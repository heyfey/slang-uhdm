# r10uvm115repro/fence115.py — the BUILTIN-CLASS DECLARATION differential
# census for ONE test.  MEASUREMENT ONLY (the official uhdm-cmp and
# scripts/verify_golden.py are the judges).  LHS is ALWAYS golden (Surelog);
# RHS is ALWAYS ours.
#
#   python3 fence115.py <golden.tsv> <ours.tsv> <mode> <test>
#
# Reads two ct115cen censuses and prints one row per DECLARATION CELL whose
# (variable kind, parent kind, typespec kind, typespec name, typespec instance,
# typespec span) payload DIFFERS between the two sides, restricted to the
# family this pass is about: a cell where EITHER side's typespec name is one of
# the `std` builtin classes, or either side's declared object is a `ref_var`
# over an `unsupported_typespec`, or a `class_var` over a `class_typespec`
# whose name is a builtin.  Nothing is deduplicated away: the join is a
# MULTISET join (Counter), because two declarations can share a key.
#
# The key is what BOTH producers can spell: SITE, VIEW, OOB, CLS, OWNER and the
# declared object's own LINE:COL span.  Never the file (our objects carry an
# EMPTY VpiFile) and never the name alone (a key that reads a name cannot see a
# rename).
#
# Row: <CLASS>\t<mode>\t<test>\t<key...>\tG=<payload>\tO=<payload>
#   CLASS = FAMILY   golden holds the placeholder shape and we do not
#           MIRROR   we hold it and golden does not (a WIDENING; must stay 0)
#           OTHERDIF any other difference inside the family's cells
import sys, collections

BUILTIN = {"process", "semaphore", "mailbox"}
UNS = "unsupported_typespec"
CTS = "class_typespec"


def is_builtin_name(n):
    return n in BUILTIN or n.startswith("std::")


def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] in ("TP", "CALL"):
            continue
        # key: SITE VIEW OOB CLS OWNER LC     payload: NM VK PK TSK TSN TSI TSLC
        d[tuple(f[1:7])][tuple(f[7:14])] += 1
    return d


def interesting(pg, po):
    for p in (pg, po):
        if p is None:
            continue
        nm, vk, pk, tsk, tsn, tsi, tslc = p
        if is_builtin_name(tsn):
            return True
    return False


def main():
    G = load(sys.argv[1])
    O = load(sys.argv[2])
    mode, test = sys.argv[3], sys.argv[4]
    for k in sorted(set(G) | set(O)):
        gc = G.get(k, collections.Counter())
        oc = O.get(k, collections.Counter())
        inter = gc & oc
        gonly = list((gc - inter).elements())
        oonly = list((oc - inter).elements())
        if not gonly and not oonly:
            continue
        # face-match by the declared NAME so a cell pairs with its own twin
        byname = collections.defaultdict(list)
        for p in oonly:
            byname[p[0]].append(p)
        for pg in gonly:
            po = byname[pg[0]].pop(0) if byname[pg[0]] else None
            if not interesting(pg, po):
                continue
            if pg[3] == UNS and (po is None or po[3] != UNS):
                cls = "FAMILY"
            elif po is not None and po[3] == UNS and pg[3] != UNS:
                cls = "MIRROR"
            else:
                cls = "OTHERDIF"
            print("%s\t%s\t%s\t%s\tG=%s\tO=%s"
                  % (cls, mode, test, "\t".join(k), "|".join(pg),
                     "|".join(po) if po else "<none>"))
        for rest in byname.values():
            for po in rest:
                if not interesting(None, po):
                    continue
                cls = "MIRROR" if po[3] == UNS else "OTHERDIF"
                print("%s\t%s\t%s\t%s\tG=<none>\tO=%s"
                      % (cls, mode, test, "\t".join(k), "|".join(po)))


main()
