# Spider
## Recursively search for unique URLs from a webpage
### Powershell
##### Arguments
args[0] = $domain - The target search domain.
<br>
args[1] = $maxDepth - The maximum number of search loops.
<br>
args[2] = $requestTimeout - Request link timeout in seconds.
<br>
args[3] = $requestLinkInfo - Performs an additional web request to gain details about each web URL.
<br>
args[4] = $requestDocInfo - Performs an additional web request to gain details about each document URL.
<br>
args[5] = $logOutOfScope - Log links found that are outside the target domain.
##### Usage
```
(cmd)
powershell.exe -file spider.ps1 domain.test.com

# To scan multiple domains
(powershell)
foreach ($domain in $domains) { powershell -file spider.ps1 $domain 10 7 y y n }
```
Generates a CSV report containing:
<br>
<b>
Domain, URL, Parent, Content Type, HTTP Status, Content Description, Date Modified, File Size
</b>
<br>
### Python
In progress.<br>
Uses multithreading for increased performance.
