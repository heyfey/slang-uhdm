# r11u489 — expression/parameter ground, pass 489

Base 440d37c8 (pass 487). Ground: src/ParamEmit.cpp only (ExprEmit, StmtEmit and EmitHelpers.h
unchanged). Pristine /tmp/r11u489_bin/pristine md5 f5161479d6c35d56a5ab4dae08c33981, the same as the
main tree's build. Law binary /tmp/r11u489_bin/law6 md5 91613eefa1398fab14ca1024d1a9f64a, linking slang
12.0.0+545f88b2e (evidence/binaries.txt).

## Verdict

- sv-tests: NO ROW MOVES. The gate stays ALL CLEAN: EQUAL 1937, STRICT_NOTEQUAL 0, DIFFERENT 3 (the
  known exceptions p733, p737 and tnoc), SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346. regressions=0 conversions=0 changes=0. No target row was open.
- Corpus gates: unchanged, with 0 byte movers (byteverify 0 of 962, 0 of 1608, 0 of 805 against the
  master's control /tmp/intr11u487). Every sweep csv equals the control row for row after path
  normalisation (probe, surelog, uhdm2rtlil, downstream, svtests).
- Pass 487's two findings are closed. The comment is corrected (no byte change), and the width model
  now follows Surelog's unmasked arithmetic: v11u487 VD/vd14 goes NOT_EQUAL -> STRICT_EQUAL (golden
  INT:16, pristine 0).
- Six laws, decoded from Surelog's ExprEval and its defparam application. They take 51 of 61 grid
  case dirs from NOT_EQUAL to STRICT_EQUAL and 10 more earlier case dirs to STRICT_EQUAL. No case
  dir moves away from golden.

## Laws (all in ParamEmit; lawOn(489, ...) from src/LawSwitch.h; R11U489_OFF drops them all)

1. § dpDepUnboundedEval489 (R11U489_UNBOUNDED_OFF). Pass 487's finding (b), inside
   § dpDepPreDefparamValue487. Surelog's ExprEval::reduceExpr adds, subtracts, multiplies and shifts
   64-bit values with no mask to any operand's width. ev489u (the new twin of ev487) values an
   UNTYPED dependent that way. When its value differs from ev487's, the constant takes it if it lies
   in (-2^31, 2^31); a negative value in a UINT constant, or a value out of range, abstains. When
   ev489u cannot value the initializer (a bitwise not, a cast, a negative operand of /, %, a bitwise
   operator or a shift, overflow), ev487's value stands as before. Cases WM wm01 to wm12, DS/ds02,
   and v11u487 VD/vd14 (golden INT:16 where 4'd15 + 4'd1 wrapped to 0).
2. § untypedDepUnboundedValue489 (R11U489_UNBOUNDEDDEP_OFF). The same rule for an instance with no
   defparam: this is the base case, wrong with no override at all. It walks every untyped,
   non-overridden parameter in declaration order, and each value feeds its dependents. A parameter it
   cannot value poisons every reader. Cases WM wm13 to wm16, wm20 and wm04. For example, 4'd0 - 4'd1
   gives INT:-1 (ours 15), 8'd200 + 8'd100 gives 300 (ours 44), and 4'd9 * 4'd2 gives 18 (ours 2).
3. § dpDepBitNegUint489 (R11U489_BITNEG_OFF). Brief item `~A` (r11u487 DD/dd31 to dd34). For
   `localparam B = ~A;`, Surelog's vpiBitNegOp negates the operand constant's 64-bit value, masks it
   to the operand constant's size and writes a UINT of that size. The operand size is read from how
   A's value is written:
   - 32 for an unsized decimal default (nb01);
   - 64 for an unsized decimal actual .A(5) or #(5) (nb02, nb19);
   - the literal's width for a sized literal (nb03, nb04);
   - -1, with no mask, for an unsized based default 'h4 (nb07);
   - the declared width for a typed A's default (int: 32, logic [5:0]: 6; nb08, nb22). A typed A
     with an unsized actual takes 64 (nb21, nb23).

   A defparam on A applies after the dependents are valued (nb05, nb06). slang wrote INT:-5, and
   ModuleEmit's reuse gate shared that constant with the reading continuous assignment. With the
   constant UINT the gate declines, and the clone takes the masked value through
   § caFoldValueFollowsPa487. A clone ModuleEmit writes as an INT (a 32-bit left side, nb15) is
   converted by this law's step in patchParamTypespecs. The law abstains on:
   - a bare-name actual (nb20);
   - a typed B (nb10);
   - ~A + 1 (nb16);
   - any other source form.
4. § dpConstUintForm489 (R11U489_DPUINT_OFF). The elaborated constant of a DEFPARAM'd parameter is
   UINT (vpiConstType 9) in golden, where ours kept the default's 7 or 5 (DS ds03, ds04, ds07). An
   untyped parameter with a sized default (its constant has no typespec) and an unsized decimal
   defparam value gets the unsized UINT of size 64 (ds01, ds02, ds05, and WM wm01 to wm12 for A).
   Only a decimal defparam value, unsized or sized 'd, re-types the constant. LAW5 ALSO
   RE-TYPED A BASED OR NAMED VALUE, and the away census caught it moving v11u407 VX/vx05
   (4'b10x0; distance 6 -> 27) and v11u279 VA/va03_defparam (p::D2; 145 -> 161) away from golden,
   plus r11u427 OT/ot10 and v11u427 VD/vd05. law6 restricts the re-type to decimal values, and all
   four are back on pristine's bytes (evidence/away_defparam_law5_vs_law6.txt: exactly those 4 of 149
   defparam dirs move between law5 and law6).
5. § unboundedAddSize489 (R11U489_ADDSIZE_OFF). The size of a constant that laws 1 and 2 re-value
   or check. Surelog's vpiAddOp and vpiSubOp size is the larger operand size. When every leaf is a
   sized literal, a parameter whose value comes from a sized literal, or an earlier dependent of
   this shape, through + and - only, the size is slang's self-determined width (4 where ours wrote 64
   or -1). Cases wm09, wm10, wm15, wm19, ds02.
6. § ovSizedActualSize489 (R11U489_OVSIZED_OFF). An untyped parameter with a sized default,
   overridden by its instantiation with a sized literal:
   - a 'd actual is INT of its width (os01, os05, os06; ours -1);
   - a 4'hE actual is HEX:E with the decompile 4'hE and size 4 (os04; ours INT:14 size -1).

   A continuous assignment then shares and resizes it as golden does (os07). An unsized default or
   actual is already golden's (os02, os03, os08: controls). Also wm17.

The pass 487 comment (§ dpDepPreDefparamValue487) now states what lit487 reads: an unsized
decimal, or a d, h, o or b based literal, unsized or sized up to 64 bits, digits only. This is a
comment-only change.

## Grid (evidence/grid_pristine.txt, grid_law6.txt, upstream_slang.txt, downstream_grid.txt)

There are 61 case dirs in DS (8), NB (25), OS (8) and WM (20). Every case's first line names its
law. Every case is accepted by upstream slang (61 of 61 at exit 0; negative control exit 1). Every
exit code is 0 on both binaries.

| | pristine | law6 |
|---|---|---|
| STRICT_EQUAL | 6 | 57 |
| NOT_EQUAL | 55 | 4 |

The 6 controls (ds06, ds08, os02, os03, os08, wm18) stay STRICT_EQUAL. Of the four left
NOT_EQUAL, three are byte-identical to pristine (nb10, nb16, nb20). nb24 (an interface) is closer:
uhdm-cmp 36 -> 31 and dump distance 18 -> 12, at the interface continuous-assignment emission.

Downstream on all 61 (harness ds.one): law6 is IDENTICAL on 61. Pristine reads IDENTICAL 30,
EQUIVALENT 16, DIVERGENT 1 and STATUS_DIFF 14, where the slang lane's Yosys READ_FAIL on pristine's
INT-typed UINT constants. No case leaves IDENTICAL.

Switches (evidence/switches_law6.txt, switch_summary.txt):
- R11U489_OFF gives pristine's bytes and exit code on 61 of 61.
- Each switch alone moves only its own law's cases. For example, DPUINT: the DS and the defparam WM
  cases; BITNEG: the NB cases.
- ds02 and wm01 to wm12 need laws 1 and 4 together, and ds02, wm09 and wm10 need law 5 too.

## Away census (evidence/away_census_list.txt, away_census_bytes_law5.txt, away_movers_judged_*.txt)

There are 34110 dut.sv case paths under tools/probe outside this pass. They were fence-filtered by
path and then by content before any other read, and the 15245 holding parameter, localparam or
defparam were each run on pristine and law5. No exit code moved, and 16 dirs moved bytes. Each
mover was judged against a fresh Surelog golden.

On law5, 2 movers went AWAY: v11u407 VX/vx05 and v11u279 VA/va03_defparam. These are the break
fixed as law 4 above.

On law6, 12 movers are closer and 4 are restored to pristine's bytes:
- to STRICT_EQUAL: r11u487 DD/dd31, dd32, dd33, dd34; v11u487 VD/vd14, vd22, VG/vg11, VT/vt04;
  v11u477 VA/va27;
- closer at the same verdict: r11u487 DD/dd28 (distance 34 -> 32), v11u423 VD/vd08 (uhdm-cmp 36 ->
  28, distance 8 -> 4) and v11u477 VA/va09 (distance 8 -> 6);
- restored to pristine's bytes: r11u427 OT/ot10, v11u279 VA/va03_defparam, v11u407 VX/vx05 and
  v11u427 VD/vd05.

The law5 -> law6 change only narrows a branch. The 149 defparam dirs were re-run law5 against law6,
and exactly those 4 move.

## Prediction and census (evidence/prediction.txt, census_law6.txt)

The prediction was written before the sweep from a traced run of law6 (drivers/census.py). It covers
every fence-filtered row of the probe, surelog, uhdm2rtlil and sv-tests, using each row's control
command. No law fired on any corpus row or probe case. Surelog 954 of 954, uhdm2rtlil 1606 of 1606
and the 24 kept sv-tests databases were byte-equal to the control. One sv-tests row,
generated/rsd/rsd.sv (SURELOG_CRASH), traced two abstains of law 2 (abstainRange DATA_MINUS_ONE,
DATA_MINIMUM) with its bytes the control's. The sweep's trace (evidence/sweep_trace.txt) holds
exactly those two lines. Predicted: 0 movers. Observed: 0 movers.

## The sweep (one, on the final binary law6, trace on; evidence/sweep_corpus.log, sweep_svtests.log)

The probe, surelog, uhdm2rtlil and downstream stages ran from the worktree. The sv-tests stage ran
through the main tree's tests/sweep.sh, since the worktree's UVM folder is empty; it exits 1 on the
main tree's stale law index alone.

| stage | result | regressions / conversions / changes |
|---|---|---|
| probe | EQUAL 4026, STRICT_NOTEQUAL 61 | 0 / 0 / 0 |
| surelog | default CMP_EQUAL 480, testflags 474 | 0 / 0 / 0 |
| uhdm2rtlil | 803/1/67 in both modes | 0 / 0 / 0 |
| downstream | 803 IDENTICAL / 66 / 2 / 0, not excused 0 | — |
| sv-tests | as in the verdict above | 0 / 0 / 0 |

- byteverify (SELFCHECK=1) against the control: 0 of 962, 0 of 1608 and 0 of 805. The self-check
  flags 961, 1607 and 804.
- canaries: ok=52 and ok=16, and both ctcan2 checks PASS.
- Binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name law6, and the other 50 hold only
  a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346. No other slang binary appears.

## Goal 1 (evidence/goal1.txt)

Unchanged:
- The probe faces C::mk().arr[1] and u.mk(x).a[2] (r11u423 g1a, g1b) exit 4 on ours and 0 on
  upstream slang.
- this.mk().inner.s (v11u415 VT/vt03) exits 0 on both. Surelog rejects all three, so there is no
  golden shape to write.
- All 75 SURELOG_ONLY details are upstream slang diagnostics, with 0 unsupported-shape details.
- bp_unicore alone on law6 with the size guard on: exit 3 in 14.1 s at 828 MB maximum resident
  (basic_string::substr). There is no memory-bounded export, so the guard stays.

## Residues (ranked; all wrong on pristine too, none moved away)

1. A bare-name override actual under `~A`, .A(P): golden reads P's own constant size 32 (nb20). The
   law abstains.
2. `~A + 1` (nb16): golden UINT 4294967292 of size 64, where the unsized literal is size 64 in
   Surelog's operation. This needs the operand-size model of a UINT operation; not written.
3. A typed `localparam [7:0] B = ~A` (nb10): golden UINT:251 with the typespec. It abstains (and
   brief item br16, the typed B, is the same family).
4. The interface continuous-assignment emission under `~A` (nb24): closer, at the interface fold.
   ModuleEmit's ground.
5. The rest of the brief's backlog, not worked by this pass:
   - from pass 487: br13 to br15, vb29, dd27/vf17, vd13, vd10, vd11, ct27, ct28, vd08, vb04, vg08,
     vg05;
   - from pass 485: dp09, dp22, vd19, vd30, ve03, va56, cc12, vn04, vn06, vt11;
   - the carried lists of passes 485 and earlier.
6. p733, p737 and tnoc: KNOWN EXCEPTIONS (user 2026-11-02), staying DIFFERENT.

## Sister-ground faces (reported, not written)

- ModuleEmit's interface continuous-assignment fold of a parameter read (nb24; emitInterfaceInstance
  / emitContAssigns on an interface_inst).
- ModuleEmit's reuse gate for § elabCaReusesParamValueConst (the `pcR9->VpiConstType() !=
  vpiUIntConst` test) decides sharing from the constant's type. This pass sets that type in
  ParamEmit before the gate reads it, so that no ModuleEmit edit was needed.

## Process

- The implementer stayed within the budget: law1 to law6 on case runs, one away census (law5) plus
  its 149-dir defparam re-run, one traced census, one full five-stage sweep on the final law6, and
  one byteverify. No pristine sweep was run; the master's control was read.
- The away census overlapped the sister r11u482's sv-tests stage (nice'd case runs; timing only).
- Two of this pass's own wait loops matched their own command line with pgrep -f and never
  returned. They were stopped by task id; no other process was touched.
- The sweep launcher checked for a quiet machine inside itself, with a pattern that does not match
  its own name.
- The fence list was read into a file by a program and never printed. Every tree-wide list was
  path- and content-filtered on it first, and the repro folder scans clean.

Drivers: drivers/env.sh, runcase.sh, grid.sh, dist.sh, ddiff.sh, switches.sh, away.sh, away1.sh,
census.py.
