# r11u284 — pass 284, the expression/parameter ground (ExprEmit, ParamEmit, EmitHelpers)

Base 75e43718 (pass 282 on top of pass 285).  Seven laws (six plus one refinement switch) behind src/R284.h
(`R11U284_<LAW>_OFF` each, `R11U284_OFF` drops all of them, `R11U284_TRACE=<dir>` logs every firing and abstention
to `<dir>/<pid>.284`).  **TEN PROBE CONVERSIONS and three probe changes toward golden; no corpus row moves in
status; 2 of 2560 corpus databases move in bytes (stamped_gen_param d/t, a known CMP_NOTEQUAL row, chain away 0,
toward 8 each).**

Binaries: pristine `884cf2ee5872967740255962bcd3a381` (built in the worktree, byte-identical to the main tree's
build/slang-uhdm), law `91ba5bad5055a2afd6e3e88bb9762c93`.

## The probe conversions (fresh sweep rows, results/ untouched)

| case | base | law | law |
|---|---|---|---|
| r11u111repro/grid/f1/a10_q_chain | fullname(5) | EQUAL | § pkgAliasTdRefNameByParent284 |
| v11u110repro/brk/v6/s01_single_chain2_ctl | fullname(6) | EQUAL | § pkgAliasTdRefNameByParent284 |
| v11u111repro/brk/f6/x65_chain_td_dims | fullname(3) | EQUAL | § pkgAliasTdRefNameByParent284 |
| r11v23repro/adv/v11_concat_64bit_param | fullname(2) | EQUAL | § genCaCatMemberInst284 |
| r11v23repro/adv/x09_concat_64bit_param_small | fullname(1) | EQUAL | § genCaCatMemberInst284 |
| r11u108repro/grid/pk/k05_param_a | file(4) | EQUAL | § f3ParamCopyDeep284 |
| r11u111repro/grid/f1/a27_q_row_named_dims | file(4) | EQUAL | § f3ParamCopyDeep284 |
| v11u111repro/brk/f3/x38_param_in_module_typed | file(4) | EQUAL | § f3ParamCopyDeep284 |
| r10earl31repro/v5_hier | fullname(1) | EQUAL | § hpSelPortConnFoldChain284 |
| r10earl52repro/a2_earl52 | file(1) | EQUAL | § ternSgnLitFreshIntTs284 |

Changes (first field moved, the fullname face cleared, § pkgTdNamedDimsElemByChain284):
r11u108repro/grid/f5/f5a20_ovr_pkgarr fullname(6) -> name(2), v11u108repro/brk/f5/b13_pkg_arr fullname(7) -> name(1),
v11u111repro/brk/f3/y31_two_pkgs_rows fullname(8) -> name(6).  The new head of all three is the sister's (below).

Probe: base EQUAL 3863 + STRICT_NOTEQUAL 224 -> law EQUAL 3873 + STRICT_NOTEQUAL 214, regressions 0.

## The decode that carries four of the laws

**Surelog stores no full name on a ref_typespec.**  The UHDM getter `VpiFullName()` computes
`BaseClass::ComputeFullName` over the parent chain when nothing is stored (and caches it).  Measured with
drivers/rtsinfo.cpp, which re-implements ComputeFullName (the member is protected) and prints STORED where the
getter disagrees with the chain: over every fourth probe golden, **28286 of 28286 golden ref_typespecs read exactly
their parent chain**.  So a golden reference name is decided by the parent objects, never by a writer.  An
experiment that renamed every one of OUR ref_typespecs by its chain (removed before delivery) read 320 probe
regressions and 5 conversions: our chains differ from golden's wherever we share an object golden copies, so the
names cannot be rewritten wholesale; each law below names one family where our chain or golden's chain is known.
(The same experiment on ref_obj / selects read 2956 regressions: golden stores those names.)

## The laws

### § pkgAliasTdRefNameByParent284 — `R11U284_ALIASPARENT_OFF` (ParamEmit, design-final in `pkgAliasTdNames284`)

`typedef b_t a_t;` in a package (b_t a same-package typedef): Surelog's CompileHelper builds the tpclone listing
object with a Typedef_alias ref parented at it.  Golden's ref name is the chain over the listing object's final
parent: UhdmWriter::writeDataTypes parents it at the package (`pk::pk::a_t`), and UhdmWriter::writeCont_assign ends
every elaborated continuous assignment with `tps->VpiParent(nullptr)` on the left side's typespec
(UhdmWriter.cpp, the end of writeCont_assign), so a signal declared `pk::a_t` that an elaborated `assign` or a
declaration initializer writes whole leaves it unparented (`pk::a_t`).  Ours stored `work@<top>.pk::a_t` (the
alias-of-typedef branch of emitPackage, an early wave-1 observation that no probe golden reads).  The law names
each such reference `pk::a_t` when an elaborated whole-signal continuous assignment or initialized declaration has
the alias as its declared type, else `pk::pk::a_t`; it abstains when any instance body, package or compilation unit
imports the package or the alias (an importer becomes the parent, § typedefParentLastWriter134's road: `work@dut.pk::a_t`,
grid A/a02) and when the listing object already has a parent.  Grid cases/A (40 dirs: `a*` the target kind x the use,
`b*` the writer shapes; the golden listing parents were read with drivers/rtsgrid.sh).

### § pkgTdNamedDimsElemByChain284 — `R11U284_F3ELEMCHAIN_OFF` (ParamEmit design-final, recorded in emitPackage)

FACE 3 of pass 111 (`typedef ut_e [0:2] row_t`): the listing object L's Elem reference was always stored
`pk::pk::row_t` (pass 111's fullname note listed four binders).  Golden reads the chain over L's final parent; the
probe census (evidence/aliascensus_base.tsv) shows our L already sits where golden's does on every probe case
(package, none, or a parameter copy's reference), so the law names the reference by its final chain.  Grid cases/E.

### § f3ParamCopyDeep284 — `R11U284_F3PARAMCOPY_OFF`, refinement `R11U284_F3GENLOCAL_OFF` (ParamEmit `makeParamTs`)

An elaborated module parameter `parameter q2::row_t UT` typed by a FACE 3 typedef is Surelog's elaboration clone of
L: unlocated (L has no span), with L's Elem target A and A's alias target B cloned too, so A's alias and elem refs
and B's elem ref read the copy's chain (`work@dut.u.UT.q2::row_t`).  Ours (§ pkgTdQualParamCopiesListing111's q111
copy) took the typedef's type span 3:11-3:21 and shared A with its unnamed refs.  The law copies A and B for the
copy, names those three refs by the copy's own Elem ref name, and leaves the copy unlocated.  **Refinement (the
law's own byte controls found it):** a parameter declared in a generate block (`localparam q2::row_t UT =
q2::IMPL.UnitTypes[grp]` in a for-generate, r11u111repro/grid/f3/s00_stamped_corpus, the stamped_gen_param shape)
keeps the listing's unnamed refs in golden; the unrefined law moved 9 records away there (chain away 9, toward 19,
both views, stage 1 on both binaries).  The law abstains on a parameter whose parent scope is not an instance
body; `R11U284_F3GENLOCAL_OFF` restores the unrefined law and its break (evidence/refsw.txt: away 9 vs 0).  Grid
cases/F (18 dirs, f17/f18 the generate-local shapes).

### § genCaCatMemberInst284 — `R11U284_CATMEMBERINST_OFF` (ExprEmit, the c7/c8 copy and mint branches)

A parameter folded as a DIRECT member of a concatenation in an IF-generate scope's continuous assignment whose
left side is a select (or member path, concatenation) or a generate-local name reads the instance (`work@dut`),
ours the scope (`work@dut.g`).  Decode: CompileExpression's concatenation branch pushes the getValue clone without
re-parenting it (the clone stays at the instance's param_assign, pass 282's decode), and the assignment's re-clone
(writeCont_assign: the right side reduces to a constant / bindVariable) copies the name the getter computed over
that chain.  A module-body whole left side keeps the scope in golden (grid C gi_l2_*) and abstains; a ternary
condition `(P == 1) ? ...` is a binary operand and keeps the scope.  Grids cases/C (42: if/for x local/outer/select x
seven right sides), C2 (62: header, untyped, sized, wildcard- and package-qualified parameters x if, case, nested
if, for, for-in-if, plus member path, concatenation left side, implicit net, outer wire, nested generate-local,
element select, call, replication, operation and select members, child and overridden instances), C3 (29, 64-bit
parameters with a signal member so the concatenation survives in golden, interfaces, depth 3, macros).
For-generate scopes are left as they are: ours already reads the instance on a local or select left side, as golden
does; golden reads the scope `work@dut.g[0]` on an outer whole left side where ours reads the instance (every such
grid case is stage 1 on both binaries on an unrelated typespec, not attempted).

### § hpSelPortConnFoldChain284 — `R11U284_HPSELPORT_OFF` (ExprEmit records, ParamEmit design-final)

A package parameter folded in a member-path select bound (`o.a[pk::DC-1:0]`) is named after the select
(`work@v5.o.a[4'h2 - 1:0].a`); in a port connection golden reads it through the port (`work@v5.u1.a.o.a[...].a`).
The law records the references the two select-naming sites write (§ stampFoldedPkgParamTs's hier_path branch and the
§ psBoundPaOwnerName192 site) and, design-final, renames one whose final chain runs through a `port` when the stored
name equals that chain with the port and its instance left out; a part select's other bound constant the select
never parented takes its sibling's new name.  Processes and continuous assignments keep the select name (h08, h09
controls).  Grid cases/H (12).

### § ternSgnLitFreshIntTs284 — `R11U284_TERNSGNLIT_OFF` (ParamEmit, the elaborated param_assign Rhs binding)

`localparam int T = C ? 1'sb0 : 1'sb1`: golden's elaborated Rhs constant binds a fresh unlocated signed
int_typespec, exactly as for `= 1'sb1` written directly (§ sgnLitElabFreshIntTs266 and the signed-binary branches);
a constant-condition ternary reads as its taken branch (§ ovEncTernaryTakenBranch28's decode).  Every base, sign
bit, nesting and condition kind (parameter, int localparam, literal, negation) in the grid; a taken branch that is
not signed keeps the declaration typespec (s04).  Gate as § sgnLitElabFreshIntTs266: module home, the signed `int`
keyword, not overridden.  Grid cases/S (22; other targets are stage 1 on both binaries).

## The grid (evidence/gridall.txt, gridsum.txt, attrib.txt; every line carries rc)

237 case dirs in A, C, C2, C3, E, F, H, S; both views = 474 case-views; labels pristine, law, law+R11U284_OFF and
law+each switch.  **222 moving, 102 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes**, uhdm-cmp line-count
changes 2 (S/s21_sub_inst d/e 18 -> 14, stage 1 on both binaries, the second instance's fresh typespec, toward),
**law+R11U284_OFF equal to pristine on 474 of 474**.  Every mover is back to pristine under exactly one switch:
ALIASPARENT 44, CATMEMBERINST 96, F3ELEMCHAIN 10, F3PARAMCOPY 26, HPSELPORT 18, TERNSGNLIT 24, and 4 (F f17/f18)
under F3PARAMCOPY with F3GENLOCAL also acting.

**Away census** (tools/probe/r11u272repro/drivers/awaychain.py, strictcmp_x): **chain away 0 on all 222 movers**,
399 records toward golden (evidence/away_grid.txt); positive control (binaries swapped) away 1 to 5 on 6 of 6
(evidence/away_poscontrol.txt).

**Downstream on the cases** (drivers/dscases.py): the 109 case dirs whose default view moves read the same verdict
on both binaries (94 IDENTICAL, 6 EQUIVALENT, 9 DIVERGENT) and the 327 slang-lane RTLIL and netlist files are
byte-identical.

## Byte controls (drivers/controls.sh; path lists filtered by $FENCED first; evidence/controls*.txt)

35 earlier repro dirs (passes 118/v11u118, 119, 120/v120, 124/v124, 131/v131, 282/v282, 280/v280, 278/v278,
276/v276, 274/v274, 272/v272, 270/v270, 266/v266, 111/v111, 108/v108, 134, 192, 256, r11v23, 23, 22), 2915 case
dirs, 5830 case-views: **46 moving, 8 entering STRICT_EQUAL** (r11u111 f3 k05_param_a and t08_param_only, r11u266
A/a24_chain_td_ctl and S/s38_ternary_ctl, both views), **0 leaving, 0 exit-code and 0 uhdm-cmp line changes, chain
away 0 on all 46** (evidence/away_controls.txt).  Some control goldens are absent where the pinned Surelog
segfaults on a case (NOGOLDEN on both binaries).

## Gates (worktree sweeps, SLANG_UHDM exported, workdirs /tmp/r11u284_wP and /tmp/r11u284_wL)

- Build: pristine md5 884cf2ee... equal to the main tree; law md5 91ba5bad...; both frozen before measurement.
- Probe: regressions 0, conversions 10, changes 3 (above).  Surelog: default CMP_EQUAL 478 + STRICT_NOTEQUAL 2,
  testflags 472 + 2, regressions/conversions/changes 0; every row identical to the pristine sweep except the
  LowMemLib/LowMemPkg testflags SURELOG_FAIL detail text (the workdir path, environment).  uhdm2rtlil 803/1/67 both
  modes, 0/0/0, rows identical.  Downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the csv
  byte-identical to the pristine sweep's.  Both sweeps exit 1 on the law-index check alone (the worktree carries
  the unlanded README; tests/LAWS.md is regenerated in the patch).
- uhdm-cmp: 0 lines on every touched probe case (all EQUAL or STRICT_NOTEQUAL); stamped_gen_param reads 64 lines on
  both binaries.
- **Firing census frozen before the law sweep** (drivers/tracecensus.sh, harness filter built from $FENCED;
  evidence/predict.txt, predict.md5): 13 probe databases and stamped_gen_param d/t fire (plus the
  ALIASPARENT_ABSTAIN lines on jeras_union d/t, which move nothing).  A first census on the unrefined law binary
  is evidence/predict_draft_law1.txt (superseded).
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors, SELFCHECK=1):
  PATH_SETS_IDENTICAL 2560, **MOVERS 2 / 2560** (uhdm2rtlil stamped_gen_param default and testflags, exactly the
  prediction), SELFCHECK 2559 / 2560 — pass 201's self-check artefact: every file is compared against the first
  path's pristine file, and that path's own pair is byte-equal.  Probe: **13 of 4087 databases move, exactly the
  predicted 13** (10 conversions, 3 changes).  Downstream: 1 of 805 slang-lane databases moves (stamped_gen_param),
  verdict unchanged.
- Corpus away census (evidence/away_corpus.txt): stamped_gen_param d/t chain away 0, toward 8 each.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS (EXPECT_UNKNOWN=1 and 6).
- Binary audit: 3265 of 3315 cmds.txt name each sweep's own binary, the other 50 run no slang, 8 fenced paths
  skipped by the filter (evidence/binary_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode): Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard d, BuildUVMPkg, Rggen d one hash each, equal to the law sweep's (evidence/determinism.txt).

## The probe residue (evidence/residue_first_records_base.txt, residue_chains_base.tsv, residue_buckets_base.txt)

214 STRICT_NOTEQUAL remain.  On this ground, ranked by cases, not attempted or not converted:
1. The member-path select element spans in an elaborated parameter initializer (`BIT0 = CFG.d[0]`,
   r11u21repro/t9, r11u24repro/n1): golden places ref_obj CFG at the `d` token and names bit_select d
   `work@kid.CFG.d[0].d` at 34-38, and the elaborated constant spans `CFG` only; three faces, the writer not located.
2. The select-naming law's leftovers b1_sites, v8_sites2, b3_edges, v92_b2_varsel (pass 280's list).
3. The struct-valued function fold leftovers r11u26 m4, m7 and r11u28 a2 (the leftover operation's ref name).
4. The for-generate concatenation member on an outer whole left side (golden `work@dut.g[0]`, ours the instance;
   stage 1 on both binaries in every grid shape).
5. r10buvm29repro/g29_d_fence (a streaming operand part select without a full name), r11u117repro g1/t12
   (a package member path in a function return), g1k_hop_userfn, vh_arrelem, the 64-bit cast value defect
   (r11u109 four cases, a Surelog defect, not copied).

## Sister-ground faces met (reported, not written)

- **The module-signal typespec of a package alias typedef** (A grid's next face `name` on a03, b01-b15; probe
  f5a20_ovr_pkgarr, b13_pkg_arr, y31_two_pkgs_rows after this pass): golden binds the package listing object
  (`pk::a_t` at the target type's span), ours a copy named `a_t` at the alias declaration — ModuleEmit
  `emitInstance` for ports and variables, TypeEmit `bareScalarTypedefVarTs` / `bareScalarTdCopyOfFresh16` for a
  type-parameter override (gdb on the line-table build).
- **r10vearl100repro/v6_more100** (a struct alias of a struct typedef): the stored `work@<top>.vp6::alias_t` is
  written by ModuleEmit `emitImportArtifacts`; golden reads the chain, `vp6::alias_t` (the listing unparented by
  writeCont_assign's reset, z1 assigned in the top).
- **Anonymous aggregate member names by chain** (r11u107repro a08_anon_member, a18_anon_typedef, r11u113 e05_nested,
  v11u93b107 p02_nested_member_dim): golden reads `t_t.m.a` where ours stored `a`; TypeEmit `buildStructTs`.  Naming
  those refs by their chain converts all four (measured in the removed experiment).
- r10earl104repro/vb4_instarr (a module-array range bound's bit_select full name), r11u1repro/grid2 and
  r11v1repro/vA (a positional modport port connection's spans), v11u111repro x40_class_prop (FACE 3's listing
  relocated by a class property): writers not decoded, all module/type ground.

## Process

**Fence.** Every corpus path list was built first and filtered by `$FENCED` (word boundary, read fail-closed from
tools/probe/r11u107repro/canaudit.sh) before any file was opened: mirror.sh, audit.sh, corpcensus.sh (a census of
golden and our alias references over the pristine sweep's 3315 cmds.txt, 8 fenced paths dropped by the list
filter), the probe and downstream byte comparisons, and the firing census through the harness filter.  rtsinfo.cpp
refuses a fenced path.  No fenced source, database or cmds.txt was read, run or decoded; gdb ran only on probe and
fresh cases.

**Processes.** No other agent's process was listed or signalled.  **Slip:** a background waiter used
`pgrep -f` with a pattern contained in its own command line and could not finish; it was stopped by its own task id
before anything else ran, nothing signalled, and replaced by a waiter on the census log's final line.  A later
process check read `/proc/<pid>/cmdline` for paths of this pass only.

**Other notes.** The interactive shell's `find` is a wrapper function that skips hidden directories; corpcensus.sh
reads the golden as `<cache dir>/golden.uhdm` directly.  The first byte controls ran on the unrefined law binary
(46 movers, s00_stamped_corpus away 9); the refinement was added, and the grid, the census, the controls and every
sweep were rerun on the final binary.  The main tree was not written.

**Files.** README; cases/ A, C, C2, C3, E, F, H, S (each dut.sv names its law on its first line); drivers/
(env.sh, case.sh, gridall.sh, gridsum.py, gsum.py, attrib.py, controls.sh, ctlsum.py, awaygrid.sh, tracecensus.sh,
det.sh, mirror.sh, audit.sh, dscases.py, classify.py, chains.py from r11u282repro; rtsinfo.cpp, rtsgrid.sh,
aliascensus.py, corpcensus.sh, gdbfn.sh, trrun.sh new); evidence/.
