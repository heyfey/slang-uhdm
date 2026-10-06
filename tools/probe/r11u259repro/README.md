# r11u259: pass 259, the module/type ground (MiniAmiq / SeqDriver heads #95125 / #95083 / #95095 and #116544 / #116502)

Base 73c55030 (pass 257). Pristine binary md5 8e370bc04400b7a764570b16132e2edd (identical to the main tree's
build), law binary md5 ec23b976885a6c2ae45e4188c8c45cd8, both linking slang 12.0.0+545f88b2e. Three laws behind
`src/R259.h` (each `R11U259_<LAW>_OFF`; `R11U259_OFF` drops all and gives pristine bytes on every case-view of the
grid, 54 of 54; `R11U259_TRACE=<dir>` logs every firing).

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep | first record |
|---|---|---|---|
| MiniAmiq default | `STRICT_NOTEQUAL,differ:fullname(5)` | `MiniAmiq,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | #95125 and #116544 cleared; new head #121302 (sister ground) |
| MiniAmiq testflags | `differ:fullname(5)` | `MiniAmiq,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | same |
| SeqDriver default | `differ:fullname(5)` | `SeqDriver,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | #95083 / #95095 and #116502 cleared; new head #121260 |
| SeqDriver testflags | `differ:fullname(5)` | `SeqDriver,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | same |

No corpus row converts: these four now stop at the StmtEmit face the brief predicted (item (1)'s "up to the StmtEmit
face"). The old heads, from evidence/rowheads.txt:

    #95125 fullname   A: ref_typespec work@svaunit_vpi_interface.uvm_pkg::uvm_hdl_path_slice.path
                      B: ref_typespec uvm_pkg::uvm_pkg::uvm_hdl_path_slice::path
    #95083 fullname   A: ref_typespec work@top_tb.uvm_pkg::uvm_hdl_path_slice.path
                      B: ref_typespec uvm_pkg::uvm_pkg::uvm_hdl_path_slice::path
    #116544 name      A: bit_typespec uvm_pkg::uvm_reg_addr_t  uvm_reg_model.svh 73:10-73:31
                      B: bit_typespec uvm_reg_addr_t           uvm_reg_model.svh 73:10-73:31

The new head (both rows, both modes):

    #121302 type      A: struct_typespec uvm_pkg::uvm_reg_map_addr_range  uvm_reg_model.svh 408:9-412:4
                      B: unsupported_typespec range                       uvm_reg_map.svh 825:50-825:55

This is the struct-index foreach in a copy: the loop variable of `foreach (m_mems_by_offset[range])` over an
associative array indexed by a struct. Golden binds the index struct; ours keeps the unsupported placeholder. The
site is StmtEmit's foreach branch under § cloneLoopVarHomeObject183 (`res183`), which is sister ground, so it is
reported here and not written. Item (1) of the brief points at it.

## The laws

1. **§ cloneMemberImporterListing259** (UhdmExporter, the member-path loop of § cloneAggMemberOwn241's drain;
   switch `R11U259_IMPLISTMEMB_OFF`). A member path `v.m` in an importer copy of a package subroutine has a root
   that is not the copy's own variable. In MiniAmiq this root is the home body's `slice` in
   `uvm_hdl_concat2string`, and golden's copy reference keeps it bound to `uvm_pkg::...::slice`. Golden binds the
   member to the same-named member of the importing package's own re-listing of the typedef. That re-listing is
   Surelog's shared import object, parented at the last importing scope. So golden reads
   `work@ifc.p::slice_t.path` when an interface imports after the package, `work@m2.p::slice_t.path` when the last
   importer is module `m2`, and `q::p::slice_t::path` when the package is the only importer. Ours bound the home
   listing's member. The law re-binds `m` to the member of the one same-named, same-kind (struct or union) typedef
   the copy's package lists. It abstains when there is no such typedef, more than one, or when the member is not
   unique.
2. **§ cloneLoopVarHomeDeclTs259** (TypeEmit `importCloneBareTdAlias16` / § cloneBodyBareTdAlias180's listener,
   applied at the start of UhdmExporter's `finish241`; switch `R11U259_LVHOMETS_OFF`). A clone's foreach binds the
   HOME package's own loop-variable object (§ cloneLoopVarHomeObject183, golden
   `uvm_pkg::uvm_mem::get_addresses::i`). That object is not inside the clone body, so Surelog's `clone_tree` never
   re-minted it. It keeps the typespec of the home declaration of the iterated array. Golden binds bit_typespec
   `uvm_reg_addr_t` at the formal's type token 1305:41, aliased to the elaborated listing `uvm_pkg::uvm_reg_addr_t`
   with the folded range `INT:63`. Ours reached that object through the clone's foreach, and § 180's re-point
   bound it to the clone's bare-aliased copy, which is the #116544 name face.
   - The law finds the home subroutine by the variable's full name minus its last segment. It searches the
     ELABORATED view (uhdmtopPackages), with class methods included and extern prototypes skipped. In that
     subroutine it takes the formal or top-level variable named as the clone foreach's array, when its typespec
     stands for the same typedef. At the end of the export it binds that declaration's then-current typespec.
   - § 180's re-point still runs first, so the copies keep their minting order.
   - Three intermediate drafts were measured and not kept: binding inline before the LAW S writers ran (the class
     method's prototype and body disagree, so it abstained), and taking the definition view (MiniAmiq then read
     the unfolded `UVM_REG_ADDR_WIDTH-1` operation where golden has `INT:63`).
3. **§ tpRebindIdOrder259** (UhdmExporter `rebindTypeParamElem107`; switch `R11U259_TP107ORDER_OFF`). This is
   determinism work, pass 257's verifier residue 1. `last107` is keyed by `type_parameter` pointers, and its loop
   mints a `packed_array_typespec` and a `ref_typespec` per rebound parameter, so the minting order followed heap
   addresses. The loop now visits in UhdmId order. It fires on 4 probe cases and the 2 T cases, and moves no byte
   on any of them: pointer order equals UhdmId order on these runs. In 10 concurrent draws per view, every one of
   these cases reads one hash.

## Grid (cases/, every case's first line names its law)

Every case runs in both views on 6 configurations: pristine, law, law with `R11U259_OFF`, and the law with each
switch off. That is 324 lines, every exit 0 (evidence/grid.txt, evidence/gridsum.txt). Totals over 54
case-views: 38 moving, 8 entering STRICT_EQUAL, none leaving, no uhdm-cmp line count changing, `R11U259_OFF`
giving pristine bytes on 54 of 54, and each switch moving only its own law's cases.

- **M, § cloneMemberImporterListing259**:
  - m01 iface_last, m03 two_modules, m08 two_pkgs, m10 packed, m12 iface_then_module, m13 task and m14 member_lhs
    go from STRICT_NOTEQUAL fullname to STRICT_EQUAL in the default view. So does r11u252repro decode/M/m01, the
    decode of #95125.
  - m02 pkg_only moves: its member record is cleared, and the copy's second struct copy still shares the home
    members (residue 2).
  - In the elaborated view, m01, m02, m03, m08, m10, m12, m13 and m14 move bytes but keep the same first record:
    the walk diverges earlier, before the member (residue 3).
  - Unmoved: m04 explicit (stage 1 at the base), m06 class method and m07 module always (STRICT_EQUAL on both
    binaries, no copy), m09 formal (STRICT_EQUAL on both).
  - m05 foreach_block and m11 union are stage 1 on both binaries; m05 is the struct-array foreach face.
- **L, § cloneLoopVarHomeDeclTs259**: l01, l02, l03, l04, l05, l07 and l09 lose every clone loop-variable record:
  the alias name and the home declaration's location, 4 records per case-view. What is left on them is the HOME
  body's own loop variable binding the listing where golden binds the declaration's copy (residue 4). l06, a
  plain int element, is STRICT_EQUAL on both. l08 local_array is stage 1 on both, and so is l10 task_queue, which
  moves.
- **T, § tpRebindIdOrder259**: t01 two_defs and t02 three_defs_reversed are STRICT_EQUAL on both binaries,
  byte-identical, with 10 of 10 draws reading one hash per view.

Away census of the grid movers (evidence/away_grid.txt), record multisets:

- 0 lost on every case-view except L/l10_task_queue (stage 1, dump-line census, lost=2 gained=1).
- In l10 the loop variable's binding equals golden's (logic_typespec `n_t` 4:24). The two lost dump lines are
  the `vpiParent` of a now-unreferenced copy that is no longer printed in the unparented tail.

## Byte controls

19 earlier repro dirs, 2304 case-views on pristine and law (evidence/controls.txt, controls_summary.txt). The dirs
are r11u257, v11u257, r11u255, v11u255, r11u253, v11u253, r11u252, v11u252, r11u251, r11u249, r11u247, r11u245,
r11u243, r11u241, r11u118, r11v11u118, r11u119, r11u120 and r11u186.

- 12 moving, 3 entering STRICT_EQUAL (r11u241 CF/e04, CF/e07, r11u252 decode/M/m01), none leaving.
- No exit code and no uhdm-cmp line count changes.
- Away census 0 lost on all 12 (evidence/away_controls.txt).

## Firing census (predictor), frozen before the law sweep

evidence/predict_frozen.txt comes from drivers/tracecensus.sh: the law binary under `R11U259_TRACE` over the probe
cases and both corpora in both modes, with the filter built from `$FENCED`. It names 14 databases:

- **Corpus**: MiniAmiq d/t and SeqDriver d/t (§ cloneMemberImporterListing259 36 firings and
  § cloneLoopVarHomeDeclTs259 2 per mode).
- **Probe**: g180_a_kinds, g207_c_share, g207_e_head, g207_h_foreign, v181_h_nofe and v208_f_io (the two content
  laws), plus r08_two_defs, e18_chain_rt, a16_two_type_params and f5a12_chain (§ tpRebindIdOrder259, order only,
  predicted not to move unless pointer order differed).

Every mover was predicted:

- **Corpus**: byteverify over fence-filtered hard-link mirrors (2560 databases, 8 fenced paths skipped) reads
  MOVERS 4 / 2560, exactly MiniAmiq d/t and SeqDriver d/t. PATH_SETS_IDENTICAL; SELFCHECK flags 2559 of 2560
  (evidence/byteverify_corpus.txt).
- **Probe**: 6 / 4087 move, exactly the six content-law predictions; the four § tpRebindIdOrder259 firings move
  no byte (evidence/probe_byte_movers.txt).
- **Downstream**: no verdict changed (below).

## Gates (law binary, from the worktree, `SLANG_UHDM` exported)

1. Builds: pristine 8e370bc04400b7a764570b16132e2edd (equal to main), law ec23b976885a6c2ae45e4188c8c45cd8, both
   frozen under scratch before any measurement. Binary-path audit: 3273 of 3323 cmds.txt per sweep name the
   frozen binary of that sweep (the other 50 are rows that never dispatch slang, the same set in both sweeps).
2. probe: `EQUAL=3558 STRICT_NOTEQUAL=529`, `regressions=0 conversions=1 changes=5`.
   - CONVERSION r10uvm180repro/g180_a_kinds `differ:fullname(1) -> EQUAL` (§ cloneMemberImporterListing259).
   - Changes:
     - g207_e_head `fullname(32) -> (16)` and g207_h_foreign `fullname(41) -> (32)` (§ 259 member law, the same
       first records).
     - v208_f_io `name(7) -> name(3)` (§ cloneLoopVarHomeDeclTs259 clears the four home-loop-variable alias
       records #160 / #566 / #803 / #1086; #738 / #1011 / #1294, a call argument in the importer's own
       function, are unchanged and wrong on pristine too).
     - v181_h_nofe `fullname(2) -> depth(1)`: #580, the member record, is cleared, and #596, the pre-existing
       walk divergence at the second package, is the same record.
     - g207_c_share `fullname(16) -> fullname(32)`, a GROWN count on the same first field. The first record is
       the same (#152, the raw identity-derived full name inside a typespec copy). Pristine's walk DIVERGED at
       #242 to #335 (objects 1165 vs 1198); the law's walk no longer diverges, so it reaches 16 more records of
       the same identity family from #507 on. The away census reads 0 lost (dist 40 -> 0, gained 7).
   - Record-multiset away census on the probe movers: g180 0 lost, g207_c 0, g207_e 0, g207_h 0, v181 0.
     - v181 dist 7 -> 12: our surplus grows by the importer listing's member subtree, now reached through the
       reference.
     - v208 lost=2: two bare `bt208vf` records. The four positions the law fixes had supplied bare records that
       the three still-wrong positions lack, so the count loss is position-free. The strict walk reads 7 -> 3
       objects differing, none newly wrong.
3. surelog: `regressions=0 conversions=0 changes=4` (the four rows above; every other row byte-identical).
   uhdm2rtlil: `regressions=0 conversions=0 changes=0`, 1606 of 1606. The pristine sweep reproduces the baseline
   exactly (regressions=0 conversions=0 changes=0 in all three stages).
4. downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`, verdict diff against
   results/downstream_uhdm2rtlil.csv 0. No row targeted; none moves.
5. uhdm-cmp: 0 lines on all four corpus movers (rc 0).
6. Away census on the corpus movers:
   - Chain-keyed (drivers/awaychain.py with strictcmp_x, pass 252's tool): MiniAmiq d/t away=0 toward=636, and
     SeqDriver d/t away=0 toward=425.
   - Flat: MiniAmiq flat_away=14, SeqDriver 3. All of them are `uvm_reg_addr_t` typespec subtree records (the
     loop variable's object changed identity) with no chain context losing a golden record
     (evidence/away_corpus_flat.txt).
7. Canaries: surelog ok=50 changed=2 (SeqDriver d/t, targeted); uhdm2rtlil ok=16 changed=0; ctcan2 surelog
   (EXPECT_UNKNOWN=1) PASS; ctcan2 uhdm2rtlil (EXPECT_UNKNOWN=6) PASS.
8. Determinism: drivers/det.sh ran three concurrent harness draws of the law binary on Earlgrey_0_1, MiniAmiq,
   SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg in both modes. Every row-mode reads one hash (Scoreboard
   testflags has no database, as at the base); the MiniAmiq and SeqDriver hashes equal the law sweep's. Separately,
   10 concurrent draws per view gave one hash on T t01, t02, the four § tpRebindIdOrder259 probe cases,
   M/m08 and L/l07.
9. `scripts/law_index.py` regenerated; `--check` reads current.

## Residues, ranked

1. **MiniAmiq / SeqDriver #121302 / #121260** (all four row-modes): the struct-index foreach loop variable in a
   copy. The site is StmtEmit § cloneLoopVarHomeObject183's `res183`, which is SISTER GROUND, so it is reported
   only.
2. M/m02 (the package as the only importer): the copy's second struct copy (the begin-block local's twin) shares
   the home listing's members, so their raw full names read `p::slice_t::path` where golden's copy owns
   `q::f::slice::p::slice_t::path`. These struct copies are minted outside § cloneAggLocalOwnCopy241, which skips
   a copy bound to the home listing object itself (`a241 == h241`).
3. The elaborated view of every M case: the copy's struct typespec shares the home members, so the walk lists a
   shared member once (`name` at #62). Wrong on pristine too.
4. The HOME body's own foreach loop variable binds the LAW S listing copy where golden binds the home
   declaration's per-declaration copy (L l01 #141 and the same on l03, l04, l05). It is not in any corpus row:
   the UVM home loop variables there are unsupported placeholders on both producers.
5. v208_f_io #738 / #1011 / #1294: a call argument in the importer's own function binds a qualified alias where
   golden's is bare.
6. Pass 257's residues (2) to (7) of the brief were not attempted: Rggen #92960, Earlgrey's records on this
   ground, the F-family return typedef, § ifacePortMemberHighConnParent257's open shapes, and the
   generate-localparam add size. Neither were pass 255's, 253's and 251's lists, or items (4) to (7). Item (6) is
   moot: HierPathTypespec d/t and InterfArrayBind d/t are CMP_EQUAL / equal at the base.
7. Determinism audit (residue 1 of v11u257): the scan of TypeEmit, UhdmExporter, ModuleEmit and TaskFuncEmit for
   loops over pointer-keyed containers whose bodies mint found two that are not keyed by slang symbols:
   - `last107`, fixed by § tpRebindIdOrder259.
   - `drainClassNestedTdGroups54`'s `grp54`, keyed by a `const void*` symbol key. It mints group `ref_typespec`s
     in key-pointer order; it was not changed and no row has shown it.
   The many `std::map<const Symbol*, ...>` walks (typedefTs, pkgImportCloneTs, classDefnMap) iterate in slang
   allocation-address order. They are deterministic per run in every draw measured, but not by construction.

## Sister-ground faces (decoded, call sites; not written)

- MiniAmiq / SeqDriver #121302 / #121260: StmtEmit § cloneLoopVarHomeObject183 (`res183`, the associative
  index struct).
- BuildUVMPkg #194627: ExprEmit § shellCallKeepsItsSyntax167 (Invalid unwrap); r11u255repro decode/A/a01.
- Earlgrey #154375 / #165002: ExprEmit § selFold9. Earlgrey #136315 / #137760: ExprEmit § sysFuncArgFold.
- Rggen #27671: ExprEmit § selChainElemShapeIsSyntactic147 (r11u257repro decode/HL).
- BlackBePipeInt #331795 / #331692: ParamEmit, the import-copy Rhs.
  
  No law of this pass fires on any of these rows (predictor), and their bytes are unchanged (byteverify).

## Process

- **The implementer's slips**:
  - One background waiter used `pgrep -f` on a pattern that matched its own shell. It was stopped by its own task
    id; no process was signalled. The next waiter polled the grid file's line count.
  - The first byte-control run failed with `case.sh: Permission denied`: the copied drivers were not executable.
    Nothing ran; the drivers were chmod'ed and the controls rerun from scratch.
  - Two debug builds carrying `DBG` trace lines were used to locate the § cloneLoopVarHomeDeclTs259 abstention.
    The traces were removed before the law binary was built and frozen.
  - The L cases' first lines first named a draft law name. They were corrected and the whole grid rerun to the
    same verdicts (324 lines, identical gridsum).
- **The fence**: every corpus database scan went through fence-filtered path lists (bvmirror.sh and the probe
  movers' `find | grep -vwE "$FENCE_RE"`). The firing census ran with the `$FENCED` filter. No fenced source or
  database was dispatched, read or opened outside the gate sweeps.
- **Tools**: every tool call went through a `[ -x ]` guard.
- **Scratch**: worktree /tmp/wt_r11u259; scratch /tmp/r11u259_*.

## Files

- `src/R259.h`: switches and trace.
- `src/UhdmExporter.cpp`: § cloneMemberImporterListing259, § tpRebindIdOrder259, and the apply step of
  § cloneLoopVarHomeDeclTs259 in `finish241`.
- `src/TypeEmit.cpp`: § cloneLoopVarHomeDeclTs259.
- `cases/M` (14, § cloneMemberImporterListing259), `cases/L` (10, § cloneLoopVarHomeDeclTs259), `cases/T` (2,
  § tpRebindIdOrder259).
- `drivers/`: pass 257's, retargeted. New ones: rowhead.sh (strict records of one sweep row, fenced refused) and
  ctlsum.py. From r11u252: awaychain.py, awayrows.py, cc_x.sh and strictcmp_x.cpp.
- `evidence/`: grid, controls, away censuses, frozen prediction, byteverify, probe movers, row heads, sweep
  summaries.
