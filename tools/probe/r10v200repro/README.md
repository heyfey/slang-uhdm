# r10v200 — ADVERSARIAL VERIFICATION of r10uvm200 — **ACCEPT**

**MEASUREMENT-ONLY probes.** The official `uhdm-cmp`
(`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py` are the
only judges of every number here. slang was **NOT** patched; `results/*.csv`
were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW CONVERTED**;
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `1af5cdae`, the verifier's own fresh worktrees |
| pristine | md5 `71288bea3b53a2587f780bd635206a47` — **byte-identical to the implementer's claim** |
| patched | md5 `1a507182eed3ad1ca2b961b525a1eee6` — **byte-identical to the implementer's claim** |
| verdict | **ACCEPT** — every headline number reproduced bit-for-bit; six adversarial arms aimed at the law's fence produced **AWAY-GOLDEN 0 / MOVED-WRONG 0** in both views |

## 1. THE BREAK ATTEMPT — six arms, twelve views, nothing broke

`arms200v/` aims at the shapes the implementer's grid does not reach.

| arm | what it aims at | def | elab |
|---|---|---|---|
| 1 `v200_1_clsparam` | CLASS-scope constants a clone's range can name — a class `localparam`, a `#()` class parameter, an out-of-body method's class localparam. If Surelog resolves these at COMPILE time the clone keeps the actual and the law over-fires. | TO-GOLDEN 0, **AWAY 0**, WRONG 0 | 0 / **0** / 0 |
| 2 `v200_2_locals` | the DECLARATION SHAPES: a function-local `localparam` in a later local's range, 2-D packed, UNPACKED dimensions, a struct member, a typedef'd local, a task | TO-GOLDEN 10 + ARITY 8, **AWAY 0**, WRONG 0 | 0 / **0** / 0 |
| 3 `v200_3_multi` | MULTIPLICITY 1..3 — three importing packages, a three-deep re-export chain, three subroutines, three parameters | TO-GOLDEN 24 + ARITY 24, **AWAY 0**, WRONG 0 | 0 / **0** / 0 |
| 4 `v200_4_rhsfaces` | every Rhs FACE a copied `param_assign` can carry: literal, folded, string, `int`, `real`, `localparam`, a THIRD package's parameter, an enum constant | TO-GOLDEN 8, **AWAY 0**, WRONG 0 | 0 / **0** / 0 |
| 5 `v200_5_modmat` | the MODULE-MATERIALIZED population (uvm196's): a module, an interface, a module instanced twice, alongside a package importer | TO-GOLDEN 2 + ARITY 2, **AWAY 0**, WRONG 0 | 0 / **0** / 0 |
| 6 `v200_6_return` | the RETURN exemption under stress — return-only, return + formals, a typedef'd return, an out-of-body method's return, a task | TO-GOLDEN 4 + ARITY 2, **AWAY 0**, WRONG 0 | 0 / **0** / 0 |

`ONLY-GOLDEN` and `ONLY-OURS` read the SAME on both binaries in all twelve
views: the law removes bindings, it never creates or destroys a cell.

**GOLDEN ITSELF DRAWS THE LINE.** Over all six arms, the only cells in an
IMPORTING package's DEF listing where golden carries an actual on a range
reference are held by the UNNAMED `logic_var()` — the return variable the
clone shares with the home. Not one `io_decl(...)`, not one named body local.
That is the law's exact shape, read off the golden databases rather than
assumed.

**Arm 5 settles the uvm196 question by measurement**: only `package(pv5p)`
cells move; the `module_inst` / `interface_inst` listings of the same
subroutine are byte-identical, and arm 5's def view CLEARS (33 cmp lines with
one head → 0, CMP_EQUAL).

**Arm 4 settles the Rhs question**: `ct200own --pa=pv4` prints our whole
param_assign listing, 37 rows, `PA-NO-RHS=0`, and it is **byte-identical
between the two binaries** — every import copy of a literal / folded / string /
int / real / localparam / third-package parameter keeps the Rhs golden keeps.
`--norhs` reads `NO-RHS=0` on golden and on both of ours in all twelve views.

## 2. WHAT REPRODUCED BIT-FOR-BIT

| claim | verifier's measurement |
|---|---|
| pristine `71288bea…`, patched `1a507182…` | **identical** |
| the head: SeqDriver ×2 and MiniAmiq ×2, **33 → 50 cmp lines, ONE head**; MiniAmiq's two modes byte-identical | **identical**; the six committed `head_{pris,pat}_*.cmp` files reproduce **byte-for-byte** from the verifier's own sweeps |
| every other row's cmp log byte-identical between the binaries — SimpleUVM ×2 17, Scoreboard/default 95, BuildUVMPkg ×2 0, Earlgrey 56 / 0, Rggen/default 0 | **identical** |
| goldens 23 PASS / 0 FAIL on both binaries, `/bin/false` 23 FAIL | **identical** |
| u2r 679/50/2 both modes both binaries; ct8rows PASS ×3; byteverify **0 / 1358** | **identical** |
| surelog **0 differing rows patched vs own pristine**; vs the committed baseline exactly one row-side, `Earlgrey_0_1,testflags CMP_EQUAL/differ → CMP_EQUAL/`, **present identically in the verifier's own PRISTINE sweep** | **identical** — a uhdm-dump timeout of the DUMP column under sweep load; status CMP_EQUAL both sides; no row converted |
| status histograms identical between the binaries, both modes | **identical** (940 CMP_EQUAL / 16 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM / 1 TIMEOUT / 2 UNTRANSLATABLE, both) |
| byte movers **5 / 956** — the four predicted BY NAME plus Scoreboard/default | **identical**; the coin's path-normalised, id-stripped, sorted dump diff is **0 content lines** over 1 100 381 lines |
| the attribution: each moved row loses exactly **4 dump lines and adds nothing** | **identical** — 2 × `\|vpiActual:` + 2 × `\_constant: line:410:30, endln:410:60`, **ADDED = 0**, on all four rows |
| the a-priori prediction, re-derived by the verifier from its OWN pristine sweep | **identical**: `scanned=948 NODB=617 FENCED=8`, strict>0 on exactly `MiniAmiq` ×2 (14) and `SeqDriver` ×2 (7), every other row `strict=0 AND wide=0` |
| the grid, 5 arms × 2 views | **identical**: TO-GOLDEN 4+8+2+4+2 = **20**, ARITY **2**, **AWAY 0, MOVED-WRONG 0**, 0 nonzero rcs; arm E def 33 → 17 |
| the census, 11 row-modes, golden-vs-golden calibrated FIRST | **identical**: SeqDriver ×2 TO-GOLDEN 2, MiniAmiq ×2 TO-GOLDEN 3, **AWAY 0 / MOVED-WRONG 0**; SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2, Earlgrey ×2, Rggen/default all mover columns 0; calibration 0 on every one |
| canaries / ctcan2 / canaudit | ctcan2 PASS ×2; canaudit PASS `audited=29 UNCOVERED=0 FENCE-BREACH=0`; u2r canaries ok=8 changed=0. **Surelog canaries read ok=51 changed=1 against the COMMITTED baseline on BOTH binaries** (the same Earlgrey/testflags dump cell) and **ok=52 changed=0 patched-vs-own-pristine** — see § 4 |
| SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr | **PINS HELD**, byte-identical, both modes |
| the four protected CMP_EQUAL row-modes | **CMP_EQUAL at rc=0, databases byte-identical** (BuildUVMPkg ×2 `68729cf77d77`, Earlgrey/tf `2afc8c0f6b08`, Rggen/default `8c0f8a3e6f7b`) |
| R0, the next head | **identical**, quoted object for object |

Every `cmds.txt` was audited BY PATH: 1523 `slang:` lines in each surelog
sweep and 1458 in each u2r sweep, **100 % the verifier's own frozen binaries,
zero main-tree hits**.

## 3. THE WIDE BOUNDARY — the verifier's own run, with six extra arms

```
LISTED=5249 PROCESSED=5249 PRODUCED_DBS=5064 MOVED_ARMS=10 RC_DIFFS=0
```

The ten movers are the five `grid200/g200_*.sv` (the pass's positive control)
and five of the verifier's own six arms — `v200_1_clsparam` correctly does not
move. **NOT ONE earlier-pass arm moved, in either view:**

| family | listed | moved |
|---|---|---|
| `r10uvm198repro` (§ classScopedTdImportCopyLocalUnsupported198) | 5 | **0** |
| `r10v198repro` (its verifier's conjunct arms) | 6 | **0** |
| `r10uvm197repro` (the size-stamp arms) | 6 | **0** |
| `r10uvm196repro` (the module materializer) | 9 | **0** |
| `r10uvm188repro` (the render arms) | 4 | **0** |
| `r10uvm82-91repro` | 113 | **0** |
| `r10buvm3-15repro` | 119 | **0** |
| `r10sd8-12repro` | 347 | **0** |

Byte-identity of the database in BOTH views is strictly stronger than
re-scoring those arms, so § 198's arms and its verifier's conjunct, § 197's
size stamp, § 196's module-materialized population and the uvm82-91 /
buvm3-15 / sd8-12 floor are all untouched. The elab-mode segfaults the log
reports are **pre-existing and identical on both binaries** — `RC_DIFFS=0`.

## 4. THE ONE REPORTING NIT (not a defect)

The implementer's `GATES.r10uvm200.txt` § 5 records the surelog canary line as
`ok=52 changed=0`. Against the **committed** `results/golden_surelog.csv` the
verifier reads `ok=51 changed=1`, and the one changed cell is
`Earlgrey_0_1 testflags CMP_EQUAL/differ -> CMP_EQUAL/` — **the same cell on
the PRISTINE binary, ok=51 changed=1 there too**. Scored the way the gate is
meant to be scored, patched against the pass's own pristine sweep, it is
`ok=52 changed=0`. So the substance holds and the patch moves no canary; only
the baseline the line was scored against is unstated.

## 5. RANKED RESIDUES (all present on BOTH binaries — none is a regression)

1. **R1, the explicit-item clone.** Arm D's two STILL-WRONG cells are exactly
   `package(pexp200d)` (`import pa200d::fd;`): golden `NONE`, ours the
   `constant`, unmoved. Correctly declined and correctly declared — it needs
   the `pkgElabSubTf` twin fence first.
2. **The elab-view in-class method range (the implementer's R6), measured.**
   Verifier arm 1: `elabpkg|package(pv1)|function(mpk)|io_decl(b)|WPK` and its
   return twin read golden `NONE` / ours `constant` in the HOME package's
   elaborated listing — we over-bind a class method's range where golden does
   not, on both binaries.
3. **An out-of-body method's class localparam, under-bound.** Verifier arm 1:
   `function(Cext::mext)` `io_decl(d)` / `logic_var(locext)` naming the class
   localparam `ELP` — golden binds them to a `logic_net`, we carry `NONE`, in
   the home package AND in the module listings, on both binaries.
4. **A cosmetic flag-style residue.** Both new sites write
   `impCloneDeclRangeNoBind200 = pkgImportCloneEmit; … ; = false;` rather than
   the save-and-restore its three neighbours at site 2 use. No call site can
   re-enter: `emitTaskFuncs` is called only from `ParamEmit`, `ModuleEmit` and
   `UhdmExporter`, never from `TypeEmit`, so `sharedTypespec` / `makeTypespec`
   cannot nest a second window; and if one ever did, the failure mode is an
   under-fire, never an AWAY-GOLDEN cell.

## 6. HOW TO RE-RUN

```
CEN=<ct200cen> bash ../r10uvm200repro/grid200.sh arms200v/<arm>.sv <pris.bin> <pat.bin> <wd>
python3 ../r10uvm200repro/score200.py <wd>/cen.g.<view>.txt <wd>/cen.a.<view>.txt <wd>/cen.b.<view>.txt --show
<ct200own> <golden.uhdm> <ours.uhdm> --norhs --pa=<pkg>
PRIS=<pris.bin> PATCHED=<pat.bin> bash ../r10uvm200repro/bound200.sh <copy-of-tools/probe> <out>
```
