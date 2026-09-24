# r11u140 — the expression/parameter ground of the strict axis, fourth refill (implementer)

Base `d8473d78` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/StmtEmit.cpp`,
`src/EmitHelpers.h`. No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or any header under `include/`; a face whose fix sits there is decoded below and stops there.
Net binding (the live sister pass's § caLhsDefNetUnlessOpRhs139 / § ndaLeftmostLeafElab139 /
§ clockingEventDefNet139 / § connLeftmostLeafElab139) is not touched: none of this pass's hunks is in a function
its law.patch changes other than `emitExpr`, whose only sister hunk is the re-entry at the very top of the
function (this pass edits the UnaryOp, Streaming, NamedValue pattern-substitution and cast-target cases, far
below it), and the EmitHelpers.h block of this pass sits at the end of the file. Worktree `/tmp/wt_r11u140`,
system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree rebuild of the base; byte-identical to the main tree's `build/slang-uhdm`) | `5737c6b070f5aaa9ecd29a6b291c1402` |
| law (this patch) | `28d69b69ace5614d967ec44e61619c95` |
| `build/uhdm-strictcmp` (identical to the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Both were frozen (`chmod 555` copies under `/tmp/r11u140_bin`) before they measured anything; every
`cmds.txt` of both sweeps names its frozen binary. A `-g1` build of an intermediate state of the same source
(line tables only) pinned two mint sites with gdb (drivers/findrank.cpp gives an object's creation rank).

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 709 | **722** | +13 |
| uhdm2rtlil strict-equal (of 1606) | 1334 | **1344** | +10 |
| probe EQUAL (of 4087) | 2221 | **2244** | +23 |
| surelog / uhdm2rtlil judge-equal (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 rows changed on any column |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them)**, fresh csv
rows (evidence/sweep_law_vs_baselines.txt), with the law whose trigger the pristine database carries
(drivers/predict140.cpp, evidence/predictions_pristine.txt):

    surelog:
      ClassVar,default,CMP_EQUAL,,,equal                         § foreachArrayPlaceholderFile140
      ComplexExprSize,default,CMP_EQUAL,,,equal                  § sysArgUnaryWholeSpan140
      ComplexExprSize,testflags,CMP_EQUAL,,,equal                § sysArgUnaryWholeSpan140
      DefaultPatternModule,default,CMP_EQUAL,,,equal             § defaultFillOneConstant140
      IntegerConcat,default,CMP_EQUAL,,,equal                    § pkgRefFoldClonesMultiDimOnly140
      IntegerConcat,testflags,CMP_EQUAL,,,equal                  § pkgRefFoldClonesMultiDimOnly140
      Kmac,default,CMP_EQUAL,,,equal                             § impLhsCloneArrayTsOwnCopy140
      ParamArrayUnsizedPattern,default,CMP_EQUAL,,,equal         § defaultFillOneConstant140 + § replCountFoldFile140
      ParamArrayUnsizedPattern,testflags,CMP_EQUAL,,,equal       § defaultFillOneConstant140 + § replCountFoldFile140
      ParamFromPackage,default,CMP_EQUAL,,,equal                 § pkgRefFoldClonesMultiDimOnly140
      ParamFromPackage,testflags,CMP_EQUAL,,,equal               § pkgRefFoldClonesMultiDimOnly140
      ParamScope,default,CMP_EQUAL,,,equal                       § elabPatOperandRefSpan140
      ParamScope,testflags,CMP_EQUAL,,,equal                     § elabPatOperandRefSpan140
    uhdm2rtlil:
      func_local_compound_xor,{default,testflags},CMP_EQUAL,,,equal       § multiDeclOneItem140
      param_struct_field_bitsel,{default,testflags},CMP_EQUAL,,,equal     § impLhsCloneArrayTsOwnCopy140
      param_unpacked_struct_array,{default,testflags},CMP_EQUAL,,,equal   § impLhsCloneArrayTsOwnCopy140
      struct_dynamic_range,{default,testflags},CMP_EQUAL,,,equal          § procLvTrailIdxNamesByPath140
      struct_member_trailing_index,{default,testflags},CMP_EQUAL,,,equal  § procLvTrailIdxNamesByPath140 + § procLvBaseSelTrailAtIdx140

23 row-modes in 13 tests; 23 probe cases (`r10buvm28repro/g28_a0_head`, `g28_c_castr0`, `r10buvm29repro/g29_b_targets`,
`g29_c_carriers`, `g29_e_homes`, `g29_f_head`, `r10uvm93repro/g93_a6_case`, `v93_a1_types`, `v93_a4_case`, `v93_a6_sub`,
`v93_a9b_sysfn`, `v93_c1_bitsfall`, `v93_crash_min`, `r10vbuvm29repro/gv29_h_genident`, `gv29_i1`, `gv29_i2`, `gv29_i3`:
§ streamOperandBraceSpan140, 17; `r10svs3repro/a3_position`, `r10uvm28repro/t38c`, `r10uvm57repro/v2_loopvar`,
`r10uvm8repro/q3`: § foreachArrayPlaceholderFile140, 4; `r11u113repro/grid/b/b27_pkpar_of_pkpar`,
`v11u116repro/cases/k3_unq_ovr`: § pkgRefFoldClonesMultiDimOnly140, 2), each reading `EQUAL,,equal` in the fresh
probe.csv. Targeted downstream rows, all IDENTICAL (evidence/downstream_law.csv):
`func_local_compound_xor,IDENTICAL,OK,OK,65,65,,`, `param_struct_field_bitsel,IDENTICAL,OK,OK,6,6,,`,
`param_unpacked_struct_array,IDENTICAL,OK,OK,20,20,,`, `struct_dynamic_range,IDENTICAL,OK,OK,68,68,,`,
`struct_member_trailing_index,IDENTICAL,OK,OK,177,177,,`.

## Laws (all under `R11U140_OFF=1`, each droppable alone)

| law | switch | site (file + § token) | cluster / residue it closes |
|---|---|---|---|
| § sysArgUnaryWholeSpan140 | `R11U140_SYSUNARY_OFF` | ExprEmit.cpp, `emitExpr` UnaryOp case (`sysArgUnaryWholeSpan140On`) | N0245 (ComplexExprSize) |
| § streamOperandBraceSpan140 | `R11U140_STREAMBRACE_OFF` | ExprEmit.cpp, `streamOperandBraces140`, called from the Streaming case of `emitExpr` | N0050, N0060 (the stream / cast-over-stream probe grids) |
| § procLvTrailIdxNamesByPath140 | `R11U140_LVIDX_OFF` | ExprEmit.cpp, `emitMixedHierPath` (SITE 1) and the plain-base member-select builder (SITE 2), both feeding `trailSelIdxNames133` | pass 133's § hpTrailSelIdxNamesByPath133 in a process lvalue (N0052's lvalue twin) |
| § procLvBaseSelTrailAtIdx140 | `R11U140_LVTRAIL_OFF` | ExprEmit.cpp, `emitMixedHierPath`, the member-select process-lvalue branch | N0061, pass 133's residue R8 (tix t08) |
| § foreachArrayPlaceholderFile140 | `R11U140_FEFILE_OFF` | StmtEmit.cpp, the foreach array-reference placeholder (two mints, beside § cloneForeachArrayRefUnresolved183) | N0041 |
| § elabPatOperandRefSpan140 | `R11U140_PATOPSPAN_OFF` | ExprEmit.cpp, `emitExpr` NamedValue case, the `patSubstElab` substitution beside `patParamNoFold` | N0212 (ParamScope) |
| § multiDeclOneItem140 | `R11U140_MULTIDECL_OFF` | StmtEmit.cpp, `emitStmt` StatementList case, the synthesized body `begin`'s anchor (both the block-item and the tf-item item lists) | N0053 |
| § impLhsCloneArrayTsOwnCopy140 | `R11U140_LHSARRTS_OFF` | ParamEmit.cpp, `lhsCloneArrayTs140` + `arrTsLhsOwnCopy140` (run after `impPaLhsDisjointClone133` in `drainShareDefParamTs`) | pass 133's residue R6 |
| § pkgRefFoldClonesMultiDimOnly140 | `R11U140_PKGREFMD_OFF` | ParamEmit.cpp, `emitParameters`, the ParameterFromPkg* clone case (`pkgRefSrc` hit, beside § pkgScopedParamRhsTs60) | pass 133's residue R5; ParamFromPackage's reference name |
| § pkgTypedefCastTargetTs140 | `R11U140_PKGTDCAST_OFF` | ExprEmit.cpp, the cast-target chain of the Conversion case (`pkgTdCast140Pending`); bound in ParamEmit.cpp `drainShareDefParamTs` | N0024's package-cast face (def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot) |
| § defaultFillOneConstant140 | `R11U140_DEFFILL_OFF` | ParamEmit.cpp, `emitParameters`, the `'{default: X}` unpacked-array expansion | the `depth` head of ParamArrayUnsizedPattern, DefaultPatternModule, DefaultPatternInt |
| § replCountFoldFile140 | `R11U140_REPLCNTFILE_OFF` | ParamEmit.cpp, `emitParameters`, the replication-count fold of an unpacked-array pattern | N0394 (`file|constant|ours-empty|under:operation`, the ParamEmit share) |

Switch helper: `r11u140On` in EmitHelpers.h (its block lists every switch). `R11U140_OFF=1` restores pristine
bytes on all 108 case databases of this directory (evidence/switches.txt: `byte-identical to pristine on 108 of
108 cases`; the law binary without the switch differs from pristine on 88). Each single switch moves only its
own grid's cases (evidence/switches.txt): SYSUNARY `sca/*` (25), STREAMBRACE `stm/*` (9; s01 has no whitespace
and is its control), LVIDX `plv/l01 l05 l06 l08`, LVTRAIL `plv/l02 l03 l04 l10`, FEFILE `fav/f01 f02 f04 f05`,
PATOPSPAN `pso/p01 p04-p09`, MULTIDECL `mdi/d01-d03 d05-d07`, LHSARRTS `lat/*` + `dfl/d02`, PKGREFMD
`pfp/g01-g03 g05-g11 g15 i01 i02 i04`, PKGTDCAST `tdc/c01 c05 c06`, DEFFILL `dfl/d01-d03 d05`, REPLCNTFILE
`rcf/r01 r02`.

### § sysArgUnaryWholeSpan140 (N0245)
A unary operation that is directly a system call's argument was anchored at its operator token
(`op->VpiEndColumnNo(col + 1)`, landed for BitsCallOnExpression `dr_q[$bits(~dr_q)-1:0]`). CENSUS over every
judge-equal golden (evidence/census_unary_sysarg.txt, drivers/cen.cpp `unarysys`): 147 such operations agree
with ours, 35 differ, and golden's operator-token span occurs ONLY under a ranged part-select; the grid adds the
parameter initializer (`sca/r08_param`, `localparam int P = $bits(~a)`: golden 3:28-29) as the second constant
context. THE LAW: the whole unary expression (slang's range, parentheses excluded: ComplexExprSize
`$unsigned((~&(8'ha4)))` golden 4:41-50) everywhere but a ranged part-select bound (`inPsRangeBound`) and a
parameter initializer (`inParamInit`). Grid `sca/`: `$bits`/`$signed`/`$unsigned`/`$clog2` over `~ - ! &` in a
continuous assignment, a process, a bit-select and an indexed part-select index -> equal (r03 r05 r07 s01-s03
t01-t04); `$size $high $low $left $right` move to their next face (the elaborated listing folds the call where
golden keeps the sys_func_call, `type`), `$clog2` to `count`; the stage-1 cells ($countones, $onehot, ...) move
their operation span toward golden (dump distance 35 -> 31, evidence/grid_stage1_bytemovers.txt); r01 r06
(ranged part-select) and r08 (parameter) unchanged.

### § streamOperandBraceSpan140 (N0050, N0060)
The stream operation of `{ << real { q }}` is located at its operand braces; ours took the operands' range
widened by one column each side, which is the braces only for `{q}`. Golden (v93_crash_min 10:15-20,
g29_f_head 14:41-52, and the multi-line grid cell `stm/s09`: 3:18-5:4) includes whitespace and line breaks
between the braces and the operands. THE LAW scans the source text between the whole streaming expression's
ends and the first/last operand for the enclosing `{`/`}` (spaces, tabs, line breaks skipped) and spans them;
a macro-born or cross-buffer location answers nothing and keeps the old span. Grid `stm/`: s02-s10 -> equal
(sliced, `>>`, process, lvalue, cast, tab, multi-line, single operand); s01 (no whitespace) is the control.
Probe: 17 cases convert (the r10uvm93 and r10buvm29 stream grids).

### § procLvTrailIdxNamesByPath140 and § procLvBaseSelTrailAtIdx140 (N0061, pass 133's R8)
In a PROCESS LVALUE the trailing select's variable index is named by its parent chain exactly as pass 133 measured
for an rvalue (`s.sat[i] = 1'b1` golden `work@dut.s.sat[i].i`; `s.sat[i + 1]` `work@dut.s.sat[i + 1].sat.i`;
`w.f.sat[i]`; an `always_ff` nonblocking write), which `trailSelIdxNames133` now also applies there (both
sites). And when the path's BASE is selected (`tbl[r].sat[i] = ...`, struct_member_trailing_index
`d[pc][row].sat[hist] = val`), the trailing bit_select anchors at its INDEX and stores the path's name
(`tbl[r].sat[i]`, golden 15:16-17), as the cont-assign lvalue branch already does; a plain base keeps the
member+index span with the lazily frozen doubled name (l01, golden agrees). Grid `plv/`: l01 l02 l05 l06 l08 ->
equal, l07 (constant index) the control; l03 l04 l10 (unpacked bases, stage 1 on both) move their dump
distance down (24 -> 18, 10 -> 4, 8 -> 2). Corpus: struct_member_trailing_index, struct_dynamic_range -> equal.

### § foreachArrayPlaceholderFile140 (N0041)
The unsupported_typespec a foreach mints for an unresolvable array reference copied the reference's line and
columns but not its file. CENSUS over every judge-equal golden: 19158 located unsupported_typespecs, every one
with a file; ours 9554 without (evidence/census_unsupported_typespec_file.txt), all of them this placeholder
(`ref_typespec < ref_var < foreach_stmt`). THE LAW copies the reference's file too (golden ClassVar `dut.sv
16:11-16`). Grid `fav/`: f01 f02 f04 f05 -> equal, f03 (module array, resolved) the control. Corpus:
ClassVar/default -> equal; probe 4 cases convert and 25 more lose most of their `file` count (the class-typespec
remainder is TypeEmit's).

### § elabPatOperandRefSpan140 (N0212)
An assignment-pattern package parameter read unqualified as an OPERAND of an elaborated parameter initializer
(`parameter int VALUE = VALUE_TEMP + 2` with `VALUE_TEMP = '{default: 1}`) is substituted by the pattern's own
operation, which ours left at the package declaration (2:30-43). Golden (ParamScope 11:25-35 in both elaborated
listings, the override copy in `bottom_u` included) locates that operation — its top node only; its children
keep the package spans — at the READING reference, file included. The source comment at the site measured the
opposite on the pilot pin; v1.87 relocates. Grid `pso/`: p01 p05-p09 (left/right operand, nested, override
copy, localparam, header import) -> equal; p04 (whole initializer, stage 1) moves its dump distance 24 -> 18;
p02 (qualified) and p03 (module-local) untouched (stage 1 on both).

### § multiDeclOneItem140 (N0053)
A subroutine body with more than one item gets a synthesized `begin` anchored at its SECOND item, and ours
counted items per slang VariableDeclaration, one per declarator. Surelog counts data_declarations: `logic [7:0]
result, temp;` is ONE item (golden func_local_compound_xor's body begin 19:5-20, the first statement after the
declaration; ours 18:5-30, the declaration itself; r10svs2 s4 `int i, r;` golden 14:5-47). THE LAW skips every
further declarator of the first item's declaration, in both item lists (block items and tf items). Grid `mdi/`:
d01-d03 d05-d07 -> equal (function, three declarators, task, two multi-declarator declarations, class method,
initialized declarators); d04 (one declarator per line) the control.

### § impLhsCloneArrayTsOwnCopy140 (pass 133's R6)
Pass 133's § impPaLhsDisjointClone133 gives an imported parameter's param_assign Lhs its own copy with a fresh
reference to the SAME typespec. For an unpacked-array parameter golden's copy reaches a PRIVATE array_typespec
whose range (`[N]` -> `0 : N-1`) is listed again under it (param_unpacked_struct_array `range 15:25-26`); the
walk had already visited our shared array_typespec's range, so our copy listed the element reference first
(`type`). The same shape holds for a body import's separate Lhs (lat/a03). THE LAW (a post-pass after pass 133's):
in every package and definition module/interface listing, a param_assign Lhs parameter that is not the listed
object but reaches a listed parameter's array_typespec gets a copy of it — every field, ranges deep-copied as
pass 133 copies the parameter's own ranges, a fresh element reference. FENCES: bounds, an index typespec, a
resolution function or a typedef alias keep the typespec shared; so does a NAMED non-aggregate element (a vector
typedef such as Earlgrey's hmac `sha_word_t InitHash[8]`: golden's copy lists a bare-named per-use clone of the
element, § castPkgVecTdBareViewClone123's shape, and listing the shared `hmac_pkg::sha_word_t` there made
uhdm-cmp read the name — measured, fenced). Grid `lat/`: a01-a03 a05 -> equal; a07 (pass 133's l04 twin) moves
to its next face (`line`); a04 a06 (stage 1) halve their dump distance (250 -> 130, 170 -> 98). Corpus: Kmac/default,
param_unpacked_struct_array, param_struct_field_bitsel -> equal; the ibex rows lose the structural divergence
that hid their tails (below).

### § pkgRefFoldClonesMultiDimOnly140 (pass 133's R5)
The ParameterFromPkg* case (an elaborated parameter defaulted to a bare reference to a materialized package
parameter, `P = X`) cloned X's folded constant and X's typespec for every parameter type. Golden does so only
when the reference is QUALIFIED (`int own2 = src::SA`, r10earl60 v60d; `int P = aes_pkg::XI`, pfp/g13) or the
parameter is an aggregate (a multi-dimension packed array, ParamFromPackage `logic [7:0][3:0] P = X`, a
`w_t` typedef of that shape, `bit [7:0][3:0]`; a packed struct, r11u108 `s_t P = D`); an UNQUALIFIED read into a
SIMPLE integral parameter (a keyword integer, a scalar, a one-dimension vector) is re-folded with the
parameter's OWN typespec (`int P = XI`, `logic [31:0] P = X`, `int P = X` over a 2-D X; the import copy
`InfosPerBank = FLASH_INFO_PER_BANK` of IntegerConcat, int_typespec 3:11-14 not 2:12-15; pass 133's lhs cells
l01 l07 l09 l11). And where the clone happens for a MULTI-DIMENSION packed parameter in an elaborated module
WITH a parameter port list (the § modDefImportShape flip), the clone's reference carries the DEFINITION's name
(golden `work@aes_cipher_core`, `work@cc`); without a port list (r11u124 c12 a09/a10) or for an enum/string
parameter (c12 a06/a11, r11u133 l10) it keeps the instance's — each of those was measured as a regression of an
earlier cut and fenced. Grid `pfp/`: g01-g03 g05-g11 g15 i01 i04 -> equal; g12 g14 (struct) and g13 (qualified)
the controls; g16 (no port list) the fence's own cell. Corpus: ParamFromPackage, IntegerConcat -> equal; probe
b27_pkpar_of_pkpar, k3_unq_ovr convert.

### § pkgTypedefCastTargetTs140 (N0024's package-cast face)
`localparam cfg_t C = cfg_t'(0)` in a package: the cast names a package STRUCT typedef, which the package lists
only after its parameters, so the cast-target chain fell to the size-cast fallback and minted an
integer_typespec at the name token (and an "unsupported" exit, rc 4). Golden targets the typedef's own
struct_typespec (def_ctx_struct_param 11:11-15:4). THE LAW makes the cast's reference (named like the other
package cast refs) and binds it to the typedef's listed typespec at the end of the export (the deferred list is
drained in `drainShareDefParamTs`); only a struct/union typedef of the package being emitted, outside a
subroutine. Grid `tdc/`: c01 c05 c06 -> equal (c05, the `p::cfg_t'` spelling, was stage 1 with 108 uhdm-cmp
lines and reads equal), rc 4 -> 0; c02 c03 (vector, enum) and c04 (module) untouched. Corpus: def_ctx_struct_param,
latch_decoder_partial, latch_tlb_napot move from `type` at record 36 to `depth` at record 43 — the walk now
reaches the typedef's members, whose XLEN carries the constants of the function-built override `Cfg =
build_config()` (the typedef typespec mutated by the member-default rule of the type ground, residue 7).

### § defaultFillOneConstant140 and § replCountFoldFile140 (N0394's ParamEmit share)
`'{default: X}` on an unpacked-array parameter expands, in the elaborated views, to an array_expr: golden fills
every element with ONE constant object (the walk lists it once), ours minted one per element (ParamArrayUnsizedPattern,
DefaultPatternModule, DefaultPatternInt: `depth`). And the replication count of `'{N{'1}}`, folded to N's value,
carried the reference's span without its file (golden `dut.sv 6:62-71`). Grids `dfl/` (d01 d03 move to the
continuous-assignment fold's face, residue 1; d02 d05 stage 1 move toward golden, 94 -> 74 and 123 -> 111 with 136
-> 112 uhdm-cmp lines) and `rcf/` (r01 r02 move to the same cont_assign face; r03 literal count the control).
Corpus: ParamArrayUnsizedPattern (both), DefaultPatternModule/default -> equal.

## Census (the whole status column, law sweep vs pristine sweep, row by row)

Sweeps: `tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil"`, workdirs `/tmp/r11u140_wdP` (pristine) and
`/tmp/r11u140_wdL` (law), same length. The pristine sweep reads `regressions=0 conversions=0 changes=0` in all three
stages against the committed baselines (evidence/sweep_pristine_vs_baselines.txt). Law vs committed
(evidence/sweep_law_vs_baselines.txt):

| | regressions | conversions | changes |
|---|---|---|---|
| probe | 0 | 23 | 46 |
| surelog | 0 | 13 | 20 |
| uhdm2rtlil | 0 | 10 | 32 |

Every row whose status or strict cell differs between the two sweeps (144 = 46 conversions + 98 changes) was
re-measured record by record (drivers/firstrec.py, evidence/strict_changes_first_record.txt): 46 EQUAL, 37 LATER
(the first differing record is further along the walk), 37 SAME-FEWER (same first record, fewer objects), and 24
whose count GROWS on the same first record — every one checked with drivers/worse2.py (pass 131's rule: no record
that matched golden under pristine differs under the law before either walk diverges, and the law's divergence is
not earlier), evidence/count_growth_record_check.txt, 24 / 24 OK:

| rows | pristine -> law | why it grows |
|---|---|---|
| ibex_alu, ibex_branch_predict, ibex_compressed_decoder, ibex_decoder, ibex_icache, ibex_multdiv_fast, ibex_multdiv_slow, ibex_wb_stage, ibex_tracer (both modes) | `fullname(2)` -> `fullname(9..200)` (tracer 87 -> 587) | the pristine walk diverged structurally at the PmpCfgRst Lhs copy (record ~5640, R6's `type`); § impLhsCloneArrayTsOwnCopy140 removes it (divL=None), so the tail of every ibex design is compared for the first time: its first record is still N0008 (sister) and the new ones are revealed faces (residue 13) |
| ibex_pmp (both) | `file(6)` -> `file(60)` | the same; divergence 5647 -> 13972 |
| Earlgrey_0_1 (both) | `line(1051)` -> `line(1785)` | divergence 51100 -> 130430 (52346 -> 131904), 4 early records gone, none new |
| probe r11u10repro/grid/h9_1e1m_port, hD_1e1mvec | `fullname(2)` -> `fullname(7)` | divergence 114/129 -> none |

Byte level (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law vs pristine workdir,
evidence/byteverify_*.txt): surelog `PATH_SETS_IDENTICAL (960 paths)`, `MOVERS: 35 / 960`, selfcheck 959/960;
uhdm2rtlil `PATH_SETS_IDENTICAL (1608 paths)`, `MOVERS: 42 / 1608`, selfcheck 1607/1608; probe databases 70 / 4087
moved (evidence/probe_movers.txt). PREDICTED BY NAME from the pristine databases (drivers/predict140.cpp, run on
every pristine database before the law sweep, evidence/predictions_pristine.txt): **147 / 147 movers predicted, 0
unpredicted**; movers by trigger (a database can carry several): FEFILE 51, LHSARRTS 38, STREAMBRACE 30, MULTIDECL
25, LVIDX 15, PKGREFMD 14, SYSUNARY 9, PKGTDCAST 7, DEFFILL 6, PATOPSPAN 3, LVTRAIL 2, REPLCNTFILE 2. The predicate
is wider than the laws: 172 predicted databases did not move (MULTIDECL 100 — a first declaration with several
declarators whose begin golden also anchors there; PKGREFMD 49 — clone-arm rows that keep the clone; PATOPSPAN 20
— the interface-port-view pattern operations, whose golden keeps the package span; LVIDX 3). The UVM family
(MiniAmiq, SeqDriver, SimpleUVM, Scoreboard) moves, predicted (FEFILE, STREAMBRACE, MULTIDECL); every one of the 147
movers passes the record-level check (evidence/movers_record_check.txt: 147 OK).

## Gates

1. Build: md5s above; the pristine rebuild is byte-identical to the main tree's `build/slang-uhdm`.
2. Probe: `regressions=0` vs `results/golden_probe.csv`; EQUAL 2221 -> 2244, STRICT_NOTEQUAL 1866 -> 1843; every case
   stays judge-equal.
3. Corpora: `regressions=0` in both (surelog conversions 13 changes 20; uhdm2rtlil conversions 10 changes 32);
   uhdm-cmp statuses unchanged on every row (480/3 + 474/3, 803/1/67 both modes).
4. Downstream (`tests/sweep.sh --corpus downstream`, law binary, evidence/downstream_summary.txt):
   `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`; joined to
   `results/downstream_uhdm2rtlil.csv` on every column: 0 of 871 rows changed (pass 120's eight rows and every
   earlier target row stay IDENTICAL). The sweep exits 1 only on `law index STALE`, true at the base as well
   (evidence/sweep_pristine_vs_baselines.txt, first line) and fixed by the regenerated tests/LAWS.md of this patch.
5. uhdm-cmp: every touched row keeps judge-equality (the status join), every probe case judge-equal; the grid's
   stage-1 cells keep or lower their uhdm-cmp line counts (evidence/grid_stage1_bytemovers.txt).
6. Byteverify and predictions: above.
7. Canaries: `canaries.sh` law surelog csv vs committed: ok=39 changed=13 — the 13 are the strict cells of predicted,
   record-checked movers (Earlgrey_0_1, SVSwitch, ApbSlave, SimpleUVM, SeqDriver, BuildUVMPkg, Scoreboard); the
   pristine csv reads ok=52 changed=0; uhdm2rtlil ok=16 changed=0. `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: PASS ok=58;
   `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil: PASS ok=2.
8. Earlier passes' cases as byte controls (pristine vs law, evidence/controls_earlier_passes.txt, 1280 databases):
   r11u118repro 0/56, r11v11u118repro 0/56, r11u119repro 0/78, r11u120repro 0/44, r11v120repro 0/47,
   r11u121repro 0/83, v11u121repro 0/41, r11v124repro 0/109, r11u125repro 0/61, r11v125repro 0/48,
   r11u130repro 0/98, r11v130repro 0/115, r11u131repro 0/121, r11v131repro 0/128, r11u124repro 7/81,
   r11u133repro 7/50, r11v133repro 10/64. Every mover judged against golden (evidence/controls_movers_verdicts.txt,
   controls_movers_record_check.txt): 18 of 24 move to STRICT_EQUAL (c12 a01 a03 a04 a07 a08 a12 a13, lhs l01 l07 l09
   l11, tix t08, c01 c04 c06 c08 h05, tix f09); l02 c02 c09 record-level OK (same cell); l04 moves `type` -> `line`
   (divergence 93 -> none); c03 c10 (stage 1 on both) keep their uhdm-cmp line count and dump distance.

## Decoded, not landed (ranked residues)

R1 — PatternStruct's head (N0394's ModuleEmit share) and the `dfl`/`rcf` cells' next face: the packed-struct
net-declaration pattern `my_struct s = '{word: 125}` folds to an op75 over a `tryFoldConst` constant that
ModuleEmit.cpp `emitContAssigns` never locates (golden 5:26-29, the member value); a continuous assignment
reading an unpacked-array parameter element (`assign o = A[0]`) keeps golden's bit_select or its constant at the
default value's span. Sister ground (emitContAssigns, the "PACKED-struct assignment-pattern net-decl RHS" block).

R2 — N0284 (FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array, 29 probe cases alone):
golden keeps the `func_call` (or shares the parameter's constant object) where ModuleEmit's continuous-assignment
fold (emitCaStructParamSubst55 / the cont_assign `tryFoldConst` sites) mints a fresh constant. Sister ground.

R3 — N0063: the nested pattern's typespec reference minted in ExprEmit.cpp `emitExpr` (the assignment-pattern case,
`nestedPat` ts ref) is, in golden, parented at the operation and named with the interface PORT VIEW's full name
(`work@iface_nested_param_field.u.sub`) while the elaborated instance's copy stays bare; the port view is known only
to ModuleEmit.cpp `emitInterfaceInstance` (portView), which calls `emitParameters` identically for both. Needs a
port-view flag from the sister ground.

R4 — ParamNoImport / StructParamPatternInitCast (fullname 2): the package listing's pattern operation shares its
typespec reference with a module-side use; golden gives the package listing an unnamed, unparented reference
(§ pkgPatReadTsNoParent131's read set: ParamNoImport is fenced there as `hiConnOps131`; a `pkg::NAME` inside a call
argument of a parameter default — pkgPatCallArgParam58's set — is not in it). ParamEmit `drainShareDefParamTs`;
needs the module use to keep its own copy.

R5 — `Cfg.XLEN'(1)`: a size cast whose size is a struct-parameter member takes, in golden, the struct parameter's
typespec (`struct_typespec cfg_pkg::cfg_t`) where ours mints an integer_typespec (cva6_struct_param_field,
StructParamFieldRange, the r11u109 f1 grid's 20 probe cases). ExprEmit cast-target chain, the size-cast case; the
rows also carry TypeEmit faces (N0009 struct span, N0001 base-ref column).

R6 — N0001/iface rows (iface_cfg_mem, iface_param_2level, iface_nested_param_field, iface_scalar_localparam, ...):
the struct-parameter member path's base ref at the member token and the leaf unnamed, built by TypeEmit.cpp
`emitSyntaxExpr` (pass 131's R2; sister).

R7 — def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot after § pkgTypedefCastTargetTs140: the package
typedef's struct typespec carries member default-value constants from the function-built override (the type
ground's member-default rule mutates the shared typedef, N0045; sister).

R8 — StructArrayParameterInitializedByPatternPassedAsPort / Nested...: a pattern parameter passed as a port
connection is located at the package span where golden relocates it to the reference (the port twin of
§ elabPatOperandRefSpan140) and its typespec reference name is doubled (`u_hw_sel.u_hw_sel`); ModuleEmit.cpp
`emitInstance` high-conn substitution. Sister ground.

R9 — MacroArgMismatch (`` d <= `D (~d) ``: every span on the line one column right): the macro line/column
model, UhdmExporter.cpp `locLineCol`. Sister ground.

R10 — ExplictiPorts (N0055/N0079): explicit port expression operands (`module c(.a({b, c}))`) located at the
declarations; ModuleEmit port low-conn (the sister pass's own residue 3).

R11 — ImplicitPackedStructNet/testflags, InterfArrayBind: a base-select index named by the path only in the
-elabuhdm views (UHDM ElaboratorListener's clone, uhdm_main ground).

R12 — jeras_tcb_gpio: ranged part-select bound refs inside a process-lvalue path (`bus.wdt[GW - 1:0]`, golden
`work@tcb_gpio.bus.wdt[GW - 1:0].wdt.GW`; iface_scalar_localparam's `sub.adr[ADR - 1:]` in a cont_assign) — the
part-select twin of § procLvTrailIdxNamesByPath140 (ExprEmit `emitMixedHierPath`, not landed); plus the gen-if
hier_path `bus.DLY` (base at the leaf's span, leaf unnamed: the N0001 shape).

R13 — revealed by § impLhsCloneArrayTsOwnCopy140 on the ibex rows (evidence/count_growth_record_check.txt): after the
N0008 head (TypeEmit, sister), qualified package-parameter folds under param_assign span the whole `pkg::NAME`
where golden spans the qualifier (ibex_alu `RV32B = ibex_pkg::RV32BNone` 10:39-58 vs 10:39-49) or the name
(`ibex_pkg.sv 384:45-53` vs 45-55): N0005's family (ParamEmit, § pkgQualSpan133's neighbourhood).

R14 — pass 133's R7 (a base select's index inside an operation operand, probe mode) and pass 133's R2
(§ pkgPatInPkgReadNoParent133r) are unchanged.

## Cases (first line of every case names its law; pristine and law verdicts, evidence/grid_pristine_vs_law.txt)

60 of 108 cases move to STRICT_EQUAL, 9 are equal on both binaries (controls), none leaves equality; every other
moved judge-equal cell passes the record check (evidence/grid_record_check.txt) and every moved stage-1 cell keeps
or lowers its uhdm-cmp line count and dump distance (evidence/grid_stage1_bytemovers.txt).

| case | law (first line) | pristine | law binary |
|---|---|---|---|
| `dfl/d01_mod_int` | § defaultFillOneConstant140 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL file |
| `dfl/d02_pkg_import` | § defaultFillOneConstant140 | cmp=36 NOT_EQUAL stage1 | cmp=36 NOT_EQUAL stage1 |
| `dfl/d03_unsized_ones` | § defaultFillOneConstant140 | cmp=0 STRICT_NOTEQUAL depth | cmp=0 STRICT_NOTEQUAL file |
| `dfl/d04_single_ctl` | § defaultFillOneConstant140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_NOTEQUAL file |
| `dfl/d05_four` | § defaultFillOneConstant140 | cmp=136 NOT_EQUAL stage1 | cmp=112 NOT_EQUAL stage1 |
| `fav/f01_local_queue` | § foreachArrayPlaceholderFile140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 32 objects |
| `fav/f02_class_prop` | § foreachArrayPlaceholderFile140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 33 objects |
| `fav/f03_module_initial` | § foreachArrayPlaceholderFile140 | cmp=0 STRICT_EQUAL 54 objects | cmp=0 STRICT_EQUAL 54 objects |
| `fav/f04_pkg_func` | § foreachArrayPlaceholderFile140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 61 objects |
| `fav/f05_two_dims` | § foreachArrayPlaceholderFile140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 47 objects |
| `lat/a01_hdr_struct_arr` | § impLhsCloneArrayTsOwnCopy140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 380 objects |
| `lat/a02_hdr_int_arr` | § impLhsCloneArrayTsOwnCopy140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 170 objects |
| `lat/a03_body_import_ctl` | § impLhsCloneArrayTsOwnCopy140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 170 objects |
| `lat/a04_pkg_imports_pkg` | § impLhsCloneArrayTsOwnCopy140 | cmp=184 NOT_EQUAL stage1 | cmp=184 NOT_EQUAL stage1 |
| `lat/a05_hdr_range_arr` | § impLhsCloneArrayTsOwnCopy140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 162 objects |
| `lat/a06_hdr_2d_arr` | § impLhsCloneArrayTsOwnCopy140 | cmp=304 NOT_EQUAL stage1 | cmp=304 NOT_EQUAL stage1 |
| `lat/a07_l04_twin` | § impLhsCloneArrayTsOwnCopy140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_NOTEQUAL line |
| `mdi/d01_func_two` | § multiDeclOneItem140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 145 objects |
| `mdi/d02_func_three_decl` | § multiDeclOneItem140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 141 objects |
| `mdi/d03_task` | § multiDeclOneItem140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 49 objects |
| `mdi/d04_single_decl_ctl` | § multiDeclOneItem140 | cmp=0 STRICT_EQUAL 125 objects | cmp=0 STRICT_EQUAL 125 objects |
| `mdi/d05_two_decls` | § multiDeclOneItem140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 149 objects |
| `mdi/d06_class_method` | § multiDeclOneItem140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 60 objects |
| `mdi/d07_init_decl` | § multiDeclOneItem140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 131 objects |
| `pfp/g01_hdr_ovr` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 141 objects |
| `pfp/g02_hdr_noovr` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 127 objects |
| `pfp/g03_body_import` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 141 objects |
| `pfp/g04_qualified` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL endcol |
| `pfp/g05_hdr_two_inst` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 182 objects |
| `pfp/g06_body_param` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 141 objects |
| `pfp/g07_int_hdr` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 103 objects |
| `pfp/g08_vec32` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 174 objects |
| `pfp/g09_typedef` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 210 objects |
| `pfp/g10_int_int` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 162 objects |
| `pfp/g11_bit_same` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 186 objects |
| `pfp/g12_struct_unq` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL endline | cmp=0 STRICT_NOTEQUAL endline |
| `pfp/g13_int_qual_imp` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_EQUAL 325 objects | cmp=0 STRICT_EQUAL 325 objects |
| `pfp/g14_struct_qual_imp` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL endcol |
| `pfp/g15_int_body_localparam` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 325 objects |
| `pfp/g16_body_noports` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_EQUAL 127 objects | cmp=0 STRICT_EQUAL 127 objects |
| `pfp/i01_imp_int_body` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 102 objects |
| `pfp/i02_imp_md_body` | § pkgRefFoldClonesMultiDimOnly140 | cmp=50 NOT_EQUAL stage1 | cmp=50 NOT_EQUAL stage1 |
| `pfp/i03_imp_md_hdr` | § pkgRefFoldClonesMultiDimOnly140 | cmp=50 NOT_EQUAL stage1 | cmp=50 NOT_EQUAL stage1 |
| `pfp/i04_imp_int_hdr` | § pkgRefFoldClonesMultiDimOnly140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 86 objects |
| `plv/l01_plain_struct` | § procLvTrailIdxNamesByPath140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 247 objects |
| `plv/l02_packed_arr_base` | § procLvBaseSelTrailAtIdx140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 261 objects |
| `plv/l03_unpacked_2d` | § procLvBaseSelTrailAtIdx140 | cmp=58 NOT_EQUAL stage1 | cmp=58 NOT_EQUAL stage1 |
| `plv/l04_unpacked_1d` | § procLvBaseSelTrailAtIdx140 | cmp=58 NOT_EQUAL stage1 | cmp=58 NOT_EQUAL stage1 |
| `plv/l05_ff` | § procLvTrailIdxNamesByPath140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 243 objects |
| `plv/l06_deep` | § procLvTrailIdxNamesByPath140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 258 objects |
| `plv/l07_const_idx` | § procLvTrailIdxNamesByPath140 | cmp=0 STRICT_EQUAL 246 objects | cmp=0 STRICT_EQUAL 246 objects |
| `plv/l08_op_idx` | § procLvTrailIdxNamesByPath140 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 251 objects |
| `plv/l10_unp_const_base` | § procLvBaseSelTrailAtIdx140 | cmp=58 NOT_EQUAL stage1 | cmp=58 NOT_EQUAL stage1 |
| `pso/p01_imp_left` | § elabPatOperandRefSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 70 objects |
| `pso/p02_qual_left` | § elabPatOperandRefSpan140 | cmp=64 NOT_EQUAL stage1 | cmp=64 NOT_EQUAL stage1 |
| `pso/p03_local` | § elabPatOperandRefSpan140 | cmp=74 NOT_EQUAL stage1 | cmp=74 NOT_EQUAL stage1 |
| `pso/p04_imp_whole` | § elabPatOperandRefSpan140 | cmp=103 NOT_EQUAL stage1 | cmp=103 NOT_EQUAL stage1 |
| `pso/p05_imp_right` | § elabPatOperandRefSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 70 objects |
| `pso/p06_imp_nested` | § elabPatOperandRefSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 74 objects |
| `pso/p07_imp_sub` | § elabPatOperandRefSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 95 objects |
| `pso/p08_localparam` | § elabPatOperandRefSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 70 objects |
| `pso/p09_hdr_import` | § elabPatOperandRefSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 70 objects |
| `rcf/r01_unsized` | § replCountFoldFile140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_NOTEQUAL type |
| `rcf/r02_sized` | § replCountFoldFile140 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_NOTEQUAL type |
| `rcf/r03_literal_ctl` | § replCountFoldFile140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_NOTEQUAL type |
| `sca/r01_ps_bits` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_EQUAL 107 objects | cmp=0 STRICT_EQUAL 107 objects |
| `sca/r03_bs_bits` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 105 objects |
| `sca/r05_proc_bits` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 101 objects |
| `sca/r06_proc_ps` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_EQUAL 109 objects | cmp=0 STRICT_EQUAL 109 objects |
| `sca/r07_ips_bits` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 107 objects |
| `sca/r08_param` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/r09_binop` | § sysArgUnaryWholeSpan140 | cmp=78 NOT_EQUAL stage1 | cmp=78 NOT_EQUAL stage1 |
| `sca/s01_bits` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `sca/s02_signed` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `sca/s03_unsigned` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `sca/s04_clog2` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL count |
| `sca/s05_countones` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/s06_onehot` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/s07_onehot0` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/s08_isunknown` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/s09_size` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL type |
| `sca/s10_high` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL type |
| `sca/s11_low` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL type |
| `sca/s12_left` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL type |
| `sca/s13_right` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_NOTEQUAL type |
| `sca/s14_increment` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/s15_dimensions` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/s16_countbits` | § sysArgUnaryWholeSpan140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `sca/t01_bits_neg` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `sca/t02_signed_neg` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `sca/t03_unsigned_not` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `sca/t04_signed_redand` | § sysArgUnaryWholeSpan140 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 88 objects |
| `stm/s01_nows` | § streamOperandBraceSpan140 | cmp=0 STRICT_EQUAL 101 objects | cmp=0 STRICT_EQUAL 101 objects |
| `stm/s02_ws` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 101 objects |
| `stm/s03_sliced` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 103 objects |
| `stm/s04_rl_ws` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 101 objects |
| `stm/s05_proc` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 106 objects |
| `stm/s06_lvalue` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 106 objects |
| `stm/s07_cast` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 133 objects |
| `stm/s08_tab` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 101 objects |
| `stm/s09_multiline` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL line | cmp=0 STRICT_EQUAL 101 objects |
| `stm/s10_single_ws` | § streamOperandBraceSpan140 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 98 objects |
| `tdc/c01_pkg_struct` | § pkgTypedefCastTargetTs140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 124 objects |
| `tdc/c02_pkg_vec` | § pkgTypedefCastTargetTs140 | cmp=76 NOT_EQUAL stage1 | cmp=76 NOT_EQUAL stage1 |
| `tdc/c03_pkg_enum` | § pkgTypedefCastTargetTs140 | cmp=17 NOT_EQUAL stage1 | cmp=17 NOT_EQUAL stage1 |
| `tdc/c04_mod_struct_imp` | § pkgTypedefCastTargetTs140 | cmp=0 STRICT_EQUAL 124 objects | cmp=0 STRICT_EQUAL 124 objects |
| `tdc/c05_pkg_struct_qual` | § pkgTypedefCastTargetTs140 | cmp=108 NOT_EQUAL stage1 | cmp=0 STRICT_EQUAL 124 objects |
| `tdc/c06_pkg_struct_unused` | § pkgTypedefCastTargetTs140 | cmp=0 STRICT_NOTEQUAL type | cmp=0 STRICT_EQUAL 96 objects |

## Files

* `sca/ stm/ plv/ fav/ pso/ mdi/ lat/ pfp/ tdc/ dfl/ rcf/` — the law grids (108 cases).
* `drivers/`: `run_case.sh` (one case: golden with the probe flags, cached by content md5; ours; uhdm-cmp;
  strictcmp), `grid.sh` (a list of cases on pristine and a law binary), `cx.sh` + `ctx.sh` + `anc.py` (a case's or a
  pair's differing strict records with their ancestors), `pairs.py` (every judge-equal row-mode and probe case of a
  sweep with its golden), `firstrec.py` (first differing record, pristine vs law), `worse2.py` (record-level
  worsening check, pass 131's rule), `bytes.sh` (byte compare of every case under a directory), `switches.sh`
  (master and single switches over the grids), `probe_sub.sh`, `cen.cpp` (walk census: `unarysys`, `opctx <type>`),
  `predict140.cpp` (mover prediction from pristine databases), `findrank.cpp` (an object's creation rank, for a
  gdb `ignore`). Build a C++ driver with `g++ -std=gnu++20 -include uhdm/config.h X.cpp -I ~/.local/include
  ~/.local/lib64/libuhdm.a ~/.local/lib64/libcapnp.a ~/.local/lib64/libkj.a -ldl -lpthread`.
* `evidence/`: sweep gates (pristine and law), downstream summary and csv, byteverify, predictions, record checks,
  switches, grids, censuses, earlier-pass controls, canaries.
