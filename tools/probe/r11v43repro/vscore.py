#!/usr/bin/env python3
# v11u43 VERIFIER scorer — independent of the implementer's score.py.
# For every cont_assign / assignment in a dump, report the Rhs constant's
# size/value/consttype/decompile, SECTIONED by def-view vs elab-view
# (|uhdmtopModules: starts the elaborated section) and keyed by src line.
import re, sys, subprocess, os
DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"
def ind(l): return len(l) - len(l.lstrip(' '))
def scan(text):
    lines = text.split('\n')
    sect = 'DEF'
    out = []
    for i, ln in enumerate(lines):
        if '|uhdmtopModules:' in ln: sect = 'ELAB'
        if '|uhdmallModules:' in ln: sect = 'DEF'
        m = re.search(r'\\_(cont_assign|assignment)\w*: .*?line:(\d+):(\d+)', ln)
        if not m: continue
        base = ind(ln); kind, sl, sc = m.group(1), m.group(2), m.group(3)
        cur = None; j = i+1
        while j < len(lines) and (lines[j].strip()=='' or ind(lines[j]) > base):
            s = lines[j].strip()
            if re.match(r'^\|vpi\w+:$', s): cur = s[1:-1]
            elif s.startswith('\\_constant:') and cur == 'vpiRhs':
                cb = ind(lines[j]); size=val=ct=dec='?'
                k=j+1
                while k < len(lines) and ind(lines[k]) > cb:
                    t = lines[k].strip()
                    mm = re.match(r'\|vpiSize:(-?\d+)', t)
                    if mm: size = mm.group(1)
                    mm = re.match(r'\|(UINT|INT|BIN|OCT|HEX|STRING|REAL|SCAL):(.*)', t)
                    if mm: val = mm.group(1)+':'+mm.group(2)
                    mm = re.match(r'\|vpiConstType:(\d+)', t)
                    if mm: ct = mm.group(1)
                    mm = re.match(r'\|vpiDecompile:(.*)', t)
                    if mm: dec = mm.group(1)
                    k+=1
                out.append((sect, sl, sc, kind, size, val, ct, dec))
            j+=1
    # dedup preserving order
    seen=[]
    for r in out:
        if r not in seen: seen.append(r)
    return seen
if __name__ == '__main__':
    root, tag, kindsel = sys.argv[1], sys.argv[2], (sys.argv[3] if len(sys.argv)>3 else 'gold')
    for a in sorted(os.listdir(root)):
        if kindsel=='gold': db = os.path.join(root,a,'slpp_all','surelog.uhdm')
        else: db = os.path.join(root,a,kindsel+'.uhdm')
        if not os.path.exists(db): print('%s %s NODB'%(tag,a)); continue
        try: t = subprocess.run([DUMP,db],capture_output=True,text=True,timeout=900).stdout
        except Exception as e: print('%s %s DUMPFAIL'%(tag,a)); continue
        rows = scan(t)
        if not rows: print('%s %s NOCONST'%(tag,a))
        for r in rows:
            print('%s %s %s L%s:%s %s size=%s %s ct=%s dec=%s'%(tag,a,r[0],r[1],r[2],r[3],r[4],r[5],r[6],r[7]))
