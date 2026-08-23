#!/usr/bin/env python3
# pred112.py — A-PRIORI mover predictor for § classTdCloneSpecOverridesOwnArgs112,
# read from a PRISTINE uhdm-dump ONLY (never from the patched side).
#
# A cell moves iff, in the pristine dump, a class_typespec
#   * carries a |vpiTypedefAlias  (it is a CLONE of a group base), AND
#   * carries its own |vpiParameter type_parameter whose actual typespec NAME
#     differs from the name the BASE's corresponding type_parameter carries.
# The base is reached through the alias ref_typespec's |vpiActual.
#
# Output: one PREDICT line per (owner class, typedef name, formal, ours -> base).
import sys, re, collections

IND = re.compile(r'^(\s*)')
def indent(l): return len(l) - len(l.lstrip())

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    return lines

def block(lines, i):
    """indices of the direct children region of the node opening at line i"""
    base = indent(lines[i]); j = i+1; out=[]
    while j < len(lines):
        l = lines[j]
        if not l.strip(): break
        if indent(l) <= base: break
        out.append(j); j += 1
    return out

NAME = re.compile(r'\\_(\w+): \(([^)]*)\)')

def field_child(lines, idxs, field, depth):
    """the node line that follows a |<field>: marker at the given depth"""
    res=[]
    for j in idxs:
        s = lines[j].strip()
        if s == '|'+field+':' and indent(lines[j]) == depth:
            if j+1 < len(lines): res.append(j+1)
    return res

# An UNNAMED typespec (`int_typespec: , line:71:18, endln:71:21`) has no
# parenthesised name, so NAME does not match it.  A type-parameter actual is
# very often exactly that -- pass 54's arm a1 binds T to `byte` / `short_int` /
# `int` -- and `VpiType` is the FIRST field every generated `Compare` reads, so
# those cells are judge-visible.  Identify a typespec by KIND plus (name or
# span); a class one still reads by name.
ANY = re.compile(r'\\_(\w+_typespec|\w+): (?:\(([^)]*)\))?\s*(?:, (line:\d+:\d+, endln:\d+:\d+))?')
def ts_ident(line):
    m = ANY.search(line)
    if not m: return None
    kind = m.group(1)
    if not kind.endswith('typespec'): return None
    return (kind, m.group(2) if m.group(2) else (m.group(3) or ''))

def actual_name(lines, j):
    """given a ref_typespec node line index, the IDENTITY of its |vpiActual"""
    d = indent(lines[j])
    for k in block(lines, j):
        if lines[k].strip() == '|vpiActual:' and indent(lines[k]) == d+2:
            return ts_ident(lines[k+1])
    return None

def tp_bindings(lines, j):
    """given a class_typespec node line index, {formal: actual-name}"""
    d = indent(lines[j]); out={}
    for k in block(lines, j):
        if lines[k].strip() == '|vpiParameter:' and indent(lines[k]) == d+2:
            tp = k+1
            m = NAME.search(lines[tp])
            if not m or m.group(1) != 'type_parameter': continue
            td = indent(lines[tp]); nm=None
            for q in block(lines, tp):
                s = lines[q].strip()
                if s.startswith('|vpiName:') and indent(lines[q]) == td+2:
                    nm = s.split(':',1)[1]
                if s == '|vpiTypespec:' and indent(lines[q]) == td+2:
                    nxt = lines[q+1]
                    if '\\_ref_typespec:' in nxt:
                        a = actual_name(lines, q+1)
                    else:
                        a = ts_ident(nxt)      # direct, un-indirected typespec
                    if nm is None: nm = '?'
                    out[nm] = a
    return out

def key_of(line):
    """(paren-text, span) identity for a dumped node line"""
    m = NAME.search(line)
    if not m: return None
    sp = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', line)
    return (m.group(1), m.group(2), sp.group(0) if sp else '')

def run(path, tag):
    lines = parse(path)
    # PASS 1 — global index: uhdm-dump prints a back-referenced object SHALLOW
    # (no children), so a clone's BASE is almost never expanded at the point the
    # alias names it.  Index every class_typespec occurrence by (paren-text,
    # span) and keep the RICHEST binding map seen anywhere in the dump.
    index = {}
    for i, l in enumerate(lines):
        k = key_of(l)
        if not k or k[0] != 'class_typespec': continue
        b = tp_bindings(lines, i)
        if b and len(b) > len(index.get(k, {})):
            index[k] = b
    # PASS 2 — every class_typespec that carries an alias is a CLONE.
    hits = collections.Counter()
    for i, l in enumerate(lines):
        k = key_of(l)
        if not k or k[0] != 'class_typespec': continue
        d = indent(l)
        al = [q for q in block(lines, i)
              if lines[q].strip() == '|vpiTypedefAlias:' and indent(lines[q]) == d+2]
        if not al: continue
        mine = tp_bindings(lines, i)
        if not mine: continue
        bj = al[0]+1
        bd = indent(lines[bj]); bidx = None
        for q in block(lines, bj):
            if lines[q].strip() == '|vpiActual:' and indent(lines[q]) == bd+2:
                bidx = q+1; break
        if bidx is None: continue
        bk = key_of(lines[bidx])
        if not bk: continue
        theirs = index.get(bk, {})
        if not theirs: continue
        owner = None
        for q in block(lines, i):
            s2 = lines[q].strip()
            if s2.startswith('|vpiFullName:') and indent(lines[q]) == d+2:
                owner = s2.split(':',1)[1]; break
        for f, a in mine.items():
            b = theirs.get(f)
            if b is not None and a is not None and a != b:
                hits[(owner or k[1], bk[1], f, a, b)] += 1
    for (o,t,f,a,b), n in sorted(hits.items()):
        print('PREDICT %s owner=%s base=%s formal=%s ours=%s -> base=%s  refs=%d'
              % (tag, o, t, f, a, b, n))
    print('PREDICT-TOTAL %s cells=%d refs=%d' % (tag, len(hits), sum(hits.values())))

for p in sys.argv[1:]:
    run(p, p)
