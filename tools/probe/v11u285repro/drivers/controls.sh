#!/bin/bash
# v11u285 controls.sh <out> <tools/probe dir>...: every case of the listed repro dirs in both views on pristine and
# law (r11u285repro's controls.sh: path lists filtered by $FENCED before any case is opened). Needs B, S.
D=$(cd "$(dirname "$0")" && pwd); R=$(cd "$D/../../r11u285repro/drivers" && pwd)
. "$R/env.sh" || exit 2
bash $R/controls.sh "$@"
