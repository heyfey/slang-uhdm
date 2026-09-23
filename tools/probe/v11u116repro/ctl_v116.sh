#!/bin/bash
# v11u116_ctl.sh <root> <out> : every dut.sv under root (any depth); pris vs law bytes; golden+cmp only for movers
ROOT=$(realpath "${1:?root}"); OUT=${2:?out}; mkdir -p "$OUT"; OUT=$(realpath "$OUT")
export ROOT OUT SL=/home/heyfey/git-repos/Surelog/build/bin/surelog CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
export PRIS=${PRIS:?pristine binary} LAW=${LAW:?law binary} LAWENV=${LAWENV:-}
one() {
  arm=$1; src="$ROOT/$arm"; w="$OUT/$arm"; mkdir -p "$w"; res="$arm"
  for tag in pris law; do
    bin=$PRIS; env=""; [ $tag = law ] && { bin=$LAW; env="$LAWENV"; }
    rm -f "$w/$tag.uhdm"
    (cd "$src" && env $env timeout 300 "$bin" dut.sv --single-unit --nobuiltin -o "$w/$tag.uhdm" </dev/null > "$w/$tag.log" 2>&1); res="$res $tag:rc=$?"
  done
  if cmp -s "$w/pris.uhdm" "$w/law.uhdm"; then echo "$res SAME"; return; fi
  if [ ! -f "$w/gold.uhdm" ]; then
    rm -rf "$w/gold"; mkdir -p "$w/gold"
    (cd "$src" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/gold" </dev/null > "$w/gold/log" 2>&1); echo $? > "$w/gold/rc"
    g=$(ls "$w"/gold/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm"
  fi
  for tag in pris law; do
    [ -f "$w/gold.uhdm" ] && [ -f "$w/$tag.uhdm" ] && { "$CMP" "$w/gold.uhdm" "$w/$tag.uhdm" > "$w/$tag.cmp" 2>&1; res="$res $tag=$(wc -l < "$w/$tag.cmp")/$(grep -c '^LHS:' "$w/$tag.cmp"; true)"; }
  done
  echo "$res MOVED"
}
export -f one
LIST=$(mktemp /tmp/v11u116_clist.XXXX); (cd "$ROOT" && find . -name dut.sv | sed 's#^\./##; s#/dut.sv$##' | sort) > "$LIST"
xargs -P 3 -I{} bash -c 'one "$@"' _ {} < "$LIST" | sort
echo "LISTED=$(wc -l < "$LIST")"; rm -f "$LIST"
