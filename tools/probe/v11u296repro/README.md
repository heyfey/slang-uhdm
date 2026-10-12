# v11u296 — adversarial verification of r11u296

Verifier of pass 296 (ground A: src/ExprEmit.cpp, src/StmtEmit.cpp, src/ParamEmit.cpp, switches in src/R296.h).
Base 3049e6ab. Fresh worktrees /tmp/wt_v11u296pris (pristine) and /tmp/wt_v11u296 (the implementer's patch
applied clean), scratch /tmp/v11u296_*.

## Verdict

**ACCEPT, NO PRODUCTION FIX.** Every headline number of the implementer reproduces bit for bit, and the
fresh attack found no case on legal SystemVerilog where pristine was right and the law wrong. The
production files are byte-identical to /tmp/r11u296.patch. This directory adds the fresh cases, the
drivers and the evidence.

| binary | md5 | |
|---|---|---|
| pristine | 6b20693eef699614784a0ae089571dc0 | rebuilt here, equal to the main tree's build/slang-uhdm |
| law | f084a2ac85ffae8db05ce180440a60ed | rebuilt here from the patch, equal to the implementer's |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | the pristine worktree's build, used by both sweeps |

## Gates reproduced (tests/sweep.sh --jobs 3, workdirs /tmp/v11u296_wdP and /tmp/v11u296_wdL, evidence/sweep_*.log)

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3966 + STRICT_NOTEQUAL 121, 0/0/0 | EQUAL 3971 + STRICT_NOTEQUAL 116, regressions=0 **conversions=5** changes=0 |
| surelog | 480 + 0 / 474 + 0, 0/0/0 | 480 + 0 / 474 + 0, 0/0/0 |
| uhdm2rtlil | 803/1/67 both modes, 0/0/0 | 803/1/67 both modes, 0/0/0 (stamped_gen_param d/t CMP_NOTEQUAL as at the base) |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0; downstream.csv byte-identical to results/downstream_uhdm2rtlil.csv and to pristine's |

The five conversions (fresh probe.csv rows of the law sweep):

    r10v169repro/v169_g_control,EQUAL,,equal         (base differ:line(10))     § retFoldTsKeyedByParam296
    r10uvm193repro/g193_c_argface,EQUAL,,equal       (base differ:fullname(4))  § pkgFnCloneIdxNamesByChain296
    r10earl29repro/v8_sites2,EQUAL,,equal            (base differ:fullname(1))  § hcTrailIdxNamesByPortChain296
    r10earl29repro/b3_edges,EQUAL,,equal             (base differ:fullname(2))  § castTsInPathIdxByChain296
    r10uvm175repro/g175_c_tail,EQUAL,,equal          (base differ:fullname(2))  § randWithLastSelChainShape296

An EQUAL probe row needs uhdm-cmp equal, so uhdm-cmp reads 0 lines on all five.

- Row by row, surelog.csv differs between the two sweeps only in the LowMemLib and LowMemPkg testflags
  detail text, which holds the workdir path. uhdm2rtlil.csv and downstream.csv do not differ at all.
  probe.csv differs only in the five conversions.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on hard-link mirrors filtered by
  $FENCED (drivers/mirror.sh: 2560 mirrored, 8 fenced paths skipped by name):
  - PATH_SETS_IDENTICAL, MOVERS 0 of 2560.
  - SELFCHECK flags 2559 of 2560. The self-check compares every database with one fixed database, and
    that database is never flagged against itself. This is the known artefact, not a mover.
  - Probe databases: exactly the five above of 4087. Downstream slang-lane databases: 0 of 805.
- Firing census (drivers/tracecensus.sh on the frozen law binary, filter built from $FENCED;
  evidence/predict.txt): **byte-identical to the implementer's predict.txt**. It names the five probe
  databases and six corpus row-modes where a trace fires but no byte moves: Earlgrey_0_1 d/t
  HCTRAILIDX 97, and MiniAmiq d/t and SeqDriver d/t PKGFNCLONEIDX 16. byteverify confirms 0 corpus
  movers, so the census over-predicts only on those six; it misses no mover. The trace logs a
  recomputed base or a re-registered clone, not a changed byte. No corpus database moved, so the
  corpus away census (awaycorp.sh) is 0 by construction.
- canaries: surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0 on both sweeps. ctcan2 PASS on
  both corpora (EXPECT_UNKNOWN=1 and 6) on both sweeps.
- Binary-path audit (drivers/audit.sh, path list filtered by the fence first): each sweep has 3265
  cmds.txt naming its own binary, 0 naming another, 50 running no slang, and 8 fenced paths skipped.
- Determinism (drivers/det.sh, evidence/det.txt): three concurrent draws of the law binary on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen give one hash per
  row-mode on 12 row-modes (Scoreboard and Rggen testflags write no database). Each hash equals both
  sweeps' database and the implementer's det.txt.
- The implementer's grid, rerun with these binaries and goldens built here
  (evidence/impl_grid_rerun.txt, 1328 lines), matches evidence/grid.txt in every field except md5.
  The databases carry the worktree path, so md5 differs. The rerun gives: 166 case-views, 127
  movers, 73 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 4 uhdm-cmp changes (rf04 and rf05
  d/e, all to 0) and R11U296_OFF equal to pristine on 166 of 166. The per-switch attribution is
  identical: RETFOLDTS 26, PKGFNCLONEIDX 23, HCTRAILIDX 36, CASTIDXTS 24, RANDLASTSEL 18.
- The law index: `python3 scripts/law_index.py --check` reads current on the delivered patch applied to
  a fresh 3049e6ab (tests/LAWS.md regenerated with this directory's cases).

## The attack (cases/, 76 fresh case dirs in both views, 152 case-views; evidence/grid1-3.txt, grid_summary.txt, grid_away.txt)

Every case's first line names its law. drivers/gridall.sh runs each case-view on pristine, law,
law+R11U296_OFF and law with each single switch. Every line carries the exit code. Goldens come from
the pinned Surelog with check_probe's arguments; view e adds -elabuhdm / --elabuhdm.

- **152 case-views: 138 moving, 60 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.**
  R11U296_OFF gives pristine's bytes on 152 of 152. Two uhdm-cmp counts change, both to 0: VF/vf08
  d/e 30 -> 0 (a `localparam int signed` beside an `int unsigned` took the other's clone).
- Attribution: each mover returns to pristine under one switch: HCTRAILIDX 46, RANDLASTSEL 32,
  CASTIDXTS 26, RETFOLDTS 16, PKGFNCLONEIDX 14. The exceptions are a cast inside a port connection's
  index (VH/vh18 and VT/vt17, d/e), which needs HCTRAILIDX and CASTIDXTS together.
- **Chain-keyed away census** (drivers/awaygrid.sh with awaychain.py, strictcmp_x built by cc_x.sh):
  away 0 on all 138 movers, with 229 records toward golden.
  - Positive control (binaries swapped, 13 sampled movers, evidence/away_poscontrol.txt): away 1 to 8
    on the 10 movers that have records toward golden.
  - The 0/0 movers were read by dump diff (/tmp/v11u296_gen/tri.sh):
    - VF/vf02: the unreferenced weak tail reordered into golden's order.
    - VH/vh10 and vh11: the symbol table only, dumps identical.
    - Stage-1 cases where ours now reads golden's name but the walk does not align: vh02 and vh17
      read golden's name; vh15, vh16, vh21 and vc01 are at stage 1.
    - vt06 (interface member path): `...bus.q.f[3'(k)].f` against golden's `...bus.q.f[].f`, where
      pristine had `work@dut`.
    - vr06 and vr08: stage 1.
- **Downstream** (drivers/dscases.py on both lanes, 72 case dirs: VH, VT, VF, VR and VC;
  evidence/downstream_cases.txt): no verdict change between pristine and law. 65 IDENTICAL, 4
  EQUIVALENT, 3 DIVERGENT on both binaries. The DIVERGENT cases are vf05, vf07 and vh17, constant
  mismatches pristine has too.
- Shapes per law, with the § law next to each group:
  - **VH**, § hcTrailIdxNamesByPortChain296. The index of a port connection's trailing select written
    as:
    - an implicit net (vh01) or a localparam (vh02);
    - a for-generate genvar (vh03, unmoved), or a reference plus a genvar (vh21);
    - two instances on two ports (vh04);
    - +: and -: part selects (vh05, vh06);
    - unary, ternary and $unsigned indices (vh07 to vh09);
    - an instance in an if-generate (vh10) or a for-generate with local nets (vh11);
    - a two-level member path (vh12);
    - a macro index (vh13);
    - an interface member path (vh14, unmoved);
    - instance depth 2 with an override (vh15, vh22);
    - a class specialization in a +: width (vh16);
    - an output port (vh17);
    - a cast in the port index (vh18);
    - a bind (vh19);
    - an array element member (vh20);
    - a concatenation actual (vh23, unmoved);
    - an interface instance's port (vh24);
    - a program's port (vh25);
    - .* beside a named port (vh26);
    - an instance array (vh27).
  - **VT**, § castTsInPathIdxByChain296. A cast in a path index:
    - in a for-generate (vt01) or an if/else-generate (vt11);
    - in a module function (vt02) or a package function (vt03);
    - nested casts (vt04);
    - a cast inside a call argument in the index (vt05, abstains, unmoved);
    - an interface member (vt06);
    - typedef casts under + (vt07);
    - a class method in a package (vt08) or in a module (vt13);
    - instance depth 2 (vt09) and a for-generate of instances (vt15);
    - the +: base (vt10, unmoved);
    - a this. path (vt12, unmoved, STRICT_EQUAL on both);
    - a task lvalue (vt14);
    - a macro cast (vt16);
    - a right side together with a port (vt17).
  - **VR**, § randWithLastSelChainShape296. The randomize-with receiver's last select indexed by:
    - a class localparam (vr01), an enum constant (vr02);
    - a string key (vr03), a queue `[$]` (vr04);
    - `j-1` (vr06), a cast (vr08), a hex literal (vr09), unary minus (vr10);
    - an associative int key (vr11).
    Other shapes:
    - randomize(lot) with an argument (vr05);
    - an if condition (vr07);
    - a with block reading a member (vr12);
    - a module-scope array (vr13);
    - an extern method in a virtual class with a pure virtual prototype, defined below the class
      (vr14);
    - super.holds[...] (vr15);
    - a static property at two sites (vr16).
  - **VF**, § retFoldTsKeyedByParam296. Return-folded package parameters:
    - three returns with A repeated (vf01);
    - enum-typed (vf02), string (vf04) and typedef-typed (vf05) parameters;
    - a literal as the first return (vf03);
    - an imported package's parameter (vf06);
    - two functions in an importer package (vf07);
    - signed and unsigned localparams (vf08).
  - **VC**, § pkgFnCloneIdxNamesByChain296. An importer package's clone of a free function with:
    - a parameter index (vc01);
    - a property select (vc02);
    - an lvalue (vc03);
    - a static function (vc04);
    - foreach (vc05);
    - a function with a task beside it (vc06);
    - a named call argument (vc07);
    - an explicit `import h::f` (vc08, unmoved).
- Three case files were first written as illegal SV and slang rejected them with exit 3: a task
  called from a function, a non-constant output-port index, and a pure virtual method in a non-virtual
  class. They were rewritten legal before the grid. The golden cache keys on file content, so the
  edits needed no eviction.

## Byte controls (drivers/ctllist.sh; evidence/controls.txt, controls_dirs.txt, controls_away.txt)

540 case dirs were selected by the laws' triggers from 156 earlier repro dirs under tools/probe. The
triggers were: a randomize-with call, a port connection whose actual has an index, a cast inside a
select, a package returning two or more of its parameters, or four packages with an import and a
member path select. The pass's own dirs were excluded and the path list was filtered by $FENCED
before any file was opened.

- 1080 case-views: 26 moving, 0 leaving STRICT_EQUAL, 0 exit-code changes, 0 NOGOLDEN.
- Entering STRICT_EQUAL: r11v133repro/tix/f10_idx_cast d/e (CASTIDXTS) and
  r11v133repro/tix/a10_port_conn e (HCTRAILIDX).
- Moving inside STRICT_NOTEQUAL or stage 1 toward golden: r11v133 a10 d, r11u226verify
  E/e22_clone_idx_nested_cast d/e, v11u220repro C/c22 d/e, r11v42repro grid42v/v1 d/e.
- Moving in the symbol table only, with identical dumps: r11u205dec GS g10, g11 and g12,
  r11u217verify GS/g02, v11u209repro GS/v03, r11u280repro VR/r27_portactual,
  r11v145repro bso/x19_port_conn and v11u280repro VA/va25_iface_inst_actual, each d/e.
- Away 0 on all 26, with 25 records toward golden.

## Residues (all wrong on pristine too)

The implementer's ranked list stands. Confirmed or added here:
1. **The default-view index binding of a port connection.** With the names right, the next record is
   `depth`: golden binds the definition's net, ours the elaborated variable. This covers vh04 to
   vh09, vh12, vh13, vh22, vh25 and vh26 d (11 fresh d views). It is ModuleEmit emitInstance's netMap
   (the stale currentScope of RESUME §9), the sister's ground.
2. **An instance array's port connection.** Golden names the index reference through `u.a`. The law
   gives `u[0].a` / `u[1].a` and pristine gave the scope (vh27, stage 1 on both binaries).
3. **A cast in an interface member path.** Golden's path text drops the cast (`q.f[]`) and ours keeps
   it (vt06, stage 1). The same text rule is why b3_edges reads `{1'b1,}`.
4. **The for-generate name `gb` against our `gb[0]`** in a port-connection index (vh21, stage 1). This
   is the generate-scope naming, not this pass's.
5. **Typedef- and enum-typed return folds** (vf02, vf05). Golden keeps the parameter typespec chain
   with `p::A::w_t` / `p::p::e_t` names that ours does not build. They are untouched by
   RETFOLDTS except the weak tail's order.
6. The implementer's residues 2 to 7 (first-select index under a port, the elaborated listing of
   package-function clones, the imported-call return folds, CT/RW stage-1 shapes, the 116 probe
   residues).

## Process

- The pristine binary was built and frozen (chmod 555 copies under /tmp/v11u296_bin) before the law
  build. Both binaries were frozen before any measurement. The grids, controls, census and the
  determinism check all ran on the frozen copies.
- The fence was read fail-closed from the FENCED= line of tools/probe/r11u107repro/canaudit.sh
  (drivers/env.sh) and never spelled. Every path list over tools/probe or a sweep workdir was filtered
  before any file was opened. No gdb was run.
- No process of another agent was listed or signalled. Nothing was written to the main tree.
- **THE VERIFIER'S ORDER, no effect on any number:** the firing census ran after the law sweep, as a
  reproduction of the implementer's frozen prediction. Its output is byte-identical to that
  prediction, and byteverify had already confirmed the movers.
- Both sweeps ran the harness of the pristine worktree. Its tests/LAWS.md is stale at the base, so
  both exited 1 on the law-index check alone.
- One sweep was launched with `&` inside a foreground shell, and the sweep ran to completion. Its log
  ends rc=1, the law-index check alone.

## Drivers (drivers/, copied from tools/probe/r11u296repro/drivers; scratch defaults moved to /tmp/v11u296_*)

The new driver is `ctllist.sh` (controls over an explicit list of dirs, filtered by the fence).
Everything else is as in r11u296repro: `env.sh`, `case.sh`, `views.sh`, `gridall.sh`, `gridsum.py`,
`attrib.py`, `awaygrid.sh`, `awaychain.py`, `awayrows.py`, `cc_x.sh`, `strictcmp_x.cpp`,
`tracecensus.sh`, `mirror.sh`, `audit.sh`, `det.sh`, `dscases.py`, `dump.sh`, `residue.py`,
`controls.sh` and `ctlsum.py`.
