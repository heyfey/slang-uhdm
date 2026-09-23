#!/bin/bash
# order-blind, workdir-normalised sorted-dump diff line count between two slang.uhdm
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
n(){ timeout 600 $D "$1" 2>&1 | sed -E 's#/tmp/[a-z0-9_]+/#W/#g; s#file:[^,]*#file:F#g' | sort; }
diff <(n "$1") <(n "$2") | grep -c '^[<>]'; true
