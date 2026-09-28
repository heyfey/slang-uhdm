# r11u216: v1.87 strict pass 216, the module/type ground (pair B, refill after pass 212)

Base `745f66ab` (pass 212). Ground: src/ModuleEmit.cpp and src/UhdmExporter.cpp (TypeEmit.cpp, TaskFuncEmit.cpp and
uhdm_main.cpp untouched). Five laws, each behind its own switch; `R11U216_OFF` drops all five;
`R11U216_TRACE=<dir>` names every firing (`<dir>/<pid>.216`, first line `OUT <-o path>`).
The r11u214 ground-B decode (`tools/probe/r11u214dec`) had not landed at the start or at delivery (no
`/tmp/r11u214.patch`, nothing under the base's tools/probe), so item (0) did not apply and nothing of it is in this patch.

**Verdict in one line:** no corpus row-mode converts; MiniAmiq d/t moves `file(75)` -> `fullname(61)` (its first
record, the `uvm_severity` formal writer-order record #899, is gone) and is the only corpus mover; the downstream face
r11u173 N1 (q08, `$high` in a generate scope) goes DIVERGENT -> IDENTICAL with nine more fresh faces; 0 regressions in
all three stages; downstream 803 / 66 / 2 / 0 with every verdict equal to the pristine sweep and to the baseline.

## 1. The laws

| law | site | switch | statement |
|---|---|---|---|
| § genScopeRangeQueryFold216 | ModuleEmit.cpp `emitGenScopes` (the generic right-side emission), helpers `rqFoldPlan216` / `rqNetBound216` / `rqFoldMake216` | `R11U216_GENRQFOLD_OFF` | an elaborated generate-scope continuous assignment whose whole right side is `$high`, `$low`, `$left` or `$right` of a name with a written packed range is the queried BOUND: a literal bound as written (its span, decompile, value, constant type), an arithmetic bound reduced (`W-1` INT, `W+1` UINT, located at the left operand), a parameter read from a nested generate scope or a generate-block localparam the bare value; a net or variable operand's bound is that signal's own typespec bound object (shared); adjustSize to the left side only for a plain declared module net or variable |
| § ndaRangeQueryFold216 | ModuleEmit.cpp `emitContAssigns` (net-declaration branch), `emitGenScopes` (the generate cell), `emitInterfaceInstance` (the interface cell), helper `ndaQueryFold216` | `R11U216_NDARQFOLD_OFF` | an elaborated net declaration whose whole initializer is such a range query is the bound adjusted to the net (UINT masked with its decompile, other encodings but DEC sized in place, so a shared bound object carries the net's width) |
| § ndaSizeQueryFold216 | ModuleEmit.cpp `ndaQueryFold216` (the same three cells) | `R11U216_NDASIZEFOLD_OFF` | an elaborated net declaration whose whole initializer is `$size` of a net or variable (one packed dimension, or one unpacked dimension of an integral element) is a location-less `UINT:<count>` constant (decompile, vpiUIntConst), masked and sized to the net |
| § tfArgOutsideClassOrder216 | UhdmExporter.cpp, § tfArgClassMethodOrder176's writer resolution (the `clsOrder176` decision and the `lastCls176` order) | `R11U216_TFOUTCLS_OFF` | a class method OUTSIDE a package enum typedef's package (a class of another package, bare imported or qualified, or a class declared in a module) is a writer of the shared object; the elaborated package object takes the last class writer in Surelog's compile order (packages in NAME order, each package's classes in name order, then module classes in name order), the definition listing still the package's own last subroutine |
| § tfArgImportCloneFollows216 | UhdmExporter.cpp, the same block (after the two moves) | `R11U216_TFIMPCLONE_OFF` | beside § tfArgOutsideClassOrder216, the importer's CLONE of one of the package's own subroutines (CompileHelper::importPackage clone_tree) types its formal with a copy that holds the definition listing's moved span: every enum typespec of the listing's name still at the declaration span and referenced only from subroutines listed in another package or an instance takes the package's last own writer's span |

`R11U216_TFOUTCLS_OFF` drops § tfArgImportCloneFollows216 too (the clone law runs only where the outside order fired);
`R11U216_TFIMPCLONE_OFF` drops the clone law alone. Every other switch drops its own law only.

### 1.1 Decodes (Surelog source under third_party/Surelog/src, UHDM templates under third_party/Surelog/third_party/UHDM)

* **The range-query fold (§ genScopeRangeQueryFold216, § ndaRangeQueryFold216).** CompileExpression.cpp routes
  `$high`/`$low`/`$left`/`$right` to `compileBound`, which compiles the operand with `Reduce::No`, reads the operand's
  typespec `ranges->at(0)`, reduces both bounds (CompileHelper::reduceExpr, which hands back a constant bound itself)
  and returns the LEFT expr for `$left`, the RIGHT for `$right`, for `$high` the left when `lrv > rrv` else the right,
  for `$low` the other; UHDM's ExprEval range-query branch (templates/ExprEval.cpp) does the same through `getObject`
  (a parameter resolves to its param_assign's value and that value's typespec). The generate-scope cont_assign and the
  net-declaration cell are compiled in the instance (NetlistElaboration elabSignal for the cell), so the right side is
  the bound object; writeCont_assign then calls `CompileHelper::adjustSize(tps, ..., uniquify=true)`: the vpiUIntConst
  branch CLONES and masks (`UINT:`, decompile and size re-written), vpiBinaryConst truncates in place, every other
  encoding but vpiDecConst is sized IN PLACE (so golden's `[W-1:0]` bound INT:5 reads size 8 in the port's own
  typespec too, NQ n05), and a null `tps` returns the object untouched. `tps` is the bound variable's typespec: a
  net declaration always; a generate-scope assignment only for a plain module-level declared net or variable (the
  `bindVariable` reach of § genLpUintCaRhsOwnCopy148: a generate-local net, a select or an implicit net get nothing,
  GQ g03 size 64, g16 `p[1:0]` size 64). Measured faces: a module parameter read from a depth-1 generate scope gives
  the declared literal (`[4:1]` -> UINT:4 at the `4`, g01; `[8'h7:4'd2]` `$right` -> DEC:2 `4'd2` size 4, g10;
  `[1:5]` `$low` -> UINT:1 at the `1`, g11); the same parameter from a NESTED scope (g05, g12) and a generate-block
  localparam (g19) give the bare `UINT:<v>` (the lookup lands on the Value-built typespec); a net or variable operand
  shares its typespec's bound object across every scope that reads it (g03, g06, g08, g17: golden lists it once; the
  first draft minted a fresh copy per scope and read `type` at the second scope, `rqNetBound216` takes our own
  instance typespec's bound, and only when it holds the queried value); an arithmetic bound is ExprEval's reduced
  constant, INT for sub/mult/div (srlgRedIntSyn), located as § tpArrBoundAtLeftOperand196 locates a folded bound
  (`W-1` at `W`, `2*W-1` at `2*W`, g06, g15, n05, n08); a pasted-token bound reads its own token (`HI(1)` -> `11`,
  g22: the first draft went through emitSyntaxExpr, which read the raw source span `1)` and moved the elaborated case
  view from STRICT_NOTEQUAL_col to stage 1; the unsized decimal bound is now built from its token and the value).
  Declines (the call stays): an identifier bound (`[W:0]`, g13: golden hands back the parameter's value constant with
  an int typespec), an operand without a written range (`int` parameter, g14 b), a query that is not the whole right
  side (n20 b), and `$size` in a generate scope (g07: golden keeps the call with the parameter's value as argument).
  The definition view keeps the call in golden (every diff sits in the elaborated tree), and so does ours.
* **The `$size` fold (§ ndaSizeQueryFold216).** `compileBits(..., sizeMode=true)` always returns the `$size`
  sys_func_call; writeCont_assign's ExprEval reduce folds it to a fresh constant `UINT:<n>` (no location), decompile
  `<n>`, size 64, vpiUIntConst, then adjustSize's UINT branch masks and sizes it: n06 `logic [5:2] i` -> UINT:4 size 8,
  n13 onto `wire [2:0]` size 3, n14 `logic [3:0] i [5]` -> UINT:5, n15 `logic [0:2] v` -> UINT:3. A parameter operand
  keeps the call (n15 `$size(a)`: golden substitutes the parameter's value as the argument; not modelled).
* **The outside class writers (§ tfArgOutsideClassOrder216).** CompileStmt.cpp `compileTfPortList` runs
  `fC->populateCoreMembers(type, type, ts)` UNCONDITIONALLY on the typespec compileTypespec returns for every formal,
  and a package enum typedef name resolves to the typedef's own object (CompileType.cpp, the TypeDef branch), so every
  formal that names it moves it, the last compiled one winning (the § tfArgTypedefLastWriter146 decode). § 176 had
  modelled the classes of the typedef's own package (class NAME order, then the package's items) and declined any
  writer outside the package. The grid (cases/TW) reads golden's order for the outside writers: w01 another package's
  class method moves the elaborated object (12:21 over the own class's 5:21), w04 the same qualified (`p::e_t`), w05
  two outside packages `q`, `r` (the last, `r`'s, wins), w07 packages `zq` then `aq` in the FILE and `aq` < `p` < `zq`
  by NAME: `zq`'s method wins (name order, not file order), w08 a module-declared class after another package's class,
  w09 the typedef's own package `zp` sorting after the outside `aq`: its own class `K` wins (MiniAmiq's shape:
  `svaunit_pkg` compiles before `uvm_pkg`, and golden reads uvm_sequence_item.svh 352:37 in the 136 elaborated
  records), w18 two classes of one module: `Mb` (declared first) after `Ma` (name order). The definition listing keeps
  the package's own last subroutine (7:29 in every case; MiniAmiq uvm_globals.svh 271:61, `uvm_string_to_severity`'s
  `output uvm_severity sev`). Declines: an outside writer that is not a class method (w03: another package's
  package-level function; golden there also re-lists the home package's function under the importer with its own
  copy at the importer's writer, not modelled; w15: a module function), class writers in two modules, a class in an
  interface (w11, stage 1 at the base), an out-of-body definition of the outside class's method (w16, stage 1 at the
  base).
* **The importer's clone (§ tfArgImportCloneFollows216).** CompileHelper::importPackage `clone_tree`s every imported
  subroutine listing into the importer at the importer's compile, i.e. after the home package's own items moved the
  definition listing and before any class compile: golden's `q::g::y` (w01) and MiniAmiq's 24 clones of uvm_pkg's
  `uvm_report`, `uvm_report_enabled`, `uvm_string_to_severity` and the out-of-body `uvm_component::set_report_*`
  methods in `svaunit_pkg` (both listings) and `svaunit_vpi_interface` read the definition listing's moved span. Ours
  types those clones with one parentless copy left at the declaration span (uvm_object_globals.svh 242:1-248:16); the
  law moves a copy only when every ref_typespec naming it sits under a subroutine listed in another package or an
  instance (`refs=16` on MiniAmiq, trace).

## 2. The grid (cases/, 62 cases x 2 views = 124 case-views; evidence/grid/grid_pris_law.tsv)

Every case names its law in its first line (headers and second files too). `drivers/grid.sh` with
`GRIDBINS="pristine.bin law.bin" OFFCHECK=1`: **R11U216_OFF restores the pristine bytes on 124 of 124 case-views**;
each law's own switch restores them on its own family (evidence/grid/switches_own_family.txt: GQ 44/44 under
`R11U216_GENRQFOLD_OFF`, NQ 44/44 under the two net-declaration switches, TW 36/36 under `R11U216_TFOUTCLS_OFF`);
`R11U216_TFIMPCLONE_OFF` alone moves exactly the ten clone cases (w01 w05 w07 w08 w09 w10 w12 w13 w14 w18, both
views) back to line records (evidence/grid/switch_tfimpclone_alone.txt).

| family (law) | cases | pristine -> law (case-views) |
|---|---|---|
| GQ (§ genScopeRangeQueryFold216) g01-g22 | 22 | -> **EQUAL 28** (from stage 1 12, line 10, type 5, file 1: g01-g04, g06, g08, g09, g11, g15-g18, g20, g21 both views); stage 1 -> stage 1 14 (g05 g12 g19: the nested-scope parameter typespec, the right side now golden's; g07 g13 g14: declined faces; g10: the typespec's sized bound encoding); g22 stage 1 -> col (the parse view: the pasted-token column face left) and col -> col (elaborated, 23 -> 18 objects, a strict subset) |
| NQ (§ ndaRangeQueryFold216, § ndaSizeQueryFold216) n01-n22 | 22 | -> **EQUAL 36** (n01-n10, n13, n14, n16, n18-n22 both views); EQUAL -> EQUAL 1 (n12_el); depth -> depth 1 (n12: `$left` of an unpacked array, declined); stage 1 -> stage 1 6 (n11: the variable initializer face; n15: `$size` of a parameter; n17: net order across an include) |
| TW (§ tfArgOutsideClassOrder216, § tfArgImportCloneFollows216) w01-w18 | 18 | line -> **EQUAL 20** (w01 w04 w05 w07 w09 w10 w12 w13 w14 w17); EQUAL -> EQUAL 2 (w02, the own-package control); line -> fullname 6 (w06 w08 w18: every location now golden's, the first record the pre-existing module-class ref name `work@top::M::p::e_t` against ours `work@top.p::e_t`); line -> line 4 (w03 w15, declined); stage 1 -> stage 1 4 (w11 w16) |

**Totals: 84 case-views convert to EQUAL, 3 EQUAL stay EQUAL, none leaves EQUAL; no strict count grows.**
The adversarial shapes of caution (i) are in the grid: two files with the outside class at the own function's line and
column (w10, `args`), a qualified formal (w04), module and package classes beside package formals (w08, w18), an
included header (g21, n17, w13), macro-written queries, bounds and methods (g10, g20, g22, n19, n21, w12), a pasted
token (g22), a CRLF file (n16, w14), a range split over lines and an inactive branch (n22), an interface (g09, n10),
a child instantiated twice with different widths (n08, g18), a generate cell (n09), both views everywhere.

## 3. The gates (evidence/sweeps/, evidence/gates/, evidence/movers/)

Binaries (frozen, `chmod 555`, /tmp/r11u216_bin): pristine `8c724b6404258a8d5c9648ea1c376823` (byte-identical to the
main tree's build/slang-uhdm), law `53d6e821836b2ba7ad70ec7ca2060e72`, strict comparator
`fa6e4f42f252ae0ab69d9845003e71c5`. The patch applied to a fresh `745f66ab` worktree builds the law binary byte for byte (`53d6e821`), and `scripts/law_index.py --check` reads current there. Sweeps `tests/sweep.sh --jobs 3` from the worktree: pristine /tmp/r11u216_sP, law
/tmp/r11u216_sQ (same-length names). Every one of the 3273 `slang:` lines of each corpus sweep names that sweep's
frozen binary by path. Both sweeps exited 1 on the law-index staleness of the unpublished directory only (every stage
read 0 unexcused); tests/LAWS.md is regenerated in the patch.

| stage | pristine vs baselines | **law vs baselines** |
|---|---|---|
| probe | 3410 + 677, 0 / 0 / 0 | **3410 + 677: regressions 0, conversions 0, changes 0** |
| surelog | 929 + 25, 0 / 0 / 0 | **929 + 25: regressions 0, conversions 0, changes 2** |
| uhdm2rtlil | 1596 + 10, 0 / 0 / 0 | **1596 + 10: regressions 0, conversions 0, changes 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | **803 / 66 / 2 / 0, not excused 0; verdicts identical to the pristine sweep and to results/downstream_uhdm2rtlil.csv row for row** |

The two corpus changes (fresh law csv rows, baseline `differ:file(75)`):

    MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(61),,differ:fullname(61)
    MiniAmiq,testflags,STRICT_NOTEQUAL,differ:fullname(61),,differ:fullname(61)

The first record moved from #899 (`enum_typespec uvm_pkg::uvm_severity`, golden uvm_globals.svh 271:61-73, ours
uvm_object_globals.svh 242:1-248:16) to the base's second record #10107 (the `uvm_event_pool` typedef alias ref named
through the importing interface, `work@svaunit_vpi_interface.uvm_pkg::uvm_event_pool`, map 13's module-imported copy
name family, unchanged); the 14 records gone are all `uvm_severity` records. uhdm-cmp reads 0 lines on both
(evidence/gates/uhdmcmp_touched.txt). Canaries: `r11u107repro/canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16
changed=0; `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` PASS (ok=58), uhdm2rtlil `EXPECT_UNKNOWN=6` PASS (ok=2).

## 4. Movers, predicted by name before the law sweep

**Predictor** ([drivers/census.sh](drivers/census.sh)): the law binary with `R11U216_TRACE` over the 4087 probe cases
and both corpora in both modes, the corpus runs filtered by `^(?!(<the four fenced names>)$)` read fail-closed from
`$FENCED` (fenced hits 0 0 0 0); every law traces where it writes. Frozen (`chmod 444`,
[evidence/census/predicted.txt](evidence/census/predicted.txt), md5 `556a7184`, 2026-09-28 18:05:51) before the law
sweep: **2 row-modes (MiniAmiq d/t, 4 firings: § tfArgOutsideClassOrder216 `uvm_severity uvm_sequence_item` and
§ tfArgImportCloneFollows216 `refs=16`)**. The two fold laws fire on no probe case and no corpus row-mode (a census
with the previous development binary gave the same set; it was re-run after the last law change, the pasted-token
repair, and frozen from that run).

**Movers** (byteverify `SELFCHECK=1`: surelog 959 / 960 and uhdm2rtlil 1607 / 1608 flagged, path sets identical):
**surelog 2 databases (MiniAmiq d/t), uhdm2rtlil 0, probe 0 of 4087, downstream lanes 0 of 805: exactly the
prediction.** No coin moved between the two sweeps.

**Pass switch:** the law binary under `R11U216_OFF=1` writes MiniAmiq d/t's pristine bytes (`4db8f413be66`, both
modes); no probe case, uhdm2rtlil row or downstream lane carries a firing.

**Away-moved-record census** ([drivers/awayrows.py](drivers/awayrows.py), map 12's method, chain-keyed and flat;
[evidence/movers/away_census.txt](evidence/movers/away_census.txt)): 2 databases differ; **away 0 on both, toward 165
chain-keyed (189 flat) each**. Positive control (the two sweeps swapped,
[away_census_reversed.txt](evidence/movers/away_census_reversed.txt)): **away 165**, naming the moved `uvm_severity`
records.

**UVM order-blind distance** ([drivers/uvmdist.sh](drivers/uvmdist.sh); [evidence/uvmdist.txt](evidence/uvmdist.txt)),
pristine -> law at 745f66ab: MiniAmiq 6528 -> **6339** (sym 14780 -> 14402), SeqDriver 5071, SimpleUVM 1983, Scoreboard
1453, BuildUVMPkg 713 unchanged (pass 212's figures at b69dc2da reproduce at this base).

**Determinism** ([drivers/det.sh](drivers/det.sh), three concurrent runs per binary per row-mode;
[det_law.txt](evidence/det_law.txt), [det_pris.txt](evidence/det_pris.txt)): Earlgrey_0_1, SeqDriver, SimpleUVM and
BuildUVMPkg one hash per mode in both binaries, equal to their sweeps; Scoreboard d pristine two hashes
(`50f1e9cd5845`, `de42a8e468b9`), law one (`de42a8e468b9`): the known svunit listing coin; MiniAmiq pristine two hashes
(`322b782ebb31`, `4db8f413be66`) and law two (`e980a33e2671` three times, the sweep's `ae2f0060a863`): the known
storage-order coin, the law pair's dumps identical ordered and order-blind (0 lines each). No new coin.

**Downstream faces** ([drivers/dsfaces.py](drivers/dsfaces.py), the gate's own `one()`, fresh `GOLDEN_CACHE`, both
binaries; evidence/downstream/): pass 212's 271-case face set: **pristine 226 IDENTICAL / 22 EQUIVALENT / 16 DIVERGENT
/ 6 STATUS_DIFF / 1 SLANG_REJECT, law 227 / 22 / 15 / 6 / 1: one verdict change, r11u173 N1 `rq/q08` DIVERGENT ->
IDENTICAL**. This directory's 58 single-file cases plus q08: **10 DIVERGENT -> IDENTICAL** (q08, GQ g01 g02 g04 g05
g11 g12 g14 g20, NQ n04), 48 IDENTICAL stay IDENTICAL, NQ n11 DIVERGENT on both (the variable initializer face).

**Wide byte control** ([drivers/widebytes.sh](drivers/widebytes.sh); evidence/wide/): every earlier case file under
tools/probe that writes a range query or `$size`, or holds a class and a package import (1287 files, 2574 case-views,
pristine against law, fence fail-closed): **14 case-views move (7 files), every one carrying a firing and restored to
pristine bytes by `R11U216_OFF`, every one toward golden**: r11u173verify rq/q03 and q08, v11u176repro CM/c20 and
SP/s02, v11u212repro E/e09 and G/g13 reach EQUAL in both views, E/e16 in the elaborated view (its parse view moves
from stage 1 to `depth`, the unpacked-array `$left` face of n12) ([movers_judged.txt](evidence/wide/movers_judged.txt)).

## 5. Residues and faces, ranked (the brief's items first)

1. **Item (1), pass 212's residues.** q08 decoded and written (IDENTICAL downstream, EQUAL both views); the range-query
   branch of § ndaSysCallNetTs212 is now folded in the elaborated view (v11u212 e09, g13 EQUAL both views, e16
   elaborated EQUAL); its definition-view stamp stays, as golden writes it. Not attempted: the instance-folded stamp
   of a parameterized net (e05, g11), the signed net's stamp, the elaborated net-declaration left side (n02, n06 of
   r11u212 NS), member order across a late include (a06; this grid's n17 is the net twin), the type-parameterized /
   bound parse-view names (g08, g09), the exposed names (b02, c02, c07, a13), the anonymous struct span (s08, s18),
   the anonymous union member refs (s09), the size dimension without an override (f04), g12. c06: the inner size
   cast's typespec is ExprEmit's (the sister's; ExprEmit's cast emission, grid r11u212 NS n04). InterfArrayBind d
   `fullname(1)`: ExprEmit's (§ elabIfArrIdxChainName205 family). Rggen d #23164: the Surelog TypespecCache defect.
2. **Item (2), the formal writer-order family.** MiniAmiq #899 closed (above). **BuildUVMPkg #3245 (`uvm_action`):**
   the typedef is an `int` alias (a SimpleType, cloned per use), its 42 `int_typespec uvm_pkg::uvm_action` records
   read uvm_pkg.sv 8075:9 in golden and ours alike at this base (#3245 excused by the comparator since pass 209), the
   row's first record is #26067 (a ref_obj column, ground A), and the census shows no firing there (no class writer
   outside uvm_pkg). **cfg_func_width_loop d/t `line(3)`, decoded, not written:** its
   #464 is the param_assign value constant's ref_typespec of `u.M` (`3'b101`), golden an alias clone of `q::mask_t`
   located at the FUNCTION FORMAL `maxw(mask_t cfg)` 27:40-46 with the folded range `[0:2]` (a SimpleType typedef is
   cloned per use in CompileType.cpp, so this is the elaborated formal's own clone, reached by the parameter
   binding), ours a clone at the typedef 16:11-25 with the unfolded `NF-1` (#472 type); map 13's lesson stands (the
   kept call differs past the structural record).
3. **The remaining UVM enum listings** (map 13's F-family view, MiniAmiq after this pass): the class-member references
   golden binds to the ELABORATED object where ours binds the definition listing (14 `uvm_severity` records under
   uvm_pkg classes, ours 271:61, golden 352:37; pre-existing, they read the declaration before this pass), and the
   partially modelled enums with records left at the declaration (`uvm_check_e`, `uvm_endianness_e`, `uvm_hier_e`,
   `uvm_path_e`, `uvm_phase_state`, `uvm_phase_type`, `uvm_predict_e`, `uvm_radix_enum`, `uvm_active_passive_enum`:
   golden holds at most one record at the declaration, ours 6 to 93 each): the next writer-order step on this ground.
4. **MiniAmiq d/t's new head #10107** (the typedef alias ref named through the importing interface) and the svaunit
   clone names of item (3): not attempted.
5. **This pass's own declines and exposed faces**: the nested-scope / generate-localparam parameter typespec (g05, g12,
   g19: golden's elaborated typespec is a bare Value-built logic_typespec; the parameter's typespec emission, the
   sister's ParamEmit), the sized/based bound encoding of a parameter's range (g10, UINT against golden's HEX/DEC),
   the identifier bound (g13), `$size` / `$high` of a parameter (g07, g14 b, n15: golden keeps the call with the
   parameter's value constant as the argument and a typespec stamp; ExprEmit's system-call argument emission), the
   module variable initializer golden keeps as a call (n11, the elaborated logic_var's vpiExpr; ModuleEmit),
   the unpacked-array `$left` (n12 / e16, depth), the pasted-token column face (g22), the module-scope class
   reference name (w06, w08, w18: `work@top::M::p::e_t`), the declined writer shapes (w03, w11, w15, w16).
6. **Items (3)-(7) not attempted**: the svaunit class-method clone families, Scoreboard d `fullname(188)` and SimpleUVM
   d/t `fullname(236)` (unchanged), the sister's hand-offs of item (5), ibex_tracer, OutputSize, struct_param_func_config,
   HierPathTypespec d, Earlgrey d/t `endcol(45)` (unchanged), r11u204's B4/N7/N8/N9, pass 206's residues and r11u213's
   under-reaches, the downstream faces UD/u04, GV, u01, N7, g12 (re-measured in the 271-case set: unchanged).
7. **Item (8), the switch-reach repair: not attempted.** The reach facts stand as r11u213 and pass 210 measured them
   (R11U202_OFF also drops § unitClassTdEndAtInitIfcPrg206 and § classScopeTdRetBuildsOwner206; R11U200_OFF and
   R11U200_CLASSTDRET_OFF also drop the second; R11U205_OFF also drops pass 209's three r11u205 laws). This pass's own
   reach: `R11U216_OFF` all five laws; `R11U216_TFOUTCLS_OFF` its law and § tfArgImportCloneFollows216; every other
   switch its own law (section 2).

## 6. Fence and process

* Every driver that reads corpus sources or databases reads the four fenced names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (env.sh, case.sh, census.sh with `^(?!(...)$)` and a fenced hit
  count of `0 0 0 0`, rowhead.sh, widebytes.sh, awayrows.py, dsfaces.py, det.sh, uvmdist.sh). The gate sweeps
  dispatched every row; no binary, gdb or script ran on a fenced test's sources or databases outside them; no fenced
  head was read. A grep of this directory for the four names reads 0.
* Builds `-j 2`; the pristine binary was frozen before the first edit; no source was edited while a unit compiled.
  Development binaries dev1-dev11 were measured on the grid only; the law binary is dev11, frozen before the census.
  Scratch `/tmp/r11u216_*` only (binaries `_bin`, sweeps `_sP` `_sQ`, census `_cen` (and the superseded `_cen0`), OFF run
  `_sO`, goldens `_g`, `_dsg`, `_dsg2`, downstream `_dsf`, `_dsf2`, determinism `_det`, wide control `_wb`, `_x`);
  worktree /tmp/wt_r11u216. Nothing under results/, tests/ (but the regenerated tests/LAWS.md) or third_party/ was
  written; no stash; `GOLDEN_DEFER` unset. The processes stopped during the pass were this pass's own (a census run
  and a wide-control run restarted after a driver fix), each checked by its command line first.

## 7. Files

* [cases/](cases): GQ (22, g21 with its header), NQ (22, n17 with its header, n16 CRLF), TW (18, w10 two files via
  `args`, w13 with its header, w14 CRLF).
* [drivers/](drivers): env.sh, case.sh, grid.sh, dumpdiff.sh, rowhead.sh, census.sh, switches.sh, widebytes.sh,
  awayrows.py, dsfaces.py, det.sh, uvmdist.sh.
* [evidence/](evidence): grid/ (the grid and the switch checks), census/ (the frozen predictor, firings, trace
  details, freeze time), movers/ (byteverify, probe and downstream-lane movers, pass switch, away census and its
  reversed control), sweeps/ (the two sweep logs), gates/ (canaries, uhdm-cmp), downstream/ (face verdicts, both
  binaries), wide/ (the wide byte control), det_law.txt, det_pris.txt, uvmdist.txt.
