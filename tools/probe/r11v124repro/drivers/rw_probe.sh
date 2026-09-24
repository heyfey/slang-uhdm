#!/bin/bash
# rw_probe.sh rel golden [lawdir]
rel=$1; g=$2; L=${3:-/tmp/v11u124_wdL/probe}; n=$(echo $rel | sed 's#/#__#g').uhdm
echo "$rel $(python3 /tmp/v11u124_drv/pathchk.py $g /tmp/v11u124_wdQ/probe/$n $L/$n | head -9 | tr '\n' ' ')"
