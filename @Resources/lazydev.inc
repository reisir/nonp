[iFS]
measure=plugin
plugin=isfullscreen

[iFSR]
measure=string
string=[&iFS]
regexpsubstitute=1
substitute="^((?!Rainmeter.exe).)*$":"0","Rainmeter.exe":"1"
dynamicvariables=1

[iFSN]
measure=calc
formula=[&iFSR]
dynamicvariables=1

[config]
measure=plugin
plugin=getactivetitle
regexpsubstitute=1
substitute=".*Skins\\|\\[^\\]*$|Manage Rainmeter|About Rainmeter":"","":"\"
dynamicvariables=1
disabled=(#key# = 1 ? ([iFSN:] = 1 ? 0 : 1) : 1)
ifmatch=^\\$
ifmatchaction=[!SetVariable rootfound 0]
ifnotmatchaction=[!SetVariable rootfound 1]

[rootconfig]
measure=string
string=[&config]\
regexpsubstitute=1
substitute="(.*?)\\.*$":"\1","\\1":"#noroot#"
dynamicvariables=1

[noRMW]
measure=plugin
plugin=getactivetitle
regexpsubstitute=1
substitute="^((?!Manage Rainmeter|About Rainmeter).)*$":"key","Manage Rainmeter|About Rainmeter":"dum"

[activate]
measure=plugin
plugin=hotkey
hotkey=lctrl lalt
keydownaction=[!setvariable [&noRMW] 1][!update][!redraw]
keyupaction=[!setvariable [&noRMW] 0][!update][!redraw]
dynamicvariables=1




































