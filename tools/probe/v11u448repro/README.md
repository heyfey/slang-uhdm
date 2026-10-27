# v11u448 — adversarial verification of r11u448 (module/type ground)

Verdict: **CONFIRMED, no break, no production change.** The verified patch's source diff is
byte-identical to the implementer's /tmp/r11u448.patch; this patch adds only this directory and the
regenerated tests/LAWS.md. Base 84452b82f (pass 446).

## Binaries (built once, frozen before any measurement)

- law: /tmp/v11u448_bin/law, rebuilt from the implementer's patch in /tmp/wt_v11u448 (-j 2), md5
  997cfcce9c8595a4f6be1bedd419fbd7, equal to the implementer's law7; links slang 12.0.0+545f88b2e.
- uhdm-strictcmp: md5 fa6e4f42f252ae0ab69d9845003e71c5, equal to the implementer's.
- pristine (case runs only): a frozen copy of the main tree's build/slang-uhdm, md5
  0629d46c68933a364c6dcac8b2a3967b. No pristine build and no pristine sweep: the pristine reading is
  the master's control sweep /tmp/intr11u446.
- No verified build, since no refinement was needed.

## The one five-stage sweep on the law binary (evidence/v11u448_sweep.log)

The corpus stages ran from this worktree. The svtests stage ran through the main tree's
tests/sweep.sh, because the worktree's UVM submodule is empty. Both ran with R11U448_TRACE.

| stage | result |
|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64 of 4087, 0/0/0; all 4087 databases identical to the control by path-normalized dump (positive control: two different databases differ by 840 lines) |
| surelog | 480 + 0 / 474 + 0, 0/0/0; the csv differs from the control only in the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0; the csv is identical to the control |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; the csv is identical |
| svtests | EQUAL 1916, DIFFERENT 24, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, conversions 2, changes 0 |

The two conversions, as the fresh svtests.csv rows:

    generated/basejump/bsg_mem_BaseJumpSTL_bsg_nonsynth_mem_1rw_sync_assoc.sv,EQUAL,,equal
    generated/basejump/bsg_misc_BaseJumpSTL_bsg_scheduler_dataflow.sv,EQUAL,,equal

The sv-tests csv differs from the control on exactly those two lines (DIFFERENT,decompile: ->
EQUAL,,equal). The 4 bp_multicore rows stay SURELOG_CRASH.

The corpus stages and the main tree's svtests stage exited 1 on "law index STALE" alone. In this
worktree, that came from this directory's new cases. The implementer's patch on a fresh 84452b82
reads "law index current".

- **Trace** (evidence/v11u448_sweep_trace.txt): exactly the implementer's prediction.
  § invalidReadDefAdmit448 fires on bsg_nonsynth_mem_1rw_sync_assoc, on bsg_scheduler_dataflow
  (read:bypass_lo), and on bp_uce in the 4 bp_multicore rows, which stay SURELOG_CRASH.
  § implicitNetFirstRefLoc448 fires nowhere in the sweep. Neither law fires in probe, surelog,
  uhdm2rtlil or downstream.
- **byteverify** against /tmp/intr11u446 (same-length workdir): surelog 0 of 962, uhdm2rtlil 0 of
  1608, downstream 0 of 805; the self-checks flag 961, 1607 and 804.
- **Canaries:** ok=52 and ok=16; ctcan2 ok=58 (unknown 1) and ok=2 (unknown 6), both PASS.
- **Binary audit** (cmds.txt, fence-filtered): surelog 1523 of 1573 records name
  /tmp/v11u448_bin/law; the other 50 hold only a Surelog line. uhdm2rtlil 1740 of 1740; sv-tests
  2346 of 2346.
- **Determinism:** three concurrent law runs of each converted row's command line read one hash per
  row, exit 0 each time (evidence/v11u448_determinism.txt).

## The implementer's grid, reproduced (evidence/v11u448_grid_r11u448_reproduced.tsv)

The 470 case dirs were run on five configurations: pristine, law, R11U448_OFF,
R11U448_INVREADADMIT_OFF and R11U448_FIRSTREFLOC_OFF. Every one of the 470 lines equals the
implementer's on exit code, uhdm-cmp count, dump distance and strict verdict. The md5 column
differs only because the case work directory differs.

- **Movers:** 59; 49 NOT_EQUAL -> STRICT_EQUAL, 10 closer, none further, no exit code changed.
- **R11U448_OFF:** pristine's bytes and exit code on 470 of 470.
- **R11U448_INVREADADMIT_OFF:** pristine's bytes on all 59 movers.
- **R11U448_FIRSTREFLOC_OFF:** moves exactly v11u447 VP/vp09 and OR/or01, or03, or04, or05.

## Attack grid: 46 fresh case dirs (cases/VA, VR, VS; drivers/grid.sh)

Every case is accepted by upstream slang (~/.local/bin/slang --single-unit). Each case reads an
undeclared name, or holds a statement slang marks invalid, inside a never-instantiated definition
with an undefaulted parameter. Goldens come from Surelog -parse -nobuiltin -nocache -sv. Every exit
code is 0 on every binary.

| case | law | shape | pristine -> law |
|---|---|---|---|
| VA/va01 | § invalidReadDefAdmit448 | blocking assignment to an undeclared name | NOT_EQUAL -> STRICT_EQUAL |
| VA/va02 | § invalidReadDefAdmit448 | `++undecl` | -> STRICT_EQUAL |
| VA/va03 | § invalidReadDefAdmit448 | `r += undecl` | -> STRICT_EQUAL |
| VA/va04 | § invalidReadDefAdmit448 | read only in a module function | -> STRICT_EQUAL |
| VA/va05 | § invalidReadDefAdmit448 | read only in a task, under @(posedge clk) | -> STRICT_EQUAL |
| VA/va06 | § invalidReadDefAdmit448 | a named block declares a variable of the name | -> STRICT_EQUAL |
| VA/va07 | § invalidReadDefAdmit448 | a function local of the name | -> STRICT_EQUAL |
| VA/va08 | § invalidReadDefAdmit448 | the name of another module | -> STRICT_EQUAL |
| VA/va09 | § invalidReadDefAdmit448 | `assign w = f(undecl)` (control, already listed on pristine) | STRICT_EQUAL both |
| VA/va10 | § invalidReadDefAdmit448 | case item label | -> STRICT_EQUAL |
| VA/va11 | § invalidReadDefAdmit448 | final block | -> STRICT_EQUAL |
| VA/va12 | § invalidReadDefAdmit448 | always_comb and always_ff | -> STRICT_EQUAL |
| VA/va13 | § invalidReadDefAdmit448 | read before a later module variable | -> STRICT_EQUAL |
| VA/va14 | § invalidReadDefAdmit448 | two placeholder definitions read the same name | -> STRICT_EQUAL |
| VA/va15 | § invalidReadDefAdmit448 | placeholder-width target `logic [P-1:0]` | -> STRICT_EQUAL |
| VA/va16 | § invalidReadDefAdmit448 | for-loop initializer (refused) | byte-identical |
| VA/va17 | § invalidReadDefAdmit448 | name from a macro | -> STRICT_EQUAL |
| VA/va19 | § invalidReadDefAdmit448 | `!`, `~`, unary `-` | -> STRICT_EQUAL |
| VA/va20 | § invalidReadDefAdmit448 | with a wildcard-imported package parameter | closer, 170 -> 21 |
| VA/va21 | § invalidReadDefAdmit448 | module typedef target | -> STRICT_EQUAL |
| VA/va22 | § invalidReadDefAdmit448 | with a child instance | -> STRICT_EQUAL |
| VA/va23 | § invalidReadDefAdmit448 | a task name read as a value | closer, 89 -> 14 |
| VA/va24 | § invalidReadDefAdmit448 | generate-block name (refused) | byte-identical |
| VA/va25 | § invalidReadDefAdmit448 | block label (refused) | byte-identical |
| VA/va26 | § invalidReadDefAdmit448 | a function-local localparam name | closer, 147 -> 64 |
| VA/va27 | § invalidReadDefAdmit448 | a packed-struct member name | -> STRICT_EQUAL |
| VA/va28 | § invalidReadDefAdmit448 | assign reading a block-local name (control) | STRICT_EQUAL both |
| VR/vr01 | § implicitNetFirstRefLoc448 | process read and assign on one line | -> STRICT_EQUAL |
| VR/vr02 | § implicitNetFirstRefLoc448 | two names, reverse order | -> STRICT_EQUAL |
| VR/vr03 | § implicitNetFirstRefLoc448 | two assigns before two processes | -> STRICT_EQUAL |
| VR/vr04 | § implicitNetFirstRefLoc448 | task, process, assign | -> STRICT_EQUAL |
| VR/vr05 | § implicitNetFirstRefLoc448 | multi-line call | -> STRICT_EQUAL |
| VR/vr06 | § implicitNetFirstRefLoc448 | read before the assign that makes the implicit net (refused) | byte-identical |
| VR/vr07 | § implicitNetFirstRefLoc448 | read through a macro | -> STRICT_EQUAL |
| VS/vs01 | § invalidReadDefAdmit448 | nonblocking write to an automatic variable | -> STRICT_EQUAL |
| VS/vs02 | § invalidReadDefAdmit448 | `initial break;` | -> STRICT_EQUAL |
| VS/vs03 | § invalidReadDefAdmit448 | `initial return;` (refused) | byte-identical |
| VS/vs04 | § invalidReadDefAdmit448 | `initial continue;` | -> STRICT_EQUAL |
| VS/vs05 | § invalidReadDefAdmit448 | procedural write to a wire | -> STRICT_EQUAL |
| VS/vs06 | § invalidReadDefAdmit448 | `#1` in always_comb (refused) | byte-identical |
| VS/vs07 | § invalidReadDefAdmit448 | always_ff without an event (control) | STRICT_EQUAL both |
| VS/vs08 | § invalidReadDefAdmit448 | `#1` in a function (refused) | byte-identical |
| VS/vs09 | § invalidReadDefAdmit448 | task call from a function | -> STRICT_EQUAL |
| VS/vs10 | § invalidReadDefAdmit448 | procedural write to an input port | -> STRICT_EQUAL |
| VS/vs11 | § invalidReadDefAdmit448 | NBA plus a write to an undeclared name | -> STRICT_EQUAL |
| VS/vs12 | § invalidReadDefAdmit448 | associative NBA plus an assign read | -> STRICT_EQUAL |

### Totals (evidence/v11u448_grid_VA_VR.tsv, v11u448_grid_VS.tsv)

- **Movers:** 33 NOT_EQUAL -> STRICT_EQUAL and 3 closer (va20, va23, va26). None further, none
  away from STRICT_EQUAL, no exit code changed.
- **Unmoved:** 10 byte-identical (va09, va16, va24, va25, va28, vr06, vs03, vs06, vs07, vs08).
- **R11U448_OFF:** pristine's bytes on 46 of 46.
- **R11U448_INVREADADMIT_OFF:** pristine's bytes on all 36 movers.
- **R11U448_FIRSTREFLOC_OFF:** moves exactly vr01 and vr07 back. On those two it leaves the law's
  admission at uhdm-cmp 32, dump distance 16.
- **With an explicit top** (Surelog --top-module top, ours --top top;
  evidence/v11u448_grid_top.tsv): all 46 fresh cases and the implementer's 31 AD/OR cases classify
  identically. That is 53 to STRICT_EQUAL, 7 closer (ad08, ad09, ad18, ad22, va20, va23, va26),
  17 byte-identical, no exit code changed, and R11U448_OFF giving pristine's bytes on all 77.
- **Downstream** (drivers/ds_cases.py, every one of the 36 movers): 36 IDENTICAL on pristine and
  on the law, no verdict changed.

## Code review

- **First Bad404 pass with the law off** (on448 false, inStmt448 0): it judges exactly as before.
  The new handlers for InvalidTimingControl, InvalidAssertionExpr and InvalidConstraint act only
  under inStmt448. slang's visitor never descended into those nodes, because they have no
  visitExprs, so no first-pass verdict moves.
- **Relaxed judgement:** it runs only on the original placeholder build, after the retries of
  passes 440 and 444 failed.
- **No-header audit:** no src/R*.h, no getenv, no LawState.h section and no header change. The two
  switches go through lawOn; the three lawTrace calls are there. Every case's first line names its
  law.

## Residues (all unlisted or unequal on pristine too; none moved away)

1. **va23:** a task name read as a value is admitted, because slang wraps it as an InvalidExpression
   with a call child. Ours writes a task_call where golden mints the implicit net work@m.t and a
   ref_obj. Closer, 89 -> 14. ExprEmit is the writer (the sister's).
2. **va26:** a function-local localparam named like the read. Ours lists the parameter work@m.f.LP
   under the function where golden does not. TaskFuncEmit's never-elaborated function listing
   (this ground).
3. **va20:** a wildcard-imported package parameter read in the placeholder definition. Golden's
   constant carries a ref_typespec to the package's int_typespec and a vpiInstance to pk. This is
   the imported-parameter face of passes 440 and 442.
4. **Refused shapes, still unlisted as on pristine:**
   - a for-loop initializer `for (int i = undecl; ...)` (va16): the EqualsValueClause and
     ForVariableDeclaration are not in the admitted ancestors;
   - `initial return;` (vs03);
   - a delay in always_comb or in a function (vs06, vs08);
   - a generate-block name or block label read as a value (va24, va25);
   - a read before the assign that creates the implicit net (vr06).
   Each needs a decode before it is admitted.
5. **Admission of definitions that need both a retry and a read admission.** The relaxed judgement
   runs only on the original placeholder build. A definition that needs an array or string retry of
   pass 440 or 444 as well as an undeclared-read admission stays unlisted. No case or row of that
   shape was found.
6. **The implementer's residues stand as reported:** AD/ad07's nested module (exit 4 on both
   binaries), the event and delay controls, selects, generate blocks, the concatenation and
   named-block shapes, and bp_uce behind pass 403's size guard.

## Sister-ground faces (reported, not written)

- ExprEmit: a task name read as a value (va23) is written as a task_call where golden mints an
  implicit net.
- The implementer's: ExprEmit § undeclaredReadImplicitNet447's scopeOk447 on nested-module reads
  (ad07).

## Process

- One law build and one five-stage sweep, after three quiet readings. No pristine build, no
  pristine sweep, no verified build.
- **Slip, affecting no measurement:** the first attack batch (34 cases, one process at a time) was
  launched while the sister r11u449's census runner (svtests_matrix on its candidate rows) was
  live. It was not a sweep.
- Every other batch and the reproduced grid ran on a quiet machine, after the sweep.
- The fence list was read into a file by a program and never printed. Every tree-wide reader
  (cmds.txt audit) filtered on it first.
- No other agent's process was touched.
