#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: adapted from r11u190verify/drivers/mkstate.sh) mkstate.sh <name> <ENV=VAL>...: a frozen wrapper
# $R221_BIN/<name>.sh that runs law.bin (baf91896) under the given switches (the state binaries of the composition
# sweeps).  chmod 555.
source "$(dirname "$0")/env.sh" || exit 2
n=$1; shift; f=$R221_BIN/$n.sh
printf '#!/bin/bash\nexec env %s %s/law.bin "$@"\n' "$*" "$R221_BIN" > $f; chmod 555 $f; echo "$f: $(tail -1 $f)"
