#!/usr/bin/env bash
# r10buvm19repro/detcheck19.sh — determinism: N runs of ONE binary on ONE
# command line, hashing the database each time.  A single distinct hash means
# the row is byte-deterministic for that binary; more than one means the row is
# one of the campaign's documented COINS and every mover attribution on it must
# be made ORDER-BLIND.
#
# usage: detcheck19.sh <binary> <n> <source...>
set -u
B=$1; N=$2; shift 2
T=$(mktemp -d /tmp/r10buvm19_det.XXXXXX)
for i in $(seq 1 "$N"); do
  "$B" "$@" --single-unit -o "$T/o.uhdm" >/dev/null 2>&1
  if [ -s "$T/o.uhdm" ]; then md5sum "$T/o.uhdm" | cut -c1-12; else echo NO_OUTPUT; fi
done | sort | uniq -c
rm -rf "$T"
