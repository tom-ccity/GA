*** Settings ***
Documentation               This is a demo for Cinemaworld.co.uk
Library                     Selenium2Library
Library                     Lib/proxy.py  WITH NAME  ProxyHandler

Suite Setup                 Start Browser
Suite Teardown              Close Browser
      
      
*** Variables ***
${PAGE_URL}                 https://www.cineworld.co.uk/ 
${BROWSER}                  Firefox
${BROWSERMOB_PATH}          /Users/tomdom/Downloads/browsermob-proxy-2.1.4/bin/browsermob-proxy
${PATTERN}                  'https://www.google-analytics.com'
${ACTIVE_POSTER_XPATH}      div[@class="tab-pane collapsed active"]//div[@aria-expanded="true"]/div[@class="poster-container"]

      
*** Keywords ***
Start Browser
  [Documentation]         Start FF browser

  Set Selenium Implicit Wait  10

  ${server}=     ProxyHandler.Start Server  ${BROWSERMOB_PATH}
  Set Suite Variable    ${server}    ${server}
  
  ${proxy}=     ProxyHandler.Create Proxy  ${server}
  Set Suite Variable    ${proxy}    ${proxy}

  ${profile}=   ProxyHandler.Set Profile  ${proxy}

  Create Webdriver        ${BROWSER}    firefox_profile=${profile}
      
Close Browser
   Close All Browsers
   ProxyHandler.Stop Server  ${server}
      
*** Test Cases ***
Entering Cineworld Website
   [Documentation]     Components should be properly loaded
   [Tags]  Website
   ProxyHandler.Start Har  ${proxy}  Cineworld
   Go to                   ${PAGE_URL}
   Wait Until Page Contains Element  xpath://section[@class="quickbook-component"]
   Element Should Be Enabled         xpath://button[@data-automation-id="searchByCinema"]
   Element Should Be Enabled         xpath://button[@data-automation-id="searchByFilm"]
   Element Should Be Enabled         xpath://div[@data-automation-id="selectCinema"]
   Page Should Contain Element       xpath://a[@id="nowBooking_tab"]
   Page Should Contain Element       xpath://a[@id="comingSoon_tab"]

Expanding Movie List
   [Documentation]  Expanding should show more movies
   [Tags]  Website
   Page Should Contain Element       xpath://div[@class="poster-grid"]
   ${before}=     Get Element Count  xpath://${ACTIVE_POSTER_XPATH}
   Page Should Contain Element       xpath://img[@alt="Show more films"]
   Click Element                     xpath://img[@alt="Show more films"]
   ${after}=      Get Element Count  xpath://${ACTIVE_POSTER_XPATH}
   Should Be True   ${after} > ${before}

Browsing Coming Soon List
   [Documentation]  Some posters should be located here
   [Tags]  Website
   Page Should Contain Element       xpath://div[@class="poster-grid"]
   Click Element                     xpath://a[@id="comingSoon_tab"]
   ${coming}=     Get Element Count  xpath://${ACTIVE_POSTER_XPATH}
   Should Be True   ${coming} > 0

Check Google Analytics
   [Documentation]  GA requests printed in log info
   [Tags]  Analytics
   ProxyHandler.Check Har  ${proxy}  ${PATTERN}
   