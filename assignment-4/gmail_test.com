*** Settings ***
Library                   QWeb
Library                   ImapLibrary2
Library                   String
Library                   Collections
Library                   SmtpKeywords.py
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Variables ***
${GMAIL_USER}             sumanchouhan0313@gmail.com 
${GMAIL_RECIPIENT}        sumanchouhan0313@gmail.com
${SMTP_HOST}              smtp.gmail.com
${SMTP_PORT}              587
${IMAP_HOST}              imap.gmail.com
${IMAP_PORT}              993
${EMAIL_SUBJECT}          CRT Test Email - Automated Verification
${EMAIL_BODY}             This is an automated test email sent from Copado Robotic Testing. Visit https://eu-robotic.copado.com/ and https://qentinelqi.github.io/shop/ for more details.

*** Keywords ***
Setup Browser
    Open Browser          about:blank    chrome
    SetConfig             DefaultTimeout    20s
    SetConfig             LineBreak         ${EMPTY}

End Suite
    Close All Browsers

*** Test Cases ***
Send Email Via SMTP
    [Documentation]       Sends an email via Gmail SMTP using App Password.
    ...                   Gmail App Password must be set as a CRT execution parameter.
    [Tags]                Assignment4    Gmail    Send

    # Step 1: Send email using SMTP (no browser login needed)
    Send Email Via Smtp
    ...    sender=${GMAIL_USER}
    ...    recipient=${GMAIL_RECIPIENT}
    ...    subject=${EMAIL_SUBJECT}
    ...    body=${EMAIL_BODY}
    ...    host=${SMTP_HOST}
    ...    port=${SMTP_PORT}
    ...    password=${GMAIL_APP_PASSWORD}

    Log    Email sent successfully via SMTP

Verify Email Received In Inbox Via IMAP
    [Documentation]       Verifies the sent email appears in Gmail inbox using IMAP.
    ...                   Uses ImapLibrary2 for server-side verification.
    [Tags]                Assignment4    Gmail    Verify

    # Step 1: Connect to Gmail via IMAP
    Open Mailbox          host=${IMAP_HOST}
    ...                   user=${GMAIL_USER}
    ...                   password=${GMAIL_APP_PASSWORD}
    ...                   is_secure=True
    ...                   port=${IMAP_PORT}

    # Step 2: Wait for the email with matching subject
    ${email_index}=       Wait For Email
    ...                   subject=${EMAIL_SUBJECT}
    ...                   timeout=120

    # Step 3: Verify email body contains expected content
    ${body}=              Get Email Body    ${email_index}
    Should Contain        ${body}    automated test email

    # Step 4: Extract links from the email
    ${links}=             Get Links From Email    ${email_index}
    Log                   Found links: ${links}

    # Step 5: Close mailbox
    Close Mailbox

    # Step 6: Open all URLs from the email in the browser
    FOR    ${link}    IN    @{links}
        GoTo              ${link}
        Sleep             2s
    END
