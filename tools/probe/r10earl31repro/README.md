# r10earl31 — § psBoundPkgParamTs31

**THE HEADLINE, FIRST: `Earlgrey_0_1/default` does NOT convert.** The head this
pass was given is **CLEARED** — the row's first divergence moves off the folded
constant's typespec entirely, onto a *different* object in a *different file* —
but the row stays `CMP_NOTEQUAL`, byte-identical in the CSV to the committed
baseline:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- fresh (patched)
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- results/golden_surelog.csv
```

Row counts are unchanged (`default` **467/13**, not 468/12), so there is nothing
for an integrator to promote and `results/*.csv` were **not** edited.

The head that replaces it is quoted in §6 R1: `dm_mem.sv:365`, where golden
**folds** `dm::DataAddr` to a constant as a *function-call argument* and we keep a
bound `ref_obj`. That is a fold-vs-ref question, not a typespec question — and
this pass's own grid (`e3_pos.sv` p11) had already measured it as a cell.

---

## 0. THE LAW

> **§ psBoundPkgParamTs31 — a constant minted by folding a PACKAGE PARAMETER
> read, which sits (through OPERATIONS ONLY) in a `part_select`'s LEFT or RIGHT
> range, carries a `ref_typespec` whose `Actual_typespec` is THE PARAMETER'S OWN
> DECLARATION TYPESPEC — in every scope, at every operation depth, on either
> bound, whatever the spelling.**

The whole code change is **one block at one call site** (`src/ExprEmit.cpp`,
inside the existing `scope is a Package && symbol is a Parameter` fold branch),
plus **one defaulted parameter** on the existing helper it calls
(`stampFoldedPkgParamTs`, +1 early return) so that helper's two older call sites
stay byte-for-byte unchanged.

**STATED GATE == CODE GATE.** The gate is exactly three things:

1. this is a package-parameter fold (the enclosing `if` — nothing added),
2. `!c->Typespec()` — the constant is still **bare**, so the rule is **purely
   additive** and can never rewrite an existing stamp,
3. walking up through **`uhdmoperation` nodes only** (bounded at 32) reaches a
   `uhdmpart_select`.

There is **no context flag, no view test, no import test, and no text test**.
Two of those absences are load-bearing and were measured, not assumed:

* **No `rawText(...).find("::")` test.** `e4_ctrl.sv` k3 writes the bound through
  a **macro** (`` `WPS `` → `pk::DC`) and golden stamps it; a text test on the
  fold's own source range would have missed it.
* **No `work@`-prefix test on names.** `e4_ctrl.sv` k2 selects out of an
  **escaped identifier** `\d@x ` — a legal SV name that contains the very `@`
  character a name-keyed gate would have keyed on. The hier_path discrimination
  in the fullname is therefore **structural** (`VpiParent()->UhdmType() ==
  uhdmhier_path`), not textual. (The standing rule that demands this was written
  after an escaped `\this` broke a name-keyed gate; here it changed the design.)

Everything the rule does not recognise **keeps its previous answer**, so every
position golden leaves bare abstains by construction — and `e3_pos.sv`, the
position arm, is **byte-identical before and after** (§3.3).

| # | call site | what mints the constant |
|---|---|---|
| 1 | `src/ExprEmit.cpp` ~5248 (`emitExpr`, `NamedValueExpression`, package-parameter fold, immediately before its `return c`) | every module-side fold of a package parameter, qualified or import-resolved |

---

## 1. LOCALIZATION — which field, on which object

Read from the **generated** Compare in `~/git-repos/UHDM`, not guessed.
`build/generated/src/expr.cpp` — `expr::Compare` — reads three fields, and the
typespec is the **third**, before `constant::Compare` ever runs:

```cpp
if ((r = lhs->VpiDecompile().compare(rhs->VpiDecompile())) != 0) { ... }
if ((r = lhs->VpiSize() - rhs->VpiSize()) != 0) { ... }
if ((r = SafeCompare(lhs->Typespec(), rhs->Typespec(), context)) != 0) return r;
```

`build/generated/src/ref_typespec.cpp` — `ref_typespec::Compare` — reads
`VpiName`, `VpiDefName`, `Actual_typespec`. And `BaseClass::Compare` reads
`VpiType`, `VpiName`, `VpiDefName` **and nothing else**. Three consequences that
shaped this pass:

* **`VpiFullName` is NOT compared, anywhere.** The bizarre fullname convention is
  a *byte/dump* obligation, not a cmp one — but this pass matched it exactly
  anyway (§3), because the row's dump is the next metric after cmp.
* **SPANS ARE NOT COMPARED.** `line`/`endln` never enter any `Compare`. This
  matters because our folded constant's span **differs from golden's on every
  qualified read** (golden spans only the `pk::` qualifier, we span the whole
  `pk::DC`) — a real residue (R3), invisible to cmp, and *not* this pass's field.
* A missing `Typespec()` is reported by `SafeCompare` as `RHS: <null>`, which is
  exactly what the row said.

The witness, measured on the target at 63ff1fb with my own pristine build:

```
SOURCE  dm_csrs.sv:408:  abstractauto_d.autoexecdata    = 12'(dmi_req_i.data[dm::DataCount-1:0]);
GOLDEN  constant @408:65-408:69  vpiDecompile:4'h2 vpiSize:4 HEX:2 vpiConstType:5
          +-- vpiTypespec -> ref_typespec (work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data)
                +-- vpiActual -> logic_typespec @25:14-25:25
OURS    constant @408:65-408:78  vpiDecompile:4'h2 vpiSize:4 HEX:2 vpiConstType:5
          (no Typespec at all)  ->  cmp reports `RHS: <null>`
```

**BOTH SIDES CENSUSED SPAN-KEYED BEFORE ANY MISSING-OBJECT CLAIM** (`census31.py`
on the two complete 4.8M/4.6M-line dumps, `sed 1d` both): the constant exists on
both sides with identical value, size and const type; the *only* differences are
the typespec and the span. Nothing here is a `SafeCompare` artefact.

### 1.1 THE BRIEF'S DECODE OF THE FULLNAME IS REFUTED, TWICE

The brief said the ref_typespec's `vpiActual` is *"the `dmi_req_i.data` MEMBER's
declared type"* and that the fullname *"EMBEDS the SIBLING line 407 select text"*.
Both are wrong, and the second is a line-off transcription:

* `logic_typespec @25:14-25:25` is **`dm_pkg.sv:25`**, not `dm_csrs.sv:25`:
  `localparam logic [3:0] DataCount = 4'h2;` — columns 14..25 are exactly
  `logic [3:0]`. It is **the folded parameter's own declared type**. (`dm_csrs.sv:25`
  is `input logic testmode_i` — not the member type either.) The sibling line 409
  proves it independently: its stamp points at `logic_typespec @22:14-22:25` =
  `localparam logic [4:0] ProgBufSize = 5'h8;`, one line per parameter.
* The `data[4'h2 - 1:0]` text in the fullname is **line 408's OWN select**, not
  line 407's. The brief's source quote for 408 is line 409's text; 407 is
  `abstractauto_d = 32'b0;`. The convention is mundane once the line is right:
  **scope prefix + the select's own fullname + the select's own member name**.

---

## 2. THE MECHANISM — why the existing rules could not reach it

This codebase already had **eleven** context flags that stamp a folded
package-parameter read, and one of them, `§ caPartSelBoundFoldTs`, is the same
law for a cont-assign. Two independent reasons it missed the witness — both
**measured on `e1_psbound.sv`**, not inferred:

1. **Scope.** `psOwner9` is gated `!inProcessEmit && !currentTf && !ndaRhsEmit`,
   and its walk is **one** operation deep. `dm_csrs.sv:408` is inside an
   `always_comb` (one op deep) and `:409`'s bound `dm::ProgBufSize-1+16` is **two**
   ops deep (`op24` over `op11`).
2. **The import test.** Every stamping arm requires
   `importedParamDefTs.count(&nv.symbol)` — the parameter must have been
   **materialized into this module by an import**. `dm_csrs.sv` contains **no
   `import` at all**; every `dm::` read there is qualified. `e1` o11 isolates
   this: even the **cont-assign** bound, which the existing rule was written for,
   stays bare without an import while golden stamps it.

So the fix is not a new heuristic: it is the **one missing position** in a law
this repo already transcribes elsewhere, with the typespec taken from the object
`stampFoldedPkgParamTs` was already built to produce (§3.2 shows that object is
right for five of six origins, and the sixth abstains).

**earl30's R5 hypothesis is REFUTED for this cell.** R5 said "the folded
parameter VALUE may be wrong upstream, with the typespec following". Measured
first, as the brief instructed: our value is `HEX:2`, size 4, decompile `4'h2`,
const type 5 — **identical to golden in every field**. There was nothing upstream
to fix; the typespec does not arrive free, and it had to be attached.

---

## 3. THE GRID, CELL FOR CELL

Four arms, `arm31.sh` (LHS always golden, `sed 1d` both dumps, binary md5 printed
on every run, missing database fatal, each arm in its own scratch dir). The
instruments are `tsread.py` (the dump reader, with the r10earl30 §7 subtree-skip
defect encoded and a `--selfcheck` control that RUNS), `census31.py` (constants
cross-tabbed by POSITION × has-typespec) and `cells31.py` (**every** cell of a
position, both sides, multiplicity kept).

```
$ python3 tsread.py --selfcheck
SELFCHECK reader: constants=1 top=1 ct='7' ts='ref_typespec(work@g1_ctx)->int_typespec@59:14-59:17'
SELFCHECK: PASS (a vpiConstType AFTER a nested ref_typespec must be READ, the
                 ref_typespec must be FOUND, and the stub constant under
                 vpiParent must NOT be counted as a top-level constant)
```

### 3.0 THE ONE-LINE RESULT

```
arm            cmp lines (head depth)   dump-diff sides   patch effect on OUR dump
e1_psbound      17  ->   0  PASS_CMP     498 -> 428        +98 lines, 0 removed  (14 stamps)
e2_origin      267  -> 267  (unrelated)  804 -> 780        +36 lines, 0 removed  ( 6 stamps)
e3_pos         100  -> 100  (unrelated)   71 ->  71        NO LINES CHANGED AT ALL
e4_ctrl         17  ->   0  PASS_CMP     474 -> 429        +63 lines, 0 removed  ( 9 stamps)
```

**Two arms go to `PASS_CMP` (cmp-equal, whole database), the position arm is
byte-identical, and the patch REMOVES NO LINE ANYWHERE** — the rule is additive
by construction (gate 2 of §0).

### 3.1 e1_psbound — POSITION-IN-THE-SELECT, SCOPE and OPERATION DEPTH

Origin held at the witness's (a `logic [3:0]` package localparam read **qualified,
in a module with no import**). Golden stamps **12 of 12** folds and every literal
bound stays bare. After the patch our fullname and actual typespec match golden
**exactly** in all 12:

| cell | source | ops | golden ref_typespec | ours before | ours after |
|---|---|---|---|---|---|
| o1 40:21 | `r.data[pk::DC-1:0]` — **THE EARLGREY WITNESS** (hier_path + cast) | 1 | `work@e1.blk.r.data[4'h2 - 1:0].data` → logic_ts 23:14 | bare | **exact** |
| o2 41:21 | `r.data[pk::PB-1+16:16]` — **the dm_csrs.sv:409 shape** | **2** | `...r.data[5'h8 - 1 + 16:16].data` → logic_ts 24:14 | bare | **exact** |
| o3 42:16 | `d[pk::DC-1:0]` plain select | 1 | `work@e1.blk.d` | bare | **exact** |
| o4 43:16 | `d[pk::DC:0]` **bare bound** (parent IS the select) | **0** | `work@e1.blk.d` | bare | **exact** |
| o5 44:18 | `d[7:pk::DC]` — **the RIGHT bound** | 0 | `work@e1.blk.d` | bare | **exact** |
| o6 45:16 + 45:25 | `d[pk::DC+4:pk::DC]` — **both bounds at once** | 1 / 0 | `work@e1.blk.d` ×2 | bare ×2 | **exact ×2** |
| o7 46:12 | no cast around the select | 1 | `work@e1.blk.d` | bare | **exact** |
| o8 47 | `d[$clog2(pk::DC)+1:0]` — **NEGATIVE CONTROL** | — | **no stamp** (the arg fold is a `sys_func_call/vpiArgument`, bare on both sides) | bare | **bare** |
| o9 51:16 | **unnamed** `always_comb` | 1 | `work@e1.d` (no block component) | bare | **exact** |
| o10 55:16 | inside a **function body** | 1 | `work@e1.f1.w` | bare | **exact** |
| o11 58:21 | **cont_assign**, qualified, no import (def + elab, ×2) | 1 | `work@e1.d` ×2 | bare ×2 | **exact ×2** |
| o12 70:21 | hier_path select, **bare bound** | **0** | `work@e1.blk2.r.data[4'h2:0].data` | bare | **exact** |
| o13 71:23 | hier_path select, **RIGHT bound** | 0 | `work@e1.blk2.r.data[7:4'h2].data` | bare | **exact** |

o12/o13 were **added after the first patched run**, because the first fullname
formula (`prefix + "." + select name`) was **built and measured WRONG**: `prefix`
is not the statement's scope at this point — the emitter descends into a range
*through the select*, so a bound one operation deep already carries the select's
own fullname as its prefix, and the rebuild doubled the last component
(`work@e1.blk.d.d`, 8 cells across e1 and e4). The shipped formula uses the plain
select's fullname **verbatim** and brackets only the hier_path case; o12/o13 exist
to hold that hier_path branch at zero operation depth and on the right bound
instead of assuming it generalizes from o1.

### 3.2 e2_origin — the ORIGIN axis, and WHAT THE TYPESPEC POINTS AT

Position held at the witness's (part-select left bound, one op, in a process).
**Golden's `vpiActual` is the PARAMETER'S OWN DECLARATION TYPESPEC in every
stamped cell**, and the kind follows the declaration:

| cell | origin | golden actual | ours after | verdict |
|---|---|---|---|---|
| c1 37:16 | pkg localparam `logic [3:0]` | `logic_typespec@20:14-20:25` | same | **MOVER, exact** |
| c2 38:16 | pkg localparam `int` | `int_typespec@21:14-21:17` | same | **MOVER, exact** |
| c3 39:16 | pkg localparam **implicit** (`localparam UC = 3;`) | `int_typespec@22:3-22:39` — the **whole ParameterDeclaration** span | same | **MOVER, exact** |
| c4 40:16 | pkg localparam `logic signed [3:0]` | `logic_typespec@23:14-23:32` | same | **MOVER, exact** |
| c5 41:16 | pkg localparam of a **typedef'd** type (`w_t`) | `logic_typespec@19:11-19:22` (the **typedef's** object) | **bare** | **ABSTAINS** — R2 |
| c6 42:16 | **package ENUM literal** (`pk::E2`) | **no stamp** | bare | **must not move — did not** |
| c7/c8 43,44 | module localparam / module parameter | *no constant at all* (never folded in the def view) | — | unreachable by construction |
| c9 | **function-local** localparam | *no constant* | — | unreachable |
| c12 45:16 | a plain sized **literal** bound `4'h2` | **no stamp** | bare | **must not move — did not** |
| c10 64:16 | **unqualified** read through `import pk::*` | `logic_typespec@20:14-20:25` | already stamped **before** this pass | untouched (gate 2) |
| c11 65:16 | **qualified** read in a module that ALSO imports pk | `logic_typespec@20:14-20:25` | bare → **MOVER, exact** | the import does not suppress it |

c5 is the pass's one detected **abstention**, and it is deliberate. Our `pk::TC`
*parameter object* carries the right `ref_typespec` → `logic_typespec (w_t)
@19:11-19:22` — byte-identical to golden — but at the moment the module-side fold
runs, that object is not reachable through `pkgParamObj` with a resolved
`Actual_typespec`, so the helper's fallback would have minted an
`int_typespec@24:14-24:17`: **a WRONG object where golden has the typedef's
`logic_typespec`, replacing a missing object with a wrong one.** That is what the
new `declTsOnly` parameter refuses. It was **caught by the arm after the first
patched build** (the cell read `int_typespec@24:14-24:17` vs golden
`logic_typespec@19:11-19:22`) and fixed before landing; e2's added-line count
dropped 44 → 36 when the abstention went in.

### 3.3 e3_pos — THE POSITION AXIS, AND THE OVER-FIRE CONTROL

Origin and scope held at the witness's; only the position varies. **Golden's
answer is a select-WIDTH rule, not a "folded constant" rule** — and our patch
changes **nothing** in this arm (0 dump lines, before == after, byte for byte):

| cell | position | golden | ours (before == after) |
|---|---|---|---|
| p1 43:16 | `d[pk::DC]` — **bit_select INDEX** | **bare** | bare ✓ |
| p2 44:21 | hier_path bit_select index | **bare** | bare ✓ |
| p3 45:16 | `d[pk::DC +: 4]` — ips **BASE** | **bare** | bare ✓ |
| p4 46:21 | `d[0 +: pk::DC]` — ips **WIDTH** | **STAMPED** `work@e3.blk.d` → logic_ts 22:14 | bare — **R2, not shipped** |
| p5 47:10 | assignment RHS, directly | bare | bare ✓ |
| p6 48:10 | assignment RHS, one op deep | bare | bare ✓ |
| p7 49:11 | **replication COUNT** | bare | bare ✓ |
| p8 50:15 | concat element | bare | bare ✓ |
| p9 52:7 | **case ITEM** | bare | bare ✓ |
| p10 55:14 | if condition | bare | bare ✓ |
| p11 59:13 | **function-call ARGUMENT** | bare **constant** | **no constant at all** — R1, **the row's next head** |
| p12 60:17 | sys-func argument | bare | bare ✓ |
| p13 35:10 | `logic [pk::DC-1:0] v;` — a **declaration typespec** range bound (Surelog folds the WHOLE bound to one `INT:1`) | bare | bare ✓ |
| p14 62:25 | for-loop condition | bare | bare ✓ |

Two readings worth stating plainly. First, the discriminator is **not** "is it a
fold?" — every cell here is the same fold of the same parameter. It is
**where the fold determines the SELECT'S WIDTH**: both `part_select` bounds and
the `+:` width are stamped, the `+:` base and the bit_select index are not.
Second, golden's **span** discriminates with it: every stamped **parameter** fold
spans only the `pk::` qualifier (4 chars, `46:21-46:25`), while every bare
parameter fold spans the whole `pk::DC` (6 chars, `43:16-43:22`, `47:10-47:16`,
`60:17-60:23`) — so Surelog mints the two classes in different code, which is the
strongest independent evidence that the POSITION gate is the real one. (The
exception is not a counterexample: an **enum-literal** fold, e2 c6, carries the
4-char span and no stamp — it is a copy of the `enum_const`, r10earl30's law, a
different origin entirely.)

### 3.4 e4_ctrl — VIEW MULTIPLICITY, ESCAPED IDENTIFIERS, MACROS

| cell | what | golden | ours after |
|---|---|---|---|
| k1 36:16 | child module instantiated **twice** | stamped, def listing | **exact** |
| k6 63:18 | a process in a **generate scope** | stamped **×3**: `work@e4.gblk.ginner.d` (def) + `gblk[0]` + `gblk[1]` (elab) | **exact ×3** |
| k2 37 | select out of an **escaped identifier** `\d@x ` | `work@e4child.blk@1.d@x` (backslash and trailing space dropped, in an **escaped block name** too) | **exact name** (the constant's own span differs — pre-existing, R4) |
| k3 38:16 | bound written by a **MACRO** | stamped | **exact** |
| k4 39:18 | hier_path select, **nested struct** member | `work@e4child.blk@1.o.a[4'h2 - 1:0].a` | **exact** |
| k5 45:16 / 68:15 | `always_ff` (unnamed) / `initial` | `work@e4child.d` / `work@e4.d` | **exact** |
| k7 40 / 41 | **module localparam** bound / **literal** bounds | never folded / bare | unchanged — the arm ends with **22 bare part-select-range constants on each side, golden 22 / ours 22**, and the arm's dump delta has **0 removed lines** |

k6 settles the def/elab question the brief's precedent
(`§ elabConnSelFoldNoTs21`, where golden stamps the def view and NOT the elab
one) made mandatory to measure: for THIS position golden stamps **every** copy,
and so do we.

---

## 4. THE CENSUS AND THE PREDICTION, BOTH RUN BEFORE CODING

The brief's instruction was explicit: a typespec-attachment law can reach every
folded constant, so census golden's policy first and predict the movers from
source-derived data. Two instruments, both run on the pristine build.

**(a) The whole-design POLICY CENSUS** (`census31.py`, complete dumps, `sed 1d`
both, join key = nearest named ancestor + START span + decompile, because the
spans themselves disagree by construction):

```
POSITION                            g:TS   g:bare     o:TS   o:bare      joined verdict
part_select/vpiLeftRange             327     3291      228     3291      TS_GOLDEN_ONLY = 2   <== THE PREDICTED MOVER SET
part_select/vpiRightRange            110     3157      118     3155      TS_GOLDEN_ONLY = 0
indexed_part_select/vpiWidthExpr     234      241      298      327      TS_GOLDEN_ONLY = 10  (R2)
indexed_part_select/vpiBaseExpr       81      718       27      716      TS_OURS_ONLY   = 2
bit_select/vpiIndex                 2046    12455       54    12123      TS_GOLDEN_ONLY = 0
param_assign/vpiRhs                14328    16075    13187    16066      TS_GOLDEN_ONLY = 1
... 136822 golden constants, 131483 ours
```

**The prediction: exactly TWO objects on the target design**, and the census names
them — `408:65` and `409:65`, both `part_select/vpiLeftRange`, both `stmt=process`,
at operation depth 1 and 2. **Checked after coding, on the same instrument:**

```
part_select/vpiLeftRange   TS_GOLDEN_ONLY  2 -> 0        ours TS 228 -> 230, ours bare 3291 -> 3289
part_select/vpiLeftRange   TS_BOTH same  145 -> 147      (the two new stamps land ON golden, fullname included)
every other cell            UNCHANGED, including all 15 pre-existing ips/base residues
```

Exact, in both directions, with no new `TS_OURS_ONLY` cell anywhere.

**(b) The SOURCE-DERIVED corpus fence** (`pred31.sh`, run on both corpora's
sources): the law can only touch a test that contains a **range select** whose
bound names something other than a literal — `A` a bound containing `::`, `B` a
bound with an identifier in a file that wildcard-imports a package.

```
uhdm2rtlil test tree          1886 files   A=1    B=37     -> 17 candidate test dirs
Surelog tests                  824 files   A=8    B=32
Surelog third_party/tests    11776 files   A=215  B=1002   -> 65 candidate test dirs
```

That is a deliberately loose **upper bound** (it cannot tell a package parameter
from a module localparam and it does not parse) — the point is that it is
falsifiable: **every measured mover must be inside it.** The one measured mover,
`Earlgrey_0_1`, is in the `A` list. 0 of the 17 u2r candidates moved.

---

## 5. EVERY MOVER ATTRIBUTED, PER SHAPE, BY MULTISET

Byte movers, both corpora, against my own pristine 63ff1fb build:

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 1 / 953
             SELFCHECK 952/953 flagged        SELFCHECK1 = 2  (= 1 real + 1 injected)
             MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
```

**ONE mover in 1632 databases, and it is the target row.** `Scoreboard` — the
per-run-instability row that cost r10earl29 and r10earl30 a paragraph each — did
**not** move this time.

`mv31.sh` (r10earl30's `mv30.sh`, carried forward) takes the **multiset delta** of
dump lines with indentation stripped and looks every distinct changed shape up in
**golden** with a per-shape `grep -Fxc`, ADDED and REMOVED separately, with a
`SELFCHECK=1` fabricated-shape control:

```
== Earlgrey_0_1/default: ADDED instances=14 over 11 shapes; REMOVED instances=0 over 0 shapes
  ADDED   x1 golden=2      ok         \_ref_typespec: (work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data)
  ADDED   x1 golden=2      ok         \_ref_typespec: (work@dm_csrs.csr_read_write.dmi_req_i.data[5'h8 - 1 + 16:16].data)
  ADDED   x1 golden=1      ok         |vpiFullName:work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data
  ADDED   x1 golden=1      ok         |vpiFullName:work@dm_csrs.csr_read_write.dmi_req_i.data[5'h8 - 1 + 16:16].data
  ADDED   x1 golden=26     ok         \_logic_typespec: , line:25:14, endln:25:25
  ADDED   x1 golden=17     ok         \_logic_typespec: , line:22:14, endln:22:25
  ADDED   x2 golden=91157  ok         |vpiTypespec:            <- BARE FIELD LINE, non-attributable absorber
  ADDED   x2 golden=233938 ok         |vpiActual:              <- BARE FIELD LINE, non-attributable absorber
  ADDED   x2 golden=723816 ok         |vpiParent:              <- BARE FIELD LINE, non-attributable absorber
  ADDED   x1 golden=0      OVER-FIRE  \_constant: , line:408:65, endln:408:78
  ADDED   x1 golden=0      OVER-FIRE  \_constant: , line:409:65, endln:409:80
  ADDED   x1 golden=0      OVER-FIRE  \_FABRICATED_SHAPE_r10earl31  <- the CONTROL, correct
  ADDED  : 9 covered, 2 OVER-FIRE (+ the fabricated one)
  REMOVED: 0 correct, 0 UNDER-FIRE
```

**The four sharp shapes — two `ref_typespec` headers with their exact fullnames
and two `logic_typespec` headers — are each present in golden.** The three bare
field lines are named as what they are: **non-attributable absorbers**, whose
multiplicity is a whole-database aggregate once indentation is stripped, so they
are never allowed to stand as an attribution.

### 5.1 THE TWO `OVER-FIRE` FLAGS ARE THE KNOWN SPAN RESIDUE, NOT NEW OBJECTS

Stated plainly, and counted rather than argued. The flagged shapes are the
`|vpiParent:` **stubs** `uhdm-dump` prints *inside* the new `ref_typespec` — the
constant they point at is the one that was already there:

```
                          "…408:65, endln:408:78"   "…408:65, endln:408:69"
golden  g.dump                    0                          2   (real object + its stub)
ours before o.dump                1  (real object)            0
ours after  q.dump                2  (real object + stub)     0
```

No object was created: **one print of one pre-existing object was added**, at a
span that already disagreed with golden before this pass (R3). Golden holds the
identical pair at *its* span. The span is not a compared field, and correcting it
is a different law on a different field (R3).

**The span-keyed attribution is the real one**, and it is exact on both:

| span | source | golden | ours before | ours after |
|---|---|---|---|---|
| 408:65 | `dm_csrs.sv` `12'(dmi_req_i.data[dm::DataCount-1:0])` — **THE WITNESS** | `ref_typespec(work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data)` → `logic_typespec@25:14-25:25` | `<bare>` | **byte-identical to golden** |
| 409:65 | `dm_csrs.sv` `16'(dmi_req_i.data[dm::ProgBufSize-1+16:16])` — **two ops deep** | `…data[5'h8 - 1 + 16:16].data` → `logic_typespec@22:14-22:25` | `<bare>` | **byte-identical to golden** |

**2 movers, 2 landing exactly on golden, 0 moved away, 0 over-fire.**

Whole-design multiset distance to golden (`msdist.sh` @7c7eaa6, md5
`7c0d46b5da124cfe37d27eddc95eb7e7`): **309589 → 309579 (−10)**; golden-only
instances 239082 → 239070 (−12), ours-only 70507 → 70509 (+2, the two stub
lines). Dump length 4,654,873 → 4,654,887 (+14) against golden's 4,823,448.

### 5.2 WHAT THIS PASS REFUTED

* **The brief's decode of the typespec's target** ("the `dmi_req_i.data` MEMBER's
  declared type") and **of the fullname** ("embeds the SIBLING line 407 select
  text"). Both wrong; §1.1 gives the measured answer from two cells and the
  line-off that caused it. Had I transcribed the member type, `ref_typespec::Compare`
  would have failed on `Actual_typespec` and the head would have stayed.
* **earl30's R5** ("fixing the folded parameter VALUE gives the const type free —
  check whether the VALUE matches golden first"). Checked first, as instructed:
  the value matches golden in every field at both witness sites. R5 is real for
  *its* cells (e2 c6/c7 of earl30) and irrelevant to this head.
* **"A typespec-attachment law can reach every folded constant."** Measured: it
  reaches **2 objects** on the target, **0** of 679 u2r rows and **0** of the other
  952 surelog rows. The position gate, not the origin gate, is what makes it
  narrow — and `e3_pos.sv` is the byte-identical proof.
* **My own first fullname formula**, which was `prefix + "." + select name` and
  doubled the last component on 8 cells (§3.1). Caught by the arm, before the
  gates, because the arm prints every cell rather than the head.
* **My own first typespec source**, which silently minted an `int_typespec` for a
  typedef-typed parameter (§3.2 c5). Caught the same way, and turned into an
  explicit abstention rather than a wrong object.

---

## 6. RANKED RESIDUES

Ranked by measured reach on a real row, most valuable first.

**R1 — `Earlgrey_0_1/default`'s NEW head: golden FOLDS a package parameter passed
as a FUNCTION-CALL ARGUMENT; we keep a bound `ref_obj`.** `dm_mem.sv:365`:

```
SOURCE  abstract_cmd[2][63:32] = dm::load(ac_ar.aarsize, 5'd8, 5'd10, dm::DataAddr);
LHS(golden)  constant @365:75-365:87  vpiDecompile:12'h380 vpiSize:12 HEX:380 vpiConstType:5
               parent func_call (dm::load) @365:38  — and NO typespec on it
RHS(ours)    ref_obj (dm::DataAddr) @365:75-365:79
               vpiActual -> parameter (dm::DataAddr) @34:27  (dm_pkg.sv:34, `logic [11:0] DataAddr = 12'h380`)
```

Already a measured cell of this pass: `e3_pos.sv` **p11**, where golden has a bare
constant and we have **no constant at all**. It is a **fold-vs-ref** law on
`vpiDecompile`/object kind, not a typespec law, so it is squarely outside this
pass's field — and it is **the next thing to look at for this design**. Proved
pre-existing: this patch's entire effect on this database is the 14 added lines of
§5, none at `dm_mem.sv:365`.

**R2 — the `indexed_part_select` WIDTH is the same law, one position over. 10
objects on the target, 1 arm cell (`e3_pos.sv` p4).** Golden stamps
`d[0 +: pk::DC]`'s width fold exactly as it stamps a part-select bound; we leave
it bare (and, separately, we stamp 3 ips-width + 2 ips-base folds golden leaves
bare, all in elaborated port connections). The shipped gate deliberately tests
`uhdmpart_select` only, so this abstains by construction. **The fix is one
`UhdmType()` alternative at the site this pass touched** plus the fullname
question re-measured for `indexed_part_select` — but its 10 target objects sit in
the ELAB view under port connections, where the census also shows a pre-existing
`ref_typespec()` with an EMPTY fullname and an unlocated `int_typespec`, so it
needs its own arm and was not censused for corpus reach here.

**R3 — the SPAN of a folded QUALIFIED package-parameter read.** Golden spans only
the scope qualifier (`pk::`, 4 chars: `408:65-408:69`), we span the whole
`pk::DC` (`408:65-408:78`). Measured on every stamped cell of every arm, and on
an **unqualified** read (e2 c10) the two sides AGREE — so the rule is about the
qualified spelling. Invisible to `uhdm-cmp` (no `Compare` reads a span), but it is
a real dump/byte residue and it is the sole remaining difference on all 12 e1
cells. It also explains §5.1's two flags. A pure-span law, one field, one site.

**R4 — an escaped-identifier select is positioned differently on the two sides.**
`e4_ctrl.sv` k2: golden's part_select for `\d@x [pk::DC-1:0]` puts the bound
constant at `37:24-37:28`, ours at `37:20-37:26` — a whole-object span shift, not
just an end column. Both sides now carry the SAME ref_typespec name and actual,
so cmp is clean; the byte residue remains. Pre-existing, unchanged by this pass.

**R5 — a typedef-typed package parameter's declaration typespec is not reachable
from the module-side fold.** §3.2 c5. Our own `parameter` object has the right
`ref_typespec` → the typedef's `logic_typespec`; `pkgParamObj` does not hand it
over with a resolved `Actual_typespec` at fold time, so the rule abstains rather
than mint a wrong `int_typespec`. Fixing the lookup (or resolving the alias
earlier) would land one more grid cell and needs no new measurement of the law.
Belongs to the campaign-memory *typespec-linkage* cluster.

**R6 — `param_assign/vpiRhs` has 1 golden-only typespec left on the target**, at
a package parameter whose value ALSO disagrees (`golden INT:0 sz32 ct7` vs
`ours UINT:0 sz64 ct9`, span `60:28-60:38` vs `60:28-60:29`) — i.e. earl30's R5
shape, value first, typespec second. Untouched here (different position,
different field).

---

## 7. THE FIVE GATES, each with the number I measured

Binary under test `00ec475cf42b95b0bcbcf570e1842643`, built at
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl31/build`.

### GATE 1 — BUILD

`grep -c "Linking CXX executable slang-uhdm"` = **1** (a build that compiles
nothing still exits 0, so the link line is the check); `grep -icE "error:"` = **0**.
The md5 assertion ran as a **SEPARATE command**, with the baseline validated as
32 hex characters first:

```
baseline OK 32 hex: 839ca7d61e574b269300ed4b7518a095
FINAL=00ec475cf42b95b0bcbcf570e1842643
MD5 CHANGED: PASS
```

The baseline is not asserted, it is **reproduced**: my patch worktree's unpatched
build, my pristine worktree's build and the main tree's 63ff1fb binary are all
`839ca7d61e574b269300ed4b7518a095` — three independent bit-for-bit builds.

### GATE 2 — GOLDENS

`check_goldens.sh` **defaults `SLANG_UHDM` to the MAIN TREE**, so it was pinned:

```
SLANG_UHDM=<my build>  ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false  ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match  183 differ  52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default   225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

`Earlgrey_0_1/default` does **NOT** convert — `default` stays **467/13**, not
468/12, and the row is quoted at the top of this file. `results/*.csv` untouched.

My **pristine** sweeps reproduce both committed baselines at **0 differing rows**
each, which is what makes GATE 5's byte comparison meaningful.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine 63ff1fb

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 1 / 953
             SELFCHECK 952/953 flagged        SELFCHECK1 = 2  (= 1 real + 1 injected)
```

The single mover is attributed per shape against golden by **multiset** in §5:
`Earlgrey_0_1/default` = 2 objects, both landing exactly on golden, 0 removed
lines, and the two flagged shapes explained by count in §5.1.

### CANARIES

| check | corpus | result |
|---|---|---|
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=6` | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown-patterns=6 → PASS |
| `r10oth7repro/ctcan2.sh`, `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown-patterns=1 → PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** (named explicitly — several files share that basename) | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 (expected for a u2r csv) |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | ok=52 **changed=0 absent=0** unknown-names=7 (the u2r-only canaries) |
| `r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** → PASS |

BY NAME on the surelog csv:

```
InterfaceModPort    default   CMP_EQUAL/differ      InterfaceModPort   testflags CMP_EQUAL/differ
BlackParrotComplex  default   CMP_EQUAL/differ      BlackParrotComplex testflags CMP_EQUAL/differ
SVSwitch            default   CMP_NOTEQUAL/         Earlgrey_0_1       default   CMP_NOTEQUAL/
```

`UnsignedParam`, `HierPathEval`, `FileLocalParam` and `TopParam` were **not
dispatched by any driver** (asserted by `canaudit.sh`, FENCE-BREACH=0).

### BOUNDARIES

**No collision.** `r10svs5` owns clocking-block path components in `hier_path`s
and `r10uvm59` owns type-parameter scoped-call `ref_obj`s. This pass creates
`ref_typespec` objects only, on `constant`s, and reads a `hier_path`'s **type**
(never its name, contents or components) as one structural test. `SVSwitch` is
byte-unchanged (both modes still `CMP_NOTEQUAL`, and it is not in the mover list);
no `ref_obj` is created, deleted or re-bound anywhere in the diff.

---

## 8. THE DRIVERS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm31.sh` | one arm's golden + ours + dumps + cmp; **prints the binary's md5**, existence-checks all four tools, `sed 1d` on both dumps, missing database = fatal, each arm in its own scratch dir |
| `tsread.py` | the dump-tree reader: constants with their typespec, the r10earl30 §7 subtree-skip trap encoded, back-reference stubs marked, `--selfcheck` control that RUNS |
| `census31.py` | **THE POLICY TABLE**: every constant cross-tabbed by (POSITION, has-typespec), plus the span-keyed join with `--pairs` / `--cell` |
| `cells31.py` | per-cell table, **every** cell of a position, both sides, multiplicity kept, golden always argv[1] |
| `pred31.sh` | **the SOURCE-DERIVED mover fence** — the candidate row set computed from the corpus sources alone, run before the patch was measured |
| `mv31.sh` | per-shape mover attribution against golden by multiset, ADDED/REMOVED separately, `SELFCHECK=1` fabricated-shape control, bare field lines named as non-attributable |
| `e1_psbound.sv` | POSITION-IN-THE-SELECT × SCOPE × OPERATION DEPTH — 13 cells incl. the witness, both bounds, function body, cont_assign, and the sys-func negative control |
| `e2_origin.sv` | ORIGIN — 12 origins in one position, incl. the enum-literal and literal-bound negative controls and the import/qualification 2×2 |
| `e3_pos.sv` | **THE OVER-FIRE CONTROL** — 14 positions, origin held fixed; the patch changes ZERO lines here |
| `e4_ctrl.sv` | view multiplicity (def + 2 elab + gen scope), ESCAPED identifiers, a MACRO-written bound, nested-struct hier_path, `always_ff`/`initial`, module-localparam and literal bounds |

Reused unchanged: `r10uvm55repro/{msdist.sh,canaudit.sh}` (msdist pinned at
`7c7eaa6`, md5 `7c0d46b5da124cfe37d27eddc95eb7e7`), `r10oth6repro/byteverify.sh`,
`r10oth7repro/ctcan2.sh`, `r10oth8repro/ct8rows.sh`,
`r10uvm52repro/canaries.sh`. `scripts/verify_golden.py` and
`tests/check_goldens.sh` were **not** modified.
