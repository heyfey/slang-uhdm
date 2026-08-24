# r10v82 — ADVERSARIAL VERIFICATION of r10earl82 (§ rangeBoundStoredWidth82)

**VERDICT: ACCEPT WITH FIX.**  The law is right, the head clears in both modes,
the family closes corpus-wide, and every gate reproduces — but the pass shipped
one cell that PRISTINE got exactly right and the patch got wrong on legal SV.
It is fixed here, in five lines, and the fix costs nothing on either corpus.
Ship `/tmp/r10earl82.verified.patch`.

## 1. What reproduced, bit for bit

Built both binaries myself in fresh worktrees at 29c1576 and got the
implementer's md5s exactly (`6cc73445…` pristine, `69612991…` patched).  Ran
the whole battery on my own frozen binaries and my own workdirs, auditing every
`cmds.txt` by absolute binary path.

* goldens 23/0 in every state, `/bin/false` 0/23;
* u2r 679/50/2 both modes, surelog 471/10 + 466/9 — **0 differing rows** against
  the COMMITTED baselines in every state, whole row including the dump column;
  **no row converted**, `results/*.csv` untouched;
* Earlgrey head **36 lines / 1 head → 58 / 1 in both modes**, and my
  `HEAD_BEFORE_*` / `HEAD_AFTER_*` are byte-identical to the four committed
  ones;
* corpus census **45,264 surelog + 11,656 u2r range-bound keys**, TO-GOLDEN 8 /
  AWAY 0 / MOVED-WRONG 0, SIZE-ONLY keys 8 → **0** — the family IS closed;
* per-directory boundary PROCESSED=1536 identical=2799 DIFFERING=17, the same
  17 rows, and the five self-unstable directories re-proved self-unstable by
  three pristine-only recompiles each.

`GATES_V82.txt`, `CENSUS_V82.txt`, `BOUNDARY_V82.txt` carry the numbers.

## 2. The regression I found, and the fix

`ovActualStoredWidth82` refused any stored width above 64.  The arm it replaced
lent the FORMAL's width, and for a formal wider than 64 bits that answer was
golden's.  `v6_hole82.sv:14` — `w100_v6 #(parameter logic [99:0] LW = 1)` fed
`localparam logic [99:0] WIDE100 = 8` — is golden **sz 100**, pristine **100**,
patched **64**.  The declaration-side half of the very same § lends 100 without
a cap and lands on golden (`v7_edge82.sv:17`), so the cap was not even
self-consistent.

Fix: `if (w <= 0)` instead of `if (w <= 0 || w > 64)`.  Slot score on the eight
adversarial arms goes LOST=1/GAINED=44 → **LOST=0/GAINED=47**, and a byteverify
of the fixed sweep against the pre-fix patched sweep over BOTH corpora reports
one mover — the documented Scoreboard coin.  Full detail and the second cell the
cap also cost: `REGRESSION_V82.txt`.

Also repaired: the patch mangled an UNRELATED comment in
`include/UhdmExporter.h` (§ classTpTsName87's), leaving the line
`/// nullptr otherwise.naming the return typespec would silently ADD …` — a
stray global substitution.  Comment-only, restored.

## 3. What did NOT reproduce (measurements the pass reported wrongly)

1. **Byte movers: 2/956 claimed, 4–5/956 measured**, with binaries whose md5s
   match theirs.  `./default/Scoreboard` is the documented coin — I produced
   BOTH faces from ONE binary in three sequential runs.  `./default/SeqDriver`
   and `./testflags/SeqDriver` move DETERMINISTICALLY (3× stable per binary) and
   are **convicted NOT the law** by the kill switch: `R10E82_OFF=1` reproduces
   the PATCHED bytes, not the pristine ones.  Their dumps are identical up to
   ORDER; unsorted, one pair of weaklyReferenced-TAIL `bit_typespec` entries is
   swapped (352 bytes).  Benign — the tail is unreachable to the judge and both
   rows keep their baseline status and dump column — but real, and unreported.
2. **The committed WIDE boundary is stale.**  PROCESSED=3621 against my 3694:
   it missed all 68 `.v` files and FIVE of the pass's OWN arms
   (`g0_min82`, `g1_ty82`, `g2_cons82`, `g3_shape82`, `g6_earl82`), which its
   own ARMS.txt says change.  Re-run here over everything: DIFFERING=20 (10
   files × 2 views), every one scored against golden, LOST=0 throughout.
3. **The two AFTER head logs are not byte-identical to each other** — they
   differ in four object ids.  The head object and every judged field are the
   same in both modes, so the substance holds; the sentence does not.
4. (Not a discrepancy, recorded so the master does not re-derive it.)  The main
   tree moved to `9e04993b` — UVM pass 119 — while I was verifying.  This patch
   is against the pinned base `29c1576`, where it applies cleanly; pass 119
   touched `src/ExprEmit.cpp` and `include/UhdmExporter.h`, so the header will
   need a rebase hunk.  Nothing measured here depends on it: every gate ran on
   binaries built from 29c1576.

## 4. How I tried to break the law

Eight arms, each a shape the pass's own grid does not contain, every one
compiled by Surelog for golden and by both frozen binaries in BOTH views, scored
slot-by-slot with a NO-SPAN judge-fields payload (`score3.py` span-level 3-way,
`score4.py` slot-level LOST/GAINED, `varm82.sh` the driver, `cenagg.py` the
corpus aggregate).  **LOST=0 on all eight after the fix.**

| arm | what it attacks | slots |
|---|---|---|
| `v1_homes82.sv` | gen-for / gen-if / NESTED gen / interface / program homes, 3 instances, packed range on a var, a net and an unpacked dim | GAINED 19 |
| `v2_chain82.sv` | the override-actual-is-a-NAME chain: based-literal init, >64-bit actual, untyped-with-expression, a THREE-hop chain, a package root | GAINED 3 |
| `v3_net82.sv` | `emitPackedStructArrayNet` — the SECOND patched call site, which the pass's grid never exercises (its "packed-net" column is a plain `logic` vector) | GAINED 3 |
| `v4_cons82.sv` | the consumer axis with an OVERRIDDEN parameter: part-select, indexed part-select, bit-select, case item and case selector, call argument, concat member, replication, High_conn (earl81's must-stay-64), unpacked range- and size-form dims | GAINED 7 |
| `v5_inst82.sv` | 1..3 instances mixing an overridden and a DEFAULT instance, bound in body / gen-for / gen-if / nested gen (the we24 2×2) | GAINED 6 |
| `v6_hole82.sv` | THE FENCE HOLES — every shape where the old lambda lent the FORMAL's width and the new law abstains, with the formal deliberately given the actual's width.  **This is the arm that found the regression.** | LOST 1 → 0, GAINED 3 |
| `v7_edge82.sv` | declaration-side encoder edges: a NEGATIVE package parameter, a >64-bit one, a signed one, value 0, on a net and on a var | GAINED 3 |
| `v8_more82.sv` | untyped-with-BASED initialiser, a NINE-hop chain past the depth guard, a package expression parameter into a narrow formal, `integer`, a package parameter naming another | GAINED 3 |

Refuted along the way: that the depth-8 guard is reachable in a way that hurts
(a nine-hop chain abstains in BOTH binaries), that the declaration-side encoder
mis-renders a negative or zero-valued package parameter (both move toward
golden), and that the interface/program/gen homes behave differently from the
module body (they do not — the law is a consumer law, not a home law).

## 5. Residues, ranked (measured here)

* **R1 (the pass's own R1, confirmed and now slightly worse on one field).**
  A BASED-literal initialiser on the parameter a bound names.  Golden carries
  the literal's own width AND base: `8'd8` → `INT:8 sz8 ct7`, `4'h7` →
  `HEX:7 sz4 ct5`.  Pristine wrote the FORMAL's width with `UINT`/ct9 (size
  accidentally right when the widths coincided), the patch writes 64.  No cell
  is EQUAL in either state, so the judge cannot see it, but the SIZE field does
  move away on `v6:18/22/26`, `v2:15`, `v8:15`.  earl80's `SrlgLitEnc` closes
  it.
* **R2.** The law is applied only ONCE per definition where a bound is read
  through `makeTypespec`: with three instances of one module golden folds all
  three at the parameter's width and we fold ONE (`v1:33`, `v4:23`).  The other
  copies never reach this builder — an emission-path gap, not a width gap, and
  the biggest remaining source of UNMOVED-WRONG cells in the arms.
* **R3.** For a `wire` of a packed struct array golden emits ONE bound constant
  where we emit TWO (`v3:23-31`, `v7:20`).  A COUNT divergence, pre-existing,
  untouched; the patch makes both of our copies carry golden's value, which is
  strictly closer but still 2-vs-1.
* **R4.** A negative package parameter at a bound: golden `INT:-1 ct7`, ours
  `UINT:0 ct9` on BOTH copies (`v7:16`).  The patch aligns the two copies at the
  right SIZE; the value and ct are a `patDefBoundPkgParamSubst` residue.
* **R5.** `r10buvm22repro/g22.sv` — a pointer leaks into a constant's
  `vpiDecompile`/`UINT`, 22433209 vs 22437337, delta exactly 4128, and the kill
  switch proves it is not this law.  It is the tax every boundary walk pays and
  it will corrupt any future attribution that does not run the kill switch.
* **R6.** 14 probe arms segfault (rc=139) in the ELAB view under BOTH binaries
  symmetrically.  Pre-existing.
