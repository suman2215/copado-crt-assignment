#
# Test asset originally created using Copado QEditor.
#

*** Settings ***

Library    QWeb

*** Test Cases ***

Implement a login test that carries our login to Copado Robotic Testing using your own
credentials.

    OpenBrowser    https://eu-robotic.copado.com/    chrome

*** Keywords ***

Click On Google SSO
    [Documentation]    Click on Google SSO
    ClickText          Sign in with Google


