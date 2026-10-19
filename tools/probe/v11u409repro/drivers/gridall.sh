#!/bin/bash
# per case: pristine, law, law R11U409_OFF, ver, ver R11V409_OFF, ver R11U409_OFF
VER=$1; OUT=$2; : > $OUT
for root in /tmp/wt_v11u409/tools/probe/r11u409repro/cases /tmp/wt_v11u409/tools/probe/v11u409repro/cases; do
cd $root
for c in */*/; do c=${c%/}
 p=$(/tmp/v11u409_case.sh $c /tmp/v11u409_bin/pristine); l=$(/tmp/v11u409_case.sh $c /tmp/v11u409_bin/law)
 lo=$(/tmp/v11u409_case.sh $c /tmp/v11u409_bin/law R11U409_OFF=1); v=$(/tmp/v11u409_case.sh $c $VER)
 vo=$(/tmp/v11u409_case.sh $c $VER R11V409_OFF=1); vu=$(/tmp/v11u409_case.sh $c $VER R11U409_OFF=1)
 m(){ echo "$1" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'; }
 echo "$(basename $root | cut -c1-7)/$c | P ${p#* } | L ${l#* } | ver ${v#* } | lawOFF=pris:$([ $(m "$lo") = $(m "$p") ] && echo y || echo N) verVOFF=law:$([ $(m "$vo") = $(m "$l") ] && echo y || echo N) verUOFF=pris:$([ $(m "$vu") = $(m "$p") ] && echo y || echo N)" >> $OUT
done; done
echo DONE >> $OUT
