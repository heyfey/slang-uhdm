# v11u289 — adversarial verification of r11u289

Base af6dc102 (pass 287). The implementer's pass r11u289 (tools/probe/r11u289repro) landed seven struct-parameter
member-read laws in ModuleEmit behind `src/R289.h`. This verification reproduced every headline number. It then
broke two of the laws on legal SystemVerilog where pristine was right, and fixed both with two refinements in
ModuleEmit. Each refinement has its own switch, and `R11V289_OFF` drops both.

**Verdict: the five probe conversions stand, with two production fixes.**

- **The gate is unchanged.** Probe reads EQUAL 3893 + STRICT_NOTEQUAL 194, surelog 478 + 2 / 472 + 2, uhdm2rtlil
  803/1/67 and downstream 803/66/2/0, with 0 regressions in every stage.
- **The fix moves nothing the gate sees.** It moves 0 of 3365 corpus databases and 0 of 4087 probe databases
  against the law.

## Binaries (built here, frozen under /tmp/v11u289_bin before any measurement)

| binary | md5 | note |
|---|---|---|
| pristine | 79b73d19da0324ee68ff7fe6adaa2f56 | the same as the implementer's and the brief's |
| law | d6bea85a8c605e723527f3c612da2739 | the same as the implementer's law16.bin |
| fix | 2e46a6c240bcd46e0b5d3fb91a60abe1 | the law plus the two refinements below |

All three link slang 12.0.0+545f88b2e.

## The breaks and the refinements

### 1. A delay written as a name: § caDelayNameRefKeepsOperand289v (`R11V289_DLYREF_OFF`)

**Decode.** `UhdmWriter::writeCont_assign` handles a delay that is a `ref_obj` (`delay->UhdmType() ==
uhdmref_obj`) in its first branch:

- that branch clones the assign and sets `cloned`;
- the reduce branch then calls `CompileHelper::adjustSize` only while `cloned == false`.

So under `assign #D o = P.a;` golden's Rhs is the reduced operand exactly as it was: not re-sized, not truncated
and not re-parented. Pristine already models this; it shares the operand on such a cell.

**The break.** The three typed laws ran before that path and re-sized or truncated the shared operand:
§ caStructParamModSharesPaOperand289, § caStructParamModClonesPaOperand289 and § genCaStructParamTypedLhsShares289.

**Cases where pristine was right and the law moved away**, in both views (every one returns to pristine's bytes
under the fix):

| case | pristine | law | fix |
|---|---|---|---|
| VM/vm01_pdelay_hexwide (`12'hABC` into 4 bits) | STRICT_EQUAL | stage 1, chain away 1 | STRICT_EQUAL |
| VM/vm02_pdelay_binwide | STRICT_EQUAL | stage 1, chain away 1 | STRICT_EQUAL |
| VC/vc09_own_pdelay_twoca (the module-body clone) | STRICT_EQUAL | stage 1, chain away 1; downstream IDENTICAL -> DIVERGENT | STRICT_EQUAL, IDENTICAL |
| VM/vm28_comma_list_pdelay (`assign #D o = .., p = ..`) | STRICT_EQUAL | stage 1, chain away 1 | STRICT_EQUAL |
| VM/vm19_paren_pdelay (`#(D)`) | stage 1 | stage 1, chain away 1 | stage 1 |
| VM/vm24_var_delay (`#dv`, a variable) | stage 1 | stage 1, chain away 1 | stage 1 |
| VM/vm25_pkgqual_delay (`#pd::PD`) | stage 1 | stage 1, chain away 1 | stage 1 |
| VM/vm22_pdelay_then_plain | stage 1, downstream IDENTICAL | stage 1, downstream DIVERGENT | **STRICT_EQUAL**, IDENTICAL |
| VG/vg01_gen_pdelay | stage 1 | stage 1 | stage 1 |

- **vm19, vm24, vm25:** stage 1 on every binary.
- **vm22:** the fix converts it. The plain cell re-sizes the shared operand and the delayed cell shares it as is,
  which is what golden does.
- **vg01:** golden's operand keeps vpiSize 12 and its operation parent; the law wrote 4 and re-parented it. The
  case stays at stage 1 because our generate scope writes no vpiDelay, a pristine residue.

**The rule.** The three typed laws step aside when the cell's delay is written in one of the spellings Surelog
compiles to a `ref_obj`:

- a bare name: a parameter or a variable;
- a qualified name;
- either of the above parenthesised (`#(D)`).

**Exceptions:**

- A localparam keeps the law. VM/vm21_localparam_delay_bin converts under both the law and the fix, because golden
  adjusts there.
- `#(D+1)` and `#(D:E:F)` are not this shape.

The interface laws are untouched: `tps` is null in an interface, so `adjustSize` never runs (VI/vi04, vi10 and vi14
are unchanged in status). The trace tag is `DLYREF289V_ABSTAIN`.

### 2. A part-select Lhs with non-constant bounds: § ifSelShareConstBounds289v (`R11V289_SELBOUNDS_OFF`)

**The break.** § caIfaceSelLhsTakesSharedRhs289 re-lists a part-select Lhs, but `cpBound` copies a bound only when
it is a constant. On `assign e[W-1:0] = K.m;` in an interface, the elaborated part_select was written with no left
range, where golden keeps the operation `W-1`. The bound's records were lost: uhdm-cmp's first difference became
`RHS: <null>` at that operation.

- VI/vi01_pkg_partsel_parambounds: stage 1, 73 -> 41 uhdm-cmp lines, with the bound gone.
- VI/vi03_own_partsel_parambounds: 69 -> 41.

**The rule.** A part-select Lhs whose bounds are not both constants keeps the definition's cell, as pristine did.
Both cases return to pristine's bytes. The trace tag is `SELBOUNDS289V_ABSTAIN`.

## Reproduction of the implementer's numbers (all bit for bit)

- **Grid** (tools/probe/r11u289repro/cases plus the 5 probe targets; 58 dirs, 116 case-views, every line with
  rc=; evidence/impl_grid_repro.txt):
  - all 232 pristine and law lines are identical to the implementer's grid.txt in every field but md5;
  - 90 moving, 80 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes;
  - the fix equals the law on 116 of 116;
  - `R11V289_OFF` gives the law's bytes and `R11U289_OFF` gives pristine's on 116 of 116.
- **Byte controls** (the implementer's 24 repro dirs: 1527 case dirs, 3054 case-views on pristine, law and fix;
  evidence/controls_impl.txt):
  - pristine -> law: 50 moving, 22 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 18 uhdm-cmp line counts
    shrinking;
  - lost 0 and chain away 0 on all 50 (evidence/controls_away.txt);
  - law -> fix: 0 moving.
- **Widened byte controls** (15 more repro dirs: r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u90 (the
  delay-reference spelling), r11u164 (shared delays), r11u267, v11u267, r11u273, v11u273, r11u285, v11u285, r11u283
  and v11u283):
  - 868 case dirs and 1736 case-views, with **0 moving** between any two of the three binaries;
  - 18 case-views exit non-zero, identically on all three binaries (rc 3, rc 4, and v11u283 VB/vb06 rc 139, the
    known crash).
- **Gate sweeps** (tests/sweep.sh --jobs 3, my own workdirs; evidence/sweep_*.log):
  - pristine: probe 3888 + 199, surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67, downstream 803/66/2/0;
  - law and fix: probe 3893 + 194 with the 5 conversions and 0 changes, every other stage 0 / 0 / 0;
  - downstream on pristine, law and fix: the csv is byte-identical to results/downstream_uhdm2rtlil.csv;
  - the uhdm2rtlil csvs are identical across the three binaries;
  - the surelog csvs differ only in the workdir path inside the LowMemLib / LowMemPkg testflags detail;
  - the fix sweep's probe csv is identical to the law's;
  - the sweeps exited 1 on the law-index check alone (this directory was added mid-run; LAWS.md is regenerated).
- **Firing census** (drivers/tracecensus.sh): the law's 17 lines are identical to the implementer's predict.txt
  (evidence/predict_law.txt).
  - The fix binary's census was frozen before the fix sweep (evidence/predict_fix.txt). It is identical to the
    law's, and no refinement abstention fires on any probe or corpus database.
  - It predicted 0 law -> fix movers, and 0 moved.
- **Byteverify** (fence-filtered hard-link mirrors, SELFCHECK=1):
  - corpus: pristine -> law 0 of 3365, pristine -> fix 0, law -> fix 0;
  - SELFCHECK reads 3363 of 3365, the known twin;
  - probe: pristine -> law 5 of 4087 (exactly the 5 conversions), law -> fix 0.
- **Canaries:** surelog ok=52, uhdm2rtlil ok=16, and both ctcan2 checks PASS, on the law and fix csvs.
- **Binary-path audit:** 3265 of 3315 cmds.txt name each sweep's own frozen binary on all three sweeps. The other
  50 run no slang-uhdm.
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode with the fix on Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen; evidence/determinism.txt):
  - one hash per row-mode, equal to the pristine and fix sweeps';
  - Scoreboard and Rggen testflags write no database, as at the base.

## Fresh cases (cases/; 72 dirs in VM 32, VC 12, VG 8, VI 20; 144 case-views; evidence/grid.txt with rc= on every line)

Each case-view runs on pristine, the law, the fix, the fix with `R11V289_OFF`, the fix with `R11U289_OFF`, and the
fix with each refinement switch off. Each case's first line names its law.

| | moving | entering STRICT_EQUAL | leaving | other |
|---|---|---|---|---|
| pristine -> law | 122 | 69 | **8** (vc09, vm01, vm02, vm28, both views) | chain away 1 on 14 (those 8 plus vm19, vm24, vm25) |
| pristine -> fix | 98 | 71 | 0 | lost 0 and chain away 0 on all 98, 100 records toward golden |
| law -> fix | 30 | 10 | 0 | each mover restored to the law's bytes by exactly one switch: DLYREF 26, SELBOUNDS 4 |

- `R11V289_OFF` gives the law's bytes and `R11U289_OFF` gives pristine's on 144 of 144.
- No exit code differs between the binaries. vm27 (`#(D, E)` on a variable) was illegal and was dropped.
- **Downstream** (drivers/dscases.py, three binaries; evidence/downstream_cases.txt):
  - pristine -> fix:
    - DIVERGENT -> IDENTICAL on vc02, vc03, vc06, vm05, vm06 and vm08;
    - EQUIVALENT -> IDENTICAL on vg04;
    - none worse;
  - the law alone took vc09 and vm22 from IDENTICAL to DIVERGENT, which the fix restores.

What the fresh cases confirm about the implementer's laws (all STRICT_EQUAL under law and fix):

- **Module level:**
  - two cells narrow then wide (vm05) and wide then narrow (vm06);
  - module plus generate in either order (vm07, vm08);
  - a struct Lhs (vm10), a signed Lhs (vm11), a wire declaration (vm12);
  - an instance inside a generate block (vm13), a comma list (vm30), drive strength (vm31);
  - two packages (vm32), a header include (vm33), CRLF (vm16), a macro read (vm17), int and integer Lhs (vm18);
  - the module-body clone with three widths (vc02), two members over three cells (vc11), a parameter port (vc06),
    two instances (vc04).
- **Interface:** a select in a generate block (vi08), a select before the whole read (vi12), two members with
  selects (vi17), an interface port of a module (vi18), an interface inside a generate block (vi15), the elaborated
  view of an interface array (vi16).

## Residues (ranked; all wrong on pristine too)

1. **The generate-scope cont_assign with a delay** writes no vpiDelay in ours, on every binary (vg01, vg07, vg08;
   stage 1). Golden's elaborated delay is a folded constant. Pass 90 recorded this as w5_dlyparamgen.
2. **The interface select cell with non-constant bounds** (vi01, vi03). Golden re-lists the cell with the
   operation bound and shares the Rhs. A faithful law would deep-copy the bound expression; the refinement
   abstains.
3. **The module-body clone whose first cell has a delay** (vc10, stage 1 on every binary), and a select Lhs before
   the whole read (vc08). The module-level select-Lhs residue is the implementer's m19.
4. **Overridden parameters:** vc12 (a child override, stage 1, EQUIVALENT downstream on every binary), vi11 and vi20
   (interface overrides). vi11 moves 32 -> 68 uhdm-cmp lines with chain away 0 and toward 1: the walk diverges later
   at the instance param_assign, the sister's ParamEmit face the implementer reported.
5. **A 64-bit or wider Lhs:** vm29 (`logic [99:0]`, the law abstains above 64 bits) moves stage 1 -> type with
   chain away 0.
6. **Other shapes:**
   - stage 1 on every binary: vm04 (an implicit net, type), vm09 (a bit Lhs with a wider binary, type), vm15 (a
     localparam initialised from the member), vm20 (`#(D+1)`), vm26 (a program home, 732 lines), vi19 (a nested
     interface, 2372 -> 2360 lines, chain away 0);
   - vi13 (a modport port) moves from type(2) to fullname(1).

## Process

- **Fence.** $FENCED is read fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh)
  and never spelled.
  - Every control path list was filtered by word boundary before any case was opened.
  - The census ran through the harness filter.
  - The byteverify mirrors were fence-filtered (8 fenced row-mode databases left out).
  - The cmds.txt audit list was filtered before any file was read.
- **Slip.** One of my waiting loops used `pgrep -f` with a pattern contained in its own command line, so it could
  never finish. I stopped it by its own task id; nothing else was listed or signalled.
- **Writes.** Every write went to /tmp/wt_v11u289*, /tmp/v11u289_* and the session scratch. The main tree was not
  written.
- **Binaries.** All three were frozen before measurement:
  - draft fix binaries 71f3f5c5 and 40f66005 were superseded;
  - 40f66005 lacked the parenthesised spelling, which vm19 caught at chain away 1;
  - every fix number above is from 2e46a6c2.
