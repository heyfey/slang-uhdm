# r11u160: the module/type ground on the strict axis (pair B, refill after pass 155)

Base `75226e07` (branch matrix-1.87). Files of the ground touched: `src/UhdmExporter.cpp`, `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `uhdm_main.cpp` (no header; no `ExprEmit.cpp` / `EmitHelpers.h` / `StmtEmit.cpp` /
`ParamEmit.cpp` line). Eight laws under sixteen switches; `R11U160_OFF=1` drops all of them. The switch helper is
`r11u160Law` (UhdmExporter.cpp, beside `r11u155Law`).

The slang-fenced tests are written `FENCED=` here. Every driver that reads corpus sources or corpus databases
(`drivers/predict.py`, `drivers/attrib.sh`, `drivers/dumpdist.sh`, `drivers/bvmirror.sh`) refuses to run without
`$FENCED` (four names, taken from RESUME.md, never spelled) and skips those names (word match). The byte comparisons
ran on hard-link mirrors that leave the 8 fenced row-mode databases out (`drivers/bvmirror.sh`). No fenced test was
run, read or decoded outside the gate sweeps, which dispatch every row themselves.

r11u161 (the definition-view generate-path family, the first ordered connection, the non-package enum alias clone)
landed in the main tree as a measurement-only commit AFTER this pass started (its `law.patch` was not in the tree at
the start), so this pass did not land it and wrote none of its three faces (S5, S6 and r11u159 residue 1 are its). Its
`law.patch` (based on 5a602076) does not apply on a fresh 75226e07 either: its hunks at the helper declarations
(TypeEmit.cpp `r11u155Law` line, ModuleEmit.cpp the same) need a rebase, and they sit where this patch adds
`r11u160Law`'s declaration.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u160_bin/pris.bin` | `2aa918616ddb54c5502f85f387b3e4f7` | worktree `/tmp/wt_r11u160` at 75226e07, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` |
| `/tmp/r11u160_bin/law.bin` | `7caa76089b0d55ebfe3401b263799570` | 75226e07 + this patch (the final build) |
| `/tmp/r11u160_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator |
| `/tmp/r11u160_bin/g1.bin` | `18899914190e75e966ccd78f303f6c9a` | `-g1` build of 75226e07 (gdb only: the struct-clone callers) |
| `/tmp/r11u160_bin/strictcmp_x` | (built by `r11u156map/drivers/cc.sh`) | raw full names for the decodes |

Sweeps (`tests/sweep.sh --jobs 3`, same-length workdirs): `/tmp/r11u160_swP` (pristine), `/tmp/r11u160_swL` (final
law). Every `cmds.txt` names its binary: 3273 of 3273 `slang:` lines read `/tmp/r11u160_bin/pris.bin` in the
pristine sweep and `/tmp/r11u160_bin/law.bin` in the law sweep; the downstream stage ran with the same exported
binary (its slang databases differ between the sweeps exactly on the moved tests).

## 2. Laws (each behind its own switch; `R11U160_OFF=1` drops every law of the pass)

| law | switch(es) | site | statement (decode) |
|---|---|---|---|
| § ppMacroBodyLines160 | `R11U160_PPINACTIVE_OFF`, `R11U160_PPARGNL_OFF`, `R11U160_PPBUILTIN_OFF`, `R11U160_PPSTRINGIFY_OFF`, `R11U160_PPPASTE_OFF`, `R11U160_PPNESTCOL_OFF`, `R11U160_PPPUSHLINE_OFF` | UhdmExporter.cpp: `buildMacroExpansions` (the data), `locLineCol` / `ppBodyLineCol160` / `macroInvLineCol` / `ppPushLine160Adjust` (the positions) | the ibex macro-line set (map N0017 + N0026 + N0027 + N0029, pass-155 residue "the ibex family"): SURELOG'S OUTPUT LINE AND COLUMN OF A TOKEN IN A MULTI-LINE MACRO BODY (SV3_1aPpTreeShapeListener.cpp enterMacroInstanceWithArgs/NoArgs, PreprocessFile::evaluateMacro). An invocation PUSHes a line record mapping its output line to the `define line S; the body with every formal replaced by the TRIMMED actual is preprocessed as its own text, where `addLineFiller` is a no-op (`if (m_pp->isMacroBody()) return;`), so an inactive `ifdef branch leaves no newline behind, the newline ending the directive line included (INACTIVE); a nested call POPs a record mapping the output line where it ends to the definition line of its closing parenthesis plus the newlines the enclosing actuals added (the reset, INACTIVE); a multi-line actual adds its newlines and restarts the column at its last line (ARGNL); `__FILE__`/`__LINE__` expand in place with no record: their literal sits at the backtick name and shifts the later columns (BUILTIN; slang opens an argument-kind buffer for the literal and a body-kind buffer whose "body" is the name itself, which pasted the rest of the line); a one-line body that is exactly `` `"<formal>`" `` is the trimmed actual in plain quotes (STRINGIFY; slang's literal carries the call's leading blanks); a token pasted with ``` `` ``` replaces its written span by the pasted text (PASTE); a one-line call inside a multi-line body sits after the earlier replacements of its body line (NESTCOL); the text BEFORE a top-level call of a multi-line body on its line reads the `define line (PUSHLINE, same-file definitions only). ibex_branch_predict `$error` 29:3-33:32 (def 32:3), `__FILE__` 29:60-29:155, `__LINE__` 29:157, the name 33:10-33:31; ibex_decoder's multi-line `__prop`: property 78:42-79:33, `else begin` 80:10-82:8. Grid MM |
| § objMacroParenArgsTrimmed160 | `R11U160_OBJMACROPAREN_OFF` | UhdmExporter.cpp `buildMacroExpansions`, the top-level shift loop | pass-154 sister face S3 (MacroArgMismatch). Surelog's pp grammar reads `` `NAME Spaces* ( args ) `` as MacroInstanceWithArgs whatever the definition (grammar/SV3_1aPpParser.g4 macro_instance), and evaluateMacro of a macro WITHOUT formals re-emits the body, then `(` + the first actual TRIMMED + `)`: the blanks between the name and `(`, after `(` and before `)` leave the output line (`d <= \`D (~d);` -> golden `~d` 5:13, ours 5:14). Three entries on the line's shift table; only a top-level call closing on its line with no top-level comma, of a definition with no formals. Grid MA |
| § tpCloneWholeLhsBare160 | `R11U160_TPWHOLELHS_OFF` | TypeEmit.cpp makeTypespec, the § tpOvrTypedefStructSpan152 block | map N0014 (gen_scope_typaram). The module-typedef rule "a struct whose variable is assigned WHOLE is netlist-recompiled: BARE member refs" (TypeEmit emitTypedefs) holds for the instance's clone of an overriding typedef: a continuous assignment of the instance body (generate blocks included) writing a T-typed signal WHOLE (`assign d_o = d_i;`, `= '0`, a body `T q; assign q = ...`) names every member reference of the clone from the typedef alone (`pair_t.x`, ours `work@top.u.T.pair_t.x`); a whole READ, a member write or a procedural write keeps the type-parameter names. Grid GT |
| § defNetTypeParamPackedVec160 | `R11U160_TPPACKEDVEC_OFF` | ModuleEmit.cpp materializeDefNetTs, the § defNetTypeParamPackedDim144 gate | map N0090 + N0533 (packed_array_reset_loop): the VECTOR half of § defNetTypeParamPackedDim144. A type parameter whose default is a four- or two-state vector or scalar answers its name with its one default object, so `addr_t [N-1:0] q;` binds it and writeNets moves its end to the written dimension (golden 9:37-17:17 with the default's own range; ours an unranged logic_typespec at the declaration). Pass 144's hold-back (its grid tq d3, the `'0` sized from the bound typespec) is NOT_EQUAL before and after. Grid TV |
| § bodyTypeParamDefaultBound160 | `R11U160_BODYTPDEF_OFF` | ModuleEmit.cpp materializeDefNetTs, § defNetTypeParamDefault137's lookup | map N0083 + N0740 (packed_array_struct; pass-144 S3 / pass-147 residue). A BODY `localparam type my_t = struct packed {...};` has no typeParamDefaultTs entry (ParamEmit records only the parameter-port-list defaults), so the definition net built its own typespec; the definition's own type_parameter already holds the one object: read it there (golden 10:28-17:15, the end moved to the first packed dimension). Grid BT |
| § tpUseBindsDefDefault160 | `R11U160_TPUSEDEF_OFF` (definition default), `R11U160_TPUSEUNIT_OFF` (the $unit half) | UhdmExporter.cpp, a post-pass before § instTypeParamSharesDef120 | map N0090 / N0044 (packed_array_reset_loop, packed_struct_array_fifo). The same producer as § instTypeParamSharesDef120: an elaborated declaration typed by a type parameter the instantiation does NOT override by name compiles against the definition's parameter list and binds the definition's default object (with the end writeNets moved onto it). Per elaborated module instance, a variable or net of the instance (packed-array elements and generate scopes included, child instances not) reading the instance copy is re-pointed at the definition's object when UHDM's own Compare (the judge's) reads the two equal, for logic/struct/union typespecs (a packed-array default keeps the copy, § tpPackedArrayTsVar108's grid f5). The $unit half: a copy of a file-level struct/union typedef takes the typedef's span and member names (golden `d_t` 1:9-24:24, `d_t.op`; ours `struct packed` keyword span, `op`), the copy kept (golden's has no instance, which the judge reads). Grids TV, TP, BT |
| § implNetBareParamElab160 | `R11U160_IMPLBAREPARAM_OFF` | ModuleEmit.cpp emitContAssigns, the implicit-net share block | pass-154 sister face S1 (ComplexParamOverload, map N0739). A BARE value parameter read onto an IMPLICIT net (`assign o = PadTypeInGeneric;`) re-elaborates: a fresh cont_assign whose Lhs ref_obj is named by the instance and bound to the definition net, whose Rhs IS the elaborated param_assign's value object (re-parented at the cont_assign, listed once); ours shared the definition cont_assign. Only when that value is a constant. Grid CP (c03, a declared net, is the control) |
| § uncaughtExitsReject160 | `R11U160_CATCH_OFF` | uhdm_main.cpp `main` (the old body is `realMain`) | pass-154 sister face S7: an exception escaping the export (slang's `Compilation::parseName` throws inside `Scope::lookupName` on an escaped identifier holding `#`, from ModuleEmit.cpp mintUnitEnumNets) aborted with rc 134; caught, it prints the message and exits 3 (a clean SLANG_REJECT; no database is written, the serializer saves last). Surelog fails that source too (no golden). Case S7/s01 |

## 3. Targeted rows (fresh law-sweep csv rows, `name,mode,status,detail,blocked_by,strict`)

**30 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions** (loudly; results/ untouched). Surelog 6
(default CMP_EQUAL 425 -> 428, testflags 423 -> 426), uhdm2rtlil 24 (751 -> 763 per mode). Each fresh row below is
`<name>,<mode>,CMP_EQUAL,,,equal` in both modes (`/tmp/r11u160_swL/{surelog,uhdm2rtlil}.csv`, copied into
`evidence/sweeps/*_compare.txt`):

| test (both modes) | corpus | before | after | law(s) (per-switch byte attribution, `evidence/sweeps/corpus_attribution.txt`) |
|---|---|---|---|---|
| MacroArgMismatch | surelog | differ:endcol(8) | `MacroArgMismatch,default,CMP_EQUAL,,,equal` | objMacroParenArgsTrimmed160 |
| ComplexParamOverload | surelog | differ:name(2) | `ComplexParamOverload,default,CMP_EQUAL,,,equal` | implNetBareParamElab160 |
| BlackConst | surelog | differ:line(29) / line(19) | `BlackConst,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (NESTCOL, PUSHLINE) |
| ibex_branch_predict | uhdm2rtlil | differ:line(12) | `ibex_branch_predict,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (INACTIVE, BUILTIN, STRINGIFY) |
| ibex_csr | uhdm2rtlil | differ:line(12) | `ibex_csr,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (INACTIVE, BUILTIN, STRINGIFY) |
| ibex_fetch_fifo | uhdm2rtlil | differ:line(24) | `ibex_fetch_fifo,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (INACTIVE, BUILTIN, STRINGIFY) |
| ibex_wb_stage | uhdm2rtlil | differ:line(24) | `ibex_wb_stage,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (+ PASTE) |
| ibex_decoder | uhdm2rtlil | differ:endline(18) | `ibex_decoder,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (+ ARGNL) |
| ibex_multdiv_slow | uhdm2rtlil | differ:endline(18) | `ibex_multdiv_slow,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (+ ARGNL) |
| ibex_compressed_decoder | uhdm2rtlil | differ:line(132) | `ibex_compressed_decoder,default,CMP_EQUAL,,,equal` | ppMacroBodyLines160 (+ ARGNL) |
| gen_scope_typaram | uhdm2rtlil | differ:fullname(6) | `gen_scope_typaram,default,CMP_EQUAL,,,equal` | tpCloneWholeLhsBare160 |
| gen_scope_numports | uhdm2rtlil | differ:fullname(4) | `gen_scope_numports,default,CMP_EQUAL,,,equal` | tpUseBindsDefDefault160 (TPUSEDEF) |
| packed_array_reset_loop | uhdm2rtlil | differ:endline(3) | `packed_array_reset_loop,default,CMP_EQUAL,,,equal` | defNetTypeParamPackedVec160 + tpUseBindsDefDefault160 |
| packed_array_struct | uhdm2rtlil | differ:endline(2) | `packed_array_struct,default,CMP_EQUAL,,,equal` | bodyTypeParamDefaultBound160 + tpUseBindsDefDefault160 |
| packed_struct_array_fifo | uhdm2rtlil | differ:endline(6) | `packed_struct_array_fifo,default,CMP_EQUAL,,,equal` | tpUseBindsDefDefault160 (TPUSEUNIT) |

**Downstream rows of the converted uhdm2rtlil tests (fresh, all IDENTICAL, `differs` empty):**
`gen_scope_numports,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `gen_scope_typaram,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`ibex_branch_predict,IDENTICAL,OK,OK,248,248,,` `ibex_compressed_decoder,IDENTICAL,OK,OK,1166,1166,,`
`ibex_csr,IDENTICAL,OK,OK,32,32,,` `ibex_decoder,IDENTICAL,OK,OK,327,327,,` `ibex_fetch_fifo,IDENTICAL,OK,OK,305,305,,`
`ibex_multdiv_slow,IDENTICAL,OK,OK,2323,2323,,` `ibex_wb_stage,IDENTICAL,OK,OK,101,101,,`
`packed_array_reset_loop,IDENTICAL,OK,OK,8,8,,` `packed_array_struct,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`packed_struct_array_fifo,IDENTICAL,OK,OK,25,25,,`.

**Improved, still STRICT_NOTEQUAL** (compare_results CHANGE lines):
* ApbSlave d/t `line(29) -> line(26)` (ppMacroBodyLines160 ARGNL + BUILTIN; order-blind lines not in golden 358 -> 328).
* ibex_load_store_unit d/t `endline(240) -> endline(142)` (ppMacroBodyLines160).
* ibex_icache d/t `line(157) -> fullname(49)` and ibex_multdiv_fast d/t `line(86) -> endcol(26)`: the macro-line
  records clear and the first record left is one the pristine walk already listed (pristine `--max 3000` holds the
  law's first record: icache `ref_typespec work@ibex_icache.fill_addr_q.fill_addr_q`, multdiv_fast `$signed`
  158:24-158:59; `evidence/sweeps`).
* arb_idx_cast d/t `endline(3) -> endcol(17)` (defNetTypeParamPackedVec160 + TPUSEDEF): the pristine walk DIVERGED at
  #128 (the vector type-parameter face); the law clears it and the walk reaches later pre-existing faces (#209, the
  cast constant's end).


## 4. Gates (`tests/sweep.sh --jobs 3`, `evidence/sweeps/`)

| gate | pristine (`/tmp/r11u160_swP`) | law (`/tmp/r11u160_swL`, `law.bin`) |
|---|---|---|
| (1) build | `pris.bin` = main tree md5 `2aa91861...` | `law.bin` `7caa7608...` |
| (2) probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2514, STRICT_NOTEQUAL 1573) | regressions 0, conversions 18, changes 25 (EQUAL 2532, STRICT_NOTEQUAL 1555) |
| (3) surelog vs golden_surelog.csv | 0 / 0 / 0 | regressions 0, conversions 6, changes 2 |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | regressions 0, conversions 24, changes 8 |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0 | the same; `downstream.csv` identical to pristine's row by row (pass 120's eight rows included; `evidence/sweeps/downstream_pristine_vs_law.diff` (empty)) |

The law sweep exits 1 for one reason only, `law index STALE` (the edited `src/` before `scripts/law_index.py`; the
patch carries the regenerated `tests/LAWS.md`, `tests/LAWS.csv`, `tests/CASES.csv`). (5) uhdm-cmp reads 0 lines on
every touched row and case: every converted row is CMP_EQUAL, every changed row stays STRICT_NOTEQUAL (judge-equal),
and the probe stage has no NOT_EQUAL case.

* **(6) Byte movers, corpora** (`tools/probe/r11v75repro/byteverify.sh` on the fenced mirrors, SELFCHECK=1, path
  sets identical, 951/952 and 1607/1608 flagged by the self-check; `evidence/sweeps/byteverify_*.txt`): surelog 15,
  uhdm2rtlil 48. Attribution (`drivers/attrib.sh`, `evidence/sweeps/corpus_attribution.txt`): every deterministic
  mover (58) returns to the pristine bytes under `R11U160_OFF=1`, and the switches that change its bytes are the
  laws named in section 3, plus these byte-only movers whose csv row is unchanged (all CMP_EQUAL, strict equal
  before and after): **bits_of_type_param, param_name_collision_typeparam, param_nested_struct_field_width,
  port_chained_type_param, top_module_type_param, TypeParameterAsPortTypeWithLogicAnonymous,
  type_param_override_elem_sel, type_param_packed_dim** d/t (TPUSEDEF alone: the elaborated use re-pointed at the
  definition's Compare-equal object, a sharing change the canonical walk does not see). The UVM order-coin family
  (MiniAmiq d/t, SeqDriver d/t, SimpleUVM t; Scoreboard d) is nondeterministic per invocation, so it is attributed
  order-blind (`drivers/offorderblind.sh`, `evidence/sweeps/uvm_off_orderblind.txt`): under `R11U160_OFF=1` each
  differs from its pristine database only by the known 4-line `UINT`/`vpiDecompile` coin (plus the dump header's
  path). The law moves these rows a long way TOWARD golden (order-blind dump lines not in golden, pristine -> law,
  `evidence/sweeps/uvm_orderblind_distance.txt`): MiniAmiq 90788 -> 63758, SeqDriver 88723 -> 62501, SimpleUVM 42202
  -> 26835, Scoreboard 41715 -> 26390 (the macro bodies of the UVM library: `__FILE__`/`__LINE__`, nested one-line
  calls, `ifdef inside `uvm_*` bodies); their csv rows are unchanged (the first differing record is elsewhere). The
  lines newly absent from golden are pre-existing structural listings now carrying corrected spans (MiniAmiq's
  `get_child` begin 130:4-134:7 is golden's span; golden lists it 12 times, ours 16).
* **Probe byte movers** (`drivers/attrib_probe.sh`, `evidence/sweeps/probe_attribution.txt`): 89, every one returns to
  the pristine bytes under `R11U160_OFF=1`; contributing switches: TPUSEDEF 47, BODYTPDEF+TPUSEDEF 15, PPSTRINGIFY 7,
  TPPACKEDVEC 6, TPUSEUNIT 3, PPPUSHLINE 3, BODYTPDEF 3, TPWHOLELHS 2, TPPACKEDVEC+TPUSEDEF 2, PPARGNL 1. All 43
  verdict movers are among them. The CHANGE lines (`evidence/sweeps/probe_compare.txt`): every one lowers the count
  on its first field, or moves the first field because the pristine first records cleared, except two that grow on
  the same field — **r11u47repro/branches/g8 `fullname(3) -> fullname(10)` and r11v47repro/branches/v30 `fullname(8) ->
  fullname(18)`**: the pristine walks DIVERGED (g8 #21 `type`: golden struct_typespec, ours logic_typespec at the
  bare `it_t v`), BODYTPDEF clears the divergence and the first records are identical in both runs (g8 #6/#12
  `ref_typespec <in>x / <in>y`, v30 #9/#13/#17), the added count being the same member-name face on the listings the
  walk now reaches (residue 4 below). The r11u112 k-series `endline(5) -> fullname(N)` is the same unmasking.
* **Prediction** (`drivers/predict.py`, a fenced source-shape census per law over each test's own directory;
  `evidence/sweeps/prediction.txt`, `mover_prediction.txt`): it names every moving uhdm2rtlil test and surelog
  BlackConst, ComplexParamOverload, MacroArgMismatch and MiniAmiq by law, and misses ApbSlave, Scoreboard, SeqDriver
  and SimpleUVM (their macros live in the UVM library outside the test directory). **The census was written after
  the development sweeps had run, so it is not a blind prediction**: stated here as a gap against the brief's
  prediction step, as passes 152 and 155 stated theirs.
* **Canaries** (`evidence/sweeps/canaries.txt`): canaries.sh surelog ok=50 changed=2 (ApbSlave d/t, the attributed
  CHANGE), uhdm2rtlil ok=16 changed=0; ctcan2 surelog ok=56 changed=2 (BlackConst d/t, the conversion; prints FAIL
  because a supplementary canary moved) with EXPECT_UNKNOWN=1, uhdm2rtlil ok=2 changed=0 PASS with EXPECT_UNKNOWN=6.
* Development breaks found and fixed before the final sweep (each by fresh evidence, each gated): a paste-end remap
  that moved `unused_bit` in AllPackageSignal (slang lays the token after a paste at the pasted text's running
  offset; only an end still on the paste's own line is remapped); a stringify trim that broke bodies writing their
  own text inside the quotes (r11v11u8repro v4/v11/v13; STRINGIFY is now the one-formal body only); an actual-extent
  read that ran through a pasted token (v133_f_macro), past a defaulted formal (ibex `__clk = \`ASSERT_...`), and
  across an actual written in two places (int_types `TEST(typ signed, ...)`, DIVERGENT downstream in the
  intermediate build) — all three restored to pristine bytes in the final build.


## 5. Grid (`cases/`, 80 law cases, `drivers/gridall.sh`, `evidence/grid/gridall.txt`)

Goldens: `drivers/grid.sh` (pinned Surelog with check_probe's arguments, cached under `/tmp/r11u160_g`); ours with
`--single-unit --nobuiltin`. Each case's first line names its law. Columns of `gridall.txt`: pristine verdict, law
verdict, the bytes under `R11U160_OFF=1` and under the dir's own switches against pristine. **All 80 cases return
to the pristine bytes under `R11U160_OFF=1` and under their own switches; no case that pristine read STRICT_EQUAL
reads otherwise with the law (0 breaks).** Law grids: pristine STRICT_EQUAL 19 -> law 68.

| dir | law | cases | pristine EQUAL | law EQUAL | controls / stage-1 / residue |
|---|---|---|---|---|---|
| MM | ppMacroBodyLines160 | 15 | 2 | 15 | m05 (nested multi-line), m07 (`ifndef` active) equal both ways |
| MA | objMacroParenArgsTrimmed160 | 14 | 4 | 11 | m02 m05 (no blank / no paren) m13 (function-like macro) m14 equal both ways; m09 m11 SURELOG_FAIL; m04 (`#\`D (x)`) moves to the delay's own col face |
| GT | tpCloneWholeLhsBare160 | 18 | 10 | 18 | g04 (package typedef), g06 g09 g15 g16 g17 (read, procedural, member writes) equal both ways |
| TV | defNetTypeParamPackedVec160 (+ tpUseBindsDefDefault160) | 9 | 0 | 6 | v07 (enum default) unmoved; v08 (2-state default) walks further (endline -> line); v09 (generate) stage-1 both |
| BT | bodyTypeParamDefaultBound160 (+ tpUseBindsDefDefault160) | 5 | 0 | 2 | b03 b04 (bare `my_t s` written procedurally: member names through the last net, residue); b05 stage-1 both |
| TP | tpUseBindsDefDefault160 ($unit half) | 9 | 2 | 7 | t03 t04 equal both ways; t07 t09 (overrides of a $unit typedef) stage-1 both |
| CP | implNetBareParamElab160 | 9 | 1 | 9 | c03 (declared net) equal both ways |
| S7 | uncaughtExitsReject160 | 1 | - | - | rc 134 -> rc 3 (SURELOG_FAIL: no golden) |

## 6. Decodes, sister-ground faces and residues

**LogicTypespec d/t (N0422 + N0484 + N1149): a Surelog-defect candidate, not followed.** A fresh case measured on both
downstream lanes (`evidence/residue/LT`): the net `my_package::t2 [1:0][7:0] x` is `wire width 32` on both lanes
(l01 IDENTICAL), but `assign w = $bits(x);` reads 2 on the Surelog lane and 32 on ours (l02 DIVERGENT, nohier il
synth differ): golden binds the declaration straight to the package typedef and DROPS the written packed dimensions,
and that width reaches the plugin through `$bits`. Ours keeps the LRM width.

**GenerateUnnamed d/t (N0969, fullname 9): decoded in part, not landed** (`evidence/residue/GU`). The gate terminal
references are named through Surelog's UNFLATTENED generate path while the gen_scope listing is flat: an else-if
level adds a `genblk1` (`if (p == 1) ; else if (p == 2) begin ... end` -> `work@top.genblk1.genblk1.a`, u01; slang and
ours `genblk1`), a nested unnamed if inside an unnamed block adds its own level (u06 `genblk1.genblk1`), a named block
closes the chain it ends (u05 `nm` alone, equal today). Not landed: the index Surelog gives a later unnamed construct
in the same block is not the LRM's (GenerateUnnamed g4 `genblk1.genblk1.genblk1` where the LRM numbering says
`genblk2`; DesignElaboration.cpp genBlkIndex). Site: ModuleEmit.cpp emitGates (`refScope` of the elaborated view).

**Sister-ground faces (the fix sits in a file this pass does not own):**
* S2, YosysMarlann d/t (24 objects) and the five Earlgrey_0_1 param_assign endcol records at
  alert_handler_reg_pkg.sv 529-533 (`= 8'h 0`): the space between a base and its digits leaves Surelog's output
  line, so every later column moves left (fresh repros `evidence/residue/NL`: the literal itself is right, the objects
  after it on the line are one column right). The base->value run is excluded from UhdmExporter's
  § ppIntegralNumberFold119 because it is subtracted "site by site" by `basedLiteralSpaceCount` (EmitHelpers.h) at
  ExprEmit.cpp (the IntegerLiteral, the cast, three more), StmtEmit.cpp and ModuleEmit.cpp; folding it in the column
  model double-counts at those sites. The fix: fold the run in `ppFold119Line` and drop the site subtractions
  together (ExprEmit/StmtEmit/ParamEmit side).
* UnionCast d/t value(24): the based literal's value text `UINT:00` (golden keeps the written digits) - the
  literal's VpiValue in ExprEmit.cpp emitExpr IntegerLiteral; its file(2) face (N0430, buildUnionTs) was not reached.
* SimpleConstraint d/t endcol(2): the method-call hier_path `frame.randomize()` spans the parentheses (ExprEmit).
* const_cast_signext d/t line(5): ParamEmit.cpp makeParamTs copies (pass-155 residue R-SP); the absent constant under
  its cont_assign follows only after them.
* ibex_multdiv_fast d/t endcol(26) (after this pass): `$signed({...})` sys_func_call spans only the name in golden
  (158:24-158:31), ours the whole call: ExprEmit.cpp emitExpr (system call span).

**Residues on this ground, ranked:**
1. **Earlgrey_0_1 d/t line(1730)** first ten records: five `include_file_info` lines (prim_generic_ram_1p.sv 256 vs
   ours 57, prim_generic_rom.sv, prim_ram_*_adv.sv: an `include after a macro-only include, the map's N0064 family,
   UhdmExporter.cpp emitIncludeFileInfos) and the five S2 param_assign endcols above.
2. **ClassTypeParam d/t** (17 objects): a typedef of a class specialization: the specialization typespec's end moved to
   its last user (20:9-24:36), the class formals and their param_assigns unlocated in golden, the actual class
   typespec spanning `#(...)`; several faces, not attempted.
3. **ibex_icache fullname(49), ibex_load_store_unit endline(142), ibex_tracer fullname(579), ibex_register_file_ff
   fullname(31), ibex_pmp file(52)**: their macro-line faces are cleared, what is left is other families (the
   dv_fcov macro users' names, prim_* instance names).
4. **The anonymous `localparam type` struct written bare and procedurally** (BT b03 b04; probe r11u112 k-series,
   r11u47 g8, r11v47 v30 now walk further): golden names its members through the last user net
   (`work@top.s.a`, `work@top.c.arr.arr.a`); ours bare.
5. **The vector half on a 2-state or enum default** (TV v08 v07): the elaborated flat var keeps the instance copy.
6. **STRINGIFY with its own text inside the quotes** (`` `"  __a  __b`" ``, r11v11u8repro v4 v11 v13): Surelog's
   literal is the body text with the trimmed actuals; slang's carries extra leading blanks; declined (pristine bytes).
7. HierPathTypespec t (N1174), UnionCast's union file (N0430), the UVM/Earlgrey-only clusters (N0064, N0067/N0068,
   N0069/N0072, N0051, N0093, N0070), pass-152 improved-not-converted rows: not reached.


## 7. Files

* `cases/<dir>/<case>/dut.sv`: the 80 law cases (first line `// § <law>`); `evidence/residue/<dir>/<case>.sv.txt`:
  the decode-only repros (GU GenerateUnnamed, NL the spaced based literal, LT LogicTypespec's downstream measure).
* `drivers/grid.sh` (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), `drivers/gridall.sh` (every case, four
  states), `drivers/predict.py` (the fenced source-shape census), `drivers/attrib.sh` and `drivers/attrib_probe.sh`
  (per-switch byte attribution), `drivers/dumpdist.sh` (order-blind dump distance to golden), `drivers/bvmirror.sh`
  (the fenced mirror for byteverify).
* `evidence/grid/gridall.txt`, `evidence/sweeps/` (sweep logs, compare outputs, byteverify, attribution, prediction,
  the UVM order-blind distances, the downstream csv diff against pristine: empty).
