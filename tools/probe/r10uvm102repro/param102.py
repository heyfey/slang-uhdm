#!/usr/bin/env python3
"""Extract comparator-visible parameter typespec presence from uhdm-dump."""

import re
import sys

OBJ = re.compile(r"^(\s*)\\_parameter: .*?line:(\d+):(\d+), endln:")
ANY_OBJ = re.compile(r"^(\s*)\\_[A-Za-z0-9_]+:")


def emit(cur):
    if not cur or not cur["full"]:
        return
    key = "%s@%s:%s#%s" % (
        cur["full"], cur["line"], cur["col"], cur["imported"]
    )
    print("%s\tts=%d" % (key, cur["ts"]))


current = None
for raw in sys.stdin:
    line = raw.rstrip("\n")
    obj = ANY_OBJ.match(line)
    if obj and current and len(obj.group(1)) <= current["indent"]:
        emit(current)
        current = None
    pm = OBJ.match(line)
    if pm:
        current = {
            "indent": len(pm.group(1)),
            "line": pm.group(2),
            "col": pm.group(3),
            "full": "",
            "imported": "",
            "ts": 0,
            "value": "",
        }
        continue
    if not current:
        continue
    indent = len(line) - len(line.lstrip())
    if indent != current["indent"] + 2:
        continue
    text = line.strip()
    if text == "|vpiTypespec:":
        current["ts"] = 1
    elif text.startswith("|vpiFullName:"):
        current["full"] = text.split(":", 1)[1]
    elif text.startswith("|vpiImported:"):
        current["imported"] = text.split(":", 1)[1]
    elif re.match(r"\|(BIN|OCT|DEC|HEX|INT|UINT|REAL|STRING):", text):
        current["value"] = text[1:]

emit(current)
