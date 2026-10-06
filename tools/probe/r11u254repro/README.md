# r11u254 — pass 254, the expression/parameter ground (ExprEmit, StmtEmit)

Base aeabc99d (pass 252 on top of pass 255). Six laws behind `src/R254.h`. Each law reads its own
`R11U254_<LAW>_OFF` switch, and `R11U254_OFF` drops all of them (pristine bytes on 176 of 176 grid case-views).
`R11U254_TRACE=<dir>` logs every firing, abstentions included, as `<law> <detail>`.

## 1. Verdicts on the targeted rows

| row-mode | base (results/golden_surelog.csv) | this pass (fresh sweep csv) |
|---|---|---|
| BuildUVMPkg default | STRICT_NOTEQUAL differ:endcol(1) #194627 | **CMP_EQUAL, CONVERTED**: `BuildUVMPkg,default,CMP_EQUAL,,,equal` |
| BuildUVMPkg testflags | STRICT_NOTEQUAL differ:endcol(1) | **CMP_EQUAL, CONVERTED**: `BuildUVMPkg,testflags,CMP_EQUAL,,,equal` |
| Earlgrey_0_1 default | differ:fullname(155) | differ:fullname(133) (`Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(133),,differ:fullname(133)`) |
| Earlgrey_0_1 testflags | differ:fullname(50) | differ:fullname(40) |
| BlackBePipeInt d/t | depth(1) #331795 / #331692 | unchanged (item 3 not attempted, section 6) |

BuildUVMPkg's last record at the base, #194627, ground A:
`hier_path factory.is_type_registered uvm_pkg.sv 14097:13`, golden endcol 46, ours 39. It is cleared by
§ shellCallInvocationSpan254, and BuildUVMPkg is CMP_EQUAL with strict `equal` in both modes. On Earlgrey, the first
record stays #136315 / #137760, which is TypeEmit and so the sister's ground (section 5). These records are cleared:
#154375 / #165002 and t #155820 / #166447 (§ hcSelIdxTsSkipsPort254), #193018 and t #194478 (§ procReplCountOwner254),
#214553 / #346618 (§ pkgSelIdxRefColons254), and the gen_fwd_pass / gen_bwd_pass ref_typespecs from #346678
(§ genCaPsBoundOpChain254). The rstmgr port-connection records #233668 / #233688 are cleared as well
(§ procReplCountOwner254, port branch).

Probe conversions, from the fresh `probe.csv`:
- STRICT_NOTEQUAL -> EQUAL: `r10earl82repro/g6_earl82` fullname(1), `r10earl_repro/qa20` fullname(1),
  `r10earl_repro/wd` fullname(1), `r10uvm160repro/g160_c_context` endcol(1), `r10uvm167repro/g167_b_spell` endcol(2),
  `r10v167repro/vA_meth` endcol(9) and `r10v167repro/vD_kinds` endcol(2).
- One change: `r10earl41repro/v41v_comment` fullname(24) -> fullname(20), the same first field with fewer objects.

## 2. The laws (all in src/ExprEmit.cpp except the last; anchors are the § tokens)

1. **§ shellCallInvocationSpan254** (`R11U254_SHELLSPAN_OFF`, ExprEmit Call branch at § callParenSpan11).
   * When a method call's argument does not convert, slang wraps the call in an InvalidExpression. The call keeps no
     syntax of its own (§ shellCallKeepsItsSyntax167), and its range is only the callee member access.
   * Golden (Surelog never binds the argument) spans the whole invocation.
   * The shell's invocation syntax is read through `callInvocation167` for that exact call, under the same rule as
     § callParenSpan11 (same start, reaching further).
   * Statement-position calls (method_func_call) already carried golden's span. The law fires there (the traces count
     it) but no bytes move: grid I/i05, the UVM rows, and five probe cases.
2. **§ hcSelIdxTsSkipsPort254** (`R11U254_HCSELPORT_OFF`, the package-parameter fold stamp in emitExpr's NamedValue
   branch, helper `hcSelIdxTsSkipsPort254`).
   * Golden's ref_typespec name on a folded imported-parameter index is UHDM `BaseClass::ComputeFullName`, which skips
     a port directly above a bit_select.
   * Ours kept the port segment: `work@top.u.a.pmp_req_err` against golden's `work@top.u.pmp_req_err`.
   * The walk climbs only bit_selects and operations to the port. The segment just before the climbed selects' own
     names must spell the port, and it is dropped. Any other shape abstains.
3. **§ procReplCountOwner254** (`R11U254_REPLCOUNT_OFF`, the same stamp plus the Replication branch's `replCountOp254`).
   * An imported parameter folded as the DIRECT repeat count is Surelog's getValue clone, parented at the owning
     module's param_assign. Golden's reference therefore names the owning module: `work@pinmux`, not the named block
     `work@pinmux.p_sleep`.
   * The same holds inside a function or task, and in a port connection, where the port and its instance are climbed.
   * The owning module is named by its module_inst full name. That is the definition in a definition listing and the
     instance path in an elaborated one (`work@wdtop.u0`, probe wd).
   * An operation as the count (`{N+1{e}}`) is not reached, and golden keeps the enclosing name there (R/r10).
   * The law abstains through generate scopes, packages, classes, interfaces and programs.
4. **§ genCaPsBoundOpChain254** (`R11U254_GCAPSOP_OFF`, `genCaUseSiteChainName169`'s new part_select /
   indexed_part_select branch).
   * A part-select bound that is an OPERATION over a folded parameter, in a generate-scope continuous assignment, is
     named through the select: `work@top.gen_fwd[0].cp::RC.cp::RC`. Ours kept the instance (`work@top`).
   * A direct bound keeps the landed instance rule.
   * A select that is a component of a member path abstains (G/g07). Golden names it from the path's folded text,
     which this walk does not have. This refinement was added after law v16's corpus away census found 87 flat
     records on Earlgrey's xbar `gen_host_fifo` (chain key 0).
5. **§ pkgSelIdxRefColons254** (`R11U254_PKGSELREF_OFF`, the NamedValue ref naming, helper `pkgSelIdxRefColons254`).
   * Golden names a reference read inside a select of a package-qualified base with `::` and without the scope:
     `cp::RC::cp::RC::cp::RC::W` for `cp::RC[0][W-1:0]`, and `cp::R3::cp::R3::W` for `cp::R3[W-1][0]`. The base is
     written once more than the select levels.
   * This happens when the select chain has two or more levels, read on the syntax (the IdentifierSelectName
     selectors), and is the whole right side of an assignment or continuous assignment.
   * A single level (prim_prince p_key_expansion line 59, dm_mem 471), an operand (p_post_round_xor line 167, the
     elaborated gen_fwd_pass at line 106) and an unqualified base keep the dotted name. Laws v9 and v13 got this wrong
     and were withdrawn after the Earlgrey run, section 4.
   * The law is off under `--elabuhdm`. There, golden's elaborated listing keeps the dotted name, while ours is UHDM's
     DeepClone of the definition's object and copies the name (Q/q01, q05).
6. **§ forInitSelectLhsBase254** (`R11U254_FORINITSEL_OFF`, src/StmtEmit.cpp, the outside-variable for-init branch).
   * `for (s.a = 0; ...)`, `for (arr[0] = 0; ...)` and `for (v[3:0] = 0; ...)` wrote no Lhs. Golden writes a ref_var
     named for the base (`work@top.s`) and located at the base identifier.
   * UHDM `ElaboratorListener::enterFor_stmt` reads `Lhs()` without a null check. This was the rc 139 crash in the
     elaborated view of `tools/probe/r11v124repro/hx/x02_forstep` (pass 252's residue). That case now reads
     STRICT_EQUAL in both views.
   * A `this` / `super` base and a package-qualified base abstain, because golden writes a variable object there (F/f04,
     V/v05).

## 3. Grid (cases/, decode/P, plus r11u255 decode/A and r11v124 hx/x02; drivers/grid.sh, evidence/grid.txt)

* **Size**: 88 case dirs in both views, 176 case-views. Each case-view ran on 9 configurations (P, L, OFF, and each of
  the six switches), 1584 lines, every line with its exit code.
* **Switch census** (drivers/gridcensus.py, evidence/grid_census.txt):
  * `R11U254_OFF` gives pristine bytes on 176 of 176.
  * Each switch moves only its own law's cases: SHELLSPAN 28, HCSELPORT 18, REPLCOUNT 18, GCAPSOP 6, PKGSELREF 11,
    FORINITSEL 13.
  * Q/q05 and q08 are moved by two laws, GCAPSOP and PKGSELREF, both written for that shape.
* **Verdict census**: 92 case-views move, 60 enter STRICT_EQUAL and none leave.
* **First-field changes**:
  * H/h08_el fullname -> endcol: the operand-index fold span is the next face.
  * Q/q02 and decode P/p08 fullname -> type: the walk diverges later, on golden's var_select where ours folded a
    constant.
  * F/f02_el and V/v05_el: SLANG_FAIL (rc 139) -> stage 1.
* **Exit codes**: six pristine crashes (rc 139, all `--elabuhdm` for-init shapes) now exit 0. No exit code worsens.
* **uhdm-cmp lines**: they rise only on two stage-1 case-views, F/f02 (15 -> 17) and V/v05 (15 -> 38). In both, the
  first mismatch moved later: f02 reaches `sa[1].b`, where golden's ref_var carries a ref_typespec, and v05 reaches the
  abstained `pv::gs.a`.
* **Away census** (drivers/awaychain.py, chain and flat keys, evidence/grid_away.txt): 86 of 86 movers that have a
  pristine database read chain away=0 and flat away=0. The other 6 movers are pristine rc 139 crashes.
* **Constant slots**: covered by I/i18, H/h13 to h17, R/r14, G/g03 and Q/q06. Fresh shapes from brief item (h) are in
  cases/V: extern and pure-virtual prototypes, named calls, interface bodies, a generate-local net and an implicit net,
  parameter and specialization slots, nested replication and streaming.

## 4. Gates (frozen binaries; evidence/sweeps_summary.txt)

* **Binaries**:
  * Pristine is md5 86b9049a3c31716209e7ba2a4778d03e, the main tree's.
  * The law binary is md5 29b5f8dd6c98e6a45638f52a735486c3, built from the patch's tree.
  * Both report slang 12.0.0+545f88b2e.
* **Binary-path audit** (fence-filtered cmds.txt): 3265 of 3315 name the swept binary in each sweep. The other 50 are
  the golden-cache-miss runs with no slang line. 0 lines name another binary.
* **Probe** (`tests/sweep.sh --corpus probe`):
  * regressions=0, conversions=7, changes=1, EQUAL 3559 + STRICT_NOTEQUAL 528.
  * The pristine sweep equals the committed baseline (3552 / 535, 0 / 0 / 0).
* **Surelog** corpus: regressions=0, conversions=2 (BuildUVMPkg d/t), changes=2 (Earlgrey d/t, -22 / -10).
* **uhdm2rtlil** corpus: regressions=0 conversions=0 changes=0 (1606 + 0).
* **Downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. The verdict diff is 0 against both the
  baseline and the pristine sweep, and 0 of 805 downstream slang-lane databases move.
* **uhdm-cmp**: 0 lines on all four corpus movers (BuildUVMPkg d/t, Earlgrey d/t).
* **byteverify** (fence-filtered hard-link mirrors, drivers/bvmirror.sh, 2560 of 2568 mirrored, the 8 fenced row-modes
  left out unread):
  * There are exactly 4 movers: BuildUVMPkg d/t and Earlgrey_0_1 d/t.
  * SELFCHECK reads 2559 of 2560. That is the self-check artifact pass 201 recorded: the one fixed file the comparator
    corrupts against is compared with itself and cannot be flagged. It is not a movers line.
* **Firing census and prediction**:
  * The census was frozen before the law sweep (drivers/tracecensus.sh, then drivers/predict2.py counting only firings
    that write; evidence/census_predict_*.txt).
  * Predicted corpus databases (11): BuildUVMPkg d/t, Earlgrey d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t and
    SimpleUVM d/t.
  * Moved: the 4 named above. The 7 UVM row-modes fire § shellCallInvocationSpan254 only on statement-position calls
    (`uvm_report_fatal`, `uvm_report_warning`, `write`), whose span was already golden's, so their bytes do not move.
  * Predicted probe databases (13); moved: 8, all predicted. The 5 that fire without moving are statement-position
    shells: g103_a2, a2_position, d10_argstmt, v103_c5_slots and v162_3_ctx.
* **Away census on the corpus movers** (chain and flat keys, evidence/corpus_movers_cmp_away.txt):
  * BuildUVMPkg d/t: 0 lost and 1 toward per mode.
  * Earlgrey d/t: 0 lost, with 23 and 11 toward.
* **Canaries**:
  * surelog ok=48 changed=4, all targeted.
  * uhdm2rtlil ok=16 changed=0.
  * ctcan2 surelog PASS (ok=58).
  * ctcan2 uhdm2rtlil PASS (ok=2).
* **Determinism** (drivers/det.sh, three concurrent draws on Earlgrey_0_1 and the five UVM rows, plus the sweep): one
  hash per row-mode on 11 of 11. Scoreboard testflags is SLANG_REJECT at the base.

## 5. Ground-B faces reported with their call sites (not written)

* **Earlgrey #136315 / #137760** (`$clog2(NumRound)` in a typespec range, decode/A/a03 of r11u255):
  * Pass 255 attributed this to ExprEmit's § sysFuncArgFold. That is wrong.
  * The ref_typespec is minted by **TypeEmit `crossPkgBoundFoldConst9`**, reached from `emitSyntaxExpr` /
    `makeTypespec` (gdb on `MakeRef_typespec`).
  * Golden parents the constant at the package param_assign (line 3) and names the reference `work@sha2`. Ours stores
    no name (§ crossPkgFoldTsNameOnChain152's chain).
  * This is Earlgrey's first record in both modes.
* **Earlgrey #190726 / #190744** (padring logic_typespec endcol): TypeEmit.
* **Earlgrey #214166 to #214360** (prim_present `k` gen-block ref full names): the module ground.
* **Earlgrey #214684 / #214686 / #214818 / #214824** (the definition-view var_select / part_select full names):
  TypeEmit emitSyntaxExpr's § defGenPathSel161.
* **Earlgrey #233633 / #233638** (rstmgr port-typespec full names): ModuleEmit.
* **Earlgrey #375033 onward** (`...if_stage_i.prefetch_buffer_i...` lacking the `gen_prefetch_buffer` scope in
  elaborated instance paths): ModuleEmit instance prefix.
* **MiniAmiq / SeqDriver #95125 / #95083 / #95095**: UhdmExporter § cloneAggMemberOwn241's drain. Unchanged here.

## 6. Residues, ranked

1. **Earlgrey_0_1 d/t 133 / 40.** The head is TypeEmit (section 5). The records remaining on this ground:
   * **(a)** In a generate definition body, golden writes the `::` form even for an operand select
     (Q/q08 `a ^ cp::RC[k][W-1:0]`, `cp::RC::cp::RC::k`). § pkgSelIdxRefColons254 abstains there, so the
     operand-versus-whole-RHS rule holds only outside generate bodies.
   * **(b)** In the same whole-right-side shape, golden names the folded W's ref_typespec in the `::` form
     (`cp::RC::cp::RC::cp::RC`). § genCaPsBoundOpChain254 writes the dotted chain; both pristine and this pass are
     wrong there.
   * **(c)** The member-path select names (G/g07: golden names from the path's folded text).
2. **BlackBePipeInt d/t #331795 / #331692** (item 3), not attempted. The bisect from its package source,
   pass 252's residue 3 and pass 250's A/a02 are all unchanged.
3. **The for-init `this.k` and package-qualified bases** (F/f04, V/v05): golden writes an int_var named for the
   enclosing scope.
   * The `--elabuhdm` crash stays on `this.k` (F/f04_el rc 139 on both binaries).
   * `sa[1].b` (F/f02) lacks golden's ref_typespec on the ref_var.
4. **§ procReplCountOwner254's open shapes:**
   * the gen-scope if-generate continuous assignment, where golden's name is empty (R/r11);
   * the class method, where golden names `work@top::c` (R/r14);
   * interface bodies, which are stage 1 on both binaries (R/r13).
5. **The shell-call shapes still stage 1 on both binaries:**
   * I/i02, the static call: golden `ref_obj fac::reg2`.
   * I/i07 and i14, a call-result receiver: golden writes an unnamed method_func_call.
   * I/i08 and i15, an index of a member array: rc 4, `unsupported expression kind: Invalid`.
   * I/i18, an indexed part-select whose base is a shell call: no start location, a separate face.
6. **The high-conn faces not written:**
   * H/h08_el: the operand-index constant endcol 22 against 20.
   * H/h06, V/v02 and R/r12: interface or generate connections, stage 1 on both binaries.
7. **Not attempted**: brief items (4) to (7) beyond the pass 252 crash in residue (4), which this pass fixes.
   * Yosys on VS vs03's database: not attempted.
   * Pass 250's, 248's and earlier residues, N0033 / N0025, the map 15 brief, N0008, the value encodings and the UVM A
     families: carried unchanged.

## 7. Byte controls and downstream on the cases

**Byte controls** (drivers/controls.sh, evidence/controls.txt). These ran on pristine and law over 14 earlier repro
dirs: r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11v124repro, r11u131repro, r11u169repro,
r11u192repro, r11u250repro, r11u252repro, v11u252repro, r11u255repro, v11u255repro and r11u115repro. That is 968 case
dirs and 1936 case-views, and every line carries its exit code.

* **Moving: 15.** 8 enter STRICT_EQUAL and none leave.
  * r11u169 gc/c04: fullname -> STRICT_EQUAL (§ genCaPsBoundOpChain254).
  * r11u255 decode/A a01, both views (§ shellCallInvocationSpan254) and a02, both views (§ hcSelIdxTsSkipsPort254).
  * r11v11u118 v1/v09_vsvar (§ hcSelIdxTsSkipsPort254).
  * r11v124 hx/x02_forstep, both views. The elaborated view goes rc 139 -> 0 (§ forInitSelectLhsBase254).
* **Bytes only:** r11u169 c04_el, r11u250 decode/E e01, both views (the pass-250 decode of Earlgrey's prim_prince,
  4 records toward golden in the definition view), and r11v11u118 v1/v30_vs_genfor (4 toward).
* **Not attributable to a law:** v11u255 F/vf03, both, and vf08, both views, are pass 255's known pristine
  determinism defect. TypeEmit collectFwWinners98's specialization order varies per run: pristine itself writes
  2 hashes in 5 draws on vf03. Their strict verdict is STRICT_EQUAL on both binaries.
* **Away census:** chain away=0 and flat away=0 on every attributable mover.
* **Exit codes:** the only exit-code difference is x02_forstep_el, 139 -> 0.

**Downstream on the cases** (drivers/dscases.py, both binaries, 84 case dirs, evidence/downstream_cases.txt):

* 72 IDENTICAL -> IDENTICAL and none leaving IDENTICAL.
* F/f01, f02, f03 and f05: STATUS_DIFF -> IDENTICAL. The slang lane crashed in the plugin on the missing for-init Lhs.
* V/v05: STATUS_DIFF -> DIVERGENT. The slang lane no longer crashes. The remaining divergence is the abstained
  package-qualified loop `pv::gs.a`, where golden writes an int_var and ours still writes no Lhs (residue 3).
  V/v06, which is v05 without that loop, reads STATUS_DIFF -> IDENTICAL. v06 ran outside evidence/grid.txt: P and L in
  both views, uhdm-cmp stage 1 on both, with the head moved from line 7 to line 9's two-initializer loop.
* The remaining verdicts are unchanged: 4 EQUIVALENT, 2 DIVERGENT and 1 STATUS_DIFF (F/f04, `this.k`).

## 8. Process

* Law binaries withdrawn before the final one. Each gate sweep was rerun from scratch on the final binary.
  * dev9: the `::` law fired on operands and single select levels. Earlgrey went 139 -> 153 on a row run.
  * dev13: frozen first, then superseded when § forInitSelectLhsBase254 was added.
  * dev15: § procReplCountOwner254 named the definition in an elaborated listing. The probe sweep's
    `r10earl_repro/wd` went fullname(1) -> (2).
  * dev16: § genCaPsBoundOpChain254 fired inside member paths. The corpus flat away census read 87 records on
    Earlgrey.
  * dev17: the fresh case V/v05 showed golden's variable object on a package-qualified for-init base.
* Process slips:
  * Two of my own shell commands meant to stop my earlier gate runs matched their own command line in a kill loop and
    ended the invoking shell (exit 144). They signalled only processes of this pass: each candidate's command line was
    checked for `r11u254_` and a binary or harness path first.
  * One `find` in the decode of item 3 ran with an empty directory variable, and so listed the main checkout. Its path
    list was filtered by `$FENCED` before `grep` opened any file. Nothing fenced was read.
  * The first binary-path audit draft used an unfiltered `find | xargs grep` over the sweep trees. It was stopped before
    it ran, and rewritten to filter the path list by `$FENCED` first (evidence/binary_audit.txt).
* Nothing fenced was dispatched, read or opened outside the gate sweeps. byteverify and dbmovers read fence-filtered
  path lists, and every driver here reads `$FENCED` fail-closed.

## 9. Files

* cases/F, G, H, I, Q, R, V: the grids. Each case's first line names its law.
* decode/P: the `::` naming decode of § pkgSelIdxRefColons254.
* drivers/: grid.sh, case.sh, gridcensus.py, predict2.py, tracecensus.sh, awaychain.py with awayrows.py, flatlost.py,
  dbmovers.sh, bvmirror.sh, det.sh, dscases.py, controls.sh and cc_x.sh with strictcmp_x.cpp. Most are copied from
  r11u255repro and r11u252repro.
* evidence/: every number above.
