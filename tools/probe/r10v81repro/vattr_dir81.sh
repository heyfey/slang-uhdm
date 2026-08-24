#!/usr/bin/env bash
# r10v81 — attribute ONE differing per-directory boundary cell with TWO
# controls: the SAME binary run twice, and the patched binary with the law
# DISABLED (R10E81_OFF=1) against pristine.  MEASUREMENT ONLY.
set -u
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
dir=$1; view=$2; STG=/tmp/v81_bnd/attrdir; mkdir -p $STG
FL=""; [ "$view" = elab ] && FL="--elabuhdm"
key=$(basename "$dir")_$view
run() { # tag bin env
  local tag=$1 bin=$2 ev=$3
  local d="$STG/${key}_$tag"
  rm -rf "$d"; mkdir -p "$d"; cp "$dir"/*.sv "$d/" 2>/dev/null; cp "$dir"/*.v "$d/" 2>/dev/null
  local srcs; srcs=$(cd "$d" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
  ( cd "$d" && env $ev "$bin" $FL $srcs -o slang.uhdm >slang.log 2>&1 </dev/null ); local rc=$?
  "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}_$tag#WD#g; s#$STG#STG#g" > "$d/o.norm"
  echo "  rc=$rc $tag lines=$(wc -l < "$d/o.norm")"
}
run A1 /tmp/v81_bin/patched X=1
run A2 /tmp/v81_bin/patched X=1
run B1 /tmp/v81_bin/pris    X=1
run B2 /tmp/v81_bin/pris    X=1
run N1 /tmp/v81_bin/patched R10E81_OFF=1
c() { cmp -s "$STG/${key}_$1/o.norm" "$STG/${key}_$2/o.norm" && echo "SAME" || echo "DIFF($(diff "$STG/${key}_$1/o.norm" "$STG/${key}_$2/o.norm" | grep -c '^[<>]'))"; }
echo "$dir [$view]  A1vsA2(patched self)=$(c A1 A2)  B1vsB2(pristine self)=$(c B1 B2)  A1vsB1(cross)=$(c A1 B1)  N1vsB1(law-off vs pristine)=$(c N1 B1)"
