# r11u241 — module/type ground: the UVM first records of item (1)

Pass 241 (PAIR B refill after pass 239), base `23a9a439`, worktree `/tmp/wt_r11u241`. Ground: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`, `uhdm_main.cpp`. This pass touches
`src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp` and adds `src/R241.h` (switches + `R11U241_TRACE`).

Six laws, each behind its own switch; `R11U241_OFF` drops all of them (pristine bytes on 74 of 74 case-views).
`R11U241_TRACE=<dir>` writes `<dir>/<pid>.241`: `OUT <-o path>` then one `<law> <detail>` line per write (a
`..._shared` line is an abstention and writes nothing).

## Verdicts per targeted row (before -> after; no row converts)

| row-mode | base | after | first record after |
|---|---|---|---|
| BuildUVMPkg d/t | `differ:line(16)` #81218 | `differ:file(8)` #81827 | #81218 (uvm_driver `REQ req; RSP rsp;`) cleared; next: a `begin` with no location (the foreach body in `uvm_port_component::get_connected_to`, golden uvm_pkg.sv 45157:26-45159:8, ours 0:0): StmtEmit, **ground A** |
| Scoreboard d | `differ:file(11)` #80496 | `differ:fullname(3)` #81633 | the uvm_driver face cleared; next: the `ref_obj addr` inside `predict_info.addr[...]` (golden `uvm_pkg::uvm_reg_predictor::write::predict_info.addr[]::addr::addr`, ours `...::write::addr`): ExprEmit hier_path naming, **ground A** |
| SimpleUVM d/t | `differ:line(8)` #75572 | `differ:line(4)` #75572 / #75584 | same first record (the late-bound net mint, the sister r11u240's item); the uvm_driver face (#80104) behind it cleared |
| MiniAmiq d/t | `differ:fullname(8)` #68597 | `differ:fullname(4)` #71388 | #68597..#69885 cleared (assoc-array full names, then the struct formal location, then the struct local's own copy and members); the walk now reaches 1011 more golden objects (433138 -> 434149 of 435559). Next: the nested-block fixed array `int q[5];` in the copy `svaunit_pkg::uvm_table_printer::emit` (golden lists the element var twice, under the begin with full name `...::emit` and under the array_var; ours once): StmtEmit nested-block locals, **ground A** |
| SeqDriver d/t | `differ:fullname(8)` #68553 / #68565 | `differ:fullname(4)` #71344 / #71356 | the same as MiniAmiq (the `adpcm_pkg` copy) |

Fresh csv rows (law sweep, `evidence/sweep_L_surelog.csv`):

    BuildUVMPkg,default,STRICT_NOTEQUAL,differ:file(8),,differ:file(8)
    MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)
    Scoreboard,default,STRICT_NOTEQUAL,differ:fullname(3),,differ:fullname(3)
    SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)
    SimpleUVM,default,STRICT_NOTEQUAL,differ:line(4),,differ:line(4)
    (testflags identical except Scoreboard testflags SLANG_REJECT as at the base)

**PROBE CONVERSION**: `r10v182repro/v182_g_names` `STRICT_NOTEQUAL differ:fullname(36)` -> `EQUAL`
(§ cloneLocalArrayTsParented241). results/ untouched.

## The laws

### § tpPropDefaultLoc241 (`R11U241_TPDEFLOC_OFF`; UhdmExporter emitClassParameters)
The class_defn listing is Surelog's compile of the class HEADER: a type parameter's class_typespec is located at the
header's written default. slang keys specializations on resolved arguments, so when `typedef uvm_driver
#(uvm_sequence_item, uvm_sequence_item) uvm_default_driver_type;` (or a member `drv #(item,item) d;`) is created
before `getDefaultSpecialization`, the "default" specialization the listing walks is that one and its parameter's
type syntax is the typedef's argument. The law reads the header default (`tpHeaderDefaultSyn188`) for class-typed
parameters; every holder located from the parameter's own object by § classTpDefaultTsAtUse180 / § tpGroupOneSpan234
follows (properties, chain members, array elements). BuildUVMPkg #81218, Scoreboard #80496, SimpleUVM #80104.
Cases TD d01 d03-d08 d10-d12 (d03: a specialization with other types, no move; d02: no typedef, control).

### § tpClsDefaultAtClassName241 (`R11U241_TPDEFCLSNAME_OFF`; same site)
A parameterized class default `type REQ = base #(2)` ends at the class name (compileTypespec populates from the
class-name node), the rule § classPropElemClassTsAtName196 reads for a property element. Pre-existing face that the
first law exposed in d09 (line -> endcol); d13 is the no-typedef control (endcol at the base). Cases TD d09, d13.

### § cloneLocalArrayTsParented241 (`R11U241_CLONEARRTS_OFF`; TaskFuncEmit makeQueueDynArrayVar / makeAssocArrayVar, drain in UhdmExporter exportDesign)
An importer's copy of a subroutine is Surelog's UHDM DeepClone of the home object: the copy's local array_typespec is
parented at the clone's ref_typespec (the home's has no parent), so UHDM's lazy `VpiFullName()` gives the
ref_typespecs under it (element, index, the associative marker constant's) the local's full name. MiniAmiq #68597
(`uvm_factory_queue_class sorted_override_queues[string]` in `svaunit_pkg::uvm_default_factory::print`). The parent
is set design-final, after every drain: set at the site it changed an unrelated MiniAmiq typespec name (stage 1,
measured on the first build). Guard (refinement found by the census): the parent is set only when every ref_typespec
binding the array_typespec sits inside that copy and is not a home variable re-parented into it — StmtEmit's
`arrayVarArrayTs` binds the LAST emission's array_typespec, so in `r10v208repro/v208_f_io` the home loop variable
`p208a_vf::fh208vf::i208`, re-parented under the copy's foreach, reads the copy's object, and golden's keeps no names
there (the unguarded law added 4 wrong full-name records, count 15 -> 19; guarded: pristine bytes). Cases AA a08
(converts, both views), AA a01-a11 (stage 1 at the base on another face, below).

### § cloneAggTsAtHomeListing241 (`R11U241_CLONEAGGLOC_OFF`; drain in UhdmExporter exportDesign, copies recorded in TaskFuncEmit emitTaskFuncs)
Every enum / struct / union typespec an importer copy holds for a typedef of the copy's HOME package carries the
location of the home's definition-listing object as the home compile left it — compileTfPortList's
populateCoreMembers moved it to the type token of the typedef's LAST formal writer. Decisive case CF e03: golden's copy
of `f1(k_t a)` reads f2's `k_t` token 9:29, not its own 4:29; e01: an out-of-body definition's formal 10:27. Ours
minted the copies at the typedef (the writer laws move the listing object design-final, after the copies exist). The
drain copies file and span from the def listing (`typedefTs`) onto every such typespec a ref_typespec inside an
importer copy binds; it abstains on a typedef of another package (CF e09, e13 are stage 1 at the base: unmeasured),
on ambiguous names, and on an object bound outside any copy (`..._shared`). MiniAmiq #69885
(`uvm_printer_row_info row` in `format_row`, golden 651:42), g180_a_kinds #1067. Cases CF e02-e04, e09-e13.

### § cloneAggLocalOwnCopy241 (`R11U241_CLONEAGGCOPY_OFF`; inside the same drain, off with it)
A copy's reference bound to a LISTING object (the importer's re-listing: MiniAmiq `uvm_printer_row_info row_info;` in
`print_object_header` read the svaunit_pkg listing at 212:46) or to a struct/union it does not own (the memoized
per-source formal copy of § importCopyAggFormalOwnCopy32) is, in golden, the deep clone's own object hanging off its
ref_typespec: one private copy per reference (alias, instance, base, constants shared: every judge-read field stays
the source's), at the home location. Cases CF e05-e08.

### § cloneAggMemberOwn241 (`R11U241_CLONEAGGMEMB_OFF`; same drain)
The deep clone's struct/union members are its own: each typespec_member (and its ref_typespec, member type shared)
is copied under the copy, so a member's full name reads through the copy's chain (golden
`q::pr::fmt::row::p::row_t::name`, ours `work@top.p::row_t.name`), and a one-level member path `v.m` in the copy whose
root holds a copied aggregate binds the copy's member. Without it the walk lists a shared member set once (MiniAmiq
#70107 depth). Case CF e01 (both views convert).

## Grid (`drivers/grid.sh`, `evidence/grid.txt`, `evidence/grid_summary.md`)
38 cases (TD 13, CF 13, AA 11 + d13), both views, 9 binaries/configurations each: 666 runs, every line carries rc
(rc=0 on all but TD d05/d08, rc=4 "unsupported constructs" on every binary including pristine).
74 case-views: `R11U241_OFF` == pristine 74/74; 22 enter STRICT_EQUAL, 0 leave; per-switch reverts TPDEFLOC 18,
TPDEFCLSNAME 4, CLONEARRTS 18, CLONEAGGLOC 24 (includes COPY and MEMB), CLONEAGGCOPY 22, CLONEAGGMEMB 16.
The case first lines were renamed to their final law names after the grid (comment line only; no output byte depends
on it). Downstream on six cases (TD d01 d10, CF e03 e05 e12, AA a08): IDENTICAL on pristine and law.

## Gates (law binary md5 `219ff84f7dff1511eef8b7a819ed2a61`, pristine `aa9012ebb7b3104475c0e59866e01645`)
- (2) probe: EQUAL 3481 + STRICT_NOTEQUAL 606; regressions=0 conversions=1 changes=6.
- (3) surelog regressions=0 conversions=0 changes=9 (the nine UVM row-modes above); uhdm2rtlil 0/0/0 (1606 + 0).
  Pristine sweep: all three stages 0/0/0 (EQUAL 3480 + 607). Row join pristine vs law: exactly the nine rows differ.
- (4) downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict diff vs
  results/downstream_uhdm2rtlil.csv 0. Census: no downstream lane fired.
- (5) every touched row-mode and probe case stays judge-equal (STRICT_NOTEQUAL or EQUAL).
- (6) byteverify on fence-filtered mirrors (`drivers/bvmirror.sh`, 2560 each, 8 fenced paths skipped by name):
  PATH_SETS_IDENTICAL, MOVERS 9/2560, SELFCHECK 2559/2560. Probe databases: 12 movers. **All 21 movers predicted by
  name** before the law sweep (`evidence/predict.txt`, md5 `5618b3d25a78b5bb915076f11f0c7fb4`, from the firing
  census `drivers/census.sh` + `dscensus.py` + `predict.py`, `--filter` built from $FENCED); no unpredicted mover.
  Probe changes: g180_a_kinds line(5) -> fullname(1) (the copy enum location cleared; next #1244 a home-side member
  full name), g193_c_argface fullname(102) -> (44), g193_d_propfence (10) -> (4), t42a line(35) -> (29),
  v181_h_nofe name(7) -> fullname(2), g207_c_share fullname(13) -> (16): the walk diverges later (pristine's #256
  member-order divergence cleared; the added records are pre-existing nested-typedef member full names inside copies,
  `<in>bt207h` raw `p207b_h::fboth207::...` vs `bt207h`), chain away 0, toward 60.
- Away census (`drivers/awayrows.py`, chain-keyed, variant comparator `drivers/strictcmp_x.cpp`): 21 databases,
  **away 0 on every one**, toward 3073 (MiniAmiq 834 per mode, SeqDriver 557, the three uvm_driver rows 9 each).
  Flat key: MiniAmiq 30, SeqDriver 20, v181_h_nofe 1 flat-away records (one sampled: a member ref full name
  `trebuchet_imp::trebuchet_home::springald_t::onager` that pristine matched at another chain position).
- Canaries: surelog ok=45 changed=7 (the seven predicted canary row-modes), u2r ok=16 changed=0;
  ctcan2 surelog PASS (ok=58, unknown 1), u2r PASS (ok=2, unknown 6).
- Determinism (`drivers/det.sh`): three concurrent draws of Earlgrey_0_1 and the five UVM rows, both modes: one hash
  per row-mode, equal to the law sweep's (`evidence/det_law.txt`).

## Residues, ranked
1. MiniAmiq / SeqDriver #71388 / #71344 (ground A, StmtEmit): a nested-block fixed array in a copy; the element var
   listed under the begin with the block's full name and again under the array_var. The fixed-array sites
   (TaskFuncEmit's body-local fixed array, StmtEmit's nested `makeTypespec(bm)`) do not take
   § cloneLocalArrayTsParented241.
2. BuildUVMPkg #81827 (ground A, StmtEmit): foreach body `begin` unlocated in a generic-class method.
3. Scoreboard #81633 (ground A, ExprEmit): hier_path member naming `predict_info.addr[]::addr::addr`.
4. Clone stage-1 faces at the base (not this pass's writes; bytes move, cmp line counts unchanged): a body-local array
   with a keyword element or index type (`int`, `string`) in a class-method copy (AA a01 a03-a07 a09-a11: a
   typespec vpiInstance names the def-view package where golden names the elaborated one); a struct local in a
   class-method copy without a formal of that type (CF e08); unpacked union typedefs in a copy (CF e10, e11); a third
   package's typedefs in a copy (CF e09, e13); a module-scope typedef of a class specialization (TD d05, rc=4); a
   class inside a module (TD d08, rc=4); a package-qualified typedef of a specialization (TD d12).
5. Nested member paths (`v.a.b`) in a copy bind the shared member below the first level; enum copies keep shared
   constants (no measured difference).
6. Home-side member ref full names (`work@top.p::k_t.hi` vs ours `p::p::k_t::hi`: CF e04, e07, g180 #1244).
7. TD d07 ($unit class + typedef): location cleared, an extra ours-only class_typespec record remains (depth).
8. Brief items (2)-(5) and (7) not attempted; (6) the ground-A faces stand as decoded by passes 238/239.

## Sister-ground faces (decode only)
- ExprEmit hier_path naming: Scoreboard #81633.
- StmtEmit: BuildUVMPkg #81827 (foreach body begin location), MiniAmiq/SeqDriver #71388/#71344 (nested fixed array
  element listing), and `arrayVarArrayTs` binding the last emission's array_typespec (v208_f_io: a home foreach
  variable reads the copy's object; this pass abstains there).

## Drivers (`drivers/`; every one reads $FENCED fail-closed)
`env.sh`, `case.sh`, `grid.sh`, `gridsum.py`, `census.sh`, `dscensus.py`, `predict.py` (an `_shared` line is not a
write), `bvmirror.sh`, `det.sh`, `awayrows.py`, `cc_x.sh` + `strictcmp_x.cpp` (copied from r11u238repro).

## Process
- Worktree `/tmp/wt_r11u241`, scratch `/tmp/r11u241_*`; the main checkout was never written; no submodule
  initialised. Pristine built and frozen before any edit (md5 equal to the main tree's).
- Every tool reached through a variable was guarded (`[ -x ]` in env.sh / case.sh).
- Two law sweeps were stopped and discarded (the binary changed after the census exposed v208_f_io and an early-return
  path that skipped the drains: `exportDesign` returns before the writer loop when no typedef has a writer, so the
  drains now run in a `finish241` wrapper on every exit). The census, prediction and sweep cited are the final
  binary's. The stopped sweep's processes were checked by this pass's own workdir name only.
- No fenced test was dispatched, read or opened outside the gate sweeps; every evidence csv has the fenced rows
  stripped; corpus scans were done only through path lists filtered by $FENCED (byteverify on mirrors).
