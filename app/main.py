from fastapi import FastAPI
from app.database import init_db
from app.routes import auth_routes,cattle_routes
from fastapi.openapi.utils import get_openapi

app = FastAPI()

@app.on_event("startup")
def startup_event():
    """Initialize database tables on server startup."""
    init_db()


# ROUTES
app.include_router(auth_routes.router)
app.include_router(cattle_routes.router)



@app.get("/")
def root():
    return {"message": "FarmTrace Backend Running!"}
