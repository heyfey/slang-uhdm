# r10uvm69 — § retNameRecvCollapse69: THE HEAD IS CLEARED ON ALL THREE TARGET ROWS, and the brief's expected law is REFUTED IN BOTH DIRECTIONS

**FIRST LINE, as the brief demands: the head DID clear.** The
`LHS: func_call (open_recorder) / RHS: method_func_call (m_do_open)` head is gone
from SimpleUVM (both modes) and Scoreboard (default), and each of those three
rows falls **112 → 54 cmp lines**. The whole call-SHAPE disagreement family on
SimpleUVM goes **7 cells → 0**. No row converts — all four UVM rows stay
`CMP_NOTEQUAL` — and every gate reads 0 differing rows against the committed
baselines.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`~/.local/bin/uhdm-cmp` and every driver here passes `(golden.uhdm, ours.uhdm)`
in that order.

Base commit **6e1c27a**, branch `auto5h`, own worktree
`.claude/worktrees/r10uvm69` with a PRISTINE 6e1c27a twin at
`.claude/worktrees/r10uvm69pris` built from source in this pass.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 6e1c27a) | `f1fee994fffdfc1e2d7883d791e1621f` | **byte-identical to the main-tree `build/slang-uhdm`**, which is what makes it a valid control |
| FINAL (gated, shipped) | `3088f565cd6b93c67c8f85441a3e79fc` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **read only**; row counts come
from `ct8rows.sh`'s lines-minus-one, never from `wc -l`.

---

## 0. THE LAW, in the form a future pass can grep for

ONE § marker, ONE predicate, TWO call sites
(`grep -n 'retNameRecvCollapse69' src include`):

### § retNameRecvCollapse69

> **When a method call is written `<r>.<m>(args)` and `<r>` names the ENCLOSING
> function's own implicit RETURN VARIABLE, Surelog resolves the receiver to THE
> FUNCTION and swallows the method.** It emits a plain `func_call` **named
> `<r>`**, spanning the **whole call expression**, carrying
> `vpiFunction` → **the enclosing function itself** and the METHOD's arguments
> as its own `vpiArgument` children. The method name appears NOWHERE.
>
> This happens **IF AND ONLY IF**
> **(a)** the call is in **STATEMENT position**, and
> **(b)** the enclosing function is **NOT a class OUT-OF-BODY method**.
>
> In EXPRESSION position, or inside an out-of-body method body, the ordinary
> method shape is kept.

Mechanism: Surelog's `compileTfCall` resolves a dotted invocation **by its FIRST
identifier**; inside a function the implicit return variable shares the
function's name, so the lookup lands on the FUNCTION object and the call is
compiled as a call to it.

**STATED GATE == CODE GATE.** The stated gate is
`(receiver is exactly the return-variable NamedValue) && stmtCtx && !out-of-body`.
The code gate is `UhdmExporter::retNameRecvCollapse69(recv, stmtCtx)`, whose
whole body is those three tests plus the structural requirement that the return
variable's parent scope IS a `Subroutine` (without it there is no function to
name the call after). There is no fourth clause anywhere, and both call sites
call the same function — neither re-implements it.

**Sites** — `src/ExprEmit.cpp` (the predicate + its decode; the USER
class-method arm at § deepRecvCall11's entry; the BUILT-IN method arm it
narrows), `include/UhdmExporter.h` (the declaration). **DIRECTION: BOTH.** This
pass ADDS a collapse the user-method path never had and REMOVES one the built-in
path was making too widely — see §2.

---

## 1. THE CENSUS THAT REFUTED THE BRIEF, both sides, span-keyed, BEFORE any code

`callcen.cpp` lists **every** `func_call` / `method_func_call` / `task_call` /
`method_task_call` object in a database (via `Serializer::AllObjects()`, so it is
an OBJECT census and not a dump-occurrence count) with its name, span, argument
spans, prefix, `vpiFunction` target and enclosing routine. `calljoin.py` joins
two censuses.

**THE PAIRING KEY IS THE ARGUMENT SPANS, NOT THE CALL'S OWN SPAN.** Golden's
`func_call` for the head spans 343:13-343:61 (from the RECEIVER token) while ours
spans 343:27-343:36 (the METHOD token). A key built on the call's own start pairs
NOTHING and would report every cell as "golden-only + ours-only" — the add+drop
artefact this campaign keeps paying for. Both sides carry the identical three
`vpiArgument` children at 343:37 / 343:43 / 343:51, so the argument-span key
pairs them exactly and is blind to the shape being measured.

SimpleUVM, control, golden vs ours — **7 SHAPE-disagreeing cells**, and they run
in **BOTH DIRECTIONS**:

| line | written source | position | enclosing routine | GOLDEN | OURS | direction |
|---|---|---|---|---|---|---|
| 343 | `open_recorder.m_do_open(this, m_time, type_name);` | stmt | `uvm_tr_stream::open_recorder` (IN-BODY) | `func_call open_recorder` | `method_func_call m_do_open` | **we UNDER-collapse** ← THE HEAD |
| 157 | `open_stream.m_do_open(this, scope, type_name);` | stmt | `uvm_tr_database::open_stream` (IN-BODY) | `func_call open_stream` | `method_func_call m_do_open` | we UNDER-collapse |
| 946 | `create_item.set_item_context(this, l_sequencer);` | stmt | `uvm_sequence_base::create_item` (IN-BODY) | `func_call create_item` | `method_func_call set_item_context` | we UNDER-collapse |
| 992 | `index_string.itoa(index);` | **stmt** | `uvm_printer::index_string` (**OUT-OF-BODY**) | `method_func_call itoa` | `func_call index_string` | **we OVER-collapse** |
| 357 | `uvm_instance_scope = uvm_instance_scope.substr(0,pos);` | **expr** | `uvm_instance_scope` (package free fn) | `method_func_call substr` | `func_call uvm_instance_scope` | we OVER-collapse |
| 351 | `pos = uvm_instance_scope.len()-1;` | **expr** | `uvm_instance_scope` (package free fn) | `method_func_call len` | `func_call uvm_instance_scope` | we OVER-collapse |

(the 7th SHAPE cell is 357/992 counted twice, once per listing view.)

BuildUVMPkg adds three more UNDER-collapse cells of the same shape —
`get_link.set(lhs, rhs);` in `uvm_parent_child_link` / `uvm_cause_effect_link` /
`uvm_related_link` — and its own `itoa` / `substr` OVER-collapses. SeqDriver
carries the SimpleUVM set plus its `adpcm_pkg` clones.

### 1.1 The brief's expected law, quoted and REFUTED

The brief says:

> "when the receiver of a method call is spelled with the enclosing function's
> (return variable's) name, Surelog RESOLVES THE RECEIVER TO THE FUNCTION and
> emits a func_call named by it, swallowing the method."

**That is true of only 4 of the 7 corpus cells.** Cells 992, 357 and 351 are
receivers spelled with the enclosing function's return-variable name where golden
does **NOT** collapse. Implemented as stated, the law would have been an ADD-only
change that left three corpus over-collapses in place and moved nothing on
`uvm_instance_scope` — and, worse, an implementer who "fixed" the user path to
match the built-in path would have propagated the built-in path's own defect.
**The pre-existing built-in arm was already wrong on this corpus in the opposite
direction, and nothing in the brief suggested looking at it.**

---

## 2. THE PASS'S OWN FIRST LAW, ALSO REFUTED — the `string` hypothesis

After the census, the population fit a **type** law exactly:

| receiver type | corpus cells | golden |
|---|---|---|
| class handle (`m_do_open`, `set_item_context`, `set`) | 6 | COLLAPSE |
| queue (`myFunc1.push_back`, CrossFunc) | 1 | COLLAPSE |
| **string** (`itoa`, `substr`, `len`) | 3 | **KEEP** |

Every string cell in the corpus uses a string built-in, so "the type is `string`"
and "the method is a string built-in" fit **identically**, and both fit all 10
cells. `a1_type.sv` was built to grid the type axis — and it **destroyed the
hypothesis on its first run**: at package-free-function scope golden collapses
`f_str_stmt.itoa(i);` (string!) and keeps `f_str_expr.substr(0,p)` (also
string!). The type never mattered; **POSITION** did.

That left ONE corpus cell contradicting a position-only law: `992`
`index_string.itoa(index);` is statement position and golden keeps it.
`a2_scope.sv` separates the two survivors on the two cells the corpus does not
contain:

| cell | scope | return type | position | (S) out-of-body predicts | (T) string predicts | GOLDEN MEASURED |
|---|---|---|---|---|---|---|
| **G2** `g_s_in.itoa(n);` | class **IN-BODY** | string | stmt | COLLAPSE | KEEP | **COLLAPSE** → (S) |
| **H1** `h_h_out.touch(n);` | class **OUT-OF-BODY** | class handle | stmt | KEEP | COLLAPSE | **KEEP** → (S) |

**(T) type-based: REFUTED. (S) out-of-body: CONFIRMED.** Two cells, one database,
opposite predictions — that is why the arm exists.

---

## 3. THE GRID, cell for cell, golden vs ours, CONTROL and FINAL

Three arms, one `.sv` each, built by `ct1arm.sh` and tabulated by
`gridcells.sh` (which re-reads golden from BOTH workdirs and **exits 4 if
golden differs between them** — golden cannot move between our builds, and a
table that silently compared two different arms would be void).

### 3.1 `a1_type.sv` — THE RETURN-TYPE AXIS (14 differing → **0**)

Every cell is a method call on the enclosing function's return variable, at
package-free-function scope.

| cell | receiver type | method | position | GOLDEN | OURS CONTROL | OURS FINAL |
|---|---|---|---|---|---|---|
| A1 `f_str_stmt.itoa(i);` | string | built-in | stmt | COLLAPSE | COLLAPSE | agree |
| A2 `= f_str_expr.substr(0,p)` | string | built-in | expr | KEEP | **COLLAPSE** | agree |
| A4 `= f_str_len2.len()-1` | string | built-in | expr | KEEP | **COLLAPSE** | agree |
| B1 `f_q_stmt.push_back(n);` | queue | built-in | stmt | COLLAPSE | COLLAPSE | agree |
| B3 `= f_q_expr2.size()` | queue | built-in | expr | KEEP | **COLLAPSE** | agree |
| C1 `f_d_stmt.delete();` | dyn array | built-in | stmt | COLLAPSE | COLLAPSE | agree |
| C2 `= f_d_expr.size()` | dyn array | built-in | expr | KEEP | **COLLAPSE** | agree |
| D1 `f_a_stmt.delete("k");` | assoc array | built-in | stmt | COLLAPSE | COLLAPSE | agree |
| D2 `= f_a_expr.num()` | assoc array | built-in | expr | KEEP | **COLLAPSE** | agree |
| E1 `f_c_stmt.touch(n);` | class handle | **user** | stmt | COLLAPSE | **KEEP** | agree |
| E2 `= f_c_expr.peek()` | class handle | user | expr | KEEP | KEEP | agree |
| F2 `= f_e_expr2.name()` | enum | built-in | expr | KEEP | **COLLAPSE** | agree |
| A3/B2/F1 (ordinary LOCAL receiver) | — | — | — | KEEP | KEEP | agree (CONTROL) |

**Golden's column depends only on POSITION — never on the type.** All six
receiver types collapse in statement position and keep in expression position.

### 3.2 `a2_scope.sv` — THE SCOPE × TYPE GRID, statement position (12 differing → **0**)

| cell | scope | return type | GOLDEN | OURS CONTROL | OURS FINAL |
|---|---|---|---|---|---|
| **G1** `g_h_in.touch(n);` | class IN-BODY | class handle | **COLLAPSE** | KEEP | agree |
| **G2** `g_s_in.itoa(n);` | class IN-BODY | string | **COLLAPSE** | COLLAPSE | agree |
| **H1** `h_h_out.touch(n);` | class OUT-OF-BODY | class handle | **KEEP** | KEEP | agree |
| **H2** `h_s_out.itoa(n);` | class OUT-OF-BODY | string | **KEEP** | COLLAPSE | agree |
| J1 `j_h_free.touch(n);` | package free fn | class handle | COLLAPSE | KEEP | agree |
| J2 `j_s_free.itoa(n);` | package free fn | string | COLLAPSE | COLLAPSE | agree |
| K1 `k_h_mod.touch(n);` | module fn | class handle | COLLAPSE | KEEP | agree |
| K2 `k_s_mod.itoa(n);` | module fn | string | COLLAPSE | COLLAPSE | agree |
| G4/G5/H3/H4 (expression twins) | all four scopes | both | KEEP | mixed | agree |

G1 is the HEAD's exact shape in miniature; H2 is cell 992's. **The boundary is
in-body vs out-of-body, exactly as § classMethodRetNameNoBind56 found for a
different field on the same family — but with the OPPOSITE sense**, which is why
this pass could not reuse that law's gate and says so in the code.

### 3.3 `a3_recv.sv` — THE OVER-FIRE GUARD (5 differing → **2**, both the known residue)

Every receiver kind that is NOT the return variable, in the statement position
where the collapse is active:

| cell | receiver | GOLDEN | OURS CONTROL | OURS FINAL |
|---|---|---|---|---|
| N1 | ordinary body local | KEEP | KEEP | **agree** |
| N2 | formal argument | KEEP | KEEP | **agree** |
| N3 | local NAMED after another function | KEEP | KEEP | **agree** |
| N4 | class property | KEEP | KEEP | **agree** |
| N5 | `this.`-rooted property | KEEP | KEEP | **agree** |
| N7 | return name as an ARGUMENT of another call | KEEP | KEEP | **agree** |
| Q1 | the return variable (POSITIVE control) | COLLAPSE | KEEP | **agree** |
| P1 | parens-less `p_noparens.len` | (no call object) | **`func_call`** | **agree** |
| **N6** | **CHAINED `n_chain.inner.touch(n);`** | COLLAPSE (arg-less) | KEEP | **KEEP — residue R1** |

**P1 is a boundary repair, not a boundary breach.** The parens-less form belongs
to § parensLessCallIsPathRefObj / § parensLessFuncRefIsRefObj (r10svs2), which
emit a path/ref_obj and no call object at all. The pre-existing built-in arm was
collapsing it into a `func_call` — reaching INTO r10svs2's territory. The
position gate removes that object and the cell now agrees. **No r10svs2 driver
names were touched and no fenced name is driven by this pass.**

---

## 4. WHAT CHANGED IN THE CODE, and why it is TWO directions in ONE predicate

| site | before | after |
|---|---|---|
| BUILT-IN method arm (`stmtCtx` path) | fired on "receiver is the return variable", **no position gate, no out-of-body gate** | calls `retNameRecvCollapse69(recv, stmtCtx)` |
| USER class-method arm (§ deepRecvCall11 entry) | **never collapsed at all** | calls `retNameRecvCollapse69(recv0, callStmtCtx0)` |

The user arm takes its receiver from `call.thisClass()` (not `arguments()[0]`),
its arguments through `writtenArgs16(call)` (a DEFAULTED formal is not written and
Surelog does not list it), and its span from `callRng11` so the no-argument
spelling still runs through the closing paren (§ callParenSpan11). Those three
are the only differences between the two arms' bodies.

`curSubOob9` and `funcRetSym` are both saved/restored around subroutine-body
emission at the same place (`TaskFuncEmit.cpp`), so the predicate reads a
consistent pair for every call in a body. `stmtCtx` / `callStmtCtx0` are each the
call's OWN captured flag, never the member `callStmtContext`, which is cleared
early — the trap already documented at two other sites in this file.

---

## 5. NARROWNESS: what this law deliberately does NOT do

**The receiver must be EXACTLY the return name.** A CHAINED receiver whose first
segment is the return name (`n_chain.inner.touch(n);`) **also collapses in
golden**, but to a **different object** — an ARGUMENT-LESS `func_call`, because
Surelog's `compileTfCall` reads only the first two names and drops the argument
list that belongs to the last. It has **zero corpus population** (no such cell in
any of the four UVM tests), so it is left to § deepRecvCall11 and ranked R1. The
`NamedValue` test in the predicate excludes it **structurally**, not by comment:
a chained receiver is a `MemberAccessExpression` and can never reach the arm.

---

## 6. THE FIVE GATES, each with the number measured on the FINAL binary

### GATE 1 — BUILD

`cmake --build build -j 4` → `[100%] Linking CXX executable slang-uhdm` /
`[100%] Built target slang_uhdm`. Then, in a SEPARATE command before any sweep:

```
f1fee994fffdfc1e2d7883d791e1621f  …/r10uvm69pris/build/slang-uhdm
3088f565cd6b93c67c8f85441a3e79fc  …/r10uvm69/build/slang-uhdm
OK: BINARY md5 CHANGED f1fee994fffdfc1e2d7883d791e1621f -> 3088f565cd6b93c67c8f85441a3e79fc
32-hex OK
```

The control's validity anchor, printed before any edit: the pristine worktree
build and the main-tree `build/slang-uhdm` were BOTH
`f1fee994fffdfc1e2d7883d791e1621f`.

### GATE 2 — GOLDENS

`tests/check_goldens.sh` on the FINAL binary: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the control
fires.

### GATE 3 — uhdm2rtlil, `testflags`, `--jobs 2`

**679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump column
**496 match / 183 differ / 52 blank**. WHOLE-ROW judge against the committed
baseline (`ct8rows.sh`):

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both`, `--jobs 2`

`default` **469 CMP_EQUAL / 11 CMP_NOTEQUAL** / 5 DEFERRED / 284 SLANG_REJECT /
25 SURELOG_FAIL; `testflags` **465 CMP_EQUAL / 8 CMP_NOTEQUAL** / 5 DEFERRED /
286 SLANG_REJECT / 23 SURELOG_FAIL / 3 NO_DATABASE / 2 UNTRANSLATABLE /
1 TIMEOUT / 1 NO_UHDM. Dump column match 225 (default) / 165 (testflags).
Every figure equals the expected one. WHOLE-ROW judge:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` was left UNSET: the 5 memory-giant tests read `DEFERRED` in both
modes, exactly as the baseline does.

### GATE 5 — BYTE VERIFIER, both corpora, against the PRISTINE 6e1c27a workdir built in this pass

`SELFCHECK=1 SELFCHECK1=1 byteverify.sh <patched-wd> <pristine-wd>`:

```
uhdm2rtlil/testflags:
  databases: patched=679 pristine=679
  PATH_SETS_IDENTICAL (679 paths)
  MOVERS: 0 / 679
  SELFCHECK: 678 / 679 flagged        SELFCHECK1: 1

surelog/both:
  databases: patched=953 pristine=953
  PATH_SETS_IDENTICAL (953 paths)
  MOVERS: 7 / 953
  SELFCHECK: 952 / 953 flagged        SELFCHECK1: 8
```

**0 movers on uhdm2rtlil, 7 on surelog**, both negative controls firing on both
corpora (SELFCHECK1's 8 = the 7 real movers plus the corrupted one).

#### 6.5.1 THE MOVERS WERE PREDICTED BY NAME BEFORE THE SWEEP RAN

The census predicted **exactly the 7 UVM databases** (Scoreboard/testflags is
`SLANG_REJECT` and has no database). The sweep produced exactly those 7 and
nothing else.

#### 6.5.2 EVERY MOVER PROVED **REAL** BY SIZE-DELTA, NOT BY HASH INEQUALITY

**This check is not a formality and it nearly changed the reading.** `detcheck.sh`
on Scoreboard/default gives **3 distinct hashes in 3 runs on BOTH binaries** —
the pre-existing emitter nondeterminism already on record in MEMORY.md. A mover
list built on hash inequality alone would therefore be partly meaningless. Under
the standing law (*same-size = flake, size-delta = real*):

| binary | Scoreboard/default, 3 reps | bytes |
|---|---|---|
| PRISTINE | 3 distinct hashes | **11122738** (all three) |
| FINAL | 3 distinct hashes | **11122938** (all three) |

The size is STABLE within each binary and differs BETWEEN them, so the mover is
real and the nondeterminism is pre-existing and untouched. All seven:

| mover | patched | pristine | delta |
|---|---|---|---|
| default/SimpleUVM | 11118646 | 11118095 | **+551** |
| default/Scoreboard | 11122938 | 11122738 | **+200** |
| default/SeqDriver | 17962372 | 17960936 | **+1436** |
| default/BuildUVMPkg | 11097319 | 11097017 | **+302** |
| testflags/SimpleUVM | 11118958 | 11118485 | **+473** |
| testflags/SeqDriver | 17962804 | 17961341 | **+1463** |
| testflags/BuildUVMPkg | 11097319 | 11097017 | **+302** |

**No mover has delta 0** — none is a flake.

#### 6.5.3 MOVERS PER-SHAPE vs GOLDEN BY MULTISET, ADDED and REMOVED SEPARATELY

`mv1.sh` per mover. LHS is ALWAYS golden.

| mover | msdist pristine | msdist patched | **gain** | ADDED | REMOVED |
|---|---|---|---|---|---|
| default/SimpleUVM | 143682 | 143558 | **124** | 107 | 77 |
| default/Scoreboard | 134032 | 133908 | **124** | 107 | 77 |
| default/SeqDriver | 365900 | 365670 | **230** | 199 | 125 |
| default/BuildUVMPkg | 80324 | 80150 | **174** | 119 | 113 |
| testflags/SimpleUVM | 143678 | 143554 | **124** | 107 | 77 |
| testflags/SeqDriver | 365900 | 365670 | **230** | 199 | 125 |
| testflags/BuildUVMPkg | 80324 | 80150 | **174** | 119 | 113 |

**Every mover moves TOWARD golden; not one regresses.**

`mv1.sh` prints **ADD-ONLY FALSIFIED** on every mover, and that is **CORRECT and
EXPECTED here** — this pass is deliberately BI-DIRECTIONAL (it ADDS the
user-method collapse and REMOVES the built-in over-collapse), so a REMOVED
column of 77–125 is the law working, not a defect. A pass claiming add-only
would have been refuted by this instrument.

The added line TEXTS are exhaustively the law's own population, each with its
three-way count golden/pristine/patched showing **ours was BELOW golden and the
add closes the gap**: `create_item`, `open_recorder`, `open_stream`, `get_link`
(the collapses ADDED) and `itoa`, `substr`, `len`, `index_string`,
`uvm_instance_scope`, `uvm_instance_scope.len`, `uvm_instance_scope.substr`,
`pos` (the method shapes RESTORED), plus their `|vpiParent:` / `|vpiPrefix:` /
`|vpiFunction:` / `|vpiSize:64` child and edge lines. There is no unattributed
name on any mover.

### 6.6 CANARIES

| check | result |
|---|---|
| `r10uvm52repro/canaries.sh` (the brief's NAMED script), surelog | `ok=52 changed=0 absent=0` |
| `r10uvm52repro/canaries.sh`, u2r | `ok=8 changed=0 absent=0` |
| this dir's `canaries.sh` (37 names), surelog / u2r | `ok=52 / ok=8`, `changed=0 absent=0` |
| `ctcan2.sh` surelog, **EXPECT_UNKNOWN=1**, baseline FIRST | `ok=58 changed=0 absent=0 unknown-patterns=1` PASS |
| `ctcan2.sh` u2r, **EXPECT_UNKNOWN=6**, baseline FIRST | `ok=1 changed=0 absent=0 unknown-patterns=6` PASS |
| `canaudit.sh` (run on THIS dir's drivers) | `audited=29 UNCOVERED=0 FENCE-BREACH=0` |

BY NAME, both quoted from the CSVs:

```
InterfaceModPort    base: default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
InterfaceModPort    new : default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
BlackParrotComplex  base: default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
BlackParrotComplex  new : default,CMP_EQUAL,,,differ  testflags,CMP_EQUAL,,,differ
```

Both are `CMP_EQUAL/differ` rows, and a `differ` dump column is BLIND inside the
database (uvm56's F4). Gate 5 closes it: neither test is among the 7 movers, so
both databases are BYTE-IDENTICAL between pristine and patched in both modes.

The four SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by NO driver in this directory — asserted mechanically
by `canaudit.sh`, not by inspection.

---

## 7. THE HEAD, BEFORE AND AFTER

| row | control | final |
|---|---|---|
| SimpleUVM / default | **112** cmp lines, 1 head | **54**, 1 head |
| SimpleUVM / testflags | **112**, 1 head | **54**, 1 head |
| Scoreboard / default | **112**, 1 head | **54**, 1 head |
| BuildUVMPkg / both | 58 | 58 (its head is a different family) |
| SeqDriver / both | 1414861 | 1414877 |

The whole call-SHAPE family on SimpleUVM goes **7 cells → 0**
(`calljoin.py`: `agree` 10948 → 10957, `SHAPE` 7 → **0**).

**THE NEW HEAD on the three target rows is a DIFFERENT FAMILY** and this pass
does not touch it:

```
LHS: int_var: (uvm_pkg::uvm_tr_stream::get_recorders), line:371:13
     |vpiTypespec: ref_typespec -> |vpiActual: logic_typespec
     |vpiSigned:1
```

a return-variable TYPESPEC/`vpiSigned` cell — the
§ atomVarSignedWritten68 / § arrayVarSignedWritten8 family, not a call shape.

**SeqDriver's +16 cmp lines is HEAD DEPTH, NOT DISTANCE.** Its head is
UNCHANGED in identity — still `LHS: <null> / RHS: package uvm_pkg (uvm_pkg::)`,
the whole design-package slot — and a `<null>` head dumps an entire subtree, so
adding objects inside that subtree lengthens the print. The instrument that
measures distance says SeqDriver moved **230 closer** to golden. The campaign law
"the cmp line count is HEAD DEPTH ONLY, never a distance" is why this is reported
rather than alarmed at.

---

## 8. BOUNDARIES AND COLLISIONS

* **§ classMethodRetNameNoBind56 / § retNameNewLhsNoBind56** own return-name
  *binding* refusals. This pass changes no `Actual_group` and adds no bind: it
  changes the CALL SHAPE only, exactly as the brief predicted. Their family
  boundary (in-body vs out-of-body) turns out to govern this law too — **with the
  opposite sense** (they unbind IN-BODY; this pass collapses IN-BODY) — so the
  gate could not be shared and the code says so.
* **§ parensLessCallIsPathRefObj / § parensLessFuncRefIsRefObj** (r10svs2) own
  the parens discriminator. Arm cell P1 shows the pre-existing built-in arm was
  **reaching into** their territory, minting a `func_call` for a parens-less
  `p_noparens.len`; the position gate REMOVES that object and the cell now
  agrees with golden. This is a repair of an encroachment, not a new claim on
  the axis. No r10svs2 driver name is used by this pass.
* **§ invalidNewCallFromSyntax55** owns double-bind refusals on `new()`. The
  `method_func_call 'new'` objects are visible in every arm census here and are
  **untouched** on both sides in control and final alike.
* **§ deepRecvCall11** keeps the chained receiver — see residue R1.
* **COLLISION REPORT — r10sd2 (SeqDriver design-package slot), LIVE.** This pass
  moves BOTH SeqDriver databases (+1436 / +1463 bytes) and lengthens the
  SeqDriver cmp print by 16 lines, because r10sd2's head is the `<null>`
  design-package slot whose subtree now contains this pass's objects. **The head
  itself is unchanged in identity and the multiset distance improves by 230**,
  but r10sd2 will see a different byte baseline and should re-measure rather than
  compare against a pre-6e1c27a+r10uvm69 reading.
* **r10earl40 (Earlgrey var_select), LIVE** — no interaction: `Earlgrey_0_1` is a
  named canary, `changed=0`, and is not among the 7 movers, so its databases are
  byte-identical.

---

## 9. RANKED RESIDUES

**R1 — the CHAINED return-name receiver.** `n_chain.inner.touch(n);` (arm a3
cell N6): golden collapses it to an **ARGUMENT-LESS** `func_call n_chain`
spanning the whole statement; we keep `method_func_call inner` with the receiver
as prefix. The only differing cell left in a3 (2 diff lines = one cell). Direction
**REPLACE**. **Zero corpus population** across all four UVM tests, which is why
it was deliberately excluded rather than guessed at — implementing it means
producing an argument-less call object, a shape no corpus cell demands.
Belongs with § deepRecvCall11.

**R2 — the new head on the three target rows** (§7): the return variable's
`int_var` carries `vpiSigned:1` and a `ref_typespec` → `logic_typespec` where
golden differs. Highest-value next target on these rows; the
§ atomVarSignedWritten68 family already owns the predicate shape.

**R3 — SeqDriver's `<null>` design-package head** (1.41M cmp lines) is untouched
and dominates that row; it is r10sd2's live target.

**R4 — the 58 `NAME` cells** in the SimpleUVM call census (unchanged by this
pass, control and final alike): calls where both sides agree on the SHAPE and
disagree on the NAME. Untouched here because naming is context-dependent
(MEMORY.md's dead-end note) and none is a call-shape question.

**R5 — the `GONLY`/`OONLY` no-argument cells** (1944/1959 on SimpleUVM). These
are dominated by the census's own `NOARG` key falling back to the call's own
column, which cannot pair two different shapes; they are an INSTRUMENT
limitation, not a measured disagreement, and are labelled `NOARG` in the output
so no reader can mistake them for cells. Any future pass wanting them must give
`callcen.cpp` a better key for argument-less calls.

---

## 10. REFUTATIONS, stated plainly

1. **The brief's law is false as written** — "receiver spelled with the return
   variable's name ⇒ func_call" holds for only 4 of 7 corpus cells; 992, 357 and
   351 are counterexamples where golden keeps the method shape (§1.1).
2. **This pass's own first law — "the discriminator is the `string` type" — is
   false**, though it fits all 10 corpus cells exactly. Arm a1 kills it (golden
   collapses a `string` receiver at package scope) and arm a2 cell G2/H1 replaces
   it (§2).
3. **A position-only law is also false** — cell 992 is statement position and
   golden keeps it; the out-of-body gate is required (§2).
4. **The pre-existing built-in arm was wrong in the OPPOSITE direction from the
   head**, on the same corpus, and the brief did not point at it. A pass that had
   only implemented the brief would have left 3 corpus over-collapses standing
   and would have copied a defective arm into a second call path.
5. **`vpiMethod` — § classMethodRetNameNoBind56's discriminator — is NOT this
   law's discriminator.** It splits in-body from out-of-body for BINDING; here
   the same split governs SHAPE but with the opposite sense, so reusing the flag
   as-is would have inverted three corpus cells.
