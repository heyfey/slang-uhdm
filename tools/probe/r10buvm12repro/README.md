# r10buvm12 — § externProtoInBodyCallBinds12 — **the BuildUVMPkg head cleared; the CALLEE LINK of an `extern` / `pure virtual` class method**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `67bb2b0` |
| worktree | `/tmp/wt_r10buvm12` |
| pristine binary | md5 `faab97020523781f26d59a3895785102` |
| patched binary | md5 `5404b8b6aae58aadbadfc79527aae79a` |
| production surface | `include/UhdmExporter.h` (one map + the law), `src/TaskFuncEmit.cpp` (2 registrations), `src/UhdmExporter.cpp` (clear/restore), `src/ExprEmit.cpp` (2 call sites) |
| probe surface | `tools/probe/r10buvm12repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines.  What it does is clear the head buvm11
left as its residue R0.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` lines, default / testflags | **47** | **29** |
| heads (`grep -c '^LHS:'`) | 1 | 1 |
| head object | `function(uvm_pkg::uvm_comparer::get_recursion_policy)@21000:3` < `class_defn(uvm_comparer)` / `RHS: <null>` | `io_decl(severity)@9560:40` < `function(uvm_pkg::uvm_report)@9560:1` / `RHS: <null>` |
| ladder rungs (fixpoint) | **125** | **99** |

Both modes' cmp logs are **byte-identical to each other** on both binaries, and
the other ten cmp logs of the seven-row head set are **byte-identical between the
two binaries** (§9).

## 1. THE HEAD, DECODED — the brief's hypothesis is REFUTED: it is not a listing, it is a LINK

The brief asked which VECTOR under the `class_defn` was short or mis-ordered.
**It is neither, and the dump says so.**  `class_defn::Compare`
(`generated/src/class_defn.cpp:160`) walks `Task_funcs()` with the VECTOR
`SafeCompare`, and that overload sets `m_failedLhs` **and** `m_failedRhs` to the
two CONTAINERS on a size mismatch — the head would then decompile the
`class_defn`.  It decompiles the FUNCTION with `RHS: <null>`, which only the
SINGULAR `SafeCompare` can produce:

```cpp
// generated/src/func_call.cpp
if ((r = SafeCompare(lhs->Function(), rhs->Function(), context)) != 0) return r;
```

```
uvm_pkg.sv:21396, inside uvm_comparer::compare_object (an IN-BODY method):
    ret_val = object_compared(lhs, rhs, get_recursion_policy(), ret_val);
                                        ^^^^^^^^^^^^^^^^^^^^^^

golden                                     ours
\_func_call: (get_recursion_policy) 21396:49   \_func_call: (get_recursion_policy) 21396:49
  |vpiParent: \_func_call:(object_compared)      |vpiParent: \_func_call:(object_compared)
  |vpiName:get_recursion_policy                  |vpiName:get_recursion_policy
  |vpiFunction:                              <-- THE DEFECT: ABSENT ON OUR SIDE
  \_function: (…::get_recursion_policy) 21000:3
```

`21000:3` is the **`extern` PROTOTYPE** (`extern virtual function
uvm_recursion_policy_enum get_recursion_policy();`), the object the `class_defn`
lists — *not* the out-of-body definition at `21588:1`, which golden also emits as
a separate `function` object under the package.  Our `class_defn` **has** that
prototype object (whole-dump line 377 989); we simply never point at it.

Our `Task_funcs` listing is not the defect: the walk reaches the failing
`func_call` from INSIDE `compare_object`, which is itself `Task_funcs[i]` for an
`i` BELOW the prototype's index, so the listing had already compared equal that
far.

## 2. THE CENSUS — golden vs ours over every tf_call, BEFORE any code

`r10buvm12cen` reads a database out of `Serializer::AllObjects()` (never dump
TEXT) and emits one row per `func_call` / `method_func_call` / `task_call` /
`method_task_call`: view, parent chain, kind, name, span, whether it carries a
callee link, the link TARGET, `nargs`, `Scope()`, the call's home, its nearest
`class_defn`, the enclosing method's line and TWO independent out-of-body
shadows.  It also emits one `PR` row per `class_defn` method LISTING, which is
what makes the mover prediction readable out of a pristine database (§7).
`cenjoin12.py` joins two censuses on an **ID-blind and address-blind** key
`(view, parent chain of kinds+names, call kind, name, line:col)`, as
**MULTISETS** — 120 of BuildUVMPkg's 13 083 tf_calls share a key with another,
and a last-writer-wins dict would silently drop one of each pair.

**CALIBRATION FIRST, golden against golden** (BuildUVMPkg): `G=L P=L 2915 /
G=N P=N 10048 / DISAGREEING 0`.  A join that cannot report zero on identical
inputs cannot report 39 on different ones.

BuildUVMPkg, golden vs ours:

| class | pristine | patched |
|---|---|---|
| `G=L P=L` — both link, SAME target | 2 871 | **2 907** |
| **`G=L P=N` — golden links, we do NOT** | **37** | **3** |
| **`G=L P=X` — both link, DIFFERENT target** | **2** | **0** |
| **`G=N P=L` — we link, golden does NOT (OVER-LINK)** | **0** | **0** |
| `G=N P=N` | 10 100 | 10 100 |

and the 39 pristine disagreements SEPARATE PERFECTLY on one property of the
CALLEE — printed in full by the join, then read back against the source:

| callee's declaration form | targets | calls | outcome |
|---|---|---|---|
| `extern …` prototype (definition out of body) | 13 + 2 | 26 + **2 `P=X`** | **every one wrong** |
| `pure virtual …` prototype (no body at all) | 7 | 7 | **every one wrong** |
| plain IN-BODY class method | 136 | 249 | every one already right |
| package free function | 36 | 2 591 | 2 588 right, **3 left** (§6 R1) |

**249 links to in-class methods work and 34 do not, and the line between them is
exactly `extern`/`pure virtual`.**  The two `P=X` cells are the same family seen
from the other side: we linked the OUT-OF-BODY DEFINITION
(`m_predefine_policies@64005:1`, `get_default_max_ready_to_end_iterations@33672:1`)
where golden has the PROTOTYPE (`@63531:4`, `@32619:3`).

`nargs` agrees on **every one of the 39** (`0/0`, `1/1`, `2/2`, `3/3`, `4/4`), so
§ `namedTfArgsFormalSlots4` does **not** ride along: golden links these calls
without slot-filling their actuals, and `get_schedule_name(bit hier = 0)` called
as `get_schedule_name()` stays `nargs=0` on both sides.  **This law is
link-only.**

## 3. DECODED FROM THE PRODUCER, AND FROM OUR OWN SOURCE

Surelog is single-pass over a class body, and `TaskFuncEmit.cpp`'s own comment
already had the right model — it just never acted on the parenthesis:

> "…that class's OWN declarations (**an `extern` prototype counts**).  It never
> reaches a BASE class, and an OUT-OF-BODY definition is compiled in the home
> package's scope, where the class's methods are not visible at all."

Two lines of ours are why the parenthesis was dead:

* `TaskFuncEmit.cpp:4493` — *"The prototype listing ends here: … and no subMap
  registration (**calls bind the DEFINITION object**, which the second group
  emits from the same SubroutineSymbol)."*  The definition group is emitted
  LAST, so an in-body call finds nothing and takes § `classCallNoLink12`; a
  class-PROPERTY initializer is drained even later (`lateInit29`) and finds the
  definition — the two `P=X` cells.
* `TaskFuncEmit.cpp:2531` — *"The prototype takes no funcMap/subMap
  registration: nothing binds to a pure virtual's formals, there being no
  body."*  True of the FORMALS, false of the CALL: slang answers a call to a
  pure method with the stub `SubroutineSymbol` that
  `MethodPrototypeSymbol::getSubroutine()` mints
  (`SubroutineSymbols.cpp`, `createFromPrototype`), and that stub was in no map.

§ `classCallNoLink12`'s standing claim — *"Surelog never links a class method
call anyway"* — is **REFUTED for prototypes and CONFIRMED for everything else**,
and its own witness is why: `uvm_default_factory::m_matches_type_override` is
prototyped at 11952 and every one of its **6** calls is unlinked in golden —
because all 6 sit in OUT-OF-BODY definitions (12476, 12558, 12959, 12996, 13071,
13108; the class ends at 11990).  All **39** of this pass's cells sit INSIDE the
class body.  The two populations never overlap.

## 4. THE LAW

> **§ externProtoInBodyCallBinds12** — a call written INSIDE a class body — an
> in-body method body, or a class-property initializer — whose callee is a
> method of **THAT SAME class** declared as an `extern` or `pure virtual`
> **PROTOTYPE**, binds `vpiFunction` to the **PROTOTYPE** function object the
> `class_defn` lists: not to the out-of-body definition object, and not to
> nothing.

### STATED GATE == CODE GATE

**STATED:** a `std::map<const Symbol*, UHDM::function*>` is CLEARED at the top of
every class body's emission and filled, in DECLARATION ORDER, with that class's
own `extern` and `pure virtual` prototype objects as they are emitted.  A call
reads it, and the ONE extra predicate is `!curSubOob9`.  **THE MAP IS THE GATE**,
and three fences fall out of it with no predicate at all:

| fence | why the map gives it free | golden |
|---|---|---|
| a BASE class's prototype | cleared before this class's emission | arm v2 `call_bef` **lnk0** |
| a prototype declared BELOW the calling body | not in the map YET (bodies are emitted from the same declaration-order loop) | arm v1 `call_efb` **lnk0** |
| …but IN scope for a class-PROPERTY initializer | `lateInit29` is drained AFTER `emitTaskFuncs`, map full | arm v1 `prop_esb` **lnk1 -> proto@42:5** |
| an OUT-OF-BODY definition body | `!curSubOob9` — the ONE predicate; oobDefs are emitted last, when the map IS full | arm v1 `c2::oob_caller` **lnk0**, corpus `m_matches_type_override` ×6 **lnk0** |

**CODE:** `git diff` vs `67bb2b0` — **119 added lines, of which 86 are comment**
and 33 are code: one map, two registrations, one clear/restore pair, two
`find`-and-bind windows.  `siTf` and everything the argument-typespec stamping
reads are left untouched, so a call this map does not hold emits
byte-identically.

**FUNCTIONS ONLY.**  Stamping a `task*` into `Function()` would be a bad cast,
and golden disagrees with us about the object's KIND there, not its link — see
residue R2.

### the gates that were REFUTED, each on the grid

| candidate gate | refuted by |
|---|---|
| "it is a `Task_funcs` listing bug" (the brief) | §1 — a vector `SafeCompare` cannot produce `RHS: <null>` on an ELEMENT; the failing field is `func_call::Function()` |
| "Surelog never links a class method call" (§ classCallNoLink12) | §2 — golden links 249 in-class plain-method calls and 34 prototype calls |
| "golden never links an `extern` callee" (§ classCallNoLink12's witness) | §2/§3 — true only from an OUT-OF-BODY caller; all 6 `m_matches_type_override` calls are out-of-body |
| "any same-class callee links" | arm v1 `call_below` / `call_efb` — a callee declared BELOW an in-body caller is **lnk0**, prototype or not (t8's `lateT` rule) |
| "an inherited prototype links" | arm v2 `call_bef` — **lnk0** |
| "declaration order decides everywhere" | arm v1 `prop_esb` — a class-PROPERTY initializer links a prototype declared BELOW it |
| "a receiver or a class qualifier reaches it" | arm v2 `call_recv`/`call_recvpm` (method_func_call, **lnk0** both sides) and `call_qual` (`recv2::rst2()` links the OUT-OF-BODY DEFINITION `@29:3` — and we already agree) |
| "classes in a module are fenced out" | arm v2 `call_mef`/`call_mpv` — golden links there too; **CONVERTED** |

## 5. THE GRID — two arms, 30 golden cells, **0 OVER-FIRE**

`grid12.sh` is the three-way cell table (golden / pristine / patched).  Surelog
and BOTH binaries run in the SAME directory (a UHDM database records the source
file's ABSOLUTE path — buvm8's `bndarms` trap).  The cell is
`<view>:lnk<0|1>-><target kind>@<line:col>`; the target is spelled by KIND and
LOCATION and never by fullname, because location is the only thing that
separates a PROTOTYPE listing from its DEFINITION listing and fullname is not a
field `Compare` reads.

| arm | what it varies | golden calls | verdict |
|---|---|---|---|
| `v1_proto12` | the SAME-CLASS matrix: extern / extern-static / extern-void / extern-task / pure virtual / plain, ABOVE and BELOW the caller, in statement / operand / argument position, plus property initializers and an out-of-body caller | 19 | **CONVERTED 8, OVER-FIRE 0** |
| `v2_reach12` | the REACH FENCE: inherited proto, overridden pure, receiver call, `C::sm()` qualifier, property init to a plain method, extern task, and the whole shape inside a MODULE | 11 | **CONVERTED 2, OVER-FIRE 0** |

**10 CONVERTED, 0 OVER-FIRE, 0 MOVED-STILL-WRONG.**  Cells worth naming:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| v1 `call_ef` | in-body body calls `ef_above()` (`extern virtual`, def oob) | `lnk1->function@13:5` | `lnk0` | **`lnk1->function@13:5`** |
| v1 `call_pv` | …calls `pv_above()` (`pure virtual`) | `lnk1->function@16:5` | `lnk0` | **= golden** |
| v1 `call_es` / `call_etv` | `extern static` / `extern` void | `lnk1->@19:5` / `@14:5` | `lnk0` | **= golden** |
| v1 `call_expr` / `call_arg` | the same callee in OPERAND and ARGUMENT position | `lnk1` | `lnk0` | **= golden** |
| v1 `prop_es` / `prop_esb` | `static int prop = es_above();` / `es_below();` | `lnk1->@19:5` / `@42:5` (the PROTOTYPES) | `lnk1->@52:3` / `@53:3` (the DEFINITIONS) | **= golden** |
| v1 `call_efb` | in-body body calls `ef_below()` (proto declared BELOW) | **`lnk0`** | `lnk0` | unchanged — the FENCE |
| v1 `c2::oob_caller` | an out-of-body definition calls `ef2()` and `pm2()` | **`lnk0`** both | `lnk0` | unchanged — the FENCE |
| v2 `call_bef` / `call_bpm` | an inherited `extern` / plain method of the BASE | **`lnk0`** | `lnk0` | unchanged — the FENCE |
| v2 `call_qual` | `recv2::rst2()`, another class's `extern static` | `lnk1->function@29:3` (the DEFINITION) | = golden | unchanged |
| v2 `call_mef` / `call_mpv` | the same shape in a class inside a MODULE | `lnk1->@61:5` / `@62:5` | `lnk0` | **= golden** |
| v1 `call_ek` / v2 `call_tk` | an `extern task` prototype called from an in-body task | golden **`task_call`** + `vpiTask->task@15:5` | ours is a **`func_call`**, `lnk0` | unchanged (**R2**) |

`detcheck.sh`, 3 runs of the patched binary on each arm: **1 distinct hash, 0
NO_OUTPUT** (the map is keyed by a slang symbol POINTER, and it is only ever
looked up, never iterated).

## 6. RESIDUES, each measured and left deliberately

* **R0 — THE NEW HEAD.**  `io_decl(severity)@uvm_pkg.sv:9560:40` under
  `function(uvm_pkg::uvm_report)@9560:1`, `RHS: <null>`, both modes — a formal
  of a PACKAGE free function that golden lists and we do not.  A different
  family (io_decl population, not callee links); pre-existing.
* **R1 — the package-free-function SHADOW, 27 cells, the whole residual
  `G=L P=N`.**  Exactly **3 per UVM database × 9 databases**:
  `uvm_process_report_message` (×2) and `uvm_report_fatal` (×1).  Each is a call
  inside an in-body method to a name that the SAME class also declares as a
  plain method **BELOW** the call (`uvm_report_object` at 31367,
  `uvm_sequence_item` at 52113 / 52100).  Surelog, single-pass, has not seen the
  method yet and falls through to the PACKAGE free function
  (`uvm_pkg::uvm_process_report_message@9680:1`); slang resolves to the class
  method (correct SV) and we emit no link.  This is § `inheritedNameBindsPkgFn72`
  (LAW C) with its `callee class != caller class` gate widened to
  "declared below", and it is a pass of its own: LAW C's gate is a
  *ref-binding* rule with its own precedents, and 220 of the 221
  `uvm_report_fatal` calls in BuildUVMPkg already link correctly.
* **R2 — the extern-TASK KIND disagreement.**  `extern task tk2(); task
  call_tk(); tk2(); endtask` — golden emits a `task_call` carrying `vpiTask` ->
  the prototype; we emit a `func_call` with no link, because
  § `classCallNoLink12` commits to `func_call` for any name it has not seen
  ("Surelog is single-pass, so a name it has not seen yet has no kind to go on").
  Measured reach on the corpus: **ZERO** cells (BuildUVMPkg has 24 `task_call`s
  and 17 `vpiTask` links on BOTH sides, and the corpus join reports **0 KIND-SWAP
  pairs**), which is why the law is stated FUNCTIONS ONLY rather than guessed at.
  uvm_pkg does contain 101 `extern … task` prototypes, so the shape is reachable
  by future sources; arms v1 `call_ek` and v2 `call_tk` are its witnesses.
* **R3 — `G=L P=X` 4 757 cells, and they are NOT cmp-visible.**  The corpus join
  uses the STRICT target key (kind + **fullname** + line:col).  Measured directly
  on MiniAmiq, which holds 1 216 of them: **1 216 / 1 216 agree on
  `kind@line:col`** and differ ONLY in the package qualifier of `VpiFullName`
  (golden `uvm_pkg::uvm_report_enabled@133:1`, ours
  `svaunit_pkg::uvm_report_enabled@133:1` — a wildcard-import clone).
  `scope::Compare` reads `VpiName`, never `VpiFullName`, so uhdm-cmp cannot see
  these.  A separate family; this law removed 11 of them (the real prototype
  redirects) and touched no other.
* **R4 — 281 `ARITY-DIFF` + 15 645 `G-only` + 15 386 `P-only` keys**, identical
  on both binaries: calls that exist on one side only, or a differing number of
  calls at one key.  A population-level defect (mostly `method_func_call`s: 44
  G-only / 61 P-only on BuildUVMPkg alone) that this law does not touch and must
  not be counted as it.

## 7. THE MOVERS, PREDICTED BY NAME BEFORE ANY BYTE WAS COMPARED

`predict12.sh` reads ONLY the PRISTINE databases (never the patched ones, never
golden).  `extern`/`pure virtual` is a slang FLAG, but it has an exact UHDM
shadow — a `class_defn` method LISTING with no `Stmt` and either
`vpiAccessType == 2` (`vpiExternAcc`) or `vpiDPIPure` — and out-of-body-ness has
TWO (the enclosing method parented at a package, OR `vpiMethod == 0`; the ELAB
view MOVES the definition listing into the `class_defn`, so the parent test alone
reads every ELAB out-of-body body as in-body and over-counted CAND A 44 -> 672).

* **CAND A** — a `func_call` under `class_defn` C, enclosing method not
  out-of-body, name matching a PROTOTYPE listing of C itself declared ABOVE the
  enclosing method (or the call is in a property initializer), current link not
  already that prototype.
* **CAND B / CAND C** — CONTROLS, not predictions: the same shape with no
  `class_defn` in the chain (B) and the same shape inside an out-of-body
  definition (C).  Any B or C object that moves is an over-fire.

| corpus | databases | CAND A | CAND B | CAND C | candidate DATABASES |
|---|---|---|---|---|---|
| uhdm2rtlil | 1 358 | **0** | **0** | **0** | **0** |
| surelog | 956 | **214** | 12 934 | 5 176 | **9** |

```
44 {default,testflags}/BuildUVMPkg   18 {default,testflags}/SimpleUVM
18 {default,testflags}/SeqDriver     18 {default,testflags}/MiniAmiq
18 default/Scoreboard
```

Those **9 databases are EXACTLY the 9 byte movers** gate 5 then found, and the
u2r prediction of ZERO is exactly its 0 movers.  CAND A is an UPPER BOUND by
construction (the UHDM shadow cannot see slang's emission order inside one
class): 214 predicted, **142 moved**, **0 CAND B or CAND C objects moved**
(`G=N P=L` = 0 corpus-wide, both binaries).

## 8. THE CORPUS-WIDE CENSUS, golden vs ours, on BOTH binaries

`cenall12.sh` runs the join over every database of a sweep workdir, reading each
test's golden out of its OWN `cmds.txt`.  `SKIP` (no golden or no database) is
COUNTED and printed, never hidden.

**surelog — 956 databases, 339 with both sides (617 SKIP), 154 000+ compared tf_calls**

| class | pristine | patched | delta |
|---|---|---|---|
| `G=L P=L` | 28 895 | **29 037** | **+142** |
| **`G=L P=N`** | **158** | **27** | **−131** |
| **`G=L P=X`** | **4 768** | **4 757** | **−11** |
| **`G=N P=L` (OVER-LINK)** | **0** | **0** | **0** |
| `G=N P=N` | 106 254 | 106 254 | 0 |
| `ARITY-DIFF` / `G-only` / `P-only` | 281 / 15 645 / 15 386 | 281 / 15 645 / 15 386 | 0 |

**uhdm2rtlil — 1 358 databases, 1 254 with both sides (104 SKIP): `G=L P=L`
2 104, `G=N P=N` 28, TOTAL DISAGREEING 0 on BOTH binaries.**  A strict no-op.

`+142 = 131 new links + 11 redirects`, which is exactly what the byte verifier
then attributed database by database.

> **A ZERO FROM A GATE THAT RAN NOTHING, CAUGHT BY THE GATE'S OWN GUARD.**  The
> first `cenall12` run printed `tests=0 SKIP=0 TOTAL DISAGREEING=0`: the
> inherited one-field `sed` handed `39 (shown 39)` to `$(( ))`, whose syntax
> error aborted the loop.  The script's `reached NO tests` FATAL is what caught
> it.  A LATER run then silently lost 577 of 956 joins because this directory was
> moved mid-run — caught by counting the `rows:` lines against the `==` headers
> (379 vs 956) before any number was reported.  Both are fixed and both numbers
> above are from complete runs.

## 9. THE FIVE GATES

| # | gate | result |
|---|---|---|
| 1 | build BOTH binaries, `-j 2`, md5 separately | pristine `faab97020523781f26d59a3895785102`, patched `5404b8b6aae58aadbadfc79527aae79a`.  The deliverable was then applied to a THIRD, untouched `67bb2b0` worktree (`/tmp/wt_r10buvm12_verify`, `git apply --check` clean) and built from scratch: md5 **`5404b8b6aae58aadbadfc79527aae79a`** — the patch reproduces, bit for bit, the binary every reading above was taken with. |
| 2 | `tests/check_goldens.sh` + negative control | **23** PASS on the pristine, the patched AND the from-scratch reproduction; `SLANG_UHDM=/bin/false` -> **0** PASS.  `SLANG_UHDM` exported explicitly to EACH binary. |
| 3 | uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in each mode on each binary.  `ct12rows.sh`: pristine `testflags` vs the COMMITTED `results/gate_uhdm2rtlil.csv` = **0 differing ROWS** over 731 (**BASELINE FIRST**); patched vs the same = **0**; pristine vs patched over all 1 462 = **0** (status AND dump column). |
| 4 | Surelog suite, `--mode both` | `ct12rows.sh` patched vs the COMMITTED `results/golden_surelog.csv` = **0 differing rows** over 1 588; pristine vs the same = **0**; pristine vs patched = **0**.  Status and dump histograms identical.  **NO ROW CONVERTED — `BuildUVMPkg` stays `CMP_NOTEQUAL` in both modes, `Earlgrey_0_1/testflags` stays `CMP_NOTEQUAL`, and `results/*.csv` were not touched.** |
| 5 | `byteverify.sh SELFCHECK=1 SELFCHECK1=1` | surelog **9 / 956** movers, u2r **0 / 1 358**.  Controls: 955/956 + `SELFCHECK1`=10 (1 corruption + the 9 movers), and 1357/1358 + `SELFCHECK1`=1. |

Every mover attributed by `attrib12.sh` (census delta on the law's own field +
a whole-dump path-normalised diff, judged ORDER-BLIND; the verdict asserts
`added == 2*gained + redirected`, `removed == redirected`, and that every added
and removed dump line is a `|vpiFunction:` or a shallow `\_function:` line):

| database | census GAINED / REDIRECTED | dump RAW | dump ORDER-BLIND | verdict |
|---|---|---|---|---|
| `{default,testflags}/BuildUVMPkg` | 34 / 2 | +70 / −2 | +70 / −2, `vpiFunction:`=34 `\_function:`=36 other=0 | **ATTRIBUTED** (predicted) |
| `{default,testflags}/MiniAmiq` | 9 / 1 | +19 / −1 | +19 / −1, other=0 | **ATTRIBUTED** (predicted) |
| `{default,testflags}/SeqDriver` | 9 / 1 | +19 / −1 | +19 / −1, other=0 | **ATTRIBUTED** (predicted) |
| `{default,testflags}/SimpleUVM` | 9 / 1 | +19 / −1 | +19 / −1, other=0 | **ATTRIBUTED** (predicted) |
| `default/Scoreboard` | 9 / 1 | **+65 / −47** | **+19 / −1**, other=0 | **ATTRIBUTED** — and the RAW figure is the DOCUMENTED COIN (`svunit_pkg` `vpiTaskFunc` reorder), which the order-blind reading removes |

`-- databases NOT ATTRIBUTED: 0`.

### the canary battery, all pristine-vs-patched

| check | result |
|---|---|
| `canaries.sh` on the surelog CSVs (patched vs pristine AND patched vs COMMITTED) | `ok=52 changed=0 absent=0` both, 7 expected unknown names (the u2r-only canaries) |
| `canaries.sh` on the u2r CSVs | `ok=16 changed=0 absent=0`, 25 expected unknown names |
| `ctcan2.sh` surelog (`EXPECT_UNKNOWN=1`) / u2r (`EXPECT_UNKNOWN=6`) | `ok=58 changed=0` / `ok=2 changed=0` — **PASS** both |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0`, both self-tests live |
| `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` | **byte-identical** in both modes (md5s printed, not merely absent from the mover list) |
| `SVSwitch` md5 pin | **`4842211c4030`** on the PATCHED binary, both modes |
| `YosysVerx` md5 pin | **`6ccda350c24a`** on the PATCHED binary, both modes |

### the SEVEN-ROW HEAD SET, both binaries, out of the FULL sweep workdirs

| row | mode | pristine | patched | cmp log |
|---|---|---|---|---|
| `BuildUVMPkg` | default, testflags | 47 / 1 | **29 / 1** | the head MOVED (§ THE HEADLINE) |
| `SeqDriver` | default, testflags | 47 / 1 | 47 / 1 | **BYTE-IDENTICAL** (its database moved; its cmp log did not) |
| `SimpleUVM` | default, testflags | 47 / 1 | 47 / 1 | **BYTE-IDENTICAL** (same) |
| `Scoreboard` | default | 47 / 1 | 47 / 1 | **BYTE-IDENTICAL** (same) |
| `MiniAmiq` | default, testflags | 47 / 1 | 47 / 1 | **BYTE-IDENTICAL** (same) |
| `Earlgrey_0_1` | default / testflags | 46 / 1, 33 / 1 | 46 / 1, 33 / 1 | **BYTE-IDENTICAL** |
| `Rggen` | default | 85 / 1 | 85 / 1 | **BYTE-IDENTICAL** |

`Scoreboard testflags` and `Rggen testflags` print SKIP-NOFILE and are COUNTED,
not hidden.  **ONE head per run on every measured row.**

### the LADDER (measurement only; `uhdm-cmp` is the judge)

`tools/probe/r10ladder1repro/ctladder`, run to fixpoint on BuildUVMPkg/default.
Calibration on this pass's golden against itself: **0 rungs on 183 142
objects.**

| | pristine | patched |
|---|---|---|
| rungs (fixpoint) | **125** | **99** |
| stop | FIXPOINT | FIXPOINT |
| masks / cascades | 125 / 67 | 99 / 61 |
| secs | 93.6 | 91.7 |

Rung-list diff by normalised LHS object: **26 removed, 0 ADDED**, and every one
of the 26 removed rungs is one of this law's prototype objects —
`get_result` ×5, `get_show_max` ×5, `get_recursion_policy` ×3,
`get_verbosity` ×3, `get_check_type`, `object_compared`, `get_imp`,
`get_phase_type`, `get_schedule_name`, `get_default_max_ready_to_end_iterations`,
`m_value_as_string`, `m_value_type_name`, `set_id_count`, `set_max_quit_count`,
`set_message_database`, `set_quit_count`, `set_severity_count`.  Nothing was
un-exposed.

### the boundary gate

`bndsub12.sh` over **580** arm sources — `r10buvm3..11`, `r10oth8`, `r10oth9`,
`r10svs6`, `r10sd8..12`, `r10uvm80`, `r10uvm82..88` (subdirectory arms included,
buvm9's lesson; the list travels on fd 3 with children `</dev/null`, buvm10's
lesson) — on both binaries:

```
-- arms PROCESSED=580 IDENTICAL=573 MOVED=1 REJECT-BOTH=6 ONE-SIDE=0
```

and the ONE moved arm was put back through `grid12.sh` against golden, because
"moved" is not a verdict:

| arm | cmp lines | grid verdict |
|---|---|---|
| `r10buvm4repro/a3_linkgrid` | 108 -> 112, heads 1 -> 1 | **CONVERTED 3, OVER-FIRE 0** |

That arm is buvm4's own LINK GRID and its `oob::later` cells are this law
exactly (`extern` proto, in-body caller).  Its cmp log grew by **4 lines that are
the two `|vpiFunction:` / `\_function:` prints of the now-correct link appearing
in the decompile**; the head OBJECT and its failing field are unchanged (a
pre-existing `constant` `vpiDecompile` 0-vs-1 divergence in the argument list,
which `tf_call::Compare` reaches BEFORE `Function()`).  Verified by diffing the
two cmp logs: `90a91,92` and `108a111,112`, nothing else.

The boundary laws named in the brief — the class method-LISTING laws
(`Task_funcs` assembly, out-of-body listing fields, `extern`, `vpiVirtual`,
uvm80-R2 `VpiAutomatic`, uvm83's `classKeyTsScopeOwner35` and its listing
family, sd10/sd12 `scopedReach`/`scopedOrder`) and the call-emission laws
(§ `writtenCallArgs16`, § `namedTfArgsFormalSlots4`,
§ `namedMethodArgsWritten4`, § `defGenCallNoBind`,
§ `defGenQualPkgCallBinds18`, § `staticScopedCall12`, § `elabInstCallDefSub`,
§ `classInBodyBareCallArgStmtOnly53`, § `blockLocalSameCtrlDepthArgBinds57`,
§ `inheritedNameBindsPkgFn72`) — are in those 573 IDENTICAL arms.  This law
moves **one** field, `func_call::Function()`, and only for a callee the map
holds; it changes no listing, no argument list, no span and no name, and the
census proves it: `ARITY-DIFF`, `G-only` and `P-only` are byte-identical between
the two binaries, corpus-wide.

## 10. reproduce
```sh
./build12.sh                                              # the census instrument
/tmp/r10buvm12cen <golden.uhdm> G > g.cen                 # census golden ...
/tmp/r10buvm12cen <ours.uhdm>   P > p.cen                 # ... and ours
./cenjoin12.py g.cen G p.cen P --limit 60                 # the join
./cenjoin12.py g.cen G <(sed 's/^TC G /TC P /' g.cen) P   # the golden-vs-golden CALIBRATION
./cenall12.sh <workdir> /tmp/cen.txt                      # the corpus-wide census
VERBOSE=1 PRISTINE=<67bb2b0 bin> PATCHED=<patched bin> ./grid12.sh v1_proto12.sv   # ... v2
./allsweeps12.sh                                          # four sweeps, one at a time, --jobs 2
./predict12.sh /tmp/r10buvm12_wds_pristine                # PREDICT FIRST
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/r10buvm12_wds_patched /tmp/r10buvm12_wds_pristine
./attrib12.sh <patched wd> <pristine wd> <rel>/slang.uhdm ...
./ct12rows.sh <baseline.csv> <fresh.csv>
./canaries.sh <fresh.csv> <baseline.csv>; EXPECT_UNKNOWN=<n> ./ctcan2.sh ...
bash canaudit.sh canaries.sh ctcan2.sh
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./detcheck.sh <bin> 3 <arm>.sv
PRISTINE=... PATCHED=... ./bndsub12.sh < <list of ABSOLUTE arm paths>
```
