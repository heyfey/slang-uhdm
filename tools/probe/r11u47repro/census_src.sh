#!/bin/bash
# r11u47 SOURCE CENSUS — every file in either corpus that writes an ANONYMOUS
# aggregate as a type parameter's default: `[local]param type <N> = struct|union
# [packed] {`  (the construct § tpAnonAggParamTsNoStamp47 governs).  The
# POSITIVE CONTROL is the grid: /tmp/r11u47_grid/g*/dut.sv must be found.
ROOTS="/home/heyfey/git-repos/uhdm2rtlil/test /home/heyfey/git-repos/Surelog/tests /home/heyfey/git-repos/Surelog/third_party/tests /home/heyfey/git-repos/sv-tests/third_party/tools/Surelog/third_party/UVM ${EXTRA:-}"
grep -rlE '(localparam|parameter)[[:space:]]+type[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=[[:space:]]*(struct|union)' \
     --include='*.sv' --include='*.v' --include='*.svh' --include='*.vh' $ROOTS 2>/dev/null | sort
