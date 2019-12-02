# Nathan Carl Mitchell
# nathancarlmitchell@gmail.com
# https://github.com/nathancarlmitchell/Spider
# Verion 2.7.2
# PowerShell Version 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($args[0]) {
	$url = $args[0]
} else {
	$url = Read-Host 'Search Domain [chfs.ky.gov]'
	if (!$url) {
		$url = 'chfs.ky.gov'
	}
}

if ($args[1]) {
	if (($args[1]).ToLower().Contains('y')) {
		$progress = $true
	} elseif (($args[1]).ToLower().Contains('n')) {
		$progress = $false
	}
} else {
	$p = Read-Host 'Display Detailed Progress? (Slower performance) y/[n]'
	if (!$p) {
		$progress = $false
	} else {
		if (($p).ToLower().Contains('y')) {
			$progress = $true
		} elseif (($p).ToLower().Contains('n')) {
			$progress = $false
		}
	}
}

if ($args[2]) {
	$maxDepth = $args[2]
} else {
	$maxDepth = Read-Host 'Max Depth? (1 - 99) [10]'
	if (!$maxDepth) {
		$maxDepth = 10
	}
}

if ($args[3]) {
	$requestTimeout = $args[3]
} else {
	$requestTimeout = Read-Host 'Request Timeout? (Seconds 1 - 99) [10]'
	if (!$requestTimeout) {
		$requestTimeout = 10
	}
}

if ($args[4]) {
	if (($args[4]).ToLower().Contains('y')) {
		$requestLinkInfo = $true
	} elseif (($args[4]).ToLower().Contains('n')) {
		$requestLinkInfo = $false
	}
} else {
	$p = Read-Host 'Request Link Information? (Slower performance) [y]/n'
	if (!$p) {
		$requestLinkInfo = $true
	} else {
		if (($p).ToLower().Contains('y')) {
			$requestLinkInfo = $true
		} elseif (($p).ToLower().Contains('n')) {
			$requestLinkInfo = $false
		}
	}
}

if ($args[5]) {
	if (($args[5]).ToLower().Contains('y')) {
		$requestDocInfo = $true
	} elseif (($args[4]).ToLower().Contains('n')) {
		$requestDocInfo = $false
	}
} else {
	$p = Read-Host 'Request Document Information? (Slower performance) [y]/n'
	if (!$p) {
		$requestDocInfo = $true
	} else {
		if (($p).ToLower().Contains('y')) {
			$requestDocInfo = $true
		} elseif (($p).ToLower().Contains('n')) {
			$requestDocInfo = $false
		}
	}
}

if ($args[6]) {
	if (($args[6]).ToLower().Contains('y')) {
		$logOutOfScope = $true
	} elseif (($args[4]).ToLower().Contains('n')) {
		$logOutOfScope = $false
	}
} else {
	$p = Read-Host 'Log out-of-scope links? (Slower performance) [y]/n'
	if (!$p) {
		$logOutOfScope = $true
	} else {
		if (($p).ToLower().Contains('y')) {
			$logOutOfScope = $true
		} elseif (($p).ToLower().Contains('n')) {
			$logOutOfScope = $false
		}
	}
}

#$path =  'C:\Users\nathan.mitchell\Documents\Spider\'
#$urls = Get-Content $path'http.txt'

#foreach ($url in $urls) {
$request = Invoke-WebRequest $url -TimeoutSec $requestTimeout -UseBasicParsing
$domain = $request.BaseResponse.ResponseUri.Host
$path = 'C:\Users\nathan.mitchell\Documents\Spider\' + $domain + '\'
$linkfile = $domain + '.links.csv'
$docfile = $domain + '.docs.csv'
$scopefile = $domain + '.out-of-scope.csv'
$reportfile = $domain + '.report.csv'
$tempfile = $domain + '.temp.txt'
$errorfile = $domain + '.errors.csv'
$logfile = $domain + '.log.txt'
$outofscope = 0
$duplicatecount = 0
$webcount = 0
$filecount = 0
$totalcount = 0
$errors = 0
$depth = 1
$unique = $true
$StartDate = Get-Date

if (![System.IO.File]::Exists($path)) {
	New-Item -ItemType Directory -Force -Path $path
}
if (![System.IO.File]::Exists($path + $linkfile)) {
	New-Item -Path $path -Name $linkfile
}
if (![System.IO.File]::Exists($path + $docfile)) {
	New-Item -Path $path -Name $docfile
}
if (![System.IO.File]::Exists($path + $scopefile)) {
	New-Item -Path $path -Name $scopefile
}
if (![System.IO.File]::Exists($path + $reportfile)) {
	New-Item -Path $path -Name $reportfile
}
if (![System.IO.File]::Exists($path + $tempfile)) {
	New-Item -Path $path -Name $tempfile
}
if (![System.IO.File]::Exists($path + $errorfile)) {
	New-Item -Path $path -Name $errorfile
}
if (![System.IO.File]::Exists($path + $logfile)) {
	New-Item -Path $path -Name $logfile
}

Clear-Content -Path $path$linkfile
Clear-Content -Path $path$docfile
Clear-Content -Path $path$scopefile
Clear-Content -Path $path$reportfile
Clear-Content -Path $path$tempfile
Clear-Content -Path $path$errorfile
Clear-Content -Path $path$logfile

Add-Content -Path $path$errorfile -Value 'URL,Error'

function removeHTTP {
	param(
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
	$link = $link -replace 'www.'
	return $link
}

function documentCheck {
	$doclink = ($contentlink.Split('.')[-1]).ToLower()
	$doctypes = 'pdf','xls','xlsx','xlsm','xlt','xltm','doc','docm','docx','dot','dotx','ppt','pptm','pptx','ppsx',`
 		'zip','csv','kmz','shp','cat','dat','dgn','alg','rtf','pub',`
 		'mp3','mp4','avi','mov','wav','wmv','jpg','png','gif','tif'
	if ($doctypes.Contains($doclink)) {
		$document = $true
	} else {
		$document = $false
	}
	return $document
}

function documentType {
	param(
		$doclink
	)

	$doctype = ($doclink.Split('.')[-1]).ToLower()
	return $doctype
}

function formatUrl {
	param(
		$contentlink
	)

	$contentlink = $contentlink -replace ',','%2C'
	$contentlink = $contentlink -replace ' ','%20'
	if ($contentlink.EndsWith('#')) {
		$contentlink = $contentlink -replace '#'
	}
	return $contentlink
}

function formatReadable {
	param(
		$contentlink
	)

	$contentlink = $contentlink.Split('/')[-1]
	#$contentlink = $contentlink.Split('.')[0]
	$contentlink = $contentlink -replace '%2C',' '
	$contentlink = $contentlink -replace '%20',' '
	$contentlink = $contentlink -replace '%27',"'"
	$contentlink = $contentlink -replace '%28',"("
	$contentlink = $contentlink -replace '%29',")"
	return $contentlink
}

function removeComma {
	param(
		$lm
	)

	$lm = $lm -replace ',','.'
	return $lm
}

function DisplayInBytes () {
	param(
		$num
	)

	$suffix = "B","KB","MB","GB","TB","PB","EB","ZB","YB"
	$index = 0
	while ($num -gt 1kb)
	{
		$num = $num / 1kb
		$index++
	}

	"{0:F1} {1}" -f $num,$suffix[$index]
}

$link = removeHTTP -link $request.BaseResponse.ResponseUri.AbsoluteUri
Add-Content -Path $path$linkfile -Value $link
$webcount++

#$scope = '.' + $domain.split('.')[1] + '.' + $domain.split('.')[2]
$links = $request.Links.href
$links = $links | Sort-Object | Get-Unique
$linksCount = $links.Count
$linkCount = 0
foreach ($link in $links) {
	$linkCount++
	$linkProgress = ($linkCount / $linksCount) * 100
	$linkProgress = "{0:n2}" -f $linkProgress
	Write-Progress -Activity "Search in Progress: $domain" -Status "Complete: $linkProgress% Depth: $depth" -PercentComplete $linkProgress
	if ($link) {
		$link = formatUrl -contentlink $link
		#or $link.Contains($scope)
		if ($link.StartsWith('/') -or $link.Contains($domain)) {
			if ($link.StartsWith('/')) {
				$contentlink = $domain + $link
			} elseif ($link.Contains($domain)) {
				$contentlink = removeHTTP -link $link
			}
			if (documentCheck) {
				if (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($contentlink).ToLower()) })) {
					$content = $contentlink + ',' + $url
					Add-Content -Path $path$docfile -Value $content
					'New Document: ' + $contentlink
					$filecount++
				}
			} elseif (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($contentlink).ToLower()) })) {
				$content = $contentlink + ',' + $url
				Add-Content -Path $path$linkfile -Value $content
				#if ($contentlink.Contains($domain))
				Add-Content -Path $path$tempfile -Value $contentlink
				'New Link: ' + $contentlink
				$webcount++
			}
		} else {
			if ($logOutOfScope) {
				$link = removeHTTP -link $link
				if (!(Get-Content $path$scopefile | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
					$content = $link + ',' + $url
					Add-Content -Path $path$scopefile -Value $content
					$outofscope++
					'Out of scope: ' + $link
				}
			}
		}
	}
}

while ($unique) {
	if ($null -eq (Get-Content -Path $path$tempfile)) {
		$unique = $false
	}
	if ($depth -lt $maxDepth) {
		$depth++
		$links = Get-Content $path$tempfile
		$links = $links | Sort-Object | Get-Unique
		Clear-Content -Path $path$tempfile
		$linksCount = $links.Count
		$linkCount = 0
		foreach ($link in $links) {
			if ($link) {
				$linkCount++
				$linkProgress = ($linkCount / $linksCount) * 100
				$linkProgress = "{0:n2}" -f $linkProgress
				Write-Progress -Activity "Search in Progress: $link" -Status "Complete: $linkProgress% Depth: $depth" -PercentComplete $linkProgress -CurrentOperation ' '
				try {
					$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing
				} catch {
					$errorlink = formatUrl -contentlink $_.TargetObject.Address.AbsoluteUri
					#$errorDetails = replaceComma $_.ErrorDetails -replace NewLine
					$errormessage = $errorlink + ',' + $_.ErrorDetails
					Add-Content -Path $path$errorfile -Value $errormessage
					$errors++
				}
				$results = $request.Links.href
				if ($progress) {
					$resultCount = $results.Count
					$requestCount = 0
				}
				foreach ($result in $results) {
					if ($progress) {
						$requestCount++
						$requestProgress = ($requestCount / $resultCount) * 100
						$requestProgress = "{0:n2}" -f $requestProgress
						Write-Progress -Id 1 -Activity "Result: $result" -Status 'Progress' -PercentComplete $requestProgress -CurrentOperation ' '
					}
					if ($result) {
						$result = formatUrl -contentlink $result
						if ($result.StartsWith('/') -or $result.Contains($domain)) {
							if ($result.StartsWith('/')) {
								$contentlink = $domain + $result
							} elseif ($result.Contains($domain)) {
								$contentlink = removeHTTP -link $result
							}
							if (documentCheck) {
								if (!(Get-Content $path$docfile | Where-Object { ($_).ToLower().Contains(($contentlink).ToLower()) })) {
									$content = $contentlink + ',' + $link
									Add-Content -Path $path$docfile -Value $content
									'New Document: ' + $contentlink
									$filecount++
								} else {
									$duplicatecount++
								}
							} elseif (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($contentlink).ToLower()) })) {
								if ($contentlink.Contains($domain)) {
									Add-Content -Path $path$tempfile -Value $contentlink
								}
								$content = $contentlink + ',' + $link
								Add-Content -Path $path$linkfile -Value $content
								'New Link: ' + $contentlink
								$webcount++
							} else {
								$duplicatecount++
							}
						} else {
							if ($logOutOfScope) {
								$result = removeHTTP -link $result
								if (!(Get-Content $path$scopefile | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
									$content = $result + ',' + $link
									Add-Content -Path $path$scopefile -Value $content
									$outofscope++
									'Out of scope: ' + $result
								}
							}
						}
					}
				}
			}
		}
	} else {
		$unique = $false
	}
}

Remove-Item -Path $path$tempfile

if ($errors -eq 0) {
	Remove-Item -Path $path$errorfile
} else {
	#Sort and unique
}

$totalcount = $webcount + $filecount

''
'Duplicates: ' + $duplicatecount
'Web links: ' + $webcount
'Document links: ' + $filecount
'Total links: ' + $totalcount
if ($logOutOfScope) {
	'Out of scope links: ' + $outofscope
}
'Errors: ' + $errors
'Depth: ' + $depth

$value = 'Duplicates: ' + $duplicatecount
Add-Content -Path $path$logfile -Value $value
$value = 'Web links: ' + $webcount
Add-Content -Path $path$logfile -Value $value
$value = 'Document links: ' + $filecount
Add-Content -Path $path$logfile -Value $value
$value = 'Total links: ' + $totalcount
Add-Content -Path $path$logfile -Value $value
if ($logOutOfScope) {
	$value = 'Out of scope links: ' + $outofscope
	Add-Content -Path $path$logfile -Value $value
}
$value = 'Errors: ' + $errors
Add-Content -Path $path$logfile -Value $value
$value = 'Depth: ' + $depth
Add-Content -Path $path$logfile -Value $value

if ($requestLinkInfo) {
	$links = Get-Content -Path $path$linkfile | Sort-Object | Get-Unique
	Clear-Content -Path $path$linkfile
	$linksCount = $links.Count
	$linkCount = 0
	foreach ($link in $links) {
        $parent = $link.split(',')[1]
        $link = $link.split(',')[0]
		$linkCount++
		$linkProgress = ($linkCount / $linksCount) * 100
		$linkProgress = "{0:n2}" -f $linkProgress
		Write-Progress -Activity "Requesting Link Information: $link" -Status "Complete: $linkProgress" -PercentComplete $linkProgress -CurrentOperation ' '
		if ($link) {
			try {
				$link = formatUrl -contentlink $link
				$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing
				$lastModified = removeComma -lm $request.Headers.'Last-Modified'
				$contentLength = DisplayInBytes -num $request.Headers.'Content-Length'
				try {
					$title = $request.Content.Split('<') | Where-Object { $_.Contains('title') }
					$title = $title.Split('>')[1]
					$title = $title -replace ([Environment]::NewLine)
					$title = $title -replace ('  ')
					$title = removeComma -lm $title
				} catch {
					$title = ''
				}
				$content = $link + ',' + $parent + ',' + ($request.Headers.'Content-Type'.Split(';')[0]).Split('/')[1] + ',' + $request.StatusCode + ',' + $title + ',' `
 					+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
				Add-Content -Path $path$linkfile -Value $content
			} catch {
                $content = $link + ',' + $parent
				if ((($_ -split '\n')[0]).Contains("Bad Request")) {
					$content += ',error,400,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("401") -or (($_ -split '\n')[0]).Contains("Unauthorized")) {
					$content += ',error,401,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("Forbidden") -or (($_ -split '\n')[0]).Contains("You do not have permission")) {
					$content += ',error,403,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("404") -or (($_ -split '\n')[0]).Contains("Not Found") -or (($_ -split '\n')[0]).Contains("not found") -or (($_ -split '\n')[0]).Contains("could be found") -or (($_ -split '\n')[0]).Contains("The resource you are looking for has been removed")) {
					$content += ',error,404,' + ($_ -split '\n')[4]
				} elseif ((($_ -split '\n')[0]).Contains("Unable to connect to the remote server") -or (($_ -split '\n')[0]).Contains("The operation has timed out.")) {
					$content += ',error,408,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("Server Error")) {
					$content += ',error,500,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("Service Unavailable")) {
					$content += ',error,503,' + ($_ -split '\n')[0]
				} else {
					$content += ',error,,' + ($_ -split '\n')[0]
				}
				Add-Content -Path $path$linkfile -Value $content
			}
		}
	}
} else {
	$content = Get-Content -Path $path$linkfile | Sort-Object | Get-Unique
	Clear-Content -Path $path$linkfile
	foreach($c in $content) {
		Add-Content -Path $path$linkfile -Value $c
	}
}

if ($requestDocInfo) {
	$links = Get-Content -Path $path$docfile | Sort-Object | Get-Unique
	Clear-Content -Path $path$docfile
	$linksCount = $links.Count
	$linkCount = 0
	foreach ($link in $links) {
        $parent = $link.split(',')[1]
        $link = $link.split(',')[0]
		$linkCount++
		$linkProgress = ($linkCount / $linksCount) * 100
		$linkProgress = "{0:n2}" -f $linkProgress
		Write-Progress -Activity "Requesting Document Information: $link" -Status "Complete: $linkProgress" -PercentComplete $linkProgress -CurrentOperation ' '
		if ($link) {
			$doctype = documentType -doclink $link
			try {
				$link = formatUrl -contentlink $link
				$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing -Method Head
				$lastModified = removeComma -lm $request.Headers.'Last-Modified'
				$contentLength = DisplayInBytes -num $request.Headers.'Content-Length'
				$title = formatReadable -contentlink $link
				$content = $link + ',' + $parent + ',' + $doctype + ',' + $request.StatusCode + ',' + $title + ',' `
 					+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
				$request.ParsedHtml.title
				Add-Content -Path $path$docfile -Value $content
			} catch {
                $content = $link + ',' + $parent
				if ((($_ -split '\n')[0]).Contains("Bad Request")) {
					$content += ',error,400,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("401") -or (($_ -split '\n')[0]).Contains("Unauthorized")) {
					$content += ',error,401,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("Forbidden") -or (($_ -split '\n')[0]).Contains("You do not have permission")) {
					$content += ',error,403,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("404") -or (($_ -split '\n')[0]).Contains("Not Found") -or (($_ -split '\n')[0]).Contains("not found") -or (($_ -split '\n')[0]).Contains("could be found") -or (($_ -split '\n')[0]).Contains("The resource you are looking for has been removed")) {
					$content += ',error,404,' + ($_ -split '\n')[4]
				} elseif ((($_ -split '\n')[0]).Contains("Unable to connect to the remote server") -or (($_ -split '\n')[0]).Contains("The operation has timed out.")) {
					$content += ',error,408,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("Server Error")) {
					$content += ',error,500,' + ($_ -split '\n')[0]
				} elseif ((($_ -split '\n')[0]).Contains("Service Unavailable")) {
					$content += ',error,503,' + ($_ -split '\n')[0]
				} else {
					$content += ',error,,' + ($_ -split '\n')[0]
				}
				Add-Content -Path $path$docfile -Value $content
			}
		}
	}
} else {
	$content = Get-Content -Path $path$docfile | Sort-Object | Get-Unique
	Clear-Content -Path $path$docfile
	foreach($c in $content) {
		Add-Content -Path $path$docfile -Value $c
	}
}

if ($outofscope -eq 0) {
	Remove-Item -Path $path$scopefile
} else {
	$content = Get-Content -Path $path$scopefile
	Clear-Content -Path $path$scopefile
	$content = $content | Sort-Object | Get-Unique
	Add-Content -Path $path$scopefile -Value $content
}

$content = Get-Content -Path $path$linkfile
$content += Get-Content -Path $path$docfile
$content = $content | Sort-Object | Get-Unique
Add-Content -Path $path$reportfile -Value 'URL,Parent,Content,HTTP Status,Description,Date Modified,Size,Byte Size'
Add-Content -Path $path$reportfile -Value $content

$EndDate = Get-Date
$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
$TimeSpan

Add-Content -Path $path$logfile -Value ''
$value = 'Complete in: ' + $TimeSpan.Hours + ' hours, ' + $TimeSpan.Minutes + ' minutes, ' + $TimeSpan.Seconds + ' seconds'
Add-Content -Path $path$logfile -Value $value
#}
