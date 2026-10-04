# v11u236 — adversarial verification of r11u236 (pass 236, the expression/parameter ground)

Base `6152687b` (matrix-1.87). This pass verifies the implementer's patch `/tmp/r11u236.patch` (md5
`ddb09d8f043b30cb540b92143dccaf39`, the nine laws of [r11u236repro/README.md](../r11u236repro/README.md)). It
reproduces every headline number and then attacks the laws with 102 fresh cases. Three of the laws broke legal SV
where pristine was right. Each break is fixed here by a refinement behind its own switch. The verified patch is
`/tmp/r11u236.verified.patch`: the implementer's patch plus the three refinements in `src/ExprEmit.cpp`,
`src/ParamEmit.cpp` and `src/R236.h`, plus this directory and the regenerated `tests/LAWS.md`.

The four slang-fenced tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh`, fail-closed. The gate sweeps dispatch every row themselves. `evidence/sweeps/` keeps the fix sweep's four csvs, with the fenced
rows stripped, and the three sweeps' summary logs. The pristine and law csvs are not kept: the pristine csv equals
the committed baselines, and the law csv equals the fix csv.

## Verdict

**The implementer's numbers reproduce bit for bit. Three laws are refined.**

- § namedCallArgFormalTs236 stamped named-call actuals in contexts where golden keeps them bare.
- § caOpArgIntFormalTs236 did the same for operation actuals.
- § pkgDefPatSubstShared236 shared member copies across packages.

On the fresh cases, the implementer's binary moves 20 case-views from judge-equal to stage-1 NOT_EQUAL. 18 of them
were STRICT_EQUAL at the base. The verified binary moves none away. It writes **the implementer's bytes on all 2560
corpus databases, all 4087 probe databases and all 805 downstream lane databases**, so every gate number, every
corpus mover and every targeted row stays exactly as the implementer reported.

| row-mode | base | after (verified binary, `evidence/sweeps/fix_surelog.csv`) | first record after |
|---|---|---|---|
| Earlgrey_0_1 d/t | `differ:fullname(18)` | `differ:fullname(5)` | #121994 `ref_obj bank`: golden `work@flash_phy.gen_flash_banks.i_core.host_req_i.bank`, ours `...host_req_i.host_rsp_avail.bank` (ModuleEmit `emitDefGenStmts`, ground B) |
| BlackBePipeInt d / t | `differ:type(1)` | `differ:fullname(73)` / `(75)` | #24671: golden `bp_be_pkg::all_cfgs_gp::bp_common_pkg::bp_proc_param_s::cc_x_dim`, ours `work@bp_be_pipe_int.bp_common_pkg::bp_proc_param_s.cc_x_dim` (N2471, ground A). The base walk diverged at #15272 (`objects 339479 vs 341734`, "walk diverged"), so the larger count is a later divergence. The chain-keyed away census reads 0 lost. |
| MiniAmiq d/t, SeqDriver d/t | `differ:fullname(2)` | `differ:depth(1)` | MiniAmiq #64612: golden `int_var _byte uvm_pkg::uvm_oneway_hash::_byte`, ours an operation at 378:21 (a binding inside the importer clone) |
| FuncStructVal t | `differ:depth(1)` #13254 | `differ:depth(1)` (later) | the default row's ground-B head |

```
BlackBePipeInt,default,STRICT_NOTEQUAL,differ:fullname(73),,differ:fullname(73)
BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:fullname(75),,differ:fullname(75)
Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
Earlgrey_0_1,testflags,STRICT_NOTEQUAL,differ:fullname(5),,differ:fullname(5)
MiniAmiq,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
SeqDriver,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
```

**Probe conversions** (STRICT_NOTEQUAL -> EQUAL; `results/` untouched): `r10earl34repro/v1_view`,
`r10v65repro/a6_def` and `r10v65repro/a8_orphan`. **One probe change:** `r10v169repro/v169_g_control`,
`differ:fullname(14) -> differ:line(10)`.

## The refinements (each behind its own switch; `R11V236_OFF` drops all three and restores the implementer's bytes, `R11U236_OFF` restores pristine)

### § namedCallArgCtx236v (switch `R11V236_NAMEDCTX_OFF`; ExprEmit stampCond48, the § namedCallArgFormalTs236 disjunct)

The law fires on every named call outside a subroutine body. Golden stamps a named call's actuals only on a
continuous assignment's right side. That right side can be the call itself, or a call nested only in binary
operations whose other operands are literals: `f(.q(b), .p(a)) > 0` and `h(.x(a), .y(b)) + 0` are stamped (cases
r11u236 N/n15, A/m1, m3, m4, m6). Golden keeps every actual bare in these cases, where pristine was right and the
law was wrong:

- **A net, a variable or another call beside it in the operation:** `h(.x(a), .y(b)) + a`, `a + f(...)`,
  `g(...) + g(...)`, and the nested `h(.x(h(.y(a), .x(b))), .y(b)) + r` (cases A/k5_named, k6_named, k8_named_el,
  m2, m7, a06; STRICT_EQUAL at the base, stage 1 under the law). Case a05_el is the same shape.
- **An indexed part-select base or width, or a part-select bound:** `v[h(.x(1), .y(2)) +: 4]` and
  `v[h(.x(2), .y(1)):0]` (A/a15 STRICT_EQUAL -> stage 1; A/a17 judge-equal -> stage 1).
- **A port connection:** A/a13, stage 1 at the base on another face; the law moves bytes there.

**Refinement:** the law fires only when the call's UHDM parent chain, through enclosing calls, reaches a
`cont_assign`. Through operations it also fires, but only when the syntax walk up to the assignment meets binary
operations (or parentheses) whose other operand is a literal. In every other context it abstains and traces
`namedCallArgCtx236v`.

### § opArgCallCtx236v (switch `R11V236_OPCTX_OFF`; ExprEmit argCtxOk, the § caOpArgIntFormalTs236 disjunct)

The law stamps an operation actual of an `int` formal whenever the operation reads a net or variable. Golden keeps
it bare in these cases:

- **The call is an operand of an operation:** `f(a + 1) + 1` (B/b05_el STRICT_EQUAL -> stage 1; the default view's
  elaborated listing is stamped in golden and stays unstamped, pre-existing) and `f(v[3:0] + v[7:4]) ^ a` (B/b08
  both views).
- **The call is a select index or bound:** `v[f(a + 1) +: 4]`, `v[f(a - 1)]` (B/b15_el STRICT_EQUAL -> stage 1).
- **The call is a port connection actual:** `.i(f(a * 2))` (B/b11, B/b13).

**Refinement:** the stamp is lifted only when the call's parent chain, through enclosing calls, reaches a
`cont_assign`. This covers the law's own targets: CA c05, `f(f(a) + 1)` (B/b07), generate and interface-body
assignments (B/b14, B/b11's interface), and an implicit net (B/b12).

### § pkgDefPatHomeOnly236v (switch `R11V236_PKGHOME_OFF`; ExprEmit pkgPatSubstValue branch, ParamEmit emitParameters, R236.h `pkgDefPatShareScope236`)

The law's memo was keyed only on the source object and never scoped. So another package's reads of `pk::dflt_p.a`
were handed the declaring package's copy:

- across packages (E/e05: `pb_p.a` and `pc_p.a` one object);
- across two parameters of one reading package (E/e09: `pb_p.a`, `pb_q.a` and `pk::own_p.a`, all object 24).

Golden gives each of them its own object (`objid236`: 490, 642 and 207). These cases are stage 1 at the base on
another face, so no gate sees the identity. **Refinement:** ParamEmit records the declaring package's scope next to
the flag. A read shares only when every parameter it names is declared in that scope, and otherwise traces
`pkgDefPatHomeOnly236v`. The refinement fires nowhere in the corpus or the probe, and BlackBePipeInt is unchanged.

## Binaries (frozen before any measurement; every `cmds.txt` audited)

| binary | md5 |
|---|---|
| pristine `/tmp/v11u236_bin/pristine` | `ed8c598e76da99bd014a5ba69e751d23` (= the base's; reports slang 12.0.0+545f88b2e) |
| law `/tmp/v11u236_bin/law` (the implementer's patch, rebuilt here) | `ca838e5b2888680e04a3ec8c9fcd4f1c` (= the implementer's) |
| fix `/tmp/v11u236_bin/fix` (the verified patch) | `b876e0a340744287a72181d2396ae5d6` |
| uhdm-strictcmp / strictcmp_x | `fa6e4f42f252ae0ab69d9845003e71c5` / `886f030233ecdbcce7d0e29ac0c4df2c` (both = the implementer's) |

Every corpus `cmds.txt` with a slang line names its sweep's binary: 3265 per sweep. The remaining 50 rows are
Surelog-only. The development binaries `fix1`–`fix3` ran only on cases.

## Gates (`tests/sweep.sh --jobs 3`, all three sweeps run from the worktrees with SLANG_UHDM exported)

| stage | pristine `/tmp/v11u236_wpri` | law `/tmp/v11u236_wlaw` | fix `/tmp/v11u236_wfix` |
|---|---|---|---|
| probe | 3454 + 633, 0/0/0 | 3457 + 630, **regressions 0, conversions 3, changes 1** | identical csv to law |
| surelog | 932 + 22, 0/0/0 | 932 + 22, **0 / 0 / 8** (BlackBePipeInt, Earlgrey_0_1, MiniAmiq, SeqDriver, d/t) | identical rows to law |
| uhdm2rtlil | 1604 + 2, 0/0/0 | 0/0/0 | 0/0/0 |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, verdict diff 0 | identical csv |

- **`law index STALE`:** every sweep prints it. The base cannot carry its own commit. `law_index.py --check`
  reads current with the verified patch.
- **uhdm-cmp:** every corpus mover's status stays STRICT_NOTEQUAL (judge-equal), so uhdm-cmp reads 0 lines.
- **Canaries on the fix csvs:**
  - `canaries.sh` surelog ok=48 changed=4: Earlgrey_0_1 d/t and SeqDriver d/t, the intended changes.
  - `canaries.sh` uhdm2rtlil ok=16 changed=0.
  - `EXPECT_UNKNOWN=1 ctcan2.sh` surelog ok=56 changed=2: BlackBePipeInt d/t, intended.
  - `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS.

## Movers

**Prediction.** `drivers/census.sh` with the fix binary and `R11U236_TRACE` (corpus `--filter` from `$FENCED`,
every probe case), then `drivers/predict.py`. The refinements' own traces are listed apart, because they write no
byte. The prediction was frozen at 18:48 before the fix sweep: [evidence/census/](evidence/census/), md5
`05759538a7ab2e8dacae5cdcb85daf67`.

- **Against pristine:** the implementer's 19 rows. Scr1SvTests d/t and three probe rows (r10v122repro/q4inst,
  q6clone, r10vbuvm29repro/gv29_b_positions) carry only a § caOpArgIntFormalTs236 predicate trace, so they are
  predicted as non-movers.
- **Against the law binary:** 0 databases. The refinement traces fire only on those same five rows, which the law
  does not move. § namedCallArgCtx236v and § pkgDefPatHomeOnly236v fire nowhere.

**Measured.**

- **Against the law sweep:** byteverify 0 / 2560 corpus, 0 / 4087 probe, 0 / 805 downstream lanes (positive
  control: two different lanes compared read as a mover).
- **Against pristine:** byteverify 10 / 2560: BlackBePipeInt, Earlgrey_0_1, FuncStructVal, MiniAmiq and SeqDriver,
  each d/t, all predicted. Probe: 4 / 4087, all predicted (v1_view, v169_g_control, a6_def, a8_orphan), measured
  against a pristine probe sweep re-run from the same worktree.

The first pristine sweep ran from `/tmp/wt_v11u236pris`, so every probe database embeds a different `file:` path
and differs by bytes. That is a path artifact, not a mover.

**Downstream:** 0 of 805 lane databases move, pristine -> law and law -> fix.

**SELFCHECK `2559 / 2560 flagged`.** byteverify's negative control compares every patched file against ONE fixed
pristine file, the first path. For that first path, the comparison is the same database in the two sweeps, which
did not move, so it is the one path the control cannot flag. 2559 is the correct reading.

## Away-moved-record census (chain key)

- **Corpus and probe, law vs pristine** (`drivers/awayrows.py` with strictcmp_x): chain-keyed away 0 on all 14
  movers, toward 78 (Earlgrey_0_1 16 per mode, BlackBePipeInt 10, MiniAmiq 3, SeqDriver 2, v1_view 8,
  v169_g_control 4, a6_def 2, a8_orphan 2). The fix binary writes the same bytes, so the same numbers hold.
- **Flat key:** 2 away each on SeqDriver d/t and FuncStructVal t, the records the implementer explains.
- **Cases** (`drivers/awaychain.py`, pristine vs fix, every case-view with records on both sides): 134 case-views,
  0 lost, 768 toward ([evidence/grid/away_chain_cases.txt](evidence/grid/away_chain_cases.txt)).

## Determinism

`drivers/det.sh` ran three concurrent harness runs of the fix binary on Earlgrey_0_1 and the five UVM rows. It gives
one hash per row-mode on all 11 row-modes with a database (Scoreboard t is SLANG_REJECT). Each hash equals the
fix sweep's and the implementer's law hash ([evidence/det_fix.txt](evidence/det_fix.txt)). The UVM order-blind
distance is unchanged from the implementer's measurement, because the bytes are identical.

## Grids

**The implementer's 48 cases, rerun** (pristine, law, fix, both views; [evidence/grid/](evidence/grid/)):

- 41 case-views enter STRICT_EQUAL under the law and under the fix. 16 enter judge-equal. 76 move bytes. None
  leaves.
- `R11U236_OFF` gives pristine bytes on all 96 case-views. `R11V236_OFF` gives the law's bytes on all 96.

**The fresh cases, 102 cases** in `cases/A`–`H`. Each first line names its law. Both views, 204 case-views, every
exit code 0 on all five binaries and modes.

| binary | leave judge-equal | leave STRICT_EQUAL | enter STRICT_EQUAL |
|---|---|---|---|
| law | **20** | 18 | 50 |
| fix | **0** | 0 | 51 |

The case-views the law breaks are A/a05_el, a06 d/el, a15 d/el, a17 d/el (judge-equal, endcol), k5_named d/el,
k6_named d/el, k8_named_el, m2 d/el, m7 d/el, B/b05_el, b08 d/el and b15_el.

**Switch grid** ([evidence/grid/grid_switches.txt](evidence/grid/grid_switches.txt), 2448 runs, every exit code 0).
Each of the twelve switches alone changes only its own law's cases. Each `R11V236_*_OFF` alone gives the law's bytes
on every case it touches:

| switch | case-views | law's bytes |
|---|---|---|
| NAMEDCTX | 26 | 26 |
| OPCTX | 16 | 16 |
| PKGHOME | 8 | 8 |

**Downstream verdicts** of all 102 fresh cases (`drivers/dscase.py`, the harness's `one`) are identical on pristine,
law and fix: 96 IDENTICAL, 5 EQUIVALENT (A/a09, B/b11, B/b13, C/c06, G/g07) and 1 STATUS_DIFF (A/a13), all
pre-existing.

**Per law on the fresh cases** (default and elaborated view):

- **§ hpSelIdxPkgFoldTsOwner236**
  - holds: C/c07 (instance depths two and three) converts; c01, c03, c04 and c05 move toward with 0 lost.
  - c06 (interface): abstains, bytes unchanged.
  - c02: stage 1 at the base.
  - The law's table is incomplete. In an elaborated continuous-assignment lvalue, golden names the chain only when
    the right side is a constant, an unbased literal or a net. With an operation, a member path or a call (C/c05),
    golden keeps `work@top`. The mid-path READS of an XOR right side read the chain in golden; the law gives
    `work@top`. Pristine was wrong on both, so these are residues, not breaks (c05 26 -> 9 records, 0 lost).
- **§ hpMidSelBaseSelDotted236:** G/g02, g03 (three levels) and g04 (package indices, net right side) convert. g05
  and g06 (procedural) and g08 (generate) are unchanged or moving toward.
- **§ defConnIpsFoldTsOwner236:** D/d04, d06 (`-:`), d08, d09 and d11 convert both views. d07_el and d12_el move
  later (fullname -> endcol, 0 lost). d05 (instance array) and d10 (if-generate) abstain. D/d01 (package-qualified
  `pk::H -: pk::W`) is untouched: golden stamps the base `work@mid.u_s.a_i.x`, ours writes no typespec, pre-existing.
- **§ pkgPatArithLeftParenSpan236:** E/e10, e12 and e14 convert both views (multiplicative, shift, member reads,
  spaced and doubled parentheses). e15 (operands across lines, a macro-conditional operand) stays endcol, 0 lost.
  e11 and e13 are stage 1 at the base.
- **§ pkgDefPatSubstShared236:** E/e08 converts (localparam int, an unpacked array of patterns, a parameter). e06
  moves type -> line, 0 lost. The cross-package faces e04, e05 and e09 led to § pkgDefPatHomeOnly236v.
- **§ cloneRetParamFoldTsName236:** F/f02 moves fullname -> depth/line (16/10 toward, 0 lost). In f04, f05 and f06
  (both branches of an if, an operation, a qualified return), the computed reference names match golden's counts
  (`q::rev_string` 2 = golden 2), though those cases are stage 1 at the base on other faces.
- **§ namedCallArgFormalTs236** (with § namedCallArgCtx236v): A/a02 (net declaration), a14 (implicit net), k1, k3,
  k4 and k7 (literal, enum constant, parameter and enum-formal actuals) and m1/m3/m4/m6 convert. a01 (processes) and
  a07 (class static) are unchanged.
- **§ caOpArgIntFormalTs236** (with § opArgCallCtx236v): B/b06, b07, b12 and b14 convert, and b04_el converts only
  with the refinement. b09 (conditional branches) is unchanged.
- **§ patLeftoverCopyShared236:** H/h01 is stage 1 at the base (the shapes the implementer reports); the corpus row
  FuncStructVal t is the witness.

## Residues (ranked)

1. **Named calls under an operation, default view (§ namedCallArgCtx236v's boundary).** With an enum formal golden
   stamps the first call's net actual even beside another call (`g(.y(P), .x(e)) + g(...)`, A/k8_named, pre-existing
   missing stamp). The positional form over-stamps in an operation where golden is bare (A/k6_pos, k5_pos: ours
   stamps `a` in `h(a, b) + a`, pre-existing). Golden's rule looks like Surelog's reduce of the operation evaluating
   its first call operand and then aborting. It is not decoded.
2. **§ hpSelIdxPkgFoldTsOwner236's right-side distinguisher** in elaborated continuous-assignment lvalues (C/c05,
   above), and the chain names of mid-path reads inside an operation right side.
3. **The operation actual of an `int` formal** under an operation: golden stamps it in the default view's elaborated
   listing only (B/b05), and not in the definition listing or the -elabuhdm view. A concatenation actual of an
   `integer` formal (B/b02 `{v, v}`) is stamped by golden and not by ours.
4. **Package-qualified indexed part-select bases in definition port connections** carry no typespec in ours
   (D/d01).
5. The implementer's residues (N2471, the importer-clone loop-variable binding, Earlgrey #122230 and #130430, the
   ground-B faces) stand unchanged. The fix writes the same corpus bytes.

## Drivers

All drivers are in `drivers/`, and every one reads `$FENCED` fail-closed. The new ones:

- `run.sh`: many binaries over case dirs, both views.
- `awaychain.py`: chain-keyed away census from strict record dumps.
- `dscase.py`: downstream verdicts of cases.

The others are copied from r11u236repro: `env.sh`, `case.sh`, `census.sh`, `dscensus.py`, `predict.py` (refinement
traces listed apart), `bvmirror.sh`, `det.sh`, `uvmdist.sh`, `awayrows.py`, `strictcmp_x.cpp` and `cc_x.sh`.

## Process notes

- **Worktrees and scratch:** `/tmp/wt_v11u236` (law, then fix) and `/tmp/wt_v11u236pris` (pristine), scratch
  `/tmp/v11u236_*`. No submodule was initialised.
- **Builds:** `-j 2`. The pristine binary was frozen before the law build started, and every refinement build came
  after the pristine freeze.
- **Fence:** no fenced test was dispatched by this pass outside the gate sweeps, and none was read, decoded or run.
  Two incidental exposures, both without any decode:
  - A `pgrep -af` listing printed another agent's running command line, which carries the fence as a `--filter`
    alternation.
  - One byte comparison of the law and fix sweeps (`cmp -s` over every corpus `slang.uhdm`) opened the fenced rows'
    databases before its output was filtered. Only equal/differ was computed, and nothing was printed for them.
    Every later comparison went through `bvmirror.sh`, or through path lists filtered before any read.
- **Killed processes:** none.
- **Guards:** every tool call through a variable was guarded with `[ -x ]`.
