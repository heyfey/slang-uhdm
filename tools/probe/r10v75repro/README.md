# r10v75 — adversarial verification of r10earl75 (§ genScopeProcOpFoldTs75)

**VERDICT: ACCEPT as shipped.** No production line changed by this verifier.
The patch is `/tmp/r10earl75.patch`; this directory is the verifier's evidence
and rides with it. **MEASUREMENT ONLY** — the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge. `results/*.csv` was
READ ONLY throughout and **no row was converted**.

Base `94e673b`. Every number below was produced in my own worktrees, with
binaries I built and froze myself, using instruments I wrote independently of
the pass's.

---

## 1. Bit-for-bit reproduction

| claim | mine |
|---|---|
| pristine binary md5 `e52f39cc3ed19857684896fe4602ee2c` | **same** — my rebuild of a clean `94e673b` |
| patched binary md5 `0dfff398b6cc969b40f5bc78e31e5522` | **same** |
| `HEAD_BEFORE_{default,testflags}.cmp` (17 lines, 1 head) | **same object, both modes** |
| `HEAD_AFTER_{default,testflags}.cmp` (36 lines, 1 head) | **same, line for line** |
| goldens 23/0 both binaries, 0/23 on `/bin/false` | **same** |
| u2r 679/50/2 both modes, 0 differing rows | **same** |
| surelog 1588 rows, 0 differing rows, no conversion | **same** |
| every other named row's head unchanged | **same** (`GATES_V75.txt`) |
| Earlgrey census: TO-GOLDEN 2 per mode, AWAY 0, values unmoved | **same** |
| WIDE boundary DIFFERING = the grid + `pf19.sv` | **same** |

`GATES_V75.txt` carries every gate with its numbers. Two headline numbers
came out differently and both are explained there and below: **byte movers
3/956, not 2** (the third is the documented Scoreboard/default coin, convicted
by a neutral control in which the *patched* binary alone lands on the
*pristine* hash two runs out of three), and my probe-copy file count is 3421
where the pass counted 3435 (a different snapshot of `tools/probe`, same
verdict).

---

## 2. The instruments, and why they are not the pass's

* **`vcen75.cpp`** — whole-design constant census read straight off
  `Serializer::AllObjects`, keyed on the constant's own span (the FILE is
  dropped: our databases leave `VpiFile` empty on a folded constant), with the
  payload split into the **value** fields any generated `Compare` reads
  (`VpiConstType` / `VpiSize` / `VpiValue` / `VpiDecompile`) and the
  **ref_typespec edge** (present? actual kind / name / defname / signedness /
  its own span). A flat arena walk, deliberately **not** the
  `UhdmListener` route `r10earl75repro/cscen75.cpp` takes, so a routing bug in
  either instrument cannot hide in both.
* **`vscore75.py`** — an **order-free multiset-distance** scorer. The pass's
  `score75.py` sorts golden / pristine / patched separately and pairs them by
  INDEX; a sorted-list pairing is exactly what manufactures phantom AWAY cells
  (and can hide a real one). This one compares `Counter`s per key and reports
  `TO-GOLDEN / TOWARD-NOT-EQUAL / AWAY-GOLDEN / MOVED-WRONG / MOVED-SIDEWAYS /
  NOGOLD-MOVED / STILL-*`. Scored on the pass's own `g1_gsproc75.sv` it
  reproduces the pass's 13 moved rows exactly, with 0 in every bad bucket.
* **`vbwide75.sh` / `vbdir75.sh`** — my own recursive per-file and
  per-directory boundary. **A normalisation trap worth recording:** the first
  line of `uhdm-dump` output is `<dbfile>: Restored design …`, so A-vs-B
  compares on databases written to different filenames report EVERY cell as
  DIFFERING. My first walk did exactly that. Normalise line 1.
* **`varm75.sh`** — build one arm with Surelog and with both frozen binaries in
  both views, run the official `uhdm-cmp` on each, census all five.

---

## 3. What I tried to break, and what held

Seven arms, `ARMS_V75.txt` for the per-arm scores and what each adds over the
pass's grid. Homes: module body, gen-if, gen-for, nested gen, gen-for inside
gen-if, **interface**, **program**, gen-scope function, gen-scope task,
uninstantiated branch, taken else arm. Origins: `int`, `int unsigned`,
implicitly typed, negative, `longint`, `byte`, `shortint`, `bit [7:0]`,
1/2/3-hop derived chains, a second package, qualified reads, module parameter,
module localparam, gen-scope localparam, genvar. Positions: replication count
(whole Rhs and under an operator), concat member, arithmetic operand, ternary
arm, `if` condition, `case` item, bit-select index, part-select bound, indexed
part-select width, `$clog2` argument, call argument, loop conditions. One to
three instances, per-instance overrides whose actuals are multiplication,
subtraction and `$clog2`. Both views on every cell.

**Totals over all nine arms (seven mine + the pass's grid + `pf19.sv`):
TO-GOLDEN 40, AWAY-GOLDEN 0, MOVED-WRONG 0, and the value fields never move —
in the default view and in the `--elabuhdm` view alike.**

Three results are worth naming because they were live risks:

* **The `ref_typespec` fullname.** `gsProcOpFold75` sits in the `VpiFullName`
  chain *before* the fallback that `tfOpFold9` uses, so a fold that satisfied
  both would be renamed. It cannot: the a3 dump diff between the two binaries
  is **exactly four added `ref_typespec` blocks and nothing else**, the
  gen-scope function's and task's existing stamps are untouched, and each new
  block reads `work@a3top.u_a` — the OWNING INSTANCE, **character-identical to
  golden's** at the same site.
* **Nested generate.** In a gen-for inside a gen-if, golden emits **no folded
  constant at all** and neither do we, in either binary — `§
  genNestedScopePkgParamNoFold24` is not disturbed.
* **Interfaces and programs.** `emitGenScopes` is also the interface caller, so
  the law reaches interface gen scopes; golden stamps there and the patch
  matches it (a1, 4 cells). A module with a gen-scope process instantiated
  inside another module's for-generate stamps correctly at both instance
  levels (a6).

---

## 4. The one claim I refuted, and its decode

`r10earl75repro/README.md` §4 says of the two fences: *"neither fence can
suppress a stamp golden makes — in both regions golden has no constant to
stamp"*, and reports **no-golden-cell MOVED = 0 on the grid and in the
corpus**. The corpus number is right (I re-measured it: the Earlgrey delta is
exactly the two head cells, nothing else). The general statement is not.

`a2_loops75.sv` puts the loop kinds the grid has none of into a gen-scope
`always_comb`, and golden answers differently for each:

| position, inside a gen-scope `always_comb` | golden | ours (94e673b) | patched |
|---|---|---|---|
| `foreach (mem[k]) r = r + {NB{1'b1}};` (body) | folds, **stamps** | folds, bare | **stamps** — TO-GOLDEN |
| `do begin r = r + {NB{1'b1}}; …` (body) | folds, **stamps** | folds, bare | **stamps** — TO-GOLDEN |
| `while (w < NB)` (**condition**) | **no constant** — keeps a `ref_obj` | over-folds | over-fold **now stamped** |
| `end while (d < NB)` (**condition**) | **no constant** — keeps a `ref_obj` | over-folds | over-fold **now stamped** |
| `repeat (NB)` (**count**) | **no constant** | over-folds | untouched (parent is the stmt, not an operation) |
| `for (int i = 0; i < NB; i++)` header AND body | **no constant** | over-folds | untouched (fence b) |

and in the MODULE BODY of the same file golden folds **and stamps every one of
the six**, the `for` header included.

So the region where golden refuses to substitute inside a generate scope's
process is **bigger than the for-statement**: it is the for-statement (header
and body) *plus every loop CONTROL expression* — `while` and `do…while`
conditions and the `repeat` count — while the *bodies* of `foreach` and
`do…while` substitute normally. `procForAllDepth9` covers only the first of
those, so two cells per witness are stamped on constants golden does not have.

**Why this is not a regression and does not block the landing.** Golden has a
`ref_obj` where we have a `constant`: `basetype_t::Compare` fails on `VpiType`
before `expr::Compare` ever reaches the `Typespec` arm, so the added edge is
invisible to the judge at that object. No cell that was RIGHT became WRONG —
in either view, on any arm. And the corpus contains **zero** cells of the
shape: the whole-database Earlgrey census moves exactly two cells, both to
golden, and `byteverify` finds no other real mover in 956 + 1358 databases.

**What it is worth.** It is a free, already-measured extension of the pass's
own R0. R0 is *"suppress the FOLD, not the stamp, when `inGenScopeProc &&
procForAllDepth9 > 0`"*; the table above says the same suppression is owed to
`while` / `do…while` conditions and the `repeat` count, and that
`foreach`/`do` **bodies** must keep folding. `a2_loops75.sv` is the ready-made
grid: its module-body twin module is the negative control that must not move.

---

## 5. Residues I add to the pass's list

* **V-R1 (feeds the pass's R0).** The gen-scope non-fold region is
  for-statement + loop CONTROL expressions, not the for-statement alone
  (§4 above, `a2_loops75.sv`). Two cells per witness are currently stamped on
  objects golden does not have; zero in the corpus.
* **V-R2.** An `initial` inside a gen scope **of a `program`** DOES fold and
  stamp in golden (`a6_prog75.sv:12`), where fence (a) — measured on a module
  — refuses. Pre-existing (pristine is bare there too), unfixed by this pass,
  and the reason is visible in the emitter: a program body is compiled in the
  elaborated context with `inProcessEmit` set, so a program's *module-body*
  `initial` is already stamped and only its *gen-scope* one is not.
* **V-R3.** An interface's **module-body** process (`a1_iface75.sv:20`) misses
  the stamp golden makes, in both binaries — `§ procOpFold9`'s hole one level
  out from this law, and cheap to check next to V-R2.
* **V-R4.** Confirms the pass's R4 from the other side: the two positions
  `§ procOpFold9` misses (`x = NB;` with no operation, and a `$clog2`
  argument) are missed in the interface and program homes as well.

---

## 6. Reproduction

```bash
g++ -O2 -std=c++17 vcen75.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vcen75
PRIS=<pristine> PATCHED=<patched> ./varm75.sh a2_loops75.sv <outdir>
for t in g o oe q qe; do ./vcen75 <outdir>/$t.uhdm --ts | sort > $t.ts; done
python3 ./vscore75.py g.ts o.ts q.ts      # default view
python3 ./vscore75.py g.ts oe.ts qe.ts    # --elabuhdm view
#   ... and again with --val for the value fields.

PATCHED_BIN=<p> PRISTINE_BIN=<q> TMPD=<scratch> ./vbwide75.sh <file-list> <prefix>
PATCHED_BIN=<p> PRISTINE_BIN=<q> TMPD=<scratch> ./vbdir75.sh  <dir-list>  <prefix>
```

The boundary lists are built from a COPY of `tools/probe` with **no path
filter**, `.sv` and `.v` at any depth, with the four slang-fenced tests removed
by a regex passed on the command line (0 files matched; no driver here names
them).
