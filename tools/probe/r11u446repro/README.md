# r11u446 — module/type ground, pass 446: the uvm-examples importer-package family

Base e316b93a6 (pass 444). Implementer pass on the module/type ground
(src/ModuleEmit.cpp, src/UhdmExporter.cpp, src/TaskFuncEmit.cpp; TypeEmit,
uhdm_main.cpp, include/ and every sister file unchanged). Final binary
`law7`, md5 c56b0919304427814e2877f4a85aa234, linking slang
12.0.0+545f88b2e. The pristine reading is the master's control sweep at the
base, /tmp/intr11u444 (no pristine build, no pristine sweep; the frozen copy
of the main tree's build, md5 0ff84699b281f8ee9eb87dff63772efb, served the
case runs).

## Verdict

No sv-tests row converts: the 26 DIFFERENT rows stay DIFFERENT, with 0
regressions and 0 changes in every stage. This pass is the first one to work
the largest open cluster on this ground, the 17 uvm-examples rows (plus the 3
uvm_scoreboard rows and easyUVM, untouched). The failure population of every
importer row shrinks by 72% to 99%.

How the population was measured: pass 442's 36 "heads" and the earlier
cmptrace2 lists were mostly ONE face. UHDM's `package::Compare` inserts the
golden package into the visited set before it compares anything, and
`SafeCompare` reports a null rhs as `L=<owner> R=null`. So every typespec
whose vpiInstance leads into the uvm_pkg comparison reported the same
failure again, and seeding one typespec per run only exposed the next path
into it. The localizer used here (evidence/tools/clsloc.cpp) pre-seeds every
package, class_defn and module of the golden. It then compares every package
listing entry, every class method and every module on its own, so each
failure it reports is local.

Localized failures per row, pristine (master control) -> law7
(evidence/uvm_rows_localized_before_after.txt):

| row | pristine | law7 |
|---|---|---|
| uvm_messaging_example | 1607 | 18 |
| uvm_priority_arbitration | 1601 | 18 |
| uvm_priority_grab_lock | 1614 | 18 |
| uvm_use_models_unidirectional | 1600 | 21 |
| uvm_use_models_bidir_get_put | 1613 | 36 |
| uvm_use_models_bidir_item_done | 1613 | 36 |
| uvm_generation_seq_persistence / _poly / _randomization | 4783 | 57 |
| uvm_vif_config_db | 3212 | 75 |
| uvm_ac_config_db | 3223 | 78 |
| uvm_ef_vif_config_db | 3213 | 78 |
| uvm_id_register | 4829 | 121 |
| uvm_test_init | 12564 | 146 |
| uvm_many_to_one | 7870 | 1334 |
| uvm_param_vif_config_db | 5638 | 1628 |
| uvm_use_models_pipelined_get_put | 4703 | 2047 |
| easyUVM, the 3 uvm_scoreboard rows | 5 | 5 |

messaging_example, priority_arbitration and priority_grab_lock now fail only
on sister-ground faces (all listed below). Once those are written, they are
the next rows expected to convert. Every remaining failure of messaging_example
is in evidence/messaging_law7_loc.txt.

## Laws (switch `R11U446_OFF` drops all; `R11U446_TRACE=<dir>` logs each firing)

1. **§ clsLocalTdTopHomeInst446** (ModuleEmit, after § classKeyTsScopeOwner35;
   `R11U446_CLSTDTOPHOME_OFF`) — pass 426's face A. An unlisted class_typespec
   parented by its class_defn, whose vpiTypedefAlias target `P::N` is listed
   by package P's TOP view and not by its DEF view, takes P's TOP view as its
   vpiInstance. § 35 had stamped it with the last importer's DEF view. This
   was the first uhdm-cmp head of 12 rows (uvm_pool `this_type`). The rule
   holds on the goldens: 0 objects change on the uvm_messaging_example golden
   and 0 on SeqDriver's. Grid CT: ct01, ct04, ct05 and ct06 go NOT_EQUAL ->
   STRICT_EQUAL. ct02 (the specialization typedef in the importer) is a second
   face and is unchanged. ct03 is a control and is unchanged.
2. **§ aggCopyClassMemberHomeInst446** (UhdmExporter, design-final in final287;
   `R11U446_AGGCLSMEM_OFF`) — the null class_typespec member of a package
   struct's copies (`uvm_object_wrapper m_type` of m_uvm_factory_type_pair_t).
   For a named struct or union `P::N` with home package P, the class member
   takes:
   - P's TOP view, on an unlisted copy;
   - the copy's own instance, on a listed copy whose instance is a view of P;
   - P's DEF view, on any other listed copy (the importer's listing copy).

   Only a null class member moves. Grid SM: sm01 NOT_EQUAL -> STRICT_EQUAL;
   sm03 moves from record distance 82 to 16, its rest is the per-use struct
   copy's own instance (below); sm02 and sm04 are controls and stay equal.
3. **§ enumBaseAliasCopyBare446** (UhdmExporter, final287;
   `R11U446_ENUMBASEBARE_OFF`) — the case: an unlisted enum `P::N` (a per-use
   copy) whose base typespec's vpiTypedefAlias reaches a bit or logic
   typespec named `P::X`. That alias target is a listing object or a named
   copy, and has no alias of its own. Such an enum gets its own base copy,
   whose alias is a fresh bare copy named `X`, instanced at P's TOP view.
   Golden's compile-time copies are never qualified, so they keep the bare
   name. This was pass 442's heads #2 to #4 (uvm_radix_enum's
   uvm_field_flag_t). Grid EB:
   - eb01 and eb04 go NOT_EQUAL -> STRICT_EQUAL;
   - eb03 goes NOT_EQUAL -> STRICT_NOTEQUAL on name; the rest is a reference
     typespec in the importer's own function (ExprEmit);
   - eb02, with no importer, is a control and is byte-identical.
4. **§ importGroupKeepsHomeOrder446** (UhdmExporter, final287;
   `R11U446_IMPGRPORDER_OFF`) — an import group lists the home package's
   DEF listing verbatim. collectPkgTfListing (EmitHelpers.h, the sister's)
   orders a group by the raw declaration location, so it put the
   macro-written out-of-body methods last. These are uvm_packer's
   get/set_packed_bytes/ints/longints. Golden puts them at positions 227 to
   233 of messaging_pkg's 979 entries; ours put them at 947, which misaligned
   714 entries. Design-final, every package and module listing run that
   carries one import statement's key is re-ordered by the home's DEF listing
   names. A run is re-ordered only when every name is found once there. Grid
   IG: ig01, ig02 and ig03 (a transitive importer) go NOT_EQUAL ->
   STRICT_EQUAL, module listings included.
5. **§ clsBodyCallBindsHomeTopTf446** (UhdmExporter emitPackageClasses;
   `R11U446_CLSCALLHOME_OFF`) — a call written in a class of an importing
   package binds the home package's elaborated subroutine
   (pkgElabSubTf, with the formals' typespecs from it), not the importer's
   clone. The clone takeover of emitPackage is suspended for the class pass
   only and restored after it. Golden: agent_green::run_phase's `uvm_info`
   expansion binds uvm_report_enabled, uvm_report_info, uvm_report_warning
   and uvm_report_error in uvm_pkg TOP. SeqDriver reads the same and is
   invisible there, since the clone's body compares equal. Grid CB, measured
   by binding (evidence/cb_bindings.txt):
   cb01 to cb03 now bind p TOP as golden does, but their strict verdicts are
   unchanged on other faces. cb04 (an out-of-body method of the importer) has
   no class-body object in golden; the residue stands.
6. **§ cloneBodyCallBindsHomeTopTf446** (UhdmExporter, final287;
   `R11U446_CLONECALLHOME_OFF`) — the twin for the bodies of the import group
   itself. A call in a group member (a clone of a home free subroutine or of
   an out-of-body class method) that binds a group clone is rebound to the
   home package's TOP subroutine of that name. Golden binds uvm_pkg TOP in
   all 176 calls of uvm_report_enabled in messaging_pkg's group bodies; ours
   bound messaging_pkg's TOP clone in 832. The importer's own subroutines and
   its own out-of-body methods keep the clone, as in probe r10evfn 2 and
   cb04. Grid CG (cg01 to cg03): pristine is NOT_EQUAL at the same distance on
   both binaries. In these small shapes golden writes no call objects in the
   clone bodies at all, so the law is measured on the sv-tests rows, the
   probe pre-census and the sweep. cg03 fires laws 5 and 6 and needs both
   switches to restore pristine.
7. **§ clsTdQueueLocalCloneUnsupported446** (TaskFuncEmit
   makeQueueDynArrayVar; `R11U446_CLSTDQLOCAL_OFF`) — the array spelling of
   § classScopedTdImportCopyLocalUnsupported198, which was that law's own
   residue (grid198 dArr198). It applies inside an imported out-of-body class
   method clone, to a queue or dynamic-array local whose element is a
   class-scope typedef written bare. The element becomes an
   unsupported_typespec, named as written and spanned at the type name. It
   is instanced at the home package, re-pointed to TOP by
   importCopyTsFixups. Golden: m_resolve_type_name_by_inst's
   `m_inst_typename_alias_t type_alias_inst[$]` reads 2036:3 @uvm_pkg. Grid
   QU:
   - qu02 goes NOT_EQUAL -> STRICT_EQUAL;
   - qu01 goes from uhdm-cmp 96 to 17 lines and from record distance 162 to
     2; its rest is the `with` iterator, the sister's;
   - qu03, with no importer, is a control.

No src/R*.h, no getenv, no reader function, no LawState.h section. Every law
has a lawTrace call. Three laws (2, 3 and 4 with 6) run in final287, so
they run on every exit of exportDesign. The first placement, at the end of
exportDesign, was skipped by the two early returns of § 146 and § 176, and
the IG cases showed it.

Cross-file flags: none written in one emitter and read in another. Law 5
swaps and restores `subMap` entries inside UhdmExporter only. Laws 4 and 6
only read pkgTfOrder9 (written by ParamEmit and TaskFuncEmit) and
pkgDefMap.

## Grid (27 case dirs, cases/<GROUP>, every first line `// § <law>`; evidence/grid_law7.txt)

Pristine -> law7, with every exit code 0 on both binaries:

- **To STRICT_EQUAL, 11:** CT ct01, ct04, ct05, ct06; SM sm01; EB eb01, eb04;
  IG ig01, ig02, ig03; QU qu02.
- **To STRICT_NOTEQUAL, 1:** EB eb03 (name).
- **Closer, 2:** SM sm03 (record distance 82 -> 16, uhdm-cmp 289 -> 858
  lines, the head moving later); QU qu01 (cmp 96 -> 17).
- **Controls, byte-identical:** CT ct03, SM sm02, sm04, EB eb02, QU qu03.
- **Same distance, other faces:** CT ct02, CB cb01 to cb04 (binding moved to
  golden on cb01 to cb03), CG cg01 to cg03.
- **Further: none.**

Switches (evidence/switches_grid.txt):
- `R11U446_OFF` gives pristine's bytes on 27 of 27.
- Each group's own switch restores pristine on 26 of 27. On the 27th, cg03,
  both CG and CB switches are needed (laws 5 and 6 both fire).

Downstream: the grid cases are class and package shapes that the plugin does
not synthesize, and they are not run downstream. The sweep's downstream stage
is the downstream evidence.

## Census by name before the sweep, and the sweep (evidence/sweep_law7.txt, trace_census_sweep.txt)

- Corpus UVM rows, traced targeted run on law7 (evidence/corpus_uvm_rows_law7.csv):
  - Laws fire on MiniAmiq d/t and SeqDriver d/t only, each with 8 of law 1,
    1 of law 5 and 1 of law 6.
  - All seven UVM rows keep their status: CMP_EQUAL and strict equal, or
    their SLANG_REJECT.
- Probe pre-census: the 207 fence-filtered probe cases holding a package with
  a wildcard import (evidence/probe_importer207_law7.csv). All 207 equal
  results/golden_probe.csv. Laws fire on 9: r10uvm127 g127_c_import, r10uvm172
  g172_b_name and g172_d_scope, r10uvm204 g204_b_ctx, r10uvm227
  a9_class_holder, r10uvm23 t34e_t, r10v169 v169_g_control, r10v195
  v195_b_reads and v195_d_tfitem.
- One full five-stage sweep on law7 (tests/sweep.sh --jobs 3 with the trace on;
  the sv-tests stage through the main tree's scripts/check_svtests.py against
  this worktree's baseline, since the worktree's UVM submodule is empty):
  - **probe:** EQUAL 4023 + STRICT_NOTEQUAL 64, regressions 0, conversions 0,
    changes 0.
  - **surelog:** 480 + 0 / 474 + 0, 0/0/0.
  - **uhdm2rtlil:** 803/1/67 in both modes, 0/0/0.
  - **downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0;
    downstream.csv is identical to the control.
  - **sv-tests:** EQUAL 1914, DIFFERENT 26, BOTH_REJECT 303, SURELOG_ONLY 75,
    SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions 0, conversions 0,
    changes 0. svtests.csv is identical to the control.
  - Every csv equals the master control's, apart from the two LowMem
    log-path texts.
- Trace census of the sweep:
  - surelog: MiniAmiq d/t and SeqDriver d/t, as predicted.
  - probe: the 9 predicted cases, no other.
  - sv-tests: the 17 uvm-examples DIFFERENT rows and 4 EQUAL rows, which stay
    EQUAL: uvm_overriding, uvm_slave_agent, uvm_slave_agent_multi_seq_item
    and uvm_wait_for_signal.
  - uhdm2rtlil and downstream: none.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) against
  /tmp/intr11u444:
  - surelog: 4 of 962 movers, exactly MiniAmiq d/t and SeqDriver d/t; the
    self-check flags 961.
  - uhdm2rtlil: 0 of 1608; the self-check flags 1607.
  - probe: the databases embed the worktree path, so they were compared by a
    path-normalized dump (drivers/probecmp.sh). 5 of 4087 move, all among
    the 9 predicted: r10uvm127 g127_c_import, r10uvm172 g172_b_name and
    g172_d_scope, r10uvm227 a9_class_holder, r10v169 v169_g_control. All
    stay EQUAL. The un-normalized first run flagging every database is the
    positive control.
- Canaries ok=52 and ok=16; ctcan2 PASS on both.
- Binary audit (fence-filtered): surelog 1523 of 1573 records name law7, and
  the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests
  2346 of 2346; none names another binary.
- Determinism: three concurrent law7 runs of SeqDriver testflags plus the
  sweep's database read one hash, 4 of 4.

## Sv-tests rows (before -> after)

All 26 DIFFERENT -> DIFFERENT (evidence/runner_law7_open26.csv). Goal 1:
nothing on this ground. All 75 SURELOG_ONLY rows read as before, and no
exporter message is involved.

## Residues, ranked (all wrong on pristine too, none moved away)

1. **The uvm-examples rows' remaining faces.** Every one of them on
   messaging_example, priority_arbitration and priority_grab_lock is
   sister-ground; see the next section. ac_config_db, ef_vif_config_db,
   vif_config_db and id_register also show class-listing misalignments in the
   user classes (34 to 48 "func" entries), module parameter constants and a
   module listing class_typespec. many_to_one, param_vif_config_db and
   pipelined_get_put carry larger unexplored families (1334 to 2047). None
   was decoded.
2. **The per-use struct copy's own vpiInstance in an importer clone body.** In
   SM sm03 the struct_var's copy reads the importer (q) where golden reads
   p's TOP view. It is invisible on the uvm rows once uvm_pkg is visited.
3. **CT ct02:** a specialization typedef written in the importer.
4. **EB eb03:** a reference's typespec in the importer's own function binds
   the importer's listing copy (ExprEmit).
5. **CB cb04:** ours writes the out-of-body method body under the importer's
   class_defn, and golden does not.
6. **The non-null vpiInstance differences:** string and int members of struct
   copies, enum copies in clones at the importer view. uhdm-cmp sees them only
   before the golden package is visited, and the strict walk never reads them.
7. **Not reached:** easyUVM and the 3 uvm_scoreboard rows (5 localized
   failures each, at design and module level); bsg_nonsynth_mem_1rw_sync_assoc
   and bsg_scheduler_dataflow (the sister's writers first); p733, p737 and
   tnoc (await the user's decision).
8. The carried lists of passes 444 and earlier.

## Sister-ground faces (reported, not written)

These are the only remaining failures of uvm_messaging_example,
priority_arbitration and priority_grab_lock, 8 per package view:

- **StmtEmit's foreach loop variable inside import-group clones:**
  - The loop variable of the macro-written methods is shared across the
    macro's expansions. In get/set_packed_ints and longints, the clone's
    `i` is uvm_packer::get_packed_bytes::i with a byte_typespec, where golden
    has an int or long_int at the expansion's own column (551:48, 551:52,
    620:48, 620:52).
  - uvm_init's foreach `idx` is an unsupported_typespec where golden writes
    an array_typespec (uvm_globals.svh 373).
  - uvm_reg_block::get_blocks's `blk_`: golden has the class's own
    class_typespec (42:30, no instance), ours 1274:45 @uvm_pkg.
  - uvm_reg_map::perform_accesses's `i`: golden binds the importer listing's
    struct chain named uvm_pkg::uvm_reg_addr_t.
- **The constructor clone's body-local references:** uvm_root::new's `rh` in
  messaging_pkg's listing. Golden leaves the reference unbound; ours binds
  class_var rh (ExprEmit/StmtEmit).
- **collectPkgTfListing (EmitHelpers.h) itself:** its group order should map a
  macro location to its expansion, as § pkgTfMacroDefAtExpansion403 does for
  the package's own listing. Law 4 repairs the output design-final; the
  writer is the sister's.
- **ParamEmit's emitPackage subMap takeover:** it stays live while
  emitImportedPkgClassMethodClones runs. Laws 5 and 6 repair the bindings on
  this ground.

## Process

- **Measurement budget.** No pristine build and no pristine sweep. The law
  binary was rebuilt seven times (law1 to law7), and every intermediate was
  used on case runs and targeted runner calls only:
  - the 26 open rows on law4 and law7, and 3 rows on law5;
  - the seven corpus UVM rows on law7;
  - the 207-case probe pre-census on law7.

  One full five-stage sweep, on law7.
- **Overlaps.** Analysis tools on existing databases (single-threaded) ran
  beside the sister v11u445's verified sweep and the master's pass 445
  integration sweep. No build, grid batch or runner call overlapped another
  sweep: the first build started at 08:27, after the machine read quiet.
- **Slips, none affecting a measurement:**
  - The first placement of laws 2 to 4 at the end of exportDesign missed two
    early returns; found on the IG grid and moved into final287 before any
    runner call.
  - One cp onto a frozen read-only binary failed and was redone under a new
    name (law7).
- **Fence.** The fence list was read into a file by a program and never
  printed. Every tree-wide list (the probe sources, cmds.txt records) was
  filtered on it first. No fenced test was named, opened or run.
- **The base moved during the pass:** the main tree landed pass 445
  (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit). This patch touches none of
  those files.
