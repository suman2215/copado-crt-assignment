*** Settings ***
Library                   QWeb
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Variables ***
# Username can be stored here; password MUST be set as a CRT execution parameter
${CRT_URL}                https://eu-robotic.copado.com/
${CRT_USERNAME}           None
${CRT_PASSWORD}           None

*** Keywords ***
Setup Browser
    Open Browser          about:blank    chrome
    SetConfig             DefaultTimeout    20s
    SetConfig             LineBreak         ${EMPTY}

End Suite
    Close All Browsers

*** Test Cases ***
Login To Copado Robotic Testing
    [Documentation]       Logs into Copado Robotic Testing using QWords.
    ...                   Password is stored in CRT execution parameters (vault), not hardcoded.
    [Tags]                Assignment2    Login

    # Step 1: Navigate to CRT login page
    GoTo                  ${CRT_URL}

    # Step 2: Click "Sign in with email" to reveal email/password form
    ClickText             Sign in with email    timeout=30s

    # Step 3: Enter credentials and log in
    TypeText              Email           ${CRT_USERNAME}
    TypeText              Password        ${CRT_PASSWORD}
    ClickText             Login

    # Step 4: Verify successful login by checking for dashboard elements
    VerifyText            Dashboard       timeout=30s
