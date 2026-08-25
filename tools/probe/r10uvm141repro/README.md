# r10uvm141 — § qualLifetimeStubListsNoBodyLocals141

**BuildUVMPkg×2, 83 → 55 cmp lines, one head each. Base commit `c695e97`.**

The head was the LAST vector still hanging off pass 46's qualifier+lifetime
class-method stub: the body locals of
`uvm_pkg.sv:75228  local function automatic int unsigned ceil(int unsigned a, int unsigned b)`
in class `uvm_reg_map`. Golden's stub lists none. We listed both.

---

## 1. The head, read from the object and not from a framing

The brief inherited the framing "our function `uvm_pkg::uvm_reg_map::ceil` at a
slot where golden has none", i.e. a METHOD-LISTING count/owner bug. **That is
refuted.** Golden has an object at exactly that slot, under exactly that owner,
with exactly our field values; the *listing* is already right and has been since
pass 46.

The pristine head (`head_pris_BuildUVMPkg_default.cmp`, byte-identical to the
one pass 138 committed) prints

```
LHS: <null>
RHS:
decompile:
function: (uvm_pkg::uvm_reg_map), id:74836, line:75228:1, endln:75228:6
 ...
|vpiVariables:  \_int_var: (uvm_pkg::uvm_reg_map::ceil::r)   ...
|vpiVariables:  \_int_var: (uvm_pkg::uvm_reg_map::ceil::r0)  ...
|vpiMethod:1  |vpiVisibility:3  |vpiReturn: \_logic_var: (uvm_pkg::uvm_reg_map)
```

`LHS: <null>` with a full RHS is `BaseClass::SafeCompare`'s **vector** overload
in its `lhs == nullptr && rhs != nullptr && !rhs->empty()` branch
(`~/.local/include/uhdm/BaseClass.h:220`): it sets `m_failedRhs` to the
**owner** and never touches `m_failedLhs`. So the printed `function` is the
CONTAINER, not the value, and golden's corresponding vector is **null**.

Which vector: `task_func` derives from `scope`, and `scope::Compare` reaches
`Variables()` at `~/git-repos/UHDM/build/generated/src/scope.cpp:340` — before
`task_func::Compare`'s own `Return`/`Io_decls`/`Stmt`
(`generated/src/task_func.cpp:180/182/183`) and after only vectors that are null
on both sides. `vpiVariables` is the first field that can differ, and it is the
one that does. The whole 83-line head is those two `int_var`s and their
typespec chain.

The census closes it with no inference at all. `cen141.py` over the **nine
measurable UVM databases** (SeqDriver×2, SimpleUVM×2, Scoreboard/default,
MiniAmiq×2, BuildUVMPkg×2 — Scoreboard/testflags has no golden cache entry)
lists **69,289 class-method rows on each side**, keyed by owner × kind × name ×
field list × listed-variable names, joined as a MULTISET, and finds exactly
**two** wrong — the same cell in the two BuildUVMPkg modes:

```
ONLY-GOLDEN x1 OWNER=uvm_pkg::uvm_reg_map|KIND=function|NAME=|FIELDS=vpiParent,vpiFullName,vpiMethod,vpiVisibility,vpiReturn|VARS=
ONLY-OURS   x1 OWNER=uvm_pkg::uvm_reg_map|KIND=function|NAME=|FIELDS=vpiParent,vpiFullName,vpiVariables*2,vpiMethod,vpiVisibility,vpiReturn|VARS=...ceil::r,...ceil::r0
```

SeqDriver 8358/8358, SimpleUVM 4751/4751, Scoreboard 4799/4799, MiniAmiq
14892/14892 are **0 ONLY-GOLDEN / 0 ONLY-OURS** already. The listing — which
methods appear, under which owner, how many copies per definition style, in
either view — was never wrong. **One field of one object was.** After the pass
BuildUVMPkg reads 4244/4244 with **0/0** in both modes, so the entire
class-method listing population of every measurable UVM database is now
identical to golden: TO-GOLDEN 2, AWAY-GOLDEN 0, STILL-WRONG 0
(`CENSUS.r10uvm141.txt`).

---

## 2. The decoded model (Surelog, mechanical)

`CompileClass::compile_class_method_`
(`src/DesignCompile/CompileClass.cpp:395`) hands `compileFunction` the
**unadvanced** `fC->Child(id)` — the `Class_method`'s first child, which with a
written qualifier is the QUALIFIER node, not the declaration
(`CompileClass.cpp:489` and `:491`; it calls twice, which is why the object is
minted as a placeholder on the first call and filled on the second).

`CompileHelper::setFuncTaskQualifiers` (`src/DesignCompile/CompileStmt.cpp:1839`)
unwraps a `Function_declaration` into its child **only** in its first two `if`s
(`:1844`, `:1848`), which fire only when the node handed in IS that
declaration. With a qualifier in front, those do not fire; the `while` loop
consumes the qualifier (`paMethodQualifier_ClassItem`, `:1933`, stamping
`vpiLocalVis`/`vpiProtectedVis`), advances to the sibling `Function_declaration`,
and **returns it still wrapped**.

Back in `compileFunction` (`CompileStmt.cpp:2310`), `func_decl` is that
`Function_declaration`, so

```
Function_body_declaration = fC->Child(func_decl);       // CompileStmt.cpp:2337
```

is `Child(Function_declaration)` — which, when the declaration writes
`automatic` or `static`, is the **LIFETIME node**, not the
`Function_body_declaration`. Everything derived from there is invalid: the
`Function_data_type_or_implicit`, the `Function_name` (hence the EMPTY
`VpiName`), the `Tf_port_list` (hence no io_decls), the return type (hence the
bare `logic_var` with no typespec), the body statement — **and the body's
declarations, which is this pass's cell.** `compileFunction`'s own guard
`if (func->Io_decls() || func->Variables() || func->Stmt()) return true;`
(`CompileStmt.cpp:2368`) names the three vectors that come out of the body node
together; all three are absent on golden's stub for the same single reason.

`vpiVisibility` survives because its `if` already fired inside the qualifier
loop. `vpiAutomatic` does not, because the loop's `paLifetime_Automatic` branch
(`:1907`) is reached only when the lifetime is a SIBLING at the qualifier level
— which is exactly the case that does NOT produce a stub. Both halves of that
are visible in arm A: the stub `ca1` carries visibility and no automatic; the
qualifier-less control `cb1` (`function automatic int g1`) is fully named AND
carries `vpiAutomatic`.

**The law.** A class method written with a QUALIFIER *and* a written LIFETIME
lists **no `vpiVariables`**. Its stub prints `vpiParent`, `vpiFullName` (the
CLASS's, not the method's), `vpiMethod:1`, `vpiVisibility`, `vpiVirtual` when
`virtual` was written, and — for a FUNCTION — `vpiReturn` (a bare `logic_var`),
and nothing else.

---

## 3. The production change

One line, one term, in the site `§ ctorBodyLocalsNotOnFunc71` already owns:

```c++
// src/TaskFuncEmit.cpp (~5936, inside emitTaskFuncs' per-member loop)
-  if (!fvars->empty() && !ctorNoVars71)
+  if (!fvars->empty() && !ctorNoVars71 && !qualLifetime46)
       tf->Variables(fvars);
```

`qualLifetime46` is pass 46's own predicate (`TaskFuncEmit.cpp:2993`), already
the gate for the name (`:3104`), the io_decls (`:4938`) and the body
(`:6125`, `:6240`). No new predicate is introduced, and the variables are still
BUILT (they stay in `fvarsAll71`, which the `$bits(<formal>)` binder reads);
they are simply not listed — the same idiom pass 46 used for the io_decls.

---

## 4. The grids (`ARMS.r10uvm141.txt`, arm sources `g141_*.sv`)

Every arm is built with Surelog in **both views** (`-parse` and
`-parse -elabuhdm`, each with its own golden) and with both frozen binaries,
scored by `cen141.py`'s **multiset** join (a set join would hide the collapse)
and judged by the official `uhdm-cmp`. Every child rc is printed.

| arm | grid | wrong cells DEF | wrong cells ELAB |
|---|---|---|---|
| A `g141_a_vars.sv` | qualifier × written lifetime × body-local shape (initialised / bare / inside a named begin block / absent), function vs TASK, `local`/`protected`/`virtual`/class-item `static`; 3 controls writing only ONE feature | 8 → **1** | 8 → **1** |
| B `g141_b_styles.sv` | owners: package class, MODULE-owned class, NESTED class, COMPILATION-UNIT class; styles: in-body, extern prototype + out-of-body definition, three-in-one-class; referenced vs unreferenced | 7/9 → **1/3** | 9/11 → **1/3** |
| C `g141_c_names.sv` | name collisions (a package free function `ceil`, built-in method spellings `size`/`num`, a system-function spelling `clog2`), 1 vs 3 instances, 3 specializations of a parameterized class | 6/7 → **0/1** | 6/7 → **0/1** |

Nothing moved away in any cell, in either view.

**Measured negatives, kept as negatives.**
* `local`/`protected`/`virtual`/class-item `static` all behave alike; the
  distinguisher is the WRITTEN LIFETIME, not which qualifier.
* Reachability is not a distinguisher: `cm1.q1` (called) and `cm2.q2` (never
  called) produce the same object.
* Instance count and specialization count are not distinguishers: one
  `class_defn` stub per class, whatever the count, in both views.
* Name collisions change nothing (the stub has no name to collide with).
* Surelog's grammar REJECTS a lifetime on an extern prototype
  (`extern local function automatic` → PA0207), so that cell is unreachable;
  the reachable out-of-body cell (qualifier on the prototype, lifetime on the
  DEFINITION, `cb_ext2::e2`) is FULLY NAMED with its body local on BOTH sides —
  which vindicates pass 46's exclusion of out-of-body definitions instead of
  assuming it.
* slang rejects a written `static` LIFETIME on a class method
  ("class methods cannot have static lifetime"), so arm A reaches that cell
  only through `protected function automatic`.

---

## 5. Prediction, movers, boundary

`pred141.cpp` names, **from the pristine databases and before the patched
sweep**, every database holding an unnamed class-parented `task_func` with a
non-empty `Variables` vector — a deliberate over-approximation of the law's
reach. Over **956** surelog databases and **1358** uhdm2rtlil databases it
returns exactly two:

```
CAND  default/BuildUVMPkg-bf853d43    uvm_pkg::uvm_reg_map  function  nvars=2
CAND  testflags/BuildUVMPkg-bf853d43  uvm_pkg::uvm_reg_map  function  nvars=2
```

`byteverify.sh SELFCHECK=1` then measured **MOVERS 2 / 956** and **0 / 1358** —
the predicted set, by name, and nothing else. The order-blind whole-dump diff
attributes all of it: **32 removed lines, 0 added**, every one naming
`uvm_pkg::uvm_reg_map::ceil::r` / `::r0` or their `ref_typespec` /
`int_typespec` / `vpiVariables` container lines (`MOVERS.r10uvm141.txt`).
Scoreboard/default — the ~50/50 `vpiTaskFunc`-order coin — did not move this
run, so no coin attribution was needed.

The wide boundary (`bound141.sh`, from a COPY of the probe tree, subdirectories
included, file list on fd 3, `PROCESSED` asserted against `LISTED`, scratch
keyed on the RELATIVE path) compiled **LISTED=4079 PROCESSED=4079
PRODUCED_DBS=3935** arms in both views with both binaries:
**MOVED_ARMS=5, RC_DIFFS=0**. Three are this pass's own arms — the positive
control that proves the gate can see. The other two are
`r10uvm46repro/t64a/dut.sv` and `r10uvm47repro/t64a/dut.sv` (the same source),
**pass 46's own arms for the law this pass extends**. Re-measured against
golden they move TOWARD it: cmp 3930→3874 (DEF) and 4546→4490 (ELAB) with the
head OBJECT unchanged, ONLY-GOLDEN 1→1 and ONLY-OURS 6→6 in count, with the two
surplus stubs that used to carry `vpiVariables` now printing golden's exact
field list (`BOUNDARY.r10uvm141.txt`). No `r10uvm77-79`, `r10uvm82-91`,
`r10uvm84/85`, `r10uvm89`, `r10buvm3-15` or `r10sd8-12` arm moved at all.

---

## 6. Gates (`GATES.r10uvm141.txt`) — all green

Both binaries frozen at immutable paths before any sweep; every `cmds.txt`
audited by BINARY PATH (1523/1523 surelog, 729/729 uhdm2rtlil name the patched
binary). Goldens 23/0 with `SLANG_UHDM` exported explicitly, `/bin/false` 0/23.
uhdm2rtlil 679/50/2 in both modes, `ct8rows` PASS against the committed
baseline and against this pass's own pristine control. Surelog corpus
`ct8rows` PASS — **0 differing rows over 1588**, status AND dump column. **No
row converted; `results/*.csv` untouched.** Canaries `ok=52` / `ok=8`,
`changed=0`; `ctcan2` PASS both; `canaudit` `audited=29 UNCOVERED=0
FENCE-BREACH=0`; SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` held,
InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical. The pristine
control was itself checked byte-identical to the committed baseline first, so
it is not a stale control.

Heads: SeqDriver 26, SimpleUVM 334, Scoreboard/default 334, MiniAmiq 26,
Earlgrey_0_1 15, Rggen 0 — all unchanged; **BuildUVMPkg 83 → 55, both modes**,
one head per run throughout.

---

## 7. Residues and R0

**R0 (the new BuildUVMPkg head, both modes, 55 lines, one object)** —
`LHS: array_var uvm_pkg::uvm_reg_map::unregister::q` with `RHS: <null>`: the
SINGULAR `SafeCompare` overload naming the VALUE golden has and we do not.
`uvm_pkg.sv:75268  uvm_reg_block q[$];` inside
`virtual function void unregister()`. Golden lists an `array_var` named `q`
with `vpiArrayType:4` (queue), an `array_typespec` at 75268:17-20, and a
`class_var` in `vpiReg` carrying a `class_typespec` spanning the element type
(75268:3-16), all parented at the function's `begin` block
(`head_pat_BuildUVMPkg_default.cmp`). A QUEUE-OF-CLASS body local is the shape
to decode.

**R1 — the class-method `vpiAutomatic` residue.** Golden stamps `vpiAutomatic`
on a class method whose declaration writes `automatic` and that is NOT a stub
(`setFuncTaskQualifiers`'s `paLifetime_Automatic` branch,
`CompileStmt.cpp:1907`); we suppress it, because `TaskFuncEmit.cpp`'s automatic
arm is gated `&& !classScope`. Three independent witnesses this pass:
arm A `cb1::g1`, arm B `cb_ext2::e2` (an out-of-body definition), and pass 46's
`t64a` `f_auto_2tok`. **Corpus-invisible today** — over BuildUVMPkg's 4244
class-method rows no cell shows it — so it is a boundary-only residue, not a
head; it is also the one thing standing between arm A and 0/0.

**R2 — pass 46's COLLAPSE, still unimplemented and still recorded.** Several
qualifier+lifetime methods in ONE class fuse into ONE golden object; we emit one
stub per declaration. This pass does not change that count (arm B `cb_multi`
3 vs 1, arm C `Sizey` 2 vs 1, `t64a` 5 vs 1) — it only makes every one of them
field-identical to golden's. No corpus source has two such methods in one class,
so nothing in either corpus can see it.

---

## 8. Files

| file | what it is |
|---|---|
| `arm141.sh` | build one arm: Surelog golden in BOTH views + both frozen binaries + official `uhdm-cmp`; every rc printed |
| `bound141.sh` | the wide boundary gate, run from a COPY of the probe tree |
| `cen141.py` | class-method census out of a `uhdm-dump`: OWNER × KIND × NAME × top-level FIELD NAMES × listed variable names. No span, no file, no id |
| `score141.sh` | multiset join of two censuses over an arm dir, both views |
| `corpcen141.sh` | the same census over the NAMED corpus rows of a `verify_golden` workdir |
| `pred141.cpp` / `pred141.sh` | the a-priori mover predictor over pristine databases |
| `g141_a_vars.sv` `g141_b_styles.sv` `g141_c_names.sv` | the three grids |
| `head_pris_*.cmp` / `head_pat_*.cmp` | official `uhdm-cmp` heads for all seven named rows, before and after |
| `PREDICT` / `MOVERS` / `BOUNDARY` / `CENSUS` / `ARMS` / `GATES` `.r10uvm141.txt` | the measurements above |
| `byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh` | the gate scripts, carried so this directory runs standalone |
