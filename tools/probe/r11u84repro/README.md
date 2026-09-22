# r11u84 — THE IMPORT CLONES IN THE PACKAGE'S OWN LISTING

Base `c2ff6b71`. Pristine binary `0765c72612466247727527e9f48c7512` — built in
this pass's own worktree, `-j 2`, md5 taken separately, and byte-identical to
the main tree at `c2ff6b71` and to the OPS pin, compared not assumed. Patched
binary `217c082c9f5997646c3639e2d212eb40`. Both frozen `chmod 555` before any
sweep; every `cmds.txt` audited by binary PATH.

Pass 79 landed the package's own listing and left two residues on it — the
wildcard clone's def-view net type (`R0`) and the explicit-import clone that we
never build (`R1`). This pass decodes BOTH out of ONE producer mechanism, finds
a THIRD face of the same mechanism that pass 79 could not have seen, and lands
all three gated.

---

## 1. THE TWO RESIDUES, RE-MEASURED AT THE BASE (question 1)

`z7_pkgimpclone` (r11u79) and `q5_impreach` (r11v79) re-run against a freshly
regenerated Surelog v1.87 golden, scored on the PACKAGE SECTION of both views
through `pkgscore79.py` (kind + the judge-read fields; no span, no fullname):

```
  arm  cell                              GOLDEN                    OURS @c2ff6b71
  q5   pb5::a_wtd   uhdmallPackages      logic_net nett=36         logic_net nett=1   <- R0
  q5   pc5::a_wtd   uhdmallPackages      logic_net nett=36         logic_net nett=1   <- R0
  q5   pd5::a_net   BOTH views           logic_net nett=1          <none>             <- R1
  q5   pd5::a_uarr  BOTH views           array_var size 1 / 2      <none>             <- R1
  q5   pd5::a_var   BOTH views           logic_var auto=1          <none>             <- R1
  z7   pe::a_net    BOTH views           logic_net nett=1          <none>             <- R1
  z7   pe::a_var    BOTH views           logic_var auto=1          <none>             <- R1
```

`q5_impreach` MISMATCH 5 (def) + 3 (elab); `z7_pkgimpclone` MISMATCH 2 + 2.
R0 is 2 cells, R1 is 10.

---

## 2. THE DECODE (question 2) — ONE MECHANISM, THREE FACES

`CompileHelper::importPackage` (Surelog `src/DesignCompile/CompileHelper.cpp:
127-190`) is called once per IMPORT ITEM from `CompilePackage::collectObjects_`
(`src/DesignCompile/CompilePackage.cpp:141-167`), and for each item it pushes
the home package's entries into the IMPORTING scope's own containers:

```cpp
    // Variables
    auto& variableSet = def->getVariables();
    for (auto& var : variableSet) {
      if (!object_name.empty()) { if (var.first != object_name) continue; }   // :174-176
      scope->addVariable(var.second);
    }
    // Nets
    auto& netSet = def->getSignals();
    for (auto& net : netSet) {
      if (!object_name.empty()) { if (net->getName() != object_name) continue; }  // :184-186
      scope->getSignals().push_back(net);                                     // :187
    }
```

Three facts fall out of those eighteen lines.

### 2a. THE CLONE IS A POINTER, NOT A COPY (LAW A, and it answers R0)

`push_back(net)` pushes the home `Signal` ITSELF, and `design->getPackage(
pack_name)` (`:167`, `src/Design/Design.cpp:435`) answers the **ELAB** Package
for every caller — the unelab twin is minted inside the ctor
(`src/Package/Package.cpp:42`, `m_unElabPackage = new Package("", ...)`) and
never registered in `m_packageDefinitions`. `FunctorCompilePackage::operator()`
(`src/DesignCompile/CompilePackage.cpp:60-70`) compiles both views, so BOTH
views of the importing package alias THE SAME ELAB home Signal.

That Signal is the one `ElaborationStep::bindPortType_` mutated in place
(`src/DesignCompile/ElaborationStep.cpp:1489-1500`): when the declaration's
type name resolves to a `SIMPLE_TYPEDEF` whose own written type is
`logic`/`reg`/`wire`, `signal->setType(...)` REPLACES it. So a clone answers
`elabSignal`'s kind question and `getVpiNetType`'s net-type question with the
ELABORATED reading **whatever view is being written**. Pass 79's LAW C (the
per-view `vpiNetType`) is right for a package's OWN entry and does not apply to
a cloned one.

Note the ordering is not what makes this true — the POINTER SHARING is. The
rewrite reaching the clone does not depend on whether `importPackage` ran
before or after `ElaborationStep`.

### 2b. AN EXPLICIT IMPORT CLONES ITS ONE NAMED ENTRY (LAW B, and it answers R1)

Both data arms are filtered by `object_name`, which `importPackage` reads off
the import item's second name node (`:137-142`) and leaves EMPTY for a
wildcard. So `import p::n` pushes exactly the entry called `n`, into whichever
container it rides, and a name that is not a data declaration pushes nothing.

### 2c. EVERY CLONE PRECEDES EVERY OWN ENTRY (LAW C, and pass 79 could not see it)

`CompilePackage::compile` (`:105-108`) runs

```cpp
  collectObjects_(CollectType::FUNCTION, reduce);
  collectObjects_(CollectType::DEFINITION, reduce);
  m_helper.evalScheduledExprs(m_package, m_compileDesign);
  collectObjects_(CollectType::OTHER, reduce);
```

`paPackage_import_item` is handled ONLY under `FUNCTION` (`:164`) while
`paNet_declaration` and `paData_declaration` are handled ONLY under
`DEFINITION` (`:255`, `:262`). The whole import batch is therefore in the
scope's vectors before the package's own first declaration is looked at,
WHATEVER the source order says.

Pass 79 modelled the clone as riding the one source-ordered walk "at the import
statement's slot". That is indistinguishable from this on every package it
measured — `uvm_pkg`, `adpcm_pkg` and all 38 of its arms open the body with the
import — and wrong the moment a declaration precedes an import.

### 2d. THE SPLIT-ON-ERASE ARTIFACT (decoded, left as R0 — see §7)

`NetlistElaboration::elaboratePackages` (`src/DesignCompile/
NetlistElaboration.cpp:100-134`) collects the rejected signals into a
**`std::set<Signal*>`** and then erases each one with a `break` after the first
match:

```cpp
      std::set<Signal*> notSignals;
      for (Signal* sig : pack->getSignals())
        if (!elabSignal(...)) notSignals.insert(sig);
      for (auto sig : notSignals)
        for (auto itr = pack->getSignals().begin(); itr != ...; itr++)
          if ((*itr) == sig) { pack->getSignals().erase(itr); break; }
```

When the SAME pointer reaches a listing more than once — a diamond, a duplicate
import item, a wildcard and an explicit item over the same home — `elabSignal`
pushes it onto `variables()` once per occurrence but the set dedupes it, so
exactly ONE occurrence is erased and the rest stay in `getSignals()` and are
written as NETS. Measured, `t3_shapes` `s5` and `sa`: two `s_var` variables AND
a `logic_net` named `s_var` carrying `vpiNetType 36`.

---

## 3. THE GOLDEN GRID (question 3)

Six new arms, one real Surelog v1.87 golden each, both package sections scored.
`t1`/`t4`/`t6` are the decisive ones; `t5` is a FENCE arm, recorded not scored.

### 3a. `t1_cloneviews` — THE CLONE'S DEF VIEW **IS** THE HOME'S ELAB VIEW

`h1` declares thirteen spellings; `h2` wildcard-imports it. Every cell of
golden's `h2` listing, in BOTH views, equals the corresponding cell of golden's
`h1` **ELABORATED** view:

| home spelling | h1 DEF | h1 ELAB | h2 clone DEF | h2 clone ELAB |
|---|---|---|---|---|
| `wire a1_t n_w1` (1 hop `logic`) | nt 1 | nt **36** | nt **36** | nt 36 |
| `wire a2_t n_w2` (2 hops) | nt 1 | nt 1 | nt 1 | nt 1 |
| `wire a3_t n_w3` (3 hops) | nt 1 | nt 1 | nt 1 | nt 1 |
| `b1_t v_b1` (1 hop `bit`) | `bit_var` | `bit_var` | `bit_var` | `bit_var` |
| `b2_t v_b2` (2 hops) | `logic_net` | **`bit_var`** | **`bit_var`** | `bit_var` |
| `e1_t v_e1` | `enum_var` | `enum_var` | `enum_var` | `enum_var` |
| `e2_t v_e2` (2 hops) | `logic_net` | **`enum_var`** | **`enum_var`** | `enum_var` |
| `s1_t v_s1` (struct w/ `int`) | `struct_var` | `struct_var` | `struct_var` | `struct_var` |
| `s2_t v_s2` (2 hops) | `logic_net` | **`struct_var`** | **`struct_var`** | `struct_var` |
| `g1_t v_g1` (all-logic struct) | `logic_net` | `logic_net` | `logic_net` | `logic_net` |
| `r1_t v_r1` (`typedef reg`) | nt 0 | nt **48** | nt **48** | nt 48 |
| `w1_t v_w1` (1 hop, no keyword) | nt 0 | nt **36** | nt **36** | nt 36 |
| `w2_t v_w2` (2 hops) | nt 0 | nt 0 | nt 0 | nt 0 |

54 cells, two views. Pre-84 `h2`'s ELAB view was already right on all of them
and its DEF view wrong on the six where the home's two views disagree — LAW A
is exactly that gap and nothing wider.

### 3b. `t4_expviews` — THE EXPLICIT CLONE AND THE WILDCARD CLONE ARE THE SAME OBJECT

`p1` declares thirteen spellings; `p2` imports each one EXPLICITLY, `p3`
wildcard-imports the lot. Golden's `p2` and `p3` listings are **cell for cell
identical in both views** — same kinds, same `vpiNetType`s, same per-view array
sizes (`k_ua` reads `size 1` in the def view and `size 3` in the elaborated one
in BOTH packages). One builder serves both; LAW B needs no kind table and no
net-type table of its own, and gets none.

### 3c. `t2_expkinds` — WHAT AN EXPLICIT ITEM CLONES, KIND BY KIND

Fifteen explicit items over one home, one importing package each:

```
  import e1::x_net     -> logic_net nt 1            import e1::x_int   -> integer_var
  import e1::x_var     -> logic_var auto=1          import e1::x_wand  -> logic_net nt 2
  import e1::x_uarr    -> array_var (1 / 2)         import e1::x_sup   -> logic_net nt 11
  import e1::x_glogic  -> logic_net                 import e1::x_bit   -> bit_var
  import e1::x_wtd     -> logic_net nt 36 BOTH      import e1::x_real  -> real_var
  import e1::x_wv      -> logic_net nt 36 BOTH      import e1::x_str   -> string_var
  import e1::x_rv      -> logic_net nt 48 BOTH
  import e1::XP    (a PARAMETER) -> NOTHING IN THE LISTING
  import e1::xt_t  (a TYPEDEF)   -> NOTHING IN THE LISTING
```

82 cells over both views. The three `nt 36 / nt 48 BOTH` rows are LAW A acting
on an explicit clone — the same pointer, the same elaborated reading.

### 3d. `t6_slots` — THE SLOT, AND IT IS NOT THE SOURCE SLOT

`n1` writes `own_net_a`/`own_var_a`, then `import m1::*`, then more own
declarations, then `import m2::*`, then more. `n2` is its explicit twin.
Golden, both views:

```
  n1 Variables : m_var, m_uarr | own_var_a, own_var_b, own_var_c
  n1 Nets      : m_net, m_wtd, m_net2 | own_net_a, own_net_b, own_net_c
  n2 Variables : m_var, m_uarr | e_var_a, e_var_b, e_var_c
  n2 Nets      : m_net | e_net_a, e_net_b, e_net_c
```

Every clone precedes every own entry although `own_net_a` and `own_var_a` are
written ABOVE the first import. Within the batch the order is the IMPORT ITEM's
(`m1`'s entries then `m2`'s); within one item, the home's own vector order.
`q5_impreach` `pc5` shows the recursive form: `pa5`'s five entries, then `pb5`'s
own `b_own`, then `pc5`'s own `c_own`.

### 3e. `t3_shapes` — THE IMPORT-SHAPE GRID

| shape | golden |
|---|---|
| diamond (`s5`: `import s2::*; import s4::*`, both reach `s1`) | every entry TWICE, plus the split-on-erase phantom net |
| duplicate explicit item (`s6`: `import s1::s_net` twice) | `s_net` TWICE |
| wildcard then explicit (`s7`) | the wildcard's three, then the explicit's copy |
| explicit then wildcard (`s8`) | the explicit's copy, then the wildcard's three |
| explicit + wildcard + own decls (`sa`) | two `s_var` variables + the phantom net |
| a package nobody imports (`sz`) | its own listing only |
| importing a package with NO data declarations (`sx`) | nothing added |

Nothing is deduped anywhere: the producer pushes per ITEM, and the importing
package's listing is a multiset.

### 3f. `t5_expfences` — THE TWO FENCES, RECORDED AS MEASURED FACTS, NOT SCORED

**(a) Surelog v1.87 ERRORS on an explicit import of an entry whose declared
type is a typedef the same item does not carry over.** `importPackage` filters
the DATATYPE map by `object_name` too (`:163-169`), so the cloned signal's type
name has nothing to bind to in the importing scope:

```
  [ERR:CP0317] Undefined type "fs_t"   import f1::f_struct  (typedef struct w/ an int)
  [ERR:CP0317] Undefined type "fe_t"   import f1::f_enum    (typedef enum)
  [ERR:CP0317] Undefined type "fb_t"   import f1::f_bit     (typedef bit)
```

and NOT on `typedef logic`, `typedef reg`, an ALL-LOGIC struct typedef, or any
untypedef'd spelling (`bit [7:0] k`, `real`, `string` all clean) — measured,
eight spellings. **AN ARM WHOSE COMPILE FAILS TEACHES ERROR-RECOVERY, NOT
GOLDEN**, so those spellings are not this law's ground and `t5` is excluded
from the per-cell score. For the record, on the error run golden writes the
clone as a bare `logic_net` (the override never fired because the type never
resolved) while we write the resolved kind; a corpus test of this shape is a
`SURELOG_FAIL` row and is never compared.

**(b) A CHAINED explicit item is unreachable through our front end.**
`import s2::n` where `s2` only WILDCARD-imported `n` is accepted by Surelog
(its `getSignals()` scan finds the clone) and REJECTED by slang: `error: no
member named 's_net' in package 's2'`. No such item can reach the emitter, so
`pkgExplicitImportEntry84` scans the home package's own members and that scan
is complete for everything we can compile.

### 3g. THE CONTROLS — THE BOUNDARY OVER ALL 52 ARMS

Every committed pass-77/78/79 arm (`b*`, `g*`, `v*`, `w8`, `x*`, `y1`-`y6`,
`z3`-`z8`) plus the r11v79 break grid (`q1`-`q8`) re-run on both binaries and
compared as ORDER-SENSITIVE, path- and banner-normalised dumps:

```
  BYTE-IDENTICAL pristine vs patched : 44 of 52 arms
  MOVED                              :  8 — q5_impreach, z7_pkgimpclone and
                                          the six new t* arms, every one of
                                          which carries an import clone
  cmp_rc CONVERT 0   cmp_rc REGRESS 0   (ARMS.pris / ARMS.patch)
```

Per-cell score over the 51 scored arms (`reg84.py`, both views, position AND
face, so a pure slot move is counted rather than washed out):

```
  TO-GOLDEN = 120    AWAY-GOLDEN = 0    STILL-WRONG = 10    CELLS-OK = 970
```

The 10 still-wrong are three named residues, none of them new and none of them
touched: `t3_shapes` 4 (the split-on-erase phantom, §7 R0), `q7_qual` 2
(r11v79's `vpiConstantVariable` on a `const` unpacked-array holder) and
`z5_pkgunpacked` 4 (r11u79's package DYNAMIC container `vpiAutomatic`). Both of
the latter arms are byte-identical between the two binaries.

---

## 4. THE THREE LAWS, GATED (question 4)

All three are in `src/ParamEmit.cpp`; `include/UhdmExporter.h` carries one
member declaration. **`src/ModuleEmit.cpp` is not touched at all** — it is the
sister pass's ground.

**§ caPkgCloneReadsTheElaboratedEntry84** (`R11U84_ELAB_OFF=1`) — an
IMPORT-CLONE entry of another package's listing, wildcard or explicit, direct
or transitive, answers the KIND question and the `vpiNetType` question with the
ELABORATED reading in EITHER view, because the clone is the home's ELAB Signal
pointer and not a copy of it. Fences: the reading only — the object's own
view-dependent shape (an unpacked array's `vpiSize`: 1 in the def view,
flattened in the elaborated one) is the writer's and is untouched; the
package's OWN entries keep § caPkgListingNetTypeIsPerView79 exactly; the
importing MODULE's hoist is not reached.

**§ caPkgExplicitImportClonesItsOneEntry84** (`R11U84_EXP_OFF=1`) — an explicit
import item builds the clone of exactly the one named DATA DECLARATION, through
the same `emitOne9` builder the wildcard clone uses, and builds nothing for a
name that is not one. Fences: a plain member scan of the home package, never
`importedSymbol()` (forcing AST binding during the DEF phase has changed later
emission before); GOLDEN WRITES NOTHING for a parameter, a typedef, a
subroutine or an unresolvable package, and neither do we.

**§ caPkgCloneListingComesFirst84** (`R11U84_ORDER_OFF=1`) — every import clone
precedes every own entry, in both vectors, in import-item source order and then
the home's own order, recursively. Fences: the ordering only; the hoisted
out-of-body constructor locals stay with the own group they belong to and keep
§ hoistedLocalKeepsItsLifetime209's value.

`R11U84_OFF=1` drops all three and **reproduces the pristine database BYTE FOR
BYTE on all 52 arms** (`pris_blind=0 pris_ord=0` on every one). Each switch
drops its own law alone — read as distance from PRISTINE / from PATCHED, order
blind and order sensitive (`SWITCHES.r11u84.txt`):

| switch | arms it returns to PRISTINE | what it leaves |
|---|---|---|
| `ELAB_OFF` | `t1_cloneviews` — its whole difference was LAW A | LAWS B and C still acting (up to 904 lines from pristine) |
| `EXP_OFF` | `t2_expkinds`, `t5_expfences`, `z7_pkgimpclone` — their whole difference was LAW B | LAWS A and C (up to 440 ordered lines from pristine) |
| `ORDER_OFF` | none | `patch_blind=0` on EVERY arm and `patch_ord` nonzero only on `t3_shapes` (296) and `t6_slots` (816) |

That last row is the pass's own methodological finding: **LAW C's whole byte
surface is a SLOT**, so an ORDER-BLIND comparator reads it as a no-op. `sw84.sh`
scores both columns for exactly that reason; scoring only the blind one would
have certified a live law as dead code.

44 of the 52 arms read `0/0/0/0` under every switch, which is the ledger's own
in-place control: a switch that moved one of them would be reaching outside
this ground.

---

## 5. THE CENSUS AND THE PREDICTION (question 5)

`cen84.py` replays the harness's OWN discovery and its OWN slang argv
(`verify_golden.discover_*` / `translate` / `location_args`), runs the frozen
patched binary with `R11U84_CELLDBG=1`, and records every invocation's rc. The
four slang-fenced names are read off `canaudit.sh`'s own `FENCED=` line and
never dispatched.

THREE trace rows, one per law, each computed in the SAME run on the SAME binary
so a corpus mover is named a priori without a second binary:

* `R11U84CELL name=… view=… own=… vkview=… vkelab=… ntview=… ntelab=… SAME|MOVED`
  — LAW A: one row per listing entry carrying BOTH readings.
* `R11U84EXP name=pkg::n view=… into=… MINT|NONE` — LAW B: one row per explicit
  import item, naming the entry it adds or declining.
* `R11U84ORD name=… view=… imports=… decls=… SAME|MOVED` — LAW C: one row per
  package view, MOVED exactly when a listed declaration is written before an
  import that clones anything.

```
  corpus       invocations   pkg views   listing cells   LAW A   LAW B   LAW C
  surelog         1573          820        660 (452 own + 208 CLONE)   0     0     0
  uhdm2rtlil      1742          752          0                         0     0     0
  ----------------------------------------------------------------------------
  PREDICTED MOVER INVOCATIONS = 0   on both corpora
```

**THE ZERO HAS A STRUCTURAL REASON, and it is named rather than assumed.** In
the surelog corpus the two populations are DISJOINT: 52 package views carry an
import and NO own data declaration, 28 carry declarations and NO import, 740
carry neither, and **not one carries both**. LAW C needs both, so it cannot
move. The 208 CLONE cells are real (`MiniAmiq` and `SeqDriver` — `adpcm_pkg`
cloning `uvm_pkg`'s listing, the population pass 79 documented) and **not one
of them has `ntview != ntelab` or `vkview != vkelab`**, so LAW A leaves every
one byte-identical. No package in either corpus carries an explicit import item
at all, so LAW B emits no `MINT` row. The uhdm2rtlil corpus has NO package view
with a listed data declaration whatsoever (`decls=0` on all 752).

**THE POSITIVE CONTROL.** A census zero needs one, and the instrument is shown
to fire on the grid before the corpus zero is believed:

```
  t6_slots : R11U84ORD  n1 MOVED, n2 MOVED   (m1, m2 SAME — no imports)
             R11U84CELL n1::m_wtd MOVED (ntview=1 ntelab=36)
             R11U84EXP  m1::m_net / m_var / m_uarr MINT into n2
  t2_expkinds : 13 MINT rows, and R11U84EXP e1::XP NONE, e1::xt_t NONE
                — the two negatives decline, per view
```

Non-zero rc rows are recorded, not hidden: surelog `rc=3` 578 (SLANG_REJECT),
`rc=4` 14, `rc=2` 32, `rc=1` 4, `rc=-11` 4; uhdm2rtlil `rc=3` 131, `rc=4` 14,
`rc=-11` 3. The three uhdm2rtlil segfaults (`rp32_r5p_degu_soc_top`,
`rp32_r5p_mouse_soc_top`, `rp32_soc_vfriendly`, all testflags) were re-run on
BOTH frozen binaries and return `rc=-11` on both — pre-existing at `c2ff6b71`,
not this pass's.

---

## 6. THE GATES (question 6)

### 6a. Build and binaries

```
  pristine  0765c72612466247727527e9f48c7512   == main tree @c2ff6b71 == OPS pin
  patched   217c082c9f5997646c3639e2d212eb40
```

Both built `-j 2`, md5 taken separately, frozen `chmod 555` before any sweep.
The deliverable patch was re-applied to a SEPARATE fresh `c2ff6b71` worktree
and rebuilt there: it applies with no warnings, leaves no conflict marker, and
produces `217c082c9f5997646c3639e2d212eb40` — the same byte-for-byte binary.
The fence check over the patch reports 0 hits for each of the four
slang-fenced names and 0 `results/` files touched.

### 6b. Goldens

```
  patched   23 PASS / 0 FAIL
  pristine  23 PASS / 0 FAIL
  /bin/false 0 PASS / 23 FAIL          (negative control)
```

### 6c. uhdm2rtlil, both modes

```
  patched   CMP_EQUAL 788  CMP_NOTEQUAL 16  SLANG_REJECT 67   (both modes)
  row join vs results/golden_uhdm2rtlil.csv (BOTH modes, key (name,mode),
      status + dump column):  0 of 1742 differ
  ct8rows  vs results/gate_uhdm2rtlil.csv:  PASS, every row byte-identical
  byteverify (SELFCHECK=1) patched vs this pass's own pristine workdir:
      MOVERS 0 / 1608, selfcheck 1607 / 1608, PATH_SETS_IDENTICAL
  binary audit: 1742 / 1742 cmds.txt name the frozen patched binary, OTHER-TREE 0
```

### 6d. surelog, `--mode both`

```
  patched   default    CMP_EQUAL 474  CMP_NOTEQUAL 9
            testflags  CMP_EQUAL 469  CMP_NOTEQUAL 8        == the committed baseline
  pristine  default    CMP_EQUAL 474  CMP_NOTEQUAL 9
            testflags  CMP_EQUAL 469  CMP_NOTEQUAL 8        (the control sweep)
  row join vs results/golden_surelog.csv:  2 of 1596 differ, both quoted below
  binary audit: 1531 / 1581 cmds.txt name the frozen patched binary, OTHER-TREE 0
```

THE TWO DIFFERING ROWS, QUOTED:

```
  Earlgrey_0_1  default    CMP_EQUAL / differ  ->  CMP_EQUAL / <blank>
  Earlgrey_0_1  testflags  CMP_EQUAL / differ  ->  CMP_EQUAL / <blank>
```

The STATUS is unchanged and the pin is the DATABASE byte-compare, which HOLDS
in both modes (§6e). **THE PRISTINE SWEEP PRODUCES THE SAME TWO ROWS** — its
own row join against the committed baseline differs on exactly these two and
nothing else — so the blank dump column is the documented uhdm-dump timeout
draw under load and is not this pass's. **No row converts and no row regresses;
`results/*.csv` is untouched.**

### 6d'. surelog byteverify, and the five movers attributed

```
  SELFCHECK=1 byteverify.sh <patched wd> <pristine wd>   (same-length workdir
      names `slpa` / `slpr`, so the path the database embeds is the same length)
  databases patched=960 pristine=960, PATH_SETS_IDENTICAL (960 paths)
  MOVERS: 5 / 960, selfcheck 959 / 960
```

All five are the UVM family, and the census named zero corpus movers a priori.
Order-blind, path-normalised dump diff of each:

```
  database                     differing lines            PACKAGE-LISTING lines
  default/MiniAmiq             4  (UINT + vpiDecompile)            0
  default/SimpleUVM            4  (UINT + vpiDecompile)            0
  default/Scoreboard           0  (pure ORDER draw)                0
  testflags/MiniAmiq           4  (UINT + vpiDecompile)            0
  testflags/SeqDriver          4  (UINT + vpiDecompile)            0
```

A package-listing change prints a `|vpiNetType:` line, an object-kind line or a
vector header; **not one of the five contains any of those**. The UINT deltas
are 688 / 669 / 925 / 1121 — not multiples of 4096 and paired with
`vpiDecompile`, so they are the documented line-number class and not the
page-boundary class the 16KB-pad control exists for.

THE POSITIVE CONTROL that convicts the environment rather than the law — each
test re-run THREE times from its own source directory, on EACH frozen binary,
each run into its own fresh output directory:

```
  MiniAmiq   default    PRISTINE x3 : dba5dd0a8bda 93a8ba485719 c7ca09f79e10   distinct=3
                        PATCHED  x3 : 27419f6011b4 b0b3b00e683e 0c39b8d082f9   distinct=3
      ^^ THREE hashes from THREE runs of the PRISTINE binary, nothing patched
  MiniAmiq   testflags  PRISTINE x3 : 372401f061da 27419f6011b4 16eff8f5901a   distinct=3
      ^^ and the pristine binary hits 27419f6011b4, the hash byteverify read on
         the PRISTINE side for the default mode
  SeqDriver  testflags  PRISTINE x3 : 356f18823bb0 05df6c25a21b 1cf3868d3d8b
                        PATCHED  x3 : b1bdd3abdea3 283a01b459e6 05df6c25a21b
      ^^ the PATCHED binary lands on a hash the PRISTINE binary produced
  SimpleUVM  default    PATCHED  x3 : d4f8cd018f2d d4f8cd018f2d 1144e55c8c72
      ^^ runs 1 and 2 ARE the pristine hash byteverify recorded (d4f8cd018f2d)
  Scoreboard default    PRISTINE x3 : 1621aec6c9f3 e70775324004 e70775324004
                        PATCHED  x3 : e70775324004 1621aec6c9f3 1621aec6c9f3
      ^^ BOTH binaries produce BOTH faces; byteverify's draw was
         patched=1621aec6c9f3 pristine=e70775324004, i.e. the two faces swapped
```

Every UVM row stays `CMP_EQUAL` with `cmp rc=0` in both modes (§6f), and the
surelog row join differs on no row but Earlgrey's dump column, which the
pristine sweep reproduces.

### 6e. Canaries and protected databases

```
  canaries  surelog     ok=50 changed=2 absent=0   (the two Earlgrey dump-column rows)
  canaries  uhdm2rtlil  ok=8  changed=0 absent=0
  ctcan2    surelog     PASS (58 rows byte-identical)
  ctcan2    uhdm2rtlil  PASS
  canaudit  audited=29  UNCOVERED=0  FENCE-BREACH=0

  PROTECTED DB BYTE PINS, both modes, ALL MATCH:
    SVSwitch            4842211c4030 / 4842211c4030      (hard byte pin)
    YosysVerx           6ccda350c24a / 6ccda350c24a      (hard byte pin)
    InterfaceModPort    59a365f3ce2c / 59a365f3ce2c
    YosysOldOr          d68e0796d62c / d68e0796d62c
    BlackParrotComplex  e3e354129d5a / 73a10e8217e5
    Earlgrey_0_1        8bdf25272e08 / 59d0ee6d10c3
```

Earlgrey's byte pin holding in BOTH modes is what convicts §6d's two rows as a
dump-side environment draw rather than a database change.

### 6f. The UVM family (MOVER RULE: nonzero = real)

```
  rowheads on the patched workdir
    SeqDriver  SimpleUVM  Scoreboard  MiniAmiq  BuildUVMPkg  Earlgrey_0_1
      all 0 cmplines, 0 heads, cmp rc=0, both modes
    Rggen/default unchanged at 64 / 1
    SKIP-NOFILE on Scoreboard/testflags and Rggen/testflags, as expected
```

All seven conversion rows stay `CMP_EQUAL`. `MiniAmiq` and `SeqDriver` are the
two corpus tests that DO carry import clones (208 cells) and the census named
them SAME a priori.

---

## 7. RESIDUES (ranked)

1. **R0 — THE SPLIT-ON-ERASE PHANTOM NET.** When the same home `Signal`
   POINTER reaches one listing more than once (a diamond, a duplicate import
   item, a wildcard and an explicit item over the same home), `elabSignal`
   pushes it onto `variables()` once per occurrence but
   `NetlistElaboration::elaboratePackages`'s `std::set<Signal*> notSignals`
   (`:114-129`) dedupes it and the erase loop `break`s after the first match —
   so N occurrences give N variables and **N-1 surviving NETS**. Measured,
   `t3_shapes` `s5` and `sa`: golden carries a `logic_net` named `s_var` with
   `vpiNetType 36` beside the two `logic_var`s. 4 cells, both views, fully
   decoded here and NOT built — it is a fourth law with its own shape (a net
   minted for a name that is a variable), and GOLDEN HAS it so building it is
   not an invention but it is also not this batch. The next head behind this
   ground.
2. **The explicit-import DATATYPE fence is Surelog's, and it is not modelled.**
   An explicit import of a `struct`-with-a-non-logic-member, an `enum` or a
   `bit` typedef'd entry makes Surelog ERROR (`CP0317 Undefined type`) because
   the typedef is filtered out by the same `object_name`. On that error run
   golden writes the clone as a bare `logic_net`; we write the resolved kind.
   6 cells on `t5_expfences`, in error-recovery territory only — a corpus test
   of this shape is a `SURELOG_FAIL` row and is never compared. Left measured.
3. **r11v79's residue 3 stands**: `vpiConstantVariable` missing on a `const`
   unpacked-array holder (`q7_qual` `g_arrconst`, 2 cells), inside r11u79's own
   `emitPkgFixedArrayVar79`. Byte-unchanged by this pass.
4. **r11u79's residues stand and were re-measured**: the package DYNAMIC
   container's `vpiAutomatic` (`z5_pkgunpacked`, 4 cells), the missing
   unpacked-array typedef in `Typespecs` (`vb`), the two-hop typedef's net
   typespec (`unsupported_typespec` vs `logic_typespec`). All byte-unchanged.
5. The pass-77 / r11v77 residue set stands.

---

## 8. HOW TO RE-RUN

```
GRID=<dir> bash rr84.sh <binary> <tag>              # run the arms (rc on every line)
python3 ordlist84.py gold.dump ours.dump <SECT>     # ORDERED listing, per package
python3 reg84.py <grid-dir>                         # TO-GOLDEN / AWAY-GOLDEN per cell
GRID=<dir> bash sw84.sh <binary> off R11U84_OFF=1   # blind AND ordered distance
python3 cen84.py <repo> <corpus> <binary> out.tsv   # the corpus census
python3 censcore84.py out.tsv                       # movers BY NAME
python3 join84.py <baseline.csv> <fresh.csv> [...]  # both-mode row join
```

`R11U84_ELAB_OFF` / `R11U84_EXP_OFF` / `R11U84_ORDER_OFF` drop one law each;
`R11U84_OFF` drops all three; `R11U84_CELLDBG=1` emits the three trace rows.
