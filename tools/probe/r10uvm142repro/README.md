# r10uvm142 — § `tfItemLocalClassTsNamedByCompileTypespec142`

**MEASUREMENT-ONLY.**  Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here.  slang was NOT patched;
`results/*.csv` were READ ONLY; `GOLDEN_DEFER` stayed unset; the four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

---

## The head cleared

MiniAmiq **and** SeqDriver, both modes, **26 cmp lines and one `^LHS:`** at base
`eca7329` — re-measured on THIS worktree's own pristine build with
`rowheads.sh` before a line of code was written (`head_pris_*.cmp`):

```systemverilog
function void uvm_component::m_set_cl_verb;                        // uvm_component.svh:3375
  static string values[$];                                         // :3380
  static bit    first = 1;                                         // :3381
  string        args[$];                                           // :3382
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();   // :3383  <- THE HEAD
  uvm_root      top;                                               // :3384
  uvm_coreservice_t cs;                                            // :3385
```

```
LHS (golden)                                      RHS (ours)
class_typespec: (uvm_cmdline_processor)           class_typespec: ,
  line:3383:3, endln:3383:24                        line:3383:3, endln:3383:24
|vpiName:uvm_cmdline_processor                    (absent)
|vpiInstance: -> package uvm_pkg                  (absent)
|vpiClassDefn: -> uvm_pkg::uvm_cmdline_processor  |vpiClassDefn: -> uvm_pkg::uvm_cmdline_processor
```

`typespec::Compare` reads `VpiName` and then `Instance` (UHDM's generated
`typespec.cpp`; `Typedef_alias` is walked BEFORE `Instance`), and
`class_typespec::Compare` adds `VpiClassType` / `VpiAutomatic` / the five
vectors / `Class_defn` — all of which already agreed.  The whole 26-line head
was those two fields on one object, and the SPAN was already ours.

**Heads before → after** (this worktree's own pristine and patched builds,
`rowheads.sh` on the two sweep workdirs; counts are DEPTH, not distance):

| row | before | after |
|---|---|---|
| SeqDriver default / testflags | 26 / 26 | **6254 / 6254** (new, deeper object — R0) |
| MiniAmiq default / testflags | 26 / 26 | **6222 / 6222** (same new object) |
| SimpleUVM default / testflags | 29 / 29 | 29 / 29 (unchanged — its head is reached earlier) |
| Scoreboard default | 29 | 29 |
| BuildUVMPkg default / testflags | 83 / 83 | 83 / 83 |
| Earlgrey_0_1 default / testflags | 15 / 15 | 15 / 15 |
| Rggen default | 0 | 0 |

(`Scoreboard/testflags` is `SLANG_REJECT` and `Rggen/testflags` has no golden —
both print SKIP-NOFILE and are counted, never read as perfection.)

---

## 1. The decoded model (Surelog, read line by line)

A subroutine's declaration section is compiled in one of two productions, and
the two build the local's **typespec** in two different places — only one of
which ever NAMES it.

| production | Surelog site | what builds the local's typespec |
|---|---|---|
| **TF-ITEM** | `CompileHelper::compileTfPortDecl`, the `paBlock_item_declaration` arm, `CompileStmt.cpp:1665-1700` | `ts = compileTypespec(component, fC, Data_type, …)` for the WHOLE declaration, then, per declarator, `var->Typespec()->Actual_typespec(ts)` — **overwriting** whatever `compileVariable` had built |
| **BLOCK-ITEM** | `CompileHelper::compileDataDeclaration`, `CompileStmt.cpp:1127` | the identical `compileTypespec` call is **commented out** at `:1152-1153`; the typespec is whatever `compileVariable` produced and nothing replaces it |

`compileTypespec` on a class name reaches `compileDatastructureTypespec`'s
`ClassDefinition` arm (`CompileType.cpp:902-908`):

```cpp
class_typespec* ref = s.MakeClass_typespec();
ref->Class_defn(classDefn->getUhdmDefinition());
ref->VpiName(typeName);                       // <- THE NAME, the WRITTEN spelling
fC->populateCoreMembers(type, type, ref);     // <- the TYPE NODE's span
```

`compileVariable` (`CompileType.cpp:250-384`) tries
`component->getDataType(typeName)` first — a walk up the parent-scope chain
(`DesignComponent.cpp:108-119`) that HITS for an imported or `$unit` class and
MISSES for a class the enclosing component declares itself — and only on the
miss falls through to `design->getClassDefinition(typeName)`, which mints

```cpp
class_typespec* tps = s.MakeClass_typespec();
tps->Class_defn(cl->getUhdmDefinition());     // NO VpiName at all
```

That surviving asymmetry on the BLOCK face is exactly
§ `localClassTsUnnamed15` / § `classMethodLocalNameFollowsHomeComponent7`, and
this law does not touch it.

### `vpiInstance` — the USE SITE's package, never the class's home

`compileTypespec`'s own tail (`CompileType.cpp:2135-2137`):

```cpp
if (result && component && !result->Instance())
    result->Instance(component->getUhdmInstance());
```

`getUhdmInstance()` is non-null **only for a Package** — the only three writers
of `setUhdmInstance` in the whole of Surelog are `CompilePackage.cpp:84`,
`Builtin.cpp:246` and `ResolveSymbols.cpp:110`, all packages.  So the stamp is
the package that is COMPILING the declaration: the package for its own free
subroutine and for an out-of-body class method written at package scope,
nothing for an in-body class method and nothing anywhere in a module.
Measured both ways in `g142_b_home.sv`: `oo_othimp` / `oo_othscoped` name a
class living in `pb1142` from a subroutine in `pb2142`, and golden reads
`vpiInstance -> package pb2142`.  Same family as
§ `scopedTdUnsupTsHomePkgInstance83` ("the home package for an out-of-body
class method, nothing for an in-body one") and § `pkgVarBindsOnlyThroughInstance88`.

### The law

> **§ tfItemLocalClassTsNamedByCompileTypespec142.**  A class-handle
> **subroutine body local** compiled under the **TF-ITEM** production carries
> the WRITTEN class name on its `class_typespec`, **whatever the class's home
> is** — Surelog builds that object with `compileTypespec`, not with
> `compileVariable`'s fallback.  The BLOCK-ITEM production keeps the opposite
> rule (named only when `component->getDataType` resolves the name, i.e. for an
> imported / `$unit` class) and is untouched.  The object's `vpiInstance` is the
> package that COMPILES the declaration, or nothing when no package does.

**The `vpiInstance` half needed no new code.**  `emitTaskFuncs` already stamps
`tsInst` on a body local's typespec (`TaskFuncEmit.cpp`, the
`if (tsInst && stdBi115.empty() && …)` site), and
`tsInst = (pkgScope && !classScope) ? m : (oob ? oobHomePkg : nullptr)` is
already exactly Surelog's rule; `oobHomePkg` is set only when the class's parent
is a `package`.  The one thing taking the stamp away again was the design-final
`clearAnonClassTsInstance()` ("an ANONYMOUS class_typespec never carries
vpiInstance") — a **named** object keeps it.  So naming the object restores the
instance for free, and the two head fields move together by construction.

---

## 2. The production is directly visible in golden's database

`g142_a_prod.sv` puts one class-handle local in every (subroutine home ×
written header shape), the class always in the SAME package, with and without
an initialiser.  Golden's answer is the PRODUCTION and only the production
(`ct142cen` + `score142.py`, both views identical):

| home | header written | production | golden `vpiName` | golden `vpiInstance` |
|---|---|---|---|---|
| in-body class method | `function void ibtf;` | TF-ITEM | **`Ka142`** | – |
| in-body class method | `function void ibbl();` | BLOCK | – | – |
| in-body class task | `task ibtk;` | BLOCK | – | – |
| in-body class task + body io | `task ibtkio; input int q;` | TF-ITEM | **`Ka142`** | – |
| out-of-body class method | `function void Ha142::oobtf;` | TF-ITEM | **`Ka142`** | **`package pa142`** |
| out-of-body class method | `function void Ha142::oobbl();` | BLOCK | – | – |
| out-of-body class task | `task Ha142::oobtk;` | BLOCK | – | – |
| out-of-body class task + body io | `task Ha142::oobtkio; input int q;` | TF-ITEM | **`Ka142`** | **`package pa142`** |
| package free function | `function void pftf;` | TF-ITEM | **`Ka142`** | **`package pa142`** |
| package free function | `function void pfbl();` | BLOCK | – | – |
| package free task | `task pftk;` | BLOCK | – | – |
| package free task + body io | `task pftkio; input int q;` | TF-ITEM | **`Ka142`** | **`package pa142`** |
| module free function | `function void mtf;` | TF-ITEM | **`Ma142`** | – |
| module free function | `function void mbl();` | BLOCK | – | – |
| module task / module task + body io | | BLOCK / TF-ITEM | – / **`Ma142`** | – / – |
| module class in-body / out-of-body, paren-less | | TF-ITEM | **`Ma142`** | – |
| module class in-body / out-of-body, paren'd | | BLOCK | – | – |
| package variable `Ka142 pkgvar142;` | (not a local) | — | `Ka142` | `package pa142` |

An INITIALISER changes nothing (`*_n` and `*_i` read identically on every row);
a written `static` changes nothing (`g142_c_shape.sv` `c_static`, named, at the
span AFTER the keyword); the class's home changes nothing on the tf-item face.

`g142_b_home.sv` varies the CLASS's home against the use site under both
productions.  Golden, both views:

| the class | in-body TF / BLOCK | out-of-body TF / BLOCK | package free TF / BLOCK | module fn TF / BLOCK |
|---|---|---|---|---|
| declared in THIS package (`Kb2142`) | **named** / – | **named**+`pb2142` / – | **named**+`pb2142` / – | **named** / – |
| another package, wildcard-imported (`Kb1142`) | named / named | named+`pb2142` / named+`pb2142` | named+`pb2142` / named+`pb2142` | named / named |
| another package, scoped (`pb1142::Kb1142`) | named / named | named+`pb2142` / named+`pb2142` | named+`pb2142` / named+`pb2142` | named / named |
| `$unit` (`Ub142`, module only — a package may not reference a `$unit` item) | — | — | — | named / named |
| the same module (`Mb142`) | — | named / – | — | **named** / – |

Two readings this pins down: the NAME is the **written spelling**
(`pb1142::Kb1142`, not the class's simple name), and the INSTANCE is the
**use site's** package even when the class lives in another one.

---

## 3. The change

Three hunks, one new predicate, no new walk.

```
include/UhdmExporter.h   bool tfItemLocalClassTs142 = false;      + the law and its Surelog citations
src/TaskFuncEmit.cpp     tfItemLocalClassTs142 = !blockItems9;    around the body-local makeTypespec call
src/TypeEmit.cpp         if ((!localSameComp0 || tfItemNamed142) && …)   cts->VpiName(ct0.name);
```

`blockItems9` is the production selector `emitTaskFuncs` already computes (a
FUNCTION takes the block shape iff its header carries a port-list paren, a TASK
unless its body declares io — § `blockItems9`), so the gate cannot drift from
the shape the rest of that loop models.

**THREE FENCES**, each a refusal to move a cell this pass did not measure:

* `nested0` — only a SUBROUTINE / statement-block declaration.  A class
  PROPERTY or a package variable is named by the pre-existing rule and is
  untouched (`pkgvar142`, `bpkgvar_same`, `cpkg_one`: RIGHT→RIGHT before and
  after).
* the WRITTEN type must resolve **directly** to a class:
  `arrayElemLeaf(declared->getType()).kind != SymbolKind::TypeAlias`.  A
  TYPEDEF'd handle takes Surelog's `SimpleType` arm
  (`CompileType.cpp:882-896`), which hands back the TYPEDEF's OWN object
  instead of minting one — so its name is that typedef's, not the class's.
  Arm `g142_c_shape.sv` `e_td` / `e_tdspec` / `f_td` / `f_tdspec` and
  `g142_b_home.sv` `pf_othtd` / `pfb_othtd` are ALL unmoved by this pass
  (`P == Q` on every column).  R1.
* `builtinLocalUnnamed0` still wins (§ `builtinClassTsLinksBuiltinFileDefn7`):
  a `std` built-in is not resolvable as a DataType from inside a class body and
  never reaches Surelog's naming arm either.
* **A FOURTH FENCE, added by the adversarial verifier
  (§ `tfItemLocalClassTsNotAConstructor142v`, `../r10v142repro/`): a CLASS
  CONSTRUCTOR is never the TF-ITEM production**, however its header is written.
  Surelog compiles a constructor body through
  `CompileHelper::compileClassConstructorDeclaration` (`CompileStmt.cpp:2165`),
  which never reaches `compileTfPortDecl`'s `paBlock_item_declaration` arm at
  all, so a constructor's class-handle local keeps `compileVariable`'s UNNAMED
  fallback even for a PAREN-LESS `function new;` — which `blockItems9`, reading
  only the port-list paren, calls TF-ITEM.  Without the term, FOUR
  RIGHT->WRONG cells (`Cv1142::new` 14:7, `Bv4142::new` 12:7, `Dv4142::new`
  18:7 in an extended class, `Mc4142::new` 43:7 in a module class); with it,
  zero.  The term is slang's own `MethodFlags::Constructor`, NOT a
  `sub.name == "new"` test: an ESCAPED `function void \new ;` is an ORDINARY
  paren-less method whose locals golden DOES name.  Corpus-invisible (no
  corpus row has a paren-less constructor with a same-component class-handle
  local), which is why this pass's own gates could not see it.

---

## 4. The grids (arms142.sh + ct142cen + score142.py — `ARMS.txt`)

Six arm-views (three files × def/elab), every cell joined as a MULTISET on the
span key, scored on the nine fields the generated `Compare` chain reads:

| arm.view | TSNAME | TSINST |
|---|---|---|
| `g142_a_prod.def` | R→R 38, **W→R 25**, W→W 1 | R→R 48, **W→R 16** |
| `g142_a_prod.elab` | R→R 38, **W→R 25**, W→W 1 | R→R 48, **W→R 16** |
| `g142_b_home.def` | R→R 45, **W→R 6**, OG 6, OO 8 | R→R 47, **W→R 4**, OG 6, OO 8 |
| `g142_b_home.elab` | R→R 52, **W→R 6**, OG 6, OO 8 | R→R 54, **W→R 4**, OG 6, OO 8 |
| `g142_c_shape.def` | R→R 33, **W→R 18**, OG 6, OO 15 | R→R 33, **W→R 18**, OG 6, OO 15 |
| `g142_c_shape.elab` | R→R 33, **W→R 18**, OG 6, OO 15 | R→R 33, **W→R 18**, OG 6, OO 15 |

**MOVED-WRONG (RIGHT→WRONG) = 0 and AWAY = 0 on every column of every
arm-view**, and `TSALIAS` / `TSDEFN` / `TSCT` / `TSAUTO` / `TSPARM` / `TSPA` /
`TSEXT` are RIGHT→RIGHT everywhere (the ONLY-GOLDEN / ONLY-OURS counts on those
columns are the arm's pre-existing one-sided sets and are IDENTICAL before and
after — that is what makes AWAY zero rather than merely unreported).

**The one-sided sets, scored explicitly** (they are the places where "a name
added where golden has none" could hide):

* `g142_b_home` `ib_nested` / `oo_nested` / `oob_nested` (a handle of a class
  NESTED in the enclosing class) — golden emits **no `class_typespec` at all**
  there; it emits `unsupported_typespec: (Nb142)`, and for the out-of-body
  method that placeholder carries `vpiInstance -> package pb2142` (read off
  golden's own dump).  Our object's KIND is a pre-existing residue; this pass
  gives it precisely golden's NAME and golden's INSTANCE, so it moves TOWARD
  golden on both compared fields and adds nothing golden lacks.  Corpus
  incidence of the cell: **zero** (§7 R2).
* `g142_c_shape` `c_two_*` / `c_three_*` — golden compiles ONE typespec per
  declaration STATEMENT and shares it across declarators; we mint one per
  declarator.  Pre-existing surplus, count UNCHANGED (2 golden vs 4 and 6
  ours, before and after); the patch gives every one of ours golden's name and
  instance.  R3.
* `g142_c_shape` `c_spec` / `e_spec` (`Kc142#(int, 3)`) — golden's object sits
  at the NAME TOKEN's span (`26:5-26:10`) and ours at the whole written type
  (`26:5-26:19`), so the span-keyed census cannot pair them; the FIELD VALUES
  are now golden's (`Kc142`, `package pc142`).  Span is dump-only —
  no generated `Compare` reads a location.  R4.
* `g142_a_prod` `89:19` (`static function Ua142 get_inst();` in a `$unit`
  class) — golden NAMES the class-handle RETURN typespec and we do not.  A
  DIFFERENT Surelog site (the class-handle return arm) and a different law;
  this pass leaves it exactly as it was (W→W 1).  R5.

---

## 5. The a-priori prediction (`PREDICTION.txt`, `predsweep142.sh`, `pred142.py`)

Made from the PRISTINE databases alone, before the patched binary existed.
The production is visible in golden's own database: a TF-ITEM local is listed
on the SUBROUTINE (the holding `class_var`'s `vpiParent` is a `function`/`task`,
and it is not the subroutine's `Return()` variable), while a BLOCK-item local is
re-parented under the body `begin` — or, when it carries an initialiser, under
that init `assignment`.  So the predicate is: golden has a NAMED
`class_typespec` at (span, class_defn) held by a variable hanging off a
function/task, and ours has an ANONYMOUS one at the same (span, class_defn).

**2314 rows examined** across both corpora and both modes (721 SKIP-NOFILE,
counted).  **9 rows predicted to move; every other row predicted
byte-identical:**

```
default/BuildUVMPkg  10 cells      testflags/BuildUVMPkg  10 cells
default/MiniAmiq     12 cells      testflags/MiniAmiq     12 cells
default/Scoreboard    6 cells      testflags/Scoreboard   — SLANG_REJECT, no database
default/SeqDriver    12 cells      testflags/SeqDriver    12 cells
default/SimpleUVM     6 cells      testflags/SimpleUVM     6 cells
```

The whole corpus-wide population is **four written declarations**:
`uvm_component.svh:3383/3384/3385` (`clp`, `top`, `cs` in
`function void uvm_component::m_set_cl_verb;`) and, in BuildUVMPkg's 1800.2
`pp_output`, the same three plus two more tf-item
`uvm_cmdline_processor clp = …` locals at `41266` and `41353`.

---

## 6. Gates (all green)

1. **Build** both binaries, `-j 2`, md5s taken separately and both frozen at
   immutable `chmod 555` paths before any sweep; every `cmds.txt` in both
   patched workdirs audited by binary PATH — of 3035, **2981 name the frozen
   patched binary and 0 name any other**; the remaining 54 carry only a golden
   cache line because slang was never invoked for that row (SURELOG_FAIL /
   DEFERRED / NO_DATABASE).  Audited by PATH, not by the string `slang-uhdm`,
   which also matches `slang-uhdm-goldens/`.
2. **Goldens** `23 PASS / 0 FAIL` with `SLANG_UHDM` exported explicitly to the
   patched binary; `SLANG_UHDM=/bin/false` → `23 FAIL` (negative control).
3. **uhdm2rtlil** testflags `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`;
   `ct8rows.sh` **0 differing rows** (status AND dump) against the committed
   `results/gate_uhdm2rtlil.csv` AND against this worktree's own pristine sweep,
   in BOTH modes.
4. **Surelog corpus**, `--mode both`: `ct8rows.sh` **0 differing rows over
   1588** against the committed `results/golden_surelog.csv` and against the
   pristine sweep.  **No row was converted; `results/*.csv` were not edited.**
   Status histograms are identical before and after
   (default 471/283/25/10/5, testflags 466/284/23/9/5/3/2/1/1).
5. **Byte verifier**, `SELFCHECK=1`:
   * uhdm2rtlil `MOVERS 0 / 1358`, SELFCHECK 1357/1358 flagged;
   * surelog `MOVERS 9 / 956`, SELFCHECK 955/956 flagged — **exactly the nine
     predicted databases, by name**, and nothing else.
   Every mover attributed by a path-normalised **ORDER-BLIND** (sorted) whole-dump
   diff — mandatory for `Scoreboard/default`, which is a ~50/50 coin:

   | database | order-blind dump diff lines | lines outside `class_typespec` / `vpiName` / `vpiInstance` / the named package |
   |---|---|---|
   | SeqDriver ×2, MiniAmiq ×2 | 84 | **0** |
   | BuildUVMPkg ×2 | 70 | **0** |
   | SimpleUVM ×2, Scoreboard/default | 42 | **0** |

   84 / 70 / 42 lines over 12 / 10 / 6 predicted cells is exactly 7 lines per
   cell on every one of the nine.
6. **Canaries**: `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0`
   (uhdm2rtlil); `ctcan2.sh` PASS with `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6`;
   `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0
   FENCE-BREACH=0`.  Protected databases by name, md5 vs the pristine sweep:
   `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr` byte-identical;
   `SVSwitch` pin `4842211c4030`; `YosysVerx` pin `6ccda350c24a`.
7. **Corpus class_typespec census** (`uvmcen142.sh`, `UVMCENSUS.txt`) over the
   nine UVM databases that have a golden:

   | database | TSNAME W→R | TSINST W→R | RIGHT→WRONG | AWAY |
   |---|---|---|---|---|
   | SeqDriver default / testflags | 12 / 12 | 12 / 12 | 0 | 0 |
   | MiniAmiq default / testflags | 12 / 12 | 12 / 12 | 0 | 0 |
   | SimpleUVM default / testflags | 6 / 6 | 6 / 6 | 0 | 0 |
   | Scoreboard default | 6 | 6 | 0 | 0 |
   | BuildUVMPkg default / testflags | 10 / 10 | 10 / 10 | 0 | 0 |

   86 cells fixed on each of the two head fields; `TSALIAS`, `TSDEFN`, `TSCT`,
   `TSAUTO`, `TSPARM`, `TSPA`, `TSEXT` all RIGHT→RIGHT with unchanged one-sided
   sets.  An independent count that skips the scorer entirely (per span,
   `min(golden, patched) − min(golden, pristine)` on the TSNAME multiset) finds
   **12 fixed cells in SeqDriver/default and NO other span whose multiset
   changed at all** — zero collateral inside the database.
8. **Wide boundary** (`bound142.sh`) — see §8.

---

## 7. The instruments

    g++ -O2 -std=c++17 ct142cen.cpp -I ~/.local/include \
        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct142cen

| tool | what it answers |
|---|---|
| `ct142cen.cpp` | one row per `class_typespec`, deduped by `UhdmId`, with the nine fields the `Compare` chain reads plus a REFERRER index (`HOLD=`) built from every `ref_typespec`'s own `vpiParent` — the field that makes the TF-ITEM production visible in the database, with a subroutine's `Return()` variable marked `@ret` so the class-handle RETURN site cannot be mistaken for a body local |
| `score142.py` | golden / pristine / patched joined as a MULTISET per span key, per column; RIGHT→WRONG and AWAY are the two numbers that must be 0 |
| `pred142.py` / `predsweep142.sh` | the A-PRIORI mover predictor over a whole sweep workdir, from pristine databases only |
| `arms142.sh` | the three grids under Surelog + both binaries, both views, fd-3 file list, PROCESSED asserted |
| `uvmcen142.sh` | the corpus census over named rows, golden read from each row's OWN `cmds.txt` |
| `bound142.sh` | the wide boundary gate |
| `rowheads.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | carried unchanged from the standing battery |

**One instrument bug, found and fixed mid-pass, recorded because it is the
species of error this campaign keeps paying for:** `score142.py`'s built-in
filter matched `process` as a SUBSTRING, and `process` is a substring of
`uvm_cmdline_processor` — the first corpus census silently dropped THIS PASS'S
OWN HEAD CELLS and reported 8 fixed cells where there are 12.  The filter now
matches the WHOLE `Class_defn` name.

---

## 8. The wide boundary gate

`bound142.sh` compiles every `.sv`/`.svh` under the WHOLE of `tools/probe`
(3993 files, subdirectories included) with the pristine and the patched binary,
in BOTH views, to the SAME output path, and md5-compares first.  Only a file
whose database MOVED is dumped, censused and attributed, and it must be
attributable on FOUR independent counts:

1. its `ct142cen` census must have moved too;
2. the **PREDICTOR binary** — the PRISTINE emitter plus one inert `fprintf` that
   evaluates this law's OWN gate on the OLD code path (built in a separate
   worktree; never shipped) — must name at least one cell for that file AND
   view;
3. every moved census line must differ ONLY in `TSNAME=` / `TSINST=`;
4. every line of the whole-dump diff must be a `class_typespec` identity line,
   a `vpiName`, a `vpiInstance` or the package that instance names.

An rc mismatch between the two binaries is itself a breach (a segfault must
never read as "no differences").  The predictor's own source diff is committed
here as `pred142.diff` (apply to a fresh `eca7329` worktree and build) so the
gate is reproducible.

```
LISTED=4034 PROCESSED=4034 MOVED=14 BREACH=0 RC-MISMATCH=0 NORUN=306
PROCESSED-ASSERT-OK
BOUNDARY PASS
```

The 14 moved file-views are this pass's own three arms (6) and **four FOREIGN
arm files** written by another pass — `r10uvm139repro/g139_b_kinds.sv`,
`r10uvm139repro/g139_c_shapes.sv`, `r10v139repro/v139_a_kinds.sv`,
`r10v139repro/v139_h_odd.sv` (8).  Re-measured against GOLDEN, all four move
TOWARD it and nowhere else — an independent test of the law on grids this pass
did not write:

| foreign file (both views) | TSNAME | TSINST |
|---|---|---|
| `g139_b_kinds.sv` | TOTAL 13, R→R 5, **W→R 8** | TOTAL 13, R→R 5, **W→R 8** |
| `g139_c_shapes.sv` | TOTAL 4, **W→R 4** | TOTAL 4, **W→R 4** |
| `v139_a_kinds.sv` | TOTAL 18, R→R 6, **W→R 12** | TOTAL 18, R→R 6, **W→R 12** |
| `v139_h_odd.sv` | TOTAL 4, **W→R 4** | TOTAL 4, **W→R 4** |

RIGHT→WRONG 0, ONLY-GOLDEN 0, ONLY-OURS 0, AWAY 0 on every one.  Every moved
cell is a PAREN-LESS subroutine's class-handle body local
(`Forge139::Tongs139` ×4, `Loom139::Bobbin139` ×2, `Quarrel139::Trinket139` ×6,
`Wicket139::Pawl139` ×2).

**POSITIVE CONTROL** (`CTRL=1` over this pass's own arm directory):
`LISTED=3 PROCESSED=3 MOVED=6 BREACH=0` → `POSITIVE-CONTROL-OK (gate can see:
6 file-views moved)`.  `NORUN=306` file-views are files NEITHER binary produced
a database for.  See `BOUNDARY.txt`.

---

## 9. Residues and R0

* **R0 (the next head).**  SeqDriver ×2 and MiniAmiq ×2, 6254 / 6222 cmp lines,
  ONE `^LHS:` — the body `begin` of `uvm_pkg::uvm_component::m_set_cl_verb`
  (`uvm_component.svh:3387:3`), a `Stmts` **VECTOR SIZE MISMATCH** (the vector
  `SafeCompare` overload sets BOTH containers, so both sides print in full).
  Golden's `begin` holds **6** top-level statements, ours **8**; the two extra
  are the HOISTED INITIALISERS of two TF-ITEM locals:

  ```
  assignment  3381:14-3381:23    static bit first = 1;
  assignment  3383:25-3383:64    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  ```

  i.e. **under the TF-ITEM production Surelog does not hoist a local's
  initialiser into the body as an assignment statement** — the same face
  § 139 and this pass have been walking down.  See
  `head_pat_default_SeqDriver.summary.txt`.
* **R1 — the TYPEDEF'd handle.**  A local written through a typedef of a class
  takes Surelog's `SimpleType` arm and binds the TYPEDEF's own object; we mint
  a fresh one per declaration.  Deliberately fenced OUT of this law (the fence
  is the second bullet of §3).  Cells: `g142_c_shape` `e_td` / `e_tdspec` /
  `f_td` / `f_tdspec`, `g142_b_home` `pf_othtd` / `pfb_othtd`, `cpkg_td` — all
  `P == Q`.  Corpus incidence: zero (no predicted cell is a typedef'd handle).
* **R2 — the NESTED-class handle.**  Golden emits an `unsupported_typespec`
  where we emit a `class_typespec`; this pass gives ours golden's NAME and
  golden's INSTANCE, leaving only the KIND wrong.  Corpus incidence: zero.
* **R3 — one typespec per declaration STATEMENT.**  Golden compiles the tf-item
  `ts` ONCE, outside the declarator loop, and shares it across `a, b, c`; we
  mint one per declarator.  Count unchanged by this pass.  No generated
  `Compare` reads object identity, so this is invisible to the judge as long as
  every copy carries the same fields — which, after this pass, they do.
* **R4 — the `#(...)`-spelled generic's SPAN.**  Golden anchors the tf-item
  local's typespec at the class's NAME TOKEN (`populateCoreMembers(type, type)`
  where `type` is the `StringConst`), we anchor it at the whole written type.
  Dump-only.
* **R5 — the class-handle RETURN typespec.**  `g142_a_prod` `89:19`: golden
  names a `$unit` class's return typespec and we leave it anonymous.  A
  different Surelog site (the class-handle return arm) and a different law;
  untouched here (W→W 1 on both views of arm a).
