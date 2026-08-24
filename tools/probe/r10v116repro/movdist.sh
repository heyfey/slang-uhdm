#!/usr/bin/env bash
set -u
OUT=/tmp/v116_scratch/movdist; mkdir -p $OUT
for cell in default/BuildUVMPkg-bf853d43 default/MiniAmiq-544c7f61 default/Scoreboard-59431470 default/SeqDriver-32af76aa default/SimpleUVM-1dc93a62 testflags/BuildUVMPkg-bf853d43 testflags/MiniAmiq-544c7f61 testflags/SeqDriver-32af76aa testflags/SimpleUVM-1dc93a62; do
  key=$(echo $cell | tr '/' '_')
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' /tmp/v116_wd/slpat/$cell/cmds.txt | head -1)/golden.uhdm
  [ -f "$g" ] || { echo "$key NO-GOLDEN"; continue; }
  uhdm-dump "$g" 2>/dev/null | sed '1s#^[^:]*:#<DB>:#' > $OUT/$key.g.txt
  uhdm-dump /tmp/v116_wd/slpris/$cell/slang.uhdm 2>/dev/null | sed '1s#^[^:]*:#<DB>:#' > $OUT/$key.a.txt
  uhdm-dump /tmp/v116_wd/slpat/$cell/slang.uhdm 2>/dev/null | sed '1s#^[^:]*:#<DB>:#' > $OUT/$key.b.txt
  for t in g a b; do sort $OUT/$key.$t.txt > $OUT/$key.$t.srt; done
  da=$(diff $OUT/$key.g.txt $OUT/$key.a.txt | grep -c '^[<>]'; true)
  db=$(diff $OUT/$key.g.txt $OUT/$key.b.txt | grep -c '^[<>]'; true)
  sa=$(diff $OUT/$key.g.srt $OUT/$key.a.srt | grep -c '^[<>]'; true)
  sb=$(diff $OUT/$key.g.srt $OUT/$key.b.srt | grep -c '^[<>]'; true)
  ab=$(diff $OUT/$key.a.srt $OUT/$key.b.srt | grep -c '^[<>]'; true)
  printf "%-32s gold=%-8s seqDIST pris=%-7s pat=%-7s | ORDERBLIND pris=%-7s pat=%-7s | A-vs-B=%s\n" "$key" "$(wc -l < $OUT/$key.g.txt)" "$da" "$db" "$sa" "$sb" "$ab"
done
