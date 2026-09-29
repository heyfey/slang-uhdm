#!/bin/bash
# r11u222map: the firing census of the law218 binary (the mover PREDICTION, frozen chmod 444 with its md5 and time),
# then its full gate sweep (all four stages) in $LSW.   env (besides env.sh): LCEN (census scratch), LSW (sweep dir)
. "$(dirname "$0")/env.sh"
export SLANG_UHDM=$B/slang-uhdm.law218
rm -rf ${LCEN:?}; mkdir -p $LCEN
bash $DR/census.sh $LCEN/wd $LCEN/trace $LCEN/census > $LCEN/census.log 2>&1
(cd $REPO && python3 $DR/censum.py $LCEN/trace $LCEN/wd) > $LCEN/census_law.txt
chmod 444 $LCEN/census_law.txt; date -Iseconds > $LCEN/frozen_at.txt; md5sum $LCEN/census_law.txt >> $LCEN/frozen_at.txt; ls -l --time-style=full-iso $LCEN/census_law.txt >> $LCEN/frozen_at.txt
echo CENSUS_FROZEN
cd $REPO && tests/sweep.sh --jobs 3 --workdir ${LSW:?} > $LSW.log 2>&1; echo "SWEEP_RC=$?" >> $LSW.log
echo SWEEP_DONE
