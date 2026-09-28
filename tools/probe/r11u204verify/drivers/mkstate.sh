#!/bin/bash
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: adapted from r11u190verify/drivers/mkstate.sh) mkstate.sh <name> <ENV=VAL>...: a frozen wrapper
# $R204_BIN/<name>.sh that runs law.bin (1454b68c) under the given switches (the state binaries of the composition
# sweeps).  chmod 555.
source "$(dirname "$0")/env.sh" || exit 2
n=$1; shift; f=$R204_BIN/$n.sh
printf '#!/bin/bash\nexec env %s %s/law.bin "$@"\n' "$*" "$R204_BIN" > $f; chmod 555 $f; echo "$f: $(tail -1 $f)"
