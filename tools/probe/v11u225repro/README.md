# v11u225: adversarial verification of r11u225 (pass 225, the module/type ground)

**Verdict: ACCEPT WITH FIX.** Every headline number of r11u225 reproduces on my own builds. Three row-modes convert:
InterfArrayBind default and OutputSizeWithParameterOfInstanceInitializedByStructMember default and testflags. No
regression appears in any gate stage, and the downstream csv is unchanged.

One law breaks on legal SystemVerilog where pristine was right: § initHierFillKept225. It keeps `'1` unsized even when
the struct parameter's value is one Surelog reduces (an untyped assignment pattern, a plain integer or a
concatenation). There golden folds the range bound and the `'1` alike. Pristine wrote golden's sized UINT there, and the
law removed it. The implementer's own grid case OS/o21 is one of these cases.

These cases are already stage 1 at the base, because our range keeps the substituted `Info.x` where golden holds a
constant. So no verdict and no gate row sees the break, but the chain-keyed away census does: 9 records lost. I refined
the law behind its own switch as § fillSymbolicRootOnly225v (`R11V225_FILLSYM_OFF`, and `R11V225_OFF` for all
refinements). With the refinement: 0 records lost, 351 toward golden, and the refined binary's gate sweep matches the law
sweep row for row. The shipped patch is `/tmp/r11u225.verified.patch`.

Base `75a564b0` (branch matrix-1.87). Production files: the implementer's `src/ModuleEmit.cpp` and
`src/TypeEmit.cpp`, plus `src/R225.h`. The refinement adds lines to `src/TypeEmit.cpp` and `src/R225.h` only. Nothing
changes in ExprEmit.cpp, EmitHelpers.h, StmtEmit.cpp or ParamEmit.cpp (the sister's ground). The four slang-fenced
tests are never named here. Every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed.

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u225_bin` before measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `abaa83b8a0194539219d406e055c8b51` | fresh worktree at `75a564b0`, system-deps config, `-j 2`; the same as the main tree's `build/slang-uhdm` |
| `law` | `3e17227217fcf1e151cd5a3d1d1e043c` | fresh worktree at `75a564b0` + `/tmp/r11u225.patch` (md5 `9cdb2a63…`, applies clean): **the implementer's md5, byte for byte** |
| `fix` | `88b089ce307f418948a7b0b20f332ab3` | `law` + § fillSymbolicRootOnly225v |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build (not edited) |

`/tmp/r11u225.verified.patch` (the git diff against `75a564b0`) applies clean on a fresh `75a564b0` worktree, and that tree rebuilds `fix` byte for byte (`88b089ce…`). Its src hunks also apply on the main tree's current HEAD (pass 224 landed during this verification); only tests/LAWS.md conflicts there and must be regenerated.

Every `slang:` line of every `cmds.txt` names its sweep's binary: 3273 of 3273 in each of the pristine, law and fix
sweeps.

## 2. The headline numbers, reproduced

Sweeps: `tests/sweep.sh --jobs 3`, workdirs `/tmp/v11u225_w{P,L,X}`. The summaries are in
[evidence/sweeps/](evidence/sweeps/).

| gate | law sweep (reproduces the implementer's) | fix sweep |
|---|---|---|
| probe | regressions=0 conversions=0 changes=0, EQUAL 3448 / STRICT_NOTEQUAL 639; csv byte-identical to results/golden_probe.csv | the same, csv identical |
| surelog | regressions=0 **conversions=1** (InterfArrayBind default) changes=0 | the same |
| uhdm2rtlil | regressions=0 **conversions=2** (OutputSize... d/t) changes=0 | the same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; csv identical to the pristine sweep's | the same, csv identical to the law sweep's |

**The target rows, fresh csv rows from the fix sweep** (results/ untouched):

```
InterfArrayBind,default,CMP_EQUAL,,,equal                                             (baseline STRICT_NOTEQUAL differ:fullname(1))
InterfArrayBind,testflags,CMP_EQUAL,,,equal                                           (unchanged)
OutputSizeWithParameterOfInstanceInitializedByStructMember,default,CMP_EQUAL,,,equal   (baseline STRICT_NOTEQUAL differ:line(8))
OutputSizeWithParameterOfInstanceInitializedByStructMember,testflags,CMP_EQUAL,,,equal (baseline STRICT_NOTEQUAL differ:line(8))
OutputSizeWithParameterOfInstanceInitializedByStructMember,IDENTICAL,NO_GATES,NO_GATES,0,0,,   (downstream)
```

- **Each sweep exits 1 only on `law index STALE`.** The pristine worktree at `75a564b0` exits the same way, so the
  staleness predates the pass. The patch carries a regenerated tests/LAWS.md.
- **uhdm-cmp:** 0 lines on all four moved row-modes. The strict verdicts are InterfArrayBind d `STRICT_EQUAL 186
  objects`, t `96`, OutputSize d `259` and t `169`, the implementer's figures.
- **Canaries** on the law and fix csvs: canaries.sh surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0. ctcan2.sh
  PASSES with EXPECT_UNKNOWN=1 on surelog and EXPECT_UNKNOWN=6 on uhdm2rtlil.
  - Run them against the worktree's `results/` at `75a564b0`. The main tree's `results/golden_surelog.csv` has moved
    since: pass 224 landed during this verification. Against it, five UVM canaries read changed, all the pass-224
    re-baselines of SimpleUVM, BuildUVMPkg and Scoreboard.
- **Byte movers**, from `tools/probe/r11v75repro/byteverify.sh` with `SELFCHECK=1`. The inputs are hard-link mirrors
  without the 8 fenced row-mode databases (r11u225repro/drivers/bvmirror.sh, `fenced_skipped=8` per side). Each run
  reads PATH_SETS_IDENTICAL (2560), and SELFCHECK flags 2559 of 2560.
  - law vs pristine: **5 of 2560**. These are InterfArrayBind d/t, OutputSize d/t and MiniAmiq default. The prediction
    names the first four; MiniAmiq is the known symbol-table coin (section 7).
  - fix vs law: **1 of 2560**, MiniAmiq testflags, the same coin.
  - fix vs pristine: 6, the law's four plus MiniAmiq d and t.
  - Probe: 0 of 4087 databases move, law vs pristine and fix vs pristine. Both sweeps must run from the same worktree
    path, because a probe database embeds the case's absolute path. A pristine probe stage run from the pristine
    worktree (`/tmp/wt_v11u225pris`, 4 characters longer) differs in all 4087 databases for that reason alone. The
    control is `/tmp/v11u225_wQ`, the pristine probe stage re-run from the law worktree.
  - Downstream: 1 of 805 lanes moves, OutputSize.
- **The implementer's frozen prediction** (md5 `8d9896b852ab7f1a284a97cff5c2be5d`, verified). My own firing census
  with the fix binary (drivers/census.sh, `--filter` built from `$FENCED`) reproduces it law for law: 6/1/1 on each
  OutputSize database and 1 on each InterfArrayBind mode. The refinement fires nowhere in the corpora, the probe cases
  or the downstream lanes. [evidence/prediction_fix_frozen.txt](evidence/prediction_fix_frozen.txt), md5
  `a060b88e71a10dbb9d481ed6e0d9bb31`, was frozen before the fix sweep: 0 gate databases move against the law. The only
  mover was the MiniAmiq coin.
- **The implementer's grid, re-run** with my binaries ([evidence/grid_r11u225_rerun.txt](evidence/grid_r11u225_rerun.txt)):
  86 case-views, 60 move bytes and 29 enter EQUAL. None leaves EQUAL, every exit code is 0, and `R11U225_OFF` gives
  pristine bytes on all 86. The fix equals the law's bytes on 84; the other two are OS/o21 in both views (section 3).
- **The away census on the gate sweeps** (r11u225repro/drivers/awayall.py; OFF = pristine corpora + the same-path
  pristine probe stage, ON = fix): chain_lost=0 chain_toward=15 flat_lost=0 flat_toward=15 flat_unpaired=0. That is
  InterfArrayBind d 1 and OutputSize d/t 7 each. The reversed control reads 15 lost
  ([evidence/away/gate_pristine_to_fix.txt](evidence/away/gate_pristine_to_fix.txt)).

## 3. The break and its refinement: § fillSymbolicRootOnly225v (`R11V225_FILLSYM_OFF`, TypeEmit)

**The mechanism.** § initHierFillKept225's premise holds only when golden keeps the bound SYMBOLIC. Surelog's
`UhdmWriter::writeCont_assign` reduces the Rhs and calls `CompileHelper::adjustSize`. When `Info.x` stays unreduced,
the `Bits` call in adjustSize comes back invalid and `'1` stays unsized at `-1`. Surelog reduces the member, and folds
the range, depending on how the struct parameter is written.

Top-level `assign data = '1` onto `logic [N-1:0] data` with `localparam int N = Info.x`
([evidence/fresh_cases.txt](evidence/fresh_cases.txt)):

| `parameter info_t Info = ...` | golden's range | pristine | law | case |
|---|---|---|---|---|
| `info_t'(16)` (the corpus row's form) | `Info.x` kept | line | **EQUAL** | h05, g01-g14 |
| `info_t'{x: 16}` | kept | line | **EQUAL** | h02 |
| `info_t'('{x: 16})` | kept | file | file (the law's records all toward) | h07 |
| `'{x: 16}` | **folded** | stage 1 | stage 1, **the '1 moved away** | g19 |
| `'{16}` | folded | stage 1 | stage 1, moved away | h01 |
| `'{default: 16}` | folded | stage 1 | stage 1, moved away | h03 |
| `16` | folded | stage 1 | stage 1, moved away | h04 |
| `{32'd16}` | folded | stage 1 | stage 1, moved away | h06 |
| `'{x: 16, y: 8}`, the child written by `'1` twice | folded | stage 1 | stage 1, moved away | g15, g17, **r11u225's own OS/o21** |

In every folded case golden writes `constant 65535 size 16 UINT:65535`, as pristine did, and the law wrote the unsized
definition constant: `'1`, BIN:1, size -1. For example, on g19:

```
golden   '1 (definition)  65535 (elaborated, size 16)
pristine '1               65535
law      '1               (the definition constant shared, size -1)
fix      '1               65535
```

The away census over the fresh cases and the implementer's grid (drivers/awaycase.py: chain-keyed and flat records from
the gate's comparator walked over each database, stage-1 pairs included) finds 9 records that were golden's and that
the law lost. They are all this constant, in `cont_assign < module_inst:… < design`: g15, g17, g19, h01, h03, h04, h06
and h06_el, plus OS/o21
([evidence/away/cases_pristine_to_law.txt](evidence/away/cases_pristine_to_law.txt)). The implementer's README lists
o21 as "stage 1 -> stage 1 (the same first path)": the verdict is unchanged, but a record moved away. uhdm-cmp would
read this constant's VpiSize and VpiDecompile. It is hidden only because the pre-existing range difference comes first
in the walk. Downstream verdicts are the same on the three binaries (g15, g17, o21 EQUIVALENT; the others IDENTICAL):
the plugin self-replicates `'1`.

**The refinement.** It sits at the TypeEmit site where the owner registry of `initHierOwners225` is filled:

1. Follow the member-initialized parameter to its struct parameter, then along a bare-reference chain as
   resolveMemberInit does.
2. Record the signal only when that parameter's initializer is written as a cast (`CastExpression`) or as a typed
   assignment pattern (`AssignmentPatternExpression` with a type).
3. Otherwise leave the registry empty, so the fill law does not fire and pristine's fold stays.

Declines are traced as `fillSymbolicRootOnly225v <owner>`. The span and bare-name laws are untouched: in the folded
cases they act on hier_path objects golden does not hold.

**With the refinement:**

- **Fresh cases:** 0 records lost and 351 toward golden. The reversed control reads 351 lost
  ([evidence/away/cases_pristine_to_fix.txt](evidence/away/cases_pristine_to_fix.txt),
  [cases_reversed_control.txt](evidence/away/cases_reversed_control.txt)).
- **Bytes:** the fix differs from the law on exactly the 16 case-views of those 8 cases (7 fresh and o21). The fill
  constant there reads golden's `65535` again. `R11V225_OFF` gives the law's bytes on all 80 fresh case-views.
- **Gates:** it changes no gate database (section 2).

## 4. The fresh cases (cases/FA, cases/FO: 40 cases, 80 case-views in both views, [evidence/fresh_cases.txt](evidence/fresh_cases.txt))

drivers/case.sh (copied from r11u225repro) builds the golden with check_probe's Surelog arguments (`-elabuhdm` for the
elaborated view). It runs each binary with `--single-unit --nobuiltin`, then uhdm-cmp and uhdm-strictcmp, and records
every exit code (all 0).

**Totals with the fix binary:**

- 78 of 80 case-views move, and **31 enter STRICT_EQUAL**. None leaves EQUAL, and no judge-equal case-view drops to
  stage 1.
- The stage-1 case-views keep their uhdm-cmp line count, with one exception. On FO/g16 elaborated the count grows 32 ->
  100 because the head moves: the law clears pristine's first difference (u1's fill constant, now golden's `UINT:1` size
  1) and the walk reaches a pre-existing one (u2's range `Info.y` where ours writes `Info.x`, predating the pass).
- `R11U225_OFF` gives pristine bytes on all 80.

**Per law:**

| law | fresh cases (§ first line of each dut.sv) | result |
|---|---|---|
| ifArrElemLitCaFresh225 | FA f01-f12 | The parse view converts on f03, f05, f06, f08, f10, f11 (a parameterized interface array, a generate-loop prefix, CRLF, an enum selector with a modport, two instances with different selectors, a header included by two modules), and f02's elaborated view converts (`'0`/`'x`/`'z` fills). f01, f02 and f12 keep a fullname head with 3 -> 1 objects or the same count; f07 (the assignment written by a macro) and f09 (a package-qualified selector) are stage 1 on both binaries with identical uhdm-cmp output; f04 (a struct member of the element) is not reached. |
| initHierAtRefToken225 / initHierCaLhsBareName225 | FO g01, g04-g14, g16, g18, g20, g21 | These convert: `'x` onto the signal (g01), a macro-written reference (g05), CRLF (g06), a signal written only by a process and read by an assign (g07: golden keeps the scoped name, and so does the law), ANSI header parameters with a package struct type (g11), a program (g12), two files with the same declarator position (g13), a wire (g14), a block-local variable sharing a cont-assigned signal's name (g20, g21). g02 (a generate-block signal, whose bound golden folds) and the stage-1 shapes g03, g04, g08, g09, g10 keep their heads. |
| initHierFillKept225 | FO g15-g19, h01-h07 | the break of section 3, and its refinement |

**Downstream:** 39 fresh cases through `downstream_uhdm2rtlil.one()`, a fresh `GOLDEN_CACHE`, and g13 left out (two
files). Pristine and law give the same verdicts on all 39: 35 IDENTICAL, f07 and g04 DIVERGENT on both, g15 and g17
EQUIVALENT on both. The fix gives the same verdicts on the 8 cases it moves, and o01 stays IDENTICAL.
[evidence/downstream_cases.txt](evidence/downstream_cases.txt), [downstream_fix_cases.txt](evidence/downstream_fix_cases.txt).

**Switches, each dropped alone on every fresh and grid case-view with the fix binary**
([evidence/switches.txt](evidence/switches.txt), 166 case-views):

| switch | case-views moved |
|---|---|
| `R11U225_IFARRELEMCA_OFF` | 48 |
| `R11U225_INITHIERSPAN_OFF` | 90 |
| `R11U225_INITHIERCANAME_OFF` | 60 |
| `R11U225_INITHIERFILL_OFF` | 32 |
| `R11V225_FILLSYM_OFF` | 16 |

Every case-view a switch moves is one where its own law fires in the trace.

## 5. What the bare-name law is in Surelog (decoded, for the record)

The implementer transcribed § initHierCaLhsBareName225 from the grid without locating its producer. It is the last line
of Surelog's `UhdmWriter::writeCont_assign` (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp, the per-assign loop).
For an elaborated cont_assign whose Lhs is a `ref_obj`, `tps` is set to the bound variable's typespec, and the loop then
runs

```
if (tps != nullptr) const_cast<typespec*>(tps)->VpiParent(nullptr);
```

The signal's logic_typespec loses its parent, so the full name the dump derives for the `Info.x` ref_typespec under its
range stops at the path: `Info.x`, where `work@top.data.Info.x` reaches the signal. That holds for every whole-signal
continuous-assignment target, and for no process target (OS/o10, o13, FO/g07) and no select (a select Lhs is no
`ref_obj`: OS/o17). The law's predicate, a whole-signal left side of a continuous assignment in its own module scope, matches that
rule on every case here. Scopes it does not model (a generate-block assignment, FO/g08, stage 1 on both binaries; the
interface case OS/o20) stay residues.

## 6. Residues, ranked

1. **The member substitution itself for a reduced struct value** (pre-existing, not this pass): for an untyped pattern,
   a plain integer or a concatenation, golden folds the range bound to a constant (`INT:15`), where ours emits the
   `Info.x` hier_path (FO g15, g17, g19, h01, h03, h04, h06; r11u225 OS/o21). The site is TypeEmit makeTypespec's
   resolveMemberInit, the substitution § memberInitBaseSelect refines. The same syntax test as
   § fillSymbolicRootOnly225v, applied there, would decline the substitution. Those cases would leave stage 1, but they
   are this ground's next law, gridded against the elaborated view first.
2. **Two instances of one child with two member widths** (FO/g16, r11u225 OS/o21): the fill law fires on the first
   instance only. In g16's elaborated view the second instance's range reads the first one's member (`Info.x` for
   golden's `Info.y`), a pre-existing name bind.
3. **Carried from r11u225 unchanged:** items (1) UVM_SEQ_ARB_TYPE and (2) this_type (the MiniAmiq, SeqDriver,
   SimpleUVM, Scoreboard and BuildUVMPkg heads, unchanged in every sweep here); (3) imported scalar typedef formals;
   `'0`/`'z` and net-declaration `'1` onto a substituted width (OS o05, o19, o12); the Earlgrey records; the shapes
   neither law reaches (FA f04, f07, f09; OS a11, a12, a16, a22, o14-o16); the invisible re-parenting of the shared
   constant.

## 7. Determinism (three concurrent runs per binary, drivers/det.sh; [evidence/det/](evidence/det/))

- **Deterministic on both binaries, the same hash on each:** Earlgrey_0_1 d/t, SeqDriver d/t, BuildUVMPkg d/t and
  SimpleUVM t.
- **The coins,** all pre-existing and all drawn by pristine as well:
  - MiniAmiq d/t (`accabd75`, `dd7b20df`, `1d91262b`): identical dumps.
  - SimpleUVM default (`2ca40da0`, `4cd63e62`): identical dumps.
  - Scoreboard default (`1a416c8d`, `25e129dc`, `44613c73`): `44613c73` has an identical dump. `25e129dc` has a
    94-line dump diff, and its sorted dumps are identical: the svunit listing order.
- **Every sweep mover of MiniAmiq** (law vs pristine d, fix vs law t) has a dump identical to the other side's.
- **The refinement allocates nothing** on a design it does not reach: no heap block, and a trace string only when
  tracing.

## 8. Findings on process (the implementer's)

- **OS/o01 duplicates a corpus source.** It is the uhdm2rtlil corpus row's `dut.sv` with a `// §` first line added, so
  a second copy of a corpus test source now sits under tools/probe. That goes against the one-place rule for test
  inputs; tests/probe already excludes the cases that duplicate a corpus test. It is evidence, not a gate case, so it is
  left in place; the integrator decides.
- **The owner registry is filled whether or not its switch is set.** The `initHierOwners225().emplace_back` call is
  not gated by `R11U225_INITHIERFILL_OFF` or `R11U225_OFF`. It is harmless: the registry is read only by the gated fill
  law, and `R11U225_OFF` still gives pristine bytes on every case-view here.
- **No stray files.** I checked the case directories, both worktrees and my scratch.

## 9. Files

- **cases/FA** (12, ifArrElemLitCaFresh225) and **cases/FO** (28, initHierAtRefToken225, initHierCaLhsBareName225,
  initHierFillKept225 and fillSymbolicRootOnly225v). Every case's first line names its law.
- **drivers/:**
  - env.sh: pins, fence, tool guards, `B=/tmp/v11u225_bin`.
  - case.sh, census.sh, det.sh, dscases.py and awayall.py, copied from r11u225repro with this directory's paths.
  - awaycase.py: the away census over case.sh stores.
- **evidence/:**
  - fresh_cases.txt, grid_r11u225_rerun.txt, switches.txt.
  - away/ (cases pristine->law, pristine->fix, the reversed control, and the gate sweeps pristine->fix).
  - downstream_cases.txt, downstream_fix_cases.txt.
  - det/, sweeps/ (the three sweep summaries).
  - prediction_fix_frozen.txt.
