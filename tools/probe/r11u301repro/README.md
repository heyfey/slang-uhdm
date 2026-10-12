# r11u301 — module/type ground: the elaborated continuous-assignment cell as Surelog's writeCont_assign clones, reduces and shares it; pure virtual prototypes as typedef writers and inline-aggregate spans

Base 5b58d3ee (pass 299). Twelve laws in ModuleEmit, UhdmExporter and TaskFuncEmit behind `src/R301.h`. Each law
reads its own `R11U301_<LAW>_OFF` switch. `R11U301_OFF` drops all of them and gives pristine's bytes and exit code on
370 of 370 grid case-views. `R11U301_TRACE=<dir>` logs the firings (one file per process, `OUT <-o path>` first, then
`<law> <detail>`).

**TWELVE PROBE CONVERSIONS**, no change, no regression. No corpus or downstream database moves in bytes (0 of 3365
fence-filtered databases), so no corpus row changes status or strict column.

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r10uvm99repro/g99_a2_proc | `differ:count(0)` | **EQUAL** | § caInsideRhsClonesCell301 |
| r10uvm99repro/g99_a9_fence | `differ:count(0)` | **EQUAL** | § caInsideRhsClonesCell301 |
| r10v62repro/v62e_bind | `differ:fullname(5)` | **EQUAL** | § caInsideRhsClonesCell301 |
| r10rgg9repro/cells/c_paraminit | `differ:type(1)` | **EQUAL** | § caSelLhsParamReuseAnyEnc301 |
| r10v111repro/v111_b6 | `differ:type(1)` | **EQUAL** | § caConstVarFoldNeedsReducibleInit301 |
| r10vrgg9repro/cells/v_takn_real | `differ:type(1)` | **EQUAL** | § caTernRealArmKept301 |
| r10vrgg9repro/cells/w_typeparam | `differ:type(1)` | **EQUAL** | § caTernTypeParamQueryNoFold301 |
| r10v92repro/v4_arm | `differ:type(1)` | **EQUAL** | § caTernParamArmReusesPaConst301 |
| r11u109repro/grid/f1/p03_ready | `differ:type(1)` | **EQUAL** | § caStructSetterCastMemberWidthNoFold301 |
| r11u90repro/grid.verifier/vy5_dlyparamovrmod | `differ:type(1)` | **EQUAL** | § caDlyParamLitRhsFresh301 |
| r11u88repro/grid/a6_commadrive | `differ:col(2)` | **EQUAL** | § ifCaConstDelayPerCell301 |
| v11u112repro/grid/brk/k/b3a_multi_decl | `differ:decompile(1)` | **EQUAL** | § caFillPackedAggElabSharesDef301 |
| probe | EQUAL 3962 + STRICT_NOTEQUAL 125 | **EQUAL 3974 + STRICT_NOTEQUAL 113** | regressions 0, conversions 12, changes 0 |
| surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

Fresh law-sweep probe rows (evidence/sweep_L.txt): every one of the twelve reads `<case>,EQUAL,,equal`, e.g.
`r10uvm99repro/g99_a2_proc,EQUAL,,equal`, `r10v62repro/v62e_bind,EQUAL,,equal`,
`v11u112repro/grid/brk/k/b3a_multi_decl,EQUAL,,equal`.

The two pass-299 residues the brief named first are written too (§ unitTdPureProtoFormalWriter301 and
§ pureProtoInlineAggSpans301): v11u299repro VU/vu01, vu14, VP/vp08 and VR/vr08 enter STRICT_EQUAL in both views (byte
controls below); no gate probe case carries those shapes.

## The decode shared by the ten ModuleEmit laws: UhdmWriter::writeCont_assign

`UhdmWriter::writeCont_assign` (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp) writes every elaborated
continuous assignment from the definition's cell:

1. a delay that is a name (`#D`) clones the whole cell first (`clone_tree`, its Rhs constant included);
2. a plain-name Lhs bound by `bindVariable` with an Rhs that is an **operation** (any `operation`, `vpiInsideOp`
   included) clones the cell, re-points the Lhs at the instance's variable and reduces the Rhs;
3. otherwise the Rhs is reduced in the trailing `simplified == false` branch; a constant result clones the cell (when not
   cloned yet) and calls `CompileHelper::adjustSize(tps, ...)` with the Lhs's typespec. `adjustSize` returns its
   argument untouched when `tps` is null (a select Lhs carries none) and clones only a UINT, an unsized or a signed
   binary constant under `uniquify`, mutating every other encoding in place: the reduced value, often the parameter's
   OWN value object, becomes the cell's Rhs.

Our elaborated view shares the definition's cell unless one of these routes fires; each law below adds a route the
emitter missed. "Golden lists no Rhs" means the cell's Rhs is an object the walk had already listed (UHDM's
VpiListener lists an object's children once per section).

## Laws

**§ caInsideRhsClonesCell301** (`R11U301_CAINSIDE_OFF`, ModuleEmit emitContAssigns). An `inside` Rhs is a UHDM
operation, so route 2 clones the cell for a plain-name Lhs; `containsOperation` (EmitHelpers.h, sister file, not
edited) does not list `ExpressionKind::Inside`, so ours shared the definition's cell and its Lhs kept the
definition's net (g99_a2/a9 `count(0)`: the definition's `logic_net` listed once more; v62e_bind: the inside-set
reference names). The law clones exactly where the share branch would have shared, and stands aside when the whole
`inside` is constant (golden folds it; grid CI c05 read chain away 4 under a draft, residue). The net-declaration twin
is § ndaConstRhsFreshLhs271's `inside` branch.

**§ caSelLhsParamReuseAnyEnc301** (`R11U301_SELPARAMREUSE_OFF`, ModuleEmit, at § elabCaReusesParamValueConst's gate).
A select Lhs (`arr[0] = Z`, `v[3:0] = Z`, `v[2 +: 4] = Z`) has no typespec, so adjustSize returns the parameter's own
value object whatever its encoding: the elaborated cell's Rhs is the instance's param_assign constant for UINT and
unsized values too, and its size is not adjusted (grid SP s04: `v[3:0] = Z` keeps 32).

**§ caConstVarFoldNeedsReducibleInit301** (`R11U301_CONSTVARINIT_OFF`, ModuleEmit). The fold of a read of a
constant-initialized, never-written integer variable (constVarRhs) stands aside when the initializer calls a
function (package, module or class static; slang evaluates them, Surelog's reduce does not) or when the read is
package-qualified (`p::w`): golden keeps the written reference (v111_b6 `ref_obj w_v6`, ours folded `UINT:6`).

**§ caTernRealArmKept301** (`R11U301_TERNREAL_OFF`, ModuleEmit, § srlgCondOpInstValueTernFold9's select-Lhs fold).
A real literal branch the constant condition selects is installed (`REAL:1.5` at the branch's span), shared across instances
as the netlist's own object like § caTernFillArmKept193's fill branch (grid TF r04).

**§ caTernTypeParamQueryNoFold301** (`R11U301_TERNTPQUERY_OFF`, same site). A system query on a type parameter
(`$bits(T)`, in an branch or the condition) is not evaluable by the elaborated reduce: golden keeps the written ternary
(w_typeparam), ours folded `INT:16`.

**§ caTernParamArmReusesPaConst301** (`R11U301_TERNPARAMARM_OFF`, ModuleEmit, § elabCaTernaryArmInstall92's
plain-Lhs fold). A selected branch that is a bare module parameter whose value carries x or z bits (`EN ? XV : 4'h0`)
reduces to the parameter's own value object, mutated in place by adjustSize (sized, unsigned, based): the cell's Rhs is
the instance's param_assign constant. Only a constant already at the target width and an unsigned target (grid TP
a06, a10 residues).

**§ caStructSetterCastMemberWidthNoFold301** (`R11U301_SETCASTW_OFF`, ModuleEmit caStructParamSetter55). A struct
parameter member whose setter is a size cast with a struct-member width (`y: Cfg.XLEN'(2)`; slang parses the width as
a ScopedName with a `.` separator) is not reduced: golden keeps `hier_path I.y` (p03_ready). A parameter or literal
width folds as before (grid SC c02, c03, c11 controls).

**§ caDlyParamLitRhsFresh301** (`R11U301_DLYLITFRESH_OFF`, ModuleEmit literal-share site). Route 1: a cell with a
parameter-name delay was cloned whole before the reduce, so each instance owns a copy of a sized literal Rhs (vy5:
golden lists `32'd10` under u_a and u_b, ours shared the definition's object).

**§ ifCaConstDelayPerCell301** (`R11U301_IFDLYCONST_OFF`, ModuleEmit interface cell re-list). A constant delay is part
of the cloned cell: every elaborated interface cell carries its own copy (a6_commadrive `assign #4 p = .., q = ..;`).

**§ caFillPackedAggElabSharesDef301** (`R11U301_FILLAGGELAB_OFF`, ModuleEmit unbased-fill fold). On the declarations
§ caUnbasedFillPackedAggregateKeepsRaw43 names (packed dimensions written on a named struct, union or enum element),
adjustSize gets no typespec it can size, so the elaborated cell carries the definition's `'1` constant (BIN:1, size
-1), exactly as § initHierFillKept225 does: pass 43's open '1 residue, the elaborated site it did not find.

**§ unitTdPureProtoFormalWriter301** (`R11U301_PUREPROTO_OFF`, UhdmExporter scanCls299). A pure virtual prototype's
formal writes the `$unit` struct or union typedef (CompileClass compiles it through compileFunction): golden vu01 s_t
4:31, vu14 u_t 4:32. The struct/union half of § unitTdClassFormalWriter299 poisoned on `MethodFlags::Pure`. An
INTERFACE class's prototypes stay non-writers (grid PV v08: golden keeps the declaration, chain away 4 under a draft);
a DPI import stays a non-writer.

**§ pureProtoInlineAggSpans301** (`R11U301_PUREAGG_OFF`, TaskFuncEmit pure-virtual prototype branch). The pure virtual
twins of § inlineAggFormalTypeSpan299 (the formal spans the whole written type after a direction keyword, the
keyword alone without one) and § inlineAggReturnVarSpan299 (an inline packed struct or union return with packed
dimensions spans its return variable over the type): vp08 3:45-3:86, vr08 3:25-3:66.

## Grid (cases/; drivers/grid.sh, every line with its exit code; evidence/grid.txt, grid_summary.txt)

185 case dirs in both views, 370 case-views: CI 28 (§ caInsideRhsClonesCell301), SP 24 (§ caSelLhsParamReuseAnyEnc301),
CV 21 (§ caConstVarFoldNeedsReducibleInit301), TF 16 (r* § caTernRealArmKept301, t* § caTernTypeParamQueryNoFold301),
TP 12 (§ caTernParamArmReusesPaConst301), SC 12 (§ caStructSetterCastMemberWidthNoFold301), DL 19 (d* § caDlyParamLitRhsFresh301,
i* § ifCaConstDelayPerCell301), FP 19 (§ caFillPackedAggElabSharesDef301), PV 18 (§ unitTdPureProtoFormalWriter301),
PA 16 (§ pureProtoInlineAggSpans301). Each case names its law in its first line. Configurations P, L, OFF and the law
with each of the twelve switches off.

- 246 case-views moving, **198 entering STRICT_EQUAL, 0 leaving**, 0 exit-code changes (every line rc=0), OFF equal
  to P in bytes on 370 of 370.
- Every mover restored by exactly one switch: CAINSIDE 36, SELPARAMREUSE 30, PUREPROTO 30, CONSTVARINIT 28, PUREAGG 26,
  FILLAGGELAB 22, SETCASTW 16, TERNPARAMARM 16, DLYLITFRESH 12, TERNREAL 12, TERNTPQUERY 10, IFDLYCONST 8.
- Away census (drivers/awaycv.sh, order-blind and chain-keyed) on all 246 movers: lost 0 and chain away 0 on every one,
  670 records toward golden (evidence/grid_away.txt). Positive control (binaries swapped) on 11 sampled movers: away
  or distance growth on 10 of 11 (CI/c21 is a stage-1 identity-only mover; evidence/grid_away_poscontrol.txt).
- Movers that stay at uhdm-cmp stage 1 keep their line counts except SC/c08_iface_el (109 -> 60, toward 34, away 0);
  CI/c12_bind default moves fullname -> depth (2 toward, 0 away).
- Two refinements made before delivery from the grid's away census: § caInsideRhsClonesCell301 abstains on a constant
  `inside` (CI c05 had read chain away 4/5) and § unitTdPureProtoFormalWriter301 leaves interface classes alone (PV
  v08 had read chain away 4/3). Both cases are now unmoved.
- Downstream (drivers/dscases.py, both binaries, 185 dirs; evidence/downstream_cases.txt): no verdict worse; 6
  EQUIVALENT -> IDENTICAL (CV/c17, TF/t01, t02, t06, t08, t09); 168 IDENTICAL, 8 EQUIVALENT and 3 DIVERGENT
  (FP/p13, p18, p24) on both binaries.
- Dropped as illegal SV (slang exits 3 on both binaries): a variable-index unpacked element in a continuous assign and
  a string parameter onto a packed array.

## Gates (worktree at 5b58d3ee, SLANG_UHDM exported per binary)

- Builds: pristine md5 5c3e79f4 (equal to the main tree's build/slang-uhdm), law e0fa57a0; both frozen read-only before
  any measurement; slang 12.0.0+545f88b2e.
- Firing census frozen before the law sweep (drivers/tracecensus.sh over the probe and both corpora in both modes,
  fence-filtered; evidence/predict.txt): 37 probe databases, 0 corpus row-modes. Probe byte movers in the sweeps:
  exactly those 37 (12 conversions; 25 EQUAL on both binaries: r11u116 f1 *_ms ×10, r11u88 a1, z4, r11u90 w4, w11,
  w13, w14, vy1, vy4, vy6, vy7, vy8, vy10, vy12, vy15, r11v83 b14). Away census on all 37: lost 0, chain away 0, toward
  47 (evidence/probe_movers_away.txt).
- Law sweep `tests/sweep.sh --jobs 3` (evidence/sweep_L.txt; pristine sweep_P.txt): probe EQUAL 3974 +
  STRICT_NOTEQUAL 113, regressions 0, conversions 12, changes 0; surelog default 480 + 0, testflags 474 + 0, 0/0/0;
  uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0, the csv
  identical to the pristine sweep's and to results/downstream_uhdm2rtlil.csv. Both sweeps exit 1 on the law-index
  check alone (tests/LAWS.md regenerated in the patch).
- Strict column, whole csvs row by row against the pristine sweep: surelog differs only in the LowMemLib / LowMemPkg
  testflags detail text (the workdir path); uhdm2rtlil 0 rows; probe the twelve rows above.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors of the two
  same-length workdirs: 0 of 3365 corpus and downstream databases move (SELFCHECK 3363 of 3365, the known twin;
  evidence/byteverify_corpus.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
- Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 run no slang
  (evidence/binary_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode on the law binary): Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and every testflags row-mode with a database read one
  hash each, equal to the law sweep's (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` before any case is opened; evidence/controls*):
  40 earlier repro dirs (r10rgg9, r10vrgg9, r11u90, r11v90, r11u88, r11v88, r11u85, r11u139netbind, r11u171, r11u193,
  r11u225, r11u271, v11u271, r11u289, v11u289, r11u164, r11u19, r11u299, v11u299, r11u155, r11u55, r11u56, r11v56,
  r11u68, r11u69, r11v69, r11u279, r11u287, r11u118, r11v11u118, r11u119, r11u120, r11u124, r11u131, r11u83, r11v83,
  r11u22, r11u23, r11u109, r11u112): 1904 case dirs, 3808 case-views, 30 moving, **10 entering STRICT_EQUAL**
  (v11u299repro VU/vu01_purevirt_mod, vu14_union_purevirt_only, VP/vp08_purevirt, VR/vr08_purevirt and r11u85repro
  a6_commadrive, all in both views), 0 leaving, 0 exit-code or uhdm-cmp line-count changes; the other 20 (r11u85,
  r11u88, r11v83 interface delay cells, r11u90 w10, w16) stay at their verdicts; lost 0 and chain away 0 on all 30.

## Residues (ranked; all wrong on pristine too)

1. **Interface-body cells.** The interface re-list (§ caIfaceBodyCaFolds83's loop) has none of the module folds:
   probe r10rgg9repro/cells/c_iface_body (`arr[0] = (P) ? {2{sig}} : '0`, golden the `'0` branch) and the select-Lhs
   parameter read (SP s11, golden reuses the param_assign constant), CI c10 (an interface `inside`), CV c18, FP p26.
   ModuleEmit, the interface twin of § srlgCondOpInstValueTernFold9 and of the two reuse laws.
2. **Generate-scope cells** (emitGenScopes): CI c11 and c25, FP p27 at stage 1 on both binaries.
3. A constant `inside` (CI c05: golden folds the whole set test; not transcribed), a `$unit` variable (CV c20) and an
   initializer with a nested call (CV c12) at stage 1; a parameter X branch onto a wider or signed target (TP a06, a10:
   adjustSize resizes in place); a parenthesised parameter delay `#(D)` (DL d06, i04) and a rise/fall delay list
   (DL i09, an operation delay); a union or `var`/`wire` packed-aggregate fill (FP p13, p17, p18) and a named logic
   element (FP p24, golden the element-width face).
4. Pure virtual leftovers: an interface class formal for an enum (pass 299's vu15), a pure prototype beside an extern
   (PV v13, stage 1, moved toward golden), the `struct packed signed` formal and return (PA a14, pass 299's p12).
5. The rest of the 113 probe residues on this ground stand as pass 299's README lists them (t42a, vxpkg8, the
   type-parameter element full names e18, b18, b21, i16, the q2::row_t chains x36, x40, y31, b07, g149/homes,
   vb4_instarr, grid2/vA, pb19_modportview), plus r10earl53repro/v2_v53 (a `wire pkg::T name;` moving the package
   struct typedef's end to the type name; decoded from golden, not written) and r10uvm220 a1_uninst_if.

Sister-ground faces (reported, not written): r11v77repro/grid/vh_arrelem (a package array variable's enum typedef end;
ParamEmit's package listing), r10earl115 p1_pos115, r10earl121 a1_axis121, r10earl31 v4_ops, r11v66 a3_inst66,
k11_logic_param_range and c9_litarith_noovr (folded-constant spans; ExprEmit or ParamEmit), r11u117 t12, the struct-fold
member names (m4, m7, a2, n11, v15; ParamEmit), the package struct typedef stretch (b3, n4; ParamEmit), t9 and n1, the
package-function call folds (v3_clone13, v9fold8, a1, va8, a9_class_holder; ExprEmit or ParamEmit), the type-parameter
anonymous struct parents (g2, g10, g12, v12, v28; ParamEmit § tpAnonStructLastParamUser167) and the r11u109 64-bit
cast values (c04, c06, p06, p07).

## Process

Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh);
every corpus path list was filtered before any file was opened; no fenced name is spelled. No other agent's process
was listed or signalled; the main tree was not written. **The implementer's slips, no effect on any number:** a first
law sweep was started on a draft binary before the grid's away census found the two breaks above; it was stopped by
its own task id, its workdir and census deleted, and the census, grid, sweep and controls were all rerun on the
refined binary e0fa57a0. A second census launch ran in a shell without drivers/env.sh and exited 2 (FENCED unset) on
its fail-closed check before reading anything; it was rerun correctly. Superseded draft binaries ran only the grid and
an exploratory probe check.

Files: cases/{CI,SP,CV,TF,TP,SC,DL,FP,PV,PA}, drivers/ (copied from r11u299repro; grid.sh's switch list and
gridsum301.py renamed for this pass), evidence/.
