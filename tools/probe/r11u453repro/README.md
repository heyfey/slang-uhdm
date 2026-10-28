# r11u453 — pass 453, expression/parameter ground (implementer)

Base ccfaa169 (pass 450 on top of pass 451). Ground: src/ExprEmit.cpp,
src/EmitHelpers.h, src/ParamEmit.cpp (StmtEmit.cpp untouched). Eight laws, each
behind its own switch read through src/LawSwitch.h (`lawOn(453, ...)`);
`R11U453_OFF` drops all of them; `R11U453_TRACE=<dir>` logs each firing through
`lawTrace(453, ...)`. No src/R*.h, no getenv, no header change.

Binaries: pristine = the main tree's build/slang-uhdm at the base
(md5 bcbbf4bebc1acb00e518ec826fbaabdf, copied to /tmp/r11u453_bin/pristine);
final law binary law14 (md5 a6737bb721028e3e28cd355e393687f4, links slang
12.0.0+545f88b2e).

## sv-tests heads at the base

The 20 open both-accepted rows (results/golden_svtests.csv DIFFERENT) were
re-read with uhdm-cmp on the master's control databases and the cached
Surelog goldens: tnoc's head is the standing tnoc_pkg.sv 333:14 constant
(golden UINT:241, ours UINT:1; Surelog's function evaluation, a Surelog
artefact), the 12 uvm-examples rows, the 3 scoreboard rows and easyUVM stay at
the module/type ground's class and design listings, p733 and p737 as before.
No head lands on this ground, so this pass works the reported faces (the
sister pass 450's var_select face) and pass 451's residues, then the carried
backlog (pass 417's VH endcol residue).

## Laws

1. § vsTrailRangeColonJoin453 (R11U453_VSCOLJOIN_OFF; ExprEmit,
   `vsTrailRangeName453`) — a plain var_select's trailing part select or
   indexed part select joins its doubled name with `::` in a package or class
   scope: UHDM's ComputeFullName uses one separator for the whole chain, so
   golden names `m[1][2+:2]` in `p::f` as `p::f::m::m` (and a reference under
   an operation of its base `p::f::m::m::i0`), where ours wrote `p::f::m.m`.
   A module scope keeps `.`; a qualified parameter base
   (§ pkgQualParamVarSelFull118) is left alone. The dotted-path twin is
   § hpVarSelColumnJoin220. This is THE SISTER PASS 450's REPORTED FACE
   (r11u450 IX/ix13, ix17 to ix19 and v11u450 VX/vx08, STRICT_NOTEQUAL on
   fullname on both binaries at the base).
2. § vsTrailRangeParenStart453 (R11U453_VSPARENSTART_OFF; ExprEmit,
   `vsTrailSelRange453`) — a var_select's trailing (indexed) part select spans
   its written range with the parentheses: Surelog locates the select at the
   part_select_range node, so `q[k][(k)+:2]` starts at the `(` (6:24) where
   ours took the bound's own start inside it (6:25), and `q[1][3:(2)]` ends at
   the `)`. The range's syntax is found under an ElementSelectExpression, the
   last selector of an IdentifierSelectName, the right side of a ScopedName
   or inside a ParenthesizedExpression (a cast operand). Applied at the plain
   var_select builder and at the dotted path's trailing var_select
   (§ hpVarSelRangeIdxNamesByPath220's site).
3. § hpPartSelParenRightEnd453 (R11U453_HPPSPARENEND_OFF; ExprEmit,
   `hpPsRightEnd453`) — a dotted path's trailing part select ends at its
   written right bound with the parentheses: golden `s.data[N-1:(0)]` 5:20-5:32,
   ours 5:31. The indexed twin is § memberIpsParenEnd264. Clears pass 417's
   residue v11u417 VH/vh17, vh22, vh29 (STRICT_NOTEQUAL endcol -> STRICT_EQUAL).
4. § hpVsParenBoundPretty453 (R11U453_HPVSPARENBND_OFF; ExprEmit) — a dotted
   path's trailing var_select whose range bounds are written in parentheses or
   with `**` is named from the bound objects (Surelog's decompileHelper through
   ExprEval::prettyPrint, no parentheses, spaced operators): golden
   `tq[1].pg[1][3:2]` for `tq[1].pg[1][(3):(2)]` (the hier_path, read by
   uhdm-cmp, and the var_select's full name). The part-select twin is
   § hierSelParenBoundPretty417. uhdm-cmp NOT_EQUAL -> STRICT_EQUAL (HP/hp08,
   hp11, hp12, hp14, hp15).
5. § pkgExplicitImpParamReExport453 (R11U453_XPARAMREEXP_OFF; ParamEmit,
   `pkgExplicitImpParam453`, called from collectImportedParams'
   `collectPkgParams` and the § 451 per-path walk) — a package's EXPLICIT
   import of a parameter is part of what it re-exports to a wildcard importer:
   `CompileHelper::importPackage` with an object name still runs its parameter
   loops filtered to that name, so `import a::PA;` in b inserts PA into b's
   getParameterMap() and its param_assign into b's getParamAssignVec(), and
   `import b::*` copies both. A parameter met twice under one import item this
   way is the same map entry, so the repeat is an assign-only occurrence
   (Parameters once, Param_assigns twice; the v11u451 case VA/va06's top lists
   2 parameters and 3 param_assigns). Clears pass 451's residue DI/di04 and
   VA/va06 (uhdm-cmp NOT_EQUAL -> STRICT_EQUAL) and v11u451 VD/vd02.
6. § pkgImpParamsAheadOfOwn453 (R11U453_IMPPARAMFIRST_OFF; ParamEmit) — a
   package re-exports its imported parameters ahead of its own wherever the
   import item is written (CompilePackage's FUNCTION pass materializes the
   imports before the DEFINITION pass compiles a declaration, the parameter
   half of § caPkgCloneListingComesFirst84): `package b; parameter int PB = 2;
   import a::*;` re-exports PA, PB. Fires only when an import item follows a
   parameter declaration.
7. § pkgExplicitImpVarReExport453 (R11U453_XVARREEXP_OFF; EmitHelpers.h,
   listing217) — a module's (or interface's) copy of an imported package now
   carries the entries the package's own explicit imports put in its signal
   vector, as the package's own listing already does
   (§ caPkgExplicitImportClonesItsOneEntry84): `package b; import a::va;`
   under `package c; import a::*; import b::*;` gives `module top; import
   c::*;` two copies of va, net and variable.
8. § modCopyImportsFirst453 (R11U453_MODCOPYIMPFIRST_OFF; EmitHelpers.h,
   listing217) — the module's copy of a package lists the package's import
   clones ahead of its own variables and nets (LAW C of pass 84, which the
   package's own listing applies and this walk did not) when an own entry
   precedes an import item and the package hoists no out-of-body constructor
   local. Measured on r11u84 t3_shapes and t6_slots (both still NOT_EQUAL at a
   typedef-typed wire net, the dump distance 2132 -> 1739 and 1609 -> 1137).

## Grid (tools/probe/r11u453repro/cases, every first line names its law)

drivers/run1.sh golden (Surelog -parse -nobuiltin -nocache -sv, cached per case
text under /tmp/r11u453_scr/gold) + ours + uhdm-cmp line count + uhdm-strictcmp
verdict; drivers/grid.sh two binaries per case; evidence/grid_pristine_vs_law14.txt
is the whole control grid (1192 case dirs: this pass's cases, the
r11u220, r11u417, v11u417, r11u147, r11u451, v11u451, r11u450, v11u450,
r11u118, r11v11u118, r11u84, r11u196, r11u292, r11u121, r11u79, r11u183dec and
r11u293 grids). Every exit code 0 on both binaries.

- VS (§ vsTrailRangeColonJoin453): vs01 to vs06, vs08 to vs10, vs12, vs13
  STRICT_NOTEQUAL fullname -> STRICT_EQUAL (package functions and tasks, a
  package class method, a $unit class, a class in a module, `+:` `-:` and
  simple ranges, references under an operation of the base, a package
  parameter width and bound, a clone importer); controls vs07 (module scope)
  and vs11 (interface function) byte-identical.
- VP (§ vsTrailRangeParenStart453): vp01 to vp05 STRICT_NOTEQUAL col / endcol /
  fullname -> STRICT_EQUAL (module process, simple and indexed, a
  parenthesized right bound, a package function, cast operands).
- HP (§ hpPartSelParenRightEnd453, § hpVsParenBoundPretty453): hp01 to hp04,
  hp06, hp07, hp09, hp10 STRICT_NOTEQUAL endcol -> STRICT_EQUAL (continuous
  assignment read and left side, procedural left side, interface path, package
  function, a parameterized module, a cast operand); hp08, hp11, hp12, hp14,
  hp15 uhdm-cmp NOT_EQUAL -> STRICT_EQUAL (the var_select naming, with
  § vsTrailRangeParenStart453 at the dotted site); controls hp05, hp13
  byte-identical.
- XP (§ pkgExplicitImpParamReExport453, § pkgImpParamsAheadOfOwn453): xp01 to
  xp04, xp06, xp07 uhdm-cmp NOT_EQUAL -> STRICT_EQUAL; xp05 (a typedef-typed
  parameter) moves bytes and stays NOT_EQUAL at the residue face of
  evidence/residue/TS.
- XV (§ pkgExplicitImpVarReExport453): xv02 to xv04 uhdm-cmp NOT_EQUAL ->
  STRICT_EQUAL (module and interface importers, a variable and a net, the
  root package's own explicit import); control xv01 (wildcard diamond)
  byte-identical.

Control movers outside this pass's cases (all toward golden, none worse on
either judge): r11u450 IX/ix13, ix17, ix18, ix19 and v11u450 VX/vx08 (the
reported fullname face; vx08 to STRICT_NOTEQUAL type at the sister's clone
binder face, evidence/sister/HS); r11u451 DI/di04, v11u451 VA/va06, VD/vd02
(NOT_EQUAL -> STRICT_EQUAL); v11u417 VH/vh17, vh22, vh29 (endcol ->
STRICT_EQUAL); r11v11u118 grid/v3/x04_vs_paren (col -> STRICT_EQUAL); r11u84
t3_shapes (uhdm-cmp 2532 -> 60 lines), t6_slots (1476 -> 60), t2_expkinds
(dump distance 2206 -> 1852), t4_expviews (2211 -> 2034), t5_expfences (a
Surelog error run, golden writes nothing worth following; 652 -> 683 at law13,
unchanged by the ordering law); r11u79 z7_pkgimpclone (723 -> 644).

Switches (evidence/switches_law14.txt): R11U453_OFF gives pristine's bytes on
57 of 57 movers; on every mover the switches of the laws its trace names give
pristine's bytes together, and on the single-law movers each law's own switch
alone.

## Sweep (one full five-stage sweep on law14, trace on)

drivers/fullsweep.sh: tests/sweep.sh --jobs 3 --workdir /tmp/r11u453_sw --corpus
"probe surelog uhdm2rtlil downstream" from the worktree, then the sv-tests stage
through the main tree's scripts/check_svtests.py (the worktree's UVM submodule is
empty) on the same binary and workdir, SLANG_UHDM=/tmp/r11u453_bin/law14,
R11U453_TRACE=/tmp/r11u453_trace, launched on a quiet machine (no sweep, runner,
probe, golden or downstream process of any agent live).

- probe: EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, regressions=0 conversions=0
  changes=0; the 4087 databases path-normalized-dump identical to the master's
  control /tmp/intr11u450/probe (0 movers; comparator positive control: two
  different cases flagged).
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0
  changes=0; the csv differs from the control only in the two LowMem log-path
  texts. byteverify 0 of 962 (SELFCHECK 961 of 962 flagged).
- uhdm2rtlil: 803/1/67 in both modes, 0/0/0; the csv identical to the
  control; byteverify 0 of 1608 (SELFCHECK 1607).
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871;
  the csv identical to the control; byteverify 0 of 805 (SELFCHECK 804).
- sv-tests: EQUAL 1920, DIFFERENT 20, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0
  conversions=0 changes=0; the status column identical to the control on all
  2346 rows. NO sv-tests row converts: none of the 20 open rows has its head
  on this ground.
- canaries: canaries.sh ok=52 (surelog) and ok=16 (uhdm2rtlil); ctcan2
  EXPECT_UNKNOWN=1 ok=58 PASS and EXPECT_UNKNOWN=6 ok=2 PASS.
- binary audit: surelog 1531 of 1581 cmds.txt name /tmp/r11u453_bin/law14, the
  other 50 hold only a Surelog line; uhdm2rtlil 1742 of 1742; sv-tests 2346 of
  2346.

THE TRACE CENSUS (the by-name prediction): the grid and the text scan
(drivers/scan.py over the corpus sources, fence-filtered before any file is
opened: 136 files with an explicit non-wildcard import, 991 with a
parenthesized range bound, 265 package or class files with a multi-index
select; sv-tests 71 / 459 / 17) predicted that the eight laws fire on shapes
the corpora barely hold, the explicit imports being module-level and the
parenthesized bounds in modules outside a var_select's trailing range. The
sweep's trace names exactly one firing process in all five stages: the probe
case r10uvm92repro/v92_b2_varsel (§ vsTrailRangeColonJoin453, two names
computed for `vsp::probe::probes::uv` that a later rule rewrites; its database
path-normalized identical to the control), and no corpus row, downstream row
or sv-tests row. Trace positive control: the same runners with
R11U450_TRACE set log pass 450's firings on sv-tests uvm_messaging_example (21
lines through check_svtests.py) and surelog MiniAmiq default (12 lines through
verify_golden.py), so the environment reaches the binary in every stage. So no
sweep hash moves and nothing is re-recorded.

Downstream on grid cases (ds.one, both lanes): VP/vp01, vp05 and XV/xv04
EQUIVALENT -> IDENTICAL; VP/vp02, HP/hp01, hp02, hp08, hp09, hp11 and XV/xv02
IDENTICAL on both binaries; none away.

## Goal 1

Nothing new on this ground. The 75 SURELOG_ONLY rows' details are all upstream
slang front-end diagnostics (file:line: error ...); none carries an exporter
message. The goal-1 probe faces C::mk().arr[1], u.mk(x).a[2] and
this.mk().inner.s were not reached. The black-parrot size guard
(R11U403_MACROLITGUARD_OFF) stands, not measured this pass; generated/rsd/rsd
stays SURELOG_CRASH (Surelog dies first). No exit-code mover in the grid (every
case exit 0 on both binaries), the probe stage or any corpus stage.

## Residues (ranked)

1. A module variable initializer reading an imported package variable
   (`int x = vc;`, pass 451's DI/di02): the initializer's reads are not
   emitted through ExprEmit's emitExpr (a trace at the NamedValue case head
   never fired on evidence/sister/IR/ir01 and ir05), and golden binds the read
   to the module's own import copy `work@top.vc` (listed by both producers);
   the qualified twin `int x = c::vc;` (ir05) keeps golden's `c::vc` name, the
   scope span 6:11-6:14 and the package's own `c::vc` variable. ir01, ir02,
   ir04, ir06 to ir10 uhdm-cmp NOT_EQUAL on both binaries; ir03 (net
   declaration), ir11 (generate block), ir12 (block local) and IQ (process and
   continuous-assignment reads) STRICT_EQUAL. Sister-ground (below).
2. A typedef-typed package parameter re-exported through a second package
   (evidence/residue/TS/ts02, XP/xp05): uhdm-cmp NOT_EQUAL at a param_assign
   constant (golden size 4, ours 64) on both binaries; the visible dump differs
   only in weakly referenced typespecs. Not decoded.
3. r11u84 t3_shapes and t6_slots: next head a typedef-typed wire net in the
   module copy (`wire mw_t m_wtd`), pass 84's residue.
4. A wildcard import written twice in one package (pass 451's DN/dn02,
   VL/vl08) and DI/di05: unchanged.
5. The carried lists of passes 451 and earlier (the brief's items (a) to ({)),
   not reached.

## Sister-ground faces (reported, not written)

- The module variable initializer binding of residue 1 (ModuleEmit's
  elaborated variable writer, the initializer emitted outside emitExpr; the
  module copy itself is right).
- A dotted path's trailing indexed part select in an importer's clone body
  (`s.f[i0+:4]` in `r::f`): golden binds the select to the struct's
  typespec_member `f` (vpiActual with the ref_typespec `work@top.p::s_t.f`),
  ours leaves it unbound (evidence/sister/HS/hs02, STRICT_NOTEQUAL type on both
  binaries, the home view hs01 STRICT_EQUAL; v11u450 VX/vx08's next face).
  UhdmExporter's clone binders (§ cloneLhsIdxPartSelBind450's sweep).
- The unpacked-array local of a package task (`logic [3:0][7:0] m [2]`) at its
  logic_typespec instance (pass 450's IX/ix22 residue; TypeEmit).

## Process

Within the budget: no pristine build of my own (the pristine is the main
tree's build copied to /tmp/r11u453_bin/pristine, md5 equal to the brief's);
law1 to law14 on case runs only; one full five-stage sweep on law14;
byteverify once against the master's control /tmp/intr11u450; the trace
positive control two one-row runner calls on a quiet machine. Slips, none
affecting a measurement: the first ExprEmit edit landed while the worktree's
first build was still compiling other units (before ExprEmit's turn), so that
build is law1 and no base binary was built in the worktree; intermediate law2 and law3 builds
changed nothing (the syntax lookup missed the IdentifierSelectName form, found
by a debug trace that was removed before law4); law13 to law14 added
§ modCopyImportsFirst453 after the control grid showed r11u84 t6_slots
growing its dump distance under § pkgExplicitImpVarReExport453 alone (1609 ->
1673; with the ordering law 1137). The fence list was read into a file by a
program without printing it and every tree-wide scan filtered on it before
opening a file; no fenced test named, opened or run; no other agent's process
touched.
