# Pulling From Arizona Medical Board

Need to create a web-scraper that can pull a list of all the DO physicians and MD physicians with their corresponding practice address. Additionally, I want to grab their self-reported specialty, what medical school they went to, and their graduation date

**How Will I Do This**
https://drive.google.com/drive/u/1/folders/1hUp-1FAK0f_ndZ-zWvDHQL_j0DnZuzBN

1. Get a program to go to the Arizona Medical Board website
   https://azbomprod.azmd.gov/GLSuiteWeb/Clients/AZBOM/public/WebVerificationSearch.aspx?q=azmd&t=20220903084023

2. There will be two separate searches. First one click the Medical Doctor Button and then press search

3. Iteratively go through each one and grab the following data

- Practice Address
- Self-reported Specialty
- Medical School Alma Mater
- Graduate Date for Medical School

4. Make another request but this time for osteopathic physicians. I will be grabbing the same data.\

**Python Packages Needed**

- requests?
- need to do more research on this
