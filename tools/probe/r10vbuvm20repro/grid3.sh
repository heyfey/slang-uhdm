set -u
ARM=$1; W=$2
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/vbuvm20_cen
rm -rf "$W"; mkdir -p "$W"
for v in d e; do
  if [ $v = d ]; then SLF=""; OF=""; else SLF="-elabuhdm"; OF="--elabuhdm"; fi
  mkdir -p "$W/$v/g"; cp "$ARM" "$W/$v/g/a.sv"
  ( cd "$W/$v/g" && $SURELOG a.sv -parse $SLF -d coveruhdm -nocache -createcache -noprecompiledcache -nowritecache -mt 0 -mp 0 -o s >sl.log 2>&1 ) </dev/null
  sfx=$([ $v = d ] && echo "" || echo "e")
  $CEN "$W/$v/g/s/slpp_all/surelog.uhdm" G > "$W/g$sfx.txt" 2>&1
  for n in pris pat fix; do
    mkdir -p "$W/$v/$n"; cp "$ARM" "$W/$v/$n/a.sv"
    ( cd "$W/$v/$n" && /tmp/vbuvm20_bin/$n.bin a.sv $OF -o o.uhdm >o.log 2>&1 ) </dev/null
  done
  $CEN "$W/$v/pris/o.uhdm" O > "$W/o$sfx.txt" 2>&1
  $CEN "$W/$v/pat/o.uhdm"  P > "$W/p$sfx.txt" 2>&1
  $CEN "$W/$v/fix/o.uhdm"  P > "$W/f$sfx.txt" 2>&1
done
