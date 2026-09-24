# r11u144 — the module/type ground on the strict axis, fourth round: the --elabuhdm instance-tree clones, bare decimals on a select, folded call spans, folded-bound and alias-bound names, type-parameter packed nets, class method spans, generate-block member paths

Pair B implementer pass (refill after pass 137). Base `6ef15be0` (branch matrix-1.87). Ground: `src/ModuleEmit.cpp`,
`src/TypeEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`, `uhdm_main.cpp` (the patch touches no other
source file and no header). Worktree `/tmp/wt_r11u144`, system-deps config, `-j 2`. The fifth map edition
(`tools/probe/r11u142map`) did not exist when this pass ran; the clusters were re-measured at the base from this
pass's own pristine sweep (every strict-NE row's first eight differing records, `drivers/row.sh`).

| binary | md5 | what |
|---|---|---|
| pristine | `614337e4c8d4b8833fe5c71262db8aae` | the base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `10c1d04958343953d85c6a94a9f16172` | this patch (all ten laws) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | the main tree's (= the worktree's build) |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | MEASUREMENT ONLY: tools/probe/r11u138map/drivers/strictcmp_x.cpp (raw full names in the record dumps) |
| `g1` | `0ee58f918b49f8229665cbe94f356b51` | the pristine source with `-DCMAKE_CXX_FLAGS=-g1`, for gdb pinning only (drivers/pin.sh) |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u144_bin/`) before it measured anything; every sweep
exported `SLANG_UHDM` and `STRICT_CMP` to the frozen copy (drivers/sweep.sh; the cmds.txt of every corpus run
names the frozen binary). Sweeps: pristine `/tmp/r11u144_wdP`, law `/tmp/r11u144_wdC` (same-length names for the
byte verifier), downstream `/tmp/r11u144_dsL`. Law names are written `§ <name>` in the source, here and in every
case's first line.

## 1. Verdict per target

| target (brief item) | before -> after | law |
|---|---|---|
| (1) net-binding leftovers: PortExpr, ExplictiPorts | not landed: decoded (section 7, R1), the faces are the escaped-identifier column model and the port-expression reference locations, not a net-binding road | — |
| (2) elab-clone leftovers: CarryAdd t, SequenceInst t, GenScopeHierPath3 t | fullname(2) / fullname(6) / fullname(163) -> `equal` (all three) | § elabCloneInstTreeUnstored144 |
| (2) HierPathTypespec t | fullname(1) unchanged: the listener binds the member of `pkg::b`'s element COPY in golden (`pkg::pkg::b::pkg::a::x`), ours shares `pkg::a` (typespec identity at a ref_obj Actual; residue R2) | — |
| (3) N0270 packed_struct_array_fifo | endline(2) -> fullname(8), UNMASK (the walk no longer diverges: the net binds the type parameter's default `d_t` with the moved end; what remains is the elaborated `d_t` copy and a part-select index name, section 7 R3) | § defNetTypeParamPackedDim144 |
| (3) N0270 packed_array_struct | unchanged: `localparam type` defaults are built by ParamEmit.cpp (sister, S3) | — |
| (3) N0084 / N0638 / N0096 | not landed (residue R4: golden parents the default struct at the LAST net and names the member refs by that chain) | — |
| (4) N0281 ParameterOfParametrizedType, ...InSubmodule (u2r, both modes), UnsizedParam | fullname(3) / fullname(5) -> `equal` (both modes); UnsizedParam t fullname(6) -> `equal`, UnsizedParam d fullname(8) -> fullname(2) (the rest is the default instance sharing the definition's implicit-net cast, R5) | § paramAliasBoundRefUnstored144 |
| (4) N0078 PackStructVar (both modes) | fullname(5) -> `equal` | § pkgTsForeignQualRefUnstored144 |
| (4) the TypeEmit twin of pass 133's hier_path laws, definition-view generate paths: iface_array_modport_drive, genvar_iface_struct | endcol(2) -> `equal` (both modes); genvar_iface_struct endcol(3) -> fullname(1) (the remaining `IFN` reference is ExprEmit's, S4) | § defGenLhsHpBaseAnchor144 |
| (4) N0008 ParameterInitializedByPartSelectOfParametersAssignedToVar (both modes) | fullname(1) -> `equal` | § foldedBoundTsRefUnstored144 |
| (4) N0008's ibex face and the struct-parameter base spans | decoded, sister's sites (S1, S2) | — |
| (5) non-pure virtual function with a body; the attribute start of a prototype | ClassTypeParam d endline(26) -> (25), t file(39) -> (38); SVSwitch d/t endcol(37) -> (33); the UVM rows' method spans move to golden (section 6); v11u137 break cells f04, f05 -> `equal` | § classMethodQualSpan144, § methodSpanSkipsAttrs144 |
| (5) PkgParamAsFunctionArg (both modes) | endcol(1) -> `equal` | § callFoldFormalBitSelLoc144 |
| (5) IndexAssign (both modes) | decompile(1) -> `equal` | § caSelLhsBareDecNoAdjust144 |
| (5) replication in a concatenation actual, package bit_typespec name, type-parameter port copies, PreprocTest, port-view fold span | not landed (R6-R8, S5) | — |
| (6) UVM/Earlgrey-only clusters | not landed (R9); the method-span law moves 4800-6800 order-blind dump lines per UVM row toward golden | — |

**CONVERSIONS (loud): 8 surelog row-modes, 10 uhdm2rtlil row-modes, 13 probe cases turn `STRICT_NOTEQUAL` ->
`CMP_EQUAL` / `EQUAL`. results/ untouched.** The fresh csv rows of the law sweep read `<name>,<mode>,CMP_EQUAL,,,equal`
for (evidence/cols_P_L.tsv holds every changed row with its old cell):

    surelog: CarryAdd testflags, GenScopeHierPath3 testflags, SequenceInst testflags, UnsizedParam testflags,
      IndexAssign default + testflags, PackStructVar default + testflags
    uhdm2rtlil, both modes: iface_array_modport_drive, ParameterInitializedByPartSelectOfParametersAssignedToVar,
      ParameterOfParametrizedType, ParameterOfParametrizedTypeInSubmodule, PkgParamAsFunctionArg

Probe cases turned `EQUAL`: r10earl109repro/g2_stale109, r10earl_repro/l, r10earl_repro/wh, r10sd3repro/g8_pkg_virtual_extends,
r10svs3repro/a2_thisnew, r10uvm10repro/t6, r10uvm12repro/t, r10uvm57repro/a7_forkfor, r10uvm69repro/v1_gaps,
r10uvm71repro/a2_site, r10v133repro/v133_h_more, r10v141repro/v141_d_owners, r10vearl115repro/w4_selmem.

Downstream: the five converted uhdm2rtlil tests (both modes) and the two moved-but-not-converted ones read
IDENTICAL in the law's downstream sweep (fresh rows, `name,verdict,surelog_status,slang_status,differs`):

    PkgParamAsFunctionArg,IDENTICAL,NO_GATES,NO_GATES,
    ParameterInitializedByPartSelectOfParametersAssignedToVar,IDENTICAL,NO_GATES,NO_GATES,
    ParameterOfParametrizedType,IDENTICAL,NO_GATES,NO_GATES,
    ParameterOfParametrizedTypeInSubmodule,IDENTICAL,NO_GATES,NO_GATES,
    iface_array_modport_drive,IDENTICAL,READ_FAIL,READ_FAIL,
    genvar_iface_struct,IDENTICAL,OK,OK,
    packed_struct_array_fifo,IDENTICAL,OK,OK,

## 2. The laws (each droppable alone; `R11U144_OFF=1` drops all ten and restores the pristine bytes)

| law | switch | site (file + token) | rule |
|---|---|---|---|
| § elabCloneInstTreeUnstored144 | `R11U144_ELABINST_OFF` (the instance trees), `R11U144_ELABPROP_OFF` (the property/sequence instance chains) | uhdm_main.cpp, inside elabCloneFullNameUnstored137 | UHDM's ElaboratorListener also clones out of the ELABORATED instance trees (it re-elaborates every generate scope, giving a hier_path over a generate array its fresh `bit_select` element) and turns an assertion's unparented property/sequence instance into a parented clone. § elabCloneFullNameUnstored137's equality test (a stored name equal to the object's own chain is left unstored, which no un-cloned view can observe) now covers the `topModules` subtrees and every object whose chain ends at an unparented `property_inst` / `sequence_inst`: golden `…STAGE[i - 1].C.STAGE.i` where ours copied `…C.i` (CarryAdd), `…temp.inner.CHUNK` (GenScopeHierPath3), `work@m.a1.p_triggers.a` where ours copied `p_triggers.a` (SequenceInst) |
| § caSelLhsBareDecNoAdjust144 | `R11U144_SELBAREDEC_OFF` | ModuleEmit.cpp emitContAssigns (the re-emitted bare-literal resize) | UhdmWriter::writeCont_assign hands the reduced Rhs to CompileHelper::adjustSize with the Lhs's TYPESPEC; a bit-select or part-select Lhs of a packed vector carries none, so a bare decimal keeps `3`, `UINT:3`, size 64 in the elaborated view (IndexAssign `assign sig[I-7] = 3;`, where ours truncated to the select width). A whole-net Lhs still truncates (`74` on a 1-bit net -> `UINT:0`), a member-select Lhs and an unpacked element were already right |
| § callFoldFormalBitSelLoc144 | `R11U144_CALLBITSEL_OFF` | ModuleEmit.cpp emitContAssigns (the callFold constant, beside the assignment-pattern element location) | a function whose result is a bit select of a FORMAL folds through UHDM `ExprEval::reduceBitSelect((constant*)object, …)`, which ends `c->VpiFile/LineNo/ColumnNo/EndLineNo(op->…); c->VpiEndColumnNo(op->VpiColumnNo() + 1)` over the reduced ACTUAL: a literal actual lends its file and start and a one-column end (`get_first(2'b10)` -> 5:25-5:26); a package parameter initialised by a concatenation reduces to an unlocated constant, so the fold reads 0:0-0:1 with no file (PkgParamAsFunctionArg) |
| § foldedBoundTsRefUnstored144 | `R11U144_FOLDTSNAME_OFF` | TypeEmit.cpp makeTypespec, the packed builder's `rt0` beside § foldedBoundTsIsTheSignednessCapture48 | Surelog's identifier case (CompileExpression.cpp, the `sval->isSigned()` block) writes `rt->VpiParent(c); rt->Actual_typespec(ts)` and no name, so the folded bound's reference reads its chain; golden's typespec there is an unparented copy and the name is EMPTY where ours stored the owner's (`work@top.max_value`, map N0008). A declaration inside a generate block keeps the name (golden parents the typespec at the variable there: ibex_counter's `logic [63:CounterWidth] unused_counter_load`, grid fb/b) |
| § defNetTypeParamPackedDim144 | `R11U144_TPPACKEDNET_OFF` | ModuleEmit.cpp materializeDefNetTs, before § defNetTypeParamDefault137 | a definition net typed by a type-parameter name carrying PACKED dimensions (`dtype [FifoDepth-1:0] mem_n, mem_q;`) binds the parameter's default object (compileTypespec answers the name with the default and never wraps the written packed dimensions), and writeNets' end-only populate (`dimensions = getUnpackedDimension(); if (!dimensions) dimensions = getPackedDimension();`) moves its end to the first packed dimension's end, the last net declared winning (packed_struct_array_fifo: `d_t` 1:9-24:24). Gated to a struct/union default: an enum or vector default sizes the `'0` Rhs from the bound typespec (grid tq d3, d7 are judge-visible and not modelled) |
| § paramAliasBoundRefUnstored144 | `R11U144_PARAMALIASREF_OFF` | TypeEmit.cpp, the flag `paramAliasBoundUnstored144` (set in makeTypespec, read in emitSyntaxExpr's plain-reference case) | the typedef CLONE a parameter's typespec takes (`typedef logic [X-1:0] my_type_t; parameter my_type_t Y`): Surelog's plain-identifier case stores no full name (`ref->VpiName(n); ref->VpiParent(pexpr);`), so golden's bound reference reads its chain through the clone (`work@top.Y.my_type_t.X`) where ours stored the parameter prefix (`work@top.Y.X`); our chain reads the same path, so the reference is left unstored (map N0281) |
| § pkgTsForeignQualRefUnstored144 | `R11U144_PKGQUALREF_OFF` | TypeEmit.cpp emitSyntaxExpr, the qualified-name `ref_obj` case | inside a typespec a PACKAGE holds, a reference qualified by ANOTHER package carries no stored name in golden: it reads its chain (`tlul_pkg::tlul_pkg::tl_h2d_t::d_size::top_pkg::TL_SZW`, PackStructVar, map N0078) where ours stored the qualified name itself (equal to vpiName, which the VPI reports as no full name at all) |
| § classMethodQualSpan144 | `R11U144_METHQUALSPAN_OFF` | TaskFuncEmit.cpp emitTaskFuncs (the class-method span, beside the static-qualifier rule) | a class FUNCTION written with class-item qualifiers spans its FIRST qualifier token, `virtual` included (`virtual function void f();` 2:3-2:10; `virtual protected function` on `virtual`), while a class TASK spans the whole declaration whatever its qualifiers (`static task`, `protected virtual task`, `virtual protected task` 2:3-3:10). The pristine rule collapsed only on `static`/`local`/`protected` (tasks included) and spanned a `virtual` function whole |
| § methodSpanSkipsAttrs144 | `R11U144_METHATTR_OFF` | TaskFuncEmit.cpp, the pure-virtual prototype span (§ pureVirtProtoSpan137's site) and the whole-declaration method span | an attribute instance is not part of a method's span: golden starts at the first qualifier (`(* keep *) pure virtual function int f;` 2:14; `(* keep *) virtual task t();` 2:14-3:10; v11u137's f04) |
| § defGenLhsHpBaseAnchor144 | `R11U144_DEFGENHP_OFF` | ModuleEmit.cpp emitDefGenStmts (after the Lhs `emitSyntaxExpr`) | the definition view's generate-block assignment whose Lhs is a member path over a base selected by a plain index name (`man[i].vld`, `s[i].f` in a genvar loop) is anchored at the BASE-name token (golden 11:12-11:15) and its leaf carries the raw dotted path (`man[i].vld`): the shape emitSyntaxExpr's genvar-base case gives, which its symbolic-index case (it takes every selected base first) did not. An Rhs path keeps the whole span (grid hg/e), an expression index (`s[i+0].f`, hg/d) is not modelled |

The switch helper `r11u144Law` is defined in UhdmExporter.cpp beside `r11u137Law` and declared file-locally at each
user; no header is touched.

## 3. Decode notes (Surelog v1.87 / UHDM, third_party/Surelog/src)

* **Instance-tree clones.** Under `-elabuhdm` golden's generate-scope hier_path gains a `bit_select` element
  whose child index reads `…STAGE[i - 1].C.STAGE.i` (BaseClass::ComputeFullName: a ref_obj under a bit_select
  under a hier_path is not skipped when the child is an operation), and a property instance's clone is parented at
  its assertion. Our instance-tree objects stored names equal to their own chains; the clones copied them
  (DeepClone begins `*clone = *this`). Measured with drivers/pchain.cpp (parent chains of both producers).
* **Select Lhs.** `adjustSize(tps, …)` with `tps` the Lhs's typespec: a bit/part select has none. Grid ia: 17 shapes.
* **Folded call bit select.** third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp, reduceBitSelect's tail
  (`c->VpiEndColumnNo(op->VpiColumnNo() + 1)`); the evalFunc case calls it with the reduced actual.
* **Folded-bound and alias-bound references.** CompileExpression.cpp: the StringConst case (`ref->VpiName(n);
  ref->VpiParent(pexpr)`) and the signed-fold case store no full name. Every such golden name is a chain name, so
  the laws leave ours unstored exactly where our chain equals golden's (grid fb/b is the generate counter-example).
* **VPI and a stored name.** `ref_obj::GetVpiPropertyValue(vpiFullName)` returns nothing when the full name EQUALS
  vpiName: PackStructVar's stored `top_pkg::TL_SZW` read as an empty name in the strict records.
* **Type-parameter packed nets.** UhdmWriter.cpp writeNets (`populateCoreMembers(InvalidNodeId, dimensions, ts)`
  with the packed dimension as the fallback), grid tq (two nets: the later one's dimension wins).
* **Method spans.** Measured on golden (grid vf, at): the function/task split and the first-qualifier start.
* **Pins** (drivers/pin.sh over the g1 binary, `objrank` for the creation rank): IndexAssign's Rhs constant
  (ExprEmit.cpp emitExpr < ModuleEmit.cpp emitContAssigns), the folded call constant (ModuleEmit.cpp
  emitContAssigns), the parameter alias clone's reference (TypeEmit.cpp emitSyntaxExpr < makeTypespec <
  ParamEmit.cpp makeParamTs), the qualified reference (TypeEmit.cpp emitSyntaxExpr < makeTypespec < buildStructTs
  < ParamEmit.cpp emitPackage), the definition-view generate hier_path (TypeEmit.cpp emitSyntaxExpr < ModuleEmit.cpp
  emitDefGenStmts), and the sister-ground sites in section 7.

## 4. Grids (grid/, every case names its law in its first line)

Scored per cell by drivers/case.sh (Surelog `-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0`, ours `dut.sv
--single-unit --nobuiltin`; grid el adds `-elabuhdm` / `--elabuhdm` on both sides); drivers/grid.sh runs them all.
Full tables: evidence/grid_pristine.txt, grid_law.txt, grid_law_off.txt (with `R11U144_OFF=1`: pristine bytes on 84
of 84 cells). Every cell keeps its rc and uhdm-cmp line count across the three runs.

| grid | law | cells | judge-equal | strict-equal pristine | strict-equal law |
|---|---|---|---|---|---|
| ia (bit/part/member/unpacked selects, whole net, sized/based/`'d` literals, sub-module, nested select, `+:`) | § caSelLhsBareDecNoAdjust144 | 17 | 17 | 9 | 17 |
| pf (literal / package-concat / local-param / package-literal actuals, `x[0]`, whole return, part select) | § callFoldFormalBitSelLoc144 | 7 | 3 | 0 | 3 |
| fb (module var, generate var, net init, sub-module, gen-for, procedural) | § foldedBoundTsRefUnstored144 | 6 | 4 | 2 | 4 |
| el (--elabuhdm: property instance, generate hier path, nested generate, sequence instance, procedural assertion) | § elabCloneInstTreeUnstored144 | 5 | 4 | 0 | 4 |
| tq (header type parameter: inline struct, both dims, vector, typedef default, two nets, one declaration, enum, sub-module) | § defNetTypeParamPackedDim144 | 8 | 5 | 0 | 4 (d1: member names, R4) |
| pt (module / sub-module / localparam / two-param bound / alias of alias / net control / bare bound) | § paramAliasBoundRefUnstored144 | 6 | 5 | 1 | 5 |
| qb (package struct / module net / module struct / package vector typedef / bare bound / unused / same package / package parameter / enum base / nested struct) | § pkgTsForeignQualRefUnstored144 | 10 | 6 | 1 | 5 (c: the module-struct folded span, R7) |
| vf (virtual/static/local/protected functions and tasks, qualifier orders, package class, override, extern) | § classMethodQualSpan144 | 15 | 13 | 5 | 13 |
| at (attributes on pure virtual function/task, virtual function, plain function, virtual task, two attributes) | § methodSpanSkipsAttrs144 | 6 | 6 | 1 | 6 |
| hg (struct array in genvar loop, interface array modport, expression index, Rhs control) | § defGenLhsHpBaseAnchor144 | 4 | 4 | 1 | 3 (d: expression index) |
| total | | 84 | 67 | 20 | 64 |

**Switches** (drivers/switches.sh, evidence/switches.txt): each single switch moves back exactly the cells of its
own grid, to the pristine bytes; the one cell two laws share is at/fc (`(* keep *) virtual function`, owned by
§ classMethodQualSpan144 and § methodSpanSkipsAttrs144). NOT_EQUAL cells a law touches keep their uhdm-cmp count
(pf/b 26, qb/e 50, qb/h 64, vf/l 13, fb/c 17).

## 5. Census: the strict column, law sweep vs pristine sweep, row by row (evidence/cols_P_L.tsv, prefix_P_C.txt)

| corpus | judge-equal row-modes | strict-equal pristine | strict-equal law |
|---|---|---|---|
| surelog | 954 (480 + 474) | 772 | 780 |
| uhdm2rtlil | 1606 (803 + 803) | 1384 | 1394 |
| probe cases | 4087 | 2272 | 2285 |

Changed and not converted: surelog 11 row-modes, uhdm2rtlil 4, probe 21. drivers/prefix.py compares, for each,
the complete differing-record lists of golden-vs-pristine and golden-vs-law: **no record the pristine walk matched
(before its structural divergence) differs in the law walk, on any of the 36**: 33 IMPROVE (the law's differing
records are a subset of the pristine's: ClassTypeParam d/t, Earlgrey_0_1 d/t 1051 -> 1041, InterfArrayBind t,
SVSwitch d/t, UnsizedParam d, YosysBigSimEllip d, YosysOldOr d/t, genvar_iface_struct d/t and 20 probe cases), 3
UNMASK (the pristine walk diverged and the law walk reaches further: packed_struct_array_fifo d/t endline(2) ->
fullname(8) — the definition net now binds the default `d_t` and the walk finds the elaborated copy's names and
`FifoDepth[ADDR_DEPTH:0]`'s index name; probe r11u112repro/grid/k/k20_hdr_param_type_ctl endline(3) -> (2)). No
status changes, no row leaves `equal`. An interim sweep caught § foldedBoundTsRefUnstored144 worsening
ibex_counter d/t fullname(1) -> (2) (a generate-block variable); the law now keeps the name inside a generate block
(grid fb/b) and the row reads its baseline cell again.

## 6. Gates

1. build: pristine `614337e4c8d4` (= main tree), law `10c1d0495834`.
2. probe: `EQUAL=2285 STRICT_NOTEQUAL=1802 (of 4087)`, `regressions=0 conversions=13 changes=21`; every case
   uhdm-cmp equal (the gate's own check). Pristine sweep: `regressions=0 conversions=0 changes=0`.
3. corpora: surelog `[default] CMP_EQUAL=391 … STRICT_NOTEQUAL=89`, `[testflags] CMP_EQUAL=389 … STRICT_NOTEQUAL=85`
   (`regressions=0 conversions=8 changes=11`); uhdm2rtlil `CMP_EQUAL=697 CMP_NOTEQUAL=1 SLANG_REJECT=67
   STRICT_NOTEQUAL=106` both modes (`regressions=0 conversions=10 changes=4`). The judge-equal scoreboards stay
   480/3 + 474/3 and 803/1/67. The own pristine sweep reads regressions=0 conversions=0 changes=0 in all three.
   The sweeps' rc=1 is `law index STALE`, which the base itself reads (tests/LAWS.md is regenerated with this
   patch; `law_index.py --check` reads current after).
4. downstream (law): `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`;
   verdict AND `differs` identical to results/downstream_uhdm2rtlil.csv on 871 of 871 rows (evidence/downstream_law.csv);
   the converted rows and the pass-120/125/130/134/137 rows unchanged.
5. uhdm-cmp: every corpus row keeps its status, every probe case and grid cell its uhdm-cmp verdict and count.
6. byteverify (`SELFCHECK=1`, same-length workdirs): PATH_SETS_IDENTICAL both corpora, SELFCHECK 959/960 and
   1607/1608; MOVERS 32/960 + 14/1608 = 46 byte movers, one per row-mode database (v11u144 correction: the evidence files read 32 and 14) (evidence/byteverify_*.txt).
   PREDICTED from the pristine rows' sources and command lines before the mover set was read
   (drivers/predict.py, evidence/predict_pristine.tsv; the fenced tests are skipped by `$FENCED`): 44 of 46
   predicted; the two others, EvalFunc t and StringRange t, are --elabuhdm rows whose uhdm-dump text is identical
   (0 order-blind lines): § elabCloneInstTreeUnstored144 unstored names equal to their chains, which changes the
   file's bytes and no read value (both restore the pristine bytes under `R11U144_ELABINST_OFF` alone).
   Attribution (drivers/attrib.py, evidence/attribution.txt): under `R11U144_OFF=1` 40 of 46 give the pristine bytes
   back, and each of those but Earlgrey_0_1 d/t, SeqDriver t, SimpleUVM t has a single owning switch. Earlgrey_0_1
   is byte-deterministic: run with ONE law on at a time (drivers/attrib3.py, evidence/attribution_earlgrey.txt) its
   bytes move under § foldedBoundTsRefUnstored144, § pkgTsForeignQualRefUnstored144 and § defGenLhsHpBaseAnchor144
   (testflags also § elabCloneInstTreeUnstored144); the prediction named the row (its folded bounds) but not the
   other three faces, because the source scan reads only the test's own directory and Earlgrey's sources live in
   its file lists. SeqDriver t and SimpleUVM t are UVM coin rows as below. The six others are
   the UVM order coin (MiniAmiq d/t, Scoreboard d, SeqDriver d, SimpleUVM d: `R11U144_OFF` leaves 2-6
   order-blind dump lines, every single switch but `R11U144_METHQUALSPAN_OFF` the same 2-6, and only
   § classMethodQualSpan144 moves thousands, evidence/attribution_multi.txt). No row outside the prediction moves,
   none of the four slang-fenced tests moves.
7. canaries: `canaries.sh` law vs pristine: surelog ok=44 changed=8 (Earlgrey_0_1 d/t, YosysOldOr d/t, ClassTypeParam
   d/t, SVSwitch d/t — all IMPROVE, section 5), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh`
   results/golden_surelog.csv: PASS ok=58 changed=0; `EXPECT_UNKNOWN=6` results/golden_uhdm2rtlil.csv PASS ok=2.

## 7. Residues, ranked

**Sister's ground (decoded, not landed; call sites named):**
* **S1 the ibex family's two faces** (ibex_alu, ibex_branch_predict, ibex_compressed_decoder, ibex_decoder,
  ibex_icache, ibex_multdiv_fast, ibex_multdiv_slow, ibex_wb_stage: 16 row-modes whose ONLY faces are these two;
  also Kmac d/t, NestedStructArrayParameterInitializedByPatternPassedAsPort, StructArrayParameterInitializedByPattern
  PassedAsPort, param_struct_field_bitsel, param_unpacked_struct_array): an unpacked-array PARAMETER
  (`parameter logic [PMP_ADDR_MSB:0] PmpAddrRst[PMP_MAX_REGIONS]`). (a) ParamEmit.cpp makeUnpackedArrayParamTs
  hands the array_typespec the parameter's OWN `range` object (range 4's parent is the parameter, and the array
  typespec's Ranges hold it): golden copies it, so the walk meets `range` where ours meets the element reference
  (`differ:type`); (b) the element's folded bound constant takes its ref_typespec from TypeEmit.cpp
  crossPkgBoundFoldConst9 (called by makeUnpackedArrayParamTs's `foldSubst9`), which stores `paramTsOwnerFull9`
  (`ibex_pkg::PmpAddrRst`) where golden's chain ends at an unparented element copy (empty). (b)'s site is this
  ground's, but golden gives the SAME object a parented copy in the module listings (`work@top.R`), so the name can
  only be left unstored once (a) gives our module copy its own parented element: land (a) first, then (b).
* **S2** LocalParamInNestedForLoops: the pattern element constant's ref_typespec (`'{0, 1}`, golden empty, ours
  `work@top`) is ParamEmit's; its second face (the gen-scope cont_assign's folded Rhs shares the param_assign's
  constant object, golden copies it) sits in ModuleEmit's generate cont_assign fold.
* **S3** packed_array_struct: a body `localparam type my_t = struct packed {…}` has no header declarator, so
  ParamEmit.cpp emitParameters' `defTypeSyn` stays null: no `typeParamDefaultTs` entry (the net builds a
  logic_typespec at its use) and the default spans `struct packed` where golden spans `struct` (grid tp).
* **S4** genvar_iface_struct's remaining `IFN` reference (`work@dut.m.IFN` vs `work@dut.IFN`), ibex_counter's
  part-select bound name, ParamFromPackage's param_assign constant reference, ComplexExprSize / HierPathStructTypespec
  / StructUnsizedVal constant spans: ExprEmit.cpp / ParamEmit.cpp.
* **S5** the port-view parameter fold span (pass 133 R4) and IntegerConcat's parameter int_typespec: ParamEmit.cpp.

**Module/type ground:**
* **R1 PortExpr / ExplictiPorts** (4 row-modes): not net binding. Golden's escaped identifier `\op[79] ` spans
  col+6+len on its OWN line (the `@@BS@@` preprocessor spelling: 4:11-4:23, where our offset arithmetic crosses the
  line end, 5:3), and later tokens on the line shift by the same mangling; the references inside an explicit port
  expression are located at the expression (`.a({b, c})` 31:14), and `module f({a, b})` locates `b`'s net and port
  at the expression but `a`'s at the declaration. ModuleEmit.cpp emitPortExprPort, UhdmExporter.cpp nameSpan.
* **R2 HierPathTypespec t**: the listener binds the member of the element COPY of `pkg::b`; ours shares `pkg::a`.
* **R3 packed_struct_array_fifo** after § defNetTypeParamPackedDim144: the elaborated listing's `d_t` copy
  (1:9-1:22, members named bare) and `FifoDepth[ADDR_DEPTH:0]`'s index name.
* **R4 the type-parameter default's member references** (grid tq/d1, map N0084 family): golden parents the default
  struct at the LAST net (`struct_net arr`), so its member refs read `work@top.arr.arr.a`; unstoring ours gives
  `work@top.my_t.a`: the parent model has to move first.
* **R5 UnsizedParam d** fullname(2): the default instance shares the definition's implicit-net cast.
* **R6** Surelog's escaped-identifier columns (R1) are the head of YosysBigSimEllip's 3038.
* **R7** grid qb/c: a module-scope struct member's folded package-qualified bound spans `p::` (6:12-6:15).
* **R8** grid hg/d: an expression index in the definition-view generate Lhs (`s[i+0].f`): anchored too, but golden
  names the index reference through the hier path (`work@top.g.s[i + 0].f.i`).
* **R9** the UVM/Earlgrey clusters N0064 N0067 N0068 N0069 N0072 N0051 N0093 N0070 (untouched but for the method
  spans).

## 8. Files

* `grid/{ia,pf,fb,el,tq,pt,qb,vf,at,hg}/` — the cases (every `dut.sv` names its law in its first line).
* `evidence/` — grid_pristine.txt, grid_law.txt, grid_law_off.txt, grid_sw_*.txt, switches.txt, sweep_pristine.txt,
  sweep_law.txt, cols_P_L.tsv, prefix_P_C.txt, byteverify_surelog.txt, byteverify_uhdm2rtlil.txt,
  predict_pristine.tsv, attribution.txt, attribution_multi.txt, attribution_earlgrey.txt, canaries.txt, downstream_law.csv, downstream_law.log.
* `drivers/` — case.sh / grid.sh (one case, the grid), switches.sh, sweep.sh, row.sh (a corpus row's records),
  prefix.py (the no-new-difference check), predict.py (mover prediction), attrib.py / attrib2.py / attrib3.py
  (per-switch, order-blind and one-law-on attribution), pin.sh (gdb pin at a Make call's rank), pchain.cpp (an object's parent chain with both
  full-name readings), objrank.cpp (creation rank), tsinfo.cpp (array typespec ranges and referrers).
