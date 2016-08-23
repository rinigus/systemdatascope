#include "imagefile.h"

#include <QFileInfo>
#include <QFile>

using namespace Graph;

void ImageFile::setImage(QImage &image)
{
    m_image = image;
    m_time = QDateTime::currentDateTimeUtc();
}
