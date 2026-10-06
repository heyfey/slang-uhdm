# v11u252: adversarial verification of r11u252

Base 99ea3716 (`matrix-1.87`, pass 250). This directory verifies the r11u252 patch (twelve laws in
src/ParamEmit.cpp, src/ExprEmit.cpp and src/StmtEmit.cpp behind src/R252.h, delivered as /tmp/r11u252.patch, md5
a2002339...). It also carries the verifier's four refinements, each behind its own switch.

**Verdict: every headline number reproduces bit for bit, and every gate holds. Fresh cases found four defects on
legal SV where pristine was right and the law moved records away from golden. One of them, VS vs01, took a
STRICT_EQUAL case-view to STRICT_NOTEQUAL in both views. All four are fixed behind their own switches. The fixes move
no gate database: 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream databases differ from the law's.**

| binary | md5 | how |
|---|---|---|
| pristine | de0c6d846229ddfb799e37cb0cbb28b8 | /tmp/wt_v11u252pris at 99ea3716, the implementer's pristine md5 |
| law (r11u252) | ec509aa1d646c51552387d68d1c3796a | /tmp/r11u252.patch applied on a fresh 99ea3716, the implementer's law md5 |
| fix (v11u252) | 00c7bed5eefdca49d682e33b2f55cc93 | the law tree plus this pass's four refinements |

All three binaries link slang 12.0.0+545f88b2e. They were frozen (chmod 555) under /tmp/v11u252_bin before any
measurement with them. Each cmds.txt path list was filtered by $FENCED before any file was read. In every sweep,
each of the 3265 slang command lines names that sweep's own frozen binary. The other 50 cmds.txt files belong to rows
where slang never runs.

## The refinements

`R11V252_OFF` drops all four and restores the law's bytes on every case-view. `R11U252_OFF` still restores pristine
bytes, since each refinement sits inside a law's branch. Each one traces through `R11U252_TRACE`.

| refinement | switch | site | what |
|---|---|---|---|
| § concatSelInParamInit252v | R11V252_CONCATSELPARAM_OFF | ParamEmit `concatSelReadNames252` (§ impPatConcatSelReadParents252's reach) | The law read the elements of a concatenation parameter as "selected" whenever ANY element select or select name anywhere in the design had the concatenation's name as its base. That included a continuous assignment `assign o = ALL[0]` (VS vs07), a module signal of the same name (vs01), a selected module concatenation in an assignment (vs08), and a module header parameter of the same name selected in another header parameter (vs15). Golden keeps the base listing in all of them, and the law moved two records away on each. vs01 went STRICT_EQUAL -> STRICT_NOTEQUAL fullname in both views. Now a select counts only when it is inside a PARAMETER initializer, and only when its enclosing module or package declares no plain parameter of that name. Golden agrees with this rule: VS vs12 (a body localparam), vs13 (a module concatenation selected in a module localparam) and vs14 each move two chain records toward golden, as r11u252's S s13 and decode S/d04 do. |
| § memReadHomePkgKey252v | R11V252_MEMREADPKG_OFF | ParamEmit `impPatCopyFirstListing215`, § impPatMemberReadParentsAll252's test; `pkgMemberReadNames252` | The law parented an import copy whenever its NAME matched a parameter that some package member-reads in its own initializers. In VS vs02, package p reads its own `D.a`; the module imports q's unrelated, unread `D`. That copy was parented, one record away from golden. The key is now the home package plus every package that imports the home package (transitively), matched against the copy's vpiImported. Two shapes needed the importer half: VS vs16 (q imports and exports p; the law moved one record toward golden) and r11u236repro BP/bp04 (pk2 imports pk with no export). An export-only draft of this refinement moved bp04 four records away; the byte controls caught it and the draft was replaced. Elements of a selected concatenation keep the name key. |
| § dupImpTypeParamDepAbstains252v | R11V252_DUPTYPEPARAM_OFF | ParamEmit `paramValueIsDefRhs124` (§ dupImportSameValueKeeps252's branch); `collectTypeParamDep252v` | The law copied the definition Rhs value onto both `$unit`-import Parameters() entries. For `parameter A = $bits(T) * 2` with `parameter type T`, golden keeps the operation and writes no value on any entry. Our definition Rhs folds it (a pre-existing ParamEmit face), so the law propagated the fold: r11u252's own U/u07 lost 2 records and VU vu13 lost 4. The implementer had recorded u07 as residue 5. Now a package parameter whose initializer names one of its package's type parameters keeps the base's handling. A `$bits` of a typedef built on a type parameter (VU vu20) is not caught by the name scan; the law moves it 2 records TOWARD golden there, so it stays with the law. |
| § impCastNestedConcatBare252v | R11V252_CASTNESTCAT_OFF | ParamEmit, § impSizeCastFoldLocated252's `castLoc252` test | The law left a size cast unlocated when its direct operand is a concatenation or a replication. For `8'({4'h1} + 1)` (VF vf04), golden writes the same bare constant (no location, size 8), but the law located it. The order-blind dump lost the golden-agreeing line in both views. The operand tree is now walked through operators, not through call arguments. A concatenation or replication anywhere in it keeps the bare constant. Call arguments are skipped because VF vf15 `8'($countones({2{W[1:0]}}))` keeps the law's location, and golden's operation there sits at the same span. |

## Reproduction of the implementer's numbers

| item | implementer | verifier |
|---|---|---|
| pristine / law md5 | de0c6d84 / ec509aa1 | the same, both built here |
| probe | 3547 -> 3552 EQUAL, 0 regressions, 5 conversions (g201_a_forms, g201_c_uvmshape, g201_e_explicit, g210_e_unitimp, c5_clone) | the same five, regressions 0, changes 0 |
| surelog | 937 + 17 -> 939 + 15; conversions 2 (SimpleUVM d/t), changes 6 | the same, regressions 0 (csv diff in `evidence/csvdiff_pristine_law.txt`: the eight rows plus the two LowMem workdir-path rows) |
| uhdm2rtlil | 1606 + 0, unchanged | the same, regressions 0 conversions 0 changes 0 |
| downstream | 803 / 66 / 2 / 0, row for row equal to pristine | the same; the csv is byte-equal to pristine's |
| corpus byte movers | 10 of 2560 (BlackBePipeInt, Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, both modes) | the same 10. Fence-filtered hard-link mirrors were used (`drivers/bvmirror.sh`, 8 fenced databases left out). byteverify SELFCHECK reads 2559 / 2560: every file is compared against one fixed file, and that file matches itself, so this is the self-check's own artifact. |
| probe / downstream byte movers | 6 of 4087 / 0 of 805 | the same (`drivers/dbmovers.sh`) |
| uhdm-cmp on the movers | 0 lines on all 10 | 0 lines on all 10, law and fix (`evidence/uhdmcmp_movers.txt`) |
| away census on the sweeps | 0 lost on all 16 moved databases; toward SimpleUVM 50, MiniAmiq 15, SeqDriver 10, BlackBePipeInt 743 (744 flat) | the same numbers; the swapped run reads them as lost (`evidence/away_sweeps*.txt`) |
| Earlgrey_0_1 | bytes only | the id-stripped uhdm-dump of the pristine and law databases is IDENTICAL line for line (4744202 lines), not just as a multiset |
| canaries | surelog ok=48 changed=4, uhdm2rtlil ok=16, ctcan2 surelog FAIL on the two BlackBePipeInt rows only, uhdm2rtlil PASS | the same on law and fix; pristine ok=52, ctcan2 PASS (`evidence/gatechecks.txt`) |
| heads | SimpleUVM equal; MiniAmiq #95125, SeqDriver #95083 / #95095; BlackBePipeInt #331795 / #331692 depth | the same records (`evidence/heads.txt`) |
| grid | 3450 lines, 230 case-views, R11U252_OFF 230 / 230, 90 entering, 0 leaving, every rc 0 | rerun: all 3450 lines carry the same case-view, configuration, cmp line count, strict verdict and exit code (`evidence/grid_reproduction.txt`; the md5 column differs because each database embeds its worktree path) |
| determinism | one hash per row-mode on 13 of 13 | the same with the fix binary, every hash equal to the law sweep's (`evidence/determinism.txt`) |

The fresh rows (results/ untouched):

    SimpleUVM,default,CMP_EQUAL,,,equal
    SimpleUVM,testflags,CMP_EQUAL,,,equal
    MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
    BlackBePipeInt,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)

(testflags the same for each.) **SimpleUVM CONVERTS in both modes.**

## Gates on the fix binary (`evidence/sweeps.txt`, `evidence/gatechecks.txt`)

* probe EQUAL 3552 + 535, regressions 0, conversions 5 (the law's five).
* surelog 939 + 15, regressions 0, conversions 2, changes 6 (the law's eight rows).
* uhdm2rtlil 1606 + 0, unchanged.
* downstream 803 / 66 / 2 / 0.
* Every csv equals the law sweep's row for row (after normalising the workdir prefix), and so does the downstream csv.
* Byte check against the law sweep: 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream databases move.
* Prediction: the firing census of the final fix binary was frozen before the final fix sweep
  (`evidence/prediction_fix.txt`, drivers/tracesweep.sh, the fenced rows excluded through the harness filter).
  The refinements fire on 7 gate databases, all § concatSelInParamInit252v: Earlgrey_0_1 d/t, uhdm2rtlil
  ibex_tracer d/t, and probe r10earl41repro v41v_comment, r10earl42repro v42_overfire and v11u116repro
  h1_ff_lhsidx. In each, a concatenation parameter is selected only outside parameter initializers. In none of
  them is an element a packed-struct-pattern import copy, so none moves; the byte checks confirm it.
  § memReadHomePkgKey252v, § dupImpTypeParamDepAbstains252v and § impCastNestedConcatBare252v fire on no gate
  database. The positive controls are vs02 / vu13 / vf04 in the grid.
* Every gate sweep exits 1 only on the law-index check. This is the base's own state: tests/LAWS.md at 99ea3716
  predates its own commit hash ("commits: none on this branch"), and the pristine sweep from the clean base
  worktree reads the same. `scripts/law_index.py --check` passes on this patch after regeneration.

## Fresh cases (cases/, 94 case dirs, 188 case-views; every first line names its law)

Grid `evidence/grid.txt` (drivers/grid.sh): 22 configurations per case-view. They are pristine, law, law +
R11U252_OFF, law + each of the twelve law switches, fix, fix + R11V252_OFF, fix + R11U252_OFF, and fix + each of
the four refinement switches. That makes 4136 lines, every one with its exit code, and every exit code is 0.

* Law: R11U252_OFF == pristine on 188 / 188. 21 case-views enter STRICT_EQUAL. **2 leave: VS vs01 in both views.**
* Fix: 21 enter, 0 leave. The fix equals the law's bytes on 174. The other 14 are vs01, vs02, vs07, vs08, vs15,
  vu13 and vf04 in both views, and each equals pristine's bytes. fix + R11V252_OFF == law on 188 / 188, and
  fix + R11U252_OFF == pristine on 188 / 188. Each refinement switch moves only its own cases.
* Away census (chain-keyed, drivers/awaychain.py, every moving case-view that is not STRICT_EQUAL;
  `evidence/away_grids_*.txt`): the law loses records on 14 case-views. These are vs01, vs02, vs07, vs08, vs15,
  vu13 and r11u252's own u07, each in both views, and vf04 adds two more on the order-blind dump census. The fix
  loses 0 on all 150 chain-keyed pairs.
* The order-blind dump-line census still reads 1-2 "lost" lines on vs03, vs05, vs12-vs14 and on r11u252's l06,
  s04, s06, s15 and decode d03 (the last five are already in the implementer's README). Each was checked in the
  dumps. For vs05, golden parents the elaborated `D` op ref at `work@top` exactly as law and fix do. For vl04,
  golden's shared home loop variable binds `struct_typespec p::pkt_t`, as the law does. In each case the line
  multiset paired a pristine line with a golden line from another listing.

| cases | law | result (pristine -> law; fix where it differs) |
|---|---|---|
| VU vu04_typed, vu19 | § dupImportSameValueKeeps252 | value -> STRICT_EQUAL in both views (an explicit `$unit` import beside the wildcard; `$unit` plus a module-scope import) |
| VU vu01-vu12, vu14-vu18, the `_typed` twins | § dupImportSameValueKeeps252 | mostly stage 1 on both binaries: an untyped package parameter USED in a module carries vpiSigned on golden's int_typespec, a pre-existing face. Bytes move toward golden on every one (real / string, enum / struct, a shadowing child, a package chain, the constant slots, an interface, `$clog2` / function / ternary inits, `$bits` of a typedef, typed and signed, 100-bit, mixed qualification, implicit nets, class-specialization bounds, a package after a `$unit` import). vu07_typed value -> fullname, 0 lost. |
| VU vu13, vu20 | § dupImpTypeParamDepAbstains252v | vu13 (`$bits(T)` with a type parameter): the law loses 4 records, the fix restores pristine. vu20 (a typedef of T): the law moves 2 toward golden and the fix keeps that. |
| VL vl01-vl08 | § cloneLoopVarLocalElemTs252 | vl03 (2-D), vl07 (initialized) -> STRICT_EQUAL. vl01 type -> name (a class element, the l13 face). vl02, vl04 stage 1, moving toward golden (golden binds the enum / struct typespec as the law does). vl05 (in-body) and vl08 (nested block) equal on both. vl06 stage 1, no move. |
| VX vx01-vx09 | § cloneHpIdxSelectByChain252 | vx02, vx06, vx07 -> STRICT_EQUAL. vx01 (three levels) col on both. vx08 fullname on both. vx04 stage 1, toward. vx03, vx05, vx09 unchanged. |
| VK vk01-vk06 | § cloneLoopVarClassScopedInt252 | vk01 (a base class's static), vk02 (`lib#(T)::`) -> STRICT_EQUAL. vk03, vk04, vk06 stage 1, toward. vk05 unchanged. |
| VR vr01-vr07 | § cloneRandWithParentCall252 | vr01 (`this.randomize() with`), vr04 (`local::`), vr06 (a package function), vr07 (pure virtual above, extern below) -> STRICT_EQUAL in the default view. vr02 stage 1, toward. vr03 (`std::randomize`) and vr05 unchanged. |
| VF vf01-vf03, vf05-vf14 | § impSizeCastFoldLocated252 | vf13 (a concatenation-valued parameter as the operand) -> STRICT_EQUAL. The rest are stage 1 (an untyped imported parameter), bytes moving toward golden, 0 lost. vf05 (signing casts) and vf14 (a call operand, golden keeps the call) unchanged. |
| VF vf04, vf15 | § impCastNestedConcatBare252v | vf04: the law loses 1 line per view, the fix restores pristine. vf15 keeps the law's bytes. |
| VS vs03-vs06, vs09-vs11, vs17 | § ternLeafThroughParamRef252, § patFlatBinLeftSpan252, § impPatMemberReadParentsAll252, § impStructRefOpAtRef252 | stage 1 on both, toward golden or unchanged (a three-link reference chain; relational, logical, unary-left, parenthesised-left and power members; a qualified own-package read; a reference to another package's parameter; a read in a function and an untaken branch; an unpacked struct; a generate and instance depth 3; a read by another package) |
| VS vs01, vs07, vs08, vs15 | § concatSelInParamInit252v | law 2 records away per view (vs01 STRICT_EQUAL -> fullname); fix = pristine |
| VS vs12, vs13, vs14 | § impPatConcatSelReadParents252 | the law's positive shapes: 2 chain records toward golden; fix = law |
| VS vs02 | § memReadHomePkgKey252v | law 1 away; fix = pristine |
| VS vs16, vs18 | § memReadHomePkgKey252v | re-export and import chains: law = fix (vs16 1 toward) |
| VT vt01-vt04 | § lazyTernArithLeftSpan252 | stage 1 on both, toward (relational, a parenthesised left, body constant slots, an imported package) |

**Downstream on the cases** (drivers/dscases.py, 52 synthesizable case dirs; `evidence/ds_*.txt`): pristine, law and
fix each read 38 IDENTICAL / 9 EQUIVALENT / 4 DIVERGENT / 1 STATUS_DIFF, with no case changing verdict on any
binary. The STATUS_DIFF is VS vs03: Yosys crashes on slang's database (`slang_status CRASH`) on all three binaries,
so the crash is pre-existing.

## Byte controls (`evidence/controls.txt`, `evidence/controls_summary.txt`, drivers/controls.sh)

There are 41 repro dirs: the implementer's 31, plus r11u247, r11u249, v11u215, v11u232, v11u236, v11u240, v11u247,
v11u249, v11u251 and v11u253. That gives 2824 case dirs, 5648 case-views and 16944 lines on pristine, law and fix,
each line with its exit code.

* Law vs pristine: 90 move, 28 enter STRICT_EQUAL, none leave. The entrants are r11u214dec D/g01-g03, r11u251
  decode HP h01-h02, r11u253 decode LV lv01-lv02, r11u250 T/t01, t02 and decode B/b01, v11u238 D/d05, r11u238
  F/f19, r11u236 BP/bp02 and v11u253 A/va06, in both views. The implementer's 26 plus va06 (new dir).
* Fix vs law: 0 move. An intermediate draft moved r11u236 BP/bp04 (see § memReadHomePkgKey252v).
* Exit codes are identical on the three binaries for every case-view. 117 lines carry a non-zero code on every
  binary: rc 4 (stage-1 comparisons), rc 3 (slang rejects) and **rc 139 on r11v124repro hx/x02_forstep in the
  elaborated view. That segfault is in PRISTINE too**, a pre-existing crash reported here, not this pass's.
* Away census, chain-keyed, on the 60 moving pairs that are not STRICT_EQUAL: 0 lost for law and fix.

## Rows (before -> after; the same on law and fix)

| row-mode | base | after | head now |
|---|---|---|---|
| SimpleUVM d / t | value(50) #203342 / #203354 | **CMP_EQUAL, strict equal (334285 / 334297 objects)** | - |
| MiniAmiq d / t | type(1) #87036 | fullname(5) | #95125: `slice.path` ref_typespec, golden `work@svaunit_vpi_interface.uvm_pkg::uvm_hdl_path_slice.path`, ours `uvm_pkg::uvm_pkg::uvm_hdl_path_slice::path` (UhdmExporter, § cloneAggMemberOwn241's drain, ground B) |
| SeqDriver d / t | type(1) #86994 / #87006 | fullname(5) | #95083 / #95095, the same face named `work@top_tb...` |
| BlackBePipeInt d / t | file(721) #190646 / #190553 | depth(1) | #331795 / #331692: golden's elaborated param_assign dut.sv 14508:12-118 where ours writes the operation 14219:1-14265:2 (the all_cfgs_gp import copy's Rhs, ParamEmit) |

## Residues, ranked

1. **MiniAmiq / SeqDriver #95125 / #95083 / #95095, 4 row-modes** (sister ground, UhdmExporter § cloneAggMemberOwn241's
   drain), as the implementer decoded it (r11u252repro decode/M/m01).
2. **BlackBePipeInt #331795 / #331692** (ParamEmit; the elaborated import copy of the concatenation parameter
   `all_cfgs_gp`): golden writes no Rhs. The reductions do not reproduce it, and neither do this pass's vs12-vs14.
3. The definition-view fold of a type-parameter-dependent initializer (U/u07, VU vu13): our definition Rhs folds
   `$bits(T) * 2` where golden keeps the operation. With § dupImpTypeParamDepAbstains252v the `$unit` listing is
   back at pristine, but the module-scope import (VU vu17) writes the folded value on pristine too. The writer is
   ParamEmit's definition-view fold.
4. § concatSelInParamInit252v resolves the select base by syntax (the enclosing declaration's own parameters),
   not by symbol. A select of a same-named parameter imported from a second package would still read as the
   concatenation. No case or gate database holds the shape.
5. The implementer's residues 3-7 stand (the home package's member-read `U = D` listing, the definition-listing
   struct-pattern faces, X x04, L l06 / l12 / l13, and brief items (4)-(7)). Here VL vl01 (a class-handle queue)
   reads type -> name like l13, and VX vx01 (a three-level index) reads col on both binaries.
6. Pre-existing defects found on the way, not this pass's: the pristine segfault on r11v124repro hx/x02_forstep
   (elaborated view), and the Yosys crash on VS vs03's slang database.

Sister-ground faces, reported and not written: Rggen #26477 (ModuleEmit), Earlgrey #136315 / #142988 (TypeEmit
emitSyntaxExpr) and #154375 (ModuleEmit), BuildUVMPkg (TaskFuncEmit; pass 255 has since landed on the main tree).

## Process

* **Unset tool variable (the brief's named trap).** Three shell calls ran `$UHDM_DUMP <db>` before sourcing
  the environment. Bash executed case databases as scripts, with the main checkout as the current directory:
  r11u252 L/l01 and l03, VL vl03 and VF vf15, golden plus ours. Every redirect went to a `.d` file in this pass's
  own scratch tree, and those files came out empty and were deleted. The main checkout was checked right after:
  `git status` was clean, and the root directory's mtime was unchanged since 16:12 (before this pass), so nothing
  was created there. Every later call sourced /tmp/v11u252_env.sh, which tests each tool with `-x` and fails
  closed, and quoted the variable.
* One `pgrep -f` with a pattern naming this pass's own grid driver checked that the driver was alive. It
  signalled nothing and read no other agent's command line, but the pattern could match the invoking shell,
  against the brief's rule.
* Intermediate fix binaries were withdrawn before the final one:
  * 3ce0091d had the concatenation and member-read keys without the shadow check and the importer chain.
  * 4b91a1c3, 3e9d6a0a and 712dbf7d led to VS vs15, vs16, VF vf15 and r11u236 BP/bp04, found by fresh cases and
    by the byte controls.
  * 2d51ff1e had the export-only key.

  Every number above is the final binary's (00c7bed5). For it, the firing census was frozen before the fix sweep,
  then come the gate sweep, both grids, the fix column of the controls, the away censuses, determinism and
  downstream. The pristine and law sweeps were each run once.
* Fence: no fenced test was dispatched, read or opened outside the gate sweeps. The firing census used the
  harness's own `--filter`. byteverify ran on hard-link mirrors without the fenced databases. dbmovers, the binary
  audit and every case driver filter their path lists by $FENCED before opening anything. No evidence file holds a
  fenced name (checked by word boundary).
* Patch surface: src/ParamEmit.cpp, src/ExprEmit.cpp, src/StmtEmit.cpp, src/R252.h, tools/probe/r11u252repro/
  (the implementer's, unchanged), tools/probe/v11u252repro/, and the regenerated tests/LAWS.md.

## Drivers

`drivers/env.sh` sets the pins and the fence. `case.sh` runs one case on both producers (relative names `v/` for
these cases and `r/` for r11u252repro's). `grid.sh` runs the grid, with FIXBIN for the fix columns. `controls.sh`
runs the byte controls on three binaries (`CTL_BINS`), and `ctlsum.py` summarises them. `gridsum.py` summarises a
grid. `awayctl.sh` (with `TAGB=law|fix`), `awaychain.py`, `awayrows.py` and `awaydump.py` run the away censuses.
`tracesweep.sh` runs the firing census, `bvmirror.sh` builds the fence-filtered mirrors, `dbmovers.sh` finds probe
and downstream movers, `det.sh` runs the determinism draws, and `dscases.py` runs downstream on cases. `cc_x.sh` and
`strictcmp_x.cpp` build the variant comparator that awayrows.py reads. Most are copies of r11u252repro's.
