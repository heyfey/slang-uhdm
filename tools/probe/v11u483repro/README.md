# v11u483 — adversarial verification of r11u483

Verifier of pass 483 (expression/parameter ground: src/ParamEmit.cpp and src/ExprEmit.cpp) on base
fc1624b5a. VERDICT: CONFIRMED WITH TWO BREAKS FIXED. The implementer's numbers reproduce bit for bit; its two
laws hold on every corpus row, probe case and sv-tests row; the attack grid found two shapes on legal SV that
upstream slang accepts where the law moved a database AWAY from golden (dump distance growing, uhdm-cmp head
changing), both fixed behind their own switches in the same two files. The verified binary is byte-identical
to the law binary on every corpus, probe, sv-tests and away-census database; it differs only on the three
attack dirs the fixes target.

Binaries (frozen under /tmp/v11u483_bin before any measurement): pristine = a copy of the main tree's
build/slang-uhdm (md5 20763fbe4439f89a287c3cf3a5128eb6); law = /tmp/r11u483.patch applied to a fresh
fc1624b5a and built (md5 db70b390505c7fdbef10fa1c0805c3a6, equal to the implementer's law2, slang
12.0.0+545f88b2e); ver1 (md5 11aa66c6..., the first refinement only, used on case runs and the away census
only); ver = the delivered verified binary (md5 231e2289ac49c8b28d225444a3ad2c51).

## Target rows (before -> after), reproduced

- generated/uvm-examples/uvm_param_vif_config_db.sv: DIFFERENT -> STRICT_NOTEQUAL on the law AND on the
  verified binary (CONVERSION in both sweeps):

      generated/uvm-examples/uvm_param_vif_config_db.sv,STRICT_NOTEQUAL,differ:fullname(2),differ:fullname(2)

  uhdm-cmp 46 -> 0 lines (pristine's first difference: interface_inst SFR_MASTER's param_assign, golden
  ref_obj SFR::sfr_addr_width against our constant UINT:16). The implementer's README says 172 -> 0; its own
  evidence file row_pvc_uhdmcmp_pristine.txt holds 46 lines, and 46 is what this base reads (172 was the
  count before pass 474 landed): a README slip, no measurement affected. Strict remainder on the verified
  binary (evidence/row_pvc_strict.txt): #93329 fullname, the ref_typespec under set_arbitration's formal val
  (golden sfr_agent_pkg::..., ours sfr_test_pkg::...), then the walk diverging at #138364 (golden int_var pos
  at uvm_misc.svh 103:7, the tb_params_pkg clone binding): the sister's two module/type faces, as claimed.
- generated/easyUVM/top.sv: DIFFERENT, unchanged, no law firing (the trace names only the two rows below).

## The two breaks and their fixes

### § clsOvDefparamAbstain483v (ParamEmit; R11V483_DEFPARAM_OFF; cases VO/vo13, vo20; controls vo18, vo19)

A parameter overridden by a named class-scoped actual AND targeted by a defparam (`m #(.A(K::w)) u(o);
defparam u.A = 6;`, and through a level, `defparam x.u.A = 7;`): golden's elaborated Rhs is the defparam's
value constant (UINT:6), pristine wrote a constant with the wrong value (UINT:3, dump distance 4, uhdm-cmp 64
lines), the law wrote the ref_obj K::w (dump distance 43). A move away from golden on legal SV that upstream
slang accepts. The fix abstains when the instance body's hierarchyOverrideNode (the map slang's
ParameterBuilder reads for a defparam) holds the parameter's declarator: vo13 and vo20 back on pristine's
bytes; a defparam on another parameter of the same instance (vo18) or on another instance (vo19, STRICT_EQUAL
on the law) keeps the law. Downstream EQUIVALENT on all three binaries for vo13 and vo20.

### § ifaceValNestedModAbstain483v (ExprEmit; R11V483_NESTMOD_OFF; case VI/vi25)

An interface instance read as a value in a module DEFINED INSIDE another module (`module top; module inner;
ifc u(clk); virtual ifc g; initial g = u; endmodule inner i1(); endmodule`): golden binds the ref_obj to the
elaborated interface_inst work@top.i1.u and mints no wire; pristine left it unbound (uhdm-cmp 139, distance
13); the law minted a net named work@top.work@top::inner.u under the nested definition (uhdm-cmp 274, distance
20). The fix abstains when the definition's parent scope is an instance body: vi25 back on pristine's bytes
(writing golden's interface_inst binding is left as a residue). Downstream IDENTICAL on all three binaries.

Switches (evidence/switches_ver.txt, 96 dirs: 48 attack + the implementer's 48): R11V483_OFF gives the law's
bytes on 96 of 96; R11U483_OFF gives pristine's bytes on 96 of 96; R11V483_DEFPARAM_OFF alone restores exactly
vo13 and vo20, R11V483_NESTMOD_OFF alone exactly vi25. On the law binary (evidence/switches_law.txt, 90 dirs at
the time): R11U483_OFF = pristine on all; every mover restored by exactly one of R11U483_CLSOVRHS_OFF and
R11U483_IFACEVALNET_OFF.

## Attack grid (48 fresh case dirs, evidence/grid_*.txt, grid_table.txt)

Every case accepted by upstream slang (~/.local/bin/slang --single-unit, real exit code read; five drafts it
rejected were dropped: an instance in `$display("%p", u)`, a read before the instance's declaration, a
conditional `c ? u2 : u1`, `$dumpvars(0, u)` and a generic class `K::w` without parameters). Every exit code 0
on all three binaries. Columns: uhdm-cmp lines / path-normalised dump distance / verdict.

- VO (23, § clsScopedOvRhsRefObj483 and its fix): an enum constant K::RED (vo01, closer 65 -> 21 at an older
  class-typedef head), a class localparam (vo02), a typedef of a specialization `typedef C#(9) K;` (vo04),
  two instances of a middle module importing the class's package (vo05), two class-scoped overrides (vo06,
  older head), `K :: w` with spaces (vo07: STRICT_NOTEQUAL endcol, golden ending the span after `::` where the
  law ends at the member name: a residue), a macro actual (vo08), a string parameter (vo09), a generate-if
  selected by the override (vo10: golden takes the default branch since Surelog cannot value K::w; head
  later, uhdm-cmp 46 -> 128 with dump distance 45 -> 30), generate-if instances (vo11), a port-list
  `localparam B = A` (vo12, the dependent-parameter residue), defparam shapes (vo13, vo18 to vo20), a logic
  vector parameter (vo14, older head), two parameterized middle instances (vo15), an interface override in a
  child module (vo16), a non-ANSI body parameter (vo17), a nested module definition (vo21), an inherited
  class parameter (vo22), an interface used as a port (vo23, closer).
- VI (25, § ifaceInstValueImplicitNet483 and its fix): statement task call tk(u) (vi01), void'(f(u)) (vi02),
  if condition (vi03), fork (vi04), two parameterized instances of a child (vi05), operand and nonblocking
  (vi06), a statement call inside if/else (vi07), a parameterized interface (vi08, older endcol head), assert
  (vi09), a function returning u (vi10, older col head), two instances with an earlier continuous-assign
  implicit net (vi11), an array element g[0] = u (vi12, closer), a process in a generate block (vi13,
  byte-identical), `default_nettype tri (vi14: closer, golden vpiNetType 4 where the mint writes 1: a
  residue), wait (vi15), two processes (vi16), task and direct read (vi17), a class method call d.set(u)
  (vi18), for and if (vi19), a case item (vi20), a child's automatic task (vi21), constructor plus named block
  (vi22), queue push (vi23, closer), a modport virtual interface (vi24), the nested module (vi25), a child
  under a generate loop (vi26).

Tally: pristine STRICT_EQUAL 1, NOT_EQUAL 47; law STRICT_EQUAL 32, STRICT_NOTEQUAL 3, NOT_EQUAL 13; verified
STRICT_EQUAL 32, STRICT_NOTEQUAL 3, NOT_EQUAL 13. Dump distance growing against pristine: 3 dirs on the law
(vi25, vo13, vo20, the breaks above), 0 on the verified binary. Downstream (evidence/downstream_*.txt) on the
41 + 8 dirs measured: none leaves IDENTICAL on any binary; 15 EQUIVALENT -> IDENTICAL (vo01, vo02, vo04 to
vo09, vo11, vo12, vo14, vo15, vo17, vo19, vo22).

## Reproduction of the implementer's numbers

- Grid: its 48 dirs on pristine, law and verified (evidence/impl_grid_*.txt): exit code, uhdm-cmp count and
  verdict identical to its grid_pristine.txt and grid_law2.txt on 48 of 48 lines each (md5 columns differ
  only by the embedded checkout path); pristine 5 / 1 / 42 and law 37 / 1 / 10 STRICT_EQUAL / STRICT_NOTEQUAL /
  NOT_EQUAL; the verified binary byte-identical to the law on all 48.
- Away census (evidence/away_census_pris_law_ver1.txt, away_census_law_ver.txt, away_movers_golden.txt): 8537
  fence-filtered case dirs under tools/probe whose dut.sv holds defparam, interface, virtual or a named
  parameter assignment (a wider list than the implementer's 562), pristine, law and ver1, then law and ver:
  no exit code moving (8455 exit 0, 65 exit 3, 17 exit 4 on every binary); 31 pristine -> law movers, all
  toward golden by dump distance, 20 to STRICT_EQUAL: the implementer's 30 plus v11u410 VV/vv01 (NOT_EQUAL 254
  -> STRICT_EQUAL), which its narrower list missed; law -> verified movers 0 of 8537.
- Sweeps: one full five-stage sweep on the law binary and one on the verified binary (tests/sweep.sh --jobs 3
  from the worktree for probe, surelog, uhdm2rtlil and downstream; the sv-tests stage through the main tree's
  tests/sweep.sh since the worktree's UVM folder is empty), run one after the other with no other sweep live,
  R11U483_TRACE on. Both read: probe EQUAL 4024 + STRICT_NOTEQUAL 63, 0/0/0; surelog default CMP_EQUAL 480 and
  testflags 474, 0/0/0; uhdm2rtlil 803/1/67 in both modes, 0/0/0; downstream IDENTICAL 803, SLANG_REJECT 66,
  EQUIVALENT 2, not identical and not excused 0; sv-tests EQUAL 1935, STRICT_NOTEQUAL 1, DIFFERENT 4,
  SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346, regressions=0
  conversions=1 changes=0. Every sweep command exited 1 on the law index check alone (the worktree's index
  stale while this folder was being written; the main tree's as the implementer reports). Every csv of the
  law sweep equals the master's control /tmp/intr11u481 row for row except the converted row and the two
  LowMem log-path texts; every csv of the verified sweep equals the law sweep's row for row.
- Byteverify (SELFCHECK=1, same-length workdir names; evidence/byteverify_*.txt): law vs control 0 of 962, 0
  of 1608, 0 of 805; verified vs law and verified vs control the same zeros. The probe databases read 0
  movers too. The kept sv-tests databases embed the work directory and are not comparable by bytes; the trace
  stands for them.
- Trace (evidence/trace_sweep_law.txt, trace_sweep_ver.txt): identical on both binaries, exactly the
  implementer's: uvm_param_vif_config_db (4 firings of § clsScopedOvRhsRefObj483) and
  hdlconvertor_std2017_p771 (3 of § ifaceInstValueImplicitNet483, SLANG_ONLY, row unchanged); no line from
  either refinement, as predicted before the verified sweep (evidence/prediction_verified.txt).
- Canaries: ok=52 changed=0 and ok=16 changed=0 on both sweeps; ctcan2 EXPECT_UNKNOWN=1 and EXPECT_UNKNOWN=6
  PASS on both.
- Binary audit: surelog 1531 of 1581 cmds.txt naming the binary under test (the other 50 hold only a Surelog
  line), uhdm2rtlil 1742 of 1742, sv-tests 2346 of 2346, on both sweeps.
- Goal 1: the probe faces C::mk().arr[1] (r11u423 evidence/residue_cases/g1a) and u.mk(3).a[2] (g1b) exit 4
  on all three binaries, this.mk().inner.s (v11u415 VT/vt03) exits 0; upstream slang 0 and Surelog 3 on all
  three. bp_unicore alone on the verified binary with the size guard on: exit 3 (`basic_string::substr`) in
  17.1 s at 815 MB maximum resident: the guard stays.

## Residues (all wrong on pristine too; none moved away on the verified binary)

1. uvm_param_vif_config_db: the sister's two faces (#93329, #138364 above).
2. A defparam on a parameter that also has a class-scoped named actual (vo13, vo20): pristine's wrong value
   UINT:3 where golden has the defparam's UINT:6 (an older value face, now outside the law).
3. The nested-module read (vi25): golden binds the ref_obj to the elaborated interface_inst; not written.
4. `K :: w` with whitespace (vo07): golden's span ends after `::`, the law's at the member name.
5. `default_nettype tri (vi14): golden's minted net has vpiNetType 4, the shared mint writes 1 (also true
   of the other implicit-net laws using mintImplicitNet403).
6. The implementer's residues stand: the dependent parameter (ov06, ov23, vo12), an expression actual (ov16),
   `default_nettype none (iv08), a generate-block instance (iv12), the module variable initializer (iv21),
   v11u481 VA/va56, and the generate branch Surelog picks from the default (vo10, a Surelog artefact).

## Sister-ground faces (reported, not written)

The implementer's list stands (TypeEmit § elabParamClsScopedSubst474's body bounds for ov17, ov20, ov22 and the
dependent parameter; TypeEmit's interface_typespec span on iv21 and on a parameterized interface typespec,
VI/vi08; the two uvm_param_vif_config_db faces in UhdmExporter / ModuleEmit). vi10's function return variable
column (golden 4:22, ours 4:30) is TaskFuncEmit's.

## Process

Within the budget: no pristine build and no pristine sweep (pristine a copy of the main tree's build, the
master's control for the sweep reading); the law binary rebuilt once from the patch; two verified builds,
the first (ver1, the defparam fix alone) used on case runs and the away census only, the second the
delivered binary; one full five-stage sweep each on the law and the verified binary, launched only after the
sister v11u476's sweep had ended. The fence list was read into a file by a program and never printed; every
tree-wide list was filtered on it before any file was opened; this folder scans clean. No other agent's
process touched. Slip, no measurement affected: the first switch-check loop reused an output file it had not
deleted (slang-uhdm -o does not truncate), reading every dir as a mover; rerun with every output deleted.

## Files

cases/VO (23) and cases/VI (25), each dut.sv naming its law on its first line; drivers/env.sh, runcase.sh,
ds.sh, switches.sh, away2.sh, away3.sh; evidence/ as cited above.
