#!/usr/bin/env bash
# r10uvm194repro/scoregrid194.sh — score one grid arm workdir with score194.py.
# MEASUREMENT ONLY.  The DEF and ELAB listings are kept in SEPARATE rows and
# NEVER merged (r10uvm166 §6 / r10v169's listcheck law).
#
#   scoregrid194.sh <arm workdir> <arm tag>
set -u
W=${1:?arm workdir}; TAG=${2:?tag}
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d)
for v in def elab; do
  [ -f "$W/cen.g.$v.txt" ] || continue
  cp "$W/cen.g.$v.txt" "$T/$TAG.$v.g.txt"
  cp "$W/cen.a.$v.txt" "$T/$TAG.$v.o.txt"
done
mkdir -p "$T/b"
for v in def elab; do
  [ -f "$W/cen.b.$v.txt" ] || continue
  sed 's/^RET|b|/RET|o|/' "$W/cen.b.$v.txt" > "$T/b/$TAG.$v.o.txt"
done
sed -i 's/^RET|a|/RET|o|/' "$T"/*.o.txt
sed -i 's/^RET|g|/RET|g|/' "$T"/*.g.txt
python3 "$HERE/score194.py" "$T" --ours2 "$T/b"
rm -rf "$T"
