from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app import models, schemas
from datetime import timedelta
from app.auth_utils import hash_password, verify_password, create_access_token

router = APIRouter(tags=["Authentication"])


# Dependency for DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# -----------------------------
# Farmer Signup
# -----------------------------
@router.post("/farmer/signup")
def farmer_signup(data: schemas.FarmerSignup, db: Session = Depends(get_db)):
    # Check if phone already exists
    existing = db.query(models.Farmer).filter(models.Farmer.phone == data.phone).first()
    if existing:
        raise HTTPException(status_code=400, detail="Phone number already registered")

    hashed_pw = hash_password(data.password)

    new_farmer = models.Farmer(
        name=data.name,
        phone=data.phone,
        state=data.state,
        district=data.district,
        pincode=data.pincode,
        password_hash=hashed_pw
    )

    db.add(new_farmer)
    db.commit()
    db.refresh(new_farmer)

    token = create_access_token({"id": new_farmer.id, "role": "farmer"})

    return {
        "id": new_farmer.id,
        "name": new_farmer.name,
        "phone": new_farmer.phone,
        "role": "farmer",
        "token": token
    }


# -----------------------------
# Farmer Login
# -----------------------------
@router.post("/farmer/login")
def farmer_login(data: schemas.FarmerLogin, db: Session = Depends(get_db)):
    farmer = db.query(models.Farmer).filter(models.Farmer.phone == data.phone).first()

    if not farmer:
        raise HTTPException(status_code=404, detail="Farmer not found")

    if not verify_password(data.password, farmer.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect password")

    token = create_access_token({"id": farmer.id, "role": "farmer"})

    return {
        "id": farmer.id,
        "name": farmer.name,
        "phone": farmer.phone,
        "role": "farmer",
        "token": token
    }


# -----------------------------
# Veterinarian Signup
# -----------------------------
@router.post("/vet/signup")
def vet_signup(
    name: str,
    phone: str,
    password: str,
    clinic_state: str,
    clinic_district: str,
    clinic_pincode: str,
    vet_id_url: str,  # will be uploaded to Cloudinary by frontend
    db: Session = Depends(get_db)
):
    existing = db.query(models.Veterinarian).filter(models.Veterinarian.phone == phone).first()
    if existing:
        raise HTTPException(status_code=400, detail="Phone number already registered")

    hashed_pw = hash_password(password)

    new_vet = models.Veterinarian(
        name=name,
        phone=phone,
        clinic_state=clinic_state,
        clinic_district=clinic_district,
        clinic_pincode=clinic_pincode,
        vet_id_url=vet_id_url,
        password_hash=hashed_pw
    )

    db.add(new_vet)
    db.commit()
    db.refresh(new_vet)

    token = create_access_token({"id": new_vet.id, "role": "vet"})

    return {
        "id": new_vet.id,
        "name": new_vet.name,
        "phone": new_vet.phone,
        "role": "vet",
        "token": token
    }


# -----------------------------
# Veterinarian Login
# -----------------------------
@router.post("/vet/login")
def vet_login(data: schemas.VetLogin, db: Session = Depends(get_db)):
    vet = db.query(models.Veterinarian).filter(models.Veterinarian.phone == data.phone).first()

    if not vet:
        raise HTTPException(status_code=404, detail="Veterinarian not found")

    if not verify_password(data.password, vet.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect password")

    token = create_access_token({"id": vet.id, "role": "vet"})

    return {
        "id": vet.id,
        "name": vet.name,
        "phone": vet.phone,
        "role": "vet",
        "token": token
    }
