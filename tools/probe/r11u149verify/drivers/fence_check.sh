#!/bin/bash
# fence_check.sh: pass 144's predictor fence, re-checked without spelling or reading any fenced source.
# (1) the committed r11u144repro files never name a fenced test as a word (counts only; a superstring test name is allowed);
# (2) the committed predict_pristine.tsv holds no fenced row;
# (3) predict.py refuses to run without $FENCED (fail-closed) and, with it, reproduces the committed tsv byte for byte
#     from an unfenced-safe workdir (every row dir + cmds.txt; the scanner reads corpus sources, never a fenced directory:
#     checked by path first, (0) below).
source /tmp/wt_r11u149/tools/probe/r11u149verify/drivers/env.sh
R=/tmp/wt_r11u149/tools/probe/r11u144repro; W=${1:-/tmp/r11u149_wOF}
set -- $FENCED; echo "fenced names read from RESUME.md: $#"
python3 - <<'PY'
import os, glob
F=set(os.environ['FENCED'].split()); SR='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'; S={}
for b in (SR+'/tests', SR+'/third_party/tests'):
    for f in glob.glob(b+'/*/*.sl')+glob.glob(b+'/*/*/*.sl'): S.setdefault(os.path.basename(f)[:-3], os.path.dirname(f))
fd=set(S[n] for n in F if n in S)
ov=[n for n,d in S.items() if n not in F and any(d==x or d.startswith(x+'/') or x.startswith(d+'/') for x in fd)]
hits=0
for n,d in S.items():
    if n in F or not os.path.exists(os.path.join(d,n+'.sl')): continue
    for tok in open(os.path.join(d,n+'.sl'),errors='replace').read().split():
        for t in ([tok[2:]] if tok.startswith('-I') else [tok]):
            p=os.path.normpath(os.path.join(d,t)); hits+=any(p==x or p.startswith(x+'/') for x in fd)
print(f'(0) fenced dirs resolved {len(fd)}/{len(F)}; unfenced tests sharing a fenced scan dir: {len(ov)}; unfenced command-line tokens into a fenced dir: {hits}')
PY
i=0; for n in $FENCED; do i=$((i+1)); echo "(1) fenced #$i: word hits in r11u144repro = $(grep -rlw -- "$n" $R | wc -l); (2) rows in predict_pristine.tsv = $(awk -F'\t' -v n=$n '$3==n' $R/evidence/predict_pristine.tsv | wc -l)"; done
(unset FENCED; python3 $R/drivers/predict.py $W /tmp/r11u149_fence_nofence.tsv > /tmp/r11u149_fence_nofence.log 2>&1; echo "(3a) without FENCED: rc=$? output_written=$([ -e /tmp/r11u149_fence_nofence.tsv ] && echo yes || echo no)")
python3 $R/drivers/predict.py $W /tmp/r11u149_fence_rerun.tsv | sed 's/^/(3b) /'
cmp -s /tmp/r11u149_fence_rerun.tsv $R/evidence/predict_pristine.tsv && echo "(3c) rerun == committed predict_pristine.tsv: BYTE_IDENTICAL ($(md5sum < $R/evidence/predict_pristine.tsv | cut -c1-12))" || echo "(3c) rerun differs from committed"
