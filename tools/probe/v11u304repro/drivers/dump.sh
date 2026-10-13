# (v11u304: copied from r11u304repro/drivers, scratch renamed to /tmp/v11u304_*)
# (r11u304: copied from r11u302repro/drivers, renamed to R11U304 / r11u304)
#!/bin/bash
# (r11u304: copied from r11u300repro/drivers, renamed to R11U304 / r11u304)
# r11u286 dump.sh <db.uhdm>: uhdm-dump through a guarded variable (never executes a database).
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$UHDM_DUMP" ] || { echo "dump.sh: UHDM_DUMP not executable" >&2; exit 2; }
for n in $FENCED; do echo "$1" | grep -qw "$n" && { echo "dump.sh: fenced path refused" >&2; exit 2; }; done
exec "$UHDM_DUMP" "$1"
