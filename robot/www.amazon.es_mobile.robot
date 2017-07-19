*** Setting ***
Default Tags  chromium
Resource  chromium_iphone6.resource.robot
Suite Setup  Suite Setup
Suite Teardown  Suite Teardown
Test Timeout  1 minute

*** Test Case ***
Navigate Home
    [Documentation]  Obre el navegador cap a la pàgina d' inici
    &{bmp_opts}  Create Dictionary  captureHeaders=True
    New Har  Home
    Go To  https://www.amazon.es/
    Screenshot
