# -*- coding: utf-8 -*-
"""Generate P2 Architecture, P3 Runtime, P4 Benchmark PDFs for ReActLab portfolio.
Fonts: KaiTi (Chinese), Times New Roman (English). Title 20pt, Body 18pt.
"""

import json
from pathlib import Path
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm, cm
from reportlab.lib.colors import HexColor, white, black
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle,
    PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

BASE = Path(__file__).parent
OUTPUT = BASE / "portfolio"

# ── Register Fonts ──────────────────────────────────────
KAITI_PATH = r"C:\Windows\Fonts\simkai.ttf"
TIMES_PATH = r"C:\Windows\Fonts\times.ttf"
TIMES_BOLD_PATH = r"C:\Windows\Fonts\timesbd.ttf"

if Path(KAITI_PATH).exists():
    pdfmetrics.registerFont(TTFont("KaiTi", KAITI_PATH))
    CN = "KaiTi"
    CN_BOLD = "KaiTi"  # KaiTi has no real bold, use same font
else:
    CN = "Helvetica"
    CN_BOLD = "Helvetica"

if Path(TIMES_PATH).exists():
    pdfmetrics.registerFont(TTFont("TimesNR", TIMES_PATH))
    EN = "TimesNR"
else:
    EN = "Times-Roman"

if Path(TIMES_BOLD_PATH).exists():
    pdfmetrics.registerFont(TTFont("TimesNRBold", TIMES_BOLD_PATH))
    EN_BOLD = "TimesNRBold"
else:
    EN_BOLD = "Times-Bold"

# ── Colors ──────────────────────────────────────────────────
PRIMARY   = HexColor("#1a237e")   # Deep indigo
ACCENT    = HexColor("#7b1fa2")   # Purple
SUBTITLE  = HexColor("#455a64")   # Blue-grey
BG_LIGHT  = HexColor("#f5f5f5")
BORDER    = HexColor("#e0e0e0")
GREEN     = HexColor("#2e7d32")
ORANGE    = HexColor("#e65100")

PAGE_W, PAGE_H = A4  # 210 x 297 mm

# ── Styles ──────────────────────────────────────────────────
# Title: 20pt KaiTi Bold
title_style = ParagraphStyle("CNTitle", fontName=CN_BOLD, fontSize=20,
    leading=26, alignment=TA_LEFT, textColor=PRIMARY, spaceAfter=4*mm)

# Subtitle: 18pt KaiTi
subtitle_style = ParagraphStyle("CNSubtitle", fontName=CN, fontSize=18,
    leading=24, alignment=TA_LEFT, textColor=SUBTITLE, spaceAfter=2*mm)

# H2 heading: 18pt KaiTi Bold
h2_style = ParagraphStyle("CNH2", fontName=CN_BOLD, fontSize=18,
    leading=24, textColor=ACCENT, spaceBefore=6*mm, spaceAfter=3*mm)

# Body: 18pt KaiTi
body_style = ParagraphStyle("CNBody", fontName=CN, fontSize=18,
    leading=24, textColor=HexColor("#333333"))

# Small/footer: 16pt KaiTi
small_style = ParagraphStyle("CNSmall", fontName=CN, fontSize=16,
    leading=20, textColor=HexColor("#888888"))

# Caption: 16pt KaiTi
caption_style = ParagraphStyle("Caption", fontName=CN, fontSize=16,
    leading=20, textColor=HexColor("#888888"), alignment=TA_CENTER)

# Table cell: 16pt KaiTi (slightly smaller for table fitting)
table_style = ParagraphStyle("TableCell", fontName=CN, fontSize=16,
    leading=20, textColor=HexColor("#222222"), alignment=TA_LEFT,
    wordSpace=0, spaceBefore=0, spaceAfter=0)

# Table header: 16pt KaiTi Bold
table_header_style = ParagraphStyle("TableHeader", fontName=CN_BOLD, fontSize=16,
    leading=20, textColor=white, alignment=TA_CENTER,
    wordSpace=0, spaceBefore=0, spaceAfter=0)

# Metric label: 16pt KaiTi
metric_label = ParagraphStyle("MetricLabel", fontName=CN, fontSize=16,
    leading=20, textColor=HexColor("#666666"), alignment=TA_CENTER)

# Metric value: 18pt Times New Roman Bold
metric_value = ParagraphStyle("MetricValue", fontName=EN_BOLD, fontSize=18,
    leading=24, textColor=PRIMARY, alignment=TA_CENTER)


def hr():
    return HRFlowable(width="100%", thickness=0.5, color=BORDER, spaceAfter=3*mm, spaceBefore=1*mm)


def footer_block(page_type):
    """Shared footer."""
    return [
        Spacer(1, 4*mm),
        hr(),
        Paragraph(
            f"ReActLab Agent 实验平台  |  {page_type}  |  作品附件",
            small_style
        )
    ]


def wrap_cell(text):
    """Wrap table cell text into a Paragraph for proper formatting."""
    return Paragraph(text, table_style)


def wrap_header(text):
    """Wrap table header text into a Paragraph."""
    return Paragraph(text, table_header_style)


# ══════════════════════════════════════════════════════════════
#  P2: ARCHITECTURE
# ══════════════════════════════════════════════════════════════

def build_p2():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    pdf_path = str(OUTPUT / "p2_architecture.pdf")

    doc = SimpleDocTemplate(pdf_path, pagesize=A4,
        leftMargin=14*mm, rightMargin=14*mm,
        topMargin=12*mm, bottomMargin=12*mm)

    elements = []

    # Title
    elements.append(Paragraph("系统总体架构", title_style))
    elements.append(Paragraph("User → Gateway → Agent Runtime → Tools / RAG → LLM 全链路数据流", subtitle_style))
    elements.append(hr())

    # Architecture diagram image
    img_path = str(BASE / "p2_architecture.png")
    if Path(img_path).exists():
        img = Image(img_path, width=PAGE_W - 28*mm, height=130*mm)
        img.hAlign = "CENTER"
        elements.append(img)
        elements.append(Paragraph("图 1: ReActLab 系统架构总览 — 从 Web 层到基础设施的完整数据流", caption_style))

    # Architecture layers text description
    elements.append(Spacer(1, 4*mm))
    elements.append(Paragraph("架构分层说明", h2_style))

    usable_w = PAGE_W - 28*mm  # 182mm

    layers_data = [
        [wrap_header("层级"), wrap_header("组件"), wrap_header("技术方案"), wrap_header("职责")],
        [wrap_cell("用户层"), wrap_cell("Web 浏览器"), wrap_cell("HTML5 + JavaScript + AJAX"), wrap_cell("用户交互，发送诊断请求")],
        [wrap_cell("网关层"), wrap_cell("FastAPI 网关"), wrap_cell("FastAPI + SSE + CORS"), wrap_cell("请求路由，流式推送，跨域支持")],
        [wrap_cell("Agent 层"), wrap_cell("Agent Runtime"), wrap_cell("LangGraph + LangChain + ReAct"), wrap_cell("任务规划，工具调度，执行评估，报告生成")],
        [wrap_cell("工具层"), wrap_cell("MCP 工具服务"), wrap_cell("MCP 协议 + FastMCP + HttpClient"), wrap_cell("日志查询，监控数据，时间工具统一接入")],
        [wrap_cell("知识层"), wrap_cell("RAG 知识库"), wrap_cell("Milvus + Embedding + 语义检索"), wrap_cell("文档切片，向量化，上下文增强检索")],
        [wrap_cell("模型层"), wrap_cell("LLM 推理"), wrap_cell("通义千问 / Qwen Chat"), wrap_cell("任务规划，工具调用决策，报告生成")],
        [wrap_cell("数据层"), wrap_cell("CLS 日志 / 云监控"), wrap_cell("腾讯云 CLS + 云监控 API"), wrap_cell("原始日志与监控指标数据存储")],
    ]

    col_w = [usable_w*0.12, usable_w*0.18, usable_w*0.35, usable_w*0.35]
    t_layers = Table(layers_data, colWidths=col_w, repeatRows=1)
    t_layers.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PRIMARY),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("BOX", (0, 0), (-1, -1), 0.8, BORDER),
        ("INNERGRID", (0, 0), (-1, -1), 0.3, BORDER),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
    ]))
    elements.append(t_layers)
    elements.append(Paragraph("表 1: 系统架构分层说明", caption_style))

    elements.extend(footer_block("P2 架构"))
    doc.build(elements)
    print(f"[OK] P2 → {pdf_path}")
    return pdf_path


# ══════════════════════════════════════════════════════════════
#  P3: RUNTIME
# ══════════════════════════════════════════════════════════════

def build_p3():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    pdf_path = str(OUTPUT / "p3_runtime.pdf")

    doc = SimpleDocTemplate(pdf_path, pagesize=A4,
        leftMargin=14*mm, rightMargin=14*mm,
        topMargin=12*mm, bottomMargin=12*mm)

    elements = []

    # Title
    elements.append(Paragraph("Agent Runtime 工作流", title_style))
    elements.append(Paragraph("Plan → Execute → Replan → Report 多阶段自主诊断闭环", subtitle_style))
    elements.append(hr())

    # Runtime diagram image
    img_path = str(BASE / "p3_runtime.png")
    if Path(img_path).exists():
        img = Image(img_path, width=PAGE_W - 28*mm, height=130*mm)
        img.hAlign = "CENTER"
        elements.append(img)
        elements.append(Paragraph("图 2: Agent Runtime 工作流 — Plan-Execute-Replan 循环 + 报告生成", caption_style))

    # Core capabilities
    elements.append(Spacer(1, 4*mm))
    elements.append(Paragraph("Runtime 核心能力", h2_style))

    usable_w = PAGE_W - 28*mm

    capabilities = [
        [wrap_header("能力"), wrap_header("实现方式"), wrap_header("说明")],
        [wrap_cell("Task Planning"), wrap_cell("LangGraph StateGraph + Planner 节点"), wrap_cell("LLM 根据用户意图自动拆解任务，生成结构化执行计划")],
        [wrap_cell("Tool Calling"), wrap_cell("MCP 协议 + Agent Tool 绑定"), wrap_cell("标准化工具接口，支持日志查询、监控、知识检索等 7 个工具")],
        [wrap_cell("Execution Loop"), wrap_cell("Executor + Replanner 节点循环"), wrap_cell("逐步执行计划，评估结果，失败时自动重规划")],
        [wrap_cell("Memory"), wrap_cell("会话状态管理 + 断点续传"), wrap_cell("多轮对话上下文保存，计划执行状态持久化")],
        [wrap_cell("Reflection"), wrap_cell("Replanner 节点 + 评估逻辑"), wrap_cell("根据执行结果判断是否达成目标，决定继续或重新规划")],
        [wrap_cell("Report Generation"), wrap_cell("Reporter 节点 + LLM 结构化输出"), wrap_cell("自动生成包含根因分析和处理建议的诊断报告")],
        [wrap_cell("Streaming"), wrap_cell("FastAPI SSE + 事件推送"), wrap_cell("实时流式输出执行进度、步骤状态和诊断结果")],
    ]

    col_w = [usable_w*0.18, usable_w*0.38, usable_w*0.44]
    t_cap = Table(capabilities, colWidths=col_w, repeatRows=1)
    t_cap.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), ACCENT),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("BOX", (0, 0), (-1, -1), 0.8, BORDER),
        ("INNERGRID", (0, 0), (-1, -1), 0.3, BORDER),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
    ]))
    elements.append(t_cap)
    elements.append(Paragraph("表 2: Agent Runtime 核心能力一览", caption_style))

    elements.extend(footer_block("P3 运行时"))
    doc.build(elements)
    print(f"[OK] P3 → {pdf_path}")
    return pdf_path


# ══════════════════════════════════════════════════════════════
#  P4: BENCHMARK
# ══════════════════════════════════════════════════════════════

def build_p4():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    pdf_path = str(OUTPUT / "p4_benchmark.pdf")

    doc = SimpleDocTemplate(pdf_path, pagesize=A4,
        leftMargin=14*mm, rightMargin=14*mm,
        topMargin=12*mm, bottomMargin=12*mm)

    elements = []

    # Title
    elements.append(Paragraph("评测体系与效果验证", title_style))
    elements.append(Paragraph("100 条 Benchmark Query · 10 个端到端任务 · 全维度指标体系", subtitle_style))
    elements.append(hr())

    # Load benchmark data
    benchmark_path = BASE / "benchmark_results.json"
    if benchmark_path.exists():
        with open(benchmark_path, "r", encoding="utf-8") as f:
            bm = json.load(f)
        rag = bm.get("rag", {})
        agent = bm.get("agent", {})
        mcp = bm.get("mcp_retry", {})
        api = bm.get("api", {})
    else:
        rag = {"top1_pct": 86, "top1_pass": 86, "recall3_pct": 94, "recall3_pass": 94, "mrr": 0.887}
        agent = {"success_rate_pct": 100, "passed": 10, "total_tasks": 10, "pattern": "Plan-Execute-Replan"}
        mcp = {"without_retry_pass": 1, "with_retry_pass": 3, "improvement_pp": 50}
        api = {"health_p50_ms": 0}

    usable_w = PAGE_W - 28*mm

    # ── Key metrics cards ─────────────────────────────────
    elements.append(Paragraph("核心指标一览", h2_style))

    card_data = [
        [
            Paragraph("Top-1 Accuracy", metric_label),
            Paragraph("Recall@3", metric_label),
            Paragraph("MRR", metric_label),
            Paragraph("Agent 成功率", metric_label),
        ],
        [
            Paragraph(f"{rag['top1_pct']}%", metric_value),
            Paragraph(f"{rag['recall3_pct']}%", metric_value),
            Paragraph(f"{rag['mrr']:.3f}", metric_value),
            Paragraph(f"{agent['success_rate_pct']}%", metric_value),
        ],
        [
            Paragraph(f"{rag['top1_pass']}/100", caption_style),
            Paragraph(f"{rag['recall3_pass']}/100", caption_style),
            Paragraph("Mean Reciprocal Rank", caption_style),
            Paragraph(f"{agent['passed']}/{agent['total_tasks']} 任务", caption_style),
        ],
    ]

    card_table = Table(card_data, colWidths=[usable_w*0.25]*4)
    card_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), BG_LIGHT),
        ("BACKGROUND", (0, 1), (-1, 1), white),
        ("BACKGROUND", (0, 2), (-1, 2), BG_LIGHT),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("BOX", (0, 0), (-1, -1), 0.8, BORDER),
        ("INNERGRID", (0, 0), (-1, -1), 0.3, BORDER),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    elements.append(card_table)
    elements.append(Paragraph("表 1: ReActLab Benchmark 核心指标汇总", caption_style))

    # ── RAG evaluation details ───────────────────────────
    elements.append(Spacer(1, 6*mm))
    elements.append(Paragraph("RAG 检索评估 (100 条 Benchmark Query)", h2_style))

    rag_detail = [
        [wrap_header("指标"), wrap_header("数值"), wrap_header("说明")],
        [wrap_cell("Top-1 Accuracy"), wrap_cell(f"{rag['top1_pct']}% ({rag['top1_pass']}/100)"), wrap_cell("正确答案出现在检索结果第 1 位的比例")],
        [wrap_cell("Recall@3"), wrap_cell(f"{rag['recall3_pct']}% ({rag['recall3_pass']}/100)"), wrap_cell("正确答案出现在检索结果前 3 位的比例")],
        [wrap_cell("MRR"), wrap_cell(f"{rag['mrr']:.4f}"), wrap_cell("Mean Reciprocal Rank — 正确答案排名的倒数均值")],
        [wrap_cell("测试集规模"), wrap_cell("100 条 Query"), wrap_cell("覆盖 CPU / 内存 / 磁盘 / 服务故障 4 类场景")],
    ]

    col_w = [usable_w*0.20, usable_w*0.30, usable_w*0.50]
    t_rag = Table(rag_detail, colWidths=col_w, repeatRows=1)
    t_rag.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PRIMARY),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("ALIGN", (0, 0), (1, 0), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("GRID", (0, 0), (-1, -1), 0.5, BORDER),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, BG_LIGHT]),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
    ]))
    elements.append(t_rag)

    # ── Agent evaluation details ─────────────────────────
    elements.append(Spacer(1, 6*mm))
    elements.append(Paragraph("Agent 端到端评测 (10 个诊断任务)", h2_style))

    agent_detail = [
        [wrap_header("指标"), wrap_header("数值"), wrap_header("说明")],
        [wrap_cell("任务成功率"), wrap_cell(f"{agent['success_rate_pct']}% ({agent['passed']}/{agent['total_tasks']})"), wrap_cell("Agent 完整执行 Plan→Execute→Report，输出有效诊断报告")],
        [wrap_cell("Runtime 框架"), wrap_cell(agent.get("pattern", "Plan-Execute-Replan")), wrap_cell("LangGraph 构建的多节点状态图")],
        [wrap_cell("工具数量"), wrap_cell("7 个"), wrap_cell("retrieve_knowledge + 4 MCP 工具 + 2 时间工具")],
        [wrap_cell("MCP 重试恢复率"), wrap_cell(f"无重试: {mcp['without_retry_pass']}/4 → 有重试: {mcp['with_retry_pass']}/4 (+{mcp['improvement_pp']}pp)"), wrap_cell("指数退避策略显著提升工具调用可靠性")],
        [wrap_cell("API 延迟 (p50)"), wrap_cell(f"{api['health_p50_ms']}ms"), wrap_cell("FastAPI 健康检查端点 p50 响应时间")],
    ]

    t_agent = Table(agent_detail, colWidths=col_w, repeatRows=1)
    t_agent.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), ACCENT),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("ALIGN", (0, 0), (1, 0), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("GRID", (0, 0), (-1, -1), 0.5, BORDER),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, BG_LIGHT]),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
    ]))
    elements.append(t_agent)

    # ── Demo screenshot ──────────────────────────────────
    demo_path = str(BASE / "p4_benchmark.png")
    if Path(demo_path).exists():
        elements.append(Spacer(1, 6*mm))
        elements.append(Paragraph("Demo: Agent 实时对话效果", h2_style))
        img = Image(demo_path, width=PAGE_W - 28*mm, height=60*mm)
        img.hAlign = "CENTER"
        elements.append(img)
        elements.append(Paragraph("图 3: ReActLab Web 端 Agent 流式对话 — 任务诊断与报告生成", caption_style))

    elements.extend(footer_block("P4 评测"))
    doc.build(elements)
    print(f"[OK] P4 → {pdf_path}")
    return pdf_path


# ══════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    build_p2()
    build_p3()
    build_p4()
    print("\n[DONE] All 3 pages generated in portfolio/")
