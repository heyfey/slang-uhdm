# v11u207 — adversarial verification of r11u207: the pass holds on every gate, but § namedUnlinkedWrittenOrder207 broke calls that golden LINKS (three fresh cases went from judge-equal to NOT_EQUAL, and two moved a task's argument order away from golden). Refined behind § namedOrderLinkedDeclines207v (`R11V207_NAMEDLINK_OFF`). UnitElabBlock d/t CONVERT, 7 probe cases convert, 0 regressions.

**Base.** `3668bf30` (branch matrix-1.87). Verified patch: `/tmp/r11u207.patch` (the implementer's). Delivered patch:
`/tmp/r11u207.verified.patch` = `git diff 3668bf30` of `/tmp/wt_v11u207`. It contains:
- the implementer's patch, unchanged;
- one refinement in `src/ExprEmit.cpp` plus its switch helper in `src/EmitHelpers.h`;
- `tools/probe/v11u207repro/`;
- the regenerated `tests/LAWS.md`.

No file of the sister's ground is touched (TypeEmit, ModuleEmit, UhdmExporter, TaskFuncEmit, uhdm_main,
include/UhdmExporter.h). Nothing under `results/`, `third_party/` or `tests/` is edited, apart from the regenerated
`tests/LAWS.md`.

**Resume note.** A reboot killed the first session of this verifier at 11:51. Its worktrees, its frozen pristine
binary and its fresh cases A–G survived on disk. The outage interrupted its pristine sweep, and its law build had not
finished. Everything below was measured again in this session: both builds, both sweeps, the census, the controls
and every case judgment. No number from before the outage is quoted.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` in the MAIN repository, resolved through git's common dir. Each of these
drivers refuses a fenced name, and fails closed when the fence cannot be read: `j.sh`, `case.sh`, `judge.sh`,
`dscase.py`, `det.sh`, `detob.sh`, `awaycorp.sh` and `uvmdist.sh`. Two drivers keep fenced rows out in other ways:
- `census.sh` runs the corpora and downstream lanes with a `--filter` built from the fence;
- `bvmirror.sh` leaves the 8 fenced row-mode databases out of byteverify (`fenced_skipped=8`).

No fenced source, database or head was read. The only fenced facts cited are the gate sweeps' csv verdicts, and they
are unchanged.

## 0. Verdict

**The implementer's patch: CONFIRMED on every gate and every headline number, with one BREAK, now FIXED.**

The break is in § namedUnlinkedWrittenOrder207. The law lists a named call's actuals in written order in two branches:
- the no-link branch of an in-body class call (§ classCallNoLink12);
- the main branch when `!haveSlots4`.

In the no-link branch, our exporter still BINDS the call in two cases, and golden resolves them too:
- the class's own `extern` / `pure virtual` FUNCTION prototype (§ externProtoInBodyCallBinds12);
- the package free function of that name (§ classOwnLateMethodBindsPkgFn113).

A task whose `extern` or `pure virtual` prototype sits ABOVE the call is also linked by golden, although our exporter
has no object to bind it to (the prototype map holds functions only). In each of these cases Surelog had the callee's
io_decls and lists the arguments in FORMAL order, but the law reordered them.

On legal SV where the pristine binary was right, the law was wrong:

| case (both views) | pristine | r11u207 `lawF` | **verified** | face |
|---|---|---|---|---|
| B/b06 | `STRICT_NOTEQUAL file(1)` | **NOT_EQUAL** | **EQUAL** | `mt(.c(W), .b(1), .a(0))` inside a method of a parameterized class, `extern static` prototype above: golden `0 1 W` |
| B/b10 parse / elab | `EQUAL` / `STRICT_NOTEQUAL fullname(2)` | **NOT_EQUAL** | `EQUAL` / `fullname(2)` (pristine bytes) | a same-class method declared below the caller, which golden binds to the package free function `late` |
| B/b11 | `EQUAL` | **NOT_EQUAL** | `EQUAL` (pristine bytes) | a `pure virtual` function prototype called in-body out of formal order |
| B/b09 | NOT_EQUAL | NOT_EQUAL, `tt(.c(y), .b(x), .a(1))` reordered to `y x 1` (golden `1 x y`) | NOT_EQUAL, pristine bytes | the extern TASK prototype above the caller |
| B/b12 parse / elab | NOT_EQUAL / NOT_EQUAL | NOT_EQUAL / NOT_EQUAL, `ta` and `tv` reordered away from golden | NOT_EQUAL / **EQUAL** | the extern and pure virtual tasks above (`ta`, `tv`: formal order) against the extern task declared below (`tb`: written order, the law's own face) |

In total, 6 case-views went from judge-equal to NOT_EQUAL on the law binary, and 0 do on the verified binary. The
corpus, the probe set and the downstream lanes did not see the break: the firing census of the refinement
(`namedOrderLinkedDeclines207v`) reads 0 firings in every population. The verified binary's gate sweeps therefore read
exactly the implementer's numbers.

**Row verdicts** (fresh csv rows of the verified law sweep `/tmp/v11u207_swL`, NOT written to `results/`):

| row-mode | base | after |
|---|---|---|
| **UnitElabBlock d** | `differ:file(2)` | **CONVERSION** `UnitElabBlock,default,CMP_EQUAL,,,equal` |
| **UnitElabBlock t** | `differ:file(1)` | **CONVERSION** `UnitElabBlock,testflags,CMP_EQUAL,,,equal` |
| BlackBePipeInt d / t | `fullname(2)` / `fullname(2)` | `type(1)` / `depth(1)` |
| BuildUVMPkg d / t | `line(11)` | `line(7)` |
| MiniAmiq d / t | `file(71)` | `file(70)` |
| SeqDriver d / t | `fullname(65)` | `fullname(64)` |
| SimpleUVM d / t | `fullname(95)` | `fullname(94)` |
| Scoreboard d | `fullname(103)` | `fullname(102)` |

**Probe conversions** (7), each now `EQUAL`:
- r10buvm4repro/a2_kindgrid
- r10uvm167repro/g167_d_decline
- r10v167repro/vB_bare
- r10uvm21repro/t32g_t
- r10uvm84repro/g84_c1_lvalue
- r10uvm84repro/v84x6_stmt
- r10uvm85repro/v85x4_pos

**Probe changes** (3, all shrinking):
- g167_b_spell `file(6)` -> `endcol(2)`
- t33e_t `endcol(8)` -> `file(2)`
- v204_s_shadow `endcol(3)` -> `depth(1)`

The rows the task names, at the base and after (unchanged): Earlgrey_0_1 d/t `fullname(76)`, Rggen d `defname(142)`,
Scr1SvTests d/t `type(1)`, arb_idx_cast d/t `endline(2)`, cfg_func_width_loop d/t `line(3)`,
struct_param_func_config d/t `fullname(5)`, InterfArrayBind d `fullname(3)`. SVSwitch d/t is CMP_EQUAL at the base.

## 1. Binaries (frozen `chmod 555` in `/tmp/v11u207_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `d27bb984d49f6d31eb76cd00e98e517f` | `/tmp/wt_v11u207pris` at `3668bf30`, byte-identical to the main tree's build at that base |
| `law.bin` | `7be18fd04b6c3fb632ea4447a6e2dc25` | `3668bf30` + `/tmp/r11u207.patch`, built here: reproduces the implementer's `lawF.bin` |
| `fix1.bin` | `ae0bffb6e4ae2c54f417c1370d5853af` | + the function half of § namedOrderLinkedDeclines207v (ran the first census, law sweep, byte controls and determinism check) |
| **`fix2.bin`** | **`a98fa7d0d2bed31480bc9503ff0305f5`** | **THE DELIVERED SOURCES** (+ the task half). Applying the final src diff to a FRESH `3668bf30` worktree (`/tmp/wt_v11u207chk`, `-j 2`) rebuilds this md5 (it rebuilt `fix1`'s md5 on the previous diff too) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's |

The worktree's diff before this verifier's edits was compared file by file against `/tmp/r11u207.patch`: 92 of 92
entries are identical.

## 2. The refinement

### § namedOrderLinkedDeclines207v (`R11V207_NAMEDLINK_OFF`; `R11V207_OFF` drops every v11u207 refinement)

**Law.** § namedUnlinkedWrittenOrder207 takes a call only when golden leaves it UNRESOLVED. It declines in three
cases:
- **No-link branch (§ classCallNoLink12), bound call.** The call has a `vpiFunction` after the branch's bindings:
  - the prototype (§ externProtoInBodyCallBinds12);
  - the package free function (§ classOwnLateMethodBindsPkgFn113).
- **No-link branch, task prototype above.** The call is to a TASK of the caller's own class whose `MethodPrototype`
  (`extern` or `pure virtual`) sits above the call in the same buffer. The caller is in-body (`!curSubOob9`).
  - Code: `classTaskProtoAbove207v` in ExprEmit.cpp.
  - Our exporter lists no link there, because TaskFuncEmit registers only function prototypes in `classProtoFn12`.
  - Golden links the prototype (`task_call` + `vpiTask`).
- **Main branch, linked call.** The call is `linked4` (the call golden links).

In every declined case the list stays the pristine one: the § writtenCallArgs16 prefix. A prototype BELOW the call
still takes the written order, because Surelog's single pass has not seen it (B/b12 `tb`: golden `y x 2`, verified
EQUAL on that call).

**Decode.** Surelog's `compileTfCallArguments` (the § namedTfArgsFormalSlots4 decode) rebuilds the list in FORMAL
order whenever the callee's io_decls are in hand. The link and the io_decls come from the same resolved callee, so a
linked call is never an `argOrder` list. Every golden record of the grid agrees (`drivers/calls.py`: each call's
link and argument list, per producer):
- b06, b09 `mt`, b10, b11, b12 `ta` / `tv`: formal order with a link;
- b12 `tb`, and the implementer's N grid: written order with no link.

**Gate.** Trace name `namedOrderLinkedDeclines207v` (under `R11U207_TRACE`, like every r11u207 law).
- **Firing census** over every corpus row-mode but the fenced four, the probe set and the downstream lanes: **0
  firings**. The refinement cannot move a gate database, and it moves none (section 4).
- **Switch check** ([evidence/switch/switch_refine.txt](evidence/switch/switch_refine.txt)): with
  `R11V207_NAMEDLINK_OFF=1` or `R11V207_OFF=1`, `fix2` writes `law.bin`'s bytes on b06, b09, b10, b11 and b12, in both
  views.
- `R11U207_OFF=1` on `fix2` writes the pristine bytes on all 76 grid cases in both views.

## 3. Fresh cases (47 of this verifier's, plus the implementer's 29; every one names its law on its first line)

Judged against a pinned Surelog v1.87 golden in two forms, by `drivers/j.sh` and `drivers/jall.sh`:
- the probe form: `-parse -nobuiltin -nocache -sv`, `--single-unit --nobuiltin`. A `nosv` file drops `-sv`; an
  `args` file lists the root files.
- the `-elabuhdm` form: `ELAB=1`.

Each case-view gets four columns:
- the verdict per binary, by uhdm-cmp and then uhdm-strictcmp;
- `rc` for both binaries;
- whether the database moved;
- the order-blind dump distance.

All in [evidence/grid/grid.tsv](evidence/grid/grid.tsv).

| set | case-views | EQUAL pristine / law / verified | judge-equal -> NOT_EQUAL, law | the same, verified | `R11U207_OFF=1` not pristine |
|---|---|---|---|---|---|
| r11u207repro (the implementer's 29 cases) | 58 | 8 / 50 / 50 | 0 | 0 | 0 |
| v11u207repro (this verifier's 47 cases) | 94 | 4 / 32 / 38 | **6** | **0** | 0 |

- **Strict worsening.** No case-view moves to a larger count on the same first field. The two same-field changes both
  shrink: d07 `endcol(5)` -> `(3)`, h01 `fullname(7)` -> `(4)`.
- **rc.** Every rc is 0 on both binaries. (Two drafts that met slang's unsupported fixed-array class property, rc 4,
  were rewritten with dynamic and associative arrays before judging.)
- **The implementer's grid count.** The implementer's grid claim "22 go from not-equal to EQUAL" is **21**. Its 29
  cases are 21 conversions, 4 controls (b03, n07, u03, u05) and 4 decode-only cases (p02, p03, x01, x02).

The cases, by law:
- **A/a01–a04: § hiddenBlockVarMintNoFile207** (Verilog `top.v`).
  - a01: hidden logic in a task, read before written, and the same name hidden in two blocks.
  - a02: three instance levels beside a port-connection implicit net.
  - a03: a width and an initial block. NOT_EQUAL on both binaries; the law does not fire.
  - a04: a function body and a nested named block with a nonblocking assignment.
  - a01, a02 and a04 go `file(n)` -> **EQUAL** in both views.
- **B/b01–b08: § namedUnlinkedWrittenOrder207**; **B/b06, b09–b12: § namedOrderLinkedDeclines207v**.
  - b01: for- and if-generate processes in the definition view. NOT_EQUAL -> **EQUAL**.
  - b02: an inherited task and function, mixed positional and named, a call in a fork. -> **EQUAL**.
  - b07: string, real and enum formals. -> **EQUAL**.
  - b03, b04, b05, b08: NOT_EQUAL on both binaries on other faces. The order-blind distance shrinks or stays.
  - b06, b09–b12: the break, section 0.
- **C/c01–c04: § namedSlotFillerRootFile207**.
  - c01: an included package header.
  - c02: three instance levels, generate and continuous assignment.
  - c03: a macro from an included header. `file(8)` -> **EQUAL**.
  - c04: an included class. Elab view `file(3)` -> **EQUAL**.
  - c01, c02 and c04's parse view are NOT_EQUAL on both binaries.
- **D/d01–d08: § bitSelMethodCallIdxSpan207**.
  - d01: interface functions through a port and an instance. The law does not fire.
  - d02: static and package calls, the controls. Bytes unchanged.
  - d03: a method on a call result, an array element, `this.o`, a multi-line argument list.
  - d04: lvalue selects beside rvalues. `endcol(4)` -> **EQUAL**.
  - d05: part-select bounds, two dimensions, a select inside an index.
  - d06: built-in methods. Bytes unchanged.
  - d07: macro-written indices. `endcol(5)` -> `endcol(3)`.
  - d08: module initial, two-level for-generate, task. `endcol(8)` -> **EQUAL**.
- **E/e01–e05: § parenMethodCallPathSpan207**.
  - e01: `this`, `super` and two handles.
  - e02: interface functions and the plain and package controls. Bytes unchanged.
  - e03: built-in and static methods.
  - e04: two lines, a macro, a ternary and a concatenation. `endline(5)` -> **EQUAL**.
  - e05: module, for-generate, an lvalue index. `endcol(7)` -> **EQUAL**.
- **F/f01–f05: § foreachThisArrAtThisToken207**.
  - f01: `this.obj.arr`, `this.s.a`. See residue V2.
  - f02: a formal or local of the same name. `endcol(1)` -> **EQUAL**.
  - f03: whitespace and a line break around the dot, an escaped name, one-letter and long names. `endcol(4)` ->
    **EQUAL**.
  - f04: the `super.`, bare, handle and in-module controls.
  - f05: a macro, and a specialization.
- **G/g01–g04: § parenCastWidthRefPkgBare207**. Package-only shapes, a second package, an importer of the width
  parameter alone, a re-exporting package. NOT_EQUAL on both binaries at the base (golden's cast-width shape and
  folds), and the order-blind distance shrinks on all four.
- **H/h01–h05: the cautions' contexts.**
  - h01 (§ bitSelMethodCallIdxSpan207): class-specialization static calls `K#(2)::sf(i)` and `p::K#(3)::sf(1)` as
    indices, chained handles, `this.o.gi(2)`, an implicit net beside it. `fullname(7)` -> `fullname(4)`.
  - h02: an interface body's own always block and function indexing by a class handle's method, parenthesized too.
    `endcol(12)` -> **EQUAL**.
  - h03: parenthesized specialization static calls, `super.` and defaulted arguments.
  - h04: `foreach (this.<array>)` over dynamic, associative and queue properties, with a same-named local.
    `endcol(3)` -> **EQUAL**.
  - h05: named calls that golden links in modules, interfaces, packages and classes. Unchanged verdict (the filler
    files move).

**Downstream** (the gate's own `one()`, `drivers/dscase.py`,
[evidence/downstream/](evidence/downstream/)): all 76 cases, pristine against verified. No case leaves IDENTICAL.
- A/a01, A/a02 and the implementer's U/u01, U/u02: **EQUIVALENT -> IDENTICAL**. The implicit wire's `\src` attribute
  no longer appears, as in golden.
- C/c02 and G/g01: DIVERGENT on both binaries, at the base as well. Both are pre-existing: c02's continuous-assignment
  call fold, and g01's package cast function.

**Switch checks** ([evidence/switch/](evidence/switch/), `drivers/switchcheck.sh fix2.bin`, both grids, both
forms): each r11u207 switch alone, on every case where only its law fires, restores the pristine bytes. The result
reads NOT_RESTORED none on all 38 lines; cases where another law also fires are listed as mixed.

## 4. The gates (from `/tmp/wt_v11u207`, `tests/sweep.sh --jobs 3`, `SLANG_UHDM` exported)

| gate | pristine `/tmp/v11u207_swP` (`pris.bin`) | **verified `/tmp/v11u207_swL` (`fix2.bin`)** |
|---|---|---|
| (1) build | `d27bb984...` | `a98fa7d0...`; the fresh-tree rebuild reproduces it |
| (2) probe vs golden_probe.csv | EQUAL 3363 / 724, `regressions=0 conversions=0 changes=0`, `probe.csv` byte-identical to the committed baseline | **EQUAL 3370 / 717, `regressions=0 conversions=7 changes=3`** |
| (3) surelog | `0 / 0 / 0` | **`regressions=0 conversions=2 changes=11`** (464 + 16 / 460 + 14; CMP_NOTEQUAL 3 / 3 unchanged) |
| (3) uhdm2rtlil | `0 / 0 / 0` | `0 / 0 / 0`; `uhdm2rtlil.csv` byte-identical to the pristine sweep's |
| (4) downstream | 803 / 66 / 2 / 0 | **803 / 66 / 2 / 0; `downstream.csv` byte-identical to the pristine sweep's** |
| (5) uhdm-cmp | | every mover keeps its judge status, so its uhdm-cmp stays at 0 lines |
| (6) byteverify | | **13 / 2560 movers, all predicted by name**; SELFCHECK 2559 / 2560 |

- **Numbers against the implementer's.** Every verdict line equals the implementer's final sweep `/tmp/r11u207_swF`.
  The four csvs are identical to swF's with the workdir paths normalised.
  - The verified corpus databases are byte-identical to swF's on 2560 of 2560.
  - `fix1`'s sweep matched on 2559: its Scoreboard default drew the other variant of the known storage-order coin,
    0 sorted-dump lines apart.
- **`cmds.txt` audit.** Every `slang:` line of the corpus workdirs names the sweep's binary: swP 3273 of 3273
  `/tmp/v11u207_bin/pris.bin`, swL 3273 of 3273 `fix2.bin`.
- **Sweep exit code.** The pristine sweep exits 0. The law sweep's `law index` line reads current: `tests/LAWS.md` was
  regenerated before it ran.
- **SELFCHECK 2559 / 2560 is the control working, not a movers line.** byteverify compares every patched database
  against the PRISTINE copy of one fixed path (the first in sort order). That fixed path is not a mover, so its own
  patched database equals its pristine copy, and exactly one of the 2560 comparisons reads equal. The threshold is
  `>= N - 1`, so a reading below 2559 would mean a blind comparator or a second identical database.
- **Probe byte movers.** The probe databases embed the source path, which differs between worktrees. So a second
  pristine probe run was made from the law worktree (`/tmp/v11u207_swQ`, csv byte-identical to swP's), and byte
  comparison against it names **10 movers**: the 7 conversions and 3 changes above.
  - An order-blind dump comparison sees only 6 of the 10. The four § namedSlotFillerRootFile207 movers change only a
    constant's file, which uhdm-dump does not print.
- **Canaries** ([evidence/canaries.txt](evidence/canaries.txt)):
  - surelog: `ok=45 changed=7`, exactly the seven canary rows among the eleven CHANGE lines (SimpleUVM d/t, SeqDriver
    d/t, BuildUVMPkg d/t, Scoreboard d).
  - uhdm2rtlil: `ok=16 changed=0`.
  - ctcan2 `EXPECT_UNKNOWN=1` on surelog: `changed=2`, exactly BlackBePipeInt d/t, the named CHANGE.
  - ctcan2 `EXPECT_UNKNOWN=6` on uhdm2rtlil: PASS.

## 5. Prediction, attribution, away census, distances, determinism

**Prediction** ([evidence/predicted_movers.txt](evidence/predicted_movers.txt), frozen `chmod 444` before the verified
law sweep, [predicted_frozen_at.txt](evidence/predicted_frozen_at.txt)). `drivers/census.sh` runs `fix2.bin` with
`R11U207_TRACE`, and `drivers/censum.py` summarises the trace. It predicts:
- 15 corpus row-modes: the 13 movers plus SVSwitch d/t;
- 11 probe cases: the 10 movers plus r10svs4repro/g1_thisidx;
- 0 downstream lanes.

The two predicted-but-unmoved rows are both `foreach (this.data[i])`: a four-letter name spans the same columns as
`this`. The implementer's census names the same 26. Moved and not predicted: **0**.

**Attribution** (firing counts per row, by law):

| row | § foreachThisArrAtThisToken207 | § bitSelMethodCallIdxSpan207 | § parenMethodCallPathSpan207 | other |
|---|---|---|---|---|
| UnitElabBlock d/t | | | | § hiddenBlockVarMintNoFile207 ×1 |
| BlackBePipeInt d/t | | | | § parenCastWidthRefPkgBare207 ×10 (t also § pcwElabKeepsClaim207v, which has no trace) |
| BuildUVMPkg | ×28 | ×5 | ×8 | § namedUnlinkedWrittenOrder207 ×4 |
| MiniAmiq, SeqDriver | ×52 | ×8 | ×14 / ×13 | |
| SimpleUVM, Scoreboard | ×26 | ×4 | ×13 | |

For the probe movers:
- § namedSlotFillerRootFile207: a2_kindgrid, g167_b_spell, g167_d_decline, vB_bare;
- § foreachThisArrAtThisToken207: the other six.

**Away-moved-record census** (v11u202's `away.py`, `drivers/awaycorp.sh`, [evidence/away.txt](evidence/away.txt)):
**0 lost records on all 13 movers**. Gained records per mover: BlackBePipeInt d 75, t 49; BuildUVMPkg 37; MiniAmiq 69;
SeqDriver 79; SimpleUVM 57; Scoreboard 46; UnitElabBlock 2 / 1.

**UVM order-blind distance** (`drivers/uvmdist.sh`, [evidence/uvmdist.txt](evidence/uvmdist.txt); the pristine and
verified sweeps, total = ours-not-in-golden + golden-not-in-ours):

| row-mode | total, pristine | total, verified |
|---|---|---|
| MiniAmiq | 15058 | 14920 (−138) |
| SeqDriver | 11252 | 11094 (−158) |
| SimpleUVM | 4060 | 3946 (−114) |
| Scoreboard | 3029 | 2937 (−92) |
| BuildUVMPkg | 1551 | 1477 (−74) |
| ApbSlave, SVSwitch | 0 | 0 |

These equal the implementer's figures exactly.

**Determinism** (`drivers/det.sh fix1.bin`: three CONCURRENT harness runs;
[evidence/determinism/](evidence/determinism/)):
- **Earlgrey_0_1 default and testflags: one hash per mode.**
- BlackBePipeInt, BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM and UnitElabBlock: one hash per mode.
- Scoreboard default: two hashes, 0 sorted-dump lines apart. This is the known svunit listing-order coin; across all
  sweeps this row draws storage-order variants only.

The determinism check ran on `fix1`. `fix2` differs from it only in the task half, which fires on no corpus row.

**Byte controls** (the implementer's 1760 cases from the evidence grids of passes 118–204 and their verifiers,
`drivers/ctlbytes.sh`, [evidence/byte_controls.tsv](evidence/byte_controls.tsv), `pris.bin` against `fix2.bin`):
**4 databases move**, the implementer's four:
- v11u201 M/m04_task_ctl: `endcol(2)` -> EQUAL;
- r11u195 A/a04: NOT_EQUAL on both;
- r11u204verify DF/e06 and DF/e08: NOT_EQUAL on both, their fillers gaining the root file.

**0 worse.** The six FAIL rows fail identically on both binaries.

## 6. Ranked residues

1. **V1 (FIXED here): § namedUnlinkedWrittenOrder207 on linked calls.** See section 0; now
   § namedOrderLinkedDeclines207v.
2. **V3: a LINKED no-link-branch call that skips a formal takes no slot fill** (ground A, ExprEmit, the
   § classCallNoLink12 branch).
   - Face: B/b09 `h`: `mt(.c(x), .a(0))` against an `extern` prototype above.
     - Golden: `0, INT:0 (no location), x` with vpiFunction.
     - Ours: the § writtenCallArgs16 prefix `0, 1` (the declared default).
   - NOT_EQUAL at the base, and not moved by either binary.
   - The next law: the § namedTfArgsFormalSlots4 slot list whenever `linked207v` holds.
3. **V4: an in-body call to an `extern` or `pure virtual` TASK declared above the caller.**
   - Face: B/b09 `tt`, B/b12 `ta` / `tv`.
     - Golden: `task_call` + `vpiTask` to the prototype.
     - Ours: an unlinked `func_call`.
   - The no-link branch always mints a func_call, and TaskFuncEmit registers only function prototypes in
     `classProtoFn12` (§ externProtoInBodyCallBinds12 SITE 2, `tf->UhdmType() == uhdmfunction`).
   - Ground B (TaskFuncEmit.cpp) for the registration. The kind half is ExprEmit's branch.
4. **V2: § foreachThisArrAtThisToken207 over-reach on `this.<obj>.<arr>`.**
   - The law walks nested scoped names to the root `this`, so it also fires on `foreach (this.obj.arr[i])`.
   - There golden writes a `hier_path` (`obj.arr`) where ours writes a `ref_var`: NOT_EQUAL on both binaries (F/f01).
   - The move is invisible to every gate. It would matter only once the hier_path shape is modelled; a gate of one
     level (`this.<name>`) would be the decode's own shape.
5. **The implementer's residues stand as measured** (its README section 7, ranked there). Checked here at the base:
   - the UVM first records: MiniAmiq #899, SeqDriver #10090 (the N0540 family, ground A, not attempted),
     SimpleUVM #458 / Scoreboard #466 `UVM_MACRO_NUMFLAGS`, BuildUVMPkg #3245;
   - BlackBePipeInt's next records (d #15272, t #66);
   - x01 and x02;
   - InterfArrayBind d's instance-listing clone (ModuleEmit);
   - the cast-width importer copies (p02, p03, and this verifier's G/g03: ModuleEmit importPaCopy82);
   - struct_param_func_config's memberScope names;
   - cfg_func_width_loop;
   - r11u204's N2–N4 and N6;
   - pass 198's R3, R4, R6 and R10.
6. **C/c02 and G/g01: DIVERGENT downstream on both binaries.**
   - c02: named calls with unwritten formals in a continuous assignment of a leaf instantiated three levels deep.
   - g01: a package function with a paren-cast return.
   - Both are pre-existing and are candidates for the downstream-visible face list.

## 7. Files

- `drivers/`:
  - `env.sh`: the pins and the fence (MAIN repo's `FENCED=`, fail closed).
  - `j.sh` + `jall.sh`: judge a case in one view with the pristine and a law binary, with `OFFCHK=1` for the
    `R11U207_OFF` byte check.
  - `tr.sh`: the laws that fired on a case.
  - `calls.py`: each call's link and arguments, per producer.
  - `dscase.py`: the downstream `one()` on cases.
  - `switchcheck.sh`: `CASES=` and `PAIRS=`.
  - `census.sh` + `censum.py`: the firing census.
  - `bvmirror.sh`, `awaycorp.sh` + `away.py`, `uvmdist.sh`, `det.sh` + `detob.sh`, `ctlbytes.sh` + `judge.sh` +
    `case.sh` + `ctlsum.py`: adapted from r11u207repro, with scratch under `/tmp/v11u207_*`.
- `cases/`: A–H as listed in section 3.
- `evidence/`:
  - `grid/grid.tsv`;
  - `switch/`;
  - `downstream/`;
  - `predicted_movers.txt` (frozen) and `predicted_frozen_at.txt`;
  - `byteverify.txt`;
  - `sweeps/`: the summaries, and the corpus and probe mover lists;
  - `away.txt`, `uvmdist.txt`, `determinism/`, `byte_controls.tsv` (+ list), `canaries.txt`.
