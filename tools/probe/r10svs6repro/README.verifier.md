# r10svs6 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PARTIAL.**

Every number the implementer reported is **reproduced exactly** — all five gates,
the grid, the head, the per-shape multiset attribution, the canaries. The build
is bit-reproducible: my independent build of the patch on a fresh 80892a3
produced md5 `32d3d947ba25f42e18069d741b35aebe`, byte-for-byte the implementer's
claimed binary, and my pristine produced `7067d4c913176c204f89fc7106cea65d`,
theirs too. The head IS cleared, both modes, and nothing regressed.

It is PARTIAL, not PASS, because the empty-product-cell hunt the brief mandates
found **one shape the gate was specifically written to exclude and does not** —
`typedef byte b4_t[4]; b4_t x[2];` — where the pass now emits a NEW object with
**seven wrong fields**, two of which (`vpiSize`, `vpiSigned`) are fields
`variables::Compare` reads. It is LATENT (no corpus test contains the shape;
byte verifier proves 2 movers total), so no gate catches it and nothing is
broken today. But it is the exact over-fire the implementer's clause (2) exists
to prevent, reached through a door the clause leaves open, and it entered
through the ONE helper the pass chose to share with the module arm.

Findings F1 (the over-fire) and F2 (a second, smaller one) are the substance.
F3–F5 are accuracy corrections to the record. Everything else confirms.

---

## 0. WHAT I BUILT AND HOW

Fresh worktrees at BASE 80892a3, both bases printed and grep-checked:

```
worktree .claude/worktrees/r10svs6v       git rev-parse HEAD = 80892a311f7a82cf60c722571604bd7f93112b69
                                          git apply /tmp/r10svs6.patch  (--check clean first)
                                          dirty: include/UhdmExporter.h, src/TypeEmit.cpp, src/UhdmExporter.cpp  (+ untracked repro dir)
worktree .claude/worktrees/r10svs6vpris   git rev-parse HEAD = 80892a311f7a82cf60c722571604bd7f93112b69
                                          git status --porcelain = EMPTY
```

```
md5(r10svs6v/build/slang-uhdm)      = 32d3d947ba25f42e18069d741b35aebe   == implementer's claim
md5(r10svs6vpris/build/slang-uhdm)  = 7067d4c913176c204f89fc7106cea65d   == implementer's claim
find src include -newer build/slang-uhdm  ->  0 files, BOTH worktrees
both builds: "[100%] Linking CXX executable slang-uhdm", EXIT=0, no `error:`
md5(/tmp/r10svs6.patch) = 71f985d1f81c684ee7fb7f72c3466c8c   == claim   (2439 lines)
```

The binaries reproducing bit-for-bit is worth stating on its own: it means every
number below is measured against *the same code* the implementer measured, and
any disagreement would have been a measurement error, not a build difference.

---

## 1. NUMBERED FINDINGS

### F1 — NEW OVER-FIRE: a fixed array whose ELEMENT is a whole-array typedef builds a WRONG object (7 fields), and the gate's clause (2) does not see it

**Severity: the substantive finding. Latent (absent from both corpora), so no
gate fires — which is exactly why only a product-cell hunt could find it.**

The gate's clause (2) is `cp.getType().kind != SymbolKind::TypeAlias`, and the
README defends it at length: `typedef byte barr_t[4]; barr_t x;` is "a DIFFERENT
and much smaller golden object", so it is declined and left as residue R1, a
"MEASURED over-fire avoided". That is true and it works (cell `c25_wholetd`).

But the clause tests only the property's **own** type. Write the same typedef as
the **element** of a further array and the property's own type is a
`FixedSizeUnpackedArrayType` (the outer `[2]`), so the clause does not decline —
while the gate's canonical descent

```cpp
const Type* in6 = &ct;
while (in6->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
    in6 = &in6->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
```

walks straight *through* the typedef's inner `[4]` to `byte`. The typedef is
erased, and with it every reason clause (2) was written.

**MEASURED** (`tools/probe/r10svs6repro/v1_gaps.sv`, cell `v01_tdarr`,
`typedef byte b4_t[4]; b4_t v01_tdarr[2];`):

```
G: size=2  signed=-  elem=array_var  elemtsact=array_typespec(b4_t)  elemtsspan=17:9-17:21   elemtsparent=array_var(...)
O: size=8  signed=1  elem=byte_var   elemtsact=byte_typespec         elemtsspan=33:3-33:7    elemtsparent=byte_var(...)
DIFFER[size+signed+elem+elemtsact+elemtsspan+elemtssigned+elemtsparent]      pristine: UNMEASURED (-NOOBJ-)
```

Golden's element is a **nested `array_var`** carrying the named
`array_typespec (b4_t)` — the typedef survives as the element, which is a
different shape entirely (the R2 hybrid family, not this law). We emit a flat
`byte_var`.

**The two gating fields, and the mechanism for each:**

* `vpiSize` 8 vs 2. `fixedUnpackedCount6` (src/TypeEmit.cpp) iterates the
  **canonical** dims but reads param-sizedness from `dimSyns`, the **written**
  declarator dims. There is one written dim and two canonical ones, so on
  iteration 1 the guard `if (di0 < dimSyns.size() && …)` simply fails, `paramSized`
  stays false, and the typedef's inner width 4 is multiplied in: `2*4 = 8`.
  Meanwhile `buildUnpackedRanges` emits **one** range. The object is internally
  inconsistent — `vpiSize:8` with a single `[2]` range.
* `vpiSigned:1` vs golden's absent. `arraySignedWritten8(cp.getType(), *et)` is
  handed the outer array (not a TypeAlias, so clause (a) passes) and `byte` as
  the element. § arrayVarSignedWritten8's typedef rejection is real and correct,
  but it never sees this typedef because the *caller's* canonical descent already
  stripped it. The predicate is not at fault; the new gate's descent is.

**Command:**
```sh
cd .claude/worktrees/r10svs6v/tools/probe/r10svs6repro
SLANG_UHDM=<patched> ./ct6arm.sh v1_gaps.sv /tmp/v6ver/varm_pat/v1_gaps
python3 ct6cells.py /tmp/v6ver/varm_pat/v1_gaps/{g,o}.dump | grep -A2 '^v01_tdarr'
```

**Why this one matters more than the other 15 UNMEASURED→DIFFER cells.** The
implementer's framing — "every one of the 15 is a cell where we now emit the
object and one FIELD of its element typespec still disagrees, a strictly smaller
reading than *we emit nothing*" — is fair for those 15: they are all element-
**typespec** span/parent residues (R3/R5/R6), fields on a child object. `v01_tdarr`
is different in kind: the wrong fields are on the `array_var` **itself**, they are
`vpiSize` and `vpiSigned`, and the README states plainly that
`variables::Compare` reads `VpiSigned`. This is a wrong object, not a
partially-decorated right one.

**And it entered through the one thing the pass chose to share.** §2 of the
implementer's README argues at length — correctly, and with 10 measured module
cells — that the class arm must NOT route through `emitArrayVar` because its
element decode is wrong. But the pass *did* share `fixedUnpackedCount6`, lifted
verbatim out of `emitArrayVar`, and that helper carries this defect. The module
twin proves it is inherited, not invented: `m01_tdarr` reads the same
`DIFFER[size+signed+elem+…]` on the **pristine** binary and on the patched one.
The extraction imported a defect that was never measured because no arm cell
exercised a typedef'd-array element.

**Blast radius: LATENT.** The byte verifier reports 2 movers in 953 surelog
databases and 0 in 679 u2r databases, so no corpus test contains the shape. The
gates cannot see this and correctly do not fire.

**Fix shape (for the next pass, not asked for here):** clause (2) should test the
element chain, not just the property's own type — decline when any dim traversed
by the canonical descent was not written in `dimSyns`, i.e. when
`dimSyns.size()` is smaller than the number of canonical fixed dims. That single
condition also declines `b4_t x[2][3]` and every deeper nesting of the same
family, and it is an AST/syntax-shape test, so the "no clause reads source text"
property is preserved.

---

### F2 — NEW: an UNPACKED-UNION element gets a `logic_typespec` instead of the named `union_typespec`

Second new wrong object, three fields, same hunt (`v1_gaps.sv`, `v05_uunion`,
`typedef union { int a; byte b; } uun_t; uun_t v05_uunion[4];`):

```
G: elem=union_var  elemtsact=union_typespec(uun_t)  elemtsspan=20:9-53:23  elemtsparent=design(work@v1_top)
O: elem=union_var  elemtsact=logic_typespec         elemtsspan=36:3-36:8   elemtsparent=union_var(...)
DIFFER[elemtsact+elemtsspan+elemtsparent]      pristine: UNMEASURED
```

The element **var class is right** (`union_var`) — `classAssocElemVar` handles it
— but the typespec resolves to `logic_typespec`. The b2 arm measured packed and
unpacked STRUCT elements (`c20_pstruct`, `c21_ustruct`, both DIFFER on
span+parent only, typespec kind correct) and never a UNION, so the kind error
was not visible. Smaller than F1 (it is an element-typespec field, R3's family)
but it is a *kind* mismatch, not a span/parent one, so it is a step worse than
the 15 cells it superficially resembles. Latent for the same reason.

---

### F3 — RECORD CORRECTION: "r10svs6 MADE THIS THE FOURTH CALL SITE" of § arrayVarSignedWritten8 is false; there are three before and three after

The README states, at the predicate's comment and in the law summary, that this
pass added "the FOURTH call site of § arrayVarSignedWritten8". Measured on both
binaries:

```sh
grep -rn "arraySignedWritten8(" src/ include/ | grep -v "static bool"
PRISTINE: UhdmExporter.cpp:838   TypeEmit.cpp:14280   TypeEmit.cpp:14599   (+1 definition :1415)
PATCHED : UhdmExporter.cpp:949   TypeEmit.cpp:14348   TypeEmit.cpp:14619   (+1 definition :1568)
```

Three call sites before, three after. The pass did not add one — it **widened the
entry condition of the existing class-array call site** so fixed arrays flow
through it. That is strictly better than what r10oth9's residue R3 predicted
("it needs § arrayVarSignedWritten8 as a fourth call site"), and the honest claim
is the stronger one: the fourth *shape* is served with **zero** new call sites.
As written the sentence would send a later reader grepping for a fourth site that
does not exist. **The underlying reuse claim is CONFIRMED: exactly one definition
of `arraySignedWritten8` (UhdmExporter.cpp:1568, declared in the header), exactly
one of `predefIntTypespec` (ParamEmit.cpp:2101), no forked copy of either
predicate anywhere in `src/` or `include/`.**

---

### F4 — RECORD CORRECTION: the Scoreboard "known flake" did not reproduce at all — the honest mover count is 2, and it always was

The implementer reported **3** surelog movers (SVSwitch ×2 + `Scoreboard/default`),
then spent refutation R-3 proving Scoreboard is a pre-existing nondeterminism and
that "ATTRIBUTABLE MOVERS: 2". My independent run:

```
databases: patched=953 pristine=953        PATH_SETS_IDENTICAL (953 paths)
MOVER ./default/SVSwitch-db796243/slang.uhdm    patched=2af0c522d0d4 pristine=1f2254681d69
MOVER ./testflags/SVSwitch-db796243/slang.uhdm  patched=2af0c522d0d4 pristine=1f2254681d69
MOVERS: 2 / 953
SELFCHECK 952/953 flagged     SELFCHECK1 = 3  (2 movers + 1 corruption)
```

**Scoreboard is not a mover in my run at all.** The refutation is therefore
confirmed by a second, independent draw — and this is a point in the
implementer's favour, recorded as a correction only because the headline "3
movers" is now known to be a coin-flip artefact rather than a stable reading.
u2r: **0 / 679**, SELFCHECK 678, SELFCHECK1 1 — exact.

---

### F5 — RECORD GAP: the witness class carries two further differences the residue list does not mention (both PRE-EXISTING, neither attributable to this pass)

The claim "the whole `class_defn (work@Environment)` region is 194 lines on both
sides differing in exactly ONE line" is **exactly true for the region it
describes** — I confirmed the class header plus its `vpiVariables` listing is
lines 1..194 of the subtree (line 195 is `|vpiMethod:`), golden 194 / ours 194,
one differing line, the spanless `class_typespec: (Receiver)` (R3). Verified.

But the `class_defn` **subtree** is 2186 lines (golden) / 2196 (ours), and the
part below line 194 — the method bodies — holds two more differences that appear
in no residue:

```
line 43  `rcvr[i]= new(output_intf[i],rcvr2sb);`
  G: \_bit_select: (work@Environment::build::rcvr), line:43:11, endln:43:12     <- the index alone
  O: \_bit_select: (work@Environment::build::rcvr), line:43:6,  endln:43:13     <- the whole `rcvr[i]`
line 63  `repeat (4) @ input_intf.clock;`
  G: \_ref_obj:   (work@Environment::reset::input_intf)
  O: \_hier_path: (input_intf.clock)  with two vpiActual ref_objs
```

**Both are byte-identical between the pristine and the patched binary** (I
grepped both dumps), so neither is caused by this pass. They are worth recording
because the first one is a `bit_select` on `rcvr` — one of the two properties
this pass just created — so a later reader will reasonably assume it belongs to
this law, and it does not. Ranked below as R8/R9.

---

## 2. EVERY CLAIMED NUMBER, REPRODUCED

### GATE 1 — BUILD ✅ exact
See §0. Both md5s bit-identical to the claims; `find src include -newer` empty on
both; link line waited for; bases printed and grep-checked.

### GATE 2 — GOLDENS ✅ exact
```
SLANG_UHDM=<patched>  ./tests/check_goldens.sh  ->  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh  ->  PASS=0   FAIL=23     (control fires)
```

### GATE 3 — u2r `testflags --jobs 2` ✅ exact
```
PATCHED : 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL   dump 496 match / 183 differ / 52 blank
PRISTINE: 679 / 50 / 2                                        dump 496 / 183 / 52          (control)
ct6rows.sh vs results/gate_uhdm2rtlil.csv : PASS, every row byte-identical
raw row-side diff vs the committed gate csv: 0     (pristine control: 0)
```

### GATE 4 — surelog `--mode both --jobs 2`, GOLDEN_DEFER UNSET ✅ exact
```
PATCHED  default  : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
         testflags: 463 / 10 / 5 / 286 / 23  + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM
         dump: default 225 match / 242 differ / 327 blank ; testflags 165 / 298 / 331
PRISTINE : identical in every field (control)
ct6rows.sh vs results/golden_surelog.csv : PASS, 0 differing row-sides, BOTH binaries
```

**SVSwitch did NOT convert — I re-ran both rows myself:**
```
PATCHED  : SVSwitch,default,CMP_NOTEQUAL,decompile:,,     SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
PRISTINE : SVSwitch,default,CMP_NOTEQUAL,decompile:,,     SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
COMMITTED results/golden_surelog.csv (unchanged):
           SVSwitch,default,CMP_NOTEQUAL,decompile:,,     SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```
Byte-identical to the baseline. The brief's conversion branch does not apply.
`git status --porcelain results/` is empty in the patched worktree and the patch
touches **0** files under `results/` (`grep -c '^+++ b/results/' = 0`).

### GATE 5 — BYTE VERIFIER ✅ (better than claimed, see F4)
```
u2r     : PATH_SETS_IDENTICAL (679)   MOVERS 0 / 679   SELFCHECK 678   SELFCHECK1 1
surelog : PATH_SETS_IDENTICAL (953)   MOVERS 2 / 953   SELFCHECK 952   SELFCHECK1 3
          -> SVSwitch/default + SVSwitch/testflags only.  Scoreboard absent (F4).
```

**PER-SHAPE, BY MULTISET, vs GOLDEN** — `msdist.sh` md5
`7c0d46b5da124cfe37d27eddc95eb7e7`, and I verified its provenance rather than
trusting the label: `git cat-file -p 7c7eaa6:tools/probe/r10uvm55repro/msdist.sh
| md5sum` is the same hash, so the shipped copy IS the whitespace-fixed one.

```
MULTISET DISTANCE to golden : pristine 1485 -> patched 1402      (-83, TOWARD golden)
  golden-only line instances: 618 -> 517       ours-only: 867 -> 885
ADDED (absent in pristine): 32    REMOVED (absent in patched): 0   [separately, as required]
shapes whose count moved   : 67   CONVERGED=56  DIVERGED=9  LATERAL=2
```
Every figure exact. The 9 DIVERGED are the 2 spanless `class_typespec: (Receiver)`
instances (R3) plus 7 dump-occurrence recounts (`|vpiParent:` ×2, `|vpiTypespec:`,
`|vpiActual:`, `|vpiVariables:`, `|vpiVisibility:1`, `|vpiName:output_intf`) —
exactly as characterised. Adding objects shifts serializer ids and re-prints
shapes under new parents; none of it reaches a cmp verdict.

### THE HEAD ✅ exact, both modes
```
                    PRISTINE            PATCHED
default    cmp HEAD DEPTH  8542   ->    13     heads=1
testflags  cmp HEAD DEPTH  8542   ->    13     heads=1
```
```
BEFORE (pristine, both modes)                    AFTER (patched, both modes)
LHS:                                             LHS:
decompile:                                       decompile:
class_defn: (work@Environment), id:6,            method_func_call: (new), id:2099
  .../SVSwitch/Environemnt.sv, line:12:1,        |vpiParent:
  endln:146:9                                    \_assignment: , id:2096, line:30:1, endln:30:24
|vpiParent:                                      |vpiName:new
\_design: (work@top), id:3780                      … (repeated) …
|vpiName:work@Environment                        RHS: <null>
|vpiVariables:
\_logic_var: (work@Environment::mem_intf), …
```
The new head is `third_party/tests/SVSwitch/Coverage.sv:30` — a different object
in a different file, § invalidNewCallFromSyntax55's family (residue R7), handed
over already decoded. Confirmed.

And the two new objects exist where they should:
```
patched  o.dump: \_array_var: (work@Environment::output_intf), line:17:31, endln:17:42   (+ ::rcvr)
pristine o.dump: grep -c "array_var: (work@Environment::"  ->  0
```

### THE GRID ✅ exact, and the "no regression" claim independently re-proved
```
                CELLS  EQ  DIFFER  UNMEASURED
PATCHED  (mine)  105   63    33        9        == claim
PRISTINE (mine)  105   21    18       66        == claim

transition                class  module   (mine, per-cell join)
UNMEASURED -> EQ           42      0
UNMEASURED -> DIFFER       15      0
UNMEASURED -> UNMEASURED    6      3
EQ -> EQ                    4     17
DIFFER -> DIFFER            0     18
EQ -> anything else:  ZERO CELLS
```

**A stronger no-regression proof than the cell table.** The cell extractor only
reads `*_var` objects named like a cell, so it could not see a property that
pristine emitted as some *other* object and the patch replaced. I diffed the
whole of **our** side of all five arm dumps, pristine vs patched, normalising
serializer ids and workdir paths:

```sh
sed -e 's/, id:[0-9]*//g' -e 's#/tmp/v6ver/arms_[a-z]*/##g' <dump>
b1_witness   REMOVED=0  ADDED=185
b2_elemkind  REMOVED=0  ADDED=1578
b3_arraykind REMOVED=0  ADDED=462
b4_qual      REMOVED=0  ADDED=989
b5_vif       REMOVED=0  ADDED=579
```
**REMOVED=0 in every arm.** The patch is purely additive on our side: not one
line pristine produced was deleted or altered. Combined with 42 UNMEASURED→EQ,
the additions are genuine new correct objects, not replacements.

### THE DECLINING GATE CLAUSES ARE EXECUTED ✅ exact
Unsupported notes on the **shipped** binary, per arm:
```
b1_witness   (none)
b2_elemkind  1  class property type: FixedSizeUnpackedArrayType   <- clause (2), c25_wholetd
b3_arraykind 1  class property type: FixedSizeUnpackedArrayType   <- clause (3), hybrids
             1  class array property element
b4_qual      (none)
b5_vif       (none)
```
Exactly the 1 / 2 / zero-zero-zero distribution claimed. Both declining clauses
demonstrably run.

### CANARIES ✅ exact
```
u2r      canaries.sh  ok=9   changed=0 absent=0   unknown-names=28
         ctcan2.sh    ok=1   changed=0 absent=0   unknown-patterns=6 = EXPECT_UNKNOWN=6   PASS
surelog  canaries.sh  ok=58  changed=0 absent=0   unknown-names=8
         ctcan2.sh    ok=58  changed=0 absent=0   unknown-patterns=1 = EXPECT_UNKNOWN=1   PASS
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
BY NAME, patched vs committed baseline, both modes:
  InterfaceModPort   default/testflags  CMP_EQUAL / differ   IDENTICAL
  BlackParrotComplex default/testflags  CMP_EQUAL / differ   IDENTICAL
```
`UnsignedParam` / `HierPathEval` / `FileLocalParam` / `TopParam` never dispatched
by any driver; canaudit confirms FENCE-BREACH=0.

### PATCH HYGIENE ✅
```
files touched: include/UhdmExporter.h, src/TypeEmit.cpp, src/UhdmExporter.cpp,
               tools/probe/r10svs6repro/ (19 files)          <- production + own repro only
results/ files touched: 0
added production lines matching printf|cerr|cout|TODO|FIXME|XXX|HACK : none
added production lines with trailing whitespace : 0
git apply --check against a fresh pristine 80892a3 : clean
```
The `fixedUnpackedCount6` extraction is a faithful lift — `emitArrayVar` keeps
its early `return nullptr` before the helper is called, so the helper's
`if (!declared) return 1;` is unreachable from that caller and the module path is
unchanged. **Measured, not read: all 38 module twins are 17 EQ→EQ / 18
DIFFER→DIFFER / 3 UNMEASURED→UNMEASURED, no transitions.** The extraction is
behaviour-neutral — while, per F1, also behaviour-*preserving of a defect*.

---

## 3. THE EMPTY-PRODUCT-CELL HUNT

Axes the brief names for an add-a-whole-object law: element kind × qualifiers ×
class kind × dimensions. The implementer's 105 cells cover element kind and
qualifiers densely, dimensions to 2-D, and class kind only as *parameterized*.
I built the rest: **42 new cells in two arms**, `v1_gaps.sv` (22) and
`v2_kind.sv` (20), both added to `tools/probe/r10svs6repro/`.

### v2_kind — the CLASS-KIND and INITIALIZER axes: 19 EQ / 1 UNMEASURED, no new defect

The law holds across every class kind the grid skipped:

| cell | shape | verdict |
| --- | --- | --- |
| `p01_arr`, `p02_init` | class declared in a **PACKAGE** | EQ |
| `n01_arr` / `n02_arr`, `n03_2d` | **NESTED** class (outer / inner, incl. 2-D) | EQ |
| `w01_arr`, `w02_prot` | **VIRTUAL** class, incl. `protected` | EQ |
| `b01_arr`, `b02_loc`, `d01_arr` | **BASE / DERIVED** pair, incl. `local` in the base | EQ |
| `e01_simple`, `e02_repl`, `e03_struct` | the three assignment-pattern kinds — simple, **replicated** `'{4{7}}`, **structured** `'{default:0}` | EQ |
| `e04_statinit`, `e05_constinit` | `static` and `const` **with** initializer | EQ |
| `e06_rand2d` | `rand` on a **2-D** array | EQ |
| `e07_locstat`, `e08_protstat`, `e09_noinit` | `local static`, `protected static`, no-init control | EQ |
| `i01_arr` | class declared in an **INTERFACE** | UNMEASURED |

All 20 were UNMEASURED on pristine. The INITIALIZER HALF is the notable
confirmation: the new code accepts three `ExpressionKind`s and the grid exercised
only `SimpleAssignmentPattern`; the replicated and structured forms are EQ too.

`i01_arr` is a **pre-existing, unrelated gap**: golden emits the `array_var` for a
class declared inside an interface, and we emit no `v2_inif` `class_defn` at all
(`grep -c v2_inif o.dump` = 0 patched *and* pristine). Not this law. Ranked R10.

### v1_gaps — element-kind and dimension gaps: where F1 and F2 live

| cell | shape | pristine → patched |
| --- | --- | --- |
| `v02_3d` | **THREE** dims `[2][3][4]` — `vpiSize:24`, 3 ranges | UNMEASURED → **EQ** |
| `v03_mix` | **MIXED** `[0:3][2]` — range dim + size dim, spans differ per dim | UNMEASURED → **EQ** |
| `v04_prange` | **param RANGE** `[N-1:0]` — golden `vpiSize:4`, the real width | UNMEASURED → **EQ** |
| `v14_parlit` | param SIZE `[N]` control — golden `vpiSize:1` | UNMEASURED → **EQ** |
| `v07_pk` | 2-D **PACKED** element `bit [3:0][7:0]` | UNMEASURED → **EQ** |
| `v11_rt` | `real`, keeps `real_typespec` | UNMEASURED → **EQ** |
| `v15_arr` + `v15_ord_a`/`v15_ord_b` | array **between two scalars** — `vpiVariables` ORDER | UNMEASURED → **EQ** |
| `v01_tdarr` | **typedef'd-array element** | UNMEASURED → **DIFFER[7]** — **F1** |
| `v05_uunion` | **unpacked UNION** element | UNMEASURED → **DIFFER[3]** — **F2** |
| `v09_self` | **SELF-referential** class handle | UNMEASURED → DIFFER[2] (R3 family) |
| `v13_spsigned` | **signed packed struct** element | UNMEASURED → DIFFER[2] (R3/R5) |
| `v12_tpelem` | **type-parameter** element | UNMEASURED → DIFFER[1] (R5/R6) |
| `v08_tddyn` | `typedef int dyn_t[]; dyn_t x[4];` | UNMEASURED → UNMEASURED (clause (3) declines; golden HAS an object — R2 family) |
| `v06_ev` | `event e[4]` | UNMEASURED → UNMEASURED (golden emits nothing either — correctly inert) |

**The dimension axis is a clean confirmation of the law.** `v04_prange` deserves
a note: the "PARAM-sized dim contributes 1" quirk is stated for the `[N]` form,
and I checked the other spelling — a param **range** `[N-1:0]` gives the real
count 4, and **golden agrees**. The quirk is correctly scoped to the form it was
measured on, and the shared helper gets both right.

**Ordering is preserved.** `vpiVariables` used to lose the property entirely at
the `continue`; `v15_ord_a` / `v15_arr` / `v15_ord_b` confirm the new object is
listed in source position between its scalar neighbours, all three EQ.

---

## 4. WHAT I CHECKED THAT THE IMPLEMENTER CLAIMED, AND CONFIRM

* **§ arrayVarSignedWritten8 REUSED, NOT FORKED** — one definition, no second
  copy (F3 corrects only the call-site *count* claim, not the reuse claim). Its
  existing arms still pass: the module fixed-size site's cells (`m01`..`m24`) and
  the class scalar site are 17 EQ→EQ / 18 DIFFER→DIFFER, zero transitions.
* **§ arrayElemTsSignedParented9 REUSED, NOT FORKED** — one `predefIntTypespec`
  definition (ParamEmit.cpp:2101). Its law **does** extend to fixed arrays:
  `c01_int`..`c08_time` all EQ with the element typespec carrying resolved
  `vpiSigned` and `vpiParent` → its own element var. Its deliberately-unshipped
  half is still unshipped and still visible (`c13_bitsv`/`c14_logsv`, R4).
* **§ 8 fires AS WRITTEN at this scope** — `vpiSigned:1` on int/byte/shortint/
  longint/integer/`bit signed[7:0]`/`logic signed[7:0]`; absent on unsigned
  atoms, time, bare bit/logic/reg, unsigned vectors, real, shortreal, string,
  enum **and the signed-enum typedef**, structs, handle, chandle, typedef'd
  element. Reproduced cell for cell. (F1 is not a counterexample to the
  predicate — it is the caller stripping the typedef before the predicate runs.)
* **The `vpiRandType:1` decode** — `1` = vpiNotRand default, `rand`→2, `randc`→3
  with `vpiIsRandomized`. `c01_rand`/`c02_randc` EQ; my `e06_rand2d` EQ too.
  The brief's puzzle is genuinely decoded, not transcribed.
* **The `emitArrayVar` refutation** — the module element-decode table is real
  (`m03`/`m04`/`m05`/`m06`/`m15`/`m16`/`m17`/`m21`/`m22`/`m24` all pre-existing
  DIFFER on both binaries). Not routing through it was right. F1 is the cost of
  the one thing that *was* shared.
* **The census over-prediction (R-2)** — corroborated by the decisive instrument
  rather than re-grepping: 2 movers in 953 surelog databases means no UVM test
  moved. The lesson as stated ("the honest instrument is the emitter's own
  unsupported note, not a source grep") is sound and is the reason F1/F2 were
  findable at all — the arm logs are what show which clauses actually ran.
* **`vpiConstantVariable` on the shared arm** — `c15_constq` / `c16_constdyn`
  EQ→EQ; my `e05_constinit` EQ. The stamp does not disturb the dyn/queue arm.

---

## 5. RANKED RESIDUES (mine, merged with the implementer's)

| # | residue | cells | status |
| --- | --- | --- | --- |
| **V1** | **typedef'd-array ELEMENT builds a wrong object** — `vpiSize`, `vpiSigned`, element class and typespec all wrong; gate clause (2) blind to it; latent (absent from both corpora) | 1 (+ its pre-existing module twin) | **NEW, F1 — fix before the family is touched again** |
| **V2** | **unpacked-UNION element typespec is `logic_typespec`**, not `union_typespec(uun_t)` | 1 | **NEW, F2** |
| R1 | whole-array typedef property emits nothing (deliberately gated out; module twin builds the wrong object today) | 1 | implementer's, confirmed |
| R2 | fixed/unsized hybrids emit nothing; golden has an object | 5 (+ `v08_tddyn` = 6) | implementer's, confirmed + 1 |
| R3 | class-handle / struct element `class_typespec` has no span, no parent — **the one line left in the witness region** | 7 (+ `v09_self`, `v13_spsigned` = 9) | implementer's, confirmed + 2 |
| R4 | signed `bit`/`logic` element typespec lacks `vpiSigned` (r10oth9 R1) | 2 | implementer's, confirmed |
| R5 | shared-typedef element typespec is the last-lister's, span is golden's merged one | 4 (+ `v12_tpelem` = 5) | implementer's, confirmed + 1 |
| R6 | typedef'd element gets a fresh typespec, not the typedef's named one | 1 | implementer's, confirmed |
| R7 | the NEXT SVSwitch head — `Coverage.sv:30`, § invalidNewCallFromSyntax55's family | 1 test | implementer's, confirmed and quoted above |
| **R8** | `bit_select` on `rcvr` spans the whole `rcvr[i]`; golden spans the index alone (`43:11-43:12`) | 1 | **PRE-EXISTING, unreported (F5)** |
| **R9** | `input_intf.clock` is a `hier_path` for us, a plain `ref_obj` in golden | 1 | **PRE-EXISTING, unreported (F5)** |
| **R10** | a class declared inside an **interface** is not emitted at all | 1 | **PRE-EXISTING, unrelated to this law** |

---

## 6. VERDICT

**PARTIAL — land it, with V1 recorded as the top residue of the family.**

The pass does what it claims. The head is cleared on both modes by an
independently reproduced measurement; the change is purely additive (REMOVED=0
across every arm); 42 previously-absent objects are now byte-correct against
golden; the multiset distance moves 83 toward golden with 32 shapes added, none
removed, and every added shape CONVERGED; all five gates are green on my own
binaries with pristine controls beside each one; every canary and both named
tests are unchanged. The engineering judgement in it is good — declining to route
through `emitArrayVar` was correct and measured, the `vpiRandType` puzzle is
genuinely decoded, and the census over-prediction is self-reported rather than
buried.

It is not a PASS because the gate has a hole of exactly the kind the gate was
written to close, and the pass's own documentation is what makes the hole
legible: clause (2) is defended as preventing an over-fire on a whole-array
typedef, and a whole-array typedef one level down over-fires anyway, on
`vpiSize` and `vpiSigned` — two fields the same document names as cmp-gating.
It is latent, so nothing is broken and no gate could have caught it; the product
hunt is the only instrument that reaches it, which is precisely why the brief
mandates one. F3–F5 are accuracy corrections that cost the record nothing to fix.

**Deliverables:** `/tmp/r10svs6.patch`, md5 `71f985d1f81c684ee7fb7f72c3466c8c`,
re-verified `git apply --check` clean against a fresh 80892a3, production +
`tools/probe/r10svs6repro` only, `results/` untouched.
My two new arms (`v1_gaps.sv`, `v2_kind.sv`) sit beside the implementer's five in
`tools/probe/r10svs6repro/` and reproduce F1, F2 and the 42-cell hunt with the
existing `ct6arm.sh` / `ct6cells.py` — no new instrument was needed, which is
itself a good sign about the instruments.

Worktrees: `.claude/worktrees/r10svs6v` (patched), `r10svs6vpris` (pristine).
All my sweep workdirs under `/tmp/v6ver` are deleted.
