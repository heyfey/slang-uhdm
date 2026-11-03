#!/bin/bash
# census.sh <bin> <tsv> <outdir>: run <bin> with R11U474_TRACE on every "<row>\t<argv>" line (cwd = a scratch dir), 3 at a time
B=$1; T=$2; O=$3; mkdir -p $O/trace $O/db
[ -x "$B" ] || { echo "no binary"; exit 1; }
run(){ row="$1"; shift; k=$(echo "$row" | tr '/' '_'); mkdir -p "$O/trace/$k"; rm -f "$O/db/$k.uhdm"
  ( cd /tmp && R11U474_TRACE="$O/trace/$k" timeout 600 "$B" "$@" -o "$O/db/$k.uhdm" > "$O/db/$k.log" 2>&1 </dev/null ); echo "$row rc=$?" >> "$O/rc.txt"; rm -f "$O/db/$k.uhdm"; }
export -f run; export B O
while IFS=$'\t' read -r row args; do eval "set -- $args"; set -- "${@:1:$#}"; 
  # drop the trailing '-o <path>' of the recorded command line
  a=(); skip=0; for x in "$@"; do if [ $skip = 1 ]; then skip=0; continue; fi; if [ "$x" = "-o" ]; then skip=1; continue; fi; a+=("$x"); done
  while [ $(jobs -r | wc -l) -ge 3 ]; do sleep 0.5; done
  run "$row" "${a[@]}" &
done < $T
wait
