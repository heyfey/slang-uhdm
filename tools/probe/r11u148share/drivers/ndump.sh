#!/bin/bash
# ndump.sh DB: uhdm-dump with checkout paths normalised
/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump "$1" 2>&1 | tail -n +2 | sed -E 's#/[^ ,]*/(test|tests)/([^/ ,]+)/#T/\2/#g; s#/tmp/[^ ,]*/##g'
