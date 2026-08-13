# r10sd2 — VERIFIER REPORT (adversarial)

**VERDICT: PASS (with findings).**

The pass ships **zero production change**, and I confirmed that independently
rather than accepting it: I created my own worktree at `6e1c27a`, applied
`/tmp/r10sd2.patch`, ran a **fresh `cmake` configure**, built, and got md5
**`f1fee994fffdfc1e2d7883d791e1621f`** — the same 32 hex the implementer claims
for both of its worktrees. So "0 movers" is an identity, not a measurement, and
no gate can fail for a code reason.

Everything load-bearing reproduced. The central refutation is **correct**: the
brief's package-vector law is false, and coding to the brief would have edited
correct code. Seven findings follow; **F1–F3 are real defects in the record**,
none of which changes the verdict, because none touches a gate and the pass's
own conclusions survive them. F3 is the one the next pass should act on.

| | |
|---|---|
| verifier worktree | `/tmp/wt_r10sd2v` (fresh `6e1c27a`, patch applied, own cmake configure) |
| my binary md5 | `f1fee994fffdfc1e2d7883d791e1621f` |
| implementer delivered / pristine | `f1fee994…` / `f1fee994…` — **all three byte-identical** |
| patch md5 | `3274429c8a8031f515d7f603eb624779` (as claimed) |
| production files touched | **NONE** (`git diff 6e1c27a -- include src uhdm_main.cpp CMakeLists.txt share` = 0 lines) |

---

## 1. FINDINGS

### F1 — the §1 law's count is WRONG on two of the four designs (record says 214, actual **216**)

`README.md` §1.1 and the summary state the `class_defn`-valued `vpiInstance`
population as **428 / 214 / 214 / 203**. SeqDriver (428) and BuildUVMPkg (203)
are exact. **SimpleUVM and Scoreboard are 216, not 214.**

```sh
# 3 reps, freshly emitted, plus the sweep artifact — all agree
/tmp/r10sd2v_ct2view <golden> <ours> 0 | grep class_defn | awk '{s+=$3} END{print s}'
#   SimpleUVM  rep1/rep2/sweep = 216 216 216   (slang.uhdm byte-identical across reps)
#   Scoreboard rep1/rep2/rep3  = 216 216 216
```

The breakdown sums to 216 over 19 class names on both. Note `428 / 2 = 214`
exactly, and SeqDriver's per-class figures are *almost* twice SimpleUVM's — the
one exception being `uvm_tlm_generic_payload` (4 on both, not 8/4). That is the
signature of a number **derived by halving SeqDriver** rather than read off its
own census, which is precisely what "per-shape or nothing" forbids. The law's
substance is untouched: **golden is 0 on all four**, which is the claim that
matters.

### F2 — the mutation that retires the pass's headline law is NOT reproducible from the delivered instruments

`README.md` §4.4 hypothesis 1 — *"Nulling all 428 of them: head byte-identical …
The §1 law is real and is NOT the head"* — is the argument that demotes §1 from
"the head" to residue R2 and justifies shipping it unfixed. It selects by the
**value's** type (`class_defn`). The shipped `ct2mut.cpp` selects by the
**owner's** type (`bit_typespec`, `class_typespec`, …) and cannot express it:

```sh
cd tools/probe/r10sd2repro && grep -rl 'class_defn' . | grep -v README
#   grid/p6_class_in_pkg.sv   (a source comment)
#   dumptree.py               (generic printer)
# -> NO instrument performs the mutation the claim rests on.
```

I wrote the missing instrument (`ct2vclsdefn.cpp`, added by this verification)
and **the claim is TRUE**:

```
BASELINE                            r=-1  LHS=<null>  RHS=package(uvm_pkg)@28:1-39:11
class_defn-valued Instance() slots on OUR side: 428  (typespec=428 task_func=0 variables=0)  over 19 class names
NULLED all class_defn-valued        r=-1  LHS=<null>  RHS=package(uvm_pkg)@28:1-39:11
RESTORED (must equal BASELINE)      r=-1  LHS=<null>  RHS=package(uvm_pkg)@28:1-39:11
```

This also confirms §1's "owner is always a `typespec` (`variables`=0,
`task_func`=0)" exactly. The tool refuses to report on a 0-slot selection, so the
"no change" reading cannot be vacuous. Finding stands as a **record defect, not a
substantive one**: the conclusion was right and is now reproducible.

### F3 — an UNREPORTED design-object divergence on 3 of the 7 live UVM rows (act on this)

`ct2pkgv.cpp` prints the `design` line *above* the package vectors on every run.
The analysis filtered it out (`grep -E 'Packages'`), and it carries a real
divergence that appears **nowhere** in the record — `grep -c 'Param_assigns'
README.md` = **0**:

| row | golden `design.Param_assigns` / `Parameters` / `Typespecs` | ours |
|---|---|---|
| `default/SimpleUVM` | 45 / 45 / 123 | **NULL / NULL / 89** |
| `testflags/SimpleUVM` | 45 / 45 / 123 | **NULL / NULL / 89** |
| `default/Scoreboard` | 45 / 45 / 125 | **NULL / NULL / 91** |
| SeqDriver, BuildUVMPkg | NULL / NULL / NULL | same — no divergence |

`ct2design` names it outright: `design.Param_assigns: golden=45 ours=-1  <--
SIZE MISMATCH`. This is exactly the **uvm67 residue-2 family** (`$unit`-import
materialisation onto the DESIGN object: `design.Parameters` /
`Param_assigns` / `Typespecs`) that the brief instructed the pass to *read
FIRST*. The record reaches that family only through the synthetic `p4` grid cell
(R5) and never notices it is **live on three real corpus rows**.

It is currently **masked**, which is why no head shows it — `design::Compare`
order (generated `design.cpp`) reaches `AllModules` at line 302, before
`Typespecs` (303) and `Parameters`/`Param_assigns` (306/307), and
SimpleUVM/Scoreboard both fail inside `AllModules`. It becomes the head the
moment their `func_call`/`method_func_call` head clears. **This is the highest-
value thing this verification found**, and it belongs in the residue ranking.

Independently, `ct2design` on SeqDriver surfaces a second unreported shape:
`design.TopPackages[2] r=-3 lhs=class_var(access_record)@483:34` vs
`rhs=struct_var@483:34` in `class_defn(uvm_resource_base)` — a `class_var` /
`struct_var` divergence (fresh-context view, so reach not location).

### F4 — OPS: `verify_golden.py` silently defaults `SLANG_UHDM` to the MAIN-TREE binary

My first u2r sweep ran the **main-tree** binary, not my worktree build, because
the harness defaults `SLANG_UHDM` (the trap `ct2arm.sh`'s own header warns
about). I caught it by reading `cmds.txt` and re-ran every sweep pinned.

It was harmless **only by luck**: at the moment I checked, the main tree's binary
was itself a BASE build (`md5 f1fee994…`), because the live pass's edits were
uncommitted **and not compiled in**. The record never states that its own sweeps
pinned `SLANG_UHDM`; its own conclusions are unaffected either way, since all
three binaries in play were the same 32 hex.

**This is a standing hazard, not a one-off.** The main tree carried uncompiled
edits for the whole of this verification and still does (`r10earl40`'s landed as
`681f4c0` mid-run; `r10uvm69` now holds `src/ExprEmit.cpp` uncommitted). Any
unpinned sweep silently picks up whatever the main tree last built — and can
change binaries *mid-run* if a live pass rebuilds. Every sweep in this report was
pinned to my worktree binary and **verified pinned by reading `cmds.txt`**, which
is the only way to detect it after the fact.

### F5 — the boundary statement swaps the two live passes' file sets

`README.md` §9 says `r10uvm69` is "`TaskFuncEmit.cpp` territory" and `r10earl40`
is "`ExprEmit.cpp`". **Both are wrong, and this is now provable rather than a
snapshot read:** `r10earl40` **landed during this verification** as `681f4c0`,
and the commit touches `include/UhdmExporter.h` and `src/TypeEmit.cpp` — not
`ExprEmit.cpp`:

```sh
git diff --stat 6e1c27a..681f4c0 -- include src
#   include/UhdmExporter.h |  8 +++++
#   src/TypeEmit.cpp       | 95 ++++++++++++++++++++++++++++++++++++++++++++++++--
```

`src/ExprEmit.cpp` is what the *next* live pass (`r10uvm69`) is currently
editing in the main tree. So the record attributes each pass the other's file.
The **conclusion is unaffected** — the patch's file set is
`tools/probe/r10sd2repro/` alone, so the intersection is empty against any of
them — but §7 R2 defers fixing the `class_defn` `vpiInstance` sites partly
*because* `TaskFuncEmit.cpp` is said to be inside `r10uvm69`'s file set, and
that premise is not established. The blast-radius argument for deferring R2
still stands on its own; the file-collision half of it does not.

**Integration note.** `HEAD` moved from `6e1c27a` to `681f4c0` while I was
verifying. Every gate in this report was run against `6e1c27a` — the patch's
stated BASE — with that commit's `results/*.csv`, so it is internally
consistent. I re-checked the delivered patch against the new head: `git apply
--check` on a fresh `681f4c0` worktree is **rc=0, applies clean**. An integrator
landing on `681f4c0` inherits `r10earl40`'s changes and should re-run the gates
there; nothing in this probe-only patch can interact with them.

### F6 — minor: §1.1's table drops a control row

The table shows `OTHER:design()` for SimpleUVM/Scoreboard but "—" for SeqDriver,
and omits `OTHER:module_inst(work@top_tb) 1 / 1` (SeqDriver), `module_inst(dut)`
and `module_inst(work@top)` (SimpleUVM), `module_inst() 4/4` (Scoreboard). These
are equal on both sides and *strengthen* the law (they are the "vpiInstance does
name real instance scopes" control), so the omission understates the evidence.

### F7 — minor: sd1's grid reads `SAME=24` here vs the `SAME=23` sd1 recorded

Benign and recorded so a future pass does not read it as drift — see §3.

---

## 2. WHAT REPRODUCED EXACTLY

Every number below was re-measured, not accepted.

**The central refutation (the record's own attack item 1) — CONFIRMED.** All 7
live UVM rows, both modes, **at full field depth** (every one of the 25 vectors
`package::Compare` walks, NULL distinguished from empty, spans, `vpiTop`,
parent), `VpiFile` excluded because ours is empty (R7):

```
default/SeqDriver    VECTORS-ONLY IDENTICAL (8 lines)
default/SimpleUVM    VECTORS-ONLY IDENTICAL (6 lines)
default/Scoreboard   VECTORS-ONLY IDENTICAL (8 lines)
default/BuildUVMPkg  VECTORS-ONLY IDENTICAL (6 lines)
testflags/SeqDriver  VECTORS-ONLY IDENTICAL (8 lines)
testflags/SimpleUVM  VECTORS-ONLY IDENTICAL (6 lines)
testflags/BuildUVMPkg VECTORS-ONLY IDENTICAL (6 lines)
(testflags/Scoreboard SLANG_REJECT, no database — correctly skipped)
```

The 8/6 line counts match the record's own `(8 lines)`/`(6 lines)` exactly.
SeqDriver's per-entry figures match cell for cell, `AllPackages[1].Class_defns`
NULL and `TopPackages[1].Class_defns=323` included. **The brief's law is FALSE
and the pass was right to refuse it.**

**The head.** `LHS: <null>` / `RHS: package uvm_pkg`, `vpiParent design
(work@top_tb) id:1`, `grep -c '^LHS:'` = **1**, **1414861** lines on *both*
SeqDriver rows (`id:6032` default, `id:6044` testflags) — exact. `ct2design`
puts it at `design.AllPackages[1]` with `golden=3 ours=3`, so the vector-size arm
is ruled out by measurement. `design::Compare` order confirms `AllPackages` (296)
is the first vector after the base type, so the head is reached where claimed.

**The other rows' heads — all exact**, and the record is right that they moved
since the brief: SimpleUVM/Scoreboard **112** on
`func_call(open_recorder)@343:13-343:61` vs
`method_func_call(m_do_open)@343:27-343:36`; BuildUVMPkg **58** on
`ref_obj(…uvm_deferred_init)` vs `hier_path(…push_back)@14107`.

**The §1 law.** SeqDriver **428 over 19 class names, golden 0** — every
per-class figure in the record's prose matches (`uvm_mem` 80, `uvm_reg` 68,
`uvm_vreg` 52, `uvm_reg_map` 48, `uvm_reg_field` 36, `uvm_vreg_field` 32,
`uvm_phase`/`uvm_reg_file` 20, `uvm_mem_mam`/`uvm_transaction` 12,
`uvm_component`/`uvm_packer`/`uvm_printer` 8, and six at 4). `<null>`,
`ALL:`/`TOP:` and `adpcm_pkg` totals match on all four designs. BuildUVMPkg 203
exact. (SimpleUVM/Scoreboard: see F1.)

**I strengthened the law beyond what the pass claimed** (its own attack item 4 —
"a law whose zero has only been checked on one design family is a law with one
witness"). Golden's zero holds on **26 corpus-wide golden databases** sampled
across the whole 3727-entry golden cache, plus the non-UVM `p6` arm:

```
---- GOLDEN databases sampled=26 | class_defn-valued vpiInstance == 0 in 26 | NONZERO in 0
```

**§4.4 hypothesis 2 — exact.** Every count the record cites, with the arm flip:
`bit_typespec` 1085, `class_typespec` 2163, `string_typespec` 3008,
`enum_typespec` 78, `logic_typespec` 146 all flip to `r=1 LHS=package RHS=<null>`;
`RESTORED` reprints `BASELINE` byte for byte. The mutation probe is real and its
control works.

**`m_visited` (attack item 3) — CONFIRMED keyed on LHS alone.** Generated
`package::Compare` opens `if (!context->m_visited.insert(this).second) return r;`
— `this` is the LHS. The suppression-operator semantics every §4.3 localization
depends on is sound. `SafeCompare`'s four arms match the record's quote verbatim
in `~/.local/include/uhdm/BaseClass.h`.

**The grid — exact, cell for cell**, including the three failing arms'
`PASS_CMP`/cmp-line counts (`p4` 353, `p5` 91, `p6` 130) and dump figures
(`p3` 12, `p4` 294, `p5` 16, `p6` 5). `p5` really does prove **declaration**
order: golden lists `builtin, p5b, p5a` with the never-imported `p5b` first.

**`msdist` — exact.** golden 1970508 / ours 1807412 dump lines, golden-only
264498, ours-only 101402, **MULTISET DISTANCE 365900**.

---

## 3. EMPTY PRODUCT HUNT — clean, and checked mechanically

The grid driver only *prints* both sides and greps `name=`; the record's "SAME"
verdicts are an eyeball read. I re-ran the comparison **mechanically at full
field depth** and it holds. Non-vacuity, per the record's own attack item 6:

- **All 6 cells carry ≥ 2 package objects per vector on the thinner side**
  (`builtin` + the cell's own package; `p5` carries 3), on **both** sides. No
  `SAME` costs nothing.
- **No cell `SURELOG_FAIL`s** — all six produce both a golden and an ours
  database (`ct2arm.sh` exits 5/7 otherwise, and did not).
- `ct2pkgv` censuses 7–9 real lines per arm and 9 on SeqDriver; `ct2view` keys
  golden=20397 / ours=18722; `ct8rows` compares 731 and 1588 real rows;
  `canaudit` audits 29 names and hard-fails at 0; `ct2vclsdefn` refuses a
  0-slot selection. None of the green readings is an empty product.

**One genuine empty-product-adjacent defect did surface — F3**: a divergence the
instrument printed on every run and the analysis filtered away. That is the
failure mode this hunt exists for, and it was found in the *design* line rather
than in a grid cell.

**sd1's b1–b28 grid HOLDS** — I ran it rather than accepting "by construction":

```
--- cells=28  golden-PA-cells=11  ours-PA-cells=7  SAME=24 DIFF=4 FAILED=0
```

The 4 DIFF cells are **exactly** sd1's recorded residues — `b4_modtd`,
`b15_pkgtd_foreign`, `b16_modtd_foreign` (R3) and `b25_inline_pkgvar_own` (R4).
**Zero new DIFF cells, zero SAME→DIFF regressions.** sd1 recorded `SAME=23
DIFF=4` (27 of 28); I read `SAME=24 DIFF=4 FAILED=0` (F7) — one more cell
*passing*, never a regression.

**Live-pass boundaries: no collision.** The patch's file set is
`tools/probe/r10sd2repro/` alone, so the intersection is **empty** against every
candidate file set — `r10earl40`'s actual one (`include/UhdmExporter.h`,
`src/TypeEmit.cpp`, now landed as `681f4c0`), `r10uvm69`'s current one
(`src/ExprEmit.cpp`, uncommitted in the main tree), and the two the record names
(see F5). A probe-only patch cannot collide with any of them.
`§ classTdSpecParamsForeignHome1`'s `UhdmExporter.cpp ~2682` `home1` gates are
present and unmodified.

---

## 4. THE FIVE GATES, RUN INDEPENDENTLY

| gate | measured by me | verdict |
|---|---|---|
| **1 BUILD** | fresh worktree at `6e1c27a`, own cmake configure, absolute path, **link line waited for** (`Linking CXX executable slang-uhdm` → `Built target slang_uhdm`), `errors: 0`; `git rev-parse` grep-checked in all three worktrees; md5 asserted separately = `f1fee994fffdfc1e2d7883d791e1621f`, **equal to both implementer binaries** | **PASS** |
| **2 GOLDENS** | **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** | **PASS** |
| **3 u2r** | testflags `--jobs 2`, own out/workdir: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `ct8rows` **0 differing ROWS**, histograms identical | **PASS** |
| **4 surelog** | both modes `--jobs 2`: default **469 / 11** (SURELOG_FAIL 25, DEFERRED 5, SLANG_REJECT 284); testflags **465 / 8** (23, 5, 286, +3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM); `ct8rows` **0 differing ROWS**, **all 4 dump histograms identical** | **PASS** |
| **5 BYTE VERIFIER** | see below | **PASS** |

`GOLDEN_DEFER` **[UNSET]** and verified unset; every sweep `--jobs 2` with
private `--out`/`--workdir`; `results/*.csv` read-only; no `git stash`; every
sweep's binary verified from `cmds.txt` (F4).

**Gate 5.** The delivered and pristine binaries are **the same file**, and I
established that by building it myself rather than by trusting the claim, so a
patch-caused mover is structurally impossible. I ran **two independent pinned
`surelog` both-mode sweeps** into separate workdirs and byte-compared them with
`byteverify.sh`, both controls included:

```
databases: patched=953 pristine=953
PATH_SETS_IDENTICAL (953 paths)
MOVER ./default/Scoreboard-59431470/slang.uhdm  patched=4e325679f075 pristine=da1eeb8b9000
MOVERS: 1 / 953
SELFCHECK  (every file vs one fixed file): 952 / 953 flagged
SELFCHECK1 (one file corrupted, expected 1 + real movers): 2
CSVs, A vs B: IDENTICAL
```

Every figure matches the record, **including the two Scoreboard hashes it
reports** (`da1eeb8b9000` / `4e325679f075`) — reproduced from my own binary on
my own sweeps. The mover is size-equal and therefore the flake. I also measured
per-row determinism directly on the rows that matter:

- `default/SeqDriver` — **byte-identical** across reps and identical to the
  sweep artifact (17960936 bytes); `testflags/SeqDriver` 17961341, as recorded.
- `SimpleUVM` — **byte-identical** across reps (`md5 dbe43f4f58dc`, 11118095 B).
- `Scoreboard` — **6 reps, 3 on each binary path**: size **constant at
  11122738** on all six, hashes varying (`4e325679f075` recurring, matching the
  record). **Size-equal ⇒ flake by the standing law**, on both binaries. This
  reproduces r10sd1-verifier F2 and confirms the record's R8: it is not
  binary-dependent at all. Read the SIZE.

**Canaries — all exact.** `canaries.sh` surelog **ok=52 changed=0 absent=0**,
unknown-names 7 (documented u2r-only); u2r **ok=8 changed=0 absent=0**,
unknown 25. `ctcan2` surelog `EXPECT_UNKNOWN=1` → **ok=58 changed=0 absent=0**
PASS; u2r `EXPECT_UNKNOWN=6` → **ok=1 changed=0 absent=0** PASS (baseline first,
mode-matched). `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** PASS. The
four fenced names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`)
are **dispatched by no driver**. `InterfaceModPort` and `BlackParrotComplex`
**OK by name**, both corpora, both modes.

**Patch hygiene.** `git apply --check` rc=0 against a fresh `6e1c27a`; applies
clean; reproduces `tools/probe/r10sd2repro/` **byte-for-byte** (`diff -r` clean
against the implementer's worktree); **1 porcelain entry**; **no production file
in the patch** (`grep '^+++ b/' | grep -v probe` = 0). The delivered
`README.verifier.md` **was THIS pass's** — an explicit, honestly-labelled
placeholder stating "NO VERIFIER HAS RUN", with an attack order; it did not
fabricate a verdict. It is replaced by this file.

---

## 5. RANKED RESIDUES (revised)

1. **R1 — the SeqDriver head, both rows, 1 414 861 lines.** Unchanged and
   correctly localized: a singular `vpiInstance` slot, NULL in golden, holding
   our **TOP-view** `uvm_pkg`, inside `class_defn(uvm_coreservice_t)`, reached
   only through `class_typespec@199:3-199:20` but by ≥ 2 disjoint routes below
   it. Needs the **set-valued ddmin**; `ct2owner.cpp` carries the operator.
2. **F3 — `design.Param_assigns` / `Parameters` / `Typespecs` NULL on our side,
   45/45/123 in golden, on `SimpleUVM` (both modes) and `Scoreboard`.**
   *Promoted above the record's own R2.* It is a live corpus divergence on 3 of
   7 UVM rows, currently masked by those rows' heads, in the uvm67 residue-2
   family the brief said to read first — and it is a **size mismatch on the
   design object**, which is the cheapest possible shape to attack. Start here.
3. **R2 — § instanceIsNeverAClassDefn2.** Real, cmp-visible, `typespec`-owned,
   golden 0 on **26 corpus goldens** (strengthened here), and proved not the
   head (now reproducibly, F2). Counts **428 / 216 / 216 / 203** (F1).
4. **R3 — the `TOP:` view carries the `vpiInstance` deficit** (`TOP:uvm_pkg`
   −4578 on SeqDriver vs `ALL:` −114; `adpcm_pkg` long on both). Reproduced
   exactly; still the most likely single mechanism behind R1.
5. **NEW — `class_var` vs `struct_var` at `access_record@483:34`** inside
   `class_defn(uvm_resource_base)`, surfaced by `ct2design` on SeqDriver's
   `TopPackages[2]`. Unreported by the pass; fresh-context view, so reach not
   location.
6. **R4 / R5 / R6** — the `p5` (91 lines, mirror arm), `p4` (353, `$unit`) and
   `p6` (130, package class method) grid cells. All three reproduce exactly and
   are genuine ready-made reproducers.
7. **R7 — `VpiFile` empty on nearly every object we emit.** Confirmed; it is why
   every census here excludes it from the key.
8. **R8 — `Scoreboard` hash-unstable, size-stable.** Confirmed on 6 reps across
   both binary paths. **Read the SIZE.**
9. **R9 — the other three rows' heads moved since the brief.** Confirmed.
10. **F4 — unpinned `SLANG_UHDM` is a standing hazard** for as long as any live
    pass holds uncompiled edits in the main tree. Pin it, then prove it was
    pinned by reading `cmds.txt`.

---

## 6. WHAT I DID NOT DO

1. I did not run the `uhdm2rtlil` byte verifier's second sweep (the `surelog`
   one I did run in full, both controls). The u2r gate and its `ct8rows` row
   diff were run, and for u2r gate 5's substance rests on the binary identity I
   rebuilt plus the per-row determinism reps above.
2. I did not close R1. The set-valued ddmin remains unwritten.
3. I did not attack `ct2owner.cpp`'s 34-chokepoint stall set object by object;
   I verified the *operator* it depends on (`m_visited` keyed on LHS) instead.
4. `folded` mode was not swept (neither target mode requires it).
5. My law-generalisation scan sampled 26 of 3727 cached goldens, chosen by size
   stride, not all of them.
