# r10uvm23 — UVM pass 23

Pass 22's ranked **#1**, `§ classInheritsContainerImports22`, is **IMPLEMENTED**.
Gated clean, **0 movers**, and the listing gap it was decoded from is **95%
closed**: 8356 -> 410 diff-lines over the UVM-4, with **task_funcs, parameters
and param_assigns now BYTE-IDENTICAL to golden**.

| | tf | ts | var | par | pas | TOTAL |
|---|---|---|---|---|---|---|
| HEAD e8be6e3 | 6260 | 955 | 331 | 405 | 405 | **8356** |
| + § classInheritsContainerImports23 | **2** | 374 | 34 | **0** | **0** | **410** |

(`tools/probe/r10uvm23m.sh`, the metric this law needs — see below.  SeqDriver's
five adpcm classes alone: `tf 4504/4504 difflines=0`, `par 225/225 difflines=0`,
`pas 225/225 difflines=0`, `var 179 vs 178`, `ts 618 vs 450`.)

Gate on the final tree: goldens **23/23 PASS**; u2r testflags (732 rows) and
Surelog both-modes (1589 rows) **byte-identical** to the committed baselines
(`diff | wc -l` = 0 each, dump column included) — so SLANG_REJECT membership,
every canary and every `dump=match` are unchanged.

---

## The law as implemented

> **§ classInheritsContainerImports23** — a CLASS inherits the whole content of
> every package imported by its CONTAINER into its OWN `vpiTaskFunc`,
> `vpiTypedef`, `vpiVariables`, `vpiParameter` and `vpiParamAssign` listings,
> BEFORE its own members.

`CompileClass::compile_class_` (:137-158) builds `pack_imports` from the class's
own FileContent objects PLUS its container's, and calls
`CompileHelper::importPackage` once per **ITEM** — not once per package.  Pass
22 decoded the source; this pass measured what each PRODUCER of those items is
worth and what each of the five listings does with them.

### 1. Multiplicity — four producers, four different counts

Measured, both directions, on `t34a`/`t34b`/`t34c` (this pass) on top of pass
22's `t33a`/`t33c`:

| arm | class lives in | import written at | copies |
|---|---|---|---|
| t33a | package `pk2` | `pk2`'s own body | **1** |
| t34a | module `top` | `top`'s own body | **1** |
| t33c | `$unit` | `$unit`, same file | **2** |
| t34c | package `pk2` | `$unit`, same file | **2** |
| t34b | module `top` | `$unit`, same file | **4** |

The rule behind the table:

* a `$unit`-scope import in the class's OWN FILE counts **twice** —
  `CompileFileContent` (:83) calls `importPackage`, which registers the item on
  the FileContent itself (`CompileHelper.cpp`:131), and then adds the SAME item
  a second time (:88);
* a **PACKAGE** container contributes only its own body imports, **once** each:
  packages are compiled BEFORE the file contents, so `CompilePackage.cpp`:143's
  "local file imports" loop saw an EMPTY list — which is why t34c reads x2 and
  not x4;
* a **MODULE/PROGRAM/INTERFACE** container contributes its own body imports
  once AND the same-file `$unit` ones twice: its local-file loop
  (`CompileModule.cpp`:572) DID run, so those items are on the module too.
  That is `§ collectMaterializedPkgs`' module rule, one level out (t34b: x4);
* a `$unit`-scope class has **no container at all** (`ResolveSymbols.cpp`:163
  passes `nullptr`), so only the file's own x2 applies.

### 2. The five listings split three ways

* **task_funcs** are SHARED (`inPackage` is false for the class caller, :319) —
  the pointers, not clones — and carry the `duplicate` name check (:311).
* **typespecs** go through `insertDataType`, a `std::map` keyed by the type
  NAME, so they de-duplicate AND come out **name-sorted**, with the class's own
  typedefs merged into the same order (`t34d`: `aaa_t`, `pk1::nib_t`,
  `pk1::srec_t`, `zzz_t` — the own ones do NOT simply follow).
* **variables**, **parameters** and **param_assigns** have NEITHER a check nor
  a map, so they land once per import ITEM — the double-count above.

### 3. Two rules the source reading alone would have got wrong

**The duplicate-name check reads the PACKAGE listing's name, not the final
one.**  A package lists a class method under its QUALIFIED spelling (`C::run`,
`t33d`'s `DEFPKG[pk]`), while `materializedPkgTfGroup` hands back the
class_defn-parented DEFINITION object, whose `VpiName` is the bare `run`.
Keying the check on the bare name collapsed uvm_pkg's 894 entries to **586** —
every `new` / `do_copy` in the package folding onto one — where golden keeps all
894.  Keying an IMPORTED class method qualified and a package FREE subroutine
bare reproduces both measured directions at once: `t34e`'s `pk1::f1` DOES
suppress the importing class's own `f1` (golden lists `f1`, `f3` and no
`C::f1`), and `t33d`'s `C::run` does NOT suppress `C`'s own `run`.  With the
key right, SeqDriver's five classes read 899/905/898/901/901 — golden exactly.

**The parameter arm is name-sorted; the param_assign arm is not.**
`importPackage` walks `def->getParameterMap()` (a `std::map<name,Parameter*>`)
for parameters but `getParamAssignVec()` (a vector) for param_assigns.
SeqDriver shows it directly: `adpcm_driver`'s 45 parameters read `UVM_ABSTRACT`,
`UVM_ALL_ON`, `UVM_CHECK_FIELDS`... while its 45 param_assigns are uvm_pkg's
declaration order.  Both listings are 225/225 with 0 diff-lines once the two
orders are separated.

---

## Bring your own metric

Pass 22 recorded that this law is INVISIBLE to the pass-19 body-residue metric
(`r10uvm19m.sh` walks MATCHED task_func bodies, so a listing our side never
populates is never compared).  `tools/probe/r10uvm23m.sh` is the metric it
needs: for every `class_defn` in every view of the UVM-4 it diffs golden's and
our ORDERED listings as `<type> '<name>'` lines and totals the diff-lines per
vector.  `tools/probe/r10uvm23b.cpp` is the dumper behind it (and the one that
diffs a single class against golden).

    R10B=<r10uvm23b build> tools/probe/r10uvm23m.sh <sweep workdir>

**Build the probes with the STATIC UHDM libs.**  `-luhdm` picks up a shared
library that restores Surelog's `.uhdm` files with NULL vector contents (sizes
survive, pointers do not) — every listing reads `<null>` and the census silently
measures nothing:

    g++ -std=c++20 -O2 tools/probe/r10uvm23b.cpp -o /tmp/r10uvm23b \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread

...and generate the repro goldens with `~/git-repos/Surelog/build/bin/surelog`,
the harness's own binary — not the `sv-tests` third-party copy, whose output
this UHDM cannot read either.

---

## Arms: 9 of the 10 byte-identical to golden

`t33a`/`t33b`/`t33c`/`t33e` (pass 22) and `t34a`..`t34g` (this pass) all read
**IDENTICAL** on the whole class-listing dump.  The one exception is `t33d`,
and it is not this law: golden's `pk::C` lists `run` THREE times (the imported
copy, the `extern` PROTOTYPE object at line 21, and the DEFINITION at line 23)
where we list two — our class's own listing carries the definition alone.  The
import half of that arm is now right: `pk::Cel`, which gets `C::run` only
because the `$unit` `import pk::*` re-imports the class's OWN package, matches
golden exactly.

---

## RANKED #1 for pass 24 — the class TYPESPEC set (`ts 374`, purpose-built and reproduced)

The only listing still short is `vpiTypedef`, and the gap is **not** in the
class arm: it is in the PACKAGE-level import, which the class arm faithfully
inherits.  SeqDriver, golden vs ours:

| | golden | ours |
|---|---|---|
| `DEFPKG[adpcm_pkg]` ts | 124 | 90 |
| `ELABPKG[adpcm_pkg]::adpcm_driver` ts | 123 | 90 |

The ~34 missing entries are all class-local typedefs — `this_type`,
`this_subtype`, `type_id`, `super_type` — carrying the IMPORTING package's name
(`adpcm_pkg::this_type`), and their sort positions give away the map key:
golden's `ts[8] 'adpcm_pkg::this_type'` sits between `uvm_active_passive_enum`
and `uvm_apprepend`, i.e. the DataTypeMap key is the QUALIFIED
`<class>::<typedef>` while the object's `VpiName` is the bare one requalified by
`writeDataTypes` (`UhdmWriter.cpp`:791) with the importing package's name.

Two purpose-built arms separate the ingredient:

* **`t34f`** — imported package `pk1` holds a PLAIN class `K` with
  `typedef int this_type; typedef bit[6:0] kk_t;`.  Golden's `pk2::C` lists
  `pk1::nib_t` and NOTHING else, and we are **byte-identical**.  A plain class's
  local typedefs do not propagate, and neither does a class_typespec for `K`.
* **`t34g`** — the same with `K` PARAMETERIZED (`class K #(type T = int)`) and
  SPECIALIZED by the importer (`K #(byte) kb;`).  Golden's `pk2::C` gains
  `class_typespec 'pk2::this_type'` **ahead of** `pk1::nib_t` (so the key sorts
  before `nib_t` — consistent with `K#(byte)::this_type`), and `DEFPKG[pk2]`
  gains the same object.  `kk_t`, whose target is not a class, does NOT come.

So the next law is: **specializing an imported parameterized class publishes
that specialization's CLASS-TYPED local typedefs into the specializing scope's
DataTypeMap, under a `<specialization>::<name>` key, with the typespec
requalified to the specializing package** — and the class arm then inherits
them for free, because it reads the very same set.

## Also still open

* `var 34` — pre-existing OWN-property gaps, not import-related (SeqDriver's
  `adpcm_driver` is missing its own `logic_var 'ADPCM'`; the imported 33 are
  exact in all five classes).
* `tf 2` — BuildUVMPkg's pre-existing pair, unchanged by this pass.
* the `t33d` extern-prototype listing entry described above.
