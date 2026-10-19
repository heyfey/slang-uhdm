# gold.sh <workdir-of-test> -> path of golden
d=$1; g=$(sed -n 's/.*cache hit \(.*\))/\1/p' $d/cmds.txt); if [ -n "$g" ]; then echo $g/golden.uhdm; else ls $d/slpp_all/surelog.uhdm; fi
