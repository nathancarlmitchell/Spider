$url = 'https://chfs.ky.gov/Pages/sitemap.aspx'

$curl = curl $url

$links = $curl.Links.href

Set-Content -Path 'c:\users\nathan.mitchell\documents\chfsspider.txt' -Value 'CHFS Spider'

foreach ($link in $links) {

    if ($link.StartsWith('/')) {

        $url = 'chfs.ky.gov' + $link

        $curl = curl $url

        $links = $curl.Links.href

        foreach ($link in $links) {

            if ($link.StartsWith('/')) {

                $result = 'chfs.ky.gov' + $link

                $result

                Add-Content 'c:\users\nathan.mitchell\documents\chfsspider.txt' -Value $result

            }

        }

    }

}

#check for unique values
#ends with 'pdf'