#!/bin/bash
# (r11u226: copied from r11u221verify/drivers/fencecheck.sh; the six directories of passes 219, 220, 223 and their verifiers.)
# v11u207repro) and of this directory's env.sh: sourced from the checkout (rc, number of names) and, as the NEGATIVE
# control, sourced from a scratch copy of the driver dir beside a canaudit.sh whose FENCED= line holds two dummy names
# (must refuse).  Also a word scan of the five directories for the fenced names (the POSITIVE control plants one name
# in a scratch file).  Prints no fenced name.
source "$(dirname "$0")/env.sh" || exit 2
T=/tmp/r11u226_fence; rm -rf $T; mkdir -p $T/tools/probe/r11u107repro
echo 'FENCED="dummyA dummyB"' > $T/tools/probe/r11u107repro/canaudit.sh
for d in r11u219repro v11u219repro r11u220repro v11u220repro r11u223repro v11u223repro r11u226verify; do
  real=$(env -i HOME="$HOME" PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true B=/tmp S=/tmp/r11u226_fence_s bash -c "source $R226_ROOT/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
  mkdir -p $T/tools/probe/$d; cp -r $R226_ROOT/tools/probe/$d/drivers $T/tools/probe/$d/
  neg=$(env -i HOME="$HOME" PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true B=/tmp S=/tmp/r11u226_fence_s bash -c "source $T/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
  hits=$(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $R226_ROOT/tools/probe/$d 2>/dev/null | wc -l)
  echo "$d env.sh checkout: $real | two-name canaudit: $neg | files naming a fenced test: $hits"
done
f1=$(echo $FENCED | cut -d' ' -f1); mkdir -p $T/pos; echo "x $f1 y" > $T/pos/planted.txt
echo "positive control: planted files found $(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $T/pos | wc -l) (expect 1)"
rm -rf $T
