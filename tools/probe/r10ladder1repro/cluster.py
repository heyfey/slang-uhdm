#!/usr/bin/env python3
"""r10ladder1/cluster.py — turn the per-row ladders into the campaign's
priority queue.

Reads every ladder_<mode>_<name>.txt in a directory and groups the rungs into
FAMILIES.  ctladder emits KINDL / KINDR / FIELD / SHAPE as separate FACTS and
joins them into a raw key; the KEY POLICY lives HERE, in one place, so that
tuning it can never make the committed artifacts and the report disagree:

    FAM   = <kind key> | <first differing field> | <normalised value shape>
    FAM2  = <kind key> | <first differing field>          (coarser)

    <kind key> = the GOLDEN kind, except where golden has no object at all —
                 those are re-keyed on OURS' kind with a leading '+', because
                 keying them on the literal "<null>" collapses every
                 extra-object defect in the corpus into ONE family and hides
                 the very distinction the campaign needs.

Ranking is by ROWS COVERED first and DISTINCT OBJECT PAIRS second, because a fix
that moves five rows is worth more to a convergence campaign than a fix that
moves fifty rungs of one row.

vladder1 (adversarial verification) added three things this file used to get
wrong, each of which changed the ranking:

  * DISTINCT vs ENTRIES.  A rung is a head, not a defect.  The same golden
    object can be the head of several rungs (one per reference site that holds
    a null), so `entries` over-counts; ranking now uses the number of distinct
    `#UhdmId` pairs and prints both.  Conversely `ident()` used to be
    non-injective, so a reader who deduplicated by the printed string
    UNDER-counted — Rggen's 98 rungs collapse to 23 by string and are 98 by id.

  * FAM3, the NORMALISED family.  `SHAPE` embeds the literal values of a text
    difference, so ONE emitter law is split across as many families as it has
    literal spellings: `ref_obj|VpiName|O-EXTRA-SUFFIX([rtype])`,
    `…([obj])`, `…([original_type])` and `…([original_type_name])` are one law
    in four ranks, each individually below the visibility threshold.  FAM3
    strips the literal and keeps the structure.

  * THE REFERRER IS THE DEFECT.  For a null-sided head the family name reads
    "golden has an X we do not emit", but the object that is actually wrong is
    the REFERRER holding the null — measured: 44 of the 45
    `function|<rhs-null>|MISSING-OURS` cells are really
    `func_call.vpiFunction == nullptr`, and `KINDP` (the vpiParent) says
    `class_defn`, which is the wrong place to look.  FAM3 keys null shapes on
    the masked referrer's kind instead.

HONESTY RULES BAKED IN:
  * every family carries its stop-context: a row that stopped early contributes
    a TRUNCATED ladder and the table says so, so no family is read as complete.
  * entries whose field could only be diagnosed one hop up are marked '^'
    (precise null edge) or '~' (weaker: some field of a referrer differs); the
    report keeps the marks instead of laundering them into a clean claim.
  * a family present in ONE row of ONE mode is labelled as such — the pair
    (default, testflags) of the same test is NOT two independent witnesses.

usage: cluster.py <ladder-dir> [> CLUSTERS.md]
"""
import glob
import os
import re
import sys


def md(x):
    """Escape a family key for a markdown TABLE CELL.  The key's own separator
    is '|', which is also the cell separator: unescaped, every family name broke
    the table into gibberish columns."""
    return str(x).replace("|", "\\|")


def parse(path):
    row = os.path.basename(path)[len("ladder_"):-len(".txt")]
    rungs, summary, meta = [], {}, {}
    cur = None
    for line in open(path, errors="replace"):
        if line.startswith("# "):
            m = re.search(r"golden_objs=(\d+) ours_objs=(\d+)", line)
            if m:
                meta["gobjs"], meta["oobjs"] = int(m.group(1)), int(m.group(2))
        if line.startswith("RUNG\t"):
            f = dict(p.split("=", 1) for p in line.rstrip("\n").split("\t")[2:] if "=" in p)
            f["idx"] = line.split("\t")[1]
            f["row"] = row
            # RECOMPUTED here, identically to ctladder, so ladders produced
            # before and after the key was refined cluster the same way: a
            # head with no golden object is keyed on OURS' kind with a '+'.
            kk = f.get("KINDL", "?")
            if kk == "<null>":
                kk = "+" + f.get("KINDR", "?")
            f["FAM"] = "%s|%s|%s" % (kk, f.get("FIELD", "?"), f.get("SHAPE", "?"))
            f["FAM2"] = "%s|%s" % (kk, f.get("FIELD", "?"))
            f["KK"] = kk
            cur = f
            rungs.append(f)
        elif cur is not None and line.startswith("   "):
            tag = line[3:5].strip()
            if tag in ("L", "R", "G=", "MK", "PL", "PR"):
                cur.setdefault(tag, line[5:].strip() if tag != "G=" else line[3:].strip())
        elif line.startswith("[S] "):
            summary = dict(p.split("=", 1) for p in line[4:].split() if "=" in p)
    for f in rungs:
        f["FAM3"] = fam3(f)
        f["OID"] = (oid(f.get("L")), oid(f.get("R")))
    return row, rungs, summary, meta


def oid(s):
    """The `#UhdmId` of a printed object.  `ident()` alone is NOT injective."""
    if not s or s == "<null>":
        return None
    m = re.search(r"#(\d+)$", s)
    return m.group(1) if m else s


_LIT = re.compile(r"^(G-EXTRA-PREFIX|O-EXTRA-PREFIX|G-EXTRA-SUFFIX|O-EXTRA-SUFFIX)\(.*\)$")


def fam3(f):
    """NORMALISED family: strip the literal text out of the shape, and key the
    null shapes on the REFERRER that actually holds the null rather than on the
    victim object's kind."""
    kk, fld = f.get("KK", "?"), f.get("FIELD", "?")
    shape = f.get("SHAPE", "?")
    if shape.startswith("TEXT:"):
        shape = "TEXT-DIFF"
    elif _LIT.match(shape):
        shape = shape.split("(")[0]
    if fld in ("<rhs-null>", "<lhs-null>"):
        # the referrer is the defect; MK names the object the mask proved was
        # holding the failing edge.  Fall back to the raw shape when the row
        # stopped before a mask was chosen.
        mk = f.get("MK", "")
        mk = re.sub(r"\s*\[.*$", "", mk)
        ref = mk.split("(")[0].split("@")[0].strip() or "?"
        return "%s -> %s|%s" % (ref, kk, shape)
    if fld.startswith("^") or fld.startswith("~"):
        fld = fld[1:]
    return "%s|%s|%s" % (kk, fld, shape)


def main():
    d = sys.argv[1]
    files = sorted(glob.glob(os.path.join(d, "ladder_*.txt")))
    if not files:
        sys.exit("FATAL: no ladder_*.txt in %s" % d)
    rows, allr = [], []
    for f in files:
        row, rungs, summ, meta = parse(f)
        rows.append((row, rungs, summ, meta))
        allr += rungs

    print("# r10ladder1 — CLUSTER REPORT")
    print()
    print("Instrument: `ctladder` (MEASUREMENT-ONLY; the official `uhdm-cmp` "
          "remains the sole acceptance judge).  Every rung below is a real "
          "`design::Compare` head under official semantics — the walk, the "
          "field order and the failure points are UHDM's own.")
    print()
    print("## Per-row ladder length (the first honest 'how far are we')")
    print()
    print("| row | rungs | distinct pairs | stop | deepest walk | cascade masks | SUPPRESSED | secs |")
    print("|---|---:|---:|---|---|---:|---|---:|")
    for row, rungs, s, meta in rows:
        d = len({r["OID"] for r in rungs})
        print("| %s | %s | %d | %s | %s | %s | %s | %s |" %
              (row, s.get("rungs", "?"), d, s.get("stop", "?"), s.get("maxvis", "?"),
               s.get("cascades", "-"), s.get("suppressed", "-"), s.get("secs", "?")))
    print()
    print("`SUPPRESSED` is the union of the sets REACHABLE from every masked object, "
          "over the golden database.  Read it as an UPPER bound on what the masks hid: "
          "an object reachable from a mask may still be compared through another edge "
          "(that is why rungs continue after a whole package is masked).  `maxvis` is "
          "the matching LOWER bound on what was proven equal.  Together they say the "
          "ladder is a SAMPLE OF THE HEAD PATH, not a defect census — on the UVM rows "
          "SUPPRESSED approaches 100%.  `cascade masks` counts rungs whose single mask "
          "reached >=1% of golden.")
    print()
    trunc = [r for r, _, s, _ in rows if s.get("stop") != "FIXPOINT"]
    print("Rows whose ladder is TRUNCATED (stop != FIXPOINT), so their length is a "
          "strict LOWER bound: **%s**" % (", ".join(trunc) if trunc else "none"))
    print()
    print("Every ladder length is a lower bound in a second way as well.  Seeding "
          "`m_visited` with a golden object M makes every later `SafeCompare(M, x)` "
          "return 0 without descending, so every disagreement whose failing "
          "`SafeCompare` is only REACHED THROUGH M on the walk becomes invisible.  "
          "That is not the same as M's `vpiParent` subtree, which is what `PL` and "
          "`KINDP` print: an object reachable by an edge outside M is still compared. "
          "Per-rung `masked=` is the size of the set reachable from that rung's mask.")
    print()

    print("## Per-row family profile (top 5 by entries)")
    print()
    print("| row | rungs | top families |")
    print("|---|---:|---|")
    for row, rungs, s_, meta in rows:
        c = {}
        for r in rungs:
            c[r["FAM"]] = c.get(r["FAM"], 0) + 1
        top = sorted(c.items(), key=lambda kv: -kv[1])[:5]
        print("| %s | %d | %s |" %
              (row, len(rungs), "<br>".join("`%s` x%d" % (md(k), n) for k, n in top) or "-"))
    print()

    for key, title in (("FAM3", "NORMALISED FAMILIES — THE QUEUE "
                                "(referrer -> kind | shape, literals stripped)"),
                       ("FAM", "RAW FAMILIES (kind | field | value shape)"),
                       ("FAM2", "COARSE FAMILIES (kind | field)")):
        fam = {}
        for r in allr:
            k = r.get(key, "?")
            e = fam.setdefault(k, {"n": 0, "rows": set(), "all": [], "oid": set()})
            e["n"] += 1
            e["rows"].add(r["row"])
            e["oid"].add((r["row"], r["OID"]))
            e["all"].append(r)
        # Examples are chosen from DISTINCT ROWS first.  Three cells of the same
        # row would make a five-row family look like a one-row family and is
        # exactly the kind of example set that misleads a reader in a hurry.
        for e in fam.values():
            seen, ex = set(), []
            for r in e["all"]:
                if r["row"] not in seen:
                    seen.add(r["row"])
                    ex.append(r)
                if len(ex) == 3:
                    break
            for r in e["all"]:
                if len(ex) == 3:
                    break
                if r not in ex:
                    ex.append(r)
            e["ex"] = ex
        order = sorted(fam.items(),
                       key=lambda kv: (-len(kv[1]["rows"]), -len(kv[1]["oid"]), -kv[1]["n"], kv[0]))
        print("## %s" % title)
        print()
        print("| rank | rows | distinct objects | rungs | family |")
        print("|---:|---:|---:|---:|---|")
        for i, (k, e) in enumerate(order, 1):
            print("| %d | %d | %d | %d | `%s` |" %
                  (i, len(e["rows"]), len(e["oid"]), e["n"], md(k)))
        print()
        if key != "FAM3":
            continue
        print("### Example cells (up to 3 per family, in rank order)")
        print()
        for i, (k, e) in enumerate(order, 1):
            print("**F%d `%s`** — %d distinct objects / %d rungs in %d row(s): %s" %
                  (i, k, len(e["oid"]), e["n"], len(e["rows"]), ", ".join(sorted(e["rows"]))))
            print()
            for x in e["ex"]:
                print("  - `%s` rung %s  (raw family `%s`)" % (x["row"], x["idx"], x.get("FAM")))
                print("    - L(golden) `%s`" % x.get("L", "-"))
                print("    - R(ours)   `%s`" % x.get("R", "-"))
                print("    - masked    `%s`" % x.get("MK", "-"))
                print("    - %s" % x.get("G=", "-"))
            print()


main()
