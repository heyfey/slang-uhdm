#!/usr/bin/env python3
"""r10uvm157 — score ONE grid arm: golden vs a binary, statement-scope TYPESPEC
LISTING cell by cell.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
G/LHS is ALWAYS golden (Surelog).

ct157cen prints ONE row per scope (so a scope that lists NOTHING is a row — the
AWAY column is only scorable when "listed nothing" is a value and not a gap)
and one row per listing ENTRY carrying its INDEX (so the ORDER is measured).

Cell KEY  = (VIEW, OWNER, SKIND, DEPTH, SKEY, SNAME).
Cell VALUE = the sorted SET of that key's tokens (a SET, not a multiset, for
score155.py's reason: one source scope can appear more than once under the same
key — a package task_func is reachable from both the definition listing and the
elaborated one, and the two producers materialise different NUMBERS of those
copies.  That multiplicity is a different law's and would drown this one; the
`N=` token still carries each distinct listing COUNT, so a genuine size
disagreement inside a scope is unaffected):
    N=<count|null>                             from the SCOPE row
    I<idx>=<tskind>|<tsname>|<tsspan>|<tsinst>|<range>|<alias>   per entry

SKEY is the scope's own span, EXCEPT for a scope hanging directly off a
task/function (its body), where ct157cen prints the literal `#body`: a
subroutine body's SYNTHESISED `begin` is anchored at the second body item by
Surelog and at the first executable statement by us — a PRE-EXISTING residue of
a different law, invisible to every generated `Compare` (RESUME §9: no Compare
reads a line or a column).  The scope's `Variables()` names are a COLUMN of the
census and are neither key nor payload, for the same reason: our list carries an
array/queue/associative local's ELEMENT variable and golden's may not, which is
a different law again.  Run with --span to put the real span back in the value.

--listed drops every cell where NEITHER side lists anything (only `N=null` /
`N=0` tokens on both).  Those cells are outside this law by construction — it
only ever ADDS a listing — and they carry a MULTIPLICITY artifact that would
otherwise drown the signal: a builtin class's `task`/`function` appears once in
golden and twice in ours under the same (view, owner, kind, depth, vars) key,
which is a listing-blind duplicate, not a listing difference.  A cell where the
PATCHED side lists something golden does not is NEVER dropped — that is the AWAY
column and it must stay visible.

usage: score157.py <cen.g.txt> <cen.o.txt> [--span] [--listed] [name-prefix ...]
"""
import sys, collections

args = [a for a in sys.argv[1:] if not a.startswith("--")]
WANT_SPAN = "--span" in sys.argv
LISTED_ONLY = "--listed" in sys.argv
# --noowner drops the OWNER column from the key.  Needed for exactly one thing:
# in the ELABORATED view golden spells a module subroutine's `VpiFullName` with
# the INSTANCE path (`work@top26v.u.f26`) and we spell it with the DEFINITION
# (`work@amod26v.f26`) — a PRE-EXISTING residue of a different law, and one no
# generated `Compare` reads (RESUME §9: VpiFullName is dump-only).  With the
# owner in the key those cells pair up wrongly and read as ONLY-G / ONLY-O.
NO_OWNER = "--noowner" in sys.argv

def empty(v):
    return v is None or all(t.startswith("N=null") or t.startswith("N=0") for t in v)

def load(p):
    m = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 3:
            continue
        if f[1] == "SCOPE":
            if len(f) < 10:
                continue
            k = (f[2], "-" if NO_OWNER else f[3], f[4], f[5], f[6], f[7])
            m[k].append("N=" + f[8] + (("@" + f[10]) if WANT_SPAN else ""))
        elif f[1] == "TSENT":
            if len(f) < 14:
                continue
            k = (f[2], "-" if NO_OWNER else f[3], f[4], f[5], f[6], "")
            # the TSENT row has no SNAME column; recover it by matching the
            # SCOPE row's key prefix at compare time
            m[("TSENT",) + k[:5]].append(
                "I" + f[7] + "=" + "|".join([f[8], f[9], f[10], f[11], f[12], f[13]]))
    # fold the TSENT bucket into every SCOPE key sharing its 5-tuple prefix
    out = {}
    for k, v in m.items():
        if k[0] == "TSENT":
            continue
        ents = m.get(("TSENT",) + k[:5], [])
        out[k] = sorted(set(v + ents))
    return out

g = load(args[0]); o = load(args[1])
pref = tuple(args[2:])
same = diff = og = oo = 0
for k in sorted(set(g) | set(o)):
    if pref and not (k[1].startswith(pref) or k[5].startswith(pref)):
        continue
    gv = g.get(k); ov = o.get(k)
    if LISTED_ONLY and empty(gv) and empty(ov):
        continue
    if gv is None:
        oo += 1; print(f"ONLY-O\t{k}\t{ov}"); continue
    if ov is None:
        og += 1; print(f"ONLY-G\t{k}\t{gv}"); continue
    if gv == ov:
        same += 1; print(f"SAME\t{k}\t{gv}")
    else:
        diff += 1
        print(f"DIFF\t{k}\n     G={gv}\n     O={ov}")
print(f"-- SAME={same} DIFF={diff} ONLY-G={og} ONLY-O={oo}")
