# v11u319repro: the pins, the binaries and the fence, from r11u319repro/drivers/env.sh. Source it: `. drivers/env.sh`.
# The caller exports B (the frozen binaries: pristine, law, fix, uhdm-strictcmp, strictcmp_x, bindcls) and S (scratch).
V319_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$V319_HERE/../../r11u319repro/drivers/env.sh" || return 1 2>/dev/null || exit 1
export V319_DRV=$V319_HERE R319_DRV=$(cd "$V319_HERE/../../r11u319repro/drivers" && pwd)
