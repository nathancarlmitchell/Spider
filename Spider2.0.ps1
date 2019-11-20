[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://chfs.ky.gov/Pages/sitemap.aspx'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
$curl = Invoke-WebRequest $url -UseBasicParsing
$domain = $curl.BaseResponse.ResponseUri.Host
$file = $domain+'.txt'
$docfile = $domain+'.docs.txt'

$StartDate = Get-Date

if(![System.IO.File]::Exists($path+$file)) {
    New-Item -Path $path -Name $file
}
if(![System.IO.File]::Exists($path+$docfile)) {
    New-Item -Path $path -Name $docfile
}

Clear-Content -Path $path$file
Clear-Content -Path $path$docfile
function replaceHTTP {
    param (
        $link
    )
    if ($link.Contains("https://")) {
        $link = $link -replace "https://"
    } elseif ($link.Contains("http://")) {
        $link = $link -replace "http://"
    } elseif ($link.Contains("http&#58;//")) {
        $link = $link -replace "http&#58;//"
    } elseif ($link.Contains("https&#58;//")) {
        $link = $link -replace "https&#58;//"
    }
    return $link
}

$link = $curl.BaseResponse.ResponseUri.AbsoluteUri
$link = replaceHTTP -link $link
Add-Content -Path $path$file -Value $link



$links = $curl.Links.href
$links = $links | Get-Unique



foreach ($link in $links) {
    if ($link.StartsWith('/') -or $link.Contains($domain)) {
        if ($link.StartsWith('/')) {
            $contentlink = $domain + $link           
        } elseif ($link.Contains($domain)) {
            if ($link.Contains("https://")) {
                $contentlink = $link -replace "https://"
            } elseif ($link.Contains("http://")) {
                $contentlink = $link -replace "http://"
            } elseif ($link.Contains("http&#58;//")) {
                $contentlink = $link -replace "http&#58;//"
            } elseif ($link.Contains("https&#58;//")) {
                $contentlink = $link -replace "https&#58;//"
            }
        }
        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            Add-Content -Path $path$file -Value $contentlink
            $contentlink
        }
    }
}

# while unique = true
Pause
$links = Get-Content $path$file
$links = $links | Get-Unique

foreach ($link in $links) {
    $curl = Invoke-WebRequest $link -UseBasicParsing
    $results = $curl.Links.href
    foreach ($result in $results) {
        if ($result.StartsWith('/') -or $result.Contains($domain)) {
            if ($result.StartsWith('/')) {
                $contentlink = $domain + $result           
            } elseif ($result.Contains($domain)) {
                if ($result.Contains("https://")) {
                    $contentlink = $result -replace "https://"
                } elseif ($result.Contains("http://")) {
                    $contentlink = $result -replace "http://"
                } elseif ($result.Contains("http&#58;//")) {
                    $contentlink = $result -replace "http&#58;//"
                } elseif ($result.Contains("https&#58;//")) {
                    $contentlink = $result -replace "https&#58;//"
                }
            } if ($contentlink.EndsWith('.pdf') -or $contentlink.EndsWith('.xls') -or $contentlink.EndsWith('.xlsx') -or $contentlink.EndsWith('.doc') -or $contentlink.EndsWith('.docx') -or $contentlink.EndsWith('.mp4') -or $contentlink.EndsWith('.ppt') -or $contentlink.EndsWith('.pptx')) {
                if (!( Get-Content $path$docfile | Where-Object { $_.Contains($contentlink) } )) {
                    Add-Content -Path $path$docfile -Value $contentlink
                    'Not a website: '+$contentlink
                } else {
                    'Duplicate: '+$contentlink
                }
            } elseif (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                Add-Content -Path $path$file -Value $contentlink
                $contentlink
            } else {
                'Duplicate: '+$contentlink
            }
        }
    }
}

$EndDate = Get-Date
$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
$TimeSpan