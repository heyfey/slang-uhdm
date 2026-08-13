# r10earl36 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PASS.**

Every number in the implementer's write-up reproduced, most of them bit-exactly,
on binaries I built myself from a **fresh worktree at 4296917** (`git worktree
add --detach`, `git apply --check` clean, BASE printed and grep-checked on both).
The five gates are green measured independently. The grid reproduces cell for
cell. The whole-design delta is byte-for-byte the claimed hunk pair.

I found **no defect in the patch**. I found **one measurement trap that burned me
and is not in the repro's trap list** (V1), **two genuinely uncovered product
cells that the patch handles CORRECTLY** (V2, V5), **one uncovered cell that is a
COUNTEREXAMPLE to the law's stated symmetry and a fence for any future widening**
(V3 — new residue R6), and **a stronger proof of the Scoreboard flake than the
implementer's own** (V8).

| | |
|---|---|
| verified against | a fresh `4296917` worktree I created (`/tmp/wt_e36v` patched, `/tmp/wt_e36p` pristine) |
| PRISTINE md5 | `5c2da1b76847bf1f1aaf14cf207eb104` — **bit-identical to the implementer's** |
| PATCHED md5 | `5500bf4d776745babe113ac3ede66f38` — **bit-identical to the implementer's** |
| patch md5 | `47eee547d055a8d7c0bcd5c8f3c41f89`, 8 files, `src/TypeEmit.cpp` 52/0 |
| also applies to | current HEAD `575f51d` — `git apply --check` rc=0, no rebase conflict |

Both md5s reproducing exactly is the strongest single result here: it means I am
measuring the *same two binaries* the implementer measured, so every downstream
number is a genuine re-measurement rather than a re-derivation.

---

## 1. PATCH HYGIENE — verified

```
$ git apply --numstat /tmp/r10earl36.patch
52   0   src/TypeEmit.cpp
61   0   tools/probe/r10earl36repro/PREDICTION.md
574  0   tools/probe/r10earl36repro/README.md
93   0   tools/probe/r10earl36repro/a1_bound.sv
58   0   tools/probe/r10earl36repro/a2_noimport.sv
50   0   tools/probe/r10earl36repro/arm36.sh
123  0   tools/probe/r10earl36repro/bndcen.py
89   0   tools/probe/r10earl36repro/pred36.py
```

Production surface is **one file, 52 insertions, 0 deletions**. I counted the
block by hand in the patched tree: **39 comment lines + 13 code lines = 52**, as
claimed. No `include/` change, therefore **no new member declared** — confirming
"no new helper, no new predicate, no new minter". `wildcardPkgParamNamed9` and
`pkgBoundValueConst9` already existed (declared and used at `src/TypeEmit.cpp`
:390 and :250, called by § shadowedImportBoundFold at :10578).

### STATED GATE == CODE GATE — read line by line, holds

The claim that this is the *packed-array carrier of a rule already implemented
for the plain-vector carrier* is **true and checkable**: `src/TypeEmit.cpp`:10574
–10580 does the identical `wildcardPkgParamNamed9` re-point for the
`defNetTsScope` (logic_typespec) arm. The new block is that re-point, transposed.

One precision note, **not** a mismatch (V9): the summary's five-bullet list
compresses the code's `bs9->kind == SymbolKind::Parameter` into "resolved symbol
NOT package-homed". The README **prose** states it correctly ("slang resolved it
to *a parameter* that is NOT package-homed"), and the in-code comment does too.
The code's semantic gate equals the README's prose gate. Separately (V10), the
`!structMemberTsCtx` conjunct is inherited from the enclosing
`if (loc && !structMemberTsCtx)` at :1860 rather than restated — which is what
makes `PREDICTION.md`'s `N_CLASSES` exclusion ("identV is not even computed
there") valid. I verified both by reading the enclosing block.

Monotonicity is real: the only write is `patPkgPar9 = wp9`, consumed at :1937 as
`if (patPkgPar9) roV = pkgBoundValueConst9(...)` with a `if (!roV)` fallback to
the bare `ref_obj`. It can only turn an unbound `ref_obj` into a constant, and a
non-integer package value falls back safely.

### collisions — none

| pass | files | overlap |
|---|---|---|
| `r10uvm64` (landed `575f51d`) | `src/ExprEmit.cpp`, `include/UhdmExporter.h` | none |
| `r10uvm65` (`/tmp/r10uvm65.patch`) | `src/TaskFuncEmit.cpp`, `include/UhdmExporter.h` | none |
| `r10svs9` (`/tmp/r10svs9.patch`) | `src/StmtEmit.cpp`, `include/UhdmExporter.h` | none |

No live pass touches `src/TypeEmit.cpp`. Confirmed by `git apply --numstat`, not
by reading a claim.

### earl34 / earl35 arms hold

I ran all five prior arms under **both** binaries and diffed the dumps
(path-normalised):

| arm | pristine vs patched |
|---|---|
| `r10earl34repro/a1_idxkind.sv` | **0 delta lines** |
| `r10earl34repro/a2_shape.sv` | **0** |
| `r10earl34repro/a3_escaped.sv` | **0** |
| `r10earl35repro/a1_flat.sv` | **0** |
| `r10earl35repro/a2_wire.sv` | **0** |

Byte-identical, so whatever verdict each carried at 4296917 is preserved exactly.

---

## 2. THE FIVE GATES, measured by me

**GATE 1 — BUILD. GREEN.** `cmake --build` from absolute paths; waited for
`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm` on
both; `grep -c 'error:'` = **0** on both. md5 asserted in a **separate** step,
32-hex-checked, and differs between the two binaries. `git rev-parse HEAD` =
`42969177aac74db7c595d3707945c7bfbab87071` grep-checked on both; pristine
`git status --porcelain` **empty**.

> Ops note for the next pass: my first attempt ran both builds concurrently at
> `-j8` and cc1plus was **OOM-killed** on a 15 GB box (`c++: fatal error: Killed
> signal terminated program cc1plus`). That prints as `error:` count 1 and looks
> like a compile failure. Serialised at `-j4` both built clean. Not a code defect.

**GATE 2 — GOLDENS. GREEN.** `tests/check_goldens.sh` with `SLANG_UHDM` pointed
at the patched build: **23 PASS / 0 FAIL**. Negative control
`SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL**, rc=1 — the harness really executes
the binary under test.

**GATE 3 — uhdm2rtlil, `--mode both --jobs 2`, own `--out`/`--workdir`. GREEN.**

```
[default]   CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2   -> 679/50/2
[testflags] CMP_EQUAL 679  SLANG_REJECT 50  SURELOG_FAIL 2
dump histogram (testflags): 496 match / 183 differ / 52 blank
ct8rows vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 diff row-sides)
  "PASS: every row byte-identical to the committed baseline"
```

I **independently confirmed the implementer's mode-projection disclosure** rather
than taking it on trust:
`awk -F, 'NR>1{c[$2]++}'` on the committed baseline prints `testflags 731` and
**no `default` rows at all**. Fed the unprojected CSV, `ct8rows` reports **731
differing ROWS** — all ADDED `default` rows, with the testflags histograms
identical base vs fresh. The disclosure is exact and the projected reading is the
committed gate, not a weakened one.

**GATE 4 — surelog, BOTH modes, `--jobs 2`. GREEN.**

```
[default]   CMP_EQUAL 467  CMP_NOTEQUAL 13   -> 467/13
[testflags] CMP_EQUAL 463  CMP_NOTEQUAL 10   -> 463/10
ct8rows vs results/golden_surelog.csv: 0 differing ROWS (0 diff row-sides)
dump histograms UNCHANGED both modes:
  default   327 / 242 differ / 225 match     (base == fresh)
  testflags 331 / 298 differ / 165 match     (base == fresh)
```

Patched and pristine CSVs are **byte-identical** (`cmp` silent, both
`ac4cab4119732769756cee08325dd99e`) in both corpora — so the whole-row gate is
blind by construction and GATE 5 is doing the real work, exactly as claimed.

**GATE 5 — BYTE VERIFIER, both corpora both modes, `SELFCHECK=1 SELFCHECK1=1`.
GREEN.**

```
uhdm2rtlil:  PATH_SETS_IDENTICAL (1358)  MOVERS: 0 / 1358
             SELFCHECK 1357/1358   SELFCHECK1 1
surelog:     PATH_SETS_IDENTICAL (953)
             MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
                   patched=8933713c71fb pristine=2699befd0213
             MOVERS: 1 / 953        SELFCHECK 952/953   SELFCHECK1 2
```

**ONE real mover in 2311 databases and it is the target.** I measured **1**,
where the implementer measured 2 — the difference is the Scoreboard flake, which
did not recur for me. See V8: that non-recurrence, plus a cross-binary md5
collision, proves the flake harder than the implementer's own 3-rep argument.

### CANARIES — all reproduce

| check | my result | claimed |
|---|---|---|
| `canaries.sh` vs `golden_surelog.csv` | ok=52 changed=0 absent=0, unknown-names=7 | same |
| `canaries.sh` vs u2r (testflags projection) | ok=8 changed=0 absent=0, unknown-names=25 | same |
| `ctcan2.sh` EXPECT_UNKNOWN=1, surelog, baseline FIRST | **PASS** ok=58 changed=0 absent=0, unknown-patterns=1 | same |
| `ctcan2.sh` EXPECT_UNKNOWN=6, u2r, baseline FIRST, mode-matched | **PASS** ok=1 changed=0 absent=0, unknown-patterns=6 | same |
| `canaudit.sh` | audited=29 **UNCOVERED=0 FENCE-BREACH=0**, 4 fenced names not dispatched | same |
| `InterfaceModPort` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh | same |
| `BlackParrotComplex` BY NAME | base `default/CMP_EQUAL/differ testflags/CMP_EQUAL/differ` == fresh | same |
| `Earlgrey_0_1` BY NAME | base `default/CMP_NOTEQUAL testflags/SLANG_REJECT` == fresh | same |

The unprojected u2r readings the implementer disclosed also reproduce exactly:
`canaries.sh` → `absent=8`, `ctcan2` → `absent=1` **and FAIL**. Both readings
printed here for the same reason they printed them: so the green one cannot be
mistaken for the only one taken. `GOLDEN_DEFER` verified **UNSET**.

---

## 3. THE TARGET AND THE WHOLE-DESIGN DELTA — reproduced bit-exactly

| quantity | claimed | I measured |
|---|---|---|
| pristine head, `uhdm-cmp` lines | 42 | **42** |
| pristine head object | `constant: , id:927782, line:22:67, endln:22:75` | **identical** |
| pristine dump lines (`sed 1d`) | 4654894 | **4654894** |
| patched dump lines | 4654903 | **4654903** |
| `diff o.dump p.dump` | 1 hunk pair, 2 removed / 11 added | **1 hunk pair, 2 removed / 11 added** |
| multiset distance to golden, pristine | 309338 | **309338** |
| multiset distance to golden, patched | 309329 | **309329** |
| golden-only instances | 238946 → 238937 | **238946 → 238937** |
| ours-only instances | 70392 → 70392 | **70392 → 70392** |
| patched head, `uhdm-cmp` lines | 48 | **48** |
| patched head object | `hier_path: (flash_ctrl_i.rd), id:90798, line:129:13, endln:129:28` | **identical** |

The whole-design diff is **byte-for-byte** the block quoted in the write-up, in
4.65 M lines:

```
4476952c4476952
<       \_ref_obj: (NumBanks), line:22:67, endln:22:75
>       \_constant: , line:22:67, endln:22:75
4476955c4476955,4476964
<         |vpiName:NumBanks
>         |vpiDecompile:2  |vpiSize:32  |UINT:2  |vpiTypespec:
>         \_ref_typespec:  ( |vpiParent: -> the constant ; |vpiActual: ->
>                            \_int_typespec: , line:11:14, endln:11:17 )
>         |vpiConstType:9
```

### the 13-shape accounting closes exactly, regressions included

Every one of the 13 cells reproduced, `|g−o|` and `|g−p|` alike, **including the
two rows that move the wrong way**:

| line shape | g | o | p | \|g−o\| | \|g−p\| | |
|---|---|---|---|---|---|---|
| `\_constant: …22:67…` (depth 6) | 2 | 1 | 2 | 1 | **0** | CLOSER |
| `\_constant: …22:67…` (depth 10) | 1 | 0 | 1 | 1 | **0** | CLOSER |
| `\_int_typespec: …11:14…` | 23 | 22 | 23 | 1 | **0** | CLOSER |
| `\|vpiDecompile:2` | 188 | 187 | 188 | 1 | **0** | CLOSER |
| `\|vpiName:NumBanks` | 5 | 6 | 5 | 1 | **0** | CLOSER |
| `\_ref_obj: (NumBanks)…` | 0 | 1 | 0 | 1 | **0** | CLOSER |
| `\_ref_typespec: ` | 244 | 226 | 227 | 18 | 17 | CLOSER |
| `\|UINT:2` | 228 | 224 | 225 | 4 | 3 | CLOSER |
| `\|vpiConstType:9` | 5790 | 5693 | 5694 | 97 | 96 | CLOSER |
| `\|vpiSize:32` | 1018 | 1014 | 1015 | 4 | 3 | CLOSER |
| `\|vpiTypespec:` | 9004 | 9002 | 9003 | 2 | 1 | CLOSER |
| `\|vpiParent:` | 77691 | 77832 | 77833 | 141 | **142** | **FURTHER** |
| `\|vpiActual:` | 21705 | 21873 | 21874 | 168 | **169** | **FURTHER** |
| **sum** | | | | **440** | **431** | **−9** |

11 improvements, 2 regressions, net −9 — stated by the implementer, and true.
Reporting the two FURTHER rows rather than netting them away is correct practice
and I confirm the numbers.

### the mover fence: 13 candidates, and I re-derived all 12 exclusions from SOURCE

`pred36.py` on my own pristine dump prints **13 distinct, 13 prints** — the
identical set. I then checked each exclusion against the source **and caught
myself using the wrong source tree first**: there are six `flash_mp.sv` in the
corpus, and `IncompTitan`'s line numbers do not match. The tree
`Earlgrey_0_1/sim-icarus/lowrisc_systems_top_earlgrey_0.1.scr` compiles is
`third_party/tests/Earlgrey_0_1/src/`. Re-checked there, every claim holds:

| candidate | claimed reason | verified |
|---|---|---|
| `NumBanks` @22:67 | flash_mp:12 `parameter int NumBanks = 2`; body import at :51; `flash_ctrl_pkg.sv:11` `localparam int NumBanks` | **all four lines read and confirmed**, `int` at col 14 = golden's `int_typespec@11:14` |
| `TotalRegions` @21:69 | module localparam, no package twin | only decl is flash_mp:14; **no package declares it** |
| `alert_pkg::NAlerts` ×2, `alert_pkg::N_ESC_SEV` ×2 | written QUALIFIED | `::` visible in the candidate names, `::`-guard |
| `N_CLASSES` @41:15, @54:15 | `structMemberTsCtx` | both lines are inside `typedef struct packed {` in `alert_pkg.sv` |
| `N_ESC_SEV` @26:20, @27:20 | `prim_esc_pkg` declares no `N_ESC_SEV` | `grep -c` = **0**; nmi_gen's only import is `prim_esc_pkg::*`; the name is nmi_gen:13's own `localparam int unsigned N_ESC_SEV = 4` |
| `NrHarts` ×2, `NrHartsAligned` | `dm_csrs`/`rv_dm` have no wildcard import | **zero `import` lines at all** in both files |

`N_ESC_SEV` deserves a note: `alert_pkg` **does** declare `N_ESC_SEV`, and
nmi_gen does not import it. That makes the a2 control cell `n_shp` — twin exists
in a package that is **not** imported, golden keeps the bound symbolic — a shape
that is **realised in the real corpus**, not a synthetic hypothetical. The fifth
conjunct is load-bearing on live code.

### the two view refutations are TRUE

**F1** — the brief's "ELABORATED module context" is false. The elab-view left
bound at `line:22:67` is `constant |vpiDecompile:1 |vpiSize:64 |INT:1
|vpiConstType:7` and I diffed golden against pristine there: **identical before
the patch**. Confirmed.

**F2** — no fold is added. I read both def-view subtrees: `\_operation:` with
`|vpiOpType:11` is present on **both** sides, before and after; only the first
operand changes from `\_ref_obj: (NumBanks)` to `\_constant: … |UINT:2`.
Confirmed.

**R3** — `\_int_typespec: , line:11:14, endln:11:17` over all indents: golden
**137**, pristine **114**, patched **115**. 137 − 115 = **22 short**, exactly as
ranked.

---

## 4. THE GRID — reproduced cell for cell, both arms

I built the cell→line map myself from the arm sources and ran `bndcen.py`
three-way (golden / pristine / patched).

**a1 (22 cells): FIXED 6 · unchanged-correct 14 · STILL WRONG 2 · REGRESSIONS 0.**
Confirmed exactly. `a_shp` `UINT:5 sz32 ct9 ->int_typespec@22:14` (package value
5, not the module's 9); `a_shpp` `UINT:6 ->@24:14`; `a_shimpl` `UINT:4 ->@25:3`
(the untyped-localparam whole-decl span); `a_shlp` `UINT:7 ->@23:14`; `a_two`
dim-1 folds while its no-twin dim-2 stays `ref_obj(NOCOLL)`; `c_shp` body net.
Patched == golden on every fixed cell's bound entries.

**The separating pair is real and I re-measured it.** `a_shlp` — module
**localparam**, shadowed — folds in golden. `a_nocoll` — module **parameter**, no
twin — stays `ref_obj(NOCOLL)` in golden. **The parameter/localparam axis is
refuted in both directions**; the axis is the SHADOW. F4 stands, and the
implementer is right that without this grid the patch would have folded every
module-parameter bound in the corpus.

**a2 (7 cells): FIXED 1 (`h_shp`) · unchanged-correct 6 · REGRESSIONS 0.**
Confirmed. `n_shp`, `n_bshp`, `n_body`, `n_blp` — twin present, **no import** —
golden keeps `ref_obj`, and so do we. No over-fire. `h_shp` shows import SITE is
not an axis.

Residues R1 and R2 confirmed as still-wrong and PRE-EXISTING: `a_shp_plain`
golden def `UINT:5 sz32 ->@22:14` vs golden elab `UINT:9 sz32 ->ts` vs ours
`UINT:9 sz64` no-ts ×3 (three stacked defects, and the two views want **different
answers** — the decision not to widen `plainIdV` is correct); `a_clog` golden
keeps `op11` with the pkg leaf inside `$clog2`'s argument while we emit one
`UINT:3 sz64` over the whole bound, identically in pristine and patched.

Per-arm, the complete pristine→patched delta is **only** removed
`\_ref_obj:`/`|vpiName:` pairs and added constant groups — 6 bounds in a1, 1 in
a2 — nothing else at all. That is the monotonicity claim measured rather than
argued.

---

## 5. MY OWN FINDINGS

### V1 — THE TRAP THAT BURNED ME: `verify_golden.py` defaults `SLANG_UHDM` to the MAIN TREE

`scripts/verify_golden.py`:52

```python
SLANG_UHDM = os.environ.get('SLANG_UHDM',
                            os.path.join(HOME, 'git-repos', 'slang-uhdm', 'build', 'slang-uhdm'))
```

Running it *from inside a worktree* does **not** make it use that worktree's
binary. My first sweep pair — launched with `cd /tmp/wt_e36v && python3
scripts/verify_golden.py …` and no `SLANG_UHDM` — silently measured the
**main-tree** binary (`c7f318688961a24d51d9a4d958bcf2ad`, a *third* build, at
HEAD `575f51d`) on **both** sides. It produced a fully plausible false-green:
GATE 4 read 467/13 + 463/10 with 0 differing rows, and GATE 5 read **`MOVERS: 0 /
953`** with `SELFCHECK 952/953` — every control passing. I caught it only because
`0` movers contradicted the arms, which had already proved the binaries differ.

`arm36.sh`'s header documents this trap for itself ("both harness scripts default
it to the MAIN TREE") but the repro's trap list does **not** carry it for
`verify_golden.py`, which is what the five gates actually run. **Recommendation:
add it, and add a positive control** — sample `ps` for the invoked binary path
during the sweep, which is how I confirmed the relaunch:

```
$ for i in 1 2 3 4 5 6; do ps -eo args | grep -v grep |
      grep -oE '^[^ ]*build/slang-uhdm'; sleep 5; done | sort | uniq -c
      1 /tmp/wt_e36p/build/slang-uhdm
      2 /tmp/wt_e36v/build/slang-uhdm
```

This is **not** an implementer defect: their GATE 5 reported the target as a
mover, which is impossible with one binary on both sides, so they set the
variable. It is a hole in the durable record.

### EMPTY PRODUCT CELLS — I built arm `a3v_gaps.sv` for the six the grid omits

a1/a2 cross carrier × symbol-kind × shadow × bound-form × depth × position ×
import-site. Six product cells are in neither file. I built them and measured
golden / pristine / patched three-way.

**V2 — the RIGHT-hand bound was never measured, and the patch is CORRECT there.**
Every packed cell in a1/a2 puts the shadowed name in the LEFT bound; the right
bound is always a literal. Cell `g1_right` (`q3::f_t [0:SH_P-1]`):

| | |
|---|---|
| GOLDEN | `const[UINT:5 sz32 ct9]->int_typespec@38:14` — the PACKAGE value |
| PRISTINE | `ref_obj(SH_P)` |
| PATCHED | `const[UINT:5 sz32 ct9]->int_typespec@38:14` — **matches golden** |

`mkBound` is shared, so the arm fires symmetrically, and golden wants it to. Gap
closed, no action.

**V3 — GENERATE-BLOCK-SCOPED net: golden does NOT substitute. A COUNTEREXAMPLE to
the law's stated symmetry, and a fence for any future widening. NEW RESIDUE R6.**
Cell `g5_genblk` — `q3::f_t [GB_P-1:0]` declared inside `if (1) begin : gb`, with
`GB_P` a module parameter shadowing `q3::GB_P`, same body wildcard import:

| | |
|---|---|
| GOLDEN | `const[INT:8 …ct7] ×1` + `const[UINT:1 …]` + **`ref_obj(GB_P)`** — the def-view op is KEPT and the leaf stays SYMBOLIC |
| PRISTINE | `const[INT:8 sz64 ct7] ×2` — we fold the whole bound, in both views, and never emit the op form |
| PATCHED | identical to pristine — **the arm does not reach it** |

Two things follow. First, this is a **pre-existing divergence** in a container the
implementer's grid never measured, and it is untouched by the patch. Second and
more important: the law's summary says the shadow substitution is "symmetric in
kind … port or body net — all fold the same". A **generate-block** net is where
golden **does not** fold, so the symmetry has a CONTAINER limit. `wildcardPkg
ParamNamed9` walks up to `InstanceBody` and *would* find the import from a
generate scope, so a future pass that widens this arm to the generate-block path
would **over-fire**. Recording golden's answer now, before anyone writes that.

**V4 — a package name that is NOT a parameter: abstain is golden-faithful.** Cell
`g3_nonparam` (package declares `typedef logic NPNAME`, module declares
`parameter int NPNAME`): golden keeps `ref_obj(NPNAME)`; pristine and patched
both keep it. `wildcardPkgParamNamed9`'s `kind == Parameter` filter is correct.

**V5 — TWO wildcard imports both declaring the name: first-found-wins agrees with
golden on this sample.** Cell `g4_ambig` — `q3::AMB = 7` imported first,
`q3b::AMB = 8` imported second, module `parameter int AMB = 9`. Legal SV, because
the module's own declaration shadows both so no ambiguous unqualified reference
occurs.

| | |
|---|---|
| GOLDEN | `const[UINT:7 sz32 ct9]->int_typespec@40:14` — **`q3::AMB`, the first import** |
| PRISTINE | `ref_obj(AMB)` |
| PATCHED | `const[UINT:7 …]->@20:14` — **matches golden** |

`wildcardPkgParamNamed9` returns the first hit in `wildcardImports` order and
that agreed with golden here. Stated honestly: this is agreement on **one
ordering sample**, and the ordering behaviour is **inherited** from
§ shadowedImportBoundFold rather than established by this pass. Not a defect;
an untested assumption now half-tested and recorded.

**V6 — the "explicit import" axis is VACUOUS, not merely uncovered.** I tried to
build a cell where a non-wildcard `import q3c::EX_P;` is shadowed by a module
`parameter int EX_P`. slang rejects it outright:

```
error: redefinition of 'EX_P' [-Wredefinition]
  import q3c::EX_P;
note: previous definition here
  parameter int EX_P = 9
```

An explicitly-imported name **cannot** be shadowed by a module-local declaration.
So restricting the walk to wildcard imports loses nothing, and "import kind" is
not an axis at all. Cell deleted rather than reported as a gap.

**Also measured and clean:** `g6_unpacked` (`q3::f_t u [SH_P-1:0]`, the
`array_typespec` carrier) — golden and both our builds agree; no divergence.

Reproduce the a3 grid with the committed arm:

```
$ SLANG_UHDM=<build>/slang-uhdm ./arm36.sh a3v_gaps.sv /tmp/a3
$ python3 bndcen.py /tmp/a3/g.dump \
    62=g1_right,63=g3_nonparam,64=g4_ambig,70=g6_unpacked,73=g5_genblk \
    /tmp/a3/o.dump
```

Across all three arms the complete pristine→patched delta remains only removed
`ref_obj`/`vpiName` pairs and added constant groups: **a1 6 bounds, a2 1, a3 2**,
and the a3 pair is exactly `g1_right` and `g4_ambig`, both of which golden wants
folded. **No over-fire anywhere in the expanded product.**

### V7 — small accounting nit in the a1 table

"FIXED = 6 cells (7 bounds — `a_two` carries two)" is defensible as written, but
the number of **moved** bounds is **6**, not 7: `a_two`'s `NOCOLL` dim correctly
does not move. The a1 dump delta contains exactly **6** removed `\_ref_obj:`
lines. Worth phrasing as "6 cells, 6 moved bounds, 7 bounds total" so the figure
cannot be read as a mover count.

### V8 — the Scoreboard flake, proved HARDER than the implementer proved it

In **my** sweeps Scoreboard did not move at all (`MOVERS: 1 / 953`), and both my
binaries produced:

```
0163f3d486538b8a2b13490b90d3661c   /tmp/e36p_wd_sl/default/Scoreboard-59431470/slang.uhdm   (PRISTINE)
0163f3d486538b8a2b13490b90d3661c   /tmp/e36v_wd_sl/default/Scoreboard-59431470/slang.uhdm   (PATCHED)
```

`0163f3d48653` is **the exact md5 the implementer recorded for their PRISTINE
binary in reps 1 and 2**. So a **PATCHED** binary reproduced a **PRISTINE**
binary's Scoreboard output byte-for-byte. That cross-binary collision is
decisive: the output is not a function of the patch, and the difference the
implementer saw is § emitter-nondeterminism. Size 11133449 on every observation.
This is stronger than the same-binary 3-rep argument, and it independently
vindicates the attribution.

---

## 6. RANKED RESIDUES

The implementer's five, all confirmed by me, plus two of mine.

1. **R1 — PLAIN-IDENT packed bound, wrong in BOTH views with DIFFERENT golden
   answers per view.** Re-measured: golden def `UINT:5 sz32 ->its@22:14`, golden
   elab `UINT:9 sz32 ->ts` ×2, ours `UINT:9 sz64` no-ts ×3. Three stacked defects
   (def symbol, size 64 vs 32, missing `ref_typespec`). Confirms that *not*
   widening `plainIdV` was correct: the one-line change fixes one print and breaks
   two. Fix per view; a1 already carries the witness.
2. **R2 — SYS-CALL bound fully folded where golden keeps the operation.**
   Re-measured, PRE-EXISTING, structurally unreachable by this arm
   (`$clog2(...)` is not an identifier). Corpus population still unmeasured.
3. **R6 (NEW, mine) — GENERATE-BLOCK-scoped shadowed bound.** Golden keeps the
   def-view `op11` + `ref_obj`; we fold the whole bound to `INT sz64` in both
   views and never emit the op form. Pre-existing and untouched here. Ranked
   above R3 because it is **both** a defect **and** a NEGATIVE that constrains
   the obvious next extension of this very law — the container is a discriminator
   golden uses, and widening the arm to generate scopes would over-fire.
4. **R3 — `int_typespec@flash_ctrl_pkg.sv:11:14` still 22 short** (golden 137,
   ours 115, verified). Cheapest true extension: enumerate the 22 other reads and
   find which are shadowed bounds in an uncovered container. R6 says to check the
   container's *sign* before assuming they all want folding.
5. **R4 — THE NEW HEAD.** `hier_path: (flash_ctrl_i.rd)` @flash_phy.sv:129:13, a
   port's `vpiActual`, 48 cmp lines, verified printing identically on both sides
   in the log's first 20 lines. A naming axis; must be localised field-by-field.
6. **R5 — the `|vpiParent:` / `|vpiActual:` surplus** this patch necessarily grows
   by one each. Verified: 141→142 and 168→169, in a pre-existing surplus of that
   size. Population difference elsewhere, far larger than this pass.
7. **R7 (NEW, mine) — the durable record should carry V1.** Add
   `verify_golden.py`'s main-tree `SLANG_UHDM` default to the repro's trap list,
   with the `ps`-sampling positive control, because that default produces a
   fully-controlled false-green on the gate that matters most (GATE 5).

---

## 7. WHAT I RAN

Worktrees `/tmp/wt_e36v` (patched) and `/tmp/wt_e36p` (pristine), both fresh
`--detach` at `4296917`. Arms in `/tmp/r10earl36v_arm` (`a1`, `a2`, my
`a3v_gaps.sv`, and the five earl34/earl35 arms). Sweeps `/tmp/e36{v,p}_wd_{sl,u2r}`
with own `--out`/`--workdir` at `--jobs 2`, `SLANG_UHDM` set explicitly and
verified by `ps` sampling. Dumps in `/tmp/e36v_dmp` (`g/o/p.dump`, all `sed 1d`).
Reused unchanged and by absolute path: `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`, `r10uvm52repro/canaries.sh`,
`r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`, `r10earl36repro/{arm36.sh,
bndcen.py,pred36.py}`. `results/*.csv` read-only; no `git stash`; `GOLDEN_DEFER`
UNSET; the four SLANG-FENCED names never dispatched (asserted by `canaudit.sh`).
Sweep workdirs and dumps deleted after measurement.
