#include "configurator.h"
#include "global.h"

#include <QDebug>

#include <QDirIterator>
#include <QStandardPaths>
#include <QDir>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>

#include <QProcess>

#include <iostream>

using namespace Graph;

#define MAKECONFIG_EXE "systemdatascope-makeconfig"


QString Configurator::defaultColorLineMain("#0000FFFF");
QString Configurator::defaultColorLineSecondary("#0000FF80");

Configurator::Configurator(QObject *parent) : QObject(parent)
{

}

Configurator::~Configurator()
{
    if (m_makeconfig)
    {
        m_makeconfig->kill();
        if (m_makeconfig)
            delete m_makeconfig;
    }
}

/////////////////////////////////////////////////////////////////////////
/// Directories related functions
///
QString Configurator::suggestDirectory(bool temp)
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

QString Configurator::isDirectoryOK(QString dirname, bool must_be_there)
{
    // check if dir exists
    if ( dirname.length() < 1 )
    {
        if ( must_be_there )
            return "Error: Directory name is empty";
        else
            return "Empty directory name; this is OK";
    }

    QDir dir(dirname);
    if (!dir.exists())
    {
        if (must_be_there) return "Error: Directory does not exists";
        else return "Directory does not exist, but this is not an error. It should be created when needed.";
    }

    // Let's see if there are RRD files organized as dir/files.rrd
    dir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot | QDir::NoSymLinks);
    QDirIterator itdir(dir);
    QStringList fname; fname << "*.rrd";
    while (itdir.hasNext())
    {
        QDir subdir(itdir.next());
        if ( subdir.entryList(fname, QDir::Files).size() > 0 )
            // we have found at least one rrd in correct place
            return "OK";
    }

    return "Error: no RRD files found";
}

/////////////////////////////////////////////////////////////////////////
/// Set extra variables
///
void Configurator::setExtraVariable(QString name, QString value)
{
    m_extra_variables[ name ] = value;
}

void Configurator::setExtraVariable(QString name, QColor value)
{
    m_extra_variables[ name ] = qcolor2rrd(value);
}


////////////////////////////////////////////////////////
/// Configuration parser
///

#define RETERRS(comment) { std::cerr << "\n" << comment << "\n" << std::endl; return QString(); }
#define RETERRB(comment) { std::cerr << "\n" << comment << "\n" << std::endl; return false; }

/// configuration checker
bool Configurator::checkConfig(QJsonObject &init) const
{
    if ( !init.contains("types") || !init["types"].isObject() )
        RETERRB("JSON configuration missing types or they are not defined as JSON object");

    if ( !init.contains("page") || !init["page"].isObject() )
        RETERRB("JSON configuration missing page and it is not defined as JSON object");

    if ( init.contains("cover") && !init["cover"].isArray() )
        RETERRB("JSON configuration cover that is not defined as JSON array");

    return true;
}

/// Main parsing function
QString Configurator::parseConfig(QString config)
{
    // check if configuration is fine
    QJsonParseError perror;
    QJsonDocument document_init( QJsonDocument::fromJson( config.toLatin1(), &perror ) );
    if ( document_init.isNull() || !document_init.isObject() )
    {
        qDebug() << perror.errorString();
        RETERRS("JSON Document parsing error or document is not an object: " + config.toStdString());
    }

    QJsonObject init (document_init.object());
    if ( !checkConfig(init) ) return QString();

    // Lets replace all variables
    if ( init.contains("variables") )
    {
        QJsonValue vars_val = init["variables"];
        if (!vars_val.isObject()) RETERRS("JSON configuration: variables are not defined as an object");
        QJsonObject vars = vars_val.toObject();

        QStringList work;
        work.append("types");

        foreach (QString curr, work)
        {
            QJsonDocument curr_doc(init[curr].toObject());
            QString curr_str = curr_doc.toJson();

            for (QJsonObject::iterator iterVar = vars.begin(); iterVar != vars.end(); ++iterVar)
            {
                QString varName = iterVar.key();
                QString varValue = iterVar.value().toString();

                // perform replacement only if the variable is NOT in m_extra_variables
                if ( !m_extra_variables.contains(varName)
     #ifdef LINE_COLOR_PROGRAM
                     // or if it is single line color
                     && varName != VARIABLE_COLOR_SINGLE_LINE_MAIN
                     && varName != VARIABLE_COLOR_SINGLE_LINE_SECONDARY
     #endif
                     )
                    curr_str.replace("$" + varName +"$", varValue);

#ifdef LINE_COLOR_PROGRAM
                if (varName == VARIABLE_COLOR_SINGLE_LINE_MAIN)
                    defaultColorLineMain = varValue;
                else if (varName == VARIABLE_COLOR_SINGLE_LINE_SECONDARY)
                    defaultColorLineSecondary = varValue;
#endif
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

        foreach (QString curr, work)
        {
            QJsonDocument curr_doc(init[curr].toObject());
            QString curr_str = curr_doc.toJson();

            QHashIterator<QString, QString> iter(m_extra_variables);
            while (iter.hasNext())
            {
                iter.next();

                QString varName = iter.key();
                QString varValue = iter.value();

#ifdef LINE_COLOR_PROGRAM
                // replace if it is not single line color
                if (
                    varName != VARIABLE_COLOR_SINGLE_LINE_MAIN &&
                    varName != VARIABLE_COLOR_SINGLE_LINE_SECONDARY
                        )
#endif
                    curr_str.replace("$" + varName +"$", varValue);

#ifdef LINE_COLOR_PROGRAM
                if (varName == VARIABLE_COLOR_SINGLE_LINE_MAIN)
                    defaultColorLineMain = varValue;
                else if (varName == VARIABLE_COLOR_SINGLE_LINE_SECONDARY)
                    defaultColorLineSecondary = varValue;
#endif
            }

            QJsonDocument curr_after( QJsonDocument::fromJson( curr_str.toLatin1() ) );
            init[curr] = curr_after.object();
        }
    }


    QJsonDocument result( init );

    return result.toJson();
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
/// Configuration generation using makeconfig script
///

void Configurator::makeConfiguration(QString dirname)
{
    if ( m_makeconfig != nullptr ) return; /// we have generator running already

    m_makeconfig = new QProcess();
    m_dirname = dirname;

    QString progname = MAKECONFIG_EXE;
    QStringList arguments;
    arguments << dirname;

    connect( m_makeconfig, &QProcess::stateChanged,
             this, &Configurator::makeconfig_stateChanged );

    m_makeconfig->start(progname, arguments);
}


QString Configurator::makeconfig_errorhead()
{
    return QString("Called generator script: ") + MAKECONFIG_EXE + "\n" +
            "Called with directory as an argument: " + m_dirname + "\n\n";
}

void Configurator::makeconfig_stateChanged(QProcess::ProcessState newState)
{
    if (m_makeconfig && newState == QProcess::NotRunning )
    {
        // Let's get all output. If error occurred, output would be empty
        QString config = m_makeconfig->readAllStandardOutput();

        if ( config.length() < 1 )
        {
            emit errorConfigurator(
                        makeconfig_errorhead() +
                        QString("No output was generated by the ") + MAKECONFIG_EXE + " (maybe script is not in the PATH). Error state: " +
                        m_makeconfig->errorString());
        }
        else
        {
            QJsonParseError perror;
            QJsonDocument document_init( QJsonDocument::fromJson( config.toLatin1(), &perror ) );
            if ( document_init.isNull() || !document_init.isObject() )
            {
                const int maxl = 3000;
                if ( config.length() > maxl)
                    config = config.left(maxl) + "\n... trimmed here ...";

                emit errorConfigurator(
                            makeconfig_errorhead() +
                            QString("JSON Document parsing error or generated document is not an object: ") + config);
            }

            else
            {
                QJsonObject init (document_init.object());
                if ( !checkConfig(init) )
                    emit errorConfigurator(
                            makeconfig_errorhead() +
                            "Error while checking generated JSON configuration" );
                else
                    emit newConfiguration( config );

            }
        }

        m_makeconfig->deleteLater();
        m_makeconfig = nullptr;
    }
}
