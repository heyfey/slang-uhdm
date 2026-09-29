#!/bin/bash
# (r11u229: copied from r11u226verify/drivers/fencecheck.sh; the directories of passes 224, 225, r11u226 and this pass.)
# v11u207repro) and of this directory's env.sh: sourced from the checkout (rc, number of names) and, as the NEGATIVE
# control, sourced from a scratch copy of the driver dir beside a canaudit.sh whose FENCED= line holds two dummy names
# (must refuse).  Also a word scan of the five directories for the fenced names (the POSITIVE control plants one name
# in a scratch file).  Prints no fenced name.
source "$(dirname "$0")/env.sh" || exit 2
T=/tmp/r11u229_fence; rm -rf $T; mkdir -p $T/tools/probe/r11u107repro
echo 'FENCED="dummyA dummyB"' > $T/tools/probe/r11u107repro/canaudit.sh
TOOLS="SURELOG=$SURELOG UHDM_CMP=$UHDM_CMP UHDM_DUMP=$UHDM_DUMP B=$R229_BIN R226_BIN=$R229_BIN R229_BIN=$R229_BIN S=/tmp/r11u229_fence_s"
for d in r11u224repro v11u224repro r11u225repro v11u225repro r11u226verify r11u229verify; do
  mkdir -p $T/tools/probe/$d; cp -r $R229_ROOT/tools/probe/$d/drivers $T/tools/probe/$d/
  for mode in bare tools; do
    ev="HOME=$HOME PATH=/usr/local/bin:/usr/bin:/bin SLANG_UHDM=/bin/true"; [ $mode = tools ] && ev="$ev $TOOLS"
    real=$(env -i $ev bash -c "source $R229_ROOT/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
    neg=$(env -i $ev bash -c "source $T/tools/probe/$d/drivers/env.sh >/dev/null 2>&1; echo rc=\$? n=\$(echo \$FENCED | wc -w)")
    echo "$d [$mode env] env.sh checkout: ${real:-shell aborted} | two-name canaudit: ${neg:-shell aborted}"
  done
  hits=$(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $R229_ROOT/tools/probe/$d 2>/dev/null | wc -l)
  echo "$d files naming a fenced test: $hits"
done
f1=$(echo $FENCED | cut -d' ' -f1); mkdir -p $T/pos; echo "x $f1 y" > $T/pos/planted.txt
echo "positive control: planted files found $(grep -rlwE "$(echo $FENCED | tr ' ' '|')" $T/pos | wc -l) (expect 1)"
rm -rf $T
