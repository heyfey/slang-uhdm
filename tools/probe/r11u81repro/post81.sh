#!/bin/bash
# r11u81 POST-SWEEP GATES — row joins, byteverify (with its selfcheck), the
# canary battery and the conversion rows.  Run after gates81.sh for BOTH tags.
set -u
R=${R:-/tmp/r11u81_gates}
S=${S:-/home/heyfey/git-repos/slang-uhdm}
P=${P:-/tmp/r11u81_g}
echo "########## ROW JOINS"
echo "--- u2r law vs COMMITTED results/golden_uhdm2rtlil.csv"
bash "$P/rowjoin81.sh" "$R/u2r.lawx.csv" "$S/results/golden_uhdm2rtlil.csv" u2r-committed
echo "--- u2r law vs THIS PASS'S OWN pristine sweep"
bash "$P/rowjoin81.sh" "$R/u2r.lawx.csv" "$R/u2r.pris.csv" u2r-ownpris
echo "--- u2r law (testflags rows only) vs COMMITTED results/gate_uhdm2rtlil.csv"
python3 - "$R/u2r.lawx.csv" > "$R/u2r.lawx.tf.csv" <<'PY'
import csv, sys
w = csv.writer(sys.stdout)
with open(sys.argv[1]) as f:
    r = csv.reader(f); hdr = next(r); w.writerow(hdr)
    for row in r:
        if row[1] == 'testflags': w.writerow(row)
PY
bash "$P/rowjoin81.sh" "$R/u2r.lawx.tf.csv" "$S/results/gate_uhdm2rtlil.csv" u2r-tfgate
echo "--- surelog law vs COMMITTED results/golden_surelog.csv"
bash "$P/rowjoin81.sh" "$R/sl.lawx.csv" "$S/results/golden_surelog.csv" sl-committed
echo "--- surelog law vs THIS PASS'S OWN pristine sweep"
bash "$P/rowjoin81.sh" "$R/sl.lawx.csv" "$R/sl.pris.csv" sl-ownpris

echo "########## BYTEVERIFY (workdir names are the SAME LENGTH: _pris / _lawx)"
echo "--- uhdm2rtlil"
SELFCHECK=1 bash "$P/byteverify.sh" "$R/wd_u2r_lawx" "$R/wd_u2r_pris" | tail -40
echo "--- surelog"
SELFCHECK=1 bash "$P/byteverify.sh" "$R/wd_sl_lawx" "$R/wd_sl_pris" | tail -40

echo "########## CANARIES"
echo "--- canaries.sh surelog (law vs committed)"
bash "$P/canaries.sh" "$R/sl.lawx.csv" "$S/results/golden_surelog.csv" | tail -6
echo "--- canaries.sh u2r (law vs committed)"
bash "$P/canaries.sh" "$R/u2r.lawx.csv" "$S/results/golden_uhdm2rtlil.csv" | tail -6
echo "--- ctcan2.sh surelog"
EXPECT_UNKNOWN=1 bash "$P/ctcan2.sh" "$S/results/golden_surelog.csv" "$R/sl.lawx.csv" | tail -6
echo "--- ctcan2.sh u2r"
EXPECT_UNKNOWN=6 bash "$P/ctcan2.sh" "$S/results/golden_uhdm2rtlil.csv" "$R/u2r.lawx.csv" | tail -6
echo "--- canaudit.sh"
bash "$P/canaudit.sh" "$P/canaries.sh" "$P/ctcan2.sh" | tail -6

echo "########## FENCE CHECK (the four slang-fenced names must appear in NO driver)"
grep -rl -f /dev/null "$P" 2>/dev/null | head -0
echo "########## CSV UNTOUCHED"
(cd "$S" && git status --porcelain results/ | sed 's/^/  /'; echo "  (blank above = untouched)")
