#!/bin/bash
# judge every case in allcases.txt, both views, with LB; out tsv
cd /tmp/wt_v11u207/tools/probe
export LB=$1 OFFCHK=${OFFCHK:-}
out=$2
cat ${CASELIST:-/tmp/v11u207_scr/allcases.txt} | xargs -P 3 -I{} bash -c 'bash /tmp/wt_v11u207/tools/probe/v11u207repro/drivers/j.sh {} 2>/dev/null; ELAB=1 bash /tmp/wt_v11u207/tools/probe/v11u207repro/drivers/j.sh {} 2>/dev/null' | sort > $out
