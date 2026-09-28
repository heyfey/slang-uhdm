#!/bin/bash
# r11u201: the byte controls — every case of the named earlier passes' evidence grids (tools/probe/<pass>/**/dut.sv,
# listed in <list>), judged with the pristine and the law binary (judge.sh: verdict per binary, `=` when the law
# binary's database is byte-identical to the pristine one).  Fence fail-closed in case.sh.
# usage: ctlbytes.sh <list of case dirs> <out tsv> [law binary name, default law.bin]
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
bash $HERE/judge.sh "pris.bin ${3:-law.bin}" $(cat $1) > $2
