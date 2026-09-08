# r10v208 — ADVERSARIAL VERIFICATION of r10uvm208 (§ `cloneSharedArrayElemSplitMint208`)

**VERDICT: ACCEPT.** Every headline number reproduced BIT-FOR-BIT from my own
build, my own sweeps and my own instruments. Ten new adversarial arms across
faces the implementer's grid did not cover found **AWAY-GOLDEN 0 and
MOVED-WRONG 0 everywhere**, plus **one additional conversion** the pass did not
claim (`v208_f_io`, the `io_decl` face: 112 cmp lines / 1 head → 0 / 0, both
views). No production change was needed; `/tmp/r10uvm208.verified.patch` is the
implementer's patch **plus this directory** — the production surface is
byte-identical.

MEASUREMENT ONLY. The official `~/git-repos/UHDM/build/bin/uhdm-cmp` and
`scripts/verify_golden.py` are the only judges. slang was NOT patched.
`results/*.csv` were READ ONLY and NOT EDITED. Nothing promoted, NO ROW
CONVERTED. `GOLDEN_DEFER` unset. The four slang-fenced tests were never
dispatched and are named nowhere in this directory.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `f3a3fcf0` (verifier worktrees `/tmp/wt_v208`, `/tmp/wt_v208pris`) |
| pristine binary | md5 `61d817dba1aa2bbe6cdd2be4e165b818` — **identical to the implementer's**, built `-j 2` from my own clean worktree, frozen `chmod 555` before any sweep |
| patched binary | md5 `0cd3924b8afdc086884ece90b4d3d82a` — **identical to the implementer's**; +16576 bytes |
| patch | `/tmp/r10uvm208.patch` md5 `cbf7a253648ab3b4012a1ec243680f4c`, applied clean (`git apply -3`, rc 0) on a FRESH `f3a3fcf0` |
| surface after apply | `src/TypeEmit.cpp` **+272 / −0** and `tools/probe/r10uvm208repro/` ONLY; `src/TypeEmit.cpp` md5 `4a7df5ae1b2658234f16933ff73b7514` = the implementer's worktree, and the whole probe dir `diff -rq` clean against theirs |

## 1. Independent reproduction of every gate

| gate | implementer | **verifier (mine)** |
|---|---|---|
| goldens, pristine / patched | 23 PASS / 0 FAIL | **23 / 0 both** |
| `/bin/false` negative control | 23 FAIL | **23 FAIL** |
| u2r testflags + default, both binaries | 679 / 50 / 2 | **679 / 50 / 2 ×4** |
| `ct8rows` u2r: baseline↔patched, pristine↔patched (tf), pristine↔patched (def) | PASS ×3 | **PASS ×3** |
| `byteverify SELFCHECK=1` u2r | 0 / 1358 | **0 / 1358**, PATH_SETS_IDENTICAL |
| surelog `--mode both`, both binaries | 473/8 + 468/7 | **473/8 + 468/7 on both, byte-identical CSVs** |
| `ct8rows` surelog **pristine ↔ patched** | 1 row (Earlgrey dump col) | **0 differing ROWS over 1588** (cleaner than theirs — see §2) |
| `byteverify SELFCHECK=1` surelog | 4 / 956 | **4 / 956, the same four paths AND the same eight md5 prefixes** |
| `cmds.txt` audit by BINARY PATH | sl 1523, u2r 1458 per binary | **sl 1523 / 1523, u2r 1458 / 1458, 0 naming the main tree or the other binary** |
| `canaries` u2r | ok=8 changed=0 | **ok=8 changed=0** |
| `ctcan2` sl / u2r | PASS ×2 | **PASS ×2** (ok=58/ok=1, changed=0) |
| `canaudit` | audited=29 UNCOVERED=0 FENCE-BREACH=0 | **identical** |
| SVSwitch / YosysVerx pins | `4842211c4030` / `6ccda350c24a` | **HELD, both modes, both binaries** |
| InterfaceModPort / BlackParrotComplex / YosysOldOr | byte-identical | **byte-identical, both modes** |
| corpus census, 12 tests × 2 modes | SeqDriver ×2 + MiniAmiq ×2 TO-GOLDEN 6 / AWAY 0 / MW 0 / SW 0; every other row-mode all-zero | **identical, cell for cell** (AGREE 5275 / 5445, one-sided 1011 / 468, calibration 0 on every row-mode) |
| kind table, MiniAmiq/default | `differ=6 → 0`; `.elem` BARE/BARE 20→26; **home BARE/QUAL 55 unmoved** | **identical** (agree 5445→5451) |
| object half (`ct208obj`) | +6 `array_typespec` +6 `ref_typespec`, nothing else, per moved row | **identical on all four movers**, totals 310179→310191 and 299565→299577 / 299577→299589 |
| a-priori prediction from PRISTINE dbs | 4 row-modes, `shared=6 splits=6`, `uvm_pkg::uvm_reg_addr_t`; 0 / 1358 u2r | **identical — scanned=948 NODB=617 FENCED=8; 0 of 1358 u2r.** Predicted set == measured mover set, no false positive, no miss |
| wide boundary | LISTED 5358, MOVED_ARMS 10, RC_DIFFS 0 | **LISTED 5368 PROCESSED 5368 PRODUCED_DBS 5183 MOVED_ARMS 18 RC_DIFFS 0** — the same 10 by name, plus my own 8 moving arms |

### The head, re-measured

`rowheads.sh` on my own sweeps, both binaries: SeqDriver 112/1 ×2,
SimpleUVM 4177864/4178104 /1, Scoreboard/default 95/1, MiniAmiq 112/1 ×2, and
**BuildUVMPkg ×2, Earlgrey_0_1 ×2, Rggen/default all 0 lines / 0 heads, judge
rc=0**, on BOTH binaries.

MiniAmiq's head OBJECT moves exactly as claimed, in both modes:

```
PRISTINE  \_ref_typespec: (svaunit_pkg::uvm_reg_map::m_set_reg_offset::addrs::uvm_reg_addr_t)
PATCHED   \_ref_typespec: (svaunit_pkg::uvm_reg_map::m_set_mem_offset::range::
                           uvm_pkg::uvm_reg_map_addr_range::min::uvm_reg_addr_t)
```

SeqDriver's head object is unchanged (the class-member kind, `adpcm_pkg::…::min::uvm_reg_addr_t`);
SimpleUVM ×2 and Scoreboard/default cmp output is byte-identical between the
binaries.

The six moved cells (`score208.py --show`, MiniAmiq/default) are all in
`TOP[2] svaunit_pkg`, each `('bit_typespec','uvm_reg_addr_t','uvm_pkg::uvm_reg_addr_t')
→ ('bit_typespec','uvm_reg_addr_t','uvm_reg_addr_t')` = golden's value —
exactly § 205's R1 list.

## 2. The Earlgrey dump-column flake, re-measured — and NO ROW CONVERTED

My **pristine ↔ patched** surelog `ct8rows` reads **0 differing ROWS over 1588**
(status AND dump column). Against the committed baseline BOTH of my sweeps show
the same single cell — `Earlgrey_0_1,testflags` dump column `differ → ` — so the
movement is between the baseline and this machine's run conditions, **not
between the two binaries**. STATUS is `CMP_EQUAL` on every Earlgrey cell on both
binaries, `rowheads` reads 0/0 (judge rc=0) for both Earlgrey modes on both
binaries, and neither Earlgrey database is a byte mover. That independently
confirms the implementer's attribution (their run flipped it on `default` in one
sweep and `testflags` in the other; mine flipped it identically in both).
`canaries.sh` therefore reads **ok=51 changed=1** on BOTH of my surelog sweeps —
the one changed cell is the same in pristine and patched. **earl122's conversion
holds: `Earlgrey_0_1` default and testflags are CMP_EQUAL on both binaries.**

## 3. BREAKING THE LAW — ten new arms, faces the pass's grid does not cover

`grid208.sh` (the pass's own driver), one REAL Surelog golden per arm, BOTH
views, golden-vs-golden calibrated first (0 in every column, every arm, every
view), every rc recorded, every binary path echoed.

| arm | the face it attacks | def | elab |
|---|---|---|---|
| **A** `v208_a_alias` | **the outer/inner aliasing hole.** `outer208` is built only from `variables` and `io_decl`. If a clone declaration's OWN ref were also the `Elem_typespec` ref of a HOME array, the mask would still read 1 and the split would move a home cell. Home declares `bt two[][]` (element type IS `bt[]`) and `foreach`es it; the clone-reached body declares `bt one[]` | TO-GOLDEN 2, **AWAY 0, MW 0**, SW 0 | TO-GOLDEN 4, **AWAY 0, MW 0**, SW 0 |
| **B** `v208_b_assoc` | **the `Index_typespec` face** — an associative array indexed BY the package typedef, the only shape that puts the typedef on the link `splitTs208` also copies | **BYTE-IDENTICAL**, all cells agree | **BYTE-IDENTICAL** |
| **C** `v208_c_packed` | **the `packed_array_typespec` mint branch**, which no committed arm exercises by name, beside a dynamic array of the same typedef | TO-GOLDEN 1, AWAY 0, MW 0, SW 10 (§205 R2, unchanged) | TO-GOLDEN 2, AWAY 0, MW 0, SW 18 |
| **D** `v208_d_chain` | **transitive import** — a clone of a body that is itself already a clone (p→p→p wildcard chain) | TO-GOLDEN 1, AWAY 0, MW 0, SW 0 | TO-GOLDEN 2, AWAY 0, MW 0, SW 0 |
| **E** `v208_e_spec` | **uvm202's face — a parameterized class SPECIALIZATION reached through two importers**, whose method `foreach`es an array of the typedef. Sharing must not split wrongly | TO-GOLDEN 1, AWAY 0, MW 0, SW 0 | TO-GOLDEN 2, AWAY 0, MW 0, SW 0 |
| **F** `v208_f_io` | **the `io_decl` face** — a formal that is an array of the typedef, sharing with a home `foreach` | **112 cmp lines / 1 head → 0 / 0, judge rc=0: CONVERTS** | **112 / 1 → 0 / 0: CONVERTS** |
| **G** `v208_g_twohome` | **two home declarations + one clone + a SECOND typedef alongside** so a wrong element type cannot ride along — the widest corpus shape in miniature | TO-GOLDEN 5, AWAY 0, MW 0, SW 0 | TO-GOLDEN 10, AWAY 0, MW 0, SW 0 |
| **H** `v208_h_deep` | **depth** — the clone's declaration at block depth 3 (nested begin inside for inside begin), the home's sharing reference at depth 0, so a `depth208` mis-count would show as a key collision or an unsplit cell | TO-GOLDEN 2, AWAY 0, MW 0, SW 0 | TO-GOLDEN 3, AWAY 0, MW 0, SW 0 |
| **I** `v208_i_struct` | **the NON-DECLARATION owner** — a struct MEMBER contributes no bit to either mask; does either law then move a cell golden keeps qualified? | TO-GOLDEN 1, AWAY 0, MW 0, SW 0 | TO-GOLDEN 2, AWAY 0, MW 0, SW 0 |
| **J** `v208_j_modimp` | **the module-importer control** — § 194's wildcard gate is PACKAGE-import-only | **BYTE-IDENTICAL** | **BYTE-IDENTICAL** |

**AWAY-GOLDEN 0 and MOVED-WRONG 0 in every arm in every view.** Where an arm's
uhdm-cmp output differs between the binaries (D, E, G, H elab) the diff is
**object-id renumbering only** — the head object and every content line are the
same; where it does not differ, the line count and head are identical.

### Arm F is a conversion the pass did not claim

`v208_f_io` goes 112 cmp lines / 1 head → **0 lines / 0 heads, judge rc=0**, in
BOTH views: a second independent minimised head besides the implementer's
arm E, on the `io_decl` role rather than the block-local `variables` role.

## 4. The guard's other cells, § 205's arms, and the protected families

Re-run through the same driver against real goldens:

* **§ 205's six arms**: `g205_a_kinds`, `g205_b_ctx`, `g205_d_noimport`,
  `g205_e_head`, `g205_f_home` **BYTE-IDENTICAL on both binaries in both
  views** (their STILL-WRONG counts unchanged) — § 205's guard cells STAY.
  `g205_c_share` (§ 205's own reproduction of R1) moves TO-GOLDEN 1 def / 2
  elab, AWAY 0, MW 0, **STILL-WRONG → 0**.
* **§ 208's own arms** re-run: **D** (`g208_d_home`, home only) and **F**
  (`g208_f_explicit`, § 194's explicit-import fence) **BYTE-IDENTICAL**;
  **E** (`g208_e_head`) **112 / 1 → 0 / 0 CONVERTS** in both views; **G**
  (`g208_g_fences`) TO-GOLDEN 1/2 with STILL-WRONG 2/4 (§ 205's R2) unchanged;
  A 7/10, B 1/2, C 1/2 — every number the pass reported.
* `r10v205repro/grid/v205_l_reuse.sv` moves TO-GOLDEN 2 def / 4 elab, AWAY 0,
  MW 0, SW 0.
* **Wide boundary, 5368 arms, PROCESSED=5368, RC_DIFFS=0**: zero movers in
  § 204, § 202, § 198, § 194, § 193, § 190, § 180, § 169, § 16, **earl122** (3
  arms), earl121, uvm82-91 (113 arms), buvm3-15 (119 arms), sd8-12 (347 arms,
  subdirectories included).

### The three static-address false movers, re-proved on all four tells

`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
`r10uvm185repro/grid185/g185_e_kinds.sv`:

1. the OFFICIAL `uhdm-cmp` output against a real Surelog golden is
   **byte-identical** between the two binaries in both views — 17/17, 3438/3438,
   92/92, same head, every line;
2. `ct208obj` per-kind object counts: **0 lines of difference** — the law never
   fired;
3. census TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0 with STILL-WRONG unchanged;
4. each binary deterministic on its own (3 runs, one md5 each).

The single differing thing in the whole dump of each is
`|vpiDecompile:22671097 → 22683385`, delta **12288 = exactly three 4096-byte
pages**, against a binary that grew 16576 bytes.

## 5. Determinism on the corpus law row itself

Three runs of the **patched** binary on MiniAmiq/default's own command line,
from the test's own directory, into the sweep's own output path:
`d53dd9ae065f` ×3 — and that IS the mover hash `byteverify` reports. Three runs
of the **pristine** binary: `f1a5df6e291c` ×3. The mint order does not depend on
allocation addresses on the row that actually splits, not just on a small arm.
(`byteverify` re-run afterwards still reads MOVERS 4 / 956.)

## 6. Where the write-up is looser than the measurement

* README § 4 says the split "changes nothing" in the DEF view because the
  clone's chain is already clone-exclusive there. That is true **of the corpus
  rows** — all 24 moved census cells are in the elaborated importing-package
  listing (`TOP[2]`) — but it is not true of the law: arm E and arm
  `v208_f_io` both CONVERT in the **def**-view database as well. Read § 4's
  sentence as a statement about the corpus, not about the law.
* The pass reports `canaries ok=50 changed=2`; on this machine the same scripts
  read `ok=51 changed=1` on BOTH binaries. The difference is entirely the
  Earlgrey dump-column flake (§ 2), not the patch.

## 7. RANKED RESIDUES (verifier's, beyond the pass's R0–R6)

1. **`copyTsShell208` does not copy `VpiDefName`, and `BaseClass::Compare`
   READS it** (`~/git-repos/UHDM/build/generated/src/BaseClass.cpp:163-186`:
   VpiType, VpiName, VpiDefName). The pass's field table lists `typespec::Compare`
   as VpiName / Typedef_alias / Instance and omits the base class's third field.
   **Latent, not live**: measured with a purpose-built scan
   (`vdefname.cpp`, in this directory) over MiniAmiq/default —
   `arrays=903 with-defname=0` pristine, `909 / 0` patched, `913 / 0` golden;
   and 0 of 476/481/550 `ref_typespec` on the arms. `splitLink208` already
   copies it for the fresh `ref_typespec`; only the fresh array shell does not.
   One line (`dst->VpiDefName(src->VpiDefName())` in `copyTsShell208`) closes it
   before some future law starts setting it. **Not a defect today; do not hold
   the landing for it.**
2. **Both owner masks (`owner205`, `outer208`) see only `variables` and
   `io_decl`.** Arm I shows a struct MEMBER co-owner does no harm on the shapes
   reachable today, but the masks are a whitelist, not a proof. If a future law
   binds these chains from a `typespec_member`, `parameter` or `net`, the
   exclusivity guard silently over-approximates.
3. **The `<ambiguous>` determinism guard appears unreachable in legal SV** — the
   key carries package + class + subroutine + depth + role + `name@file:line:col`
   + kind, and two distinct declarations cannot collide on it within one file.
   It is a correct safety net that no arm can exercise; do not mistake "never
   fired" for "tested".
4. **The `--prof` arity model has a second half nobody has closed**: golden's
   clone listing reads `arr=1 elemref=1` while ours reads `arr=2` even after the
   split (one chain per *listing view*, not per declaration) — the pass's R3,
   confirmed on arm G. Invisible to the judge (no generated `Compare` reads
   `VpiParent`) but it is the reason the object counts will never match golden's.
5. **`score208.py`'s golden-vs-golden calibration compares a file with itself**,
   so it can only catch an asymmetric key/payload extraction, not a systematically
   wrong one. It did its job here (0 in every column on every row-mode and arm),
   but it is weaker than the name suggests.

## 8. HOW TO REPRODUCE THIS VERIFICATION

```bash
git worktree add /tmp/wt_v208     f3a3fcf0 && git -C /tmp/wt_v208 apply -3 /tmp/r10uvm208.patch
git worktree add /tmp/wt_v208pris f3a3fcf0
for w in /tmp/wt_v208pris /tmp/wt_v208; do
  cmake -S $w -B $w/build -DCMAKE_BUILD_TYPE=Release && cmake --build $w/build -j 2; done
cp /tmp/wt_v208pris/build/slang-uhdm /tmp/v208_scratch/pris_61d817db.bin
cp /tmp/wt_v208/build/slang-uhdm     /tmp/v208_scratch/pat_0cd3924b.bin
chmod 555 /tmp/v208_scratch/*.bin          # FREEZE before any sweep

cd tools/probe/r10uvm208repro
g++ -O2 -std=c++17 ct208cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o /tmp/ct208cen        # ct208pred, ct208obj likewise
g++ -O2 -std=c++17 ../r10v208repro/vdefname.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/vdefname

for a in ../r10v208repro/grid/v208_*.sv; do                    # the ten new arms
  CEN=/tmp/ct208cen bash grid208.sh "$a" /tmp/v208_scratch/pris_61d817db.bin \
      /tmp/v208_scratch/pat_0cd3924b.bin /tmp/w_$(basename $a .sv); done
for a in ../r10uvm205repro/grid205/g205_*.sv; do               # § 205's own arms
  CEN=/tmp/ct208cen bash grid208.sh "$a" <PRIS> <PATCHED> /tmp/w205_$(basename $a .sv); done
PRIS=<pris> PATCHED=<patched> bash bound208.sh <copy of tools/probe> /tmp/bound
```

Everything else is the pass's own § 11, run verbatim with my binaries and my
workdirs.
