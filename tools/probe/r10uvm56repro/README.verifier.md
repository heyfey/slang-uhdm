# r10uvm56 — ADVERSARIAL VERIFICATION

**VERDICT: PASS.** Every number in the implementer's report reproduced on a
worktree I built myself from `/tmp/r10uvm56.patch` against a fresh 946579a, with
a PRISTINE 946579a twin I also built. All five gates green. Four ARMS THE
IMPLEMENTER NEVER BUILT found **zero over-fires** and 14 further over-binds that
the law correctly clears. Six findings follow, all LOW/INFO — none blocks the
landing, and none is a defect in the shipped code.

* patched worktree `.claude/worktrees/r10uvm56v` (branch `r10uvm56vwt`)
* pristine worktree `.claude/worktrees/r10uvm56vp` (branch `r10uvm56vpris`)
* `git stash` never used (the 2 stashes in this repo are dated 2026-07-24, older
  than this pass — `git stash list --date=iso`)
* nothing under `results/` was written: `git status --short results/ scripts/ tests/`
  prints NOTHING both before and after the patch and after every sweep.

---

## 0. THE PATCH ITSELF

```
$ md5sum /tmp/r10uvm56.patch
7f3ee584cc8232ad485d6a50d37a672e   ← matches the claim
$ wc -l /tmp/r10uvm56.patch → 1827   ← matches
$ git apply --stat /tmp/r10uvm56.patch      (rc 0, full output)
 include/UhdmExporter.h                  |   12 +
 src/ModuleEmit.cpp                      |    8
 src/TypeEmit.cpp                        |  105 +++++
 src/UhdmExporter.cpp                    |   11 +
 tools/probe/r10uvm56repro/README.md     |  646 ++++
 tools/probe/r10uvm56repro/{a1_witness,a2_local,a3_scope,a4_kinds,a5_argpos,
                            a6_type,a7_recur,a8_newlhs}.sv,
                           {arm.sh,cells.py,cells.sh,owntab.py,retlist.py,
                            retown.cpp,retx.py}
 20 files changed, 1687 insertions(+)
```

* **20 paths, 4 production + 16 assets, production = 136 added / 0 deleted**
  (`sed -n '1,180p' patch | grep -c '^-[^-]'` → **0**). Confirmed.
* **No `results/*.csv`, no harness script, no slang header.** The 11 grep hits
  for `results/|scripts/|tests/` are all PROSE INSIDE `README.md` (lines
  209–766); no `diff --git` path touches them, and nothing under
  `~/.local/include/slang` appears anywhere in the patch.
* `git apply --check` rc 0 and a real `git apply` rc 0 on a fresh 946579a.
* The tree I built is bit-identical to the delivered patch:
  `diff <(sed -n '1,180p' /tmp/r10uvm56.patch) <(git diff 946579a -- include src)`
  → **identical** (both md5 `ac79f48590f3e91a4c9b46a4a158d163`).

---

## 1. THE FIVE GATES — mine beside theirs

| gate | measurement | THEIRS | MINE | verdict |
|---|---|---|---|---|
| 1 | pristine md5 | `ed106184c97207183fe1316211507882` | **same** | ✓ (and identical to main-tree `build/slang-uhdm`, so the control is valid) |
| 1 | patched md5 | `de52f8be5bfa705510cb622cadad4d12` | **same** | ✓ md5 CHANGED, asserted in a SEPARATE command before any sweep — and the build is reproducible bit-for-bit |
| 2 | goldens | 23 PASS / 0 FAIL | **23 / 0** | ✓ |
| 2 | negative control | 0 PASS / 23 FAIL | **`neg PASS=0 neg FAIL=23`**, rc 1 | ✓ the control fires |
| 3 | u2r testflags status | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | **same** | ✓ |
| 3 | u2r dump column | 496 match / 183 differ / 52 blank | **same** | ✓ |
| 3 | `ct8rows.sh` | 0 differing ROWS / 731 | **0 differing ROWS (0 diff row-sides)**, `PASS` | ✓ |
| 4 | surelog default | 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL | **same** | ✓ |
| 4 | surelog testflags | 463 / 10 / 5 / 286 / 23 / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM | **same** | ✓ |
| 4 | surelog dump column | match 225 / 165, differ 242 / 298, blank 327 / 331 | **same** | ✓ |
| 4 | `ct8rows.sh` | 0 differing ROWS / 1588 | **0 differing ROWS**, `PASS` | ✓ GOLDEN_DEFER left at default, 5 DEFERRED both modes |
| 5 | u2r byte | 0 movers / 679; SELFCHECK 678/679; SELFCHECK1 = 1 | **same** | ✓ |
| 5 | surelog byte | 7 movers / 953; SELFCHECK 952/953; SELFCHECK1 = 8 | **same, same 7 paths, same md5 prefixes** | ✓ |

The 7 movers, my run, byte for byte the same set:
`default/{SimpleUVM,Scoreboard,SeqDriver,BuildUVMPkg}` and
`testflags/{SimpleUVM,SeqDriver,BuildUVMPkg}` — `BuildUVMPkg` reads
`patched=2f5eb902c640 pristine=6455c28a7a86` in BOTH modes, exactly as claimed.

### 1.1 mover attribution, my own re-derivation

| mover | content lines | ADDED | removed | law-named lines |
|---|---|---|---|---|
| default/SimpleUVM | 152 | **0** | 152 | 64 |
| default/Scoreboard | 152 | **0** | 152 | 64 |
| default/SeqDriver | 152 | **0** | 152 | 64 |
| default/BuildUVMPkg | 59 | **0** | 59 | 24 |
| testflags/SimpleUVM | 152 | **0** | 152 | 64 |
| testflags/SeqDriver | 152 | **0** | 152 | 64 |
| testflags/BuildUVMPkg | 59 | **0** | 59 | 24 |

**Every mover is a PURE DELETION (`+0`).** I listed the complete set of
distinct changed line shapes after filtering the three routine names
(`create::create`, `do_compare::do_compare`, `reserve_region::reserve_region`)
and what remains is EXHAUSTIVELY the child/edge lines of the removed
return-variable triples plus the `class_defn` / `int_typespec` / `bit_typespec`
they pointed at — `|vpiActual: |vpiParent: |vpiTypespec: |vpiName:{create,
do_compare,reserve_region} |vpiInstance: |vpiClassDefn: |vpiSigned:1
\_class_typespec: \_ref_typespec: \_int_typespec: \_bit_typespec: \_class_defn:`.
**Nothing unattributed on any mover. `vpiTypedefAlias` changed lines = 0** on all
seven, so the documented build-dependent UVM alias population did not fire —
measured, not assumed.

### 1.2 a control the implementer asserted but did not measure — I measured it

The README claims the return-variable object is "still MINTED so serializer ids
do not shift". Direct proof:

```
uhdm-dump --stats  (SimpleUVM/default, pristine vs patched)
  control: 183090 objects over 94 kinds
  final  : 183090 objects over 94 kinds
  diff of the by-kind tables: EMPTY
```

Not one object was un-minted or renumbered; only reachability changed. That, plus
`+0` added lines on every mover, closes the id-shift question properly.

### 1.3 CANARIES, all rc 0

| script | corpus | result |
|---|---|---|
| `ctcan2.sh` `EXPECT_UNKNOWN=6` | u2r | ok=1 changed=0 absent=0 unknown=6, rc 0 |
| `ctcan2.sh` `EXPECT_UNKNOWN=1` | surelog | ok=58 changed=0 absent=0 unknown=1, rc 0 |
| `r10uvm52repro/canaries.sh` (**the script the brief names**) | u2r | ok=8 changed=0 absent=0 unknown=25, rc 0 |
| `r10uvm52repro/canaries.sh` | surelog | ok=52 changed=0 absent=0 unknown=7, rc 0 |
| `r10uvm55repro/canaries.sh` (**what the report's numbers actually came from**) | u2r | ok=9 changed=0 absent=0 unknown=28, rc 0 |
| `r10uvm55repro/canaries.sh` | surelog | ok=58 changed=0 absent=0 unknown=8, rc 0 |
| `canaudit.sh <canaries.sh> <ctcan2.sh>` | — | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, rc 0; all four fenced names `not dispatched by any driver (OK)` |

**BY NAME.** `InterfaceModPort` and `BlackParrotComplex` are **surelog-corpus
only** (`UNKNOWN-NAME` in the u2r csv, both modes) and read
`OK CMP_EQUAL/differ` in both modes there. Because a `differ` dump column makes
the CSV row blind to bytes, I ALSO compared their databases directly:

```
InterfaceModPort   default / testflags : DATABASE BYTE-IDENTICAL
BlackParrotComplex default / testflags : DATABASE BYTE-IDENTICAL
```

The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched or measured individually; their rows are
byte-identical to the baselines inside the whole-corpus sweep.

---

## 2. THE TARGET — head cleared, on all THREE rows, both sides measured

Old head reproduced on the PRISTINE binary on all three target rows:

```
LHS: <null>
RHS: class_var: (uvm_pkg::uvm_object_registry::create::create), id:181259,
     line:250:19, endln:250:20
     |vpiParent: \_ref_obj: (…::create::create), id:39355, line:259:16, endln:259:22
```

**GONE on all three** with the patched binary. New head, identical on all three:

```
LHS: string_var: (uvm_pkg::uvm_object_registry::create::msg), id:139929,
     line:260:14, endln:260:17
     |vpiParent: \_begin: (uvm_pkg::uvm_object_registry::create), id:139927,
                          line:259:30, endln:266:8
RHS: <null>
```

i.e. direction **ADD** — the implementer's R1, correctly characterised.

### THREE NUMBERS, never conflated — mine

| row | cmp lines | dump content +/- | MULTISET (`msdist.sh`) |
|---|---|---|---|
| SimpleUVM default | 29 → 29 (1 head) | 238656 → **238588** | 46983 → **46958** |
| SimpleUVM testflags | 29 → 29 | 238654 → **238586** | (not measured) |
| Scoreboard default | 29 → 29 | 226798 → **226714** | 45194 → **45169** |
| SeqDriver default | 85 → 85 | 513503 → **518693 (+5190)** | 133269 → **133248 (−21)** |
| BuildUVMPkg default | 58 → 58 | 167366 → **167315** | 34261 → **34235** |

Every figure the report gives is exact, **including the alignment law**:
SeqDriver's `diff -u` grew 5190 while its alignment-free distance FELL 21.

---

## 3. INDEPENDENT REPRODUCTION OF THE ARM TABLE AND THE CENSUS

All eight arms, built on both binaries by me:

| arm | ret cells | local cells | differing CTL | differing FIN | ours-dump +/- CTL→FIN | cmp |
|---|---|---|---|---|---|---|
| a1 | 8 | 3 | 2 | **0** | 82 → 45 | 1 head |
| a2 | 3 | 14 | 0 | **0** | 32 → 32 **byte-identical** | 1 head |
| a3 | 21 | 7 | 1 | **0** | 171 → 150 | **rc 0, 0 heads — CONVERTED** |
| a4 | 6 | 14 | 0 | **0** | 11 → 11 **byte-identical** | 1 head |
| a5 | 22 | 18 | 3 | **0** | 101 → 37 | 1 head |
| a6 | 24 | 14 | 3 | **0** | 162 → 100 | 1 head |
| a7 | 4 | 4 | 0 | **0** | 12 → 12 **byte-identical** | 1 head |
| a8 | 4 | 10 | 1 | **0** | 70 → 56 | 1 head |
| **TOTAL** | **92** | **84** | **10** | **0** | | |

Cell for cell identical to the report, and **all 84 local (positive-control)
cells agree before AND after** — the ordinary-local guarantee holds.

Corpus census, SimpleUVM, my own runs of their instruments:

* `retx.py`: **golden binds 218** return-name refs. The brief's law as written
  is therefore REFUTED — implementing it verbatim would have destroyed 218
  correct bindings. Control `gB oB 218 / gB ox 3 / gx oB 10 / gx ox 275`
  (13 differing) → final `218 / 3 / 2 / 283` (**5 differing**).
* `retlist.py OVERBIND`: **8 rows → 0 rows**, and the 8 are exactly the three
  routines (`*_registry::create` 2, `do_compare` 4, `reserve_region` 2).
* `owntab.py`: golden `vpiMethod=1 inClass` **0 bound / 67**; ours **6 → 0**.
  `vpiMethod=0 inClass` golden 176/189, ours 176 → 174 (the two correct
  `reserve_region` lawB drops). `funcs=` counts identical on both sides
  (57 / 79 / 24), so `vpiMethod` agrees with golden on every function object.
* `SLANG_UHDM_DBG56=1` on SimpleUVM: **exactly** the 8 documented drops and
  `routines=139 lawA-drops=6 lawB-drops=2`.
* `SLANG_UHDM_DBG37=1` on SimpleUVM: 117 lines — **60** read `def=0 top=1` (arm
  does not fire) and 57 read `cd=(nil) def=-1 top=-1` (arm fires). R-4 confirmed.

---

## 4. THE OVER-FIRE HUNT — four arms the implementer never built

`v1_scopes2.sv`, `v2_call.sv`, `v3_hierpath.sv`, `v4_methodkinds.sv` (in this
directory). **62 new return-name cells + 51 new local cells. ZERO over-fires.**

| arm | what it builds that a1–a8 do not | ret cells | differing CTL → FIN | ours dump +/- |
|---|---|---|---|---|
| `v1_scopes2` | class at **$unit** scope; class declared **inside a MODULE**; class **inside an INTERFACE**; plain function inside an interface | 12 | 5 → **3** (the 3 residual are a PRE-EXISTING NOREF, see finding 6) | 192 → 150 |
| `v2_call` | a **CALL** to an in-body method from outside the class, from a sibling method, **`super.f(...)`**, an **inherited** call through a derived handle, and a derived **override whose return name is the same token as the super call** | 7 | 2 → **0** | 74 → 34 |
| `v3_hierpath` | lawB's real predicate — a return-name ref whose parent is a **hier_path the SOURCE built, not pass 55**: struct member lvalue+read, class-handle member lvalue+read, **nested** member, at MODULE and PACKAGE scope | 26 | 4 → **0** | 94 → 16 |
| `v4_methodkinds` | **static / virtual / protected** in-body methods, a **NESTED class**, a **derived override**, a **PARAMETERISED class with two specialisations**, and the return name read inside a **for loop** and a **case** | 24 | 6 → **0** | 223 → 99 |

What they establish that the shipped arm set could not:

1. **The law generalises to every class-declaration scope, correctly.** a3 only
   ever put its class in a PACKAGE. Golden binds **0 of 3** for an in-body method
   of a class declared at **$unit** scope and **0 of 3** for one declared **inside
   a module**; ours over-bound one cell in each and now agrees. No over-fire.
2. **A CALL can never enter the population — structurally, not just empirically.**
   `funcRetRefs` is pushed only at `src/ExprEmit.cpp:6244`,
   `else if (funcRetRefs && &nv.symbol == funcRetSym)`, i.e. only when the
   referenced symbol IS `sub.returnValVar`. `v2`'s ours-dump diff between the two
   binaries is a pure deletion of the `int_var` return triple: **no
   `method_func_call`, no `func_call`, no `super`-path object changed a byte.**
3. **The `protoOf` hole is closed by construction, and nobody said so.**
   `VpiMethod()` is set by `protoOf || ((designScope||classScope) && (!oob||oobCtor))`
   (`src/TaskFuncEmit.cpp:2613`), so an out-of-body method's PROTOTYPE listing
   carries `vpiMethod = 1` and would take lawA — except that
   `src/TaskFuncEmit.cpp:4069` does `if (protoOf) { tfs->push_back(tf); continue; }`
   **before** the `pendingFuncRet.push_back` at 4861, so a prototype never enters
   `retNameRefs56`. The one way the "vpiMethod=1 ⇒ in-body" equivalence could
   have broken does not exist. (Likewise `oobCtor`: `new` has no return
   variable and `drainFuncRet` guards `!sub.returnValVar`.)
4. **lawB's predicate is much wider than its § name suggests, and the width is
   right.** The code is `drop56 = parent && parent->UhdmType() == uhdmhier_path`
   — ANY hier_path-parented return-name ref at ANY scope, not only the pass-55
   `= new(...)` artefact. `v3` puts source-built hier_paths at module and package
   scope: golden binds **0 of all 26** cells there, ours over-bound the 4
   `= new()` sites and now agrees; the member-access refs were already unbound on
   both sides. **Recommendation for the record: rename or re-word
   § retNameNewLhsNoBind56, because its predicate is "hier_path parent", and a
   future reader who trusts the name will mis-model it.**
5. **No re-entry through drainFuncRet's partial drains.** The new
   `retNameRefs56.push_back` sits after `if (pkgOnly && !pf.inst) continue;` and
   after `if (pf.refs.empty() …) continue;`, and the drain ends with
   `pf.refs.clear()`, so a pkg-only drain cannot record an entry twice with
   effect; and a repeated drop is idempotent in any case.

**Corpus reach, priced empirically before quoting any syntactic site count:** the
pass fires on **exactly 8 references in 4 databases out of the 1632 databases
across both corpora** (0 u2r movers / 679, 7 surelog movers / 953). Every other
class-bearing corpus test (ClassExtends, ClassParamAsParam, ClassTypeParam,
SimpleConstraint, …) is byte-unchanged, because their in-body return-name refs
were already unbound by `classMethodNoBind`. The arms, not the corpus, are what
bound the law's width — which is why I built four more of them.

---

## 5. THE DROPPED BINDING AND OTHER CONSUMERS

Executed, not asserted:

* Passes after `retNameNoBind56(d)` in `exportDesign`, enumerated from the source
  and each body extracted and grepped:
  `drainClassNestedTdGroups54` **0**, `importPublishesPackageClasses24` **0**,
  `classInheritsContainerImports23` **0**, `modulePublishesPackageClasses45` **0**
  occurrences of `Actual_group`; `thisImplicitNetBoth38` has 2 and its FIRST
  guard is `if (r->VpiName() != "this" || r->Actual_group()) continue;` — a
  return-name ref is never named `this`. The inline
  § castSizeParamRefBindFinal block reads `Actual_group()` only for an
  `int_typespec`'s `Cast_to_expr` reached through a listing's `Parameters()`,
  never a statement-level ref.
* **No reference became unresolvable in golden's sense**: the dropped refs keep
  `vpiName` / `vpiFullName` and golden's own refs at those sites have no
  `vpiActual` either. The removed `class_var`/`bit_var`/`int_var` were each the
  private per-reference mint of the ref that pointed at them (their `vpiParent`
  IS that ref_obj in the pristine dump), so nothing else lost a target — and the
  `--stats` table proves no object vanished.
* Empirical closure: 1632 databases, 7 movers, all pure deletions of exactly the
  intended subtrees. Zero collateral anywhere.

---

## 6. FINDINGS, most severe first

**F1 — LOW (rigor, not a defect). The "nothing after this point reads
Actual_group" proof stops at the emitter and misses the POST-EXPORT UHDM library
passes.** `uhdm_main.cpp:471–506` runs, after `exportDesign()` returns and before
`serializer.Save()`: `UHDM::ElaboratorContext` + `UHDM::UhdmAdjuster` when
`-elabuhdm`, and `UHDM::SynthSubset` when `-synth`. Those are UHDM-library
consumers that DO read `Actual_group`, and **636 of the surelog testflags rows
carry `-elabuhdm`**. The risk is empirically bounded to zero — none of those 636
moved a byte, and the 3 UVM testflags movers carry no `-elabuhdm` — but the
README's claim as written is only true of OUR passes, not of the process.
Show it:
`sed -n '471,506p' uhdm_main.cpp` and
`grep -l elabuhdm /tmp/v56sweep/wd_sl_fin/testflags/*/cmds.txt | wc -l` → **636**;
`grep -o '\-elabuhdm' /tmp/v56sweep/wd_sl_fin/testflags/SimpleUVM-*/cmds.txt` → empty.

**F2 — LOW (citation). The report's canary numbers come from a different
`canaries.sh` than the brief names, and the write-up does not say which.**
`ok=9/unknown=28` and `ok=58/unknown=8` are `tools/probe/r10uvm55repro/canaries.sh`
(37 names). The brief specifies `tools/probe/r10uvm52repro/canaries.sh`
(33 names), which gives `ok=8/unknown=25` and `ok=52/unknown=7`. Six files under
`tools/probe/*/` share the basename `canaries.sh` with 24/33/33/37/37/37 names.
**Coverage is not weakened** — the 33-name list is a strict subset of the
37-name one (`55-only: 2DFunctionArg ClogCast PartSelect4 TypespecExpr`) — and I
ran BOTH: `changed=0 absent=0`, rc 0, on both corpora with both scripts. Show it:
the name-set diff in §1.3 above.

**F3 — INFO (disclosed, but the wording invites over-reading).** "`retlist.py`
reports OVERBIND 0 rows on all four tests after the fix" is true of that
instrument, while its sibling `retx.py` on the same census still reports **2
`gx oB` cells** on SimpleUVM after the fix: `uvm_mem::get_access` @1165:63 and
@1176:63. They are the same macro-buffer coordinate residue the report ranks as
**R3**, and `retlist` classes them `NOREF` rather than `OVERBIND` because the
position differs — so the two instruments disagree by construction, not by
regression. Show it: `python3 retx.py g.cen o.cen -v` (final) prints the two
cells; `python3 retlist.py g.cen o.cen OVERBIND` prints `# 0 rows`.

**F4 — INFO. The two brief-named canaries are quoted from a CSV row that cannot
see bytes.** `InterfaceModPort` and `BlackParrotComplex` are surelog-only and
their rows are `CMP_EQUAL/`**`differ`**; a `differ` dump column means the row is
blind inside the database. I closed it directly: both are **DATABASE
BYTE-IDENTICAL** between pristine and patched, in both modes (`cmp -s` on the
two `slang.uhdm`). The claim stands; its evidence was one instrument short.

**F5 — INFO. `SimpleUVM/testflags` — one of the three target rows — is missing
from the report's movement table.** Its numbers are 29 → 29 cmp lines and
**238654 → 238586** dump content, not the default row's 238656 → 238588. Head
cleared there too; no conflict, just an omission. Show it:
`wdump.sh /tmp/v56sweep/wd_sl_{ctl,fin} SimpleUVM testflags …`.

**F6 — INFO (a residue only my v1 arm can see, NOT caused by this pass).** For a
class declared **inside an INTERFACE**, ours emits **no return-name reference at
all** where golden emits three (unbound): `work@i1::i_in` @22:10, 23:14, 24:12
read `NOREF-DIFF` in BOTH the control and the final. Direction ADD, 3 cells,
reference-EXISTENCE not binding — belongs in the ranked residue below the
report's R6 family. Show it: `cells.sh /tmp/v56ctl_v1_scopes2` and
`cells.sh /tmp/v56fin_v1_scopes2`.

---

## 7. WHAT I DID NOT RE-VERIFY

* `owntab.py` for Scoreboard / SeqDriver / BuildUVMPkg (I re-derived SimpleUVM in
  full; the other three are corroborated instead by the mover attribution, which
  names the same three routines with the same line counts on every row).
* `msdist` for SimpleUVM/testflags (not claimed by the report either).
* The residue ranks R2, R4, R5, R6 as *rankings*; I confirmed R2's and R3's cells
  exist in my own census output but did not price the rest.

## 8. FILES THIS VERIFICATION ADDS

`v1_scopes2.sv`, `v2_call.sv`, `v3_hierpath.sv`, `v4_methodkinds.sv` — the four
missing arms, driven with the implementer's own unmodified `arm.sh` / `cells.sh`
/ `cells.py`, and this `README.verifier.md`.
