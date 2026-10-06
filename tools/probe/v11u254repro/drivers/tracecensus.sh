#!/bin/bash
# (v11u254: copied from r11u254repro/drivers)
# (r11u254: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers; R11U254_TRACE)
# tracecensus.sh <binary> <workroot>: the firing census of this pass's laws, run BEFORE the law sweep. The binary
# runs under R11U254_TRACE over the probe cases and both corpora in both modes (the harness itself dispatches; the
# filter built from $FENCED excludes the four fenced tests by exact name, the probe paths by word boundary), then
# every trace file is mapped through its `OUT <-o path>` line to the row-mode or probe case it wrote: the PREDICTED
# movers (predict.txt), one line per database with the laws that fired. Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "tracecensus.sh: FENCED unset" >&2; exit 2; }
BIN=$1; W=$2; [ -x "$BIN" ] || { echo "tracecensus.sh: binary not executable" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FR="$(echo $FENCED | tr ' ' '|')"
rm -rf $W; mkdir -p $W/trace
cd $REPO
export SLANG_UHDM=$BIN R11U254_TRACE=$W/trace
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
        if key: hits[key][l.split(' ', 1)[0]] += 1
for k in sorted(hits):
    print(k, ' '.join(f'{law}:{n}' for law, n in sorted(hits[k].items())))
PY
wc -l < $W/predict.txt
