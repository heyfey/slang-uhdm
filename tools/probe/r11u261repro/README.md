# r11u261: pass 261, the module/type ground (Earlgrey_0_1 #136315 / #137760 and the records behind it)

Base e3538174 (pass 259). Pristine binary md5 59fd71bb928e52946a4bf932aba35a98 (identical to the main tree's build),
law binary md5 3667c71c45081af8b7cf558a0a52d403, both linking slang 12.0.0+545f88b2e, both frozen under scratch
before any measurement. Six laws behind `src/R261.h` (each `R11U261_<LAW>_OFF`; `R11U261_OFF` drops all and gives
pristine bytes on every case-view of the grid, 122 of 122; `R11U261_TRACE=<dir>` logs every firing).

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep (fresh csv row) | first record |
|---|---|---|---|
| Earlgrey_0_1 default | `STRICT_NOTEQUAL,differ:fullname(117)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(74),,differ:fullname(74)` | #136315 cleared; new head #233633 (sister ground) |
| Earlgrey_0_1 testflags | `STRICT_NOTEQUAL,differ:fullname(24)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)` | #137760 cleared; new head #216212 (sister ground) |

No corpus row converts. 43 of 117 objects (default) and 20 of 24 (testflags) are cleared. Both row-modes now start
at an expression-ground record. The old head (evidence/earlgrey_*_pristine_records.txt):

    #136315 fullname   A: ref_typespec work@sha2      (sha2.sv `logic [$clog2(NumRound)-1:0] round;`)
                       B: ref_typespec <no name>

The new heads (evidence/earlgrey_*_law_records.txt):

    default  #233633 fullname  A: ref_typespec work@rstmgr_ctrl   B: work@rstmgr_ctrl.rst_req_i
             (rstmgr_ctrl.sv:64 `rst_req_i[OffDomainSelStart +: OffDomains]`; module localparam OffDomains shadowed
              by rstmgr_pkg's: ExprEmit § shadowedImportParamFold, reproduced as decode/B/b01)
    testflags #216212 fullname A: ref_obj DataWidth prim_cipher_pkg::PRINCE_ROUND_CONST::...::DataWidth
              B: work@prim_prince.p_pre_round_xor.prim_cipher_pkg::PRINCE_ROUND_CONST.prim_cipher_pkg::...DataWidth
             (prim_prince.sv:81 `data_state[0] ^= prim_cipher_pkg::PRINCE_ROUND_CONST[0][DataWidth-1:0];` in an
              always_comb: ExprEmit, § pkgSelIdxRefColons254's `::` form not reaching a compound assignment)

Each law's share on the row (evidence/earlgrey_switches.txt, the law binary with one switch off):

| switch off | default | testflags |
|---|---|---|
| none (law) | fullname(74) | fullname(4) |
| `R11U261_SYSARGTS_OFF` | fullname(75) | fullname(5) |
| `R11U261_QSELNAME_OFF` | fullname(78) | fullname(8) |
| `R11U261_GENBIRTH_OFF` | fullname(108) | fullname(19) |
| `R11U261_PSCONNARR_OFF` | fullname(78) | fullname(4) |

## The laws

1. **§ sysArgFoldTsUnitName261** (TypeEmit, emitSyntaxExpr's system-call argument branch, § sysCallArgPkgParamSubst's
   module half; switch `R11U261_SYSARGTS_OFF`). An unqualified package parameter read as the argument of a query
   call in a typespec range (`logic [$clog2(NumRound)-1:0]`, `NumRound` wildcard-imported) is substituted by the
   package's own value constant (crossPkgBoundFoldConst9).
   - The constant's ts ref stores the full name of the DESIGN UNIT the call is compiled in: `work@sha2`, and an
     interface's `work@ifc`, a program's `work@prg`.
   - Golden writes this whatever declares the range: a net, a port, a struct member, a function local, a variable
     with a process, a bound module, a macro body, an included header, or a parameter's own type.
   - Ours stored the parameter owner's name (`paramTsOwnerFull9`), or nothing at all, in which case the getter
     computed an empty chain through the sys_func_call.
   - The qualified spelling (`$clog2(hp::NumRound)`) keeps no ts ref and is untouched (A/a02).
   - Abstains outside a module/interface/program body. The package-listing branch runs with `curPkgEmitSym` set and
     never reaches this site.
   - Golden also parents the constant at the package's param_assign. That is not a field the comparator or the
     downstream reads, and this law does not write it.
   - Decoded on pass 254's gdb pin (r11u255repro decode/A/a03); Surelog's `VpiFullName()` getter caches the chain
     name the first time it is read, and the identifier is compiled with the module as the constant's parent.
2. **§ pkgQualSelChainOwnName261** (TypeEmit, the qualified-select delegation of § pkgScopedMultiSelVarSelect40;
   switch `R11U261_QSELNAME_OFF`). A select chain of two or more selectors on a PACKAGE-QUALIFIED base
   (`prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0]`) is emitted with no stored full name (policy (1) of
   pass 40), so its index references read the chain.
   - Golden's var_select and every part_select of the chain carry their OWN written name as full name
     (`cp::RC`). The VPI reports that as no full name, since it equals vpiName.
   - Ours left them unset, and the getter computed `<scope>.cp::RC` and `<scope>.cp::RC.cp::RC` at write time.
   - The law stores the name on the var_select and its part_selects. Nothing else moves: the chain walk reads
     vpiName, never a parent's full name, so the index references keep their dotted path (golden's operand form).
   - Clears Earlgrey #214684, #214686, #214818, #214824 (testflags #216343 to #216483).
3. **§ genChildParentAtBirth261** (ModuleEmit, emitInstance and the gen-scope instance loop; switch
   `R11U261_GENBIRTH_OFF`). A module or program instantiated in a generate block is parented at the block's
   gen_scope FROM BIRTH, not re-parented after its body is emitted.
   - An object of the body that stores no full name (the operand part_select of a per-instance cont_assign copy)
     has its name computed by the database getter the first time anything reads it, and ExprEmit's emitExpr
     reads it while the body is being built (gdb on case D/d01: five getter calls from emitExpr before the
     serializer's).
   - Through the module parent, the cached chain skipped the generate scope: `...if_stage_i.prefetch_buffer_i.
     fifo_i.rdata`, where golden reads `...if_stage_i.gen_prefetch_buffer.prefetch_buffer_i.fifo_i.rdata`.
   - vpiInstance / vpiModuleInst still name the module until the loop clears them, as before.
   - The pending parent is taken on entry to emitInstance, so no grandchild or bind can inherit it.
   - Clears Earlgrey #375033 to #393091, #474036 / #481420 and the other gen_flash_banks bit selects, #596152 /
     #596173 (34 default records, 15 testflags). Pass 155's § pselConnNameNotFrozen155 had repaired the
     part-select-actual face of the same cause.
4. **§ pselConnArrPathName261** (ModuleEmit, the part-select HighConn branch before its bound folds; switch
   `R11U261_PSCONNARR_OFF`). When the parent instance's path holds a generate-ARRAY index (`gen_flash_banks[1]`),
   ExprEmit's part-select branch (its `prefix.find('[')` branch) NAMES a part-select actual `<parent path>.<base>`
   instead of leaving it to the chain.
   - Golden reads the chain through the child instance and the formal, `<child>.<formal>.<base>`
     (flash_phy_core.sv:226 `.addr_i(muxed_addr[BankAddrW-1:LsbAddrBit])`:
     `...i_core.i_flash.addr_i.muxed_addr`), as § pselConnNameNotFrozen155 re-derives for a frozen name.
   - The law re-derives it BEFORE the bound folds. The bound references named through the select follow, and so
     does a folded bound constant's ts ref stamped with the select's name (ExprEmit's stampFoldedPkgParamTs).
   - Reading the name of a ts ref that stores none would cache its chain. A ComputeFullName probe (no getter)
     detects that read and undoes it.
   - Clears Earlgrey #474416 / #474419 and #481719 / #481722 (default only; the `--elabuhdm` view already agreed).
5. **§ grp54IdOrder261** (UhdmExporter drainClassNestedTdGroups54; switch `R11U261_GRP54ORDER_OFF`). This is
   determinism work, the residue pass 259 left. grp54 is keyed by a symbol pointer and the loop MINTS an alias
   ref_typespec per member. The groups are now visited in the UhdmId order of their smallest member typespec.
   - Traced only where the visit order moves.
   - Fires on 7 probe cases and the UVM rows (BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard).
   - 10 concurrent draws per view on the 7 probe cases: one hash each on both binaries
     (evidence/nondet_grp54.txt).
6. **§ classImportsIdOrder261** (ModuleEmit classInheritsContainerImports23; switch `R11U261_CLSIMPORDER_OFF`).
   This is the determinism audit's one remaining mint loop over a slang-Symbol-pointer map. It minted the
   per-class import copies (importVarCopy5 and the listing vectors) in classDefnMap's pointer order.
   - The classes are now visited in the UhdmId order of their class_defn. A class_defn reached by two symbols
     keeps the pointer order between them.
   - Traced only where the order moves. It moves bytes and no content: on all 67 probe databases it moves, the
     sorted uhdm-dumps of pristine and law are identical. On the corpus it moves BuildUVMPkg, Scoreboard and
     SimpleUVM with identical dumps, and MiniAmiq and SeqDriver with order-only dump lines (sorted dumps equal).

## Grid (cases/, every case's first line names its law)

61 case dirs run in both views on 9 configurations: pristine, law, law with `R11U261_OFF`, and the law with each
switch off. The dirs are cases A, C, D and G, the decode dirs B, E and F, r11u255repro decode/A/a03 and r11u254repro
Q/q08. That is 1098 lines, every exit 0 (evidence/grid.txt, gridsum.txt).

Totals over 122 case-views: 66 moving, 48 entering STRICT_EQUAL, none leaving, `R11U261_OFF` pristine on 122 of
122, and each mover moved only by its own law's switch. Two uhdm-cmp line counts change: A/a06 in both views, 42 ->
44, stage 1 on both binaries. That case's head (golden keeps a ref_obj where ours folds) is unchanged; the extra two
lines print the new ts ref name.

Away census of the 66 grid movers (record multisets; dump lines on stage-1 cases): 0 lost on 66 of 66
(evidence/away_grid.txt).

- **A, § sysArgFoldTsUnitName261**:
  - Entering STRICT_EQUAL in both views: a01 net, a04 port, a05 interface, a08 struct member, a11 nested instance,
    a13 function local, a14 process variable, a17 bind, a18 program, a19 macro body, a20 CRLF with two modules, and
    a21 a header included in two modules.
  - a15 (a parameter's own type) moves fullname -> endcol. Its remaining record is the elaborated folded bound's
    endcol (7:16 vs golden 7:26), an expression-ground fold.
  - a06 (a generate block) is stage 1 on both binaries: golden keeps the ref_obj there.
  - Unmoved: a02 (qualified), a09 (localparam init, ExprEmit already right) and a16 (unpacked dims), all
    STRICT_EQUAL on both. a03, a07, a10 and a12 are stage 1 on both, a10 being the package importer, where golden
    names the ref `q`.
- **C, § pkgQualSelChainOwnName261**:
  - Entering STRICT_EQUAL in both views: c01 operand, c06 three selectors, c07 if-generate, c09 two operands, c10
    bit chain, c11 whitespace in the qualified base, c12 macro + CRLF, and c13 two packages.
  - c02 (the select as the WHOLE right side) moves but keeps the `::` index-reference face (residue 4).
  - Unmoved: c03 (bare base) and c08 (nested generate; ours already right). c04 and c05 (single selector) are
    stage 1 on both.
- **D, § genChildParentAtBirth261**:
  - Entering STRICT_EQUAL in the default view: d01 if-generate, d05 a generate inside the child, d11 a grandchild,
    and d13 macro + CRLF. Their elaborated views are byte-moved and STRICT_EQUAL on both binaries.
  - d12 (named and positional connections) is stage 1 on both and moves.
  - Unmoved: d03 process, d04, d06 case-generate, d07, d09 program, and d10 generate in generate.
  - d08 (an interface in a generate block) is not a birth face: ours shares the interface definition's objects
    (residue 5).
- **G, § pselConnArrPathName261**:
  - Entering STRICT_EQUAL in the default view: g03 (parent in a for-generate) and g04 (literal bounds).
  - g05 (positional, parameter bounds) is stage 1 on both and moves.
  - Unmoved: g01 and g02 (no generate array) and g06 (an interface child).
- **decode/B, E, F** (sister-ground faces, unmoved by every law): b01 is the rstmgr face; b02 and b03 are its
  STRICT_EQUAL controls. e01 is the testflags cast face. f01 is the flash_phy_rd ts-ref face.

## Byte controls

26 earlier repro dirs, 3504 case-views on pristine and law (evidence/controls.txt, controls_summary.txt,
controls_switches.txt). The dirs: r11u259, v11u259, r11u257, v11u257, r11u255, v11u255, r11u254, v11u254, r11u253,
v11u253, r11u252, v11u252, r11u251, r11u249, r11u247, r11u118, r11v11u118, r11u119, r11u120, r11u186, r11u155,
r11u154, r11u152, r11u193, r10uvm54 and r11u137.

- 20 moving, 4 entering STRICT_EQUAL, none leaving.
  - Entering: r11u254 G/g01_pkgsel_ps in both views (QSELNAME) and r11u255 decode/A/a03 in both views (SYSARGTS).
  - Moving otherwise:
    - r11u155 PS3 n01, n04 and n06 in both views (GENBIRTH). These are pass 155's own cases; the law gets their
      names right at the first read, so § 155's re-derivation no longer fires. No record moves.
    - r11u254 Q/q05 and q08, r11v11u118 v1/v30, v11u254 P/vp01 and vp06 (QSELNAME).
- No exit code and no uhdm-cmp line count changes.
- Away census 0 lost on all 20; 14 move toward golden (evidence/away_controls.txt).

## Firing census (predictor), frozen before the law sweep

evidence/predict_frozen.txt (md5 648bdde85b2136df0a1b5f5fe8b7163f, written 02:05 before the law sweep started) comes
from drivers/tracecensus.sh: the law binary under `R11U261_TRACE` over the probe cases and both corpora in both modes,
with the filter built from `$FENCED`. It names 545 databases: 379 probe, 121 surelog, 45 uhdm2rtlil.

- **Corpus**: byteverify over fence-filtered hard-link mirrors (2560 databases, 8 fenced paths skipped) reads MOVERS
  14 / 2560 (evidence/byteverify_corpus.txt; PATH_SETS_IDENTICAL; SELFCHECK 2559 of 2560). Every mover is
  predicted:
  - Earlgrey_0_1 d/t: content.
  - Rggen d (GENBIRTH:374): 8 dump lines. A part_select's full name gains `g_register_15`, toward golden; the strict
    count is unchanged because the walk is already misaligned there. Flat away 0 lost, 1 toward.
  - genscope_module_ctx_reset d/t (uhdm2rtlil, GENBIRTH): dumps identical.
  - BuildUVMPkg d/t, Scoreboard d and SimpleUVM d/t (CLSIMPORDER + GRP54ORDER): dumps identical.
  - MiniAmiq d/t and SeqDriver d/t (CLSIMPORDER + GRP54ORDER): dump lines reordered only, sorted dumps equal.
  - evidence/byteverify_dumpdiff.txt has the dump diffs.
- **Probe**: 72 / 4087 move, every one predicted (evidence/probe_byte_movers.txt).
  - 67 by CLSIMPORDER (one also GRP54ORDER), all with identical sorted dumps.
  - 3 by GENBIRTH, 1 by QSELNAME and 1 by SYSARGTS: these are the verdict movers below.
- **Downstream**: no verdict moves (below).

## Gates (law binary, from the worktree, `SLANG_UHDM` exported)

1. Builds: pristine 59fd71bb928e52946a4bf932aba35a98 (equal to main), law 3667c71c45081af8b7cf558a0a52d403.
   Binary-path audit: 3265 of 3315 fence-filtered cmds.txt per sweep name the frozen binary of that sweep; the other
   50 carry no slang line, the same set in both sweeps.
2. probe: `EQUAL=3566 STRICT_NOTEQUAL=521`, `regressions=0 conversions=1 changes=4` (evidence/sweeps/probe_L_vs_baseline.txt).
   - **CONVERSION** r10vrgg16repro/cells/v8 `differ:fullname(4) -> EQUAL` (§ genChildParentAtBirth261).
   - Changes:
     - r10earl41repro/v41v_comment `fullname(20) -> (18)` (§ pkgQualSelChainOwnName261).
     - r10earl_repro/ue `fullname(5) -> file(3)` (§ sysArgFoldTsUnitName261 fires twice there; the first
       differing field moves from fullname to file).
     - r10vearl108repro/m_gen108 `line(6) -> (3)` and r11v69repro/grid/v4_nestinst `line(4) -> (2)`
       (§ genChildParentAtBirth261).
   - Away census on these five: 0 lost each (v8 4 toward, v41v 2, m_gen108 3, v4_nestinst 2, ue 0).
3. surelog: `regressions=0 conversions=0 changes=2` (the two Earlgrey rows above). uhdm2rtlil:
   `regressions=0 conversions=0 changes=0`, 1606 of 1606. The pristine sweep reproduces the baseline exactly
   (regressions=0 conversions=0 changes=0 in all three stages, evidence/sweeps/*_P_vs_baseline.txt).
4. downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`, verdict diff against the pristine sweep and
   against results/downstream_uhdm2rtlil.csv 0. No downstream row is targeted. On the cases, 59 case dirs read
   IDENTICAL on both binaries (evidence/downstream_cases.txt).
5. uhdm-cmp: 0 lines on both Earlgrey row-modes (rc 0; the status stays judge-equal) and on every probe mover.
6. Away census on the corpus movers:
   - Flat (evidence/away_corpus_flat.txt): 0 lost on 12 of 14. On Earlgrey d/t it reads 1 lost, 68 / 57 gained.
   - Chain-keyed (drivers/awaychain.py with strictcmp_x): Earlgrey d away=0 toward=70, t away=0 toward=58
     (evidence/away_corpus_chain.txt).
   - The flat loss is one all-zero empty-named ref_typespec record. Golden holds 496, pristine 497 and the law 495.
     § sysArgFoldTsUnitName261 names #136315, so the multiset can no longer pair a surplus pristine empty with an
     unrelated golden one.
7. Canaries: surelog ok=50 changed=2 (Earlgrey d/t, targeted); uhdm2rtlil ok=16 changed=0; ctcan2 surelog
   (EXPECT_UNKNOWN=1) PASS; ctcan2 uhdm2rtlil (EXPECT_UNKNOWN=6) PASS.
8. Determinism:
   - drivers/det.sh ran three concurrent harness draws of the law binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
     SimpleUVM, Scoreboard and BuildUVMPkg in both modes. Every row-mode reads one hash, equal to the law sweep's
     (Scoreboard testflags has no database, as at the base) (evidence/det_law.txt).
   - 10 concurrent draws per view on the seven grp54 probe cases read one hash on both binaries.
9. `scripts/law_index.py` regenerated; `--check` reads current.

## Residues, ranked

1. **Earlgrey_0_1 default, 74 records, now headed by sister-ground faces**:
   - #233633 / #233638: ExprEmit § shadowedImportParamFold. pkgBoundValueConst9 stores no name, and the getter
     names the ref after the select where golden names the module. The site's own comment records golden's
     `work@<module>`. Reproduced as decode/B/b01.
   - #472295 to #481404 and #464077: 34 ts refs of folded package parameters in elaborated generate scopes, named
     after the scope or the select where golden names the instance. The writers are ExprEmit's emitExpr and
     stampFoldedPkgParamTs; gdb on decode/F/f01.
   - #482965 / #482968: an indexed-part-select width fold named `u_flash_eflash`, golden `...host_addr_i`. ExprEmit,
     same family.
   - #600811 / #600816: a fill constant's ts ref in a generate scope, golden unnamed. Not decoded.
   - #620047 to #620111: the tlul_socket_1n index ref `N`, golden `work@tlul_socket_1n.N`. No reduction reproduces it
     yet.
   - #658559 to #658579: the tlul_err_resp cont_assign order (line/name/depth). Not decoded.
   - Files: #395727 (enum_const without file; a reduction with a generate-block enum read, not kept, was STRICT_EQUAL on both binaries) and #439105 /
     #439106 (rv_dm.sv constants written as dm_pkg.sv, ParamEmit).
2. **Earlgrey_0_1 testflags, 4 records**:
   - #216212: ExprEmit, the compound assignment's `::` form.
   - #235310 / #235315: as #233633 above.
   - #403326: the elaborated cast target struct (`CpuCtrl_t'(csr_wdata_int)`) is the same object whose member a
     hier_path already reached, where golden's cast binds a per-use copy. The canonical walk then skips the visited
     member (`typespec_member unused_ctrl` vs ours `x`). The site is ExprEmit's cast-target typespec (the
     § castTsPushLaidOut131 family); reproduced as decode/E/e01 (elaborated view only).
   - Clearing these on the sister ground should CONVERT the testflags row: no ground-B record remains on it.
3. A/a15: the elaborated folded bound's endcol of a parameter's own type, ExprEmit. A/a06 and A/a10: a $clog2 read in
   a generate block (golden keeps the ref_obj) and in a package importer (golden names the ref `q`), stage 1 on both.
4. C/c02, r11u254 Q/q05 and Q/q08: a qualified select as the WHOLE right side of a generate continuous assignment.
   Golden's index references read `cp::RC::cp::RC::k` and its elaborated ts refs `cp::RC::cp::RC::cp::RC`. This is
   the generate-body half of § pkgSelIdxRefColons254 and was not attempted.
5. D/d08: an interface instantiated in a generate block shares its definition's cont_assign objects
   (`work@ifc.d`), where golden holds per-instance copies. G/g06: a part-select actual of an interface child.
6. Not attempted: pass 259's other residues (package-only importers, the elaborated member view, the home foreach
   variable, the four unfired shapes, v208_f_io), pass 257's (Rggen #92960, the F-family return typedef,
   § ifacePortMemberHighConnParent257's open shapes, the generate-localparam add size), passes 255 to 237's lists,
   and the decode's BuildUVMPkg clusters (that row is CMP_EQUAL).
7. Determinism audit: a scan of TypeEmit, ModuleEmit, UhdmExporter and TaskFuncEmit for loops over containers keyed
   by pointers whose bodies mint found nine. Two are converted here: grp54 (§ grp54IdOrder261) and classDefnMap
   (§ classImportsIdOrder261). The other seven do not mint in the loop: they are "first match, then break" lookups,
   which pick in pointer order when two entries match:
   - typedefTs at TypeEmit 4825 / 19934 and TaskFuncEmit 5079 / 5344 (by canonical type);
   - subMap at TypeEmit 23277 (by callee name);
   - defMap at ModuleEmit 10118 / 22525 / 37589 (by definition name).

   Every draw measured reads one hash. They are recorded, not changed.

## Sister-ground faces (decoded, call sites; not written)

- Earlgrey #233633 / #233638 (testflags #235310 / #235315): ExprEmit § shadowedImportParamFold (the call to
  pkgBoundValueConst9 with defStmtImportScope9). Golden names the ts ref `work@<module>`. decode/B/b01; b02 and b03 are
  STRICT_EQUAL controls.
- Earlgrey testflags #216212: ExprEmit, prim_prince.sv:81 `^=` in an always_comb (§ pkgSelIdxRefColons254 covers
  the plain whole right side only).
- Earlgrey testflags #403326: ExprEmit's cast-target typespec in the elaborated view. decode/E/e01.
- Earlgrey #472295 onward, #464077 and #482965: ExprEmit emitExpr / stampFoldedPkgParamTs, folded ts-ref names in
  elaborated generate scopes. decode/F/f01.
- MiniAmiq / SeqDriver #121302 / #121260 / #121272: StmtEmit § cloneLoopVarHomeObject183 (`res183`), unchanged.
- Rggen #27671: ExprEmit § selChainElemShapeIsSyntactic147, unchanged. BlackBePipeInt #331795 / #331692: ParamEmit,
  the import-copy Rhs, unchanged.

## Process

- **The implementer's slips**:
  - A first draft of § pkgQualSelChainOwnName261 sat in the select builder, which this path reaches with the prefix
    cleared, so it moved no byte (dev2). It was replaced by the delegate-site law before any binary was frozen.
  - A first draft of § pselConnArrPathName261 renamed after the bound folds and left the stamped ts refs behind
    (dev5). It was moved before the folds (dev6), then given the no-cache ts-ref rename (dev7).
  - The first law binary (dev8) was frozen and its firing census and grid had started when the audit's classDefnMap
    loop was added as § classImportsIdOrder261. Both runs were stopped by their own processes' pids, checked by
    `/proc/<pid>/cmdline` for this pass's name (pgrep on a bracketed `[r]11u261_...` pattern that cannot match the
    asking shell); their outputs were deleted unread. The binary was refrozen (law = dev9), and the census and grid
    were rerun from scratch before the law sweep.
  - The copy loop for the drivers wrote a `#` provenance line on top of strictcmp_x.cpp. It was corrected to `//`
    before the helper was compiled.
  - The byteverify dump-diff loop also read byteverify's summary line as a path. That produced one empty line, which
    was dropped from the evidence.
  - The pristine sweep and the first law-sweep run read "law index STALE" (this pass's cases were in place before
    tests/LAWS.md was regenerated): every stage ran and was compared, and the sweep's exit 1 is that check alone.
- **The fence**: every corpus database scan went through fence-filtered path lists (bvmirror.sh; the cmds.txt audit
  as `find | grep -vwE "$FENCE_RE" | xargs grep`). The firing census ran with the `$FENCED` filter. Every evidence
  file was checked for the fenced names (none). No fenced source or database was dispatched, read or opened outside
  the gate sweeps.
- **Tools**: every tool call went through a `[ -x ]` guard (drivers/env.sh, case.sh).
- **Scratch**: worktree /tmp/wt_r11u261; scratch /tmp/r11u261_*.

## Files

- `src/R261.h`: switches and trace.
- `src/TypeEmit.cpp`: § sysArgFoldTsUnitName261, § pkgQualSelChainOwnName261.
- `src/ModuleEmit.cpp`: § genChildParentAtBirth261, § pselConnArrPathName261, § classImportsIdOrder261.
- `src/UhdmExporter.cpp`: § grp54IdOrder261.
- Cases, each first line naming its law:
  - `cases/A` (21, § sysArgFoldTsUnitName261), `cases/C` (13, § pkgQualSelChainOwnName261),
    `cases/D` (13, § genChildParentAtBirth261), `cases/G` (6, § pselConnArrPathName261).
  - `decode/B` (3, § shadowedImportParamFold), `decode/E` (2, § castTsPushLaidOut131), `decode/F` (1,
    § stampFoldedPkgParamTs): sister-ground reductions, unmoved.
- `drivers/`: pass 259's, retargeted to R11U261.
- `evidence/`: grid, controls, away censuses, frozen prediction, byteverify, probe movers, Earlgrey records before
  and after, per-switch Earlgrey rows, determinism, downstream on the cases, sweep comparisons.
