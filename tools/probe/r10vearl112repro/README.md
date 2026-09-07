# r10vearl112 — ADVERSARIAL VERIFICATION of r10earl112

**VERDICT: ACCEPT-WITH-FIX.** The pass's law, decode and every headline number
reproduce bit-for-bit. The gate as submitted had **one missing fence** and it
cost **five measured pristine-right → patched-wrong cells on legal SV**, in both
views, in the one place two of this law's own neighbours already fence: a
generate index inside an assignment-pattern member value that is a **USER
subroutine call's argument**. The fix is one test; it is landed here as
§ `patCaGenIdxNeverInUserCallArg112v`. Ship `/tmp/r10earl112.verified.patch`.

MEASUREMENT ONLY. The official `uhdm-cmp` is the sole acceptance judge. LHS is
always golden.

---

## 1. Reproduction, bit for bit

Fresh worktrees at 7e06ae0c (`/tmp/wt_v112pris` pristine, `/tmp/wt_v112`
patched), both configured and built independently, `-j 2`.

| | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `783d8623136cecc3099bdfb052a83c08` | **same** |
| patched binary md5 | `39717fd1ff3fc5377292befa29419dc4` | **same** |
| patch applies on fresh 7e06ae0c | `git apply -3`, 0 conflict markers | **same** |
| surface | `src/ExprEmit.cpp`, `include/UhdmExporter.h`, `tools/probe/r10earl112repro/` | **same**, 49 files, nothing else |
| fence check (four slang-fenced names) | 0 | **0 outside `canaudit.sh`'s own `FENCED=`** |
| goldens | 23 PASS / 0 FAIL both binaries; `/bin/false` 0/23 | **same** |
| u2r testflags + default | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, both binaries, both modes | **same** |
| u2r `ct8rows` vs committed baseline **and** vs own pristine | PASS | **PASS ×3** |
| surelog 1588 rows | identical histograms, `ct8rows` PASS both ways, **no row converted** | **same** |
| byteverify u2r | 0 / 1358 | **0 / 1358** |
| byteverify surelog | 3 / 956 | **2 / 956** — the same two Earlgrey rows with the same md5s (`706635f304bb` default, `1b68458e9d40` testflags); the implementer's third was Scoreboard/default, RESUME §9's documented ~50/50 coin, which did not flip in either of my runs |
| heads | Earlgrey/testflags 364 lines / 1 head before and after; Earlgrey/default 31 / 1 | **same, all seven named rows measured** |
| head object | `hier_path` VpiName `tl_h_i[i].a_valid` → `tl_h_i[0].a_valid` = golden's | **confirmed by direct cmp-log diff**; the remaining fields on the same object are `vpiSize:1` (golden gives none) and the `ref_typespec`→`array_typespec` golden carries — exactly the pass's R0 and R1 |
| corpus census | surelog HPN SHAPE **TO-GOLDEN 18 / AWAY 0 / MOVED-WRONG 0**, u2r all 0 | **Earlgrey/default 9 + Earlgrey/testflags 9 = 18, AWAY 0, MOVED-WRONG 0, ONE-SIDED-CHANGED 0**, and byteverify proves those are the ONLY two databases in 2314 that changed at all, so the corpus-wide claim follows from the two |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS ×2, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, other three unchanged | **same, both binaries** |

Every `cmds.txt` in all six sweep workdirs was audited **by binary PATH**: one
distinct frozen path per workdir, `git-repos/slang-uhdm/build/slang-uhdm`
(the main-tree default the harness silently falls back to) appears **zero**
times. Binaries were `chmod 555` frozen before any sweep.

---

## 2. THE BREAK — § `patCaGenIdxNeverInUserCallArg112v`

**A pattern's `Reduce::Yes` does not reach through a USER subroutine call's
argument list.** `CompileHelper::compileTfCallArguments` (Surelog
`CompileHelper.cpp:4340`) compiles every argument with `pexpr = call`, and the
identifier arm under a non-null `pexpr` binds through `bindVariable` and never
reaches the `getValue` substitution that mints the constant. That is the same
mechanism § `genLpBitSelIdxOneHopFold67` and § `connBitSelIdxModParamFold81`
already fence on with `callArgDepth - sysCallArgDepth22 == 0`, and that
r10earl112's gate did not carry.

Measured on golden, arms `v1_call112` / `v6_call2112`, **both views**, all three
unrollings, every cell a pattern member value of a gen-scope continuous assign:

| pattern member value | golden | pristine | as submitted | fixed |
|---|---|---|---|---|
| `f8(tl_h_i[i].a_data)` | SPELLED | right | **WRONG (AWAY)** | right |
| `f8(f8(tl_h_i[i].a_data))` | SPELLED | right | **WRONG (AWAY)** | right |
| `f8($unsigned(tl_h_i[i].a_data))` | SPELLED | right | **WRONG (AWAY)** | right |
| `$unsigned(f8(tl_h_i[i].a_data))` | SPELLED | right | **WRONG (AWAY)** | right |
| `f8(tl_h_i[i].a_data \| 8'h1)` | SPELLED | right | **WRONG (AWAY)** | right |
| `$unsigned(tl_h_i[i].a_data)` | VALUED | wrong | right | right |
| `$unsigned($signed(tl_h_i[i].a_data))` | VALUED | wrong | right | right |
| `8'(tl_h_i[i].a_data)` (cast) | VALUED | wrong | right | right |
| `tl_h_i[i].a_valid ? … : …` | VALUED | wrong | right | right |
| the same user call OUTSIDE a pattern | SPELLED | right | right | right |

The arithmetic gets every nesting right on its own: user-in-user 2−0,
system-in-user 2−1 and user-in-system 2−1 all abstain; system-in-system 2−2
folds; a bare system call 1−1 folds. The fix is exactly

```cpp
if (callArgDepth - sysCallArgDepth22 != 0)
    return nullptr;
```

placed as fence (f) at the top of `patCaGenIdxFold112`, with the decode and this
grid in the comment beside it.

**Cost of the fix on the corpus: ZERO.** The fixed binary's databases are
**byte-identical to the as-submitted patched binary's** over the whole surelog
corpus (0 / 956) and the whole u2r corpus (0 / 1358). The five cells have
corpus population zero; the fence is a floor, not a trade.

---

## 3. The rest of the break attempt — what did NOT move

Eight arms, 2 views each, scored as a depth-keyed identity census
(`cen112` + `cells.py`, payload compare-visible, span in the key only):

* **v3 / v4, ONE vs THREE INSTANCES** — the same child carrying the head shape,
  instantiated once and three times with different parameters. Golden's index
  multiset over all instances is `{0:3, 1:3, 2:2, 3:1}` (u1 `M=2`, u2 `M=3`,
  u3 `M=4`); ours is exactly `{0:6, 1:6, 2:4, 3:2}` — the same SET, two arena
  copies per elaborated object. **The per-instance and per-copy value is right
  for every copy**; nothing collapses onto one value, so the law does not read
  a stale `currentScope` or a def-view parameter. AWAY 0.
* **v5, the MUST-STAY floor** — earl110's exact corpus shape in a plain
  cont_assign is **byte-identical** across the patch (its census cell scores
  SAME, golden's set unchanged); so are a genvar part-select bound, a bit-select
  on the member, a genvar-free pattern, a gen-if body and a gen-case body.
  TO-GOLDEN 8, AWAY 0, MOVED-WRONG 0.
* **v7, INTERFACE ARRAYS** — `ifs[i].a_valid` inside a pattern: golden folds,
  we do not, **unchanged** by the patch. A residue, not a regression (the
  interface path is built elsewhere). AWAY 0.
* **v2, gen_scope_array / 2-D arrays / outer genvar at depth 2 / variable index**
  — a bare OUTER genvar read in an inner generate body folds correctly at depth
  2 (earl112's own g3 only measured `j+k` arithmetic there); a VARIABLE index
  is correctly left alone; `gen_a[i].w` is untouched (residue). The three 2-D
  `tl2[i][0]` cells score MOVED-WRONG **only because golden's payload set at
  that span also contains its DEF-view copy while ours sits at a shorter span
  with two path elements instead of three** — a pre-existing span/shape residue
  for 2-D unpacked arrays, identical on both binaries (`ONE-SIDED-CHANGED 0`).
  Every one of our three ELAB objects moved onto golden's; none moved away.
* **v8, the pattern kinds the guard does not cover** — a top-level REPLICATED
  assignment pattern (`'{4{tl_h_i[i].a_data}}`) is a residue: golden folds, we
  do not, unchanged. A replication NESTED inside a structured pattern DOES fold
  (the outer guard is already on) and lands on golden.
* **earl112's own four arms, re-run against the FIXED binary** — HPN SHAPE
  TO-GOLDEN **54**, AWAY **0**, MOVED-WRONG **0**; HPR **0/0/0**;
  `ONE-SIDED-CHANGED 0` in all sixteen rows. Identical to the implementer's
  committed GRID, so the fix costs the law nothing.

**Wide boundary**, fixed vs pristine, every `.sv`/`.v` under `tools/probe` at
any depth (LISTED 4977 = the 4973 committed at 7e06ae0c plus this pass's 4 arms,
`FENCED_REMOVED=0`, `PROCESSED==LISTED`), both views, workdir-normalised
whole-dump byte compare:

    PROCESSED=4977 identical=9566 DIFFERING=8 no_output=380
    rc by side, symmetric in every bucket: A/0 9185 A/3 364 A/4 389 A/139 16 = B/…

The ONLY eight differing cells are **this pass's own four arms × two views** —
which is simultaneously the positive control proving the instrument can see a
move. **No arm of any earlier pass moves.**

Two more boundaries over the eight verifier arms, same instrument:

* fixed vs pristine → `DIFFERING=14` of 16 (only `v7_iface112` is unmoved) —
  the law's reach on this arm set;
* **fixed vs AS SUBMITTED → `DIFFERING=4`: `v1_call112` and `v6_call2112`,
  both views, and nothing else.** The fix touches exactly the two
  user-call-argument arms.

**Whole-database attribution of the two Earlgrey movers** (`kinds112` over
`Serializer::AllObjects`, so unreachable arena objects are counted too): the
only kind whose count moves is `constant` **+261 in BOTH modes** (= 9 pattern
members × 29 elaborated instances), plus `ref_obj` **−522** in testflags (the
dropped references' arena copies). `kinds112 --names` says the only names that
move are the nine `tl_h_i[i].<member>` families, **88 copies → 39 + 39 + 9 + 1**,
where the surviving `[i]` copy is the DEF-view object golden also spells — so
the per-instance values differ per copy and the DEF view is untouched. Nothing
else in either database changes kind or name.

The **sectioned, path-normalised, ORDER-BLIND whole-dump diff** of
Earlgrey/testflags (360 MB per side) closes the attribution: 12191 order-blind
lines, **all of them in ONE ELAB section (`sec=10`)** — the DEF section and the
weaklyReferenced TAIL are untouched — and the complete list of changed line
shapes on BOTH sides is nothing but this law's own:
`bit_select (tl_h_i[i])` → `(tl_h_i[N])`, `ref_obj`/`parameter … .i` →
`constant` + `UINT:N`/`vpiSize`/`vpiDecompile`/`vpiConstType`, and the nine
`hier_path (tl_h_i[i].<member>)` → `(tl_h_i[N].<member>)` names. **No foreign
shape appears anywhere in the diff.**

---

## 4. Residues this verification names (ranked)

1. **R-v1 — a USER-call argument inside a pattern now abstains, and golden
   agrees.** Closed by the fix; recorded because the cell is a *miss for the
   next law* only if golden ever folds it, and it does not.
2. **R-v2 — a top-level REPLICATED assignment pattern** (`'{N{path}}`) and the
   FLATTENED pattern path (§ `patFlatDidOrder27` returns before the guard is
   constructed) are the two pattern shapes the guard never arms. Golden folds
   the replicated one. Corpus population zero in both corpora (byteverify).
3. **R-v3 — `gen_a[i].w`, a gen_scope_array index inside a pattern.** Golden
   folds; a different builder composes that name, so this law cannot reach it.
4. **R-v4 — interface-array elements inside a pattern.** Golden folds; same
   reason. Relevant because the interface cluster is 21% of the DIFF corpus.
5. **R-v5 — the 2-D unpacked-array DEF-view hier_path** carries two path
   elements at a shorter span where golden carries three at the full span.
   Pre-existing, both binaries, unrelated to this law.
6. The pass's own R0 (`expr::VpiSize` on the head object) and R1
   (`expr::Typespec`) are **confirmed by direct cmp-log reading**: our head
   object now differs from golden's only in `vpiSize:1` and the missing
   `ref_typespec` → `array_typespec`.

---

## 5. Files

* arms `v1_call112.sv` (user/system call args, concat, ternary),
  `v2_hier112.sv` (gen_scope_array, 2-D, outer genvar at depth 2, variable
  index, LHS), `v3_inst112.sv` / `v4_one112.sv` (three instances vs one),
  `v5_floor112.sv` (the must-stay floor incl. earl110's pair),
  `v6_call2112.sv` (call nesting and cast), `v7_iface112.sv` (interface array),
  `v8_repl112.sv` (replicated / flattened patterns), `TOPS.txt`;
* `grid112.sh`, `cen112.cpp`, `cen112.py` (copied verbatim from the pass, so the
  arms are scored by the pass's own instrument), `cells.py` (the per-cell
  verdict printer this verification reads).

Run: build `cen112`, then
`PATCHED_BIN=<bin> PRISTINE_BIN=<bin> CEN_BIN=<cen112> ARM_DIR=. bash grid112.sh <outdir> v?_*112.sv`,
then `python3 cells.py <d>/cen.gold.txt <d>/cen.pris.txt <d>/cen.patch.txt` per
arm/view directory.
