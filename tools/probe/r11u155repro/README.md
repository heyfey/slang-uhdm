# r11u155: the module/type ground on the strict axis (pair B, refill after pass 152)

Base `78f8134a` (branch matrix-1.87). Files of the ground touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp` (no header; no `ExprEmit.cpp` / `EmitHelpers.h` / `StmtEmit.cpp` / `ParamEmit.cpp` line).
Eleven laws under twelve switches, `R11U155_OFF=1` drops all of them. The switch helper is `r11u155Law`
(UhdmExporter.cpp, beside `r11u152Law`).

The slang-fenced tests are written `FENCED=` here. Every driver that reads corpus sources or corpus databases
(`drivers/heads.sh`, `drivers/predict.py`, `drivers/attrib.sh`) refuses to run without `$FENCED` and skips those
names (word match). No fenced test was run, read or decoded outside the gate sweeps, which dispatch every row
themselves.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u155_bin/pris.bin` | `3b033b63958f68a1837d254512b79a3e` | worktree `/tmp/wt_r11u155` at 78f8134a, system-deps config, `-j 2`; byte-identical to the main tree's `build/slang-uhdm` |
| `/tmp/r11u155_bin/law2.bin` | `9539451580d1a22a2a38a8086d11a8b7` | 78f8134a + this patch (the final build) |
| `/tmp/r11u155_bin/law.bin` (= `dev4.bin`) | `ce9c70bf0091d4645fcff35f3c4694be` | the previous build, superseded: its § ifaceSigConnNamedByChildPort155 also renamed a GENERIC port's members (section 4, the superseded build) |
| `/tmp/r11u155_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the committed comparator (worktree build = main tree build) |
| `/tmp/r11u155_bin/g1.bin` | `143980bfceddfe5b203959f2998a491f` | `-g1` build used by gdb only (decode of the writers) |
| `/tmp/r11u155_bin/strictcmp_x` | (built by `r11u156map/drivers/cc.sh`) | raw full names for the StructParamFieldRange decode only |

Sweeps (`tests/sweep.sh --jobs 3`, same-length workdirs): `/tmp/r11u155_swP` (pristine), `/tmp/r11u155_swL`
(final law, `law2.bin`), `/tmp/r11u155_swD` (the superseded `law.bin`). Every `cmds.txt` names its binary: 3273 of
3273 `slang:` lines read `/tmp/r11u155_bin/pris.bin` in the pristine sweep and `/tmp/r11u155_bin/law2.bin` in the
final law sweep; each downstream sweep ran with its own binary.

## 2. Laws (each behind its own switch; `R11U155_OFF=1` drops every law of the pass)

| law | switch | site | statement (decode) |
|---|---|---|---|
| § initTsEndProgramLocal155 | `R11U155_PRGINITEND_OFF` | ModuleEmit.cpp, the PROGRAM process-local hoist (`hoistBlk`) | map N1146. The program-scope logic_net Surelog lists for an INITIALISED process local (`integer j = 0;`, `frame_t frame = new();`) reads a typespec ending at the initializer: SimpleConstraint 52:6-52:19 where ours read 52:13 (the block's own variable keeps the type span). Only a keyword or class type (a typedef name binds a clone; grid IT s11 is stage-1). Grid IT |
| § implicitArgDimsInner155 | `R11U155_IMPLARGDIM_OFF` | TypeEmit.cpp makeTypespec, the ImplicitType dimension branch | map N0767. A subroutine formal with no direction/`const`/`var`/`static` keyword whose type is only packed dims (`function f([2:0] sdn)`, the directionless follower of `input [2:0] a, [3:1] b`) reads its logic_typespec and first range at the first dimension's INNER text (`2:0`): ImplicitArg 5:4-5:7 where ours read 5:3-5:8. Grid IA |
| § nonAnsiArrayNetAtHeader155 | `R11U155_NAARRNET_OFF` | ModuleEmit.cpp emitInstance, after `emitArrayNet` | map N1135 + N1156. The elaborated array_net of a NON-ANSI port (`module dut(var3); output struct2 var3 [7];`) is located at the header name (UnpackPort 1:12-1:16, ours 6:18-6:22); its struct_net element starts there and keeps its end (1:12-6:26), a logic_net element takes the header name span. Top and child instances alike (UP u10). Grid UP |
| § unitAggTfArgLastWriter155 | `R11U155_UNITUNIONARG_OFF` (union), `R11U155_UNITSTRUCTARG_OFF` (struct) | UhdmExporter.cpp, the file-level typedef loop (`lastFormalTok155`) | map N1041 + N1161. A `$unit` packed union / struct typedef named by a subroutine formal is relocated to the formal's type token, the LAST compiled formal winning (Surelog `compileTfPortList`: `populateCoreMembers(type, type, ts)` on the shared object): union_param_repro u_t 7:31-7:34 where ours kept 5:9-5:50. All writers in one container ($unit or one module definition) else declined (UF f20); class methods decline; DPI imports do not write. The struct half extends the existing first-formal rule to the last writer, module subroutines and module-signal users (UF f09, f16, f17, f21); writeNets' end move still lands after it (UF f22). Grid UF |
| § pselConnNameNotFrozen155 | `R11U155_PSELNAME_OFF` | ModuleEmit.cpp emitInstance, the part-select HighConn block ("A part-select HighConn's bounds reduce like the module_array's own range") | map N1118, pass-147 sister face S3. `ref_obj::VpiFullName()` STORES the name it computes from the parent chain; reading it before the instance sits under its generate scope froze `work@X.u_c.ci.in_i` (golden `work@X.gen_inst.u_c.ci.in_i`). The bound fold now reads it only for an operation bound, and a name already frozen by the actual's emission (ExprEmit) is re-derived from the instance's own full name, the bound references named through it following (generate-loop PS3 n03). Grid PS3 |
| § packedStructNdaFoldConstLoc155 | `R11U155_NDAFOLDLOC_OFF` | ModuleEmit.cpp, the net-declaration "PACKED-struct assignment-pattern ... folds to an op75" case | map N0394 + N1140, pass-147 sister face S4. The folded constant of a ONE-element pattern (`my_struct s = '{word: 125};`, `'{125}`) is located at the element's value (PatternStruct 5:26-5:29); ours had no location. Wider patterns are stage-1 elsewhere (PS4 p02/p04/p05/p07). Grid PS4 |
| § ifacePortViewFoldAtLeftOperand155 | `R11U155_PVLEFTOP_OFF` | ModuleEmit.cpp emitInterfaceInstance, the `portView && !namedModportPortView9` param_assign loop beside § ifacePortViewAggParamParent120 | map N0005, pass-147 sister face S1. The PORT VIEW's folded constant of an operation default (`localparam int unsigned BYT = DAT/8;`) is its own object located at the operation's LEFT operand (`DAT` 10:33-10:36; `CFG.BUS.DAT` 15:33-15:44), a unary operation at its operator token, parentheses transparent; the connected instance's own view keeps the whole initializer (ours shared one object). Grid PV (binary, nested, parenthesised, unary, call, shift) |
| § pkgTdStretchNonAnsiHeaderSkips155 | `R11U155_TDSTRETCHHDR_OFF` | UhdmExporter.cpp, the `pendingPkgTsStretch` loop | map N0009's IfGenTypeBinding face (r11u153's residue on § defNetTypedefEndWrite134). A module whose header carries a NON-ANSI port list, the empty `()` included, does not stretch an imported package typedef: the definition net carries no typespec there (`isNonAnsiHeader`, ModuleEmit.cpp) so writeNets' end-only populate has nothing to land on (IfGenTypeBinding pmp_cfg_t 3:11-8:4, ours 18:66). `module top;`, a parameter-only header and an ANSI port list still stretch (TE t02/t04/t08). Grid TE |
| § modAggTfArgLastWriter155 | `R11U155_MODAGGARG_OFF` | TypeEmit.cpp emitTypedefs (packed struct and packed union branches, `modTfArgLastTok155`) | map N0438 (+ N0043's module face). The module-body twin of § unitAggTfArgLastWriter155: const_cast_signext `op_t` 19:42-19:46 (the third function's formal) where ours kept 15:11-15:61. The value-parameter copies ParamEmit builds keep the typedef span (sister residue R-SP). Grid MF |
| § dirlessFormalTypeAtName155 | `R11U155_DIRLESSNAME_OFF` | TypeEmit.cpp makeTypespec, the packed-array-over-struct/enum leaf branch (beside § pkgLeafPatLocByWriting152) | pass-152 residue 1 (v11u152 KP p03 / KY y04). A directionless formal written as a named type with packed dims (`function int f(s_t [2:0] v)`) locates its packed_array_typespec at the type NAME (6:28-6:31, ours ended at the dims), a package-qualified name at its `pk::` prefix (ours unlocated); an `input` formal keeps the whole span (FN n08). Tasks, class methods and module/package homes alike. Grid FN |
| § ifaceSigConnNamedByChildPort155 | `R11U155_IFSIGCHILD_OFF` | ModuleEmit.cpp emitInterfaceInstance, after the elab-view modport loop | map N0269 + N0450 + N1059 + N1072. In a MODPORT-qualified port view, a member connected BARE to a child instance's port (`child c (.clk(sub.clk))`, positional and output connections too) is named through that child port (`work@dut.m.c.clk.clk`, ours `work@dut.m.sub.s.clk.clk`; OneNetModport `work@top.dut.sub1.inp.drive`), the last connection in source order winning (IC i02); the io_decl's net or variable and its ref_typespec both take it. A member under an operator (IC i05), a plain interface port view (IC i03, i09) and a GENERIC port whose modport comes from the connection (`module mid (interface sub)`, IC i08; OneNetModPortGeneric keeps `work@TOP.dut1.middle1.intf.drive`) are untouched. Grid IC |

## 3. Targeted rows (fresh law-sweep csv rows, `name,mode,status,detail,blocked_by,strict`)

**20 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions.** Surelog 10 (default CMP_EQUAL 417 -> 422,
testflags 416 -> 421), uhdm2rtlil 10 (736 -> 741 per mode).

| row-mode(s) | before | after (fresh row) | law (single-switch attribution, section 4) |
|---|---|---|---|
| ImplicitArg d / t | differ:col(4) | `ImplicitArg,default,CMP_EQUAL,,,equal`, same testflags | implicitArgDimsInner155 |
| UnpackPort d / t | differ:line(2) | `UnpackPort,default,CMP_EQUAL,,,equal`, same testflags | nonAnsiArrayNetAtHeader155 |
| GenForIfaceLocalparamBound d / t | differ:endcol(1) | `GenForIfaceLocalparamBound,default,CMP_EQUAL,,,equal`, same testflags | ifacePortViewFoldAtLeftOperand155 |
| GenForIfaceLocalparamNestedGen d / t | differ:endcol(1) | `GenForIfaceLocalparamNestedGen,default,CMP_EQUAL,,,equal`, same testflags | ifacePortViewFoldAtLeftOperand155 |
| IfGenTypeBinding d / t | differ:endline(5) | `IfGenTypeBinding,default,CMP_EQUAL,,,equal`, same testflags | pkgTdStretchNonAnsiHeaderSkips155 |
| union_param_repro d / t (u2r) | differ:line(4) | `union_param_repro,default,CMP_EQUAL,,,equal`, same testflags | unitAggTfArgLastWriter155 (union switch) |
| genscope_module_ctx_reset d / t (u2r) | differ:fullname(1) | `genscope_module_ctx_reset,default,CMP_EQUAL,,,equal`, same testflags | pselConnNameNotFrozen155 |
| PatternStruct d / t (u2r) | differ:file(1) | `PatternStruct,default,CMP_EQUAL,,,equal`, same testflags | packedStructNdaFoldConstLoc155 |
| OneNetModport d / t (u2r) | differ:fullname(4) | `OneNetModport,default,CMP_EQUAL,,,equal`, same testflags | ifaceSigConnNamedByChildPort155 |
| iface_sig_in_child_port d / t (u2r) | differ:fullname(4) | `iface_sig_in_child_port,default,CMP_EQUAL,,,equal`, same testflags | ifaceSigConnNamedByChildPort155 |

**Downstream rows of the converted uhdm2rtlil tests (fresh, all IDENTICAL, `differs` empty):**
`union_param_repro,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `genscope_module_ctx_reset,IDENTICAL,OK,OK,11,11,,`
`PatternStruct,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `OneNetModport,IDENTICAL,NO_GATES,NO_GATES,0,0,,`
`iface_sig_in_child_port,IDENTICAL,OK,OK,2,2,,` (and `const_cast_signext,IDENTICAL,NO_GATES,NO_GATES,0,0,,`).

**Improved, still STRICT_NOTEQUAL** (compare_results CHANGE lines, every one smaller or the walk's next pre-existing
face):
* SimpleConstraint d/t `differ:endcol(4) -> differ:endcol(2)` (initTsEndProgramLocal155); the rest is the method-call
  hier_path `frame.randomize` ending before `()` (golden 57:12-57:29, ours 57:27): ExprEmit, sister ground.
* const_cast_signext d/t `differ:line(15) -> differ:line(5)` (modAggTfArgLastWriter155); the five left are ParamEmit's
  value-parameter copies (residue R-SP).
* YosysBigSimEllip d `differ:fullname(2941) -> differ:type(1)` (pselConnNameNotFrozen155): 2940 generate-scope
  part-select actual names cleared; the first record left, #70374 `part_select C` against our `constant`, is the SAME
  record the pristine walk already diverges at (`evidence/sweeps` note: pristine `--max 5000` lists #70374 type with
  identical A/B lines; objects 681189 vs 681181 in both).

## 4. Gates (`tests/sweep.sh --jobs 3`, `evidence/sweeps/sweep_{pristine,law}.log`, `downstream_{pristine,law}.log`)

| gate | pristine (`/tmp/r11u155_swP`) | law (`/tmp/r11u155_swL`) |
|---|---|---|
| probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2491, STRICT_NOTEQUAL 1596) | regressions 0, conversions 8, changes 67 (EQUAL 2499, STRICT_NOTEQUAL 1588) |
| surelog vs golden_surelog.csv | 0 / 0 / 0 | regressions 0, conversions 10, changes 3 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | regressions 0, conversions 10, changes 2 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0 | the same; `downstream.csv` identical to pristine's row by row (pass 120's eight rows included) |

The law sweep exits 1 for one reason only, `law index STALE` (the worktree's edited `src/` before
`scripts/law_index.py`; the patch carries the regenerated `tests/LAWS.md`). uhdm-cmp reads 0 lines on every touched
row and case: every converted row is CMP_EQUAL, every changed row stays STRICT_NOTEQUAL (judge-equal), and the probe
stage has no NOT_EQUAL case.

* **Probe changes and conversions (75 cases), all attributed** (`drivers/attrib_probe.sh`,
  `evidence/sweeps/probe_attribution.txt`): each case returns to the pristine bytes under `R11U155_OFF=1` and under
  exactly one switch. PVLEFTOP 69 (the r10rgg3 / r10vrgg3 / r11u115 / v11u115 interface port-view families; six
  convert: r10rgg3repro b1_pl_named_norecvp, b2_pl_named_recvp, r10vrgg3repro x2_named_only_override_single,
  x3_plain_positional_single, r11u115repro/grid/i/s21_recv_B_nonarr_pos, v11u115repro/grid/f2/p08_single_pl_named_recvA),
  PSELNAME 3 (r10rgg6repro genfor_* typed_param, endcol count -3 each), IFSIGCHILD 2 (r10rggen9repro t8
  fullname(4) -> fullname(2), t9 converts), DIRLESSNAME 1 (r11u109repro/grid/hp/h13_func converts). 66 of the 67
  changes lower the count on the same first field; `r11v1repro/vA` reads `endcol(2) -> depth(1)`: the endcol record
  (#253, the port-view constant) cleared and the first record left, #292 depth, is the one the pristine walk already
  held (pristine strict run lists #253 endcol then #292 depth with identical lines). The 75 probe byte movers are
  exactly the 75 verdict movers (`evidence/sweeps/probe_byte_movers.txt`, no byte-only probe mover).
* **Byte movers, corpora** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, path sets identical, 959/960 and
  1607/1608 flagged by the self-check; `evidence/sweeps/byteverify_*.txt`): uhdm2rtlil 12 = the 6 moved tests x 2
  modes; surelog 23. Single-switch attribution (`drivers/attrib.sh`, `evidence/sweeps/corpus_attribution.txt`):
  every deterministic mover returns to the pristine bytes under `R11U155_OFF=1` and under exactly one switch:
  ImplicitArg (IMPLARGDIM), UnpackPort (NAARRNET), GenForIface x2 (PVLEFTOP), IfGenTypeBinding (TDSTRETCHHDR),
  SimpleConstraint (PRGINITEND), YosysBigSimEllip d (PSELNAME), union_param_repro (UNITUNIONARG), genscope_module_ctx_reset
  (PSELNAME), PatternStruct (NDAFOLDLOC), OneNetModport + iface_sig_in_child_port (IFSIGCHILD), const_cast_signext
  (MODAGGARG), and three byte-only movers whose csv row is unchanged: **Earlgrey_0_1 d/t (PSELNAME), OneNetModPort
  d/t and Rggen d (IFSIGCHILD)**. Their full strict tallies are identical pristine vs law (the walk diverges before
  the moved objects), and each moves TOWARD golden by the order-blind dump distance (sorted uhdm-dump lines
  differing from golden, pristine -> law): Earlgrey_0_1 507875 -> 507715, Rggen 64486 -> 63856, OneNetModPort 119 ->
  91 (`evidence/sweeps/byteonly_movers_fields.txt`). The UVM coin family moves as always: MiniAmiq d/t, SeqDriver
  d/t and SimpleUVM d, 4 order-blind dump lines each (`evidence/sweeps/uvm_coin_orderblind.txt`), the OFF re-run
  landing on either face.
* **The superseded build** (`law.bin`, sweep `/tmp/r11u155_swD`): the same csv verdict lines and the same downstream
  csv, but its byte verifier also moved OneNetModPortGeneric d/t, and the order-blind distance to golden GREW (128 ->
  156 lines): its § ifaceSigConnNamedByChildPort155 renamed the members of a GENERIC `interface intf` port whose
  modport comes from the connection (`.intf(conntb.dut)`), where golden keeps the port-view name. Invisible to the
  strict count (the walk diverges earlier); the final build gates the generic road out (fresh case IC i08, whose
  bytes the superseded build moved away from golden and the final build returns to pristine's), and
  OneNetModPortGeneric no longer moves. Every other verdict, csv row and probe database is the same in both builds.
* **Prediction.** `drivers/predict.py` (a wide source-shape census per law, fenced) names 324 tests
  (`evidence/sweeps/prediction.txt`). It predicts 15 of the 19 moving tests by law; it misses Earlgrey_0_1 and Rggen
  (sources outside the test directory), YosysBigSimEllip (the part-select actual shape) and MiniAmiq / SimpleUVM (the
  coin). The
  census was written after the development sweeps had run, so it is not a blind prediction: stated here as a gap
  against the brief's prediction step, as pass 152 stated its own.
* **Canaries** (`evidence/sweeps/canaries.txt`): canaries.sh surelog ok=50 changed=2 (SimpleConstraint d/t, the
  attributed CHANGE), uhdm2rtlil ok=16 changed=0; ctcan2 surelog ok=58 changed=0 (EXPECT_UNKNOWN=1) PASS,
  uhdm2rtlil ok=2 changed=0 (EXPECT_UNKNOWN=6) PASS.
* Pass 120's rows stay IDENTICAL (the downstream csv is unchanged row by row), and every earlier pass's probe case is
  either unmoved or in the attributed list above; no case left EQUAL.

## 5. Grid (`cases/`, 135 law cases + 23 residue repros, `drivers/gridall.sh`, `evidence/grid/gridall.txt` and `residue_repros.txt`)

Goldens: `drivers/grid.sh` (pinned Surelog with check_probe's arguments, cached under `/tmp/r11u155_g`); ours with
`--single-unit --nobuiltin`. Each case's first line names its law. The 23 decode-only repros of the sister/structural residues (EV, LS, LT) were
run from `cases/` too and then moved to `evidence/residue/<dir>/<case>.sv.txt` (first line `residue ...`), so the law
index does not attribute them to this pass's laws.
Columns: pristine verdict, law verdict (+ uhdm-cmp lines), `R11U155_OFF=1` verdict and bytes against pristine, the
case's own switch verdict and bytes against pristine. **Every one of the 135 law cases returns to the pristine bytes
under `R11U155_OFF=1` and under its own switch; no case that pristine read STRICT_EQUAL reads otherwise with the law
(0 breaks); the 23 residue repros are byte-identical to pristine under the law.**

| dir | law | cases | pristine EQUAL | law EQUAL | controls / stage-1 |
|---|---|---|---|---|---|
| IT | initTsEndProgramLocal155 | 20 | 6 | 16 | s02 m01 m02 m03 i01 s05 s06 s14 equal both ways; s04 s07 s11 s16 stage-1 |
| IA | implicitArgDimsInner155 | 17 | 5 | 14 | a02 a03 a06 a07 a13 (directed / typed) equal both ways; a05 (two dims: Surelog drops one) a09 a12 stage-1 |
| UP | nonAnsiArrayNetAtHeader155 | 12 | 1 | 5 | u07 (ANSI) equal both ways; u10 (child instance) moves to golden's spans behind an earlier `type` face; u03 u05 u06 u09 u11 u12 stage-1 |
| UF | unitAggTfArgLastWriter155 | 22 | 4 | 15 | f02 f06 f07 equal both ways; f20 (writers in two modules) declined; f08 (union return type: the return variable's span, another face); f12 f13 f15 f18 f19 stage-1 |
| PS3 | pselConnNameNotFrozen155 | 9 | 4 | 8 | n02 n05 n08 n09 equal both ways; n04 stage-1 |
| PS4 | packedStructNdaFoldConstLoc155 | 8 | 0 | 2 | p02 p04-p08 stage-1 |
| PV | ifacePortViewFoldAtLeftOperand155 | 9 | 0 | 9 | |
| TE | pkgTdStretchNonAnsiHeaderSkips155 | 10 | 5 | 9 | t02 t04 t06 t07 t08 equal both ways; t05 stage-1 |
| MF | modAggTfArgLastWriter155 | 7 | 0 | 2 | m05 (a localparam of the type: ParamEmit copies, R-SP); m01 m02 m04 m06 stage-1 |
| FN | dirlessFormalTypeAtName155 | 12 | 1 | 10 | n08 (`input`) equal both ways; n04 n12 stage-1 |
| IC | ifaceSigConnNamedByChildPort155 | 9 | 2 | 7 | i03, i09 (plain interface port) equal both ways; i08 (generic port: the break the superseded build had, now pristine bytes); i05 (`~sub.clk`): the renamed member clears, the pre-existing structural record left |
| EV (evidence/residue) | residue R-EV | 8 | 1 | 1 | unmoved |
| LS (evidence/residue) | residue R-SP | 5 | 1 | 1 | unmoved |
| LT (evidence/residue) | residue R-LT | 10 | 2 | 2 | unmoved |

Law grids: 135 cases, pristine STRICT_EQUAL 28 -> law 97.

## 6. Sister-ground faces and decodes (stopped at the decode; call sites for r11u154 / the next ground-A pass)

* **R-EV, EnumVar d/t (N0844 + N0851).** Golden moves an enum-ALIAS clone's end (`typedef enum_t alias_t;`,
  `pkg::alias_t b;`) only when the using declarator has an unpacked dimension or an initializer (evidence/residue/EV e03/e06);
  a bare declarator (`pkg::alias_t b;`, e02/e04/e08) keeps the enum's span. Our writer (gdb watch on the alias
  object's end line) is ParamEmit.cpp `emitPackage`, the enum-alias clone block ("A module VARIABLE of the alias type
  extends the span to its declarator end"): `useEnd = dsyn0->sourceRange().end()` should require
  `!dd.dimensions.empty() || dd.initializer`.
* **R-SP, struct_param_pattern_packing (N0043) / const_cast_signext's rest / StructParamFieldRange,
  cva6_struct_param_field (N0009 fullname).** A value parameter typed by a struct typedef (or by a `localparam type`
  anonymous struct) gets per-use struct copies from ParamEmit.cpp `makeParamTs` (callers `mintParamOpClones` from
  ModuleEmit emitInstance, `patchParamTypespecs`, `drainDefParamTs`; gdb backtraces of `MakeStruct_typespec`).
  Golden's copies carry the span the shared object has AFTER the formal relocation (the package's own relocation is
  ParamEmit.cpp emitPackage "A package STRUCT typedef named as a package SUBROUTINE ARGUMENT's type ... last-writer
  stamp"; the module's is § modAggTfArgLastWriter155) or the type parameter's `struct` keyword span
  (§ typeParamStructAtKeyword146), and name their member references through the value parameter
  (`work@StructParamFieldRange.I.x`, raw names via strictcmp_x). Repros evidence/residue/LS (unmoved), grid MF m05.
* **MultirangesStartNotFromZero d/t (N0831 + N0843).** In a generate cont_assign, golden mints loc-less enum_const
  copies for the part-select bound references on BOTH sides; ours mints them on the Rhs only and binds the LHS
  var_select's bounds to the shared located enum_const. ExprEmit.cpp `emitExpr`, the enum-constant mint
  (§ genCaSelEnumPlainDecompile22 / § uninstIfaceEnumConstNoActual221 block, `caEnumSelPos22` / `genCaLhsSelect22`).
* **SimpleConstraint's rest.** A method-call hier_path `frame.randomize()` spans through the parentheses in golden:
  ExprEmit.cpp emitExpr (the method-call hier_path).
* **HierPathTypespec t (N1174).** The testflags-only golden binds the member reference to the typespec_member of the
  struct copy under `pkg::b`'s element (`pkg::pkg::b::pkg::a::x`); the binding is ExprEmit's (hier_path member
  actual), not buildStructTs.

## 7. Residues, ranked

1. **R-SP** above (ParamEmit makeParamTs copies): struct_param_pattern_packing d/t (1 object), const_cast_signext d/t
   (5), StructParamFieldRange / cva6_struct_param_field d/t (fullname 4 + span 3). Sister.
2. **R-EV** EnumVar d/t (3 objects): one condition in ParamEmit emitPackage. Sister.
3. **R-LT, LogicTypespec d/t (N0422 + N0484 + N1149).** Structural: golden binds `pkg::t [1:0][7:0] x` straight to
   the package's vector typedef object, DROPPING the written packed dims, and writeNets moves that object's end to the
   first packed dim (evidence/residue/LT l01/l02/l06: 29 golden records against our 39). Following it changes the declared width
   the downstream plugin would read; not attempted.
4. **GenerateUnnamed d/t fullname(9).** Gate terminal references in unnamed generate blocks are named through the
   syntactic nesting (`work@test1.genblk1.genblk1.u1.a`, `genblk1.genblk1.genblk1.a` for a nested `if (1) begin`)
   while the gen_scope_arrays are listed flat; not decoded to a rule.
5. **packed_array_reset_loop / packed_array_struct** (type-parameter default with packed dims on a VECTOR or
   struct default; walk diverges, 377/367 and 340/268 records): § defNetTypeParamPackedDim144's vector half,
   judge-visible per its own grid; not attempted.
6. **packed_struct_array_fifo, gen_scope_typaram** (type-parameter clone member names), **ClassTypeParam** (17
   objects), **rp32 set** (6+ clusters each), **UVM/Earlgrey-only clusters**: not reached.
7. Law residues: UF f08 (a union typedef as a function RETURN type locates the return variable at the type name);
   PS4 multi-element patterns (stage-1); IA a05 (two packed dims on an implicit formal: Surelog keeps one range,
   stage-1); IC members read under an operator keep the port-view name (golden too).

## 8. Files

* `cases/<dir>/<case>/dut.sv`: the 135 law cases (first line `// § <law>`); `evidence/residue/<dir>/<case>.sv.txt`: the
  23 residue repros (`evidence/grid/residue_repros.txt`).
* `drivers/grid.sh` (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), `drivers/gridrun.sh`, `drivers/gridall.sh`
  (every case, four binaries/switch states), `drivers/heads.sh` (strict heads of named rows, fail-closed on
  `$FENCED`), `drivers/predict.py` (the source-shape mover census, fail-closed), `drivers/attrib.sh` and
  `drivers/attrib_probe.sh` (single-switch byte attribution).
* `evidence/grid/gridall.txt`, `evidence/sweeps/` (sweep and downstream logs, byteverify, attribution, prediction,
  canaries, the UVM coin and byte-only mover checks).
