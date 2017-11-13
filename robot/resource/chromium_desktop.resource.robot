*** Settings ***
Library  Collections
Library  OperatingSystem
Library  BrowserMobProxyLibrary
Library  SeleniumLibrary

*** Variables ***
${BMP_HOST}  bmp
${BMP_PORT}  9090
${SELENIUM}  http://hub:4444/wd/hub
${SHOT_NUM}  0
@{TIMINGS}

*** Keywords ***
Suite Setup
    [Documentation]  Prepare environment
    Register Keyword To Run On Failure  Suite Failure
    Set Selenium Implicit Wait  10 seconds
    Set Selenium Timeout  10 seconds
    Connect To Remote Server  ${BMP_HOST}  ${BMP_PORT}
    Create Proxy
    ${capabilities}  Evaluate  selenium.webdriver.DesiredCapabilities.CHROME  selenium
    Add To Capabilities  ${capabilities}
    Log  ${capabilities}
    Create WebDriver  Remote  command_executor=${SELENIUM}  desired_capabilities=${capabilities}

Get Performance Timings
    ${json}  Execute Javascript  return window.performance.timing || window.webkitPerformance.timing || window.mozPerformance.timing || window.msPerformance.timing || {};
    Append To List  ${TIMINGS}  ${json}

New Har Page
    [arguments]  ${pagename}
    Get Performance Timings
    New Page  ${pagename}

Suite Teardown
    Get Performance Timings
    ${json}  Get Har
    Set To Dictionary  ${json["log"]}  _webtimings=${TIMINGS}
    ${json_string}  evaluate  json.dumps(${json})  json
    Create File  ${OUTPUT DIR}${/}file.har  ${json_string}
    Close Proxy
    Delete All Cookies
    Close All Browsers
    Stop Local Server

Suite Failure
    Log Location
    Log Title
    Log Source
    Screenshot

Screenshot
    ${SHOT_NUM}  Evaluate  ${SHOT_NUM} + 1
    Set Global Variable  ${SHOT_NUM}
    Capture Page Screenshot  ${OUTPUT DIR}${/}Screenshots${/}${SUITE NAME}-${SHOT_NUM}-${TEST NAME}.png
