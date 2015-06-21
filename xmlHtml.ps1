Param( [string]$htmlFileName, [string]$imgSource, [string]$description)

# Read the HTML as XML because the brain damaged Invoke-WebRequest
# reads but refuses to parse HTML from a local file
[xml]$html = Get-Content $htmlFileName

# The first <div> inside body is a template, it isn't
# rendered and must be there when the program is first run
$type = $html.html.body.div.GetType().Name

# Check if div refers to a single element or array
if ( $type -eq "XmlElement" ) {
    $element = $html.html.body.div.clone()
} else {
    $element = $html.html.body.div[0].clone()
}

# This assignment handles & < > conversion to entities
# Otherwise, use [System.Security.SecurityElement]::Escape($description)
$element.div = $description
$element.img.src = $imgSource
$element.img.title = $imgSource

$html.html.body.AppendChild($element) | Out-Null

$html.Save("$pwd\$htmlFileName") | Out-Null
