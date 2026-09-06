# r10v172 — the ADVERSARIAL VERIFICATION of r10uvm172, § `recvNamesSubroutineCollapsesStmtCall172`

**MEASUREMENT-ONLY probes.**  Nothing here is an acceptance judge; the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are the
authorities for every number below.  slang was **NOT** patched, `results/*.csv`
were **READ ONLY**, nothing was promoted, **no corpus row converted**,
`GOLDEN_DEFER` stayed unset, and the four slang-fenced tests were never
dispatched (their names are spelled only in `r10uvm172repro/canaudit.sh`'s own
fence list — this pass removed the one other place that spelled them).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `d53fbaad` |
| pristine binary | md5 `fb82059559765e79eee43ee365aa4879` — built in this verifier's OWN worktree from a clean `d53fbaad`, **byte-identical to the main tree's `build/slang-uhdm`** and to `/tmp/pris_fb82.bin` |
| implementer's patched binary | md5 `01bb3fd9524dbf34f3dc255634a90b86` — reproduced BIT FOR BIT by an independent build of `/tmp/r10uvm172.patch` in a fresh worktree |
| VERIFIED binary (the one fix below) | md5 `f0abe23d44f53867fec9dc2f8298dc58` |
| verdict | **ACCEPT WITH FIX** — one regression found and fixed, two overstatements corrected, five ranked residues |

---

## 1. WHAT WAS REPRODUCED, BIT FOR BIT

Everything the implementer claimed was re-measured from binaries this verifier
built, sweeps this verifier ran, and workdirs this verifier owns.  No control
directory (`/tmp/ctl_wd_*`) was read.

* both binaries rebuilt: **`fb820595…`** (pristine) and **`01bb3fd9…`**
  (patched) — the patched md5 matches the implementer's claim exactly;
* goldens **23 PASS / 0 FAIL** under pristine, patched AND the fixed binary;
  negative control `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**;
* surelog corpus, both modes, 1588 rows: `ct8rows` **0 differing rows** against
  `results/golden_surelog.csv` AND against this verifier's own pristine sweep,
  status AND dump column.  Status histograms identical row for row — **no
  hidden `SLANG_REJECT`-wearing segfault**, no row converted;
* uhdm2rtlil both modes: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**,
  three `ct8rows` **PASS**;
* byteverify: **2 / 956** surelog movers — `MiniAmiq` default and testflags,
  both `948816f7ae30` vs `82e5a3c667ad`; **0 / 1358** uhdm2rtlil; SELFCHECK
  955/956 and 1357/1358;
* the movers ATTRIBUTED by an id-normalised, **order-blind** (sorted) whole-dump
  diff: **48 lines, exactly the four claimed cells** —
  `svaunit_immediate_assertion_details.svh:155,159,163` (`func_call (copy)`) and
  `svaunit_immediate_assertion_info.svh:230` (`func_call (get_checks)`) — and
  nothing else;
* heads (`rowheads.sh`): MiniAmiq **40/1 → 40/1** with the head OBJECT moved
  `func_call (copy)`@155:10 → `bit_select (checks_details)`@233:24, the two
  modes' logs byte-identical (md5 `dcb32643befb…`).  **Every other named row's
  cmp log byte-identical** (md5-compared), Scoreboard/default included;
* canaries `ok=52 changed=0` / `ok=8 changed=0`, both `ctcan2` **PASS**,
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`; SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, and InterfaceModPort / BlackParrotComplex /
  YosysOldOr byte-identical between pristine and patched;
* the six grid arms reproduce the implementer's table exactly, deduped, both
  views: **b_name 10→0, c_home 6→0, d_scope 8→0, e_deep 20→0, a_shape 10→2,
  f_args 18/23→2**, and under the official judge `b_name` (both views),
  `d_scope` (both views) and `c_home` (elab) reach **0 lines / 0 heads**;
* every `cmds.txt` of all four sweeps audited FILE BY FILE by binary PATH
  (1573 + 1573 + 1462 + 1462): every `slang:` line names the frozen binary of
  that arm and no other; the 50 files with no `slang:` line at all are
  golden-cache-only rows;
* the wide boundary re-run pristine-vs-fixed:
  `LISTED=4818 PROCESSED=4818 PRODUCED_DBS=4661 MOVED_ARMS=16 RC_DIFFS=0` — the
  implementer's 11 movers, cell for cell, plus this verifier's own five arms
  (the positive control).  `r10buvm22repro/g22.sv` and
  `r10uvm154repro/l154_noenum.sv` re-attributed here: their ONLY dump
  difference is an address-derived `UINT`/`vpiDecompile` pair
  (`22580985 → 22585081` under THESE binaries, a different pair than the
  implementer saw — which is itself the proof that it is address-derived).
  **Not one arm of r10uvm171, r10uvm169, r10uvm167, r10uvm89, r10uvm77-79,
  r10uvm82-91, r10buvm3-15 or r10sd8-12 moved.**

---

## 2. THE REGRESSION — a NESTED class walked into its OUTER class

`v172_4_home.sv` cell **v4_11**.  Inside `Outer4172::Inner4172::iprobe172`:

```
outfn172.q172.push_back("v4_11");     // `outfn172` names a method of Outer4172
alpha172.q172.push_back("v4_12");     // `alpha172` names a package free function
```

| | line 77 (`outfn172`) | line 78 (`alpha172`) |
|---|---|---|
| golden | `method_func_call (q172)` pfx `ref_obj(outfn172)` | `func_call (alpha172)` link `F:alpha172` |
| pristine | **same as golden** | `method_func_call (q172)` |
| implementer's patched | `func_call (outfn172)` link `F:outfn172` — **WRONG** | same as golden |

A cell that AGREED with golden in the pristine database DISAGREED after the
patch, on legal SystemVerilog, in BOTH views.  **The OFFICIAL judge convicts it
by itself**: run `uhdm-cmp` on this arm's golden and the implementer's patched
database and the HEAD is that very cell —

```
LHS: method_func_call: (q172), line:77:36, endln:77:40
     |vpiParent: begin (pv4172::Outer4172::Inner4172::iprobe172) 76:9-76:26
     |vpiPrefix: ref_obj (…::iprobe172::outfn172) 77:27-77:35
```

— where the pristine head sat at 67:23 on a cell this law legitimately owns.
After the fix the cell agrees and the arm's head moves on to an unrelated
`program`-block difference that pristine also has (§5 V-R3).

**Why.**  `stmtCallCollapseSub172` walked `getParentScope()` from the method's
class upward and slang puts an INNER class inside its OUTER class's scope, so
`Outer4172::outfn172` was found.  Surelog cannot find it: `CompileClass.cpp:693`
builds an inner class as

```cpp
new ClassDefinition(class_name, m_class->getLibrary(),
                    m_class->getContainer(), fC, id, m_class, defn);
```

— the parent scope of a nested `ClassDefinition` is its outer class's
**CONTAINER**, so `getTaskFunc`'s `while (comp) comp = comp->getParentScope()`
walk steps from a nested class straight to the enclosing package/module/file and
**never sees an enclosing class**.  (The existing fence,
`sym->getParentScope() != sc0`, only refuses a name found in a BASE class; it
cannot refuse one found in a legitimately-enclosing scope.)

**The fix** (`src/StmtEmit.cpp`, inside `stmtCallCollapseSub172`, 8 lines plus
comment): skip enclosing `ClassType` scopes when building the chain, and let the
out-of-body switch climb to the nearest NON-class scope rather than exactly one
level:

```cpp
if (sc && curSubOob9)
    while (sc && sc->asSymbol().kind == SymbolKind::ClassType)
        sc = sc->asSymbol().getParentScope();
std::vector<const slang::ast::Scope*> chain;
for (const slang::ast::Scope* c = sc; c; c = c->asSymbol().getParentScope()) {
    if (!chain.empty() && c->asSymbol().kind == SymbolKind::ClassType)
        continue;
    chain.push_back(c);
}
```

**The fix costs nothing.**  Byteverify of the FIXED sweep against the
IMPLEMENTER'S patched sweep: **0 / 956** surelog and **0 / 1358** uhdm2rtlil —
the fix is byte-invisible on both corpora.  Every gate above was re-run on the
fixed binary and is green; the six implementer grid arms score identically; the
wide boundary moves the same 16 arms.

---

## 3. THE ARMS

| arm | what it breaks | result |
|---|---|---|
| `v172_1_import.sv` | WHERE the import is written: package-scope wildcard, `$unit` wildcard, EXPLICIT import, TRANSITIVE (a package that imports another), module-scope wildcard, a class in a module, a module task — plus a NEVER-imported package function as the negative control | **0 diff-lines vs golden, both views** (pristine 20).  The suspected over-reach is REFUTED: golden collapses at every import site, and the never-imported control stays a `method_func_call` on both sides |
| `v172_2_order.sv` | the SEARCH ORDER: a name that is BOTH a `$unit` subroutine and an imported-package subroutine OF THE OTHER KIND | **a real distinguisher, residue V-R1 below** |
| `v172_3_pos.sv` | POSITION: statement vs assigned vs condition vs argument vs member-read vs concatenation vs `void'()` vs for-loop vs `fork` vs `case`; and a receiver spelling that names NO subroutine | **0 diff-lines def, and the arm reaches 0 lines / 0 heads under the OFFICIAL judge in both views** (pristine 12/15) |
| `v172_4_home.sv` | HOMES × MULTIPLICITY: inherited, own method, imported function/task, mixed case, digit-bearing spellings, constructor, static method, extern PROTOTYPE, OUT-OF-BODY body, NESTED class, interface task, program, module function, generate-block function, module instantiated ×3 | **found the regression** (§2); after the fix 3→1 def / 7→5 elab, the remainder being the copy-count and the generate-block link residue V-R2 |
| `v172_5_shape.sv` | CHAIN SHAPE and ARGUMENTS: 2/3/4/5 components, two positional args, one literal arg, NAMED args, a CALL as an arg, arg-dropping on a 3-chain, `this.`/`super.` roots, recursion, base = the enclosing TASK, a void function, and a statement call with NO enclosing subroutine | 30→4; the only remaining cells are the implementer's declared residue **R2** (`initial` / `always_comb` bodies) |
| `v172_6_edge.sv` | THE EDGES: subscript on the SECOND component (R1), on the FIRST, on both; a HIERARCHICAL task call through an instance whose name also names a package function; `$display`; `randomize() with`; an array of class handles | 16→4; the only remaining cells are the implementer's declared residue **R1**, confirmed with golden's `args=1` (the subscript compiled as the collapsed call's one argument) |

`vgrid172.sh` runs one arm through Surelog + both binaries in BOTH views, keeps
the DEF and ELAB listings in SEPARATE files (never merged), records every `rc`,
and additionally runs the **official `uhdm-cmp`** on each (golden, ours) pair.
`ctv172top.cpp` prints the sizes of every vector `design::Compare` reads, in the
order it reads them, so a head that lands on the `design` object can be
attributed to the one vector whose SIZE differs.

---

## 4. TWO OVERSTATEMENTS IN THE IMPLEMENTER'S REPORT

* **"Fence check 0/0/0/0."**  It was **1/1/1/1**: `README.md` §16 spelled all
  four slang-fenced test names in a sentence, and the master's fence check
  (`awk … | grep -v canaudit | grep -c .`) counts the README.  Fixed here by
  rewriting that sentence; the check now reads 0/0/0/0.
* **"uvm151's verifier arms … now MATCH GOLDEN on every moved cell."**  The
  cells that MOVED do match golden, but each arm still holds cells that do not:
  `v151_8_tfname.sv:18,19` and `v151_6_shadow.sv:28` keep a link-less
  `func_call`, and line 19's `tname8` is still the wrong OBJECT KIND
  (golden `task_call` + `vpiTask`).  The implementer's own README §14 declares
  exactly this as residue **R7**; the summary line omits the qualifier.  Both
  arms' heads are unchanged (`heads=1`, same cmp line count) before and after —
  they do NOT reach CMP_EQUAL.

---

## 5. RANKED RESIDUES this verification adds

1. **V-R1 — the SEARCH ORDER is transcribed with two steps swapped.**
   Surelog's `getTaskFunc` order is (1) the component's scope chain, (2) the
   component's own `FileContent`s, (3) `getFuncFromPackage` — the IMPORTED
   packages, (4) every file's file-level task_funcs.  The predicate's order is
   (1) the scope chain — which in slang ALREADY CONTAINS the enclosing
   compilation unit — then (2) imports, then (3) the compilation units.  A
   `$unit` subroutine therefore beats an imported-package subroutine of the same
   name, where golden picks the package.  Measured on `v172_2_order.sv`, DEF
   view: `clash172` is a `$unit` FUNCTION and an imported-package TASK — golden
   `task_call` linked to `pv2172::clash172`, ours `func_call` linked to the
   `$unit` function; `clash2172` is the mirror.  Both sides are wrong in the
   pristine database too (`method_func_call`), so this is **not** a regression.
   ZERO corpus cells (a name must exist in two scopes at once).  Ranked FIRST
   because it is a decode error rather than a modelling gap.  *(The same arm's
   ELAB view agrees with golden — the elaborated scope chain does not reach the
   compilation unit — which is why only DEF shows it.)*
2. **V-R2 — a collapsed call to a MODULE function from inside a GENERATE block
   keeps a NULL `vpiFunction` on some copies.**  `v172_4_home.sv:123`: golden
   links all six copies to `mfn172`; we link two and leave four
   `link=F:<null>`.  `subMap` never holds the resolved symbol for those copies,
   so neither the immediate link nor `drainCollapseLink172` can take it.  The
   SHAPE, NAME and SPAN are golden's — only the link is missing, and pristine
   held a completely different object there, so it is not a regression.  Zero
   corpus cells.
3. **V-R3 — MASKS CASCADE, and this law unmasks big ones.**  In
   `v172_2_order.sv`'s ELAB view golden's `design::Task_funcs` holds 1 entry and
   BOTH our binaries hold 2 (we list a `$unit` task golden drops — measured with
   `ctv172top`).  Pristine's head sat deep inside `AllPackages`, which
   `design::Compare` reads FIRST; once this law makes those statements agree the
   walk reaches `Task_funcs` and the head becomes the whole `design` — the cmp
   log goes 22 lines → 2492.  `v172_4_home.sv` does the same on a smaller scale
   (20 → 388, the new head an unrelated `program`-block object).  Not a new
   defect (RESUME.md §9 "masks cascade"; the cmp line count is the HEAD OBJECT's
   decompile size, not a distance), but a reader comparing raw cmp line counts
   across this law will see them jump, and must not read that as a regression.
4. **V-R4 — `drainCollapseLink172` is inserted between `drainScopedCallBind26`'s
   explanatory comment and its body**, so that comment now reads as if it
   described the new drain.  Cosmetic; noted so a later reader is not misled.
5. The implementer's own R1-R7 all reproduce here, R1 and R2 cell for cell on
   arms `v172_6_edge.sv` and `v172_5_shape.sv`.

---

## 6. FILES

| file | what it is |
|---|---|
| `vgrid172.sh` | the arm runner: Surelog golden + both binaries × both views, every `rc` recorded, the official `uhdm-cmp` run on each pair, DEF and ELAB listings never merged |
| `ctv172top.cpp` | design-level vector sizes in `design::Compare`'s own order — attributes a head that lands on the `design` object |
| `v172_1_import.sv` … `v172_6_edge.sv` | the six adversarial arms (§3) |

The listing instrument is `r10uvm172repro/ct172list.cpp`, built unchanged.
