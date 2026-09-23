#!/bin/bash
# v11u116_grid.sh <arms-dir> <out-root> [ENV for law run via LAWENV]
ARMS=$(realpath "${1:?arms}"); OUT=${2:?out}
mkdir -p "$OUT"; OUT=$(realpath "$OUT")
export ARMS OUT SL=/home/heyfey/git-repos/Surelog/build/bin/surelog CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
export PRIS=${PRIS:?pristine binary} LAW=${LAW:?law binary} LAWENV=${LAWENV:-}
one() {
  arm=$1; src="$ARMS/$arm"; w="$OUT/$arm"; mkdir -p "$w"
  if [ ! -f "$w/gold.uhdm" ]; then
    rm -rf "$w/gold"; mkdir -p "$w/gold"
    (cd "$src" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/gold" </dev/null > "$w/gold/log" 2>&1); echo "$?" > "$w/gold/rc"
    g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm"
  fi
  res="$arm grc=$(cat $w/gold/rc)"
  for tag in pris law; do
    bin=$PRIS; env=""; [ $tag = law ] && { bin=$LAW; env="$LAWENV"; }
    rm -f "$w/$tag.uhdm" "$w/$tag.cmp"
    (cd "$src" && env $env timeout 300 "$bin" dut.sv --single-unit --nobuiltin -o "$w/$tag.uhdm" </dev/null > "$w/$tag.log" 2>&1); rc=$?
    if [ -f "$w/gold.uhdm" ] && [ -f "$w/$tag.uhdm" ]; then
      "$CMP" "$w/gold.uhdm" "$w/$tag.uhdm" > "$w/$tag.cmp" 2>&1
      res="$res $tag:rc=$rc,$(wc -l < "$w/$tag.cmp")/$(grep -c '^LHS:' "$w/$tag.cmp"; true)"
    else
      res="$res $tag:rc=$rc,NA"
    fi
  done
  if cmp -s "$w/pris.uhdm" "$w/law.uhdm"; then res="$res SAME"; else res="$res MOVED"; fi
  echo "$res"
}
export -f one
N=0
exec 3< <(cd "$ARMS" && find . -mindepth 2 -maxdepth 2 -name dut.sv | sed 's#^\./##; s#/dut.sv$##' | sort)
LIST=$(mktemp /tmp/v11u116_list.XXXX); cat <&3 > "$LIST"
xargs -P 3 -I{} bash -c 'one "$@"' _ {} < "$LIST" | sort
echo "LISTED=$(wc -l < "$LIST")"
rm -f "$LIST"
