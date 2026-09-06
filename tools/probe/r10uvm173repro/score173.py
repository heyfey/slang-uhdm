#!/usr/bin/env python3
"""r10uvm173repro/score173.py — SCORE ONE GRID ARM, cell for cell, against golden.

MEASUREMENT ONLY; the official ``uhdm-cmp`` is the sole judge.  LHS is ALWAYS
golden (Surelog); the two right-hand columns are the PRISTINE and PATCHED
binaries.

    score173.py <workdir> [--view def|elab|both] [--list]

Reads the ``bind.{g,a,b}.{def,elab}.txt`` rows ``grid173.sh`` wrote and joins
them as a MULTISET (keys collide — a plain dict drops rows).  The key is the
whole row minus the ``WOULDMOVE`` marker, so a cell that changed its
``callview->calleeview`` column shows up as one row leaving a bucket and one
row entering another.

It prints the four numbers a landing has to quote:

    TO-GOLDEN    cells where PATCHED agrees with golden and PRISTINE did not
    AWAY-GOLDEN  cells where PRISTINE agreed with golden and PATCHED does not
    STILL-WRONG  cells where neither agrees
    UNMOVED-OK   cells where both agree

AWAY-GOLDEN must be 0.  A view whose golden side holds NO ``PKGDEF`` row tests
nothing and is reported as ``EMPTY-GOLDEN`` rather than as a pass.
"""
import argparse
import collections
import os
import sys


def rows(path):
    out = collections.Counter()
    if not os.path.exists(path):
        return None
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip("\n")
            if "] BIND " not in ln:
                continue
            body = ln.split("] ", 1)[1]
            body = body.replace(" WOULDMOVE", "")
            out[body] += 1
    return out


def _drop_span(c):
    """Re-key a row counter with the trailing ``line:col`` field removed."""
    out = collections.Counter()
    for k, v in c.items():
        out[k.rsplit(" ", 1)[0]] += v
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("workdir")
    ap.add_argument("--view", default="both", choices=["def", "elab", "both"])
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--only", default="", help="substring a row must contain (e.g. PKGDEF)")
    ap.add_argument("--nospan", action="store_true",
                    help="drop the line:col field from the key.  No generated Compare "
                         "reads a span (RESUME.md §9), and a macro-expanded call's "
                         "SourceLocation legitimately differs between the two producers "
                         "(uvm_hdl_concat2string reads 150:52 in golden and 2089:60 in "
                         "ours), so a span-keyed census reports such a cell as one-sided "
                         "on BOTH sides and scores this pass's law for a difference that "
                         "predates it and that the judge cannot see.")
    ap.add_argument("--setmode", action="store_true",
                    help="score BUCKET MEMBERSHIP, not multiplicity: a listing that "
                         "carries a body twice where golden carries it once is a "
                         "COPY-COUNT residue of another family, and counting it here "
                         "reports this pass's law as wrong for a reason that is not "
                         "its own (arm A's elab class-method cells).")
    a = ap.parse_args()
    views = ["def", "elab"] if a.view == "both" else [a.view]
    grand = collections.Counter()
    for v in views:
        g = rows(os.path.join(a.workdir, f"bind.g.{v}.txt"))
        p = rows(os.path.join(a.workdir, f"bind.a.{v}.txt"))
        q = rows(os.path.join(a.workdir, f"bind.b.{v}.txt"))
        if g is None or p is None or q is None:
            print(f"[{v}] MISSING-SIDE — this view scored NOTHING")
            grand["MISSING"] += 1
            continue
        if a.only:
            for c in (g, p, q):
                for k in list(c):
                    if a.only not in k:
                        del c[k]
        if a.nospan:
            g, p, q = (_drop_span(g), _drop_span(p), _drop_span(q))
        if a.setmode:
            for c in (g, p, q):
                for k in list(c):
                    c[k] = 1
        if not g:
            print(f"[{v}] EMPTY-GOLDEN — this view tests nothing")
            grand["EMPTY"] += 1
            continue
        keys = set(g) | set(p) | set(q)
        to = away = still = ok = 0
        for k in sorted(keys):
            gn, pn, qn = g[k], p[k], q[k]
            if gn == pn == qn:
                ok += gn
                continue
            pref = (pn == gn)
            qref = (qn == gn)
            if qref and not pref:
                to += abs(qn - pn)
                if a.list:
                    print(f"[{v}] TO-GOLDEN   g={gn} a={pn} b={qn}  {k}")
            elif pref and not qref:
                away += abs(qn - pn)
                if a.list:
                    print(f"[{v}] AWAY-GOLDEN g={gn} a={pn} b={qn}  {k}")
            elif not pref and not qref:
                still += max(gn, pn, qn)
                if a.list:
                    print(f"[{v}] STILL-WRONG g={gn} a={pn} b={qn}  {k}")
            else:
                ok += gn
        print(f"[{v}] TO-GOLDEN={to} AWAY-GOLDEN={away} STILL-WRONG={still} UNMOVED-OK={ok}")
        grand["TO"] += to
        grand["AWAY"] += away
        grand["STILL"] += still
        grand["OK"] += ok
    print(f"TOTAL TO-GOLDEN={grand['TO']} AWAY-GOLDEN={grand['AWAY']} "
          f"STILL-WRONG={grand['STILL']} UNMOVED-OK={grand['OK']} "
          f"EMPTY-GOLDEN-VIEWS={grand['EMPTY']} MISSING-SIDES={grand['MISSING']}")
    return 1 if grand["AWAY"] or grand["MISSING"] else 0


if __name__ == "__main__":
    sys.exit(main())
