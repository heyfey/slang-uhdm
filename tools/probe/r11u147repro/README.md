# r11u147 — the expression/parameter ground of the strict axis, sixth refill (implementer), landing r11u151's structural law too (§ pkgTdCastTargetOwnView151, § blockLhsVarSelBindsWholeRef151, § nonblockingSelLhsBindsWholeRef151, § condTakenParamRhsShared151, § concatArrParamDefTs151, § patLeftoverOrphanCopy151, § hierSizeCastBaseStructTs151, § nestedPatOpTsNoParent151)

Base `1fb349a9` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`,
`TaskFuncEmit.cpp`, `uhdm_main.cpp` or `include/`; the faces whose fix sits there are decoded below and stop at the
decode. Net binding and § ipsQualBaseRangeSpan141v's hunk are not touched; passes 140/145's laws are not edited.
Worktree `/tmp/wt_r11u147`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base, byte-identical to the main tree's `build/slang-uhdm`) | `0d37333d17a0a6bc3c0f0e8fbfe21f8a` |
| law (this patch: the eight r11u147 laws + r11u151's `law_after_r11u145.patch`) | `d1b102e17317fc448653ec355f758fe0` |
| r11u147 laws alone (measured first, every gate below repeated on it; kept as the composition control) | `dd7a8cbda4cb57598dee73d6ea4b6fc2` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Every binary frozen (`chmod 555` copies) before measuring. Every `cmds.txt` of the pristine sweep names the pristine
copy (3273 / 3273 slang runs) and every one of the law sweep the law copy (3273 / 3273). The pristine sweep
(`/tmp/r11u147_wdP`) reads `regressions=0 conversions=0 changes=0` in all three stages against the committed
baselines (evidence/sweep_pristine_vs_baselines.txt); its only red is `law index STALE`, which this patch's
tests/LAWS.md fixes.

**The structural classes (brief item 1): r11u151's law, landed here.** `tools/probe/r11u151struct` did not exist at
this pass's start; it landed in the main tree (d10675dd) while this pass ran, with `law_after_r11u145.patch` (the
law rebased on 1fb349a9, without its DEFPAT class, which § defaultFillImportCopies145 already is). This pass applied
it on top of its own laws (src/EmitHelpers.h conflicted only where both blocks append at the end of the file; both kept),
kept its switches `R11U151_*`, made `R11U147_OFF=1` drop it too (`r11u151On` reads both master switches), rebuilt, and
re-ran every gate below on the composed binary. Its README's numbers re-verified on 1fb349a9 (its "composition with
r11u145" column): conversions surelog BlackParrotComplex d/t, uhdm2rtlil array_assign, def_ctx_struct_param,
latch_decoder_partial, latch_tlb_napot d/t (10 row-modes, all reproduced); probe changes 30 (all
`r11u109repro/grid/f1`, D + DCAST: 29 unmaskings, pristine "walk diverged" and law aligned, and `p03_ready` whose
first structural record moves later, #126 -> #284); surelog changes FuncStructVal d/t (default: first structural
record #7595 -> #7975, later; testflags #14385 -> #13254, count 377 -> 363: r11u151's R-D4), FuncStructValSimple,
StructParamFieldRange, StructParamFuncBodyFieldCompare, StructParamPatternInitCast d/t (unmaskings); uhdm2rtlil
NestedStructArray…PassedAsPort `fullname(4) -> line(2)` and cva6_struct_param_field `endcol(5) -> endcol(9)`
(unmasking); its 67 grid cases: 14 -> STRICT_EQUAL, none leaves STRICT_EQUAL, `R11U147_OFF=1` restores pristine bytes
on all 67 and each `R11U151_*` switch owns its own class (evidence/grid_r11u151_pristine_vs_law.txt,
evidence/switches_r11u151_grid.txt); downstream rows of every touched test IDENTICAL. Its ARR law also clears this
pass's two ARR evidence cases (`ipb/d1_lhs_vs_var`, `ipb/d4_lhs_vs_var_bs`: `w = '0; w[0][b] = 1` in one block,
stage 1 -> STRICT_EQUAL). The laws landed from it (sites and statements in tools/probe/r11u151struct/README.md):
§ pkgTdCastTargetOwnView151 (`R11U151_D2_OFF`), § blockLhsVarSelBindsWholeRef151 (`R11U151_ARR_OFF`),
§ nonblockingSelLhsBindsWholeRef151 (`R11U151_ARRNB_OFF`), § condTakenParamRhsShared151 (`R11U151_G_OFF`),
§ concatArrParamDefTs151 (`R11U151_G2_OFF`), § patLeftoverOrphanCopy151 (`R11U151_D_OFF`),
§ hierSizeCastBaseStructTs151 (`R11U151_DCAST_OFF`), § nestedPatOpTsNoParent151 (`R11U151_C3_OFF`); master
`R11U151_OFF` or `R11U147_OFF`.

**The fence.** No binary, script or reader touched a slang-fenced test's source. Every script that walks case
directories drops a path naming a fenced test (word boundary, from `$FENCED`, fail closed: drivers/bytes.sh). The
corpus sweeps are `tests/sweep.sh` runs, which dispatch every row the committed baselines hold, one fenced surelog
row included (written `FENCED_1` here, both modes); the census sweep is the same `tests/sweep.sh` run with
drivers/tracewrap.sh standing in for the binary. That row's only reads in this pass are its sweep verdicts, its
census firing (`ENUMCLONE`) and the strict comparator's field tally of the two databases the sweeps wrote
(evidence/fieldcmp.txt, redacted), exactly the reads map 6 made.

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 798 | **802** | +4 (`FENCED_1` d/t by § memberEnumCloneKeepsBase147, BlackParrotComplex d/t by r11u151's G) |
| uhdm2rtlil strict-equal (of 1606) | 1408 | **1434** | +26 (18 by the r11u147 laws, 8 by r11u151's D2 / ARR) |
| probe EQUAL (of 4087) | 2352 | **2407** | +55 |
| surelog / uhdm2rtlil judge-equal (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 rows changed on any column |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them)**, the fresh csv rows
(evidence/sweep_law_vs_baselines.txt), with the law the census names for each (drivers/tracewrap.sh,
evidence/census_fires.txt):

    uhdm2rtlil:
      latch_packed_dyn_write,default,CMP_EQUAL,,,equal                    § vsIpsBaseNamesByIps147 + § lvIdxBitSelAtIndex147
      latch_packed_dyn_write,testflags,CMP_EQUAL,,,equal                  (same)
      mem_packed_2d_byte_write,default,CMP_EQUAL,,,equal                  § vsIpsBaseNamesByIps147
      mem_packed_2d_byte_write,testflags,CMP_EQUAL,,,equal                (same)
      unpacked_elem_partsel_comb,default,CMP_EQUAL,,,equal                § vsIpsBaseNamesByIps147
      unpacked_elem_partsel_comb,testflags,CMP_EQUAL,,,equal              (same)
      multiplier,default,CMP_EQUAL,,,equal                                § firstOrderedConnBitSelWhole147 + § gcaUseSiteParamConst147
      multiplier,testflags,CMP_EQUAL,,,equal                              (same)
      SelectFromUnpackedInFunction,default,CMP_EQUAL,,,equal              § nestedDefaultPatLoc147
      SelectFromUnpackedInFunction,testflags,CMP_EQUAL,,,equal            (same)
      ParameterPassedTo3TimesNestedSubmodule,default,CMP_EQUAL,,,equal    § memberEnumCloneKeepsBase147
      ParameterPassedTo3TimesNestedSubmodule,testflags,CMP_EQUAL,,,equal  (same)
      ParameterPassedToSubmoduleInGenscopeOfSubmodule,default,CMP_EQUAL,,,equal     § memberEnumCloneKeepsBase147
      ParameterPassedToSubmoduleInGenscopeOfSubmodule,testflags,CMP_EQUAL,,,equal   (same)
      ParameterPassedToSubmoduleOfSubmodule,default,CMP_EQUAL,,,equal     § memberEnumCloneKeepsBase147
      ParameterPassedToSubmoduleOfSubmodule,testflags,CMP_EQUAL,,,equal   (same)
      SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule,default,CMP_EQUAL,,,equal    § memberEnumCloneKeepsBase147
      SubmoduleInGenScopeWithGenScopeParametrizedByParameterFromTopModule,testflags,CMP_EQUAL,,,equal  (same)
      array_assign,default,CMP_EQUAL,,,equal                              § blockLhsVarSelBindsWholeRef151 (r11u151 ARR)
      array_assign,testflags,CMP_EQUAL,,,equal                            (same)
      def_ctx_struct_param,default,CMP_EQUAL,,,equal                      § pkgTdCastTargetOwnView151 (r11u151 D2)
      def_ctx_struct_param,testflags,CMP_EQUAL,,,equal                    (same)
      latch_decoder_partial,default,CMP_EQUAL,,,equal                     § pkgTdCastTargetOwnView151
      latch_decoder_partial,testflags,CMP_EQUAL,,,equal                   (same)
      latch_tlb_napot,default,CMP_EQUAL,,,equal                           § pkgTdCastTargetOwnView151
      latch_tlb_napot,testflags,CMP_EQUAL,,,equal                         (same)
    surelog:
      BlackParrotComplex,default,CMP_EQUAL,,,equal                        § condTakenParamRhsShared151 + § concatArrParamDefTs151 (r11u151 G)
      BlackParrotComplex,testflags,CMP_EQUAL,,,equal                      (same)
      FENCED_1,default,CMP_EQUAL,,,equal                                  § memberEnumCloneKeepsBase147 (census only; no decode)
      FENCED_1,testflags,CMP_EQUAL,,,equal                                (same)

Probe: 55 cases `STRICT_NOTEQUAL -> EQUAL` (each reads `EQUAL,,equal` in the fresh probe.csv): § vsIpsBaseNamesByIps147
52 (`r11u116repro/grid/f2/g2_* g3_* gi_*` 32, `v11u116repro/cases/f2_* f2k_* f2p_ifif g2_child g2_modpar` 12,
`r11u112repro/grid/v/v02 v04 v06 v07 v10 v11` 6, `v11u112repro/grid/brk/v/b4a_opbase b4f_genlp_width` 2),
§ enumQualDefaultDefSpan147 3
(`r10earl106repro/h1_head106`, `r10earl_repro/aa`, `r11u111repro/grid/f1/a21_q_enum_ctl`)
(evidence/probe_conversions_attributed.txt).

Target rows (map 6's expression list and the brief's residues), before -> after:

| row | before | after | what is left |
|---|---|---|---|
| latch_packed_dyn_write d/t (N1053 + N0036) | fullname(2) | **CMP_EQUAL** | — |
| multiplier d/t (N0471 + N0702 + the first-connection span) | col(42) | **CMP_EQUAL** | — |
| SelectFromUnpackedInFunction d/t (N0109 + N0110 + N1114 + N1159) | file(2) | **CMP_EQUAL** | — |
| ParameterPassed… / SubmoduleInGenScope… (4 tests, d/t; S3 = N0057 + N0012) | file(2) | **CMP_EQUAL** | — |
| GenForIfaceLocalparamBound / …NestedGen d/t (N0077) | endcol(5) | endcol(1) | N0005's interface port-view span: sister ground (S1 below) |
| ibex_alu d/t (pass-145 R4) | fullname(2) | fullname(1) | #2449 the PmpAddrRst array typespec's range constant reference name (N0008 / pass-144 S1 face b) |
| PortInitVal d, PortInitVal2 d/t, sat_asserts_seq d/t (N0455 + N0456) | line(2) / line(18) | unchanged | sister ground (S2) |
| genscope_module_ctx_reset d/t (N1118) | fullname(1) | unchanged | sister ground (S3) |
| PatternStruct d/t (N0394 + N1140) | file(1) | unchanged | sister ground (S4) |
| StructArray… / NestedStructArray…PassedAsPort (C3) | line(2) / fullname(4) | line(2) / line(2) | § nestedPatOpTsNoParent151 took Nested's reference names; the span/name face is sister ground (S5; r11u151's pairB_c3_scratch.patch) |
| def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot d/t (D2) | depth(1) | **CMP_EQUAL** | — (r11u151) |
| array_assign d/t (ARR) | depth(1) | **CMP_EQUAL** | — (r11u151) |
| BlackParrotComplex d/t (G) | depth(1) | **CMP_EQUAL** | — (r11u151) |
| StructParamFuncBodyFieldCompare, StructParamPatternInitCast d/t (D) | depth(1) / fullname(2) | endcol(17) / fullname(17) | r11u151's R-D1..R-D3 (unmaskings: the walk now aligns) |
| StringMethod d/t (N0006 + N0765) | fullname(2) | unchanged | residue R2 |
| iface_struct_field_partsel, iface_arr_struct_field_partsel, anon_struct_packed_dim | fullname(15/4/43) | unchanged | residue R3 |
| comb_dyn_2d_packed_sel, ComplexParamOverload, MacroArgMismatch, YosysMarlann, PackedEnumPort, VarPassedTo2Submodules | — | unchanged | residues R4-R6 |

## Laws (all under `R11U147_OFF=1`, each droppable alone; `R11U147_TRACE=1` prints one stderr line per firing)

| law | switch | site (file + § token) | cluster |
|---|---|---|---|
| § ifaceMemberTrailIdxNamesByPath147 | `R11U147_IFTRAILIDX_OFF` | ExprEmit.cpp `ifaceTrailIdxNames147`, called at the end of `emitExpr`'s ElementSelect case "Element select over a DOTTED interface-member path" | N0077 |
| § vsIpsBaseNamesByIps147 | `R11U147_VSIPSBASE_OFF` | ExprEmit.cpp `emitExpr` RangeSelect, the var_select case's trailing indexed_part_select (`ipsBasePfx147`); EmitHelpers.h `vsIpsBaseNamesByIps147On` | N1053, N0820's shape, 52 probe cases |
| § lvIdxBitSelAtIndex147 | `R11U147_LVIDXBS_OFF` | ExprEmit.cpp `emitExpr` ElementSelect, the plain bit_select's location (`lvIdx147`); EmitHelpers.h `lvIdxBitSelAtIndex147` | N0036 |
| § nestedDefaultPatLoc147 | `R11U147_NESTDEFLOC_OFF` | ExprEmit.cpp `nestedDefaultValueSyntax147` + `nestedDefaultTsLoc147`, called at the `'{default: X}` setter of `emitExpr`'s StructuredAssignmentPattern case | N0109, N0110, N1114, N1159 |
| § gcaUseSiteParamConst147 | `R11U147_GCAUSESITE_OFF` | ExprEmit.cpp `gcaUseSiteParamRead147`, read beside `pa9` in the § genCaLoopParamFold window of `emitExpr` NamedValue | N0471, N0702 |
| § firstOrderedConnBitSelWhole147 | `R11U147_FIRSTPOS_OFF` | ExprEmit.cpp `firstOrderedConnSel147`, at the plain bit_select's location | multiplier's 36 `bit_select A` records |
| § memberEnumCloneKeepsBase147 | `R11U147_ENUMCLONE_OFF` | ParamEmit.cpp `emitPackage`, the member loop's per-use enum clone (`eSyn147`, `mec147`) | S3 = N0057 (+ N0012's package-listing face) |
| § enumQualDefaultDefSpan147 | `R11U147_ENUMQSPAN_OFF` | ExprEmit.cpp `emitExpr` NamedValue, the package enum-constant fold (`on147`) | pass-145 R4 |

Switch helper: `r11u147On` in EmitHelpers.h (its block lists every switch). `R11U147_OFF=1` restores pristine bytes
on all 68 case databases of this directory and on r11u151's 67; each single switch moves exactly its own grid's cases
(evidence/switches.txt, evidence/switches_r11u151_grid.txt; the `ipb/e*`, `f6`, `f7` and `d1` cases exercise both ipb
laws and are owned by both; `ipb/d1 d4` are owned by `R11U151_ARR_OFF` too; no r11u147 switch owns an r11u151 case and
no r11u151 switch owns an r11u147 case outside `d1 d4`).

### § ifaceMemberTrailIdxNamesByPath147
§ hpTrailSelIdxNamesByPath133 names the index of a path's trailing select by the path; the dotted interface-member
builder (`sub.ben[s]`, `sub.req.arr[i]` through an interface port, a modport or an instance) only named the gen-scope
PROCESS form. Golden (grid `tsi`): the index reference under the trailing bit_select is `<scope>.<path>.<name>`
everywhere — a gen-scope continuous assignment (GenForIfaceLocalparamBound `work@top.c.g[0].sub.ben[i].i`, ours
`work@top.c.g[0].i`), a module-body continuous assignment and process (`work@child.sub.ben[s].s`), a function body
(`work@child.f.sub.ben[k].k`), a top-level interface instance (`work@top.sub.ben[s].s`), a modport port and an
operand position; a reference under an operation index is `<scope>.<path>.<leaf>.<name>` (`...sub.ben[i + 1].ben.i`).
Cases `tsi/a2 a3 a4 b3 b4 b5 b6` -> STRICT_EQUAL; `a1 a7` keep only the definition-view gen_for face (bit_select
`sub.ben[i]` at the name token, golden `work@child.g.sub.ben[i].ben` at the index: TypeEmit `emitSyntaxExpr`, sister
ground S6) and `a6` also the folded-index face (residue R3c); `a5` (gen-scope process, already named) and `b2` (an
lvalue in a process: base span, residue R3d) keep their verdicts with fewer differing objects.

### § vsIpsBaseNamesByIps147
A var_select whose last step is an indexed part-select (`w[0][{b[2], 2'b00}+:4]`): a NON-BARE base (an operation, a
bit_select) names its references through the ips, whose own name doubles the base (UHDM ComputeFullName keeps the ips):
golden latch_packed_dyn_write `...read_write_comb.wr_be.wr_be.bit_i`, ours `...wr_be.bit_i`; a reference under an
operation alike (`w[0][k + 1 +: 2]`: `work@top.blk.w.w.k`), in a process lvalue and rvalue. A bare reference base
(`w[0][k +: 2]`) keeps the var_select's name in golden too (controls `ipb/f2_lhs_ref`, `f4_rhs_ref`). Cases `ipb/c3 e1
e2 e3 e4 f3 f5 f6 f7 f8` -> STRICT_EQUAL; controls `c4 e5 f2 f4` unchanged.

### § lvIdxBitSelAtIndex147
"Surelog anchors rvalue bit_selects at the index expression, but lvalue ones span the whole select" holds for the
TARGET only: a bit_select nested in the lvalue's own select indices is a read and sits at its index (golden
latch_packed_dyn_write 47:32-33, ours 47:26-34; `w[0][b[1]] = 1`, `w[b[2] +: 4] = '1`, `w[0][b[k[0]] + 1 +: 2] = '1`).
The gate is the parent: a var_select / bit_select / part_select / indexed_part_select, directly or through
operations. Cases `ipb/c2 d5 f1 f6` (+ `e1-e4 f7` with the law above) -> STRICT_EQUAL.

### § nestedDefaultPatLoc147
`'{default: '{default: 0}}` (SelectFromUnpackedInFunction's `logic [2:0] a [3:0]` initializer; a procedural
assignment and an indexed-plus-default pattern alike): golden locates the outer `default:` tagged_pattern at its
value (6:37-50) and the inner pattern's `default` string_typespec at the inner key (6:39-46); ours left both
unlocated (the bound default setter reaches the pattern case without its written syntax). The outer pattern's syntax
supplies both; only a MISSING location is filled. Cases `dfp/s1 s5 s6` -> STRICT_EQUAL; control `s2_var_flat`
unchanged.

### § gcaUseSiteParamConst147
In a top-level loop-generate continuous assignment the § genCaLoopParamFold window hands back the parameter's own
elaborated constant, parented at its param_assign and named by the instance — golden's form for a bare operand. Two
positions are compiled fresh at the use site in golden and named through it (multiplier Multiplier_2D): a read INSIDE
AN OPERATION of a replication count (`{(N-i){1'b0}}`, `{N-i{1'b0}}`: `work@Multiplier_2D.addPartialProduct[1]`, ours
`work@Multiplier_2D`) and a read inside the bound of a part-select trailing an UNQUALIFIED var_select
(`PP[i-1][M+i-1:0]`: `...addPartialProduct[1].PP.PP`). A bare or parenthesized-bare count (`{M{B[i]}}`, `{(N){..}}`)
keeps the instance's name (controls `mul/k6 k7 k9`; the first law build named those by the scope too and moved
multiplier's Multiplier_flat records AWAY — refined before landing), as does a plain part-select bound (`k4`) and a
package-qualified var_select base (`k10`, probe `r10earl41repro/v41v_comment`: golden `q41::A::q41::A::q41::A`, the
§ pkgQualPsRtFull118v spelling this law does not model — the second law build moved that case from one wrong name to
another; the landed gate leaves it byte-identical to pristine). Cases `mul/k1 k2 k3 k5 k8` -> STRICT_EQUAL.

### § firstOrderedConnBitSelWhole147
A high-conn bit_select is anchored at its index like every rvalue select, except the FIRST connection of an ordered
list of two or more: golden multiplier `FullAdder unit(A[i],B[i],CC[i],S[i],CC[i+1])` puts `A[i]` at 124:20-24 and the
rest at the index (grid `pos`: `add u(X[0], Y[0], Z[0])` X whole, Y/Z index; `add u(c, B[1], ..)` B index; named
connections index; the definition view of a non-top parent the same). A SINGLE ordered connection keeps the index
(`buf1 u(A[1])`, and ExplicitPorts `a a3(a[1])`: the first law build read `line(8) -> line(9)` there and the landed
gate restores pristine's bytes; controls `pos/p2 p4`). Cases `pos/m2 n1 n2 p1 p3` -> STRICT_EQUAL; `n5` (a variable
index: the index reference named through the port and bound to the net in golden, residue R3e) keeps its verdict with
fewer differing objects. Corpus: multiplier's 36 records and YosysOldOr (`line(593) -> line(75)`, both modes).

### § memberEnumCloneKeepsBase147
r11u143's S3, re-derived on unfenced cases: the per-use member copy of ANOTHER package's enum (`package pb; import
pa::*; typedef struct packed { pad_type_e m; } t;`) is a full clone in golden — Surelog's `importPackage` inserts the
home package's DataType itself and every later copy is `clone_tree`, which keeps the base-type reference and the file
(ParameterPassedToSubmoduleOfSubmodule: enum `prim_pad_wrapper_pkg::pad_type_e` at dut.sv 2:4-4:17 with its `logic`
base reference; ours had no file and no base, uhdm-cmp stage 1 on the fence cases). The law passes the home typedef's
enum syntax to `buildEnumTs`, copies the file, parents the base typespec at the home package and names the base
reference as the home's (`ea::ea::st_e`). Cases `mec/f01 f04 f05 g1 g3` -> STRICT_EQUAL, `f02 f03` stage 1 ->
judge-equal (the explicit-import clone's base-reference name remains, residue R3f); control `g2_same_pkg_ctl`
unchanged. The ParamEmit import-clone site (`buildEnumTs(ct2.as<EnumType>(), eSyn2, nm2)`) already carried the
syntax; only the per-use member site lacked it.

### § enumQualDefaultDefSpan147
§ pkgQualFoldSpanByView124's rule for a qualified ENUM constant: a module DEFINITION listing's parameter default
written `pk::B` folds at the qualifier with its colons (golden ibex_alu `RV32B = ibex_pkg::RV32BNone` 10:39-49, grid
`qen`: `parameter`, `localparam`, header parameter and a child definition with an override); the elaborated instance
keeps the whole reference. Cases `qen/q01 q02 q03 q05` -> STRICT_EQUAL.

## Census (the whole status column, law sweep vs pristine sweep, row by row)

Law vs committed baselines (evidence/sweep_law_vs_baselines.txt):

| | regressions | conversions | changes |
|---|---|---|---|
| probe | 0 | 55 | 33 |
| surelog | 0 | 4 | 18 |
| uhdm2rtlil | 0 | 26 | 14 |

The r11u147 laws' changes (11 row-modes' worth, below) keep their first differing record and first field and drop
objects (evidence/changes_first_record.txt: first record pristine = law on every row); r11u151's (the 30 probe
cases and 14 corpus row-modes named in the structural paragraph at the top) are unmaskings or later divergences,
re-measured record by record in the same file. The r11u147 changes: Earlgrey_0_1 `line(1755) -> line(1750)` d/t (#6), GenForIfaceLocalparamBound
and …NestedGen `endcol(5) -> endcol(1)` d/t (IFTRAILIDX), YosysOldOr `line(593) -> line(75)` d/t (FIRSTPOS),
ibex_alu `fullname(2) -> (1)` (ENUMQSPAN), ibex_compressed_decoder `-1`, ibex_decoder `-2`, ibex_multdiv_fast `-1`
(ENUMQSPAN), ibex_icache `-32` (VSIPSBASE), all both modes; probe `r10uvm134repro/g134_d_bodies file(2) -> (1)`
(LVIDXBS), `r10vrgg4repro/v5d_noovr_enumparam endcol(7) -> (6)` (ENUMQSPAN), `r11u112repro/grid/v/v08_comb
fullname(8) -> (4)` (VSIPSBASE).

Byte level (`SELFCHECK=1 tools/probe/r11v75repro/byteverify.sh`, law vs pristine workdir, evidence/byteverify_*.txt):
surelog `PATH_SETS_IDENTICAL (960 paths)`, `MOVERS: 34 / 960`, selfcheck 959/960; uhdm2rtlil `PATH_SETS_IDENTICAL
(1608 paths)`, `MOVERS: 40 / 1608`, selfcheck 1607/1608; probe databases 91 / 4087 (evidence/probe_movers.txt).
PREDICTED BY NAME before the comparison by the census sweep (the law binary under `R11U147_TRACE=1` and
`R11U151_TRACE=1` through drivers/tracewrap.sh on every command of a `tests/sweep.sh` run,
evidence/census_fires.txt, one line per row and firing law): **corpus 74 / 74 movers predicted, probe 91 / 91, 0
unpredicted**; predicted rows that did not move: 20 corpus row-modes (WireUnpacked d/t and AssignArraySelPlus d/t by
VSIPSBASE on a shape the rename leaves equal; the rest r11u151's ARR registrations with no whole reference, its own
README's list) and nine probe cases. The r11u147 laws' movers alone (the composition control binary) were 50 / 50
and 60 / 60 predicted; the composed binary's extra movers are exactly r11u151's firing rows. The UVM family (MiniAmiq,
SeqDriver, SimpleUVM, Scoreboard default) and BuildUVMPkg move by § lvIdxBitSelAtIndex147 (svaunit `siblings[m_sync]`
index spans 2138:14-23 -> 2138:21-22, golden's), not by the coin.

Order-blind dump distance to golden (drivers/dist.sh: the sorted uhdm-dump of golden against pristine and against
the law, file paths reduced to basenames; evidence/dump_distance_to_golden.txt), on all 62 non-fenced corpus movers:
**54 TOWARD, 0 SAME, 8 AWAY**. The 8 AWAY are the eight § memberEnumCloneKeepsBase147 CONVERSIONS
(ParameterPassed… / SubmoduleInGenScope…, d/t, strict-equal): golden's struct member IS the home enum object (Surelog's
import inserts it), printed once, while ours keeps its per-use copy, which now carries the base reference and the
`logic` base typespec the home object has; the extra dump lines are that copy's content (14 -> 24,
evidence/enumclone_copy_lines_ParameterPassedToSubmoduleOfSubmodule.txt: every one is ours-only, none golden-only).
That is typespec identity (copy against share), canonicalised by the strict comparator and outside the strict contract
(GOLDEN_EQUIVALENCE.md, "Typespec identity is canonicalised"); the rows read `CMP_EQUAL,,,equal`. Notable TOWARD:
YosysOldOr 2489 -> 417 (FIRSTPOS), Rggen 68972 -> 64092 (IFTRAILIDX), Earlgrey_0_1 504605 -> 503585, the UVM family
by 16-38 lines each (LVIDXBS: svaunit `siblings[m_sync]` at its index, golden's 2138:21-22).

## Gates

1. Build: md5s above; the pristine rebuild is byte-identical to the main tree's `build/slang-uhdm`.
2. Probe: `regressions=0` vs `results/golden_probe.csv`; EQUAL 2352 -> 2407, STRICT_NOTEQUAL 1735 -> 1680; every case
   stays judge-equal.
3. Corpora: `regressions=0` in both (surelog conversions 4 changes 18; uhdm2rtlil conversions 26 changes 14); uhdm-cmp
   statuses unchanged on every row (480/3 + 474/3, 803/1/67 both modes).
4. Downstream (`tests/sweep.sh --corpus downstream`, law binary, evidence/downstream_summary.txt):
   `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`; joined to
   `results/downstream_uhdm2rtlil.csv` on every column: 0 of 871 rows changed (pass 120's eight rows and every earlier
   target row stay IDENTICAL). Every converted and changed uhdm2rtlil row reads IDENTICAL:
   `latch_packed_dyn_write,IDENTICAL,OK,OK,37,37,,`, `mem_packed_2d_byte_write,IDENTICAL,OK,OK,1749,1749,,`,
   `multiplier,IDENTICAL,OK,OK,21,21,,`, `unpacked_elem_partsel_comb,IDENTICAL,OK,OK,152,152,,`,
   `SelectFromUnpackedInFunction,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, the four ParameterPassed… / SubmoduleInGenScope…
   rows `IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `ibex_alu,IDENTICAL,OK,OK,1028,1028,,`,
   `ibex_compressed_decoder,IDENTICAL,OK,OK,1166,1166,,`, `ibex_decoder,IDENTICAL,OK,OK,327,327,,`,
   `ibex_icache,IDENTICAL,OK,OK,3610,3610,,`, `ibex_multdiv_fast,IDENTICAL,OK,OK,3906,3906,,`,
   `array_assign,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `def_ctx_struct_param,IDENTICAL,OK,OK,2,2,,`,
   `latch_decoder_partial,IDENTICAL,OK,OK,1,1,,`, `latch_tlb_napot,IDENTICAL,OK,OK,2,2,,`,
   `NestedStructArrayParameterInitializedByPatternPassedAsPort,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
   `cva6_struct_param_field,IDENTICAL,OK,OK,1,1,,` (evidence/downstream_targets.csv).
5. uhdm-cmp: every row keeps judge-equality (the status join), every probe case judge-equal; every one of this pass's
   68 grid cases reads uhdm-cmp 0 lines on the law binary.
6. Byteverify and predictions: above.
7. Canaries (evidence/canaries.txt): `canaries.sh` law surelog csv vs committed: ok=44 changed=8 — BlackParrotComplex
   d/t (the claimed conversion), FuncStructVal d/t (r11u151's D, record-checked above), Earlgrey_0_1 and YosysOldOr d/t
   (predicted, record-checked); the pristine csv reads ok=52 changed=0; uhdm2rtlil ok=16 changed=0.
   `EXPECT_UNKNOWN=1 ctcan2.sh` surelog: ok=56 changed=2, the FAIL is BlackParrotComplex d/t alone, the claimed
   conversion (r11u151's README reads the same); `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil: PASS ok=2.
8. Earlier passes' cases as byte controls (pristine vs law, drivers/bytes.sh, fence-filtered,
   evidence/controls_earlier_passes.txt): 2088 cases in 25 directories (r11u118repro 0/56, r11v11u118repro 0/56,
   r11u119repro 0/78, r11u120repro 0/44, r11v120repro 0/47, r11u121repro 0/83, v11u121repro 0/41, r11u124repro 0/81,
   r11v124repro 1/109, r11u125repro 0/61, r11v125repro 0/48, r11u130repro 0/98, r11v130repro 0/115, r11u131repro
   0/121, r11v131repro 0/128, r11u133repro 0/50, r11v133repro 0/64, r11u140repro 3/108, r11v140repro 9/129,
   r11u143verify 5/160, r11u144repro 0/84, r11u145repro 0/52, r11v145repro 0/107, r11u148share 0/47, r11u149verify
   3/121); every mover is a census firing:
   * `r11v124repro/qx/q07_enumconst` (ENUMQSPAN): STRICT_NOTEQUAL endcol -> STRICT_EQUAL.
   * `r11v140repro/plv/v13_iface_arr` (IFTRAILIDX): stage 1 on both binaries, uhdm-cmp 40 lines on both.
   * `r11u143verify/cases/fence_s3/f01..f05` (ENUMCLONE): f03 stage 1 -> judge-equal (fullname), f05 stage 1 ->
     STRICT_EQUAL, f01 f02 f04 stage 1 on both with the head moved past this law's face (residue R6).
   * pass 140's `tdc` grids (`r11u140repro/tdc/c01 c05 c06`, `r11v140repro/tdc/t01 t03 t04 t06 t08 t09 t10 t12`,
     `r11u149verify/cases/tdc/n01 n02 n03`; r11u151's D2 rebinding the cast target per listing): `t01_union`
     STRICT_NOTEQUAL file -> STRICT_EQUAL; every other one keeps its verdict and its uhdm-cmp line count (the
     STRICT_EQUAL ones stay equal; `t12` keeps fullname=2).
   `r11v124repro/pv/v14_string`, `qx/q08_string` write no database on either binary (rc=3). The r11u147-only binary
   read 7 movers over the same 2088 (the D2 ones absent).

## Sister-ground faces (decoded; the fix sits in a file this pass does not own)

S1 — N0005's interface PORT-VIEW span (GenForIfaceLocalparamBound / …NestedGen's last record, 4 row-modes; pass
145's R6, r10rgg3repro's 35 probe cases): `localparam int unsigned BYT = DAT/8` read through an interface port —
golden's port-view param_assign constant spans the left operand (10:33-36), the connected instance's own view the
whole init (10:33-38); ours shares one object at 10:33-38. ModuleEmit.cpp `emitInterfaceInstance`, the `portView &&
!namedModportPortView9` param_assign loop beside § ifacePortViewAggParamParent120 (its face (C) already names the
narrowing and the definition view's operation Rhs as the oracle): the port view needs its own constant at the left
operand's span.

(Pass 146 landed in the main tree while this pass ran, 3e06cad2; its subject names "port initial assignments at the
header", which reads as S2, and "array-bound references named by the array path". Nothing below was re-measured on it:
this pass's base is 1fb349a9.)

S2 — the output-port initializer's synthesized initial (PortInitVal d, PortInitVal2 d/t, sat_asserts_seq d/t, 5
row-modes, N0455 + N0456): golden spans the assignment and its Lhs reference at the PORT-LIST name of a non-ANSI port
(1:13-14), ours at the body declaration (3:20-21). ModuleEmit.cpp, the block "An OUTPUT port INITIALIZER synthesizes a
loc-less initial" (both the literal and the parameter case): `nameSpan(ps9.location, ps9.name)`.

S3 — genscope_module_ctx_reset d/t (N1118): the elaborated high_conn part_select of an instance inside a generate
scope is named `work@X.u_c.ci.in_i`, golden `work@X.gen_inst.u_c.ci.in_i`. ModuleEmit.cpp `emitInstance`, the block "A
part-select HighConn's bounds reduce like the module_array's own range" (§ foldBareParamBound's caller) reads
`pselA9->VpiFullName()` before the port's instance carries its generate path, which freezes the lazy name.

S4 — PatternStruct d/t (N0394 + N1140): `my_struct s = '{word: 125};` — the packed-struct net-declaration pattern
folds to `op75(constant)` and the constant carries no location; golden 5:26-29 (the member value). ModuleEmit.cpp,
the net-decl-assign "PACKED-struct assignment-pattern net-decl RHS folds to an op75" case (`tryFoldConst`).

S5 — StructArray… / NestedStructArray…PassedAsPort (C3, 4 row-modes): ModuleEmit.cpp `emitInstance`, the "named
UNPACKED-ARRAY-of-packed-struct PARAM connection" block: `cfn9 = prefix + "." + inst.name + "." + ps.name` doubles the
instance (`work@top.u_hw_sel.u_hw_sel.region_attrs_i`) and the returned operation keeps the parameter initializer's
span where golden relocates it to the actual (23:23-33).

S6 — the definition-view gen_for of an interface-member select (`tsi/a1 a5 a6 a7`, probe only): the def listing's
bit_select `sub.ben[i]` at the name token, golden `work@child.g.sub.ben[i].ben` at the index — TypeEmit.cpp
`emitSyntaxExpr` (the syntax-driven def-view gen-block emission).

S7 — PackedEnumPort d/t, VarPassedTo2Submodules d/t (N0655, N0163): the enum-ALIAS typedef's per-use name
(`lc_ctrl_pkg::lc_tx_t` vs `lc_tx_e`): TypeEmit.cpp `buildEnumTs` (map 6 ground B).

## Decoded, not landed (ranked residues on this ground)

R1 — r11u151's own residues (its README section 4): C3's span and name (pair B, measured in its
pairB_c3_scratch.patch), D's module-holder copy and definition-module hier_path spans (R-D2/R-D3), R-D1 the `localparam
type` struct span, R-D4 (FuncStructVal testflags), R-ARR2, G2 h01/h03/h05.

R2 — StringMethod (N0765 + N0006): a method-call argument in a variable initializer or continuous assignment is named
by the call path in golden (`int b = s.compare(t)`: `work@top.b.s.compare.t`; `assign b = s.compare(t)`:
`work@top.s.compare.t`), ours by the scope (`work@top.b.t`); and with two initializers reading `t` golden binds the
first argument to the definition listing's `logic_net t` (the structural record). The built-in method cases of
`emitExpr` (the hier_path `s.compare` form) — not landed: the row keeps the structural face.

R3 — interface/member path names: (a) iface_struct_field_partsel / iface_arr_struct_field_partsel — the hier_path's
bit_select `sub.req_dly[0]` (ours `req_dly[0]`) and the part-select bound references named through the path
(`work@mem.sub.req_dly[0].adr[$clog2(BYT) - 1:0].adr.BYT`), with sister faces N0139 / N0001 on the same rows; (b)
anon_struct_packed_dim (N0820, 43 objects, with N0014); (c) `tsi/a6`: a folded parameter index in an interface-member
path names the bit_select and the constant's ref_typespec by the folded path (`sub.ben[2]`); (d) `tsi/b2`: the lvalue
interface-member select in a process (base reference span, bit_select span); (e) `pos/n5`: a positional connection's
variable index is named through the port (`work@top.u.k`) and golden lists its net; (f) `mec/f02 f03`: the
explicit-import clone's base-reference name (ParamEmit `buildEnumTs(ct2.as<EnumType>(), eSyn2, nm2)`).

R4 — ComplexParamOverload (N0739): the elaborated cont_assign of an overloaded struct-member parameter lists one
reference fewer in golden (its Rhs object already walked); first caller ModuleEmit `emitContAssigns` (map 6's caution
list) — not decoded to the site.

R5 — pass-145 R5 / V5 (an imported package parameter read in a continuous assignment or under a unary operator):
not reached in this pass.

R6 — the original r11u143 fence_s3 cases now read uhdm-cmp 64 lines (pristine 16): the base-reference head this pass
clears is gone and the walk reaches the next, pre-existing face (`assign o = Cfg.mode`: golden keeps the hier_path,
ours folds to a constant — the same 64 lines the same-package control reads on pristine). An unmasking, not a
regression (evidence/controls_earlier_passes.txt).

## Cases (first line of every case names its law; pristine and law verdicts, evidence/grid_pristine_vs_law.txt)

| case | law (first line) | pristine | law |
|---|---|---|---|
| `dfp/s1_var_nested` | § nestedDefaultPatLoc147 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 60 objects |
| `dfp/s2_var_flat` | § nestedDefaultPatLoc147 | cmp=0 STRICT_EQUAL 56 objects | cmp=0 STRICT_EQUAL 56 objects |
| `dfp/s5_idx_and_default` | § nestedDefaultPatLoc147 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 68 objects |
| `dfp/s6_assign_nested` | § nestedDefaultPatLoc147 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 81 objects |
| `ipb/c2_lhs_plain` | § lvIdxBitSelAtIndex147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 71 objects |
| `ipb/c3_rhs_vs` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 100 objects |
| `ipb/c4_rhs_ca` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_EQUAL 83 objects | cmp=0 STRICT_EQUAL 83 objects |
| `ipb/d1_lhs_vs_var` | § blockLhsVarSelBindsWholeRef151 (the r11u151 ARR law this pass lands, composed with § lvIdxBitSelAtIndex147 and § vsIpsBaseNamesByIps147) | cmp=138 NOT_EQUAL stage1 | cmp=0 STRICT_EQUAL 118 objects |
| `ipb/d4_lhs_vs_var_bs` | § blockLhsVarSelBindsWholeRef151 (the r11u151 ARR law this pass lands, composed with § lvIdxBitSelAtIndex147 and § vsIpsBaseNamesByIps147) | cmp=74 NOT_EQUAL stage1 | cmp=0 STRICT_EQUAL 109 objects |
| `ipb/d5_lhs_var_plain` | § lvIdxBitSelAtIndex147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 96 objects |
| `ipb/e1_case_ips` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 158 objects |
| `ipb/e2_if_ips` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 135 objects |
| `ipb/e3_case_add` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 158 objects |
| `ipb/e4_case_noname` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 158 objects |
| `ipb/e5_case_ps` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_EQUAL 160 objects | cmp=0 STRICT_EQUAL 160 objects |
| `ipb/f1_lhs_bs` | § lvIdxBitSelAtIndex147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 199 objects |
| `ipb/f2_lhs_ref` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_EQUAL 202 objects | cmp=0 STRICT_EQUAL 202 objects |
| `ipb/f3_lhs_refop` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 206 objects |
| `ipb/f4_rhs_ref` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_EQUAL 202 objects | cmp=0 STRICT_EQUAL 202 objects |
| `ipb/f5_rhs_bsop` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 207 objects |
| `ipb/f6_lhs_bsbare` | § lvIdxBitSelAtIndex147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 203 objects |
| `ipb/f7_lhs_bs_in_bs` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 209 objects |
| `ipb/f8_rhs_refop` | § vsIpsBaseNamesByIps147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 206 objects |
| `mec/f01_param_import_wild` | § memberEnumCloneKeepsBase147 | cmp=16 NOT_EQUAL stage1 | cmp=0 STRICT_EQUAL 213 objects |
| `mec/f02_param_import_explicit` | § memberEnumCloneKeepsBase147 | cmp=16 NOT_EQUAL stage1 | cmp=0 STRICT_NOTEQUAL fullname |
| `mec/f03_var_not_param` | § memberEnumCloneKeepsBase147 | cmp=16 NOT_EQUAL stage1 | cmp=0 STRICT_NOTEQUAL fullname |
| `mec/f04_scoped_ctl` | § memberEnumCloneKeepsBase147 | cmp=16 NOT_EQUAL stage1 | cmp=0 STRICT_EQUAL 145 objects |
| `mec/f05_nested_sub` | § memberEnumCloneKeepsBase147 | cmp=16 NOT_EQUAL stage1 | cmp=0 STRICT_EQUAL 293 objects |
| `mec/g1_scalar_base` | § memberEnumCloneKeepsBase147 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 124 objects |
| `mec/g2_same_pkg_ctl` | § memberEnumCloneKeepsBase147 | cmp=0 STRICT_EQUAL 110 objects | cmp=0 STRICT_EQUAL 110 objects |
| `mec/g3_int_base` | § memberEnumCloneKeepsBase147 | cmp=0 STRICT_NOTEQUAL file | cmp=0 STRICT_EQUAL 195 objects |
| `mul/k10_qual_vs_ctl` | § gcaUseSiteParamConst147 (control: a package-qualified var_select base keeps pristine's name; residue) | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `mul/k1_vs_ps_bound` | § gcaUseSiteParamConst147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 287 objects |
| `mul/k2_repl_only` | § gcaUseSiteParamConst147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 164 objects |
| `mul/k3_repl_plainlhs` | § gcaUseSiteParamConst147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 114 objects |
| `mul/k4_ps_plain` | § gcaUseSiteParamConst147 | cmp=0 STRICT_EQUAL 134 objects | cmp=0 STRICT_EQUAL 134 objects |
| `mul/k5_typed_int` | § gcaUseSiteParamConst147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 164 objects |
| `mul/k6_repl_bare` | § gcaUseSiteParamConst147 | cmp=0 STRICT_EQUAL 156 objects | cmp=0 STRICT_EQUAL 156 objects |
| `mul/k7_repl_paren` | § gcaUseSiteParamConst147 | cmp=0 STRICT_EQUAL 156 objects | cmp=0 STRICT_EQUAL 156 objects |
| `mul/k8_repl_op_noparen` | § gcaUseSiteParamConst147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 164 objects |
| `mul/k9_repl_bare_plainlhs` | § gcaUseSiteParamConst147 | cmp=0 STRICT_EQUAL 110 objects | cmp=0 STRICT_EQUAL 110 objects |
| `pos/m2_pos_const` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 122 objects |
| `pos/m4_named_gen` | § firstOrderedConnBitSelWhole147 (control: named connections keep the index span) | cmp=0 STRICT_EQUAL 266 objects | cmp=0 STRICT_EQUAL 266 objects |
| `pos/n1_pos_other` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 122 objects |
| `pos/n2_pos_swap` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 122 objects |
| `pos/n3_pos_second_only` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_EQUAL 133 objects | cmp=0 STRICT_EQUAL 133 objects |
| `pos/n4_named_const` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_EQUAL 132 objects | cmp=0 STRICT_EQUAL 132 objects |
| `pos/n5_pos_var_idx` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_NOTEQUAL fullname |
| `pos/p1_def_view_mid` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 190 objects |
| `pos/p2_single_port` | § firstOrderedConnBitSelWhole147 (control: a single ordered connection keeps the index span) | cmp=0 STRICT_EQUAL 72 objects | cmp=0 STRICT_EQUAL 72 objects |
| `pos/p3_nonansi_child` | § firstOrderedConnBitSelWhole147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_EQUAL 122 objects |
| `pos/p4_explicitports_shape` | § firstOrderedConnBitSelWhole147 (control: a single ordered connection keeps the index span) | cmp=0 STRICT_EQUAL 35 objects | cmp=0 STRICT_EQUAL 35 objects |
| `qen/q01_param_enum` | § enumQualDefaultDefSpan147 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 96 objects |
| `qen/q02_localparam_enum` | § enumQualDefaultDefSpan147 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 96 objects |
| `qen/q03_header_param_enum` | § enumQualDefaultDefSpan147 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 65 objects |
| `qen/q05_child_inst` | § enumQualDefaultDefSpan147 | cmp=0 STRICT_NOTEQUAL endcol | cmp=0 STRICT_EQUAL 123 objects |
| `tsi/a1_gen_ca` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `tsi/a2_mod_ca_net` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 167 objects |
| `tsi/a3_mod_proc` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 169 objects |
| `tsi/a4_gen_ca_op` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 203 objects |
| `tsi/a5_gen_proc` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `tsi/a6_gen_ca_param` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `tsi/a7_gen_ca_nested` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_NOTEQUAL fullname |
| `tsi/b2_lhs_proc` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL col | cmp=0 STRICT_NOTEQUAL col |
| `tsi/b3_func` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 203 objects |
| `tsi/b4_top_inst` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 104 objects |
| `tsi/b5_operand` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 176 objects |
| `tsi/b6_modport` | § ifaceMemberTrailIdxNamesByPath147 | cmp=0 STRICT_NOTEQUAL fullname | cmp=0 STRICT_EQUAL 177 objects |

68 cases, every one rc=0 on both binaries and uhdm-cmp 0 lines on the law binary; 44 move to STRICT_EQUAL (5 of them
from stage 1: `mec/f01 f04 f05`, and `ipb/d1 d4` by r11u151's ARR), 2 from stage 1 to judge-equal (`mec/f02 f03`), 15
controls stay STRICT_EQUAL, and the 7 still-failing law cases (`tsi/a1 a5 a6 a7 b2`, `pos/n5`, `mul/k10`) keep or
shrink their differing-object count (`tsi/a1` 6 -> 2, `a7` 6 -> 2, `b2` 6 -> 4, `n5` 3 -> 2, `a5` 1, `a6` 10, `k10`
byte-identical to pristine).

## Ops notes (disclosed)

* drivers/rc.sh first wrote its golden-path pointer (`.gpath`) into the case directory it measured. It did so for
  seven earlier-pass case directories of the MAIN checkout (`tools/probe/r11v124repro/qx/q07_enumconst`,
  `r11v140repro/plv/v13_iface_arr`, `r11u143verify/cases/fence_s3/f01..f05`) while re-measuring them; each file was
  removed right after, `git status` of the main tree reads clean, and the driver now keeps the pointer under
  `/tmp/r11u147_s/gpath`.
* While stopping this pass's own distance census, a `uhdm-dump` process of another agent (a dump of
  `/tmp/r11u153_swB/surelog/default/Earlgrey_0_1-a898def8/slang.uhdm`) was killed by pid. That run's Earlgrey default
  dump may be truncated; r11u153 should repeat that one step.
* The census sweep is a `tests/sweep.sh` run and dispatches every row the gate does (the fenced row included, see the
  top); no fenced source was read by this pass.

## Files

* `tsi/ ipb/ dfp/ mul/ pos/ mec/ qen/` — the law grids (68 cases).
* `drivers/`: `rc.sh` (one case: golden with the probe flags, cached per case text; ours per binary; uhdm-cmp; strict),
  `ctx.sh` + `anc.py` + `cx.sh` (a pair's differing strict records with their ancestors), `row.sh` +
  `rowpaths.sh` (corpus rows through verify_golden.py; a sweep row's two databases), `grid.sh` (every case on two
  binaries), `switches.sh` (master and single switches), `tracewrap.sh` (the census stand-in binary), `bytes.sh`
  (earlier passes' byte controls, fence-filtered), `fieldcmp.sh` (whole-walk field tallies), `changecheck.sh` (first
  record and walk summary before and after), `dist.sh` (order-blind dump distance to golden).
* `evidence/`: `sweep_pristine_vs_baselines.txt`, `sweep_law_vs_baselines.txt`, `census_fires.txt`,
  `byteverify_surelog.txt`, `byteverify_uhdm2rtlil.txt`, `probe_movers.txt`, `probe_conversions_attributed.txt`,
  `changes_first_record.txt`, `dump_distance_to_golden.txt`, `enumclone_copy_lines_*.txt`, `switches.txt`,
  `switches_r11u151_grid.txt`, `grid_pristine_vs_law.txt`, `grid_r11u151_pristine_vs_law.txt`,
  `controls_earlier_passes.txt`, `canaries.txt`, `downstream_summary.txt`, `downstream_targets.csv`. The fenced row is
  written `FENCED_1` in every file.
