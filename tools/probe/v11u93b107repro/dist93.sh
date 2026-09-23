#!/bin/bash
# v11u93_dist.sh <gold.uhdm> <ours.uhdm>: order-blind, path-normalised dump distance (diff lines)
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
n(){ timeout 300 $D "$1" 2>&1 | sed -E 's#file:[^,]*#file:F#g; s#/(tmp|home)/[^ ,]*#P#g; s/id:[0-9]+//g' | sort; }
diff <(n "$1") <(n "$2") | grep -c '^[<>]'; true
