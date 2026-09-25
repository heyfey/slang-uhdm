#!/bin/bash
# moverfacets.sh <pristine sweep> <law sweep> <out dir> corpus/mode/test ... : record-level facet census (map 8's
# analyzer, drivers/analyze.py of r11u165map with strictcmp_x dumps) of each mover in both sweeps; prints every cluster
# whose object count changed.  Refuses fenced names.
P=$1 L=$2 U=$3; shift 3
: "${FENCED:?}"; fre=$(echo $FENCED | sed 's/ /|/g')
A=/tmp/wt_r11u172/tools/probe/r11u165map/drivers; export SCMP=/tmp/r11u172_bin/strictcmp_x
for row in "$@"; do
  echo "$row" | grep -Eqw "$fre" && { echo "FENCED $row refused"; continue; }
  c=${row%%/*}; r=${row#*/}; m=${r%%/*}; t=${r#*/}
  for v in P L; do W=$P; [ $v = L ] && W=$L
    d=$(ls -d $W/$c/$m/$t-*); g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $d/cmds.txt)/golden.uhdm
    DUMPS=$U/d$v bash $A/run1.sh $c $m $t $g $d/slang.uhdm
    printf '%s\t%s\t%s\t-\t-\t-\n' $c $m $t > $U/j_$c_$m_$t.txt
    (cd $A && R11U138_TMP=$U/tmp python3 analyze.py $U/j_$c_$m_$t.txt $U/a$v.$c.$m.$t.jsonl $U/d$v 1)
  done
  python3 - "$U" "$c" "$m" "$t" <<'PY'
import json, collections, sys
U, c, m, t = sys.argv[1:5]; C = {}
for v in 'PL':
    r = json.loads(open(f'{U}/a{v}.{c}.{m}.{t}.jsonl').readline())
    C[v] = collections.Counter(f['cluster'] for f in r['rows']); C[v + 'n'] = len(r['rows'])
up = [k for k in set(C['P']) | set(C['L']) if C['L'][k] > C['P'][k]]
print(f"{c}/{m}/{t}: facet rows {C['Pn']} -> {C['Ln']}; clusters down {sum(1 for k in C['P'] if C['L'][k] < C['P'][k])}, up {len(up)}")
for k in sorted(set(C['P']) | set(C['L'])):
    if C['P'][k] != C['L'][k]: print(f"   {C['P'][k]:6d} -> {C['L'][k]:6d}  {k}")
PY
done
