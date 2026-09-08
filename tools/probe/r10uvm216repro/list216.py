#!/usr/bin/env python3
"""r10uvm216 — pretty-print a `ct216cen` keycount as per-holder ORDERED listings.

MEASUREMENT ONLY.  Reads the POS| family (holder x index x payload) and prints
one block per holder in index order, so golden and ours can be read side by
side.  `--holder <substr>` restricts to holders whose key contains <substr>;
`--dpi` keeps only holders that hold at least one DPI-marked entry.

usage: list216.py <file.kc> [--holder S] [--dpi]
"""
import sys
from collections import defaultdict


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    args = sys.argv[2:]
    want = None
    if "--holder" in args:
        want = args[args.index("--holder") + 1]
    dpi_only = "--dpi" in args
    holders = defaultdict(list)
    with open(sys.argv[1]) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line.startswith("POS|") and "\tPOS|" not in line:
                continue
            _, _, key = line.partition("\t")
            parts = key.split("|")
            if len(parts) < 3:
                continue
            holder = parts[1]
            if want and want not in holder:
                continue
            holders[holder].append(key)
    for h in sorted(holders):
        rows = sorted(holders[h])
        if dpi_only and not any("acc=EXPORT" in r or "acc=IMPORT" in r for r in rows):
            continue
        print(f"HOLDER {h}  n={len(rows)}")
        for r in rows:
            print("   " + r.split("|", 2)[2])
    return 0


if __name__ == "__main__":
    sys.exit(main())
