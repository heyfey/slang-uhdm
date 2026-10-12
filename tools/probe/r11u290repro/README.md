# r11u290 — the two un-parked Surelog rows: LogicTypespec d/t and Scr1SvTests d/t

Pass 290 (user ruling 2026-10-11: the two Surelog row-modes the 2026-09-29
ruling parked are work items).  Base 309b62bc.  Ten laws behind `src/R290.h`
(each `R11U290_<LAW>_OFF`, `R11U290_OFF` drops all ten, `R11U290_TRACE=<dir>`
logs every firing and abstention).

**Result: all four target row-modes CONVERT**, nothing else in either corpus,
the probe set or the downstream lane moves in bytes:

    LogicTypespec,default,CMP_EQUAL,,,equal       (was STRICT_NOTEQUAL differ:endline(3))
    LogicTypespec,testflags,CMP_EQUAL,,,equal     (was STRICT_NOTEQUAL differ:endline(3))
    Scr1SvTests,default,CMP_EQUAL,,,equal         (was STRICT_NOTEQUAL differ:type(1))
    Scr1SvTests,testflags,CMP_EQUAL,,,equal       (was STRICT_NOTEQUAL differ:type(1))

uhdm-strictcmp on the law sweep's databases: LogicTypespec default
STRICT_EQUAL 122 objects, testflags 32 objects; Scr1SvTests default
STRICT_EQUAL 84098 objects, testflags 83997 objects; uhdm-cmp 0 lines on all
four (evidence/strict_targets.txt).  With the corpus at zero open rows since
pass 277, the Surelog corpus is now 954 of 954 judge-equal row-modes
CMP_EQUAL (default 480, testflags 474).  results/ is untouched: the master
re-baselines the four rows.

## Decode

### LogicTypespec (law 1)

`my_package::typedef_logic_typespec [1:0][7:0] my_instance;` in a module.
Strict first records at the base: #14 endline (golden's elaborated package
typedef `my_package::typedef_logic_typespec` ends 7:44, ours 2:20), #104 name
(golden's definition net binds that typedef object, ours an unnamed
logic_typespec 7:1-7:49), #105 depth (the typedef's range under it).

Surelog: `CompileType.cpp` compileTypespec, `paPackage_scope` branch, returns the
package DataType's own typespec and wraps the written ranges in a
packed_array_typespec only when the result is NOT a logic, bit or int
typespec, so a vector typedef with extra packed dimensions binds the shared
typedef object and the extra dimensions are lost (a Surelog defect; the
elaborated variable keeps them, which is why the defect is invisible there).
`UhdmWriter::writeNets` then runs its end-only populate
(`dimensions = getUnpackedDimension(); if (!dimensions) dimensions =
getPackedDimension(); populateCoreMembers(InvalidNodeId, dimensions, ts)`)
on that shared object: its END and FILE move to the end of the first
unpacked dimension, or else of the first PACKED dimension, last net writer
winning, in every listing of the elaborated package.  This is the
packed-dimension twin of § defNetScopedPkgVecTdShares134.

### Scr1SvTests (laws 2-10)

The brief's head (#48892, `assign ifu2imem_cmd_o = SCR1_MEM_CMD_RD;`) was the
first of SIX faces the diverged walk hid (the base's `type(1)` counts one
object because the walk diverged there).  Each was decoded and cleared in
turn, the strict walk moving #48892 -> #63358 -> ... -> equal:

1. **#48892** (law 2): the `$unit` enum `type_scr1_mem_cmd_e` sits behind an
   include guard first expanded in another root file, so Surelog reads
   `SCR1_MEM_CMD_RD` in scr1_pipe_ifu as an implicit net (both producers
   already list that net in the definition).  `UhdmWriter::writeCont_assign`
   clones a cell only for an operation right side, a constant reduce result
   or an unsized constant; reduceExpr on the unresolved name returns the
   ref_obj, so the elaborated instance lists the DEFINITION's cont_assign
   itself (Rhs = ref_obj bound to the definition's implicit net, full name
   `work@scr1_pipe_ifu.SCR1_MEM_CMD_RD`).  Ours folded the enum constant
   (1'b0).  This is NOT a general enum keep rule: every other enum-member
   read (resolved names, operation right sides, procedural, case items,
   package enums, the same-file module) was already equal on both producers
   (grid E, below).
2. **scr1_mem_axi, 26 index references** (law 3): in the elaborated
   cont_assign writeCont_assign clones (operation Rhs), clone_tree parents a
   reference index of the path's LEADING select at the clone's bit_select,
   so UHDM's ComputeFullName names it through the path
   (`...i_imem_axi.req_status[req_aval_ptr].req_resp.req_aval_ptr`); ours
   parented it at the hier_path (`...i_imem_axi.req_aval_ptr`).  The
   base-select twin of § hierPathSelIdxCloneKeepsElem178v; three builder
   sites (the mixed-path base select, the element-select-based range-select
   branch, the dotted-text range-select branch).
3. **scr1_dmi DMI_* ladder** (law 4): `DMI_DATA_LO = DMI_OP_HI + 1` holds
   DMI_OP_HI's elaborated Rhs OBJECT as its operand (the decode at
   § elabMisevalRefSubst said so; the code cloned it), so the walk lists it
   once.  Not in the --elabuhdm view (UHDM's elaborator re-reduces there;
   grid M/m02_dmi_el read stage 1 under a draft).
4. **scr1_pipe_tdu var ranges** (laws 8, 9): the references a
   § elabVarRangeMisevalSubst splice builds store no full name in golden, so
   the reader names them through the variable
   (`...i_pipe_tdu.csr_addr_mcontrol.SCR1_TDU_MTRIG_NUM`; ours bare); and the
   spliced node is typed by the substituted parameter's OWN declaration
   typespec (ALLTRIG_W's, carrying the paren-cast width mark's vpiExpr),
   where ours minted a fresh int_typespec.
5. **i_tcm -> i_dp_memory override chain** (laws 5, 6, 10): i_dp_memory's
   elaborated `SCR1_SIZE` param_assign Rhs is a COPY of i_tcm's tree
   re-stamped at the actual `.SCR1_SIZE( SCR1_TCM_SIZE )` with its FILE
   (scr1_tcm.sv 101:19-32; ours kept scr1_top_axi.sv because setLoc leaves a
   stamped file alone), its references and ref_typespecs named through the
   copy's own chain (`...i_tcm.i_dp_memory.SCR1_TCM_ADDR_MASK`; ours copied
   i_tcm's names) — the nested copy under ram_block's RAM_SIZE_WORDS splice
   likewise; a range bound naming the overridden parameter itself
   (`input logic [$clog2(SCR1_SIZE)-1:2] addra`) takes a copy re-stamped at
   the use (file included), hung where its source hangs, with the source's
   names.
6. **scr1_tcm port connection** (law 7): in the elaborated port connection
   `.addra(imem_addr[$clog2(SCR1_TCM_SIZE)-1:2])` the unreduced reference in
   the part-select bound operation is named through the chain, port and
   instance included (`...i_tcm.i_dp_memory.addra.imem_addr.SCR1_TCM_SIZE`);
   ours scoped it by the parent instance's prefix.

## Laws (switch; site; function edited)

| # | law | switch | file, function |
|---|---|---|---|
| 1 | § pkgTdPackedDimsDefNetShares290 — a definition net typed `pkg::T [d]...` with T a package logic/bit vector typedef (not over another typedef, not a `var` declaration, not a port) binds the elaborated package's typedef object and moves its end/file to the first unpacked dimension, else the first packed dimension | R11U290_PKGTDPACKED_OFF | ModuleEmit.cpp `materializeDefNetTs` |
| 2 | § caUnitEnumUnresolvedShares290 — a cont_assign whose whole Rhs is a `$unit` enum member declared in another root file than the module shares the definition's cell in the elaborated view (the enum fold is skipped) | R11U290_UNITENUMSHARE_OFF | ModuleEmit.cpp `emitContAssigns` |
| 3 | § elabCaBaseSelRefIdxAtElem290 — elaborated cont_assign Rhs (contAssignView 2), rvalue: a reference index of a path's base select stays at its bit_select and is named from the chain by § hierPathSelIdxCloneKeepsElem178v's drain (gated by R11V178_ELABCA_OFF and R11U178_MIDIDX_OFF too) | R11U290_BASEIDXELEM_OFF | ExprEmit.cpp `emitMixedHierPath` (base select), `emitExpr` RangeSelect branches (element-select base `mbSel109`, dotted-text branch) |
| 4 | § elabMisevalCompositeShares290 — § elabMisevalRefSubst returns the sibling's composite Rhs object itself (not on the override road, not in --elabuhdm) | R11U290_MISEVALSHARE_OFF | ExprEmit.cpp `emitExpr` NamedValue (§ elabMisevalRefSubst) |
| 5 | § elabOvMisevalCloneChain290 — the override road's copy of the parent's tree (and a copy nested in a sibling's splice) has its references and ref_typespecs named from its own chain | R11U290_OVCLONECHAIN_OFF | ExprEmit.cpp (§ elabMisevalRefSubst), TypeEmit.cpp `emitSyntaxExpr` (§ elabOvMisevalNoFold branch), drain `drainMisevalSpliceChain290` |
| 6 | § elabOvMisevalRestampFile290 — the § elabOvMisevalNoFold re-stamp moves the file too | R11U290_OVFILE_OFF | ParamEmit.cpp `emitParameters` |
| 7 | § elabConnPsBoundRefChain290 — elaborated port connection, simple part-select bound operation: its references named from the chain | R11U290_CONNBOUNDCHAIN_OFF | ExprEmit.cpp `emitExpr` simple part-select; drain in TypeEmit.cpp |
| 8 | § elabMisevalSpliceDeclTs290 — the § elabVarRangeMisevalSubst splice binds the substituted parameter's definition typespec object | R11U290_SPLICEDECLTS_OFF | TypeEmit.cpp `emitSyntaxExpr` |
| 9 | § elabMisevalSpliceRefChain290 — the splice's references with an empty or bare stored name named from the chain | R11U290_SPLICECHAIN_OFF | TypeEmit.cpp `noteMisevalSplice290` / `drainMisevalSpliceChain290`; call added in ParamEmit.cpp design-final drain list after `drainHierPathSelIdx178` |
| 10 | § elabOvSpliceTopCopy290 — a bound naming the overridden parameter itself (splice depth 0) takes a copy re-stamped at the use with file, hung at the source's parent, named like the source | R11U290_OVSPLICETOP_OFF | TypeEmit.cpp `emitSyntaxExpr` (§ elabOvMisevalNoFold branch) |

New file src/R290.h (switches, trace, `misevalOvRhs290`,
`misevalSpliceDepth290`).  ParamEmit.cpp `emitParameters` also sets/clears
`misevalOvRhs290()` beside `misevalParamRhsScope`.  `#include "R290.h"` is
placed before the first `R*.h` include in ExprEmit, TypeEmit, ParamEmit
(after R289.h in ModuleEmit) so a pair pass adding its header after the last
one does not collide.

## Measurements (base 309b62bc; pristine = law binary with R11U290_OFF)

Binaries frozen before any measurement: pristine `/tmp/r11u290_bin/pristine`
md5 f285f238dbd51f0029dc79812e56e69d (= the main tree's build), law
`/tmp/r11u290_bin/law8` md5 29c6811344ecce47f41b66ca720c0bd5; both link slang
12.0.0+545f88b2e.

**Gate sweeps** (tests/sweep.sh --jobs 3; evidence/sweep_pristine.txt,
sweep_law.txt; both exit 1 on the law-index check alone):

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3903 + STRICT_NOTEQUAL 184, reg 0 conv 0 chg 0 | identical, reg 0 conv 0 chg 0 |
| surelog | default 478 + 2, testflags 472 + 2, reg 0 | default 480 + 0, testflags 474 + 0, **regressions=0 conversions=4 changes=0** |
| uhdm2rtlil | 803/1/67 both modes, reg 0 conv 0 chg 0 | identical |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | identical, csv row-identical |

Row by row (evidence/csv_rowdiff.txt): the only csv lines differing between
the two sweeps are the four conversions and the LowMemLib/LowMemPkg
testflags detail text (the workdir in a log path, environment).

**Firing census, frozen before the law sweep** (drivers/tracecensus.sh,
fence-filtered harness dispatch, evidence/predict.txt): exactly
LogicTypespec d/t (law 1) and Scr1SvTests d/t (laws 2-10: UNITENUMSHARE 1,
BASEIDXELEM 28, CONNBOUNDCHAIN 2, MISEVALSHARE 5, SPLICEDECLTS 26,
SPLICECHAIN 24, OVCLONECHAIN 4, OVFILE 1, OVSPLICETOP 8); no probe case, no
uhdm2rtlil row.  No over-prediction.

**byteverify** on fence-filtered mirrors (drivers/bvmirror.sh, 8 fenced
row-mode paths skipped): 4 of 3365 corpus and downstream databases move,
exactly the predicted four; SELFCHECK 3363 of 3365 (the known
1DUnpackedArray twin, so the script prints SELFCHECK_FAILED as on every pass
since 285).  Probe: 0 of 4087 databases move (selfcheck 199 of 200).

**Away-moved census** (evidence/away_corpus*.txt): order-blind lost 0 on all
four (gained 5, 5, 78, 78), chain-keyed away 0 / toward 5, 5, 78, 78; the
positive control with the binaries swapped reads away 5, 5, 78, 78.

**Determinism** (drivers/det.sh, three concurrent draws per row-mode with the
law binary, evidence/determinism.txt): one hash each on Earlgrey_0_1,
MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, Rggen, Scr1SvTests
and LogicTypespec in both modes (Scoreboard and Rggen testflags write no
database), every hash equal to the law sweep's.

**Canaries** (evidence/canaries*.txt): surelog ok=50 changed=2 (the two
Scr1SvTests canary rows, the conversions), uhdm2rtlil ok=16 changed=0;
ctcan2 surelog ok=58 PASS, uhdm2rtlil ok=2 PASS (one mode in the gate csv,
EXPECT_UNKNOWN=6).  Binary-path audit (evidence/binary_audit.txt): 3273 of
3323 cmds.txt in each sweep name that sweep's own binary, the other 50
carry no slang line.

## Grid (cases/, both views, every line with its exit code)

71 case dirs, 142 case-views, configurations P, L, OFF and each switch off
(evidence/grid.txt, grid_summary.txt): 73 moving, 47 entering STRICT_EQUAL,
0 leaving, 0 exit-code changes, R11U290_OFF gives pristine's bytes on 142 of
142; attribution PKGTDPACKED 32, BASEIDXELEM 20, UNITENUMSHARE 18,
MISEVALSHARE 1, and M/m03_tcm d/el the miseval family together (the seven
switches 4-10 off restore pristine, evidence/grid_m03_family.txt).
Away census on all 73 movers (evidence/grid_away.txt): lost 0 and chain away
0 on every one.  Downstream on eight representative cases, both binaries
(evidence/downstream_cases.txt): all IDENTICAL on the law, E/e01 EQUIVALENT
-> IDENTICAL, none worse.

- **T** (§ pkgTdPackedDimsDefNetShares290), single file: two/one extra
  dims, two modules (last writer t08), two declarations, plain + packed,
  multi-declarator, signed, CRLF, header in two modules (file moves to the
  header t26), used — all converting in both views.  t09 (`typedef logic t`,
  no range) moves endline -> name (the elaborated variable's typespec, a
  separate face, pristine wrong too).  Stage 1 on both binaries (pre-existing
  judge faces, laws keep chain away 0): t03 var (law abstains), t04 wire,
  t05 port, t06 localparam, t07 import, t11 bit, t12 int, t13 unpacked too,
  t14 initializer, t15 interface, t18 typedef over typedef, t19 parameter
  dims, t22 generate block.  t10 struct, t24 enum already equal.
- **E** (§ caUnitEnumUnresolvedShares290), multi-file (args): a guarded
  header expanded first by f1.sv, the reader in f2.sv.  Converting in both
  views: whole-Rhs read with logic / enum / variable / wider left side, two
  instances, delay, parenthesised, CRLF.  Already equal on both binaries
  (golden folds or keeps exactly as we do): procedural, case item,
  comparison, ternary, dotted and select left sides, the same-file module
  (e22), a package enum (e23).  Stage 1 on both binaries: port actual,
  concatenation, function argument, generate block, net declaration
  assignment, unary, cast, interface, a header with `'x` and a parameter
  initializer (e24, moving, chain away 0).
- **H** (§ elabCaBaseSelRefIdxAtElem290): unary, `&`/`|`, ternary, shift with
  a trailing part select, part select only, function argument, two
  dimensions, nested member, concatenation convert; whole Rhs, always_comb,
  operation index, constant index, net declaration assignment already
  equal; generate block h13 residue (fullname, unmoved); two instances h14
  and interface h16 stage 1 on both binaries.
- **M** (laws 4-10), multi-file with two root files claiming `$unit`
  parameters: m02 (the DMI ladder) converts default (el already equal),
  m03 (the top -> tcm -> dp_memory override chain) converts in both views;
  m01 (the tdu splice) is stage 1 on both binaries — our
  unitParamNoValue model does not reproduce the Scr1 valuelessness in a
  three-file reduction, so laws 8 and 9 are evidenced by Scr1SvTests alone
  (the census firings and the switch-off reading below).

Scr1SvTests switch attribution (each switch off alone on the law binary,
default mode, first strict record; evidence/scr1_switches.txt): UNITENUMSHARE
#48892 type, SPLICECHAIN #63358 fullname, SPLICEDECLTS #63387 depth,
MISEVALSHARE #70254 type, OVFILE #76071 file, OVCLONECHAIN #76072 fullname,
OVSPLICETOP #76131 file, CONNBOUNDCHAIN #76199 fullname, BASEIDXELEM #80640
fullname; PKGTDPACKED off leaves the row equal (bytes unchanged); R11U290_OFF
gives the pristine sweep's bytes (a984d92b).  The conversion needs all nine.

## Residues (ranked)

1. --elabuhdm view of the sibling share: m03_tcm_el moves file(#310) ->
   type(#354) (RAM_SIZE_WORDS' shared operand; the law is gated off in that
   view because m02_el needs the fold), chain away 0.
2. t09: a range-less package typedef's elaborated variable typespec
   (name), pristine wrong too.
3. E-grid stage-1 shapes (port actual, concatenation, function argument,
   generate block, nda, unary, cast, interface, enum member with a parameter
   initializer) — all wrong on pristine; the unresolved `$unit` enum read in
   those positions is not modelled.
4. h13 (elaborated cont_assign in a generate block, base-select index
   name), unmoved.
5. m01: the tdu valuelessness in a minimal repro (model gap, pristine
   wrong).

Sister-ground faces: none found beyond the above; the probe residue (184)
is untouched (no probe database moves).

## Process

Fence: every driver reads `$FENCED` fail-closed from
tools/probe/r11u107repro/canaudit.sh; the harness dispatches the fenced
rows only in the gate sweeps; the census, byteverify (mirrors), away and
determinism runs filter by name before any file is opened.  Every
investigated source is Scr1SvTests or LogicTypespec (not fenced).
SLIP (no effect): one background waiter used `pgrep -f` with a pattern
contained in its own command line; it was stopped by its own task id
before it signalled anything, and replaced by a line-count waiter.  No
other agent's process was listed or signalled; the main tree was not
written.  Note for later passes: `grep` here is ugrep and skips files with
non-UTF-8 bytes (Scr1's `©` headers) unless `-a` is given.
Drafts superseded: law1..law7 (law7 lacked the `var` abstention, which the
grid's away census caught on T/t03 at chain away 1); every reported number
is from law8.

Files: README.md, cases/{T,E,H,M} (first line of every .sv names its law),
drivers/ (env.sh, case.sh, grid.sh, gridsum290.py, tracecensus.sh,
bvmirror.sh, away.py, awayrows.py, awaychain.py, awaycv.sh, awaycorp.sh,
det.sh, strictcmp_x.cpp, cc_x.sh, dscases.py, awaydump.py), evidence/.
