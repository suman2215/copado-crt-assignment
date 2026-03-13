import smtplib
from email.mime.text import MIMEText


def send_email_via_smtp(sender, recipient, subject, body, host, port, password):
    """Sends an email using SMTP with TLS authentication."""
    msg = MIMEText(body, "plain")
    msg["From"] = sender
    msg["To"] = recipient
    msg["Subject"] = subject

    with smtplib.SMTP(host, int(port)) as server:
        server.starttls()
        server.login(sender, password)
        server.sendmail(sender, recipient, msg.as_string())
