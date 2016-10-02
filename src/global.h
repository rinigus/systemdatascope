#ifndef GLOBAL_H
#define GLOBAL_H

#include <QString>
#include <QColor>

#ifdef LINE_COLOR_PROGRAM
#define VARIABLE_COLOR_SINGLE_LINE_MAIN         "COLOR_LINE_SINGLE"
#define VARIABLE_COLOR_SINGLE_LINE_SECONDARY    "COLOR_LINE_SINGLE_SUB"
#endif

/// \brief Convert between QColor and rrdtool color representation
///
QString qcolor2rrd(const QColor &color);

#endif // GLOBAL_H
