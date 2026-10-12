# v11u305 — adversarial verification of r11u305 (module/type ground)

Base 6efe8882 (pass 303). Implementer's patch `/tmp/r11u305.patch` (nine laws in ModuleEmit and TypeEmit behind
`src/R305.h`). Verdict: **every headline number reproduced bit for bit; four breaks found on fresh legal SV where
pristine was right and the law wrong; fixed by four refinements behind `R11V305_<X>_OFF`** (shipped as
`/tmp/r11u305.verified.patch`). With the refinements, the gate numbers are unchanged: five probe conversions, no
change, no regression, and 0 of 3365 corpus and downstream databases move in bytes.

## Reproduction (binaries built here, frozen read-only before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine | 0679e3cb | equal to the main tree's build/slang-uhdm at the base |
| law | 27389a5a | equal to the implementer's law binary |
| fix | 0a8b3ba2 | the law plus the four refinements (final; draft `fix_d3` 6a92f384 differs only in the trace order of § wireScopedTdPkgOnly305v) |

slang 12.0.0+545f88b2e (~/.local). The sweeps ran `tests/sweep.sh --jobs 3` from this worktree with `SLANG_UHDM` exported
(workdirs /tmp/v11u305_sw{P,L,F}, same length).

- **Law sweep** (evidence/sweep_L.txt): probe EQUAL 3997 + STRICT_NOTEQUAL 90, regressions 0, conversions 5, changes 0
  (`r10earl53repro/v2_v53`, `r11u1repro/grid2`, `r11u93repro/grid/pb19_modportview`, `r11v1repro/vA`,
  `v11u93b107repro/brk/q04_pkg_member`, each `-> EQUAL`, csv rows `<name>,EQUAL,,equal`); surelog default 480 + 0,
  testflags 474 + 0, 0/0/0; uhdm2rtlil 803/1/67 in both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66,
  EQUIVALENT 2, DIVERGENT 0, the csv byte-identical to results/downstream_uhdm2rtlil.csv. Pristine sweep: probe
  3992 + 95 and the same corpus numbers.
- **Row-by-row csv diff law vs pristine**: probe exactly the five rows; surelog only the LowMemLib / LowMemPkg testflags
  detail text (the workdir path); uhdm2rtlil 0 rows; downstream 0 rows.
- **Byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors,
  drivers/bvmirror.sh): law vs pristine **0 of 3365** (SELFCHECK 3363 of 3365, the known twin); probe databases moving:
  exactly the five conversions.
- **Firing census** (drivers/tracecensus.sh on the fix binary, frozen before the fix sweep; evidence/predict_law.txt):
  byte-identical to the implementer's predict.txt (the five probe databases, 0 corpus row-modes); the refinement
  census (evidence/predict_fix.txt, every `*305V_ABSTAIN` firing in the probe and both corpora in both modes) is
  **empty**: no gate database is predicted to move between law and fix. Positive control: run on the witnesses,
  each refinement logs its tag (vt20 `TDCOPY305V_ABSTAIN override work@dut.u.T.s_t`, vu05 `IFCALL305V_ABSTAIN`
  on b0 and b1, vw04 `WIREPKG305V_ABSTAIN sn`, vm11 `UDPBIND305V_ABSTAIN work@top.a.q`).
- **Fix sweep** (evidence/sweep_F.txt): the same numbers as the law sweep; csv diff fix vs law: probe 0 rows,
  uhdm2rtlil 0, surelog only the LowMem path text; downstream csv byte-identical to the committed one; byteverify fix vs
  law and fix vs pristine 0 of 3365 (SELFCHECK 3363 of 3365); probe databases fix vs law 0 moving, fix vs pristine the
  five conversions.
- **Canaries**: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 on the law and pristine sweeps; ctcan2 PASS on
  both (EXPECT_UNKNOWN=1 / 6).
- **Binary-path audit**: 3315 fence-filtered cmds.txt per sweep; 3265 name the sweep's own binary, 0 another, the other
  50 run no slang (48 name no slang-uhdm path, CoresSweRV and CoresSweRVMP run Surelog only).
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode, evidence/determinism.txt): Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and every testflags row-mode with a
  database read one hash each on law and on fix, each equal to the law and fix sweeps' hashes.
- **The implementer's grid** (118 dirs, 236 case-views, rerun here on pristine, law and fix;
  evidence/impl_grid_PL.txt): the P and L strict verdict, exit code and md5 match the implementer's grid.txt on
  236 of 236 lines each; 160 moving, 134 entering STRICT_EQUAL, 0 leaving; the fix equal to the law on all 236.

## Breaks found (fresh cases, cases/; pristine right, law wrong) and the refinements

107 fresh case dirs in both views (214 case-views) in VM (positional modport, 14), VP (port views, 17), VT (scoped
typedef members, 30), VU (interface unsized / plain / split cells, 29) and VW (scoped wire typedefs, 17); every grid
line carries its exit code (drivers/grid.sh; evidence/grid.txt: 1284 lines over P, L, F, OFF, FOFF, FUOFF, rc=0
on 1248, rc=3 on VT/vt23_tp_ovr_inline and VP/vp14_portdecl_after_mp (slang rejects both on every binary), rc=4 on
VT/vt17_union_unpacked (every binary)).

1. **§ ifUnsizedUserCallAbstains305v** (`R11V305_IFCALL_OFF`, ModuleEmit, inside § ifCaUnsizedRhsClonePerInst305's
   gate and § ifTernFillSplitPerInst305's `split305`). An interface cell whose Rhs holds a USER function call
   (`assign arr[0] = f(sig) | '0;`, a package function `pk::f(sig) | '0`, a plain Lhs `w = f(sig) ^ '1`, one instance,
   `{8{g(sig)}} & '1`, the split ternary `(P) ? f(sig) : '0`): the law cloned the cell and **broke uhdm-cmp equality
   in the elaborated view** (VU vu05, vu23, vu24 and vu25 `_el`: STRICT_NOTEQUAL type / fullname with uhdm-cmp 0 ->
   NOT_EQUAL stage 1 with 60 lines, order-blind lost 124 to 160 records, chain away 6; vu21_el uhdm-cmp 30 -> 60, chain
   away 6; vu26_el chain away 6). Golden binds the call argument to the instance's variable where the clone keeps the
   definition's net; the producer's re-evaluation of the call in its clone is not transcribed. The refinement stands
   the law aside on any `func_call` in the Rhs (operands, system-call arguments, select indices). System calls
   (vu22_syscall `^sig`, `$countones(sig)`) keep the law (vu22_el enters STRICT_EQUAL).
2. **§ scopedTdMemberCopyAbstains305v** (`R11V305_TDCOPY_OFF`, TypeEmit, both struct and union sites of
   § scopedSimpleTdMemberBindsListing305, the direct member and the unpacked element). A struct or union COPY made for
   another name: a module typedef passed as a type-parameter override (`sub #(.T(s_t)) u`, module or interface
   receiver, two instances, a union; ParamEmit's override road builds it under `bypassTypedefShare` while the emitted
   scope is the receiving body) or a typedef of the typedef (`typedef s_t s2_t;`). Golden gives such a copy's member
   the `w_t` clone with Instance pk (the pristine road); the law bound `pk::w_t` and read **chain away 4 to 16** (VT
   vt20, vt24, vt28, vt29, vt30, vt26, both views; uhdm-cmp 17 -> 112 lines at stage 1 on vt20, vt24, vt29, vt30). The
   override test needs the declaring scope to be an instance body not reached from the current scope without crossing
   another body: `$unit`, package and class typedefs also built under `bypassTypedefShare` keep the law (a draft gating
   on `bypassTypedefShare` alone gave up VT/vt18_class_prop_struct, which golden binds like the law; the package override
   vt21 and default vt22 keep the law and enter STRICT_EQUAL). The module's own listing of s_t keeps the law (vt20 ...
   still move toward golden against pristine, away 0).
3. **§ wireScopedTdPkgOnly305v** (`R11V305_WIREPKG_OFF`, ModuleEmit, § wireScopedTdEndAtType305's gate). The law fires
   on any scoped type name; `wire $unit::sa_t sn;` (golden writes an unsupported_typespec) and `wire C::sa_t sn;` (a
   class-scoped typedef) take other producer roads. The law read chain away 4 (VW/vw04_unit), 7 (vw17_unit_twomods) and
   1 (vw16_class_scope) in both views, stage 1 on every binary. The refinement requires the net's type to be a typedef
   declared in a package.
4. **§ udpMpPathBindAbstains305v** (`R11V305_UDPBIND_OFF`, ModuleEmit, § udpPosModportPathAtSel305's gate). A bind
   directive's instantiation `bind top mp_pos a (u.mp, o);` is a bind_instantiation to Surelog's parser, not a
   udp_instantiation; the law moved the path away (VM/vm11_bind: STRICT_NOTEQUAL line -> col, order-blind lost 2,
   chain away 2 in both views). The refinement stands aside for an instance under a BindDirective.

Each refinement is droppable alone (evidence/fix_attribution.txt: the 32 case-views where fix and law differ are each
restored to the law's bytes by exactly one switch: IFCALL 12, TDCOPY 12, WIREPKG 6, UDPBIND 2); `R11V305_OFF` gives the
law's bytes and `R11U305_OFF` on the fix binary gives pristine's on 214 of 214 fresh case-views (and `R11U305_OFF` on
the law binary too). Every refinement case names its law in its first line.

## Fresh grid numbers (evidence/grid_PL.txt, grid_PF.txt, grid_LF.txt, away_*.txt)

- **Law vs pristine**: 204 case-views moving, 143 entering STRICT_EQUAL, none leaving STRICT_EQUAL, but **4 leaving
  uhdm-cmp equality** (vu05, vu23, vu24, vu25 `_el`) and **26 case-views moving away** under the chain-keyed census
  (the refinement witnesses above).
- **Fix vs pristine**: 184 moving, **143 entering STRICT_EQUAL, 0 leaving, 0 leaving uhdm-cmp equality, no exit-code
  change; lost 0 and chain away 0 on all 184 with 2232 chain records toward golden**; positive control (binaries
  swapped) reads away on 12 of 12 sampled movers (away_fix_poscontrol.txt).
- uhdm-cmp line counts on the fix: every mover falls or stays except VU/vu14_nested_iface (an interface instantiated
  inside an interface: 1720 -> 1936 and 1722 -> 1940 at stage 1, on every binary at the same design-level head, the
  `uhdmallInterfaces` listing of the nested interface; chain away 0, toward 4; the cell under work@top.o0.bi is now
  parented at the instance as golden's is; downstream EQUIVALENT on all three binaries).
- Laws that moved fresh cases toward golden (fix): positional modport (VM: 12 of 14 dirs STRICT_EQUAL in both views,
  vm03 two instances in one statement moving toward at col, vm02 `#(4)` / `#(.K(4))` stage 1), port views (VP: 12 of
  17 entering, vp04 a modport port expression and vp08 a header port expression moving at line / stage 1, vp13 an
  interface array stage 1), scoped members (VT: 17 dirs entering, among them cross-package, nested, package function
  argument, import, two packages with the same typedef name, the class property, a function return), interface
  cells (VU: 20 dirs entering in at least one view), scoped wires (VW: 11 dirs entering in both views).
- **Downstream** (drivers/dscases.py, 107 dirs on three binaries; evidence/downstream_*.txt): no verdict worse than
  pristine on the fix; 4 improve EQUIVALENT -> IDENTICAL (VU vu09_paramval, vu11_split_plain, vu12_split_three,
  vu27_plain_fill_one). The law's fifth improvement, VU/vu26_split_call EQUIVALENT -> IDENTICAL, is given up by
  § ifUnsizedUserCallAbstains305v (its elaborated view read chain away 6 under the law; it stays at stage 1 on every
  binary).

## Firing scan over every case dir (drivers/scan.sh, the fix binary, default view)

The fix binary run under `R11U305_TRACE` over all 25764 fence-filtered case dirs under tools/probe (default view;
evidence/scan_fix.txt): 221 dirs log a pass-305 tag, 186 of them this pass's and the implementer's grids; the
refinement abstentions fire on this pass's 16 witness dirs and on one earlier dir, r11u159verify/cases/cx/
x08_tp_and_enum_default (`TDCOPY305V_ABSTAIN`, no byte change: the member there is not a simple package typedef). The
other **35 earlier dirs (70 case-views) were run on pristine, law and fix in both views** (evidence/controls_*.txt,
every line rc=0): law vs pristine **56 moving, 27 entering STRICT_EQUAL, 0 leaving, no exit-code change, lost 0 and
chain away 0 on all 56 with 513 chain records toward golden**, 21 uhdm-cmp line counts falling and none growing; the
fix equal to the law on all 70. Entering STRICT_EQUAL beyond the implementer's controls: r11u162verify
pvn/n01_positional_modport, r11u199verify T/t05_iface_ca, r11u256repro B/b12_iface_body (elaborated view) and
r11v154repro pv/o2, each in both views unless stated.

## Residues (ranked; all wrong on pristine too)

1. The interface cells with a user function call in the Rhs (VU vu05, vu21, vu23 to vu26): the producer re-evaluates
   the call when it clones the cell and binds the argument to the instance's variable; transcribing that is the next
   interface law (ModuleEmit emitInterfaceInstance with unsizedRhsCloneDrain193).
2. Type-parameter override copies of module typedefs (VT vt20, vt24, vt28 to vt30; stage 1 on every binary at the
   `w_t` clone's ref_typespec chain name, uhdm-cmp 17 lines) and the typedef-of-typedef copy vt26 (stage 1).
3. The implementer's ranked residues stand (the `-elabuhdm` whole-name fill size, the constant-only interface cells IU
   u16 to u19, vi02 / vi13, the positional modport shapes PM p03 to p06, p08, p10, the scoped member shapes TQ s05,
   s15, s18, s24, s26, t05, the wire shapes WN w02 ... w18, PV v05 / v08); fresh additions: `#(4)` before a positional
   modport actual (VM/vm02, stage 1, golden parses `#(4)` as a udp delay), the bound instance vm11 (line), the modport
   and header port expressions (VP vp04, vp08), an interface-array port view (vp13), `uwire`, `trireg`, a typedef chain
   (VW vw03, vw05, vw06; stage 1), a multi-dimensional unpacked member (VT/vt04) and the struct initialised from a
   pattern or localparam (vt10, vt11; stage 1), the nested interface (vu14).
4. Not attacked: the elaborated-view-only shapes of § pvHdrBodyFirstNdaCell305 beyond vp11, CRLF and include headers
   for the port-view laws.

## Process

Every driver reads `$FENCED` fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh);
every path list (bvmirror, the cmds audit, the probe byte compare, scan.sh, tracecensus.sh's filter) was built and
filtered before any file was opened; no fenced name is spelled in a file of this pass; no gdb ran on anything but this
pass's fresh cases (VT vt20, vt24, vt26); no other agent's process was listed or signalled; the main tree was not
written (worktrees /tmp/wt_v11u305, /tmp/wt_v11u305pris; scratch /tmp/v11u305_*). **The verifier's slips, no effect on
any number:** (1) the fix sweep was launched with a trailing `&` inside a foreground shell; it ran to completion
(sweep F rc=1 on the law-index check alone). (2) One `pgrep -f` used to check that sweep listed this session's own
shells (a pattern of this pass's own script path; no other agent's command line was printed). (3) An `rm -rf` of a
relative trace glob after a `cd` was refused by the harness before running; every later removal used absolute paths.
(4) The fresh grid was first run with the cases under the scratch directory; every number above is from the rerun with
the cases at their committed paths (golden and database bytes carry the path). Three fix drafts were frozen
(d3bb877f gating TDCOPY on bypassTypedefShare alone, which lost vt18; ea072d35 before the bind refinement; 6a92f384);
every number is from the final binary 0a8b3ba2, whose fresh-grid bytes equal 6a92f384's. All sweeps exit 1 on the
law-index check alone before tests/LAWS.md is regenerated (done last, in the patch); after it, `tests/sweep.sh
--corpus probe` on the fix binary reads `law index current`, EQUAL 3997 + STRICT_NOTEQUAL 90, regressions 0,
conversions 5, changes 0, rc 0.

Files: cases/{VM,VP,VT,VU,VW} (107 dirs), drivers/ (env.sh, case.sh, grid.sh, awaycv.sh, away.py, awaychain.py,
awayrows.py, cc_x.sh, strictcmp_x.cpp, bvmirror.sh, dscases.py, det.sh and tracecensus.sh copied from r11u305repro;
grid.sh, scan.sh new), evidence/.
