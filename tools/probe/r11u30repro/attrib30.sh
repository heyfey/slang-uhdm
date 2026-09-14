#!/usr/bin/env bash
# r11u30 — MEASUREMENT ONLY.  ATTRIBUTE one mover's bytes, ORDER-BLIND.
# Four of the five target tests are the proven UVM COIN family (pristine-
# nondeterministic: a vpiTaskFunc list ORDER flip under slang's parallel parse),
# so a mover there is attributed by a SORTED, workdir-normalised dump diff --
# never by a line count, never by a raw diff.
#   usage: attrib30.sh <cendir>            (a cen30.sh output dir with pris/pat dumps)
set -u
D=${1:?cen dir}
cd "$D" || exit 9
for t in pris pat; do
  sed -E 's#/tmp/[^ ,:]*##g' $t.dump | sort > $t.norm
done
n=$(diff pris.norm pat.norm | grep -c '^[<>]'; true)
echo "$(basename "$D"): ORDER-BLIND diff lines = $n"
diff pris.norm pat.norm | grep '^[<>]' | sed 's/^/   /'
