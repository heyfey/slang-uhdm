#!/bin/bash
# waits until no sweep/runner process is live (pattern assembled at run time; own process tree excluded)
P="sweep"'\.sh|svtests_'"matrix|verify_"'golden|check_'"probe|downstream_"'uhdm2rtlil|check_'"svtests"
while true; do
  n=$(pgrep -f "$P" | while read p; do [ "$p" = "$$" ] && continue; c=$(tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null); case "$c" in *r11u469_*|*r11u466_wait*) continue;; esac; echo $p; done | wc -l)
  [ "$n" -eq 0 ] && break
  sleep 60
done
echo quiet $(date)
