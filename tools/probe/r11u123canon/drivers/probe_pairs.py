#!/usr/bin/env python3
"""The 2833 probe arms as extra (golden, ours) pairs for the identity check: the
golden from the probe golden cache (check_probe.cache_dir; a MISS is reported, never
built), ours written fresh by $SLANG_UHDM.  Output: pairs.tsv rows (corpus=probe).
usage: probe_pairs.py <repo worktree> <outdir> > probe_pairs.tsv"""
import concurrent.futures, os, subprocess, sys
repo, outdir = sys.argv[1], sys.argv[2]
sys.path.insert(0, os.path.join(repo, 'scripts'))
import check_probe as cp  # noqa: E402
import verify_golden as vg  # noqa: E402
SU = os.environ['SLANG_UHDM']
os.makedirs(outdir, exist_ok=True)


def one(rel):
    hit = vg.cache_load(cp.cache_dir(rel))
    g = hit[1] if hit and hit[1] else '-'
    o = os.path.join(outdir, rel.replace('/', '__') + '.uhdm')
    if os.path.exists(o):
        os.remove(o)
    subprocess.run([SU] + cp.SU_ARGS + ['-o', o], cwd=os.path.join(cp.ROOT, rel),
                   capture_output=True, timeout=300)
    if not os.path.exists(o) or os.path.getsize(o) == 0:
        o = '-'
    return '\t'.join(['probe', 'default', rel, '-', '-', g, o, SU, '1'])


with concurrent.futures.ThreadPoolExecutor(3) as pool:
    for line in pool.map(one, cp.arms(None)):
        print(line, flush=True)
