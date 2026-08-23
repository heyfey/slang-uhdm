# r10vbuvm31 — ADVERSARIAL VERIFICATION of r10buvm31
## § assocPropPatternInitRidesElem31, and the clause-(3) gate this pass added

**Verdict: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduces bit for bit from independently rebuilt binaries.  Breaking
the law found ONE class of `pristine-right -> patched-wrong` on legal SV — the
clause-(3) constant-width rewrite shrank a literal the source had WRITTEN 64
bits wide — which is fixed here by `bareDecimalDefault64_31` and re-gated.
Ship `r10buvm31.verified.patch`.

Base commit `265eea9`.  Three binaries, all built `-j 2` in this verifier's own
worktrees and frozen `chmod 555` before any sweep:

| binary | md5 | what |
|---|---|---|
| pristine | `c7c8fb93c856c9eb9bc57b534f9d770a` | 265eea9, verifier's own build |
| patched  | `80926ef2e2ca81f480cbb436e0283652` | + `/tmp/r10buvm31.patch` |
| verified | see §6 | + the clause-(3) gate below |

The first two md5s are the implementer's, reproduced exactly — the pass is
byte-deterministic and the patch is the code that was measured.

---

## 1. Reproduction of the implementer's numbers (all from the verifier's own baselines)

Baselines read from the verifier's worktree; `results/*.csv` untouched; NO
conversion claimed anywhere.

| claim | verifier's measurement |
|---|---|
| patch applies clean on a FRESH 265eea9 | `git apply --check` rc 0 (plain apply, no 3-way), 0 conflict markers |
| surface | 4 production files + `tools/probe/r10buvm31repro/` only; fence check 0/0/0/0 |
| goldens | pristine 23 PASS / 0 FAIL; patched 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` 23 FAIL |
| u2r testflags / default | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes, both binaries; 0 differing rows vs the committed `gate_uhdm2rtlil.csv` AND vs the verifier's own pristine control |
| surelog both modes | 1588 rows; default 471 CMP_EQUAL / 10 CMP_NOTEQUAL, testflags 466 / 9 — identical on both binaries; 0 differing rows vs committed `golden_surelog.csv` and vs the pristine control (status AND dump column) |
| `byteverify SELFCHECK=1` | surelog **9 / 956** movers, uhdm2rtlil **0 / 1358**; SELFCHECK 955/956 and 1357/1358 (the comparator is live) |
| the nine movers | exactly the nine predicted names; order-blind sorted diff = **4 lines each, identical in all nine**, and `default/Scoreboard` (the documented coin) shows the law's 4 lines and no coin noise |
| row heads | SeqDriver 47 -> **46** both modes, BuildUVMPkg 47 -> **46** both modes; SimpleUVM 56, Scoreboard 56, MiniAmiq 60, Earlgrey 11664 / 11404, Rggen 0 — unchanged |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS x2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical to pristine in both modes; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `g31a3.sv`, `r10svs6repro/b4_qual.sv` | 1 head -> **0 heads**, whole-design official `uhdm-cmp` EQUAL, in BOTH views |
| R0 | confirmed verbatim: `ref_obj (…::m_add_typewide_sequence::this_type::add_typewide_sequence)` 413:3-14 vs our `func_call`, in both SeqDriver modes |

Every `cmds.txt` was audited by BINARY PATH, file by file: 1458/1462 u2r and
1523/1573 surelog name the frozen binary of that sweep (the remainder are the
golden-cache-hit records with no slang invocation), and NO file anywhere names
the main-tree binary or the other sweep's binary.

The census counts in the implementer's arm table are per-cell after MERGING
the two views (`grid31.sh` concatenates `cen.g.def.txt` and `cen.g.elab.txt`).
This verifier's `vcmp31.py` keys every cell on `(VIEW, loc, kind, arrayType,
name, home)` so a DEF-only or ELAB-only move cannot hide inside the other
view's rows; its FIXED counts are therefore exactly 2x theirs
(g31a1 31 vs 17, g31a2 60 vs 30, g31a3 42 vs 21, b4_qual 8 vs 4) and its
MOVED-WRONG is 0 on all four of their arms, as they reported.

---

## 2. BREAKING THE LAW — the arms

Nine purpose-built arms (`gv31a1` … `gv31a8`, `gv31seg2`), every one accepted
by BOTH slang and Surelog, each built three ways (Surelog golden, pristine,
candidate) in BOTH views and scored cell by cell with the view-general
comparator.  What they cover: every assignment-pattern initializer shape
(assoc `[string]`/`[int]`/`[bit[7:0]]`/`[*]`; default-only, default-nonzero,
default-plus-keyed, keyed-only; simple, replicated, concatenation, `{}` empty,
nested); queue / dynamic / fixed; every home (class property protected /
local / static / rand / const, class in package / module / `$unit`, module
variable, package variable, `$unit` variable, function local, `initial`-block
automatic, generate block, program, interface, out-of-body method, generic
class); every element type (base-less enum, based enum, packed struct, packed
union, unpacked struct, typedef'd, int / byte / longint / `logic[127:0]` /
`bit[2:0]` / string / real / shortreal / time, class handle); 1..3 module
instances; and pattern operands that are NAMES, scoped names, calls and system
calls.  Positional controls (`gv31a4`): the same patterns in statement Rhs, a
call argument, a concatenation member and a `$display` argument.

Three object-level invariants were measured across every arm, not just the
cell verdict:

* **INVENTED-EXPR = 0 everywhere** — the candidate never gives a variable a
  `vpiExpr` that golden does not have.  Both kind gates hold.
* **OBJECTS-LOST = 0 everywhere** — nothing golden or pristine had disappears.
* **PATCH-ONLY-OBJECTS = 0 everywhere except one cell** (see R-V2).

---

## 3. THE DEFECT — clause (3) shrank a WRITTEN width

`gv31a7.sv`, class-scope properties whose pattern operands are ALL written 64
bits wide:

```systemverilog
class v31c7;
  int     cx_all64[] = '{64'd9, 64'd8};
  int     cx_q[$]    = '{64'd9};
  int     cx_cat[]   = {64'd9, 64'd8};
  byte    cz_all64[] = '{64'd9};
endclass
```

The patch's clause (3) resized **any** direct constant operand whose
`VpiSize()` happened to be 64.  Measured, DEF view, `array_var` carrier:

| cell | GOLDEN | PRISTINE | PATCHED |
|---|---|---|---|
| `cx_all64` | `OP75(C(ct=1,sz=64,dc=64'd9),C(ct=1,sz=64,dc=64'd8))` | **= golden** | `sz=32,sz=32` |
| `cx_q`     | `OP75(C(ct=1,sz=64,dc=64'd9))` | **= golden** | `sz=32` |
| `cx_cat`   | `OP33(C(ct=1,sz=64,…),C(ct=1,sz=64,…))` | **= golden** | `sz=32,sz=32` |
| `cz_all64` | `OP75(C(ct=1,sz=64,dc=64'd9))` | **= golden** | `sz=8` |

Four cells, `golden == pristine` and `golden != patched`: a
`pristine-right -> patched-wrong` on legal SV, on a field
`constant::Compare` reads.  The same shrink is visible mixed into other arms —
`gv31a1` `int cw_a[] = '{1, 64'd9, 32'd7}` (golden `32 / 64 / 32`, patched
`32 / 32 / 32`), `int cw_k[$] = '{9, 64'd4}`, `int cw_h[] = {1, 64'd9}`.

**The same over-reach ALREADY EXISTED at the base commit** in
`TypeEmit.cpp emitDynArrayVar`'s concatenation arm (`gv31a1` cell `mw_h`,
module scope: pristine already emitted `64'd9` at size 32).  The patch did not
invent the rule; it propagated an ungated one to two more carriers and to the
pattern kinds, which is where it started costing cells that had been right.

### The fix (shipped)

`src/EmitHelpers.h`, one predicate, applied at all THREE carriers (including
the pre-existing `TypeEmit` one, which is the same law):

```cpp
inline bool bareDecimalDefault64_31(const UHDM::any* o) {
    if (!o || o->UhdmType() != UHDM::uhdmconstant) return false;
    const auto* c = (const UHDM::constant*)o;
    if (c->VpiSize() != 64 || c->VpiConstType() != vpiUIntConst) return false;
    return std::string_view(c->VpiDecompile()).find('\'') == std::string_view::npos;
}
```

Clause (3) says "wherever `emitExpr` left the BARE-DECIMAL default of 64", and
this is that sentence written out.  It is a MEASUREMENT, not a guess — golden
sizes only the operands that had no written width:

| source | golden's operand sizes |
|---|---|
| `int d[] = '{1,2,3}` | 32 32 32 |
| `byte b[] = '{1,2}` | 8 8 |
| `bit [2:0] j[] = '{1,2,3}` | 3 3 3 |
| `logic [127:0] c[] = '{1,2}` | 128 128 |
| `longint f[] = '{1,2}` | 64 64 |
| `int a[] = '{1, 64'd9, 32'd7}` | 32 **64** 32 |
| `int q[$] = '{9, 64'd4}` | 32 **64** |
| `byte z[] = '{64'd9}` | **64** |
| `int c[] = {1, 64'd9}` (concat) | 32 **64** |
| `shortreal s[] = '{1.0,2.0}` | **64 64** (a real is not resized) |
| `'{default:0}` | 64 (a TAGGED operand is not a constant — unchanged) |

`vpiUIntConst` is what `emitExpr` stamps on a bare decimal and never on a
based literal (`64'd9` -> `vpiDecConst`, `8'hff` -> `vpiHexConst`,
`'1` -> `vpiBinaryConst` at size -1) or on a real (`vpiRealConst`), so the
constant-type test alone already separates them; the decompile tick test is
the belt-and-braces half and costs nothing.

### After the fix, on the same arms

| arm | patched | verified |
|---|---|---|
| `gv31a7` | EQUAL 21, FIXED 1, **MOVED-WRONG 4** | EQUAL 25, FIXED **5**, **MOVED-WRONG 0** |
| `gv31a1` | EQUAL 23, FIXED 47, STILL-UNEQ 51 | EQUAL 23, FIXED **61**, STILL-UNEQ **41** |
| `gv31a2` `gv31a3` `gv31a4` `gv31a6` `gv31a8` | MOVED-WRONG 0 | MOVED-WRONG 0 |
| `g31a1` `g31a2` `g31a3` `b4_qual` (the implementer's) | unchanged | unchanged, still 0 / 0 / 0-heads / 0-heads |

`gv31a6` ($unit scope) goes 1 head -> **0 heads** in both views on both
candidates — a third whole-design `uhdm-cmp` EQUAL the pass earns.

---

## 4. Residues the arms measured (ranked; none of them blocks the landing)

* **R-V1 — package-scope operands are not FOLDED like golden's.**  Golden's
  package data-declaration path reduces; ours does not.  `gv31a5` `int pd_p[]
  = '{PP, PP+1}` reads golden `C(4), C(5)` against our `C(4), OP24(C(4),C(1))`;
  `gv31a5` `'{$bits(int), 1}` reads golden `C(32)` against our
  `sys_func_call:$bits`; `gv31a3` `e_nobase_t pe_d[] = '{E_A, E_B}` reads
  golden `C(ct=7,sz=0,dc=0/1)` against our `ref_obj:E_A/E_B`.  All three are
  cells that were EMPTY before this pass, so the pass moves them from
  "absent" to "present but unfolded"; none is a regression, and none is
  reachable in either corpus (measured: producer B of the prediction is 0).
* **R-V2 — the only patch-only OBJECT in the whole arm set.**  The unfolded
  `$bits(int)` above carries its type argument as an `int_var` that golden
  (which folded) does not have: 1 object, in each of the two package views of
  `gv31a5`.  `tf_call::Compare` DOES read `Tf_call_args()`, so the object is inside a
  compared vector — but that vector belongs to a `sys_func_call` node golden
  does not have AT ALL (golden folded the operand to `C(32)`), so the operand
  already first-fails on kind before the argument list is reached.  It is
  subordinate to R-V1 and disappears the moment R-V1 is fixed.
* **R-V3 — a real literal in a pattern is sized at the ELEMENT width by
  `emitExpr` itself, not by clause (3).**  `shortreal pd[] = '{1.0, 2.0}`
  gives 32 where golden gives 64, on the gated binary too (the gate excludes
  `vpiRealConst`), while the scalar `shortreal x = 1.0;` gives 64 on both.
  Pre-existing emitter behaviour in the pattern path; out of this law's scope.
* **R-V4 — a byte-width bare decimal keeps its untruncated decompile.**
  `byte b[] = '{8'hff, 300}` reads golden `C(ct=9,sz=8,dc=44)` against our
  `dc=300`: the pass now gets the SIZE right and the VALUE is still the
  written one.  Pre-existing; the same family as the implementer's R2.
* **R-V5 — PRE-EXISTING SEGFAULT, both binaries, unrelated to this pass.**
  A GENERIC class declared inside a module and specialised segfaults
  `slang-uhdm --elabuhdm` (rc 139) at the BASE COMMIT: `gv31seg2.sv` has no
  pattern initializer at all and still crashes on pristine and on patched
  alike.  It matters operationally because `verify_golden.py` records rc=139
  as `SLANG_REJECT` wearing the last stderr warning (RESUME §9), so it is
  invisible in a status histogram; and because a boundary or grid arm that
  contains one produces NO database, which `uhdm-cmp` then reports as 0 heads.
  `gv31a5.sv` hit exactly this; `gv31a5b.sv` is the same arm with the generic
  class removed and is the one that actually tests the elab view.
* **R-V6 — the implementer's R1 confirmed.**  `§ arrayVarSignedWritten8` never
  reached `emitPkgArrayVar`: golden puts `vpiSigned:1` on a package-scope
  `array_var` and nothing on its element; we do the opposite.  It is the head
  of `g31a1`/`g31a2`/`gv31a5b` on BOTH binaries, and it masks the initializer
  field there — which is why `g31a3.sv` (no package array variable) exists.
* **R-V7 — a scorer note, not a defect.**  In the ELAB view we emit 5 copies
  of a module-nested `class_defn`'s members where golden emits 3
  (`g31a1` cells at 22:15 / 23:16 / 24:14).  The payload is IDENTICAL on both
  sides; only the cardinality differs, and it differs identically on pristine
  and on the candidate.  A view-merged multiset scorer buries this; a
  view-keyed one surfaces it as MOVED-STILL-UNEQUAL.

---

## 5. Files

* `gv31a1.sv` clause-3 adversary (explicit widths, odd element widths, three
  carriers) · `gv31a2.sv` key x shape x home matrix · `gv31a3.sv` element-type
  matrix · `gv31a4.sv` position controls + 3 instances · `gv31a5.sv` /
  `gv31a5b.sv` name / scoped-name / call / system-call operands (the `b`
  variant is the one whose ELAB view builds) · `gv31a6.sv` `$unit` scope ·
  `gv31a7.sv` THE regression probe · `gv31a8.sv` boundary literals
  (unsized-based, unbased-unsized, wide decimals, real / shortreal / time) ·
  `gv31seg2.sv` the pre-existing generic-class elab segfault, minimised.
* `vcmp31.py` — the VIEW-GENERAL three-way multiset scorer (keys on
  `(view, loc, kind, arrayType, name, home)`; reports FIXED / MOVED-WRONG /
  MOVED-STILL-UNEQUAL / UNCHANGED-UNEQUAL and a judge-blind vpiParent split).
* `newobj.py` — objects the candidate emits that NEITHER golden NOR pristine
  has, and objects it loses.  `invent.py` — variables the candidate gives a
  `vpiExpr` that golden leaves empty.
* `predictv31.py` + `PREDICTION.txt` — the verifier's OWN mover prediction,
  written from the pristine + golden corpus censuses before the verified
  sweep, by a different route from the implementer's (restrict producer A to
  test-modes where WE HAVE a database; add producer B for the new gate).
* `vbuild31.sh` / `vsweep31.sh` / `vbound31.sh` — parameterised drivers; they
  hard-code no path and no other pass's directories.

---

## 6. THE FULL BATTERY ON THE VERIFIED BINARY

Verified binary md5 `494caa64e0035fc8fd25529dad9af088`, built `-j 2` in the
verifier's worktree and frozen `chmod 555` before any sweep.  `SLANG_UHDM` was
exported explicitly to it for every step; `GOLDEN_DEFER` never set.

| gate | result |
|---|---|
| build | `Built target slang_uhdm`, rc 0 |
| goldens | **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false` **23 FAIL** |
| u2r testflags | **0 differing rows** vs the committed `gate_uhdm2rtlil.csv` AND vs the verifier's own pristine control; 679 / 50 / 2 |
| u2r default | **0 differing rows** vs the pristine control; 679 / 50 / 2 |
| surelog both modes | **0 differing rows of 1588** vs the committed `golden_surelog.csv`, vs the pristine control, AND vs the implementer's patched sweep (status AND dump column); histogram unchanged: default 471 / 10, testflags 466 / 9.  **NO conversion is claimed; `results/*.csv` is untouched.** |
| byteverify SELFCHECK=1, ver vs pristine | surelog **9 / 956** — the same nine names, with byte-for-byte the SAME hashes as the implementer's patched run; uhdm2rtlil **0 / 1358**; SELFCHECK 955/956 and 1357/1358 |
| byteverify SELFCHECK=1, ver vs PATCHED | **0 / 956** and **0 / 1358** — the clause-(3) gate changes NOTHING in either corpus, exactly as predicted |
| mover attribution | order-blind sorted diff, 4 lines per database, identical in all nine, `default/Scoreboard` included |
| row heads | SeqDriver 46 / 46, BuildUVMPkg 46 / 46, SimpleUVM 56 / 56, Scoreboard 56, MiniAmiq 60 / 60, Earlgrey 11664 / 11404, Rggen 0 — identical to the patched binary |
| canaries | surelog `ok=52 changed=0 absent=0`; u2r `ok=8 changed=0 absent=0`; `ctcan2` PASS x2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical to pristine, both modes; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |

### The mover prediction, written before the verified sweep

`PREDICTION.txt`, derived from the pristine and golden corpus censuses only
(no candidate database read), by a route independent of the implementer's:
producer **A** (the law) restricted to test-modes where WE HAVE a database —
which is what collapses golden's 38 candidate test-modes to nine, since
AmiqEth / Opentitan / Ibex / CoresSweRV / Driver / Monitor / SimpleClass1 /
SimpleInterface / UVMNestedSeq / UVMSwitch / BuiltInMethod all have `o=0`
databases of ours — and producer **B** (the new gate), scanned over OUR OWN
databases for an unsized-array initializer holding a direct constant with a
WRITTEN width, which is **0 in both corpora**.  Both predictions were then
measured exactly: 9 / 956 and 0 / 1358 against pristine, 0 and 0 against the
implementer's patched binary.

### Boundary gate — a COPY of the whole probe tree, no path filter

`.sv` AND `.v`, both binaries, both views, file mode AND directory mode; the
arm list on fd 3, every child `</dev/null`, `PROCESSED` asserted against
`LISTED`, scratch keyed on the RELATIVE path, rc recorded per cell.

```
MODE=file VIEW=def   PROCESSED=3548 LISTED=3548 DIFFER=6  rejects 138/138  asym 0
MODE=file VIEW=elab  PROCESSED=3548 LISTED=3548 DIFFER=6  rejects 150/150  asym 0
MODE=dir  VIEW=def   PROCESSED=1517 LISTED=1517 DIFFER=7  rejects 120/120  asym 0
MODE=dir  VIEW=elab  PROCESSED=1517 LISTED=1517 DIFFER=7  rejects 126/126  asym 0
```

(3548 = the 3545 arms of the base tree plus the implementer's three new ones;
1517 = 1516 + their directory.  No `asym.txt` was written in any of the four
configurations, so no arm is accepted by one binary and rejected by the other.)

The FILE-mode differing arms are the law's own cells and nothing else, each
scored against a rebuilt Surelog golden with the view-general comparator:

| arm | FIXED | MOVED-WRONG | new objects | heads |
|---|---|---|---|---|
| `r10buvm31repro/g31a1.sv` | 31 | 0 | 0 | 1 -> 1 (residue R-V6) |
| `r10buvm31repro/g31a2.sv` | 60 | 0 | 0 | 1 -> 1 (residue R-V6) |
| `r10buvm31repro/g31a3.sv` | 42 | 0 | 0 | **1 -> 0, uhdm-cmp EQUAL, both views** |
| `r10svs6repro/b4_qual.sv` | 8 | 0 | 0 | **1 -> 0, uhdm-cmp EQUAL, both views** |
| `r10uvm29repro/t39a/dut.sv` | 2 | 0 | 0 | 1 -> 1 |
| `r10uvm29repro/t39c/dut.sv` | 6 | 0 | 0 | 1 -> 1 |

DIRECTORY mode adds three arms and only three, in BOTH views — and all three
are the documented `vpiTaskFunc` LIST-ORDER COIN, not a content change:

```
./r10uvm75repro   raw diff 16 lines   ORDER-BLIND sorted diff 0     def
./r10uvm76repro   raw diff 18 lines   ORDER-BLIND sorted diff 0     def
./r10v109repro    raw diff 26 lines   ORDER-BLIND sorted diff 0     def
   (all three: sorted diff 0 in the elab view too)
```

while the law's own directories move with content (`r10buvm31repro` 703/1011,
`r10svs6repro` 16/34, `r10uvm29repro/t39a` 4/11, `t39c` 12/28 sorted lines,
def/elab).

Every bind-window arm in the tree is byte-identical: `§ classArgBind12`,
`§ retNameRecvCollapseArgsBindLikeBody15`, `§ collArgNamedBlkLocalNoBind15`,
`§ controlBodyNoBind28`, `§ blkLocalSameCtrlDepthArgBinds57/64`,
`§ pkgVarBindsOnlyThroughInstance88`, `§ formalDefaultBindsLikeBody13`,
`§ classInBodyRecvCallArgNoBind52`, `§ superNewFormalBinds28`, uvm81's formal
contest, sd10/sd12 `scopedReach`, `§ newArrayArgNoBind16`'s
`paDynamic_array_new` arm, `§ namedTfArgsFormalSlots4`, `§ writtenCallArgs16`,
`§ genLpPortConnCopyableOnly11v`, `§ emptyArgSlotIntZero24`,
`§ dottedIdxRecvFromSyntax23`, `§ droppedIdxRecvCall26`,
`§ foreachElabLoopVarAnyKindBinds17`, `§ foreachArraySelfSelectAssignDropsTs19`,
`§ foreachPkgClassArrayVar25`, `§ castTargetKeywordTypespecKind96`,
`§ enumNoBaseTypespecZeroBits28`, `§ binOpLeftmostSelectBits27`,
`§ genBlockBitsNoLeftmostFold27v`, `§ bitsSelectIgnoredRootBits95`,
`§ invalidCtorCallArgsUnwrap90` and the uvm89/92/94/95 name-text arms.
**This law owns no binding window**: it never calls a bind, and the only
argument it changes in any `emitExpr` call is the PARENT POINTER of the
top-level operation — from the `array_var` to its own `vpiReg` element, which
is one step DEEPER in the same chain, so every scoped-reach walk sees the same
scopes in the same order.  `gv31a5b.sv` is the arm that tests exactly that:
pattern operands that are names, `pkg::`-scoped names, static-method calls and
system calls at all three carriers, in both views — MOVED-WRONG 0.

---

## 7. VERDICT

**ACCEPT WITH FIX** — ship `/tmp/r10buvm31.verified.patch`.

* The law `§ assocPropPatternInitRidesElem31` is correctly decoded, correctly
  gated, and correctly located at three carriers.  It never invents an
  initializer, never loses an object, owns no binding window, and it clears
  the 47-line head on four row-modes plus three whole-design `uhdm-cmp`
  EQUALs on purpose-built sources (`g31a3.sv`, `r10svs6repro/b4_qual.sv`,
  and — new here — `gv31a6.sv` at `$unit` scope).
* Clause (3) as shipped by the implementer was **over-broad** and produced a
  measured `pristine-right -> patched-wrong` on legal SV (four cells,
  `gv31a7.sv`).  The gate `bareDecimalDefault64_31` narrows it to the
  bare-decimal default the clause's own text describes, removes the same
  over-reach from the PRE-EXISTING `TypeEmit` copy, and is proved
  corpus-neutral: 0 movers against the implementer's binary in both corpora.
* Every gate is green on the verified binary, and NO row of either corpus
  changes status or dump in either mode.  No conversion is claimed;
  `results/*.csv` is untouched.
