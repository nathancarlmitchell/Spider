[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$domain = 'chfs.ky.gov'
$url = 'https://chfs.ky.gov/Pages/sitemap.aspx'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
$file = 'spider.txt'

$curl = Invoke-WebRequest $url
$links = $curl.Links.href

Set-Content -Path $path$file -Value 'CHFS Spider'

foreach ($link in $links) {

    $contentlink = $domain + $link

    if ($link.StartsWith('/')) {
        #check duplicates here
        $result = $domain + $link
        $result
        Add-Content -Path $path$file -Value $result

        $url = $domain + $link
        $curl = Invoke-WebRequest $url
        $links = $curl.Links.href

        foreach ($link in $links) {

            $contentlink = $domain + $link

            if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {

                if ($link.StartsWith('/')) {
                    $result = $domain + $link
                    $result
                    Add-Content -Path $path$file -Value $result

                    $url = $domain + $link
                    $curl = Invoke-WebRequest $url
                    $links = $curl.Links.href

                    foreach ($link in $links) {
                        
                        $contentlink = $domain + $link

                        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {

                            if ($link.StartsWith('/')) {
                                $result = $domain + $link
                                $result
                                Add-Content -Path $path$file -Value $result
                            }
                        } else { 'Duplicate' }
                    }
                }
            } else { 'Duplicate' }
        }
    }
}

#check for unique values
#ends with 'pdf'