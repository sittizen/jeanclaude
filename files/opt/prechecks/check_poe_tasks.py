#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

import tomlkit


SRC = Path("/opt/prechecks/poe_tasks.toml")
DST = Path("pyproject.toml")


def get_table(doc, keys: list[str]):
    cur = doc
    for k in keys:
        if k not in cur or not isinstance(
            cur[k], (tomlkit.items.Table, tomlkit.items.InlineTable)
        ):
            cur[k] = tomlkit.table()
        cur = cur[k]
    return cur


def main() -> int:
    if not SRC.exists():
        print(f"toolchain source-of-truth not found: {SRC}", file=sys.stderr)
        return 2
    if not DST.exists():
        print(f"project pyproject.toml not found: {DST}", file=sys.stderr)
        return 2

    src_doc = tomlkit.parse(SRC.read_text(encoding="utf-8"))
    dst_text = DST.read_text(encoding="utf-8")
    dst_doc = tomlkit.parse(dst_text)

    src_tasks = (((src_doc.get("tool") or {}).get("poe") or {}).get("tasks")) or {}
    if not src_tasks:
        print(f"no [tool.poe.tasks] found in {SRC}", file=sys.stderr)
        return 2

    dst_tasks = get_table(dst_doc, ["tool", "poe", "tasks"])

    changed = False
    for name, value in src_tasks.items():
        if name not in dst_tasks or dst_tasks[name] != value:
            dst_tasks[name] = value
            changed = True

    # optional: enforce removal of tasks not in source-of-truth
    # for name in list(dst_tasks.keys()):
    #     if name not in src_tasks:
    #         del dst_tasks[name]
    #         changed = True

    new_text = tomlkit.dumps(dst_doc)
    if changed and new_text != dst_text:
        DST.write_text(new_text, encoding="utf-8")
        print("pyproject.toml updated: synced [tool.poe.tasks]")
    else:
        print("pyproject.toml already in sync")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
