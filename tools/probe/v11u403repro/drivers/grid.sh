#!/bin/bash
# grid.sh <cases root> -> one line per case: pristine | law
. /tmp/v11u403_scr/env.sh
for d in $(find $1 -name dut.sv | sort); do c=$(dirname $d); g=$(basename $(dirname $c))/$(basename $c)
  echo "$g | $(/tmp/v11u403_scr/rc.sh $c $PRIS) | $(/tmp/v11u403_scr/rc.sh $c $LAW)"; done
