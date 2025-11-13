from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# -------------------------
# Farmer Schemas
# -------------------------
class FarmerSignup(BaseModel):
    name: str
    phone: str
    state: str
    district: str
    pincode: str
    password: str


class FarmerLogin(BaseModel):
    phone: str
    password: str


# -------------------------
# Veterinarian Schemas
# -------------------------
class VetSignup(BaseModel):
    name: str
    phone: str
    clinic_state: str
    clinic_district: str
    clinic_pincode: str
    vet_id_url: str
    password: str


class VetLogin(BaseModel):
    phone: str
    password: str


# -------------------------
# Cattle Schemas
# -------------------------
class CattleCreate(BaseModel):
    tag_id: str
    breed: Optional[str]
    dob: Optional[datetime]
    location: Optional[str]


class CattleOut(BaseModel):
    id: int
    tag_id: str
    breed: Optional[str]
    location: Optional[str]
    status: str
    tx_hash: Optional[str]

    class Config:
        from_attributes = True

