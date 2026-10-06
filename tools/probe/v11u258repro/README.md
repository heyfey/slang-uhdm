# v11u258: adversarial verification of r11u258 (pass 258, the expression/parameter ground)

Base 2178d427 (pass 256). VERDICT: **the three laws hold; one verifier fix, order-only.** Every headline number of
r11u258 reproduces bit for bit on binaries built here. 112 fresh case-views and 4,134 control case-views found no
legal-SV case where pristine was right and the law is wrong. No probe case, corpus status, strict cell or downstream
verdict moves away from golden. The one defect found is a determinism-by-construction gap that the law exposed:
- § hpSelIdxTrailIdOrder258v sorts an address-ordered name-registration walk in ExprEmit (§ hpSelIdxPathTrailByChain244's
  drain). The walk changed three symbol-table strings on SimpleUVM d/t and Scoreboard d under the law binary.
- The fix changes no dump, record, verdict or csv row.

The delivery is `/tmp/r11u258.verified.patch`: the implementer's patch plus the fix, this directory and the regenerated
`tests/LAWS.md`.

Binaries, built here from fresh worktrees (system-deps config, `-j 2`, frozen `chmod 555` before any measurement):

| binary | md5 | |
|---|---|---|
| pristine (2178d427) | b89d1d5b0dad633330f3355585ce388d | equal to the main tree's build/slang-uhdm |
| law (r11u258.patch) | 4efa5b469a64d3a4ee09f106233fe0fe | equal to the implementer's |
| fix (law + § hpSelIdxTrailIdOrder258v) | b56a3f969034f1863f08321059aa112c | |

All three binaries link slang 12.0.0+545f88b2e.

## Targeted rows (before -> after), reproduced

| row-mode | pristine sweep | law sweep | fix sweep |
|---|---|---|---|
| MiniAmiq default | `MiniAmiq,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | `MiniAmiq,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)` | same as law |
| MiniAmiq testflags | `differ:type(1)` | `differ:file(4)` | same |
| SeqDriver default | `differ:type(1)` | `differ:file(4)` | same |
| SeqDriver testflags | `differ:type(1)` | `differ:file(4)` | same |

NO ROW CONVERTS. The old head is cleared on all four row-modes (MiniAmiq default numbering):

    #121302 type  A: struct_typespec uvm_pkg::uvm_reg_map_addr_range  uvm_reg_model.svh 408:9-412:4
                  B: unsupported_typespec range                       uvm_reg_map.svh 825:50-825:55

The new records, the same as the implementer's (evidence/corpus_heads.txt):

    #126482 / #126534 / #127274 file  A: enum_typespec uvm_pkg::uvm_status_e uvm_reg_block.svh 1774:45-57
                                      B: enum_typespec uvm_pkg::uvm_status_e uvm_vreg_field.svh 462:31-43
    #127418 type  A: typespec_member byte_en uvm_pkg.sv 303:21-28
                  B: ref_obj z  svaunit_pkg::uvm_reg_map::do_bus_write::...::rw_access.byte_en[z]::z

SeqDriver default reads #126440 / #126492 / #127232 / #127376 and SeqDriver testflags #126452 / #126504 / #127244 /
#127388: the same four faces. uhdm-cmp reads 0 lines on all four row-modes, on all three binaries.

The objects count grows from 1 to 4 because pristine's walk stopped at #121302. Both away censuses read 0 lost
(evidence/away_corpus.txt):

| row-mode | record census (awaycorp.sh) | chain-keyed census (awaychain.py) |
|---|---|---|
| MiniAmiq d/t | dist 156 -> 134, lost 0, gained 520 | away 0, toward 522 (flat 0 / 496) |
| SeqDriver d/t | dist 107 -> 97, lost 0, gained 342 | away 0, toward 348 (flat 0 / 326) |

**The face behind #127418 reproduces in a small case: VD/vd01** (`rw_access.byte_en[z] = 1'b1;` in an extern method
copied into an importer package). On both binaries:
- #163 is golden's `typespec_member byte_en` against our `ref_obj z`, from the same unbound bit_select in the copy.
- Two `addr_t` member-alias full names: golden `q::c::f::rw_access::p::op_t::data::addr_t`, ours `addr_t`.

The writer is the sister ground's binder (UhdmExporter § cloneMemberImporterListing259 / § pkgCloneMember10, both
ref_obj only); not written here. A reduction of #126482 (an enum struct member in a copy plus a later `output st_e`
formal) was stage 1 on both binaries on an unrelated package-list face and was not kept.

## The laws as verified

1. **§ cloneLoopVarAssocIdxTs258** (`R11U258_CLONELVIDX_OFF`; StmtEmit, drained in ParamEmit
   drainUnsizedBasedRhs106). Read against golden on 34 fresh case-views (VA).
   - 2-D associative arrays, macro-born foreach in two methods, two importer packages, extern tasks, parameterized
     classes, two loops over one array, fork / nested begin, a handle argument rather than `this`, and longint /
     shortint indices: all go to STRICT_EQUAL in both views.
   - Every other shape stays stage 1 on both binaries and moves toward golden.
2. **§ lvStreamBaseKeepsActual258** (`R11U258_STREAMRD_OFF`; ExprEmit). 44 fresh case-views (VS):
   - Nested streams, interface bodies, virtual interfaces, parameter and indexed bounds, a variable ips base, streams
     on both sides, a two-level generate at instance depth 2, a hierarchical instance path, slice sizes, class handles,
     task struct locals, modports, unpacked element bits and the inLhs restore (vs21) all go to STRICT_EQUAL.
   - The rest move toward golden or stay unmoved.
3. **§ forMultiInitAssign258** (`R11U258_FORMULTIINIT_OFF`; StmtEmit). 32 fresh case-views (VF).
   - These include the shapes whose single-initializer form crashes the elaborated view: r11u254 f04's class property
     and struct member (vf01), v11u254 vf04's generate-block variable (vf02), a class-handle member (vf08) and a
     virtual-interface member (vf09).
   - Every case-view exits 0 on every binary: no crash is introduced.
   - 22 case-views go from stage 1 to STRICT_EQUAL.

## The verifier's fix: § hpSelIdxTrailIdOrder258v (R11V258_HPIDXORDER_OFF)

THE DEFECT. The implementer reported three unpredicted order-only movers and did not locate their cause: SimpleUVM
d/t and Scoreboard d, which no law fires on and which `R11U258_CLONELVIDX_OFF` restores. Located here:
- `strings(1)` over the two SimpleUVM default databases (71,579 strings each) differs only at the symbol table's
  tail. Three full names change places: `...::objection.m_forked_contexts[]::m_forked_contexts::obj`,
  `...::objection.m_drain_proc[]::m_drain_proc` and `...::predict_info.addr[]::addr::addr` (evidence/order_movers.txt).
- Those names are registered by ExprEmit's drainHpSelIdxTrail244 (§ hpSelIdxPathTrailByChain244). It collects its
  hits from `Serializer::AllObjects()`, a `std::map<const BaseClass*, uint32_t>` keyed by the address of a `new T`
  per object, and calls `VpiFullName(want)` in that order.
- The law's only effect on these rows is the `homeForeach258()` map nodes. They change which freed heap chunks later
  UHDM objects reuse, so the relative address order of those three ref_objs flips.
- Each binary is invariant under glibc's heap tunables (`mmap_threshold=4096`, `top_pad` + `arena_max=1`,
  `tcache_count=0`, `tcache_count=0:mxfast=0`): the output is deterministic per binary but not by construction.

THE FIX. Visit the hits in UhdmId (creation) order, as § fullNameDrainIdOrder226v did for
refFullNameThroughNamedExpr175. chainFullName175 reads only VpiName / VpiDefName of the chain, never a name the loop
sets, so only the symbol table's order can change.
- `R11V258_OFF` drops the fix and gives the law's bytes. `R11U258_OFF` also drops it and gives pristine's bytes.
  `R11U258_TRACE` logs `hpSelIdxTrailIdOrder258v <n>` wherever two or more names are set.
- `src/R258.h` r11v258On now also reads `R11U258_OFF`.

MEASURED.
- SimpleUVM default under the fix equals pristine's bytes, with or without `R11U258_CLONELVIDX_OFF`
  (f87dd1ed9147 on every configuration). `R11V258_OFF` gives the law's 045c25fc8bd4.
- The fix's firing census (law binary + fix, fence-filtered, evidence/predict_fix_frozen.txt, frozen 04:10:02 before
  the fix sweep, md5 709852d6596e5252c726d9e5c7b03ace) names 11 databases:
  - corpus: BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d;
  - probe: r10earl29repro a4_ctx, r10uvm94repro g94_a0_head.
- byteverify fix vs pristine: 8 of 2560. The four law rows plus BuildUVMPkg d/t, Scoreboard d and SimpleUVM t.
- byteverify fix vs law: 8 of 2560. MiniAmiq d/t, SeqDriver d, BuildUVMPkg d/t, Scoreboard d and SimpleUVM d/t.
- Every mover is inside the frozen prediction.
- On every order-only mover the uhdm-dump output, ids included, is identical across pristine, law and fix, and so are
  the file sizes. On the four law rows the fix's dump equals the law's.
- Probe: 0 of 4087 databases move fix vs law; the two firing probe databases are byte-equal to pristine's and the
  law's. Every csv (probe, surelog, uhdm2rtlil, downstream) is row-identical fix vs law.
- The fix binary under `R11U258_OFF` gives pristine's bytes on all 240 grid case-views (the implementer's 64 dirs and
  the 56 here, both views).
- Cases: the fix's bytes equal the law's on all 240 grid case-views and all 2670 control case-views. In the widened
  controls exactly r11u244 X/x04 moves in both views (STRICT_EQUAL on all three binaries, dumps identical).

## Gates (all three sweeps from fresh worktrees, `tests/sweep.sh --jobs 3`, SLANG_UHDM exported)

| gate | pristine | law | fix |
|---|---|---|---|
| probe | EQUAL=3565 STRICT_NOTEQUAL=522, 0/0/0 | same, 0/0/0 | same, 0/0/0 |
| surelog | 0/0/0 | regressions=0 conversions=0 changes=4 | changes=4 (the same rows) |
| uhdm2rtlil | 1606 + 0, 0/0/0 | 0/0/0 | 0/0/0 |
| downstream | IDENTICAL=803 SLANG_REJECT=66 EQUIVALENT=2 | same, csv identical | same, csv identical |

- **The sweeps exit 1** only on the law-index check. Neither the pristine checkout nor a checkout carrying this
  directory had a regenerated index when it swept: the index lags by one landing.
  - On a fresh 2178d427 checkout with only r11u258.patch, `scripts/law_index.py --check` reads current.
  - The delivered patch carries the regenerated index.
- **Csv row diffs** pristine vs law: only the four changes and the LowMemLib / LowMemPkg testflags detail text, which
  embeds the workdir (evidence/csv_rowdiffs.txt).
- **byteverify** over fence-filtered hard-link mirrors (2560 databases, 8 fenced paths skipped unread, SELFCHECK=1):
  - law vs pristine reads MOVERS 7 of 2560 with the implementer's hashes on every line.
  - SELFCHECK reads 2559 of 2560 on every pair. The self-check compares each patched file with the pristine copy of
    the FIRST listed path, and that path, not itself a mover, cannot flag against its own copy.
- **Probe bytes**, compared from one worktree (pristine's probe rerun from the law tree, fence-filtered path list):
  0 of 4087 move law vs pristine. A positive control, the first file against the second, is flagged.
- **Binary-path audit** (fence-filtered before any cmds.txt is opened), the same on each of the three sweeps:
  3315 cmds.txt, 3265 naming that sweep's frozen binary, 0 naming another, 50 with no slang line.
- **Canaries** on the law csv:
  - surelog ok=50 changed=2, both targeted: SeqDriver d/t `differ:type(1) -> differ:file(4)`.
  - uhdm2rtlil ok=16 changed=0.
  - ctcan2 surelog (`EXPECT_UNKNOWN=1`) PASS, ok=58; ctcan2 uhdm2rtlil (`EXPECT_UNKNOWN=6`) PASS, ok=2.
  - The fix's csvs are row-identical to the law's.
- **Determinism**: three concurrent draws per binary on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and
  BuildUVMPkg in both modes (evidence/determinism.txt).
  - Every row-mode reads one hash on each of pristine, law and fix, equal to that binary's sweep.
  - Scoreboard testflags has no database, as at the base.
- **Firing census** of the law binary (r11u258's tracecensus.sh, fence-filtered; evidence/predict_frozen.txt, frozen
  03:40:46 before the law sweep, md5 b3381a55616a6a7ff8d6def590d43788):
  - It names MiniAmiq d/t and SeqDriver d/t (8 `defer` + 8 `bind` each), identical to the implementer's.
  - The prediction adds the implementer's three untraced order movers. The `homeForeach258()` registration branch
    carries no trace, which is why a trace census cannot name them; with the fix the question is moot.
  - Positive controls: the trace fires on VS/vs01 and VF/vf04.

## Grid and controls

Implementer's grid, rerun (64 dirs, 768 lines, six configurations): identical in every verdict field
(evidence/impl_gridsum_rerun.txt).
- 128 case-views, 88 moving, 74 entering STRICT_EQUAL, none leaving.
- `R11U258_OFF` gives pristine's bytes on 128 of 128.
- The away census over the 88 movers is identical row for row to the implementer's evidence/away_grid.txt.

Byte controls, rerun on the implementer's 20 dirs (2670 case-views, evidence/controls_summary_rerun.txt):
- 12 moving, 10 entering, none leaving, no exit code changing: the same movers (v11u256 M/vm09, vm17, vm18, vm20,
  vm21, v11u254 F/vf03, both views).
- 14 rc-139 / SLANG_FAIL lines, 7 per binary, all pre-existing on pristine.

Widened controls on all three binaries (drivers/widen.sh, evidence/widen_summary.txt): 9 more dirs, 732 case dirs,
1464 case-views. The dirs are r11u187repro, v11u187repro, r11u244repro, v11u244repro, r11u181repro, r11v181repro,
r11u226verify, r11u183dec and r11u178repro.
- The law moves 4 case-views, all toward golden with 0 lost:
  - r11u187 T/t14 (a streaming target whose index is a call), both views: stage 1 -> STRICT_NOTEQUAL fullname,
    uhdm-cmp 128 -> 0 and 156 -> 0 lines.
  - v11u244 A/a14_cls_forms2, both views: stage 1 on both binaries, dump distance 33 -> 23 and 94 -> 74.
- The fix moves 2 against the law: r11u244 X/x04 in both views, order only.
- None leaves STRICT_EQUAL and no exit code changes. 16 case-views exit nonzero identically on all three binaries
  (r11u183dec SLANG_FAIL rc=3 and the like, pre-existing).

## Fresh attack cases (cases/, every first line names its law)

55 case dirs (VA 17, VF 16, VS 22) plus the decode VD/vd01. Every case-view runs in both views on six configurations:
pristine, law, `R11U258_OFF` and each switch off. That is 660 lines, every exit 0 (evidence/fresh_grid1.txt,
fresh_grid2.txt, fresh_gridsum.txt).
- 110 case-views, 102 moving, 68 entering STRICT_EQUAL, NONE LEAVING, no exit code changing.
- `R11U258_OFF` gives pristine's bytes on 110 of 110.
- Each mover is moved by exactly one switch: CLONELVIDX 32, STREAMRD 42, FORMULTIINIT 28.

Away census on the movers (evidence/fresh_away.txt):
- 0 lost on every one of the 53 record-census rows.
- 17 stage-1 case-views read lost lines on the dump census (45 lines), all print artifacts:
  - the `|vpiParent:` / `|vpiName:range` header lines of the unsupported placeholder the law no longer mints
    (va01, va04, va05, va09, va11, va12, va13, va15);
  - subtrees printed at another position: vf02_el (y's range objects, 150 -> 122) and vf10_el (STRICT_EQUAL under
    the law). In vf10_el, golden, pristine and law all print exactly one top-level `array_var p::c::q` and one
    `int_var p::c::i`.
  - The distance to golden falls on every one of the 17.

Downstream on 54 fresh case dirs (the harness's `one()` per case; evidence/downstream_fresh_*.txt):
- pristine: 46 IDENTICAL, 7 EQUIVALENT, 1 STATUS_DIFF; the law: 52 IDENTICAL, 1 EQUIVALENT, 1 STATUS_DIFF.
- VF vf04, vf05, vf12, vf13, vf14 and vf15 go EQUIVALENT -> IDENTICAL. None leaves IDENTICAL.
- vs08 (STATUS_DIFF: Surelog READ_FAIL) and vs22 (EQUIVALENT) read the same on both binaries.
- va01 was left out: its `include` needs the case directory.

| case | law | pristine -> law |
|---|---|---|
| VA va02, va03, va06, va07, va08, va10, va14, va17 (both views), va13 (both) | § cloneLoopVarAssocIdxTs258 | type / stage 1 -> STRICT_EQUAL |
| VA va01, va04, va05, va09, va11, va12, va15 (both views) | § cloneLoopVarAssocIdxTs258 | stage 1 on both binaries, toward |
| VA va16 | § cloneLoopVarAssocIdxTs258 | unmoved (stage 1, a type-parameter index) |
| VF vf04, vf06, vf07, vf08, vf09, vf10, vf11, vf13, vf14, vf15 (both), vf05_el, vf12_el | § forMultiInitAssign258 | stage 1 -> STRICT_EQUAL |
| VF vf01 (both) | § forMultiInitAssign258 | stage 1 -> fullname (the class struct-member ref_typespec, TypeEmit) |
| VF vf02 (both), vf05, vf12 (default view) | § forMultiInitAssign258 | stage 1 on both binaries, toward |
| VF vf03, vf16 | § forMultiInitAssign258 | unmoved (the law abstains: `this.` / hierarchical second initializer) |
| VS vs01-vs07, vs09-vs12, vs15, vs19, vs21 (both views) | § lvStreamBaseKeepsActual258 | col -> STRICT_EQUAL |
| VS vs14 | § lvStreamBaseKeepsActual258 | defname -> col (vm06's start-column face remains) |
| VS vs17 | § lvStreamBaseKeepsActual258 | fullname(6) -> fullname(4), #67 cleared |
| VS vs20 | § lvStreamBaseKeepsActual258 | col -> fullname, distance 24 -> 4 |
| VS vs08, vs13, vs16, vs22 | § lvStreamBaseKeepsActual258 | stage 1 on both binaries, toward |
| VS vs18 | § lvStreamBaseKeepsActual258 | unmoved (fullname on both) |
| VD vd01 | (decode of MiniAmiq #127418) | equal bytes on both binaries |

## Residues, ranked

1. **MiniAmiq / SeqDriver d/t, four records each, sister ground.** Clearing them should convert all four row-modes.
   - #126482 / #126534 / #127274: the enum listing's location inside importer-copy struct copies.
   - #127418: the bit_select member binding in a copy, reproduced as VD/vd01; UhdmExporter § cloneMemberImporterListing259
     / § pkgCloneMember10 bind ref_obj elements only.
2. **Other address-ordered name walks.** Several walks still register names in `AllObjects()` (address) order. A
   200-line scan after each `AllObjects()` call finds `VpiFullName(...)` writes in:
   - ExprEmit: cloneHpIdxDrain220, drainLvIpsChain244, rootPathFullNameByChain181;
   - ParamEmit: pkgArrTdBindCopies250, pcwRefLastWriter250, bindPkgTfBodyClassMethodClones192.

   None moved in any measurement here. Each is deterministic per binary, not by construction; not audited further.
3. **§ cloneLoopVarHomeObject183's home lookup collides on a shared include** (VA/va01, wrong on pristine too, stage 1
   on both binaries). One header holding the foreach is included into two packages. q2's copy then shares p1's loop
   variable (`p1::c::f::range`) where golden's is p2's.
4. **§ cloneLoopVarAssocIdxTs258's open shapes**, all stage 1 on both binaries and moving toward golden:
   - class-scoped enum and struct index typedefs (va04, va12);
   - an index typedef from a third package (va05);
   - a struct index with enum and nested-struct members (va09);
   - a packed union index (va11);
   - integer, time, bit and untypedef'd logic-vector indices (va15);
   - a type-parameter index (va16, unmoved).

   The implementer's a01 / a09 / a10 (package-only importer: fullname(2) -> (14), same first record #83, 0 lost)
   reproduce.
5. **§ lvStreamBaseKeepsActual258's remaining faces:**
   - vs20: the genvar reference inside a binary-op index of a read path (`[g + 4]`) is named through the chain in
     golden (`...read_data[g + 4].read_data.g`) and by scope in ours (`gb[0].g`), on 4 records;
   - vs17: a plain-variable stream target's part_select stores no full name in ours (golden `work@m.v`), wrong on
     pristine too;
   - vs14 / v11u256 vm06: the start column with spaces;
   - vs18: class properties without `this.`;
   - vs08, vs13, vs16, vs22: stage 1 on both binaries;
   - the implementer's s15.
6. **§ forMultiInitAssign258's remaining faces:**
   - The for-init Lhs binding context. In an interface task (vf05, default view) golden binds the ref_var's actual
     (`int_var work@top.b.i`) where ours leaves it null. Two generate levels down at instance depth 2 (vf12, default
     view) golden leaves it unbound where ours binds. Presumably shared with the single-initializer form; not measured.
   - vf02 (a generate-block `int y [2]` read as logic_var in ours).
   - vf01's class struct-member ref_typespec full name (TypeEmit, the sister ground's vf01 face).
   - The abstentions vf03 (`this.` second) and vf16 (hierarchical second).
7. **Carried, not attempted by the implementer:**
   - BlackBePipeInt #331795 / #331692;
   - pass 256's residues other than vm17 / vm20 (the Earlgrey faces, vb01, vb06, vb07, vg19, vf11, vm10, vm06, the
     grid residues);
   - items (4) to (7) except the two-initializer loops;
   - the sister-ground faces with their call sites as the implementer lists them.

## Process

- Worktrees `/tmp/wt_v11u258` (law, then law + fix) and `/tmp/wt_v11u258pris`, plus a read-only index check
  worktree `/tmp/v11u258_idxwt`. Scratch is `/tmp/v11u258_*`.
- No source was edited while a translation unit compiled: the law binary was frozen before the fix was written, and
  the fix built afterwards.
- No process was signalled, and no other agent's command line was listed.
- **The fence**:
  - The fence names were read from `tools/probe/r11u107repro/canaudit.sh` through r11u258's env.sh, fail-closed.
  - Every corpus database scan went through fence-filtered path lists: bvmirror.sh, binaudit.sh and the probe cmp
    loops.
  - The firing censuses ran with the `$FENCED` filters.
  - The only corpus databases opened outside the gate sweeps are the named rows MiniAmiq, SeqDriver, SimpleUVM,
    Scoreboard and BuildUVMPkg.
  - Nothing fenced was dispatched, read, decoded or opened outside the gate sweeps. The patch reads 0 fenced names as
    whole words.
- Every dump went through a `[ -x "$UHDM_DUMP" ]` guard.
- **One slip**:
  - Two shells reused the variable `S` for my scratch root after sourcing env.sh, which sets `S` to the case store.
  - One evidence copy then failed with "No such file" before anything was written, and was rerun with a distinct
    variable.
  - No file outside my scratch was touched.
- A first draft of va09 was illegal SV: slang rejects a foreach over a wildcard-indexed array. It was rewritten
  before any law measurement. The decode case vd02 was dropped, since it did not reproduce its face.

## Files

- `cases/VA`, `cases/VF`, `cases/VS`: the fresh cases. `cases/VD/vd01`: the #127418 decode.
- `drivers/fixrun.sh`: one binary over repro dirs in both views. `drivers/widen.sh`: three binaries.
  `drivers/widensum.py`: the three-binary summary.
- Every other driver is r11u258repro's: case.sh, grid.sh, gridsum.py, controls.sh, ctlsum.py, tracecensus.sh,
  awayall.sh, awaycorp.sh, awaychain.py, cc_x.sh, bvmirror.sh, binaudit.sh, det.sh and dscases.py.
- `evidence/`: the sweep summaries (P / L / F), csv row diffs, the three byteverify runs, the two frozen predictions,
  corpus heads, away censuses, determinism draws, order_movers.txt, the fresh grid, gridsum and away census, the
  downstream runs on the cases, the rerun grid and control summaries, the widened controls and the vd01 decode.
