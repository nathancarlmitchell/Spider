$url = 'https://chfs.ky.gov/Pages/sitemap.aspx'
$path =  'C:\Users\Owner\Documents\Spider\'
$file = 'spider.xlsx'

$curl = curl $url
$links = $curl.Links.href

Set-Content -Path $path+$file -Value 'CHFS Spider'

foreach ($link in $links) {

    $content = Get-Content -Path $path+$file
    $contentlink = 'chfs.ky.gov' + $link

    if (!$content.Equals($contentlink)) {

        if ($link.StartsWith('/')) {

            $url = 'chfs.ky.gov' + $link
            $curl = curl $url
            $links = $curl.Links.href

            foreach ($link in $links) {

                if ($link.StartsWith('/')) {
                    $result = 'chfs.ky.gov' + $link
                    $result

                    Add-Content -Path $path+$file -Value $result
                }
            }
        } else { 'Duplicate' }
    }
}

#check for unique values
#ends with 'pdf'