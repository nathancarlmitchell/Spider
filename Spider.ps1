[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$level1 = 0
$level2 = 0
$level3 = 0
$level4 = 0
$level5 = 0
# remove 'domain + link' by using
# $curl.BaseResponse.ResponseUri.AbsoluteUri
$url = 'chfs.ky.gov'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
# Description $curl.links.innerText
# try
$curl = Invoke-WebRequest $url
# catch, log error with http code
$links = $curl.Links.href
$domain = $curl.BaseResponse.ResponseUri.Host
# .txt vs .csv
$file = $domain+'.txt'
#Set-Content -Path $path$file -Value 'URL,Depth'
Clear-Content -Path $path$file

foreach ($link in $links) {
    # Level 1
    if ($link.StartsWith('/')) {
        $contentlink = $domain + $link
        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            $level1++
            $result = $domain + $link
            #$curl.BaseResponse.ResponseUri.AbsoluteUri
            $result
            # commas in URL break CSV
            Add-Content -Path $path$file -Value $result
            #',1' 
        }    
        #$curl.BaseResponse.ResponseUri.AbsoluteUri
        $url = $domain + $link
        $curl = Invoke-WebRequest $url
        #$curl.links.innerText
        $links = $curl.Links.href
        foreach ($link in $links) {
            # Level 2
            if ($link.StartsWith('/')) {
            $contentlink = $domain + $link
                if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                    $level2++
                    #$curl.BaseResponse.ResponseUri.AbsoluteUri
                    $result = $domain + $link
                    $result
                    Add-Content -Path $path$file -Value $result
                    #',2'
                    #$curl.BaseResponse.ResponseUri.AbsoluteUri
                    $url = $domain + $link
                    $curl = Invoke-WebRequest $url
                    #$curl.links.innerText
                    $links = $curl.Links.href
                    foreach ($link in $links) {
                        # Level 3
                        if ($link.StartsWith('/')) {
                            $contentlink = $domain + $link
                            if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                                $level3++
                                $result = $domain + $link
                                $result
                                Add-Content -Path $path$file -Value $result
                                #',3'
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
                                            Add-Content -Path $path$file -Value $result
                                            #',4'
                                            $url = $domain + $link
                                            $curl = Invoke-WebRequest $url
                                            $links = $curl.Links.href
                                            foreach ($link in $links) {
                                                # Level 5
                                                if ($link.StartsWith('/')) {
                                                    $contentlink = $domain + $link
                                                    if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                                                        $level5++
                                                        $result = $domain + $link
                                                        $result
                                                        Add-Content -Path $path$file -Value $result
                                                        #',5'
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
#ends with 'pdf'