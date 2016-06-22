#include "graphgenerator.h"

#include <QPointer>
#include <QDebug>
#include <QImage>

#include <QDirIterator>
#include <QStandardPaths>
#include <QDir>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>

#include <iostream>
#include <algorithm>

#define RRDTOOL_EXE "rrdtool"
#define IMAGE_PROPERTY_NAME "image_fname"

using namespace Graph;

Generator::Generator(QObject *parent) :
    QObject(parent),
    m_current_dir(".")
{
    // Continue only if temp dir creation was fine
    if ( !m_dir.isValid() ) return;

    QString progname = RRDTOOL_EXE;
    QStringList arguments;
    arguments << "-";

    m_rrdtool = new QProcess(this);

    connect( m_rrdtool, &QProcess::started,
             this, &Generator::started );

    connect( m_rrdtool, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
             this, &Generator::stopped );

    connect( m_rrdtool, &QProcess::stateChanged,
             this, &Generator::stateChanged );

    connect( m_rrdtool, &QProcess::readyReadStandardOutput,
             this, &Generator::readFromProcess );

    m_rrdtool->start(progname, arguments);

    // start timer to check cache
    setImageCacheTimeout(m_timeout);
}


Generator::~Generator()
{
    if (m_rrdtool)
    {
        m_rrdtool->write("quit\n");
        m_rrdtool->closeWriteChannel();
        m_rrdtool->waitForFinished(5000);
    }
}

/// Functions following RRDTOOL
void Generator::started()
{
    m_ready = true;
    emit readyChanged();
    commandRun(); // if there are some commands in queue already
}


void Generator::stopped(int /*exitCode*/, QProcess::ExitStatus /*exitStatus*/)
{
    m_ready = false;
    emit readyChanged();
}


void Generator::stateChanged(QProcess::ProcessState state)
{
    if ( m_ready && state != QProcess::Running )
    {
        m_ready = false;
        emit readyChanged();
        return;
    }

    if ( !m_ready && state == QProcess::Running )
    {
        m_ready = true;
        emit readyChanged();
        return;
    }
}


/// RRDTOOL command processings
void Generator::commandRun()
{
    if ( m_rrdtool_busy || !m_ready ) return; ///< RRDTOOL is processing a command or is not ready
    if ( !m_command_queue.get( m_command_current ) ) return; ///< No commands in queue

    /// Ready to process the next command

    QString com = m_command_current.command;

    qDebug() << "Sending command: " + com;

    m_rrdtool_busy = true;
    m_rrdtool_output = QString();
    m_rrdtool_output_skip_lines = 0;

    // the first response line in graph command is the image size
    if ( m_command_current.is_graph ) m_rrdtool_output_skip_lines = 1;

    com.append("\n");
    m_rrdtool->write(com.toLatin1());
}


void Generator::readFromProcess()
{
    m_rrdtool_output.append( m_rrdtool->readAllStandardOutput() );

    // check for ERROR. NB! works for cd and graph commands. some listings could do damage,
    // if file named ERROR is in the listed directory
    if ( m_rrdtool_output.count('\n') > m_rrdtool_output_skip_lines ||
         m_rrdtool_output.indexOf("ERROR") >= 0 )
    {
        qDebug() << "RRDTOOL returned: " << m_rrdtool_output;

        if (m_rrdtool_output.indexOf("OK") >= 0 && m_rrdtool_output.indexOf("ERROR") < 0 ) /// All went fine
        {
            if (m_command_current.callback) m_command_current.callback();
        }
        else
        {
            emit errorRRDTool(m_rrdtool_output);
        }

        m_rrdtool_busy = false;
        m_command_current = Command();
        commandRun();
    }
}

////////////////////////////////////////////////
/// Misc functions
///

QString Generator::suggestDirectory(bool temp)
{
    QString dir;

    if ( temp )
        dir = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + QDir::separator() + "collectd";
    else
        dir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + QDir::separator() + "collectd";

    QDir d(dir);
    QStringList l = d.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    if (l.size() > 0)
    {
        d.cd( l[0] );
        dir = d.path();
        qDebug() << "Suggested directory: " << dir;
    }
    else dir = "";

    return dir;
}

void Generator::chdir(QString dir)
{
    // check if dir exists
    if ( dir.length() < 1 || !QDir(dir).exists() )
    {
        emit errorRRDTool( "Cannot change to directory: " + dir );
        return;
    }

    m_current_dir.cd(dir);

    Command comm;
    comm.command = "cd " + dir;
    m_command_queue.add(comm);
    commandRun();
}


/////////////////////////////////////////////////////////////////////////
/// Image callback
///
void Generator::imageCallback(QPointer<QObject> tocall, QString fname, QSize size, QString id)
{
    qDebug() << "Callback for " << id << ": " << fname;

    if (tocall)
        tocall->setProperty(IMAGE_PROPERTY_NAME, "file://" + fname);

    m_image_cache[id].setImage(fname, size);
}


void Generator::imageSizeTypeCallback(QString size_key, QString fname,
                                      // these are arguments for getImage
                                      QObject *caller, QString type, double from, double duration, QSize size, bool full_size
                                      )
{
    QImage im(fname);
    m_image_type_size[size_key] = im.height();

    qDebug() << "Image height for " << size_key << " : " << im.height();

    m_image_cache[size_key].setImage(fname, size); // to delete as any other cache file

    getImage(caller, type, from, duration, size, full_size);
}


static QString timestr(double t)
{
    QString time;
    if (fabs(t) > 30*24*60*60) // change to days if the time is more than 10 days away
        time = QString::number(t / (24*60*60), 'f', 0) + "D";
    else
        time = QString::number(t, 'f', 0);
    return time;
}

/////////////////////////////////////////////////////////////////////////
/// Register image type
///
void Generator::registerImageType(QString type, QString command_json)
{
    QJsonDocument document( QJsonDocument::fromJson( command_json.toLatin1() ) );
    if (!document.isObject())
    {
        std::cerr << "Failed to register image type: " << type.toStdString() << std::endl;
        return;
    }

    QJsonObject obj( document.object() );
    QJsonValue command( obj.value("command") );
    QJsonValue files( obj.value("files") );

    if ( !command.isString() || !( files.isArray() || files.Undefined ))
    {
        std::cerr << "Cannot register command: " << type.toStdString() << " something is wrong with definition:\n"
                  << QString(document.toJson()).toStdString() << std::endl;
    }

    if ( files.isArray() )
    {
        QJsonArray files_array( files.toArray() );
        for (int i=0; i < files_array.size(); ++i)
        {
            QJsonValue v( files_array.at(i) );
            if (!v.isString())
            {
                std::cerr << "Cannot register command: " << type.toStdString() << " something is wrong with definition:\n"
                          << QString(document.toJson()).toStdString() << std::endl;
            }

            if ( !m_current_dir.exists(v.toString()) ) // required file does not exist, skip registration
                return;
        }
    }

    qDebug() << "New type registered: " << type << " : " << command.toString();

    // Register with some default options
    m_image_types[type] = command.toString();
}

void Generator::dropAllImageTypes()
{
    m_image_types = QHash<QString, QString >();
    m_image_type_size = QHash<QString, int>();
    m_image_cache = QHash< QString, ImageFile >();
}

/////////////////////////////////////////////////////////////////////////
/// Set font options and extra variables
///
void Generator::setFontSize(QString type, int size)
{
    m_font_options[ type + " SIZE"] = "--font " + type + ":" + QString::number(size, 10) + ":.";
}

void Generator::setExtraVariable(QString name, QString value)
{
    m_extra_variables[ name ] = value;
}

void Generator::setExtraVariable(QString name, QColor value)
{
    QString v = value.name(QColor::HexArgb);
    m_extra_variables[ name ] = "#" + v.mid(3) + v.mid(1,2);
}


/////////////////////////////////////////////////////////////////////////
/// Registration of image requests
///
void Generator::getImage(QObject *caller, QString type, double from, double duration, QSize size, bool full_size)
{
    // check sanity
    if (size.width() < 1 || size.height() < 1) return; // called when initializing image, will call again soon

    if ( !m_image_types.contains(type) )
    {
        qDebug() << "Key " << type << " missing among registered types";
        return;
    }

    // sanity: ok

    m_next_image_index++;

    Command comm;
    QString timing;
    timing = "--start " + timestr(from - duration) + " ";

    if ( fabs(from) < 1e-8 ) // check for zero
        timing += "--end -0D ";
    else
        timing += "--end " + timestr(from) + " ";

    comm.is_graph = true;
    comm.graph_id = type + " " + timing;

    // check if we have it in cache and it hasn't expired
    if (m_image_cache.contains(comm.graph_id) &&
            m_image_cache[comm.graph_id].getImageSize() == size &&
            m_image_cache[comm.graph_id].secsTo(QDateTime::currentDateTimeUtc()) < m_timeout)
    {
        qDebug() << "Found in cache: " << comm.graph_id;
        caller->setProperty( IMAGE_PROPERTY_NAME, "file://" + m_image_cache[comm.graph_id].getFilename() );
        return;
    }

    // ////////////////////////////
    // we have to create new image

    QDir d(m_dir.path());
    QString fname( d.filePath( QString::number(m_next_image_index) + ".png" ));

    comm.command = "graph " + fname + " ";

    QString size_key = QString::number(size.height()) + " : " + type;
    if ( full_size || m_image_type_size.contains(size_key) ) // We are ready to go
    {
        comm.command += "--full-size-mode --width=" + QString::number(size.width());

        if (full_size)
            comm.command += " --height="  + QString::number(size.height()) + " ";
        else
            comm.command += " --height=" + QString::number( m_image_type_size[size_key] ) + " ";

        comm.callback = std::bind(&Generator::imageCallback, this, QPointer<QObject>(caller),
                                  fname, size, comm.graph_id);
    }
    else // we have to make a test graph first, to determine the full height of the image
    {
        // test image can be smaller in width, no need to make full image to get height
        // there is no --full-size-mode option here, we give canvas!
        comm.command +=
                " --width=" + QString::number(std::min( size.width(), 100 ) ) +
                " --height="  + QString::number(size.height()) + " ";

        // callback will first register the size and later call this method again
        // to retrieve an image
        comm.callback = std::bind(&Generator::imageSizeTypeCallback, this, size_key, fname,
                                  caller, type, from, duration, size, full_size );
    }

    comm.command += timing;

    // add font options
    foreach (QString f, m_font_options.values())
        comm.command += f + " ";

    comm.command += m_image_types[type];

    m_command_queue.add(comm);
    commandRun();
}



////////////////////////////////////////////////////////
/// Image cache handling
///

void Generator::setImageCacheTimeout(double timeout)
{
    m_timeout = timeout;

    if ( m_timer_id != 0 ) killTimer(m_timer_id);
    m_timer_id = startTimer( m_timeout * 1000 );
}


void Generator::timerEvent(QTimerEvent *)
{
    QDateTime now = QDateTime::currentDateTimeUtc();
    for (bool erased = true; erased; )
    {
        erased = false;
        for (auto i = m_image_cache.begin(); i != m_image_cache.end(); ++i)
        {
            if (i.value().secsTo(now) > m_timeout)
            {
                m_image_cache.erase(i);
                erased = true;
                break; // get out of inner loop and work through the cache again
            }
        }
    }
}


////////////////////////////////////////////////////////
/// Configuration parser
///

#define RETERR(comment) { std::cerr << "\n" << comment << "\n" << std::endl; return QString(); }

/// Main parsing function
QString Generator::setConfig(QString config)
{
    // check if configuration is fine
    QJsonParseError perror;
    QJsonDocument document_init( QJsonDocument::fromJson( config.toLatin1(), &perror ) );
    if ( document_init.isNull() || !document_init.isObject() )
    {
        qDebug() << perror.errorString();
        RETERR("JSON Document parsing error or document is not an object: " + config.toStdString());
    }

    QJsonObject init (document_init.object());

    if ( !init.contains("types") || !init["types"].isObject() )
        RETERR("JSON configuration missing types or they are not defined as JSON object");

    if ( !init.contains("page") || !init["page"].isObject() )
        RETERR("JSON configuration missing page and it is not defined as JSON object");

    std::cout << "Init JSON: \n"
              << QString(document_init.toJson()).toStdString() << std::endl;

    // Lets replace all variables
    if ( init.contains("variables") )
    {
        QJsonValue vars_val = init["variables"];
        if (!vars_val.isObject()) RETERR("JSON configuration: variables are not defined as an object");
        QJsonObject vars = vars_val.toObject();

        QStringList work;
        work.append("types");
        work.append("page");

        foreach (QString curr, work)
        {
            QJsonDocument curr_doc(init[curr].toObject());
            QString curr_str = curr_doc.toJson();

            for (QJsonObject::iterator iterVar = vars.begin(); iterVar != vars.end(); ++iterVar)
            {
                QString varName = iterVar.key();
                QString varValue = iterVar.value().toString();

                // perform replacement only if the variable is NOT in m_extra_variables
                if ( !m_extra_variables.contains(varName) )
                    curr_str.replace("$" + varName +"$", varValue);
            }

            QJsonDocument curr_after( QJsonDocument::fromJson( curr_str.toLatin1() ) );
            init[curr] = curr_after.object();
        }
    }

    // Replace all extra variables
    if ( m_extra_variables.size() > 0 )
    {
        QStringList work;
        work.append("types");
        work.append("page");

        foreach (QString curr, work)
        {
            QJsonDocument curr_doc(init[curr].toObject());
            QString curr_str = curr_doc.toJson();

            QHashIterator<QString, QString> iter(m_extra_variables);
            while (iter.hasNext())
            {
                iter.next();
                curr_str.replace("$" + iter.key() +"$", iter.value());
            }

            QJsonDocument curr_after( QJsonDocument::fromJson( curr_str.toLatin1() ) );
            init[curr] = curr_after.object();
        }
    }


    QJsonDocument result( init );

    std::cout << "End JSON: \n"
              << QString(result.toJson()).toStdString() << std::endl;

    return result.toJson();
}
