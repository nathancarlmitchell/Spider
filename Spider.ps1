[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$domain = 'aba.ky.gov'
$url = 'http://aba.ky.gov/Pages/default.aspx'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
$file = $domain+'.txt'
$level1 = 0
$level2 = 0
$level3 = 0
$level4 = 0
$level5 = 0

# Description $curl.links.innerText

Set-Content -Path $path$file -Value 'URL,Depth'

$curl = Invoke-WebRequest $url
$links = $curl.Links.href

foreach ($link in $links) {
    # Level 1
    if ($link.StartsWith('/')) {
        $contentlink = $domain + $link
        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            $level1++
            $result = $domain + $link
            $result
            Add-Content -Path $path$file -Value $result',1' 
        }    
        $url = $domain + $link
        $curl = Invoke-WebRequest $url
        $links = $curl.Links.href
        foreach ($link in $links) {
            # Level 2
            if ($link.StartsWith('/')) {
            $contentlink = $domain + $link
                if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                    $level2++
                    $result = $domain + $link
                    $result
                    Add-Content -Path $path$file -Value $result',2'
                    $url = $domain + $link
                    $curl = Invoke-WebRequest $url
                    $links = $curl.Links.href
                    foreach ($link in $links) {
                        # Level 3
                        if ($link.StartsWith('/')) {
                            $contentlink = $domain + $link
                            if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                                $level3++
                                $result = $domain + $link
                                $result
                                Add-Content -Path $path$file -Value $result',3'
                                $url = $domain + $link
                                $curl = Invoke-WebRequest $url
                                $links = $curl.Links.href
                                foreach ($link in $links) {
                                    # Level 4
                                    if ($link.StartsWith('/')) {
                                        $contentlink = $domain + $link
                                        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                                            $level4++
                                            $result = $domain + $link
                                            $result
                                            Add-Content -Path $path$file -Value $result',4'
                                            $url = $domain + $link
                                            $curl = Invoke-WebRequest $url
                                            $links = $curl.Links.href
                                            foreach ($link in $links) {
                                                # Level 5
                                                if ($link.StartsWith('/')) {
                                                    $contentlink = $domain + $link
                                                    if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                                                        $level4++
                                                        $result = $domain + $link
                                                        $result
                                                        Add-Content -Path $path$file -Value $result',5'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

'Level 1: '+$level1
'Level 2: '+$level2
'Level 3: '+$level3
'Level 4: '+$level4
'Level 5: '+$level5

#catch exceptions
#check for unique values
#ends with 'pdf'