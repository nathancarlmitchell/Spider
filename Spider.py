# -*- coding: utf-8 -*-
"""
Created on Tue Jan  7 16:08:13 2020

@author: nathan.mitchell
"""

import time
import requests
from lxml import html
from multiprocessing.pool import Pool
#from util import replace_right


def replace_right(source, target, replacement, replacements=None):
    # >>> replace_right("asd.asd.asd.", ".", ". -", 1)
    # 'asd.asd.asd. -'
    return replacement.join(source.rsplit(target, replacements))

def make_request(url):
    """Makes a web request, return links on the page."""
    try:
        request = requests.get(url, timeout=5)
    except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
        request = []
        print('Timout occurred: ' + url)
    return request


def format_url(url):
    url = url.replace('http://', '')
    url = url.replace('https://', '')
    url = url.replace(',', '%2C')
    url = url.split('#')[0]
    url = url.split('?')[0]
    if url.endswith('/'):
        url = replace_right(url, '/', '', 1)
    return url


def append_links(links, url, scope):
    """Format links from web request, prepend domain."""
    results = []
    for link in links:
        link = format_url(link)
        if link.startswith('/'):
            link = url + link
            link = format_url(link)
            results.append(link)
            print('New link: ' + link)
        else:
            if scope in link:
                results.append(link)
                print('New link: ' + link)
            else:
                print('out of scope: ' + link)
                
    results = list(dict.fromkeys(results))
    return results


def document_check(url):
    """Check if file extension is in a URL."""
    docs = ['.pdf', '.xls', '.xlsx', '.xlsm', '.xlt', '.xltm', '.doc', '.docm',    
            '.docx', '.dot', '.dotx', '.ppt', '.pptm', '.pptx', '.ppsx','.txt',    
            '.zip', '.rar', '.csv', '.kmz', '.shp', '.cat', '.dat', '.dgn', '.alg', 
            '.prj', '.rtf', '.pub', '.xml', '.gpx','.mp3', '.mp4', '.avi', '.mov',  
            '.wav', '.wmv', '.wma', '.jpg', '.jpeg', '.png', '.gif', '.tif', '.bmp']
    document = False
    for doc in docs:
        if doc in url:
            True
            
    return document        


def main():
    start = time.time()
    url = 'https://project-open-data.cio.gov/'
    url = 'https://' + format_url(url)
    scope = format_url(url)
    unique = True
    depth = 0
    new_links = [url]
    links = []
    result = []
    
    """Loop until no new links are found."""
    while unique:
        
        unique = False
        new_links = list(dict.fromkeys(new_links)) 
        
        """Create a process pool and make the web request."""
        with Pool(16) as p:
            requests = p.map(make_request, new_links)
            
        new_links = []
        for request in requests:
            if request:
                try:
                    webpage = html.fromstring(request.content)
                    links = webpage.xpath('//a/@href')
                    links = list(dict.fromkeys(links))
                    """Check if link is new and append to results."""
                    links = append_links(links, url, scope)
                    for link in links:
                        """If link is new"""
                        if link not in result:
                            unique = True
                            result.append(link)
                            link = 'http://' + link
                            """If link is not a document"""
                            if not document_check(link):
                                new_links.append(link)
                except:
                    pass
                        
        result = list(dict.fromkeys(result))            
        depth += 1
        print(depth)
        print(len(result))
        print(len(new_links))
    
    """Write results to CSV file"""
    f = open("result.csv", "w", encoding='utf-8')
    for x in result:
        x = format_url(x)
        # UnicodeEncodeError: 'charmap' codec can't encode character '\u03b2' in position 48: character maps to <undefined>
        f.write(x + "\n")
    f.close()
        
    print(len(result))    
    print("Execution time = {0:.5f}".format(time.time() - start))
    
    return


if __name__ == '__main__':
    main()