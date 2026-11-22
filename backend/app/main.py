"""Application entry point."""

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.core.database import ping
from app.core.exceptions import setup_exception_handlers
from app.core.response import response
from app.core.security import TOKEN_HEADER
from app.routers.auth import router
from app.services.user_service import initialize


@asynccontextmanager
async def lifespan(_app: FastAPI):
    initialize()
    yield


app = FastAPI(title="智约实验室设备预约系统", version="0.1.0", lifespan=lifespan)
setup_exception_handlers(app)
app.include_router(router)


@app.middleware("http")
async def session_headers(request: Request, call_next):
    result = await call_next(request)
    if request.url.path.startswith("/api/"):
        result.headers["Cache-Control"] = "no-store"
    if token := getattr(request.state, "next_token", None):
        result.headers[TOKEN_HEADER] = token
    return result


@app.get("/api/health", tags=["健康检查"])
def health() -> JSONResponse:
    if not ping():
        return JSONResponse(response({"status": "unavailable"}, "数据库暂不可用", code=503), status_code=503)
    return JSONResponse(response({"status": "ok", "version": app.version}))
