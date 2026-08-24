# r10uvm117 — § `pkgFreeSubRefVarHoistNet117` — **SURELOG'S LATE-BINDING POOL IS NOT A CLASS MECHANISM: A FREE PACKAGE FUNCTION'S OR TASK'S `ref_var` LOCAL HOISTS THE SAME IMPLICIT WIRE AN OUT-OF-BODY METHOD'S DOES** — the SimpleUVM ×2 **17-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `7fb7d67` |
| worktree | `/tmp/wt_r10uvm117` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `7fb7d67` BYTE FOR BYTE (md5 `cc1dcd48920298639c02a3371750f62a`) — frozen `chmod 555` before any sweep |
| patched binary | md5 `b778b33088c6d70540626300cb53aa19`, frozen `chmod 555`. An INTERMEDIATE build (`25ead49d5fb17f36f1729fd01b4f0dec`, the law without §4's mint-order staging) is kept ONLY as the null control in `ATTRIB.file.txt` |
| production surface | `include/UhdmExporter.h` (the law + two members + one 3-line accessor), `src/TaskFuncEmit.cpp` (the member's ONE setter and its reset), `src/ExprEmit.cpp` (the predicate's FIRST conjunct, the pool push's home argument and its staging vector, and the two-vector back-patch), `src/ParamEmit.cpp` (the staged entries' ONE flush point) |
| probe surface | `tools/probe/r10uvm117repro/` only |

## READ THIS FIRST — the numbers

`rowheads.sh` on this pass's OWN pristine and patched sweeps, same instrument
both times:

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **17** | **56** | 1 — a **NEW** head, a different object, and it is **byte-identical (ids aside) to SeqDriver's** |
| SeqDriver default / testflags | 56 | 56 | 1 unchanged, head text BYTE-IDENTICAL |
| Scoreboard default | 56 | 56 | 1 unchanged, head text BYTE-IDENTICAL |
| MiniAmiq default / testflags | 56 | 56 | 1 unchanged, head text BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 56 | 56 | 1 unchanged, head text BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 36 | 36 | 1 unchanged, head text BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes; CMP_NOTEQUAL stays 19) | |
| byte movers | — | **4 / 956** surelog — exactly the four PREDICTED BY NAME — and **0 / 1358** uhdm2rtlil. Every mover adds NINE dump lines and removes none | |
| the implicit-net population, 9 UVM DBs | 6 golden-only NAMES in each of 4 DBs | **5** — `p` gone, the other five are other laws' | |
| the corpus FENCE, after | HIT **4** | **HIT 0**, MIRROR still **0** — the family CLOSED corpus-wide | |
| ours-only implicit-net names | `clp`, `top` | **the identical set** — no widening | |
| direction, 9 UVM DBs | — | **4 NET cells + 4 REF cells TO-GOLDEN, 0 AWAY-GOLDEN**, over 526 net cells and 444,283 reference cells | |

The 17-line head this pass cleared is `head_pris_default_SimpleUVM.cmp`; the new
one is `head_pat_default_SimpleUVM.cmp` (56 lines, §7 R0).

## 1. THE HEAD, CONFIRMED FROM `BaseClass.h` AND FROM BOTH DUMPS FIRST

The whole 17-line head, verbatim from the pristine cmp log:

```
LHS:
decompile:
logic_net: (work@top.p), line:263:3, endln:263:4
|vpiParent:
\_module_inst: work@top (work@top), file:.../SimpleUVM/testbench.sv, line:44:1, endln:71:10
|vpiName:p
|vpiFullName:work@top.p
|vpiNetType:1
RHS: <null>
```

`LHS` printing in full with `RHS: <null>` is the **SINGULAR** `SafeCompare`
overload's `lhs != nullptr && rhs == nullptr` arm
(`~/.local/include/uhdm/BaseClass.h:187-193`); the VECTOR overload
(`:202-224`) would have named the whole `module_inst::Nets` CONTAINER, not one
net. **The field is `ref_obj::Actual_group`, not `module_inst::Nets`** — read
off both `uhdm-dump`s and off the census, not assumed: the carrier is golden's
`ref_obj (p)` @263:3 in the **`uhdmtopPackages`** copy of `uvm_pkg`, whose
`vpiActual` IS that net; ours carries none, and our `work@top` holds no net of
that name at all. `design::Compare`
(`~/git-repos/UHDM/build/generated/src/design.cpp:296-302`) walks `AllPackages`
→ `TopPackages` → `AllModules`, so the reference is reached long before any
module's net list.

Source — `uvm-1.2 base/uvm_globals.svh`, and the routine is a **FREE PACKAGE
FUNCTION**, not a class method (its own header comment says "defined in package
scope"):

```systemverilog
function void uvm_process_report_message(uvm_report_message report_message); // :259
  uvm_root top;                                                              // :260
  uvm_coreservice_t cs;                                                      // :261
  process p;                                                                 // :262  <- § 115 makes this a ref_var
  p = process::self();                                                       // :263  <- THE HEAD's reference
  cs = uvm_coreservice_t::get();
  top = cs.get_root();
  top.uvm_process_report_message(report_message);
endfunction
```

The reference the wire is stamped from is the **Lhs of an ordinary assignment**
at `263:3-263:4` — the net carries the REFERENCE's span
(`UhdmWriter.cpp:3982-4004`), and 263:3 is `p`'s only appearance in the whole
function.

## 2. THE LAW

> **§ `pkgFreeSubRefVarHoistNet117`** — *Surelog's late-binding pool is not a
> CLASS mechanism. `UhdmWriter::lateBinding`
> (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:3374`) walks the
> REFERENCE's own `VpiParent` chain (`:3359-3360`), and its `uhdmfunction`
> (`:3371-3436`) and `uhdmtask` (`:3437-…`) arms are reached by EVERY
> subroutine body alike — a class's OUT-OF-BODY method (§
> `oobRefVarLocalHoistNet107`) and a package's OWN FREE FUNCTION or TASK.
> Both arms skip a candidate whose object is a `ref_var`
> (`if (decl->UhdmType() == uhdmref_var) continue;`, at `:3387` `Io_decls` and
> `:3397` `Variables` for the function, `:3442`/`:3452` for the task), both
> fall through to the module-level search, and both end at the SAME implicit-
> wire mint (`UhdmWriter.cpp:3982-4004`, the `s.MakeLogic_net()` at `:3985`: a `logic_net`, `VpiName(name)`,
> `VpiParent(m)`, the REFERENCE's span, `VpiNetType` from the design element's
> `m_defaultNetType` — `1` for the default net type — pushed onto
> `inst->Nets()` and bound with `ref->Actual_group(net)`). **Nothing in that
> function tests for a class.** A module inherits the whole unbound-reference
> list of every package it imports (`CompileHelper::importPackage`,
> `CompileHelper.cpp:190-193`, fed by `CompileModule.cpp:571-581` for every
> FILE-SCOPE `import pkg::*;` — and, measured on arm a4, for a BODY-SCOPE
> `import` too), and a free package subroutine's references are in exactly that
> list. So the gate § 107 wrote — "an OUT-OF-BODY method body of a PACKAGE
> class" — is one body kind too narrow, and the fix is to widen it by exactly
> one: a FREE PACKAGE SUBROUTINE's body, emitted in the package's ELABORATED
> (top) view.*
>
> **AND THE VIEW HALF, which is not decoration:** *golden binds the wire on the
> `uhdmtopPackages` copy of the body and leaves the `uhdmallPackages` copy
> UNBOUND — measured on both sides of all nine UVM databases and on every arm.
> `design::Compare` walks AllPackages BEFORE TopPackages, so binding the DEF
> copy would have been a NEW head rather than a cleared one.*
>
> **WHICH REFERENCES: unchanged from § 107.** *Exactly the ones Surelog's
> COMPILE-TIME `CompileHelper::bindVariable` failed on, which is what
> § `refVarLocalWindowBinds5` already models — the gate is `!bind5` — plus § 5's
> own residue R1, the user-class-receiver call argument in expression position.
> The `= new` lvalue FENCE (`lhsOfWrittenNewAsg107`) and the hier_path-element
> / method-receiver builders keep every name they already kept.*

### THE PRISTINE BINARY ALREADY AGREES WITH GOLDEN ON EVERY NON-NET CELL

The decode is not a story about which positions bind — that was settled by
§ `refVarLocalWindowBinds5` and § 107. Arm a1 reads all fourteen reference
positions off ONE golden, and the PRISTINE binary already matches golden on
every cell where golden binds the declaration or binds nothing
(`condGamma` → `ref_var`, `userArgDelta` → `ref_var`, the `= new` lvalue, the
statement and expression receiver calls, the resolved controls). It differs on
**exactly the eight cells where golden mints the wire**. The one thing missing
was the HOME test. See §3.

## 3. THE GRID — golden's answer for every cell, both views

`grid117.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm` / `-elabuhdm`) and censuses all six; every
command is echoed with its own `rc` into `<workdir>/cmds.txt` so the binary each
database came from is auditable BY PATH (RESUME §9). `GRID.txt` has every cell
verbatim. Each arm gives every cell its OWN name — a grid that calls everything
`a_t`/`b_t`/`c_t` is self-confirming (RESUME §9).

**`g117_a1.sv` — the REFERENCE-POSITION grid, a free package FUNCTION and a
free package TASK** (ELABPKG, `work@top117a`):

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| 01 `asgLhsAlpha = process::self();` | ordinary assignment LVALUE — **the head's own position** | **logic_net** | NONE | **logic_net** ✓ |
| 02 `asgLhsAlpha = rhsReadBeta;` | LVALUE and plain RHS READ | **logic_net** ×2 | NONE | **logic_net** ×2 ✓ |
| 03 `if (condGamma == null)` | CONDITION operand | `ref_var` | `ref_var` | `ref_var` ✓ |
| 04 `sink117a(userArgDelta)` | user call ARGUMENT | `ref_var` | `ref_var` | `ref_var` ✓ |
| 05 `$cast(sysArgEpsilon, rhsReadBeta)` | SYSTEM-call arguments | **logic_net** ×2 | NONE | **logic_net** ×2 ✓ |
| 06 `newLhsZeta = new(1);` | the `= new` LVALUE — **the fence** | NONE | NONE | NONE ✓ |
| 07 `stmtCallEta.kill();` | receiver call, STATEMENT | NONE | NONE | NONE ✓ |
| 08 `if (exprCallTheta.status() == …)` | receiver call, EXPRESSION | NONE | NONE | NONE ✓ |
| 10 `return retIota;` | RETURN operand | **logic_net** | NONE | **logic_net** ✓ |
| 11 `blkLocalLambda = process::self();` | a BLOCK-ITEM local (§ 115 SITE 2) | **logic_net** | NONE | **logic_net** ✓ |
| 12 `taskLocalNu = process::self();` | a free package **TASK**'s local | **logic_net** | NONE | **logic_net** ✓ |
| C1 `resolvedCtlXi` | a USER class handle, every position | binds its own decl / NONE | same | same ✓ |
| C2 `intCtlOmicron` | an `int` local, every position | `int_var` | `int_var` | `int_var` ✓ |

**6 of 6 net cells and 53 of 53 reference cells agree with golden after the
patch; 0 and 45 before; 0 AWAY.**

**`g117_a2.sv` — the HOME grid.** ONE declaration shape and ONE reference
position (the ordinary assignment lvalue), written in SIX homes. This is the
arm that decides the law:

| a2 cell | home | golden | pristine | patched |
|---|---|---|---|---|
| `homeFreeFnAlpha` | a FREE PACKAGE **FUNCTION** | **wire** | — | **wire** ✓ |
| `homeFreeTaskBeta` | a FREE PACKAGE **TASK** | **wire** | — | **wire** ✓ |
| `homeOobGamma` | an OUT-OF-BODY class method | wire | wire | wire ✓ (§ 107) |
| `homeInBodyDelta` | an IN-BODY class method | — | — | — ✓ (the control: § 115 keeps `class_var`, so no `ref_var` and no wire) |
| `homeModFnEpsilon` | a **MODULE's own function** | **wire** | — | — (residue **R-MODFN**, §7) |
| `homeUnitFnZeta` | a `$unit` function | — | — | — ✓ |

**3 of 4 net cells agree after, 1 before, 0 AWAY.** The `ref_var` declarations
themselves are byte-identical between the two producers on this arm (the RV row
sets diff clean), so every cell above is a BINDING answer and not a declaration
one.

**`g117_a3.sv` — the OWNER grid** (two tops, a child instantiated three times,
and a MULTIPLICITY CONTROL): golden mints `ownerAlpha` and `ownerBeta` in
`work@kid117c` **ALONE** — `UhdmWriter::lateBinding`'s own first line is
`if (ref->Actual_group()) continue;` and the ref objects are SHARED, so the
FIRST module written that cannot bind a name owns the only wire. We mint them in
all three importing modules. **That spread is the shared pool's, not this law's,
and the arm PROVES it**: the control name `ctlProp117c` — § `classPropRefs`' own
family, an unresolvable class property in an out-of-body method — is minted by
the **PRISTINE** binary in `work@topA117c` and `work@topB117c` too, where golden
mints it in `work@kid117c` alone (`g=0 pris=1 pat=1`, unchanged by this pass).
uvm107's residue **R-MULTI**, inherited; **zero corpus reach** (§5, and the
post-patch census in §6: the ours-only implicit-net name set is byte-equal to
the pristine one).

**`g117_a4.sv` — the hoisting-shape NEGATIVE CONTROL.** No module imports the
package at FILE scope: one imports it INSIDE its body, one names the function
through its package scope and imports nothing, one does nothing at all. Golden
mints `noHoistAlpha` in `work@bodyImp117d` and nowhere else — a BODY-SCOPE
import hoists — and the patched binary mints it in `work@bodyImp117d` and
nowhere else. **1 of 1, 0 AWAY.**

**GOLDEN-VS-GOLDEN CALIBRATION FIRST** (`goldcen117.sh`). Over the five UVM
tests that have both modes, `default` and `testflags` are two independent
Surelog runs of the same design; this family's rows (every implicit net per
module + every `ref_var` local of a package subroutine) are compared pair by
pair: **5 pairs calibrated, 0 SKIP, 0 pairs differ, EXPM_N = 0** over 6,035
family rows. Every golden-vs-ours number below is read against zero expected
mismatch.

## 4. THE FIX

Three edits, all of them the SAME sentence in three places.

* **`include/UhdmExporter.h`** — the law, one member
  `pkgFreeSubHomePkg117`, and a 3-line accessor `hoistHomePkg117()` that
  returns the class's home package for an out-of-body method (§ 75 / § 107) and
  the PACKAGE ITSELF for a free package subroutine.
* **`src/TaskFuncEmit.cpp`** — the member's ONE setter, written beside
  `classBodyHomePkg75`'s so the two states cannot drift:
  ```cpp
  pkgFreeSubHomePkg117 = nullptr;
  if (pkgScope && !classScope && !cloneMode && pkgTopEmit && !pkgImportCloneEmit)
      pkgFreeSubHomePkg117 = homePkgSym;
  ```
  `homePkgSym` is `emitTaskFuncs`' own `(pkgScope && !classScope) ?
  &body.asSymbol() : nullptr` — the package. `pkgTopEmit` is the VIEW conjunct
  (§2's second paragraph); `!pkgImportCloneEmit` keeps a WILDCARD-IMPORT clone
  re-emitted into an IMPORTING package out, because its home would be the
  importer and not where golden's pool lives (zero corpus HIT cells sit in a
  clone — §5). The member is reset with `classBodyHomePkg75` at the end of
  `emitTaskFuncs`.
* **`src/ExprEmit.cpp`** — `oobRefVarLocalHoistNet107`'s FIRST conjunct becomes
  `if (!hoistHomePkg117()) return false;` (it was
  `if (!inClassBodyEmit || !classBodyHomePkg75) return false;`), and the pool
  push at the § `refVarLocalWindowBinds5` bind gate records
  `hoistHomePkg117()` as the reference's home package instead of
  `classBodyHomePkg75`. **Every other conjunct of § 107's predicate is
  untouched** — the `= new` fence, the `ref_var` declaration-object test, the
  plain-local test, the function-return-name exclusion and the
  `!bind5 || recvUserMethodArgDepth107 > 0` disjunct.

The three other families that share the pool are untouched by construction: a
`with`-iterator argument (§ `withIterRefBindsHoistNet75`), a class-scope enum
constant (§ `classEnumConstBindsHoistNet76`) and a class PROPERTY
(§ `classPropRefs` / § `classPropNewLhsNoHoist109`) all read
`classBodyHomePkg75` at their own push sites and are only reachable from a class
body.

### THE FOURTH EDIT — THE MINT ORDER, AND THE BOUNDARY GATE THAT DEMANDED IT

`bindHoistedClassPropRefs` mints ONE wire per NAME per module, **at the FIRST
pool entry of that name** — which is our EMISSION order. Surelog's order is the
order references were REGISTERED while the package was compiled, i.e. the
package's SOURCE order. Our package emitter runs the package's own free
subroutines BEFORE its classes (`emitPackage`: `emitTaskFuncs(pkg, …)` then
`emitPackageClasses`), so a first cut RE-SPANNED a wire a class body already
owned. **The BOUNDARY gate caught it on two EARLIER passes' committed arms, and
nothing else did** — no corpus row, no census cell, and no `uhdm-cmp` head, since
no generated `Compare` reads a net's span:

| arm | name | golden | pristine | first cut | shipped |
|---|---|---|---|---|---|
| `r10uvm77repro/v77x4_scope.sv` | `p` in `work@top77x4` | @29:5 (`x4c::oob`, source line 29) | @29:5 | **@35:5** (`pkgfn`, line 35) | @29:5 ✓ |
| `r10buvm9repro/w1v_pkgclsts.sv` | `v` in `work@w1m` | @32:54 (`w1k::f1`, line 32) | @32:54 | **@39:49** (`g8`, line 39) | @32:54 ✓ |

The fix is a STAGING vector: a free package subroutine's pool entries are
recorded in `pkgFreeSubPropRefs117` and APPENDED to `classPropRefs` at ONE point
in `src/ParamEmit.cpp`, once the package's classes have contributed theirs. That
restores the pristine order for every name a class body already owns and adds
only names no class body claims — so it can never move a wire that was already
right. With it, both arms move **TO-GOLDEN only** (2 and 1 cells, 0 AWAY): the
free-subroutine reference now BINDS the wire golden binds it to, at golden's own
span. `src/ExprEmit.cpp`'s § `lvIncDecCollapseNetSpans7` back-patch reads BOTH
vectors rather than assuming which took the last push.

**DIRECTION: it adds a BINDING and the one wire that binding mints, and nothing
else.** The order-blind whole-dump attribution (§6) proves the only objects that
change in any real mover are ONE `logic_net` and the nine dump lines that make
it and its binding.

## 5. THE FENCE AND THE PREDICTION — written from PRISTINE databases only

`fence117.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir with `ct117cen` and joins the REFERENCE rows on the key
both producers can spell — (view, owner fullname, reference span, reference
name):

* **HIT** — golden binds an IMPLICIT MODULE WIRE, we bind NOTHING, the owner is
  a FREE PACKAGE SUBROUTINE, and the name IS a `ref_var` local of that owner in
  OUR OWN database. These MUST move, and nothing else may.
* **OTHER** — golden binds an implicit wire and we do not, but the shape is not
  the family's. These must NOT move.
* **MIRROR** — WE bind an implicit wire where golden binds nothing, in the
  family's shape. A WIDENING; must stay 0.

| corpus | measured | SKIP | **HIT** | OTHER | **MIRROR** | **databases that MUST move** |
|---|---|---|---|---|---|---|
| surelog | 956 | 617 | **4** | 40 | **0** | **4** |
| uhdm2rtlil | 679 | 52 | **0** | 0 | **0** | **0** — the predicted NONE |

The four, BY NAME: `{default,testflags}/{SimpleUVM,SeqDriver}`. **ONE site in
each**, identical:

```
uvm-1.2 base/uvm_globals.svh:263:3   uvm_pkg::uvm_process_report_message   p = process::self();
```

The 40 OTHER rows are uvm107's residue **R-NONREFVAR**: `sz`, `n`, `addr`,
`local_addr`, `uvm_phase`, `m_packed_size` — names golden nets from `new(...)` /
`randomize()` arguments and foreach-scope reads where the declaration is an
`int_var` / `bit_var` / `array_var` on BOTH sides. The `ref_var` conjunct
excludes every one of them, and none moved.

`pred117.sh` is the MOVER PREDICTOR and reads **OUR SIDE ALONE** — no golden is
opened. It reports `MAY-MOVE` (an ELABPKG reference owned by a free package
subroutine, naming a `ref_var` local of that owner, unbound today, and NOT a
hier_path element or a method-call receiver) and `OUTER` (the same without the
last test). Surelog: **MAY-MOVE 9 rows in 9 databases — all nine UVM ones —
OUTER 22**; uhdm2rtlil: **0 and 0**. The nine are a SUPERSET of the fence's
four: Scoreboard, MiniAmiq ×2 and BuildUVMPkg ×2 carry the same reference but no
module of those designs imports `uvm_pkg`, so no module hoists it and no wire is
minted — and the measured movers are exactly the fence's four (§6). The 22 OUTER
rows are `uvm_has_wildcard`'s `arg` (a hier_path base, 18) and `uvm_init`'s
`uvm_deferred_init` (a method-call receiver, 4) — the two builders that keep a
name out of Surelog's pool (§ `classPropNewLhsNoHoist109`); neither moved.

## 6. THE GATE BATTERY

See `GATES.txt` for the whole battery with its numbers, the `cmds.txt` binary
audit by PATH, the four boundary runs and the order-blind mover attribution.
Headline: goldens **23/0** (and `/bin/false` **0/23**); uhdm2rtlil
**679/50/2** in BOTH modes on BOTH binaries; the surelog corpus **1588 rows,
CMP_NOTEQUAL 19, unchanged**, `ct8rows` **PASS** (0 differing rows, status AND
dump column) against the committed baselines and against this pass's own
pristine sweep; byte movers **4/956** and **0/1358**, all four predicted by
name; canaries **ok=52 / ok=8, changed=0**, `ctcan2` PASS ×2, `canaudit`
**audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected databases
byte-identical with `SVSwitch` pinned at `4842211c4030` and `YosysVerx` at
`6ccda350c24a`.

**THE BOUNDARY**, over a COPY of the WHOLE probe tree, no path filter, both
MODEs and both VIEWs — `PROCESSED == LISTED` and `PRIS_REJECT ==
PATCHED_REJECT` in all four:

| run | arms | DIFFER |
|---|---|---|
| file / def | 3626 | 8 |
| file / elab | 3626 | 6 |
| dir / def | 1529 dirs | 8 |
| dir / elab | 1529 dirs | 6 |

Every differing arm is accounted for in `ATTRIB.file.txt`: **four are this
pass's own**; `r10uvm115repro/g115_a.sv` (**11 cells TO-GOLDEN, 0 AWAY** — five
implicit wires golden has and the pristine binary did not),
`r10buvm9repro/w1v_pkgclsts.sv` (**2 TO-GOLDEN, 0 AWAY**) and
`r10uvm77repro/v77x4_scope.sv` (**1 TO-GOLDEN, 0 AWAY**); and two that are not
this law at all — see residues **R-ADDR** and **R-LISTORDER**, each with its own
NULL CONTROL.

**The four slang-fenced tests are NEVER dispatched and never spelled**: the
boundary compiles only files under the probe-tree copy, and `canaudit.sh`
reports `FENCE-BREACH=0`, and its per-name lines read
`not dispatched by any driver (OK)`.
FENCED= (list only — the four names are deliberately NOT written into any probe
artefact of this pass).

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SimpleUVM ×2 (56 lines), AND IT IS ALREADY ON THE
BOARD.** Byte-identical (ids aside) to SeqDriver's, Scoreboard/default's,
MiniAmiq's and BuildUVMPkg's — **ONE object now heads SIX row-modes** (plus
SimpleUVM ×2 = eight):

```
LHS  class_var: (uvm_pkg::uvm_sequence_library::init_sequence_library::this_type::m_typewide_sequences) @496:12-496:23
       |vpiName:this_type::m_typewide_sequences   |vpiParent: foreach_stmt @496:3
       |vpiTypespec -> ref_typespec -> unsupported_typespec (this_type::m_typewide_sequences) @496:12-496:23
RHS  ref_var:   (…::init_sequence_library::m_typewide_sequences) @496:12-496:32
       |vpiName:m_typewide_sequences
       |vpiTypespec -> ref_typespec -> unsupported_typespec (m_typewide_sequences) @496:12-496:32
```

`uvm-1.2 seq/uvm_sequence_library.svh:496`,
`foreach (this_type::m_typewide_sequences[i])`: golden keeps the WRITTEN
`this_type::`-qualified spelling as the foreach index variable's NAME (and as
its `unsupported_typespec`'s), ending the span at the NAME (`:23`), where we
strip the qualifier and span the whole written text (`:32`), and the object KIND
differs too (`class_var` vs `ref_var`). **This is the head the sister pass
r10buvm33 is already on** (the brief names it "the this_type:: foreach head —
seven OTHER row-modes"); SimpleUVM ×2 simply joins its row set. Nothing to do
with this pass — the object is untouched by it, and Scoreboard/default,
MiniAmiq ×2, BuildUVMPkg ×2 and SeqDriver ×2 carried it BEFORE the patch with
byte-identical head text.

**R-MODFN — a MODULE's OWN function's `ref_var` local.** Arm a2 cell
`homeModFnEpsilon`: golden mints `logic_net(work@top117b.homeModFnEpsilon)`
@52:5 in the module's own DEFMOD listing — the module is its OWN late-binding
owner, so `UhdmWriter::lateBinding(s, mod, m)` reaches the same mint with no
package in the picture. We mint nothing. It is the SAME law one home further
out, but a different MECHANISM on our side (the hoisted-net pool is keyed on a
module's MATERIALISED PACKAGES; a module's own function has no package home, and
the machinery that would serve it is § `fnLocalParamRangeNet`'s
`implicitNetModule`). **ZERO corpus witnesses on either corpus** — the fence's
HIT set is four cells and all four are free-PACKAGE-function ones — so it is
recorded rather than widened on no evidence. Ranked next in this family.

**R-MULTI (uvm107's) — the wire is minted ONCE PER REFERENCE, in the FIRST
module that cannot bind it.** Re-measured on `g117_a3.sv`: golden mints
`ownerAlpha` / `ownerBeta` in `work@kid117c` alone; the patched binary mints them
in `kid117c`, `topA117c` and `topB117c`. The arm's MULTIPLICITY CONTROL proves
the spread is the shared pool's and PRE-EXISTING: `ctlProp117c`
(§ `classPropRefs`' own family) is minted in all three by the **PRISTINE** binary
against golden's one. **Zero corpus reach** — SimpleUVM and SeqDriver each have
exactly one importing module, and the post-patch census's ours-only
implicit-net NAME set (`clp`, `top`) is byte-equal to the pristine one. A pass
that fixes it must move § classPropRefs / § 75 / § 76 / § 107 / § 117 together.

**R-NONREFVAR (uvm107's) — still open, still ranked, and it is now the WHOLE
golden-only implicit-net population of the four movers.** After this pass
SimpleUVM's `work@top` and SeqDriver's `work@top_tb` are missing exactly FIVE
implicit-net names golden has: `sz` @488:15, `n` @1427:25, `addr` @1491:44,
`local_addr` @1467:39 and `uvm_phase` @1664:21 — `new(...)` / `randomize()`
arguments and foreach-scope reads whose declaration is an `int_var` /
`bit_var` / `array_var` on BOTH sides, so the `ref_var` gate deliberately
excludes them. 40 reference cells corpus-wide (`PREDICTION.fence_pristine_surelog.tsv`).

**R-CLP / R-TOPNET (uvm109's) — the two ours-only wires, unchanged.**
`uvm_root::new` `clp = uvm_cmdline_processor::get_inst();` @339:3, where golden
binds the `class_var` outright and we mint a hoisted wire; and `work@top.top`
@67:18, a DEFMOD-level `$dumpvars` reference with no task/func owner. Both are
byte-identical before and after.

**R-DEFCOPY — the DEF listing's half, and why it must stay that way.** In the
`uhdmallPackages` copy of `uvm_process_report_message` golden leaves the `p`
reference UNBOUND, and so do we, before and after. `pkgTopEmit` is the conjunct
that keeps it so. Not a residue to fix — a fact the law encodes.

**R-ADDR — an ADDRESS-DERIVED garbage constant, and why a relink moves it.**
Boundary arm `r10buvm22repro/g22.sv`, an associative-array typedef
`typedef C22 ka_cls_t[string];`: golden gives the range a plain `constant`,
while WE give it an `operation` over a 64-bit constant whose value is an
ADDRESS — `0x155fd99` / `0x155fa41` on the pristine binary. It is not this
law's cell and not any cell of any family; it is a pre-existing residue of the
associative-array dimension-bound family that tracks the BINARY'S SIZE. **NULL
CONTROL, three binaries** (`ATTRIB.file.txt`): the INTERMEDIATE patched build —
the law fully active, and byte-size-identical to the pristine binary at
22,193,056 — reproduces the PRISTINE values exactly; the shipped build (+4,280
bytes) shifts both by EXACTLY 4096, one page, with their low 12 bits unchanged.
With those two values masked, all three dumps are byte-identical (md5
`3e596e6ed8b3`). Recorded here so no later pass mistakes it for a mover.

**R-LISTORDER — three dir-mode boundary directories whose diff is PURE ORDER.**
`r10uvm75repro`, `r10uvm76repro` and `r10v109repro` compiled as directories show
their modules' `vpiTaskFunc` lists PERMUTED — the same objects, no additions and
no removals. **NULL CONTROL**: the PRISTINE binary ALONE produces FOUR DIFFERENT
whole-dump md5s in four runs on each of those three directories, and the
ORDER-BLIND (sorted) diff between pristine and patched is **0, 0, 0**. This is
the emitter nondeterminism RESUME §9 names — macro-buffer `SourceLocation`
ordering under slang's parallel parse, the same coin that makes
Scoreboard/default a ~50/50 flip — and it is why every attribution in this pass
is read order-blind.

**R-UNDECLARED — the cell no arm can carry.** A reference to a name with NO
declaration at all in a free package function is the purest form of this
mechanism (Surelog's module-level search fails and mints), but slang REJECTS the
source, so no database of ours can ever exist for it. Recorded as unreachable,
not as unmeasured.

## 8. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct117cen.cpp` | the REFERENCE-ACTUAL + IMPLICIT-NET census. `r10uvm109repro/r10uvm109cen.cpp` with ONE column added — **HOME**, the KIND of the scope the owning task/func is DECLARED IN (CLS / PKG / MOD / IFACE / PROG), walked off the owner's own `vpiParent` chain. That column is the whole reason it exists: `OOB`/`IB` (read off the owner's NAME) cannot tell a FREE PACKAGE FUNCTION from an IN-BODY class method — both are `IB`. Keyed on what both producers can spell (view / owner / span); NEVER the file (our objects carry an EMPTY `VpiFile`). |
| `cells117.py` | the IMPLICIT-NET POPULATION JOIN, per top module, golden vs ours, as a MULTISET on (view, module, name, span) AND on (view, module, name) — with the ORIGIN of each differing cell (the minting reference's owner, its HOME, and whether the name is a `ref_var` local). |
| `cen117.sh` | runs `ct117cen` over both sides of a NAMED set of tests in a sweep workdir; the golden path is read out of the workdir's own `cmds.txt`, never guessed. |
| `fence117.sh` | the family's differential census over a WHOLE sweep workdir: HIT / OTHER / MIRROR. |
| `pred117.sh` | the MOVER PREDICTOR, our side alone: MAY-MOVE / OUTER. |
| `score117.py` | the ARM SCORER: golden vs pristine vs patched, NET and REF families, TO-GOLDEN / AWAY-GOLDEN / STILL as multisets. |
| `movattrib117.sh` | the ORDER-BLIND byte-mover attribution (Scoreboard/default is a ~50/50 emitter COIN — RESUME §9 — so only a sorted, id-stripped, path-normalised read can attribute it). |
| `goldcen117.sh` | the golden-vs-golden calibration, run FIRST. |
| `grid117.sh` | builds one arm's six databases (three producers × two views) and censuses them; every command echoed with its own rc. |
| `bound117.sh` | the BOUNDARY gate over a COPY of the whole probe tree, both MODEs, both VIEWs. |
| `attrib117.sh` | boundary-arm attribution against a FRESH golden. |
| `build117.sh` | builds a probe from THIS directory. |
| `g117_a1.sv` … `g117_a4.sv` | the four purpose-built goldens: the REFERENCE-POSITION grid, the HOME grid, the OWNER grid (with its multiplicity control) and the hoisting-shape NEGATIVE control. |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing gates, copied unchanged so this directory can re-run its own battery. |
