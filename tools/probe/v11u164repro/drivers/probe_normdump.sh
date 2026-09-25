#!/bin/bash
# prints "<file> <md5 of normalized dump>"
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
echo "$(basename $1) $($D $1 2>/dev/null | tail -n +2 | sed -E 's#/tmp/wt_v11u164(pris)?/##g; s#/tmp/v11u164_sw[A-Za-z0-9]*/##g' | md5sum | cut -c1-12)"
