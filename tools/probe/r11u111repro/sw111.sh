#!/bin/bash
# sw111.sh <out> <root>...: the SWITCH check.  Every dut.sv under each root is compiled by pristine,
# the law binary, and the law binary under each kill switch (wrappers /tmp/r11u111_sw_<tag>.sh).
# Prints per arm the set of tags whose bytes equal pristine, and a summary: R11U111_OFF must equal
# pristine everywhere; each single switch must equal pristine exactly on the arms its law alone moves.
OUT=${1:?}; shift; PRIS=${PRIS:-/tmp/r11u111_pris.bin}; LAW=${LAW:-/tmp/r11u111_lawx.bin}
TAGS="off f1off f1doff f1boff f2off f3off f5off f6off"
mkdir -p "$OUT"; : > "$OUT/result.txt"
for root in "$@"; do
  while read -r rel <&3; do
    d=$(dirname "$rel"); key=$(echo "$root/$d" | tr / _); w="$OUT/$key"; mkdir -p "$w"
    run() { (cd "$root/$d" && timeout 120 "$2" dut.sv --single-unit --nobuiltin -o "$w/$1.uhdm" </dev/null >/dev/null 2>&1); md5sum < "$w/$1.uhdm" 2>/dev/null | cut -c1-12; }
    p=$(run pris "$PRIS"); l=$(run law "$LAW"); line="$root/$d law=$([ "$p" = "$l" ] && echo SAME || echo MOVED)"
    for t in $TAGS; do s=$(run $t /tmp/r11u111_sw_$t.sh); if [ "$s" = "$p" ]; then line="$line $t=P"; elif [ "$s" = "$l" ]; then line="$line $t=L"; else line="$line $t=X"; fi; done
    echo "$line" >> "$OUT/result.txt"; rm -f "$w"/*.uhdm
  done 3< <(cd "$root" && find . -name dut.sv | sort)
done
echo "ARMS=$(wc -l < "$OUT/result.txt")"
echo "OFF!=pristine: $(grep -c 'off=[LX]' "$OUT/result.txt"; true)"
grep 'law=MOVED' "$OUT/result.txt" | sed 's/ law=MOVED//' | awk '{s=""; for(i=2;i<=NF;i++) if ($i ~ /=P$/) s=s" "$i; print $1, "restored-by:" s}'
