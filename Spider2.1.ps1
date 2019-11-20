[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'https://abc.ky.gov/Pages/index.aspx'
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
$curl = Invoke-WebRequest $url -UseBasicParsing
$domain = $curl.BaseResponse.ResponseUri.Host
$file = $domain+'.txt'
$docfile = $domain+'.docs.txt'
$duplicatecount = 0
$webcount = 0
$filecount = 0
$totalcount = 0
$unique = $true

$StartDate = Get-Date

if(![System.IO.File]::Exists($path+$file)) {
    New-Item -Path $path -Name $file
}
if(![System.IO.File]::Exists($path+$docfile)) {
    New-Item -Path $path -Name $docfile
}
if(![System.IO.File]::Exists($path+$docfile)) {
    New-Item -Path $path -Name $doc'tmp.txt'
}

Clear-Content -Path $path$file
Clear-Content -Path $path$docfile
Clear-Content -Path $path'tmp.txt'
function removeHTTP {
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

$link = removeHTTP -link $curl.BaseResponse.ResponseUri.AbsoluteUri
Add-Content -Path $path$file -Value $link
$webcount++

$links = $curl.Links.href
$links = $links | Get-Unique

foreach ($link in $links) {
    if ($link.StartsWith('/') -or $link.Contains($domain)) {
        if ($link.StartsWith('/')) {
            $contentlink = $domain + $link           
        } elseif ($link.Contains($domain)) {
            $contentlink = removeHTTP -link $link
        }
        if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            Add-Content -Path $path$file -Value $contentlink
            Add-Content -Path $path'tmp.txt' -Value $contentlink
            $contentlink
            $webcount++
        }
    }
}

while ($unique) {
    if ($null -eq (Get-Content -Path $path'tmp.txt')) {
        $unique = $false
    }
    # while unique = true
    $links = Get-Content $path'tmp.txt'
    $links = $links | Get-Unique

    Clear-Content -Path $path'tmp.txt'

    foreach ($link in $links) {
        $curl = Invoke-WebRequest $link -UseBasicParsing
        $results = $curl.Links.href
        foreach ($result in $results) {
            if ($result.StartsWith('/') -or $result.Contains($domain)) {
                if ($result.StartsWith('/')) {
                    $contentlink = $domain + $result           
                } elseif ($result.Contains($domain)) {
                    $contentlink = removeHTTP -link $result
                }
                if ($contentlink.EndsWith('.pdf') -or $contentlink.EndsWith('.xls') -or $contentlink.EndsWith('.xlsx') -or $contentlink.EndsWith('.doc') -or $contentlink.EndsWith('.docx') -or $contentlink.EndsWith('.mp4') -or $contentlink.EndsWith('.ppt') -or $contentlink.EndsWith('.pptx')) {
                    if (!( Get-Content $path$docfile | Where-Object { $_.Contains($contentlink) } )) {
                        Add-Content -Path $path$docfile -Value $contentlink
                        'Not a website: '+$contentlink
                        $filecount++
                    } else {
                        'Duplicate: '+$contentlink
                        $duplicatecount++
                    }
                } elseif (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                    Add-Content -Path $path$file -Value $contentlink
                    Add-Content -Path $path'tmp.txt' -Value $contentlink
                    $contentlink
                    $webcount++
                } else {
                    'Duplicate: '+$contentlink
                    $duplicatecount++
                }
            }
        }
    }
}

$totalcount = $webcount + $filecount
'Duplicates: '+$duplicatecount
'Web links: '+$webcount
'Document links: '+$filecount
'Total links: '+$totalcount

$EndDate = Get-Date
$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
$TimeSpan

$report = Get-Content -Path $path$file
$report += Get-Content -Path $path$docfile
$report = $report | Sort-Object
Add-Content -Path $path'report.txt' -Value $report