# Nathan Carl Mitchell
# nathancarlmitchell@gmail.com
# https://github.com/nathancarlmitchell/Spider
# Verion 2.7.5
# PowerShell Version 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($args[0]) {
	$url = $args[0]
}
else {
	$url = Read-Host 'Search Domain [chfs.ky.gov]'
	if (!$url) {
		$url = 'chfs.ky.gov'
	}
}

if ($args[1]) {
	$maxDepth = $args[1]
}
else {
	$maxDepth = Read-Host 'Max Depth? (1 - 99) [15]'
	if (!$maxDepth) {
		$maxDepth = 15
	}
}

if ($args[2]) {
	$requestTimeout = $args[2]
}
else {
	$requestTimeout = Read-Host 'Request Timeout? (Seconds 1 - 99) [10]'
	if (!$requestTimeout) {
		$requestTimeout = 10
	}
}

if ($args[3]) {
	if (($args[3]).ToLower().Contains('y')) {
		$requestLinkInfo = $true
	}
 elseif (($args[3]).ToLower().Contains('n')) {
		$requestLinkInfo = $false
	}
}
else {
	$p = Read-Host 'Request Link Information? (Slower performance) [y]/n'
	if (!$p) {
		$requestLinkInfo = $true
	}
 else {
		if (($p).ToLower().Contains('y')) {
			$requestLinkInfo = $true
		}
		elseif (($p).ToLower().Contains('n')) {
			$requestLinkInfo = $false
		}
	}
}

if ($args[4]) {
	if (($args[4]).ToLower().Contains('y')) {
		$requestDocInfo = $true
	}
 elseif (($args[4]).ToLower().Contains('n')) {
		$requestDocInfo = $false
	}
}
else {
	$p = Read-Host 'Request Document Information? (Slower performance) [y]/n'
	if (!$p) {
		$requestDocInfo = $true
	}
 else {
		if (($p).ToLower().Contains('y')) {
			$requestDocInfo = $true
		}
		elseif (($p).ToLower().Contains('n')) {
			$requestDocInfo = $false
		}
	}
}

if ($args[5]) {
	if (($args[5]).ToLower().Contains('y')) {
		$logOutOfScope = $true
	}
 elseif (($args[5]).ToLower().Contains('n')) {
		$logOutOfScope = $false
	}
}
else {
	$p = Read-Host 'Log out-of-scope links? (Slower performance) [y]/n'
	if (!$p) {
		$logOutOfScope = $true
	}
 else {
		if (($p).ToLower().Contains('y')) {
			$logOutOfScope = $true
		}
		elseif (($p).ToLower().Contains('n')) {
			$logOutOfScope = $false
		}
	}
}

$request = Invoke-WebRequest $url -TimeoutSec $requestTimeout -UseBasicParsing
$domain = $request.BaseResponse.ResponseUri.Host
$path = 'C:\Users\Owner\Downloads\Spider-master\Spider-master\' + $domain + '\'
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
$documentcount = 0
$totalcount = 0
$errorcount = 0
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

function documentCheck {
	param(
		$link
	)

	$doclink = ($link.Split('.')[-1]).ToLower()
	$doctypes = 'pdf', 'xls', 'xlsx', 'xlsm', 'xlt', 'xltm', 'doc', 'docm', 'docx', 'dot', 'dotx', 'ppt', 'pptm', 'pptx', 'ppsx', `
		'zip', 'csv', 'kmz', 'shp', 'cat', 'dat', 'dgn', 'alg', 'rtf', 'pub', `
		'mp3', 'mp4', 'avi', 'mov', 'wav', 'wmv', 'wma', 'jpg', 'png', 'gif', 'tif'
	if ($doctypes.Contains($doclink)) {
		$document = $true
	}
	else {
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
		$url
	)

	$url = $url -replace 'https://'
	$url = $url -replace 'http://'
	$url = $url -replace 'http&#58;//'
	$url = $url -replace 'https&#58;//'
	$url = $url -replace ',', '%2C'
	$url = $url -replace ' ', '%20'
	$url = $url -replace '&amp;', '&'
    
	if ($url.EndsWith('#')) {
		$url = $url -replace '#'
	}
    
	if ($url.StartsWith('www.')) {
		$url = $url -replace 'www.'
	}

	return $url
}

function formatReadable {
	param(
		$content
	)

	if ($content.ToLower().Contains('filename=')) {
		$content = $content.Split('=')[-1]
	}
	else {
		$content = $content.Split('/')[-1]
	}

	$content = $content -replace '%2C', ' '
	$content = $content -replace '%20', ' '
	$content = $content -replace '%27', "'"
	$content = $content -replace '%28', "("
	$content = $content -replace '%29', ")"
	$content = $content -replace '&ndash;', "-"
	$content = $content -replace '&mdash;', "-"
	$content = $content -replace '&#8211;', "-"
	$content = $content -replace '&amp;', "&"
	$content = $content -replace '&#038;', "&"
	$content = $content -replace '&#39;', "'"
	$content = $content -replace '&quot;', "'"
	$content = $content -replace '&#8217;', "'"
	$content = $content -replace '&nbsp;', " "
	return $content
}

function catchHTTP {
    param (
        $e,
        $link,
        $parent
    )

    $content = $link + ',' + $parent
    if ((($e -split '\n')[0]).Contains("Bad Request")) {
        $content += ',error,400,' + ($e -split '\n')[0]
    }
    elseif ((($e -split '\n')[0]).Contains("401") -or (($e -split '\n')[0]).Contains("Unauthorized")) {
        $content += ',error,401,' + ($e -split '\n')[0]
    }
    elseif ((($e -split '\n')[0]).Contains("Forbidden") -or (($e -split '\n')[0]).Contains("You do not have permission")) {
        $content += ',error,403,' + ($e -split '\n')[0]
    }
    elseif ((($e -split '\n')[0]).Contains("404") -or (($e -split '\n')[0]).Contains("Not Found") -or (($e -split '\n')[0]).Contains("not found") -or (($e -split '\n')[0]).Contains("could be found") -or (($e -split '\n')[0]).Contains("The resource you are looking for has been removed")) {
        $content += ',error,404,' + ($e -split '\n')[4]
    }
    elseif ((($e -split '\n')[0]).Contains("Unable to connect to the remote server") -or (($e -split '\n')[0]).Contains("The operation has timed out.")) {
        $content += ',error,408,' + ($e -split '\n')[0]
    }
    elseif ((($e -split '\n')[0]).Contains("Server Error")) {
        $content += ',error,500,' + ($e -split '\n')[0]
    }
    elseif ((($e -split '\n')[0]).Contains("Service Unavailable")) {
        $content += ',error,503,' + ($e -split '\n')[0]
    }
    else {
        $content += ',error,,' + ($e -split '\n')[0]
    }
    Add-Content -Path $path$docfile -Value $content
}

function removeComma {
	param(
		$lm
	)

	$lm = $lm -replace ',', '.'
	return $lm
}

function DisplayInBytes () {
	param(
		$num
	)

	$suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
	$index = 0
	while ($num -gt 1kb) {
		$num = $num / 1kb
		$index++
	}

	"{0:F1} {1}" -f $num, $suffix[$index]
}

$link = formatUrl -url $request.BaseResponse.ResponseUri.AbsoluteUri
$content = $link + ',' + $domain
Add-Content -Path $path$linkfile -Value $content
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
		$link = formatUrl -url $link
		#or $link.Contains($scope)
		if ($link.StartsWith('/') -or $link.ToLower().Split('/')[0].StartsWith($domain)) {
			if ($link.StartsWith('/')) {
				$link = $domain + $link
			}
			if (documentCheck -link $link) {
				if (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
					$content = $link + ',' + $url
					Add-Content -Path $path$docfile -Value $content
					'New Document: ' + $link
					$documentcount++
				}
			}
			elseif (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
				if ($link.ToLower().Contains($domain)) {
					Add-Content -Path $path$tempfile -Value $link
				}
				$content = $link + ',' + $url
				Add-Content -Path $path$linkfile -Value $content
				'New Link: ' + $link
				$webcount++
			}
		}
		else {
			if ($logOutOfScope) {
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
				}
				catch {
					$errorDetails = removeComma -lm $_.ErrorDetails 
					$errorDetails = $errorDetails -replace ([Environment]::NewLine), (' ')
					$errorDetails = $errorDetails -replace ("`n"), (' ')
					$errorDetails = $errorDetails -replace ("`t"), (' ')
					$errormessage = $link + ',' + $errorDetails
					Add-Content -Path $path$errorfile -Value $errormessage
					$errorcount++
				}
				$results = $request.Links.href
				foreach ($result in $results) {
					if ($result) {
						$result = formatUrl -url $result
						if ($result.StartsWith('/') -or $result.ToLower().Split('/')[0].StartsWith($domain)) {
							if ($result.StartsWith('/')) {
								$result = $domain + $result
							}
							if (documentCheck -link $result) {
								if (!(Get-Content $path$docfile | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
									$content = $result + ',' + $link
									Add-Content -Path $path$docfile -Value $content
									'New Document: ' + $result
									$documentcount++
								}
								else {
									$duplicatecount++
								}
							}
							elseif (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
								if ($result.ToLower().Contains($domain)) {
									Add-Content -Path $path$tempfile -Value $result
								}
								$content = $result + ',' + $link
								Add-Content -Path $path$linkfile -Value $content
								'New Link: ' + $result
								$webcount++
							}
							else {
								$duplicatecount++
							}
						}
						else {
							if ($logOutOfScope) {
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
	}
 else {
		$unique = $false
	}
}

Remove-Item -Path $path$tempfile

$totalcount = $webcount + $documentcount

''
'Duplicates: ' + $duplicatecount
'Web links: ' + $webcount
'Document links: ' + $documentcount
'Total links: ' + $totalcount
if ($logOutOfScope) {
	'Out of scope links: ' + $outofscope
}
'Errors: ' + $errorcount
'Depth: ' + $depth

$value = 'Duplicates: ' + $duplicatecount
Add-Content -Path $path$logfile -Value $value
$value = 'Web links: ' + $webcount
Add-Content -Path $path$logfile -Value $value
$value = 'Document links: ' + $documentcount
Add-Content -Path $path$logfile -Value $value
$value = 'Total links: ' + $totalcount
Add-Content -Path $path$logfile -Value $value
if ($logOutOfScope) {
	$value = 'Out of scope links: ' + $outofscope
	Add-Content -Path $path$logfile -Value $value
}
$value = 'Errors: ' + $errorcount
Add-Content -Path $path$logfile -Value $value
$value = 'Depth: ' + $depth
Add-Content -Path $path$logfile -Value $value

if ($webcount -eq 0) { Remove-Item -Path $path$linkfile } else { 
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
					$link = formatUrl -url $link
					$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing
					$lastModified = removeComma -lm $request.Headers.'Last-Modified'
					$contentLength = DisplayInBytes -num $request.Headers.'Content-Length'
					try {
						$title = $request.Content.Split('<') | Where-Object { $_.ToLower().Contains('title>') }
						$title = $title.Split('>')[1]
						$title = $title -replace ([Environment]::NewLine), (' ')
						$title = $title -replace ("`n"), (' ')
						$title = $title -replace ("`t")
						$title = $title -replace ('  '), (' ')
						$title = $title.TrimStart(' ')
						$title = $title.TrimEnd(' ')
						$title = removeComma -lm $title
						$title = formatReadable -content $title
					}
					catch {
						$title = ''
					}
					$content = $link + ',' + $parent + ',' + ($request.Headers.'Content-Type'.Split(';')[0]).Split('/')[1] + ',' + $request.StatusCode + ',' + $title + ',' `
						+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
					Add-Content -Path $path$linkfile -Value $content
				}
				catch {
					catchHTTP -e $_ -link $link -parent $parent
				}
			}
		}
	}
 else {
		$content = Get-Content -Path $path$linkfile | Sort-Object | Get-Unique
		Clear-Content -Path $path$linkfile
		foreach ($c in $content) {
			Add-Content -Path $path$linkfile -Value $c
		}
	}
}

if ($documentcount -eq 0) { Remove-Item -Path $path$docfile } else { 
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
					$link = formatUrl -url $link
					$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing -Method Head
					$lastModified = removeComma -lm $request.Headers.'Last-Modified'
					$contentLength = DisplayInBytes -num $request.Headers.'Content-Length'
					$title = formatReadable -content $link
					$content = $link + ',' + $parent + ',' + $doctype + ',' + $request.StatusCode + ',' + $title + ',' `
						+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
					$request.ParsedHtml.title
					Add-Content -Path $path$docfile -Value $content
				}
				catch {
					catchHTTP -e $_ -link $link -parent $parent
				}
			}
		}
	}
 else {
		$content = Get-Content -Path $path$docfile | Sort-Object | Get-Unique
		Clear-Content -Path $path$docfile
		foreach ($c in $content) {
			Add-Content -Path $path$docfile -Value $c
		}
	}
}

if ($errorcount -eq 0) {
	Remove-Item -Path $path$errorfile
}
else {
	$content = Get-Content -Path $path$errorfile | Sort-Object | Get-Unique
	Clear-Content -Path $path$errorfile
	Add-Content -Path $path$errorfile -Value 'URL,Error'
	foreach ($c in $content) {
		Add-Content -Path $path$errorfile -Value $c
	}
}

if ($outofscope -eq 0) {
	Remove-Item -Path $path$scopefile
}
else {
	$content = Get-Content -Path $path$scopefile | Sort-Object | Get-Unique
	Clear-Content -Path $path$scopefile
	Add-Content -Path $path$scopefile -Value 'URL,Parent'
	foreach ($c in $content) {
        Add-Content -Path $path$scopefile -Value $c
    }
}

if ($linkfile -ne 0) { $content = Get-Content -Path $path$linkfile }
if ($documentcount -ne 0) { $content += Get-Content -Path $path$docfile }
$content = $content | Sort-Object | Get-Unique
Add-Content -Path $path$reportfile -Value 'URL,Parent,Content,HTTP Status,Description,Date Modified,Size,Byte Size'
Add-Content -Path $path$reportfile -Value $content

Add-Content -Path 'C:\Users\Owner\Downloads\Spider-master\Spider-master\master.csv' -Value $content

$EndDate = Get-Date
$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
$TimeSpan

Add-Content -Path $path$logfile -Value ''
$value = 'Complete in: ' + $TimeSpan.Hours + ' hours, ' + $TimeSpan.Minutes + ' minutes, ' + $TimeSpan.Seconds + ' seconds'
Add-Content -Path $path$logfile -Value $value