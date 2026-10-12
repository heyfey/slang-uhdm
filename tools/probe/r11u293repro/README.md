# r11u293 — module/type ground: clone return-name binding, def-view class array typespec end, hoisted package array element span, interface first-signal binding, port-view net declaration assignment parent

Base 28a27398 (pass 291). Six laws, all in ModuleEmit, behind `src/R293.h`. Each law reads its own
`R11U293_<LAW>_OFF` switch. `R11U293_OFF` drops all six and gives pristine's bytes on 116 of 116 grid case-views.
`R11U293_TRACE=<dir>` logs every firing (one file per process, `OUT <-o path>` first).

**TWELVE PROBE CONVERSIONS**, one shrinking probe change, no regression. No corpus database moves in bytes (0 of 2560
fence-filtered corpus databases), so no corpus row changes status or strict column.

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| r10uvm171repro/g171_a_pos | `depth(1)` | **EQUAL** | § cloneRetNameSelRefBindsHomeReturn293 |
| r10uvm171repro/g171_b_homes | `depth(1)` | **EQUAL** | § cloneRetNameSelRefBindsHomeReturn293 |
| r10uvm171repro/g171_c_shapes | `depth(1)` | **EQUAL** | § cloneRetNameSelRefBindsHomeReturn293 |
| r10uvm194repro/g194_c_clone | `depth(1)` | **EQUAL** | § cloneRetNameSelRefBindsHomeReturn293 |
| r10uvm221repro/grid221/a4_corpus | `endcol(2)` | **EQUAL** | § defNetClassArrTsDimEnd293 |
| r10uvm225repro/grid225/a6_headerforms | `endcol(4)` | **EQUAL** | § defNetClassArrTsDimEnd293 |
| r11u88repro/grid/i6_ifarray | `endcol(1)` | **EQUAL** | § pkgHoistArrNetElemDimSpan293 |
| r11u88repro/grid/y2_pkgvarkind | `endcol(1)` | **EQUAL** | § pkgHoistArrNetElemDimSpan293 |
| r11u93repro/grid/pb10_ifnetuse | `line(20)` | **EQUAL** | § ifaceFirstSignalBindsRefs293 |
| r11v93repro/grid/v15_ifdeclafterbody | `line(4)` | **EQUAL** | § ifaceLowConnFirstSignal293 |
| r11u90repro/grid.verifier/vx8_strifport | `fullname(2)` | **EQUAL** | § portViewNdaNetCellParent293 |
| r11v88repro/grid/v14_ndamodport | `fullname(2)` | **EQUAL** | § portViewNdaNetCellParent293 |
| r11v77repro/grid/vh_arrelem (change) | `endline(9)` | `endline(6)` | § pkgHoistArrNetElemDimSpan293 (3 element records toward golden, away 0) |
| probe | EQUAL 3929 + STRICT_NOTEQUAL 158 | **EQUAL 3941 + STRICT_NOTEQUAL 146** | regressions 0, changes 1 |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

All twelve conversions are STRICT_EQUAL in the elaborated view too (`EL=1`, measured with drivers/case.sh).

## Law 1 — § cloneRetNameSelRefBindsHomeReturn293 (switch `R11U293_CLONERETSEL_OFF`, ModuleEmit drainFuncRet)

**The face.** A package function writing a select of its own return name (`f[i] = ...`) is cloned into a package
that wildcard-imports its home. In the clone body golden binds every bare reference to the return name to the HOME
function's return variable (`string_var p1::f`). Ours bound the bare references that `endSelTrack` had bound to the
body's first select (`funcRetSelBound`) to the CLONE's own `bit_select` (`p2::f::f` at the select's line): the
strict walk expands that select under the ref_obj, `depth(1)`.

**The decode.** Surelog compiles the clone body in the importing package with every reference already bound to the
home's objects, so `UhdmWriter::lateBinding`'s first line (`if (ref->Actual_group()) continue;`) skips them and its
block branch (the scan for an assignment whose Lhs is a select of the name, the source of the home body's select
binding, § homeRetNameSelBindSurvivesDefViewUnbind194's decode) never answers in a clone.

**The law.** In drainFuncRet's clone branch (`pf.bindVar`, set only for wildcard-import clone bodies) a reference in
`funcRetSelBound` takes the same target as the other references of the clone (the home's return variable). The home
body keeps its select binding (CR/cr04 control). The out-of-body class method of the clone stays golden-null
(§ classRetNameDefViewNoBind37 runs later; CR/cr08 control).

## Law 2 — § defNetClassArrTsDimEnd293 (switch `R11U293_CLSARRDIMEND_OFF`, ModuleEmit materializeDefNetTs)

**The face.** A definition-view net of a class handle array (`C a_lof [];`, `pk::C b [2];`, `C q [$]`): golden's
class_typespec spans the type through the end of the FIRST unpacked dimension (37:4-37:23), ours the type (37:4-37:14).
Module, interface and program definitions alike; the elaborated element keeps the type span on both sides.

**The decode.** The same writeNets end-only populate `populateCoreMembers(InvalidNodeId, dimensions, ts)` that the
existing unpacked-array branch of materializeDefNetTs models (and § defNetTypedefEndWrite134 models on a shared struct
typedef). compileTypespec answers a class name with a fresh class_typespec per declaration, so the end moves on it too;
the branch was fenced by `ts->VpiName().empty()`, which a class_typespec never satisfies.

**The law.** The unpacked branch also takes a class_typespec when the declared array's element type is a ClassType
written directly (not a typedef and not a type parameter, whose objects are shared: CA/ca08 and ca09 unmoved). The
start stays (the scoped `pk::` start included, CA/ca06). An order-blind check of every class_typespec span of the CA
grid's stage-1 cases (ca02, ca04 to ca07, ca11, ca14 the macro form) reads the law's multiset equal to golden's.

## Law 3 — § pkgHoistArrNetElemDimSpan293 (switch `R11U293_HOISTELEMSPAN_OFF`, ModuleEmit hoisted import builder)

**The face.** The module's (or interface's) hoisted copy of an imported package array net (`st_t v_sarr [0:1];`):
golden's element `struct_net` spans the name through the end of the first unpacked dimension (19:21-19:33); ours the
name. Measured: struct elements (named, `wire`, nested, union, anonymous) and one-hop NAMED logic elements (`wire w_t
nw [0:1]`) take the span; the unnamed `wire [7:0] n [0:1]` element keeps the name (HE/he04); variable-road array_vars
keep the name (HE/he12); a multi-dimension declaration ends at its first dimension (he05).

**The law.** In the hoisted array_net builder (§ caImportedPkgHoistUnpackedBuilder80's element), a struct_net or
named (`hoistElemNamed80`) element spans the name through the first unpacked dimension.

## Law 4 — § ifaceFirstSignalBindsRefs293 (switch `R11U293_IFFIRSTREF_OFF`) and Law 5 — § ifaceLowConnFirstSignal293 (switch `R11U293_IFLOWFIRST_OFF`), ModuleEmit

**The face.** A non-ANSI interface port declared twice (`output [31:0] o;` and `wire [31:0] o;`) lists two nets
(§ caIfacePortDeclNetMint93). Golden binds every name reference (`assign o = ...`, `assign p = o`, processes, generate
blocks; the definition's shared cont_assigns re-pointed to the instance) to the FIRST signal the collect walk created,
which is the port declaration's mint when it is written first (pb10: 3:17, ours the body's 5:15). Where the body
declaration is written first, the port's Low_conn binds and is located at the BODY net (v15: golden ref_obj 3:15,
ours the port declaration's 5:17); the port itself keeps the port declaration's span.

**The decode.** bindVariable answers the first net of the name in the instance's signal vector; writeNets fills the
port's Low_conn on the first signal of the name (UhdmWriter.cpp:846-856, the LOW face of pass 93).

**The laws.** Law 4: the definition cont_assign rebind (netToVar) and the elaborated reads after LAW A's cells (whose
Lhs stays the body declaration's net) take the mint when it precedes the body net (logic_net bodies only: a `logic`
re-declaration is found among the variables, IF/if04 control). Law 5: the face-B Low_conn (def and elaborated roads)
binds the body net when it precedes the mint. IF/if11 (one port of each kind) needs both switches.

## Law 6 — § portViewNdaNetCellParent293 (switch `R11U293_PVNDAPARENT_OFF`, ModuleEmit interface port view)

**The face.** A modport port view of an interface net with a declaration assignment (`wire [31:0] w_plain = 32'd11;`):
golden's io_decl expression is a net parented at a cont_assign (located at the name, vpiNetDeclAssign) that no view
lists, with no stored full name, its ref_typespec named `w_plain`. Ours parented it at the io_decl with
`work@dut.u_s.p.mp.w_plain.w_plain`.

**The decode.** elabSignal builds the net-declaration-assignment cell for the port view's signals too
(`assign->Lhs(net)`, re-parenting the net), but the port view lists no cell (§ caIfaceElabNetDeclAssignListing88's
q6_ndaport).

**The law.** In the port view's fresh-net branch, a Net with an initializer passing LAW A's cell predicate
(`ifaceNdaCellMinted88`: no drive strength) gets an unlisted cell as its parent, no full name, and its ref_typespec
named by the net. A non-ANSI header port stands aside (its port declaration's signal comes first and carries no cell:
pb19_modportview and PV/pv06 keep pristine's bytes; a draft without this abstention moved pb19 `line(14)` ->
`fullname(16)` in a probe sweep and was superseded).

## Measurements (final law binary 390358c0, pristine 961af689 = the main tree's build at the base)

- **Grid** (cases/CR, CA, HE, IF, PV: 58 case dirs, each first line naming its law; 116 case-views, every line with
  its exit code, evidence/grid.txt, grid_summary.txt): 79 moving, 51 entering STRICT_EQUAL, 0 leaving, 0 exit-code
  changes, `R11U293_OFF` restoring pristine's bytes on 116 of 116; attribution by single switch: CLSARRDIMEND 24,
  HOISTELEMSPAN 20, PVNDAPARENT 16, IFFIRSTREF 12, IFLOWFIRST 3, CLONERETSEL 3, and IF/if11 default (both
  IF switches). Away census (drivers/awaycv.sh, order-blind and chain-keyed): lost 0 and chain away 0 on all 79 with
  319 records toward golden (evidence/grid_away.txt); the positive control (binaries swapped) reads away 1 to 20 on 6
  of 6 (grid_away_poscontrol.txt). Downstream (drivers/dscases.py, both binaries, 58 dirs): no verdict changes
  (51 IDENTICAL, 5 DIVERGENT, 1 EQUIVALENT, 1 STATUS_DIFF on both; the DIVERGENT ones are CR stage-1 cases where the
  module-level call fold differs, not this law's face).
- **Byte controls** (drivers/controls.sh over 25 earlier repro dirs: r11u88, r11u77, r11u80, r11v77, r11u275,
  r11u93, r11v93, r11u90, r11v88, r11u85, r10uvm221, r10uvm225, r11u130, r11v130, r11u134, r11u152, r11u202,
  r11u283, r11u291, r11u289, r11u82, r11v75, r11u224, r11u225, r11u223; 1215 case dirs, 2430 case-views, path lists
  fence-filtered before opening): 22 moving, 8 entering STRICT_EQUAL (the y2_pkgvarkind and i6_ifarray twins), 0
  leaving, 0 exit-code changes, chain away 0 on all 22 (r10uvm225 a12_modport reads flat away 1 with chain away 0).
- **Firing census** (drivers/tracecensus.sh, frozen before the law sweep, evidence/predict.txt, 335 lines): every
  byte mover was predicted by name. It OVER-PREDICTS: the § defNetClassArrTsDimEnd293 trace sits before the
  unpacked-array test of the branch, so it fires on every class-typed definition net including scalar handles (19
  corpus row-modes ApbSlave, ArrayMethodIterator, ClassFsm, ClassMini, ClassParamAsParam, ClassTypeParam, SVSwitch,
  Scoreboard, SimpleUVM d/t, OneClass d/t, and about 280 probe cases, none moving), and the
  § ifaceFirstSignalBindsRefs293 trace fires on the definition rebind map where no reference binds the net (pass 93's
  EQUAL interface cases, none moving).
- **Gate sweep** (tests/sweep.sh --jobs 3, law binary, exit 0, evidence/sweep_L.log): probe EQUAL 3941 +
  STRICT_NOTEQUAL 146, regressions 0, conversions 12, changes 1 (vh_arrelem endline -3); surelog default 478 + 2,
  testflags 472 + 2, regressions 0 conversions 0 changes 0; uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream
  IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0, not excused 0. Pristine sweep of the corpora (exit 1 on
  the law-index check alone, evidence/sweep_P.log): the same 0/0/0.
- **Byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors from
  drivers/bvmirror.sh, 8 fenced row-mode databases left out): MOVERS 0 / 2560 corpus databases, PATH_SETS_IDENTICAL,
  SELFCHECK 2559 / 2560. Probe byte compare: 15 of 4087 move (evidence/byteverify_probe.txt): the 12 conversions,
  vh_arrelem, and r10uvm134 g134_e_mult (class arrays, CLSARRDIMEND) and r10v194 v194_a_explicit (CLONERETSEL) staying
  EQUAL; away census on all 15: lost 0, chain away 0 (evidence/probe_movers_away.txt).
- **Canaries**: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both corpora.
- **Binary audit**: 3265 of 3315 cmds.txt name each sweep's own frozen binary on both sweeps, the other 50 carry no
  slang line (evidence/binary_audit.txt).
- **Determinism**: three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
  BuildUVMPkg and Rggen with the law binary: one hash per row-mode (evidence/determinism.txt).
- uhdm-cmp reads 0 lines on every converted probe case in both views.

## Residues (ranked; all wrong on pristine too)

1. **pb19_modportview** (`line(14)`): the modport PORT view of a non-ANSI interface port needs the port declaration's
   mint there too (io_decl net at the port declaration with the port's typespec; the port view's ports and Low_conns at
   the port declaration). Our port view mints nothing (pass 93: a port view lists no nets). ModuleEmit, this ground.
2. **Law 1's stage-1 neighbours**: CR/cr02, cr03, cr05, cr07, cr10 are stage 1 on both binaries on the package-function
   call fold (golden folds `return f(3)` to a constant; sister ground, the package function call folds), cr06 moves
   inside stage 1.
3. **Law 2's stage-1 neighbours**: fixed-size class arrays (CA ca02, ca04, ca05, ca07, ca11, ca14) are stage 1 on both
   binaries on the elaborated element's kind (golden `class_var` element under an `array_var`).
4. **Law 3**: a named import of a package array (HE/he11) and a named logic element (he03) are stage 1 on another face.
5. **Law 6**: a generic interface port (PV/pv04) is stage 1 on both binaries; a body-first non-ANSI header port with a
   declaration assignment and a modport is not modelled (abstains).
6. **The rest of the probe residue**: 146 first records (the base's 158 classified in
   evidence/residue_first_records_base.tsv, by first field: fullname 54, line 19, endcol 17, depth 15, type 14, file 11,
   col 8, name 7, endline 6, value 4, count 2, decompile 1). Located on this ground and not written: ordered type
   overrides that Surelog ignores (v11u111 y64, y65, x64; copying it would copy a Surelog defect), the escaped
   instance name end column (v11u110 a36, r10earl54 v3_v54: golden end three columns past ours on both), the instance
   array range parameter select (r10earl104 vb4_instarr), the class method return-name reference full name (r10uvm116
   g116_f).
7. Items (2) to (7) of the brief beyond the above were not attempted.

Sister-ground faces (ExprEmit / ParamEmit / StmtEmit; reported, not written): the package function call folds
(r10buvm13 v3_clone13, r10buvm8 v9fold8, r10uvm52 a1, r11v48 va8, and the CR stage-1 cases), the type-parameter
anonymous struct parenting (r11u47 g2, g10, g12, r11v47 v12, k14_unpacked, t13; § tpAnonStructLastParamUser167),
the struct-fold member names (r11u26 m4, m7, r11u28 a2), the package struct typedef stretch (r11u13 b3, r11u24 n4),
a3_inst66, v5_escaped, the gen-if fold reference names (r11u113 c09, c11), the r11u109 64-bit cast constants (a Surelog
defect).

## Process

- **Fence.** $FENCED was read fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line through
  drivers/env.sh and never spelled. The census ran through the harness filter built from $FENCED; the byteverify
  mirrors, the binary audit and the control path lists were filtered by word boundary before any file was opened. No
  fenced source or database was read or run. The main tree was not written. Evidence files hold no fenced name.
- **SLIP, no effect:** one wait loop of mine used `pgrep -f` with a pattern contained in its own command line; it was
  stopped by its own task id, nothing else was listed or signalled, and the wait was redone on the census output file.
- **Drafts superseded:** law 6's first cut sat on the netMap branch and never fired; its second cut fired on header
  ports and moved pb19 in a draft probe sweep; the final binary abstains there. Every number above is from the frozen
  law binary.
- tools/probe/r11u293repro: README, 58 case dirs in CR, CA, HE, IF and PV, drivers (copied from r11u291repro with
  gridsum293.py and ctlsum293.py new), evidence.
