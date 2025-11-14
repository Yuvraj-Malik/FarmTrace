from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey,Float
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


# -------------------------------
# Farmer Table
# -------------------------------
class Farmer(Base):
    __tablename__ = "farmers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    phone = Column(String(20), unique=True, index=True)
    state = Column(String(100))
    district = Column(String(100))
    pincode = Column(String(10))
    password_hash = Column(String(255))
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationship
    cattle = relationship("Cattle", back_populates="owner")


# -------------------------------
# Veterinarian Table
# -------------------------------
class Veterinarian(Base):
    __tablename__ = "veterinarians"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    phone = Column(String(20), unique=True, index=True)
    clinic_state = Column(String(100))
    clinic_district = Column(String(100))
    clinic_pincode = Column(String(10))
    vet_id_url = Column(Text)  # uploaded future document
    password_hash = Column(String(255))
    created_at = Column(DateTime, default=datetime.utcnow)


# -------------------------------
# Cattle Table
# -------------------------------
class Cattle(Base):
    __tablename__ = "cattle"

    id = Column(Integer, primary_key=True, index=True)
    tag_id = Column(String, unique=True, index=True)
    breed = Column(String)
    dob = Column(DateTime)
    location = Column(String)
    owner_id = Column(Integer, ForeignKey("farmers.id"))
    status = Column(String, default="Active")  # Active, For Sale
    tx_hash = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    owner = relationship("Farmer", back_populates="cattle")
    photos = relationship("CattlePhoto", back_populates="cattle")


# -------------------------------
# Cattle Photos
# -------------------------------
class CattlePhoto(Base):
    __tablename__ = "cattle_photos"

    id = Column(Integer, primary_key=True)
    cattle_id = Column(Integer, ForeignKey("cattle.id"))
    url = Column(String)
    uploaded_at = Column(DateTime, default=datetime.utcnow)

    cattle = relationship("Cattle", back_populates="photos")


# -------------------------------
# Treatment Records
# -------------------------------
class Treatment(Base):
    __tablename__ = "treatments"

    id = Column(Integer, primary_key=True)
    cattle_id = Column(Integer, ForeignKey("cattle.id"))
    drug = Column(String)
    dosage = Column(String)
    date = Column(DateTime)
    safe_to_sell = Column(DateTime)
    hash = Column(String)

class MedicalRecord(Base):
    __tablename__ = "medical_records"

    id = Column(Integer, primary_key=True, index=True)
    cattle_id = Column(Integer, ForeignKey("cattle.id"))
    image_url = Column(String)
    diagnosis = Column(String)
    score = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow)

    cattle = relationship("Cattle")
