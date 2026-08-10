#!/bin/bash
# r10uvm42 — the whole metric panel on one sweep workdir, with THIS pass's /tmp
# namespace for the probe binaries (a sibling worktree must not be able to
# clobber them mid-measurement).
# NOTE r10uvm31m.sh (PAIRTOTAL) must be run with an r10uvm30io build: the later
# io probes (31io/32io/35ti/37lv/39h/40av/41ts) add object-index fields that
# INFLATE it.
#   usage: panel.sh <sweep-workdir>
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WD=${1:?}
P=/tmp/r10uvm42_
echo "### BINDWRONG";  R10G=${P}r10uvm28g bash tools/probe/r10uvm38w.sh "$WD"
echo "### BINDTOTAL";  R10G=${P}r10uvm28g tools/probe/r10uvm28m.sh  "$WD"
echo "### PAIRTOTAL";  R10IO=${P}r10uvm30io tools/probe/r10uvm31m.sh "$WD"
echo "### IOTOTAL2";   R10IO=${P}r10uvm30io tools/probe/r10uvm30iom.sh "$WD"
echo "### IOTOTAL";    R10IO=${P}r10uvm29io tools/probe/r10uvm29iom.sh "$WD"
echo "### INITTOTAL";  R10V=${P}r10uvm29v  tools/probe/r10uvm29m.sh  "$WD"
echo "### CTOR/BODY";  R10S=${P}r10uvm27s  tools/probe/r10uvm27m.sh  "$WD"
echo "### VARTOTAL";   R10V=${P}r10uvm26v  tools/probe/r10uvm26m.sh  "$WD"
echo "### r10uvm23m";  R10B=${P}r10uvm23b  tools/probe/r10uvm23m.sh  "$WD"
