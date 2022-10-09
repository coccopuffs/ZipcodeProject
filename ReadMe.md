# Goal of the Project

Compare the average income of the zipcode in which the different physician degrees (MD vs DO) practice in. So basically, seeing if the degree has an impact on the locations in which you can practice in.

# Pulling From Arizona Medical Board

Need to create a web-scraper that can pull a list of all the DO physicians and MD physicians with their corresponding practice address. Additionally, I want to grab their self-reported specialty, what medical school they went to, and their graduation date

**How Will I Do This**

1. Get a program to go to the Arizona Medical Board website
   https://azbomprod.azmd.gov/GLSuiteWeb/Clients/AZBOM/public/WebVerificationSearch.aspx?q=azmd&t=20220903084023

2. We will be using the specialty Search Button. The only fields you need to enter is MD when searching for MDs and DO when searching for DOs.
TLDR: Search Medical Doctor Using the Specialty Search Button

3. Iteratively go through each entry and grab the following data

- Practice Address
- Self-reported Specialty
- Medical School Alma Mater
- Graduate Date for Medical School

4. Repeat this process for all MD and DO physicians 

**Python Packages Needed**

This is just a guess

- requests
- selenium
- BeautifulSoup
