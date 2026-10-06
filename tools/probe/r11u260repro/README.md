# r11u260: pass 260, the expression/parameter ground (Earlgrey_0_1's expression-ground records)

Base a609e392 (pass 258). Pristine binary md5 c84be26c6817dd700c631e458e1683f6 (identical to the main tree's
build), law binary md5 395ec3e583221d108d2e0c2f5042143b, both linking slang 12.0.0+545f88b2e. Three laws in
`src/ExprEmit.cpp` behind `src/R260.h`. Each law has its own `R11U260_<LAW>_OFF` switch, and `R11U260_OFF` drops all
three; it gives pristine bytes on every case-view of the grid (146 of 146). `R11U260_TRACE=<dir>` logs every firing
and every abstention, one file per process (`<dir>/<pid>.260`).

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep | first record |
|---|---|---|---|
| Earlgrey_0_1 default | `differ:fullname(36)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:file(34),,differ:file(34)` | #233633 / #233638 cleared; new head #395727 (sister ground) |
| Earlgrey_0_1 testflags | `differ:fullname(4)` | `Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(20),,differ:fullname(20)` | all four old records cleared (#216212, #235310, #235315, #403326); new head #446024 |

NO CORPUS ROW CONVERTS. The brief expected the testflags row to convert once its four records were cleared. All
four are cleared, but the walk no longer diverges at #403326 (a `depth` record, after which pristine's walk
stopped), so it reaches 16 more records further on. None of them is one of the old four:

    testflags, the law sweep (evidence/earlgrey_testflags_L_records.txt):
    #446024 fullname  ref_typespec  golden work@top_earlgrey.u_ram1p_ram_main   ours work@top_earlgrey
                      (pass 256's #464077 face in this view: ExprEmit, a folded header parameter as an ips width in an
                       if-generate; not attempted)
    #530951 / #530956 fullname  ref_typespec  golden <none>  ours ...i_prim_ram_2p_async_adv.gen_secded
                      (the default row's #600811 / #600816: a fill constant's ts ref; not decoded)
    #580520 to #594077 (12 records) fullname  ref_typespec of a typespec_member bound by the elaborator under a port
                      actual hier_path `reg2hw.mp_region_cfg[0].en.q` (flash_ctrl_reg_top.sv:1003): golden's member
                      belongs to a struct copy named `work@flash_ctrl_reg_top.flash_ctrl_reg_pkg::<type>.en`, ours to
                      the package listing (`flash_ctrl_reg_pkg::flash_ctrl_reg_pkg::<type>::en`). Port connection:
                      ModuleEmit, the sister ground.
    #604623 / #604627 / #604631 file  int_typespec  golden flash_erase_ctrl.sv 9:13  ours flash_ctrl_pkg.sv 18:14
                      (THIS ground, the shadowed import fold: see residue 1)
    #604991 depth (the walk diverges)

The default row's first field changes from fullname to file: #233633 / #233638 are cleared and the head is now
#395727 (an enum_const without a file, sister ground), followed by the records the base already had (#464077,
#600811 / #600816, #620047 to #620111, #658559 onward).

Old heads at the base (evidence/earlgrey_*_P_records.txt):

    default   #233633 fullname  ref_typespec  golden work@rstmgr_ctrl  ours work@rstmgr_ctrl.rst_req_i
    testflags #216212 fullname  ref_obj DataWidth  golden prim_cipher_pkg::PRINCE_ROUND_CONST::prim_cipher_pkg::
              PRINCE_ROUND_CONST::prim_cipher_pkg::PRINCE_ROUND_CONST::DataWidth
              ours work@prim_prince.p_pre_round_xor.prim_cipher_pkg::PRINCE_ROUND_CONST.prim_cipher_pkg::...DataWidth
              #235310 / #235315 as #233633
              #403326 depth  golden typespec_member unused_ctrl (ibex_cs_registers.sv 167)  ours ref_obj csr_wdata_int

The away census reads 0 lost on both row-modes (gate 6). The count grows on testflags only because the walk reaches
further.

## The laws

1. **§ pkgSelPsBoundColonsElab260** (ExprEmit, emitExpr's NamedValue branch at the § pkgSelIdxRefColons254 call; helper
   `psBoundRefElab260`; switch `R11U260_PSELELAB_OFF`). Clears #216212.
   - § pkgSelIdxRefColons254 gives a reference in the bound of a two-level package-qualified select golden's `::`
     name (`cp::RC::cp::RC::cp::RC::W`). It is off in the `--elabuhdm` view because the elaborated listing is UHDM's
     DeepClone of the definition's object, which copies a stored name (`*clone = *this`), where golden's clone reads
     the dotted chain.
   - THE DECODE. A reference in a PART-SELECT BOUND (`[W-1:0]`) never reaches the clone when it names an overridable
     parameter: the elaborator reduces the clone's bounds to constants in golden and in ours, so only the definition
     listing holds the reference, and there golden writes the `::` form in both views (cases X x01, x04, x07, x10 to
     x13, x15, x16, x18, x23; r11u254repro decode/P p01 to p07 in the elaborated view).
   - It abstains when the reference is a localparam (header or body, even with a literal value): the clone keeps that
     reference (X x06, x21, x22, where a first draft moved the clone away from golden). It also abstains on an
     element index (`R3[0][W-1]`, X x09 and r11u254 Q/q01: the clone keeps it), an indexed part select (X x08), and
     anything that is not a selector's simple range bound built of arithmetic and parentheses.
   - The law extends the view gate only; the shape tests (two or more levels, the whole right side of an
     assignment, the qualified base) stay § pkgSelIdxRefColons254's.
2. **§ shadowedImportTsRefOwner260** (ExprEmit, the § shadowedImportParamFold branch of emitExpr; helper
   `shadowFoldOwnerCtx260`; switch `R11U260_SHADOWTSOWNER_OFF`). Clears #233633 / #233638 and #235310 / #235315.
   - A module's read of a local parameter that a wildcard-imported package also declares folds to the PACKAGE's value
     (pkgBoundValueConst9). That function stores no name on the fold's ref_typespec, so the getter read the parent
     chain (`work@rstmgr_ctrl.rst_req_i`).
   - Golden names it `work@<definition>` when the fold IS the whole slot (parentheses aside): a part-select bound, an
     indexed part-select base or width, a replication count, or a system-call argument. This holds in both views
     (S s01, s03, s05, s10 to s12, s23 to s27).
   - Inside an operation (`OffD-1`, a ternary), as a bit-select index, or as a plain operand, golden keeps the parent
     chain (`work@ctrl.a`, `work@ctrl.nb`). The law abstains there (S s02, s04, s15 to s18, s21, s28; a first draft
     without the slot test moved those away).
   - A system call's argument is parsed as SimpleSequenceExpr / SimplePropertyExpr / OrderedArgument; the helper
     steps through them.
3. **§ castStructInstCopy260** (ExprEmit, the Conversion branch where the cast's ref_typespec is bound; helpers
   `castAggInstCopy260` and `castMembersCopy260`; switch `R11U260_CASTSTRUCTCOPY_OFF`). Clears #403326.
   - A cast to a packed STRUCT typedef written in an elaborated instance listing (a re-emitted continuous assignment
     or process, not a subroutine) targets a per-use COPY of the struct in golden, in both views. Surelog compiles
     the cast's type in the instance.
   - The copy is parented at the cast's ref_typespec and keeps the listing's name, span, vpiInstance and packing. Its
     members' references read `<scope>.<typedef>.<member>` (`work@top.u.t_t.x`, a package typedef
     `work@top.u.p::t_t.x`). Golden lists every copy at the top level of the dump (decoded on cases E e01 to e07,
     e11, e16, e17; one copy per instance). (Verifier correction, v11u260: the law writes that parent and those
     names, but the database it delivers holds the copy WITHOUT a parent and its member references named `t_t.x`:
     UhdmExporter typedefParentModel134 re-derives typedef parents after emission, moves the copy to no parent
     (`R11U134_DBG=1` prints `TDPARENT t_t -> (none)` on e01) and renames the names below its members. The
     strict walk reads neither a parent nor a full name inside a typespec copy, so no gate sees it; see
     tools/probe/v11u260repro/README.md.)
   - Nested aggregates are copied too:
     - a struct member gets a copy of its struct (`work@top.u.t_t.n.in_t.k`, e06);
     - a union member likewise (`work@top.u.t_t.x.u_t.p`, e16);
     - a packed-array member gets a copy of the array, whose element reference reads the member's name and whose
       element struct is copied (`work@top.u.t_t.x.in_t.k`, e17).
   - Other member typespecs are shared. Typespec identity is canonicalised by the comparator; golden also copies the
     leaf logic_typespecs, which no walk record can see.
   - Ours bound the shared listing struct. A member path the elaborator had already bound to one of its members
     (`rd.unused_ctrl`, Earlgrey's `cpuctrl_d.unused_ctrl`) made the canonical walk skip that member under the cast:
     the `depth` divergence #403326.
   - A cast in a module function (e09) or a class method (e14's class) gets no copy. Enum and vector typedef casts
     (e10, e12) are not struct casts. A member with a default value makes the whole cast abstain.

## Grid (cases/, every case's first line names its law)

73 case dirs (E 19, S 30, X 24), every one in both views on six configurations: pristine, law, law with
`R11U260_OFF`, and the law with each switch off. That is 876 lines, every one carrying its exit code
(evidence/grid.txt, evidence/gridsum.txt).

Totals over 146 case-views:
- 57 moving and 23 entering STRICT_EQUAL. None leaves STRICT_EQUAL, no exit code changes, and no uhdm-cmp line count
  changes.
- `R11U260_OFF` gives pristine's bytes on 146 of 146.
- Each mover is moved by exactly one switch: PSELELAB 13, SHADOWTSOWNER 22, CASTSTRUCTCOPY 22.
- 144 case-views exit 0 on both binaries. The other two are E/e04 in both views, which exits rc 4 on both (an
  `Invalid` expression, stage 1 on both, pre-existing).

The cases by law:
- **E, § castStructInstCopy260**:
  - Enter STRICT_EQUAL in the elaborated view: e01_inst_hier, e02_top, e03_pkg_td, e05_proc, e06_nested,
    e07_param_width, e11_unpacked_inst_depth3, e16_union_member and e17_arr_member.
  - Their parse views move bytes only and stay STRICT_EQUAL; so do e14_class in both views.
  - e04_two_inst moves and is stage 1 on both binaries (pre-existing).
  - Unmoved: e08_gen (if-generate, already STRICT_EQUAL), e09_func, e10_enum, e12_vector_td, e13_iface (stage 1 on
    both), e15_unpacked (STRICT_NOTEQUAL file on both), e18_ff_member_after (STRICT_EQUAL on both), and e19_for_gen2
    (residue 3).
- **S, § shadowedImportTsRefOwner260**:
  - s01_ips_width (Earlgrey's shape) enters STRICT_EQUAL in both views.
  - Fullname -> line in both views (the fullname records cleared): s03, s05, s10, s11, s12, s23, s24, s25, s26 and s27.
    The remaining line record is residue 1.
  - Unmoved, the abstentions: s02, s04, s06, s13 to s21 and s28. s07, s08, s09, s22, s29 and s30 are stage 1 on both
    binaries (pre-existing).
- **X, § pkgSelPsBoundColonsElab260**:
  - Enter STRICT_EQUAL in the elaborated view: x01, x03, x04, x07, x10, x11, x12, x13, x15, x16, x18 and x23.
  - x19_paren_bound_el moves (its fullname record cleared) and keeps a pre-existing col record on both binaries.
  - Unmoved: x02 (a single level: golden keeps the dotted name), x05 and x17 (operands), x06, x21 and x22
    (localparams), x08, x09, x14, x20 (pre-existing on both, § pkgSelIdxRefColons254's own shapes) and x24.
  - The default views do not move (the law extends the elaborated view only).

Away census of the grid movers (evidence/away_grid.txt; drivers/awayall.sh: record multisets when both sides pass
stage 1, uhdm-dump line multisets otherwise): 0 lost on every one of the 57.
- The record distance to golden falls or stays: S 3 -> 1, X 1 -> 0, E 0 -> 0 with 6 to 20 golden records gained in
  the elaborated view.
- e04 (stage 1 on both) reads dist 3 -> 7 / 4 -> 8 on uhdm-dump lines with 0 lost and 35 gained. The copies'
  member lines are golden's. (Verifier correction, v11u260: the 4 added lines golden lacks are the copy's two
  member references named `t_t.a` / `t_t.x` where golden writes `work@top.u.t_t.a` / `work@top.u.t_t.x`, the
  rename above, not leaf-typespec copies.)

Downstream on the 73 case dirs (drivers/dscases.py, evidence/downstream_cases.txt): 73 IDENTICAL on pristine and 73
IDENTICAL on the law.

## Byte controls

20 earlier repro dirs, 1566 case dirs, 3132 case-views on pristine and law (evidence/controls.txt,
controls_summary.txt). The dirs are r11u261, v11u261, r11u258, v11u258, r11u256, v11u256, r11u254, v11u254, r11u252,
v11u252, r11u131, r11v131, r11u118, r11v11u118, r11u119, r11u120, r11v124, r11u124, r11u140 and r11u172rp.

- 15 moving, 8 entering STRICT_EQUAL, none leaving, no exit code or uhdm-cmp line count changing.
- Entering STRICT_EQUAL:
  - r11u254 decode/P p01, p02, p03, p06 and p07 in the elaborated view (§ pkgSelPsBoundColonsElab260): pass 254's
    own `--elabuhdm` decodes;
  - r11u261 decode/B/b01 in both views (§ shadowedImportTsRefOwner260);
  - r11u261 decode/E/e01 in the elaborated view (§ castStructInstCopy260).
- Also moving:
  - r11u254 Q/q01_el (2 -> 1 records);
  - q02_el (stage 1 on both, dump distance 49 -> 43, 0 lost);
  - q05_el (records unchanged; one elaborated generate-scope reference now reads golden's `::` name, invisible to
    the walk);
  - v11u254 P/vp03_el (5 -> 3 records);
  - r11u261 decode/E e01 and e02 parse views and e02_el (STRICT_EQUAL on both).
- The away census of the 15 control movers reads 0 lost on all (evidence/away_controls.txt).

## Firing census (predictor), frozen before the law sweep

evidence/predict_frozen.txt (md5 0dd5978c413289693277bef80b7908ef, frozen 2026-10-06T05:39:10-04:00, before the law
sweep started) comes from drivers/tracecensus.sh: the law binary under `R11U260_TRACE` over the probe cases, both
corpora in both modes and the downstream lane, with every filter built from `$FENCED`.
- It separates firing lines from abstention lines: `MOVER` names a database where a law fired, `abstain-only` one
  where a law only tested and stepped aside.
- It names 7 movers:
  - surelog Earlgrey_0_1 default (castStructInstCopy260 3, shadowedImportTsRefOwner260 4);
  - surelog Earlgrey_0_1 testflags (the same plus pkgSelPsBoundColonsElab260 1);
  - surelog ConstantBits d/t (castStructInstCopy260 1 each);
  - uhdm2rtlil CastStruct d/t (castStructInstCopy260 1 each);
  - downstream CastStruct (castStructInstCopy260 1).
- 0 probe databases fire. 20 surelog testflags rows read abstain-only (verifier correction, v11u260: the frozen file holds 20) (the elaborated-view test of
  § pkgSelPsBoundColonsElab260 stepping aside).
- Positive controls: the frozen law binary under `R11U260_TRACE` writes a firing line for each law on X x01, E e01
  and S s01 in the elaborated view.

Movers (byteverify over fence-filtered hard-link mirrors, 2560 databases, 8 fenced paths skipped unread;
PATH_SETS_IDENTICAL; evidence/byteverify_corpus.txt): MOVERS 6 / 2560, exactly the six predicted corpus databases:
Earlgrey_0_1 d/t, ConstantBits d/t (STRICT_EQUAL on both binaries, the cast copy invisible to the canonical walk,
chain away 0 / toward 0) and uhdm2rtlil CastStruct d/t (the same). No UVM order mover.

SELFCHECK flags 2559 of 2560. The self-check compares every file with one fixed file, and that file cannot flag
itself, so 2559 is the expected reading, not a mover line.

Probe: 0 of 4087 databases move (path sets identical, fence-filtered). Downstream: 1 of 805 databases moves,
CastStruct, as predicted; the downstream csv is byte-identical to pristine's (CastStruct IDENTICAL on both)
(evidence/probe_downstream_movers.txt).

## Gates (law binary, from the worktree, `SLANG_UHDM` exported)

1. Builds: pristine c84be26c6817dd700c631e458e1683f6 (equal to the main tree's build/slang-uhdm), law
   395ec3e583221d108d2e0c2f5042143b. Both were frozen (chmod 555) under scratch before any measurement.
   - Binary-path audit (drivers/binaudit.sh, the path list filtered by `$FENCED` before any cmds.txt is opened): per
     sweep, 3315 cmds.txt, of which 3265 name that sweep's frozen binary, 0 name another, and 50 have no slang line.
     8 fenced paths were skipped unread.
2. probe: `EQUAL=3566 STRICT_NOTEQUAL=521`, `regressions=0 conversions=0 changes=0`. The csv is byte-identical to
   pristine's.
3. surelog: `regressions=0 conversions=0 changes=2`. The CHANGES are:
   - `Earlgrey_0_1 default STRICT_NOTEQUAL differ:fullname(36) -> differ:file(34)`: a first-field change, with the
     old head #233633 / #233638 cleared.
   - `Earlgrey_0_1 testflags STRICT_NOTEQUAL differ:fullname(4) -> differ:fullname(20) [fullname +16]`: all four old
     records cleared. Pristine's walk diverged at #403326 (`depth`); the law's walk passes it and diverges at
     #604991. The old first record is #216212 and the new one #446024; the away census reads 0 lost.
   - uhdm2rtlil: `regressions=0 conversions=0 changes=0`, 1606 of 1606.
   - The pristine sweep reproduces the baselines exactly (regressions=0 conversions=0 changes=0 in all three
     stages).
   - The only other csv row differences are the LowMemLib / LowMemPkg testflags detail text, which embeds the
     workdir (evidence/surelog_csv_rowdiff.txt).
   - Both sweeps exit 1 on the law-index staleness check alone: the case files existed before tests/LAWS.md was
     regenerated, and the index is current in the patch.
4. downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871); not identical and not excused=0`. The csv is
   byte-identical to pristine's.
5. uhdm-cmp: 0 lines on all six corpus movers.
6. Away census on the corpus movers (drivers/awaychain.py, chain-keyed, evidence/away_corpus.txt):

   | row-mode | away | toward | flat_away | flat_toward |
   |---|---|---|---|---|
   | Earlgrey_0_1 default | 0 | 11 | 0 | 11 |
   | Earlgrey_0_1 testflags | 0 | 61 | 0 | 61 |
   | ConstantBits d/t | 0 | 0 | 0 | 0 |
   | CastStruct d/t (uhdm2rtlil) | 0 | 0 | 0 | 0 |

7. Canaries:
   - surelog: ok=50 changed=2 (the Earlgrey rows, targeted).
   - uhdm2rtlil: ok=16 changed=0.
   - ctcan2 surelog (`EXPECT_UNKNOWN=1`) PASS; ctcan2 uhdm2rtlil (`EXPECT_UNKNOWN=6`) PASS.
8. Determinism (drivers/det.sh): three concurrent harness draws per binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
   SimpleUVM, Scoreboard and BuildUVMPkg in both modes (evidence/det_law.txt, det_pristine.txt).
   - Every row-mode reads one hash on each binary. Scoreboard testflags has no database, as at the base.
   - The law's Earlgrey hashes equal the law sweep's (0d28327c9ef4 / a603c2abcb02). The five UVM rows are
     byte-identical between the binaries.
9. `scripts/law_index.py` regenerated; `--check` reads current.

## Residues, ranked

1. **The shadowed import fold's typespec location** (THIS ground, ExprEmit § shadowedImportParamFold): Earlgrey
   testflags #604623 / #604627 / #604631 (flash_erase_ctrl.sv's header `parameter int AddrW` shadowing flash_ctrl_pkg's;
   golden's int_typespec at the module's own declaration 9:13, ours the package's at flash_ctrl_pkg.sv 18:14).
   - Reproduced on every S case that passes stage 1 except s01: they read `line` at the module's `localparam int`
     (6:14) against ours at the package's (3:14).
   - The fix rebinds the fold's ref_typespec to the shadowing local parameter's own typespec (paramTs / the
     listing's parameter object). Not attempted.
2. **Earlgrey testflags' other records**:
   - #446024 is pass 256's #464077 face (a folded header parameter as an ips width in an if-generate, golden names
     the owning instance), ExprEmit, not attempted.
   - #530951 / #530956 is the #600811 face (a fill constant's ts ref in a generate scope, golden unnamed), not
     decoded.
   - #580520 to #594077 are the port-actual member binding (residue 5, sister ground).
3. **§ castStructInstCopy260 in for-generate scopes**: e19 (a cast two for-generate levels down) keeps the `depth`
   record in the elaborated view. The generate-scope continuous assignment does not reach the re-emitted branch, so
   the law does not fire there. An if-generate (e08) is STRICT_EQUAL on both binaries.
4. § pkgSelIdxRefColons254's own open shapes, which this pass did not extend:
   - an element index (X x09, r11u254 Q/q01's R3);
   - an indexed part select (x08);
   - a select inside a concatenation (x20);
   - generate bodies (x14, r11u254 Q/q05);
   - localparams in the elaborated view (x06, x21, x22), where the clone keeps the reference and the definition
     listing's name cannot be set without moving the clone.
5. Not attempted:
   - items (2) to (7) of the brief: the address-ordered loops of pass 258's residues, BlackBePipeInt
     #331795 / #331692, and passes 256 to 238's residue lists;
   - Earlgrey default's #464077 and #600811 / #600816.

## Sister-ground faces (call sites; not written)

- Earlgrey default #395727: an enum_const without a file (the new head).
- Earlgrey default #620047 to #620111: ModuleEmit dottedLhs, the tlul_socket_1n shared cont_assign. #658559 onward:
  the tlul_err_resp cont_assign order.
- Earlgrey testflags #580520 to #594077: a typespec_member bound under a port actual hier_path
  (`reg2hw.mp_region_cfg[0].en.q`, flash_ctrl_reg_top.sv:1003) belongs in golden to a struct copy named
  `work@flash_ctrl_reg_top.<pkg>::<type>.<member>`, ours to the package listing. This is ModuleEmit's port
  connection, or the elaborator's binding on our shared listing.
- MiniAmiq / SeqDriver #126482 / #126534 / #127274 and #127418: UhdmExporter § cloneAggMemberOwn241 and
  § cloneMemberImporterListing259 / § pkgCloneMember10, as pass 258 reported; unchanged here (byte-identical).
- Rggen #92960: ModuleEmit § genLpUnpackedArray, unchanged.
- vf01: TypeEmit, the class struct-member ref_typespec full name.

## Process

- Drafts measured on cases only, never frozen as the law binary:
  - § pkgSelPsBoundColonsElab260 without its gate (every elaborated view): r11u254 Q/q01's element-index
    reference moved away;
  - the gate without the overridable-parameter test: X x06 moved away;
  - § shadowedImportTsRefOwner260 without its slot test: S s02, s04, s15 to s18, s21 and s28 moved away;
  - § castStructInstCopy260 copying struct members only: E e16 and e17 left `name` records.
- The firing census was started once on an earlier frozen law binary (struct-only copy) and stopped by its own task
  id before it finished. Only this pass's processes were stopped (checked with a bracketed pattern on this pass's
  scratch paths). Its outputs were deleted unread, and the census was rerun from scratch on the final binary before
  the law sweep.
- Every dump went through `[ -x "$UHDM_DUMP" ]`.
- The fence:
  - Every corpus database scan went through fence-filtered path lists (bvmirror.sh, binaudit.sh, and the probe and
    downstream mover lists `find | grep -vwE "$FENCE_RE"`).
  - The firing census ran with the `$FENCED` filters.
  - The only corpus databases opened outside the gate sweeps are Earlgrey_0_1, ConstantBits and CastStruct (named
    movers) and the six determinism rows.
  - No fenced source or database was dispatched, read or opened outside the gate sweeps.
  - The whole-word scan for the fenced names reads 0 on the patch, this directory and src/R260.h.
- Ground: production edits are in `src/ExprEmit.cpp` plus the new `src/R260.h` only. The sister files were read, not
  edited.
- Scratch: worktree /tmp/wt_r11u260; scratch /tmp/r11u260_*.

## Files

- `src/R260.h`: switches and trace.
- `src/ExprEmit.cpp`: the three laws:
  - § pkgSelPsBoundColonsElab260 (`psBoundRefElab260`, the § pkgSelIdxRefColons254 call);
  - § shadowedImportTsRefOwner260 (`shadowFoldOwnerCtx260`, the § shadowedImportParamFold branch);
  - § castStructInstCopy260 (`castAggInstCopy260`, `castMembersCopy260`, the cast's ref_typespec).
- `tests/LAWS.md`: regenerated.
- Cases: `cases/E` (19), § castStructInstCopy260; `cases/S` (30), § shadowedImportTsRefOwner260; `cases/X` (24),
  § pkgSelPsBoundColonsElab260.
- `drivers/`: pass 258's, retargeted.
  - tracecensus.sh separates firing lines from abstention lines.
  - The rest as delivered: grid.sh, gridsum.py, case.sh, controls.sh, ctlsum.py, awayall.sh, away.py, awaydump.py,
    awaychain.py, awayrows.py, bvmirror.sh, binaudit.sh, det.sh, dscases.py, rowhead.sh, cc_x.sh / strictcmp_x.cpp,
    env.sh.
- `evidence/`: grid and gridsum, away censuses (grid, controls, corpus), controls and summary, the frozen
  prediction, byteverify, probe and downstream movers, Earlgrey records (pristine and law, both modes), determinism
  draws, downstream on the cases, csv row diffs and sweep summaries.
