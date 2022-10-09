import requests
import BeautifulSoup
from selenium import webdriver

# Sorry this code is a mess. lol

# driver = webdriver.Firefox()
# driver.get('https://azbomprod.azmd.gov/GLSuiteWeb/Clients/AZBOM/public/WebVerificationSearch.aspx?q=azmd&t=20220904115542')




headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'}
url = 'https://azbomprod.azmd.gov/GLSuiteWeb/Clients/AZBOM/public/WebVerificationSearch.aspx?q=azmd&t=20220904115542'
r = requests.get(url, headers=headers)
print(r)

# soup = BeautifulSoup(r.text, 'html.parser')

# soup = BeautifulSoup(r.json(), 'html.parser')


# soup = BeautifulSoup(requests.get(url, headers=headers), features="html.parser")

