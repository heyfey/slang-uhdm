#!/bin/bash
f=$1
a=$(/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump /tmp/v11u174_swP/probe/$f 2>/dev/null | sed -E 's#wt_v11u174pris#WT#g; s#v11u174_sw[PLM]#SW#g' | md5sum | cut -c1-12)
b=$(/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump /tmp/v11u174_sw${2:-L}/probe/$f 2>/dev/null | sed -E 's#wt_v11u174#WT#g; s#v11u174_sw[PLM]#SW#g' | md5sum | cut -c1-12)
[ "$a" != "$b" ] && echo "$f"
