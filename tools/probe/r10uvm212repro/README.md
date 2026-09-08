# r10uvm212 — § `classTdCloneTakesTheBasesEmptyListing212` — **AN ABSENT SPECIALIZATION LISTING IS A LISTING: A CLASS-SCOPE TYPEDEF CLONE TAKES ITS BASE'S EMPTY ONE** — the Scoreboard/default 95-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED** by
this pass and **nothing was promoted** — **ONE ROW CONVERTS** (Scoreboard/default,
`CMP_NOTEQUAL` -> `CMP_EQUAL`, quoted in full below) and the master promotes it.
No row converts in the other direction. `GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here and are named only inside `canaudit.sh`'s own `FENCED=`
line.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `59767284` |
| pristine binary | md5 `049fa251053375ef129df1158bd07521`, built from this pass's OWN worktree at a clean `59767284` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `97b4a36beefdc33cafe8d0f127ccf7b4`, frozen `chmod 555` |
| production surface | `src/UhdmExporter.cpp` (`copyClassTdSpecParams1`, the law and its Surelog decode) and `include/UhdmExporter.h` (the declaration's note). **+53 / −1 lines, two files, no new exporter state, no new flag, no object re-pointed, no new call site.** |
| probe surface | `tools/probe/r10uvm212repro/` only |

---

## READ THIS FIRST — the numbers

| | pristine | patched |
|---|---|---|
| Scoreboard/default cmp lines / heads | **95 / 1** | **0 / 0** |
| SeqDriver ×2 / MiniAmiq ×2 / SimpleUVM ×2 / BuildUVMPkg ×2 / Earlgrey ×2 / Rggen | 50/1, 112/1, 0/0, 0/0, 0/0, 0/0 | IDENTICAL |
| `grid/c9` (the UVM-free reproducer), def view | **95 / 1** | **0 / 0**, rc 0 |
| `grid/c9`, elaborated view | **117 / 1** | **0 / 0**, rc 0 |
| surelog corpus, default | 474 CMP_EQUAL / 7 CMP_NOTEQUAL | **475 / 6** |
| surelog corpus, testflags | 469 CMP_EQUAL / 6 CMP_NOTEQUAL | 469 / 6 |
| uhdm2rtlil corpus, both modes | 679 / 50 / 2 | 679 / 50 / 2 |
| byte movers, surelog | — | **1 / 956**, the predicted one |
| byte movers, uhdm2rtlil | — | **0 / 1358** |
| boundary gate, 665 committed arms, both views | — | **MOVED_ARMS=1**, this pass's own positive control |

**ONE CORPUS ROW CONVERTS — read it, do not summarise it:**

```
< Scoreboard,default,CMP_NOTEQUAL,decompile:,,
> Scoreboard,default,CMP_EQUAL,,,differ
```

`results/golden_surelog.csv` was **NOT** edited by this pass. The master
promotes that row.

---

## 1. THE HEAD, RE-MEASURED — and the framing that was wrong

The brief called this "a **singular** link golden leaves NULL". It is not.
`ct212fields` (this directory) matches the head object to its counterpart on the
other side by face + ancestor-face path and prints EVERY `GetByVpiType` edge of
both, with `NULLVEC` kept apart from `size 0`. On the pristine database:

```
HEAD LHS(golden) = <null>
HEAD RHS(ours)   = class_typespec(type_id)@483:12-483:34#180280
  >>> vpiType=40 (vpiParamAssign) golden: -              ours: VEC size 1 [0]=param_assign
  >>> vpiType=41 (vpiParameter)   golden: -              ours: VEC size 1 [0]=type_parameter(T)
  >>> vpiType=81 (vpiParent)      golden: class_defn(work@my_scoreboard)   ours: same
  >>> vpiType=652 (vpiClassDefn)  golden: class_defn(uvm_component_registry) ours: same
  >>> vpiType=701 (vpiTypedefAlias) golden: ref_typespec  ours: ref_typespec
```

`class_typespec::Compare`
(`~/git-repos/UHDM/build/generated/src/class_typespec.cpp:206-236`) reaches
`Parameters` at line 228, one line BEFORE `Param_assigns`, so the field the
judge stops on is **`Parameters`**. Golden's is a **NULL VECTOR POINTER**; ours
is a one-element vector. That takes BaseClass.h's **VECTOR** `SafeCompare`
(`~/.local/include/uhdm/BaseClass.h:220-222`), which on `lhs == nullptr` and a
non-empty `rhs` records **`rhs_obj` — the OWNER** — as `m_failedRhs` and never
touches `m_failedLhs`. That is why the head prints `LHS: <null>` with a whole
`class_typespec` on the right: **a vector verdict wearing a singular verdict's
face.** `ct212own.cpp` (the mirror owner-finder, inherited from r10uvm164)
confirms it independently: the only non-`vpiParent` edge in OURS that lands on
the head is `class_defn`'s typespec vector at index 3, and golden's counterpart
vector has the SAME size (124) and the SAME face at that index — so no singular
edge points at this object at all, and the singular reading is impossible.

The head is REPRODUCED BYTE-FOR-BYTE on this pass's own pristine build (md5
`049f…`, byte-identical to the main tree's), not carried forward: 95 cmp lines,
1 head, identical file to the control's.

---

## 2. THE FAMILY, BOTH SIDES — `type_id` keyed by declaring class and by link

`ct212cen.cpp` prints one row per `class_typespec` keyed on
`VpiName × vpiParent × Class_defn × Typedef_alias? × Instance? ×
Parameters × Param_assigns`, with `NUL` (a null vector pointer) printed apart
from `n0`. Over the nine comparable UVM row-modes:

| row-mode | golden `type_id` WITH listing | golden WITHOUT | ours WITH | ours WITHOUT |
|---|---|---|---|---|
| Scoreboard/default | 0 | 56 | **1** | 55 |
| SeqDriver/default, /testflags | 58 | 0 | 58 | 0 |
| MiniAmiq/default, /testflags | 65 | 0 | 65 | 0 |
| SimpleUVM/default, /testflags | 0 | 55 | 0 | 55 |
| BuildUVMPkg/default, /testflags | 0 | 89 | 0 | 89 |

Counting EVERY `class_typespec` (not only the registry family), golden's whole
Scoreboard/default database carries exactly **3** listing-bearing objects
(`uvm_analysis_imp` on `m_imp`, and two `uvm_analysis_port`); ours carries those
same 3 **plus one**. That one extra object IS the head. Eight of the nine
row-modes already match golden object-for-object.

**The listing is ALL-OR-NOTHING per database**, which is the tell: Surelog does
not decide it per class. It decides it once, for the group's BASE, and every
later typedef of the same target is `clone_tree` of that base
(`~/git-repos/Surelog/src/DesignCompile/ElaborationStep.cpp:193-200`).

---

## 3. THE LAW, and the census that proves it — `ct212alias`

`ct212alias.cpp` walks every `class_typespec` that carries a `vpiTypedefAlias`
and prints its own `Parameters/Param_assigns` beside **its base's**.

```
                       GOLDEN mismatches   OURS mismatches
Scoreboard   default          0                  1
SeqDriver    default          0                  0
SeqDriver    testflags        0                  0
MiniAmiq     default          0                  0
MiniAmiq     testflags        0                  0
SimpleUVM    default          0                  0
SimpleUVM    testflags        0                  0
BuildUVMPkg  default          0                  0
BuildUVMPkg  testflags        0                  0
-- measured=9 SKIP-NOFILE=1  GOLDEN total=0  OURS total=1
```

(Scoreboard/testflags is SKIP-NOFILE — slang produces no database for it, so it
is not one of the nine comparable row-modes.)

**GOLDEN NEVER DISAGREES WITH ITS OWN BASE.** Ours disagreed exactly once:

```
MISMATCH CLONE type_id in class_defn:work@my_scoreboard         P/PA=n1/n1
      || BASE  type_id in class_defn:uvm_algorithmic_comparator P/PA=NUL/NUL
```

That is the law: **a clone carries the base's listing, present or ABSENT.**
§ `classTdSpecParamsForeignHome1` (r10sd1) decides whether a typedef's OWN
`#(...)` text earns a listing; § `classTdCloneSpecOverridesOwnArgs112` made the
clone half total for a base that HAS one; this pass supplies the missing
direction — a base with a **NULL** `Parameters` gives its clones a NULL one,
overwriting whatever `emitClassTdSpecParams1` had already put there (that call
deliberately runs BEFORE the group arms).

### The decode

`ElaborationStep::bindTypedefs_` (ElaborationStep.cpp:193-200) is the whole
mechanism:

```cpp
} else if (typespec* tps = def->getTypespec()) {
  ElaboratorContext elaboratorContext(&s, false, true);
  tpclone = (typespec*)UHDM::clone_tree((any*)tps, &elaboratorContext);
  ref_typespec* rt = s.MakeRef_typespec();
  rt->VpiParent(tpclone);  rt->Actual_typespec(tps);
  tpclone->Typedef_alias(rt);
}
```

`clone_tree` copies the base wholesale. There is no arm anywhere in that
function that lets a clone acquire a specialization the base does not have, and
`compileDatastructureTypespec`'s `ClassDefinition` arm
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:902-1000`) — the only
writer of `Parameters`/`Param_assigns` on a `class_typespec` — never runs for a
typedef that took the clone path. The base is simply "walked first", by
`Design::m_classDefinitions` order (§ 54's transcription), which is why the
answer is uniform across a database.

### Where our emitter filled it

`src/UhdmExporter.cpp`, `copyClassTdSpecParams1`, the `overwrite1` (§ 54
no-anchor drain) call at `drainClassNestedTdGroups54`. The old first line
returned early when `!base->Parameters()`, leaving the clone wearing its own
`#(...)`; it now clears `Parameters`/`Param_assigns` back to **NULL VECTORS**
(never empty ones — `BaseClass.h:220` fires on NULL-vs-non-empty, so `NUL` and
`n0` are different answers). The pass-50 package-anchor call site passes the
default `overwrite1 = false` and is untouched.

---

## 4. THE GOLDEN GRID (`grid/`, `grid212.sh`)

18 arms, each a SUBDIRECTORY with its own `design.sv`, run through the canonical
golden-side Surelog — the one `scripts/verify_golden.py` names,
`~/git-repos/Surelog/build/bin/surelog` — with `default` mode's argv
reproduced exactly (`-parse` + `precompiled_guard`'s `-noprecompiledcache` +
`+incdir+.+<uvm src>/` + `-sv` + sources, `-mt 0 -mp 0 -o <workdir>`, cwd = the
arm). Arms carrying a `USE_UVM` marker are compiled against uvm-1.2; the rest
are self-contained. Every cell records BOTH processes' rc; `PROCESSED` is
asserted against `LISTED`; the arm list is read on fd 3 with children
`</dev/null`; scratch is keyed on the RELATIVE path; a run that reaches no arm
exits 4 instead of printing green.

**The `tidb` listing, golden vs pristine ours:**

| cell | shape | golden | ours (pristine) |
|---|---|---|---|
| `c1_cuclass_foreignpkg` | compilation-unit class, target generic in another package | listing | listing |
| `c2_cuclass_foreignpkg_macro` | c1, typedef produced by a MACRO | listing | listing |
| `c3_cuclass_foreignpkg_explicit` | c1 with an explicit single import | listing | listing |
| `c4_cuclass_cutarget` | cu class, cu target (r10sd1's `b13`) | listing | listing |
| `c5_pkgclass_foreignpkg` | package class, foreign target (r10sd1's `b11`) | listing | listing |
| `c6_cuclass_foreignpkg_twotd` | two cu classes, one generic — base + clone | both listed | both listed |
| `c7_cuclass_foreignpkg_and_pkgclass` | a cu class and a package class, one generic | both listed | both listed |
| `c8_cuclass_foreignpkg_extends_foreign` | cu class EXTENDING a foreign class (Scoreboard's `extends uvm_scoreboard`) | listing | listing |
| **`c9_pkgsuppressedbase_and_cuclone`** | a SUPPRESSED base (package class, own-package target) **plus** a cu clone whose own text would earn a listing | **base NUL, clone NUL** | **base NUL, clone `n1`** ← the bug |
| `c10_pkgsuppressedbase_only` | the suppressed base alone | NUL | NUL |

**c1/c2/c3/c8 REFUTE the "work-library" reading** the brief's question 3 asks
about: a compilation-unit class whose class-scope typedef targets a foreign
package generic KEEPS its listing in golden — that diagonal is the cell
r10sd1's b-grid never measured, and it fires. Neither the declaring library nor
the field-utils macros decide anything; only clone-hood does.

**`c9` is a UVM-free reproduction of the corpus head.** Pristine, the official
`uhdm-cmp` on that cell prints **95 cmp lines and 1 head**, the same count as
Scoreboard/default, with the same `LHS: <null>` shape on the clone
`class_typespec`. Patched: **0 lines, 0 heads, rc 0.**

**The eight `g*` arms answer the with-and-without-field-utils half** directly,
against real uvm-1.2 (listing-bearing `class_typespec` counts,
golden / ours-pristine / ours-patched):

| cell | shape | golden | pristine | patched |
|---|---|---|---|---|
| `g1_unit_comp` | `uvm_component_utils` in a compilation-unit class | 0 | **1** | **0** |
| `g2_pkg_comp` | the same class in a package | 9 | 9 | 9 |
| `g3_unit_obj` | `uvm_object_utils` in a compilation-unit class | 0 | **1** | **0** |
| `g4_pkg_obj` | the same in a package | 50 | 50 | 50 |
| `g5_unit_comp_fields` | `uvm_component_utils_begin` + `uvm_field_int` + `_end`, compilation unit | 0 | **1** | **0** |
| `g6_pkg_comp_fields` | the same in a package | 9 | 9 | 9 |
| `g7_unit_and_pkg` | a compilation-unit AND a package registered class together | 10 | 10 | 10 |
| `g8_pkg_param_comp` | `uvm_component_param_utils` in a package | 9 | 9 | 9 |

`g7` is the control that settles the question: it has a compilation-unit
registered class too, and golden gives it a listing — because there the group's
BASE (the package class's typedef, whose target is foreign) HAS one. The
field-utils macros change nothing. **Clone-hood and the base's listing are the
only variables.**

The `g*` arms are CENSUS arms, not cmp arms: a minimal UVM design is not a
converged row, so their `uhdm-cmp` head is an unrelated earlier object under
both binaries. Their cmp line counts drop by exactly the removed listing's
64-line decompile and by nothing else (g1 661830 -> 661766, g3 663724 ->
663660, g5 664910 -> 664846).

---

## 5. THE PREDICTION — made from PRISTINE databases, BEFORE the patched sweep

`pred212.py` screens every `slang.uhdm` in a workdir for the exact condition the
law changes: a class_typespec that is a CLONE, has a non-null `Parameters` of
its own, and whose BASE's `Parameters` is a NULL vector.

```
surelog   corpus: SCANNED=956  PREDICTED-MOVER-OBJECTS=1
  PREDICTED-MOVER Scoreboard  default  x1 MISMATCH CLONE type_id in class_defn:work@my_scoreboard
                                          P/PA=n1/n1 || BASE type_id in class_defn:uvm_algorithmic_comparator P/PA=NUL/NUL
uhdm2rtlil corpus: SCANNED=1358 PREDICTED-MOVER-OBJECTS=0
```

**One object, one database, named before the patched binary existed.** (The
first cut of this screen matched the word `MISMATCH` anywhere in `ct212alias`'s
output and so matched its own HEADER line — `clone/base listing MISMATCHES=0` —
reporting all 956 clean databases as movers. The screen counts only the
`x<count> MISMATCH …` DATA rows. Recorded because a screen that cannot be wrong
is a screen that is not measuring.)

---

## 6. GATES

`GATES.r10uvm212.txt` carries the raw transcript. In one line each:

* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` negative control **0 / 23**.
* uhdm2rtlil **679 / 50 / 2** in both modes; `ct8rows` **0 differing rows** against
  the committed `results/gate_uhdm2rtlil.csv` and against this pass's own
  pristine sweeps in both modes; `byteverify SELFCHECK=1` **0 movers / 1358**.
* surelog `--mode both`: **1 differing row out of 1588** against this pass's own
  pristine sweep, and it is the conversion quoted above. `byteverify SELFCHECK=1`
  **1 mover / 956**, `./default/Scoreboard-59431470/slang.uhdm`, the one object
  `pred212.py` had already named.
* Against the committed `results/golden_surelog.csv` two more rows appear —
  `Earlgrey_0_1` default and testflags, dump column `differ` -> blank. That is a
  **harness artifact, proven three ways**: the STATUS column stays `CMP_EQUAL`
  on both sides; the database is byte-identical patched vs pristine (default
  `8c2ba25c4d7f`, testflags `92bf7b7facdc`, the same prefixes r10uvm209
  recorded) and byteverify calls it a non-mover; and the blank is
  `dump_verdict` timing out — one `uhdm-dump` of that database takes over 300 s
  on this machine while two other passes sweep, against a 180 s budget. This
  pass's OWN PRISTINE sweep already has the blank in default, so it predates the
  patch.
* **THE COIN.** Scoreboard/default is the ~50/50 coin row, so it is attributed
  ONLY order-blind: `uhdm-dump` both databases, normalise the workdir path,
  `sort`, `diff`. 1100449 -> 1100422 lines; **82 diff lines, every one of them
  the removed listing** (`|vpiParameter:`, `|vpiParamAssign:`, the
  `work@my_scoreboard::type_id::T` type_parameter and its ref_typespec, the
  param_assign with its `vpiLhs`/`vpiRhs`, the `my_scoreboard` actual, and
  indentation-only re-prints of the SHARED
  `uvm_pkg::uvm_component_registry::T` subtree now reached one level shallower).
  **Zero `svunit_pkg` task/func lines** — the coin did not flip between the two
  runs, and the sorted diff would have been blind to it if it had.
  `COIN.orderblind.r10uvm212.txt` is the whole diff.
* canaries: uhdm2rtlil `ok=8 changed=0`; surelog `ok=49 changed=3`, the three
  being the conversion plus the two Earlgrey dump-column blanks above. `ctcan2`
  PASS on both corpora. `canaudit.sh canaries.sh ctcan2.sh`: **audited=29
  UNCOVERED=0 FENCE-BREACH=0 PASS**.
* 20 protected databases (InterfaceModPort, BlackParrotComplex, YosysOldOr,
  SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, YosysBigSimReed,
  YosysOldOpen, ApbSlave, ClassExtends, Earlgrey_0_1, both modes each):
  **compared=20 NOFILE=0 MOVED=0**.
* the SIX CMP_EQUAL row-modes (BuildUVMPkg ×2, Earlgrey_0_1 ×2, SimpleUVM ×2),
  **both columns scored explicitly**: identical, pristine to patched.
* **BOUNDARY**, `bound212.sh` over 665 arms from r10uvm163 + r10v163, 202, 205,
  207, 208, 82-91, buvm3-15, sd8-12 and sd1, in BOTH views:
  `LISTED=665 PROCESSED=665 PRODUCED_DBS=650 MOVED_ARMS=1 RC_DIFFS=0`. The one
  mover is this pass's own `grid/c9` positive control — so the gate can see —
  and it moves TOWARD golden in both views (def 95 -> 0, elab 117 -> 0). Every
  committed arm of every named pass is byte-identical.
* **MOVED-WRONG 0 / AWAY 0.** `ct212alias` over the nine UVM row-modes: golden 0
  mismatches before and after, ours 1 before and 0 after. `pred212.py` over both
  whole corpora after the patch: 0 of 956 and 0 of 1358. The 18-arm grid: four
  cells move 1 -> 0 where golden is 0 (c9, g1, g3, g5), fourteen do not move and
  match golden exactly, and **no cell loses a listing golden has**.

## 7. RESIDUES

* **R1** — the pass-50 package-anchor call of `copyClassTdSpecParams1` still
  passes `overwrite1 = false` and is therefore still governed by pass 50's
  UNMEASURED-CELL note (no grid cell and no corpus row reaches a
  package-anchored group whose base is a FOREIGN generic). Deliberately not
  touched: nothing measures it, and widening it would be a guess.
* **R2** — clearing the vectors leaves the already-minted `type_parameter` and
  `param_assign` objects unreferenced in the serializer's factory. They land in
  the weakly-referenced tail, which is unreachable to the judge (RESUME §9).
  Not minting them at all would require moving `emitClassTdSpecParams1` after
  the design-final drain; deferred under the no-premature-restructuring rule.
* **R3** — `grid/c9`'s and `c10`'s BASE object differs from golden in
  `vpiInstance` and `vpiParent` independently of this law (golden parents the
  base at the LAST class / at the module_inst and gives it an `Instance`, we
  parent it at its own `class_defn`). The cell still reaches CMP_EQUAL after the
  patch, so the difference is not judge-visible there, but it is recorded rather
  than dressed up.
