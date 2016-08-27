#ifndef IMAGEFILE_H
#define IMAGEFILE_H

#include <QString>
#include <QDateTime>
#include <QSize>

namespace Graph
{

/// \brief Image file tracking object
///
/// Allows access to the image file name, its size, and deletes the image
/// file on destruction. No copy operator or constructor are allowed - it has to be
/// a single object tracking this particular file
///
class ImageFile
{
protected:
    static size_t total_size;

public:
    static size_t getTotalSize() { return total_size; }                           ///< Size of all currently held image files in bytes

public:

    ImageFile() {}
    ~ImageFile() { deleteFile(); }

    void setImage(QString fname, QSize imsize);                                 ///< Sets a new file to track

    size_t getSize() const { return m_size; }                                      ///< Size of the tracked file
    QString getFilename() const { return m_filename; }                             ///< Tracked filename
    QSize getImageSize() const { return m_image_size; }
    double secsTo(const QDateTime &other) const { return m_time.secsTo(other); }   ///< Number of seconds from registration of the file to other

protected:
    void deleteFile();

protected:
    QString m_filename;
    QDateTime m_time;
    size_t m_size = 0;
    QSize m_image_size;
};

}
#endif // IMAGEFILE_H
