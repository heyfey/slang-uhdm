# r10ladder1 — the multi-head comparator

**MEASUREMENT-ONLY.  Nothing in this directory is an acceptance judge.**  The
official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) remains the sole
authority for `CMP_EQUAL` / `CMP_NOTEQUAL` and for every gate in this campaign.
No production emitter code (`src/`, `include/`) is touched by this pass, and the
UHDM installation the gates use is neither modified nor rebuilt.

`uhdm-cmp` stops at the **first** disagreeing object.  After eighty-odd passes
the campaign has therefore only ever seen *one* defect per row and has never
been able to answer the two questions that decide where to spend the next pass:

1. **How many disagreements are left in a row?**
2. **Which defect shapes are shared across rows** — i.e. what should be fixed
   first?

`ctladder` answers both by running the official `design::Compare` repeatedly,
recording the head, masking it, and re-running to fixpoint.

---

## 1. THE MECHANISM

Every generated `<kind>::Compare` opens with

```cpp
if (!context->m_visited.insert(this).second) return r;   // keyed on the LHS
```

so an LHS (golden) object already present in `m_visited` compares **equal
instantly**.  A head can therefore be *suppressed* by seeding `m_visited` with
it, and the comparison continues to whatever would have been next.  This is the
r10sd6 `ct6mask` technique run to a fixpoint instead of once.

Nothing in UHDM is patched.  The walk order, the field order, the failure
points and the `m_failedLhs` / `m_failedRhs` assignments are the shipped ones.

### 1.1 The four failure shapes, and how each is masked

`SafeCompare` (BaseClass.h) writes the head in three different ways, and they
do **not** all respond to seeding:

| shape | how it fires | maskable by seeding? |
|---|---|---|
| (a) property / container mismatch **on** an object | `m_failedLhs = lhs; m_failedRhs = rhs` inside the object's own `Compare` | **yes** — seed that object, `masklvl=0` |
| (b) `SafeCompare(lhs, rhs=nullptr)` | golden has a child, ours has none | **no** — `lhs->Compare` is never called, so seeding `lhs` is INERT |
| (c) `SafeCompare(lhs=nullptr, rhs)` | ours has a child, golden has none | **no** — there is no golden object to seed at all |
| (d) design-level field | the failure is in `design::Compare`'s own body | **never** — masking the root returns 0 for the whole comparison |

For (b) and (c) the object that must be masked is the one that was *mid-Compare*
— the **referrer**, not the tree parent.  `ctladder` therefore keeps a referrer
index of both databases and, crucially, filters candidates by
`ctx.m_visited`: an object the walk never entered cannot be the one that held
the failing `SafeCompare`.  When the heuristic names nothing that works, the
blocker is found by **bisection over the visited set** (§1.3).  Shape (d) is
reported as `ROOT-BLOCKED` and stops the row — it is never silently skipped and
never reported as agreement.

### 1.2 Cascade masking — how to read a ladder length

The short-circuit is at the **top** of `Compare`, so masking an object skips its
**entire subtree**.  A ladder length is therefore the number of *maximal
disagreeing subtree roots on the walk*: a **lower bound** on the defect count,
never an upper one.  Two consequences, both visible in the artifacts:

* each rung prints `masked=` — the number of golden objects under the node that
  was masked — and the row prints `suppressed=` — the UNION of every masked
  subtree, i.e. how much of the golden database the ladder stopped looking at;
* the tool prefers the **smallest** mask that moves the head.  This is
  not cosmetic: masking golden's `uvm_pkg` moves the head *and* hides the entire
  UVM library.  Measured on `default/SimpleUVM`: preferring the failing object
  gave **16 rungs**; adding referrer candidates, the visited-set filter and
  bisection gave **48**.

> **vladder1 correction to the paragraph above.**  The smallest-mask preference
> was applied ONLY to the named-candidate path.  The **bisection fallback had no
> volume preference at all**, and it is the path that masked golden's whole
> `package(uvm_pkg)` — at rung 9 of 89 on `default/BuildUVMPkg`, rung 13 of 47
> on `default/SimpleUVM`, rung 13 of 76 on `default/Scoreboard` and rung 39 of
> 59 on `default/SeqDriver` — i.e. exactly the mask this paragraph claims the
> tool avoids, in 4 of the 11 rows, most of them within the first sixth of the
> ladder.  Bisection is now cascade-averse (§1.3) and the rung counts it had
> been suppressing are **3-8x** the published ones:
>
> | row | rungs, shipped | rungs, cascade-averse |
> |---|---:|---:|
> | default/SeqDriver | 59 | **395** |
> | default/SimpleUVM | 47 | **397** |
> | default/BuildUVMPkg | 89 | **270** |
>
> The cost is 25-60x wall clock, and `suppressed=` still approaches 100% of the
> golden database on every UVM row: even the fixed ladder is a **sample of the
> head path, not a defect census**.  See `VERIFY.md`.

### 1.3 Bisection — the part that is measured rather than guessed

Masking can only turn a sub-result from FAIL to EQUAL, never the other way, so
the first failure can only move **later** as the mask grows.  The predicate
"this mask moves the head" is therefore **monotone in the mask**, and a binary
search over the objects the walk actually entered is sound.  `ctladder` uses it
whenever the named candidates are all inert; it costs ~log2(|visited|)
whole-design compares (`BI n compares` on the rung).  If the narrowing stalls on
two halves that only work *together*, the set is minimised greedily and kept as
a **set** — insisting on a single blocker stopped `SimpleUVM` 26 rungs early.

The pool is ordered by `UhdmId`, **never by address**: address order is not
stable across runs and the ladder must be (gate 4).

### 1.4 The first differing field

Field order is **not invented here**.  `ctfields.inc` is generated by
`genfields.py` from UHDM's own `<kind>::Compare` bodies, with the base class's
fields spliced in at the point `basetype_t::Compare` is called, and each field
carries the vpi selector that reads it back through the public
`GetVpiPropertyValue` / `GetByVpiType` introspection.  The 24 fields UHDM
exposes no selector for (`design::AllPackages` and friends, `instance::Array_nets`,
`for_stmt::VpiForInitStmts`, …) are read by hand-written fallbacks in
`ctladder.cpp` — a dropped field would print "no differing field" for a pair
that differs in exactly that field.

Marks on a field name:

* *(none)* — the field of the head pair itself.
* `^` — the **precise null edge**: a referrer that really holds the target on
  one side and really holds null on the other.
* `~` — weaker: some field of a referrer differs.  Kept as a distinct mark
  instead of being laundered into a clean claim.

---

## 2. FILES

| file | what it is |
|---|---|
| `ctladder.cpp` | the instrument.  Modes: ladder (default), `--calib`, `--head1`, `--refute-fast` |
| `genfields.py` → `ctfields.inc` | per-kind Compare field order + vpi selectors, scraped from the UHDM build's generated sources |
| `genvpinames.sh` → `vpinames.inc` | int→vpi-name multi-map scraped from the installed headers (reference table; the ints in `ctfields.inc` are resolved by `genfields.py`) |
| `rowladders.sh` | run the ladder over named rows of a `verify_golden` workdir |
| `rowsanity.sh` | **gate 3** — rung #1 must be byte-identical to `uhdm-cmp`'s head |
| `detcheck.sh` | **gate 4** — two runs of a row give the same ladder |
| `calib.sh` | **gate 2** — golden-vs-golden must give ZERO rungs |
| `cluster.py` → `CLUSTERS.md` | families, ranked by (rows covered, entries).  The KEY POLICY lives here, not in the tool |
| `gates.sh` → `GATES.txt` | runs gates 1-4 and prints the evidence |
| `cost.sh` | the cost model, recomputed from the ladders instead of estimated |
| `comparescope.sh` | what the judge actually compares — the evidence behind LEDGER §0 |
| `inputs.sh` → `INPUTS.txt` | sha256 of BOTH databases of every row, so a later pass can prove it is looking at the same measurement |
| `LEDGER.md` | the reading: families vs the known residue ledger, and the discoveries |
| `ladder_<mode>_<test>.txt` | the per-row ladders (artifacts) — the 11 NE rows |
| `appendix/ladder_*.txt`, `APPENDIX.md` | the OTHER 8 `CMP_NOTEQUAL` rows of `results/golden_surelog.csv`, laddered the same way and reported separately so they cannot inflate the 11-row ranking |
| `base_d853e76/ladder_*.txt`, `BASE_D853E76.md` | the five ladders taken before the base workdir was deleted (§4.1).  Kept as the cross-base stability measurement, NOT merged into the ranking |
| `INPUTS.txt` / `INPUTS.115082d.txt` / `INPUTS.0424f46.txt` | the input pins for all three control workdirs this pass saw.  The first two now point at files that no longer exist — that is the point of a pin |
| `regate.sh` | re-derives gates 3 and 4 from their SAVED PAIRS, with no workdir |
| **`VERIFY.md`** | **the adversarial verification — read this first.**  What reproduced, the three factual errors in the pass report, the cascade defect that was under-reporting every UVM row by 3-8x, the family-key split/merge, and the coverage measured against `uhdm-dump` independently of the instrument |
| **`CLUSTERS.vladder1.md`** | the regenerated cluster report, single-base at the MANDATED base `d853e76`, from the fixed instrument.  **This supersedes `CLUSTERS.md` as the queue** |
| **`COST.vladder1.txt`**, **`GATES.vladder1.txt`**, **`INPUTS.vladder1.txt`** | cost / gates / sha256 pins for the verified run |
| **`vgates.sh`** | gates 1-4 against a PRIVATE PINNED workdir — the shared control workdir was deleted mid-measurement four times across the two passes |
| `ladder_<mode>_<test>.txt` | **regenerated by the verifier** at `d853e76` with the fixed instrument.  The shipped versions are recoverable from the r10ladder1 patch |

### build

```sh
g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctladder
```

### regenerate the field table (only needed if UHDM changes)

```sh
python3 genfields.py ~/git-repos/UHDM/build/generated/src ~/.local/include/uhdm > ctfields.inc
./genvpinames.sh ~/.local/include/uhdm > vpinames.inc
```

### run

```sh
./rowladders.sh /tmp/ctl_wd_sl_d853e76 out \
    default:SeqDriver default:SimpleUVM default:Scoreboard default:BuildUVMPkg \
    default:Earlgrey_0_1 testflags:SeqDriver testflags:SimpleUVM \
    testflags:BuildUVMPkg default:YosysVerx testflags:YosysVerx default:Rggen
python3 cluster.py out > CLUSTERS.md
```

---

### cost

Measured, not estimated (`cost.sh`).  A ladder is not one aborted compare, it is
hundreds of increasingly deep ones:

| row | rungs | mask trials | bisection | total compares | secs | ms/compare |
|---|---:|---:|---:|---:|---:|---:|
| default/SeqDriver | 59 | 85 | 259 | 404 | 3.7 | 9.2 |
| default/SimpleUVM | 47 | 72 | 278 | 398 | 2.5 | 6.3 |
| default/Scoreboard | 76 | 107 | 284 | 468 | 3.3 | 7.1 |
| default/BuildUVMPkg | 89 | 150 | 248 | 488 | 3.2 | 6.6 |
| default/Rggen | 98 | 98 | 0 | 197 | 6.8 | 34.5 |
| default/YosysVerx | 1 | 1 | 0 | 3 | 0.2 | 66.7 |

≈ **6-10 ms per whole-design Compare** on a 185 k-object database, ≈ 35 ms on
Rggen's 252 k — walks that go far deeper than the ~1.5 ms/compare r10sd4
measured at |m_visited| ≈ 1650, so the old figure does not transfer.  The
per-compare cost tracks the DEPTH the walk reaches, not the database size: the
YosysVerx figure is 67 ms for three compares that each clear the entire golden
database.

Bisection dominates the compare COUNT on the UVM rows and is worth it — it is
what turns a stalled row into 20-40 more rungs — and costs nothing on Earlgrey
and Rggen, where the named candidates always work.

## 3. GATES## 3. GATES

| gate | script | what it proves |
|---|---|---|
| 1 build | the build line above | links the **official** UHDM install, calls the official `Compare` |
| 2 calibration | `calib.sh` | golden-vs-golden (two independent restores of the same file) gives **0 rungs**.  A detector that flags everything is a broken detector |
| 3 sanity | `rowsanity.sh` | `ctladder --head1` output is **byte-identical** to `uhdm-cmp`'s, per row — rung 1 *is* the official head |
| 4 determinism | `detcheck.sh` | two runs of a row give identical ladders (wall-clock field stripped) |
| 5 report | `CLUSTERS.md` + this file | complete |

---

## 4. WHAT WAS REFUTED ALONG THE WAY

**The incremental "fast mode" is WRONG, and it fails in the direction that
flatters the tool.**  The obvious optimisation is to keep one `CompareContext`
and add the mask between rungs.  But `design::Compare` inserts the design itself
into `m_visited` on entry, as does every object on the path down to the failure,
so the *second* call on the same context returns 0 at its first line and the
tool reports `FIXPOINT` for a database it never looked at.  It is kept runnable
as `--refute-fast`:

```
$ ./ctladder <golden> <ours> --refute-fast
[S] REFUTE-FAST r1=588 r2=0 design_in_visited=1 visited=10559 —
    reusing one context makes the SECOND call return 0 without comparing anything
```

Every rung in this instrument uses a **fresh** context seeded with the
accumulated mask only.  This was caught because the first YosysVerx run
reported a one-rung `FIXPOINT`; had it been trusted, this pass would have
reported "the corpus is nearly converged" from an instrument that stopped
looking after one object.

Two smaller refutations, both fixed before the artifacts were produced:

* keeping only the **first** referrer of an object made `design` (which lists
  every module) shadow the real referrer, and YosysVerx came out `ROOT-BLOCKED`
  when a one-object mask cleared it.  The referrer index is a multi-map.
* `fallbackVecPtr` originally dropped null elements, which is exactly the case
  a null-element head lives in.  It is null-preserving, and index identity is
  what lets `Field[i]` be named.

---

## 4.1 THE RUN INCIDENT — the base workdir vanished mid-batch

Half way through the first 11-row batch the control workdir this pass was told
to read (`/tmp/ctl_wd_sl_d853e76`) was **deleted out from under the running
driver** and replaced by a workdir for a NEWER base (`/tmp/ctl_wd_sl_115082d`,
one pass ahead — `d853e76` is an ancestor of `115082d`).  Five rows had already
been laddered; six had not.

This is exactly the failure `rowladders.sh`'s guard exists for.  The six rows
printed **`UNKNOWN-NAME`** and were **COUNTED**
(`-- laddered=5 … UNKNOWN-NAME=6`) instead of quietly producing nothing, so the
loss was visible in the driver's own summary rather than discovered later by a
reader counting artifacts.

And then it happened AGAIN: while the gates were running, `115082d`'s workdir
was pruned too and replaced by `0424f46`.  Three control workdirs in one pass.
The instrument therefore treats a workdir as a **volatile input**: every driver
resolves its golden from the row's own `cmds.txt`, every driver counts what it
could not reach, both `INPUTS.*.txt` pin what was actually read, and both gates
leave their RAW PAIRS on disk so `regate.sh` can re-derive their verdicts with
no workdir at all.

Rather than ship a table that mixes two bases, **every row was re-measured
against the one surviving workdir**, so `CLUSTERS.md` is single-base (`115082d`);
gates 2 and 3 were then re-run against `0424f46` as well, and pass there too.  The five
`d853e76` ladders are kept in `base_d853e76/` (reported separately in
`BASE_D853E76.md`) and are not wasted: they are a free **cross-base stability
measurement** of the instrument itself.

| row | rungs @ `d853e76` | rungs @ `115082d` |
|---|---:|---:|
| default/SeqDriver | 60 | 59 |
| default/SimpleUVM | 48 | 47 |
| default/Scoreboard | 77 | 76 |
| default/BuildUVMPkg | 92 | 89 |

One intervening emitter pass moves a ladder by 1-3 rungs — the resolution the
family ranking should be read at.

## 4.2 THE DETERMINISM GATE EARNED ITS KEEP TWICE

First it reported `DIFFERS` on Earlgrey.  That particular report was **my own
ops error, not a tool defect**: three overlapping `gates.sh` invocations (a
timed-out foreground run, a backgrounded one, and a detached one) were writing
the same output files, and one run's second ladder was truncated by another's
`SIGTERM`.  The lesson is banal and expensive: one gate runner at a time, and a
gate that shares an output directory with a second copy of itself is measuring
the copy.

But chasing it surfaced a **real** defect.  `Serializer::AllObjects()` is
`std::map<const BaseClass*, uint32_t>` — **ordered by ADDRESS**.  Every index in
this tool was being built by iterating it, so the insertion order of the
referrer and twin indices was address-dependent, which made `equal_range` order
address-dependent, which made the CANDIDATE order and therefore the whole ladder
address-dependent.  It had not yet produced a visible difference, which is
precisely why it was worth fixing: the campaign's standing law is that address
order must never reach a result.  Every index is now built in `UhdmId` order,
and all ten fast rows re-verified `IDENTICAL`.

## 5. KNOWN LIMITS (read the numbers with these in hand)

1. **Ladder length is a lower bound.**  Cascade masking (§1.2) hides everything
   inside a masked subtree.
2. **`ROOT-BLOCKED` is a real wall.**  When the failure is in `design::Compare`'s
   own body, no object mask can pass it; those rows' ladders are truncated and
   the per-row table says so.
3. **`maxvis` is the deepest walk, not a monotone progress bar.**  It is the
   largest number of golden objects proven equal in a single official-semantics
   walk during the row; masks that skip subtrees can lower later walks.
4. **Selector collisions.**  A few kinds reuse one vpi int for two fields
   (`module_inst::Module_inst` and `::Modules` are both `vpiModule`).  Such a
   field reads as "both null" and is skipped by the field scan rather than
   mis-reported; the head object and span are unaffected.
5. **The `d853e76` workdir is gone.**  `INPUTS.txt` records what it was and
   `base_d853e76/` keeps the five ladders taken from it; they can never be
   reproduced.  `INPUTS.115082d.txt` pins the 19 rows the current tables were
   actually measured on.
6. **Cross-side joins are trialled, never trusted.**  A tree-position key join
   is only ever used to *propose* a mask or a diagnosis; every mask is accepted
   only after the head is observed to move.
