#!/usr/bin/env python3
"""r10rgg3/census.py — corpus-wide PREDICTION for § portViewRangeRecvParams.

For every test of both corpora it reads the SOURCE and reports the tests that can
possibly move, split into the two clauses of the law:

  RECVSUBST  a module with an interface PORT of an interface that declares a
             parameter the module ALSO declares (parameter or localparam) —
             the substitution can change that port view's member ranges.
  ARRELEM    an interface instantiated as an ARRAY with MORE THAN ONE distinct
             override text anywhere in the design, whose element port views
             stop reading the connected instance and start reading the
             (substituted) defaults.

It is deliberately a SOURCE scan, not an elaboration: it OVER-predicts (it does
not check that the port view is reference-style, nor that the values differ), so
it is an upper bound on the movers.  The byte verifier is the ground truth.
"""
import os, re, sys, glob

def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    return t

DECL = re.compile(r'\b(?:module|interface)\s+([A-Za-z_]\w*)', re.S)

def scan_text(t):
    """-> (iface_params{name:set}, mod_params{name:set}, mod_ifports{name:set(iface)},
            iface_array_overrides{iface:set(text)})"""
    t = strip_comments(t)
    ifp, mdp, mdip, arr = {}, {}, {}, {}
    # split into units at module/interface keywords
    units = []
    for m in re.finditer(r'\b(module|interface)\s+([A-Za-z_]\w*)', t):
        units.append((m.start(), m.group(1), m.group(2)))
    units.append((len(t), None, None))
    for i in range(len(units) - 1):
        st, kind, name = units[i]
        body = t[st:units[i + 1][0]]
        # parameter / localparam names declared in this unit
        pnames = set(re.findall(r'\b(?:parameter|localparam)\b[^;=,)]*?([A-Za-z_]\w*)\s*(?==|,|\)|;)',
                                body))
        pnames |= set(re.findall(r'\b(?:parameter|localparam)\s+(?:type\s+)?(?:\w+\s+)*?([A-Za-z_]\w*)\s*=',
                                 body))
        if kind == 'interface':
            ifp[name] = pnames
        else:
            mdp[name] = pnames
            # interface ports: `IF.mp p` or `IF p` inside the port list
            hdr = body.split(');', 1)[0]
            for mm in re.finditer(r'\b([A-Za-z_]\w*)\s*(?:\.\s*[A-Za-z_]\w*)?\s+([A-Za-z_]\w*)\s*(?:\[[^\]]*\])?\s*[,)]',
                                  hdr):
                mdip.setdefault(name, set()).add(mm.group(1))
        # interface ARRAY instantiations with an override
        for mm in re.finditer(r'\b([A-Za-z_]\w*)\s*#\s*\(([^;]*?)\)\s*([A-Za-z_]\w*)\s*\[[^\]]*\]\s*\(\s*\)',
                              body):
            arr.setdefault(mm.group(1), set()).add(re.sub(r'\s+', '', mm.group(2)))
        for mm in re.finditer(r'\b([A-Za-z_]\w*)\s*#\s*\(([^;]*?)\)\s*([A-Za-z_]\w*)\s*\(\s*\)', body):
            arr.setdefault(mm.group(1), set()).add(re.sub(r'\s+', '', mm.group(2)))
    return ifp, mdp, mdip, arr

def analyse(files):
    ifp, mdp, mdip, arr = {}, {}, {}, {}
    for f in files:
        try:
            t = open(f, errors='replace').read()
        except OSError:
            continue
        a, b, c, d = scan_text(t)
        ifp.update(a); mdp.update(b)
        for k, v in c.items(): mdip.setdefault(k, set()).update(v)
        for k, v in d.items(): arr.setdefault(k, set()).update(v)
    recv = []
    for mod, ifaces in mdip.items():
        for it in ifaces:
            if it not in ifp:
                continue
            common = ifp[it] & mdp.get(mod, set())
            if common:
                recv.append((mod, it, sorted(common)))
    arrmulti = sorted(k for k, v in arr.items() if k in ifp and len(v) > 1)
    return recv, arrmulti

def corpus_files():
    out = {}
    root = os.path.expanduser('~/git-repos/uhdm2rtlil/test')
    for d in sorted(os.listdir(root)):
        p = os.path.join(root, d)
        if not os.path.isdir(p):
            continue
        fs = sorted(glob.glob(p + '/*.sv') + glob.glob(p + '/*.v'))
        if fs:
            out['u2r/' + d] = fs
    sr = os.path.expanduser('~/git-repos/Surelog')
    for sl in sorted(glob.glob(sr + '/tests/*/*.sl') + glob.glob(sr + '/third_party/tests/*/*.sl')):
        d = os.path.dirname(sl)
        name = os.path.basename(sl)[:-3]
        fs = []
        for tok in open(sl, errors='replace').read().split():
            if tok.endswith(('.sv', '.v', '.svh')):
                fp = os.path.join(d, tok)
                if os.path.isfile(fp):
                    fs.append(fp)
        if fs:
            out['sl/' + name] = fs
    return out

if __name__ == '__main__':
    hits = 0
    for name, fs in sorted(corpus_files().items()):
        recv, arrmulti = analyse(fs)
        if not recv and not arrmulti:
            continue
        hits += 1
        print('%-46s RECVSUBST=%d ARRMULTI=%s' % (name, len(recv), ','.join(arrmulti) or '-'))
        for r in recv[:6]:
            print('      recv %s <- iface %s  shared=%s' % r)
    print('-- tests flagged:', hits)
