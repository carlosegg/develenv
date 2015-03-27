#!/usr/bin/env python2.6
from selenium import webdriver
from PIL import Image
import sys
import os

def main(argv=sys.argv):
    #browser = webdriver.Firefox()
    output_file=sys.argv[2]
    
    if len(sys.argv) == 4:
        element_id=sys.argv[3]
    else:
        element_id=None
    browser = webdriver.Remote(command_executor="http://localhost:4445/wd/hub",desired_capabilities={ "browserName": "firefox" })
    browser.set_window_size(2048,10)
    browser.get(sys.argv[1])
    browser.save_screenshot(output_file)
    # now that we have the preliminary stuff out of the way time to get that image :D
    if element_id != None:
        element=browser.find_element_by_id(element_id)
        location = element.location
        size = element.size
    browser.quit()
    
    if element_id != None:
        im = Image.open(output_file) # uses PIL library to open image in memory
        left = location['x']
        top = location['y']
        right = location['x'] + size['width']
        bottom = location['y'] + size['height']
        im = im.crop((left, top, right, bottom)) # defines crop points
        im.save(output_file) # saves new cropped image

if __name__ == "__main__":
    main()