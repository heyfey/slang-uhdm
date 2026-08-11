# r10uvm47 — UVM pass 47

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours. Every `uhdm-cmp` invocation
in this pass is `uhdm-cmp <golden.uhdm> <ours.uhdm>`, never the other way round.**

**TWO laws. ZERO conversions. The head WALKED TWICE on the three tests the brief
put in front of it, and the brief's own framing of target 1 is REFUTED.**

| | HEAD (0b10344, re-measured, not inherited) | after law 1 | after law 1+2 |
|---|---|---|---|
| `SeqDriver` full cmp | **43 lines** | **32** | **38** |
| `SimpleUVM` full cmp | **43** | **32** | **38** |
| `Scoreboard` full cmp | **43** | **32** | **38** |
| `BuildUVMPkg` full cmp | **50** | 50, byte-identical | 50, same object (ids only) |
| the three heads identical modulo object ids | yes | yes | **yes** (md5 of the id-normalised cmp output is one value for all three) |
| verdict, all four, both modes | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` |

The line count is not monotone and that is not a defect: 43 -> 32 -> 38 is three
DIFFERENT objects, each one further into the same `compare_field` body. The head
is now `uvm_comparer.svh:156` where it was `:154` and before that
`uvm_object_globals.svh:637`. **Where the head ended up is § 5 and it is the most
useful line in this handoff.**

Every figure in the brief that I could re-measure, I did. Two are wrong; both
are recorded in § 1 and § 6.

## 0. THE BRIEF'S TARGET 1 IS REFUTED — the class_var is NOT missing

The brief states, in capitals, `RHS: <null>  <-- WE EMIT NOTHING AT ALL. THE FIX
ADDS.`, and derives five sub-requirements from it (two spans, the ref_typespec
fullname, `vpiAutomatic`+`vpiVisibility` on a package variable, the `new`
method_func_call, the double print). **All five were ALREADY SATISFIED at HEAD.**
`r10uvm47pv` (new) censuses every package-parented `variables` object with its
kind, name, fullname, span, `vpiAutomatic`, `vpiVisibility`, `vpiConstantVariable`,
its typespec's kind/name/span, its ref_typespec's fullname and its `vpiExpr`
kind. On `SeqDriver` it prints **twelve rows on golden and twelve on ours**
(6 declarations x `uvm_pkg` + `adpcm_pkg`), and the only textual difference in the
whole projection is `vpiFile`, which `BaseClass::Compare` does not read.

    golden  class_var'uvm_default_table_printer' full='uvm_pkg::uvm_default_table_printer'
            uvm_object_globals.svh:610:19-610:52 autom=1 vis=1 const=0
            ts=class_typespec'uvm_table_printer'@610:1-610:18
            refts='uvm_pkg::uvm_default_table_printer' expr=method_func_call'new'
    ours    class_var'uvm_default_table_printer' full='uvm_pkg::uvm_default_table_printer'
            :610:19-610:52 autom=1 vis=1 const=0
            ts=class_typespec'uvm_table_printer'@610:1-610:18
            refts='uvm_pkg::uvm_default_table_printer' expr=method_func_call'new'

Pass 26's § `packageVarAutomaticIsDataDeclShape26` already built that object, both
spans and all. **What was missing was ONE SCALAR POINTER**, and the reason the
head reads as a missing object is a property of the TOOL:
`BaseClass.h:191`'s scalar `SafeCompare` arm sets `m_failedLhs = lhs` — *the
child* — and leaves `m_failedRhs` at null, so `uhdm-cmp` prints the child against
`<null>`. The vector overload behaves differently (a size mismatch reports the
CONTAINER, `:210`), which is how the two cases are told apart. **Reading the
generated Compare code before theorizing is what turned "add a missing variable"
into "bind one pointer"**; the census that proved it is one-sided-proof-resistant
because it prints BOTH sides of the same projection.

The owner of that pointer is the SIXTH declaration the brief flagged and told me
to read golden for — `uvm_object_globals.svh:637`,
`uvm_printer uvm_default_printer = uvm_default_table_printer;`. Its `vpiExpr` is
a `ref_obj` and golden binds that ref_obj's **vpiActual** to the package's
`class_var uvm_default_table_printer`. The five `= new()` declarations at 610,
618, 626, 645 and 654 needed **nothing at all**: their `vpiExpr` is a
`method_func_call`, which carries no actual on either side. So the brief's
predicted head-walk `610 -> 618 -> 626 -> 637 -> 645 -> 654` did not happen and
could not have: **only 637 was ever wrong**, and it is the one spelling the brief
correctly warned had an unmeasured half.

## 1. § pkgInitRefBindsOwnListing47 — direction: ADD (one arm also REMOVES)

`src/ParamEmit.cpp` (`bindListingInitRefs47` / `bindInitRefsIn47`, new, next to
`emitPackageVar`; called from the package variable-listing site), `src/ModuleEmit.cpp`
(the imported-package hoist site), `include/UhdmExporter.h`.

**Every ref inside a finished VARIABLE LISTING's initialisers resolves against
THAT SAME LISTING, first entry of the name winning, variables only.**

### The gate, cell by cell — each predicate named by an arm, none assumed

| gate | arm cell | golden (LHS) | what happens without the gate |
|---|---|---|---|
| run AFTER the listing is complete, never incrementally | **t65b** (GOLDEN-ONLY; slang enforces the LRM and rejects use-before-declaration) `int f_fwd = f_late;` | **binds `q1::f_late`** — a FORWARD reference binds | an incremental "register as you emit" implementation cannot express it at all, and would leave every forward reference unbound |
| resolve WITHIN THIS LISTING, by name | t65a `p3` wildcard-imports `p1` and reads `i_first` | binds **`p3::i_first`**, the IMPORTING listing's own clone — NOT `p1::i_first` | binding the home package's object by SYMBOL is the natural implementation and is WRONG in every clone listing |
| UNQUALIFIED names only | t65a `q_qual = p1::i_first` (inside p1) and `p3_qual` | binds `p1::i_first` in p1, p2 AND p3 — the HOME object | widening to `::` names applies the existing `pkgVarObjsAll9` arm TWICE and this law, running later, wins with the wrong object |
| VARIABLES only, never NETS | **t65c** `int x_from_net = n_first;` where `n_first` is a `typedef logic [3:0]` declaration (the NET arm) | **binds NOTHING** | we bound the `logic_net`. This is the REMOVE half: our net arm registers into `pkgViewVarObjs9` eagerly inside the emission loop while the variable arm registers only after it, so **our two arms were wrong in opposite directions** |

> **CORRECTION FROM THE PASS-47 VERIFIER, and it is this campaign's own
> unmeasured-half trap turned on the write-up: "golden binds NOTHING" is ONE
> SIDE of t65c.** The omitted half is a golden that DOES bind — in t65c the
> *package* row `r1::x_from_net` has `actual=<none>`, but the *module-hoist* row
> `work@t65c.x_from_net` binds `logic_var 'n_first'@23:7-23:14`. So the real rule
> is not "never nets": it is **"the referent must be a `variables` object OF THIS
> LISTING"** — a net-typedef declaration is a `logic_net` in the package listing
> and so binds nothing, but it is a materialised `logic_var` in the module hoist
> and binds normally. The SHIPPED CODE implements both halves correctly; only
> this table was one-sided. A law that only ever saw one spelling has an
> unmeasured half — including when the "law" is a row in a results table.

| FIRST entry of the name WINS | **t65d** — the discriminator. A hoisted out-of-body-constructor local `dup_name` at line 21 and a package MEMBER `dup_name` at line 25 | binds the object at **21:9** — the HOISTED one | "the real package member wins" is the other reading and t65c alone could not separate them (its member happened to be first). Rule is LISTING ORDER |
| at EVERY DEPTH | t65a `int i_expr = i_first + 1;` | binds the ref at depth 1 under the `operation` | a top-level-only walk sees `expr=operation, actual=<none>` and measures the shape as ABSENT |
| the MODULE hoist is its own listing | t65a's `work@t65a` hoisted group | `work@t65a.i_back` binds `work@t65a.i_first` — the module's own hoisted copy | leaving it out would have kept the hoist half unmeasured |

Kinds that bind, all measured, none assumed: `class_var` (the uvm shape),
`int_var`, `string_var`, `enum_var` (t65c `ev_back`). Kinds that bind nothing on
either side, so the law must not touch them: a `= new()` initialiser
(`method_func_call`, no ref at all), a bare constant, and an `enum_const`
reference (which we already bind and golden agrees).

### Post, on this worktree's own binary

* `t65a`/`t65c`/`t65d` package cells: **every one of the law's positions is now
  identical to golden**, and the residual census diff is three PRE-EXISTING items
  named in § 6 (a def/top asymmetry on `p1::q_qual`, a module-hoisted
  integral-typedef `logic_var` that carries no initialiser at all on our side,
  and two extra subroutine-local objects).
  > CORRECTED: those two extra subroutine-local objects are in **t65c and t65d**
  > (`r1::ooc::new::shared_name`, `r2::ooc::new::dup_name`), NOT t65a. t65a's own
  > residual 3-line diff is one extra UNBOUND `p1::q_qual` copy plus
  > `work@t65a.n_back`/`n_first` losing their initialisers.
* Corpus: the SeqDriver / SimpleUVM / Scoreboard head at
  `uvm_object_globals.svh:610` is **GONE**, full cmp 43 -> 32 lines on all three.
* `BuildUVMPkg` byte-identical — the 1800.2-2017-1.0 `pp_output` has no
  `<class-type> <name> = <other variable>;` at package scope, so the law does not
  fire there. **The brief's "96 `= new(` lines" figure is irrelevant to this law
  for exactly the reason the brief itself warns about**, and I did not reuse it.

## 2. § pkgParamInClassMethodStaysRef47 — direction: REPLACE (constant -> ref_obj)

`src/ExprEmit.cpp`, in the existing `scope is a Package && symbol is a Parameter`
block, ahead of the `pkgScopeInst` arm and the fold.

**An IN-BODY CLASS METHOD reading a parameter of the class's OWN ENCLOSING
PACKAGE keeps an UNFOLDED, UNBOUND `ref_obj`; a parameter from anywhere else
folds.** Head this closed (`uvm_comparer.svh:154`, `mask >>= (UVM_STREAMBITS-size);`
against `parameter UVM_STREAMBITS = \`UVM_MAX_STREAMBITS;` at
`uvm_object_globals.svh:39`):

    LHS(golden) ref_obj (uvm_pkg::uvm_comparer::compare_field::UVM_STREAMBITS)
                154:15-154:29, parent operation 154:15-154:34,
                vpiName + vpiFullName and NOTHING else — no vpiActual, no typespec
    RHS(ours)   constant 4096, vpiSize 32, vpiConstType 9

### FOUR candidate keys the uvm site suggested — ALL FOUR REFUTED

The site is a `parameter` (not `localparam`), IMPLICITLY typed, read inside an
OPERATION, in a class method. Arm **t66a** puts one parameter in nine positions
with a control for each:

| cell | t66a line | golden | verdict |
|---|---|---|---|
| class method, in an operation (the uvm shape) | 42 | ref_obj | — |
| class method, BARE assignment Rhs | 48 | ref_obj | **position REFUTED as a key** |
| class method, EXPLICITLY typed `parameter int` | 54 | ref_obj | **implicit typing REFUTED** |
| class method, `localparam` | 60 | ref_obj | **`parameter` vs `localparam` REFUTED** |
| class method, the exact `>>=` statement shape | 67 | ref_obj | — |
| package FUNCTION body | 75 | ref_obj | control — we already agreed |
| class PROPERTY initialiser | 36 | ref_obj | control — we already agreed |
| typedef RANGE bound | 33 | ref_obj | control — we already agreed |
| MODULE body | 87 | **constant** | control — we already agreed |

### THE ANCESTOR TEST IS THE REAL GATE, and t66b is what named it

t66a cannot see it: its class, its method and its parameter are all in ONE
package. Arm **t66b** splits them:

| cell | t66b line | reader | parameter's home | golden | ours at HEAD |
|---|---|---|---|---|---|
| `u2::c_pkg::m_own` | 33 | class method in pkg `u2` | pkg `u2` — an ANCESTOR | **ref_obj** | **constant** — the one cell that moves |
| `u2::c_pkg::m_other` | 28 | class method in pkg `u2` | pkg `u1`, seen through `import u1::*` | **constant** | constant — already equal |
| `c_mod::m_pkg` | 58 | class method in a MODULE | pkg `u1` | constant | constant — already equal |
| `c_mod::m_qual` | 63 | class method in a MODULE, written `u1::U1_P` | pkg `u1` | constant | constant — already equal |
| `c_unit::m` | 44 | class method in `$unit` | pkg `u1` | constant | constant — already equal |
| `c_mod::m_mod` | 68 | class method in a MODULE | that MODULE's parameter | ref_obj | ref_obj — already equal (this block is never entered: `scope` is not a Package) |
| `c_mod::m_cls` | 73 | class method | the CLASS's own localparam | ref_obj | ref_obj — already equal |

**Without the ancestor test this law would have moved cells 28, 44 and 58 — three
positions where we already agree with golden — and the corpus regression would
have read as a refutation of the whole law.** That is the brief's "running the
WRONG law once against the real corpus beats another arm cell" turned into an arm
cell instead, at the cost of one golden run.

Out-of-body methods are excluded (`!curSubOob9`): a different Surelog entry point
compiles them in the home package's scope and no golden was read. The predicate
reuses the shape of the existing § `pkgClassEnumFold13` walk, with the ancestor
comparison added.

### Post

* the `:154` head is gone on all three tests; full cmp 32 -> 38 lines.
* `t66a`: all five class-method cells now `ref_obj` with golden's fullname
  (`s1::rdr::m_op::P_IMPL` etc.); the module cell still folds.
* `t66b`: cell 33 flipped to `ref_obj` matching golden; cells 28/44/58/63/68/73
  **unchanged**.
* `BuildUVMPkg` object ids shift (the law fires there too) but its head is the
  SAME OBJECT and its residue is unchanged.

## 3. Gates — all four, on this worktree's own binary, md5 checked before AND after every sweep

`SLANG_UHDM` pinned to this worktree's `build/slang-uhdm` for every run
(`scripts/verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one). **No
build ran while a sweep was in flight**; `gate2.sh` prints the binary md5 before
and after and both printed values matched on every sweep.

Binaries: HEAD `3f2b9b2b7cdda9de5db0d55ff92a7871`, law-1-only
`664dd8c48f42ff5da216fd85b7705de3`, law-1+2 `8c858276f8e20b0a3202614e82e2fd78`.
**The HEAD binary was rebuilt a second time from `git checkout --` of the three
touched `.cpp` files (the patch touches FOUR production files — `include/UhdmExporter.h`
plus those three — and reverting only the `.cpp`s leaves unreferenced declarations
behind, which is harmless and still reproduces the HEAD binary; the pass-47
verifier confirmed that independently from a pristine build) and came out md5-IDENTICAL to the one built from pristine HEAD
before any code was written** — the baseline is the baseline.

1. **Build** `cmake --build build -j 3`: `Built target slang_uhdm`, 0 errors.
2. **Goldens** `23 PASS / 0 FAIL`, with the **NEGATIVE CONTROL on the gate script
   itself**: `SLANG_UHDM=/bin/false` gives `0 PASS / 23 FAIL` (rc=1).
3. **uhdm2rtlil `testflags`, --jobs 2, own --out**: 732 rows, `679 CMP_EQUAL /
   50 SLANG_REJECT / 2 SURELOG_FAIL`, **0 whole-row diff lines** against
   `results/gate_uhdm2rtlil.csv` — run for law 1 alone AND for law 1+2. No dump
   `match -> differ`, no status change. Canaries by name: `add_sub_bind_if`,
   `bind_hier`, `bind_toplevel`, `paramod_genscope_child`, `issue326_packed_mem`
   `CMP_EQUAL` + `match`; `assignment-pattern`, `genscope_cells`,
   `genvar_loop_decl_3`, `hier_path`, `MultirangesStartNotFromZero` `CMP_EQUAL`
   at their baseline dump values.
4. **surelog `--mode both`, --jobs 2, own --out**: 1589 rows, **0 whole-row diff
   lines** against `results/golden_surelog.csv` INCLUDING the `DUMP` column — for
   law 1 alone and for law 1+2. Canaries: `InterfaceBinding` `CMP_EQUAL` +
   `dump=match` in BOTH modes, `BindHierPath` `CMP_EQUAL` + `match`, `LowMemPkg` (default only — its testflags row is SURELOG_FAIL AT BASELINE) /
   `InterfaceModExp` / `EnumConcat` `match`, `FuncStruct` / `FuncStructVal` /
   `FuncIoTypespec` / `EvalFunc` / `ClassExtends` / `Scr1SvTests` / `BasicOh`
   `CMP_EQUAL`. `SLANG_REJECT` membership unchanged (286, identical rows).
   **No `Google,testflags` SURELOG_FAIL-vs-TIMEOUT line appeared in this pass's
   runs** — the known six-pass environment flake did not fire; I am naming its
   absence rather than claiming credit for it.
5. **BYTE VERIFIER** (the whole-row CSV diff is blind inside the already-
   `CMP_NOTEQUAL` rows), HEAD binary vs POST binary writing to the SAME workdir:
   * law 1 alone: **953 databases, 948 identical, exactly 5 DIFFER** —
     `default/{SeqDriver,SimpleUVM,Scoreboard}`, `testflags/{SeqDriver,SimpleUVM}`.
   * law 1+2: **953 databases, 946 identical, exactly 7 DIFFER** — the same five
     plus `default/BuildUVMPkg` and `testflags/BuildUVMPkg`.
   Nothing else in either corpus moved a byte. `Scoreboard` has no `testflags`
   database (it is `SLANG_REJECT` there), which is why the count is 5 and 7 rather
   than 6 and 8.
6. **The `Scoreboard` flake, settled INSIDE this pass rather than excluded by
   name** (the pass-46 precedent): two INDEPENDENT sweeps of the UVM-4 on the
   law-1+2 binary produced **byte-identical `uhdm-cmp` output for Scoreboard**
   (`751f0f0cfbcd`), and its head content changed 43 -> 32 -> 38 lines in step
   with the two laws, each step landing on a specific named object. The
   macro-buffer `SourceLocation` flake does not produce that. So Scoreboard's
   change is REAL; its byte difference is nonetheless still not usable in an
   "N identical" control and is not used in one above.

## 4. Deliberately NOT done, with reasons

* **The brief's TARGET 2** (`BuildUVMPkg`'s `uvm_id_verbosities_array`
  class_typespec / doubled `uvm_pkg::uvm_pkg::` `vpiTypedefAlias`): **HONESTLY
  NOT DONE**, not attempted beyond confirming its head is unchanged and is the
  same object after both laws. It was outranked on the brief's own criterion the
  moment law 1 landed: the head law 1 exposed sits in front of THREE tests where
  target 2 sits in front of part of ONE, and the brief's order-of-work says a
  clean conversion beats two half-gated laws. Ranked #2 in § 5 with everything I
  know about it.
* **The `x_from_net` REMOVE arm was implemented** (it is the same law site) but
  its corpus reach was NOT censused: the byte verifier says no database outside
  the UVM-4 changed, which bounds its reach to zero on both corpora but does not
  enumerate the shape.
* **The metric panel** (`r10uvm28a` / `r10uvm41ts` / `r10uvm42tw` / `LSTOTAL` /
  `LISTDIRECT` / `BINDWRONG` …) was NOT re-measured this pass. The brief's method
  law says "THE BISECTOR IS THE FRONTIER AND THE CENSUS IS NOT — do not retreat
  into building another counter", and the frontier was in hand. Every panel
  number in the brief is therefore INHERITED, not confirmed, and the next pass
  should treat them as such.

## 5. RANKED RESIDUE, most reachable first

1. **`uvm_comparer.svh:156` — WHERE THE HEAD ENDED UP. ONE law, THREE tests,
   identical head (md5 of the id-normalised cmp output is one value across
   SeqDriver, SimpleUVM and Scoreboard). Direction: REPLACE. Depth: one statement
   emitter.** Source: `uvm_object::__m_uvm_status_container.scope.set_arg(name);`
   Golden collapses the WHOLE statement to a single bare `ref_obj`:

       LHS ref_obj (uvm_pkg::uvm_comparer::compare_field::uvm_object::__m_uvm_status_container)
           156:7-156:19, vpiParent = begin (uvm_pkg::uvm_comparer::compare_field),
           vpiName `uvm_object::__m_uvm_status_container`, and nothing else
       RHS method_func_call 'scope' 156:44-156:49 whose vpiPrefix is
           ref_obj '__m_uvm_status_container' 156:7-156:43

   Note the span: `156:7-156:19` is **`uvm_object::` alone** (12 characters),
   which is exactly the shape § `staticScopedRef12` already documents — "the
   object is an unbound ref_obj named FIRST-SEGMENT `::` FINAL-IDENTIFIER and
   spanned only up to (not including) that final identifier". So the existing law
   has the NAME and the SPAN right and the missing half is that the whole
   `.member.call(...)` CHAIN is dropped, statement and all. Arms to build before
   coding: a class-scoped static read with (a) no chain, (b) one `.member`,
   (c) `.member.call()`, (d) `.call()` directly, (e) as an r-value inside a
   larger expression rather than a whole statement — (e) decides whether the
   collapse is a STATEMENT rule or an EXPRESSION rule, and that is the half that
   would otherwise go unmeasured.
2. **The brief's target 2**, `BuildUVMPkg`'s only head, unchanged and re-verified
   this pass (50 cmp lines, same object). Direction: REPLACE. Depth: the package
   typedef-specialisation listing. Carried forward with the brief's own reading
   intact and one addition from this pass: **the doubled `uvm_pkg::uvm_pkg::`
   prefix on a self-alias `ref_typespec` is a shape this emitter ALREADY builds
   deliberately** — `src/ParamEmit.cpp`'s generic-class typedef-alias block
   writes `prefix + prefix + name` with the comment "like every other self-alias
   this emitter builds". So that half of target 2 is not a mystery and not a
   print artifact; the missing half is that we publish an inline class_typespec
   parented at the declaring CLASS_VAR instead of a package-parented alias chain.
   **NEVER MUTATE A SHARED OBJECT applies in full here** (`isSharedAliasTs`,
   `pkgTopTypedefTs`, `typedefTs`).
3. **The `p1::q_qual` def/top asymmetry** (t65a, PRE-EXISTING at HEAD, unrelated
   to both laws). Direction: ADD. Depth: one map lookup. Golden binds an
   explicitly `p1::`-qualified reference to the home package's parameter/variable
   in BOTH package views; we bind it in one view and leave it null in the other
   (two objects named `p1::q_qual`, one bound, one not). The cause is visible:
   `pkgVarObjsAll9` is populated only after a listing's emission loop, so the
   FIRST view emitted has nothing to find. Small, and it has a golden in hand.
4. **The module-hoisted integral-typedef `logic_var` carries NO initialiser**
   (t65a `work@t65a.n_back`, t65c `work@t65c.n_first`). Direction: ADD. Depth: the
   `intTypedef9` arm of the imported-package hoist in `src/ModuleEmit.cpp`, which
   builds the variable and its typespec but never reads `dt->getInitializer()`.
   Golden gives it the initialiser AND (for `n_back`) binds the ref inside the
   hoisted listing, so § pkgInitRefBindsOwnListing47 would then cover it for free.
5. **The module hoist's listing is missing the hoisted out-of-body constructor
   locals** (t65d: golden's module hoist binds `work@t65d.dup_name`@21:9, the
   hoisted local; ours binds @25:7, the member, because ours is the only entry).
   Direction: ADD. Depth: `collectImportedPkgVars` vs `collectOobCtorLocals`.
   **Currently cmp-INVISIBLE** — `variables::Compare` reads no location, so
   binding the wrong same-named object compares equal — which makes it exactly
   the kind of latent wrongness that surfaces later as a fresh bug. Recorded
   rather than left for someone to rediscover.
6. **The `::`-qualified fold's constant SIZE** (t66b:63, golden 64 / ours 32,
   PRE-EXISTING). Direction: REPLACE. One field.
7. **Pass 46's § 3 residue, carried unchanged**: golden stamps `vpiAutomatic` on
   a plain class method that writes `automatic` (`t64a`/`t64c`) where our
   `VpiAutomatic` arm is guarded `&& !classScope`. Needs its own reach census.
8. Carried from pass 46 § 6, **all INHERITED and NOT re-measured this pass** (see
   § 4): `BINDWRONG` 757 / `BINDTOTAL` 1681 = 938 extra / 743 miss (attack the
   extra half); the `r10uvm42tw`/`r10uvm41ts` clone-sharing residue;
   `LISTDIRECT` 80 vs golden 56; `CPTOTAL` 580; `TSINSTTOTAL` 1074; `CPCLASS` 25;
   `INITTOTAL` 52; `BODYOTHER` 434; the PROGRAM arm of § 45; the module arm of
   § `classKeyTsScopeOwner35`; the `types_t` ELEMENT position; the 238-row
   unspanned empty `array_typespec` family; the four `t60a` LISTED span rows; the
   module-implicit-net wash; BARE->SELF 438 rows; the socket-sharing residue;
   `t40a`; `t36b`; `t33d`; and the still-unmeasured ELEMENT half of pass 43's
   widened kind gate.

## 6. Corrections to the brief, and other things the next pass should know

1. **`RHS: <null> <-- WE EMIT NOTHING AT ALL. THE FIX ADDS.` is wrong** for the
   object it names. The class_var is present and field-for-field equal; the fix
   adds a `vpiActual` on a DIFFERENT declaration's initialiser ref_obj (§ 0).
   The brief's five derived sub-requirements were all already met at HEAD.
2. **The predicted head-walk `610 -> 618 -> 626 -> 637 -> 645 -> 654` did not
   happen.** Only 637 was ever wrong; the five `= new()` sites carry a
   `method_func_call` with no actual on either side. The brief was right that 637
   needed reading before the law was written — it was the ONLY thing that needed
   it.
3. **`cmp prints the failing node twice; that is the tool, not two defects` —
   CONFIRMED, and here is the mechanism**: `UHDM::decompile`
   (`templates/vpi_visitor.cpp:603`) writes the rendering to `std::cout` AND
   returns it, and `util/uhdm-cmp.cpp:105` writes the returned string to
   `std::cerr`. One print site, two streams.
4. **`GetByVpiType` is NOT a complete relation walk** — it has no `vpiTypespec`
   arm, among others. `r10uvm47ro`'s null-slot scan is therefore reported as
   "in the relations GetByVpiType exposes", never as a whole-model zero. A census
   one field short of what Compare reads reports a CLOSED head.
5. Our package `class_var`s carry an EMPTY `vpiFile` where golden carries
   `uvm_object_globals.svh`. `BaseClass::Compare`
   (`templates/BaseClass.cpp:163`) reads `VpiType`, `VpiName` and `VpiDefName`
   only — **not `VpiFile`, and `variables::Compare` reads no location either** —
   so this is cmp-invisible and is NOT a defect any gate would catch. It is also
   why residue item 5 is invisible.
6. Law 2 mints `ref_obj`s where constants used to be, so **object ids shift in
   `BuildUVMPkg`** without its residue changing. An id-only diff of a cmp head is
   not a change; § 0's normalisation (`sed 's/id:[0-9]*/id:N/g'`) is how this pass
   compared heads across binaries and across tests.

## 7. Apparatus

New probes (all built by `probebuild.sh`, all STATIC against the installed
`libuhdm.a`/`libcapnp.a`/`libkj.a`, all in this pass's `/tmp/r10uvm47_` namespace):

* **`r10uvm47pv.cpp`** — the package-scope `variables` census (kind, name,
  fullname, span, automatic, visibility, const, typespec kind/name/span,
  ref_typespec fullname, expr kind, parent) plus a generic **PATH finder** built
  on `UhdmListener`, which follows every generated relation rather than a
  hand-picked list, and prints the callstack to each matching object. The PATH
  half is what proved the failing pointer was reached from the package listing
  and not from some other container. Refuses to report when a database holds zero
  `variables`; announces an empty filter selection on stderr with the population.
* **`r10uvm47ro.cpp`** — the initialiser-BINDING census over every `variables`
  AND every `nets` object, recursing the whole initialiser expression and
  reporting each ref's DEPTH, its `vpiActual`'s kind, fullname AND SPAN (two
  objects in one listing can share a fullname — t65c has exactly that pair, and a
  fullname-only report cannot say which one a binding picked). Prints the owner's
  `vpiParent` so a package listing, an importing package's clone and a module
  hoist are told apart.
* **`r10uvm47pf.cpp`** — the FOLD census, keyed on **SOURCE SPAN**, because a
  folded `constant` and an unfolded `ref_obj` have nothing else in common (a
  constant has no name, so no KIND:NAME census can see a fold disagreement).
  Refuses to report when a database holds zero refs and zero constants.

New drivers: `cmp4.sh` (the FULL cmp output per UVM-4 test out of a sweep
workdir, FATAL on every missing input), `arms65.sh` (per-cell census diff AND cmp
verdict for the t65 arms, FATAL rather than silent), `gate2.sh` (the gate driver
at `--jobs 2` that prints the binary md5 BEFORE and AFTER every sweep). Inherited
unchanged: `gold.sh`, `goldfile.sh`, `csvdiff.sh`, `byteverify.sh`, `uvm4.sh`,
`probebuild.sh`, and pass 46's `t63*`/`t64*` arms.

New arms: **`t65a`** (7 binding cells x 3 package listings x the module hoist),
**`t65b`** (GOLDEN-ONLY: the forward-reference half), **`t65c`** (the net/variable
cross cells and the hoisted-local name collision), **`t65d`** (the
first-wins-vs-member-wins discriminator), **`t66a`** (9 fold cells refuting all
four candidate keys), **`t66b`** (7 cells; the ancestor test's discriminator and
six must-not-move controls).

The namespace shift from pass 46 was done with a **prefix-anchored** sed
(`/tmp/r10uvm46_` -> `/tmp/r10uvm47_` only), inheriting pass 44's lesson that a
blanket rename rewrites the PROBE BINARY names and every driver then reports
perfection; the surviving `V=/tmp/r10uvm47_r10uvm44ls`-style paths were verified
to keep their BIRTH-pass binary names.

## Integration notes added by the master at land (pass-47 verifier findings)

**D1 — A REAL TYPE-PUNNING DEFECT, FIXED BEFORE LANDING, NOT FILED AS RESIDUE.**
`bindInitRefsIn47` handled `uhdmref_obj` and `uhdmref_var` in one arm with a
single `(UHDM::ref_obj*)e` cast. `ref_var` is `final : public variables` and
`ref_obj` is `: public simple_expr` — **unrelated hierarchies** — so that
C-style cast was a `reinterpret_cast`: `VpiName()` read ref_obj's name slot from
inside a `ref_var`, and `Actual_group(...)` **wrote** at ref_obj's offset inside
it. Arbitrary field corruption. It was LATENT (all 8 `MakeRef_var` sites are
statement contexts, and a listing initialiser comes from `emitExpr`, which mints
none), which is exactly why all four gates and the byte verifier stayed green.
**No measurement could have caught this — only reading the hunk against the UHDM
class hierarchy could.** Both kinds really do carry `VpiName` and
`Actual_group`, so the law legitimately covers both; it now reaches them through
`any_cast` on their own static type, at all three access points (read name, read
actual, write actual). Precedent for the correct idiom is in this pass's OWN
probe (`r10uvm47ro.cpp::actualOf`) and at `src/UhdmExporter.cpp:4403/4416`.

**D2 — the shipped law is NARROWER than this README's headline, deliberately.**
The code only touches a ref whose `Actual_group()` is null or a NET
(`if (cur && !any_cast<const net*>(cur)) return;`). So what ships is "every
UNBOUND or NET-bound unqualified ref in a finished listing binds to the
listing's first same-named variable", not "every ref resolves against that
listing". That is the regression-safe reading and it is disclosed in the code
comment. **Pass 48 must not assume the FIRST-WINS rule overrides an existing
VARIABLE binding made at the mint site** — that case is unmeasured.

**D3 — unmeasured half, recorded.** `bit_select`, `part_select`, `var_select`
and `indexed_part_select` ARE `ref_obj` subclasses in UHDM and carry their own
`VpiName`/`Actual_group`. The walk descends into their index/range children but
never binds the select node itself, and there is no `hier_path` arm at all. So
`int x = arr[i];` at package scope leaves the base unbound.

**PROBE CAVEATS — write these next to the probes before reusing them.**
* `r10uvm47pf`'s filter also matches the object's FILE leaf, and OUR databases
  carry an EMPTY `vpiFile`, so a file-based filter selects NOTHING on our side:
  `r10uvm47pf ours.uhdm dut.sv` prints `EMPTY: population=62 ... PFTOTAL=0`. The
  positive control fires correctly, but stdout alone reads as a CLOSED RESIDUE.
  Use a NAME filter (or none) on our side.
* `r10uvm47pv` and `r10uvm47ro` DEDUPLICATE identical projection lines (`sort` +
  `unique`), so `PVTOTAL`/`ROTOTAL` count DISTINCT PROJECTIONS, not objects
  (`population` is the object count). "Twelve rows on golden and twelve on ours"
  is sound as a field-for-field EQUALITY claim but **cannot detect a
  duplicate-count difference between the sides** — so residue 3's reading ("we
  bind in one view and not the other") cannot be separated from "we hold an
  extra object" by this probe alone.
* Keep byte-verifier intermediates in the `/tmp/r10uvm47_*` namespace. The
  verifier's own copy used a bare `bv_*` prefix in the shared scratchpad and
  overwrote a previous session's `bv_join/bv_same/bv_diff` files.

**ONE HEAD, NOT FOUR — a correction to the MASTER's own figures.** uhdm-cmp
stops at the FIRST failing pair and writes exactly ONE `LHS:`/`RHS:` pair per
file. A `grep -c '^decompile:'` of 4 is ONE head printed twice per side
(`UHDM::decompile` writes to cout, uhdm-cmp echoes the return to cerr). The
"2 heads / 4 heads" figures the master put in the pass-47 and pass-48 briefs are
that double print. `cmp4.sh`'s own `heads=` counter was independently dead (it
grepped `'^  LHS:'` against a column-0 `LHS:`, so it printed 0 every time) and is
fixed here.

**FOR TARGET 2 (pass 48), confirmed at its line by the verifier.** The
doubled `uvm_pkg::uvm_pkg::` self-alias prefix is REAL and already deliberately
built at `src/ParamEmit.cpp:18869-18876` — one `class_typespec` per generic class
is the base and the rest are clones with a `vpiTypedefAlias` ref carrying the
doubled fullname. So the machinery target 2 needs already exists. TWO WARNINGS:
that block picks the base by **NAME order** while golden's target-2 base is the
**SOURCE-FIRST** typedef — they coincide only because `uvm_id_actions_array`
sorts before `uvm_id_verbosities_array`, so do NOT assume name-first is the
rule; and `typedefTs`/`pkgTopTypedefTs` are populated ten lines above
(`18857-18860`), so the NEVER-MUTATE-A-SHARED-OBJECT / `isSharedAliasTs` rule
bites directly there.
