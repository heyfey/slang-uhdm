# r11u304 — pass 304, expression/parameter ground: the subroutine body's typedef items, the uninstantiated interface's parameter foreach, the generate-scope cast alias name, the nested select in a path index

Pair A, refill after pass 302. Base 1a9530f6 (pass 302). Production surface: src/StmtEmit.cpp, src/ExprEmit.cpp
and the new src/R304.h only (ParamEmit and EmitHelpers.h untouched). Pristine build md5
aaf89bbe9c28f0fbf51f6ae28021ecfe (equal to the main tree's build/slang-uhdm at the base); law build md5
8e3a7b6bb8169cb9f720d1c82732a382. Both binaries were frozen (chmod 555) before any measurement; every
cmds.txt of both sweeps names its own binary (evidence/gates.txt). Both report slang 12.0.0+545f88b2e.

## Verdict

- **FIVE PROBE CONVERSIONS**, each predicted by name in the firing census frozen before the law sweep
  (evidence/predict.txt), uhdm-cmp 0 lines before and after; the fresh law-sweep rows:
  - `r10uvm213repro/g213_i_scopedtd,EQUAL,,equal` (was `differ:line(2)`) — § tfBodyTypedefIsItem304
  - `r10uvm220repro/grid220/a1_uninst_if,EQUAL,,equal` (was `differ:file(2)`) — § uninstIfaceForeachParamOwnTs304
  - `r11u113repro/grid/c/c09_genif_modtd_ctl,EQUAL,,equal` (was `differ:fullname(1)`) — § genCaCastTdAliasScopedName304
  - `r11u113repro/grid/c/c11_genif_pkimp,EQUAL,,equal` (was `differ:fullname(1)`) — § genCaCastTdAliasScopedName304
  - `r10earl29repro/b1_sites,EQUAL,,equal` (was `differ:fullname(4)`) — § hpOpIdxNestedSelByPath304
- **One probe change, shrinking:** `r10uvm79repro/c2_idxkind,STRICT_NOTEQUAL,differ:col(3),differ:col(3)` (was
  `differ:col(5)`) — § hpOpIdxNestedSelByPath304 clears the d4 face (`iarr[midx[i] + 1].f`: the bit_select
  `midx` now `work@grid::probe::iarr[ + 1].f::midx` at 24:14-21 and its index `i` named through the path, as
  golden); the first record #83 is unchanged (the depth-3 face `iarr[midx[midx[i]]].f`, a select directly in a
  select index, not an operation), chain away 0 (residue 2).
- **No corpus row moves:** surelog default 480 + 0 and testflags 474 + 0, uhdm2rtlil 803/1/67 in both modes,
  regressions 0 / conversions 0 / changes 0 in both corpora; byteverify reads 0 corpus and 0 downstream-lane
  databases moving. Every Surelog row-mode stays CMP_EQUAL (954 of 954); stamped_gen_param d/t stays CMP_NOTEQUAL
  as at the base. The firing census found no firing and no abstention on any corpus row-mode.
- **Downstream:** IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0, the law csv byte-identical to
  results/downstream_uhdm2rtlil.csv.
- **Probe gate:** 4015 EQUAL + 72 STRICT_NOTEQUAL, regressions 0, conversions 5, changes 1 (pristine at the base:
  4010 + 77, equal to results/golden_probe.csv).

## The laws (src/R304.h)

`R11U304_OFF` drops all five and gives pristine's bytes and exit code on 278 of 278 grid case-views.
`R11U304_TRACE=<dir>` logs every firing (`<law> <detail>`) and every abstention (`<law>_ABSTAIN <reason>`) into
`<dir>/<pid>.304`, its first line `OUT <-o path>`.

### § tfBodyTypedefIsItem304 — `R11U304_TDITEM_OFF` (StmtEmit, the statement-list branch's wrapper begin anchor)

Surelog's `compileFunction` / `compileTask` (third_party/Surelog/src/DesignCompile/CompileStmt.cpp) build the
body's wrapper `begin` when `MoreFunction_statement_or_null` / `MoreStatement_or_null` exists and locate it on that
node (`fC->populateCoreMembers(More..., More..., begin)`): the SECOND `Function_statement_or_null` of a block-item
body, and a body `typedef` is one of those items (a data_declaration the parser lists among them). slang lists no
statement for a typedef, so the second-item count skipped it: golden `function void c::gi213(); typedef bit [2:0]
stmt213_t; stmt213_t locsi213; locsi213 = 3'b0;` anchors the begin at `stmt213_t locsi213;` (21:5-24), ours at the
assignment (22:5-21); `int b; typedef ...; s_t v;` anchors at the typedef itself. The law reads the subroutine's
own syntax item list (`FunctionDeclarationSyntax::items`, the count `subroutineBodyItemCount157` already uses) and
fires only when a typedef is the first or second item of a block-item body: a typedef or declaration item spans
the whole item, a statement item takes the anchor the branch already gives it (`invalidAnchor244`). A TF-ITEM
(paren-less) body skips its typedefs as Surelog does (they are tf_item_declarations), a constructor keeps
emitCtorBody27, and a parameter-bearing task body takes the `items9` branch, untouched. Trace `TDITEM
<sub> typedef|decl|stmt`, `TDITEM_ABSTAIN <sub> unmatched`.

### § tfBodyTypedefForcesBegin304 — `R11U304_TDBEGIN_OFF` (StmtEmit, emitStmt's entry)

The same producer rule decides WHETHER the wrapper exists: two or more written items make the begin, a typedef
included. slang's `bindItems` hands a one-statement body back as that statement (not a list), so `function int
g(int a); typedef ...; return a + 1; endfunction` reached emitStmt as a bare `return` where golden has a `begin`
(anchored at the second written item, holding the typedef listing on vpiTypedef, as `makeStmtScopeTdListing157`
builds it for the list branch) around it; uhdm-cmp read 59 to 248 lines on every such shape. The law builds that
begin for a block-item, non-constructor, parameter-free body whose slang body is one statement, an empty list or an
empty statement (a `;` item), when the written items hold a typedef; the anchor is the second written item (the
statement's own anchor when that item is the statement). A body whose one statement is a declaration
(`typedef ...; s_t v;`, grid TD t28) abstains: its variable re-parenting is the list branch's business and
golden's shape there is a separate face (exit 4 on both binaries). Trace `TDBEGIN <sub> stmt|item|empty`.

### § uninstIfaceForeachParamOwnTs304 — `R11U304_UIPARAMTS_OFF` (StmtEmit, the foreach array reference)

A foreach over a PARAMETER array inside an UNINSTANTIATED interface's subroutine (or process): golden's iterated
reference binds the parameter's own `array_typespec` (13:14-27, `int PAR220[3]`), because
`compileDatastructureTypespec` scans the interface's `getParamAssignVec()` and returns that parameter's
`Actual_typespec` (the fence § uninstIfaceForeachHdrUnresolved220 already reads, CompileType.cpp:750-762). Ours
deferred the bind to the pendingForeachArrayTs drain, which knows array variables and ports only and minted a
bare unlocated `array_typespec` (probe a1_uninst_if `file(2)`, the walk then diverging on the missing element).
The law reads the parameter of that name from the interface listing the foreach sits in and binds its typespec
object; it abstains (traced) when no such parameter carries an array_typespec (a package parameter imported into
the interface is listed there too and binds, grid UI u07, as golden). Trace `UIPARAMTS <name>`,
`UIPARAMTS_ABSTAIN <name> noiface|noparam`.

### § genCaCastTdAliasScopedName304 — `R11U304_CASTALIAS_OFF` (ExprEmit, the module-scope cast clone)

In an ELABORATED generate scope's continuous assignment, a cast to a logic typedef (`assign y = idx_t'(a);` in
`if (1) begin : g`) is re-elaborated in the scope by UhdmWriter::writeCont_assign's clone, and the clone's
Typedef_alias reference is named through the scope: golden `work@top.g.idx_t` (`work@top.g[0].idx_t` in a
for-generate, `work@top.u.g.idx_t` in a child, `work@top.m.l.g.idx_t` at depth 3), where ours kept the bare
`idx_t`. The clone's own range references are renamed the same way (`typedef logic [W-1:0] idx_t`: golden
`work@top.g.idx_t.W`). Gated on the clone actually happening, read from pass 282's and pass 17's decode of
writeCont_assign: a bound whole-name target over an operation right side (`caBoundLhsOpRhs17`), or a right side
that IS the cast (parentheses seen through). Abstains (traced): a cast inside a select's brackets (an index or a
part-select bound, golden bare: k17, k29, k30, k32), a select, member or generate-local target over an operation
(golden bare: p09 to p11, p14 to p17 and the control r11u288repro PC/pc04_gen_scopes, which convicted the first
draft), and a written package qualifier (`pk::idx_t'(a)`, golden mints no clone there at all, k05). A process in the
scope (k07) and the module body (k01) are untouched (not `inGenScopeCaRhs`). Trace `CASTALIAS <name>`,
`CASTALIAS_ABSTAIN <scope> <type> in-select|no-reclone|qualified`.

### § hpOpIdxNestedSelByPath304 — `R11U304_NESTSEL_OFF` (ExprEmit, emitMixedHierPath's tail)

A select nested in an OPERATION that indexes one of a member path's selects (`ea[k[0] + 1].fld`,
`t.arr[{1'b0, k[0]}].fld`, `iarr[midx[i] + 1].f` in a class method) is compiled by Surelog as part of the path's
element list: golden names the bit_select by the path (`work@top.ea[ + 1].fld.k`, `...::iarr[ + 1].f::midx`) and
locates it from its name to its closing bracket (8:22-26), names the references in its index by the path too
(`...fld.j`), names a select nested in ITS index through it and spans it whole (`...fld.k.k2`, with that select's
index references `...fld.k.j`), and names a part select there `...fld.k` (ours `...fld.ea.k`). Ours named all of
them by the scope (`work@top.k`) at the index (8:24-25). Under a user or system call's argument inside that
operation (`ea[f(k[0]) + 1]`, `ea[$unsigned(k[0]) + 1]`) golden names the select and its index references by the
path but keeps the select at its index. The law walks every non-last bit_select element of the path whose index
is an operation; the whole span is read from slang's ElementSelect expression keyed by its selector's laid-out
span, and a macro-born select abstains (traced `nospan`; grid NS m19, golden spans through the macro). A bare
select index (`ea[k[0]].fld`) and the path's last element are untouched; a path inside a simple part-select's
range bound keeps § psRangeBoundHpBaseSelKeeps153v's gate. Trace `NESTSEL [callarg ]sel|inner|part <name>`,
`NESTSEL_ABSTAIN nospan <name>`.

## Grid (cases/, 139 case dirs, 278 case-views; evidence/grid.txt, grid_summary.txt, grid_attrib.txt)

Every case dir's first line names its law. drivers/gridall.sh: pristine, law, law+R11U304_OFF and law+each
switch, every line with its exit code (`rc=`), both views (`d` = check_probe's arguments, `e` = + elabuhdm).

| grid | law | dirs | shapes |
|---|---|---|---|
| TD | § tfBodyTypedefIsItem304 (23), § tfBodyTypedefForcesBegin304 (21) | 44 | out-of-body, in-class, static, extern below the caller, pure-virtual implementation, parameterized class specialization, package function and task, module, interface, program, generate-block and `$unit` subroutines; typedef first, second, two typedefs, enum typedef, macro-born typedef (first and second item); one-statement bodies (return, assignment, system task, `begin` block, `if`, null statement, typedefs only), declaration-with-initializer, named-argument caller; controls: TF-ITEM body, constructor, named block, localparam |
| UI | § uninstIfaceForeachParamOwnTs304 | 12 | parameter, localparam, typedef'd array, two dimensions, packed element, header parameter, package parameter imported, process (initial), macro-born declaration, two interfaces, nested foreach; control: instantiated interface |
| GC | § genCaCastTdAliasScopedName304 | 53 | if, for, case, nested and two-level generates, child depth 1 and 3, interface, implicit net, package import, header parameter in the typedef's range, macro-born cast, operand / ternary / replication / replication-count positions, select and generate-local targets, parentheses, genvar operands; abstentions: casts in a bit-select index, a part-select bound and an indexed part-select base (constant and variable), qualified casts, select / generate-local targets over an operation, net declaration assignment; controls: module body, process, int cast, struct typedef, user-call argument |
| NS | § hpOpIdxNestedSelByPath304 | 30 | `+`, concatenation, unary, two selects, variable index, three levels, part select, member and base selects, continuous assignment, process lvalue, streaming lvalue, generate scope, for-generate, child at depth 1 and 3, class method, `this.` path, parameter base, user and system call arguments (constant and variable index), a path in an index, an indexed part-select base, macro-born index; controls: bare select index, increment target |

Law against pristine: 210 movers of 278 case-views, 178 entering STRICT_EQUAL, **0 leaving**, 0 exit-code
changes (exit 4 on TD t28, GC k06 and k25 and exit 3 on NS m17 on every binary: slang rejects m17's non-constant
part-select bound; the others are stage-1 shapes unchanged), uhdm-cmp line changes on 40 case-views, all falling (TD: 59 to
248 lines -> 0 on 36 case-views; t32 230/234 -> 33/22 and t43 140 -> 95, the next face of those cases).
R11U304_OFF equals pristine's bytes on 278 of 278. Per switch: every mover is restored to pristine's bytes by
exactly one single switch (CASTALIAS 62, NESTSEL 46, TDBEGIN 42, TDITEM 38, UIPARAMTS 22; evidence/grid_attrib.txt).

Movers that do not enter STRICT_EQUAL (all chain away 0): GC k20_iface d/e (the next record is the interface
reference `work@top.u.g.a`, unnamed in golden), k25 and k27 (stage 1 on both binaries), p12_two_iter_ref e,
NS m15_class e (the class method's elaborated view, where golden names every path-index object through the base
select again, `...::iarr[ + 1].f::iarr::midx`, for this law and the landed § hpBaseSelOpIdxNamesByPath145 alike:
residue 3), m18 and m22 (stage 1, the select named and spanned as golden, the stage-1 head elsewhere), TD t05,
t16, t17, t46 (module and interface subroutines: golden lists a module-level net for the local, another face),
t10 (a localparam item), t15 and t43 (an enum typedef in a subroutine: golden's begin lists a ref_var, uhdm-cmp
falling 140 -> 95 on t43), t32, t38 (a program's task typedef listed on the program), UI u03 (a typedef'd array
parameter: our parameter's own typespec is the wrong object, which the reference now shares; 0 records either
way).

**Away census** (map 12's chain-keyed census, drivers/awaygrid.sh with strictcmp_x): 0 records away on all 210
grid movers, 1014 records toward golden (evidence/grid_away.txt). Positive control (the binaries swapped, every
sixteenth mover): away on 12 of 13, u03 neutral (evidence/away_poscontrol.txt).

**Downstream on the grid** (drivers/dscases.py, every case dir on both binaries, run one binary after the other;
evidence/downstream_cases_*.txt): no case worse; 3 EQUIVALENT -> IDENTICAL (NS m04_base_plus_varidx, m08_twolevel,
m23_threelevel: the nested selects' names and spans reach the RTLIL `src` attributes), 128 IDENTICAL on both, and
the same verdict on both binaries for the rest (EQUIVALENT GC k06, TD t17, t46; DIVERGENT GC p09, p10; STATUS_DIFF
NS m16, m28; SLANG_REJECT NS m17).

## Byte controls (evidence/controls_*.txt)

- Trigger-selected (drivers/firescan.sh: the law binary over every dut.sv dir under tools/probe and tests/probe,
  30201 dirs (this pass's own case dirs included), the path list filtered by $FENCED before any file was opened; the dirs whose run wrote a trace
  line, minus this pass's own cases and the gate's six probe databases: 19 dirs, 38 case-views;
  evidence/firescan.txt, control_trigger_dirs.txt): 32 moving, 9 entering STRICT_EQUAL (r11u198repro K/k10_for_typedef
  d/e, v11u198repro K/x13_typedef_cast_concat d/e, v11u282repro VC/vc05_cast_typedef_sel d/e by CASTALIAS,
  r11v145repro bso/x14_bitsel_in_op d/e and v11u252repro VX/vx08_two_dim_idx d by NESTSEL), 0 leaving, no
  exit-code change, uhdm-cmp lines falling on r11u229verify B/b04 d/e (110 -> 38, TDBEGIN); the rest stage 1 on
  both binaries and moved toward golden (r10uvm221 a2_home, r10v149 arms/scoped, r11u233verify F/f04 and f24,
  r11u305repro TQ/s24_func_local, r11u35 g1_site35, r11u52 x3_scopes, v11u285repro VM/vm08_local_td by TDITEM;
  r11u182verify B/b05, r11u204verify K/k2 by CASTALIAS); v11u287repro VD/vd13_cast_idx abstains only (a cast in a
  select index) and does not move.
- Standard: every case dir of passes 118, 119, 120, 124, 131, 145, 198, 282, 288 and 302 with their verifications
  (r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11v120repro, r11u124repro, r11v124repro,
  r11u131repro, r11v131repro, r11u145repro, r11v145repro, r11u198repro, v11u198repro, r11u282repro,
  v11u282repro, r11u288repro, r11u302repro, v11u302repro) and the tools/probe dirs of this pass's targets
  (r10earl29repro, r10uvm213repro, r10uvm220repro, r10uvm79repro, r11u113repro): 2124 dirs, 4248 case-views,
  8 moving, all 8 entering STRICT_EQUAL (the four trigger dirs above that these sets contain), 0 leaving, no
  exit-code or uhdm-cmp change; r11u288repro PC/pc04_gen_scopes and r11u113repro c/c10_genif_pkqual do not move.
- Chain away 0 on all 32 distinct control movers, 126 records toward golden (evidence/controls_away.txt).
- The crash scan: one exit 139 over the 30201 dirs, v11u112repro m07_hdr_enum_default, crashing on pristine too.

## Firing census (evidence/predict.txt, frozen before the law sweep)

drivers/tracecensus.sh on the law binary over the probe cases and both corpora in both modes (the filter built
from $FENCED). Firings: exactly the six probe databases b1_sites (NESTSEL 2), g213_i_scopedtd (TDITEM 2),
a1_uninst_if (UIPARAMTS 1), c2_idxkind (NESTSEL 1), c09_genif_modtd_ctl and c11_genif_pkimp (CASTALIAS 1 each);
no firing and no abstention on any corpus row-mode. Byte movers in the law sweep: exactly those six probe
databases, 0 of 2560 corpus, 0 of 805 downstream.

## Gates (evidence/gates.txt, sweep_P.log, sweep_L.log)

- probe: law 4015 + 72, regressions 0, conversions 5, changes 1 (the five conversions and c2_idxkind col(5) ->
  col(3) above); pristine 4010 + 77 (0 / 0 / 0). The row-by-row diff of the two probe csvs is exactly those six rows.
- surelog 480 + 0 / 474 + 0 and uhdm2rtlil 803/1/67 in both modes: regressions 0, conversions 0, changes 0 on both
  binaries; the row-by-row csv diff law vs pristine: the LowMemLib / LowMemPkg testflags detail text (the workdir
  path) and nothing else; the uhdm2rtlil csvs identical.
- downstream 803/66/2/0, the law csv and the pristine csv byte-identical to the committed one.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, same-length workdir names) on fence-filtered
  hard-link mirrors (drivers/mirror.sh, 2560 databases each, 8 fenced skipped): PATH_SETS_IDENTICAL, MOVERS 0 / 2560;
  SELFCHECK reads 2559 of 2560 flagged: the self-check compares every file with one fixed file, and that file
  compared with itself is the one not flagged (the artefact pass 201 first explained), not a mover. The probe
  databases compared the same way (the path list filtered by $FENCED first): 6 of 4087 moving, exactly the
  predicted six; the downstream lane's slang databases: 0 of 805 moving (self-check 804 of 805 flagged, the same
  artefact).
- canaries (tools/probe/r11u107repro/canaries.sh): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2
  EXPECT_UNKNOWN=1 (ok=58) and EXPECT_UNKNOWN=6 (ok=2) PASS.
- binary-path audit (drivers/audit.sh): law sweep own 3265 other 0 noslang 50; pristine sweep the same.
- determinism (drivers/det.sh, three concurrent draws of the law binary): one hash per row-mode on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen (Scoreboard and Rggen testflags write no
  database), each equal to the law sweep's (evidence/determinism.txt).
- the delivered patch applies clean on a fresh 1a9530f6 worktree and rebuilds to the law binary's md5
  8e3a7b6bb8169cb9f720d1c82732a382 (a fresh worktree, git apply rc 0, cmake -j 2).
- every sweep exited 1 on the law-index check alone (tests/LAWS.md is stale against a worktree carrying this pass's
  new README and cases); tests/LAWS.md is regenerated in this patch.

## Residues (ranked; the 72 probe cases still STRICT_NOTEQUAL, writer read from the first record's object chain, gdb backtraces where named)

1. **This ground, not attempted or not reached:** r11v77repro/grid/vh_arrelem endline(6) (ParamEmit, the package
   variable road of the typedef stretch: golden stretches `si_t` / `en_t` in ONE of its two package listings while
   ours lists one object in both, so the stretch needs a per-view object first; pass 280's measurement stands);
   r11v21repro/v15 depth(1) (§ elabParamLeftoverRefUnnamed174 in the drain); r11u117repro/grid/g1/t12 fullname(4)
   (the returned qualified member path, pass 292's withdrawn draft); r10uvm92repro/v92_b2_varsel fullname(1) (a
   var_select nested in a path index's operation, `bb.bin[n + two_d[1][bb.q]]`: golden names the inner path's
   `q` `...::bin::two_d::q`, the var_select twin of § hpOpIdxNestedSelByPath304, not gridded);
   r11v4repro/v6 fullname(1); the four r11u109 value(2) cases (a Surelog defect, golden reading `W'(1)` with
   W = 64 as 0).
2. **c2_idxkind's other faces** (col(3)): a select directly in a select index (`iarr[midx[midx[i]]].f`, #83: the
   inner select spans `midx[i]` 22:19-26 in golden) and a member chain in a path index (`iarr[h.idx[i]].f`, #114
   `h` at 26:16-19, #115). Same element-list compile; not gridded.
3. **This ground's laws, open shapes:** a class method's ELABORATED view, where golden names every path-index
   object through the base select again (`...::iarr[ + 1].f::iarr::midx`, NS m15 e, and the landed
   § hpBaseSelOpIdxNamesByPath145 refs the same; c2's e view); a macro-born nested select (NS m19, golden spans it
   through the macro); a cast in a generate-scope net declaration assignment (GC k24, golden scoped; ours is not
   `inGenScopeCaRhs` there, the cell's emission is ModuleEmit's); an interface reference in the same cell (k20, golden
   unnamed); the subroutine bodies' other faces (an enum typedef's ref_var, a localparam item, module and
   interface subroutines' module-level nets, the program's typedef listing: TD t15, t43, t10, t05, t16, t17, t46,
   t38), a declaration-only one-statement body (t28, exit 4 on both binaries), a parameter-bearing task body with a
   typedef (the `items9` branch, not gridded).
4. **The sister's ground (reported, not written):** r11u117repro/grid/g1/g13 endcol(3) — the dead generate
   branch's `localparam V = q2::IMPL.v` is written by TypeEmit emitSyntaxExpr called from ModuleEmit
   emitDefGenStmts (gdb backtrace on MakeHier_path; golden's shape: the hier_path at the qualifier `q2::`, the
   `q2::IMPL` reference at the member token, the leaf unnamed — the same shape golden gives a module-body localparam,
   grid scratch q03, stage 1 there on the hier_path's name, `q2::IMPL.v` in golden and empty in ours from
   ExprEmit's pkgQualBase9 member branch: a ground-A follow-up once the definition-view writer moves);
   v11u111repro/brk/f6/x64_two_dims_positional fullname(3) (`$bits(T)` in a child with a positional type override:
   golden names the references after the definition `work@child.T`, the type-parameter family, TypeEmit);
   r11u23repro e05_untaken_bare_partsel file(1) (golden binds a fresh unlocated enum_const minted by
   lateBinding for the generate block's package enum reference); v11u112repro g1k_hop_userfn line(4) (golden
   types the generate localparam's constant with the module function's formal typespec in the default view only);
   r10uvm227repro a9_class_holder, r10v97repro c3/c9 (the import-clone and class-specialization listings,
   UhdmExporter / TaskFuncEmit); and every chain pass 302 listed in its residue 4 that is still open: the package
   typedef stretches and last-writer spans (TypeEmit, UhdmExporter, TaskFuncEmit), the type-parameter typespec
   copies, the q2::row_t alias family, the generate and module-instance cells (p1_pos115, v8, v41v_comment,
   v59v2, g3_rhs98, l_concat, a3_inst66, v13_v54, c9_litarith_noovr, f1_noovr_arr_recvp), the interface port
   hier_path spans, the import-clone homes, the class and package-class faces, r11v11u8repro/v9's macro column.

## Sister-ground faces (reported, not written)

- g13's dead-generate writer (TypeEmit emitSyntaxExpr from ModuleEmit emitDefGenStmts), above.
- The generate-scope net declaration assignment's cast (GC k24): the law needs the cell's emission flagged the way
  `inGenScopeCaRhs` flags a continuous assignment (ModuleEmit emitGenScopes).
- Pass 302's g213_i_scopedtd, a1_uninst_if, c09_genif_modtd_ctl and c11_genif_pkimp, listed by pass 302 and pass 305
  as the sister's or by chain, were this ground's (StmtEmit's statement-list branch and emitStmt, StmtEmit's foreach
  branch, ExprEmit's cast clone), and are converted here.

## Process

- Four earlier law binaries were frozen before the final one, each replaced by the next with every measurement
  redone in full on the final binary: d8 (NESTSEL named a select's index references by the path even under a
  nested select; the grid's m23 read golden's `...fld.k.j`), d9 (NESTSEL extended to call arguments after the
  fresh m27, m30 and m31 cases read golden's call-argument naming), d10 (CASTALIAS gated on writeCont_assign's
  re-clone after the byte control r11u288repro PC/pc04_gen_scopes read chain away 2 on that binary: a select target
  over an operation keeps golden's bare name; the fresh p01 to p17 cases bracket the gate), d11 (CASTALIAS
  abstaining on a written package qualifier after GC k05 moved between two wrong byte sets with 0 records toward);
  d12 is the law binary. The censuses, sweeps, grids and controls of the earlier binaries were stopped by their
  own process groups (each group's command line checked for this pass's scratch names first) and rerun. The final
  firing census was frozen before the final law sweep; the final grid, controls, away censuses, scan, byteverify,
  canaries, audit and determinism all ran on the final binary.
- THE IMPLEMENTER'S SLIPS, no effect: one background launch line (`cd ... && nohup A & nohup B &`) ran B outside the
  drivers directory, so B (a grid run) failed at once with `gridall.sh: No such file or directory`; the summary
  first read from that run was of the previous binary's grid file, noticed from the file's timestamp, and the grid
  was rerun with absolute paths before any number was taken from it.
- Every driver read $FENCED fail-closed; every path list over tools/probe and tests/probe was built and filtered by
  $FENCED before any file was opened; no fenced name was spelled; the only process listings named this pass's
  own drivers; gdb ran on this pass's scratch cases only; nothing was written outside the worktree /tmp/wt_r11u304
  and /tmp/r11u304_* scratch.
- Drivers: copied from tools/probe/r11u302repro/drivers (renamed to R11U304 / r11u304; attrib.py's switch prefix
  updated), plus firescan.sh (new). No patch file is kept in this directory.
