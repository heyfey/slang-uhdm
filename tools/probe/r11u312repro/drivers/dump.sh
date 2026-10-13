# (r11u312: copied from r11u310repro/drivers, renamed to R11U312 / r11u312)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
#!/bin/bash
# (r11u308: copied from r11u300repro/drivers, renamed to R11U308 / r11u308)
# r11u286 dump.sh <db.uhdm>: uhdm-dump through a guarded variable (never executes a database).
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$UHDM_DUMP" ] || { echo "dump.sh: UHDM_DUMP not executable" >&2; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo "dump.sh: fenced path refused" >&2; exit 2; }; done
exec "$UHDM_DUMP" "$1"
