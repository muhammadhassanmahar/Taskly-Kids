from bson import ObjectId
from datetime import datetime
from app.config import tasks_collection, users_collection


# ======================================================
# HELPER FUNCTIONS
# ======================================================

def safe_email(email: str) -> str:
    """Convert email to a MongoDB-safe key."""
    return email.replace(".", "_")


def convert_id(task: dict) -> dict:
    """Convert ObjectId to string for JSON serialization."""
    task["_id"] = str(task["_id"])
    return task


# ======================================================
# ADD TASK
# ======================================================

def add_task(task: str, parentEmail: str, children: list, deadline: datetime = None) -> str:
    """Add a new task with default status, stars and optional deadline."""
    status = {safe_email(child): "not_started" for child in children}
    stars = {safe_email(child): 0 for child in children}

    result = tasks_collection.insert_one({
        "task": task,
        "parentEmail": parentEmail,
        "children": children,
        "status": status,
        "stars": stars,
        "deadline": deadline,  # 🔥 NEW FIELD
        "createdAt": datetime.utcnow()
    })

    return str(result.inserted_id)


# ======================================================
# GET TASKS
# ======================================================

def get_all_tasks() -> list:
    tasks = list(tasks_collection.find())
    return [convert_id(t) for t in tasks]


def get_tasks_for_parent(parentEmail: str) -> list:
    tasks = list(tasks_collection.find({"parentEmail": parentEmail}))
    return [convert_id(t) for t in tasks]


def get_tasks_for_child(childEmail: str) -> list:
    tasks = list(tasks_collection.find({"children": {"$in": [childEmail]}}))
    return [convert_id(t) for t in tasks]


# ======================================================
# MARK PENDING (CHILD COMPLETE REQUEST)
# ======================================================

def mark_task_pending(task_id: str, childEmail: str) -> bool:
    try:
        obj_id = ObjectId(task_id)
    except Exception:
        return False

    email_key = safe_email(childEmail)

    result = tasks_collection.update_one(
        {"_id": obj_id},
        {"$set": {f"status.{email_key}": "pending"}}
    )

    return result.modified_count > 0


# ======================================================
# APPROVE TASK
# ======================================================

def approve_task(task_id: str, childEmail: str, stars: int = 5) -> bool:
    try:
        obj_id = ObjectId(task_id)
    except Exception:
        return False

    email_key = safe_email(childEmail)

    result = tasks_collection.update_one(
        {"_id": obj_id},
        {
            "$set": {
                f"status.{email_key}": "approved",
                f"stars.{email_key}": stars
            }
        }
    )

    if result.modified_count == 0:
        return False

    # Update user progress & coins
    users_collection.update_one(
        {"email": childEmail},
        {"$inc": {"progressPoints": 5, "coins": stars * 2}},
        upsert=True
    )

    return True


# ======================================================
# DECLINE TASK
# ======================================================

def decline_task(task_id: str, childEmail: str) -> bool:
    try:
        obj_id = ObjectId(task_id)
    except Exception:
        return False

    email_key = safe_email(childEmail)

    result = tasks_collection.update_one(
        {"_id": obj_id},
        {"$set": {f"status.{email_key}": "declined"}}
    )

    if result.modified_count == 0:
        return False

    # Deduct progress points
    users_collection.update_one(
        {"email": childEmail},
        {"$inc": {"progressPoints": -5}},
        upsert=True
    )

    return True


# ======================================================
# GENERIC STATUS HANDLER
# ======================================================

def mark_task_status(task_id: str, childEmail: str, status: str) -> bool:
    status = status.lower()

    if status == "pending":
        return mark_task_pending(task_id, childEmail)

    elif status == "approved":
        return approve_task(task_id, childEmail)

    elif status == "declined":
        return decline_task(task_id, childEmail)

    return False


# ======================================================
# UPDATE TASK
# ======================================================

def update_task(task_id: str, task: str = None, children: list = None, deadline: datetime = None) -> bool:
    try:
        obj_id = ObjectId(task_id)
    except Exception:
        return False

    update_data = {}

    if task is not None:
        update_data["task"] = task

    if children is not None:
        status = {safe_email(child): "not_started" for child in children}
        stars = {safe_email(child): 0 for child in children}

        update_data["children"] = children
        update_data["status"] = status
        update_data["stars"] = stars

    # 🔥 NEW: Deadline Update Support
    if deadline is not None:
        update_data["deadline"] = deadline

    if not update_data:
        return False

    result = tasks_collection.update_one(
        {"_id": obj_id},
        {"$set": update_data}
    )

    return result.modified_count > 0


# ======================================================
# DELETE TASK
# ======================================================

def delete_task(task_id: str) -> bool:
    try:
        obj_id = ObjectId(task_id)
    except Exception:
        return False

    result = tasks_collection.delete_one({"_id": obj_id})
    return result.deleted_count > 0
