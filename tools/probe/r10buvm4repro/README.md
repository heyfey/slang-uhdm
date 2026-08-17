# r10buvm4 — `§ namedMethodArgsWritten4` + `§ namedTfArgsFormalSlots4`: the **BuildUVMPkg head CLEARED on BOTH modes** (34 → 29 cmp lines), and the second law was **REFUTED BY THE CORPUS AFTER I HAD ALREADY BUILT IT** and had to be re-gated on the CALLEE LINK

**FIRST LINE, as the standing rules demand.** `BuildUVMPkg` **DID NOT CONVERT**:
`CMP_NOTEQUAL` before and after, in both modes, and no conversion was expected.
`results/gate_uhdm2rtlil.csv` (**731** rows) and `results/golden_surelog.csv`
(**1588** rows) are **byte-identical to the committed baselines** — whole ROW,
dump column included. I did not promote any CSV.

**SECOND LINE.** The briefed head is **GONE from BOTH `BuildUVMPkg` row-modes**.
It was

```
LHS golden: ref_obj (…set_type_override_by_type::original_type) id:5905 @12509:31-44
            |vpiParent: method_func_call (new) id:5904
RHS ours  : constant  id:19244 @12370:39-41
            |vpiDecompile:""  STRING:  vpiConstType:6
```

— our first `vpiArgument` on `override = new(.orig_type(original_type), …)` was
**`uvm_factory_override::new`'s FIRST FORMAL's DEFAULT `""`**, declared at
`uvm_pkg.sv:12370:39`, standing where golden holds the **first WRITTEN actual**.
The cell is now **byte-identical to golden**, and the whole-design cmp is
**34 → 29 lines** with a head in a different family (R0, §5).

**THIRD LINE, and it is the finding worth more than the patch.** The two call
families do **NOT** obey the same rule, and the discriminator is neither the
receiver nor the syntax:

* a **`method_func_call`** (a ctor `new`, a `super.new`, any `recv.m(...)`)
  lists the **WRITTEN actuals in WRITTEN order**; an unwritten formal
  contributes **nothing**.
* a **`func_call` / `task_call`** lists **one argument per FORMAL in FORMAL
  order**, an unwritten formal's slot holding a **loc-less, parent-less
  `constant INT:0`** — *not* that formal's declared default.

**FOURTH LINE — THE REFUTATION, and I paid for it with a build.** I derived the
second law from arms a1/a2 and shipped it at **all three** arms that build a
`func_call`/`task_call`. `BuildUVMPkg` refuted it on the next measurement: at
`uvm_pkg.sv:12476`

```
if(m_matches_type_override(.override(m_type_overrides[index]),
                           .requested_type(original_type),
                           .requested_type_name(original_type.get_type_name())))
```

golden carries **THREE** arguments and **no placeholders**, and my six-argument
version became a **NEW 208-line cmp head** — *strictly worse than the 34-line
one the pass set out to clear*. The real gate is the **CALLEE LINK**: every
slot-filled golden call in a1/a2/a3 carries `vpiFunction`, and 12476's carries
**none**. The shipped predicate therefore fires **only where we emit the
link**, and the two no-link arms (`§ classCallNoLink12`, the unit-scope
DPI-import arm) keep `§ writtenCallArgs16`'s prefix untouched.

Base **115082d**. Worktree `/tmp/wt_r10buvm4`; the pristine control is **my own
build of the base commit in that worktree**, taken before any edit.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 115082d) | `a3b363b74a043842f66a2c3ca3268756` | my own build of the base commit |
| **SHIPPED (patched)** | **`3df2841723c42bab1561f1280d676a73`** | every gate number below was measured on THIS binary |
| (census instrument, NOT shipped) | `74b50c4d4516cc8d1bf199691c98fdad` | throwaway build, §2 |

BUILD DIR (absolute): `/tmp/wt_r10buvm4/build`, `-j 2`, `CMAKE_BUILD_TYPE=Release`,
`/opt/rh/gcc-toolset-14/root/usr/bin/c++`. Each build log was checked for
`Linking CXX executable slang-uhdm` = 1, `Built target slang_uhdm` = 1 and
`error:` = 0 **before** any md5 was taken.

`git stash` was never used. `results/*.csv` were only ever READ. slang was not
patched. `GOLDEN_DEFER` was left **UNSET** (echoed as `[UNSET]` at the sweep
launch). The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) were never dispatched — `canaudit.sh` proves it
mechanically (**FENCE-BREACH=0**), and the census driver (§2) skips them by name
and prints `FENCED` for each of its 8 test-modes.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

---

## 0. THE TWO LAWS

### § namedMethodArgsWritten4

*A **`method_func_call`** — a constructor `new`, a `super.new`, or any call
reached through a receiver — carries its `vpiArgument` list as the **WRITTEN
actual list in WRITTEN order**. A formal that was not written contributes
**NOTHING**, and a named actual contributes the expression the CALL SITE wrote,
at the position the CALL SITE wrote it.*

### § namedTfArgsFormalSlots4

*A **`func_call` / `task_call` WHOSE CALLEE WE LINK** and whose actual list uses
**named association** carries **one `vpiArgument` per FORMAL, in FORMAL order**;
an unwritten formal's slot holds a **loc-less, parent-less `constant`** —
`INT:0`, `vpiSize:64`, `vpiDecompile:0`, `vpiConstType:7` — which is **not** the
formal's declared default. A **purely positional** call is untouched: it keeps
`§ writtenCallArgs16`'s written prefix and gets **no** placeholders.*

Both laws share ONE decoder, `writtenFormalIdx4` (`src/EmitHelpers.h`), which
maps each written actual to its formal index and is **all-or-nothing**: an empty
association (`.f()`, or the trailing `f(a,b,)` slot uvm-1.2's `create` /
`print_field_int` / `read` / `write` calls are full of), a name matching no
formal, a duplicate, or a position past the bound list all return **false**, and
every caller then keeps its existing behaviour byte-for-byte.

---

## 1. THE ARMS — where the laws come from

`ct4arm.sh <arm>.sv` runs Surelog and slang-uhdm on one file in its own scratch
dir and diffs the two dumps. `SLANG_UHDM` has **no default**.

### a1 `a1_namedargs.sv` — the two shapes, side by side

| cell | written | golden `func_call` / `method_func_call` args |
|---|---|---|
| C1 ctor, 5 named of 6 formals, first skipped | `.b .c .d .e .f` | `"bb" 1 2 3 1` — written order |
| C2 ctor, same 5 **REORDERED** | `.d .b .f .c .e` | `2 "bb" 1 1 3` — **written order**, not formal |
| C3 ctor, only the mandatory formal | `.d(9)` | `9` |
| C4 ctor, MIXED positional + named | `"aa" .d .f` | `"aa" 4 1` |
| C6 **package function**, 3 named of 6 | `.d .b .c` | `0[NOLOC] "bb" 1 2 0[NOLOC] 0[NOLOC]` — **formal slots** |
| C7 package function, `.d(9)` alone | `.d(9)` | `0 0 0 9 0 0` — five placeholders |
| C8/C9 `hh.mf6(...)` method, named + reordered | | `"bb" 2 1` / `2 1 "bb"` — written order |
| C10/C11 `hh.mt6(...)` **TASK** | | `"bb" 2 1` / `2 "bb" 1` — written order |
| C12 package function, **POSITIONAL** 4 of 6 | | `"aa" "bb" 1 2` — **no placeholders** |
| C13 method, positional 4 of 6 | | `"aa" "bb" 1 2` |

C7 is the cell that kills "the placeholder is the formal's default": `a`/`b` are
`string=""`, `e` is `int=7`, `f` is `bit=0`, and all four slots read `INT:0`.
C12/C13 are the cells that gate the placeholders on **named association**.

**AFTER the patch, every a1 cell above matches golden.** The single remaining a1
divergence is **C5** (`new(.b("bb"), .c(), .d(5))`, an EMPTY named association),
where golden emits a `hier_path (c.d)` gluing the two argument names together —
a **Surelog parse artefact**, not a law. `writtenFormalIdx4` refuses that list
and the emitter keeps its pristine output, which is why the cell is
**unchanged** rather than newly wrong. Filed as **residue R1**.

### a2 `a2_kindgrid.sv` — WHICH KIND, not which receiver

| cell | written | golden |
|---|---|---|
| D1 `super.new(.c(k), .b(2))` | | `method_func_call` → `ref_obj 2` — written order |
| E1 `im(.c(1), .b(2))` — in-class, **NO receiver** | | **`func_call`** → `0[NOLOC] 2 1 0[NOLOC]` |
| E2 `this.im(.c(1), .b(2))` | | `method_func_call` → `1 2` — written order |
| E3/F1 package function | | `func_call` → formal slots |
| E4/F2 package **task** | | `task_call` → formal slots |
| E5 `caller::sm(...)` static via `::` | | no call node at all (§ staticScopedCall12) |
| E7 `im(.b(2), .c(1))` **REORDERED** | | `0 2 1 0` — **FORMAL order, always** |

E1 vs E2 is the whole point: the **same method**, called with and without a
receiver, takes **different** argument rules. **a2 is `PASS_CMP` after the
patch — `cmp.log` is 0 lines** (it was 0 before too; every named cell was in the
un-compared tail, which is why the arm's `diff -u` of the dumps is the judge and
the cmp line count is printed as head depth only).

### a3 `a3_linkgrid.sv` — THE REFUTATION ARM

Written **after** BuildUVMPkg refuted the second law, to reproduce both sides.

| cell | callee | golden `vpiFunction` | golden args | pristine | patched |
|---|---|---|---|---|---|
| M1 `later(.b(1), .c(2))` — **OUT-OF-BODY** callee | prototyped, defined below | **YES** | `0[NOLOC] 1 2 0[NOLOC]` | `0 1` | `0 1` (**unchanged**) |
| M2 `sooner(.b(1), .c(2))` — in-place callee | defined above | YES | `0[NOLOC] 1 2 0[NOLOC]` | `0 1` | **`0[NOLOC] 1 2 0[NOLOC]`** ✔ |
| M3 `later(.d(4),.b(1),.a(0),.c(2))` all written | | YES | `0 1 2 4` | `0 1 2 4` | `0 1 2 4` |
| M4 `later(0, 1)` positional control | | YES | `0 1` | `0 1` | `0 1` |

**M2 is the only cell in a3 the patch moves, and it moves from WRONG to
GOLDEN.** M1 is an honest statement of the gate's shape: the predicate follows
**our** link decision, and at M1 **we do not link `later` at all** where golden
does (`fn=no` vs `fn=YES`) — a **pre-existing** `§ classCallNoLink12` defect that
this pass neither fixes nor worsens (pristine and patched are the same two
arguments). Filed as **residue R2**.

---

## 2. THE CENSUS — corpus-wide, artifact-based, and it named every mover in advance

A **throwaway instrumented build** (md5 `74b50c4d4516cc8d1bf199691c98fdad`,
reverted before the shipped patch) appended one line per call carrying a NAMED
or EMPTY association, and `censusrun.sh` replayed **every corpus test's own
slang argv** — built by `verify_golden.py`'s **own** `translate()` /
`location_args()` / `split_sources()`, so the flags are the sweep's flags — in
each test's own directory. **3035 test-modes, 1520 tests, both corpora, both
modes**; the four fenced names were skipped by name (`FENCED`, 8 test-modes) and
every test-mode's **exit code** was recorded, because a census that counts a
crash as "no named arguments" under-reports.

**The whole corpus contains named association in SEVEN tests.** Nothing else in
either corpus can reach either law.

| test | `NEWCLASS` named (→ § …Written4) | method call named (→ § …Written4) | `func_call` named (→ § …FormalSlots4) |
|---|---|---|---|
| **BuildUVMPkg** | **4** — `uvm_pkg.sv` 12509 / 12588 / 12656 / 12699, 5 of 6 formals, **reordered** | **2** — `begin_tr` 54964 / 55592 | 14 sites (`m_matches_*`, `add`), **all in the NO-LINK arm or all-formals-written → inert** |
| SimpleUVM | 4 — `uvm_factory.svh` 984/1049/1113/1152, 4 of 4 **reordered** | `add` ×2 (written order **==** formal order → inert) | — |
| SeqDriver | 4 — same four | `add` ×2 (inert) | — |
| Scoreboard (default) | 4 — same four | `add` ×2 (inert) | — |
| MiniAmiq | 4 — same four | `add` ×2 (inert) | — |
| EvalFuncNamed | — | — | 2 sites, **every formal written** → slot list **==** prefix → inert |
| FuncArgsByName | — | — | 2 sites, **every formal written** → inert |

`MiniAmiq` **SEGFAULTS on the PRISTINE binary too** (verified: `rc=139` with
`a3b363b…`), which is why it is `SLANG_REJECT` in the baseline and cannot move a
row. Five more test-modes segfault identically at base (`Earlgrey_0_1.testflags`,
`Rggen.testflags`, `Tnoc.{default,testflags}`); all pre-existing.

### PREDICTION, written before the sweeps ran

* **byte movers, surelog corpus: `BuildUVMPkg` ×2, `SimpleUVM` ×2, `SeqDriver` ×2, `Scoreboard` ×1 (default only — its testflags row is `SLANG_REJECT`), `MiniAmiq` ×2 (no database).**
* **byte movers, uhdm2rtlil corpus: ZERO.**
* **`EvalFuncNamed` and `FuncArgsByName`: NO byte change** — they are the corpus's only other named-argument `func_calls`, they are `CMP_EQUAL`, and they write every formal.
* **row movers: ZERO on both corpora.**

---

## 3. THE PATCH

Production surface is **two files**: `src/EmitHelpers.h` (the decoder) and
`src/ExprEmit.cpp` (five emit sites plus the placeholder minter).

| site | law | what changed |
|---|---|---|
| `case ExpressionKind::NewClass` | § …Written4 | the ctor's own `NewClassExpressionSyntax` arg list is decoded here (it is **not** an `InvocationExpressionSyntax`, so the shared reader cannot see it) — **THE HEAD** |
| 7 × `method_func_call` arms (`§ superMethodCall17`, `§ thisRecvCall11`, `§ deepRecvCall11`, `§ classArgBind12`, …) | § …Written4 | `writtenArgs16(call)` → `writtenArgsInOrder4(call, sub, buf)` |
| the bound `func_call`/`task_call` arm | § …FormalSlots4 | slot loop, gated on `linked4 && namedTfSlots4` |
| `§ classCallNoLink12` arm | — | **deliberately unchanged**, with the refutation recorded in the comment |
| unit-scope DPI-import arm | — | **deliberately unchanged**, same reason |

`linked4` is not a new concept: it is a `bool` recording the arm's **existing**
`vpiFunction` / `vpiTask` decision, including the `§ defGenCallNoBind` /
`§ defGenQualPkgCallBinds18` carve-out and a null `siTf`.

---

## 4. THE GATES

### Gate 1 — builds

Both binaries built `-j 2` in `/tmp/wt_r10buvm4/build`; md5s in the table above;
`error:` = 0, link line = 1, `Built target slang_uhdm` = 1 in each log.

### Gate 2 — goldens

| run | PASS | FAIL |
|---|---|---|
| `SLANG_UHDM=<patched> tests/check_goldens.sh` | **23** | **0** |
| `SLANG_UHDM=/bin/false tests/check_goldens.sh` (negative control) | **0** | **23** |

### Gate 3 — uhdm2rtlil

`ct8rows.sh` against the **committed** `results/gate_uhdm2rtlil.csv`
(**baseline FIRST**: the pristine sweep was checked against it too):

| comparison | differing ROWS | histogram |
|---|---|---|
| committed baseline vs **PRISTINE** testflags | **0** | 679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL` |
| committed baseline vs **PATCHED** testflags | **0** | 679 / 50 / 2, dump column 496 `match` / 183 `differ` / 52 blank — identical |
| pristine vs patched, **both modes** (1462 rows) | **0** | — |

Canaries on the u2r CSV: `canaries.sh` `ok=8 changed=0 absent=0`;
`ctcan2.sh EXPECT_UNKNOWN=6` `ok=1 changed=0 absent=0`; `canaudit.sh`
`audited=29 UNCOVERED=0 FENCE-BREACH=0`.

### Gate 4 — surelog, `--mode both`

`ct8rows.sh` against the **committed** `results/golden_surelog.csv`, **1588 rows**:

| comparison | differing ROWS |
|---|---|
| committed baseline vs **PRISTINE** | **0** |
| committed baseline vs **PATCHED** | **0** |
| pristine vs patched | **0** |

Status histogram, identical on all three: `default` 469 `CMP_EQUAL` / 11
`CMP_NOTEQUAL` / **5 `DEFERRED`** / 284 `SLANG_REJECT` / 25 `SURELOG_FAIL`;
`testflags` 465 / 8 / **5 `DEFERRED`** / 3 `NO_DATABASE` / 1 `NO_UHDM` / 286 /
23 / 1 `TIMEOUT` / 2 `UNTRANSLATABLE`. Dump column identical too
(`default` 225 `match` / 244 `differ`; `testflags` 165 / 300).

Canaries on the surelog CSV: `canaries.sh` **`ok=52 changed=0 absent=0`**
(7 unknown names = the u2r-only canaries, the documented expectation);
`ctcan2.sh EXPECT_UNKNOWN=1` **`ok=58 changed=0 absent=0`**.

Named canary pins, measured on the patched sweep:

| canary | md5 (first 12) | note |
|---|---|---|
| `SVSwitch` default **and** testflags | `4842211c4030` | **the pin the standing rules name**, both modes |
| `InterfaceModPort` default and testflags | `59a365f3ce2c` | cmp 0 lines (byte-equal to golden) |
| `BlackParrotComplex` | `e3e354129d5a` | cmp 0 lines |
| `YosysOldOr` | `d68e0796d62c` | cmp 0 lines |

### Gate 5 — byte verification, `SELFCHECK=1`, EVERY MOVER NAMED AND ATTRIBUTED

| corpus | databases | MOVERS | SELFCHECK |
|---|---|---|---|
| uhdm2rtlil (both modes) | 1358 | **0** — exactly as predicted | 1357 / 1358 flagged |
| surelog (both modes) | 953 | **7** — **exactly the seven predicted, by name** | 952 / 953 flagged |

```
MOVER ./default/BuildUVMPkg-bf853d43/slang.uhdm    6c539800206a <- b38dec27066c
MOVER ./default/Scoreboard-59431470/slang.uhdm     f383a9b83ff3 <- b41ba175752f
MOVER ./default/SeqDriver-32af76aa/slang.uhdm      d02cbf56667a <- 11c89dc5c4be
MOVER ./default/SimpleUVM-1dc93a62/slang.uhdm      4ce6aa8ba475 <- 041c7fcd1601
MOVER ./testflags/BuildUVMPkg-bf853d43/slang.uhdm  6c539800206a <- b38dec27066c
MOVER ./testflags/SeqDriver-32af76aa/slang.uhdm    cb4cf67e822a <- 02f888acffa9
MOVER ./testflags/SimpleUVM-1dc93a62/slang.uhdm    651d47055e6a <- b3b11ba2475e
```

`Scoreboard/testflags` and `MiniAmiq/{default,testflags}` are `SLANG_REJECT` and
produce no database at all, which is why the census named them and the verifier
cannot.

**ATTRIBUTION, mover by mover, from the DUMPS, not from the md5s.**

*`BuildUVMPkg` (both modes — the two databases are BYTE-IDENTICAL to each other,
`6c539800206a`).* 275 changed dump-line sides, and **every one** carries a line
number the census named:

| dump `line:` | what it is |
|---|---|
| 12509 / 12588 / 12656+12657+12671 / 12699+12701 | the four ctor calls' first written actual |
| 12513 / 12526 / 12529 / 12592 / 12633 / 12450 / 12452 | their other written actuals and the io_decls those bind to |
| **12370** | `uvm_factory_override::new`'s formal-1 default `""` — **the object that WAS the cmp head**, now gone from all four calls |
| 54965 / 55593 | the two `begin_tr` method calls |
| **40511 / 40512** | `uvm_component::begin_tr`'s `label=""` and `desc=""` DEFAULTS, now gone from those two calls |

The head cell itself is byte-identical to golden after the patch:
`new`'s `vpiArgument` list at 12509 is
`ref_obj@12509:31 | hier_path@12510:36 | ref_obj@12511:31 | hier_path@12512:36 |
ref_obj@12513:31` on **both** sides.

*`SimpleUVM`, `SeqDriver`, `Scoreboard` (uvm-1.2).* Their dump content is a
**PURE REORDER** — the `<` and `>` line multisets are byte-identical
(`c122807f03e8`, `628df128cca9`, `7b2e103fa547` respectively), because these four
`new` calls write **all four** formals and the patch only changes the ORDER:

```
uvm_factory.svh:984  override = new(.orig_type(...), .orig_type_name(...),
                                    .full_inst_path("*"), .ovrd_type(...));
PRISTINE -> constant@986:36 | hier_path@985:36 | ref_obj@984:31 | ref_obj@987:31   (FORMAL order)
PATCHED  -> ref_obj@984:31 | hier_path@985:36 | constant@986:36 | ref_obj@987:31   (WRITTEN order)
```

The changed line numbers are exactly 984/986, 1049/1051, 1113/1114, 1152/1154 —
the four call sites — plus 931/1003/1094/1127, the FORMAL DEFAULT locations the
pristine list pointed at. `Scoreboard`'s extra `svunit_pkg` lines are the same
objects at different arena positions and are part of the same pure-reorder
multiset.

**THE FIVE-ROW WALL DID NOT REGRESS, and this is measured, not asserted.** The
whole `uhdm-cmp` OUTPUT for `SimpleUVM/{default,testflags}`,
`SeqDriver/{default,testflags}` and `Scoreboard/default` — 1 405 511, 1 450 011
and 1 399 779 lines — is **byte-identical between the pristine and patched
binaries**. Their head did not move and their distance did not change; only
bytes below the head did.

### Determinism

`BuildUVMPkg` produced md5 `6c539800206aeb51ab090c495e1e7a5b` in **three
independent runs** (a standalone run, the sweep's `default` row, the sweep's
`testflags` row), from two different working directories.

---

## 5. THE NEW HEAD (R0) — for the next pass

`BuildUVMPkg`, **both modes**, 29 cmp lines, and it is an **object we emit that
golden does not have at all** (`LHS: <null>`):

```
RHS: ref_var (uvm_pkg::uvm_default_factory::set_inst_alias::orig_type_alias_per_inst)
     id:19740, line:12754:30, endln:12754:54
     |vpiParent: begin (uvm_pkg::uvm_default_factory::set_inst_alias) @12754:5-12754:55
     |vpiTypespec: ref_typespec -> struct_typespec (m_inst_typename_alias_t) @11964:11-11968:4
```

`uvm_pkg.sv:12754` is `m_inst_typename_alias_t orig_type_alias_per_inst;` — a
`begin`-block local whose declaration golden does **not** materialise as a
`ref_var` in this position. This is a **declaration/scope** question, not an
argument-list one; it is a *different family* from the head this pass cleared.

---

## 6. RESIDUES

* **R1 — the EMPTY named association (`.c()`).** Golden (arm a1 C5) emits a
  `hier_path (c.d)` that glues the `.c()` and `.d(5)` argument NAMES into one
  dotted path; that is a Surelog parse artefact, not a law, so
  `writtenFormalIdx4` refuses the whole list and the emitter is left exactly as
  it was. Corpus reach of empty associations: `create` / `open_recorder` /
  `print_field_int` / `read` / `write` in BuildUVMPkg, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard — **all with `named=0`**, so none of them changes.
* **R2 — our link decision is not golden's.** `§ namedTfArgsFormalSlots4` is
  gated on `linked4`, i.e. on **our** `vpiFunction`. Arm a3 M1 is a cell where
  golden links an out-of-body-defined class method and we do not, so golden fills
  slots and we emit the prefix. Fixing that is `§ classCallNoLink12`'s problem,
  not this law's; when the link is fixed the argument list follows for free.
* **R3 — the covergroup ctor arm still emits FORMAL order.**
  `§ covergroupNewCall7` builds its own written-set mask and then iterates the
  bound list in **formal** order, so a REORDERED named covergroup `new` would
  come out in the wrong order. `NewCovergroup` is a separate expression kind
  with **zero** named-association reach in the census, so it was left alone
  rather than changed blind.

---

## 7. DELIVERY — COLLISION CHECK, NO COLLISION

`/tmp/r10buvm4.patch`, md5 recorded in the delivery message (the README is INSIDE the patch, so the patch cannot state its own md5), 2013 lines,
19 files, **surface = `src/EmitHelpers.h` + `src/ExprEmit.cpp` +
`tools/probe/r10buvm4repro/` and nothing else** (checked mechanically:
`git diff 115082d --name-only` filtered against that surface is EMPTY).

* `git apply --check` **clean on a FRESH `115082d` worktree**.
* `git apply --check` **clean on the current branch head `0424f46`** (r10earl52,
  the one commit that landed since my base).
* **ROUND-TRIP**: applying it to a fresh `115082d` and re-`git diff`ing
  regenerates a patch with the **same md5**.
* The landed commit touches **only `src/ParamEmit.cpp`** among production files
  (`git diff --stat 115082d 0424f46 -- src include`), and this pass touches
  neither that file nor any file it touches — **no collision**.

`GOLDEN_DEFER` was `[UNSET]` at the sweep launch and **5 `DEFERRED`** appears in
both surelog modes, matching the committed baseline. `results/*.csv` were never
written; the CSVs this pass produced live in `/tmp/r10buvm4_*.csv`.
