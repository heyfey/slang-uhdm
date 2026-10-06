# r11u258: pass 258, the expression/parameter ground (the MiniAmiq / SeqDriver struct-index record, streaming targets, multi-initializer loops)

Base 2178d427 (pass 256). Pristine binary md5 b89d1d5b0dad633330f3355585ce388d (identical to the main tree's
build), law binary md5 4efa5b469a64d3a4ee09f106233fe0fe, both linking slang 12.0.0+545f88b2e. Three laws behind
`src/R258.h`. Each law has its own `R11U258_<LAW>_OFF` switch, and `R11U258_OFF` drops all three; it gives pristine
bytes on every case-view of the grid (128 of 128). `R11U258_TRACE=<dir>` logs every firing, one file per process
(`<dir>/<pid>.258`), on every branch of each law.

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep | first record |
|---|---|---|---|
| MiniAmiq default | `differ:type(1)` | `MiniAmiq,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)` | #121302 and #122023 cleared; new head #126482 (sister ground) |
| MiniAmiq testflags | `differ:type(1)` | `MiniAmiq,testflags,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)` | same |
| SeqDriver default | `differ:type(1)` | `SeqDriver,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)` | #121260 and its bit_typespec twin cleared; new head #126440 |
| SeqDriver testflags | `differ:type(1)` | `SeqDriver,testflags,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)` | #121272 cleared; new head #126452 |

NO CORPUS ROW CONVERTS. The brief expected one law to convert MiniAmiq d/t and SeqDriver d/t. It does not: the
struct-index record was not the last one. Clearing it uncovered a second foreach record on the same ground (#122023,
the same law clears it) and then two faces on the sister ground, which are reported below and not written.

The old head (all four row-modes; MiniAmiq default numbering):

    #121302 type   A: struct_typespec uvm_pkg::uvm_reg_map_addr_range  uvm_reg_model.svh 408:9-412:4
                   B: unsupported_typespec range                       uvm_reg_map.svh 825:50-825:55

This is the loop variable of `foreach (top_map.m_mems_by_offset[range])` in svaunit_pkg's copy of
`uvm_reg_map::m_set_mem_offset`, over `local uvm_mem m_mems_by_offset[uvm_reg_map_addr_range]`. Once it is cleared,
the next record is the same law's other face:

    #122023 type   A: bit_typespec uvm_reg_addr_t  uvm_reg_model.svh 73:10-73:31
                   B: unsupported_typespec reg_addr  uvm_reg_map.svh 936:47-936:55

That is `foreach (top_map.m_regs_by_offset[reg_addr])` over `m_regs_by_offset[uvm_reg_addr_t]`.

The new head (law sweep, MiniAmiq default; SeqDriver default #126440 / #126492 / #127232 / #127376 and testflags
#126452 / #126504 / #127244 / #127388 are the same four records):

    #126482 file   A: enum_typespec uvm_pkg::uvm_status_e  uvm_reg_block.svh 1774:45-1774:57
                   B: enum_typespec uvm_pkg::uvm_status_e  uvm_vreg_field.svh 462:31-462:43
    #126534 file   (the same, the local `accesses` struct var's copy)
    #127274 file   (the same, `rw_access`)
    #127418 type   A: typespec_member byte_en  uvm_pkg.sv 303:21-303:28
                   B: ref_obj z  (the index of `rw_access.byte_en[z]`, uvm_reg_map.svh 1903:29-30)

All four records are in the importer copies of `uvm_reg_map::do_bus_write` and `do_bus_read`
(`svaunit_pkg::` on MiniAmiq, `adpcm_pkg::` on SeqDriver). The objects-differing count grows from 1 to 4
because pristine's walk diverged at #121302 and stopped there, while the law's walk runs to #127418. The chain-keyed
away census reads 0 lost on all four row-modes (gate 6). Both faces are the sister ground's:

- **#126482 / #126534 / #127274**: the `status` member of a struct copy (`uvm_reg_bus_op`, the local
  `uvm_reg_bus_op accesses[$]` and `rw_access` of the copy) binds the `uvm_status_e` enum listing object.
  - Golden's sits at the home definition listing's last formal writer, `uvm_reg_block::read_mem_by_name`'s
    `output uvm_status_e status` at 1774:45.
  - Ours sits at `uvm_vreg_field.svh` 462:31.
  - A census over the whole walk reads 278 golden records at 1774:45 against 254 of ours, and 218 against 242 at
    462:31: 24 bindings, all inside importer copies.
  - The member copies are made by UhdmExporter § cloneAggMemberOwn241, which shares each source member's
    `Actual_typespec`, and the enum listing's location is written by the module/type ground's formal-writer laws.
    Not located further.
- **#127418**: in the copy, golden binds the `bit_select` `byte_en` of `rw_access.byte_en[z] = ...` to the
  typespec_member `byte_en` of the LAST importer's re-listing (`work@svaunit_vpi_interface.uvm_pkg::uvm_reg_bus_op
  .byte_en`). Ours leaves it unbound.
  - This is the bit_select twin of § cloneMemberImporterListing259. That law sits in UhdmExporter's member-path
    loop of § cloneAggMemberOwn241's drain and binds ref_obj members only.
  - The clone-body member binder that runs before it, § pkgCloneMember10 (UhdmExporter, `bindMember10`), also
    reads ref_obj elements only.

## The laws

1. **§ cloneLoopVarAssocIdxTs258** (StmtEmit, the § cloneLoopVarHomeObject183 branch `res183`, with its drain
   at the head of ParamEmit `drainUnsizedBasedRhs106`; switch `R11U258_CLONELVIDX_OFF`).
   - THE RULE. A foreach in an importer copy over an associative array binds the shared home loop-variable object
     (§ cloneLoopVarShared37 / § cloneLoopVarHomeObject183) to the array's INDEX typespec, whatever kind it is.
     Pass 183 measured this on class, string and int indices and left every other kind on the unsupported
     placeholder. Golden binds:
     - the struct_typespec of a struct index (`uvm_reg_map_addr_range`, packed or unpacked);
     - the bit_typespec of a bit-vector typedef (`uvm_reg_addr_t`);
     - the logic_typespec of a logic typedef, the enum_typespec of an enum, and the byte_typespec of `byte`.

     The bound object is the one the array's index binds: the LAST importer's re-listing. Golden's member full names
     read `work@top.p::rng_t.min` when a module imports after the package.
   - TWO THINGS SURELOG'S ORDER GIVES, AND OURS MUST REPRODUCE:
     1. Golden's DeepClone resolved the copy body's `range.min` while the home object was still unresolved, so the
        member reference stays unbound in golden. Our clone-body member binder (§ pkgCloneMember10) would follow
        the struct and bind it, and uhdm-cmp reads that bound member unequal (a first draft that bound at emission
        went stage 1 on every A case).
     2. The object is the HOME's, parented at the home foreach_stmt (golden `vpiParent: foreach_stmt (p::c::f)`).
        Ours was parented inside the copy, so § cloneAggLocalOwnCopy241 took a private struct copy for it, whose
        members' full names read through the copy (`q::c::f::range::p::rng_t::min`; second draft, A a12 fullname(6)).

     So the binding is DEFERRED. StmtEmit records `{ref_typespec, index typespec, shared object, foreach key}` in
     `deferredAssocIdxTs258()` and emits no placeholder. The drain, which runs after § pkgCloneMember10 and before
     § cloneAggLocalOwnCopy241, binds the typespec and parents the shared object at its home foreach_stmt.
   - The home foreach_stmt is recorded for every non-copy foreach by the `foreach` keyword's file, line and column
     (`homeForeach258()`). It takes the elaborated body's when there is one, else the definition listing's.
   - The law abstains when no home foreach was emitted before the copy (trace `nohome`; the placeholder stays). It
     also stands down when a later § 248 / § 252 rule sets the typespec (trace `superseded`).
2. **§ lvStreamBaseKeepsActual258** (ExprEmit, the ElementSelect and RangeSelect branches of `emitExpr`; switch
   `R11U258_STREAMRD_OFF`).
   - Surelog compiles a streaming concatenation's lvalue operand as an rvalue (§ streamLvMemberPathRead184 holds
     the same for emitMixedHierPath's paths). For a dotted interface or struct path with a trailing bit, part or
     indexed part select, golden gives exactly the read path's shape:
     - the base ref_obj at its own token (`bit_field_if` 4:19-31, where § lvPathBaseAtFirstMember154 moved it to the
       first member, 4:32-41);
     - the part_select without § lvPathSelNamedByChain154's defname and chain name;
     - the bit_select at its index, not § lvIfaceBitSelWhole154's whole span, and named through the parent chain
       (`work@m.bit_field_if.read_data[3].read_data`).

     This holds inside a macro body (§ macroIfacePathTokSpans183's token branch, v11u256 M/vm20) and outside it
     (M/vm17).
   - The two branches run with `inLhs` cleared for such a path, restored on exit (the RAII `StreamRead258`, gated by
     the existing `lvStreamOperand181`).
   - The bit_select's full name is left to the reader's parent chain, as § genScopeTrailSelNameLate184 does, because
     the stream operation is parented after its operands.
   - Pass 256's § macroIpsBaseStreamAbstain256v already abstains for its own branch; this law covers the others.
3. **§ forMultiInitAssign258** (StmtEmit, the `for` initializer branch; switch `R11U258_FORMULTIINIT_OFF`).
   - Golden lists one vpiForInitStmt assignment per initializer of a multi-initializer loop (`for (i = 0, j = 0;
     ...)`, `for (s.a = 0, i = 0; ...)`). Each has no vpiOpType, no vpiBlocking, and a bare unbound ref_var Lhs named
     by the base: exactly the single initializer's form (including § forInitSelectLhsBase254).
   - Ours emitted each initializer as an ordinary blocking assignment expression (op type 82, blocking, a bound
     ref_obj or hier_path Lhs), which uhdm-cmp reads unequal.
   - The single initializer's code is now a lambda (`mkInit258`, byte-identical for one initializer) applied to
     every initializer.
   - The law abstains for the whole loop when an initializer would get no Lhs (`this.i`, an interface member
     `bi.v`), because UHDM's elaborator crashes on that, which § forInitSelectLhsBase254 names as the --elabuhdm
     crash. A first draft took F f10 and f13 from rc 0 to rc 139 in the elaborated view. It also abstains for a
     package-qualified variable, which golden writes as a variable object (`int_var pv`).

## Grid (cases/, every case's first line names its law)

64 case dirs; every case runs in both views on six configurations: pristine, law, law with `R11U258_OFF`, and the law
with each of the three switches off. That is 768 lines, every one carrying its exit code (evidence/grid.txt,
evidence/gridsum.txt).

Totals over 128 case-views:
- 88 moving, 74 entering STRICT_EQUAL, none leaving. No exit code changes.
- `R11U258_OFF` gives pristine's bytes on 128 of 128.
- Each mover is moved by exactly one switch: CLONELVIDX 24, STREAMRD 44, FORMULTIINIT 20.
- The uhdm-cmp line count changes on 26 case-views: 24 stage-1 case-views going to 0 lines, and S s15 going
  1146 -> 1144 / 1388 -> 1384.

By law:

- **A, § cloneLoopVarAssocIdxTs258** (struct index):
  - a12 two_importers_ext (a package and a module import, the module last: MiniAmiq's and SeqDriver's shape) goes
    from STRICT_NOTEQUAL type to STRICT_EQUAL in both views.
  - a01 dotted_ext, a09 bare_ext and a10 unpacked_ext (a package the only importer) move from type to the
    pre-existing fullname face at the same first record (residue 2).
  - a07 pkg_func_local and a14 local_assoc_ext are stage 1 on both binaries and move.
  - Unmoved: a02 bare_method and a13 module_importer_ext (STRICT_EQUAL on both, no copy: Surelog copies only
    out-of-body subroutines into an importer), a06 module_always (no copy), a11 explicit_ext (stage 1 on both, the
    law does not fire) and a15 queue_of_structs_ext (an int index, the law does not fire).
- **B, § cloneLoopVarAssocIdxTs258** (index kinds):
  - b01 bit typedef, b02 logic typedef, b03 enum, b04 byte and b06 bit typedef bare go from type to STRICT_EQUAL in
    both views.
  - b05, an untypedef'd bit vector, is stage 1 on both and moves.
  - b07 int and b08 string are pass 183's branches, STRICT_EQUAL and unmoved.
- **S, § lvStreamBaseKeepsActual258** (30 dirs):
  - s01 (= v11u256 M/vm17), s02 (= M/vm20), s03, s05, s06, s07, s08, s10, s12, s13, s14, s19, s23 (two-level
    for-generate), s24 (`this.` path in a class method), s25 (struct-array member), s27 (module task), s28
    (instance depth 3) and s29 (if-generate macro) go to STRICT_EQUAL in both views. So do s26 (a call index) and
    s30 (a member-path index), which were stage 1 at the base.
  - s04 (§ macroIpsBaseStreamAbstain256v's own shape): defname -> STRICT_EQUAL.
  - Unmoved controls: s09 and s17 (plain lvalue targets, § lvPathBaseAtFirstMember154 still fires), s16 (an rvalue
    read), s18 (a streaming source), s20, s21 and s22 (no dotted path with a select).
  - s15, a three-level interface path, is stage 1 on both binaries; s11 has no golden.
- **F, § forMultiInitAssign258** (15 dirs):
  - f01, f02, f04, f05, f07, f08, f09, f11, f12 and f14 go from stage 1 to STRICT_EQUAL in both views. The shapes
    are: a member first, plain, an element select, a member second, an expression, three initializers, a class
    method, a module function, a for-generate process, and a call on the right side.
  - The abstentions f10 (`this.i`), f13 (interface member) and f15 (package-qualified) keep pristine's bytes. A
    draft without the abstention crashed f10 and f13 in the elaborated view (rc 139).
  - f03, a single initializer, is byte-identical (the lambda refactor). f06 (declared initializers, another branch)
    is stage 1 and unmoved.

Away census of the 88 grid movers (evidence/away_grid.txt; drivers/awayall.sh: record multisets when both sides pass
stage 1, uhdm-dump line multisets otherwise):
- 0 lost on every record census.
- The stage-1 movers a07, a14 and b05 (both views) each read lost=1 on the dump-line census. The lost line is a bare
  `|vpiParent:` header of the unsupported placeholder the law no longer mints.
  - The gained lines are golden's: `\_foreach_stmt: (p::c::f)` (the shared object's parent) and `\_struct_typespec:
    (p::rng_t)` (its binding).
  - The distance to golden falls on all six (38 -> 33, 200 -> 195, 113 -> 108, 436 -> 431, 19 -> 15, 32 -> 28).

Downstream on the 64 case dirs (drivers/dscases.py, the harness's `one()` per case, evidence/downstream_cases_*.txt):
- Pristine reads 54 IDENTICAL, 9 EQUIVALENT and 1 SURELOG_FAIL; the law reads 60 IDENTICAL, 3 EQUIVALENT and 1
  SURELOG_FAIL.
- Six cases go from EQUIVALENT to IDENTICAL: F f01, f02, f05, f07, f08 and f14. No case leaves IDENTICAL.

## Byte controls

20 earlier repro dirs, 1335 case dirs, 2670 case-views on pristine and law (evidence/controls.txt,
controls_summary.txt). The dirs are r11u256, v11u256, r11u259, v11u259, r11u257, v11u257, r11u254, v11u254, r11u252,
v11u252, r11u253, r11u248, r11u184, r11u154, r11u118, r11v11u118, r11u119, r11u120, r11v124 and r11u238.

- 12 moving, 10 entering STRICT_EQUAL, none leaving, no exit code changing.
- v11u256 M/vm09, vm17, vm18, vm20 and vm21 in both views enter STRICT_EQUAL (§ lvStreamBaseKeepsActual258):
  - vm17 and vm20 are pass 256's residue 1;
  - vm09, vm18 and vm21 were STRICT_NOTEQUAL defname, the part_select defname pass 256 named as the next record.
- v11u254 F/vf03 in both views goes from stage 1 (94 uhdm-cmp lines) to STRICT_NOTEQUAL col (0 lines)
  (§ forMultiInitAssign258: its last loop has two initializers). The remaining record is an indexed part select's
  column on another of its loops.
- The 14 lines with rc 139 or SLANG_FAIL are pre-existing elaborated-view crashes on both binaries: r11u254 F/f04,
  v11u254 vf02 and vf04, and r11v124 pv/v14 and qx/q08.

## Firing census (predictor), frozen before the law sweep

evidence/predict_frozen.txt (md5 9655e97180938ced2df3f3de5a4049fc, frozen 2026-10-06T03:03:33, before the law
sweep started) comes from drivers/tracecensus.sh: the law binary under `R11U258_TRACE` over the probe cases, both
corpora in both modes and the downstream lane, with every filter built from `$FENCED`. It names 4 databases:
MiniAmiq d/t and SeqDriver d/t, with `cloneLoopVarAssocIdxTs258` 8 `defer` + 8 `bind` each. No other law fires on
any probe, corpus or downstream database: there is no streaming-target path and no multi-initializer loop in the
corpora.

Positive controls for the zero:
- The same binary under `R11U258_TRACE` writes the expected lines on grid cases A a12, B b01, S s01 and F f02.
- check_probe.py passes the trace environment to the binary: run on r10earl_repro/vo and v06_gf_vs_psel with
  `R11U256_TRACE` set, pass 256's laws write their trace files.

Movers (byteverify over fence-filtered hard-link mirrors, 2560 databases, 8 fenced paths skipped unread;
PATH_SETS_IDENTICAL; evidence/byteverify_corpus.txt): MOVERS 7 / 2560.
- The four predicted: MiniAmiq d/t and SeqDriver d/t.
- Three not predicted: SimpleUVM d/t and Scoreboard default. These are the UVM family's known order-only movers:
  - Their uhdm-dump output is identical to pristine's, sorted AND unsorted, ids included, once the workdir path is
    normalised. Only 153 bytes of the serialised string table change order. Both rows stay CMP_EQUAL.
  - Each binary is deterministic on them: three concurrent draws of pristine read pristine's hash, three of the law
    read the law's.
  - `R11U258_CLONELVIDX_OFF` alone restores pristine's bytes on all three and `R11U258_STREAMRD_OFF` does not.
    The law never fires there (no trace), so the movement is its bookkeeping (`homeForeach258()` records every
    non-copy foreach's key, allocating), which perturbs the heap under an address-ordered string interning walk
    elsewhere. That walk is deterministic per binary, but not by construction (residue 5).

SELFCHECK flags 2559 of 2560: the self-check compares every file with one fixed file, and that file cannot flag
itself.

Probe: 0 of 4087 databases move (path sets identical; a self-check pairing every file with its neighbour flags 4086
of 4086; evidence/probe_byte_movers.txt). Downstream: the csv is byte-identical to pristine's.

## Gates (law binary, from the worktree, `SLANG_UHDM` exported)

1. Builds: pristine b89d1d5b0dad633330f3355585ce388d (equal to the main tree's build/slang-uhdm), law
   4efa5b469a64d3a4ee09f106233fe0fe. Both were frozen (chmod 555) under scratch before any measurement.
   - Binary-path audit (drivers/binaudit.sh, path list filtered by `$FENCED` before any cmds.txt is opened): 3315
     cmds.txt per sweep, 3265 naming that sweep's frozen binary, 0 another, 50 with no slang line (rows that never
     dispatch slang), 8 fenced paths skipped unread.
2. probe: `EQUAL=3565 STRICT_NOTEQUAL=522`, `regressions=0 conversions=0 changes=0`. The csv is byte-identical to
   pristine's.
3. surelog: `regressions=0 conversions=0 changes=4`, with the CHANGES `MiniAmiq default / testflags` and `SeqDriver
   default / testflags` `differ:type(1) -> differ:file(4)`.
   - Each is a first-field change: the old heads #121302 / #121260 / #121272 are cleared, and #122023 behind them.
   - The new heads are on the sister ground (above).
   - The count grows because pristine's walk diverged at the old head; the chain-keyed away census reads 0 lost
     (gate 6).
   - uhdm2rtlil: `regressions=0 conversions=0 changes=0`, 1606 of 1606.
   - The pristine sweep reproduces the baselines exactly (regressions=0 conversions=0 changes=0 in all three
     stages).
   - The only other csv row differences are the LowMemLib / LowMemPkg testflags detail text, which embeds the
     workdir (evidence/surelog_csv_rowdiff.txt).
4. downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`. The csv is
   byte-identical to pristine's; no row moves.
5. uhdm-cmp: 0 lines on all four corpus movers.
6. Away census on the corpus movers (drivers/awaychain.py, chain-keyed, evidence/away_corpus.txt):

   | row-mode | away | toward | flat_away | flat_toward |
   |---|---|---|---|---|
   | MiniAmiq d/t | 0 | 522 | 0 | 496 |
   | SeqDriver d/t | 0 | 348 | 0 | 326 |

7. Canaries:
   - surelog: ok=50 changed=2 (SeqDriver d/t, targeted).
   - uhdm2rtlil: ok=16 changed=0.
   - ctcan2 surelog (`EXPECT_UNKNOWN=1`) PASS; ctcan2 uhdm2rtlil (`EXPECT_UNKNOWN=6`) PASS.
8. Determinism (drivers/det.sh): three concurrent harness draws per binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
   SimpleUVM, Scoreboard and BuildUVMPkg in both modes (evidence/det_law.txt, det_pristine.txt).
   - Every row-mode reads one hash on each binary. Scoreboard testflags has no database, as at the base.
   - The law's hashes equal the law sweep's. Earlgrey_0_1 and BuildUVMPkg are byte-identical between the binaries.
9. `scripts/law_index.py` regenerated; `--check` reads current.

## Residues, ranked

1. **MiniAmiq / SeqDriver d/t, the four records above**, sister ground. Clearing them should convert all four
   row-modes. Nothing else of this pass's ground is in their walks.
   - #126482 / #126534 / #127274: the enum member location in importer-copy struct copies (UhdmExporter
     § cloneAggMemberOwn241's shared member typespec, or the module/type ground's formal-writer location).
   - #127418: the bit_select member binding in a copy (UhdmExporter § cloneMemberImporterListing259 /
     § pkgCloneMember10 read ref_obj elements only).
2. **§ cloneLoopVarAssocIdxTs258's open shapes**:
   - A package as the ONLY importer of the struct (A a01, a09, a10). The struct copy's member typedef-alias full
     names read `q::p::rng_t::min::addr_t` in golden and `p::rng_t::min::addr_t` in ours: the importer re-listing
     face, wrong on pristine too (pristine's first record #83 is the same).
     - With the law the walk no longer diverges at the loop variable, so it reaches more records of that family:
       fullname(2) -> fullname(14), the same first record #83.
     - The away census reads 0 lost.
   - The untypedef'd bit-vector index `int m[bit [15:0]]` (B b05) is stage 1 on both binaries.
   - The local associative array in a copy (A a07 package function, a14 extern method) is stage 1 on both binaries:
     the copy's local is listed differently, uhdm-cmp line counts are unchanged, and the loop variable now binds
     golden's struct.
   - An explicit-import copy (A a11) is stage 1 on both, and the law does not fire.
3. **§ lvStreamBaseKeepsActual258**: a three-level interface path (S s15) is stage 1 on both binaries; the uhdm-cmp
   line count falls from 1146 to 1144 and 1388 to 1384. A continuous assignment to a streaming target (S s11) has no
   golden (Surelog fails).
4. **§ forMultiInitAssign258**:
   - A declared multi-initializer `for (int k = 0, l = 0; ...)` (F f06) is a different branch, stage 1 on both.
   - The abstaining shapes keep pristine's bytes and remain wrong: `this.i` (f10), an interface member (f13) and a
     package-qualified variable (f15).
5. Order-only bytes: SimpleUVM d/t and Scoreboard default change their serialised string-table order under the law
   binary while no law fires. The bookkeeping allocations perturb an address-ordered interning walk somewhere
   outside this ground: deterministic per binary, not by construction. Not located.
6. Not attempted:
   - Pass 256's residues other than M/vm17 and M/vm20:
     - Earlgrey default #464077, #600811 / #600816 and #474416 to #481722, and testflags #216212;
     - vb01, vb06, vb07, vg19, vf11, vm10, vm06;
     - G g12, g18_el, g19, B b07, M m07, m08, m20, V v06.
   - BlackBePipeInt d/t #331795 / #331692 (item 3).
   - Items (4) to (7), except the two-initializer loops of item (4).

## Sister-ground faces (call sites; not written)

- MiniAmiq / SeqDriver #126482 / #126534 / #127274 (and the SeqDriver twins): enum listing location inside
  importer-copy struct copies. UhdmExporter § cloneAggMemberOwn241 (member copies share the source member's
  `Actual_typespec`) or the module/type ground's formal-writer location laws.
- MiniAmiq / SeqDriver #127418 (SeqDriver #127376 / #127388): bit_select member binding in a copy. UhdmExporter
  § cloneMemberImporterListing259 (`m259`) and § pkgCloneMember10 (`bindMember10`), both ref_obj-only.
- Carried from the brief, not re-measured here:
  - Earlgrey #136315 / #137760: TypeEmit crossPkgBoundFoldConst9.
  - #214684 to #214824 and testflags #216343 onward: TypeEmit § defGenPathSel161.
  - #233633 / #233638: ModuleEmit, the rstmgr ref_typespec names.
  - #375033, #392938, #474036, #596152 onward: ModuleEmit, the instance prefix missing a generate scope.
  - #620047 to #620111: ModuleEmit's dottedLhs net-base test.
  - Rggen #92960: ModuleEmit § genLpUnpackedArray.
  - vf01: TypeEmit, the class struct-member ref_typespec full name.

## Process

- **This implementer's slips**:
  - One exploratory dump ran with the dump tool variable unset (the environment had not been sourced in that
    shell). bash executed a case's golden.uhdm as a script, with my scratch case directory as the working
    directory. It printed `command not found` and a syntax error and wrote nothing: the directory listing was
    unchanged, and the main checkout's porcelain was clean. Every later dump went through a guarded helper that
    sources the environment and checks `[ -x "$UHDM_DUMP" ]`.
  - Two shell lines spelled the fenced names in a `grep -vwE` filter (a path-list filter for the control dirs'
    case count, and in my scratch UHDM probe tool) instead of reading `$FENCED`. Nothing fenced was read. The probe
    tool was rewritten to read `$FENCED`, fail-closed.
  - One background waiter was written with `pgrep -f` on a pattern that matched its own command line. I stopped it
    by its own task id before it was relied on; no process was signalled.
  - The README text of the earlier drafts is not delivered. Three draft laws were measured on cases only, never
    frozen as the law binary:
    - binding the struct at emission (stage 1, the member reference bound);
    - deferring the binding without re-parenting (§ cloneAggLocalOwnCopy241's private copy, fullname);
    - the multi-initializer law without its abstention (rc 139 on F f10 and f13 in the elaborated view).
- **The fence**: every corpus database scan went through fence-filtered path lists (bvmirror.sh, binaudit.sh, the
  probe movers' `find | grep -vwE "$FENCE_RE"`). The firing census ran with the `$FENCED` filters. The only corpus
  databases opened outside the gate sweeps are MiniAmiq, SeqDriver, SimpleUVM and Scoreboard (named rows). No fenced
  source or database was dispatched, read or opened outside the gate sweeps.
- **Ground**: production edits are in StmtEmit, ExprEmit and ParamEmit plus the new src/R258.h only. The sister
  files were read, not edited.
- **Scratch**: worktree /tmp/wt_r11u258; scratch /tmp/r11u258_*.

## Files

- `src/R258.h`: switches, trace, the deferred index list and the home-foreach map.
- `src/StmtEmit.cpp`: § cloneLoopVarAssocIdxTs258 (the § cloneLoopVarHomeObject183 branch and the home-foreach
  record at the ForeachLoop branch) and § forMultiInitAssign258.
- `src/ParamEmit.cpp`: § cloneLoopVarAssocIdxTs258's drain at the head of `drainUnsizedBasedRhs106`.
- `src/ExprEmit.cpp`: § lvStreamBaseKeepsActual258 (`StreamRead258`, the ElementSelect and RangeSelect branches).
- `tests/LAWS.md`: regenerated.
- Cases: `cases/A` (11) and `cases/B` (8), § cloneLoopVarAssocIdxTs258; `cases/S` (30), § lvStreamBaseKeepsActual258;
  `cases/F` (15), § forMultiInitAssign258.
- `drivers/`: pass 259's, retargeted (case.sh, grid.sh, gridsum.py, controls.sh, ctlsum.py, tracecensus.sh with the
  downstream lane added, awayall.sh, awaychain.py, bvmirror.sh, det.sh, dscases.py, cc_x.sh / strictcmp_x.cpp).
  binaudit.sh is new.
- `evidence/`: grid, gridsum, away censuses, controls, the frozen prediction, byteverify, probe movers, row heads,
  determinism draws, downstream on the cases, csv row diffs and sweep summaries.
