# r10v62 — ADVERSARIAL VERIFICATION of r10earl62 (§ defBodyTypedefSiteShare62)

**VERDICT: ACCEPT.**  Every headline number in the implementer's report
reproduced bit-for-bit from independently built binaries, and eleven new
adversarial grids — including the two shapes the implementer's own grids never
touched (a **param-dependent typedef width** and **param-dependent enum
constant values**) — produced **zero AWAY-GOLDEN cells** and **zero
pristine-right → patched-wrong** on legal SV.

Binaries built here, frozen at `/tmp/v62_bin/{pris,pat}.bin`:
pristine `9aefca44d0a994e7ba84e5bfc5c8c6cc`, patched `bea968278278c25e502eda308f26723f`
— **identical to the implementer's claimed md5s.**

---

## 1. What this directory adds that the pass did not have

| file | why it exists |
|---|---|
| `vwide62.sh` | **RECURSIVE** wide boundary.  The shipped `vbndall62.sh` globs `"$ROOT"/*/*.sv` — depth 2 only — and therefore swept **1,084 of the tree's 2,758 arms**.  1,674 arms at depth ≥ 3 (`r10vrgg3repro/w1_member_kinds/dut.sv`, all of `r10vrgg8repro/cells/*/`, …) were NEVER MEASURED.  This one uses `find`, reads the list on fd 3, runs children `</dev/null`, records rc per (arm, view, side) and asserts PROCESSED. |
| `vdir62.sh` | **PER-DIRECTORY MULTI-FILE** boundary: every probe directory compiled as ONE `--single-unit`, both views, both binaries.  A per-file sweep cannot reach a pkg+dut or iface+user arm. |
| `v62cen.cpp` | WHOLE-DATABASE census via `Serializer::AllObjects()` — every `ref_obj`/`ref_var`/`ref_typespec`/variable/net in the DB, not just the ones under a `cont_assign` (`cacen62`) or on a module's `Variables()` (`mlts62`).  Payload is Compare-visible only (Actual kind + `VpiName`). |
| `run62.sh`, `dist62.sh` | one-arm × both-binaries × both-views driver, and the L1 multiset distance to golden (a signed scalar per arm, so "improved" is a number and not an impression). |
| the `.sv` arms | see §3. |

Usage: `PROBE_ROOT=<wt>/tools/probe PATCHED_BIN=… PRISTINE_BIN=… bash vwide62.sh <list> <outprefix>`;
`ARM62=<wt>/tools/probe/r10earl62repro/arm62.sh bash run62.sh <arm.sv>`.

---

## 2. Reproduction of every headline number

| claim | reproduced |
|---|---|
| md5 pristine / patched | **YES**, both exact |
| Earlgrey default 19 → 64 cmp lines, 1 head | **YES** |
| Earlgrey testflags 37 → 64 cmp lines, 1 head | **YES** |
| the two patched logs are `cmp -s` identical | **YES** |
| pristine heads = `enum_const (OpRead)` id 191246 / `typespec_member (error)` id 191252 | **YES**, both quoted from my own run |
| new head = `param_assign` Rhs constant `prim_ram_1p_adv.sv:32:41`, golden `INT:14` ct 7 vs ours `BIN:…1110` ct 3 | **YES** |
| `cacen62` cont_assign census: default TO-GOLDEN **10** / 0 / 0, testflags **14** / 0 / 0 | **YES**, cell-for-cell, including the `L219:10` PLAIN-cont_assign key that refutes the brief's "assignment-pattern member value" framing |
| `mlts62` signal-typespec census: **64** / 0 / 0 both modes | **YES**, and the reachable-tree line count is 36163 for golden, pristine AND patched |
| goldens 23 PASS / 0 FAIL (patched **and** pristine); `/bin/false` → 0 PASS / 23 FAIL | **YES** |
| surelog whole-row gate vs committed `results/golden_surelog.csv` | **PASS, 0 differing rows**, for BOTH binaries (status AND dump column) |
| surelog histogram 936 CMP_EQUAL / 20 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM | **YES**, byte-identical pristine vs patched |
| u2r testflags + default whole-row gate | **PASS**, 679/50/2 both modes, vs committed baseline AND vs my pristine sweep |
| u2r movers 2/1358 = `genvar_iface_struct` both modes, TO-GOLDEN=2 / 0 / 0, row stays CMP_EQUAL | **YES**, exact |
| canaries `ok=52` / `ok=8`, changed=0; ctcan2 PASS/PASS; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **YES** |
| protected DBs: InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | **YES**, both modes |
| rowheads unchanged except Earlgrey 19/37 → 64/64 | **YES** |
| `cmds.txt` audited by absolute binary path | **YES** — u2r 1458/1462 and surelog 1523/1573 name the frozen binary; the rest have no `slang:` line.  Audited **file-by-file** (`grep -h` over every `cmds.txt`, unique-set = exactly one path per workdir), not `find | head -1`. |
| surelog movers 2/956 | **3 raw, 2 real** — see §5. |

---

## 3. BREAKING THE LAW — eleven new grids, all measured against Surelog

`TO/AWAY/STILL` = the sectioned (DEF+ELAB, no `weaklyReferenced` tail),
path-normalised, indent-stripped 3-way line multiset (`sect3way62.sh`).
`L1` = total multiset distance to golden, pristine → patched.

| arm | what it attacks | plain | elab | AWAY | L1 |
|---|---|---|---|---|---|
| `v62a_pwidth.sv` | **PARAM-DEPENDENT typedef WIDTHS** (`logic [W-1:0] w_t`, `[W-1:0] a` struct member) across two specializations | FAIL→FAIL | FAIL→FAIL | **5 (judge-invisible, §4)** | 12→10, 30→26 |
| `v62b_penum.sv` | **PARAM-DEPENDENT enum CONSTANT VALUES and base width** (`enum logic[EW-1:0] {VA=P,…}`), P=1/EW=2 vs P=4/EW=4 | FAIL→FAIL | FAIL→FAIL | **0** | 25→17, 27→17 |
| `v62c_carriers.sv` | net decl-init, var decl-init, procedural, `wire r_t` NET of the typedef, unpacked array, function arg, THREE specializations | FAIL→FAIL | FAIL→FAIL | **0** (plain shows one aggregate `vpiActual` cell; decomposed in §4) | 293→275, 436→402 |
| `v62d_iface.sv` | **INTERFACE-local** param-dependent typedef, 2 instances, hier read through a modport | FAIL→FAIL | FAIL→FAIL | **0** | 88→84, 106→102 |
| `v62e_bind.sv` | **every enum-read carrier**: initial, always_ff, case labels, function, task, localparam/parameter initializer, `inside`, cast — 3 specializations | PASS→PASS | **FAIL→PASS** | **0** | 197→193, 546→514 |
| `v62f_typeuse.sv` | typedef as function return, task arg, chained alias, `typedef t_t t_arr_t[0:1]`, nested typedef, child port actual | FAIL→FAIL | FAIL→FAIL | **0** | 180→176, 380→368 |
| `incarm/v62g_include.sv` | **the same typedef TEXT `` `include ``d into TWO DIFFERENT modules** — the sharpest attack: if slang gave both expansions one SyntaxNode the patch would key two DesignComponents' typedefs to ONE object, which Surelog never does | **FAIL→PASS** | **FAIL→PASS** | **0** | converts |
| `v62h_assoc.sv` | the `isSharedAliasTs` hole (§6): module-local typedef as an **associative-array INDEX TYPE** and array element, 2 specializations | FAIL→FAIL | FAIL→FAIL | **0**; all 24 `idx_t` typespec occurrences keep the typedef's own span `11:11-11:22` — **no stamping** | 57→53, 63→57 |
| `v62i_nobind.sv` | **§ enumNoBind13 / LAW C**: module-local enum read from an in-body class method (condition, arg, write) inside a multiply-specialized module — must stay BARE | **FAIL→PASS** | **FAIL→PASS** | **0**, and `vpiActual` lands **exactly** on golden (105/157) | 24→20, 250→244 |
| `v62j_genfor.sv` | six specializations minted by a **generate-for** with a per-iteration parameter, plus a nested `mid62` wrapper | FAIL→FAIL | FAIL→FAIL | **0** | **20→4**, **28→4** |
| `mf/` (3 files) | **MULTI-FILE**: package in one file, the multiply-specialized module def in a second, the instantiations in a third | **FAIL→PASS** | **FAIL→PASS** | **0** | 10→2, 14→2 |

Plus the implementer's own three grids, re-run here: `g1` PASS→PASS (plain) and
**FAIL→PASS** (elab, 37 lines → 0 — the README calls g1 "measured EQUAL", which
was true of the PLAIN view only); `g2` **FAIL→PASS in BOTH views** (19 and 37
lines → 0); `g3` FAIL→FAIL with `TO=6 AWAY=0` both views.

**Not one arm regressed.  Every arm's L1 distance to golden strictly decreased.**

### 3.1 The law survives its hardest case — independently confirmed on golden

`mlts62` on my own Surelog databases prints the object ids:

```
v62a (typedef WIDTH depends on W):
  TS DEF  work@pw62                 OWNTS logic_typespec:w_t   id=18
  TS ELAB work@top62a.u_a (W=8)     OWNTS logic_typespec:w_t   id=18
  TS ELAB work@top62a.u_b (W=16)    OWNTS logic_typespec:w_t   id=18
v62b (enum VALUES depend on P, base width on EW):
  TS DEF  work@pe62                 OWNTS enum_typespec:ve_t   id=19
  TS ELAB work@top62b2.u_a (P=1,EW=2) OWNTS enum_typespec:ve_t id=19  VAR struct_typespec:vs_t id=46 vv
  TS ELAB work@top62b2.u_b (P=4,EW=4) OWNTS enum_typespec:ve_t id=19  VAR struct_typespec:vs_t id=46 vv
```

Surelog shares **one** object across specializations **even when the typedef's
width and the enum's constant values are parameter-dependent** — because it
keeps those ranges and values SYMBOLIC in the definition (`\_ref_obj: (w_t.W)`,
`vpiDecompile:P + 1`).  § defBodyTypedefSiteShare62 is right in the hardest case
the pass never tested.

---

## 4. The three AWAY-GOLDEN readings, decomposed (none is a regression)

1. **`v62a`, 5 cells, both views.**  All five are one fact: the shared
   `w_t` typespec's range operand `\_ref_obj: (…W)` reparents from
   `work@pw62.w_t.W` to `w_t.W`, taking a `|vpiFullName:` and one `|vpiParent:`
   line with it.  **No generated `Compare` reads `VpiParent` or `VpiFullName`**
   (RESUME §9), and the judge agrees: the two cmp logs differ only in
   `id:461`→`id:458` at the SAME slot, the head is the pre-existing
   `range` fold (`operation W-1` vs our folded `INT:7`) on BOTH binaries.
2. **`v62c` plain, 1 cell:** `|vpiActual:` 215 / 215 / 217 — an AGGREGATE
   label line with no payload.  In the same arm the patch converts three
   `struct_net` → `struct_var` (golden: `struct_var`) and clears four
   `logic_typespec:` — pristine's 215 was a coincidence of composition, not a
   correct value.  `cmp` logs pristine vs patched are **IDENTICAL**.
3. **Earlgrey testflags, 2 cells** in the whole-DB `v62cen` census
   (`enum_var st_d/st_q @prim_generic_flash.sv:50` 4/4/8).  These live in the
   **unreachable** serializer population: our DB already carries 8 `st_d`
   objects where golden has 4 (and 14 `ref_obj st_q` where golden has 2) —
   pristine split them 4 named + 4 nameless, patched names all 8.  The
   **reachable** count is identical for golden, pristine and patched
   (`mlts62`: 162 `st_d`/`st_q` lines, 1 `drv` line, 36163 total, all three).
   The same holds for `drv @prim_generic_pad_wrapper.sv:24` (a MODULE-level
   `typedef enum … drv_e` in the Earlgrey_0_1 copy of that file — the gen-scope
   version lives in a different tree and is out of the patch's reach as the
   fence claims: `emitTypedefs` walks `body.members()` and never recurses into
   a generate block).

---

## 5. Movers, boundary, and the arms the pass never swept

**Surelog byteverify: 3 raw movers, not 2.**  The third is
`default/Scoreboard-59431470` — the documented ~50/50 COIN.  Attributed
ORDER-BLIND as §9 requires: both dumps sorted, **0 differing lines** over
1,099,517 lines.  Real movers = 2 = `Earlgrey_0_1` default + testflags, the
target.  (A verifier that reports "2 movers" without doing this has not
measured; a run that happens to see 2 is luck.)

**Recursive wide boundary (`vwide62.sh`), 2,758 arms — 2.5× the shipped sweep:**

```
PROCESSED=2758  identical=5249  DIFFERING=12  no_output=255
signals rc=139: A(patched)=7  B(pristine)=7   <-- SYMMETRIC, all pre-existing
  r10buvm8repro/v21shadow8.sv, r10buvm8repro/vshadowcells8/v21_s9.sv,
  r10uvm84repro/v84x8_break.sv, r10uvm87repro/v87_a4_scope.sv,
  r10vrgg8repro/cells/{v8_recurse,v8_recurse_mutual,v8_recurse_uncond}/dut.sv
```

The 12 differing entries are 6 arms × 2 views:

| arm | disclosed by the pass? | measured vs Surelog |
|---|---|---|
| `r10earl62repro/g1,g2,g3_earl62.sv` | yes | the witnesses |
| `r10earl59repro/v59w2_shapes59.sv` | yes | **confirmed exactly**: `TO=4 AWAY=0 STILL=1` both views; `en_t` 9→10 vs golden 11; cmp log **IDENTICAL** to pristine (CMP_FAIL, 1 head, 45 lines) and the `vpiActual` count is unchanged, so earl59's binder cells are untouched |
| `r10vrgg3repro/w1_member_kinds/dut.sv` | **NO — depth 3, invisible to `*/*.sv`** | `TO=4 AWAY=0 STILL=0` both views; `struct_typespec:(st_t)` 9→13 = golden, `logic_typespec:(word_t)` 8→12 = golden, two nameless `logic_typespec` cleared; **cmp log IDENTICAL**; L1 117→101 |
| `r10vrgg3repro/w2_member_enum_string_real/dut.sv` | **NO — depth 3** | `TO=2 AWAY=0 STILL=0` both views; `enum_typespec:(e_t)` 10→14 = golden, nameless cleared; **cmp log IDENTICAL**; L1 44→36 |

**Per-directory multi-file boundary (`vdir62.sh`), 1,289 directories:**

```
PROCESSED=1289  identical=2339  DIFFERING=7  no_output=232
```

Six of the seven are the four arms above.  The seventh is
**`r10uvm88repro` (elab)** — a UVM-family directory the brief protects.  It is
**the ORDER COIN, not a mover**: the difference is 4 lines, a `vpiTaskFunc`
list-position flip on `p3::base3::oob_base`; the order-blind (sorted) diff is
**0 lines**, and four fresh runs per binary all produce the SAME normalised
dump md5 `13a6f965cea1` on BOTH binaries.

---

## 6. Ranked residues found by this verification

* **R-V1 — the law is only HALF applied: `sharedAliasTs` / `isSharedAliasTs`
  were not extended to the site key.**  Both resolve `typedefTs.find(&t)` on the
  CURRENT specialization's `TypeAliasType` (`src/UhdmExporter.cpp:1833` and
  `:1843`), which misses for exactly the declarations § defBodyTypedefSiteShare62
  exists to serve.  Two consequences, both measured:
  (a) the four § sharedAliasNoStamp41 no-stamp sites (`UhdmExporter.cpp:2442`
  and `:2482`, `TypeEmit.cpp:15918`, `ParamEmit.cpp:21865`) judge a
  site-shared object "fresh" — a latent licence to RE-SPAN and RE-INSTANCE the
  DEF's object that every instance points at.  `v62h_assoc.sv` proves it does
  not fire TODAY, because `assocIndexTs` reaches the registry through
  `sharedAliasTs`, which also misses, so the shared object never arrives at
  those sites at all;
  (b) the same miss means an associative INDEX or array ELEMENT typed by a
  module-local typedef in a second specialization still gets a fresh
  `logic_typespec` — the law's own shape, unconverted.  Extending both
  functions with the site key is the natural next pass, and it MUST be done
  together with (a) or the no-stamp guard opens.
* **R-V2 — value encoding of a param-dependent shared enum constant.**
  `v62b`: golden's shared `enum_const VB` carries `vpiDecompile:P + 1`,
  `UINT:0` (SYMBOLIC — which is *why* one object can serve every
  specialization); we carry the def specialization's FOLDED value (`INT:1`,
  decompile `P`).  Pre-existing on both binaries, but the patch now propagates
  that one folded value to every specialization, so it is the same family as
  this pass's new R0 head (`param_assign` Rhs `INT:14` vs `BIN:…1110`).
  Fixing R0's encoding family should be measured on `v62b` too.
* **R-V3 — the shipped wide-boundary instrument under-covers by 61 %.**
  `vbndall62.sh`'s `"$ROOT"/*/*.sv` reached 1,084 of 2,758 arms; two real
  movers sat in the unreached 1,674.  It also hardcodes
  `ROOT=${PROBE_ROOT:-/tmp/wt_r10earl62/tools/probe}` — a path that dies with
  the pass's worktree.  Use `vwide62.sh` + `vdir62.sh` from here on.
* **R-V4 — `v62f`**: `typedef t_t t_arr_t [0:1]; t_arr_t d;` emits a
  `logic_net` where golden emits an array; the patch makes one more copy of the
  wrong object (`golden=0 pristine=2 patched=3`, STILL-WRONG, judge-invisible —
  cmp logs identical).  Same family as the pass's own R3.
* The pass's R1 (gen-scope CA reading a module-local enum), R2 (`en_t` 9→10 on
  `v59w2`) and R3 (unpacked array of a module-local struct) are all confirmed
  here unchanged.
