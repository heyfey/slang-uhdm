# r10uvm144 — § scopedCallArgsBindLikeBareCall144 (+ its fence § ctorFirstBodyItemIsUnlistedNoBind144)

**BuildUVMPkg×2, 55 → 174 cmp lines, one head each, the briefed head OBJECT
CLEARED. Base commit `9d72d85`.**

**FIRST LINE, as the standing rules demand.** **NO ROW CONVERTED.**
`results/gate_uhdm2rtlil.csv` (731 rows) and `results/golden_surelog.csv`
(1588 rows) are byte-identical to the committed baselines — whole ROW, dump
column included, **0 differing rows on both** — and they were only ever READ.
BuildUVMPkg is `CMP_NOTEQUAL` before and after; none was expected.

**SECOND LINE. THE BRIEF'S FRAMING IS REFUTED, IN ITS FIRST CLAUSE.** The brief
said

> "the queue-of-class body local `q` of `uvm_reg_map::unregister`: golden lists
> `array_var` + `array_typespec` + the element `class_var` in `vpiReg` under the
> function's begin block; **ours lists nothing at that slot**."

We list all of it, and have for many passes. Golden's `begin` and ours both
print, in this order,
`|vpiVariables: class_var (…unregister::q)` then
`|vpiVariables: array_var (…unregister::q)`, the `array_var` carrying
`vpiArrayType:4`, a `ref_typespec` onto an `array_typespec` at 75268:17-20, and
the element `class_var` under `vpiReg` over a `class_typespec` at 75268:3-16 —
**byte-identical subtrees**. Nothing about queues, class-typed elements, home
blocks or the 1800.2 macro tree was the defect.

`array_var::Compare` (`~/git-repos/UHDM/build/generated/src/array_var.cpp:137`)
is not what printed the head either. The head is
`ref_obj::Actual_group` — `BaseClass::SafeCompare`'s **SINGULAR** overload
(`~/.local/include/uhdm/BaseClass.h:190`) with `lhs != nullptr` and
`rhs == nullptr`, so the printed `array_var` is the **VALUE golden binds and we
do not**, at

```
uvm_pkg.sv:75269   uvm_reg_block::get_root_blocks(q);
```

golden's argument `ref_obj q` @75269:34 carries `|vpiActual: \_array_var
(uvm_pkg::uvm_reg_map::unregister::q)`; ours carried none. **One field of one
object**, and the whole 55-line head was that object's decompile.

**THIRD LINE.** The defect is a *missing window*, not a missing object, and it
is one arm wide: § `classScopeCallOfOutOfBodyMethodIsFuncCall26` — the arm that
renders `Class::f(...)` as a real `func_call`/`task_call` — was the only USER
call arm in `ExprEmit.cpp` that compiled its arguments **without opening the
§ `classArgBind12` window**. Inside an in-body class method `classMethodNoBind`
is therefore still in force and *every* argument of *every* such call stays
bare. The corpus has exactly one reachable cell; the arms have thirty.

---

## 1. THE LAW

### § scopedCallArgsBindLikeBareCall144

*A CLASS-SCOPE-QUALIFIED call that KEEPS its `func_call` / `task_call` compiles
its ARGUMENTS through the very same binding window a receiver-less call does,
with every fence already written on that window unchanged.*

### § ctorFirstBodyItemIsUnlistedNoBind144  (the fence)

*A variable declared in the FIRST BODY ELEMENT of a NO-ARGUMENT CONSTRUCTOR is
listed on no scope at all, so it binds NOTHING — in any window, in any position,
in either view.*

---

## 2. THE DECODED MODEL (Surelog, read not guessed)

A reference binds EAGERLY, at compile time, in `CompileHelper::bindVariable`
(`src/DesignCompile/CompileStmt.cpp:3089`). It walks the `pexpr` it is handed up
its `VpiParent` chain and inspects only `uhdmfunction` / `uhdmtask` /
`uhdmbegin` / `uhdmmodule_inst` scopes, reading their `Variables()` and
`Io_decls()`. **Two things therefore decide every cell in this pass: whether the
call node was PARENTED before its arguments were compiled, and whether the name
is LISTED on some scope the walk reaches.**

**The window.** `CompileExpression.cpp`'s class-scope arm builds the call at
`:5273-5286`, parents it — `call->VpiParent(pexpr)` at `:5286` — and only THEN
calls `compileTfCallArguments(component, fC, List_of_arguments, …, call, …)` at
`:5369`, which hands each actual that same, already-parented call as its
`pexpr`. That is character-for-character what the receiver-less path does
(`CompileHelper.cpp:4251` `call->VpiParent(pexpr)`, then `:4330`
`compileTfCallArguments(…, call, …)`). The two paths are structurally
identical, so the window and its fences carry over verbatim:

* § `classInBodyBareCallArgStmtOnly53` — inside an IN-BODY class method the
  window opens in **STATEMENT position only**, because in EXPRESSION position
  the enclosing statement node is not parented yet (`stmt->VpiParent(pstmt)` is
  the LAST thing `compileStmt` does, `CompileStmt.cpp:1084`) and the walk
  dead-ends;
* § `controlBodyNoBind28` — a SUBROUTINE local read one control body deeper
  stays bare;
* § `blockLocalSameCtrlDepthArgBinds57` — a local of the UNNAMED block open at
  THAT depth does bind; a NAMED block's does not;
* an OUT-OF-BODY or PACKAGE-FREE caller binds everywhere, as it already did.

**The fence.** § `constructorBodyElementShift27` already decoded the other half:
`CompileHelper::compileClassConstructorDeclaration` (`CompileStmt.cpp:2165`)
reads its `tf_port_list` with `fC->Child(nodeId)`, and **with no port list the
node it takes for one is the FIRST BODY ELEMENT** — which is therefore consumed
and never compiled. When that element is a declaration, no variable object of it
is ever listed, on the function or on the body `begin`, so `bindVariable` walks
straight past and returns null. `emitCtorBody27` (`StmtEmit.cpp:1339`) already
computes exactly that skip as `firstCounted` / `walkFrom`; this pass records the
declarations the walk does not reach and lets ExprEmit read that decision rather
than re-derive a predicate for it.

**Why a constructor-wide gate is WRONG, and how it was caught.** A first cut
gated on `MethodFlags::Constructor` + "declared in the subroutine scope". The
WIDE BOUNDARY GATE convicted it on `r10uvm28repro/t38a/dut.sv`, § 28's own arm,
where `function new(int a); int lb; int li = 7; … mm(lb); mm(li);` is golden
**BOUND** — a constructor WITH a port list eats nothing. Arm G then read the
split off one golden: `g09 function new(); int s9; int q9[$]; …` binds **q9 and
not s9** — the SECOND declaration of the SAME constructor. Only the
first-element rule gets that cell.

---

## 3. THE PRODUCTION CHANGE (three hunks, 129 added lines, ~14 of them code)

```c++
// src/ExprEmit.cpp — inside § classScopeCallOfOutOfBodyMethodIsFuncCall26's
// argument loop (~18568), the window this arm never opened:
ClassArgBindIf38 cab26(classArgBindDepth12,
                       callStmtCtx0 || !(curSubClassScope9 && !curSubOob9));

// src/ExprEmit.cpp — one more disjunct in the reference-silence test:
bool ctorSubLocalNoBind144 =
    !curSubOob9 && !ctorUnlistedBid144.empty() &&
    nv.symbol.kind == SymbolKind::Variable &&
    ctorUnlistedBid144.count((const void*)&nv.symbol) != 0;

// src/StmtEmit.cpp — emitCtorBody27, before its walk:
for (size_t i = 0; i < el.size(); ++i)
    if (el[i].k == EK_BID && (i < from || i >= to))
        ctorUnlistedBid144.insert(
            (const void*)&el[i].st->as<VariableDeclStatement>().symbol);
```

The window expression is § `classInBodyBareCallArgStmtOnly53`'s own, copied
verbatim from the generic call arm (`ExprEmit.cpp:20415`); no new predicate is
introduced there. `ClassArgBindIf38` only ever *raises* the depth, so a scoped
call nested inside an already-open window keeps it (arm C `c14`).

---

## 4. THE GRIDS

Every arm is built with Surelog in **both views** (`-parse` and
`-parse -elabuhdm`, each with its own golden) and with both frozen binaries;
every child rc is printed; scoring is `argscan144.py`'s CALL-ARGUMENT census,
keyed on the object's OWN fields (`|vpiName`, `line:col`) and the ACTUAL's UHDM
KIND — never on the dump-synthesized `vpiFullName`.

| arm | grid | wrong cells DEF | wrong cells ELAB |
|---|---|---|---|
| B `g144_b.sv` | the corpus shape: queue-of-class / int-queue / scalar handle through `C::f(...)`, virtual and plain, blockifying and not | 5 → **0** | 0 → **0** |
| C `g144_c.sv` | POSITION (statement / assignment RHS / if-cond / while-cond / return / operand / nested scoped call / inside `$display` / for-body / if-body) × OWNER (in-body, out-of-body, package free, module class, module subroutine) × ARGUMENT KIND (subroutine local, formal, class property, unnamed-block local, named-block local, queue) + bare-call controls | 6 → **0** | 1 → **0** |
| D `g144_d.sv` | SHAPES (queue / dynamic / associative / fixed unpacked / scalar) × ELEMENT KINDS (class handle / typedef'd class / parameterized specialization / int / string / packed struct / enum) × HOMES (function top / after statements / explicit begin-end / fork arm / task / void function / static method / constructor / qualifier+lifetime stub / out-of-body) × 1 and 3 instances | 21 → **0** | 0 → **0** |
| E `g144_e.sv` | the CONSTRUCTOR grid: sub-scope local, formal, unnamed-block local, out-of-body ctor, ordinary-method twin, escaped `\new`, `super.new()` first, and the receiver-less controls | 5 → **0**\* | 6 → **0**\* |
| F `g144_f.sv` | § 32's QUALIFIER SPELLINGS (defining class / own typedef / `this_type` / derived-for-base / base-for-own / in-body static) and the PACKAGE-qualified free function in statement and expression position | 3 → **0** | 0 → **0** |
| G `g144_g.sv` | the ctor FIRST-BODY-ELEMENT split: scalar vs queue, initialised or not, one vs two declarations, ports vs no ports, scoped vs receiver-less call, ordinary-method twins | 7 → **0** | 7 → **0** |

Plus the four arms the wide boundary gate reported as movers, re-measured
against their own goldens: `r10buvm22repro/g22.sv`, `r10buvm32repro/g32a3.sv`,
`r10uvm28repro/t38a/dut.sv`, `r10uvm64repro/v2_ctx.sv` — **0 wrong cells in
both views** after the pass (§ 32's `g32a3` and § 28's `t38a` both improve;
see §6).

**Over all ten arms × both views: 61 wrong binding cells → 0, and nothing moved
away.** (`ARMS.r10uvm144.txt`.)

\* Arm E scores 0 on the BINDING key. On the FULL census key (which also carries
the reference's own `line:col`) one row survives in DEF and two in ELAB: `vc09`,
whose reference column reads 33:72 where golden reads 33:76. That is the
escaped-identifier span residue, PRE-EXISTING — pristine reads 33:72 too — and
it is recorded as R2, not fixed here.

**Measured negatives, kept as negatives.**
* A CLASS PROPERTY argument stays bare in every window (arm C `c09`, arm D
  `d40`) — that is § `pkgVarBindsOnlyThroughInstance88`/`classPropRefs`
  territory, untouched.
* The DEGRADED half of § 32 is untouched: a qualifier that is a typedef of the
  own class, a `this_type`, a derived class written for a base method, or an
  in-body static method all collapse to a bare `ref_obj` **with no arguments at
  all** (arm F `f02`/`f03`/`f04`/`f06`) — there is nothing to bind.
* A PACKAGE-qualified free function (`q144f::pjoin(sq)`) never reaches this arm;
  it takes the generic call arm, which already opened the window. Its
  expression-position cells stay bare on both sides (arm F `f08`/`f09`) — these
  are the corpus's own `uvm_pkg::m_uvm_string_queue_join(qs)` population, and
  the pass does not move one of them.
* An operation OPERAND inside a scoped call's argument binds too (arm C `c16`,
  golden agrees), and a CONCATENATION operand does not (`c17`, no ref_obj row).
* Reachability, instance count and specialization count are not distinguishers.
* Arm E `vc09` (the escaped `\new`) keeps a PRE-EXISTING **column** residue on
  the reference itself (`33:72` vs golden `33:76`); its BINDING is now golden's.
  Pristine has the same column. Not this pass's, recorded in §7 as R2.

---

## 5. PREDICTION AND MOVERS

`pred144.cpp` names, from the PRISTINE databases and before the patched sweep,
every database holding (A) a `::`-named `tf_call` owning a BARE `ref_obj`
argument or (B) a BOUND `ref_obj` inside a class-parented constructor — a
deliberate over-approximation of both halves. Over **956** surelog and **1358**
uhdm2rtlil databases it returns **17** candidates and **0**
(`PREDICT.r10uvm144.txt`).

`byteverify.sh SELFCHECK=1` then measured **MOVERS 2 / 956** and **0 / 1358** —
`default/BuildUVMPkg-bf853d43` and `testflags/BuildUVMPkg-bf853d43`, the
predicted set, by name, and nothing else. The order-blind, path-normalised
whole-dump diff attributes all of it: **2 added lines per mode, 0 removed**, and
they are the head's own `|vpiActual:` and the `array_var` it names
(`MOVERS.r10uvm144.txt`). Scoreboard/default — the ~50/50 `vpiTaskFunc`-order
COIN — did not flip this run, so no coin attribution was needed.

The other 15 candidates did not move: their `::`-named calls are
PACKAGE-qualified free-function calls, which take the generic arm.

---

## 6. THE WIDE BOUNDARY GATE

`bound144.sh`, run from a COPY of the whole probe tree, subdirectories included,
the file list read on fd 3, children `</dev/null`, `PROCESSED` asserted against
`LISTED`, scratch keyed on the RELATIVE path. It compiled

```
LISTED=4116 PROCESSED=4116 PRODUCED_DBS=3972 MOVED_ARMS=9 RC_DIFFS=0
```

in both views with both frozen binaries. **Six of the nine movers are this
pass's own arms** — the positive control that proves the gate can see. The other
three (`BOUNDARY.r10uvm144.txt`):

* `r10buvm32repro/g32a3.sv`, § 32's OWN arm — **one added bind**,
  `tder32::tdt32(a)` @24:21 in an in-body class TASK, golden `io_decl(a)`.
  **TO-GOLDEN**; its arg-census wrong cells go 1 → 0 (DEF), 0 → 0 (ELAB).
* `r10uvm64repro/v2_ctx.sv`, § 64's arm — **one removed bind**, `work@v2c::new`'s
  `if (nfarg == 0)` @142:9, where `nfarg` is the FIRST BODY ELEMENT of a
  no-argument constructor. Golden's operand is BARE and ours was bound.
  **TO-GOLDEN**, and it is the fence's corpus-shaped witness in the *condition*
  window rather than the argument window.
* `r10buvm22repro/g22.sv` — the OFFICIAL `uhdm-cmp` output for this arm is
  **BYTE-IDENTICAL** before and after (DEF 17506 lines / ELAB 26436 lines, one
  head each). The whole dump delta is TWELVE lines: three uninterpretable
  NUMBERS, printed twice each, in OURS-ONLY objects. Decoded and controlled as
  R3 below.

**`r10uvm28repro/t38a/dut.sv` — § 28's own arm — MOVED under the FIRST cut of
the fence and is what convicted it; with the shipped first-body-element rule it
does not move at all.** No `r10uvm77-79`, `r10uvm82-91`, `r10uvm84/85`,
`r10uvm89`, `r10buvm3-15`, `r10sd8-12`, `r10uvm46/47/71/87/113/139/141` arm
moved. § 141's qualifier+lifetime stub cell is byte-identical pristine to
patched in arm D (`d27`), and § 71's constructor cell keeps golden's empty
listing everywhere.

---

## 7. GATES (`GATES.r10uvm144.txt`) — all green

Both binaries frozen at immutable paths (`chmod 555`) before any sweep; every
`cmds.txt` audited by BINARY PATH — 1523/1523 surelog and 1458/1458 uhdm2rtlil
name the patched binary, 0 name anything else, and the pristine control workdirs
likewise name only the pristine binary. `GOLDEN_DEFER` left **UNSET**. `git
stash` never used. `results/*.csv` only READ. slang not patched. The four
slang-fenced tests were never dispatched (`canaudit`: `audited=29 UNCOVERED=0
FENCE-BREACH=0`).

* goldens **23/0** with `SLANG_UHDM` exported explicitly; `/bin/false` **0/23**.
* uhdm2rtlil **679/50/2** in BOTH modes; `ct8rows` PASS against the committed
  baseline AND against my own pristine control, status and dump column.
* surelog corpus `ct8rows` PASS — **0 differing rows over 1588** against the
  committed baseline and against my own pristine control. The pristine control
  was itself checked byte-identical to the committed baselines first, so it is
  not a stale control. **NO ROW CONVERTED.** Status histograms identical:
  default 471 EQUAL / 283 REJECT / 25 SURELOG_FAIL / 10 NOTEQUAL / 5 DEFERRED,
  testflags 466 / 284 / 23 / 9 / 5.
* `byteverify SELFCHECK=1`: **MOVERS 2 / 956** (surelog) and **0 / 1358**
  (uhdm2rtlil), PATH_SETS_IDENTICAL on both, every mover PREDICTED BY NAME.
* canaries `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS both; SVSwitch
  `4842211c4030` and YosysVerx `6ccda350c24a` held; InterfaceModPort,
  BlackParrotComplex and YosysOldOr byte-identical in both modes.
* Heads: SeqDriver 6254, SimpleUVM 29, Scoreboard/default 29, MiniAmiq 6222,
  Earlgrey_0_1 110/142, Rggen 0 — **all unchanged**; **BuildUVMPkg 55 → 174,
  both modes**, one head per run throughout, the two heads byte-identical to
  each other.

---

## 8. RESIDUES AND R0

**R0 (the new BuildUVMPkg head, both modes, 174 cmp lines, one object).** A
`hier_path` ELEMENT shape mismatch at `uvm_pkg.sv:76967` in
`uvm_reg_map::do_bus_access`:

```
rw.value[idx][8 * i +: 8]
```

Golden's element at that slot is a **`var_select`** named `value`
(76967:20-38) carrying **two** `vpiIndex` children — the `ref_obj idx` (bound to
the loop's `array_var`) and an `indexed_part_select` named `value` — while ours
is a **flat `indexed_part_select`** named `value[idx]` (76967:20-37) with the
`idx` step folded into its NAME and no `var_select` at all. Both sides agree on
the `vpiBaseExpr` operation (`8 * i`, with `i` bound) and the `vpiWidthExpr` 8.
A SELECT-CHAIN element under a `hier_path` is the shape to decode; § 89's
`hpTrailSelIdxDecompiled89` and § 14's
`builtinRecvMultiDimStepIsBitSelectChain14` are the neighbouring laws and their
arms must not move. (`head_pat_BuildUVMPkg.default.cmp`.)

**R1 — the OTHER window this pass did not open.** § 26's arm also has a
DEGRADED half: when `getTaskFunc("<Class>::<f>")` misses (§ 32), the call
collapses to a bare `ref_obj` and **its arguments are dropped entirely**. That
matches golden today (arm F `f02`/`f03`/`f04`/`f06`) and is untouched.

**R2 — the escaped-`\new` reference COLUMN.** Arm E `vc09`
(`function int \new (int a); int vc09[$]; B144::qint(vc09);`) binds correctly
now, but the argument `ref_obj`'s own span reads 33:72 where golden reads 33:76
— the four columns of the escaped identifier's trailing space. PRE-EXISTING
(pristine reads 33:72 too), corpus-invisible (no corpus source writes `\new`),
and not a binding fact.

**R3 — an UNCHECKED DOWNCAST in `buildUnpackedArrayTypedefTs`.** Found by this
pass's boundary gate, decoded, controlled, and deliberately NOT fixed here:
`src/TypeEmit.cpp:10771` does `ct.as<FixedSizeUnpackedArrayType>()` with no kind
test and is reached for an ASSOCIATIVE typedef through the elaborated clone
path, so `fua.range` at `:10855` prints whatever an `AssociativeArrayType`
holds at that offset. Golden models that slot as the `associative` MARKER
constant — which our non-clone twin already emits — so the object is ours-only
and wrong before and after. Two controls built from 9d72d85 in a separate
worktree (a file-scope `volatile int`; and ONLY the shipped `std::set` member
with no reader) both reproduce the PRISTINE numbers, so it is neither a
code-layout nor an exporter-object-size effect. `uhdm-cmp`'s output on that arm
is byte-identical before and after.

**R4 — § 141's `vpiAutomatic` residue survives**, unchanged and still
corpus-invisible; and § 46's COLLAPSE (several qualifier+lifetime methods in one
class fusing into ONE golden object) is likewise untouched.

---

## 9. FILES

| file | what it is |
|---|---|
| `arm144.sh` | build one arm: Surelog golden in BOTH views + both frozen binaries + official `uhdm-cmp`; every rc printed |
| `bound144.sh` | the wide boundary gate, run from a COPY of the probe tree |
| `argscan144.py` | the CALL-ARGUMENT binding census out of a `uhdm-dump`: call kind × SCOPED/PLAIN × call name × argument ref name × line:col × the ACTUAL's UHDM KIND and name. No fullname, no id |
| `score144.sh` | golden / pristine / patched scoring of one arm dir, both views |
| `corpcen144.sh` | the same census over the NAMED corpus rows of a `verify_golden` workdir, multiset-joined |
| `pred144.cpp` / `pred144.sh` | the a-priori mover predictor over pristine databases (arm A the window half, arm B the fence half) |
| `g144_b.sv` … `g144_g.sv` | the six grids |
| `head_pris_*.cmp` / `head_pat_*.cmp` | official `uhdm-cmp` heads for all seven named rows, before and after |
| `PREDICT` / `MOVERS` / `BOUNDARY` / `CENSUS` / `ARMS` / `GATES` `.r10uvm144.txt` | the measurements above |
| `byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh` | the gate scripts, carried so this directory runs standalone |
