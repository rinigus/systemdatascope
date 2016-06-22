#include "systemdserviceswitchcmd.h"
#include <QProcess>

#define SCTL "systemctl"


SystemDServiceSwitchCmd::SystemDServiceSwitchCmd(QString servicename, QObject *parent) :
    QObject(parent),
    m_service_name(servicename)
{
    m_extra << "--user";
    updateState();
}


void SystemDServiceSwitchCmd::updateState()
{
    // check if its enabled
    {
        QStringList args(m_extra); args << "is-enabled" << m_service_name;
        QProcess proc;
        proc.start( SCTL, args );
        if ( proc.waitForStarted() && proc.waitForFinished() )
        {
            QString out( proc.readAll() );
            bool v = out.contains("enabled");
            if ( m_enabled != v)
            {
                m_enabled = v;
                emit enabledChanged();
            }
        }
    }

    // check if its running
    {
        QStringList args(m_extra); args << "is-active" << m_service_name;
        QProcess proc;
        proc.start( SCTL, args );
        if ( proc.waitForStarted() && proc.waitForFinished() )
        {
            QString out( proc.readAll() );
            bool v = out.contains("active");
            if ( m_running != v )
            {
                m_running = v;
                emit runningChanged();
            }
        }

    }
}


void SystemDServiceSwitchCmd::startAutoUpdates(double seconds)
{
    killTimer(m_timer_id);
    if ( seconds >= 0)
        m_timer_id = startTimer(int(round(seconds * 1e3)));
}


void SystemDServiceSwitchCmd::setEnable(bool e)
{
    QStringList args(m_extra);
    if ( e ) args << "enable";
    else args << "disable";
    args << m_service_name;

    QProcess proc;
    proc.start( SCTL, args );
    proc.waitForStarted() && proc.waitForFinished();

    updateState();
}


void SystemDServiceSwitchCmd::setRun(bool r)
{
    QStringList args(m_extra);
    if ( r ) args << "start";
    else args << "stop";
    args << m_service_name;

    QProcess proc;
    proc.start( SCTL, args );
    proc.waitForStarted() && proc.waitForFinished();

    updateState();
}
