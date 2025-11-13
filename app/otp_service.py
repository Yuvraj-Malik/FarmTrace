from twilio.rest import Client
import os
import random
from datetime import datetime, timedelta

# store OTP temporarily in memory
otp_store = {}

account_sid = os.getenv("TWILIO_ACCOUNT_SID")
auth_token = os.getenv("TWILIO_AUTH_TOKEN")
twilio_phone = os.getenv("TWILIO_PHONE")

client = Client(account_sid, auth_token)

def generate_otp():
    return str(random.randint(100000, 999999))

def send_otp(phone):
    otp = generate_otp()
    otp_store[phone] = {
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=5)
    }

    message = client.messages.create(
        body=f"Your FarmTrace OTP is {otp}",
        from_=twilio_phone,
        to=phone
    )

    return True

def verify_otp(phone, otp):
    if phone not in otp_store:
        return False

    entry = otp_store[phone]

    if entry["otp"] != otp:
        return False

    if datetime.utcnow() > entry["expires_at"]:
        return False

    del otp_store[phone]
    return True
