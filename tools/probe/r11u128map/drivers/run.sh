#!/bin/bash
# The r11u128 map pipeline (measurement only). W = scratch work dir.
# Inputs: a strict sweep workdir (tests/sweep.sh --workdir SW with SLANG_UHDM and STRICT_CMP exported)
# holding <corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt} and probe/<rel __>.uhdm.
set -eu
DR=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$DR/../../../.." && pwd)
SW=${SW:?sweep workdir}; W=${W:?work dir}; export SCMP=${SCMP:?frozen uhdm-strictcmp}
mkdir -p "$W"; cd "$W"
python3 "$DR/jobs.py" "$REPO/results/golden_surelog.csv" "$REPO/results/golden_uhdm2rtlil.csv" "$SW" jobs_int.tsv
DUMPS=$W/dumps; export DUMPS
awk -F'\t' '{print $1,$2,$3,$4,$5}' jobs_int.tsv | xargs -P3 -n5 "$DR/run1.sh"
( cd "$REPO" && python3 "$DR/probejobs.py" "$REPO" "$SW/probe" "$W/probejobs.tsv" )
DUMPS=$W/pdumps awk -F'\t' '{print $1,$2,$3,$4,$5}' probejobs.tsv | DUMPS=$W/pdumps xargs -P3 -n5 "$DR/run1.sh"
: > probe_ne.tsv; : > probe_verdict.tsv
while IFS=$'\t' read c m n g o rel; do f=$W/pdumps/probe/default/$n.out
  if grep -q '^rc=2' "$f"; then printf '%s\t%s\t%s\t%s\t%s\t%s\n' $c $m $n $g $o $rel >> probe_ne.tsv
    printf '%s\t%s\n' $rel "$(grep -o '^STRICT_NOTEQUAL .*' $f | cut -d' ' -f2)" >> probe_verdict.tsv; fi
done < probejobs.tsv
( cd "$REPO" && python3 "$DR/probelaw.py" ) > probe_law.tsv
# analyze.py reads <dumps>/<corpus>/<mode>/<test>.{a,b}
python3 "$DR/analyze.py" jobs_int.tsv corpus.jsonl "$W/dumps" 3
python3 "$DR/analyze.py" probe_ne.tsv probe.jsonl "$W/pdumps" 3
# evid.py / tsspan.py / pinprep.py name /tmp/r11u128_dumps and /tmp/r11u128_pdumps: link them or edit.
python3 "$DR/tsspan.py" "$W" corpus "$W/dumps" > tsspan.txt
cp "$DR/../evidence/coverage_overrides.json" sites.json
python3 "$DR/final.py" "$W" "$REPO" "$W/out" > final_all.txt
python3 "$DR/fullname_classes.py" "$W" > fnclass.txt
# Site pinning (needs an exporter built with -g1 line tables; its output must be byte-identical):
#   c++ -std=c++20 -O2 -I$HOME/.local/include objrank.cpp -o objrank $HOME/.local/lib64/{libuhdm,libcapnp,libkj}.a -ldl -lutil -lm -lrt -lpthread
#   python3 pinprep.py $W $REPO ./objrank K0017 ... > pinprep.tsv; python3 pinall.py pinprep.tsv <exporter.g1> $REPO/src pins.txt
