# r10uvm130 — § `newArrayArgHoistNet130` — **A DYNAMIC-ARRAY `new[...]` ARGUMENT DOES NOT MERELY STAY UNBOUND: IT MINTS AN IMPLICIT WIRE, AND THE DECLARATION KIND IS IRRELEVANT** — the SeqDriver ×2 **17-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f611e1b` |
| worktree | `/tmp/wt_r10uvm130` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `f611e1b` BYTE FOR BYTE (md5 `f102bcba68a7d9317c746b848792fda1`) — frozen `chmod 555` before any sweep |
| patched binary | md5 `96ac63809cd34213960a17a58a268e13`, frozen `chmod 555` |
| production surface | `include/UhdmExporter.h` (the law + ONE declaration) and `src/ExprEmit.cpp` (the predicate and ONE pool push inside the branch that already existed) |
| probe surface | `tools/probe/r10uvm130repro/` only |

## READ THIS FIRST — the numbers

`rowheads.sh` on this pass's OWN pristine and patched sweeps, same instrument
both times:

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **17** | **310** | 1 — a **NEW** head, a different object (§7 R0) |
| SimpleUVM default / testflags | 64 | 64 | 1 unchanged, head text BYTE-IDENTICAL |
| Scoreboard default | 64 | 64 | 1 unchanged, head text BYTE-IDENTICAL |
| MiniAmiq default / testflags | 294 | 294 | 1 unchanged, head text BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 54 | 54 | 1 unchanged, head text BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 90 / 150 | 90 / 150 | 1 unchanged, head text BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes; CMP_NOTEQUAL stays 19) | |
| byte movers | — | **4 / 956** surelog — exactly the four PREDICTED BY NAME — and **0 / 1358** uhdm2rtlil. Every mover ADDS 40 dump lines and REMOVES none | |
| the corpus FENCE | HIT **24**, MIRROR **0** | **HIT 0**, MIRROR still **0** — the family CLOSED corpus-wide | |
| the implicit-net population, per moving DB | **5** golden-only NAMES | **1** (`uvm_phase`, another law's) | |
| ours-only implicit-net names | `clp` (SeqDriver), `clp`+`top` (SimpleUVM) | **the identical sets** — no widening | |
| direction, 9 UVM databases | — | **16 NET cells + 24 REF cells TO-GOLDEN, 0 AWAY-GOLDEN**, over 213–225 net cells and 26,628–31,697 reference cells per database | |

The 17-line head this pass cleared is `head_pris_default_SeqDriver.cmp`; the new
one is `head_pat_default_SeqDriver.cmp` (310 lines, §7 R0).

## 1. THE HEAD, CONFIRMED FROM `BaseClass.h` AND FROM BOTH DUMPS FIRST

The whole 17-line head, verbatim from this pass's own pristine cmp log:

```
LHS:
decompile:
logic_net: (work@top_tb.sz), line:488:15, endln:488:17
|vpiParent:
\_module_inst: work@top_tb (work@top_tb), file:.../SeqDriver/testbench.sv, line:210:1, endln:236:18
|vpiName:sz
|vpiFullName:work@top_tb.sz
|vpiNetType:1
RHS: <null>
```

`LHS` printing in full with `RHS: <null>` is the **SINGULAR** `SafeCompare`
overload's `lhs != nullptr && rhs == nullptr` arm
(`~/.local/include/uhdm/BaseClass.h:187-193`); the VECTOR overload (`:202-224`)
would have named the whole `module_inst::Nets` CONTAINER, not one net. The
carrier is golden's `ref_obj (sz)` @488:15 whose `vpiActual` IS that net; ours
carries none, and our `work@top_tb` holds no net of that name at all.

Source — `uvm-1.2 base/uvm_packer.svh`, and the routine is an **OUT-OF-BODY
METHOD** of a package class:

```systemverilog
function void uvm_packer::get_bytes(ref byte unsigned bytes[]);   // :484  OUT OF BODY
  int sz;                                                         // :485  an int_var, NOT a ref_var
  byte v;
  sz = (m_packed_size+7) / 8;                                     // :487  binds normally
  bytes = new[sz];                                                // :488  <- THE HEAD's reference
  for (int i=0;i<sz;i++) begin                                    // :489  binds normally
```

`sz` is read three times in eight lines and only ONE of those reads mints a
wire. The position — the **SIZE ARGUMENT of a dynamic-array `new[...]`** — is
the whole story, and §2 says why.

## 2. THE LAW

> **§ `newArrayArgHoistNet130`** — *A name written in a DYNAMIC-ARRAY
> `new[size](init)` argument list does not merely stay unbound (which is all
> § `newArrayArgNoBind16` claimed): it MINTS AN IMPLICIT WIRE in every module
> that hoists the enclosing body's package, and **the declaration kind is
> irrelevant**. `CompileHelper::compileBlockingAssignment`'s
> `paDynamic_array_new` arm (Surelog
> `src/DesignCompile/CompileHelper.cpp:4482-4497`) builds the
> `method_func_call` named `new` and NEVER sets its `VpiParent` — the CLASS
> `= new` arm eleven lines down (`:4543`) does `fcall->VpiParent(assign);` —
> and hands that parentless call to `compileTfCallArguments` as the arguments'
> `pexpr`. So BOTH of Surelog's bind walks die on their first hop:
> `CompileHelper::bindVariable` (`src/DesignCompile/CompileStmt.cpp:3089-3147`)
> recurses on `scope->VpiParent()` and the reference goes to
> `DesignComponent::needLateBinding` (`CompileExpression.cpp:5778-5809`); and
> then `UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3359-3360`,
> `const any* parent = ref->VpiParent(); while (parent)`) starts from THE SAME
> unparented call, so its `uhdmfunction` / `uhdmtask` / `uhdmbegin` arms are
> never reached. The module-level search (`:3762-3958`) finds nothing either,
> and `:3982-4004` mints a `logic_net`, names it after the token, parents it at
> the module, stamps it with the REFERENCE's span and `VpiNetType` 1, pushes it
> onto `inst->Nets()` and does `ref->Actual_group(net)`.*
>
> **WHY IT IS OUTSIDE § `oobRefVarLocalHoistNet107`'S GATE.** *§ 107's
> `ref_var` conjunct models ONE reason the write-time walk cannot answer — the
> explicit `if (decl->UhdmType() == uhdmref_var) continue;` repeated in every
> scope arm. The DEAD PARENT CHAIN is the OTHER reason, and it does not look at
> the declaration at all: an `int_var`, a `bit_var`, an `array_var`, an
> `io_decl` and a `ref_var` fall through alike. That is exactly why this
> population was recorded as § 107's residue **R-NONREFVAR** and § 117's 40
> OTHER fence rows, and why widening § 107's `ref_var` test would have been the
> wrong fix.*
>
> **WHICH BODIES — the ONE discriminator, and it is `hoistHomePkg117()`.**
> *`lateBinding(s, mod, m)` walks `mod->getLateBinding()`, and a module
> inherits the whole unbound-reference list of every package it imports
> (`CompileHelper::importPackage`, `CompileHelper.cpp:190-193`). A CLASS's list
> is never walked at all — `UhdmWriter.cpp:1067` is the commented-out
> `// lateBinding(s, classDef, c);`. So an IN-BODY class method's `new[...]`
> argument belongs to the CLASS component and stays bare in golden for ever,
> while an OUT-OF-BODY definition's (§ `oobRefVarLocalHoistNet107`) and a free
> package subroutine's (§ `pkgFreeSubRefVarHoistNet117`) belong to the PACKAGE
> and hoist. `hoistHomePkg117()` is already the one pointer that names either
> body, so the law adds NO new home machinery.*
>
> **AND THE BUILDER HALF, unchanged from § `classPropNewLhsNoHoist109`:** *a
> hier_path element and a method-call RECEIVER under the same `new[...]` never
> enter Surelog's pool and never take a wire. Those references are built by
> other builders that never reach this bind gate, so the exclusion is
> structural.*

### THE TWELVE CORPUS SITES, six that hoist and six that do not

Read off golden alone, `uvm-1.2`, in SeqDriver's `work@top_tb` and SimpleUVM's
`work@top` (the two designs whose top module imports `uvm_pkg`):

| site | written | enclosing routine | golden |
|---|---|---|---|
| `uvm_packer.svh:488:15` | `bytes = new[sz];` | `uvm_packer::get_bytes` **OOB** | **logic_net** — THE HEAD |
| `uvm_packer.svh:509:14` | `ints = new[sz];` | `uvm_packer::get_ints` **OOB** | the **SAME** wire (one per NAME per module) |
| `uvm_reg_map.svh:1427:25` | `local_addr = new [n];` | `uvm_reg_map::get_physical_addresses` **OOB** | **logic_net** |
| `uvm_reg_map.svh:1467:39` | `addr = new [local_addr.size()] (local_addr);` — the INIT argument | same **OOB** | **logic_net** |
| `uvm_reg_map.svh:1491:22` | `addr = new [n + sys_addr.size()] (addr);` — the size OPERAND | same **OOB** | **logic_net** |
| `uvm_reg_map.svh:1491:44` | same statement, the INIT argument | same **OOB** | **logic_net** |
| `uvm_spell_chkr.svh:160:13/15` | `d = new[m*n];` | `levenshtein_distance` **IN-BODY** | **NONE** |
| `uvm_reg_adapter.svh:195:30` | `gp.m_byte_enable = new [nbytes];` | `reg2bus` **IN-BODY** | **NONE** |
| `uvm_reg_model.svh:362:39` | `slices = new [slices.size()+1] (slices);` | `add_slice` **IN-BODY** | **NONE** |
| `uvm_tlm2_generic_payload.svh:547:20` | `m_data = new[m_length];` | `do_unpack` **IN-BODY** | **NONE** |
| `uvm_tlm2_generic_payload.svh:553:27` | `m_byte_enable = new[m_byte_enable_length];` | same **IN-BODY** | **NONE** |
| `uvm_packer.svh:475:14` | `bits = new[m_packed_size];` | `uvm_packer::get_bits` **OOB** | **logic_net** — a class PROPERTY, already ours through § `classPropRefs`; untouched by this pass |

and every hier_path element under a `new[...]` — `local_addr` @1467:19,
`sys_addr` @1491:26, `gp` @200:23, `slices` @362:21, `m_extensions` @910:24 —
carries **NO** actual and mints **NO** wire on either side, before and after.

The IN-BODY / OUT-OF-BODY split is the ONLY feature that separates the two
halves of that table: the contexts are the same, the declaration kinds are the
same (an `int` local, a formal, a class property appear on both sides), and the
files are the same tree.

## 3. THE GRID — golden's answer for every cell, both views

`grid130.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm` / `-elabuhdm`) and censuses all six; every
command is echoed with its own `rc` into `<workdir>/cmds.txt` so the binary each
database came from is auditable BY PATH (RESUME §9). `GRID.r10uvm130.txt` has
every cell verbatim with the direction score. Each arm gives every cell its OWN
name — a grid that calls everything `a_t`/`b_t`/`c_t` is self-confirming.

**`g130_a1.sv` — the CONTEXT grid** (one home: an OUT-OF-BODY package-class
method; one declaration kind: an `int` body local):

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| 01 `dynA = new[sizeAlpha];` | the BARE SIZE argument — the head's own shape | **logic_net** | NONE | **logic_net** ✓ |
| 02 `dynB = new[opndBeta + 1];` | the size as an OPERATION OPERAND | **logic_net** | NONE | **logic_net** ✓ |
| 03 `dynA = new[3](srcLam);` | the COPY-SOURCE (init) argument | **logic_net** | NONE | **logic_net** ✓ |
| 04 `dynB = new[srcLam.size()];` | a METHOD-CALL RECEIVER inside the size | NONE | NONE | NONE ✓ |
| 05 `fixedArr[0] = rhsEps;` | an ordinary assignment RHS | `int_var` | `int_var` | `int_var` ✓ |
| 06 `fixedArr[1] = fixedArr[idxDelta];` | a SELECT INDEX | `int_var` | `int_var` | `int_var` ✓ |
| 07 `sink130a(argZeta)` | a USER CALL argument | `int_var` | `int_var` | `int_var` ✓ |
| 08 `if (condEta == 0)` | a CONDITION operand | `int_var` | `int_var` | `int_var` ✓ |
| 09 `hOmega = new(newArgIota);` | a CLASS `new(...)` ARGUMENT — Surelog PARENTS that call | `int_var` | `int_var` | `int_var` ✓ |
| 10 `return retTheta + farmXi;` | a RETURN operand | `int_var` | `int_var` | `int_var` ✓ |

**3 of 3 net cells and 3 of 3 moving reference cells agree after; 0 before;
0 AWAY.** The patched implicit-net set for `work@top130a` is BYTE-EQUAL to
golden's, spans included.

**`g130_a2.sv` — the HOME grid, the arm that DECIDES the law.** ONE declaration
kind and ONE reference position (the bare size argument), written in SIX homes:

| a2 cell | home | golden | pristine | patched |
|---|---|---|---|---|
| `homeOobGamma130b` | an OUT-OF-BODY class method | **wire** | — | **wire** ✓ |
| `homeFreeFnAlpha130b` | a FREE PACKAGE **FUNCTION** | **wire** | — | **wire** ✓ |
| `homeFreeTaskDelta130b` | a FREE PACKAGE **TASK** | **wire** | — | **wire** ✓ |
| `homeInBodyBeta130b` | an **IN-BODY** class method | **—** | — | **—** ✓ **THE CONTROL** |
| `homeUnitFnZeta130b` | a `$unit` function | — | — | — ✓ |
| `homeModFnEps130b` | a **MODULE's OWN** function | **wire** | — | — (residue **R-MODFN**, §7 — uvm117's, inherited) |

**3 of 4 net cells agree after, 0 before, 0 AWAY.**

**`g130_a3.sv` — the DECLARATION-KIND grid, and the arm that refutes § 107's
`ref_var` gate for this family.** ONE home (OOB) and ONE context (the bare size
argument); what varies is what the name declares:

| a3 cell | declaration | golden | pristine | patched |
|---|---|---|---|---|
| 01 `bodyBeforeAlpha130c` | a body local (`int_var`) | **wire** | — | **wire** ✓ |
| 02 `farmXi130c` | a **FORMAL** (`io_decl`) | **wire** | — | **wire** ✓ |
| 03 `refArgPsi130c` | a **`ref` FORMAL** | **wire** | — | **wire** ✓ |
| 04 `propMu130c` | a CLASS PROPERTY | wire | wire | wire ✓ (§ `classPropRefs`, untouched) |
| 05 `statNu130c` | a STATIC class property | wire | wire | wire ✓ (untouched) |
| 06 `pkgVarOmi130c` | a PACKAGE variable | — (no IMPL net) | — | — ✓ |
| 07 `blkLocalGam130c` | a BLOCK local | **wire** | — | **wire** ✓ |
| 08 `nmdBlkDel130c` | a **NAMED**-block local | **wire** | — | **wire** ✓ |
| 09 `loopIterEps130c` | a LOOP ITERATOR | **wire** | — | **wire** ✓ |
| 10 | a local declared AFTER the read | NOT EXPRESSIBLE in SystemVerilog — see the arm's own comment; cell 07's block local is the nearest legal spelling | | |
| 11 `handleTau130c.propMu130c` | a hier_path receiver under `new[]` | — | — | — ✓ |

**10 of 10 net cells and 6 of 6 moving reference cells agree after; 4 and 0
before; 0 AWAY.** The declaration kind is measured, not assumed, to be
irrelevant.

**`g130_a4.sv` — the OWNER / MULTIPLICITY grid** (a child instantiated by two
tops, everything imported at file scope): golden mints `ownerAlpha130d` in
`work@kid130d` **ALONE** — `UhdmWriter::lateBinding`'s own first line is
`if (ref->Actual_group()) continue;` and the ref objects are SHARED, so the
FIRST module written that cannot bind a name owns the only wire. We mint it in
all three importing modules. **That spread is the shared pool's, not this law's,
and the arm PROVES it**: the CONTROL name `dynD130d` — a different family
entirely — is minted by the **PRISTINE** binary in `work@topA130d` and
`work@topB130d` too, where golden mints it in `work@kid130d` alone
(`g=1 pris=3 pat=3`, unchanged by this pass). uvm107's residue **R-MULTI**,
inherited; **zero corpus reach** (§5's MIRROR count is 0 before and after, and
§6's ours-only implicit-net name sets are byte-equal to the pristine ones).

**`g130_a5.sv` — the HOISTING-SHAPE NEGATIVE CONTROL.** No module imports the
package at FILE scope: one imports it INSIDE its body, one names the class
through its package scope and imports nothing, one does nothing at all. Golden
mints `noHoistAlpha130e` in `work@bodyImp130e` and nowhere else — a BODY-SCOPE
import hoists — and the patched binary mints it in `work@bodyImp130e` and
nowhere else. **1 of 1, 0 AWAY.**

**GOLDEN-VS-GOLDEN CALIBRATION FIRST** (`goldcen130.sh`, `CENSUS.r10uvm130.txt`).
Over the five UVM tests that have both modes, `default` and `testflags` are two
independent Surelog runs of the same design; this family's rows (every implicit
net per module + every `NEWARG` reference with its actual) are compared pair by
pair: **5 pairs calibrated, 0 SKIP, 0 pairs differ, EXPM_N = 0** over 502 family
rows. Every golden-vs-ours number below is read against zero expected mismatch.

## 4. THE FIX

Two edits, and the second is six lines of code.

* **`include/UhdmExporter.h`** — the law (the Surelog decode above, the twelve
  measured corpus sites) and ONE declaration,
  `bool newArrayArgHoistNet130(const Symbol&, const Expression&) const;`.
* **`src/ExprEmit.cpp`** — the predicate, three conjuncts:
  ```cpp
  if (newArrayArgDepth16 == 0)          return false;   // § newArrayArgNoBind16's WINDOW
  if (!newArraySubScopeSym16(sym))      return false;   // and its SYMBOL half
  return hoistHomePkg117() != nullptr;                  // a hoisting HOME
  ```
  and ONE pool push, inside the `if` branch that § `newArrayArgNoBind16`
  ALREADY reached and whose body was empty:
  ```cpp
  if (newArrayArgNoBind16 && newArrayArgHoistNet130(nv.symbol, expr)) {
      auto& pool130 = (inClassBodyEmit && classBodyHomePkg75) ? classPropRefs
                                                             : pkgFreeSubPropRefs117;
      pool130.push_back({ref, std::string(nv.symbol.name), expr.sourceRange,
                         hoistHomePkg117()});
  }
  ```
  The two-vector choice and the staging flush are § 117's own, unchanged: a free
  package subroutine's entries are appended after the package's classes have
  contributed theirs, so a wire a class body already owns can never be
  re-spanned.

**NOTHING ELSE CHANGED.** § `newArrayArgNoBind16` still refuses the binding (the
branch is the same branch); § `oobRefVarLocalHoistNet107`'s predicate, its
`ref_var` conjunct and its `= new` fence are untouched; § `classPropRefs`,
§ `withIterRefBindsHoistNet75` and § `classEnumConstBindsHoistNet76` push at
their own sites as before. The net field table is the pool binder's, already
golden's: `logic_net`, `VpiNetType(1)`, the READ site's span, parent the top
module, one wire per NAME per module — and the four minted wires land on
golden's own spans (`sz`@488:15-17, `n`@1427:25-26, `local_addr`@1467:39-49,
`addr`@1491:44-48; `CENSUS.r10uvm130.txt`).

**DIRECTION: it adds a BINDING and the wire that binding mints, and nothing
else.** The order-blind whole-dump attribution over all four movers is **40
ADDED lines and 0 REMOVED lines** each — four `logic_net`s, their four
`vpiParent` module lines, the `vpiActual` / `vpiName` / `vpiFullName` lines that
make them, and nothing more.

## 5. THE FENCE AND THE PREDICTION — written from PRISTINE databases only

`fence130.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir with `ct130cen` and joins the REFERENCE rows on the key
both producers can spell. A `new[...]` argument's `vpiParent` chain is DEAD on
BOTH sides — that is the whole law — so its view/owner columns read `OTHER`/`-`
in both databases and the span+name half of the key carries it:

* **HIT** — golden binds an IMPLICIT MODULE WIRE, we bind NOTHING anywhere, and
  OUR OWN database says `CTX=NEWARG` with a parent that is not a `hier_path`.
* **OTHER** — golden binds an implicit wire and we do not, but the shape is not
  the family's. These must NOT move.
* **MIRROR** — WE bind an implicit wire where golden binds none. A WIDENING;
  must stay 0.

| corpus | measured | SKIP | **HIT** | OTHER | **MIRROR** | **databases that MUST move** |
|---|---|---|---|---|---|---|
| surelog, PRISTINE | 956 | 617 | **24** | 12 | **0** | **4** |
| surelog, PATCHED | 956 | 617 | **0** | 12 | **0** | — |
| uhdm2rtlil, PRISTINE | 1358 | 104 | **0** | 0 | **0** | **0** — the predicted NONE |
| uhdm2rtlil, PATCHED | 1358 | 104 | **0** | 0 | **0** | — |

The 24 HIT cells are SIX SITES × FOUR DATABASES
(`{default,testflags}/{SeqDriver,SimpleUVM}`), listed by name in
`FENCE.pristine.surelog.tsv`: `sz` @488:15 and @509:14, `n` @1427:25 and
@1491:22, `local_addr` @1467:39, `addr` @1491:44. The 12 OTHER rows are all
`uvm_phase` — @1722:82 (an associative-array INDEX TYPE read as an expression in
`uvm_phase::get_predecessors_for_successors`'s formal list) and @1896:17 /
@1946:17 — a different family, residue **R-IDXTYPE** (§7); none moved.

`pred130.sh` is the MOVER PREDICTOR and reads **OUR SIDE ALONE** — no golden is
opened. `MAY-MOVE` is a `CTX=NEWARG` reference, not a hier_path element, unbound
today, written inside a subroutine whose HOME can hoist (found by LINE
CONTAINMENT against the census's `LV` owner spans, since a NEWARG reference has
no owner column of its own). Surelog: **MAY-MOVE 54 rows in 9 databases,
OUTER 109**; uhdm2rtlil: **0 and 0**. The 54 are a SUPERSET of the fence's 24 —
Scoreboard, MiniAmiq ×2 and BuildUVMPkg ×2 carry the same references (and the
1800.2 tree's own `get_packed_bytes` / `get_physical_addresses_to_map` twins),
but no module of those designs imports `uvm_pkg`, so no module hoists and no
wire is minted. The measured movers are exactly the fence's four (§6). The 109
OUTER rows are the IN-BODY half of §2's table plus every hier_path element; none
moved.

## 6. THE GATE BATTERY

See `GATES.r10uvm130.txt` for the whole battery with its numbers, the `cmds.txt`
binary audit BY PATH, and the four boundary runs. Headline: goldens **23/0**
(and `/bin/false` **0/23**); uhdm2rtlil **679/50/2** in BOTH modes on BOTH
binaries; the surelog corpus **1588 rows, CMP_NOTEQUAL 19, unchanged**;
`ct8rows` **PASS** (0 differing rows, status AND dump column) against the
committed baselines AND against this pass's own pristine sweep, on both corpora;
byte movers **4/956** and **0/1358**, all four predicted by name, `SELFCHECK`
955/956 and 1357/1358; canaries **ok=52 / ok=8, changed=0**, `ctcan2` PASS ×2,
`canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected
databases byte-identical with `SVSwitch` pinned at `4842211c4030` and
`YosysVerx` at `6ccda350c24a`.

**THE BOUNDARY**, over a COPY of the WHOLE probe tree, no path filter, both
MODEs and both VIEWs — `PROCESSED == LISTED` and `PRIS_REJECT ==
PATCHED_REJECT` in all four:

| run | arms | DIFFER |
|---|---|---|
| file / def | 3879 | 10 |
| file / elab | 3879 | 10 |
| dir / def | 1571 dirs | 10 |
| dir / elab | 1571 dirs | 10 |

Every differing arm is accounted for in `BOUNDARY.r10uvm130.txt`:

* **five are this pass's own** (`g130_a1..a5`);
* **four are earlier passes' arms that move TOWARD golden and only toward it** —
  `r10buvm16repro/a1_newgrid16.sv` (§ `newArrayArgNoBind16`'s OWN arm: **8 NET +
  17 REF cells TO-GOLDEN, 0 AWAY**), `r10uvm69repro/a1_type.sv` (**1 NET + 2 REF,
  0 AWAY**), `r10v107repro/v107_b2.sv` (**1 NET + 1 REF, 0 AWAY**),
  `r10v110repro/v4_bind.sv` (**4 NET + 4 REF, 0 AWAY**);
* **one is not this law at all** — `r10buvm22repro/g22.sv`, residue
  **R-ADDRCONST** (§7), with its proof;
* the five **dir-mode-only** directories (`r10uvm117repro`, `r10uvm75repro`,
  `r10uvm76repro`, `r10v109repro`, `r10v117repro`) have **0 order-blind
  differing lines in BOTH views**: the whole difference is `vpiTaskFunc` LIST
  ORDER, which is per-run nondeterministic on the SAME binary (four consecutive
  runs of the PRISTINE binary over `r10uvm75repro` gave four different orders).

**The four slang-fenced tests are NEVER dispatched and never spelled**: the
boundary compiles only files under the probe-tree copy, and `canaudit.sh`
reports `FENCE-BREACH=0` with each per-name line reading
`not dispatched by any driver (OK)`.
FENCED= (list only — the four names are deliberately NOT written into any probe
artefact of this pass).

## 7. RESIDUES, named for the queue

**R0 — THE NEW HEAD of SeqDriver ×2 (310 lines), a `named_fork`.**
`head_pat_default_SeqDriver.cmp`; the def and testflags head texts are
byte-identical (ids aside):

```
LHS  named_fork: (uvm_pkg::uvm_phase::execute_phase::master_phase_process) @1400:9-1413:18
       |vpiParent: begin (uvm_pkg::uvm_phase::execute_phase) @1393:10-1526:8
       |vpiName:master_phase_process   |vpiJoinType:1
       |vpiStmt: begin @1401:11-1412:14  -> assignment @1403:13 …
RHS  <null>
```

`uvm-1.2 base/uvm_phase.svh:1400`, `fork begin : master_phase_process … end join_none`
inside `uvm_phase::execute_phase` — golden carries a NAMED FORK whose
`vpiJoinType` is 1 and whose statement is the labelled `begin`; we carry nothing
at that slot. 310 cmp lines is that object's decompile size, not a distance.
**Ranked next for this row family.**

**R-MODFN — a MODULE's OWN function's `new[...]` argument.** Arm a2 cell
`homeModFnEps130b`: golden mints `logic_net(work@top130b.homeModFnEps130b)`
@60:22 in the module's own listing — the module is its OWN late-binding owner,
so `UhdmWriter::lateBinding(s, mod, m)` reaches the same mint with no package in
the picture. We mint nothing. It is the SAME law one home further out, but a
different MECHANISM on our side (the hoisted-net pool is keyed on a module's
MATERIALISED PACKAGES; a module's own function has no package home, and the
machinery that would serve it is § `fnLocalParamRangeNet`'s
`implicitNetModule`). **ZERO corpus witnesses on either corpus** — the fence's
HIT set is 24 cells and all of them are package-home ones — so it is recorded
rather than widened on no evidence. This is uvm117's R-MODFN, unchanged, now
witnessed for a second reference family.

**R-MULTI — the hoisting module COUNT.** Arm a4: golden mints one wire in the
FIRST module written that cannot bind the name; our pool binds every module that
materialises the home package. Inherited from uvm107 and shared by every law
that uses the pool; the arm's CONTROL name `dynD130d` shows the PRISTINE binary
already spreading a different family the same way. **Zero corpus reach** (fence
MIRROR = 0 before and after; ours-only implicit-net name sets byte-equal).

**R-IDXTYPE — `uvm_phase` as an ASSOCIATIVE-ARRAY INDEX TYPE.** The 12 OTHER
fence rows and the ONE golden-only implicit-net name left in SeqDriver and
SimpleUVM. `uvm_phase.svh:1722`,
`function void uvm_phase::get_predecessors_for_successors(output bit pred_of_succ[uvm_phase]);`
— golden reads the index TYPE NAME as an expression, fails to bind it and mints
`logic_net(work@top_tb.uvm_phase)` @1664:21; two more copies sit under
`array_typespec`s at @1896:17 and @1946:17. A TYPE-name-as-expression family, not
a `new[...]` one; ranked after R0.

**R-ADDRCONST — an ADDRESS LEAK in the associative-array typedef's
`array_typespec`, and it is NOT this law.** Boundary arm
`r10buvm22repro/g22.sv`, both views, the WHOLE diff is 12 lines:
`|vpiDecompile:22465217` / `|UINT:22465217` (and `…66073`) become `…69313` /
`…70169`. `g22.sv` contains **zero** occurrences of `new[`, and the census scores
0 TO-GOLDEN / 0 AWAY on it. Those values are `.bss` ADDRESSES of the emitting
binary, leaked into the RIGHT RANGE of the `array_typespec` our emitter mints for
`typedef C22 ka_cls_t[string];` (g22.sv:70) — where golden emits a
`string_typespec` and no constant at all. `readelf` on the two binaries:
pristine `.bss` starts at `0x156ba00` and leaks `0x156cac1`/`0x156ce19`; patched
`.bss` starts at `0x156ca00` and leaks `0x156dac1`/`0x156de19` — the values shift
by exactly the section's shift, `0x1000`. Both binaries are `ET_EXEC` (non-PIE),
so the value is DETERMINISTIC per binary (measured three times on pristine, twice
on patched, identical each time) and moves with ANY change to static layout.
Neither value is golden's, so the cell has no direction. A pre-existing emitter
bug in the associative-array typespec family; recorded, not touched.

**R-COPYCOUNT — the class body's copy count.** In the small grid arms golden
carries an `ELABPKG` copy of an out-of-body method body that we do not emit at
all, so the arm diffs carry a block of golden-only `REF ELABPKG IB CLS …` rows
in the PRISTINE run and in the PATCHED run alike. Pre-existing, unchanged by this
pass (it is why arm a1's REF cell count is 42 rather than golden's own),
uvm107's R-ELABMULT family.
