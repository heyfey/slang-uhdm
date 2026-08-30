# r10v164 — the ADVERSARIAL VERIFICATION of r10uvm164

`§ castOperandNeverBindsInCondWindow164` — the `if` / `if_else` / `case`
CONDITION column is the same cast window r10v161's FIX 1 opened for the
assert / case-item column.

**VERDICT: ACCEPT, production surface UNCHANGED.** Every headline number in the
implementer's report reproduces bit-for-bit on binaries this verifier built
itself; no legal-SystemVerilog face was found where the pristine binary agrees
with golden and the patched one does not.

MEASUREMENT ONLY throughout. LHS is ALWAYS golden (Surelog); RHS is ALWAYS
ours. `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.

---

## 1. What was rebuilt, and what it hashed to

Two fresh worktrees at `578ffc2`, configured and built independently
(`-j 2`, Release, gcc-toolset-14), then FROZEN (`chmod 555`) before any sweep:

| binary | md5 |
|---|---|
| pristine `578ffc2` | `55fb7e0612ac4dc2008d1e5906b184e8` |
| patched (`git apply -3` of the pass patch, clean) | `a6cf9362b957f131bfc5e13d3de0c105` |

Both match the implementer's claimed hashes exactly. The patch applies clean on
a FRESH `578ffc2`; its surface is `RESUME.md` + `include/UhdmExporter.h` +
`src/ExprEmit.cpp` + `src/StmtEmit.cpp` + `tools/probe/r10uvm164repro/` and
nothing else — no `results/*.csv`, no `GOLDEN_DEFER`, no hard-coded foreign
scratch, no `rm -rf`, and the four slang-fenced names appear in NO file
(the four slang-fenced names: 0 each).

The MAIN TREE's `build/slang-uhdm` is `8197eea55fded4f23c7628f2d23c8bae` — it
is NOT a `578ffc2` build (the main tree is several landings ahead). The
pristine baseline used here is this verifier's own `578ffc2` build, and every
number below is against that.

## 2. The one edit, read for equivalence

`MethodWindow161` (StmtEmit.cpp:127) is behaviourally IDENTICAL to the
hand-spelled `bool sX = classMethodNoBind; classMethodNoBind = false; … ;
classMethodNoBind = sX;` it replaces at the three CONDITION sites: when the
flag is false the constructor's `if (f)` is not taken and the destructor still
assigns `saved` (false); when it is true both forms clear and restore. The one
behavioural addition is `++/--condMethodWindowDepth164`, taken ONLY when the
window actually lifts a set flag. The RAII is constructed INSIDE the existing
`CondWindow5` block whereas the old restore sat just after it — nothing is
emitted between the block's close brace and the old assignment at any of the
three sites, so the restore point is unobservable. The RAII is also exception-
safe where the hand-spelled form was not, and the depth is balanced (no early
return between construction and scope end at any site).

`condMethodWindowDepth164` is a SEPARATE counter, not a widening of
`methodWindowDepth161v`. Measured consequence, below: § namedBlkLocalNoBind144v
reads `methodWindowDepth161v` alone and its condition-column twin does not move.

## 3. The gates, re-run end to end

| gate | result |
|---|---|
| (1) both binaries built here, md5s | above; identical to the claim |
| (2) goldens, `SLANG_UHDM` exported per binary | patched 23 PASS / 0 FAIL; pristine 23 / 0; `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL |
| (3) u2r status, both modes, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL — four identical histograms |
| (3) `ct8rows` u2r | vs committed `results/gate_uhdm2rtlil.csv`: 0 differing rows; pris-vs-pat testflags 0; pris-vs-pat default 0 |
| (4) surelog `--mode both`, 1588 rows | pristine and patched status histograms IDENTICAL (937 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM) |
| (4) `ct8rows` surelog | vs committed `results/golden_surelog.csv`: 0 differing rows over 1588; pris-vs-pat: 0. **NO row converted** — the head moves, the rows stay CMP_NOTEQUAL. `results/*.csv` never written. |
| (5) `byteverify SELFCHECK=1` | surelog MOVERS **9 / 956**, selfcheck 955/956; u2r MOVERS **0 / 1358**, selfcheck 1357/1358; PATH_SETS_IDENTICAL on both |

**cmds.txt audit, file by file, by BINARY PATH** (not by the string
`slang-uhdm`, which also matches the golden cache): 1573 + 1462 = **3035**
`cmds.txt` per sweep; every one names exactly ONE binary, and it is the frozen
one — `/tmp/…/pat.bin` for the patched sweeps (1523 + 1458 files carry a
`slang:` line; the rest are rows where our binary was never invoked) and
`/tmp/…/pris.bin` for the pristine ones. The main-tree binary appears NOWHERE.

**Canaries.** `canaries.sh` ok=52 changed=0 absent=0 (surelog) and ok=8
changed=0 (u2r); `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh`
→ `audited=29 UNCOVERED=0 FENCE-BREACH=0`. Protected databases, patched vs
pristine bytes: InterfaceModPort, BlackParrotComplex, YosysOldOr **byte-
identical in both modes**; SVSwitch on pin `4842211c4030`; YosysVerx on pin
`6ccda350c24a`.

## 4. The movers, predicted a priori and attributed order-blind

**PREDICTION, written and run against PRISTINE DATABASES ONLY** before any
patched database was compared (`/tmp/v164_predict.sh`, reproduced below). The
NECESSARY condition for a database to move is that it hold a reference that is
under a cast, homed in a class-definition subroutine, and currently BOUND —
nothing else can lose a binding. Deliberately a SUPERSET predicate (it does not
read the condition column, so it over-predicts):

```
scanned=956  candidates=9   (surelog)
  default/BuildUVMPkg  default/MiniAmiq  default/Scoreboard
  default/SeqDriver    default/SimpleUVM
  testflags/BuildUVMPkg testflags/MiniAmiq
  testflags/SeqDriver  testflags/SimpleUVM
scanned=1358 candidates=0   (uhdm2rtlil)
```

**MEASURED: byteverify MOVERS 9 / 956 and 0 / 1358 — exactly those rows, by
name.** Prediction and measurement agree with nothing left over.

**Every one of the nine attributed ORDER-BLIND** (`uhdm-dump`, workdir path
normalised, both sides `sort`ed). Each database's whole-dump order-blind diff
is EXACTLY TWO LINES, and they are the law's own cell:

```
< \_io_decl: (action), line:347:51, endln:347:57        (30797:51 in BuildUVMPkg's pp_output)
< |vpiActual:
```

`Scoreboard/default` is RESUME §9's ~50/50 COIN. It is attributed order-blind
like the rest and its order-blind diff is the same two lines — the coin
contributes nothing to the attribution either way.

## 5. Heads

`rowheads.sh` on this verifier's own sweeps, pristine → patched:

| row-mode | pristine | patched |
|---|---|---|
| SeqDriver default / testflags | 29 / 29 | **82 / 82** |
| SimpleUVM default / testflags | 29 / 29 | **82 / 82** |
| Scoreboard default | 145 | 145 |
| MiniAmiq ×2 | 106 | 106 |
| BuildUVMPkg ×2 | 29 | 29 (head unchanged: the `alias_name` io_decl at 14091:46) |
| Earlgrey_0_1 default / testflags | 58 / 62 | 58 / 62 |
| Rggen default | CMP_EQUAL | CMP_EQUAL |

ONE head per run on every measured row (`grep -c '^LHS:'` = 1). All **24**
committed `head_{pris,pat}_*.cmp` evidence files in `r10uvm164repro/`
reproduce BYTE-FOR-BYTE from this verifier's build and sweeps.

The pristine head is the SINGULAR SafeCompare **mirror** (`LHS: <null>`, full
RHS) on `io_decl (action) @347:51` under
`function uvm_pkg::uvm_report_handler::format_action` — confirmed by reading
the cmp log directly, not carried forward.

The R0 head is confirmed as described: golden a plain `ref_var` whose
`ref_typespec`'s actual is the NAMED `array_typespec (types_t)` at 642:11;
ours an `array_var` (`vpiArrayType:4`) whose `ref_typespec` actual is an
ANONYMOUS `array_typespec` at 651:13, with the named typespec demoted onto a
nested `vpiReg` `ref_var` — two different `UhdmType`s, so the type test fails
first.

## 6. The corpus census, reproduced

`census164.sh` + `cencount164.py` on this verifier's own sweeps, over the nine
rows (SKIP-NOFILE=0 — every row reached):

```
668 references under a cast
  by context   ifcond 164 | assign_rhs 266 | body 176 | arg 35 | return 27
               (casecond, caseitem, assertcond, loopcond: empty in the corpus)
  by home      function@class_defn 333 | function@package 227 |
               task@class_defn 18 | function@design 2 | none@none 88
  by kind      castop 668 | signcast 0
  DIFF golden-vs-ours   PRISTINE 9  ->  PATCHED 0
  MOVED 9, all TOWARD-EXACT;  AWAY 0, SIDEWAYS 0, RESHAPE 0
  ONE-SIDED SETS unchanged: ONLY-G ('body',function@class_defn,castop) x36 +
      ('body',function@package,castop) x52  vs  ONLY-O ('body',none@none,castop) x88
      — the same 88 references differing only in HOME, a pre-existing parenting residue
```

All nine DIFF cells are the same cell:
`(ifcond, castop, function@class_defn, ref_obj, action, 350:25)`
(`30800:25` in BuildUVMPkg's pp_output).

## 7. BREAKING THE LAW — three new adversarial arms

Each arm is built against its OWN Surelog golden in BOTH views by
`r10uvm164repro/grid164.sh` (all 6 commands rc=0 per arm, every rc recorded).
Scored two ways: `score164.py` (set-keyed, the implementer's scorer) AND
`v164_multiset.py`, a MULTISET counter written for this verification because a
SET of values cannot see "golden has 1 BARE + 2 BOUND, we have 2 BARE + 1
BOUND" across three module instances (RESUME §9's census trap).

### `v164_e_scope.sv` — THE CLASS-HOME ATTACK (the sharpest one)

The model says a cast operand falls through Surelog's
`if (pexpr) … else if (instance) … else needLateBinding` to the INSTANCE, so
the suppression is owed only where there is no instance, and a MODULE function
must stay BOUND. Arm B measured the module-function face. This arm attacks the
other half: a CLASS METHOD whose class is declared somewhere that HAS an
instance.

| home | cells | golden | result |
|---|---|---|---|
| class in a PACKAGE (control) | e01-e04 | BARE | TOWARD |
| class at `$unit` scope | e11-e13 | BARE | TOWARD |
| class inside a MODULE (function + task) | e21-e27 | BARE | TOWARD |
| class inside an INTERFACE | e31-e33 | (we emit no such class at all) | — |
| class inside a PROGRAM | e41-e43 | BARE | TOWARD |
| class nested in a class in a module | e51-e53 | BARE | TOWARD |
| a `virtual` base and its override | e54-e56 | BARE | TOWARD |

**A class method has no instance even when its class is lexically inside a
module, an interface or a program.** 34 CAS cells, DIFF 36 → 2, **AWAY 0**
(multiset AWAY 0). The 2 residual are `outcome40` in the program's `initial`
(no cast, pre-existing, unmoved). Fresh residue found and NOT this pass's:
a class declared inside an INTERFACE is absent from our output entirely
(14 ONLY-G cells, identical on both our columns).

### `v164_f_faces.sv` — EVERY CAST FACE, one home held fixed

54 CAS cells TOWARD, 2 NO-GOLDEN, **AWAY 0** (multiset AWAY 0 after the shape
artefact below is read). DIFF 56 → 2. Movers occur in ifcond, casecond and
`arg`-inside-a-condition and NOWHERE ELSE.

MOVED (golden BARE, pristine BOUND, patched BARE): type / size-literal /
size-parameter / enum / typedef casts (f01-f05, f08); `signed'()` and
`unsigned'()` CAST spellings (f06, f07); a cast of a cast in both orders
(f09-f11); a cast inside a BINARY, inside a TERNARY arm, with a ternary or a
concat UNDER it (f12, f14-f17 — the concat cells MEASURED, never legislated:
r10v161's R0b family is untouched); a cast of an ARRAY ELEMENT or a PART SELECT
(f18, f19); an ENUM-TYPED FORMAL (f23); a cast inside a `$sformatf` argument and
inside a USER-CALL argument, both INSIDE a condition (f24, f25); `casex` and
`casez` conditions (f32, f33); `unique if` / `priority if` (f35, f36); and the
`else if` condition of a chain (f38).

MUST-STAY, verified golden = pristine = patched cell by cell:

* **f13** `if (int'(barrow) == 41 && barrow == 41)` — the cast operand goes
  BARE while the BARE operand in the SAME condition stays BOUND. The term is
  the CAST, not the position.
* **f26 / f27** `$signed(x)` / `$unsigned(x)` as SYSTEM CALLS: golden **BOUND**,
  pristine BOUND, patched BOUND. The census labels them `CAST=signcast` — the
  same wrapper kind as the moving f06/f07 — so this is a golden-BINDS cell
  wearing the moving cells' own census key, and the patch still leaves it
  alone. The sharpest near-miss on the whole grid, and it passes.
* **f28** `$cast(dst, src)` used as an `if` CONDITION: its argument `barrow` is
  golden-**BOUND** and stays BOUND. A no-cast reference inside a call argument
  inside a condition is NOT touched.
* **f40-f42** assert / assume / cover conditions: r10uvm161's column, BARE on
  all three, unmoved.
* **f50-f54** `while`, `do-while`, `for` and `repeat` controls (census
  `CTX=loopcond`) and a `foreach` body: golden BARE, already BARE, unmoved.
* **f60-f62** assignment RHS, call argument, `return`: BARE on all three.

### `v164_g_depth.sv` — depth, the other silences, and 3 INSTANCES

20 CAS cells TOWARD, DIFF 22 → 2, **AWAY 0** (multiset AWAY 0 — the three
instances' elaborated copies are counted individually).

MOVED: a CONSTRUCTOR's local and formal (g01, g03, g04 — § ctorSubLocalNoBind144's
home); a NAMED-block local and a subroutine local read from inside a named block
(g11, g13, g14); an UNNAMED block's local (g15); a cast in a `this.`-call
argument and in a plain-call argument inside a condition (g31, g33); **a cast
inside a `fork` (g27)**.

MUST-STAY: one control body deep (g21-g23) golden BARE and already BARE
(§ controlBodyNoBind28 owns them); a bare reference in a method-call argument
inside a condition (g32) golden **BOUND** and unmoved; a bare reference in a
`fork` (g28) golden BOUND and unmoved; a `randomize() with` inline constraint
(g34/g35) unmoved; a TERNARY condition (g41/g42) unmoved.

### The must-stay controls the brief names

| arm | pristine DIFF → patched | moved |
|---|---|---|
| `r10v161repro/v161_a_statics.sv` (the statics matrix) | 36 → 36 | **0** |
| `r10v161repro/v161_c_overbind.sv` (the discriminator arm) | 17 → 17 | **0** |
| `r10v161repro/v161_d_break.sv` | 43 → 15 | 28, all TOWARD |

Cell by cell in `v161_d_break.sv`:

* **d61** `146:14 if (int'(loc) == 1)` in a MODULE FUNCTION —
  `HOME=function@module_inst`, golden **BOUND**, pristine **BOUND**, patched
  **BOUND**. This is the golden-BOUND control that convicted r10v161's first
  cut, and the patch leaves it alone.
* **d62** the assert twin at `147:18` in the same module function — BOUND on
  all three.
* **d31** `53:11` (§ refVarLocalWindowBinds5's condition window, no cast) —
  golden BARE, ours BOUND before AND after: unmoved standing residue.
* **d41** `97:13` (§ namedBlkLocalNoBind144v's condition twin, no cast) —
  golden BARE, ours BOUND before AND after: unmoved.
* **d21** `38:16` (case condition + cast) — golden BARE, pristine BOUND,
  patched BARE: TOWARD. This was r10uvm161's declared R0a.

And on the implementer's own arm D: **d41** (named-block local, NO cast,
`if` condition) golden BARE / ours BOUND / **unmoved**, while its CAST twin
**d42** goes BOUND → BARE. The separate-counter design does exactly what its
comment claims.

### Reproduction of the implementer's four grid arms

Scored on this verifier's binaries, all families, matching
`r10uvm164repro/GRID.r10uvm164.txt` line for line:

| arm | pristine DIFF → patched | MOVED |
|---|---|---|
| A contexts | 27 → 15 | 12 TOWARD |
| B homes | 21 → 1 | 20 TOWARD |
| C cast kinds × referents × instances | 99 → 11 | 88 TOWARD + 4 NO-GOLDEN |
| D must-stay | 19 → 7 | 12 TOWARD |

**AWAY 0 on every arm, on both scorers.** The only multiset "AWAY" signals
anywhere (2 in `v164_f_faces.sv` f09, 2 in the implementer's arm C) are the
NESTED-CAST SHAPE artefact: golden's key is `CAST=castop>castop` and ours
`CAST=castop` (we render one `vpiCastOp` where golden renders two), so the
patched BARE lands on a key golden has zero of. The VALUE moved toward golden;
the wrapper count is the pre-existing R-catshape residue and is identical in
the pristine binary.

## 8. The boundary gate, over a copy of the WHOLE probe tree

```
LISTED=4647 PROCESSED=4647 PRODUCED_DBS=4491 MOVED_ARMS=11 RC_DIFFS=0
```

(the implementer's run read 4644/4644/4488/8/0 — the difference is exactly this
verifier's three new arms, which is also the POSITIVE CONTROL: a gate that
reported zero over them could not see.)

Seven movers are this pass's own arms (four `g164_*.sv`, three `v164_*.sv`).
The FOUR outside, each censused against its own Surelog golden:

| arm | DIFF | cells |
|---|---|---|
| `r10buvm29repro/g29_c_carriers.sv` | 4 → 0 | 4 TOWARD |
| `r10uvm96repro/g96_a2_homes.sv` | 10 → 6 | 4 TOWARD |
| `r10v161repro/v161_d_break.sv` | 43 → 15 | 28 TOWARD |
| `r10v161repro/v161_g_catshape.sv` | 116 → 108 | 8 TOWARD (r10v161's R0b concat cells untouched) |

**44 outside cells, every one TOWARD, AWAY 0 on both scorers.**

Every must-stay set the brief names was LISTED (non-zero) and moved 0, the
SUBDIRECTORY arms included: r10uvm160 (6), 158 (6), 139 (5), 145 (5), 155 (5),
157 (5), 146 (7), 114 (8), 89 (2), 77 (9), 78 (8), 79 (8), 82 (7), 84 (23),
85 (23), 91 (5), 161 (4), r10buvm3 (4), buvm14 (1), buvm15 (9), r10sd8 (37),
sd9 (44), sd10 (68), sd11 (90), sd12 (108), r10uvm33 (3).

## 9. RESIDUES, ranked

1. **R-pkgvar** — `int'(pkg::var)` in a class-method condition: golden BARE,
   ours BOUND, **unchanged by this patch** (`v164_f_faces.sv` f20
   `smithy164::hoard` 66:14, and the implementer's a25 / c20). The
   package-qualified reference never reaches this gate. No corpus cells: the
   corpus census's `ifcond` DIFF is 0 after the patch. Highest-ranked because
   it is the same law's own column.
2. **R-ifacecls** (found here, pre-existing) — a class declared inside an
   INTERFACE is absent from our output entirely (`v164_e_scope.sv` e30-e33:
   14 ONLY-G cells, identical on both our columns). Nothing to do with casts.
3. **R-catshape** — one `vpiCastOp` where golden renders two for
   `T'(int'(x))`; the operand's VALUE is right, the wrapper count is not
   (f09, arm C's two NO-GOLDEN cells).
4. **R-oob** — a `$unit`-scope OUT-OF-BODY method (`v161_d_break` 130:12 /
   131:16): golden BARE, ours BOUND, no window opens. The same shape inside a
   package is golden-BOUND and correct.
5. **R-bodyhome** — the 88 `body`-context cells whose HOME reads `none@none`
   on our side and `function@…` on golden's: a parenting residue, identical on
   both our columns.
6. **§ 144v / § 5 condition-column twins** — d41 `97:13` and d31 `53:11`:
   golden BARE, ours BOUND, deliberately untouched (they are the no-cast half
   and the separate counter is what keeps them still).
7. **r10v161's R0b** — a plain concatenation's operands: measured on
   `v164_f_faces.sv` f16/f17 and on `v161_g_catshape.sv`, legislated nowhere.

## 10. R0 — the next head, independently confirmed

SeqDriver ×2 + SimpleUVM ×2 move 29 → 82 cmp lines, ONE head, the SAME object
on all four row-modes: `uvm-1.2/src/base/uvm_misc.svh:651:13`, the
`types_t types;` local of the static method `find_all` in the parameterized
class `uvm_utils #(type TYPE=int, string FIELD="config")` (which declares
`typedef TYPE types_t[$]`). It is the DECLARATION KIND of a queue-typed local
in a parameterized class. Read from the cmp log directly (§ 5 above).

---

### Files

* `v164_e_scope.sv` — the class-home attack (package / `$unit` / module /
  interface / program / nested / virtual-override homes).
* `v164_f_faces.sv` — every cast face against its must-stay twin, one home held
  fixed.
* `v164_g_depth.sv` — constructor, named and unnamed blocks, control bodies,
  `fork`, `foreach`, `randomize() with`, call arguments, ternary condition,
  and three module instances.

The arms are driven by `r10uvm164repro/grid164.sh` and scored by
`r10uvm164repro/score164.py`; the multiset check is `v164_multiset.py`, the
a-priori mover predictor is `v164_predict.sh`, both in this directory.
