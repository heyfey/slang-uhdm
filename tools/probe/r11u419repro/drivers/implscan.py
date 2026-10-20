#!/usr/bin/env python3
# r11u419 implscan.py <listfile>: predict § implicitPortParamListedFirst419 / § implicitPortPaLastIface419
# on source files. For each module/interface header parameter port list, classify each comma entry:
# K = starts with parameter/localparam, T = keyword-less with a data type, I = keyword-less untyped
# (inherits the previous entry's group). Prints FIRST when a T/I-in-T-group entry follows a K entry
# (the Parameters reorder), IFACE when an interface's list has a keyword-less entry (the elab
# param_assign demotion now reaching interfaces), IMPMIX when a module or interface with a
# keyword-less entry also has a package import in its header or body (rank after imports).
import sys, re
KW = re.compile(r'^\s*(parameter|localparam)\b')
TYP = re.compile(r'^\s*(int|integer|logic|bit|reg|byte|shortint|longint|real|realtime|shortreal|string|time|signed|unsigned|type|[A-Za-z_]\w*(::\w+)?\s+(\[|[A-Za-z_]))')
def strip(s):
    s = re.sub(r'/\*.*?\*/', ' ', s, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', s)
for path in open(sys.argv[1]).read().split():
    try: src = strip(open(path, errors='replace').read())
    except Exception: continue
    for m in re.finditer(r'\b(module|interface|program)\s+(?:static\s+|automatic\s+)?(\w+)\s*((?:import\s[^;]*;\s*)*)#\s*\(', src):
        i = m.end(); depth = 1; j = i
        while j < len(src) and depth:
            if src[j] == '(': depth += 1
            elif src[j] == ')': depth -= 1
            j += 1
        body = src[i:j-1]
        ents = []; d = 0; cur = ''
        for ch in body:
            if ch in '([{': d += 1
            if ch in ')]}': d -= 1
            if ch == ',' and d == 0: ents.append(cur); cur = ''
            else: cur += ch
        ents.append(cur)
        grp = None; sawK = False; first = False; anyImpl = False
        for e in ents:
            if not e.strip(): continue
            if KW.match(e): grp = 'K'; sawK = True
            elif TYP.match(e) and '=' in e and not re.match(r'^\s*\w+\s*=', e): grp = 'T'
            elif grp is None: grp = 'T'
            if grp == 'T':
                anyImpl = True
                if sawK: first = True
        kind, name = m.group(1), m.group(2)
        if first: print('FIRST', path, kind, name)
        if anyImpl and kind == 'interface': print('IFACE', path, kind, name)
        if anyImpl:
            end = src.find('end' + kind, j)
            if m.group(3) or re.search(r'\bimport\s+\w+::', src[j:end if end > 0 else len(src)]):
                print('IMPMIX', path, kind, name)
