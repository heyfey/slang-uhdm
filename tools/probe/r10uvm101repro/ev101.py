#!/usr/bin/env python3
"""Extract event_stmt fields read by UHDM Compare from an uhdm-dump stream."""

import re
import sys

OBJ = re.compile(r"^(\s*)\\_([a-zA-Z0-9_]+):")
EVENT = re.compile(
    r"^(\s*)\\_event_stmt: (?:\((.*?)\))?.*?"
    r"line:(\d+):(\d+), endln:(\d+):(\d+)"
)
FILE = re.compile(r"(?:^|, )file:([^,]+)")


def emit(cur):
    if not cur:
        return
    # UHDM Compare does not read source spans.  Key on the start site so an
    # escaped identifier's pre-existing end-column mismatch does not turn a
    # name-field correction into two artificial cells.
    key = "%s:%s:%s" % (
        cur["file"],
        cur["sl"], cur["sc"],
    )
    value = "name=%s;blocking=%s" % (cur["name"], cur["blocking"])
    print("%s\t%s" % (key, value))


stack = []
current = None
for line in sys.stdin:
    raw = line.rstrip("\n")
    obj = OBJ.match(raw)
    if obj:
        indent = len(obj.group(1))
        if current and indent <= current["indent"]:
            emit(current)
            current = None
        while stack and stack[-1][0] >= indent:
            stack.pop()
        fm = FILE.search(raw)
        source = fm.group(1) if fm else (stack[-1][1] if stack else "")
        stack.append((indent, source))
        em = EVENT.match(raw)
        if em:
            current = {
                "indent": indent,
                "file": source,
                "sl": em.group(3), "sc": em.group(4),
                "el": em.group(5), "ec": em.group(6),
                "name": "", "blocking": "0",
            }
        continue
    if not current:
        continue
    indent = len(raw) - len(raw.lstrip())
    if indent != current["indent"] + 2:
        continue
    if "|vpiName:" in raw:
        current["name"] = raw.split("|vpiName:", 1)[1]
    elif "|vpiBlocking:" in raw:
        current["blocking"] = raw.split("|vpiBlocking:", 1)[1]

emit(current)
