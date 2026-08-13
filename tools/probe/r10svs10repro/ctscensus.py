#!/usr/bin/env python3
"""r10svs10 — count a dump's CARRIER nets for § classHandleWriteKeepsTs10.

Reads a uhdm-dump (already `sed 1d`'d) on stdin and prints ONE number: how many
DEF-VIEW nets carry NO vpiTypespec while a `class_var` of the same vpiFullName
exists elsewhere in the database.  That pairing is the carrier shape -- the def
view says nothing about the net's type, and the elab twin proves it is a class
handle.

Shares ctsread.py's tree walk: descend only into fields that are NOT vpiParent,
so a net reprinted inside its own subtree as a back-pointer is never counted.
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ctsread  # noqa: E402  (the reader whose walk we reuse)


def main():
    data = sys.stdin.read()
    import tempfile
    with tempfile.NamedTemporaryFile('wt', suffix='.dump', delete=False) as f:
        f.write(data)
        path = f.name
    try:
        cells = ctsread.collect(path)
    finally:
        os.unlink(path)
    # every fullname that appears as a class_var anywhere (the elab twin)
    classnames = {c[1] for c in cells if c[3] == 'class_var'}
    n = 0
    for (scope, name, span, kind, val) in cells:
        if kind != 'class_var' and val == 'NONE':
            # the def-view net's fullname, or its elab-qualified tail
            tail = name.split('.')[-1]
            if name in classnames or any(
                    cn.split('.')[-1] == tail for cn in classnames):
                n += 1
    print(n)


main()
