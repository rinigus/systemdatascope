#include "imagefile.h"

#include <QFileInfo>
#include <QFile>

using namespace Graph;

void ImageFile::setImage(QByteArray fname, QSize req_size, QSize real_size, int id)
{
    m_filename = fname;
    m_req_size = req_size;
    m_real_size = real_size;
    m_id = id;
    m_time = QDateTime::currentDateTimeUtc();
}
