*** Settings ***
Library                   QWeb
Library                   MailClientLibrary
Library                   String
Library                   Collections
Suite Setup               Setup Browser
Suite Teardown            End Suite

*** Variables ***
${SMTP_HOST}              smtp.gmail.com
${SMTP_SSL_PORT}          465
${IMAP_HOST}              imap.gmail.com
${IMAP_SSL_PORT}          993
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
    [Documentation]       Sends an email via Gmail SMTP using MailClientLibrary.
    ...                   Gmail App Password must be set as a CRT execution parameter.
    [Tags]                Assignment4    Gmail    Send

    # Step 1: Configure SMTP server
    Set Smtp Server Address    ${SMTP_HOST}
    Set Smtp Ssl Port          ${SMTP_SSL_PORT}
    Set Smtp Username And Password    ${GMAIL_USER}    ${GMAIL_APP_PASSWORD}

    # Step 2: Send the email
    Send Mail
    ...    senderMail=${GMAIL_USER}
    ...    receiverMail=${GMAIL_RECIPIENT}
    ...    subject=${EMAIL_SUBJECT}
    ...    text=${EMAIL_BODY}
    ...    useSsl=${True}

    Log    Email sent successfully via SMTP

Verify Email Received In Inbox Via IMAP
    [Documentation]       Verifies the sent email appears in Gmail inbox using IMAP.
    ...                   Uses MailClientLibrary for server-side verification.
    [Tags]                Assignment4    Gmail    Verify

    # Step 1: Configure IMAP server
    Set Imap Server Address    ${IMAP_HOST}
    Set Imap Ssl Port          ${IMAP_SSL_PORT}
    Set Imap Username And Password    ${GMAIL_USER}    ${GMAIL_APP_PASSWORD}

    # Step 2: Open the email by subject and get raw MIME content
    ${mail_content}=      Open Imap Mail By Subject    ${EMAIL_SUBJECT}    useSsl=${True}

    # Step 3: Verify email body contains expected content
    Should Contain        ${mail_content}    automated test email

    # Step 4: Extract URLs from the email body
    ${links}=             Evaluate    re.findall(r'https?://[^\\s<>"\\\\]+', '''${mail_content}''')    re
    # Remove duplicates while preserving order
    ${links}=             Evaluate    list(dict.fromkeys($links))
    Log                   Found links: ${links}

    # Step 5: Open all URLs from the email in the browser
    FOR    ${link}    IN    @{links}
        GoTo              ${link}
        Sleep             3s
    END
