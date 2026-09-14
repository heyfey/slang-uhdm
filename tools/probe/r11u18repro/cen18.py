#!/usr/bin/env python3
"""cen18.py <gold.dump> <pris.dump> <pat.dump> [label]
KEYED directional census for the two r11u18 laws.  A line-multiset census is
BLIND to both of them (`|vpiLocalParam:1` and `|vpiTypespec:` are lines the
dump already carries many times), so each cell is keyed by the object it lives
on and the FIELD is the payload:

  TP  (section, 'type_parameter', fullname) -> vpiLocalParam
  ML  (section, struct name, member name)   -> the leftover's Actual typespec

TO-GOLDEN counts cells whose payload was != golden pristine and == golden
patched; AWAY-GOLDEN the reverse; STILL-WRONG the cells that disagreed before
and still disagree.  Cells absent on a side are keyed as ABSENT, never dropped
(a dict that drops a key manufactures agreement)."""
import sys, re, subprocess

def ind(l): return len(l) - len(l.lstrip(' '))

def cells(path):
    lines = open(path, errors='replace').read().split('\n')
    sec = 'HEAD'; struct = '?'; out = {}
    # uhdm-dump ABBREVIATES a repeat visit (the header line with no children).
    # An abbreviated line is the SAME OBJECT, not a missing one -- resolving it
    # to the payload of its full print is what keeps a listing that SHARES an
    # object (golden's elaborated type_parameter is the definition one) from
    # reading as ABSENT against a listing that mints a second copy.
    seen = {}
    for i, l in enumerate(lines):
        s = l.strip()
        if s.startswith('|uhdm'): sec = s.strip('|:')
        if s.startswith('\\_weaklyReferenced'): sec = 'weaklyReferenced'
        m = re.match(r'^(\s*)\\_struct_typespec: \(([^)]*)\)', l)
        if m: struct = m.group(2)
        m = re.match(r'^(\s*)\\_type_parameter: \(([^)]*)\)', l)
        if m:
            mi, name = len(m.group(1)), m.group(2)
            props = []
            j = i + 1
            while j < len(lines) and lines[j].strip() and ind(lines[j]) > mi:
                if ind(lines[j]) == mi + 2 and lines[j].strip().startswith('|'):
                    props.append(lines[j].strip())
                j += 1
            if props:
                pay = 'local=1' if any(p.startswith('|vpiLocalParam') for p in props) else 'local=0'
                seen[name] = pay
            else:
                pay = seen.get(name)
                if pay is None:
                    continue
            out[('TP', sec, name)] = pay
            continue
        m = re.match(r'^(\s*)\\_typespec_member: \(([^)]*)\)', l)
        if not m: continue
        mi, mem = len(m.group(1)), m.group(2)
        key = ('ML', sec, struct + '.' + mem)
        val = 'NO-LEFTOVER'
        j = i + 1
        while j < len(lines) and lines[j].strip() and ind(lines[j]) > mi:
            if lines[j].strip() == '|vpiExpr:' and ind(lines[j]) == mi + 2:
                hdr = lines[j + 1]; k = j + 2; val = 'leftover ts=NONE'
                while k < len(lines) and lines[k].strip() and ind(lines[k]) > ind(hdr):
                    if lines[k].strip() == '|vpiActual:' and ind(lines[k]) == ind(hdr) + 4:
                        val = 'leftover ts=' + re.sub(r', line:.*', '', lines[k + 1].strip().lstrip('\\_'))
                    k += 1
                break
            j += 1
        out.setdefault(key, val)
    return out

g, p, q = (cells(a) for a in sys.argv[1:4])
label = sys.argv[4] if len(sys.argv) > 4 else ''
to = away = still = 0; away_l = []; to_l = []
for k in set(g) | set(p) | set(q):
    gv, pv, qv = g.get(k, 'ABSENT'), p.get(k, 'ABSENT'), q.get(k, 'ABSENT')
    if pv == qv: 
        if gv != qv: still += 1
        continue
    if pv != gv and qv == gv: to += 1; to_l.append((k, gv, pv, qv))
    elif pv == gv and qv != gv: away += 1; away_l.append((k, gv, pv, qv))
    else: still += 1; away_l.append((k, gv, pv, qv))
print('%-34s TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d' % (label, to, away, still))
for k, gv, pv, qv in sorted(to_l)[:40]:
    print('   TO   %-12s %-16s %-46s g=%-28s pris=%-20s pat=%s' % (k[0], k[1], k[2], gv, pv, qv))
for k, gv, pv, qv in sorted(away_l)[:40]:
    print('   AWAY %-12s %-16s %-46s g=%-28s pris=%-20s pat=%s' % (k[0], k[1], k[2], gv, pv, qv))
