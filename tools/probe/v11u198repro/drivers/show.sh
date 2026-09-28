#!/bin/bash
# v11u198: for one judged case (as passed to judge.sh, relative), print the pristine->law dump diff and the golden lines
# carrying the same object names (ELAB=1 for the -elabuhdm form's run directories).
c=$1; h=$(echo "$c${ELAB:+E}" | md5sum | cut -c1-10); P=/tmp/v11u198_judge/pris/$h L=/tmp/v11u198_judge/${LB:-law}/$h
echo "=== $c ($h) cmp: $(head -c 300 $P/cmp.txt | tr '\n' ' ')"
diff $P/o.dump $L/o.dump | head -${N:-40}
