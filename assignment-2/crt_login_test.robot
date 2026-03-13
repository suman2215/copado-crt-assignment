*** Settings ***
Library                   QWeb
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Variables ***
${CRT_URL}                https://eu-robotic.copado.com/
${GOOGLE_EMAIL}           ${EMPTY}    # Set via CRT execution parameters
${GOOGLE_PASSWORD}        ${EMPTY}    # Set via CRT execution parameters

*** Keywords ***
Setup Browser
    Open Browser          about:blank    chrome
    SetConfig             DefaultTimeout    20s
    SetConfig             LineBreak         ${EMPTY}

End Suite
    Close All Browsers

*** Test Cases ***
Login To CRT With Google SSO
    [Documentation]       Logs into Copado Robotic Testing using Google SSO authentication.
    ...                   Google credentials are stored securely in CRT execution parameters (vault).
    ...                   Test handles redirect to Google, multi-step login, and redirect back to CRT.
    [Tags]                Assignment2    Login    SSO    Google

    # Step 1: Navigate to CRT login page
    GoTo                  ${CRT_URL}
    
    # Step 2: Click Google SSO login button
    ClickText             Sign in with Google
    
    # Step 3: Wait for redirect to Google's login page
    VerifyText            Sign in              timeout=10s
    
    # Step 4: Enter Google email address
    TypeText              Email                ${GOOGLE_EMAIL}
    ClickText             Next
    
    # Step 5: Wait for password page and enter password
    VerifyText            Welcome              timeout=5s
    TypeSecret            Enter your password  ${GOOGLE_PASSWORD}
    ClickText             Next
    
    # Step 6: Handle potential 2-Step Verification (if enabled)
    # Note: This assumes you're using a test account without 2FA
    # If 2FA is required, additional steps would be needed here
    
    # Step 7: Handle "Continue as" or consent screen (if appears)
    ${consent_visible}=   IsText               Continue as          timeout=3s
    IF                    ${consent_visible}
        ClickText         Continue as
    END
    
    # Step 8: Verify successful redirect back to CRT and login
    VerifyText            Dashboard            timeout=30s
    VerifyUrl             https://eu-robotic.copado.com/    timeout=10s
