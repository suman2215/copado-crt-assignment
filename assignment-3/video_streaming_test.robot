*** Settings ***
Library                   QWeb
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Variables ***
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

Login To CRT
    [Documentation]       Reusable login keyword for CRT
    GoTo                  ${CRT_URL}
    ClickText             Sign in with email    timeout=30s
    TypeText              Email           ${CRT_USERNAME}
    TypeText              Password        ${CRT_PASSWORD}
    ClickText             Login
    VerifyText            Dashboard       timeout=30s

Switch To Video Stream Window
    [Documentation]       Switches to the window whose title contains "Video Stream".
    SwitchWindow          NEW             timeout=5s
    ${title}=             GetTitle
    Should Contain        ${title}        Video Stream

Enable Video Streaming If Needed
    [Documentation]       Ensures Video Streaming is Enabled in config.
    ...                   Clicks Enabled and tries Save. If already enabled, clicks Cancel.
    ScrollText            Video Streaming and Recording    timeout=10s
    ClickText             Enabled         anchor=Video Streaming and Recording    timeout=20s
    ${save_ok}=           RunKeywordAndReturnStatus
    ...                   ClickText    Save    timeout=5s
    IF    not ${save_ok}
        ClickText         Cancel          timeout=10s
    END

*** Test Cases ***
Enable Video Streaming And Verify It Starts
    [Documentation]       Logs into CRT, enables video streaming in config,
    ...                   runs the test job with Open Video Stream,
    ...                   and verifies the video streaming window opens.
    [Tags]                Assignment3    VideoStreaming    E2E

    # Step 1: Log into Copado Robotic Testing
    Login To CRT

    # Step 2: Navigate to Test Jobs
    ClickText             Test Jobs       timeout=30s

    # Step 3: Click on the test job name to open its detail page
    ClickText             Copado Assignment    timeout=20s

    # Step 4: Open Configuration and enable Video Streaming
    ClickText             Configuration   timeout=20s
    Enable Video Streaming If Needed

    # Step 5: Close the configuration panel by refreshing and navigating back
    ClickText             Test Jobs       timeout=30s
    ClickText             Copado Assignment    timeout=20s

    # Step 6: Click Run Test Job, select Open Video Stream, and Run Now
    ClickText             Run Test Job    timeout=30s
    ClickText             Open Video Stream    timeout=20s
    ClickText             Run Now         timeout=20s

    # Step 7: Wait for streaming window to open and verify it
    Wait Until Keyword Succeeds    120s    5s    Switch To Video Stream Window
    LogScreenshot
