from fastapi import FastAPI
from app.database import init_db
from app.routes import auth_routes, farmer_routes, vet_routes,cattle_routes

app = FastAPI()


@app.on_event("startup")
def startup_event():
    """Initialize database tables on server startup."""
    init_db()


# ROUTES
app.include_router(auth_routes.router, prefix="/auth", tags=["Authentication"])
app.include_router(farmer_routes.router, prefix="/farmers", tags=["Farmers"])
app.include_router(vet_routes.router, prefix="/vets", tags=["Veterinarians"])
app.include_router(cattle_routes.router, prefix="/cattle", tags=["Cattle"])



@app.get("/")
def root():
    return {"message": "FarmTrace Backend Running!"}
