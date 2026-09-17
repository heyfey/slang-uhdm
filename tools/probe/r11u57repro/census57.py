"""r11u57 BLAST RADIUS — a `$bits(<type parameter>)` that is NOT the whole Rhs.

r11u53's census.py answered "which test directories call `$bits` on a type
parameter" (road A's whole radius).  This pass writes only the ELABORATED half
for a call BURIED inside a surviving expression, so the radius has to be split
one level finer: per USE SITE, is the `$bits(...)` the ENTIRE right-hand side
of the parameter/localparam assignment it sits in, or is there other text
around it?

The whole-Rhs sites are already golden (r11u53's `bitsOfTypeParamInit53`); the
BURIED ones are this pass's cells.  Printing BOTH classes per directory is what
makes a zero readable: a directory that carries only whole-Rhs sites is in the
counter's reach and is predicted NOT to move.

Usage: python3 census57.py            (both corpora, all three roots)
"""
import os, re, sys

roots = {'u2r': '/home/heyfey/git-repos/uhdm2rtlil/test',
         'sl': '/home/heyfey/git-repos/Surelog/tests',
         'sl3p': '/home/heyfey/git-repos/Surelog/third_party/tests'}
tpdecl = re.compile(r'\b(?:parameter|localparam)\s+type\s+([A-Za-z_]\w*)')
bitsuse = re.compile(r'\$bits\s*\(\s*([A-Za-z_]\w*)\s*\)')
# the Rhs of a parameter/localparam assignment, up to the separating `,` or `;`
assign = re.compile(r'=\s*([^,;]*)')


def classify(line, col, name):
    """WHOLE if the `$bits(name)` spans the whole Rhs of its assignment."""
    seg = line[:col]
    eq = seg.rfind('=')
    if eq < 0:
        return 'NO-ASSIGN'
    m = assign.match(line[eq:])
    if not m:
        return 'NO-ASSIGN'
    rhs = m.group(1).strip()
    # strip a trailing line comment
    c = rhs.find('//')
    if c >= 0:
        rhs = rhs[:c].strip()
    whole = re.fullmatch(r'\$bits\s*\(\s*' + re.escape(name) + r'\s*\)', rhs)
    return 'WHOLE' if whole else 'BURIED'


for tag, root in roots.items():
    if not os.path.isdir(root):
        print(f"{tag}\tMISSING-ROOT {root}")
        continue
    for d in sorted(os.listdir(root)):
        p = os.path.join(root, d)
        if not os.path.isdir(p):
            continue
        names, uses = set(), []
        for dp, _, fns in os.walk(p):
            if 'slpp_all' in dp or 'slpp_unit' in dp:
                continue
            for fn in fns:
                if not fn.endswith(('.sv', '.v', '.svh', '.vh')):
                    continue
                try:
                    txt = open(os.path.join(dp, fn), errors='replace').read()
                except Exception:
                    continue
                for m in tpdecl.finditer(txt):
                    names.add(m.group(1))
                for ln, line in enumerate(txt.splitlines(), 1):
                    if line.lstrip().startswith('//'):
                        continue
                    for m in bitsuse.finditer(line):
                        uses.append((os.path.relpath(os.path.join(dp, fn), p),
                                     ln, m.start(), m.group(1), line))
        if not names:
            continue
        tp = [u for u in uses if u[3] in names]
        if not tp:
            print(f"{tag}\t{d}\tTPDECL_ONLY bits_args={len({u[3] for u in uses})}")
            continue
        cls = [classify(u[4], u[2], u[3]) for u in tp]
        nb = cls.count('BURIED')
        nw = cls.count('WHOLE')
        print(f"{tag}\t{d}\tBURIED={nb} WHOLE={nw} "
              + ' '.join(f"{u[0]}:{u[1]}[{c}:{u[3]}]" for u, c in zip(tp, cls)))
