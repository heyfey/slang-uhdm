#!/bin/bash
# r10uvm46 — run the interface_inst OBJECT+POSITION census on an ARM's golden and
# on ours, side by side.  Refuses to print anything it cannot substantiate: the
# probe itself exits non-zero when a file holds ZERO interface_inst objects.
#   usage: armif.sh <arm-outdir>          e.g. armif.sh /tmp/r10uvm46_t63a
set -u
OUT=${1:?}
V=/tmp/r10uvm46_r10uvm46if
[ -x "$V" ] || { echo "FATAL: probe $V missing"; exit 3; }
G=$OUT/slpp_all/surelog.uhdm
O=$OUT/ours.uhdm
for f in "$G" "$O"; do [ -f "$f" ] || { echo "FATAL: $f missing"; exit 3; }; done
"$V" "$G" > "$OUT/if_g.txt" || { echo "FATAL: probe failed on golden"; exit 3; }
"$V" "$O" > "$OUT/if_o.txt" || { echo "FATAL: probe failed on ours"; exit 3; }
echo "=== $(basename "$OUT")  golden OBJ=$(grep -c '^OBJ' "$OUT/if_g.txt") ours OBJ=$(grep -c '^OBJ' "$OUT/if_o.txt")"
echo "--- GOLDEN"; cat "$OUT/if_g.txt"
echo "--- OURS";   cat "$OUT/if_o.txt"
