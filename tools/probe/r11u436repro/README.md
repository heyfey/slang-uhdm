# r11u436: the module/type ground, pair B (the sv-tests campaign's eighteenth pass on this ground)

Base `c0096a9a` (branch matrix-1.87). Files of the ground touched: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp` and `src/UhdmExporter.cpp` (TaskFuncEmit, uhdm_main.cpp, EmitHelpers.h,
ExprEmit, StmtEmit, ParamEmit and include/ unchanged). Seven laws, each read through
`src/LawSwitch.h` (`lawOn(436, "R11U436_<LAW>_OFF")`), `R11U436_OFF` drops all of them,
`R11U436_TRACE=<dir>` logs each firing through `lawTrace(436, ...)`. No `src/R*.h`, no LawState.h
section, no getenv, no reader function, no new include.

Pristine = the master's control sweep at the base, `/tmp/intr11u434` (its five csvs equal the
committed results/*.csv); for case runs the main tree's `build/slang-uhdm`, frozen as
`/tmp/r11u436_pristine.bin` (md5 `3da951e1eb1969ab5fc9812f41f9725a`; the worktree's own first
build of the base gave the same md5). The final law binary `/tmp/r11u436_bin/law19`
(md5 `5763a78b4576322e97b9fa6267effdb3`).

## Verdict per targeted row (fresh rows of the law sv-tests stage; results/ untouched)

FOUR sv-tests CONVERSIONS, 0 regressions, 0 changes:

| row | base | law |
|---|---|---|
| `generated/hdlconv_std2017/hdlconvertor_std2017_p203.sv` | DIFFERENT | `...p203.sv,EQUAL,,equal` |
| `generated/hdlconv_std2017/hdlconvertor_std2017_p334.sv` | DIFFERENT | `...p334.sv,EQUAL,,equal` |
| `generated/hdlconv_std2017/hdlconvertor_std2017_p719.sv` | DIFFERENT | `...p719.sv,EQUAL,,equal` |
| `generated/uvm-examples/apb_protocol_monitor.sv` | DIFFERENT | `generated/uvm-examples/apb_protocol_monitor.sv,STRICT_NOTEQUAL,differ:col(1),differ:col(1)` |

sv-tests at the law: EQUAL 1903 -> 1906, STRICT_NOTEQUAL 0 -> 1, DIFFERENT 37 -> 33, BOTH_REJECT
303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; the csv differs from the
control in exactly these four rows (evidence/svtests_vs_control.diff).

Attribution (evidence/trace_census.txt): p334 through § genClsNoDefRangeSyntax436 alone (its
head at the base the `ENCODER_f` return `logic_typespec` 2:17-2:37 missing its `[ENCODE_W-1:0]`
range, four typespecs in all); p203 through § clsSpecSurelogOrder436 alone (its head at the base
`class_typespec(C) > type_parameter(p)` in golden against our `type_parameter(T)` for
`C#(1, real) v2`, and the named `C#(.p(2), .T(real)) v3` listed with a parameter golden does not
write); p719 through § nestedModGateUpwardNet436 alone (its head at the base golden's
`logic_net work@dff_nested.i1.nq1` minted in the nested instance against our null, 17 nets
and 22 terminal bindings in all, plus the definition-view gate names); apb_protocol_monitor
through § uninstIfaceAssertListing436 (17 firings: 9 property and 1 sequence declarations, 16
assertions in the interface definition), § cgArrayElemUnsupportedTs436 (`APB_accesses_cg
APB_protocol_cg[no_slaves]`) and § ifaceDefArrNetDimSym436 (the `[no_slaves]` bound kept
symbolic), now judge-equal with one strict field left: the left side of
`APB_protocol_cg[i] = new();` (145:5-145:23 ours, golden the index 145:21-145:22), a select
emitted by the sister's ground (below).

## The gates (one full five-stage sweep; the sv-tests stage rerun alone on the final binary)

The full five-stage sweep ran on `law17` (`tests/sweep.sh --jobs 3 --workdir /tmp/r11u436sw1`
from the worktree, `R11U436_TRACE` on). Its sv-tests stage read the worktree's empty UVM tree
(every UVM row failing on both tools: a path artefact, not a measurement), so that stage was
rerun alone through the main tree's `scripts/check_svtests.py` with the worktree's baseline
(drivers/svstage.sh), on `law17` and again on the final `law19`, both reading the csv above
(identical to each other on all 2346 rows). `law19` differs from `law17` only inside
§ ifaceDefArrNetDimSym436 (the `$unit` parameter binding of an instantiated interface, below),
whose trace fires on no probe case, no surelog or uhdm2rtlil row and no downstream database, so
the four corpus stages of the `law17` sweep stand for `law19`; the grid and the earlier-pass
census were rerun on `law19`.

- probe: EQUAL 4019 + STRICT_NOTEQUAL 68 of 4087, regressions 0, conversions 0, changes 0, the
  csv identical to the control; the 4087 databases identical to the control's by path-normalized
  dump (positive control: a database against another case's reads DIFF).
- surelog: default CMP_EQUAL 480, testflags 474, regressions 0 / conversions 0 / changes 0; the
  csv differs from the control only in the two LowMem log-path texts.
- uhdm2rtlil: 803 / 1 / 67 in both modes, 0 / 0 / 0, the csv identical to the control.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871, the csv
  identical to the control.
- sv-tests: regressions 0, conversions 4, changes 0 (above).
- byteverify against the control: 0 of 962, 0 of 1608, 0 of 805 with the self-checks passing
  (evidence/byteverify.txt).
- canaries ok=52 (surelog) and ok=16 (uhdm2rtlil), changed 0; ctcan2 PASS on both
  (`EXPECT_UNKNOWN=1` and `=6`).
- the trace census: the laws fire on five sv-tests databases, the four conversions and rsd
  (SURELOG_CRASH, unjudgeable: 386 firings of § ifaceDefArrNetDimSym436 on its interface
  arrays), and on no corpus row or probe case (evidence/trace_census.txt).
- the corpus UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg) byte-identical
  to the control in both modes (byteverify), so their strict counts stand.

## The laws

- **§ genClsNoDefRangeSyntax436** (TypeEmit makeTypespec, switch `R11U436_NODEFRANGE_OFF`). In the
  listing of a parameterized class whose parameter has no default (slang's invalid
  specialization, the listing of § genericClassNoDefaultListed408), a subroutine's return,
  argument or local written as a vector over the unset parameter (`logic [N-1:0]`) is an error
  type in slang, and ours wrote a bare `logic_typespec`. Surelog compiles the declaration with no
  value for the parameter: each written packed dimension is a range at its brackets whose bounds
  are the unreduced syntax, a reference to a parameter an unbound `ref_obj` with no full name, a
  `bit` keyword keeps its `bit_typespec` and a written `signed` its vpiSigned. Cases DL dl01 to
  dl03, dl05 to dl09, dl14 to dl19, dl21, dl23, dl24, dl26. One flag written across files:
  `g436InvalidSpecCls`, defined in TypeEmit, written only by UhdmExporter's
  `genericClassNoDefault408` (the class it lists), read only by makeTypespec, checked for
  membership and never iterated.
- **§ genClsNoDefPropRange436** (TypeEmit makeTypespec and noDefPropRangeOk436, UhdmExporter
  genericClassNoDefault408 and the class property variable; switch `R11U436_NODEFPROP_OFF`). A
  PROPERTY of such a class written as a vector keyword with `[l:r]` packed dimensions over
  default-less parameters only, with no unpacked dimension, in a class declared at `$unit` or in
  a package: the class is listed now (pass 408 abstained on an error-typed property), the
  property is the keyword's variable (`bit_var` for `bit`, `logic_var` otherwise) and its
  typespec carries the same ranges with the references named through the variable
  (`work@C::v::N`, `p::C::v::N`). A bound reading a parameter WITH a default (`int M = N * 2`)
  is substituted by Surelog at a property's bound (DL/dl13) and abstains, as does a system call.
  Cases DL dl04, dl10 to dl13, dl20, dl22, dl25.
- **§ clsSpecSurelogOrder436** (TypeEmit makeTypespec, the module-variable specialization
  listing after § classSpecExprArgUnlocated202; switch `R11U436_SPECORDER_OFF`). A module
  variable written as a class specialization lists only its WRITTEN arguments, as Surelog's
  compileDatastructureTypespec walks the written Ordered_parameter_assignment list against the
  class's ordered formals (CompileType.cpp, the ClassDefinition branch): a type formal with no
  written argument is not listed (CS cs09, cs10), a NAMED argument list lists nothing (cs03,
  cs04), and an argument pairs with Surelog's ordered formal, where a header `type T` written
  without its own keyword after a `parameter` value declaration is compiled before the header's
  value parameters (`#(parameter p = 2, type T = int)` orders T, p; `C#(1, real)` names its entry
  p, located at p, with the value formal p as the param_assign's Lhs: cs02, cs07, cs08). Cases CS
  cs01 to cs16.
- **§ nestedModGateUpwardNet436** (ModuleEmit emitGates and drainNestGateDefRefs436, called from
  UhdmExporter's final287; switch `R11U436_NESTGATE_OFF`). A gate in a NESTED module definition
  whose terminal names a net of the enclosing module gets, in each elaborated instance of the
  nested module, an implicit `logic_net` (vpiNetType 1) of that name at its first terminal use,
  listed after the instance's own nets in first-use order, the terminal bound to it; the
  definition view's terminal binds the FIRST instance's net, and the definition view's gate is
  named through the enclosing definition (`work@dff_nested.work@dff_nested::ff1.g1b`), its
  terminal references keeping the gate's own scope. Cases NM nm01 to nm12.
- **§ uninstIfaceAssertListing436** (ModuleEmit emitInterfaceDef, the uninstantiated branch;
  switch `R11U436_IFCUNINST_OFF`). An UNINSTANTIATED interface's definition lists its named
  sequence and property declarations and its concurrent assertions, as the module road's
  definition view does (the module road's listing transcribed, its own laws keeping their own
  switches), every reference in them left unbound like the processes beside them: a formal mints
  no net, and a reference naming a listed property or sequence declaration carries no actual
  (UnbindDecl436). Pass 424's § ifcConcAssertListed424 lists an instantiated interface's
  assertions; this is the uninstantiated twin. Cases IU iu01 to iu06.
- **§ cgArrayElemUnsupportedTs436** (TypeEmit makeTypespec, the vector fallback; switch
  `R11U436_CGARRAY_OFF`). The element of an array of covergroup handles (`cg cgs[N];`) is the
  covergroup branch's `unsupported_typespec` named after the written type, as a single handle's is,
  where ours wrote a `logic_typespec`; in an interface definition it spans the declaration from
  the type through the declarator. Cases IU iu08, iu09, iu12, iu13.
- **§ ifaceDefArrNetDimSym436** (TypeEmit buildUnpackedRanges, the size-form dimension; the flag
  `ifaceDefArrNet436` written only by ModuleEmit's makeIfaceDefArrayNet225 around its call;
  switch `R11U436_IFCDEFDIM_OFF`). An interface definition's `array_net` keeps a parameter-sized
  `[N]` symbolic (`ref_obj work@ifc.arr.N`, unbound, minus an unparented `INT:1`), as the
  port-view branch of the same branch already does: Surelog never reduces an interface definition.
  In the definition of an INSTANTIATED interface a `$unit` parameter's reference is bound to the
  design-level parameter (Surelog's late binding; v11u432 VD/vd06, IU/iu15), in an
  uninstantiated one it stays unbound (iu14). Cases IU iu07, iu10, iu11, iu14 to iu17.

## The grid (71 case dirs in CS, DL, IU and NM; drivers/grid.sh, evidence/grid_law19.txt)

Every exit code 0 on both binaries. `R11U436_OFF` gives pristine's bytes and exit code on 71 of
71; each case's own switch gives pristine's bytes on 69, the two others (IU/iu07 and iu10) needing
`R11U436_CGARRAY_OFF` too (both laws fire on a covergroup array sized by a parameter).

- 44 NOT_EQUAL -> STRICT_EQUAL, 1 STRICT_NOTEQUAL fullname -> STRICT_EQUAL (NM/nm10);
- 1 NOT_EQUAL -> STRICT_NOTEQUAL col (IU/iu12, the sister's select span, below);
- 11 controls byte-identical and STRICT_EQUAL on both (CS cs01, cs05, cs06, cs13 to cs16,
  DL/dl06, IU/iu05, NM nm05, nm09);
- NOT_EQUAL on both binaries and closer by sorted dump distance: DL/dl18 60 -> 30, dl21 57 -> 6,
  dl22 185 -> 8, IU/iu10 58 -> 33, iu13 28 -> 22, iu17 36 -> 21 (uhdm-cmp line counts that grow
  do so because the head moved later in the walk);
- byte-identical residues NOT_EQUAL on both: CS/cs12, DL/dl13, dl14, dl15, dl20, IU/iu04,
  NM/nm02; DL/dl19 has no golden (Surelog rejects `logic [N]` as a packed dimension).

Downstream (the uhdm2rtlil plugin, drivers/dsgrid.sh, evidence/downstream_cases.txt) on the 17
class-free NM and IU cases: IDENTICAL on both binaries, none worse.

## The earlier-pass census (4689 fence-filtered case dirs of passes 401 to 434)

drivers/bytecensus.sh, both binaries writing the same output path in turn
(evidence/earlier_pass_census_all.txt): exit codes equal on all 4689; 5 dirs move, every one
toward golden (evidence/earlier_pass_census_movers.txt):

- v11u424 VI/vi12 NOT_EQUAL -> STRICT_EQUAL (pass 424's residue: an uninstantiated interface's
  assertion; § uninstIfaceAssertListing436);
- v11u408 VG/vg15 NOT_EQUAL -> STRICT_EQUAL (pass 408's residue: a method local sized by the
  default-less parameter; § genClsNoDefRangeSyntax436);
- r11u408 GC/gc05 NOT_EQUAL -> STRICT_EQUAL (pass 408's residue: a property sized by it;
  § genClsNoDefPropRange436);
- v11u432 VD/vd06 NOT_EQUAL -> STRICT_EQUAL (pass 432's interface array over a `$unit`
  parameter; § ifaceDefArrNetDimSym436, whose `$unit` binding this case decided);
- v11u424 VP/vp06 NOT_EQUAL on both, closer (dump distance 131 -> 13; a module variable
  `C #(...)` whose unwritten type formal golden does not list; § clsSpecSurelogOrder436).

## Goal 1

Nothing on this ground: re-grepping the detail column of results/golden_svtests.csv, no
SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row carries an exporter message; all 75 SURELOG_ONLY
rows carry an upstream slang front-end diagnostic (`expected a declaration name` 5, unknown
modules, time-scale, real-type and local-member diagnostics among them).

## Residues (all wrong on pristine too, none moved away), ranked by rows

1. The 16 uvm-examples rows other than apb_protocol_monitor. Re-measured at the base with pass
   426's design-level tracer (evidence of pass 426, tools cmptrace2): uvm_messaging_example's
   first heads are still the `this_type` class_typespec's vpiInstance of uvm_pool (golden
   TOP uvm_pkg), then the class_typespec of `m_uvm_factory_type_pair_t.m_type` (vpiInstance TOP
   uvm_pkg, ours null), then the `uvm_field_flag_t` alias chain under `uvm_radix_enum`;
   uvm_test_init and uvm_generation_seq_poly head at the elaborated enum copies' vpiInstance
   (golden the importing test package) for `uvm_radix_enum`, `uvm_recursion_policy_enum`,
   `uvm_core_state` and the `uvm_id_verbosities_array` class_typespec. Not written.
2. The 3 uvm_scoreboard testbench rows: the tracer reads the golden design handle itself as
   null (`L=null R=design`), so nothing can be matched; easyUVM not decoded further.
3. The 8 basejump rows with the `inv` placeholder default (control_slave, comm_link_checker,
   mem_1rw_sync_assoc, scheduler_dataflow, ascii_writer, dff_en_segmented at the design's module
   list; round_robin_fifo_to_fifo and mesh_stitch at a typedef range, round_robin's sorted dump
   distance 10906 lines at the base), p737 (the default-less type parameter top), tnoc (a
   Surelog artefact) and fx68k and p733 (the sister's, below).
4. The laws' own residues: CS/cs12 (a class PROPERTY written as `C#(3, byte)` goes through the
   class-property listing, which still pairs by member order and names `C.T`); DL/dl13 (a property
   bound over a defaulted parameter, which Surelog substitutes with the default's tree at the
   use: abstained); DL/dl14 (a class with a type parameter, which pass 408 does not list);
   dl15 (a default-less class declared inside a module); dl18 (an argument with an unpacked
   dimension: the io_decl's range is still missing); dl20 (a property with an unpacked or queue
   dimension: abstained); dl21 (a function local `bit [N:0]` is a `bit_var` in golden and a
   `logic_var` in ours; the local's variable class); dl22 (a property initializer `= '0` that
   golden keeps as a constant and ours drops); NM/nm02 (a continuous assignment in a nested
   module, whose definition-view reference golden binds to the OUTER module's net); IU/iu04 (an
   INSTANTIATED interface's property declaration, listed in golden under the definition and the
   instance with the last instance's name and its formal minting an instance net); IU/iu10 (the
   elaborated interface instance lists a covergroup array as an array_var golden does not
   write); IU/iu17 (the range form `[0:N-1]` of an interface array keeps `N-1` unreduced in
   golden: the range-form branch of buildUnpackedRanges, not written).
5. The carried lists of passes 434 and earlier (the brief's items (a) to (y)), untouched.

## Sister-ground faces (reported, not written)

- apb_protocol_monitor's last strict field: `APB_protocol_cg[i] = new();` inside a foreach in an
  uninstantiated interface's initial block; golden's left-side `bit_select` spans the index
  (145:21-145:22), ours the whole select (145:5-145:23). The select of an assignment's left side,
  ExprEmit's element-select emitter under StmtEmit's assignment; case IU/iu12 (9:9-9:10 against
  9:5-9:11), the same shape in a module (iu13) differing first at the foreach loop variable
  (golden `ref_var i`, ours `int_var i`, StmtEmit's foreach).
- fx68k's head at the base: the elaborated port connection `.bAdd((oper != OP_SBCD))` of
  `aluCorf`, golden a constant UINT:6 at size 64 where ours keeps `ref_obj OP_SBCD` bound to the
  `$unit` parameter (ExprEmit's operand fold; pass 432's residue and pass 433's target).
- p733: Surelog does not apply a defparam from another top (ParamEmit; carried).

## Process

The implementer ran one full five-stage sweep on `law17` and reran the sv-tests stage alone twice
(on `law17` after the worktree's UVM path artefact, and on the final `law19` after the narrowed
`$unit` binding of § ifaceDefArrNetDimSym436); the intermediate binaries `law1` to `law16`, and
`law18`, ran on case runs and targeted runner calls only (the pristine runner call on the 37
DIFFERENT rows to keep their pairs, and the law rows p334, p203, p719 and apb). `law17` is a
rebuild after a comment-only edit giving `law16`'s md5. Slips, none affecting a measurement: the
first sweep's sv-tests stage ran from the worktree, whose UVM tree is empty, so its 156 UVM rows
failed on both tools (the stage was rerun alone through the main tree, its first output kept
aside as `svtests_badpath`); the build of `law4` once copied the main tree's binary when a
script failed before the build (removed before any run); a grid of four cases and two builds ran
while the sister r11u433's surelog verification was live (about 01:47; nothing else overlapped,
every sweep and census waiting for a quiet reading first). The fence list was read into a file by
a program without printing it, and the earlier-pass census list filtered on it before any file
was opened; no other agent's process touched, no fenced test named, opened or run.
