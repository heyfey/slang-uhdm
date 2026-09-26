# r11u169 — the expression/parameter ground of the strict axis: folded generate constants named at their use site, member leftovers located where the producer writes them, flattened pattern members at their left operand; 2 row-modes and 58 probe cases converted

Base `45b8e774` (branch matrix-1.87, pass 167). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or `include/`. The based-literal compaction sites (`basedLiteralSpaceCount` and its subtractions) are
not touched; the sister pass r11u168 had not landed at the start or at the law sweep (main tree HEAD `45b8e774`
throughout), so those sites are still in HEAD. Net binding is not touched. Every law of passes 140-167 and every
earlier refinement is left as landed; the four laws here are new sites under their own switches. Worktree
`/tmp/wt_r11u169`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base, byte-identical to the main tree's `build/slang-uhdm`) | `d64816326230eb41669e1062297ba547` |
| law (this patch; `law8` in the scratch naming) | `4a1d1f4cff4ddff0f8fdbf259ed587f4` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u169_bin`) before it was measured. The pristine sweep
(`/tmp/r11u169_swP`) and the law sweep (`/tmp/r11u169_swL`) have workdir names of the same length; in both, all 1531
surelog and all 1742 uhdm2rtlil `cmds.txt` slang lines name the frozen copy of that sweep's binary. The pristine sweep
reads `regressions=0 conversions=0 changes=0` in all three stages, probe `EQUAL=2676 STRICT_NOTEQUAL=1411`, downstream
803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT (evidence/sweep_pristine_summary.txt). Its only red, and the law
sweep's, is `law index STALE` (the worktree's hashes); the regenerated tests/LAWS.md in this patch clears it.

**The fence.** No binary, gdb run or script touched a slang-fenced test's source or database outside the gate
sweeps. The census (drivers/census.sh) refuses to run without `$FENCED` and dispatches the corpora with a
whole-name exclusion filter (794 of 798 surelog tests; "fenced mentions: 0"). The row readers drivers/rowrec.sh and
drivers/moverdiff.sh and drivers/predict.py refuse to run without `$FENCED` and refuse a fenced name. drivers/env.sh
reads the four names from RESUME.md; nothing in this directory spells them (a grep reads 0).

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 881 | 881 | 0 (2 changes, counts down) |
| uhdm2rtlil strict-equal (of 1606) | 1550 | **1552** | +2 |
| probe EQUAL (of 4087) | 2676 | **2734** | +58 |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | the law sweep's downstream.csv is byte-identical to the pristine sweep's |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched).** The fresh rows of the law sweep:

    uhdm2rtlil:
      pkg_nested_struct_param_width,default,CMP_EQUAL,,,equal      § memLeftFormalArgLoc169 + § memLeftSliceUnlocated169 (was differ:line(5))
      pkg_nested_struct_param_width,testflags,CMP_EQUAL,,,equal    (same)
    downstream (fresh row, IDENTICAL as before):
      pkg_nested_struct_param_width,IDENTICAL,OK,OK,66,66,,

**CHANGES (corpus, 10 row-modes, every one attributed record by record: evidence/corpus_movers_records.txt):**

| row-mode | before -> after | law | records |
|---|---|---|---|
| surelog FuncStructVal d | endcol(207) -> endcol(95) | § memLeftSliceUnlocated169 | 112 leave, 0 enter |
| surelog FuncStructVal t | endcol(363) -> endcol(177) | § memLeftSliceUnlocated169 | 186 leave, 0 enter |
| uhdm2rtlil ibex_pmp d/t | file(52) -> file(51) | § genCaFoldTsChainNamed169 | 1 leave, 0 enter |
| uhdm2rtlil struct_param_field_shift d/t | col(41) -> fullname(5) | § memLeftFormalArgLoc169 + § memLeftSliceUnlocated169 | 36 leave, 0 enter |
| uhdm2rtlil param_nested_struct_field_width d/t | line(5) -> fullname(6) | § memLeftFormalArgLoc169 (the copy) + § memLeftSliceUnlocated169 | 5 leave, 6 enter: the walk diverges LATER |
| uhdm2rtlil struct_param_func_config d/t | line(5) -> fullname(14) | the same | 5 leave, 14 enter: the walk diverges LATER |

The two growing counts are the walk going further: pristine's walk diverged at a `depth` record
(param_nested_struct_field_width d `#177 line #190 line #206 file #207 file #239 depth`) because the whole-formal-read
leftover SHARED the parameter's constant and the walk skips an object it has already visited; with the law's copy
(golden holds a copy too) the walk no longer diverges there and every entering record lies beyond the old divergence
(`#789 fullname #802 fullname #856 endcol #873 fullname #886 fullname #912 file`; struct_param_func_config
`#697 ... #1364 depth`). The first entering face is the leftover's typespec reference name, residue R1 below
(evidence/walk_diverges_later.txt quotes all four row-modes, old and new first records).

**Probe: 58 cases go `STRICT_NOTEQUAL -> EQUAL`, 27 change, 0 regress** (evidence/sweep_law_changes.txt,
evidence/probe_changes_attributed.txt):
* conversions: 52 by § genCaFoldTsChainNamed169 (the v11u116 branches grid f1/f1s/f1t: 45 cases; r10earl pv20 qd21 qe21
  qf21; r10vearl105 v4_home105; r11u115 k06_modhdr_p09_add, v10_genfor_modparam_ctl), 3 by § memLeftSliceUnlocated169
  (r11u11 a3, r11u14 c8, r11vu3 vK), 3 by it with § memLeftFormalArgLoc169 (r11u20 b2 b5, r11vu13 v2);
* changes: 22 lose records only (g5_int105, v7_repl105, v95a_ctx, f1_shex x3, f1t_intsig by the fold name; r11u11 a5 a8,
  r11u13 b3 b6, r11u18 b4, r11u20 b1 b3 b4 b6, r11u82 s1 s2 v2 v3, r11v75 xl_impclimb by the leftover laws;
  r11v66 a3_inst66 by § patFlatMemberLeftSpan169); 5 (r11u20 t5, r11u21 t1, r11v21 v1, r11vu13 v4 v9) lose their
  divergence and reach later records, exactly as the two corpus rows above (evidence/walk_diverges_later.txt).

Every probe byte mover was attributed against its golden (drivers/pmovers.py, evidence/probe_movers_records.tsv):
**98 movers, 866 records leave, 36 enter, all 36 on the five cases whose walk now goes past its old divergence**;
13 movers are record-neutral and dump-identical (the r11u109 f1 grid, § patFlatMemberLeftSpan169 on an object no
listing reaches).

## Targeted rows (brief items), before -> after

| row | before | after | law / what is left |
|---|---|---|---|
| (1) N0471 ibex_pmp d/t | file(52) | file(51) | § genCaFoldTsChainNamed169 clears the N0471 record; the row's other faces (the typespec located at its use, file(15+); the dv_fcov macro spans) are the TypeEmit/macro-model's (below) |
| (1) N0086 + N0087 + N0407 + N1083 (the makeMemLeftConst leftovers) | line/col/file | pkg_nested_struct_param_width d/t **CMP_EQUAL**; struct_param_field_shift, param_nested_struct_field_width, struct_param_func_config d/t now head at R1 | § memLeftSliceUnlocated169 + § memLeftFormalArgLoc169 |
| (2) pass 167's rs/r07 (a folded pattern member at its left operand) | endcol | STRICT_EQUAL | § patFlatMemberLeftSpan169 |
| (2) pass 167's gz/z07 | fullname | fullname | not worked (the multi-dimensional declared type) |
| (1) N0977 CovMacro d/t | endcol(118) | unchanged | the head is the macro-argument column model (constants at `SV_COV_*` 12:34 golden, 12:46 ours; `$root` at 12:48 against 12:82): UhdmExporter's macro model, not ExprEmit; the `$root.top` name comes after |
| (1) N0278 LocalScopeHierPath t | fullname(1) | unchanged | decoded below (S1): a parenting face |
| (1) N0427 InterfArrayBind d | fullname(3) | unchanged | pass 167's decode stands (needs an elaborated-view flag from ModuleEmit) |
| (1) N0003 StructParamPatternInitCast d/t, iface_zero_width_field d/t | fullname(3)/(4) | unchanged | the flattened-pattern rule is not decoded (pass 167 residue 1) |
| (1) const_cast_signext, N0012, N0536, N0129 YosysOldOpen, ibex_alu | — | unchanged | not worked in this pass |
| (1) YosysRiscv d/t | endcol(86) | unchanged | its head is the spaced based literal (col 60:17 golden, 60:18 ours): the reserved compaction area |
| (3) r11u170: § aggParamFoldUnqualWholeSpan158 / § aggParamFoldQualSpanByView163 | — | measured | below |
| (3) r11u170: § elabTpDefaultDefNamed163 | — | measured | below |
| (5) pair B r11u168 | — | — | not landed at the start or at the law sweep |

## Laws (each under its own switch; `R11U169_OFF=1` drops all of them; `R11U169_TRACE=1` prints one stderr line per branch)

Sites are named by function and § token (`grep -n '§ <law>' src`). The switch table is the r11u169 block at the end
of src/EmitHelpers.h. Every law was decoded on purpose-built goldens of the pinned Surelog (the grids below), and on
Surelog's source.

### § genCaFoldTsChainNamed169 (`R11U169_GCACHAIN_OFF`; ExprEmit.cpp emitExpr, the generate-scope cont_assign parameter fold, both the copied-encoding constant `c5` and the folded constant `c9`, helper genCaUseSiteChainName169)
A module parameter folded in a generate-loop continuous assignment (§ genCaLoopParamFold, § loopCaParamReadKeepsLiteral116,
§ genCaTopLoopParamPaCopy105) carries a `ref_typespec` whose full name Surelog never stores: BaseClass::ComputeFullName
walks from the substituted constant's parent, the operation, conditional, select or cont_assign that reads it. So the
name is the generate scope for an operand of a binary operation or a conditional at any depth and for the whole
right side (`a[c] & P`, `(a[c] > P) ? a[c] : P`, `{a[c], (P + 1)}`, `o = P`, `o = (P)`: golden `work@dut.g[0]`), and
the select for an index (`a[c][P]`, `a[c][P % 4]`, `q[NUM_REQS]`: `work@dut.g[0].a`, `work@qe21.gen_rev[0].q`); a
DIRECT operand of a concatenation, a replication or a unary operation, and a part-select bound, keep the instance's
name (`{P, a[c]}`, `{P{1'b1}}`, `{2{P}}`, `~P`, `-P`, `a[c][P:0]`: `work@dut`, what we already wrote). Ours named every
one by the instance (`mi9->VpiFullName()`). The law names the reference by the use site when the landed instance name
would be written (a module parameter with a param_assign), and abstains on any other parent (a part select, a call).
Inside an index an operation is emitted under the select base's prefix already, so the select's name is appended
only when the prefix does not end with it. Cases gc/a01 a02 a05 a06 a09 a11 a13 a16 b03 b04 b05 b06 b08 b11 c03 c05
c06 c07 c10 (STRICT_EQUAL); controls gc/a03 a04 a08 a15 b01 b02 b10 c01 c02 c09 (equal on both); residues gc/a07 c04
(below); stage 1 on both: gc/a10 a12 a14 b07 b09 c08.

### § memLeftSliceUnlocated169 (`R11U169_MLLOC_OFF`; ParamEmit.cpp emitParameters at the makeMemLeftConst stamp site, helper memLeftSiteLoc169, and its drain half in stampEvalFuncLeftovers)
A struct parameter built by a member-by-member constant function leaves one constant per member on the struct
typespec (UHDM ExprEval::setValueInInstance stamps `reduceExpr(<body right side>)`). A COMPUTED member (`c.B = x / 8`,
`$clog2(xlen / 8)`, `e == 1'b1 ? (c.A / 16) : 1`, `3 * 4`, `PK + 1`, `bit'(1)`) is a fresh constant ExprEval mints with
no location: golden file empty and 0:0-0:0 (r11u11 a3, r11u14 c8, r11vu3 vK, struct_param_field_shift's
XLEN_ALIGN_BYTES, param_nested_struct_field_width's `derived`); ours parked it at the call. The law clears the minted
constant's location. Exceptions, each measured:
* a SIGN cast of a literal (`cfg.NrRgprPorts = unsigned'(2)`) is the literal's own node (golden FuncStructVal 539:33-34):
  located at the literal (ml/m15); a type cast (`bit'(1)`, c8) is not;
* a right side that reads a FORMAL's member is decided in the drain: when a read member's caller actual is a recorded
  PATTERN parameter golden writes it at a read site of the parameter (FuncStructVal INSTR_PER_FETCH at
  `CVA6Cfg.INSTR_PER_FETCH` 618:22-45, not modelled: the call span stands), else it is the plain unlocated reduction
  (ml/m13 `c.der = uu.d * 2` with `build(UC)`);
* the literal, parameter-read, pattern-element, concatenation and function-body (S2) leftovers keep their landed
  resolutions.
Cases ml/m01-m10 m12 m13 m15 (records leave; the first face left is R1); stage 1 on both: ml/m03 m08 m11 m14 m16 m18.

### § memLeftFormalArgLoc169 (`R11U169_MLARGLOC_OFF`; ParamEmit.cpp, the same site, helper memLeftActualLoc169, and the drain's parameter-actual copy)
A WHOLE FORMAL READ (`c.A = x`) leaves what the evaluator bound the formal to: the caller's actual, written where the
actual is written. A literal actual leaves the literal (`mk(64, 5)`: golden 15:27-29 and 15:31-32), a reduced binary
operation actual its LEFT operand's node (`mk(32 + 32, 5)`: 15:27-29; CompileExpression's tail
`populateCoreMembers(child, child, result)`, the rule § elabParamOpSubtreeFold86 decoded), a parameter actual a COPY of
the parameter's constant at the reference (`build(UCFG)`: golden param_nested_struct_field_width 31:38-42, while
UCFG's own constant stays at 30:32; ours shared that object). The law locates the minted leftover at the actual, and in
the drain replaces the shared parameter constant by a copy (value, size, type, decompile, typespec reference) at that
location. A defaulted formal (its expression written in the subroutine header) and any other actual shape abstain; a
macro-born actual abstains (ml/m12: golden 16:27-29 is the macro model's column). Cases ml/m01 m02 m04-m07 m09 m10 m13.

### § patFlatMemberLeftSpan169 (`R11U169_PATFLATSPAN_OFF`; ParamEmit.cpp emitParameters, the flattened elaborated pattern's member constant `c2`)
The elaborated listing re-compiles a struct pattern member with Reduce::Yes, and CompileExpression's tail stamps the
reduced constant (minted with no location) at the expression node's FIRST CHILD: the left operand's own node with its
parentheses for a binary operation, the operator token for a unary one. Golden `'{x: (W'(1) << (W - 1)) | W'(1)}` at
7:28-7:46 (pass 167's rs/r07, ours the whole member 7:28-7:54), `(W + 1) * 2` at `(W + 1)`, `W - 1 - 2` at `W - 1`,
`(3 + 4)` at `3`, `'{default: 3 + 4}` at `3`. Cases pf/p01 p04 p05 p07 p09 p10 (STRICT_EQUAL); pf/p06 p08 keep another
face (a tagged_pattern column, the macro column); stage 1 on both: pf/p02 p03. Corpus: BlackBePipeInt d/t move toward
golden without a verdict change (24 dump lines in the default row, all toward: evidence/blackbepipeint_default_toward.txt).

## Census (the predictions) and the movers

The census (drivers/census.sh + tracewrap.sh) ran on the law binary BEFORE the law sweep, through the harness, with
the fence filter. Every branch of every law traces (`GCACHAIN c9`/`c5`, `... same`, `... abstain`; `MLLOC`,
`MLLOC castlit`, `MLLOC reads deferred`, `MLLOC reads`, `MLLOC reads pattern keep`; `MLARGLOC site`,
`MLARGLOC abstain`, `MLARGLOC paramcopy`; `PATFLATSPAN bin`/`un`). evidence/census_all_firings.tsv lists every
firing; evidence/predicted_movers.tsv the byte-changing branches: **118 names, 10 surelog row-modes, 10 uhdm2rtlil
row-modes, 98 probe cases.**

Byte verifier (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law `/tmp/r11u169_swL` against pristine
`/tmp/r11u169_swP`):

| stage | paths | selfcheck | movers | predicted | unpredicted |
|---|---|---|---|---|---|
| surelog | 960 identical sets | 959/960 | 16 | 10 | **6: MiniAmiq d/t, SeqDriver d/t, SimpleUVM t** (the 4-line UINT/vpiDecompile coin: ordered = order-blind = 4 dump lines each) **and Scoreboard d** (the svunit list-order coin: 92 ordered lines, 0 order-blind): evidence/uvm_coin_orderblind.txt |
| uhdm2rtlil | 1608 identical sets | 1607/1608 | 10 | 10 | 0 |
| probe (every database compared) | 4087 | — | 98 | 98 | 0 |

Every predicted mover moved. Record attribution of the corpus movers (drivers/moverdiff.sh):
the 10 changes above; record-neutral: BlackBePipeInt d/t (toward golden, above), Earlgrey_0_1 d/t
(§ genCaFoldTsChainNamed169 on prim_prince, prim_gate_gen and ibex's prefetch buffer: 26 dump lines move in the default row, all toward
golden's counts: evidence/earlgrey_default_toward.txt; its walk diverges earlier), StructParamPatternInitCast d/t and
StructParamFuncBodyFieldCompare d/t (dump-identical: § patFlatMemberLeftSpan169 on an object no listing reaches).

## Gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `d6481632…` = main tree; law `4a1d1f4c…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=58, changes=27; EQUAL 2734 STRICT_NOTEQUAL 1353, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 0 + 2; changes 2 + 8 (all attributed above) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; not identical and not excused=0; downstream.csv byte-identical to the pristine sweep's; every touched uhdm2rtlil row reads IDENTICAL (ibex_pmp, param_nested_struct_field_width, pkg_nested_struct_param_width, struct_param_field_shift; struct_param_func_config IDENTICAL NO_GATES as at the base) |
| (5) uhdm-cmp on touched rows | every mover keeps its judge-equal status; every grid case keeps its uhdm-cmp verdict (evidence/grid_pristine_vs_law.txt) |
| (6) byteverify | 16 + 10 corpus movers and 98 probe movers, all attributed; all but the six coin rows predicted by name |
| canaries | r11u107repro/canaries.sh: surelog ok=50 changed=2 (FuncStructVal d/t, the attributed change; pristine ok=52), uhdm2rtlil ok=16 changed=0; ctcan2.sh EXPECT_UNKNOWN=1 surelog ok=58 changed=0 PASS, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2 changed=0 PASS (evidence/canaries.txt) |
| cases | 64 cases (evidence/grid_pristine_vs_law.txt): 25 go to STRICT_EQUAL, 10 are equal on both (controls), 15 stay STRICT_NOTEQUAL (records leave; residues named), 14 are stage 1 on both; no case changes its uhdm-cmp verdict |
| switches | each switch alone returns its own grid to pristine bytes: GCACHAIN_OFF gc 37/37, PATFLATSPAN_OFF pf 10/10, MLLOC_OFF + MLARGLOC_OFF ml 17/17 (evidence/switches.txt) |
| `R11U169_OFF=1` | 1646 of 1646 cases (these 64 and every case of r11u120/124/131/154/158/160/163/167, r11v120/124/131/154/158/163/167, r11u162verify, r11u170verify) byte-identical to pristine (7 rejected by both: no database) (evidence/offbytes.txt) |
| byte controls | the law binary with every law on leaves those 1582 earlier cases byte-identical to pristine except pass 167's rs/r07 (its residue 7, now STRICT_EQUAL), rs/r10 and gz/z03 (record-neutral: strict-equal and stage 1 on both, bytes only) (evidence/offbytes.txt) |

## r11u170's item (3), measured (evidence/r11u170_item3.txt; the pristine binary with switches, full probe + both corpora, byte compared)

| switch(es) set | verdict changes | byte movers | reading |
|---|---|---|---|
| `R11U158_AGGUNQSPAN_OFF` | none (0/0/0) | u2r struct_param_func_config d/t, probe r11vu13 v4 v9 (+ UVM coins) | **dump-identical** on all four (uhdm-dump diff 0 lines; strict records identical): the only difference is serialized bytes, not content. § aggParamFoldUnqualWholeSpan158 is fully covered by § aggParamFoldQualSpanByView163 at HEAD and can be retired as content-neutral (its removal is a byte change on those four databases) |
| `R11U163_AGGQUALSPAN_OFF` | probe 10 changes `name(2) -> endcol(3)` (r11u108 pk k10e k11, r11u111 f2 b04 b05 b08 b10 b11 b12 b17, v11u111 x26) | those 10 probe cases | § aggParamFoldQualSpanByView163 is NOT covered by pass 158's law: keep it |
| both | probe 5 regressions (r11u108 pk k10h k10i k23 k23c k23d), surelog LargeValue2Struct and StructUnsizedVal d/t regress | + LargeValue2Struct, StructUnsizedVal | the pair is needed; the 158 half alone is redundant |
| `R11U163_TPDEFNAME_OFF` | probe r11u20 t6 `fullname(2) -> fullname(3)` (one record enters: `ref_obj IW <in>IW`) | u2r gen_scope_numports and param_name_collision_typeparam d/t (strict-equal both ways, record-neutral), probe r11u20 t3 (record-neutral) | § elabTpDefaultDefNamed163 is redundant with § tpUseBindsDefDefault160 except that one record: dropping it loses a record, so it stays |

## Sister-ground faces (decoded; the fix sits in a file this pass does not own, or the decode is incomplete)

S1 — LocalScopeHierPath t `fullname(1)`: golden's definition-view foreach index `j` inside `path.slices[j].spath` is
parented at the HIER_PATH (golden default dump: `vpiParent: hier_path`), so its unstored name computes
`pack::uvm_mem_mam::check_reg::j` (a ref_obj under a hier_path skips the path's name); the `--elabuhdm` listener's
clone re-parents it at the cloned bit_select and recomputes `...check_reg::path.slices[j].spath::j`. Ours parents `j` at
the bit_select and STORES `...check_reg::j`; § elabCloneFullNameUnstored137 (uhdm_main.cpp) leaves a stored name that
differs from its own chain stored, so the clone copies it. The fix is the index's parent (ExprEmit's hier_path element
emission) plus the 137 walk's equality then clearing it; not landed: re-parenting every hier_path element index needs
its own grid (it moves every `--elabuhdm` clone of such a path).

S2 — ibex_pmp d/t `file(51)`: struct/enum typespecs located at their use (`ibex_pmp.sv 114:47-57` golden, the package
typedef `ibex_pkg.sv 433` ours) — the typespec location model (TypeEmit makeTypespec); then the `dv_fcov_macros.svh`
spans (the macro model).

S3 — CovMacro d/t `endcol(118)`: every head is a macro-argument column (`SV_COV_*` constants 12:34-36 golden, 12:46
ours; `$root` 12:48-51 golden, 12:82 ours): the UhdmExporter macro model; the `$root.top` name (N0977) follows.

S4 — YosysRiscv d/t `endcol(86)`: the spaced based literal's column (60:18 golden, 60:19 ours), the reserved compaction
area r11u168 retires.

## Decoded, not landed (ranked residues on this ground)

1. **R1, the leftover's typespec reference on the elaborated parameter's struct copy** (now the head of
   struct_param_field_shift, param_nested_struct_field_width, struct_param_func_config d/t, FuncStructValSimple d/t and
   the ml grid): golden holds, in the ELABORATED module listing (`uhdmtopModules` work@top.Cfg), its own struct copy
   whose leftover constants carry references named through the copy (`<in>p::cfg_t.A`: unstored, chain through the
   member), while the package and definition listings keep the stored package name (`p`). Ours shares one struct and
   one leftover. Pass 167's § evalFuncBodyRhsStampClone167 builds exactly that copy, but only for an S2 hit; widening
   it to every stamped elaborated parameter (copy the struct, clone every minted leftover, unname its reference, and
   re-point the param_assign constant's reference too) is the next law. Each of those rows has a second face after it
   (the param_assign constant's `p::D` span `endcol`, an INT constant `file`, a `struct_typespec` line).
2. gc/c04: an operation under an indexed part-select base (`a[c][P - 1 +: 1]`) names through BOTH selects in golden
   (`work@dut.g[0].a.a`); the law abstains on part selects. gc/a07 (`a[c][P +: 2]`) is a definition-view ref_obj name
   (`work@dut.g.a.P` golden, `...g.a.a.P` ours), another site. g5_int105's `sig[IDW +: 2]` base (golden the instance,
   ours the scope) is the c5 branch's `genCaSelBasePfx`.
3. The member leftover read through a PATTERN caller (FuncStructVal INSTR_PER_FETCH): golden writes it at a read site of
   the parameter (`CVA6Cfg.INSTR_PER_FETCH` in an override), not decoded further.
4. The ml/m12 macro-born actual (golden 16:27-29, the macro model's column for `` `XW ``).
5. S1 above (LocalScopeHierPath t).
6. The brief's other items not worked here: StructParamPatternInitCast / iface_zero_width_field's flattened pattern,
   InterfArrayBind d, const_cast_signext, N0012, N0536, the ibex_alu enum default span, YosysOldOpen, pass 167's gz/z07
   rs/r22, the carried pass-163 residues, r11u157's R2/R3/R6/R8/R9, gl/l4, ev/e16, hl/h3, r11u170's R-list (hier_path
   routes, the size-cast shapes), pass 154's macro lvalue paths, pass 164's S2 (sc/c10), vA's column face.

## Cases (first line of every case names its law; pristine / law verdicts in evidence/grid_pristine_vs_law.txt)

| grid | cases | law | pristine -> law |
|---|---|---|---|
| gc | a01 a02 a05 a06 a09 a11 a13 a16 b03 b04 b05 b06 b08 b11 c03 c05 c06 c07 c10 | § genCaFoldTsChainNamed169 | fullname -> STRICT_EQUAL |
| gc | a03 a04 a08 a15 b01 b02 b10 c01 c02 c09 | § genCaFoldTsChainNamed169 (controls: concatenation, replication, part-select bound, unary operand, nested loops, if-generate) | equal -> equal |
| gc | a07 c04 | § genCaFoldTsChainNamed169 (residue 2) | fullname -> fullname (bytes unchanged) |
| gc | a10 a12 a14 b07 b09 c08 | § genCaFoldTsChainNamed169 (stage 1 on both) | NOT_EQUAL -> NOT_EQUAL |
| ml | m01 m02 m04 m05 m06 m07 m09 m10 m13 | § memLeftSliceUnlocated169 + § memLeftFormalArgLoc169 (residue 1 left) | col/line -> fullname (records leave) |
| ml | m12 | § memLeftSliceUnlocated169 (the macro actual abstains: residue 4) | col -> col (records leave) |
| ml | m15 | § memLeftSliceUnlocated169 (the sign cast of a literal) | file -> endcol (the `p::D` span face) |
| ml | m03 m08 m11 m14 m16 m18 | § memLeftSliceUnlocated169 (stage 1 on both) | NOT_EQUAL -> NOT_EQUAL |
| pf | p01 p04 p05 p07 p09 p10 | § patFlatMemberLeftSpan169 | endcol -> STRICT_EQUAL |
| pf | p06 p08 | § patFlatMemberLeftSpan169 (another face stays) | col -> col (records leave) |
| pf | p02 p03 | § patFlatMemberLeftSpan169 (stage 1 on both) | NOT_EQUAL -> NOT_EQUAL |

## Ops notes (disclosed)

* Eight law binaries were built in turn (law1 the first chain walk and a member-parenting half, withdrawn: golden's
  package listing keeps the stored reference name, residue 1; law2/law3 the refined walk and the left-operand span;
  law4 the bare select index; law5-law8 the computed-leftover exceptions: the formal-member read deferred to the drain,
  the sign cast). The census and the gate sweep ran on law8 only; measurement sweeps ran on law3 and on the pristine
  binary with the item-(3) switches.
* EmitHelpers.h holds only the switch block; the helpers live in the translation unit that uses them.
* No process I did not start was touched.

## Files

* drivers/env.sh (the environment, `$FENCED` read from RESUME.md), sweep.sh (a gate sweep), msweep.sh (a measurement
  sweep with switches), grid.sh / gridall.sh (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), recdiff.sh (a
  case's leaving and entering records), switches.sh, offbytes.sh (`R11U169_OFF` and law bytes over case trees).
* drivers/census.sh + tracewrap.sh (the firing census, fence-filtered), predict.py (the firing list).
* drivers/rowrec.sh, moverdiff.sh (fence-guarded row readers), pmovers.py (probe mover records).
* evidence/: the files named above.
