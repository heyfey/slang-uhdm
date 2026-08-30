# r10v163 — the ADVERSARIAL VERIFICATION of r10uvm163

Verdict: **ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduces bit for bit on independently built binaries. One face of the law was
never crossed and it regresses legal SystemVerilog: **an ordered argument that
names a type formal of the DECLARING class itself**. The fix is
§ `ownTypeFormalArgPushesNothing163v`, four lines at the listing site plus the
declaring scope threaded to it; with it, MOVED-WRONG is **0** in every arm-view
and the corpus is byte-for-byte what the as-shipped patch produced.

Base commit **578ffc2**. LHS is **always** golden (Surelog); RHS is always ours.
The judge is `~/.local/bin/uhdm-cmp` and nothing else. slang was NOT patched;
`results/*.csv` were READ ONLY.

Binaries, all three built here from the two worktrees, `-j 2`:

| | md5 |
|---|---|
| pristine, 578ffc2 | `55fb7e0612ac4dc2008d1e5906b184e8` |
| as shipped, `/tmp/r10uvm163.patch` | `04bf7b27b6e9bfb62c3e13177e14010e` |
| verified, `/tmp/r10uvm163.verified.patch` | `9668dad46cf923eddd107907b89ca1f7` |

The first two md5s are the implementer's own two, reproduced independently.

---

## 1. REPRODUCTION of the as-shipped patch (before any fix)

| claim | reproduced |
|---|---|
| applies clean on fresh 578ffc2, surface = 3 production files + `r10uvm163repro/` | yes, `git apply -3` rc 0, no conflict markers |
| fence check, the four slang-fenced names (spelled only in `canaudit.sh`, which is their mechanical judge) | **0 / 0 / 0 / 0** |
| goldens 23 PASS / 0 FAIL on both binaries, 23 FAIL on `/bin/false` | yes, `SLANG_UHDM` exported to each |
| u2r 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes | yes |
| 0 differing rows, both corpora, both modes, vs committed baselines AND this base's own pristine CSVs | yes — **5 ct8rows comparisons PASS** |
| byte movers 1 / 956 surelog, 0 / 1358 uhdm2rtlil | yes — the mover is `default/Scoreboard-59431470`, the one predicted by name |
| Scoreboard/default 145 → 95 cmp lines, 1 head, a DIFFERENT object | yes |
| the other twelve row-modes' head logs BYTE-IDENTICAL | yes, `cmp` on all twelve |
| census 9 UVM row-modes: WRONG 1 → 0, AWAY 0, RESHAPE 0, RIGHT 2478 → 2479 | yes |
| canaries ok=52 / ok=8 changed=0, ctcan2 PASS both, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | yes |
| five protected DBs unchanged, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | yes |
| the mover's order-blind attribution: 52 lines, all additions, all the law's | yes — 52 additions, 0 deletions (the only `<` line is the dump's own filename banner) |
| Scoreboard/default is not the coin | yes — 3 runs per binary: **145, 145, 145** pristine and **95, 95, 95** patched, across two distinct patched database hashes |
| boundary: 4 earlier-pass arms move, all re-measured MOVED-WRONG 0 / AWAY 0; `g22.sv` and `l154_noenum.sv` equidistant with the same head | yes — 17506/17506 and 26436/26436; 1632/1632 and 1636/1636; id/value-normalised cmp diff **0 lines** |

Every `cmds.txt` in all six sweep workdirs was audited by ABSOLUTE PATH: each
names exactly one binary and no other `slang-uhdm` path appears anywhere.

---

## 2. THE REGRESSION — pristine right, patched wrong, on legal SV

Arm S cell `s31_arg_is_own_formal`, arm P cells `p03` / `p11` / `p05` / `p06`,
arm Q cells `q04` / `q05` / `q06`. The shape:

```systemverilog
package Pk_Bet;
  import Pk_Alef::*;                       // GenAlef lives in Pk_Alef
  class ArgIsFormalBet #(type PP = int);
    GenAlef#(PP) p03_arg_is_formal;        // the argument names the class's OWN formal
  endclass
endpackage
```

| cell | written | golden | pristine | as shipped |
|---|---|---|---|---|
| `p03` / `p11` / `s31` | `#(PP)` | **no listing at all** | no listing | **1 entry `ONE:int_typespec:PP`** |
| `q06` | `#(PP, PP)` | **no listing at all** | no listing | **2 entries** |
| `p05` | `#(CfgBet, PP)` | **ONE** entry `ONE:CfgBet` | none | 2 entries |
| `p06` | `#(PP, CfgBet)` | **ONE** entry `TWO:CfgBet` | none | 2 entries |
| `q04` | `#(Loc_nib_t, PP)` | **ONE** entry `ONE:Loc_nib_t` | none | 2 entries |
| `q05` | `#(PP, Loc_nib_t)` | **ONE** entry `TWO:Loc_nib_t` | none | 2 entries |

`p03`/`p11`/`s31`/`q06` are **MOVED-WRONG** — the pristine binary agreed with
golden and the patched one does not — in **both** views. `p05`/`p06`/`q04`/`q05`
are the same defect with a witness left: golden pairs the CONCRETE argument with
the formal the skipped one would have taken, so the index ADVANCES past the
skipped argument exactly as it does for a value formal.

**The candidate cause was crossed out by measurement, not reasoning.** Arm P
exists to separate two readings, and it has ZERO Surelog errors:

* *(A) the declaring class is parameterized* — REFUTED. `p02` (a type-
  parameterized declaring class), `p04` (a value-parameterized one) and `p10`
  (the same in `$unit`) all carry golden's listing with a concrete argument.
* *(B) the written argument names a type formal of the declaring class* —
  HOLDS, and only for **that** class's own formals: an OUTER class's formal seen
  from a nested class (`q01`) and a MODULE's type parameter (`q10`) ARE listed
  by golden — as an `unsupported_typespec` carrying the written name — and a
  class-scope TYPEDEF argument (`q03`) keeps its ordinary entry.

> ### § ownTypeFormalArgPushesNothing163v
>
> In § `classPropSpecForeignPkgHome163`'s ordered-argument loop, a written
> argument that names a **type parameter declared by the declaring class
> itself** contributes NO `vpiParameter` / `vpiParamAssign` entry, and still
> ADVANCES the index — the same clause a VALUE formal's argument already had.

### The fix

`src/UhdmExporter.cpp`, inside `emitClassPropSpecParams163`: a
`declScope->find(<identifier>)` that yields a `TypeParameter` skips the entry;
`src/TypeEmit.cpp` passes `declSymbol.getParentScope()` (the declaring class's
scope, which `siteKind53 == ClassType` already guarantees); the header carries
the law and its arm cells. A direct `find` in that ONE scope and no lookup walk
— `q01` and `q10` are the arms that forbid a walk.

### After the fix

| arm-view | as shipped | verified |
|---|---|---|
| S / DEF, S / ELAB | MOVED-WRONG 1, TO-GOLDEN 12 | **MOVED-WRONG 0**, TO-GOLDEN 12, HELD-RIGHT 5 |
| P / DEF, P / ELAB | MOVED-WRONG 2, RESHAPE 2, TO-GOLDEN 7 | **MOVED-WRONG 0, RESHAPE 0**, TO-GOLDEN **9** |
| Q / DEF, Q / ELAB | MOVED-WRONG 1, RESHAPE 4, TO-GOLDEN 3 | **MOVED-WRONG 0**, RESHAPE 2, TO-GOLDEN **5** |
| T, N, B, E (all views) | MOVED-WRONG 0 | MOVED-WRONG 0, unchanged |

and on the corpus the fix is **invisible**: the order-blind whole-dump diff
between the as-shipped and the verified database of the one mover is **0 lines**
(the byte difference is RESUME.md §9's documented Scoreboard order coin), the
mover set is the same 1/956 + 0/1358, and all twelve head logs are byte-identical
to the as-shipped ones.

---

## 3. THE ADVERSARIAL GRID (`GRID.r10v163.txt`, every cell, both views)

Seven arms, named and spelled unlike the implementer's so an agreement is not a
copy. `armv163.sh` builds each with Surelog in both views and with two frozen
binaries in both views; `scorev163.py` joins golden / pristine / patched on the
HOLDER NAME (never on the span, which is what §53 moves) as a MULTISET.

* **S — the SITES** (`v163_s_sites.sv`): class property, static, rand, local,
  protected, two names on one declaration, a second declaration of one
  specialization, a second specialization of one generic, a class-scope
  TYPEDEF, a class-scope type localparam, a method formal, a method local, a
  package variable, a module variable with and without `= new`, a `$unit`
  variable, a class in a module / interface / program, three instances of the
  holder module. Foreign-home properties: **12 TO-GOLDEN**; every same-home
  control and every non-class site HELD.
  The class-scope **TYPEDEF site is NOT reached** — the pristine-vs-verified
  order-blind dump diff of this arm is **323 lines, all additions, all this
  law's objects, no `<` line at all** — so the over-reach hypothesis
  (`siteKind53 == ClassType` also covers a typedef and a type localparam) is
  REFUTED by measurement.
* **T — the CONTENT** (`v163_t_content.sv`): 24 argument spellings — `int`,
  `bit[3:0]`, `byte`, `logic signed [7:0]`, a `$unit` typedef, an imported
  typedef, a package-scoped typedef, two enums, a packed struct, a class, a
  class SPECIALIZATION, duplicate arguments, one-of-two, two-of-three, a value
  formal first / last / in the middle, an expression value, value-only, NAMED
  arguments, a bare default, a non-parameterized class, and the fixed / queue /
  dynamic / associative declarators. **14 TO-GOLDEN, 0 MOVED-WRONG**; named
  arguments, the bare default and the non-parameterized control all HELD.
* **P — the PARAMETERIZED DECLARING CLASS** (`v163_p_paramcls.sv`): the arm that
  found the regression and decided its cause. Zero Surelog errors.
* **Q — how far "a type formal" reaches** (`v163_q_formalarg.sv`): the outer
  class's formal, a module's type parameter, an interface's, and a class-scope
  typedef as the negative control.
* **N — the HOME WALK** (`v163_n_nest.sv`): depth 1 / 2 / 3 nesting in a
  package, cross-package, `$unit` and module; a generic NESTED IN A CLASS; a
  self-typed property; the argument naming the declaring class; a class
  extending a foreign base. Cross-package depth 1 and 2 are TO-GOLDEN, all
  same-home depths HELD.
* **B — the BUILT-IN FENCE** (`v163_b_builtin.sv`, run WITH built-ins):
  `mailbox` / `semaphore` / `process` in a package class, a `$unit` class and
  cross-package — **9 HELD-RIGHT**, and the arm's cmp distance improves 81 → 32.
* **E — the spelling EDGES** (`v163_e_edges.sv`, WITH built-ins): an empty
  `#()` (HELD), a user class whose name collides with the built-in registry key
  (unchanged on both binaries), and a two-class control. Mixing ordered and
  named arguments is ILLEGAL SV — both tools reject it, measured, so no cell
  spells it.

---

## 4. GATES, on the VERIFIED binary (`GATES.r10v163.txt`)

goldens **23 PASS / 0 FAIL** (and 23 FAIL on `/bin/false`); u2r
**679 / 50 / 2** in both modes; **six** ct8rows comparisons PASS — committed
baselines and this base's own pristine CSVs, surelog and u2r, both modes,
status column and dump column; byte movers **1 / 956** (the predicted database)
and **0 / 1358**, comparator selfcheck 955/956 and 1357/1358; census over the
nine UVM row-modes **RIGHT 2479, WRONG 0, RESHAPE 0, AWAY 0**; canaries
`ok=52` / `ok=8` `changed=0`; `ctcan2` PASS on both corpora; `canaudit
audited=29 UNCOVERED=0 FENCE-BREACH=0` from THIS directory; the five protected
databases unchanged with SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a`;
every `cmds.txt` audited by absolute path. The four slang-fenced tests were
never dispatched and are not spelled in any file here.

**Wide boundary** (`bound163.sh` over a copy of the whole probe tree, this
directory's arms included as the positive control):
`LISTED=4650 PROCESSED=4650 PRODUCED_DBS=4494 MOVED_ARMS=13 RC_DIFFS=0`. Six of
the thirteen are this directory's own arms; three are the pass's `g163_*`; the
remaining four are the same four the implementer reported, and all four were
re-measured against golden rebuilt in both views with the VERIFIED binary:
**MOVED-WRONG 0 and AWAY 0 in every arm-view**, with 1 WRONG→RIGHT in
`r10uvm156repro/g156_b_forms.sv` and 1 in `r10uvm23repro/t34g/t.sv`, and
`r10buvm22repro/g22.sv` + `r10uvm154repro/l154_noenum.sv` equidistant from
golden on both binaries with the same head object (id/value-normalised cmp diff
0 lines). The committed arms of **r10uvm160, r10uvm156's other files, r10uvm139
and r10uvm162 did not move at all** — byte-identical databases in both views.

---

## 5. RESIDUES, ranked

* **V1 — an argument that Surelog cannot resolve is an `unsupported_typespec`
  carrying the WRITTEN name.** Arm Q `q01` (an outer class's type formal seen
  from a nested class) and `q10` (a module's type parameter): golden's actual is
  `unsupported_typespec (PP)` / `(MP)`; ours is `int_typespec (PP)` /
  `class_typespec (CfgUnitQ)` — for `q10` we resolve the parameter to the
  instance's actual type, which golden never does at the declaration site. Both
  cells were AWAY-by-absence before this pass (no Parameters vector at all), so
  this is a NEW residue of a mover that still moves toward golden: the vector
  size and the `type_parameter` name now match. **Ranked first** — it is the
  only residue this pass's own law creates.
* **V2 — the typedef ARGUMENT's name is the canonical spelling, not the written
  one.** Arm T `t03` (`Vec_k_t` imported): golden names the actual
  `Vec_k_t`, we name it `Pk_Kappa::Vec_k_t`; `t04` (`Pk_Kappa::Vec_k_t` written
  scoped): golden's actual is an `unsupported_typespec`, ours a `bit_typespec`.
  Same family as V1 — Surelog names the argument's typespec from the WRITTEN
  text.
* **V3 — `--elabuhdm` SEGFAULTS on a self-typed property of a parameterized
  class**, on BOTH binaries, i.e. PRE-EXISTING and untouched by this pass.
  Eight lines of legal SV, `v163_iso_selfspec.sv`:
  `class SelfNu #(type TT=int); SelfNu#(int) x; endclass` in a package, with one
  `SelfNu#(int)` instance. `rc=139`, which `verify_golden.py` records as
  SLANG_REJECT wearing the last stderr warning (RESUME.md §9). The DEF view is
  fine. No corpus row reaches it.
* **V4 — a class nested THREE deep gets no declaration-site `class_typespec` in
  golden at all** (arm N `n03` / `n13` / `n21` / `n31`, with the arm carrying
  ZERO Surelog errors): golden has no cell, both binaries have one, and the
  law now also gives ours a listing. Pre-existing in KIND (the object's
  existence), and the arm's cmp distance is identical on both binaries.
* **V5 — a generic NESTED IN A CLASS is invisible to §53 and §163** (arm N
  `n04`): its parent scope is a ClassType, not a Package, so `pkgGeneric53` is
  false and both binaries emit a listing golden does not have. Pre-existing,
  unchanged.
* **V6 — a class declared in an INTERFACE has no declaration-site
  `class_typespec` on our side at all** (arm S `s60`, arm Q `q20` / `q21`):
  golden has the cell, we have nothing, on both binaries. Pre-existing,
  unchanged; the PROGRAM site (`s70`) works and is TO-GOLDEN.
* **V7 — a user class whose name collides with a built-in registry key**
  (`Pk_Edge::mailbox`, arm E `e04`): Surelog emits NO cell for it; we emit one.
  Pre-existing, unchanged, and the scoped spelling keeps §163 out of it.
* **R0 stands as the implementer wrote it** — Scoreboard/`default`, 95 cmp
  lines, the mirror `LHS: <null>` on our `class_typespec (type_id)` at
  `uvm_object_defines.svh:483:12-483:34` under `class_defn (work@my_scoreboard)`.
  Verified independently: the object is present 26 times in the pristine
  database and 26 times in the verified one and appears nowhere on the
  order-blind dump diff, so it is a pre-existing deficit this pass unmasked, not
  one it created.

---

## 6. FILES

* `armv163.sh` — build one arm with Surelog and two frozen binaries, both views,
  every rc printed, `BUILTIN=1` for the built-in arm.
* `scorev163.py` — the golden/pristine/patched multiset join, keyed on the
  holder name; exit 1 on any MOVED-WRONG.
* `v163_{s,t,n,p,q,b,e}_*.sv` — the seven arms; `v163_iso_selfspec.sv` — the
  eight-line pre-existing `--elabuhdm` segfault.
* `GRID.r10v163.txt` — every cell, both views, as shipped AND verified.
* `GATES.r10v163.txt` — the gate transcript with the three binary md5s.
* `canaudit.sh` / `canaries.sh` / `ctcan2.sh` — copies, so the audit RUNS here.
* the census instrument is the implementer's `r10uvm163repro/ct163cen`, audited
  (its `--selftest` passes here) and reused deliberately: a verifier that
  rewrites the instrument cannot tell an instrument bug from a code bug.
