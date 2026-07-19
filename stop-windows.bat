@echo off
chcp 936 >nul

echo ====================================
echo 停止 ReActLab 服务
echo ====================================
echo.

REM 停止 FastAPI 主服务
echo [1/4] 正在停止 FastAPI 服务...
taskkill /FI "WINDOWTITLE eq ReActLab API*" /F >nul 2>&1
if errorlevel 1 (
    echo [提示] 未找到正在运行的 FastAPI 服务。
) else (
    echo [成功] FastAPI 服务已停止。
)
echo.

REM 停止 CLS MCP 服务
echo [2/4] 正在停止 CLS MCP 服务...
taskkill /FI "WINDOWTITLE eq CLS MCP Server*" /F >nul 2>&1
if errorlevel 1 (
    echo [提示] 未找到正在运行的 CLS MCP 服务。
) else (
    echo [成功] CLS MCP 服务已停止。
)
echo.

REM 停止 Monitor MCP 服务
echo [3/4] 正在停止 Monitor MCP 服务...
taskkill /FI "WINDOWTITLE eq Monitor MCP Server*" /F >nul 2>&1
if errorlevel 1 (
    echo [提示] 未找到正在运行的 Monitor MCP 服务。
) else (
    echo [成功] Monitor MCP 服务已停止。
)
echo.

REM 停止 Milvus 相关 Docker 容器
echo [4/4] 正在停止 Milvus 相关容器...
docker ps --format "{{.Names}}" | findstr "milvus" >nul 2>&1
if not errorlevel 1 (
    docker compose -f vector-database.yml down
    if errorlevel 1 (
        echo [错误] Docker 容器停止失败。
    ) else (
        echo [成功] Milvus、etcd、MinIO 和 Attu 已停止。
    )
) else (
    echo [提示] 未发现正在运行的 Milvus 容器。
)
echo.

echo ====================================
echo ReActLab 服务停止完成
echo ====================================
echo.
echo 提示：
echo   当前操作不会删除数据库数据。
echo   如果确实需要同时删除 Docker 卷，请谨慎执行：
echo   docker compose -f vector-database.yml down -v
echo.
pause