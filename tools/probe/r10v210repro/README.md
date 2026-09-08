# r10v210 — ADVERSARIAL VERIFICATION of r10uvm210. **Verdict: ACCEPT.** Every headline number reproduces bit-for-bit on an independently built binary; the refutation stands; four write-up defects are named and corrected here.

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**; nothing
was promoted and **NO CORPUS ROW CONVERTED** in either direction.
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
by any driver here; where a corpus census reaches one, its name is redacted by
the pass's own `scrub210.sh` (which reads the list out of `canaudit.sh` and
never spells one).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, everywhere below.

| | |
|---|---|
| BASE | `18d0800c` |
| verifier worktrees | `/tmp/wt_v210` (BASE + `/tmp/r10uvm210.patch`), `/tmp/wt_v210pris` (clean BASE) |
| both binaries, built by the verifier at `-j 2`, frozen `chmod 555` | **md5 `1644b8e244f1b5caca4f876ebc99d1e9`, IDENTICAL** — the implementer's claimed md5, reproduced by an independent build from a clean worktree |
| production surface of the patch | **NONE.** 31 files, all under `tools/probe/r10uvm210repro/`; `src/` and `include/` untouched; `CMakeLists.txt` does not reference `tools/probe`, so the two builds agree by construction and the boundary is *proven*, not sampled |
| fence check | each of the four names in `canaudit.sh`'s `FENCED=` list: **0 / 0 / 0 / 0** files outside `canaudit.sh` itself |
| gate-script copies | `byteverify.sh`, `canaries.sh`, `canaudit.sh`, `ct8rows.sh`, `ctcan2.sh`, `rowheads.sh` are **byte-identical** to the canonical committed copies (`cmp` against every other `tools/probe/*/` copy) |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Every number below was re-measured by the verifier on its own binary, its own
sweep workdirs and its own probe builds. Full transcripts: `GATES.r10v210.txt`,
`CENSUS.r10v210.txt`, `CROSSING.r10v210.txt`.

| claim | verifier's measurement |
|---|---|
| pristine binary md5 `1644b8e2…` | **reproduced exactly** from a clean `18d0800c` worktree |
| goldens 23 PASS / 0 FAIL, `/bin/false` 23 FAIL | 23 / 0 on **both** binaries; negative control 23 FAIL |
| uhdm2rtlil 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both modes | **679 / 50 / 2** in both modes on both binaries |
| `ct8rows` u2r testflags vs `results/gate_uhdm2rtlil.csv` | **PASS**, every row byte-identical |
| surelog 1588 rows: 473/8 default, 468/7 testflags | **exactly**; **NO ROW CONVERTED** |
| the two moved row-SIDES are the informational dump column on `Earlgrey_0_1` ×2 | **exactly** — `CMP_EQUAL/differ` → `CMP_EQUAL/`, and the verifier's **pristine** sweep reads them the same way |
| rowheads SeqDriver 50/1, SimpleUVM 86/1, Scoreboard 95/1, MiniAmiq 112/1, BuildUVMPkg 0/0, Earlgrey 0/0, Rggen 0/0 | **line for line identical**, including the two `SKIP-NOFILE` rows |
| the head log | 50 lines, one `^LHS:`, **identical to `head_pris_SeqDriver.default.cmp` modulo object ids** |
| golden's def `uvm_pkg` `PA[35]` Rhs is `ref_obj UVM_SET` `ACTUAL=operation@216:31-216:48` **and so is ours** | **reproduced** (`ct210own --slots`, both databases) — the brief's law is already emitted |
| `PARAM_ASSIGNS DIFFERING 7 / 45` in all four package listings, index 35 never among them | **reproduced**, same seven indices, same `FAILL 61413` / `FAILR 6275` pair, same ids |
| SeqDriver form census 590 / 590 / AGREE 590 / 0 / 0, exactly two REF cells, both agreeing | **reproduced** |
| surelog census 956 rows, AGREE 52724, ONLY-GOLDEN 37 (29 CONST / 4 OP / 2 NONE / 2 REF), ONLY-OURS 3123, 27 rows | **reproduced exactly**, and **both REF cells sit on one slang-fenced row** |
| uhdm2rtlil census 1358 rows, 0 / 0, AGREE 68676 | **reproduced exactly** |
| canaries `ok=50 changed=2` / `ok=8 changed=0`; `ctcan2` PASS ×2; `canaudit` PASS `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **reproduced** |
| `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` per mode | **reproduced, every one** |
| the four protected CMP_EQUAL row-modes at rc=0 | `BuildUVMPkg` ×2 and `Earlgrey_0_1` ×2 **CMP_EQUAL, 0 cmp lines, 0 heads, cmp rc=0**, on both binaries |

**byteverify, done properly.** The pass could only self-compare (no second
binary). The verifier built two binaries from two worktrees, ran **four** sweeps,
and compared two real workdirs: **surelog MOVERS 1 / 956, uhdm2rtlil MOVERS
0 / 1358**, `SELFCHECK` firing 955/956 and 1357/1358. The single mover is
`Scoreboard/default`, the documented ~50/50 coin — attributed ORDER-BLIND
(uhdm-dump both, normalise the workdir path, `sort`): **1100449 lines each,
0 differing lines**. That is the emitter-nondeterminism floor, not a code effect.

---

## 2. THE REFUTATION IS SOUND

The brief asked for a gated *unfold* — emit a `ref_obj` where golden keeps one
and we fold. Three independent measurements say it is already emitted and has no
corpus population:

1. **The head cell itself.** `ct210own --slots` on both databases: golden's DEF
   `uvm_pkg` `PA[35]` and ours are the same form, name, fullname, actual kind and
   actual span. Running the OFFICIAL `param_assign::Compare` on each index with a
   fresh `CompareContext` puts index 35 outside the seven differing cells in all
   four package listings, in both modes.
2. **The census key cannot hide the shape.** The key is
   `<owner kind>|<owner name>|<view>|<Lhs name>|<Lhs line:col>|<Rhs FORM>|<ref ACTUAL kind>`
   over **every** scope with `Param_assigns` (not just packages and modules). A
   golden `REF` met by an ours `CONST` at the same declaration necessarily shows
   as one-sided on **both** sides; the key can only over-report, never mask. The
   whole surelog corpus carries **two** `REF`-form ONLY-GOLDEN cells and both are
   on one slang-fenced row; uhdm2rtlil carries none.
3. **The rows that could act.** At BASE the actionable `CMP_NOTEQUAL` rows are
   `SeqDriver` ×2, `SimpleUVM` ×2, `MiniAmiq` ×2 and `Scoreboard`/default (the
   remaining eight are the four fenced tests). Every one of them scores
   `ONLY-GOLDEN=0 ONLY-OURS=0`. A gated unfold would have moved zero cells.

Shipping probes and evidence with an empty production surface was the right
call, and the pass says so plainly rather than dressing it up.

---

## 3. FOUR DEFECTS IN THE WRITE-UP (all corrected here; none changes the verdict)

**D1 — the grid's "CALIBRATION" is a tautology.** `grid210.sh` computes

```
cal=$(diff <(sort "$d/g.key") <(sort "$d/g.key") | wc -l)
```

— the golden key file against **itself**. `diff f f` is empty for every input, so
`TOTAL CALIB non-null: 0` in `GRID.r10uvm210.txt` carries no information at all,
and the README's "golden-vs-golden CALIBRATION run FIRST in every cell" is not
what the script does. A real calibration needs a second Surelog build of the same
arm (or two extractions of the same golden). The arms' `ONLY-GOLDEN` /
`ONLY-OURS` counts are unaffected; only the control is void.

**D2 — the byte-identity claim is contradicted by the pass's own transcript.**
`README.md` says the pristine binary is "**byte-identical to the main tree's own
`build/slang-uhdm` at that commit**". `GATES.r10uvm210.txt` prints
`1644b8e244f1b5caca4f876ebc99d1e9` for the pass binary and
`6fcb25434647c0559ba55ab2f1414bad` for the main tree's — **different files**.
(The main tree had moved past `18d0800c` by then, so the comparison was not a
comparison at that commit.) The verifier's own clean-worktree build at
`18d0800c` reproduces `1644b8e2…` exactly, so the *reproducibility* claim holds;
the *byte-identity-with-the-main-tree* sentence should be struck.

**D3 — `grid210/g210_g_clsty.sv` does NOT reproduce the R0 shape.** R0 tells the
next pass to score that arm with `ct210inst --tsinst`. Measured:

```
arm g210_g_clsty, parse and elab, GOLDEN and OURS:  TSI DISTINCT KEYS 0
unsupported_typespec objects in either database:    0
```

Neither producer mints an `unsupported_typespec`, and **no typespec in that arm
carries an `Instance` at all** — so the arm is blind to the mechanism R0 names,
in both views. Its `0 / 0` FORM score is an arm agreeing, not an arm testing
(RESUME §9). Two closer reproducers written here — a parameterized class
extending a parameterized base with the type parameter forwarded and specialized
(`arms210v/r0_a.sv`), and the same with a class-typed default
(`arms210v/r0_b.sv`) — also score `TSI DISTINCT KEYS 0` on both sides.
**R0 currently has no working arm.** The nearest thing that does move is
`arms210v/v210_7_muststay.sv` (§ 4), whose parse view shows golden minting
`Instance`-carrying typespec copies we do not mint and a count split we do not
match — a different object kind but the same per-view mint-and-`Instance`
question. Start the R0 golden grid there.

**D4 — R0's population is 17 keys, not 16, and one is not a class type
parameter.** Joining every typespec on `<kind>|<name>|<line:col>` across both
SeqDriver databases and keeping the keys where golden names the DEF `uvm_pkg`
and we never do gives **17** (`CROSSING.r10v210.txt` §D): the sixteen `REQ`/`RSP`
`unsupported_typespec` keys the pass named, **plus
`logic_typespec|uvm_pkg::uvm_integral_t|59:9`**, where golden reads
`{DEFPKG:adpcm_pkg 1, DEFPKG:uvm_pkg 1, ELABPKG:uvm_pkg 1}` and ours reads
`{DEFPKG:adpcm_pkg 3}`. That one is a package typedef's typespec, not a class
method local, so R0's surface is wider than "the def-view class-method-clone
family".

**A gap, not a defect — the route from the seven cells to the crossing object was
asserted, not measured.** `ROUTE.r10uvm210.txt` §C prints only the summary
`WITH-INSTANCE=7` and §E then names the `REQ` typespec. The per-cell `Instance`
(which `ct210inst --pa-inst` does print) shows **both sides pointing all seven
recursing cells at their OWN DEF package** — so the crossing is *not* at the Rhs
constant's typespec, it is deeper inside the package-vs-package walk. The
conclusion survives on residency alone (golden's `ref_obj` 61413 lives only in
golden's DEF `uvm_pkg`; our `constant` 6275 lives only in our ELAB `uvm_pkg` and
five `adpcm_*` class bodies, so an ancestor pair must have been DEF-vs-ELAB), and
the 17 keys of D4 are the measured candidate set. Which one the judge reaches
first is still unproven.

---

## 4. BREAKING THE LAW — SIX NEW ARMS, THREE OF THEM MOVE IN THE PARSE VIEW

`armsv210.sh` + `arms210v/`, same recipe as the pass's grid
(`-parse -d coveruhdm -nobuiltin -nocache`, then again with `-elabuhdm`), one
REAL Surelog golden per arm-view, every rc recorded, scored on the pass's own
`ct210own --key` **and** on the typespec-`Instance` multiset the pass's grid
never scored. `ARMS.r10v210.txt`: **16 arm-views, 0 nonzero rcs.**

| arm | shape the pass's grid never built | parse | elab |
|---|---|---|---|
| `v210_1_localparam` | a package **LOCALPARAM** chain and a parameter defaulting to a localparam | 0 / 0 | 4 / 4 (R1's shape) |
| `v210_2_iface` | an **INTERFACE** listing (`AllInterfaces`, keyed by the census, never built by the grid) | **0 / 0** | **0 / 0** |
| `v210_3_modchain` | a module's **own** parameter chain, no import | **0 / 0** | **0 / 0** |
| `v210_4_clsparam` | parameter defaults inside a package **CLASS body** | **1 / 1** | 3 / 3 |
| `v210_5_crosspkg` | a **BARE (unqualified)** cross-package reference through a wildcard import | **2 / 2** | 2 / 2 |
| `v210_7_muststay` | a wider must-stay-folded control: `int'(3.7)`, `signed -7`, `{3{2'b01}}`, `$bits`, `$clog2`, string concat | **5 / 5** | 5 / 5 |

Three parse-view divergences, none of them a regression (no code changed) and
none of them in the corpus, but all three outside the pass's stated conclusion
that "in the PARSE view … only qualified enum-constant defaults move":

* **`v210_5` — we UNFOLD where golden FOLDS, the inverse of the briefed law.**
  In the importing package's DEF listing, for `parameter B_BAREPARM = A_LIT;`
  where `A_LIT` comes from another package through `import v5a::*;`:
  golden `RHS=constant UINT:9`; ours
  `RHS=ref_obj name=v5a::A_LIT full=v5b::v5a::A_LIT ACTUAL=parameter@5:13-5:18`.
  We keep a symbolic reference *and* name it with a qualified `v5a::A_LIT` the
  source never wrote (the source wrote a bare `A_LIT`). `ref_obj::Compare` reads
  `VpiName`, so the name is part of the cell.
* **`v210_4` — a def-view ACTUAL divergence inside a class body.** For
  `parameter C_PKGREF = P_LIT;` in a package class, golden keeps the `ref_obj`
  **UNBOUND** (`REF|NULL`) where we bind it to a `constant`. The pass's arm E is
  cited as proof that "we already reproduce BOTH def-view `vpiActual` bindings";
  in a class body we do not.
* **`v210_7` — the must-stay control fails in both directions.**
  `parameter S_CAST = int'(3.7);` — golden keeps an `operation` (opType 67) in
  the importing module's DEF listing, in the elaborated module and in the
  elaborated package; **we fold all three to `constant UINT:4`** (our DEF package
  keeps the operation, so we invert golden's fold split). `parameter signed
  S_SGN = -7;` — golden **folds** to `constant INT:-7` everywhere; we keep an
  `operation` (unary minus) in the DEF package and DEF module. `{3{2'b01}}` —
  golden keeps an `operation` in the elaborated package; we fold.
  The over-fold direction **does** have corpus population: the census's
  `BlackParrotComplex` cell
  `module_inst|work@top|elab|routing_matrix_p|40:48` is golden `OP` against our
  `CONST`, on a row the judge reads CMP_EQUAL.

`v210_7`'s parse view is also the only small arm in the tree where the
typespec-`Instance` multiset moves: golden mints
`int_typespec||7:13 -> DEFPKG:v7pkg` (×1) and `int_typespec||9:30 -> ELABPKG` (×2)
that we do not mint at all, and golden's `int_typespec||11:13 -> ELABPKG` is ×5
against our ×4. That is the per-view mint-and-`Instance` split R0 has to decide,
in twelve lines of SystemVerilog.

**What none of this changes:** the patch has no production surface, so no arm of
any earlier pass and no corpus row can move. These are pre-existing divergences
that the pass's eight arms did not reach, recorded so the family's closure claim
is scoped honestly: closed **on the corpus**, not law-complete in general.

---

## 5. WHAT IS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ctv210.cpp` | the verifier's own reader. `--painst <db> <pkg> <DEFPKG\|ELABPKG>` prints every `param_assign` cell's Rhs-typespec `Instance` with the VIEW it names (the per-cell measurement the pass summarised); `--tsi <db>` prints every typespec's `Instance` as a joinable multiset key. |
| `armsv210.sh`, `arms210v/` | the adversarial arm grid: 8 arms × 2 views, one REAL Surelog golden each, scored on the FORM key **and** the typespec-`Instance` multiset, every rc recorded. |
| `ARMS.r10v210.txt` | § 4 — the arm grid transcript. |
| `CROSSING.r10v210.txt` | § 3 — the per-cell `Instance` measurement and the 17-key R0 population. |
| `CENSUS.r10v210.txt` | § 1 — the independent corpus census reproduction, both corpora (fenced names redacted by the pass's `scrub210.sh`). |
| `GATES.r10v210.txt` | § 1 — every gate, transcript, on the verifier's own binaries and sweeps. |

---

## 6. RESIDUES THE VERIFIER ADDS

* **V1 — R0 has no arm.** `g210_g_clsty.sv` and two closer attempts all score
  `TSI DISTINCT KEYS 0` on both sides. Before any R0 code, build an arm that
  actually mints an `Instance`-carrying class-body typespec; `v210_7_muststay`
  is the nearest moving shape.
* **V2 — R0's population is 17 keys**, sixteen `REQ`/`RSP`
  `unsupported_typespec` plus `logic_typespec|uvm_pkg::uvm_integral_t|59:9`, and
  the last is a package typedef, so the surface is not only the class-method
  clone family.
* **V3 — the bare cross-package parameter reference** (`v210_5`): we keep a
  `ref_obj`, and name it `v5a::A_LIT` when the source wrote `A_LIT`, where golden
  folds. Corpus population zero, but it is an over-unfold *and* a synthesized
  qualified name in one cell.
* **V4 — the fold split on casts and replications** (`v210_7`): golden keeps
  `int'(…)` and `{n{…}}` as operations in the materialized/elaborated listings
  and folds `signed -7` everywhere; we do the opposite on both. **This one has
  corpus population** — the `BlackParrotComplex` `routing_matrix_p` cell, on a
  CMP_EQUAL row.
* **V5 — the class-body def-view ACTUAL** (`v210_4`): golden leaves the
  `ref_obj` unbound where we bind a `constant`.
* **V6 — `grid210.sh`'s CALIB line is `diff f f`.** Any pass copying that grid
  inherits a control that cannot fail. Fix it before reuse.
