from fastapi import APIRouter, HTTPException
from app.schemas.user_schema import UserCreate, UserLogin, TokenResponse
from app.crud.user_crud import create_user, authenticate_user

router = APIRouter()

@router.post("/signup")
def signup(user: UserCreate):
    res = create_user(user.email, user.password, user.role)
    if not res:
        raise HTTPException(status_code=400, detail="Email already exists")
    return {"message": "User created"}

@router.post("/login", response_model=TokenResponse)
def login(user: UserLogin):
    token = authenticate_user(user.email, user.password)
    if not token:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    return {"access_token": token}
