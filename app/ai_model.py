import numpy as np
import cv2
import os
from keras.models import load_model


MODEL_PATH = os.getenv("MODEL_PATH", "models/dummy_model.h5")

# For hackathon: either use a tiny model or a placeholder function.
# If you don't have a model yet, we provide a dummy predictor.
model = None
if os.path.exists(MODEL_PATH):
    model = load_model(MODEL_PATH)

def preprocess_image_bytes(image_bytes, target_size=(128,128)):
    arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    img = cv2.resize(img, target_size)
    img = img.astype("float32") / 255.0
    img = np.expand_dims(img, axis=0)
    return img

def predict_infection(image_bytes):
    if model is None:
        # Dummy heuristic: use average brightness to return pseudo-score
        arr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        score = float(np.mean(gray) / 255.0)  # 0..1
        return {"score": score, "label": "suspicious" if score < 0.5 else "healthy", "note": "dummy model"}
    else:
        x = preprocess_image_bytes(image_bytes)
        pred = model.predict(x)[0][0]  # adapt based on model output
        return {"score": float(pred), "label": "suspicious" if pred>0.5 else "healthy"}
