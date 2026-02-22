from pydantic import BaseModel, EmailStr

class UserModel(BaseModel):
    email: EmailStr
    password: str
    role: str  # "parent" or "child"
    coins: int = 0
