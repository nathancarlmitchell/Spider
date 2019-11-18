[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$domain = 'technology.ky.gov'
$url = 'https://technology.ky.gov/Pages/default.aspx'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
$file = $domain+'.txt'

Set-Content -Path $path$file -Value $url

$curl = Invoke-WebRequest $url
$links = $curl.Links.href

foreach ($link in $links) {

    $contentlink = $domain + $link

    if ($link.StartsWith('/')) {

        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            $result = $domain + $link
            $result
            Add-Content -Path $path$file -Value $result
        }

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
            } else { 'Duplicate' }
        }
    }
}
#catch exceptions
#check for unique values
#ends with 'pdf'