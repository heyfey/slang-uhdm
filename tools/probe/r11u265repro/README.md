# r11u265: pass 265, the module/type ground (MiniAmiq / SeqDriver, the last four records)

Base e00d883a (pass 263). The pristine binary has md5 29cc18a20502e4ae9e4c5c89e7e7cad1, identical to the main
tree's build. The law binary has md5 cf13ae7d2744346dcb1622edc2364ca1. Both link slang 12.0.0+545f88b2e and both
were frozen under scratch before any measurement.

The pass adds three laws in `src/UhdmExporter.cpp`, in the importer-copy drain of § cloneAggTsAtHomeListing241 and
§ cloneAggMemberOwn241, behind `src/R265.h`:
- Each law reads its own `R11U265_<LAW>_OFF` switch.
- `R11U265_OFF` drops all three and gives pristine bytes on every grid case-view (46 of 46).
- `R11U265_TRACE=<dir>` logs every firing.

## Verdict per targeted row

NO ROW CONVERTS. On all four row-modes, all four targeted records are cleared. The walk now stops at one record that
belongs to the sister ground.

| row-mode | base (pristine sweep) | law sweep (fresh csv row) | first record after |
|---|---|---|---|
| MiniAmiq default | `differ:file(4)` (#126482 / #126534 / #127274 file, #127418 type) | `MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134648 depth (sister ground, see residue 1) |
| MiniAmiq testflags | `differ:file(4)` (same four) | `MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134648 |
| SeqDriver default | `differ:file(4)` (#126440 / #126492 / #127232, #127376) | `SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134606 |
| SeqDriver testflags | `differ:file(4)` (#126452 / #126504 / #127244, #127388) | `SeqDriver,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)` | #134618 |

Before (evidence/corpus_heads.txt), MiniAmiq default. All four records sit in the svaunit_pkg copy of
`uvm_reg_map::do_bus_write`:

    #126482 / #126534 / #127274 file  A: enum_typespec uvm_pkg::uvm_status_e uvm_reg_block.svh 1774:45-57
                                      B: enum_typespec uvm_pkg::uvm_status_e uvm_vreg_field.svh 462:31-43
        (member `status` of the struct uvm_reg_bus_op held by `accesses[$]` (its element and its element variable)
         and by `rw_access` in foreach_addr)
    #127418 type  A: typespec_member byte_en uvm_pkg.sv 303:21-28
                  B: ref_obj z  (the bit_select `rw_access.byte_en[z]` unbound in the record walk; the dump shows it
                     bound to do_bus_write's own local `bit byte_en` 1842:22)

After:

    #134648 depth  A: 5 string_var error_str  svaunit_pkg::uvm_component::new::error_str  uvm_component.svh 1729:10-19
                   B: 4 assignment            uvm_component.svh 1730:12-15

All four row-modes have the same objects counts before and after: 435559 vs 435060 on MiniAmiq, 475526 vs 475095 on
SeqDriver default, 475538 vs 475107 on SeqDriver testflags. uhdm-cmp reads 0 lines on all four. The away censuses
(evidence/away_corpus.txt) read:

| row-mode | record census (awaycorp.sh) | chain-keyed census (awaychain.py) |
|---|---|---|
| MiniAmiq d/t | dist 134 -> 110, lost 0, gained 24 | away 0, toward 201 (flat 0 / 168) |
| SeqDriver d/t | dist 97 -> 81, lost 0, gained 16 | away 0, toward 134 (flat 0 / 112) |

Each law's share on MiniAmiq default, with the law binary and one switch off (evidence/miniamiq_switches.txt):
- `R11U265_MEMBENUMLOC_OFF` or `R11U265_SHAREDAGGCOPY_OFF` reads file: the three enum records stand, the bit-select
  record is cleared, and the walk reaches three more enum records #127587 / #127965 / #128017.
- `R11U265_COPYBITSELMEMB_OFF` reads type: #127418 alone.
- `R11U265_OFF` gives the pristine four.

## The laws

### § cloneMembEnumAtHomeListing265 (`R11U265_MEMBENUMLOC_OFF`)

UhdmExporter: the lambda `memberEnum265`, called from the § cloneAggMemberOwn241 member copy and from
§ cloneSharedAggOwnCopy265.

- **What golden does.** An importer's copy of a subroutine is Surelog's deep clone of the home's compiled subroutine.
  A member of a struct or union that the clone owns and whose type is an enum typedef of the copy's HOME package
  holds the clone's own enum, located at the home LISTING object's span. That span is the type token of the
  typedef's last formal writer: `output uvm_status_e status` of `uvm_reg_block::read_mem_by_name`,
  uvm_reg_block.svh 1774:45.
- **What ours did.** We shared the home struct member's enum (uvm_vreg_field.svh 462:31), which the home keeps in
  golden too.
- **The rule.** The copied member's ref_typespec takes its own enum_typespec: name, base, consts, alias and instance
  are shared, and the file and span are the listing's.
- **It abstains** when the member's enum already reads that span (E/e04, no formal writer), when the typedef is not
  the home package's (E/e06), and on non-enum members (E/e09's struct member).

### § cloneSharedAggOwnCopy265 (`R11U265_SHAREDAGGCOPY_OFF`)

UhdmExporter: the `_shared` abstention of § cloneAggTsAtHomeListing241, plus an array leg over
§ cloneLocalArrayTsParented241's array_typespecs.

- **The problem.** MiniAmiq's `uvm_reg_bus_op accesses[$]` and `rw_access` locals in the svaunit_pkg copy bind ONE
  struct object together with the home's declarations. § 241's guard leaves such a shared object unedited, so the
  member law above had no copy to work on.
- **The rule.** A reference under a variable the copy declares (its full name lies under the copy's) takes a
  private copy of the struct or union:
  - located at the shared object's own span (golden's struct reads uvm_reg_item.svh 257:9 in the copy as in the home);
  - alias and instance shared;
  - members its own, made as § cloneAggMemberOwn241 makes them, each through § cloneMembEnumAtHomeListing265.
- **The array leg.** A copy's local array's element reference is not reached by § 241's walk, because the
  array_typespec is parented only at the end of the drain. Such an element reference takes the same private copy
  whenever it binds a struct it does not own: shared with the home (MiniAmiq `accesses`), or bound only by the copy
  (grid E/e02_el).
- **Gate.** The law fires only when at least one member's enum would move (a dry run of `memberEnum265`), so a copy
  that would read identically is never made.

### § cloneBitSelMemberBind265 (`R11U265_COPYBITSELMEMB_OFF`)

UhdmExporter: the member-path loop of § cloneAggMemberOwn241's drain.

- **What golden does.** A member path `v.m[i]` in an importer copy whose member element is a bit_select binds the
  struct MEMBER, as the ref_obj member path does. The home body's bit_select stays unbound in golden and in ours.
- **What ours did.** We left the copy's bit_select unbound (VD/vd01). Where the home subroutine declares a variable
  named like the member, we bound it to that variable (MiniAmiq's `bit byte_en`, B/b02).
- **The rule.** The member is chosen in this order:
  - the copy's own member, when the root's struct is the copy's;
  - otherwise the member of the importing package's own re-listing of the typedef (§ cloneMemberImporterListing259's
    rule: the one same-kind, same-named typedef the copy's package lists, which may be the root's struct itself).
- **It abstains** without a unique member. It does not reach part selects (B/b03) or a select on the third path
  element (B/b08).

## Grid (cases/E, cases/B: 23 case dirs, both views, 6 configurations, 276 lines, every line carrying rc=)

evidence/grid.txt and evidence/gridsum.txt:
- Every exit code is 0.
- `R11U265_OFF` gives pristine's bytes on 46 of 46 case-views.
- 32 case-views move, 18 enter STRICT_EQUAL, and none leaves STRICT_EQUAL.
- No uhdm-cmp line count changes.
- Each mover is moved by its own law's switch. SHAREDAGGCOPY moves E/e02 together with MEMBENUMLOC, because its
  copies exist only for the enum law.

| case | law | default view | elaborated view |
|---|---|---|---|
| E/e01 struct local in a nested begin | MEMBENUMLOC | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| E/e02 queue local `op_t acc[$]` | MEMBENUMLOC + SHAREDAGGCOPY | stage 1 both (acc[0].status face) | line -> STRICT_EQUAL |
| E/e03 packed union with an enum member | MEMBENUMLOC | stage 1 both | stage 1 both |
| E/e04 no formal writer | (abstains) | STRICT_EQUAL, same bytes | same |
| E/e05 local in a foreach body (as rw_access) | MEMBENUMLOC | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| E/e06 enum from a third package | (abstains) | stage 1 both, same bytes | same |
| E/e07 two importer packages | MEMBENUMLOC | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| E/e08 package free function | (no copy drained) | STRICT_EQUAL, same bytes | depth both, same bytes |
| E/e09 two enum members and a struct member | MEMBENUMLOC | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| E/e10 last formal writer inside a macro body | MEMBENUMLOC | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| E/e11 typedef + writer in an included CRLF header | MEMBENUMLOC | line -> STRICT_EQUAL | line -> STRICT_EQUAL |
| E/e12 local at the task level | MEMBENUMLOC | stage 1 both (package-order face) | stage 1 both |
| B/b01 VD/vd01 | COPYBITSELMEMB | fullname both (#163 cleared; the alias full names remain) | fullname both |
| B/b02 home local named like the member | COPYBITSELMEMB | type -> STRICT_EQUAL | STRICT_EQUAL both |
| B/b03 part select | (not reached) | stage 1 both, same bytes | same |
| B/b04 bit select read on a right side | COPYBITSELMEMB | type -> STRICT_EQUAL | STRICT_EQUAL both |
| B/b05 formal root | COPYBITSELMEMB | type -> STRICT_EQUAL | STRICT_EQUAL both |
| B/b06 packed union member | COPYBITSELMEMB | stage 1 both | stage 1 both |
| B/b07 no importer | (no copy) | STRICT_EQUAL, same bytes | same |
| B/b08 two-level path | (not reached) | type both, same bytes | depth both |
| B/b09 two importers + an interface importing last | COPYBITSELMEMB | type -> STRICT_EQUAL | STRICT_EQUAL both |
| B/b10 select inside a macro body | COPYBITSELMEMB | type -> STRICT_EQUAL | STRICT_EQUAL both |
| B/b11 package-variable root | (not reached) | stage 1 both, same bytes | same |

The away census on the 32 movers (evidence/away_grid.txt) reads lost 0 everywhere:
- Every case-view with both sides past stage 1 reads `dist -> 0` or `0 -> 0`.
- Five stage-1 case-views move the dump distance with 0 lost dump lines: E/e02 default 25 -> 29, e03 6 -> 8 and
  126 -> 128, e12_el 145 -> 147, B/b06 3 -> 3. Each adds its own struct copy's lines on a case that judge-fails for
  another reason.

Downstream on 22 case dirs (evidence/downstream_cases.txt): 21 IDENTICAL and 1 EQUIVALENT (B/b11, NO_GATES), with the
same verdicts on both binaries. E/e11 is left out because its header is included.

## Byte controls

evidence/controls.txt and controls_summary.txt cover 18 earlier repro dirs, 2202 case-views on both binaries. The
dirs are r11u241, r11u259, v11u259, r11u253, v11u253, v11u258, r11u175uvm, r11u247, r11u263, r11u118, r11v11u118,
r11u119, r11u120, r11v120, r11u124, r11v124, r11u131 and r11v131.
- 2 case-views move: v11u258 VD/vd01 in both views, the decode of #127418, which is B/b01 here. Its strict verdict is
  unchanged (fullname, the alias names) and it loses 0 records.
- None enters or leaves STRICT_EQUAL, and no exit code or uhdm-cmp line count changes.

## Gates (from the worktree, SLANG_UHDM exported, both binaries frozen)

1. Builds: pristine 29cc18a2... (= the main tree), law cf13ae7d....
2. Probe: law sweep `EQUAL=3566 STRICT_NOTEQUAL=521`, regressions=0 conversions=0 changes=0. 0 of 4087 probe
   databases move.
3. Corpora: surelog regressions=0 conversions=0 changes=4. The four changes are the targeted rows
   `differ:file(4) -> differ:depth(1)`, each a first-field change with every old head cleared and the chain-keyed
   away census reading 0 lost. uhdm2rtlil regressions=0 conversions=0 changes=0.
4. Downstream: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`, with a verdict diff of 0 against pristine's
   csv and 0 of 805 slang-lane databases moving.
5. uhdm-cmp reads 0 lines on all four touched row-modes.
6. byteverify over fence-filtered mirrors (evidence/byteverify_corpus.txt): `MOVERS: 4 / 2560`, PATH_SETS_IDENTICAL,
   SELFCHECK 2559 / 2560 flagged.
   - The four movers are exactly MiniAmiq d/t and SeqDriver d/t.
   - They were PREDICTED BY NAME by the firing census frozen before the law sweep (evidence/predict.txt: 4 lines,
     0 probe and 0 uhdm2rtlil firings, the three laws firing on each of the four).
   - The census is its own positive control: the trace fires through the harness on exactly those four.
7. Canaries (evidence/canaries.txt):
   - surelog `ok=50 changed=2` (the SeqDriver rows);
   - uhdm2rtlil `ok=16 changed=0`;
   - both ctcan2 checks PASS.
8. Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary. The other 50 carry no slang
   line.
9. Determinism (evidence/det_law.txt): three concurrent draws of the law binary on Earlgrey_0_1, MiniAmiq, SeqDriver,
   SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes give one hash per row-mode, equal to the sweep's.
10. The pristine sweep reproduces the baseline exactly (exit 0, 0 changes in every stage), and the law sweep exits 0.

## Residues (ranked)

1. **THE NEW HEAD OF ALL FOUR ROW-MODES, SISTER GROUND.**
   - **The records.** MiniAmiq #134648 and SeqDriver #134606 / #134618: the importer copy of the constructor
     `uvm_component::new` (`string error_str; uvm_root top; uvm_coreservice_t cs;`).
   - **What golden does.** Golden's deep clone gives each Rhs-less declaration assignment its OWN Lhs variable copy,
     listed under the assignment.
   - **What ours does.** Ours points the assignment's Lhs at the begin's variable.
   - **The site.** StmtEmit `UhdmExporter::emitCtorBody27`, the `EK_BID` branch. Unlike the subroutine-body site, it
     never registers the Lhs with § importCloneBodyLocalCopies175's `cloneLocalLhs175` (in an importer clone,
     `pkgImportCloneEmit`).
   - **The scratch fix.** A scratch binary (never delivered; StmtEmit restored byte for byte) added that one
     registration. MiniAmiq default then reads `differ:depth(1)` at #136655.
2. **Behind it, #136655 (decoded on the scratch binary only).**
   - **The record.** uvm_pkg's class_defn `uvm_algorithmic_comparator`, its `type_id` class_typespec, type_parameter
     `T`.
   - **What golden does.** Golden binds T's ref_typespec to the class_typespec `svaunit_base`
     (uvm_object_defines.svh 468:35-65): Surelog's shared specialization takes the last `uvm_component_utils`
     expansion.
   - **What ours does.** Our ref_typespec has no actual.
   - **Extent.** Over the whole walk, golden reaches 195 such bindings (svaunit_base 22, svaunit_base_sequence 108,
     uvm_component 11, uvm_object 54) and ours 65 unbound.
   - **Ground and status.** Likely this ground (the type-parameter rebind of UhdmExporter / TypeEmit, the
     first-writer family of pass 257). Not attempted.
3. **Grid shapes the laws do not reach.**
   - B/b01's member-type alias full names: golden `q::c::f::rw_access::p::op_t::data::addr_t`, ours `addr_t`. The
     copy's member type is the source's, one level.
   - B/b03 a part select and B/b08 a two-level path.
   - Stage 1 on both binaries:
     - E/e02 default, `acc[0].status`: a member of an array element, RHS null in ours;
     - E/e03 and B/b06, packed unions;
     - E/e06, a third-package typedef;
     - E/e12, a task-level local of a copied method, where uhdm-cmp reads the package order;
     - B/b11, a package-variable root.
   - E/e08_el reads depth on both binaries.
4. **Not attempted.** The brief's items (2) to (7) (pass 263's, 261's, 259's, 255's and earlier residues, the
   decode's BuildUVMPkg clusters, the seven first-match pointer-keyed loops, the UVM A families).
5. **Sister-ground faces to REPORT, with their call sites.**
   - **Earlgrey_0_1 default:**
     - #233633 / #233638: ExprEmit § shadowedImportParamFold.
     - #395727: ExprEmit's enum-constant clone at § genCaEnumBindsSelectOnly22's sites (r11u263repro decode/E/e01).
     - #464077: ExprEmit stampFoldedPkgParamTs.
     - #600811 / #600816: the generate-scope replication fold.
     - #814099 to #814111: the § genIpsBoundOwner256 family.
   - **Earlgrey_0_1 testflags:** #216212, #235310 / #235315 and #403326, all ExprEmit.
   - **BlackBePipeInt #331795 / #331692:** ParamEmit, the import-copy Rhs.
   - **MiniAmiq / SeqDriver:** the StmtEmit constructor face of residue 1.
   - **Unchanged this pass:** every one of these rows keeps its head.

## Process

- The pristine build was frozen before any edit. One scratch experiment touched `src/StmtEmit.cpp`, the sister's
  file. It built a scratch binary only, the file was restored from a copy at once, and the delivered patch does not
  touch it.
- One dump command ran with `UHDM_DUMP` unset in a fresh shell, so the shell tried to execute a golden case database.
  It stopped at a syntax error on line 2, wrote nothing, and left the main tree clean. Every later tool call was
  guarded (`${UHDM_DUMP:?}`, `[ -x ]`).
- Every corpus path list was filtered by `$FENCED` (read from r11u107repro/canaudit.sh) before any file was opened.
  Nothing fenced was dispatched, read or decoded outside the gate sweeps.
- No process was signalled.

## Files

- `cases/E`, `cases/B`: 23 case dirs, each case's first line naming its law.
- `drivers/`: copied from r11u263repro and retargeted to this pass's switches and trace.
- `evidence/`: as cited above.
