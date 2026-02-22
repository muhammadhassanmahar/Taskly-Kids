from app.config import tasks_collection, users_collection


# 🔐 helper
def safe_email(email: str) -> str:
    return email.replace(".", "_")


# ================= GET SINGLE CHILD PROGRESS =================
def get_child_progress(childEmail: str):
    email_key = safe_email(childEmail)

    tasks = list(tasks_collection.find({
        "children": {"$in": [childEmail]}
    }))

    total_tasks = len(tasks)
    approved = 0
    pending = 0
    declined = 0
    not_started = 0

    for task in tasks:
        status_map = task.get("status", {})
        status = status_map.get(email_key, "not_started")

        if status == "approved":
            approved += 1
        elif status == "pending":
            pending += 1
        elif status == "declined":
            declined += 1
        else:
            not_started += 1

    percentage = 0
    if total_tasks > 0:
        percentage = int((approved / total_tasks) * 100)

    # get progress points from user
    user = users_collection.find_one({"email": childEmail})
    progress_points = user.get("progressPoints", 0) if user else 0
    coins = user.get("coins", 0) if user else 0

    return {
        "childEmail": childEmail,
        "totalTasks": total_tasks,
        "approved": approved,
        "pending": pending,
        "declined": declined,
        "notStarted": not_started,
        "progressPercentage": percentage,
        "progressPoints": progress_points,
        "coins": coins
    }


# ================= GET ALL CHILDREN PROGRESS (FOR PARENT) =================
def get_all_children_progress(parentEmail: str):
    tasks = list(tasks_collection.find({
        "parentEmail": parentEmail
    }))

    children_set = set()

    for task in tasks:
        for child in task.get("children", []):
            children_set.add(child)

    result = []

    for child in children_set:
        progress_data = get_child_progress(child)
        result.append(progress_data)

    return result
