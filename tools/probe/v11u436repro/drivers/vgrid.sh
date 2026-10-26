#!/bin/bash
# vgrid.sh <casedir>: ver2 reading + R11V436_OFF bytes == law bytes
D=/tmp/wt_v11u436/tools/probe/v11u436repro/drivers; c=$1
k=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); O=/tmp/v11u436_scr/out/$k
v=$(bash $D/run1.sh $c /tmp/v11u436_bin/ver3 v | cut -d' ' -f2-)
bash $D/run1.sh $c /tmp/v11u436_bin/ver3 vo R11V436_OFF=1 >/dev/null
bash $D/run1.sh $c /tmp/v11u436_bin/ver3 vu R11U436_OFF=1 >/dev/null
ml=$(md5sum <$O/l/ours.uhdm|cut -c1-8); mo=$(md5sum <$O/vo/ours.uhdm|cut -c1-8); mp=$(md5sum <$O/p/ours.uhdm|cut -c1-8); mu=$(md5sum <$O/vu/ours.uhdm|cut -c1-8)
echo "$k | ver $v | R11V436_OFF $([ $ml = $mo ] && echo =law || echo DIFF) | R11U436_OFF $([ $mp = $mu ] && echo =pristine || echo DIFF) | ver==law $([ $ml = $(md5sum <$O/v/ours.uhdm|cut -c1-8) ] && echo yes || echo no)"
