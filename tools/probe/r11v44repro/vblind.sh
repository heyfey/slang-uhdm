#!/bin/bash
# v11u44 independent blinder: ids + every source location. Design names blinded
# ONLY as the literal test name passed in (one token), so nothing else vanishes.
set -u
f=$1; n=${2:-__NONE__}
sed -E 's/id:[0-9]+/id:#/g; s/line:[0-9]+:[0-9]+/line:#/g; s/endln:[0-9]+:[0-9]+/endln:#/g;
        s/col:[0-9]+/col:#/g; s#file:[^,]*#file:#g;
        s/vpiRef(File|LineNo|ColumnNo|EndLineNo|EndColumnNo):.*/vpiRef\1:#/' "$f" \
 | sed -E "s/\b$n\b/<D>/g"
