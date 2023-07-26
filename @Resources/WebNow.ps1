. '.\@Resources\Parser.ps1'

$webnowplaying = "`nMeasure=Plugin`nPlugin=WebNowPlaying`n`n"

function Plugin {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]
        $Plugin
    )

    return @(
        ('\n\s*?measure\s*?=\s*?' + $Plugin + '\s*?(?=\n|$)'),
        ('\n\s*?plugin\s*?=\s*?' + $Plugin + '\.dll\s*?(?=\n|$)'),
        ('\n\s*?plugin\s*?=\s*?plugins\\' + $Plugin + '\.dll\s*?(?=\n|$)'),
        ('\n\s*?plugin\s*?=\s*?' + $Plugin + '\s*?(?=\n|$)')
    )

}

function Contains-Patterns {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]
        $Section,
        [Parameter(Position = 1, Mandatory)]
        [array]
        $Patterns
    )

    # Write-Host $Section

    foreach ($pattern in $Patterns) {
        # Write-Host $pattern
        # Write-Host ($Section -match $pattern)
        if ($Section -match $pattern) {
            return $True
        }
    }

    return $False
}

function Remove-Option {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Position = 0, Mandatory)]
        [string]
        $Section,
        [Parameter(Position = 1, Mandatory)]
        [string]
        $Option
    )
    $pattern = '\n\s*?' + $Option + '\s*?=.*?(?=\n|$)'
    return $Section -replace $pattern, ''
}

function PlayerTypes {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [string]
        $Content
    )

    $options = @{
        trackname  = 'Title'
        albumname  = 'Album'
        artistname = 'Artist'
        trackuri   = 'Status'
        albumuri   = 'Status'
        artisturi  = 'Status'
        genre      = 'Status'
        albumart   = 'Cover'
        volume     = 'Volume'
        repeat     = 'Repeat'
        shuffle    = 'Shuffle'
        position   = 'Position'
        playing    = 'Status'
        length     = 'Duration'
        progress   = 'Progress'
    }

    $Content = $Content -replace '\n\s*?type\s*?=\s*?progress\s*?(?=\n|$)', 'PlayerType=Progress'

    foreach ($option in $options.Keys) {
        $pattern = '\n\s*?type\s*?=\s*?' + $option + '\s*?(?=\n|$)'
        $value = 'PlayerType=' + $options[$option]
        $Content = $Content -replace $pattern, $value
    }

    return $Content
}

function Get-Path {

    $skins = $RmApi.VariableStr("SKINSPATH")
    $root = $RmApi.MeasureStr("rootconfig")
    return "$skins$root"

}

function ScanFiles {
    $Path = Get-Path
    Get-ChildItem -Path "$($Path)\*" -Recurse -Include "*.inc", "*.ini" | % {
        $file = "$($_)"

        $content = Get-Content $file -Raw
        $sections = Parse-Ini -Content $content

        $np = Plugin "nowplaying"
        $sp = Plugin "spotifyplugin"

        foreach ($section in $sections) {
            if ((Contains-Patterns $section -Patterns $np) -or (Contains-Patterns $section -Patterns $sp) ) {
                return $True
            }
        }
    }
    return $False
}

function Scan {

    if (!(ScanFiles)) { 
        $RmApi.Bang("[PlayStop]")
        $RmApi.Bang("[!SetVariable detected 0][!UpdateMeter now][!Redraw]")
        return
    }

    $RmApi.Bang("[Play $($RmApi.ReplaceVariablesStr("#@#wnp.wav"))][!SetVariable detected 1][!UpdateMeter now][!Redraw]")

    if ($RmApi.Measure("MeasureStatus") -eq 1) { 
        $RmApi.Bang("[!CommandMeasure MediaKey PlayPause][!SetVariable WasPlaying 1]")
    }

}

function Update {
    $Path = Get-Path
    return $Path
}

function ConvertTo-WebNowPlaying {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path
    )

    if (!$Path) { $Path = Get-Path }
    if ($Path -notlike "$($RmApi.VariableStr("SKINSPATH"))*") { throw "Illegal path." }

    $RmApi.Bang("[PlayStop]")

    Write-Host $Path

    Get-ChildItem -Path "$($Path)\*" -Recurse -Include "*.inc", "*.ini" | % {

        $file = "$($_)"

        Write-Host $file

        $content = Get-Content $file -Raw
        $sections = Parse-Ini -Content $content
        $newContent = ""

        $pluginPatterns = Plugin "nowplaying"
        $pluginPattenrs += Plugin "spotifyplugin"
        $pluginPattenrs += Plugin "mediaplayer"

        $replaceFile = $False

        foreach ($section in $sections) {
            if (Contains-Patterns $section -Patterns $pluginPatterns) {
                $replaceFile = $True
                $section = Remove-Option $section "measure"
                $section = Remove-Option $section "plugin"
                # $section = Remove-Option $section "coverpath"
                $section = PlayerTypes $section
                $section += $webnowplaying
            }
            $newContent += "$($section)`n`n"
        }

        if ($replaceFile) { Set-Content -Path $file -Value $newContent -Force }
    }

    if (($RmApi.Variable("WasPlaying") -eq 1) -and ($RmApi.Measure("MeasureStatus") -ne 1)) { 
        $RmApi.Bang("[!CommandMeasure MediaKey PlayPause]")
    }
    $RmApi.Bang("[!RefreshApp]")
}
