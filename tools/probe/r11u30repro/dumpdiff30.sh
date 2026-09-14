#!/usr/bin/env bash
# r11u30 — MEASUREMENT ONLY.  Whole-dump fidelity diff for ONE arm directory
# built by three99.sh: golden vs pristine and golden vs patched, with object ids
# and the workdir path normalised away.  Judge-INVISIBLE fields (vpiParent,
# spans) are included on purpose -- this is the instrument that catches a byte
# the official Compare cannot see.
set -u
D=${1:?arm workdir}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
cd "$D" || exit 9
for t in pris pat; do [ -f $t.uhdm ] && "$DUMP" $t.uhdm > $t.dump 2>/dev/null; done
python3 - "$D" <<'PY'
import re,sys,difflib,os
def norm(p):
    return [re.sub(r'file:[^,]*,','file:F,',re.sub(r'id:\d+','id:#',l)).rstrip('\n')
            for l in open(p,errors='replace')][1:]
g=norm('g.dump')
for t in ('pris','pat'):
    if not os.path.exists(t+'.dump'): continue
    d=[l for l in difflib.unified_diff(g,norm(t+'.dump'),'golden',t,lineterm='',n=0)
       if l.startswith(('+','-')) and not l.startswith(('---','+++'))]
    print('%-28s golden-vs-%-4s DIFFLINES %d' % (os.path.basename(sys.argv[1]), t, len(d)))
    for l in d[:40]: print('   ', l)
PY
