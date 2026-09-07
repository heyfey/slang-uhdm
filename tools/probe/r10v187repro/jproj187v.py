# r10v187 -- project a ct187cen VALUE onto ONLY the fields a generated Compare
# reads: kind, VpiName, the alias target's kind+VpiName, Ranges count, VpiSigned
# and Instance.  DROPPED: @span (BaseClass::Compare reads VpiType/VpiName/
# VpiDefName only -- no generated Compare reads line/col), apar (VpiParent is
# read by NO generated Compare) and nsh (a sharing fan-out, not a field).
import re, sys
def proj(v):
    v = re.sub(r'@\d+:\d+-\d+:\d+', '', v)
    v = re.sub(r' apar=\S+', '', v)
    v = re.sub(r' nsh=\d+', '', v)
    return v
for line in open(sys.argv[1]):
    p = line.rstrip('\n').split('\t')
    if len(p) < 6: continue
    p[5] = proj(p[5])
    print('\t'.join(p))
