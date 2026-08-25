# r10uvm150 — § `rootCallEatsTheChain150`

**BuildUVMPkg×2, 68 → 30 cmp lines, one head each, THE BRIEFED HEAD OBJECT
CLEARED.  Base commit `074c38c`.**

**FIRST LINE, as the standing rules demand.  NO ROW CONVERTED.**
`results/gate_uhdm2rtlil.csv` (731 rows) and `results/golden_surelog.csv`
(1588 rows) are byte-identical to the committed baselines — whole ROW, dump
column included, **0 differing rows on both** — and they were only ever READ.
BuildUVMPkg is `CMP_NOTEQUAL` before and after; none was expected.

**SECOND LINE — THE BRIEF'S FRAMING IS REFUTED, AND THE REFUTATION IS THE
LAW.**  The brief said *"golden's hier_path lists a func_call element
`uvm_root::get` before the method_func_call `uvm_report_enabled`; ours lacks
that element."*  Read from the pristine cmp log and the golden dump on this
pass's own build: **there is no hier_path on either side, and golden has no
`method_func_call` at all.**  Golden's `if_stmt` at `uvm_pkg.sv:29217` carries

```
|vpiCondition:
\_func_call: (uvm_root::get), line:29217:10, endln:29217:18
  |vpiName:uvm_root::get
  |vpiFunction:
  \_function: (uvm_pkg::uvm_root::get), line:38754:1, endln:38757:12
```

and **nothing else** — the whole written
`uvm_root::get().uvm_report_enabled(UVM_LOW,UVM_INFO,"UVM/REPORT/CATCHER")`
renders as its RECEIVER CALL alone.  Ours was the mirror image: a bare
`method_func_call (uvm_report_enabled)` @`29217:26-44` with three arguments and
no prefix — the METHOD kept, the RECEIVER dropped.  Surelog is LOSSY here and
the campaign's target is Surelog, warts included.

**THIRD LINE.**  The head is four written sites, not one, and the same law
clears all four: `29217` (an `if` condition) and `29218` (its statement twin),
repeated verbatim at `29526`/`29527`.  All four are now **byte-identical to
golden**, in both dump views, in both modes.

---

## 1. THE LAW

### § rootCallEatsTheChain150

*When the ROOT of a written postfix chain is a CALL, Surelog compiles THAT CALL
and discards everything written after its closing paren — `.method(args)`,
`.property`, `[index]`.  The rendered object is exactly what the root call
alone renders as; the discarded chain contributes NOTHING to the database, in
either view, in every context and every home.  Only a chain whose root is a
NAME takes the hier_path road and keeps its steps.*

Its four sub-rules, one per root kind, each measured cell by cell:

* **SCOPED root that binds** (`A::f(...)`, `pkg::f(...)`, `G#(...)::f(...)`)
  — a `func_call`/`task_call` named `<first written segment>::<final
  identifier>`, spanned over the **first segment's identifier token alone**,
  carrying **its own arguments** and its `vpiFunction`/`vpiTask`.  The span is
  the same with a chain and without one.
* **SCOPED root that misses** — the `ref_obj` of § `staticScopedCall12`,
  spanned from the start of the scoped name to just before the final
  identifier, arguments dropped **by that law, not by this one**.
* **`this.` / `super.` root** — a `method_func_call` named after the FIRST
  method, spanned over the method token, with the unparented `"this"`/`"super"`
  string constant as `vpiPrefix` and **the first method's own arguments kept**.
* **BARE root** (an unqualified subroutine name) — a `func_call`/`task_call`
  with its binding and its own arguments, spanned over the **WHOLE WRITTEN
  EXPRESSION, the discarded chain included**.  This is the one sub-rule whose
  span differs from the standalone call, and the arm pair `d5`/`d6` pins it:
  `dmk(51).twice(52)` → `func_call dmk` @`42:29-46`, `dmk(51)` alone →
  `func_call dmk` @`44:41-48`.

**THE FENCE.**  A NAME root is a different road and must not move:
`hd.nxt().GO(6,7)` is golden's `hier_path (hd.nxt)` with THREE elements
(`ref_obj hd` > `method_func_call nxt` > an ANONYMOUS argument-less
`method_func_call` @`38:39-46`), and `lv.mul(1)` / `hd.NIL()` / `arr[2].rd(11)`
are the two-element form.  `rootCallEatsChain150` refuses every one of them.

---

## 2. THE DECODED MODEL (Surelog, read not guessed)

Every dotted expression enters `CompileHelper::compileComplexFuncCall`
(`src/DesignCompile/CompileExpression.cpp:5039`), which dispatches **once** on
the type of `name` — the FIRST node of the chain — and never revisits it.

| Surelog site | root written as | what it mints | what it does with the rest |
|---|---|---|---|
| `CompileExpression.cpp:5253` `paClass_scope` | `A::f(...)` | `getTaskFunc(basename)` at `:5271`; on a hit `MakeFunc_call`/`MakeTask_call` `:5277`/`:5280`, `populateCoreMembers(Class_type_name, Class_type_name, call)` `:5286` — **the class-name token alone** — `VpiName(basename)` `:5366`, `compileTfCallArguments(..., List_of_arguments, ...)` `:5369` where `List_of_arguments = fC->Sibling(Class_scope_name)` — the FIRST argument list only | `result = call` `:5373`; the sibling carrying `.method(args)` is never read |
| the same arm, `:5375` | `A::f(...)`, lookup missed | `compileExpression(component, fC, name, ...)` → the bare `ref_obj` of § `staticScopedCall12` | same — never read |
| `CompileExpression.cpp:5154` `paImplicit_class_handle` | `this.m(...)` / `super.m(...)` | `MakeMethod_func_call` `:5171`, `Prefix(object)` `:5175`, `populateCoreMembers(Method, Method, fcall)` `:5179`, arguments from `fC->Sibling(Method)` | `result = fcall` `:5185`; returns |
| `CompileHelper.cpp:4213` (the `else` arm of `compileTfCall`) | `f(...)` | `MakeFunc_call`/`MakeTask_call`, `getTaskFunc(name)`, spanned over the WHOLE `Subroutine_call` node | the chain is inside that node, so it only WIDENS the span |
| `CompileExpression.cpp:5455` | `v`, `v[i]` | `MakeHier_path` + the `while (dotedName)` loop, `:5610-5686` pushing one `method_func_call` per `paMethod_call_body` | **KEPT** — this is the only road that keeps the chain |

`CompileHelper::compileTfCall` routes statement position to the same place:
`leaf_type == paClass_scope` (`CompileHelper.cpp:4209`) and
`leaf_type == paImplicit_class_handle` (`:4157`) both `return
compileComplexFuncCall(...)`.  That is why golden's `29218` statement twin has
the identical shape to the `29217` condition.

**Nothing on any of those roads reads a symbol table for the discriminator.**
The WRITTEN FORM decides, and slang hands it over unambiguously: a dot after a
NAME is parsed as a `ScopedName`, a dot after a CALL as a
`MemberAccessExpression`.  `rootCallEatsChain150` reads exactly that.

**SURELOG'S OWN PARSER FENCES THE REST.**  `Cls::f().name[i]`,
`Cls::f().a().b(...)`, `bare().a().b()` and `Cls::f().arr.sum()` are all
`[SNT:PA0207] Syntax error` — see `g150_e.sv`, which is committed as a
GRAMMAR-FENCE arm with no golden and is deliberately NOT modelled.

---

## 3. THE PRODUCTION CHANGE

One helper and one guarded early return in `src/ExprEmit.cpp`'s
`ExpressionKind::Call` arm:

```c++
if (call.thisClass()) {
    if (int rc150 = rootCallEatsChain150(expr.syntax)) {
        auto& recv150 = stripImplicitConv(*call.thisClass());
        callStmtContext = callStmtCtx0;
        if (auto* r150 = emitExpr(recv150, parent, prefix, netMap)) {
            if (rc150 == 2 && expr.syntax)
                setLoc(r150, expr.syntax->sourceRange());
            return r150;
        }
        return nullptr;
    }
}
```

It mints nothing of its own: the receiver is emitted through the arms that
already render a standalone root call correctly (§ `classScopeCallOfOutOfBody
MethodIsFuncCall26` / § `classScopeCallWrittenQualifierIsLookupKey32` for the
scoped root, § `staticScopedCall12` for the degraded one, § `thisRecvCall11` /
§ `superMethodCall17` for `this.`/`super.`, the ordinary user-call arm for the
bare root), which is why the four corpus sites come out byte-identical to
golden including the `vpiParent` asymmetry golden shows there (the condition's
call is parented at the enclosing `begin`, the statement's at the `if_stmt`).
`rc150 == 2` is the single span correction the bare root needs.

---

## 4. THE GRIDS

Four golden arms (`g150_a/b/c/d.sv`), deliberately UNPARALLEL in naming style,
ordering, numbers and case so an agreeing cell cannot be self-confirming, plus
the grammar-fence arm `g150_e.sv`.  Axes actually varied:

* **receiver shapes** — out-of-body static class method, in-body static class
  method, package free function (qualified and unqualified), parameterized
  class, `this.`, `super.`, a bare in-body method, a plain variable, an indexed
  variable, a variable-rooted two-method chain, a call returning a struct
* **call kinds** — function, task, void function, property access (no call)
* **argument counts** — 0, 1, 2, 3, on the ROOT and on the discarded method
* **contexts** — `return` expression, `if` condition (bare and inside an
  operation), assignment Rhs, call argument, `$display` argument, bare
  statement, `while` body, `for` body
* **homes** — in-body class method, OUT-OF-BODY class method, package free
  function, module function, `initial` block
* **instances** — one, two and three per expression
* **views** — DEF and ELAB, every cell, both

Scores (`ARMS.r10uvm150.txt`, `score150.py`; JUDGE scoring drops `VpiParent`
and `VpiFullName`, which no generated `Compare` reads):

| view | FIXED | BROKEN | MOVEDWRONG | UNMOVED | RIGHT |
|---|---|---|---|---|---|
| DEF  | 32 | **0** | 1 | 11 | 6 |
| ELAB | 32 | **0** | 1 | 11 | 6 |

The single `MOVEDWRONG` is `c3f`, `Gen0#(int,2)::gGet().mul(7)`: patched gives
`func_call Gen0::gGet` @`45:30-34` with golden's name and golden's span but
**no `vpiFunction`**.  The control `c10f` — the SAME call written STANDALONE —
is missing `vpiFunction` in the PRISTINE binary too, so this is a pre-existing
§26 residue on class SPECIALIZATIONS (`pendingScopedCallBind26` never resolves
for one), newly exposed rather than caused.  Its corpus reach is zero.

---

## 5. THE CENSUS

`ct150cen.cpp` over the NINE UVM databases (five row families × both modes,
Scoreboard/testflags SLANG-REJECTs), joined as a MULTISET by `join150.py`.
Golden-vs-golden calibrates at **0 rows changed** on both BuildUVMPkg and
SeqDriver.

Two populations per database: `HP` = every `hier_path` whose `Path_elems` carry
a call element (the NAME-rooted road, 4258–7347 rows per database); `CALL` =
every call object NOT inside a `hier_path` (9976–17426 per database).

| database | rows changed |
|---|---|
| SeqDriver default / testflags | none |
| SimpleUVM default / testflags | none |
| Scoreboard default | none |
| MiniAmiq default / testflags | none |
| BuildUVMPkg default | **FIXED 10** |
| BuildUVMPkg testflags | **FIXED 10** |

**TOTAL: TO-GOLDEN 20, AWAY-GOLDEN 0, STILL-WRONG 0, MOVED-WRONG 0.**
Six rows deleted per database (`method_func_call uvm_report_enabled` NARG=3
×2, `method_func_call uvm_report_info` NARG=7 ×2, and the spurious
`func_call uvm_pkg::m_uvm_string_queue_join` NARG=1 ×2 that lived inside the
discarded argument list), four minted (`func_call uvm_root::get` NARG=0
BOUND=1 at `29217:10-18`, `29218:8-16`, `29526:10-18`, `29527:8-16`) — every
one of the four matching a golden row that had **no ours-side partner**.

*The key deliberately excludes `VpiFile`.*  A first cut that keyed on
`basename(VpiFile)` reported the four new `func_call`s as AWAY-GOLDEN phantoms,
because our emitter leaves `VpiFile` EMPTY on these objects and golden's
identical rows sat under a different key.  Recorded here as the census trap it
was.

**Whole-dump check.**  `uhdm-dump` of BuildUVMPkg pristine vs patched,
path- and id-normalised, ORDERED: **3 hunks** — one is the dump banner (the
workdir path), the other two are the `29217/29218` and `29526/29527` sites.
Every changed dump line names source line 29217, 29218, 29526, 29527 (the four
written sites), 38754 (`uvm_root::get`'s function object, newly referenced by
`vpiFunction`) or 9008 (`m_uvm_string_queue_join`, whose spurious call goes
away).  Both `if_stmt` subtrees, in both dump views, are `patched == golden:
True` and were `pristine == golden: False`.

---

## 6. THE REACH — WHY ONLY FOUR CELLS

`scan150.py` / `scan150b.py` strip comments and string literals and find every
`)` followed by `.<identifier>` with balanced parens across **all four corpus
roots** (`Surelog/tests`, `Surelog/third_party/tests`,
`Surelog/third_party/UVM`, `uhdm2rtlil/test`).  The complete population:

* **SCOPED root — 5 written sites**: `uvm_pkg.sv:29217/29218/29526/29527`
  (BuildUVMPkg) and `Ibex/.../core_ibex_base_test.sv:89`.
* **BARE root — 4 real chains**, all in `Ibex` / `IbexGoogle` / `Opentitan`
  (`report_message.get_report_object().get_full_name()`,
  `satp.get_field_by_name("PPN").bit_width`,
  `hart_cfg_rg.get_field_by_name(...).set(...)`).
* the remaining `) .` hits are `virtual iface#(N).modport`, a module
  instantiation and `(* attr *) .port(...)` — not chains.

`Ibex`, `IbexGoogle` and `Opentitan` are `SLANG_REJECT` in BOTH modes
(`results/golden_surelog.csv`, read-only, in this worktree) and `BlackParrot`
is `SURELOG_FAIL`, so **not one of them produces a database to compare**.  The
prediction written before the patched sweep (`PREDICT.r10uvm150.txt`) named
BuildUVMPkg/default and BuildUVMPkg/testflags and nothing else; `byteverify.sh`
found `MOVERS: 2 / 956`, exactly those two, by name.

---

## 7. RESIDUES

* **`.property` / `[index]` after a root call** — golden renders the root call
  there too (`BLD::OB().V` → `func_call BLD::OB` @`31:30-33`, `Pc3::pcWord().hi`
  → `func_call Pc3::pcWord`), and we emit NOTHING (a
  `noteUnsupported("member access base")`).  That path is a `MemberAccess`
  expression, not a `CallExpression`, so this pass's arm never sees it.  Arm
  cells `b01`, `c6f`, `a c08` are the golden record; corpus reach is zero.
* **`vpiFunction` on a SPECIALIZED class's scoped call** (`c3f`/`c10f`) — a
  pre-existing § `classScopeCallOfOutOfBodyMethodIsFuncCall26` residue, proven
  pre-existing by the standalone control, corpus reach zero.
* **`Cls::f().a().b()` and friends** — refused by Surelog's own parser; no
  golden exists.  `g150_e.sv` keeps the shapes for a later pass.

**R0 (the next head).**  BuildUVMPkg's new head, both modes, 30 cmp lines, one
head: `uvm_pkg.sv:38763` — golden's `class_typespec (uvm_report_handler)`
carries `VpiName` **and** `vpiInstance -> package uvm_pkg`, ours carries
neither (`class_typespec: ,` with only `vpiClassDefn`).  Its owner is the
`class_var uvm_pkg::rh` at `38763:22-24`.

---

## 8. FILES

| file | what it is |
|---|---|
| `g150_a.sv` … `g150_d.sv` | the golden grids (receiver shapes, call kinds, arg counts, contexts, homes, instances) |
| `g150_e.sv` | the GRAMMAR FENCE — four shapes Surelog's parser refuses |
| `arm150.sh` | build one arm with Surelog + both frozen binaries, both views, score with the official uhdm-cmp |
| `bound150.sh` | the boundary gate over EVERY committed arm (subdirectories included, fd-3 file list, PROCESSED asserted, relative-path scratch keys) |
| `ct150cen.cpp` / `corpcen150.sh` / `join150.py` | the call-chain census and its multiset join |
| `score150.py` | the per-cell arm scorer (STRICT and JUDGE modes) |
| `scan150.py` / `scan150b.py` | the corpus-wide reach scan |
| `PREDICT.r10uvm150.txt` | the mover prediction, written from pristine data before the patched sweep |
| `ARMS.r10uvm150.txt` / `CENSUS.r10uvm150.txt` / `GATES.r10uvm150.txt` / `BOUNDARY.r10uvm150.txt` | the evidence |
| `head_pris_*.cmp` / `head_pat_*.cmp` | every row's head log, before and after |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the standing gates, carried so this directory runs on its own |
