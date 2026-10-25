#!/bin/bash
# v11u427 vgrid.sh <cases root> <pris file> <law file> <out>: per case: pristine/law (from files or run), verified, R11V427_OFF -> law bytes, R11U427_OFF -> pristine bytes
R=$1; PF=$2; LF=$3; OUT=$4; : > $OUT
P=/tmp/v11u427_bin/pristine; L=/tmp/v11u427_bin/law; V=/tmp/v11u427_bin/verified; D=/tmp/v11u427_drv/case.sh
m(){ echo "$1" | grep -o 'rc=[0-9]*\|md5=[0-9a-f]*' | tr '\n' ' '; }
f(){ echo "$1" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^rc=|^cmp=|^away=/) printf "%s ",$i; n=split($0,a,"| "); printf "%s", a[n]}'; }
cd $R; for c in */*; do
 p=$(grep "^$c " $PF 2>/dev/null | tail -1); [ -z "$p" ] && p="$c $(bash $D $c $P)"
 l=$(grep "^$c " $LF 2>/dev/null | tail -1); [ -z "$l" ] && l="$c $(bash $D $c $L)"
 v=$(bash $D $c $V); vo=$(bash $D $c $V R11V427_OFF=1); uo=$(bash $D $c $V R11U427_OFF=1)
 echo "$c | P $(f "$p") | L $(f "$l") | V $(f "$v") | VOFF=law:$([ "$(m "$vo")" = "$(m "$l")" ] && echo y || echo N) UOFF=pris:$([ "$(m "$uo")" = "$(m "$p")" ] && echo y || echo N) VL:$([ "$(m "$v")" = "$(m "$l")" ] && echo same || echo moved)" >> $OUT
done
