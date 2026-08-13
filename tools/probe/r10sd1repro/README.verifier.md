# r10sd1 — § classTdSpecParamsForeignHome1 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PARTIAL.** The pass's central claim is TRUE and reproduces bit-for-bit
— the 85-line SeqDriver head is cleared on BOTH target rows, the mover set is
exactly the 3 predicted databases, and all five gates are green. But the **stated
law and the code gate are NOT the same predicate**, and the difference is a
measurable **OVER-FIRE** on a legal SystemVerilog shape the delivered grid does
not contain. This report fixes it, adds the witness cell, and proves the fix is
corpus-neutral.

This file replaces the implementer's placeholder of the same name (which said
"NO VERIFIER HAS RUN"). It is THIS pass's, written by the verifier.

| | |
|---|---|
| BASE | `df0cdae` (fresh worktrees, `rev-parse` grep-checked in each) |
| verifier worktrees | `/tmp/wt_vsd1` (delivered patch), `/tmp/wt_vsd1pris` (pristine), `/tmp/wt_vsd1fix` (patch + verifier fix) |
| delivered patched md5 | `9c01498a4f709a336d5b0c43399da7d3` — **reproduced exactly** |
| pristine md5 | `fc59a2414877316104c88c8c1fe43b77` — **reproduced exactly** |
| verifier-fixed md5 | `720c56f5b7697ee91379ea03ef924327` |
| delivered patch md5 | `13a5871c7009f5f0d94c8b36f00b885d` |
| re-cut patch | `/tmp/r10sd1.verified.patch` |

---

## 1. FINDINGS

### F1 — OVER-FIRE (**CONFIRMED, FIXED IN THE RE-CUT**). The `Package`-only home test misses probe 3's enclosing-CLASS case.

The delivered gate (3), `src/UhdmExporter.cpp` in the delivered patch:

```cpp
if (dp1 && home1 == &dp1->asSymbol() &&
    home1->kind == SymbolKind::Package)
    return false;
```

Surelog's probe 3 is `getClassDefinition(parentScope->getName() + "::" + typeName)`.
It hits whenever the target generic is a **sibling of the referencing class in
that class's immediate parent scope** — and Surelog keys a class nested in an
outer class (`pb::outerb::regb`) exactly the way it keys a package class
(`pb::regb`). The `Package` conjunct therefore drops the enclosing-CLASS half of
probe 3, and we emit a specialization golden does not have.

**Witness — new cell `grid/b28_nestedouter.sv`** (a class `regb` and a class `ub`
both nested in class `outerb` in package `pb`; `ub` typedefs `regb #(ub,"ub")`):

| binary | golden PA | ours PA | verdict | dump content vs golden | cmp head |
|---|---|---|---|---|---|
| pristine `fc59a24…` | 0 | 0 | SAME | 94 | `LHS: class_defn (pb::outerb)` |
| **delivered patch `9c01498…`** | 0 | **1** | **DIFF** | **143** | **`LHS: <null>`** — we emit what golden lacks |
| verifier fix `720c56f…` | 0 | 0 | **SAME** | 94 | `LHS: class_defn (pb::outerb)` |

This is a genuine **SAME → DIFF regression** and the dump gets **49 content lines
worse**. The over-firing object is
`class_typespec tidb @10:15-10:19, cd=class_defn(pb::outerb::regb)`.

**F1 also refutes the implementer's own README.verifier.md §2.1**, which asserted
of exactly this case: *"the code does [look at the OUTER CLASS], because `dp1` is
the outer class symbol, but no grid cell proves it."* The code does **not** — the
`&& home1->kind == SymbolKind::Package` conjunct blocks it. The missing cell was
not a documentation gap; it was hiding a defect.

**Fix** (in `/tmp/r10sd1.verified.patch`): accept a parent scope that is a
**named declaration scope**, Package *or* ClassType. The compilation unit is
neither, so cell `b13` ($unit → $unit, which must keep firing because Surelog
keys those `work@C` and no probe can spell it) is unaffected — verified, b13 is
still `PA=1/PA=1`.

```cpp
if (dp1 && home1 == &dp1->asSymbol() &&
    (home1->kind == SymbolKind::Package ||
     home1->kind == SymbolKind::ClassType))
    return false;
```

**Corpus reach of the defect: ZERO, measured.** See §4 — the fixed binary's
databases are byte-identical to the delivered patch's across both corpora. The
defect was latent, not active. It is fixed anyway: a gate whose stated law and
code disagree is exactly what the campaign's "STATED GATE == CODE GATE" rule
exists to catch, and the next design with a nested-class registry would hit it.

### F2 — Scoreboard is FLAKE-CLASS on BOTH binaries; the implementer never measured it (**NEW, not a defect of the patch**)

The brief demanded determinism on Scoreboard with ≥3 reps. The implementer ran
`detcheck` on **SeqDriver only**. Measured here, 5 reps per binary:

```
SCOREBOARD   pristine sizes: 11122522 x5   distinct hashes 3/5
             patched  sizes: 11122752 x5   distinct hashes 2/5
             pat - pris size delta = +230
SEQDRIVER    pristine 17947327 x3, 1 distinct hash
             patched  17960950 x3, 1 distinct hash   delta = +13623
```

Reading by the standing multi-stability law: **within** each binary Scoreboard is
size-stable and hash-unstable → **FLAKE**, and it flakes on the **pristine**
binary too, so it is pre-existing (the campaign's known `SourceLocation`/macro-buffer
nondeterminism), *not* introduced here. **Across** binaries the size delta is
+230, stable over 5 reps → the Scoreboard mover is **REAL and ADD-direction**.
SeqDriver is fully deterministic on both binaries; the implementer's +13623
reproduces exactly. Recorded because a hash-unstable input in the mover set is a
trap for the next pass, and the delivered README does not mention it.

### F3 — The implementer's "footprint proof" is weaker than claimed; a stronger one holds (**claim UPHELD by a better instrument**)

README §2 and §5.2 rest on `uhdm-cmp <pristine db> <patched db>` reporting "one
head". `uhdm-cmp` **stops at the first divergence**, so "one head" can never
prove "nothing else changed" — it proves only that the *first* difference is the
`type_id` family. The conclusion is nevertheless correct, and this is the proof
that carries it — a full **dump-level** diff, which no short-circuit truncates:

```
uhdm-dump default/SeqDriver pristine vs patched, sed 1d, diff -u
  ADDED 1354 content lines   REMOVED 22 content lines
  object kinds touched: class_typespec, type_parameter, param_assign,
                        ref_typespec, class_defn (header re-prints)
  labels touched:       vpiParent vpiFullName vpiName vpiTypespec vpiActual
                        vpiRhs vpiLhs vpiParameter vpiParamAssign vpiClassDefn
  shapes OUTSIDE that family: NONE (the filtered list is empty)
  package-valued objects added: ZERO
```

Since the patch adds no `package` object anywhere, the new head
(`LHS: <null>` / `RHS: package uvm_pkg`) **cannot** have been created by it —
residue R1 is confirmed **pre-existing**. Note the implementer's per-shape figures
(ADDED 1340 / REMOVED 8) come from `mv1.sh`'s indentation-keyed multiset and do
**not** equal a raw dump diff's 1354/22; both are internally consistent, but the
two instruments are not interchangeable and the README does not say which is which.

### F4 — Attack surface 2.2 (package-parameter argument) is REFUTED as a defect

`namesAParamOf1` walks only the enclosing **class** chain, so an ordered argument
naming a package-level `parameter type` is treated as concrete. Measured with
cell `v2_pkgparamarg.sv` (`parameter type PT = baseb;` in the package, `typedef
regb #(PT,"pt") tidb;` in a class):

```
GOLDEN PA=1    pristine ours PA=0    patched ours PA=1
dump content vs golden: 112 -> 87   (BETTER)
```

Golden **also** fires here, so the class-chain-only walk reaches the same
decision Surelog does. The surface the implementer flagged is a **win**, not a
bug. The remaining difference on that cell is the known vpiParent residue
(`parent=module_inst(work@topb)` vs ours `class_defn(pb::ub)`) — residue R6,
cmp-invisible.

### F5 — Attack surfaces 2.3 and 2.4 are SOUND, and now proved rather than argued

* **2.3 (shared actual / shared Lhs).** Read from the generated UHDM sources:
  `class_typespec::Compare` reads `VpiClassType`, `VpiAutomatic`, `Extends`,
  `Variables`, `Task_funcs`, `Constraints`, `Parameters`, `Param_assigns`,
  `Virtual_interface_vars`, `Named_event*`, `Scopes`, `Class_defn`;
  `type_parameter::Compare` reads `VpiLocalParam`, `Typespec`, `Expr`,
  `VpiImported`; `BaseClass::Compare` reads `VpiType`, `VpiName`, `VpiDefName`.
  **No `Compare` body on this path reads `VpiFullName`, `VpiLineNo`, or object
  identity.** Sharing the base's `Actual_typespec` across clones is therefore
  cmp-equivalent to golden's `clone_tree`, as claimed.
* **2.4 (`VpiFullName` caching).** Not writing `VpiFullName` is safe *and*
  measured: the 128 `vpiFullName` lines in the ADD set are computed by the
  reader, and they read `adpcm_pkg::adpcm_seq_item::adpcm_pkg::type_id::T`
  where golden reads `work@top_tb.adpcm_pkg::type_id.T` — exactly residue R6,
  disclosed, and cmp-invisible by the paragraph above. No wrong string is
  cached into the database.

### F6 — The brief's r10uvm52-era law IS refuted; transcription verified

`templates/BaseClass.h:216-220`, read directly:

```cpp
} else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
    context->m_failedLhs = lhs_obj;   // the CONTAINER
    return 1;                          // m_failedRhs left UNSET -> "RHS: <null>"
}
```

Confirmed verbatim. A NULL **vector** on an object both sides emit prints
byte-identically to a missing singular object, so "head-is-an-object means every
recursive vector before it passed" is **false**. The implementer's refutation
stands, and the parent-vector census it demanded (125 == 125) was the right move.

### F7 — EMPTY PRODUCT HUNT: clean (0 found)

Every agreement-shaped cell was re-measured with an added non-vacuity column
(`/tmp/vsd1_grid.sh`): for each cell, how many `class_typespec` **full prints**
named `tidb`/`regb` exist at all on each side. A cell reading `PA=0 / PA=0` with
**zero** such objects would be agreement that costs nothing.

```
pristine  cells=27  SAME=17 DIFF=10 FAILED=0  VACUOUS=0
patched   cells=27  SAME=23 DIFF=4  FAILED=0  VACUOUS=0
fixed     cells=28  SAME=24 DIFF=4  FAILED=0  VACUOUS=0
```

Minimum objects on the thinner side of any cell = **2**. No cell is vacuous, none
`SURELOG_FAIL`s. The code's own empty products are refused too:
`emitClassTdSpecParams1` returns false on empty `ok1` and on empty `params1`,
`copyClassTdSpecParams1` returns on empty `params1`, so no empty
`Parameters`/`Param_assigns` vector is ever written. Instrument nit, not a
finding: `ct1grid.sh`'s `[ "$O" = 0 ] || pa_o=$((pa_o+1))` counts a
`NO_OURS_DUMP` cell into `pa_o`; that counter feeds no verdict.

---

## 2. THE NUMBERS — every one re-derived, none taken on trust

Reproduced **exactly** as reported unless flagged.

| claim | reported | verifier | |
|---|---|---|---|
| patched md5 | `9c01498a…` | `9c01498a…` | ✅ bit-for-bit |
| pristine md5 | `fc59a241…` | `fc59a241…` | ✅ bit-for-bit |
| goldens | 23 / 0 | 23 / 0 | ✅ |
| goldens `/bin/false` | 0 / 23 | 0 / 23 | ✅ |
| u2r both modes | 679 / 50 / 2 | 679 / 50 / 2 | ✅ |
| u2r testflags dump | 496 / 183 / 52 | 496 / 183 / 52 | ✅ |
| u2r row gate | 0 rows | **0 rows** | ✅ |
| surelog default | 469 / 11, FAIL 25, DEFER 5 | same | ✅ |
| surelog testflags | 465 / 8, FAIL 23, DEFER 5 | same | ✅ |
| surelog row gate | 0 rows, 4 histograms identical | **0 rows, 4 identical** | ✅ |
| patched CSV == pristine CSV | both corpora | both corpora | ✅ |
| byteverify surelog | 3 / 953 | **3 / 953, same 3 by name** | ✅ |
| byteverify u2r | 0 / 1358 | 0 / 1358 | ✅ |
| SELFCHECK / SELFCHECK1 | 952/953, 4=3+1 · 1357/1358, 1 | identical | ✅ |
| `default/SeqDriver` head | 85 → cleared | 85 → cleared | ✅ |
| `testflags/SeqDriver` head | 85 → cleared | 85 → cleared | ✅ |
| new head | `LHS:<null>` / `RHS: package uvm_pkg`, 1414891 | identical, both rows | ✅ |
| Scoreboard head | unchanged (58, `int_var …file@1038:18`) | **byte-identical head** | ✅ |
| whole-design grid, SeqDriver | DIFF 6→0, SAME 3133→3139, GOLDEN-ONLY 694 | keys 4080→4085, DIFF 6→**0**, SAME 3133→**3139**, GOLDEN-ONLY 694→694, OURS-ONLY 247→252 | ✅ |
| cell grid | SAME 17→23, DIFF 10→4, 0 regressions | identical, **+ 0 vacuous** | ✅ |
| the six movers | b11 b13 b14 b17 b22 b23 | same six | ✅ |
| remaining DIFF | b4 b15 b16 b25 | same four | ✅ |
| Scoreboard msdist | −19, ADDED 38, REMOVED 11 | −19, 38, 11 | ✅ reproduced |
| SeqDriver determinism | 1 hash each, +13623 B | identical | ✅ |
| Scoreboard determinism | **not reported** | flake both binaries, +230 B | ⚠️ **F2** |
| canaries surelog | 52/0/0, unknown 7 | identical | ✅ |
| canaries u2r | 8/0/0, unknown 25 | identical | ✅ |
| ctcan2 (baseline FIRST) | UNK=1 → 58/0 · UNK=6 → 1/0 | identical, both PASS | ✅ |
| canaudit | 29, UNCOVERED=0, FENCE=0 | identical | ✅ |
| `InterfaceModPort`, `BlackParrotComplex` + 7 more | `== baseline` | 14 rows, all `== baseline` | ✅ |
| `GOLDEN_DEFER` | UNSET | `[UNSET]` in all sweeps | ✅ |

The **only** discrepancy in the whole report is the ADDED/REMOVED instrument
mismatch in F3 (1340/8 by `mv1.sh` vs 1354/22 by raw dump diff), which is a
difference of instruments, not of facts.

### 2.1 The Scoreboard `−19`, attacked as the brief required

Attack surface 2.5 asked whether any of the 38 ADDED lines lands on an object
golden does not have. Re-run of `mv1.sh` three-way counts: **yes, several line
TEXTS have `golden=0`** — e.g. `type_parameter (work@my_scoreboard::type_id::T)`,
`ref_typespec (uvm_pkg::uvm_component_registry::T)`,
`class_typespec (my_scoreboard) @468:35-468:57`. But they are golden-absent
**texts**, not golden-absent **objects**: golden holds the same objects under its
own naming and spans (residue R6/R2). The two counts that key on `(name, span)`
rather than on fullname both move **toward** golden and one lands exactly:

```
class_typespec (type_id) @483:12-483:34   golden 9  pristine 6  patched 8   (toward, still 1 short)
|vpiName:my_scoreboard                    golden 3  pristine 2  patched 3   (EXACT)
```

So the `−19` is the multiset instrument's indentation/fullname blindness, as
claimed — and Scoreboard is **advanced, not closed** (`@483:12` is 8 vs golden 9;
residue R7 remains). Its cmp head is byte-identical before and after, and its CSV
row does not move. No regression.

---

## 3. PATCH HYGIENE AND BOUNDARIES

* Delivered patch applies clean to a **fresh `df0cdae`** (`git apply --check`
  rc=0) **and** to current head `983cf4b`.
* Working tree after apply: exactly `M include/UhdmExporter.h`,
  `M src/UhdmExporter.cpp`, `?? tools/probe/r10sd1repro/` — **3 entries, no
  strays**. Production delta +20 / +286, additions only.
* `results/*.csv` were read-only throughout; no `git stash`; `GOLDEN_DEFER`
  `[UNSET]` in every sweep; all sweeps `--jobs 2` with private `--out`/`--workdir`.
* `README.verifier.md` **is THIS pass's** — the delivered one was an
  implementer-written placeholder that said so in its first line; this file
  replaces it with the verifier's actual result.
* **Live-pass boundaries HOLD.** File-set intersection is empty both ways:
  * `r10uvm68` → `src/EmitHelpers.h`, `src/ModuleEmit.cpp`, `src/StmtEmit.cpp`, `src/TaskFuncEmit.cpp`
  * `r10earl39` → `src/ExprEmit.cpp`
  * `r10sd1` → `include/UhdmExporter.h`, `src/UhdmExporter.cpp`
  Checked constructively as well: `r10sd1.patch` then `r10uvm68.patch` both apply
  clean, in that order, to one fresh `df0cdae` worktree. **No collision.**
* The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) are dispatched by no driver here — `canaudit` FENCE-BREACH=0.

---

## 4. THE RE-CUT: `/tmp/r10sd1.verified.patch`

Delivered patch **plus** two changes and nothing else:

1. `src/UhdmExporter.cpp` gate (3): `Package` → `Package || ClassType`, with the
   finding recorded in the comment.
2. `tools/probe/r10sd1repro/grid/b28_nestedouter.sv`: the F1 witness cell.
3. this `README.verifier.md`.

**The fix is corpus-neutral — measured, not argued.** The fixed binary
(`720c56f5b7697ee91379ea03ef924327`) was swept over both corpora in both modes
and byte-compared against the **delivered patch's** databases:

```
sweeps (fixed binary), --jobs 2, GOLDEN_DEFER [UNSET]
  surelog   default 469/11  FAIL 25  DEFER 5 |  testflags 465/8  FAIL 23  DEFER 5
  u2r       default 679/50/2                 |  testflags 679/50/2
goldens (fixed binary)                              : 23 PASS / 0 FAIL
row gate vs results/golden_surelog.csv              : 0 differing ROWS
row gate vs results/gate_uhdm2rtlil.csv             : 0 differing ROWS
CSVs, fixed vs delivered, both corpora              : IDENTICAL
canaries 52/0/0 and 8/0/0; ctcan2 58/0 and 1/0      : all PASS
byteverify  uhdm2rtlil  delivered vs fixed          : 0 movers / 1358
byteverify  surelog     delivered vs fixed          : 1 mover / 953
```

The single surelog "mover" is `default/Scoreboard` — **the F2 flake, not a real
difference**, and the standing "3 reps before attributing" rule settles it:

```
Scoreboard, 3 reps per binary, same command
  delivered sizes 11122752 x3   hashes {6f99209…, 9f4d8f6…}
  fixed     sizes 11122752 x3   hashes {6ffc2f4…, 9f4d8f6…}
  SAME SIZE (size-delta would mean real) and the two hash sets INTERSECT
  on 9f4d8f6a9ce3c39d -- both binaries produce the same output population.
default/SeqDriver and testflags/SeqDriver: BYTE-IDENTICAL, delivered vs fixed.
```

So the fix moves **zero** databases in either corpus. Every gate figure in §2
carries over to the re-cut **unchanged**, and cell `b28` moves DIFF → SAME while
no other cell moves.

Roundtrip-checked: `/tmp/r10sd1.verified.patch` applies clean to a fresh
`df0cdae` **and** to current head `983cf4b`, reproduces `/tmp/wt_vsd1fix`
byte-for-byte, leaves exactly 3 porcelain entries, and `r10uvm68.patch` still
applies clean on top of it.

---

## 5. RESIDUES, RANKED (verifier's ranking)

1. **R1 — the new head on both SeqDriver rows**, `LHS: <null>` / `RHS: package
   uvm_pkg`, 1414891 lines. Confirmed **pre-existing** by F3's dump-level proof
   (zero package objects added). Still **unlocated**: not `typespec::Instance`,
   not a printed uvm_pkg vector. `cmptool` is the instrument. Largest item left.
2. **R3 — `b4`/`b15`/`b16`**, module- and package-scope typedefs of a foreign
   generic. Golden carries the specialization; we do not. Different emission
   site, zero measured corpus reach. Three ready-made witnesses.
3. **R4 — `b25`**, a package-level inline variable of an own-package generic
   (golden PA×2, ours 0). Third site.
4. **R6 — `vpiParent` of the base object** (ours `class_defn`, golden
   `module_inst work@top_tb`). cmp-invisible, but it is why our computed
   fullnames read `adpcm_pkg::adpcm_seq_item::adpcm_pkg::type_id::T`. Fixing it
   fixes the fullnames for free. It is also what keeps Scoreboard's msdist at −19.
5. **R7 — Scoreboard's surviving DIFF cell** `uvm_analysis_imp @9:3-9:19`, and
   `class_typespec (type_id) @483:12` still 8 vs golden 9. Same family as R4.
6. **R2 — argument typespec SPAN**: golden spans the macro **expansion**
   (`440:31-440:65`), we span the macro **definition** (`440:31-440:54`).
   cmp-invisible; it is the whole of the OURS-ONLY +5. Same family as the
   campaign's `getFullyOriginalLoc` note.
7. **R5 — `b11`**: a foreign package class's class-name key is not published to
   the importing module (golden 2, ours 1, identical under all three binaries).
   Arm-only; SeqDriver's real listing censuses 125 == 125.
8. **R8 — the package-anchored clone arm is UNMEASURED** and a provable no-op
   today (`copyClassTdSpecParams1` returns immediately when the base carries no
   `Parameters`). Verifier concurs it is dead code as delivered; keeping it is
   defensible for symmetry, but it should not be described as tested.
9. **NEW — Scoreboard is a hash-unstable input on both binaries** (F2). Any
   future pass that treats a Scoreboard byte difference as evidence must read the
   **size**, not the hash.

---

## 6. WHAT THE VERIFIER DID NOT DO

1. The `folded` diagnostic mode was not swept (neither target mode requires it).
2. R1 was not located — that needs `cmptool` and is the next pass's job.
3. The re-cut was **not** re-run through `detcheck` on Scoreboard (it produces
   byte-identical databases to the delivered patch, so F2's reading transfers).
4. Surelog's `CompileType.cpp` was not re-read line by line; the probe semantics
   used to justify F1 were derived from the implementer's transcription **plus**
   the measured behaviour of cell `b28`, and the measurement is the authority.
   Nested-class-in-nested-class and transitively-imported-package cells
   (attack surface 2.1's remaining half) are still unmeasured.
5. `namesAParamOf1` was probed for the `parameter type` case (F4) but not for a
   value `localparam` argument.

---

## 6.5 COMMANDS — one per finding, runnable as written

```sh
# BUILD both, BASE grep-checked, md5 asserted separately (GATE 1)
git worktree add --detach /tmp/wt_vsd1 df0cdae
git -C /tmp/wt_vsd1 apply /tmp/r10sd1.patch
bash /tmp/bld34.sh /tmp/wt_vsd1          # 9c01498a4f709a336d5b0c43399da7d3
git worktree add --detach /tmp/wt_vsd1pris df0cdae
bash /tmp/bld34.sh /tmp/wt_vsd1pris      # fc59a2414877316104c88c8c1fe43b77
git -C /tmp/wt_vsd1 rev-parse HEAD | grep -c '^df0cdae49428e3317fdfc59bef8c0800b53dc998$'

# F1 — the OVER-FIRE. golden PA=0 / pristine PA=0 / delivered PA=1
SLANG_UHDM=/tmp/wt_vsd1pris/build/slang-uhdm bash /tmp/vsd1_arm.sh \
    tools/probe/r10sd1repro/grid/b28_nestedouter.sv /tmp/vsd1_pris_b28
SLANG_UHDM=/tmp/wt_vsd1/build/slang-uhdm     bash /tmp/vsd1_arm.sh \
    tools/probe/r10sd1repro/grid/b28_nestedouter.sv /tmp/vsd1_pat_b28
SLANG_UHDM=/tmp/wt_vsd1fix/build/slang-uhdm  bash /tmp/vsd1_arm.sh \
    tools/probe/r10sd1repro/grid/b28_nestedouter.sv /tmp/vsd1_fix_b28

# F2 — Scoreboard determinism, 5 reps, SIZE is the discriminator
cd $SURELOG/third_party/tests/Scoreboard
bash tools/probe/r10sd1repro/detcheck.sh /tmp/wt_vsd1pris/build/slang-uhdm 3 <args>
bash tools/probe/r10sd1repro/detcheck.sh /tmp/wt_vsd1/build/slang-uhdm     3 <args>

# F3 — the footprint proof no short-circuit can truncate
uhdm-dump <pris SeqDriver db> | sed 1d > pris.dump
uhdm-dump <pat  SeqDriver db> | sed 1d > pat.dump
diff -u pris.dump pat.dump | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) '

# F7 — the EMPTY PRODUCT hunt (adds the TOT column ct1grid.sh lacks)
SLANG_UHDM=/tmp/wt_vsd1pris/build/slang-uhdm bash /tmp/vsd1_grid.sh pris
SLANG_UHDM=/tmp/wt_vsd1/build/slang-uhdm     bash /tmp/vsd1_grid.sh pat

# the head, per mode, with the MODE-MATCHED golden (they are different files)
uhdm-cmp ~/.cache/slang-uhdm-goldens/b5b4389e30f948a6a29f/golden.uhdm \
         <default/SeqDriver db>            # default
uhdm-cmp ~/.cache/slang-uhdm-goldens/dae43e130380ebfeaa07/golden.uhdm \
         <testflags/SeqDriver db>          # testflags

# GATES 3/4/5
python3 scripts/verify_golden.py --corpus surelog    --mode both --jobs 2 \
        --out /tmp/vsd1_sl_pat.csv  --workdir /tmp/vsd1_sl_pat_wd
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 \
        --out /tmp/vsd1_u2r_pat.csv --workdir /tmp/vsd1_u2r_pat_wd
bash tools/probe/r10sd1repro/ct8rows.sh results/golden_surelog.csv    /tmp/vsd1_sl_pat.csv
bash tools/probe/r10sd1repro/ct8rows.sh results/gate_uhdm2rtlil.csv   /tmp/vsd1_u2r_pat_tf.csv
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10sd1repro/byteverify.sh \
        /tmp/vsd1_sl_pat_wd /tmp/vsd1_sl_pris_wd

# whole-design cell grid (the DIFF 6 -> 0 claim)
python3 tools/probe/r10sd1repro/cells.py gold.dump pris.dump | tail -1
python3 tools/probe/r10sd1repro/cells.py gold.dump pat.dump  | tail -1
```

**A GATE-3 TRAP, recorded.** `results/gate_uhdm2rtlil.csv` holds **testflags rows
only**. Feeding it a both-modes CSV makes all 731 default rows read as ADDED and
`ct8rows.sh` prints `ATTENTION: rows moved`. Filter to testflags first — the
implementer did this correctly; the trap is worth naming because the failure mode
looks like a regression.

**A MEASUREMENT TRAP, recorded.** The `default` and `testflags` SeqDriver goldens
are **different cache entries** (`b5b4389e…` vs `dae43e13…`). Comparing the
testflags database against the default golden yields a spurious 6.8M-line
`design (work@top_tb)` head. This verifier hit it once; read each row's
`cmds.txt` for its own golden.

---

## 7. VERDICT

**PARTIAL — the pass is sound and lands, after F1.**

The head is genuinely cleared on both target rows; the mover set is exactly the
three census-predicted databases and nothing else moved in 953 + 1358 databases;
the whole-design cell grid closes the deficit 6 → 0 with zero SAME→non-SAME; all
five gates, all canaries and both negative controls reproduce independently; the
two binaries' md5s reproduce bit-for-bit. The refutations the implementer states
are all correct, and the one they got wrong is in their **own** verifier brief,
not in the measurements.

The blocker is F1: the stated law ("neither nested in the referencing class nor a
sibling of it in the referencing class's immediate PACKAGE scope") and the code
gate are different predicates, and on `b28_nestedouter.sv` the difference is a
SAME → DIFF regression with the dump 49 lines worse. Corpus reach is zero today,
which is why every gate figure above is still green — but "STATED GATE == CODE
GATE" is a standing law of this campaign and it is violated as delivered.

**Land `/tmp/r10sd1.verified.patch`, not `/tmp/r10sd1.patch`.**
