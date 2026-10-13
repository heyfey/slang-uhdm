#!/bin/bash
# v11u312 attrib.sh <tags file (tracetags.sh)> <cases root> <law bin> <pristine results (gridone.sh)>: for each mover, the
# law binary rerun with the switches of every tag it fired set (CONCATLV_PKGTF -> CONCATLV and PKGTF, THISIDX_INCDEC ->
# THISIDX); RESTORED when the database md5 equals pristine's: `<case> <view> <switches> RESTORED|NOT`.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "attrib: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); CR=$(cd "$2" && pwd); B=$3; P=$4
while read -r c v rest; do
  sw=$(for t in $rest; do t=${t%%:*}; case $t in THISIDX_INCDEC) echo THISIDX;; CONCATLV_PKGTF) echo CONCATLV; echo PKGTF;; CONCATLV_MODTF) echo CONCATLV; echo MODTF;; *) echo $t;; esac; done | sort -u | tr '\n' ' ')
  envs=$(for s in $sw; do printf 'R11U312_%s_OFF=1 ' $s; done)
  got=$(env $envs bash $H/case.sh $CR/$c $B $v 5 | sed 's/.*md5=//')
  want=$(awk -v c=$c -v v=$v '$1==c && $2==v{sub(/.*md5=/,""); print}' $P)
  [ "$got" = "$want" ] && r=RESTORED || r=NOT
  echo "$c $v $sw$r"
done < $1
