@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

echo ====================================
echo 启动 ReActLab 服务
echo ====================================
echo.

REM 检查 uv；如果不存在则使用 pip
echo [1/8] 检查依赖管理工具...
where uv >nul 2>&1
if errorlevel 1 (
    echo [提示] 未检测到 uv，将使用 pip 安装依赖。
    echo [提示] 如需安装 uv，可执行：pip install uv
    set USE_UV=0
) else (
    echo [成功] 已检测到 uv。
    set USE_UV=1
)
echo.

REM 检查 Python 版本配置
echo [2/8] 检查 Python 配置...
if exist .python-version (
    set /p PYTHON_VERSION=<.python-version
    echo [信息] 当前配置的 Python 版本：!PYTHON_VERSION!

    REM 如果配置为 Python 3.10，则更新为 3.13
    echo !PYTHON_VERSION! | findstr /C:"3.10" >nul
    if not errorlevel 1 (
        echo [提示] Python 3.10 不符合当前项目配置，正在修改为 3.13...
        echo 3.13> .python-version
        echo [成功] 已将 Python 版本配置修改为 3.13。
    )
) else (
    echo [提示] 未找到 .python-version，正在创建...
    echo 3.13> .python-version
    echo [成功] 已创建 .python-version。
)
echo.

REM 创建或更新虚拟环境及依赖
echo [3/8] 检查虚拟环境和项目依赖...
if exist .venv\Scripts\python.exe (
    echo [信息] 已找到虚拟环境，正在更新依赖...

    if "!USE_UV!"=="1" (
        uv sync
        if errorlevel 1 (
            echo [警告] uv sync 执行失败，改用 pip 安装依赖...
            .venv\Scripts\python.exe -m pip install -e .
            if errorlevel 1 (
                echo [错误] 项目依赖安装失败。
                pause
                exit /b 1
            )
        ) else (
            echo [成功] uv 依赖同步完成。
        )
    ) else (
        echo [信息] 正在使用 pip 安装项目依赖...
        .venv\Scripts\python.exe -m pip install -e .
        if errorlevel 1 (
            echo [错误] 项目依赖安装失败。
            pause
            exit /b 1
        )
    )
) else (
    echo [信息] 未找到虚拟环境，正在创建...

    if "!USE_UV!"=="1" (
        echo [信息] 正在尝试使用 uv 创建环境并同步依赖...
        uv sync
        if not errorlevel 1 (
            echo [成功] uv 已创建环境并同步依赖。
            goto :venv_created
        )
        echo [警告] uv sync 执行失败，改用 Python venv。
    )

    echo [信息] 正在创建 Python 虚拟环境...
    python -m venv .venv
    if errorlevel 1 (
        echo [错误] 虚拟环境创建失败。
        echo [提示] 请确认已经安装 Python 3.11、3.12 或 3.13。
        pause
        exit /b 1
    )

    echo [信息] 正在升级 pip 并安装项目依赖...
    .venv\Scripts\python.exe -m pip install --upgrade pip
    .venv\Scripts\python.exe -m pip install -e .
    if errorlevel 1 (
        echo [错误] 项目依赖安装失败。
        pause
        exit /b 1
    )
    echo [成功] 虚拟环境和项目依赖准备完成。
)

:venv_created
echo [成功] Python 环境检查完成。
echo.

REM 设置项目使用的 Python
set PYTHON_CMD=.venv\Scripts\python.exe

REM 启动 Milvus 及其配套容器
echo [4/8] 检查并启动 Milvus...
docker info >nul 2>&1
if errorlevel 1 (
    echo [错误] 无法连接 Docker Engine。
    echo [提示] 请先启动 Docker Desktop，然后重新运行本脚本。
    pause
    exit /b 1
)

docker ps --format "{{.Names}}" | findstr /X "milvus-standalone" >nul 2>&1
if not errorlevel 1 (
    echo [信息] Milvus 已经在运行。
) else (
    echo [信息] 正在启动 Milvus、etcd、MinIO 和 Attu...
    docker compose -f vector-database.yml up -d
    if errorlevel 1 (
        echo [错误] Docker 容器启动失败。
        echo [提示] 请检查 Docker Desktop 和 vector-database.yml。
        pause
        exit /b 1
    )

    echo [信息] 正在等待 Milvus 初始化，预计需要 10 秒...
    timeout /t 10 /nobreak >nul
)
echo [成功] Milvus 启动步骤完成。
echo.

REM 启动 CLS MCP 服务
echo [5/8] 启动 CLS MCP 日志服务...
start "CLS MCP Server" /min %PYTHON_CMD% mcp_servers/cls_server.py
timeout /t 2 /nobreak >nul
echo [成功] CLS MCP 服务启动命令已执行。
echo.

REM 启动 Monitor MCP 服务
echo [6/8] 启动 Monitor MCP 监控服务...
start "Monitor MCP Server" /min %PYTHON_CMD% mcp_servers/monitor_server.py
timeout /t 2 /nobreak >nul
echo [成功] Monitor MCP 服务启动命令已执行。
echo.

REM 启动 FastAPI
echo [7/8] 启动 FastAPI 主服务...
start "ReActLab API" %PYTHON_CMD% -m uvicorn app.main:app --host 0.0.0.0 --port 9900
echo [信息] 正在等待 FastAPI 初始化，预计需要 15 秒...
timeout /t 15 /nobreak >nul
echo.

REM 检查服务并导入知识库文档
echo [8/8] 检查服务状态并导入知识库...
curl.exe -s http://localhost:9900/api/health >nul 2>&1
if errorlevel 1 (
    echo [警告] FastAPI 健康检查未通过。
    echo [提示] 请查看 ReActLab API 窗口或 logs 目录中的日志。
) else (
    echo [成功] FastAPI 健康检查通过。
    echo.
    echo [信息] 正在导入 aiops-docs 目录中的知识库文档...

    for %%f in (aiops-docs\*.md) do (
        echo [上传] %%~nxf
        curl.exe -s -X POST http://localhost:9900/api/upload -F "file=@%%f" >nul 2>&1
    )

    echo [成功] 知识库文档导入完成。
)

echo.
echo ====================================
echo ReActLab 启动流程执行完成
echo ====================================
echo Web 页面：http://localhost:9900
echo API 文档：http://localhost:9900/docs
echo 健康检查：http://localhost:9900/api/health
echo Attu 页面：http://localhost:8000
echo.
echo 日志说明：
echo   FastAPI 日志：查看 ReActLab API 窗口或 logs 目录
echo   CLS MCP 日志：查看 CLS MCP Server 窗口
echo   Monitor MCP 日志：查看 Monitor MCP Server 窗口
echo.
echo 如需停止全部服务，请运行：
echo   stop-windows.bat
echo ====================================
pause