# r10earl46 — ADVERSARIAL VERIFIER REPORT

**VERDICT: PASS, with ONE REQUIRED CORRECTION before landing (F-1).**

Every number the implementer reported reproduced on binaries **I** built from a
**fresh** `c31af36` worktree — including both binary md5s, the Earlgrey database
md5, the 64→46 head byte-for-byte, all 638 census cells, all five gates and every
canary. The structural half of the law (§ genLpFoldSignedStructural46, 638 cells)
is **fully vindicated** and my own probes extended it to five shapes the delivered
arms never measured, all of which it gets right.

The one thing that does not survive is the **second** law's stated text.
§ genLpFoldSignedIntReadsBitsSigned46 says *"the DIGITS are the signed reading of
the bits, whatever the declared signedness."* **Golden refutes that**, and the
patch loses one previously-correct cell to it (F-1). The digits half is still a
net gain (4 wrong → 1 wrong on the probe that isolates it) and has **zero** cells
in Earlgrey and **zero** in both corpora, so it does not threaten a gate — but the
law must not land as written.

---

## 0. WHAT I DID, AND ON WHAT

| | |
|---|---|
| Base | `c31af36`, **fresh** worktrees I created: `/tmp/wt_r10earl46v` (patched), `/tmp/wt_r10earl46vpris` (pristine) |
| Patch | `/tmp/r10earl46.patch`, md5 `0057a0e405dca8d11c5a1b85938d5b9c`, applied with `git apply --verbose` — **clean, no warnings, no fuzz** |
| Build | `cmake --build … -j 2`, absolute paths, both trees, **0** lines matching ` error:` |
| BASE grep-check | all four trees (mine ×2, implementer's ×2) print `c31af3661e42f2b3baa428e7d065023501c080b6` |

```sh
git worktree add --detach /tmp/wt_r10earl46vpris c31af36
git worktree add --detach /tmp/wt_r10earl46v     c31af36
cd /tmp/wt_r10earl46v && git apply --verbose /tmp/r10earl46.patch
cmake -S <tree> -B <tree>/build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
  -DUHDM_DIR=$HOME/.local/lib64/cmake/UHDM -Dslang_DIR=$HOME/.local/lib64/cmake/slang
cmake --build <tree>/build -j 2
```

**The build is bit-reproducible and my binaries are the implementer's binaries.**
md5 asserted separately, 32-hex checked:

```
pristine  0752f5052bbb7c06209747018ddef20d   <- implementer reported 0752f505…  MATCH
patched   f428238f477f364f04f8e563dcd03f12   <- implementer reported f428238f…  MATCH
```

mtimes: binary `06:30:00` > `src/ModuleEmit.cpp` `06:21:05`. No gate here stands on
a stale binary.

**Patch == worktree.** I re-cut the implementer's tree myself
(`git diff c31af36 -- include src tools/probe/r10earl46repro`, staged) and got
md5 `0057a0e405dca8d11c5a1b85938d5b9c` — **byte-identical to the delivered patch**.
The "reproduces the worktree byte-for-byte" claim is true.

---

## 1. THE HEADLINE NUMBERS — ALL REPRODUCED

| claim | implementer | **mine** |
|---|---|---|
| pristine binary md5 | `0752f505…` | **same** |
| patched binary md5 | `f428238f…` | **same** |
| pristine Earlgrey head | 64 lines, == committed `r10earl45repro/r6_nexthead45.cmp` | **64, `diff` EMPTY** |
| patched Earlgrey head | 46 lines, == committed `r6_nexthead46.cmp` | **46, `diff` EMPTY** |
| patched Earlgrey db md5 | `98b93a3e54d7bcb076eadaa7de850267` | **same** |
| CONSTANT golden INT → ours UINT | 489 → 170 | **489 → 170** |
| CONSTANT golden INT → ours INT | 19284 → 19603 | **19284 → 19603** |
| CONSTANT golden UINT → ours INT | 156 → 156 | **156 → 156** |
| PARAMETER golden INT → ours UINT | 392 → 73 | **392 → 73** |
| PARAMETER golden INT → ours INT | 566 → 885 | **566 → 885** |
| PARAMETER golden UINT → ours INT | 0 → 0 | **0 → 0** |
| per-shape movers | 957 ADDED = 957 REMOVED, NET 0, 3 shape families | **957 = 957, NET +0; families `\|INT` 596, `\|UINT` 596, `\|vpiConstType` 3+3 — nothing else** |
| msdist vs golden | 308684 → 307428 | **308684 → 307428** |
| a1 grid | 15 differing → 4 | **15 → 4** |
| b1 grid | 9 → 2 (both instances) | **9 → 2 at `[0]` AND at `[3]`** |
| module-scope controls | `rows=4 differing=0`, `rows=2 differing=0` | **same, on BOTH binaries** |

**The four predicted span populations are exactly the four that moved**, and nothing
else did:

```
CONSTANT  distinct spans 21 -> 17, total cells 489 -> 170
   removed: 64:27-64:41 (255)  60:31-60:48 (25)  61:33-61:42 (25)  104:38-104:52 (14)  = 319
PARAMETER distinct spans 11 -> 7,  total cells 392 -> 73
   removed: 64:22-64:24 (255)  60:22-60:28 (25)  61:22-61:30 (25)  104:33-104:35 (14)  = 319
```

Every **named non-mover** held: the 3 `indexed_part_select.vpiBaseExpr` over-fires
are 3 before and 3 after at the same three spans (`128:32`, `178:32`, `185:32`);
the 156 `golden UINT / ours INT` constants are 156 both times; `PARAMETER golden
UINT / ours INT` is 0 both times; the residual 73 PARAMETER cells are exactly the
7 package spans R1 names.

**The prediction-before-measurement discipline is real.** `CENSUS_PREDICT.txt` is
in the patch, written from the pristine artifact, and it names 638 = 319 + 319 at
four spans. 638 moved. 0 moved the other way.

---

## 2. THE FIVE GATES — RUN INDEPENDENTLY, ALL GREEN

### GATE 1 — BUILD
Absolute paths, `-j 2`, `Linking CXX executable slang-uhdm` present in both logs,
**0** ` error:` lines, md5 asserted separately and 32-hex-checked, BASE printed and
grep-checked on all four trees. ✔

### GATE 2 — GOLDENS
```sh
SLANG_UHDM=/tmp/wt_r10earl46v/build/slang-uhdm     ./tests/check_goldens.sh   # 23/0
SLANG_UHDM=/bin/false                              ./tests/check_goldens.sh   # 0/23
SLANG_UHDM=/tmp/wt_r10earl46vpris/build/slang-uhdm ./tests/check_goldens.sh   # 23/0
```
**23/0 patched, 0/23 negative control, 23/0 pristine.** ✔

### GATE 3 — uhdm2rtlil, both modes, both binaries
`679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in **all four** sweeps.
testflags dump histogram **496 match / 183 differ / 52 blank** on both binaries.
Sorted pat-vs-pris CSV `diff` **EMPTY in both modes**.
`ct8rows.sh results/gate_uhdm2rtlil.csv <fresh testflags>`:
**0 differing ROWS (0 diff row-sides)**, PASS — and the pristine control is 0 too. ✔

> **Scoping note.** The committed `results/gate_uhdm2rtlil.csv` is a **testflags-only**
> 731-row baseline. Feeding it a both-modes CSV makes `ct8rows.sh` report 731
> spurious ADDED rows. That is the harness, not the patch — but a verifier who
> concatenates modes for u2r the way it is correct to do for surelog will see a
> wall of red. The surelog baseline (`golden_surelog.csv`, 1588 rows) **is**
> both-modes. I hit this and corrected it; recorded as R-9 so the next one does not.

### GATE 4 — surelog, both modes, both binaries
```
default    469 CMP_EQUAL  11 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  465 CMP_EQUAL   8 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
```
`469/11` and `465/8`, FAIL 25/23, DEFER 5/5 — required values, met.
`ct8rows.sh results/golden_surelog.csv <fresh both-modes>`: **0 differing ROWS**,
PASS, and **every dump histogram byte-identical to the committed baseline**
(default 325/244/225, testflags 329/300/165). Pristine control also 0. Sorted
pat-vs-pris CSVs `diff` EMPTY in both modes. ✔

**I verified which binary each sweep actually invoked**, not the script's echo:
```sh
find <wdir> -name cmds.txt | xargs grep -oh '/tmp/wt_r10earl46v[a-z]*/build/slang-uhdm' | sort -u
#  uhdm2rtlil_pat -> /tmp/wt_r10earl46v/build/slang-uhdm      (1 distinct)
#  uhdm2rtlil_pris-> /tmp/wt_r10earl46vpris/build/slang-uhdm  (1 distinct)
#  surelog_pat    -> …v/build/slang-uhdm                       (1 distinct)
#  surelog_pris   -> …vpris/build/slang-uhdm                   (1 distinct)
```
`GOLDEN_DEFER` unset throughout; `SLANG_UHDM` exported on every sweep.

### GATE 5 — BYTE VERIFIER, both corpora, both modes
```
uhdm2rtlil   PATH_SETS_IDENTICAL (1358)   MOVERS 4 / 1358   SELFCHECK 1357/1358   SELFCHECK1 5
surelog      PATH_SETS_IDENTICAL ( 953)   MOVERS 2 /  953   SELFCHECK  952/ 953   SELFCHECK1 3
```
u2r matches the report exactly. **surelog does NOT: I get 2 movers, not 1** — see
**F-2**. Both negative controls behave correctly in both corpora
(`SELFCHECK1 == real + 1` in each case). ✔ (gate passes; see F-2 for the caveat)

#### MOVER RULE applied to every mover, by me

| mover | size Δ | verdict | content, direction vs GOLDEN |
|---|---|---|---|
| `Earlgrey_0_1` default | **−1195 B** | REAL by size | 957 lines, 3 shape families; msdist **308684 → 307428** |
| `int_types` default / testflags | **−108 / −110 B** | REAL by size | ADDED 17×`\|INT:-1`; msdist **2208 → 2174** |
| `gen_test4` default / testflags | **0 B** | **ZERO PROVES NOTHING** → control run below | msdist **10 → 6** |
| `Scoreboard` surelog default | **0 B** | **NOT THIS PATCH** — control below | per-shape movement **0 ADDED / 0 REMOVED** |

**`gen_test4` determinism control (mine).** 4 runs of each binary on the real test
source: pristine `49fcd00d2e70` ×4, patched `82cfb77ddc2f` ×4 — both md5s equal to
what the sweep recorded. **Byte-deterministic, so the move is real**, and it is
toward golden. Cell for cell:

```
work@gen_test4.foo[0].PREV   golden INT:-1  pristine INT:-1  patched INT:-1   (unmoved)
work@gen_test4.foo[1].PREV   golden INT:0   pristine UINT:0  patched INT:0    FIXED
work@gen_test4.foo[2].PREV   golden INT:1   pristine UINT:1  patched INT:1    FIXED
work@gen_test4.foo[*].i      golden UINT:n  pristine UINT:n  patched UINT:n   (genvar RESETS — unmoved)
```

**`Scoreboard` determinism control (mine).** 5 runs of the **PRISTINE** binary:
```
79d0a9c77a9f   5d1678fd99c0   5d1678fd99c0   79d0a9c77a9f   52eca89ea740     (all size 11123248)
```
**Three distinct md5s from the unmodified `c31af36` binary alone** — and one of
them, `52eca89ea740`, is precisely the value my *patched* sweep produced. The
"mover" is the documented emitter nondeterminism, not this patch. Confirmed
independently by the per-shape multiset: **0 ADDED, 0 REMOVED**, identical line
counts.

#### Canaries — every one re-run by me
| check | result |
|---|---|
| `canaries.sh` vs committed u2r baseline | `ok=8 changed=0 absent=0`, 25 unknown-names |
| `canaries.sh` vs committed surelog baseline | `ok=52 changed=0 absent=0`, 7 unknown-names |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | `ok=1 changed=0 absent=0 unknown=6` → **PASS** |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | `ok=58 changed=0 absent=0 unknown=1` → **PASS** |
| `canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` → **PASS** |

**Named databases, byte-identical BY NAME** (`cmp` on files that exist, both modes):
`InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch`, `SimpleUVM`,
`SeqDriver`, `BuildUVMPkg` — **all OK-IDENTICAL**.

**Brief-protected genscope canaries, BY NAME**: `gen_test9`, `genvar_loop_decl_2`,
`genvar_loop_decl_3`, `paramod_genscope_child`, `genscope_cells`, `gen_test5`,
`LocalParamInNestedForLoops` — **all OK-IDENTICAL, both modes**.
`gen_test4` — **CHANGED** (see F-5; disclosed, improvement, CSV row unmoved).

---

## 3. THE ARMS AND THE PRIOR PASSES

### Grid, re-run on my binaries — every claim holds cell for cell
The 4 residual a1 rows are **exactly** what was claimed: `vpiSize` 64-vs-32 on
otherwise identical encodings, with the **parameter carrier identical**:
```
A_MOD | INT:41 signed | INT:41 signed || INT:41 ct7 size=64 dec=41 | INT:41 ct7 size=32 dec=41 | DIFF
D_SUB | INT:23 signed | INT:23 signed || INT:23 ct7 size=64 dec=23 | INT:23 ct7 size=32 dec=23 | DIFF
T_UN  | INT:41        | INT:41        || INT:41 ct7 size=64 dec=41 | INT:41 ct7 size=32 dec=41 | DIFF
NEG   | INT:2  signed | INT:2  signed || INT:2  ct7 size=64 dec=2  | INT:2  ct7 size=32 dec=2  | DIFF
```
**Zero encoding cells remain in a1.** b1's 2 are `CONCM` (R2) and `UPLUS` (R3).

**The ternary measurement is the strongest thing in this pass and it holds.** The
SAME two rows flip with the constant condition, on both binaries:
```
b1 [0] golden TERNM UINT:3   TERNU UINT:3      patched UINT:3 / UINT:3   (taken branch = literal 3)
b1 [3] golden TERNM INT:41   TERNU INT:210     patched INT:41 / INT:210  (taken branch = arithmetic)
```
"a ternary resets" fails at `[3]`; "a ternary propagates from either branch" fails
at `[0]`. Only *taken branch* survives. Likewise the pristine over-fires
`IDXMUL`/`ORM`/`FCALL`/`TERNU@0` are all UINT after, matching golden, and the
under-fire `MODREF` is INT after.

### Prior-pass arms — all hold
Path-normalised OURS-dump diff, pristine vs patched, on every arm source in
`r10earl42/43/44/45repro`:

| arm | Δ dump lines |
|---|---|
| `a1_earl42`, `v42_overfire`, `a1_earl43`, `v43_overfire`, `a1_earl44`, `v44_overfire`, `v44x_deconf`, `w45v`, `x45v`, `y45v` | **0** |
| `a1_earl45` | **150 — moves TOWARD golden**, msdist **1713 → 1567**, same 3 shape families (25 constants × 2 + 25 parameters = 75 lines). Not a corpus test; not a gate; a correct extra effect the implementer did not measure. |

**earl45 `y45v` contract**: `ROWS 38 NON-MATCH 4` on **both** binaries. (The
contract in `r10earl45repro/README.verifier.md` quotes 6→7 against *its* pristine;
the landed `c31af36` reads 4 because that pass's F-1 over-fire was fixed at
integration. The contract that matters here — **patched == pristine** — holds.)

> **A trap I walked into and caught.** My first prior-arm sweep reported
> `*** OURS-DUMP CHANGED ***` on **all ten** arms. Two separate instrument bugs:
> (a) the arms never ran (wrong cwd — `arm46.sh` takes a *relative* source and I
> passed absolute; `varm46v.sh` is the absolute-path driver), and `cmp` on two
> **missing** files exits non-zero, which reads **exactly like a mover** — the same
> trap the implementer documented for Scoreboard; (b) once they ran, the dumps
> embed the **workdir path**, so a raw `diff` reported 704 changed lines on
> `a1_earl42` where the true answer is **0**. Both were caught by reading the log
> and the diff instead of the exit status. Neither instrument asserts its inputs
> exist and are comparable.

---

## 4. WHAT I FOUND THAT THE PASS DID NOT — MY OWN PROBES

Two probes, added to this directory: **`v46v_gaps.sv`** (nine shapes the delivered
arms never put on the table) and **`v46v_digits.sv`** (four rows that isolate the
digits rule). Driver `varm46v.sh`, reader `grid46.py`.

```sh
SLANG_UHDM=<bin> tools/probe/r10earl46repro/varm46v.sh \
    $PWD/tools/probe/r10earl46repro/v46v_gaps.sv /tmp/gap
python3 tools/probe/r10earl46repro/grid46.py /tmp/gap/g.dump /tmp/gap/o.dump '[3].'
```

### 4.1 Five shapes the law gets RIGHT that nobody had measured

| row | shape | golden | pristine | patched |
|---|---|---|---|---|
| `NOTB` | `(~(ARR[x] % W)) & 255` — **`~`** over a `%`-fold | UINT | UINT | **UINT ✓** |
| `SHR` | `(ARR[x] * 2) >> 1` | UINT | **INT ✗ over-fire** | **UINT ✓ FIXED** |
| `ASHR` | `(ARR[x] * 2) >>> 1` — arithmetic shift | UINT | **INT ✗ over-fire** | **UINT ✓ FIXED** |
| `ANDL` | `(ARR[x] % W) && 1` | UINT | UINT | **UINT ✓** |
| `PKGREF` | `p46v::PKGMOD + 1` — `+` over a **PACKAGE-scope** param ref | INT | **UINT ✗** | **INT ✓ FIXED** |
| `CHAIN1/2/3` | a **3-deep** `+`-over-REF chain | INT | **UINT ✗ ×3** | **INT ✓ ×3** |

Three points the pass earns but never claimed:
* The in-code comment asserts *"`!` and `~` RESET"* citing b1's `UNOTL`, which is
  `!`. **`~` was never measured.** It is now, and the comment is TRUE.
* `>>` and `>>>` are two **more** pristine over-fires this pass silently fixes.
  b1 measured `<<` only.
* **REF propagation reaches PACKAGE scope**, not just module scope as b1's `MODREF`
  shows, and it survives a 3-deep chain. The `depth > 32` cap is nowhere near.

### 4.2 **F-1 — the DIGITS law as stated is FALSE, and it costs one correct cell**

`v46v_digits.sv` puts two rows side by side with the **same declared type**
(`int unsigned`), the **same 32-bit pattern** `0xC0000000`, and the **same INT tag** —
and golden writes **different digits**:

| row | initializer | value before truncation | GOLDEN | pristine | patched |
|---|---|---|---|---|---|
| `D_POSBIG` | `32'hC0000000 * 1` | **positive** (+3221225472) | `INT:3221225472` | **`INT:3221225472` ✓** | **`INT:-1073741824` ✗ REGRESSED** |
| `D_NEGBIG` | `0 - 32'h40000000` | **negative** (−1073741824) | `INT:-1073741824` | `UINT:3221225472` ✗ | `INT:-1073741824` ✓ FIXED |
| `D_NEGSML` | `0 - 105` | negative | `INT:-105` | `UINT:4294967191` ✗ | `INT:-105` ✓ FIXED |
| `D_NEGONE` | `-1` (the `int_types` shape) | negative | `INT:-1` | `UINT:4294967295` ✗ | `INT:-1` ✓ FIXED |

**Identical bits, identical type, identical tag, different golden digits.** So the
digits are **not** "the signed reading of the bits". The discriminator golden
actually uses is **the sign of the value BEFORE it was truncated to the declared
width** — which is information the code throws away when it reads `cv.integer()`
and calls `setSigned(true)` unconditionally.

* **Net effect: still a win.** On this probe the row goes `differing 4 → 1`. The
  patch fixes three shapes and breaks one.
* **Population: ZERO.** No Earlgrey cell (the 957 moved dump lines contain **no**
  `|vpiDecompile:` shape at all — a digits change would have shown there), and no
  corpus cell (the only movers are the four analysed above, and every `int_types`
  digit change is *toward* golden).
* **It is nonetheless a landed law that golden contradicts**, and it takes a cell
  the unmodified binary got right.

**Required before landing:** either narrow the predicate to the measured rule
(take the signed reading only when the initializer's value is negative *before*
conversion to the declared type — reachable from `ps.getInitializer()` by looking
through the implicit `ConversionExpression` and evaluating the operand), **or**
rewrite the law text to state its true, narrower reach and rank `D_POSBIG` as a
known regression. What must not land is the sentence *"whatever the declared
signedness"* presented as measured — `v46v_digits.sv` is its counterexample.

### 4.3 **F-7 — `negSib9` now has a measured counterexample**

The implementer explicitly declined to claim `negSib9` correct (their R-6). My
probe supplies the cell. `NEGSEL = NEGARR[x]` with `NEGARR[0] = -1`:

```
x=0  golden INT:-1  / INT:-1     ours INT:-1 / INT:-1        (genuinely negative — right)
x=3  golden UINT:105 / UINT:105  ours UINT:105 / INT:105 ✗   (positive sibling of a negative one)
```

**Golden does NOT force INT on the positive members of a gen array that contains a
negative one.** `negSib9`'s sibling scan is an over-fire; the correct rule appears
to be simply *"this instance's value is negative → INT"*, per instance, with no
scan. It also makes our two carriers disagree with each other (constant INT,
parameter UINT). Unchanged by this patch — pristine and patched are identical
here — so it is a **pre-existing** defect this pass merely illuminates. Ranked R-4.

### 4.4 One more pre-existing residue characterised

`CMPM = (ARR[x] % W) > 0`: golden writes the parameter `BIN:0`/`BIN:1` and the
**constant** `BIN:0` at `x=0` but **`INT:-1`** at `x=3`; we write `UINT` on both.
Identical before and after. A comparison fold renders 1-bit BIN — a different law
again. Ranked R-5.

---

## 5. EMPTY-PRODUCT HUNT

I checked every grid row in every saved and re-run grid for cells that "match"
because **neither side emitted anything**.

* **One half-empty product, in every grid, both binaries: the `x` row.**
  `(no param_assign) | (no param_assign)` on both sides — the **constant carrier
  does not exist** for the genvar localparam. The row still carries real evidence
  on the *parameter* carrier (`UINT:n | UINT:n`, both sides populated), so the
  README's use of it to show *"a genvar RESETS"* is **supported**, but only by one
  of the two carriers. Worth stating because `grid46.py` scores `(none)` vs
  `(none)` as `same`, so a row that vanished on both sides would read green.
* **No fully-empty rows anywhere.** Every other row in `a1` (23), `b1` (20),
  `v46v_gaps` (12) and `v46v_digits` (6) has both carriers populated on the golden
  side, and the parameter carrier populated on both sides.
* **`UPLUS` is the inverse case and it is correctly scored:** golden emits **no**
  `VpiValue` on the parameter (`None:None`) while we emit `INT:41`. `grid46.py`
  reports that as `DIFF`, not as a match — the instrument does not treat an absent
  golden field as agreement.
* The census's own empty-key population (141/131 unspanned constants) is disclosed
  by the implementer as instrument noise (their R7); I confirm it is stable
  (156 → 156) and is not load-bearing for any claim.

---

## 6. NUMBERED FINDINGS

**F-1 — `§ genLpFoldSignedIntReadsBitsSigned46` is refuted by golden; one
previously-correct cell regresses. REQUIRED CORRECTION.**
Severity: **must fix or must restate before landing.** Population: 0 Earlgrey, 0
corpus. Detail in §4.2.
```sh
SLANG_UHDM=<pris|pat> tools/probe/r10earl46repro/varm46v.sh \
  $PWD/tools/probe/r10earl46repro/v46v_digits.sv /tmp/dig
python3 tools/probe/r10earl46repro/grid46.py /tmp/dig/g.dump /tmp/dig/o.dump '[3].'
# pristine: rows=6 differing=4     patched: rows=6 differing=1  (D_POSBIG regressed)
```

**F-2 — the surelog byte-verifier line "MOVERS: 1 / 953" is run-dependent; the
honest number is "1 real + 1 nondeterministic".**
My run reports **2 / 953** (`Earlgrey_0_1` + `Scoreboard`). The implementer *did*
disclose Scoreboard's nondeterminism and ran the control, but their GATE-5 table
prints `MOVERS: 1 / 953` with no caveat, so a reader diffing against a re-run sees
an unexplained extra mover. **My own control reproduces their diagnosis and
strengthens it**: 5 pristine runs give 3 distinct md5s, one of which is the value
the patched sweep produced (§2, GATE 5). No action beyond a caveat on the table.
```sh
SELFCHECK=1 SELFCHECK1=1 tools/probe/r10earl46repro/byteverify46.sh <pat root> <pris root>
```

**F-3 — the `int_types` result is reported far below what it actually is.**
README §5.2 says *"all four `genblk*.y` parameters now EXACTLY golden
(`WRONG before=2, after=0`)"*. Measured: there are **33** `work@top.genblk*.y`
parameters; golden writes `INT:-1` on **all 33**; pristine got **17 WRONG**
(`UINT:4294967295` ×2, `UINT:65535`, `UINT:18446744073709551615`, `UINT:255`,
`UINT:1` ×6, `UINT:3` ×6); patched gets **all 33 exactly golden**. "before=2" is
also internally inconsistent with the same row's own "ADDED 17 × `|INT:-1`".
The error understates the pass's own result, but it is an error.
```sh
uhdm-dump <int_types slang.uhdm> | sed 1d | grep -A6 '\\_parameter: (work@top\.genblk[0-9]*\.y)'
```

**F-4 — `census46.py` output row order is NOT reproducible.**
Two runs on **identical** input produce different orderings of equal-count rows
(Python string-hash randomisation). The committed `census46_pristine.txt` /
`census46_patched.txt` therefore **cannot be verified by `diff`** — I could only
confirm the counts, which all matched. Any future census artifact should sort ties
on a stable key (or set `PYTHONHASHSEED`), otherwise the artifact is not evidence
of itself.
```sh
python3 census46.py g.dump o.dump > a.txt; python3 census46.py g.dump o.dump > b.txt; diff a.txt b.txt
```

**F-5 — `gen_test4` is a brief-PROTECTED genscope canary and its DATABASE moved.**
Disclosed by the implementer, and I confirm it is (a) byte-deterministic under both
binaries, (b) a move **toward** golden (msdist 10 → 6, both named cells now exactly
golden), and (c) **CSV-row-identical** to the committed baseline in both modes. It
is an improvement, not a regression — but the brief protects it *by name*, so this
needs the master's explicit acceptance rather than a verifier's.

**F-6 — the collision statement is inaccurate, though the conclusion holds.**
The report says *"r10uvm74 is ExprEmit/StmtEmit — no overlap."* r10uvm74 (`bd4b122`)
**does** touch `src/ModuleEmit.cpp` (+86 lines). Its hunks are at ~4141/~4388;
earl46's are at ~11345/~11829/~11874/~12100. **No overlap in fact** — and I verified
the stronger claim directly: `git apply --check /tmp/r10earl46.patch` on a detached
`bd4b122` worktree **applies cleanly**. `r10sd5` is not yet landed; if it touches
`emitGenScopes`, the three contact points named in the report are correct.

**F-7 — `negSib9` over-fires; measured counterexample supplied.** §4.3. Pre-existing,
unchanged by this patch, now has a cell.

**F-8 — `ExpressionKind::HierarchicalValue` is unhandled and unmeasured.**
`genLpFoldSigned46`'s `NamedValue` case propagates through a parameter ref, but slang
models a *hierarchical* reference (`top.M.P`) as a **separate expression kind**, which
falls to `default: return false` and RESETS. I did **not** measure whether golden
propagates there (constructing the case needs a cross-instance reference in a
gen-scope localparam initializer, which no corpus test exercises). Stated as a known
unmeasured boundary, not as a defect.

**F-9 — `ct8rows.sh` scoping is a foot-gun across the two corpora.** The committed u2r
baseline is testflags-only (731 rows); the surelog baseline is both-modes (1588). §2.

**F-10 — `sweeps46.sh`'s "cmds.txt binary:" echo prints the golden CACHE path.**
Independently confirmed: every one of my eight sweeps printed
`cmds.txt binary: /home/heyfey/.cache/slang-uhdm`. The implementer's self-refutation
(their R-5) is **correct**, and the consequence stands: every earlier README that
quoted that line as proof of which binary a sweep invoked quoted a line that cannot
show it. The real check is the explicit `grep -o` in §2.

---

## 7. RANKED RESIDUES (after this pass)

1. **PACKAGE-scope arithmetic folds — 73 Earlgrey PARAMETER cells, the largest
   remaining population, and the obvious next pass.** 7 spans, confirmed by my own
   census: `flash_phy_pkg.sv:31/34/37/46`, `rstmgr_pkg.sv:11`, `hmac_pkg.sv:18`,
   `flash_ctrl_pkg.sv:21`. `srlgArithFoldSigned` already answers all of them; the
   package parameter's `VpiValue` is written by a path that never asks. Fenced
   territory (§ psBoundPkgParamTs31) — correctly untouched here. **My `PKGREF` row
   (§4.1) shows the *reading* side of package params is now right, which makes the
   writing side the only thing left.**
2. **F-1's digits rule** — 0 cells today, but a landed law contradicted by golden and
   one correct cell lost. Smallest fix on this list; see §4.2.
3. **`vpiSize` 64-vs-32 on the gen-scope fold constant** — 0 Earlgrey cells, 20 arm
   cells (`A_MOD`, `D_SUB`, `T_UN`, `NEG` × 5 instances). Confirmed: `E_SUB2`,
   `H_GMOD`, `I_KMOD` are 32 on both sides, so it is **not** "every INT fold is 64".
   Discriminator not found; correctly not guessed.
4. **`negSib9` over-fires (F-7)** — 0 Earlgrey cells, 5 arm cells, now with a golden
   counterexample and a proposed correct rule ("negative *this* instance → INT").
5. **Comparison folds render 1-bit BIN, and the constant can be `INT:-1`** — 0
   Earlgrey cells, 10 arm cells (`CMPM`). New, characterised here.
6. **CONCAT fold renders BIN at the concat width** — 5 arm cells (`CONCM`).
7. **`+(expr)`: golden omits the parameter's `VpiValue` entirely** — 5 arm cells
   (`UPLUS`), plus the size-64 axis on the same row.
8. **3 `indexed_part_select.vpiBaseExpr` over-fires** — 3 Earlgrey cells, 3 before
   and 3 after at `128:32`, `178:32`, `185:32`. Must not grow.
9. **6 module-port localparam constants** — ParamEmit's carrier, unmoved by design.
10. **Instrument debt**: `census46.py` row-order (F-4); `census46.py`/`shapes46.sh`
    do not assert their input's line count against the producer's (the implementer's
    R10 — a partial dump reads exactly like a result, and `earl46.sh` already prints
    the number that would catch it); `cmp`-based ad-hoc canary loops read two
    **missing** files as a mover (I hit this myself, §3); arm dumps embed the workdir
    path so cross-workdir `diff` needs normalising (§3).
11. **The next head, `prim_keccak.sv:65:61`** — golden substitutes the folded
    `ShiftAmt` into the `indexed_part_select` width where we keep a `ref_obj`.
    Witness `r6_nexthead46.cmp`, reproduced byte-for-byte. § genLpConst SHARE.

---

## 8. REFUTATIONS — CHECKED, NOT TAKEN ON TRUST

| the implementer's claim | my finding |
|---|---|
| "`%` is the discriminator" — true but 50 of 638 | **CONFIRMED.** The four moving spans are 255 + 25 + 25 + 14; the `+`-over-REF shape (`Pa = Base0 + offset`) is 269 of the 319 constants. |
| "declared type is irrelevant — REFUTED, FLAT" | **CONFIRMED**, and strengthened: `e.type` appears nowhere in `genLpFoldSigned46`; 7 declared types + untyped give one answer; `prim_arbiter_tree` declares `int unsigned` with golden INT. |
| "the carrier is `emitGenScopes`, not ParamEmit / elab select-fold" | **CONFIRMED** by the module-scope controls: `rows=4 differing=0` and `rows=2 differing=0` on **both** binaries. Had the carrier been ParamEmit those four rows would have moved. |
| "visitor + `%` + `-` would have been wrong" | **CONFIRMED and extended.** b1 shows 3 pristine over-fires; my probe adds **2 more** (`>>`, `>>>`). Widening the visitor would have widened all five. |
| "`sweeps46.sh`'s cmds.txt echo prints the golden cache path" | **CONFIRMED** on all 8 of my sweeps. |
| "both carriers always agree" — retracted for digits | **The retraction is right, and incomplete.** `NEGSEL` (§4.3) is a second, *pre-existing* carrier disagreement the arms could not show. |
| "`negSib9` is NOT claimed correct" | **Honest, and now measurable** — F-7 supplies the counterexample they left open. |
| "STATED GATE == CODE GATE" | **TRUE for the structural law** — I read every case; each clause is one `case`, the type is never consulted, and both call sites pass the same expression to the one function. **FALSE for the digits law**: the code does what the sentence says, but the sentence is not what golden does (F-1). |

---

## 9. DELIVERABLES

* `tools/probe/r10earl46repro/README.verifier.md` — this report.
* `tools/probe/r10earl46repro/v46v_gaps.sv` — 9-shape verifier probe (`~`, `>>`,
  `>>>`, `&&`, package-REF, 3-deep REF chain, negative-sibling select, MSB-set
  product, comparison).
* `tools/probe/r10earl46repro/v46v_digits.sv` — the 4-row probe that refutes
  § genLpFoldSignedIntReadsBitsSigned46. **This is the regression test the F-1 fix
  must pass: `rows=6 differing=4` on the pristine binary and `1` on the patched one;
  a correct fix returns it to `0`**, with `D_NEGBIG`/`D_NEGSML`/`D_NEGONE` still at
  `INT:-…` and `D_POSBIG` back to `INT:3221225472`.
* `/tmp/r10earl46.verified.patch` — the implementer's patch **plus** the three files
  above. Production code (`include/UhdmExporter.h`, `src/ModuleEmit.cpp`) is
  **byte-identical** to the delivered patch; I changed no production line.

`results/*.csv` were read only. `slang` was not patched. `GOLDEN_DEFER` unset
throughout. My sweep workdirs (`/tmp/r10earl46v/wd`, the golden workdirs, the
determinism scratch dirs and the 238 MB Earlgrey dumps) are **deleted**; the two
verifier worktrees `/tmp/wt_r10earl46v` and `/tmp/wt_r10earl46vpris` and the small
arm/probe workdirs remain with their built binaries.
