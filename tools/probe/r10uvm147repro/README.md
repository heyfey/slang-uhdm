# r10uvm147 — § `selChainElemShapeIsSyntactic147`

**BuildUVMPkg×2, 174 → 68 cmp lines, one head each, the briefed head OBJECT
CLEARED. Base commit `c67afc7`.**

**FIRST LINE, as the standing rules demand. NO ROW CONVERTED.**
`results/gate_uhdm2rtlil.csv` (731 rows) and `results/golden_surelog.csv`
(1588 rows) are byte-identical to the committed baselines — whole ROW, dump
column included, **0 differing rows on both** — and they were only ever READ.
BuildUVMPkg is `CMP_NOTEQUAL` before and after; none was expected.

**SECOND LINE. THE DEFECT IS ONE `if` CONDITION AND IT MODELS NOTHING.** The
production change is **one line of code** (66 inserted / 5 deleted, 65 of the
insertions being the decoded comment): a gate that read

```c++
if (!mchain.empty() && mb->kind == ExpressionKind::NamedValue &&
    (mb->as<NamedValueExpression>().symbol.kind == SymbolKind::Variable ||
     mb->as<NamedValueExpression>().symbol.kind == SymbolKind::Net)) {
```

now reads

```c++
if (!mchain.empty() && mb->kind == ExpressionKind::NamedValue) {
```

The `Variable || Net` test came in with wave-32 as a conservative guess.
Surelog has no such test: `compileSelectExpression` decides the shape of a
`hier_path` select element from the **SELECT GRAMMAR** alone and never looks at
what the base name resolves to. The gate was hiding this arm from every base
that is not a plain variable — a **formal argument** (the head), a class
property, a struct-typed localparam — and those references fell through to the
dotted-interface arm, which flattens the whole chain into ONE
`indexed_part_select` named `value[idx]`.

**THIRD LINE.** The head was **two sites, not one**, and the same law clears
both: the briefed rvalue at `uvm_pkg.sv:76967` and its LVALUE twin at
`77065` — `rw.value[idx][i0*8+:8] = p[…]` — whose golden shape is the SPLIT
(`bit_select` @MID + an ANONYMOUS trailing part-select element) that this arm's
`inLhs` branch already modelled and never got to run.

---

## 1. THE LAW

### § selChainElemShapeIsSyntactic147

*The SHAPE of a `hier_path` element that carries a select chain is decided by
the WRITTEN SELECT CHAIN alone. What the base name resolves to — a variable, a
net, a formal argument, a class property, a static property, a parameter — is
not a discriminator, in either view, in either position.*

Its two halves, both already implemented in the arm this pass unlocks:

* **RVALUE** — more than one select step on the member mints a `var_select`
  named after the MEMBER, whose `vpiIndex` list takes ONE ENTRY PER STEP in
  source order: a plain index contributes the compiled index EXPRESSION itself,
  a trailing range contributes a `part_select` / `indexed_part_select` carrying
  the MEMBER's name in both `vpiName` and `vpiDefName`. A SINGLE step yields
  the flat object instead.
* **LVALUE** — the same chain splits into a `bit_select` / `var_select`
  element for the index steps and a SEPARATE, ANONYMOUS `(indexed_)part_select`
  ELEMENT for the trailing range.

---

## 2. THE DECODED MODEL (Surelog, read not guessed)

`CompileHelper::compileSelectExpression`
(`src/DesignCompile/CompileExpression.cpp:1258`) is the function that mints
every one of these objects, and it is driven by node types only:

| Surelog line | what it reads | what it mints |
|---|---|---|
| `:1272` | `fC->Child(Bit_select) && fC->Sibling(Bit_select)` — **more than one select step** | a `var_select`, `VpiName(name)`, empty `Exprs()`, parented at `pexpr` |
| `:1310` | a `paBit_select` with an expression child | compiles the index and **pushes the index EXPRESSION** into `Exprs()`, re-parenting it at the `var_select` |
| `:1350` | a `paPart_select_range` | calls `compilePartSelectRange(…, name, …)` and **pushes what it builds** into `Exprs()` |
| `:1330` | a lone index, no sibling | a flat `bit_select` |
| `:1368` | a lone range, no sibling | the bare `part_select` / `indexed_part_select` (`result = sel`) |

`compilePartSelectRange` (`:4227`) is where the trailing object gets the
MEMBER's name: `:4251` / `:4276` set `VpiName(name)` **and** `VpiDefName(name)`
whenever the name is neither empty nor `"CREATE_UNNAMED_PARENT"`, `:4256` /
`:4281` stamp `VpiConstantSelect` unconditionally, and `:4292`
`populateCoreMembers(Constant_range, Constant_range, result)` spans it over the
range text alone — golden's `76967:31-37` for `8*i+:8`.

The caller is `compileExpression`'s hier_path element loop
(`:5535-5547`): when the member is followed by a `paBit_select` **with a
child**, it hands the whole chain to `compileSelectExpression` with `tmpName` =
the member name and `path` as `pexpr`, then re-spans the result
`populateCoreMembers(name, dotedName, select)` — from the MEMBER NAME token to
the end of the select chain. That is golden's `var_select` at `76967:20-38`
under a `hier_path` at `76967:17-38`.

**Nothing on that road reads a symbol table.** `name`, `dotedName`,
`Bit_select` are grammar nodes. Which is why the golden grids below show every
base kind shaped identically.

**THE HEAD.** `uvm_pkg.sv:76967`, `uvm_reg_map::do_bus_access`:

```
p.push_back(rw.value[idx][8*i+:8]);          // 76967, an ARGUMENT (rvalue)
rw.value[idx][i0*8+:8] = p[idx*bytes_per_value+i0];   // 77065, an LVALUE
```

`rw` is `uvm_reg_item rw` — the task's **first formal argument**, so
`symbol.kind` is `FormalArgument` and the gate refused. Golden at 76967:

```
var_select (…::value) 76967:20-38
  vpiIndex ref_obj idx 76967:26-29        -> vpiActual array_var …::idx
  vpiIndex indexed_part_select value 76967:31-37
           vpiDefName value, vpiConstantSelect 1, vpiIndexedPartSelectType 1
           Base = operation(8*i), Width = constant 8
```

ours was one flat `indexed_part_select` named `value[idx]` at `76967:20-37`.

---

## 3. THE GRIDS

Every arm is built with Surelog in **both views** (`-parse` and
`-parse -elabuhdm`, each with its own golden) and with both frozen binaries;
every child rc is printed (`arm147.sh`). Scoring is `ct147cen --sel` +
`join147.py`: ONE ROW PER `hier_path` that carries a select ELEMENT, keyed on
`(span | hier_path VpiName)` — `VpiName` **is** read by `hier_path::Compare`,
a TEXT law — with the ELEMENT SHAPE SIGNATURE (per element: UHDM kind, VpiName,
the kind of every index STEP, MID/TRAIL) as the payload. **`VpiFullName` is
never in the key or the payload**; the judge does not read it.

| arm | grid | wrong cells DEF | wrong cells ELAB |
|---|---|---|---|
| A `g147_a.sv` | the CORPUS SHAPE and its neighbours: formal-argument receiver × step count × trailing kind (`+:` / `-:` / constant range / bit-select / none) × index shape, plus the LOCAL-VARIABLE / CLASS-PROPERTY / MODULE-VARIABLE twins and the LVALUE row | 21 → **0** | 44 → **0** |
| B `g147_b.sv` | the RECEIVER-SYMBOL-KIND axis: input / `ref` / `const ref` formal, local variable, instance and STATIC class property, explicit `this.`, struct-typed property, parameter base, static method, task, package free function, module variable, module handle, continuous assign, `foreach` body | 13 → **0** | 28 → **0** |
| C `g147_c.sv` | the kinds arm B could not reach: a struct LOCALPARAM base with a real element step, TWO and THREE member accesses, a MODPORT port, an interface INSTANCE | 13 → **2**\* | 36 → **4**\* |
| D `g147_d.sv` | the SYSTEMATIC cross: step count 0/1/2/3 × trailing kind × index shape (bound local, formal, literal, expression, package localparam, NESTED SELECT) × base shape (bare ref, literal, package localparam, parameter width), each with its LOCAL-VARIABLE control | 14 → **0** (2 key-only rows, R2) | 28 → **0** (4, R2) |
| E `g147_e.sv` | RECEIVER SHAPE (dynamic array / queue / fixed unpacked / packed 2-dim / associative / struct member) × HOME (in-body method, task, out-of-body, package free function, module initial / always_comb / final) × 1–3 instances, plus the § `builtinRecvMultiDimStepIsBitSelectChain14` and § `hpTrailSelIdxDecompiled89` CONTROLS | 13 → **0** | 29 → **0** (5 pre-existing, unchanged) |

**Over all five arms × both views: 239 DIFFER cells → 6**, and the
`away147.py` transition audit reads **TO-GOLDEN 242 / AWAY-GOLDEN 0 /
STILL-WRONG 29 / UNMOVED-OK 133** (`AWAY.r10uvm147.txt`). **Not one cell went
from agreeing with golden to disagreeing, in either view, in any arm.**

\* Arm C's residue is the **declared** one: `p.arr[idx][8*i+:8]` (a MODPORT
port) and `bus.arr[idx][8*i+:8]` (an interface INSTANCE). Their base is an
`ArbitrarySymbol` / `HierarchicalValue`, not a `NamedValue`, so they never
reach this arm at all; golden shapes them as var_selects too. That road is the
dotted-interface builder with its own elaborated-`High_conn` laws
(§ `connIpsPkgParamBoundNoTs65`, § `connMpRootIpsBoundKeepsTs65v`,
§ `connHpIpsBaseNonOvParamFold84`, § `hpConnElemIdxFold17`) and their arms;
**widening into it is R1, not this pass.**

**Measured negatives, kept as negatives.**
* A `this.`-prefixed path (`this.h_prop.value[idx][8*i+:8]`, arm B `b07`) has
  NO golden row at all — § `thisPathSelectErased4` erases the select. Untouched.
* A member with NO index step and only a range (`fa.pk[8*i+:8]`, `PB.a[8*i+:8]`,
  arm A `a08`, arm B `b09`/`b17`) is a flat `indexed_part_select` in golden too,
  under both a variable and a PARAMETER base. Agrees before and after.
* A NESTED-SELECT index (`fa.d1[fa.ix[i]][8*i+:8]`, arm D `d20`/`d30`) gets the
  right SHAPE now, but golden's hier_path NAME drops the whole bracket group
  (§ `hpTrailSelIdxDecompiled89`'s convention B — `decompileHelper` has no
  `hier_path` row). **That name residue is PRE-EXISTING and identical on the
  LOCAL-VARIABLE twin `d30`, which this pass does not touch**; it is R2.
* The § 14 builtin-method receiver cells (arm E `e08`–`e11`) and the § 89
  trailing-select cells (`e12`–`e14`) are byte-for-byte what they were.

---

## 4. PREDICTION AND MOVERS

`pred147.cpp` names, from the **PRISTINE** databases and **before** the patched
sweep, every database holding a `hier_path` PATH ELEMENT that is a
`part_select` / `indexed_part_select` whose own `VpiName` CONTAINS `'['` — the
flat `member[idx]` shape. It is deliberately an OVER-approximation (it also
names the R1 cells the law leaves alone). Over **956** surelog and **1358**
uhdm2rtlil pristine databases it returns

```
CAND default/BuildUVMPkg-bf853d43 count=4
CAND testflags/BuildUVMPkg-bf853d43 count=4
-- surelog databases=956 candidates=2
-- uhdm2rtlil databases=1358 candidates=0
```

and names the four objects: `76967:20 value[idx]` and `77065:10 value[idx]`,
twice each (DEF + ELAB). (`PREDICT.r10uvm147.txt`.)

`byteverify.sh SELFCHECK=1` then measured **MOVERS 3 / 956** and **0 / 1358**,
`PATH_SETS_IDENTICAL` on both:

* `default/BuildUVMPkg-bf853d43` and `testflags/BuildUVMPkg-bf853d43` — the
  predicted set, by name, and the two patched databases are byte-identical to
  each other;
* `default/Scoreboard-59431470` — the known ~50/50 `vpiTaskFunc`-order **COIN**.
  Attributed ORDER-BLIND: the path-normalised **sorted** whole-dump diff is
  **0 lines** over 1,099,154 dump lines, i.e. the two databases are the same
  multiset of lines. Not this pass.

The BuildUVMPkg attribution is the sorted whole-dump diff, **66 removed / 112
added**, and every changed object carries line **76967** or **77065** of
`uvm_pkg.sv` (with the loop variables at 76965/76966/77063/77064)
(`MOVERS.r10uvm147.txt`). The SUBTREE test is stronger and is the one that
matters: extracted from the corpus dumps and compared to GOLDEN's own subtree
with `vpiFullName` stripped (the judge does not read it), **site 76967 is
IDENTICAL to golden** and site 77065 differs in ONE dump-only line (R2 below).

---

## 5. THE WIDE BOUNDARY GATE

`bound147.sh`, run from a COPY of the whole probe tree, subdirectories
included, the file list read on fd 3, children `</dev/null`, `PROCESSED`
asserted against `LISTED`, scratch keyed on the RELATIVE path, both views, both
frozen binaries.

```
LISTED=4184 PROCESSED=4184 PRODUCED_DBS=4039 MOVED_ARMS=5 RC_DIFFS=0
```

**The five movers are this pass's own five grids and nothing else** — the
positive control that proves the gate can see, and a clean sweep everywhere
else. No `r10uvm77-79`, `r10uvm82-91`, `r10uvm84/85`, `r10uvm89`, `r10buvm3-15`,
`r10sd8-12`, `r10uvm92`, `r10uvm113`, `r10uvm143` or `r10uvm144` arm moved, and
`RC_DIFFS=0` (the segfaults the driver prints are PRE-EXISTING and occur
identically under both binaries — that is exactly what `RC_DIFFS=0` asserts).
(`BOUNDARY.r10uvm147.txt`.)

---

## 6. GATES (`GATES.r10uvm147.txt`) — all green

Both binaries frozen at immutable paths (`chmod 555`) before any sweep; every
`cmds.txt` audited by BINARY PATH — of 1573 surelog rows, the **1523** that ran
slang all name the patched binary and the other 50 name no binary at all
(SURELOG_FAIL / golden-cache-only rows); of 1462 uhdm2rtlil rows, **1458** name
the patched binary and the other 4 are the two SURELOG_FAIL rows × two modes.
**0 name any other binary**, and the
pristine control workdirs likewise name only the pristine binary. `GOLDEN_DEFER`
left **UNSET**. `git stash` never used. `results/*.csv` only READ. slang not
patched. The four slang-fenced tests were never dispatched (`canaudit`:
`audited=29 UNCOVERED=0 FENCE-BREACH=0`).

* goldens **23/0** with `SLANG_UHDM` exported explicitly to each binary;
  `/bin/false` **0/23**.
* uhdm2rtlil **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in BOTH
  modes; `ct8rows` PASS against the committed baseline AND against my own
  pristine control, status and dump column.
* surelog corpus `ct8rows` PASS — **0 differing rows over 1588** against the
  committed baseline and against my own pristine control (which was itself
  checked byte-identical to the committed baseline first, so it is not a stale
  control). **NO ROW CONVERTED.**
* `byteverify SELFCHECK=1`: **MOVERS 3 / 956** (two predicted by name + the
  Scoreboard coin, attributed order-blind) and **0 / 1358**,
  `PATH_SETS_IDENTICAL` on both.
* canaries `ok=52` / `ok=8`, `changed=0`; `ctcan2` PASS both; SVSwitch
  `4842211c4030` and YosysVerx `6ccda350c24a` held; InterfaceModPort,
  BlackParrotComplex and YosysOldOr byte-identical in both modes.
* Heads: SeqDriver 62/62, SimpleUVM 62/62, Scoreboard/default 62, MiniAmiq
  62/62, Earlgrey_0_1 64/64, Rggen 0 — **all unchanged, and their cmp logs
  byte-identical between the two binaries**; **BuildUVMPkg 174 → 68, both
  modes**, one head per run throughout, the two heads byte-identical to each
  other.

---

## 7. RESIDUES AND R0

**R0 (the new BuildUVMPkg head, both modes, 68 cmp lines, one object).** A
`Path_elems` MEMBER-KIND mismatch at `uvm_pkg.sv:29217` in
`uvm_report_catcher::print_catcher`:

```
if (uvm_report_enabled(UVM_LOW, UVM_INFO, "UVM/REPORT/CATCHER"))
```

Golden's element at that slot is a **`func_call` named `uvm_root::get`**
(29217:10-18) bound to `function uvm_pkg::uvm_root::get` — i.e. Surelog
resolved the `uvm_report_enabled` macro expansion's `uvm_root::get()` into the
path — while ours is a **`method_func_call` named `uvm_report_enabled`**
(29217:26-44) carrying the three arguments. A DIFFERENT element of the same
`hier_path`, one slot earlier. (`head_pat_BuildUVMPkg.default.cmp`.)

**R1 — the OTHER road this pass deliberately did not widen.** A
`<base>.<member>[i]…[range]` whose base is an `ArbitrarySymbol` or a
`HierarchicalValue` (an interface INSTANCE, a MODPORT port, a cross-module
path) still takes the dotted-interface builder and still flattens to one
`(indexed_)part_select` named `member[idx]`; golden gives it the SAME
`var_select` this law mints (arm C `c06`/`c07`, 2 cells DEF / 4 ELAB). That
builder carries § `connIpsPkgParamBoundNoTs65`,
§ `connMpRootIpsBoundKeepsTs65v`, § `connHpIpsBaseNonOvParamFold84` and
§ `hpConnElemIdxFold17` on its elaborated `High_conn` path, so moving that
population needs its own census and its own arms. **Corpus reach measured: the
predictor finds ZERO such cells in either corpus today.**

**R2 — two dump-only residues this pass exposed but does not own.**
1. The LVALUE branch sets `suppressConstParent = true` for the WHOLE trailing
   range, so a constant nested inside an ARITHMETIC base (`i0*8`'s `8` at
   `77065:24`) is minted unparented where golden parents it at the operation.
   The general rule elsewhere in this same function is
   `suppressConstParent = isLiteralExpr(bound)` — "a range endpoint that IS a
   literal stays unparented; a constant nested in an endpoint OPERATION keeps
   its operation parent". **`vpiParent` is read by NO generated `Compare`**, so
   the judge cannot see it; changing the blanket would move the other arms that
   measured it, for zero judge benefit. Recorded, not fixed.
2. The NESTED-SELECT index name (`fa.d1[fa.ix[i]][8*i+:8]` vs golden
   `fa.d1[8*i+:8]`) — § `hpTrailSelIdxDecompiled89`'s convention B is not
   applied by THIS builder's name renderer. PRE-EXISTING and identical on the
   LOCAL-VARIABLE twin the pass never touches; corpus reach zero.

---

## 8. FILES

| file | what it is |
|---|---|
| `arm147.sh` | build one arm: Surelog golden in BOTH views + both frozen binaries + official `uhdm-cmp`; every rc printed |
| `bound147.sh` | the wide boundary gate, run from a COPY of the probe tree |
| `ct147cen.cpp` | the hier_path SELECT-ELEMENT SHAPE census out of `Serializer::AllObjects` |
| `join147.py` | the multiset join of two censuses: SHARED-EQUAL / DIFFER / GOLDEN-ONLY / OURS-ONLY |
| `away147.py` | the transition audit: TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / UNMOVED-OK |
| `score147.sh` | golden / pristine / patched scoring of one arm dir, both views |
| `corpcen147.sh` | the same census over the NAMED corpus rows of a `verify_golden` workdir |
| `pred147.cpp` / `pred147.sh` | the a-priori mover predictor over pristine databases |
| `g147_a.sv` … `g147_e.sv` | the five grids |
| `head_pris_*.cmp` / `head_pat_*.cmp` | official `uhdm-cmp` heads for all seven named rows, before and after |
| `PREDICT` / `MOVERS` / `BOUNDARY` / `CENSUS` / `ARMS` / `AWAY` / `GATES` `.r10uvm147.txt` | the measurements above |
| `byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh` | the gate scripts, carried so this directory runs standalone |
