#ifndef IMAGEFILE_H
#define IMAGEFILE_H

#include <QString>
#include <QDateTime>
#include <QSize>
#include <QImage>

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
    ~ImageFile() {}

    void setImage(QImage &image);                                 ///< Sets a new file to track

    QImage getImage() const { return m_image; }                             ///< Tracked filename
    QSize getImageSize() const { return m_image.size(); }
    double secsTo(const QDateTime &other) const { return m_time.secsTo(other); }   ///< Number of seconds from registration of the file to other

protected:
    QImage m_image;
    QDateTime m_time;
    QSize m_image_size;
};

}
#endif // IMAGEFILE_H
