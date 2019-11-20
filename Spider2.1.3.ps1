# Nathan Carl Mitchell
# nathancarlmitchell@gmail.com
# https://github.com/nathancarlmitchell/Spider
# Verion 2.1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = 'mcalleninc.com'
$url = $args[0]
$curl = Invoke-WebRequest $url -UseBasicParsing
$domain = $curl.BaseResponse.ResponseUri.Host
$path =  'C:\Users\nathan.mitchell\Documents\Spider\'+$domain+'\'
$file = $domain+'.txt'
$docfile = $domain+'.docs.txt'
$errorfile = $domain+'.errors.txt'
$reportfile = $domain+'.report.csv'
$tempfile = $domain+'.temp.txt'
$outofscope = 0
$duplicatecount = 0
$webcount = 0
$filecount = 0
$totalcount = 0
$errors = 0
$unique = $true
$StartDate = Get-Date

if(![System.IO.File]::Exists($path)) {
    New-Item -ItemType Directory -Force -Path $path
}
if(![System.IO.File]::Exists($path+$file)) {
    New-Item -Path $path -Name $file
}
if(![System.IO.File]::Exists($path+$docfile)) {
    New-Item -Path $path -Name $docfile
}
if(![System.IO.File]::Exists($path+$reportfile)) {
    New-Item -Path $path -Name $reportfile
}
if(![System.IO.File]::Exists($path+$tempfile)) {
    New-Item -Path $path -Name $tempfile
}
if(![System.IO.File]::Exists($path+$errorfile)) {
    New-Item -Path $path -Name $errorfile
}

Clear-Content -Path $path$file
Clear-Content -Path $path$docfile
Clear-Content -Path $path$reportfile
Clear-Content -Path $path$tempfile
Clear-Content -Path $path$errorfile

function removeHTTP {
    param (
        $link
    )

    if ($link.Contains('https://')) {
        $link = $link -replace 'https://'
    } elseif ($link.Contains('http://')) {
        $link = $link -replace 'http://'
    } elseif ($link.Contains('http&#58;//')) {
        $link = $link -replace 'http&#58;//'
    } elseif ($link.Contains('https&#58;//')) {
        $link = $link -replace 'https&#58;//'
    }
    return $link
}

function documentCheck {
    param (
        $link
    )

    if ($contentlink.EndsWith('.pdf') -or $contentlink.EndsWith('.xls') -or $contentlink.EndsWith('.xlsx') -or $contentlink.EndsWith('.doc') -or $contentlink.EndsWith('.docx') -or $contentlink.EndsWith('.mp4') -or $contentlink.EndsWith('.ppt') -or $contentlink.EndsWith('.pptx')) {
        $document = $true
    } else {
        $document = $false
    }
    return $document
}

function formatUrl {
    param (
        $contentlink
    )

    $contentlink = $contentlink -replace ',','%2C'
    return $contentlink
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
        if (documentCheck -link $contentlink) {
            if (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                $contentlink = formatUrl -contentlink $contentlink
                Add-Content -Path $path$docfile -Value $contentlink
                $contentlink
                $filecount++
            }
        } elseif (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
            $contentlink = formatUrl -contentlink $contentlink
            Add-Content -Path $path$file -Value $contentlink
            Add-Content -Path $path$tempfile -Value $contentlink
            $contentlink
            $webcount++
        }
    } else {
        'Out of scope: '+$link
        $outofscope++
    }
}

while ($unique) {
    if ($null -eq (Get-Content -Path $path$tempfile)) {
        $unique = $false
    }

    $links = Get-Content $path$tempfile
    $links = $links | Get-Unique

    Clear-Content -Path $path$tempfile

    foreach ($link in $links) {
        try {
            $curl = Invoke-WebRequest $link -UseBasicParsing
        } catch {
            $errormessage = $_.TargetObject.Address.AbsoluteUri + ',' + $_.ErrorDetails
            Add-Content -Path $path$errorfile -Value $errormessage
            $errors++
        }
        $results = $curl.Links.href
        foreach ($result in $results) {
            if ($result.StartsWith('/') -or $result.Contains($domain)) {
                if ($result.StartsWith('/')) {
                    $contentlink = $domain + $result           
                } elseif ($result.Contains($domain)) {
                    $contentlink = removeHTTP -link $result
                }
                if (documentCheck -link $contentlink) {
                    if (!( Get-Content $path$docfile | Where-Object { $_.Contains($contentlink) } )) {
                        $contentlink = formatUrl -contentlink $contentlink
                        Add-Content -Path $path$docfile -Value $contentlink
                        'Not a website: '+$contentlink
                        $filecount++
                    } else {
                        'Duplicate: '+$contentlink
                        $duplicatecount++
                    }
                } elseif (!( Get-Content $path$file | Where-Object { $_.Contains($contentlink) } )) {
                    Add-Content -Path $path$tempfile -Value $contentlink
                    $contentlink = formatUrl -contentlink $contentlink
                    Add-Content -Path $path$file -Value $contentlink
                    $contentlink
                    $webcount++
                } else {
                    'Duplicate: '+$contentlink
                    $duplicatecount++
                }
            } else {
                'Out of scope: '+$result
                $outofscope++
            }
        }
    }
}

Remove-Item -Path $path$tempfile
if ($null -eq (Get-Content -Path $path$errorfile)) {
    Remove-Item -Path $path$errorfile
}

$totalcount = $webcount + $filecount
''
'Duplicates: '+$duplicatecount
'Web links: '+$webcount
'Document links: '+$filecount
'Total links: '+$totalcount
'Out of scope links: '+$outofscope
'Errors: '+$errors

$EndDate = Get-Date
$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
$TimeSpan

$report = Get-Content -Path $path$file
$report += Get-Content -Path $path$docfile
$report = $report | Sort-Object
Add-Content -Path $path$reportfile -Value $report