# README.verifier.md — r10sd7, ADVERSARIAL VERIFICATION

**VERDICT: PASS.**

Every gate, every grid cell, every boundary and every headline number in
`README.md` was re-derived from a **fresh worktree at `f0d93e1`**, a fresh
`git apply` of `/tmp/r10sd7.patch`, and two independently-configured `-j 2`
builds. Nothing was taken from the implementer's worktrees, binaries, sweeps or
databases.

The single strongest cross-check: **both binaries rebuild to the implementer's
md5 bit for bit** —
delivered `f46ccffff0fa29f838a5701882a685ba`, pristine
`2ecf28a8494750468a6edcd435b8f874`. The delivered patch and the delivered
measurements describe the same object.

| | |
|---|---|
| verifier worktrees | `/tmp/wt_r10sd7ver` (patched), `/tmp/wt_r10sd7verp` (pristine) — both `f0d93e1`, grep-checked `=1` |
| verifier sweeps | `/tmp/v7_sl_new.csv` `/tmp/v7_sl_pris.csv` `/tmp/v7_u2r_new.csv` `/tmp/v7_u2r_pris.csv` |
| re-cut patch | `/tmp/r10sd7.verified.patch` |
| production diff | `src/ModuleEmit.cpp` **+77 −1**, byte-for-byte as delivered |

---

## 1. THE LAW SURVIVES THE STRONGEST TEST AVAILABLE

The implementer's §3.1 reports a depth **histogram**. A histogram can match
golden while the *wrong* five cells move. So the census was re-run and joined as
a **MULTISET OF ROWS**, golden against both binaries:

```
SeqDriver, ct7pop, row multiset joined against golden
                       rows   golden-disagreement
  golden               1325   —
  ours PRISTINE        1325   93
  ours DELIVERED       1325   88          <- five fewer, no others changed

PRISTINE -> DELIVERED, exact multiset movement:
  REMOVED 5 / ADDED 5, and every one of them is the same cell:
   - adpcm_pkg::adpcm_{driver,seq_item,sequencer,test,tx_seq}
       :: uvm_random_seed_table_lookup | d1 ts/index
       | string_typespec@328:44-328:50 | inst=TOP:uvm_pkg
   + ...                                | inst=<null>          == GOLDEN
```

**Five rows moved, all five in the correct direction, and no row anywhere else
in the 1325-row population changed.** The histogram claim (`1139/63/81/39/3` on
all three sides) is therefore not merely satisfied, it is satisfied cell-by-cell.

Same join on the other two designs, and the same result:

| design | golden d1 `<null>`/SET | pris | delivered | rows moved | golden-disagreement |
|---|---|---|---|---|---|
| SeqDriver | 81 / 39 | 76 / 44 | **81 / 39** | 5 (all correct) | 93 → **88** |
| SimpleUVM | 78 / 39 | 76 / 41 | **78 / 39** | 2 (all correct) | 84 → **82** |
| Scoreboard | 78 / 39 | 76 / 41 | **78 / 39** | 2 (all correct) | 84 → **82** |

### The control that chooses the law — re-read, all three databases

`ct7pkgsub uvm_random_seed_table_lookup`, four package listings, view-matched:

```
GOLDEN  [ALL]uvm_pkg ALL:uvm_pkg   [ALL]adpcm_pkg ALL:adpcm_pkg
        [TOP]uvm_pkg TOP:uvm_pkg   [TOP]adpcm_pkg TOP:adpcm_pkg
PRIS    identical      DELIVERED   identical
```

So §3.2 holds: "an associative array's index typespec carries no `vpiInstance`"
is refuted on its own evidence, and the law belongs to the **copy**.

### STATED GATE == CODE GATE

Read line by line against `src/ModuleEmit.cpp`. The stated behaviour — walk
`vpiIndexTypespec`/`vpiElemTypespec` (array) and `vpiElemTypespec`
(packed_array) to depth 4, null `Instance` **below depth 0 only**, only when
`cpTs != srcTs`, stop on kind divergence, never walk `Typedef_alias` — is
exactly what the code does. `+77 −1`, one file-static + one call site. No
production file outside `src/ModuleEmit.cpp` is touched, and the 82 probe files
are all under `tools/probe/r10sd7repro/`.

---

## 2. FIVE GATES — re-measured, not reviewed

| gate | measured by the VERIFIER | vs README |
|---|---|---|
| **1 BUILD** | both worktrees `BASE f0d93e1` grep-checked `=1`; `0` ` error:` each; `Linking CXX executable slang-uhdm` at line 73 of each log, before any md5 was read; md5 **f46ccff…** / **2ecf28a…**; pristine porcelain **0** | **EXACT, including both md5s** |
| **2 GOLDENS** | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 / 23** | EXACT |
| **3 u2r** | default **679/50/2**, testflags **679/50/2**; testflags dump **496 match / 183 differ / 52 blank**; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` → **0 ROWS, 0 row-sides, PASS**; pristine-vs-delivered → **0 ROWS** | EXACT |
| **4 surelog** | default **469 / 11 / 25 SURELOG_FAIL / 5 DEFERRED / 284**; testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM). All four dump histograms **225/244/325** and **165/300/329**. `ct8rows` vs committed `results/golden_surelog.csv` → **0 ROWS, PASS**; pristine-vs-delivered → **0 ROWS** | **BETTER — see F1** |
| **5 BYTE VERIFIER** | u2r **0 / 1358**, surelog **5 / 953**, `PATH_SETS_IDENTICAL` both; SELFCHECK **1357/1358** and **952/953**; SELFCHECK1 **1** and **6**. Census-predict run FIRST off the PRISTINE artifacts: **5 surelog / 0 u2r**, and the five names it printed are the five the comparator found | EXACT |

`GOLDEN_DEFER` = **`[UNSET]`**. `SLANG_UHDM` pin read exhaustively out of
`cmds.txt`: surelog **1573** files, **1523** `slang:` lines, **1523/1523** name
the verifier's own binary and 0 name any other; u2r **1462 / 1458 / 1458**.
`git status --porcelain -- results` = **0**. All sweeps `--jobs 2`, private
`--out`/`--workdir`. No `git stash`. slang not patched.

### MOVER RULE — every mover has a nonzero SIZE delta

```
default/SeqDriver     18021074 -> 18021021   -53
testflags/SeqDriver   18021497 -> 18021453   -44
default/Scoreboard    11145455 -> 11145436   -19
default/SimpleUVM     11141095 -> 11141083   -12
testflags/SimpleUVM   11141412 -> 11141400   -12
default/BuildUVMPkg   11105247 -> 11105247     0  (byte-identical, predicted 0)
testflags/BuildUVMPkg 11105247 -> 11105247     0  (byte-identical, predicted 0)
```

All five real. Per-shape, by MULTISET, ADDED and REMOVED separately
(`ct7shape.py`): SeqDriver `vpiInstance` **0 / 5**, `package` **0 / 5**,
**130 other shapes 0 / 0**; SimpleUVM and Scoreboard **0 / 2** and **0 / 2**,
116 and 109 other shapes unchanged. That is the transcription and nothing else.

Every moved row is already `CMP_NOTEQUAL` (or `SLANG_REJECT`) at baseline; no
`CMP_EQUAL` database changed a byte anywhere in either corpus.

### The cost is real and was reported honestly

```
msdist to golden   SeqDriver  359631 -> 359641  (+10)
                   SimpleUVM  140250 -> 140254  (+4)
                   Scoreboard 130534 -> 130538  (+4)
positional diff -u SeqDriver  503005 -> 503007  (+2)
```

Reproduced exactly. The implementer led with this rather than burying it, and
the object census is the right authority: the five deleted lines are five lines
golden does not have, on a shape where golden is thousands of lines ahead of us
(R7, re-measured below).

### The head ADVANCED — measured, not asserted

```
PRISTINE   r=-1  failedLhs=<null>  failedRhs=package(uvm_pkg)@28:1-39:11  visited=1650   pool 5934
DELIVERED  r=-1  failedLhs=<null>  failedRhs=package(uvm_pkg)@28:1-39:11  visited=1653   pool 5929
```

`cmp.log` is **byte-identical** at 1 422 659 lines with `grep -c '^LHS:' == 1` on
both — and §6.6 is right that this proves nothing, because the printed body is
the RHS package's subtree dump. `visited` **1650 → 1653** and pool **−5** is the
measurement with content. Other rows: SimpleUVM 17/17, Scoreboard 26/26,
BuildUVMPkg 94/94, `testflags/Scoreboard` `SLANG_REJECT` (SKIP, not agreement).

### Determinism

`detcheck.sh` on `g1`, delivered binary: 3 runs, **1 distinct sha256**, 0
NO_OUTPUT. And on the design that matters: SeqDriver built twice from different
cwds with different `-o` paths is **byte-identical**
(`aaa1bff6bb3a2cebf7075785d11b9d3d`).

---

## 3. GRID — re-run on both binaries, golden re-read

| cell | GOLDEN class copy | ours pris | ours delivered | pkg listing pris→new | dump content |
|---|---|---|---|---|---|
| **g1 assoc index import** | `index inst=<null>` | `TOP:p1` | **`<null>` == GOLDEN** | **IDENTICAL** | 135 → **133** |
| **g5 int index import** | `index inst=<null>` | `TOP:p5` | **`<null>` == GOLDEN** | **IDENTICAL** | 135 → **133** |
| **g6 two-level import** | `index inst=<null>` | `TOP:p6` | **`<null>` == GOLDEN** | **IDENTICAL** | 289 → **287** |
| g2 dynarray elem | **no elem ts, either side** | — | — | IDENTICAL | 92 → 92 |
| g3 class-own assoc (CONTROL) | `<null>` | same | same | (no listing, printed as such) | PASS_CMP, unchanged |
| g4 no import (CONTROL) | no class copy | — | — | IDENTICAL | PASS_CMP, unchanged |

The whole-grid `diff` between the two binaries changes **only** the three
`OURS CLS … d1 ts/index` lines, the three `DUMP_DIFF content=` counters, and
heap POINTERS. No `PKG` instance value moves anywhere.

**Boundaries — RE-RUN on both binaries, not cited:**

* **sd4 `§ classHomedTypeTsNoPkgInstance4`** — the whole `qgrid4` re-run through
  `ct7arm.sh` on both binaries: `q1 26, q2 4, q3 26, q4 36, q5 6, q6 2, q7 16,
  q8 2, q9 56, q10 42, q11 70, qv12 86, qv13 56` — **sd4's recorded numbers to
  the digit, and `diff`-IDENTICAL between the two binaries.** `BuildUVMPkg`
  byte-identical in both modes.
* **sd5 `§ importedClassVarIsOwnCopyNoInstance5`** — `ct5cls` pristine vs
  delivered `diff`-EMPTY, `X own named INST 63` intact.
* **sd6 `§ importCopyInitRefIsOwnedAndUnbound6`** — `ct6clsref` on the delivered
  database is identical to the pristine one **and to GOLDEN**. `grid6` g1–g6
  `diff`-IDENTICAL on both binaries.
* **sd3 `§ retNameLocalInstIsHomeNotClass3`** — see F4; the refutation stands.
* **CANARIES** — `canaries.sh` surelog **ok=52 changed=0 absent=0** vs the
  committed baseline *and* vs this pass's own pristine sweep, unknown-names 7;
  u2r **ok=8/0/0**, unknown 25. `ctcan2.sh` surelog `EXPECT_UNKNOWN=1`
  **ok=58/0/0 PASS**; u2r `EXPECT_UNKNOWN=6` on the testflags-only CSV
  **ok=1/0/0 PASS**. `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0
  PASS**, with `UnsignedParam`/`HierPathEval`/`FileLocalParam`/`TopParam` all
  confirmed dispatched by no driver. `InterfaceModPort` and `BlackParrotComplex`
  **by name**: `CMP_EQUAL` in both modes on both binaries, matching the committed
  baseline row for row.
* **COLLISION, CONFIRMED** — `r10earl47` is live at `f0d93e1` in
  `/tmp/wt_r10earl47` and touches `src/ModuleEmit.cpp`, this patch's only
  production file. The two changes are in different functions
  (`importVarCopy5` + one static above it, vs generate-block work), so the
  overlap is textual; **the integrator must merge, not cherry-pick.**
  `r10uvm76` is ExprEmit — no overlap.

---

## 4. FINDINGS

**F1 — gate 4 is CLEANER than reported; the brief's pin reproduces.**
The README reports `testflags` `SURELOG_FAIL = 24` and one moved row
(`Google,testflags` `TIMEOUT` → `SURELOG_FAIL`) against the committed baseline.
On the verifier's sweeps the count is **23** — the brief's pinned 25/23 — on
**both** binaries, and `ct8rows` against the committed
`results/golden_surelog.csv` reports **0 differing ROWS on both corpora**. The
implementer's extra row was a machine-load TIMEOUT on the **golden** side, which
they diagnosed correctly and reported as measured. Nothing to fix; recorded so
the next pass does not inherit a phantom moved row.

**F2 — `README.md` §8 R1's killer counts need their MODE named (doc).**
"`ct4scan` on the DELIVERED database returns 24 singleton killers (was 21)" is
reproducible **only** in `visited` mode: `ct4scan <g> <o> visited` → **21 → 24**,
exactly as stated. The tool's DEFAULT mode is `nullinst`, which gives **8 → 10**.
Both modes name the same new object. Name the mode.

**F3 — §6.4 / R5's "golden runs 3735 lines long on `|vpiInstance:`" is not
reproducible as stated (doc).** The measured per-shape multiset distance is
**3739 → 3744**. The argument — that deleting correct lines *raises* a
golden-only surplus — is unaffected, and the surplus is real.

**F4 — §7.3's sd3-boundary sentence overreaches; §4 and §9.1 are exact.**
`ct7loc` on `uvm_report_warning` gives **36 rows per side, every one
`inst=<null>`, `diff`-identical** — verbatim as claimed, and the brief's
statement-local hypothesis is genuinely **REFUTED**. But §7.3 generalises it to
"every function-body local of `uvm_report_*`", and that population is **368 rows
per side with 170 `diff` sides**. Every one of those 170 is a **SPAN** difference:
strip spans and the two sides are byte-identical, `inst=` fields included. So no
instance law differs there either — but "diff-identical" is the wrong word for
the wider family.

**F5 — §7.3 / R7's "our 9 892" is the PRISTINE figure (doc).** Re-measured:
golden **13 184** instanced objects, ours **9 892 pristine → 9 887 delivered**;
`enum_typespec TOP:uvm_pkg` **390 vs 12**, `struct_typespec TOP:uvm_pkg`
**90 vs 2**. R7 is otherwise exact.

**F6 — the law GENERALISES past the delivered grid (verifier-added evidence).**
Two new cells written by the verifier and not in the delivered patch's grid:

* `grid7v/v2_packed_elem_import.sv` — `typedef logic [3:0] n8; n8 m8 [string];`
  the element is a **packed typedef**, a shape the grid never tries. Pristine
  `index inst=TOP:p8`; **delivered `<null>`, == golden.**
* `grid7v/v3_assoc_of_array_import.sv` — `k9 m9 [string][2]`. Pristine
  `index inst=TOP:p9`; **delivered `<null>`, == golden.**

Two independent shapes outside the fitted set move the right way. This is the
evidence the law needed most and it was not in the delivery.

**F7 — R3 must be ESCALATED: the `Elem_typespec` and `packed_array_typespec`
arms are UNREACHABLE, not merely unexercised.** The README calls them
unexercised and carries them on the pointer guard. The verifier tried three
further shapes chosen specifically to fire them — a fixed-size unpacked array of
a class type, an assoc array with a packed element, and an assoc array whose
element is itself an array — and **not one produced a single `ts/elem` row on
either side**, in addition to the 6 delivered grid cells and all 2 311 corpus
databases. They are dead code with zero coverage in every corpus and every probe
this campaign has. Recommendation: **cut both arms**, or land them only with an
explicit "unreachable, retained as the faithful transcription of the law" comment
that a reader cannot mistake for tested behaviour. This does not block the pass —
dead code cannot regress anything, and the byte verifier proves it did not.

**F8 — a NEW defect the verifier found, NOT introduced by this patch.**
`grid7v/v1_fixedarray_elem_import.sv`: a package **fixed-size unpacked array of a
class type** (`k7 m7 [4]`) wildcard-imported into a package that declares a
class. Golden's importing class lists `m7`; **ours does not list it at all** —
the import copy is MISSING for that shape, not merely mis-stamped:

```
GOLDEN q7::c7 :: m7   | d0 ts | array_typespec@0:0-0:0 | inst=<null>
OURS   (no m7 row)
```

Identical on **both** binaries, so it is not a regression. It is an under-fire of
`§ importedClassVarIsOwnCopyNoInstance5` and a cheap, self-contained next cell.

**F9 — a latent gap in the safety argument, with proof that it did not bite
here.** `cpTs == srcTs` guards only against sharing with the **source
variable's own** subtree. It does not guard against a cloned typespec that is
*also* registered in a `design`/`package` `Typespecs` listing — R1's own
`class_typespec(uvm_seed_map)` is reached from exactly such a listing, so that
kind of sharing demonstrably exists in these databases. No collateral occurred:
the per-shape multiset removes **exactly 5** `|vpiInstance:` lines for 5 objects,
and an object printed under two listings would have removed two lines each; and
all four package listings are unchanged. State the limit in the law.

**F10 — refutation 5 is stronger than its own evidence.** `BaseClass.h`: the
singular `SafeCompare` sets `m_failedRhs` alone and returns **−1**; the vector
overload sets **both** `m_failedLhs` and `m_failedRhs` and returns **+1**.
`ct7mut` reports `r=-1`, so the vector branch is excluded by the **sign of `r`**
before any census is needed. `ct7vec` was still re-run and agrees (all `uvm_pkg`
vectors equal in size on both views, both sides; only object IDs differ) — it is
a belt-and-braces control, not the load-bearing one.

**F11 — deliverable integrity.** `/tmp/r10sd7.patch` md5
**`97bc49a9a349253c11dc340629395f77`**, 317 382 bytes, 7 250 lines, 83 `diff
--git` entries = `src/ModuleEmit.cpp` + **82** files under
`tools/probe/r10sd7repro/`, nothing else. `git apply --check` at `f0d93e1`
rc=**0** on a worktree that had never seen it.

**F12 — reproducible builds.** Both binaries rebuild to the implementer's md5s
exactly. Every number in this file was produced by binaries the verifier
compiled.

---

## 5. RESIDUES, RANKED (verifier's list)

1. **R1 — `class_typespec(uvm_seed_map)@328:1-328:13`, the next head.**
   CONFIRMED: present in `ct4scan … visited` on the delivered database (24
   killers, was 21) and in `ct7cand`'s candidate set as
   `CAND ALL:uvm_pkg class_typespec(uvm_seed_map)@328:1-328:13`, golden null.
   Reached from the package's `Typespecs` listing, not `Elem_typespec`.
2. **R2 — `ct7cand`'s other 24 keys**, re-measured: **25 candidates total**,
   24 `class_typespec ALL:uvm_pkg` + 1 `string_typespec ALL:uvm_pkg`.
3. **R3 (escalated, F7) — cut or comment the two unreachable arms.**
4. **R4 (new, F8) — the import copy is MISSING for a package fixed-size
   unpacked array of a class type.** Golden lists it; we do not.
5. **R5 (new) — the index typespec's SPAN is wrong for a multi-dimension assoc
   array.** `grid7v/v3`: golden `string_typespec@7:10-7:16`, ours
   `@7:18-7:19` — we take the inner dimension's typespec. Instance now agrees;
   span does not. Same family as the depth-0 span residues that make up most of
   the remaining 88 census disagreements.
6. **R6 — the msdist regression (+10 / +4 / +4).** Real, disclosed, and bounded;
   any future pass quoting a small per-shape delta must pair it with an object
   census, as this one did.
7. **R7 — the `TOP:`-view instance deficit.** golden 13 184 vs ours 9 887;
   `enum_typespec TOP:uvm_pkg` 390 vs 12. Untouched, and it is why R6's
   arithmetic points the wrong way.
8. **R8 — `ct7mut` judges movement by the `m_failedRhs` POINTER** and
   under-counts. Judge by `(r, failedLhs, failedRhs, visited)`. As reported.
9. **R9 — gdb frame names are untrustworthy in this build** (§4a / R6 of the
   delivery). Not independently re-derived here; carried forward.

---

## 6. WHAT THE VERIFIER ADDED

`grid7v/v1_fixedarray_elem_import.sv`, `grid7v/v2_packed_elem_import.sv`,
`grid7v/v3_assoc_of_array_import.sv` — three cells written to attack the two
weakest points in the delivery: whether the law generalises past the three cells
that were fitted to it (F6: **it does**), and whether the two unexercised code
arms can be fired at all (F7: **they cannot**). `v1` found a new defect (F8) as
a side effect. Run them exactly like the delivered grid:

```sh
SLANG_UHDM=<bin> ./ct7arm.sh grid7v/v2_packed_elem_import.sv /tmp/wd
CT7POP=<ct7pop> ...   # then score both databases with ct7pop / ct7pkgsub
```

---

## 7. DELIVERABLE

`/tmp/r10sd7.verified.patch` — `git diff` vs `f0d93e1`, `src/ModuleEmit.cpp`
(**unchanged from the delivered patch, +77 −1**) plus
`tools/probe/r10sd7repro/`, now including this file and `grid7v/`. All sweep
workdirs deleted.
