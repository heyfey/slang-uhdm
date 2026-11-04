# v11u489 — adversarial verification of r11u489 (expression/parameter ground, pass 489)

Base 440d37c8 (pass 487). Implementer's patch /tmp/r11u489.patch applied clean on a fresh 440d37c8
worktree (/tmp/wt_v11u489). Production surface: src/ParamEmit.cpp only (617 lines added, 4 removed).

## Verdict

CONFIRMED, NO BREAK, NO PRODUCTION CHANGE. The verified patch's src diff is byte-identical to the
implementer's. No sv-tests row, corpus row or probe case moves; every csv of the law sweep equals the
master's control (/tmp/intr11u487) row for row after path normalisation, byteverify 0 movers in every
corpus. The attack grid (128 fresh case dirs, all accepted by upstream slang, every exit code 0 on both
binaries) finds no dir further from golden than pristine, no STRICT_EQUAL lost and no downstream verdict
leaving IDENTICAL. Two findings that are not breaks (below).

## Binaries (evidence/binaries.txt)

- pristine /tmp/v11u489_bin/pristine md5 f5161479d6c35d56a5ab4dae08c33981 (frozen copy of the main
  tree's build, no pristine build of mine, per the budget)
- law /tmp/v11u489_bin/law md5 91613eefa1398fab14ca1024d1a9f64a, rebuilt once from the patch, EQUAL to
  the implementer's law6; links slang 12.0.0+545f88b2e
- no verified build (nothing to refine)

## Gates on the law binary (one five-stage sweep, /tmp/v11u489swp, trace on)

- probe: EQUAL 4026, STRICT_NOTEQUAL 61 of 4087, regressions=0 conversions=0 changes=0
- surelog: default CMP_EQUAL 480, testflags 474, regressions=0 conversions=0 changes=0
- uhdm2rtlil: 803/1/67 in both modes, regressions=0 conversions=0 changes=0
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0
- sv-tests (scripts/check_svtests.py from the main tree with SVTESTS_ROOT, the worktree's UVM folder
  being empty): EQUAL 1937, DIFFERENT 3 (p733, p737, tnoc: known exceptions), SURELOG_ONLY 75,
  BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0
  changes=0
- every csv (probe, surelog, uhdm2rtlil, downstream, svtests) equal to the control's row for row
  after path normalisation (0 diff lines each)
- byteverify against the master's control, SELFCHECK=1: 0 of 962, 0 of 1608, 0 of 805 (negative
  controls 961/962, 1607/1608, 804/805 flagged); evidence/byteverify_law_vs_control.txt
- canaries ok=52 and ok=16, both ctcan2 checks PASS (evidence/canaries.txt)
- the sweep's trace (evidence/sweep_trace.txt) is exactly the implementer's prediction: two
  § untypedDepUnboundedValue489 abstainRange lines on rsd (SURELOG_CRASH), no firing anywhere else
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt naming the law binary, the other 50
  holding only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346

## Reproduction of the implementer's numbers

- its 61 grid dirs (DS, NB, OS, WM): exit code, uhdm-cmp count and strict verdict reproduced line for
  line on both binaries (evidence/impl_grid_*.txt): pristine STRICT_EQUAL 6 / NOT_EQUAL 55, law 57 / 4
- its 16 away movers re-judged (evidence/impl_away_movers_rejudged.txt): 9 NOT_EQUAL -> STRICT_EQUAL
  (r11u487 DD/dd31 to dd34, v11u477 VA/va27, v11u487 VD/vd14, vd22, VG/vg11, VT/vt04), 3 closer at
  the same verdict (r11u487 DD/dd28 34 -> 32, v11u423 VD/vd08 8 -> 4, v11u477 VA/va09 8 -> 6), and
  4 byte-identical to pristine (r11u427 OT/ot10, v11u279 VA/va03_defparam, v11u407 VX/vx05,
  v11u427 VD/vd05)
- pass 487's finding (b): v11u487 VD/vd14 NOT_EQUAL (dist 8) -> STRICT_EQUAL
- goal 1 (evidence/goal1.txt): r11u423 residue cases g1a and g1b (C::mk().arr[1], u.mk(x).a[2]) exit 4
  on both binaries and 0 in upstream slang; v11u415 VT/vt03 (this.mk().inner.s) 0 on all; 0 of 75
  SURELOG_ONLY details name an unsupported shape. bp_unicore not re-measured.
- switches (evidence/switches.txt): R11U489_OFF gives pristine's bytes and exit code on 189 of 189
  dirs (my 128 and the implementer's 61); 145 of them move under the law and every one is restored by
  at least one single law switch (OVSIZED 17, UNBOUNDEDDEP 34, BITNEG 45 + 14, UNBOUNDED 11,
  DPUINT 33, ADDSIZE 22 + 1 dirs moving when that switch alone is set), none unattributed

## Away census (fence-filtered)

The implementer covered 15245 dirs (tools/probe dirs whose sources hold "param"). I ran the
complement: every tools/probe dir with a dut.sv whose sources hold "param" (18920 after the fence
filter, its positive control flagging a planted fenced path) minus the implementer's 15245 = 3675
dirs (evidence/away_census_complement*.txt): no exit code moves (3634 rc 0, 38 rc 3, 2 rc 4, 1 rc 139
on both binaries) and 0 byte movers; positive control r11u487 DD/dd31 and v11u487 VD/vd14 both flag.

## Attack grid: 128 case dirs in VU, VN, VD, VO, VS (cases/, every first line names the law)

All accepted by upstream slang (checked with the real exit code; the first drafts of VU/vu23, vu34
and VO/vo14 were rejected by upstream slang and rewritten), every exit code 0 on both binaries.

| binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 13 | 1 | 114 |
| law | 76 | 2 | 50 |

Downstream (128 dirs): pristine IDENTICAL 56 / EQUIVALENT 57 / DIVERGENT 1 / STATUS_DIFF 14; law
95 / 32 / 0 / 1 (VD/vd04 STATUS_DIFF on both). No dir leaves IDENTICAL; no dir's dump distance grows;
the 13 pristine STRICT_EQUAL dirs stay STRICT_EQUAL.

Groups and the law each attacks:
- VU (§ untypedDepUnboundedValue489, § dpDepUnboundedEval489 for vu39): mixed-sign comparisons
  (vu01, vu02, vu41 to vu45: the law abstains, our right side not being a plain constant), conditional,
  divide, shift, unary minus, logical not, multiply, chains, typed readers, a child override .X(B),
  a function return, a generate-if, an initial $display, a package, a generate block, an interface, a
  class, a program, a nested module, the uninstantiated top. To STRICT_EQUAL: vu06, vu07, vu09, vu13,
  vu15, vu16, vu18, vu20, vu23, vu25, vu29, vu30, vu31, vu33, vu37, vu46; vu27 to STRICT_NOTEQUAL
  (dist 24 -> 18).
- VN (§ dpDepBitNegUint489): readers (always_comb, port connection, B + 1, if, a select), defaults
  4'hF, 'b101, 0, 64'd5, 4'sd5, typed logic [7:0], integer, signed, interface, defparam on A, two
  instances, overridable B, top-level localparam A. To STRICT_EQUAL: vn01 to vn08, vn10 to vn13, vn15,
  vn18, vn20, vn22 to vn26, vn28, vn29, vn33.
- VD (§ dpConstUintForm489): int, [3:0] typed, defparam 0, 'd6, 4'd6, 64'd6, 300, readers, a
  two-level and a generate-scope defparam, 8'hFF default, an override plus a defparam, two instances,
  an interface, 'd4 and 4'sd4 defaults. To STRICT_EQUAL: vd03, vd05, vd06, vd08 to vd10, vd12 to vd14,
  vd16.
- VO (§ ovSizedActualSize489): lowercase 4'he, 8'h0F, 4'D3, ordered #(4'd3), readers, an override plus
  a defparam. To STRICT_EQUAL: vo01, vo02, vo05, vo07, vo09, vo10, vo11, vo13.
- VS (§ unboundedAddSize489): mixed widths, 40'd5 actual, chained sums, a wrapping subtract. To
  STRICT_EQUAL: vs02, vs04, vs06, vs09, vs10.

Dirs whose bytes move with the verdict and distance unchanged or closer (checked object by object, none
moving a cell away from golden): VU/vu17 (uhdm-cmp 36 -> 64 with the head moving later from B's
param_assign to the typed C's continuous-assignment clone, dist 10 -> 4), VU/vu28 (36 -> 128, head
moving later to the generate scope slang chose from its own wrapped value, dist 36 -> 30), VU/vu24 (the
continuous-assignment constant 15 -> -1 where golden keeps the unreduced operation, dist 56 both),
VD/vd15 (the defparam'd 4'sd4 constant now UINT and no longer shared with the reader as golden, its
size 8 -> 4 where golden writes 64, dist 21 both), VN/vn21, vn27, vn30, vn32, vn34 to vn39 (finding 1).

## Findings that are not breaks

1. § dpDepBitNegUint489's typed-A branch with a SIZED literal default writes the declared width
   where golden uses another: decimal or binary sized literals in a logic, bit, reg or implicit
   vector A keep the literal's width in golden (bit [7:0] A = 4'd4 golden UINT:11 size 4, the law
   UINT:251 size 8: VN/vn21, vn30, vn32, vn36, vn37, vn39; logic [3:0] A = 8'd4 golden 251 size 8,
   the law 11 size 4: vn27; 12'd4 golden size 12: vn38), integer A = 8'd4 reads size 8 (vn34) and
   logic signed [7:0] A = 4'd4 reads 4294967291 size 32 (vn35), while hex and octal sized literals,
   int and same-width literals follow the declared width as the law writes (vn26, vn28, vn29, vn33,
   vn40 STRICT_EQUAL). Pristine was wrong on all ten (the same value at size 64) at the same dump
   distance, so no cell moves away; the README's "the declared width for a typed A's default" holds
   only for unsized decimal defaults and the shapes above. The next pass may abstain there or write
   golden's rule after decoding it.
2. lit487's comment, and the corrected § dpDepPreDefparamValue487 comment quoting it, say "sized up
   to 64 bits", but the reader also rejects more than 16 digits, so a 64-bit binary literal written
   with all its digits abstains; the comment claims slightly more than the code.

## Residues (all wrong on pristine too; none moved away)

- VU/vu39: with a defparam on ANY parameter of the instance, § untypedDepUnboundedValue489 does not
  run (it runs only where § dpDepPreDefparamValue487 did not walk) and that walk re-values only the
  defparam'd parameter's dependents, so B = A + 4'd1 stays slang's wrapped 0 (golden 16).
- VU/vu28: a generate-if over a re-valued parameter: slang elaborated the other branch, the head now
  the generate scope (not writable from the exporter).
- typed readers of a re-valued parameter (vu17's localparam [7:0] C = B, vu22, vu19's B + 1, vu10 and
  vu38's ranges [B-1:0]), operation trees golden keeps unreduced (vu24), vu08 (two instances, closer),
  vu26 (1 << 31, abstainRange).
- § ovSizedActualSize489 not reaching: two instances with different actuals (VO/vo06), a generate-loop
  instance (vo14), an interface instance (vo08), a signed 4'sd3 actual (vo15), a binary actual (vo03).
- interface folds (VN/vn09, VU/vu11, VD/vd11: closer, uhdm-cmp 36 -> 31; ModuleEmit's interface
  continuous-assignment fold, the sister's, as the implementer's nb24).
- VD/vd02, vd07, vd15, vd17 closer but not equal; VD/vd04 STRICT_NOTEQUAL on both.
- VN/vn16 (C = B over ~A, closer), vn17 (4'sd5 default), vn19 (B in a range, closer); VS/vs03 (B in
  a range, closer), vs07 (4'd3 - 4'd5, closer); package, generate-block and class parameters (VU/vu04,
  vu05, vu32, vu35) untouched.

## Sister-ground faces

None new beyond the implementer's (ModuleEmit's interface continuous-assignment fold).

## Process

- Within the budget: one law build (md5 equal to the implementer's), one five-stage sweep on it, no
  verified build and no second sweep (no refinement), one byteverify against the master's control.
- The sweep launcher waited inside itself (pattern anchored on the sweep processes, not on its own
  name) for the sister v11u482's sweep to end; my attack-grid case runs, switch runs, downstream case
  runs and the nice'd away census overlapped the sister's sweep and my own corpus stages (timing
  only; my sv-tests stage and its own TIMEOUT row read as the control).
- The fence list was read into a file by a program and never printed; every tree-wide list was
  filtered on it first; the repro folder scans clean. No other agent's process touched; no fenced
  test named, opened or run.
