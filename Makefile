# ReActLab Python 鐗堟湰 Makefile
# 鐢ㄤ簬鑷姩鍖栭」鐩垵濮嬪寲銆丏ocker 绠＄悊鍜屾枃妗ｅ悜閲忓寲

# ============================================================
# 閰嶇疆鍙橀噺
# ============================================================
SERVER_URL = http://localhost:9900
UPLOAD_API = $(SERVER_URL)/api/upload
HEALTH_CHECK_API = $(SERVER_URL)/health
DOCS_DIR = aiops-docs
MILVUS_CONTAINER = milvus-standalone

# 棰滆壊杈撳嚭
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
CYAN = \033[0;36m
NC = \033[0m

.PHONY: help init start stop restart check upload clean up down status wait \
        install install-dev dev run test test-quick format lint fix type-check \
        security pre-commit-install pre-commit check-all coverage docs shell \
        ipython watch add add-dev remove list-docs test-upload sync logs \
        start-cls stop-cls start-monitor stop-monitor start-api stop-api status-mcp

# ============================================================
# 榛樿鐩爣锛氭樉绀哄府鍔╀俊鎭?
# ============================================================
help:
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)  ReActLab Python 鐗堟湰 - Makefile 鍛戒护$(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo ""
	@echo "$(CYAN)銆愪竴閿搷浣溿€?(NC)"
	@echo "  $(YELLOW)make init$(NC)         - 馃殌 涓€閿垵濮嬪寲锛圖ocker 鈫?鏈嶅姟 鈫?涓婁紶鏂囨。锛?
	@echo ""
	@echo "$(CYAN)銆怐ocker 绠＄悊銆?(NC)"
	@echo "  $(YELLOW)make up$(NC)           - 馃惓 鍚姩 Milvus 瀹瑰櫒"
	@echo "  $(YELLOW)make down$(NC)         - 馃洃 鍋滄 Milvus 瀹瑰櫒"
	@echo "  $(YELLOW)make status$(NC)       - 馃搳 鏌ョ湅瀹瑰櫒鐘舵€?
	@echo ""
	@echo "$(CYAN)銆愭湇鍔＄鐞嗐€?(NC)"
	@echo "  $(YELLOW)make start$(NC)        - 馃殌 鍚姩鎵€鏈夋湇鍔★紙MCP + FastAPI锛?
	@echo "  $(YELLOW)make stop$(NC)         - 馃洃 鍋滄鎵€鏈夋湇鍔★紙MCP + FastAPI锛?
	@echo "  $(YELLOW)make restart$(NC)      - 馃攧 閲嶅惎鎵€鏈夋湇鍔?
	@echo "  $(YELLOW)make check$(NC)        - 馃攳 妫€鏌?FastAPI 鏈嶅姟鐘舵€?
	@echo "  $(YELLOW)make status-mcp$(NC)   - 馃搳 鏌ョ湅 MCP 鏈嶅姟鐘舵€?
	@echo ""
	@echo "$(CYAN)銆怣CP 鏈嶅姟绠＄悊銆?(NC)"
	@echo "  $(YELLOW)make start-cls$(NC)     - 馃搵 鍚姩 CLS MCP 鏈嶅姟"
	@echo "  $(YELLOW)make stop-cls$(NC)      - 馃洃 鍋滄 CLS MCP 鏈嶅姟"
	@echo "  $(YELLOW)make start-monitor$(NC) - 馃搳 鍚姩 Monitor MCP 鏈嶅姟"
	@echo "  $(YELLOW)make stop-monitor$(NC)  - 馃洃 鍋滄 Monitor MCP 鏈嶅姟"
	@echo "  $(YELLOW)make start-api$(NC)     - 馃殌 鍚姩 FastAPI 鏈嶅姟"
	@echo "  $(YELLOW)make stop-api$(NC)      - 馃洃 鍋滄 FastAPI 鏈嶅姟"
	@echo ""
	@echo "$(CYAN)銆愬紑鍙戞ā寮忋€?(NC)"
	@echo "  $(YELLOW)make dev$(NC)          - 馃敡 寮€鍙戞ā寮忚繍琛岋紙鍓嶅彴锛岀儹閲嶈浇锛?
	@echo "  $(YELLOW)make run$(NC)          - 馃彮 鐢熶骇妯″紡杩愯锛堝墠鍙帮級"
	@echo ""
	@echo "$(CYAN)銆愭枃妗ｇ鐞嗐€?(NC)"
	@echo "  $(YELLOW)make upload$(NC)       - 馃摛 涓婁紶 docs 鐩綍涓嬬殑鏂囨。"
	@echo "  $(YELLOW)make list-docs$(NC)    - 馃摎 鍒楀嚭鍙笂浼犵殑鏂囨。"
	@echo "  $(YELLOW)make test-upload$(NC)  - 馃И 娴嬭瘯涓婁紶鍗曚釜鏂囦欢"
	@echo ""
	@echo "$(CYAN)銆愪緷璧栫鐞嗐€?(NC)"
	@echo "  $(YELLOW)make install$(NC)      - 馃摝 瀹夎鐢熶骇渚濊禆"
	@echo "  $(YELLOW)make install-dev$(NC)  - 馃摝 瀹夎寮€鍙戜緷璧?
	@echo "  $(YELLOW)make sync$(NC)         - 馃攧 鍚屾渚濊禆"
	@echo "  $(YELLOW)make add PKG=xxx$(NC)  - 鉃?娣诲姞渚濊禆鍖?
	@echo ""
	@echo "$(CYAN)銆愪唬鐮佽川閲忋€?(NC)"
	@echo "  $(YELLOW)make format$(NC)       - 馃帹 鏍煎紡鍖栦唬鐮?
	@echo "  $(YELLOW)make lint$(NC)         - 馃攳 浠ｇ爜妫€鏌?
	@echo "  $(YELLOW)make fix$(NC)          - 馃敡 鑷姩淇闂"
	@echo "  $(YELLOW)make test$(NC)         - 馃И 杩愯娴嬭瘯"
	@echo "  $(YELLOW)make check-all$(NC)    - 鉁?杩愯鎵€鏈夋鏌?
	@echo ""
	@echo "$(CYAN)銆愬叾浠栥€?(NC)"
	@echo "  $(YELLOW)make clean$(NC)        - 馃Ч 娓呯悊涓存椂鏂囦欢"
	@echo "  $(YELLOW)make shell$(NC)        - 馃悕 鍚姩 Python Shell"
	@echo "  $(YELLOW)make coverage$(NC)     - 馃搳 鏌ョ湅娴嬭瘯瑕嗙洊鐜?
	@echo "  $(YELLOW)make logs$(NC)         - 馃摐 鏌ョ湅鏈嶅姟鏃ュ織"
	@echo ""
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)浣跨敤绀轰緥:$(NC)"
	@echo "  1. 涓€閿垵濮嬪寲: $(YELLOW)make init$(NC)"
	@echo "  2. 鍚姩鏈嶅姟:   $(YELLOW)make start$(NC) (鑷姩鍚姩 CLS + Monitor MCP + FastAPI)"
	@echo "  3. 妫€鏌ョ姸鎬?   $(YELLOW)make status-mcp$(NC)"
	@echo "  4. 鍋滄鏈嶅姟:   $(YELLOW)make stop$(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"

# ============================================================
# 涓€閿垵濮嬪寲
# ============================================================
init:
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)馃殌 寮€濮嬩竴閿垵濮嬪寲 ReActLab...$(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo ""
	@echo "$(YELLOW)姝ラ 1/4: 鍚姩 Docker 瀹瑰櫒锛圡ilvus 鍚戦噺鏁版嵁搴擄級$(NC)"
	@$(MAKE) up
	@echo ""
	@echo "$(YELLOW)姝ラ 2/4: 鍚姩 FastAPI 鏈嶅姟$(NC)"
	@$(MAKE) start
	@echo ""
	@echo "$(YELLOW)姝ラ 3/4: 绛夊緟鏈嶅姟灏辩华$(NC)"
	@$(MAKE) wait
	@echo ""
	@echo "$(YELLOW)姝ラ 4/4: 涓婁紶鏂囨。鍒板悜閲忔暟鎹簱$(NC)"
	@$(MAKE) upload
	@echo ""
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)鉁?鍒濆鍖栧畬鎴愶紒鎵€鏈夋枃妗ｅ凡鎴愬姛鍚戦噺鍖栧瓨鍌ㄥ埌鏁版嵁搴?(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo ""
	@echo "$(GREEN)馃寪 鏈嶅姟璁块棶鍦板潃:$(NC)"
	@echo "   API 鏈嶅姟: $(SERVER_URL)"
	@echo "   API 鏂囨。: $(SERVER_URL)/docs"
	@echo "   Attu (Milvus Web UI): http://localhost:8000"
	@echo "   MinIO: http://localhost:9001 (admin/minioadmin)"
	@echo ""
	@echo "$(YELLOW)馃挕 鎻愮ず: 鏈嶅姟姝ｅ湪鍚庡彴杩愯$(NC)"
	@echo "   鏌ョ湅鏃ュ織: $(YELLOW)tail -f server.log$(NC)"
	@echo "   鍋滄鏈嶅姟: $(YELLOW)make stop$(NC)"

# ============================================================
# Docker 绠＄悊
# ============================================================

# 鍚姩 Docker 瀹瑰櫒锛堜娇鐢?docker compose锛?
up:
	@echo "$(YELLOW)馃惓 妫€鏌?Docker 瀹瑰櫒鐘舵€?..$(NC)"
	@if ! docker info > /dev/null 2>&1; then \
		echo "$(YELLOW)鈿狅笍  Docker 鏈繍琛岋紝灏濊瘯鍚姩 Colima...$(NC)"; \
		colima start 2>/dev/null || (echo "$(RED)鉂?鏃犳硶鍚姩 Docker锛岃鎵嬪姩鍚姩$(NC)" && exit 1); \
		sleep 3; \
	fi
	@if docker ps --format '{{.Names}}' | grep -q "^$(MILVUS_CONTAINER)$$"; then \
		echo "$(GREEN)鉁?Milvus 瀹瑰櫒宸茬粡鍦ㄨ繍琛屼腑$(NC)"; \
		docker ps --filter "name=milvus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -10; \
	else \
		echo "$(YELLOW)馃殌 鍚姩 Milvus 鐩稿叧瀹瑰櫒...$(NC)"; \
		docker compose -f vector-database.yml up -d; \
		echo "$(YELLOW)鈴?绛夊緟瀹瑰櫒鍚姩...$(NC)"; \
		sleep 5; \
		if docker ps --format '{{.Names}}' | grep -q "^$(MILVUS_CONTAINER)$$"; then \
			echo "$(GREEN)鉁?Docker 瀹瑰櫒鍚姩鎴愬姛锛?(NC)"; \
			echo ""; \
			echo "$(GREEN)馃搵 杩愯涓殑瀹瑰櫒:$(NC)"; \
			docker ps --filter "name=milvus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -10; \
			echo ""; \
			echo "$(GREEN)馃寪 鏈嶅姟璁块棶鍦板潃:$(NC)"; \
			echo "   Milvus: localhost:19530"; \
			echo "   Attu (Web UI): http://localhost:8000"; \
			echo "   MinIO: http://localhost:9001 (admin/minioadmin)"; \
		else \
			echo "$(RED)鉂?瀹瑰櫒鍚姩澶辫触$(NC)"; \
			exit 1; \
		fi; \
	fi

# 鍋滄 Docker 瀹瑰櫒
down:
	@echo "$(YELLOW)馃洃 鍋滄 Docker 瀹瑰櫒...$(NC)"
	@if docker ps --format '{{.Names}}' | grep -q "milvus"; then \
		docker compose -f vector-database.yml down; \
		echo "$(GREEN)鉁?Docker 瀹瑰櫒宸插仠姝?(NC)"; \
	else \
		echo "$(YELLOW)鈿狅笍  娌℃湁杩愯涓殑 Milvus 瀹瑰櫒$(NC)"; \
	fi

# 鏌ョ湅瀹瑰櫒鐘舵€?
status:
	@echo "$(YELLOW)馃搳 Docker 瀹瑰櫒鐘舵€?$(NC)"
	@echo ""
	@if docker ps -a --format '{{.Names}}' | grep -q "milvus"; then \
		docker ps -a --filter "name=milvus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
		echo ""; \
		running=$$(docker ps --filter "name=milvus" --format '{{.Names}}' | wc -l | tr -d ' '); \
		total=$$(docker ps -a --filter "name=milvus" --format '{{.Names}}' | wc -l | tr -d ' '); \
		echo "$(GREEN)杩愯涓? $$running / $$total$(NC)"; \
	else \
		echo "$(YELLOW)鈿狅笍  娌℃湁鎵惧埌 Milvus 鐩稿叧瀹瑰櫒$(NC)"; \
		echo "$(YELLOW)鎻愮ず: 璇峰厛鍒涘缓 Milvus 瀹瑰櫒$(NC)"; \
	fi

# ============================================================
# MCP 鏈嶅姟绠＄悊
# ============================================================

# 鍚姩 CLS MCP 鏈嶅姟
start-cls:
	@echo "$(YELLOW)馃搵 鍚姩 CLS MCP 鏈嶅姟...$(NC)"
	@if pgrep -f "mcp_servers/cls_server.py" > /dev/null 2>&1; then \
		echo "$(GREEN)鉁?CLS MCP 鏈嶅姟宸茬粡鍦ㄨ繍琛屼腑$(NC)"; \
	else \
		echo "$(YELLOW)馃摝 姝ｅ湪鍚姩 CLS MCP 鏈嶅姟锛堝悗鍙拌繍琛岋級...$(NC)"; \
		nohup .venv/bin/python mcp_servers/cls_server.py > mcp_cls.log 2>&1 & \
		echo $$! > mcp_cls.pid; \
		sleep 2; \
		if pgrep -f "mcp_servers/cls_server.py" > /dev/null 2>&1; then \
			echo "$(GREEN)鉁?CLS MCP 鏈嶅姟鍚姩鎴愬姛$(NC)"; \
			echo "$(YELLOW)   PID: $$(cat mcp_cls.pid)$(NC)"; \
			echo "$(YELLOW)   URL: http://127.0.0.1:8003/mcp$(NC)"; \
			echo "$(YELLOW)   鏃ュ織: mcp_cls.log$(NC)"; \
		else \
			echo "$(RED)鉂?CLS MCP 鏈嶅姟鍚姩澶辫触$(NC)"; \
			echo "$(YELLOW)璇锋鏌ユ棩蹇? tail -f mcp_cls.log$(NC)"; \
		fi; \
	fi

# 鍚姩 Monitor MCP 鏈嶅姟
start-monitor:
	@echo "$(YELLOW)馃搳 鍚姩 Monitor MCP 鏈嶅姟...$(NC)"
	@if pgrep -f "mcp_servers/monitor_server.py" > /dev/null 2>&1; then \
		echo "$(GREEN)鉁?Monitor MCP 鏈嶅姟宸茬粡鍦ㄨ繍琛屼腑$(NC)"; \
	else \
		echo "$(YELLOW)馃摝 姝ｅ湪鍚姩 Monitor MCP 鏈嶅姟锛堝悗鍙拌繍琛岋級...$(NC)"; \
		nohup .venv/bin/python mcp_servers/monitor_server.py > mcp_monitor.log 2>&1 & \
		echo $$! > mcp_monitor.pid; \
		sleep 2; \
		if pgrep -f "mcp_servers/monitor_server.py" > /dev/null 2>&1; then \
			echo "$(GREEN)鉁?Monitor MCP 鏈嶅姟鍚姩鎴愬姛$(NC)"; \
			echo "$(YELLOW)   PID: $$(cat mcp_monitor.pid)$(NC)"; \
			echo "$(YELLOW)   URL: http://127.0.0.1:8004/mcp$(NC)"; \
			echo "$(YELLOW)   鏃ュ織: mcp_monitor.log$(NC)"; \
		else \
			echo "$(RED)鉂?Monitor MCP 鏈嶅姟鍚姩澶辫触$(NC)"; \
			echo "$(YELLOW)璇锋鏌ユ棩蹇? tail -f mcp_monitor.log$(NC)"; \
		fi; \
	fi

# 鍋滄 Monitor MCP 鏈嶅姟
stop-monitor:
	@echo "$(YELLOW)馃洃 鍋滄 Monitor MCP 鏈嶅姟...$(NC)"
	@if [ -f mcp_monitor.pid ]; then \
		pid=$$(cat mcp_monitor.pid); \
		if ps -p $$pid > /dev/null 2>&1; then \
			kill $$pid; \
			echo "$(GREEN)鉁?Monitor MCP 鏈嶅姟宸插仠姝?(PID: $$pid)$(NC)"; \
		else \
			echo "$(YELLOW)鈿狅笍  杩涚▼涓嶅瓨鍦?(PID: $$pid)$(NC)"; \
		fi; \
		rm -f mcp_monitor.pid; \
	else \
		echo "$(YELLOW)鈿狅笍  鏈壘鍒?mcp_monitor.pid 鏂囦欢$(NC)"; \
		pkill -f "mcp_servers/monitor_server.py" 2>/dev/null && \
			echo "$(GREEN)鉁?宸插仠姝㈡墍鏈?Monitor MCP 杩涚▼$(NC)" || \
			echo "$(YELLOW)鈿狅笍  娌℃湁杩愯涓殑 Monitor MCP 杩涚▼$(NC)"; \
	fi

# 妫€鏌?MCP 鏈嶅姟鐘舵€?
status-mcp:
	@echo "$(YELLOW)馃搳 MCP 鏈嶅姟鐘舵€?$(NC)"
	@echo ""
	@echo "$(CYAN)CLS MCP 鏈嶅姟:$(NC)"
	@if pgrep -f "mcp_servers/cls_server.py" > /dev/null 2>&1; then \
		pid=$$(pgrep -f "mcp_servers/cls_server.py"); \
		echo "  鐘舵€? $(GREEN)杩愯涓?(NC)"; \
		echo "  PID: $$pid"; \
		echo "  URL: http://127.0.0.1:8003/mcp"; \
		curl -s http://127.0.0.1:8003/mcp > /dev/null 2>&1 && \
			echo "  杩炴帴: $(GREEN)鉁?姝ｅ父$(NC)" || \
			echo "  杩炴帴: $(RED)鉂?鏃犳硶杩炴帴$(NC)"; \
	else \
		echo "  鐘舵€? $(RED)鏈繍琛?(NC)"; \
	fi
	@echo ""
	@echo "$(CYAN)Monitor MCP 鏈嶅姟:$(NC)"
	@if pgrep -f "mcp_servers/monitor_server.py" > /dev/null 2>&1; then \
		pid=$$(pgrep -f "mcp_servers/monitor_server.py"); \
		echo "  鐘舵€? $(GREEN)杩愯涓?(NC)"; \
		echo "  PID: $$pid"; \
		echo "  URL: http://127.0.0.1:8004/mcp"; \
		curl -s http://127.0.0.1:8004/mcp > /dev/null 2>&1 && \
			echo "  杩炴帴: $(GREEN)鉁?姝ｅ父$(NC)" || \
			echo "  杩炴帴: $(RED)鉂?鏃犳硶杩炴帴$(NC)"; \
	else \
		echo "  鐘舵€? $(RED)鏈繍琛?(NC)"; \
	fi
	@echo ""
	@echo "$(CYAN)Math MCP 鏈嶅姟:$(NC)"
	@echo "  鐘舵€? $(YELLOW)宸茬Щ闄わ紙绀轰緥鏈嶅姟锛?(NC)"

# ============================================================
# FastAPI 鏈嶅姟绠＄悊
# ============================================================

# 鍚姩鎵€鏈夋湇鍔★紙MCP + FastAPI锛?
start:
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)馃殌 鍚姩鎵€鏈夋湇鍔?(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo ""
	@$(MAKE) start-cls
	@sleep 1
	@echo ""
	@$(MAKE) start-monitor
	@sleep 1
	@echo ""
	@$(MAKE) start-api
	@echo ""
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)鉁?鎵€鏈夋湇鍔″惎鍔ㄥ畬鎴愶紒$(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"

# 鍚姩 FastAPI 鏈嶅姟
start-api:
	@echo "$(YELLOW)馃殌 鍚姩 FastAPI 鏈嶅姟...$(NC)"
	@if curl -s -f $(HEALTH_CHECK_API) > /dev/null 2>&1; then \
		echo "$(GREEN)鉁?FastAPI 鏈嶅姟宸茬粡鍦ㄨ繍琛屼腑 ($(SERVER_URL))$(NC)"; \
	else \
		echo "$(YELLOW)馃摝 姝ｅ湪鍚姩 FastAPI 鏈嶅姟锛堝悗鍙拌繍琛岋級...$(NC)"; \
		nohup .venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 9900 > server.log 2>&1 & \
		echo $$! > server.pid; \
		echo "$(GREEN)鉁?FastAPI 鏈嶅姟鍚姩鍛戒护宸叉墽琛?(NC)"; \
		echo "$(YELLOW)   PID: $$(cat server.pid)$(NC)"; \
		echo "$(YELLOW)   URL: $(SERVER_URL)$(NC)"; \
		echo "$(YELLOW)   鏃ュ織: server.log$(NC)"; \
	fi

# 鍋滄鎵€鏈夋湇鍔★紙FastAPI + MCP锛?
stop:
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)馃洃 鍋滄鎵€鏈夋湇鍔?(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo ""
	@$(MAKE) stop-api
	@echo ""
	@$(MAKE) stop-cls
	@echo ""
	@$(MAKE) stop-monitor
	@echo ""
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"
	@echo "$(GREEN)鉁?鎵€鏈夋湇鍔″凡鍋滄锛?(NC)"
	@echo "$(GREEN)鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?(NC)"

# 鍋滄 CLS MCP 鏈嶅姟
stop-cls:
	@echo "$(YELLOW)馃洃 鍋滄 CLS MCP 鏈嶅姟...$(NC)"
	@if [ -f mcp_cls.pid ]; then \
		pid=$$(cat mcp_cls.pid); \
		if ps -p $$pid > /dev/null 2>&1; then \
			kill $$pid; \
			echo "$(GREEN)鉁?CLS MCP 鏈嶅姟宸插仠姝?(PID: $$pid)$(NC)"; \
		else \
			echo "$(YELLOW)鈿狅笍  杩涚▼涓嶅瓨鍦?(PID: $$pid)$(NC)"; \
		fi; \
		rm -f mcp_cls.pid; \
	else \
		echo "$(YELLOW)鈿狅笍  鏈壘鍒?mcp_cls.pid 鏂囦欢$(NC)"; \
		pkill -f "mcp_servers/cls_server.py" 2>/dev/null && \
			echo "$(GREEN)鉁?宸插仠姝㈡墍鏈?CLS MCP 杩涚▼$(NC)" || \
			echo "$(YELLOW)鈿狅笍  娌℃湁杩愯涓殑 CLS MCP 杩涚▼$(NC)"; \
	fi

# 鍋滄 FastAPI 鏈嶅姟
stop-api:
	@echo "$(YELLOW)馃洃 鍋滄 FastAPI 鏈嶅姟...$(NC)"
	@if [ -f server.pid ]; then \
		pid=$$(cat server.pid); \
		if ps -p $$pid > /dev/null 2>&1; then \
			kill $$pid; \
			echo "$(GREEN)鉁?FastAPI 鏈嶅姟宸插仠姝?(PID: $$pid)$(NC)"; \
		else \
			echo "$(YELLOW)鈿狅笍  杩涚▼涓嶅瓨鍦?(PID: $$pid)$(NC)"; \
		fi; \
		rm -f server.pid; \
	else \
		echo "$(YELLOW)鈿狅笍  鏈壘鍒?server.pid 鏂囦欢$(NC)"; \
		pkill -f "uvicorn app.main:app" 2>/dev/null && \
			echo "$(GREEN)鉁?宸插仠姝㈡墍鏈?uvicorn 杩涚▼$(NC)" || \
			echo "$(YELLOW)鈿狅笍  娌℃湁杩愯涓殑 uvicorn 杩涚▼$(NC)"; \
	fi

# 閲嶅惎鎵€鏈夋湇鍔?
restart:
	@echo "$(YELLOW)馃攧 閲嶅惎鎵€鏈夋湇鍔?..$(NC)"
	@echo ""
	@$(MAKE) stop
	@sleep 2
	@$(MAKE) start
	@$(MAKE) wait
	@echo ""
	@echo "$(GREEN)鉁?鎵€鏈夋湇鍔￠噸鍚畬鎴愶紒$(NC)"

# 绛夊緟鏈嶅姟灏辩华锛堟渶澶?60 绉掞級
wait:
	@echo "$(YELLOW)鈴?绛夊緟鏈嶅姟鍣ㄥ氨缁?..$(NC)"
	@max_attempts=60; \
	attempt=0; \
	while [ $$attempt -lt $$max_attempts ]; do \
		if curl -s -f $(HEALTH_CHECK_API) > /dev/null 2>&1; then \
			echo ""; \
			echo "$(GREEN)鉁?鏈嶅姟鍣ㄥ凡灏辩华锛?$(SERVER_URL))$(NC)"; \
			exit 0; \
		fi; \
		attempt=$$((attempt + 1)); \
		printf "\r$(YELLOW)   绛夊緟涓?.. [$$attempt/$$max_attempts]$(NC)"; \
		sleep 1; \
	done; \
	echo ""; \
	echo "$(RED)鉂?鏈嶅姟鍣ㄥ惎鍔ㄨ秴鏃讹紒$(NC)"; \
	echo "$(YELLOW)璇锋鏌ユ棩蹇? tail -f server.log$(NC)"; \
	exit 1

# 妫€鏌ユ湇鍔＄姸鎬?
check:
	@echo "$(YELLOW)馃攳 妫€鏌ユ湇鍔″櫒鐘舵€?..$(NC)"
	@if curl -s -f $(HEALTH_CHECK_API) > /dev/null 2>&1; then \
		echo "$(GREEN)鉁?鏈嶅姟鍣ㄨ繍琛屾甯?($(SERVER_URL))$(NC)"; \
		echo ""; \
		echo "$(CYAN)鍋ュ悍妫€鏌ュ搷搴?$(NC)"; \
		curl -s $(HEALTH_CHECK_API) | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin), indent=2, ensure_ascii=False))" 2>/dev/null || curl -s $(HEALTH_CHECK_API); \
	else \
		echo "$(RED)鉂?鏈嶅姟鍣ㄦ湭杩愯鎴栨棤娉曡繛鎺ワ紒$(NC)"; \
		echo "$(YELLOW)璇峰厛鍚姩鏈嶅姟: make start$(NC)"; \
		exit 1; \
	fi

# 寮€鍙戞ā寮忚繍琛岋紙鍓嶅彴锛岀儹閲嶈浇锛?
dev:
	@echo "$(YELLOW)馃敡 鍚姩寮€鍙戞湇鍔″櫒锛堢儹閲嶈浇锛?..$(NC)"
	.venv/bin/python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 9900

# 鐢熶骇妯″紡杩愯锛堝墠鍙帮級
run:
	@echo "$(YELLOW)馃彮 鍚姩鐢熶骇鏈嶅姟鍣?..$(NC)"
	.venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 9900

# ============================================================
# 鏂囨。绠＄悊
# ============================================================

# 涓婁紶鎵€鏈夋枃妗?
upload:
	@echo "$(YELLOW)馃摛 寮€濮嬩笂浼?$(DOCS_DIR) 鐩綍涓嬬殑鏂囨。...$(NC)"
	@if [ ! -d "$(DOCS_DIR)" ]; then \
		echo "$(RED)鉂?鐩綍 $(DOCS_DIR) 涓嶅瓨鍦紒$(NC)"; \
		exit 1; \
	fi
	@count=0; \
	success=0; \
	failed=0; \
	for file in $(DOCS_DIR)/*.md; do \
		if [ -f "$$file" ]; then \
			count=$$((count + 1)); \
			filename=$$(basename "$$file"); \
			echo "$(YELLOW)  [$$count] 涓婁紶鏂囦欢: $$filename$(NC)"; \
			response=$$(curl -s -w "\n%{http_code}" -X POST $(UPLOAD_API) \
				-F "file=@$$file" \
				-H "Accept: application/json"); \
			http_code=$$(echo "$$response" | tail -n1); \
			body=$$(echo "$$response" | sed '$$d'); \
			if [ "$$http_code" = "200" ]; then \
				echo "$(GREEN)      鉁?鎴愬姛: $$filename$(NC)"; \
				success=$$((success + 1)); \
			else \
				echo "$(RED)      鉂?澶辫触: $$filename (HTTP $$http_code)$(NC)"; \
				echo "$$body" | head -n 3; \
				failed=$$((failed + 1)); \
			fi; \
			sleep 1; \
		fi; \
	done; \
	echo ""; \
	echo "$(GREEN)馃搳 涓婁紶缁熻:$(NC)"; \
	echo "   鎬昏: $$count 涓枃浠?; \
	echo "   $(GREEN)鎴愬姛: $$success$(NC)"; \
	if [ $$failed -gt 0 ]; then \
		echo "   $(RED)澶辫触: $$failed$(NC)"; \
	fi

# 鍒楀嚭鏂囨。
list-docs:
	@echo "$(YELLOW)馃摎 $(DOCS_DIR) 鐩綍涓嬬殑鏂囨。:$(NC)"
	@if [ -d "$(DOCS_DIR)" ]; then \
		ls -lh $(DOCS_DIR)/*.md 2>/dev/null || echo "$(RED)娌℃湁鎵惧埌 .md 鏂囦欢$(NC)"; \
	else \
		echo "$(RED)鐩綍 $(DOCS_DIR) 涓嶅瓨鍦?(NC)"; \
	fi

# 娴嬭瘯涓婁紶鍗曚釜鏂囦欢
test-upload:
	@echo "$(YELLOW)馃И 娴嬭瘯涓婁紶鍗曚釜鏂囦欢...$(NC)"
	@first_file=$$(ls $(DOCS_DIR)/*.md 2>/dev/null | head -n1); \
	if [ -n "$$first_file" ]; then \
		echo "$(YELLOW)涓婁紶鏂囦欢: $$first_file$(NC)"; \
		curl -X POST $(UPLOAD_API) \
			-F "file=@$$first_file" \
			-H "Accept: application/json" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin), indent=2, ensure_ascii=False))" 2>/dev/null || \
			curl -X POST $(UPLOAD_API) -F "file=@$$first_file"; \
	else \
		echo "$(RED)娴嬭瘯鏂囦欢涓嶅瓨鍦?(NC)"; \
	fi

# ============================================================
# 渚濊禆绠＄悊
# ============================================================

install:  ## 瀹夎渚濊禆锛堢敓浜х幆澧冿級
	@echo "$(YELLOW)馃摝 瀹夎渚濊禆...$(NC)"
	pip install -r requirements.txt 2>/dev/null || pip install -e .
	@echo "$(GREEN)鉁?渚濊禆瀹夎瀹屾垚$(NC)"

install-dev:  ## 瀹夎寮€鍙戜緷璧?
	@echo "$(YELLOW)馃摝 瀹夎寮€鍙戜緷璧?..$(NC)"
	pip install -e ".[dev]" 2>/dev/null || pip install -e .
	@echo "$(GREEN)鉁?寮€鍙戜緷璧栧畨瑁呭畬鎴?(NC)"

sync:  ## 鍚屾渚濊禆
	@echo "$(YELLOW)馃攧 鍚屾渚濊禆...$(NC)"
	pip install -e . --upgrade
	@echo "$(GREEN)鉁?渚濊禆鍚屾瀹屾垚$(NC)"

add:  ## 娣诲姞渚濊禆鍖?(鐢ㄦ硶: make add PKG=package_name)
	@echo "$(YELLOW)馃摝 娣诲姞渚濊禆: $(PKG)...$(NC)"
	pip install $(PKG)

add-dev:  ## 娣诲姞寮€鍙戜緷璧?(鐢ㄦ硶: make add-dev PKG=package_name)
	@echo "$(YELLOW)馃摝 娣诲姞寮€鍙戜緷璧? $(PKG)...$(NC)"
	pip install $(PKG)

remove:  ## 绉婚櫎渚濊禆鍖?(鐢ㄦ硶: make remove PKG=package_name)
	@echo "$(YELLOW)馃棏锔? 绉婚櫎渚濊禆: $(PKG)...$(NC)"
	pip uninstall $(PKG)

# ============================================================
# 浠ｇ爜璐ㄩ噺
# ============================================================

format:  ## 鏍煎紡鍖栦唬鐮?
	@echo "$(YELLOW)馃帹 鏍煎紡鍖栦唬鐮?..$(NC)"
	python3 -m ruff check --select I --fix app/ 2>/dev/null || true
	python3 -m ruff format app/ 2>/dev/null || python3 -m black app/
	@echo "$(GREEN)鉁?鏍煎紡鍖栧畬鎴?(NC)"

lint:  ## 浠ｇ爜妫€鏌?
	@echo "$(YELLOW)馃攳 浠ｇ爜妫€鏌?..$(NC)"
	python3 -m ruff check app/ 2>/dev/null || python3 -m flake8 app/
	@echo "$(GREEN)鉁?妫€鏌ュ畬鎴?(NC)"

fix:  ## 鑷姩淇浠ｇ爜闂
	@echo "$(YELLOW)馃敡 鑷姩淇浠ｇ爜闂...$(NC)"
	python3 -m ruff check --fix app/ 2>/dev/null || true
	python3 -m ruff format app/ 2>/dev/null || python3 -m black app/
	@echo "$(GREEN)鉁?淇瀹屾垚$(NC)"

type-check:  ## 绫诲瀷妫€鏌?
	@echo "$(YELLOW)馃攳 绫诲瀷妫€鏌?..$(NC)"
	python3 -m mypy app/ --ignore-missing-imports
	@echo "$(GREEN)鉁?绫诲瀷妫€鏌ュ畬鎴?(NC)"

security:  ## 瀹夊叏妫€鏌?
	@echo "$(YELLOW)馃敀 瀹夊叏妫€鏌?..$(NC)"
	python3 -m bandit -r app/ -ll
	@echo "$(GREEN)鉁?瀹夊叏妫€鏌ュ畬鎴?(NC)"

test:  ## 杩愯娴嬭瘯
	@echo "$(YELLOW)馃И 杩愯娴嬭瘯...$(NC)"
	python3 -m pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html

test-quick:  ## 蹇€熸祴璇?
	@echo "$(YELLOW)鈿?蹇€熸祴璇?..$(NC)"
	python3 -m pytest tests/ -v

check-all:  ## 杩愯鎵€鏈夋鏌?
	@echo "$(YELLOW)馃殌 杩愯鎵€鏈夋鏌?..$(NC)"
	@$(MAKE) format
	@$(MAKE) lint
	@$(MAKE) test
	@echo "$(GREEN)鉁?鎵€鏈夋鏌ラ€氳繃锛?(NC)"

pre-commit-install:  ## 瀹夎 pre-commit hooks
	@echo "$(YELLOW)馃敆 瀹夎 pre-commit hooks...$(NC)"
	python3 -m pre_commit install
	python3 -m pre_commit install --hook-type commit-msg
	@echo "$(GREEN)鉁?Pre-commit hooks 瀹夎瀹屾垚$(NC)"

pre-commit:  ## 杩愯 pre-commit 妫€鏌?
	@echo "$(YELLOW)馃攳 杩愯 pre-commit 妫€鏌?..$(NC)"
	python3 -m pre_commit run --all-files

coverage:  ## 鏌ョ湅娴嬭瘯瑕嗙洊鐜囨姤鍛?
	@echo "$(YELLOW)馃搳 鐢熸垚瑕嗙洊鐜囨姤鍛?..$(NC)"
	python3 -m pytest tests/ --cov=app --cov-report=html --cov-report=term
	@echo "$(GREEN)鉁?瑕嗙洊鐜囨姤鍛婂凡鐢熸垚: htmlcov/index.html$(NC)"
	@open htmlcov/index.html 2>/dev/null || xdg-open htmlcov/index.html 2>/dev/null || echo "璇锋墜鍔ㄦ墦寮€ htmlcov/index.html"

# ============================================================
# 鍏朵粬宸ュ叿
# ============================================================

clean:  ## 娓呯悊涓存椂鏂囦欢
	@echo "$(YELLOW)馃Ч 娓呯悊涓存椂鏂囦欢...$(NC)"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf htmlcov/ .coverage
	rm -f server.pid server.log
	rm -f mcp_cls.pid mcp_cls.log
	rm -f mcp_monitor.pid mcp_monitor.log
	rm -rf uploads/*.tmp 2>/dev/null || true
	@echo "$(GREEN)鉁?娓呯悊瀹屾垚$(NC)"

shell:  ## 鍚姩 Python shell
	@echo "$(YELLOW)馃悕 鍚姩 Python shell...$(NC)"
	python3 -i -c "import sys; sys.path.insert(0, '.'); from app.config import config; print('鐜宸插姞杞斤紝config 瀵硅薄鍙敤')"

ipython:  ## 鍚姩 IPython shell
	@echo "$(YELLOW)馃悕 鍚姩 IPython shell...$(NC)"
	python3 -m IPython

docs:  ## 鎵撳紑 API 鏂囨。
	@echo "$(YELLOW)馃摎 API 鏂囨。鍦板潃: $(SERVER_URL)/docs$(NC)"
	@open $(SERVER_URL)/docs 2>/dev/null || xdg-open $(SERVER_URL)/docs 2>/dev/null || echo "璇锋墜鍔ㄦ墦寮€ $(SERVER_URL)/docs"

watch:  ## 鐩戣鏂囦欢鍙樺寲骞惰嚜鍔ㄨ繍琛屾祴璇?
	@echo "$(YELLOW)馃憖 鐩戣鏂囦欢鍙樺寲...$(NC)"
	python3 -m pytest_watch -- -v

logs:  ## 鏌ョ湅鏈嶅姟鏃ュ織
	@echo "$(YELLOW)馃摐 鏌ョ湅鏈嶅姟鏃ュ織...$(NC)"
	@if [ -f server.log ]; then \
		tail -f server.log; \
	else \
		echo "$(RED)鏃ュ織鏂囦欢涓嶅瓨鍦?(NC)"; \
		echo "$(YELLOW)鎻愮ず: 浣跨敤 make start 鍚姩鏈嶅姟鍚庝細鐢熸垚鏃ュ織$(NC)"; \
	fi
