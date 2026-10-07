# v11u273 — adversarial verification of r11u273

Base commit `a37b87c1` (pass 271). The implementer's patch (`/tmp/r11u273.patch`, md5 `c836564b`) applied clean on a
fresh worktree. This pass did four things:

- rebuilt pristine and law and reproduced every headline number;
- attacked the three laws with 61 fresh case dirs in both views;
- found two places where a law does not follow Surelog's own rule;
- landed three refinements behind their own switches, in UhdmExporter, ModuleEmit and `src/R273.h` (the module/type
  ground).

Nothing under `results/`, `tests/` (apart from the regenerated `tests/LAWS.md`) or `third_party/` is touched. No file
of the sister's ground (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) is edited.

| binary | md5 | what |
|---|---|---|
| pristine | `fee442106f0f3244cb319a78f1fdccfb` | the base, byte-identical to the main tree's build at `a37b87c1` |
| law | `2caeef71f294ecc5b8e2ee997a8461f2` | the implementer's patch, the implementer's md5 |
| final | `83215b81e3f89247ad91f03bbafd3945` | law + this pass's three refinements |

All three link slang 12.0.0+545f88b2e and were frozen before any measurement.

## Verdict

**Verified, with three refinements.** Every number the implementer gives is reproduced bit for bit.

- No gate database moves between law and final.
- The refinements move only fresh cases, and every one of those moves toward golden.
- No corpus row converts. MiniAmiq d/t `differ:endcol(5)` and SeqDriver d/t `differ:fullname(6)` carry only
  sister-ground records at the base and keep their bytes.
- **48 probe conversions**, by the same names as the implementer's `evidence/probe_conversions.txt`, with 0
  regressions and 0 changes. The probe reads 3670 EQUAL + 417 STRICT_NOTEQUAL.

## The refinements

Each refinement has its own switch. `R11V273_OFF` drops all three and gives the law's bytes. `R11U273_OFF` still gives
pristine's bytes. Both hold on 120 of 120 database-producing grid case-views.

### 1. § tpVarSigKeepsTpParent273v

- **Where:** UhdmExporter, inside § typeParamStructLastNetParent273.
- **Switch:** `R11V273_TPVARKEEP_OFF`.

**What Surelog does.** Only the net branches of `NetlistElaboration::elabSignal` run `spec->VpiParent(stv)`. These
are the struct_net branches, and the element under an array net.

A signal Surelog makes a variable does not run it. That covers two cases:

- `ElaborationStep::makeVar_`'s DummyType branch, which sets `found = true` and never parents the typespec;
- a union in the net branch, which goes through `getSimpleVarFromTypespec`.

In both cases the struct stays at its type parameter. Golden shows `type_parameter work@dut.T`, members
`work@dut.T.a`, and for two instances the definition's `work@m.T`.

**Which signals are variables.** This follows elabSignal's own rule, not the kind of our signal:

- a struct is a net exactly when every member's typespec is a logic or struct typespec;
- a union never is.

**Where the law went wrong.** The law parented the struct at any signal, so on these shapes it put it at the
variable. Pristine was wrong too: it left the struct unparented with bare member names. Under the law the dump
distance went 5 -> 6 on vt02, vt15 and vt16, and vt14 lost one golden dump line. The strict count did not change.

**The `var` keyword leg.** A declaration written `var T v;` reaches makeVar_ without the DummyType data type. It takes
the fallback branch, which does run `tps->VpiParent(obj)`, so golden parents the struct at that variable (vt21, vt23,
vt24, vt26). Our database does not keep the keyword. The refinement therefore reads the declaration's text, from the
previous `;` up to the signal's name, with comments removed (vt25 has `var` on the line before; vt27 has a comment
reading `var`). Unreadable text counts as no `var`.

**Struct with no parent.** A struct that only variables take, and that ours left unparented, is parented at the
definition's type_parameter that holds it.

**Grid:** VT vt02, vt14, vt15, vt16, vt18 and vt27 enter STRICT_EQUAL in both views. vt21, vt23, vt24, vt25 and vt26
keep the law's STRICT_EQUAL.

### 2. § delayRefShareAsIs273v

- **Where:** ModuleEmit, in `retLitShareDrain273` and `paramValShareDrain273`.
- **Switch:** `R11V273_DLYREF_OFF`.

**What Surelog does.** `UhdmWriter::writeCont_assign` clones the assignment *first* when its delay is a ref_obj
(`assign #D o = ...;`). So `cloned` is already true when the reduced value arrives:

- neither `adjustSize` nor `res->VpiParent(assign)` runs;
- the shared constant (the function's return constant, or the param_assign value) is installed as it is, whether the
  left side is typed or not, and keeps its own parent.

**Where the law went wrong.**

- It re-parented the constant at the assignment. vp18 and vf14 each had one golden dump line moved away (the
  constant's `vpiParent`). Both comparators are blind to that field.
- It abstained on a typed left side, where golden shares (vp19, vf15).

**Grid:** vp19 and vf15 enter STRICT_EQUAL in both views. vp18 and vf14 become dump-identical to golden.

## Reproduction (law against pristine)

### Implementer's grid

- 71 dirs, 142 case-views, 852 lines with 6 configurations, every line carrying `rc=`.
- My lines are identical to `r11u273repro/evidence/grid.txt` in every cmp, cmplines, strict and rc field (0 of 852
  differ; the TPNDARESET column was not rerun).
- 64 move and 60 enter STRICT_EQUAL. None leave. TP/t12 exits 4 on both binaries.
- `R11U273_OFF` gives pristine's bytes on 142 of 142.
- The final binary gives the law's bytes on 142 of 142.

### Gate sweeps

| sweep | probe | surelog d / t | uhdm2rtlil d / t | downstream |
|---|---|---|---|---|
| pristine | 3622 + 465 | 476+4 / 470+4 | 803/1/67 ×2 | 803 / 66 / 2 / 0 |
| law | 3670 + 417, 48 conv. | unchanged, 0 regr. | unchanged | 803 / 66 / 2 / 0, csv = pristine's |
| final | = law (csv identical) | = law (LowMem detail text only) | = law (csv identical) | csv = law's |

- Every sweep exited 1 on the law-index check alone. The final patch carries the regenerated `tests/LAWS.md`.
- The 48 conversions match the implementer's list by name.

### Byteverify

Byteverify ran on fence-filtered hard-link mirrors (2560 of 2568; 8 fenced row-modes left out), with `SELFCHECK`
reading 2559/2560.

**Law against pristine:**

- 2 of 2560 corpus databases move: uhdm2rtlil port_chained_type_param d/t, exactly as predicted.
- 68 of 4087 probe databases move. This is the implementer's `predict.txt` (md5 `2912f4b1`) line for line.
- 1 of 805 downstream databases moves: port_chained_type_param, IDENTICAL on both binaries.

**Final against law:** 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream databases move.

### port_chained_type_param d/t

- CMP_EQUAL and strict-equal on both binaries.
- uhdm-cmp reads 0 lines.
- **Correction to the implementer's README:** the record census goes 30 -> 0 with 0 lost. The dump census goes 6 -> 4
  with 0 lost. The README calls the 30 -> 0 a dump distance; it is the record census.

### Other checks

- **Canaries:** surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both csvs
  (`EXPECT_UNKNOWN=1` / `6`).
- **Binary-path audit:** each sweep has 3323 cmds.txt (the sweep dispatches the fenced rows itself). 3273 name the
  sweep's own frozen binary. The other 50 run no slang; two of them carry the repository path only.
- **Determinism:** three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
  BuildUVMPkg and Rggen. Each binary (law, the first fix, final) gives one hash per row-mode, equal to the sweep's and
  to pristine's (`evidence/determinism.txt`).

### Byte controls

- The implementer's 1305 control dirs: 2610 case-views, rerun on pristine, law and final.
- **Law:** 32 move and 2 enter STRICT_EQUAL. None leave. No exit code or uhdm-cmp line count changes.
- **Final:** equal to the law on all 2610.
- **Record census:** 0 lost on all 32 movers. But 30 of the 32 are uhdm-cmp stage 1 on both binaries, where the record
  census is empty by construction.
- **Dump census:** lost lines on 8 of them, while the distance falls on every one:

  | case | dump distance | lost |
  |---|---|---|
  | r11u71repro n1_sharewidths | 67 -> 31 | 6 |
  | r11u71repro n2_bindhomes | 23 -> 8 | 10 |
  | r11v71repro x2_delayclone | 5 -> 2 | 4 |
  | r11v71repro x3_nofold | 100 -> 88 | 1 |

  Each case is listed with both views. The lost lines are the fresh constant's generic lines (`vpiParent:`,
  `vpiSize:32`, `vpiConstType:9`), printed once fewer now that the object is shared.

- **Note on the implementer's "0 away":** it holds record- and chain-keyed only.

## Attack

The attack used 61 fresh case dirs in both views: 122 case-views, 1220 grid lines, 10 configurations, every line
carrying `rc=` (`evidence/grid.txt`, summary `evidence/grid_summary.txt`). Configurations:

- P, L and F;
- F with `R11V273_OFF`, which equals L on 120 of 120;
- F with `R11U273_OFF`, which equals P on 120 of 120;
- F with each of the five switches.

| | moving vs pristine | entering STRICT_EQUAL | leaving | uhdm-cmp / rc change |
|---|---|---|---|---|
| law | 56 | 38 | 0 | 0 |
| final | 60 | 54 | 0 | 0 |

- **Final against law:** 20 movers, each attributed to exactly one refinement switch (DLYREF 8, TPVARKEEP 12).
- **Away census on all 60 final movers** (`evidence/away_grid_final.txt`): the record census reads 0 lost and the
  chain-keyed census 0 away on every one. The dump census shows lost lines on two cases, both from the implementer's
  laws, not the refinements:
  - VP/vp15 loses 2 lines while its distance falls 16 -> 1 and it enters STRICT_EQUAL;
  - VF/vf05_el loses 4 lines (stage 1 on every binary) while its distance falls 63 -> 44.
- **Downstream** on all 61 case dirs is the same verdict on pristine, law and final: 52 IDENTICAL, 8 DIVERGENT and 1
  SLANG_REJECT, all pre-existing (`evidence/downstream_cases.txt`).
- **Firing census of the refinements** (`drivers/fixcensus.sh`; `evidence/predict_fix.txt`, md5 `f651b266`): frozen
  before the final sweep.
  - It predicted two probe databases, r11u107repro/grid/t06_tp_union and r11u113repro/grid/e/e07_lptype_scalar
    (VARSIG). Neither moved: both are EQUAL, with a reset or an unchanged parent.
  - It predicted no corpus database. The positive control is the 20 grid movers.

### Cases by law

| law | cases |
|---|---|
| § paramValRhsSharesParamConst273 | VP vp01_genvar_sel, vp02_concat_lhs, vp03_member_lhs, vp04_implicit_net, vp05_ips_lhs, vp06_child_override_sel, vp07_struct_member_sel, vp08_import_bare, vp09_bitsel_typed_vec, vp10_genloop_local, vp11_two_inst_same, vp12_iface_body, vp13_genvar_plain_genlocal, vp14_param_param (enters), vp15_case_gen (enters), vp16_enum_param, vp17_delay_param (enters) |
| § fnRetLitRhsSharesDefConst273 | VF vf01_two_calls_typed, vf02_case_returns, vf03_pkg_fn_sel, vf04_uint_ret (enters), vf05_bitvec_hex_wide, vf06_gen_and_body (enters), vf07_iface_fn, vf08_param_branch_two_inst, vf09_byte_ret_untyped_sel (enters), vf10_struct_ret_member, vf11_shortint_ret_net (enters), vf12_nested_call, vf13_delay_param (enters) |
| § delayRefShareAsIs273v | VF vf14_delay_only, vf15_delay_typed (enters); VP vp18_delay_only, vp19_delay_typed (enters) |
| § typeParamStructLastNetParent273 | VT vt01_gen_last, vt03_override_anon, vt04_member_assign (enters), vt05_same_line (enters), vt06_enum_member, vt07_iface_tp, vt08_two_sig_one_assigned_last, vt09_child_chain, vt10_param_width_member, vt11_packed_arr_gen, vt12_ff_var (enters), vt13_union_assign, vt17_union_gen, vt19_td_logic_member, vt20_packed_arr_bit, vt22_nested_struct_member (enters) |
| § tpVarSigKeepsTpParent273v | VT vt02_union, vt14_union_two_inst, vt15_struct_bit_members, vt16_struct_int_member, vt18_struct_mixed_two, vt27_int_member_comment_var (all enter under the refinement); vt21_var_kw_bit, vt23_var_kw_union, vt24_var_kw_multi, vt25_var_kw_prevline, vt26_bit_two_inst_var (the `var` leg, keeping the law's STRICT_EQUAL) |

## Residues

All of these are wrong on pristine too, ranked by reach.

1. **Shapes the share laws do not reach** (STRICT_NOTEQUAL type on every binary):
   - a concatenation left side (vp02);
   - a member left side (vp03);
   - an indexed part select (vp05, as the implementer's PV p05);
   - a child-override select (vp06);
   - a bit select into a typed vector (vp09);
   - two instances of one module, where the law never sees a folded constant (vp11: no trace line);
   - an interface body (vp12);
   - a package function (vf03);
   - a parameter-dependent branch in two instances (vf08, DIVERGENT downstream on every binary);
   - a case-statement return set (vf02, uhdm-cmp stage 1 in the elaborated view, DIVERGENT);
   - a 4-bit return into an 8-bit target (vf05);
   - a function in an interface (vf07, stage 1).
2. **Type-parameter shapes outside the law** (uhdm-cmp stage 1 on every binary, DIVERGENT downstream): a generate
   block's signal (vt01, vt17), an enum member (vt06), a parameter-width member (vt10), a packed array in a generate
   loop (vt11), a typedef member (vt19), a packed array of a variable-kind struct (vt20). Also an interface's type
   parameter (vt07, fullname).
3. **An anonymous struct as an override actual** (vt03): slang-uhdm exits 3 on every binary.
4. **A generate-scope delayed cont_assign has no `vpiDelay` in ours** (VB/vb04's face; control r11v71repro
   x2_delayclone). § delayRefShareAsIs273v cannot see the delay there, so the law still re-parents the shared constant
   where golden keeps the pattern's parent.
5. **The `var` leg reads source text.** A `var` produced by a macro, or a declaration whose preceding `;` sits inside a
   comment, stays unread.
6. **The implementer's own residues**, which this pass did not re-measure: its interface homes, concatenation-member
   patterns, struct-member typespec full names (16), the type-parameter-sized packed-array line (15),
   `home48::w48_t` (10), package param_assign endcol (8). Items (2) to (7) of the brief were not attempted.

## Sister-ground faces (reported, not written; not stubbed)

These are unchanged from the implementer's report:

- SeqDriver's six records and MiniAmiq #227043 / #227046 / #227049 are the inside-set package-parameter fold (ExprEmit
  emitExpr).
- MiniAmiq #217949 is the `$sformatf` endcol with a macro last argument (ExprEmit).
- MiniAmiq #227149 is the enum-alias cast binding (ParamEmit emitPackage's enum-alias branch plus ExprEmit).

## Process

- Two worktrees at `a37b87c1`: `/tmp/wt_v11u273pris` (pristine build) and `/tmp/wt_v11u273` (law, then final).
- All writes went under the worktree and the `/tmp/v11u273_*` scratch.
- **Fence:** every corpus path list was filtered by `$FENCED` (word boundary, from canaudit's FENCED= line) before
  anything was opened.
  - Byteverify ran on fence-filtered mirrors.
  - The census used `--filter` built from `$FENCED`.
  - No fenced source or database was read.
  - No process was signalled.
- **Intermediate binaries:** fix1 (net-kind test on our signal kind) moved r11u273 TP/t22_var_kw away. fix2
  (elabSignal's member rule) moved vt21 away from pristine. fix3 (`var` read on the name's line only) missed vt25 and
  misread vt27. Each was withdrawn after its grid. The census, sweeps, controls, grid and determinism were rerun on
  `final`.
- One helper invocation failed before measuring anything: the first fix grid ran without `drivers/env.sh`, so
  `STRICT_CMP` was unset and case.sh refused. It was rerun.
- **Drivers** (copied from r11u273repro with the case root changed): `case.sh`, `grid.sh`, `env.sh`, `away.py`,
  `awaychain.py`, `awayrows.py`, `awaydump.py`, `awaycorp.sh`, `bvmirror.sh`, `det.sh`, `dscases.py`. New:
  `vgrid.sh`, `vgridsum.py` and `fixcensus.sh`.
