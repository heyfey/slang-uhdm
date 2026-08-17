# r10buvm5 — `§ refVarLocalWindowBinds5`: the **BuildUVMPkg head CLEARED on BOTH modes** (29 → 19 cmp lines), and **THE BRIEF'S FRAMING WAS WRONG** — nothing is missing from that block, we were attaching a `vpiActual` golden does not attach

**FIRST LINE, as the standing rules demand.** `BuildUVMPkg` **DID NOT CONVERT**:
`CMP_NOTEQUAL` before and after, in both modes. `results/gate_uhdm2rtlil.csv`
(**731** rows) and `results/golden_surelog.csv` (**1588** rows) are
**byte-identical to the committed baselines** — whole ROW, dump column included.
I did not promote any CSV.

**SECOND LINE.** The briefed head is **GONE from BOTH `BuildUVMPkg` row-modes**,
which are byte-identical to each other before and after. It was

```
LHS: <null>
RHS: ref_var (uvm_pkg::uvm_default_factory::set_inst_alias::orig_type_alias_per_inst)
     id:19740 @12754:30-12754:54  |vpiParent: begin @12754:5-12754:55
```

and the whole-design cmp is **29 → 19 lines** with a head in a different family
(R0, §7).

**THIRD LINE, and it is the finding worth more than the patch: THE BRIEF'S
DIAGNOSIS WAS WRONG, AND SO WAS ITS WHOLE QUESTION.** The brief read that head as
a DECLARATION/SCOPE question — "an EXTRA `ref_var` WE emit and golden does NOT",
"is the declaration itself absent in golden's block? hoisted? a duplicate?" — and
told me to census the begin block's children on both sides. I did that FIRST, and
the census says the block is **IDENTICAL**:

```
$ diff <(sed -n '24060,24175p' gold.dump) <(sed -n '24060,24175p' ours.dump)  ->  EMPTY
```

Golden's `set_inst_alias` has **the same two `vpiVariables`** on the function and
**the same two** on the `begin`, in the same order, with the same spans and the
same `ref_typespec` → `struct_typespec (m_inst_typename_alias_t) @11964:11`.
`orig_type_alias_per_inst` **is** a `ref_var` in golden and **is** parented at
that `begin`. There is nothing to hoist, merge or omit.

The `ref_var` in the cmp head is not the OBJECT that differs — it is the object a
`vpiActual` **POINTS AT**. The differing object is one line of source further on,
at `uvm_pkg.sv:12766`:

```
m_inst_aliases.push_back(orig_type_alias_per_inst);
                         ^^^ this argument's ref_obj @12766:34

golden : |vpiName:orig_type_alias_per_inst   |vpiFullName:…   (and NOTHING else)
ours   : … + |vpiActual: \_ref_var (…::orig_type_alias_per_inst) @12754:30
```

`uhdm-cmp` prints the actual's decompile, so the head reads like a stray
declaration. It is a **REFERENCE-BINDING** question, in the
`classMethodNoBind` / `§ controlBodyNoBind28` / `§ blkLocalSameCtrlDepth…57/64`
family — not a declaration one, and not in the sd10/sd12 variable-KIND family the
brief pointed at either. **A one-line span-keyed census of the block, run before
any code, is what caught it**, and it is the reason this pass did not spend a
build on the declaration question.

**FOURTH LINE — the law is REF_VAR-SPECIFIC, and the controls are what prove it.**

> A reference to a SUBROUTINE-LOCAL whose emitted DECLARATION IS A `ref_var` — a
> local Surelog itself never resolved to a variable kind — binds its `vpiActual`
> **only** when BOTH (a) it stands in a BINDING WINDOW (an if/case CONDITION, or
> a USER call's ARGUMENT list) and (b) its declaration is at the **SAME
> `ctrlBodyDepth28`** the reference reads at. Everywhere else it is BARE.

The identical bodies with an `int`, a resolved class handle and a `string` local
(arm a2 `c01`/`c02`/`c03`) are golden-BOUND in **every** one of those positions —
in an assignment and one block deeper alike. The uvm_pkg twin of that control is
in the head's own function: golden binds `original_type_name` (a `string_var`) at
`12764:53` from inside the very `else begin` where it refuses to bind
`orig_type_alias_per_inst`.

Base **9f45cc0**. Worktree `/tmp/wt_r10buvm5`; the pristine control is **my own
build of the base commit**, and it came out **bit-identical to the main tree's
binary**, which is what lets the control be named twice below.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 9f45cc0) | `4220e4f818406b3c91323967eb59db89` | my own `-j 2` build of the base commit; **equal to `~/git-repos/slang-uhdm/build/slang-uhdm`** |
| **SHIPPED (patched)** | **`dff63b97f02fb845b49c8f91de6c2a12`** | every gate number below was measured on THIS binary |
| (census instrument, NOT shipped) | `b0ddfa95ecba17e277cec9c59cc3e872` | throwaway build, §5 |

BUILD DIR (absolute): `/tmp/wt_r10buvm5/build`, `-j 2`, `CMAKE_BUILD_TYPE=Release`,
`/opt/rh/gcc-toolset-14/root/usr/bin/c++`. Each build log was checked for
`Linking CXX executable slang-uhdm` = 1, `Built target slang_uhdm` = 2 and
`error:` = 0 **before** any md5 was taken. One COMMENT-ONLY edit was made to
`ExprEmit.cpp` after the shipped binary was cut; the tree was rebuilt and the
binary came out **byte-identical (`dff63b97…` again)**, so the shipped source and
every measured number correspond exactly.

`git stash` was never used. `results/*.csv` were only ever READ. slang was not
patched. `GOLDEN_DEFER` was left **UNSET** (echoed as `[UNSET]` at the sweep
launch, and **5 `DEFERRED`** appears in both surelog modes exactly as the
committed baseline has it). The four slang-fenced tests (`UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam`) were never dispatched — `canaudit.sh`
proves it mechanically (**FENCE-BREACH=0**), and that guard had to be **CORRECTED**
first (§6.1).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

---

## 1. THE DECODE — twenty golden cells, one truth table

Two arms, both **out-of-body** methods (which is where the whole corpus population
lives) unless marked, each cell a `ref_var` local read from exactly ONE position.
`ct5arm.sh` runs a cell file through Surelog and through us; `pop.py`
(in this directory) prints, for every `ref_obj` naming a declared `ref_var`, the
use site, the decl site, the actual it carries and its parent kind.

| cell | source | position | golden |
|---|---|---|---|
| a1 P1 | `hold5.push_back(v5);` | stmt METHOD-call arg, same depth | **BIND** |
| a1 P3 | `sink5(v5);` | stmt PLAIN-call arg, same depth | **BIND** |
| a1 P5 | `if (v5 == null)` | if CONDITION, same depth | **BIND** |
| a1 P7 | `if (!$cast(v5, fifo5))` | `$cast` arg inside a condition | **BIND** |
| a1 S1 | `sq5.push_back(u5);` | class-nested STRUCT typedef local | **BIND** |
| a2 b02 | `if (v5 == null) return 0;` | if CONDITION | **BIND** |
| a2 b03 | `case (v5)` | CASE condition | **BIND** |
| a2 b06 | `isink5((v5==null)?1:0);` and the `push_back` twin | call arg that is an OPERATION | **BIND** |
| a2 b09 | decl AND read in the same unnamed block (d1 == d1) | | **BIND** |
| a2 i01 | the **IN-CLASS** twin of P1 | | **BIND** |
| a1 P2/P4/P6/P8/S2 | the same five, one `begin` deeper | | bare |
| **a2 b08** | `if (m5 == 0) hold5.push_back(v5);` | **BARE if body, SAME block, d0 vs d1** | **bare** |
| a2 b10 | decl at d1, read at d2 | | bare |
| a2 b11 | **NAMED** begin, same block, same depth | | bare |
| a2 b01 | `$display("%p", v5);` | SYSTEM call arg, same depth | bare |
| a2 b04 | `while (v5 == null)` | WHILE condition | bare |
| a1 P10/P11 | `v5 = fifo5;` / `w5 = v5;` | assignment LHS **and** RHS | bare |
| a2 i08 | the IN-CLASS twin of b08 | | bare |

Three of those cells are the ones a rule written from the corpus alone would have
got wrong:

* **`b08` is the cell that decides BLOCK vs DEPTH.** The declaration and the
  reference are in the SAME Surelog block — a bare `if` body opens none — and
  golden still refuses. So the test is `ctrlBodyDepth28`, exactly the counter
  § 28 already keeps, and **not** "same statement block".
* **`b04` is the cell that decides which conditions are windows.** A `while`
  condition is not one. That is the same boundary § 64's `c13` found for the
  in-body law, and it is why the window is a counter raised at the THREE
  StmtEmit sites that clear `classMethodNoBind`, not at "any condition".
* **`b11`** keeps § 57's UNNAMED requirement load-bearing: Surelog scopes a named
  block's locals through the label and binds none of them.

### 1.1 the CONTROLS — the law is `ref_var`-specific

Arm a2 `c01`/`c02`/`c03` put an `int`, a resolved class handle and a `string`
local in the SAME out-of-body bodies, read from the same positions:

```
137:12  int_var    func_call    q5::own5::c01_5::i5     <- call arg, same depth
138:5   int_var    assignment   q5::own5::c01_5::i5     <- ASSIGNMENT LHS
140:14  int_var    func_call    q5::own5::c01_5::i5     <- one block DEEPER
147:12  class_var  func_call    q5::own5::c02_5::p5
148:5   class_var  assignment   q5::own5::c02_5::p5
150:14  class_var  func_call    q5::own5::c02_5::p5
158:5   string_var assignment   q5::own5::c03_5::s5
160:7   string_var assignment   q5::own5::c03_5::s5     <- one block DEEPER
```

golden BINDS all of them, in both views, and so do we, before and after. The gate
therefore keys on the **emitted declaration object**, not on the position.

### 1.2 the corpus population, decoded before any code

Order-blind census of `uvm_pkg.sv` (golden vs ours, whole design, both views):
golden carries **45** `ref_obj → ref_var` bindings and we carried **61**. The 16
extras are **8 sites × 2 views**, and every one of them is a cell of the table
above:

| site | source | why golden refuses |
|---|---|---|
| 12766:34 | `m_inst_aliases.push_back(orig_type_alias_per_inst);` | decl d0, read d1 (`else begin`) — **THE HEAD** |
| 41209:35 | `m_time_settings.push_back(setting);` | decl d1, read d2 |
| 41223:44 | `m_verbosity_settings.push_back(setting);` | decl d1, read d3 |
| 54013:27 | `m_last_req_push_front(param_t);` | decl d0, read d1 |
| 56939:17 | `if (!$cast(req_item, obj))` | decl d0, read d1 |
| 76692:5, 76761:5, 76834:2 | `ep = rw.get_event_pool();` | same depth, but an ASSIGNMENT is not a window |

`param_t` is the cell that proved the law is **per-SITE, not per-VARIABLE**:
golden binds it at `54004` (`if ($cast(param_t, t))`, d0) and refuses at `54013`
and `54020` — one declaration, three references, two answers.

Two sites move the OTHER way and are **NOT** this law's: `41143:6` / `41157:6`
(`if(p_!=null)`, `process p_;`) are golden `ref_var` and ours `class_var`, a
variable-KIND difference that this predicate never sees (our object is not a
`ref_var`, so it returns false). They are untouched, before and after.

---

## 2. THE PATCH — one predicate, one reader, one counter

Surface: `include/UhdmExporter.h`, `src/ExprEmit.cpp`, `src/StmtEmit.cpp` (+157/−11).

* `int condBindDepth5` — the if/case CONDITION window as a COUNTER. Raised at
  EXACTLY the three `StmtEmit.cpp` sites that clear `classMethodNoBind` with the
  comment *"condition refs DO bind"*, and nowhere else. It exists because an
  OUT-OF-BODY method never sets `classMethodNoBind` at all, so a law that has to
  tell "inside a condition" from "in an assignment" there cannot read that flag.
* `UhdmExporter::refVarLocalNoBind5(sym, declObj)` — the predicate. Four
  conditions, each one a cell that fails without it (see the header comment).
* ONE reader: the `netMap` binding arm in `emitExpr`'s `NamedValue` case. When it
  fires, the reference is registered for **neither** the `vpiActual` **nor**
  `selWholeRefs` — "binds nothing" has to survive `endSelTrack`'s back-patch too.

It is deliberately **NOT** folded into § 28/§ 57/§ 64: those are gated on an
IN-BODY class method and apply to every local; this one applies to a `ref_var`
local in every method and to nothing else. §1.1 is why that split is real.

### 2.1 arm verdict after the patch

`pop.py` over both sides, patched binary:

* **arm a2: golden and ours are now IDENTICAL on the WHOLE `ref_obj` actual
  census** (`diff` empty, 100+ rows, both views).
* **arm a1: identical except the one documented residue R1** (P9).
* pristine → patched, both arms: **12 cells moved, all of them wrong → right, ZERO
  pristine-right → patched-wrong.**

---

## 3. RESIDUES

* **R1 — a USER call nested INSIDE a condition.** a1 `P9`
  (`if (port5.try5(v5) == 0)`) is golden BARE and the predicate still binds it:
  the window is open and the depth matches. Left alone ON PURPOSE, because
  golden also **NAMES** that argument differently —
  `p9_5::port5.try5::v5`, the callee path spliced into the scope prefix, exactly
  as uvm_pkg spells `send_request::m_req_fifo.try_put::param_t`
  (`uvm_pkg.sv:54020`) and `item_done::m_req_fifo.try_get::t` (`54474`). Those two
  corpus cells cannot go byte-equal from the binding alone, so a gate written for
  them here would have been unmeasurable. The naming law is the next pass's.
* **R2 — `process p_` is `class_var` for us and `ref_var` for golden**
  (`uvm_pkg.sv:41140`, bound at `41143`/`41157`). A variable-KIND question in the
  sd10/sd12 family; this predicate cannot reach it and does not.
* **R3 — the in-body law is untouched.** `classMethodNoBind`,
  § `controlBodyNoBind28`, § `blkLocalSameCtrlDepthArgBinds57` and
  § `blkLocalSameCtrlDepthWindowBinds64` keep their own gates; arm a2's `i01`/`i08`
  are the two cells that show it (golden BIND / bare, ours BIND / bare, before and
  after).

---

## 4. GATES — all five, every number measured on `dff63b97…`

### Gate 1 — builds

Both `-j 2`, both logs `error:` = 0, `Linking CXX executable slang-uhdm` = 1,
`Built target slang_uhdm` = 2. md5s in the table at the top. The pristine control
reproduced the MAIN TREE's binary bit-for-bit (`4220e4f818406b3c91323967eb59db89`
both), so "pristine" is not a claim, it is a hash.

### Gate 2 — goldens

| run | PASS | FAIL |
|---|---|---|
| `SLANG_UHDM=<patched> tests/check_goldens.sh` | **23** | **0** |
| `SLANG_UHDM=/bin/false` (negative control) | **0** | **23** |

### Gate 3 — uhdm2rtlil, BASELINE FIRST

The committed `results/gate_uhdm2rtlil.csv` carries **testflags only** (731 rows),
so the row gate is run three ways and all three are quoted:

| comparison | rows | differing ROWS |
|---|---|---|
| PRISTINE vs committed (testflags) — **baseline first** | 731 | **0** |
| PATCHED vs committed (testflags) | 731 | **0** |
| PATCHED vs PRISTINE, **both** modes | 1462 | **0** |

Status histogram identical on all of them: **679 `CMP_EQUAL` / 50 `SLANG_REJECT` /
2 `SURELOG_FAIL`** per mode. Dump column identical too (`default` 492 `match` /
187 `differ`; `testflags` 496 / 183).

### Gate 4 — surelog, both modes, 1588 rows

| comparison | differing ROWS |
|---|---|
| PRISTINE vs committed — **baseline first** | **0** |
| PATCHED vs committed | **0** |

Status histogram, identical on both: `default` 469 `CMP_EQUAL` / 11 `CMP_NOTEQUAL`
/ **5 `DEFERRED`** / 284 `SLANG_REJECT` / 25 `SURELOG_FAIL`; `testflags` 465 / 8 /
**5 `DEFERRED`** / 3 `NO_DATABASE` / 1 `NO_UHDM` / 286 / 23 / 1 `TIMEOUT` /
2 `UNTRANSLATABLE`. Dump column identical (`default` 225 `match` / 244 `differ`;
`testflags` 165 / 300).

Canaries: `canaries.sh` on the surelog CSV **`ok=52 changed=0 absent=0`** (7
unknown names = the u2r-only canaries, the documented expectation);
`ctcan2.sh EXPECT_UNKNOWN=1` **`ok=58 changed=0 absent=0`**; on the u2r CSV
`canaries.sh` **`ok=8 changed=0 absent=0`** and `ctcan2.sh EXPECT_UNKNOWN=6`
**`ok=1 changed=0 absent=0`**.

Named canary pins — **pristine and patched byte-identical on every one**:

| canary | mode | md5 (first 12), pristine == patched |
|---|---|---|
| **`SVSwitch`** | default **and** testflags | **`4842211c4030`** — the pin the standing rules name |
| `InterfaceModPort` | both | `59a365f3ce2c` |
| `BlackParrotComplex` | default / testflags | `e3e354129d5a` / `73a10e8217e5` |
| `YosysOldOr` | both | `d68e0796d62c` |

### Gate 5 — byte verification, EVERY MOVER PREDICTED THEN NAMED

The prediction was written **before** the verifier ran (`/tmp/r10buvm5_predict.txt`,
reproduced as §5 below).

| corpus | databases | MOVERS | `SELFCHECK` | `SELFCHECK1` |
|---|---|---|---|---|
| uhdm2rtlil (both modes) | 1358 | **0** — as predicted | 1357 / 1358 flagged | 1 |
| surelog (both modes) | 953 | **7** — **exactly the seven predicted, by name** | 952 / 953 flagged | **8** = 1 planted + the 7 real |

```
MOVER ./default/BuildUVMPkg    patched=3fb5e3995d0c pristine=6c539800206a
MOVER ./default/Scoreboard     patched=c347da7b9a4a pristine=f383a9b83ff3
MOVER ./default/SeqDriver      patched=835f4aa3cefc pristine=d02cbf56667a
MOVER ./default/SimpleUVM      patched=93f10f2ffe72 pristine=4ce6aa8ba475
MOVER ./testflags/BuildUVMPkg  patched=3fb5e3995d0c pristine=6c539800206a
MOVER ./testflags/SeqDriver    patched=46201cb69054 pristine=cb4cf67e822a
MOVER ./testflags/SimpleUVM    patched=f3cc6f67f6f6 pristine=651d47055e6a
```

`BuildUVMPkg`'s two row-modes are **byte-identical to each other** before
(`6c539800206a`) and after (`3fb5e3995d0c`) — the cross-mode identity the brief
asked about, preserved.

Heads, by `rowheads.sh` on the two workdirs:

| row | pristine cmp lines | patched cmp lines |
|---|---|---|
| `BuildUVMPkg` default | 29 | **19** |
| `BuildUVMPkg` testflags | 29 | **19** |

### Gate 5b — THE FIVE-ROW WALL, and it had to be measured the hard way

All three wall rows **DO move** under this pass (they carry uvm-1.2), so a line
count alone would have been worthless. `wall5.sh` re-runs `uhdm-cmp` on BOTH sides
and requires the cmp OUTPUT to be **byte-identical**:

```
SeqDriver    default   DB-MOVED  pris=1450011   patched=1450011   CMP-BYTE-IDENTICAL
SeqDriver    testflags DB-MOVED  pris=1450011   patched=1450011   CMP-BYTE-IDENTICAL
SimpleUVM    default   DB-MOVED  pris=1405511   patched=1405511   CMP-BYTE-IDENTICAL
SimpleUVM    testflags DB-MOVED  pris=1405511   patched=1405511   CMP-BYTE-IDENTICAL
Scoreboard   default   DB-MOVED  pris=1399779   patched=1399779   CMP-BYTE-IDENTICAL
Scoreboard   testflags NO-DB-BOTH-SIDES (SLANG_REJECT row; nothing to compare)
WALL HELD: every row's cmp output byte-identical
```

**1450011 / 1405511 / 1399779**, the exact pinned numbers, with the cmp text
identical byte for byte. The seven database movers are therefore all **PURE
below-the-head changes**: real, attributable, and invisible to every status the
harness records — which is exactly what the byte verifier exists to see.

---

## 5. THE CENSUS — artifact-based, order-blind, and it named the movers first

A throwaway build (`b0ddfa95ecba17e277cec9c59cc3e872`, built in
`build-census/`, the instrumentation reverted and the directory deleted before
the shipped binary was cut) logs one line per SUPPRESSED binding.
`maketsv.py` builds the argv list by **importing `verify_golden.py` itself**, so a
census can never run an argv the sweep would not have used; the resulting TSV is
**provably the same argv set** as r10buvm4's gate-verified one (0 differing rows
after normalising the corpus label and removing the four fenced names).
`censusrun.sh` replayed **3027 test-modes**.

The predicate fires in **NINE test-modes, corpus-wide, and nowhere else**:

| test-mode | suppressions | names |
|---|---|---|
| `BuildUVMPkg` default / testflags | 16 each | `ep`×6 `setting`×4 `req_item`×2 `param_t`×2 `orig_type_alias_per_inst`×2 |
| `SeqDriver` default / testflags | 20 each | `setting`×8 `t`×4 `req_item`×4 `param_t`×4 |
| `MiniAmiq` default / testflags | 20 each | (same four) |
| `SimpleUVM` default / testflags | 10 each | `setting`×4 `t`×2 `req_item`×2 `param_t`×2 |
| `Scoreboard` default | 10 | (same four) |
| **every other test-mode, both corpora** | **0** | — |

`BuildUVMPkg`'s 16 = exactly the **8 corpus sites decoded in §1.2 × 2 views**, which
is what makes the census a check on the decode rather than a restatement of it.

Nine hit test-modes, seven predicted movers: `MiniAmiq` (both modes) and
`Scoreboard/testflags` have hits but are `SLANG_REJECT` in the committed baseline
(no top-level modules / `use of undeclared identifier 'my_scoreboard'`), so they
produce **no database on either side** and cannot be byteverify movers. The gap
was stated in the prediction file before the verifier ran.

Six census test-modes exited 139. All six are rows the committed baseline already
records as `SLANG_REJECT` / `SURELOG_FAIL` (`Tnoc` both — `rc=-11` in the
baseline — `MiniAmiq` both, `Rggen`/`Earlgrey_0_1` testflags), the crash is in the
database writer AFTER emission, and the census file is written with `fflush` per
hit, so nothing is lost.

---

## 6. THE INSTRUMENTS I HAD TO FIX BEFORE I COULD USE THEM

### 6.1 `canaudit.sh`'s fence check called THE FENCE a FENCE-BREACH

Carried forward unchanged, it reported **`FENCE-BREACH=4`** for this directory. The
test was a bare `grep -rl`: any mention of a fenced name in any driver is a
breach. But `censusrun.sh` and `maketsv.py` have to NAME the four fenced tests in
order to REFUSE to run them, so the guard flagged the guard. An instrument that
reports the safety mechanism as the violation gets silenced by the next author —
the campaign's own "cited guard" failure mode, pointing the other way.

The corrected rule is auditable: **an exclusion list is exhaustive.** A LINE that
names ALL FOUR fenced tests is a fence; a line naming SOME of them is a dispatch
(or a fence with a hole) and is a breach. Two negative controls now run every time:

```
  UnsignedParam          not dispatched by any driver (OK)
  HierPathEval           not dispatched by any driver (OK)
  FileLocalParam         not dispatched by any driver (OK)
  TopParam               not dispatched by any driver (OK)
  SELF-TEST: planted one-name dispatch REPORTED (guard is live)
  SELF-TEST: a full four-name EXCLUSION is not a breach (no false alarm)
---- audited=29  UNCOVERED=0  FENCE-BREACH=0
```

### 6.2 `wall5.sh` called a documented `SLANG_REJECT` row FATAL

First version printed `FATAL-MISSING` for `Scoreboard/testflags`, which has no
`slang.uhdm` on EITHER side because it is `SLANG_REJECT` in the committed
baseline. Same disease. It now separates **NO-DB-BOTH-SIDES** (expected, not
counted) from **FATAL-ASYMMETRY** (one side has a database and the other does not
— which IS a regression and is exactly what a blanket "missing" verdict would have
hidden).

---

## 7. THE NEW HEAD (R0) — for the next pass

`BuildUVMPkg`, **both modes**, **19** cmp lines, cross-mode byte-identical, and it
is the OTHER direction from this pass's head — an object **golden has and we do
NOT** (`RHS: <null>`):

```
LHS golden: constant id:6934, line:12983:53, endln:12983:54
            |vpiParent: bit_select
                        (uvm_pkg::uvm_default_factory::find_override_by_name::matched_overrides)
                        id:6935 @12983:53-12983:54
            |vpiDecompile:$   |vpiSize:1   |STRING:$   |vpiConstType:10
RHS ours  : <null>
```

`uvm_pkg.sv:12983` is inside `find_override_by_name`, and the object is the
**`$` of a queue bound** — golden materialises `matched_overrides[$]` as a
`bit_select` whose index is a `constant` of `vpiConstType:10` with the literal
STRING `$`, and we emit no index object at all. A CONSTANT/SELECT question, a
different family again from both this pass's and pass 4's.

---

## 8. DELIVERY

`/tmp/r10buvm5.patch` = `git diff 9f45cc0`, 2139 lines, 21 files, surface =
**`include/UhdmExporter.h` + `src/ExprEmit.cpp` + `src/StmtEmit.cpp` +
`tools/probe/r10buvm5repro/` and nothing else** — checked mechanically
(`git diff 9f45cc0 --name-only` filtered against that surface is EMPTY). The
README is INSIDE the patch, so the patch cannot state its own md5; it is in the
delivery message.

* `git apply --check` **clean on a FRESH `9f45cc0` worktree**.
* `git apply --check` **clean on the current branch head `4df4bab`** (r10ladder1,
  the one commit that landed since my base) — and **NO COLLISION**: that commit
  touches **zero** production files (`git diff --stat 9f45cc0 4df4bab -- src
  include` is empty), so nothing it added can conflict with the three files here.
* **ROUND-TRIP**: applying to a fresh `9f45cc0` and re-`git diff`ing regenerates
  a patch with the **same md5**.

Reproduce the decode from scratch:

```sh
cd tools/probe/r10buvm5repro
SLANG_UHDM=<build>/slang-uhdm ./ct5arm.sh a1_refvarbind.sv /tmp/a1
SLANG_UHDM=<build>/slang-uhdm ./ct5arm.sh a2_windowgrid.sv /tmp/a2
diff <(python3 pop.py /tmp/a2/g.dump) <(python3 pop.py /tmp/a2/o.dump)   # EMPTY
diff <(python3 pop.py /tmp/a1/g.dump) <(python3 pop.py /tmp/a1/o.dump)   # R1 only
```

---

# ADVERSARIAL VERIFIER PASS (vbuvm5) — VERDICT: **REPRODUCED, THEN BROKEN, THEN FIXED**

Everything above is the implementer's report. This section is the verifier's, and
it changes the patch: the shipped `§ refVarLocalWindowBinds5` created **22
measured pristine-RIGHT → patched-WRONG cells on legal SystemVerilog**, which the
implementer's `ZERO pristine-right → patched-wrong` claim missed because both of
their arms stop at the `if`/`case` **condition** and neither of them puts a
select on a `ref_var`. The law is right; its **window set was two-thirds short**
and one line of bookkeeping was moved that must not move.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours, in every table here.

## V-1. What reproduced, bit for bit

Both binaries were rebuilt from scratch in the verifier's own worktrees
(`/tmp/wt_vbuvm5pris`, `/tmp/wt_vbuvm5`), `-j 2`, `error:` = 0, link = 1,
`Built target slang_uhdm` = 2:

| binary | md5 | agrees with |
|---|---|---|
| pristine `9f45cc0` | `4220e4f818406b3c91323967eb59db89` | implementer's CONTROL **and** the main-tree binary |
| as-shipped patch | `dff63b97f02fb845b49c8f91de6c2a12` | implementer's SHIPPED |
| **V-FIXED (this section)** | **`be0b2f938bd21347c97432c5c57aacdd`** | — |

Reproduced independently and exactly: patch md5 `215847e15403d29807d63a0ec84acb3a`
and its round-trip; `BuildUVMPkg` **29 → 19** cmp lines in both modes with ONE
head, the old head and the new head R0 **verbatim**, cross-mode byte-identical
before and after; the corpus `ref_obj → ref_var` census **golden 45 / pristine 61
/ patched 45**; the span-keyed block census `diff` **EMPTY** (so the brief's
declaration/scope diagnosis really is refuted, and the differing object really is
the argument `ref_obj`@12766:34 whose `vpiActual` we added and golden has not);
goldens **23/0** with `/bin/false` **0/23**; u2r **679/50/2** per mode; surelog
**469/11/5/284/25** default and **465/8/5/3/1/286/23/1/2** testflags with
`GOLDEN_DEFER` `[UNSET]`; ct8rows **0 differing rows** five ways (pristine-vs-
committed FIRST, patched-vs-committed, patched-vs-pristine, both corpora);
byteverify **0/1358** u2r and **7/953** surelog, the same seven rows BY NAME;
wall **1450011 / 1405511 / 1399779** with byte-identical cmp text; `canaudit`
**audited=29 UNCOVERED=0 FENCE-BREACH=0** with both self-tests live; every canary
byte-identical including **SVSwitch `4842211c4030`** in both modes.

Two numbers in the implementer's report are run-artefacts, not errors, and both
are named in V-5.

## V-2. THE 22 REGRESSIONS — `vfix5cells.sh` + arms `v1`…`v5`

Five new arms, 80 golden cells, all out-of-body methods (the corpus population),
scored FOUR ways — golden | pristine | as-shipped | V-FIXED:

```
TOTAL rows measured                : 80
pristine-RIGHT -> AS-SHIPPED-WRONG : 22
pristine-RIGHT -> V-FIXED-WRONG    : 0
wrong -> right   as-shipped=22   V-FIXED=22
```

The as-shipped patch is therefore **22 right and 22 wrong**; the V-fix is **22
right and 0 wrong**. Two negative controls run every time: the pristine column
scored against itself (0/0, so the PASS line cannot be earned by a broken
comparator), and an explicit `ATTENTION` when the fixed column fixes nothing (so
it cannot be earned by inaction). Planting the as-shipped binary in the V-FIXED
column makes the script report 22 and FAIL.

### V-2.1 The window set is SIX sites, not three (20 of the 22)

Golden's binding window for a `ref_var` local is not "the three places
StmtEmit.cpp clears `classMethodNoBind`". Measured, same depth as the
declaration unless noted:

| position | arm cells | golden | as-shipped |
|---|---|---|---|
| `case` ITEM EXPRESSION | v1 k16, v3 w01 ×2 | **BIND** | bare ✗ |
| `casex` / `casez` / `unique case` item | v3 w02/w03/w04 | **BIND** | bare ✗ |
| case item that is an OPERATION `(uw+1)` | v3 w13 | **BIND** | bare ✗ |
| case item, decl in that same block (d1==d1) | v3 w06, v5 z09 | **BIND** | bare ✗ |
| immediate `assert` / `assume` / `cover` cond | v4 y01/y02/y03, v5 z07/z08 | **BIND** | bare ✗ |
| assertion cond, decl in that same block | v4 y05 | **BIND** | bare ✗ |
| EVENT CONTROL `@(v)` / `@(posedge v)` | v5 z01/z04 | **BIND** | bare ✗ |
| event control, decl in that same block | v5 z03 | **BIND** | bare ✗ |

and the **depth half of the law is untouched** — every one-body-deeper twin is
golden-bare and stayed bare: v3 w05 (case one deeper), v5 z05 (two deeper),
v4 y04 (assert one deeper), v5 z06 (assert in a `for` body), v4 y10 (assert in a
case ITEM), v5 z02 (event control one deeper).

**`case … inside` is the discriminator that keeps the window from being "any case
item".** v4 y06 69:7 reads a `ref_var` from a `case (vy) inside` item member at
d0==d0 and golden leaves it **BARE**, where the plain/x/z/unique spellings all
bind. Surelog compiles the inside-item list through a different path, and the fix
raises the window in the non-`Inside` arm only — which is why the two arms of that
`if` are gated separately rather than together.

### V-2.2 THE STRUCTURAL ONE — `selWholeWrittenVars` (2 of the 22)

The patch did not only skip `ref->Actual_group(...)`; it moved the
`selWholeRefs` **and** `selWholeWrittenVars` registration inside the same `if`.
`selWholeWrittenVars` is **not a record of the reference** — it is the
source-level fact *"this VARIABLE is also written whole"*, and `endSelTrack`
reads it to decide what **OTHER, still-bound** references to the same variable
re-point to. Silencing the insert made an assignment-LHS whole write invisible,
the constant-bounds part-select carve-out stopped firing, and a correctly-bound
window reference got re-pointed at the `part_select`. Arm v2, `bs = 8'h00;` next
to `bs[3:0] = 4'hf;`:

| cell | golden | pristine | as-shipped | V-FIXED |
|---|---|---|---|---|
| s01 37:12 `isinks(bs)` call arg | `ref_var` | `ref_var` | **`part_select`** ✗ | `ref_var` ✓ |
| s05 70:9 `if (bs == 8'h0f)` | `ref_var` | `ref_var` | **`part_select`** ✗ | `ref_var` ✓ |

`selWholeRefs.push_back` stays **inside** the suppression, deliberately: queuing a
suppressed reference would let `endSelTrack` hand it an actual again, and it fixes
nothing measured (arm v2's four remaining rows are wrong on BOTH binaries — see
residue R-SEL).

## V-3. THE V-FIX — 4 hunks, same three production files

* `src/ExprEmit.cpp` — `bool bind5 = !refVarLocalNoBind5(...)`; `Actual_group`
  and `selWholeRefs` are gated on it, `selWholeWrittenVars` is not.
* `src/StmtEmit.cpp` — `CondWindow5` at three more places: the non-`Inside`
  case-item expression loop (SITE 4), the three immediate-assertion conditions
  (SITE 5), the event-control expression (SITE 6).
* `include/UhdmExporter.h` — the law text now states the six sites and the four
  measured NON-windows (`while`/`for`/`do-while`, `wait`, `case … inside` item,
  `return`).

`condBindDepth5` still has **exactly one reader** (`refVarLocalNoBind5`), checked
mechanically, so widening it cannot reach any other law.

## V-4. THE V-FIXED BINARY'S OWN GATES — all five, plus the boundaries

1. build `-j 2`, `error:`=0, link=1, `Built target slang_uhdm`=2, md5
   `be0b2f938bd21347c97432c5c57aacdd`; a comment-only re-edit rebuilt to the
   SAME md5, so shipped source ≡ measured binary.
2. goldens **23/0**; `/bin/false` **0/23**.
3. u2r **679/50/2** per mode; ct8rows **0 differing rows** vs committed
   (testflags) and vs pristine (1462 rows, both modes).
4. surelog **0 differing rows** vs committed (1588) **and vs the as-shipped
   CSV**; 5 `DEFERRED` per mode, `GOLDEN_DEFER` `[UNSET]`; canaries
   `ok=52 changed=0 absent=0`, ctcan2 `ok=58 changed=0`; **SVSwitch pinned at
   `4842211c4030`**, InterfaceModPort `59a365f3ce2c`, BlackParrotComplex
   `e3e354129d5a`/`73a10e8217e5`, YosysOldOr `d68e0796d62c` — byte-identical
   across pristine, as-shipped and V-FIXED.
5. byteverify `SELFCHECK=1 SELFCHECK1=1`: u2r **0/1358**; surelog **7/953**, the
   same seven rows by name, and **six of the seven patched hashes bit-identical
   to the as-shipped run** (`BuildUVMPkg` ×2 `3fb5e3995d0c`, `SeqDriver/default`
   `835f4aa3cefc`, `SimpleUVM` `93f10f2ffe72`/`f3cc6f67f6f6`,
   `SeqDriver/testflags` `9c299bda0585`). The seventh is `Scoreboard/default`,
   attributed in V-5. **Wall: 1450011 / 1405511 / 1399779, cmp text
   byte-identical.** `BuildUVMPkg` heads **19** lines both modes, cmp text
   **byte-identical to the as-shipped one**, and the corpus census back to
   **45 = golden**.

**BOUNDARIES, all byte-identical pristine ↔ V-FIXED** (dumps normalised for the
embedded workdir path): sd10 grid **9/9 cells KINDS IDENTICAL**; sd12 grid
**5/5 cells identical**; buvm3 arms `a1_member` `a2_kindgrid` `a3_overfire`
`v1_tdorder` **0 diff lines each**; buvm4 arms `a1_namedargs` `a2_kindgrid`
`a3_linkgrid` **0 each**; and all **47** uvm77–81 arm cells **0**. Not one cell
outside the law's own window positions moved.

## V-5. THE TWO RUN-ARTEFACTS IN THE IMPLEMENTER'S NUMBERS

* **`testflags/SeqDriver`'s mover hashes.** Implementer: `patched=46201cb69054
  pristine=cb4cf67e822a`. Verifier, same corpus, same two binaries (md5-identical
  to theirs): `9c299bda0585` / `947dca184fcd`. **BOTH sides differ**, so this is
  not an attribution error — it is the campaign's known emitter nondeterminism,
  and a per-row hash is not a reproducible quantity.
* **`Scoreboard/default` is nondeterministic ON THE PRISTINE BASE COMMIT.**
  `detcheck.sh`, 4 runs each, same input, same cwd:

  | binary | distinct hashes / 4 | bytes |
  |---|---|---|
  | pristine `4220e4f8…` | **2** | 11144945 |
  | as-shipped `dff63b97…` | **3** | 11144858 |
  | V-FIXED `be0b2f29…` | **2** | 11144858 |

  As-shipped and V-FIXED both produced hash `a54ca75020769940` at the same byte
  size — **positive proof by shared hash** that the V-fix does not change that
  database, which is the only honest way to clear the one byteverify mover
  between them. It also means the seven-mover list must be read as seven ROWS,
  never as seven hashes.

## V-6. RESIDUES the V-fix deliberately does NOT touch

* **R-SEL (new, ranked FIRST).** With a select on the same `ref_var`, golden
  binds the **select object** in positions this law calls bare: v2 s01 35:5 and
  s04 62:10 are golden `part_select`, s03 50:5 golden `indexed_part_select`, and
  both binaries are wrong there (pristine `ref_var`, ours bare). Also v2 s02
  44:12: with NO whole write, golden keeps `ref_var` and both binaries re-point
  to the `part_select`. Four cells, one family — `endSelTrack`'s carve-out is the
  next thing to decode, and it is a bigger population than R1.
* **R-ARG.** `classArgBindDepth12` over-fires in an **assignment-RHS** call
  argument: v3 w12 146:14 `mw = fnw(vw)` is golden BARE and both binaries bind —
  golden's argument window is STATEMENT-position calls only, exactly as
  § classInBodyBareCallArgStmtOnly53 already says for the in-body law.
* **R-TIMED.** v5 z10 117:24 `#1 numsz.push_back(vz == 0);` is golden BARE while
  the identical statement without the `#1` binds (a2 b06) — a `Timed`
  statement's body behaves like a control body for golden and our
  `ctrlBodyDepth28` does not count it.
* **R1 is NARROWER than the implementer stated.** Their R1 says a user call
  nested inside a condition is golden-bare. v3 w08 114:13 `if (fnw(vw) == 0)`, a
  BARE user function call in a condition, is golden **BIND** and we bind it. The
  bare-call spelling is not the residue; only the **receiver-qualified** call
  (`port5.try5(v5)`, `m_req_fifo.try_put`) is — which is also the only spelling
  whose argument golden re-NAMES.
* **R2 / R3** stand as written, unchanged and unreachable by this predicate.

## V-7. REPRODUCE

```sh
cd tools/probe/r10buvm5repro
PRIS=<pristine>/slang-uhdm SHIP=<as-shipped>/slang-uhdm FIX=<v-fixed>/slang-uhdm \
  ./vfix5cells.sh                       # 80 cells, 22 / 0, both self-tests
SLANG_UHDM=<v-fixed>/slang-uhdm ./ct5arm.sh a2_windowgrid.sv /tmp/a2
diff <(python3 pop.py /tmp/a2/g.dump) <(python3 pop.py /tmp/a2/o.dump)   # still EMPTY
```
