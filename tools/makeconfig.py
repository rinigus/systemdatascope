import json, os, os.path, argparse, glob, re

parser = argparse.ArgumentParser(description='Generate JSON configuration file for SystemDataScope')
parser.add_argument('root_dir', type=str,
                    help='Root directory with collectd RRD databases, for example /tmp/collectd/Jolla')

args = parser.parse_args()

Root = args.root_dir
os.chdir(Root)

Config = {}

Config["variables"] = {
    "COLOR_BACKGROUND": "#00000000",
    "COLOR_CANVAS": "#00000000",
    "COLOR_FONT": "#000000FF",
    "COLOR_AXIS": "#000000FF",
    "COLOR_ARROW": "#000000FF",
    "COLOR_LINE_SINGLE": "#0000FFFF",
    "COLOR_LINE_SINGLE_SUB": "#0000FF80",

    "LINE_WIDTH_PRIMARY": "3",
    "LINE_WIDTH_SECONDARY": "1"    
    }

Config["page"] = {
    
    "title": "Overview",
    "plots": [
    ]
}

defColors = "--color BACK$COLOR_BACKGROUND$ --color SHADEA$COLOR_BACKGROUND$ --color SHADEB$COLOR_BACKGROUND$ --color CANVAS$COLOR_CANVAS$  "
defColors += "--color FONT$COLOR_FONT$ --color AXIS$COLOR_AXIS$ --color ARROW$COLOR_ARROW$ "

######################################################################################
## Helper classes

class ColorSingle:
    def __init__(self, color):
        self.color = color

    def set_number_of_lines(self, n):
        # noop
        self.n = n

    def get_color(self, i):
        return self.color

class Colors:
    # internally stored as RGBA integers 
    def __init__(self, colors, last_transparent = False):
        self.colors = colors
        self.n = None
        self.last_transparent = last_transparent
        
    def set_number_of_lines(self, n):
        self.n = n

    def makestr(self, c):
        s = "#"
        for i in c:
            s += ("%02X" % int(round(i)) )
        return s

    def get_color(self, i):
        if i == 0: return self.makestr(self.colors[0])
        if i >= self.n-1:
            if self.last_transparent: return self.makestr([0,0,0,0])
            return self.makestr(self.colors[-1])

        dline = float(i) / float(self.n-1)
        color0 = int( (len(self.colors) - 1) * dline )
        factor = (len(self.colors) - 1) * dline - color0
        c = []
        for i in range(len(self.colors[color0])):
            c.append( (1-factor)*self.colors[color0][i] + factor*self.colors[color0+1][i] )
        return self.makestr(c)

    
class StackOrLines:
    def __init__(self, col, isStack = False, t = "LINE"):
        self.lines = []
        self.gt = t
        self.colors = col
        self.isStack = isStack

    def add(self, name, width, options, extra="", makeLine=False):
        self.lines.append( { "name": name,
                             "width": width,
                             "options": options,
                             "extra": extra,
                             "makeLine": makeLine } )
        # cmd = self.gt + ":" + l
        # if self.count > 0 and not makeLine:
        #     cmd += ":STACK"
        # self.lines.append(cmd)
        # self.count += 1

    def str(self):
        s = ""
        self.colors.set_number_of_lines(len(self.lines))
        for idx, i in enumerate(self.lines):
            color = self.colors.get_color(idx) 
            s += self.gt
            if self.gt == "LINE": s += i["width"]
            s += ":" + i["name"] + color + ":" + i["options"]
            if self.isStack and idx > 0 and not i["makeLine"]: s += ":STACK"
            s += " " + i["extra"] + " "
        return s    
        
######################################################################################
# Colorschemes. If more are needed, see at http://colorbrewer2.org/

# http://colorbrewer2.org/?type=qualitative&scheme=Set1&n=8
cmap = [ [228,26,28,255],[55,126,184,255],[77,175,74,255],[152,78,163,255],[255,127,0,255],[255,255,51,255],[166,86,40,255],[247,129,191,255] ]
csFull = Colors( cmap )
csFullTr = Colors( cmap, True )

cs3Col = Colors( [ [228,26,28,255],[55,126,184,255],[77,175,74,255] ] )

csSingle = ColorSingle( "$COLOR_LINE_SINGLE$" )

######################################################################################
Units = { "DEFAULT": "",
          "voltage": "V",
          "current": "A" }

Formats = { "DEFAULT": "%0.2lf",
            "voltage": "%1.3lf%S",
            "current": "%1.0lf%S",
            "context_switch": "%1.0lf%S" }

def getit(name, D):
    if name in D: return D[name]
    return D["DEFAULT"]

def getunit(name): return getit(name, Units)
def getf(name): return getit(name, Formats)

######################################################################################
# Helper function for a single value plot
def maketypesplot(name, g, Type, Title = None):
    
    f = getf(name)
    u = getunit(name)
    frm = f + u
    
    command_def = '-t " '
    if Title is not None: command_def += Title
    else: command_def += Type + " " + name

    if len(u) > 0: command_def += ", " + u
    command_def += '"  '  + " " + defColors
    
    command_line = ""
    files = []
    s = StackOrLines(csSingle)
    command_def += "DEF:" + name + "=" + g + ":value:AVERAGE "
    command_def += "DEF:" + name + "_min=" + g + ":value:MIN "
    command_def += "DEF:" + name + "_max=" + g + ":value:MAX "
    command_def += "CDEF:" + name + "_max_min_delta=" + name + "_max," + name + "_min,- "
    command_def += "LINE:" + name + "_min AREA:" + name + "_max_min_delta$COLOR_LINE_SINGLE_SUB$::STACK "
    s.add( name, "$LINE_WIDTH_PRIMARY$", "\"" + name + '\\l"',
           "COMMENT:\\u GPRINT:"+name+":AVERAGE:\"Avr " + frm + "\" GPRINT:"+name+"_min:MIN:\"Min " + frm +
           "\" GPRINT:"+name+"_max:MAX:\"Max " + frm + "\" GPRINT:"+name+":LAST:\"Last " + frm + "\\r\" ")
    files.append(g)

    command_line = s.str()

    gt = { "command": command_def + command_line,
           "files": files }
    plot = { "type": Type + "/" + name }

    return gt, plot
    
                
######################################################################################
# Start definition of types                
Config["types"] = {}


               
######################################################################################
# CPU

CpuPlots = { "subplots": { "title": "CPU details", "plots": [ { "type": "CPU/overview" } ] } }

# CPU overview
command_def = "-t \"CPU usage\" --upper-limit 100 --lower-limit 0 --rigid " + defColors
command_line = ""
files = []
s = StackOrLines( csFullTr, isStack = True, t = "AREA" )
cpustates_fr = [ 0, ["interrupt", "softirq", "steal", "wait", "system"] ]
cpustates_end = [ len(cpustates_fr) + 100, ["user", "nice", "idle"] ]
cpustates_other = len(cpustates_fr) + 50
cpustates = []
for g in glob.glob( "cpu/*.rrd" ):
    m = re.search( "^cpu.*/.*-(.*).rrd", g ).group(1)
    for k in [ cpustates_fr, cpustates_end ] :
        if m in k[1]:
            cpustates.append( [ k[0] + k[1].index( m ), g ] )
    if m not in cpustates_fr[1] and m not in cpustates_end[1]:
        cpustates.append( [ cpustates_other, g ] )

cpustates.sort()

for gcpu in cpustates:
    g = gcpu[1]
    name = re.search( "^cpu.*/.*-(.*).rrd", g ).group(1)
    command_def += "DEF:" + name + "=" + g + ":value:AVERAGE "
    s.add( name, "$LINE_WIDTH_PRIMARY$", "\"" + name + '\\l"',
           "COMMENT:\\u GPRINT:"+name+":AVERAGE:\"Avr %2.0lf\" GPRINT:"+name+":MIN:\"Min %2.0lf\" GPRINT:"+name+":MAX:\"Max %2.0lf\" GPRINT:"+name+":LAST:\"Last %2.0lf\\r\" " )
    files.append(g)

command_line = s.str()

Config["types"]["CPU/overview"] = { "command": command_def + command_line,
                                 "files": files }

CpuPlots["type"] = "CPU/overview"

# Make CPU subplots
cpustates.reverse()
for gcpu in cpustates:
    g = gcpu[1]
    name = re.search( "^cpu.*/.*-(.*).rrd", g ).group(1)
    command_def = "-t \"CPU " + name + "\" --upper-limit 100 --lower-limit 0 --rigid " + defColors
    command_line = ""
    files = []
    s = StackOrLines(csSingle)
    command_def += "DEF:" + name + "=" + g + ":value:AVERAGE "
    command_def += "DEF:" + name + "_min=" + g + ":value:MIN "
    command_def += "DEF:" + name + "_max=" + g + ":value:MAX "
    command_def += "CDEF:" + name + "_max_min_delta=" + name + "_max," + name + "_min,- "
    command_def += "LINE:" + name + "_min AREA:" + name + "_max_min_delta$COLOR_LINE_SINGLE_SUB$::STACK "
    s.add( name, "$LINE_WIDTH_PRIMARY$", "\"" + name + '\\l"',
           "COMMENT:\\u GPRINT:"+name+":AVERAGE:\"Avr %1.0lf\" GPRINT:"+name+"_min:MIN:\"Min %1.0lf\" GPRINT:"+name+"_max:MAX:\"Max %1.0lf\" GPRINT:"+name+":LAST:\"Last %1.0lf\\r\" ")
    files.append(g)

    command_line = s.str()

    Config["types"]["CPU/" + name] = { "command": command_def + command_line,
                                       "files": files }
    CpuPlots["subplots"]["plots"].append( { "type": "CPU/" + name } )

# Add all CPU plots
Config["page"]["plots"].append( CpuPlots )


######################################################################################
# Battery 
    
BatteryPlots = { "subplots": { "title": "Battery details", "plots": [ ] } }

for g in glob.glob( "battery-0/*.rrd" ):
    name = re.search( "^battery.*/(.*).rrd", g ).group(1)
    gt, plot = maketypesplot( name, g, "Battery" )

    Config["types"]["Battery/" + name] = gt
    BatteryPlots["subplots"]["plots"].append( plot )

# Add all Battery plots
BatteryPlots["type"] = "Battery/voltage"
Config["page"]["plots"].append( BatteryPlots )


######################################################################################
# Storage

Plots = { "subplots": { "title": "Storage details", "plots": [ ] } }

for gd in glob.glob( "df-*" ):
    part_name = re.search( "^df-(.*)", gd ).group(1)

    command_def = '-t "Storage ' + part_name +  '" --lower-limit 0 ' + defColors
    command_line = ""
    files = []
    s = StackOrLines( cs3Col, isStack = True, t = "AREA" )

    allGs = []
    for g in glob.glob( gd + "/*.rrd" ): allGs.append(g)
    allGs.reverse() # to get free as a last
    
    for g in allGs:
        name = re.search( "^df-.*/df_complex-(.*).rrd", g ).group(1)
        command_def += "DEF:" + name + "=" + g + ":value:AVERAGE "
        s.add( name, "$LINE_WIDTH_PRIMARY$", "\"" + name + '\\l"',
               "COMMENT:\\u GPRINT:"+name+":AVERAGE:\"Avr %2.0lf%S\" GPRINT:"+name+":MIN:\"Min %2.0lf%S\" GPRINT:"+name+":MAX:\"Max %2.0lf%S\" GPRINT:"+name+":LAST:\"Last %2.0lf%S\\r\" " )
        files.append(g)
    
    command_line = s.str()

    Config["types"]["Storage/" + part_name] = { "command": command_def + command_line,
                                                "files": files }

    Plots["subplots"]["plots"].append( {"type": "Storage/" + part_name} )

Plots["type"] = "Storage/root"
Config["page"]["plots"].append( Plots )

######################################################################################
# Misc 
    
Plots = { "subplots": { "title": "Misc details", "plots": [ ] } }

g = "contextswitch/contextswitch.rrd"
name = "context_switch"
gt, plot = maketypesplot( name, g, "Context", "Context switch" )
Config["types"]["Context/" + name] = gt
Plots["subplots"]["plots"].append( plot )

g = "entropy/entropy.rrd"
name = "entropy"
gt, plot = maketypesplot( name, g, "Entropy", "Entropy" )
Config["types"]["Entropy/" + name] = gt
Plots["subplots"]["plots"].append( plot )

# uptime needs some math
g = "uptime/uptime.rrd"
name = "uptime"
f = getf(name)
u = getunit(name)
frm = f + u

command_def = '-t "Uptime, days" ' + defColors
command_line = ""
files = []
s = StackOrLines(csSingle)
command_def += "DEF:" + name + "_data=" + g + ":value:AVERAGE "
command_def += "CDEF:" + name + "=" + name + "_data,86400,/ "
s.add( name, "$LINE_WIDTH_PRIMARY$", "\"" + name + '\\l"',
       "COMMENT:\\u GPRINT:"+name+":LAST:\"Current " + frm + "\\r\" ")
files.append(g)

command_line = s.str()

gt = { "command": command_def + command_line,
       "files": files }
plot = { "type": "Uptime/" + name }

Config["types"]["Uptime/" + name] = gt
Plots["subplots"]["plots"].append( plot )

# Add all Misc plots
Plots["type"] = "Context/context_switch"
Config["page"]["plots"].append( Plots )



# Print resulting JSON configuration
print json.dumps(Config, indent=3)
