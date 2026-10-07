# v11u272 — adversarial verification of r11u272 (§ leftoverTsCopyPerElabUse272)

Pass 272, verifier, pair A, base 888e916b. Implementer's patch `/tmp/r11u272.patch` (md5 c72ad228), applied clean
on a fresh 888e916b worktree. **VERDICT: ACCEPT, no production fix.** Every headline number of the implementer
reproduced bit for bit on binaries built here; 73 fresh case dirs (146 case-views) in four families attacked the law
and found no break: no case-view leaves STRICT_EQUAL, no uhdm-cmp line count or exit code changes, the chain-keyed
away census reads 0 away and the dump census 0 lost on every mover, and every downstream verdict is the same on both
binaries with the slang lane's RTLIL byte-identical. This directory adds cases and evidence only; the production
files are the implementer's (`src/ParamEmit.cpp`, `src/R272.h`, `src/R270.h`).

## Binaries (built here, frozen read-only before any measurement)

- pristine: 888e916b, system-deps Release config, md5 **0abca7967cdc381814fce3f657599a03** = the main tree's
  `build/slang-uhdm`.
- law: 888e916b + the patch, md5 **779f518375985a3302d9f77c61790457** = the implementer's lawG. Reports
  `slang 12.0.0+545f88b2e`, UHDM 1.87.
- Both sweeps were run from the law worktree (probe databases embed the source path), workdirs of equal length.

## Reproduction of the implementer's numbers

| measurement | implementer | here |
|---|---|---|
| pristine sweep probe / surelog / uhdm2rtlil | baseline exactly | probe 3682 + 405 (csv byte-identical to `results/golden_probe.csv`), surelog 477 + 3 / 471 + 3, uhdm2rtlil 803/1/67 both modes; regressions=0 conversions=0 changes=0 in all three |
| law sweep probe | 3703 + 384, conversions=21 changes=1 | **3703 + 384, regressions=0 conversions=21 changes=1**, the same 21 names and r11u26repro/m7 `differ:fullname(40) -> differ:fullname(38)` |
| law sweep surelog / uhdm2rtlil | 0 / 0 / 0 | regressions=0 conversions=0 changes=0 in both; the status and strict columns of every row-mode equal to pristine's (row-by-row diff empty) |
| downstream | 803/66/2/0, csv = pristine = baseline | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on both binaries, csv byte-identical to pristine's and to `results/downstream_uhdm2rtlil.csv`; 7 of 805 slang-lane databases move (the seven uhdm2rtlil tests below), their `.il`, `_nohier.il`, `_synth.v` byte-identical (21 of 21 files) |
| firing census (`drivers/tracecensus.sh`, filter built from `$FENCED`) | 83 lines, md5 4b927121 | **identical line for line**, md5 4b9271213452c94b310221f862d63900 |
| byteverify corpus (fence-filtered hard-link mirrors, SELFCHECK=1) | 16 / 2560 = predicted | PATH_SETS_IDENTICAL 2560, **MOVERS 16 / 2560**, exactly the predicted StructParamPatternInitCast d/t and uhdm2rtlil def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot, portsel_struct_param, struct_member_cfg_width, struct_param_func_arg, struct_param_func_loop d/t; all CMP_EQUAL and strict-equal on both binaries |
| byteverify probe | 57 / 4087 = predicted | path sets identical, **57 / 4087**, equal to the 57 probe lines of the census carrying a firing that is not only an abstention |
| chain-keyed away census | away 0 on 16 + 57, control away 8 | away=0 on all 16 corpus movers (toward 1-6) and all 57 probe movers; positive control (binaries swapped on r11u26repro/m12) **away=8** |
| canaries | ok=52 / ok=16, ctcan2 PASS | surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, `EXPECT_UNKNOWN=1` and `EXPECT_UNKNOWN=6` ctcan2 PASS, on both sweeps |
| binary-path audit | 3273 of 3323 | 3273 of 3323 cmds.txt name each sweep's own frozen binary; the other 50 carry no slang line (Surelog-only rows) |
| determinism | one hash per row-mode | three concurrent draws of the law binary on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg, Rggen, both modes: one hash per row-mode, equal to the law sweep's (Scoreboard and Rggen testflags write no database, as on the baseline) |
| implementer's grid (cases/L of r11u272repro, 52 case-views) | 48 moving, 25 entering, 0 leaving | rerun on these binaries: every verdict field (cmp, cmplines, strict, rc) identical line for line, summary identical |
| byte controls, 26 dirs | 2620 case-views, 132 moving, 16 entering, 0 leaving | **identical**: 2620, 132 moving (the same names), 16 entering, 0 leaving, 0 rc changes, uhdm-cmp line counts changed only on r11vu13repro v3 / v10 both views (308 -> 320) |
| MiniAmiq d/t | bytes = pristine | bytes = pristine (no corpus mover besides the 16), strict `differ:col(2)` unchanged, heads #241741 / #243118 (TaskFuncEmit) |

**SELFCHECK 2559 / 2560.** byteverify's negative control compares every database of one side against ONE fixed
database (its first path) and must flag every path; the fixed database is identical to itself, so exactly one path
is not flagged. It is an artefact of the self-check, not a mover.

**The sweeps' exit codes.** The pristine gate sweep exited 0; every later sweep exited 1 on the law-index staleness
check alone (this directory's cases were added between the two sweeps); `tests/LAWS.md` is regenerated last.

The 21 conversions as the fresh law `probe.csv` reads them (`EQUAL,,equal` each): r11u24repro/n12, n3;
r11u26repro/m12, m13, m15, m6, m8, m9; r11u28repro/a13, a16, a4, a5, a6, a7; r11v26repro/v12, v13, v15, v16, v18,
v2, v9. The change: `r11u26repro/m7,STRICT_NOTEQUAL,differ:fullname(38),differ:fullname(38)`, first record
unchanged (#74 ref_typespec `pk` against ours `work@dut`), two fullname records cleared, chain census away=0
toward=4.

## The attack (cases/, every case's first line names § leftoverTsCopyPerElabUse272; drivers/grid.sh, every line carries rc)

73 case dirs, both views, four configurations each (pristine, law, law + `R11U272_OFF`, law +
`R11U272_LOTSCOPY_OFF`): `evidence/grid.txt` 584 lines, `evidence/grid_summary.txt`.

**146 case-views: 116 moving, 27 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 0 uhdm-cmp verdict
changes; `R11U272_OFF` and `R11U272_LOTSCOPY_OFF` each give pristine's bytes on 146 of 146.** Away census on all
116 movers (`evidence/away_grid.txt`): chain-keyed away=0 on 116 of 116, dump census lost=0 on 116 of 116.
Downstream (`evidence/downstream_cases.txt`): 54 IDENTICAL, 12 EQUIVALENT, 7 DIVERGENT, the same verdict on both
binaries for every case, the slang lane's RTLIL byte-identical between the binaries (219 of 219 files).

- **VL (29 dirs, RTL reads of the parameter in continuous assignments, always blocks, functions):** instance arrays
  (vl01), two-level for-generate (vl02), depth 3 (vl03), RTL reads in slots, a function and always_comb (vl04), a
  vector-typed parameter with the struct default (vl05), module localparams named after the parameter (vl06), one
  default and one override instance (vl07), defparam (vl08), if/case-generate conditions (vl09), a type parameter
  typing the parameter (vl10), an explicit import (vl11), a pass-down to a grandchild (vl12), instances in if and
  case generates (vl13), an implicit net (vl14), two struct parameters (vl16), a class specialization in a bound and
  a `this.` path (vl17), an unpacked struct (vl18), a builder with an argument in another package (vl19), the top
  and its child (vl20), an operation leftover with signed and enum members (vl21), three nesting levels (vl22), a
  loop in the builder (vl23), ports and nets of the same struct (vl24), generate-local localparams (vl25),
  macro-born default and builder body from an include in another root file (vl26), two child modules (vl27), the
  parameter as a package-function argument and a call index (vl28), `assign o = P` (vl29), a two-level if-generate at
  depth 2 (vl30). Most are uhdm-cmp stage 1 on BOTH binaries because a continuous assignment reading `P.<member>`
  folds differently (pre-existing, ModuleEmit's elaborated cont_assign: the VM family removes it); vl04, vl06, vl09,
  vl24 enter STRICT_EQUAL, vl29 reads `fullname -> name` (the `assign o = P` face, the implementer's residue 1).
- **VM (23 dirs):** the VL shapes with every continuous-assignment read of the parameter replaced by a localparam
  read: vm07, vm20, vm26, vm27 enter STRICT_EQUAL in both views; vm01, vm03, vm13, vm14 keep a pre-existing `col`
  first record (the bit-select `P.u.a[0]` span) with their fullname records falling 9 -> 1 and 5 -> 1.
- **VN (14 dirs, the value-copy boundary):** a cast default (vn01), a parenthesized default (vn02, enters), an
  untyped parameter (vn03), a member-select default (vn04), a conditional default (vn05), a positional override
  beside a default instance (vn06), a body localparam (vn07, enters), a header wildcard import (vn08), $unit types and
  parameters (vn09), a package parameter naming another package's parameter (vn10), a second header parameter
  defaulting to the first (vn11, enters), always_ff and task reads (vn12, enters default view), converted names
  (vn13, vn14: the law does not fire).
- **VO (7 dirs):** a packed union (vo01, the law stands aside), a packed-array member (vo02), an unpacked struct with
  real and string members (vo03, does not fire), an instance-array range and a member-select override (vo04), two
  packages (vo05, enters), generate loops bounded by the parameter with continuous assignments one and two levels
  down (vo06, enters), calls in part-select bounds and indices, an increment indexed by a call (vo07, enters default
  view).

Two first drafts were illegal SV and are not kept (a module instantiated in an interface body; a localparam reading
an input port): both exited 3 on both binaries.

## Findings (none a break)

1. **Two-level generate scopes are not walked** (VM/vm02 `for` in `for`, vm30 `if` in `if` at depth 2: bytes equal
   to pristine, the leftover `ref_typespec` full-name records `<in>pk::c_t.u` against our `pk` still there): the
   law's walk visits a module_inst's `Gen_scope_arrays` one level deep and never a gen_scope's own nested arrays.
   An under-reach, wrong on pristine too; the extension is a recursive gen_scope walk in the same drain.
2. **A type parameter typing the struct parameter** (VL/VM vl10 / vm10, `parameter type T = pk::c_t, parameter T P =
   pk::C`, stage 1 on both binaries): our elaborated P binds a struct named `T` (the type parameter's instance-level
   struct, the module/type ground's object) and the law's copy takes that name, `work@dut.k0.P.T.u`, where golden's
   copy reads `work@dut.k0.P.pk::c_t.u`; pristine already writes `P.T.u` on that struct's members. Dump census lost
   0; the name fix is the sister's (TypeEmit's type-parameter struct naming).
3. **Member reads still bind the listing's members, not the copy's** (VN/vn12 elaborated view, the implementer's
   l11_slots_el and VO/vo07_el the same shape): `P.u.a` read in a task or a slot keeps `ref_obj a ->
   typespec_member a` of the package listing, whose ref_typespec reads `pk::pk::in_t::a` where golden binds the
   copy's member `work@dut.k0.P.pk::c_t.u.pk::in_t.a`. Wrong on pristine too (1 record left of 8 on vn12_el); the
   rebinding of a member-select's member to the instance's copy is the natural next law on this ground (ExprEmit).
4. **The converted value** (r11vu13repro v3 / v10, the implementer's residue 3): measured by full-name multisets the
   law ADDS `work@top.Cut.p::ucfg_t.a` (golden has it once, pristine never) and one value-copy name
   `p::ucfg_t.a` that golden does not write (golden writes `p::cfg_t.u.p::ucfg_t.a` four times, pristine and the law
   never); stage 1 on both binaries, dump census lost 0. Fresh converted-name shapes without other faces (VN/vn13,
   vn14) do not fire the law. The implementer's candidate refinement (copy the value only for an unconverted name)
   stays unconfirmed: no stage-2 shape reaches it.
5. The value-copy rule's own boundary matches golden wherever the walk is strict-comparable: a parenthesized default
   copies (vn02 enters), a positional override keeps the listing for the value (vn06, toward only), a body
   localparam copies (vn07 enters), a header parameter defaulting to another header parameter keeps the listing for
   the value and copies the parameter (vn11 enters).

## Byte controls widened (drivers/controls.sh, path lists filtered by `$FENCED` first)

39 further repro dirs of the struct-parameter and this ground's recent passes (r11u10, r11u11, r11u14, r11u15,
r11u17 to r11u23, r11u25, r11u27, r11v16, r11v17, r11v21, r11v22, r11v23, r11u80, r11u83, r11u84, r11u85, r11v80,
r11v83, r11v84, r11u250, v11u250, r11u252, v11u252, r11u266, v11u266, r11u268, v11u268, r11u271, v11u271, r11u111,
v11u111, r11u108, r11u112): **2516 case-views, 28 moving, 0 entering, 0 leaving, 0 exit-code changes, 0 uhdm-cmp
line-count changes** (`evidence/controlsW_summary.txt`). The 28 movers are r11u14repro c1 / c7, r11u21repro t5 / t8 /
t10 / t11, r11v16repro v3 / v5 / v6 / v7 / v12 / v14, r11v21repro v5 / v6, each in both views; 26 are uhdm-cmp
stage 1 on both binaries and r11v16repro/v14 stays `STRICT_NOTEQUAL fullname` with two records toward golden; the
chain-keyed away census reads away=0 and the dump census lost=0 on all 28 (`evidence/controlsW_away.txt`). With the
implementer's 26 dirs: 65 dirs, 5136 case-views, 160 moving, 16 entering, 0 leaving.

## Residues (ranked; all wrong on pristine too)

1. The implementer's residue 1, `assign o = P` with a struct parameter (25 probe cases, VL/vl29): ModuleEmit
   emitContAssigns, the sister's ground.
2. Member reads binding the listing's member instead of the instance copy's (finding 3, ExprEmit, this ground).
3. Nested generate scopes not walked (finding 1, this law's drain).
4. Module-local function sources (r11u26repro m4, m7, r11u28repro a2) and the converted value (finding 4).
5. Type-parameter-typed struct parameters (finding 2, TypeEmit, sister); interface, wildcard-import, pattern-override,
   alias, implicit-net and class-specialization shapes stage 1 on both binaries; the cast default (vn01), the
   conditional default (vn05), $unit (vn09) and union (vo01) shapes stage 1 on both.

## Sister-ground faces (reported, not written)

- TaskFuncEmit: the constructor return class_var span, MiniAmiq's last face (#241741 / #243118).
- ModuleEmit emitContAssigns: the `assign o = P` struct-parameter read; the elaborated cont_assign fold of
  `P.<member>` that puts the VL family at stage 1.
- TypeEmit: the type-parameter struct object named after the type parameter (finding 2).

## Process

- Worktrees /tmp/wt_v11u272 (law) and /tmp/wt_v11u272pris (pristine), both at 888e916b; builds -j 2; binaries
  frozen read-only in the scratch before any measurement; no edit of `src`.
- Every corpus path list (mirrors, census, away census, downstream database compare) was filtered by `$FENCED`
  before any file was opened; the census ran with the filter built from `$FENCED`; no fenced test was dispatched or
  read outside the gate sweeps.
- A first byte-controls launch ran nothing because the copied drivers had lost their exec bit; it was rerun.
  One of my own waiters used a `pgrep -f` pattern that its own command line contained; it was stopped by its own
  task id. No other process was signalled.

## Files

- `cases/VL`, `cases/VM`, `cases/VN`, `cases/VO`: 73 case dirs (vl26 / vm26 carry `args`, `pkg.sv`, `defs.svh`).
- `drivers/`: copied from r11u272repro/drivers (case.sh, grid.sh, gridsum.py, controls.sh, ctlsum.py, tracecensus.sh,
  det.sh, bvmirror.sh, away*.py, awayall.sh, strictcmp_x.cpp, cc_x.sh, env.sh), `dscases.py` reading an `args` file.
- `evidence/`: grid.txt, grid_summary.txt, away_grid.txt, downstream_cases.txt, away_corpus_movers.txt,
  away_probe_movers.txt, byteverify_corpus.txt, byteverify_probe.txt, predict.txt, determinism.txt, controls
  summaries, sweep summaries.
