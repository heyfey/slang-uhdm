# v11u310 — adversarial verification of r11u310 (pass 310, expression/parameter ground)

Verdict: **PASS, no production refinement.** The implementer's patch (src/ExprEmit.cpp, thirteen laws read through
src/LawSwitch.h as `lawOn(310, "R11U310_<X>_OFF")`, `R11U310_OFF` for all, `lawTrace(310, ...)` under
`R11U310_TRACE`) is carried byte-identical. Every headline number reproduced bit for bit, and 224 fresh case dirs
(448 case-views) found no case on legal SV where pristine was right and the law wrong. No `src/R*.h`, no
src/LawState.h section, no getenv in the added lines.

## Binaries (built by this verifier, frozen chmod 555 before any measurement)

- Worktrees /tmp/wt_v11u310pris (pristine) and /tmp/wt_v11u310 (implementer's patch applied cleanly) at 50288747,
  built with `-j 2`, system deps against ~/.local.
- pristine `ce9fa46ba3afcd1ff2a7dbff0a690e9b`: equal to the main tree's build at the base and to the implementer's.
- law `13561334707cdac7bce3d7f66b3b8481`: equal to the implementer's law binary.
- Both report slang 12.0.0+545f88b2e. uhdm-strictcmp `fa6e4f42…`, strictcmp_x `886f0302…` (drivers/cc_x.sh), both
  equal to the implementer's.

## Gates (both sweeps from /tmp/wt_v11u310 with SLANG_UHDM exported; workdirs /tmp/v11u310_swP and /tmp/v11u310_swL)

| stage | pristine | law |
|---|---|---|
| probe | 4017 EQUAL + 70 STRICT_NOTEQUAL, 0/0/0 | 4017 + 70, 0/0/0 |
| surelog | default 480 + 0, testflags 474 + 0, 0/0/0 | the same |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | the same |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same |

- Regressions, conversions and changes are all 0 against the committed baselines.
- Both sweeps exit 1 on the law-index check alone; the index is regenerated in this patch.
- **The first pristine sweep was discarded.** It ran while the law binary was compiling, and Earlgrey_0_1
  testflags read TIMEOUT (machine load, a pristine binary). It was rerun on a quiet machine to the table above.
- **csv row diff, pristine vs law (workdir path normalised): 0 lines** in probe, surelog, uhdm2rtlil and downstream.
  Both downstream csvs are byte-identical to results/downstream_uhdm2rtlil.csv.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered mirrors from drivers/mirror.sh):
  - Path sets are identical: 3365 paths, 0 movers. A cmp loop over the 4087 probe databases also finds 0 movers.
  - SELFCHECK reads 3363 of 3365. The reference (the first sorted path, downstream/1DUnpackedArray/slang.uhdm) is
    byte-identical to uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm. That is the same test with the same
    arguments, so those two files are the unflagged pair, and every other file is flagged.
- **Firing census** (drivers/tracecensus.sh): the law binary under R11U310_TRACE through the harness, over the probe
  cases and both corpora in both modes, with the four fenced tests excluded by the filter.
  - It wrote no line (evidence/predict.txt is empty), which matches the 0 byte movers.
  - Its own csvs read probe 4017 + 70.
  - Positive control: R11U306_TRACE and R11U310_TRACE through scripts/check_probe.py on
    r10uvm79repro/c2_idxkind wrote the pass 306 BARESEL / NESTSHAPE / NESTSHAPE_LEAFSEL lines.
- **Canaries** on both sweeps: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both
  (EXPECT_UNKNOWN=1 and 6).
- **Binary-path audit** (drivers/audit.sh): pristine own 3265 / other 0, law own 3265 / other 0 (50 noslang, 8
  fenced row-modes skipped by name).
- **Determinism** (drivers/det.sh): three concurrent draws of the law binary give one hash per row-mode on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each hash equals both sweeps'
  database (Scoreboard and Rggen testflags write no database, as at the base). See evidence/determinism.txt.
- uhdm-cmp: no row moved in bytes, so every touched row stays at 0 lines.
- After tests/LAWS.md was regenerated, `tests/sweep.sh --corpus probe` on the law binary exits 0 (4017 + 70, 0/0/0).

## The implementer's measurements, reproduced

- **Grid:** 406 case-views × 3 labels over tools/probe/r11u310repro/cases (evidence/impl_grid_repro.txt).
  - 1218 of 1218 lines are equal to the implementer's grid.txt in every field but md5 (the database embeds its
    absolute path).
  - 294 movers, 244 entering STRICT_EQUAL, 0 leaving. `R11U310_OFF` equals pristine on 406 of 406, with 0 exit-code
    changes and 13 uhdm-cmp line changes (the same 13).
- **Attribution** (evidence/impl_grid_attrib_repro.txt) equals the implementer's grid_attrib.txt line for line:
  METHTAIL 72, CLSLVTRAIL 62, LVNESTIDX 50, QUALCALLSPAN 20, CASTLVIDX 16, CASTSELIDX 10, METHIDXCALL 8,
  METHPATHSPAN 8, CALLTERNTRUE 4, METHIDXTEXT 2, METHNESTSEL 2, and 40 needing two or more.
- **Away census:** chain away 0 and flat away 0 on all 294, with 627 records toward golden. Equal to the
  implementer's grid_away.txt.
- **Standard byte controls** (drivers/controls.sh over the same 21 repro dirs, 3976 case-views):
  - The summary is identical to the implementer's: 24 moving, 16 entering STRICT_EQUAL, 0 leaving, 0 exit-code
    changes, 4 uhdm-cmp line changes.
  - Chain away 0 on all 24, with 144 records toward golden.
  - r11u296repro CI/ci05 d grows from 156 to 1432 uhdm-cmp lines at stage 1 on both binaries. Pristine's head (the
    hier_path `fl[[k]].rub` decompile in package h) is gone. uhdm-cmp now reports at the package level, printing
    the whole package. Chain away 0, 36 records toward golden.
- **Firing scans** (drivers/firescan.sh, law binary, over every fence-filtered dut.sv dir under tools/probe and
  tests/probe, 31761 / 31779 dirs including this directory's cases): 327 dirs fire in the default view and 342 in
  the elaborated view; none is under tests/probe.
  - Outside r11u310repro, this directory and the standard controls, the firing dirs are exactly the implementer's
    14 trigger dirs.
  - Trigger controls (28 case-views): 22 moving, 13 entering STRICT_EQUAL, 0 leaving, 0 uhdm-cmp changes. This
    summary is identical to the implementer's. Chain away 0 on all 22, with 30 records toward golden.
- **Crashes:** the firing scans saw 1 exit 139 in the default view and 8 in the elaborated view. The implementer's
  9 crash dirs (m07_hdr_enum_default d/e, v8_recurse, v8_recurse_mutual, v8_recurse_uncond, F/f04_class,
  RS/s22_recursion, F/vf02_iface, F/vf04_hier e) exit 139 on pristine and law alike.

## The attack: 224 fresh case dirs, both views (cases/, drivers/gen.py)

Each case's first line names its law. The class template carries item/holder/grid classes; the module template
carries packed-struct arrays with clk, i, j and c ports (downstream-runnable).

- **VM (69):** the method-call receiver (METHTAIL, METHIDXTEXT, METHRECVCUM, METHIDXCALL, METHIDXSEL,
  METHNESTSEL). Shapes covered:
  - built-in methods: string `len`, queue `size`/`push_back`/`reverse`/`sum`, enum `name`, `randomize`,
    `randomize() with`, a `find_first_index` with-clause and a with-clause reading a receiver;
  - receiver forms: deep `.nx.nx`, two-member and member-select indices, 2-D receivers, a range-select index,
    `this.` on the receiver and in the index;
  - index contents: a cast, unary, concat, `$clog2`, a ternary true or false branch, a call argument, nested calls
    with path arguments, the receiver as a call argument;
  - statement contexts: void statement, `if`, `while`, `case`, `$display`, `fork/join_none`, foreach, a
    string-keyed associative array;
  - macros: a macro index, a macro call, an include-file macro;
  - scopes: a package class, a parameterized class, an extern method, `super.`, a virtual-interface member index,
    module/interface/generate bodies with class handles;
  - receiver chains whose earlier elements carry selects (`harr[i].arr[midx[j]]`, `harr[midx[i]].arr[j]`,
    `h.hh.arr[fn(i)]`, `harr[fn(i)].hh.arr[hd.k]`).
- **VL (37):** the lvalue nested middle index (LVNESTIDX).
  - Middle indices: nonblocking, op, call, select, path, cast, ternary and unary indices; `++`/`--`/`+=`; a
    concatenation target; two nested paths; `this.` bases.
  - Module contexts: always_ff, always_comb, task, for-generate and if-generate, depth 3, an implicit net, an
    interface body.
- **VC (30):** casts (CASTSELIDX, CASTLVIDX): byte/int/unsigned/signed/size/typedef/enum casts; nested, leading and
  trailing selects; inc/dec, compound and nonblocking writes, concatenation targets, package-call arguments;
  module, generate and interface-function contexts.
- **VT (37):** class lvalue trailing index (CLSLVTRAIL). Index sources: locals, formals, package and class
  parameters, a global variable, foreach variables, `this.` and member paths, nested selects, ternaries, `$clog2`,
  static calls and method calls. Targets: 2-D targets, logic-vector bits, an indexed part select. Scopes: nested,
  extern, package, derived and parameterized classes, a task, an interface function. A module-task control.
- **VQ (51):** qualified calls and the true-branch rule (QUALCALLSPAN, CALLTERNTRUE, METHPATHSPAN).
  - Ternary positions: true, false and condition positions, nested ternaries (a call in the false branch or the
    condition of a conditional sitting in an outer true branch), an operation inside the true branch.
  - Qualified-call contexts: inside a cast, a system call, a concatenation and a nested select; the qualified call
    as a receiver index and under inc/dec and nonblocking writes; a class-scope call, a macro-born qualifier,
    blanks, a wildcard-import control.
  - Module contexts: always_comb, always_ff, assign, for-generate.

Results (evidence/grid.txt, grid_summary.txt, grid_away.txt, grid_attrib.txt):

| group | case-views | moving | entering STRICT_EQUAL | leaving | STRICT_EQUAL after |
|---|---|---|---|---|---|
| VC | 60 | 28 | 26 | 0 | 53 |
| VL | 74 | 58 | 37 | 0 | 64 |
| VM | 138 | 110 | 97 | 0 | 115 |
| VQ | 102 | 58 | 54 | 0 | 85 |
| VT | 74 | 46 | 38 | 0 | 58 |
| total | 448 | 300 | 252 | 0 | 375 |

- **Fallout:** 0 exit-code changes, and `R11U310_OFF` equals pristine on 448 of 448 case-views.
- **uhdm-cmp line changes (20 case-views):** none grows.
  - 16 go from stage 1 to 0 lines: vc26, vm42, vm43, vm59, vq30, vm82, vm83 and vm84 in both views.
  - 4 shrink by 2 at stage 1 on both binaries: vm47_extern and vm48_super, both views.
- **Away census:** chain away 0 and flat away 0 on all 300 movers, with 677 records toward golden.
  - 27 movers carry no record toward golden. 20 of them are VL views (19 elaborated plus vl07 d). There the law re-parents the middle index at
    its select as golden does, and the strict walk does not key on parents (vl07_pathidx d checked against
    golden's dump: the `hd.k` index now hangs at `arr` as in golden).
  - The rest are stage-1 views on both binaries (vm47, vm48, vt25), plus vt27 below.
- **Attribution:** every mover is restored by a single switch or a set of this pass's switches (METHTAIL 78,
  LVNESTIDX 58, CLSLVTRAIL 48, QUALCALLSPAN 30, CALLTERNTRUE 22, CASTLVIDX 16, CASTSELIDX 6, METHIDXCALL 4,
  METHIDXTEXT 4, METHPATHSPAN 4, and 30 needing two or three).
- **Downstream** (drivers/dscases.py, both lanes, the 31 module- and interface-scope dirs): 19 IDENTICAL on both
  binaries; 8 EQUIVALENT → IDENTICAL (vq13, vq14, vq18, vq23, vq38, vq39, vq49, vq50: the call span the plugin
  reads); 4 EQUIVALENT on both (vl35, vc30, vt40, vq51); none worse.

**No break found.** No case on legal SV moved away from golden, left STRICT_EQUAL, changed its exit code or worsened
downstream, so no refinement was written.

## Residues (all wrong on pristine too; none moved away)

1. **CLSLVTRAIL's reach.**
   - The law looks only at a hier_path that is an assignment's own Lhs. A concatenation target
     `{h.idx[i + 1], r} = 2` (VT/vt36, VC/vc22) and a method path as the trailing index `h.idx[iarr[i].get()] = r`
     (VT/vt37) keep `work@grid::probe::i`, where golden has `...::h.idx[i + 1]::idx::i` / `...::h.idx[]::idx::i`.
   - A MODULE task `task t(); h.idx[i + 1] = r;` (VT/vt18) keeps `work@top.t.i`, where golden has
     `work@top.t.h.idx[i + 1].idx.i` (the class gate and § lvSelIdxChainName181's process drain both miss it).
   - This ground (ExprEmit); the next law.
2. **A `this.` path in a class lvalue trailing index** (`h.idx[this.i + 1] = r`, VT/vt27).
   - Golden stores no full name on the path's `i`; pristine stores `work@grid::probe::i`; CLSLVTRAIL's path branch
     stores `...::h.idx[ + 1]::idx::i`.
   - It moves from one wrong value to another, with 0 records either way. The endcol head (golden's hier_path
     `this.i` ends at 17, ours at 15) stands first.
   - A refinement could let the path branch abstain on a `this` base. It is not a strict break, so it is not
     written here.
3. **With-clause receivers** (VM/vm72 `harr[h.k].q.find_first_index(x) with (...)`).
   - Golden puts `h` on the `k` token (col 34), the nested shape. METHTAIL stands aside for every with-clause
     receiver (`!withExpr9`), although here a member follows the select.
   - Not this pass's fault: pristine has the same col.
4. The implementer's residues 1 and 4 are confirmed on fresh shapes:
   - VQ/vq25 d, vq26 d and vq28 d: the inner method path's index reference is named through the inner path
     (`...::iarr[ + 1].f::iarr[i].get::i`, golden `...::iarr[ + 1].f::i`).
   - VQ/vq38 (`assign r = sa[p::f(i)].f`): the call argument's ref_typespec is `work@top.i`, golden
     `work@top.sa[].f.i`.
   - The lvalue and trailing method-path spans: vq27, vq29.
5. **A definition-view generate statement's call in a ternary true branch** (VQ/vq51
   `for (genvar g...) always_comb sa[c ? fn(i) : g].k = j;`): golden spans `fn(i)` (8:64-69), ours the name
   (8:64-66), on both binaries.
   - Most likely the sister's TypeEmit emitSyntaxExpr called from ModuleEmit emitDefGenStmts (the face passes 306
     and 308 named). Not backtraced here: report only.
6. **Stage 1 on both binaries:**
   - 2-D receivers (vm19), `this.` index and receiver (vm23, vl32, vl37);
   - module, interface and generate class-handle bodies (vm51, vm54, vm55);
   - extern (vm47, vt25), `super.` (vm48, vt39);
   - `randomize() with` (vm74), a typedef cast (vc08), a package-parameter control (vq16), a class-scope call
     (vq17), a macro-born qualifier (vq19), a generate cast (vc28);
   - interface functions (vc30, vt40), interface always_ff (vl35), a concatenation lvalue (vl09).
7. The implementer's other residues stand as listed in tools/probe/r11u310repro/README.md.

## Sister-ground faces

Only vq51's generate-definition call span above (most likely TypeEmit emitSyntaxExpr from ModuleEmit
emitDefGenStmts, not backtraced).

## Process

- **THE FENCE:**
  - Every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line (drivers/env.sh).
  - Every path list is built and filtered before a file is opened. byteverify ran on fence-filtered mirrors, and
    the census filter excludes the four names.
  - The fence scan of this directory reads 0 files for each name.
- **Isolation:** no other agent's process was listed or touched, and nothing was written outside the two worktrees,
  /tmp/v11u310_* and the session scratchpad.
- **SLIPS, no effect:**
  - The first draft of the fresh class template declared `int dq[4][$]`, which slang-uhdm rejects
    (exit 4 on every class case). It also declared an unpacked struct member `s_t.idx` whose own typespec face
    headed every class case, plus one illegal with-clause case and two package-class cases reaching $unit items.
    All were fixed and regenerated before any counted measurement; only the final grid above counts.
  - The first pristine gate sweep ran concurrently with the law build and read an Earlgrey_0_1 testflags TIMEOUT.
    It was discarded and rerun.
- Drivers: copied from tools/probe/r11u310repro/drivers with scratch paths renamed to /tmp/v11u310_*. gridall.sh
  gained `GRIDC` (another cases root) and `GRIDP` (parallelism). gen.py is new.
- No patch file in this directory; /tmp/r11u310.verified.patch is transport only.
