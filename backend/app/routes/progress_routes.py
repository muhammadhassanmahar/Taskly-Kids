from fastapi import APIRouter, HTTPException
from app.crud.progress_crud import (
    get_child_progress,
    get_all_children_progress
)

router = APIRouter()


# ================= GET SINGLE CHILD PROGRESS =================
@router.get("/child/{childEmail}")
def fetch_child_progress(childEmail: str):
    try:
        data = get_child_progress(childEmail)
        return data
    except Exception:
        raise HTTPException(
            status_code=400,
            detail="Failed to fetch child progress"
        )


# ================= GET ALL CHILDREN PROGRESS (FOR PARENT) =================
@router.get("/parent/{parentEmail}")
def fetch_all_children_progress(parentEmail: str):
    try:
        data = get_all_children_progress(parentEmail)
        return data
    except Exception:
        raise HTTPException(
            status_code=400,
            detail="Failed to fetch children progress"
        )
