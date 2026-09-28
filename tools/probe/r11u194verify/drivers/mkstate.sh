#!/bin/bash
# (r11u194: adapted from r11u190verify/drivers/mkstate.sh) mkstate.sh <name> <ENV=VAL>...: a frozen wrapper
# $R194_BIN/<name>.sh that runs law.bin (706ab521) under the given switches (the state binaries of the composition
# sweeps).  chmod 555.
source "$(dirname "$0")/env.sh" || exit 2
n=$1; shift; f=$R194_BIN/$n.sh
printf '#!/bin/bash\nexec env %s %s/law.bin "$@"\n' "$*" "$R194_BIN" > $f; chmod 555 $f; echo "$f: $(tail -1 $f)"
