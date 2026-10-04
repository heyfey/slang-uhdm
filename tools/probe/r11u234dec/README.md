# r11u234dec — map 15's thirteen nine-row UVM clusters, decoded and scratch-verified

Analyst pass, measurement only. Base e4650c14. The `src/` edits are NOT part of this directory. They are delivered as one
law patch outside the repository for the module/type pair to land:

* `/tmp/r11u234_law.patch` (md5 `9d78d04f8c8904ca16a5cc25845ff738`). It is a git diff against e4650c14 of
  `src/R234.h` (new), `src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp`, `src/ModuleEmit.cpp` and `src/UhdmExporter.cpp`
  (739 lines added, 1 removed). It applies cleanly (`git apply --check`, rc 0) both on a fresh e4650c14 export and on
  HEAD 212475d9e.

This directory holds no patch file.

The 13 targets are N0171, N0067, N0068, N0180, N0158, N0188, N0232, N0230, N0213, N0117, N0254, N0255 and N0256
(map 15, `tools/probe/r11u230map/cluster_index.csv`). All 13 stand on all nine judge-equal UVM row-modes: MiniAmiq
d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d and BuildUVMPkg d/t.

## Verdict

* **12 of the 13 clusters clear on BuildUVMPkg d/t.** Seven laws do it, each behind its own switch. `R11U234_OFF`
  drops all seven.
* **N0254 stands.** It was not reduced: every reduction reads stage-1 NOT_EQUAL at the base (see § N0254).
* **The first run left no README, so the counts below come from its logs and this run's re-measurements.**
  * On the other four rows, 10 of the 13 clear.
  * N0232 keeps 5 objects on MiniAmiq, SeqDriver, SimpleUVM and Scoreboard (a second shape: the type-parameter
    element `uvm_utils#(TYPE)::types_t`).
  * N0171 keeps 54 objects on MiniAmiq and 36 on SeqDriver (a second shape: `uvm_reg_addr_t` foreach keys).
  * N0254 stands on all nine.
* **No UVM row-mode converts.**
  * Gate: 0 regressions in all three stages.
  * Corpus: 5 changes, all shrinks of the first field's count.
  * Probe: 5 conversions and 1 change.
  * Downstream: 803/66/2/0 with a verdict diff of 0.
* **BuildUVMPkg does NOT convert,** even with the live pair B's named heads added. 28 clusters (125 objects) would
  remain; see § Residue.

## Binaries (frozen before any measurement; every cmds.txt audited by binary path)

| binary | md5 | use |
|---|---|---|
| pristine (e4650c14, the slang of 2026-09-29) | 1ed1fbc425479dc756e7d78a8c1ebdae | the first run's pristine sweep and the grid |
| law (e4650c14 + law patch, same slang) | 2b4659097cf4d9db387e6f08da057670 | the law sweep, the firing census, the grid, the switch-off runs, determinism |
| pristine.v12 (e4650c14 rebuilt against the installed slang 12.0.0+545f88b2e) | 2b10a6aba650891fbebb106059a59b0b | equals the main tree's binary at HEAD, as the brief predicted |
| law.v12 (the worktree rebuilt against slang v12.0) | 8ec72875b30b8728a4c8ea63cd7bf3ff | writes the law sweep's bytes on all 11 UVM and Earlgrey row-modes (evidence/v12_control.txt) |

Audit: all 3273 `cmds.txt` of the pristine sweep name `pristine`, and all 3273 of the law sweep name `law`.

## Per cluster: records at the base, reduced cases, golden's rule, the law

Records are map 15's analyzer rows on BuildUVMPkg default at e4650c14 (evidence/base_records_BuildUVMPkg_default.txt).
The cases are in `cases/<set>/`, and each `dut.sv` starts with a `// §` line. Grid lines are pristine -> law in both
views (`_el` = `--elabuhdm`/`-elabuhdm`), with all exit codes 0 (evidence/grid_final.txt).

### N0171, N0180, N0188, N0158, N0213: the uvm_enum_wrapper shape. Law § tpTdDefaultUseSharesListing234 (R11U234_TPTDUSE_OFF)

**Records** (`class uvm_enum_wrapper #(type T=uvm_active_passive_enum)`):
* N0213: `#96956/-1`. Golden binds the shared `enum_typespec uvm_pkg::uvm_active_passive_enum` (2 objects) under
  `enum_var < array_var(map)`. Ours lacks it, and binds a `bit_typespec` minted at the `T` token.
* N0158: `bit_typespec` depth 8 under `ref_typespec < enum_typespec(...)` in golden, depth 6 under `enum_var` in ours.
* N0171: `#97010/-1`. Golden has a `bit_typespec` (1 object) under `ref_typespec < enum_typespec < ref_typespec <
  ref_var(e)`; ours has none.
* N0188: `#97008/96998`. Golden names the `enum_typespec` `uvm_pkg::uvm_active_passive_enum`; ours is unnamed.
* N0180: `#97009/96999`. Golden's `ref_typespec` full name is `uvm_pkg::uvm_pkg::uvm_active_passive_enum`; ours is
  empty.

What these records show: golden's property `map`, local `e` and static `m` (written `T`) all bind the typedef's shared
listing object. Ours mints an unnamed, unlocated enum with no base type.

**Golden's rule:**
* Surelog's `compileTypespec` answers a type parameter's name with that parameter's own typespec (CompileType.cpp
  1998-2003, the `uhdmtype_parameter` branch).
* For a header default that names a package typedef, that typespec IS the typedef's object (CompileType.cpp 856-857,
  the TypeDef branch: `result = parent_tpd->getTypespec(); break;`).
* Enum, struct and union typedefs share that object. Scalar typedefs are cloned (the SimpleType branch), so they are
  excluded.

**Law:** TypeEmit.cpp, `makeTypespec` and `tpTdTarget234`, plus the array-element site in `UhdmExporter::classElemVar`.
* It applies to a property or an in-body local written as such a parameter, and to a chain member `type U = T`.
* It does not apply to an out-of-body definition (§ 87's fence).
* An overridden parameter counts only when the override names the default's own type (e20 against e21).

**Cases E** (20). Pairwise distinguishers:
* e02 against e01: no formal.
* e03 against e04: local against property.
* e05 and e06: extern.
* e07: struct.
* e08: scalar (a stage-1 case: it decides nothing).
* e09, e14, e15, e16, e18 and e19: compile order.
* e11: qualified default.
* e13: a chain.
* e17: a specialization (stage-1 at the base; the law makes it judge-equal).
* e20 against e21: the override.

Measured on E:
* 32 of 40 views convert to STRICT_EQUAL and none leaves it.
* e15, e18 and e19 were already EQUAL.
* e08 is stage-1 in both views and unmoved.

### N0266 / N0075 (not among the 13; pair B's N0266). Law § tpTdFormalWritesTypedef234 (R11U234_TPTDFORMAL_OFF)

This is the span half of the same shape.
* **Golden:** every holder of the shared enum object reads the last formal writer's type token, 9952:52 (`ref T value`
  in `from_name`).
* **Ours:** the typedef declaration, 7954:1.

**Rule:** compileTfPortList's `populateCoreMembers(type, type, ts)` (CompileStmt.cpp 1806-1809) moves the type
parameter's typespec, which is the typedef object, to the formal's token.

**Law:** UhdmExporter.cpp, inside the class-method writer collection. It adds the formal as a writer of that typedef,
so the landed order laws (§ tfArgClassMethodOrder176, § tfArgOutsideClassOrder216) pick the last writer.

**Overlap:** the live pair B r11u231 owns N0266 by its brief ("UVM_SEQ_ARB_TYPE (N0266)"). On BuildUVMPkg this law
takes N0266 from 17 objects to 1 and N0075 from 2 to 0. It is kept under its own switch so the landing pair can drop it
if pair B lands N0266 first. It is not needed for any of the 13: with it off, all 13 stay cleared
(evidence/switchoff_BuildUVMPkg_default.txt).

### N0067, N0068 (part), N0230, N0255: the uvm_sequencer_param_base group. Law § tpGroupOneSpan234 (R11U234_TPGROUP_OFF)

**Records:** `type REQ = uvm_sequence_item, type RSP = REQ` with `typedef REQ req_type; typedef RSP rsp_type;`.
* N0067 and N0068, `#87882` and `#87888`: the `class_typespec rsp_type` under the queue properties
  `m_last_req_buffer` and `m_last_rsp_buffer`. Golden: uvm_pkg.sv 53934:58-53934:61. Ours: no file, 0:0:0:0.
* N0230 (4 records): the same object under `type_parameter(REQ)` and three `io_decl`s. Golden 53934:58; ours 53928:58.
* N0255: the class typedef listing entry. Golden 53934:58; ours 53759:11 (the `RSP` token of the typedef).

**Rule:** golden holds ONE object for the group: the chain root's typespec (CompileType.cpp 1998-2003), named for the
winning typedef. `populateCoreMembers` (CompileStmt.cpp 1809) moves it to the type token of the LAST formal written with
a parameter of the chain.
* A writer is an in-body method or an extern prototype. Out-of-body definitions are not writers, and neither is a
  formal written with the class typedef (r05).
* With no writer, the object keeps the header default's token (r06).

**Law:** TypeEmit.cpp `classTpDefaultTsDrain180` (the plan read before § 180's moves). Holders are registered in
`makeTypespec`, `classElemVar`, `buildClassTypedefTs` and `emitTaskFuncs` (the return holder). Groups with no winning
typedef keep § classTpDefaultTsAtUse180.

**Cases R** (8). r02 has no typedef and is already EQUAL; r03 uses scalar properties; r04 has RSP-only formals; r05 is
the typedef-spelled writer; r06 has no formal; r07 uses in-body methods; r08 has a single parameter. **14 of 16 views
convert**, and r02 stays EQUAL.

### N0067, N0068 (the other 48 of 52 records). Law § retNameLocalClassTsAtType234 (R11U234_RETLOCALTS_OFF)

**Records:** 24 per cluster. The `class_typespec` of the per-reference return-name variable of an out-of-body method or
a package function returning a class handle. Examples:
* `function uvm_reg_map uvm_mem::get_default_map(); ... m_maps.first(get_default_map)`: golden 73223:10-73223:21 with
  an empty name; ours 0:0:0:0 with no file.
* `reserve_region`, `find`, `find_by_name`, `get_block`, `get_parent`, `allocate`, `get_field_by_name`,
  `get_register`, and others.

**Rule:** Surelog compiles the return variable with `compileVariable` over the function's return data type
(CompileStmt.cpp 2410), and it locates the class_typespec there.

**Law:** ModuleEmit.cpp `drainFuncRet`. When the class_typespec has no location, it is located at the written return
type.

**Cases F:**
* f01 (out-of-body), f03 (`first()`) and f04 (package function): the parse view converts (3 of 8 views).
* f02 (in-body) and every `_el` view are already EQUAL.

### N0232: a class-scope queue typedef of a class handle returned by a method. Law § clsTdClassElemRetSharesListing234 (R11U234_CLSTDRET_OFF)

**Record:** `#-1/162499`. Ours holds 5 objects that golden lacks: a twin `array_typespec` with a `Typedef_alias` under
`get_elements`'s return, for `typedef uvm_report_message_element_base queue_of_element[$]`. Golden returns the
typedef's own listing object (`array_typespec queue_of_element` 28180:11-28180:62).

**Rule:** CompileType.cpp 856-857. compileTypespec resolves the name through the class's TypeDef and breaks with its
typespec: no twin, no alias.

**Law:** TaskFuncEmit.cpp `emitTaskFuncs`. It is decided before the twin is built, and declines in three shapes:
* an element that is a type parameter (the twin is kept, per § queueTwinKeepsElem204v);
* an element that is a typedef name (gq01);
* a package-scope typedef (q05).

**Cases Q** (9):
* q01, q03 and q04 convert in both views. Their `_el` views were stage-1 at the base and are now judge-equal and
  STRICT_EQUAL.
* q08 and q09 `_el` go from stage-1 to STRICT_NOTEQUAL file.
* q02, q06 and q07 are stage-1 in both views and unmoved.

### N0117: a class-scope qualified formal without a direction. Law § clsScopeFormalQualSpan234 (R11U234_CLSQUALSPAN_OFF)

**Records:** 2. `unsupported_typespec uvm_resource_types::rsrc_q_t` on `rq` of `m_print_resources` and
`print_resources`. Golden 16625:35-16625:55 (the `uvm_resource_types::` qualifier); ours to 16625:63 (the whole name).

**Rule:** CompileStmt.cpp 1791, `NodeId type = fC->Child(tf_data_type);`. With no direction keyword, the data type
node's first child is the class_scope, and 1809 locates the typespec there. With a direction keyword, the data type is
the whole name.

**Law:** TaskFuncEmit.cpp `emitTaskFuncs`, the class-scoped formal branch.

**Cases U:**
* u01 and u05 convert in both views (4 of 10).
* u02 (`input`) is already EQUAL.
* u03 and u04 are stage-1 in both views and unmoved.

### N0256: a pure virtual prototype returning a specialization. Law § pureVirtRetSpecWholeSpan234 (R11U234_PUREVIRTSPAN_OFF)

**Record:** the `class_var` of `uvm_coreservice_t::get_component_visitor` (and its class_typespec, which is in N0051).
Golden 9111:24-9111:51 (`uvm_visitor#(uvm_component)`, the whole type); ours 9111:24-9111:35 (the name only).

**Rule:** a pure virtual prototype's return is not a listing site. Surelog compiles its return variable with
`compileVariable` over the whole return data type (CompileStmt.cpp 2410), `#(...)` included.

**Law:** TypeEmit.cpp `makeTypespec`. It suspends § 196's name narrowing for a `MethodPrototype` with `MethodFlags::Pure`.

**Cases V:**
* v01 converts in both views.
* v02 to v05 (a body, no specialization, extern, package function) are already EQUAL.

### N0254: a class-scope enum over a class-scope scalar typedef. NOT REDUCED, no law

**Record:** `#197929/197984`, the base `ref_typespec` of `enum_typespec override_e` in the `uvm_resource_types` listing.
Golden's full name is `uvm_pkg::uvm_resource_types::override_e`; ours is `override_e`.

The base ref is built at CompileType.cpp 1336-1340 (`baseTypeRef` under `en`). The full name golden writes on it is
the enum typedef's own full name. Where that name is written was not pinned in this pass.

**Cases N** (10). All read stage-1 NOT_EQUAL at the base in both views, so none decides anything:
* n09 (the typedef pair alone, unused): ours omits `override_e` from the class's typedef listing, which golden lists
  first.
* n01, n03, n04 and n07 (the enum read from a formal or property): ours binds a fresh, unnamed enum_typespec where
  golden binds the listing object.

These stage-1 faces sit on the module/type ground (`buildClassTypedefTs` / `emitClassTypedefs`) and must be fixed
before N0254 can be reduced. In UVM the row is judge-equal, so a larger context hides them. This is the first open item
for the next pair B refill.

## Per-law attribution on BuildUVMPkg default (evidence/switchoff_BuildUVMPkg_default.txt)

Each switch was set alone, against the law's 31 clusters.

| switch | the cluster objects it restores |
|---|---|
| R11U234_OFF | all 13 cleared clusters and N0266 / N0075; bytes = the pristine sweep's (6a6d62e38946) |
| R11U234_TPTDUSE_OFF | N0171 1, N0180 1, N0158 1, N0188 1; N0213's 2 objects return keyed as N0423 (+2), plus N0012 / N0034 (1 each) |
| R11U234_TPTDFORMAL_OFF | N0266 17, N0075 2 (none of the 13) |
| R11U234_TPGROUP_OFF | N0067 2, N0068 2, N0230 4, N0255 1 (and N0072 7 -> 12) |
| R11U234_RETLOCALTS_OFF | N0067 24, N0068 24 |
| R11U234_CLSTDRET_OFF | N0232's 5 objects, keyed `ours-only:fewer-copies` |
| R11U234_CLSQUALSPAN_OFF | N0117 2 |
| R11U234_PUREVIRTSPAN_OFF | N0256 1 (and N0051 16 -> 17) |

## Measurements

### Gate sweeps

`drivers/sweep.sh` was run with `tests/sweep.sh --jobs 3` (evidence/sweep_swP.log and evidence/sweep_swL.log).

**Pristine:** 0/0/0 in every stage.
* probe: 3453 + 634
* surelog: default 467 CMP_EQUAL + 13 STRICT_NOTEQUAL, testflags 463 + 11
* uhdm2rtlil: 801/1/67 in both modes
* downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT

**Law:** regressions = 0 in all three stages.
* **probe:** EQUAL 3458 + STRICT_NOTEQUAL 629. CONVERSIONS:
  * `r10uvm56repro/a5_argpos`: differ:file(4) -> EQUAL
  * `r10uvm56repro/a8_newlhs`: differ:file(2) -> EQUAL
  * `r10v158repro/v158_i`: differ:name(3) -> EQUAL
  * `r10v160repro/x09_struct`: differ:type(1) -> EQUAL
  * `r10v160repro/x10_enum`: differ:name(2) -> EQUAL

  CHANGE: `r10uvm56repro/a6_type` line(15) -> line(9).
* **surelog:** 0 conversions. CHANGES:
  * BuildUVMPkg d/t: line(14) -> line(12)
  * Scoreboard d: file(12) -> file(10)
  * SimpleUVM d/t: file(36) -> file(34)

  MiniAmiq and SeqDriver move bytes, but their first field and its count are unchanged.
* **uhdm2rtlil:** 0/0/0.
* **downstream:** 803/66/2/0, verdict diff 0. No downstream lane moved a byte.

`EXIT=1` in both logs is the harness's "law index STALE" note of the worktree's tests/LAWS.md, not a gate failure.

The law's credit for each change:
* `retNameLocalClassTsAtType234` fires on all ten probe uvm56/uvm69/buvm15 cases.
* `tpTdDefaultUseSharesListing234` fires on v158_i, x09_struct and x10_enum.
* The corpus rows' credit is in the per-law table above.

uhdm-cmp stays at 0 lines on every moved row: all are STRICT_NOTEQUAL or EQUAL, so stage 1 holds.

### Firing census and the byte-mover prediction

`drivers/firecensus.py` covered 8273 jobs: every surelog and uhdm2rtlil row in both modes, every probe case and every
downstream lane. 4 fenced jobs were excluded through the in-process filter.

**Prediction:** 22 jobs fired, so 22 movers were predicted. `evidence/census/prediction.txt` (md5 0f266daa…) was frozen
2026-09-29T16:37:48Z, before the law sweep.

**Measured:** byteverify (`tools/probe/r11v75repro/byteverify.sh`, same-length workdir names) found 9 corpus movers of
3373 databases and 0 downstream movers. A probe md5 join found 13 of 4087. That is exactly the 22 predicted names
(evidence/byte_movers.txt).

SELFCHECK reads 3371 of 3373 flagged. The two unflagged files are BuildUVMPkg d and t, which are byte-identical to each
other (6a6d62e3… in both modes) and to the fixed comparison file, so this is a property of the selfcheck file and not
a comparator fault.

**Census controls:**
* Exit codes are identical job by job between the law and pristine censuses.
* The pristine binary through the same census fires 0 jobs, which is the negative control.

### Away census, both keys, with the reversed control (drivers/awaypair.py)

The chain key is position-aware: a record is keyed with its ancestor chain.

**On the 22 movers** (evidence/away_movers*.txt):
* Chain key: 0 lost, 1167 toward. Flat key: 3 lost, 1141 toward.
* The reversed control reads 1167 / 1141 lost and 3 toward.

The 3 flat-key losses are one featureless record in Scoreboard d and SimpleUVM d/t: an unnamed, unlocated
`ref_typespec`. It is the base `ref_typespec` of pristine's minted enum under `ref_var e` in
`uvm_enum_wrapper::m_init_map`, the very object N0180/N0188 remove. Golden has none at that position, and the chain
key reads it as no loss. It counts as flat-key loss only because ours is short of that featureless record elsewhere
(golden 1264, pristine 1220, law 1219 on SimpleUVM). It moves nothing away from golden.

**On the grid** (evidence/away_grid*.txt, 181 moved case stores): 0 lost and 1330 / 1138 toward in the two keys, and
the reversed control reads 1330 / 1138 lost.

### Grid (cases E F R Q U V N + GE GF GQ GR GU GV)

The grid covers 116 cases, 232 case-views, and every exit code is 0 for both binaries (evidence/grid_final.txt). It holds
every case except n09 and n10, which were added in this run and measured at the base only (stage-1 in both views, rc 0).
* 129 case-views convert to STRICT_EQUAL and 0 leave STRICT_EQUAL.
* 10 go from stage-1 NOT_EQUAL to judge-equal.
* No uhdm-cmp line count grows; 12 views shrink.
* `R11U234_OFF` writes the pristine bytes on all 232 views.
* 4 case-views change their first field without converting, all toward golden:
  * GE ge14_modclass d/el: line -> fullname
  * GR gr06_virt d/el: line -> name

The fresh shapes the grid covers:
* both views;
* packages importing packages;
* `$unit` classes;
* specializations;
* nested classes;
* extern and out-of-body methods;
* virtual, static and pure methods and tasks;
* typedefs of typedefs;
* forward typedefs;
* fixed, queue, dynamic, associative and packed containers;
* two files, includes and macros;
* CRLF;
* module classes;
* unions and unpacked structs.

No law reads an expression, so there is no constant-slot check to make.

67 case-views are stage-1 at the base. They decide nothing and are listed as such in the grid file. 23 of them move
bytes while staying stage-1.

### UVM order-blind distance (r11u230map/drivers/uvmdist.sh; evidence/uvmdist.txt)

| row | base | law |
|---|---|---|
| MiniAmiq d/t | 1761 | 1648 |
| SeqDriver d/t | 1304 | 1155 |
| SimpleUVM d/t | 914 | 776 |
| Scoreboard d | 585 | 475 |
| BuildUVMPkg d/t | 230 | 145 |

### UVM family census (uvmcensus.py + uvmfamilies.py over map 15's index)

Base: 14,341 objects in 156 clusters. Law: 13,566 objects in 138 clusters (evidence/families_*.txt,
evidence/clusters_*.tsv). No new cluster appears on any row-mode, and none grows.

### Determinism (drivers/det.sh)

Three concurrent law runs were made per mode on Earlgrey_0_1 d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t,
Scoreboard d and BuildUVMPkg d/t. Every row-mode gives one hash, equal to the law sweep's, with rc 0
(evidence/determinism.txt).

### slang v12.0

law.v12 writes the law sweep's bytes, and pristine.v12 writes the pristine sweep's bytes, on the UVM and Earlgrey
row-modes (evidence/v12_control.txt).

## Residue (evidence/residue_uvm.tsv: per row-mode, every standing cluster with its ground, base objects and writer)

**BuildUVMPkg d/t** after the laws: 31 clusters, 132 objects, first record `line` (12).

**Ground A** (expression/parameter), 18 clusters:
* N0033 (26)
* N0025 (20)
* N0109, N0110, N2400 (3 each)
* N0197, N1050, N1051, N1079, N1080 (2 each)
* N0039, N0178, N0179, N0198, N0247, N0253, N1151, N2401 (1 each)

**Ground B** (module/type), 13 clusters, in the order the next pair B refill would take them:
1. **N0051** (16). The class_typespec endcol of a specialization. Its pure-virtual return part is now cleared, leaving
   other `#(...)` sites.
2. **N0161** (9). `uvm_callbacks::this_type` full name; golden prefixes `uvm_pkg::`.
3. **N0974** (9). An ours-only `this_type` class_typespec copy.
4. **N0423** (8) with **N0177** (2). An `enum_typespec recursion_state_e` copy (4 objects golden-only) and its
   `bit_typespec`.
5. **N0072** (7, was 12). **Pair B's head.**
6. **N0467** (2). An ours-only array_typespec.
7. **N0043** (1). struct_typespec `uvm_reg_bus_op`, the formal-writer lambda.
8. **N0120** (1). **Pair B's head.**
9. **N0203** (1). `uvm_pack_bitstream_t` ref full name.
10. **N0254** (1). See § N0254.
11. **N0264** (1). int_typespec endcol.
12. **N0266** (1, was 17). **Pair B's head**, the `uvm_status_e` face.

**Does BuildUVMPkg convert with these laws plus pair B's named heads (N0266, N0337, N0072, N0120, the package typedef
Instance link, the imported scalar typedef formals)? NO.** Taking all four named clusters out still leaves 28 clusters
(125 objects): 18 on ground A, and 10 on ground B (N0051, N0161, N0974, N0423, N0177, N0467, N0043, N0203, N0254,
N0264). The first record would then be N0423's `recursion_state_e` copy (`#74761`) on ground B, together with ground A's
N0025 / N0033 (`#153012` onwards).

**Other rows** after the laws:

| row | clusters (base -> law) | objects (base -> law) | ground B | ground A |
|---|---|---|---|---|
| MiniAmiq d/t | 130 -> 115 | 7147 -> 7027 | 63 clusters / 4865 objects | 52 / 2162 |
| SeqDriver d/t | 124 -> 109 | 4859 -> 4649 | 63 / 3321 | 46 / 1328 |
| SimpleUVM d/t | 64 -> 46 | 1590 -> 1390 | 16 / 974 | 30 / 416 |
| Scoreboard d | 54 -> 37 | 516 -> 368 | 11 / 110 | 26 / 258 |

The top ground-B items on those rows:
* MiniAmiq and SeqDriver: N0182 (1158 / 766), N0420, N0121 (462 / 299), N0478, N0492, N0571, N0538.
* SimpleUVM: N0565 (590), N2464 (179).
* Scoreboard: N0008 (45), N0051, N0262, N0161, N0337 (pair B).

Of the 13 targets, these still stand there:
* N0232's type-parameter face, `uvm_utils #(type TYPE=int)::types_t find_all` (5 objects on the four rows; the law
  declines a type-parameter element).
* N0171's `uvm_reg_addr_t` foreach-key face (54 objects on MiniAmiq, 36 on SeqDriver: 9-object bit_typespec copies under
  `ref_var(reg_addr) < foreach_stmt`).
* N0254.

## Drivers (`drivers/`)

The drivers resolve their paths from the repository. `env.sh` needs DEC_W and DEC_BIN exported, and reads FENCED
fail-closed from the FENCED= line of tools/probe/r11u107repro/canaudit.sh. Every tool is called through a variable
guarded with `[ -x ]`.

| driver | what it does |
|---|---|
| `case.sh` | one case, golden + ours + uhdm-cmp + uhdm-strictcmp; GW = the golden store |
| `grid.sh` | pristine / law / R11U234_OFF over every case in both views |
| `recs.sh`, `rowclusters.py` | map 15's analyzer over one database pair |
| `uvmrows.py` | the analyzer over the UVM rows of a sweep |
| `residue.py` | the ranked residue |
| `awaypair.py` | away census, both keys, REVERSE=1 control |
| `firecensus.py` | the firing census through the harness's own command lines |
| `det.sh` | determinism |
| `switchoff.sh` | the per-law switch runs on one row |
| `sweep.sh` | the gate sweep |
| `mkgrid.py` | writes the G* cases |

## Process notes

* The first run (2026-09-29) built the binaries, the sweeps, the census and the grid, then died before writing this
  README. This run re-read its draft and logs, and kept the law unchanged: the final law binary equals the worktree
  build.
* The grid was re-run with the final law binary, and its database md5s match the first run's grid line for line.
* This run added the cluster census, the distance, the away census on the movers and on the grid, the determinism
  runs, the switch-off attribution, the v12 control, n09/n10 and this README.
* Neither live pair has landed: `git log e4650c14..212475d9e` holds no r11u231 or r11u232 commit. The law patch is
  against e4650c14 and also applies to HEAD.
* No fenced row, source or database was opened or run. Every corpus loop filters by word from $FENCED.
* The scratch is `/tmp/r11u234_*`, about 5 GB.
