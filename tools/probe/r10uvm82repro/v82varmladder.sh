#!/usr/bin/env bash
# verifier: ladder every arm pristine+patched, report rung sets and NEW rungs.
set -u
LAD=/tmp/v82_lad2/ctladder
out=/tmp/v82_armlad; mkdir -p $out
printf "%-5s %7s %7s %7s %7s  %s\n" ARM RUNG_B RUNG_A FAM82_B FAM82_A NEW_RUNG_KEYS_AFTER
for n in "$@"; do
  P=/tmp/v82_arm_pris_v$n; Q=/tmp/v82_arm_pat_v$n
  [ -f $P/slang.uhdm ] && [ -f $Q/slang.uhdm ] || { echo "v$n SKIP"; continue; }
  $LAD $P/slpp_all/surelog.uhdm $P/slang.uhdm --max=300 --budget=180 > $out/b$n.txt 2>&1
  $LAD $Q/slpp_all/surelog.uhdm $Q/slang.uhdm --max=300 --budget=180 > $out/a$n.txt 2>&1
  rb=$(grep -c '^RUNG' $out/b$n.txt); ra=$(grep -c '^RUNG' $out/a$n.txt)
  fb=$(grep -c 'FAM=parameter|VpiImported|O-EMPTY' $out/b$n.txt; true)
  fa=$(grep -c 'FAM=parameter|VpiImported|O-EMPTY' $out/a$n.txt; true)
  # rung key = FAM + the golden object's line span (path-free, order-blind)
  awk '/^RUNG/{fam=""; for(i=1;i<=NF;i++) if($i ~ /^FAM=/) fam=$i; getline l; sub(/^ *L  /,"",l); sub(/#[0-9]*$/,"",l); sub(/[^ ]*\//,"",l); print fam"\t"l}' $out/b$n.txt | sort -u > $out/kb$n
  awk '/^RUNG/{fam=""; for(i=1;i<=NF;i++) if($i ~ /^FAM=/) fam=$i; getline l; sub(/^ *L  /,"",l); sub(/#[0-9]*$/,"",l); sub(/[^ ]*\//,"",l); print fam"\t"l}' $out/a$n.txt | sort -u > $out/ka$n
  nw=$(comm -13 $out/kb$n $out/ka$n | wc -l)
  printf "%-5s %7s %7s %7s %7s  new=%s\n" "v$n" "$rb" "$ra" "$fb" "$fa" "$nw"
  [ "$nw" -gt 0 ] && comm -13 $out/kb$n $out/ka$n | sed 's/^/        NEW /'
done
