# v11u459 — adversarial verification of r11u459 (pass 459, expression/parameter ground)

Base 2f99dba8. Verdict: CONFIRMED with no break and no production change. The
verified patch's src diff is byte-identical to the implementer's /tmp/r11u459.patch.

## Binaries
- pristine: the implementer's frozen base build (md5 d0dfe22c35b7dc0c5d3ab323a4e7a34d,
  equal to the main tree's base build), frozen at /tmp/v11u459_bin/pristine. No pristine
  build and no pristine sweep: the pristine sweep reading is the master's control /tmp/intr11u456.
- law: built once in /tmp/wt_v11u459 (-j 2), md5 efb75a40b10e27254abfe1eabf4e72e6 = the
  implementer's law7, links slang 12.0.0+545f88b2e; frozen at /tmp/v11u459_bin/law.

## The one sweep (law binary, /tmp/sw_v11u459; prediction in evidence/prediction.txt written first)
- probe: EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0 changes=0; csv identical to the control.
- surelog: default 480, testflags 474, 0/0/0; csv identical to the control after path normalization.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0; csv identical.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0; csv identical.
- sv-tests (main tree scripts/check_svtests.py with --baseline the worktree's base
  results/golden_svtests.csv, since the worktree's UVM submodule is empty): EQUAL 1927,
  STRICT_NOTEQUAL 2, DIFFERENT 11, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19,
  SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=1 changes=0. The csv is
  byte-identical to the implementer's law7 sv-tests csv and differs from the control in one row:
      generated/uvm-examples/uvm_ac_config_db.sv,STRICT_NOTEQUAL,differ:fullname(1863),differ:fullname(1863)
  (uhdm-cmp 0 lines on the kept pair, strict fullname=1863). uvm_use_models_pipelined_get_put
  stays DIFFERENT at 56 lines with its head moved from uvm_pkg's foreach loop variable
  (array_var vs golden int_var) to mbus_types_pkg's param_assign at 39:41 (golden a $bits
  sys_func_call, ours a constant); the object shapes at 39:41 are the same on the control
  and the law database, so that face predates the pass; Surelog's values (100/13/99) now
  appear 326 times against golden's 338 (control 145).
- The four corpus stages' command exits 1 on the law-index check alone (this directory added).
- byteverify (SELFCHECK=1) against the control: surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805 (self-checks 961, 1607, 804). Prediction held: no corpus mover.
- canaries ok=52 changed=0, ok=16 changed=0; ctcan2 EXPECT_UNKNOWN=1 and =6 PASS.
- binary audit (fence-filtered): surelog 1523 of 1573 cmds.txt name the law binary (the other
  50 hold only a Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.
- trace (evidence/trace): a traced runner call on the three firing uvm-examples rows gives
  firings identical to the implementer's trace_law7 (ac_config_db 12 and param_vif_config_db 6
  § defFlipUnszBasedRaw459; pipelined_get_put § unitImpTransLateList459 once plus 77
  § pkgBitsTypeEnumZero459). The black-parrot rows were not rerun (SURELOG_CRASH, no golden).

## Reproduction of the implementer's grid
All 58 case dirs of r11u459repro reproduced on exit code, uhdm-cmp count, strict verdict
and moved/same (evidence/impl_grid_repro.txt; md5s differ only by the embedded source path).
Switches (evidence/switchcheck.txt, 105 dirs = 58 + 47 of this grid): R11U459_OFF gives
pristine's bytes on 105 of 105; each of the 72 moved dirs is restored by exactly its own
law's switch (R11U459_DEFFLIPRAW_OFF, R11U459_UNITTRANS_OFF, R11U459_ZEROENUMBITS_OFF).
Earlier grids (evidence/earlier_grids_bytecheck.txt): 1456 case dirs of r11u405, r11u421,
r11u423, r11u425, r11u427, r11u429, r11u431, r11u433, r11u435 and their v11u twins (the
x/z, unsized-based and $bits families the implementer's byte check did not cover):
0 moved, every exit code equal.

## Attack grid (51 fresh case dirs, evidence/grid.txt; every one accepted by upstream slang, every exit code 0 on both binaries)
Goldens: Surelog -parse -nobuiltin -nocache -sv; ours --single-unit --nobuiltin (drivers/run1.sh).
35 moved, 16 byte-identical; every mover closer to golden by path-normalized dump distance
(evidence/dist.txt), none away; 7 to STRICT_EQUAL.

VA — § defFlipUnszBasedRaw459 (13):
- STRICT_EQUAL: va02 (int 'hFF, int unsigned 'h7), va04 (byte 'o17, shortint 'O7), va08
  (interface, two parameterizations), va13 (typedef parameter, two instances).
- closer, head later: va01 (int 'b1 / 'b0; head now the instance copy, golden 32'b1),
  va06 (bit [3:0] 'b0, 16-bit 'B1), va07 (12 bits read by always_ff and a generate-if, 64 -> 17),
  va09 (type-parameter port list), va10 (top-level module with a parameter port list).
- closer, same head: va03 ('sh1f, signed 'sb101: the def listing now 'b101 where golden keeps
  'sb101 and pristine wrote 8'b101), va05 ('b1x0: golden's def listing 255 by the x/z adjust,
  ours 'b1x0, pristine 8'b1x0; 'hz now golden's 'hz).
- byte-identical controls: va11 ('d decimal), va12 (p::D without an import).

VF — § unitImpTransLateList459 (14):
- STRICT_EQUAL: vf03 (body `import pk::Cel` explicit, $unit `import x::Q` explicit).
- head later at the clone ref_var typespec face (12 -> 18): vf04 (an unrelated $unit import
  first), vf05 ($unit import after the module), vf07 (three-level chain), vf13 (string
  properties, function), vf14 (fixed and this.dq arrays, two-level chain).
- vf11, vf12: § pkgVarArrCloneLoopVarTs449's site through the transitive import: vf11
  STRICT_NOTEQUAL type on both, fields 7 -> 2; vf12 18 -> 29 lines with the r::f clone's loop
  variable typespec now golden's unsupported_typespec and the head moved to the shared
  p::f::i listing.
- byte-identical controls: vf01 (import inside a class function), vf02 and vf08 (in-body
  methods), vf06 (export only), vf09 (module-scope import), vf10 ($unit import in x.sv
  declared before pk: the earlier-only rule).

VB — § pkgBitsTypeEnumZero459 (24):
- STRICT_EQUAL: vb08 (assign y = $bits(s) + 1), vb23 (module localparams W/2 read by an
  addition).
- closer: vb01 ($bits(v) of a module variable), vb02 (unpacked array typedef x2),
  vb04 (unpacked struct), vb05 (inline enum member), vb06 (enum alias, (N+7)/8), vb07
  (W-1 range), vb13 (int unsigned, logic [7:0], untyped), vb15 (nested struct), vb16
  (generate loop bound: the parameter now golden's 2; the generate-block count still slang's
  18 on both binaries, so uhdm-cmp 64 -> 1780 lines with the head moved from the parameter
  value to the module_inst listing), vb18 ($bits of a struct-typed parameter), vb19 (typedef
  bounds), vb20 (re-exporting package), vb22 ($bits of a package variable), vb24.
- byte-identical controls: vb03 (packed union, max 32), vb09 (package function return),
  vb10 (class localparam), vb11 (generate-block localparam), vb12 (override actual), vb14
  (<< and $clog2: the evaluator abstains), vb17 (comparison in always_comb), vb21 ($bits of a
  type parameter).
Downstream (ds.one): vb08 DIVERGENT -> IDENTICAL, vb23 EQUIVALENT -> IDENTICAL; vb24 and vb16
EQUIVALENT on both; va07, va13, vf03 IDENTICAL on both.

## Residues (all wrong on pristine too, none moved away)
1. vb24: a module's operand reading an imported package parameter (assign y = x + M) folds
   slang's value (UINT:37) where golden folds Surelog's (UINT:5): the imported-parameter fold
   in ExprEmit does not go through tryFoldConst or psValue459. Also not reached: a generate
   localparam (vb11), a class localparam (vb10), a package function return (vb09), an override
   actual (vb12).
2. vb16: a generate-loop bound folded through such a parameter: golden elaborates 2 blocks,
   slang (and ours) 18 (the elaboration itself follows slang; not writable here).
3. va03 / va05: the flipped def listing of a signed 'sb literal loses the s ('b101, golden
   'sb101) and of an x/z binary golden applies the x/z adjust (255) where ours keeps 'b1x0.
4. va01: the instance copy of int 'b1 (golden 32'b1).
5. vf04/05/07/13/14 and the implementer's ft01/04/08/10: the clone's actual ref_var typespec
   (golden int_typespec, ours unsupported_typespec); vf12's shared p::f::i listing.
6. The implementer's residues 1 to 8 stand as written in r11u459repro/README.md.

## Sister-ground faces
None new beyond the implementer's (§ unitImportHoistsPkgParams146's sys_func_call branch,
§ typedefParentLastWriter134's 1863 fullname objects on uvm_ac_config_db, TypeEmit
makeTypespec's alias-copy bound).

## Process
- Within the budget: one law build, no pristine build, one five-stage sweep, no verified build
  (nothing changed), one traced 3-row runner call, case runs.
- Slips, none affecting a measurement: two quiet-check wait loops and the first sweep launcher
  matched their own command lines with pgrep -f; the launcher refused to start (it printed
  BUSY), the wait loops were stopped by task id; the sweep was then launched from a script file
  after a ps check read quiet. The attack grid's first pass and the earlier-grid byte check ran
  while the master's r11u458 integration sweep was live (timing only, case runs at nice 19).
- The fence list was read into a file by a program without printing it; every tree-wide list
  was filtered on it; no fenced test named, opened or run; no other agent's process touched.
