#!/bin/bash
c=$1
p=$(/tmp/v11u168_case.sh $c /tmp/v11u168_bin/pris.bin pris)
l=$(/tmp/v11u168_case.sh $c /tmp/v11u168_bin/law.bin law)
echo "$p ||| $l"
