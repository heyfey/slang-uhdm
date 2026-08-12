# r10uvm57 — VERIFIER'S REPORT. **VERDICT: PARTIAL.**

Gate 5 is **closed and reproduced independently**: 7 movers on surelog, 0 on
uhdm2rtlil, **0 REMOVED lines on all 7**, both byte-verifier controls firing.
Both headline claims re-measured and **CONFIRMED** from my own runs. The pass's
two arm tables hold up on nine new product cells I built.

**But the pass ships ONE OVER-FIRE, and it is in the corpus, not just in an
arm.** § blockLocalSameCtrlDepthArgBinds57 binds a block-local reference in
**EXPRESSION position** whenever the callee is a class method that is not yet in
`subMap` — the § classCallNoLink12 branch (`src/ExprEmit.cpp` ~8773) opens a
`ClassArgBind12` window with **no** § classInBodyBareCallArgStmtOnly53
statement-position gate. Golden leaves those bare. Measured on
`uvm_pkg::uvm_reg_map::clone_and_update` in the 1800.2-2017-1.0 UVM:
**4 over-fired `vpiActual` edges** (2 sites × BuildUVMPkg default+testflags) out
of **345 new bindings**, and a **second, latent instance of the same defect** in
the `super.<m>()` arm (~7955), which no corpus row exercises yet.

The pass's own claim that *"the EXPRESSION-position and receiver-qualified cells
stay bare"* (`src/ExprEmit.cpp:5727`, and README.md §3.2's b4 paragraph) is
**FALSE for two of the five call kinds.** None of the pass's gates could see it:
the row status, the dump column, the cmp head, `mv57.sh` and `cov57.sh` are all
green on the rows that carry it.

---

## 0. WHAT I VERIFIED, AND WITH WHICH BINARY

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp`, called as `uhdm-cmp <golden.uhdm>
<ours.uhdm>` in every command below.

I built **both** commits myself, in my own worktrees, and verified the base of
each binary **by grep on that worktree's own source** before building anything:

```
$ git show 7c7eaa6:src/ExprEmit.cpp | grep -c blockLocalSameCtrlDepthArgBinds57   -> 0
$ git show 5f528bb:src/ExprEmit.cpp | grep -c blockLocalSameCtrlDepthArgBinds57   -> 2
$ git -C .claude/worktrees/v57pris rev-parse HEAD  -> 7c7eaa6facc5647e6a7e720a154c2ab9d6187115
$ grep -c blockLocalSameCtrlDepthArgBinds57 .claude/worktrees/v57pris/src/ExprEmit.cpp -> 0
$ git -C .claude/worktrees/v57test rev-parse HEAD  -> 5f528bbe37703c4927507372e804e3f7703a9637
$ grep -c blockLocalSameCtrlDepthArgBinds57 .claude/worktrees/v57test/src/ExprEmit.cpp -> 2
```

Both worktrees `git status --porcelain` **empty** — no patch was applied by me;
the code under test is what is committed. `git stash` was never used.
`results/*.csv` were **read only**. Slang-fenced tests (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) were never dispatched or measured.
`GOLDEN_DEFER` left at default (5 DEFERRED in both surelog modes).

| binary | worktree | md5 | link line |
|---|---|---|---|
| CONTROL (pristine `7c7eaa6`) | `.claude/worktrees/v57pris` | `71bd294b421e23a4feb7807f8c5b7a8f` | `[100%] Linking CXX executable slang-uhdm` **present** |
| UNDER TEST (`5f528bb`) | `.claude/worktrees/v57test` | `b40329b21fb425f8a6efcd2d7d43f195` | `[100%] Linking CXX executable slang-uhdm` **present** |

md5s asserted in a **separate** command from the build; both are 32 hex
characters. **The under-test md5 is byte-identical to the implementer's shipped
FINAL and to the main tree's `build/slang-uhdm`**, and the pristine md5 is
byte-identical to the implementer's control — so `7c7eaa6` and `3500bc4` compile
to the same binary (`7c7eaa6` touched only `tools/probe/.../msdist.sh`), and this
is a **third independent reproduction** of both binaries. Sweeps ran at
`--jobs 2` with my own `--out` and `--workdir`.

---

## 1. GATE 5 — THE BYTE VERIFIER, INDEPENDENTLY (the gap the master could not close)

`tools/probe/r10oth6repro/byteverify.sh <under-test-wd> <pristine-wd>`, both
corpora, `SELFCHECK=1 SELFCHECK1=1`:

| corpus | paths | MOVERS | SELFCHECK (all-vs-one) | SELFCHECK1 (one corrupted) |
|---|---|---|---|---|
| uhdm2rtlil (testflags) | 679 = 679, `PATH_SETS_IDENTICAL` | **0** | 678 / 679 flagged | **1** |
| surelog (`--mode both`) | 953 = 953, `PATH_SETS_IDENTICAL` | **7** | 952 / 953 flagged | **8** = 7 real + 1 corrupted |

Both controls fire on both corpora, so **0 movers on u2r is a measurement, not a
silence**. The 7 movers are exactly the rows the implementer named:
`default/{SimpleUVM,Scoreboard,SeqDriver,BuildUVMPkg}` and
`testflags/{SimpleUVM,SeqDriver,BuildUVMPkg}`.

### 1.1 ADDED versus REMOVED, counted SEPARATELY, by my own instrument

`vmov.sh` (written from scratch for this verify; strips indentation **before**
counting and accumulates with `+=`, the `msdist.sh` bug §7 of the pass report
describes):

| row | dump lines pris → patched | **REMOVED** | **ADDED** | verdict |
|---|---|---|---|---|
| default/SimpleUVM | 1100381 → 1100471 | **0** | 90 | PURE ADDITION |
| default/Scoreboard | 1096969 → 1097059 | **0** | 90 | PURE ADDITION |
| default/SeqDriver | 1808892 → 1808982 | **0** | 90 | PURE ADDITION |
| default/BuildUVMPkg | 1076280 → 1076410 | **0** | 130 | PURE ADDITION |
| testflags/SimpleUVM | 1100441 → 1100531 | **0** | 90 | PURE ADDITION |
| testflags/SeqDriver | 1808952 → 1809042 | **0** | 90 | PURE ADDITION |
| testflags/BuildUVMPkg | 1076280 → 1076410 | **0** | 130 | PURE ADDITION |

**The "PURE ADDITION" half of the implementer's claim is CONFIRMED on all seven
rows by an independent instrument.** `vcov.py`, keyed on (line, field), also
reports **0 REMOVED (line,field) instances** on every row, and every one of the
355 added instances hangs off **`vpiActual` and nothing else**
(`added instances by FIELD: {'vpiActual': 45}` ×5, `{'vpiActual': 65}` ×2).

The *arms* agree: `diff -u <pristine ours.dump> <patched ours.dump> | grep -c '^-'`
is **0** on both v1 and v2.

### 1.2 …but "every added line covered by golden" DOES NOT HOLD as stated

Three different criteria exist and the pass's headline states one while its
instrument checks another:

* **(A) what `cov57.sh` actually checks** (`cov57.sh:65`,
  `if (($2 in g) && g[$2] >= $1)`) — golden's **total** multiplicity of a shape
  ≥ the **added delta**. This never looks at our total at all.
* **(B) what README.md §0 claims** — *"100 % of the added line instances exist in
  GOLDEN **with at least that multiplicity**"*, i.e. our total ≤ golden's total.
* **(C) the only criterion that can judge a BINDING law** — per (line, **field**),
  our total ≤ golden's total, so an added `vpiActual` edge is judged against
  golden's `vpiActual` edges rather than against a header line four fields share.

Under (B), **5 of the 7 movers fail** (`vmov.sh`): e.g. SimpleUVM
`ours=30 golden=24 \_array_var: (…do_unpack::__array), line:3657:11`. Under (C)
that particular excess **clears**, exactly as README §5.1 argues — I re-derived
its table myself with `vfield.py` and it is right: for `do_unpack::__array` the
`vpiActual` field goes ours 4 → **6** = golden's 6, and the surplus is the
**pre-existing** 6 `vpiLhs` occurrences (golden 0) this pass never touched.

**But under (C), BuildUVMPkg still fails, on a shape the pass report never
mentions** — and that is finding #1.

---

## 2. FINDINGS, MOST SEVERE FIRST

### FINDING 1 (SEVERE, corpus, shipped) — the law OVER-FIRES in EXPRESSION position when the callee is not yet emitted

```
$ python3 vcov.py bp_g.dump bp_pris.dump bp_test.dump
ADDED (line,field) instances   : 65  over 54 keys
REMOVED (line,field) instances : 0  over 0 keys
ADDED instances FAILING criterion (C): 4  over 2 keys
  OVER-FIRE  ours=2 golden=1  [vpiActual] \_class_var: (uvm_pkg::uvm_reg_map::clone_and_update::rg), line:75320:13, endln:75320:15
  OVER-FIRE  ours=2 golden=1  [vpiActual] \_class_var: (uvm_pkg::uvm_reg_map::clone_and_update::rg), line:75325:13, endln:75325:15
```

and the per-REFERENCE audit (`vaudit.py` — one cell per `ref_obj`/`ref_var`,
`vpiActual` read at OWN CHILD DEPTH, keyed on name+span+field+parent-kind, which
is the only instrument in this directory that asks *"is the reference we newly
bound bound in GOLDEN"* rather than *"is the added line one golden has"*):

```
$ python3 vaudit.py bp_g.dump bp_pris.dump bp_test.dump     # default/BuildUVMPkg
cells whose binding CHANGED pristine->patched : 66
  of which NEWLY BOUND (more B than before)   : 65
  NEWLY BOUND and MATCHING GOLDEN             : 63
  NEWLY BOUND but GOLDEN DISAGREES (OVER-FIRE): 2
    OVER-FIRE golden=b pris=b patched=B [vpiArgument under func_call] uvm_pkg::uvm_reg_map::clone_and_update::rg line:75321:46
    OVER-FIRE golden=b pris=b patched=B [vpiArgument under func_call] uvm_pkg::uvm_reg_map::clone_and_update::rg line:75326:46
```

**THE CORPUS SOURCE**, `third_party/UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv`
75319-75322 (`uvm_reg_map::clone_and_update`):

```systemverilog
foreach (m_regs_by_offset[i]) begin              // unnamed block, ctrlBodyDepth28 = 1
   uvm_reg rg = m_regs_by_offset[i];             // 75320  BLOCK LOCAL
   uvm_reg_map_info info = get_reg_map_info(rg); // 75321:46  EXPRESSION position
   m.add_reg(rg, info.offset, rights, …);        // 75322:15  STATEMENT position
end
```

| cell | position | golden | pristine | UNDER TEST |
|---|---|---|---|---|
| `get_reg_map_info(rg)` 75321:46 | EXPRESSION (decl-assign RHS) | **bare** | bare | **BOUND — OVER-FIRE** |
| `m.add_reg(rg, …)` 75322:15 | STATEMENT (receiver-qualified) | BOUND | bare | BOUND — correct fix |

Read straight out of the two dumps: golden's `\_func_call: (get_reg_map_info)`
argument carries only `|vpiName:rg |vpiFullName:…`, while ours now adds
`|vpiActual: \_class_var: (…clone_and_update::rg), line:75320:13`.

**MECHANISM, checked against the code rather than asserted.**
`classArgBindDepth12` is raised at five places. **Exactly one of them applies
§ classInBodyBareCallArgStmtOnly53's statement-position gate:**

| site | what it is | gate on the window |
|---|---|---|
| `ExprEmit.cpp:9189` | resolved call | `ClassArgBindIf38(…, callStmtCtx0 \|\| !(curSubClassScope9 && !curSubOob9))` — **gated** |
| `ExprEmit.cpp:8773` | § classCallNoLink12 — class method **not yet in `subMap`** | `ClassArgBind12 cab12(classArgBindDepth12);` — **UNGATED** |
| `ExprEmit.cpp:7955` | § superMethodCall17 — `super.<m>(…)` | **UNGATED**, and it sets `callStmtContext = false` first |
| `ExprEmit.cpp:8533` | receiver-qualified `method_func_call` | ungated, but § classInBodyRecvCallArgNoBind52 covers it |
| `ExprEmit.cpp:9933` | § builtinMethodArgBinds28 | ungated; the expression-position twin at 10128 raises `RecvCallArg52` |

`get_reg_map_info` is `extern virtual` (declared 75115, **defined out-of-body at
76030, below the caller**), so at emission it is not in `subMap` and the call
takes the 8773 branch. The pass-57 carve-out then clears
§ controlBodyNoBind28 there, and nothing else withholds the actual.

**THE ARM: `v3_exprsib.sv`, built and measured on BOTH binaries.** D1 writes the
corpus shape with the callee declared **above** (resolved → gated path) and D8
writes it with the callee declared **below** (unresolved → 8773). D1 is the
control that shows why b4 never saw this; D8 is the defect.

| cell | line | shape | golden | pristine | UNDER TEST |
|---|---|---|---|---|---|
| D1a | 55:24 | `info = getinfo(rg)` callee ABOVE | b | b | b — correct |
| D1b | 56:15 | `useit(rg);` STATEMENT | **B** | b | **B** — correct fix |
| **D8a** | **135:20** | `i8 = late8(r8)` callee BELOW | **b** | b | **B — OVERBIND** |
| D8b | 136:16 | `late8v(r8);` STATEMENT, callee BELOW | **B** | b | **B** — correct fix |
| **D8c** | **137:25** | `d8 = i8 + late8(r8)` OPERAND | **b** | b | **B — OVERBIND** |
| **D8d** | **138:26** | `d8 = late8(late8(r8))` NESTED | **b** | b | **B — OVERBIND** |

`cells.py` differing count: pristine **3** / 70 → under test **3** / 70. *The
count did not improve: the law traded one underbind for three overbinds in this
arm.* Reproduce:

```
bash arm.sh v3_exprsib.sv /tmp/x_pris .claude/worktrees/v57pris/build/slang-uhdm
bash arm.sh v3_exprsib.sv /tmp/x_test .claude/worktrees/v57test/build/slang-uhdm
python3 cells.py /tmp/x_test/g.dump /tmp/x_test/o.dump | grep -E 'd8|DIFFERING'
```

**CORPUS REACH, PRICED EMPIRICALLY — it moved bytes, so this is a mover count
and not a syntactic site count.** Complete per-cell audit of all 7 movers:

| row | newly bound cells | matching golden | **REAL OVER-FIRES** |
|---|---|---|---|
| default/SimpleUVM | 43 | 43 | **0** |
| default/Scoreboard | 43 | 43 | **0** |
| default/SeqDriver | 43 | 43 | **0** |
| testflags/SimpleUVM | 43 | 43 | **0** |
| testflags/SeqDriver | 43 | 43 | **0** |
| default/BuildUVMPkg | 65 | 63 | **2** |
| testflags/BuildUVMPkg | 65 | 63 | **2** |
| **total** | **345** | **341** | **4** |

So: **4 wrong `vpiActual` edges against 341 right ones, on 2 source sites, both
in `uvm_reg_map::clone_and_update`, in one test in two modes.** 0 on uhdm2rtlil.
It is **not cmp-visible** — BuildUVMPkg's head is 58 lines and **byte-identical**
control-to-under-test (`diff` of the two `uhdm-cmp` outputs is empty), and the
row is `CMP_NOTEQUAL` before and after. **Every shipped gate is green on the rows
that carry it.**

*(The audit's other flag, `golden=ABSENT … __m_uvm_field_automation::max__
line:270:35`, is a **FALSE POSITIVE of my own span key** and I checked it rather
than counting it: golden carries the same reference under the same
`method_func_call: (print_array_header)` parent with the same
`|vpiActual: \_int_var (…max__), line:259:15`, at span **270:44** where ours says
270:35 — a pre-existing 9-column shift in macro-expanded code, present in the
pristine dump too. The binding is correct; only the span disagrees. Ranked R4.)*

### FINDING 2 (SEVERE, latent, zero corpus reach today) — the same defect in the `super.<m>()` window

`ExprEmit.cpp` ~7955 (§ superMethodCall17) opens `ClassArgBind12` unconditionally
and raises no `RecvCallArg52`, so **nothing** withholds the window from an
expression-position `super.` call. Arm **`v4_superexpr.sv`**:

| cell | line | shape | golden | pristine | UNDER TEST |
|---|---|---|---|---|---|
| S1a | 44:18 | `super.bv(r1);` STATEMENT | **B** | b | **B** — correct fix |
| **S1b** | **45:23** | `i1 = super.bm(r1);` | **b** | b | **B — OVERBIND** |
| **S1c** | **46:28** | `e1 = i1 + super.bm(r1)` | **b** | b | **B — OVERBIND** |
| **S1d** | **53:25** | `return super.bm(r1d);` | **b** | b | **B — OVERBIND** |
| S2a | 65:17 | `this.iv(r2);` STATEMENT | **B** | b | **B** — correct fix |
| S2b | 66:22 | `i2 = this.im(r2);` | b | b | b — correct (§52 holds) |
| S3a | 76:14 | `o.bv(r3);` STATEMENT | **B** | b | **B** — correct fix |
| S3b | 77:19 | `i3 = o.bm(r3);` | b | b | b — correct (§52 holds) |
| S4a-c | 87-89 | method-body-local twins | b | b | b — correct |

Differing cells **7 → 7**: three underbinds fixed, three overbinds created. No
corpus row exercises it (0 super-expression over-fires among the 345 audited
cells), so **its price today is 0 bytes** — but it is the same missing gate, in a
second window, and it will fire the moment a UVM row writes
`x = super.f(blocklocal)` inside a control body. **This is exactly the shape
`v4` exists to stop the next pass from shipping.**

### FINDING 3 (MODERATE, instrument) — `cov57.sh` cannot establish the claim made for it

`cov57.sh:65` compares golden's total against the **added delta**, so it reads
`NOT COVERED=0` on rows where our total ends up **above** golden's, and it read
green on both BuildUVMPkg rows that carry finding #1. Its SELFCHECK still fires
(it injects a shape golden has **zero** of, which any of the three criteria
catches), so the self-check does not exercise the weakness. README.md §0's
*"with at least that multiplicity"* describes criterion (B), which the script
does not implement — and even (B) is too weak for a binding law, because one
header line is shared by `vpiActual` / `vpiLhs` / `vpiParent` / `vpiVariables`
(§5.1's own point). `vcov.py` and `vaudit.py` in this directory implement (C) and
the per-reference test; **the per-reference test is the one that found #1.**

### FINDING 4 (MINOR, instrument labelling) — two different multiset conventions are both called "the multiset distance"

README §4.1 quotes *"MULTISET distance, correctly computed (§7): 140957 →
140871 (−86)"*. I reproduce those numbers **exactly** — but only with
indentation **STRIPPED**:

```
indent-STRIPPED  PRISTINE  golden-only=90638 ours-only=50319  MULTISET DISTANCE=140957
indent-STRIPPED  PATCHED   golden-only=90550 ours-only=50321  MULTISET DISTANCE=140871
indent-KEPT      PRISTINE  golden-only=93269 ours-only=52950  MULTISET DISTANCE=146219
indent-KEPT      PATCHED   golden-only=93218 ours-only=52989  MULTISET DISTANCE=146207
```

`§7`'s **fix to `msdist.sh` KEEPS indentation on purpose** ("uhdm-dump encodes an
object's DEPTH as leading spaces"), so the fixed `msdist.sh` reports
**146219 → 146207 (−12)**, not −86. Both numbers are right about different
things; neither should be quoted without saying which convention it uses.
(§5.1's "golden-only fell 88, ours-only rose by 2" is the stripped convention and
is exact: 90638→90550, 50319→50321.)

### FINDING 5 (MINOR, arm hygiene — refines b4/b5's CP0332 note) — the real gate is NON-STATIC + DEPTH 0, not "derived class"

b4's header blames CP0332 on a class that **extends** another; b5 tripped it and
its cells were left standing on a golden produced under an error. The actual
discriminator, measured on four minimal probes:

| probe | shape | Surelog `[ERR/FTL]` |
|---|---|---|
| t1 | NON-static method, unqualified pkg call at **depth 0**, non-derived, shadowed name | **1** (`CP0332`) |
| t2 | same, no shadowing | **1** (`CP0332`) |
| t3 | **STATIC** method, same depth-0 call | **0** |
| t4 | NON-static, the call only **inside the if body** | **0** |

So a depth-0 unqualified package call in a **non-static** method is the trap, in
a non-derived class too, and shadowing is irrelevant. Every method in `v1`..`v3`
is `static` for this reason — which is also the corpus shape
(`uvm_object_registry::create` **is** a static function) and b1's own `f`. A
second one found the same way: **`$display` written inside a CLASS method** makes
Surelog report `CP0333 "Undefined system task/function $display"` under
`-nobuiltin`, where the same call in a package function is clean; `v4` therefore
writes a member instead.

---

## 3. THE TWO HEADLINE CLAIMS, RE-MEASURED

### 3.1 The head cleared and advanced — **CONFIRMED**, quoted from my own runs

`uhdm-cmp <golden> <ours>`; `grep -c '^LHS:'` at column 0:

| row | pristine | UNDER TEST |
|---|---|---|
| default/SimpleUVM | 29 lines, 1 head | **54 lines, 1 head** |
| testflags/SimpleUVM | 29 lines, 1 head | **54 lines, 1 head** |
| default/Scoreboard | 29 lines, 1 head | **54 lines, 1 head** |
| default/SeqDriver | 85 lines, 1 head | 85, head **byte-identical** |
| default/BuildUVMPkg | 58 lines, 1 head | 58, head **byte-identical** |

The pristine head is the brief's, verbatim, ending `RHS: <null>`. The new head,
my own `uhdm-cmp` output, matches the implementer's quotation **id for id**:

```
LHS:
ref_var: (uvm_pkg::uvm_set_get_dap_base::get), id:173208, line:71:26, endln:71:27
|vpiParent: \_function: (…::get), id:173207, line:71:4, endln:71:16
|vpiTypespec: \_ref_typespec … |vpiActual: \_int_typespec: , id:173185, line:80:45, endln:80:46
RHS:
int_var: (uvm_pkg::uvm_set_get_dap_base::get), id:105718, line:71:26, endln:71:27
|vpiParent: \_function: (…::get), id:105717, line:71:4, endln:71:34
|vpiTypespec: \_ref_typespec … |vpiActual: \_int_typespec: , id:105719, line:71:26, endln:71:27
|vpiSigned:1
```

cmp line count is a **HEAD-DEPTH** measure; the alignment-sensitive `diff -u`
content figure is 238561 → 238343 raw, i.e. **238559 → 238341 (−218)** once
diff's own two header lines come off — the implementer's figure exactly.

### 3.2 The brief's diagnosis was wrong — **CONFIRMED, with one correction to how it is stated**

Span-keyed `grep -Fxc`, indentation stripped, on the target line
`\_string_var: (uvm_pkg::uvm_object_registry::create::msg), line:260:14, endln:260:17`:

```
golden 3    pristine (control) 2    under test 3
```

**The master's brief to me says "grep -Fxc gives golden 3 / ours 3". That is true
of the UNDER-TEST binary only; on the CONTROL it is 3 / 2.** The pass report
states it correctly ("golden 3 — ours 2 → 3"). The distinction matters, because
the refutation lives in *which* of the three occurrences was missing —
`vfield.py`, splitting by the edge each occurrence hangs off:

| field | golden | pristine | under test |
|---|---|---|---|
| `vpiVariables` (the block's declaration listing) | 1 | **1** | 1 |
| `vpiParent` (of its `ref_typespec`) | 1 | **1** | 1 |
| `vpiActual` (of the 265:34 argument reference) | 1 | **0** | **1** |

**The declaration was there all along** — the brief's "ADD the object (and its
typespec chain) to the block's variable listing" would have emitted a second
`string_var` into a listing that already had it. The one missing occurrence was
the **`vpiActual` edge** of the `msg` argument at 265:34, and the three
`ref_obj`/`ref_var` references to `msg` (261:7 Lhs, 265:34 argument, the
`ref_typespec`) are 1/1/1 on all three sides. **REFUTATION CONFIRMED.**

---

## 4. THE EMPTY SQUARES I BUILT — THE AXIS GRID, AND WHAT EACH PRODUCT SAID

Axes: block named/unnamed × declaring scope × depth relationship × **call kind**
(user-package / system / sibling-method / receiver-method / `super.` / built-in) ×
symbol kind × **statement-vs-expression position** × enclosing construct. The
a1..b5 set covers the diagonal; these are the products it skips.

### 4.1 `v1_prodcell.sv` — nine product cells at ctrlBodyDepth28 1 == 1

`cells.py` differing cells: pristine **17** / 81 → under test **2** / 81.

| cell | shape | golden | pristine | UNDER TEST |
|---|---|---|---|---|
| W1a/W1b | `sink(str8(b1v))`, `sink(str8(str8(b1v)))` — nested call, **STATEMENT** outer | B | b | **B** fixed |
| W1c | `sink(str8(mb))` method-body local (neg) | b | b | b |
| W1d | `$display(str8(b1v))` — **SYSTEM outer** call (neg) | b | b | b |
| W2a/W2b | `sinki(b2i + 1)`, `sinki(b2i + mbi)` — **OPERATION** operand | B | b | **B** fixed |
| W3a/W3b | `sink({b2s, "x"})`, `sink({b2s, b2s})` — **CONCAT** operand | b | b | b (ClassArgBindOff12 holds) |
| W4a-c | `sinki(b4a[0])`, `sinki(b4s.f)`, `sinki(b4a[b4s.f])` — select/member | b/b | b/b | b/b |
| W5a/W5b | `mq.push_back(b5i)`, `b5q.push_back(b5i)` — **BUILT-IN method arg** | B | b | **B** fixed |
| W5c | `mq.push_back(obj)` formal (neg) | b | b | b |
| W6a-c | `sinko/sinkio/sinkr(b6s)` — **output / inout / ref** formal | B | b | **B** fixed |
| W6d | `sinko(mb6)` body local (neg) | b | b | b |
| W7a | `do begin … sink(b7d); end while` — **DO-WHILE** body | B | b | **B** fixed |
| W7b | `forever begin … sink(b7f); end` — **FOREVER** body | B | b | **B** fixed |
| W8b | block local **SHADOWING** a method-body local of the same name | B | b | **B** fixed |
| W8a/W8c | the method-body `shdw` at depth 0 / at depth 1 | B / b | B / b | B / b |

**Every new binding matches golden and no negative control moved.** The two
residual cells are ONE pre-existing naming pair, identical on both binaries:
golden `pv1::shp::w4::b4a::f` vs our `pv1::shp::w4.b4a::f` — a **`.` where golden
writes `::`** in the `hier_path` fullname of a member select on a block-local
struct inside a class method. Ranked R3. (Note W1d and the audit's 4-5 correct
new `vpiArgument under sys_func_call` bindings per row together refine the law's
comment: a **top-level** system call never enters the window, but a system call
**nested inside a user call's argument list** inherits the open window, and
golden agrees.)

### 4.2 `v2_loopvar.sv` — symbol kind and enclosing construct

`cells.py` differing cells: pristine **2** / 69 → under test **0** / 69.

| cell | shape | golden | pristine | UNDER TEST |
|---|---|---|---|---|
| X1a/X1b/X1c | `for (int i=0;…) sinki(i);` — the **for's implicit loop variable**, in an `if`, bare-body, and at depth 0 | **b** | b | **b** — no over-fire |
| X2a/X2b | `foreach (a2[j]) sinki(j);` — **foreach index variable** | **b** | b | **b** — no over-fire |
| X3a | a **for-BODY** block local read in the body | **B** | b | **B** fixed |
| X3b | the loop variable `m` at the same site | **b** | b | **b** |
| X4a-f | module function / module task / `initial` / `always_comb` | B | B | B unchanged |
| X5 | package function twin | B | B | B unchanged |

**X3a next to X3b is the sharp cell**: at one site, golden binds the for-body
block local and leaves the for's loop variable bare, and the law gets both right.
The implicit `for (int i …)` wrapper block **is** an unnamed
`StatementBlockSymbol` holding a `Variable`, so `blkLocalSameCtrlDepth57`'s first
three tests all pass on a loop variable — it is the depth test alone that saves
it (the wrapper is entered at *d*, the body runs at *d+1*). That is a
**one-condition-deep** save on a shape no arm cell covered; it is now covered.

Module and package scope cannot fire (`ctrlBodyNoBind28` needs
`curSubClassScope9 && !curSubOob9`) and are measured, not assumed: X4/X5 cells are
identical on both binaries.

### 4.3 Two candidates from the brief that I did **not** build, and why

* **"a block local in one FORK arm read from a DIFFERENT arm"** — not legal
  SystemVerilog: an arm's `begin`-block declarations are not visible in a sibling
  arm, so there is no such reference to bind. b4's e9 already measures the
  reachable half (an arm's own local and the enclosing if-body local, both bound
  in golden, both correct here).
* **`obj.m(blkloc)` / `super.m(blkloc)` in STATEMENT position** — already covered
  by b4 (58:14, 135:18) and re-confirmed here as v4 S1a/S3a. The **expression**
  products are finding #2.

---

## 5. THE OTHER GATES, ON MY OWN BINARIES

| gate | pristine | UNDER TEST |
|---|---|---|
| GOLDENS `tests/check_goldens.sh` | — | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **23 FAIL** |
| u2r testflags | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL; dump 496/183/52 | identical |
| surelog default | 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED; dump match 225 | identical |
| surelog testflags | 463 / 10 / 5 DEFERRED; dump match 165 | identical |
| `ct8rows.sh` vs **committed** `results/gate_uhdm2rtlil.csv` | 0 differing ROWS | **0 differing ROWS** |
| `ct8rows.sh` vs **committed** `results/golden_surelog.csv` | 0 differing ROWS | **0 differing ROWS** |
| `ct8rows.sh` pristine CSV vs under-test CSV, both corpora | — | **0 differing ROWS** |

The pristine sweep matching the committed baselines row for row is what makes the
0-differing-rows reading on the under-test sweep meaningful rather than a
coincidence of two equally stale files. Canaries and `canaudit` were run by the
master on this exact md5 and are not repeated.

---

## 6. VERDICT

**PARTIAL.**

* Gate 5 is **closed**: 7 movers / 0 movers, both controls firing, **0 REMOVED
  lines on all seven rows**, 355 added instances all on `vpiActual`, and 341 of
  345 newly bound references match golden. The pass's "pure addition" claim is
  independently **CONFIRMED**.
* Both headline claims are **CONFIRMED** from my own runs, with one correction to
  how the second is stated (the control's count is 2, not 3).
* Nine new product cells (nested call in statement position, operation operands,
  concat operands, selects, built-in-method arguments, output/inout/ref formals,
  do-while, forever, shadowing, loop variables, module and package twins) all
  agree with golden — **the law's decoding is sound where it was decoded.**
* **It ships one over-fire in the corpus (4 edges, 2 sites, BuildUVMPkg ×2 modes)
  and one latent instance of the same defect**, both from the same root cause:
  two of the five `ClassArgBind12` windows are opened without
  § classInBodyBareCallArgStmtOnly53's statement-position gate, so the carve-out
  does **not** in fact inherit that gate as `ExprEmit.cpp:5727` claims.
* No gate the pass ran could have seen it: the head, the row status, the dump
  column and both mover instruments are green on the rows that carry it.

---

## 7. RANKED RESIDUE

**R1 — FIX FINDING 1 AND 2 TOGETHER: gate the carve-out on statement position
rather than trusting §53 to have done it.** The narrow fix is to make
`blkLocalArgBind57` require the window to have been opened in statement position,
which needs one member (an "ungated window" depth, or a statement-position flag
recorded when `ClassArgBind12` is pushed) — **not** a change to the windows
themselves at 7955/8773, because those also govern formals and body locals and
widening or narrowing them would move cells this pass never measured. Arms
already exist and are decisive: `v3_exprsib.sv` D8a/c/d and `v4_superexpr.sv`
S1b/c/d must go to **bare** while D1b, D8b, S1a, S2a, S3a stay **bound**, and the
BuildUVMPkg mover must lose exactly 4 `vpiActual` edges and keep the other 126
added lines. Verify with `vaudit.py`, which is the only instrument here that
sees it.

**R2 — the new head: the return variable of `pure virtual function T get()` in a
parameterised class** (`uvm_set_get_dap_base.svh:71`). Golden `ref_var` with its
`int_typespec` at the **specialisation** site (80:45); ours `int_var` +
`vpiSigned:1` + own-span typespec; the `function`'s `endln` is the prototype's
`:16` in golden and `:34` for us. Blocks SimpleUVM (both modes) and Scoreboard,
and is very likely a family (every `pure virtual` returning a type parameter).
Confirmed as the head by my own `uhdm-cmp` run.

**R3 — `hier_path` fullname of a member select on a BLOCK-LOCAL struct inside a
class method uses `.` where golden uses `::`.** `v1_prodcell` W4b: golden
`pv1::shp::w4::b4a::f`, ours `pv1::shp::w4.b4a::f`. The only differing cell left
in v1, unchanged by this pass, one arm cell away from a fix. Same family as the
pass report's R6 (`pb4::shp::e2::o.bm2::r2`).

**R4 — a 9-column span shift on references inside macro-expanded
`__m_uvm_field_automation` bodies.** `…max__` is at 270:44 in golden and 270:35
in ours (its sibling constant 270:51 vs 270:42), on every one of the 5
SimpleUVM/Scoreboard/SeqDriver movers, in the pristine dump too. It makes a
correct new binding look like an over-fire under any span-keyed audit, so it
costs verifier time on every pass until it is fixed; likely the
`getFullyOriginalLoc` mapping the MEMORY note describes.

**R5 — pre-existing `vpiLhs` on a block-local dynamic-array decl assignment.**
Ours takes the `array_var` as the assignment's Lhs where golden takes a
`ref_obj`; 6 occurrences on `uvm_tlm_generic_payload::do_unpack::__array` alone.
It is the sole reason criterion (B) fails on 5 of the 7 movers, i.e. it is a
standing generator of false over-fire alarms. Re-confirmed with `vfield.py`.

**R6 — `cov57.sh`'s criterion should be replaced, not just documented** (finding
3), and `msdist.sh`'s two conventions should be named at every quotation
(finding 4). `vcov.py` and `vaudit.py` here are the replacements; `vaudit.py`
found the only real defect in the pass.

**R7 — arm-hygiene, now characterised** (finding 5): `CP0332` needs
NON-STATIC + depth-0 unqualified package call (not "derived class"), and
`CP0333` fires for `$display` written inside a class method under `-nobuiltin`.
b5's depth-0 receiver cells still stand on a golden produced under CP0332 and
should be re-measured before any law leans on them.

---

## 8. THE INSTRUMENTS I ADDED

| file | what it is |
|---|---|
| `v1_prodcell.sv` | nine product cells: nested call in statement position, operation/concat operands, element+member selects, built-in method args, output/inout/ref formals, do-while, forever, shadowing |
| `v2_loopvar.sv` | `for`-inline-decl and `foreach` implicit loop variables; module function/task/`initial`/`always_comb` and package twins |
| `v3_exprsib.sv` | **the over-fire arm** — sibling-method call in expression position, callee ABOVE (D1, control) vs BELOW (D8, defect) |
| `v4_superexpr.sv` | `super.` / `this.` / receiver calls in statement **and** expression position — finding 2 |
| `vmov.sh` | ADDED vs REMOVED as separate numbers, + golden coverage, golden resolved from the row's own `cmds.txt`; `SELFCHECK=1` deletes a line, `SELFCHECK2=1` injects one golden cannot have |
| `vcov.py` | coverage per **(line, field)** — criterion (C); shows what `cov57.sh`'s criterion misses |
| `vfield.py` | per-FIELD census of one shape across golden / pristine / patched — mechanises README §5.1 |
| `vaudit.py` | **the per-REFERENCE audit**: every cell whose binding changed, against golden's own state. The instrument that found finding 1 |

All four arms build clean goldens (`surelog ERR/FTL = 0`) on both binaries; the
`arm.sh` and `cells.py` already in this directory were used unmodified.

My sweep workdirs (`/tmp/v57ver/**`) were **removed** when this report was
written. `scripts/verify_golden.py` and `tests/check_goldens.sh` were not
modified; nothing under `results/` was touched.
