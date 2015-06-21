Param( [int]$pageStart, [int]$pageEnd )

# If PowerShell scripts haven't been run before on this box
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Usage:
#   Edit the URL below to a valid tumbler, this is
#   coded for a specific template, the site you want is
#   probably different, you'll have to view it's source
#   and adapt the code

#   As the download progresses, it will update the
#   index.html file.  To start over, copy indexTemplate.html
#   to index.html

#   Execute .\tumbler.ps1 -pageStart 1 -PageEnd 10
#   substituting the page numbers you wish.  If the image
#   is already in the current folder, it will be skipped


for( $i = $pageStart; $i -le $pageEnd; $i++ ){

    # Set this to the URL you wish
    $url = "http://your_site_here.tumblr.com/page/$i"

    Write-Output "Getting Page $url"

    $resp = Invoke-WebRequest -Uri $url

    $pictures = $resp.ParsedHtml.body.getElementsByTagName('div') |
        where {$_.getAttributeNode('class').Value -eq 'right'}

    foreach( $element in $pictures ){

        $images = $element.getElementsByTagName('img')

        foreach( $image in $images ){
            $src = $image.getAttributeNode('src').Value

            # extract the image file name
            $filename = $src.Substring($src.LastIndexOf("/")+1)
            $filename = $filename -Replace "%2B"," "

            if ( Test-Path $filename ){
                Write-Output "Skipping $filename"
                continue;
            }

            # extract and format the notes
            $notes = $element.getElementsByTagName('p')

            $noteText = ""
            foreach( $note in $notes ){
                if( $note.innerText -ne $null ){
                    $noteText += $note.innerText.Trim()
                }
            }

            $cleanNote = $noteText -Replace "&nbsp", " "
            $cleanNote = $cleanNote -Replace "’","'"
            $cleanNote = $cleanNote -Replace "…","..."
            $cleanNote = $cleanNote -Replace "[^\w'\.]", " "
            $cleanNote = $cleanNote -Replace "EM", ""
            $cleanNote = $cleanNote -Replace "STRONG", ""
            $cleanNote = $cleanNote -Replace '\s+',' '


            Write-Output $filename
            Write-Output $cleanNote

            # Retrieve and store the image
            Invoke-WebRequest $src -OutFile $filename

            # Add the image to the html index page w/notes
            .\xmlHtml.ps1 -htmlFileName index.html -imgSource $filename -description $cleanNote

        }
    }
}
