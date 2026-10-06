# r11u269: pass 269, the module/type ground (Earlgrey_0_1's port-actual struct members, the UVM type_id clones)

Base abc22480. Five laws behind `src/R269.h`, in `src/TypeEmit.cpp`, `src/UhdmExporter.cpp` and `src/ModuleEmit.cpp`.
Each law reads its own `R11U269_<LAW>_OFF` switch, `R11U269_OFF` drops all five (pristine's bytes on every grid
case-view), and `R11U269_TRACE=<dir>` logs every firing. No corpus row converts: every row this ground reaches is
still headed by a sister-ground record. Sixteen probe cases convert, every one predicted by name before the law sweep.

| row-mode | base strict | law sweep row | what moved |
|---|---|---|---|
| Earlgrey_0_1 testflags | `differ:fullname(14)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(105),,differ:fullname(105)` | All 14 base records cleared: #580520 to #594077 (the 13 port-actual struct-member records, § topNestedArrElemTopTwin269) and #604991 (the `depth` record where pristine's walk diverged). The walk now runs to the end of the design (no `objects` line; pristine read `objects 1342584 vs 1342968`). The 105 records it now reaches are all on the sister ground (below). Away census 0 lost, flat and chain-keyed (1981 chain records toward golden) |
| Earlgrey_0_1 default | `differ:fullname(192)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(192),,differ:fullname(192)` | Bytes move, the strict column is unchanged: no module-ground record was left on this row-mode (all 192 sister ground). The chain-keyed census reads 0 away and 10559 records toward golden (the raw full names inside the elaborated struct copies, which the comparator canonicalises) |
| MiniAmiq default / testflags | `differ:depth(1)` | `MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` (testflags the same) | Bytes move, the head #134648 is the sister's (StmtEmit). The object gap behind it shrinks: 435559 vs 435060 -> 435559 vs 435526. Away census 0 lost, 469 chain records toward golden |
| SeqDriver default / testflags | `differ:depth(1)` | `SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` (testflags the same) | Bytes move, heads #134606 / #134618 unchanged (sister). Object gap 475526 vs 475095 -> 475526 vs 475512 (testflags 475538 vs 475107 -> 475524). Away census 0 lost, 422 toward |

Probe conversions (STRICT_NOTEQUAL -> EQUAL in the law sweep; results/ untouched), all by § cloneTdSpecDeepCopy269:

    CONVERSION r10uvm112repro/a10_sameargs        differ:depth(1) -> EQUAL
    CONVERSION r10uvm112repro/a6_sortbase         differ:depth(1) -> EQUAL
    CONVERSION r10uvm112repro/a7_twogroups        differ:depth(1) -> EQUAL
    CONVERSION r10uvm112repro/a9_diffnames        differ:depth(1) -> EQUAL
    CONVERSION r10uvm212repro/grid_c7_cuclass_foreignpkg_and_pkgclass_design  differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g10_twomacros         differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g12_twoinclass        differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g15_twopkg_two        differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g18_arity             differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g1_asciiedge          differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g2_digits             differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g3_fiveclasses        differ:depth(1) -> EQUAL
    CONVERSION r10v112repro/g5_oneline            differ:depth(1) -> EQUAL
    CONVERSION r10v212repro/gridv_v1_ordersplit_design        differ:depth(1) -> EQUAL
    CONVERSION r10v212repro/gridv_v8_bothforeign_twopkg_design differ:depth(1) -> EQUAL
    CONVERSION r10v212repro/gridv_v9_cu_base_pkg_clone_design  differ:depth(1) -> EQUAL
    CHANGE     r10v112repro/g19_builtin           differ:file(6) -> differ:file(10) [file +4]

g19_builtin's count grows because its walk no longer diverges (pristine `objects 62 vs 48`, the law's walk runs to
the end). Its first five records (#4 / #7 / #23 / #26 / #39, the base's unlocated type_parameter and param_assign)
are unchanged; the new records are the same span face on the copies, which carry the base's (empty) span. The
chain-keyed census on it reads 0 away, 12 toward.

## The laws

1. **§ topNestedArrElemTopTwin269**, switch `R11U269_TOPARRELEM_OFF`, TypeEmit, the design-final
   `modPkgTypedefTopTs15` (helper `topNestedArrElemTopTwin269`).
   - The face (Earlgrey testflags #580520 to #594077): `reg2hw.mp_region_cfg[0].en.q`, a port actual in
     flash_ctrl_reg_top. Golden binds `en` to the member of a struct copy named
     `work@flash_ctrl_reg_top.flash_ctrl_reg_pkg::flash_ctrl_reg2hw_mp_region_cfg_mreg_t`; ours bound the package
     listing's member (`flash_ctrl_reg_pkg::flash_ctrl_reg_pkg::...::en`).
   - Bisected from the Earlgrey source (cases A/a07, then A/a02): the shape needs a struct typedef with a
     struct-typed member (`addr_t addr;`) beside a packed array of a struct typedef (`mreg_t [1:0] cfg;`), in a
     wildcard-imported package, read through `-elabuhdm`'s hier_path binding. Without the struct-typed member (A/a01)
     ours was already right. Pass 267's three reductions missed the struct-typed member.
   - The decode (gdb watchpoints on the packed array's element reference, evidence in this README only): our
     elaborated package listing of such a struct is emitPackage's `topNested` form, left UNPARENTED until
     UhdmExporter typedefParentModel134 parents it at the module at the end. The def/top member cross-wire
     (ParamEmit emitPackage) hands the top struct the packed array the DEF pass built, whose element is the DEF
     listing's `mreg_t`. § modPkgTypedefTopTs15's module-owned re-point fixes that element only when the parent
     walk reaches a module, which an unparented top struct never does (A/a01's top struct is parented, so it is
     re-pointed there).
   - The law re-points the element of every packed-array member of an unparented top-view struct or union listing
     to the element typedef's elaborated twin (the same def -> top map, `d2t15`), in UhdmId order.
   - A first version wrote the twin at creation (makeTypespec's packed-array branch); the cross-wire then moved that
     array into the DEF struct. It was withdrawn before any gate measurement.
2. **§ cloneTdSpecDeepCopy269**, switch `R11U269_TDCLONEDEEP_OFF`, UhdmExporter `copyClassTdSpecParams1`, the § 54
   drain (`overwrite1`) only.
   - The face (MiniAmiq #136655, behind the sister head, reproduced on a scratch binary): uvm_pkg's
     `uvm_algorithmic_comparator::type_id`, a clone whose base is the last `uvm_component_utils` expansion
     (svaunit_base). Golden lists `type_parameter T -> ref -> class_typespec svaunit_base` and a param_assign whose
     Rhs (a second copy of T, bound to svaunit_base) and Lhs (a copy of the generic's formal T at its span, bound to
     uvm_component) both print. Ours shared the base's actual and pointed the param_assign's Rhs at the Parameters'
     T and its Lhs at the generic's own formal: shared objects the walk lists once, read as T unbound and an empty
     param_assign.
   - Surelog: `ElaborationStep::bindTypedefs_` gives a group's later typedefs `clone_tree` of the base, a deep copy.
   - The law gives each clone fresh copies: the class_typespec actual (name, span, file, class_defn, its own
     specialization copied the same way), any other actual kind through UHDM's `clone_tree` with Surelog's context
     (U/u02, `type Q = int`, which a9_diffnames needed), a separate Rhs type_parameter, the Lhs formal (name, span)
     with a copy of its actual, and the base parameter's and param_assign's spans.
3. **§ retTopRangeOwnPkg269**, switch `R11U269_RETRANGEOWNPKG_OFF`, ModuleEmit `drainFuncRet` (sets
   `retTopPkg269`) and TypeEmit's package-parameter range binding in `emitSyntaxExpr`.
   - The face (MiniAmiq #177415, behind #136655 on the scratch binary): uvm_globals.svh 421
     `function logic[UVM_LARGE_STRING:0] uvm_string_to_bits` with `$swrite(uvm_string_to_bits, ...)`. The
     per-reference return-name local that drainFuncRet mints for the elaborated package listing bound
     `UVM_LARGE_STRING` to svaunit_pkg's import-copy value constant (typed `svaunit_pkg`), because the drain runs
     after every package view and the symbol-keyed maps hold the last package to list the parameter. Golden binds
     the home package's own object.
   - The law binds the range parameter to the elaborated home package object's own param_assign value when the drain
     compiles that package's subroutine (R/r01: a package importing the home; r03 two parameters, r04 two importers,
     r05 a localparam).
4. **§ selLhsOpFoldFresh269**, switch `R11U269_SELOPFOLD_OFF`, ModuleEmit `emitContAssigns` (the def-share gate).
   - Pass 267's residue R/r11 to r14: a bit, part, indexed-part select or concatenation Lhs whose Rhs is an
     operation over literals and parameters (`assign w[8:0] = {AllPagesW{1'b1}}`). Golden folds it per instance
     (UhdmWriter::writeCont_assign's trailing `simplified == false` branch: reduce, clone, install the constant parented
     at the clone); ours shared the definition's cont_assign and its operation (uhdm-cmp stage 1).
   - The law lets such an assignment re-emit fresh, where the general fold and § caFoldParentUnboundLhs267 then fold
     and parent it. It fires only when the operation's own width is the Lhs width: the reducer keeps the operation's
     width (S/s05 `w[3:0] = P + 1` reads `UINT:6 size 64` in golden, and pristine already re-emits that one), and a
     first version without this test moved s05's elaborated view from STRICT_NOTEQUAL to stage 1 on the grid; it
     was refined before any gate measurement. A cast Rhs (s08), a signal operand (s07) and a member-rooted select
     (s10) keep the share.
5. **§ caLhsBindsUpScopes269**, switch `R11U269_BINDUP_OFF`, ModuleEmit `emitGenScopes`, § genCaReplWholeFold78's
   mint (helper `caLhsBindsUpScopes269`).
   - Pass 267's residue (v11u267repro VB/vb01, vb02, vb03, vb09): CompileHelper::bindVariable switches on function /
     task / begin / module_inst and tail-recurses on VpiParent, so a gen-local net named like a net of the enclosing
     module (vb01 `x`, the port), or like a net of an instantiating module (vb02 `w`, vb09 `zz`, B/b06 the
     grandparent), and an interface gen-scope signal named like a net of the instantiating module (vb03 `s`) all
     bind by name, and golden leaves the replication fold unparented. `caLhsBindsByName267` read only the declaring
     scope.
   - The helper walks the Lhs symbol's scopes up to its instance body, tries a MODULE body by name (net or variable),
     then the body's parent instance, up to the root. Controls: no name above (B/b05), a parameter of that name
     (b07), an interface whose instantiator lacks the name (b08) keep the parent.

Withdrawn before any gate measurement: a sixth law that kept the gen-scope replication unfolded under a reference
delay (VB/vb04). The golden dump shows the fold there (`BIN:1010`, unparented); the residue on vb04 is the
missing `vpiDelay` on our gen-scope cont_assign (golden: `ref_obj D` in the definition, the constant 1 elaborated),
whose def-view ref `D` is the stage-1 head on both binaries.

## Grid (evidence/grid.txt, gridsum.txt, grid_away.txt)

drivers/grid.sh runs 58 case dirs (A 20, B 11, R 8, S 12, U 7) in both views on 8 configurations (pristine, law,
`R11U269_OFF`, each switch off): 116 case-views, 928 lines, every line carrying its exit code.

- `R11U269_OFF` gives pristine's bytes on 116 of 116.
- 73 case-views move, 44 enter STRICT_EQUAL, none leaves; no exit code changes. Each mover is moved by exactly one
  switch: TOPARRELEM 22, TDCLONEDEEP 14, RETRANGEOWNPKG 5, SELOPFOLD 16, BINDUP 16.
- Away census (drivers/awayall.sh): the record census reads 0 lost on every mover that passes stage 1 on both
  binaries. Stage-1 movers use the dump census:
  - S/s04_ipart_local_el loses one generic `|vpiParent:` line (a print-position artefact; the case enters
    STRICT_EQUAL, dump distance 15 -> 1).
  - S/s03_concat_repl default view: stage 1 -> `depth`, dump distance 1 -> 3 with 37 golden lines gained. Its
    remaining record: the concatenation Lhs's refs bind our instance nets where golden's clone keeps the definition's
    nets.
  - U/u04_spec_actual (stage 1 on both, a nested specialization argument): distance 13 -> 21 and 32 -> 46 with
    32 / 61 golden lines gained and 0 lost; the copies print, golden's head face is elsewhere.
  - U/u01 and u06 grow by one record not in golden while their walks reach further (u01 #32 -> #56).
- Downstream (evidence/ds_cases.txt): the 57 single-file case dirs read the same verdict on both binaries, 56
  IDENTICAL and A/a20 STATUS_DIFF (Surelog's READ_FAIL).

| cases | law | what they cover |
|---|---|---|
| A/a02, a03, a07, a12, a15, a16, a17, a19 | § topNestedArrElemTopTwin269 | struct-typed member first or after, the Earlgrey reg_top reduction (multi-file, real package), a cont_assign Rhs path, a module-local variable, two definitions, the array one struct level down, CRLF: every elaborated view enters STRICT_EQUAL |
| A/a09, a10, a11 | § topNestedArrElemTopTwin269 | an enum element array, two dimensions, the element typedef in another package: bytes move, STRICT_EQUAL on both |
| A/a01, a04, a05, a06, a08, a13, a14 | § topNestedArrElemTopTwin269 | controls: no struct-typed member, a vector typedef member, a plain member, a second user, a union container (parented), an explicit import, no import: unchanged |
| A/a18, a20 | § topNestedArrElemTopTwin269 | an unpacked container, an interface port: stage 1 on both (a20 rc 4 on both) |
| U/u01 to u07 | § cloneTdSpecDeepCopy269 | a class actual, an int actual, three clones over two packages, a specialization actual, an enum actual, two type parameters and a value parameter, the macro-written typedef: u02, u03, u07 enter STRICT_EQUAL; u01 moves to its next face (`#56`, the type-parameter use, residue 1); u05 depth -> fullname; u06 keeps `file` (the base's span) |
| R/r01, r03, r04, r05 | § retTopRangeOwnPkg269 | an importer, two parameters, two importers, a localparam: default views enter STRICT_EQUAL |
| R/r02, r06, r07, r08 | § retTopRangeOwnPkg269 | no importer, the return name assigned (`f[0]`, depth on both), a class method (stage 1 on both), a called function (stage 1 on both) |
| S/s01 to s04, s06, s09, s11, s12 | § selLhsOpFoldFresh269 | part, bit, concatenation, indexed-part with a localparam count, unary, an unpacked element, a parameter index, a multi-bit literal: all but s03's default view enter STRICT_EQUAL |
| S/s05, s07, s08, s10 | § selLhsOpFoldFresh269 | controls: an `int` operand, a signal operand, a cast, a member-rooted select: unchanged |
| B/b01 to b04, b06, b09, b10, b11 | § caLhsBindsUpScopes269 | vb01 / vb02 / vb03 / vb09, the grandparent, a for-generate, a parent variable, a nested generate: every elaborated view enters STRICT_EQUAL (b01, b03, b11 both views); the default views of b02, b04, b06, b09, b10 stay stage 1 on both (the parent net `w` listing, not this law) |
| B/b05, b07, b08 | § caLhsBindsUpScopes269 | controls: unchanged |

## Gates (base abc22480)

1. **Build.** Pristine `52573f406f01c43fb57d2d6c829e7f48` (the main tree's md5). Law `885a66ea315bff7d08675ba2e6e38e2f`.
2. **Probe.** EQUAL 3591 + STRICT_NOTEQUAL 496, regressions=0, conversions=16, changes=1 (g19_builtin, above).
   Pristine's sweep reads the baseline exactly (3575 + 512, 0 changes).
3. **Corpora.** surelog 944 + 10, regressions=0, conversions=0, changes=1 (Earlgrey testflags, above);
   uhdm2rtlil 1606 + 0, no change. Pristine: 0 changes in both.
4. **Downstream.** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on both binaries, csv identical,
   0 of 805 slang-lane databases moving (evidence/downstream_bytes.txt).
5. **uhdm-cmp.** 0 lines and rc 0 on all six corpus movers (evidence/uhdmcmp_rows.txt).
6. **byteverify** on fence-filtered hard-link mirrors (drivers/bvmirror.sh, 8 fenced databases skipped unread),
   SELFCHECK 2559 / 2560: 6 of 2560 corpus databases move (Earlgrey_0_1 d/t, MiniAmiq d/t, SeqDriver d/t); 19 of
   4087 probe databases (evidence/probe_byte_movers.txt).
7. **Prediction.** The firing census (drivers/tracecensus.sh, frozen before the law sweep as
   evidence/predict_frozen.txt, 31 lines) names every mover. It also names six databases that do not move: BuildUVMPkg
   d/t, Scoreboard d, SimpleUVM d/t and probe r10uvm67repro/c5_clone, where § retTopRangeOwnPkg269 fires once and
   binds the object the old chain already chose (the bytes are identical). § selLhsOpFoldFresh269
   and § caLhsBindsUpScopes269 fire on no corpus or probe database.
8. **Canaries.** surelog ok=51 changed=1 (Earlgrey testflags), uhdm2rtlil ok=16; both ctcan2 checks PASS.
9. **Binary-path audit.** On both sweeps 3265 of 3315 fence-filtered cmds.txt name that sweep's own binary; the
   other 50 carry no slang line.
10. **Away census.** On all 25 byte movers (6 corpus, 19 probe), chain-keyed with the raw-full-name comparator
    (drivers/awayrows.py): 0 away on every one (evidence/away_all_movers.txt, away_corpus_chain.txt). Flat
    (drivers/awaycorp.sh): 0 lost on all six corpus movers (evidence/away_corpus_flat.txt).
11. **Determinism.** drivers/det.sh: three concurrent draws of the law binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
    SimpleUVM, Scoreboard, BuildUVMPkg and Rggen read one hash per row-mode, equal to the sweep's (evidence/det_law.txt;
    Scoreboard and Rggen testflags have no database).
12. **Byte controls** (evidence/controls.txt, controls_summary.txt): 37 earlier repro dirs (r11u118, r11v11u118,
    r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u148share, r11u152, r11u155, r11u164,
    r11u175uvm, r11u176, r11u183dec, r11u186, r11u193, r11u212, r11u253, r11u256, v11u256, r11u257, r11u259,
    r11u260, v11u260, r11u261, v11u261, r11u262, v11u262, r11u263, v11u263, r11u265, v11u265, r11u267, v11u267,
    r10uvm54), 5286 case-views on both binaries: 22 move, 14 enter STRICT_EQUAL, none leaves, no exit code changes.
    Each mover is moved by exactly one switch (evidence/controls_movers_switches.txt): r10uvm54 a1 TDCLONEDEEP,
    r11u152 UQ/u06 TOPARRELEM, r11u267 R/r11 to r14 and v11u267 VA/va04 SELOPFOLD, v11u267 VB/vb01, vb02, vb03, vb09
    BINDUP. Away census (evidence/controls_away.txt): 0 lost except R/r14_el's one `|vpiParent:` line (s04's twin);
    r10uvm54 a1 (stage 1 on both, head unchanged) gains 95 / 191 golden dump lines while its distance grows
    67 -> 108 / 262 -> 347: the copies print, and golden locates the copied type_parameter at the formal (47:20)
    where the base, and so the copy, is unlocated in ours (residue 3).

Both sweeps exit 1 on the law-index staleness check alone (the case files predate the regenerated index, which the
patch carries).

## Behind the sister head on MiniAmiq and SeqDriver (evidence/uvm_scratch_decode.txt)

A scratch-only binary (never delivered; StmtEmit restored byte for byte after each build) added the one registration
the sister's head needs (emitCtorBody27's EK_BID branch registering its Lhs with § importCloneBodyLocalCopies175's
`cloneLocalLhs175`). With it and this pass's laws, default mode:

- MiniAmiq: the sister registration alone moves the head #134648 -> #136655; with this pass's laws the row reads
  `differ:endcol(2)` with head #217949, `objects 435559 vs 435553`.
  #136655 (§ cloneTdSpecDeepCopy269) and #177415 (§ retTopRangeOwnPkg269) are cleared.
- SeqDriver: -> `differ:depth(1)` at #218195.

The faces that remain there:

1. **#218195 (SeqDriver) and MiniAmiq #223178, this ground.** `uvm_component_registry::create_component`'s local
   `T obj` (and, behind it, `static function T create`'s return variable, #218260): golden's reference shares the
   type parameter's own default class_typespec, which the walk has already listed; ours mints a per-use copy
   (§ classTpDefaultTsAtUse180, with § typeParamUseSharesOwnTs183 deferred by § typeParamDefersToTpUse186).
   Measured: `R11U186_TPDEFER_OFF=1` on the scratch binary moves SeqDriver to #218260 (the return variable, which
   the 183 branch does not reach because its call passes the return-type syntax), and keeps BuildUVMPkg d/t,
   SimpleUVM d/t and Scoreboard d CMP_EQUAL in one draw; pass 186's determinism coin was not re-measured.
2. **MiniAmiq #217949, sister ground.** `$sformatf(..., get_user_name(), `SVAUNIT_VERSION_STRING)` over two lines:
   golden ends the call at 434:75, ours at 434:85 (the expression span with a macro last argument; ExprEmit).

## Decoded faces on the sister ground (report only)

- **Earlgrey default (192) and testflags (105) records left by this pass**, all on the expression/parameter ground:
  - 15 `ref_obj k` records (`reg2hw_wrap.alert_en[k]` in a generate loop): golden names the index through the
    written path, ours by scope; ExprEmit's hier_path select-index naming (`ir->VpiFullName(prefix + "." + varIdx)`).
  - The `tlul_socket_m1` family: 145 (default) / 58 (testflags) ref_typespec full names and 29 indexed_part_select
    endcols (`tl_h_i[i].a_source[0+:8 - 2]`, golden 97:40, ours 97:39); ExprEmit's indexed-part-select width fold
    naming (§ genIpsBoundOwner256 / stampFoldedPkgParamTs family).
  - 3 `int_typespec` file records (default #1465373 / #1465389 / #1488054, testflags #1141614 / #1141630 /
    #1163456): the elaborated param_assign fold's int typespec. `localparam int AVFifoWidth = NBufWidth;` (a
    parameter whose value is another parameter folded from `$clog2`) gets golden's fresh unlocated int where ours
    shares the declaration's located one; reproduced by a one-module case (`localparam int NBufWidth =
    $clog2(NBuf); localparam int AVFifoWidth = NBufWidth;`, STRICT_NOTEQUAL `file` on pristine). `localparam int
    NEndpoints = usbdev_reg_pkg::NEndpoints` (golden usbdev.sv 91, ours the package's line) did not reproduce
    in that case. ParamEmit, the elaborated param_assign fold.
- **MiniAmiq / SeqDriver heads #134648 / #134606 / #134618**: StmtEmit `emitCtorBody27`, the `EK_BID` branch (above).

## Residues, ranked

1. The type-parameter use face behind the sister's UVM head (above, item 1): the next record on both UVM rows once
   the sister lands; TypeEmit's 180 / 183 / 186 family, with the return-variable branch (TaskFuncEmit `retTypeSyn175`
   call) not reached by § typeParamUseSharesOwnTs183.
2. Pass 267's VB/vb04: the gen-scope cont_assign's `vpiDelay` (ours none; golden `ref_obj D` in the definition, the
   folded constant 1 elaborated), stage 1 on both binaries.
3. The base type_parameter's span on a class-typedef group (U/u06, g19_builtin, r10uvm54 a1): golden locates the
   type_parameter and its param_assign at the generic's formal, ours leaves them unlocated; the clones copy the
   base, so they follow once the base is fixed (§ classSpecExprArgUnlocated202's family).
4. U/u05: the enum copy's base-reference raw full name (golden `up::c2::tid::T::bp::e_t`, ours `bp::e_t`); U/u04 a
   specialization argument (stage 1 on both).
5. § selLhsOpFoldFresh269's open shapes: a concatenation Lhs in the default view (S/s03, the refs' bindings), an
   `int`-width operation (S/s05, golden's unadjusted 64-bit constant), a member-rooted select (S/s10, stage 1).
6. The default views of the parent-net cases (B/b02, b04, b06, b09, b10): stage 1 on both binaries on the parent's
   net listing, not decoded.
7. § retTopRangeOwnPkg269's neighbours: the return name written with a bit select in an importer copy (R/r06, depth on
   both), a class method's range (r07) and a called function (r08), stage 1 on both.
8. § topNestedArrElemTopTwin269's open shapes: an unpacked container (A/a18) and an interface port (A/a20, rc 4).
9. The brief's items (3) (pass 265's residues other than #136655, pass 260's cast-copy re-parent in
   typedefParentModel134), (4) and (5) (passes 263, 261, 259 and earlier), and pass 267's law-3 shapes (vc11, vc12,
   vc14, P/p10, the program / var / pkg:: ports) and vd05: not attempted.

## Process

- Every corpus reader read `$FENCED` (drivers/env.sh, fail closed): the census through the harness with the fence
  filter, byteverify and the binary audit on fence-filtered path lists, rowhead / awaycorp / awaychain / awayrows on
  the six movers only.
- THE IMPLEMENTER'S FENCE NOTE: while locating `prim_subreg` I ran one `grep -rn` over the Earlgrey_0_1 `src`
  tree (Earlgrey's own sources; no fenced test lives there, nothing fenced was opened or run), where the rule asks
  for a filtered path list first. Every later lookup named files explicitly.
- A debug-info build of the worktree (a scratch build directory, never delivered) carried temporary prints during
  the decode. One of them broke an `if / else` in ParamEmit and changed the output; every print was removed, the
  sources restored with `git checkout`, and the later decodes used gdb only (python watchpoints, no allocation).
- No process was signalled. Waiters used bracketed patterns.

## Files

- `cases/` holds 58 case dirs (A, B, R, S, U), each first line naming its law; A/a07 is a three-file case read
  through its `args` file (flash_ctrl_reg_pkg and prim_subreg from Earlgrey, a reduced flash_ctrl_reg_top).
- `drivers/` holds case.sh, grid.sh, gridsum.py, controls.sh, ctlsum.py, tracecensus.sh, bvmirror.sh, rowhead.sh,
  det.sh, the away census drivers, dscases.py, cc_x.sh with strictcmp_x.cpp (copied from r11u267repro), and
  idobj.cpp, a new reader printing every object's UhdmId, parent and reference target (identity, which neither the
  dump nor the strict walk shows; fail-closed on `$FENCED`).
- `evidence/` holds the measurements named above.
