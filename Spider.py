# -*- coding: utf-8 -*-
"""
Created on Mon Dec 23 12:59:55 2019

@author: nathan.mitchell
"""

from lxml import html
import requests
import os

def remove_file(filename):
    if os.path.exists(filename):
        os.remove(filename)
        
def format_url():
    # remove / from end
    return

def check_file(link):
    with open('links.txt') as file:
        if link in file.read():
            return True
        else:
            return False

def main():
    url = 'https://technology.ky.gov'
    page = requests.get(url)
    webpage = html.fromstring(page.content)
    
    links = webpage.xpath('//a/@href')

    remove_file('temp.txt')
    file_links = open('links.txt', "a")
    file_temp = open('temp.txt', "a")
    
    for link in links:
        if link.startswith('/'):
            link = url + link
            
            if not check_file(link):
                print('New link found: ' + link)
                file_links.write(link + '\n')
                file_temp.write(link + '\n')
            else:
                print('Duplicate: ' + link)
        else:
            if url in link:
                print(link)
            else:
                print('out of scope')

    file_links.close()
    file_temp.close()

if __name__ == "__main__":
    main()