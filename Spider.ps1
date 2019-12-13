# Nathan Carl Mitchell
# nathancarlmitchell@gmail.com
# https://github.com/nathancarlmitchell/Spider
# Verion 2.8.1
# PowerShell Version 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($args[0]) {
	$domain = $args[0]
}
else {
	$domain = Read-Host 'Search Domain [chfs.ky.gov]'
	if (!$domain) {
		$domain = 'chfs.ky.gov'
	}
}

if ($args[1]) {
	$maxDepth = $args[1]
}
else {
	$maxDepth = Read-Host 'Max Depth? (1 - 99) [10]'
	if (!$maxDepth) {
		$maxDepth = 10
	}
}

if ($args[2]) {
	$requestTimeout = $args[2]
}
else {
	$requestTimeout = Read-Host 'Request Timeout? (Seconds 1 - 99) [7]'
	if (!$requestTimeout) {
		$requestTimeout = 7
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

function Confirm-Document {
	param(
        [Parameter(Mandatory=$true)]
		[String]
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

function Get-DocumentType {
	param(
        [Parameter(Mandatory=$true)]
		[String]
		$doclink
	)

	$doctype = ($doclink.Split('.')[-1]).ToLower()
	return $doctype
}

function Format-Url {
	param(
        [Parameter(Mandatory=$true)]
		[String]
		$url
	)

	$url = $url -replace 'https://'
	$url = $url -replace 'http://'
	$url = $url -replace 'http&#58;//'
	$url = $url -replace 'https&#58;//'
	$url = $url -replace ',', '%2C'
	$url = $url -replace ' ', '%20'
    $url = $url -replace '&amp;', '&'
    $url = $url -replace ';', '%3B'
    $url = $url -replace ([Environment]::NewLine), (' ')
	$url = $url -replace ("`n"), (' ')
	$url = $url -replace ("`t")
    $url = $url -replace ('\n')

	if($url.StartsWith('//')) {
		$url = $url -replace '//'
	}
    
	if ($url.Contains('#')) {
		$url = $url.Split('#')[0]
	}
    
	if ($url.StartsWith('www.')) {
		$url = $url -replace 'www.'
	}

	if ($url.ToLower().Contains('?')) {
		$url = $url.Split('?')[0]
	}

<# 	if ($url.ToLower().Contains('?page=')) {
		$url = $url.Split('?page=')[0]
	}
	elseif ($url.ToLower().Contains('&page=')) {
		$url = $url.Split('&page=')[0]
	}
	elseif ($url.ToLower().Contains('?sort=')) {
		$url = $url.Split('?sort=')[0]
	}
	elseif ($url.ToLower().Contains('&sort=')) {
		$url = $url.Split('&sort=')[0]
	}
	elseif ($url.ToLower().Contains('?search=')) {
		$url = $url.Split('?search=')[0]
	}
	if ($url.ToLower().Contains('?tags=')) {
		$url = $url.Split('?tags=')[0]
	}
#>

	return $url
}

function Format-Readable {
	param(
        [Parameter(Mandatory=$false)]
		[String]
        $Content,

        [Parameter(Mandatory=$true)]
		[Boolean]
		$Document
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
	$content = $content -replace '&#160;', " "
	$content = $content -replace '%27', "'"
	$content = $content -replace '&#39;', "'"
	$content = $content -replace '&#039;', "'"
	$content = $content -replace '&quot;', "'"
	$content = $content -replace '&apos;', "'"
	$content = $content -replace '&#8216;', "'"
	$content = $content -replace '&#8217;', "'"
	$content = $content -replace '&#8220;', "'"
	$content = $content -replace '&#8221;', "'"
	$content = $content -replace '%28', "("
	$content = $content -replace '%29', ")"
	$content = $content -replace '&ndash;', "-"
	$content = $content -replace '&mdash;', "-"
	$content = $content -replace '&#8211;', "-"
	$content = $content -replace '&#8212;', "-"
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

function Get-HttpError {
    param (
        [Parameter(Mandatory=$false)]
		[String]
        $e,

        [Parameter(Mandatory=$false)]
		[String]
        $link,

        [Parameter(Mandatory=$false)]
		[String]
        $parent
    )

    $content = $link + ',' + $parent
    if ((($e -Split '\n')[0]).Contains("Bad Request")) {
        $content += ',error,400,' + ($e -Split '\n')[0]
    }
    elseif ((($e -Split '\n')[0]).Contains("401") -or (($e -Split '\n')[0]).Contains("Unauthorized")) {
        $content += ',error,401,' + ($e -Split '\n')[0]
    }
    elseif ((($e -Split '\n')[0]).Contains("Forbidden") -or (($e -Split '\n')[0]).Contains("You do not have permission")) {
        $content += ',error,403,' + ($e -Split '\n')[0]
    }
	elseif ((($e -Split '\n')[0]).Contains("404") -or (($e -Split '\n')[0]).Contains("Not Found") -or (($e -Split '\n')[0]).Contains("not found") `
		-or (($e -Split '\n')[0]).Contains("could be found") -or (($e -Split '\n')[0]).Contains("The resource you are looking for has been removed")) {
        $content += ',error,404,' + ($e -Split '\n')[4]
    }
    elseif ((($e -Split '\n')[0]).Contains("Unable to connect to the remote server") -or (($e -Split '\n')[0]).Contains("The operation has timed out.")) {
        $content += ',error,408,' + ($e -Split '\n')[0]
    }
    elseif ((($e -Split '\n')[0]).Contains("Server Error")) {
        $content += ',error,500,' + ($e -Split '\n')[0]
    }
    elseif ((($e -Split '\n')[0]).Contains("Service Unavailable")) {
        $content += ',error,503,' + ($e -Split '\n')[0]
    }
    else {
        $content += ',error,,' + ($e -Split '\n')[0]
    }
    Add-Content -Path $path$fileDocument -Value $content
}

function Remove-Comma {
	param(
        [Parameter(Mandatory=$false)]
		[String]
		$Content
	)

	$Content = $Content -replace ',', '.'
	return $Content
}

function Get-ByteSize {
	param(
        [Parameter(Mandatory=$false)]
		[Int32]
		$size
	)

	if($size) {
		$suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
		$index = 0
		while ($size -gt 1kb) {
			$size = $size / 1kb
			$index++
		}

		"{0:F1} {1}" -f $size, $suffix[$index]
	}
}

function Test-FileLock {
	param (
        [Parameter(Mandatory=$true)]
		[String[]]
		$file
	)
	# Returns true if the file is locked
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
        $File,
        
        [Parameter(Mandatory=$true)]
		[String[]]
        $Mode,
        
        [Parameter(Mandatory=$false)]
		[String[]]
		$Content
	)
	
	$Complete = $false
	while(!$Complete) {
		if (!(Test-FileLock -File $File)){
			if($Mode -eq 'add') {
				Add-Content -Path $File -Value $Content
			}
			elseif($Mode -eq 'clear') {
				Clear-Content -Path $File
			}
			$Complete = $true
		}
		else {
			''
			$File + ' is locked.'
			'Close the file to continue.'
			Pause
		}
	}
}

try { 
	$request = Invoke-WebRequest $domain -TimeoutSec $requestTimeout -UseBasicParsing
} catch {
	''
	"Error connecting to host domain: $domain"
}
if ($request) {
	#$domain = Format-Url -url $request.BaseResponse.ResponseUri.Host
	$path = $PSScriptRoot + '\' + $domain + '\'
	$fileLink = $domain + '.links.csv'
	$fileDocument = $domain + '.docs.csv'
	$fileScope = $domain + '.out-of-scope.csv'
	$fileReport = $domain + '.report.csv'
	$fileUnique = $domain + '.temp.txt'
	$fileError = $domain + '.errors.csv'
	$fileLog = $domain + '.log.txt'
	$countScope = 0
	$countDuplicate = 0
	$countLink = 0
	$countDocument = 0
	$countTotal = 0
	$countError = 0
	$countDepth = 1
	$unique = $true
	$StartDate = Get-Date

	if (![System.IO.File]::Exists($path)) {
		New-Item -ItemType Directory -Force -Path $path
	}
	if (![System.IO.File]::Exists($path + $fileLink)) {
		New-Item -Path $path -Name $fileLink
	}
	if (![System.IO.File]::Exists($path + $fileDocument)) {
		New-Item -Path $path -Name $fileDocument
	}
	if (![System.IO.File]::Exists($path + $fileScope)) {
		New-Item -Path $path -Name $fileScope
	}
	if (![System.IO.File]::Exists($path + $fileReport)) {
		New-Item -Path $path -Name $fileReport
	}
	if (![System.IO.File]::Exists($path + $fileUnique)) {
		New-Item -Path $path -Name $fileUnique
	}
	if (![System.IO.File]::Exists($path + $fileError)) {
		New-Item -Path $path -Name $fileError
	}
	if (![System.IO.File]::Exists($path + $fileLog)) {
		New-Item -Path $path -Name $fileLog
	}

	Edit-Content -File $path$fileLink -Mode 'clear'
	Edit-Content -File $path$fileDocument -Mode 'clear'
	Edit-Content -File $path$fileScope -Mode 'clear'
	Edit-Content -File $path$fileReport -Mode 'clear'
	Edit-Content -File $path$fileUnique -Mode 'clear'
	Edit-Content -File $path$fileError -Mode 'clear'
	Edit-Content -File $path$fileLog -Mode 'clear'

	$link = Format-Url -url $request.BaseResponse.ResponseUri.AbsoluteUri
	$content = $link + ',' + $domain
	Edit-Content -File $path$fileLink -Mode 'add' -Content $content
	$countLink++

	#$scope = '.' + $domain.Split('.')[1] + '.' + $domain.Split('.')[2]
	$links = $request.Links.href
	$links = $links | Sort-Object | Get-Unique
	$linksCount = $links.Count
	$linkCount = 0

	foreach ($link in $links) {
		$linkCount++
		$linkProgress = ($linkCount / $linksCount) * 100
		$linkProgress = "{0:n2}" -f $linkProgress
		Write-Progress -Activity "Search in Progress: $domain" -Status "Complete: $linkProgress% Depth: $countDepth" -PercentComplete $linkProgress
		if ($link) {
			$link = Format-Url -url $link
			#or $link.Contains($scope)
			if ($link.StartsWith('/') -or $link.ToLower().Split('/')[0].StartsWith($domain)) {
				if ($link.StartsWith('/')) {
					$link = $domain + $link
				}
				if (Confirm-Document -link $link) {
					if (!(Get-Content $path$fileLink | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
						$content = $link + ',' + $url
						Edit-Content -File $path$fileDocument -Mode 'add' -Content $content
						'New Document: ' + $link
						$countDocument++
					}
				}
				elseif (!(Get-Content $path$fileLink | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
					if ($link.ToLower().Contains($domain)) {
						Edit-Content -File $path$fileUnique -Mode 'add' -Content $link
					}
					$content = $link + ',' + $url
					Edit-Content -File $path$fileLink -Mode 'add' -Content $content
					'New Link: ' + $link
					$countLink++
				}
			}
			else {
				if ($logOutOfScope) {
					if (!(Get-Content $path$fileScope | Where-Object { ($_).ToLower().Contains(($link).ToLower()) })) {
						$content = $link + ',' + $url
						Edit-Content -File $path$fileScope -Mode 'add' -Content $content
						$countScope++
						'Out of scope: ' + $link
					}
				}
			}
		}
	}

	while ($unique) {
		if ($null -eq (Get-Content -Path $path$fileUnique)) {
			$unique = $false
		}
		if ($countDepth -lt $maxDepth) {
			$countDepth++
			$links = Get-Content $path$fileUnique
			$links = $links | Sort-Object | Get-Unique
			Edit-Content -File $path$fileUnique -Mode 'clear'
			$linksCount = $links.Count
			$linkCount = 0
			foreach ($link in $links) {
				if ($link) {
					$linkCount++
					$linkProgress = ($linkCount / $linksCount) * 100
					$linkProgress = "{0:n2}" -f $linkProgress
					Write-Progress -Activity "Search in Progress: $link" -Status "Complete: $linkProgress% Depth: $countDepth" -PercentComplete $linkProgress -CurrentOperation ' '
					try {
						$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing
					}
					catch {
						# Should this be here?
						# Replaced by catch http?
						# Need seperate file for errors?
						if($_.ErrorDetails) {
							$errorDetails = Remove-Comma -Content $_.ErrorDetails 
							$errorDetails = Format-Readable -Content $errorDetails -Document $false
						}
						$errorMessage = $link + ',' + $errorDetails
						Edit-Content -File $path$fileError -Mode 'add' -Content $errorMessage
						$countError++
					}
					$results = $request.Links.href
					foreach ($result in $results) {
						if ($result) {
							$result = Format-Url -url $result
							if ($result.StartsWith('/') -or $result.ToLower().Split('/')[0].StartsWith($domain)) {
								if ($result.StartsWith('/')) {
									$result = $domain + $result
								}
								if (Confirm-Document -link $result) {
									if (!(Get-Content $path$fileDocument | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
										$content = $result + ',' + $link
										Edit-Content -File $path$fileDocument -Mode 'add' -Content $content
										'New Document: ' + $result
										$countDocument++
									}
									else {
										$countDuplicate++
									}
								}
								elseif (!(Get-Content $path$fileLink | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
									if ($result.ToLower().Contains($domain)) {
										Edit-Content -File $path$fileUnique -Mode 'add' -Content $result
									}
									$content = $result + ',' + $link
									Edit-Content -File $path$fileLink -Mode 'add' -Content $content
									'New Link: ' + $result
									$countLink++
								}
								else {
									$countDuplicate++
								}
							}
							else {
								if ($logOutOfScope) {
									if (!(Get-Content $path$fileScope | Where-Object { ($_).ToLower().Contains(($result).ToLower()) })) {
										$content = $result + ',' + $link
										Edit-Content -File $path$fileScope -Mode 'add' -Content $content
										$countScope++
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

	Remove-Item -Path $path$fileUnique

	$countTotal = $countLink + $countDocument

	''
	'Duplicates: ' + $countDuplicate
	'Web links: ' + $countLink
	'Document links: ' + $countDocument
	'Total links: ' + $countTotal
	if ($logOutOfScope) {
		'Out of scope links: ' + $countScope
	}
	'Errors: ' + $countError
	'Depth: ' + $countDepth

	$value = 'Duplicates: ' + $countDuplicate
	Add-Content -Path $path$fileLog -Value $value
	$value = 'Web links: ' + $countLink
	Add-Content -Path $path$fileLog -Value $value
	$value = 'Document links: ' + $countDocument
	Add-Content -Path $path$fileLog -Value $value
	$value = 'Total links: ' + $countTotal
	Add-Content -Path $path$fileLog -Value $value
	if ($logOutOfScope) {
		$value = 'Out of scope links: ' + $countScope
		Add-Content -Path $path$fileLog -Value $value
	}
	$value = 'Errors: ' + $countError
	Add-Content -Path $path$fileLog -Value $value
	$value = 'Depth: ' + $countDepth
	Add-Content -Path $path$fileLog -Value $value

	if ($countLink -eq 0) { Remove-Item -Path $path$fileLink } else { 
		if ($requestLinkInfo) {
			$links = Get-Content -Path $path$fileLink | Sort-Object | Get-Unique
			Edit-Content -File $path$fileLink -Mode 'clear'
			$linksCount = $links.Count
			$linkCount = 0
			foreach ($link in $links) {
				$parent = $link.Split(',')[1]
				$link = $link.Split(',')[0]
				$linkCount++
				$linkProgress = ($linkCount / $linksCount) * 100
				$linkProgress = "{0:n2}" -f $linkProgress
				Write-Progress -Activity "Requesting Link Information: $link" -Status "Complete: $linkProgress" -PercentComplete $linkProgress -CurrentOperation ' '
				if ($link) {
					try {
						$link = Format-Url -url $link
						$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing
						$lastModified = Remove-Comma -Content $request.Headers.'Last-Modified'
						$contentLength = Get-ByteSize -Size $request.Headers.'Content-Length'
						try {
							$title = $request.Content.Split('<') | Where-Object { $_.ToLower().Contains('title>') }
							$title = $title.Split('>')[1]
							$title = Remove-Comma -Content $title
							$title = Format-Readable -Content $title -Document $false
						}
						catch {
							$title = ''
						}
						$content = $link + ',' + $parent + ',' + ($request.Headers.'Content-Type'.Split(';')[0]).Split('/')[1] + ',' + $request.StatusCode + ',' + $title + ',' `
							+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
							Edit-Content -File $path$fileLink -Mode 'add' -Content $content
					}
					catch {
						Get-HttpError -e $_ -link $link -parent $parent
					}
				}
			}
		}
		else {
			$content = Get-Content -Path $path$fileLink | Sort-Object | Get-Unique
			Edit-Content -File $path$fileLink -Mode 'clear'
			foreach ($c in $content) {
				Edit-Content -File $path$fileLink -Mode 'add' -Content $c
			}
		}
	}

	if ($countDocument -eq 0) { Remove-Item -Path $path$fileDocument } else { 
		if ($requestDocInfo) {
			$links = Get-Content -Path $path$fileDocument | Sort-Object | Get-Unique
			Edit-Content -File $path$fileDocument -Mode 'clear'
			$linksCount = $links.Count
			$linkCount = 0
			foreach ($link in $links) {
				$parent = $link.Split(',')[1]
				$link = $link.Split(',')[0]
				$linkCount++
				$linkProgress = ($linkCount / $linksCount) * 100
				$linkProgress = "{0:n2}" -f $linkProgress
				Write-Progress -Activity "Requesting Document Information: $link" -Status "Complete: $linkProgress" -PercentComplete $linkProgress -CurrentOperation ' '
				if ($link) {
					$doctype = Get-DocumentType -doclink $link
					try {
						$link = Format-Url -url $link
						$request = Invoke-WebRequest $link -TimeoutSec $requestTimeout -UseBasicParsing -Method Head
						$lastModified = Remove-Comma -Content $request.Headers.'Last-Modified'
						$contentLength = Get-ByteSize -Size $request.Headers.'Content-Length'
						$title = Format-Readable -Content $link -Document $true
						$content = $link + ',' + $parent + ',' + $doctype + ',' + $request.StatusCode + ',' + $title + ',' `
							+ $lastModified + ',' + $contentLength + ',' + $request.Headers.'Content-Length'
						Edit-Content -File $path$fileDocument -Mode 'add' -Content $content
					}
					catch {
						Get-HttpError -e $_ -link $link -parent $parent
					}
				}
			}
		}
		else {
			$content = Get-Content -Path $path$fileDocument | Sort-Object | Get-Unique
			Edit-Content -File $path$fileDocument -Mode 'clear'
			foreach ($c in $content) {
				Edit-Content -File $path$fileDocument -Mode 'add' -Content $c
			}
		}
	}

	if ($countError -eq 0) {
		Remove-Item -Path $path$fileError
	}
	else {
		$content = Get-Content -Path $path$fileError | Sort-Object | Get-Unique
		Edit-Content -File $path$fileError -Mode 'clear'
		Edit-Content -File $path$fileError -Mode 'add' -Content 'URL,Error'
		foreach ($c in $content) {
			Edit-Content -File $path$fileError -Mode 'add' -Content $c
		}
	}

	if ($countScope -eq 0) {
		Remove-Item -Path $path$fileScope
	}
	else {
		$content = Get-Content -Path $path$fileScope | Sort-Object | Get-Unique
		Edit-Content -File $path$fileScope -Mode 'clear'
		Edit-Content -File $path$fileScope -Mode 'add' -Content 'URL,Parent'
		foreach ($c in $content) {
			Edit-Content -File $path$fileScope -Mode 'add' -Content $c
		}
	}

	if ($fileLink -ne 0) { $content = Get-Content -Path $path$fileLink }
	if ($countDocument -ne 0) { $content += Get-Content -Path $path$fileDocument }
	$content = $content | Sort-Object | Get-Unique
	Edit-Content -File $path$fileReport -Mode 'add' -Content 'URL,Parent,Content,HTTP Status,Description,Date Modified,Size,Byte Size'
	Edit-Content -File $path$fileReport -Mode 'add' -Content $content

	Edit-Content -File $PSScriptRoot'\master.csv' -Mode 'add' -Content $content

	$EndDate = Get-Date
	$TimeSpan = New-TimeSpan -Start $StartDate -End $EndDate
	$TimeSpan

	Edit-Content -File $path$fileLog -Mode 'add' -Content ''
	$value = 'Complete in: ' + $TimeSpan.Hours + ' hours, ' + $TimeSpan.Minutes + ' minutes, ' + $TimeSpan.Seconds + ' seconds'
	Edit-Content -File $path$fileLog -Mode 'add' -Content $value
}