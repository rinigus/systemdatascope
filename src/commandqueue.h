#ifndef COMMANDQUEUE_H
#define COMMANDQUEUE_H

#include <QQueue>
#include <QHash>
#include <QString>

#include <utility>
#include <functional>

namespace Graph
{

/// \brief Commands given to RRDTOOL
///
struct Command
{
    QString command;                    ///< Holds RRD command
    std::function<void()> callback;     ///< Callback that is called after execution of command
    bool is_graph = false;
    QString graph_id;
};

class CommandQueue
{
public:
    CommandQueue();

    void add(const Command &command);
    bool get(Command &command);


protected:
    QHash< QString, Command > m_commands;       ///< commands stored as a key/command pair
    QQueue< QString > m_queue;                  ///< queue stored as keys

    QString m_unique_base;
    uint m_unique_offset = 0;
};

}
#endif // COMMANDQUEUE_H
