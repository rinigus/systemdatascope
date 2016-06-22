#ifndef SYSTEMDSERVICESWITCHCMD_H
#define SYSTEMDSERVICESWITCHCMD_H

#include <QObject>
#include <QString>
#include <QStringList>

/// \brief Interface with systemd through command-line interface
///
/// This inteface uses systemctl command to start/stop/enable/disable service.
/// While not as elegant as DBus connection, it allows performing these tasks if
/// systemd is running on kdbus and dbus interface is not provided. Note that its possible to
/// write the class with the same interface, but using DBus and then just make select
/// which object to use in main()
///
class SystemDServiceSwitchCmd : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged) ///< when true, service is enabled on boot
    Q_PROPERTY(bool running READ running NOTIFY runningChanged) ///< when true, service is enabled on boot

public:
    explicit SystemDServiceSwitchCmd(QString servicename, QObject *parent = 0);
    virtual ~SystemDServiceSwitchCmd() {}

    Q_INVOKABLE bool enabled() const { return m_enabled; } ///< true if the service enabled
    Q_INVOKABLE bool running() const { return m_running; } ///< true if the service enabled

    Q_INVOKABLE void setEnable(bool e);    ///< Enable or disable the service on boot
    Q_INVOKABLE void setRun(bool r);       ///< Start (true) or stop (false) the service

    /// \brief Start or stop automatic updates
    ///
    /// Depending on the sign of the argument, starts (>=0) or kills automatic updates
    ///
    /// @param seconds period in seconds for updates. If negative, updates will stop
    Q_INVOKABLE void startAutoUpdates(double seconds);

    Q_INVOKABLE void updateState();         ///< Update state variables (enabled & running)

signals:
    void enabledChanged();
    void runningChanged();

public slots:

protected:
    virtual void timerEvent(QTimerEvent *) { updateState(); }

protected:
    QString m_service_name;
    QStringList m_extra;
    bool m_enabled = false;
    bool m_running = false;
    int m_timer_id = 0;
};

#endif // SYSTEMDSERVICESWITCHCMD_H
