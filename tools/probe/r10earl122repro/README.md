# r10earl122 — § `genCaPatTagDeepBind122` — **A KEYED ASSIGNMENT PATTERN'S OPERANDS ARE NOT ITS MEMBER VALUES: EVERY KEYED ITEM SITS UNDER A `tagged_pattern`, AND § `genCaOpDeepBindGenLocal20`'s BIND WALK — WHICH KNOWS `operation` AND `sys_func_call` AND NOTHING ELSE — STOPPED AT THE WRAPPER** — so the Earlgrey_0_1 **default** head `LHS: logic_var (…gen_host_fifo[0].shifted_id)` / `RHS: <null>` CLEARED (31 cmp lines → **0**), the row **CONVERTS `CMP_NOTEQUAL` → `CMP_EQUAL`**, on the exact next head r10earl121's R0 named

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY** and **NOT EDITED**.  `GOLDEN_DEFER` stayed
unset.  The four slang-fenced tests were never dispatched and are named only
inside `canaudit.sh`'s own `FENCED=` list, which `widerun122.sh` reads so the
boundary filter cannot drift from the audit.

> **ONE CORPUS ROW CONVERTS, AND IT IS THIS PASS'S TARGET — quoted in full:**
> ```
> < Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,   (results/golden_surelog.csv AND this pass's PRISTINE sweep)
> > Earlgrey_0_1,default,CMP_EQUAL,,,                (this pass's PATCHED sweep)
> ```
> The `default` status histogram moves `CMP_EQUAL 472 → 473`,
> `CMP_NOTEQUAL 9 → 8`.  The other 1587 rows of 1588 are byte-identical in
> status AND dump column.  **`results/*.csv` was not edited**; promoting the row
> is the integrator's step.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `a74e2df3` |
| pristine binary | md5 `4f5f59ff040bbe46f92e4222a881637e`, built from this pass's OWN worktree at a clean `a74e2df3` and frozen `chmod 555` before any sweep.  It was byte-identical to the main tree's `build/slang-uhdm` at the moment of freezing (the main tree was at `a74e2df3` then), and — the time-independent proof — a SECOND, untouched worktree of `a74e2df3` builds to the same md5 |
| patched binary (SHIPPED) | md5 `33a1b22b5ebba79ec34825031618deb7`, frozen `chmod 555`.  **REPRODUCED**: `/tmp/r10earl122.patch` applied to a FRESH `a74e2df3` worktree and rebuilt there gives the SAME md5 — and that same fresh worktree WITHOUT the patch builds to `4f5f59ff040bbe46f92e4222a881637e`, the pristine md5.  The patch IS the artifact every number below was measured on |
| the head | **Earlgrey_0_1/default, 31 cmp lines, ONE head → 0 cmp lines, ZERO heads, `CMP_EQUAL`.**  Before: `LHS: logic_var (work@top_earlgrey.u_xbar_main.u_sm1_17.gen_host_fifo[0].shifted_id)` @`tlul_socket_m1.sv:94:21-94:31` / `RHS: <null>` — r10earl121's R0.  After: the row is EQUAL, so there is no next head in it |
| Earlgrey_0_1/testflags | **0 cmp lines, `CMP_EQUAL`, before AND after — and its database is BYTE-IDENTICAL between the two binaries** (md5 `92bf7b7facdcf4fca15d5710960e8c64`) |
| production surface | `src/ModuleEmit.cpp` ONLY — **+47 lines, of which FIVE are code**.  Nothing existing was edited or removed |
| probe surface | `tools/probe/r10earl122repro/` only |

---

## 1. THE JUDGE, DECODED FIRST — the head is **NOT** a listing head

The brief handed this pass a framing: *"golden lists the declared-and-
continuously-assigned gen-local under the scope's variables where we list
none."*  **That framing is REFUTED**, and refuting it was the first instrument,
not an afterthought.

`~/.local/include/uhdm/BaseClass.h` has TWO `SafeCompare` overloads that can
print `RHS: <null>`, and **which one fired is the whole question**:

```
SINGULAR  SafeCompare(lhs, rhs, ctx)                            (:187-199)
    lhs != nullptr && rhs == nullptr  ->  m_failedLhs = THE POINTEE
VECTOR    SafeCompare(lhs_obj, lhs_vec, rhs_obj, rhs_vec, ctx)  (:202-225)
    lhs_vec non-empty && rhs_vec == nullptr -> m_failedLhs = THE CONTAINER
    size mismatch                           -> BOTH containers set
```

A "we list none" head would name the **`gen_scope`**, not the variable.  The
head names a `logic_var`, so it is the SINGULAR branch: a golden edge whose
target this is, with the OWNER HIDDEN.

`own122.cpp` answers it.  Its field table is **DERIVED, not hand-typed**:
`gen_pointsat122.sh` reads every generated `<kind>::Compare`
(`~/git-repos/UHDM/build/generated/src/*.cpp`), takes every SINGULAR
`SafeCompare(lhs->F(), rhs->F(), …)`, looks `F`'s declared type up in
`~/.local/include/uhdm/<kind>.h`, and keeps the **175** fields whose type can
hold a `logic_var` (`any`, `expr`, `variables` — a `variables` IS-A
`simple_expr` IS-A `expr`).  Full output in `OWNER_BEFORE.r10earl122.txt`:

```
== [2] CONTAINER TABLE — scope::Compare order, then gen_scope::Compare order
   Variables    golden=4   ours=4   r=0   LHS=<null> RHS=<null>      <== EQUAL
   ...
== [3] WHOLE-DATABASE IDENTITY SEARCH on OUR side
   OURS [FULL] logic_var(shifted_id)@:94:21-94:31#632703
        parent: gen_scope()@:89:36-139:6#632691
   OURS fullname-matches=4     GOLDEN fullname-matches=4
== [4] SINGULAR FIELD SCAN — GOLDEN objects holding a compared singular edge
   ref_obj::Actual_group  owner=ref_obj        2
== [5] VECTOR SLOT SCAN
   SLOT Variables[2/4] of gen_scope(...)             (golden)
   SLOT OURS.Variables[2/4] of gen_scope(...)        (ours)
```

**WE LIST IT.  IN THE SAME CONTAINER.  AT THE SAME SLOT INDEX.  OF THE SAME
ARITY.**  The edge is `ref_obj::Actual_group`, and the owner is named:

```
== [4''] EDGE PAIRING — golden owner vs OUR object at the same kind+name+span
   GOLD ref_obj(shifted_id)@96:12-96:22   -> logic_var(shifted_id)@94:21-94:31
   OURS ref_obj(shifted_id)@96:12-96:22   -> Actual_group logic_var@94:21-94:31
   GOLD ref_obj(shifted_id)@113:19-113:29 -> logic_var(shifted_id)@94:21-94:31
   OURS ref_obj(shifted_id)@113:19-113:29 -> Actual_group <null>          <== THE OWNER
```

`tlul_socket_m1.sv:113:19` is the `a_source:` member VALUE of the gen-scope
assignment-pattern continuous assign at `:108`:

```systemverilog
 89   for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
 90     tlul_pkg::tl_h2d_t hreq_fifo_i;     // gen-local struct var, the target
 94     logic [IDW-1:0] shifted_id;         // gen-local, declared and CA-driven
 96     assign shifted_id = { tl_h_i[i].a_source[0+:(IDW-STIDW)], reqid_sub };
108     assign hreq_fifo_i = '{
113       a_source:   shifted_id,           // <== THE REFERENCE
```

**This is a BINDING law, not a listing law.**

---

## 2. THE DECODE — WHY THIS ONE REFERENCE AND NOT ITS FOUR SIBLINGS

`cen122` (the census, §4) prints every reference in that gen scope with what it
binds.  Golden and we agree on **every** gen-local reference in the block except
ONE:

| reference | position | golden | ours (pristine) |
|---|---|---|---|
| `shifted_id` @96:12 | the CA's own **Lhs** | BOUND | BOUND |
| `reqid_sub` @98:7 | inside the CA's **concat Rhs** | BOUND | BOUND |
| `unused_tl_h_source` @105:12 | a CA Lhs | BOUND | BOUND |
| `hreq_fifo_i` @108:12 | the pattern CA's Lhs | BOUND | BOUND |
| `hreq_fifo_i` @130:21 | a child-instance **port conn** | BOUND | BOUND |
| `reqid_sub` @95:12 | a CA Lhs | UNBOUND | UNBOUND |
| **`shifted_id` @113:19** | **a KEYED pattern's member value** | **BOUND** | **UNBOUND** |

So a same-scope gen-local read from a gen-scope CA Rhs already binds
(`reqid_sub` @98:7, a plain concatenation).  What binds it is
§ `genCaOpDeepBindGenLocal20`'s walk (`src/ModuleEmit.cpp`), which fires when the
assignment's target is a local of THIS gen scope and re-binds every same-scope
gen-local read ANYWHERE in the Rhs.  Its recursion, verbatim before this pass:

```cpp
if (n20->UhdmType() == UHDM::uhdmoperation)     { …operands…; return; }
if (n20->UhdmType() == UHDM::uhdmsys_func_call) { …args…;     return; }
if (n20->UhdmType() != UHDM::uhdmref_obj)       return;        // <== STOPS HERE
```

**A `tagged_pattern` is none of the three.**
`CompileHelper::compileAssignmentPattern`
(`Surelog/src/DesignCompile/CompileExpression.cpp:3671-3838`) wraps EVERY KEYED
pattern item in a `tagged_pattern` whose `Pattern()` holds the value; a
POSITIONAL pattern takes the `!with_key` path at `:3736-3745` and gets no
wrapper at all.  And r10earl121's § `genCaPatKeepTagDefView121` keeps those
wrappers in the DEFAULT view for exactly the Lhs shape this walk fires on — a
gen-scope-local whole-name target.  So the walk reached every POSITIONAL
pattern's operands and no KEYED pattern's, and the head is the difference.

Surelog draws no such line, and it is not `bindVariable` that binds these: a
member value is bound at COMPILE time by `compileExpression` walking the block's
scope, and the tag is only a wrapper the writer puts around a value that is
ALREADY bound.  Hence the law:

> **§ `genCaPatTagDeepBind122` — § `genCaOpDeepBindGenLocal20`'s walk also
> descends through a `tagged_pattern` to its `Pattern()`.**

**THE CHILD-INSTANCE TRAP, paid again.**  None of this is visible at the TOP
module: there `suppressRefActual` is off, the ordinary `netMap` path binds the
reference, and golden and we agree.  Measured, not assumed — the REAL
`tlul_socket_m1` gen block, cut down and compiled as a TOP module with the
harness Surelog and our pristine binary, gives `shifted_id@113:19` **BOUND on
both sides**; the SAME file instantiated once as `u_sm1_17` inside a wrapper
gives golden BOUND and ours UNBOUND, in all three unrolled scopes.  That is
§ `genCaSysCallArgBinds22`'s own note — *"five passes of top-module witnesses
never saw it"* — and it is why both arms here are wrapped in a child instance.

---

## 3. THE LISTING HALF, ANSWERED AT CORPUS SCALE

Because the brief's framing was a listing one, `cen122` also emits a `LIST` row
per object a `gen_scope` lists — container, slot INDEX, ARITY and KIND, so the
net-vs-var SPLIT is measured rather than inferred.  Over the WHOLE
`Earlgrey_0_1/default` design:

```
golden 5908 LIST rows | pristine 5908 | patched 5908
golden-vs-pristine differing rows: 0
pristine-vs-patched  differing rows: 0
```

and the head's own scope, byte for byte on both sides:

```
gen_host_fifo[0] | hreq_fifo_i        90:24  Variables|0/4|struct_var
gen_host_fifo[0] | reqid_sub          93:23  Variables|1/4|logic_var
gen_host_fifo[0] | shifted_id         94:21  Variables|2/4|logic_var
gen_host_fifo[0] | unused_tl_h_source 104:31 Variables|3/4|logic_var
gen_host_fifo[0] | i                  89:0   Parameters|0/1|parameter
```

**THE DECLARATION-FORM SPLIT, read off GOLDEN** (`a3_forms122.sv`, ten forms in
one gen block inside a child instance, PLAIN view; `container|slot/arity|kind`):

| form | golden | ours (pristine) |
|---|---|---|
| d1 `logic` plain | `Variables\|0/5\|logic_var` | same |
| **d2 `logic`, declared AND continuously assigned** — the head's own form | `Variables\|1/5\|logic_var` | **same** |
| d3 `logic [7:0]` ranged | `Variables\|2/5\|logic_var` | same |
| d4 `int` | `Variables\|3/5\|int_var` | same |
| d5 struct-typed VARIABLE | `Nets\|0/4\|struct_net` | same |
| d6 `wire`-typed struct | `Nets\|1/4\|struct_net` | `Nets\|1/4\|logic_net` (**R2**) |
| d7 `reg`, driven by a CA | `Nets\|2/4\|logic_net` | same |
| d8 `reg`, never driven | `Nets\|3/4\|logic_net` | same |
| d9 unpacked array of logic | `Variables\|4/5\|array_var` | same |
| d10 IMPLICIT net (undeclared CA target) | **listed NOWHERE** | same |

So the **net-vs-var split is golden's already, form for form**, including the
head's own form (d2), and the ONE kind we get wrong (d6) is a `wire`-typed
struct — a pre-existing residue this pass does not touch.  Across all five
arm×view cells the pristine-vs-patched LIST diff is **0**: this pass moves not
one listing row anywhere.  (The golden-vs-pristine LIST diffs — 4 / 8 / 0 / 3 /
2 — are R2 and R3 below, identical on both binaries.)

---

## 4. WHAT WAS BUILT — FIVE LINES

`src/ModuleEmit.cpp`, inside § `genCaOpDeepBindGenLocal20`'s `deep20` lambda,
between its `operation` arm and its `sys_func_call` arm:

```cpp
if (n20->UhdmType() == UHDM::uhdmtagged_pattern) {
    deep20((UHDM::any*)((UHDM::tagged_pattern*)n20)->Pattern());
    return;
}
```

Nothing else moved.  Every gate the walk already carried still runs BEFORE it
and is untouched: `lhsGenLocal20` (the target must be a Variable of THIS block,
or a select — § `genCaSelLhsDeepBindGenLocal23`), the block's own member scan,
§ `genCaAncestorNetShadowUnbinds98`'s walk up the elaborated hierarchy, the
`ca->Rhs()` must be an `operation`, and the leaf filter that refuses every
net-kind `netMap` object.  §5's fence arm measures all of them on GOLDEN.

---

## 5. THE ARMS — 3 ARMS × 2 VIEWS × GOLDEN + BOTH BINARIES

`GRID.r10earl122.txt` holds the full table; every arm is built with the surelog
`scripts/verify_golden.py` names, **spelled in full**
(`~/git-repos/Surelog/build/bin/surelog` — r10earl120's R4), in both views, and
every rc is recorded.

**`a1_axis122.sv` — THE AXIS.**  Eight cells inside a CHILD instance, varying
the one thing the law is about against everything that could plausibly be the
discriminator.

| cell | shape | golden | pristine | patched |
|---|---|---|---|---|
| x1 | KEYED pattern, gen-local struct VAR target, bare same-scope gen-local operand | BOUND | UNBOUND | **BOUND** |
| x4 | same, nested member value | BOUND | UNBOUND | **BOUND** |
| x3 | **POSITIONAL** pattern, same operand | BOUND | BOUND | BOUND |
| x6 | a **PROCESS** (`always_comb`), same operand | BOUND | BOUND | BOUND |
| x2 | operand is a MODULE-scope net | UNBOUND | UNBOUND | UNBOUND |
| x5 | operand lives in the ANCESTOR gen scope | UNBOUND | UNBOUND | UNBOUND |
| x8 | module-scope CA, no generate scope at all | BOUND | BOUND | BOUND |
| x7 | KEYED pattern, gen-local struct **NET** (`wire`) target | BOUND | UNBOUND | UNBOUND (**R1**) |

**`a2_fence122.sv` — THE FENCE**, one cell per reason the walk must not move,
each answer taken from GOLDEN:

| cell | shape | golden | pristine | patched |
|---|---|---|---|---|
| gf1 | ELEMENT-SELECT Lhs of a gen-local array, KEYED pattern | BOUND | UNBOUND | **BOUND** |
| gf3 | MODULE-scope target, KEYED pattern | **UNBOUND** | UNBOUND | UNBOUND |
| gf4 | the operand is a gen-local **NET** (`wire`) | **UNBOUND** | UNBOUND | UNBOUND |
| gf5 | the operand lives in the ANCESTOR gen scope | UNBOUND | UNBOUND | UNBOUND |
| gf6 | POSITIONAL pattern | BOUND | BOUND | BOUND |
| gf7 | the Lhs name is **SHADOWED** by a net one module up | **UNBOUND** | UNBOUND | UNBOUND |
| gf8 | REPLICATION operand | BOUND | BOUND | BOUND |
| gf9 | a PROCESS, not a cont_assign | BOUND | BOUND | BOUND |

gf3, gf4 and gf7 are the three gates the descent must not cross, and golden
agrees with every one of them; gf1 is the one the descent is OWED (§ 23's
select clause turns the walk on and golden binds there too).  The arm scores

```
a1_axis122 plain  TO-GOLDEN 4  AWAY-GOLDEN 0  MOVED-WRONG 0  NOGOLD_MOVED 0
a2_fence122 plain TO-GOLDEN 2  AWAY-GOLDEN 0  MOVED-WRONG 0  NOGOLD_MOVED 0
a1_axis122 elab   TO-GOLDEN 0  AWAY-GOLDEN 0  MOVED-WRONG 0  NOGOLD_MOVED 0
a2_fence122 elab  TO-GOLDEN 0  AWAY-GOLDEN 0  MOVED-WRONG 0  NOGOLD_MOVED 0
```

**Nothing moves in the `--elabuhdm` view, in either arm** — the law is
default-view-only by construction, and the arms say so independently.

---

## 6. THE CORPUS — PREDICTION FIRST, THEN THE CENSUS, THEN THE BYTES

**THE PREDICTION, made from the PRISTINE databases ALONE** (`pred122.cpp`,
whose condition is the patch's term for term; the two terms a database cannot
see — § 98's hierarchy walk and the block's member scan — can only make it an
OVER-count, and its docstring maps each one):

```
surelog     PREDICT-MOVE  rows=1  cells=29
              default    Earlgrey_0_1   29 cells,
              all of them `shifted_id` @113:19-113:29, one per
              gen_host_fifo[k] of every u_sm1_* instance
uhdm2rtlil  PREDICT-MOVE  rows=0  cells=0     (in BOTH modes)
```

**THE CENSUS** (`CENSUS_sl.txt` / `CENSUS_u2r.txt`), three-way multiset join,
**calibration first** — `score122.py` REFUSES to score unless the two sweeps'
GOLDEN halves are identical:

```
surelog     CALIBRATION OK: golden halves identical, 6 033 502 keys
            TO-GOLDEN 29 · AWAY-GOLDEN 0 · MOVED-WRONG 0 · NOGOLD_MOVED 0
            SAME_AGREE 1 018 596 · STILL-WRONG 20 401   (other laws' residue, R4)
            MOVER ROWS: default Earlgrey_0_1 {'TO-GOLDEN': 29}   — the only row
uhdm2rtlil  CALIBRATION OK: golden halves identical, 139 544 keys
            TO-GOLDEN 0 · AWAY-GOLDEN 0 · MOVED-WRONG 0 · NOGOLD_MOVED 0
            not one cell moved, in either mode
```

**THE FORM GRID** (`FORMGRID.r10earl122.txt`) — gen-scope-homed references by
POSITION CLASS × MODE, BOUND/TOTAL, for `Earlgrey_0_1`.  Of the 57 position
classes in the default mode, **exactly one moves**:

```
   position                          mode      GOLDEN     PRIS       PAT
   operation<cont_assign<gen_scope   default   613/6434   584/6434   613/6434
   operation<cont_assign<gen_scope   testflags 6424/6434  6424/6434  6424/6434
```

— the patched column lands ON golden's number, and every other class in both
modes is unchanged.

**WHY `Earlgrey_0_1/testflags` IS `CMP_EQUAL` AND CANNOT MOVE — two independent
reasons, both measured.**  Its own command line carries `-elabuhdm`
(`Surelog/third_party/tests/Earlgrey_0_1/sim-icarus/Earlgrey_0_1.sl`), which
`verify_golden.py:369-370` translates into our `--elabuhdm`.  (a) In that view
r10earl121's `elabUhdmView121` gate leaves `patFlat9` TRUE, so we FLATTEN the
keyed pattern and there is no `tagged_pattern` for the new descent to cross at
all.  (b) Independently, `uhdm_main.cpp` runs `UHDM::ElaboratorContext` only
under `--elabuhdm`, and that listener binds references by name anyway — the form
grid's testflags column is `6424/6434` BOUND on golden, pristine AND patched.
The byte gate confirms it without any model: **the testflags database md5 is
IDENTICAL between the two binaries** (`92bf7b7facdcf4fca15d5710960e8c64`) and
the row is not in the mover set.

**THE BYTE MOVERS**: `byteverify.sh SELFCHECK=1` reports **0 / 1358** on
uhdm2rtlil and **2 / 956** on surelog:

* `./default/Earlgrey_0_1-71da2fd7/slang.uhdm` — **PREDICTED BY NAME**.
  `ATTRIB_Earlgrey_default.txt`: both dumps path-normalised, diffed RAW and
  ORDER-BLIND —
  ```
  lines pristine=4730932  patched=4730990
  RAW diff lines        : 58
  ORDER-BLIND diff lines: 58
    ADDED   29 |vpiActual:
    ADDED   29 \_logic_var:
    REMOVED (none)
  ```
  29 references, one `vpiActual` pointer each, ALL ADDITIONS, ZERO removals.
* `./default/Scoreboard-59431470/slang.uhdm` — the documented ~50/50 COIN
  (RESUME.md §9).  `ATTRIB_Scoreboard_coin.txt`: RAW diff 92 lines,
  **ORDER-BLIND diff ZERO lines** — not one dump line differs in content, only
  in order.  And the law cannot reach it: `pred122` on its PRISTINE database
  reports `sites=0 predicted-cells=0`.

---

## 7. THE GATES — ALL GREEN

In one line: goldens **23 PASS / 0 FAIL on BOTH binaries** and **0 PASS / 23
FAIL on `/bin/false`**; uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2
SURELOG_FAIL in both modes on both binaries**, `ct8rows` PASS four ways and
**0 / 1358** byte movers; surelog **1588 rows**, `ct8rows` pristine-vs-patched
**ONE differing row — the CONVERSION quoted at the top** — and 2 / 956 byte
movers, both attributed by name; canaries 50+2 / 8+0, `ctcan2` PASS twice,
`canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0.  Protected databases, md5
patched vs pristine: `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`
**SAME** in both modes; `SVSwitch` `4842211c4030` and `YosysVerx`
`6ccda350c24a` pins hold in both modes.  Every `cmds.txt` audited BY BINARY
PATH: 1523/1523 surelog and 1458/1458 uhdm2rtlil slang invocations used this
pass's frozen binaries and **0 used any other binary**.  Full transcript in
`GATES.r10earl122.txt`.

`rowheads.sh` on the seven named rows, pristine → patched:

```
SeqDriver      default 112/112        testflags 112/112
SimpleUVM      default 4177864/…      testflags 4178104/…
Scoreboard     default 95/95          testflags SKIP-NOFILE (expected)
MiniAmiq       default 112/112        testflags 112/112
BuildUVMPkg    default 0/0            testflags 0/0        <- CMP_EQUAL, stays
Rggen          default 0/0            testflags SKIP-NOFILE (expected)
Earlgrey_0_1   default 31 -> 0        testflags 0/0        <- CMP_EQUAL, stays
```

one head throughout.  **The four `CMP_EQUAL` row-modes are scored on BOTH
columns and all four stay `CMP_EQUAL` with 0 cmp lines**: `BuildUVMPkg/default`,
`BuildUVMPkg/testflags`, `Earlgrey_0_1/testflags` and `Rggen/default`.  None of
`BuildUVMPkg`, `Rggen` or `Scoreboard` has a gen-scope pattern continuous assign
the law could reach (`pred122`: 0 predicted cells), and `Earlgrey_0_1/testflags`
declines by construction (§6).

**The one baseline row-side difference that is NOT the conversion**, quoted in
full and present on the PRISTINE binary too:

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ      (results/golden_surelog.csv)
> Earlgrey_0_1,testflags,CMP_EQUAL,,,            (BOTH of this pass's sweeps)
```

The STATUS is `CMP_EQUAL` on both sides; only the dump diagnostic column
empties, and `ct8rows` pristine-vs-patched is PASS on that row.  It is the
`uhdm-dump` TIMEOUT under concurrent sweeps that r10earl119, r10earl120 and
r10earl121 each recorded.

---

## 8. THE WIDE BOUNDARY — EVERY COMMITTED ARM, BOTH VIEWS

`widerun122.sh` stages a COPY of `tools/probe`, lists every `.sv`/`.v` at ANY
depth, filters the fenced names out of the list BEFORE a child runs (reading the
list out of `canaudit.sh`'s own `FENCED=` line), reads the list on fd 3 with
children `</dev/null`, and asserts PROCESSED == LISTED.

```
LISTED=5337  FENCED_REMOVED=0  (of 5337 found)
PROCESSED=5337 identical=10232 DIFFERING=8 no_output=434
rc by side:  A/0 9841  A/139 16  A/3 418  A/4 399
             B/0 9841  B/139 16  B/3 418  B/4 399     <-- SYMMETRIC
PROCESSED==LISTED (5337)
```

The 8 differing cells:

* **two are this pass's OWN arms in the PLAIN view** — its population, rescored
  against golden in §5 (TO-GOLDEN 6, AWAY-GOLDEN 0, MOVED-WRONG 0).
* **six are three files in BOTH views, and they are the documented
  STATIC-ADDRESS FALSE MOVER** (`BOUNDARY_falsemovers.txt`): `r10buvm22repro/
  g22.sv`, `r10uvm154repro/l154_noenum.sv`, `r10uvm185repro/grid185/
  g185_e_kinds.sv`.  Four instruments convict them: each is byte-identical when
  built TWICE with the SAME binary (so not nondeterminism); the entire
  difference is a handful of `vpiDecompile:` / `UINT:` values and **every
  numeric delta is exactly −4096, one page**; the object is an
  address-derived `array_typespec` right-range bound over an ASSOCIATIVE array
  (`g22.sv:70`, `typedef C22 ka_cls_t[string];`) — a pre-existing artifact of
  another family that follows the binary's layout; and `pred122` reports
  **sites=0 predicted-cells=0** on all three.  The brief names this trap and
  its tell — *zero census movement* — and the census is 0 outside the 29.

**THE MUST-STAY FLOOR**, checked BY NAME, mechanically (`floor122.sh`):
r10earl121's arms and its verifier's, r10earl120's, r10earl119's arms and its
all-fences arm, § 106's arms and fences, r10earl118's arms and fence,
r10earl110-117's, and uvm82-91 / buvm3-15 / sd8-12 — **42 directories checked,
BREACHES 0**.  Not one of them appears in the differing list.

---

## 9. RESIDUES

* **R0 — THE NEXT HEAD.**  `Earlgrey_0_1` is now **`CMP_EQUAL` in BOTH modes**,
  so this row has no next head.  The remaining `CMP_NOTEQUAL` surelog rows are
  8 in `default` and 7 in `testflags`; the campaign's live heads are the ones
  `rowheads.sh` names — `SeqDriver` 112 (both modes), `MiniAmiq` 112 (both
  modes), `Scoreboard/default` 95, `SimpleUVM` ~4.18M (both modes).  **The
  named next head for whoever takes the Earlgrey chain is therefore a DIFFERENT
  ROW**; within THIS pass's family the ranked next object is R1 below.
* **R1 — THE GEN-LOCAL STRUCT **NET** TARGET DOES NOT TURN THE WALK ON.**  Arm
  `a1_axis122` cell x7: `wire r122::p_t t7; assign t7 = '{…, f_d: sid7, …};`
  — golden BINDS `sid7`, we still leave it UNBOUND, before and after.
  § `genCaOpDeepBindGenLocal20`'s `lhsGenLocal20` requires
  `ls20.kind == SymbolKind::Variable`, and a `wire`-typed struct is a
  `SymbolKind::Net`, so the walk never starts.  Deliberately NOT taken here:
  widening the Lhs KIND is a different law from descending through the wrapper,
  ps20 measured only the Variable half, and this pass's brief is
  MOVED-WRONG 0 / AWAY 0.  x7 is the reduced repro; it is 2 cells in the arm and
  **0 cells in either corpus** (the census's TO-GOLDEN set is exactly 29 and
  contains none of this shape).
* **R2 — A `wire`-TYPED GEN-LOCAL STRUCT IS LISTED AS A `logic_net`, NOT A
  `struct_net`.**  `a3_forms122` cell d6 and `a1_axis122`'s `t7`, plain view:
  golden `Nets|…|struct_net`, ours `Nets|…|logic_net`.  Present on BOTH
  binaries; it is r10earl121's R2 seen from the listing side, and this pass
  moves zero listing rows.
* **R3 — A GEN SCOPE MISSING FROM THE ELAB LISTING.**  `a2_fence122` elab: our
  `gf8[1]` scope has no `Parameters`/`Variables` rows at all where golden lists
  three.  Another family's; identical on both binaries.
* **R4 — THE 20 401 `STILL-WRONG` CENSUS KEYS ARE NOT THIS LAW'S.**  They are
  references whose binding disagrees for reasons this walk never touches (the
  `hier_path` and `bit_select` position classes in the form grid are 0/N on our
  side in the default view across the board).  Named here so the number is not
  mistaken for this law's residue.
* **R5 — THE TWO-SURELOG TRAP, re-paid once.**  Every golden in this directory
  was built with `~/git-repos/Surelog/build/bin/surelog`, the path
  `scripts/verify_golden.py` names, spelled in full.  The shell `surelog` alias
  is a DIFFERENT build (r10earl120's R4).

---

## 10. FILES

| file | what it is |
|---|---|
| `own122.cpp` | THE OWNER-FINDER for a `LHS: <object>` / `RHS: <null>` head: the official head, the parent chain, the two scopes' CONTAINER TABLE in generated-`Compare` order with NULL and EMPTY told apart, a WHOLE-DATABASE identity search before concluding absence, the SINGULAR field scan, the EDGE PAIRING, and the VECTOR slot scan |
| `gen_pointsat122.sh` / `pointsat122.inc` | the 175 singular compared fields that can hold a `variables`, DERIVED from UHDM's own generated `Compare` bodies rather than typed out |
| `OWNER_BEFORE.r10earl122.txt` | its full output on the pristine pair |
| `cen122.cpp` | THE CENSUS: every `ref_obj`/`ref_var` keyed by home scope + name + span + POSITION CHAIN, payloaded BOUND/UNBOUND and to what, with `live=` from `UhdmListener`'s own visited set and `--with-dead` to tell a MISSING object from an ORPHANED one; plus the `LIST` rows (every object a `gen_scope` lists, with container, slot index, arity and KIND — the net-vs-var SPLIT) |
| `censweep122.sh` | runs it over a whole `verify_golden.py` workdir, golden path from each test's OWN `cmds.txt`, every rc logged |
| `pred122.cpp` | the mover set predicted BY NAME from the PRISTINE census alone, on the patch's own condition term for term, with the two DB-invisible terms named |
| `score122.py` | the three-way multiset join; asserts the two sweeps' golden halves identical FIRST |
| `PREDICT_sl.txt` / `PREDICT_u2r.txt` | the predictions, made from the pristine databases |
| `CENSUS_sl.txt` / `CENSUS_u2r.txt` | the corpus three-way scores, calibration line first |
| `FORMGRID.r10earl122.txt` | binding by POSITION CLASS × MODE for `Earlgrey_0_1`, golden vs pristine vs patched |
| `a1_axis122.sv` | THE AXIS ARM: eight cells inside a CHILD instance — keyed vs positional, var/net/struct target, same-scope vs ancestor vs module operand, nesting, process vs cont_assign |
| `a2_fence122.sv` | THE FENCE ARM: nine cells that must not move, one per reason, each answer taken from GOLDEN |
| `a3_forms122.sv` | THE DECLARATION-FORM ARM: ten gen-block declaration forms, so §3's net-vs-var listing SPLIT is measured on golden per form and per view rather than cited |
| `arm122.sh` | the arm runner: both views, golden (harness surelog spelled in full) + both frozen binaries, official `uhdm-cmp` count, census, every rc |
| `GRID.r10earl122.txt` | the scored arm grid, the golden-measured FENCE TABLE, and the LISTING half |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the official `uhdm-cmp` head of `Earlgrey_0_1` in both modes, before and after |
| `attrib122.sh` / `ATTRIB_Earlgrey_default.txt` / `ATTRIB_Scoreboard_coin.txt` | the path-normalised, RAW and ORDER-BLIND whole-dump attribution of the two byte movers |
| `wide122.sh` / `widerun122.sh` / `BOUNDARY_*` | the wide boundary over every committed arm, both views, with the fence filter, the rc histogram by side, the differing list, and the conviction of the three static-address false movers |
| `floor122.sh` | the MUST-STAY FLOOR checked BY NAME against the boundary's differing list |
| `GATES.r10earl122.txt` | the gates, every command and every number |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the gate scripts, carried so this directory reproduces the battery on its own |
