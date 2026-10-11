# v11u287 — adversarial verification of r11u287 (module/type ground: six laws behind src/R287.h)

Base 04d369c8 (pass 285). Verdict: **five of the six laws hold as delivered. Law 6, § evalFuncUnreducedOperandKeepsCall287,
breaks on legal SV where pristine was right, and is refined here** behind one new switch:

- **§ evalFuncKeepOwnParamAddCmp287v** (ModuleEmit, inside law 6's M / P read; switch `R11V287_EVALOPSCOPE_OFF`, read
  through `r11v287On` in src/R287.h; `R11V287_OFF` drops it, `R11U287_OFF` still drops everything).
  - A parameter read poisons ExprEval::evalFunc only as a DIRECT operand of a binary `+`, a comparison
    (`==`, `!=`, `<`, `<=`, `>`, `>=`), `===` / `!==` or `^`. A select of the parameter (`a + N[1:0]`) counts as the
    parameter.
  - The parameter must be declared by the function's own scope: the module, interface or program body for rule M, the
    package for rule P.
  - The unrefined law kept the call for ANY parameter below ANY operator. Golden folds `a - N`, `a * N`, `a / N`,
    `a << N`, `a & N`, `a | N`, `~N`, `-N`, `a + (-N)`, `a * N + 1`, `a && N`, `a + int'(N)`, and every read of a
    PACKAGE parameter from a module function (`p::W`, or wildcard-imported).

Binaries (built here, -j 2, system deps against ~/.local, slang 12.0.0+545f88b2e): pristine 99feee870ddf8af0d49063e9916ac921
(= the main tree's at the base), law 76dc7188c4ed5eef1e7b6efab889226c (= the implementer's), fix 54c3e410fa88f846b4d6109107812309.
Frozen before any measurement; every cmds.txt audited.

## The break (fresh cases, cases/VE and cases/VM)

- **43 fresh cases, 86 case-views, leave STRICT_EQUAL under the law** (pristine STRICT_EQUAL, law uhdm-cmp stage 1 with
  64 lines). All rc 0. Each is back to pristine's bytes under `R11U287_EVALKEEP_OFF` and under the refinement:
  - § evalFuncUnreducedOperandKeepsCall287: VE/ve01_pkgqual_param (`r = a + p::W` in a module function),
    ve02_imported_param (the same through `import p::*`), ve04_unary_param (`r = ~NF`), ve16_logic_ret_param
    (`r = a << NF`);
  - § evalFuncKeepOwnParamAddCmp287v (the matrix): VM im_add, im_addr, im_and, im_or, im_ret_add, im_shl, lp_and,
    lp_neg, lp_or, lp_shl, mi_neg, mi_umin, ml_addcast, ml_and, ml_logand, ml_neg, ml_or, ml_shl, mp_and, mp_neg,
    mp_or, mp_shl, mu_and, mu_neg, mu_or, mu_shl, pk_addcast, pk_and, pk_logand, pk_neg, pk_or, pk_shl, pq_add,
    pq_addr, pq_and, pq_neg, pq_or, pq_ret_add, pq_shl.
- Chain-keyed away census on the law: ve01, ve02, ve04, ve16 read **chain away 1, order-blind lost 82 to 113** in both
  views (the whole walk lost at stage 1); ve12_pkgfn_otherpkg (a package function reading ANOTHER package's
  parameter) chain away 1 at stage 1; ve11_real_param (`a * NF - 1`) stays stage 1 but its uhdm-cmp count grows 36 -> 64.
- Downstream on the law: **5 IDENTICAL -> DIVERGENT** (ve12_pkgfn_otherpkg, VM mi_neg, mi_umin, ml_logand, pk_logand).
- The decode (drivers/golden_keepfold.sh, evidence/vm_keepfold_matrix.txt: the Rhs-kind census of golden, pristine and
  law per cell; a kept call reads one constant fewer): 35 operator forms x 7 contexts. Module parameter, untyped
  module parameter, module localparam (mp, mu, lp, ml), an if condition (mi) and a package function's own parameter
  (pk): golden keeps exactly for `+`, comparisons, `===`, `^` and the conditional whose condition is a comparison; it
  folds for every other operator. A package parameter from a module function (pq, im): golden folds everything except
  `^`. A package function's return (pr): golden folds everything (the law already excluded it). `a ^ 3` with no
  parameter keeps too: reduceExpr has no `^` / `===` case, so it is not a parameter face (residue 1).
  In UHDM's ExprEval::reduceExpr the `+` case (vpiAddOp / vpiPlusOp) takes the unsigned branch and never sets
  invalidValue when the operand is not reduced; the comparisons go through reduceCompOp. `-`, `*`, `<<` and the
  unary operators fall back to get_double and fold. Golden's keep set follows those two paths.

## The refinement measured

| | pristine -> law | pristine -> fix | law -> fix |
|---|---|---|---|
| fresh grid, 284 dirs, 568 case-views | 450 moving, 198 entering, **86 leaving** | **222 moving, 194 entering, 0 leaving** | 228 moving, 86 entering, 4 leaving |
| implementer's grid, 147 dirs, 294 case-views | 138 / 122 / 0 | 138 / 122 / 0 (byte-identical to the law) | 0 |
| byte controls, 4714 dirs, 9429 case-views | 60 / 17 / 0 | 54 / 17 / 0 | 6 / 0 / 0 |
| probe databases (4087) | 38 | 38 (the same, byte-identical) | 0 |
| corpus databases (3365, fence-filtered mirrors) | 0 | 0 | 0 |

- Exit codes: no change on any line of any table, every line carrying rc.
- `R11U287_OFF` (law and fix) gives pristine's bytes on 862 of 862 grid case-views; `R11V287_OFF` gives the law's
  bytes on 862 of 862.
- uhdm-cmp line counts pristine -> fix: 120 change, all shrinking, none growing.
- The 4 law -> fix leavers are VM im_xor and pq_xor in both views: a package parameter under `^`. The unrefined law
  kept them only because it kept every parameter read. The fix returns them to pristine's bytes (pristine wrong
  too). It is the `^` face of residue 1, not a parameter face.
- The 6 control movers law -> fix return to pristine's bytes (pristine wrong too), so these toward-only gains of the
  law are given up:
  - tools/probe/r11v11u118repro/grid/v3/x03_vs_pkgbound_func_el: fullname under the law, stage 1 at 34 lines under
    the fix, as on pristine;
  - r11v11u118repro/grid/v2/w11_pkgbound_func in both views: 34 -> 36 lines, pristine's 36;
  - r11u131repro/inet/n08_func_blockparam in both views: bytes only, stage 1 on every binary.
  - x03 and w11 are `return cfgp::A2[3][cfgp::N-5:0]`: a package parameter inside the select bound of a package
    parameter, which golden keeps. That is pass 237's package-select face, not an operator read (residue 2).
- Downstream, pristine -> fix: 34 DIVERGENT -> IDENTICAL and none leaving IDENTICAL or EQUIVALENT (431 dirs). On the
  implementer's 147 dirs: 108 / 8 / 31 on pristine, 120 / 8 / 19 on both the law and the fix.
  - Law -> fix: 10 IDENTICAL -> DIVERGENT, all back to pristine's verdict: VM mi_addneg, mi_and, mi_div, mi_mul,
    mi_muladd, mi_or, mi_shl, mi_sub, im_gt, pq_gt.
  - Golden FOLDS these cells, so they are uhdm-cmp stage 1 on every binary: 36 lines on pristine and the fix, 64 on
    the law. The law kept the call where golden folds; the plugin then evaluated the function itself and matched
    the Surelog lane by accident.
  - The divergence is pristine's own fold VALUE: in `if (a * N) r = 1;` golden folds to the taken branch's literal
    `1` at 3:65, while ours folds to the first assignment's literal `0` at 3:47 (residue 3).
- Away census (drivers from tools/probe/r11u287repro, chain-keyed and order-blind):
  - pristine -> fix: chain away 0 on 220 of the 222 fresh movers, on all 138 of the implementer's grid movers and on
    all 54 control movers; lost 0 on all control movers;
  - positive control (binaries swapped): chain away 1 to 6 on VE/ve07, VD/vd07, VR/vr05, VA/va04, VP/vp03 and
    VM/mp_add;
  - the two exceptions are the law 4 finding below.
- Attribution: each of the 360 grid movers pristine -> fix returns to pristine's md5 under exactly one law switch.
  - The implementer's 138: EVALKEEP 66, GENCASHARE 22, PVRECVBODYTS 20, DEFGENSELNAME 12, IFARRINTTS 10, PVFLATTS 8,
    equal to the implementer's table.
  - The fresh 222: EVALKEEP 168, GENCASHARE 20, DEFGENSELNAME 10, PVRECVBODYTS 10, IFARRINTTS 8, PVFLATTS 6
    (evidence/grid_attr.txt).

## Reproduction of the implementer's numbers (every one bit for bit)

- Sweeps (`tests/sweep.sh --jobs 3`, own workdirs; every sweep exits 1 on the law-index check alone):
  - **pristine**: probe 3853 + 234; surelog 478 + 2 / 472 + 2; uhdm2rtlil 803/1/67 in both modes; downstream
    803/66/2/0; regressions, conversions and changes 0.
  - **law**: probe 3878 + 209 with the 25 conversions and the 1 change r11v4repro/v6 `fullname(2) -> fullname(1)` by
    name; the csv is byte-identical to the implementer's. surelog and uhdm2rtlil 0 / 0 / 0. The downstream csv is
    byte-identical to pristine's and to results/downstream_uhdm2rtlil.csv. The surelog csv differs from pristine's
    only in the LowMemLib / LowMemPkg testflags log path.
  - **fix**: the same as the law in every stage. The probe, uhdm2rtlil and downstream csvs are byte-identical to the
    law's.
- Probe bytes: 38 of 4087 move pristine -> law, exactly predict.txt's probe lines minus r10earl31repro/e1_psbound.
  0 of 4087 move law -> fix. The pristine and fix probe stages were rerun from the law worktree, because the
  databases carry the worktree path.
- The 25 conversions are STRICT_EQUAL in the elaborated view too; r11v4repro/v6 and r11u74repro b4_nonamesake_el stay
  fullname (evidence/probe_movers_both_views.txt).
- Byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, fence-filtered hard-link mirrors with 8 fenced
  row-mode databases left out): pristine -> law, law -> fix and pristine -> fix each read **0 of 3365** movers.
  SELFCHECK reads 3363 of 3365 each time, the known byte-identical twin 1DUnpackedArray.
- Firing census (r11u287repro/drivers/tracecensus.sh): the law's 54 lines are byte-identical to the implementer's
  evidence/predict.txt. The fix's 49 lines drop five over-predictions that moved no byte: e1_psbound, Earlgrey_0_1 d/t
  and FuncIoTypespec d/t (evidence/predict_law.txt, predict_fix.txt).
  - PROCESS: this census ran after the fix sweep, because the refinement was written after the law sweep. Its
    prediction (no byte mover law -> fix: every dropped line was already a non-mover) agrees with the measurement.
- Canaries on the law and fix csvs: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both
  (EXPECT_UNKNOWN=1 and 6).
- Binary-path audit (fence-filtered cmds.txt lists): on each of the P, L and F sweeps, 3265 of 3315 name that sweep's
  own frozen binary. The other 50 run no slang-uhdm; two of them, CoresSweRV and CoresSweRVMP, mention `slang-uhdm`
  only in the Surelog command's path.
- Determinism (r11u287repro/drivers/det.sh, three concurrent draws with the fix on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen): one hash per row-mode, each equal to the fix sweep's and to the
  implementer's law hashes (evidence/determinism_fix.txt).
- The implementer's grid (294 case-views): P -> L 138 moving, 122 entering, 0 leaving, 0 exit-code changes; O = P on
  294 of 294; lost 0 and chain away 0 on all 138, GS/s23_nested_member_el flat_away 1 with chain away 0.
- The implementer's byte controls (40 dirs, 3738 case-views): P -> L 40 moving, 4 entering (v5a_noovr_int_td and
  f08_param_arith in both views), 0 leaving. Widened by 55 dirs (evidence/controls_dirs.txt, 5690 case-views): 20
  moving, 13 entering, 0 leaving under both the law and the fix, chain away 0 on all.

## The other five laws attacked (fresh grid; every line with its exit code; all chain away 0 unless named)

- **§ ifArrPortSizeIntTsUnlocated287** (VA, 7 dirs). va04_named_conn_two (two instances, named connections) converts in
  both views. va05 (a port without a modport) and va08 (a second header parameter overridden) move toward golden at
  stage 1. va06 (defparam) moves 50 -> 48 lines. va02 (`[0:R-1]`), va03 (`[p::R]`) and va07 (`[R*2]`) are untouched.
  (va01, a size declared after the port, was rejected by every binary with exit 3 and dropped.)
- **§ defGenSelRefChainName287** (VD, 17 dirs). vd07_multidim (`rd[i][j][o -: 4]`), vd08_genlocalparam and
  vd12_param_width (`o +: W`) convert in both views. vd01 (`o -: p::W`) and vd15 (an enum constant index) move toward
  golden at stage 1. The cast, `$clog2`, call, concatenation, nested-generate, interface-index, port-connection,
  struct-member, always_ff and select-Lhs shapes are unmoved: vd02 to vd06, vd09 to vd11, vd13, vd14, vd16, vd17.
- **§ pvRecvBodyParamTs287** (VR, 7 dirs). vr02 (`logic [7:0]`), vr03 (a ternary initializer), vr04 (a port without
  a modport), vr05 (two shadowing localparams) and vr07 (the localparam also read in the body) convert in both
  views. vr01 (`A = C + 3`) and vr06 (untyped `5 + 2`) are untouched.
- **§ pvPatFlattenTsUnparented287** (VP, 6 dirs). vp03 (two receivers of one interface), vp04 (an array element)
  and vp06 (the receiver reading `q.CFG.DAT`) convert in both views. vp01 (an instance override), vp02 (a
  modport-qualified port) and vp05 (a type-parameter struct) are untouched.
- **§ genCaStructParamSharesPaOperand287** (VS, 11 dirs). vs06_localparam_cfg converts in both views. The other
  movers keep a first record on the sister ground: a signed sized literal `8'sd3` in the package pattern, whose
  ref_typespec golden names `work@dut` (pass 266's ParamEmit face). Every downstream verdict is unchanged.
  - **FINDING, not refined:** VS/vs08_gencase_el and vs10_gencase_nodefault_el read **chain away 3** (case generate,
    elaborated view only; the gen-if twins vs09 and vs11 read 0). The law makes the canonical walk align (pristine
    `fullname` with the walk diverging at #236, `part_select o` against `hier_path CFG.d`; fix `fullname(1)`, the
    sister's #137). The three away records sit inside the elaborated parameter CFG's typespec subtree: golden's
    `work@dut.CFG.p::cfg_t.n` / `.d` / `.s`, read `p::p::cfg_t::n` under the law.
  - Decode: under a select Lhs the law skips emitting the cell's `CFG.d` expression, and in a case generate that
    emission is what gave the elaborated CFG its private copy of the struct (golden's object). The law then binds
    the package listing.
  - The names are identity-derived inside a typespec subtree, which uhdm-strictcmp canonicalises. Restoring them
    would need either the discarded emission (orphan objects) or the copy made explicitly in ModuleEmit
    emitGenScopes. Both are left to the module/type ground.
  - vs02_signed_member reads order-blind lost 1 with chain away 0.

## Residues (ranked; all wrong on pristine too)

1. `^` and `===` / `!==` keep the call wherever an executed statement holds one, parameter or not (`a ^ 3` keeps in a
   module function, a package function, an if condition and a package return: VM ml_lit_xor, pk_lit_xor, mi_lit_xor,
   pr_lit_xor). reduceExpr has no case for them. This is a separate keep law for ModuleEmit's keep gates.
2. A package parameter inside a select bound of a package parameter in a module function's return
   (r11v11u118repro x03_vs_pkgbound_func, w11_pkgbound_func): golden keeps. This is § r237PkgSelKeeps' neighbour,
   reached by the unrefined law only by accident.
3. **Pristine's fold VALUE in an if-guarded function.** `function int f(int a); int r; r = 0; if (a * N) r = 1;
   return r;` folds to `0` (the first assignment's literal) where golden folds to `1`. VM mi_and, mi_div, mi_mul,
   mi_muladd, mi_or, mi_shl, mi_sub, mi_addneg, im_gt and pq_gt are uhdm-cmp stage 1 (36 lines) and DIVERGENT
   downstream on pristine and on the fix. This is a wrong value (ModuleEmit constCallFold's literal pick), and it is
   the implementer's residue 3 in its sharpest form.
4. Law 4's case-generate parameter copy (the finding above).
5. A function-local localparam (VE/ve03, ve13; stage 1 at 285 lines on every binary, another face) and a package
   function reading another package's parameter (ve12, stage 1 on every binary).
6. The implementer's residues 1 to 9 stand as written, with its sister-ground list. Two sister faces were seen again
   here: the signed sized literal in a package pattern (VS, ParamEmit) and a package parameter in a definition-view
   generate select width (VD/vd01, stage 1).

## Process

- Fence: $FENCED read fail-closed through r11u287repro/drivers/env.sh. Every corpus path list (mirrors, cmds.txt
  audit, probe byte compare, controls) was built first and filtered by word boundary before any file was opened.
  The firing census ran with the harness filter built from $FENCED. No fenced source or database was read or
  dispatched outside the gate sweeps, and no fenced name appears in this directory.
- **SLIP (no effect):** one completion waiter used `pgrep -u <me> -f v11u287_controls.sh`, a pattern contained in
  its own command line, so it could never finish. It was stopped by its own task id; nothing was signalled, and
  completion was read from the output's line count. No other agent's process was listed or signalled.
- Nothing was written to the main tree. Scratch: /tmp/v11u287_*, worktrees /tmp/wt_v11u287, /tmp/wt_v11u287pris
  and /tmp/wt_v11u287fix.
- Two fresh cases were rejected by every binary with exit 3: va01 (the size used before its localparam) and the
  first draft of vd09 (a variable indexed part select on a continuous-assign left side). va01 was dropped and vd09
  rewritten with always_comb; only the rewrite is gridded.
- The VM cells were generated by drivers/gen_vm1.py, gen_vm2.py and gen_vm3.py (first lines then set to
  § evalFuncKeepOwnParamAddCmp287v). drivers/golden_keepfold.sh is the keep / fold census.
- Drivers: grid.sh, attr.sh, controls.sh, gridsum.py, golden_keepfold.sh. They reuse
  tools/probe/r11u287repro/drivers (case.sh, awaycv.sh, tracecensus.sh, det.sh, bvmirror.sh, dscases.py).
