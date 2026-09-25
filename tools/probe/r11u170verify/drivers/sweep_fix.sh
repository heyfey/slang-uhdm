#!/bin/bash
# The gate sweep of the fix binary (all four stages), after the type-parameter sweeps.
until [ -f /tmp/r11u170_sweeps_tp.done ]; do sleep 20; done
/tmp/wt_r11u170/tools/probe/r11u170verify/drivers/sweep.sh /tmp/r11u170_bin/fix.bin /tmp/r11u170_swF
echo done > /tmp/r11u170_swF.done
