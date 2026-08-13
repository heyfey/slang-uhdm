# r10uvm70 — VERIFIER NOTES (`§ implicitRetSigningIsIntVar70`)

**LANDING HYGIENE**: this file is r10uvm70's own, written by the ADVERSARIAL
VERIFIER of this pass. It is not carried forward from any earlier pass. Every
number below was measured by me, on two binaries I built myself, in worktrees I
created at the BASE COMMIT.

**VERDICT: PASS.** Every number the implementer reported reproduced exactly —
binaries, grid, five gates, canaries, movers, head, census. The law also holds
on ten cells the implementer's grid does not contain (§V3) and the boundary the
implementer only argued structurally (`§ retLocalPkgRangeBind67`) is byte-
identical when measured (§V4). The findings below are measurement-hygiene and
write-up defects, none of them load-bearing on the patch.

| binary | md5 | what it is | who built it |
|---|---|---|---|
| CONTROL (pristine 19730ce) | `d90af4f662bab7e66f24bfe6258a8f9b` | `/tmp/wt_v70pris`, `-j 2` | me |
| **SHIPPED (patched)** | **`839793c33f4ec8c3d4dcc130fc3e5168`** | `/tmp/wt_v70`, `-j 2` | me |

Both md5s are **bit-for-bit the implementer's**, and the CONTROL is the main
tree's `build/slang-uhdm` at `HEAD == 19730ce` as well — the build is
reproducible three ways. `git rev-parse HEAD` = `19730ce655fe9…` in both
worktrees; `git status --short` clean in the pristine one. `SLANG_UHDM` was
EXPORTED and its md5 echoed at every sweep and every arm (`verify_golden.py`
and `check_goldens.sh` both SILENTLY default it to the main-tree binary).
`GOLDEN_DEFER` was echoed `[UNSET]` at each of the four sweep launches. The four
slang-fenced tests were never dispatched. `results/*.csv` were only ever read.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

---

## V1. WHAT REPRODUCED, NUMBER FOR NUMBER

```bash
git worktree add --detach /tmp/wt_v70 19730ce && cd /tmp/wt_v70 && git apply /tmp/r10uvm70.patch
~/.local/bin/cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ && \
  ~/.local/bin/cmake --build build -j 2     # [100%] Linking / Built target slang_uhdm
md5sum build/slang-uhdm                     # separate command, 32-hex asserted
```

| gate | claimed | measured by me |
|---|---|---|
| 1 BUILD | md5 changed, 32-hex | `d90af4…` → `839793c3…`, link line read first |
| 2 GOLDENS | 23/0, `/bin/false` 0/23 | **23 / 0**, `/bin/false` **0 / 23** |
| 3 u2r testflags | 679/50/2, dump 496/183/52, 0 rows | **identical**, `ct8rows` **0 differing ROWS** |
| 4 surelog both | 469/11 + 465/8 (5 DEFER, 284/286 REJ, 25/23 FAIL) | **identical**, `ct8rows` **0 differing ROWS**, both histograms unchanged |
| 5 BYTE VERIFIER | surelog 7/953, u2r 0/679; SELFCHECK 952/678, SELFCHECK1 8/1 | **identical**, both controls fire on both corpora |
| grid a1 | `EQ=13/DK=3` → `EQ=16/DK=0`, `CMP_FAIL`(54) → `PASS_CMP` | **identical** |
| grid a2 (negative control) | no cell moved, dump-diff 205/205 | **identical** — and stronger, see §V2 |
| grid a3 | `EQ=7/DK=7` → `EQ=12/DK=2` | **identical** |
| grid a4 | `EQ=3/DK=4` → `EQ=7/DK=0` | **identical** |
| head | 54 → 593 on SimpleUVM×2 + Scoreboard/default | **identical**; head object byte-identical across the three rows with ids normalised |
| non-target heads | SeqDriver 1414877→1414881, BuildUVMPkg 58→58 | **identical, and the head OBJECT is unchanged** on both (first 6 lines, ids normalised, `cmp` equal) |
| movers | 7 surelog / 0 u2r, all gain=10 / ADDED 6 / REMOVED 4 | **identical, all seven** |
| sizes | −5 −2 +12 −5 +5 +12 and Scoreboard **0** | **identical, all seven** |
| census | our `int_var`+`logic_typespec`+`signed=1` population == golden's | **identical**, both objects, same spans, same fullnames |
| `b68fence` | arms=6 MOVED=0 | **arms=6 MOVED=0** |
| canaries | surelog ok=52/0, u2r ok=8/0, ctcan2 1 and 6, canaudit UNCOVERED=0 FENCE-BREACH=0 | **identical**; InterfaceModPort + BlackParrotComplex OK BY NAME in both modes |

**One statement worth more than the table: NOT ONE `CMP_EQUAL` DATABASE MOVED A
BYTE, IN EITHER CORPUS.** The only 7 databases that changed are the 4 UVM tests
(×modes), all of which are `CMP_NOTEQUAL` before and after. There is therefore
no room anywhere for a silent regression inside the 183 + 244 + 300 rows whose
dump column reads `differ`.

---

## V2. THE NEGATIVE CONTROL, MADE STRONGER THAN ITS OWN TABLE

`a2_site` is the pass's negative control. Rather than trust the cell tally, I
compared OUR OWN dumps between the two binaries with the workdir normalised out:

```bash
sed "s#/tmp/v70probe/wd_pris_a2_site##g" wd_pris_a2_site/o.dump > p.n
sed "s#/tmp/v70probe/wd_fin_a2_site##g"  wd_fin_a2_site/o.dump  > f.n
diff p.n f.n | grep -cE '^[<>]'     #  -> 0
```

**0 differing lines** — the patch is provably inert on the whole SITE axis
(ports, nets, module variables, formals, body locals, block locals, task
locals), not merely on the rows the grid prints. The same comparison on the
other three arms shows deltas of 36 / 40 / 72 lines, and **every one of those
lines is the law's own population**: `logic_var` → `int_var` plus
`|vpiSigned:1`, on return variables only, nothing else.

---

## V3. THE LAW HOLDS ON TEN CELLS THE IMPLEMENTER'S GRID DOES NOT CONTAIN

`v5_gaps.sv` (this directory, the verifier's own arm) puts the head's spelling
at sites the four arms never reach. Golden and ours **agree on every one after
the patch** (`cells=10 EQ=10 DIFFER=0 DIFFERKIND=0 UNMEASURED=0`):

| cell | written | golden and ours (FINAL) |
|---|---|---|
| 6 | `virtual function unsigned` (non-pure class method) | `int_var` `signed=1` `logic_ts` |
| 10 | `function automatic unsigned` | same |
| 15 | `function signed` (class, direction sibling) | same |
| 23 | `function unsigned` in an **INTERFACE** | same |
| 30 | `function unsigned [3:0][1:0]` (**multi-dim** packed) | same |
| 34 | `function unsigned f(input int a)` (with formals) | same |
| 38 | `function signed [31:0] f(...)` (the pre-existing cell) | same |
| 43 | `function unsigned` inside a **GENERATE** block | same |
| 48 | `function unsigned` whose name is read in its own body | same (both the return var and the drainFuncRet local) |
| 54 | `function unsigned` in a **PROGRAM** | same |

A second block closes the explicit-base × direction gap the a1 grid leaves
(a1 has `logic unsigned [3:0]` but no `logic signed [3:0]`, and no `bit signed`,
`reg unsigned`, `byte signed`, `integer unsigned`): **all five agree, all five
are untouched by the patch.** So the arm's `ImplicitType` fence is measured in
both directions on every base type the corpus can spell, not just the five
controls a1 happens to carry.

`function static signed f;` inside a class is **SLANG_REJECT** ("class methods
cannot have static lifetime") and is out of campaign scope; it is recorded in
the arm as a comment rather than dropped silently.

---

## V4. THE BOUNDARIES — ONE RE-MEASURED, ONE MEASURED FOR THE FIRST TIME

* **`§ atomVarSignedWritten68`** — `b68fence.sh` on my two binaries:
  `arms=6 MOVED=0`, all six a1–a6 databases byte-identical. The structural
  reason holds on inspection: `clearNamedAtomSigned68` returns immediately
  unless `declared.kind == TypeAlias`, and this population is reached by no
  name. Grid cell a4 `12:27` (`pv_u`) proves the two predicates coexist at the
  same site: 68 runs AFTER the factory and does not clear the new flag.
* **`§ retLocalPkgRangeBind67`** — the implementer argued this one from the
  source ("different field, no shared state") and did not measure it. **I
  measured it**: both of `r10uvm67repro`'s arms through both binaries,
  workdir-normalised, `a1_pkgparamts` **0** differing lines (7157-line dump) and
  `a2_rangeref` **0** (3796-line dump).
* **`makeReturnVar`'s eleven other call sites** carry the 1-argument form, so
  the element-reg factories are inert by construction:
  `grep -rn "makeReturnVar(" src/` → 15 lines, 4 of which pass the predicate
  (TaskFuncEmit 2421 / 2958 / 3027, ModuleEmit 20628) and 11 of which do not.
  **STATED GATE == CODE GATE.**
* **Live passes.** `git apply --check` of BOTH live passes' current diffs on top
  of this patch: `r10sd3` **co-applies CLEAN**, `r10earl41` **co-applies CLEAN**
  (see finding F4 for what the implementer's collision paragraph gets wrong).

---

## V5. TWO CHECKS THE IMPLEMENTER DID NOT RUN

### V5.1 The mover set is COMPLETE, mechanically

A mover list is only as good as its denominator. `vpiFullName`s are stored as
plain text in the database, so the population is greppable:

```bash
cd /tmp/v70wd_pris_sl && find . -name slang.uhdm -print0 | xargs -0 grep -la get_recorders
```

returns **exactly the seven databases that moved** — `default/{SimpleUVM,
Scoreboard, SeqDriver, BuildUVMPkg}` and `testflags/{SimpleUVM, SeqDriver,
BuildUVMPkg}`. No database contains the shape without moving; no database moved
without containing it. Combined with the source census (`grep -rn` over
`uvm-1.2/src` returns exactly the two declarations, and `uvm-1.1d` **none**),
the mover set is closed at both ends.

### V5.2 Scoreboard's zero size-delta — the instrument, not just the object

The implementer's correction to the campaign shorthand is right, and its
foundation needed one more measurement. `detcheck.sh`, 3 reps, both binaries:
SimpleUVM/default **1 distinct hash** each side (bytes 11118646 / 11118641),
Scoreboard/default **3 distinct hashes** each side, bytes **stable and equal at
11122938**. So Scoreboard's byte inequality is not by itself evidence.

The authority is then the per-shape analysis — **but that instrument had never
been shown to be noise-immune on a nondeterministic test.** It is:

```bash
# two pristine runs of Scoreboard, same binary
diff sbdet1.dump sbdet2.dump | grep -cE '^[<>]'   -> 92      (LCS sees order noise)
./msdist.sh sbdet1.dump sbdet2.dump               -> 0       (the MULTISET does not)
```

The dump-line **multiset** is deterministic even though the bytes and the dump
ORDER are not, which is exactly the property `mv70.sh` relies on. And the
per-shape result is reproducible across independent pristine runs: `mv70.sh`
against **two different** pristine Scoreboard databases gives the identical
`gain=10  ADDED=6  REMOVED=4`, naming the same two objects. Scoreboard's mover
is REAL.

### V5.3 The new head is PRE-EXISTING, not minted by this patch

`54 → 593` is head depth, and the new head (`LHS:<null>` vs our
`function (uvm_pkg::uvm_objection::new)` task_func vector entry) is a divergence
the old head was masking. Proof without a second dump: the patched-vs-pristine
delta on that database is **exactly 10 lines**, all of them `int_var` /
`logic_var` / `|vpiSigned:1` on the two law objects (`mv70.sh` ADDED=6
REMOVED=4). An object present in one database and not the other would appear in
that delta. `uvm_objection::new` does not, so both binaries mint it.

---

## V6. FINDINGS

**F1 — MEASUREMENT HYGIENE (medium). `a2_site`'s grid silently drops 12 of its
24 declared sites, including the two axes §2.4 names first.**
`ct70cells.py` filters to `*_var` kinds; ANSI ports and subroutine formals are
`io_decl` objects and the two `wire signed/unsigned` are nets, so lines 5–10,
18–19 and 22–25 produce **no row on either side** — they are invisible to the
tally, not reported as `UNMEASURED`. The README's §2.4 nevertheless describes
the arm as "Module ports, module-scope variables, subroutine formals, body
locals and block locals". The CONCLUSION survives (§V2 proves inertness on the
whole file, and the a2 golden carries 92 `io_decl`/net objects to our 79 — a
pre-existing divergence, identical on both binaries), but the cited instrument
cannot see the sites the citation claims. This is the campaign's own named trap
("a cited guard that does not cover what the citation claims").
Command: `grep -cE '\\_(io_decl|logic_net):' wd_fin_a2_site/{g,o}.dump` → 92 / 79.

**F2 — WRITE-UP CONTRADICTION (low).** `README.verifier.md` (the implementer's
version, replaced by this file) item 4 says `mv70.sh` is "carried forward
unchanged in substance … differ from their ancestors only in the `/tmp` prefix",
while `README.md` §6.5.3 documents a real instrument defect fixed in `mv70.sh`
(shape counts printed as distinct delta entries instead of instances). Both
statements are in the same deliverable.

**F3 — OVERCLAIM (low).** The same file says the 7 movers were "each proved real
by SIZE-DELTA", which `README.md` §6.5.2 explicitly refutes for
Scoreboard/default (size delta **0**, and the pass's own correction is that a
zero delta proves nothing). Kept honest in §V5.2 above.

**F4 — COLLISION PARAGRAPH INACCURATE (low).** "`r10earl41` is in
`TypeEmit`/`ExprEmit`, which this patch does not touch at all" — `r10earl41`
ALSO edits `src/EmitHelpers.h` (its hunk at ~1383), a file this patch edits at
~2075 / ~2120 / ~2238; and `r10sd3`'s diff is not confined to
`ParamEmit`/`TaskFuncEmit`: it edits `src/ModuleEmit.cpp` at ~20872, inside the
same `drainFuncRet` this patch touches at ~20628. **No textual conflict** —
both live diffs `git apply --check` CLEAN on top of this patch — but the
paragraph understates the shared surface, and the next pass to read it would
mis-scope its own collision check.
Command: `cd /tmp/wt_r10earl41 && git diff 19730ce -- src/EmitHelpers.h | grep ^@@`.

**F5 — RESIDUE PROMOTED (low/medium). The DPI-import site moves one cell AWAY
from golden's shape.** For `import "DPI-C" function unsigned dpi_u();` golden
emits **no Return variable at all**; we emit one, and this patch changes it from
`logic_var` to `int_var` + `vpiSigned:1`. The implementer disclosed this as R5
before it was found, and both corpora have **zero** population, so it moves no
byte — but "all four factories state the same predicate" is a consistency
argument, not a measured one, and site 2 could equally have been left ungated.
Accepted as a ranked residue, not a blocker (a4 cell `18:27`).

**F6 — TALLY QUOTED SHORT (low).** The README quotes `cells=17 EQ=13
DIFFERKIND=3` for a1 (and the corresponding lines for a3/a4) while the tool also
prints `UNMEASURED=1` (a3: 2, a4: 3). Those cells ARE disclosed in prose as
R3/R4/R5/R6/R7, so nothing is hidden, but the pasted tally line is not the
tool's whole line.

**F7 — CENSUS COUNT (trivial).** "five non-UVM files" is six paths: `Yosys` and
`YosysTestSuite` each carry a copy of `code_verilog_tutorial_v2k_reg.v`. Both
are `SLANG_REJECT` at the test level; nothing follows from it.

---

## V7. RESIDUES, RANKED (the implementer's, re-measured, plus mine)

| # | residue | status after my measurement |
|---|---|---|
| **R1** | module-scope `var signed x;` — we stamp `vpiSigned:1`, golden does not | CONFIRMED, `DIFFER` before and after (a2 `14:18`); untouched, `makeVar` territory, no UVM population |
| **R2** | class PROPERTY `var unsigned/signed` — golden `int_var` + **`int_typespec`** + no flag | CONFIRMED, the 2 remaining `DIFFERKIND` cells of a3; needs the typespec, which the brief fences |
| **R3** | `extern function unsigned f();` prototype return var carries the BODY's span | CONFIRMED (a3 `49:21` golden-only) |
| **R4** | `var <implicit+signing>` sub/block/task LOCAL — golden emits NO object, we do | CONFIRMED (5 ours-only cells in a2, 1 in a3) |
| **R5** | DPI-import implicit-signing return — see F5 | CONFIRMED, and slightly worse-shaped after the patch |
| **R6** | fully-implicit pure-virtual return var spanless in golden, spanned in ours | CONFIRMED (a4 `@` vs `14:36`) |
| **R7** | `function int signed f;` span | **SHARPENED**: it is not "ours spans `int`" — ours emits a SECOND object at the base-token-only span (`52:12-52:15` beside the agreeing `52:12-52:22`), and the same shape appears for `function byte signed` (`70:12-70:16` beside `70:12-70:23`) in `v5_gaps.sv`. The rule is ATOM base + written signing, not `int` specifically |
| **R8** | the new head: our `function (uvm_pkg::uvm_objection::new)` task_func vector entry | CONFIRMED and shown PRE-EXISTING (§V5.3) — the honest next head for all three rows |
| **R9** | *(verifier)* the grid instrument cannot see `io_decl`/net sites at all — see F1 | a `KIND=` axis (or an `io_decl` row) would close it; the golden/ours `io_decl` count already differs 92/79 on a2 |

---

## V8. WHAT A LATER PASS SHOULD RE-RUN FIRST

1. `./ct70arm.sh v5_gaps.sv <wd>` + `KEY=sp NAMERE='^(p5::|work@(m5|if5|pr5|m6))'
   python3 ct70cells.py <wd>/g.dump <wd>/o.dump` — the widest statement of the
   law (16 cells, every site and every base type).
2. The workdir-normalised OURS-vs-OURS dump diff per arm (§V2). It is a
   stronger negative control than any cell tally and costs one `sed`.
3. `b68fence.sh` and the two `r10uvm67repro` arms (§V4) — both boundaries.
4. `find … -print0 | xargs -0 grep -la <fullname>` over a pristine sweep
   workdir before believing any mover count (§V5.1).
5. `msdist.sh` between two runs of the SAME binary on a nondeterministic test
   before quoting a per-shape delta on it (§V5.2).

---

## V9. POST-VERIFICATION: THE BASE MOVED WHILE I WAS MEASURING

The main tree advanced from `19730ce` to **`ba7d1ef`** (`r10sd3` /
`§ retNameLocalInstIsHomeNotClass3`) during this verification. Everything above
was measured against the brief's BASE, `19730ce`. Because BOTH passes touch
`drainFuncRet`'s return-name local — sd3 sets its `vpiInstance` at
`ModuleEmit.cpp` ~20872, this pass sets its CLASS at ~20628 — I re-checked the
combination rather than assuming it:

```bash
git worktree add --detach /tmp/wt_v70head ba7d1ef && cd /tmp/wt_v70head
git apply /tmp/r10uvm70.verified.patch     # CLEAN
cmake --build build -j 2                   # md5 c932a66fcafdab8b3f3931adb1657f0c
```

* **GOLDENS 23 / 0** on the combined tree.
* **arm a1 `PASS_CMP`, 0 heads**; arm a4 `29` cmp lines / `120` dump-diff
  content — identical to the `19730ce` + patch measurement.
* **SimpleUVM/default head = 593 lines on the same
  `function (uvm_pkg::uvm_objection::new)` object**: the 54-line
  `get_recorders` head is cleared on the new base too (database size differs,
  11118551, because sd3's own change is in it).

The law survives the rebase. A full five-gate re-run on `ba7d1ef` is still the
landing gate — this is a smoke test, not a substitute for it.
