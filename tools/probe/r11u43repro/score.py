#!/usr/bin/env python3
# r11u43 — read a uhdm-dump and report EVERY constant that sits directly under
# a cont_assign / assignment as the Rhs, with its size, value and const type,
# keyed by the assign's source line.  Measurement-only; no objects are minted.
import re, sys, subprocess, os

DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"

def dump(db):
    r = subprocess.run([DUMP, db], capture_output=True, text=True, timeout=600)
    return r.stdout

def indent(line):
    return len(line) - len(line.lstrip(' '))

def scan(text):
    lines = text.split('\n')
    out = []
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.search(r'\\_(cont_assign|assignment|cont_assign_bit):.*?line:(\d+):', ln)
        if m:
            base = indent(ln)
            kind, srcline = m.group(1), m.group(2)
            # walk the children of this object
            j = i + 1
            cur = None
            while j < len(lines) and (indent(lines[j]) > base or lines[j].strip() == ''):
                s = lines[j].strip()
                if s.startswith('|vpi') and s.endswith(':'):
                    cur = s[1:-1]
                elif s.startswith('\\_constant:') and cur in ('vpiRhs',):
                    # gather this constant's fields
                    cb = indent(lines[j])
                    size = val = ct = dec = '?'
                    k = j + 1
                    while k < len(lines) and indent(lines[k]) > cb:
                        t = lines[k].strip()
                        mm = re.match(r'\|vpiSize:(-?\d+)', t)
                        if mm: size = mm.group(1)
                        mm = re.match(r'\|(UINT|INT|BIN|OCT|HEX|STRING|REAL|SCAL):(.*)', t)
                        if mm: val = mm.group(1) + ':' + mm.group(2)
                        mm = re.match(r'\|vpiConstType:(\d+)', t)
                        if mm: ct = mm.group(1)
                        mm = re.match(r'\|vpiDecompile:(.*)', t)
                        if mm: dec = mm.group(1)
                        k += 1
                    out.append((srcline, kind, size, val, ct, dec))
                j += 1
        i += 1
    return out

if __name__ == '__main__':
    root = sys.argv[1]
    tag = sys.argv[2] if len(sys.argv) > 2 else 'GOLD'
    for a in sorted(os.listdir(root)):
        db = os.path.join(root, a, 'slpp_all', 'surelog.uhdm')
        if not os.path.exists(db):
            db = os.path.join(root, a, a + '.uhdm')
        if not os.path.exists(db):
            print('%s %s NODB' % (tag, a)); continue
        try:
            t = dump(db)
        except Exception as e:
            print('%s %s DUMPFAIL %s' % (tag, a, e)); continue
        rows = scan(t)
        seen = []
        for r in rows:
            if r not in seen:
                seen.append(r)
        if not seen:
            print('%s %s NOCONST' % (tag, a))
        for r in seen:
            print('%s %s line=%s %s size=%s %s ct=%s dec=%s' % (tag, a, r[0], r[1], r[2], r[3], r[4], r[5]))
