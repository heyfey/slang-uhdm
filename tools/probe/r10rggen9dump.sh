#!/bin/bash
# r10rggen9dump: uhdm-dump both sides of the Rggen pair once into /tmp.
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen9_slang.path)
[ -s /tmp/r10rggen9_g.dump ] || timeout 1800 $HOME/git-repos/UHDM/build/bin/uhdm-dump "$G" > /tmp/r10rggen9_g.dump 2>&1
timeout 1800 $HOME/git-repos/UHDM/build/bin/uhdm-dump "$S" > /tmp/r10rggen9_s.dump 2>&1
wc -l /tmp/r10rggen9_g.dump /tmp/r10rggen9_s.dump
