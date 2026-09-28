#!/bin/bash
# lsdet.sh <tag> <N> [ENV=VAL ...]: N concurrent runs of law.bin on cases/LS/l01_scale (the multi-file determinism case of
# § lawSCopyIdOrder186) under the given switches; prints the md5 of each database and the distinct-hash count.
source "$(dirname "$0")/env.sh" || exit 2
T=$1; N=$2; shift 2; O=/tmp/r11u194_lsdet/$T; rm -rf $O; mkdir -p $O
cd $R194_DIR/cases/LS/l01_scale
for i in $(seq 1 $N); do (env "$@" $LAW $(cat files) --single-unit --nobuiltin -o $O/$i.uhdm > $O/$i.log 2>&1; echo rc=$? >> $O/$i.log) & done; wait
echo "$T [$*] $(for i in $(seq 1 $N); do echo -n "$(md5sum < $O/$i.uhdm | cut -c1-8) "; done) distinct=$(for i in $(seq 1 $N); do md5sum < $O/$i.uhdm; done | sort -u | wc -l)"
