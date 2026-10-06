# r11u256 — pass 256, the expression/parameter ground (ExprEmit, ParamEmit)

Base 5b903eef (pass 254 on top of pass 257). Four laws behind `src/R256.h`. Each law reads its own
`R11U256_<LAW>_OFF` switch, and `R11U256_OFF` drops all of them: pristine bytes on 164 of 164 grid case-views.
`R11U256_TRACE=<dir>` logs every firing as `<law> <detail>`, abstentions included.

## 1. Verdicts on the targeted rows

| row-mode | base (results/golden_surelog.csv) | this pass (fresh law sweep csv) |
|---|---|---|
| Rggen default | STRICT_NOTEQUAL differ:col(129), head #27671 | `Rggen,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` |
| Earlgrey_0_1 default | differ:fullname(117) | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(79),,differ:fullname(79)` |
| Earlgrey_0_1 testflags | differ:fullname(24) | unchanged, `differ:fullname(24)` (the bytes move: 67 records toward golden, 0 lost) |
| BlackBePipeInt d/t | depth(1) #331795 / #331692 | unchanged (item 3 not attempted, section 6) |

**Rggen default.** Every ground-A record is cleared.
* The base head was #27671: `ref_obj bit_field_if`, golden block_0.sv 7:24-33, ours 7:11-23
  (evidence/rggen_default_pristine_records.txt).
* All 129 col and endcol records are that face, written inside a macro body. § macroIfaceRangeSelBaseTok256 clears
  all of them.
* The row now reads `type(1)`, which is a first-field change. Its first record is #92960, the ground-B record:
  golden lists a `range` at block_0.sv 1811:46-47 where ours lists a `ref_typespec`
  (evidence/rggen_default_law_records.txt). This is § genLpUnpackedArray in ModuleEmit, the sister ground.
* Order-blind away census: distance 523 -> 1, lost 0, 522 records toward golden. #92960 is the one record that
  remains (evidence/awaycorp.txt).

**Earlgrey_0_1 default** goes from 117 to 79 objects. The first record is still #136315 (TypeEmit
crossPkgBoundFoldConst9, the sister ground). Cleared:
* #439105 / #439106 (rv_dm.sv 100-101, `datasize: dm::DataCount`, `dataaddr: dm::DataAddr`), by
  § patLitFormFileAtRef256.
* 34 ref_typespec records: flash_phy_rd `gen_buf_match[0..3]` in both flash banks, #472295 to #472530 and
  #479751 to #479986, plus `gen_word_sel` #474020 / #481404. These are cleared by § genIpsBoundOwner256.
* #482965 / #482968 (flash_phy.sv 65, `host_req_i ? host_addr_i[BankAddrW +: BankW] : '0`), by
  § elabBodyIpsBoundSelName256.
* That is 2 + 34 + 2 = 38. Away census: distance 973 -> 935, lost 0, gained 38.

**Earlgrey_0_1 testflags** stays `fullname(24)`, and its first record is still #137760.
* The strict walk diverges at #403326 (`typespec_member unused_ctrl`, depth). That comes before the records these
  laws reach, so the count cannot see them.
* The order-blind census does see them: distance 717 -> 650, lost 0, gained 67.

**Probe changes** (the fresh probe.csv; both cases stay STRICT_NOTEQUAL, the first field unchanged, fewer objects):
* `r10earl_repro/vo` fullname(2) -> fullname(1), by § elabBodyIpsBoundSelName256.
* `v11u115repro/grid/f1/v06_gf_vs_psel` fullname(3) -> fullname(1), by § genIpsBoundOwner256.

## 2. The laws (anchors are the § tokens; switches are environment variables)

1. **§ macroIfaceRangeSelBaseTok256** (`R11U256_MACROIPSBASE_OFF`; ExprEmit, the dotted-interface range-select branch,
   the `ci == 0` base ref beside § lvPathBaseAtFirstMember154).
   * An LVALUE interface / hierarchical path with a trailing (indexed) part select anchors its base ref at the
     first member's token. Outside a macro, that span is computed from text offsets.
   * Inside a macro expansion, the offsets are refused (`sm->isMacroLoc`). The base ref then kept the ACTUAL's span:
     Rggen `RIF.read_data[LSB+:WIDTH]` was 7:11-23, where golden has 7:24-33.
   * The law reads the member token from the path's syntax (`pathNameToks183` over `esLeftSyn183`). This is the
     range-select twin of what § macroIfacePathTokSpans183 already does for the bit-select branch.
   * It applies only when the token count equals the component count and is at least 2. Otherwise it abstains.
2. **§ patLitFormFileAtRef256** (`R11U256_PATLITFILE_OFF`; ParamEmit, emitParameters' struct-pattern member
   literal-form branch, `srlgLitFormSrc`).
   * The member constant is minted by emitExpr at the SOURCE literal: the parameter's own initializer, `4'h2` in
     dm_pkg.sv. It is then re-located at the member setter.
   * setLoc keeps a VpiFile that is already written, so line and columns came from the setter (rv_dm.sv 100:17-30)
     while the FILE stayed dm_pkg.sv.
   * Golden's constant takes all four fields from the setter. The law clears the file before the re-location, and
     only when the two files differ.
   * The writer was found with a temporary backtrace in setLoc (process note, section 8).
3. **§ genIpsBoundOwner256** (`R11U256_GENIPSOWNER_OFF`; ExprEmit, helper `genIpsBoundOwner256`).
   * Scope: the base or width of an indexed part select, folded from a parameter, in an elaborated TOP-LEVEL
     generate scope's continuous assignment (`contAssignView == 0 && inGenScopeCaRhs && !genNestedScopeEmit24`).
   * Golden's reference names the OWNING INSTANCE (`work@top.u`). Ours named the generate scope
     (`work@top.u.gb[0]`) or the member path (`work@top.u.gb[0].rb[i].addr[FW+:PW]`).
   * It applies in a for-generate body at any depth of the right side: whole, an operand of `==`, `&`, `?:` or a
     system call, a concatenation member, a member-path select, an implicit-net or generate-local target, and a
     child instance's generate (`genCaLoopParamFold || genCaChildLoopFold21`).
   * In an if / case scope it applies only when the select IS the whole right side (G g06, Earlgrey `gen_word_sel`).
   * An if / case scope's NESTED select under an operation reads the select's own full name instead
     (`work@top.u.gw.a`, G g07).
   * There are two sites: the stamp's else-branch, through `ipsWidFold9`, and the member-path select's folded width
     (§ elabHierSelWidthFold's `stampFoldedPkgParamTs`).
   * Port connections (`elabConnEmit21`) are excluded.
4. **§ elabBodyIpsBoundSelName256** (`R11U256_BODYIPSSEL_OFF`; the same helper, the elaborated module-body branch,
   `contAssignView == 2`).
   * The same fold in an elaborated instance's module-body continuous assignment, with the select NESTED under an
     operation (a ternary branch, an operand, a concatenation member).
   * Golden's reference reads the select's own full name: `work@top_earlgrey.u_flash_eflash.host_addr_i`, where
     ours had the instance.
   * A whole-right-side select is the shared definition object and never reaches this branch.
   * Processes and subroutines (`inProcessEmit`, `currentTf`) are excluded, and so are hier_path member selects
     (B b07, a residue).

## 3. Grid (cases/, plus r11u257repro decode/HL; drivers/grid.sh, evidence/grid.txt, gridsum.txt)

* **Size.** 82 case dirs (cases B, F, G, M, V, and the nine r11u257 decode/HL dirs) in both views, 164 case-views.
  Seven configurations each: P, L, OFF, and the law with each of the four switches off. That is 1148 lines, every
  line with its exit code.
* **R11U256_OFF** gives pristine bytes on 164 of 164.
* **Verdicts.** 114 case-views move, 80 enter STRICT_EQUAL, and none leave.
* **Attribution.** Every mover is moved back by exactly one switch: MACROIPSBASE 42, GENIPSOWNER 38, BODYIPSSEL 20,
  PATLITFILE 14.
* **No other measure worsens.** No exit code changes, and no uhdm-cmp line count changes. The stage-1 movers
  (B b03, b13; F f03, f06, f08; G g08, g10, g18; M m18; V v02, v03, v04) keep the same line count on both binaries.
* **Away census** (drivers/awaycases.sh, evidence/grid_away.txt): lost=0 on all 114 movers.
* **Grid coverage, by law.** Each case's first line names its law.
  * § macroIfaceRangeSelBaseTok256, cases/M:
    * the path as a macro argument and wholly in the macro body;
    * simple and indexed part selects, up and down;
    * an interface instance, a port, a modport and a cross-module path;
    * parameter bounds (the constant slots), a call as the select base, a concatenation target;
    * an always_ff, a for-generate and an if-generate;
    * nested macros, CRLF copies (m01, m03, m13 `_crlf`), a macro from an include file, instance depth 3;
    * the rvalue and plain-source controls m05 and m11, which do not move;
    * the r11u257 decode/HL h01 to h09, of which h03 and h08 enter STRICT_EQUAL and the others do not move.
  * § patLitFormFileAtRef256, cases/F: another-file package (args `pk.sv dut.sv`), wildcard import, child instance
    and generate, a one-bit member, a same-file control (f05, unmoved), a package-level pattern, a macro, a header
    parameter default and override.
  * § genIpsBoundOwner256, cases/G and V: the shapes listed in section 2, a qualified bound, own parameters,
    LHS selects, a net-decl assign, an always_comb, interface bodies, named-call arguments, a class with `this.`
    paths, extern and pure virtual prototypes, and a child specialization `#(.W(PW))` with a select port actual.
  * § elabBodyIpsBoundSelName256, cases/B and V v07: ternary branches, binary operands, unary and system-call
    operands, depth 3, the top module's own body, own-parameter controls, a member path, qualified bounds, a whole
    right side, nda and always_comb controls, two instances, an interface body, a down select and an LHS select.

## 4. Gates (frozen binaries; evidence/sweeps)

* **Binaries.**
  * Pristine is md5 02900011d91aa5da3d83d64143317a14, byte-identical to the main tree's build.
  * The law binary is md5 bfdcaa5cf6e17d8ea33af50fd3ab6e62. Both report slang 12.0.0+545f88b2e.
  * uhdm-strictcmp is md5 fa6e4f42f252ae0ab69d9845003e71c5.
* **Binary-path audit** (fence-filtered cmds.txt, evidence/binaudit.txt): in each sweep, 3265 of 3315 name the
  swept binary and 0 name another. The other 50 are golden-cache-miss runs with no slang line.
* **Probe** (`tests/sweep.sh --corpus probe`): regressions=0 conversions=0 changes=2, EQUAL 3564 +
  STRICT_NOTEQUAL 523. The pristine sweep equals the committed baseline (3564 / 523, 0 / 0 / 0).
* **Surelog** corpus: regressions=0 conversions=0 changes=2 (Earlgrey_0_1 default -38, Rggen default
  col(129) -> type(1)).
* **uhdm2rtlil** corpus: regressions=0 conversions=0 changes=0 (1606 + 0).
* **Downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0. downstream.csv is byte-identical to the
  pristine sweep's, and 0 of 805 slang-lane databases move (evidence/dbmovers.txt).
* **uhdm-cmp**: 0 lines on the three corpus movers (evidence/cmp_surelog_*.txt).
* **byteverify** (fence-filtered hard-link mirrors, drivers/bvmirror.sh, 2560 of 2568 mirrored; the 8 fenced
  row-modes were left out unread):
  * There are exactly 3 movers: Earlgrey_0_1 d/t and Rggen d (evidence/byteverify.txt).
  * SELFCHECK reads 2559 of 2560. That is pass 201's self-check artifact: the one fixed file the comparator corrupts
    against is compared with itself and cannot be flagged. It is not a movers line.
* **Firing census and prediction.** The census ran with the law binary under R11U256_TRACE over the probe and both
  corpora, filtered by $FENCED (drivers/tracecensus.sh, drivers/predict2.py). It was frozen as evidence/predict.txt
  before the law sweep.
  * It predicts five databases: Earlgrey_0_1 d/t, Rggen d, probe `r10earl_repro/vo` and
    `v11u115repro/grid/f1/v06_gf_vs_psel`.
  * All five moved, and nothing else moved.
  * The census fires nothing in the uhdm2rtlil corpus.
* **Away census on the corpus movers** (chain-free order-blind multiset, drivers/awaycorp.sh,
  evidence/awaycorp.txt): Earlgrey d 973 -> 935, Earlgrey t 717 -> 650, Rggen d 523 -> 1. Lost 0 on all three.
* **Canaries** (tools/probe/r11u107repro):
  * surelog ok=51 changed=1, the targeted Earlgrey default;
  * uhdm2rtlil ok=16 changed=0;
  * ctcan2 surelog PASS (ok=58);
  * ctcan2 uhdm2rtlil PASS (ok=2).
* **Determinism** (drivers/det.sh, three concurrent draws of the law binary on Earlgrey_0_1 and the five UVM rows,
  both modes; evidence/det_law.txt): one hash per row-mode on 11 of 11. Scoreboard testflags is SLANG_REJECT at the
  base. The Earlgrey hashes equal the law sweep's (9090c6a0bad8 / b15a828ca58e), so that row has four draws.

## 5. Ground-B faces reported with their call sites (not written)

* **Earlgrey #136315 / #137760**: TypeEmit crossPkgBoundFoldConst9 under § crossPkgFoldTsNameOnChain152. This is
  the first record in both modes and is unchanged.
* **Earlgrey #214684 / #214686 / #214818 / #214824, and t #216343 to #216483**: the definition-view var_select and
  part_select full names. TypeEmit emitSyntaxExpr § defGenPathSel161.
* **Earlgrey #233633 / #233638, and t #235310 / #235315**: the rstmgr ref_typespec full names
  (`work@rstmgr_ctrl.rst_req_i` against golden's `work@rstmgr_ctrl`). ModuleEmit, as earlier passes reported.
* **The ModuleEmit instance prefix missing a generate scope**:
  * #375033 to #375643 (`...if_stage_i.prefetch_buffer_i...`, no `gen_prefetch_buffer`);
  * #392938 to #393091 (`gen_multdiv_single_cycle`);
  * #474036 to #474087 and #481420 to #481471 (`gen_flash_banks[0]`);
  * #596152 / #596173 (`gen_arb_ppc`).
* **New decode: Earlgrey #620047 to #620111**, 9 records: `ref_obj N`, golden `work@tlul_socket_1n.N`, ours
  `work@top_earlgrey.u_spi_device.u_reg.u_socket.N` (tlul_socket_1n.sv 201-211, `assign tl_u_o[N].a_valid = ...`).
  * Golden's instance listing holds the DEFINITION's cont_assign object (shared, printed once by uhdm-dump), so the
    index reference keeps the definition name. Ours re-emits a fresh instance cont_assign.
  * Reduced to
    `typedef struct packed {logic a_valid; logic [3:0] a_opcode;} tl_t; module sock #(parameter int unsigned N = 4)
    (input tl_t tl_t_o, output tl_t tl_u_o [8]); assign tl_u_o[N].a_valid = tl_t_o.a_valid; ... endmodule`.
    Instantiating it twice gives golden `work@sock.N` in both instances. The same holds with a constant index
    `tl_u_o[2].a_valid`.
  * The call site is ModuleEmit's elaborated cont-assign writer. Its `dottedLhs` net-base test walks only
    MemberAccess down to a NamedValue, so a member of an ELEMENT SELECT of an array_net (`tl_u_o[N]`) is never
    recognized as net-backed. The def cont_assign is therefore not shared, as golden shares it.
  * The walk divergence that follows at #658559 (tlul_err_resp's cont_assigns: golden's first listed is line 40,
    ours line 38) is plausibly the same sharing: golden's line 38 is a shared object the walk's memo skips.
* **Earlgrey #395727**: `enum_const WB_INSTR_OTHER` without a file. Not attempted (the enum listing, TypeEmit).
* **Rggen #92960**: § genLpUnpackedArray, ModuleEmit (section 1).
* **MiniAmiq / SeqDriver #95125 / #95083 / #95095**: UhdmExporter § cloneAggMemberOwn241's drain. Unchanged.

## 6. Residues, ranked

1. **Earlgrey default, ground-A records left** (all wrong on pristine too):
   * **#464077.** The width of `rdata_sram[0+:Width]` is folded from an OVERRIDDEN header parameter inside an
     if-generate, as the whole right side. Golden has `work@top_earlgrey.u_ram1p_ram_main`, ours the instantiating
     scope `work@top_earlgrey`.
     * Reproduced as cases/G/g23_if_own_param: golden `work@top.u`, ours `work@top`. The non-overridden twin is
       STRICT_EQUAL.
     * gdb puts the writer in emitExpr, called from emitGenScopes, on the module-parameter fold path rather than the
       imported-parameter stamp this pass writes. It is not located further.
   * **#600811 / #600816.** `assign a_wmask_d = {TotalWidth{1'b1}}` in the if-generate `gen_secded`. Golden's folded
     replication constant is UNPARENTED, so its ref_typespec has no name. Ours parents it at the cont_assign, which
     gives it the scope's name.
     * The same holds for an imported count and in a for-generate, from a reduction with `b = {TotalWidth{1'b1}}`
       and `d = {PW{1'b1}}`.
     * ExprEmit's sized-element replication fold returns the constant unparented, so the parent comes from the
       gen-scope CA caller. That caller is not located.
     * The concatenation and unary twins (`{1'b0, {PW{1'b1}}}`, `~{PW{1'b0}}`) are stage 1: golden folds them whole.
   * **#474416 / #474419 / #481719 / #481722.** The port-connection part select `.addr_i(muxed_addr[BankAddrW-1:
     LsbAddrBit])`. Golden names it through the port (`...i_flash.addr_i.muxed_addr`), ours through the instantiating
     scope. Not attempted.
2. **Earlgrey testflags #216212** (item (1)(d)): the `--elabuhdm` definition listing's `::` form.
   * Decoded: the elaborated listing of an `--elabuhdm` run is the UHDM ElaboratorListener clone of OUR definition
     object, so a rename in the definition listing is copied into the clone. Golden's clone keeps the dotted name.
   * A definition-listing-only rename needs a hook after elaboration that restores the clone's name. That hook
     belongs in the elaboration driver (UhdmExporter / uhdm_main, the sister files). Stopped at the decode.
3. **The grid's own residues** (wrong on pristine too, unmoved or moved toward golden):
   * G g12 and g19: a for-generate select bounded by the module's OWN localparam or header parameter (g12) or
     inside an always_comb (g19). Golden has the owner, ours the scope; these take other fold paths.
   * G g18_el: the definition-listing reference names of `a[FW+PW -: PW]`. Golden has `work@m.gb.a.FW`, ours
     `work@m.gb.FW`.
   * B b07: a member-path select nested in a module-body operation. Golden has `work@top.u.r.addr[2+:3].addr`.
   * F f02: an unqualified, wildcard-imported pattern member. Our constant sits at the package literal (pk.sv
     3:38), golden's at the setter.
   * M m07: the width reference inside a macro select. Golden has `work@m.bi.read_data[L * 2+:W].W`, ours
     `work@m.W`.
   * M m08, m20 and V v06: in generate scopes, the macro-argument constants and the select's end line are located
     at the macro use site. Golden uses the expanded text's coordinates.
   * The stage-1 cells listed in section 3.
4. **BlackBePipeInt d/t #331795 / #331692** (item 3): not attempted. Also not attempted: pass 252's member-read
   `U = D` listing and pass 250's A/a02.
5. **Not attempted**: brief items (4) to (7), and the r11u230map / r11u234dec clusters.
   * Pass 254's for-init, shell-call, replication-owner and generate part-select residues stand as written.
   * So do the older residues from pass 252 back to pass 238, N0033 / N0025 and N0008.

## 7. Byte controls and downstream on the cases

**Byte controls** (drivers/controls.sh, evidence/controls.txt). These ran on pristine and law over 20 earlier repro
dirs: r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11u131repro, r11u147repro, r11u169repro,
r11u183dec, r11u187repro, r11u192repro, r11u198repro, v11u198repro, r11u236repro, r11u250repro, r11u252repro,
v11u252repro, r11u254repro, v11u254repro, r11u257repro and v11u257repro. That is 1616 case dirs and 3232
case-views, and every line carries its exit code.

* **Moving: 6.**
  * r11u257 decode/HL h03_lhs_macro and h08_lhs_macro_always, both views: col -> STRICT_EQUAL
    (§ macroIfaceRangeSelBaseTok256, the Rggen reductions).
  * v11u252 VF/vf07_const_slots, both views: stage 1 on both binaries, uhdm-cmp 60 lines on both. Moved by
    § elabBodyIpsBoundSelName256 alone; every other switch keeps the law's bytes.
    * The one changed object is the width constant of `i[0 +: X]` under `|` in the top module's body. Its
      ref_typespec goes from `work@top` to `work@top.i`, which is golden's name.
    * Away census: lost 0.
* **Nothing else.** None leave STRICT_EQUAL, and no exit code differs.

**Downstream on the cases** (drivers/dscases.py, which now reads a case's `args` file, both binaries, 82 case dirs,
evidence/ds_cases.txt): 80 IDENTICAL -> IDENTICAL and 2 EQUIVALENT -> EQUIVALENT. No verdict changes.

## 8. Process

* **Order of work.** The pristine binary was frozen before any edit (`/tmp/r11u256_bin/pristine`). Development
  binaries dev1 to dev5 were frozen per law. The final law binary is byte-identical to dev5: the last source change,
  removing an unused `#include "R256.h"` from StmtEmit, leaves the bytes the same.
* **No law binary was withdrawn.**
* **The temporary setLoc backtrace.** To find § patLitFormFileAtRef256's writer, a temporary backtrace print was
  added to `UhdmExporter::setLoc`, a sister file.
  * It was built as a separate scratch binary and run on the reduction and once on Earlgrey_0_1. That run was not
    a gate run, and Earlgrey is not fenced.
  * The file was restored byte-for-byte from a copy taken before the edit. UhdmExporter.cpp is not in the patch.
  * The same scratch binary listed every re-located object whose file differs: Earlgrey has 12. Two are the
    constants this law fixes. Ten are `type=2251` objects in top_earlgrey.sv, whose records already agree with
    golden; they were left alone.
* **Fence.** Nothing fenced was dispatched, read or opened outside the gate sweeps.
  * The census ran with `--filter` built from $FENCED.
  * byteverify and dbmovers read fence-filtered path lists.
  * The copied sweep csvs have their fenced rows removed (surelog 1597 -> 1589 lines). Rows naming a fenced test
    only as a substring of another test's name were dropped too (downstream 872 -> 871, uhdm2rtlil 1743 -> 1741),
    so a substring fence check over the patch reads 0 outside the tests/LAWS.md context line.
  * Every driver reads $FENCED fail-closed.
  * No process was signalled, and no other agent's command line was listed.
* **Running slang-uhdm in the corpus tree.** The one Earlgrey run outside the harness used the corpus scr file from
  its own directory, with `-o` under this pass's scratch. `git status` of the Surelog submodule was clean afterwards.

## 9. Files

* `cases/B` (§ elabBodyIpsBoundSelName256), `cases/F` (§ patLitFormFileAtRef256), `cases/G`
  (§ genIpsBoundOwner256), `cases/M` (§ macroIfaceRangeSelBaseTok256), `cases/V` (the fresh shapes, each naming its
  law).
* `drivers/`: case.sh, env.sh, grid.sh, gridsum.py, controls.sh, det.sh, away.py, awaycorp.sh, awaycases.sh,
  awaychain.py, bvmirror.sh, dscases.py, heads.sh, tracecensus.sh, predict2.py and dbmovers.sh. Most are copied from
  r11u254repro.
* `evidence/`: grid.txt, gridsum.txt, grid_away.txt, controls.txt, predict.txt (frozen before the law sweep),
  byteverify.txt, dbmovers.txt, awaycorp.txt, binaudit.txt, det_law.txt, ds_cases.txt, cmp_surelog_*.txt, the
  Earlgrey and Rggen record lists, and sweeps/ (fence-filtered csvs and summaries of both sweeps).
