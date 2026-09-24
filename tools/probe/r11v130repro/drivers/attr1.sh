# attr1.sh <corp> <mode> <name> : which single R11U130 switch moves this row's fix1 bytes
source /tmp/v11u130_env.sh
corp=$1; mode=$2; name=$3
p=$(ls -d /tmp/v11u130_wdF/$corp/$mode/$name-*); cmd=$(sed -n 's/^slang: *[^ ]* //p' $p/cmds.txt | sed 's/ -o .*//')
tdir=$(python3 /tmp/v11u130_drv/testdir.py $corp $name)
out=/tmp/v11u130_attr/$corp/$mode/$name; mkdir -p $out; laws=""
for s in DEFNETLOC WILDSPAN CLSARGNET NETSIGN PVPARAM SUSIGN IFSUKW REDEFLINE INCNOTEXT GVTSFILE; do
  rm -f $out/s.uhdm; (cd $tdir && env R11U130_${s}_OFF=1 /tmp/v11u130_bin/fix1.bin $cmd -o $out/s.uhdm >/dev/null 2>&1)
  cmp -s $out/s.uhdm $p/slang.uhdm || laws="$laws $s"
done
echo "$corp $name/$mode:$laws"
