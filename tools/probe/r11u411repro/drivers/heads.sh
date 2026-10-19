#!/bin/bash
# r11u411_heads.sh <runner outdir> : per row, golden (cache) vs ours: uhdm-cmp LHS/RHS head summary
O=$1; CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
tail -n +2 $O/m.csv | cut -d, -f2 | while read p; do
 w=$O/work/${p%.sv}; c=$(sed -n 's/^(golden cache hit \(.*\))$/\1/p' $w/surelog.log)
 g=$(ls $c/*.uhdm 2>/dev/null | head -1); [ -z "$g" ] && g=$w/slpp_all/surelog.uhdm
 timeout 300 $CMP $g $w/slang.uhdm > $w/cmp.txt 2>&1
 l=$(awk '/^LHS:/{f=1;next} f&&/^[a-z_]+:/{print;exit}' $w/cmp.txt | sed 's/id:[0-9]*, //')
 lf=$(awk '/^LHS:/{f=1;next} f&&/^[a-zA-Z]+:$/{print;exit}' $w/cmp.txt)
 r=$(awk '/^RHS:/{f=1;next} f&&/^[a-z_]+:/{print;exit}' $w/cmp.txt | sed 's/id:[0-9]*, //')
 lv=$(awk '/^LHS:/{f=1;next} f&&/^\|vpi(Decompile|Name|Size)|INT:/{print;exit}' $w/cmp.txt)
 rv=$(awk '/^RHS:/{f=1;next} f&&/^\|vpi(Decompile|Name|Size)|INT:/{print;exit}' $w/cmp.txt)
 echo "$p | $lf | L: $l $lv | R: $r $rv | n=$(wc -l < $w/cmp.txt)"
done
