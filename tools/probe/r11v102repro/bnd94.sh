#!/bin/bash
# r11v102 wide boundary: every *.sv under a base checkout's tools/probe, pristine vs fixed,
# through r11u91repro/bnd72.sh (same file name, same dir, one after the other).
# usage: BND_PRIS=<bin> BND_LAW=<bin> BND_ROOT=<tree>/tools/probe BND_OUT=<dir> bnd94.sh > out
set -u
: ${BND_PRIS:?} ${BND_LAW:?} ${BND_ROOT:?} ${BND_OUT:?}
export BND_PRIS BND_LAW BND_ROOT BND_OUT
(cd "$BND_ROOT" && find . -name '*.sv' | sed 's#^\./##' | sort) | xargs -P 3 -n 1 bash "$BND_ROOT/r11u91repro/bnd72.sh"
