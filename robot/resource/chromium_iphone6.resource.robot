*** Settings ***
Library  Collections
Library  OperatingSystem
Library  BrowserMobProxyLibrary
Library  Selenium2Library

*** Variables ***
${BMP_HOST}  bmp
${BMP_PORT}  9090
${SELENIUM}  http://hub:4444/wd/hub
${SHOT_NUM}  0
@{TIMINGS}

*** Keywords ***
Suite Setup
    [Documentation]  Prepare environment
    #[Timeout]  30 seconds
    Register Keyword To Run On Failure  Suite Failure
    Set Selenium Implicit Wait  10 seconds
    Set Selenium Timeout  10 seconds
    Connect To Remote Server  ${BMP_HOST}  ${BMP_PORT}
    Create Proxy
    Log To Console  Using 360x640 resolution and iPhone6 User Agent
    ${capabilities}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys
    Call Method  ${capabilities}  add_argument  --user-agent\=Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25
    Call Method  ${capabilities}  add_argument  --window-size\=360,640
    ${capabilities}  Call Method  ${capabilities}  to_capabilities
    Add To Capabilities  ${capabilities}
    Log  ${capabilities}
    Create WebDriver  Remote  command_executor=${SELENIUM}  desired_capabilities=${capabilities}

Get Performance Timings
    [Timeout]  30 seconds
    ${json}  Execute Javascript  return window.performance.timing || window.webkitPerformance.timing || window.mozPerformance.timing || window.msPerformance.timing || {};
    Append To List  ${TIMINGS}  ${json}

New Har Page
    [arguments]  ${pagename}
    [Timeout]  30 seconds
    Get Performance Timings
    New Page  ${pagename}

Suite Teardown
    [Timeout]  30 seconds
    Get Performance Timings
    # ${json} will be a python dict
    ${json}  Get Har
    # Add our webtimings
    Set To Dictionary  ${json["log"]}  _webtimings=${TIMINGS}
    # Convert the dict to a json string
    ${json_string}  evaluate  json.dumps(${json})  json
    Create File  ${OUTPUT DIR}${/}file.har  ${json_string}
#    Wait For Traffic To Stop  1000  10000
    Close Proxy
    Delete All Cookies
    Close All Browsers
    Stop Local Server

Suite Failure
    [Timeout]  30 seconds
    Log Location
    Log Title
    Log Source
    Screenshot

Screenshot
    [Timeout]  30 seconds
    ${SHOT_NUM}  Evaluate  ${SHOT_NUM} + 1
    Set Global Variable  ${SHOT_NUM}
    Capture Page Screenshot  ${OUTPUT DIR}${/}Screenshots${/}${SUITE NAME}-${SHOT_NUM}-${TEST NAME}.png
