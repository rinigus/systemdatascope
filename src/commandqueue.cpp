#include "commandqueue.h"

#include <QUuid>
#include <QDebug>

using namespace Graph;

CommandQueue::CommandQueue()
{
    QUuid id;
    m_unique_base = id.toByteArray();
}


void CommandQueue::add(const Command &command)
{
    QString id;

    // Make unique id if its not graph
    if ( !command.is_graph )
    {
        id = m_unique_base + QString::number(m_unique_offset);
        m_unique_offset++;
    }
    else id = command.graph_id;

    if (!m_commands.contains( id ))
        m_queue.enqueue(id);
    m_commands[ id ] = command;
}


bool CommandQueue::get(Command &command)
{
    if (m_queue.length() == 0) return false;

    QString id = m_queue.dequeue();
    command = m_commands.take(id);
    return true;
}

int CommandQueue::size() const
{
    return m_queue.size();
}
