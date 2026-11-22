"""The JSON envelope shared by the API and the desktop client."""

from typing import Any


def response(data: Any = None, message: str = "成功", *, code: int = 200) -> dict:
    return {"code": code, "message": message, "data": data}
