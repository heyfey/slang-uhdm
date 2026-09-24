# offrow.sh <corp> <mode> <name> [ENV...] : rerun the row's slang command with fix1 + env, compare to the pristine sweep bytes
source /tmp/v11u130_env.sh
corp=$1; mode=$2; name=$3; shift 3
p=$(ls -d /tmp/v11u130_wdP/$corp/$mode/$name-*); rel=${p#/tmp/v11u130_wdP/}
cmd=$(sed -n 's/^slang: *[^ ]* //p' $p/cmds.txt | sed 's/ -o .*//')
cwd=$(python3 -c "
import sys; sys.path.insert(0,'/tmp/wt_v11u130pris/scripts')
" ; true)
out=/tmp/v11u130_wdX/$rel; mkdir -p $(dirname $out/x); rm -f $out/slang.uhdm
# the harness runs from the test directory; recover it from verify_golden
tdir=$(python3 /tmp/v11u130_drv/testdir.py $corp $name)
(cd $tdir && env "$@" /tmp/v11u130_bin/fix1.bin $cmd -o $out/slang.uhdm >/dev/null 2>&1)
cmp -s $out/slang.uhdm $p/slang.uhdm && echo "$name/$mode $* =PRISTINE" || echo "$name/$mode $* DIFF"
