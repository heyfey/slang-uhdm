#!/usr/bin/env bash
# r10vrgg6 — independent MOVER PREDICTION from the SOURCES, before any patched
# database is read.  A test can only move under § nestedParamActualTs6 if it
# declares a parameter whose initializer is a CALL WITH AN IDENTIFIER ARGUMENT.
set -u
for root in "$HOME/git-repos/Surelog/tests" "$HOME/git-repos/Surelog/third_party/tests"; do
  [ -d "$root" ] || continue
  find "$root" -maxdepth 1 -mindepth 1 -type d | sort | while read -r d; do
    if grep -rIlE '(localparam|parameter)[^;]*=[[:space:]]*[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\([[:space:]]*[A-Za-z_]' \
         --include='*.sv' --include='*.v' --include='*.svh' --include='*.vh' "$d" >/dev/null 2>&1; then
      echo "$(basename "$d")"
    fi
  done
done
