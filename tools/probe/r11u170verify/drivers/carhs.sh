#!/bin/bash
# carhs.sh <db>...: per elaborated continuous assignment (the uhdmtopModules section), the Rhs constant's
# type/size/value/decompile as uhdm-dump prints them (measurement only).
for f in "$@"; do echo "== $f"; $UHDM_DUMP $f 2>/dev/null | awk '/uhdmtopModules/{t=1} t && /\\_cont_assign:/{if(c)print c; c=$0; n=0; next} t && c && n<14 {n++; if ($0 ~ /vpiRhs|constant|operation|vpiSize|INT:|BIN:|HEX:|DEC:|vpiDecompile|vpiConstType|vpiOpType/) c=c " |" gensub(/^ +/, "", 1, $0)} END{if(c)print c}'; done
