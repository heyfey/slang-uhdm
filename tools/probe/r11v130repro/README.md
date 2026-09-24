# r11v130 — adversarial verification of r11u130 (the module/type ground on the strict axis)

Verifier of `/tmp/r11u130.patch` (md5 `ced6ad54951061228e54cc32d5978b53`) at base `634b3a19`
(branch matrix-1.87). Fresh worktrees `/tmp/wt_v11u130` (patch) and `/tmp/wt_v11u130pris` (base),
both built here with the system-deps config at `-j 2`.

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of r11u130 reproduces bit for bit. Two of its ten
laws move legal SystemVerilog from strict-equal to strict-differ (12 fresh cells, none in either corpus
or the probe set): a `var` declaration's enum typespec, and an included file whose directive lines are
indented with a TAB. Both are fixed here by two gated refinements; with them the pass leaves every
corpus row, probe case, downstream row and grid cell measured here equal to or closer to golden.

| binary | md5 | what |
|---|---|---|
| pristine | `7c5a7e01c46167100bd7787ae1798f2c` | base; equal to the main tree's `build/slang-uhdm` at the base |
| law | `6a3e91ed5fc42521d23d417bf12da912` | r11u130 as shipped (the implementer's law binary, reproduced byte for byte) |
| fix1 | `0d6b38e35e0639c7dc427ba5a3e49587` | r11u130 + this verification's two refinements (the verified patch; the final tree rebuilds to the same md5) |
| `uhdm-strictcmp` | `70ddf0ad777735ff05ec8d89aee66627` | built from the base tree |

All binaries were frozen (`chmod 555` copies) before they measured anything; every sweep exported
`SLANG_UHDM` and `STRICT_CMP` to the frozen copies, and every corpus `cmds.txt` names the right one
(3273 of 3273 slang lines per sweep; the other 50 rows have no slang run). The downstream sweep does not
record the binary, so a positive control stands in: the fix1 command line on `simple_enum` reproduces the
sweep's database byte for byte, and the pristine one does not.

## 1. The two defects, and the fixes

### § defNetVarNoSlot130v (refines § defNetEndOnlyLoc130; switch `R11V130_DEFNETVAR_OFF`)

§ defNetEndOnlyLoc130 locates a definition net's unlocated typespec at Surelog's packed slot. A
declaration written with `var` fills no such slot: `CompileHelper::compileDataDeclaration` reaches the
data type through the `Var_type` node's sibling, and golden leaves the typespec unlocated.

| cell (grid/var) | shape | pristine | r11u130 | fix1 |
|---|---|---|---|---|
| a02 | `var enum {A, B, C} x;` | equal | `file(2)` (`dut.sv 0:0:3:17` against golden's nothing) | equal |
| k01 | `var enum logic [1:0] {A, B} x;` | equal | `file(2)` | equal |
| k05 | the same in an interface | equal | `file(2)` | equal |
| k06 | the same in a sub-module | equal | `file(2)` | equal |
| k09 | `var enum {..} x = B;` (the initializer case keeps its end and gains the file) | `file(2)` | equal | equal |
| k12 | `var pkg::S [1:0] x;`: golden's packed_array typespec is unlocated (uhdm-dump), judge-unequal row | — | located | unlocated again |

The fix: the tail block of `materializeDefNetTs` (ModuleEmit.cpp, § defNetVarNoSlot130v) skips a
declaration with a `var` keyword (`hasVarKeywordDecl`). The initializer case is unchanged (k09).

### § includeLeadTabIsText130v (refines § includeNoTextSplicesNothing130; switch `R11V130_INCTAB_OFF`)

§ includeNoTextSplicesNothing130 treats a file made only of `define/`undef/`ifdef-family lines and
blank lines as splicing nothing. Golden counts a TAB in a line's LEADING whitespace as text: it keeps
every line of such a file, while leading spaces are not text. This was found by i06, where
`<2 spaces>` then a `define, then `<TAB>` then a `define, spliced every line in golden and none in ours.

| cell (grid/tab) | defs.svh | golden flat line of the next include | pristine | r11u130 | fix1 |
|---|---|---|---|---|---|
| v8 | 2 lines, each indented with 2 spaces | 4 (splices 0) | 6 | 4 | 4 |
| v10 | second line indented with 2 spaces | 4 | 6 | 4 | 4 |
| v9 | second line indented with a TAB | 6 (splices all) | 6 | 4 | 6 |
| v11 | one line, indented with a TAB | 5 (splices all) | 5 | 4 | 5 |
| v2 | first line spaces, second line a TAB | 6 | 6 | 4 | 6 |
| v14 | a TAB-only line between the defines | 7 | 7 | 4 | 7 |
| v19 | a TAB before a `define inside `ifndef | 7 | 7 | 4 | 7 |
| v21 | spaces, then a TAB, before a `define | 6 | 6 | 4 | 6 |
| v22 | the file ends with a TAB-only line | 7 | 7 | 4 | 7 |
| v15, v17 | a TAB between the words of a `define, or at the end of the line | 4 | 6 | 4 | 4 |
| v20 | a TAB-indented CONTINUATION line of a macro body | 4 | 7 | 4 | 4 (exempt) |
| i06 | spaces, then a TAB, then 2 blank lines | 8 | 8 | 4 | 8 |

The fix: in `emitIncludeFileInfos` (UhdmExporter.cpp, § includeLeadTabIsText130v), a line that is not
a continuation and has a TAB in its leading whitespace makes the file text. The grammar gives no clean
decode: `Spaces: (WS | TAB)+` in `SV3_1aPpLexer.g4` treats both alike, so the rule is the measured one.

Neither refinement moves any corpus database. fix1 against the law sweep: 0 of 1608 uhdm2rtlil movers,
and 3 of 960 surelog movers, all the UVM order coin (see section 4). No probe case moves on strict.
Every one of the 12 defect cells is downstream-IDENTICAL under both binaries: they differ on the strict
axis only.

## 2. Headline numbers of r11u130, reproduced

| claim | measured here |
|---|---|
| law binary md5 `6a3e91ed5fc4` | same (fresh worktree, same config) |
| probe EQUAL 4087/4087, strict-equal 1890 -> 1902 | same (pristine and law sweeps; fix1: 4087, 1902) |
| surelog 480/3 + 474/3, uhdm2rtlil 803/1/67 both modes, regressions=0 conversions=0 changes=0 | same for law and for fix1 |
| strict-equal surelog 593 -> 600 of 954, uhdm2rtlil 1222 -> 1242 of 1606 | same (fix1 too) |
| 46 changed row-modes: 27 turned, 8 fewer, 11 moved-fewer, 0 worse | same (evidence/census_P_L.txt; census_P_F.txt is identical row for row). I also compared the per-field counts of every changed row: no field count grows on any of the 19 non-turned rows |
| probe: 12 turned, 13 fewer or moved-fewer, 0 worse | same (evidence/probe_census_P_L.txt: every probe case strict-judged on both sweeps (the file keeps the changed cases; 4062 are unchanged in verdict and per-field counts): 12 turned, 13 with fewer objects and no growing field, 0 worse) |
| grid 117 cells, strict-equal 25 -> 93, no per-field growth, NOT_EQUAL cells keep their uhdm-cmp line count | same (evidence/grid_impl_PLF.txt); fix1 = law on all 117 |
| `R11U130_OFF` restores pristine bytes on every grid cell | same on all 117, and on all 115 cells of this verification (evidence/switches_*.txt) |
| byte movers 33 + 32; 60 non-UVM movers identical to evidence/byte_movers.txt | 32 + 32 here, with the same 60 non-UVM movers. The UVM coins differ from draw to draw: here MiniAmiq (both modes), SeqDriver/default and Scoreboard/default; the implementer's draw had SeqDriver/testflags and SimpleUVM/testflags where this one has Scoreboard/default |
| `R11U130_OFF` gives pristine bytes back on the 60 non-UVM movers | same, 60 of 60 (evidence/attribution_all_off.txt) |
| per law: DEFNETLOC 20, WILDSPAN 16, PVPARAM 12, NETSIGN 6, CLSARGNET 2, SUSIGN 2 | Every mover is owned by a law (evidence/attribution_single_switch.txt). The correct counts are DEFNETLOC **22** and WILDSPAN **18**: Earlgrey_0_1 has both laws, in both modes, and the implementer's own name lists add up to 22 and 18. PVPARAM 12, NETSIGN 6, CLSARGNET 2, SUSIGN 2 are exact |
| downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, verdict and `differs` equal to results/downstream_uhdm2rtlil.csv on every row | same for fix1 (evidence/downstream_fix1.csv; the four slang-fenced rows are removed from the committed file, as in the implementer's evidence) |
| canaries surelog ok=48 changed=4, uhdm2rtlil ok=16 changed=0; ctcan2 ok=58 and ok=2 PASS | same for fix1 (evidence/canaries_fix1.txt) |

Cluster examples at the base, and after fix1 (`build/uhdm-strictcmp`, quoted from the sweep rows):

* K0053 EnumArray: golden `packed_array_typespec dut.sv 0:0:8:46`, ours had no file -> strict-equal.
* K0028/K0058 simple_enum: golden `enum_typespec dut.sv 0:0:4:14`, ours unlocated -> equal. The
  corpus example TypeParameterAsPortTypeWithEnumOfParametrizedWidth `state_e` (golden 12:3-14:13, ours
  no file) is unchanged. It is residue R1, a sister-ground site.
* K0048 SignedWire: `logic_typespec 2:1-2:12` against ours `2:1-2:19` -> equal.
* K0067 WildConn: `ref_obj a 14:5-14:6` against ours `14:5-14:7` -> equal.
* K0085 InterfType: `parameter PACKET_CONFIG work@tnoc_types.PACKET_CONFIG` against ours
  `work@dut.tnoc.types.PACKET_CONFIG` -> equal.
* K0034 Disable `logic_net loop`: golden has no file, ours `dut.sv`. Unchanged; the mint is on the
  sister's ground (StmtEmit.cpp emitStmt).
* K0070 TypeParam: at the base the head is `type` (`logic_typespec 17:38-43` against ours
  `int_typespec 18:5-8`, walk diverged). Unchanged; this is residue R3.
* K0049/K0057 TypedefWithParameter: `logic_typespec my_pkg::word` golden 3:12-7:26 against ours
  3:12-3:25. Unchanged; this is residue R5.
* K0024 RangeSelect: `struct_typespec tl_h2d_t` golden 2:12-6:17 against ours 2:12-4:5. Unchanged;
  this is use-site residue R2.

## 3. Breaking the laws: grids of this verification (115 cells, every case names its law in its first line)

Scored per cell against golden with uhdm-cmp and uhdm-strictcmp, using the pristine, law and fix1
binaries (drivers/case.sh, the probe arguments; evidence/grid_v130_PLF.txt). Every cell's rc is 0.

| group | laws broken against | cells | judge-equal | strict-equal pristine / law / fix1 | worse than pristine: law / fix1 |
|---|---|---|---|---|---|
| grid/var | § defNetVarNoSlot130v, § defNetEndOnlyLoc130 (initializer case k04/k09/k10, control k13), § suSigningNotInSpan130 (k07), § netSigningTsSpan130 (k08) | 14 | 7 | 4 / 2 / 6 | 4 (a02 k01 k05 k06) / 0 |
| grid/tab | § includeLeadTabIsText130v, § includeNoTextSplicesNothing130 (spaces, trailing blanks, CRLF, continuation, nested and twice-included define files, macro use in a define, inside a module) | 31 | 31 | 10 / 21 / 29 | 8 (i06 v2 v9 v11 v14 v19 v21 v22) / 0 |
| grid/adv | every other law: anonymous enums in gen blocks, programs, packages, `$unit`, with attributes, `static`, `const`; named packed arrays with two declarators and two dimensions, `wire`-typed, type-parameter typed; non-ANSI ports; `wire signed` with drive strength, delay, `vectored`, `wand`/`trireg`, over several lines, with parameter widths, two initialized declarators; struct/union `packed signed` typedef'd, nested, as a port, in a function, in a package, as a parameter, in a gen block; interface inline unions and parameterized structs; `.*` with interface ports, struct ports, parameterized and arrayed instances, mixed with named connections, nested under generate; port views of arrayed, derived-parameter, generate-scoped, same-named, modport-at-connection, two-instance and interface-in-interface ports; class specialization arguments in interfaces and gen blocks; empty redefinitions after a bodied define, around `undef, in `ifdef, defined in an include, with trailing comments, CRLF, spaces, TAB, followed by one-line and multi-line macro uses, includes, `ifdef blocks, include guards; genvar loops in nested includes, sub-modules and macro arguments | 70 | 42 | 5 / 35 / 35 | 0 / 0 |

No cell's per-field counts grow from pristine to fix1 (drivers/growth.py over all 115 + 117 cells).
Every NOT_EQUAL cell keeps its uhdm-cmp line count under all three binaries. Downstream (the harness's
`one()` on each case, fix1): 94 IDENTICAL, 14 EQUIVALENT, 5 DIVERGENT, 2 STATUS_DIFF. Each of the 21
non-IDENTICAL cells reads the same verdict and `differs` with the pristine binary; they are uhdm-cmp
NOT_EQUAL shapes or residue cells (m01, m03, h09). The 11 cells of the last batch (n01-n11) read
IDENTICAL with both binaries (evidence/downstream_cases_*.txt).

Switches (evidence/switches_v130_grid.txt, switches_impl_grid.txt; drivers/sw.sh): on all 232 cells,
`R11U130_OFF=1` on fix1 gives the pristine bytes, and `R11V130_DEFNETVAR_OFF=1 R11V130_INCTAB_OFF=1` on
fix1 gives the law binary's bytes. Every cell where fix1 differs from pristine changes under at least
one single-law switch. Each refinement's switch moves exactly its own cells: DEFNETVAR a02 k01 k02 k05
k06 k12; INCTAB i06 v2 v9 v11 v14 v19 v21 v22.

## 4. Gates (fix1, run from /tmp/wt_v11u130 with SLANG_UHDM exported to the frozen copy)

1. build: pristine `7c5a7e01c461`, fix1 `0d6b38e35e06` (the final tree rebuilds to the same md5).
2. probe: `EQUAL=4087 (of 4087)`; strict tally `equal=1902` (pristine 1890).
3. corpora: surelog `[default] CMP_EQUAL=480 CMP_NOTEQUAL=3 ... [testflags] CMP_EQUAL=474
   CMP_NOTEQUAL=3`, uhdm2rtlil `CMP_EQUAL=803 CMP_NOTEQUAL=1 SLANG_REJECT=67` in both modes;
   `regressions=0 conversions=0 changes=0` in both. The sweep's rc=1 is `law index STALE` only.
   The base tree reads stale too, because its tests/LAWS.md predates its own commit hash; the patch
   ships the regenerated file.
4. downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`.
   Verdict and `differs` equal the committed baseline on all 871 rows. The pass-120 rows and every
   turned uhdm2rtlil row are IDENTICAL; for example `simple_enum`, `EnumArray`, `static_cast_simple`,
   `svtypes_struct_simple`, `sva_basic02`, `iface_param_width_per_inst` and `iface_ff_genvar_partsel`
   all read IDENTICAL with an empty `differs`.
5. uhdm-cmp: no corpus row changes status (census: 0 status changes). Every byte mover is CMP_EQUAL in
   both sweeps, so it is at 0 lines.
6. byteverify (`SELFCHECK=1`, same-length workdirs `/tmp/v11u130_wd{P,L,F}`):
   * law vs pristine: PATH_SETS_IDENTICAL; SELFCHECK 959/960 and 1607/1608; MOVERS 32/960 + 32/1608.
   * fix1 vs law: MOVERS 3/960 + 0/1608. The three are MiniAmiq (both modes) and SeqDriver/default.
   * **UVM coin:** each of these is a 4-line `vpiDecompile`/`UINT` value flip. Three reruns of the
     PRISTINE binary on MiniAmiq/default gave three different values (765, 681, 1158) at that one
     object. Scoreboard/default (law vs pristine) is its 92-line order coin, with an order-blind
     sorted diff of 0.
   * **Prediction:** the two refinements were predicted to move no corpus database. No corpus row's
     definition nets are `var`-declared with an unlocated inline enum or scoped packed array, and no
     corpus include file is directives-only with TAB indentation, which is why the law sweep's movers
     already equal the implementer's list. Confirmed: 0 real movers.
7. canaries (fix1 vs pristine): surelog ok=48 changed=4 (YosysOldOpen and ClassTypeParam, the
   census's no-growth improvements), uhdm2rtlil ok=16 changed=0. `EXPECT_UNKNOWN=1 ctcan2.sh` on the
   committed surelog csv (LF-normalised) PASS ok=58; `EXPECT_UNKNOWN=6` uhdm2rtlil PASS ok=2.

## 5. Residues, ranked (measured here; the implementer's R1-R8 stand as written)

1. **`var` and port inline struct headers** (grid/var k07 `var struct packed signed`, grid/adv c04 a
   port `input struct packed signed {..} p`): golden spans the bare `struct` keyword (3:7-3:13). Ours
   ends at `packed` after § suSigningNotInSpan130 (3:7-3:20; it was 3:7-3:27 at the base). The cell
   moves toward golden, but the object count is unchanged. Site: TypeEmit.cpp makeTypespec (the
   § suSigningNotInSpan130 cases); the rule is the one § ifaceElabInlineSuKeyword130 applies to the
   elaborated interface.
2. **Indented empty redefinition** (grid/adv m01 TAB, m03 spaces): the dropped line's leading
   whitespace lands at the start of the next output line, so the next line's columns shift (40
   objects, col). The line half is right after § emptyRedefineObjLine130; this is its column twin.
3. **Multi-line macro INVOCATION as a resync point** (grid/adv h09 `ID(\n q)`): 61 -> 14 objects, but
   still one line off after the invocation. § emptyRedefineObjLine130 resyncs only on multi-line
   macro BODIES. This belongs to the same family as the implementer's R6.
4. **Define-only files golden splices nothing, where the law abstains** (grid/tab i02 a defines file
   that includes another defines file, i05 an `ifdef whose inactive branch holds code): golden 4, ours
   6 and 9, unchanged from pristine (the law abstains).
5. **Nested anonymous union inside a struct** (grid/adv c02): golden locates the inner
   `union_typespec` at the `union` keyword (5:19-5:24); ours has no location. Unchanged from pristine;
   site: TypeEmit.cpp makeTypespec (member typespec).
6. **Port-view leftovers** (grid/adv f02: a derived parameter's folded constant ends at 2:49 in golden,
   2:53 in ours, which is the implementer's R7 on the sister's ground; f04: a same-named module
   parameter `W` read through the port view is named `work@sub.b.d[W - 1:0].d.W` in golden and
   `work@sub.W` in ours).

## 6. Files

* `grid/var`, `grid/tab`, `grid/adv`: the 115 cases (each `dut.sv` names its law in its first line).
* `drivers/`: `case.sh` (one cell, any set of binaries), `growth.py` (per-field growth between two
  binaries), `sw.sh` (switch battery per cell), `census.py` (strict column row by row with per-field
  counts), `probecensus.py` (every probe case, both sweeps), `rowcmp.sh` (one sweep row's records),
  `offrow.sh` / `attr1.sh` / `testdir.py` (rerun one corpus row under a switch), `coin.sh`
  (order-blind dump diff), `ds_case.py` (downstream verdict of a case).
* `evidence/`: `grid_impl_PLF.txt`, `grid_v130_PLF.txt`, `switches_impl_grid.txt`,
  `switches_v130_grid.txt`, `census_P_L.txt`, `census_P_F.txt`, `probe_census_P_L.txt`,
  `probe_census_P_F.txt`, `byteverify_*`, `attribution_single_switch.txt`,
  `attribution_all_off.txt`, `downstream_fix1.csv`, `downstream_cases_*.txt`, `canaries_fix1.txt`.
