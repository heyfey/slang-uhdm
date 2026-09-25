# r11u158 — the expression/parameter ground of the strict axis: the hier_path decode landed, and eight laws

Base `75226e07` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/ParamEmit.cpp`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or `include/`. The faces whose fix sits there stop at the decode (section "Sister-ground faces").
Net binding is not touched. The laws of passes 140/145/147/154, r11u151 and the r11u141/149/153/154v/159 refinements
are not edited. Worktree `/tmp/wt_r11u158`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base, byte-identical to the main tree's `build/slang-uhdm`) | `2aa918616ddb54c5502f85f387b3e4f7` |
| law (this patch; `law6` in the scratch naming) | `9bcd87116e9ecb02cde0473c81e451ca` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |
| pristine built with `-g1` (gdb pins only) | not a gate binary |

Every binary was frozen (`chmod 555` copies) before it was measured. The pristine sweep (`/tmp/r11u158_swP`) and the
law sweep (`/tmp/r11u158_swL`) have workdir names of the same length. In the law sweep, all 3273 corpus `cmds.txt`
slang lines name the law copy. The pristine sweep reads `regressions=0 conversions=0 changes=0` in all three stages
against the committed baselines, and its `probe.csv` is byte-identical to `results/golden_probe.csv`
(evidence/sweep_pristine_vs_baselines.txt). Its only red is `law index STALE`, which comes from this worktree's
sources. The regenerated tests/LAWS.md in this patch fixes it.

**The fence.** No binary, gdb run, script or reader touched a slang-fenced test's source or database outside the
gate sweeps. The firing census (drivers/census.sh) refuses to run without `$FENCED`. It runs the harness with
`--filter '^(?!(<the four>)$)'`, so no fenced row is dispatched ("fenced mentions: 0" in its output). The row
readers drivers/heads.sh, rowdump.sh, moverdiff.sh and predict.py refuse to run without `$FENCED` and skip fenced
names. None of the scratch copies of corpus sources used for decoding (StructUnsizedVal, SimpleConstraint,
MultirangesStartNotFromZero) is one of the fenced four.

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 848 | **855** | +7 |
| uhdm2rtlil strict-equal (of 1606) | 1502 | **1508** | +6 |
| probe EQUAL (of 4087) | 2514 | **2528** | +14 |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | 0 of 871 verdicts differ from the pristine sweep and from results/downstream_uhdm2rtlil.csv |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them).** These are the
fresh csv rows (evidence/sweep_law_vs_baselines.txt):

    surelog:
      EnumVar,default,CMP_EQUAL,,,equal                         § enumAliasEndAtDimOrInitDecl158
      EnumVar,testflags,CMP_EQUAL,,,equal                       (same)
      HierPathStructTypespec,default,CMP_EQUAL,,,equal          § pkgFoldLeftParenSpan158
      HierPathStructTypespec,testflags,CMP_EQUAL,,,equal        (same)
      LocalScopeHierPath,default,CMP_EQUAL,,,equal              § foreachArrPathVarForm157
      SimpleConstraint,default,CMP_EQUAL,,,equal                § methodRandomizeCallSpan158
      SimpleConstraint,testflags,CMP_EQUAL,,,equal              (same)
    uhdm2rtlil:
      MultirangesStartNotFromZero,default,CMP_EQUAL,,,equal     § genCaLhsEnumConstClone158
      MultirangesStartNotFromZero,testflags,CMP_EQUAL,,,equal   (same)
      expr_width_cast,default,CMP_EQUAL,,,equal                 § hpSelRoute157 (size-cast width = SEL)
      expr_width_cast,testflags,CMP_EQUAL,,,equal               (same)
      portsel_struct_param,default,CMP_EQUAL,,,equal            § hpSelRoute157
      portsel_struct_param,testflags,CMP_EQUAL,,,equal          (same)
    downstream (fresh rows of the law sweep, all IDENTICAL as before):
      expr_width_cast,IDENTICAL,NO_GATES,NO_GATES,0,0,,
      MultirangesStartNotFromZero,IDENTICAL,NO_GATES,NO_GATES,0,0,,
      portsel_struct_param,IDENTICAL,OK,OK,1,1,,

**Probe: 14 cases go `STRICT_NOTEQUAL -> EQUAL`.** Each reads `EQUAL,,equal` in the fresh probe.csv:
* § thisPathFormByPosition157: `r10uvm84repro/ast84`, `g84_a2_parens`, `g84_e1_positions`, `v84x2_incdec`,
  `r10uvm85repro/g85_a1_builtin`, `g85_a7_pos`, `v85x1_kinds`, `r10v125repro/v2_faces`,
  `r10vbuvm29repro/gv29_a_shapes`. These are the nine the r11u157 decode measured at 4e20e0d5.
* § methodRandomizeCallSpan158: `r10uvm119repro/g119_b`, `r10uvm77repro/v77x1_randwith`, `r10v116repro/v116_q`,
  `r10v119repro/v119_k`, `r10v151repro/v151_4_nonarray`.

**Targeted rows (brief items), before -> after:**

| row | before | after | law / what is left |
|---|---|---|---|
| (1) LocalScopeHierPath d / t | file(3) / file(4) | **CMP_EQUAL** / fullname(1) | § foreachArrPathVarForm157. t: the `foreach (path.slices[j])` loop variable `j` is named through the path in golden (`...::path.slices[j].spath::j`), residue 6 |
| (1) expr_width_cast d/t | col(12) | **CMP_EQUAL** | § hpSelRoute157 |
| (1) portsel_struct_param d/t | col(4) | **CMP_EQUAL** | § hpSelRoute157 |
| (1) mem_ff_partial_rsp d/t | CMP_EQUAL (pass 154, § lvIdxPathIsRead154) | CMP_EQUAL, bytes unchanged | the route law gives the same answer as pass 154's legacy flag, which is kept as the flag the route refines (section "Landing the r11u157 decode") |
| (1) ComplexHierPath d / t | col(10) / col(8) | col(7) / col(7) | § genTgtLhsLeafOwnName157 (the only law that fires there). The rest is R1: the definition-view gen-scope path, TypeEmit `emitSyntaxExpr`, sister |
| (1) SVSwitch d/t | endcol(27) | fullname(11) (32 records leave, 0 enter) | § thisPathFormByPosition157 + § methodRandomizeCallSpan158 (`pkt.randomize()`). Left: R8 `new[bytes.size]`, a class_typespec file (sister) |
| (1) StructParamFuncBodyFieldCompare, StructParamPatternInitCast d/t | fullname(15) | fullname(11) | § hpSelRoute157 (pattern member value = CFC) |
| (1) CovMacro d/t | endcol(118) | endcol(118) (16 records replaced by 16) | § rootPathOwnNames157 moves `$root` to the next component's token. Golden holds that token in the macro BODY's coordinates (R7) |
| (2) EnumVar d/t (R-EV, N0844 + N0851) | endline(3) | **CMP_EQUAL** | § enumAliasEndAtDimOrInitDecl158 |
| (2) MultirangesStartNotFromZero d/t (N0831 + N0843) | file(2) | **CMP_EQUAL** | § genCaLhsEnumConstClone158 |
| (2) SimpleConstraint d/t (R6) | endcol(2) | **CMP_EQUAL** | § methodRandomizeCallSpan158 |
| (3) the size cast assigned straight to an output (`assign p = SEL_W'(3)`) | **DIVERGENT downstream** on pristine, uhdm-cmp NOT_EQUAL | **IDENTICAL downstream**, STRICT_EQUAL | § sizeCastCaLitMask158 + § sizeCastCaSignedSize158 (grid `sc`, 17 cases: 5 DIVERGENT and 5 EQUIVALENT -> IDENTICAL, evidence/downstream_sc_grid.txt) |
| (5) HierPathStructTypespec d/t (N0010) | col(1) | **CMP_EQUAL** | § pkgFoldLeftParenSpan158 |
| (5) HighLow d/t (N0822) | line(5) | value(1) (8 records leave) | § arrQueryFoldAtBound158. Left: the `assign ccc = $high(a)` value on an implicit net, ModuleEmit (sister S1) |
| (5) LargeValue2Struct d/t, StructUnsizedVal d/t (N0005) | endcol(5) / endcol(3) | fullname(4) / fullname(2) | § aggParamFoldUnqualWholeSpan158. Left: the member names of the parameter's typespec copy (R-SP, residue 2) |
| (5) N0063 iface_* | CMP_EQUAL (pass 154) | CMP_EQUAL | confirmed |
| (5) N0357 jeras_tcb_gpio | CMP_EQUAL (pass 154) | CMP_EQUAL | confirmed |
| (4) r11u159 R2 StringMethod d/t | CMP_EQUAL at the base (pass 154) | CMP_EQUAL | confirmed |
| (4) r11u159 R3 iface_struct_field_partsel d/t / anon_struct_packed_dim d/t | CMP_EQUAL (pass 154) / fullname(43) | same | anon_struct_packed_dim is TypeEmit buildStructTs (pass 154 residue 3), sister |
| (3)/(5) InterfArrayBind d (N0427) | fullname(3) | fullname(3) | not reached: the default view's interface-array element index name needs the elaborated default view (pass 154 residue 1a) |
| (4) r11u159 S1 GenForIface*, S3 genscope_module_ctx_reset | CMP_EQUAL at the base (pass 155) | CMP_EQUAL | confirmed. The rows are absent from the base fail list |

## Landing the r11u157 decode (question 1)

`tools/probe/r11u157hp/law.patch` (base 4e20e0d5) applies to 75226e07 with four rejected hunks. All four sit where
pass 154 changed the legacy flags: `lhsM154` (§ lvIdxPathIsRead154) in the member-access branch, and `lhsT154`
(§ lvIdxPathIsRead154 + § psBoundPathFirstMember154) in the interface/hierarchical branch. Both sides are kept by hand:
* member-access branch: `legacyLv157 = lhsM154 || paramInitStructMember || incDecLv124` (was `inLhs || ...`). The base
  anchor reads `selSpan157 || thisSpan157`. The leaf name reads `scoped157`, the r11u157 rule, on top of that
  legacy flag;
* interface/hierarchical branch: `lhsT154` is computed once before the loop, as the legacy value of
  `selSpan157`/`selName157`. The route overrides it only where it decides. The element loop reads `selName157`
  (leaf name) and `selSpan157` (base anchor).

The six laws, their per-law switches and the axis switches (`R11U157_SPAN_OFF`, `R11U157_NAME_OFF`,
`R11U157_FILE_OFF`, `R11U157_OFF`) are kept verbatim. This pass adds one thing to them: a census trace
(`R11U157_TRACE=1` prints `R11U157 law THIS|FOREACH|ROOT|GENTGT|WITHRECV`), which writes no byte. The decode, the
route table and the gdb instrument are in tools/probe/r11u157hp/README.md.

Re-measured on the current baselines, by laws alone (the law binary without the r11u158 laws: `law2`, sweep
`/tmp/r11u158_swA`): probe 9 conversions / 22 changes / 0 regressions; surelog LocalScopeHierPath d converts;
uhdm2rtlil expr_width_cast and portsel_struct_param convert in both modes. mem_ff_partial_rsp was converted by pass
154 and stays byte-identical (`lvIdxPathIsRead154` and the route agree on the select index). The 157 grid
(tools/probe/r11u157hp/cases, 57 cases) against the current base: 7 cases turn STRICT_EQUAL (c11, k01, k03, k10, k11,
k14, t03), q01 moves from endcol to col (the R1 def-view residue), and no case gets worse. The cases are copied into
`cases/hp/` with their law named on the first line.

## Laws (each under its own switch; `R11U158_OFF=1` drops all of them; `R11U158_TRACE=1` prints one stderr line per firing)

Sites are named by function and § token (`grep -n '§ <law>' src`). The switch table is the r11u158 block at the end of
src/EmitHelpers.h.

### § hpSelRoute157, § thisPathFormByPosition157, § foreachArrPathVarForm157, § rootPathOwnNames157, § genTgtLhsLeafOwnName157, § withRecvOnlyLastScoped157 (R11U157_ROUTE_OFF / _THIS_OFF / _FOREACH_OFF / _ROOT_OFF / _GENTGT_OFF / _WITHRECV_OFF; ExprEmit.cpp)
The r11u157 decode, landed as delivered. Surelog writes a plain dotted path in compileSelectExpression (SEL) or
compileComplexFuncCall (CFC), and the grammar position of the path picks the writer. The three `this.` forms, the
`foreach` array variable, the `$root` branch, the plain gen-block target and the `with`-receiver loop complete the
family (tools/probe/r11u157hp/README.md sections 2 and 4). Cases: `hp/c11_param_binop` (§ hpSelRoute157, plus the
controls `hp/c07_lhs_index`, `c08_rhs_index` and `c19_funcarg`); `hp/k01_this_rhs`, `k03_this_cond`,
`k11_display_arg`, `k14_this_incdec` and `t03_mixed` (§ thisPathFormByPosition157, plus the control `hp/k02_this_lhs`);
`hp/k10_foreach_member` (§ foreachArrPathVarForm157); `hp/q01_gen_plain_lhs` (§ genTgtLhsLeafOwnName157, plus the
control `hp/q02_gen_array_lhs`). Gate probe cases: `r11u82repro/grid/v3_rootpath` (§ rootPathOwnNames157, col(20) ->
col(16)); `r10uvm175repro/g175_a_pos`, `g175_f_fence`, `r10v175repro/v175_deep`, `v175_scope`
(§ withRecvOnlyLastScoped157, file counts down).

### § enumAliasEndAtDimOrInitDecl158 (`R11U158_EVALIASEND_OFF`; ParamEmit.cpp emitPackage, the enum-alias clone block)
A package enum-typedef ALIAS clone (`typedef enum_t alias_t;`) that a module variable uses keeps the TARGET typedef's
declaration span when the variable's declarator is bare. Golden EnumVar `pkg::alias_t b;` spans the clone 2:14-2:57,
the `typedef enum ... enum_t;`. The end moves to a declarator with an unpacked dimension or an initializer, and to
the LATER of two such declarators (`b [2], c = pkg::ONE` -> the end of `c = pkg::ONE`; two declarations -> the second).
A bare use still doubles the reference scoping and parents the clone at the package. Ours moved the end to the
first direct use's declarator. Cases: `ev/e02`, `e04`, `e08`, `e13`, `e18`, and `e15` (a hidden fullname face stays).
Controls: `ev/e06`, `e10`, `e11`, `e12`, `e17`, `e19`. `ev/e16` (`b [2], c = pkg::ONE` in ONE declaration) stays:
another writer puts the end back on `b [2]` (residue 7). `ev/e03`, `e07` and `e14` keep a scoping fullname face.

### § genCaLhsEnumConstClone158 (`R11U158_GCALHSENUM_OFF`; ExprEmit.cpp emitExpr's NamedValue binder, EmitHelpers.h genCaLhsCtx158)
An enum-constant reference on the LEFT side of an elaborated generate-scope continuous assignment binds a fresh
loc-less `enum_const` (name, value, size, the plain decimal decompile), as the right side's mint does
(§ genCaEnumBindsSelectOnly22). Golden MultirangesStartNotFromZero `assign io_fwd_link_li[i][e_e:w_e] = ...` in
gen_cmd_link has both bounds loc-less. Surelog resolves both sides through UhdmWriter::lateBinding. Ours bound the
located shared constant. The gate: the nearest cont_assign ancestor is parented at a gen_scope. Cases: `gl/l1`, `l2`,
`l3`, `l5`, `l7` (package / module enum, gen-for / gen-if / nested, part-select / bit-select, child instance). Control:
`gl/l6` (module level). `gl/l4` (an indexed part-select target) keeps a separate span face (residue 5).

### § sizeCastCaLitMask158 (`R11U158_SCLITMASK_OFF`; ExprEmit.cpp tryFoldConst)
A size cast that is a continuous assignment's WHOLE value folds, when its operand is a literal or an operator tree
over literals and names (anything but a bare name), to the operand's bits masked to the cast width, as UINT, at the
assignment's width. Golden (logic [3:0] p): `2'(3)` -> UINT:3; `SEL_W'(3)` -> UINT:3; `2'(7)` -> UINT:3. Golden into
logic [7:0]: `2'(-1)` -> UINT:3; `2'(3 + 4)` -> UINT:3; `2'(V + 0)` -> UINT:3; `2'(-V)` -> UINT:1. Surelog's netlist
elaboration reduces the operand unsigned and keeps the cast's low bits. Ours folded the LRM value: a signed 2-bit -1
that the assignment sign-extends to UINT:15, or INT:-1 at the cast width. The downstream plugin read that as
`4'1111` (DIVERGENT), or as a `$pos` cell (EQUIVALENT). A cast 64 bits or wider and parameter folds are not touched.
Cases: `sc/c1`, `c2`, `c3`, `c4`, `c6`, `c13`, `c14`, `c15`, `c16`. Controls: `sc/c5`, `c7`, `c9`, `c11`, `c17`.
`sc/c10` (a gen-if scope) and `sc/c12` (a child instance with an overridden width) are residues (sister S2, S3).

### § sizeCastCaSignedSize158 (`R11U158_SCSIGNSIZE_OFF`; ExprEmit.cpp tryFoldConst, the signed size-cast branch)
The signed branch's constant (`2'(V)` with `int V = 7` -> INT:-1) takes the continuous assignment's width. Golden
`assign p = 2'(V)` (logic [3:0] p) is INT:-1 size 4. Ours had size 2, which the plugin zero-extends through a `$pos`
cell (`4'0011`, DIVERGENT). It applies to a bare-name operand only, the measured shape. Case `sc/c8`.

### § pkgFoldLeftParenSpan158 (`R11U158_PKGLPAREN_OFF`; ParamEmit.cpp emitParameters, the elaborated package computed fold)
The elaborated package listing locates a computed parameter's fold at its left operand, and a PARENTHESIZED left
operand keeps its parentheses. Golden HierPathStructTypespec `BufferCycles = (Sha3Latency + RegLatency -
1)/RegLatency` is 10:34-64, and `((A - 1)) / B` spans both pairs. slang's operand range drops them. The range is read
from the binary expression's own syntax. Cases: `pp/p1`, `p2`, `p3`. Control: `pp/p4`.

### § arrQueryFoldAtBound158 (`R11U158_ARRQRYLOC_OFF`; ParamEmit.cpp emitParameters + arrQueryBoundLoc158)
A folded `$high(a)` / `$low(a)` / `$left(a)` / `$right(a)` parameter value is located at the written range bound it
resolves to. Golden HighLow (`parameter [2:1] a`) gives `$high` 6:14-15 (the `2`) and `$low` 6:16-17 (the `1`). A
`[1:2]` range swaps them. The rule holds through an overridden parameter's declaration too (`$high(A)`, `[3:0] A`:
the `3`). The law abstains unless both bounds are integer literals. Cases: `hl/h1`, `h2`, `h7`. `hl/h3` (a symbolic
bound) and `hl/h4`, `h5`, `h6`, `h8` are NOT_EQUAL at stage 1 on both binaries (residue 8).

### § aggParamFoldUnqualWholeSpan158 (`R11U158_AGGUNQSPAN_OFF`; ExprEmit.cpp emitExpr, the aggregate package-parameter default fold)
A struct/union package parameter read in a parameter default is folded to its value. The folded value is located
at the package qualifier (`pkg::`) only when the reference is QUALIFIED. An unqualified read (a wildcard import)
spans the whole identifier in golden: StructUnsizedVal `Init = InitDefault` 17:53-64, LargeValue2Struct 23:52-79.
Ours measured a qualifier that is not written (the package name + 2: 17:53-58, gdb pin on the -g1 pristine,
emitExpr < emitParameters < emitInstance). Cases: `uq/u1`, `u3`, `u5` (the span record leaves; the member-name face
of residue 2 stays). `uq/u2` (qualified) and `u4` are NOT_EQUAL at stage 1 on both binaries.

### § methodRandomizeCallSpan158 (`R11U158_RANDSPAN_OFF`; ExprEmit.cpp emitExpr, the method-call hier_path)
A member `randomize()` call's hier_path runs through the call's parentheses. Golden SimpleConstraint
`frame.randomize()` is 57:12-29, ours was 57:12-27, because slang's built-in randomize call range stops at the name.
Surelog populates the path from the whole complex_func_call node. The range is read from the call's own syntax.
Cases: `rz/r1`, `r2`, `r4`. `rz/r3` (`randomize(a)`) is NOT_EQUAL at stage 1 on both binaries.

## Census (the predictions) and the movers

The census (drivers/census.sh + tracewrap.sh) ran on the law binary BEFORE the law sweep, through the harness, with
the fence filter. It predicts **319 names**: 64 surelog row-modes, 76 uhdm2rtlil row-modes and 179 probe cases, each
listed with the laws that fired on it (evidence/predicted_movers.tsv).

Byte verifier (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law `/tmp/r11u158_swL` against pristine
`/tmp/r11u158_swP`, names of the same length):

| stage | paths | selfcheck | movers | predicted | unpredicted |
|---|---|---|---|---|---|
| surelog | 960 identical sets | 959/960 | 36 | 34 | **2: EnumVar d/t** |
| uhdm2rtlil | 1608 identical sets | 1607/1608 | 11 | 11 | 0 |
| probe (md5 of every database) | 4087 | — | 62 | 62 | 0 |

The two unpredicted movers are an honest miss of the census. § enumAliasEndAtDimOrInitDecl158's trace sits on the
stretching branch (a dimension or an initializer). EnumVar moves on the other branch, the bare declarator, which
prints no trace. Its record diff attributes it to that law alone: the 6 endline/endcol records of the alias clone
leave, which is the shape of grid `ev/e02`. No other law touches an enum-alias span.

Every mover was attributed record by record. drivers/moverdiff.sh collects the strict comparator's full
differing-record set of the pristine and the law database against the same golden
(evidence/corpus_movers_records.txt, evidence/probe_movers_records.txt):
* corpus: 47 movers. 0 records enter on 45 of them. **CovMacro d/t: 16 leave, 16 enter**, same first field and same
  count (endcol(118)). § rootPathOwnNames157 anchors `$root` at the next component's token as golden does (12:82-85,
  was its own token 12:76-81), but golden holds that token in the MACRO BODY's coordinates (12:48-51, R7 of the
  decode). The leaf's name record leaves (fullname -> col on #108). Record-neutral movers are the UVM family
  (BuildUVMPkg, MiniAmiq, Scoreboard d, SeqDriver, SimpleUVM), BlackBePipeInt, mem_read_reg d/t and
  struct_param_func_config d/t. Each lies wholly past its row's walk divergence (`walk diverged` on both binaries),
  and each is a predicted law mover (THIS/FOREACH/WITHRECV/RANDSPAN/CFC, CFC/SEL/PKGLPAREN, CFC, AGGUNQSPAN), not
  the UINT/vpiDecompile coin.
* probe: 62 movers, 0 records enter, 4 record-neutral (`r10uvm37repro/t51a`, `r11u20repro/t5`, `r11vu13repro/v4`,
  `v9`). The 44 probe CHANGEs are first-field moves or count decreases. The laws are 31 r11u157 changes, 20
  § aggParamFoldUnqualWholeSpan158 (the pk/f2 grids of r11u108/r11u111/v11u111: the span record leaves and their
  fullname residue shows), 1 § pkgFoldLeftParenSpan158 (`r10earl76repro/g2_orig76` col(16) -> fullname(13), 6
  leave) and 1 § methodRandomizeCallSpan158 (`r10v116repro/v116_u` endcol(2) -> endline(1): the endline record was
  there before, behind the endcol one; 2 leave, 0 enter).

## Gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `2aa91861…` = main tree; law `9bcd8711…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=14, changes=44; EQUAL 2528 STRICT_NOTEQUAL 1559, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 7 + 6; changes 15 + 0 (every change is a record decrease or a first field moving later: evidence/corpus_movers_records.txt) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; not identical and not excused=0; 0 of 871 verdicts differ from the pristine sweep |
| (5) uhdm-cmp on touched rows | every mover keeps CMP_EQUAL or STRICT_NOTEQUAL (judge-equal); 0 regressions in all three stages |
| (6) byteverify | 36 + 11 corpus movers, 62 probe movers: all attributed, 45 of 47 corpus movers predicted by name (above) |
| canaries | r11u107repro/canaries.sh: surelog ok=48 changed=4 (SVSwitch d/t, SimpleConstraint d/t: attributed above), uhdm2rtlil ok=14 changed=2 (MultirangesStartNotFromZero d/t); ctcan2.sh EXPECT_UNKNOWN=1 surelog ok=58 changed=0 PASS, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2 changed=0 PASS |
| cases | 74 cases (evidence/grid_pristine_vs_law.txt): 36 go to STRICT_EQUAL (26 from STRICT_NOTEQUAL, 10 from NOT_EQUAL at stage 1), 18 are equal on both (controls), 20 stay (residues named above), and no case loses judge-equality |
| switches | each switch alone returns exactly its own cases to the pristine verdict (evidence/switches.txt) |
| `R11U157_OFF=1 R11U158_OFF=1` | 131 of 131 cases (these 74 + the 57 r11u157 grid cases) byte-identical to pristine (evidence/offbytes.txt) |
| downstream grid | `sc` 17 cases through the harness: c1-c4 and c8 DIVERGENT -> IDENTICAL; c6, c13, c14, c15 and c16 EQUIVALENT -> IDENTICAL; c10 EQUIVALENT and c12 DIVERGENT unchanged (sister); the rest IDENTICAL on both (evidence/downstream_sc_grid.txt) |

## Sister-ground faces (decoded; the fix sits in a file this pass does not own)

S1 — HighLow d/t `value(1)`: `assign ccc = $high(a);` onto an IMPLICIT net. Golden's elaborated Rhs is a loc-less
constant UINT:2 (size 0, const type 0); ours is UINT:0, the fold truncated to the implicit net's one bit. Site:
ModuleEmit.cpp emitContAssigns, the `$signed/$unsigned/$high/$low/$left/$right` sysFold block (`qry9`, before the
"implicit-net LHS cont_assign shares the DEF-view object" block and `implNetComputedFold9`).

S2 — `sc/c10`: a size cast of a negated literal in a gen-if scope (`assign q = 3'(-1)`). Golden folds it to UINT:7 at
the target width, and ours keeps the cast operation. The gen-scope cont_assign's fold decision is ModuleEmit.cpp's
emitBlock gen-CA branch, which calls tryFoldConst only under genCaLoopParamFold and its siblings.

S3 — `sc/c12`: `assign p = W'(7)` in a child whose `W` an instance overrides (3). Golden gives the overriding instance
UINT:7, and ours gives UINT:3: the fold reads the definition's width. The elaborated cont_assign fold in ModuleEmit
emitContAssigns (`tryFoldConst(ae.right())`) gets the expression bound in the default specialisation.

S4 — `assign #d b = a, c = ~a` (r11u159's residue 2): the delay is attached per net assignment by ModuleEmit.cpp
emitContAssigns (the `emitAssignDelay(caSyn9->delay, ...)` call). Golden attaches it to the first assignment only.

S5 — the rc 134 abort on an escaped name containing `#`: an uncaught std::runtime_error thrown by
Compilation::parseName inside Scope::lookupName, called from ModuleEmit.cpp mintUnitEnumNets (pass 154's S7). A
`Scope::find` there, or a top-level catch in uhdm_main.cpp, is pair B's.

S6 — iface_param_port_width d/t `fullname(2)`: the interface port view's parameter and its ref_typespec are named
by the definition (`work@bus_if.DATA_WIDTH`) in golden, and by the port path (`work@top.m0.bus.DATA_WIDTH`) in
ours. They are minted by the ModuleEmit port-view builder.

S7 — the def-view generate-scope hier_path (R1 of r11u157): ComplexHierPath's remaining col(7) and the grid q01.
TypeEmit.cpp emitSyntaxExpr.

S8 — N0739 ComplexParamOverload and MacroArgMismatch / YosysMarlann: decoded by pass 154 (ModuleEmit emitContAssigns;
the UhdmExporter column model). Not re-opened here.

## Decoded, not landed (ranked residues on this ground)

1. R2/R3 of r11u157: mixed paths with a component select in an rvalue, and the index of a hier_path component.
   They are not routed. Left untouched in the UVM rows.
2. R-SP (ParamEmit makeParamTs): the member names of a value parameter's struct typespec copy (StructUnsizedVal
   `work@dut.pkg::init_t.key` in golden, `work@top.d.Init.pkg::init_t.key` in ours; LargeValue2Struct, the uq cases,
   struct_param_pattern_packing, StructParamFieldRange, cva6_struct_param_field). After
   § aggParamFoldUnqualWholeSpan158 this is StructUnsizedVal's and LargeValue2Struct's only face.
3. N0003 + N1132 ParamNoImport: the package pattern parameter's operation carries a ref_typespec named `pkg` in ours,
   empty in golden. The instance override shares the package's operation, where golden holds a copy whose
   ref_typespec is named by the instance (`work@dut.t`). A copy at the instance override (ParamEmit
   emitParameters / ExprEmit's package-parameter substitution) plus the empty package name.
4. N0472 type_param_override_elem_sel / param_array_wildcard: a reference in a localparam type's dimension (or a
   value parameter's unpacked dimension) is named through the DEFINITION in golden (`work@child.rt_t.DEPTH`) and
   through the instance in ours (`work@dut.u.rt_t.DEPTH`). No distinguisher decoded yet against the many
   instance-named bounds the gate holds. param_array_wildcard's walk also diverges earlier (array_typespec).
5. `gl/l4`: the indexed part-select target of a generate cont_assign spans the whole select in golden (`o[B +: 4]`
   5:12-21) and only the range in ours (5:14-20).
6. LocalScopeHierPath t: the `foreach (path.slices[j])` loop variable is named through the path in golden.
7. `ev/e16`: two alias declarators in one declaration (`b [2], c = pkg::ONE`): after the law's own writer, another
   writer puts the end back on the unpacked declarator.
8. `hl/h3`: `$high` of a symbolically bounded parameter is stage-1 different (INT against UINT) on both binaries.
9. N0016 FuncIoTypespec `file(9)`: a function-local parameter read in a function variable's range mints an
   implicit net with no file in golden, in the ELABORATED top view too. § implicitNetMintNoFile131 clears the
   definition view only. It needs a def-vs-elab grid before its gate widens (ParamEmit's end-of-export pass).
10. R6 remainder: `iq.sum() with (item)` (one column short) and `bc.gn(t.gt())`. R7 (paths in macro bodies,
    CovMacro). R8 (`new[x.size + 4]`). R9 (`this.h.v`, `super`).

## Cases (first line of every case names its law; pristine / law verdicts in evidence/grid_pristine_vs_law.txt)

| grid | cases | law | pristine -> law |
|---|---|---|---|
| hp | c11_param_binop | § hpSelRoute157 | col -> STRICT_EQUAL |
| hp | c07_lhs_index c08_rhs_index c19_funcarg | § hpSelRoute157 (controls) | equal -> equal |
| hp | k01_this_rhs k03_this_cond k11_display_arg k14_this_incdec t03_mixed | § thisPathFormByPosition157 | endcol -> STRICT_EQUAL |
| hp | k02_this_lhs | § thisPathFormByPosition157 (control) | equal -> equal |
| hp | k10_foreach_member | § foreachArrPathVarForm157 | file -> STRICT_EQUAL |
| hp | q01_gen_plain_lhs | § genTgtLhsLeafOwnName157 (R1 stays) | endcol -> col |
| hp | q02_gen_array_lhs | § genTgtLhsLeafOwnName157 (control) | equal -> equal |
| ev | e02 e04 e08 e13 e18 | § enumAliasEndAtDimOrInitDecl158 | endline/endcol -> STRICT_EQUAL |
| ev | e15 | § enumAliasEndAtDimOrInitDecl158 | endline -> fullname |
| ev | e06 e10 e11 e12 e17 e19 | § enumAliasEndAtDimOrInitDecl158 (controls) | equal -> equal |
| ev | e03 e07 e14 e16 | § enumAliasEndAtDimOrInitDecl158 (residues) | unchanged |
| gl | l1 l2 l3 l5 l7 | § genCaLhsEnumConstClone158 | file -> STRICT_EQUAL |
| gl | l6 | § genCaLhsEnumConstClone158 (control) | equal -> equal |
| gl | l4 | § genCaLhsEnumConstClone158 (residue 5) | col -> col |
| sc | c1 c2 c3 c4 c6 c13 c14 c15 c16 | § sizeCastCaLitMask158 | NOT_EQUAL (stage 1) -> STRICT_EQUAL |
| sc | c5 c7 c9 c11 c17 | § sizeCastCaLitMask158 (controls) | equal -> equal |
| sc | c10 c12 | § sizeCastCaLitMask158 (sister S2, S3) | NOT_EQUAL -> NOT_EQUAL |
| sc | c8 | § sizeCastCaSignedSize158 | NOT_EQUAL (stage 1) -> STRICT_EQUAL |
| pp | p1 p2 p3 | § pkgFoldLeftParenSpan158 | col -> STRICT_EQUAL |
| pp | p4 | § pkgFoldLeftParenSpan158 (control) | equal -> equal |
| hl | h1 h2 h7 | § arrQueryFoldAtBound158 | line/col -> STRICT_EQUAL |
| hl | h3 h4 h5 h6 h8 | § arrQueryFoldAtBound158 (stage-1 residues) | NOT_EQUAL -> NOT_EQUAL |
| uq | u1 u3 u5 | § aggParamFoldUnqualWholeSpan158 | endcol/endline -> fullname (R-SP stays) |
| uq | u2 u4 | § aggParamFoldUnqualWholeSpan158 (stage-1 residues) | NOT_EQUAL -> NOT_EQUAL |
| rz | r1 r2 r4 | § methodRandomizeCallSpan158 | endcol -> STRICT_EQUAL |
| rz | r3 | § methodRandomizeCallSpan158 (stage-1 residue) | NOT_EQUAL -> NOT_EQUAL |

## Ops notes (disclosed)

* Six law binaries were built in turn (law1 = the r11u157 law alone, law2 + EV/GCALHSENUM, law3/law4 + the size-cast,
  paren, $high and unqualified-span laws, law5 + RANDSPAN, law6 + census traces). One build failed to compile
  (law3's first attempt). The binary copied under its name at that moment was the previous one; it was deleted
  before any measurement, and law3 was rebuilt. Full sweeps: pristine, law2 (`swA`), law4 (`swB`) and law6
  (`swL`, the gate). Each read regressions=0.
* The first cut of § sizeCastCaLitMask158 matched literals only, and its companion size law applied to every signed
  operand. The break grid then found `sc/c14` (`2'(3 + 4)`) moving from EQUIVALENT to DIVERGENT downstream, which
  pristine was right on. Golden treats an operator tree like a literal (`2'(V + 0)` -> UINT:3, `2'(-V)` -> UINT:1),
  and only a bare name keeps the signed branch. The laws were narrowed to that measurement (law4) and every grid and
  gate re-run.
* The -g1 pristine (`/tmp/r11u158_gsrc`, a `git archive` of the base) served one gdb pin (the StructUnsizedVal span).
* No process I did not start was touched.

## Files

* drivers/grid.sh (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), gridall.sh, switches.sh, offbytes.sh.
* drivers/census.sh + tracewrap.sh (the firing census, fence-filtered), predict.py (the predicted mover set).
* drivers/heads.sh, rowdump.sh, moverdiff.sh (fence-guarded row readers), pdiff.sh (probe case record diff).
* evidence/: the files named above.
