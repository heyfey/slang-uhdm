# r11u299 — module/type ground: subroutine-formal writers of a typedef's shared object (class methods compile after the modules; the module enum's elaborated parameter copies), inline-aggregate formal and return spans, the non-ANSI type-parameter port variable

Base 11701850 (pass 297). Five laws (the first in two halves) in UhdmExporter, TaskFuncEmit and ModuleEmit behind
`src/R299.h`. Each law reads its own `R11U299_<LAW>_OFF` switch. `R11U299_OFF` drops all of them and gives pristine's
bytes and exit code on 154 of 154 grid case-views. `R11U299_TRACE=<dir>` logs every firing that writes (one file per
process, `OUT <-o path>` first, then `<law> <detail>`).

**THREE PROBE CONVERSIONS AND ONE CHANGE**, no regression. No corpus or downstream database moves in bytes (0 of 3365
fence-filtered databases), so no corpus row changes status or strict column.

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r10uvm56repro/a6_type | `differ:line(9)` | **EQUAL** | § unitTdClassFormalWriter299 |
| v11u93b107repro/brk/p18_func_arg | `differ:endcol(4)` | **EQUAL** | § inlineAggFormalTypeSpan299 |
| r11u110repro/grid/e1/e22_nonansi | `differ:line(1)` | **EQUAL** | § nonAnsiTpVarAtHeader299 |
| r10v62repro/v62e_bind | `differ:line(7)` | `differ:fullname(5)` (CHANGE: the two line records #499 / #510 cleared, toward 6, lost 0, chain away 0; the next first record #767 is the one pristine also reads, the inside-set reference names, sister ground) | § modEnumTfArgCloneFollows299 |
| probe | EQUAL 3954 + STRICT_NOTEQUAL 133 | **EQUAL 3957 + STRICT_NOTEQUAL 130** | regressions 0, conversions 3, changes 1 |
| surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

Fresh law-sweep probe rows: `r10uvm56repro/a6_type,EQUAL,,equal`, `r11u110repro/grid/e1/e22_nonansi,EQUAL,,equal`,
`v11u93b107repro/brk/p18_func_arg,EQUAL,,equal`, `r10v62repro/v62e_bind,STRICT_NOTEQUAL,differ:fullname(5),differ:fullname(5)`.

## The decode shared by laws 1 and 2: Surelog's formal writer

`CompileHelper::compileTfPortList` (third_party/Surelog/src/DesignCompile/CompileStmt.cpp) compiles each ANSI formal's
type and runs `fC->populateCoreMembers(type, type, ts)` on what `compileTypespec` returns. `type` is the child of the
node it reads as the data type: with a direction keyword (`input`, `output`, `ref`, ...) that node is the whole
`Data_type` (dimensions included); with none it is the first token of the type (the § tfArgQualOutsideWriter176 reading
of the same node). For a typedef name `compileDatastructureTypespec` (CompileType.cpp) returns the typedef's own object
for an enum, struct or union (`TypeDef::getTypespec`, no clone), so the shared object takes the span of the last formal
compiled. `CompileDesign::compilation_` compiles packages, file contents, modules (name order), programs, and only then
the class map (`compileMT_` over `getClassDefinitions`, keyed `work@<class>` for a `$unit` class and
`work@<module>::<class>` for a class a module declares, compiled in key order).

## Law 1 — § unitTdClassFormalWriter299 (switch `R11U299_UNITCLSFORMAL_OFF`, UhdmExporter)

**The face.** a6_type: `typedef struct packed {...} s6_t;` at `$unit`, written by `c6::y_struct(s6_t y)` (24:27) and by
the module's `z_struct(s6_t y)` (47:27). Golden reads 24:27-24:31 on all 9 holders; ours read the declaration 4:9-7:2
because § unitAggTfArgLastWriter155 declined any class writer, and § tfArgTypedefLastWriter146 declined the enum when its
writers sit in several containers.

**The law.** A formal of a class method (a `$unit` class or a class a module declares, a nested class's under its
outermost class's key, a constructor's, an `extern` prototype's) writes the `$unit` typedef like any other formal, and
the last class writer by (class key, source order) wins over every subroutine writer. Struct and union half: in
`lastFormalTok155`; enum half: `unitEnumClsWriter299` in the § tfArgTypedefLastWriter146 order chain, only where the
container check declines (one container keeps the landed rule). An out-of-body definition's formal is not a winner (u06,
u28, u29, u30: golden reads the prototype); a pure virtual, a DPI import or a spelling other than the bare name declines.

## Law 2 — § modEnumTfArgCloneFollows299 (switch `R11U299_MODENUMCLONE_OFF`, UhdmExporter, design-final)

**The face.** v62e_bind: a module enum `b_e` written by `fb(input b_e q)` and `tb(input b_e q, ...)`; § 146 moves the
module's listing to 28:27 as golden does, but the elaborated parameters `u_a.LP` / `PP` keep their own copies at the
declaration 11:3-11:47 where golden reads 28:27-28:30.

**The law.** The enum twin of § modAggTfArgCloneFollows180: Surelog moves the shared object at compile time, before
elaboration, and the elaborated parameter typespec it clones afterwards copies the moved span. After the § 146 apply,
every enum_typespec of the typedef's name still at its declaration span (file included) whose nearest non-typespec
ancestor is a parameter under an instance of the typedef's own definition takes the moved span and file.

## Law 3 — § inlineAggFormalTypeSpan299 (switch `R11U299_INLAGGFORMAL_OFF`, TaskFuncEmit)

**The face.** p18_func_arg: `function automatic logic [3:0] f(input struct packed {...} [1:0] v)`: golden's
packed_array_typespec 2:42-2:83 (`struct` through `[1:0]`), ours 2:42-2:55 (`struct packed`), on the io_decl and the call
argument, both views (4 records).

**The law.** A formal written with an inline struct or union type (with or without packed dimensions) binds a typespec
spanning the whole written type when a direction keyword precedes it, and the `struct` / `union` keyword alone when none
does (p13, p25: golden 3:36-3:42).

## Law 4 — § inlineAggReturnVarSpan299 (switch `R11U299_INLAGGRET_OFF`, TaskFuncEmit)

**The face.** `function automatic struct packed {...} [1:0] f(...)`: golden's return logic_var 3:22-3:63, ours 3:22-3:35.
**The law.** compileVariable's `populateCoreMembers(declarationId, declarationId, result)` on the Data_type node (the
§ tfSigningSpanFollowsCompilePath200 decode): an inline packed struct or union return type with packed dimensions spans
its return variable over the whole type. No probe case carries the shape; grid RF only.

## Law 5 — § nonAnsiTpVarAtHeader299 (switch `R11U299_NATPVARHDR_OFF`, ModuleEmit)

**The face.** e22_nonansi: `module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (rt_i,
sel_o); input rt_t rt_i;` — the elaborated packed_array_var `work@dut.u.rt_i`: golden 1:81-1:85 (the port-list name),
ours 2:14-2:18 (the body declaration).
**The law.** The variable § namedTypePackedDimElabVar32's factory builds for a port is located at the port-list name
(`setLocNamed(v, *it.port)`, as the makeVar road below it already does), unless the port has a separate body
redeclaration. An ANSI port is unchanged (its name is the declaration).

## Grid (tools/probe/r11u299repro/cases; drivers/grid.sh, every line with its exit code)

77 case dirs in both views, 154 case-views: UC (30, law 1), PF (25, law 3; p07 law 4), RF (7, law 4), NA (7, law 5),
ME (8, law 2). Configurations P (pristine), L (law), OFF (law + `R11U299_OFF`) and the law with each switch off
(evidence/grid.txt, grid_summary.txt).

- 122 case-views moving, **108 entering STRICT_EQUAL, 0 leaving**, 0 exit-code changes, OFF equal to P in bytes and
  exit code on 154 of 154.
- Every mover restored by exactly one switch: UNITCLSFORMAL 58, INLAGGFORMAL 36, INLAGGRET 12, MODENUMCLONE 10,
  NATPVARHDR 6.
- Away census (drivers/awaycv.sh: order-blind away.py and chain-keyed awaychain.py) on all 122 movers: lost 0 and chain
  away 0 on every one, 640 records toward golden; positive control (binaries swapped) away 1 to 10 on 8 of 8
  (evidence/grid_away.txt, grid_away_poscontrol.txt). The movers staying at uhdm-cmp stage 1 (u06, u10, u28, u29, u30,
  p10) keep their uhdm-cmp line counts; their moved spans are golden's (u06 4:25, u28 4:25, u29 5:18, u30 5:25, u10 4:18,
  p10 3:42-3:83).
- Downstream (drivers/dscases.py, both binaries, 77 dirs): no verdict changes (75 IDENTICAL, p12 DIVERGENT and p04
  SURELOG_FAIL on both binaries; evidence/downstream_cases.txt).

| case (law named in its first line) | P default / elab | L default / elab |
|---|---|---|
| UC/u01..u05, u07..u09, u11, u13..u18, u21..u26 (§ unitTdClassFormalWriter299: class before / after the module, enum, two classes in key order, union, class only, two methods, module class, program, header, task before function, `$unit` class against a module class both ways, constructor, two modules, `$unit` function, nested classes) | line / line | EQUAL / EQUAL |
| UC/u12_enum_cls_only (same; one container, landed rule) | EQUAL | unmoved |
| UC/u06_extern_proto, u28_enum_extern, u29_extern_then_inbody, u30_inbody_then_extern (same) | stage 1 | stage 1, spans moved to golden's |
| UC/u10_mod_signal (same) | stage 1 | stage 1, span moved to golden's 4:18 |
| UC/u27_hdr_samepos (same) | line | file (see residue 3) |
| PF/p01..p03, p09, p11, p13..p17, p19, p21..p26 (§ inlineAggFormalTypeSpan299: function, task, union, class method, two dims, no direction, no dims, multi-line, interface, `$unit`, two ports, default, ref, output, union no dims, second port without direction, macro) | endcol / endcol | EQUAL / EQUAL |
| PF/p07_func_ret (§ inlineAggReturnVarSpan299) | endcol | EQUAL |
| PF/p10_pkg_func (same as p01) | stage 1 | stage 1, span moved to golden's |
| PF/p04 (Surelog fails), p05, p12 (stage 1, other faces), p06, p08, p18 (controls) | | unmoved |
| RF/r01, r03..r06 (§ inlineAggReturnVarSpan299: module, union, class, `$unit`, multi-line) | endcol | EQUAL |
| RF/r02_ret_nodim (stage 1), r07_ret_vec_ctl (control) | | unmoved |
| NA/n01, n04, n06 (§ nonAnsiTpVarAtHeader299: override, default, output) | line / line | EQUAL / EQUAL |
| NA/n02, n03, n07 (controls), n05 (stage 1) | | unmoved |
| ME/e01, e02, e04, e05, e08 (§ modEnumTfArgCloneFollows299: one instance, three specializations, task, two instances, override) | line / line | EQUAL / EQUAL |
| ME/e03, e06, e07 (controls) | EQUAL | unmoved |

## Gates (worktree at 11701850, SLANG_UHDM exported per binary)

- Builds: pristine md5 5169a64e (equal to the main tree's build/slang-uhdm), law 0bd15001; both frozen read-only
  before any measurement; the binary reports slang 12.0.0+545f88b2e.
- Firing census frozen before the law sweep (drivers/tracecensus.sh, R11U299_TRACE over the probe and both corpora in
  both modes, fence-filtered; evidence/predict.txt): exactly 4 probe databases (the four targets), 0 corpus row-modes.
- Law sweep `tests/sweep.sh --jobs 3` (evidence/sweep_L.txt; pristine sweep_P.txt): probe EQUAL 3957 + STRICT_NOTEQUAL
  130, regressions 0, conversions 3, changes 1 (above); surelog default 480 + 0, testflags 474 + 0, regressions 0
  conversions 0 changes 0; uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT
  2, DIVERGENT 0, the csv identical to the pristine sweep's and to results/downstream_uhdm2rtlil.csv. Every sweep exited
  1 on the law-index check alone (tests/LAWS.md regenerated in the patch).
- Strict column, the whole csvs row by row against the pristine sweep: surelog differs only in the LowMemLib / LowMemPkg
  testflags detail text (the workdir path); uhdm2rtlil 0 rows; probe the four rows above.
- uhdm-cmp 0 lines on every touched probe case in both binaries.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors of the two
  same-length workdirs: 0 of 3365 corpus and downstream databases move (SELFCHECK 3363 of 3365, the known twin);
  probe exactly the 4 predicted of 4087 (evidence/byteverify_*.txt). The away census on them: lost 0, chain away 0,
  toward 9, 6, 1 and 4; positive control away 9 and 6 (evidence/probe_movers_away.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
- Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 run no slang
  (evidence/binary_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode on the law binary): Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and every testflags row-mode with a database read one
  hash each, equal to the law sweep's (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` before any case is opened) over 28 earlier repro
  dirs (r11u146, v11u146, r11u153verify, r11u155, r11u176, r11u175uvm, r11u180, v11u180, r11u191dec, r11u216, v11u216,
  r11u223, r11u231, r11u279, v11u279, r11u152, r11u108, r11u110, v11u110, r11u297, v11u297, r11u118, r11u119, r11u120,
  r11u124, r11u131, r11u172rp, r11u277): 2058 case dirs, 4116 case-views, 6 moving, 2 entering STRICT_EQUAL
  (r11u152repro/cases/TP/t08_nonansi in both views, law 5), 0 leaving, 0 exit-code changes; r11u231repro AL/a10 and
  TI/t05 in both views (a `$unit` enum alias with an extern prototype, law 1's enum half) stay at stage 1 with their
  uhdm-cmp line counts, toward 2 and away 0; lost 0 and chain away 0 on all 6 (evidence/controls*.txt).

## Residues (ranked; all wrong on pristine too)

1. **r10uvm32repro/t42a `differ:line(29)` — a package enum written by its own package and by importer packages.**
   Decoded from golden, not written: the definition listing reads the last inside writer (21:29), every importer's
   listing and formal the last outside writer in package compile order (43:29); the importer clones of the home
   package's own subroutine `a_use` read the outside object's span at the importer's compile, the definition-view clone
   AFTER the importer's own writers (pb42 28:29, pc42 28:29, pd42 43:29) and the elaborated-view clone BEFORE them (pb42
   21:29, pc42 28:29, pd42 28:29). § tfArgDefTopSplit176 declines outside writers in two containers. UhdmExporter
   (§ 146's order chain); needs the per-importer clone objects identified first.
2. r10buvm8repro/vxpkg8 `line(7)`: a package VECTOR typedef written qualified (`zp::zb_t`) by another package's formals;
   golden moves the elaborated object to the last qualified writer's `zp::` token and the formal binds it with no alias
   (walk diverges at #143); § tfArgScalarTdWriter223 skips `::` spellings. Not attempted.
3. UC/u27_hdr_samepos: the class writer's token in a header shares its line and column with a module writer's token in
   dut.sv; § tdMoveCarriesFile172 picks the last writer in syntax order (dut.sv) where Surelog's last writer is the
   class (h.svh). TypeEmit, a refinement of § 172.
4. The extern-prototype cases (u06, u28, u29, u30) and u10 stay at stage 1 for faces outside this law; p12 (`struct
   packed signed` formal) stage 1 and DIVERGENT downstream on both binaries; r02 (inline struct return without
   dimensions) stage 1; n05 (`input id_t [3:0] rt_i;` with a module typedef) stage 1.
5. The rest of the 130 probe residues by first record (classified on the base databases; drivers/recpath.py): the
   type-parameter element full names (e18_chain_rt, b18_var_kw, b21_always_ff, i16_var_kw_init: our element ref_typespec
   stores `...rt_t.id_t` where golden stores none or reaches a per-variable copy; UhdmExporter rebindTypeParamElem107's
   ground), the q2::row_t alias chains (x36, x40, y31), b07_param_typedef_arr (golden leaves the type parameter's
   typedef-of-typedef unlocated), g149/homes (anonymous unpacked struct end at its first member's `;`), v28 and the
   type-parameter struct parents (g2, g10, g12, v12, k14, t13; ParamEmit tpAnonStructLastParamUser167, sister), the
   ordered type overrides Surelog ignores (y64, y65, x64; report only), the positional modport actual (grid2, vA), and
   the residues pass 297's README lists.

Sister-ground faces (reported, not written): r10v62repro/v62e_bind's next record #767 (`hier_path bv.op` inside an
inside set named `work@be62.op` where golden names `work@top62e.u_a.op`; ExprEmit), the struct-fold member names (m4,
m7, a2, n11, v15; ParamEmit), the package struct typedef stretch (b3, n4; ParamEmit), the folded-constant end columns
(p1_pos115, a1_axis121, v4_ops, c9_litarith_noovr, a3_inst66, k11_logic_param_range; ExprEmit or ParamEmit), t9 and
n1 (the `CFG` reference of a member select in an elaborated param_assign located at the member; ParamEmit).

## Process

Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh); every
corpus path list was filtered before any file was opened; the fenced names are never spelled. No other agent's process
was listed or signalled (one own background census was stopped by its own task id when the law changed, and rerun on
the final binary before the law sweep). The main tree was not written. Superseded binaries law1 to law6 (the drafts
before the extern-prototype refinement of law 1 and the write-only traces) ran only the grid; the census, grid,
controls, sweeps and determinism ran on the final law binary.

Files: cases/{UC,PF,RF,NA,ME}, drivers/ (copied from r11u297repro; grid.sh, tracecensus.sh switched to R11U299;
gridsum299.py new), evidence/.
