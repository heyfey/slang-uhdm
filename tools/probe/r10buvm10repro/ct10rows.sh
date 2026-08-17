#!/usr/bin/env bash
# r10oth8 — THE ROW GATE: a WHOLE-ROW diff of a fresh CSV against the COMMITTED
# AUTHORITATIVE baseline, plus per-mode status and dump histograms.
#
#   usage: ct10rows.sh <baseline.csv> <fresh.csv>
#
# results/gate_uhdm2rtlil.csv and results/golden_surelog.csv are the committed
# authoritative baselines; this script only ever READS them.
#
# TRAPS ENCODED:
#   * `wc -l` COUNTS THE HEADER.  731 rows print as 732 lines and 1588 as 1589,
#     so the row count here is lines-minus-one and it says so out loud.
#   * THE WHOLE ROW IS COMPARED, dump column included: a dump-column-only
#     regression moves no status and is invisible to a status-only diff.
#   * A row present in one CSV and not the other is reported as ADDED/REMOVED,
#     never silently skipped.
set -u
B=${1:?baseline csv}
F=${2:?fresh csv}
[ -f "$B" ] || { echo "FATAL: missing baseline $B"; exit 9; }
[ -f "$F" ] || { echo "FATAL: missing fresh $F"; exit 9; }
bl=$(wc -l < "$B"); fl=$(wc -l < "$F")
echo "baseline: $bl lines = $((bl-1)) ROWS (the header is not a row)"
echo "fresh   : $fl lines = $((fl-1)) ROWS"
tb=$(mktemp); tf=$(mktemp)
tail -n +2 "$B" | LC_ALL=C sort > "$tb"
tail -n +2 "$F" | LC_ALL=C sort > "$tf"
# TWO NUMBERS, because they are not the same number and conflating them is how a
# "1 row moved" gets reported as "2 rows moved": `diff` prints a changed row
# TWICE (once as `<`, once as `>`), so the SIDES count is double the ROWS count
# for a pure change and single for an add/remove.  The authoritative figure is
# the number of distinct (name,mode) KEYS whose row text differs.
diffsides=$(diff "$tb" "$tf" | grep -cE '^[<>]' || true)
diffkeys=$(diff "$tb" "$tf" | grep -E '^[<>]' | sed -E 's/^[<>] //' |
           awk -F, '{print $1","$2}' | sort -u | wc -l)
echo "---- WHOLE-ROW diff (status AND dump column): $diffkeys differing ROWS" \
     "($diffsides diff row-sides)"
diff "$tb" "$tf" | grep -E '^[<>]' | head -40
echo "---- per-mode STATUS histogram (baseline -> fresh)"
for m in default testflags folded; do
  hb=$(awk -F, -v m="$m" '$2==m {print $3}' "$tb" | sort | uniq -c | tr '\n' ' ')
  hf=$(awk -F, -v m="$m" '$2==m {print $3}' "$tf" | sort | uniq -c | tr '\n' ' ')
  [ -z "$hb$hf" ] && continue
  echo "  $m  base: $hb"
  echo "  $m  fresh: $hf"
done
echo "---- per-mode DUMP-column histogram (baseline -> fresh)"
for m in default testflags folded; do
  hb=$(awk -F, -v m="$m" '$2==m {print $NF}' "$tb" | sort | uniq -c | tr '\n' ' ')
  hf=$(awk -F, -v m="$m" '$2==m {print $NF}' "$tf" | sort | uniq -c | tr '\n' ' ')
  [ -z "$hb$hf" ] && continue
  echo "  $m  base: $hb"
  echo "  $m  fresh: $hf"
done
rm -f "$tb" "$tf"
[ "$diffkeys" = 0 ] && echo "PASS: every row byte-identical to the committed baseline" \
                    || echo "ATTENTION: rows moved -- read them above, do not summarise them"
