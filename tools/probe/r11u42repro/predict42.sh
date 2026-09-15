#!/usr/bin/env bash
# r11u42 STAGE-1 A-PRIORI PREDICTOR — SOURCE LEVEL, no database, no dispatch.
#
#   usage: predict42.sh dirs <root> [...]      # one test per DIRECTORY (uhdm2rtlil)
#          predict42.sh sl   <root> [...]      # one test per `*.sl`   (surelog corpus)
#
# § hpTrailSelPkgFold42 can only reach a design that BOTH declares a `package`
# AND writes a dotted member select whose bracket text contains a letter (an
# identifier index).  Everything else renders byte-for-byte as before, BY
# CONSTRUCTION — the patch's fold table reaches only the bracket text of a
# hier_path NAME — so this grep is a SUPERSET of the fire set, and stage 2
# (`ct42cen.py` over those tests' PRISTINE databases) is the exact one.
#
# It READS sources only: nothing is compiled, nothing is dispatched, and the
# four slang-fenced tests are therefore unreachable from here.
set -u
MEMSEL='\.[A-Za-z_][A-Za-z0-9_]*[ \t]*\[[^]]*[A-Za-z_]'
MODE=${1:?dirs|sl}; shift
tot=0; hit=0
check() {  # $1 = test name, $2 = source dir
  local srcs
  srcs=$(find "$2" -maxdepth 2 \( -name '*.sv' -o -name '*.v' -o -name '*.svh' -o -name '*.vh' \) 2>/dev/null)
  [ -n "$srcs" ] || return 0
  tot=$((tot+1))
  if grep -lE '^[[:space:]]*package[[:space:]]' $srcs > /dev/null 2>&1 &&
     grep -lE "$MEMSEL" $srcs > /dev/null 2>&1; then
    echo "FIRE-CANDIDATE $1  ($2)"
    hit=$((hit+1))
  fi
}
for root in "$@"; do
  [ -d "$root" ] || { echo "MISSING_ROOT $root"; continue; }
  if [ "$MODE" = dirs ]; then
    while IFS= read -r d; do check "$(basename "$d")" "$d"; done \
      < <(find "$root" -mindepth 1 -maxdepth 1 -type d | sort)
  else
    # One test per `*.sl`, exactly as verify_golden.py's discover_surelog scans;
    # the sources live in the `.sl` file's OWN directory.
    while IFS= read -r f; do
      d=$(dirname "$f"); n=$(basename "$f" .sl); check "$n" "$d"
    done < <(find "$root" -name '*.sl' | sort)
  fi
done
echo "STAGE1 tests-with-sources=$tot FIRE-CANDIDATES=$hit"
