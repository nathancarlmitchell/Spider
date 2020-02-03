# Spider
## Recursively search for unique URLs from a webpage
### Powershell
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
