#!/usr/bin/env bash
# normalise a uhdm-dump: drop ids, file paths, and the workdir; sort -u.
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
"$D" "$1" 2>/dev/null \
 | sed -E 's/, id:[0-9]+//g; s/id:[0-9]+//g; s#(file|vpiRefFile|vpiFile):[^,|]*#\1:X#g; s#/tmp/[^ ,|]*##g' \
 | sed -E 's/^[[:space:]]+//' | sort -u
