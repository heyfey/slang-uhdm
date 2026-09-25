# dumpd.sh <griddir>: uhdm-dump of golden, pris, law; diff line counts golden-vs-each (sorted and unsorted)
source /tmp/v11u163_env.sh
d=$1
for t in golden pris ver1; do $UHDM_DUMP $d/$t.uhdm 2>/dev/null | sed -E 's#/[^ ]*/##g; s/[0-9a-f]{6,}//g' > $d/$t.dump; done
p=$(diff $d/golden.dump $d/pris.dump | grep -c '^[<>]'); l=$(diff $d/golden.dump $d/ver1.dump | grep -c '^[<>]')
ps=$(diff <(sort $d/golden.dump) <(sort $d/pris.dump) | grep -c '^[<>]'); ls=$(diff <(sort $d/golden.dump) <(sort $d/ver1.dump) | grep -c '^[<>]')
echo "$(basename $d) dumpdiff pris=$p law=$l sorted pris=$ps law=$ls"
