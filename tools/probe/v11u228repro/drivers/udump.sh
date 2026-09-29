#!/bin/bash
# udump.sh <db.uhdm> : uhdm-dump through a guarded path (never through an unset variable), ids stripped.
U=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$U" ] || { echo "udump: uhdm-dump missing" >&2; exit 2; }
[ -f "$1" ] || { echo "udump: no database $1" >&2; exit 2; }
"$U" "$1" 2>&1 | sed 's/, id:[0-9]*//; s#/[^ ]*/##g'
