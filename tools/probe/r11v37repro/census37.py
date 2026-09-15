import os, re, sys
roots = [os.path.expanduser('~/git-repos/uhdm2rtlil/test'),
         os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests')]
BUILT = set('logic bit byte int integer shortint longint real shortreal time reg wire string chandle event void signed unsigned struct union enum virtual'.split())
k1 = re.compile(r'\b(?:parameter|localparam)\s+type\s+([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\s*(?=[,;)])', re.S)
# ordered or named type override whose range holds an identifier
k2 = re.compile(r'#\s*\(([^;]{0,4000}?)\)\s*[A-Za-z_]\w*\s*\(', re.S)
ident = re.compile(r'\$bits\s*\(\s*([A-Za-z_]\w*)|(?<![\w.$])([A-Za-z_]\w*)\s*[-+*/\]]')
def strip(s):
    s = re.sub(r'/\*.*?\*/', ' ', s, flags=re.S)
    s = re.sub(r'//[^\n]*', ' ', s)
    return s
n1 = n2 = 0
for r in roots:
    for dp, dn, fn in os.walk(r):
        for f in fn:
            if not f.endswith(('.sv', '.v', '.svh')): continue
            p = os.path.join(dp, f)
            try: t = strip(open(p, errors='ignore').read())
            except Exception: continue
            for m in k1.finditer(t):
                if m.group(2) in BUILT: continue
                n1 += 1
                print('K1', p.replace(os.path.expanduser('~/git-repos/'), ''), t[:m.start()].count('\n')+1, m.group(0).strip()[:70])
            for m in k2.finditer(t):
                body = m.group(1)
                if not re.search(r'\b(logic|bit|reg|byte|int|integer|shortint|longint)\s*\[', body): continue
                # ranges only
                for rng in re.finditer(r'\[([^\[\]]*)\]', body):
                    inner = rng.group(1)
                    ids = [x for x in re.findall(r'(?<![\w.$`])([A-Za-z_]\w*)', inner) if x not in BUILT]
                    if ids:
                        n2 += 1
                        print('K2', p.replace(os.path.expanduser('~/git-repos/'), ''), t[:m.start()].count('\n')+1, ('#('+body.strip()[:90]).replace('\n',' '))
                        break
print('K1 sites:', n1, ' K2 sites:', n2)
