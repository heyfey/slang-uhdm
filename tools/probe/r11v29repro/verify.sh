#!/bin/bash
# r11v29repro/verify.sh — the adversarial verification of r11u29, re-runnable.
#
# WHAT IT DOES, in the order the README's numbers were made:
#   1. builds the tree FROM SOURCE at the base commit and asserts the md5 is the
#      pin (r11u29 copied the main-tree binary; this is the build it skipped);
#   2. freezes that binary and sweeps both corpora, both modes, into its OWN
#      workdirs, then asserts row-for-row agreement with the READ-ONLY baselines;
#   3. re-extracts the head of EVERY not-equal row through the committed
#      rowheads.sh (ONE head per run) plus two known-EQUAL positive controls;
#   4. runs r11u29's OWN facediff.py over those heads and diffs the result
#      against r11u29's committed faces — the claim is byte identity, so any
#      non-zero diff is a finding;
#   5. re-runs the K2 census UNFILTERED (r11u29's evidence file shows only the
#      rows that matched its thesis), calibrating golden-vs-golden first;
#   6. re-checks the fence exclusion by EXACT name match, and counts (never
#      prints) fenced-name hits in the patch and the probe tree.
#
# NOTHING HERE IS A GATE.  The judge is uhdm-cmp; this only reads it.
#
#   usage: verify.sh <worktree-at-base> <scratch> <workdir>
set -u
WT=${1:?worktree at the base commit}
SC=${2:?scratch dir (pass-prefixed, yours)}
WD=${3:?sweep workdir (yours)}
PIN=62547ac98ebcfdeb522171dc946d50ad
SL_BASE=$WT/results/golden_surelog.csv
U2R_BASE=$WT/results/golden_uhdm2rtlil.csv
mkdir -p "$SC" "$WD/sl" "$WD/u2r"

# --- 1. build from source, assert the pin -----------------------------------
cmake -S "$WT" -B "$WT/build" -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
      -Dslang_DIR="$HOME/.local/lib64/cmake/slang" \
      -DUHDM_DIR="$HOME/.local/lib64/cmake/UHDM" > "$SC/cfg.log" 2>&1 || exit 3
cmake --build "$WT/build" -j 2 > "$SC/build.log" 2>&1 || exit 3
GOT=$(md5sum "$WT/build/slang-uhdm" | cut -d' ' -f1)
echo "built md5 $GOT  pin $PIN  $([ "$GOT" = "$PIN" ] && echo MATCH || echo MISMATCH)"
[ "$GOT" = "$PIN" ] || exit 3
cp "$WT/build/slang-uhdm" "$SC/pris.bin"; chmod 555 "$SC/pris.bin"
export SLANG_UHDM=$SC/pris.bin

# --- 2. own sweeps, assert the baseline -------------------------------------
( cd "$WT" && python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
    --jobs 2 --out "$WD/u2r_tf.csv" --workdir "$WD/u2r" > "$WD/u2r_tf.log" 2>&1
  python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default \
    --jobs 2 --out "$WD/u2r_def.csv" --workdir "$WD/u2r" > "$WD/u2r_def.log" 2>&1
  python3 scripts/verify_golden.py --corpus surelog --mode both \
    --jobs 2 --out "$WD/sl.csv" --workdir "$WD/sl" > "$WD/sl.log" 2>&1 )
# the harness silently defaults SLANG_UHDM to the MAIN-TREE binary: audit by PATH
echo "cmds.txt NOT naming the frozen binary: $(find "$WD/u2r" -name cmds.txt -exec grep -L "$SC/pris.bin" {} \; | wc -l)"
python3 - "$U2R_BASE" "$WD/u2r_tf.csv" "$WD/u2r_def.csv" "$SL_BASE" "$WD/sl.csv" <<'EOF'
import csv,sys
def load(ps):
    d={}
    for p in ps:
        for r in csv.DictReader(open(p)): d[(r['name'],r['mode'])]=r['status']
    return d
u2rb,u2rm=load([sys.argv[1]]),load(sys.argv[2:4])
slb,slm=load([sys.argv[4]]),load([sys.argv[5]])
for lab,B,M in (('uhdm2rtlil',u2rb,u2rm),('surelog',slb,slm)):
    d=[k for k in set(B)|set(M) if B.get(k)!=M.get(k)]
    nb=sorted(k for k,v in B.items() if v=='CMP_NOTEQUAL')
    nm=sorted(k for k,v in M.items() if v=='CMP_NOTEQUAL')
    print('%-11s differing-status rows %d  NOTEQUAL set identical %s (%d rows)'%(lab,len(d),nb==nm,len(nm)))
EOF

# --- 3. fence list, built from a COMMITTED driver's own FENCED= line ---------
sed -n '37p' "$WT/tools/probe/r10sd4repro/canaudit.sh" | sed 's/FENCED=//; s/"//g' \
  | tr ' ' '\n' | grep . > "$SC/fenced.txt"
awk -F, 'NR>1 && $3=="CMP_NOTEQUAL"{print $1}' "$SL_BASE" | sort -u > "$SC/sl_all.txt"
grep -vxFf "$SC/fenced.txt" "$SC/sl_all.txt" > "$SC/sl_names.txt"   # -x = EXACT line match
awk -F, 'NR>1 && $3=="CMP_NOTEQUAL"{print $1}' "$U2R_BASE" | sort -u > "$SC/u2r_names.txt"
echo "surelog not-equal tests $(wc -l < "$SC/sl_all.txt") -> unfenced $(wc -l < "$SC/sl_names.txt"); u2r tests $(wc -l < "$SC/u2r_names.txt")"
comm -23 "$SC/sl_all.txt" "$SC/sl_names.txt" > "$SC/excluded.txt"
python3 -c "
f=set(open('$SC/fenced.txt').read().split()); ex=[l.strip() for l in open('$SC/excluded.txt') if l.strip()]
print('excluded %d, all EXACT fence members: %s'%(len(ex), all(e in f for e in ex)))"

# --- 4. heads + positive control + faces ------------------------------------
RH=$WT/tools/probe/r10uvm67repro/rowheads.sh
FD=$WT/tools/probe/r11u29repro/facediff.py
for c in u2r sl; do
  case $c in u2r) W=$WD/u2r; N=$(cat "$SC/u2r_names.txt"); B=$U2R_BASE;;
                sl) W=$WD/sl;  N=$(cat "$SC/sl_names.txt");  B=$SL_BASE;; esac
  CTL=$(awk -F, 'NR>1 && $3=="CMP_EQUAL"{print $1}' "$B" | sort -u | head -2)
  mkdir -p "$SC/$c/cmp"
  bash "$RH" "$W" "$SC/$c/cmp" $N $CTL > "$SC/$c/rowheads.txt" 2>&1
  echo "== $c: $(tail -1 "$SC/$c/rowheads.txt")"
  echo "   POSITIVE CONTROL (must read 0 cmp lines / 0 heads):"
  for x in $CTL; do grep "^$x " "$SC/$c/rowheads.txt" | sed 's/^/     /'; done
  python3 "$FD" --key "$SC/$c/cmp"/*.cmp > "$SC/$c/faces.key.txt"
  python3 "$FD"       "$SC/$c/cmp"/*.cmp > "$SC/$c/faces.full.txt"
  E=$WT/tools/probe/r11u29repro/evidence/$([ $c = sl ] && echo surelog || echo u2r)
  echo "   vs r11u29: faces.key diff $(diff "$SC/$c/faces.key.txt" "$E/faces.key.txt" | wc -l) lines," \
       "faces.full diff $(diff "$SC/$c/faces.full.txt" "$E/faces.full.txt" | wc -l) lines," \
       "rowheads diff $(diff "$SC/$c/rowheads.txt" "$E/rowheads.txt" | wc -l) lines"
  # mode identity, id-blind
  sp=0; for f in "$SC/$c/cmp"/*.default.cmp; do n=${f%.default.cmp}; t=$n.testflags.cmp
    [ -f "$t" ] || continue
    diff -q <(sed -E 's/id:[0-9]+/id:#/g' "$f") <(sed -E 's/id:[0-9]+/id:#/g' "$t") >/dev/null || sp=$((sp+1)); done
  echo "   MODE-SPLIT rows: $sp"
done

# --- 5. the K2 census, UNFILTERED, calibrated golden-vs-golden first ---------
CEN=$WT/tools/probe/r11u29repro/nettype_census.py
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$SC/census"
for n in gen_scope_numports packed_array_reset_loop param_name_collision_typeparam \
         latch_packed_enum_loop arb_idx_cast; do
  d=$(echo "$WD/u2r/default/$n"-*/); C=$d/cmds.txt
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)/golden.uhdm
  "$DUMP" "$G" > "$SC/census/$n.golden.txt" 2>/dev/null
  "$DUMP" "$d/slang.uhdm" > "$SC/census/$n.ours.txt" 2>/dev/null
  printf '%-32s calib %s\n' "$n" "$(python3 "$CEN" "$SC/census/$n.golden.txt" "$SC/census/$n.golden.txt" | tail -1)"
  printf '%-32s G-vs-O %s\n' '' "$(python3 "$CEN" "$SC/census/$n.golden.txt" "$SC/census/$n.ours.txt" | tail -1)"
  printf '%-32s of which the claimed vpiNetType face: %s\n' '' \
    "$(python3 "$CEN" "$SC/census/$n.golden.txt" "$SC/census/$n.ours.txt" | grep -c 'golden=False    ours=True' || true)"
  # the second half of the law: the ELAB-view object kind
  printf '%-32s golden packed_array_var rows %s / ours %s\n' '' \
    "$(grep -c 'packed_array_var: (work@' "$SC/census/$n.golden.txt" || true)" \
    "$(grep -c 'packed_array_var: (work@' "$SC/census/$n.ours.txt" || true)"
done

# --- 6. fence scan of the deliverables (counts only) ------------------------
i=0; while read -r fn; do i=$((i+1))
  printf 'fenced[%d] hits in the probe tree: %s\n' "$i" \
    "$(grep -rc "$fn" "$WT/tools/probe/r11u29repro" "$WT/tools/probe/r11v29repro" 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')"
done < "$SC/fenced.txt"
