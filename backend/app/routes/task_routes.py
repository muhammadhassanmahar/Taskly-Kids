from fastapi import APIRouter, HTTPException, status
from app.schemas.task_schema import TaskCreate, TaskComplete, TaskUpdate
from app.crud.task_crud import (
    add_task,
    get_tasks_for_child,
    get_tasks_for_parent,
    get_all_tasks,
    mark_task_status,
    update_task,
    delete_task,
    approve_task,
    decline_task
)

# ⚠️ IMPORTANT:
# prefix already defined in main.py → app.include_router(..., prefix="/tasks")
router = APIRouter(tags=["Tasks"])


# ======================================================
# ADD TASK
# ======================================================

@router.post("/add", status_code=status.HTTP_201_CREATED)
def create_task(task: TaskCreate):
    task_id = add_task(
        task=task.task,
        parentEmail=task.parentEmail,
        children=task.children,
        deadline=task.deadline   # 🔥 NEW (Deadline Support)
    )

    if not task_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task creation failed"
        )

    return {
        "success": True,
        "message": "Task added successfully",
        "task_id": task_id
    }


# ======================================================
# GET TASKS FOR CHILD
# ======================================================

@router.get("/child/{childEmail}", status_code=status.HTTP_200_OK)
def fetch_child_tasks(childEmail: str):
    tasks = get_tasks_for_child(childEmail)
    return tasks or []


# ======================================================
# GET TASKS FOR PARENT
# ======================================================

@router.get("/parent/{parentEmail}", status_code=status.HTTP_200_OK)
def fetch_parent_tasks(parentEmail: str):
    tasks = get_tasks_for_parent(parentEmail)
    return tasks or []


# ======================================================
# GET ALL TASKS
# ======================================================

@router.get("/all", status_code=status.HTTP_200_OK)
def fetch_all_tasks():
    return get_all_tasks() or []


# ======================================================
# UPDATE TASK
# ======================================================

@router.put("/update/{task_id}", status_code=status.HTTP_200_OK)
def edit_task(task_id: str, task: TaskUpdate):
    success = update_task(
        task_id=task_id,
        task=task.task,
        children=task.children,
        deadline=task.deadline   # 🔥 NEW (Deadline Update Support)
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task update failed"
        )

    return {
        "success": True,
        "message": "Task updated successfully"
    }


# ======================================================
# DELETE TASK
# ======================================================

@router.delete("/delete/{task_id}", status_code=status.HTTP_200_OK)
def remove_task(task_id: str):
    success = delete_task(task_id)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task deletion failed"
        )

    return {
        "success": True,
        "message": "Task deleted successfully"
    }


# ======================================================
# CHILD MARK COMPLETE (PENDING)
# ======================================================

@router.post("/complete", status_code=status.HTTP_200_OK)
def complete_task(task: TaskComplete):
    success = mark_task_status(
        task_id=task.task_id,
        childEmail=task.childEmail,
        status="pending"
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to mark task as pending"
        )

    return {
        "success": True,
        "message": "Task sent for approval"
    }


# ======================================================
# PARENT APPROVE TASK
# ======================================================

@router.post("/approve", status_code=status.HTTP_200_OK)
def approve(task: TaskComplete):
    success = approve_task(
        task_id=task.task_id,
        childEmail=task.childEmail
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Approval failed"
        )

    return {
        "success": True,
        "message": "Task approved successfully"
    }


# ======================================================
# PARENT DECLINE TASK
# ======================================================

@router.post("/decline", status_code=status.HTTP_200_OK)
def decline(task: TaskComplete):
    success = decline_task(
        task_id=task.task_id,
        childEmail=task.childEmail
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Decline failed"
        )

    return {
        "success": True,
        "message": "Task declined successfully"
    }
