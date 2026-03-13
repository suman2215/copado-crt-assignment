"""
Google Authenticator TOTP Library for Copado Robotic Testing
=====================================================

This library generates Time-based One-Time Passwords (TOTP) compatible with
Google Authenticator app using the pyotp library.

Requirements:
    - pyotp>=2.9.0

Usage in Robot Framework:
    Library    GoogleAuthenticator.py
    
    ${code}=    Generate TOTP Code    ${GOOGLE_TOTP_SECRET}
    ${valid}=   Verify TOTP Code      ${GOOGLE_TOTP_SECRET}    ${code}

Author: Copado Robotic Testing
Version: 1.0
"""

import pyotp
import time
import sys
from datetime import datetime


class GoogleAuthenticator:
    """Robot Framework library for generating Google Authenticator TOTP codes."""
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0'
    
    def __init__(self):
        """Initialize the Google Authenticator library."""
        print("GoogleAuthenticator library initialized (using pyotp)")
    
    def generate_totp_code(self, secret):
        """
        Generates a TOTP (Time-based One-Time Password) code using pyotp.
        
        This simulates the Google Authenticator mobile app behavior by generating
        a 6-digit code that changes every 30 seconds.
        
        Args:
            secret (str): Base32-encoded secret key from Google Authenticator setup.
                         Example: 'JBSWY3DPEHPK3PXP'
        
        Returns:
            str: 6-digit TOTP code (e.g., '123456')
        
        Raises:
            Exception: If the secret is invalid or code generation fails
        
        Example:
            | ${code}= | Generate TOTP Code | ${GOOGLE_TOTP_SECRET} |
            | Log | Generated code: ${code} |
        """
        try:
            # Validate secret is not empty
            if not secret or secret.strip() == '':
                raise ValueError("TOTP secret cannot be empty")
            
            # Remove any whitespace from secret
            secret = secret.strip().replace(' ', '')
            
            # Create TOTP object
            totp = pyotp.TOTP(secret)
            
            # Generate current code
            code = totp.now()
            
            # Calculate time remaining for this code
            time_remaining = 30 - (int(time.time()) % 30)
            current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            # Log detailed information
            print(f"[GoogleAuthenticator] TOTP Code Generated")
            print(f"  - Code: {code}")
            print(f"  - Valid for: {time_remaining} seconds")
            print(f"  - Generated at: {current_time}")
            print(f"  - Secret length: {len(secret)} characters")
            
            # Validate code format
            if len(code) != 6:
                raise ValueError(f"Generated code has invalid length: {len(code)} (expected 6)")
            
            if not code.isdigit():
                raise ValueError(f"Generated code is not numeric: {code}")
            
            return code
            
        except ValueError as ve:
            error_msg = f"TOTP generation failed - Invalid secret: {str(ve)}"
            print(f"[ERROR] {error_msg}", file=sys.stderr)
            raise Exception(error_msg)
            
        except Exception as e:
            error_msg = f"TOTP generation failed: {str(e)}"
            print(f"[ERROR] {error_msg}", file=sys.stderr)
            raise Exception(error_msg)
    
    def verify_totp_code(self, secret, code):
        """
        Verifies if a TOTP code is valid for the given secret.
        
        This is useful for testing and validation purposes.
        
        Args:
            secret (str): Base32-encoded secret key
            code (str): 6-digit TOTP code to verify
        
        Returns:
            bool: True if code is valid, False otherwise
        
        Example:
            | ${is_valid}= | Verify TOTP Code | ${GOOGLE_TOTP_SECRET} | 123456 |
            | Should Be True | ${is_valid} |
        """
        try:
            secret = secret.strip().replace(' ', '')
            totp = pyotp.TOTP(secret)
            is_valid = totp.verify(code, valid_window=1)  # Allow 1 window (±30s)
            
            print(f"[GoogleAuthenticator] TOTP Verification")
            print(f"  - Code: {code}")
            print(f"  - Valid: {is_valid}")
            
            return is_valid
            
        except Exception as e:
            error_msg = f"TOTP verification failed: {str(e)}"
            print(f"[ERROR] {error_msg}", file=sys.stderr)
            raise Exception(error_msg)
    
    def get_totp_provisioning_uri(self, secret, account_name, issuer_name='Google'):
        """
        Generates a provisioning URI for QR code generation.
        
        This can be used to set up the authenticator app.
        
        Args:
            secret (str): Base32-encoded secret key
            account_name (str): Account identifier (usually email)
            issuer_name (str): Service name (default: 'Google')
        
        Returns:
            str: Provisioning URI (otpauth://totp/...)
        
        Example:
            | ${uri}= | Get TOTP Provisioning URI | ${SECRET} | test@example.com | Google |
            | Log | ${uri} |
        """
        try:
            totp = pyotp.TOTP(secret)
            uri = totp.provisioning_uri(name=account_name, issuer_name=issuer_name)
            
            print(f"[GoogleAuthenticator] Provisioning URI Generated")
            print(f"  - Account: {account_name}")
            print(f"  - Issuer: {issuer_name}")
            print(f"  - URI: {uri}")
            
            return uri
            
        except Exception as e:
            error_msg = f"Provisioning URI generation failed: {str(e)}"
            print(f"[ERROR] {error_msg}", file=sys.stderr)
            raise Exception(error_msg)


# Make the library importable as a module
if __name__ == '__main__':
    # Test the library directly
    print("Testing GoogleAuthenticator library...")
    ga = GoogleAuthenticator()
    
    # Example secret (replace with your actual secret for testing)
    test_secret = "JBSWY3DPEHPK3PXP"
    
    code = ga.generate_totp_code(test_secret)
    print(f"\nGenerated TOTP code: {code}")
    
    is_valid = ga.verify_totp_code(test_secret, code)
    print(f"Code verification: {is_valid}")
