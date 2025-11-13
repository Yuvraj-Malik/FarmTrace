import cloudinary
import cloudinary.uploader
from app.config import CLOUD_NAME, CLOUD_KEY, CLOUD_SECRET

cloudinary.config(
    cloud_name=CLOUD_NAME,
    api_key=CLOUD_KEY,
    api_secret=CLOUD_SECRET,
    secure=True
)

def upload_file(file_obj, folder="farmtrace"):
    # file_obj should be a file-like object (UploadedFile.file)
    result = cloudinary.uploader.upload(file_obj, folder=folder, use_filename=True, unique_filename=False)
    return result.get("secure_url")
