# r11u186: the module/type ground, pair B (refill after pass 180): the r11u183 decode's ground-B laws landed and re-verified, eleven laws and refinements of this pass

Base `a3a62624` (branch matrix-1.87, pass 180). Files of the ground touched: `src/TypeEmit.cpp`, `src/ModuleEmit.cpp`,
`src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`; `uhdm_main.cpp` needed nothing. No line of the sister's files
(`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`), of `include/`, and nothing under
`results/`, `tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated (`python3 scripts/law_index.py`).
The r11u183 decode's ground-A patch (`tools/probe/r11u183dec/law_exprstmt.patch`) is the sister's and is NOT applied
here: every number below is this ground's half alone.

**The fence.** The four slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus
sources or databases (`drivers/env.sh`, `case.sh`, `row.sh`, `rowrun.sh`, `det.sh`, `census.sh`, `bvmirror.sh`,
`uvmdist.sh`, `offcheck.sh`, `switches.sh`, `dscase.sh`) takes the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed; the firing census ran `verify_golden.py --filter` built from
`$FENCED` (the four rows excluded); the byte comparisons ran on hard-link mirrors that leave the 8 fenced row-mode
databases out (`fenced_skipped=8`). No fenced test was run, read or decoded outside the gate sweeps, which dispatch every
row themselves. gdb was not used. A grep of this directory for the four names reads 0.

**Switches.** The r11u183 laws keep their `R11U183_*` switches (`R11U183_OFF` drops all of them); the three laws that
shared the family switch `R11U183_RANGEFILE_OFF` got their own beside it (`R11U183_ASSOCBRACKET_OFF`,
`R11U183_PKGPARAMTS_OFF`, `R11U183_ELABCAFOLD_OFF`). Every law and refinement of this pass reads its own
`R11U186_<LAW>_OFF` through `r11u186Law` (`UhdmExporter.cpp`, beside `r11u180Law`), and `R11U186_OFF=1` drops all of
them. `R11U186_OFF=1 R11U183_OFF=1` together give the pristine bytes on every one of the 4087 `tests/probe` cases and
on 477 of the 481 case directories of this pass, r11u183dec, r11u180repro, v11u180repro, r11u181repro and
r11v181repro; the other 4 write no database on either binary (section 6). Instrumentation: `R11U183_TRACE=<dir>` (the r11u183 laws,
one file per process per unit) and `R11U186_TRACE=<dir>` (this pass's, `<dir>/<pid>.186`), each file's first line the
`-o` database path, then one line per firing; unset, nothing is written.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u186_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `11406ca141eca2351fb70b640f522369` | the worktree's system-deps `-j 2` build of `a3a62624` = the main tree's `build/slang-uhdm` |
| `l183.bin` | `ac995db3b1b5ac586d38142e733b57eb` | `a3a62624` + the r11u183 ground-B laws alone, rebased (section 2): sweep `swA` |
| `law.bin` | `3127d6397c85a60c1ee86d4264682010` | + this pass's first law set: sweep `swL` |
| `final.bin` | `57aea56cb01ce6c59c701125d7bf1ab3` | + § assocBracketPkgOnly186 + § typeParamGateNoLookup186: sweep `swF` |
| `final2.bin` | `2d409958d1e842d60cafad673cf106a2` | + § typeParamDefersToTpUse186: **the patch** (the worktree's `build/slang-uhdm` rebuilt from the delivered sources); sweep `swG` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

(`d1`..`d7` are development builds; `d7` = `final2.bin`.) Sweeps: `drivers/sweep.sh <bin> <workdir>` =
`tests/sweep.sh --jobs 3` with the pins exported, all four stages, same-length workdirs `/tmp/r11u186_sw{P,A,L,F,G}`;
every corpus `cmds.txt` of each names its own binary (3273 of 3273 `slang:` lines).

## 2. The r11u183 ground-B laws, rebased on a3a62624

`tools/probe/r11u183dec/evidence/law_typeemit_rebased_on_804e3b75.patch` was applied to the four files of `804e3b75`
and merged three-way (`git merge-file`) onto `a3a62624` (pass 181 and pass 180 in between): TypeEmit, ModuleEmit and
TaskFuncEmit merged clean; UhdmExporter had ONE conflict, in `classElemVar`'s array-element site, where pass 180 added
`else noteTpUse180(...)` (§ classTpDefaultTsAtUse180) and r11u183 added § classPropElemClassTsAtType183 after the same
block: both kept, pass 180's first (the drain overwrites the span of a type-parameter element, so the r11u183 span only
lands on non-parameter elements; grid U/u04 control). The 13 laws of the brief are all present with their switches;
their r11u183 grid (147 cases, `tools/probe/r11u183dec/cases`) reproduces on `l183.bin` every B-alone verdict of
r11u183's `evidence/grid.tsv` except where passes 176/180/181 had already moved the case at this base (b/t01-t07 EQUAL at
the base: § classTpDefaultTsAtUse180; a/c16 EQUAL; b/s01 `type(1)` at the base).

### 2a. The composition with pass 180 (brief item 1)

| pair | measured | result |
|---|---|---|
| § classTpDefaultTsAtUse180 / § classTpFormalMovesTs180 vs § typeParamUseSharesOwnTs183 | ArrayMethodIterator d/t through the harness with each switch (`drivers/rowrun.sh`): both on `endcol(1)`; `R11U183_TYPEPARAM_OFF` `endcol(1)`; `R11U180_TPUSE_OFF` `endcol(1)`; both off `name(6)` / `name(16)`. Grids r11u183dec b (t01-t08), T (t01-t03), r11u180repro A: every verdict identical with either law alone | **redundant**: either law alone gives the row and every case; the r11u183 law shares the parameter's object where § 180 copies name and span (identity is canonicalised). Two side effects of the r11u183 law found here decided the composition: its gate's `lookupName` moved the bytes of two probe cases it never fires on, and with that fixed (§ typeParamGateNoLookup186) sharing the object made BuildUVMPkg a run-to-run byte coin (section 5). **§ typeParamDefersToTpUse186**: the r11u183 law now fires only when `R11U180_TPUSE_OFF` is set |
| § enumImportParentLastWriter180 vs § classImportParamOwnRefs183 (imported copies) | MiniAmiq default: all on `file(7)` 22,794; `R11U183_IMPCOPY_OFF` `file(7)` 26,342; `R11U180_ENUMIMP_OFF` `file(7)` 22,792; both off 26,342 (order-blind distance, `drivers/uvmdist.sh`) | independent: IMPCOPY carries 3,548 of the distance, ENUMIMP moves no strict field there (the 2-record difference is the known UINT coin) |
| § ifaceWildcardTdNameOrder180 (+ § ifaceTwoPkgTdNameOrder186) vs § memberBareTdAliasNamedByUse183 (interface listings) | MiniAmiq default: `R11U183_BITTSNAME_OFF` `fullname(8)`, `R11U180_IFACETDORDER_OFF` `file(7)`, `R11U186_IFACE2PKG_OFF` `file(7)`, BITTSNAME + IFACETDORDER off `fullname(8)`; distance 22,794 in all four | independent: BITTSNAME clears MiniAmiq's first record (`<in>uvm_reg_byte_en_t`, an in-copy name the order-blind distance does not see); the interface orders move no strict field on this row |

### 2b. Fresh cases per law (brief item 1: 2-4 per law; `cases/<letter>/`, first line `// § <law>`)

Judged exactly as `scripts/check_probe.py` does (`drivers/case.sh`: goldens from the pinned Surelog
`-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, ours `--single-unit --nobuiltin`), pristine -> final2; "obd" is
the order-blind uhdm-dump distance to golden (`drivers/obd.sh`) for the judge-unequal ones.

| law (switch) | cases | result |
|---|---|---|
| § assocPromotedBoundAtBracket183 (`R11U183_ASSOCBRACKET_OFF`) | A/n01-n04 | n03 (a package task, enum key) `file(2)` -> EQUAL; n01 (in-body class method), n04 (keyword index) EQUAL controls, bytes unchanged; n02 (module function) judge-unequal on both, bytes unchanged |
| § pkgParamElabCaSharesDefFold183 (`R11U183_ELABCAFOLD_OFF`) | P/p01-p05 | p04 (module parameter) EQUAL control, unchanged; p01-p03, p05 judge-unequal on both (golden sizes the elaborated fold of a package parameter 32 where ours keeps the parameter width: section 9 R6), obd 40->6, 40->12, 74->10, 53->37 |
| § pkgParamFoldOwnTs183 (`R11U183_PKGPARAMTS_OFF`) | P/p06-p08 | fires on p06, p08 (a bare decimal and a computed default; p07's multi-dimensional type does not reach the site): judge-unequal on both (the same size face), obd 28->4, 30->6 |
| § aliasOfTdSharedKeepsModName183 (`R11U183_ALIASNAME_OFF`) | E/e01-e03 | `fullname(50/85/85)` -> `file(40/68/68)`: the name half is this law; the remaining `file` records are law aliasFoldBoundFile183 (unlanded, the sister's), the sister's (ParamEmit `emitPackage`), exactly jeras_union's split |
| § classPropElemClassTsAtType183 (`R11U183_PROPELEM_OFF`) | U/u01, u02, u04 | u01 (fixed and dynamic arrays) `file(2)` -> EQUAL; u02 judge-unequal on both (a bounded queue's range), obd 36->28; u04 (a type-parameter element) EQUAL control, bytes unchanged |
| § typeParamUseSharesOwnTs183 (`R11U183_TYPEPARAM_OFF`) | T/t01-t03 | deferred to § classTpDefaultTsAtUse180 (2a): t02 (a formal) and t03 EQUAL on both, t01 judge-unequal on both (an unrelated task listing) |
| § importNetTsToInitEnd183 (`R11U183_IMPNETTS_OFF`) | H/h01-h04 | h02 (explicit import, two-line initializer) `endline(2)` -> EQUAL; h03 (no initializer, class handle) EQUAL control, bytes unchanged; h01, h04 (interface importer) judge-unequal on both, obd 36->26, 16->10 |
| § ifaceArrPortSizeDimAtExpr183 (`R11U183_IFARR_OFF`) | I/i01-i04 | i01 (`p[N]`), i04 (positional, spaced `[ 3 ]`) `endcol(4)` -> EQUAL; i03 (range form) unchanged; i02 (`p[2*2]`) judge-unequal on both, obd 206->200 |
| § foreachAssocLocalSharesDeclTs183 (`R11U183_UARANGE_OFF`) | F/f01-f03 | f03 (a typedef index) `file(4)` -> EQUAL; f01 EQUAL, unchanged; f02 judge-unequal on both (a byte-index loop variable, `int_var` vs `byte_var`), obd 13->10 |
| § foreachAssocLoopVarIdxTs183 (`R11U183_FEIDX_OFF`), the B half | F/f03 | the registration alone moves no byte in any grid (`R11U183_FEIDX_OFF` moves 0 cases): it waits for its StmtEmit half (the sister's) |
| § macroPathTokSpans183 (`R11U183_PATHSPAN_OFF`) | Q/q01-q03 | q02 (a macro generate loop, a member bit select) `endline(19)` -> `col(16)`; q01, q03 EQUAL controls, unchanged |
| § memberBareTdAliasNamedByUse183 (`R11U183_BITTSNAME_OFF`) | G/g01-g03 | g02 (explicit module import), g03 (two structs share the typedef) `fullname(6/12)` -> EQUAL; g01 EQUAL control |
| § classImportParamOwnRefs183 (`R11U183_IMPCOPY_OFF`) | K/k01-k03 | k01, k02 (string and bit-vector parameters) `depth(1)` -> EQUAL; k03 (a module importer beside) judge-unequal on both, obd 79->52 |

## 3. This pass's laws (brief items 1-3)

### 3.1 § enumConstUnderscoreDropped186 (`R11U186_ENUMUS_OFF`), § synLitUnderscoreDropped186 (`R11U186_SYNUS_OFF`), § boundLitUnderscoreDropped186 (`R11U186_BOUNDUS_OFF`) — TypeEmit.cpp

Pass 181's sister faces S3 and V1, transcribed: Surelog's `compileConst` (third_party/Surelog/src/DesignCompile/
CompileExpression.cpp, the `slIntConst` case, `value.erase(std::remove(value.begin(), value.end(), '_'), ...)`) erases
every `_` before the decompile and the value. Three builders outside the literal emitter kept the written text:
- the enum builder (`buildEnumTs`, the bare-decimal branch): `A = 1_0` read `1_0` / `UINT:1_0`, which the reader parses as 1
  (downstream-visible: D/d01, d02, d07 EQUIVALENT -> IDENTICAL on the gate's own `one()`);
- the syntax re-emitter (`emitSyntaxExpr`, `IntegerLiteralExpression`): a generate loop's condition, initial value and
  step, an if-generate condition; wider than 64 bits it takes compileConst's DEC branch (size -1, `DEC:<digits>`,
  § bigDecUnderscoreDropped181v's rule);
- the range bound (`makeBoundConst`): `logic [1_5:0]` decompiled `1_5` (value already `UINT:15`).

Grid D (d01-d08, all judge-unequal at pristine): d01-d05, d07, d08 -> EQUAL; r11u181repro us/u03 -> EQUAL (its S3).
d06 (a generate step written `g - 1_0`) stays judge-unequal: golden's ELABORATED loop reads the step as 1 (eleven
iterations where slang elaborates two) — a Surelog evaluation of the separator we do not follow (report only). A
sized or based enum value (`16'd1_2`, `'h1_F`) was already right.

### 3.2 § classPropElemQualTs186 (`R11U186_PROPELEMQUAL_OFF`) — UhdmExporter.cpp `classElemVar`

A package-qualified element class (`q::e lst[$];`) is compileTypespec's paPackage_scope form: named from the tokens
without blanks (`q::e`) and located at the qualifier, package name through the end of `::` (golden 7:3-7:6; ours `e` at
7:3-7:7 with § classPropElemClassTsAtType183, unlocated before), the rule § classTpQualDefaultSpan180 reads for a
qualified type-parameter default. U/u03, u05 (associative and fixed arrays, blanks around `::`): judge-unequal (the
name is judged) -> EQUAL.

### 3.3 § ifaceTwoPkgTdNameOrder186 (`R11U186_IFACE2PKG_OFF`) — ModuleEmit.cpp `emitImportArtifacts`

Pass 180's residue: an interface wildcard-importing SEVERAL packages lists their typedefs in ONE name order. Decode:
`CompileHelper::importPackage` (CompileHelper.cpp:127) copies each package's typedefs into the interface's single
`DataTypeMap` (`std::map<std::string, DataType*>`, include/Surelog/Design/DesignComponent.h:91) and `writeInterface`
walks it once (`writeDataTypes(mod->getDataTypeMap(), ...)`, UhdmWriter.cpp:1670), where § ifaceWildcardTdNameOrder180
sorted per package. Golden W/w01: `p1::a_t`, `p2::b_t`, `p1::c_t`, `p2::d_t`. Applied when every import of the interface
is a wildcard, at least two packages are imported and no typedef name repeats (a repeated name is one map entry: not
modelled); requires § ifaceWildcardTdNameOrder180 on. W/w01 `name(24)` -> EQUAL, w02 (packages imported in reverse
name order, struct and enum typedefs) `type(1)` -> EQUAL, w03 (one package) EQUAL control, unchanged. It also reorders
r11u180repro I/i03 (two packages, vector typedefs: stage 1 on both with the same head, pass 180's residue).

### 3.4 § lawSCopyIdOrder186 (`R11U186_LAWSSORT_OFF`) — TypeEmit.cpp `bareScalarTypedefVarTs` (determinism)

Pass 180's residue 15: LAW S's design-final pass iterated `Serializer::AllObjects()`, a
`std::map<const BaseClass*, uint32_t>` (address order, which follows slang's parallel parse), and minted its
per-declaration copies (`bareScalarTdCopyOf`, first use mints) in that order in two loops (the main loop and the
element-typespec half). Both loops now visit the objects in CREATION order (`UhdmId`, the serializer's counter);
every decision is per object, so only the order of the minted copies can move. Measured (`drivers/det.sh`, three
concurrent harness runs per binary): Earlgrey_0_1 default pristine `657dd42f` x2 + `529b2a71` x1 (and x2/x1 in an
earlier trio), with the law ONE hash in every trio (default `d8c6c5f6` 6/6, testflags `982f47f6` 3/3); section 5 for
the UVM rows. Its predictor (`R11U186_TRACE`): the objects whose visit minted a copy are the TRIGGERS; `reorder` when
their address order differs from their creation order, `multi` when there are two or more (a superset: another object
of the same memo key may be first in address order), else `single`.

### 3.5 § rootElemAtNextTok186 (`R11U186_ROOTELEM_OFF`) — TypeEmit.cpp `emitSyntaxExpr`

Pass 181's residue S2: a `$root` path the syntax re-emitter builds (a definition view's generate scope) anchors its
`$root` element on the NEXT component's token, § rootNetPathOwnNames181's rule for the expression emitter's twin (golden
`$root` 3:62-65 on `top`, ours 3:56-61). r11u181repro rt/g11 `col(1)` -> EQUAL, R/r02 (case-generate, three levels)
`col(1)` -> EQUAL, r01 (for-generate) judge-unequal on both (an unrelated net/variable face), obd 6->4; r03 (outside a
generate scope) control, unchanged.

### 3.6 Refinements found by fresh cases and by the corpus (brief caution h)

- **§ macroPathTokOneBuffer186** (`R11U186_PATHBUF_OFF`), of § macroPathTokSpans183. Found on Rggen d: a path
  component whose tokens do not all sit in its first token's buffer (a select written with macro ARGUMENTS,
  `RIF.read_mask[LSB+:WIDTH]`: the member in the body buffer, `0` / `4` in the arguments') has no contiguous text, so
  `t0 + offset` ran two columns short of golden's expanded-line layout (4:65-4:79, law 4:65-77; the bound constant
  4:78, law 4:76) where pristine was right; such a component keeps the pristine mapping. Rggen d on `l183.bin`:
  `endcol(634) -> endcol(696)` (552 records entered, 490 left; the walk diverges at `#23166` in both), on the final
  binary `endcol(634) -> endcol(144)`. Q/q04 (the Rggen shape in a generate scope): `l183.bin` `endcol(5)` (obd 9->15,
  WORSE), final = pristine bytes. q05 (a genvar select beside an argument select): pristine `fullname(9)`, `l183.bin`
  `fullname(5)`, final `fullname(6)` (neither mapping is golden's there; the refinement returns that component to the
  pristine mapping).
- **§ assocBracketPkgOnly186** (`R11U186_ASSOCPKG_OFF`), of § assocPromotedBoundAtBracket183. Found on r11u183's own
  grid a/c18 (obd 174->176 on the law binary): a `$unit` class or subroutine (no package above the declaration) is
  compiled without the elaborated listing that promotes the NAME index; golden leaves both markers unlocated there.
  A/n06 (a `$unit` out-of-body method, typedef key, obd 160->162 on the law binary) and c18 return to the pristine bytes;
  n07 (the package twin) keeps the law (`file(2)` -> EQUAL); n05 (a `$unit` in-body method) never reaches the law.
- **§ typeParamGateNoLookup186** (`R11U186_TPGATE_OFF`), of § typeParamUseSharesOwnTs183. The law's gate called slang's
  `lookupName` on every class-handle name written in a class method; that early resolution moved the bytes of
  tests/probe r10v195repro v195_b_reads and v195_d_tfitem (dumps identical, order only) although the law never fires
  there: the only two unpredicted movers of the law sweep `swL`. The lookup now runs only when an enclosing class's
  header declares a type parameter of that name.
- **§ typeParamDefersToTpUse186** (`R11U186_TPDEFER_OFF`): section 2a.

## 4. Verdict per targeted row (fresh rows of the final sweep; results/ untouched)

**4 uhdm2rtlil row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions, loudly** (§ pkgParamElabCaSharesDefFold183):

    ParameterFromPkgInNestedModule,default,CMP_EQUAL,,,equal          (was differ:fullname(7))
    ParameterFromPkgInNestedModule,testflags,CMP_EQUAL,,,equal        (was differ:fullname(7))
    ParameterFromPkgOnParameterPortList,default,CMP_EQUAL,,,equal     (was differ:fullname(7))
    ParameterFromPkgOnParameterPortList,testflags,CMP_EQUAL,,,equal   (was differ:fullname(7))

Downstream: `ParameterFromPkgInNestedModule,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
`ParameterFromPkgOnParameterPortList,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

**127 probe cases STRICT_NOTEQUAL -> EQUAL** (EQUAL 2895 -> 3022). By the laws that fire on each
(`evidence/probe_movers_laws.tsv`; a case may fire several): § ifaceArrPortSizeDimAtExpr183 60,
§ classPropElemClassTsAtType183 30, § importNetTsToInitEnd183 18, § foreachAssocLoopVarIdxTs183 (registration) 12,
§ classImportParamOwnRefs183 11, § pkgParamElabCaSharesDefFold183 4, § ifaceTwoPkgTdNameOrder186 3 (with
§ importNetTsToInitEnd183), § memberBareTdAliasNamedByUse183 2, § foreachAssocLocalSharesDeclTs183 2,
§ assocPromotedBoundAtBracket183 2.

**The rows of the brief, before -> after (this ground's half):**

| row-mode | base | final | law / what waits |
|---|---|---|---|
| ParameterFromPkgInNestedModule, ParameterFromPkgOnParameterPortList d/t (u2r) | `fullname(7)` | **CMP_EQUAL** | § pkgParamElabCaSharesDefFold183 |
| jeras_union d/t (u2r) | `fullname(75)` | `file(60)` | § aliasOfTdSharedKeepsModName183 cleared the names; the 60 `file` records are law aliasFoldBoundFile183 (unlanded, the sister's) (ParamEmit `emitPackage`, the sister's law_exprstmt.patch): waits for the sister |
| ArrayMethodIterator d/t | `endcol(1)` | `endcol(1)` | the base already carries § classTpDefaultTsAtUse180; the one record is law withClauseCloseParenEnd183 (unlanded, the sister's) (ExprEmit, the sister's): waits for the sister |
| ApbSlave d/t | `depth(1)` | `depth(1)` (order-blind 12 -> 4) | § classPropElemClassTsAtType183 + § importNetTsToInitEnd183 cleared N0067 / N0068 / the imported variable's span; the depth is N0289 = law defCloneRefsBindDefListing183 (unlanded, the sister's) (ParamEmit, the sister's): waits for the sister (r11u183 section 7: STRICT_EQUAL composed) |
| SVSwitch d/t | `file(15)` | `fullname(13)` | § classPropElemClassTsAtType183 (`Receiver rcvr[4]`'s class_typespec, map N0067); next: `size` reference full names (F5, ExprEmit) |
| MiniAmiq d/t | `fullname(8)` | `file(7)` | § memberBareTdAliasNamedByUse183 cleared `#770`; next `#899` the `uvm_severity` enum file (pass 176's class-writer residue) |
| SeqDriver d/t | `fullname(7)` | `col(6)` | same `#753`; next `seed_map.count[type_id]++` (ExprEmit, r11u183 e/p06) |
| BuildUVMPkg d/t | `fullname(23)` | `col(22)` | same `#1135` |
| SimpleUVM d/t, Scoreboard d | `fullname(23)` | `fullname(22)` | one alias name fewer; first ten are `UVM_MACRO_*` parameter reference names (N0682, ParamEmit, sister) |
| Rggen d | `endcol(634)` | `endcol(144)` | § ifaceArrPortSizeDimAtExpr183 + § macroPathTokSpans183 with § macroPathTokOneBuffer186; next `#2931` a `rggen_mux.sv` logic_typespec end column (6:11-6:41 golden, 6:30 ours) |
| Earlgrey_0_1 d/t | `col(102)` | `col(102)` (bytes deterministic) | § lawSCopyIdOrder186 + § aliasOfTdSharedKeepsModName183 (no strict field) |

Status histograms (CMP_EQUAL + STRICT_NOTEQUAL): surelog 456+24 default, 452+22 testflags (480 / 474 judge-equal, as at the base), uhdm2rtlil 786+17 both modes
(803 / 803). No row leaves judge-equality.

## 5. Determinism (brief item 2, caution j)

`drivers/det.sh <bin> <row> <mode> <N>`: N concurrent harness runs of one row-mode, the md5 of each database
(`evidence/determinism_runs.txt`):

| row-mode | pristine | final |
|---|---|---|
| Earlgrey_0_1 default | 2 hashes (`657dd42f` x2 + `529b2a71`, twice) | 1 hash (`d8c6c5f6` 3/3 on `d2`, 3/3 on `final.bin`) |
| Earlgrey_0_1 testflags | 1 hash 3/3 | 1 hash 3/3 |
| BuildUVMPkg default | 1 hash 6/6 + 3/3 | `final.bin`: 2 hashes (3 + 3 of 6, order only: raw uhdm-dump identical); `R11U183_TYPEPARAM_OFF` or `R11U186_TPGATE_OFF`: 1 hash 4/4 -> § typeParamDefersToTpUse186; **`final2.bin` 1 hash 6/6** |
| MiniAmiq, SeqDriver default | 3, 2 hashes of 3 | `final2.bin` 3, 3 of 3: every pair differs only by the known 4-line `UINT` / `vpiDecompile` coin (pristine the same) |
| SimpleUVM, Scoreboard default | 1, 1 of 3 | `final2.bin` 1, 1 of 3 (`final.bin` 2, 2: the UINT coin and Scoreboard's 92-line svunit order coin, 0 lines sorted) |
| Earlgrey_0_1 d/t on `final2.bin` | | 1 hash each, 3 of 3 (`d8c6c5f6`, `982f47f6`) |

The sort cannot remove those coins: they are not minted by LAW S.

## 6. The gates (final sweep `/tmp/r11u186_swG`, `final2.bin`)

| gate | result |
|---|---|
| (1) build | pristine `11406ca1…` = the main tree's; final `2d409958…` (the worktree rebuilt from the delivered sources) |
| (2) probe | regressions=0 conversions=127 changes=84; EQUAL 3022 STRICT_NOTEQUAL 1065, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 0 + 4; changes 12 + 2 (section 4) |
| (4) downstream | IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2, not identical and not excused=0; `downstream.csv` byte-identical to the pristine sweep's (pass 120's eight rows IDENTICAL, mem_read_reg `IDENTICAL,OK,OK,1789,1789`) |
| (5) uhdm-cmp | every moved row-mode and probe case keeps its judge-equal status (the strict stage 1 is uhdm-cmp's Compare; 0 regressions in all three stages) |
| (6) byteverify | corpus: MOVERS 36 / 2560 (SELFCHECK 2559/2560 flagged, `fenced_skipped=8`), probe: 253 / 4087; every one predicted by name and attributed (section 7) |
| canaries | `r11u107repro/canaries.sh`: surelog ok=43 changed=9 (exactly SVSwitch d/t, SimpleUVM d/t, SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d of section 4), uhdm2rtlil ok=16 changed=0 (pristine 52/0 and 16/0); `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS |
| changes judged | the 84 probe changes + 127 conversions: 206 BETTER, 5 SAME (r10uvm207repro g207_c_share / g207_e_head / g207_f_home / g207_h_foreign, r10uvm211repro g211_d_noimport: order-blind equal, the walk only), 0 WORSE by the order-blind strict-record distance (`drivers/chgdist.py`, `evidence/probe_change_orderblind.txt`); the corpus changes in section 4, Rggen's count FALLS |
| cases | 481 case directories (`evidence/grid_pristine_final.tsv`): 71 verdicts change, every one toward golden; of the 109 byte movers 103 BETTER and 6 SAME by the order-blind dump distance, 0 WORSE (`evidence/grid_movers_orderblind.tsv`) |
| switches | each switch alone moves only its own law's cases (`evidence/switches.txt`); `R11U186_LAWSSORT_OFF`, `R11U186_TPGATE_OFF`, `R11U183_FEIDX_OFF`, `R11U183_TYPEPARAM_OFF` move none of them (their movers are corpus / probe only, or none) |
| whole-pass switch | `R11U186_OFF=1 R11U183_OFF=1` on `final2.bin`: 4087 of 4087 `tests/probe` databases byte-identical to the pristine sweep's (its `probe.csv` too); 477 of 481 case directories identical (`drivers/offcheck.sh`, `evidence/offcheck_cases.txt`; the other 4 write no database on either binary: r11u180repro H/h23, h24 are three-file cases, r11u183dec a/c10, h/h09 slang failures) |
| downstream on cases | the 63 cases of this pass (`evidence/downstream_cases_pristine_final.txt`, `final2.bin`): 3 EQUIVALENT -> IDENTICAL (D/d01, d02, d07), 51 IDENTICAL, 7 EQUIVALENT and 2 STATUS_DIFF (I/i02, i03) unchanged, none moves away from IDENTICAL; the 147 r11u183dec cases: no verdict moves (`evidence/downstream_r11u183cases_pristine_final.txt`) |
| law index | regenerated; `python3 scripts/law_index.py --check`: current. Every full sweep above exits 1 for one reason only, `law index STALE` (the worktree's sources and this directory were ahead of `tests/LAWS.md` while they ran); after the regeneration `tests/sweep.sh --corpus probe` on `final2.bin` (`/tmp/r11u186_swH`) exits 0 (`law index current`, regressions=0 conversions=127 changes=84, `probe.csv` byte-identical to `swG`'s) |

## 7. Movers, predicted by name first

The prediction is the firing census (`drivers/census.sh`): the law binary with `R11U183_TRACE` and `R11U186_TRACE` over
both corpora in both modes (the fenced four excluded by `--filter`) and all 4087 probe cases, frozen `chmod 444`
before the gate sweep ran (`evidence/census_final.tsv`, `evidence/predicted_movers_final.tsv`: 29 surelog + 54
uhdm2rtlil row-modes, 425 probe cases; every law's trace sits on its firing branch, the sort law predicts `reorder` and
`multi`). Result on the final sweep against the pristine sweep:

- corpus: 36 movers, 36 predicted, 0 moved-not-predicted (`evidence/byteverify_G_vs_P.txt`,
  `evidence/mover_attribution.tsv`). By law: the UVM rows (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d,
  BuildUVMPkg d/t) the r11u183 class, import-copy, foreach, alias and span laws plus the sort; ApbSlave d/t
  § classPropElemClassTsAtType183 + § importNetTsToInitEnd183; SVSwitch d/t § classPropElemClassTsAtType183 +
  § ifaceArrPortSizeDimAtExpr183 (ArrayMethodIterator d/t moved on `final.bin` by § typeParamUseSharesOwnTs183 and
  keeps the pristine bytes on `final2.bin`, § typeParamDefersToTpUse186);
  Rggen d § ifaceArrPortSizeDimAtExpr183 + § macroPathTokSpans183 + § macroPathTokOneBuffer186; ParameterFromPkg* d/t
  § pkgParamElabCaSharesDefFold183; Earlgrey_0_1 d/t, LargeValue2Struct d/t, StructUnsizedVal d/t, UnionCast d/t,
  rp32_r5p_alu/bru/mdu/wbu d/t, jeras_union d/t § aliasOfTdSharedKeepsModName183 (+ the sort where `reorder`): on
  those rows other than jeras_union the uhdm-dump is identical pristine vs final and the strict cell stays `equal` /
  `col(102)` (the renamed shared alias reference is reached by neither walk; checked on UnionCast, LargeValue2Struct,
  StructUnsizedVal, rp32_r5p_alu, rp32_r5p_bru: 0 dump lines); their downstream verdicts IDENTICAL.
- probe: 253 movers, every one predicted (`evidence/probe_movers_G_vs_P.txt`); 11 of them fire only the sort law (`multi` /
  `reorder`), e.g. r10uvm125repro g125_a_dirs, r10sd5repro v6_no_import_control: uhdm-dump identical, order-only.
- Predicted-not-moved: 47 corpus row-modes and 172 probe cases, the sort law's superset (e.g. every ibex_*
  uhdm2rtlil row: on this machine's heap layout their triggers' address order and creation order mint the same
  sequence) and firings that rewrite a field to the value it had.
- The law sweep `swL` (`law.bin`) had two probe movers the census did not predict (r10v195repro v195_b_reads,
  v195_d_tfitem): found by this check, attributed by bisection to § typeParamUseSharesOwnTs183's gate (switch
  `R11U183_TYPEPARAM_OFF` restores the bytes, no law fires there) and removed by § typeParamGateNoLookup186.

## 8. The UVM rows (brief item 4)

Order-blind distance to golden (`drivers/uvmdist.sh`, strict records, depth dropped; `evidence/uvmdist_P_G.txt`),
pristine -> final2: MiniAmiq 26,583 -> 22,792 (testflags 26,585 -> 22,792), SeqDriver 19,523 -> 17,774 (testflags 19,521 -> 17,776), SimpleUVM
6,964 -> 5,913, Scoreboard 5,616 -> 4,688, BuildUVMPkg 3,293 -> 3,084, ApbSlave 12 -> 4, SVSwitch 106 -> 102. (r11u183's
expected 36,021 -> 26,247 and 29,571 -> 23,251 were measured at 80a1c2af with both patches; passes 176 and 180 have
taken 9,438 and 10,048 of those since.)

First records after the laws (`evidence/first10_after.txt`), by family: MiniAmiq `#899` enum `uvm_severity` file
(F3, pass 176's class-writer residue), `#1516/#1517` `seed_map.count[type_id]` columns (F7, ExprEmit inc/dec
operand, r11u183 e/p06), `#1694/#1858/#2014` `uvm_bitstream_t` / `uvm_integral_t` logic_typespec files at formal type
tokens (F6, § tdMoveCarriesFile172's writer order), `#2450` a depth record (`printer` bound to `uvm_default_printer`, a
reference binding, ExprEmit); SeqDriver the same from `#1499`; SimpleUVM / Scoreboard ten `ref_typespec UVM_MACRO_*`
package parameter reference names (F5, N0682, ParamEmit); BuildUVMPkg the `seed_map` columns then `severity` /
`UVM_ERROR` reference full names through `uvm_report::verbosity` (F5, ExprEmit); Earlgrey `#26470` a
`flash_phy_pkg.sv` constant column, then `reg2hw.key[i]` bit_select names (ExprEmit).

## 9. Residues, ranked, and the sister-ground faces (decoded; the fix sits elsewhere or is out of reach)

1. **Waiting for the sister's law_exprstmt.patch** (r11u183 section 7 measured both together): jeras_union d/t
   (law aliasFoldBoundFile183 (unlanded, the sister's)), ArrayMethodIterator d/t (law withClauseCloseParenEnd183 (unlanded, the sister's)), ApbSlave d/t
   (law defCloneRefsBindDefListing183 (unlanded, the sister's)), and r11u183's three both-patch probe cases.
2. **R1 — a named type-parameter override by a module-local enum typedef** (TypeParameterAsPortTypeWithEnum d/t
   `file(8)`, TypeParameterAsPortTypeWithEnumOfParametrizedWidth d/t `file(6)`; case Y/y01 reproduces, `file(4)`):
   golden files and spans the instance's copy of the enum (the type_parameter's and the port variable's) at the typedef
   declaration (dut.sv 9:3-11:16), ours leaves both copies unlocated. The type_parameter copy of a NAMED override is
   ParamEmit's per-instance mint (§ instTypeParamSharesDef120 excludes named overrides); the port variable's copy follows
   it. Not landed (the copy's mint site is the sister's; not pinned without gdb).
3. **R2 — pass 176/180 carried** (not attempted): the UVM class-writer relocation with outside writers (MiniAmiq `#899`),
   § tdMoveCarriesFile172's writer order across unit kinds (the `uvm_bitstream_t` files), a package variable at a module
   declarator's position, program instances sharing processes, a pasted-token io_decl column, the include-file undef
   residue, the modport grids, interface-instance delays, the generate array indexed by a struct-parameter member,
   CovMacro's macro-argument columns, enums their importers cast to, P/p08 (an included file keeping the main file).
4. **R3 — Rggen d `#2931`**: a `rggen_mux.sv` logic_typespec ending at 6:30 where golden reads 6:41 (not decoded).
5. **R4 — § macroPathTokSpans183's multi-buffer components** (Q/q05 `fullname(6)`): a select whose index is a macro
   argument is laid out by golden at the argument's expanded position (`bits[5]` 4:43-4:44); neither the pristine nor
   the token mapping reproduces it. TypeEmit `emitSyntaxExpr` (this ground), next pass.
6. **R5 — PreprocTest d/t endcol(2)** (N0056): the enum base `bit_typespec` span alone (5:14-5:17 golden, 5:14-5:23
   ours); Surelog lexes `bit` in a `.vh` file without `-sv` as an identifier (pass 168's decode); the harness never tells
   slang-uhdm Surelog's language mode. Not implementable on this ground.
7. **R6 — the elaborated fold of a package parameter with an unsized default** (P/p01-p03, p05-p08, judge-unequal):
   golden's elaborated cont_assign constant has vpiSize 32 (the literal's own width) where ours keeps the parameter's
   width; the fold is built by ExprEmit's elaborated substitution (ModuleEmit `emitContAssigns` only places it): the
   sister's.
8. **R7 — the separator in a generate step** (D/d06): golden's elaborated loop reads `1_0` as 1 in the step; report only.
9. **Map 9's greedy list, measured at the base** — StructParamPatternInitCast d/t `fullname(3)` (N0014): the first
   record is a bare `ref_typespec` golden leaves without a full name (`work@StructParamPatternInitCast` ours), then two
   in-copy member names: ParamEmit's op75 `MakeRef_typespec` (pass 180's S1); no TypeEmit / ModuleEmit half at the
   first record. ibex_icache `fullname(49)` (N0129), iface_zero_width_field `fullname(3)` (N0688): ExprEmit / ParamEmit
   as pass 180 decoded (S5, S4). HierPathTypespec t `fullname(1)` (N1174): not attempted (naming context-dependent).
   LogicTypespec d/t `endline(3)`: a user decision, measured only (package logic_typespec 2:9-7:44 golden, 2:9-2:20
   ours, unchanged). **InterfaceModPort d/t `endcol(12)`** (report only): the objects are the `logic_typespec` of the
   six SCALAR `logic` signals of interface `mem_if` (`reset`, `we_sys`, `cmd_valid_sys`, `ready_sys`, `we_mem`,
   `ce_mem`; top.v 27-34), definition and elaborated listings: golden ends at the keyword (27:3-27:8), ours at the
   declarator's name (27:21); three smaller shapes (an interface with a port and modports, without a port, a
   modport-qualified port reading the signals) are STRICT_EQUAL on the pristine binary, so the stretch needs something
   else of this design (not isolated). **YosysRiscv**: CMP_EQUAL at the base (pass 181's § bitSelParenIdxSpan181).
10. **Sister faces carried from passes 176-181**: isNetLvalueSyntax's concatenation branch (EmitHelpers.h); Scr1SvTests
    d/t `type(1)`'s call-argument formal typespec (not decoded here); ibex_multdiv_fast's generate-block enum constants
    (`file(11)`, not decoded here).

## 10. Files

- `cases/<letter>/<case>/dut.sv` (63 cases, first line `// § <law>`): A § assocPromotedBoundAtBracket183 (n01-n04),
  § assocBracketPkgOnly186 (n05-n07); D § enumConstUnderscoreDropped186 (d01, d02, d07), § synLitUnderscoreDropped186
  (d03, d04, d06), § boundLitUnderscoreDropped186 (d05, d08); E § aliasOfTdSharedKeepsModName183 (e01-e03); F
  § foreachAssocLocalSharesDeclTs183 (f01-f03, f03 with § assocPromotedBoundAtBracket183); G
  § memberBareTdAliasNamedByUse183 (g01-g03); H § importNetTsToInitEnd183 (h01-h04); I § ifaceArrPortSizeDimAtExpr183
  (i01-i04); K § classImportParamOwnRefs183 (k01-k03); P § pkgParamElabCaSharesDefFold183 (p01-p05),
  § pkgParamFoldOwnTs183 (p06-p08); Q § macroPathTokSpans183 (q01-q03), § macroPathTokOneBuffer186 (q04, q05); R
  § rootElemAtNextTok186 (r01-r03); T § typeParamUseSharesOwnTs183 (t01-t03); U § classPropElemClassTsAtType183 (u01,
  u02, u04), § classPropElemQualTs186 (u03, u05); W § ifaceTwoPkgTdNameOrder186 (w01-w03); Y § instTypeParamSharesDef120
  (y01, residue R1).
- `drivers/`: `env.sh` (pins, `$FENCED`, fail closed), `sweep.sh`, `case.sh`, `grid.sh`, `obd.sh`, `row.sh`,
  `rowrun.sh`, `det.sh`, `census.sh` + `censum.py` (the prediction), `bvmirror.sh`, `probemovers.sh`, `chgdist.py` +
  `obdist.py` (from r11u183dec), `uvmdist.sh` (from r11u183dec), `offcheck.sh`, `switches.sh`, `dscase.sh` +
  `dsgrid.sh`.
- `evidence/`: the census and the frozen prediction, the sweep summaries, byteverify and probe movers, the mover
  attribution, the probe mover laws, the grid and its order-blind judgement, the switches, the downstream on cases,
  determinism runs, UVM distances and first records.
