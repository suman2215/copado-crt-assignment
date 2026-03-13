*** Settings ***
Library                   QWeb
Library                   GoogleAuthenticator.py    # TOTP generator using pyotp
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Variables ***
${CRT_URL}                https://eu-robotic.copado.com/
${GOOGLE_EMAIL}           ${EMPTY}    # Set via CRT execution parameters
${GOOGLE_PASSWORD}        ${EMPTY}    # Set via CRT execution parameters
${GOOGLE_TOTP_SECRET}     ${EMPTY}    # Set via CRT execution parameters (Base32 secret from Google Authenticator)

*** Keywords ***
Setup Browser
    Open Browser          about:blank    chrome
    SetConfig             DefaultTimeout    20s
    SetConfig             LineBreak         ${EMPTY}

End Suite
    Close All Browsers

Validate TOTP Secret
    [Documentation]       Validates that the TOTP secret is properly configured
    Should Not Be Empty   ${GOOGLE_TOTP_SECRET}    msg=GOOGLE_TOTP_SECRET execution parameter is not set
    ${secret_length}=     Get Length    ${GOOGLE_TOTP_SECRET}
    Should Be True        ${secret_length} >= 16    msg=TOTP secret seems too short (expected Base32 format)

*** Test Cases ***
Login To CRT With Google SSO And Authenticator 2FA
    [Documentation]       Logs into Copado Robotic Testing using Google SSO with Authenticator App 2FA.
    ...                   
    ...                   Requirements:
    ...                   - GOOGLE_EMAIL: Test Google account email
    ...                   - GOOGLE_PASSWORD: Test Google account password  
    ...                   - GOOGLE_TOTP_SECRET: Base32 secret from Google Authenticator setup
    ...                   
    ...                   This test uses pyotp library to generate time-based one-time passwords,
    ...                   simulating the Google Authenticator mobile app behavior.
    ...                   
    ...                   Flow:
    ...                   1. Navigate to CRT and click Google SSO
    ...                   2. Enter email and password
    ...                   3. Generate TOTP code using pyotp
    ...                   4. Enter generated code for 2FA verification
    ...                   5. Verify successful login to CRT
    [Tags]                Assignment2    Login    SSO    Google    2FA    Authenticator

    # Pre-validation: Ensure TOTP secret is configured
    Validate TOTP Secret
    
    # Step 1: Navigate to CRT login page
    Log                   Step 1: Navigating to CRT login page
    GoTo                  ${CRT_URL}
    VerifyText            Sign in              timeout=10s
    
    # Step 2: Initiate Google SSO login
    Log                   Step 2: Clicking Google SSO login button
    ClickText             Sign in with Google
    
    # Step 3: Wait for redirect to Google's login page
    Log                   Step 3: Waiting for Google login page
    VerifyText            Sign in              timeout=10s
    VerifyText            to continue to       timeout=5s
    
    # Step 4: Enter Google email address
    Log                   Step 4: Entering Google email: ${GOOGLE_EMAIL}
    TypeText              Email                ${GOOGLE_EMAIL}
    ClickText             Next
    
    # Step 5: Wait for password page and enter password
    Log                   Step 5: Entering Google password
    VerifyText            Welcome              timeout=10s
    TypeSecret            Enter your password  ${GOOGLE_PASSWORD}
    ClickText             Next
    
    # Step 6: Handle 2-Step Verification with Authenticator App (TOTP)
    Log                   Step 6: Checking for 2FA prompt
    ${mfa_required}=      IsText               Enter the code    timeout=10s
    
    # CRITICAL: Ensure 2FA is actually required and being used
    Should Be True        ${mfa_required}      msg=2FA was not triggered! Google account may not have 2FA enabled.
    Log                   ✓ 2FA verification required - proceeding with authenticator app
    
    # Generate TOTP code using pyotp (simulating Google Authenticator app)
    Log                   Generating TOTP code using pyotp library
    ${totp_code}=         Generate TOTP Code   ${GOOGLE_TOTP_SECRET}
    ${code_length}=       Get Length           ${totp_code}
    Should Be Equal       ${code_length}       ${6}    msg=TOTP code should be 6 digits
    Log                   ✓ Generated 6-digit TOTP code: ${totp_code}
    
    # Verify the prompt is specifically for authenticator app
    ${authenticator_prompt}=    IsText        Google Authenticator    timeout=3s
    IF    ${authenticator_prompt}
        Log               ✓ Confirmed: Google Authenticator app method detected
    END
    
    # Enter the generated TOTP code
    Log                   Entering TOTP code for 2FA verification
    TypeText              Enter the code       ${totp_code}
    ClickText             Next
    
    # Step 7: Handle "Trust this device" prompt (optional)
    Log                   Step 7: Checking for trust device prompt
    ${trust_visible}=     IsText               Don't ask again on this device    timeout=5s
    IF                    ${trust_visible}
        Log               Selecting 'Don't ask again on this device'
        ClickText         Don't ask again on this device
        ClickText         Next
    END
    
    # Step 8: Handle consent screen if it appears
    Log                   Step 8: Checking for consent screen
    ${consent_visible}=   IsText               Continue as          timeout=5s
    IF                    ${consent_visible}
        Log               Clicking consent 'Continue as' button
        ClickText         Continue as
    END
    
    # Step 9: Verify successful redirect back to CRT
    Log                   Step 9: Verifying successful login to CRT
    VerifyText            Dashboard            timeout=30s
    VerifyUrl             https://eu-robotic.copado.com/    timeout=10s
    
    # Step 10: Final verification - ensure we're logged in
    Log                   Step 10: Final authentication verification
    VerifyNoText          Sign in              timeout=5s
    
    Log                   ✓ SUCCESS: Logged in to CRT using Google SSO with Authenticator 2FA

Test TOTP Code Generation
    [Documentation]       Standalone test to verify pyotp TOTP code generation is working correctly.
    ...                   This test validates that the TOTP secret is configured and can generate codes.
    [Tags]                Assignment2    Validation    2FA    TOTP

    # Validate the secret is configured
    Validate TOTP Secret
    
    # Generate and validate TOTP code
    Log                   Testing TOTP code generation with pyotp
    ${code}=              Generate TOTP Code    ${GOOGLE_TOTP_SECRET}
    Log                   Generated TOTP code: ${code}
    
    # Verify the code format
    ${code_length}=       Get Length            ${code}
    Should Be Equal       ${code_length}        ${6}    msg=TOTP code must be exactly 6 digits
    Should Match Regexp   ${code}               ^\\d{6}$    msg=TOTP code must contain only digits
    
    # Generate again to ensure it's consistent within the 30-second window
    Sleep                 1s
    ${code2}=             Generate TOTP Code    ${GOOGLE_TOTP_SECRET}
    Should Be Equal       ${code}               ${code2}    msg=TOTP codes should be identical within 30-second window
    
    # Verify the code using pyotp's built-in verification
    ${is_valid}=          Verify TOTP Code      ${GOOGLE_TOTP_SECRET}    ${code}
    Should Be True        ${is_valid}           msg=Generated TOTP code failed verification
    
    Log                   ✓ SUCCESS: TOTP generation and verification working correctly
