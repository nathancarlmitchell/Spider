[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$domain = 'ag.ky.gov'
$url = 'https://ag.ky.gov/'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
$file = $domain+'.txt'
$level1 = 0
$level2 = 0
$level3 = 0
$level4 = 0

Set-Content -Path $path$file -Value $url

$curl = Invoke-WebRequest $url
$links = $curl.Links.href

foreach ($link in $links) {
    # Level 1
    
    $contentlink = $domain + $link

    if ($link.StartsWith('/')) {
        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            $level1++
            $result = $domain + $link
            $result
            Add-Content -Path $path$file -Value $result    
        }
        
        $url = $domain + $link
        $curl = Invoke-WebRequest $url
        $links = $curl.Links.href

        foreach ($link in $links) {
            # Level 2
            $contentlink = $domain + $link

            if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {

                if ($link.StartsWith('/')) {
                    $level2++
                    $result = $domain + $link
                    $result
                    Add-Content -Path $path$file -Value $result
                    $url = $domain + $link
                    $curl = Invoke-WebRequest $url
                    $links = $curl.Links.href

                    foreach ($link in $links) {
                        # Level 3
                        $contentlink = $domain + $link

                        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {

                            if ($link.StartsWith('/')) {
                                $level3++
                                $result = $domain + $link
                                $result
                                Add-Content -Path $path$file -Value $result
                                $url = $domain + $link
                                $curl = Invoke-WebRequest $url
                                $links = $curl.Links.href

                                foreach ($link in $links) {
                                    # Level 4
                                    $contentlink = $domain + $link

                                    if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                                        if ($link.StartsWith('/')) {
                                            $level4++
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

'Level 1: '+$level1
'Level 2: '+$level2
'Level 3: '+$level3
'Level 4: '+$level4

#catch exceptions
#check for unique values
#ends with 'pdf'