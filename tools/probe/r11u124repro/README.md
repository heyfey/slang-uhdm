# r11u124 — the expression/parameter ground of the strict axis (implementer)

Base `7bd06f52` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`
(no edit to `src/EmitHelpers.h` or `src/StmtEmit.cpp`). Worktree `/tmp/wt_r11u124`, built with the
system-deps config at `-j 2`.

| binary | md5 |
|---|---|
| pristine (byte-identical to the main tree's `build/slang-uhdm`) | `cb7b39bd1fa880fa84d54d11d9ff8ce2` |
| law (this patch) | `4bfab8b9a6fc92d4c9b8d2fc29be022b` |
| `build/uhdm-strictcmp` (identical to the main tree's) | `88bf7040c706f80686ea981e6a8650c8` |

Both exporter binaries were frozen (`chmod 555` copies) before any measurement; every `cmds.txt` of
both law sweeps names the frozen law binary (3273 of 3273 slang lines; the other 50 rows are
producer failures with no slang line).

## Result

| axis | pristine | law | delta |
|---|---|---|---|
| surelog strict-equal (of 954 judge-equal row-modes) | 521 | **565** | +44 |
| uhdm2rtlil strict-equal (of 1606) | 1072 | **1134** | +62 |
| probe strict-equal (of 4087) | 1712 | **1846** | +134 |
| surelog scoreboard | 480/3 + 474/3 | 480/3 + 474/3 | regressions=0 conversions=0 changes=0 |
| uhdm2rtlil scoreboard | 803/1/67 both modes | same | regressions=0 conversions=0 changes=0 |
| probe gate | EQUAL=4087 | EQUAL=4087 | |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 rows changed (verdict and `differs`) |

No row-mode's strict column worsened (method in "Census"): 106 corpus row-modes and 134 probe
cases turn equal, and every other changed cell loses objects or moves its first difference later.

## Laws (all under `R11U124_OFF=1`, each droppable alone)

| law | switch | site (file + § token) | cluster(s) |
|---|---|---|---|
| § impLhsCloneFile124 | `R11U124_LHSFILE_OFF` | ParamEmit.cpp, the def-view imported-parameter Lhs clone | C0003 |
| § aggArrayOuterRangeLoc124 | `R11U124_AGGRNG_OFF` | ParamEmit.cpp, emitPackage's packed-array-of-aggregate typedef | C0019 (that shape) |
| § paramValueIsDefRhs124 | `R11U124_PVAL_OFF` (+ `R11U124_PVALNEG_OFF` for the clearing half) | ParamEmit.cpp, post-pass run from drainShareDefParamTs | C0020, C0034, C0044 and every other parameter-value cell |
| § realLitValueIsText124 | `R11U124_REALTXT_OFF` | ExprEmit.cpp, emitExpr's RealLiteral case | real-literal constant values (Shortreal, realexpr) |
| § castTsFile124 | `R11U124_CASTFILE_OFF` | ExprEmit.cpp (the three `pendingCastTs` push sites + the registry) and ParamEmit.cpp (the stamp in drainShareDefParamTs) | C0015, C0028 |
| § pkgQualFoldSpanByView124 | `R11U124_QSPAN_OFF` | ParamEmit.cpp (the elaborated fold's qualifier-span branch) and ExprEmit.cpp (the def-view NamedValue fold) | C0014 |
| § incDecMemberPathIsLvalue124 | `R11U124_INCDEC_OFF` | ExprEmit.cpp, the unary inc/dec case + the MemberAccess hier_path builder | C0007 / C0009 (the inc/dec subset) |

`R11U124_OFF=1` restores pristine bytes on all 81 cases of this directory and on the eight example
rows (HierPathStructTypespec, IOClassStruct, ParamConstPush, CastSize, Shortreal, TypedefRange,
ImportedParameter, BitsLogic); each single switch restores pristine bytes on a case where only its
law fires (BitsLogic, CastSize, ImportedParameter, real/r09_proc, c14/p07_modparam, hp/h01_post,
rng/g01_struct).

### § impLhsCloneFile124 (C0003)
Surelog's def-view Lhs of an imported param_assign is a `clone_tree` copy of the package's own
parameter (CompileHelper::importPackage, CompileHelper.cpp:265), so it carries the declaration's
VpiFile with its span. Our clone (`upLhs9`) copied the four span fields and not the file. The law
copies `up`'s VpiFile. Example uhdm2rtlil/testflags/ImportedParameter: parameter TxWidth golden
`dut.sv 2:18:2:25`, ours ` 2:18:2:25` → strict `differ:file(1)` → **equal**.

### § aggArrayOuterRangeLoc124 (C0019, the packed-array-of-aggregate typedef)
`typedef a[5:0] b` with `a` a struct/union: the outer packed_array_typespec's own range and its two
bound constants were minted with no location (`mkB2`); the alias-actual twin already carries the
dimension-token locations. Golden TypedefRange: range `dut.sv 5:13-18`, bounds `5:14-15`, `5:16-17`.
The law locates the outer range and bounds at the same tokens (`scanDimSpans`). TypedefRange/testflags
`differ:file(4)` → `differ:fullname(1)` (the remaining object is the F02 identity residue below).
The other C0019 rows (`range < logic_typespec < ref_typespec`, 16 rows, LargeValue2Struct) come
from a typedef-clone site outside this ground (the constants are copied with span and no file;
the clone is minted from TypeEmit's typedef clone path) — residue R3.

### § paramValueIsDefRhs124 (C0020, C0034, C0044)
DECODE. Surelog writes a parameter's VpiValue in one place, `compileParameterDeclaration`
(CompileHelper.cpp:4028-4034): after the definition-compile Rhs is reduced,
`if (rhs->UhdmType() == uhdmconstant) param->VpiValue(c->VpiValue())`. The elaborated instance
`clone_tree`s that parameter and deliberately keeps "the value of the parameter used during
definition" (UhdmWriter.cpp:497-520). MEASURED on every golden of the pristine sweep
(drivers/pvcensus.cpp): definition listings 11888/11888, packages 10253/10253 obey "value = the
Rhs constant's value, none when the Rhs is not a constant"; elaborated instances 97777/97777 carry
their definition's value (not their own, possibly overridden, Rhs). Our parameter objects took
their value from a separate fold predicate (UINT where the Rhs constant minted INT through
§ pkgParamMulDivModIsIntReduce96 / § addMintFollowsOperandMint97, none for `$bits(type)` folds).
THE LAW is a post-pass (the Rhs is only final after the drains): definition modules/interfaces,
both package views and classes take their own direct param_assign's Rhs value; elaborated
module/interface instances take the definition's value by (name, vpiImported); the same-named own
entries of each scope's Parameters listing follow. An object is written only when the scope owns it
(vpiParent = the scope or the param_assign): we share some parameter objects between views that
Surelog clones. Keyed by name AND vpiImported, and an ambiguous name leaves the listing alone —
the first cut keyed by name alone moved probe `r10earl85repro/g4_shadow85` (a module parameter
shadowing the imported one) and was fixed before the sweep. It extends the landed mint table: the
Rhs constant's mint (the INT laws) now reaches its parameter; no second predicate. Simulation
before landing (drivers/pvjoin.py + the rule applied offline): 1795 parameter cells fixed, 0 broken.
Examples: BitsLogic p `UINT:12` (was none) → surelog/testflags/BitsLogic **equal**;
HierPathStructTypespec BufferCycles/BufferSizeBits/MsgFifoDepth `INT:` in the package and elab
views (was `UINT:`), row `differ:fullname(82)` → `(62)`.

### § realLitValueIsText124
Surelog's `slRealConst` case writes `StrCat("REAL:", SymName(token))` (CompileExpression.cpp:569-577):
the literal as written (`REAL:0.5`, `REAL:1_000.5`, `REAL:4.0`); only the elaborated parameter fold
goes through `Value::uhdmValue`'s `std::to_string` (`REAL:123.450000`). We wrote `%f` everywhere.
The law writes the source text except in the elaborated parameter-init case (which keeps `%f`, as
its decompile already did). Grid `real/`: r01, r09 → equal; r02/r04 lose their value facet.

### § castTsFile124 (C0015, C0028)
DECODE. The typespec of a re-emitted cast (`int'(x)`, `5'(a)`, `byte'`, `logic'`, `bit'`,
`shortint'`, `integer'`) is DEFERRED: ExprEmit pushes a `pendingCastTs` record (span fields only) and
ModuleEmit's end-of-write-phase drain mints the typespec with VpiLineNo/Col/EndLine/EndCol written
directly, never through setLoc — so no VpiFile, where golden's copy has `dut.sv` like every located
object (§ vpiFileOnEveryLocated117). The natural fix site is that drain (ModuleEmit.cpp, the
"Deferred re-emitted cast typespecs" loop, and the `PendingCastTs` record in include/UhdmExporter.h),
the sister pass's ground; this law stays on this ground: each ExprEmit push also registers
(ref_typespec, file, line) and ParamEmit's end-of-export pass stamps the file on the drained
typespec when it is still file-less and its line matches. A MACRO-expanded cast additionally got the
raw 0-based macro-buffer column (`3:0-3:0`); the push now lays it out with `locLineCol`, as setLoc
does (golden `3:67-68`). Idempotent with a later drain fix. Grid `cast/`: 8 cells → equal (k01, k02,
k04, k05, k06, k08, k09, k15), 5 controls unchanged equal, 4 stage-1 cells unchanged (same cmp line
counts). CastSize/testflags `differ:file(1)` → **equal**; Shortreal/testflags `differ:value(2)` →
**equal** (with the real law).

### § pkgQualFoldSpanByView124 (C0014)
A written `pkg::P` folded to the parameter's Rhs constant spans the QUALIFIER alone (`pkg::`,
the package-scope node Surelog populates the fold from, CompileExpression.cpp:2717-2830) in the
views that compile the reference — the package listing and every module DEFINITION listing (a
def-module import copy is the package param_assign's `clone_tree`) — and the WHOLE reference in the
ELABORATED module listing. We had it reversed for imports (qualifier on the elab copy, whole on the
def copy) and whole for a module's own qualified default. Golden ParamConstPush `base_pkg::USAGE`:
package 7:38-48, def module 7:38-48, instance 7:38-53. The law: ParamEmit's elaborated
qualifier-span branch applies to package views and def listings only; ExprEmit's def-view fold of a
bare qualified initializer takes the qualifier span. Grid `c14/`: 6 cells → equal (p01 p02 p03 p06
p07 p08), 2 stage-1 cells unchanged. ParamConstPush/testflags `differ:endcol(3)` → **equal**.

### § incDecMemberPathIsLvalue124 (C0007 / C0009, inc/dec subset)
Surelog compiles the operand of `++`/`--` through its Variable_lvalue case, so a member path there
takes the LVALUE convention the builder already applies to assignment targets: the base ref_obj on
the first member's token and the leaf ref_obj with a name-only full name (golden IOClassStruct
`access_record.read_count++`: both refs 18:20-30, leaf full name bare; BuildUVMPkg `lindex.used++`,
`req_s.sequence_ptr.m_wait_for_grant_semaphore--`, `f(sequence_ptr.m_next_transaction_id++)` —
census drivers/hpcensus.cpp + hpjoin.py). The unary case names its operand (pointer identity, so an
index or argument inside it stays rvalue); `this.` paths are excluded (their own law). Grid `hp/`:
8 cells → equal, the rvalue control h06 stays equal, h09 (`this.n++`) unchanged.
IOClassStruct/testflags `differ:fullname(7)` → `(5)`.

## Grids (pristine → law, per cell; evidence/grid_*.txt)

| grid | law | cells | → equal | improved | unchanged (controls / stage-1 / residue) |
|---|---|---|---|---|---|
| c12 | § impLhsCloneFile124 (a09 a10 a14) + residue R1 (the rest) | 14 | 3 | a06 (value→fullname) | 10 |
| c14 | § pkgQualFoldSpanByView124 | 8 | 6 | | 2 stage-1 |
| cast | § castTsFile124 | 17 | 8 | | 5 equal controls, 4 stage-1 |
| real | § realLitValueIsText124 | 10 | 2 | r02, r04 | 6 stage-1 |
| hp | § incDecMemberPathIsLvalue124 | 10 | 8 | | h06 control equal, h09 this-path |
| rng | § aggArrayOuterRangeLoc124 | 6 | 0 | g01 g02 (file→fullname), g04 (8→5 objects) | g06 control equal, 2 stage-1 |
| c13 | residue R2 (decode only) | 10 | 0 | | 10 |
| f02 | residue R4 (decode only) | 6 | 0 | | 6 |

Every stage-1 (NOT_EQUAL) cell keeps its exact uhdm-cmp line count on both binaries.

## Census (the whole strict column, law sweep vs pristine sweep, row by row)

Sweeps: `tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil"` with `SLANG_UHDM` exported,
workdirs `/tmp/r11u124_wdP` (pristine) and `/tmp/r11u124_wdE` (law), same length. The pristine
strict column equals `results/golden_*.csv` on every row (drivers/strictdiff.py: 0 differences).

drivers/strictdiff.py (evidence/strictdiff_*.txt):

| | TO-EQUAL | BETTER (same field, fewer objects) | FIELD-CHANGE | WORSE | STATUS |
|---|---|---|---|---|---|
| surelog | 44 | 39 | 22 | 0 | 0 |
| uhdm2rtlil | 62 | 58 | 10 | 0 | 0 |
| probe | 134 | 161 | 72 | 0 | 0 |

drivers/worse.py re-walks every changed row-mode against the same golden with both databases and
compares record by record: a row is WORSE when the law database differs from golden at an object
the pristine one matched (before the earlier of the two walk divergences) or its walk diverges
earlier. Result: 129/129 changed corpus row-modes and 233/233 changed probe cases OK; and the 732
judge-equal, strict-NE corpus row-modes whose column did NOT change: 732/732 OK
(evidence/worse_*.txt). The FIELD-CHANGE rows are fixed first objects revealing the next field
(e.g. `file(4)` → `fullname(1)`).

Converted row-modes, with the laws the pristine database predicts for each (evidence/to_equal_rows.txt):
36 § impLhsCloneFile124 alone, 34 § castTsFile124 alone, 10 § paramValueIsDefRhs124 alone,
6 § realLitValueIsText124 alone, 20 by two or three of them together (CASTFILE+LHSFILE 8,
CASTFILE+LHSFILE+PVAL 4, LHSFILE+PVAL 2, LHSFILE+QSPAN 2, CASTFILE+REALTXT 2, PVAL+QSPAN 2).

## Gates

1. Build: md5s above; pristine byte-identical to the main tree's.
2. Probe: `EQUAL=4087 (of 4087)`; probe strict 1712 → 1846.
3. Corpora: `regressions=0 conversions=0 changes=0 only-fresh=0 only-committed=0` in both.
4. Downstream (`tests/sweep.sh --corpus downstream`, law binary): `EQUIVALENT=2 IDENTICAL=803
   SLANG_REJECT=66 (of 871); not identical and not excused=0`; row join against
   `results/downstream_uhdm2rtlil.csv`: 0 of 871 rows changed (verdict and `differs`), so pass 120's
   eight rows and pass 121's arb_idx_cast stay IDENTICAL.
5. uhdm-cmp: every row-mode keeps CMP_EQUAL (the scoreboard join), every probe case EQUAL.
6. Byteverify (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law vs pristine workdir):
   surelog `PATH_SETS_IDENTICAL (960 paths)`, `MOVERS: 121 / 960`, selfcheck 959/960;
   uhdm2rtlil `PATH_SETS_IDENTICAL (1608 paths)`, `MOVERS: 138 / 1608`, selfcheck 1607/1608.
   PREDICTED BY NAME: drivers/predict124.cpp reads each PRISTINE database and reports which law's
   trigger is present (evidence/predictions_pristine.txt). 259/259 movers were predicted; 12
   predicted databases did not move (the predicate is wider than the law: 8 CASTFILE hits are
   file-less typespecs under non-deferred casts — UnionCast, CastStructArray, jeras_union — and 4
   QSPAN-elab hits are elab constants ending in `::` from another fold case). Movers by law:
   LHSFILE 135, CASTFILE 85, PVAL 74, QSPAN 30, REALTXT 19, INCDEC 11, AGGRNG 6 (a database can
   carry several). The UVM coin family (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard) moves in both
   modes and each is predicted (INCDEC, LHSFILE, PVAL, REALTXT). (The predictor's LHSCLONE column
   belongs to the reverted attempt R1 and is not a law here.)
7. Canaries: `canaries.sh` and `ctcan2.sh` print CHANGED on every row for the PRISTINE csv too
   (the committed csvs are CRLF; the scripts compare `$NF`), so the gate is read as law output vs
   pristine output: uhdm2rtlil identical; surelog differs only in strict counts moving toward
   golden (Earlgrey_0_1 `line(5180)` → `line(5172)`, BuildUVMPkg `fullname(346)` → `(342)`,
   EvalFuncNamed `file(2)` → `equal` / `file(14)` → `fullname(12)`); every status identical.
8. Earlier passes' cases as byte/verdict controls (drivers/grid.sh, pristine vs law,
   evidence/controls_earlier_passes.txt): r11u118repro 0/56, r11v11u118repro 0/56, r11u120repro 0/44,
   v11u121repro 0/41, r11u123canon 0/22 changed; r11u119repro 2/78 (g3 n_dir_real, n_nodir_real:
   value → equal, § realLitValueIsText124), r11v120repro 2/47 (d08_top_ports_inout,
   t02_nested_named: file → equal, § impLhsCloneFile124), r11u121repro 1/83 (s08_imp_ps: file →
   fullname, the CFG Lhs clone gets dut.sv, § impLhsCloneFile124). All toward golden.

## Decoded, not landed (ranked residues)

R1 — C0012, the imported param_assign Lhs clone (58 row-modes, alone-yield 0). DECODED: the clone
exists in our def view, but its gate reads `topView`, which § modDefImportShape FLIPS to true for
every materialized import of a module WITH a parameter port list — so exactly those modules share
their Parameters entry (grid c12: a01-a08, a12 keep `depth`, the body-import and no-port-list
cells a09 a10 a14 already clone). The gate on the physical view (`defViewOrig9`) was measured
(§ impLhsCloneFlippedDefView124, NOT landed; the c12 cells a01-a08 a11-a13 name it): it clones a01-a08 but moved BlackBePipeInt (both modes),
struct_param_func_config (both modes) and probe r11u20repro/b4 to CMP_NOTEQUAL; restricted to
non-aggregate element types it still moved BlackBePipeInt. The flipped view's leftover/typespec
chain (pendingParamTs, memLeftStamps) is bound to the shared object; cloning needs that chain
re-pointed. Reverted; the grid stays as the next pass's ground. The unpacked-array shape (a13) does
not clone even in the physical def view.

R2 — C0013 (57) / C0037 (34), grid c13 (its cases name the residue law § patFlattenTsNoParent124,
NOT landed): DECODED for the pattern holder: golden's NULL-parented ref_typespec on
an assignment-pattern Rhs is the one `ExprEval::flattenPatternAssignments` mints for its reordered
copy (UHDM templates/ExprEval.cpp:931-934, `rtps` never parented), and that copy replaces the
package param_assign Rhs when the parameter is READ through `pkg::P`
(CompileExpression.cpp:921-952 → expandPatternAssignment → CompileHelper.cpp:5233) — grid c13: q02,
q03, q08, q09, q10 (qualified reads) and q05 (the module import copy) are NULL-parented in golden,
q04 (`pkg::P` as a module parameter default) stays parented, q06 (no read) has no op typespec at
all. Our op typespec is attached by ParamEmit's "(anyUnknown || packedArrayOp || ... structOp ...)"
case with `rt->VpiParent(opr)` and a stored full name. Landing needs the "was this parameter read
qualified" set that § pkgElabPatMemberStamp58 already models. C0037 (LocalParamInNestedForLoops):
golden's constant is SHARED with an orphan param_assign of the generate-scope parameter `Offset`
(its vpiParent is a param_assign with no parent); not a parent-policy law.

R3 — C0019 remainder (16 rows): `range < logic_typespec < ref_typespec` constants copied with span
and no file inside typedef clones (LargeValue2Struct); the copy site is outside this ground.

R4 — F02 (fullname inside a typespec subtree), grid f02 (its cases name the residue law
§ pkgTdSameNameOrphan124, NOT landed). DECODED for the r11u123 `pa::pa::st_t` case: there is
NO double-prefixing name site. The full name is ComputeFullName over the parent chain: our
enum/struct typespec is parented at the package (`pa` + `pa::st_t` with the package column →
`pa::pa::st_t`); golden's TopPackages copy is orphaned (grid f02 t1: one enum parented at the
package, three NULL-parented copies; census drivers/pkgtscensus.cpp over every golden: TopPackages
struct_typespec parents module_inst 1374 / PKG 262 / NULL 48, enum_typespec module_inst 1277 / PKG
140 / NULL 54) — Surelog's later `clone_tree` calls re-parent the shared package typespec to
whichever instance cloned it last. USE-SITE-DEPENDENT: an identity residue, not a
declaration-stable parent policy. Vector typedefs keep the package parent (f02 t6, equal).

R5 — hier_path other shapes (C0007/C0009 outside inc/dec): the dotted builder's cont_assign LHS
(ComplexHierPath `assign B.x = 0`, 302 objects), struct-PARAMETER member reads outside param-init
(NoReducTypespec `Cfg.NoSlvPorts` in a range, gen-if/gen-for conditions, part-select bounds), and
the 3-element leaf full-name forms (census evidence in drivers/hpcensus.cpp + hpjoin.py).

R6 — C0015/C0028 are landed here through the push site; if the sister pass fixes the ModuleEmit
drain itself, § castTsFile124's stamp becomes a no-op (it writes only a file-less typespec).

R7 — pass 121's own residues (brief item 9: the single-iteration generate loop's placeholder cast,
`pkg::CFG.f[3:0]` naming, casts inside generate-scope functions, the b17 member fold): not reached.

C0001 (gen-scope parameter file, 206 row-modes, alone-yield 116 on the law sweep's analysis) is the
sister pass's ground (ModuleEmit) and untouched.

## Files

* `c12/ c13/ c14/ cast/ real/ hp/ rng/ f02/` — the cases (`dut.sv`, first line names the law or
  the residue).
* `drivers/run_case.sh` (one case: golden with the probe flags cached by content md5, ours, uhdm-cmp,
  strictcmp), `drivers/grid.sh`; `drivers/strictdiff.py` (strict-column row join),
  `drivers/worse.py` (record-level worsening check), `drivers/rows.py`, `drivers/probe_rows.py`,
  `drivers/probe_strict.py` (the per-case probe strict column), `drivers/dsdiff.py` (downstream row
  join); censuses `drivers/pvcensus.cpp` + `drivers/pvjoin.py` (parameter values),
  `drivers/rtcensus.cpp` + `drivers/rtjoin.py` (ref_typespec parents), `drivers/hpcensus.cpp` +
  `drivers/hpjoin.py` (hier_path elements), `drivers/pkgtscensus.cpp` (package typespec parents),
  `drivers/uhdm-parents.cpp` (parent chains), `drivers/predict124.cpp` (mover prediction),
  `drivers/analyze.py` + `drivers/run1.sh` + `drivers/yieldmap.py` (the r11u122 analyzer re-pointed
  at this pass's dumps, for the remaining-row yield map). Build a C++ driver with
  `g++ -O1 -std=c++17 X.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj`.
* `evidence/` — sweeps, strict diffs, worse checks, byteverify, predictions, downstream join, grids,
  earlier-pass controls.
