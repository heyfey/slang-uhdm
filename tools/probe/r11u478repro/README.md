# r11u478: per-package alias formal copies, clone array-element members, alias-copy parameter names and provider body copies

Pass 478 on the module/type ground (TaskFuncEmit, UhdmExporter). It is the thirty-ninth pass of the
sv-tests campaign on this ground. Base b20e61b5c. This is the implementer's report.

## Verdict on the target row

| row | base (master's control /tmp/intr11u476, results/golden_svtests.csv) | law binary (law10) |
|---|---|---|
| generated/uvm-examples/uvm_param_vif_config_db.sv | STRICT_NOTEQUAL differ:fullname(3) | **EQUAL**: uhdm-cmp 0 lines, STRICT_EQUAL 1002258 objects |

The fresh row from this pass's sweep is in "Gates" below. The three DIFFERENT rows p733, p737 and
tnoc are known exceptions (the user's decision of 2026-11-02) and were not targeted. After this
pass no both-accepted row of the sv-tests corpus is open apart from those three.

How the row closed, measured on the kept pair after each step (evidence/row_steps.txt; driver
drivers/row_run.sh, against the cached golden of 1002258 objects):

| binary | strict verdict | objects | what moved |
|---|---|---|---|
| pristine | fullname at #93329, #165115; walk diverges #201344 | 1002253 | the base |
| law2 | fullname(666), walk diverges later | 1002275 | face (d) and the line 2034 face gone. The 664 UVM_ALL_ON objects behind them, already wrong on pristine, are now reached (head later in the walk) |
| law6 | depth | 1002275 | the 664 parameter names fixed |
| law8 | depth (uvm_component::new `cs`) | 1002267 | 3518 provider references rebound |
| law9 / law10 | **STRICT_EQUAL** | 1002258 | the last provider references (a declaration re-parented at its declaration assignment) |

law10 is law9 with the verifier-style refinement of § aliasFormalCopyPerClone478 described below.
That refinement does not touch the row.

## The laws

Every law is read through src/LawSwitch.h with `lawOn(478, ...)`:
- `R11U478_OFF` drops all of them.
- `R11U478_TRACE=<dir>` logs each firing with `lawTrace(478, ...)`.

No src/R*.h, no LawState.h section, no getenv and no header change. The bookkeeping is in side maps:
- a function-local static map of (shared listing clone, importing package);
- a local vector copy of the clone list;
- a local provider map.

None of them is iterated in a way that reaches the database order.

1. **§ aliasFormalCopyPerClone478** (TaskFuncEmit, at the formal's typespec of an importer clone;
   `R11U478_ALIASCOPY_OFF`). This is face (d), the enum alias typespec of set_arbitration's `val`.
   - Surelog's compileTfPortList compiles a formal's type per subroutine. So a clone's
     alias-of-alias enum formal (`typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE;`) carries a bare
     copy. That copy has its own typedef-alias ref, named by its parent chain:
     `sfr_agent_pkg::...::set_arbitration::val::UVM_SEQ_ARB_TYPE`, `tb_params_pkg::...` and
     `sfr_test_pkg::...` in golden.
   - The memo of § importCopyAggFormalOwnCopy32 is keyed by the shared listing clone. It handed
     every importer ONE copy, which § cloneAliasFormalOwnChain214 re-parented to the last
     io_decl. So every name read sfr_test_pkg.
   - The law keeps one copy per (shared listing clone, IMPORTING PACKAGE object). Within one
     importer the formals of two subroutines still share it, and its span is the last writer's
     type token. That is golden r11u231 AL/a04: q's `pf(v)` and `set_arbitration(val)` both sit at
     11:39.
   - THE IMPLEMENTER'S OWN BREAK, found in the away census and fixed before the sweep: the first
     version (law9) gave every io_decl its own copy. AL/a04 went STRICT_EQUAL -> STRICT_NOTEQUAL
     line, and law10 restores it.
   - Cases AF (af01 to af10). Controls: af04, a direct enum typedef, where the law does not fire.
     af10, one importer, where the law moves bytes only, as two package views now hold two copies
     the way golden's counts read.
2. **§ cloneHierArrElemMember478** (UhdmExporter, design-final in final287; `R11U478_ARRMEMBER_OFF`).
   This is the uvm_reg_map.svh line 2034 face, `p.push_back(accesses[i0].data[i1*8+:8])`.
   - An import clone's dotted path is built by UHDM's hier_path::DeepClone (clone_tree.cpp). When
     the element before is bound to an array_var or packed_array_var whose element typespec is a
     struct or union, DeepClone binds the next element to the member of that name. This is the
     array_var case of its first switch.
   - The member is the one reached from the CLONE's array variable:
     - for a direct importer, the home's listing member;
     - for tb_params_pkg, which reaches uvm_pkg only through sfr_agent_pkg, sfr_agent_pkg's own
       struct copy, `sfr_agent_pkg::uvm_reg_map::do_bus_access::accesses::uvm_pkg::uvm_reg_bus_op::data`.
   - In each import clone the law binds an unbound ref_obj-kind element after the first in the
     same way. An element after a bound member is not resolved further.
   - ABSTAINS when the element struct typedef is declared in a CLASS. Golden leaves it unbound:
     AM/am03 to am06, and uvm_default_factory's `type_alias_inst[0].orig.m_type`. This was read
     from cases (g-grid) and not stepped through in Surelog. Without the abstention, law1 bound 4
     `orig` elements that golden leaves null, and uhdm-cmp read 18 lines.
   - It runs in final287 because § cloneAggLocalOwnCopy241 (finish241) gives the clone's local
     array its own struct copy, which golden's provider binding reaches. At law2's earlier
     placement the member came from the listing, and the strict fullname read work@hvl_top....
   - Cases AM: am01, am02, am09 to am13 bind. Controls: am03 to am06 (class typedefs), am14 (the
     home, no clone), am07 and am08 (anonymous struct and packed union; golden binds, see
     residues).
3. **§ aliasCopyParamUnnamed478** (UhdmExporter, the last step of final287;
   `R11U478_ALIASPARNAME_OFF`). This is the next level of § cloneValFormalUnnamed474.
   - A class_typespec owned by a ref_typespec is UHDM's clone of the written specialization: the
     typedef-alias target that the copies of `this_t` carry, `<class>::type_id::T::this_t::SFR_agent_t`.
     Its param_assign value formal is named by its own chain in golden. Ours kept the generic
     class's stored `sfr_agent_pkg::sfr_agent::UVM_ALL_ON`.
   - A `parameter` Lhs parented by its own param_assign (or by the copy) whose stored name does not
     end with `<copy name>.<name>` or `<copy name>::<name>` drops the stored name, and so does its
     typespec reference.
   - It runs after § tdSpecArgTypedefShares470's deferred deep copies, which make these copies.
   - 332 firings on the row.
   - Cases AP: ap01 to ap05. ap03 goes to STRICT_EQUAL. ap02 and ap04 go fullname -> depth at the
     walk divergence pristine already had. ap05 is a control.
4. **§ providerBodyCopyBind478** (UhdmExporter, design-final after reHomeLateDrain476;
   `R11U478_PROVCOPYBIND_OFF`). This is r11u476's CC/cc13 face and the row's last depth face.
   - § cloneViaProviderTopClone476 binds a reference in a package that reaches the home through a
     provider M to M's top-view clone's body local, read when that clone was emitted.
   - Later two things happen:
     - M's wrapper begin takes its own copies of its locals (StmtEmit's § importCloneBodyLocalCopies175,
       drained in drainPaNameCopySrc38);
     - M's subroutine listing takes an unbound twin (§ cloneTfOwnVarListingIsUnbound195).
   - So the bound object is listed nowhere, and the walk meets it as a new object. Golden binds M's
     BEGIN entry: cc13's t::f `p` -> a::f's begin `p`.
   - In each provider-paired clone (the pairing is snapshotted before the late drain clears it), a
     reference whose actual is a variable of the provider clone binds the one entry of the same kind,
     name and declaration site. This applies when that variable's parent list and the provider's
     wrapper begin list no longer hold it but one of them holds such an entry. The second list
     covers `uvm_coreservice_t cs;`, re-parented at a declaration assignment.
   - 3962 firings on the row.
   - Cases PB: pb01 and pb02 go to STRICT_EQUAL. pb03, pb04 and pb06 to pb08 stay STRICT_EQUAL and
     move bytes only. pb05 (no provider) is a control.

The switch table is in evidence/grid_switch_table.txt and evidence/grid_switches_md5.txt:
- On every one of the 37 grid dirs, `R11U478_OFF` gives pristine's bytes and exit code.
- On every dir, each law's own switch alone is the only one that moves that dir's bytes.
- The one exception is AM/am12, which both ARRMEMBER and PROVCOPYBIND move. It is a provider case.

## Grid (cases/, 37 dirs; drivers/runcase.sh, drivers/switches.sh; evidence/grid_*.txt)

Every case is accepted by upstream slang (`~/.local/bin/slang dut.sv --single-unit`, rc 0 on 37 of
37). Every exit code is 0 on both binaries. Each line reads pristine -> law10, as exit code, uhdm-cmp
lines, verdict, and objects or dump distance:

```
AF/af01 cmp=394 NOT_EQUAL dd=201 -> cmp=394 dd=186     AF/af02 cmp=402 dd=315 -> dd=290
AF/af03 cmp=65 dd=286 -> dd=295 (*)                     AF/af04 STRICT_EQUAL 130 -> same bytes
AF/af05 cmp=49 dd=352 -> dd=357 (*)                     AF/af06 cmp=394 dd=99 -> dd=94
AF/af07 cmp=124 dd=321 -> dd=318                        AF/af08 cmp=472 dd=405 -> dd=386
AF/af09 STRICT_EQUAL 364 -> STRICT_EQUAL 364            AF/af10 STRICT_EQUAL 264 -> STRICT_EQUAL 264
AM/am01 cmp=1116 dd=596 -> cmp=1120 dd=592 (+)          AM/am02 cmp=1160 dd=604 -> cmp=1164 dd=600 (+)
AM/am03..am06 STRICT_EQUAL -> same bytes (controls)     AM/am07, am08 NOT_EQUAL -> same bytes (residue)
AM/am09 cmp=198 dd=378 -> dd=374                        AM/am10 cmp=38 dd=554 -> dd=550
AM/am11 cmp=1364 dd=640 -> cmp=1368 dd=636 (+)          AM/am12 cmp=1194 dd=1156 -> dd=1148
AM/am13 cmp=926 dd=618 -> dd=614                        AM/am14 STRICT_EQUAL 249 -> same bytes
AP/ap01 cmp=1618 dd=758 -> dd=662                       AP/ap02 STRICT_NOTEQUAL fullname -> depth (later)
AP/ap03 STRICT_NOTEQUAL fullname -> STRICT_EQUAL 465    AP/ap04 STRICT_NOTEQUAL fullname -> depth (later)
AP/ap05 cmp=892 -> same bytes (control)
PB/pb01 STRICT_NOTEQUAL depth -> STRICT_EQUAL 215       PB/pb02 STRICT_NOTEQUAL depth -> STRICT_EQUAL 453
PB/pb03, pb04, pb06, pb07, pb08 STRICT_EQUAL -> STRICT_EQUAL (bytes move)   PB/pb05 STRICT_EQUAL -> same bytes
```

The grid's TOY cases carry older faces of their own, so most of them are NOT_EQUAL on both binaries:
- the class_var and struct_var listing of a package OOB method, a listing golden parents at the
  function where ours parents at the begin;
- uhdm-cmp pairing package u against package a.

The laws' fields are judged by the dump distance and by the field itself:
- (+) uhdm-cmp prints 4 more lines at the SAME head. The printed RHS now holds the new
  typespec_member actual that golden also holds, and the dump distance falls.
- (*) The dump distance grows while the alias refs read golden's names and counts. On af03, golden
  has 4 `a::f::v::M_T` and 4 `b::f::v::M_T`, and law10 has the same; pristine had 0 and 2. The
  growth is the diff alignment of the weakly-referenced section. The uhdm-cmp head is unchanged.

## Away census (drivers/away.sh; evidence/away_census.txt, away_movers_judged.txt)

- Pristine (the main tree's build, md5 9aaf4570) against law10, over 7277 earlier case dirs whose
  dut.sv mentions `import`. The list was built from all 33551 case dirs under tools/probe after
  fence-filtering the paths; no fenced name is among them.
- No exit code moved. 72 dirs move bytes. Every one was judged against its golden (runcase.sh):
  - 8 go to STRICT_EQUAL: v11u265 VC/vc03_three_level_import, VE/ve06, ve07,
    r11u476 CC/cc13, v11u474 VT/vt14, v11u241 E/e02, v11u244 N/n05, v11u450 E/e10.
  - 26 come closer by dump distance at the same head, the AL group of r11u231 among them.
  - 25 STRICT_EQUAL dirs stay STRICT_EQUAL and move bytes only: provider rebinds and per-package copies.
  - 11 NOT_EQUAL dirs keep their dump distance.
  - 2 grow by dump distance with the same head and golden's name counts, as (*) above: r11u214dec
    A/d01_clonefn 157 -> 162 and r11u231 TI/t16 112 -> 123.
- None moves away from STRICT_EQUAL on law10. law9's AL/a04 break is described under law 1.

## Prediction and gates

The prediction (evidence/prediction.txt) was written before the sweep:
- evidence/tools/predict478.cpp scanned the 7476 fence-filtered slang databases of the master's
  control (evidence/predict_control_nonzero.txt). It named a9_class_holder, MiniAmiq d/t,
  SeqDriver d/t, uvm_param_vif_config_db, rsd and four uvm-examples rows.
- It named no uhdm2rtlil or downstream row.

The sweep's trace fired in exactly a9_class_holder and MiniAmiq/SeqDriver d/t on the corpus side
(evidence/trace_counts.txt).

One full five-stage sweep was run with `tests/sweep.sh --jobs 3`, on law10
(md5 d9083f9a10966f02da90e7bba6b1d14b), with `R11U478_TRACE` on. Workdir /tmp/r11u478swp, the same
length as the control's /tmp/intr11u476. The logs are evidence/sweep_corpus.log and
sweep_svtests.log, fence-filtered.

Results by stage:
- **probe**: EQUAL 4025 + STRICT_NOTEQUAL 62 of 4087, regressions 0, conversions 0, changes 0. The
  csv equals the control's row for row.
- **surelog**:
  - default CMP_EQUAL 480; testflags CMP_EQUAL 474.
  - regressions 0, conversions 0, changes 0.
  - The csv equals the control's except the two LowMem log-path texts.
- **uhdm2rtlil**: 803/1/67 in both modes, 0/0/0. The csv equals the control's.
- **downstream**: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; 0 rows not excused.
  The csv equals the control's.
- **sv-tests**: EQUAL 1937, STRICT_NOTEQUAL 0, DIFFERENT 3, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346. regressions 0, conversions 1, changes 0.
  - THE CONVERSION: `CONVERSION generated/uvm-examples/uvm_param_vif_config_db.sv: STRICT_NOTEQUAL -> EQUAL`.
  - The fresh row: `generated/uvm-examples/uvm_param_vif_config_db.sv,EQUAL,,equal`. It is the only
    line that differs from the control's csv. results/ is untouched; the master promotes.
  - The stage ran through the main tree's tests/sweep.sh. It exits 1 on the main tree's law-index
    check alone ("law index STALE"); the worktree's own check reads "law index current".

Canaries:
- canaries.sh: ok=52 (surelog) and ok=16 (uhdm2rtlil).
- ctcan2: ok=58 changed=0 (EXPECT_UNKNOWN=1) and ok=2 changed=0 (EXPECT_UNKNOWN=6), both PASS.

byteverify (SELFCHECK=1) against the control, evidence/byteverify_*.txt:
- surelog: 4 movers of 962, MiniAmiq d/t and SeqDriver d/t, as predicted. Every verdict is kept
  (CMP_EQUAL, strict equal). They are attributed to § aliasFormalCopyPerClone478:
  `R11U478_ALIASCOPY_OFF=1` alone gives the control's bytes on MiniAmiq default
  (8be0993ea71f = control, 3194d2fd5210 with the law).
- uhdm2rtlil: 0 movers of 1608.
- downstream: 0 movers of 805.
- The negative control flagged 961 of 962, 1607 of 1608 and 804 of 805.

The trace fired in 27 processes (evidence/trace_counts.txt):
- a9_class_holder: PB 4.
- MiniAmiq and SeqDriver d/t: AF 1 each.
- rsd: PB 148. The row is SURELOG_CRASH with no golden, its status unchanged.
- uvm_param_vif_config_db: AF 5, AM 6, AP 332, PB 3962.
- 21 other uvm-examples rows: AF and AM. All were EQUAL at the base and stay EQUAL.

So the trace matches the prediction. The four named uvm-examples rows are a subset of the
"every row whose user package imports uvm_pkg" clause, and no corpus row outside the prediction fired.

Goal 1 was re-read at the base: the 75 SURELOG_ONLY details hold no exporter `unsupported` message
(0 of 75), and no SLANG_CRASH row exists. Nothing on this ground.

## Residues (ranked; all wrong on pristine too, none moved away)

1. r11u476's vp06 finding (§ cloneViaProviderTopClone476 does not check that the provider package
   is declared before the importer) is not worked.
2. Interface-instance shapes are not worked:
   - the multi-instance interface statement (IU/iu14, VI/vi15);
   - the non-ANSI interface low conn (vi16);
   - udp-shaped interface arrays (vi01).
3. § cloneHierArrElemMember478 does not reach an anonymous struct element or a packed-union element
   (AM/am07, am08). Golden binds the member, but our clone's element typespec is a logic_typespec or
   bit_typespec there, an older face of the array typespec builder.
4. AP/ap02 and ap04 stay at the walk divergence pristine already had: the imported package
   parameter's int_typespec in the specialization copy.
5. AP/ap01 and ap05 are NOT_EQUAL stage1 on both binaries; they were not decoded.
6. The toy grids' older faces: a package OOB method's struct_var element listing, and its
   function-level variables parented at the begin where golden parents them at the function.
   This is TaskFuncEmit's listing, the AM cases.
7. The carried lists of passes 476 and earlier stand.

## Sister-ground faces (reported, not written)

- StmtEmit's § importCloneBodyLocalCopies175 copies a provider clone's wrapper locals design-final,
  after the provider binding was read. § providerBodyCopyBind478 repairs that on this ground;
  StmtEmit is unchanged.

## Process

- Pristine is the main tree's build, frozen at /tmp/r11u478_bin/pristine. The worktree rebuild has
  the same md5, 9aaf4570aa8c469640569b4ba37b874d. The master's control sweep /tmp/intr11u476 is the
  pristine sweep reading; no pristine sweep was run.
- Intermediate binaries were law1 to law10. They ran on the row and case runs only. One full
  five-stage sweep ran on law10, with the trace on:
  - the four corpus stages from the worktree;
  - the sv-tests stage through the main tree's tests/sweep.sh, since the worktree's UVM folder is
    empty.
- byteverify ran once, law10 against the control.
- The fence list was read into a file by a program and never printed. Every tree-wide list (the
  case census, the database scan, the byteverify output) was filtered on it before any file was
  opened or kept.
- Slip, affecting no measurement: one early comparison command ran in a shell that had not sourced
  the environment file. With UHDM_CMP unset, bash tried to run a golden database as a script. It
  ran in the scratch run directory; no file was written there or in the main tree, which `git
  status` checked. Every later command sourced /tmp/r11u478_env.sh, which checks each tool.
