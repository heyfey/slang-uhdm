# r11u108 — head cluster B + cluster C's R0: package-typedef typespec faces and the type-parameter variable kind

Base `c4adbb58`. The pins are the ones in `SUPPORT_MATRIX.md`: slang `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 `0445655ee7`, uhdm2rtlil v0.68.

The production change is `src/TypeEmit.cpp` only. Nothing else was edited: not
`src/UhdmExporter.cpp`, not the header, not the four fenced files
(`ModuleEmit.cpp`, `ExprEmit.cpp`, `EmitHelpers.h`, `ParamEmit.cpp`), and not
`results/*.csv`.

| binary | md5 |
|---|---|
| pristine (this worktree, `-j 2`) | `b4f28467e6ce11fc70a1d0b66221cc69` (the OPS pin) |
| law | `81f13e490e460366e81cf289d01d853d`. A fresh `c4adbb58` tree plus the production diff rebuilds to the same md5. |

## Outcome

| row (both modes; the counts are the same in each mode) | base: lines/heads | law: lines/heads | next head |
|---|---|---|---|
| uhdm2rtlil `type_param_packed_dim` | 60/1 | **0/0: CONVERTS** | none |
| uhdm2rtlil `type_param_override_elem_sel` | 60/1 | 47/1 | the override `logic [1:0]` (32:17) under the elaborated port `u.rt_i`'s `packed_array_typespec` Elem. RHS `<null>` |
| uhdm2rtlil `stamped_gen_param` | 138/1 | 17/1 | ref `(q2::q2::row_t)`, the Elem of the `q2::row_t` object. RHS `<null>`, because our DEF-listing object has no Elem |
| uhdm2rtlil `cfg_func_width_loop` | 148/1 | 148/1 (unmoved, fenced) | the same |
| uhdm2rtlil `const_cast_signext` | 17/1 | 17/1 (unmoved, fenced) | the same |
| surelog `LargeValue2Struct` | 108/1 | 108/1 (unmoved, fenced) | the same |

**CONVERSION.** The committed rows are:

```
type_param_packed_dim,default,CMP_NOTEQUAL,decompile:,,
type_param_packed_dim,testflags,CMP_NOTEQUAL,decompile:,,
```

The law sweep reads:

```
type_param_packed_dim,default,CMP_EQUAL,,,differ
type_param_packed_dim,testflags,CMP_EQUAL,,,differ
```

`results/*.csv` is untouched. The master promotes the rows.

## Q1: the six heads at c4adbb58 (official `uhdm-cmp`, LHS = golden, one head per run)

Full text: `evidence/HEADS.txt`.

* **cfg_func_width_loop, 148/1.**
  * LHS: `logic_typespec (q::mask_t)` at 16:11. Parent: ref `work@cfg_func_width_loop.u.M`. vpiInstance: package `q`. Range `[0:2]` (left `UINT:0`, right `INT:2`). No Typedef_alias.
  * RHS: `logic_typespec (mask_t)` with a vpiTypedefAlias ref `work@cfg_func_width_loop.u.M.mask_t` whose actual is `q::mask_t`.
* **stamped_gen_param, 138/1.**
  * LHS: `logic_typespec (q2::row_t)`. It has no location, is parented at the package, has vpiInstance `q2`, an Elem ref `(q2::q2::row_t)` pointing at an unnamed `logic_typespec` at 11:11, and range `[0:2]`.
  * RHS: an unnamed `logic_typespec` at the member span 14:5. It is parented at `typespec_member UnitTypes`, has an Elem ref `(q2::q2::impl_t::UnitTypes)` pointing at a copy named `row_t`, and range `[0:1]`.
* **const_cast_signext, 17/1.**
  * LHS: `ref_typespec (imm_t)`. Its parent is a `logic_typespec (imm_t)` copy at 14:11, and its actual is the typedef's own `logic_typespec (imm_t)`.
  * RHS: `<null>`.
* **type_param_override_elem_sel and type_param_packed_dim, 60/1 each.**
  * LHS: `packed_array_var (work@dut[.u].rt_i)` whose typespec ref points at the `packed_array_typespec` (5:31 or 17:31).
  * RHS: `logic_var` with the same name and the same ref.
* **LargeValue2Struct, 108/1.**
  * LHS: `logic_typespec (sram_key_t)` at 4:11. Parent: ref `work@top.pack::scrmbl_key_init_t.key.sram_key_t`. vpiInstance: `pack`. Range `[127:0]`.
  * RHS: `logic_typespec (pack::sram_key_t)` with no parent.

## Q2: decode per face, and the site of our emission

The sites were found by `gdbfind108.sh` on a Release+`-g` decode build whose output is byte-identical to pristine. Backtraces: `evidence/SITES.txt`.

### FACE 5: § tpPackedArrayTsVar108 (LANDED; TypeEmit.cpp `emitTypeParamArrayVar`)

**Surelog.** `ElaborationStep::makeVar_` walks the dtypes. For a type parameter, the `Parameter` arm (ElaborationStep.cpp:1943-1958) hands the elaborated typespec to `CompileHelper::getSimpleVarFromTypespec` (CompileType.cpp:78-240). That function has no `uhdmpacked_array_typespec` case, so it returns null. The `found == false && tps` dispatch (ElaborationStep.cpp:1964-2024) then mints a bare `packed_array_var` (:2018) and attaches only the typespec ref (:2031-2038).

The dispatch reads the **typespec kind**, so:

* 2-state elements take the same arm (grid f5a06, f5a16).
* So do enum and struct elements (f5a07, f5a08).
* Written dims on such a parameter are **dropped** (f5a10, f5a21, f5a24): the variable is still a typespec-only `packed_array_var`.

**Our site.** The factory is in our ground (TypeEmit.cpp). It gained two halves:

* **The dimensionless cell** (`rt_t x`). The declared type is the type-parameter alias, and `typeParamElabTs` is a `packed_array_typespec`. The factory returns a typespec-only `packed_array_var` sharing that object. That is the same object the pristine `logic_var` pointed at.
* **The written-dims cell.** The existing ranged road now returns early, with no ranges and no elements, when the parameter's typespec is a `packed_array_typespec`.

The fenced call site ModuleEmit.cpp:11985 is unchanged. It already reaches the factory.

**Gates.** These cases are refused:

* An initialised declaration in the dimensionless cell (f5a18). The caller `continue`s past the initializer emission, so firing would drop golden's vpiExpr.
* An explicit `wire` declaration (f5a13). The pinned Surelog segfaults on it, so there is no golden.

### FACE 2: § defPkgMemberTdOfNamedShares108 (LANDED; TypeEmit.cpp `buildStructTs` and `bareScalarTypedefVarTs`)

**Golden.** Take a struct member written `T [d] m`, in the DEF package listing (`design->AllPackages`), where T is a package typedef **of a named type** (`typedef ut_e [0:2] row_t;`).

* **DEF listing.** The member binds T's shared listing object `pkg::T` directly. The member's own `[d]` is dropped.
* **TOP listing.** The member keeps a member-span `logic_typespec`, whose Elem is that same object.
* **Module parameter.** The module's own parameter typed `q2::row_t` binds the same object.

This is measured on grid pk k13 and on f2 m02, m04, m08 and m09. `who108` shows the golden object's users.

**Surelog.** A typedef of a named type is filed as `TypeDef` + `DummyType`. Its typespec is built at package compile (CompileHelper.cpp:890-1043, `newTypeDef->setTypespec`). `compileDatastructureTypespec`'s `TypeDef` arm (CompileType.cpp:852-858) returns that object. The TOP listing's wrapper is CompileType.cpp:1934-1946: a logic_typespec whose Elem is the SAME object. **Not decoded:** why the DEF pass applies no wrapper. The grid is the authority for that.

**Our site.** `buildStructTs` in TypeEmit.cpp built the member-span road (`vtaMem`). The law binds `pkg::T`, taking one alias hop off the share map's bare clone. LAW S (`bareScalarTypedefVarTs`, TypeEmit.cpp) would then rewrite the member to an aliased bare copy, so it now skips the members this law bound. The skip set is file-static (TypeEmit.cpp:11859), so the shared header stays untouched.

**Gates:**

* DEF listing only: `inPkgTypedefEmit && !pkgTopEmit`.
* The typedef's written type is a `NamedType`.
* The typedef's home is a package.
* The canonical leaf is a four-state scalar. Enum and 2-state leaves are refused (f2 m03, m07): golden's object there is a `packed_array_typespec`, and ours is a `logic_typespec`.
* The bound object is named `pkg::T`.

**Residue (next head).** Our DEF-listing `pkg::T` object carries no Elem and no Ranges. The TOP twin has both. Golden has an Elem pointing at an unnamed clone of the compiled `ut_e [0:2]`. That object is built by the package listing emission (ParamEmit.cpp `emitPackage` from :27999, fenced).

Other residues:

* Golden's DEF listing omits typedefs of this kind from `vpiTypedef` (k05, k12). That is the same fenced loop.
* Our TOP member-span Elem points at a bare alias clone instead of the shared object (the `vtaMem` rebind, TypeEmit.cpp).
* Our module-side parameter struct clone binds a bare clone where golden binds `p::a_t` (k12 MOD view).

### FACE 1: STOPPED AT THE DECODE (site fenced)

**Golden.** A parameter typed by a package typedef (`parameter q::mask_t M`, overridden or default, qualified or imported) is a clone of the **package listing object**. It is named `q::mask_t`, has vpiInstance = the package, has no Typedef_alias, has folded bounds, and is parented at the parameter's ref. See grid pk k01-k03, k17, k20-k22 and the corpus row.

**Our site.** `makeParamTs`, ParamEmit.cpp:24815-24872 (fenced). It mints `cl` named bare `taSym.name`, with a Typedef_alias ref → the listing object (`cl->VpiName(taSym.name)`, `Typedef_alias(art)`).

**Naming rule across homes (FACE 1 vs FACE 3):**

* A PARAMETER's own typespec is a clone of the package listing object, named `pkg::T`, with no alias.
* A struct MEMBER is compiled in the package through the typedef's own typespec. That typespec is a bare-named clone with an alias → `pkg::T`: CompileHelper.cpp:1017-1043 builds `tpclone->VpiName(name)` with `Typedef_alias → ts`, and the listing lists `ts`.
* Cloning the struct copies that bare member clone.

So the name is inherited from **which object is cloned**. It is not a uniform `pkg::` rule.

Ports and variables (k07, k08) and imported ≤64-bit struct parameters (k09, k10, k10b-k10i) are already equal.

### FACE 3: STOPPED AT THE DECODE (site fenced)

**Golden.** A param_assign whose RHS names a package struct parameter carries a struct clone. That clone's member binds a bare `T` copy parented at its alias ref. This holds for a qualified RHS at any width (k11, k10e). For an imported RHS it holds only when the value is **wider than 64 bits** (k10j, k10l, LargeValue2Struct). k10k is 64 bits wide and already equal.

**Our site.** The clone is built by `buildStructTs`, TypeEmit.cpp:13318-13329. The § paramCloneImportedCopy arm already mints exactly that bare copy. But the context flag has to be raised by the fenced caller `pkgHomedYTs`, ParamEmit.cpp:20524-20537. It calls `makeParamTs` for the RHS param, and without the flag the member binds the pkg-named fold twin. No TypeEmit-local predicate identifies that call, so the law needs the fenced file.

### FACE 4: STOPPED AT THE DECODE (sites fenced)

**Golden.** Each use of a module-local SIMPLE typedef (`logic`/`bit`/`int`) inside a module function or task mints a fresh self-named clone with a Typedef_alias → the typedef. This covers a cast `T'(x)`: grid f4 c01, c03, c06, c07, c08, c09, c11, c12. Module-scope and `always` casts are already equal (c04, c05), and a struct-typedef cast shares the typedef (c10, equal).

**Surelog.** A module typedef has no typespec at compile ("except for packages and FileContent", CompileHelper.cpp:899), so `compileDatastructureTypespec` falls to the `SimpleType` arm. That arm is `clone_tree` + `Typedef_alias → result`, at CompileType.cpp:882-895.

**Our sites.**

* **(a) The cast.** ExprEmit.cpp:21658-21660. The gate is `!currentSubSym || homePkgSub0 || $unit`. It is missing the module-function case, so the cast shares `typedefTs[imm_t]`. The cast ref is minted at ExprEmit.cpp:22634.
* **(b) The function-name ref_obj's return var** (grid f4 c02, head ref `work@dut.f.f.imm_t`). `drainFuncRet`, ModuleEmit.cpp:36573. It binds the typedef itself, where golden has a clone with an alias → a typedef clone.

Both sites are fenced, and `const_cast_signext` needs both.

## Q3: grids (`evidence/GRIDS.txt`; golden-vs-golden calibration 82 arms, 0 nonzero)

* **`grid/f5`, 24 arms.** Type-parameter-typed declarations × written dims × element kind × position × override, plus controls.
* **`grid/pk`, 37 arms.** Package typedefs × homes (parameter, port, variable, struct member, function, cast) × ranged/rangeless × nested chains × same/cross package, plus the LargeValue2Struct bisection (k10-k10l, k23*).
* **`grid/f2`, 10 arms.** Face-2 gates and controls.
* **`grid/f4`, 12 arms.** Cast and return homes.

## Q4: laws, each droppable alone

* `R11U108_TPPAV_OFF=1` drops law 1. `R11U108_PKGTDMEM_OFF=1` drops law 2. `R11U108_OFF=1` drops both.
* `sw108.sh` over 185 arms (the four grids, `r11u107repro/grid`, `v11u93b107repro/brk`):
  * `R11U108_OFF=1` is byte-identical to pristine on 185/185.
  * Each single switch restores exactly its own law's arms: 42 arms for law 1, 6 for law 2.

## Q5: census and prediction (`evidence/CENSUS.txt`, `evidence/PREDICT.txt`)

`cen108` and `cenm108` were run on every row's golden database first, then on ours. `PREDICT.txt` was written before the law sweep finished. Predicted movers:

* **Law 1:** `type_param_packed_dim` and `type_param_override_elem_sel`, both modes. Surelog: 0.
* **Law 2:** `stamped_gen_param`, both modes. Surelog: 0.

The census's golden-only surelog cells all sit in SLANG_REJECT rows (ArianeElab2, Ariane2024).

## Q6: gates (`evidence/GATES.txt`)

* **Goldens:** 23/0, and the `/bin/false` control gives 0/23.
* **uhdm2rtlil:** the only row change is the conversion above.
* **byteverify, uhdm2rtlil:** 6/1608 movers, exactly as predicted.
* **Surelog:** statuses unchanged.
* **byteverify, surelog:** 5/960 movers, all UVM rows (MiniAmiq, SeqDriver, SimpleUVM). Each is the documented 4-line `UINT`/`vpiDecompile` order class, and all stay CMP_EQUAL.
* **Canary battery:** green. The protected databases (SVSwitch, YosysVerx, InterfaceModPort, BlackParrotComplex, YosysOldOr, Earlgrey_0_1) are byte-identical in both modes.
* **Wide boundary** (`evidence/BOUNDARY.txt`), 8832 committed probe sources: 38 movers, all deterministic.
  * 35 arms carry law-1 cells: 55 cells TO-GOLDEN, AWAY 0. They include the pass-105 grids' o01-o09 and t05, and the verifier's q/r arms.
  * The other 3 arms (g22, l154_noenum, g185_e_kinds) move only the layout-derived tail constant. `layoutproof154.sh` gives `LAYOUTPROOF OK`, and their cmp counts are unchanged.
* **Per-cell scoring, by name:**
  * Law 1 (`cell108.py`): every moved cell is TO-GOLDEN.
  * Law 2 (`cellm108.py`): every moved member's BINDING is TO-GOLDEN (two f2 arms fully). The Elem inside the bound object is the named residue above.

## Residues, ranked (R0 first)

* **R0:** `stamped_gen_param` 17/1. The DEF-listing `pkg::T` object of a typedef-of-a-named-type has no Elem and no Ranges (package listing emission, ParamEmit.cpp:27999 onward, fenced).
* **R1:** `type_param_override_elem_sel` 47/1. The elaborated port `u.rt_i` points at the definition's original `packed_array_typespec` (Elem → the default `logic`) instead of the instance's rebound one. This is the "ports keep the original" edge of § tpElemRebindDefView107.
* **R2 (fenced):**
  * FACE 1 at ParamEmit.cpp:24815-24872.
  * FACE 3 at ParamEmit.cpp:20524-20537.
  * FACE 4 at ExprEmit.cpp:21658 and ModuleEmit.cpp:36573.
* **R3 (grid only):**
  * f5a11: an unpacked array of a packed-array-typed parameter. The element should be a typespec-only `packed_array_var`.
  * f5a18 and f5a22: the initialised cells.

## Tools

| tool | what it does |
|---|---|
| `grid108.sh` | Runs the golden and our binaries per arm, records rc, and runs cmp. |
| `headsum108.sh` | Head summary. |
| `who108.cpp` | Lists which refs point at each typespec, with vpiInstance, alias and path. |
| `gdbfind108.sh` | Site locator. |
| `cen108.cpp` / `cenrun108.sh` | Law-1 census. |
| `cenm108.cpp` / `cenmrun108.sh` | Law-2 census. |
| `cell108.py` / `cellm108.py` | Per-cell scorers. |
| `bnd108.sh` / `mov108.sh` | Wide boundary and mover scoring. |
| `sw108.sh` | Switch check. |
