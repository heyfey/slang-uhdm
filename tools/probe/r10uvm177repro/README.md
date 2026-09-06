# r10uvm177 — § `ownNamedAliasRetIsRefVar177` — **A RETURN TYPE WRITTEN AS A BARE NAME THAT RESOLVES TO A TYPEDEF *OF A NAMED TYPE* DECLARED IN THE VERY COMPONENT COMPILING THE LISTING IS A BARE `ref_var`** — the SimpleUVM ×2 52-line head **CLEARED**, and the same one cell converges in **all nine UVM databases**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW WAS CONVERTED**. `GOLDEN_DEFER` was never set.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `0ae0ad69` |
| worktree | `/tmp/wt_r10uvm177` |
| pristine binary | md5 `a70f55847d13f3bb67224e7c5049ba18`, built from a clean `0ae0ad69` worktree and frozen `chmod 555` before any sweep |
| patched binary | md5 `447ba723ecfb17bbd37505068bce7ce0`, frozen `chmod 555` before any sweep |
| production surface | `src/EmitHelpers.h` (one new predicate) + `src/TaskFuncEmit.cpp` (one gated re-kind at the existing return-variable site) |
| probe surface | `tools/probe/r10uvm177repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **52** | **29** | 1 — a **NEW head**, a different object (§8) |
| SeqDriver default / testflags | 33 | 33 | 1 unchanged, head log **byte-identical** |
| Scoreboard default | 95 | 95 | 1 unchanged, head log **byte-identical** |
| MiniAmiq default / testflags | 29 | 29 | 1 unchanged, head log **byte-identical** |
| BuildUVMPkg default / testflags | 52 | 52 | 1 unchanged, head log **byte-identical** |
| Earlgrey_0_1 default / testflags | 31 / 122 | 31 / 122 | 1 unchanged, head log **byte-identical** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |

Gates, all green (`GATES.r10uvm177.txt`): goldens 23 PASS / 0 FAIL on both
binaries and the `/bin/false` negative control 0 PASS / 23 FAIL; uhdm2rtlil
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL in **both** modes with
`ct8rows` **0 differing rows** against the committed baseline *and* against this
pass's own pristine control, status column and dump column; the surelog corpus
**0 differing rows over 1588**; byteverify `SELFCHECK=1` **9 / 956** and
**0 / 1358** movers, **every one predicted BY NAME from pristine databases
before the patched sweep ran**; canaries `ok=52 changed=0` and `ok=8 changed=0`;
`ctcan2` PASS on both corpora; `canaudit` `UNCOVERED=0 FENCE-BREACH=0`; the five
protected databases byte-identical, `SVSwitch` pin `4842211c4030` and
`YosysVerx` pin `6ccda350c24a` both held.

---

## 1. THE HEAD, DECODED — the judge, the edge, both field vectors, the target's identity

`HEAD.r10uvm177.txt` holds the full transcript. The official head on SimpleUVM,
both modes, one `^LHS:` line, 52 cmp lines, at `0ae0ad69`:

```
LHS  ref_var:  (uvm_pkg::uvm_sequencer_base::get_arbitration) @1389:10-1389:26
       |vpiParent  \_function: (uvm_pkg::uvm_sequencer_base::get_arbitration) @1389:1-1391:12
       |vpiTypespec \_ref_typespec -> enum_typespec: (uvm_pkg::UVM_SEQ_ARB_TYPE) @332:40-332:56
RHS  enum_var: (uvm_pkg::uvm_sequencer_base::get_arbitration) @1389:10-1389:26
       |vpiTypespec \_ref_typespec -> enum_typespec: (uvm_pkg::UVM_SEQ_ARB_TYPE) @359:1-367:26
```

Both sides print in full, so this is `BaseClass::Compare`'s FIRST test — a
`VpiType` mismatch — and neither `SafeCompare` overload of RESUME §9 applies:
`m_failedLhs` and `m_failedRhs` are BOTH set, so the head names no null and no
container.

**THE EDGE.** `ct177own.cpp` (the owner-finder, descended from
`r10uvm164repro/ct164own.cpp` and `r10uvm174repro/ct174own.cpp`) walks BOTH
databases for every `function` at line 1389 and prints each one's parent chain
and Return. There are **four** functions at that line per database, and they
divide as:

| the copy | golden | ours (pristine) |
|---|---|---|
| `function(get_arbitration)` under `class_defn:uvm_sequencer_base` | `enum_var` #25313 | `enum_var` ✓ |
| `function(uvm_sequencer_base::get_arbitration)` under **`package:uvm_pkg` directly** | **`ref_var`** #84392 | `enum_var` ✗ |
| `function(add_hdl_path_slice)` (uvm_reg, same line, `void`) | no Return | no Return ✓ |

So the head is the **PACKAGE DEF LISTING's out-of-body `C::m` clone**, the very
listing r10uvm174 decoded — and the class-listing copy of the SAME source line
is an `enum_var` on BOTH sides. One source construct, two answers, and they
differ only in the package copy.

**BOTH FIELD VECTORS.** Neither object carries a `VpiName` (the parenthesised
text the dump prints is `vpiFullName`, SYNTHESIZED from the parent chain —
RESUME §9). Both carry a `ref_typespec` whose actual is an `enum_typespec`
named `uvm_pkg::UVM_SEQ_ARB_TYPE`. `variables::Compare` reads `VpiSigned`; both
are 0. **The var CLASS is the whole judged difference** — which is why a bare
re-kind clears the head, and `ct177own`'s step 4 confirms it: the two typespec
targets' generated `Compare` fails on the *variables* (`m_failedLhs =
ref_var #84392`, `m_failedRhs = enum_var #146063`), never on a typespec field.

**THE TARGET'S IDENTITY — shared with which references.** `ct177own` scans every
`ref_typespec` in each database for one resolving to the target. Golden's
`enum_typespec` #2305 has **six** referents, three (io_decl, return var) pairs,
one per listing:

```
io_decl(val)@1381:68  + enum_var@1389:10   <- the class body listing
io_decl(val)@1381:68  + ref_var @1389:10   <- the PACKAGE DEF listing's C::m clone
io_decl(val)@332:57   + enum_var@340:19    <- the class's `extern` PROTOTYPE
```

Ours has six too, the same shape but with `enum_var` in all three. The target's
SPAN differs (`332:40-332:56`, the `UVM_SEQ_ARB_TYPE` token in
`set_arbitration`'s formal, against our `359:1-367:26`, the `enum { … }` body of
`uvm_sequencer_arb_mode`) — but the NAMES are equal and `uhdm-cmp` reads no
span, so the span is **dump-only** and stays a residue (R2).

---

## 2. THE LAW, AND SURELOG'S RETURN-VARIABLE FACTORY

> **`CompileHelper::compileVariable`'s named-type arm turns a typespec into a
> kind-specific variable. A typedef whose OWN WRITTEN BASE IS A NAMED TYPE has
> NO typespec while the component that declares it is being compiled — it is
> `ElaborationStep::bindTypedefs_` that gives it one, and that runs afterwards —
> so the lookup finds nothing, `getSimpleVarFromTypespec` is never called, and
> the return variable falls through to the bare `ref_var` at the bottom of the
> same switch.**

Read off Surelog, line by line
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp`):

```c++
// :337-345   the named-type arm
if (const DataType* dt = component->getDataType(typeName)) {
  dt = dt->getActual();
  if (typespec* tps = dt->getTypespec())
    if (variables* var = getSimpleVarFromTypespec(tps, ranges, compileDesign)) {
      …                                     // enum_var / struct_var / int_var …
// :421-434   the fallthrough, when nothing above produced a `result`
ref_var* ref = s.MakeRef_var();
if (ts) { … ref->Typespec(tsRef); }         // ts comes from compileTypespec
ref->VpiName(typeName);
```

`getSimpleVarFromTypespec` (`CompileType.cpp:78-248`) is the whole kind table:
`uhdmenum_typespec → MakeEnum_var`, `uhdmstruct_typespec → MakeStruct_var`,
`uhdmint_typespec → MakeInt_var`, and so on. `CompileStmt.cpp:2403-2410` is what
attaches the object to the function and then does `var->VpiName("")` — which is
why golden's `ref_var` is NAMELESS even though the factory named it.

The typespec is missing because of `ElaborationStep::bindTypedefs_`
(`src/DesignCompile/ElaborationStep.cpp:267-285`): its `prevDef == nullptr` arm
is the one that calls `bindTypeDef_` / `setDefinition` / `compileTypespec` for a
typedef whose base is a NAME, and elaboration runs after every component's
compile. A typedef with an inline or keyword base (`typedef enum {…} e;`,
`typedef logic [7:0] v;`) is typespec'd by the component compile itself. A
typedef reached through an import, through `$unit`, or through a `pkg::` scope
belongs to a component that was compiled and bound earlier.

**THE FOUR TERMS, and the golden column that fixes each.**

| # | term | measured against |
|---|---|---|
| 1 | the return type is a TYPEDEF | `f_enum_d` vs `f_enum_v` (arm B) |
| 2 | it is written as a **BARE NAME** — a `pkg::T` spelling takes `compileVariable`'s `paClass_scope` arm and always resolves | `h_scopedvia` / `h_scopeddir` / `h_scopedint` golden `enum_var`/`int_var` (arm C) |
| 3 | the typedef's own **written base is a NAMED TYPE** | `bq_*`-style inline/keyword bases stay resolved: `f_byte_d`, `f_int_d`, `f_vec_d`, `f_struct_d`, `f_union_d`, `f_enum_d` (arm B), `k_moddirect`, `h_direct` (arm C) |
| 4 | the typedef is declared **in the component compiling this listing** | `d_farvia`, `k_impvia` (imported), `k_unitvia`, `unit_fn` (`$unit`), `cv_inherited`, `cv_inh_direct` (a BASE class's alias) — all golden's resolved kind (arms C, D) |

**THE LISTING AXIS** — the same source line answers differently per listing, and
the grid columns say exactly where:

| home of the function | listing | golden |
|---|---|---|
| package free function | `PKGDEF:` | **`ref_var`** (`free_alias`, `free_alias3`, `h_localvia`, `h_impvia`, `h_farvia`) |
| package free function | `PKGELAB:` | `enum_var` — the elaborated package listing is a SECOND compile, run after the bind |
| out-of-body `C::m` clone | `PKGDEF:` | **`ref_var`** (`Kls177::x_oob_alias`, `z_oob_alias3`, `p_oob_alias2`) — **THE HEAD** |
| the same method's class-body copy | class listing | `enum_var` (`x_oob_alias` @34:12 under `PKGELAB:zpk177 CLASSBODY:Kls177`) |
| module function | `MODDEF:` **and** `MODELAB:` | **`ref_var`** (`k_modvia` in both) |
| class in-body method, class's OWN alias | every class listing | **`ref_var`** (`d_ib_clsalias`, `cv_own`, `pv_own`) |

**THE WILDCARD-IMPORT CLONE IS NOT THE PACKAGE'S OWN.** An importing package
carries a clone of the imported package's `C::m`; the component compiling THAT
clone is the IMPORTER, which runs after the home package's typedefs are bound.
Measured, and it cost a build: the first patched binary moved
`PKGDEF:adpcm_pkg` (SeqDriver) and `PKGDEF:svaunit_pkg` (MiniAmiq) — plus their
`PKGELAB:` twins — AWAY from golden, four cells whose golden Return is an
`enum_var`. The gate is `pkgClassTfClone != nullptr && !pkgImportCloneEmit`.

---

## 3. WHAT WE DO INSTEAD, AND THE ONE LINE THAT CHANGES

`src/TaskFuncEmit.cpp`'s ordinary return-variable site already runs two laws in
order — § `classTdLocalVarKindFollowsCompileOrder10` (site 3 of 5) and
§ `namedBaseUnpackedTdRetVar22` — and only then calls `makeReturnVar`, whose
kind table (`src/EmitHelpers.h`) mirrors `getSimpleVarFromTypespec`. This pass
adds ONE gated re-kind AFTER both, so neither of those laws' cells can move by
construction:

```c++
if (!crossImplicitRet && !lateRv10 &&
    ownNamedAliasRetIsRefVar177(sub, sub.getReturnType(),
                                curPkgEmitSym && !pkgEmitTopView,
                                pkgClassTfClone != nullptr && !pkgImportCloneEmit))
    lateRv10 = s.MakeRef_var();
```

The predicate itself is `ownNamedAliasRetIsRefVar177` in `src/EmitHelpers.h`,
carrying the law, the four terms, the listing axis and the cells that must not
move. It is a pure re-kind: no typespec, name, span, parent or signedness is
touched.

---

## 4. THE CENSUS — nine UVM databases × both modes

`ct177cen.cpp` emits ONE ROW PER FUNCTION RETURN POSITION, keyed
`(listing, home, function name, line:col)` with value
`(var kind, typespec kind, typespec name)`; the typespec SPAN is printed but
kept out of the verdict because `uhdm-cmp` reads no span. The listing is read
STRUCTURALLY (`AllPackages` / `TopPackages` / `AllModules` / `TopModules` /
`AllClasses`) so both producers answer it identically, and `join177.py` is a
MULTISET join (RESUME §9: keys collide; a last-writer dict drops rows).

**Golden-vs-golden calibration first.** Golden's own answer, per database, for
every return whose typespec is an `enum_typespec`, split by whether the
function's name carries `::` (Surelog's spelling for the DEF listing's
out-of-body clone):

| database | BARENAME `enum_var` | OOBNAME `enum_var` | **`ref_var`** |
|---|---|---|---|
| SimpleUVM | 42 | 7 | **1** |
| SeqDriver | 42 | 23 | **1** |
| Scoreboard | 44 | 8 | **1** |
| MiniAmiq | 50 | 23 | **1** |
| BuildUVMPkg | 55 (+3 `class_var`) | 11 (+2 `class_var`) | **1** (+1 in a class body) |

Exactly ONE `ref_var` per database, and it is the same row every time:

```
PKGDEF:uvm_pkg  PKGLIST:-|OOBNAME  uvm_sequencer_base::get_arbitration
   1389:10  ref_var  enum_typespec  uvm_pkg::UVM_SEQ_ARB_TYPE
```

`UVM_SEQ_ARB_TYPE` is uvm-1.2 `uvm_object_globals.svh:370`,
`typedef uvm_sequencer_arb_mode UVM_SEQ_ARB_TYPE;` — the ONLY alias-of-a-typedef
among the enum types UVM returns out of body. Every other one
(`uvm_status_e`, `uvm_phase_type`, `uvm_phase_state`, `uvm_path_e`,
`uvm_check_e`, `uvm_endianness_e`) is a direct `typedef enum {…} name;` and
golden answers it `enum_var`, as do we.

**Golden-vs-ours, pristine then patched** (`CENSUS.r10uvm177.txt`):

| database / mode | AGREE pristine | AGREE patched |
|---|---|---|
| SimpleUVM default / testflags | 1950 | **1951** |
| SeqDriver default / testflags | 2754 | **2755** |
| Scoreboard default | 1971 | **1972** |
| MiniAmiq default / testflags | 2888 | **2889** |
| BuildUVMPkg default / testflags | 2258 | **2259** |

**+1 in every one of the nine, −1 DIFF, and no other cell moves.** Both one-sided
sets (G-ONLY / O-ONLY) are unchanged in size and content; they are a
pre-existing key-alignment residue of listings whose function names differ
between producers, not a verdict.

---

## 5. THE GRIDS — declared kinds × listings × homes × DEF/ELAB

`GRID.r10uvm177.txt` has the full cell tables. `grid177.sh` builds golden
(Surelog) and BOTH binaries in BOTH views, echoing every command with its
binary PATH and every rc into the arm's `cmds.txt`, and runs the official
`uhdm-cmp` per view per binary. `score177.py`'s **MOVED-WRONG** column counts
cells that AGREED with golden and stopped agreeing.

| arm | what it varies | def view | elab view |
|---|---|---|---|
| `g177_a_alias.sv` | direct enum td / alias / alias-of-alias / class-scope td, × in-body, out-of-body, package free, module | A_ok 23 → **B_ok 29**, FIXED 6, **MOVED-WRONG 0** | 35 → **41**, FIXED 6, **MOVED-WRONG 0** |
| `g177_b_kinds.sv` | enum, struct, union, int, byte, real, string, vector, unpacked array, class handle — direct td vs alias, in a package | 26 → **31**, FIXED 5, **MOVED-WRONG 0** | 37 → **42**, FIXED 5, **MOVED-WRONG 0** |
| `g177_c_homes.sv` | where the ALIAS lives (own pkg, foreign pkg, `$unit`, imported, `pkg::`-scoped) × where the FUNCTION lives (package, module) | 23 → **27**, FIXED 4, **MOVED-WRONG 0** | 33 → **38**, FIXED 5, **MOVED-WRONG 0** |
| `g177_d_bounds.sv` | inherited class alias, `$unit` function, `parameter type` alias, alias of an imported td, named base WITH dimensions, class handle td | 15 → **18**, FIXED 3, **MOVED-WRONG 0** | 15 → **17**, FIXED 2, **MOVED-WRONG 0** |

Arm A's `def`-view head was itself this law's cell —
`ref_var (zpk177::Kls177::x_oob_alias)` against our `enum_var` — and it CLEARS;
the arm's head then moves to an unrelated, pre-existing package `vpiTypedef`
difference whose decompile is much larger, which is why its cmp line count goes
52 → 2302 (RESUME §7: a count that rises on a head object that CHANGED is the
expected shape).

**MOVED-STILL-WRONG** in arms B and D is 4 and 2–3: cells where the KIND became
golden's `ref_var` while the typespec NAME stays unqualified on our side
(`ByteVia` against golden's `bpk177::ByteVia`). That naming difference is
pre-existing on both binaries and is residue R1; nothing there moved away.

Two grid spellings are **slang-unreachable** and are marked in the files rather
than dropped: `function UnitVia h_unitvia();` inside a package (slang: *cannot
reference compilation unit item from within a package*; Surelog accepts it and
answers `enum_var`), and an unqualified class-scope typedef as an out-of-body
return type (slang demands `Kls177::`). The reachable half of each question is
kept — `k_unitvia` in a module, `Kls177::wcls_alias` scoped.

---

## 6. THE BOUNDARY — the whole probe tree, and the verdict on every arm it moved

`BOUNDARY.r10uvm177.txt`. `bound177.sh` runs over a COPY of the entire
`tools/probe` tree, top level AND subdirectories, both views, both binaries,
children `</dev/null`, the file list on fd 3, PROCESSED asserted against LISTED,
scratch keyed on the RELATIVE path:

```
LISTED=4872 PROCESSED=4872 PRODUCED_DBS=4714 MOVED_ARMS=21 RC_DIFFS=0
```

This pass's own four `g177_*.sv` are the POSITIVE CONTROL: a gate reporting zero
movers over them could not see. `armjudge177.sh` then rebuilds each of the 21
moved arms with `grid177.sh` — golden + pristine + patched, both views — because
the boundary gate can say the bytes moved but not whether they moved TOWARD
golden:

```
ARMS-JUDGED=21  ARMS-WITH-MOVED-WRONG=0
```

The 17 arms that are not this pass's own belong to exactly the families the law
touches — `r10buvm22repro` (§22's own grid, whose g22b.sv explicitly carries the
"no-dimension arm" §22 left as ITS residue), `r10uvm140repro` / `r10v140repro`
(§ `retNamedTdWinsOverCanon140`), `r10uvm58repro/w4_aliasret.sv`,
`r10uvm91repro/v91_a3_order.sv`, `r10vbuvm20repro` (including `v9_tdoftd.sv`,
literally a typedef-of-typedef arm) and `r10vbuvm22repro`. In every one, every
changed cell took golden's `ref_var`; the residual disagreement where one
remains is the same unqualified-typespec-name residue R1.

`armjudge177.sh` carries its own SELFCHECK: the first cut of it piped the
MOVED-WRONG sum through `bc`, which is not installed on this machine, so the
counter silently stayed 0 and the gate could not have convicted. The shipped
form sums with `awk` and additionally asserts that each arm scored a nonzero
number of POSITIONS.

---

## 7. THE MOVERS — predicted by name first, then attributed order-blind

`ct177pred.cpp` + `predsweep177.sh` ran over the **pristine** databases BEFORE
the patched sweep. A candidate is a return variable that is not already a
`ref_var`, whose typespec carries a non-null `Typedef_alias` (the UHDM marker
that the typedef's written base was a NAMED type), in a listing the law can fire
in, with a typespec name scoped to that listing's own component. It is a
deliberate SUPERSET of the emitter gate.

* surelog, 956 databases scanned: **19** hold a candidate, **9** hold the law's
  cell — `BuildUVMPkg`, `MiniAmiq`, `Scoreboard`, `SeqDriver`, `SimpleUVM` in
  `default` and the same four minus Scoreboard in `testflags`.
* uhdm2rtlil, 1358 databases scanned: **8** hold a candidate, **none** hold the
  law's cell — every candidate typedef there has a KEYWORD base
  (`typedef logic [31:0] word;`, `typedef int unsigned ASSIGN_VADDR_RET_T[CNT];`,
  `typedef logic [1:0] T;`), and `Earlgrey_0_1`'s 5/26 candidates are
  `prim_keccak`'s `typedef logic [4:0][4:0][W-1:0] box_t;` and `sha_word_t`,
  keyword-based likewise.
* **PREDICTED: 9 surelog movers, 0 uhdm2rtlil movers. OBSERVED: exactly that.**

`attrib177.sh` then attributed each mover ORDER-BLIND (`uhdm-dump` both sides,
normalise the workdir and object ids out, SORT both, diff the sorted forms),
because RESUME §9 forbids attributing Scoreboard/default any other way:

```
default/BuildUVMPkg     raw=4    order-blind=4
default/MiniAmiq        raw=4    order-blind=4
default/Scoreboard      raw=82   order-blind=4     <- the COIN, and only the coin
default/SeqDriver       raw=44   order-blind=4
default/SimpleUVM       raw=4    order-blind=4
testflags/BuildUVMPkg   raw=4    order-blind=4
testflags/MiniAmiq      raw=4    order-blind=4
testflags/SeqDriver     raw=4    order-blind=4
testflags/SimpleUVM     raw=4    order-blind=4
```

and all nine order-blind diffs are the SAME two-line-per-side change:

```
-   \_enum_var: (uvm_pkg::uvm_sequencer_base::get_arbitration), line:1389:10
+   \_ref_var:  (uvm_pkg::uvm_sequencer_base::get_arbitration), line:1389:10
```

(`53467:10` in BuildUVMPkg's single-file `pp_output`; the object prints twice per
dump, once nested under the function and once at its own slot, hence 4 lines.)

**THE COIN, MEASURED.** Five repeat runs of Scoreboard/default per binary, the
frozen binaries, same command line:

| | run 1 | 2 | 3 | 4 | 5 | faces |
|---|---|---|---|---|---|---|
| pristine | `5345d158` | `a4eaa5fb` | `5345d158` | `a4eaa5fb` | `5345d158` | **2** |
| patched | `3083f1ef` | `c64e7692` | `3083f1ef` | `3083f1ef` | `c6e2a6c5` | **3** |

`uhdm-cmp` on all ten: **95 lines, 1 head, the same head object**
(`class_typespec: (type_id) @483:12`) on every face and on both binaries. The
row is untouched by this pass; its byteverify MOVER line is the coin plus the
law's four lines, and the order-blind reading separates them.

---

## 8. R0 — THE NEXT HEAD

**SimpleUVM ×2, 29 lines, ONE head** (both modes identical after id-stripping).
`LHS: <null>` with a full RHS — RESUME §9's SINGULAR/VECTOR rule: the OWNER is
set as LHS and the RHS names our object, i.e. **a `Variables` vector we populate
and golden does not**. uvm-1.2 `uvm_sequencer_param_base.svh:270`, inside
`function void uvm_sequencer_param_base::send_request(...)`:

```
RHS  ref_var: (uvm_pkg::uvm_sequencer_param_base::send_request::param_t) @270:7-270:14
       |vpiParent  \_begin: (…::send_request) @272:3-274:6
       |vpiTypespec \_ref_typespec -> unsupported_typespec: (REQ) @270:3-270:6
       |vpiName:param_t
```

It is a **`typedef REQ param_t;` written INSIDE a method body**, where `REQ` is
the class's own type parameter. We materialise a `ref_var` named `param_t` in
the `begin` block's `Variables` list; golden materialises nothing at all — a
body-local TYPEDEF is a type declaration, not a variable, and Surelog's
`compileStmt` never mints an object for it. Note our own typespec is an
`unsupported_typespec (REQ)`, which is the second half of the same story.

**R0: a TYPEDEF DECLARED INSIDE A SUBROUTINE BODY is not a `Variables` entry —
golden lists no object for it, and we list a `ref_var` wearing the typedef's
name.**

SeqDriver, Scoreboard, MiniAmiq, BuildUVMPkg, Earlgrey_0_1 and Rggen keep their
own older heads, byte-untouched by this pass.

## 9. RESIDUES

* **R1 — THE UNQUALIFIED TYPESPEC NAME.** Where this law re-kinds a return in a
  package's DEF listing, golden's typespec is named `<pkg>::<alias>` and ours
  `<alias>` (arm B `f_byte_v`, `f_int_v`, `f_vec_v`, `f_str_v`; arm D `d_qvia`;
  the boundary's `vp9::chain_t`, `vp1::bs2_t`). Pre-existing on BOTH binaries,
  untouched here, and it is what keeps those grid cells at MOVED-STILL-WRONG.
  It does not reach the corpus: the UVM cell's two typespecs are both named
  `uvm_pkg::UVM_SEQ_ARB_TYPE`.
* **R2 — THE TARGET TYPESPEC'S SPAN.** Golden's `UVM_SEQ_ARB_TYPE`
  `enum_typespec` sits at the alias NAME's first written occurrence
  (`uvm_sequencer_base.svh:332:40-332:56`, `set_arbitration`'s formal); ours
  sits at the enum BODY (`uvm_object_globals.svh:359:1-367:26`). `uhdm-cmp`
  reads no span, so this is dump-only.
* **R3 — THE SAME LAW AT OTHER DECLARATION SITES.** Surelog reaches the
  `ref_var` fallthrough from `compileVariable`, which also compiles subroutine
  LOCALS, block locals and package/module variables. This pass gates the change
  to the RETURN variable alone — the head's site — and measures nothing about
  the others; extending it needs its own census and its own boundary.
* **R4 — `$unit`.** A `$unit` function returning a `$unit` alias is golden's
  RESOLVED kind (`unit_fn`, arm D), so the CompilationUnit exclusion is measured
  rather than conservative — but the *reason* (the compilation unit is compiled
  and bound before every component) is inferred from the same
  `bindTypedefs_` reading, not from a separate measurement.

## 10. HOW TO REPRODUCE

```bash
# the probes
for f in ct177own ct177cen ct177pred; do
  g++ -O2 -std=c++17 $f.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/$f
done

# the head decode (needs a SimpleUVM workdir from verify_golden --filter SimpleUVM)
/tmp/ct177own <golden.uhdm> <ours.uhdm> 1389

# the return-variable census of one database, and the golden-vs-ours join
/tmp/ct177cen <db.uhdm>
python3 join177.py <golden census> <ours census> <tag> [--span] [--list all]

# one grid arm, both views, on two binaries, then score it
CT177CEN=/tmp/ct177cen bash grid177.sh g177_a_alias.sv <pristine> <patched> <wd>
python3 score177.py <wd> --list
python3 score177.py <wd> --list --span      # span folded into the verdict

# predict the movers from PRISTINE databases, before touching anything
bash predsweep177.sh <pristine verify_golden workdir> /tmp/PRED.txt /tmp/ct177pred

# attribute the movers ORDER-BLIND (the Scoreboard coin)
bash attrib177.sh <pristine wd> <patched wd> <outdir> <relpath> ...

# the boundary, and the verdict on every arm it moves
PRIS=<pristine> PATCHED=<patched> bash bound177.sh <copy of tools/probe> /tmp/bnd
CT177CEN=/tmp/ct177cen PRIS=<pristine> PATCHED=<patched> \
    bash armjudge177.sh /tmp/bnd/MOVERS <copy of tools/probe> /tmp/aj
```
