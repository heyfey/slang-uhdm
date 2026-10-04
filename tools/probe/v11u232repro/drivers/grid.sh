#!/bin/bash
# grid.sh <listfile of case dirs> <outfile>: every case x both views (EL=0/1) x the tags
# P pristine, L law, O law+R11U232_OFF, F fix, V fix+R11V232_OFF, W fix+R11U232_OFF, C fix+R11V232_CASTARG_OFF,
# T fix+R11V232_TRUNCBASE_OFF. Each line carries the run's exit code (rc=).
H=$(cd "$(dirname "$0")" && pwd); . $H/env.sh || exit 2
run(){ c=$1; for el in 0 1; do
  EL=$el $H/case.sh $c P $B/pristine
  EL=$el $H/case.sh $c L $B/law
  EL=$el $H/case.sh $c O $B/law R11U232_OFF=1
  EL=$el $H/case.sh $c F $B/fix
  EL=$el $H/case.sh $c V $B/fix R11V232_OFF=1
  EL=$el $H/case.sh $c W $B/fix R11U232_OFF=1
  EL=$el $H/case.sh $c C $B/fix R11V232_CASTARG_OFF=1
  EL=$el $H/case.sh $c T $B/fix R11V232_TRUNCBASE_OFF=1
done; }
export -f run; export H
xargs -a $1 -P 3 -I{} bash -c 'run {}' > $2 2>&1
