# r10uvm115repro/score115.py — THE DIRECTION SCORE.  MEASUREMENT ONLY; the
# official uhdm-cmp is the judge.  LHS is ALWAYS golden (Surelog).
#
#   python3 score115.py <golden dump> <pristine dump> <patched dump>
#
# Scores ONLY the lines the patch actually MOVED, as a MULTISET count
# comparison against golden — never "does this string appear in golden at all",
# which a generic line like `|vpiActual:` passes for free and which therefore
# manufactures phantom LOSSES.  For every distinct normalised line L:
#
#     gp = golden's count, p = ours pristine, q = ours patched
#     gain(L) = |p - gp| - |q - gp|      > 0 TOWARD golden, < 0 AWAY
#
# Order-blind (counts, not positions) because Scoreboard/default is a ~50/50
# COIN per invocation (RESUME §9) and arena order is not judge-visible.  Object
# ids are stripped (allocation counters, never compared), leading indentation is
# stripped (the same object prints at different depths in the two producers'
# trees), and uhdm-dump's `Restored design` banner — which embeds the DATABASE
# PATH and so differs between any two workdirs — is dropped outright.
#
# BARE MARKER LINES (`|vpiActual:`, `|vpiParent:` — a field name and nothing
# else) carry NO identity: their whole-dump count is dominated by unrelated
# objects, so a correct local change reads as a global "loss".  They are
# counted SEPARATELY and never scored; the identity lines around them
# (`\_ref_var: (…)`, `\_logic_net: (…)`) are what a direction claim rests on,
# and a per-cell census (fence115.sh / ct115cen REF rows) is what settles a
# marker.
import sys, collections, re

ID = re.compile(r", id:\d+")
MARKER = re.compile(r"^\|vpi[A-Za-z_0-9]+:$")


def load(p):
    c = collections.Counter()
    for ln in open(p, errors="replace"):
        ln = ID.sub("", ln.rstrip("\n")).strip()
        if ln.endswith("Restored design Pre-Elab:") or \
           ln.endswith("Restored design Post-Elab:"):
            continue
        c[ln] += 1
    return c


def main():
    G = load(sys.argv[1])
    P = load(sys.argv[2])
    Q = load(sys.argv[3])
    toward = awayc = 0
    away = collections.Counter()
    moved = 0
    marker = 0
    for ln in set(P) | set(Q):
        p, q = P[ln], Q[ln]
        if p == q:
            continue
        if MARKER.match(ln):
            marker += abs(q - p)
            continue
        moved += abs(q - p)
        gain = abs(p - G[ln]) - abs(q - G[ln])
        if gain > 0:
            toward += gain
        elif gain < 0:
            awayc += -gain
            away[ln] += -gain
    print("IDENTITY LINES MOVED %5d" % moved)
    print("bare marker lines moved (unscorable) %5d" % marker)
    print("TOWARD GOLDEN   %5d" % toward)
    print("AWAY   GOLDEN   %5d" % awayc)
    for ln, n in away.most_common(30):
        print("  AWAY x%d  %s" % (n, ln[:160]))


main()
