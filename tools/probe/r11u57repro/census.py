import os, re, sys
roots = {'u2r':'/home/heyfey/git-repos/uhdm2rtlil/test',
         'sl':'/home/heyfey/git-repos/Surelog/tests',
         'sl3p':'/home/heyfey/git-repos/Surelog/third_party/tests'}
tpdecl = re.compile(r'\b(?:parameter|localparam)\s+type\s+([A-Za-z_]\w*)')
bits   = re.compile(r'\$bits\s*\(\s*([A-Za-z_]\w*)\s*\)')
for tag, root in roots.items():
    for d in sorted(os.listdir(root)):
        p = os.path.join(root, d)
        if not os.path.isdir(p): continue
        names, uses = set(), []
        for dp, _, fns in os.walk(p):
            if 'slpp_all' in dp or 'slpp_unit' in dp: continue
            for fn in fns:
                if not fn.endswith(('.sv','.v','.svh','.vh')): continue
                try: txt = open(os.path.join(dp,fn), errors='replace').read()
                except Exception: continue
                for m in tpdecl.finditer(txt): names.add(m.group(1))
                for m in bits.finditer(txt): uses.append((os.path.relpath(os.path.join(dp,fn),p), m.group(1)))
        if not names: continue
        hit = sorted({u[1] for u in uses if u[1] in names})
        if hit:
            print(f"{tag}\t{d}\tTPARG={','.join(hit)}")
        elif uses:
            print(f"{tag}\t{d}\tTPDECL_ONLY bits_args={len({u[1] for u in uses})}")
        else:
            print(f"{tag}\t{d}\tTPDECL_ONLY no_bits")
