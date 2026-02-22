from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime


class TaskModel(BaseModel):
    task: str
    parentEmail: str
    children: List[str]
    status: Dict[str, bool]      # {childEmail: True/False}
    stars: Dict[str, int]        # {childEmail: 0-5}

    # 🔥 NEW FIELD (Deadline Feature)
    deadline: Optional[datetime] = None   # Task due date & time
