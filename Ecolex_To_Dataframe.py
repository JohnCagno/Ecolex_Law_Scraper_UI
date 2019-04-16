# -*- coding: utf-8 -*-
"""
Created on Thu Mar 14 12:21:52 2019

@author: Johnny
"""
#import dependencies

from bs4 import BeautifulSoup # For HTML parsing
from urllib.request import urlopen # Website connections
import pandas as pd # For converting results to a dataframe and bar chart plots
import urllib.parse

#%%

def create_law_df(countries):
    """
    Takes a list of countries and returns a dataframe of fishery laws
    Countries: a comma separated list of countries written in the correct syntax
    
    """
    def text_cleaner(website):

        try:
            site = urlopen(website).read() # Connect to the job posting
            law_page = BeautifulSoup(site,"lxml") # Get the html from the site   
            law_row = []  
    
            dd = law_page.find_all("dd")
            link = []
    
            for links in law_page.find_all("dd"):
                if links.find("a") != None:
                    x = links.a['href']
                    link.append(x)
    
            title = law_page.find("title").text
            country = dd[0].text
            date = law_page.find("span",attrs = {"class": "sr-date sr-help"}).text
            abstract = law_page.find("p",attrs = {"class": "abstract"}).text
            sitelink = website
            full_text_link = link[1]
    
            if dd[2].text == " Regulation":
                document_type = dd[2].text
            elif dd[2].text == " Legislation":
                document_type = dd[2].text
            else: document_type = dd[1].text
    
    
            law_row.append({'Title': title,
                            'Country': country,
                            'Date': date[0:4],
                            'Document Type': document_type,
                            'Abstract': abstract,
                            'Law Link': sitelink,
                            'Full Text Link': full_text_link
                     })
    
            return law_row
        
        except Exception: 
            pass
        
    #Enter and encode search terms
    
    law_urls = []
    
    for i in range(len(countries)):
    
        search = str(countries[i]) 
        encSrch = urllib.parse.quote(search)
        srchURL = "https://www.ecolex.org/result/?=" + encSrch +"&xsubjects=Fisheries&xcountry=" + encSrch + "&page="
        base_url = 'https://www.ecolex.org'
        print('Getting country ' + str(countries[i])) 
    
        for i in range(1,30): # Loop through 30 search result pages
            start_num = str(i) # For page number
            current_page = ''.join([srchURL + start_num]) #create link
            html_page = urlopen(current_page).read() # Get the page
            page_obj = BeautifulSoup(html_page) # Locate all of the law links
            job_link_area = page_obj.find(id = 'search-form') #identify correct section of page
            job_link_area = job_link_area.find_all('a') #retrieve relevant html      
            job_URLS = [link.get('href') for link in job_link_area] # Get all urls 
            job_URLS = [(base_url + str(link)) for link in job_URLS]  
            job_URLS = [links for links in job_URLS if "details" in links] #remove irrelevant URLs
            job_URLS = [links for links in job_URLS if "legislation" in links]
            law_urls.append(job_URLS) #append to law list
    
    print('Done with collecting laws!')   
    law_urls = [item for sublist in law_urls for item in sublist] #collapse list
    
    law_dict = [] # Store all our descriptions in this list

    for j in range(0,len(law_urls)):
        final_description = text_cleaner(law_urls[j])
        if final_description: # So that we only append when the website was accessed correctly
            law_dict.append(final_description)

    frame = [item for sublist in law_dict for item in sublist] #collapse list
    dataframe = pd.DataFrame(frame) #create dataframe
    dataframe = dataframe [["Title", "Country", "Date", "Document Type", "Abstract", "Law Link", "Full Text Link"]] #reorder columns of dataframe
    print("Done parsing laws!")
    
    return dataframe

#%%

countries = []

Num_countries = int(input("How many countries would you like to search? "))

for i in range(0,Num_countries):
    a = i+1
    country = str(input("Please enter country " + str(a) + ": "))
    countries.append(country)


df = create_law_df(countries)


#%%

