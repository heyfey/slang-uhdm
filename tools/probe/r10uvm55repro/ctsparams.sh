#!/bin/bash
# r10uvm55repro/ctsparams.sh — list EVERY class_typespec that carries a
# vpiParameter, from a `.cts` file written by ctscen.sh / ctsfield, with the
# object's name, span, class_defn and PARENT KIND.
#
#   usage: ctsparams.sh <file.cts>
#
# GUARD: a .cts file with NO `parameters=>=1` row prints
# `ZERO parameter-carrying class_typespec` and exits 5, so an empty listing is
# never mistaken for "I did not look".
set -u
F=${1:?path to a .cts file}
[ -s "$F" ] || { echo "FATAL: $F missing or empty"; exit 3; }
awk '
  /^CTS /   { hdr=$0 }
  /^  CMP / { cmp=$0 }
  /^  DUMPONLY / {
     if (cmp ~ /parameters=[1-9]/) {
        cd=cmp; sub(/.*classdefn=/,"",cd);
        pk=$0;  sub(/.*parent=/,"",pk); sub(/ instance=.*/,"",pk);
        np=cmp; sub(/.* parameters=/,"",np); sub(/ .*/,"",np);
        print hdr "  nparam=" np "  classdefn=" cd "  parent=" pk;
        n++
     }
  }
  END { print "-- parameter-carrying class_typespec = " n+0; if ((n+0)==0) exit 5 }
' "$F"
