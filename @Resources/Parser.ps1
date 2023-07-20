function Parse-Ini {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path,
        [Parameter()]
        [string]
        $Content
    )

    if (!$Path -and !$Content) { throw "-Path or -Content is required" }
    if ($Path -and $Content) { throw "Do not supply both -Path and -Content" }
    
    if ($Path) { $Content = Get-Content -Path $Path -Raw }

    $section = '\n\s*?(?=\[\S+?\])'
    $sections = $Content -split $section

    return $sections
}