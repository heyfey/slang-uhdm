#!/bin/bash
# wait for quiet (no sweep, low load) up to 30 min, then run the full five-stage sweep once on the law binary
q=0; for i in $(seq 1 180); do
  n=$(pgrep -f 'tests/sweep.sh|verify_golden.py|check_probe.py|downstream_uhdm2rtlil.py|check_svtests.py|svtests_matrix.py' | wc -l)
  l=$(cut -d' ' -f1 /proc/loadavg)
  if [ "$n" = 0 ] && awk "BEGIN{exit !($l < 2.0)}"; then q=$((q+1)); else q=0; fi
  [ $q -ge 6 ] && break; sleep 10; done
echo "launch $(date) load=$(cut -d' ' -f1-3 /proc/loadavg) sweepers=$n" > /tmp/v11u413_launch.log
pgrep -af 'tests/sweep.sh|check_svtests.py|svtests_matrix.py' >> /tmp/v11u413_launch.log
bash /tmp/v11u413_drv/sweep.sh /tmp/v11u413_bin/law /tmp/v11u413_law /tmp/v11u413_trace
echo "done $(date)" >> /tmp/v11u413_launch.log
