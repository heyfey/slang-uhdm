# r11u167 — the expression/parameter ground of the strict axis: six laws on type-parameter struct copies, evalFunc leftovers, generate-scope folds and dotted paths, 8 row-modes converted

Base `576b21fa` (branch matrix-1.87). Ground: `src/ParamEmit.cpp`, `src/ExprEmit.cpp`, `src/EmitHelpers.h`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or `include/`; the faces whose fix sits there stop at the decode (section "Sister-ground faces").
Net binding is not touched. The laws of passes 140/145/147/154/158/163, r11u151, r11u157 and the
r11u141/149/153/154v/158v/159/162/163v refinements are not edited: every law here is a new site or a new post-pass
under its own switch. Worktree `/tmp/wt_r11u167`, system-deps config, `-j 2`. The map r11u165map was not present at
the start; the seventh edition (r11u156map) was read for sites only, and the row heads were re-measured at the base
(drivers/allrec.sh: every differing strict record of every STRICT_NOTEQUAL row-mode of the pristine sweep).

| binary | md5 |
|---|---|
| pristine (worktree build of the base; byte-identical to the main tree's `build/slang-uhdm`) | `2a705713aa2d9ba859d3fd83eaa95ed7` |
| law (this patch; `lawG` in the scratch naming) | `a56d01dffa006e046c84f4ac844d63c3` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |
| `strictcmp_raw` (drivers/mkstrictraw.sh: the same comparison, the raw full name printed next to the canonical one; measurement only) | `933595297e21c137fec1857344a3fa8c` |
| pristine built with `-g1` (gdb pins only; a `git archive` of the base) | not a gate binary |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u167_bin`) before it was measured. The pristine sweep
(`/tmp/r11u167_swP`) and the law sweep (`/tmp/r11u167_swL`) have workdir names of the same length. In both sweeps all
1531 surelog and all 1742 uhdm2rtlil `cmds.txt` slang lines name the frozen copy of that sweep's binary (pristine or
law). The pristine sweep reads `regressions=0 conversions=0 changes=0` in all three stages against the committed
baselines, its `probe.csv` is byte-identical to `results/golden_probe.csv`, and its downstream stage reads 803
IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT (evidence/sweep_pristine.log). Its only red is `law index STALE` (the
worktree's abbreviated hashes); the regenerated tests/LAWS.md in this patch clears it.

**The fence.** No binary, gdb run, script or reader touched a slang-fenced test's source or database outside the
gate sweeps. The firing census (drivers/census.sh) refuses to run without `$FENCED` and dispatches the corpora with
`--filter '^(?!(<the four>)$)'` ("fenced mentions: 0" on every run). The row readers drivers/rowrec.sh, allrec.sh,
moverdiff.sh, srcgrep.sh (a corpus source grep that drops every fenced path before reading) and predict.py refuse to
run without `$FENCED` and refuse or skip a fenced name. A grep of this directory for the four names reads 0.

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 871 | **875** | +4 |
| uhdm2rtlil strict-equal (of 1606) | 1538 | **1542** | +4 |
| probe EQUAL (of 4087) | 2597 | **2626** | +29 |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | the law sweep's downstream.csv is byte-identical to the pristine sweep's |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them).** The fresh csv rows
of the law sweep (evidence/sweep_law.log):

    surelog:
      StructParamFieldRange,default,CMP_EQUAL,,,equal              § tpAnonStructLastParamUser167 + § tpAnonStructCopySpanAtKeyword167 (was differ:fullname(7))
      StructParamFieldRange,testflags,CMP_EQUAL,,,equal            (same)
      StructParamFuncBodyFieldCompare,default,CMP_EQUAL,,,equal    the two above + § evalFuncBodyRhsStampClone167 (was differ:fullname(11))
      StructParamFuncBodyFieldCompare,testflags,CMP_EQUAL,,,equal  (same)
    uhdm2rtlil:
      cva6_struct_param_field,default,CMP_EQUAL,,,equal            § tpAnonStructLastParamUser167 + § tpAnonStructCopySpanAtKeyword167 (was differ:fullname(7))
      cva6_struct_param_field,testflags,CMP_EQUAL,,,equal          (same)
      ibex_register_file_ff,default,CMP_EQUAL,,,equal              § genProcFoldDeclTsScopeNamed167 (was differ:fullname(31))
      ibex_register_file_ff,testflags,CMP_EQUAL,,,equal            (same)
    downstream (fresh rows of the law sweep, IDENTICAL as before):
      cva6_struct_param_field,IDENTICAL,OK,OK,1,1,,
      ibex_register_file_ff,IDENTICAL,OK,OK,3663,3663,,

**CHANGES (2, surelog):** StructParamPatternInitCast d/t `differ:fullname(11) -> differ:fullname(3)`: 8 records leave
(the two type-parameter laws and § pkgPatCallArgReadNoParent167), none enter; the 3 left are residue 1 below.

**Probe: 29 cases go `STRICT_NOTEQUAL -> EQUAL`, 13 change, 0 regress** (evidence/probe_changes.txt; the laws that
fired on each case are in evidence/predicted_movers.tsv). The conversions: 24 by the two type-parameter laws (the
r11u109 f1 grid f02-f24 and p01 p02 p04 p05 p09, r11u47 g1 g5, r11v47 v16 v23 v29), 4 by those with
§ evalFuncBodyRhsStampClone167 (r11u109 f1 b01-b04), 1 by the parent half's type-parameter branch alone
(`r11u107repro/grid/t15_tp_struct_unused`). The 13 changes all lose records: r11u109 c01-c06
`fullname(11|13) -> fullname(3|5)` (the two type-parameter laws and § pkgPatCallArgReadNoParent167; the 3 left are
residue 1's face), p03 p06 p07 `fullname -> type(1) / value(2)` (the fullname records leave and a later difference
becomes first), r11u47 g2 g9 and r11v47 v7 v30 (counts down; g2 and v30 by the span half alone). Every probe
mover was attributed record by record against its golden (drivers/pdiff.sh, evidence/probe_movers_records.txt):
**339 records leave and 0 enter on all 43 movers**; one mover is record-neutral (`v11u117repro/grid/b02`, a
`f(q2::IMPL.cfg)` call argument: its strict walk diverges before the package listing, where our operation's reference
now matches golden's unnamed one, checked in the dumps).

## Targeted rows (brief items), before -> after

| row | before | after | law / what is left |
|---|---|---|---|
| (2) R-SP StructParamFieldRange d/t | fullname(7) | **CMP_EQUAL** | § tpAnonStructLastParamUser167 + § tpAnonStructCopySpanAtKeyword167 |
| (2) R-SP cva6_struct_param_field d/t | fullname(7) | **CMP_EQUAL** | the same two laws |
| (2) R-SP StructParamFuncBodyFieldCompare d/t (map row, same family) | fullname(11) | **CMP_EQUAL** | the same two + § evalFuncBodyRhsStampClone167 |
| (2) R-SP StructParamPatternInitCast d/t (same family) | fullname(11) | fullname(3) | residue 1 (the flattened elaborated pattern) |
| (2) const_cast_signext d/t | line(5) | line(5) | a TYPEDEF (not a type parameter): the value-parameter copies keep the typedef span where golden relocates the shared object to the last formal (§ modAggTfArgLastWriter155 is TypeEmit's); the walk then diverges at a func_call golden keeps: no conversion reachable here |
| map row ibex_register_file_ff d/t | fullname(31) | **CMP_EQUAL** | § genProcFoldDeclTsScopeNamed167 |
| (3) whitespace inside a dotted path | — | law | § hpDotWsTrimmed167 (grid ws/w02 NOT_EQUAL stage 1 -> STRICT_EQUAL); fires on no corpus row and no probe case (census) |
| (2) based literal inner space | — | not landed | the sister's fold is not in HEAD at the start (576b21fa: `ppFold119Line` has no base-digit run; r11u164 unlanded): the subtraction sites are listed below and left |
| (2) UnionCast d/t value(26/28) | value | value | decoded to TypeEmit makeBoundConst (S2 below), not ExprEmit |
| (2) ibex_multdiv_fast d/t endcol(26) | endcol | endcol | decoded to TypeEmit emitSyntaxExpr (S1 below), not ExprEmit; its 11 enum_const `file` records are a second face |
| (1) LocalScopeHierPath t | fullname(1) | fullname(1) | residue 2 |
| (1) iface_zero_width_field d/t | fullname(4) | fullname(4) | not worked (pass-163 residue 2 stands) |
| (4) N0427 InterfArrayBind d | fullname(3) | fullname(3) | residue 3 (decoded; needs an elaborated-view flag the ExprEmit site lacks) |
| (4) N0129 YosysOldOpen t, N1115 PackedArrayHighConn d/t, UnsizedParam d | — | unchanged | sister faces as pass 163 decoded them (ModuleEmit) |
| (1) rl/q03, hc/g02, sy/b08, ip/e04, ip/e02, rc/f03, tp/g02, tp/g08, po/c10, lr/r01, r11u157 R2/R3/R6/R8/R9, gl/l4, ev/e16, hl/h3 | — | unchanged | not worked in this pass |
| (3) ComplexHierPath d/t, the generate-condition conditional, sub.q[0] / G.H.y, ma/e6 | — | unchanged | not worked |
| (5) pair B r11u164 | — | — | not landed at the start or at the law sweep (main tree HEAD 576b21fa throughout) |

## Laws (each under its own switch; `R11U167_OFF=1` drops all of them; `R11U167_TRACE=1` prints one stderr line per firing)

Sites are named by function and § token (`grep -n '§ <law>' src`). The switch table is the r11u167 block at the end of
src/EmitHelpers.h. Every law was decoded on purpose-built goldens of the pinned Surelog (the grids below), comparing
pristine and law databases with `uhdm-strictcmp` and with `strictcmp_raw`, whose raw full names show what a copy's
canonical name hides.

### § tpAnonStructLastParamUser167 (`R11U167_TPSTRUCTUSE_OFF`; ParamEmit.cpp, the recorder at the head of emitParameters and the post-pass at the end of drainShareDefParamTs)
A type parameter whose type in force is its written anonymous packed struct/union (`localparam type it_t = struct
packed {..}`, or a `parameter type` default not overridden in that listing) holds ONE struct object in Surelog,
compiled in the definition: compileTypeParameter parents it at the type_parameter, and every value parameter
declared with the type (`localparam it_t I = ..`) re-parents that same object at itself (the last one wins). The full
names of the members' references are computed through that chain: golden StructParamFieldRange's type_parameter
lists `work@StructParamFieldRange.I.x` in the definition AND the elaborated listing (grid rs/r08: `work@sub.I.x`
under both instances: the definition's parameter); `it_t J` declared after `I` wins (rs/r03); an unused type keeps
`work@top.it_t.x` (rs/r15, rs/r16 for a header `parameter type`). Ours left the struct unparented (a body type) or at
the type_parameter with the member names already fixed as bare `x` (a header type). The law parents the listing's
struct at the definition listing's last value parameter (else at the definition's type_parameter), clears the
members' reference names so they compute through the chain, and clears the stored `<prefix>.it_t.W` name of a range
reference inside a member (golden `work@top.I.x.W`, rs/r01). Only when nothing else in the body names the type (a
token count over the module's syntax): a net or variable of the type re-parents the struct again in elaboration
(rs/r06 whole-assigned: bare; rs/r12 member-written: `work@top.v.x`, residue 4), and a subroutine naming it relocates
the struct to its formal (rs/r20, residue 5): no half of either law fires there. Cases rs/r01 r02 r03 r05 r08 r09
r10 r15 r16 r17 r19 r21 (STRICT_EQUAL); controls rs/r04 (a typedef: equal on both), rs/r20 (no firing).

### § tpAnonStructCopySpanAtKeyword167 (`R11U167_TPSTRUCTSPAN_OFF`; ParamEmit.cpp, the same post-pass)
The value parameter's typespec copy and its param_assign pattern copy are, in Surelog, that same struct object: they
keep the type parameter's span, the bare `struct` keyword of § typeParamStructAtKeyword146 (golden 23:26-23:32;
ours spanned the whole struct 23:26-26:4, a header type 2:36-2:83 against 2:36-2:42). Only the end moves, and only on
a copy starting where the type parameter's struct starts. This half also fires when a net or variable names the type
(rs/r06: the three span records leave and the case turns STRICT_EQUAL). Cases rs/r06 and every case of the law above.

### § pkgPatCallArgReadNoParent167 (`R11U167_PATCALLARG_OFF`; ParamEmit.cpp drainShareDefParamTs, the read set of § pkgPatReadTsNoParent131's package loop)
A package pattern parameter read as a CALL ARGUMENT in a live parameter context (`parameter cfg_t Cfg =
pkg::mk(pkg::B)`, a body localparam, a macro-born default) is constant-evaluated by the producer (ExprEval's value
functor -> CompileHelper::getValue's qualified-name branch, CompileExpression.cpp), which writes the flattened copy back:
the package listing's pattern reference is unparented and unnamed (golden StructParamPatternInitCast `cfg_pkg::Base`
and grid pc/c01: unnamed; ours `cfg_pkg`). A plain qualified DEFAULT keeps it (pass-124 grid c13 q04; pc/c06 has both
reads and is unnamed). The read gate is § pkgElabPatMemberStamp58's `pkgPatCallArgParam58` (live contexts only: a
dead generate branch does not fire, pc/c07). Cases pc/c01 c02 c06 c09 (STRICT_EQUAL); controls pc/c07 (dead branch),
pc/c10 (an unqualified `mk(B)` after an import: not in the read set; equal records on both).

### § evalFuncBodyRhsStampClone167 (`R11U167_S2CLONE_OFF`; ParamEmit.cpp stampEvalFuncLeftovers, a walk after the TopModules stamp and the helper cloneStampTree167)
When a struct member's evalFunc leftover is the function BODY's own right-hand side (§ r10fsv3 S2: the body reads a
formal member whose caller element is unreduced: `r.Flag = (c.NrRules > 0) && (c.Length > 0)`), golden's ELABORATED
parameter holds its own struct copy whose stamped member carries a COPY of that operation, parented at the member,
whose path elements after the first hold no stored name: golden StructParamFuncBodyFieldCompare
`work@...Cfg.cfg_pkg::cfg_t.Flag.NrRules`, one copy per instance (grid fs/f02 `work@top.u1.Cfg...` and `u2`), while the
package typedef, the definition listing's copy and the struct_var's typespec keep the body object
(`cfg_pkg::build_config::NrRules`). Ours shared one struct (the package typedef) on every listing, so the elaborated
parameter gets its own copy of it (members copied, parented at the parameter, member references named through it:
golden `work@top.Cfg.cfg_pkg::cfg_t.XLEN`) and the S2 member gets the clone. The clone copies operations, hier_paths,
ref_objs and constants field for field and gives up (keeping the share) on any other kind. Cases fs/f01 f02 f03 f06
(STRICT_EQUAL); residues fs/f04 (a package holder: a different depth face, unchanged) and fs/f05 (an import: stage 1
on both, unchanged). Corpus: FuncStructVal d/t move toward golden (the elaborated copy's two names now match golden's
name set exactly, evidence/corpus_movers_records.txt) without a verdict change (its walk diverges earlier).

### § genProcFoldDeclTsScopeNamed167 (`R11U167_GSFOLDDECLTS_OFF`; ExprEmit.cpp emitExpr, the generate-scope process parameter fold, at the `rt->VpiFullName(rpfx9)` line)
A module parameter folded inside a generate-scope process (`rf_reg_q <= WordZeroVal;` in `g_rf_flops`) carries a
typespec built from the parameter's declared type (`declTs9 = makeTypespec(psym)`), and Surelog's copy of it is
parented at the scope its reference is named by (the module, or the generate block under an operation:
§ genProcFoldTsKeepsScope154's `rpfx9`): the references in its range compute `work@ibex_register_file_ff.DataWidth`
(grid gz/z04 `work@top.W`, gz/z05 under an operation `work@top.g.W`, gz/z08 per instance), and a folded bound's
constant reference reads the scope (`p::PW-1`: `work@top`, gz/z06). Ours left the copy unparented: the names were
empty. The law names the range references `rpfx9.<name>` and the constants' references `rpfx9`, on a fresh one-range
logic/bit typespec only: a multi-dimensional declared type is the parameter's own object in golden (`work@top.Z.W`,
gz/z07, residue 6). Cases gz/z01 z04 z05 z06 z08 z09 (bit) z10 (localparam) z11 (macro-born); controls gz/z02
(module-level process: equal on both), gz/z07; gz/z03 z12 are stage 1 on both.

### § hpDotWsTrimmed167 (`R11U167_HPWS_OFF`; ExprEmit.cpp emitExpr, the HierarchicalValue branch after the component split)
Whitespace around a written dot (`assign bs . wdtxx = a;` through an interface instance) is no part of a component:
golden's hier_path is `bs.wdtxx` with elements `bs` and `wdtxx` located at their tokens; ours carried `bs . wdtxx`
and `bs ` (a judge-visible name: stage 1 NOT_EQUAL) and located from the blank. Each component is trimmed, its offset
moved past the blanks, and the dotted text re-joined. A path holding an escaped identifier is left alone (its
terminating blank is part of the token). Case ws/w02 (STRICT_EQUAL); controls ws/w01 and ws/w03 (struct member
access: another branch, equal on both). The census finds no corpus row or probe case that reaches it.

## Census (the predictions) and the movers

The census (drivers/census.sh + tracewrap.sh) ran on the law binary BEFORE the law sweep, through the harness, with
the fence filter. It predicts **58 names**: 11 surelog row-modes, 4 uhdm2rtlil row-modes and 43 probe cases, each
listed with the laws that fired on it (evidence/predicted_movers.tsv; drivers/predict.py). Every branch of every law
traces (`parent=vp` / `parent=tp` / `refname`, the span half, the call-argument read, the S2 clone, the fold's `ref` and
`constts`, the dot trim).

Byte verifier (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law `/tmp/r11u167_swL` against pristine
`/tmp/r11u167_swP`, names of the same length):

| stage | paths | selfcheck | movers | predicted | unpredicted |
|---|---|---|---|---|---|
| surelog | 960 identical sets | 959/960 | 16 | 11 | **5: MiniAmiq d/t, SeqDriver t, SimpleUVM t** (the 4-line UINT/vpiDecompile coin: ordered = order-blind = 4 dump lines each) **and Scoreboard d** (the svunit list-order coin: 92 ordered lines, 0 order-blind) — evidence/uvm_coin_orderblind.txt |
| uhdm2rtlil | 1608 identical sets | 1607/1608 | 4 | 4 | 0 |
| probe (every database compared) | 4087 | — | 43 | 43 | 0 |

Every predicted corpus mover moved; every corpus mover was attributed record by record (drivers/moverdiff.sh,
evidence/corpus_movers_records.txt): **0 records enter on all 20 movers**. The 8 conversions and the 2 changes lose
their records (the laws quoted beside them above). Record-neutral: the five coin rows; FuncStructVal d/t
(§ evalFuncBodyRhsStampClone167: the elaborated copy's names now equal golden's name set, dump check in the evidence);
Rggen d and Scr1SvTests d/t (§ genProcFoldDeclTsScopeNamed167: the newly named references bring our count of
`...u_bit_field.WIDTH` names to golden's, 772 = 772 against pristine's 522, and `...SCR1_WIDTH` 4 = 4 against 2;
their strict walks diverge before those objects, evidence/neutral_movers_dumpdiff.txt).

## Gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `2a705713…` = main tree; law `a56d01df…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=29, changes=13; EQUAL 2626 STRICT_NOTEQUAL 1461, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 4 + 4; changes 2 + 0 (StructParamPatternInitCast d/t, counts down) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; not identical and not excused=0; downstream.csv byte-identical to the pristine sweep's; the two targeted uhdm2rtlil rows read IDENTICAL (quoted above) |
| (5) uhdm-cmp on touched rows | every mover keeps its judge-equal status (0 regressions in all three stages); every grid case keeps its uhdm-cmp verdict but ws/w02, which leaves stage 1 for STRICT_EQUAL (evidence/grid_pristine_vs_law.txt) |
| (6) byteverify | 16 + 4 corpus movers and 43 probe movers, all attributed; all but the five coin rows predicted by name |
| canaries | r11u107repro/canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 (pristine the same); ctcan2.sh EXPECT_UNKNOWN=1 surelog ok=58 changed=0 PASS, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2 changed=0 PASS (evidence/canaries_and_ds.txt) |
| cases | 56 cases (evidence/grid_pristine_vs_law.txt): 30 go to STRICT_EQUAL (one of them from stage 1), 4 are equal on both (controls), 22 stay (residues named above; 13 of them stage 1 on both), and no case loses judge-equality |
| switches | each switch alone returns its own cases to the pristine verdict (evidence/switches.txt) |
| `R11U167_OFF=1` | 1164 of 1164 cases (these 56 and the cases of r11u163/r11v163/r11u158/r11v158/r11u154/r11v154/r11u131/r11v131/r11u124/r11v124/r11u160/r11u120/r11v120) byte-identical to pristine (6 of them rejected by both: no database) (evidence/offbytes.txt) |
| byte controls | the law binary with every law on leaves all 1108 cases of those thirteen passes byte-identical to pristine (evidence/controls_lawbytes.txt) |

## Sister-ground faces (decoded; the fix sits in a file this pass does not own)

S1 — ibex_multdiv_fast d/t `endcol(26)`: 15 records are `$signed`/`$unsigned` sys_func_calls in the DEFINITION view of
a generate-scope continuous assignment (`gen_mult_fast`, `gen_mult_single_cycle`): golden spans the name only
(158:24-158:31) in every context (ExprEmit's `kNameOnlyFuncs` rule already does this for the elaborated view); the
definition-view generate block is emitted by TypeEmit.cpp emitSyntaxExpr, whose generic system-call branch sets
`setLoc(sfc, syn.sourceRange())` unless `inCastSize`. Grid evidence/residue/sg (s02 s04 endcol, s01 s03 s06 s10
equal; `$countones` keeps the whole call, s07). The other 11 records are generate-block enum constants (`ALBL` ...)
unlocated in ours, located at the enum in golden (not decoded further).

S2 — UnionCast d/t `value(26/28)`: an unsized decimal range bound written with leading zeros (`logic [11:00]`,
`[11:05]`) keeps its written digits in golden's VpiValue (`UINT:00`, `UINT:05`); ours `UINT:0`. gdb pin:
`MakeConstant` <- TypeEmit.cpp makeBoundConst <- makeTypespec (every range bound of a typespec); an
expression-position literal (`a + 007`, `a[05:02]`, `>> 03`) is canonical in golden and equal today (grid
evidence/residue/lz l01 l02 differ, l03-l05 equal). The union's `file(2)` face (N0430, buildUnionTs) was not reached.

S3 — HighLow d/t `value(1)`: ModuleEmit.cpp emitContAssigns, the elaborated `sysFold` of a range query onto an
IMPLICIT net (`assign ccc = $high(a);`): `sctx9.tryEval(ae.right())` evaluates the right side after slang's implicit
conversion to the one-bit net (0); golden keeps the query's own value (`UINT:2`, the constant carries no size): the
range-query branch should evaluate `stripImplicitConv(ae.right())`.

S4 — iface_param_port_width d/t `fullname(2)`: the port-view interface_inst's scalar param_assign Lhs is the
DEFINITION's parameter object in golden (`work@bus_if.DATA_WIDTH`; NetlistElaboration elab_parameters_
`inst_assign->Lhs(mod_assign->Lhs())`, the scalar half of the rule § ifacePortViewAggParamParent120 quotes); ours mints
`work@top.m0.bus.DATA_WIDTH`. Site: ModuleEmit.cpp emitInterfaceInstance, the `portView && !namedModportPortView9`
block.

S5 — a type parameter's anonymous struct named by a subroutine formal (grid rs/r20, probe r11v47 v28): golden relocates
the shared struct to the last formal's type token (5:53-5:57), the `localparam type` half of § modAggTfArgLastWriter155
(TypeEmit.cpp emitTypedefs covers typedefs only); § tpAnonStructCopySpanAtKeyword167 then gives the copies that span
for free. Both laws of this pass stay off there.

S6 — a net member-written through a type parameter's struct names its members through the net (rs/r12
`work@top.v.x`; pass-160 residue 4): the net typespec emission is TypeEmit's.

S7 — GenForStructParamBound d/t `fullname(7)`: the unpacked range bound path `[0:CFG.HSK.DLY]` carries a stored full
name (ours `work@bus_if.dly.CFG.HSK.DLY`, golden none) and the generate-for condition path is the definition view's
(TypeEmit emitSyntaxExpr, r11u157's R1 family).

## Decoded, not landed (ranked residues on this ground)

1. StructParamPatternInitCast d/t `fullname(3)` (grid rs/r11): the ELABORATED param_assign of `INT` holds the
   flattened pattern (an unparented reference, and members named through `INT` because its struct is the shared
   one) when `Cfg` is computed by a function call (`build_config(Base)`); with a package parameter default (rs/r10,
   StructParamFieldRange) the elaborated operation keeps its own named reference. The producer:
   CompileHelper::expandPatternAssignment returns the flattened operation for a struct type only when every member
   value reduces (`if (!invalidValue) result = rhs;`), else the original; which member values Surelog can reduce
   there (a struct parameter's field read through a function result versus through a pattern) is not decoded, and
   rs/r09 (an int parameter from a function) does not flatten, so the rule is narrower than "a function call".
   The probe cases r11u109repro/grid/f1/c01-c06 carry exactly this face after the laws (3 records each).
2. LocalScopeHierPath t `fullname(1)`: under `--elabuhdm` golden's foreach index `j` inside `path.slices[j].spath`
   carries no stored name (it computes `...::path.slices[j].spath::j` through the bit_select); the generated
   ref_obj/bit_select DeepClone copies every field (`*clone = *this`), so the drop happens elsewhere in the elaborator's
   re-binding; not decoded.
3. InterfArrayBind d `fullname(3)` (N0427): the elaborated view's continuous-assignment path `peripheral_io_bus[io_idx].write_en`
   names its index `<scope>.<path text>.<index>` in golden's DEFAULT mode (`work@soc_tb.io_gen[0].peripheral_io_bus[io_idx].write_en.io_idx`,
   the definition listing plain `work@soc_tb.IO_ONES`); ours plain in both views. The ExprEmit HierarchicalValue branch
   has no elaborated-view flag (ModuleEmit knows `topView`; the module-level definition and elaborated listings share
   the prefix), so the law needs a caller-side flag.
4. rs/r12: the net user's parent (S6).
5. rs/r20 / r11v47 v28: the subroutine relocation (S5).
6. gz/z07: a multi-dimensional declared type in a generate-scope fold shares the parameter's own typespec in golden
   (`work@top.Z.W`).
7. rs/r07 `endcol`: a folded pattern member `(W'(1) << (W - 1)) | W'(1)` spans its left operand in golden (7:28-7:46);
   ours the whole member expression.
8. rs/r22: an interface instance listing names its type_parameter by the definition (`work@bus_if.it_t`), ours by the
   instance.
9. The pass-163 residues not worked here (iface_zero_width_field, rl/q03, hc/g02, the verifier's shapes), r11u157's
   R2/R3/R6/R8/R9, gl/l4, ev/e16, hl/h3, ComplexHierPath, the generate-condition conditional, ma/e6.

**The based literal's inner space (brief 2).** The sister's column-model fold is not in HEAD at the start of this pass
(576b21fa: UhdmExporter.cpp `ppFold119Line` excludes the base->digits run), so the per-site subtractions stay. They
are, by function and expression: ExprEmit.cpp emitExpr — the IntegerLiteral branch (`spc = basedLiteralSpaceCount(raw)`,
which also compacts the constant's text), the size-cast fold (`sp83` on `cr83`, the folded constant's span), the
conversion operation's span (`sp9` on `opr9`), the tagged-pattern value span (`sp9` on `tpr9`), the assertion
instance span (`pir`); StmtEmit.cpp emitStmt — the expect statement and its property spec (`ex9`, `pr9`) and the
assert/assume/cover statement and its property spec (`as`, `pr`); ModuleEmit.cpp (sister's) three more. When the fold
lands, these subtractions drop together with it (only the IntegerLiteral branch's text compaction stays: it is the
literal's own text, not a column).

## Cases (first line of every case names its law; pristine / law verdicts in evidence/grid_pristine_vs_law.txt)

| grid | cases | law | pristine -> law |
|---|---|---|---|
| rs | r01 r02 r03 r05 r08 r09 r10 r15 r16 r17 r19 r21 | § tpAnonStructLastParamUser167 (+ span) | fullname -> STRICT_EQUAL |
| rs | r06 | § tpAnonStructCopySpanAtKeyword167 | endline -> STRICT_EQUAL |
| rs | r04 | § tpAnonStructLastParamUser167 (control: a typedef) | equal -> equal |
| rs | r20 | § tpAnonStructCopySpanAtKeyword167 (control: a subroutine formal; residue 5) | line -> line (bytes unchanged) |
| rs | r07 r11 r12 r22 | § tpAnonStructLastParamUser167 (records leave; residues 7, 1, 4, 8) | fullname -> endcol / fullname |
| rs | r13 r14 r18 r23 r24 r25 | § tpAnonStructLastParamUser167 (stage 1 on both) | NOT_EQUAL -> NOT_EQUAL |
| pc | c01 c02 c06 c09 | § pkgPatCallArgReadNoParent167 | fullname -> STRICT_EQUAL |
| pc | c07 c10 | § pkgPatCallArgReadNoParent167 (controls: dead branch, unqualified read) | unchanged records |
| pc | c03 c04 c05 c08 | § pkgPatCallArgReadNoParent167 (stage 1 on both) | NOT_EQUAL -> NOT_EQUAL |
| fs | f01 f02 f03 f06 | § evalFuncBodyRhsStampClone167 | fullname -> STRICT_EQUAL |
| fs | f04 f05 | § evalFuncBodyRhsStampClone167 (residues: another face / stage 1) | unchanged |
| gz | z01 z04 z05 z06 z08 z09 z10 z11 | § genProcFoldDeclTsScopeNamed167 | fullname -> STRICT_EQUAL |
| gz | z02 | § genProcFoldDeclTsScopeNamed167 (control) | equal -> equal |
| gz | z07 | § genProcFoldDeclTsScopeNamed167 (residue 6) | fullname -> fullname |
| gz | z03 z12 | § genProcFoldDeclTsScopeNamed167 (stage 1 on both) | NOT_EQUAL -> NOT_EQUAL |
| ws | w02 | § hpDotWsTrimmed167 | NOT_EQUAL -> STRICT_EQUAL |
| ws | w01 w03 | § hpDotWsTrimmed167 (controls) | equal -> equal |

Decode-only repros (not cases): evidence/residue/sg/*.sv.txt (S1), evidence/residue/lz/*.sv.txt (S2).

## Ops notes (disclosed)

* Twelve law binaries were built in turn (law1-law4 the type-parameter laws, law5 + the call-argument read, law6 + the
  generate-scope fold, law7/law8 the S2 clone (law7's first placement, in the stamp lambda, stamped the package
  typedef itself and was withdrawn), law9 the split span switch, law10 = lawF + the dot trim, lawG + the subroutine
  exclusion). Censuses ran on law9, law10 and lawG (the prediction); gate sweeps ran on lawF (evidence only: identical
  verdicts, one extra record-neutral probe mover, r11v47 v28, which lawG's subroutine exclusion removed) and on lawG
  (the gate). Every census and sweep reads regressions=0 against the baselines.
* The `-g1` pristine (`/tmp/r11u167_gsrc`, a `git archive` of the base) served gdb pins only: the generate-scope fold's
  typespec mint (`makeTypespec` <- ExprEmit emitExpr), the range-bound constants (`makeBoundConst`), the dotted path
  (`MakeHier_path` <- ExprEmit emitExpr <- ModuleEmit emitContAssigns).
* No process I did not start was touched.

## Files

* drivers/grid.sh (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), gridall.sh, recdiff.sh (a case's leaving and
  entering records), switches.sh, offbytes.sh (`R11U167_OFF` bytes), lawbytes.sh (all laws on, the byte controls).
* drivers/census.sh + tracewrap.sh (the firing census, fence-filtered), predict.py (the predicted mover set).
* drivers/rowrec.sh, allrec.sh, moverdiff.sh, srcgrep.sh (fence-guarded row and source readers), pdiff.sh (probe case
  record diff), mkstrictraw.sh (the raw-name comparator variant).
* evidence/: the files named above.
