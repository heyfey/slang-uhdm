#!/bin/bash
# r11u4 — ORDER-BLIND attribution of one mover: sort both dumps after
# normalising the workdir path out, and print the delta.  0 lines => the two
# databases differ only in OBJECT ORDER (the coin); nonzero lines are content
# and must be attributed to the law by name.
set -u
A=${1:?pristine workdir}; B=${2:?patched workdir}; shift 2
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
T=$(mktemp -d)
for m in default testflags; do for t in "$@"; do
  da=$(ls -d "$A/$m/$t"-*/ 2>/dev/null|head -1); db=$(ls -d "$B/$m/$t"-*/ 2>/dev/null|head -1)
  [ -z "$da" ] || [ -z "$db" ] && continue
  [ -f "$da/slang.uhdm" ] && [ -f "$db/slang.uhdm" ] || continue
  $DUMP "$da/slang.uhdm" | tail -n +2 | sed "s#$A##g" | sort > "$T/a"
  $DUMP "$db/slang.uhdm" | tail -n +2 | sed "s#$B##g" | sort > "$T/b"
  n=$(diff "$T/a" "$T/b" | grep -c '^[<>]'; true)
  echo "== $t/$m  order-blind delta = $n lines  (sizes $(wc -l < "$T/a") / $(wc -l < "$T/b"))"
  diff "$T/a" "$T/b" | grep '^[<>]' | head -12 | sed 's/^/     /'
done; done
rm -rf "$T"
