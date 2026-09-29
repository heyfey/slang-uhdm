#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# fencecheck.sh: runtime check of the four evidence directories' env.sh (r11u213: r11u206repro, v11u206repro, r11u207repro,
# v11u207repro) and of this directory's env.sh: sourced from the checkout (rc, number of names) and, as the NEGATIVE
# control, sourced from a scratch copy of the driver dir beside a canaudit.sh whose FENCED= line holds two dummy names
# (must refuse).  Also a word scan of the five directories for the fenced names (the POSITIVE control plants one name
# in a scratch file).  Prints no fenced name.
source "$(dirname "$0")/env.sh" || exit 2
T=/tmp/r11u221_fence; rm -rf $T; mkdir -p $T/tools/probe/r11u107repro
echo 'FENCED="dummyA dummyB"' > $T/tools/probe/r11u107repro/canaudit.sh
for d in r11u216repro v11u216repro r11u215repro v11u215repro r11u221verify; do   # r11u221
  real=$(env -i HOME="$HOME" PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true R196_BIN=/tmp V196_BIN=/tmp bash -c "source $R221_ROOT/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
  mkdir -p $T/tools/probe/$d; cp -r $R221_ROOT/tools/probe/$d/drivers $T/tools/probe/$d/
  neg=$(env -i HOME="$HOME" PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true R196_BIN=/tmp V196_BIN=/tmp bash -c "source $T/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
  hits=$(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $R221_ROOT/tools/probe/$d 2>/dev/null | wc -l)
  echo "$d env.sh checkout: $real | two-name canaudit: $neg | files naming a fenced test: $hits"
done
f1=$(echo $FENCED | cut -d' ' -f1); mkdir -p $T/pos; echo "x $f1 y" > $T/pos/planted.txt
echo "positive control: planted files found $(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $T/pos | wc -l) (expect 1)"
rm -rf $T
