#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: adapted from r11u190verify/drivers/sweep.sh) sweep.sh <slang binary or state wrapper> <workdir> [corpora]:
# the gate sweep (tests/sweep.sh --jobs 3) from this checkout with the pinned tools exported and SLANG_UHDM set to the
# given frozen binary.  Log: <workdir>.log.
source "$(dirname "$0")/env.sh" || exit 2
export SLANG_UHDM=$1; W=$2; C=${3:-}
cd $R217_ROOT
if [ -n "$C" ]; then tests/sweep.sh --jobs 3 --workdir $W --corpus "$C" > $W.log 2>&1
else tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1; fi
echo "SWEEP_RC=$?" >> $W.log
