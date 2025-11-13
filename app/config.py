from dotenv import load_dotenv
import os
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
SECRET_KEY = os.getenv("SECRET_KEY")
CLOUD_NAME = os.getenv("CLOUDINARY_CLOUD_NAME")
CLOUD_KEY = os.getenv("CLOUDINARY_API_KEY")
CLOUD_SECRET = os.getenv("CLOUDINARY_API_SECRET")
NODE_API_URL = os.getenv("NODE_API_URL")
