# r10v119repro — the ADVERSARIAL VERIFICATION of r10uvm119

**Verdict: ACCEPT.** Production is unchanged by the verifier; this directory is
evidence only.

Everything below was re-measured from scratch: two FRESH worktrees at
`7c9d641`, both binaries built by the verifier (`cmake -j 2`), frozen
`chmod 555` at immutable paths before any sweep, `SLANG_UHDM` exported
explicitly per binary, and every one of the 6070 `cmds.txt` files audited BY
PATH. The pass's own workdirs and controls were never read.

## 1. The headline numbers reproduce bit-for-bit

| claim | verifier |
|---|---|
| pristine md5 `5bdf758461ccc17f3149f1d43cac9ad0` | **same** |
| patched md5 `43ed567c2fe98891bf3cc2c321e990e5` | **same** (patch applies clean on a fresh `7c9d641`) |
| goldens 23/0, `/bin/false` 0/23 | **same** |
| u2r 679/50/2 both modes, 0 differing rows | **same** |
| surelog 1588 rows, 0 differing rows, histogram identical, NO conversion | **same** |
| byteverify 0/1358 (u2r) and 9/956 (surelog), the 9 named | **same** |
| canaries 52/8 `changed=0`, both ctcan2 PASS, canaudit `UNCOVERED=0 FENCE-BREACH=0` | **same** |
| SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, all protected DBs SAME | **same** |
| row heads 76→50 / 76→13 on nine UVM row-modes, Earlgrey 32/36 unchanged, Rggen 0 | **same** |
| the pass's own arm GRID (`g119_a..h`, both views, sixteen cells) | **every cell identical** |

`GATES.v119.txt` carries the battery. The arm grid needed one correction to be
comparable: this verifier ran `grid119.sh` from a different directory, so
`builtin.sv` prints as an ABSOLUTE path and adds a constant 50 (def) / 70
(elab) lines to every cell on both sides. With those lines filtered the
pass's table reproduces exactly — 56/20, 148/76, 52/52, 236/236, 25/25,
85/85, 137/14, 215/92, 128/20, 166/58, 152/8, 354/66, 144/36, 298/190,
259/75, 773/543.

## 2. The head really cleared — it was not masked

A smaller cmp line count can mean the head moved EARLIER in the walk and now
hides the old object (RESUME §9's "cleared vs unreached" trap). It did not:
the corpus head cell at `uvm_sequence_defines.svh:299` is now **byte-identical
to golden**, receiver-only path name, span through the block's `}`, a
SPAN-LESS `method_func_call`, and a bare `constraint` parented at the
operation — the whole 23-line subtree matches line for line. The new heads are
different objects and the word `seq_or_item` appears in **234 pristine** head
log lines and **zero** patched ones.

Constraint POPULATION now equals golden in every mover database: 8/8
(SeqDriver), 8/8 (MiniAmiq), 6/6 (SimpleUVM), 6/6 (Scoreboard), 4/4
(BuildUVMPkg).

## 3. Independent attribution and score

`v119attrib.sh` (`PAT=… PRIS=… bash v119attrib.sh`) re-derives each of the nine
movers' ORDER-BLIND (sorted, path-normalised) whole-dump diff. Every one of
them touches **exactly six `line:L:C` positions and no others** —
`299:53/54/66` and `204:53/54/59` for the five UVM databases, `56967:10/12/24`
and `56980:12/14/26` for BuildUVMPkg's pp_output. **OFF-SITE = 0 on all nine.**
`ATTRIBUTION.v119.txt`.

`v119score.sh` scores the law's own source positions against **rebuilt
goldens**, per database, as a multiset: **TO-GOLDEN = 177 lines, AWAY-GOLDEN =
0, NEW-SURPLUS = 8**. `SCORE.v119.txt`. The 8 surplus rows are one string
(`\_operation: , line:299:53, endln:299:85`) printed twice per affected
database and are the pass's residue R1 (below).

## 4. Breaking the law: 14 arms, 26 scored arm-views, LOST-CORRECT = 0

`GRID.v119.txt` is the grid, `REGRESS.v119.txt` the per-arm score. The score
is order-blind and asks the only question that convicts: **is there a dump line
that GOLDEN and PRISTINE both had, in multiset terms, that PATCHED lost?**
That is `LOST-CORRECT`, and it is **0 in every arm and every view**.

Shapes measured that the pass's own arms do not write: `super.randomize()`;
a function-return receiver; queue / associative / dynamic-array / non-literal-
index element receivers; nine different constraint-block contents (empty,
`solve … before`, `dist`, `foreach`, `soft`, `->`, `if/else`, `inside` with a
package parameter, multi-statement); a package-function home, an extern
out-of-body task home, an in-body function `return`, a module `initial`, a
`for` body; eight expression positions; eight different things for the block to
reference (receiver members, task local, task argument, caller class property,
package parameter, class parameter, the receiver's non-rand member, a literal);
two randomize-withs in one expression; one as another call's argument; a
MULTI-LINE block; a function call inside the block; a `case` expression;
`fork/join_none`; parameterised-class, static-property, typedef'd and
derived-handle receivers; a package-scoped receiver class; one-character,
case-differing and very long receiver names; a member named `randomize_x`
inside the block and in the identifier list; a user method `randomize_y`
beside; `rand_mode`, `constraint_mode`, and dotted non-randomize calls with and
without arguments.

**`v119_f` is an INDEPENDENT fence control and it is byte-identical between the
two binaries in both views** (its only diff line is the dump's own filename
banner): the scope form ×3, `std::randomize` ×2, the member form without a
block ×4 including `randomize(null)`, `rand_mode`, `constraint_mode`, two
dotted non-randomize calls, and a package function named `randomize`.

**`v119_m` is the sharpest test the pass did not run.** `scopeRandomizeCall116`
keeps a TEXT anchor; if a macro could defeat it the scope form would fall
through into this pass's member predicate. It cannot: with the scope form, the
scope form with an identifier list, `std::randomize`, the receiver, and the
whole statement each written through a macro, the patch changes **only** the
three MEMBER cells (lines 28, 30, 35). The macro-written scope forms and the
macro-written `std::randomize` are untouched, and the two predicates are
measurably mutually exclusive under macro expansion.

## 5. What is still wrong, and none of it is new

* **R1 (the pass's own, count corrected).** In the two databases carrying a
  duplicated UVM package, golden parents the `constraint` at the
  `method_func_call` and we parent it at the enclosing `operation`. There are
  **TWO such objects per affected database, eight in all** across the four
  affected row-modes — the pass's write-up says "eight rows are four objects,
  one per database", which undercounts. It is judge-invisible either way:
  `constraint::Compare` reads VpiName, VpiVirtual, VpiAutomatic,
  VpiAllocScheme, VpiAccessType, Attributes, VpiIsConstraintEnabled and
  Constraint_items, and a `grep` over EVERY generated `Compare` body finds no
  read of `VpiParent` at all.
* **A function-return receiver** (`get_b().randomize() with {…}`, `v119_b`).
  Golden drops the method entirely and emits a plain `func_call (get_b)`.
  Pristine emitted `hier_path (get_b().randomize)`; patched emits
  `hier_path (get_b())` plus a constraint. Both are wrong and wrong in the same
  KIND (hier_path vs func_call), so the judge's first difference is unchanged;
  the dump surplus grows by 4 lines. Zero corpus population.
* **An indexed receiver's `bit_select`** (`v119_c`, and the pass's R3).
  Golden names it with the BASE name and spans the INDEX token; we name it
  `q_c[0]` and span the base. `bit_select::Compare` goes through
  `basetype_t::Compare`, which DOES read VpiName, so this one is
  judge-VISIBLE — but it is untouched by this patch (byte-identical between the
  two binaries) and the hier_path name above it, which is what this law owns,
  now agrees with golden. Zero corpus population, worth its own pass.
* **`this.randomize()` WITHOUT a block** (`v119_a2` line 15). Golden emits a
  `method_func_call` with a `vpiPrefix` STRING constant `this`
  (§ thisDeepStepMockupConst84's shape); we emit a hier_path. Identical on both
  binaries — pre-existing, and the WITH form beside it is byte-perfect.
* **`super.randomize()`** (`v119_a`). Surelog rejects the file (rc=3, no
  database) and slang-uhdm reports it as an unsupported system method call on
  BOTH binaries. Symmetric refusal, no golden, out of scope.
* **The extern out-of-body task body** (`v119_e`). Surelog emits the prototype
  only and no body at all, so every statement we emit there is surplus — 67
  lines pristine, more after. Pre-existing and unrelated; the package-function,
  in-body-`return` and module-`initial` homes in the same file are byte-perfect.

## 6. Two write-up corrections (neither changes the verdict)

* The pass's `BOUNDARY.txt` reports `LISTED=3696` file-mode arms. A clean
  `7c9d641` plus this patch carries **3685**; this verifier's copy, with nine
  arms of its own added, carries 3694. The pass's boundary therefore ran over a
  copy holding eleven files in two directories that the patch does not deliver.
  It is a measurement-only gate and the verifier's own four runs supersede it.
* "Census parent-blind: TO-GOLDEN=67 … exact match [with the prediction]" holds
  at the TOTAL only. `PREDICTION.txt` reads 8/8/9/9/5/9/9/5/5 per cell and
  `SCORE.movers.txt` reads 7/7/8/8/7/8/8/7/7; both sum to 67, but they are not
  the same per-cell set, so the total is a coincidence rather than a row-by-row
  confirmation. The load-bearing halves — AWAY-GOLDEN 0 and STILL-WRONG 0 — are
  confirmed independently here (§3).

## 7. How to re-run

```bash
# arms (both views, golden + both binaries, rc per command in cmds.txt)
bash v119grid.sh v119_<x>.sv <pristine> <patched> <workdir>
bash v119regress.sh <workdir>            # LOST-CORRECT / NEW-SURPLUS / GAINED-CORRECT
# corpus
PAT=<wd>/sl PRIS=<wd_pristine>/sl bash v119attrib.sh    # order-blind diff + positions touched
PAT=<wd>/sl PRIS=<wd_pristine>/sl bash v119score.sh     # TO-GOLDEN / AWAY / NEW-SURPLUS vs golden
# boundary (the pass's driver, over a COPY of the whole probe tree)
PRISTINE=<a> PATCHED=<b> ROOT=<copy of tools/probe> OUT=<out> MODE=file|dir VIEW=def|elab \
  bash ../r10uvm119repro/bound119.sh
```

`v119_a.sv` keeps its surelog-rejected `super` cells on purpose (the refusal is
the measurement); `v119_a2.sv` is the same file without them, renamed
throughout so the two can share a directory. The two-file variant of `v119_k`
was measured and deliberately NOT committed: a lone second file is not
self-contained and would read NONDETERMINISTIC to every future boundary gate.
Every arm here was checked for run-to-run determinism, alone and as a
directory, on both binaries.

| file | what |
|---|---|
| `v119_a..m.sv` | the fourteen adversarial arms |
| `v119grid.sh` | the pass's arm harness, copied unchanged |
| `v119regress.sh` | the order-blind LOST-CORRECT / NEW-SURPLUS score for one arm |
| `v119attrib.sh`, `ATTRIBUTION.v119.txt` | each corpus mover's order-blind diff and the positions it touches |
| `v119score.sh`, `SCORE.v119.txt` | TO-GOLDEN / AWAY / NEW-SURPLUS against rebuilt goldens |
| `GRID.v119.txt`, `REGRESS.v119.txt` | the arm grid and its per-arm score |
| `GATES.v119.txt` | the verifier's full gate battery |
| `BOUNDARY.v119.txt` | four boundary runs plus the pristine-vs-pristine control |
