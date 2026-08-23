set -u
S=${S:-/tmp/v110_wd/ship_sl}; P=${P:-/tmp/v110_wd/pris_sl}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
tot=0
for f in $(cd "$S" && find . -name slang.uhdm | sort); do
  a=$(md5sum "$S/$f" | cut -c1-12); b=$(md5sum "$P/$f" | cut -c1-12)
  [ "$a" = "$b" ] && continue
  $DUMP "$S/$f" 2>/dev/null | sed "s#$S##; s#$P##" | sort > ${TMPDIR:-/tmp}/v110_at_s.txt
  $DUMP "$P/$f" 2>/dev/null | sed "s#$S##; s#$P##" | sort > ${TMPDIR:-/tmp}/v110_at_p.txt
  add=$(diff ${TMPDIR:-/tmp}/v110_at_p.txt ${TMPDIR:-/tmp}/v110_at_s.txt | grep -c '^>'; true)
  del=$(diff ${TMPDIR:-/tmp}/v110_at_p.txt ${TMPDIR:-/tmp}/v110_at_s.txt | grep -c '^<'; true)
  echo "== $f  added=$add removed=$del"
  diff ${TMPDIR:-/tmp}/v110_at_p.txt ${TMPDIR:-/tmp}/v110_at_s.txt | grep -E '^[<>]' | sed 's/^\(.\) */\1 /' | sort | uniq -c | sort -rn
  tot=$((tot+1))
done
echo "ATTRIBUTED $tot databases"
