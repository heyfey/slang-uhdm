# r10svs15 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PASS.** Every number the implementer reported reproduces, from an
independent build, on independently-run sweeps, with an independently-built
pristine control. `SVSwitch` **CONVERTS in BOTH MODES**. Zero regressions were
found anywhere I looked, including in two arms of my own on **ten shapes the pass
never measured**, one of which (`v2`) settles a question the pass's own §6.8 left
open. Four findings are recorded below; **none of them touches a measured number
and none blocks landing** — three are documentation/instrument hygiene and one is
the missing `README.verifier.md` this file supplies.

This report is about, and only about:

| | md5 | base | tree |
|---|---|---|---|
| **shipped** | `f1a2249bc847024b1bb06232ffd8bc79` | `a27a8746a82b6e74c90a1992f1694da2cfcb8f12` | `/tmp/wt_r10svs15v` (a27a874 + `/tmp/r10svs15.patch`) |
| **pristine** | `fe6962c25b01f8e48387b1ec2dcde8ee` | `a27a8746a82b6e74c90a1992f1694da2cfcb8f12` | `/tmp/wt_r10svs15vpris` (`git status --porcelain` EMPTY) |

Patch verified: `/tmp/r10svs15.patch`, md5 `20ad863c4a1339660a8ca423f5231f32`.

**I applied the patch to a FRESH `a27a874`** — stated, as the brief requires —
and *additionally* to the **current head `49475c9`** (§7), because that is where
it will actually land.

---

## 0. THE ONE RESULT THAT MATTERS MOST

**I built both binaries myself, from my own worktrees, with my own cmake
configure — and got the implementer's md5s BYTE FOR BYTE.**

```
md5sum /tmp/wt_r10svs15v/build/slang-uhdm       -> f1a2249bc847024b1bb06232ffd8bc79
md5sum /tmp/wt_r10svs15vpris/build/slang-uhdm   -> fe6962c25b01f8e48387b1ec2dcde8ee
```

Asserted in **separate commands**, both 32-hex. This does more than tick GATE 1:
it closes §5.1's "one late comment-only edit after gating" question **completely
and without relying on the implementer's own assertion**. The patch as delivered,
applied to a clean `a27a874`, produces exactly the binary every number in the
implementer's README was measured on. There is no stale-binary hole left to
argue about.

---

## 1. CONVERSION — ROWS QUOTED FROM THE COMMITTED BASELINE FIRST

`results/*.csv` is READ-ONLY and was **not touched** (`git status --porcelain
results/` EMPTY in my worktree and in the repo). The MASTER promotes.

```
committed results/golden_surelog.csv                   BEFORE
  SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,

my PRISTINE sweep (fe6962c2…)                          CONTROL
  SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,

my SHIPPED sweep (f1a2249b…)                           AFTER
  SVSwitch,default,CMP_EQUAL,,,differ
  SVSwitch,testflags,CMP_EQUAL,,,differ
```

**A control the implementer did not have.** My *pristine* surelog sweep is
byte-identical to the committed baseline across **all 1588 rows**
(`ct8rows.sh results/golden_surelog.csv /tmp/r10svs15v_sl_pris.csv` →
`0 differing ROWS`). So the two moved rows are attributable to the patch and to
nothing else — not to my harness, not to my machine, not to sweep noise. The
same holds on `uhdm2rtlil` (`0 differing ROWS` on 731).

The head, reproduced on the witness through the harness itself (`svsgen.sh`):

| | pristine | shipped |
|---|---|---|
| `uhdm-cmp` rc | **255** | **0** |
| HEAD DEPTH | **31** | **0** |
| heads | **1** | **0** |
| our dump lines | 25700 | 25706 |
| our db bytes | 247203 | 247237 (**+34**) |
| `diff -u` content ± | 1346 | 1340 |

Both modes, identically. The two modes' shipped databases are **byte-identical**
(`cmp -s` → identical; `md5 de7ab46e3f2e…`), so `module_inst::Compare` on
`work@top` returning 0 is one fact, not two.

---

## 2. THE FIVE GATES, RE-RUN INDEPENDENTLY

Read in the **CONVERSION** world — **said first**, because `SVSwitch` moved.

### GATE 1 — build, base, marker
* Both binaries built from **absolute paths**; link line **waited for and
  counted**: `Linking CXX executable slang-uhdm` = **1** in each log; `error:`
  = **0** in each.
* md5s asserted in separate commands, both 32-hex (§0).
* `git rev-parse HEAD` printed and grep-checked on **every** binary's tree:
  both `a27a8746a82b6e74c90a1992f1694da2cfcb8f12`. Pristine tree
  `git status --porcelain` **EMPTY**; shipped tree exactly the three production
  files + the untracked repro dir.
* Symbol: `drainCbElabRefs15` pristine **0**, shipped **1**.
* `basemark.sh`, two-directional with three controls, run on **both** binaries:

```
                                                  PRISTINE                        SHIPPED
SYMBOL     drainCbElabRefs15                      0                               1
MOVER      work@top.c1a[1].cb.clock               (unbound)                       bit_var work@top.c1a[0].clock
CONTROL A  work@top.c1a[0].cb.clock               (unbound)                       (unbound)
CONTROL B  work@top.c8s.cb.clock                  (unbound)                       (unbound)
CONTROL C  work@c1_if.cb.clock                    bit_var work@top.c1a[0].clock   bit_var work@top.c1a[0].clock
```

Identical to §5.1, cell for cell.

### GATE 2 — goldens, both directions
`23 PASS / 0 FAIL` with the shipped binary; `0 PASS / 23 FAIL` with
`SLANG_UHDM=/bin/false`.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`
```
679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL        = 679/50/2   ✓
496 match       183 differ        52 <empty>            = 496/183/52 ✓
ct8rows vs committed results/gate_uhdm2rtlil.csv: 731 ROWS both, 0 differing ROWS ✓
```
The **pristine** binary produces the identical histogram — the u2r corpus is
inert to this law, as predicted.

### GATE 4 — surelog, BOTH modes, `--jobs 2` — the **CONVERSION** world
```
                        my PRISTINE      my SHIPPED     expected(conversion)
default    CMP_EQUAL       467       ->     468              468   ✓
default    CMP_NOTEQUAL     13       ->      12               12   ✓
testflags  CMP_EQUAL       463       ->     464              464   ✓
testflags  CMP_NOTEQUAL     10       ->       9                9   ✓
```
My pristine numbers are **exactly the brief's UNCONVERTED expectation
(467/13 + 463/10)** — the calibration control. Every other bucket is unchanged
in both modes and on both binaries: `DEFERRED` 5/5, `SLANG_REJECT` 284/286,
`SURELOG_FAIL` 25/23, `NO_DATABASE` 3, `NO_UHDM` 1, `TIMEOUT` 1,
`UNTRANSLATABLE` 2.

`ct8rows.sh` vs the committed `results/golden_surelog.csv`, whole row, status
**and** dump column:
```
baseline 1588 ROWS, fresh 1588 ROWS
WHOLE-ROW diff: 2 differing ROWS (4 diff row-sides)   = EXACTLY 2 row-sides per mode ✓
  < SVSwitch,default,CMP_NOTEQUAL,decompile:,,
  < SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
  > SVSwitch,default,CMP_EQUAL,,,differ
  > SVSwitch,testflags,CMP_EQUAL,,,differ
dump-column histogram: default empty 327->326 / differ 242->243
                       testflags empty 331->330 / differ 298->299
```

**CANARIES.**
* **`InterfaceModPort` — the protected in-family canary, CHECKED FIRST AND BY
  NAME**, both modes, three ways: committed baseline `CMP_EQUAL,,,differ`, my
  pristine sweep `CMP_EQUAL,,,differ`, my shipped sweep `CMP_EQUAL,,,differ`.
  **UNMOVED.**
* **`BlackParrotComplex` — BY NAME**, both modes: `CMP_EQUAL,,,differ` unmoved.
* `canaries.sh` on both corpora: surelog `ok=50 changed=2 absent=0
  unknown-names=7`; the **2 changed rows printed and read** — both are
  `SVSwitch`, the intended conversion. u2r `ok=8 changed=0 absent=0`.
* `ctcan2.sh`, **EXPECT_UNKNOWN mode-matched, baseline first**: surelog
  `EXPECT_UNKNOWN=1` → `ok=58 changed=0 absent=0 unknown-patterns=1` **PASS**;
  u2r `EXPECT_UNKNOWN=6` → `ok=1 changed=0 absent=0 unknown-patterns=6` **PASS**.
* `canaudit.sh ./canaries.sh ./ctcan2.sh` → `audited=29 UNCOVERED=0
  FENCE-BREACH=0`; the four slang-fenced names (`UnsignedParam`, `HierPathEval`,
  `FileLocalParam`, `TopParam`) dispatched by **no** driver here. Neither did I
  dispatch them.
* **Every one of the census's 19 surelog candidates checked individually by
  name**, baseline → shipped: 18 `SAME`, 1 `MOVED` (`SVSwitch`). `UVMSwitch` is
  `SLANG_REJECT` in both modes — the implementer's honest miss is accurate.

`GOLDEN_DEFER` was **unset** throughout, as were `GOLDEN_CACHE` and
`SLANG_UHDM` in the ambient environment.

### GATE 5 — byte verifier, both corpora, both modes, vs my own pristine

`SELFCHECK=1 SELFCHECK1=1`:
```
uhdm2rtlil  databases: patched=679 pristine=679  PATH_SETS_IDENTICAL
            MOVERS: 0 / 679
            SELFCHECK 678/679 flagged     SELFCHECK1 1     ✓

surelog     databases: patched=953 pristine=953  PATH_SETS_IDENTICAL
            MOVER ./default/Scoreboard-59431470/slang.uhdm
            MOVER ./default/SVSwitch-db796243/slang.uhdm
            MOVER ./testflags/SVSwitch-db796243/slang.uhdm
            MOVERS: 3 / 953
            SELFCHECK 952/953 flagged     SELFCHECK1 4 (= 1 corrupted + 3)  ✓
```
**Same three paths as the implementer. REAL MOVERS: 2.**

**The `Scoreboard/default` flake, proven harder than the pass proved it.** The
ops rules require it be treated as MULTI-STABLE, same size = flake. Size is
`11122503` on both sides. I ran `Scoreboard/default` **twice with the PRISTINE
binary alone**:
```
PRIS run1  d24170f7b1ea   size 11122503
PRIS run2  af5750bd30f9   size 11122503     <- SAME BINARY, DIFFERENT BYTES
```
That is decisive on its own: **the unmodified binary is non-deterministic here**,
so no pairing involving it can be evidence of a change. Pooling the
implementer's runs with mine, `Scoreboard/default` has now produced **at least
four distinct digests at one fixed size** — `d24170f7b1ea`, `814cba9780b8`,
`5470021a5a2f`, `af5750bd30f9` — and the *pristine* binary alone produced three
of them. Its CSV row is `CMP_NOTEQUAL,decompile:` on the committed baseline, on
my pristine sweep, on my shipped sweep, and on both flake runs. This is the
`emitter-nondeterminism` entry already in memory; nothing in this patch touches
package listings.

**MOVERS PER SHAPE, vs GOLDEN, BY MULTISET, ADDED and REMOVED separately**
(`msthree.sh` on `SVSwitch/default`; both modes byte-identical so one table
serves both):
```
ADDED    FLD  ind 12   GOLD 90   PRIS 91   SHIP 94   |vpiActual:
ADDED    OBJ  ind 12   GOLD  3   PRIS  0   SHIP  3   \_bit_var: (work@top.output_intf[0].clock), line:58:38, endln:58:43
TOTAL SHAPES MOVED   2
```
**No REMOVED section.** The object shape lands on golden's count exactly
(`GOLD 3 / PRIS 0 / SHIP 3`). Three two-line insertions, +6 dump lines,
+34 bytes, nothing else.

**Multiset distance, and §5.5.3's explanation — verified:**
```
PRISTINE   golden-only 241   ours-only 623   MULTISET DISTANCE 864
SHIPPED    golden-only 238   ours-only 626   MULTISET DISTANCE 864
```
golden-only falls by **exactly 3**, ours-only rises by **exactly 3**. The
implementer's account of *why* — the companion line is the bare label
`|vpiActual:`, which our excess minted port views already carry at that depth,
so the instrument cannot credit the object it just got right — is **correct**,
and the `msthree` table above is what proves it rather than the prose.

**CENSUS-PREDICT.** I re-ran `census15.sh`: **19 surelog + 1 uhdm2rtlil = 20 test
dirs, UPPER BOUND** — identical to §5.5.0, including the named dirs. Truth was 1.
The over-prediction is honestly characterised in §5.5.1 and I confirmed the
stated reason by name (`UVMSwitch` = `SLANG_REJECT`, no database).

---

## 3. THE GRID — RE-MEASURED, PLUS 36 CELLS OF MY OWN

### 3.1 The implementer's 102 cells reproduce **exactly**

```
witness  CELLS 13   held 10   CONVERGED  3   REGRESSED 0   stillDIF  0
arm a1   CELLS 50   held 18   CONVERGED 22   REGRESSED 0   stillDIF 10
arm a2   CELLS 19   held 10   CONVERGED  9   REGRESSED 0   stillDIF  0
arm a3   CELLS 20   held  8   CONVERGED  8   REGRESSED 0   stillDIF  4
------------------------------------------------------------------------
TOTAL   CELLS 102   held 46   CONVERGED 42   REGRESSED 0   stillDIF 14
```
Cell for cell, target for target: `c7a[5:2] → c7a[2]` (the lowest index, no
element 0); `d2arr[0..1] → d2s` (an array binding to a **scalar**, and
`d2arr[0]` **bound**); `d3s → d3arr[0]`; `d4q[0] → d4p[0]`; `s2.u → s1.u`;
`e16 → e8` across a parameterization boundary. **The implementer's three
refutations of the brief's stated law all hold. The brief's law was wrong and
transcribing it would have produced four wrong cells and one wrong target.**

### 3.2 A WIDER instrument than the grid — the whole database, not just cb refs

`grid15.sh` filters to `.cb*.` refs. I ran the **unfiltered** `cbcensus.sh` — every
`ref_obj` and its `vpiActual` — on every arm and on the witness, both binaries,
and diffed the DIF sets:

| | pristine DIF | shipped DIF | **new DIF (regressions)** |
|---|---|---|---|
| witness `SVSwitch` | 7 (of 694 cells) | **4** | **0** |
| arm a1 | 25 (of 139) | **3** | **0** |
| arm a2 | 9 (of 64) | **0** | **0** |
| arm a3 | 8 (of 60) | **0** | **0** |
| **my arm v1** | 10 (of 67) | **0** | **0** |
| **my arm v2** | 5 (of 47) | **0** | **0** |

**Not one ref binding anywhere in any of these databases became wrong.** The
witness's 4 residual DIFs are exactly §1.3's `work@top.TC.output_intf[0..3].clock`
naming (R6); a1's 3 are `c11_if`'s unbound def ref (R3) and c5's two def-view
process refs (R1). Both were DIF before the patch too.

### 3.3 EMPTY-PRODUCT CELL HUNT — none found

Every one of the **138** grid cells (102 + my 36) classified:

```
GRID ROWS TOTAL                                                        138
  GOLDEN ABSENT (-)   — a cell with no golden value, i.e. empty product   0
  golden UNBOUND & ours UNBOUND — the law's over-fire CONTROL cells      34
  golden BOUND, ours == golden  — real agreement                        91
  golden present, OURS ABSENT   — missing-producer residues             13
```

* **Zero cells have no golden side.** No cell in this pass is green because
  nothing was produced on either side.
* The 34 `(unbound)/(unbound)` cells are **not** vacuous: they are precisely the
  cells a naive "bind every elab ref to the def target" implementation would have
  turned DIF. They are the law's asymmetry doing work as an over-fire control.
* Exactly **one declared arm cell produces no grid cell at all** — `a1`'s `c5`,
  which has no clocking block. It is **disclosed** in §6.5, and it is not silently
  dropped: the unfiltered census gives it two rows and the implementer turned them
  into residue **R1**. I confirm both the content and its determinism
  (`work@c5_if.clock` golden `c5a[0]` / ours `c5a[2]`, identical on both
  binaries). This is a residue reported, not an empty cell counted as green.

### 3.4 The 14 `stillDIF` cells — checked, and the framing is honest

All 14 are refs on an object we emit **nowhere** (`c6` module named clocking 5,
`c11` 2-D interface array 5, `e4` interface `default clocking` 4 = 14 exactly).
I verified this directly: in `cbcensus.sh`'s table their OURS column is `-`, not
a wrong binding. The grid *does* fold "we emit nothing" and "we bind wrongly"
into one verdict name — but §3.5 says so in plain words, and the count is right.
**Not one `stillDIF` is a wrongly bound ref.**

---

## 4. MY OWN ARMS — TEN SHAPES THE PASS NEVER MEASURED

Two new arms, `v1_cbedge.sv` and `v2_cborder.sv`, written **to break the law**,
run on both binaries with the pass's own drivers.

### 4.1 `v1_cbedge.sv` — 23 cells, **10 CONVERGED, 0 REGRESSED, 0 stillDIF**

| cell | shape never measured by a1/a2/a3 | golden's target | ours |
|---|---|---|---|
| **f1** | instances minted inside a **`generate for`** loop | `gblk[0].f1u.clock`; `gblk[0]` unbound | matches |
| **f2** | one instance at **top** + one inside a **`generate if`** | `gif.f2gen → f2top.clock` | matches |
| **f3** | an interface def **NEVER INSTANTIATED** | def ref *(unbound)*, no elab views | matches |
| **f4** | an interface **nested inside another interface**, outer array `[2]` | all three others → `f4o[0].in0.clock`; that one unbound | matches |
| **f5** | modport-carried cb, array `[3]` | `f5a[0].clock` | matches |
| **f6** | **two** clocking blocks whose events name the **SAME signal** | both blocks' `[1]` refs → `f6a[0].clock`, independently; both `[0]` refs unbound | matches |

`f3` is the sharper of these: §6.8 flags "an interface whose clocking event does
not resolve" as unmeasured, and the closest reachable case — a def with no
instances at all — is now measured. Golden leaves the def ref unbound; so do we;
`drainCbElabRefs15` copies nothing and does not fire, exactly as the code's
stated behaviour predicts. `f6` is the key-collision probe: the key is
`(clocking-decl syntax node, ref name)`, and two blocks sharing the name `clock`
do **not** collide, because `csyn` is per-block.

### 4.2 `v2_cborder.sv` — 13 cells, **5 CONVERGED, 0 REGRESSED** — and it settles a real question

The pass's `a2/d5` puts both instances at the **same** hierarchy depth, so it
cannot distinguish "first elaborated, design-wide" from "top-level declarations
first". `v2` puts them at **different** depths in **both** orders:

| cell | shape | GOLDEN | ours |
|---|---|---|---|
| **g1** | first instance one level **DOWN** (`gsub gs` declared first), second at **top** | `gtop → gs.gu.clock`; `gs.gu` unbound | matches |
| **h1** | first instance at **TOP** (`htop` declared first), second one level **down** | `hs.hu → htop.clock`; `htop` unbound | matches |
| **k1** | clocking event on a **body** `bit`, array `[3]` | `k1a[0].lclk` | matches |
| **k2** | the def's first textual instance is inside **`generate if (0)`** — never elaborated | the first **LIVE** instance `k2a[0]` is the target | matches |

**g1 + h1 together are the measurement:** the target flips with plain source
order **across hierarchy levels**, in both directions. It is not "top-level
first", and it is not "shallowest first". **`§ cbEventRefFirstInstance15`'s word
"design-wide" is now measured rather than assumed**, and our implementation
tracks golden in both directions.

**`k2` answers the brief's item (b) — "what if [0] is culled" — with an actual
culled instance.** The pass answered it by argument (`c7a[5:2]` has no element 0,
so the rule "never mentions 0"); `k2` answers it by measurement: a
`generate if (0)` instance is not elaborated, is not the target, and the first
**live** instance is. Golden and we agree.

Combined verifier arms: **36 cells, 15 CONVERGED, 0 REGRESSED, 0 stillDIF**, and
**0 new DIF** in the unfiltered whole-database census of either arm.

---

## 5. THE CODE — READ ADVERSARIALLY

The executable core is ~20 lines. I checked the four things that could make it
wrong in a way no arm would show:

1. **Ordering.** `defCbBody`/`defCbEventRefs` are written in the DEF view.
   `UhdmExporter.cpp` guarantees the ordering the law needs, in a comment that
   predates this pass: *"Every def's CONTENT … compiles before any instance"*, and
   `emitInterfaceDef` is called from that loop. So no elab view can reach the
   `else if` before its def has registered — an under-fire that would have been
   invisible in a small arm is structurally excluded. **Verified by reading, and
   by `v2`'s `g1`, where the def's first instance is one level down.**
2. **The design-final drain.** `drainCbElabRefs15()` runs in `exportDesign`
   ahead of the pinned tail, so the answer cannot depend on elab emission order.
   It only ever **fills a NULL** `Actual_group` on a ref it queued itself; it
   writes nothing else. The 1632-database byte verifier is the proof that the
   four tail passes are undisturbed.
3. **The first-writer-wins guard on `pendingCbRefs` is a genuine behaviour
   change** (the pristine drain was last-writer-wins), and it is the one edit
   whose blast radius is not obvious from the diff. §6.8 flags its body-sharing
   branch as **unexercised**, which is the correct disclosure. I add the
   empirical bound: across **1632 databases** and **six** arms, the guard changes
   **nothing** — the only movers are the three intended `vpiActual` fills. The
   reason is structural: `sym9` comes from the DEF's body and `nm` is keyed by
   symbol identity, so at most one instance's netMap can ever match. The guard is
   proven inert; it is **not** proven correct if it ever fires, and the README
   says exactly that.
4. **Adjacent laws.** `§ modportExprPort`'s own def-ref patch
   (`src/ModuleEmit.cpp:23616` in the patched tree) uses a separate vector
   (`pendingModportExprRefs`), a separate drain, and matches by **name** within
   `netMap` rather than by symbol; it is untouched. `§ ifaceDupVarsAreHomeVars14`
   (landed `a27a874`) writes no `Actual_group`. `§ vifClockingPathComponent5`
   lives in `ExprEmit.cpp` on virtual-interface paths. **No collision.** I also
   resolved **every** line-number citation in the implementer's README: they are
   consistently `a27a874` (pre-patch) line numbers, and each one lands on the text
   quoted (`ModuleEmit.cpp:10515` global-clocking "a CLONE of the def's";
   `:22459`/`:23867` the two `emitNamedClockingBlocks` call sites;
   `UhdmExporter.cpp:4788` the single `emitInterfaceDef` site).

---

## 6. FINDINGS

Numbered, each with the command that produced it. **None affects a measured
number; none blocks landing.**

### F1 — `README.verifier.md` was absent from the patch. **This file is the fix.** (hygiene, RESOLVED)

```
git apply --numstat /tmp/r10svs15.patch | grep -c README.verifier.md   -> 0
```

The implementer's §8.1 is a *correct* decision at the time it was written: no
verifier had run, and shipping a carried-forward report is the exact failure the
brief's "misfiled twice" rule exists to prevent. But the brief also requires that
what lands carries **THIS pass's** verifier report, and the patch as delivered
carries none.

**Action for the MASTER — already prepared.** A drop-in replacement patch is on
disk:

```
/tmp/r10svs15v_verified.patch
```

(Its md5 is quoted in the verifier's return message, not here: the patch
*contains this file*, so an md5 written inside it can never be its own.)

It is `/tmp/r10svs15.patch` **with the production diff byte-for-byte unchanged**
(asserted: `diff` of the two trees' `git diff a27a874 -- include src` is empty)
plus three files — this `README.verifier.md`, `v1_cbedge.sv`, `v2_cborder.sv`.
`git apply --check` is **rc=0 onto pristine `a27a874` AND onto head `49475c9`**.
Landing either patch is fine; landing this one is what satisfies the brief's
`README.verifier.md` rule without a second step. §8.1's
sentence *"If a verifier runs later, its report is what belongs at that filename,
and it must quote `f1a2249b…` and `fe6962c2…`"* is satisfied: both md5s are
quoted at the top of this file, and I re-derived both from source.

### F2 — `msdist.sh` accepts a `.uhdm` binary and prints a plausible number (instrument, LOW)

```
bash msdist.sh <golden.uhdm> <ours.uhdm>     # binaries, not dumps
  -> golden-only 623  ours-only 756  MULTISET DISTANCE 1379   g lines=713
```

`msdist.sh` takes **dumps**; its sibling `msthree.sh` takes **`.uhdm` files** and
dumps them itself. The two live side by side with near-identical names and
opposite input conventions. `msdist.sh`'s only guard is `[ -s "$f" ]`, which a
binary passes, so `sort | uniq -c` over raw bytes yields a **confident-looking
wrong distance** rather than an error. This cost me one measurement cycle before
`g lines=713` (against a real 25318) gave it away.

*Suggested hardening, one line:* reject an input whose first line does not look
like a dump, e.g. `head -c2 "$f" | grep -q '[[:print:]]' || exit 6`, or simply
`file`-check for text. Not this pass's defect — the script is carried in
byte-identical from `r10svs14repro` — but it is a live trap in a directory that
ships both scripts. The implementer's own numbers are **correct**; they used it
correctly.

### F3 — §3.1's witness table prints 9 of the grid's 13 cells without saying "excerpt" (doc, LOW)

```
bash grid15.sh svs   ->  CELLS 13   held 10   CONVERGED 3   REGRESSED 0   stillDIF 0
```

§3's summary table correctly says `CELLS 13`, but §3.1's per-row table lists 9.
The 4 omitted rows are `output_intf[0..3].cb.read`, all
`(unbound)/(unbound)/(unbound)` → `held`, so nothing substantive is hidden and the
totals are right. Label it an excerpt, or print all 13.

### F4 — §5.4 quotes `canaudit.sh` with no arguments; it requires two (doc, LOW)

```
bash canaudit.sh                     -> canaudit.sh: line 21: 1: path to canaries.sh   (exit 1)
bash canaudit.sh ./canaries.sh ./ctcan2.sh
                                     -> audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
```

The reported result is correct; only the quoted invocation is incomplete. A
reader copying it gets a usage error, which in this campaign's idiom is exactly
the "green-looking run that measured nothing" shape — here it fails loudly, so
the risk is low.

---

## 7. LANDING REALITY — THE PATCH ON THE CURRENT HEAD

The brief names `r10earl37` and `r10uvm67` as live. **`r10earl37` has since
LANDED as `49475c9`**, and it edits `src/ModuleEmit.cpp` — the same file this
patch edits. So I checked the landing target, not only the stated base:

* `git apply --check /tmp/r10svs15.patch` onto **`49475c9`** → **rc=0**, no
  textual collision. `r10earl37`'s hunks are at `emitModuleArray` (~2356) and
  `emitDefGenStmts` (~25499+); this patch's are at 21334–21440 and
  `UhdmExporter.cpp` 5860.
* Semantically disjoint: `r10earl37` is `§ genConnDottedActualIsHierPath37`
  (port-actual hier_paths in generate connections); it touches no clocking
  object, no `pendingCbRefs`, and not `exportDesign`'s design-final region.
* `r10uvm67` (worktree, base `00b7fda`) touches `ModuleEmit.cpp:20789`
  (`drainFuncRet`), `UhdmExporter.h:3225`, and `TypeEmit.cpp`. **No collision.**

**And I did not stop at `--check`. I built the landing target.** Two more
binaries, from `49475c9`:

| | md5 | symbol |
|---|---|---|
| `49475c9` pristine | `dfc46cad6152aa06c368d3c63729a128` | `drainCbElabRefs15` = **0** |
| `49475c9` + patch | `5478b377271cf37d444e946449f63242` | `drainCbElabRefs15` = **1** |

`Linking CXX executable slang-uhdm` = 1, `error:` = 0. On them:

```
basemark.sh, 49475c9 PRISTINE                      49475c9 + PATCH
  MOVER      work@top.c1a[1].cb.clock  (unbound)   bit_var work@top.c1a[0].clock
  CONTROL A  work@top.c1a[0].cb.clock  (unbound)   (unbound)
  CONTROL B  work@top.c8s.cb.clock     (unbound)   (unbound)
  CONTROL C  work@c1_if.cb.clock       bit_var work@top.c1a[0].clock  (both)

goldens on 49475c9 + patch                  23 PASS
SVSwitch  on 49475c9 + patch                CMP_EQUAL,,,differ  (BOTH modes),
                                            uhdm-cmp rc=0, HEAD DEPTH 0, heads 0
InterfaceModPort on 49475c9 + patch         CMP_EQUAL,,,differ  (BOTH modes),
                                            rc=0 — the protected canary, BY NAME
```

**The conversion, the law, the asymmetry, the controls and the protected canary
all hold on the commit the patch will actually land on**, not merely on the base
it was developed against.

---

## 8. RANKED RESIDUES (verifier's ranking)

**R1 — a DEF-view *process* ref names the wrong element.** `work@c5_if.clock`
golden `work@top.c5a[0].clock`, ours `work@top.c5a[2].clock` (and the same for
`.d`). Deterministic, identical on both binaries, **outside** the `.cb.` grid so
it is invisible to `grid15.sh` and visible only in the unfiltered census. It is
*this pass's own sentence on a third carrier*. Sharpest because the mechanism is
already written down and the fix is likely the same first-writer-wins shape.
Not on the `SVSwitch` path.

**R2 — a MODULE's named clocking block is emitted nowhere.**
`emitNamedClockingBlocks` has two call sites, both on interfaces
(`ModuleEmit.cpp:22459` def, `:23867` elab, `a27a874` numbering);
`emitScopeClocking` is gated on `asModuleInst`. Arm `a1/c6`, 5 cells. Golden's
target rule here is **different** — the DEF's OWN net, for the def view *and* all
four elements — so minting the object is necessary but not sufficient. That rule
is measured and recorded, which is what makes this the best-prepared residue.

**R3 — an interface's `default clocking` is not emitted.** Arm `a3/e4`, 4 cells.
Golden applies **this pass's law verbatim** (`e4a[1..2] → e4a[0].clock`, `e4a[0]`
unbound), so it is a pure missing-producer with its binding rule already known.
Ranked above R4 because the rule is already proven, not merely predicted.

**R4 — 2-D interface arrays get no elab views.** Arm `a1/c11`, 5 cells. Golden
needs no extension (`c11a[0][0]` is the single first); once the views exist this
law covers them unchanged. My `v1/f4` supplies supporting evidence from the
*nested-interface* direction, where the "one first across the whole nesting" rule
already works in our emitter.

**R5 — `msdist.sh`'s missing input-type guard** (F2). One line, and it protects
every future pass that reaches for the wrong sibling script.

**R6/R7/R8 — `r10svs14`'s R2/R3/R4-R5, untouched**, on
`§ progPortIfaceArrayUnowned13`'s declared boundary: the minted program-port
interface views, the unowned island's naming (the witness's 4 residual census
DIFs), and the non-ANSI header-port order / generic-port doubling.

---

## 9. WHAT I DID NOT VERIFY

Stated plainly, so the next reader does not mistake silence for coverage.

* I did **not** re-run the `folded` overlay; `GOLDEN_DEFER` stayed unset and
  `--mode both` is what the gates specify.
* I did **not** exercise the `pendingCbRefs` first-writer-wins branch's
  body-sharing case. Like the implementer, I can only show it is **inert** across
  1632 databases and six arms. It remains an unexercised branch.
* I did **not** independently audit the witness's 23 `MISSING` census cells. I
  confirmed the count is unchanged (23 on both binaries) and that the 4 remaining
  `DIF` cells are `r10svs14`'s R3 — both are outside this law.
* The design compares EQUAL **with those 4 DIF cells present**, because
  `uhdm-cmp` does not reach them today. That is disclosed in §6.8 and I confirm
  it: a future comparator change can un-hide them. It is a property of the
  instrument, not a defect this pass introduced.
* My sweeps ran four-at-a-time, which the ops rules warn can race `SURELOG_FAIL`
  **detail** rows. The whole-row diff shows **no** `SURELOG_FAIL` row moved in
  either direction on either corpus, so the warning did not bite.

---

## 10. WORKDIRS

Deleted after the gates read them, as the ops rules require:
`/tmp/r10svs15v_{sl,u2r}_{ship,pris}_wd` and the two `Scoreboard` flake workdirs.
The CSVs, dumps, censuses, arm workdirs and build logs are kept, all under
`/tmp/r10svs15v_*`, so §1–§5 are re-readable without re-running Surelog. The
implementer's own kept evidence under `/tmp/r10svs15_*` was **not touched**: my
grid runs used a path-retagged copy of `grid15.sh` (the only edit being the two
`/tmp/r10svs15_…` → `/tmp/r10svs15v_…` prefixes) so that nothing of theirs was
clobbered.
