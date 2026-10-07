# v11u270 — adversarial verification of r11u270

Verifier for pass 270 (the expression/parameter ground), base 8454e9ff, the implementer's patch `/tmp/r11u270.patch`
applied unchanged on a fresh worktree. **Verdict: VERIFIED, no production fix.** Every headline number of the
implementer's report reproduces bit for bit on binaries I built myself, and 50 fresh case dirs (100 case-views) find no
case where pristine was right and the law is wrong: none leaves STRICT_EQUAL, none changes its uhdm-cmp line count,
none loses a golden record in the chain-keyed census, and none changes its downstream verdict or its slang-lane RTLIL.

## Binaries (frozen before any measurement)

| binary | md5 | notes |
|---|---|---|
| pristine | 4473d181c349acbd4c515811197997aa | the same md5 as the main tree's `build/slang-uhdm` |
| law | 52efc588f387d179a6b952267ae53025 | the same md5 as the implementer's law binary |

Both report `slang 12.0.0+545f88b2e`. Both sweeps ran from the law worktree, so the probe databases embed the same
source paths and can be byte-compared. Every cmds.txt was audited: 3273 of 3323 name the sweep's own binary, and the
other 50 carry no slang line (`evidence/byteverify_and_canaries.txt`).

## Targeted rows (law sweep `surelog.csv`)

```
SeqDriver,default,CMP_EQUAL,,,equal
SeqDriver,testflags,CMP_EQUAL,,,equal
MiniAmiq,default,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)
```

**SeqDriver d/t CONVERT** (`differ:fullname(6)` -> CMP_EQUAL). MiniAmiq d/t move `differ:fullname(4)` -> `differ:col(2)`.
`uhdm-strictcmp --max 5` on the law databases reads the same two records in both modes:

```
#241741 col class_var svaunit_pkg::svaunit_immediate_assertion_details::new  golden 43:23-29  ours 43:30-34
#243118 col class_var svaunit_pkg::svaunit_immediate_assertion_info::new     golden 37:23-29  ours 37:30-34
```

I checked the decode against Surelog's source. `CompileHelper::compileClassConstructorDeclaration`
(third_party/Surelog/src/DesignCompile/CompileStmt.cpp) locates the return class_var at
`varId = Sibling(Child(first Tf_port_item))`. For `function new(input string name = ...)` (svaunit line 43) that node is
the data type `string`, columns 23-29. Ours writes `nameSpan(args0[0]->location, args0[0]->name)` in TaskFuncEmit's
constructor block. That file is the sister ground (r11u273), so this pass reports the face and writes nothing there.

## Gates reproduced (`evidence/sweep_gates.txt`)

| gate | pristine sweep | law sweep |
|---|---|---|
| probe | EQUAL=3634, STRICT_NOTEQUAL=453; 0 regressions, 0 conversions, 0 changes | 3634 + 453; 0 regressions, 0 conversions, **1 change**: r10uvm99repro/g99_a9_fence `differ:fullname(2)` -> `differ:count(0)` |
| surelog | default 476 + 4, testflags 470 + 4; 0 / 0 / 0 | default 477 + 3, testflags 471 + 3; 0 regressions, **2 conversions** (SeqDriver d/t), **2 changes** (MiniAmiq d/t) |
| uhdm2rtlil | 803 / 1 / 67 in both modes; 0 / 0 / 0 | the same; 0 / 0 / 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; the csv is identical to pristine's and to `results/downstream_uhdm2rtlil.csv` |

- **Row-by-row csv diff, pristine against law:** the only rows that differ are the four rows above and g99_a9_fence.
  The two LowMem testflags rows differ only by the workdir path in their detail text.
- **g99_a9_fence:** pristine's head is two ref_typespec records (`work@xi99.c3` where golden has `work@xi99`). The law
  clears both. The 342 vs 343 object count was already present on pristine.
- **uhdm-cmp:** 0 lines on every touched row. All four rows are still judge-equal.
- **Law-index check:** both sweeps exited 0 on it, because both ran in the law tree, whose tests/LAWS.md the patch
  regenerated. The downstream sweeps exited 1 on the law-index check alone: by then this directory's new cases had made
  the index stale. tests/LAWS.md is regenerated last in the verified patch.

## Movers, census, byteverify (`evidence/byteverify_and_canaries.txt`, `evidence/predict.txt`)

- **Firing census:** I reran the implementer's `drivers/tracecensus.sh` (copied here) with the law binary, filtered by
  `$FENCED`. My `predict.txt` is identical line for line to the implementer's (md5 5d7630a3). It names six databases:
  MiniAmiq d/t, SeqDriver d/t, probe g99_a9_fence, and probe r10earl41repro/v41v_comment, where
  § scopedCallPrefixEndsAtColons270 fires twice in `splitScopedName12` for a caller that never reads the end. The
  census shows no abstention or switched-off firing on any corpus or probe database.
- **byteverify** (fence-filtered hard-link mirrors on both sides, 8 fenced databases skipped each side, SELFCHECK=1):
  - PATH_SETS_IDENTICAL, 2560 paths.
  - **MOVERS 4 / 2560:** MiniAmiq d/t and SeqDriver d/t, exactly as predicted.
  - **SELFCHECK 2559 / 2560 flagged.** The self-check compares every file against one fixed file. The fixed file is
    byte-equal to itself, so it is the one file not flagged. This is a property of the self-check, not a mover.
- **Probe databases:** 1 of 4087 moves (g99_a9_fence, predicted). v41v_comment is predicted but byte-identical: an
  over-prediction, as the implementer reported.
- **Downstream:** 0 of 805 slang databases move.
- **Canaries:** surelog ok=50 changed=2 (the two SeqDriver conversions); uhdm2rtlil ok=16 changed=0. ctcan2 PASS on
  both (EXPECT_UNKNOWN=1 and 6).
- **Chain-keyed away census** (`r11u270repro/drivers/awaychain.py`, strictcmp_x rebuilt with `cc_x.sh`): away=0 on all
  five movers. Toward golden: MiniAmiq d/t 53 each, SeqDriver d/t 6 each, g99_a9_fence 2.
- **Determinism** (`drivers/det.sh`, three concurrent draws of Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen in both modes): one hash per row-mode in 3 of 3, each equal to the law sweep's
  (`evidence/determinism.txt`). Scoreboard and Rggen testflags produce no database in the corpus.

## The implementer's grid and controls, rerun

- **Grid** (`r11u270repro/drivers/grid.sh` on its 55 dirs, 110 case-views x 9 configurations = 990 lines, all rc=0):
  - Every cmp, cmplines, strict and rc field is identical to the implementer's `evidence/grid.txt` on all 990 lines.
    Only the md5 differs, because the module_inst file field embeds the worktree path.
  - 86 moving, 55 entering STRICT_EQUAL, 0 leaving; `R11U270_OFF` equals pristine on 110 of 110.
  - Each mover returns to pristine bytes under exactly one switch: INSIDEPA 34, ENUMALIAS 14, MARGIDXPARENT 14,
    TIMEKWSPAN 14, SCOPEDEND 10.
  - The implementer's 118 / 92 / 61 includes 8 R0 case-views measured before those dirs were removed (r11u271repro R
    r01, r02, r04 in both views, plus r03). The difference, 6 moving and 6 entering, is exactly those R0 movers, which
    the controls below measure again.
- **Byte controls, the same 26 dirs** (`r11u270repro/drivers/controls.sh`): 4040 case-views.
  - 6 moving, all entering STRICT_EQUAL: r11u271repro R/r01, r02 and r04 in both views.
  - 0 leaving, 0 exit-code changes, 0 uhdm-cmp line-count changes. The 14 nonzero-rc case-views are the same on both
    binaries.
  - This is identical to the implementer's `evidence/controls.txt` summary.
- **Widened controls, 16 more dirs** (r11u252, v11u252, r11u254, v11u254, r11u256, v11u256, r11u258, v11u258, r11u260,
  v11u260, r11u262, v11u262, r11u267, v11u267, r11u269, v11u269): 2564 case-views, **0 moving**, 0 rc changes, 0 cmp
  changes (`evidence/controls_summary.txt`, `evidence/controls_widened.txt`).
- **Positive control for § insideSetQualKeepsOp270:** on v11u271repro VN/vn19 the law keeps pristine's bytes in both
  views, and `R11U270_INSIDEQUAL_OFF=1` moves them. This is the shape the refinement was written for.

## Attack grid (`cases/`, 50 dirs, both views; `drivers/grid.sh`, every line with rc; `evidence/grid.txt`, `evidence/grid_summary.txt`)

- **Configurations:** pristine, law, law + R11U270_OFF, and the law with each of the six switches off: 900 lines, all
  rc=0.
- **Totals:** 100 case-views, **52 moving, 14 entering STRICT_EQUAL, 0 leaving, 0 uhdm-cmp line-count changes.**
- **Switches:** `R11U270_OFF` equals pristine on 100 of 100. Each mover returns to pristine bytes under exactly one
  switch: INSIDEPA 20, SCOPEDEND 12, TIMEKWSPAN 12, MARGIDXPARENT 6, ENUMALIAS 2.
- **Away census** (`evidence/away.txt`; record census for stage-2 case-views with v11u202's `away.py`, dump census for
  stage-1 ones with `drivers/awaydump.py`): 51 of 52 movers lose 0 golden lines.
  - The exception is VI/vi01_el: the dump census reads 28 lost lines while the distance falls 42 -> 7. The
    chain-keyed census on it reads away=0, toward=1.
  - The lost lines are print positions. The module-level localparam Q, read inside the generate block, moves to the
    module's param_assign. That is golden's parent: in golden's dump the constant at 6:34 sits under
    `param_assign 3:18` with ref_typespec `work@top`, byte for byte the law's lines. So pristine's dump no longer
    expands the generate scope under that constant's parent.
- **Downstream** (`drivers/dscases.py` on all 50 dirs, both binaries; `evidence/downstream.txt`): 45 IDENTICAL, 3
  EQUIVALENT and 2 DIVERGENT on both binaries. VE/ve06 and VT/vt01 are DIVERGENT on pristine too. The slang lane's
  `.il` and `_nohier.il` are byte-identical between the two binaries on all 50 dirs.

| cases | law | shapes | result |
|---|---|---|---|
| VI/vi01, vi02 | § insideSetParamFoldKeepsPa270 | a generate-local localparam shadowing a module parameter; a generate-block function with an import and a shadowing local | stage 1 on both, 0 lost by dump. Golden folds the generate-local `P` to the MODULE's `P` (value 1, Surelog's own lookup) where ours keeps the ref_obj: a pre-existing stage-1 face. The law never touches that ref_obj, and the module-level `Q` it moves matches golden. |
| VI/vi03, vi04, vi06, vi09, vi10, vi12, vi13, vi14, vi17, vi18, vi20, vi21 | the same | a class in a module, a class constraint, header-parameter overrides in two instances, an unpacked array member with a range, a for condition / ternary / assertion, a two-level generate, instance depth 1-3, an implicit net with case-inside, two instances with localparams, a class specialization's value parameter, $unit parameters, a task in generate instances | STRICT_EQUAL on both binaries, no byte moves |
| VI/vi05, vi07, vi08, vi11, vi15, vi16, vi19, vi22, vi24 | the same | the constant slots (a localparam initializer and a dimension width from an `inside`), an interface modport function, an inherited class parameter, a package's own class and function, typed vector and string parameters, a package importing a package, an interface property, typedef'd and enum parameters | stage 1 on both (each a pre-existing face), dump census 0 lost and 3-8 gained wherever bytes move |
| VI/vi23 | the same | a class method: plain set, case-inside, an open-range set `[UVM_SET:UVM_CHK]`, a ternary, a for loop, a task | fullname(10) -> fullname(2), 0 lost. The 2 left are the open-range BOUNDS, which golden also names `cp::item` (residue 1) |
| VE/ve05 | § enumAliasCastBindsImportCopy270 | two packages each importing the alias, casts in class methods | depth -> **STRICT_EQUAL** in both views |
| VE/ve01-ve04, ve06-ve09 | the same | a module cast, two modules with wildcard and named imports, the home package's function and class, a module-local alias, struct-alias and enum-alias casts, a generate block and localparam cast, a function in two instances, a class in a module | no byte moves (ve06 and ve07 stage 1 on both; ve09 fullname on both, not this law's face) |
| VT/vt05, vt06 | § sysCallTimeKwNameSpan270 | `$time()` / `$realtime ( )` in a module initial and always, `$display` arguments, an `if` condition, a ternary, a class method, a macro body, a call split over two lines, inside a concatenation | endcol -> **STRICT_EQUAL** in both views |
| VT/vt01, vt02, vt03, vt07 | the same | the same shapes with time / realtime variables, `$stime()`, `$time`, generate-scope always blocks | stage 1 on both (time vs real typespec, pre-existing), dump census 0 lost |
| VT/vt04 | control | `$signed`, `$unsigned`, `$time` / `$realtime` without parentheses | no byte moves |
| VS/vs05, vs06, vs07 | § scopedCallPrefixEndsAtColons270 | `c:: x`, `c::\n get()`, `c::/*x*/get()`, a static property lvalue and read, a localparam read, a module initial and always_comb, `p::c:: get()`, `p::c::type_id::\n create()` | endcol -> **STRICT_EQUAL** in both views |
| VS/vs01, vs02, vs04 | the same | an inc/dec on a split static property, a type-parameter call `T:: make()`, a class-scoped chain root `c:: obj.v` | stage 1 on both (pre-existing), dump census 0 lost |
| VS/vs03 | control | package-qualified parameter, select, function and struct-member reads written `pk:: X` | no byte moves (the helper's callers on that path do not read the end) |
| VN/vn01, vn02, vn03 | § methArgPathIdxAtHierPath270 | `v.f(v.a[i].lf.z)`, `v.grid[i][j].k`, `v.a[idx[i]].k`, `v.a[gi(i)].k`, `v.a[i].lfs[j].z`, `this.v...`, `v.a[i].lf.arr[j]`, `v.a[i + j].get()`, a sum of two paths, an interface function, a module initial for loop and always_comb, nested method calls in a task | vn02_el and vn03 -> **STRICT_EQUAL**; vn01 fullname(8) -> fullname(1), 0 lost (the remaining record is the `i` inside a call index `v.a[gi(i)].k`, wrong on pristine too: residue 3) |

## Findings (none a break)

1. **The open-range bounds of an `inside` set** (`x inside {[A:B]}` with package parameters, in a class method) are
   named after the subroutine where golden names them after the class. This is the same face as
   § insideSetParamFoldKeepsPa270, which records only direct members and plain members of an open-range set
   (`cases/VI/vi23`, 2 records). It is wrong on pristine too.
2. `src/R270.h` declares an `r11v270On` helper, written by the implementer for a verifier and used nowhere. It is
   harmless, and no fix in this pass needed it.
3. **A call inside a select index of a method argument path** (`v.has(v.a[gi(i)].k)`): golden names `i`
   `...::v.has::v.sva_info[].k::i`, ours `...::v.sva_info[].k::sva_info::i` (VN/vn01, 1 record). It is wrong on
   pristine too, outside § methArgPathIdxAtHierPath270's shape.
4. The implementer's README statements were checked against the code: the qualified-member abstention tests
   `IdentifierName`, and the time law requires an empty argument list and a span longer than the name. The README is
   accurate.

## Residues, ranked (all wrong on pristine too)

1. **Sister ground, TaskFuncEmit:** the constructor's return class_var at `Sibling(Child(first Tf_port_item))`. This is
   the only face left on MiniAmiq d/t (#241741, #243118; r11u270repro C/c01).
2. The `inside` open-range bounds (finding 1, VI/vi23).
3. The call-index name inside a method argument path (finding 3, VN/vn01).
4. The implementer's own list: I/i14, I/i08 (ModuleEmit, sister), I/i25, the realtime typespec (T/t01, t07, and my
   VT/vt01-vt03), the enum-alias shapes E/e08-e10, N/n01, N/n03.
5. The brief's items (2) to (7): not attempted by either agent.

## Process notes

- **Fence:**
  - No fenced test was dispatched or read outside the gate sweeps.
  - Every corpus or probe path list was filtered by `$FENCED` before any file was opened.
  - byteverify ran on fence-filtered mirrors, and the census used the fence-built filter.
  - MiniAmiq and SeqDriver were checked against `$FENCED` before their databases were opened by name.
- **SLIP:** while locating g99_a9_fence's golden, one command ran with its golden-directory variable empty, because the
  Surelog path was not yet exported in that shell. Its `find "$g/" -name '*.uhdm'` therefore listed `.uhdm` names from
  `/`, and the first hit, `/tmp/pbx.uhdm`, was handed to `awaychain.py` and `uhdm-strictcmp` before the mistake
  showed.
  - That file is a 12848-byte case-sized database dated 2026-09-23 that I did not write. Its path names no fenced test,
    and `awaychain.py`'s own fence check passed. Nothing in it was decoded beyond the comparators' first lines.
  - The find read directory entries only; no other file was opened.
  - The command was rerun with a guard (`[ -n "$g" ] && [ -d "$g/" ]`).
- No process was signalled. Nothing was written outside `/tmp/wt_v11u270`, `/tmp/wt_v11u270pris` and the `/tmp/v11u270_*`
  scratch.

## Files

- `cases/VI, VE, VT, VS, VN` (50 dirs). Each `dut.sv` names its law on its first line.
- `drivers/`:
  - copied from r11u270repro: case.sh, env.sh, awaydump.py, dscases.py, det.sh, tracecensus.sh, bvmirror.sh
  - new: grid.sh, gridsum.py, ctlsum.py
  - run in place from r11u270repro: controls.sh, awaychain.py, cc_x.sh
- `evidence/`: grid.txt, grid_summary.txt, away.txt, downstream.txt, controls_summary.txt, controls_widened.txt,
  predict.txt / predict.md5, determinism.txt, sweep_gates.txt, byteverify_and_canaries.txt.
