# vladder1 — ADVERSARIAL VERIFICATION of r10ladder1

**MEASUREMENT-ONLY.**  Nothing here is an acceptance judge; the official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) remains the sole authority
for `CMP_EQUAL` / `CMP_NOTEQUAL`.  No production emitter code was touched.

This file records what an independent rebuild of `ctladder` reproduced, what it
broke, and what was fixed.  Everything below was re-measured by the verifier;
nothing is carried over on the implementer's word.

---

## 0. WHAT REPRODUCED, EXACTLY

The control workdir the pass was told to read (`/tmp/ctl_wd_sl_d853e76`) no
longer exists, and neither does its successor `115082d`.  Two independent
reproductions were therefore taken.

**(a) Against the surviving control workdir `/tmp/ctl_wd_sl_0424f46`.**  The
verifier rebuilt `ctladder` from the patch with the build line in its own
header, and ran all 10 fast rows.  Every ladder is **byte-identical to the
shipped artifact** (which was measured on base `115082d`) apart from the
`budget=` echo in the header line:

```
ladder_default_BuildUVMPkg.txt   difflines=2 (budget=1500s vs 1800s)
ladder_default_Rggen.txt         difflines=2
ladder_default_Scoreboard.txt    difflines=2
ladder_default_SeqDriver.txt     difflines=2
ladder_default_SimpleUVM.txt     difflines=2
ladder_default_YosysVerx.txt     difflines=2
ladder_testflags_BuildUVMPkg.txt difflines=2
ladder_testflags_SeqDriver.txt   difflines=2
ladder_testflags_SimpleUVM.txt   difflines=2
ladder_testflags_YosysVerx.txt   difflines=2
```

Scoreboard reproduced **exactly**, with no like-for-like variant needed.

**(b) Against a workdir the verifier BUILT AT THE MANDATED BASE `d853e76`.**
`slang-uhdm` was configured and built at `d853e76` in a fresh worktree and
`verify_golden.py --mode default` was re-run for the seven tests; the four
`base_d853e76/` ladders reproduce their rung counts exactly (60 / 48 / 77 / 92)
and differ in **one field of one rung** each — `masklvl` on the
`package|<rhs-null>|MISSING-OURS` rung, with the same chosen mask and the same
`[S]` line apart from `escalated` moving by 1.  That single field is our-side
database dependent (the candidate list is filtered by `onWalk`, which reads
`m_visited` from a walk over OUR database) and is the only observed sensitivity
to a rebuild of the emitter.

Conclusion: **the shipped ladders are real and reproducible.**  The defects
found below are in what the ladders MEAN, not in whether they can be re-taken.

---

## 1. THE GATES, RE-RUN BY THE VERIFIER

| gate | scope demanded | result |
|---|---|---|
| 1 build | official UHDM install, header build line | **PASS** — builds clean, links `~/.local/lib64/libuhdm`, calls the official `design::Compare` |
| 2 calibration | golden-vs-golden = 0 heads on **every** row, not 3 | **PASS 11/11** (`calib11`): SeqDriver 317 210 objs, SimpleUVM 188 084, Scoreboard 187 081, BuildUVMPkg 183 142, Earlgrey 783 183, SeqDriver-tf 317 222, SimpleUVM-tf 188 096, BuildUVMPkg-tf 183 142, YosysVerx d/tf 24 205, Rggen 252 296 — **0 rungs each** |
| 3 head-1 | must equal `rowheads.sh`'s head on all 11 | **PASS 11/11**, byte-identical stderr including 38 802 397 bytes of decompile on SeqDriver.  `rowheads.sh` uses `~/.local/bin/uhdm-cmp` and `rowsanity.sh` uses `~/git-repos/UHDM/build/bin/uhdm-cmp`; the two files are the **same binary** (`md5 2ad8015175758e918de1789b86ef1ea5`), so gate 3 *is* head-1 equivalence with `rowheads.sh` |
| 4 determinism | 2 runs per row | **PASS 10/10** fast rows IDENTICAL. **FAIL on Earlgrey by construction** — see §5 |
| 5 report | complete | **CONDITIONAL** — three factual errors, corrected in §2 |

---

## 2. FACTUAL ERRORS IN THE PASS REPORT AND IN `LEDGER.md`

**E1 — "6 rows" for the parameter-fold family.**  The report and `LEDGER.md`
§3.2 / §4 both give `constant|VpiType|KIND:constant>ref_obj` as **6 rows,
1 289 entries** and rank it #2.  The tool's own generated `CLUSTERS.md` puts it
at **rank 39, 2 rows** (`default_Earlgrey_0_1` 1 263 + `default_Rggen` 26), and
a fresh re-run reproduces 2.  Adding every appendix and `base_d853e76` ladder
still only reaches 3 distinct tests.  **The figure is unsupported anywhere in
the artifacts.**

**E2 — the report's "TOP FAMILIES ... ranked rows-then-entries" is not that
ranking.**  By the stated policy the artifact's rank 1 is
`constant|VpiType|KIND:constant>operation` (9 rows / 27), rank 2 is
`ref_typespec|<rhs-null>|MISSING-OURS` (8 / 1460).  The report's #2 is rank 39
and its #3 (`int_typespec>integer_typespec`, 236) is **rank 63 and one row**.
The report's list is an entries-weighted list dominated by a single row, and
1 441 of the 1 460 `ref_typespec` entries are Earlgrey alone — the other seven
rows contribute **19 between them**.

**E3 — `function|<rhs-null>|MISSING-OURS` is not "whole subroutines golden
emits and we do not".**  Verified independently against `uhdm-dump` on
`default/BuildUVMPkg`: ours **does** emit `function(get_result)` at
`uvm_pkg.sv:20992:3`, at the same span.  What is missing is the link:

```
GOLDEN  \_func_call: (get_result), line:21532:9        OURS  \_func_call: (get_result), line:21532:9
          |vpiName:get_result                                  |vpiName:get_result
          |vpiFunction:                                        (nothing)
          \_function: (…::get_result), line:20992:3
```

44 of the 45 cells in that family mask a `func_call`, i.e. the defect is
`func_call.vpiFunction == nullptr`.  The family name names the victim; `KINDP`
names the victim's `vpiParent` (`class_defn`) — **both point away from the
defect**, which lives on the referrer.  Same shape confirmed for
`io_decl|<rhs-null>|MISSING-OURS`: golden's `ref_obj(lhs)@23233:20` carries
`|vpiActual: \_io_decl(lhs)@23219:62`, ours carries none.

**Correct in the report, re-verified here:** the `comparescope.sh` law.
`VpiFullName`, `VpiFile`, `VpiLineNo`, `VpiColumnNo`, `VpiEndLineNo`,
`VpiEndColumnNo` appear **0** times in 463 generated `Compare` bodies, and
`generated/src/BaseClass.cpp` — which every kind inherits and which the scan
does cover — compares only `VpiType`, `VpiName`, `VpiDefName`.  The law holds.
`FIELD=VpiFullName`, `FIELD=VpiAutomatic` and `FIELD=Instance` are 0 across all
11 ladders; `FIELD=VpiDecompile` is 89, and only `expr::Compare` and
`enum_const::Compare` read it, so the decompile families are real CMP causes on
expressions and enum constants specifically.

---

## 3. THE INSTRUMENT DEFECT: BISECTION MASKED THE WHOLE UVM LIBRARY

`README.md` §1.2 states that the tool "actively prefers the **smallest** mask …
masking golden's `uvm_pkg` moves the head *and* hides the entire UVM library".
The preference is implemented only for the **named-candidate** path.  The
**bisection fallback** minimises the CARDINALITY of the mask set and has no
volume preference whatsoever — and it is the path that chose `uvm_pkg`:

| row | rung at which golden's whole `package(uvm_pkg)` was masked | of |
|---|---:|---:|
| default/BuildUVMPkg | 9 | 89 |
| testflags/BuildUVMPkg | 9 | 89 |
| default/SimpleUVM | 13 | 47 |
| default/Scoreboard | 13 | 76 |
| default/SeqDriver | 39 | 59 |

plus dozens of whole-`class_defn` masks (`uvm_object`, `uvm_component`,
`uvm_phase`, `uvm_root`, `uvm_comparer`, `uvm_report_object`, …), most of them
`[bisected]`.

### 3.1 measured consequence

Two defect classes were counted **independently of the instrument**, from
`uhdm-dump` of both databases, keyed on source span so that naming residues
cannot confound the count:

| row | class | real defect sites | sites the ladder names | coverage |
|---|---|---:|---:|---:|
| default/BuildUVMPkg | `func_call.vpiFunction` missing in ours | 41 | 25 | **61 %** |
| default/BuildUVMPkg | `ref_obj.vpiActual` missing in ours | 115 | 9 | **8 %** |
| default/SeqDriver | `func_call.vpiFunction` missing in ours | 16 | 6 | **38 %** |
| default/SeqDriver | `ref_obj.vpiActual` missing in ours | 467 | 5 | **1 %** |

Every site the ladder DID name is real (0 false positives in 41+16 checked
sites, and 3 mid-ladder cells per row opened by hand against the dumps).  The
missing ones are inside a masked subtree — `get_show_max@21451:13`,
`get_result@21451:49` and 15 others in BuildUVMPkg are all under the `uvm_pkg`
mask taken at rung 9.

Re-measured on `default/BuildUVMPkg` after the fix of §3.3, both tools reading
the SAME pinned pair:

| class | sites | shipped tool | fixed tool |
|---|---:|---:|---:|
| `func_call.vpiFunction` | 41 | 25 (61 %) | **28 (68 %)** |
| `ref_obj.vpiActual` | 115 | 9 (8 %) | **17 (15 %)** |

More is found, and it is still far from a census — which is the point of
publishing the coverage number at all.  **No pass should ever quote a ladder
length as "the number of defects left in this row."**

### 3.2 the cascade rule, stated exactly

Every generated `<kind>::Compare` opens with
`if (!context->m_visited.insert(this).second) return 0;`, keyed on the **LHS**.
Seeding `m_visited` with a golden object `M` therefore makes **every later
`SafeCompare(M, x)` return 0 without descending**.  What becomes invisible is
not "M's `vpiParent` subtree" — it is *every disagreement whose failing
`SafeCompare` is only reached through `M` on the walk*.  An object that is also
reachable by an edge outside `M` is still compared, which is why rungs continue
after `uvm_pkg` is masked; but everything reached only via that package is gone.
`README.md` §1.2 says "skips its entire subtree", and a reader who takes
"subtree" to mean the `PL`/`KINDP` parent chain printed on the rung will
mis-read it.

### 3.3 the fix, and what it costs

`ctladder.cpp` now runs bisection over the pool with **mega-objects removed**
(subtree >= 1 % of the golden database) and only re-admits them, marked
`CASCADE=forced`, if nothing smaller moves the head.  Masking is monotone, so a
restricted pool can never yield a wrong mask — only fewer of them.  Every rung
now prints its mask's **true** volume (the old `masked=` was capped at 4 000, so
a 4 000-object mask and a 180 000-object mask printed the same number) and every
row prints `suppressed=` — the union of all masked subtrees.

Both columns measured on the SAME pinned workdir at the SAME base `d853e76`:

| row | rungs, shipped | rungs, cascade-averse | deepest walk, shipped | deepest walk, fixed | secs |
|---|---:|---:|---:|---:|---:|
| default/SeqDriver | 60 | **396** | 16 088 | 15 879 | 3.5 -> 138 |
| testflags/SeqDriver | 60 | **525** | 16 100 | 26 295 | 3.5 -> 281 |
| default/SimpleUVM | 48 | **398** | 15 403 | 40 555 | 2.4 -> 188 |
| testflags/SimpleUVM | 48 | **398** | 15 415 | 40 567 | 2.6 -> 186 |
| default/Scoreboard | 77 | **403** | 22 668 | 43 381 | 3.0 -> 244 |
| default/BuildUVMPkg | 92 | **273** | 18 936 | 42 931 | 3.0 -> 209 |
| testflags/BuildUVMPkg | 92 | **273** | 18 936 | 42 931 | 2.9 -> 202 |
| default/Rggen | 98 | 98 | 94 688 | 94 688 | 7.1 -> 9.6 |
| default/YosysVerx | 1 | 1 | 24 205 | 24 205 | 0.2 -> 0.2 |
| testflags/YosysVerx | 1 | 1 | 24 205 | 24 205 | 0.2 -> 0.2 |
| default/Earlgrey_0_1 | 3 215 (budget) | 3 202 (budget) | 471 011 | — | 1500 -> 1500 |

The three rows that do not move are exactly the three that never entered the
bisection fallback (`COST.txt`: Rggen and YosysVerx have `BISECT 0`; Earlgrey has
`BISECT 0` too — its blindness has a different cause, §3.4).

**The shipped instrument under-reports by 3-8x on the UVM rows**, and the family
ranking that was to become the campaign's queue was computed from a 12-25 %
sample of the reachable heads, biased toward whatever happens to lie before the
first mega-mask.  That is the finding that matters most in this pass.

It does **not** make the ladder a defect census.  `suppressed=` is
316 770/317 210 on SeqDriver, 187 799/188 084 on SimpleUVM, 182 799/183 142 on
BuildUVMPkg.  `suppressed` is the union of the sets **reachable** from every
masked object and is therefore an **upper** bound on the blindness (an object
reachable from a mask can still be compared through another edge — that is
exactly why rungs continue after a whole package is masked); `maxvis` is the
matching **lower** bound on what was proven equal.  Read ladder length as *a
lower bound produced by a biased sample of the head path*, and read the family
table as *what that sample says about relative frequency*.

### 3.4 the SECOND cascade defect, found by the uncapped `masked=` — NOT fixed

The named-candidate path sorts its tail by `subtreeSize(cand, 512)`.  **The key
is capped at 512**, so every candidate larger than 512 ties, and `stable_sort`
then picks by insertion order — the "smallest mask wins" rule is blind above
512 objects.  With the cap on `masked=` lifted this is now visible in the
artifacts: `default/Earlgrey_0_1` rung 90 takes `masklvl=0` — the *first* and
supposedly smallest candidate — and that mask reaches **638 600 of 783 183**
golden objects (82 %).  The shipped artifact printed `masked=4000` for the same
rung, so the reader could not see it at all.

The fix is to widen the sort key (or make it two-tier: capped-at-1 % first,
capped-at-512 second).  It is **not applied here** — it costs a
`subtreeSize` walk per candidate per rung on an 783 k-object database and needs
its own re-measurement pass.  It is the next thing to do to this instrument, and
it is why `default/Earlgrey_0_1` is the one row whose ladder this verification
did **not** materially improve.

---

## 4. THE FAMILY KEY: WHAT IT SPLITS AND WHAT IT MERGES

**It SPLITS one emitter law across four ranks.**  `SHAPE` embeds the literal
text of a value difference, so the same law lands in as many families as it has
spellings:

* `ref_obj|VpiName|O-EXTRA-SUFFIX([original_type])` (6)
* `ref_obj|VpiName|O-EXTRA-SUFFIX([rtype])` (3)
* `ref_obj|VpiName|O-EXTRA-SUFFIX([original_type_name])` (3)
* `ref_obj|VpiName|O-EXTRA-SUFFIX([obj])` (3)

— one law ("we bake the select expression into the `ref_obj` name; golden keeps
the base name", e.g. golden `m_inst_override_queues` vs ours
`m_inst_override_queues[rtype]`, verified in the dump), 15 entries, four ranks,
each below the visibility threshold.  The `hier_path|VpiName|TEXT:…` group does
the same with 66 entries across four families.

**It MERGES three different contexts under one name.**
`ref_typespec|<rhs-null>|MISSING-OURS` is described as "golden hangs a
`ref_typespec` off every `hier_path`".  Over the fast rows its referrer contexts
are `hier_path` 32, `ref_obj` 15, `bit_typespec` 4 — 63 %, not "every".  The
discriminator that decides where the fix goes (the referrer kind) is not in the
key at all; it is only recoverable from the `MK` line.

**FIXED:** `cluster.py` now emits a third key, `FAM3`, which strips the literal
out of the shape and keys null-sided heads on the **masked referrer's kind**
(`func_call -> function|MISSING-OURS`), and ranks by rows then **distinct
objects** rather than rungs.

**A trap for anyone deduplicating the artifacts:** `ident()` was **not
injective**.  `constant@:0:0-0:0` is the printed name of hundreds of distinct
objects, so deduplicating Rggen's 98 rungs by printed string gives 23 and looks
like a 4x over-count; by `UhdmId` it is 98 — every rung masked a different
object (`masks=98`).  `ident()` now carries `#UhdmId`, which is what makes the
distinct-object column trustworthy.  With it, the genuine repeat rate is
measured: BuildUVMPkg 89 rungs / 68 distinct pairs / 59 distinct golden objects;
SimpleUVM 47 / 40 / 33 (one extra `string_var(s_connection_warning_id)#3804`
alone accounts for 7 rungs).

---

## 5. DETERMINISM, AND THE EARLGREY NUMBER

Gate 4 passes 10/10 on the fast rows.  **`default/Earlgrey_0_1` is not
deterministic and cannot be**, because its stop condition is a wall clock:
`stop=BUDGET`.  The shipped artifact reports 3 215 rungs at `budget=1500s`; the
verifier's re-run at the same budget on the same golden reached **3 017**.  The
shipped `GATES.txt` bounded Earlgrey's determinism check to 200 rungs, which
tests the tool but not the published number.

**`3 215` is therefore not a measurement of Earlgrey, it is a measurement of
1 500 seconds of one machine.**  It should be quoted as `>= N, budget-truncated`
and never compared across passes or machines.  Every other row's stop is
`FIXPOINT`, `ROOT-BLOCKED` or `UNMASKABLE`, all of which are machine-independent.

---

## 6. COST — CONFIRMED

`cost.sh` infers the compare count from `masklvl` and the `BI` lines.  The
verifier built a variant with a counter around every `dg->Compare(dobj, …)` and
compared:

| row | cost.sh | TRUE compare calls |
|---|---:|---:|
| default/SeqDriver | 404 | **404** |
| default/SimpleUVM | 398 | **397** |
| default/Scoreboard | 468 | **467** |
| default/BuildUVMPkg | 488 | **488** |
| default/Rggen | 197 | **197** |
| default/YosysVerx | 3 | **3** |

Accurate to +-1 (the off-by-one is the coverage re-walk `cost.sh` always adds,
which a `ROOT-BLOCKED` row never performs).  The per-compare figure is 6-11 ms
on the UVM rows as claimed, but the honest range across the corpus is
**6-203 ms**: Rggen is 34 ms and Earlgrey is 203 ms (`COST.txt` has both; the
pass report quotes only "6-10 ms").  After the cascade-averse fix the compare
count rises roughly 25-60x on the UVM rows.

---

## 6.5 WHAT THE FIXED LADDER FINDS THAT THE SHIPPED ONE COULD NOT

These families were **entirely behind the `uvm_pkg` / `class_defn` cascade masks
and appear nowhere in the shipped `CLUSTERS.md`.**  Two of them are larger than
anything on the shipped queue.

| family | rows | rungs | what it is |
|---|---:|---:|---|
| `parameter\|VpiImported\|O-EMPTY` | 7 | **902** | golden sets `vpiImported = "uvm_pkg"` on a parameter imported into a class scope; we leave it empty.  `parameter::Compare` and `type_parameter::Compare` both read `VpiImported`, so it is a real `CMP_NOTEQUAL` cause.  164 rungs per UVM row (246 on `testflags_SeqDriver`) — the single biggest family in the corpus outside Earlgrey, and one property |
| `sys_func_call\|VpiType\|KIND:sys_func_call>constant` | 7 | 170 | golden folds `$bits`/`$clog2`-class system calls to a `constant`; we emit the call.  Same direction as earl52's fold family, different trigger |
| `bit_typespec\|VpiType\|KIND:bit_typespec>int_typespec` | — | 27 (BuildUVMPkg) | typespec-kind selection, sibling of the Earlgrey `int_typespec>integer_typespec` family |
| `constant\|VpiSize\|INT:G<O` | — | 16-20 | constant width |
| `class_var\|VpiAutomatic\|INT:G>O` | 6 | 22 | **refutes a report claim.**  The pass report states "uvm80-R2 (`VpiAutomatic`) … has ZERO ladder entries although the field IS compared".  That was an artifact of the truncated ladders: `FIELD=VpiAutomatic` occurs 22 times across 6 rows once the cascade masks are removed.  `Instance` and `VpiFullName` remain at 0, so those two conclusions stand |

## 7. OPS — THE CONTROL WORKDIR VANISHED A FOURTH TIME

`/tmp/ctl_wd_sl_0424f46` was deleted **mid-run** during this verification and
replaced by `/tmp/ctl_wd_sl_9f45cc0`; a batch of four rows died inside capnp
(`kj/io.c++:348 Bad file descriptor`).  The implementer lost three workdirs the
same way.  The verification therefore does not read the shared control workdir
at all: `slang-uhdm` was **built at the mandated base `d853e76`** and
`verify_golden.py` was re-run into a **private, pinned** workdir
`/tmp/vladder1_wd_PINNED`, whose 22 sha256 sums are recorded in
`INPUTS.vladder1.txt`.  Every number in this file after §0 comes from that one
workdir at that one base.  **Any pass that reads `/tmp/ctl_wd_sl_*` while it
works is measuring a file that may not survive the measurement.**

## 8. THINGS THAT SURVIVED THE ATTACK

* the mask-and-rerun mechanism itself, and the claim that it uses official
  semantics with no UHDM patch;
* calibration on **all 11** rows, not the 3 demanded;
* head-1 equivalence on all 11, byte-for-byte, against the same `uhdm-cmp`
  binary `rowheads.sh` uses;
* `nofield=0` — a field is named for every rung, and the field table is scraped
  from UHDM's own `Compare` bodies rather than invented;
* the `--refute-fast` refutation of the incremental design (`r1=588 r2=0`);
* the `UhdmId`-ordered indices (address order provably does not reach a result);
* the `comparescope.sh` law, which is the pass's most valuable single result and
  is reproducible from UHDM's sources including the base class;
* the cost model, to +-1 compare.
