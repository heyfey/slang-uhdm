# v11u282 — adversarial verification of r11u282

Verifier of pass 282 (the expression/parameter ground), base 8b0e9bffd, implementer's patch /tmp/r11u282.patch
(md5 dfe022b54709e4edd2dcf269d2ec40ed; sixteen laws in src/ExprEmit.cpp behind src/R282.h, one drain call in
ParamEmit). Worktrees /tmp/wt_v11u282 (law, then fix) and /tmp/wt_v11u282pris (pristine), both at 8b0e9bffd.

**Verdict.** Every headline number of the implementer reproduced bit for bit. The fresh cases found ONE BREAK on
legal SV: § genProcOpFoldInPlace282's select branch read the holding select's full name at emission time through
UHDM's caching getter, which stored a premature full name ON THE SELECT ITSELF when the select is a member path's
element (`s.f[P-1]` in a generate-scope process). Fixed behind its own switch by one refinement,
§ procSelNameFinal282v (R11V282_SELFINAL_OFF), which moves 0 gate databases against the law. The verified patch is
/tmp/r11u282.verified.patch.

## The break and the refinement

`always_comb z[w] = s.f[P-1];` with `P` a wildcard-imported package parameter, in a for- or if-generate
(VP/vp26_member_sel, VS/vs01_member_bsel_for, vs02_member_bsel_if, vs06_member_named_begin; stage 1 on every
binary on an unrelated face, 144 uhdm-cmp lines). The law wrote `rt->VpiFullName(selFullName282(up282))` while the
process was being emitted. The bit_select getter (generated `bit_select::VpiFullName() const`) computes
ComputeFullName and stores it when no name is stored. At that point the member path is not yet under its
generate scope, so the law stored `work@top.s.f[4 - 1].f` on the bit_select, where pristine and golden read
`work@top.g[0].s.f[4 - 1].f` (golden's ref_typespec reads the same, pristine's `work@top`). Chain-keyed away census
(tools/probe/r11u272repro/drivers/awaychain.py, strictcmp_x): vp26, vs01 and vs06 chain away 2 in both views,
vs02 chain away 1 in both views.

§ procSelNameFinal282v (ExprEmit, inside § genProcOpFoldInPlace282's select branch; R11V282_SELFINAL_OFF): the
branch records the (ref_typespec, select) pair and foldTsNameFinalDrain282 names the reference after the select
over the final parent chain, in emission order (trace `SELFINAL <old> -> <new>`). R11V282_OFF drops every
refinement of this verification (the law's bytes); R11U282_OFF still drops the whole pass (pristine's bytes): both
read through `r11v282On` in src/R282.h. After the fix the four cases read chain away 0 with 1 or 2 records toward
golden in the default view (evidence/away_fix.txt); vs03 (part select), vs04 (two generate levels), vs05 (an
interface port path), vs07 (a left-side member select) and vs08 (an element index) are unchanged or read away 0
on both binaries; vs09 (a plain local select, the converted shape) keeps the law's bytes.

Prediction, frozen before the fix sweep (evidence/predict_fix.txt): the select branch fires in one gate database
(probe r11u113repro/grid/v/v07_genfor_comb_ctl, where the emission-time and final names agree), so the fix moves
0 gate databases against the law. Measured: 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream databases.

## Reproduction (binaries built by the verifier, frozen in /tmp/v11u282_bin before any measurement)

- pristine d072965260dff2559869f224ede4b3f1 (equal to the main tree's build at the base), law
  0b81965c32da819f870f80f4b3447689 (equal to the implementer's law4), fix e90a777b1f5243d91a8863f68a667e31,
  uhdm-strictcmp fa6e4f42f252ae0ab69d9845003e71c5, strictcmp_x 886f030233ecdbcce7d0e29ac0c4df2c (both equal to the
  implementer's); every binary reports slang 12.0.0+545f88b2e.
- Sweeps (tests/sweep.sh --jobs 3): /tmp/v11u282_wP (pristine, from the pristine worktree), /tmp/v11u282_wL (law)
  and /tmp/v11u282_wF (fix), both from a fresh 8b0e9bff worktree with the implementer's patch applied (law index
  current there; the pristine worktree reads it stale because the base commit's own message attributes five laws
  the committed LAWS.md predates).
  - probe: pristine 3846 + 241 regressions 0; law and fix 3856 EQUAL + 231 STRICT_NOTEQUAL, regressions=0
    conversions=10 changes=0, the ten conversions by name equal to the implementer's (r10earl47repro/a3_earl47,
    r10earl76repro/g2_orig76, r10earl95repro/g5_hop95, r10earl_repro/pu20, r10earl_repro/vo,
    r10uvm99repro/g99_a7_shapes, r10v64repro/v7_inst64, r11u112repro/grid/v/v08_comb,
    r11u113repro/grid/v/v07_genfor_comb_ctl, r11u114repro/grid/f2/b07, each `<case>,EQUAL,,equal`); the law's
    probe.csv is byte-identical to the implementer's.
  - surelog: 478 + 2 / 472 + 2, regressions 0 conversions 0 changes 0 on all three binaries; the csvs differ only
    in the LowMemLib / LowMemPkg testflags detail text (the workdir path).
  - uhdm2rtlil 803/1/67 both modes, csv byte-identical across pristine, law and fix.
  - downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; the csv is byte-identical across the
    three binaries and to results/downstream_uhdm2rtlil.csv.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors
  (drivers/mirror.sh, 2560 per sweep, 8 fenced paths skipped): law vs pristine 0 / 2560, fix vs law 0 / 2560, fix vs
  pristine 0 / 2560. SELFCHECK reads 2559 / 2560 each time: the self-check compares every file against one fixed
  file (the first path), and that path's own pair is byte-equal, so it is the one path that cannot be flagged
  (pass 201's artefact, not a mover). Probe (pristine stage rerun from the law tree, /tmp/v11u282_wQ, its csv
  byte-identical to the pristine sweep's): law vs pristine exactly the 10 conversions; fix vs law 0 / 4087.
  Downstream slang-lane databases: 0 / 805 for law vs pristine and for fix vs law.
- Firing census (the implementer's drivers/tracecensus.sh with the verifier's law binary): 290 lines,
  byte-identical to r11u282repro/evidence/predict.txt (evidence/census_law_predict.txt).
- Canaries on the law and fix sweep csvs: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS
  (EXPECT_UNKNOWN=1 surelog ok=58, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2).
- Binary-path audit (drivers/audit.sh, path list filtered by $FENCED first): pristine, law and fix sweeps each
  3265 own, 0 other, 50 with no slang line, 8 fenced skipped.
- Determinism (drivers/det.sh, three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen): one hash in 3 of 3 on all 12 row-modes that write a database, for
  the law and for the fix, each equal to all three sweeps (Scoreboard and Rggen testflags write none on any
  binary). evidence/determinism_law.txt, determinism_fix.txt.
- The implementer's grid (r11u282repro/cases, 677 dirs, 1354 case-views) rerun with the verifier's binaries:
  identical in every field but md5 (the databases embed the worktree path): 458 moving, 391 entering
  STRICT_EQUAL, 0 leaving, 0 rc or uhdm-cmp line changes, R11U282_OFF = pristine on 1354 of 1354, the same 458
  movers. Under the fix: fix = law on 1354 of 1354, R11V282_OFF = law and R11U282_OFF = pristine on 1354 of 1354,
  chain away 0 on all 458 movers with 562 records toward golden (evidence/away_implgrid_fix.txt,
  implgrid_*_summary.txt).
- The implementer's byte controls (28 repro dirs): 4218 case-views, 148 moving, 31 entering, 0 leaving, 0 rc or
  cmp changes, the same 148 movers by name (evidence/controls1_summary.txt).
- Refinement switches spot-checked, each alone restoring its break on its witness: R11U282_CAIMPLICIT_OFF
  (v11u262repro VL/vl13 d), R11U282_CAUNSIZED_OFF (r11u192repro B/b11_genfor_unsized e), R11U282_LHSIPSCLONE_OFF
  (r11u282repro N/ips_lp_for_sig d), R11U282_REPLCLONE_OFF (N/rep_r_if_unsz d), R11U282_PROCOPUNARY_OFF
  (U/pk_for_and d, pk_for_minus d), R11U282_PROCCATUNARY_OFF (U/mp_for_and d leaves STRICT_EQUAL).

## Widened controls

34 more repro dirs (evidence/controls_dirs.txt, second line: passes 252 to 276 and their verifiers, v11u256,
r11u283 / v11u283, r11u22 / r11u23 / r11v23, r11u69 / r11v69, r11u88, r11v77, r11u111 / v11u111): 2045 case dirs,
4090 case-views, 10 moving, 6 entering STRICT_EQUAL (v11u256repro B/vb06_struct_member d/e and G/vg19_if_lhs_whole
d/e, v11u264repro VG/vg04_if_case_gen d/e), 0 leaving, 0 rc or uhdm-cmp changes, chain away 0 on all 10
(evidence/controls2_summary.txt). The seven case-views exiting 139 (r11u254 F/f04_class e, v11u254 F/vf02_iface e
and vf04_hier e, v11u283 VB/vb06_inst_specific d/e) do so on both binaries. Fix vs law over all 62 control dirs:
8308 case-views, 0 moving (evidence/controls_fix_vs_law_summary.txt).

## The attack (cases/, 123 dirs in both views, every line with its exit code)

Each case names the law it attacks in its first line.
- VN (9): net declaration assignments in for- and if-generates and the module body (`wire [1:0] w = b[P +: 2] |
  2'd0`; § genCaSelBoundNestedOwner282, § caHierSelBoundName282, § genCaSelBoundUnsizedClone282,
  § genCaReplCountInst282, § genCaCastFoldOrphanName282). A net-declaration left side is not a ref_obj, so
  writeCont_assign's bindVariable leg does not apply; every VN case reads the same bytes on both binaries.
- VP (31): process contexts for § genProcOpFoldInPlace282, § genProcIpsBoundInst282, § genProcCatFoldInst282,
  § genProcUnaryFoldInst282, § genProcOpFoldUnaryKeepsInst282 and § genProcFoldTsInstFromSelect282: named begin
  blocks, always_ff with nonblocking assignments, case statements, if conditions, two generate levels, a child
  instantiated twice and with an override, initial blocks, loops, ternaries holding binary operators, parenthesized
  products, call and system-call arguments, a member path select (vp26, the break), left-side bit and indexed part
  selects, casts of operations inside a concatenation, unary operators inside a select index.
- VS (9): the member-path select shapes of the break (§ procSelNameFinal282v).
- VT (14): § tfFoldCaseInsideBoundModule282 in a child instantiated twice and inside a generate loop, an interface
  function, a task called from always_comb and always_ff, unique casez with a list item, a generate-block function
  (stage 1), inside in an if condition and a ternary, a class static function (unmoved), a package function
  (unmoved), header-parameter case items (unmoved), ranges mixing parameters and literals, `case () inside`.
- VC (34): § genCaCastFoldOrphanName282 on literal, typedef, signed and package-parameter casts and an outer whole
  left side; § genCaSelBoundNestedOwner282 with port, variable, array, concatenation, interface-port, implicit
  (forward-declared) and non-ANSI output left sides, a delay, depth-2 overrides, concatenations under operations;
  § caHierSelBoundName282 on two-level member paths, interface ports, unsized right sides, part and indexed
  minus selects, ternaries, variable left sides, children, arrays of structs; § genCaSelBoundUnsizedClone282 with
  an unsized call argument.
- VR (14): replication counts with member-path, interface-port, concatenation and part-select left sides, three
  generate levels, ternaries, nested replications, package and generate-local counts, genvar counts, literal
  counts and module bodies.
- VL (12): left-side indexed part selects with parameter, parameter-operation, genvar, call, cast and ternary
  right sides, an outer target, `-:`, if-generates in a child, genvar bases, three generate levels, unsized right
  sides.

Results (evidence/grid_law.txt, grid_fix.txt, grid_fix_summary.txt):
- law: 246 case-views, 128 moving, 87 entering STRICT_EQUAL, 0 leaving, 0 rc and 0 uhdm-cmp changes, R11U282_OFF =
  pristine on 246 of 246; chain away 0 on 120 movers and away 1 or 2 on the 8 break case-views above
  (evidence/away_law.txt); the positive control (binaries swapped on every seventh mover of the first wave) read
  away 1 to 4 on all 10 (evidence/away_poscontrol.txt).
- fix: the same 128 movers and 87 entering, 0 leaving, chain away 0 on all 128 with 272 records toward golden;
  fix differs from the law only on the 10 member-select case-views; R11V282_OFF = law and R11U282_OFF = pristine
  on 246 of 246.
- Downstream (drivers/dscases.py, every dir, the default view, pristine, law and fix): 121 IDENTICAL, 1
  EQUIVALENT (VC/vc06 a signed cast, stage 1) and 1 DIVERGENT (VC/vc11 an unsized call argument, stage 1) on all
  three binaries; the 369 slang-lane .il / _nohier.il / _synth.v files byte-identical across the three.
- Determinism: two concurrent law runs over all 200 case-views of the first two waves read one hash each.

## Residues standing (all wrong on pristine too)

1. The member-path select in a process (VS vs01, vs02, vs06, vp26): stage 1 on both binaries on a package
   parameter folded in the path, the fold name now toward golden; the part select vs03 and the two-level vs04
   untouched by the law.
2. VP/vp05 (an if condition `a[w] > P + 1`) and vp29 (an if condition and both branches, toward 8 records) still
   read fullname; VC/vc30 (two selects in a ternary that is the whole right side) and VC/vc15 (a member-path left
   side with a member-path right side) unmoved at fullname; VR/vr13 (a generate-local whole left side) at
   fullname; VT/vt07 (a class static function's case item) at fullname.
3. Stage 1 on both binaries, not decoded: VC/vc06 signed cast, vc08 delay, vc11 unsized call argument, vc13
   concatenation left side, vc18 interface body (e), vc32 d, vc34 (moved 1 record toward golden), VN/vn03,
   vn04, vn06 d, VL/vl01 to vl03 (vl02 e reads file), VP/vp17, vp25, VT/vt05, VR/vr14 d.
4. The implementer's residues (r11u282repro/README.md, "The probe residue") stand as written.

## Process

Every corpus path list was filtered by $FENCED (word boundary) before any file was opened (mirror.sh, audit.sh,
the probe and downstream byte comparisons, the controls' find lists); the census ran through the harness filter
built from $FENCED; no fenced source or database was read outside the gate sweeps. Every tool variable was checked
with [ -x ] before use. No other agent's process was listed or signalled; no process was stopped. The main tree was
not written. Slips: the first away-census run on the fresh grid read nothing because the copied case.sh lacked
its execute bit (rerun after chmod, no number from it reported); one record-dump attempt ran strictcmp_x without
$FENCED and it refused.

Drivers (copied from r11u282repro/drivers and pointed at /tmp/v11u282_bin and /tmp/v11u282_gold): env.sh, case.sh,
grid.sh, gridall.sh, gridsum.py, awaygrid.sh, mirror.sh, audit.sh, det.sh, dscases.py; fixsum.py is new.
