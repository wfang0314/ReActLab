"""FastAPI 搴旂敤鍏ュ彛

涓诲簲鐢ㄧ▼搴忥紝閰嶇疆璺敱銆佷腑闂翠欢銆侀潤鎬佹枃浠剁瓑
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from contextlib import asynccontextmanager
import os

from app.config import config
from loguru import logger
from app.api import chat, health, file, aiops
from app.core.milvus_client import milvus_manager


@asynccontextmanager
async def lifespan(app: FastAPI):
    """搴旂敤鐢熷懡鍛ㄦ湡绠＄悊"""
    # 鍚姩鏃舵墽琛?
    logger.info("=" * 60)
    logger.info(f"[START] {config.app_name} v{config.app_version} starting...")
    logger.info(f"[ENV] mode: {"dev" if config.debug else "prod"}")
    logger.info(f"[LISTEN] http://{config.host}:{config.port}")
    logger.info(f"[LISTEN] http://{config.host}:{config.port}")
    
    # 杩炴帴 Milvus锛堝彲閫夛紝澶辫触涓嶉樆姝㈡湇鍔″惎鍔級
    logger.info("[LIFECYCLE] ...")
    try:
        milvus_manager.connect()
        logger.info("[LIFECYCLE] ...")
    except Exception as e:
        logger.info("[LIFECYCLE] ...")
        logger.info("[LIFECYCLE] ...")
    
    logger.info("=" * 60)
    
    yield
    
    # 鍏抽棴鏃舵墽琛?
    logger.info("[LIFECYCLE] ...")
    milvus_manager.close()
    logger.info("[LIFECYCLE] ...")


# 鍒涘缓 FastAPI 搴旂敤
app = FastAPI(
    title=config.app_name,
    version=config.app_version,
    description="鍩轰簬 LangChain 鐨凮psMind AIOps 鏅鸿兘杩愮淮绯荤粺",
    lifespan=lifespan
)

# 閰嶇疆 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 鐢熶骇鐜搴旇闄愬埗鍏蜂綋鍩熷悕
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="/api", tags=["health"])
app.include_router(chat.router, prefix="/api", tags=["chat"])
app.include_router(file.router, prefix="/api", tags=["file"])
app.include_router(aiops.router, prefix="/api", tags=["aiops"])

# 鎸傝浇闈欐€佹枃浠?
static_dir = "static"
app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/")
async def root():
    """杩斿洖棣栭〉"""
    index_path = os.path.join(static_dir, "index.html")
    if os.path.exists(index_path):
        return FileResponse(index_path)
    return {
        "message": f"Welcome to {config.app_name} API",
        "version": config.app_version,
        "docs": "/docs"
    }


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host=config.host,
        port=config.port,
        reload=config.debug,
        log_level="info"
    )
