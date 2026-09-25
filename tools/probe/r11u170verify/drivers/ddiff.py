#!/usr/bin/env python3
"""ddiff.py <case workdir> <on tag> <off tag>: order-blind uhdm-dump lines (paths and ids normalised) against the
case's golden: NEWBAD = lines ON has that golden lacks and OFF did not have; FIXED = OFF's bad lines ON lost;
LOST = golden lines OFF matched and ON does not.  Fail-closed on $FENCED."""
import os, re, sys, subprocess, collections
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('ddiff.py: source drivers/env.sh first')
w, on, off = sys.argv[1:4]
if any(re.search(rf'\b{re.escape(n)}\b', w) for n in os.environ['FENCED'].split()): sys.exit('fenced')
g = [f'{w}/{x}/golden.uhdm' for x in os.listdir(w) if x.startswith('gold_') and os.path.exists(f'{w}/{x}/golden.uhdm')][0]
def dump(f):
    t = subprocess.run([os.environ['UHDM_DUMP'], f], capture_output=True, text=True, errors='replace').stdout
    return collections.Counter(re.sub(r'id:\d+', '', re.sub(r'/[^ ,:()]*/', '', l)).strip() for l in t.splitlines() if 'Restored design' not in l)
G, A, B = dump(g), dump(f'{w}/{on}.uhdm'), dump(f'{w}/{off}.uhdm')
nb = (A - G) - (B - G); fx = (B - G) - (A - G); lost = ((G & B) - (G & A))
for name, c in (('NEWBAD', nb), ('FIXED', fx), ('LOST', lost)):
    print(f'== {name} {sum(c.values())}')
    for l, n in sorted(c.items()): print(f'  {n}x {l}')
