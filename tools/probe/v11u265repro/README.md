# v11u265: adversarial verification of r11u265 (pass 265, the module/type ground)

Base e00d883a (pass 263). Implementer's patch: /tmp/r11u265.patch (transport only, not kept here). This pass
verifies the three laws in `src/UhdmExporter.cpp` behind `src/R265.h`:
- § cloneMembEnumAtHomeListing265 (`R11U265_MEMBENUMLOC_OFF`)
- § cloneSharedAggOwnCopy265 (`R11U265_SHAREDAGGCOPY_OFF`)
- § cloneBitSelMemberBind265 (`R11U265_COPYBITSELMEMB_OFF`)

`R11U265_OFF` drops all three.

VERDICT: CONFIRMED, NO PRODUCTION FIX. Every headline number of the implementer reproduces bit for bit. The 39 fresh
case dirs (78 case-views) find no pristine-right to patched-wrong case:
- no case-view leaves STRICT_EQUAL;
- no exit code changes;
- no away-moved record;
- no downstream verdict changes.

The delivered surface is the implementer's patch plus this directory and the regenerated `tests/LAWS.md`.

## Binaries (frozen before any measurement)

| binary | md5 | path |
|---|---|---|
| pristine (e00d883a) | 29cc18a20502e4ae9e4c5c89e7e7cad1 (= the brief's pin and the implementer's) | /tmp/v11u265_bin/pristine |
| law (e00d883a + r11u265.patch) | cf13ae7d2744346dcb1622edc2364ca1 (= the implementer's) | /tmp/v11u265_bin/law |

- Both report slang 12.0.0+545f88b2e and UHDM 1.87.
- The patch applies clean on a fresh e00d883a. Its only warnings are the trailing CR of the CRLF case e11's lines.
- The two worktrees' `uhdm-strictcmp` builds are byte-identical (fa6e4f42).

## Targeted rows (fresh law-sweep csv rows, evidence/target_rows.txt)

    pristine: MiniAmiq,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)      (and testflags, SeqDriver d/t the same)
    law:      MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
              MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
              SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
              SeqDriver,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)

No row converts. uhdm-strictcmp on the sweep databases (evidence/corpus_heads.txt) reproduces the implementer's
records.

**Before (pristine).**
- MiniAmiq d/t: #126482 / #126534 / #127274 file (enum_typespec `uvm_pkg::uvm_status_e`, golden uvm_reg_block.svh
  1774:45-57, ours uvm_vreg_field.svh 462:31-43) and #127418 type (golden `typespec_member byte_en` uvm_pkg.sv
  303:21-28, ours the index `ref_obj z` of `rw_access.byte_en[z]`).
- SeqDriver default: #126440 / #126492 / #127232 / #127376.
- SeqDriver testflags: #126452 / #126504 / #127244 / #127388.

**After (law).** All twelve records are cleared.
- The new first record is #134648 (MiniAmiq d/t), #134606 (SeqDriver default) and #134618 (SeqDriver testflags).
- Each is `depth`: golden `5 string_var error_str <pkg>::uvm_component::new::error_str` uvm_component.svh 1729:10-19
  against our `4 assignment` 1730:12-15.
- Object counts are unchanged: 435559 vs 435060, 475526 vs 475095, 475538 vs 475107.

**uhdm-cmp** reads 0 lines (rc 0) on all four law databases.

**Away census** (evidence/away_corpus.txt):

| row-mode | record census (awaycorp.sh) | chain-keyed census (awaychain.py) |
|---|---|---|
| MiniAmiq d/t | dist 134 -> 110, lost 0, gained 24 | away 0, toward 201 (flat 0 / 168) |
| SeqDriver d/t | dist 97 -> 81, lost 0, gained 16 | away 0, toward 134 (flat 0 / 112) |

**Each switch alone on MiniAmiq default** (evidence/miniamiq_switches.txt):
- `R11U265_OFF` gives pristine's bytes (0fd41b95c7a3, the pristine sweep's hash), `differ:file(4)`.
- `R11U265_MEMBENUMLOC_OFF` and `R11U265_SHAREDAGGCOPY_OFF` give the same bytes (1a3898b7ea26), `differ:file(9)`. On
  this row the enum law fires only inside the copy law's private structs, and the copy law makes them only when an
  enum member would move.
- `R11U265_COPYBITSELMEMB_OFF` gives `differ:type(1)`, the bit-select record alone.

## Gates (from /tmp/wt_v11u265 and /tmp/wt_v11u265pris, SLANG_UHDM exported, workdirs /tmp/v11u265_sw{P,L})

1. **Builds**: as above.
2. **Probe.** Both sweeps read `EQUAL=3566 STRICT_NOTEQUAL=521`, regressions=0 conversions=0 changes=0, and the probe
   csvs are identical. A second pristine probe run from the law worktree (/tmp/v11u265_swQ, the same source paths)
   against the law sweep shows 0 of 4087 databases moving. A cross-worktree compare moves all 4087, only through the
   embedded source path.
3. **Corpora.**
   - surelog: regressions=0 conversions=0 changes=4, exactly the four targeted rows above.
   - uhdm2rtlil: regressions=0 conversions=0 changes=0.
   - The normalized pristine vs law csv diff holds only those four rows. The LowMem detail text differs only by the
     workdir path.
4. **Downstream.** Both sweeps read `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)` with identical csvs, and
   0 of 805 slang-lane databases move.
5. **uhdm-cmp** reads 0 lines on the four movers.
6. **byteverify** (fence-filtered hard-link mirrors via drivers/bvmirror.sh, 8 fenced databases skipped,
   evidence/byteverify_corpus.txt):
   - `MOVERS: 4 / 2560`, PATH_SETS_IDENTICAL, SELFCHECK 2559 / 2560 flagged.
   - The four movers are MiniAmiq d/t and SeqDriver d/t, with the implementer's hashes to the last digit.
   - **The firing census**, run with the law binary under R11U265_TRACE through the harness before the law sweep
     (evidence/predict.txt), is line-for-line identical to the implementer's 4-line prediction. It shows 0 probe and
     0 uhdm2rtlil firings, and it is its own positive control.
7. **Canaries**, against the BASE's results/*.csv (evidence/canaries.txt):
   - surelog `ok=50 changed=2` (the SeqDriver rows); uhdm2rtlil `ok=16 changed=0`.
   - Both ctcan2 checks PASS (EXPECT_UNKNOWN=1 / 6).
   - The main checkout's results/ is at d019d9dd (pass 260, landed after this base). Against it, Earlgrey_0_1 reads
     as changed, so the canaries must be read against e00d883a's csvs.
8. **Binary-path audit.**
   - Each sweep: 3265 of 3315 fence-filtered cmds.txt name its own binary, 0 name the other binary, and the other 50
     carry no slang line.
   - The four per-switch MiniAmiq runs name /tmp/v11u265_bin/law.
9. **Determinism** (evidence/det_law.txt). Three concurrent draws of the law binary on Earlgrey_0_1, MiniAmiq,
   SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes read one hash per row-mode. Every hash equals
   the law sweep's and the implementer's. Scoreboard testflags and Rggen testflags hold no database in either.
10. **Sweep exit codes.** Both sweeps exit 1 on the law-index check alone:
    - The pristine sweep, because the committed index at e00d883a is one landing stale, as pass 256's verifier
      recorded.
    - The law sweep, because this directory's cases predated the regenerated index. The index in the delivered patch
      is current (`law_index.py --check` reads current).

## The implementer's grid, rerun (evidence/gridsum_impl_rerun.txt)

The rerun covers 23 case dirs, both views and 6 configurations (276 lines, every line rc=0).
- The gridsum is identical to the implementer's in every field except the embedded-path md5: 46 case-views, 32
  moving, 18 entering STRICT_EQUAL, none leaving.
- `R11U265_OFF` gives pristine on 46 of 46.

## Byte controls

**The implementer's 18 dirs** (2202 case-views on both binaries, evidence/controls_impl*.txt) reproduce exactly:
- 2 movers, v11u258repro VD/vd01 in both views, `STRICT_NOTEQUAL_fullname` on both binaries with 0 lost.
- None enters or leaves STRICT_EQUAL, and no exit code or uhdm-cmp line count changes.

**Widened by 25 dirs holding importer copies of extern class methods.** The dirs are r11u231, r11u244, r11u183dec,
r11u252, v11u248, r11u248, v11u241, v11u220, v11u252, v11u238, r11u238, v11u247, r11u234dec, r11u258, r11u240,
v11u243, v11u240, r11u243, r11u213verify, r11u220, r11u218dec, v11u244, v11u263, r11u261 and v11u261. They give 3774
case-views (evidence/controls_wide*.txt).
- 2 movers, both entering STRICT_EQUAL: v11u241repro AG/g15 in both views, `STRICT_NOTEQUAL_line ->
  STRICT_EQUAL_687_objects` / `_910_objects`.
- They are moved by `R11U265_MEMBENUMLOC_OFF` alone, with the record away census `dist 12 -> 0` / `21 -> 0` and lost 0
  (evidence/away_controls.txt).
- None leaves, and no exit code or uhdm-cmp line count changes. The 16 rc=3 and 16 rc=4 lines are the same on both
  binaries.

## The attack: 39 fresh case dirs (cases/VE 25, cases/VB 14), both views

Every case names its law in its first line. The runs give 468 grid lines (evidence/grid.txt), every one carrying rc=0.
The first draft of VE/ve13 was illegal SV (rc=3 on both binaries: `export p::*` exports nothing that q never
referenced). It was rewritten with explicit exports before the numbers below.

Totals (evidence/gridsum.txt):
- 78 case-views, 56 moving, 22 entering STRICT_EQUAL, NONE LEAVING.
- `R11U265_OFF` gives pristine on 78 of 78.
- No exit code changes.
- Every mover is moved by its own law's switch: MEMBENUMLOC 28, COPYBITSELMEMB 22, MEMBENUMLOC + SHAREDAGGCOPY 4 (the
  array leg), MEMBENUMLOC + COPYBITSELMEMB 2 (VE/ve22, one face each).
- uhdm-cmp line counts change only on 6 default views that uhdm-cmp already rejects at the package order on both
  binaries (vb02, vb05, vb06, vb07, vb08, vb10). The printed q package carries the new member binding, 4 to 12 lines.
- **The away census on all 56 movers reads lost 0** (evidence/away_grid.txt).
  - Every case-view with both sides past stage 1 reads `dist -> 0` or `0 -> 0`, except VE/ve04 (`4 -> 2`, `3 -> 1`:
    the nested struct's enum stays).
  - Seven stage-1 views grow the dump distance by 2 to 8 lines with lost 0: ve06, ve07, ve09_el, ve21_el, ve22_el,
    ve24_el and vb02_el. Each added line was traced to the dump's `\_weaklyReferenced` tail, which the judge cannot
    reach, or to the `vpiInstance` lines of the new struct copies. The q copy sections read like golden's (vb02_el:
    the q copy differs from golden only by a pre-existing constant parent).
- **Downstream** on all 39 dirs gives the same verdict on both binaries: 39 IDENTICAL (evidence/downstream_cases.txt).

| case | law | default | elaborated |
|---|---|---|---|
| VE/ve01 struct as a formal of the copy | cloneSharedAggOwnCopy265 (moved by MEMBENUMLOC) | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve02 last writer a function return type | cloneMembEnumAtHomeListing265 | STRICT_EQUAL, same | same |
| VE/ve03 class-property root | cloneSharedAggOwnCopy265 | STRICT_EQUAL, same | same |
| VE/ve04 enum in a nested struct member | cloneMembEnumAtHomeListing265 | line both (dist 4 -> 2) | line both (3 -> 1) |
| VE/ve05 logic [1:0] enum in a packed struct | cloneMembEnumAtHomeListing265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve06 fixed array op_t arr[2] | cloneSharedAggOwnCopy265 | stage 1 both (module struct face) | line -> STRICT_EQUAL |
| VE/ve07 dynamic + associative array | cloneSharedAggOwnCopy265 | stage 1 both (module struct face) | line -> STRICT_EQUAL |
| VE/ve08 function copy, home declares the same | cloneSharedAggOwnCopy265 | stage 1 both, same | same |
| VE/ve09 pattern initializer | cloneSharedAggOwnCopy265 | stage 1 both (constant face) | same |
| VE/ve10 two enum typedefs as members | cloneMembEnumAtHomeListing265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve11 class-scoped struct typedef | cloneSharedAggOwnCopy265 | STRICT_EQUAL, same | same |
| VE/ve12 parameterized class | cloneSharedAggOwnCopy265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve13 module imports the re-exporting q | cloneSharedAggOwnCopy265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve14 two classes' methods, two importers | cloneSharedAggOwnCopy265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve15 enum member never read | cloneSharedAggOwnCopy265 | STRICT_EQUAL, same | same |
| VE/ve16 member typed by an enum alias | cloneMembEnumAtHomeListing265 | stage 1 both, same | same |
| VE/ve17 unpacked union | cloneMembEnumAtHomeListing265 | stage 1 both (package face) | same |
| VE/ve18 header included into two home packages | cloneMembEnumAtHomeListing265 | line both, same | same |
| VE/ve19 struct + writer in an included header | cloneMembEnumAtHomeListing265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve20 p::st_e qualified member and formal | cloneMembEnumAtHomeListing265 | stage 1 both, same | same |
| VE/ve21 two locals in one copy + property | cloneSharedAggOwnCopy265 | stage 1 both (package order) | same |
| VE/ve22 st_e sts[2] member | cloneMembEnumAtHomeListing265 | stage 1 both (package face) | same |
| VE/ve23 fork-join named-begin local | cloneSharedAggOwnCopy265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VE/ve24 importer chain + interface | cloneMembEnumAtHomeListing265 | stage 1 both (package order) | same |
| VE/ve25 local in a macro body, CRLF | cloneSharedAggOwnCopy265 | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| VB/vb01 class-property root | cloneBitSelMemberBind265 | STRICT_EQUAL, same | same |
| VB/vb02 foreach over the member | cloneBitSelMemberBind265 | stage 1 both (package order) | same |
| VB/vb03 member named like a parameter | cloneBitSelMemberBind265 | type -> STRICT_EQUAL | STRICT_EQUAL both |
| VB/vb04 unpacked-array member | cloneBitSelMemberBind265 | stage 1 both (package face) | same |
| VB/vb05 indexed part select + constant select | cloneBitSelMemberBind265 | stage 1 both (package order) | same |
| VB/vb06 q declares its own op_t | cloneBitSelMemberBind265 | stage 1 both (package order) | same |
| VB/vb07 two structs, same member name | cloneBitSelMemberBind265 | stage 1 both (package order) | same |
| VB/vb08 select inside an operation | cloneBitSelMemberBind265 | stage 1 both (package order) | same |
| VB/vb09 ref and output formal roots | cloneBitSelMemberBind265 | type -> STRICT_EQUAL | STRICT_EQUAL both |
| VB/vb10 packed struct member | cloneBitSelMemberBind265 | stage 1 both (package order) | same |
| VB/vb11 struct from a third package | cloneBitSelMemberBind265 | stage 1 both, same | same |
| VB/vb12 package free function | cloneBitSelMemberBind265 | stage 1 both (constant face), moves toward golden | same |
| VB/vb13 two-dimensional member | cloneBitSelMemberBind265 | stage 1 both (package face) | same |
| VB/vb14 array-element root | cloneBitSelMemberBind265 | stage 1 both, same | same |

**Findings** (none is visible to any gate, and none is a break):
1. **The bit-select law also fires in a package free function** (VB/vb12: an automatic function of p writing
   `r.byte_en[z]`, with q importing p). The implementer's E/e08 and B/b11 read "no copy drained" or "not reached" for
   the free-function shape. In vb12 the copy's bit select binds the member, golden agrees (+4 dump lines toward
   golden, lost 0), and downstream reads IDENTICAL on both binaries.
2. **The bit-select law binds an element select of an unpacked-array member.** `rw.arr[z]` (VB/vb04) and the enum
   array `rw.sts[1]` (VE/ve22) are bit_selects to the law. It binds the member, as golden does (lost 0, gained 8 and
   24).
3. **The enum law relies on pass 241's listing relocation.** Where that relocation is still wrong, the law's copy
   carries the same wrong span. The case is one header included into two home packages (VE/ve18): golden places the
   enum at the writer defs.svh 13:15, ours at the typedef 2:1 in every reference, on pristine too. This is a
   pre-existing residue of § cloneAggTsAtHomeListing241, not of this pass.

## Residues (ranked)

1. **The new head of all four row-modes is on the sister ground.** It is StmtEmit `emitCtorBody27`, the `EK_BID` branch:
   the importer copy of `uvm_component::new`'s Rhs-less declaration assignments. Golden gives each its own copied
   Lhs variable; ours points at the block's variable. The implementer's scratch decode stands as reported. It was not
   rebuilt here (StmtEmit is the live sister's file).
2. **#136655, behind it on the implementer's scratch binary**: a `type_id` type-parameter T golden binds to the
   last `uvm_component_utils` expansion's class_typespec. This is likely this ground (the first-writer /
   type-parameter rebind family), not attempted, and not re-measured here.
3. **Design-level package order (uhdm-cmp stage 1 on both binaries in 15 fresh dirs).** Golden lists the home and
   importer packages in a different order from ours: `design > package(p)` against `package(q)`, and the twins q/p
   and r/p.
   - The dirs: vb02, vb05, vb06, vb07, vb08, vb10, vb11, ve08, ve20, ve21, ve24.
   - In vb04, vb13, ve17 and ve22 golden lists one package more or fewer.
   - The implementer's E/e12 is the same face.
   - It is the dominant stage-1 face of copy cases with bit selects. The writer is UhdmExporter's package listing,
     this ground; not decoded.
4. **Shapes the laws do not reach**, all wrong on pristine too:
   - the enum member one level down (ve04);
   - a member typed by an enum alias (ve16) or by `p::st_e` (ve20);
   - the module-level struct listing in the default view of the array leg (ve06, ve07: `module_inst >
     struct_typespec(p::op_t) > typespec_member(status)` with a null Rhs);
   - the pattern-initializer constant (ve09);
   - the third-package struct (vb11);
   - an array-element root (vb14, where uhdm-cmp reads a logic_typespec against the struct);
   - the implementer's own list: B/b01 alias full names, B/b03, B/b08, E/e02 default, E/e03, B/b06, E/e06, E/e12,
     B/b11.
5. **The sister-ground faces**, unchanged by this pass:
   - Earlgrey default: #233633 / #233638 (ExprEmit § shadowedImportParamFold), #395727 (ExprEmit's enum-constant clone
     at § genCaEnumBindsSelectOnly22's sites), #464077 (stampFoldedPkgParamTs), #600811 / #600816 (the generate-scope
     replication fold), #814099 to #814111 (the § genIpsBoundOwner256 family).
   - Earlgrey testflags: #216212, #235310 / #235315, #403326 (all ExprEmit).
   - BlackBePipeInt #331795 / #331692 (ParamEmit, the import-copy Rhs).
   - Pass 260 has since landed at d019d9dd on the expression ground (§ shadowedImportTsRefOwner260 and two more). The
     Earlgrey records above are its targets and are read at e00d883a here.
6. **Not attempted by the implementer:** the brief's items (2) to (7).

## Process

- The pristine binary was frozen before the law build started. Nothing in src was edited.
- No production fix was made.
- Every tool call through a variable was guarded (`envx.sh` checks SURELOG, UHDM_CMP and UHDM_DUMP with `-x`, and the
  inline dumps with `[ -x "$UHDM_DUMP" ]`).
- $FENCED was read from tools/probe/r11u107repro/canaudit.sh's FENCED= line, never spelled. Every corpus path list
  (cmds.txt audit, byteverify mirrors, probe and downstream md5 lists) was filtered by it before any file was opened.
- The firing census ran through the harness with the fence filter. Only the gate sweeps dispatched the fenced rows.
- No fenced source or database was read, run or decoded.
- No process was signalled, and no other agent's command line was listed.
- **The main checkout moved to d019d9dd (pass 260) during this pass.** Its build/slang-uhdm (md5 5f13d606) is not
  this base's binary. Every measurement used the frozen binaries above, and the canaries the base's csvs.

## Files

- `cases/VE` (25 dirs), `cases/VB` (14 dirs): the fresh cases, each first line naming its law.
- `drivers/`: copied from r11u265repro/drivers.
  - `case.sh` keys on `v11u265repro/cases/`.
  - `controls.sh` runs three in parallel.
  - The rest are unchanged.
- `evidence/`: as cited above.
