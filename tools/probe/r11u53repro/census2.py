import os, re
roots = {'u2r':'/home/heyfey/git-repos/uhdm2rtlil/test',
         'sl':'/home/heyfey/git-repos/Surelog/tests',
         'sl3p':'/home/heyfey/git-repos/Surelog/third_party/tests'}
tpdecl = re.compile(r'\b(?:parameter|localparam)\s+type\s+([A-Za-z_]\w*)')
bitsany= re.compile(r'\$bits\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)')
for tag, root in roots.items():
    for d in sorted(os.listdir(root)):
        p = os.path.join(root, d)
        if not os.path.isdir(p): continue
        names, args = set(), []
        for dp, _, fns in os.walk(p):
            if 'slpp_all' in dp or 'slpp_unit' in dp: continue
            for fn in fns:
                if not fn.endswith(('.sv','.v','.svh','.vh')): continue
                try: txt = open(os.path.join(dp,fn), errors='replace').read()
                except Exception: continue
                for m in tpdecl.finditer(txt): names.add(m.group(1))
                for m in bitsany.finditer(txt): args.append(m.group(1).strip())
        if not names or not args: continue
        hit = sorted({a for a in args if set(re.findall(r'[A-Za-z_]\w*', a)) & names})
        if hit: print(f"{tag}\t{d}\tN={len(hit)}\t{'; '.join(hit[:6])}")
