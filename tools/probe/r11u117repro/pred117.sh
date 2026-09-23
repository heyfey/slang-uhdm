#!/bin/bash
# pred117.sh <sweep-workdir-root> <law-binary> <out> <row>... — A-PRIORI mover
# prediction: re-run each named candidate row's recorded slang command (from the
# PRISTINE sweep's cmds.txt, cwd = its discovered source dir) with the LAW binary
# and R11U117_DBG=1, and print which laws' detectors fire (QSELFIRE117 /
# BITS117).  The database it writes is scratch, never a sweep root.
ROOT=${1:?}; BIN=${2:?}; OUT=${3:?}; shift 3
mkdir -p "$OUT"
for row in "$@"; do
  for cf in "$ROOT"/*/"$row"-*/cmds.txt; do
    [ -f "$cf" ] || continue
    w=$(dirname "$cf"); mode=$(basename "$(dirname "$w")")
    argv=$(grep '^slang:' "$cf" | tail -1 | sed 's/^slang: *//')
    dir=$(python3 - "$row" "$w" <<'PY'
import sys, hashlib
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import verify_golden as vg
row, w = sys.argv[1], sys.argv[2]
h = w.rsplit('-', 1)[1]
for disc in (vg.discover_surelog, vg.discover_uhdm2rtlil):
    for n, (d, _a) in disc('^' + row + '$').items():
        if n == row and hashlib.sha1(d.encode()).hexdigest()[:8] == h: print(d)
PY
)
    [ -n "$dir" ] || { echo "$row $mode NODIR"; continue; }
    eval "set -- $argv"; shift; args=()
    while [ $# -gt 0 ]; do if [ "$1" = -o ]; then shift 2; continue; fi; args+=("$1"); shift; done
    o="$OUT/$row.$mode.uhdm"
    (cd "$dir" && R11U117_DBG=1 timeout 600 "$BIN" "${args[@]}" -o "$o" </dev/null 2> "$OUT/$row.$mode.err" >/dev/null); rc=$?
    echo "$row $mode rc=$rc $(grep -E '^(QSELFIRE117|BITS117)' "$OUT/$row.$mode.err" | sort | uniq -c | tr -s ' ' | tr '\n' ';')"
    rm -f "$o"
  done
done
