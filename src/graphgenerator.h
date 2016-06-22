#ifndef GRAPHGENERATOR_H
#define GRAPHGENERATOR_H

#include <QObject>
#include <QProcess>
#include <QDir>
#include <QTemporaryDir>
#include <QSize>
#include <QHash>
#include <QColor>

#include <functional>

#include "imagefile.h"
#include "commandqueue.h"

namespace Graph
{

/// \brief Generates RRD plots
///
class Generator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged) ///< when true, RRDTOOL is working

public:
    explicit Generator(QObject *parent = 0);
    ~Generator();

    bool ready() { return m_ready; }

    Q_INVOKABLE void setImageCacheTimeout(double timeout);

    /// \brief Suggests a directory with collectd databases
    ///
    /// @param temp set true if the directory should be suggested in /tmp or similar location
    Q_INVOKABLE QString suggestDirectory(bool temp);

    Q_INVOKABLE void chdir(QString dir); ///< Changes the working directory for RRDTOOL

    Q_INVOKABLE QString setConfig(QString config); ///< Parses configuration from JSON string and returns updated JSON string for GUI

    /// \brief Register new type of images
    ///
    /// First, image types and the commands have to be registered. Later the registrated types
    /// are used in getImage
    Q_INVOKABLE void registerImageType(QString type, QString command_json);

    Q_INVOKABLE void dropAllImageTypes(); ///< Drops all registered image types and all images from cache

    Q_INVOKABLE void setFontSize(QString type, int size);  ///< Sets font size for RRDTOOL. Use type as a FONTTAG in the manual

    Q_INVOKABLE void setExtraVariable(QString name, QString value);    ///< Sets variable by GUI allowing to override or complement variables provided by JSON configuration

    Q_INVOKABLE void setExtraVariable(QString name, QColor value);    ///< Sets variable by GUI allowing to override or complement variables provided by JSON configuration. An overrided function

    /// \brief Asks for a new image
    ///
    /// @param caller pointer to the calling QML object. This object property image_name will be changed when the image is ready
    ///
    Q_INVOKABLE void getImage(QObject *caller, QString id, double from, double duration, QSize size, bool full_size);

signals:
    void readyChanged();
    void errorRRDTool(QString error_text);

public slots:

protected:
    void started(); ///< Called when the RRDTOOL process has started
    void stopped(int exitCode, QProcess::ExitStatus exitStatus); ///< Called on error while starting or when RRDTOOL hsa stopped
    void stateChanged(QProcess::ProcessState newState); ///< Called when state of the process is changed

    void commandRun(); ///< Execute next command if RRDTOOL is ready
    void readFromProcess();

    virtual void timerEvent(QTimerEvent *event);

    /// \brief Called when image is ready as a callback function
    ///
    void imageCallback(QPointer<QObject> tocall, QString fname, QSize size, QString id);

    void imageSizeTypeCallback(QString size_key, QString fname,
                               // the followin options are an arguments for getImage
                               QObject *caller, QString type, double from, double duration,
                               QSize size, bool full_size);


protected:
    QDir m_current_dir;                             ///< Current working directory
    QTemporaryDir m_dir;                            ///< Directory holding images
    QHash< QString, ImageFile > m_image_cache;      ///< Image cache

    QHash< QString, QString > m_image_types;        ///< Image type -> command map
    QHash< QString, int > m_image_type_size;        ///< Keeps full image sizes for each type separately

    QHash< QString, QString > m_font_options;       ///< Font options used in the construction of all images
    QHash< QString, QString > m_extra_variables;       ///< Variables overriding or complementing JSON variables

    QProcess *m_rrdtool = NULL;    ///< pointer to RRDTOOL process
    bool m_ready = false;
    bool m_rrdtool_busy = false;

    QString m_rrdtool_output;
    CommandQueue m_command_queue;
    Command m_command_current;
    int m_rrdtool_output_skip_lines = 0;

    size_t m_next_image_index = 0;

    double m_timeout = 120; ///< Time to keep images in cache
    int m_timer_id = 0;
};

}

#endif // GRAPHGENERATOR_H
