#!/bin/bash
# ddiff.sh <golden> <ours> : normalised dump diff
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
diff <($D $1 2>&1 | tail -n +2 | sed -E 's/id:[0-9]+,? ?//; s/, file:[^,]*//') <($D $2 2>&1 | tail -n +2 | sed -E 's/id:[0-9]+,? ?//; s/, file:[^,]*//')
