# r11u154 — the expression/parameter ground of the strict axis, seventh refill (implementer)

Base `b6af876c` (branch matrix-1.87). Ground: `src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/ParamEmit.cpp`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or `include/`: the faces whose fix sits there are decoded below (section "Sister-ground faces") and
stop at the decode. Net binding is not touched (the one binding law, § varInitStrMethodArgDefNet154, rebinds a
built-in STRING method's argument references, not a net). Passes 140/145/147's laws, the r11u151 laws and the
r11u141/149/153 refinements are not edited. Worktree `/tmp/wt_r11u154`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base, byte-identical to the main tree's `build/slang-uhdm`) | `0b3b2d0a323c79f91d52be50e5bff788` |
| law (this patch, 15 laws) | `c9e81a5c0efdfc6b4806d6f207216d27` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |
| pristine built with `-g1` (gdb pins only; frozen as /tmp/r11u154_bin/pris_g1.bin) | not a gate binary |

Every binary frozen (`chmod 555` copies in /tmp/r11u154_bin) before measuring. The pristine sweep (`/tmp/r11u154_wdp`)
names the pristine copy in 3273 / 3273 `cmds.txt` slang lines, the final law sweep (`/tmp/r11u154_wdm`) the law copy
in 3273 / 3273. The pristine sweep reads `regressions=0 conversions=0 changes=0` in all three stages against the
committed baselines (evidence/sweep_pristine_vs_baselines.txt); its only red is `law index STALE` (this repro
directory), which this patch's tests/LAWS.md fixes.

**The fence.** No binary, gdb run, script or reader touched a slang-fenced test's source outside the sweeps. The
corpus stages are `tests/sweep.sh` runs, which dispatch every row the baselines hold (the fenced rows included), and
the census is verify_golden.py's corpus stage — the exact call `tests/sweep.sh` makes — with drivers/tracewrap.sh
standing in for the binary; its log was filtered by word boundary on `$FENCED` before any read (`grep -vw`, 0 lines
dropped: no law fires on a fenced row). drivers/rowdump.sh and drivers/moverdiff.sh refuse to run without `$FENCED`
and skip fenced names. The scratch copies of corpus sources used for decoding (StringMethod, the u2r tests named
below, GenIfIfaceParamStructField, InterfaceParamOverrideProp) are none of the fenced four.

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 815 | **820** | +5 |
| uhdm2rtlil strict-equal (of 1606) | 1454 | **1474** | +20 |
| probe EQUAL (of 4087) | 2445 | **2460** | +15 |
| surelog / uhdm2rtlil judge-equal (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT | same | 0 of 871 verdicts changed |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them)**, the fresh csv rows
(evidence/conversions_fresh_rows.txt, evidence/sweep_law_vs_baselines.txt) with the laws the census names for each
(evidence/census_predicted_rows.txt):

    surelog:
      BasicOh,default,CMP_EQUAL,,,equal                              § genScopeProcPsNamedByScope154 + § genProcFoldTsKeepsScope154
      InterfaceParamOverrideProp,default,CMP_EQUAL,,,equal           § defPkgStructParamMemberNames154
      InterfaceParamOverrideProp,testflags,CMP_EQUAL,,,equal         (same)
      StringMethod,default,CMP_EQUAL,,,equal                         § builtinMethodArgNamedByPath154 + § varInitStrMethodArgDefNet154
      StringMethod,testflags,CMP_EQUAL,,,equal                       (same)
    uhdm2rtlil:
      comb_dyn_2d_packed_sel,default,CMP_EQUAL,,,equal               § elabCastSharesDeclRef154
      comb_dyn_2d_packed_sel,testflags,CMP_EQUAL,,,equal             (same)
      iface_arr_struct_field_partsel,default,CMP_EQUAL,,,equal       § hpPartSelBoundNamesBySelect154 + § hpElemSelNameIsPathSoFar154
      iface_arr_struct_field_partsel,testflags,CMP_EQUAL,,,equal     (same)
      iface_cfg_mem,default,CMP_EQUAL,,,equal                        § portViewNestedPatTsNamed154
      iface_cfg_mem,testflags,CMP_EQUAL,,,equal                      (same)
      iface_nested_param_field,default,CMP_EQUAL,,,equal             § defPkgStructParamMemberNames154 + § portViewNestedPatTsNamed154
      iface_nested_param_field,testflags,CMP_EQUAL,,,equal           (same)
      iface_param_2level,default,CMP_EQUAL,,,equal                   § portViewNestedPatTsNamed154
      iface_param_2level,testflags,CMP_EQUAL,,,equal                 (same)
      iface_scalar_localparam,default,CMP_EQUAL,,,equal              § hpPartSelBoundNamesBySelect154 + § paramInitUnpackedMemberPath154 + § psBoundPathFirstMember154 + § defPkgStructParamMemberNames154 + § portViewNestedPatTsNamed154
      iface_scalar_localparam,testflags,CMP_EQUAL,,,equal            (same)
      iface_struct_field_param_width,default,CMP_EQUAL,,,equal       § defPkgStructParamMemberNames154 + § portViewNestedPatTsNamed154
      iface_struct_field_param_width,testflags,CMP_EQUAL,,,equal     (same)
      iface_struct_field_partsel,default,CMP_EQUAL,,,equal           as iface_scalar_localparam
      iface_struct_field_partsel,testflags,CMP_EQUAL,,,equal         (same)
      jeras_tcb_gpio,default,CMP_EQUAL,,,equal                       § hpPartSelBoundNamesBySelect154
      jeras_tcb_gpio,testflags,CMP_EQUAL,,,equal                     (same)
      mem_ff_partial_rsp,default,CMP_EQUAL,,,equal                   § lvIdxPathIsRead154
      mem_ff_partial_rsp,testflags,CMP_EQUAL,,,equal                 (same)

BasicOh testflags was already CMP_EQUAL and stays so (its database moves: the gen-scope part-select names take the
block, a record-neutral move, below).

Probe: 15 cases `STRICT_NOTEQUAL -> EQUAL`, each reading `EQUAL,,equal` in the fresh probe.csv:
`r10earl57repro/v1_paramkinds57`, `v2_contexts57`, `r10earl97repro/g0_head97`, `r10earl_repro/qj27`, `ve`,
`r10vearl97repro/va2_ovr97`, `va6_nest97` (§ elabCastSharesDeclRef154: all `depth(1)`, the re-listed cast
reference), `r10earl58repro/v58v1_earl58`, `v58v6_earl58`, `r10earl_repro/pt20`, `r10rggen7repro/t9`,
`r10scr14repro/t6`, `r10svs2repro/s3_arraykind`, `r11u22repro/grid/c09_procedural` (the gen-scope / hier-path name
laws: GSPROCPS, GSFOLDTS, MARGNAME, HPPSBOUND), `r11vu15repro/grid/v05_struct_member_sel` (§ lvPathBaseAtFirstMember154).

**Targeted rows (brief items), before -> after:**

| row | before | after | law / what is left |
|---|---|---|---|
| comb_dyn_2d_packed_sel d/t (N0286) | depth(1) | **CMP_EQUAL** | § elabCastSharesDeclRef154 |
| StringMethod d/t (N0006 + N0765) | fullname(2) | **CMP_EQUAL** | § builtinMethodArgNamedByPath154 + § varInitStrMethodArgDefNet154 |
| iface_arr_struct_field_partsel d/t (N0833 + N1067) | fullname(4) | **CMP_EQUAL** | § hpPartSelBoundNamesBySelect154 + § hpElemSelNameIsPathSoFar154 |
| iface_struct_field_partsel d/t (N1063, pass-147 R3a) | fullname(13) | **CMP_EQUAL** | five laws (above) |
| InterfaceParamOverrideProp + the iface tests (pass-146 sister residue, "member names in parameter typespec copies") | fullname(2..13) | **CMP_EQUAL** (5 tests, 10 row-modes) | § defPkgStructParamMemberNames154 (+ § portViewNestedPatTsNamed154); iface_zero_width_field stays (residue 5) |
| iface_cfg_mem, iface_param_2level d/t | fullname(1) | **CMP_EQUAL** | § portViewNestedPatTsNamed154 |
| BasicOh d (pass-146 "names inside a select", gen-scope face) | fullname(29) | **CMP_EQUAL** | § genScopeProcPsNamedByScope154 + § genProcFoldTsKeepsScope154 |
| mem_ff_partial_rsp d/t (hier-path bases outside TypeEmit) | col(16) | **CMP_EQUAL** | § lvIdxPathIsRead154 |
| jeras_tcb_gpio d/t | fullname(4) | **CMP_EQUAL** | § hpPartSelBoundNamesBySelect154 |
| ibex_multdiv_fast d/t, ibex_icache d/t | fullname(101/161) | fullname(87/158) | GSPROCPS; the rest is the ibex macro-line family |
| BuildUVMPkg d/t, MiniAmiq/SeqDriver/SimpleUVM d/t, Scoreboard d | line(165/190/174/190/194) | line(94/183/167/183/187) | MARGNAME + the lvalue laws; the `include_file_info` line face stays |
| Earlgrey_0_1 d/t, Scr1SvTests d/t, InterfaceModPort d/t | line(1742)/line(220)/endcol(17) | line(1734)/line(219)/endcol(15) | CASTREF/GSPROCPS/HPPSBOUND; LVIDXREAD |
| anon_struct_packed_dim d/t (N0820) | fullname(43) | unchanged | decoded: TypeEmit (residue 3) |
| ComplexParamOverload d/t (N0739) | name(2) | unchanged | decoded: ModuleEmit emitContAssigns (S1) |
| MacroArgMismatch d/t, YosysMarlann d/t | endcol(8/24) | unchanged | decoded: the preprocessor column model (S2, S3) |
| GenForIfaceLocalparamBound/NestedGen d/t (N0077) | endcol(1) | unchanged | the port-view parameter span, sister S1 of pass 147 |
| genscope_module_ctx_reset, PatternStruct (N1118, N0394) | fullname(1)/file(1) | unchanged | sister S3/S4 of pass 147 |
| GenIfIfaceParamStructField d/t | col(2) | unchanged | decoded: TypeEmit emitSyntaxExpr (S5) |
| YosysBigSimEllip d, packed_struct_array_fifo d/t, rp32 (4 tests), portsel_struct_param, expr_width_cast, ComplexHierPath | — | unchanged | residues 4-7 |

## Laws (each under its own switch; `R11U154_OFF=1` drops all of them; `R11U154_TRACE=1` prints one stderr line per firing)

Sites are named by function and § token (`grep -n '§ <law>' src`). The switch table is the r11u154 block at the end of
src/EmitHelpers.h.

### § hpPartSelBoundNamesBySelect154 (`R11U154_HPPSBOUND_OFF`; ExprEmit.cpp hpPsBoundNames154)
A reference in the bounds of a dotted path's trailing part-select is named through the path and the select:
`work@tcb_gpio.bus.wdt[GW - 1:0].wdt.GW` (jeras_tcb_gpio), `work@mem.sub.req_dly[0].adr[$clog2(BYT) - 1:0].adr.BYT`
(iface_arr_struct_field_partsel), a struct-member path alike (`work@top.s.wdt[GW - 1:0].wdt.GW`); ours named it by
the scope (`work@m.GW`). Decode: Surelog's hier_path loop compiles the trailing `name[l:r]` with
compilePartSelectRange (CompileExpression.cpp, the paPart_select_range branches) and stores no full name on the bound
references, so the writer's ComputeFullName walks the chain reference -> (operation, call) -> part_select (kept:
only a bit_select / indexed part-select / hier_path parent is skipped) -> hier_path. A bare bound is named the same
way (`bus.wdt[GW:0].wdt.GW`). Both part-select branches of the path builders (the MemberAccess branch and the dotted
interface branch). Cases `hp/f1 f2 f3 f7 f8 f9 f10 f14 f15 f18 f19` (f7, an indexed part-select, is the equal control;
f14 keeps a function-argument struct typespec span face, residue 6).

### § hpElemSelNameIsPathSoFar154 (`R11U154_HPELEMNAME_OFF`; ExprEmit.cpp hpElemSelName154)
An indexed element of a dotted path past its first component is named by the path so far (`sub.req_dly[0]`, ours
`req_dly[0]`): the `else if (Expression)` branch of the same Surelog loop sets `VpiFullName(the_name)`, the running
path text. The literal and variable element branches of the dotted interface branch (the folded one, § hpConnElemIdxFold17,
already did). Case `hp/f17`.

### § genScopeProcPsNamedByScope154 (`R11U154_GSPROCPS_OFF`; ExprEmit.cpp, the simple part-select's name)
A process of an elaborated generate scope is emitted before its gen_scope parents it, so the part-select's lazy
full name froze the instance path without the block (`work@top.r.sync_pipe`); Surelog's writer walks the final
chain (`work@top.r.genblk1.sync_pipe`, BasicOh oh_rsync.v `sync_pipe[SYNCPIPE-1:0]`, both directions). The
elaborated twin of the def-view `defGenProcessEmit` branch: the name is `prefix` (the gen block's path) + the name.
Cases `gs/g1 g_nd g_ud`.

### § genProcFoldTsKeepsScope154 (`R11U154_GSFOLDTS_OFF`; ExprEmit.cpp, the gen-scope process parameter fold)
The folded parameter constant's ref_typespec in a gen-scope process was renamed after the instance (the block
segments dropped) in every position. Golden keeps the prefix the fold is emitted under whenever the parameter sits
under an OPERATION (`v[P-1:0]`: `work@top.r.gb.v`; `x + (P - 1)`: `work@top.r.gl[0]`; BasicOh
`…wr_rsync.genblk1.sync_pipe`) and names a bare bit-select index by the select (`v[P]`: `work@top.r.gb.v`); the
instance name belongs to a parameter that IS a part-select bound or an indexed width (generate_test
`result[i*W +: W]`, BasicOh oh_dsync `sync_pipe[SYNCPIPE:0]`: both measured, both kept). Cases `gs/g2 g_la g_lb
g_lc g_ld g_le g_lf g_na g_nb g_nc g_ne g_nf g_ua g_ub g_uc g_ue g_uf` (unnamed if, named if, loop generate x
part-select bound / bit-select index / operation / ips base / bare bound / bare index).

### § builtinMethodArgNamedByPath154 (`R11U154_MARGNAME_OFF`; EmitHelpers.h builtinMethodArgNames154, called from the built-in method branch of emitExpr)
A built-in method call's argument references are named through the path: `int b = s.compare(t)`:
`work@top.b.s.compare.t`; `assign b = s.compare(t)`: `work@top.s.compare.t`; a named block, a function body and a
class method alike (`pos_home_171::sc_shape::sc_shape.substr::kx`, the `::` regime through joinRef). Surelog's loop
compiles the arguments with compileTfCallArguments(..., fcall, ...) and stores no full name, so ComputeFullName
skips the method_func_call and keeps the hier_path `s.compare`. References under an operation argument too
(`s.substr(i, i+1)`). Cases `sm/s3 s4 s6 s7 s8 v5` (s7 `getc(1)`, no reference: control).

### § varInitStrMethodArgDefNet154 (`R11U154_VARINITDEF_OFF`; ExprEmit.cpp, the built-in method branch)
In an elaborated module VARIABLE INITIALIZER a string method's argument references bind the definition listing's
net (`logic_net t`, golden StringMethod), where ours bound the elaborated `string_var t`: Surelog compiles the
initializer once, in the definition, and the elaborated variable keeps it. Continuous assignments and processes
already bind as golden (s3, s4, s8 unchanged). Gate: a string receiver, the owner a variable object, a reference
whose elaborated object has a distinct definition twin (found by the defMap nets, by symbol, else by name +
declaration syntax). Cases `sm/s1 s2 s5 v4` (+ `v1 v6` controls).

### § elabCastSharesDeclRef154 (`R11U154_CASTREF_OFF`; ExprEmit.cpp, the `castSizeStampedTs` and § castTypedParamDeclTs branches)
Surelog's elaboration clones a `P'(x)` cast typespec per use but not its vpiExpr: every copy points at the ONE
ref_obj the declaration's typespec carries (golden comb_dyn_2d_packed_sel: copies ids 89 and 93, both with vpiExpr
id 23, the definition typespec's own), so the walk from a copy through the parameter back to the declaration
typespec meets that reference on its path. Our fresh copy of the reference was re-listed under the parameter
(`depth(1)`, walk diverged). The copy now shares the declaration's reference; a declaration without one keeps the
minted reference. (A first cut that shared the whole typespec made the declaration typespec's record vanish from the
walk and was replaced: golden lists it.) Cases `cst/c1 c4 c5` (+ `c2 c3` controls: one cast, a literal width).

### § lvIdxPathIsRead154 (`R11U154_LVIDXREAD_OFF`; EmitHelpers.h lvIdxPathIsRead154, the general hier-path branch and the MemberAccess branch of emitExpr)
A dotted path inside an lvalue select's index is a READ: `m[sub.adr][7:0] <= d` (mem_ff_partial_rsp) — golden spans
the base at its own token (`sub` 24:25-28) and names the leaf through the select (`work@mem.m.adr`), as the same path
in an rvalue index; ours applied the lvalue convention because the whole left side is emitted under `inLhs`. The
gate is § lvIdxBitSelAtIndex147's (the parent is a select, directly or through operations). Cases `lx/x1 x2 x3 x4
x5` (+ `y1-y4` rvalue controls).

### § lvPathBaseAtFirstMember154 (`R11U154_LVBASEMEM_OFF`; EmitHelpers.h lvBaseAtFirstMember154 + firstMemberTok154, three path branches)
The TARGET of a write through a dotted path with a trailing select spans its base reference on the FIRST MEMBER's
whole token (`sv.wdtxx[3:0] <= x`: `sv` 31-36; `bs.rqq.adr[k +: 2] <= x`: `bs` 31-34), as the bare-member and
struct bit-select branches already do; the struct range-select branch kept the base's own length, the interface branches its
own token. The token is read from the AST's innermost MemberAccess when the base is a plain variable, else from the
path text outside a macro expansion; a path inside a macro expansion keeps pristine's placement (text offsets there
cross buffers: Rggen's `RIF.read_data[__i]` gave `16:30-168:9` in a first cut, measured and fixed before the final
gate; golden anchors those at the macro body's member token, residue 2). Cases `lv/l1 l2 l3 l4 l5 l10 l15 l18
m1 m2`, `hp/f11 f12` (l3, l5 controls; m1, m2 the macro cases, unchanged).

### § lvPathSelNamedByChain154 (`R11U154_LVSELNAME_OFF`; EmitHelpers.h lvSelNamedByChain154)
A written trailing part-select / indexed part-select of an interface path carries vpiDefName and the frozen chain
name (`work@m.bs.wdtxx[3:0].wdtxx`), as the struct branch's part-select already did; the struct branch's written indexed
part-select too, whose base reference (a direct child of the ips) is named by the path
(`work@top.sv.wdtxx[k+:2].k`); a bare-reference ips base no longer exempts the write (`bs.rqq.adr[k +: 2]`). Cases
`lv/l6 l7 l9 l11 l12 l14`, `hp/f13`.

### § lvIfacePathBitSelWhole154 (`R11U154_LVBSSPAN_OFF`; EmitHelpers.h lvIfaceBitSelWhole154)
A written trailing bit-select of an interface path spans the whole element (`wdtxx[2]` 31-39, `adr[2]` 35-41),
as the struct branch's does; a read keeps its index span. Cases `lv/l8 l13`.

### § defPkgStructParamMemberNames154 (`R11U154_DEFPKGTS_OFF`; ParamEmit.cpp makeParamTs, with the listing flag set by emitParameters)
In a DEFINITION listing (module or interface), a parameter typed by a package struct typedef names its members as
the package listing does (`p::p::cfg_t::HSK`), where ours prefixed the parameter's path (`work@tif.CFG.p::cfg_t.HSK`);
elaborated copies keep their use-site names. The member separator is the package's `::`. (The brief's "prefix comes
from makeParamTs into buildStructTs" face: fixed at makeParamTs, buildStructTs untouched.) Cases `np/i3 i4`, `pi/k1`
(+ `np/n1 n2 n5 n6` controls).

### § paramInitUnpackedMemberPath154 (`R11U154_PIUNPACKED_OFF`; ExprEmit.cpp, the MemberAccess branch's paramInitStructMember)
An UNPACKED struct parameter's member read in a parameter initializer takes the packed one's path shape: the base on
the first member's token, the leaf name-only (`localparam int unsigned BYT = CFG.BUS.DAT/8`: `CFG` 7:37-40); the
packed-only gate left the unpacked read on the rvalue shape. Cases `pi/k2 k5`.

### § psBoundPathFirstMember154 (`R11U154_PSBOUNDPATH_OFF`; EmitHelpers.h psBoundPathFirstMember154, the general hier-path branch)
A dotted path that IS a simple part-select's bound takes the written-path shape: base on the first member's token,
leaf name-only (`sub.adr[ADR-1:sub.OFF]`: `sub` 18:32-35; `v[sub.W:0]`, `v[5:sub.OFF]`); compilePartSelectRange
hands its bounds back that way. A path under a bound operation is not claimed (its hier_path name decompiles
differently at stage 1). Cases `pb/b2 b3 b4 b5`.

### § portViewNestedPatTsNamed154 (`R11U154_PVNESTTS_OFF`; ExprEmit.cpp records, ParamEmit.cpp drainPaNameCopySrc38 applies)
In the port view a modport connection builds, the INNER operation of a nested pattern parameter default
(`'{BUS: '{DAT: 32}}`) carries a typespec reference named by the view's path (`work@iface_cfg_mem.u.s`), as the outer
one; ours left it bare. The instance's own listing and definitions keep it bare on both sides. Recorded at mint
time (ExprEmit's nested-pattern bare reference) and named in ParamEmit's dead-last drain, where the port views are
registered (`ifacePortViewMap`, filled after emitInterfaceInstance returns): no sister-ground file is touched.
Case `np/n3`.

## Census (the predictions) and the movers

The census (drivers/tracewrap.sh as SLANG_UHDM over both corpora, both modes, on the final binary; evidence/
census_firings.txt, 133 firings; evidence/census_predicted_rows.txt) predicts 66 row-modes by name, per law:
CASTREF 6, DEFPKGTS 14, GSFOLDTS 6, GSPROCPS 10, HPELEMNAME 2, HPPSBOUND 13, LVBASEMEM 17, LVIDXREAD 13, LVSELNAME 9,
MARGNAME 13, PIUNPACKED 4, PSBOUNDPATH 4, PVNESTTS 20, VARINITDEF 2 (firing lines; LVBSSPAN fires on no corpus row).

Byte verifier (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law `/tmp/r11u154_wdm` vs pristine
`/tmp/r11u154_wdp`, equal-length names; evidence/byteverify_*.txt): surelog 960 paths identical sets, **22 movers**,
selfcheck 959/960; uhdm2rtlil 1608 paths, **28 movers**, selfcheck 1607/1608. **All 50 movers are predicted by name;
none unpredicted.** 16 predicted row-modes do not move (the law fired and wrote the bytes pristine wrote:
ArrayMethodIterator, GenForIfaceLocalparamNestedGen, GenIfIfaceParamStructField, iface_ff_genvar_partsel,
iface_wholestruct_param, struct_array_indexed_write, struct_little_endian_bit_array, struct_part_select_write, both
modes).

Every mover attributed record by record (drivers/moverdiff.sh: the strict comparator's full differing-record set,
pristine vs law, evidence/movers_records.txt): over the 50 movers **406 differing records leave, 0 enter**. The
record-neutral movers: Rggen d (the bound name `work@rggen_apb_adapter.apb_if.paddr[ADDRESS_WIDTH - 1:0].paddr.
ADDRESS_WIDTH` now equals golden's, read from both record dumps; the object is among the differing records on
neither binary), BasicOh t
(gen-scope part-select names take `genblk1`, equal both), rp32_r5p_alu and rp32_r5p_wbu d/t (definition-listing
member names, whole-name comparison count 675 = 675). The UVM family (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard)
moves by law (LVBASEMEM / LVSELNAME / MARGNAME firings), the same -7 in both modes of each, not by the order coin.

Probe: 33 databases move (evidence/probe_movers_records.txt): 210 -> 110 differing records, 102 leave, 2 enter —
both in `r10earl29repro/a4_ctx` (12 -> 10 objects): its lvalue `t.autoexecprogbuf[{1'b1, rq.addr}] = 1'b0` now reads
the index path as a read (§ lvIdxPathIsRead154, the base span record leaves), and the leaf `addr` changes from one
wrong name (name-only) to the rvalue contexts' wrong name (`work@a4_ctx.addr`; golden
`work@a4_ctx.t.autoexecprogbuf[{1'b1,}].autoexecprogbuf.addr` in every context: residue 1c). 18 probe CHANGEs, all
decreases on the same field or a first differing record moved later (`g171_a_pos` #42 -> #131, `gv184_i_minimal` #26
-> #59, `a2_scope` #61 -> #166, `r11u1repro/grid2` #71 -> #403: pdiff.sh), evidence/probe_changes.txt.

## Gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine = main tree `0b3b2d0a…`; law `c9e81a5c…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=15, changes=18; EQUAL 2460 STRICT_NOTEQUAL 1627 (every case judge-equal) |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 5 + 20; changes 15 + 4 (all count decreases on the same field: listed above) |
| (4) downstream (`/tmp/r11u154_dsm`) | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66, not identical and not excused=0; 0 of 871 verdicts differ from results/downstream_uhdm2rtlil.csv; the ten converted uhdm2rtlil tests all IDENTICAL (evidence/downstream_law.txt) |
| (5) uhdm-cmp on touched rows | every touched row-mode and probe case stays judge-equal (CMP_EQUAL / STRICT_NOTEQUAL / EQUAL) |
| (6) byteverify | 22 + 28 movers, all predicted, 0 records enter |
| canaries | r11u107repro/canaries.sh: surelog ok=38 changed=14 (exactly the converted/changed rows above), uhdm2rtlil ok=16 changed=0; ctcan2.sh EXPECT_UNKNOWN=1 surelog ok=58 changed=0 PASS, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2 changed=0 PASS |
| cases | 93 cases: 73 pristine STRICT_NOTEQUAL -> STRICT_EQUAL, 17 equal on both (controls), 3 unchanged (`hp/f14`, `lv/m1 m2`), none worse (evidence/grid_pristine_vs_law.txt) |
| switches | each law's switch alone returns its converted cases to pristine's verdict (73 of 73), controls stay (evidence/switches.txt) |
| `R11U154_OFF=1` | 93 of 93 cases byte-identical to pristine (evidence/offbytes.txt) |

## Sister-ground faces (decoded; the fix sits in a file this pass does not own)

S1 — ComplexParamOverload d/t (N0739, pass-147 R4): a BARE parameter read onto an IMPLICIT-net left side
(`assign o = PadTypeInGeneric;`, `o` undeclared). Golden re-elaborates a fresh elaborated cont_assign whose Rhs is
the elaborated param_assign's own constant (shared, re-parented at the cont_assign) and whose Lhs ref_obj is named by
the instance (`work@top.u.o`) and bound to the definition net; ours shares the definition cont_assign into the
elaborated list. Grid evidence/residue_cases/cpo_a1..a6.sv.txt: every implicit-net form differs, the declared-net
control (a3) is equal. Site: ModuleEmit.cpp emitContAssigns, the block "An implicit-net LHS cont_assign shares the
DEF-view object into the elab list bare" (its computed9 rule admits operations and system calls, not a bare
parameter).

S2 — YosysMarlann d/t (24 objects): a based literal written with a space between the base and the digits (`10'b 0`,
`32'h 8000_0000`): Surelog's preprocessor drops the space and every later object on the line shifts left by its
width (lines 167, 390, 435, 455, 523, 528; the lines without a later object do not differ). Site: UhdmExporter.cpp's
per-line column model (the table § escIdPpColumnShift146 extends).

S3 — MacroArgMismatch d/t: text after a macro use on the same line (`d <= \`D (~d);`) shifts left by one column in
golden. Same site as S2.

S4 — pass-145 R5 (iaw/q02 q06 ae4, usp/u04 u08): `assign o = BY` with an imported package parameter: golden copies
the package parameter's own constant encoding (`INT:4` const type 7 for `S/8`; `BIN:1`, decompile `1'b1`, const type 3
for `logic unsigned P = 1'b1`), ours mints `UINT` from the type. Pinned: ModuleEmit.cpp emitContAssigns, the block
"Typed non-overridden param ref: folded default constant + a ref to the param's typespec".

S5 — GenIfIfaceParamStructField d/t: the definition-view gen-if cont_assign lvalue `assign sub.rsp_sel = sub.sel;`:
golden's base `sub` spans the first member's token (16:18-25), leaf name-only — the written-path shape
§ lvPathBaseAtFirstMember154 lands for ExprEmit — but this listing is emitted by TypeEmit.cpp emitSyntaxExpr
(emitDefGenStmts).

S6 — a POSITIONAL modport connection (`mem u(b.sub, clk)`): the elaborated port's high_conn hier_path `b.sub`:
golden base on the `sub` token, leaf name-only; ours `b` at its own token, `sub` named `work@top.u.sub.sub`. Minted
in ModuleEmit.cpp emitInstance (the high_conn builder for an interface modport actual). The named form and a bare
interface actual agree (the lx cases were rewritten to `mem u(b, clk)` for that reason).

S7 — r11u153's N11 (evidence/residue_cases/esc_y16_hash.sv.txt, `\W#1 `): exit 134 is an uncaught std::runtime_error
thrown by slang's Compilation::parseName inside Scope::lookupName, called from ModuleEmit.cpp mintUnitEnumNets (the
syntax-walk lambda looks up every IdentifierName's text). A `Scope::find` there, or a top-level catch in
uhdm_main.cpp that exits 3, makes it a clean SLANG_REJECT. Surelog also fails the source (no golden).

S8 — YosysBigSimEllip d (fullname 2941: 266 ref_obj + 134 part_select): the high_conn part_select of an instance
inside a generate scope is named `…label[0].A`, golden `…label[0].m.A.A` (instance + port + select): ModuleEmit.cpp
emitInstance's port connection builder (the family of pass-147's S3, genscope_module_ctx_reset).

## Decoded, not landed (ranked residues on this ground)

1. Names inside selects not yet modelled: (a) InterfArrayBind d — the elaborated interface-array element index in the
   DEFAULT (non-`-elabuhdm`) view is named `work@soc_tb.io_gen[0].peripheral_io_bus[io_idx].write_en.io_idx` in
   golden, ours `work@soc_tb.io_gen[0].io_idx` (the testflags view is equal: UHDM's ElaboratorListener recomputes it);
   the general hier-path branch's genvar-index element, which has no elaborated-listing flag; (b) portsel_struct_param,
   expr_width_cast: a struct-parameter member path inside a port-connection part-select bound / a cast width (base on
   the member token, leaf unnamed): TypeEmit/ModuleEmit callers per map 6; (c) `r10earl29repro/a4_ctx`: a path inside
   a concatenation index of a member select is named through the select in golden in every context.
2. Macro-argument lvalue paths (`lv/m1 m2`, Rggen's tie-off macro): golden anchors the base on the member token
   inside the macro BODY; ours keeps pristine's placement (a location model across macro buffers is needed).
3. anon_struct_packed_dim d/t (N0820, 43 objects): the member references of a package struct typedef reached
   through two members of an anonymous struct are named `gpte.pte_t.ppn` for both in golden (the last writer's
   copy); ours share the declaration's names. TypeEmit.cpp buildStructTs.
4. packed_struct_array_fifo d/t (6): the struct typespec's end line and member names of a typedef copy (TypeEmit).
5. iface_zero_width_field d/t (4): a PACKAGE parameter's typespec copy names its members `p::B.p::bus_t.CTL`, golden
   `work@top.p::bus_t.CTL` (the elaborated use site): ParamEmit's package parameter path, not the definition rule
   § defPkgStructParamMemberNames154 covers.
6. `hp/f14`: a function argument's struct typespec located at the typedef, golden at the argument's type token.
7. Not reached this pass: pass-147 R3c/e/f (`tsi/a6` folded index, `pos/n5`, `mec/f02 f03`), the `3'd4` member-select
   decompile (`brk/mec/c1`), the package-struct member read fold (`assign o = Cfg.mode`), pass-145 V5, r11u151's
   R-D2/R-D3/R-ARR2 and the `p::D` endcol, r11u153's non-int default fill, kept-call callee, narrower own-copy and
   reduction folding.

## Cases (first line of every case names its law; pristine / law verdicts in evidence/grid_pristine_vs_law.txt)

| grid | cases | law | pristine -> law |
|---|---|---|---|
| hp | f1 f2 f3 f8 f9 f10 f15 f18 f19 | § hpPartSelBoundNamesBySelect154 | fullname -> STRICT_EQUAL |
| hp | f7 | § hpPartSelBoundNamesBySelect154 (control: indexed part-select) | equal -> equal |
| hp | f14 | § hpPartSelBoundNamesBySelect154 (name face cleared; residue 6 stays) | line -> line |
| hp | f17 | § hpElemSelNameIsPathSoFar154 | fullname -> STRICT_EQUAL |
| hp | f11 f12 | § lvPathBaseAtFirstMember154 | endcol -> STRICT_EQUAL |
| hp | f13 | § lvPathSelNamedByChain154 | col -> STRICT_EQUAL |
| gs | g1 g_nd g_ud | § genScopeProcPsNamedByScope154 | fullname -> STRICT_EQUAL |
| gs | g2 g_la g_lb g_lc g_le g_lf g_na g_nb g_nc g_ne g_nf g_ua g_ub g_uc g_ue g_uf | § genProcFoldTsKeepsScope154 | fullname -> STRICT_EQUAL |
| gs | g_ld | § genProcFoldTsKeepsScope154 (control: ips base) | equal -> equal |
| sm | s3 s4 s6 s8 v5 | § builtinMethodArgNamedByPath154 | fullname -> STRICT_EQUAL |
| sm | s7 | § builtinMethodArgNamedByPath154 (control: literal argument) | equal -> equal |
| sm | s1 s2 s5 v4 | § varInitStrMethodArgDefNet154 | fullname -> STRICT_EQUAL |
| sm | v1 v6 | § varInitStrMethodArgDefNet154 (controls: plain reference, queue method) | equal -> equal |
| cst | c1 c4 c5 | § elabCastSharesDeclRef154 | depth -> STRICT_EQUAL |
| cst | c2 c3 | § elabCastSharesDeclRef154 (controls) | equal -> equal |
| lx | x1 x2 x3 x4 x5 | § lvIdxPathIsRead154 | col -> STRICT_EQUAL |
| lx | y1 y2 y3 y4 | § lvIdxPathIsRead154 (controls: rvalue index) | equal -> equal |
| lv | l1 l2 l4 l10 l15 l18 | § lvPathBaseAtFirstMember154 | endcol -> STRICT_EQUAL |
| lv | l3 l5 | § lvPathBaseAtFirstMember154 (controls) | equal -> equal |
| lv | m1 m2 | § lvPathBaseAtFirstMember154 (macro cases: pristine placement kept; residue 2) | col -> col (m1 identical records; m2 4 -> 2 objects) |
| lv | l6 l7 l9 l11 l12 l14 | § lvPathSelNamedByChain154 | col/endcol -> STRICT_EQUAL |
| lv | l8 l13 | § lvIfacePathBitSelWhole154 | col -> STRICT_EQUAL |
| np | i3 i4 | § defPkgStructParamMemberNames154 | fullname -> STRICT_EQUAL |
| np | n1 n2 n5 n6 | § defPkgStructParamMemberNames154 (controls) | equal -> equal |
| np | n3 | § portViewNestedPatTsNamed154 | fullname -> STRICT_EQUAL |
| pi | k1 | § defPkgStructParamMemberNames154 (module definition) | fullname -> STRICT_EQUAL |
| pi | k2 k5 | § paramInitUnpackedMemberPath154 | col/fullname -> STRICT_EQUAL |
| pb | b2 b3 b4 b5 | § psBoundPathFirstMember154 | col -> STRICT_EQUAL |

evidence/residue_cases/ holds sources that decode sister faces or residues (not cases: `cpo_a1..a6.sv.txt` S1,
`esc_y16_hash.sv.txt` S7).

## Ops notes (disclosed)

* Seventeen law binaries were built in turn (law1..law17); intermediate full sweeps (law1, law3, law5, law7, law9,
  law10, law12, law15) found and removed one regression before landing: the first cut of § genProcFoldTsKeepsScope154
  (law3) moved BasicOh testflags off CMP_EQUAL and ibex_register_file_ff 31 -> 62 by dropping the instance name also
  for a bare part-select bound; refined to the operand-position rule (law5) and re-measured. The law15 gate read
  clean, but its database for Rggen showed a garbage span (`16:30-168:9`) on the macro-argument path, so the lvalue
  base law was hardened (law17, AST token / no macro offsets) and every gate above re-run on law17.
* Two background waiters of mine polled with a self-matching `pgrep`; I killed them by PID after reading their
  command lines (both mine). No other process was touched.
* The census ran verify_golden.py's corpus stage directly (the invocation tests/sweep.sh makes), dispatching every
  row; its log was filtered by `$FENCED` before reading.

## Files

* drivers/rc.sh, cx.sh, ctx.sh, anc.py, grid.sh, allgrid.sh — scratch-case golden + verdict, record context.
* drivers/pin.sh — the mint site of one of our strict records (gdb on the `-g1` pristine, objrank rank).
* drivers/rowdump.sh — every STRICT_NOTEQUAL row-mode's strict records (fence-guarded).
* drivers/tracewrap.sh — the census stand-in (R11U154_TRACE).
* drivers/moverdiff.sh, pdiff.sh, pgold.py — mover attribution, probe case comparison.
* drivers/switches.sh, offbytes.sh — per-law switch check, `R11U154_OFF=1` byte check.
* drivers/row.sh — the harness on named rows.
* evidence/ — the files named above.
