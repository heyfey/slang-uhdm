#!/bin/bash
# shobj.sh <uhdm> <regex of full name>: the actual typespec of every top-level (dump tail) ref_var with that name
[ -x "$UHDM_DUMP" ] || { echo "no UHDM_DUMP"; exit 2; }
$UHDM_DUMP $1 2>/dev/null | awk -v re="$2" '
  /^\\_ref_var: / && $0 ~ re {f=1; n=0; print "OBJ " $0; next}
  /^\\_/ {f=0}
  f && /vpiActual:/ {getline; sub(/^ */,""); print "   TS " $0}
  f && /vpiParent:/ && n==0 {getline; sub(/^ */,""); print "   PAR " $0; n=1}'
