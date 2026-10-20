# r11u418 — the module/type ground, ninth pass of the sv-tests campaign

Implementer pass on base `a39e1069a` (pass 416). Ground: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` (TaskFuncEmit and uhdm_main
unchanged). Eleven laws, each read through `src/LawSwitch.h`
(`lawOn(418, "R11U418_<LAW>_OFF")`). `R11U418_OFF` drops them all, and
`R11U418_TRACE=<dir>` logs each firing. There is no src/R*.h, no getenv and
no reader function.

## Result

sv-tests stage (the final binary, against the base golden
`a39e1069:results/golden_svtests.csv`): **regressions=0, conversions=21,
changes=0**.

| status | base | this pass |
|---|---|---|
| EQUAL | 1803 | 1816 |
| STRICT_NOTEQUAL | 6 | 11 |
| DIFFERENT | 131 | 113 |
| SURELOG_ONLY / BOTH_REJECT / SLANG_ONLY / SURELOG_CRASH / TIMEOUT | 75 / 303 / 19 / 8 / 1 | the same |

Conversions, with the law that moved each row:

| row | before -> after | law(s) |
|---|---|---|
| generated/basejump/bsg_clk_gen_BaseJumpSTL_bsg_dram_clk_gen.sv | STRICT_NOTEQUAL differ:fullname(138) -> EQUAL | § tdKeptParentMemberNames418 |
| generated/basejump/bsg_cache_BaseJumpSTL_bsg_cache_to_test_dram.sv | STRICT_NOTEQUAL differ:fullname(2) -> EQUAL | § defGenPartSelBoundRefMember418 |
| generated/basejump/bsg_noc_BaseJumpSTL_bsg_wormhole_router.sv | STRICT_NOTEQUAL differ:fullname(1) -> EQUAL | § tdMoveRenamesBitSelect418 |
| generated/hdlconv_std2017/hdlconvertor_std2017_p791.sv | DIFFERENT -> EQUAL | § genGateTermGenNetBind418 |
| generic/class/class_test_53.sv | DIFFERENT -> EQUAL | § classTpUnitTdAliasClone418 |
| chapter-16/16.9--sequence-{changed,fell,past,rose,stable}-uvm.sv (5 rows) | DIFFERENT -> EQUAL | § ifcFileScopeImportListing418, § thisNetFirstListingModule418, § hoistNetsFirstModule418, § unitVarRefMintsNet418 |
| chapter-16/16.7--sequence-{intersect,throughout}-uvm.sv, 16.15--property-iff-uvm.sv (3 rows) | DIFFERENT -> EQUAL | the same four |
| generated/uvm_classes_1/uvm_{agent,driver,env,monitor,scoreboard,sequencer,test}_class_1.sv (7 rows), testbenches/uvm_agent_env.sv | DIFFERENT -> STRICT_NOTEQUAL differ:value(3) | the same four plus § modportImplicitHdrNoNetType418 |

The 8 STRICT_NOTEQUAL rows' last face is the sister's (see below): the
interface listing's import copies of untyped arithmetic uvm_pkg parameters
(`UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1`) read INT in golden and UINT in
ours, and then the interface parameter order.

Trace census on the sv-tests stage (evidence/svtests_firing.txt): the laws
fire on 61 rows.
- 21 of them are the conversions above.
- 3 are SLANG_ONLY and 1 is SURELOG_CRASH (rsd); no status change.
- 36 stay DIFFERENT.
- Away census on the 36 DIFFERENT rows plus rsd (evidence/away_census.txt,
  drivers/away.sh): an exact multiset distance (`comm -3` over sorted,
  id-stripped dumps) against golden, control database against law database.
  **40 of 40 move toward golden, 0 away.** A first census used `diff` over
  the sorted dumps. It flagged 3 rows "away" (easyUVM/top,
  uvm_slave_agent_multi_seq_item, uvm_use_models_pipelined_get_put), but
  `diff`'s heuristic is not a multiset distance on million-line files. On
  multi_seq_item the only change is the `this` wire moving from
  `work@hdl_top.this` (control) to golden's `work@hvl_top.this` at 968:29
  (180 of golden's 183 bindings). The `comm` census reads all three toward.
- The chapter-16 rows still DIFFERENT moved their uhdm-cmp head from the
  interface (659173 lines) to 32-432 lines.

## Corpus gates

These are the final sweep's corpus stages.

| stage | result |
|---|---|
| probe | EQUAL 4018 + STRICT_NOTEQUAL 69; regressions 0, conversions 0, changes 0. The csv is byte-identical to results/golden_probe.csv. **4087 of 4087 databases are STRICT_EQUAL against the master's control** (/tmp/intr11u416/probe). |
| surelog | 480 + 0 default, 474 + 0 testflags; 0/0/0. The csv differs from the control only in the two LowMem log-path texts. |
| uhdm2rtlil | 803/1/67 in both modes; 0/0/0. The csv is identical to the control. |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The csv is identical to the control. |

- **byteverify against the master's control** (evidence/byteverify.txt,
  SELFCHECK=1): surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805.
  The path sets are identical and every selfcheck flagged all but the
  reference file.
- **Movers predicted: none.** The trace census confirms it: no law fires in
  the surelog, uhdm2rtlil or downstream stages. The positive control for the
  trace is the probe stage of the same sweep environment, where
  § ifcFileScopeImportListing418 logs 5 firings (r10uvm201repro g201_f_kinds,
  r10uvm223repro a8_unit, r10v199repro v199_d_ifprog, r10v201repro
  v201_h_ifprog, r10v223repro v7_filescope_noimport_iface). All 5 databases
  are STRICT_EQUAL to the control.
- Canaries: ok=52 changed=0 (surelog) and ok=16 changed=0 (uhdm2rtlil). Both
  ctcan2 checks PASS (EXPECT_UNKNOWN=1 and 6).
- Binary audit, fence-filtered:
  - surelog: 1573 records; 1523 name the binary under test and 50 hold no
    slang line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346 name the final binary.
- Determinism: three concurrent draws of chapter-16/16.9--sequence-past-uvm
  with the final binary read one md5.

### Which binary ran each stage

- The corpus stages (surelog, uhdm2rtlil, downstream) ran on law binary 13
  (`5644ba1c…`).
- That sweep's probe stage read 3 regressions:
  - r10uvm148repro/g148_b_scope
  - r10vbuvm31repro/gv31a6
  - r11u75repro/grid/w8_unitname

  In all three, § unitVarRefMintsNet418 minted a wire for a `$unit`-variable
  name that a nested scope redeclares, or that is the base of a dotted method
  call.
- The law was narrowed:
  - every name declared anywhere in the module text abstains;
  - an identifier that is the left side of a member access or a dotted name
    abstains.
- These cases were added to the grid: UV/uv11, uv12, uv13.
- On the final binary (`6786a1ce…`), only the affected probe stage was rerun:
  0/0/0, csv identical to the golden, 4087 of 4087 STRICT_EQUAL to the
  control.
- The narrowing touches only that law. It fired nowhere in the surelog,
  uhdm2rtlil or downstream stages (trace), so those stages' bytes stand for
  the final binary.
- The sv-tests stage ran on the final binary.
- tests/LAWS.md is regenerated in the patch.

## Laws

1. **§ tdKeptParentMemberNames418** (UhdmExporter typedefParentModel134,
   `R11U418_KEPTTDNAMES_OFF`).
   - Surelog stores no full name on a struct or union typedef's member
     ref_typespecs. ComputeFullName reads them through the typedef's final
     parent.
   - The last-writer rename ran only for objects whose parent CHANGES.
   - A package typedef's shared import clone is built with package-style
     `p::s_t::clk` names by ParamEmit's clone branch. When ModuleEmit already
     parented that clone at its definition-view module, it kept those names.
     This happens for a definition-only module, behind `--top`, in its own
     file, reached by a file-scope `import p::s_t;`.
   - Golden: `work@bsg_dram_clk_gen.bsg_tag_pkg::bsg_tag_s.clk`.
   - The law hands such objects to the same rename: struct and union
     typedefs whose last writer is a module, interface or program and is
     already the parent.
   - Grid KN, kn01-kn12. The two-file cases (pk.sv + m.sv) reproduce; the
     one-file twin kn09 does not.
2. **§ defGenPartSelBoundRefMember418** (TypeEmit emitSyntaxExpr member-select
   branch, `R11U418_PSBOUNDREF_OFF`).
   - ComputeFullName skips the parent's name for a ref_obj child of a
     bit_select or an indexed_part_select, but never of a part_select.
   - So a `[l:r]` bound that is one reference reads
     `...addr[A - 1:B].addr.B`. The existing branch dropped `.addr`.
   - Context: a definition-view generate block's member part-select
     (bsg_cache_to_test_dram:292).
   - Grid PS: 10 cases convert. Indexed and bit-select controls ps07 and ps08
     are unchanged; the elaborated ps09 moves toward golden.
3. **§ tdMoveRenamesBitSelect418** (UhdmExporter typedefParentModel134,
   `R11U418_TDMOVEBITSEL_OFF`).
   - A bit_select is a ref_obj too, and its stored name follows the moved
     typedef's chain.
   - Example: `logic [P[D]-1:0] cord;` in a module-body struct whose last
     writer moves it reads `work@m.h_s.cord.P` in golden. Ours kept `h_s.cord.P`
     (bsg_wormhole_router).
   - Grid BS.
4. **§ genGateTermGenNetBind418** (ModuleEmit buildGate,
   `R11U418_GENGATENET_OFF`).
   - A gate terminal naming a net declared in a generate block binds that
     net.
   - The plain gen-scope logic_net is filed in genScopeNets but not in
     netMap, the same store § caGenScopeNetNamesakeStore75 consults (p791).
   - Grid GG: 9 NOT_EQUAL -> STRICT_EQUAL. gg11 needs law 5 as well.
5. **§ unnamedGateTermDefName418** (ModuleEmit buildGate,
   `R11U418_UNNAMEDGATETERM_OFF`).
   - An unnamed gate's selected terminal names through the gate's definition
     name: `work@m.b[0].work@xor.a`, where ours wrote `work@m.b[0]..a`.
   - A udp is left out (UG/ug08 reads neither form).
   - This is pass 402's VG/vg16 face.
   - Grid UG.
6. **§ classTpUnitTdAliasClone418** (UhdmExporter emitClassParameters,
   `R11U418_CLSTPUNITTD_OFF`).
   - A class type parameter whose default names a `$unit` typedef of a
     built-in type binds a clone of the listing object.
   - The clone is named after the typedef, sits at the typedef's span, is
     parented at the type parameter, and carries a vpiTypedefAlias ref
     `<param>::<typedef>` to the listing.
   - The listing is no longer re-parented at the parameter.
   - A package typedef binds its listing (golden GT = mypkg::GlueType). An
     alias of an alias, an aggregate and a class typedef are not reached.
   - Grid CT (class_test_53).
7. **§ ifcFileScopeImportListing418** (ModuleEmit emitImportArtifacts,
   `R11U418_IFCFILEIMP_OFF`).
   - An interface lists its file's `$unit` imports exactly as a module does:
     the class-key publication, the typedef listing and the subroutine
     hoist.
   - Golden's interface and module listings are line-identical in order: 127
     typedefs and 979 task_funcs on the chapter-16 rows.
   - Applies only to an interface with no body import.
   - Grid IF.
8. **§ thisNetFirstListingModule418** (TypeEmit thisImplicitNetBoth38,
   `R11U418_THISFIRSTMOD_OFF`).
   - The `this` wire's home is the first AllModules entry whose listing holds
     the routine of a qualifying reference, not the top.
   - Golden: tn01 `sub` declared before `top` holds work@sub.this; tn02 `top`
     before `zsub` holds work@top.this. In chapter-16, `clk_gen` holds it.
   - Grid TN, two-file cases. A one-file case meets the class-listing face
     below first.
9. **§ hoistNetsFirstModule418** (ModuleEmit bindHoistedClassPropRefs,
   `R11U418_HOISTFIRSTMOD_OFF`).
   - The forwarded late binding runs once. The first definition that
     materializes the package mints the wires and binds the shared
     references; a later definition mints nothing.
   - Golden: `clk_gen` holds the 170 forwarded wires and `top` its own 55.
     Ours minted them in both and bound top's.
   - Grid HN.
10. **§ modportImplicitHdrNoNetType418** (ModuleEmit elaborated modport io_decl
    clone, `R11U418_MPIMPLNETTYPE_OFF`).
    - An implicit-typed interface header port (`input clk`) gives its modport
      clone no net type. `input logic` keeps 36 and `input wire` keeps 1
      (uvm_classes_1).
    - Grid MP.
11. **§ unitVarRefMintsNet418** (ModuleEmit mintUnitEnumNets,
    `R11U418_UNITVARNET_OFF`).
    - A `$unit` variable never resolves from a module. Golden lists no object
      for it and late-binds a module reference to a bare wire at the first
      reference, as for another file's enum constant: `string label` in
      every chapter-16 `*-uvm.sv` row.
    - The law abstains on names declared anywhere in the module text and on
      dotted bases (the narrowing above).
    - Grid UV.

## Grid

120 case dirs in 11 groups (evidence/grid.txt).
- **Driver:** drivers/run1.sh.
  - A `TOP` file runs both tools with that top.
  - A `FILES` file lists several sources.
  - Goldens are cached per case text under /tmp/r11u418_scr.
- **Transitions:** 43 NOT_EQUAL -> STRICT_EQUAL, 27 STRICT_NOTEQUAL ->
  STRICT_EQUAL, 36 STRICT_EQUAL controls, 14 NOT_EQUAL on both.
- **Switches:**
  - `R11U418_OFF` gives pristine's bytes and exit code on 120 of 120.
  - Each group's own switch does so on 118. GG/gg11 also needs
    `R11U418_UNNAMEDGATETERM_OFF`, and KN/kn07 (an interface) also needs
    `R11U418_IFCFILEIMP_OFF`.
- **Cases whose status did not change** are byte-identical or move toward
  golden by dump-diff line count:
  - BS/bs11, CT/ct07, ct08, GG/gg09 (10 -> 2), IF/if03 and if06 (uhdm-cmp
    139 -> 17 and 536 -> 399), KN/kn11 (STRICT_EQUAL both, member names now
    golden's), MP/mp05, mp06, PS/ps09.
  - None moved away.
- **Downstream** (drivers/downstream_cases.py, evidence/downstream_*.txt):
  on the 88 class-free cases of the grid before UV/uv11-uv14 were added, UV/uv03 goes EQUIVALENT -> IDENTICAL. No case is
  worse.

## Goal 1

- Re-grepped the detail column at the base. No SURELOG_ONLY, BOTH_REJECT or
  SLANG_CRASH row carries an exporter error. All 75 SURELOG_ONLY rows carry
  an upstream slang front-end diagnostic (the should_fail rows, the
  basejump clock rows' time-scale error, the uvm-examples time-scale rows).
- The probe-only exit-4 shapes vh04, vh06, vc13, vy02, vu02 and aq09 are not
  written.
  - vc13 was decoded: golden spans the module typedef's class_typespec from
    the target 5:11 through the array declarator 6:13, and lists `arr` as a
    def-view logic_net typed by it.
- New, illegal SV, not written: an uninstantiated module behind `--top` with
  a packed union whose members differ in width exits 4 (`typedef target:
  ErrorType`). Upstream slang accepts it because the definition is never
  elaborated. BS/bs07 was rewritten to a legal union.

## Residues (ranked; all wrong on pristine too, none moved away)

1. 36 UVM rows still DIFFERENT, all moved toward golden:
   - 16.2, 16.12, 16.14, 16.17 and 16.7--sequence (11 rows, 108-116 cmp
     lines). Head: an elaborated interface net's `reg [7:0]` logic_typespec
     against an `array_typespec` of a class handle queue at line 1304. Not
     decoded.
   - 16.10, 16.11 (3 rows). The module net order: golden lists the `$unit`
     wire `label` before the implicit `x`.
   - 16.7 and/or/and-range, 16.13 (4 rows). An operation at 120:29, not
     decoded.
   - The uvm-examples, testbenches and uvm_classes_0/2/3 component rows. The
     package listing order, class listings and find_blocks, carried.
2. The 8 new STRICT_NOTEQUAL rows: the sister's interface parameter copies
   (below).
3. bsg_wormhole_concentrator_out fullname(1): a `$clog2` argument in an
   indexed part-select width in a definition-view port connection. It is
   ExprEmit's: emitExpr under ModuleEmit emitModuleDefPorts writes
   `work@m.u.i.N` where golden reads `work@m.u.i.h.cid[...].cid.N`. Reported.
4. p488: a direction-less ANSI net port (`module m(wire [31:0] bus, ...)`).
   Golden gives the port and net no typespec and no net type. A later
   direction-less port inherits the previous port's whole type (wp1-wp5 in
   the scratch, not written).
5. p719: references from nested module definitions to the parent's nets.
   Golden mints them as the nested instance's implicit nets.
6. CT/ct07, ct08: a class property typed by the type parameter binds a
   per-use clone named after the `$unit` typedef (`work@c::v::BrickType`).
7. The file-scope import self-duplicates a class's out-of-body method in its
   own package's class listing when the package and the import share a file
   (TN one-file variants). This is pass 409's OE/oe04 face.
8. IF/if03, if06: interface variables typed by a package or own typedef bind
   per-use copies (LAW S for interface variables).
9. An empty port connection `.d()` on an interface instance. Golden writes a
   high_conn operation of type 36.
10. MP/mp05 (`input signed clk`), MP/mp06 (two modports, the ref_module
    listing).
11. The carried backlog of passes 402 to 416 on this ground.

## Sister-ground faces (reported, not written)

- **ParamEmit:**
  - The interface listing's import copies of untyped arithmetic package
    parameters read INT where ours writes UINT, then the interface parameter
    order (`UVM_HDL_MAX_WIDTH`). This is the last face of the 8 new
    STRICT_NOTEQUAL rows (§ defImpArithSize32_409 covers modules only).
  - c3: a module type parameter whose default is a `$unit` typedef wants the
    same alias clone as § classTpUnitTdAliasClone418.
- **ExprEmit:**
  - The concentrator_out face (residue 3).
  - `$realtobits(r)` carries a ref_typespec to the 64-bit typespec in golden
    (p599, r1, r4, r5).
  - `$clog2` in a net declaration initializer (r3, depth).
  - The elaborated read of a `$unit` int variable folds to its initializer
    constant where golden keeps the ref_obj (uv2 in the scratch).
- **The mesh_router and decoder_dor faces** of pass 416 stand.

## Process

- **Budget:**
  - One full sweep. The corpus stages ran on law binary 13; the probe stage
    was rerun alone on the final binary after the narrowing; the sv-tests
    stage ran on the final binary.
  - Intermediate binaries got targeted runner calls only:
    - the 72 STRICT_NOTEQUAL and non-UVM DIFFERENT rows, twice;
    - the 65 UVM DIFFERENT rows once;
    - 4 interface rows three times;
    - the 137 targeted rows once on law binary 13.
  - No pristine sweep. The pristine reading is the master's control,
    /tmp/intr11u416. The worktree's first build equals the expected pristine
    md5 `18f76dd1…`.
  - The sv-tests stage ran through the main tree's scripts/check_svtests.py
    (identical to the base's) with `--baseline` set to the base's golden csv,
    since a worktree has no UVM tree.
- **Slips:**
  - One 4-row UVM runner call (law binary 11) overlapped the sister pass
    415's surelog stage, after a pgrep that printed 3 and was not acted on.
  - Two builds (law binaries 12 and 13) and the MP and UV grids ran while
    pass 415's separately launched sv-tests stage was live (03:05-03:11).
  - The final binary's probe-stage rerun (about one minute, cached goldens)
    overlapped the start of verifier v11u415's sweep.
  - None of these affected a measurement of this pass. The sister's
    measurements may have seen the extra load.
  - Every later step waited on the sister's PIDs.
- **Fence:** the fence list was read by a program from canaudit.sh's FENCED=
  line into a file and never printed. Every tree-wide reader was filtered on
  it. No fenced test was named, opened or run.
- **Processes:** only this pass's own processes were stopped: the ddmin
  reducer by its PID and a self-matching waiter by its task id.
