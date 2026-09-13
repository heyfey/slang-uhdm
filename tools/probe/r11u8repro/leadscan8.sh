#!/bin/bash
# r11u8 — a-priori mover predictor, computed from PRISTINE DATABASES.
# Lists every database holding a STRING constant whose value begins with
# whitespace.  The law can only shorten such a value, so a database absent
# here CANNOT move.
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
WD=${1:?workdir}
for f in $(find "$WD" -name slang.uhdm | sort); do
  n=$("$D" "$f" 2>/dev/null | grep -cE '^ *\|STRING:[ \t]' ; true)
  [ "$n" -gt 0 ] && echo "$n $f"
done
exit 0
