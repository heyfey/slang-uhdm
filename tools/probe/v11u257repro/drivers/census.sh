#!/bin/bash
# v11u257 census.sh <workroot>: r11u257's tracecensus.sh with the FIX binary (the law's traces plus the two
# refinements' traces ifacePortHcConnOrder257v and genLpFoldAddOperandKinds257v), fence-filtered by the harness.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
bash $R257_D/tracecensus.sh $B/fix $1
