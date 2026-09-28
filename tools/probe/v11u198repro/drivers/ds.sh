#!/bin/bash
# v11u198: the downstream verdict (scripts/downstream_uhdm2rtlil.py's one()) of case dirs on both frozen binaries,
# plus whether the slang lane's <case>_nohier.il moved between the binaries.  Run from anywhere; fence fail-closed.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
REPO=$(cd "$HERE/../../../.." && pwd); export GOLDEN_CACHE=/tmp/v11u198_gcache
for c in "$@"; do D=$(cd $c && pwd); for f in $FENCED; do grep -qw "$f" <<< "$D" && { echo "fenced refused" >&2; exit 3; }; done
  n=$(echo $D | sed 's#.*/cases/##; s#/#_#g'); line="$n"
  for b in pris ${LB:-law}; do W=/tmp/v11u198_ds/$b; mkdir -p $W; rm -rf $W/$n
    v=$(cd $REPO && SLANG_UHDM=$VB/$b.bin python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$D', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print(r['verdict']+':'+r['differs'])" 2>/dev/null)
    line="$line	$b=$v"; done
  a=$(find /tmp/v11u198_ds/pris/$n -path '*slang*' -name '*_nohier.il' | head -1); bb=$(find /tmp/v11u198_ds/${LB:-law}/$n -path '*slang*' -name '*_nohier.il' | head -1)
  if [ -n "$a" ] && [ -n "$bb" ]; then cmp -s "$a" "$bb" && line="$line	il=SAME" || line="$line	il=MOVED"; else line="$line	il=?"; fi
  echo "$line"; done
