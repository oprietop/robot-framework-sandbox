*** Settings ***
Documentation  Selenium Grid + BMP
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary
Library  SeleniumLibrary

*** Variables ***
${BMP_HOST}  bmp
${BMP_PORT}  9090
${SELENIUM}  http://hub:4444/wd/hub
${SHOT_NUM}  0
@{TIMINGS}

*** Keywords ***
#
# Setup, Teardown and Failure keywords
#

Suite Setup
  Register Keyword To Run On Failure  Suite Failure
  Set Selenium Implicit Wait  0.2 seconds
  Set Selenium Timeout  30 seconds
  &{caps}=  Set Capabilities
  Create Webdriver  Remote  command_executor=${SELENIUM}  desired_capabilities=${caps}
  New Har  Home

Suite Teardown
  Get Har  file.har
  Delete All Cookies
  Close All Browsers
  Close Proxy

Suite Failure
  Log Location
  Log Title
  Log Source
  Screenshot

#
# Helper keywords
#

Screenshot
  ${SHOT_NUM}  Evaluate  ${SHOT_NUM} + 1
  Set Global Variable  ${SHOT_NUM}
  Capture Page Screenshot  ${OUTPUT DIR}${/}Screenshots${/}${SUITE NAME}-${SHOT_NUM}-${TEST NAME}.png

Set Capabilities
  [Documentation]  Set the options for the selenium Driver
  ${port}=  Create Proxy
  &{proxy}=  Create Dictionary
  ...  proxyType  MANUAL
  ...  sslProxy  ${BMP_HOST}:${port}
  ...  httpProxy  ${BMP_HOST}:${port}
  @{chromeopts}=  Create List  headless  disable-gpu  window-size\=1200x800
  &{chromeargs}=  Create Dictionary  args=${chromeopts}
  &{caps}=  Create Dictionary  browserName=chrome  platform=ANY  proxy=${proxy}  goog:chromeOptions=${chromeargs}
  Log  Selenium capabilities: ${caps}
  [return]  ${caps}

Create Proxy
  [Documentation]  Get a BMP port for our test
  Create Session  bmp  http://${BMP_HOST}:${BMP_PORT}
  ${resp}=  Get Request  bmp  /proxy
  Should Be Equal As Strings  ${resp.status_code}  200
  Log  BMP Sessions: ${resp.text} [${resp.status_code}]
  &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
  &{data}=  Create Dictionary  trustAllServers=True
  ${resp}=  Post Request  bmp  /proxy  data=${data}  headers=${headers}
  Should Be Equal As Strings  ${resp.status_code}  200
  Log  ${resp.text} [${resp.status_code}]
  ${port}=  Get From Dictionary  ${resp.json()}  port
  Log  New BMP port: ${port} [${resp.status_code}]
  Set Global Variable  ${port}
  [return]  ${port}

New Har
  [Documentation]  Name and initialize a Har
  [arguments]  ${pagename}
  &{data}=  Create Dictionary  initialPageRef=${pagename}
  ${resp}=  Put Request  bmp  /proxy/${port}/har  params=${data}
  #Should Be Equal As Strings  ${resp.status_code}  204
  Log  New Har (${pagename}) [${resp.status_code}]

New Har Page
  [Documentation]  Name and add a new har page
  [arguments]  ${pagename}
  Get Performance Timings
  &{data}=  Create Dictionary  pageRef=${pagename}
  ${resp}=  Put Request  bmp  /proxy/${port}/har/pageRef  params=${data}
  Should Be Equal As Strings  ${resp.status_code}  200
  Log  New Har Page (${pagename}) [${resp.status_code}]

Get Har
  [Documentation]  Serialize the current har
  [arguments]  ${harname}
  Get Performance Timings
  ${resp}=  Get Request  bmp  /proxy/${port}/har
  Should Be Equal As Strings  ${resp.status_code}  200
  ${length}  Get Length  ${resp.text}
  Log  Json length: ${length} [${resp.status_code}]
  &{dic}=  Evaluate  ${resp.text}
  Set To Dictionary  ${dic["log"]}  _webtimings=${TIMINGS}
  ${json}  evaluate  json.dumps(${dic})  json
  Create File  ${OUTPUT DIR}${/}${harname}  ${json}

Get Performance Timings
  [Documentation]  Ask javascript for the performance timings
  &{json}=  Execute Javascript  return window.performance.timing || window.webkitPerformance.timing || window.mozPerformance.timing || window.msPerformance.timing || {};
  Append To List  ${TIMINGS}  ${json}

Close Proxy
  ${resp}=  Delete Request  bmp  /proxy/${port}
  Should Be Equal As Strings  ${resp.status_code}  200
  Log  Closed proxy at ${port} [${resp.status_code}]
