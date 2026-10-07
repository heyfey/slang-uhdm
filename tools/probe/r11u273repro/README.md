# r11u273 — pass 273, the module/type ground (refill after pass 271)

Base commit `a37b87c1` (pass 271). Production surface: `src/UhdmExporter.cpp`, `src/ModuleEmit.cpp` and the new
`src/R273.h`. Nothing under `results/`, `tests/` (apart from the regenerated `tests/LAWS.md`) or `third_party/` is
touched. No file of the sister's ground (ExprEmit, EmitHelpers.h, StmtEmit, ParamEmit) is edited.

| binary | md5 | what |
|---|---|---|
| pristine | `fee442106f0f3244cb319a78f1fdccfb` | built in the worktree at the base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `2caeef71f294ecc5b8e2ee997a8461f2` | the delivered patch, frozen (`chmod 555`) before the final firing census and every gate sweep |

Both link slang 12.0.0+545f88b2e.

## Verdict

No corpus row converts: at the base no corpus record is on this ground (MiniAmiq d/t `differ:endcol(5)` and SeqDriver
d/t `differ:fullname(6)` carry only the sister's records, below), and both rows keep their bytes under the law
(determinism draws equal to pristine's hashes). The pass works the PROBE RESIDUE, item (1) of the brief:

**48 probe conversions** (STRICT_NOTEQUAL -> EQUAL; `evidence/probe_conversions.txt`, each attributed by the firing
census), 0 regressions, 0 changes; probe 3670 EQUAL + 417 STRICT_NOTEQUAL of 4087 (base 3622 + 465). Of the base's 465,
the map's ground column (tools/probe/r11u230map/probe_fail_list.csv) puts 212 on this ground and 253 on the sister's;
after the pass 169 and 248 (five conversions the map pinned to ground A are TypeEmit buildStructTs sites, this ground).

| law | conversions |
|---|---|
| § typeParamStructLastNetParent273 | 10: r11u112repro/grid/k k03_dims, k12_twodims, k16_comb_driven, k17_ff_driven; r11u113repro/grid/c/c15_genif_structdef; r11u35repro/grid/g3_shape35; r11u45repro/g4; r11u47repro/arms/g8; r11v47repro/arms/v30; v11u93b107repro/brk/q11_member_access (all `differ:fullname`) |
| § fnRetLitRhsSharesDefConst273 | 20: r10rgg8repro/cells L_1b1_bt/_it, L_1d0_bt/_it, L_2b11_bt/_it, L_8b101010_bt/_it, L_8d42_bt/_it, L_8sd3_bt/_it, L_u0_bt/_it, L_u1_bt/_it, a_bitret, a_intret; r10vrgg8repro/cells/v8_structret; r11u23repro/grid/b17_genlocal_rhs_constcall (`differ:type(1)`, L_8sd3 `differ:fullname(3)`) |
| § paramValRhsSharesParamConst273 | 18: r11u116repro/grid/f1 gl_o_ms, gl_u_ms, mh_o_ms, mh_u_ms, ml_o_ms, ml_u_ms, mu_o_ms, mu_u_ms, mv_o_ms, mv_u_ms; r11u69repro/grid/g10_lhsbind; r11u71repro/grid/n5_declkind; r11u74repro/grid/b4_nonamesake; r11u75repro/grid/w8_unitname; r11v69repro/grid/w9_sharehead, w10_sharesize; r11v71repro/grid/x4_genarray, x7_oddhomes (`differ:type(1)`) |

The pass-271 decode of the localparam / parameter type struct (item (2), k03 / k12 / k14 / k16 / k17) is the first
law; the "elaborated cont_assign's Rhs sharing an existing constant" bucket of pass 266 (a folded function's return,
the parameter's value, a pattern member) is the second and third.

## The laws (src/R273.h: each law reads its own `R11U273_<LAW>_OFF`; `R11U273_OFF` drops all of them and gives pristine's bytes on every case-view; `R11U273_TRACE=<dir>` logs every firing and abstention)

### § typeParamStructLastNetParent273 (UhdmExporter, design-final right after typedefParentModel134) — switch `R11U273_TPSTRUCTNET_OFF`, its declaration-initializer reset also under `R11U273_TPNDARESET_OFF`

A type parameter's anonymous struct (or union) is ONE object in golden, and its parent is decided by the elaboration:
Surelog's `NetlistElaboration::elabSignal`, for a signal whose declared type is a type parameter (the `DummyType`
branch and the `PARAMETER`-category branch beside it, src/DesignCompile/NetlistElaboration.cpp), hands the signal that
object and runs `spec->VpiParent(stv)`: the struct_net (for a packed or unpacked array the ELEMENT struct_net under the
array net, so the chain reads `arr.arr`), net or variable alike. Every instance writes the same object, so the LAST
signal in elaboration order wins (two instances of one module: `work@dut.u2.s`, the definition listing included), and
UhdmWriter::writeCont_assign later ends every assignment with `tps->VpiParent(nullptr)` on the left side's typespec, so
an `assign v = ...;` to a scalar signal of the type leaves it unparented (§ contAssignLhsTsUnparented134 models that
reset for named typedefs and explicitly stands aside for type parameters). With no signal the struct keeps the type
parameter as its parent. Surelog stores no full name on the member ref_typespecs nor on the ref_objs of a member's
bounds: ComputeFullName reads them through that chain (`work@dut.v.x`, `work@top.arr.arr.a`, a nested anonymous member
`work@dut.v.s.p`, a bound `work@dut.v.x.W`, a folded package-parameter bound's typespec ref
`work@g3_shape35.u_ov.sv.s_pkgq`). Ours left the struct where the type parameter put it and stored the bare member chain
(`x`) or a scoped name (`work@dut.it_t.W`, `work@g3sub35.sh_t`).

The law walks the elaborated instances from the top modules (module and interface instances, generate scopes under
their instance, signals of an instance by source position: nets, variables, array nets), collects each instance's type
parameters whose actual is an anonymous struct or union, parents that object at the last signal typed by it (the
element signal of an array) unless an elaborated assignment's left side binds a signal of it (the bind as
§ contAssignLhsTsUnparented134 reads it: the instance's variables, then its nets; a declaration with an initializer,
`my_t s = '0;`, writes a cont_assign whose left side is the signal object itself, to which ours hands a typespec of its
own, so the instance's signal of that name decides, `R11U273_TPNDARESET_OFF`: the byte controls found the first draft
moving probe control r11u112repro/grid/k/k18_init's elaborated view STRICT_EQUAL -> fullname, refined before
delivery, grid TP t27), and rewrites the names below it to
the new chain: every member ref whose stored name was the old or the bare chain, every bound ref_obj whose stored name
was the old / bare chain or a `<scope>.<name>` form, and every bound constant's own typespec ref. It stands aside for a
struct whose signals hold a separate copy of ours (same span, another object: `TPSTRUCTNET_TWIN`, probe
v11u93b107repro/brk/q04_pkg_member, where an `assign o = i` resets golden's object and ours cannot see it).

### § fnRetLitRhsSharesDefConst273 (ModuleEmit, recorded at the module-body and generate-scope fold sites of § srlgUnvaluedActualLitRetFold8, swapped design-final in `retLitShareDrain273`) — switch `R11U273_RETLITSHARE_OFF`

§ srlgUnvaluedActualLitRetFold8 decoded the fold (writeCont_assign reduces the elaborated Rhs; `ExprEval::evalFunc`
executes the body and hands back the executed `return`'s literal) and wrote the Rhs as a FRESH constant at the
literal's span. evalFunc does not copy: the reduced value IS the definition function's return-statement constant, and
writeCont_assign ends with `res->VpiParent(assign)`, so golden lists that object once, under the function (its parent
now the elaborated cont_assign), and nothing at the assignment, where ours listed a second constant
(`differ:type(1)`: golden `cont_assign -> ref_obj` where ours read `cont_assign -> constant`). The law swaps our fresh
constant for the definition's return-statement constant at the same span when exactly one exists, and:

- the function returns a bit, int, integer, byte, shortint, longint or struct type, the kinds measured to share (FR
  f01-f03, f14, f15, f17, f21, f23): a logic return is copied (FR f04 `'0`, f05 `2'b11`, f22 `1'b1`: golden lists a
  constant at the assignment there), and a real return is not shared either (r10vrgg8repro/cells/v8_realret, stage 1 on
  both binaries, read uhdm-cmp 32 -> 36 lines under the first draft in the byte controls; grid FR f24);
- either the left side has no typespec (lhsTyped273: its own typespec, else what bindVariable finds, the variables then
  the nets of the enclosing instance and then of each ancestor instance, an interface instance included), in which case
  the object goes in as it is (FR f12 / b17: `return 7;` into a generate-local net, golden's Rhs reading the definition
  object's size 64 where our fresh fold read 32), or our fold already reads the object's value, size, decompile and
  constant type and that constant is not UINT (adjustSize re-sizes in place; a UINT is uniquified: FR f07, f11 keep
  their fresh constant).

### § paramValRhsSharesParamConst273 (ModuleEmit `paramValShareDrain273`, design-final after the previous law) — switch `R11U273_PARAMVALSHARE_OFF`

writeCont_assign's reduceExpr of a parameter reference (`assign o2[c] = M;`) or of a member of a struct-valued
parameter (`assign lv = CFG.n;`) hands back the instance's param_assign value object itself (the constant, or the
member's constant inside the value's assignment pattern), and with no left-side typespec installs it as it is,
re-parented at the assignment: golden lists the value once, under the param_assign, and nothing at the assignment, where
ours listed a fresh constant at the value's span. The law, per elaborated instance and generate scope: a constant Rhs at
the span of exactly one constant of the instance's (or the enclosing generate scopes') param_assign values is replaced
by it when the left side is untyped (lhsTyped273). Indexed are the value itself and the constants of a struct member:
a tagged_pattern's pattern, or an operand of a pattern typed by a struct or union (ours flattens the elaborated struct
value). Stands aside for:

- a typed left side: golden lists a copy whatever the kind (grid PV p02 UINT, p03 and p08 HEX);
- an interface signal or an ancestor instance's namesake on the left (probe r11u88repro/grid/x6_ifdefcast,
  r11v83repro/grid/b18_xmember, r11v69repro/grid/v2_ancnamesake; grid PV p15, p16): both bind in golden;
- an element of an unpacked-array value read through a select (Surelog corpus ReorderPatt `assign b = x[0];`, grid PV
  p19 / p20): golden lists a copy, so the operands of an array-typed pattern are not indexed. A first draft indexed every
  pattern operand and the first law sweep read ReorderPatt d/t CMP_EQUAL -> STRICT_NOTEQUAL `differ:type(1)`; that sweep
  was stopped by its own pid, its outputs deleted, the index restricted, and the census and every gate rerun from scratch
  on the final binary.

## Grid (tools/probe/r11u273repro/cases: TP 26, FR 24, PV 21 case dirs, both views; every grid line carries its exit code)

`drivers/grid.sh` on P (pristine), L (law), OFF (`R11U273_OFF=1`) and the law with each switch dropped alone;
`drivers/gridsum273.py` (evidence/grid.txt, evidence/grid_summary.txt; the grid also runs `R11U273_TPNDARESET_OFF`
alone): 142 case-views, 994 lines; OFF gives pristine's bytes on 142 of 142; 64 case-views moving, each attributed to
exactly one switch (TPSTRUCTNET 30, RETLITSHARE 24, PARAMVALSHARE 10), 60 entering STRICT_EQUAL, none leaving, no exit
code and no uhdm-cmp line count changing. The four movers that do not enter (TP t12 rc 4 and t22, both views) are
uhdm-cmp stage 1 on both binaries. Away census (drivers/away.py order-blind and drivers/awaychain.py chain-keyed,
evidence/away_grid_movers.txt): 0 lost and 0 away on all 64. Downstream on the 71 case dirs
(evidence/downstream_cases.txt): the same verdict on both binaries (65 IDENTICAL, 5 EQUIVALENT and 1 DIVERGENT, all
stage-1 cases: FR f16, f18, f19, f20, TP t12 and t17).

Residues on the grid (all wrong on pristine too): TP t10 (an unpacked array of the type: our element's struct is a
second object, golden one), t11 (an interface's type parameter, a full-name face of the interface instance), t14 (an
enum type parameter: our listing differs), t13 / t17 / t18 / t21 / t22 / t12 stage 1; FR f16, f18, f19, f20 stage 1 on
both, f24 (real return); PV p05 (a part-select left side: golden keeps a copy there, not decoded), p09 (an overridden child parameter),
p11 / p17 (an interface select left side), p21 (a positional struct pattern, stage 1 in the parse view).

## Census, sweeps and controls

- Firing census frozen before the law sweep (`drivers/tracecensus.sh` on the law binary under `R11U273_TRACE`, the probe
  and both corpora in both modes, the filter built from `$FENCED`; abstentions and twin stand-asides excluded):
  `evidence/predict.txt` (md5 in predict.md5), 70 lines: uhdm2rtlil port_chained_type_param d/t (TPSTRUCTNET) and 68
  probe cases.
- Law gate sweep `tests/sweep.sh --jobs 3` (evidence/sweep_law_summary.txt): probe 3670 EQUAL + 417 STRICT_NOTEQUAL,
  regressions=0 conversions=48 changes=0; surelog default 476 + 4, testflags 470 + 4, regressions=0 conversions=0
  changes=0; uhdm2rtlil 803 / 1 / 67 both modes, regressions=0 conversions=0 changes=0; downstream 803 IDENTICAL / 66
  SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, the csv identical to the pristine downstream sweep's. The sweep exits 1 on
  the law-index check alone (the patch carries the regenerated tests/LAWS.md).
- Pristine sweep (same harness, same-length workdir) reproduces every baseline (evidence/sweep_pristine_summary.txt).
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered hard-link mirrors (2560 of 2568
  databases; 8 fenced row-modes left out): MOVERS 2 / 2560, exactly the predicted uhdm2rtlil port_chained_type_param
  d/t, SELFCHECK 2559 / 2560 (the fixed reference equals itself); both stay CMP_EQUAL / strict equal, uhdm-cmp 0 lines,
  away 0 lost (dump distance 30 -> 0) and chain-keyed 0 away. Probe: 68 of 4087 databases move, exactly the predicted
  68: the 48 conversions and 20 that keep their status (13 EQUAL cases of r11u107repro t01 / t02 / t04 / t06 / t09 /
  t11 / t12 / t14, r11u112repro k20 and v11u93b107repro q09 / q10 / q13 / q15, where only stored names below a
  canonicalised subtree change; 7 STRICT_NOTEQUAL with their detail unchanged: r11u47repro/arms g2 and g12,
  r11v47repro/arms v12 and v28, r11u71repro/grid/n3_ifacegrid, r11v69repro/grid/v10_arraysel,
  r11v71repro/grid/x6_ifacedeep, dump distances unchanged or shrinking). Away census on all 68: 0 lost, 0 chain-keyed
  away (evidence/away_probe_movers.txt). Downstream: 1 of 805 fence-filtered databases moves (port_chained_type_param,
  IDENTICAL on both; evidence/byteverify_downstream.txt); downstream on the 48 converted probe cases: 48 IDENTICAL on both
  binaries.
- Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 carry no slang line.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.
- Determinism (drivers/det.sh, three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen with the law binary): one hash per row-mode, equal to the law sweep's and to the
  pristine sweep's (evidence/determinism_law.txt).
- Byte controls (drivers/controls.sh, every case dir of r11u271repro, v11u271repro, r11u269repro, v11u269repro,
  r11u267repro, r11u118repro, r11v11u118repro, r11u119repro, r11u120repro, r11u131repro, r10rgg8repro, r10vrgg8repro,
  r11u112repro, r11u116repro, r11u69repro, r11v69repro, r11u71repro, r11v71repro, r11u134repro, r11u212repro,
  r11u107repro, r11u47repro and r11v47repro, path lists fence-filtered first; evidence/controls.txt,
  controls_summary.txt): 1305 dirs, 2610 case-views; 32 moving, 2 entering STRICT_EQUAL (r11v69repro/grid/w8_unitname,
  both views), none leaving, no exit code and no uhdm-cmp line count changing; the other 30 movers are stage 1 on both
  binaries (r11v47repro arms, r11u71repro n1 / n2, r11v71repro x2 / x3 and r11u47repro g11, both views).
  Away census on all 32: 0 lost, 0 chain-keyed away (evidence/away_control_movers.txt). The first run of the
  controls, on the previous law binary, read r11u112repro/grid/k/k18_init_el leaving STRICT_EQUAL and
  r10vrgg8repro/cells/v8_realret uhdm-cmp 32 -> 36 lines; both were refined (above), and the census, the grid, the
  controls and every gate sweep were rerun on the final binary.

## The sister's ground at this base (reported, not written)

- SeqDriver d/t `differ:fullname(6)`: all six records the `inside`-set package-parameter fold (golden names the folded
  constant's ref_typespec after the design unit and parents the constant at the param_assign where ours names it after
  the subroutine; ExprEmit emitExpr; reproduced by r11u271repro R/r02, R/r04).
- MiniAmiq d/t `differ:endcol(5)`: #217949 the `$sformatf` endcol with a macro last argument (ExprEmit), #227043 /
  #227046 / #227049 the same `inside`-set fold, and the walk divergence #227149 (`uvm_severity_type'(severity)` binding a
  definition-pass alias clone whose Typedef_alias has no actual, minted by ParamEmit emitPackage's enum-alias branch and
  bound by ExprEmit; r11u271repro R/r01). Not stubbed on a scratch binary here: what stands behind #227149 is unread.
- The probe residue after this pass by the map's ground column: 248 cases on the sister's ground. The two largest
  ground-A buckets met here: the struct-valued function-call fold inside member typespec ranges (24 cases, `fullname`
  on a ref_typespec under `operation | typespec_member`, r11u24repro n3 / n12, r11u26repro m4-m15, r11u28repro a2-a16,
  r11v26repro v2-v18: ParamEmit's function evaluation), and the struct-parameter read `assign o = P;` where golden folds
  to the shared param value and ours keeps `ref_obj P` (22 cases `differ:name`, r11u108repro/grid/pk k10*, k11,
  r11u111repro/grid/f2 b03-b17, v11u111repro x22 / x26: the fold decision sits with ExprEmit / ParamEmit; once it folds,
  § paramValRhsSharesParamConst273's typed-left-side rule decides whether the object is shared).

## Residues on this ground, ranked by probe cases (all wrong on pristine too)

1. The remaining `type|ref_obj -> constant` and `type|bit_select -> constant` cases of the share family that the laws
   leave: r11u69repro/grid g11_iface, r11u71repro/grid/n3_ifacegrid, r11v69repro/grid v7_ifacemix,
   r11v71repro/grid/x6_ifacedeep, r11v83repro/grid/b14_cadelay (interface homes: the bind there is not decoded),
   r11u114repro/grid/f1 a25 / a28 and v11u114repro/grid/set1/g25 (a member of a concatenation-valued pattern),
   r10v111repro/v111_b6 (a class static call), r11v69repro/grid/v10_arraysel; and the typed-left-side copies golden
   makes, which ours already copies.
2. `fullname` on struct-member ref_typespecs outside type parameters (16 cases, r10sd10repro g4 / g6 / v2 / v9 / v13 /
   v14, r10sd6repro/v3_hier_path, r10uvm198 / r10uvm202 homes, r10v136repro/v136_d_homes, r11u107repro a08 / a18,
   r11u24repro/n11 and r11v21repro/v15 the reverse face where golden's chain is shorter, r11v74repro/grid/v2_kindns):
   package and class typedef listings whose last writer the 134 / 212 models do not reach.
3. `line` on the logic_typespec of a type-parameter-sized packed array (15 cases, r11u108repro/grid/f5 f5a05 ...: the
   override's typespec location), `name` on a cross-package alias name `home48::w48_t` (10 cases, r10uvm36repro t48a
   ...), `endcol` on package param_assigns (8), the remaining type-parameter faces (7 `packed_array_typespec | type_parameter`,
   5 `type_parameter | interface_inst`).
4. This pass's own open shapes: a real-returning function's fold (FR f24, stage 1), the unpacked array of a type-parameter struct (TP t10, probe r11u112repro k14_unpacked:
   our element holds a second struct object), the interface type parameter (TP t11, probe r11u107repro t13), an enum
   type parameter (TP t14), the part-select and interface-select left sides of the value share (PV p05, p11, p17).
5. Items (2) to (7) of the brief beyond the above (pass 271's net-declaration neighbours, pass 269's clone-law and
   select-fold shapes, the package listing order, typedefParentModel134's cast-copy re-parent, passes 267 / 265 / 263 /
   261 / 259 residues): not attempted.

## Process notes

- The fence: every corpus path list was filtered by `$FENCED` (word boundary) before anything was opened; the census
  used the fence filter; byteverify ran on fence-filtered hard-link mirrors; the downstream byte compare listed paths
  first and filtered them; no fenced database or source was read.
- Processes: the first law sweep (the draft of the value-share law, ReorderPatt above) was stopped by its own pids after
  checking each command line named this pass's workdir; its outputs were deleted. One of this pass's own waiters used
  a `pgrep -f` pattern that matched its own shell and never ended; it was stopped by its own task id. No other process
  was signalled.
- Binary-path audit and canaries are in evidence/binary_audit.txt and evidence/canaries.txt.
- Nothing was written outside the worktree and `/tmp/r11u273_*` scratch.

## Files

- `cases/TP` (§ typeParamStructLastNetParent273), `cases/FR` (§ fnRetLitRhsSharesDefConst273), `cases/PV`
  (§ paramValRhsSharesParamConst273): each `dut.sv` names its law on its first line.
- `drivers/`: copied from r11u271repro/drivers (env.sh, case.sh, grid.sh with this pass's switches, tracecensus.sh with
  `R11U273_TRACE` and the abstention filter, controls.sh, ctlsum.py, det.sh, bvmirror.sh, away.py, awaychain.py,
  dscases.py) plus gridsum273.py.
- `evidence/`: grid.txt, grid_summary.txt, predict.txt + predict.md5, probe_conversions.txt, away_grid_movers.txt,
  away_probe_movers.txt, away_control_movers.txt, away_corpus_movers.txt, byteverify_corpus.txt, byteverify_downstream.txt, downstream_cases.txt, determinism_law.txt, binary_audit.txt, canaries.txt,
  sweep_law_summary.txt, sweep_pristine_summary.txt, controls.txt, controls_summary.txt.
