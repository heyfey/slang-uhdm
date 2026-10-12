# r11u303 — module/type ground: generate-block port actuals, module-array bounds, syntax-view system calls, generate-scope net cells, class value parameters and interface fill branches

Base 368d0810 (pass 301). Ten laws in ModuleEmit, TypeEmit and UhdmExporter behind `src/R303.h`. Each law reads its
own `R11U303_<LAW>_OFF` switch. `R11U303_OFF` drops all of them and gives pristine's bytes and exit code on 232 of
232 grid case-views. `R11U303_TRACE=<dir>` logs the firings (one file per process, `OUT <-o path>` first, then
`<law> <detail>`; `IFTERNFILL303_ABSTAIN` names the interface law's abstentions).

**EIGHT PROBE CONVERSIONS**, one shrinking change, no regression. No corpus row changes status or strict column.

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r10vrgg14repro/cells/v5 | `differ:name(14)` | **EQUAL** | § genConnSelBaseNameTrim303 |
| r11u52vrepro/grid/b2_exprforms | `differ:fullname(2)` | **EQUAL** | § bodyTdBoundSysCallClone303 |
| r11v46repro/grid7 | `differ:fullname(1)` | **EQUAL** | § sysCallArgRefScopedName303 |
| r10earl104repro/vb4_instarr | `differ:fullname(1)` | **EQUAL** | § modArrBoundSelUnstored303 |
| r10earl121repro/a1_axis121 | `differ:endcol(3)` | **EQUAL** | § genCaEnumQualWholeSpan303 |
| r10rgg14repro/cells/pc5 | `differ:depth(1)` | **EQUAL** | § genNdaSelRhsSharesNet303 |
| v11u111repro/brk/f1/x01_class_param | `differ:type(1)` | **EQUAL** | § classParamNamedTypeTs303 |
| r10rgg9repro/cells/c_iface_body | `differ:type(1)` | **EQUAL** | § ifCaTernFillArmKept303 |
| r10earl115repro/p1_pos115 (change) | `differ:endcol(18)` | `differ:endcol(13)` | § genCaEnumQualWholeSpan303 (5 records toward golden, lost 0, chain away 0) |
| probe | EQUAL 3983 + STRICT_NOTEQUAL 104 | **EQUAL 3991 + STRICT_NOTEQUAL 96** | regressions 0, conversions 8, changes 1 |
| surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

Fresh law-sweep probe rows (evidence/sweep_L.txt): each of the eight reads `<case>,EQUAL,,equal`, e.g.
`r10vrgg14repro/cells/v5,EQUAL,,equal`, `r10rgg9repro/cells/c_iface_body,EQUAL,,equal`,
`v11u111repro/brk/f1/x01_class_param,EQUAL,,equal`; `r10earl115repro/p1_pos115,STRICT_NOTEQUAL,differ:endcol(13),differ:endcol(13)`.

## Laws

**§ genConnSelBaseNameTrim303** (`R11U303_SELBASETRIM_OFF`, ModuleEmit helper selBase303). A port actual written with
blanks before its select (`.s (dn [3+2*i])`) is named by its identifier. The definition-view generate connection
branches (bit_select, var_select, indexed_part_select, part_select), the elaborated interface-array element branch and the
definition view's ref_module interface-array element branch cut the base name off the raw text at the first `[`, so
the name kept the blank (`dn `) and every full name built on it carried it (`work@top.g.a.dn `, the index reference
`work@top.g.a.dn .i`). Surelog names the select from the identifier token. The law trims trailing blanks, tabs and
line breaks off the base. Cases ST (11).

**§ bodyTdBoundSysCallClone303** (`R11U303_BOUNDSYSCLONE_OFF`, TypeEmit copyRangeVec). § bodyTypedefElemBoundSymbolic52's
per-reference bound clone modelled constants, references and operations only, so a bound holding a system call
(`typedef logic [$clog2(N)-1:0] t [D]`) was shared with the definition copy, its argument reference unnamed. Surelog
compiles the element typespec afresh per reference: each copy owns the call and the argument reference, scoped
through the typedef name (golden `t_clog.N`). The cloner now copies a system call whose arguments are themselves
modelled. Cases BS (11).

**§ sysCallArgRefScopedName303** (`R11U303_SYSARGNAME_OFF`, TypeEmit emitSyntaxExpr's system-call argument fallback).
A bare identifier argument of a system call inside a definition-view generate statement (a gen-for initial value,
condition or step, a gen-if or case condition, a generate-block cell) takes the scope's full name like any other
reference of the expression (golden `for (genvar ce = $unsigned(MM); ...)` MM `work@cell7.MM`, as the siblings
`cb = MM` and `cf = unsigned'(MM)` already were). Gated on underDefGen161: a typedef or parameter range bound keeps the
unstored name its chain gives (a draft without the gate moved probe r11u5repro/g2 and r11u35repro/grid/g3_shape35
away, both EQUAL at the base). Cases SA (15).

**§ modArrBoundSelUnstored303** (`R11U303_MODARRSELNAME_OFF`, ModuleEmit emitModuleArray). In an ELABORATED module
array's dimension bound a select (bit, part, indexed part or variable select, also under an operation) stores no
full name: compileInstantiation compiles the bound afresh with the instance as scope and compileSelectExpression
writes none (golden `sub u [X[0]:0]` bit_select `X` unnamed, ours `work@...u_ia.X`). The definition view keeps the
name through the array (§ modArrayBoundRefArrayPath146). An interface array's elaborated view lists no ranges.
Cases MA (13).

**§ modArrBoundIpsWholeSpan303** (`R11U303_MODARRIPSSPAN_OFF`, same site). An indexed part select written as a module
or interface array's dimension bound (`[X[1+:2]:0]`) spans the whole select in both views (golden 9:13-9:20, ours the
selector 9:15-9:19). Cases MA m04, m13, m14 (m04 and m13 move only with this law and the previous one together).

**§ genCaEnumQualWholeSpan303** (`R11U303_GENCAENUMSPAN_OFF`, TypeEmit emitSyntaxExpr's ScopedName package-enum
substitution). The substituted enum constant is located at the qualifier `pkg::` in a generate CONDITION
(compileGenStmt -> compileExpression's paPackage_scope branch; Surelog's EnumConstConcat), but inside a definition-view
generate continuous assignment the member value is compiled by compileStmt's expression writer, which locates the
folded constant on the whole `pkg::NAME` (golden `m_enum: p121::OpB` 76:29-76:38, ours 76:29-76:35). The law reads
the parent chain: a cont_assign under a definition-view generate statement before any generate statement or
instance. Plain, concatenation, operation, `?:` branch, pattern member and default-key right sides. Cases EP (13).

**§ genNdaSelRhsSharesNet303** (`R11U303_GENNDASEL_OFF`, ModuleEmit emitGenScopes net-declaration cell) and
**§ genNdaOpRhsFreshNet303** (`R11U303_GENNDAOP_OFF`, same site). The default view's generate-scope
net-declaration cell keeps the SCOPE NET as its Lhs whenever the initializer is a select (bit, part, indexed part or
variable select), ranged or scalar, loop or if scope: writeCont_assign neither clones the cell (route 2 wants an
operation) nor reduces it, so golden lists no Lhs net (`wire [7:0] ca1 = arr[8*i +: 8];`, ours minted a fresh net
for the ranged net). An operation or constant initializer is cloned or reduced, so even a scalar net in a loop scope
takes the fresh Lhs (`wire w = 1'b1;`, `wire w = ~b[0];`, golden lists the net, ours shared). The rule pass 164's
§ genNetDeclAssignLhsShared164 stated for a hierarchical path, extended by Rhs kind. The -elabuhdm view reads equal on
both binaries for every case. Cases GN (31).

**§ classParamNamedTypeTs303** (`R11U303_CLSPARAMTD_OFF`, UhdmExporter emitClassDefn). A class value parameter
written with a named type (`parameter q::mask_t M = 3'b010`, a typedef, package-qualified, imported, `$unit`, enum,
struct or class-scoped) is typed by that typedef's own typespec (makeTypespec on the parameter), where ours built the
whole-declaration int_typespec with the literal's range (§ classParamWrittenTypeTypespec54 converted only `string`
and `int`). The parameter and its fold constant share it as before. Cases CP (12).

**§ ifCaTernFillArmKept303** (`R11U303_IFTERNFILL_OFF`, ModuleEmit emitInterfaceInstance, helpers ifTernFillSel303 and
ifTernFillAll303). The interface twin of § caTernFillArmKept193: an interface cell is reduced by the same
writeCont_assign (§ caIfaceBodyCaFolds83's decode), and ExprEval::reduceExpr hands an unbased unsized fill taken
branch back unchanged, so a bit-select (or constant-bound part-select) Lhs cell whose constant condition picks
`'0` / `'1` (through nested conditionals too) is cloned with the branch's own located constant, one object per
definition and branch (golden `arr[0] = (P) ? {2{sig}} : '0`, P = 0: `'0` BIN:0 size -1 at 6:36-6:38). The operand
gate is the module twin's (operandOk9). Refined before delivery: the law fires only when EVERY elaborated instance
of the interface selects the same fill branch; a draft that cloned only the fill instance of a split definition
(grid IF i03_split: b0 P = 0, b1 P = 1) moved the shared cell's reference binding from b0 to b1 in the -elabuhdm
view (chain away 4); the case now keeps pristine's bytes. Cases IF (10).

## Grid (cases/; drivers/grid.sh, every line with its exit code; evidence/grid.txt, grid_summary.txt)

116 case dirs in both views, 232 case-views: ST 11, BS 11, SA 15, MA 13, EP 13, GN 31, CP 12, IF 10 (each case names
its law in its first line). Configurations P, L, OFF and the law with each of the ten switches off.

- 150 case-views moving, **95 entering STRICT_EQUAL, 0 leaving**, 0 exit-code changes (every line rc=0 except SA/a01_forinit, a
  multiply-driven bit slang rejects with rc=3 on every configuration, kept as written), OFF equal to P in bytes and exit code on
  232 of 232.
- Every mover restored by exactly one switch except MA m04 and m13 (both views), which need MODARRSELNAME with
  MODARRIPSSPAN: SELBASETRIM 18, BOUNDSYSCLONE 18, SYSARGNAME 10, MODARRSELNAME 14, MODARRIPSSPAN 2, GENCAENUMSPAN 18,
  GENNDASEL 22, GENNDAOP 10, CLSPARAMTD 22, IFTERNFILL 12, pair 4.
- Away census (drivers/awaycv.sh, order-blind and chain-keyed) on all 150 movers: lost 0 and chain away 0 on every
  one, 450 chain records toward golden (evidence/grid_away.txt). Positive control (binaries swapped) on 13 sampled
  movers: away on 11 of 13 (GN f02 and n09 are identity-only movers, distance only; evidence/grid_away_poscontrol.txt).
- Stage-1 movers whose uhdm-cmp line count changes: BS b05_iface_el 33 -> 76 and b08_twoinst_el 33 -> 90 (the head
  moves from the instance parameter to a later array_var, chain away 0), CP c02 / c06 96 -> 126 and c03 92 -> 17,
  MA m13 1258 -> 1256 (both views); all stage 1 on both binaries with away 0.
- Downstream (drivers/dscases.py, both binaries, 116 dirs; evidence/downstream_cases.txt): no verdict worse; 9
  improve (IF i01, i02, i05, i07, i10 EQUIVALENT -> IDENTICAL; ST s01, s07, s09, s11 STATUS_DIFF -> IDENTICAL); 108
  IDENTICAL, 7 EQUIVALENT and 1 SURELOG_FAIL on the law binary.

## Gates (worktree at 368d0810, SLANG_UHDM exported per binary)

- Builds: pristine 0b3ca4f9 (equal to the main tree's build/slang-uhdm), law 390233eb; both frozen read-only before any
  measurement (the law binary rebuilt after the last source edit, which only dropped an unused include, reads the same
  md5); slang 12.0.0+545f88b2e.
- Firing census frozen before the law sweep (drivers/tracecensus.sh over the probe and both corpora in both modes,
  fence-filtered; evidence/predict.txt): 27 probe databases and 14 corpus row-modes (Earlgrey_0_1, ElabCParam,
  ClogCast, ibex_icache, ibex_multdiv_fast, int_types and rp32_r5p_alu in both modes, every one by
  § sysCallArgRefScopedName303). Byte movers in the sweeps: probe 20 of the 27 predicted (the 8 conversions, the
  p1_pos115 change and 11 EQUAL on both binaries: r11u115 p12_sysarg f and i, r11u22 g09, r11u25 q15, r11v17 w04,
  r11v22 v10, v11u115 a01, a06, a09, a18, a20); the other 7 fire § sysCallArgRefScopedName303 where the stored name
  equals what the chain gives (no byte moves). Corpus: 8 of the 14 predicted row-modes move (Earlgrey_0_1,
  ElabCParam, ibex_multdiv_fast and rp32_r5p_alu, each in both modes), ClogCast, ibex_icache and int_types fire with
  no byte change; the downstream lane's ibex_multdiv_fast and rp32_r5p_alu databases move with them.
- Away census on every mover: probe 20 lost 0, chain away 0, 54 chain records toward golden
  (evidence/probe_movers_away.txt); corpus 8 row-modes lost 0 and chain away 0 in both censuses, every strict column
  unchanged (evidence/corpus_movers_away.txt).
- Law sweep `tests/sweep.sh --jobs 3` (evidence/sweep_L.txt; pristine sweep_P.txt): probe EQUAL 3991 +
  STRICT_NOTEQUAL 96, regressions 0, conversions 8, changes 1; surelog default 480 + 0, testflags 474 + 0, 0/0/0;
  uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0, the
  csv identical to results/downstream_uhdm2rtlil.csv. Both sweeps exit 1 on the law-index check alone (tests/LAWS.md
  regenerated in the patch).
- Strict column, whole csvs row by row against the pristine sweep: surelog differs only in the LowMemLib / LowMemPkg
  testflags detail text (the workdir path); uhdm2rtlil 0 rows; probe the nine rows above.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors of the two
  same-length workdirs: 10 of 3365 corpus and downstream databases move, all named above (SELFCHECK 3363 of 3365, the
  known twin; evidence/byteverify_corpus.txt).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (EXPECT_UNKNOWN=1 / 6).
- Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 run no slang
  (evidence/binary_audit.txt).
- Determinism (drivers/det.sh, three concurrent draws per row-mode on the law binary): Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and every testflags row-mode with a database read one
  hash each; Earlgrey_0_1 d/t equal to the law sweep's (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` before any case is opened; evidence/controls*):
  36 earlier repro dirs (r10vrgg14, r10rgg14, r11u52v, r11u52, r11v46, r11u46, r10earl104, r11u146, r10earl121,
  r10earl115, r11u255, r11u164, r11u202, r10rgg9, r10vrgg9, r11u83, r11v83, r11u193, r11u289, r11u301, v11u301,
  r11u115, v11u115, r11u17, r11v17, r11u22, r11v22, r11u25, r10earl105, r10vearl118, r11u88, r11u85, r11u131,
  r11u214dec, r10uvm54, r11u196): 2574 case-views, 12 moving, 0 entering or leaving STRICT_EQUAL, 0 exit-code or
  uhdm-cmp line-count changes, every mover at stage 1 on both binaries (r10rgg14 g3, r10vrgg14 v4, r11u52v
  b11_operands, r11v22 v31, v11u115 a03 and a04, both views); lost 0 and chain away 0 on all 12, 8 records toward
  golden.

## Residues (ranked; all wrong on pristine too)

1. **The brief's first item, decoded and blocked on the sister's ground.** The prefix fold of an x/z ternary branch
   with a valid leading digit (v11u301repro VA va06, va08, va09, va10): golden's elaborated param_assign of
   `localparam logic [5:0] XV = 6'o7x` is already `UINT:7` (decompile `7`) where ours keeps `OCT:7x`, also with no
   cell reading it (scratch cases: the param_assign alone differs at uhdm-cmp stage 1). ParamEmit emitParameters
   (the elaborated param_assign value reduce) is the sister's; the cell's `INT:<prefix>` fold at
   § elabCaTernaryArmInstall92 cannot convert any of the four until that lands. Not written.
2. Interface cells of a definition whose instances split (IF i03_split: golden clones every instance's cell, the
   operation instance's with elaborated names); interface select cells with a bare-signal untaken branch (i06) and
   plain-name Lhs (i08) at stage 1 on both binaries.
3. p1_pos115 `differ:endcol(13)`: the three- and four-component definition-view generate pattern paths
   (`three_i[i].lo.f0` hier_path end column and its leaf full name `work@...gen_n2.f0`), the selected trailing member
   names, and the elaborated paths that keep the genvar `two_i[i]` where golden substitutes the index
   (§ defGenPathSel161's CFC writer family, TypeEmit). r10vrgg17repro/v8 the same family: a def-view port-actual path
   `arr[6+7*i].value[0+:4]` whose trailing select golden names with the spaced decompile and whose index reference
   skips the select's base (`...value[0+:4].i`, ours `...value[0+:4].arr.i`).
4. The probe residues read and not written: g3_rhs98 (golden types a generate-block `$signed(v1)` with the PARENT
   module's `s_fc` declaration, a Surelog name lookup through the parent), v5_home (a bound instance's Lhs binding
   the definition net: the § caLhsDefNetUnlessOpRhs139 gate is not reached for the bind instance), l_concat (a
   concatenation Lhs), e05_untaken_bare_partsel (golden binds a fresh unlocated enum_const), the type-parameter
   element full names (e18, b18, b21, i16: golden's shared rt_t array re-parented at a var or unparented by an
   assignment, UhdmExporter rebindTypeParamElem107 and § tpPackedArrCaUnparent275's named-element half), the clone
   home names (q6clone, g122_f_clone) and t48a / v208_f_io, v200_5_modmat (a wildcard clone's vector local without its
   own typespec copy), g13 (a dead generate branch's `q2::IMPL.v`, stage 1 live), the nested modules
   (r11u297repro NM, not probe cases).
5. Grid stage-1 shapes on both binaries: BS b02, b04, b05, b06, b08 (`$bits(int)`, a nested call, interface and
   packed typedefs, two instances), CP c02, c03, c05, c06, c08, c12, MA m06, m07, m12, m13, SA a04, a09, a13, a14,
   GN n01, n06, f03, f04, s03, s07, s09, s10, s12, s13 (reference, operation and call initializers at stage 1 on
   another face), EP e08, e11.

Sister-ground faces (reported, not written): the elaborated param_assign reduce of an x/z localparam (ParamEmit,
residue 1); the remaining probe residues by writer as passes 294 to 301 list them (ExprEmit and ParamEmit: the
package-function call folds, the struct-fold member names, b3 / n4, the r11u109 64-bit cast values, the
folded-constant spans p1_pos115's neighbours v4_ops, c9_litarith_noovr, a3_inst66, k11_logic_param_range).

## Process

Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh);
every corpus path list was filtered before any file was opened; no fenced name is spelled. No other agent's process
was listed or signalled; the main tree was not written. **The implementer's slips, no effect on any number:** one
shell ran the dump tool through an unset variable on a scratch golden, so the shell executed the database and dropped
an empty garbage-named file in its scratch directory (not the main tree, which `git status` showed clean); the file
was deleted and every later dump went through a wrapper that refuses a missing tool. A first firing census on a draft
binary was stopped by its own task id when the interface law was refined (the IF i03 chain away above), its workdir
deleted, and the census, grid and sweep rerun on the final binary. An exploratory fence-filtered corpus run of a draft
read Earlgrey_0_1 testflags TIMEOUT under machine load; the same database built in 50 s alone (pristine 65 s) and the
gate sweep read it CMP_EQUAL.

Files: cases/{ST,BS,SA,MA,EP,GN,CP,IF}, drivers/ (copied from r11u301repro; grid.sh's switch list and gridsum303.py
renamed for this pass), evidence/.
