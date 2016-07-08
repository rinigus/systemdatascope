#ifndef CONFIGURATOR_H
#define CONFIGURATOR_H

#include <QObject>
#include <QString>
#include <QColor>
#include <QHash>
#include <QJsonObject>
#include <QProcess>

namespace Graph {

/// \brief Reads and checks configuration of graphs
///
/// This class checks JSON configuration, checks directories and
/// can generate configuration on user's request using makeconfig
/// as an external program
///
class Configurator : public QObject
{
    Q_OBJECT
public:
    explicit Configurator(QObject *parent = 0);
    ~Configurator();

signals:
    void errorConfigurator(QString error_text);
    void newConfiguration(QString config);

public slots:

public:

    /// \brief Parses configuration from JSON string and returns updated JSON string for GUI
    ///
    /// This function substitutes all variables and makes configuration ready
    /// to be used by grapher
    ///
    Q_INVOKABLE QString parseConfig(QString config);

    /// \brief Sets variable by GUI allowing to override or complement variables provided by JSON configuration
    ///
    Q_INVOKABLE void setExtraVariable(QString name, QString value);

    /// \brief Sets variable by GUI allowing to override or complement variables provided by JSON configuration
    ///
    Q_INVOKABLE void setExtraVariable(QString name, QColor value);

    /// \brief Suggests a directory with collectd databases
    ///
    /// @param temp set true if the directory should be suggested in /tmp or similar location
    Q_INVOKABLE QString suggestDirectory(bool temp);

    Q_INVOKABLE QString isDirectoryOK(QString dir); ///< Checks if directory is [possibly] keeping collectd RRD files

    /// \brief Generate configuration using makeconfig script
    ///
    Q_INVOKABLE void makeConfiguration(QString dirname);

protected:
    bool checkConfig (QJsonObject &init) const;

    void makeconfig_stateChanged(QProcess::ProcessState newState);

    QString makeconfig_errorhead();

protected:
    QHash< QString, QString > m_extra_variables;       ///< Variables overriding or complementing JSON variables

    QProcess *m_makeconfig = nullptr;   ///< Keeps a pointer of makeconfig process while its running
    QString m_dirname;                  ///< Keeps a directory argument with which makeconfig was called
};
}

#endif // CONFIGURATOR_H
