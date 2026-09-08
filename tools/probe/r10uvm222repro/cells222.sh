#!/usr/bin/env bash
# r10uvm222 — THE CELL SCORER (the arms' own verdict).  MEASUREMENT ONLY.
#
# `score222.sh` prints one record per CALL object and per `vpiPrefix`; this
# joins golden's records against ours as MULTISETS (a dict keyed by record
# would drop the repeated copies a DEF/ELAB dump carries) and reports, per arm:
#     GOLDEN-ONLY  records golden has and we do not   (MISSING)
#     OURS-ONLY    records we have and golden does not (EXTRA)
# for the pristine and the patched grid side by side.  A law that moves TOWARD
# golden lowers BOTH columns and raises neither.
#
#   usage: cells222.sh <pristine-griddir> <patched-griddir> [arm ...]
set -u
P=${1:?pristine griddir}; Q=${2:?patched griddir}
shift 2 || true
D=$(cd "$(dirname "$0")" && pwd)
ARMS=${*:-$(cd "$P" && ls -d */ | tr -d /)}
printf "%-12s %14s %12s   %14s %12s   %s\n" \
       ARM PRIS_MISSING PRIS_EXTRA PAT_MISSING PAT_EXTRA VERDICT
for a in $ARMS; do
  for g in "$P" "$Q"; do
    bash "$D/score222.sh" "$g" "$a" 2>/dev/null \
      | sed "s/^$a golden //; t g; s/^$a ours //; t o; d
             :g s/^/G /; b
             :o s/^/O /" > "/tmp/.cells222.$$.$(basename "$g")"
  done
  pf=/tmp/.cells222.$$.$(basename "$P"); qf=/tmp/.cells222.$$.$(basename "$Q")
  if [ ! -s "$pf" ] && [ ! -s "$qf" ]; then
    printf "%-12s %14s %12s   %14s %12s   %s\n" "$a" - - - - \
      "NO CALL RECORDS (error-recovery arm)"
    continue
  fi
  read -r pm pe < <(awk '$1=="G"{sub(/^G /,"");g[$0]++} $1=="O"{sub(/^O /,"");o[$0]++}
                        END{m=0;e=0;
                          for(k in g){d=g[k]-(k in o?o[k]:0); if(d>0)m+=d}
                          for(k in o){d=o[k]-(k in g?g[k]:0); if(d>0)e+=d}
                          print m, e}' "$pf")
  read -r qm qe < <(awk '$1=="G"{sub(/^G /,"");g[$0]++} $1=="O"{sub(/^O /,"");o[$0]++}
                        END{m=0;e=0;
                          for(k in g){d=g[k]-(k in o?o[k]:0); if(d>0)m+=d}
                          for(k in o){d=o[k]-(k in g?g[k]:0); if(d>0)e+=d}
                          print m, e}' "$qf")
  v=UNCHANGED
  if [ "$qm" -lt "$pm" ] || [ "$qe" -lt "$pe" ]; then v=TOWARD-GOLDEN; fi
  if [ "$qm" -gt "$pm" ] || [ "$qe" -gt "$pe" ]; then v=AWAY-GOLDEN; fi
  printf "%-12s %14s %12s   %14s %12s   %s\n" "$a" "$pm" "$pe" "$qm" "$qe" "$v"
  rm -f "$pf" "$qf"
done
