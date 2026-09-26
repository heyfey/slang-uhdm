# r11u176: the module/type ground, pair B (refill after pass 171): r11u175's extern-prototype law landed, fourteen laws of its own

Base `72fd3061` (branch matrix-1.87). Files of the ground touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp`,
`src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`. `uhdm_main.cpp` needed nothing. No line of the sister's files
(`src/ExprEmit.cpp`, `src/EmitHelpers.h`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp`) and nothing under `results/`,
`tests/probe/` or `third_party/` is edited; `tests/LAWS.md` is regenerated (`python3 scripts/law_index.py`).

Switches. r11u175's law keeps its delivered switch `R11U175_FSPAN_OFF` (`R11U175_OFF` drops it, as delivered, via the
`r11u175LawB` helper the patch brings into `TaskFuncEmit.cpp`). Every law of this pass reads its own
`R11U176_<LAW>_OFF` through `r11u176Law` (`UhdmExporter.cpp`, beside `r11u171Law`), and `R11U176_OFF=1` drops all of
them. `R11U176_OFF=1 R11U175_OFF=1` gives the pristine bytes on every one of the 105 cases here (section 5).
`R11U176_TRACE=1` prints one `R11U176 <LAW> <detail>` line per firing branch (the attribution below).

The slang-fenced tests are written `FENCED=` here and never spelled. Every driver that reads corpus sources or
databases (`drivers/predict176.sh`, `drivers/bvmirror.sh`, `drivers/rowrec.sh`, `drivers/row.sh`, `drivers/obrow.sh`,
`drivers/attrib.sh`, `drivers/uvmtrace.sh`, `drivers/uvmcensus_sweep.sh`, `drivers/boundary.sh`, `drivers/case.sh`,
`drivers/dscase.py`) reads `$FENCED` from RESUME.md (`drivers/env.sh`, fail closed) and refuses or skips a fenced name
by word boundary; the byte comparisons ran on hard-link mirrors that leave the 8 fenced row-mode databases out
(`fenced_skipped=8`). No fenced test was run, read or decoded outside the gate sweeps, which dispatch every row
themselves. gdb was not used.

## 1. Binaries (frozen `chmod 555` before any measurement, `/tmp/r11u176_bin/`)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `fdef3ad724d1655e4f9aa3b8a169655d` | worktree build of `72fd3061` (system deps, `-j 2`) = the main tree's `build/slang-uhdm` |
| `l175.bin` | `2d566bee8e58881b36076f288dfc689f` | + r11u175's `law_typeemit.patch` alone (section 3a) |
| `d1`..`d26`, `final`..`final3` | (development builds) | |
| `final4.bin` | `24e6c4dc65d673d6d6d98ed966ef1e80` | **the final build of the patch**; the final sweep `swI` |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `strictcmp_x` | `db96066ac072748e8d5b05cf675242f8` | map 8's record-dump variant (`tools/probe/r11u165map/drivers/cc.sh`), the UVM census |
| `predict176` | (built by `drivers/cc176.sh`) | `drivers/predict176.cpp`, the byte-mover predictor |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, same-length workdirs, `drivers/sweep.sh`): `/tmp/r11u176_swP`
(pristine), `/tmp/r11u176_swA` (`l175.bin`, r11u175's law alone), `/tmp/r11u176_swI` (`final4.bin`); the development
sweeps `swB`, `swC`, `swF`, `swG`, `swH` (logs `evidence/sweeps/sweep_sw{B,C,F}_dev.log`). In `swI` all 3273 `slang:` lines
of the corpus `cmds.txt` files read `/tmp/r11u176_bin/final4.bin` (in `swP` all read `pris.bin`). Every sweep exits 1
for one reason only, `law index STALE: tests/LAWS.md`, which the base reads too (`scripts/law_index.py --check`, rc 1);
the patch carries the regenerated `tests/LAWS.md`. Logs: `evidence/sweeps/sweep_sw{P,A,I}*.log`.

## 2. Verdict per targeted row (fresh csv rows of `/tmp/r11u176_swI`; results/ untouched)

**5 corpus row-modes STRICT_NOTEQUAL -> CMP_EQUAL, 0 regressions, loudly:**

    OneNetModPort,default,CMP_EQUAL,,,equal          § progTypedPortLowConnUnlocated176 + § progLowConnDefModport176   (was differ:file(3))
    OneNetModPort,testflags,CMP_EQUAL,,,equal        (same)                                                          (was differ:file(3))
    OneNetModPortGeneric,default,CMP_EQUAL,,,equal   § genericMpConnLowConnAtDecl176 + § progLowConnDefModport176 + § genericPlainNamedView176 (was differ:line(2))
    OneNetModPortGeneric,testflags,CMP_EQUAL,,,equal (same)                                                          (was differ:line(2))
    UnsizedParam,default,CMP_EQUAL,,,equal           § castRhsClonePerInst176                                        (was differ:fullname(2))

(`UnsizedParam,testflags` was already `CMP_EQUAL` and stays so.) Downstream rows of the touched uhdm2rtlil test and the
two interface tests: `ibex_pmp,IDENTICAL,OK,OK,52,52,,`, `OneNetModport,IDENTICAL,NO_GATES,NO_GATES,0,0,,`; the whole
`downstream.csv` of `swI` is byte-identical to the pristine sweep's (803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT /
0 DIVERGENT; pass 120's eight rows included).

**Improved, still STRICT_NOTEQUAL** (compare_results CHANGE lines; every one attributed in section 4):

| row (modes) | base | final | law(s) | the first record now |
|---|---|---|---|---|
| MiniAmiq d/t | file(29) | fullname(12) | § tfArgClassMethodOrder176 (+ § externProtoFormalsFromPrototype175) | #770 `ref_typespec <in>uvm_reg_byte_en_t` under a `bit_typespec` (map N0164, the typespec-identity family; golden names it through `uvm_reg_bus_op::byte_en`) |
| SeqDriver d/t | file(29) | fullname(11) | (same) | #753, the same N0164 record |
| SimpleUVM d/t, Scoreboard d | fullname(45) | fullname(27) | (same) | #458 / #466 `ref_typespec UVM_MACRO_NUMFLAGS` (golden) vs `uvm_pkg::UVM_MACRO_NUMFLAGS` (reference full names, N0682; unchanged head, 18 objects fewer behind it) |
| BuildUVMPkg d/t | line(94) | fullname(49) | (same) | #1135, the N0164 record |
| ibex_pmp d/t (u2r) | file(15) | file(5) | § tfArgQualOutsideWriter176 | #2404: the package parameter `PmpCfgRst`'s element typespec: golden's ELABORATED package listing reads the moved `pmp_cfg_t` (114:47), ours the definition object, and the module's imported copy the reverse (the import-parameter copy, ParamEmit, sister: residue 3) |
| InterfaceModPort d/t | endcol(15) | endcol(12) | § progTypedPortLowConnUnlocated176 + § progLowConnDefModport176 | the interface's `logic_typespec` end columns (27:21 where golden ends at the keyword 27:8; residue 7): the program-port faces and the walk divergence are gone |
| FuncStructValSimple d/t | file(42) / file(62) | file(41) / file(61) | § tfArgQualOutsideWriter176 | the constants without a file under `vpiRange` (N0031 family), unchanged head |
| FuncStructVal t | endcol(177) | endcol(165) | § tfArgQualOutsideWriter176 | unchanged head |
| SVSwitch d/t | fullname(11) | fullname(18) | § progTypedPortLowConnUnlocated176 + § progLowConnDefModport176 | **the count grows because the walk diverges later**: the first record is the same (#101 `ref_obj bytes`, golden `work@Driver::start::pkt.byte_pack::bytes`, sister F5); the pristine walk diverged at #3314 (depth), behind the program-port faces #1397-#1401 (file); those faces are gone and the walk now runs to #3398, exposing 7 reference full names between (#3380-#3394, `testcase.sv` 18). Order-blind the row moves toward golden, 127 -> 112 records |

No corpus row-mode regresses; every changed row is judge-equal before and after (stage 1 of the strict comparator is
uhdm-cmp's own Compare). The status histograms are the base's except the 5 conversions: surelog 453+27 default,
448+26 testflags judge-equal (480/3 + 474/3 as at the base); uhdm2rtlil 777+26 both modes (803/1).

**61 probe cases STRICT_NOTEQUAL -> EQUAL**, 30 changes, 0 regressions (EQUAL 2768 -> 2829); every change moves toward
golden (no count grows; `evidence/sweeps/probe_conversions_changes.txt`).

## 3. The laws

### 3a. r11u175's decode, landed

`law_typeemit.patch` (tools/probe/r11u175uvm) applies on `72fd3061` without a conflict and is landed unchanged
(TaskFuncEmit.cpp only; its `law_exprstmt.patch` is the sister's and is not applied).

| law | switch | site | rule (r11u175's decode) |
|---|---|---|---|
| § externProtoFormalsFromPrototype175 | `R11U175_FSPAN_OFF` | TaskFuncEmit.cpp `emitTaskFuncs` (the io_decl loop, `retTypeSyn175`, the constructor's return var) | a class body's listing of an `extern` method is compiled from the prototype (compileFunctionPrototype / compileTaskPrototype) and the definition's compile returns early (CompileStmt.cpp), so its formals, their defaults, typespecs and bounds and the return variable sit at the prototype's tokens; an extern constructor's return variable has no location |

**Measured alone** (sweep `swA`, `l175.bin`, against the committed baselines): probe regressions 0, **conversions 54**,
changes 26 (every one toward golden; `evidence/sweeps/swA_conversions_changes.txt`); surelog 0 / 0 / 0; uhdm2rtlil
0 / 0 / 0; downstream csv byte-identical to pristine. r11u175 measured the law together with its three expression-ground
laws at `e3f14d0a`, where the UVM rows' first records were its own faces; after pass 171 the first records of the UVM rows
are the typedef relocations (F3) and the reference full names (F5), which this law does not touch, so **no corpus strict
column moves** (MiniAmiq/SeqDriver stay `file(29)`, SimpleUVM/Scoreboard `fullname(45)`, BuildUVMPkg `line(94)`; the
first records before and after: `evidence/rows/first10_surelog_swP.txt` - MiniAmiq #573 `uvm_pkg::uvm_check_e` golden
`uvm_reg_block.svh 1671:35`, ours `uvm_reg_model.svh 180:4`, the same under `swA`). The law's effect is behind them,
order-blind (`evidence/sweeps/orderblind_swA.txt`, ours-not-golden + golden-not-ours): MiniAmiq 53,273 -> 46,601,
SeqDriver 42,605 -> 35,957, SimpleUVM 20,344 -> 12,972, Scoreboard 18,002 -> 10,554, BuildUVMPkg 14,833 -> 6,963,
ApbSlave 88 -> 12. Byte movers: 11 corpus row-modes (ApbSlave d/t, BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d,
SeqDriver d/t, SimpleUVM d/t), exactly the 11 its trigger predicted (`evidence/prediction/pred_P1.txt`, written
before `swA` started; `evidence/sweeps/byteverify_swA_vs_swP.txt`); 103 probe movers, all predicted (115 predicted).
Its residue a10 (a type parameter's shared typespec relocated by its last formal writer) stays (residue 4).

### 3b. The laws of this pass

| law | switch | site | statement (decode) |
|---|---|---|---|
| § castRhsClonePerInst176 | `R11U176_CASTCLONE_OFF` | ModuleEmit.cpp `emitContAssigns` (the implicit-net share and the select-Lhs share) + `castRhsCloneDrain176` (design-final, from `exportDesign`) | UhdmWriter::writeCont_assign walks the definition's cont_assign objects of every elaborated instance and replaces one with a per-instance copy in three legs; the third needs neither a bound whole-name Lhs nor an Lhs typespec, only an operation Rhs that carries a TYPESPEC of its own - a cast: `assign = clone_tree(assign, ElaboratorContext(&s,false,true)); assign->VpiParent(m); ((operation*)rhs)->Operands(((operation*)tmp)->Operands());` with `tmp` = flattenPatternAssignments over the ORIGINAL Rhs, so the copy's operation lists the definition's operand objects while the cont_assign, its Lhs subtree, the operation and its ref_typespec are fresh and read the instance's full names through the parent chain. An implicit-net Lhs (the elaborated instance drops the net, the bind fails) and a select or concatenation Lhs reached it; ours shared the definition object (UnsizedParam `assign a = int'(Y)`: golden `work@top.u_sub_default.a`, `work@top.u_sub_5.a`, one copy per instance). A bare operation (`w & 1'b1`, `~w`, `{w,w}`) keeps the share, as golden does; an assignment-pattern operand (the flatten) and a delay reference (leg 0) are not modelled |
| § progTypedPortLowConnUnlocated176 | `R11U176_PROGLCLOC_OFF` | ModuleEmit.cpp `emitPorts`, the program definition branch | a PROGRAM's typed interface port (modport-qualified or plain) has an unlocated Low_conn in the definition view: golden `work@TESTBENCH.intf.intf` 0:0 with no file (writeProgram -> writePorts mints the reference without the port-type binding's populateCoreMembers). A generic port, an ordinary net port to Surelog, keeps its span |
| § progLowConnDefModport176 | `R11U176_PROGMPDEF_OFF` | ModuleEmit.cpp `emitInstance`, the port-view modport re-point (`progDefModport176`) | UhdmWriter::writeElabProgram re-points every program port Low_conn that binds a modport to `modPortMap[ModPort*]`, the DEFINITION interface's modport (writeInterface fills the map), where the module writer keeps the port view's. So golden's io_decls under that Low_conn carry no Expr (the definition's `output drive` has none) and ours listed the view's minted `work@TOP.tb.intf.drive` (OneNetModPort / OneNetModPortGeneric / InterfaceModPort / SVSwitch's walk divergence). A generic port with a modport-qualified connection is re-pointed too |
| § progPlainPortViewUnparented176 | `R11U176_PROGVIEW_OFF` | ModuleEmit.cpp `emitInstance` + `progViewDrain176` (design-final) | a PROGRAM lists no interfaces (writeElabProgram writes ports, nets, variables, processes), so the view elab_interface_ minted for a plain typed port, or a generic port connected by name to a plain instance, keeps neither a parent nor a stored full name: golden `interface_inst intf` with an empty full name, its variables `intf.drive` |
| § genericMpConnLowConnAtDecl176 | `R11U176_GENMPLOC_OFF` | ModuleEmit.cpp `emitInstance`, the elaborated interface-port Low_conn location | a GENERIC port connected BY NAME to a modport-qualified actual (`.intf(conntb.tb)`) anchors its Low_conn at the PORT DECLARATION (module and program): NetlistElaboration's `net->UhdmType()==uhdmmodport && lowconn_is_nettype` leg copies the elaborated port's span onto the reference it mints (golden OneNetModPortGeneric `work@TOP.tb.intf` tb.v 1:31-1:35, ours the formal 18:17). Only for an actual the instantiating scope's own netlist holds (the leg reads `parentNetlist->getModPortMap()`): a connection inside a generate block to an enclosing instance keeps the existing rule |
| § genericPlainNamedView176 | `R11U176_GENPLAINLOC_OFF` (the span), `R11U176_GENPLAINVARS_OFF` (the variables) + `genPlainViewDrain176` (design-final) | ModuleEmit.cpp `emitInstance` | a GENERIC port connected BY NAME to a plain interface instance: NetlistElaboration's `uhdminterface_inst && lowconn_is_nettype` leg locates the Low_conn at the WHOLE named connection (`populateCoreMembers(Named_port_connection, ...)`: `.intf(conntb)` 19:16-19:29), and hands elab_interface_ the CONNECTED instance itself, whose elab_ports_nets_ writes the view's signals into `interf_instance->getNetlist()` - the connected instance's own netlist. So the connected instance lists its own variables followed by one copy per such view, named and parented by it and elaborated with ITS parameters (golden `work@TOP.conntb`: drive, observe, drive, observe; r11u130 p06's `data` [5:0] under `W = 6`), and the view and the HighConn's interface copy list that same variable vector; nets are the connected instance's alone (golden r11u173 cx/x07 lists no net under the view). Our listing held the connected instance's own objects twice and the view's own objects (elaborated with the definition's parameters). Only for an actual declared in the instantiating scope (`parentNetlist->getInstanceMap()`); a generate-block connection to an enclosing instance or a second level through a port adds nothing (r10vrgg16 cells/v2 u3, r11u173 pv/p04 `l`) |
| § tfArgQualOutsideWriter176 | `R11U176_QUALFORMAL_OFF` | UhdmExporter.cpp § tfArgTypedefLastWriter146's writer walk (the ScopedName branch, the aggregate admission, `applyW`) | a PACKAGE-QUALIFIED argument type (`ibex_pkg::pmp_cfg_t region_csr_pmp_cfg`) is a writer like a bare name: compileTfPortList runs the same `populateCoreMembers(type, type, ts)` over the data type node, whose first child is the qualifier, so the elaborated package's object takes the qualifier's span `p::` (with a direction keyword the node is the whole `p::e_t`: `input p::e_t x` 5:36-5:42), in the writer's file. A writer OUTSIDE the package moves a struct or union typedef's elaborated object too (§ 146 admitted enums only; its f14 inside-the-package decline stands); an aggregate's own span is its type (`struct` .. `}`), against which a write-time end move is read (r11u42 g2 keeps 15:22). A qualified writer inside its own package is not modelled (left alone, as before) |
| § tfArgClassMethodOrder176 | `R11U176_CLSMETHOD_OFF` | UhdmExporter.cpp § 146's writer walk (the class decline lifted; `lastCls176` / `lastPkg176`) | r11u175's F3 decode, completed: a method of a class a package holds writes the package typedef (§ 146's decline was ours). The two listings take two writers: the DEFINITION package listing is written by the package's own items (subroutines and out-of-body `C::m` definitions, in source order - across `include` buffers, by the walk's sequence), and the ELABORATED package's object by the class methods, which compile later: the last one in the class map's NAME order, each class in source order. Golden f3/t1, t3: the definition listing keeps its span; t4 and f4/a08: the out-of-body definition in the definition listing and the prototype in the elaborated one; t6: the package function and the class method; `uvm_check_e` reads `uvm_reg_block.svh:1671` in the definition listing |
| § tfArgDefTopSplit176 | `R11U176_DEFTOPSPLIT_OFF` | UhdmExporter.cpp § 146's writer walk (`splitIn176` / `splitOut176`) | writers INSIDE the typedef's package (its own subroutines) and OUTSIDE it in ONE other container split the listings the same way: the definition listing takes the last inside writer, the elaborated package's object the last outside one (golden r11u146 fa/f11: `p`'s own `f(e_t g)` 4:26 in the definition listing, `q::h(p::e_t k)`'s `p::` 9:26 in every later listing). Outside writers in two containers, or beside class writers, are not modelled (left alone) |
| § tdEndMoveModuleOrder176 | `R11U176_TDTIE_OFF` | TypeEmit.cpp § tdMoveCarriesFile172's block (`declEndMod176`) | v11u171 residue R1: two files holding a declarator of the same type name at the same position - the end-only move is writeNets', run module by module in the definition map's NAME order, so the alphabetically last MODULE is the last writer (v11u171 F/h05, h07: golden `m1.sv` over `dut.sv`) |
| § tdMoveKeyResolved176 | `R11U176_TDKEY_OFF` | TypeEmit.cpp § tdMoveCarriesFile172's block (`formalAtSym176`) | v11u171 residue R2: a PACKAGE subroutine's formal is keyed on the typedef its bare name RESOLVES to in that package (imports included), so `pa::s_t` and `pz::s_t` formals written `s_t` at one position in two files stay apart (v11u171 F/h10: golden files `pa::s_t` at `b_pkg.sv`) |
| § udpFormNetLvalueFirst176 | `R11U176_UDPLV_OFF` | ModuleEmit.cpp `udpFormSwallow176`, the LATE UDP-form wrap | v11u171 residue R4: Surelog reads a fully positional, parameterless instantiation as a udp_instantiation only when every instance's FIRST connection is a net_lvalue (a name, select, member access or concatenation of those); a literal or operation inside the first concatenation (`{1'b0, w1}`, `{w1 & w2, w1}`) makes a module instantiation that swallows nothing. § udpSwallowLvalueOnly171v gave the rule to the early swallow; this gives it to the pristine late wrap. The other readers of the UDP shape (the definition view's ref_module and bound names) are the sister's (residue 6) |
| § genElseBeginIfDepth176 | `R11U176_ELSEBEGIN_OFF` | ModuleEmit.cpp `emitGates`, beside § genElseIfGateTermPath171 | v11u171 residue G/a03: an `else begin if (...) ... end` body is two generate blocks in slang's chain and in Surelog's path (`work@dut.genblk1.genblk1`), where our scope naming lists one: when the prefix lists fewer generate segments than the chain has blocks and an unnamed ELSE body is on the chain, the gate terminals are named by the instance path plus the chain's names |
| § genElseIfGateArrayPath176 | `R11U176_GENARR_OFF` | ModuleEmit.cpp `emitGates`, the gate-ARRAY terminal scope | v11u171 residue G/a05: a gate ARRAY's terminals take § genElseIfGateTermPath171's path like a single gate's (`xor g1 [1:0] (c, a, b)` in an unnamed else-if body: golden `work@dut.genblk1.genblk1.c`) |

## 4. Gates (final binary, sweep `/tmp/r11u176_swI`, against the committed baselines)

| gate | pristine `swP` | final `swI` |
|---|---|---|
| (1) build | `pris.bin` = main tree md5 `fdef3ad7` | `final4.bin` `24e6c4dc` |
| (2) probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2768, STRICT_NOTEQUAL 1319) | **regressions 0**, conversions 61, changes 30 (EQUAL 2829, STRICT_NOTEQUAL 1258); no NOT_EQUAL case |
| (3) surelog vs golden_surelog.csv | 0 / 0 / 0 | **regressions 0**, conversions 5, changes 16 |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | **regressions 0**, conversions 0, changes 2 (ibex_pmp d/t) |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | 803 / 66 / 2 / 0, not excused 0; `downstream.csv` byte-identical to the pristine sweep's |
| (5) uhdm-cmp | | every converted and changed row is judge-equal before and after; no row moves between judge-equal and anything else |

**(6) Byte movers, corpora** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, fence-clean mirrors `/tmp/r11u176_mI` /
`mP`: 2560 databases each, 8 fenced skipped; PATH_SETS_IDENTICAL; SELFCHECK 2559 / 2560 flagged,
`evidence/sweeps/byteverify_swI_vs_swP.txt`): **30 movers, all 30 predicted by name** (`drivers/predict176.cpp`, one
trigger per law branch, over every PRISTINE database of `swP` with the fenced ones excluded by word boundary;
`evidence/prediction/pred_final.txt`, written at 01:44:33 before the final sweep started; the same file, byte for byte,
was first written at 00:36:47 before the first sweep of this law set, `swF`; the earlier `pred_P1`-`pred_P3` preceded
`swA`, `swB` and `swC`). 44 predicted, 14 did not move (the triggers over-approximate: Earlgrey_0_1 d/t on CASTCLONE,
GenerateUnnamed d/t on GATEGEN, PackFunc d/t and the rp32_r5p rows on TDWRITER).

| mover (row-modes) | law(s) (the trace, and the switch whose single drop restores the pristine bytes) |
|---|---|
| UnsizedParam d/t | CASTCLONE (restores) |
| Scr1SvTests d/t (strict `type(1)` unchanged: the walk diverges at #16033 before the copies) | CASTCLONE (restores; order-blind 263 -> 261) |
| Rggen d (strict `fullname(7)` unchanged) | CASTCLONE (46 firings; `R11U176_OFF` restores; order-blind 17,674 -> 17,193) |
| OneNetModPort d/t, InterfaceModPort d/t, SVSwitch d/t | PROGLCLOC + PROGMPDEF (both needed) |
| OneNetModPortGeneric d/t | GENMPLOC + GENPLAINLOC + GENPLAINVARS + PROGMPDEF |
| FuncStructVal d/t, FuncStructValSimple d/t, ibex_pmp d/t | QUALFORMAL (QUALAGG trace; restores) |
| ApbSlave d/t | FSPAN (restores) |
| MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t | FSPAN + CLSMETHOD (23-24 CLSMETHOD firings per row); `R11U176_OFF=1 R11U175_OFF=1` gives the pristine bytes on BuildUVMPkg, Scoreboard, and order-blind 4 lines (the known UINT/vpiDecompile order coin) on MiniAmiq, SeqDriver, SimpleUVM |

(`evidence/sweeps/corpus_movers_attrib.txt`, `evidence/sweeps/uvm_movers_trace.txt`.) Every corpus mover moves TOWARD golden
order-blind (strict records as multisets, depth dropped, ours-not-golden + golden-not-ours; `evidence/sweeps/orderblind_P_I.txt`),
e.g. MiniAmiq 53,273 -> 44,429, SeqDriver 42,605 -> 33,159, SimpleUVM 20,344 -> 10,594, Scoreboard 18,002 -> 8,638,
BuildUVMPkg 14,833 -> 5,431, ibex_pmp 152 -> 24, UnsizedParam 9 -> 0, InterfaceModPort 47 -> 24, SVSwitch 127 -> 112.
The UVM file facets, order-blind (`evidence/sweeps/uvm_file_facets.txt`, (type, name, file) records ours holds more
often than golden): MiniAmiq 3,832 -> 2,851, SeqDriver 4,035 -> 2,732, SimpleUVM 2,841 -> 1,710, Scoreboard 2,335 ->
1,412, BuildUVMPkg 463 -> 437.

**Probe:** 116 byte movers of 4087, all predicted (130 predicted; `evidence/sweeps/probe_movers_vs_predicted.txt`); per
mover the switch that restores it (`evidence/sweeps/probe_movers_attrib.txt`): FSPAN 102, CLSMETHOD 4, CASTCLONE 3,
QUALFORMAL 1, GENMPLOC 1, and 5 that need two laws dropped together (r10imex_repro/t7: GENMPLOC + GENPLAIN*;
r10svs9repro/b2_progdef, r10vrgg16repro/cells/v7, r11v1repro/vE: PROGLCLOC + PROGMPDEF; r10uvm204repro/g204_e_head:
FSPAN + CLSMETHOD).

**Canaries** (`evidence/sweeps/canaries.txt`): `r11u107repro/canaries.sh` surelog ok=40 changed=12 (exactly attributed
CHANGE rows: InterfaceModPort, FuncStructVal t, SVSwitch, SimpleUVM, SeqDriver, BuildUVMPkg, Scoreboard d), uhdm2rtlil ok=16
changed=0 (pristine controls ok=52 / ok=16, changed 0); `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` ok=58 changed=0 PASS,
uhdm2rtlil `EXPECT_UNKNOWN=6` ok=2 changed=0 PASS.

**Boundary and landed-law byte controls** (`drivers/boundary.sh`: every `tools/probe/**/dut.sv` outside this pass,
both binaries, `dut.sv --single-unit --nobuiltin`, children on `</dev/null`, fenced paths refused; the tests/probe
cases are the probe stage above): see section 6.

## 5. The grid (`cases/`, 105 cases, first line `// § <law>`; `drivers/case.sh`: goldens from the pinned Surelog with check_probe's arguments, cached by the md5 of every file of the case; a `files` list names several root files)

Pristine strict-equal **28 -> 80 of 105** (`evidence/grid/grid_pristine.txt`, `grid_final.txt`); in the `--elabuhdm`
form (`drivers/gridE.sh`: Surelog `-elabuhdm`, ours `--elabuhdm`) **41 -> 78 of 105** with no regression and no stage-1
line count moved except PG/g18's conversion (`evidence/grid/gridE_*.txt`). `R11U176_OFF=1 R11U175_OFF=1` gives the
pristine bytes on **105 of 105** (`evidence/grid/alloff_bytes.txt`), and each switch alone restores exactly its own
dir's movers (`evidence/grid_switches.txt`). No case pristine read strict-equal reads otherwise; no stage-1 case's
uhdm-cmp line count grows.

| dir | law | cases | converted (pristine -> final) | controls / residue |
|---|---|---|---|---|
| CC | castRhsClonePerInst176 | 29 | u01 (the UnsizedParam shape), u02 (int parameter), u03 (net operand), u05 (one instance), u06 (sized parameter), u07 (`8'(Y)`), u09 (`int'(5)`), u14, u19 (`b_t'(w)`), u20 (part-select Lhs), u21 (bit-select Lhs), u22 (concatenation Lhs), u25 (`#1` delay), u28 (two levels), u29 (three assigns) | u04 (declared net), u10-u13 (bare operations share), u15 (declared net), u16 (cast inside a binary operation), u18 (top instance: identity only), u23 (variable Lhs): strict-equal on both; u17 (gen scope: another face, `w`'s full name, on both); u08, u26 (`signed'`), u24 (pattern), u27 (interface) stage 1 on both, the same uhdm-cmp line count |
| PG | progTypedPortLowConnUnlocated176, progLowConnDefModport176, progPlainPortViewUnparented176, genericMpConnLowConnAtDecl176, genericPlainNamedView176 | 21 | g01, g02 (modport port, positional / named), g03, g04 (plain port), g06 (generic, named plain: § progPlainPortViewUnparented176), g08 (two ports), g11 (nested), g12 (generic, modport connection), g13 (module generic, modport connection), g17 (module generic named plain), g18 (two such ports: stage 1 -> strict-equal) | g07, g14 (positional) strict-equal on both; g09 (two program instances: the shared initial process, residue 5), g05, g10, g15, g16 (positional generic / generic in a multi-port program: stage 1 on both, same count); g19 (generate-block connection to an enclosing instance: bytes unchanged), g20 (second level through a port: stage 1 on both, same count, order-blind 162 -> 100), g21 (modport connection inside a generate block: bytes unchanged) |
| PQ | tfArgQualOutsideWriter176 (q21: tfArgDefTopSplit176) | 20 | q01 (enum), q02 (struct), q03 (two functions), q04 (task, `input p::e_t`), q05 (qualified and bare), q06 (another package's function), q07 (`p :: e_t`), q08, q09 (union), q14 (unpacked formal: the end kept), q16 (uncalled function), q17 (bare import struct), q19 (`input p::e_t x`), q21 (inside + outside writers, the r11u146 f11 shape) | q13 (return type), q18 (struct inside its package), q20 (bare with direction) strict-equal on both; q11 (two modules: two outside containers, not modelled), q12 (qualified alias), q15 (qualified inside its own package: stage 1 on both) |
| F3 | tfArgClassMethodOrder176 | 14 | s01 (extern definition, struct), s03 (extern definition, unpacked struct formal: the aggregate end rule of § tfArgQualOutsideWriter176), s05 (two classes, extern definitions), s06 (uncalled method), s07 (task and function) | s02, s09-s12 (package subroutines: another mechanism already moves them) strict-equal on both; s04, s14 (a package function's UNPACKED struct formal: inside aggregate writers, not modelled), s08, s13 (class writers beside outside writers: not modelled) |
| GE | genElseBeginIfDepth176, genElseIfGateArrayPath176 | 10 | e03 (inner if-else), e04 (inner case), e05 (inner if without begin), e06 (gate array), e07 (two instances) | e01 (named else body), e02 (plain else body), e08-e10 (gate arrays elsewhere) strict-equal on both |
| TD | tdEndMoveModuleOrder176, tdMoveKeyResolved176 | 3 | td01 (three files, the tie), td02 (three packages, the key) | td03 (one file) strict-equal on both |
| UD | udpFormNetLvalueFirst176 | 8 | - (u3, `{1'b0, w1}` first: stage 1 on both, order-blind 108 -> 77, downstream EQUIVALENT -> IDENTICAL; the ref_module face is the sister's) | u1, u4, u6 strict-equal on both; u2, u5, u7, u8 unchanged bytes |

The grids of r11u175 (`tools/probe/r11u175uvm/cases/f3`, f4) and v11u171 (`cases/F`, `G`, `Q`) are the laws' second
grids (`evidence/boundary_movers.txt`): f3 t1-t6 all convert; v11u171 F/h01-h03 (qualified formal), h05, h07 (the tie),
h10 (the key) convert; G/a03, a05 convert; Q/c07, c12 move toward golden (stage 1 on both: the sister's ref_module
face).

The location-model shapes the brief requires for a file or location change: the relocation laws were gridded on two
files at the same declarator position (TD td01, v11u171 F/h05-h09), on package-qualified names (PQ, v11u171 F/h01-h03),
on an include file and a macro (v11u171 F/h02, h03: converted), on both views (`--elabuhdm` grid above) and on the UVM
file facets order-blind (section 4). § tfArgClassMethodOrder176 reads writers across `include` buffers by the syntax
walk's sequence, not by location comparison.

Downstream through the harness's own `one()` (`drivers/dscase.py`, fresh `GOLDEN_CACHE`, `evidence/downstream_cases.txt`)
on the 103 single-file cases, pristine -> final: 97 IDENTICAL -> IDENTICAL, 5 EQUIVALENT on both with the same
`differs` (CC/u08, u27, PG/g21, UD/u7, u8), **UD/u3 EQUIVALENT -> IDENTICAL**. No case leaves IDENTICAL.

## 6. Boundary (`evidence/boundary_movers.txt`, `evidence/boundary_summary.txt`)

`drivers/boundary.sh` over every single-file `tools/probe/**/dut.sv` outside this pass: **listed 9078, processed 9078:
8905 SAME, 68 MOVER, 105 NODB** (no database from either binary: the same 3 segfaults and the same rejections on both;
no case where only the final binary fails). Every mover judged against its pinned-Surelog golden with both binaries
(`drivers/judge.sh`: status, uhdm-cmp lines, order-blind uhdm-dump distance):

* 21 STRICT_NOTEQUAL -> STRICT_EQUAL (r11u146 fa/f11, r11u149verify at/n02 and vf/n03, r11u162verify pvn/n04,
  r11u164 PV/a13, r11u175uvm f2/g02, f3/t1-t6, f4/a01-a05, a09, r11v133 tix/f01, v11u171 G/a03, a05);
* 2 NOT_EQUAL -> STRICT_EQUAL (r11u83 grid/i7_dblgen, i9_dblownnet: an interface bound to a generic port, the
  § genericPlainNamedView176 listing);
* 1 NOT_EQUAL -> STRICT_NOTEQUAL (r11u173verify cx/x07: the same generic view; order-blind unchanged, 303);
* 9 STRICT_NOTEQUAL on both, fewer objects off golden (r11u130 g6/p06_generic: the walk diverges later, #58 -> #80;
  r11u155 IC/i08; r11u175uvm f2/c02, g05, g06, g08, f4/a08, a10, f5/e04);
* 3 STRICT_EQUAL on both (identity: r11u155 UP/u08, r11u170verify sc/f03, r11v158 sc/b07);
* 32 NOT_EQUAL on both, every one with fewer records off golden and the same or a smaller uhdm-cmp line count.

**No case moves away from golden.** The multi-file residue grids (run with their `files` lists through
`drivers/case.sh`, `evidence/multifile_grids.txt`): v11u171 F/h01, h02, h03 (qualified formal), h05, h07 (the tie),
h10 (the key) convert; h04 stage 1 on both (36 lines); r11u172rp F/f01-f12 keep their verdicts (f03, f05 stage 1,
same line count).

Breaks found by fresh cases during development and fixed before the final binary (each a refinement of the law's
statement above, never landed without it): the first § udpFormNetLvalueFirst176 cut changed `udpFormInstantiation`
itself, which also decides the definition view's ref_module and bound names: UD/u7 (a statement whose second instance's
first actual is a literal) minted a definition net golden lacks, so the rule now reads only the late wrap; the first
§ genericPlainNamedView176 cut moved the VIEW's own variables (elaborated with the definition's parameters: r11u130
g6/p06 turned stage 1, `data` [2:0] against golden's [5:0]), then shared the nets too (r11u173 cx/x07 order-blind +6),
and applied to a generate-block connection and a second level (r10vrgg16 cells/v2, r11u173 pv/p04: stage-1 counts
34 -> 536 / 332): it now copies the connected instance's variables, leaves the nets, and requires the actual in the
instantiating scope; the first aggregate cut of § tfArgQualOutsideWriter176 moved the end with the start (r11u42
grid42/g2 same distance, golden keeps writeNets' 15:22), now read against the aggregate type's own end.

## 7. The UVM and Earlgrey rows (brief question 4)

The UVM census (r11u175's `uvmcensus.py` + `uvmfamilies.py` over map 8's analyzer, `drivers/uvmcensus_sweep.sh`,
default mode, analyzer tool-verify ok on all five rows; `evidence/uvm_families_{pristine,final}.txt`,
`uvm_first10_{pristine,final}.txt`, `uvm_census_rank_{pristine,final}.csv`):

| family | pristine | final |
|---|---|---|
| F2 object multiplicity | 47,777 | 47,777 |
| F4 formal / typespec / bound spans | 19,697 | **3,499** (§ externProtoFormalsFromPrototype175) |
| F5 reference full names | 19,445 | 19,445 |
| F6 file facets | 8,180 | **3,919** (§ tfArgClassMethodOrder176 + FSPAN) |
| F7 expression spans outside the pp model | 5,030 | **2,201** (FSPAN: the io_decl default operations) |
| F3 typedef relocation spans | 1,045 | **89** (§ tfArgClassMethodOrder176) |
| F8 names / F1 pp model / F9 value-order-depth | 732 / 720 / 363 | unchanged |
| **all** | **102,989** (426 clusters) | **78,745** (374) |

First ten records per row, attributed (base -> final; `evidence/rows/first10_surelog_sw{P,I}.txt`):

* **MiniAmiq, SeqDriver** file(29) -> fullname(12) / fullname(11). Base: 6 enum_typespec + 1 struct_typespec relocations
  (`uvm_check_e` golden `uvm_reg_block.svh 1671:35`, ours the declaration `uvm_reg_model.svh 180:4`: family F3, the
  typedef move of § tdMoveCarriesFile172's family - a relocation ours did not perform, not the include face of
  § ppOutputFile166 nor the macro-argument face of § ppFileCallArgBody168), then 3 typespec_member files. Final: #770 / #753
  `ref_typespec` under a `bit_typespec` (N0164, golden `uvm_pkg::uvm_pkg::uvm_reg_bus_op::byte_en::uvm_reg...`: the
  typespec-identity family), #899 `uvm_severity` (golden `uvm_globals.svh 271:61`: a relocation still left alone, writers
  outside uvm_pkg beside its class writers - residue 1), then ground-A spans and full names (N0119, N0052, N0001, N0061)
  and N0327 logic_typespec files (the bitstream typedef copies, other file).
* **SimpleUVM, Scoreboard** fullname(45) -> fullname(27): #458 / #466 `ref_typespec` `UVM_MACRO_NUMFLAGS` (golden) vs
  `uvm_pkg::UVM_MACRO_NUMFLAGS` (reference full names, N0682, ground A); 18 objects fewer behind it (the relocations).
* **BuildUVMPkg** line(94) -> fullname(49): base #873 `m_uvm_factory_type_pair_t` relocation (F3); final #1135 N0164.
* **Earlgrey_0_1** fullname(436), unchanged (`evidence/rows/earlgrey_first10_sw{P,I}.txt`): the first ten are
  `ref_typespec <in>ibex_pkg::csr_op_e`, `dbg_cause_e`, `exc_cause_e`, ... inside the package enum listings - the
  typespec-identity family (full names inside a typespec copy, golden naming the base reference through its use site);
  minted by TypeEmit `buildEnumTs`' base-type reference; the comparator canonicalises identity but not these tails.
* **jeras_union** fullname(36), unchanged: #168 `ref_typespec <in>riscv_isa_pkg::imm_l_t` (the same identity family), then
  #176.. constants without a file under a range (`riscv_isa_pkg.sv 132:23`, N0031).
* **ibex_multdiv_fast** file(11), unchanged: enum constants of the generate block's typedef bound loc-less (sister,
  pass 171's residue 2).
* **Scr1SvTests** type(1), unchanged: #16033 `indexed_part_select din` - golden carries the called function formal's
  typespec reference (`work@scr1_ipic.scr1_search_one_16.din`), ours an operation: the walk already diverged there in
  pristine (sister: the call-argument formal binding, ExprEmit / StmtEmit).
* **CovMacro** fullname(8), unchanged: #106 `hier_path $root.top` (golden `work@top.$root.top`, ours none) - the `$root`
  path's full name (ExprEmit, sister).
* **ApbSlave** depth(1), unchanged: #372 golden `function svunit_base::new` where ours lists `string_var svunit_version`
  (the package item order of svunit_pkg); order-blind 88 -> 12 behind it.

## 8. Residues, ranked (decoded, not landed)

1. **The UVM relocations left alone** (F3 89 objects; MiniAmiq's #899 `uvm_severity`): a typedef written by class methods
   of its own package AND by subroutines of other packages or modules (svaunit_pkg, the test's own classes) - two
   compile phases whose relative order is not decoded (§ tfArgClassMethodOrder176 declines; cases F3/s08, s13).
   Likewise outside writers in two containers (PQ/q11: golden takes module `zz` over `aa`, the name order, like the
   classes: the next law), an aggregate inside its package with an unpacked formal (F3/s04, s14), a qualified alias
   (PQ/q12).
2. **Import-parameter copies** N0151 / N0262 / N0182 (8,548 objects, UVM; and ibex_pmp's `PmpCfgRst` element typespec,
   its last file(5)): the imported parameter's copy in the importing unit keeps the typedef object the package held
   BEFORE the formal moved it; ours shares the moved one. Site: ModuleEmit `importParamCopy82` / § classImportParamStamped82
   and the ParamEmit copy (sister). Not decoded further.
3. **The typespec-identity full names** (N0164, Earlgrey's 436, jeras_union's first record): full names inside a
   typespec copy golden names through the use site; TypeEmit buildEnumTs / makeTypespec copies. The comparator's
   canonicalisation excuses a copy's tail only when golden gives the object several names.
4. **Type-parameter last writers** (r11u175 f4/a10, N0072 / N0039 1,051 / 1,231 objects): the shared typespec of a
   class type parameter relocated by its last formal writer - the F3 mechanism on a type parameter; not gridded.
5. **Program instances share their definition processes** (PG/g09: two program instances, golden lists the second
   instance's `initial` once - writeElabProgram's `m->Process(netlist->process_stmts())`, the definition's objects;
   ours copies per instance). ModuleEmit program process emission.
6. **Sister faces found here** (reported with their call sites, not edited): the definition view's UDP shape for a
   non-lvalue first concatenation (`EmitHelpers.h` `isNetLvalueSyntax`: its `ConcatenationExpression` branch does not look
   inside, so `ch a142 ({1'b0, w1}, ...)` loses its ref_module; v11u171 Q/c07, c12, UD/u3 stay stage 1);
   pass 171's rp32 DEPTH face (§ pkgFnCastTopListing172, ExprEmit); Scr1SvTests' call-argument formal typespec;
   CovMacro's `$root` path full name; ibex_multdiv_fast's generate-block enum constants; TypeParameterAsPortTypeWithEnum
   x4 (the enum copy ParamEmit `emitParameters` makes).
7. **Report only** (unchanged): InterfaceModPort endcol(12) (the interface variables' `logic_typespec` ends past the
   keyword, 27:21 against golden's 27:8: the language-mode face the harness's `-sverilog`/`-sv` split may explain);
   LogicTypespec endline(3); PreprocTest endcol(2); HierPathTypespec t fullname(1); ClassTypeParam; cfg_func_width_loop,
   const_cast_signext, mem_read_reg; UnitElabBlock endline(13); the cast law's generate-scope face (CC/u17: `w`'s full name
   inside a generate block) and interface face (CC/u27, stage 1); the positional generic port (PG/g05, g10) and the
   generic port in a multi-port program (g15, g16), stage 1 on both; OneNetModPort's residue list of pass 164 is closed.
8. Not attempted: pass 168's include-file undef residue (v11u168 U/y10), the modport `.p` shorthand and wildcard grids,
   delays in interface instances (r11u173 N3: the elaborated interface cont_assign's parameter delay; the interface
   listing shares the definition object, ModuleEmit `emitInterfaceInstance`), the generate array indexed by a
   struct-parameter member (r11u173 N2), YosysRiscv's spaced based literal column, CovMacro's macro-argument columns.

## 9. Files

* `cases/{CC,PG,PQ,F3,GE,TD,UD}/`: 105 law cases (first line `// § <law>`; `TD/td01`, `td02` carry a `files` list).
* `drivers/`: `env.sh` (pins, `$FENCED` from RESUME.md, fail closed), `case.sh` / `caseE.sh` (a case against its golden,
  default / `--elabuhdm`), `grid.sh` / `gridE.sh`, `switches.sh`, `sweep.sh`, `row.sh` / `rowrec.sh` (a row's strict
  records), `obrow.sh` (order-blind distance), `predict176.cpp` + `predict176.sh` + `cc176.sh` (the mover predictor),
  `bvmirror.sh` (fence-clean mirrors), `attrib.sh` / `uvmtrace.sh` / `probeattrib.sh` (mover attribution),
  `uvmcensus_sweep.sh` (the UVM census, r11u175's scripts in place), `boundary.sh`, `judge.sh`, `dscase.py`.
* `evidence/`: `prediction/` (the predictions, timestamped before their sweeps), `sweeps/` (sweep logs, byte
  verification, attribution, order-blind distances, UVM file facets, canaries, the probe conversions and changes),
  `grid/` (default and `--elabuhdm` verdicts, all-off bytes), `grid_switches.txt`, `boundary_movers.txt`,
  `boundary_summary.txt`, `multifile_grids.txt`, `downstream_cases.txt`, `rows/` (first records of the reported rows,
  base and final), `uvm_*` (the census).
