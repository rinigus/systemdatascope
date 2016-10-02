#include "global.h"

QString qcolor2rrd(const QColor &color)
{
    QString v = color.name(QColor::HexArgb);
    return "#" + v.mid(3) + v.mid(1,2);
}
