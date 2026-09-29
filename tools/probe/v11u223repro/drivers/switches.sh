#!/bin/bash
# switches.sh <case dir>: the final binary under each switch of the pass and of this verification, alone, both views.
. "$(dirname "$0")/env.sh" || exit 3
for sw in R11U223_SCALARTDTOK_OFF R11U223_SCALARTDEXP_OFF R11U223_ASSOCREG_OFF R11U223_SIZEDECLINE_OFF R11U223_ADJSIZE_OFF R11V223_SIZEINVALID_OFF R11V223_DETREG_OFF; do
  bash "$(dirname "$0")/grid.sh" "$1" sw_$sw=fix2:$sw=1
done
