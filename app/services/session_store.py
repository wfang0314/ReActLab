"""File-backed session persistence for LangGraph MemorySaver"""
import json, os, shutil
from datetime import datetime
from pathlib import Path
from loguru import logger

SESSION_DIR = Path("./sessions")
SESSION_DIR.mkdir(exist_ok=True)


class SessionStore:
    """Simple JSON-file session persistence."""

    def __init__(self, session_dir: str = "./sessions"):
        self.dir = Path(session_dir)
        self.dir.mkdir(exist_ok=True)
        self._cache: dict = {}

    def save(self, session_id: str, messages: list):
        messages_serializable = []
        for msg in messages:
            mtype = type(msg).__name__
            content = getattr(msg, "content", str(msg))
            messages_serializable.append({"type": mtype, "content": content})
        data = {"session_id": session_id, "updated": datetime.now().isoformat(), "messages": messages_serializable}
        path = self.dir / f"{session_id}.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        self._cache[session_id] = messages_serializable

    def load(self, session_id: str) -> list | None:
        if session_id in self._cache:
            return self._cache[session_id]
        path = self.dir / f"{session_id}.json"
        if not path.exists():
            return None
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            self._cache[session_id] = data.get("messages", [])
            return self._cache[session_id]
        except Exception as e:
            logger.warning(f"Failed to load session {session_id}: {e}")
            return None

    def delete(self, session_id: str):
        path = self.dir / f"{session_id}.json"
        if path.exists():
            path.unlink()
        self._cache.pop(session_id, None)

    def list_sessions(self) -> list:
        sessions = []
        for f in sorted(self.dir.glob("*.json"), key=lambda f: f.stat().st_mtime, reverse=True):
            try:
                with open(f, "r", encoding="utf-8") as fp:
                    data = json.load(fp)
                sessions.append({"id": data.get("session_id", f.stem), "updated": data.get("updated", ""), "count": len(data.get("messages", []))})
            except Exception:
                pass
        return sessions


# Global instance
session_store = SessionStore()
logger.info(f"SessionStore initialized: {SESSION_DIR}")
