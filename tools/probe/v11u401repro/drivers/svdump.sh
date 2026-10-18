#!/bin/bash
# v11u401: sv-tests database movers by normalized uhdm-dump (the capnp packing splits path text, so bytes cannot be normalized)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x "$D" ] || { echo "uhdm-dump missing" >&2; exit 2; }
rel=$1
h(){ [ -f "$1/svtests/$rel/slang.uhdm" ] && $D "$1/svtests/$rel/slang.uhdm" 2>&1 | sed 's#/tmp/v11u401_w[LPV]##g' | md5sum | cut -c1-12 || echo none; }
echo "$rel $(h /tmp/v11u401_wP) $(h /tmp/v11u401_wL) $(h /tmp/v11u401_wV)"
