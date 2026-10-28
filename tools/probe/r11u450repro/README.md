# r11u450 — module/type ground, sv-tests campaign (pass 450)

Base 57706919e. Implementer pass on the module/type ground (TypeEmit,
ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main.cpp). Patch surface:
src/UhdmExporter.cpp, src/ModuleEmit.cpp, src/TypeEmit.cpp, tests/LAWS.md
(regenerated) and this directory.

## Verdict

FOUR sv-tests rows convert, with 0 regressions and 0 changes in all five stages:

| row | base | law12 (fresh svtests.csv row) |
|---|---|---|
| generated/uvm-examples/uvm_messaging_example.sv | STRICT_NOTEQUAL differ:file(5) | `EQUAL,,equal` |
| generated/uvm-examples/uvm_priority_arbitration.sv | STRICT_NOTEQUAL differ:file(5) | `EQUAL,,equal` |
| generated/uvm-examples/uvm_priority_grab_lock.sv | STRICT_NOTEQUAL differ:file(5) | `EQUAL,,equal` |
| generated/uvm-examples/uvm_use_models_unidirectional.sv | DIFFERENT | `EQUAL,,equal` |

sv-tests at law12: EQUAL 1920, STRICT_NOTEQUAL 0, DIFFERENT 20, SURELOG_ONLY 75,
BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
`regressions=0 conversions=4 changes=0` (evidence/svtests_stage.log).

Goal 1: nothing new on this ground (the SURELOG_ONLY detail column is unchanged
at 75 rows, every one a slang front-end diagnostic as recorded by passes
406 to 448; no row of this pass moves on that axis).

## The laws (all `lawOn(450, ...)` through src/LawSwitch.h; `R11U450_OFF` drops all;
`R11U450_TRACE=<dir>` logs every firing; no src/R*.h, no getenv, no reader)

Faces 1 and 2 are the two left on the three STRICT_NOTEQUAL rows (pass 449's
residue 1). The walk had stopped at them; once they were written it reached a
third face, law 4. Laws 6 to 9 are uvm_use_models_unidirectional's interface
listing (pass 449's residue 4). Law 10 is the next face of the three
sfr_scoreboard rows; those rows stay DIFFERENT.

1. **§ cloneOwnCopyAtHomeListing450** (`R11U450_OWNCOPYSPAN_OFF`, UhdmExporter,
   inside § cloneSharedAggOwnCopy265's `ownCopy265`). A clone's private struct/union
   copy sits at the home package's LISTING object's span, as every other
   clone-owned copy does (§ cloneAggTsAtHomeListing241). Before this law it sat at
   the shared object's span. Head: messaging_pkg's copies of
   uvm_reg_map::perform_accesses/do_bus_access, `uvm_reg_bus_op` golden
   uvm_reg_map.svh 1793:40 (the out-of-body formal's type token, the listing),
   ours uvm_reg_item.svh 244:9. In uvm-1.2 (MiniAmiq/SeqDriver) the listing sits at
   the declaration, so those rows do not move.
   Case: OC/oc05 (pristine STRICT_NOTEQUAL line -> STRICT_EQUAL).
2. **§ cloneLhsIdxPartSelBind450** (`R11U450_IDXPSBIND_OFF`, UhdmExporter after
   § pkgCloneLocalRefBind37, plus TypeEmit § cloneStmtHomeVarRef17's remap). An
   indexed part-select that is an ASSIGNMENT LEFT SIDE in a clone body, with a
   non-constant base, binds the body's own local by name. § 17 then moves the
   binding to the home's variable. Mechanism: UHDM ElaboratorListener
   leaveIndexed_part_select = leaveRef_obj. Golden leaves these bare: a constant
   base (`data[7-:4]`), a right-side or condition read (ix09), and a formal
   (io_decl; ix08). Head: `data[i0*8+:8]` uvm_reg_map.svh 2003 bound to
   uvm_pkg::uvm_reg_map::do_bus_access::data.
3. **§ cloneVarSelBind450** (`R11U450_VARSELBIND_OFF`, same two sites). A
   var_select in a clone body binds by name wherever it is written: left or right
   side, constant indices or not, a formal included (golden binds the io_decl:
   ix20, ix21). This found the 12 uvm_packer `value[...]` var_selects that golden
   binds in MiniAmiq/SeqDriver's adpcm_pkg/svaunit_pkg clones and pristine left
   bare. Measured on MiniAmiq default: golden binds 12 of the 72 uvm_packer
   var_selects, pristine 0, law 12, the same 12.
4. **§ fwListedQualNameMatch450** (`R11U450_FWLISTEDQUAL_OFF`, UhdmExporter,
   inside § fwWinnerListedObject255). When an importing package specializes the
   winner class, the class_defn's listed typedef and the § 98 twin both carry the
   importer-qualified name (`messaging_pkg::this_type`,
   uvm_abstract_component_registry, uvm_registry.svh 292:11). The importer's
   package listing also re-parents the listed object. § 255's bare-name and
   parent match therefore found nothing. The 8 TLM socket `connect(this_type
   provider)` formals kept the unlisted twin, and the strict walk listed its
   subtree where golden lists none. The law takes the class_defn-listed object of
   the twin's own name at the twin's span. Case: FL/fl01 (dump distance 22 -> 16,
   the head elsewhere).
5. **§ cloneArrElemAggAtHomeListing450** (`R11U450_ARRELEMHOME_OFF`,
   UhdmExporter, § 265's array leg). § 265 leaves shared the element
   struct/union of a clone's local array when it has no member typed by a home
   enum. In golden that element is the clone's own object at the home listing's
   span. The copy is made with § 265's `ownCopy265`, which law 1 places. Case:
   OC/oc01 (`op_s acc[$]` in r's copy of m::bus, golden 12:20 against the
   pristine 9:26; STRICT_NOTEQUAL line -> STRICT_EQUAL). This law needs law 1 for
   the span: oc01 and oc04 read "OWNCOPYSPAN partial" in the switch table.
6. **§ ifcBodyImpTransitiveTds450** (`R11U450_IFCBODYTRANS_OFF`, ModuleEmit
   emitImportArtifacts). Shape: an interface whose body wildcard-imports packages
   that declare no typedef of their own, but import other packages. Golden lists
   the transitive typedefs exactly as a module does, so this interface takes the
   module branch. Its § modulePublishesPackageClasses45 source list also gains the
   packages the imported package itself imports, which brings in the class keys.
   Abstains on an explicit import, an own typedef in the imported package, or a
   `$unit` import in the interface's file. Head: adpcm_driver_bfm (`import
   adpcm_pkg::*`), golden 127 typedefs, ours none, in the definition and in
   top_hdl.adpcm_drv. Cases: IT/it01 and it03 -> STRICT_EQUAL. it04 (class keys of
   an own class) moves but stays unequal. it02 (own typedef: abstains) and it05
   are controls.
7. **§ ifcAnsiLogicPortNet450** (`R11U450_IFCPORTNET_OFF`, ModuleEmit
   emitInterfaceInstance). An ANSI interface header port `output logic` that the
   body drives procedurally is a logic_net in golden's elaborated HOME view, as in
   the definition and in a module's elaborated view. The interface road asked
   makeVar as if no port backed it, so the port became a logic_var. A port view is
   unchanged. Head: top_hdl.adpcm_drv `frame`, `data`. Cases: IV/iv02, iv05, iv09
   -> STRICT_EQUAL; iv03 (module) and iv06 are controls.
8. **§ ifcTaskFixupWalksStmts450** (`R11U450_IFCFIXWALK_OFF`, ModuleEmit,
   the instantiated interface's subroutine-ref fixup walk). The walk now enters
   event_control, delay_control, repeat, while and for. Golden binds
   `@(posedge clk)` in an instantiated interface's task to the elaborated net, as
   it binds the task's assignments. Head: adpcm_driver_bfm::drive's
   `@(posedge clk)` (the uhdm-cmp head after law 7). Cases: IV/iv01, iv04, iv07,
   iv08 -> STRICT_EQUAL. These need laws 7 and 8 together; each alone is partial.
9. **§ importGroupOrderIfaces450** (`R11U450_IFCGRPORDER_OFF`, UhdmExporter, after
   § importGroupKeepsHomeOrder446). The same import-group reorder now runs on
   interface listings: AllInterfaces, and every elaborated interface instance
   (whose home view copied the definition's vector at emission). Head: the six
   macro-written uvm_packer get/set_packed_* at 227 to 232 in golden, 946 to 951
   in ours. Case: IG/ig01 STRICT_NOTEQUAL name -> STRICT_EQUAL. ig02 (an
   interface importing the home directly) is a control.
10. **§ clsAssocVecIdxTs450** (`R11U450_CLSASSOCVECIDX_OFF`, UhdmExporter, the
    class property's outer associative index). An index written as a keyword
    packed vector (`bit[7:0] mem[bit[7:0]]`) is in golden a bit_typespec (bit) or
    logic_typespec (logic/reg). It carries the written ranges (UINT size-64
    constants at their tokens, each range at its brackets) and vpiSigned for
    `signed`. Ours was a bare logic_typespec. Taken only when every bound is a
    plain decimal literal and the index is not a typedef. Cases: AX/ax01, ax03,
    ax05 -> STRICT_EQUAL. ax04 moves to a later head (a function-local index, the
    TaskFuncEmit site, not taken). ax02 (module scope) and ax06 (parameter or
    sized bound) are residues/controls. Rows: uvm_vif_config_db,
    uvm_ef_vif_config_db and uvm_ac_config_db (sfr_scoreboard's `mem`) now head at
    the class typedef listing (residue 2).

## Grid

51 case dirs in AX (6), FL (1), IG (2), IT (5), IV (9), IX (23) and OC (5) (evidence/grid_law12.txt: pristine
-> law12, exit code, uhdm-cmp lines, strict verdict, md5). Every exit code is 0 on
both binaries.

- Converted to STRICT_EQUAL (26): ax01, ax03, ax05, ig01, it01, it03, iv01,
  iv02, iv04, iv05, iv07, iv08, iv09, ix01 to ix07, ix11, ix12, ix16, ix23,
  oc01, oc05.
- Moved closer, verdict unchanged: ix13, ix17 to ix19 (to a home-view
  fullname face), ix20 and ix21 (bytes move toward golden's io_decl binding, both
  STRICT_EQUAL on both binaries), ix22, it04, ax04, oc04, fl01 (dump
  distance down or the head later).
- Byte-identical: the controls ax02, ax06, ig02, it02, it05, iv03, iv06, ix08,
  ix09, ix10, ix14, ix15, oc02, oc03.

None moved further on the strict axis. oc01's dump distance grows (774 -> 806)
while strict turns equal, because the copy lists its subtree in the dump.

Switches (evidence/switches_law12.txt): `R11U450_OFF` gives pristine's bytes on
51 of 51. Each mover's own switch restores pristine alone, except two pairs that
are recorded as such: iv01/iv04/iv07/iv08 need IFCPORTNET and IFCFIXWALK, and
oc01/oc04 need ARRELEMHOME with OWNCOPYSPAN placing the copy. ix13 holds both an
idx and a var select, so it needs IDXPSBIND and VARSELBIND.

## Census before the sweep (by name), and the sweep

Candidates (drivers/candidates.py, fence-filtered before any file is read): a
package with a wildcard import, an interface declaration, or an associative
`[bit|logic|reg` index. That gives surelog 98 + BuildUVMPkg + Scoreboard,
uhdm2rtlil 80, probe 625, and sv-tests 564 (the uvm tag plus the same scan).

- probe (drivers/probecen.sh, law12, traced): 0 byte movers of 625. Firings
  without bytes: r10rggen9repro/t9 (law 7) and r10vrgg6repro/cells/v_iface_chain
  (law 8). Positive control: IX/ix01, IV/iv01 and OC/oc05 fire 4, 3 and 2.
- surelog (drivers/corpcen.sh): predicted byte movers MiniAmiq d/t and
  SeqDriver d/t (law 3, 12 firings each, toward golden), still STRICT_EQUAL at
  435559, 475526 and 475538. Firings without bytes: OneNetInterf d/t and
  OneNetRange d/t (law 7, `reg` ports: makeVar declines either way), Tnoc d/t
  (law 8). Every status equals the golden.
- uhdm2rtlil: 0 firings, 0 movers, every status equal.
- sv-tests (drivers/svcensus.sh): exactly the 4 conversions above and no other
  status change. Firings are listed in evidence/svtests_census_fires.txt
  (34 rows, including 11 EQUAL chapter-16 rows and rsd on law 7, unchanged
  status).

The one full sweep on law12 (md5 ae1709859a3c1ce1cf9b271909aee0f0; built from
this patch on 57706919e; links slang 12.0.0+545f88b2e). It was run through
drivers/fullsweep.sh and drivers/svstage.sh, after three quiet readings:

- probe: EQUAL 4023, STRICT_NOTEQUAL 64 of 4087, regressions=0 conversions=0
  changes=0. 0 of 4087 databases move by path-normalized dump against the
  master's control (comparator control flagged).
- surelog: default 480, testflags 474 CMP_EQUAL, 0/0/0 (Tnoc d/t CMP_NOTEQUAL
  standing). byteverify against /tmp/intr11u449: 4 of 962, exactly the predicted
  MiniAmiq d/t and SeqDriver d/t (law 3); self-check 961.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0; byteverify 0 of 1608.
- downstream: 803 IDENTICAL, 66 SLANG_REJECT, 2 EQUIVALENT, 0 DIVERGENT;
  byteverify 0 of 805.
- sv-tests: as in the verdict. This stage ran alone, on the same binary and
  workdir, through the main tree's scripts/check_svtests.py against the
  worktree's golden, because the worktree's UVM submodule is empty and the
  sweep's stage skipped for lack of SVTESTS_ROOT.
- canaries ok=52 and ok=16, changed 0; ctcan2 PASS (EXPECT_UNKNOWN=1 and 6).
- Binary audit, fence-filtered cmds.txt: surelog 1523 of 1573 records name
  law12 (the other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740,
  sv-tests 2346 of 2346. None names another binary.
- New hashes for the master to re-record (the § 449 note: bytes depend on the
  working directory): MiniAmiq d/t 89ef2145c577, SeqDriver default
  cb044a2c33df, testflags 0c627ab6bffd (byteverify, this workdir).
- Determinism: three concurrent law12 runs each of MiniAmiq default and
  SeqDriver testflags from the sweep's own working directory read the sweep's
  hash, 4 of 4 each (evidence/determinism.txt).

## Residues, ranked

1. **The bidir/pipelined interface rows** (uvm_use_models_bidir_get_put,
   bidir_item_done, pipelined_get_put): DIFFERENT. bidir's uhdm-cmp head is a
   design-level typespec vector where golden holds the elaborated
   bidirect_bus_drv `addr` logic_typespec and ours uvm_mem.svh 897:41
   `uvm_reg_addr_t`, an order/count face in the design listing. The net itself is
   right on law12. pipelined_get_put heads at
   uvm_default_factory::set_type_override_by_type's `index` int_var. Neither is
   decoded.
2. **sfr_scoreboard's class typedef listing** (uvm_vif_config_db,
   uvm_ef_vif_config_db, uvm_ac_config_db; law 10 cleared their index head).
   Golden's class lists its own `type_id` typedef as a class_typespec whose alias
   points at `sfr_agent_pkg::type_id` with T = sfr_agent. Ours lists sfr_agent_pkg's
   cb_type/common_type/super_type keys in a different order. This is the
   user-class listing misalignment of pass 446.
3. uvm_param_vif_config_db (`this_t` class_typespec class_defn), uvm_id_register
   (apb_sequencer's class_defn null), uvm_many_to_one (env_pkg instance),
   uvm_generation_seq_* and uvm_test_init (diamond imports, the sister's ParamEmit
   residue of pass 449), easyUVM, the 3 scoreboard rows, p733, p737 and tnoc:
   unchanged.
4. Interface import shapes law 6 does not take: an imported package with its own
   typedef as well as transitive ones (IT/it02; golden re-parents the package's
   typedef to the interface), and class keys of the imported package's own
   classes (it04).
5. The associative index in a module (AX/ax02), with a non-literal bound (ax06),
   in a function local (ax04; TaskFuncEmit's assocIndexTs site), in an inner
   dimension, or in a class typedef: not taken.
6. Var-select fullname in the home view (`p::f::m::m` golden vs ours `p::f::m.m`
   for an indexed part-select inside a var_select: ix13, ix17 to ix19). This is
   ExprEmit, the sister's.
7. The unpacked-array package-function local listing (IX/ix22, uhdm-cmp 538
   lines on both binaries).
8. Parent-only dump differences in elaborated interfaces (string_var initializer
   constants unparented in ours: invisible to both judges).
9. The carried lists of passes 449 and earlier (the brief's items (b) to ({)), not
   reached.

## Sister-ground faces (reported, not written)

- ExprEmit: the indexed part-select's full name inside a var_select (residue 6).
- StmtEmit/ExprEmit: none needed by laws 7 and 8. Their binding is ModuleEmit's
  fixup walk.

## Process

- Budget: no pristine sweep. The pristine reading is the master's control
  /tmp/intr11u449. The worktree's first build was used for case runs only, its
  md5 equal to the main tree's (cf09f0be76a18f7e3e6ff99a43f2ab89). Intermediate
  binaries law1 to law11 got only case runs and targeted runner calls (the 3 rows,
  the 24 open rows twice, unidirectional, the 3 vif rows, and the 7 UVM corpus
  rows by --filter). Censuses ran on law12. There was one five-stage sweep on law12,
  with its sv-tests stage run alone as described.
- Slips, none affecting a measurement:
  - One shell ran `$UHDM_CMP` unset while I inspected IX/ix22. It executed a
    golden database (my own case cache) as a script and wrote one empty
    garbage-named file in the worktree root, which was deleted. The main tree was
    untouched and the golden unchanged; every later command sourced a guarded env
    file.
  - A 3-row runner call on law11 (the vif rows) overlapped the sister r11u451's
    candidate runner. The pgrep output was printed but not gated.
  - Two of my waiters self-matched their own command lines (quiet.sh's pgrep
    pattern; a determinism loop). They were stopped by task id before running
    anything, and replaced by script files that exclude `bash -c` wrappers.
- Fence: the list was read into /tmp/r11u450_fence.txt by a program and never
  printed. Every tree-wide list (candidates, cmds.txt audit) was filtered on it
  before any file was opened. No fenced test was named, opened or run.
- Drivers: run1.sh (one case, golden cached per case text), grid.sh,
  switches.sh, dist.sh, candidates.py, probecen.sh, corpcen.sh, svcensus.sh,
  fullsweep.sh, svstage.sh, quiet.sh, det3.sh, goldpath.sh, ancestors.py,
  kids.py (record-dump navigation for uhdm-strictcmp --dump-a/--dump-b).
