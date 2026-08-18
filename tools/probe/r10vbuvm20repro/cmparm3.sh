set -u
ARM=$1; W=$2
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
rm -rf "$W"; mkdir -p "$W"
b=$(basename "$ARM" .sv)
for v in d e; do
  if [ $v = d ]; then SLF=""; OF=""; else SLF="-elabuhdm"; OF="--elabuhdm"; fi
  mkdir -p "$W/$v/g"; cp "$ARM" "$W/$v/g/a.sv"
  ( cd "$W/$v/g" && $SURELOG a.sv -parse $SLF -d coveruhdm -nocache -createcache -noprecompiledcache -nowritecache -mt 0 -mp 0 -o s >sl.log 2>&1 ) </dev/null
  G="$W/$v/g/s/slpp_all/surelog.uhdm"
  line=""
  for n in pris pat fix; do
    mkdir -p "$W/$v/$n"; cp "$ARM" "$W/$v/$n/a.sv"
    ( cd "$W/$v/$n" && /tmp/vbuvm20_bin/$n.bin a.sv $OF -o o.uhdm >o.log 2>&1; echo "rc=$?" >>o.log ) </dev/null
    ( $CMP "$G" "$W/$v/$n/o.uhdm" > "$W/$v.$n.cmp" 2>&1 ) </dev/null
    line="$line $n=$(grep -c '' "$W/$v.$n.cmp")/$(grep -c '^LHS:' "$W/$v.$n.cmp"; true)"
  done
  printf '%-16s view=%s lines/heads:%s\n' "$b" "$v" "$line"
done
