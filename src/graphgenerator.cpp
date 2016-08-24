#include "graphgenerator.h"

#include <QPointer>
#include <QDebug>
#include <QImage>
#include <QTime>
#include <QMutexLocker>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>

#include <iostream>
#include <algorithm>

#define RRDTOOL_EXE "rrdtool"

using namespace Graph;

Generator::Generator(QObject *parent) :
    QObject(parent),
    QQuickImageProvider(QQmlImageProviderBase::Image),
    m_current_dir(".")
{
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
    calcProgress();

    if ( m_rrdtool_busy || !m_ready ) return; ///< RRDTOOL is processing a command or is not ready
    if ( !m_command_queue.get( m_command_current ) ) return; ///< No commands in queue

    /// Ready to process the next command

    QString com = m_command_current.command;

    //qDebug() << "Sending command: " + com;

    m_rrdtool_busy = true;
    m_rrdtool_output = QByteArray();
    //m_rrdtool_output_skip_lines = 0;

    //    // the first response line in graph command is the image size
    //    if ( m_command_current.is_graph ) m_rrdtool_output_skip_lines = 1;

    com.append("\n");
    m_rrdtool->write(com.toLatin1());
}


void Generator::readFromProcess()
{
    m_rrdtool_output.append( m_rrdtool->readAllStandardOutput() );

    // check for ERROR. NB! works for cd and graph commands. some listings could do damage,
    // if file named ERROR is in the listed directory
    //    if ( m_rrdtool_output.count('\n') > m_rrdtool_output_skip_lines ||
    //         m_rrdtool_output.indexOf("ERROR") >= 0 )
    if ( m_rrdtool_output.indexOf("OK u:") >= 0 ||
         m_rrdtool_output.indexOf("ERROR") >= 0 )
    {
        //qDebug() << "RRDTOOL returned: " << m_rrdtool_output;

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
void Generator::imageCallback(int tocall, QString fname, QSize size, QString id)
{
    m_progress_images_done++;

    QImage im; im.loadFromData(m_rrdtool_output);
    {
        QMutexLocker lk(&m_mutex);
        m_image_cache[id].setImage(im);
    }

    qDebug() << QTime::currentTime().toString("h:mm:ss") <<  " callback for " << tocall << " [" << id << "]: " << fname;
    newImage(tocall, "image://" + imageProviderName() + "/" + fname);
}


void Generator::imageSizeTypeCallback(QString size_key, QString fname,
                                      // these are arguments for getImage
                                      int caller, QString type, double from, double duration, QSize size, bool full_size
                                      )
{
    m_progress_images_done++;

    QImage im; im.loadFromData(m_rrdtool_output);
    //qDebug() << "Loading from data: " << im.loadFromData(m_rrdtool_output);
    m_image_type_size[size_key] = im.height();

    qDebug() << "Image height for " << size_key << " : " << im.height();
    getImage(caller, type, from, duration, size, full_size, "");
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
/// Image generation progress handling
///
void Generator::calcProgress()
{
    double p;
    int todo = m_command_queue.size();

    if ( todo == 0 )
    {
        m_progress_images_done = 0;
        p = -1;
    }
    else
        p = ((double)m_progress_images_done) / (todo + m_progress_images_done);

    if ( p != m_progress )
    {
        m_progress = p;
        emit progressChanged();
    }
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

    // qDebug() << "New type registered: " << type << " : " << command.toString();

    // Register with some default options
    m_image_types[type] = command.toString();
}


bool Generator::isTypeRegistered(QString type)
{
    if ( !m_image_types.contains(type) )
        return false;

    return true;
}

void Generator::dropAllImageTypes()
{
    QMutexLocker lk(&m_mutex);

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

/////////////////////////////////////////////////////////////////////////
/// Registration of image requests
///
void Generator::getImage(int caller, QString type, double from, double duration, QSize size, bool full_size, QString current_fname)
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
    {
        bool found_in_cache = false;
        {
            // to ensure that we unlock mutex before sending signal
            QMutexLocker lk(&m_mutex);
            if (m_image_cache.contains(comm.graph_id) &&
                    m_image_cache[comm.graph_id].getImageSize() == size &&
                    m_image_cache[comm.graph_id].secsTo(QDateTime::currentDateTimeUtc()) < m_timeout)
                found_in_cache = true;
        }

        if (found_in_cache)
        {
            qDebug() << QTime::currentTime().toString("h:mm:ss") <<  " Found in cache: " << comm.graph_id;
            newImage(caller, "image://" + imageProviderName() + "/" + comm.graph_id + "/" + QString::number(m_next_image_index));
            return;
        }
    }

    // ////////////////////////////
    // we have to create new image

    QString fname = comm.graph_id + "/" + QString::number(m_next_image_index);

    comm.command = "graph - ";

    QString size_key = QString::number(size.height()) + " : " + type;
    if ( full_size || m_image_type_size.contains(size_key) ) // We are ready to go
    {
        comm.command += "--full-size-mode --width=" + QString::number(size.width());

        if (full_size)
            comm.command += " --height="  + QString::number(size.height()) + " ";
        else
            comm.command += " --height=" + QString::number( m_image_type_size[size_key] ) + " ";

        comm.callback = std::bind(&Generator::imageCallback, this, caller,
                                  fname, size, comm.graph_id);
    }
    else // we have to make a test graph first, to determine the full height of the image
    {
        // test image can be smaller in width, no need to make full image to get height
        // there is no --full-size-mode option here, we give canvas!
        // Correction: there could be problems with long legends. So, let's keep full size
        comm.command +=
                //" --width=" + QString::number(std::min( size.width(), 100 ) ) +
                " --width=" + QString::number( size.width() ) +
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

    //    if ( m_timer_id != 0 ) killTimer(m_timer_id);
    //    m_timer_id = startTimer( m_timeout * 1000 );
}

void Generator::checkCache()
{
    QDateTime now = QDateTime::currentDateTimeUtc();
    QMutexLocker lk(&m_mutex);

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


///////////////////////////////////////////////////////////
/// Image provider
///

QImage Generator::requestImage(const QString &id_fname, QSize *size, const QSize &requestedSize)
{
    QMutexLocker lk(&m_mutex);

    QString id = id_fname.left( id_fname.lastIndexOf("/") );

    //qDebug() << "Image provider called: " << id_fname << " : " << id;

    QImage im = m_image_cache.value(id).getImage();

    if (size)
        *size = im.size();

    if ( (requestedSize.width() > 0 ||
          requestedSize.height() > 0) && im.size() != requestedSize )
    {
        qDebug() << "Image sizes don't match: " << id << " req=" << requestedSize << " avail=" << im.size();
        return im.scaled(requestedSize);
    }

    return im;
}

//void Generator::timerEvent(QTimerEvent *)
//{
//    QDateTime now = QDateTime::currentDateTimeUtc();
//    for (bool erased = true; erased; )
//    {
//        erased = false;
//        for (auto i = m_image_cache.begin(); i != m_image_cache.end(); ++i)
//        {
//            if (i.value().secsTo(now) > m_timeout)
//            {
//                m_image_cache.erase(i);
//                erased = true;
//                break; // get out of inner loop and work through the cache again
//            }
//        }
//    }
//}


