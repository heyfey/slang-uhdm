#!/bin/bash
# cmpc.sh <workroot> <rel-without-.sv>: uhdm-cmp output
d=$1/$2; g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[^) ]*' $d/cmds.txt | head -1)/golden.uhdm
/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp $g $d/slang.uhdm 2>&1
