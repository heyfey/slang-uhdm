#!/bin/bash
# waits until no sweep/runner process is live for 3 consecutive readings 60 s apart
P1='sweep\.s''h|svtests_matr''ix|verify_gold''en|check_pro''be|downstream_uhdm2rt''lil|check_svte''sts|fullswe''ep'
n=0
while [ $n -lt 3 ]; do
  if pgrep -f "$P1" >/dev/null; then n=0; else n=$((n+1)); fi
  sleep 60
done
date
