"""Translate business and request errors to the documented JSON envelope."""

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException

from app.core.response import response


class ApiError(Exception):
    def __init__(self, status: int, message: str, data: dict | None = None):
        super().__init__(message)
        self.status = status
        self.message = message
        self.data = data


def unauthorized(message: str = "请先登录") -> ApiError:
    return ApiError(401, message)


def forbidden(message: str = "当前角色无权执行该操作") -> ApiError:
    return ApiError(403, message)


def setup_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def handle_business_error(_request: Request, error: ApiError):
        headers = {"WWW-Authenticate": "Bearer"} if error.status == 401 else None
        return JSONResponse(
            response(error.data, error.message, code=error.status),
            status_code=error.status,
            headers=headers,
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(_request: Request, error: RequestValidationError):
        fields = [
            {"field": ".".join(str(part) for part in item["loc"][1:]), "reason": item["type"]}
            for item in error.errors()
        ]
        return JSONResponse(
            response({"errors": fields}, "输入格式不正确，请检查各填写项", code=400),
            status_code=400,
        )

    @app.exception_handler(HTTPException)
    async def handle_http_error(_request: Request, error: HTTPException):
        messages = {404: "接口不存在", 405: "请求方法不受支持"}
        return JSONResponse(
            response(None, messages.get(error.status_code, "请求未完成"), code=error.status_code),
            status_code=error.status_code,
            headers=error.headers,
        )

    @app.exception_handler(Exception)
    async def handle_unexpected_error(_request: Request, _error: Exception):
        return JSONResponse(
            response(None, "服务暂时无法处理请求，请稍后重试", code=500),
            status_code=500,
            headers={"Cache-Control": "no-store"},
        )
