#!/bin/bash
# mkstate.sh <name> <ENV=VAL>...: a frozen wrapper /tmp/r11u190_bin/<name>.sh that runs law.bin (8e3153a2) under the
# given switches (the state binaries of the composition sweeps).  chmod 555.
n=$1; shift; f=/tmp/r11u190_bin/$n.sh
printf '#!/bin/bash\nexec env %s /tmp/r11u190_bin/law.bin "$@"\n' "$*" > $f; chmod 555 $f; echo "$f: $(tail -1 $f)"
