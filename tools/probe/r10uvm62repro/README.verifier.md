# r10uvm62 — ADVERSARIAL VERIFIER REPORT

## VERDICT: **PASS**, with two findings that do not block landing

Every number in the implementer's write-up reproduced on binaries **I** built
from `/tmp/r10uvm62.patch` applied to a **fresh** 75bfb7e worktree. The head is
genuinely **CLEARED on all three target rows** (20 402 → 14, head object changes
identity, not id). No over-fire and no under-fire anywhere I could reach,
including six shapes the implementer's own grid never contained.

The two findings are: **(F1)** the law as *stated* has a counterexample —
**blackboxing conditions the end label** and the README says "NOTHING ELSE
conditions it"; the underlying defect is **pre-existing, corpus-invisible, and
not introduced by this patch**. **(F2)** their `c3_edge` "13 → 4" is an
instrument-definition artefact, not 4 label bugs — under an owner-keyed census
it is **10 → 2**, and both survivors are the object-existence residues they
already name as R3/R4. Neither changes the verdict.

---

## 0. WHAT I BUILT, AND THE STRONGEST SINGLE RESULT

| binary | worktree | BASE (`git rev-parse HEAD`) | md5 |
|---|---|---|---|
| PRISTINE | `.claude/worktrees/r10uvm62vpris` | `75bfb7e3abe769746b16f1ae9a3082aea5c35bb6` | `5cf09f5121afbb14a66eacfc84bd859b` |
| PATCHED  | `.claude/worktrees/r10uvm62v`     | `75bfb7e3abe769746b16f1ae9a3082aea5c35bb6` | `4cb75fc8f5e3b665538161e9f9db1687` |

**Both md5s reproduce the implementer's reported values bit-for-bit.** That is
the strongest patch-completeness proof available: a patch that were missing a
hunk, carried an uncommitted edit, or depended on anything outside itself could
not land on the same 32-hex digest from an independent `git worktree add` +
`cmake` + `make`. Both are 32-hex; asserted separately from the build; link
line observed (`[100%] Linking CXX executable slang-uhdm`, `Built target
slang_uhdm`, 0 `error:`).

```
git worktree add --detach .claude/worktrees/r10uvm62v 75bfb7e
git -C .../r10uvm62v apply --check /tmp/r10uvm62.patch     # CLEAN
git -C .../r10uvm62v apply        /tmp/r10uvm62.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++
cmake --build build -j 4
```

`md5sum /tmp/r10uvm62.patch` → `8af71f47b4bb7a80a88f5f048019f7f7` (matches).

---

## 1. THE COMPARATOR REFUTATION — INDEPENDENTLY CONFIRMED

This was the load-bearing claim of the pass, and it holds. I extracted **only
the `Compare` function bodies** out of `~/git-repos/UHDM/build/generated/src/*.cpp`
(brace-balanced awk, 4 087 lines) and grepped inside them:

```
Compare methods                                      : 233
VpiParent      reads inside Compare bodies           :   0
VpiFile/VpiLineNo/VpiColumnNo/…  inside Compare      :   0
VpiEndLabel    reads inside Compare bodies           :   8
   -> class_defn interface_inst module_inst named_begin
      named_event named_fork package program
`grep -l vpiEndLabel ~/git-repos/UHDM/model/*.yaml | wc -l`  :   8  (SAME EIGHT)
```

`BaseClass::Compare` (`~/git-repos/UHDM/templates/BaseClass.cpp:163`) compares
`VpiType`, `VpiName`, `VpiDefName` and returns. `class_defn::Compare` is exactly
the sequence claimed, with **`VpiEndLabel` last**
(`.../generated/src/class_defn.cpp:141`).

**The brief's clue list is refuted, mechanically.** "`vpiParent: work@env`
differences (cmp-VISIBLE — the likely failing pair)" is *not* cmp-visible; nor
is the campaign's standing note that "only PARENT-family fields can be the
failing pair". Parents are as invisible to `uhdm-cmp` as spans and file paths.
This is a durable campaign correction and the implementer earned it.

---

## 2. THE HEAD — CLEARED ON ALL THREE TARGET ROWS

`rowheads.sh` on **my** workdirs, both binaries. LHS golden, RHS ours; one head
each (`grep -c '^LHS:'` = 1).

| TEST | MODE | PRISTINE | PATCHED | head object PRIS → PAT |
|---|---|---|---|---|
| SimpleUVM | default | **20402** | **14** | `class_defn (uvm_pkg::uvm_set_get_dap_base) id:129` → `integer_typespec @312:48` |
| SimpleUVM | testflags | **20402** | **14** | same |
| Scoreboard | default | **20402** | **14** | same |
| Scoreboard | testflags | SKIP-NOFILE | SKIP-NOFILE | SLANG_REJECT — reported, not hidden |
| SeqDriver | default/testflags | 85 | 85 | `class_typespec (adpcm_pkg::type_id)` — **byte-identical modulo ids** |
| BuildUVMPkg | default/testflags | 58 | 58 | `ref_obj (…uvm_deferred_init)` — **byte-identical modulo ids** |

The pristine head object is *exactly* the briefed one. The patched head is a
**different object**, so this is a clearance, not a renumbering. The full
14-line head reads: golden `integer_typespec @312:48 |vpiSigned:1`, ours the
same typespec with **no** `vpiSigned` — i.e. residue R1, already correctly
characterised.

**Scoreboard ≥3 reps (required — MULTI-STABLE flake):** three fresh runs per
binary, each producing a *different* database hash, all six cmp'd against
golden:

```
pris rep1/2/3  sha 3e47f1893d8b / 5964f6750523 / 74b373659c6d → 20402 lines, 1 head, class_defn
pat  rep1/2/3  sha 496d6b5656ff / da4c65464ea3 / cb35a356bf7e →    14 lines, 1 head, integer_typespec
```

The head result is **invariant under the flake**.

---

## 3. FIVE GATES, RE-RUN INDEPENDENTLY

**GATE 1 — BUILD / determinism.** Absolute paths above; link line waited for;
md5 asserted separately; both 32-hex; both worktrees print the base commit.
`detcheck.sh` SimpleUVM ×3: patched **1 distinct hash, 0 NO_OUTPUT**; pristine
**1 distinct, 0 NO_OUTPUT**.
Scoreboard ×5 per binary: patched **4 distinct** hashes (bytes always
`11133677`), pristine **2 distinct** (bytes always `11133612`). **The flake
reproduces on the PRISTINE binary too — pre-existing, not this patch.**
I then *bounded* the flake, which the implementer did not: four pristine
Scoreboard databases, id-stripped dumps → **2 distinct dump texts but MULTISET
DISTANCE 0 between all pairs.** The flake is a **line-order permutation with
zero content change**, so the multiset mover attribution in gate 5 is
flake-immune. (It also means the byte-level `MOVER` flag on `Scoreboard/default`
is confounded by the flake — but Scoreboard is an *expected* mover, and the
content-level +51 is what carries the claim.)

**GATE 2 — GOLDENS.** `SLANG_UHDM=<patched> ./tests/check_goldens.sh` →
**23 PASS / 0 FAIL, rc=0**. Negative control `SLANG_UHDM=/bin/false` →
**0 PASS / 23 FAIL, rc=1**. `GOLDEN_DEFER` **UNSET** throughout.

**GATE 3 — u2r testflags, `--jobs 2`, own `--out`/`--workdir`.**
`679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`; dump `496 match / 183 differ
/ 52 empty`. Identical on the pristine binary. `ct8rows.sh` vs the committed
`results/gate_uhdm2rtlil.csv` (731 rows, READ ONLY): **0 differing ROWS, 0 diff
row-sides**.

**GATE 4 — surelog both modes, `--jobs 2`.**
default `467 / 13 / 5 DEFERRED / 284 / 25`; testflags `463 / 10 / 5 DEFERRED /
286 / 23` + `3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM`. Dump
histograms `225/242/327` and `165/298/331` — **unchanged**. `ct8rows.sh` vs
committed `results/golden_surelog.csv` (1 588 rows): **0 differing ROWS**.
Both baseline CSVs verified md5-identical at 75bfb7e and at main HEAD, and both
were only ever read.

**GATE 5 — BYTE VERIFIER vs my own pristine 75bfb7e, `SELFCHECK=1 SELFCHECK1=1`.**

```
u2r     : PATH_SETS_IDENTICAL 679 | MOVERS 0/679 | SELFCHECK 678/679 | SELFCHECK1 1
surelog : PATH_SETS_IDENTICAL 953 | MOVERS 7/953 | SELFCHECK 952/953 | SELFCHECK1 8
```

The seven movers are **the same seven tests by name**: `SimpleUVM`,
`Scoreboard`, `SeqDriver`, `BuildUVMPkg` (default) and `SimpleUVM`, `SeqDriver`,
`BuildUVMPkg` (testflags).

**I upgraded "0 movers on u2r" from an observation to a PREDICTION.** The u2r
corpus contains **zero** `endclass :`, **zero** `endprogram :` and **zero**
labelled `join*` (`grep -rEl` over `~/git-repos/uhdm2rtlil/test`, 0 files),
while 63 files carry `endmodule :` — an owner that already worked before the
patch. 0 movers is therefore *entailed*, not merely measured.

---

## 4. MOVERS PER SHAPE — REPRODUCED, THEN RE-DERIVED WITH MY OWN TOOL

Their `mv62.sh` on my workdirs reproduced their table to the digit. Because
`mv62.sh` computes ADDED/REMOVED through `join` with **stderr suppressed and no
`LC_ALL`** (a locale-collation mis-sort would be silent), I recomputed every
figure with an independent Python `Counter` multiset differ:

```
TEST         MODE      | msdist to GOLDEN pris->pat |  ADDED REMOVED | UNATTRIB | delta
SimpleUVM    default   | 144580 -> 144529  IMPROVED |     51       0 |    0     |  51
SimpleUVM    testflags | 144576 -> 144525  IMPROVED |     51       0 |    0     |  51
Scoreboard   default   | 134864 -> 134813  IMPROVED |     51       0 |    0     |  51
SeqDriver    default   | 367784 -> 367728  IMPROVED |     56       0 |    0     |  56
SeqDriver    testflags | 367784 -> 367728  IMPROVED |     56       0 |    0     |  56
BuildUVMPkg  default   |  81273 ->  81221  IMPROVED |     52       0 |    0     |  52
BuildUVMPkg  testflags |  81273 ->  81221  IMPROVED |     52       0 |    0     |  52
```

Identical. `REMOVED 0` and `UNATTRIB 0` everywhere; the distance improvement
**equals** the ADDED count on all seven rows; attribution regex is exact
(`^ *\|vpiEndLabel:`).

**Corpus prediction confirmed from source, before trusting any of it:**
`uvm-1.2/src` carries **50** labelled `endclass`, **0** labelled `endprogram`,
and **exactly 1** labelled join — `uvm_objection.svh:733: join_none : guard`.
50 + 1 = **51**, the SimpleUVM/Scoreboard ADDED count.

### 4.1 The check the multiset CANNOT do — and it passes

A multiset of `|vpiEndLabel:X` lines is **owner-blind**: the right label on the
*wrong* object scores identically. I wrote an owner-keyed census
(`/tmp/v62/elcensus.py` — attributes each label to the nearest enclosing object
by indentation, popping on field lines as well as object lines, with a
zero-objects-parsed hard error) and ran it on the real corpus dumps:

| TEST/MODE | golden labels | PRIS ours | PAT ours | MISSING → | EXTRA |
|---|---|---|---|---|---|
| SimpleUVM/default | 57 | 6 | **57** | 51 → **0** | **0** |
| Scoreboard/default | 55 | 4 | **55** | 51 → **0** | **0** |
| SeqDriver/default | 68 | 12 | **68** | 56 → **0** | **0** |
| BuildUVMPkg/default | 52 | 0 | **52** | 52 → **0** | **0** |

**Right label, right owner, zero over-fire, on ~400 000-object databases.**

---

## 5. THE GRID, RE-MEASURED — AND SIX SHAPES THEY NEVER TESTED

Arms re-run from source with **both** my binaries, def **and** elab view.
Owner-keyed differing cells (my instrument):

| arm | def PRIS → PAT | elab PRIS → PAT | EXTRA after |
|---|---|---|---|
| `c1_endlabel` | 9 → **0** | 13 → **0** | 0 |
| `c2_neighbours` | 2 → **0** | 3 → **0** | 0 |
| `c3_edge` | 10 → **2** | 11 → **2** | 1 (see F2) |

The law is **not view-split** — confirmed independently in elab.

### 5.1 MY OWN GAP PROBE (empty-product-cell hunt)

I built `v_gap.sv` out of shapes **absent from c1/c2/c3**: a labelled
`begin…end : lbl` inside a **function**; a labelled fork nested two deep inside
a labelled begin inside a class task; a labelled fork directly under a module
`initial`; a labelled `begin` inside an **interface** `initial`; an
**elaborated program instance**; and an unlabelled sibling class in the same
scope as a labelled one.

```
def  : PRIS 4 differing cells -> PAT 0    (EXTRA 0)
elab : PRIS 5 differing cells -> PAT 0    (EXTRA 0)
```

**The law generalises correctly to shapes the implementer never probed.** That
is a genuine strengthening of their result.

### 5.2 A structurally empty cell they did not name

`endclass : \esc$cls` / `endinterface : \esc$if` — **Surelog's parser rejects
escaped identifiers as end-block labels** (`[SNT:PA0207] extraneous input '\'`).
The cell cannot be measured because the golden side cannot be produced. It joins
their `endclass : <wrong name>` cell as structurally empty, and should be
recorded as such rather than left looking untested.

---

## 6. FINDINGS

### F1 — the stated law is over-broad: **BLACKBOXING conditions the end label**
*(pre-existing defect; not introduced by this patch; corpus-invisible; does not block landing)*

The README's law says the label is stamped "**NOTHING ELSE conditions it** — not
the enclosing scope, not the qualifier, not nesting, not the view." There is a
counterexample. Command:

```sh
surelog     -bb_mod work@sub_lbl -parse -d uhdm -nobuiltin dut.sv
slang-uhdm  -bb_mod work@sub_lbl        -nobuiltin dut.sv -o ours.uhdm
# dut.sv: module sub_lbl(input a); endmodule : sub_lbl   + a labelled program + top
```

Golden's blackboxed `module_inst work@sub_lbl` def carries **no**
`vpiEndLabel`; ours carries `|vpiEndLabel:sub_lbl` — on **both** the pristine
and the patched binary:

```
golden  : \_module_inst: work@sub_lbl … |vpiParent |vpiFullName |vpiDefName        <- NO label
ours    : \_module_inst: work@sub_lbl … |vpiParent |vpiFullName |vpiDefName |vpiEndLabel:sub_lbl
```

The cause is structural and visible in the source: `ModuleEmit.cpp` stamps the
end label inside the `if (auto syntax = body.getSyntax())` block at **line 593**,
which runs *before* the `if (blackboxedDef(prefix)) return m;` early-return at
**line ~626** — whose own adjacent comment says the blackboxed def "keeps
exactly the header stamped above (**name, def name, parent, file, span**)".
`vpiEndLabel` is **not in that list**, so the code contradicts the comment two
lines below it.

Classification, stated plainly:
* **Not a regression.** Pristine and patched are identical in this cell.
* **Not introduced by this patch.** It belongs to the pre-existing module arm.
* **Corpus-invisible.** The only four corpus tests using `-bb_mod`/`-bb_inst`
  (`tests/BlackBox/*`) contain no labelled `endmodule`/`endprogram` at all;
  their databases are byte-identical between my two binaries (they are not
  among the 7 movers).
* **The patch's new `program` arm is CORRECT here.** With `-bb_mod work@prg_lbl`
  golden keeps the program's label and we now match it exactly. (Surelog does
  not in fact blackbox a program through `-bb_mod` — its `prg_lbl` retains its
  `vpiProcess`; ours does blackbox it. That mismatch is a separate pre-existing
  issue and is *not* about labels.)
* **The risk it flags is real for the future**: the new program arm sits on the
  same side of the same early-return, so it would inherit the same defect the
  day Surelog's blackbox path reaches programs.

**Required correction to the README before it is used as a spec:** the law
should read "…nothing else conditions it **except blackboxing, which drops the
label on the blackboxed definition (see F1) — a rule we do not yet implement**."

### F2 — `c3_edge` "13 → 4" is an instrument artefact, not four label bugs
*(bookkeeping; no impact on the verdict)*

Their `elgrid.sh` reproduces `13 → 4` exactly on my dumps, so the number is
honest under its own definition. But it counts a **NO-OBJECT** cell as a
differing cell, so each object-existence residue contributes **two** rows (the
labelled twin and the bare twin):

```
class_defn  q::IC              GOLDEN NO-OBJECT      OURS LABEL:IC      **DIFF**
class_defn  q::IC_bare         GOLDEN NO-OBJECT      OURS NOLABEL       **DIFF**
class_defn  work@InIface       GOLDEN LABEL:InIface  OURS NO-OBJECT     **DIFF**
class_defn  work@InIface_bare  GOLDEN NOLABEL        OURS NO-OBJECT     **DIFF**
```

Under an owner-keyed *label* census the figure is **10 → 2**. Verified
pre-existing on the pristine binary: `q::IC` class_defn — ours 4 occurrences,
golden **0**, unchanged by the patch; `work@InIface` — golden 2, ours **0**,
unchanged. **Zero of the four is a label bug.** Their R3/R4 characterisation is
correct; only the arithmetic invites misreading.

---

## 7. HYGIENE AND COLLISIONS

* **Patch contents**: `src/UhdmExporter.cpp (+10/−1)`, `src/ModuleEmit.cpp
  (+14)`, `src/StmtEmit.cpp (+13/−3)` and `tools/probe/r10uvm62repro/` only.
  `git diff --name-only 75bfb7e -- src/ include/ …` in my worktree returns
  exactly those three files. No `results/`, no `third_party/`, **slang not
  patched**, 0 added absolute `/home/heyfey` paths, `git diff --check` clean.
* **Marker**: `grep -rn endBlockLabelAllOwners62 include/ src/` → **3 hits, 3
  files**. Confirmed.
* **§ bitsOwnClassPropFold61 (ExprEmit.cpp) and § tfBodyConstArgNoFormalTs60
  (TaskFuncEmit.cpp)**: `git diff 75bfb7e -- src/ExprEmit.cpp
  src/TaskFuncEmit.cpp | wc -l` → **0**. Stronger than "untouched": I ran **all
  ten `r10uvm61repro` arms** (`c1_scope c2_context c3_sibling c4_edge c5_select
  v1_pkgparam v3_nonsub v4_type v6_unit v7_pkgts`) on both binaries — all ten
  produce **BYTE-IDENTICAL** `ours.uhdm`, with identical cmp lines and heads.
  **No collision.**
* **Live r10svs8 / r10earl33**: 0 occurrences of covergroup/coverpoint/generate/
  genvar/gen_scope in the production diff. Those two have since landed on main
  (`595c2e3`, `2c7f693`) touching **`src/ExprEmit.cpp` and `src/TypeEmit.cpp`
  only** — disjoint from this patch's three files. I confirmed
  `git apply --check --3way /tmp/r10uvm62.patch` is **clean against current main
  HEAD `2c7f693`**, not just against 75bfb7e. (The main working tree was left
  untouched — `git status` on `src/` clean afterwards.)
* **The eight owners are complete**: `class_defn` (UhdmExporter.cpp:735, new),
  `program` (ModuleEmit.cpp:620, new), `named_fork` (StmtEmit.cpp:947, new),
  `module_inst` (ModuleEmit.cpp:593), `interface_inst` (ModuleEmit.cpp:22041),
  `package` (ParamEmit.cpp:17024), `named_begin` (StmtEmit.cpp:950),
  `named_event` — no such syntax exists, genuinely empty. 7 handled + 1 empty.
* **The `named_fork` downcast is type-safe.** `nb`'s runtime type is chosen by
  `isFork` at mint time, and the new `if (isFork) ((named_fork*)nb)` is guarded
  by the *same* flag — the cast can never disagree with the mint.
  `BlockStatementSyntax::isKind` was read from
  `slang/build/source/AllSyntax.cpp:4433` and covers **exactly**
  `{ParallelBlockStatement, SequentialBlockStatement}`, so the widened test adds
  precisely the parallel case and nothing else.

**CANARIES** (all on the patched binary, against the committed baselines):
`canaudit.sh` audited=**29**, UNCOVERED=**0**, FENCE-BREACH=**0** (the four
fenced names dispatched by no driver). `ctcan2` u2r `EXPECT_UNKNOWN=6` →
ok=1/changed=0/absent=0 **PASS**; `ctcan2` surelog `EXPECT_UNKNOWN=1` →
ok=58/0/0 **PASS**. `canaries.sh` surelog ok=52/0/0 (unknown-names 7), u2r
ok=8/0/0 (unknown-names 25). **BY NAME**: `InterfaceModPort` and
`BlackParrotComplex` are `CMP_EQUAL` / dump `differ` in **both** modes on
**both** binaries — unmoved.

---

## 8. RANKED RESIDUES (verifier's ordering)

1. **R1 — the new head, and it is one field.** `integer_typespec @312:48`
   (`uvm_recorder.svh:312`, `local static uvm_recorder m_recorders_by_id[integer];`)
   — golden carries `vpiSigned:1`, we do not. Confirmed: it is the
   **associative-array INDEX** typespec and has **no `vpiParent`**; its element
   sibling at `131:17` (`m_ids_by_recorder[uvm_recorder]`, which *does* have a
   parent) carries `vpiSigned:1` on both sides. 14-line head, failing field
   already named. Highest value on all three target rows.
2. **R2 — `named_fork` missing `vpiJoinType`.** Verified by census of definitional
   `named_fork` occurrences in SimpleUVM/default: golden **3** occurrences carry
   `vpiJoinType`, ours **0**; the two distinct objects are
   `uvm_pkg::uvm_objection::m_execute_scheduled_forks::guard` and
   `uvm_pkg::uvm_phase::execute_phase::master_phase_process`. It is the new
   `c2_neighbours` head. One statement away from code this patch already
   touched, but a different field — correctly deferred under ONE-head-per-run.
3. **F1 (new, mine) — blackboxed definitions must DROP the end label.** We keep
   it on `module_inst`; golden drops it. Pre-existing, corpus-invisible, cheap
   to fix (move the label stamp below the `blackboxedDef` early-return, or gate
   it), and it is the counterexample that makes the § law's "nothing else
   conditions it" clause false as written.
4. **R3 / R4 — object existence, both pre-existing.** Interface classes: golden
   emits **no** `class_defn`, we emit one (now labelled — verdict-neutral, the
   containing vector's size already differs). A class declared inside an
   `interface`: golden emits it, we emit nothing.
5. **R5 — the three briefed clues are cmp-invisible.** Proven in §1, not argued.
   Dump fidelity only; worth zero for cmp. **Do not spend a head on them.**
6. **Scoreboard/default multi-stability** — reproduced on the *pristine* binary,
   so pre-existing; now additionally bounded as **content-preserving
   (multiset distance 0)**, i.e. a serialization-ORDER nondeterminism only. Any
   future pass may safely use multiset instruments on this row and must not use
   raw byte identity.

---

## 9. HOUSEKEEPING

Sweep workdirs (`/tmp/v62/wd_u2r_pat`, `wd_u2r_pris`, `wd_sl_pat`, `wd_sl_pris`
— 804 MB) and the arm/dump scratch **deleted**; logs and CSVs kept for audit.
`results/*.csv` read only. `git stash` never used. slang never patched.
`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` never dispatched.
`GOLDEN_DEFER` left UNSET (5 DEFERRED in both surelog modes, as at baseline).
All work confined to `.claude/worktrees/r10uvm62v`, `.claude/worktrees/r10uvm62vpris`
and `/tmp/v62`.
