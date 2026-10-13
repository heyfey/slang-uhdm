# v11u307 — adversarial verification of r11u307 (nested modules, generate-block udp statements, ordered gen-block ports, generate module arrays)

Base 7f95336f (pass 305). Verdict: **ACCEPT WITH FIX**. Every headline number of r11u307 reproduces bit for bit, and
the gate does not move on any binary. Fresh cases found three faces where the laws moved records away from golden on
legal SV. Each face is fixed by its own refinement in ModuleEmit, read through `src/R307.h`:

- `R11V307_<X>_OFF` drops one refinement.
- `R11V307_OFF` drops all three and gives the law's bytes on 174 of 174 fresh case-views.
- `R11U307_OFF` on the fix binary still gives pristine's bytes on every case-view measured (174 fresh, 174 of the
  implementer's).

## Binaries (frozen before any measurement, each linking slang 12.0.0+545f88b2e)

| binary | md5 | built from |
|---|---|---|
| pristine | f2536746... | a fresh worktree at 7f95336f, equal to the main tree's build at the base |
| law | 8628ba87... | a fresh worktree with /tmp/r11u307.patch, equal to the implementer's |
| fix | 827bfaff... | the law plus the three refinements, a rebuild from the verified sources |

Three fix drafts (fixd1 to fixd3) were each frozen after their source edits were complete. The final fix differs from
fixd3 only in where the shadow refinement's trace is written: it is now asked only where a law would fire, so the
census does not over-predict. It is byte-identical to fixd3 on all 1754 grid and control lines compared.

## Reproduction of the implementer's numbers (law vs pristine)

- **Implementer's grid** (87 dirs, 174 case-views; evidence/impl_grid.txt):
  - 145 moving, 137 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.
  - `R11U307_OFF` equals pristine on 174 of 174.
  - Cmp result, line count, strict verdict and rc match the implementer's evidence/grid.txt on 522 of 522 lines.
  - Restored by exactly one switch: NESTREPDEF 35, DEEPSTUB 32, GENMODARR 20, POSUDP 15, DEFGENORD 8. The other 35
    need a pair or triple.
  - The 13 case-views still not STRICT_EQUAL are the ones the implementer lists.
  - The fix equals the law on all 174.
- **Implementer's downstream** (evidence/impl_downstream_*.txt):
  - 19 STATUS_DIFF -> IDENTICAL, 2 EQUIVALENT -> IDENTICAL, 65 IDENTICAL on both.
  - NR/r21_nested_program reads STATUS_DIFF on both binaries.
  - The fix's verdicts equal the law's.
- **Firing scan** (drivers/scan.sh with the fix binary, evidence/scan_fix.txt): 26122 fence-filtered dirs under
  tools/probe (the path list filtered before any case was opened). 259 fire.
  - 100 of them are earlier dirs. They include 13 that only log the shadow refinement's stand-aside.
  - The one 139 is v11u112repro m07_hdr_enum_default, which crashes on pristine too.
- **Earlier firing dirs** (200 case-views, evidence/controls_grid.txt, controls_away_law.txt):
  - Law vs pristine: 166 moving, 110 entering STRICT_EQUAL, 0 leaving, 0 rc changes, lost 0 on all 166.
  - Chain away 0 on 165, with 3632 records toward golden.
  - r10vrgg16repro/cells/v12 reads chain away 6. The 6 records are the gen-for `finst` interface_inst records, now
    first reached through a3's elements. Ours binds the instance and golden binds its col-0 tail duplicate. The
    sibling scan behind `wantTailDup` in ModuleEmit counts instances only, not instance arrays, which is wrong at
    module scope on pristine too. This residue is not fixed here.
  - The fix equals the law on all 200.

## Gates (each sweep `tests/sweep.sh --jobs 3`, exit 1 on the law-index check alone)

| sweep | probe | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| pristine / law / fix | EQUAL 4002 + STRICT_NOTEQUAL 85; regressions 0, conversions 0, changes 0 | 480 + 0 / 474 + 0; 0/0/0 | 803/1/67 in both modes; 0/0/0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; the csv is byte-identical to the committed one |

- **Row-by-row csv diff:** law vs pristine differs only in the LowMemLib and LowMemPkg detail text (the workdir
  path). Fix vs law has no diff at all.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors, drivers/bvmirror.sh):
  - 0 of 3365 corpus and downstream databases move for law vs pristine, fix vs law and fix vs pristine.
  - SELFCHECK reads 3363 of 3365, the known twin.
  - Probe: 0 of 4087 databases move for law vs pristine (the pristine probe stage rerun from the law worktree so the
    paths match) and for fix vs law. A negative control (one corrupted copy) is flagged.
- **Firing census** (drivers/tracecensus.sh with the fix binary, frozen before the fix sweep, evidence/predict.txt,
  predict_fix.txt, census_logs.txt):
  - Over the 4087 probe cases and both corpora in both modes, with the fence filter: 0 trace files, 0 predicted law
    movers and 0 predicted refinement movers. The sweeps and byteverify confirm all three zeros.
  - Positive control (evidence/census_poscontrol.txt): VD/vd15 writes `DEEPSTUB` and `STUBOPND307V`, and VS/vs05
    writes `SHADOW307V_ABSTAIN`.
- **Canaries:** surelog ok=52 and uhdm2rtlil ok=16, changed 0. ctcan2 PASS on both csvs, on all three sweeps.
- **Binary-path audit** (fence-filtered, 3315 cmds.txt per sweep): 3265 name the sweep's own binary and 0 name
  another. The other 50 run no slang.
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode, evidence/determinism.txt): one hash per
  row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, for both law and fix.
  - Each hash equals the sweeps' hashes, which are the same on all three binaries.
  - The law's Earlgrey_0_1 testflags draws timed out while the firing scan was running. They were rerun alone,
    three concurrent: one hash, 025c86db2d2d.

## Attack (87 fresh dirs in both views, 174 case-views, every line rc=0; drivers/grid.sh, evidence/grid.txt)

The fresh dirs fall into six groups:

- **VA:** module arrays in generate blocks (ranges, slices, two dimensions, overrides, wildcard, interface arrays,
  case-generate).
- **VD:** deep and generate-block stubs (empty slots, interface ports, op/concat/ternary/syscall actuals, ordered
  actuals, second bodies, defparam, three levels).
- **VG:** generate-block udp-shaped and ordered statements (interfaces, programs, real udps, `#(P)`, empty first
  slot, member actuals).
- **VP:** positional nested instances (non-ANSI, ops and literals, `#(4'd3)`, `#(1_0)`, two delays, vectors,
  concatenation output, macros, interface terminals).
- **VR:** second bodies (outer parameters, genfor, two parents, interface ports, tasks, bind, arrays).
- **VS:** file-scope namesakes.

| comparison | moving | entering STRICT_EQUAL | leaving | lost | chain away | toward |
|---|---|---|---|---|---|---|
| law vs pristine | 162 | 89 | 0 | 0 | **65 on 24 case-views** | 3329 |
| fix vs pristine | 149 | 111 | 0 | 0 | 0 | 3341 |

- The swapped-binary positive control reads away on 12 of 12.
- **Fix vs law:** 42 case-views differ. Each is restored to the law's bytes by exactly one refinement switch: SHADOW 14,
  STUBOPND 22, STUBIFPORT 6.
- **Downstream** (evidence/downstream_*.txt), pristine -> fix:
  - 23 STATUS_DIFF -> IDENTICAL.
  - va10 EQUIVALENT -> IDENTICAL, va08 DIVERGENT -> EQUIVALENT, vp13 STATUS_DIFF -> EQUIVALENT.
  - None is worse. The law moved **VS/vs09 EQUIVALENT -> STATUS_DIFF**; the fix restores EQUIVALENT.

## The breaks and the refinements

**§ nestShadowFileScopeResolves307v** (`R11V307_SHADOW_OFF`, ModuleEmit `nestShadowTop307v`, read by
`deepStubInst307` and `udpNestInst307` only where a law would fire). This is a file-scope MODULE of the nested name.

- Surelog's ResolveSymbols::bindDefinition_ finds the file-scope declaration by the written name: the nested one is
  filed only as `outer::inner`. It retypes the udp_instantiation to a module_instantiation, and DesignElaboration
  looks up `work@inner` first (the decode of § nestArrShadowTopKeepsBare295v).
- Golden therefore elaborates the file-scope module in full: `module_inst: work@inner` on VS/vs01, vs03, vs05 and vs06,
  and `work@c_m` on vs02 and vs07.
- The law wrote a udp (§ nestedPosInstUdp307) or an empty stub (§ nestedDeepInstStub307):
  - vs05: chain away 9 in both views.
  - vs01 to vs03, vs06 and vs07: flat away 4 to 6.
  - vs09: downstream EQUIVALENT -> STATUS_DIFF.
- The laws now stand aside, and the instance keeps the base's elaboration.
- A file-scope PRIMITIVE of the name keeps the laws: golden's instance is a udp of that primitive. vs08 keeps the law's
  9 records toward golden.
- Cases: VS/vs01 to vs09.

**§ deepStubOperandLeafRule307v** (`R11V307_STUBOPND_OFF`, inside the stub's port loop in emitInstance). The stub's
actual is compiled by NetlistElaboration's port-connection loop like any other actual, so an operation or system-call
actual follows § connLeftmostLeafElab139:

- Every reference and select inside it is named through the stub: `<inst>.<formal>.<name>` for a named actual,
  `<inst>.<name>` for an ordered one.
- At module scope, every reference but the leaf reached through left operands, ternary conditions and bit-select
  indices binds the instantiating definition's net. A second body's parent reads the representative definition.
  Golden VD/vd15 `.x(i ^ j)`: i -> `work@dut.u_a.u_b.i`, j -> `work@a_m.work@a_m::b_m.j`.
- Inside a generate block only the names follow. Outer references stay unbound (§ connOperandOwnScopeBind61), which
  is golden vd21's default view.
- The law named the references in the instantiating scope and bound each one to the elaborated net: chain away 1 to 5
  on vd14 to vd18, vd21 and vd23 to vd25.
- With the refinement, vd14 to vd18, vd21, vd23, vd24 and vd25 enter STRICT_EQUAL in both views.
- vd19 and vd20 are an ordered op actual. Their elaborated stub ports now match golden. They stay at stage 1 on the
  positional law's definition-view udp terminal (golden keeps an operation terminal as the bare first reference),
  which is wrong on pristine too.

**§ deepStubIfacePortActual307v** (`R11V307_STUBIFPORT_OFF`, the same loop). An actual naming an INTERFACE PORT of
the instantiating module is a reference named by the port and bound to the module's port view (`ifacePortViewMap`),
like any passthrough connection. Golden VD/vd02 `.q(p)`, vd22 `(p, o)` and vd26 (in a generate block) read ref_obj
`work@dut.u_a.u_b.p` -> the port view interface_inst. The law left no HighConn: chain away 1 on vd02 and vd26.

- vd02 and vd26 enter STRICT_EQUAL in both views.
- vd22 stays at stage 1 on the definition-view udp terminal of an interface name, which is wrong on pristine too.

## Residues (ranked; all wrong on pristine too)

1. An instance-array element's interface actual binds the instance where golden binds its col-0 tail duplicate.
   - Seen on r10vrgg16repro/cells/v12 (chain away 6, an identity-walk artifact the gen-array listing exposes) and
     VA/va08, both at stage 1.
   - The fix belongs in ModuleEmit emitInterfaceInstance: the `wantTailDup` sibling scan reads `SymbolKind::Instance`
     siblings only, so arrays are not counted. The change reaches module scope too, so it needs its own pass.
2. The definition-view udp terminals of the positional law: an operation terminal (VD/vd19, vd20, VP/vp03), an
   interface terminal (vd22, VP/vp13), and a concatenation output (vp11).
3. The shadow cases themselves (VS): golden elaborates the file-scope module, a Surelog defect not copied.
4. The implementer's list: ND/d07 (parameter road), d15, NR/r04, r21, NP/p03, NG/g05 and GA/a11 default.
5. Others:
   - VG/vg16: the member-access actual's last element `work@outer.g.u_l.x`, strict-only.
   - VG/vg02: a udp primitive inside a generate block, where golden lists no udp_defn.
   - VG/vg08 and vg12: at stage 1 on every binary (vg08 moved 7 records toward golden).
   - VD/vd01: an empty ordered slot.
   - VD/vd06: a nested begin inside a generate block, at stage 1 on every binary (3 records toward golden).
   - VD/vd11 default (the elaborated view enters STRICT_EQUAL).
   - VP/vp05, vp10: sized or two-value delays, where the law abstains.
   - VR/vr09: unmoved.

## Process

- Both worktrees were fresh at 7f95336f. The fence was read fail-closed from canaudit.sh by every driver (copied from
  v11u305repro/drivers and adapted). Every path list was filtered before any file was opened.
- No fenced name is spelled here, and no other agent's process was touched.
- My own fix-census-and-sweep task was stopped by its task id when the shadow trace was moved. It was rerun in full on
  the final binary.
- grid.sh gained a `D<n>` configuration that reads `$B/fixd<n>`, for drafts.
- VP/vp01 (fewer actuals than ports) was dropped because Surelog crashes on it (no golden).
