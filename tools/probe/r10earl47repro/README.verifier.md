# r10earl47 — ADVERSARIAL VERIFIER's report

**VERDICT: ACCEPT WITH FINDINGS — LAND IT, and restate the law.**

The headline is TRUE and it is stronger than the implementer claimed: the
46-line Earlgrey head is cleared, and all **24** `prim_keccak`
`gen_rho_x[i].gen_rho_y[j].gen_others` sub-trees are now **BYTE-IDENTICAL to
golden**, 176 dump lines each, `vpiParent` and spans included (pristine: 149
lines, 24 of 24 differing). Every number in the implementer's write-up
reproduced on an independently built pair of binaries — build md5s, head
line-counts, census, per-shape movers, multiset distance, all five gates, all
canaries.

**But the LAW AS STATED IS FALSE, and the patch introduces a new, cmp-visible
over-fire in a shape that is absent from both corpora.** The stated
discriminator is "the localparam's declaring gen scope is the IMMEDIATE PARENT
of the use site's emission scope path". The code's discriminator is "drop the
last component of the emission prefix, whatever that component is". Those two
are the same sentence only when the last component is a generate scope. My arm
`v47v_prefixkinds.sv` puts a **function**, a **task**, a **named statement
block** and a **variable initializer** in that position and measures golden
cell for cell: the code fires in three places where golden emits a `ref_obj`,
and in one of those three the PRISTINE binary was already RIGHT. Section F1
below is the counterexample table; §F1.2 states the law the arm actually
measures, which is a clean next pass.

Neither corpus contains a cell of that shape (byte verifier: no test's
database moved except Earlgrey), so no gate can see it. That is why this is an
ACCEPT and not a REJECT — and why it must be written into the commit message
instead of the stated law, which would otherwise be quoted forward as measured
fact.

Everything below was run in the verifier's own worktrees
`/tmp/wt_r10earl47v` (patched, `git apply` of the delivered patch onto a fresh
`f0d93e1`) and `/tmp/wt_r10earl47vpris` (pristine `f0d93e1`), both
`git rev-parse HEAD` = `f0d93e15aeab7fd559d9c7c00c6196fcc99023e6`.

---

## 0. REPRODUCED, number by number

| claim | implementer | verifier | |
|---|---|---|---|
| patched binary md5 | `f57b50b3987a6554a5ad63690c472d13` | same, from a fresh independent build | ✅ |
| pristine binary md5 | `2ecf28a8494750468a6edcd435b8f874` | same, from a fresh independent build | ✅ |
| ` error:` lines in build | 0 | 0 (`-j 2`, `[100%] Linking CXX executable slang-uhdm`) | ✅ |
| pristine Earlgrey head | 46 lines | 46, and `diff` vs the committed `r10earl46repro/r6_nexthead46.cmp` is **EMPTY** | ✅ |
| patched Earlgrey head | 644 lines | 644, `diff` vs committed `r6_nexthead47.cmp` **EMPTY** | ✅ |
| keccak cells vs golden | "72 moved" | **24 of 24 `gen_others` sub-trees byte-identical to golden** (my own region differ, stronger than a cell census) | ✅ |
| movers by multiset | ADDED 936 / REMOVED 288 / NET +648 | identical, and every fullname-bearing shape is `work@prim_keccak.gen_rho_*` | ✅ |
| `msdist` vs golden | 307 428 → 306 492 (−936) | identical; golden-only −792 AND ours-only −144, i.e. strictly toward golden | ✅ |
| census (both sides) | see README §4.2 | `census47.py` re-run by me: output **byte-identical** to the committed `census47_pristine.txt` / `census47_patched.txt` (only the outfile path string differs), and `census47_patched_cells.txt` identical | ✅ |
| over-fire population R7 | 145 before and after | 141 `operation.vpiOperand` + 4 `bit_select.vpiIndex` = 145 both | ✅ |
| gate 2 goldens | 23/0, `/bin/false` 0/23 | 23/0, `/bin/false` 0/23 | ✅ |
| gate 3 u2r | 679/50/2 ×4, ct8rows 0 rows, dump 496/183/52 | identical; pat-vs-pris CSVs `diff` EMPTY both modes | ✅ |
| gate 4 surelog | 469/11 + 465/8, FAIL 25/23, DEFER 5/5, 0 rows | identical, both histograms (325/244/225, 329/300/165) unchanged | ✅ |
| gate 5 u2r bytes | 0 / 1358 movers | 0 / 1358; SELFCHECK 1357/1358; SELFCHECK1 = 1 | ✅ |
| gate 5 surelog bytes | **1** / 953 | **2** / 953 — Earlgrey (real) **and Scoreboard** | ⚠ F3 |
| Earlgrey determinism | `09b53b21d06d…` twice | `09b53b21d06d…` from my standalone run AND from the sweep; pristine `98b93a3e54d7…` likewise | ✅ |
| canaries | ok=8 / ok=52 / ctcan2 1+58 / canaudit 29,0,0 | identical | ✅ |
| named DBs by name | u2r identical=22 moved=0 | identical=22 moved=0 — `gen_test4`, `gen_test5`, `gen_test9`, `genvar_loop_decl_*`, `genscope_cells` all byte-identical | ✅ |
| protected surelog DBs | identical | `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch`: identical=8 moved=0 | ✅ |
| `§` occurrences | 6, production only | 6 in `src/` + `include/`; production diff is exactly `include/UhdmExporter.h` and `src/ExprEmit.cpp` | ✅ |
| `README.verifier.md` absent | yes | yes — this file is mine | ✅ |

I also independently verified the claim the residue ranking rests on, in
UHDM's generated sources rather than by citation:
`BaseClass::Compare` = VpiType, VpiName, VpiDefName; `expr::Compare` adds
VpiDecompile, VpiSize and `SafeCompare(Typespec())`; `constant::Compare` adds
VpiConstType. **`VpiParent` is compared nowhere**, and neither is `VpiValue`.
R4/R5 are correctly classified as cmp-inert.

Boundary arms, all run on BOTH binaries and compared as whole dumps:
`r10earl46repro/{a1,b1,v46v_digits,v46v_gaps}`, `r10earl45repro/{a1,v45_expr,
v45_order,w45v,x45v,y45v}`, `r10earl44repro/{a1,v44_overfire,v44x_deconf}` —
**0 non-path differing dump lines on every one of the 13**. The § 46
encoding arms and the § 40/41 select-structure arms are untouched.

---

## F1 — THE LAW IS MIS-STATED, and the patch REGRESSES one measured cell

`v47v_prefixkinds.sv` (committed here). One gen scope `gen_x[i]` declaring
`localparam int LPX`, one child `gen_y[j]`, and the SAME select-bound read
placed in nine different emission contexts. LHS is always golden.
`LPX = 6` at `gen_x[1]`; both instances and both `gen_y` agree.

| row | where the read is | golden | PRISTINE ours | PATCHED ours | verdict |
|---|---|---|---|---|---|
| `f_fn` | **function** body, localparam's OWN scope | `ref_obj` | const `UINT:6 ct9` par=- | const **`INT:6 ct7` par=param_assign** | over-fire, and the patch CHANGED it |
| `t_tk` | **task** body, OWN scope | `ref_obj` | const `UINT:6 ct9` par=- | const **`INT:6 ct7` par=param_assign** | over-fire, CHANGED |
| `nb` | **named `begin : nb`** in an `always_comb`, OWN scope | `ref_obj` | **`ref_obj` — MATCHES golden** | const `INT:6 ct7` par=param_assign | **REGRESSION** |
| `r_dini` | variable **declaration initializer**, OWN scope | const `INT:6` par=param_assign | `ref_obj` | const `INT:6` par=param_assign | FIXED ✔ |
| `r_own` | plain `cont_assign`, OWN scope | `ref_obj` | `ref_obj` | `ref_obj` | inert ✔ |
| `g_fn` | **function** body, CHILD scope | const `INT:6 ct7` par=param_assign | const `UINT:6 ct9` par=- | unchanged | under-fire (pre-existing) |
| `nb2` | **named block**, CHILD scope | const `INT:6` par=param_assign | `ref_obj` | `ref_obj` | under-fire (this law cannot reach it) |
| `n_ok` | plain `cont_assign`, CHILD scope | const `INT:6` par=param_assign | `ref_obj` | const `INT:6` par=param_assign | FIXED ✔ |
| `n_ini` | declaration initializer, CHILD scope | `ref_obj` | `ref_obj` | `ref_obj` | inert ✔ |

Arm totals at `gen_x[1]`: **9 → 7 differing rows of 27**. Net progress, with
one cell moved the wrong way.

**The `nb` row is a real, NEW, cmp-visible divergence**: it is the FIRST
divergence of the patched arm's `uhdm-cmp` run —

```
LHS: ref_obj: (work@v1_earl47v.gen_x[0].nb.LPX), line:31:21   <- golden
RHS: (a constant)                                              <- patched ours
```

and the pristine binary's first divergence in the same arm is a different
object entirely (the `r_dini` cell the patch fixes). `constant` vs `ref_obj`
differs in `VpiType`, which is the first field `BaseClass::Compare` reads, so
this is not a dump-fidelity residue — it is a cmp failure.

**Blast radius: zero corpus cells.** Gate 5 shows no database in either corpus
changed except Earlgrey, so no `uhdm2rtlil` or Surelog test contains a
function/task/named-block read of a gen-scope localparam in a select bound.
Every gate stays green. The shape is nevertheless ordinary RTL (a helper
function inside a `generate` block indexing by the block's own localparam),
so it is a latent bug, not an exotic one.

### F1.1 — this also REFUTES the write-up's R-7

R-7 says: *"The new helper is only ever consulted where the existing code was
about to emit a plain `ref_obj` … so no existing fold can be overridden by
it."* The `f_fn` and `t_tk` rows are counterexamples: pristine already emitted
a `constant` there (`UINT:6 ct9`, unparented) from another fold path, and the
new helper — the `if` of an `if / else if` — pre-empts it and rewrites the
encoding and the parent. Both readings are wrong against golden, so nothing
regresses in cmp terms on those two rows, but the stated invariant is false and
should not be carried forward.

### F1.2 — the law the arm actually measures (hand-off)

Golden's own naming settles it: the surviving golden `ref_obj`s are
`gen_x[0].nb.LPX`, `gen_x[0].f_fn.LPX`, `gen_x[0].t_tk.LPX` and
`gen_x[0].gen_y[j].n_ini.LPX` — every one of them exactly ONE name-hop above
the declaring scope, and golden refuses all four. So the discriminator is not
a name hop at all. Counting **GENERATE scopes only**, and treating a variable
declaration initializer as sitting one level below its own scope, every cell in
the arm AND in `a1`/`a2`/`a3`/`b1` AND the 72 keccak cells fall out:

> substitute iff the number of GENERATE-scope hops from the use's enclosing
> generate scope up to the declaring scope is exactly **1** — where a variable
> **declaration initializer** counts as one hop deeper than its own scope
> (so its own scope's localparam is distance 1, and its parent's is 2).

Checked against every measured cell: `r_own` 0 ✗, `nb` 0 ✗, `f_fn` 0 ✗,
`t_tk` 0 ✗, `r_dini` 1 ✓, `n_ok` 1 ✓, `nb2` 1 ✓, `g_fn` 1 ✓, `n_ini` 2 ✗,
a3's `z_2up` 2 ✗, `z_3up` 3 ✗, keccak's `gen_others` 1 ✓. It differs from the
shipped rule in exactly the four function/task/named-block rows.
Implementing it needs the generate-scope path, not `usePrefix` — the string is
the wrong instrument, which is the whole finding.

---

## F2 — `genLpFoldByPath` is never cleared, and the ts drain is unchecked

Two robustness gaps in the new helper, neither observed to fire:

1. `genLpFoldByPath` has no `.clear()` anywhere (`ModuleEmit.cpp:12450`,
   `:12685` insert; nothing erases). Entries therefore outlive their module and
   their view. The `it->second.ps != &sym.as<ParameterSymbol>()` identity check
   makes a stale entry a MISS rather than a wrong object, so the failure mode is
   a silently missed fold, never a wrong one. I verified the identity check does
   its job: in `a2`, `gen_x[0]` folds to `INT:4` and `gen_x[2]` to `INT:8`, per
   instance, with no cross-instance leakage.
2. The typespec share
   `for (auto& gl : pendingGenLpTs) if (gl.ps == …) { …push_back(rt); break; }`
   has **no else**. `pendingGenLpTs` is drained AND CLEARED in `emitTopPorts`
   (`ModuleEmit.cpp:16740`), which runs once per top definition, so a fold
   firing after its own param's drain would mint a `ref_typespec` with a NULL
   actual — a cmp failure on `expr::Compare`'s `SafeCompare(Typespec())` and a
   dangling `|vpiActual:` in the dump. Not reachable on anything measured: I
   scanned both whole Earlgrey dumps for empty-valued fields and found
   **0 in 1.6 M field slots on each side, and 0 in golden**, with the only
   deltas being +72 `vpiParent`, +72 `vpiTypespec`, +72 `vpiActual` — exactly
   one per substituted cell. Worth an assert, not a blocker.

Also noted, not a defect: taking the fold path skips `emitExpr` for that
bound, so the `refCollector` insert at the head of the `NamedValue` case never
happens for the folded symbol. The collector feeds process/instance ref sets;
the symbol is always a `Parameter`, and gate 5 shows no other database moved,
so nothing consumes it here.

---

## F3 — the byte verifier reports **2** surelog movers, not 1; `Scoreboard` is multi-stable

My gate-5 surelog run reported `MOVERS: 2 / 953`:
`Earlgrey_0_1` default (real) **and** `Scoreboard` default. Applying the
standing MOVER RULE: Earlgrey's size delta is **+486 B** (49 939 391 →
49 939 877) → REAL. `Scoreboard`'s size delta is **0** (11 145 455 both
sides) → PROVES NOTHING, so I ran the multi-stability test — the same
`Scoreboard` command line, three times, with **each** binary:

```
run1 pris 51045a62d0e4    run1 pat 307fdd7029de
run2 pris 51045a62d0e4    run2 pat 307fdd7029de
run3 pris 307fdd7029de    run3 pat 307fdd7029de     <- the PRISTINE binary alone flips
```

The pristine binary produces BOTH md5s across runs at a fixed size, so
`Scoreboard` is byte-nondeterministic under this base (the known
macro-buffer `SourceLocation` nondeterminism) and this mover is not the
patch's. The implementer's "1 / 953" was a lucky draw, not a property: the
number is **not reproducible**, and any future pass that quotes a Scoreboard
mover count without the same-binary re-run is quoting noise. `Scoreboard` is
not in the protected named-database list; the four names that ARE
(`InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch`) are
byte-identical, as are all 12 genscope canaries.

---

## F4 — ops: the MAIN TREE moved under this verification

`/home/heyfey/git-repos/slang-uhdm` was at `f0d93e1` with binary md5
`2ecf28a8…` at 07:45 and at commit `024b1b5` with binary md5 `a72eeb76…` by
08:56 — another pass landed and rebuilt mid-run. My first pristine Earlgrey
reading came from that binary before I noticed; I discarded it and re-ran with
my own `f0d93e1` build (`2ecf28a8…`), which is what every number above uses.
**The main tree's `build/slang-uhdm` is not a pristine reference during a
parallel block**; only a pinned worktree build is. (The discarded reading
happened to agree, which is exactly what makes the trap dangerous.)

---

## RANKED RESIDUES (verifier's ordering)

* **V-R0 — the mis-stated law + the `nb` regression (F1).** 0 corpus cells,
  1 arm cell moved the wrong way, 4 arm rows wrong in total. Fix carries the
  measured replacement law in F1.2. Highest priority because it is the only
  thing this pass got *wrong*, and because the stated law will otherwise be
  quoted forward.
* **V-R1 = implementer R0 — the next head**, `prim_present.sv:91-95`, 644
  lines, golden flattens the `gen_enc` if-generate scope. I confirmed it is
  **pre-existing, not created**: `work@prim_present.gen_round[0].gen_enc.gen_d64`
  appears 24× in the PRISTINE dump and 24× in the patched one, and golden has
  0 of them and 24 of the flattened `…gen_round[0].gen_d64`. The row advanced;
  it did not trip over new work.
* **V-R2 = implementer R3 — `pinmux.sv:176:43`, 32 cells**, a module parameter
  read one scope down, carried by ParamEmit and unreachable from
  `genLpFoldByPath`. Confirmed unchanged at 32 in my own census. Largest
  remaining Earlgrey population of this shape.
* **V-R3 — implementer R1/R2/R4/R5/R6**, all confirmed present and all
  cmp-inert or 0-cell, exactly as ranked. R4/R5's cmp-inertness is now
  verified against the generated `Compare` sources, not assumed.
* **V-R4 = implementer R7 — the 145 pre-existing over-fires** (141
  `operation.vpiOperand`, 4 `bit_select.vpiIndex`). 145 before, 145 after. This
  pass did not grow it; F1's over-fire is NOT in this count because the census
  is Earlgrey-only.
* **V-R5 — F2's two robustness gaps** (never-cleared map, unchecked ts share).
* **V-R6 — F3's Scoreboard nondeterminism.** Independent of this pass, but it
  makes the surelog mover count unusable as a bare number; the byte verifier
  should carry the same-binary re-run for zero-size-delta movers.

## REFUTATIONS I checked and could NOT break

* "distance 0 is inert" — a1's whole dump is byte-identical pristine-vs-patched
  (0 non-path lines), and `r_own` in my own arm stays `ref_obj`. ✔
* "a genvar never substitutes" — code-verified (`genLpFoldByPath` is written
  only inside the `realLp` arm of `ModuleEmit`, genvars take the other branch)
  AND measured (`a2` `n_gvb`, the `bx[x][y]` genvar indices). ✔
* "the value does not gate it" — `a2`'s `n_ipswl` literal-init `UINT:8 ct9`
  substitutes like the `INT` ones. ✔
* "per-declaration identity" — `gen_x[0]`→4, `gen_x[2]`→8 in the same arm. ✔
* "the census is not counting declaration constants" — reproduced the
  instrument's own output byte-for-byte and re-derived the 72 from an
  independent whole-sub-tree comparison. ✔

## Workdirs

Sweep workdir root `/tmp/r10earl47v/wdroot` and the arm workdirs were deleted
after the gates ran. The verifier's worktrees are `/tmp/wt_r10earl47v` and
`/tmp/wt_r10earl47vpris`.
