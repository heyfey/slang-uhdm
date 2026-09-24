#!/usr/bin/env python3
"""dsgold.py <regex>: for every uhdm2rtlil corpus test matching, print
`<name> <cached downstream-lane golden path or MISS> <slang argv>`.
The downstream-lane golden is uhdm2rtlil's own Surelog with the downstream
flags, exactly as scripts/downstream_uhdm2rtlil.py keys it.  Builds nothing.
Run from the repo root."""
import hashlib, os, sys
sys.path.insert(0, 'scripts')
import verify_golden as vg
import downstream_uhdm2rtlil as ds
ident = ds.surelog_identity()
for name, (d, parts) in sorted(vg.discover_uhdm2rtlil(sys.argv[1]).items()):
    rest = [p for p in parts if p not in ('-parse', '-nobuiltin', '-nocache')]
    sl_args = ['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest
    su_args, _, _, nob = vg.translate(sl_args)
    if nob:
        su_args.append('--nobuiltin')
    key = [ident, vg._portable(d)] + [vg._portable(a) for a in sl_args]
    if vg._reaches_outside(sl_args):
        key.append(os.path.abspath(d))
    cdir = os.path.join(vg.CACHE_ROOT, hashlib.sha1('\0'.join(key).encode()).hexdigest()[:20])
    hit = vg.cache_load(cdir)
    print(name, hit[1] if hit and hit[1] else 'MISS', d, ' '.join(su_args))
