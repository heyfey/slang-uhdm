#!/bin/bash
# upstream slang acceptance per case dir
for c in "$@"; do GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"; (cd $c && timeout 60 /home/heyfey/.local/bin/slang dut.sv $GT --single-unit > /tmp/v11u436_scr/up.log 2>&1); r=$?; echo "$(echo $c | sed 's|.*/cases/||') up_rc=$r $( [ $r != 0 ] && grep -m1 error /tmp/v11u436_scr/up.log)"; done
