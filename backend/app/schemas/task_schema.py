from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime


# ======================================================
# CREATE TASK
# ======================================================

class TaskCreate(BaseModel):
    task: str
    parentEmail: EmailStr
    children: List[EmailStr]
    deadline: Optional[datetime] = None   # 🔥 NEW FIELD


# ======================================================
# UPDATE TASK
# ======================================================

class TaskUpdate(BaseModel):
    task: Optional[str] = None
    children: Optional[List[EmailStr]] = None
    deadline: Optional[datetime] = None   # 🔥 NEW FIELD


# ======================================================
# COMPLETE / APPROVE / DECLINE TASK
# ======================================================

class TaskComplete(BaseModel):
    task_id: str
    childEmail: EmailStr
