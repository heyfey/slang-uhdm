# v11u276 — adversarial verification of r11u276 (pass 276, the expression/parameter ground)

Verifier of tools/probe/r11u276repro (three laws in `src/ParamEmit.cpp` behind `src/R276.h`), base 7c896f022.
Fresh worktrees /tmp/wt_v11u276 (law + fix) and /tmp/wt_v11u276pris (pristine); scratch /tmp/v11u276_*.

**Verdict: TWO BREAKS FOUND AND FIXED; the fixed laws ship.** § caUserCallRhsNotReduced276 lost golden records
on legal SV where pristine was right (3 fresh case dirs, 6 case-views leaving STRICT_EQUAL, chain away 4 each), and
§ caReduceOpKindGate276 gates `<->`, which Surelog writes as vpiEqOp, a listed operator (one fresh case dir, chain
away 4 on both views, on a database slang-uhdm exits 4 on). Two refinements, each behind its own switch, cure both;
every headline number of the implementer reproduces bit for bit, and the fixed binary's gate sweeps are identical to
the law's (0 of 2560 corpus, 0 of 4087 probe, 0 of 805 downstream databases differ between law and fix).

## Binaries (frozen in /tmp/v11u276_bin before any measurement)

| binary | md5 | |
|---|---|---|
| pristine | 6ebf1ae4e510656f6b0873c644546463 | equal to the base's documented build |
| law (implementer's patch, /tmp/r11u276.patch md5 3b8046e1...) | c9cccf2af0a2de4f21db2ab42016106d | equal to the implementer's law.bin |
| fix (law + the two refinements below) | d707d51c03fe6bd24682ede3eb2dd9d0 | the delivered binary |

Two earlier fix builds (fix1 0c3605a3 with CALLOPARG only; 8b87f786 without the EQUIVOP trace line) were
superseded; the first fix sweep, started on 8b87f786, was stopped by its own task id before it finished and its
workdir deleted unread. Every number below is on d707d51c.

## The refinements (src/ParamEmit.cpp, switches read through `r11v276On` in src/R276.h)

`R11V276_OFF` drops both and gives the law's bytes on 276 of 276 grid case-views; `R11U276_OFF` still gives
pristine's bytes on 276 of 276. Both are traced under `R11U276_TRACE`.

### § callOpArgNotReadEither276v — `R11V276_CALLOPARG_OFF`

The law skipped bare-name arguments of a module-local call but still harvested an OPERATION argument (whole-fold
harvest when it folds, operand scan otherwise), and its README cites CA/ca04 `assign o = f(K + 1)` as the measured
case for that. ca04 does not show it: golden keeps K's LOCATED typespec there (`logic_typespec dut.sv 4:14-4:26`
and its range constants 4:20 / 4:21 / 4:24, ours unlocated) on pristine and on the law alike (`differ:file`
records #66 to #69). Where the call does not fold (the function reads a module net), pristine harvested nothing
and was right, and the law's op-argument harvest broke it:

    VC/vc05_nonconst_fn_oparg   function f(x) return x + n;  assign o = f(K + 1);
      pristine STRICT_EQUAL 129 / 127 objects -> law STRICT_NOTEQUAL file (d and e), chain away 4 each
      golden  #69 logic_typespec dut.sv 4:14-4:26   law: logic_typespec 0:0-0:0 (+ range, two constants)
    VA/va02_netop   f(K & n[11:0])               the same: STRICT_EQUAL -> file, away 4 (d and e)
    VA/va12_nonconst_netsel   f(K[7:0] + 8'd1), f reads n   the same: STRICT_EQUAL -> file, away 4 (d and e)

The rule, measured on 14 op-argument shapes (VA: a select plus a literal, a net operand, two parameters, unary
minus, a conditional, `*`, `<<`, `&`/`|`, a for-generate, an if-generate, a child override, a macro, a package
call control): no argument of a module-local call reads a parameter, bare or operation. The refinement skips every
argument. It converts va02, va12 and vc05 back to STRICT_EQUAL and moves ca04, va01, va03-va08, va11 and vc24 toward
golden (`file -> type`: the four parameter-typespec records clear and the walk reaches the sister's elaborated
call fold), away 0 on all.

### § equivOpIsEqOp276v — `R11V276_EQUIVOP_OFF`

The law's gate lists `<->` (LogicalEquivalence) as an operator the reducer's switch does not list. Surelog writes
`a <-> b` as vpiOpType 14, vpiEqOp (golden VR/vr07: the operation under the concatenation reads `vpiOpType:14`
where `->` in vr06 reads 50), and vpiEqOp is listed, so the reducer recurses. On VR/vr07 the law lost 4 golden
records (chain away 4, d and e) where pristine agreed. slang-uhdm exits 4 on LogicalEquivalence (unsupported
construct) on every binary, so no gate row can carry it; the fix keeps the partial database at pristine's bytes.
The operator now recurses unless the switch is set.

## Reproduction of the implementer's headline numbers (all bit for bit)

- Sweeps (tests/sweep.sh --jobs 3; evidence/sweep_P.txt, sweep_L.txt, sweep_F.txt):
  - pristine: probe EQUAL 3755 + STRICT_NOTEQUAL 332, probe.csv byte-identical to 7c896f02's results/golden_probe.csv;
    surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803 / 66 / 2 / 0.
  - law: probe 3761 + 326, regressions=0 conversions=6 changes=0. The six are r10earl_repro qa28 (type(1)), ss, tl,
    ud, ue (file(3)) and r11u108repro/grid/f4/c12_const_fold (file(4)), all -> EQUAL. surelog and uhdm2rtlil 0/0/0.
    Downstream 803 / 66 / 2 / 0, and the csv is byte-identical to pristine's.
  - fix: probe.csv byte-identical to the law's (the same six conversions, `r10earl_repro/qa28,EQUAL,,equal` ...
    `r11u108repro/grid/f4/c12_const_fold,EQUAL,,equal`), surelog and uhdm2rtlil regressions=0 conversions=0
    changes=0. Status and strict columns are identical to pristine's row by row; the only text difference is the
    LowMemLib / LowMemPkg testflags detail's log path. uhdm2rtlil.csv is byte-identical. Downstream 803 / 66 / 2 / 0,
    csv byte-identical to pristine's and to results/downstream_uhdm2rtlil.csv.
  - Every sweep exits 1 on the law-index check alone, pristine included: at the base `scripts/law_index.py --check`
    reads STALE in a clean worktree, because the committed index cannot carry its own landing commit (the INDEX
    QUIRK). The patch's tests/LAWS.md is regenerated last and reads `law index current`.
- byteverify (drivers/bvall.sh: r11u272repro/drivers/bvmirror.sh fence-filtered hard-link mirrors,
  tools/probe/r11v75repro/byteverify.sh with SELFCHECK=1; probe and downstream by cmp over $FENCED-filtered path
  lists; evidence/byteverify_law.txt, byteverify_fix.txt):
  - Corpus: PATH_SETS_IDENTICAL 2560, MOVERS 0 / 2560, law and fix alike, and fix against law 0 / 2560. The mirrors
    skip 8 fenced databases.
  - Downstream: 0 of 805 move.
  - Probe: 6 of 4087 move, exactly the six conversions, law and fix alike; fix against law 0 of 4087.
  - SELFCHECK reads 2559 / 2560 because the self-check compares every file against one fixed file, and that file is
    identical to itself. That is pass 201's artefact, not a mover.
  - The probe databases carry each worktree's root in VpiFile. I first compared the pristine sweep run from
    /tmp/wt_v11u276pris and that read 4087 movers. The pristine probe stage was then rerun from the law worktree
    (/tmp/v11u276_wdQ, probe.csv identical to the pristine sweep's), and that rerun is the reference above.
- Grid: the implementer's 58 dirs (116 case-views) re-run by drivers/grid3.sh. Pristine to law: 52 moving, 20
  entering STRICT_EQUAL, 0 leaving, 0 exit-code or uhdm-cmp changes, R11U276_OFF = pristine on 116 / 116, the same
  numbers as the implementer's. Pristine to fix: 54 moving (ca04 d/e added, toward), 20 entering, 0 leaving.
- Firing census (drivers/tracecensus.sh with the fix binary, run before the fix sweep, frozen as
  evidence/predict.txt, md5 e86ac921 in predict.md5): 22 lines.
  - 21 are the implementer's lines, identical to theirs.
  - The new lines are `probe r10vrgg8repro__cells__v8_actual_neg callOpArgNotReadEither276v:1` and 44
    callOpArgNotReadEither276v firings added to `surelog Rggen/default`.
  - Neither database moves: that trace names every skipped operation argument, not a change of the harvested set.
    v8_actual_neg's argument `-a` holds no parameter, and Rggen default is byte-identical in all three sweeps.
  - Every byte mover was predicted by name.
- Canaries (evidence/canaries.txt): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, and ctcan2 PASS on both,
  for all three sweeps.
- Binary-path audit (evidence/binary_audit.txt): over the fence-filtered cmds.txt list, 3265 of 3315 name each
  sweep's own frozen binary. The other 50 run no slang binary: 48 have no slang line, and 2 (CoresSweRV,
  CoresSweRVMP default) name only the repository path in a Surelog command line.
- Determinism (r11u272repro/drivers/det.sh, three concurrent draws with the fix binary; evidence/determinism.txt):
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen read one hash per row-mode with a
  database. That hash equals the pristine, law and fix sweeps' hash on every row-mode.

## Attack: 80 fresh case dirs, both views (cases/VC, VO, VR, VA; each case's first line names its law)

drivers/grid3.sh runs pristine, the law, the fix, the fix with R11V276_OFF, the fix with R11U276_OFF and the fix
with each of the five switches. Every line carries the exit code (evidence/grid3.txt; summaries in
grid3_summary_*.txt). On the 160 fresh case-views:

| | moving | entering STRICT_EQUAL | LEAVING | exit-code changes | uhdm-cmp line changes |
|---|---|---|---|---|---|
| pristine -> law | 74 | 24 | **6** (vc05, va02, va12; d and e) | 0 | 2 |
| pristine -> fix | 84 | 24 | 0 | 0 | 2 |
| law -> fix | 26 | 6 | 0 | 0 | 0 |

- The two uhdm-cmp changes are VO/vo07_signed_formal (`logic signed` parameter and formal). Its default view goes
  from stage 1 (26 lines) to 0 lines (STRICT_NOTEQUAL type). Its elaborated view goes from 26 to 50 lines: the K
  range record clears and the walk now stops at the sister's func_call fold, the same 50 lines every CA elaborated
  view reads. Both changes move toward golden.
- Over all 276 case-views (the implementer's 116 plus the fresh 160), the fix against pristine has 138 movers, 44
  entering and 0 leaving.
  - Each mover returns to pristine's bytes under exactly one law switch: CACALLRHS 82, REDUCEKIND 40, RHSOWNTS 12,
    plus CALLOPARG 20.
  - The CALLOPARG movers also restore under CACALLRHS, which contains the refinement.
  - Two dirs need two switches. CA/ca02_child_override needs CACALLRHS and RHSOWNTS together, as the implementer
    reported. VO/vo05_header_param_ca (two instances, one overridden) needs the same pair.
- Away census (chain-keyed, r11u272repro/drivers/awaychain.py with strictcmp_x built by r11u273repro/drivers/cc_x.sh,
  md5 886f0302; drivers/awaygrid.sh):
  - Fix against pristine: away 0 on all 138 movers (evidence/away_pris_fix.txt).
  - Fix against law: away 0 on all 28 (evidence/away_law_fix.txt).
  - Positive control, the binaries swapped on vc05 and va02 (fix as the base, law as the new binary): chain away 4
    on each (evidence/away_poscontrol.txt).
  - The first law-only run (evidence/grid_first_law*.txt) is where the two breaks surfaced.
- Downstream on the 80 fresh dirs (r11u272repro/drivers/dscases.py; evidence/downstream_cases_*.txt): pristine and
  fix give the same verdict on every dir.
  - Totals: 73 IDENTICAL, 4 EQUIVALENT (va01, vc03, vc11, vr21), 1 DIVERGENT (vr30, a child override
    `#(.P(A ^ 8'hF0))`) and 2 STATUS_DIFF (vo03 and vr07, the slang lane NO_GATES). All of these are pre-existing.
  - The slang lane's .il, _nohier.il and _synth.v are byte-identical between the binaries (240 files).
- On the implementer's 58 dirs: 55 IDENTICAL and 3 EQUIVALENT on both binaries, 174 files byte-identical.

Shapes covered, with the movers' fields:

- VC, the call law:
  - The function's home: $unit (vc01), `import q::*` and `import q::f` (vc02, vc17, which abstain because their home
    is a package), a static class method (vc03), a generate block (vc07), an interface port `i.f(K)` (vc08), a child
    instance's function `s.f(K)` (vc23).
  - Select arguments in a for-generate and in the body (vc04, vc26), non-constant functions (vc05, vc06), a
    parameter also read directly or in a part-select bound (vc09, vc22).
  - Overrides: an override expression (vc10), a depth-3 pass-down (vc20).
  - Controls: `f(K) + 1` (vc11), `n[f(K) -: 4]` (vc12), `always_comb o = f(K)` (vc21).
  - An implicit net (vc13), a typedef formal (vc14), `int` (vc15), an untyped K (vc16), a static function (vc18),
    two calls (vc19), a concatenation argument (vc24), a $unit function in a for-generate (vc25).
- VO, the formal-typespec law: a call in a dimension, a localparam initializer and a generate condition
  (vo01-vo03), a call both in a localparam and in an assign (vo04), header parameters with and without an override
  (vo05), signed and `bit` formals (vo07, vo08).
- VR, the operator gate: `+`, `<<`, `-` and unary operators under `^`, and `^` under concatenation, `!=`, `+`, `&`,
  a ternary branch, replication and a cast.
  - The operators themselves: `->`, `<->`, `!==`, `===` nested, `==?` with x digits, `^~`, `P ^ Q ^ n` and
    `n ^ P ^ Q`.
  - `^` inside an index and in an indexed part-select bound.
  - Contexts: a two-level if-generate, an interface body, a macro, a package parameter, a for-generate with select
    targets, a child override, an implicit net, a call under `^`.

## Byte controls (drivers/controls.sh, path lists filtered by $FENCED before any case is opened; evidence/controls_fix*.txt)

The implementer's 19 repro dirs, widened by 16 more (r11u262 to r11u277 and their verifiers, r11u108, r11u111):

- 2531 case dirs, 5062 case-views, pristine against fix.
- 4 moving, the implementer's 4: r11u232repro FA/fa23 d/e `line -> type`, toward 4; v11u236repro B/b03 d/e, stage
  1, toward 1.
- 0 entering, 0 leaving, 0 exit-code or uhdm-cmp line changes, chain away 0 on all 4 (evidence/away_controls.txt).
- 12 case-views have no golden: Surelog segfaults on them, and they are the same on both binaries.

## Residues (ranked; all wrong on pristine too unless stated)

1. The sister's elaborated cont_assign call fold (ModuleEmit `emitContAssigns`). It now heads every CA/VC/VA
   movement `file -> type` and gives the 50-line uhdm-cmp stage 1 on the elaborated views.
2. Stage 1 on every binary:
   - Calls whose home is not the module: vc02 / vc17 (package via import), vc07 (a generate-block function),
     vc25 ($unit function inside a for-generate).
   - Other call shapes: vc11 (`f(K) + 1`), vc24 (concatenation argument), vo01 / vo03 (a call in a dimension or a
     generate condition).
   - XOR folds and unsupported operators: vr21 `(P + Q) ^ 8'h1` (the implementer's rk04 / rk09 / rk33 face, the
     whole-constant XOR fold), vr07 (`<->` unsupported, exit 4).
3. Moved by the law toward golden but still not equal: vc01 ($unit function, `line`), vc12 (`line`), vc16 (untyped
   K, `type`), vo08 (`bit`, `type`), vc26 (`type`).
4. The implementer's own residues stand as listed in r11u276repro/README.md. One correction to that README: its
   statement that an operation argument "keeps the operation rules (CA/ca04)" is refuted. Golden keeps K located in
   ca04, and § callOpArgNotReadEither276v now reads it so.

## Sister-ground faces (reported, not written)

The elaborated cont_assign call fold (ModuleEmit `emitContAssigns`, the `type` first record left on the CA, VC and
VA movers, the implementer's decode). The doubled for-generate name (TypeEmit `emitSyntaxExpr` from ModuleEmit
`emitDefGenStmts`) and the struct-member / alias-chain buckets are the implementer's decodes, not re-measured here.

## Process

- Fence: every corpus path list was filtered by $FENCED (word boundary, read fail-closed from
  tools/probe/r11u107repro/canaudit.sh) before any file was opened: bvmirror, controls, the census filter and the
  binary audit (the audit's `find` list is piped through `grep -vwE` before any `grep` opens a cmds.txt).
- No fenced source, database or cmds.txt was opened or dispatched outside the gate sweeps.
- No process of another agent was listed or signalled. The one `pgrep` used an own-tag pattern (`[v]11u276_wdF`)
  to confirm that my own stopped sweep had no children left.
- Every tool variable was checked with `[ -x ]`. Nothing was written outside /tmp/wt_v11u276*, /tmp/v11u276_* and
  the session scratchpad.
- Slip: my first away-census attempt ran two awaygrid.sh instances concurrently on one scratch directory, and they
  clobbered each other's databases ("File exists" errors). Its numbers were discarded and every census was rerun
  with a private $S per instance; only the rerun is reported.
- Files: drivers/case.sh, grid.sh, gridsum.py, awaygrid.sh, controls.sh, ctlsum.py and tracecensus.sh are copied
  from r11u276repro with their own golden and output dirs. grid3.sh, gridsum3.py and bvall.sh are new.
