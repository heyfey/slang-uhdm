#!/usr/bin/env bash
# v83 VERIFIER arm scorer.  For each arm: run BOTH binaries + Surelog golden,
# print the official uhdm-cmp verdict for each binary AND the unsupported_typespec
# vpiInstance table three ways (GOLDEN / PRISTINE / PATCHED).
# A cell is PRISTINE-RIGHT->PATCHED-WRONG if a row that matched golden on the
# pristine binary no longer matches on the patched one.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
TS=$HERE/v83ts
for src in "$@"; do
  b=$(basename "$src"); b=${b%.sv}
  echo "======== $b"
  po=$(SLANG_UHDM=$PRIS "$HERE/v83arm.sh" "$src" /tmp/v83_ap_$b 2>&1)
  qo=$(SLANG_UHDM=$PATCHED "$HERE/v83arm.sh" "$src" /tmp/v83_aq_$b 2>&1)
  echo "  PRIS   $(echo "$po"|head -1)"
  echo "  PATCH  $(echo "$qo"|head -1)"
  G=/tmp/v83_ap_$b/slpp_all/surelog.uhdm
  if [ ! -f "$G" ]; then echo "  (no golden)"; continue; fi
  "$TS" "$G" > /tmp/v83_t_g_$b.txt 2>/dev/null
  [ -f /tmp/v83_ap_$b/slang.uhdm ] && "$TS" /tmp/v83_ap_$b/slang.uhdm > /tmp/v83_t_p_$b.txt 2>/dev/null || : > /tmp/v83_t_p_$b.txt
  [ -f /tmp/v83_aq_$b/slang.uhdm ] && "$TS" /tmp/v83_aq_$b/slang.uhdm > /tmp/v83_t_q_$b.txt 2>/dev/null || : > /tmp/v83_t_q_$b.txt
  python3 - "$b" <<'PYX'
import sys, collections
b=sys.argv[1]
def rd(p):
    d=collections.defaultdict(collections.Counter)
    for l in open(p):
        l=l.rstrip('\n')
        if not l.startswith('TS\t'): continue
        parts=l.split('\t')
        body=parts[1]; cnt=int(parts[2][1:])
        nm=body[:34].strip(); rest=body[34:].strip()
        sp,role=rest.rsplit(' ',1)
        d[(nm,sp.strip())][role]+=cnt
    return d
def fmt(c):
    if not c: return 'ABSENT'
    return ','.join('%sx%d'%(k,v) for k,v in sorted(c.items()))
G=rd('/tmp/v83_t_g_%s.txt'%b); P=rd('/tmp/v83_t_p_%s.txt'%b); Q=rd('/tmp/v83_t_q_%s.txt'%b)
keys=sorted(set(G)|set(P)|set(Q))
regress=0; fixed=0
for k in keys:
    g=fmt(G.get(k)); p=fmt(P.get(k)); q=fmt(Q.get(k))
    mark=''
    if p==g and q!=g: mark='  <<< PRISTINE-RIGHT->PATCHED-WRONG'; regress+=1
    elif p!=g and q==g: mark='  *** FIXED'; fixed+=1
    elif p!=q: mark='  ~~~ MOVED (both differ from golden)'
    print("  %-26s %-20s G=%-28s P=%-28s Q=%-28s%s"%(k[0],k[1],g,p,q,mark))
print("  -- REGRESSED=%d FIXED=%d"%(regress,fixed))
PYX
done
