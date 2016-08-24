#ifndef IMAGEFILE_H
#define IMAGEFILE_H

#include <QByteArray>
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
public:

    ImageFile() {}
    ~ImageFile() { }

    void setImage(QByteArray fname, QSize req_size, QSize real_size, int id);                                 ///< Sets a new file to track

    int getId() const { return m_id; }
    QByteArray getFilename() const { return m_filename; }                             ///< Tracked filename
    QSize getImageReqSize() const { return m_req_size; }
    QSize getImageRealSize() const { return m_real_size; }
    double secsTo(const QDateTime &other) const { return m_time.secsTo(other); }   ///< Number of seconds from registration of the file to other

protected:

protected:
    QByteArray m_filename;
    QDateTime m_time;
    QSize m_req_size;
    QSize m_real_size;
    int m_id = -5;
};

}
#endif // IMAGEFILE_H
