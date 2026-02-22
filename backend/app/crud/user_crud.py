from app.config import users_collection
from app.utils.auth_utils import hash_password, verify_password, create_access_token

def create_user(email: str, password: str, role: str):
    if users_collection.find_one({"email": email}):
        return None
    hashed = hash_password(password)
    users_collection.insert_one({"email": email, "password": hashed, "role": role, "coins": 0})
    return True

def authenticate_user(email: str, password: str):
    user = users_collection.find_one({"email": email})
    if not user:
        return None
    if not verify_password(password, user["password"]):
        return None
    token = create_access_token({"sub": email})
    return token
