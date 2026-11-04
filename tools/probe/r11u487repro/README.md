# r11u487 — expression/parameter ground: the elaborated continuous-assignment fold of a parameter read, and dependent parameters under a defparam

Pass 487 of the sv-tests campaign on the expression/parameter ground (src/ParamEmit.cpp only;
ExprEmit.cpp, StmtEmit.cpp, EmitHelpers.h and every sister file unchanged), on base 791b52f7
(pass 485). Measured under the measurement budget: the pristine reading is the master's control
/tmp/intr11u485; no pristine sweep; the worktree's base build is byte-identical to the main tree's
build/slang-uhdm (md5 f6a346fb81377618674f89230eef4973), frozen as /tmp/r11u487_bin/pristine; one
full five-stage sweep on the final binary (law10, md5 9c396cfc89dce21a98410d645b837d9e, slang
12.0.0+545f88b2e); byteverify against the control.

## Verdict

- THE TARGET ROW `generated/uvm-examples/uvm_param_vif_config_db.sv`: re-measured on the
  final binary with the runner (evidence/census_law10_svtests_candidates.csv): JUDGE_EQUAL,
  strict `differ:fullname(3)`, the same three strict objects as at the base, all on the sister's
  ground (pass 478's face (d) and the uvm_reg_map.svh 2034 typespec_member face). No head on
  this ground; no law of this pass fires on it. It stays STRICT_NOTEQUAL.
- So the pass worked the backlog item the brief put first: the continuous-assignment read of a
  dependent or defparam'd parameter (r11u485 DF/df05, v11u483 VO/vo12, v11u485 VF/vf14, plus
  the defparam width face VF/vf04). Decoding them opened a wider and much more basic family:
  `localparam B = A + 1; assign o = B;` with NO override at all is NOT_EQUAL at the base
  (ours puts a typespec on the elaborated fold that golden does not have). Six laws, all in
  ParamEmit.cpp. All four named residues are STRICT_EQUAL on the final binary.
- Grid: 102 case dirs (CT 28, DD 34, BR 16, CW 10, DM 11, CV 3). Pristine STRICT_EQUAL 17,
  NOT_EQUAL 85; law10 STRICT_EQUAL 87, NOT_EQUAL 15. 70 dirs to STRICT_EQUAL, the 17 controls
  byte-identical, none of the 15 left further from golden.
- Away census: 10621 fence-filtered earlier case dirs, 34 movers, all toward golden (23 to
  STRICT_EQUAL or STRICT_NOTEQUAL), no exit code moves, no uhdm-cmp count grows.
- Corpora unchanged: probe 4025 + 62, surelog 954 + 0, uhdm2rtlil 1606 + 0, downstream
  803/66/2/0 and sv-tests 1936/1/3. Every stage reads regressions=0 conversions=0 changes=0,
  and there is no corpus mover, as predicted (the traced census caught one break, which was
  fixed before the sweep).

## Laws (each read through src/LawSwitch.h; R11U487_OFF drops them all)

### § caFoldTsFollowsPa487 (ParamEmit, in patchParamTypespecs; R11U487_CAFOLDTS_OFF; cases CT)

The elaborated continuous assignment whose whole right side reads an UNTYPED parameter of its
own instance (`localparam B = A + 1; assign o = B;`). Surelog's UhdmWriter::writeCont_assign
reduces the read to the parameter's elaborated value, and CompileHelper::adjustSize CLONES a
UINT constant at the left side's width (the rule pass 191 decoded). The copy is a clone of the
parameter's own elaborated param_assign Rhs, so it carries a typespec exactly when that Rhs
does. Golden, measured over the grid (evidence/grid_*.txt; the scratch grids behind them in
evidence/case_origin.txt):

- a literal default `localparam B = 7` keeps the implicit int typespec on both (ct21, ct22);
- a reduced operation `A + 1`, `A | 1`, `A << 1`, `3 + 4`, a conditional, a bare `A` or `(A)`
  has no typespec on the param_assign Rhs and none on the copy (ct01 to ct20), with or without
  an instance override, in a child instance, a body parameter, a top module;
- an INT result (`A - 1`, `A * 2`, `A / 2`, `-A`, `'d7`, `8'd7`) is SHARED by the param_assign
  and the continuous assignment (adjusted in place): golden and ours alike (ct23 to ct25).

ModuleEmit's fold (emitContAssigns, the `pendingParamCloneTs` entries that emitTopPorts
drains) always attached a typespec reference, and the drain's implicit-type branch minted an
int_typespec for it. patchParamTypespecs (ParamEmit) is called from emitTopPorts ahead of that
drain, so the law runs there: for each pending entry whose constant is the Rhs of a
cont_assign directly under a module or interface instance, and whose parameter is an untyped
parameter (no type, no signing, no packed dimension) of that instance's body, it finds the
instance's one param_assign for the parameter. When that Rhs is a constant with no typespec,
the copy's reference is erased (Serializer::Erase) and the entry dropped, so the drain mints
nothing. It only ever drops a typespec and never adds one.

### § caFoldValueFollowsPa487 (same site; R11U487_CAFOLDVAL_OFF; cases CV, DD)

The same copy takes the param_assign Rhs's VALUE masked to its own width when both are UINT.
ModuleEmit wrote slang's value. Golden differs from slang's value in two places: a dependent
under a defparam (§ dpDepPreDefparamValue487 below), and the bare `B = A` of
§ clsOvDepParamOpTree485 (golden reads A's default because Surelog cannot value `K::w`;
v11u483 VO/vo12 = CV/cv01, golden UINT:4 where ours wrote 3). The value is copied only from a
Rhs known to hold the elaborated value: one this pass re-valued, or the Rhs of a parameter no
override reaches. An overridden parameter's Rhs can still be stale where a defparam law
abstained (v11u485 VF/vf17 with `defparam u.A = 'h6`), and law5 to law6 copied it there and
moved the fold away from golden. law7 added this restriction, and vf17 is back on pristine's
bytes.

### § caFoldLhsWidthGrow487 (same site; R11U487_CAFOLDGROW_OFF; cases CW, r11u485 DF/df05)

The fold of an OVERRIDDEN parameter read as a continuous assignment's whole right side
(`parameter logic [3:0] A = 4`, `#(.A(5))`, `assign o = A;` with an 8-bit o). adjustSize
clones a UINT at the left side's width, growing as well as shrinking: golden size 8. ModuleEmit's
override branch only truncates, so ours wrote 4. The same face appears when a defparam'd untyped A
is typed logic [3:0] by slang from `4'd6` (df05). The left side's width comes from its simple
name, looked up in the parameter's instance body, because the ref_obj is not yet bound at this
point in the write phase. Shapes: logic and wire outputs, an int variable, a bit-typed
parameter, two instances (cw01 to cw05). A 16-bit parameter into 8 bits (cw06) already
truncated, and an INT override (cw08) is shared: controls.

### § dpDepPreDefparamValue487 (ParamEmit, end of emitParameters; R11U487_DEPPREDP_OFF; cases DD, v11u485 VF/vf14)

A parameter of an instance whose initializer reads a parameter that a DEFPARAM overrides
(`localparam B = A + 1;` with `defparam u.A = 6;`). Surelog's DesignElaboration values every
parameter of the instance from the instantiation's overrides (or the defaults). Only after that
does it apply the design's defparam table to the targeted param_assign, which is the value
§ ovDefparamWinsValue485 writes. So a dependent keeps the value it had WITHOUT the defparam:

- B = 5 from A's default 4 (dd01), and B = 6 from the instantiation's `#(.A(5))` (dd02);
- the same for every operator (dd03 to dd22), a second dependent `C = B * 2` (dd23), a
  defparam through a level `x.u.A` (dd24), two instances with the defparam on one (dd25), a
  conditional (dd26), and a 'h default (dd28: B and the fold are golden's, A's own
  hex-default param_assign is the older face).

slang applies the defparam before it values the dependents, so ours wrote 7. The law
re-values the dependent's elaborated constant as follows:

- The pre-defparam value of the defparam'd parameter is the instantiation's written actual (read
  from the HierarchyInstantiation syntax, ordered or named) or the declaration default. Only an
  unsized decimal or a based d/h/o/b literal of at most 64 bits is accepted; any other form
  abstains.
- The dependent's bound initializer is re-evaluated over that value by ev487: literals, names,
  implicit conversions, unary, binary and conditional operators, using slang's SVInt
  arithmetic. Any other shape abstains.
- The constant takes the new digits in its own form. UINT or INT, size and typespec are kept,
  and a negative UINT abstains.

An INT dependent's continuous assignment is the same object and follows. A UINT one follows
through § caFoldValueFollowsPa487.

### § bareOvRefUint64_487 (ParamEmit, end of emitParameters; R11U487_BAREOVREF64_OFF; cases BR)

An untyped `localparam B = A;` (or `(A)`) reading a parameter that the INSTANTIATION
overrides. Surelog substitutes the instance's override value, an unsized UINT, so B's
elaborated constant is UINT of size 64 whatever A's declared type: int A, logic [7:0] A, a 4'd4
default (br01 to br08). Ours copied A's width (32, 8). The law fires only when both constants
are UINT. An INT override such as 8'd5 is shared at the reader's width, golden and ours alike
(br09, br10). A non-overridden A keeps A's width (br11, br12).
THE CENSUS BREAK, fixed before the sweep: law9's test for "untyped" accepted an implicit type
with packed dimensions. uhdm2rtlil's func_upto (`localparam [HI:LO] A_CONST = A_VAL;` in an
overridden generate-instantiated module) then went CMP_EQUAL -> CMP_NOTEQUAL in both modes in
the traced census, with 8576 firings. law10 requires no packed dimension and no signing (the
same test in the three fold laws above). func_upto is then byte-identical to pristine, and
BR/br16 (`localparam [7:0] B = A`) is back on pristine's bytes.

### § ovDefparamMaskWidth487 (ParamEmit, inside § ovDefparamWinsValue485; R11U487_DPMASK_OFF; cases DM, v11u485 VF/vf04)

The defparam's value lands in the parameter's declared type. `parameter logic [3:0] A` with
`defparam u.A = 20` reads UINT:4 (20 mod 16) in golden, and the constant keeps size 4.
§ ovDefparamWinsValue485 wrote the written 20. A signed type masks the same way (dm07 UINT:4,
dm11 UINT:8 for 24). The mask applies only to a declared type narrower than 64 bits whose
value the literal exceeds.

## Grid (102 case dirs; evidence/grid_pristine.txt, grid_law10.txt, grid_remaining_dist.txt)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit, real exit code 0 on
102 of 102; the negative control, an undeclared name, reads 1). Every slang-uhdm exit code is 0 on
both binaries. Each dut.sv names its law on its first line.

| group | law | pristine | law10 |
|---|---|---|---|
| CT ct01-ct20 | caFoldTsFollowsPa487 | NOT_EQUAL 17 | STRICT_EQUAL (20) |
| CT ct21-ct26 | (controls: literal default, INT shares, a select left side) | STRICT_EQUAL | byte-identical |
| CT ct27 (generate-block assign), ct28 (interface) | not reached | NOT_EQUAL | byte-identical |
| DD dd01-dd26 | dpDepPreDefparamValue487 (+ the fold laws) | NOT_EQUAL 36/64 | STRICT_EQUAL (26) |
| DD dd27 (defparam 'h6), dd28 ('h default) | dpDepPreDefparamValue487 | NOT_EQUAL, distance 22 / 52 | NOT_EQUAL, distance 4 / 34 (A's own Rhs, older face) |
| DD dd29, dd30 | (controls) | STRICT_EQUAL | byte-identical |
| DD dd31-dd34 (`~A`) | not written | NOT_EQUAL | byte-identical |
| BR br01-br08 | bareOvRefUint64_487 (+ caFoldTsFollowsPa487) | NOT_EQUAL 36 | STRICT_EQUAL (8) |
| BR br09-br12 | (controls) | STRICT_EQUAL | byte-identical |
| BR br13-br16 | not reached ('d5 / 'h5 actuals, 'h4 default, typed B) | NOT_EQUAL | byte-identical |
| CW cw01-cw05 | caFoldLhsWidthGrow487 | NOT_EQUAL 64 | STRICT_EQUAL (5) |
| CW cw06-cw09 | (controls) | STRICT_EQUAL | byte-identical |
| CW cw10 (defparam alone on logic [3:0]) | not reached | NOT_EQUAL | byte-identical |
| DM dm01-dm05, dm07, dm09, dm10 | ovDefparamMaskWidth487 (+ grow) | NOT_EQUAL 64 | STRICT_EQUAL (8) |
| DM dm08 (int A) | (control) | STRICT_EQUAL | byte-identical |
| DM dm06 (defparam alone), dm11 (signed 24) | | NOT_EQUAL, distance 35 / 10 | 35 / 4 |
| CV cv01-cv03 | caFoldValueFollowsPa487 | NOT_EQUAL | STRICT_EQUAL (3) |

Switches (evidence/switches_law10.txt, 102 dirs, rc + md5, every output deleted before its
run): R11U487_OFF gives pristine's bytes and exit code on 102 of 102. Restored to pristine by
one switch alone: CAFOLDTS 22, DEPPREDP 13, CAFOLDGROW 7. The others need two laws together:
BR br01-br08 (CAFOLDTS + BAREOVREF64), the DD fold movers (DEPPREDP + CAFOLDTS/CAFOLDVAL), DM
(DPMASK + CAFOLDGROW), CV (CAFOLDVAL + CAFOLDTS). In each of these, each switch alone moves
the dir to an intermediate state between pristine and the law.

Downstream (evidence/downstream_grid.txt, scripts/downstream_uhdm2rtlil.one on all 102 dirs):
pristine IDENTICAL 58 / EQUIVALENT 44, law10 IDENTICAL 99 / EQUIVALENT 3. 41 EQUIVALENT ->
IDENTICAL, none leaves IDENTICAL.

## Away census (evidence/away_census_list.txt, away_census_bytes_law10.txt, away_census_movers_judged.txt)

10621 earlier case dirs under tools/probe. The 39501 dut.sv paths were fence-filtered by path
and then by content before any other read, keeping those whose source holds `assign` and a
parameter. Each was run on pristine and law10. No exit code moves; 10587 are byte-identical.
The 34 movers were each judged against a fresh Surelog golden with uhdm-cmp, the strict
comparator and the path-normalised dump distance. All 34 are closer to golden (distance down
on every one, no uhdm-cmp count growing): 21 NOT_EQUAL -> STRICT_EQUAL (vf04 on law10; the
law7 judging in away_census_movers_judged.txt reads 20, with vf04 still NOT_EQUAL there), 2
NOT_EQUAL -> STRICT_NOTEQUAL (r11u173verify cx/x06, r11u413 NU/nu05), 11 NOT_EQUAL closer. Among them:
v11u483 VO/vo12, r11u485 DF/df05, v11u485 VF/vf14 and VF/vf04 (law10 only) to STRICT_EQUAL;
r11u421 BF/bf16, PB/pb03-pb05, v11u421 VP/vp01, v11u405 VK/vk01-vk03, v11u278 VK/vk04, vk13,
r11u278 K/k35, r11v131 b01/b04, r11u151 G/g09, v11u401 PU/vs01, r11u415 GL/gl03, r11u413
NU/nu03 to STRICT_EQUAL. The defparam-dir census for the mask law (62 dirs, law7 against law10,
evidence/away_dp_*.txt) moves vf04 alone.

## Prediction and census (evidence/prediction.txt, census_*)

Written before the sweep:
- The traced census of law9 (R11U487_TRACE on) through tests/sweep.sh --corpus "probe surelog
  uhdm2rtlil" gave probe 4025 + 62 with 0/0/0 and surelog 480 + 474 with 0/0/0. In uhdm2rtlil
  func_upto d/t went CMP_EQUAL -> CMP_NOTEQUAL. That was the only trace, the break above, fixed
  in law10, and func_upto is then byte-identical to pristine.
- The traced runner census of law10 covered 302 sv-tests rows: every both-accepting row whose
  own files hold a defparam, or an `assign` together with a parameter, plus the target row. No
  R11U487 firing. The positive control R11U483_TRACE logged § clsScopedOvRhsRefObj483 on
  uvm_param_vif_config_db in the same run.
- Predicted movers: NONE in any stage; the sweep's trace directory predicted empty.

## Sweep (law10, the final binary; evidence/sweep_corpus.log, sweep_svtests_tail.log)

There was one full five-stage sweep, on a quiet machine with R11U487_TRACE on, workdir
/tmp/r11u487swp (the same name length as the control). The probe, surelog, uhdm2rtlil and
downstream stages ran through this worktree's tests/sweep.sh (law index current, rc 0). The
sv-tests stage ran through the main tree's scripts/check_svtests.py with `--baseline` set to
this worktree's results/golden_svtests.csv (rc 0).

- probe: EQUAL 4025, STRICT_NOTEQUAL 62 of 4087; regressions=0 conversions=0 changes=0.
- surelog both modes: regressions=0 conversions=0 changes=0 (default CMP_EQUAL 480, testflags
  474; 954 + 0 judge-equal row-modes; Tnoc d/t CMP_NOTEQUAL standing).
- uhdm2rtlil both modes: CMP_EQUAL 803, CMP_NOTEQUAL 1 (stamped_gen_param), SLANG_REJECT 67 in
  each mode; regressions=0 conversions=0 changes=0 (func_upto CMP_EQUAL, see the census break).
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871; not identical
  and not excused 0.
- sv-tests: EQUAL 1936, STRICT_NOTEQUAL 1, DIFFERENT 3, SURELOG_ONLY 75, BOTH_REJECT 303,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=0 changes=0.
  The target row reads as at the base:

      generated/uvm-examples/uvm_param_vif_config_db.sv,STRICT_NOTEQUAL,differ:fullname(3),differ:fullname(3)

- Every csv equals the master's control /tmp/intr11u485 row for row. That is probe 4087 of
  4087, uhdm2rtlil 1742 of 1742, downstream 871 of 871 and sv-tests 2346 of 2346. In surelog
  it is 1594 of 1596; the other two are the LowMemLib and LowMemPkg testflags log-path texts.
- The sweep's trace directory stayed empty: no law of this pass fired in any process, as
  predicted.
- byteverify against the control (SELFCHECK=1; evidence/byteverify_law10_vs_control.txt):
  surelog 0 of 962 (selfcheck 961/962), uhdm2rtlil 0 of 1608 (1607/1608), downstream 0 of 805
  (804/805). The probe databases, as path-normalised dumps (evidence/probe_dumps.txt), show 0
  of 4087 movers; the unnormalised negative control flags 99 of 99.
- canaries (evidence/canaries.txt): ok=52 changed=0 (surelog) and ok=16 changed=0
  (uhdm2rtlil); ctcan2 EXPECT_UNKNOWN=1 on surelog and EXPECT_UNKNOWN=6 on uhdm2rtlil both PASS.
- binary audit, fence-filtered: surelog 1523 of 1573 cmds.txt name /tmp/r11u487_bin/law10 (the
  other 50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346. No record
  names another slang-uhdm binary.
- NO MOVER in any stage, exactly the prediction.

## Goal 1 (evidence/goal1.txt)

- `C::mk().arr[1]` (r11u423 evidence/residue_cases/g1a) and `u.mk(3).a[2]` (g1b) exit 4 in
  ours and 0 in upstream slang. `this.mk().inner.s` (v11u415 VT/vt03) exits 0 in both. Surelog
  rejects all three (previous passes' measurement), so golden has no shape: not forced.
- All 75 SURELOG_ONLY details of results/golden_svtests.csv are slang front-end `error:`
  diagnostics. None is the exporter's unsupported-shape message.
- bp_unicore alone with the size guard on (§ macroVecLitTokenText403), on law10 after the
  sweep: exit 3 in 15.3 s at 814 MB maximum resident (`basic_string::substr`, the guarded crash
  text). There is no memory-bounded export, so the guard stays and the six black-parrot rows
  stay SURELOG_CRASH.
- generated/rsd/rsd.sv stays SURELOG_CRASH (Surelog dies first): not this ground.

## Residues (all wrong on pristine too; none moved away)

1. uvm_param_vif_config_db: the sister's faces (pass 478's brief), strict fullname(3).
2. `~A` in a dependent (DD/dd31-dd34): golden writes Surelog's unsigned bitwise-not,
   UINT:4294967291 size 32 (UINT:18446744073709551610 size 64 under an override) with the
   fold UINT:251. Ours writes slang's INT:-5, shared. Not written.
3. An unsized based override actual on an untyped parameter with a decimal default (BR/br13
   `.A('d5)`: golden INT:5 size 32, ours size -1; br14 `.A('h5)`: golden HEX:5 'h5 size 32,
   ours INT:5 size -1), and an unsized hex DEFAULT overridden (br15, dd28 A: golden UINT size
   64 with no typespec, ours size 32 with an int typespec; pass 427's OT residue).
4. A typed `localparam [7:0] B = A` under an override (BR/br16): NOT_EQUAL at the base at
   another face (not decoded).
5. A defparam on a parameter with no instance override that slang types logic [3:0]
   (CW/cw10, DM/dm06): the drain's bare vector typespec where golden builds the located
   declaration typespec. ModuleEmit's drain (emitTopPorts' pendingParamCloneTs loop tests
   isOverriddenParam, which a defparam alone does not satisfy). The sister's ground.
6. A defparam value written 'h6 (DD/dd27, v11u485 VF/vf17): golden INT:6 size 8 shared,
   § ovDefparamWinsValue485 abstains.
7. A signed defparam'd parameter's continuous-assignment fold (DM/dm11): ours UINT:0 with the
   decompile -8, golden UINT:8. ModuleEmit's override branch reads slang's negative value. The
   sister's ground.
8. The fold inside a generate block (CT/ct27: golden size 8, ours 64) and in an interface
   (ct28): different emitter sites, not reached.
9. The backlog the brief lists beyond item (a) (dp09, dp22, vd19, vd30, ve03, va56, cc12,
   vn04, vn06, vt11 and the carried lists of passes 485 and earlier): not worked by this pass.

## Sister-ground faces (reported, not written)

- ModuleEmit emitTopPorts' pendingParamCloneTs drain: a defparam'd parameter with no instance
  override gets the loc-less bare vector typespec where golden builds the declaration's (CW/cw10,
  DM/dm06).
- ModuleEmit emitContAssigns' overridden-parameter branch: a negative slang value written as
  UINT:0 with a `-8` decompile (DM/dm11). It also only truncates and never grows; this pass
  writes the grow design-final.
- ModuleEmit's generate-scope continuous-assignment fold (CT/ct27) and the interface one (ct28).

## Process

The IMPLEMENTER within the budget: no pristine build of its own beyond the worktree base build
that had to match the main tree (md5 equal), and no pristine sweep (the master's control was
read instead). Binaries law1 to law10 were used on case runs. There was one traced corpus
census (law9) and one traced sv-tests candidate census (law10), one full five-stage sweep on the
final binary law10, and one byteverify. The corpus stages were swept from the worktree. The
sv-tests stage ran through the main tree's scripts/check_svtests.py with
`--baseline` set to this worktree's results/golden_svtests.csv, because the worktree's UVM
folder is empty.

ITS SLIPS, affecting no measurement: three launches put the quiet-check loop in the same tool
command as a heredoc that spelled the checked script names. Each launcher therefore waited on
its own command line and never started; each was stopped by its task id and relaunched as a
plain `bash <script>`. During the third, the sister r11u480's sv-tests runner was live, and
this pass's runner had not started. The away census's first two runs used law5 and law7, and
the evidence is law10's run.

The fence list was read into a file by a program and never printed. Every tree-wide list (the
away census over 39501 paths, the sv-tests candidate census) was fence-filtered before any
file was opened, and every evidence log was fence-filtered. No other agent's process was
touched.

## Files

- cases/CT (28, § caFoldTsFollowsPa487), DD (34, § dpDepPreDefparamValue487), BR (16,
  § bareOvRefUint64_487), CW (10, § caFoldLhsWidthGrow487), DM (11, § ovDefparamMaskWidth487),
  CV (3, § caFoldValueFollowsPa487).
- drivers: env.sh, runcase.sh (Surelog golden + ours, rc, uhdm-cmp lines, strict verdict, md5),
  grid.sh, switches.sh, upstream.sh, away1.sh (the census), dist.sh (path-normalised dump
  distance), ddiff.sh, elab.sh and elab.py (the elaborated param_assign and cont_assign Rhs of
  a dump, one line each), gpas.sh and pas.py, ds.py (downstream one()).
- evidence: grid_*.txt, switches_law10.txt, upstream_slang.txt, downstream_grid.txt,
  away_census_*.txt, away_dp_*.txt, prediction.txt, census_*, goal1.txt, case_origin.txt, and
  the sweep, byteverify and canary logs.
