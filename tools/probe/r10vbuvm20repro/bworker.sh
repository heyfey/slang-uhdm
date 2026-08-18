#!/usr/bin/env bash
# one boundary cell: <relpath>.  Children get </dev/null.  rc recorded.
set -u
rel="$1"
key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.sv$##')
d="$OUT/w/$key"; mkdir -p "$d"; cp "$ROOT/$rel" "$d/a.sv" 2>/dev/null || { echo "COPYFAIL $rel" >> "$OUT/err.txt"; echo "PROCESSED $rel"; exit 0; }
for view in d e; do
  [ "$view" = d ] && FL="" || FL="--elabuhdm"
  for n in pris pat fix; do
    ( cd "$d" && /tmp/vbuvm20_bin/$n.bin a.sv $FL -o $n.$view.uhdm >$n.$view.log 2>&1; echo "rc=$?" >>$n.$view.log ) </dev/null
    r=$(sed -n 's/^rc=//p' "$d/$n.$view.log" | tail -1)
    db=0; [ -s "$d/$n.$view.uhdm" ] && db=1
    echo "$rel $view $n rc=$r db=$db" >> "$OUT/rc/$key.txt"
    if [ "$db" = 1 ]; then ( cd "$d" && uhdm-dump $n.$view.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > $n.$view.txt ) </dev/null; else : > "$d/$n.$view.txt"; fi
  done
  for n in pat fix; do
    dbp=0; [ -s "$d/pris.$view.uhdm" ] && dbp=1
    dbo=0; [ -s "$d/$n.$view.uhdm" ] && dbo=1
    [ "$dbp" != "$dbo" ] && echo "ASYM $rel $view pris=$dbp $n=$dbo" >> "$OUT/asym.txt"
    cmp -s "$d/pris.$view.txt" "$d/$n.$view.txt" || echo "$rel $view pris-vs-$n" >> "$OUT/differ.txt"
  done
done
if ! grep -q "^$rel " "$OUT/differ.txt" 2>/dev/null; then rm -rf "$d"; else rm -f "$d"/*.uhdm; fi
echo "PROCESSED $rel"
