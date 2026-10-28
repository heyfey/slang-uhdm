# r11u452 — module/type ground, sv-tests campaign (pass 452)

Base ccfaa1698. Implementer pass on the module/type ground (TypeEmit,
ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main.cpp). Patch surface:
src/ModuleEmit.cpp, src/TypeEmit.cpp, src/TaskFuncEmit.cpp, tests/LAWS.md
(regenerated) and this directory. UhdmExporter, ExprEmit, StmtEmit, ParamEmit,
EmitHelpers.h, include/ and uhdm_main.cpp are unchanged.

## Verdict

FOUR sv-tests rows convert, DIFFERENT -> EQUAL. All five stages read 0 regressions and
0 changes. These are the four diamond-import rows whose class-listing heads pass 451
reported for this ground (item (a) of the brief):

| row | base | law12 (fresh svtests.csv row) |
|---|---|---|
| generated/uvm-examples/uvm_test_init.sv | DIFFERENT | `EQUAL,,equal` |
| generated/uvm-examples/uvm_generation_seq_poly.sv | DIFFERENT | `EQUAL,,equal` |
| generated/uvm-examples/uvm_generation_seq_persistence.sv | DIFFERENT | `EQUAL,,equal` |
| generated/uvm-examples/uvm_generation_seq_randomization.sv | DIFFERENT | `EQUAL,,equal` |

uvm_test_init reads STRICT_EQUAL at 1524739 objects and uvm_generation_seq_poly at 801410
objects; uhdm-cmp reads 0 lines on both.

sv-tests at law12 (evidence/svtests_stage.log):
- EQUAL 1924, STRICT_NOTEQUAL 0, DIFFERENT 16, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
- `regressions=0 conversions=4 changes=0`, with the four conversions above and
  nothing else;
- the prediction (evidence/prediction.txt), written before the sweep, named exactly
  these four.

Goal 1 has nothing on this ground. Of the 75 SURELOG_ONLY rows and the
BOTH_REJECT/SLANG_CRASH rows, none carries an exporter message. The five whose detail
names a slang-uhdm path are uvm_pkg.sv's time-scale diagnostic, an upstream slang
front-end error.

The three sfr_scoreboard rows (uvm_vif_config_db, uvm_ef_vif_config_db,
uvm_ac_config_db) stay DIFFERENT. Laws 8 to 11 clear their class-listing, module
forwarded-block and `this` heads, and the walk now stops at the reference pairing
described under "Sister-ground faces".

## The laws (all `lawOn(452, ...)` through src/LawSwitch.h; `R11U452_OFF` drops all;
`R11U452_TRACE=<dir>` logs every firing; no src/R*.h, no getenv, no reader)

The first four laws are the diamond rows' class-listing heads that pass 451
reported for this ground (item (a) of the brief), then the faces each fix
uncovered. The last five are the three sfr_scoreboard rows' heads
(uvm_vif_config_db, uvm_ef_vif_config_db, uvm_ac_config_db), which stay
DIFFERENT at a later face.

1. **§ clsImpEnumTdShare452** (`R11U452_CLSIMPENUM_OFF`, ModuleEmit, inside
   § clsImpCopyTdBindsContainerListing285's `clsImpTdShare285`). This is the enum
   twin of § 285. A class's inherited copy of an imported package variable typed
   by a named enum typedef binds the container package's own listing of that
   typedef, the one shared object writePackage re-instances for every package
   (vpiInstance = the last such package). Before this law clone_tree handed the
   copy a private enum_typespec with no vpiInstance.
   - Head: uvm_test_init, class_defn top_vseq_pkg::top_vseq_base,
     `enum_var m_uvm_core_state` (golden binds uvm_pkg::uvm_core_state with
     vpiInstance test_top_pkg).
   - Cases: CV/cv01, cv03, cv04, cv06 (the binding moves to golden's object;
     STRICT_EQUAL on both binaries, since uhdm-cmp tolerates a null instance once
     the package is visited). CV/cv02, cv05, cv08, cv09 move the same binding but
     stay NOT_EQUAL at the package listing (sister faces below). cv07 is a control.
2. **§ clsImpRepTsClassKey452** (`R11U452_CLSREPKEY_OFF`, ModuleEmit,
   `g452PkgListKey` beside pkgClassKeys24, read in
   § classInheritsContainerImports23). A class whose container imports a
   package inherits each entry of that package's finished listing under the key
   § importPublishesPackageClasses24 placed it under. When that key is a CLASS
   key (`agent_a_pkg::cb_type` under uvm_event_callback, `agent_a_pkg::type_id`
   under uvm_component_registry), § 23 used to re-key it by the tail of its name
   (`cb_type`). That moved it ahead, and the class's own `type_id` then lost its
   key to the imported one (golden top_vseq_base: 128 entries in top_vseq_pkg's
   own key order plus the class's `type_id@551`; ours 127). The table is filled
   only where the key differs from the name tail; it is a lookup only, never
   iterated.
   - Measured on uvm_test_init. A first version keyed every classRep25 entry by
     its class and broke uvm_pkg's own entries (m_uvm_config_obj_misc is keyed by
     its own name since uvm_pkg imports nothing), so it was narrowed to the
     package listing's own keys.
   - No small case reproduced it: CK/ck01 is the attempt. It stays NOT_EQUAL on
     an unrelated face, a class-local `typedef int type_id` whose int_typespec
     golden links to its typedef alias (residue 6), and it is byte-identical on
     both binaries.
3. **§ clsImpParamOncePerName452** (`R11U452_CLSIMPPARONCE_OFF`, ModuleEmit,
   § 23's parameter branch). The class's parameter map is keyed by NAME, so an
   imported package whose own listing repeats a parameter once per import path
   contributes each name once. Pass 451's § diamondImportParamAssignsPerPath451
   is that repeating listing: env_1_pkg reaches uvm_pkg through itself,
   agent_a_pkg and agent_c_pkg.
   - Golden env_top_pkg::env_top has 3 imports x 41 = 123 parameters; ours had
     287. Its 287 param_assigns stay per path.
   - Cases: CP/cp01 (NOT_EQUAL 1252 -> STRICT_EQUAL); cp02 is the single-path
     control.
4. **§ ifaceConnNetAfterForwarded452** (`R11U452_IFCCONNAFTER_OFF`, ModuleEmit,
   after bindHoistedClassPropRefs). The connection-site wire of a whole
   interface instance passed to a child's interface port (`bif BUS(); slave
   DUT(.bus(BUS));`) is one of the module's own late-binding mints, so it follows
   the forwarded block of the imported packages' unresolved names. It is moved
   only when that block is not empty, and the § 219 bookmark moves with it.
   - Head: the generation_seq rows' `module DEF` failure (top_tb's BUS 30:29).
   - Cases: WO/wo01 to wo04 (NOT_EQUAL -> STRICT_EQUAL; wo02 needs laws 8 and 9
     too).
5. **§ thisNetFlatStreamPlace452** (`R11U452_THISFLATPLACE_OFF`, TypeEmit,
   § hoistedThisRidesTheForwardedBlock219's insertion). The forwarded block is
   § hoistPoolSourceOrder240's stream, which is in flattened (include-expanded)
   source order. The `this` wire takes its place in that order, before the first
   wire of the block whose own location comes later in the flattened text.
   - Before this law the key was (file NAME, line, column). That put
     generation_seq's `this@968:29` (uvm_object.svh) ahead of `p@220:3`
     (uvm_globals.svh); golden has it between m_leaf_name@924 and
     m_type_overrides@1063.
   - A location that maps to no single buffer is left out of the comparison. An
     anchor in a constructor body keeps the old key.
   - Cases: TP/tp01 (zz.svh included before aa.svh: the wire moves to golden's
     place; STRICT_EQUAL on both binaries, the order being invisible to the
     judge here). The g219 probe cases fire it and stay byte-identical.
6. **§ tfLocalClassArrElemClassTs452** (`R11U452_TFCLSARRELEM_OFF`,
   TaskFuncEmit, the fixed-size tf block-item array factory). A fixed-size array
   local of a CLASS type in a subroutine body (`bus_seq_base seq_array[4];`,
   rand_order_seq::body) gets an UNNAMED class_typespec over the written type
   name, with vpiClassDefn and no vpiInstance. It is the element typespec of both
   the reg and the array_typespec. The vector branch wrote a logic_typespec. A class
   written through a typedef or with parameters abstains.
   - Cases: CA/ca01 to ca04 and ca06 (NOT_EQUAL -> STRICT_EQUAL); ca05 and ca07
     are controls on other paths.
7. **§ elabAssocVecIdxRange452** (`R11U452_ELABASSOCIDX_OFF`, TypeEmit,
   emitDynArrayVar). This is the module-scope twin of § clsAssocVecIdxTs450. An
   associative index written as a vector keyword with plain decimal bounds
   (`int memory[logic[31:0]];`) is a logic (bit for `bit`) typespec carrying its
   written ranges and signing.
   - Head: the generation_seq rows' `module TOP work@top_tb` failure.
   - Cases: AX/ax01 (NOT_EQUAL -> STRICT_EQUAL).
8. **§ clsOwnProtoAndOobDefBoth452** (`R11U452_CLSOWNOOBDEF_OFF`, ModuleEmit,
   § 23's task_func branch). The class's own listing keeps both the `extern`
   prototype and its out-of-body definition, as the listing of a class whose
   container imports nothing already does. The name check that lets an imported
   free subroutine suppress a same-named own method now compares an own entry
   against the imported names only.
   - Head: sfr_scoreboard's write@59 and report_phase@73.
   - Cases: OB/ob02, ob03.
9. **§ pkgGroupOwnOobDef452** (`R11U452_GRPOOBDEF_OFF`, ModuleEmit,
   materializedPkgTfGroup's clone-bearing branch). The group of a package that
   itself imports (its elaborated listing verbatim) also holds the package's OWN
   classes' out-of-body definitions. They sit where the package's DEFINITION
   listing has their `C::m` clones, as in the group of a package that imports
   nothing. The DEF listing is walked and matched by name, and any mismatch keeps
   the group unchanged.
   - Head: sfr_scoreboard's inherited sfr_driver::run_phase and four siblings.
   - Cases: OB/ob01, ob04; also the module listing of OB/ob02.
10. **§ hoistPoolTransitiveImports452** (`R11U452_HOISTTRANS_OFF`, ModuleEmit,
    bindHoistedClassPropRefs). CompileHelper::importPackage splices the imported
    package's whole late-binding list, and a package's list already holds those
    of the packages it imports. So a module's forwarded block also carries the
    names of packages reached through its imports' imports. Every import item is
    followed, wildcard or explicit.
    - Head: hvl_top's this/cfg/monitor/driver/sequencer from sfr_agent_pkg.
    - Cases: HT/ht01, OB/ob02's `work@top.x`.
11. **§ thisNetPerListingModule452** (`R11U452_THISPERMOD_OFF`, TypeEmit,
    § thisImplicitNetBoth38). The late binding runs per module in the design's
    module order. Each definition binds the unresolved `this` of the routines its
    listing holds and that an earlier definition left unbound. A later
    definition binds the ORIGINAL references (the class-parented out-of-body
    definition), not the clones its own listing holds, which stay unbound.
    - The anchor rank is the stream order of the routine's HOME package. Each
      import is followed depth first, with a package placed after the packages it
      imports. The listing-package rank tied two homes, and the tie fell to an
      include-expanded key across command-line files, a parallel-parse draw: the
      first build of this law gave two hashes on uvm_vif_config_db.
    - One wire for the design is kept whenever the first definition lists every
      hit.
    - Head: uvm_vif_config_db hvl_top `this@56:18` (sfr_monitor::build_phase),
      next to hdl_top's `this@968:29`.
    - Cases: TM/tm01, tm02 (NOT_EQUAL -> STRICT_EQUAL).

## Grid (evidence/grid_law12.txt, evidence/switches_law12.txt, evidence/switch_off.txt)

There are 32 case dirs in AX, CA, CK, CP, CV, HT, OB, TM, TP and WO. Every exit code
is 0 on both binaries.

- **pristine -> law12:**
  - 19 go to STRICT_EQUAL: ax01, ca01 to ca04, ca06, cp01, ht01, ob01 to ob04,
    tm01, tm02, wo01 to wo04.
  - 8 move bytes with the same verdict: cv01, cv03, cv04, cv06 and tp01 move toward
    golden's binding or place while STRICT_EQUAL on both binaries; cv02, cv05, cv08
    and cv09 bind golden's object but stay NOT_EQUAL at the sister's listing face.
  - 5 are byte-identical controls: ca05, ca07, cp02, cv07, ck01.
  - None goes further.
- **Switches:**
  - `R11U452_OFF` gives pristine's bytes on 32 of 32.
  - Each mover's own switch alone restores pristine on AX, CA, CP, CV, HT, TP, wo01,
    wo03 and wo04.
  - OB, TM and wo02 move under the laws together (the switches file lists which
    switches change each one): OB under 8, 9 and 10; TM under 8, 9 and 11; wo02
    under 4, 8 and 9.

## Gates (one full sweep on the final binary law12, md5 in evidence/; drivers/fullsweep.sh)

| stage | result | byte movers vs the master's control /tmp/intr11u450 |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0 | 0 of 4087 by path-normalized dump (positive control differs) |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | 4 of 962 (byteverify, SELFCHECK 961 of 962 flagged) |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | 0 of 1608 (SELFCHECK 1607) |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0 | 0 of 805 (SELFCHECK 804) |
| sv-tests | 0 regressions, 4 conversions, 0 changes | — |

- **Movers, predicted by name before the sweep** (evidence/census_*.txt,
  evidence/prediction.txt):
  - SeqDriver default and testflags, SimpleUVM default and testflags, all from
    § thisNetFlatStreamPlace452.
  - The `this` wire of top_tb and top moves from DEF-view net index 66 to golden's 70
    (SeqDriver) and from 68 to golden's 72 (SimpleUVM). The judge reads both
    positions as equal. The rows stay STRICT_EQUAL at 475526, 475538, 334285 and
    334297 objects (evidence/movers_strict.txt).
- **Hashes to re-record:**
  - SeqDriver default 89255aa86b3a1fb3f16a27293df7292b
  - SeqDriver testflags 4e6f3f81e98365b31c7a10d32bbfa23b
  - SimpleUVM default 1b272df498a9b2c404d04a4d85cce3c0
  - SimpleUVM testflags a33585478fe354df2e118258e4f1750c
  - MiniAmiq default stays 89ef2145c577.
- **Census before the sweep:** run on law12, traced and fence-filtered over the
  candidate rows (surelog 145 names, uhdm2rtlil 84, probe 1155). It found the four
  movers and the § 452 firings on SeqDriver and SimpleUVM only; 0 firings and 0
  movers in uhdm2rtlil; the four g219 probe cases firing law 5 at the same place.
- **sv-tests trace:** law 5 fires on 146 rows, every one with an unchanged status.
  The class-branch laws fire on the 21 uvm-examples rows with packages importing
  packages, among them the four EQUAL rows of pass 450 (still EQUAL) and the four
  SLANG_ONLY rows (unchanged). See evidence/svtests_trace_fires.txt.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks PASS.
- **Binary audit**, fence-filtered: surelog 1523 of 1573 records name law12 (the
  other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of
  2346.
- **Determinism** (evidence/determinism.txt): three concurrent draws each of
  SeqDriver testflags, SimpleUVM default, MiniAmiq default and uvm_vif_config_db
  read one hash in 4 of 4.
  - uvm_test_init draws two hashes on law12 and on pristine (58253ef368f4,
    f4bea319e8ab, f4bea319e8ab). The law12 draws dump identically, so this is a
    serialization-order draw that predates this pass.
  - The first build of law 11 had a real dump-visible draw on uvm_vif_config_db: the
    `this` anchor was 56:18 or 72:25. The home-package stream rank removed it, and
    four draws now read one hash.

## Sister-ground faces (reported, not written)

- ParamEmit, the importer package's own variable listing:
  - CV/cv02 and cv09: a diamond `import a::*; import b::*;` where golden's shared
    a::st_t carries vpiInstance c while ours keeps a in the DEF listing of b and c.
  - CV/cv05: an array variable `st_t g_arr[2]` in a package's own listing.
  - CV/cv08: an explicitly imported variable `import a::g_state;`. Golden lists no
    copy in package b's variables; ours lists one.
- The uvm_vif_config_db rows' next head after this pass is reached from a ref
  listing order. It reads `design > package(uvm_pkg) > function(uvm_report_enabled)
  > begin > class_var(cs)` against null. Golden binds every clone's `cs`
  (sfr_agent_pkg and sfr_test_pkg clones of uvm_report_enabled) to the home
  uvm_pkg function's local. Every `cs` reference reads the same multiset of
  bindings on both sides, so the pairing differs, not the bindings. Not decoded;
  the clone binders are ParamEmit's and UhdmExporter's.

## Residues (ranked)

1. **The three sfr_scoreboard rows**, uvm_vif_config_db, uvm_ef_vif_config_db and
   uvm_ac_config_db:
   - the uhdm-cmp head after this pass is the `cs` reference pairing in the
     uvm_report_enabled clones (see sister-ground faces); not decoded;
   - uvm_ac_config_db reads the same head.
2. **uvm_use_models_bidir_get_put, bidir_item_done, pipelined_get_put,
   uvm_many_to_one, uvm_param_vif_config_db and uvm_id_register:** still DIFFERENT.
   Their heads at law6 were a logic_typespec at the interface listing (bidir rows,
   100:11), a local int_var in a uvm_default_factory clone (pipelined), and class
   typespec placement (id_register, many_to_one, param_vif_config_db). Not decoded
   this pass.
3. **easyUVM and the three testbenches scoreboard rows** (golden design empty or
   class sequencer listing), and p733, p737 and tnoc (await the user's decision).
4. **Shapes this pass does not reach:**
   - § clsImpRepTsClassKey452 has no small case. CK/ck01 stops first at a
     class-local `typedef int type_id` whose int_typespec golden links to its
     typedef alias, a TypeEmit class-typedef face found here and left unwritten.
   - § ifaceConnNetAfterForwarded452 acts only with a non-empty forwarded block.
     Golden's order between the connection-site wire and the other own mints
     (`$dumpvars` scope names, `$unit` enum nets) is measured only on wo03.
   - § thisNetPerListingModule452 runs only when the first listing module is the
     old home. An anchor in a constructor keeps the old key.
5. **The carried lists of passes 450 and earlier** (the brief's items (b) to ({)),
   not reached: VA/va04, VN/vn05, TV/tv05, AD/ad07, va26 and the rest.

## Process

- **Builds and runs:** law1 to law12 were built in the worktree with -j 2. Pristine
  (md5 bcbbf4bebc1acb00e518ec826fbaabdf) was frozen at /tmp/r11u452_bin/pristine and
  equals the main tree's build. The intermediate binaries got only case runs,
  single-row reruns of the runner's slang command line (drivers/rowrun.sh), and one
  targeted runner call on the 20 DIFFERENT rows with law6.
- **The sweep:** one full sweep on law12 (drivers/fullsweep.sh). The four corpus
  stages ran from the worktree. The sv-tests stage ran through the main tree's
  check_svtests.py against the worktree baseline, since the worktree's UVM submodule
  is empty.
- **Waiting on the sister:** before the census the sister r11u453's sv-tests sweep
  was live. I waited for three quiet readings (drivers/quiet.sh) and ran nothing in
  the meantime.
- **Slips, none affecting a measurement:**
  - The first form of § clsImpRepTsClassKey452 (law2) keyed every class
    representative by its class and moved uvm_pkg's own entries. It was caught on
    uvm_test_init before any census and narrowed in law3.
  - A header declaration added in law9 was reverted to a file-static function, which
    rebuilt every object once.
- **Fence:** the fence list was read into a file by a program and never printed.
  Every tree-wide list (candidates, cmds audit) was filtered on it first. No fenced
  test was named, opened or run.
- No other agent's process was touched.
