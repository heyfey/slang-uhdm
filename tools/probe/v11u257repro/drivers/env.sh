# v11u257 (adversarial verification of r11u257): source it. The pins come from the caller (SURELOG, UHDM_CMP,
# UHDM_DUMP exported; B = the frozen binaries' directory holding pristine, law, fix and uhdm-strictcmp; S = the
# scratch root); r11u257repro/drivers/env.sh resolves the repository from its own place, reads $FENCED from
# tools/probe/r11u107repro/canaudit.sh fail-closed and checks every tool with [ -x ].
V257_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$V257_HERE/../../r11u257repro/drivers/env.sh" || { return 1 2>/dev/null || exit 1; }
export V257_D=$V257_HERE R257_D=$(cd "$V257_HERE/../../r11u257repro/drivers" && pwd)
for b in pristine law fix; do [ -x "$B/$b" ] || { echo "env: $B/$b not executable" >&2; return 1 2>/dev/null || exit 1; }; done
