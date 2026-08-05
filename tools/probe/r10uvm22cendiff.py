# r10uvm22cendiff.py <censusdir> [topN] — rank the FOREACH LOOP-VARIABLE
# disagreements between golden and us over the UVM-4, one row per
# (golden shape, our shape) class.  `O[<missing>]` means the whole VIEW is
# absent on our side (the view-multiplicity law, § classInheritsContainerImports22),
# not a loop-variable bug — the totals line splits the two.
import sys, re, collections

TESTS = ["BuildUVMPkg", "Scoreboard", "SeqDriver", "SimpleUVM"]
LINE = re.compile(r"^(\S+) (\S+) @(\d+:\d+) lv '([^']*)' (\S+) (\S+)   over (.*)$")


def load(path):
    d = collections.Counter()
    try:
        f = open(path)
    except OSError:
        return d
    for line in f:
        m = LINE.match(line.rstrip("\n"))
        if not m:
            continue
        test, view, loc, lvn, kind, ts, over = m.groups()
        d[((test, view, loc, lvn), kind, ts)] += 1
    return d


def main():
    cdir = sys.argv[1] if len(sys.argv) > 1 else "/tmp/r10uvm22cen"
    top = int(sys.argv[2]) if len(sys.argv) > 2 else 40
    G, O = collections.Counter(), collections.Counter()
    for t in TESTS:
        G.update(load(f"{cdir}/cen_g_{t}.txt"))
        O.update(load(f"{cdir}/cen_o_{t}.txt"))
    gk = collections.defaultdict(collections.Counter)
    ok = collections.defaultdict(collections.Counter)
    for (key, kind, ts), n in G.items():
        gk[key][(kind, ts)] += n
    for (key, kind, ts), n in O.items():
        ok[key][(kind, ts)] += n
    rows, detail = collections.Counter(), collections.defaultdict(list)
    for key in set(gk) | set(ok):
        g = gk.get(key, collections.Counter())
        o = ok.get(key, collections.Counter())
        if g == o:
            continue
        gs = " ".join(f"{k[0]} {k[1]}x{v}" for k, v in sorted(g.items()))
        os_ = " ".join(f"{k[0]} {k[1]}x{v}" for k, v in sorted(o.items()))
        lab = f"G[{gs or '<missing>'}] O[{os_ or '<missing>'}]"
        rows[lab] += max(sum(g.values()), sum(o.values()))
        detail[lab].append(key)
    for lab, n in rows.most_common(top):
        ex = detail[lab][0]
        print(f"{n:6d}  {lab}   e.g. {ex[0]} {ex[1]} {ex[2]} '{ex[3]}'")
    miss = sum(n for lab, n in rows.items() if "O[<missing>]" in lab)
    real = sum(rows.values()) - miss
    print(f"TOTAL {miss + real}  view-multiplicity {miss}  loop-variable {real}")


main()
