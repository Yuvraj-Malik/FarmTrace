from sqlalchemy.orm import Session
from app import models
from app.auth_utils import hash_password
from passlib.context import CryptContext
import app.models as models
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ---------------- FARMER ----------------
def get_farmer_by_phone(db: Session, phone: str):
    return db.query(models.Farmer).filter(models.Farmer.phone == phone).first()


def create_farmer(db: Session, data):
    farmer = models.Farmer(
        name=data.name,
        phone=data.phone,
        state=data.state,
        district=data.district,
        pincode=data.pincode,
        password_hash=hash_password(data.password),
    )
    db.add(farmer)
    db.commit()
    db.refresh(farmer)
    return farmer


# ---------------- VET ----------------
def get_vet_by_phone(db: Session, phone: str):
    return db.query(models.Veterinarian).filter(models.Veterinarian.phone == phone).first()


def create_vet(db: Session, data):
    vet = models.Veterinarian(
        name=data.name,
        phone=data.phone,
        clinic_state=data.clinic_state,
        clinic_district=data.clinic_district,
        clinic_pincode=data.clinic_pincode,
        password_hash=hash_password(data.password),
    )
    db.add(vet)
    db.commit()
    db.refresh(vet)
    return vet

# ---------------------------
# Password helpers
# ---------------------------
def hash_password(password: str):
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str):
    return pwd_context.verify(plain, hashed)


# ---------------------------
# FARMER CRUD
# ---------------------------
def create_farmer(db: Session, data):
    farmer = models.Farmer(
        name=data.name,
        phone=data.phone,
        state=data.state,
        district=data.district,
        pincode=data.pincode,
        password_hash=hash_password(data.password)
    )
    db.add(farmer)
    db.commit()
    db.refresh(farmer)
    return farmer


def get_farmer_by_phone(db: Session, phone: str):
    return db.query(models.Farmer).filter(models.Farmer.phone == phone).first()


# ---------------------------
# VETERINARIAN CRUD
# ---------------------------
def create_vet(db: Session, data, vet_id_url: str = None):
    vet = models.Veterinarian(
        name=data.name,
        phone=data.phone,
        clinic_state=data.clinic_state,
        clinic_district=data.clinic_district,
        clinic_pincode=data.clinic_pincode,
        vet_id_url=vet_id_url,
        password_hash=hash_password(data.password)
    )
    db.add(vet)
    db.commit()
    db.refresh(vet)
    return vet


def get_vet_by_phone(db: Session, phone: str):
    return db.query(models.Veterinarian).filter(models.Veterinarian.phone == phone).first()


# ---------------------------
# CATTLE CRUD
# ---------------------------
def create_cattle(db: Session, farmer_id: int, data):
    cattle = models.Cattle(
        tag_id=data.tag_id,
        breed=data.breed,
        dob=data.dob,
        location=data.location,
        owner_id=farmer_id
    )
    db.add(cattle)
    db.commit()
    db.refresh(cattle)
    return cattle


def get_cattle_by_owner(db: Session, farmer_id: int):
    return db.query(models.Cattle).filter(models.Cattle.owner_id == farmer_id).all()


def list_cattle_for_sale(db: Session):
    return db.query(models.Cattle).filter(models.Cattle.status == "For Sale").all()
