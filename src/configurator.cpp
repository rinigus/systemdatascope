#include "configurator.h"

#include <QDebug>

#include <QDirIterator>
#include <QStandardPaths>
#include <QDir>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>

#include <iostream>

using namespace Graph;

Configurator::Configurator(QObject *parent) : QObject(parent)
{

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

//#define ERR(txt) { error = txt; return false; }

QString Configurator::isDirectoryOK(QString dirname)
{
    // check if dir exists
    if ( dirname.length() < 1 ) return "Error: Directory name is empty";

    QDir dir(dirname);
    if (!dir.exists()) return "Error: Directory does not exists";

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
    QString v = value.name(QColor::HexArgb);
    m_extra_variables[ name ] = "#" + v.mid(3) + v.mid(1,2);
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

    return result.toJson();
}
