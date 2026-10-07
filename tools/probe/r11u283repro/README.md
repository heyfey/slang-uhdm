# r11u283 — module/type ground: the probe residue by writer (program and interface process sharing, bound-instance display names, generate comma lists, scoped class returns)

Base fa9bf4a9 (pass 281). Seven laws in ModuleEmit and TaskFuncEmit behind `src/R283.h`: each law reads its own
`R11U283_<LAW>_OFF` switch, `R11U283_OFF` drops all seven and gives pristine's bytes on 182 of 182 grid case-views,
`R11U283_TRACE=<dir>` logs every firing (one file per process, `OUT <-o path>` first). No corpus database moves a
byte; **TWENTY-ONE PROBE CONVERSIONS**, no probe change, no regression.

| target (probe, default view = the gate) | before (base) | after (law) |
|---|---|---|
| program instantiated twice: r11u105repro/grid k40_B_program_inst_twice, k42_C_program_inst_twice_control; r11v105repro/grid v13_B_prog_inst_in_two_parents, v22_B_prog_inst_sharedleaf; r11u95repro/grid a22_progtwoinsttask, c13_progtwoinstbody; r11v95repro/grid x5_progtwoinstgeninit | `fullname(7)` / `fullname(4)` | **7 EQUAL** |
| program generate-block function duplicating a body function: r11v95repro/grid/x27_proggendupfirst | `line(3)` | **EQUAL** |
| definition-view generate comma list: r11u22repro/grid/d21_comma_list, r11u23repro/grid/d10_comma_list, r10vearl106repro va3_span106 and va7_mix106, r10vearl113repro/v1_decl113 | `endcol` / `endline` | **5 EQUAL** |
| interface instantiated several times: r10v226repro/branches/b12_multiproc, r10uvm226repro/grid226 a9_multiinst and a10_genregion | `fullname(5)`, `(9)`, `(12)` | **3 EQUAL** |
| bound instance names: r10vearl95repro/v95f_bind, r10vearl98repro/v4b_bind98, r10vrgg16repro/cells/v14 | `fullname(2)`, `(1)`, `(2)` | **3 EQUAL** |
| scoped class return: r10uvm56repro/v3_hierpath, r10v150repro/v150_f1 | `endcol(4)`, `endcol(2)` | **2 EQUAL** |
| probe | EQUAL 3815 + STRICT_NOTEQUAL 272 | **EQUAL 3836 + STRICT_NOTEQUAL 251**, regressions 0, changes 0 |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged; 0 byte movers in all three corpora |

In the elaborated view (`-elabuhdm`, not gated) 20 of the 21 converted cases read STRICT_EQUAL too; r10vrgg16repro/cells/v14
reads `depth` at a pre-existing param_assign record that was behind the two fixed full names (chain away 0, toward 2;
evidence/conversions_elview.txt).

## The laws

1. **§ progDefKeepsLastInstProcs283** (ModuleEmit emitInstance, the program branch; switch `R11U283_PROGLAST_OFF`).
   A program instantiated more than once is compiled ONCE in golden: the definition, the first instance and every later
   instance list ONE set of process objects, bound to the FIRST instance's signals (k40 `f = a`: ref_obj actual
   `work@dut.u_p.a`), and every later instance re-stamps that set as its own: the process is parented at the LAST
   instance (c13's begin reads `work@dut.u_p2` under the definition and under `u_p1`) and every stored full name below
   it reads the last instance's path (k40 ref_obj `work@dut.u_q.a`; v13 / v22 `work@z.u_q.a` with a second top
   declared later). Ours compiled the body once per instance and the definition kept the first copy. With the law a
   later instance compiles no process, lists the shared set, re-parents it and renames, by prefix, every stored full
   name of an object the process OWNS (parent chain), never entering a reference's target (OwnedRename283, the
   § propAssertLastInstPath188 renamer widened to scopes, variables and nets). The law stands aside when the first
   instance's listing holds anything besides the program body (a synthesized port initializer) or the current
   instance has one (grid P/p09).
2. **§ progGenDupFirstSpan283** (ModuleEmit, inside § caProgFlatTfNameKeyed95V; `R11U283_PROGGENDUP_OFF`). The
   verifier of pass 95 decoded the program's name-keyed subroutine registry: the survivor of a duplicated name carries
   the FIRST declaration's span and the LAST declaration's body. When the generate block's FUNCTION precedes the
   program body's in the source, the kept body object is now located at the generate declaration (x27 golden
   5:7-5:60, ours 8:3-8:56). A TASK keeps the body declaration's span (grid P/p17: golden 6:3-6:34, the law's first
   draft moved it and the case left STRICT_EQUAL; the law is restricted to functions).
3. **§ defGenCaCommaListSpan283** (ModuleEmit emitDefGenStmts; `R11U283_DEFGENCOMMA_OFF`). The definition view's
   generate-block cont_assigns of a comma list (`assign a = x, b = y;`) each take the whole list's span: Surelog's
   compileContinuousAssignment runs `populateCoreMembers(List_of_net_assignments, ...)` on every cont_assign it
   builds, and CompileStmt's paContinuous_assign (the generate block's statement compile) calls the same function
   (golden d21 7:12-7:66 on both, ours 7:12-7:38 and 7:40-7:66). The module-level and the elaborated generate-scope
   emitters already wrote it so.
4. **§ ifaceInstFirstProcsShared283** (ModuleEmit emitInterfaceInstance; `R11U283_IFPROCFIRST_OFF`). With several
   instances of one interface golden keeps ONE process set, the FIRST instance's, its references bound to that
   instance's signals (b12 `q = 1` in the definition binds `work@bm_top.a.q`), listed by the definition and by every
   instance (golden's dump prints vpiProcess under a, b and c as the one object). Ours compiled the body once per
   instance, each instance listing its own and the definition keeping the last (`work@bm_top.c.q`). A later instance
   now lists the first instance's set and compiles none.
5. **§ ifacePortViewNoProcs283** (ModuleEmit emitInterfaceInstance; `R11U283_IFVIEWNOPROC_OFF`). A PORT VIEW of an
   interface (the interface_inst a module's, program's or interface's interface port lists, `work@dut.s1.m`) lists no
   process in golden, where ours compiled the body again for it and, as the last writer, handed its set to the
   definition (grid I/i17: golden's view without vpiProcess; i21-i23 move from uhdm-cmp stage 1 to STRICT_EQUAL).
   The view lists none and leaves the definition's listing alone. Laws 4 and 5 act together on a port view of a
   twice-instantiated interface (12 grid case-views return to pristine's bytes only with both switches off).
6. **§ bindChildDisplayScopedNames283** (ModuleEmit emitInstance; `R11U283_BINDDISP_OFF`). A BOUND instance's
   generate-scope arrays are named on the bind's display path (§ bindDisplayTargetParent188: the target's parent,
   then the bind's name) at every depth, while the generate scopes and everything in them keep the target path: golden
   v95f `work@v95f_bind.u_mon.b_d1` and `work@v95f_bind.u_mon.b_d1.b_d2` over gen_scope `work@v95f_bind.u_t.u_mon.b_d1`.
   Surelog's gen_scope_array takes ModuleInstance::getFullPathName, which for a bind instance runs through the parent
   createBindInstance_ gave it. The interface port's LowConn of a bound instance is named on the display path too, as
   the plain port's already was (v14 `work@top.b_c.p`, ours `work@top.l1.b_c.p`), renamed after the path-keyed record
   (ifacePortLowConnByPath) is taken. The walk stays inside the instance (never a child instance: B/b06 residue).
7. **§ scopedClassRetQualSpan283** (TaskFuncEmit, the class-handle return; `R11U283_SCOPEDRET_OFF`). A return written
   as a SCOPED class (`function automatic fp1::LL h2();`) locates its class_typespec at the scope prefix `fp1::`, the
   Class_scope node CompileType's class_scope branch populates it from (golden v150 9:22-9:27, ours the whole 9:22-9:29),
   the rule TypeEmit's scoped class reference already follows for declarations; the return variable keeps the whole
   written type (compileVariable populates it at the data type node: class_var 9:22-9:29). Module, package, $unit,
   interface and program functions, in-body, extern / out-of-body, static and virtual methods, a parameterized
   specialization `fp::PP#(8)`, a macro-written type, `fp :: LL` with spaces, CRLF and a header included in two modules
   all convert (grid R).

## Grid (tools/probe/r11u283repro/cases, 91 case dirs in both views: 182 case-views, every line with its exit code)

`drivers/grid.sh` runs every case-view on pristine (P), the law (L), the law with `R11U283_OFF` and the law with each
switch off (evidence/grid.txt); `drivers/gridsum283.py` (evidence/grid_summary.txt):

- `R11U283_OFF` gives pristine's bytes on **182 of 182**.
- **160 moving, 132 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.** Attribution: each mover returns to
  pristine's bytes under exactly one switch (PROGLAST 28, PROGGENDUP 6, DEFGENCOMMA 30, IFPROCFIRST 32, BINDDISP 22,
  SCOPEDRET 30) except 12 needing IFPROCFIRST + IFVIEWNOPROC together (I/i17, i19-i23 both views;
  evidence/grid_pairs.txt).
- uhdm-cmp line counts changing: 11, ten to 0 (I/i08 both views 36 / 64 -> 0, I/i17 31 / 229 -> 0, i21-i23 both
  views -> 0), one growing at stage 1 on both binaries: I/i19_generic_port default 31 -> 638 (the generic port's
  golden view lists the instance's variables twice, the pre-existing head that the removed process difference had
  hidden; chain away 0, toward 10).
- Away census (drivers/awaycv.sh: away.py order-blind and awaychain.py chain-keyed with the variant comparator
  strictcmp_x; evidence/grid_away.txt): **lost 0 and chain away 0 on all 160 movers** (P/p04 reads flat away 1,
  chain away 0, toward 21). Positive control: the binaries swapped on six movers read away 2 to 9
  (evidence/away_poscontrol.txt).
- Movers staying STRICT_NOTEQUAL or stage 1 (all wrong on pristine too, chain away 0): B/b06 (`fullname`, the bound
  module's CHILD instance named on the display path in golden), B/b10 (`fullname -> line`, the positional interface
  port's LowConn location), C/c08 (an unrelated port array_typespec end), stage 1 on both binaries B/b07, b09, b12,
  C/c04 (a delay), c05 (a drive strength), I/i06, i19, i20, P/p04, p06, R/r12 (a nested `fp::OO::II` return).
- Downstream on the 91 dirs (drivers/dscases.py; evidence/downstream_cases_{P,L}.txt): 85 IDENTICAL on both
  binaries; I/i08_param DIVERGENT -> IDENTICAL, I/i17 and I/i23 EQUIVALENT -> IDENTICAL; B/b12 EQUIVALENT, I/i20
  STATUS_DIFF and P/p09 SURELOG_FAIL on both; none worse.

## Gates (law binary c9c78b5b9208ea870395bb4f4399d383; pristine b14ecd9c27c854a7b81fcde33f30da1a = the main tree's build)

- tests/sweep.sh --jobs 3 (all four stages, evidence/sweep_L.log): probe **regressions=0 conversions=21 changes=0**
  (EQUAL 3836 + STRICT_NOTEQUAL 251); surelog regressions=0 conversions=0 changes=0 (default CMP_EQUAL 478 +
  STRICT_NOTEQUAL 2, testflags 472 + 2); uhdm2rtlil 0 / 0 / 0 (803/1/67 both modes); downstream IDENTICAL 803,
  SLANG_REJECT 66, EQUIVALENT 2, not excused 0, the csv byte-identical to pristine's and to
  results/downstream_uhdm2rtlil.csv. The surelog csv differs from pristine's only in the LowMemLib / LowMemPkg
  testflags detail text (the workdir path). Both sweeps exited 1 on the law-index check alone (the committed index is
  stale at the base); this patch regenerates it.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, fence-filtered hard-link mirrors from
  drivers/bvmirror.sh, 8 fenced row-mode databases left out; evidence/byteverify_corpus.txt): **surelog 0 / 952,
  uhdm2rtlil 0 / 1608, downstream 0 / 805 movers**, SELFCHECK n-1 / n on each. Probe: **21 of 4087 databases move,
  exactly the 21 conversions** (evidence/byteverify_probe.txt).
- Predictor (drivers/tracecensus.sh, the law binary under R11U283_TRACE over the probe cases and both corpora in both
  modes with the fence filter, frozen before the law sweep; evidence/predict.txt, 349 lines): every mover predicted
  by name. It over-predicts: § ifacePortViewNoProcs283 traces on every interface port view, and bytes move only where
  the interface body holds a procedural block, which no corpus row's port view does (35 surelog, 106 uhdm2rtlil and
  187 probe lines, none moving).
- uhdm-cmp on every converted case: 0 lines; no corpus row changed status or strict column.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.
- Binary-path audit (fence-filtered cmds.txt lists): 3265 of 3315 name each sweep's own binary, the other 50 carry no
  slang line, on both sweeps.
- Determinism (drivers/det.sh, three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen with the law binary; evidence/determinism.txt): one hash per row-mode, each equal
  to the law sweep's.
- Byte controls (drivers/controls.sh over every case of the 37 repro dirs in evidence/controls_dirs.txt, among them
  pass 118's, 119's, 120's, 124's, 125's and 131's grids, passes 188, 202, 206, 231, 277, 279 and 281 with their
  verifiers, and the r11u105 / r11v105 / r11u95 / r11v95 / r11u93 / r11v93 / r10uvm226 / r10v226 residue dirs; path
  lists fence-filtered first): 1887 dirs, **3774 case-views, 6 moving, 4 entering STRICT_EQUAL, 0 leaving, 0 exit-code
  changes**, uhdm-cmp line counts 36 -> 0 and 64 -> 0 (r10v226repro/branches/b14_param, an interface with two parameter
  overrides: stage 1 -> STRICT_EQUAL in both views), v11u281repro/cases/VI/vi38_two_inst_two_declarators both views
  `fullname -> STRICT_EQUAL`, r10uvm226repro/grid226/a14_genregcount both views stage 1 unchanged at 500 lines; away
  census lost 0 and chain away 0 on all 6, toward 8 to 14 (evidence/controls_away.txt). Four case-views exit 139 on
  BOTH binaries (r10v226repro/branches/b13_modportproc and r11v105repro/grid/v09_A_nested_program_in_sub, both views).

## Residues (ranked; all wrong on pristine too)

1. The struct member full names through the importing chain in class and importer copies (8 probe cases:
   r10sd10repro g6 and v2, r10sd6repro v3, r10uvm198, r10uvm202, r10uvm207 c / e / h). Decoded here: golden's member
   ref_typespec names are COMPUTED from the parent chain (ComputeFullName): golden's class copy binds a struct
   typespec parented at the importing package (`q6::p6::t6::a6`) or, in an importer clone, at the clone's ref_typespec
   (`sluice198::Adit198::winze198::tfPkg198::quarry198::pkgSt198::lode198`), where our clone_tree copy in
   ModuleEmit importVarCopy5 (§ classInheritsContainerImports23) keeps a stored `p6::t6::a6`. Not written.
2. Bound instances' CHILD instances (grid B/b06): golden names the child module_inst, its ports and its generate
   arrays on the display path (`work@dut.u_m.u_l`), ours on the target path; needs the child prefix of a bound
   instance to be the display path in emitInstance.
3. A program generate-block FUNCTION written after the body's (tools/probe/r11v95repro/grid/x8_proggendupname, stage
   1): golden's survivor has the LAST declaration's body; ours keeps the body declaration's object.
4. The definition-view gen-scope cont_assign Rhs of a select left side (r11u69repro/grid g2_iter, g4_lhskind, g5_nest,
   r11v69repro v10_arraysel, r11u88repro j3_ifcaselect: golden shares the package pattern member constant, ours keeps
   the hier_path `CFG.n` behind § caStructParamGenScopeSubst69's Lhs fence); the concatenation-member patterns a25 /
   a28 / g25 and v111_b6 (pass 273's list).
5. Interface declaration order (decoded on a fresh case: a body `wire o;` above `output o;` in an INTERFACE puts
   golden's port LowConn at the first declaration where ours uses the port declaration, r11v93repro v15; modules are
   right), and the elaborated interface nets of a non-ANSI port read or initialized in the body (r11u93repro pb10,
   pb19: golden at the port declaration).
6. Escaped identifiers' end columns (r10earl54repro v3_v54, v11u110repro a36_escaped_inst_name, r10earl31repro e4_ctrl).
7. class_typespec spans of class handles with a parameter list in a class method / class property (r10sd1repro b27,
   r10v119repro v119_j: golden the class name only) and of dynamic arrays of a class in an interface
   (r10uvm221repro a4_corpus, r10uvm225repro a6_headerforms: golden the whole declaration).
8. The elaborated cont_assign call fold (6 probe cases: r10rgg6repro one_none_n4_yes_typed_ca, r2_ca_outer,
   top_none_n4_yes_typed_ca, r10vrgg6repro w_two_ctx_order, r11u108repro k17_func_in_pkg, k20_cfg_func_width): golden's
   writeCont_assign reduceExpr evaluates simple module functions (a fresh case folds `f(K)` to INT:5 in golden) and
   declines these (loop bodies with automatic initializers, packed-array arguments built by function chains); the
   evaluator's failure rule is not transcribed.
9. The rest of the brief's items (2) to (7) not attempted.

Sister-ground faces met (reported, not written): the elaborated overridden parameter typed by a typedef of a typedef
(r11u108repro k05_param_a, r11u111repro a27_q_row_named_dims, v11u111repro x38_param_in_module_typed: golden an
unlocated `q2::row_t` wrapper whose alias refs read `<in>q2::row_t`, ParamEmit's elaborated parameter typespec); the
type-parameter chain borrow (r11u45 / r11v45, ParamEmit § typeParamChainBorrow45); the package struct typedef stretch
(ParamEmit).

## Process

- Fence: every corpus path list was filtered by $FENCED (read fail-closed from tools/probe/r11u107repro/canaudit.sh)
  before any file was opened (bvmirror, the census filter, the binary-path audit, the corpus mover preview); no fenced
  source or database was read or dispatched outside the gate sweeps.
- SLIP: one background waiter tested `pgrep -f` with a pattern contained in its own command line, so it could never
  end; it was stopped by its own task id, no other process was listed or signalled.
- Every tool variable was checked with `[ -x ]` (drivers/env.sh); nothing was written outside the worktree and the
  pass's own scratch.
- Drivers: copied from tools/probe/r11u281repro/drivers (grid.sh with the R11U283 switches, gridsum283.py).
