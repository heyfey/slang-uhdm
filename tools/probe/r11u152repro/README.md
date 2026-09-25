# r11u152: the module/type ground on the strict axis (pair B, refill after pass 146)

Base `d10675dd` (branch matrix-1.87). Files of the ground touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp` (no header, no `ExprEmit.cpp` / `EmitHelpers.h` / `StmtEmit.cpp` / `ParamEmit.cpp`
line). The pass lands r11u151's C3 module half (`evidence/pairB_c3_scratch.patch` of
`tools/probe/r11u151struct`) as § portConnParamFoldAtActual152 and thirteen further laws. The slang-fenced
tests are written `FENCED=` here; every driver that reads corpus sources or databases refuses to run
without `$FENCED` and skips those names (word match). No fenced test was run, read or decoded.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u152_bin/pris.bin` | `0a647f63db9a3a6b6811c14d2c10f4e3` | worktree at d10675dd, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` |
| `/tmp/r11u152_bin/law2.bin` | `0a5eed3a32dc0aeefe4abf086c5de435` | d10675dd + this patch (the final build) |
| `/tmp/r11u152_bin/law.bin` | `50f9fb32ee73e89515fa06c72312c383` | the previous build; its sweep found § classVarInitSpan152's typespec half moving class-method locals (BuildUVMPkg, MiniAmiq, away from golden); the final build restricts it to module scope (section 6) |
| `/tmp/r11u152_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator (worktree build = main tree build) |

Every `cmds.txt` of the sweeps names its binary by path. Workdirs (same length): `/tmp/r11u152_swP`
(pristine), `/tmp/r11u152_swM` (final law), `/tmp/r11u152_swL` (the superseded law.bin).

## 2. Laws (each behind its own switch; `R11U152_OFF=1` drops every law of the pass)

| law | switch | site | statement (Surelog decode) |
|---|---|---|---|
| § portConnParamFoldAtActual152 | `R11U152_C3_OFF` | ModuleEmit.cpp emitInstance (the `.port(Param)` unpacked struct-array fold) | r11u151's C3 module half. The connection's folded pattern operation is located at the ACTUAL (compileExpression's parameter case clones the param_assign Rhs and `populateCoreMembers(child, child, result)` relocates the root to the reference, CompileExpression.cpp) and its ts ref is named through the port of the instance `prefix` already names (`work@top.u.a_i`, not `work@top.u.u.a_i`). Declined for a package-qualified actual (`.a(pk::P)`: golden keeps another shape, grid C3 c07) |
| § genLpOperandTsNoParent152 | `R11U152_GENLPOPTS_OFF` | ModuleEmit.cpp gen-loop localparam fold (`int L = P[k]` adopting the elaborated pattern operand) | map N0008's generate face. The ref_typespec the adopted operand constant gets has no parent (no full name) when the localparam's block is NESTED (a loop inside a loop or an if-block, an if-block inside a loop); a block of a loop written directly in the module keeps it. Surelog's writer is compileParameterDeclaration's `tsRef->VpiParent(c)` (CompileHelper.cpp:3750) on the reduced constant; the nested elaboration hands it an unparented clone. Grid LP (11 cases) |
| § crossPkgFoldTsNameOnChain152 | `R11U152_FOLDCHAIN_OFF` | TypeEmit.cpp crossPkgBoundFoldConst9 | map N0008's ibex face. The folded package-parameter bound constant's ref_typespec stores no name when its chain ends at a parentless typespec in the DECLARING package's own listing (`parameter logic [MSB:0] R[N]` in pk, owner `pk::R`): golden's name is empty there (the identifier branch's reference reads its chain, CompileExpression.cpp). An importing module's copy (`work@top.R`, grid PB b04) and an importing package's copy (ibex_tracer_pkg, grid PB b09) keep it |
| § tpElemPatAtUser152 | `R11U152_TPELEMPAT_OFF` | TypeEmit.cpp emitTypeParamArrayVar (the dimensionless cell) | map N0470. A PORT typed by a type parameter whose default wraps a named element in a packed dimension (`localparam type rt_t = id_t [3:0]`) holds golden's per-use copy of that packed_array_typespec, parented at the port's variable: its element reference names through it (`work@dut.rt_i.id_t`). Ours copies the object (same span, the SAME range so the bound references keep `work@dut.rt_t.DEPTH`, grid TP t07) with its own element reference, parented at the variable. A body declaration keeps the shared object (golden unparented there, grid TP t03/t04) |
| § pkgElemMemberPatNoLoc152 | `R11U152_PKGELEMPAT_OFF` | TypeEmit.cpp makeTypespec (the packed array over a struct/enum typedef leaf) | map N0433 + N0436 + N0494. A struct/union MEMBER written package-qualified with packed dims (`fp::cf_t [3:0][7:0] at;`) reads golden's UNLOCATED packed_array_typespec: compileTypespec's package-scope branch builds it without `populateCoreMembers` (CompileType.cpp:1597-1621, against the bare-name branch's `populateCoreMembers(type, last_Packed_dimension)` at CompileType.cpp:1987). At file level ($unit) its element reference has no parent either; in a package or a module it keeps it (grid UQ u06/u08/u10). A bare name reaching the same leaf keeps the span (UQ u05/u09) |
| § packedElemAliasTypedef152 | `R11U152_ELEMALIAS_OFF` | TypeEmit.cpp makeTypespec (same branch) | map N0163 + N0655. The packed array's element is the typedef WRITTEN at the declaration: an alias of an enum typedef (`typedef lc_tx_e lc_tx_t; lc_ctrl_pkg::lc_tx_t [0:0] x`) is its own enum_typespec (`lc_tx_t`, Typedef_alias -> `lc_tx_e`), not the first typedef of the same canonical type |
| § tpOvrTypedefStructSpan152 | `R11U152_TPOVRSTRUCT_OFF` | TypeEmit.cpp makeTypespec (the anonymous packed/unpacked struct branches) | map N0454 + N0531. An elaborated type parameter overridden by a MODULE-local struct typedef (`sub #(.T(my_t))`) holds golden's clone of that typedef: the typedef's whole span (`struct packed {...}` through the brace) and member references named through the type parameter (`work@tb.d.T.my_t.x`). Recognised by the type-parameter emission's signature (a typedef clone while the owner and the reference prefix are both the parameter's path). When every declaration typed by the parameter writes packed dims on it in the body (`T [1:0] q;`), golden's copy is unparented and the members read `my_t.x` (grid PS p05) |
| § genCaseItemUnnamed152 | `R11U152_GENCASE_OFF` | ModuleEmit.cpp emitCaseItem / emitBranch (definition view) and the elaborated gen_scope_array span | map N0646 (+ GenCase, pass 145's sister residue). CompileStmt leaves a case-generate item's parent unset, so ComputeFullName stops under it: the item's expressions and its named block store no full name and the block's contents are named from the label (`gw.w`). Elaborated: a NAMED case block keeps its begin..end span (GenCase `tag1` 12:13-14:8); the first-member span stays for an unnamed one. Grid GC |
| § delayLiteralValueText152 | `R11U152_DLYREAL_OFF` | ModuleEmit.cpp emitAssignDelay | map N0528. A REAL literal delay (`assign #0.1`, `wire #0.25 w = a`) keeps its text as the value: the `#0.1` token is compileConst's slIntConst and the value is `UINT:` + the token text with `#` and `_` removed (CompileExpression.cpp:471-560), UINT:0.1 where ours read UINT:0 |
| § unsupportedTsInitEnd152 | `R11U152_CGINITEND_OFF` | TypeEmit.cpp makeTypespec (covergroup handle) + ModuleEmit.cpp (the elaborated covergroup logic_var) | map N0117 + N0768. An initialised covergroup handle (`cg cg_inst = new(3);`): the definition net's unsupported_typespec ends at the initializer, not at the semicolon; the elaborated logic_var spans its name through the initializer. Grid CG |
| § classVarInitSpan152 | `R11U152_CLSVARINIT_OFF` | ModuleEmit.cpp (the elaborated module-scope variable) + TypeEmit.cpp makeTypespec (class handle) | map N0498. An initialised MODULE-scope class handle spans its name through the initializer (elaborated class_var), and a written specialization's typespec on the definition net ends at the initializer (`config_db#(..) misc2 = new;` 18:3-18:43). A class method's local keeps the type span (golden `uvm_callback_iter#(..) iter = new(this);` 33527:6-33527:48) |
| § classSpecNestedAtName152 | `R11U152_CLSNESTNAME_OFF` | UhdmExporter.cpp emitClassTsParams | a specialization written as another specialization's argument (`config_db#(object#(longint))`) is located at its class NAME (18:14-18:20) |
| § classSpecPaNoFile152 | `R11U152_CLSPANOFILE_OFF` | UhdmExporter.cpp emitClassTsParams | map N0447. The specialization's param_assign carries the formal's line and columns but NO file |
| § pkgLeafPatLocByWriting152 | `R11U152_PKGLEAFLOC_OFF` | TypeEmit.cpp makeTypespec (same branch as § pkgElemMemberPatNoLoc152) | map N0037 + N0062. The package leaf's packed_array_typespec is unlocated only when WRITTEN package-qualified (CompileType.cpp's package-scope branch, above); a bare name reaching it through an import (`module m import pk::*; (input s_t [2:0] a)`) keeps the declaration span (ParamTypespec2 15:10-15:24; grid PL l01/l06 against the scoped l02) |

The switch helper is `r11u152Law` (UhdmExporter.cpp, beside `r11u146Law`).

## 3. Targeted rows (fresh law-sweep csv rows, `name,mode,status,detail,blocked_by,strict`)

**32 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL (strict `equal`), 0 regressions.** Surelog 18 (default
CMP_EQUAL 406 -> 415, testflags 405 -> 414), uhdm2rtlil 14 (714 -> 721 per mode).

| row-mode(s) | before | after (fresh row) | law (single-switch attribution, section 4) |
|---|---|---|---|
| StructArrayParameterInitializedByPatternPassedAsPort d / t | differ:line(2) | `...,CMP_EQUAL,,,equal` both modes | portConnParamFoldAtActual152 |
| LocalParamInNestedForLoops d / t | differ:fullname(1) | `LocalParamInNestedForLoops,default,CMP_EQUAL,,,equal`, same testflags | genLpOperandTsNoParent152 |
| type_param_packed_dim d / t | differ:fullname(1) | `type_param_packed_dim,default,CMP_EQUAL,,,equal`, same testflags | tpElemPatAtUser152 |
| FileLevelUnionWithMultirange d / t | differ:file(14) | `...,CMP_EQUAL,,,equal` | pkgElemMemberPatNoLoc152 |
| PackageMemberTypespec d / t, UnsupportedTypespecRange d / t | differ:file(2) | `PackageMemberTypespec,default,CMP_EQUAL,,,equal`, `UnsupportedTypespecRange,...,CMP_EQUAL,,,equal` | pkgElemMemberPatNoLoc152 |
| PackedEnumPort d / t, VarPassedTo2Submodules d / t | differ:name(3) | `PackedEnumPort,default,CMP_EQUAL,,,equal`, `VarPassedTo2Submodules,...,CMP_EQUAL,,,equal` | packedElemAliasTypedef152 |
| packed_array_struct_port_sel d / t | differ:endcol(9) | `...,CMP_EQUAL,,,equal` | tpOvrTypedefStructSpan152 |
| struct_member_cfg_width d / t | differ:endline(12) | `...,CMP_EQUAL,,,equal` | tpOvrTypedefStructSpan152 |
| TypeParamElab d / t | differ:endline(15) | `TypeParamElab,default,CMP_EQUAL,,,equal`, same testflags | tpOvrTypedefStructSpan152 |
| GenCase d / t, GenCaseStmt d / t | differ:fullname(4) | `GenCase,default,CMP_EQUAL,,,equal`, `GenCaseStmt,...,CMP_EQUAL,,,equal` | genCaseItemUnnamed152 |
| DelayAssign d / t | differ:value(16) | `DelayAssign,default,CMP_EQUAL,,,equal`, same testflags | delayLiteralValueText152 |
| CrossFunc d / t | differ:endcol(2) | `CrossFunc,default,CMP_EQUAL,,,equal`, same testflags | unsupportedTsInitEnd152 |
| ClassParamAsParam d / t | differ:endcol(9) / (13) | `ClassParamAsParam,default,CMP_EQUAL,,,equal`, same testflags | classVarInitSpan152 + classSpecNestedAtName152 + classSpecPaNoFile152 (each alone leaves it NOTEQUAL) |

**Downstream rows of the converted uhdm2rtlil tests (fresh, all IDENTICAL, `differs` empty):**
`FileLevelUnionWithMultirange,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `LocalParamInNestedForLoops,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`packed_array_struct_port_sel,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `struct_member_cfg_width,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`StructArrayParameterInitializedByPatternPassedAsPort,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `type_param_packed_dim,IDENTICAL,OK,OK,9,9,,`
`VarPassedTo2Submodules,IDENTICAL,NO_GATES,NO_GATES,0,0,,`.

**Improved, still STRICT_NOTEQUAL (every one a smaller count; the first field moves to the next face):**
NestedStructArrayParameterInitializedByPatternPassedAsPort d/t fullname(4) -> fullname(2) (C3; the rest is pair
A's § nestedPatOpTsNoParent151); ibex_alu fullname(2) -> endcol(1), ibex_branch_predict fullname(13) -> line(12),
ibex_compressed_decoder fullname(134) -> endcol(133), ibex_decoder fullname(21) -> endcol(20), ibex_icache
fullname(193) -> line(192), ibex_multdiv_fast fullname(102) -> endcol(101), ibex_multdiv_slow fullname(19) ->
endline(18), ibex_pmp file(53) -> file(52), ibex_tracer fullname(580) -> fullname(579), ibex_wb_stage fullname(25)
-> line(24) (all d/t, crossPkgFoldTsNameOnChain152); type_param_override_elem_sel fullname(2) -> fullname(1)
(tpElemPatAtUser152); gen_scope_typaram endcol(9) -> fullname(6) (tpOvrTypedefStructSpan152); ClassTypeParam
endline(25) -> endline(17) / file(38) -> file(30) (classVarInitSpan152 + classSpecPaNoFile152); GenerateUnnamed
fullname(15) -> fullname(9) (genCaseItemUnnamed152); ParamTypespec2 fullname(5) -> fullname(3)
(pkgLeafPatLocByWriting152); Earlgrey_0_1 d/t line(1747) -> line(1743) (pkgLeafPatLocByWriting152).

## 4. Gates (`tests/sweep.sh --jobs 3`, `evidence/sweeps/sweep_{pristine,law}.log`)

| gate | pristine (`/tmp/r11u152_swP`) | law (`/tmp/r11u152_swM`) |
|---|---|---|
| probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2390, STRICT_NOTEQUAL 1697) | regressions 0, conversions 46, changes 65 (EQUAL 2436, STRICT_NOTEQUAL 1651) |
| surelog vs golden_surelog.csv | 0 / 0 / 0 | regressions 0, conversions 18, changes 8 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | regressions 0, conversions 14, changes 26 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0 | the same, verdict column identical row by row |

Both sweeps exit 1 for one reason only: `law index STALE` (the worktree's edited `src/`, before
`scripts/law_index.py` is run; the patch carries the regenerated `tests/LAWS.md`). uhdm-cmp is at 0 lines on
every touched row and case: every converted row is CMP_EQUAL, every changed row and case stays STRICT_NOTEQUAL
(judge-equal), and the probe stage has no NOT_EQUAL case.

* **Changes, all smaller.** All 99 CHANGE lines (65 probe, 8 surelog, 26 uhdm2rtlil) lower the object count.
  `drivers/changecheck.py` re-runs uhdm-strictcmp on the pristine and the law database of each and reports any
  differing record the law has that pristine did not (`evidence/sweeps/changecheck.txt`): 94 are strict
  subsets. The other 5 hold the SAME objects with a changed rendering, no new object: gen_scope_typaram d/t
  (the member reference moved from `x` to golden's tail `pair_t.x`, raw name still through the parameter),
  `v11u108repro/brk/f5/b15_child_ports` (the bound `D` moved from `<in>D` to golden's `<in>rt_t.D`, raw name
  still the instance's: the sister N0472 face), ClassTypeParam d/t (the specialization param_assign's file is
  now golden's empty one, and its next field, golden's 0:0 line, reads).
* **Switch attribution** (`drivers/attrib.sh`, `drivers/attrib_probe.sh`, `drivers/attrib_table.py`,
  `evidence/sweeps/attribution.txt`): every moved corpus row-mode and probe case re-run with the law binary and
  ONE switch; each names its law(s) (section 3 and the table). `R11U152_OFF=1` returns every moved probe case to
  its pristine verdict, all 102 grid cases to the pristine BYTES (`evidence/grid/gridall.txt`), and all 66
  databases of the moved corpus tests (13 surelog + 20 uhdm2rtlil tests, both modes, Earlgrey_0_1 included) to
  the pristine sweep's bytes (`evidence/sweeps/off_restore_corpus.txt`).
* **Byte movers** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, path sets identical, 959/960 and
  1607/1608 flagged by the self-check): uhdm2rtlil 40 = exactly the 20 moved tests x 2 modes; surelog 32 = the 26
  attributed row-modes + the UVM coin family (Scoreboard d, SeqDriver d/t, SimpleUVM d/t, MiniAmiq t), each 0 or
  4 order-blind dump lines (`evidence/sweeps/uvm_coin_orderblind.txt`). Probe: 124 databases move = the 111
  moved cases + 13 byte-only movers (verdict and count unchanged), each attributed to one switch
  (`evidence/sweeps/probe_byteonly_movers.txt`: TPELEMPAT 9, CLSPANOFILE 2, PKGLEAFLOC 1, GENCASE 1).
  Prediction: the movers were not predicted by name before the law sweep; they were identified by the byte
  verifier and each attributed afterwards by the single-switch re-runs above (a gap against the brief's
  prediction step, stated here).
* **The superseded build.** `law.bin`'s sweep (`/tmp/r11u152_swL`) read the same conversions and changes, but its
  byte verifier showed BuildUVMPkg d/t and MiniAmiq d moving ~200 order-blind dump lines: § classVarInitSpan152's
  typespec half stretched class-METHOD locals (`uvm_callback_iter#(..) iter = new(this);`) to the initializer,
  away from golden (33527:6-33527:48), invisible to the strict count. The final build restricts that half to
  module scope; BuildUVMPkg no longer moves.
* **Canaries** (`evidence/sweeps/`): canaries.sh surelog ok=46 changed=6 (Earlgrey_0_1 d/t, ClassParamAsParam
  d/t, ClassTypeParam d/t, all attributed above), uhdm2rtlil ok=16 changed=0; ctcan2 surelog ok=58 changed=0
  (EXPECT_UNKNOWN=1) PASS, uhdm2rtlil ok=2 changed=0 (EXPECT_UNKNOWN=6) PASS.
* Pass 120's eight rows stay IDENTICAL and every earlier-pass probe case is either unmoved or in the attributed
  improvement list; no case left EQUAL.

## 5. Grid (`cases/`, 102 cases, `drivers/gridall.sh`, `evidence/grid/gridall.txt`)

Goldens: `drivers/grid.sh` (pinned Surelog with check_probe's arguments, cached under `/tmp/r11u152_g`); ours
with `--single-unit --nobuiltin`. Each case's first line names its law. Columns: pristine verdict, law
verdict, verdict with the case's own switch, bytes under `R11U152_OFF=1` and under the own switch against
pristine.

| dir | law | cases | pristine EQUAL | law EQUAL | controls (unchanged) |
|---|---|---|---|---|---|
| C3 | portConnParamFoldAtActual152 | 12 | 0 | 5 (c01 c03 c04 c09 c12) | c02/c05 (pair A's ParamEmit half), c07 (qualified, declined), c10 (in a generate: golden keeps a ref_obj), c06/c08/c11 (stage-1 faces) |
| LP | genLpOperandTsNoParent152 | 11 | 3 | 11 | a06/a09/a10 (loop directly in the module) stay EQUAL |
| PB | crossPkgFoldTsNameOnChain152 | 8 | 0 | 5 | b05/b06/b07 stage-1 faces, unchanged |
| TP | tpElemPatAtUser152 | 8 | 1 | 7 | t08 (non-ANSI: the line face remains, the fullname face gone) |
| UQ | pkgElemMemberPatNoLoc152 | 11 | 2 | 10 | u07 stage-1 |
| EA | packedElemAliasTypedef152 | 5 | 0 | 1 | e02 (base typedef written: another face), e03-e05 stage-1 |
| PS | tpOvrTypedefStructSpan152 | 16 | 1 | 13 | p13 stage-1; p15/p16 residue (section 7) |
| GC | genCaseItemUnnamed152 | 6 | 1 | 6 | |
| DV | delayLiteralValueText152 | 8 | 1 | 3 | d03-d06, d08 stage-1 (time units, exponent, underscore, parenthesised delays) |
| CG | unsupportedTsInitEnd152 | 5 | 0 | 4 | c03 stage-1 |
| CV | classVarInitSpan152 (v01-v04), classSpecNestedAtName152 (v05), classSpecPaNoFile152 (v06) | 6 | 1 | 4 | v02 (the member's int_typespec, residue), v04 stage-1 |
| PL | pkgLeafPatLocByWriting152 | 6 | 4 | 6 | l02-l05 stay EQUAL |

Every case's own switch returns it to the pristine verdict; its bytes return to pristine except CV v02/v05
(the three class switches share them; the three together restore the bytes) and PS p04 (moved by
§ pkgLeafPatLocByWriting152, EQUAL both ways).

## 6. Decode notes

* C3 re-measured at the base: with r11u151's scratch transcription alone, StructArray...PassedAsPort converts
  both modes; the Nested twin keeps pair A's two ParamEmit ref_typespecs (§ nestedPatOpTsNoParent151).
* LP distinguisher: a06 (single loop, two iterations) was EQUAL under pristine and broke under the unconditional
  law; the grid (a06-a15) splits on the NESTING of the localparam's block, not on iteration counts.
* PB distinguisher: b04 (module `import pk::*`) and ibex_tracer (package `import ibex_pkg::*`) keep the name; the
  law needs the owner to be the declaring package itself.
* PS distinguisher: p05 (only `T [1:0] q;` in the body) reads the typedef-relative name `my_t.x`; ports, bare
  body declarations, no users, nested passes and generate-scope instances read the parameter's path (p01-p14).
* The typespec half of § classVarInitSpan152 is module scope only (section 4, the superseded build).

## 7. Residues, ranked

1. **N0472** (param_array_wildcard, type_param_override_elem_sel; 42 probe cases, among them the TP-family
   changes above): SISTER GROUND. golden names a definition-listed bound through the DEFINITION in an elaborated
   non-top instance (`work@decoder.DAM.IFN`, `work@child.rt_t.DEPTH`) where ours uses the instance path. Call
   sites: ParamEmit.cpp emitParameters, `syntaxRefPrefix = joinPath(prefix, tps.name)` (type parameters) and
   `syntaxRefPrefix = joinPath(prefix, ps.name)` (value parameters), under § typeParamNamedElemPackedDim31.
2. **The ibex family after § crossPkgFoldTsNameOnChain152** (10 tests x 2): ibex_alu's last face is the
   definition param_assign Rhs of `parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone`, which golden spans
   `ibex_pkg::` only (10:39-10:49): SISTER GROUND, ExprEmit.cpp emitExpr / tryFoldConst / enumMemberSubstConst
   under ParamEmit.cpp emitParameters (`evidence/residue/ibex_alu_enum_default_span.sv`). The others head on
   line / endcol faces (the ibex macro-line set, map N0017 + N0026 + N0027 + N0029, UhdmExporter locLineCol), not
   attempted.
3. **ParamTypespec2** (fullname 3): the package parameter's pattern operation ts ref is named `prim_esc_pkg`
   where golden's is empty: SISTER GROUND, ExprEmit.cpp emitExpr < ParamEmit.cpp emitParameters < emitPackage
   (traced with a conditional breakpoint on the name).
4. **NestedStructArray...PassedAsPort**: pair A's § nestedPatOpTsNoParent151 (ParamEmit).
5. **gen_scope_typaram** (and grid PS p15/p16): an instance inside a generate block with typed ports; golden's
   clone members read `pair_t.x` at every listing, ours the parameter's path. Not decoded (p12, an if-generate
   instance with one input port, reads both names).
6. **ClassTypeParam**: a typedef of a specialization; golden leaves the type_parameter and the param_assign
   unlocated (0:0) and spans the class_typespec through the typedef. Not decoded.
7. **CV v02**: a class member typed by the class's type parameter (`T x;`) reads golden's int_typespec at the
   default's `int` token (2:18-2:21), ours at the use (3:3-3:4). Class emission (UhdmExporter / TaskFuncEmit).
8. **C3 c10** (a package-parameter connection inside a generate block: golden keeps a ref_obj, no fold) and c07
   (a package-qualified actual: golden's element pattern at its own span).
9. **GenerateUnnamed** fullname(9): nested unnamed generate naming (`genblk1.genblk1.u1.a`).
10. **StructUnsizedVal / LargeValue2Struct**: the param_assign Rhs of a bare imported parameter spans only
    5 columns (`17:53-17:58`, golden the identifier 17:53-17:64): SISTER GROUND (ParamEmit / ExprEmit).
11. **N0078** (ibex_register_file_ff, 31 objects): the definition-view WordZeroVal constant's typespec bound
    `DataWidth` reads no full name; site not pinned.
12. **OneNetModport**: golden names the interface's io_decl variables through the connection
    (`work@top.dut.sub1.inp.drive`); a Surelog last-writer effect, not decoded.

Not reached: the pass-146 residues (IfGenTypeBinding's § defNetTypedefEndWrite134 over-firing,
packed_array_struct, the escaped-identifier leftovers, interface type-parameter default spans, the declined
shapes of § tfArgTypedefLastWriter146), pass 145's other sister residues (PreprocTest, IndexAssign, N0005, the
port-view parameter fold span), the verifiers' standing faces, and the UVM/Earlgrey-only clusters.

## 8. Files

* `cases/<dir>/<case>/dut.sv`: the 102 grid cases (first line `// § <law>`).
* `drivers/grid.sh` (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), `drivers/gridall.sh` (every case,
  four binaries/switch states), `drivers/heads.sh` (strict heads of named rows, fail-closed on `$FENCED`),
  `drivers/changecheck.py` (subset check of every CHANGE), `drivers/attrib.sh` + `drivers/attrib_probe.sh` +
  `drivers/attrib_table.py` (single-switch attribution), `drivers/byteonly.sh` (byte-only probe movers),
  `drivers/uvmmovers.sh` (the UVM re-runs that found the superseded build's class-method movement).
* `evidence/grid/gridall.txt`, `evidence/sweeps/` (sweep logs, byteverify, change check, attribution, canaries,
  UVM coin, byte-only movers), `evidence/residue/` (a sister-ground repro).
