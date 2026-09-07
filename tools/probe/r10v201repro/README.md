# r10v201 — ADVERSARIAL VERIFICATION of r10uvm201 § `impFoldRhsMirrorsLhsTs201` — **ACCEPT**

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities. slang was **NOT** patched; `results/*.csv` were **READ
ONLY**; **nothing was promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER`
stayed unset. No driver here dispatches a fenced test.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table below.

BASE `e5a04255`. Fresh worktrees `/tmp/wt_v201pris` (pristine) and `/tmp/wt_v201`
(patched), both configured and built independently of the implementer's tree.

---

## 1. EVERY HEADLINE NUMBER REPRODUCED BIT-FOR-BIT

| | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `abf4d2971987e060480a7dd3baba6e68` | **`abf4d2971987e060480a7dd3baba6e68`** |
| patched binary md5 | `162d8642028fd69724c0bc621665c578` | **`162d8642028fd69724c0bc621665c578`** |
| `src/ParamEmit.cpp` md5 | `d825ea8fae5be302ab061be97cf823b3` | **`d825ea8fae5be302ab061be97cf823b3`** |
| patch applies to a FRESH `e5a04255` | yes | **`git apply --check` clean, no 3-way fallback needed** |
| production surface | `src/ParamEmit.cpp` only, +78 lines, 0 deletions | **confirmed** (`git diff --stat` vs base: 1 file, 78 insertions) |
| `results/` hunks / fence hits | 0 / 0 | **0 / 0** |
| goldens | 23 / 0 both binaries, negative control 0 / 23 | **23 / 0 / 23** |
| u2r | 679 CMP_EQUAL, 50 SLANG_REJECT, 2 SURELOG_FAIL, both modes | **identical on both binaries** |
| u2r `ct8rows` | 0 differing rows | **0**, four ways (committed baseline × patched, pristine × patched testflags AND default, baseline × pristine) |
| u2r byte movers | 0 / 1358 | **0 / 1358**, `PATH_SETS_IDENTICAL` |
| surelog rows | 1588, 0 changed vs own pristine | **0 differing rows pristine × patched**; status histogram identical (940 `CMP_EQUAL`, 16 `CMP_NOTEQUAL`, 567 `SLANG_REJECT`, 48 `SURELOG_FAIL`, 10 `DEFERRED`, 3 `NO_DATABASE`, 2 `UNTRANSLATABLE`, 1 `TIMEOUT`, 1 `NO_UHDM`) |
| surelog byte movers | 6 / 956, named | **6 / 956, exactly `{default,testflags} × {SimpleUVM, SeqDriver, MiniAmiq}`** |
| `Scoreboard/default` coin | did not flip | **did not flip** (order-blind ADDED 0 REMOVED 0) |
| head | SimpleUVM ×2 17 lines → cleared | **17 lines pristine, byte-identical to the committed `head_pris_SimpleUVM.default.cmp`; 1327654 lines patched** |
| every other row's cmp log | byte-identical | **byte-identical** (SeqDriver ×2 33, Scoreboard/default 95, MiniAmiq ×2 33, Earlgrey_0_1/default 833; BuildUVMPkg ×2, Earlgrey_0_1/testflags, Rggen/default all **0 lines, rc=0**) |
| attribution | 6 × ADDED 40 / REMOVED 0 = 240 | **240 / 0**, `RHSGAP 4→0`, `LHSGAP` unchanged on every row |
| object level (SimpleUVM/default) | +4 `int_typespec`, +4 `ref_typespec`, no other kind | **exactly that**: golden 3022/19364, pristine 3030/18575, patched 3034/18579, totals 184965 → 184973 (golden 188084) |
| boundary | `MOVED_ARMS=10 RC_DIFFS=0` over 5268 arms | **`LISTED=5280 PROCESSED=5280 PRODUCED_DBS=5095 MOVED_ARMS=21 RC_DIFFS=0`** — the same 10, plus this verifier's own 11 positive controls |
| moved-arm golden scoring | 20 views, TO-GOLDEN 40, AWAY 0 | **20 views, `MISSING-ARMS=0 NODB-views=0 TO-GOLDEN=40 AWAY-GOLDEN=0`** |
| floor | 652 arms MOVED 0 | **652 by name**: uvm199 7, uvm197 6, uvm196 9, uvm195 5, uvm194 3, uvm193 4, uvm192 4, uvm191 3, uvm190 4, uvm189 3, uvm188 4, uvm187 6, uvm186 3, uvm185 5, uvm184 2, uvm170 5, uvm82–91 113, buvm3–15 119, sd8–12 347 — **all MOVED 0** |
| § `parenCastWidthLhsKeepsTs199v` | untouched | **`v199_l_castw.sv` and `v199_m_ctl.sv` both in `LISTED`, both MOVED 0** |
| canaries | ok=52 / ok=8 changed=0 | **ok=52 / ok=8 changed=0** against this verifier's own pristine |
| ctcan2 / canaudit | PASS / `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **PASS ×4 / `audited=29 UNCOVERED=0 FENCE-BREACH=0`** |
| protected DBs | 10 SAME | **10 SAME both modes; `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`** |

Every `cmds.txt` in all four sweeps was audited BY PATH: `/tmp/v201_wd/pris_sl`
1523 × the pristine frozen binary, `/tmp/v201_wd/pat_sl` 1523 × the patched one,
`pris_u2r` 1458 × pristine, `pat_u2r` 1458 × patched — **one distinct path per
sweep and it is the frozen one**. Both binaries were `chmod 555` before any sweep.

**R1 is confirmed as NOT this pass's.** The only row that differs from the
COMMITTED `results/golden_surelog.csv` is
`Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` → `,CMP_EQUAL,,,` — the informational
dump column, **and it differs on the PRISTINE binary too**, measured here on a
pristine build this verifier made itself. `canaries.sh` reports the same single
`CHANGED` on the pristine column.

## 2. THE LAW'S GATE IS LOAD-BEARING — THE COUNTER-EXAMPLES RE-READ OFF GOLDEN

The implementer's claim that a gate on `isImported` alone would have taken **ten
CMP_EQUAL row-modes AWAY from golden** was re-measured independently, `--pred`
run on the GOLDEN databases each row's own `cmds.txt` names:

```
ParamFromPackage        ×2   golden RHSGAP=1  other|module_inst|u_aes_cipher_core|work@aes_cipher_core|13:4|X|aes_pkg  -/logic_typespec
ParamTypespec           ×2   golden RHSGAP=1  elab |module_inst|work@top|work@top|9:1|PartInvDefault|otp_ctrl_part_pkg -/logic_typespec
DivisionOfSize               golden RHSGAP=1  (the same elab unlocated re-fold)
ParameterFromPkgInNestedModule        golden RHSGAP=1  (the same child-instance listing)
ParameterFromPkgOnParameterPortList   golden RHSGAP=1  (likewise)
```

**GOLDEN ITSELF leaves those Rhs constants BARE under a typespec'd Lhs, and our
pristine already matches it cell for cell.** All ten row-modes are `CMP_EQUAL`
on the patched binary with both columns byte-identical, and none of them is
among the six byte movers. `prtLhs9` — not `isImported` — is the correct gate,
and the measurement says so on the golden side.

## 3. BREAKING THE LAW — 18 FRESH ARMS, 36 ARM-VIEWS, REAL SURELOG v1.86 GOLDENS

`grid201v.sh` builds one REAL golden per arm-view (`-parse -d coveruhdm`, and
again with `-elabuhdm`), both binaries' databases, the golden-vs-golden
CALIBRATION, the `ct201cen` census on each binary, and the OFFICIAL `uhdm-cmp`
on each binary. `score201v.py` then scores the **Rhs half** of every cell key.

```
CALIB  36 arm-views  AGREE 1038  TS-DIFF 0  ONLY-GOLDEN 0  ONLY-OURS 0
PRIS   36 arm-views  TS-DIFF 302
PATCHED 36 arm-views TS-DIFF 110
-- cells moved 66:  TO-GOLDEN 100   AWAY-GOLDEN 0   NEUTRAL 16
0 nonzero rcs anywhere.
```

The arms, and what each one attacks (`grid_v201/`):

| arm | face | verdict |
|---|---|---|
| `v201_a_refforms` | a REFERENCE-defaulted copy of every referent form the implementer's arm G only tested as a LITERAL: decimal, ranged, signed, `int`, `string`, typedef'd, `'d13`, `'0` | `R_DEC` `R_INT` `R_RNG` `R_SGN` `R_TNIB` **fixed**; `R_UDB` / `R_UNB` NEUTRAL (§ 4) |
| `v201_b_typedlhs` | the TYPED / RANGED / SIGNED / typedef'd / `byte` / `bit` **Lhs** taking a reference default | `T_RNG` `T_SGN` fixed; the rest already right and unchanged |
| `v201_c_localparam` | LOCALPARAMS, literal- and reference-defaulted, and a `localparam` defaulted from a `parameter` | `C_LB` `C_LC` `C_PB` **fixed** |
| `v201_d_real` | REAL and STRING reference chains — the forms whose implicit type is `real_typespec` / `string_typespec`, not `int` | `D_SB` NEUTRAL (§ 4); `D_RB` / `D_RC` cells our emitter does not emit at all, on BOTH binaries (§ 5) |
| `v201_e_enum` | an ENUM-constant reference and an enum-TYPED parameter | `E_B` `E_C` NEUTRAL (§ 4); `E_A` a MISSED (§ 5) |
| `v201_f_xpkg` | a CROSS-PACKAGE qualified reference and a package that imports another | `F_B` `F_C` `F_D` **fixed** |
| `v201_g_expr` | EXPRESSION defaults: arithmetic, concat, ternary, `$clog2`, and a reference to a folded system-function result | `G_E` **fixed**; the rest unchanged |
| `v201_h_ifprog` | the copy in a MODULE, an INTERFACE and a PROGRAM def listing, file-scope import (2 copies) beside a body import (1) | **fixed in all three, at both copy counts** |
| `v201_i_explicit` | EXPLICIT `import p::ITEM;`, referenced and unreferenced, and an explicit import of the REFERENT only | **fixed** |
| `v201_j_nested` | a SUBMODULE that imports, under an importer WITH a parameter port list | `sub201vj` **fixed**; the port-list module correctly untouched (§ `modDefImportShape`'s flip) |
| `v201_k_neg` | **NEGATIVE CONTROL** — a module's OWN reference-defaulted parameter and a `pkg::X` qualified reference from a module that never imports | **byte-identical, delta 0** |
| `v201_l_class` | the `other` view: a CLASS in the imported package | the module copy fixed, the class cell untouched |
| `v201_m_multi` | the SAME import copy at **1, 2 and 3 instances** | **fixed, identically at every instance count** |
| `v201_n_genarr` | the copy under a GENERATE array with a parameter port list | **delta 0** — the flip keeps the gate off, as decoded |
| `v201_o_ovr` | an importer that OVERRIDES its own parameter, over a 3-long reference chain | **fixed** |
| `v201_p_reexport` | a package that `import`s and `export`s, imported in turn | **fixed** |
| `v201_q_castref` | **the sharpest arm**: an UNSIZED-BASED parameter whose NAME is a PAREN-CAST WIDTH — the one path where `prtLhs9` exists while `up->Typespec()` is NULL — copied into a module, an interface AND a program | `Q_W` **byte-identical, both binaries, all three listings**: the mint does NOT fire (§ 4) |
| `v201_r_cliov` | an overridden port parameter beside the import copies | **fixed** |

**AWAY-GOLDEN is 0 on all 36 arm-views, and every ONLY-GOLDEN / ONLY-OURS key
set is byte-identical between the two binaries** (checked key-set by key-set,
not just by count).

## 4. THE 16 NEUTRAL MOVES — WHERE THE MINT LANDS ON A CELL THE JUDGE ALREADY LOST

Sixteen cells change without moving toward or away from golden, because our
constant's `VpiConstType`/`VpiSize` already differs from golden's on the
**PRISTINE** binary, and `expr::Compare` reads `VpiSize` at
`~/git-repos/UHDM/build/generated/src/expr.cpp:95` — **before** `Typespec` at
`:100`. Every one of them is a reference whose REFERENT has no reducible width:

| cell | golden | ours, BOTH binaries | pristine → patched Rhs ts |
|---|---|---|---|
| `R_UDB = A_UDB` over `A_UDB = 'd13` | `ct1/sz-1`, `<unbound>` | `ct1/sz32` | `-` → `int_typespec` |
| `R_UNB = A_UNB` over `A_UNB = '0` | `ct3/sz-1`, `<unbound>` | `ct9/sz32` | `-` → `int_typespec` |
| `Q_W2 = Q_W` over `Q_W = 'h8` (paren-cast width) | `ct5/sz-1`, `<unbound>` | `ct5/sz32` | `-` → `int_typespec` |
| `D_SB = D_SA` over `D_SA = "abc"` | `ct6/sz24`, `string_typespec` | `ct9/sz24` | `-` → `int_typespec` |
| `E_B = E_A`, `E_C = E_T` (enum refs) | `ct7/sz32`, `int_typespec` | `ct7`/`ct9`, `sz2` | `-` → `int_typespec` |

**Not one is pristine-right → patched-wrong**: in every case the pristine Rhs
was `-` where golden has something, so the cell was already unequal at the same
field or an earlier one. This is the implementer's **R2 measured wider** — R2
names only "a reference to an UNSIZED-BASED sibling"; the family also contains
the DECIMAL-BASED (`'d13`), UNBASED-UNSIZED (`'0`), STRING and ENUM-constant
referents.

**The one real coupling this creates, and it is worth carrying.** Golden's
Rhs-constant ref is **UNBOUND** (`ref_typespec` with no `Actual_typespec`)
exactly where the folded constant has `VpiSize == -1`; the mint hands its ref to
the `:14971` binder, which ALWAYS binds an actual. Today that never diverges on
the corpus, because **all 24 cells the gate reaches are `ct9/sz32`** and golden
binds an actual on every one of them; and every synthetic cell where it does
diverge is already unequal at `VpiSize`. **But if § `unsizedBasedParamRhsSize106`
is ever repaired (our `sz32` → golden's `sz-1`), those cells become
judge-VISIBLE and this mint will then be wrong there unless it learns to leave
the actual unbound.** Recorded as **R2b** so the size fix and this law are
landed together.

`Q_W` itself — the unsized-based paren-cast-width parameter, the only shape
where `prtLhs9` is built while `up->Typespec()` is null — is **byte-identical on
both binaries in the module, the interface AND the program listing**
(`<unbound>/int_typespec`, `ct5/sz-1`, exactly golden's payload). The `!rhsRt`
guard holds there: the literal-fold path at `:7814` has already set `rhsRt` to
an unbound ref, so the mint declines. § `parenCastWidthLhsKeepsTs199v` is intact
by direct measurement, not only by the boundary's byte test.

## 5. TWO MISSES THIS ARM SET FOUND (neither is this pass's, both are candidates)

* **`parameter E_A = VE1;`** — an enum-CONSTANT literal default. Golden gives
  BOTH halves an `int_typespec` (`ct7/sz32`); ours gives NEITHER (`-/-`,
  `ct7/sz2`). `prtLhs9` is null, so this law cannot reach it. `grid_v201/v201_e_enum.sv`.
* **`parameter R_STR = A_STR;`** — a reference to a STRING sibling. Golden emits
  the def-view materialized cell (`string_typespec/string_typespec`); **our
  def-view listing has no cell for it at all**, and in the `elab` / `elabpkg`
  views our payload is `-/-` where golden's is `string_typespec/string_typespec`.
  Both binaries. `grid_v201/v201_a_refforms.sv`. The real-typed
  `D_RB` / `D_RC` copies are absent from our def listing the same way
  (`grid_v201/v201_d_real.sv`).

## 6. THE MOVE, CELL BY CELL, ON ALL SIX MOVERS

`ct201cen --list` diffed pristine × patched on each mover, and `--cen` against
that row's own golden:

```
row / mode              CALIB          pristine                       patched                     cell-listing diff
SimpleUVM   ×2   AGREE=338 TS-DIFF=0   AGREE=334 TS-DIFF=8 ONLY 0/0   AGREE=338 TS-DIFF=0 equal   2 keys × n=2
SeqDriver   ×2   AGREE=563 TS-DIFF=0   AGREE=559 TS-DIFF=8 ONLY 0/0   AGREE=563 TS-DIFF=0 equal   4 keys × n=1
MiniAmiq    ×2   AGREE=788 TS-DIFF=0   AGREE=784 TS-DIFF=8 ONLY 0/0   AGREE=788 TS-DIFF=0 equal   4 keys × n=1
```

Every changed key is `def|module_inst|work@top` / `work@top_tb` or
`defif|interface_inst|work@svaunit_vpi_interface`, parameter `UVM_SETINT` or
`UVM_END_FUNCS`, payload `-/int_typespec` → `int_typespec/int_typespec`.
**No `defpkg`, `elabpkg`, `elab` or `other` cell moves on any row** — the
package-side originals and the elaborated listing are untouched, which is the
claim § `impFoldRhsMirrorsLhsTs201` has to keep and does.

## 7. VERDICT

**ACCEPT.** Every headline number reproduces bit-for-bit from independently
built binaries. Eighteen fresh arms across DEF and ELAB, at one, two and three
instances, over literal-, reference- and expression-defaulted copies,
localparams, typed/ranged/signed/typedef'd/enum/real/string parameters,
module/interface/program listings, explicit and wildcard and body imports,
cross-package and re-exported packages, and the paren-cast-width shape, produce
**TO-GOLDEN 100 / AWAY-GOLDEN 0** and **not one pristine-right → patched-wrong
cell**. No fix was required; the shipped deliverable is the implementer's own
patch plus this directory.

## 8. FILES

| file | what it is |
|---|---|
| `grid_v201/*.sv` | the 18 adversarial arms |
| `grid201v.sh` | one real Surelog golden per arm-view, both binaries, CALIBRATED golden-vs-golden, census + OFFICIAL `uhdm-cmp` per binary, every rc recorded |
| `score201v.py` | the Rhs-half TO-GOLDEN / AWAY-GOLDEN / NEUTRAL scorer; NEUTRAL cells are printed, never hidden |
| `GRID.{a,b,c}.r10v201.txt` | the raw grid output for the three arm sets |
| `SCORES.{a,b,c}.r10v201.txt` | the scored cells |
| `BOUNDARY_MOVERS.r10v201.txt` | this verifier's own 5280-arm boundary movers |
| `BOUNDARY_SCORES.r10v201.txt` | the 10 non-verifier movers scored against real goldens, both views |
