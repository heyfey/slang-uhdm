#!/bin/bash
# normmd5.sh <dir> : md5 of path-normalised uhdm-dump per .uhdm file
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
cd $1; ls *.uhdm | xargs -P 6 -I{} sh -c "echo {} \$($D {} 2>/dev/null | tail -n +2 | sed -E 's#/tmp/wt_v11u152(pris)?/##g' | md5sum | cut -c1-12)"
