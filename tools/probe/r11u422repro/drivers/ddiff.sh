#!/bin/bash
# ddiff.sh <golden.uhdm> <ours.uhdm>: path-normalised uhdm-dump diff (file: basenames, header line dropped)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
n() { $D $1 2>&1 | tail -n +2 | sed -E 's|file:[^,]*/|file:|g'; }
diff <(n $1) <(n $2)
