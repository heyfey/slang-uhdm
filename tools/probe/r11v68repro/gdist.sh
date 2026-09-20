set -u
n=$1; d=$2
norm() { sed -E 's#/tmp/[a-zA-Z0-9_]+/#/WD/#g; s#_(pris|fix2|law|g)/#_X/#g; s#^\s+##' "$1" | grep -E '\|vpiSize:|\|vpiConstType:|\|(UINT|INT|DEC|BIN|HEX|OCT|STRING|SCAL):' | LC_ALL=C sort; }
norm $d/$n.g.dump > /tmp/gd_g.txt
for t in pris fix2; do norm $d/$n.$t.dump > /tmp/gd_$t.txt; done
p=$(diff /tmp/gd_g.txt /tmp/gd_pris.txt | grep -cE '^[<>]' || true)
l=$(diff /tmp/gd_g.txt /tmp/gd_fix2.txt | grep -cE '^[<>]' || true)
v=same; [ "$l" -lt "$p" ] && v=TOWARD; [ "$l" -gt "$p" ] && v='AWAY!!'
printf '%-18s pristine=%-5s fix2=%-5s %s\n' "$n" "$p" "$l" "$v"
