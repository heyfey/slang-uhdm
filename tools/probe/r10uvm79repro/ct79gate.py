#!/usr/bin/env python3
"""r10uvm79repro/ct79gate.py — STATED GATE == CODE GATE, mechanically.

Reads src/ExprEmit.cpp and asserts, as a RUN rather than a sentence, that the
three laws' prose gates are the gates the code actually has:

  § hpMidSelIdxDecompiled79
     * the renderer `idxDecompile79` exists and its FIRST statement returns the
       old renderer unchanged when `mid` is false — the trailing-select gate is
       a short-circuit, not a scattered condition;
     * every place the hier_path NAME or a path element's own fullname is built
       from a selector inside emitMixedHierPath goes through it: 3 call sites,
       and ZERO surviving `idxText34(*<...>sel...)` name-building calls;
     * `mid79` is defined exactly TWICE and both definitions are the SAME
       predicate ("this component is not the last").

  § hpMidSelIdxAtPath79
     * both index-re-pointing sites are gated on `mid79 &&` and on the index
       expression being an ElementSelect or a RangeSelect — nothing else.

  § hpTailElemJoinsByScope79
     * ZERO hard-joined trailing path-element fullnames remain and exactly TWO
       are joinRef-joined.

Exit 0 = PASS, 5 = a gate in the prose is not the gate in the code, 4 = the
audit found no construction sites at all (a run that reached nothing must never
read as perfection), 2 = usage.

  usage: ct79gate.py <path/to/ExprEmit.cpp>

NEGATIVE CONTROL: run it on the PRISTINE ExprEmit.cpp — it must exit 5.
"""
import re, sys

if len(sys.argv) != 2:
    print("usage: ct79gate.py <ExprEmit.cpp>"); sys.exit(2)
src = open(sys.argv[1], errors='replace').read()
# Comments carry the laws' prose and quote the code; strip them so the audit
# reads CODE, not the write-up.  (A guard that greps its own documentation is
# the campaign's oldest trap.)
code = re.sub(r'//[^\n]*', '', src)
fails = []

def need(cond, msg):
    if not cond: fails.append(msg)

# ---- the builder must be there at all
if 'emitMixedHierPath' not in code:
    print("AUDIT FOUND NO emitMixedHierPath — reached nothing"); sys.exit(4)

# ---- § hpMidSelIdxDecompiled79
have_render = 'idxDecompile79' in code
need(have_render, "no idxDecompile79 renderer")
if have_render:
    m = re.search(r'idxDecompile79\s*=\s*\[[^\]]*\]\s*\([^)]*\)\s*->\s*std::string\s*\{\s*(.*?)\n\s{8}\};',
                  code, re.S)
    need(bool(m), "idxDecompile79 body not found")
    if m:
        first = m.group(1).strip().split('\n')[0].strip()
        need(first.startswith('if (!mid)'),
             "the trailing gate is not the FIRST statement of idxDecompile79: %r" % first)
        need('return idxText34(selExpr);' in m.group(1).split('\n')[1],
             "the !mid arm does not return the OLD renderer unchanged")
        need('ExpressionKind::ElementSelect' in m.group(1) and
             'ExpressionKind::RangeSelect' in m.group(1),
             "idxDecompile79 does not dispatch on ElementSelect/RangeSelect")
ncall = len(re.findall(r'idxDecompile79\(\*[^,]+,\s*mid79\)', code))
need(ncall == 3, "expected 3 mid79-gated idxDecompile79 call sites, found %d" % ncall)
leftover = re.findall(r'idxText34\(\*(?:comp\.)?sels?[^)]*\)', code)
need(not leftover, "a name is still built with the RAW renderer: %r" % leftover)
mids = re.findall(r'bool mid79 = ([^;]+);', code)
need(len(mids) == 2, "expected 2 mid79 definitions, found %d: %r" % (len(mids), mids))
need(set(mids) == {'i + 1 < comps.size()', '!lastMember'},
     "the two mid79 definitions are not the same predicate: %r" % mids)

# ---- § hpMidSelIdxAtPath79
sel_gates = re.findall(r'bool (selIdx79b?) =\s*(.*?);', code, re.S)
need(len(sel_gates) == 2, "expected 2 select-index gates, found %d" % len(sel_gates))
for nm, g in sel_gates:
    g = ' '.join(g.split())
    need(g.startswith('mid79 &&'), "%s is not gated on mid79: %r" % (nm, g))
    need('ExpressionKind::ElementSelect' in g and 'ExpressionKind::RangeSelect' in g,
         "%s does not test ElementSelect/RangeSelect: %r" % (nm, g))
    need('MemberAccess' not in g and 'Call' not in g and 'BinaryOp' not in g,
         "%s tests an index kind the law does not name: %r" % (nm, g))
nrep = len(re.findall(r'VpiParent\(hp\);\s*\n\s*setLoc\(\(UHDM::any\*\)ix,', code))
need(nrep == 2, "expected 2 index re-point sites (parent=hp + whole-range loc), found %d" % nrep)
# The two index prefixes this law adds are the ones bound to a selIdx79 gate;
# a THIRD `joinRef(prefix, dotted)` predates this pass at ExprEmit.cpp:12616
# (a method-call receiver prefix, nothing to do with a hier_path index), so
# counting the bare string would have read 3 and been silently "adjusted".
npfx = len(re.findall(r'selIdx79b? \? joinRef\(prefix, dotted\)', code))
need(npfx == 2,
     "expected 2 selIdx79-gated joinRef(prefix, dotted) index prefixes, found %d" % npfx)

# ---- § hpTailElemJoinsByScope79
hard = len(re.findall(r'VpiFullName\(prefix \+ "\." \+ comp\.name\)', code))
soft = len(re.findall(r'VpiFullName\(joinRef\(prefix, comp\.name\)\)', code))
need(hard == 0, "%d trailing path-element fullnames are still hard-joined" % hard)
need(soft == 2, "expected 2 joinRef-joined trailing path-element fullnames, found %d" % soft)

if fails:
    print("FAIL %s" % sys.argv[1])
    for f in fails: print("  - %s" % f)
    sys.exit(5)
print("PASS %s  3 mid79-gated renderer sites, 2 select-index gates, "
      "0 hard / 2 joinRef trailing joints" % sys.argv[1])
