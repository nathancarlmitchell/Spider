# Nathan Carl Mitchell
# nathancarlmitchell@gmail.com
# https://github.com/nathancarlmitchell/Spider
# Verion 2.8.1
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

function documentCheck {
	param(
		$link
	)

	$doclink = ($link.Split('.')[-1]).ToLower()
	$doclink = $doclink.Substring(0, [Math]::Min($doclink.Length, 3))
	$doctypes = 'pdf', 'xls', 'xlsx', 'xlsm', 'xlt', 'xltm', 'doc', 'docm', 'docx', 'dot', 'dotx', 'ppt', 'pptm', 'pptx', 'ppsx', `
		'txt', 'zip', 'rar', 'csv', 'kmz', 'shp', 'cat', 'dat', 'dgn', 'alg', 'prj', 'rtf', 'pub', 'xml', 'gpx', `
		'mp3', 'mp4', 'avi', 'mov', 'wav', 'wmv', 'wma', 'jpg', 'jpeg', 'png', 'gif', 'tif', 'bmp'
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

	if($url.StartsWith('//')) {
		$url = $url -replace '//'
	}
    
	if ($url.EndsWith('#')) {
		$url = $url -replace '#'
	}
    
	if ($url.StartsWith('www.')) {
		$url = $url -replace 'www.'
	}

	if ($url.Contains('?')) {
		$url = $url.Split('?')[0]
	}

	return $url
}

function formatReadable {
	param(
		$content,
		$document
	)

	if($document) {
		$content = $content.Split('/')[-1]
	}
	else {
		if ($content.ToLower().Contains('filename=')) {
			$content = $content.Split('=')[-1]
		}	
	}

	$content = $content -replace '%2C', ' '
	$content = $content -replace '%20', ' '
	$content = $content -replace '&nbsp;', " "
	$content = $content -replace '%27', "'"
	$content = $content -replace '&#39;', "'"
	$content = $content -replace '&#039;', "'"
	$content = $content -replace '&quot;', "'"
	$content = $content -replace '&#8216;', "'"
	$content = $content -replace '&#8217;', "'"
	$content = $content -replace '&#8220;', "'"
	$content = $content -replace '&#8221;', "'"
	$content = $content -replace '%28', "("
	$content = $content -replace '%29', ")"
	$content = $content -replace '&ndash;', "-"
	$content = $content -replace '&mdash;', "-"
	$content = $content -replace '&#8211;', "-"
	$content = $content -replace '&amp;', "&"
	$content = $content -replace '&#038;', "&"
	$content = $content -replace '&#8230;', "..."

	$content = $content -replace ([Environment]::NewLine), (' ')
	$content = $content -replace ("`n"), (' ')
	$content = $content -replace ("`t")
	$content = $content.TrimStart(' ')
	$content = $content.TrimEnd(' ')

	if ($content.Contains('  ')) {
		$doublespace = $true
		while ($doublespace) {
			if ($content.Contains('  ')) {
				$content = $content -replace ('  '), (' ')
			}
			else {
				$doublespace = $false
			}
		}
	}

	return $content
}

function Get-HTTPError {
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

function Remove-Comma {
	param(
		$content
	)

	$content = $content -replace ',', '.'
	return $content
}

function DisplayInBytes {
	param(
		$num
	)

	if($num) {
		$suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
		$index = 0
		while ($num -gt 1kb) {
			$num = $num / 1kb
			$index++
		}

		"{0:F1} {1}" -f $num, $suffix[$index]
	}
}

$request = Invoke-WebRequest $url -TimeoutSec $requestTimeout -UseBasicParsing
$domain = formatUrl -url $request.BaseResponse.ResponseUri.Host
$path = $PSScriptRoot + '\' + $domain + '\'
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

function Test-FileLocked {
	param (
		[Parameter(Mandatory=$true)]
		[String[]]
		$file
	)

	$oFile = New-Object System.IO.FileInfo $file
	if ((Test-Path -Path $file) -eq $false) {
		return $false
	}

	try {
		$oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
		if ($oStream) {
			$oStream.Close()
		}
		$false
	}
	catch {
		return $true
	}
}

function Edit-Content {
	param(
		[Parameter(Mandatory=$true)]
		[String[]]
		$file,

		[Parameter(Mandatory=$true)]
		[String[]]
		$mode,

		[Parameter(Mandatory=$false)]
		[String[]]
		$content
	)
	
	$complete = $false
	while(!$complete) {
		if (!(Test-FileLocked -file $file)){
			if($mode -eq 'add') {
				Add-Content -Path $file -Value $content
			}
			elseif($mode -eq 'clear') {
				Clear-Content -Path $file
			}
			$complete = $true
		}
		else {
			''
			$file + ' is locked.'
			'Close the file to continue.'
			pause
		}
	}
}

Edit-Content -file $path$linkfile -mode 'clear'
Edit-Content -file $path$docfile -mode 'clear'
Edit-Content -file $path$scopefile -mode 'clear'
Edit-Content -file $path$reportfile -mode 'clear'
Edit-Content -file $path$tempfile -mode 'clear'
Edit-Content -file $path$errorfile -mode 'clear'
Edit-Content -file $path$logfile -mode 'clear'

$link = formatUrl -url $request.BaseResponse.ResponseUri.AbsoluteUri
$content = $link + ',' + $domain
Edit-Content -file $path$linkfile -mode 'add' -content $content
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
					Edit-Content -file $path$docfile -mode 'add' -content $content
					'New Document: ' + $link
					$documentcount++
				}
			}
			elseif (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
				if ($link.ToLower().Contains($domain)) {
					Edit-Content -file $path$tempfile -mode 'add' -content $link
				}
				$content = $link + ',' + $url
				Edit-Content -file $path$linkfile -mode 'add' -content $content
				'New Link: ' + $link
				$webcount++
			}
		}
		else {
			if ($logOutOfScope) {
				if (!(Get-Content $path$scopefile | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
					$content = $link + ',' + $url
					Edit-Content -file $path$scopefile -mode 'add' -content $content
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
		Edit-Content -file $path$tempfile -mode 'clear'
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
					$errorDetails = Remove-Comma -content $_.ErrorDetails 
					$errorDetails = formatReadable -content $errorDetails -document $false
					$errormessage = $link + ',' + $errorDetails
					Edit-Content -file $path$errorfile -mode 'add' -content $errormessage
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
									Edit-Content -file $path$docfile -mode 'add' -content $content
									'New Document: ' + $result
									$documentcount++
								}
								else {
									$duplicatecount++
								}
							}
							elseif (!(Get-Content $path$linkfile | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
								if ($result.ToLower().Contains($domain)) {
									Edit-Content -file $path$tempfile -mode 'add' -content $result
								}
								$content = $result + ',' + $link
								Edit-Content -file $path$linkfile -mode 'add' -content $content
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
									Edit-Content -file $path$scopefile -mode 'add' -content $content
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
		Edit-Content -file $path$linkfile -mode 'clear'
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
					$lastModified = Remove-Comma -content $request.Headers.'Last-Modified'
					$contentLength = DisplayInBytes -num $request.Headers.'Content-Length'
					try {
						$title = $request.Content.Split('<') | Where-Object { $_.ToLower().Contains('title>') }
						$title = $title.Split('>')[1]
						$title = Remove-Comma -content $title
						$title = formatReadable -content $title -document $false
					}
					catch {
						$title = ''
					}
					$content = $link + ',' + $parent + ',' + ($request.Headers.'Content-Type'.Split(';')[0]).Split('/')[1] + ',' + $request.StatusCode + ',' + $title + ',' `
						+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
						Edit-Content -file $path$linkfile -mode 'add' -content $content
				}
				catch {
					Get-HTTPError -e $_ -link $link -parent $parent
				}
			}
		}
	}
	else {
		$content = Get-Content -Path $path$linkfile | Sort-Object | Get-Unique
		Edit-Content -file $path$linkfile -mode 'clear'
		foreach ($c in $content) {
			Add-Content -Path $path$linkfile -Value $c
		}
	}
}

if ($documentcount -eq 0) { Remove-Item -Path $path$docfile } else { 
	if ($requestDocInfo) {
		$links = Get-Content -Path $path$docfile | Sort-Object | Get-Unique
		Edit-Content -file $path$docfile -mode 'clear'
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
					$lastModified = Remove-Comma -content $request.Headers.'Last-Modified'
					$contentLength = DisplayInBytes -num $request.Headers.'Content-Length'
					$title = formatReadable -content $link -document $true
					$content = $link + ',' + $parent + ',' + $doctype + ',' + $request.StatusCode + ',' + $title + ',' `
						+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
					$request.ParsedHtml.title
					Add-Content -Path $path$docfile -Value $content
				}
				catch {
					Get-HTTPError -e $_ -link $link -parent $parent
				}
			}
		}
	}
	else {
		$content = Get-Content -Path $path$docfile | Sort-Object | Get-Unique
		Edit-Content -file $path$docfile -mode 'clear'
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
	Edit-Content -file $path$errorfile -mode 'clear'
	Edit-Content -file $path$errorfile -mode 'add' -content 'URL,Error'
	foreach ($c in $content) {
		Edit-Content -file $path$errorfile -mode 'add' -content $c
	}
}

if ($outofscope -eq 0) {
	Remove-Item -Path $path$scopefile
}
else {
	$content = Get-Content -Path $path$scopefile | Sort-Object | Get-Unique
	Edit-Content -file $path$scopefile -mode 'clear'
	Edit-Content -file $path$scopefile -mode 'add' -content 'URL,Parent'
	foreach ($c in $content) {
        Edit-Content -file $path$scopefile -mode 'add' -content $c
    }
}

if ($linkfile -ne 0) { $content = Get-Content -Path $path$linkfile }
if ($documentcount -ne 0) { $content += Get-Content -Path $path$docfile }
$content = $content | Sort-Object | Get-Unique
Edit-Content -file $path$reportfile -mode 'add' -content  'URL,Parent,Content,HTTP Status,Description,Date Modified,Size,Byte Size'
Edit-Content -file $path$reportfile -mode 'add' -content  $content

Edit-Content -file $PSScriptRoot'\master.csv' -mode 'add' -content $content

$EndDate = Get-Date
$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
$TimeSpan

Edit-Content -file $path$logfile -mode 'add' -content ''
$value = 'Complete in: ' + $TimeSpan.Hours + ' hours, ' + $TimeSpan.Minutes + ' minutes, ' + $TimeSpan.Seconds + ' seconds'
Edit-Content -file $path$logfile -mode 'add' -content $value