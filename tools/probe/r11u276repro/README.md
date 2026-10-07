# r11u276 — pass 276, the expression/parameter ground (ParamEmit)

Implementer of pass 276 (pair A, refill after pass 274), base 7c896f022. Three laws, all in `src/ParamEmit.cpp`,
behind `src/R276.h` (each `R11U276_<LAW>_OFF`; `R11U276_OFF` drops all three and gives pristine's bytes on 116 of
116 grid case-views; `R11U276_TRACE=<dir>` logs every firing, one file per process, first line `OUT <-o path>`).
The three laws refine when a module parameter counts as READ by the reducer of a continuous assignment, the model
`paramCaFoldRead` keeps (§ caOperandScanRead49, § selectReadNeedsReduce50), and so whether the parameter's
elaborated param_assign Rhs constant keeps its LOCATED declaration typespec or takes Surelog's loc-less bare one.

**Verdict.** No corpus row converts or moves (byteverify 0 of 2560 corpus and 0 of 805 downstream databases);
**SIX PROBE CONVERSIONS** and no probe change; the Surelog corpus stays at zero open rows (every row-mode CMP_EQUAL
except the known failures LogicTypespec d/t and Scr1SvTests d/t), uhdm2rtlil 1606 + 0, downstream 803 / 66 / 2 / 0
with the csv byte-identical to pristine's and to the baseline.

Fresh csv rows of the conversions (`results/` untouched):

    r10earl_repro/qa28,EQUAL,,equal                     (was STRICT_NOTEQUAL differ:type(1))   § caReduceOpKindGate276
    r10earl_repro/ss,EQUAL,,equal                       (was differ:file(3))                   § caReduceOpKindGate276
    r10earl_repro/tl,EQUAL,,equal                       (was differ:file(3))                   § caReduceOpKindGate276
    r10earl_repro/ud,EQUAL,,equal                       (was differ:file(3))                   § caReduceOpKindGate276
    r10earl_repro/ue,EQUAL,,equal                       (was differ:file(3))                   § caReduceOpKindGate276
    r11u108repro/grid/f4/c12_const_fold,EQUAL,,equal    (was differ:file(4))                   § caUserCallRhsNotReduced276
                                                                                                + § elabRhsOwnTsNotDefFormal276

The four r10earl_repro cases also go from uhdm-cmp stage 1 (31 to 35 lines) to STRICT_EQUAL in the `-elabuhdm`
view (not a gate view; grid below).

## The laws

### § caUserCallRhsNotReduced276 (ParamEmit `paramCaFoldRead`) — `R11U276_CACALLRHS_OFF`

A continuous assignment whose whole right side is a call of a MODULE-LOCAL function (not a package member) reads
none of its bare-name arguments: golden `assign o = sext(K)` (r11u108repro c12, `function automatic imm_t
sext(logic [11:0] x)` in the module) keeps K's elaborated param_assign Rhs typed by K's own declaration
(`logic_typespec` 4:14-4:26), where the whole-right-side harvest (`ctx.tryEval(rhs)` folds `sext(K)`) marked K read
and gave it the loc-less bare typespec. The same rule § caCallArgParamFormalTs232 measured from the other side (its
FA/fa23: a module-local function stamps nothing; a package function is evaluated, its actuals read and stamped),
so the law reads only a subroutine whose parent scope is not a package (a package call keeps the old harvest:
CA/ca05). An argument that is itself an operation is reduced on its own and keeps the operation rules (the
whole-fold harvest when it folds, the operand scan otherwise; CA/ca04); a default argument not written at the
call is not an argument of Surelog's func_call and is skipped (CA/ca12, converted). The trace names a firing only
where the harvested set changes (`<function> <parameter>`).

### § elabRhsOwnTsNotDefFormal276 (ParamEmit `drainShareDefParamTs`, the pending share loop) — `R11U276_RHSOWNTS_OFF`

With K no longer harvested, the elaborated Rhs takes the default branch, which SHARES the definition parameter's
typespec object, resolved design-final in `drainShareDefParamTs`; there the definition parameter K already names
the module function's FORMAL typespec (golden and ours alike: def K -> `logic_typespec` 3:33, the formal `logic
[11:0] x`, ExprEval::evalFunc's `exparg->Typespec()->Actual_typespec(tps)` re-pointing the definition's
reference), and the share carried that formal into the elaborated Rhs (`line(4)`, 3:33 against golden 4:14).
Golden's elaborated Rhs keeps the declaration typespec object, which the re-pointing never touched. When the
definition parameter's typespec is the typespec of an io_decl of one of the definition's own subroutines, the
share is skipped and the Rhs keeps the parameter's own typespec. A NAMED formal typespec (a typedef's located
copy, `input b_e q`) abstains (traced `abstain named`): golden r10v62repro v62e_bind's LP / PP share the task
formal's `b_e` at 28:27, and an unrestricted first draft moved that probe case `line(7) -> line(9)` with two
records away from golden; refined before the census (CA/ca10 is the in-grid control, unmoved).

### § caReduceOpKindGate276 (ParamEmit `srlgCaOperandScan49` and `paramCaFoldRead`'s whole-fold harvest) — `R11U276_REDUCEKIND_OFF`

ExprEval::reduceExpr's operation branch (UHDM templates/ExprEval.cpp) runs the operand PRE-SCAN for every operator
(each direct reference handed to getValue: the rewrite § caOperandScanRead49 transcribes), but reduces the operands
only inside its `switch (optype)` branch; an operator the switch does not list takes `default: invalidValue = true`
and nothing below it is reduced. Listed: `>> >>> < <= > >= == != ++ -- << <<< + - * / % ** & | && ||`, every unary
operator, inside, `?:`, concatenation, replication, casts. NOT listed: `^`, `~^`/`^~`, `===`, `!==`, `==?`, `!=?`,
`->`, `<->`. So an operation under such an operator is never reduced: golden r10earl_repro ss `assign o = Seed ^
{..} ^ {..} ^ {..} ^ {SDw{clk_i}}` keeps Seed's LOCATED typespec (14:13), tl `clk_i ^ A_PKG[0] ^ B_MOD[0] ^
C_LIT[0]` keeps B_MOD's (21:13). The operand scan now stops after the pre-scan of such an operator, and the
whole-fold harvest harvests only its pre-scan (direct bare-name operands up to the first operand that stops the
scan). Positive and negative controls in the grid: `(P & n) ^ 8'h0F`, `(P & n) ^ {a, b}`,
`(P & n) === 8'h0`, `!==`, `==?`, a child override, a for-generate bit-select and an `n[0] ^ P[1] ^ Q[2]` chain all
enter STRICT_EQUAL (pristine `differ:file`); `(P & n) | 8'h0F` and `(P & n) == 8'h0` stay STRICT_EQUAL and byte-identical
(the listed operators keep recursing). The trace names a firing only where the harvested set changes (a what-if run
with the gate open, `scan <name>` / `fold <name>`).

## Grid (drivers/grid.sh, drivers/case.sh, drivers/gridsum.py; evidence/grid.txt, grid_summary.txt)

58 fresh case dirs, each naming its law in its first line: cases/CA ca01-ca22 (§ caUserCallRhsNotReduced276;
ca10, ca11 § elabRhsOwnTsNotDefFormal276) and cases/RK rk01-rk36 (§ caReduceOpKindGate276), both views, each on
pristine, the law, the law + R11U276_OFF and the law + each switch: **116 case-views, 696 lines, every line with
its exit code; 52 moving, 20 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 0 uhdm-cmp line-count
changes; R11U276_OFF gives pristine's bytes on 116 / 116**; every mover returns to pristine's bytes under exactly
one switch (CACALLRHS 28, REDUCEKIND 20, RHSOWNTS 2) except CA/ca02_child_override in both views, which needs both
CACALLRHS and RHSOWNTS off (the two laws act on the same parameter; chain toward 8, away 0). Away census
(chain-keyed, tools/probe/r11u272repro/drivers/awaychain.py with strictcmp_x, drivers/awaygrid.sh;
evidence/away_grid.txt): **away 0 on all 52 movers** (flat away 0 as well); positive control (binaries swapped on
CA/ca01 and RK/rk27) away 4 each (evidence/away_poscontrol.txt).

Most CA movers stay STRICT_NOTEQUAL with their first field moving `file -> type`: the four parameter-typespec
records clear and the walk's next difference is the sister's elaborated-cont_assign call fold (golden keeps
`func_call` for `f = x`, `return x + 1`, `return 32'd42` ... in the elaborated instance where ModuleEmit
`emitContAssigns` folds to a constant; located with a gdb backtrace on a scratch twin of CA/ca01). Grid coverage:
the constant slots (RK rk15 part-select bound, rk19 replication count; CA ca06 select argument), the module's own
localparam and header parameters (rk16, rk25, ca18), macros (rk17, ca16), an imported package parameter (rk18),
a package function (ca05, abstains), for-generate and if-generate scopes (rk10, rk22, rk35, ca07), interfaces
(rk21, ca15), child overrides and instance depths 1-3 (rk14, rk26, rk36, ca02), nested calls, casts, named and
defaulted arguments (ca12-ca14, ca22), int, enum and bare-implicit formals (ca10, ca11, ca21).

## Gates (law binary c9cccf2af0a2de4f21db2ab42016106d; pristine 6ebf1ae4e510656f6b0873c644546463 = the main tree's build)

- Probe (tests/sweep.sh --corpus probe): **regressions=0 conversions=6 changes=0** (EQUAL 3761 + STRICT_NOTEQUAL 326;
  base 3755 + 332, the pristine sweep's probe.csv byte-identical to results/golden_probe.csv); every case uhdm-cmp-equal.
- Surelog: regressions=0 conversions=0 changes=0 (default 478 + 2, testflags 472 + 2); uhdm2rtlil: regressions=0
  conversions=0 changes=0 (803 / 1 / 67 both modes). Both sweeps exit 1 on the law-index staleness check alone
  (tests/LAWS.md regenerated last, in the patch).
- Downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, csv byte-identical to pristine's and to
  results/downstream_uhdm2rtlil.csv; 0 of 805 slang-lane databases move.
- Downstream on the 58 fresh case dirs (tools/probe/r11u272repro/drivers/dscases.py, both binaries): 55 IDENTICAL and
  3 EQUIVALENT (rk04, rk09, rk33: a whole-constant XOR right side, pre-existing) on both, the slang lane's `.il`,
  `_nohier.il` and `_synth.v` byte-identical between the binaries (174 files; evidence/downstream_cases_*.txt).
- Firing census (drivers/tracecensus.sh, frozen before the law sweep; evidence/predict.txt, md5 in predict.md5): 21
  lines, 12 probe and 9 corpus row-modes. **byteverify** (fence-filtered hard-link mirrors,
  tools/probe/r11u272repro/drivers/bvmirror.sh, `tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1):
  PATH_SETS_IDENTICAL 2560, **MOVERS 0 / 2560**; SELFCHECK reads 2559 / 2560 because every file is compared against
  one fixed file and that file is the one not flagged (pass 201's self-check artefact, not a mover). Probe: **6 of
  4087 databases move = the 6 conversions, all predicted by name** (evidence/byteverify_probe.txt). The census
  over-predicts and every over-prediction is accounted: (a) the trace names a change of the harvested NAME SET at
  the moment the gate or the call law runs, and the set is per body: a name another construct of the same body
  reads (later in the scan, or through paramNameIsRead) or a parameter that takes no bare-typespec branch moves
  nothing (probe hh, r11u18 t1, the three rgg6 cells; Earlgrey_0_1 d/t and rp32_r5p_alu d/t, 1-2 firings each);
  (b) § elabRhsOwnTsNotDefFormal276's trace stands before the pristine share's own kind test
  (`dts->UhdmType() == cur->UhdmType()`), so a firing where the formal's kind differs from the Rhs typespec's moves
  nothing: Rggen default's 88 and const_arg_loop d/t's 1 firings are all of that kind, which the 0-mover byte census
  proves (a same-kind firing re-binds the Rhs and changes the database); (c) abstain-only lines (v62e_bind,
  rp32_r5p_wbu d/t) move nothing by construction.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, ctcan2 PASS on both (tools/probe/r11u107repro and
  r10uvm67repro copies; evidence/canaries.txt). Binary-path audit over the fence-filtered cmds.txt list: 3265 of 3315
  name each sweep's own frozen binary, the other 50 carry no slang line (evidence/binary_audit.txt).
- Determinism (tools/probe/r11u272repro/drivers/det.sh, three concurrent draws per row-mode): Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen default and the testflags row-modes with a database: one
  hash each, equal to both sweeps' (evidence/determinism.txt).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first): 19 earlier repro dirs (r11u118,
  r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u274, v11u274, r11u272, v11u272,
  r11u232, v11u232, r11u195, r11u239, r11u236, v11u236), both views: **2976 case-views, 4 moving, 0 entering, 0
  leaving, 0 exit-code or uhdm-cmp changes, chain away 0 on all 4** (r11u232repro FA/fa23 d/e, the module-local
  function case § caCallArgParamFormalTs232 left unstamped, `line -> type` toward 4; v11u236repro B/b03 d/e, stage 1
  on both binaries, toward 1; evidence/controls*.txt, away_controls.txt).

## The probe residue at the base, by writer (evidence/residue_buckets_base.txt, residue_chains_base.tsv)

drivers/classify.py + chains.py (from r11u266repro) over the 332 STRICT_NOTEQUAL cases of the base sweep: the first
record's object chain, bucketed by field | object | parent | grandparent | top scope (171 buckets). The largest:

| cases | bucket | writer / status |
|---|---|---|
| 25 | name ref_obj under cont_assign | the `assign o = P` struct-parameter read, ModuleEmit `emitContAssigns` (pass 272's decode) — SISTER |
| 12 | fullname ref_typespec / constant / operation | mixed: four rgg4 interface-array port ranges (a1, b1, c1, v5k: golden's folded constant unnamed and unlocated, ours named `work@top.u` at R's declaration), the rest single faces — not decoded |
| 10 + 10 | fullname ref_typespec / typespec_member / struct_typespec | struct-member full names, TypeEmit — SISTER |
| 10 | name logic_typespec under a package typespec | the `q2::row_t` / `home48::w48_t` alias chain, TypeEmit — SISTER |
| 7 | line logic_typespec / packed_array_typespec | type-parameter array faces pass 275 left, UhdmExporter — SISTER |
| 6 | type func_call under cont_assign | the elaborated cont_assign call fold, ModuleEmit `emitContAssigns` — SISTER |
| 5 | file logic_typespec / constant | **CONVERTED by this pass** (c12, ss, tl, ud, ue) |
| 5 | line int_typespec / constant | rgg3 recv_localparam x2, r11u115 s01, v201_k_neg, v11u112 g1k — not decoded |
| 5 | type ref_obj under cont_assign | the cont_assign's left side where ours lists a constant or operation — not decoded (ModuleEmit) |
| 4 | fullname ref_obj / indexed_part_select / var_select | **the doubled for-generate name** — SISTER, decoded below |
| 4 | value constant / operation / param_assign | Surelog's 64-bit cast value defect (r11u109): not to copy |
| 4 | fullname ref_typespec / constant / indexed_part_select | fold reference names in generate scopes, directions inconsistent across the four (a3_earl47 golden deeper, v08_comb and v7_repl105 golden shallower) — not decoded |

## Decodes stopping at the sister's ground (reported, not written)

1. **The doubled for-generate name** (`rd[i+1][o -: 4]` in `for (genvar i ...) begin : g`: golden `work@m.g.rd.o`,
   ours `work@m.g.rd.rd.o`; probe v11u112 b4b / b4d / b4h, v11u115 v06): a gdb backtrace on the setter of that
   16-character name (scratch twin `rd[1][o -: 4]`, the same face) shows the writer is
   `UhdmExporter::emitSyntaxExpr` (TypeEmit.cpp), called from the `emitDefGenStmts` lambda (ModuleEmit.cpp): the
   definition-view generate scope is emitted from syntax, and the trailing indexed part select's direct reference
   base scopes through the select's doubled name, where UHDM's ComputeFullName skips an indexed_part_select parent of
   a ref_obj (the rule § hpVarSelIpsDirectRefSkipsSelect220 and § vsIpsBaseNamesByIps147 apply on the AST path,
   whose elaborated `g[0]` copies are already golden's). Only a bare-name base is affected (an operation base keeps
   the doubled name in golden too: scratch `rd[i][o+1 -: 4]` STRICT_EQUAL).
2. **The elaborated cont_assign call fold**: ModuleEmit `emitContAssigns` folds `assign o = f(K)` of a module-local
   `f = x` / `return x + 1` / `return 32'd42` body to a constant in the elaborated instance where golden keeps the
   func_call (gdb backtrace on the setter of the folded `UINT:4095`): the `type` first record left on CA/ca01-ca22.
3. The realtime variable typespec (r11u270repro T/t07: golden `time_typespec`, ours `real_typespec`, stage 1): a
   variable-declaration typespec, not this ground's emitter (writer not located).

## Residues, ranked (this ground)

1. The package-function call argument (`assign o = q::f(K)`, CA/ca05; stage 1 on both binaries): left on the old
   harvest because golden evaluates package functions (§ caCallArgParamFormalTs232).
2. Nested unhandled operators in the whole-fold harvest are gated at the first one; a constant XOR right side
   (`P ^ Q`, `(P + 1) ^ Q`, `P[2] ^ 1'b1`: rk09, rk04, rk33) stays stage 1 on both binaries (the elaborated
   cont_assign fold, ModuleEmit's).
3. The probe buckets above marked "not decoded" on this ground: the int_typespec location of a received localparam
   (rgg3 n2 / xc, r11u115 s01) and the generate-scope fold reference names (a3_earl47, v08_comb, vo, v7_repl105).
4. Items (2) to (7) of the brief beyond the above were not attempted: pass 274's unary and member-read leftovers,
   pass 272's converted value and module-local function sources, pass 270's inside-set range bounds / call index /
   enum-alias shapes, pass 268's macro shapes, passes 266-232's lists and the decode's BuildUVMPkg clusters.

## Process

Fence: every corpus path list was filtered by `$FENCED` (word boundary) before any file was opened (controls.sh,
bvmirror.sh, classify.py, the binary audit); the census ran with the fenced filter; no fenced source or database was
read or dispatched outside the gate sweeps. Two slips, neither a breach: a first binary-audit `grep` read the
fenced rows' `cmds.txt` command lines in my own sweep workdirs (no source or database opened; rerun on the
fence-filtered list, the numbers above are the rerun's), and one `compare_results.py --filter` of the census csv
against the committed baseline printed the fenced rows' baseline verdicts as ONLY-COMMITTED lines (the committed
csv's facts only). A shell-function name clash aborted one case-writing command before it ran; a second attempt
with an empty directory variable tried to create `/dut.sv` and `mkdir ""`, both refused by the system (permission
denied), nothing written anywhere (main tree `git status` clean, `/dut.sv` absent); the case writer was made
fail-closed (absolute repro path required). One `pgrep -fa | grep r11u276` was used to check that the controls run
had ended (only my own lines printed); a waiter whose `pgrep -f` pattern matched its own command line was stopped by
its own task id and replaced by a log-line waiter. No process of another agent was signalled. Superseded binaries:
law1-law4 (the law-2 refinement after the v62e_bind change, the law-1 package restriction, the precise traces);
the census, grid, controls and both sweeps ran on the final one (law5 = law.bin).

Files: drivers/case.sh, grid.sh, gridsum.py, awaygrid.sh, controls.sh, ctlsum.py, tracecensus.sh (from
r11u274repro), classify.py and chains.py (from r11u266repro); the away census, bvmirror, det.sh and dscases.py are
used in place from tools/probe/r11u272repro/drivers.
