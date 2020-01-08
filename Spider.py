# -*- coding: utf-8 -*-
"""
Created on Tue Jan  7 16:08:13 2020

@author: nathan.mitchell
"""

import time
import requests
from lxml import html
from multiprocessing.pool import Pool

def make_request(url):
    """Makes a web request, return links on the page."""
    try:
        request = requests.get(url, timeout=5)
        webpage = html.fromstring(request.content)
        links = webpage.xpath('//a/@href')
        return links
    except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
        links = ''
        print('Timout occurred: ' + url)
    return links

def format_url(url):
    # remove / # , from end
    url = url.replace('http://', '')
    url = url.replace('https://', '')
    url = url.replace(',', '%2C')
    return url

def append_links(links, url, scope):
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
    docs = ['pdf', 'xls', 'xlsx', 'xlsm', 'xlt', 'xltm', 'doc', 'docm',    \
            'docx', 'dot', 'dotx', 'ppt', 'pptm', 'pptx', 'ppsx','txt',    \
            'zip', 'rar', 'csv', 'kmz', 'shp', 'cat', 'dat', 'dgn', 'alg', \
            'prj', 'rtf', 'pub', 'xml', 'gpx','mp3', 'mp4', 'avi', 'mov',  \
            'wav', 'wmv', 'wma', 'jpg', 'jpeg', 'png', 'gif', 'tif', 'bmp']
    document = False
    for doc in docs:
        if doc in url:
            True
            
    return document        

def main():
    start = time.time()
    
    #combine url and scope then add http://
    url = 'http://technology.ky.gov'
    scope = format_url(url)
    unique = True
    depth = 0
    new_links = [url]
    links = []
    result = []
    """Loop until no new links are found."""
    while unique:
        unique = False
        with Pool(16) as p:
            links += p.map(make_request, new_links)
            
        new_links = []
        """ links[0] ? """
        for link in links:
            link = append_links(link, url, scope)
            for l in link:
                """If link is new"""
                if l not in result:
                    result.append(l)
                    l = 'http://' + l
                    """If link is not a document"""
                    if not document_check(l):
                        new_links.append(l)
                    unique = True
                print(l)
            print(len(result))
            
        result = list(dict.fromkeys(result))
        
        depth += 1
        print(depth)
    
    """Write results to CSV file"""
    f = open("result.csv", "w")
    for x in result:
        x = format_url(x)
        f.write(x + "\n")
    f.close()
        
    print(len(result))    
    print("Execution time = {0:.5f}".format(time.time() - start))
    
    return

if __name__ == '__main__':
    main()