# r10uvm88 — § `pkgVarBindsOnlyThroughInstance88` — **THE `s_connection_warning_id` HEAD, CLOSED ON ALL FIVE UVM ROWS**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **no corpus row
passes cmp** (arm `a2` does — see below).

## The headline

r10uvm87 left ONE head standing on the five UVM rows (seven live row-modes) — an
**EXTRA REFERENCE EDGE**:

```
uvm_port_base.svh:245:35   m_comp.set_report_id_action(s_connection_warning_id, UVM_NO_ACTION);
LHS golden  <null>
RHS ours    string_var (uvm_pkg::s_connection_warning_id) @24:14-24:60
            < package uvm_pkg < design work@top_tb        SHAPE=EXTRA-OURS
```

That head is gone, and the whole family with it: the span-blind census of every
`ref_obj → package-scope variable` edge goes from **22 EXTRA-OURS keys (30
objects) → 0** on SeqDriver / SimpleUVM / Scoreboard / MiniAmiq and **21 → 0**
on BuildUVMPkg, with `agree` and `MISSING-OURS` **unchanged on every row**.

| row-mode | cmp lines | head |
|---|---|---|
| SeqDriver ×2 / SimpleUVM ×2 / MiniAmiq ×2 / Scoreboard-default | 47 → **96** | `string_var(s_connection_warning_id)` EXTRA-OURS → `hier_path(provider.m_provided_to[])` **VpiName** |
| BuildUVMPkg ×2 | 79 → **79** | unchanged (its own older head) — but **29 objects moved**, said out loud |
| Earlgrey_0_1, Rggen | 46/33/17 | untouched |

**The line count going UP is not a regression — it is the next rung printing.**
The PRISTINE ladder proves it *from the pristine database alone*: rungs **1, 2, 3**
are this law's three target variables, and once they are masked the ladder
reaches `hier_path(provider.m_provided_to[])` — the patched head, verbatim,
present before any patch (`LADDERS.r10uvm88.txt`). Over 60 rungs the family goes
**17 rungs → 0**, and golden-objects-proven-equal goes **13740 → 22269**.

## The law

> A `ref_obj` carries an `Actual_group` pointing at a **PACKAGE-SCOPE VARIABLE**
> only when the **ENCLOSING SUBROUTINE CARRIES THAT PACKAGE AS ITS
> `vpiInstance`**.
>
> A class method **written inside the class body** has **NO `vpiInstance` at
> all**, so golden leaves every such reference **BARE** — whatever it is, and
> wherever it sits.

### The decode, from Surelog

Surelog binds a late-bound reference to a package's `Variables()` listing in
exactly **one** place — `UhdmWriter::lateBinding` — and it gets there only
through

```
func->Io_decls() -> func->Variables() -> func->Parameters()
    -> func->Instance()'s Variables()   ** guarded by inst->UhdmType() == uhdmpackage **
```

which is the *same* walk `§ pkgSubRefBindsPkgVarOverFormal81` already decodes for
its own contest. An **out-of-body** definition is compiled in the home package's
scope and comes out carrying that package as `vpiInstance`; an **in-body** method
does not, so the listing is unreachable from it. Our emitter's counterpart of
`func->Instance()` is `pkgScopeInst`, and it is `nullptr` for exactly
`classScope && !oob` — which is the gate this pass installs, read off the same
two locals, so the gate and the instance it models cannot drift apart.

### The axis is the DEFINITION SITE, measured three ways

* **`SITEINST` is a perfect discriminator on the corpus.** SeqDriver: golden
  binds 36 such edges, **32 with `SITEINST=package`, 4 with no enclosing
  subroutine (a package initialiser), and ZERO with `SITEINST=<null>`**. Ours
  bound 58 — the same 28, plus **30 with `SITEINST=<null>`**, every one an
  in-body class method.
* **`uvm_root` is on BOTH sides of the split**, at different methods: golden
  binds in `uvm_root::new` @339 and `print_topology` @572 (both *after*
  `endclass` @301) and binds **nothing** in `phase_started` @252 (inside the
  body). The axis cannot be the class, the package, or the variable.
* **`const` is REFUTED as the axis** (the brief's first hypothesis). Arm `a1`
  reads `const string`, `const int`, plain `string` and plain `int` at the same
  positions: all four bind from an out-of-body method and **none** binds from an
  in-body one. So is the brief's second hypothesis: golden does **not** fold the
  package `const string` into a STRING constant and does **not** emit a
  different kind of object — its argument at 245:35 is the *same* `ref_obj` with
  the *same* `vpiName` and the *same* `vpiFullName`, minus the `vpiActual`.

### And the precedent it does NOT break

The code this pass gates carries the comment *“a PACKAGE-level variable of the
package being emitted is visible to every body inside it (`svunit_pkg::svunit_version`
read from `svunit_testrunner::report`)”*. **“Every body” was too many, and
`svunit_testrunner::report` survives**: svunit declares `extern function void
report();` at `svunit_testrunner.sv:41` and defines it at `:75`, *after*
`endclass` @43 — out-of-body, `vpiInstance` = `svunit_pkg`, still bound, on both
sides, before and after.

## The arms — every cell read off ONE golden, both directions

| arm | what it settles |
|---|---|
| `g88_a1_scope.sv` | **WHICH SCOPE**: in-body method (**the only mover**), out-of-body function *and task*, package function, package-variable initialiser, another package's class + function, `$unit` variable + `$unit` class, a module `initial` and a module task (bare *and* `p88::`-qualified), a module-scope class — crossed with `const string` / `const int` / plain `string` / plain `int`, with a class-scope `static` as the "is it package scope or static storage?" control |
| `g88_a2_bound.sv` | **THE BOUNDARY**: a package `parameter`, `localparam`, enum constant and function, plus a shadowing **FORMAL** and a shadowing **LOCAL**, all read from an in-body method. golden binds 4, pristine 6, patched **4 — EXACT, and the arm goes CMP_FAIL → `PASS_CMP`, 0 heads** |
| `g88_a3_sites.sv` | **WHICH POSITION**: constructor (the head's own kind), a call argument under an `if` (the head verbatim), assignment RHS **and LHS**, `return`, `if`/`while`/`for` conditions, `case` selector and item, nested block, `foreach` body, system-call argument, `static` method, task, `virtual` method, a **parameterized** class, a **derived** class, a class property initialiser. golden binds **0**, pristine 27, patched **0 — the law is position-independent** |

Every patched arm database has **zero** rows with `SITEINST=<null>`.

## Where the code is

| site | file | what changed |
|---|---|---|
| flag | `include/UhdmExporter.h` | `bool inBodyClassMethod88` |
| set | `src/TaskFuncEmit.cpp` (`emitTaskFuncs`) | `inBodyClassMethod88 = classScope && !oob;` beside `inClassBodyEmit`, cleared with it |
| **gate** | `src/ExprEmit.cpp` NamedValue arm | `if (!inBodyClassMethod88 && !ref->Actual_group() && …)` on the `pkgViewVarObjs9` bind — **this is the head** |

Three files, 45 inserted lines, 1 changed line of logic. Nothing is extracted or
refactored (`MEMORY.md`'s "no premature extraction").

## What did NOT move, and is recorded as residue

* **R1** — `MISSING-OURS`, **3 keys per row (4 on BuildUVMPkg), unchanged**:
  golden binds the *package listing's* copy of an **out-of-body** method's
  **LOCAL** (`uvm_component::m_set_cl_verb`'s `cs`/`top`, `uvm_root::new`'s
  `clp`/`rh`) where we bind the local itself. Surelog hoists an out-of-body
  method's locals into the home package's `Variables()` — both sides carry the
  same 33-name set, so the hoist agrees — and `lateBinding`'s package block then
  overwrites the local. That is `§ pkgSubRefBindsPkgVarOverFormal81`'s
  neighbour: § 81 owns the **FORMAL** contest, not the **LOCAL** one.
* **R2** — arm `a1`: 8 golden binds inside the **importing** package `q88` (its
  out-of-body `d88::qoob88` and its own `qf88` reading the wildcard-import CLONE
  `q88::cstr88`) that we do not bind. Identical in pristine; untouched.
* **R3** — Scoreboard SPANS: our `svunit_version` ref sits at 97:5 where
  golden's sits at 107:5, and three `current_tc` refs differ in ENDCOL only.
  Same bind, same name; `ref_obj::Compare` reads neither. A dump axis.
* **R4** — arm `a1`'s own cmp head: golden's `class_defn` carries COPIES of the
  package's variables as its `vpiVariables` (`p88::c88::cstr88`). Symmetric in
  the corpus (`adpcm_pkg::adpcm_driver::s_connection_*` on both sides); the arm
  exposes it because the arm has no such copy. A different family.

## The gates, in one line each

Build md5s `aa09f80f…` / `090279ec…`. Goldens **23/0** patched, **23/0**
pristine, **0/23** with `SLANG_UHDM=/bin/false`. uhdm2rtlil **679/50/2** both
modes both binaries, ct8rows **0 differing rows**, byteverify **0 / 1358**.
surelog **470+11+5+283+25 / 466+9+5+3+1+284+23+1+2**, ct8rows **0 differing
rows** on 1588, **NO ROW CONVERTED**. Bytes: **9 movers / 956**, exactly the nine
`PREDICT` named from pristine bytes, `SELFCHECK` 955/956 and `SELFCHECK1` 10.
Boundary **LISTED=581 PROCESSED=581 MOVED=0**. Canary battery
**9/0/0/27**, **56/0/0/8**, **1/0/0/6**, **58/0/0/1**, `canaudit` **33 audited,
0 UNCOVERED, 0 FENCE-BREACH**. Pins hold: `SVSwitch 4842211c4030`,
`YosysVerx 6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr
byte-identical. Full detail in `GATES.r10uvm88.txt`.

**The prediction was made first.** `pred88.sh` read the 956 pristine surelog
databases and the 1358 pristine uhdm2rtlil databases and named **9 movers and
1358+947 byte-identical files** before the patched binary existed
(`PREDICT.r10uvm88.txt`). The byte gate returned exactly that. Every CMP_EQUAL
row was in the byte-identical set — which is also the law's strongest negative
control: a CMP_EQUAL row carrying one of these cells would refute it outright,
and none does.

## Reproducing

```sh
# arms
PRI=<pristine> PAT=<patched> ./arm88.sh g88_a2_bound.sv
./armcen88.sh /tmp/r10uvm88_arm_g88_a2_bound
# census (golden vs ours)
g++ -O2 -std=c++17 ct88cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10uvm88_ct88cen
/tmp/r10uvm88_ct88cen <db.uhdm> --pkgvar    # every pkg-scope-var bind + SITEINST
/tmp/r10uvm88_ct88cen <db.uhdm> --pkgvars   # the package variables themselves
python3 join88_spanblind.py <golden.pkgvar> <ours.pkgvar> <tag>
# the mover predictor, PRISTINE bytes only
./pred88.sh /tmp/r10uvm88_wd_pris_surelog
# gates
./sweep88.sh <bin> surelog <tag>;  ./ct8rows.sh <baseline.csv> <fresh.csv>
./byteverify.sh <pat wd> <pris wd>;  SELFCHECK=1 …;  SELFCHECK1=1 …
./attr88.sh <pat wd> <pris wd> ./default/SeqDriver-32af76aa/slang.uhdm
PRI=… PAT=… ./bound88.sh
bash canaudit.sh canaries.sh ctcan2.sh
```

## R0 — the new head, for the next pass

```
uvm_port_base.svh:485:5    provider.m_provided_to[get_full_name()] = this;
LHS golden  hier_path (provider.m_provided_to[])                 @485:5-485:44
RHS ours    hier_path (provider.m_provided_to[get_full_name()])  @485:5-485:44
FIELD VpiName   SHAPE TEXT   site: uvm_port_base::connect
```
Our `hier_path` name includes the INDEX EXPRESSION's text where golden leaves the
brackets empty. Shared by all five UVM rows (seven live row-modes). The patched
ladder's rungs 2/3/5/6 are a second, separate family:
`method_func_call(super.new)` **MISSING-OURS** — golden emits an implicit
`super.new` call we do not.
