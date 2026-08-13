# r10buvm2 — ADVERSARIAL VERIFICATION: **PASS (with 3 documented over-claims, none blocking)**

**VERDICT: PASS.** Every one of the implementer's ~60 load-bearing numbers
reproduced on binaries I built myself, including both md5s bit-for-bit. The
patch is **strictly additive** — I proved it three ways — and I found **no
over-fire anywhere**, in the implementer's 4 arms or in the **5 further arms I
wrote to break it** (`v1_null.sv`, `v2_scope.sv`, `v3_sys.sv` are in this
directory and in the re-cut patch). Three claims in `README.md` are stated more
strongly than the evidence supports (F1–F3 below); all three have **zero corpus
reach** and none of them changes the verdict.

**FIRST LINE.** `BuildUVMPkg`, `SimpleUVM`, `Scoreboard`, `SeqDriver` **DID NOT
CONVERT** — all `CMP_NOTEQUAL` before and after, as expected. Both committed
baselines are **byte-identical whole-ROW**: `results/gate_uhdm2rtlil.csv` 731
rows and `results/golden_surelog.csv` 1588 rows, **0 differing ROWS** each, dump
column included, measured against the patched CSVs I produced.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here.

---

## 0. WHAT I BUILT, AND THE BASE

| | |
|---|---|
| repo HEAD when I started | `dbb1b5a9b369b627faf0bb37cebcef55de246d1e` — **equals the stated BASE**, printed and grep-asserted |
| my patched worktree | `/tmp/wt_vbuvm2` (`git rev-parse HEAD` = `dbb1b5a9…`, grep-checked) |
| my pristine worktree | `/tmp/wt_vbuvm2pris` (same, detached, **no patch**) |
| `git apply --check --verbose` on pristine dbb1b5a | **rc 0**, all 19 files listed, full output read, never truncated |
| patch md5 | `361ba5fa0c4683f919b7106e24fefab0` — **matches** (2179 lines) |
| **PATCHED binary md5** | **`35f7946d01b517ea642d5d63806369ae`** — **bit-for-bit the implementer's** |
| **PRISTINE binary md5** | **`08d4d8f964eb99ecdae33ceed5a855c5`** — **bit-for-bit the implementer's control** |

Both built with `~/.local/bin/cmake --build build -j 2` at absolute paths; I
waited for `[100%] Linking CXX executable slang-uhdm` **and** `[100%] Built
target slang_uhdm` in each log (`grep -c` = 1 each, `error:` count = 0) **before**
taking any md5, and each md5 was asserted against `^[0-9a-f]{32}$` in its own
command. `git stash` never used; `results/*.csv` only ever read; slang not
patched; `GOLDEN_DEFER` echoed `[UNSET]` at every sweep launch; the four
slang-fenced tests never dispatched.

> **ANCHOR CORRECTION — the one number in `README.md` I could NOT reproduce, and
> it is not the implementer's fault.** `README.md` anchors the control twice by
> claiming the MAIN TREE's `build/slang-uhdm` at `HEAD == dbb1b5a` is also
> `08d4d8f9…`. When I measured it, it was **`288e337ff8a9489571ea256059e53a8d`**,
> and the main tree carries an uncommitted `M src/ParamEmit.cpp` (live pass
> r10earl42) with a binary rebuilt at 15:22 — i.e. the anchor was overwritten by
> another pass *after* the implementer took it. **The claim is unfalsifiable now,
> so I replaced it with a stronger one**: I built the base commit myself in my
> own worktree and got `08d4d8f9…`, so the control reproduces from source rather
> than from a shared mutable binary. *Ops lesson: never anchor a control on the
> main tree's build directory — it is a shared mutable object.*

---

## 1. THE FIVE GATES, RE-RUN INDEPENDENTLY

### GATE 1 — BUILD

Both md5s above. **DETERMINISM**: `detcheck.sh <patched> 3 a1_timegrid.sv` →
`distinct hashes=1  NO_OUTPUT runs=0`. (My sha differs from `README.md`'s only
because the arm ran in a different scratch directory, whose path the database
embeds; the pass condition is *1 distinct*, and it is 1.)

### GATE 2 — GOLDENS

| run | PASS | FAIL |
|---|---|---|
| `SLANG_UHDM=/tmp/wt_vbuvm2/build/slang-uhdm` | **23** | **0** |
| `SLANG_UHDM=/bin/false` | **0** | **23** |

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`

```
679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump column: 496 match  183 differ  52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv <fresh>:  0 differing ROWS (0 diff row-sides)
```
The pristine sweep prints the same three status numbers.

### GATE 4 — Surelog corpus, BOTH modes, `--jobs 2`

```
default  : 469 CMP_EQUAL  11 CMP_NOTEQUAL  284 SLANG_REJECT  25 SURELOG_FAIL  5 DEFERRED
testflags: 465 CMP_EQUAL   8 CMP_NOTEQUAL  286 SLANG_REJECT  23 SURELOG_FAIL  5 DEFERRED
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
ct8rows.sh results/golden_surelog.csv <fresh>:  0 differing ROWS (0 diff row-sides)
```
Both STATUS histograms and both DUMP-column histograms identical to the
committed baseline (`default` 225/244/325, `testflags` 165/300/329). The
**pristine** sweep is also 0 differing ROWS, which is what makes gate 5's two
workdirs comparable. Every sweep had its own `--out`/`--workdir`, and each
workdir's `cmds.txt` was re-read and verified to name only the binary that ran
it.

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine build

**Census-predict FIRST**, from the pristine side alone, before the comparison:

| corpus | scanned | SCAN-FAIL | predicted CERTAIN | predicted MAYBE | **movers measured** |
|---|---|---|---|---|---|
| uhdm2rtlil testflags | 679 | 0 | **0** | **0** | **0 / 679** |
| Surelog both modes | 953 | 0 | **2** | **5** | **7 / 953** |

The 7 measured movers are **exactly** the 2 CERTAIN + 5 MAYBE, by name:
`default/BuildUVMPkg`, `testflags/BuildUVMPkg` (CERTAIN, time=1 null=1 sys=1);
`default/SimpleUVM`, `testflags/SimpleUVM`, `default/Scoreboard`,
`default/SeqDriver`, `testflags/SeqDriver` (MAYBE, macro=1).

NEGATIVE CONTROLS: `SELFCHECK=1` flagged **678/679** and **952/953**;
`SELFCHECK1=1` reported **1** and **8** ( = 1 corrupted + 7 real).
`PATH_SETS_IDENTICAL` on both.

---

## 2. MOVERS PER SHAPE — and the ONE gap in `README.md`'s table, now filled

Measured with `msdist.sh` (multiset, alignment-free) on the golden cache vs each
binary's own database, plus `ADDED`/`REMOVED` counted **separately** as raw
`diff` sides of patched-ours against pristine-ours:

| row (default) | golden-only pristine → patched | ours-only | MULTISET DISTANCE | ADDED | REMOVED |
|---|---|---|---|---|---|
| BuildUVMPkg | 53472 → **53452** (−20) | 26453 → **26453** (0) | 79925 → **79905** | **+20** | **0** |
| SimpleUVM | 92920 → **92913** (−7) | 50426 → **50426** (0) | 143346 → **143339** | **+7** | **0** |
| Scoreboard | 83533 → **83526** (−7) | 50169 → **50169** (0) | 133702 → **133695** | **+7** | **0** |
| **SeqDriver** | **264327 → 264320 (−7)** | **101307 → 101307 (0)** | **365634 → 365627** | **+7** | **0** |

**`README.md` left SeqDriver's two distance cells as `—`. I measured them: it is
as clean as the other three.** Dump line counts corroborate independently:
1074367→1074387, 1098206→1098213, 1094836→1094843, 1807488→1807495.

The added text on BuildUVMPkg is exactly 20 lines and I read every one: the
8-line `vpiNullConst` on `uvm_component::m_unsupported_resource_base`
(`class_var`-parented), the 7-line `UINT:9200000000000000` / `vpiConstType:9`
constant on `uvm_root::phase_timeout`, and the 5-line
`sys_func_call ($urandom)` on `uvm_default_coreservice_t::m_uvm_global_seed`.
The other three designs add the identical 7-line `phase_timeout` subtree at
`218:24-218:29`. **Because golden-only fell by exactly the number added and
ours-only did not move at all, every added line provably closed a golden-only
gap** — that is the strongest signature this instrument can give.

Source cells confirmed by hand: `uvm_pkg.sv:38677 time phase_timeout = 9200s;`,
`:38385 uvm_resource_base m_unsupported_resource_base = null;`,
`:9423 local int unsigned m_uvm_global_seed = $urandom;`, and
`uvm_root.svh:218 time phase_timeout = \`UVM_DEFAULT_TIMEOUT;` with
`uvm_global_defines.svh:57 \`define UVM_DEFAULT_TIMEOUT 9200s`. The macro span
law (**macro USE's start column + EXPANDED text's length** → 24-29) is therefore
verified on the real design, not only on arm a4.

### HEADS — measured on both binaries, and the regression reading refuted

| row-mode | PRISTINE (my build) | PATCHED (my build) |
|---|---|---|
| BuildUVMPkg default | **17** — `LHS: constant @38677:23-28 … UINT:9200000000000000 / RHS: <null>` | **1366987** — `LHS:<null>` / `RHS: package uvm_pkg` |
| BuildUVMPkg testflags | **17**, byte-identical | **1366987**, byte-identical to default |
| SimpleUVM default+testflags | 593 (`uvm_objection::new`) | **593, unchanged** |
| Scoreboard default | 593 | **593, unchanged** |
| SeqDriver default+testflags | **1414881 — `LHS:<null>` / `RHS: package uvm_pkg`** | 1414895, same shape |

I read the pristine head text myself: it is the brief's cell verbatim. **The
briefed 17-line head is GONE from both BuildUVMPkg rows.** I also confirmed the
implementer's key defence independently: **`SeqDriver`, which this patch does not
touch structurally, already carried the identical `(null, package uvm_pkg)` head
on the PRISTINE binary.** The new head is a pre-existing wall that
`phase_timeout` was standing in front of, not a wall this patch built. Combined
with distance-down / ours-only-flat / census 3→0, I accept "advanced, not
regressed".

### CENSUS, re-run by me on the patched binary

`propcen.py`, span-keyed, both sides, BuildUVMPkg: **887 distinct class
properties on each side, 112 with `vpiExpr` on each, MISSING = 0, EXTRA = 0,
MISMATCHED = 0** (mismatch compares child kind, child span, `vpiConstType`,
`vpiSize`, and decompile presence). 883 keys are shared; the 4 unshared keys are
the object-KIND family of `README.md` §1.3 and read `EXPR=NONE` on both sides.

---

## 3. THE GRID, CELL FOR CELL — reproduced, then attacked

### Implementer's arms, re-run on MY binaries

| arm | pristine vs golden | patched vs golden | verdict |
|---|---|---|---|
| a1 (24 time cells) | DUMP_DIFF 186 / msdist 186 | DUMP_DIFF **39** / msdist **39** | **21/24 =golden**, reproduced exactly |
| a2 (11 cells) | 87 / 81 | **24** / **18** | reproduced — but see **F1** |
| a3 (over-fire control) | 121 | **121** | **0 differing lines patched vs pristine** — reproduced |
| a4 (macro) | 28 | **0** — `DUMP_MATCH`, `PASS_CMP`, **0 heads** | reproduced exactly |

a1's residues are exactly the three claimed: k09 (`realtime` var/typespec kind,
R5), k16 (`5ns+3ns`, R3), k21 (`real`, R2). All 21 other cells — values, sizes,
masks, decompiles — are **byte-identical**, including the three that decide the
laws: `longint k17` size 64 **with** decompile (so the gate is the typespec kind,
not the width), `shortint`/`byte`/`int` masks (19264 / 64 / 3958308864 —
arithmetic checked in Python), and `7fs → UINT:0`.

### MY arms — written to break the patch, all in this directory

**`v1_null.sv` (18 cells)** — the `= null` and time shapes a1/a2 never generate:
`static` class handle, `static` chandle, **typedef'd** class handle, **typedef'd**
chandle, **typedef'd** virtual interface, a **specialized generic** class handle,
`rand`, `local`, `const`; and `typedef time`, `shortreal`, 1-bit `bit`, 1-bit
`logic`, `0ns`, an **overflowing** `100000000s`, an **odd** 3-bit width,
`$sformatf`, `$clog2`.

* **All 9 `= null` cells are byte-identical to golden, parent included** — the
  `nullInitDefnParented2` split holds on every one, *including* `n04_tdef_ch`
  where golden's variable is a `logic_var` and ours is a `chandle_var`: the gate
  still lands the constant on the CLASS_DEFN, as golden does.
* `typedef time` → `=golden`; 1-bit and 3-bit masks → `=golden`;
  **`100000000s` overflows to `UINT:0` on BOTH sides** — the guard in
  `srlgTimeLitVal` matches Surelog's own double→uint64 collapse.
* `$sformatf("%0d",3)` and `$clog2(8)` → `sys_func_call`, `=golden` on both.
* Only `shortreal` is missing (R2) — **and it produced the pass's most useful new
  fact**, below.

**`v2_scope.sv` (14 cells)** — the SCOPE axis nobody varied: a **NESTED** class, a
class declared in a **MODULE**, a class declared in an **INTERFACE**, and a
**parameterized** class with two specializations. Every cell that exists on our
side is `=golden` (`s01`–`s10`), including the parameter-dependent
`logic [W-1:0] = 5ns` which both sides size at the **default** `W=8`. The two
`work@iniface::` properties are ABSENT from our database — **pre-existing**: the
pristine binary emits no `iniface` class either (`grep -c iniface` = 0 on both).

**`v3_sys.sv` (12 cells)** — the system-call over-fire probe: `$countones`,
`$onehot`, `$ln`, `$pow`, `$signed`, `$unsigned`, `$psprintf`, `$size`, `$high`,
`$isunknown`, `$realtime`, `$stime`. Distance **153 → 10**. **Not one over-fire:
every cell where we now emit a `sys_func_call`, golden emits one too.** Two
sub-field defects surfaced (F1, F2).

---

## 4. NUMBERED FINDINGS

### F1 — `README.md`'s a2 table calls m09 `=golden`; it is not. REAL-typed system-call arguments lose their `vpiParent`.

```sh
cd tools/probe/r10buvm2repro
SLANG_UHDM=<patched> ./ct2arm.sh a2_kindgrid.sv /tmp/x_a2 && sed -n '/\$sqrt/,+12p' /tmp/x_a2/d.diff
SLANG_UHDM=<patched> ./ct2arm.sh v3_sys.sv     /tmp/x_v3 && cat /tmp/x_v3/d.diff
```
Golden hangs `|vpiParent: \_sys_func_call: ($sqrt)` on the REAL argument
constant; ours omits both lines. Reproduced on `$sqrt(4.0)` (a2 m09), `$ln(2.0)`
and **both** arguments of `$pow(2.0,3.0)` (v3 t03/t04). **INTEGER arguments carry
the parent correctly** (`$urandom_range(1,10)`, a2 m05, is byte-identical), so
this is the real-constant path in `emitExpr`, not the new arm. The correct row
for a2 is **9/11 fully `=golden`, not 10/11**. **Reach: 0 corpus tests** —
BuildUVMPkg's only system-call property is the argument-less `$urandom`.

### F2 — `§ classPropSysCallInit2`'s "spanning the WHOLE call" has a counterexample: `$size`.

```sh
grep -n -A3 'sys_func_call: (\$size)' /tmp/x_v3/g.dump /tmp/x_v3/o.dump
```
`int t08 = $size(int);` — golden spans the call **`13:18-13:23`** (the `$size`
token alone); ours spans **`13:18-13:28`** (through the closing paren). The
stated law is therefore not universal. It is again a pre-existing `emitExpr`
span, exposed rather than caused by the new arm. **Reach: 0 corpus tests.**

### F3 — "not one new ours-only line appeared, on any of the 7" is true for the corpus and FALSE on the arms.

```sh
# per-arm ours-only, pristine vs patched
msdist.sh /tmp/x_a1/g.dump /tmp/x_a1/o.dump      # patched
msdist.sh /tmp/pris_a1/g.dump /tmp/pris_a1/o.dump # pristine
```
| arm | ours-only pristine → patched |
|---|---|
| a1 | 5 → **6** |
| v1 | 33 → **36** |
| v2 | 24 → **27** |
| v3 | 0 → **2** |
| a2, a4 | 9 → 9, 0 → 0 |

I identified every new line. On a1 it is **one** semantically real line —
`\_real_var: (p1::c1::k09_rt)` printed as the new constant's parent, because our
`realtime` variable is still a `real_var` (residue **R5**); the rest are
`|vpiParent:` *label* lines whose per-indent multiset count shifts, plus F1/F2's
two `$size` span lines. The corpus claim itself is **correct and I verified it**
(ours-only flat on all four designs); it is the generalisation to "the added text
is byte-for-byte golden's own object" that over-reaches: **on a cell where the
carrier variable's kind still differs, the new object's parent line is ours-only
by construction.** Nothing here is an over-fire; it is R5 becoming visible one
level deeper. **Reach: 0 corpus tests** (no UVM property is a `realtime`).

### F4 — the patch is STRICTLY ADDITIVE, proved three ways (a finding in the patch's favour)

1. **By code**: pristine's `emitClassPropInit29` has no `TimeLiteral` and no
   `NullLiteral` arm — a `time`/`null` property fell through to
   `if (ic.kind != ExpressionKind::Call) return;` and emitted nothing. The one
   replacement (`cn6->VpiParent(cd)` → the conditional) is a **no-op for
   `vifProp6`**, which short-circuits `nullInitDefnParented2` to the old `cd`.
2. **By arm**: patched-ours vs pristine-ours, path-normalised —
   a1 **+149/−0**, a2 **+63/−0**, a4 **+28/−0**, v1 **+143/−0**, v2 **+70/−0**.
3. **By corpus**: BuildUVMPkg **+20/−0**, the other three **+7/−0**.

`REMOVED = 0` everywhere. No object we used to emit was taken away.

### F5 — a PRE-EXISTING segfault I hit while writing v1; **cleared of this patch**

```sh
printf 'interface vifx; logic a; endinterface\npackage pv;\n class cv;\n  virtual vifx n=null;\n endclass\nendpackage\n' > /tmp/m6.sv
<patched>  /tmp/m6.sv -o /tmp/m6.uhdm ; echo $?   # 139
<pristine> /tmp/m6.sv -o /tmp/m6.uhdm ; echo $?   # 139
```
A **virtual-interface class property in a design that instantiates no
interface** segfaults slang-uhdm. It fires **with no initializer at all**
(`vifx_t n05;` alone, no `= null`), and the **pristine dbb1b5a binary segfaults
identically** — so it belongs to `§ virtualIfacePropIsBareLogicVar6`'s family,
not to r10buvm2. Adding a single interface instantiation makes it disappear
(that is why the shipped `a2_kindgrid.sv` has `module m2top; vif2 iv(); endmodule`
and never tripped it). Reported here because it is a **crash**, and no corpus
test writes the shape today.

### F6 — cross-check that CORROBORATES `timeLikeType2`'s two-kind grouping

`README.md` justifies grouping `PredefinedIntegerType::Time` with
`FloatingType::RealTime` from Surelog's `compileTypespec`. An **independent prior
law** in this repo reaches the same pairing from a different direction:
`src/ExprEmit.cpp:1645-1652` (`§ bitsOwnClassPropFold61`) excludes `time`
explicitly and notes *"the two Surelog keeps (`time`, `realtime`) are exactly the
two LRM alias types"*. Two unrelated passes, same partition. This raises my
confidence in the gate well above what a1 alone would justify.

---

## 5. PATCH HYGIENE, BOUNDARIES, AND MY OWN

```sh
grep '^diff --git' /tmp/r10buvm2.patch | grep -vE 'src/EmitHelpers.h|src/UhdmExporter.cpp|tools/probe/r10buvm2repro/' | wc -l   # 0
grep -c 'README.verifier' /tmp/r10buvm2.patch                                                                                 # 0
grep -c "timeLikeType2(\|nullInitDefnParented2(" src/EmitHelpers.h src/UhdmExporter.cpp   # 2 and 2
```
* Production surface is **two files**, 2 predicates + 3 call sites. **STATED GATE
  == CODE GATE**: I read both predicates in `src/EmitHelpers.h` and all three
  call sites in `src/UhdmExporter.cpp`; the code says exactly what `README.md`
  says it says, mask arithmetic included (`w2 >= 64` skips the mask; k24's
  128-bit cell confirms it against golden).
* `README.verifier.md` was **correctly NOT written** by the implementer.
* **BOUNDARIES — all clear.** `§ declInitWrittenNewNoStmt66` (StmtEmit),
  `§ covergroupNewCall7`, `§ bitsOwnClassPropFold61` (ExprEmit) are untouched;
  the syscall arm *defers to* §61 by refusing a folded `$bits`, and §61's own
  `Time` exclusion is byte-unchanged. Live passes: **r10uvm71** owns
  TaskFuncEmit/ModuleEmit and **r10earl42** owns ExprEmit/ParamEmit — **no file
  overlap**; SimpleUVM's and Scoreboard's 593-line `uvm_objection::new` head
  (r10uvm71's cell) is **unchanged**, measured.
* **`§ scopedBuiltinRecvIsChain1` — its arms MUST hold, and they do.** I re-ran
  all nine (`a1_scope a2_pkgspan a3_overfire a4_generic a5_unbound v1_randomize
  v2_bare_rand v3_combo v4_macro`) on both binaries: **identical DUMP_DIFF counts
  and 0 changed ours-lines on every one.**
* **CANARIES**: `canaries.sh` **ok=8 / changed=0 / absent=0** (u2r, 25 unknown =
  surelog-only names) and **ok=52 / 0 / 0** (surelog, 7 unknown = u2r-only);
  `ctcan2.sh` `EXPECT_UNKNOWN=6` (u2r) and `=1` (surelog), both **PASS**,
  baseline-first and mode-matched; `canaudit.sh` **audited=29, UNCOVERED=0,
  FENCE-BREACH=0**. **BY NAME**: `InterfaceModPort` and `BlackParrotComplex`
  `CMP_EQUAL,,,differ` in both modes, rows byte-identical to the baseline.
* **My deliverable**: `/tmp/r10buvm2.verified.patch` — the implementer's patch
  **with the production diff untouched**, plus this file and my three arms
  (`v1_null.sv`, `v2_scope.sv`, `v3_sys.sv`). I re-cut **only** to land the
  verifier record and its evidence; **no production line was changed by me**.
* My sweep workdirs (`/tmp/vb2_wd_*`) and scratch (`/tmp/vb2_*`) are deleted.

---

## 6. RANKED RESIDUES (mine, re-ranked with what I measured)

**R1 — the `(null, package uvm_pkg)` first-failure, now shared by BuildUVMPkg ×2
and SeqDriver ×2.** I confirmed it is **pre-existing on SeqDriver at dbb1b5a**,
so this is a wall, not damage. Reach: 4 row-modes, and it sits behind every
remaining cell in those two designs. The implementer's own span-keyed
`|vpiInstance:` audit (3279 ours / 3267 golden, 106 ours-only / 94 golden-only,
`class_typespec` + `bit_typespec` dominant) is the right start; **key on
span-invariant identity first**, because some of those pairs are one object
separated by another family's span difference.

**R2 — `real` / `shortreal` property with a time-literal initializer, and it is
BIGGER than `README.md` says.** `README.md` frames R2 as "golden sizes it 32 and
we did not decode 32". My `v1` cell `n11_sreal` shows a **second, unstated half**:
golden's `real` constant is parented at the **VARIABLE** (a1 k21) but golden's
`shortreal` constant is parented at the **CLASS_DEFN** (v1 n11) — because
golden's `shortreal` property carries **no typespec at all** while its `real`
property does. That is `§ classPropNullInitParentedByTypespec2`'s own rule firing
on a **non-null** initializer, which means **the law is not about `null`** — it is
a general "no typespec → no re-parent" rule, and the arm should be renamed and
widened when R2 is closed. Cost: `ExprEval::size(real_typespec)` (one read) plus
the parent split I have already measured. Reach: 0 corpus tests today.

**R3 — fold-needing expression init** (`time = 5ns + 3ns`, a1 k16): golden builds
an `operation` over two adjusted constants; needs `adjustSize`'s `sizeMode=true`
operand path. Reach: 0.

**R4 — folded `$bits` property init** (a2 m08): golden sizes at the property's
width. Same `adjustSize` question as R2/R3. Reach: 0.

**R5 — `realtime` is a `time_var` + `time_typespec` in golden, `real_var` +
`real_typespec` in ours** (a1 k09). Now **one line more urgent than
`README.md` ranks it**, because F3 shows it is the sole source of a genuinely new
ours-only line: every constant we now correctly emit on a `realtime` property
prints a parent reference golden does not have. Fix `makeVarForType` and the
line disappears. Reach: 0 corpus tests, 1 arm head.

**R6 — `chandle` properties carry a `chandle_typespec` in ours and none in
golden.** I widened the evidence: it holds for **plain, `static`, `local` and
typedef'd** chandles (v1 n02/n04/n08), and for the typedef'd one golden's
variable is a **`logic_var`**, not a `chandle_var` — so closing R6 means fixing
the *variable factory* too, not only the typespec. Closing it makes
`nullInitDefnParented2`'s chandle clause **derivable** instead of enumerated.

**R7 (mine) — REAL system-call arguments lose `vpiParent`** (F1). One edit in the
real-constant path of `emitExpr`; 3 cells across 2 arms; reach 0 today, but it
will bite the moment any property initializer takes a real argument.

**R8 (mine) — a class declared inside an INTERFACE is not emitted at all**
(v2 `work@iniface`). Pre-existing on both binaries; golden emits the class_defn
and both its properties. Reach: 0 corpus tests today.

**R9 (mine) — the virtual-interface-property SEGFAULT** (F5). Pre-existing,
`§ 6`'s family, crash-severity. Reach: 0 corpus tests, but it is a crash and it
fires with **no initializer at all**.

**R10 — ops.** `` `NUM2 s `` segfaults *Surelog* (the implementer's R7). I did
not re-run it; it is Surelog's, and the cell is not in the shipped arm.

---

## 7. WHAT I TRIED TO BREAK AND COULD NOT

Stated plainly, because a verifier that only lists what it found is half a
verifier:

1. **The `= null` widening is the patch's largest blast radius** — pristine
   emitted a null constant only for virtual-interface properties, patched emits
   one for **every** property that can hold `null`. I attacked it with 9 extra
   cells across `static`/`local`/`const`/`rand`/typedef'd/specialized carriers
   and 3 declaration scopes. **Zero over-fires, zero parent errors.** The corpus
   agrees: 953 databases, 7 movers, and the null arm accounts for exactly one
   8-line subtree that golden also has.
2. **I grepped both corpora for `= null;` declarations** and confirmed the big
   UVM third-party trees that write it in bulk (`Tnoc`, `Ibex`, `AmiqEth`,
   `SplitFile`, `IbexGoogle`) are all `SLANG_REJECT` — which is *why* only one
   corpus cell exists, rather than the arm being lucky.
3. **I looked for an empty product cell in the routing** — a shape that leaves
   `emitClassDefn`'s inline chain but is not handled by `emitClassPropInit29`.
   The only one the patch creates is `real`/`shortreal` + time literal, which
   pristine also dropped, so it is a documented residue (R2) and not a
   regression.
4. **`vpiConstType:9` really is `vpiUIntConst`.** The brief's "(TIME)" gloss is
   wrong and `README.md`'s refutation #1 is correct; `vpiTimeConst` is 8, and
   nothing in any of the 9 arms or 4 designs emits it.
