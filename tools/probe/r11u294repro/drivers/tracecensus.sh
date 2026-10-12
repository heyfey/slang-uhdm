#!/bin/bash
# (r11u288: copied from r11u286repro/drivers; R11U294_TRACE, a tag ending in _ABSTAIN or a detail `off` moves nothing)
# (r11u282: copied from r11u280repro/drivers; R11U282_TRACE; a tag ending in _ABSTAIN moves nothing)
# (r11u280: copied from r11u278repro/drivers; R11U280_TRACE)
# (r11u278: copied from r11u276repro/drivers; R11U278_TRACE)
# (r11u276: copied from r11u274repro/drivers)
# (r11u274: copied from r11u272repro/drivers; R11U274_TRACE)
# (r11u270: copied from r11u271repro/drivers; R11U272_TRACE, abstain/off lines tagged)
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers; r11u259: R11U259_TRACE; r11u261: R11U261_TRACE)
# tracecensus.sh <binary> <workroot>: the firing census of this pass's laws, run BEFORE the law sweep. The binary
# runs under R11U294_TRACE over the probe cases and both corpora in both modes (the harness itself dispatches; the
# filter built from $FENCED excludes the four fenced tests by exact name, the probe paths by word boundary), then
# every trace file is mapped through its `OUT <-o path>` line to the row-mode or probe case it wrote: the PREDICTED
# movers (predict.txt), one line per database with the laws that fired. Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "tracecensus.sh: FENCED unset" >&2; exit 2; }
BIN=$1; W=$2; [ -x "$BIN" ] || { echo "tracecensus.sh: binary not executable" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FR="$(echo $FENCED | tr ' ' '|')"
rm -rf $W; mkdir -p $W/trace
cd $REPO
export SLANG_UHDM=$BIN R11U294_TRACE=$W/trace
python3 scripts/check_probe.py --jobs 3 --filter "^(?!.*\b(?:$FR)\b)" --workdir $W/probe --out $W/probe.csv > $W/probe.log 2>&1
for c in surelog uhdm2rtlil; do
  python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "^(?!(?:$FR)$)" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
done
python3 - "$W" "$FR" > $W/predict.txt <<'PY'
import os, re, sys, collections
W, FR = sys.argv[1:3]
fz = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % FR)
hits = collections.defaultdict(collections.Counter)
for f in os.listdir(f'{W}/trace'):
    key = None  # a reused pid appends a second `OUT` line to the same file
    for l in open(f'{W}/trace/{f}').read().splitlines():
        if l.startswith('OUT '):
            out = l[4:]
            if fz.search(out): sys.exit('FENCED path in a trace: refused')
            m = re.search(r'/(surelog|uhdm2rtlil)/(default|testflags)/(.+?)-[0-9a-f]{8}/', out)
            key = f'{m.group(1)} {m.group(3)}/{m.group(2)}' if m else 'probe ' + out.replace(W + '/probe/', '')
            continue
        if not key: continue
        w = l.split(' ')
        # r11u270: an abstention or a switched-off firing moves nothing; listed with a suffix
        tag = w[0] + ('/' + w[1] if len(w) > 1 and w[1] in ('abstain', 'off') else '')  # r11u274: abstain lines move nothing
        # r11u282: a tag ending in _ABSTAIN moves nothing
        hits[key][tag] += 1
for k in sorted(hits):
    print(k, ' '.join(f'{law}:{n}' for law, n in sorted(hits[k].items())))
PY
wc -l < $W/predict.txt
