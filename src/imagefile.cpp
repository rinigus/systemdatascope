#include "imagefile.h"

#include <QFileInfo>
#include <QFile>

using namespace Graph;

size_t Graph::ImageFile::total_size = 0;

void ImageFile::deleteFile()
{
    if ( m_filename.length() == 0 ) return;

    total_size -= m_size;
    m_size = 0;

    QFileInfo info(m_filename);
    if (info.exists())
        QFile::remove(m_filename);
}


void ImageFile::setImage(QString fname, QSize imsize)
{
    deleteFile(); // cleanup

    m_filename = fname;
    m_image_size = imsize;

    QFileInfo info(m_filename);
    if (info.exists())
    {
        m_size = info.size();
        total_size += m_size;
    }

    m_time = QDateTime::currentDateTimeUtc();
}
