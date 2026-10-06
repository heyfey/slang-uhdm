# v11u266: adversarial verification of r11u266 (pass 266, the expression/parameter ground)

Base `91223a6f` (pass 264). Verifier worktrees /tmp/wt_v11u266 (the implementer's patch applied clean) and
/tmp/wt_v11u266pris (the base), scratch /tmp/v11u266_*. **No production fix**: every attack on legal SV left the
laws at least as close to golden as pristine, so src/ is the implementer's, byte for byte.

## Verdict

**VERIFIED, no fix.** Both laws reproduce bit for bit and no fresh case, control, corpus row or downstream row
moves away from golden.

- § pkgTdParamValListingTs266 (`R11U266_PKGTDLISTTS_OFF`, ParamEmit patchParamTypespecs)
- § sgnLitElabFreshIntTs266 (`R11U266_SGNLITTS_OFF`, ParamEmit emitParameters plus two ExprEmit read sites)

`R11U266_OFF` gives pristine's bytes on every case-view measured (152 of 152 on the implementer's grid, 102 of 102
on the fresh grid).

## 1. Reproduction (my own builds, frozen before any measurement)

| item | implementer | verifier |
|---|---|---|
| pristine binary | 73e79e8b | 73e79e8b (/tmp/v11u266_bin/pristine, from /tmp/wt_v11u266pris) |
| law binary | 0d9da879 | 0d9da879 (/tmp/v11u266_bin/law, from /tmp/wt_v11u266 with /tmp/r11u266.patch) |
| uhdm-strictcmp | fa6e4f42 | fa6e4f42 |
| firing census (before the law sweep) | 29 lines | 29 lines, identical line for line (evidence/census_predict.txt) |
| probe, law sweep | 3595 + 492, 18 conversions, 3 changes | the same 18 conversions and 3 changes by name, regressions=0 |
| surelog | 476 + 4 / 469 + 5, regressions=0 | the same; row diff against my pristine sweep = LowMemLib / LowMemPkg testflags workdir text only |
| uhdm2rtlil | 1606 + 0 | the same, row diff 0 |
| downstream | 803 / 66 / 2 / 0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, row diff 0 |
| byteverify surelog | 0 of 952 | 0 of 952, SELFCHECK 951 of 952 |
| byteverify uhdm2rtlil | 2 of 1608 | 2 of 1608 (stamped_gen_param d/t, hashes 2d482edcf55e / add12e922be3, the implementer's) |
| byteverify downstream | 1 of 805 | 1 of 805 (stamped_gen_param, still IDENTICAL) |
| probe byte movers | 21 of 4087 | 21 of 4087, the same names, each named by the census |
| stamped_gen_param away census | dist 148 -> 144, lost 0 | dist 148 -> 144, lost 0, gained 2 (`q2::row_t`), uhdm-cmp 64 lines on both binaries, both modes |
| canaries | sl ok=52, u2r ok=16 | sl ok=52 changed=0; u2r ok=16 changed=0 |
| ctcan2 | PASS / PASS | PASS (EXPECT_UNKNOWN=1) / PASS (EXPECT_UNKNOWN=6) |
| binary audit | 3265 of 3315 | 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary; the other 50 carry no slang line; 0 slang lines name another binary (evidence/binaudit.txt) |
| determinism | one hash per row-mode | three concurrent draws, one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, each equal to my law sweep's and to the implementer's (Scoreboard and Rggen testflags write no database) |
| implementer grid (76 dirs, 152 case-views) | 102 moving, 80 entering, 0 leaving | identical in every verdict field (cmp, cmplines, strict, rc); the md5 column differs only by the embedded worktree path |
| byte controls (45 dirs, 6602 case-views) | 28 moving, 10 entering, 0 leaving | identical: 28 moving, the same MOVER lines, 10 entering, 0 leaving, rc and cmplines unchanged |

The uhdm-cmp line count stays 0 on all 21 probe movers: every one reads EQUAL or STRICT_NOTEQUAL on both binaries.

**SELFCHECK reads N-1.** It compares every database with one fixed database, and that one equals itself. So 951
of 952, 1607 of 1608 and 804 of 805 is the expected shape (pass 201's 2559 of 2560), not a missed mover.

**Probe byte comparison.** The probe databases embed the case's absolute source path. The pristine sweep ran
from the pristine worktree, so it differs on every probe database. I reran the probe stage with the pristine
binary from the law worktree (/tmp/v11u266_prP, 3577 + 510, the baseline exactly) and compared against that.

Both of my sweeps exit 1 on the law-index check alone. At the base it is the committed index's staleness; in the
law worktree it is my new cases. tests/LAWS.md is regenerated in the verified patch.

## 2. Adversarial grid (cases/VA 22 dirs, cases/VS 29 dirs; drivers/fresh.sh)

51 fresh case dirs in both views make 102 case-views. Each ran on five configurations: P, L, OFF, and the law
with each switch off. That is 510 lines, **every line rc 0** (evidence/fresh_grid.txt, fresh_gridsum.txt).

| | VA | VS | total |
|---|---|---|---|
| case-views | 44 | 58 | 102 |
| moving | 40 | 50 | 90 |
| entering STRICT_EQUAL | 20 | 22 | 42 |
| leaving STRICT_EQUAL | 0 | 0 | 0 |
| uhdm-cmp line count changed | 0 | 0 | 0 |

- Each mover is moved by exactly one switch: PKGTDLISTTS 40, SGNLITTS 50.
- `R11U266_OFF` reproduces pristine on 102 of 102.

**Away census** (evidence/fresh_away.txt, fresh_chain.txt):
- The record census reads 0 lost on every record-comparable mover except VA/va02 and va03, default view (4 flat
  records each). The dump census reads 0 lost except VA/va12 in both views (1 line, a generic `|vpiParent:`).
- I decoded va02 and va03. Golden's elaborated param_assign Rhs for M IS the listing `q::m_t`, so the law is
  right there. Golden keeps the call `q::inv(M ^ 8'h01)` UNFOLDED in the cont_assign, while we fold it to a
  constant on both binaries.
- Pristine's bare clone `m_t -> <in>m_t -> q::m_t -> range` under the param_assign had paired by accident with
  the formal's clone that golden lists under the unfolded call's operation.
- The chain-keyed census confirms this: **chain away=0, toward=4** on both. Over all 52 record-comparable
  movers it reads chain away=0.
- va12's line is a print-position artefact: distance 41 -> 8.

**Downstream on the 51 dirs** (evidence/fresh_ds_*.txt): the same verdict on both binaries.
- 47 IDENTICAL.
- 2 EQUIVALENT: va02 and va16, the unfolded-call face.
- 2 DIVERGENT: va21, a call in an if-generate condition, and vs29, a function-local localparam.
- All four read the same on pristine. None leaves IDENTICAL.

### What the fresh cases attacked

**§ pkgTdParamValListingTs266.** Golden's rule, read off pass 111's note, is "the package's last registered
typespec of that name". The attack asked whether registration leaks from any evaluated call, not only from a
call that takes the parameter alone.
- **Converted (golden binds the listing, the law agrees):**
  - va01: a constant call with a literal beside a read of M.
  - va04: a constant call in the instantiating top.
  - va05: the child calls `q::inv(X)` with X = M.
  - va07: a second parameter N of the same typedef passed alone, so the law abstains on N and fires on M.
  - va08: the same split across two modules.
  - va10: a default that is a call.
  - va11: a part-select width beside a constant call.
  - va14: a same-named typedef in another package.
  - va18: `q::inv(M[7:0])` in a localparam.
  - va22: a dimension bound `q::w(M | 8'h0)`.
- **Moved toward golden while still failing on another face:**
  - va02 and va03: the cont_assign call over an expression or a cast.
  - va16, va17, va19, va20: a localparam or parameter default over `M ^ 1`, a cast or `(M) + 0`. Uhdm-cmp
    stage 1 on both binaries; the distance falls 34 lines on each and 0 lines are lost.
  - va21: an if-generate condition.
  - va06: a package localparam evaluated by the function.
  - va09: a module function with a `q::m_t` formal.
  - va12: an if-generate over a constant call.
- **So a registration happens only when the parameter itself is the whole argument**, which is the
  implementer's syntax test. Nothing I built fires the law where golden keeps the formal's clone.
- **Over-abstention (residue, pristine's answer kept):**
  - va15: the parameter passed alone to a RUNTIME call (`always_comb r = q::inv(M)`). Golden binds the listing,
    but the definition scan abstains on any call.
  - The same family as the implementer's a35 / a37.
  - The exact distinguisher is a call that Surelog evaluates as a constant, not a call written anywhere.

**§ sgnLitElabFreshIntTs266.**
- **Converted:**
  - vs01: an overridden plus a default instance.
  - vs05: `8'sh80` and `4'sd7`.
  - vs06: the constant slots, meaning a dimension bound, a part-select bound, an indexed width and a
    replication count.
  - vs07: another parameter's default.
  - vs08: a macro-born literal (`` `define LIT 8'sh7F ``).
  - vs09 and vs10: the for-generate cont_assign and process reads.
  - vs14: 64- and 33-bit literals.
  - vs15: depth-2 instances under a for-generate with a passed-down parameter.
  - vs18: the ternary over the parameter.
  - vs24: select targets `o[k*32 +: 32]` in a for-generate.
- **Moved toward golden, stage 1 or a later face on both binaries, 0 lost:**
  - vs04: an interface home.
  - vs11: an implicit net.
  - vs12: a function read.
  - vs13: a class specialization bound.
  - vs16: a program beside the module.
  - vs17 and vs25: if, case and default-case generate.
  - vs20: read folds into a vector, `int unsigned` and `$bits`.
  - vs21: an upper-case `8'SH7F`; the unsized `'sh7F` beside it correctly does not fire.
  - vs22: a binary literal beside `32'sd2147483647`.
  - vs23: two-level generate.
  - vs26: header targets of int, `int unsigned`, integer, shortint and a signed vector, where only `A` fires.
  - vs28: a package parameter beside a module one; the package one does not fire.
  - vs29: a function-local localparam.
- **Not moving:**
  - vs02 and vs19: overrides with a signed literal, strict-equal on both binaries.
  - vs03: an int localparam inside a generate block, stage 1 on both, the law not firing.
  - vs27: class parameters, stage 1 on both, the law not firing.

## 3. Findings (none a break)

1. **The call-argument abstention is wider than golden's rule** (va15, a35, a37). Golden switches to the
   formal's clone only when the parameter alone is the argument of a call Surelog EVALUATES as a constant:
   `assign`, localparam, parameter default or generate condition. A runtime call in `always_comb`, `initial` or
   an uncalled function leaves the listing.
   - The fix would narrow `nameIsDirectCallArg266` to constant-context calls.
   - Today it keeps pristine's wrong answer, never a new one. Residue, not a break.
2. **The ParamEmit branch of § sgnLitElabFreshIntTs266 traces firings only.** It writes no abstention record.
   - Its fences (the int keyword, signedness, a non-package home, the literal form) return silently, so the
     census cannot list the parameters it declined.
   - Process note against the rule "a trace on EVERY branch". It does not change a byte.
3. **The README says "only a module or interface home"; the code tests "not a package"** (`h6->asSymbol().kind
   != SymbolKind::Package`).
   - So a program home (vs16), a generate-block home and a class home are admitted too.
   - vs16 moves toward golden, and vs03 and vs27 do not fire for other reasons, so no measured face breaks.
   - The statement should read "any non-package home".

## 4. Residues (ranked; all wrong on pristine too)

1. The implementer's R1 to R5 stand as measured. R1 is the package array typedef `file(4)` on k05_param_a,
   a27_q_row_named_dims and x38_param_in_module_typed; R2 is the signed literal into
   byte / shortint / longint / integer / `int unsigned` / vector targets; R3 is the signed ternary a2_earl52;
   R4 is the octal cont_assign fold (ModuleEmit); R5 is s37.
2. The runtime-call over-abstention (finding 1: va15, a35, a37).
3. The constant-call FOLD face: Surelog keeps `q::inv(M ^ 1)` as an unfolded func_call in an elaborated
   cont_assign, where we fold. va02 and va03 are strict-first records; va16 and va17 are stage 1 and downstream
   EQUIVALENT on both binaries.
4. An int localparam inside a generate block and class parameters (vs03, vs27: stage 1 on both, the law not
   reaching them).
5. Sister-ground faces as the implementer reported them: the shared elaborated cont_assign Rhs (ModuleEmit
   emitContAssigns / § implNetBareParamElab160), struct member reference full names (TypeEmit buildStructTs), and
   the type-parameter binding (UhdmExporter emitClassTdSpecParams1 / copyClassTdSpecParams1, MiniAmiq / SeqDriver
   #136655 / #136613 / #136625).

## 5. Process

- **The fence.** Every driver used is the implementer's (tools/probe/r11u266repro/drivers), which reads `$FENCED`
  from tools/probe/r11u107repro/canaudit.sh and fails closed.
  - The census ran with the fence filter.
  - byteverify ran on fence-filtered hard-link mirrors: 2560 mirrored, 8 fenced skipped, never opened.
  - The binary audit filtered its cmds.txt list before reading.
  - The probe byte compare covered tests/probe databases only.
  - No fenced test was dispatched, read or decoded outside the gate sweeps.
- **Signals.** No process was signalled.
- **Surelog segfaults on golden builds.** Two Surelog golden builds in the control set segfaulted. They were case
  goldens of earlier repro dirs, already SURELOG_FAIL on both binaries, and the line is the same in the
  implementer's controls.
- **One slip of my own.** My first stamped_gen_param census passed the golden-cache SYMLINK through
  `find -name '*.uhdm'`, which returned nothing. awaydump then compared the wrong pair and printed a nonsense
  `lost=3133`. I caught it and reran it with the cache path itself; that run is the result above. Nothing was
  written outside my scratch.
- **Preview runs.** The fresh grid was first previewed with byte-identical copies of the implementer's frozen
  binaries (/tmp/v11u266_prevbin, same md5s). Every number here is from my own frozen binaries.
- **Patch contents.** No patch file sits in this directory.

## Cases (each names its law in its first line)

- cases/VA/* — § pkgTdParamValListingTs266
- cases/VS/* — § sgnLitElabFreshIntTs266
