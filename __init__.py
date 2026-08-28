"""Hermes host adapter for TINO Connect.

This module only registers the packaged skills and Hermes' own Remote MCP
client. It never reads, builds, uploads, or stores customer source code.
"""

from __future__ import annotations

import logging
from pathlib import Path


_SERVER_NAME = "tino-connect"
_SERVER_URL = "https://aim.tino.vn/mcp"
_LOG = logging.getLogger(__name__)


def _register_skills(ctx) -> None:
    from agent.skill_utils import parse_frontmatter

    skills_root = Path(__file__).parent / "skills"
    for skill_dir in sorted(skills_root.iterdir()):
        skill_md = skill_dir / "SKILL.md"
        if not skill_dir.is_dir() or not skill_md.is_file():
            continue
        frontmatter, _body = parse_frontmatter(skill_md.read_text(encoding="utf-8"))
        name = frontmatter.get("name")
        description = frontmatter.get("description")
        if name != skill_dir.name or not isinstance(description, str) or not description:
            raise ValueError(f"Invalid packaged skill frontmatter: {skill_md}")
        ctx.register_skill(
            name,
            skill_md,
            description=description,
            frontmatter=frontmatter,
        )


def _ensure_remote_config():
    from hermes_cli.mcp_config import _get_mcp_servers, _save_mcp_server

    servers = _get_mcp_servers()
    current = servers.get(_SERVER_NAME)
    if current is None:
        config = {
            "url": _SERVER_URL,
            "auth": "oauth",
            "strict_redirect_headers": True,
        }
        return config if _save_mcp_server(_SERVER_NAME, config) else None
    if not isinstance(current, dict) or current.get("url") != _SERVER_URL:
        _LOG.warning(
            "TINO Connect did not replace the existing Hermes MCP server named %s",
            _SERVER_NAME,
        )
        return None

    config = dict(current)
    changed = False
    if not config.get("auth"):
        config["auth"] = "oauth"
        changed = True
    if config.get("strict_redirect_headers") is not True:
        config["strict_redirect_headers"] = True
        changed = True
    if changed and not _save_mcp_server(_SERVER_NAME, config):
        return None
    return config


def register(ctx) -> None:
    _register_skills(ctx)
    config = _ensure_remote_config()
    if config is None:
        return
    try:
        from tools.mcp_tool import register_mcp_servers

        register_mcp_servers({_SERVER_NAME: config})
    except Exception as exc:
        # Non-interactive startup and Plugin Doctor deliberately cannot open
        # the OAuth browser. The saved native config lets Hermes retry through
        # its normal MCP login/discovery path in the next interactive session.
        _LOG.info("TINO Connect OAuth will continue in an interactive session: %s", exc)
