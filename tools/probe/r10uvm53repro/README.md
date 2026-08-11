# r10uvm53 — the PACKAGE-GENERIC class handle. TWO laws; the FIVE-row head went 81 -> 17 cmp lines and ALL SEVEN comparable UVM rows now sit behind ONE law; NO conversion

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order. Every dump excerpt is passed through `sed '1d'` (uhdm-dump's FIRST LINE is
the DATABASE PATH and always differs), and `gold.sh` also strips `/home/...`
prefixes.

Base **a318ce0**.

| binary | md5 | what it is |
|---|---|---|
| HEAD control | `078eb83a19153b4e7a2bcc9836d13c99` | my worktree's build of pristine a318ce0 — **byte-identical to the main-tree `build/slang-uhdm` at the start of this pass**, and REPRODUCED mid-pass from `git checkout a318ce0 -- src/TypeEmit.cpp src/ExprEmit.cpp` for gate 5 |
| law 1 only | `8267593abb9dad21c98ccc74e20613eb` | intermediate, used to attribute the head move to law 1 alone |
| FINAL (gated, shipped) | `d0d44a2832cef7ca3cc2d96d4653ba5e` | every gate below ran on this binary |

`git stash` was never used: my edits were copied to `/tmp/r10uvm53_mine/`, the
sources checked out at a318ce0, and copied back — and `git diff a318ce0` after the
restore is **byte-identical** to the diff taken before it (both
`md5 9cb3b5e4ae1fadbcd34751070ab6b0eb`), printed as `RESTORE IS BYTE-IDENTICAL`.
The rebuild after the restore came out `d0d44a28...` again.

## 0. HEADLINE — honest

* **NOTHING CONVERTED.** `SimpleUVM`, `SeqDriver`, `Scoreboard` and
  `BuildUVMPkg` are still `CMP_NOTEQUAL`. **No row in either committed baseline
  changed; `csvdiff.py` reports ROW DIFFS 0 against both. There is NO promotion
  to make.**
* **TARGET 1 LANDED. The five-row head went 81 cmp lines -> 17**, and the head
  they moved to is **the SAME FAMILY as `BuildUVMPkg`'s** — so **all SEVEN
  comparable UVM rows are now behind ONE law**, pass-50's residue
  `classNestedClassTdGroupWithoutPkgAnchor` (this pass's **R1**, target 3).
  That consolidation is the pass's main result.
* **TWO laws landed:**
  * **`classPkgGenericSpecListing53`** (`src/TypeEmit.cpp`,
    `grep -n 'bool pkgGeneric53'`). DIRECTION: **RESHAPE + SUPPRESS**.
  * **`classInBodyBareCallArgStmtOnly53`** (`src/ExprEmit.cpp`,
    `grep -n 'classInBodyBareCallArgStmtOnly53'`). DIRECTION: **SUPPRESS**.
  * plus **SITE 4 of pass 52's `classInBodyRecvCallArgNoBind52`**
    (`grep -n 'RecvCallArg52 rca52D'`) — THE MISS its own integration recorded,
    same gate, no new law.
* **THE BRIEF'S DIRECTION WAS RIGHT AND ITS MECHANISM WAS WRONG.** The corpus
  head does need the span narrowed AND the parameter children dropped — I
  confirmed golden's own object by grepping golden, not from the `<null>` LHS
  (§1). But **it is NOT pass-50 law 3's implementation and the two CANNOT
  share one** (§3a), and the axis is neither "class variable" nor "class
  property": it is **WHERE THE GENERIC CLASS LIVES**, measured with a 3-cell
  cross in arm a3 (§3b). Two candidate axes were REFUTED with cells.
* **`§ classArgBind12`'s unmeasured half is now measured and it is bigger than
  target 2 said**: golden binds a bare in-body call's argument in STATEMENT and
  `if`-CONDITION position ONLY. **The `while`-condition cell is the decider** —
  it does not bind, which proves the mechanism is StmtEmit's
  `classMethodNoBind = false` on if/case and not a "condition binds" carve-out
  (§4).
* Reach, measured on SimpleUVM/`default` with the instruments shipped here:

  | measure | golden | HEAD `078eb83a` | FINAL `d0d44a28` |
  |---|---|---|---|
  | `class_typespec` objects carrying `vpiParameter` (`ctsprobe.py census`) | **0** of 3806 | **209** of 3427 | **0** of 3363 |
  | paired `ref_obj` `vpiActual` DISAGREEMENTS (`bindiff.py`) | — | **341** | **302** |

  **39 binding disagreements removed and ZERO added**: all 69 histogram buckets
  are present on both sides, **none grew, none is new**, and exactly two shrank
  (`vpiArgument/class_defn golden=NONE ours=io_decl` 37->3 and
  `...ours=class_var` 8->3). All 209 parameter-carrying class_typespecs are gone
  and golden has none.

## 1. GOLDEN'S OWN OBJECT — confirmed by grepping golden, not from `LHS: <null>`

The brief warned that a `<null>` LHS can be a SafeCompare artefact. It is not
here. uvm-1.2 `base/uvm_tr_stream.svh:58`
`local uvm_set_before_get_dap#(m_uvm_tr_stream_cfg) m_cfg_dap;`, in
SimpleUVM/`default`'s golden (`grep -n 'class_typespec: (uvm_set_before_get_dap)'`
finds it FOUR times: `812600`, `897411`, `1129977`, `1133050`):

| field | LHS golden | RHS ours at a318ce0 |
|---|---|---|
| object | `class_typespec (uvm_set_before_get_dap)` | same kind and name |
| span | `58:10, endln:58:32` — cols 10-31 = the 22-char generic-class NAME TOKEN | `58:10, endln:58:54` — the whole `uvm_set_before_get_dap#(m_uvm_tr_stream_cfg)` |
| `vpiParameter` / `vpiParamAssign` | **absent / absent** | 1 `type_parameter (uvm_set_before_get_dap.T)` + 1 `param_assign` |
| `vpiClassDefn` | `class_defn (uvm_pkg::uvm_set_before_get_dap)` (the GENERIC) | the same object — **already right** |
| `class_typespec (m_uvm_tr_stream_cfg)` (the specialization ARGUMENT) | **0 occurrences in the whole database** | 2 occurrences |

The same shape appears a second time in the same golden for
`uvm_pkg::uvm_recorder::m_stream_dap` at `47:9-47:31`. So the fix has to do both
things, and dropping the parameters also removes the argument typespec golden
never had.

## 2. Drivers and arms (all committed here; every cited guard EXERCISED)

| asset | what it is |
|---|---|
| `ctsprobe.py` | **new** — per CLASS VARIABLE, the span and `hasParam` of its `class_typespec`. **Not a grep:** uhdm-dump prints an object's children at some occurrences and abbreviates it at others, so this identifies objects by (kind, name, span) and takes the UNION over occurrences. GUARDS: refuses to report on a dump with 0 `class_typespec`; prints and counts `UNMEASURED` for an unresolvable typespec; **`--selftest`** is the POSITIVE control (fixture where the object is printed once with children and once without). **NEGATIVE CONTROL RUN:** breaking the union (`objs[...]['rels'].add(rel)` -> `pass`) makes the selftest print `SELFTEST FAIL: union of occurrences lost vpiParameter` and exit 1. |
| `cells.sh` | arm-cell table for one `gold.sh` outdir, BOTH SIDES, via `ctsprobe.py cell`. Existence-checks both dumps. |
| `argcells.sh` | arm a4's call-ARGUMENT binding table, BOTH SIDES, keyed by `line:col`. Also **prints the `CP0332` count from `surelog.log`** — pass 52 recorded that Surelog refuses a class method's bare call to a PACKAGE function, which silently poisons this arm. a4 is written so the count is **0**. |
| `gold.sh` | one arm, golden + ours, dump + cmp + content ±. **PASS-52 INTEGRATION ITEM C6 FIXED:** it now existence-checks `uhdm-cmp` and `uhdm-dump` too, resolved to absolute paths, and prints them. Keeps the `sed '1d'` and the `RAW - 2` arithmetic. |
| `sbflake.sh` | **new** — Scoreboard is BOTH a target row AND intermittently nondeterministic, so it runs the same test N times with one binary and prints cmp lines / heads / database sha256 each run. |
| `heads.sh` | per-test cmp lines / head count / id-normalised md5 over a workdir. Unchanged from pass 52. **KNOWN DEFECT, NOT FIXED HERE (pass-52 integration C5):** its `HEAD_MD5_IDNORM` column hashes the WHOLE cmp file, not just the head; it coincides here only because every measured file has exactly one head, and it is path-sensitive. Every md5 equality I quote below is between files measured by the same run of this script, which is the only claim it can support. **The md5 numbers are INSTRUMENT-LOCAL: quote the EQUALITY, never the number.** |
| `canaries.sh` | per-NAME canary check. **PASS 53 CHANGES:** the four brief-mandated canaries `TypespecExpr`, `ClogCast`, `2DFunctionArg`, `PartSelect4` were NOT in the list, so no pass was actually checking them by name — added. Header's stale "exits 6" text corrected to match the opt-in `CANARY_STRICT=1` behaviour, and the expected UNKNOWN-NAME counts RE-MEASURED (8 on a surelog csv, 28 on a u2r csv). |
| `bvcompare.sh` | byte-verifier join. **PASS-52 INTEGRATION ITEM C7 FIXED:** the unpaired-path tail was unlabelled and silently `head -20`-truncated; it is now LABELLED, COUNTED, untruncated, and an UNPAIRED count of 0 is stated explicitly. |
| `manifest.sh`, `csvdiff.py`, `corpdump.sh`, `explainmover.sh` | unchanged from pass 52 (their guards were verified correct at that integration). `diff -rq r10uvm52repro r10uvm53repro` confirms that ONLY `gold.sh`, `canaries.sh` and `bvcompare.sh` were modified among the copied drivers. |
| `../r10uvm52repro/dumptree.py`, `../r10uvm52repro/bindiff.py` | **NOT copied — used in place** by `argcells.sh` and by the reach measurement, so there is one copy of the binding instrument and no chance of two divergent ones. Both `--selftest`s were RE-RUN here and PASS. |
| `a1/dut.sv` | **new, and NOT pass 52's `a1`** — the directory names `a1`/`a2` are reused per pass; `r10uvm53repro/a1` and `r10uvm52repro/a1` are unrelated arms. Where does a `#(...)` handle keep its parameters? 8 cells crossing class PROPERTY / class-METHOD LOCAL / PACKAGE variable / MODULE variable / class-nested typedef / package typedef, all with a PACKAGE generic. |
| `a2/dut.sv` | **new** — reproduces the corpus head EXACTLY (81 cmp lines, 1 head, same object shape) and crosses the two axes the brief left implicit: `$unit` vs PACKAGE generic, and `= new` present vs absent. |
| `a3/dut.sv` | **new** — **THE CROSS** that separates "generic's home" from "declaring class's home", plus a MODULE-declared class and a cross-package generic. |
| `a4/dut.sv` | **new** — target 2's two cells with their OUT-OF-BODY and PACKAGE twins, plus four extra EXPRESSION spellings (operand, nested, while-condition, return) the first cut of the arm did not have. |

Every arm is judged on `diff -u g.dump o.dump` (via `ctsprobe.py` /
`dumptree.py`), never on cmp alone — a1's cmp head never moves in this pass while
five of its cells are fixed and its dump ± falls 298 -> 122, which is the
`m_visited` trap in the flesh; and a4's cmp GROWS 29 -> 64 lines while its dump ±
falls 224 -> 212 (§4c).

## 3. LAW 1 — `classPkgGenericSpecListing53`

**Sites, all tagged `NOTE § classPkgGenericSpecListing53`** in
`src/TypeEmit.cpp`'s `makeTypespec` class-handle arm: the predicate
(`grep -n 'bool pkgGeneric53'`), the SUPPRESS half
(`grep -n 'writtenSpec0 && !pkgGenericListing53'`) and the RESHAPE half
(`grep -n 'listingSite53'`).

**Predicate.**

```
pkgGeneric53      = the class type's GENERIC class (ClassType::genericClass, or
                    the type itself when it is not a specialization) has a
                    PARENT SCOPE of kind Package
declInInstance53  = the DECLARED SYMBOL's immediate parent scope is an
                    InstanceBody
pkgGenericListing53 = pkgGeneric53 && !declInInstance53      -> SUPPRESS params
listingSite53       = pkgGenericListing53 && the declared symbol's immediate
                      parent scope is a ClassType or a Package
                                                             -> NARROW the span
```

**Direction: RESHAPE + SUPPRESS** — the object is still emitted and still
carries its name and its `vpiClassDefn`; only `vpiParameter`/`vpiParamAssign`
and the span change.

**Surelog's mechanism, TRANSCRIBED not guessed**
(`src/DesignCompile/CompileType.cpp`, `compileTypespec`). Before it reaches
`compileDatastructureTypespec` — the ONLY site in Surelog that ever fills
`ref->Parameters(params)` / `ref->Param_assigns(assigns)`, in its
`datatype_cast<const ClassDefinition*>` arm — it tries

```
design->getClassDefinition(typeName)
design->getClassDefinition(<component>::<typeName>)
design->getClassDefinition(<component's parent scope>::<typeName>)
```

and **on a hit** mints a bare `class_typespec` with `VpiName` + `Class_defn` and
`fC->populateCoreMembers(type, type, tps)` — i.e. the **NAME-TOKEN span and no
parameters**. A class declared in a package is registered under
`<pkg>::<name>`, so that lookup HITS for a package generic and MISSES for a
`$unit` one. That is exactly the axis a3 measures below, and it is why the law
keys on the GENERIC's home scope rather than on anything about the declaration.

### 3a. CAN LAW 1 SHARE PASS 50 LAW 3's IMPLEMENTATION? NO — and here is why

Pass 50 law 3 (`pkgImportClassTdClone50`, `r10uvm50repro/README.md` §6) builds
the same *visible* shape — "span = the generic class NAME TOKEN, `vpiParameter`
and `vpiParamAssign` EMPTY". I read it before writing anything, as instructed,
and the two **cannot** share code:

| | pass 50 law 3 | this law |
|---|---|---|
| object | a package typedef's **import CLONE**, cached in `pkgImportCloneTs` | a **fresh** `class_typespec` minted per declaration |
| producer | `src/ParamEmit.cpp`'s package-typedef resolution (`cl8 = makeTypespec(...)` + `setLoc`) | `src/TypeEmit.cpp`'s `makeTypespec` class-handle arm |
| KEY | the **generic-class GROUP** (`classTdGroupBase50`, pass-49's grouping and base pick), and it additionally hangs a `vpiTypedefAlias` on non-base members | the generic class's **HOME SCOPE**; there is no group and no alias |
| shared-object risk | high — the clone is walked by every importer, so pass 50 needed idempotent span copies and an alias-absent test | none — the object is freshly minted here and never cached |

The only thing they share is the *appearance* of the result. Factoring them
together would mean dragging the group machinery into a declaration site that has
no group, and would put a cached, shared object under a `setLoc` that this law
applies unconditionally — the "NEVER MUTATE A SHARED OBJECT" trap. **They are
kept separate deliberately.**

### 3b. THE AXIS — arm a3, and TWO REFUTATIONS

`tools/probe/r10uvm53repro/a3/dut.sv`, read with `cells.sh`. Every cell name is
a variable name in that file.

| cell | dut.sv | declaring class's home | GENERIC's home | LHS golden span / hasParam | RHS a318ce0 | RHS final |
|---|---|---|---|---|---|---|
| `e3_pkgclass_pkggeneric` | 51 | package `r53` | package `r53` | `51:5-51:10` / **False** | `51:5-51:19` / True | **`51:5-51:10` / False — FIXED** |
| `e6_pkgclass_otherpkggeneric` | 56 | package `r53` | package `s53` | `56:5-56:10` / **False** | `56:5-56:10` / True | **`56:5-56:10` / False — FIXED** |
| `e2_unitclass_pkggeneric` | 63 | **`$unit`** | package `r53` | `63:3-63:8` / **False** | `63:3-63:8` / True | **`63:3-63:8` / False — FIXED** |
| `e4_unitclass_unitgeneric` | 68 | `$unit` | **`$unit`** | `68:3-68:8` / **True** | `68:3-68:17` / True | `68:3-68:17` / True — **params UNTOUCHED (correct); span still wide, residue R3** |
| `e5_modclass_unitgeneric` | 74 | module `top53` | **`$unit`** | `74:5-74:10` / **True** | `74:5-74:19` / True | `74:5-74:19` / True — **params UNTOUCHED (correct); span residue R3** |

* **REFUTATION 1 — "a class VARIABLE / a class PROPERTY" is NOT the axis.** All
  five cells above are class properties, and golden gives `e4` and `e5`
  parameters. A "class property" gate would have stripped 2 correct
  parameter lists in this 5-cell arm alone.
* **REFUTATION 2 — the DECLARING class's home scope (axis B) is NOT the axis.**
  `e2` is a `$unit` class holding a PACKAGE generic and golden gives it NO
  parameters; `e5` is a MODULE-declared class holding a `$unit` generic and
  golden DOES. The key is **the generic's home**, and `e2`/`e5` are the two
  cells that decide it.
* **THE 2x2 CANNOT BE COMPLETED, and that is recorded rather than glossed.** The
  fourth corner — a PACKAGE class holding a `$unit` generic — is **illegal
  SystemVerilog**; slang rejects it with `cannot reference compilation unit item
  from within a package` (LRM 3.12.1). My first cut of a3 contained that cell and
  the whole arm failed to compile; the comment at the top of `a3/dut.sv` records
  it.

### 3c. WHY THE GATE CARRIES `!declInInstance53` — arm a2, measured both ways

`a2/dut.sv` also **reproduces the corpus head exactly**: at a318ce0 it is
`81 cmp lines / 1 head`, `LHS: <null>` / `RHS: class_typespec (pgc53), 41:5-41:19`
with `vpiParameter`, parented at `class_var (q53::pholder53::d2_pkg_prop_spec)`
— the same line count and the same object shape as SimpleUVM's head.

| cell | dut.sv | site | generic | LHS golden span / hasParam | RHS a318ce0 | RHS final |
|---|---|---|---|---|---|---|
| `d1_unit_prop_spec` | 28 | class property | `$unit` | `28:3-28:8` / **True** | `28:3-28:17` / True | unchanged — **params correct, span residue R3** |
| `d2_pkg_prop_spec` | 41 | class property | package | `41:5-41:10` / **False** | `41:5-41:19` / True | **`41:5-41:10` / False — FIXED (the corpus head's cell)** |
| `d3_pkg_prop_spec_new` | 43 | class property `= new` | package | `43:5-43:10` / **False** | `43:5-43:19` / True | **`43:5-43:10` / False — FIXED** |
| `d4_unit_modvar_new` | 51 | MODULE var, `= new` | `$unit` | `51:3-51:42` / **True** | `51:3-51:17` / True | unchanged — **deliberately UNTOUCHED** |
| `d5_unit_modvar` | 53 | MODULE var, no init | `$unit` | `53:3-53:8` / **False** | `53:3-53:17` / True | unchanged — **residue R4** |
| `d6_pkg_modvar_new` | 55 | MODULE var, `= new` | package | `55:3-55:41` / **True** | `55:3-55:17` / True | unchanged — **deliberately UNTOUCHED** |
| `d7_pkg_modvar` | 57 | MODULE var, no init | package | `57:3-57:8` / **False** | `57:3-57:17` / True | unchanged — **residue R4** |

**REFUTATION 3 — at MODULE scope golden does NOT split on the generic's home; it
splits on the INITIALIZER.** `d6` (package generic, `= new`) KEEPS its
parameters and takes the WHOLE-declaration span; `d7` (the same generic, no
initializer) has neither. A gate that had ignored `!declInInstance53` would have
stripped `d6`'s parameters — and `d6` is spelled exactly like
`ClassParamAsParam`'s `config_db#(object#(longint)) misc2 = new;`, a LIVE
`CMP_EQUAL` canary. That is the cell that stopped the law from getting too wide.
Both module-variable halves are left exactly as they were and recorded as
residue **R4**.

### 3d. WHY THE SPAN HALF IS NARROWER THAN THE PARAMETER HALF — arm a1

`a1/dut.sv`, all cells with a PACKAGE generic:

| cell | dut.sv | site | LHS golden span / hasParam | RHS a318ce0 | RHS final |
|---|---|---|---|---|---|
| `c1_prop_spec` | 27 | class property | `27:5-27:9` / False | `27:5-27:17` / True | **`27:5-27:9` / False — FIXED** |
| `c2_prop_bare` | 29 | class property, BARE name | `29:5-29:9` / False | `29:5-29:9` / False | unchanged (§ classTsDefaultSpecNoParams already had it) |
| `c3_prop_td` | 32 | class property via class-nested typedef | `45:11-45:15` / False | same | unchanged |
| `c4_local_spec` | 36 | class-METHOD LOCAL | **`36:7-36:19` (WHOLE text) / False** | `36:7-36:19` / True | **`36:7-36:19` / False — params FIXED, span correctly left WIDE** |
| `c5_pkgvar_spec` | 42 | PACKAGE variable | `42:3-42:7` / False | `42:3-42:15` / True | **`42:3-42:7` / False — FIXED** |
| `c6_pkgtd_var` | 46 | package typedef | `46:3-46:13` / False | `46:3-46:13` / False (ts NAME differs — pre-existing typedef-alias residue) | unchanged |
| `c7_modvar_spec` | 54 | MODULE variable, no init | `54:3-54:7` / False | `54:3-54:15` / True | unchanged — **residue R4** |
| `c8_modvar_bare` | 56 | MODULE variable, bare name | `56:3-56:7` / False | same | unchanged |

`c4_local_spec` is the cell that makes `listingSite53` narrower than
`pkgGenericListing53`: golden strips the parameters of a class-method local of a
package generic but keeps the WHOLE-declaration span. Gating the span on
"direct member of a ClassType or a Package" reproduces both halves. (Its
`class_typespec` is also UNNAMED on both sides — `§ localClassTsUnnamed15`,
untouched.)

**HOW THE GATE WAS PROVED NECESSARY.** Three independent ways.
(a) The arms: 8 of a1's 10 rows, 2 of a2's 7 and 3 of a3's 5 moved to golden's
answer and **no cell moved away from it**; a3's cmp went 81 -> 32 lines and its
dump ± 205 -> 120, a1's dump ± 298 -> 122.
(b) The corpus: SimpleUVM's parameter-carrying `class_typespec` count went
**209 -> 0** against golden's **0**, and its total `class_typespec` count fell
3427 -> 3363 because the specialization-ARGUMENT typespecs golden never had
(`class_typespec (m_uvm_tr_stream_cfg)`, 0 occurrences in golden) are no longer
minted.
(c) The head: five rows went 81 -> 17 cmp lines under law 1 ALONE (binary
`8267593a`, §5).

## 4. LAW 2 and SITE 4 — the two call-argument residues, together

### 4a. SITE 4 of `classInBodyRecvCallArgNoBind52` — the MISS, and its arithmetic CORRECTED

**Gate: unchanged** — `curSubClassScope9 && !curSubOob9 && recvCallArgDepth52 > 0`.
The only change is one more `RecvCallArg52` window
(`grep -n 'RecvCallArg52 rca52D'`) around the DEEP-RECEIVER arm's argument loop
(`grep -n 'bool deepRecv11'`).

**I RE-COUNTED THE MINT SITES INSTEAD OF INHERITING THE BRIEF'S COUNT, and the
brief's arithmetic is slightly wrong while its conclusion is right.** The
`ExpressionKind::Call` case runs from the `case ExpressionKind::Call:` label to
the next case label (`ExpressionKind::Concatenation`). Inside it:

* **FIVE** `MakeHier_path()` mints. (A sixth in the file is in the
  `ElementSelect` case, outside.)
* **FOUR** of the five are under `!callStmtCtx0`.
* Pass 52 opened **THREE** windows — but only **TWO** of them
  (`rca52`, `rca52H`) sit on arms under `!callStmtCtx0`; the third (`rca52B`) is
  on the FIFTH mint, which is **not** under `!callStmtCtx0` (its comment names
  `callStmtCtx0` where the guard is `stmtCtx` — pass-52 integration item C3).
* So **TWO** of the four `!callStmtCtx0` mints were unwindowed, not one:
  the `deepRecv11` arm, and the `thisRoot11` arm. **The `thisRoot11` one needs
  no window: it builds its path elements and `return hp11;` WITHOUT EMITTING ANY
  CALL ARGUMENTS at all.** So `deepRecv11` was the only reachable gap, which is
  the brief's conclusion reached by a corrected count.

### 4b. LAW 2 — `classInBodyBareCallArgStmtOnly53`

**Site:** `src/ExprEmit.cpp`, the general (receiver-less) call-argument loop,
`grep -n 'classInBodyBareCallArgStmtOnly53'`. The unconditional
`ClassArgBind12 cab12(classArgBindDepth12);` becomes

```
ClassArgBindIf38 cab12(classArgBindDepth12,
                       callStmtCtx0 || !(curSubClassScope9 && !curSubOob9));
```

**Direction: SUPPRESS** — the `§ classArgBind12` window is simply not opened.
`classArgBindDepth12` has exactly ONE reader
(`grep -n 'classMethodNoBind && classArgBindDepth12 == 0'`), so the blast radius
is exactly "does this ref bind its actual".

**Why this mechanism and not a second condition carve-out.** With the window
closed, the `if`-CONDITION cell STILL binds, because StmtEmit's if / if_else /
case arms set `classMethodNoBind = false` outright
(`grep -n 'condition refs DO bind' src/StmtEmit.cpp` — three sites). The
`while`-condition does **not** clear it, and golden does **not** bind there.
That cell is the whole reason this is the right mechanism: a hand-written
"conditions bind" carve-out would have bound the `while` cell too.

### 4c. ARM a4 — every cell, BOTH SIDES, ONE golden

`a4/dut.sv`; read with `argcells.sh`. `surelog CP0332 count = 0` (pass 52's
polluted-cell trap avoided by making the bare callee a method of the same class).
The value read is the `vpiActual` of the `f` argument `ref_obj` at that
`line:col`.

| cell | dut.sv | position / callee | LHS golden | RHS a318ce0 | RHS final |
|---|---|---|---|---|---|
| `f2_ib_stmt_bare` | 51 `self53(f);` | IN BODY, STATEMENT, bare | **io_decl** | io_decl | **io_decl — unmoved (control)** |
| `f2_ib_cond_bare` | 52 `if (self53(f) == 0)` | IN BODY, if-COND, bare | **io_decl** | io_decl | **io_decl — unmoved (control)** |
| `f2_ib_rval_bare` | 54 `loc = self53(f);` | IN BODY, r-value | **NONE** | io_decl | **NONE — FIXED (target 2 / R2)** |
| `f2_ib_rval_op_bare` | 55 `loc = self53(f) + 1;` | IN BODY, operation operand | **NONE** | io_decl | **NONE — FIXED** |
| `f2_ib_rval_nest_bare` | 56 `loc = self53(self53(f));` | IN BODY, nested argument | **NONE** | io_decl | **NONE — FIXED** |
| `f2_ib_while_bare` | 57 `while (self53(f) == 99)` | IN BODY, **while-CONDITION** | **NONE** | io_decl | **NONE — FIXED (the decider)** |
| `f1_ib_cond_deep` | 59 `if (mid.leaf.m53(f) == 0)` | IN BODY, if-COND, DEEP receiver | **NONE** | io_decl | **NONE — FIXED (target 2 / THE MISS)** |
| `f1_ib_rval_deep` | 61 `loc = mid.leaf.m53(f);` | IN BODY, r-value, DEEP receiver | **NONE** | NONE | **NONE — unmoved (already right)** |
| `f1_ib_stmt_deep` | 62 `mid.leaf.m53(f);` | IN BODY, STATEMENT, DEEP | (no argument ref_obj emitted on either side) | — | — |
| `f2_ib_ret_bare` | 63 `return self53(f) + loc;` | IN BODY, return expression | **NONE** | io_decl | **NONE — FIXED** |
| `f2_ob_stmt_bare` | 80 | OUT OF BODY, statement | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f2_ob_cond_bare` | 81 | OUT OF BODY, if-COND | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f2_ob_rval_bare` | 83 | OUT OF BODY, **r-value** | **io_decl** | io_decl | **io_decl — UNTOUCHED** |
| `f2_ob_rval_op_bare` | 84 | OUT OF BODY, operand | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f2_ob_rval_nest_bare` | 85 | OUT OF BODY, nested | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f2_ob_while_bare` | 86 | OUT OF BODY, **while-COND** | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f1_ob_cond_deep` | 88 | OUT OF BODY, if-COND, DEEP | **io_decl** | io_decl | **io_decl — UNTOUCHED** |
| `f1_ob_rval_deep` | 90 | OUT OF BODY, r-value, DEEP | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f2_ob_ret_bare` | 92 | OUT OF BODY, return | io_decl | io_decl | **io_decl — UNTOUCHED** |
| `f2_pk_*` / `f1_pk_*` | 103,104,106,107,108,110,111 | PACKAGE function, all seven | io_decl | io_decl | **io_decl — UNTOUCHED** |

**Rows 83-92 are why both gates carry `!curSubOob9`, and rows 103-111 are why
they carry `curSubClassScope9`.** They are byte-for-byte the same source as the
in-body cells, moved after `endclass` / into a package function, and golden binds
every one of them. **All nine in-body cells now match golden and no out-of-body
or package cell moved.**

**a4's cmp GREW, 29 -> 64 lines, and that is a head ADVANCE, proven not
assumed.** At a318ce0 a4's single head was `LHS: <null>` /
`RHS: io_decl (f) @48:29` — our over-bind. That head is GONE. The new head is a
PACKAGE-function difference at `a4/dut.sv:111`
(`return pk_bare53(f) + loc;`): golden holds ONE `ref_obj (p53c::pk_all::f)
@111:22` whose `vpiParent` is the `operation` directly, and **we hold ZERO such
objects — in the a318ce0 dump AND in the final dump** (measured:
`grep -A2 'ref_obj: (p53c::pk_all::f), line:111:22' | grep -c operation` gives
golden 1, ours 0 at HEAD, ours 0 at FINAL). It is PRE-EXISTING, in a PACKAGE
function neither law touches, and was simply hidden behind the removed head.
a4's dump ± fell 224 -> 212 across the same change.

**HOW LAW 2 + SITE 4 WERE PROVED NECESSARY.** (a) The arm: exactly the six
wrong in-body cells moved and none of the thirteen out-of-body/package cells
did. (b) The corpus: SimpleUVM's paired-`ref_obj` disagreements fell
**341 -> 302** with **zero new disagreements and zero new buckets** across all
69 histogram buckets; the two buckets that shrank are precisely
`vpiArgument/class_defn golden=NONE ours=io_decl` (37 -> 3) and
`golden=NONE ours=class_var` (8 -> 3). (c) Gate 5 saw BuildUVMPkg move BYTES
with a byte-identical cmp head, which is what a law reaching class bodies behind
the head looks like.

*(Corroboration of pass 52's own final figure: my HEAD measurement of
SimpleUVM's disagreements is **341**, exactly the number pass 52 reported for its
final binary. Independent instrument run, same answer.)*

## 5. WHERE THE HEADS ARE NOW — measured per row with `heads.sh`

| test | mode | a318ce0 lines/heads | law 1 only | FINAL lines/heads | FINAL head family |
|---|---|---|---|---|---|
| SimpleUVM | default | 81 / 1 | 17 / 1 | **17 / 1** | R1 — `ref_typespec (uvm_pkg::uvm_set_before_get_dap::type_id)` |
| SimpleUVM | testflags | 81 / 1 | 17 / 1 | **17 / 1** | same |
| SeqDriver | default | 81 / 1 | 17 / 1 | **17 / 1** | same family, different `vpiActual` |
| SeqDriver | testflags | 81 / 1 | 17 / 1 | **17 / 1** | same |
| Scoreboard | default | 81 / 1 | 17 / 1 | **17 / 1** | same as SimpleUVM |
| BuildUVMPkg | default | 17 / 1 | 17 / 1 | **17 / 1** | R1 — `ref_typespec (uvm_pkg::uvm_pool::type_id)`, head md5 **UNCHANGED** |
| BuildUVMPkg | testflags | 17 / 1 | 17 / 1 | **17 / 1** | same |
| Scoreboard | testflags | SKIP-NOFILE (SLANG_REJECT at baseline) | — | SKIP-NOFILE | — |

At a318ce0 the five 81-line rows had EQUAL id-normalised head md5s (one run of
`heads.sh`, one shape). At FINAL, SimpleUVM x2 and Scoreboard share one md5 and
SeqDriver x2 share another, but **all four md5 classes are the same FAMILY**:

```
LHS: ref_typespec: (uvm_pkg::<class>::type_id)
     |vpiParent: class_typespec (type_id)  @<line>:12-<line>:31
     |vpiActual: class_typespec (type_id)  @<line>:12-<line>:31   (a DIFFERENT object)
RHS: <null>
```

with `<class>` = `uvm_set_before_get_dap` (uvm-1.2 dap file line 453) for the
five and `uvm_pool` (1800.2 pp line 26247) for BuildUVMPkg. That is pass-50's
residue R2/R5, `classNestedClassTdGroupWithoutPkgAnchor` — **now the single head
of all SEVEN comparable UVM rows.** Never mix the two UVM versions' line
numbers: BuildUVMPkg compiles 1800.2-2017-1.0, the other three uvm-1.2.

**Scoreboard, settled by RE-RUNNING as instructed.** `sbflake.sh` x4 on the FINAL
binary: `cmplines=17 heads=1` on ALL FOUR runs, while the database sha256 flipped
on run 4 — the known macro-buffer flake reproduced, on a binary whose cmp answer
is stable. So Scoreboard's cmp move (81 -> 17) is solid and its gate-5 byte
mover is NOT clean evidence, exactly as `bvcompare.sh` labels it.

## 6. TARGET 3 — NOT ATTEMPTED, and I say so plainly

`classNestedClassTdGroupWithoutPkgAnchor` (pass 50's R2 / pass 52's R5) is now
the head of all seven rows. I did **not** implement it: gates 3, 4 and 5 cost
this pass about three sweep-hours, and shipping a change to the class-typedef
group machinery without re-running all five gates would break the rule that
nothing ungated ships. It is **R1** below.

**I DID re-verify its key rather than inherit it**, since it is one grep and one
sort:

* `grep -c 'typedef uvm_object_registry#'` on
  `third_party/UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv` = **50**.
* pp **26247** is `typedef uvm_object_registry#(uvm_barrier,"uvm_barrier") type_id;`
  — and BuildUVMPkg's golden head object is exactly
  `class_typespec (type_id) @26247:12-26247:31`.
* sorted specialization names: `this_type` < `uvm_barrier` < `uvm_callback` <
  `uvm_cause_effect_link` < `uvm_comparer` … The one that sorts before
  `uvm_barrier`, pp **16779** `typedef uvm_object_registry#(this_type) type_id;`,
  sits inside `class uvm_resource #(type T=int)` at pp **16767** — a GENERIC
  class, not a concrete specialization.

So **`uvm_barrier` is alphabetically first among the CONCRETE specializations and
it is golden's base.** Pass 49/50's NAME-ORDER law is intact; only its KEY was
too narrow. That prediction is unchanged and still checkable.

## 7. RANKED RESIDUE — most reachable first, ONE number per residue

**R1. `classNestedClassTdGroupWithoutPkgAnchor` — a CLASS-NESTED class-handle
typedef group with no package-level anchor gets no base clone and no
`vpiTypedefAlias`. DIRECTION: ADD. Depth: medium. RANK 1, and it is now the
SINGLE head of ALL SEVEN comparable UVM rows.** §5 and §6. Its one open question
is answered and re-verified here: base = the alphabetically FIRST CONCRETE
SPECIALIZATION name (`uvm_barrier`, 1800.2 pp 26247). Implementation shape:
populate `classTdGroupBase50` from class-NESTED typedefs when no package-level
anchor exists (pass 50 law 4's consumer already exists at
`grep -n 'auto\* gcN50' src/UhdmExporter.cpp`). Expect collateral across both
corpora — budget a full five-gate run for it alone.

**R2. `scopedClassTsNameDropsSpecialization` — a SCOPED, `#(...)`-spelled class
handle is NAMED with the parameter text included. DIRECTION: RESHAPE (name
only). Depth: SHALLOW — one expression in the ScopedName arm. RANK 2, and it is
CMP-VISIBLE.** Witness, arm a3 both sides after law 1 (`cells.sh`):
`e6_pkgclass_otherpkggeneric` golden `VpiName = s53::sgc53`, ours
`s53::sgc53#(s53::scfg53)`; `e2_unitclass_pkggeneric` golden `r53::rgc53`, ours
`r53::rgc53#(r53::rcfg53)`. It is **a3's FINAL cmp head** (32 lines / 1 head,
`LHS class_typespec (s53::sgc53)` vs `RHS class_typespec
(s53::sgc53#(s53::scfg53))`). The site is
`grep -n 'rawText(sn0->sourceRange())' src/TypeEmit.cpp`, which takes the raw
text of the WHOLE `ScopedName` including the `#(...)`; golden stops at the leaf
identifier. Not done here because it needs its own five-gate run and every
scoped class typespec in both corpora goes through that line.

**R3. `classPropUnitGenericSpanNameToken` — the NAME-TOKEN span applies to a
class PROPERTY even when the generic is NOT in a package; only the PARAMETERS
depend on the package. DIRECTION: RESHAPE (span only). Depth: SHALLOW — drop
`pkgGenericListing53` from `listingSite53` and keep the site test. RANK 3.**
Witnesses, all three after law 1: a2 `d1_unit_prop_spec` golden `28:3-28:8` /
ours `28:3-28:17`; a3 `e4_unitclass_unitgeneric` golden `68:3-68:8` / ours
`68:3-68:17`; a3 `e5_modclass_unitgeneric` golden `74:5-74:10` / ours
`74:5-74:19`. Deliberately NOT taken: it is bytes-only as far as anything
measured here can see (`ClassParamAsParam` is `CMP_EQUAL` today with three
different class_typespec spans from golden), so it earns nothing at the row gate
while costing a full re-gate.

**R4. `moduleVarSpecNoInitNoParams` — a MODULE-scope class-handle variable with
NO initializer takes the NAME-TOKEN span and NO parameters; with `= new` it
keeps both. DIRECTION: RESHAPE + SUPPRESS, gated on the INITIALIZER. Depth:
shallow, but the gate is an initializer test our emitter does not currently make
at this site. RANK 4.** Witnesses: a2 `d5_unit_modvar` and `d7_pkg_modvar`
(golden narrow/no-params, ours wide/params) against `d4_unit_modvar_new` and
`d6_pkg_modvar_new` (golden wide/params, ours wide/params — already right).
a1 `c7_modvar_spec` is the third. **`d6` is spelled exactly like
`ClassParamAsParam`'s live `CMP_EQUAL` row, so this residue must be taken with
the initializer gate and never without it.**

**R5. `assocArrayVarCarriesElemSign` — golden puts `vpiSigned` on the array_var
of a signed-element assoc/queue/dyn array, we put it on the element reg.
DIRECTION: MOVE. RANK 5.** Pass 52's R4, carried forward UNCHANGED and NOT
re-measured here; pre-existing at a318ce0 and untouched by this pass. It is no
longer any arm's head in this pass (a1's head is a package-object difference).

**R6. the `LHSgolden=BOUND / RHSours=NONE` half of the binding table — 302
disagreements remain, of which the biggest buckets are UNDER-binds.
DIRECTION: ADD. Depth: unknown. RANK 6.** Measured here on SimpleUVM/`default`:
`vpiExpr class_defn golden=NONE ours=enum_const` x22,
`vpiOperand class_defn golden=class_var ours=NONE` x17,
`vpiArgument class_defn golden=class_var ours=NONE` x16, and 66 smaller buckets.
The two over-bind buckets this pass attacked are down to x3 each. `bindiff.py`
prints the whole table.

**R7. a4's own head — a PACKAGE function's `return f(x) + y` puts golden's
argument ref_obj directly under the `operation` in one view where we always keep
the `func_call`. DIRECTION: unknown. RANK 7 (an arm head, not a corpus head).**
PRE-EXISTING and proven so in §4c. Recorded because it is now what a4 stops at.

## 8. GATES — all five, with MY numbers

`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` were **read only,
never rebuilt, edited or included.** Their row counts come from `csvdiff.py`'s
parsed dict (**731** and **1588**), never from `wc -l` (which would say 732 and
1589 because of the header). The binary md5 was printed BEFORE and AFTER every
sweep and **no rebuild happened while a sweep was running**.

| gate | result |
|---|---|
| 1. `cmake --build build -j 3` | rc 0, `d0d44a2832cef7ca3cc2d96d4653ba5e`; control `078eb83a19153b4e7a2bcc9836d13c99` — **the md5 CHANGED** |
| 2. 23 goldens, `SLANG_UHDM` exported to MY build | **PASS 23 / FAIL 0** |
| 2b. negative control `SLANG_UHDM=/bin/false` | **FAIL 23 / PASS 0** — the harness really is using the exported binary, so gate 2 was not a stale-binary pass |
| 3. uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir` | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `csvdiff.py` vs `results/gate_uhdm2rtlil.csv` **ROW DIFFS 0** |
| 4. surelog, `--mode both --jobs 2`, own `--out`/`--workdir` | §9 |
| 5. byte verifier, BOTH corpora, same workdir paths | §10 |

## 9. GATE 4 — the surelog corpus

`--mode both --jobs 2 --out /tmp/r10uvm53_sl.csv --workdir /tmp/r10uvm53_sl_wd`,
`SLANG_UHDM` exported to my build, md5 `d0d44a28` printed before AND after.

* `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**; `testflags` **463 / 10** — both
  exactly the a318ce0 figures.
* totals **930 CMP_EQUAL / 23 CMP_NOTEQUAL / 570 SLANG_REJECT / 48 SURELOG_FAIL
  / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM**.
* dump **390 match / 540 differ / 658 blank** — **the match counts DID NOT
  FALL** (baseline 390 = 225 default + 165 testflags).
* `csvdiff.py` vs `results/golden_surelog.csv`: **ROW DIFFS 0** — whole row,
  status AND dump.
* `LowMemPkg,testflags`' baseline row carries an absolute session-scratchpad
  path; it reproduced identically. NOT touched, NOT reported as a regression.
* No `Google,testflags` SURELOG_FAIL/TIMEOUT flake this run (it would have shown
  as a row diff; there were none).

**Canaries, spot-checked INDIVIDUALLY BY NAME** with the FIXED `canaries.sh`:

* surelog csv: **ok=58 changed=0 absent=0 unknown-names=8**, rc 0. The two live
  fragile conversions are intact — `InterfaceModPort` `CMP_EQUAL` both modes,
  `BlackParrotComplex` `CMP_EQUAL` both modes. `YosysBigSimReed` /
  `YosysOldOpen` `CMP_EQUAL` both modes; `YosysOldOr` `CMP_NOTEQUAL` both modes.
  Pass-50's five collateral movers (`ClassParamAsParam`, `ClassTypeParam`,
  `SVSwitch`, `SimpleConstraint`, `ApbSlave`) all unchanged. The four names
  pass 53 ADDED: `TypespecExpr` `CMP_EQUAL`/`CMP_EQUAL`, `ClogCast`
  `CMP_EQUAL`/`CMP_EQUAL`, `PartSelect4` `CMP_EQUAL`/`CMP_EQUAL`, all at
  baseline; `2DFunctionArg` is a u2r-only name. `Scr1SvTests`, `BasicOh`
  `CMP_EQUAL`; `Earlgrey_0_1` `CMP_NOTEQUAL`/`SLANG_REJECT` as at baseline.
* uhdm2rtlil csv: **ok=9 changed=0 absent=0 unknown-names=28**.
* The 8 / 28 unknown-name counts are the OTHER corpus's canaries and are now
  documented inside the script.
* **NEGATIVE CONTROL OF THE CITED GUARD, RE-RUN:** injecting
  `ZZZ_TYPO_NOT_A_TEST` into `NAMES` makes it appear BY NAME as an eighth
  unknown (`ok=52 ... unknown-names=8` on the pass-52 list). **POSITIVE CONTROL
  RE-RUN:** the real list on a clean surelog csv exits **rc 0**.
* whole families diffed as blocks against the baseline: `Black*` **34 rows
  IDENTICAL**, `EvalFunc`+`ParamFile` **18 rows IDENTICAL**.
* the four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) were NEVER dispatched.

## 10. GATE 5 — the byte verifier, BOTH corpora, every mover explained

Run BACKWARDS, as passes 50-52 did: the POST manifests come from the gate-3 and
gate-4 sweeps; then the HEAD binary was rebuilt HERE from
`git checkout a318ce0 -- src/TypeEmit.cpp src/ExprEmit.cpp` (reproducing
`078eb83a...` exactly) and run into the **SAME workdir paths**. Both HEAD sweeps
reproduced the committed baselines exactly (`ROW DIFFS 0` against both), which
independently validates them as controls.

| corpus | head dbs | post dbs | paired | identical | DIFFER | UNPAIRED |
|---|---|---|---|---|---|---|
| uhdm2rtlil (`testflags`) | 679 | 679 | 679 | **679** | **0** | **0** |
| surelog (`both`) | 953 | 953 | 953 | 946 | **7** | **0** |

Path sets IDENTICAL on both corpora (UNPAIRED 0, now printed explicitly).

**Comparator negative control:** flipping one character of one hash in the u2r
POST manifest makes `bvcompare.sh` report
`identical 678 / DIFFER 1 / MOVER testflags/1DUnpackedArray-.../slang.uhdm`, so a
real difference cannot pass unnoticed.

**The 7 movers are EXACTLY the 7 target rows and NOTHING else:**

```
    [TARGET, and also KNOWN-NONDETERMINISTIC] default/Scoreboard-59431470
    MOVER default/BuildUVMPkg-bf853d43     MOVER testflags/BuildUVMPkg-bf853d43
    MOVER default/SeqDriver-32af76aa       MOVER testflags/SeqDriver-32af76aa
    MOVER default/SimpleUVM-1dc93a62       MOVER testflags/SimpleUVM-1dc93a62
```

**ZERO COLLATERAL MOVERS in either corpus, out of 1632 emitted databases** —
including every one of the 183 u2r `CMP_EQUAL`+dump-differ rows where the CSV
diff is BLIND. That matches pass 52's bar exactly.

`BuildUVMPkg` moved BYTES while its cmp head md5 stayed **identical**: both laws
reach class bodies throughout its 1800.2 `uvm_pkg`, but R1 sits in front of
everything they touch. A byte mover with a stationary head is progress no row
gate can see — the reason gate 5 exists.

## 11. Corrections I made, to my own work and to inherited assets

1. **AN INSTRUMENT BUG I CAUGHT BEFORE IT COST ANYTHING.** My first census
   counted a `class_typespec` as parameter-free whenever the occurrence it
   happened to read printed no children — and uhdm-dump abbreviates repeated
   occurrences. It made golden's `ClassParamAsParam` look like it had 15
   parameter-free `config_db` typespecs when it has TWO objects that both carry
   parameters. `ctsprobe.py` takes the UNION over occurrences and its
   `--selftest` pins it, with the negative control run (§2).
2. **THE BRIEF'S MINT ARITHMETIC, CORRECTED** (§4a): of the four
   `!callStmtCtx0` hier_path mints, pass 52 windowed TWO, not three — the third
   window is on the fifth mint, which is not under `!callStmtCtx0`. Two were
   unwindowed; one of them emits no arguments at all. Same conclusion, right
   count.
3. **`canaries.sh` was not checking four of the brief's own canaries** and its
   header still claimed an `exit 6` the code no longer does. Both fixed, both
   expected unknown-name counts re-measured (§2, §9).
4. **`bvcompare.sh`'s unpaired tail** (pass-52 integration C7) — labelled,
   counted, untruncated.
5. **`gold.sh` did not existence-check `uhdm-cmp`/`uhdm-dump`** (pass-52
   integration C6) — fixed.
6. **NOT FIXED, and flagged rather than glossed:** `heads.sh`'s
   `HEAD_MD5_IDNORM` column hashes the whole cmp file, not the head (pass-52
   integration C5). I did not touch it because every claim I make from it is a
   single-head file measured in one run, which is all it can support — but the
   next pass to see a multi-head file must fix it first.
7. **Numbers I did NOT re-measure and am NOT asserting:** pass 52's R4
   `vpiSigned` census, and any figure about `Earlgrey_0_1` or the Yosys/SVSwitch
   cluster (the other slot's work).
