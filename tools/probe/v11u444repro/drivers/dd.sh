#!/bin/bash
# dd.sh <casedir> <tagA> <tagB|gold>: normalized dump diff between two outputs (or gold)
c=$(cd $1 && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
f(){ if [ $1 = gold ]; then echo /tmp/v11u444_scr/gold/$h/slpp_all/surelog.uhdm; else echo /tmp/v11u444_scr/out/$key/$1/ours.uhdm; fi; }
norm(){ /home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump $1 2>/dev/null | sed 's/, id:[0-9]*//; s|file:[^,]*/|file:|; s|\(vpi[A-Za-z]*File\):.*/|\1:|' | tail -n +2; }
diff <(norm $(f $2)) <(norm $(f $3))
