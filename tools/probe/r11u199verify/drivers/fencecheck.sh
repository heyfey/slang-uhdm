#!/bin/bash
# fencecheck.sh: runtime check of the four evidence directories' env.sh (r11u192repro, v11u192repro, r11u193repro,
# v11u193repro) and of this directory's env.sh: sourced from the checkout (rc, number of names) and, as the NEGATIVE
# control, sourced from a scratch copy of the driver dir beside a canaudit.sh whose FENCED= line holds two dummy names
# (must refuse).  Also a word scan of the five directories for the fenced names (the POSITIVE control plants one name
# in a scratch file).  Prints no fenced name.
source "$(dirname "$0")/env.sh" || exit 2
T=/tmp/r11u199_fence; rm -rf $T; mkdir -p $T/tools/probe/r11u107repro
echo 'FENCED="dummyA dummyB"' > $T/tools/probe/r11u107repro/canaudit.sh
for d in r11u192repro v11u192repro r11u193repro v11u193repro r11u199verify; do
  real=$(env -i HOME="$HOME" PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true R193_BIN=/tmp V193_BIN=/tmp bash -c "source $R199_ROOT/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
  mkdir -p $T/tools/probe/$d; cp -r $R199_ROOT/tools/probe/$d/drivers $T/tools/probe/$d/
  neg=$(env -i HOME="$HOME" PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true R193_BIN=/tmp V193_BIN=/tmp bash -c "source $T/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
  hits=$(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $R199_ROOT/tools/probe/$d 2>/dev/null | wc -l)
  echo "$d env.sh checkout: $real | two-name canaudit: $neg | files naming a fenced test: $hits"
done
f1=$(echo $FENCED | cut -d' ' -f1); mkdir -p $T/pos; echo "x $f1 y" > $T/pos/planted.txt
echo "positive control: planted files found $(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $T/pos | wc -l) (expect 1)"
rm -rf $T
