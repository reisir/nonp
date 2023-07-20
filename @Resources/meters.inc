[Variables]
w=415
h=90
key=0
trigger=243,139,168
normal=205,214,244
color=#normal#
noroot=Hold ctrl + alt to select a skin
rootfound=0

[container]
meter=shape
shape=rectangle 0,0,#w#,#h#,20 | strokeWidth 0

[bg]
meter=shape
shape=rectangle 0,0,#w#,#h# | strokeWidth 0 | fillColor 17,17,27
container=container

[style]
y=(#h# / 2)
padding=20,0,20,0
fontcolor=#normal#
antialias=1
dynamicvariables=1
text=[\xEB27]

[text]
meter=string
meterstyle=style
fontface=jetbrains mono regular
fontsize=13
stringalign=leftcenter
measurename=rootconfig
text=Targeted skin:#crlf#> %1
w=(#w#)
clipstring=2
container=container

[img]
meter=shape
shape=rectangle 0,0,#w#,(#h# * 3),20 | strokeWidth 0
Y=10R

[now]
Meter=Image
W=#w#
ImageName=#@#webnowplaying.png
Group=Stuff
DynamicVariables=1
Container=img




































