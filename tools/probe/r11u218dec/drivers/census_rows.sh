#!/bin/bash
# r11u218dec: the firing census re-run on the rows a previous census PREDICTED (a refinement that only narrows a
# law's gate can only drop firings, so the new prediction is the census of those rows). usage:
# census_rows.sh <prediction file> <workdir> <trace dir> <out prefix>. $SLANG_UHDM = the law binary. Fenced names are
# refused (fail closed on the FENCED= line of tools/probe/r11u107repro/canaudit.sh).
set -eu; P=$1; W=$2; TR=$3; O=$4; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census_rows: fence unreadable" >&2; exit 3; }
[ -n "${SLANG_UHDM:-}" ] || { echo "census_rows: export SLANG_UHDM" >&2; exit 3; }
for n in $FENCED; do grep -qw "$n" "$P" && { echo "census_rows: fenced row in the prediction" >&2; exit 3; }; done
SL=$(awk '{print $1}' $P | grep '^surelog/' | cut -d/ -f3 | sort -u | paste -sd'|')
UR=$(awk '{print $1}' $P | grep '^uhdm2rtlil/' | cut -d/ -f3 | sort -u | paste -sd'|')
PR=$(awk '{print $1}' $P | grep '^probe/' | cut -d/ -f2- | sort -u | sed 's/[.]/\\./g' | paste -sd'|')
rm -rf "$TR" "$W"; mkdir -p "$TR" "$W"; export R11U218_TRACE="$TR"; cd "$REPO"
[ -n "$SL" ] && python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "^($SL)$" --out $O.sl.csv --workdir $W/surelog > $O.sl.log 2>&1 || true
[ -n "$UR" ] && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "^($UR)$" --out $O.u2r.csv --workdir $W/uhdm2rtlil > $O.u2r.log 2>&1 || true
[ -n "$PR" ] && python3 scripts/check_probe.py --jobs 3 --filter "^($PR)$" --out $O.probe.csv --workdir $W/probe > $O.probe.log 2>&1 || true
echo CENSUS_DONE
