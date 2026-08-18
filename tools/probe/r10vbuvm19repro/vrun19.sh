#!/usr/bin/env bash
# usage: run19.sh <file.sv> <tag> [extra-slang-args...]
set -u
D=${W:-/tmp/vbuvm19_grid}; F=$1; T=$2; shift 2
cd "$D"
rm -rf "sl_$T"; mkdir -p "sl_$T"
~/git-repos/Surelog/build/bin/surelog -parse -d coveruhdm -nocache -createcache -noprecompiledcache -nowritecache -mt 0 -mp 0 -o "sl_$T" "$@" "$F" > "sg_$T.log" 2>&1
G=$(ls "sl_$T"/slpp_all/*.uhdm 2>/dev/null | head -1)
SA=""; for a in "$@"; do [ "$a" = "-elabuhdm" ] && SA="--elabuhdm"; done
${PRISTINE:?} $SA "$F" -o "p_$T.uhdm" > "p_$T.log" 2>&1
${PATCHED:?}  $SA "$F" -o "q_$T.uhdm" > "q_$T.log" 2>&1
for x in "$G:g" "p_$T.uhdm:p" "q_$T.uhdm:q"; do
  f=${x%:*}; n=${x#*:}
  uhdm-dump "$f" > "d_${T}_$n.txt" 2>/dev/null
  python3 ${FECEN:?} "d_${T}_$n.txt" "j_${T}_$n.json" > /dev/null
done
echo "== $T"
python3 "$D/vcmp19.py" "j_${T}_g.json" "j_${T}_p.json" "j_${T}_q.json"
