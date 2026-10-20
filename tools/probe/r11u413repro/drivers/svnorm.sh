#!/bin/bash
# r11u413 svnorm.sh <row>: normalized-dump md5 of the control's and the law's kept sv-tests database
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; r=$1
n(){ timeout 900 $D $1 2>/dev/null | sed -e 's#/tmp/intr11u411/svtests/work#W#g; s#/tmp/r11u413_w5/svtests/work#W#g; s/, id:[0-9]*//' | grep -v 'Restored design' | md5sum | cut -c1-12; }
echo "$r $(n /tmp/intr11u411/svtests/work/$r/slang.uhdm) $(n /tmp/r11u413_w5/svtests/work/$r/slang.uhdm)"
