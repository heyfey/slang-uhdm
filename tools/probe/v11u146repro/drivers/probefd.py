import sys, os, subprocess, re
sys.path.insert(0, '/tmp/wt_v11u146pris/scripts'); os.chdir('/tmp/wt_v11u146pris')
import check_probe as cp
A, B, LIST = sys.argv[1], sys.argv[2], sys.argv[3]
SC = '/tmp/v11u146_bin/uhdm-strictcmp'
def first(g, o):
    r = subprocess.run([SC, '--max', '1', g, o], capture_output=True, text=True, timeout=600).stdout.split('\n')
    for i, l in enumerate(r):
        if l.startswith('#'): return int(l.split()[0][1:]), r[i+1] if i+1 < len(r) else '', r[i+2] if i+2 < len(r) else ''
    return None, '', ''
cnt = {}
for line in open(LIST):
    rel = line.split()[0]
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    f = rel.replace('/', '__') + '.uhdm'
    ia, ga, oa = first(g, os.path.join(A, f)); ib, gb, ob = first(g, os.path.join(B, f))
    if ia is None or ib is None: v = 'NOFD'
    elif ia < ib: v = 'LATER'
    elif ia > ib: v = 'EARLIER'
    else: v = 'SAME' if (ga, oa) == (gb, ob) else 'SAME_INDEX_OTHER_RECORD'
    cnt[v] = cnt.get(v, 0) + 1
    print(rel, ia, ib, v, line.split(' ', 1)[1].strip())
print(cnt, file=sys.stderr)
