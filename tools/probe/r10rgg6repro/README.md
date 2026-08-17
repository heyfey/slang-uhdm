# r10rgg6 — § nestedParamActualTs6: the write-through that fires ONE LEVEL DOWN

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `f9bd718`.**  Target: `default:Rggen`'s official head
after rgg5 — the 17-line, one-head `ref_typespec` we hung off the ELABORATED
`get_sub_n_list(N)` parameter-initializer call in every `rggen_or_reducer`
instance, where golden hangs nothing.

**RESULT.  The head object is CLEARED.**  Rggen/default's R0 moves off the
`ref_typespec` family entirely: all **17** of our spurious `ref_typespec`
objects are gone, the census goes **20 → 3** `func_call`s carrying a
`vpiTypespec` against golden's **3**, and the whole-database diff base→patched
is **120 lines removed, 0 added** — nothing but that one family moved.
`FuncInModule`, the clause's own witness and a `CMP_EQUAL` row in BOTH modes,
**stays `CMP_EQUAL` in both modes** (0 cmp lines, 0 heads).

**Rggen still does NOT pass `uhdm-cmp`, and the new head is BIGGER on the page.**
`rowheads.sh` reads **17 cmp lines / 1 head → 85 / 1 head**.  Read that
correctly: `uhdm-cmp` prints the FIRST disagreement and nothing else, so its
line count is the SIZE OF THE HEAD OBJECT'S SUBTREE, not a quantity of
disagreement.  The new R0 is the pre-existing **tree-shape** divergence rgg5
already declared unfixable by any field law: golden's innermost
`u_mux.g.u_reducer` takes the `else : g_reduce` branch (an `always` assigning
`o_result = next_data[0]`) because Surelog's corrupted fold cannot evaluate
`NEXT_N`, while slang folds `NEXT_N` correctly and instantiates another
`u_reducer` — 17 instances against golden's 13.  That object is **present in the
BASE database too** (`grep u_mux.g.u_reducer.g_reduce`: base 468 lines, patched
460, golden 28); it was simply BEHIND the `ref_typespec` head.  No value law
closes it.

---

## 1. WHAT THE HEAD WAS

```
LHS: <null>
RHS: ref_typespec (work@rggen.u_block_0...u_mux.g.u_reducer) id 17063
       < func_call(get_sub_n_list) @rggen_or_reducer.sv:62:47
       < param_assign @62:33   (localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);)
     vpiActual: bit_typespec @36:56  = get_offset_list's `sub_n_list` FORMAL
```

We stamped it through the ELAB arm of § `elabParamTsRebind`
(`src/ExprEmit.cpp`), whose witness is `FuncInModule` — the SAME SOURCE FILE as
`rggen_or_reducer.sv`, four lines different.  Golden stamps `FuncInModule`'s
call and leaves Rggen's bare, in all thirteen of its instances.

## 2. THE DISTINGUISHER, FOUND BY GRID AND NOT BY GUESSING

The brief suspected the DEF-vs-ELAB view, the instance count, the recursion, or
the corrupted fold.  **All four are irrelevant.**  Round 1 of the grid (48 cells:
top / 1 instance / 2 instances / 2 instances with different N / generate-for /
recursive × N ∈ {2,4,5,20,25} × foldable-or-not × typed-or-untyped formal ×
param-init / cont-assign / procedural consumption site) separates cleanly on
**one axis and one only** — what the THIRD localparam's call takes:

| third localparam            | golden stamps `P1 = f1(N)`? | cells |
|---|---|---|
| `P3 = f3(P2)`   (FuncInModule) | **YES**, with `f2`'s formal ts | every topology, every N |
| `P3 = f3(P1)`   (Rggen)        | **NO**                          | every topology, every N |
| `P3 = 2`        (no third call)| **NO**                          | every topology, every N |

Topology moved nothing.  N moved nothing.  Recursion moved nothing.

## 3. THE LAW

Round 2 turned that axis into a mechanism and made it falsifiable; round 3
pinned the two things an implementation still has to choose (ORDER and REACH);
round 4 isolated an emitter artefact.  All measured against REAL SURELOG.

> **§ nestedParamActualTs6.**  Surelog reduces an elaboration-time constant call
> by binding its actuals to the callee's formals
> (`UHDM/templates/ExprEval.cpp::evalFunc`: `exparg->Typespec()->Actual_typespec(tps)`).
> An actual that NAMES A PARAMETER resolves, through `ExprEval::getValue`, to
> that parameter's own `param_assign` **Rhs object** — and `getValue` reduces a
> `constant`/`ref_obj`/`operation`/`hier_path`/`bit_select`/`sys_func_call` Rhs
> but **NOT a `func_call` one**, so a `func_call` Rhs is handed back as itself
> and receives the stamp.
>
> That write reaches the TREE only from a **NESTED** evaluation.  The OUTERMOST
> call of a constant expression binds against `evalFunc`'s **cloned** copy of
> the enclosing scope's `param_assigns` (`clone_tree(p, &elaboratorContext)`),
> so its own direct parameter actuals are left bare.  Concretely, for a
> parameter initializer `Pk = F(...)`:
>   * `F`'s own direct parameter actuals' Rhs calls are **NOT** stamped;
>   * for each actual that is a parameter `P` whose initializer is itself a call
>     `G(b1..bm)`, each `bj` that names a parameter whose Rhs is a `func_call`
>     gets **G's formal-j typespec** — and the rule applies again inside that
>     parameter's own initializer, **without depth limit**;
>   * an INLINE nested call (`P3 = f3(f2(P1))`) is nested by construction and
>     does stamp its own actual;
>   * writes are **LAST-WINS**, ordered by the DRIVING (outer) expressions, and
>     within one driver by argument order, depth-first.

Applied to the two sources that started this:

```
FuncInModule  NEXT_N = get_next_n(OFFSET_LIST)
              -> one level down is get_offset_list(SUB_N_LIST_P)
              -> SUB_N_LIST_P's get_sub_n_list(N) Rhs IS stamped  (39:56)   GOLDEN
Rggen         NEXT_N = get_next_n(SUB_N_LIST)
              -> one level down is get_sub_n_list(N) itself
              -> its only actual is the integer parameter N, whose Rhs is a
                 CONSTANT, not a call -> NOTHING is stamped               GOLDEN
```

### The predictions, and what golden said

| cell | prediction | golden |
|---|---|---|
| `r2_chain4`  P4=f3(P3), P3=g2(P2), P2=f2(P1) | P3 bare, P2←g2's ts, P1←f2's ts | **exactly** |
| `r2_chain3_nodemand` nothing uses P3 | "demand" is NOT the trigger | **REFUTED the demand model**: still stamped |
| `r2_rggen_plus` Rggen + one nested consumer | P1 becomes stamped | **yes** |
| `r3_chain5` five deep | P1,P2,P3 stamped; P4,P5 bare | **exactly** |
| `r3_two_actuals` `k2(P1,P1B)` | P1B←k2's 2nd formal; P1←g2's (last wins) | **exactly** |
| `r3_same_twice` `k2(P1,P1)` | P1←k2's **SECOND** formal | **exactly** |
| `r3_inline_nested` `f3(f2(P1))` | P1←f2's ts | **yes** |
| `r3_order_split` inner order ≠ outer order | the OUTER order decides | **yes** (g2, not f2) |
| `r2_ca_outer` outer call in a cont-assign | no stamp | **yes** |
| `r3_proc_outer` outer call in `always_comb` | no stamp | **yes** |

## 4. TWO THINGS THE IMPLEMENTATION HAD TO LEARN THE HARD WAY

**(a) `vpiParent` cannot tell you the call is outermost.**  The first cut tested
`parent->UhdmType() == uhdmparam_assign`; the `param_assign` is not the `parent`
handed to `emitExpr`, so every param-init call read as NESTED and stamped its own
actual (`GRID` went 31→13 MATCH, worse than base).  Nesting is now COUNTED where
nesting happens — `callEmitDepth6`, an RAII guard at the top of `emitExpr`'s
`Call` case.

**(b) Our emitter re-emits the same source expression.**  With
`R10RGG6_TRACE=1` on `cells/r4_f2_then_g2` the driver list reads
`N, P1, P1, P2, P2B, P2` — the driver `P3 = f3(P2)` runs a **second** time,
AFTER `P3B = f3(P2B)`, and its repeat silently un-did the later chain's write.
Golden evaluates each parameter initializer once per instance, so the law now
deduplicates the **(driving site, target call, formal typespec) TRIPLE**.  The
triple and not the pair: `r3_same_twice` writes twice from ONE site with two
different typespecs and golden keeps the second.

## 5. THE GRID, both binaries, one table

`report_grid.sh` compares GOLDEN and OURS on **every** parameter-initializer
`func_call` in the ELAB view of every cell, not just the head one.

|                | comparable | MATCH | DIFF |
|---|---|---|---|
| base `f9bd718` | 62 | **33** | 29 |
| patched        | 62 | **58** | 4  |

`GRID_BASE.txt` / `GRID_PAT.txt` carry the per-cell rows.  Seven cells are
unmeasurable and are COUNTED as such (two crash Surelog itself; four are
`--nobuiltin`-free untyped-formal or non-terminating-recursion cells slang
rejects).

### The four remaining DIFFs, named

* **`rec_p2_n4_yes_typed_param`** — DIFF in base too.  It is the recursion
  tree-shape divergence (ours elaborates three instances, golden one); no field
  law reaches it.  Not a regression.
* **`r2_demand_net`, `r3_unpacked_dim`, `r3_gen_cond`** — **base MATCHED, patched
  DIFFs.  THREE PRISTINE-RIGHT → PATCHED-WRONG CELLS, AND THIS PASS SAYS SO
  OUT LOUD.**  In all three the outer driving call sits in a DECLARATION RANGE
  (`logic [f3(P2)-1:0]`), an UNPACKED DIMENSION (`logic [1:0] arr [f3(P2)]`) or
  a GENERATE CONDITION (`if (f3(P2) > 1)`), and golden stamps `P1` from there
  exactly as the law says it should.  We cannot drive from those sites because
  **our emitter emits no ELAB-view call object at them at all** — measured:
  `r3_unpacked_dim` emits ZERO `f3` calls anywhere, `r3_gen_cond` emits two and
  BOTH are in the DEF listing.  Base agreed with golden on these three by
  accident: its depth-0 rule stamped `P1` from `P2 = f2(P1)`, which is the WRONG
  reason for the right answer, and the same rule is what put 17 wrong objects in
  Rggen.  Covering them needs an AST-side driver over an elaborated instance's
  declaration ranges and generate conditions; that is a separate law with its
  own boundary, and it is NOT in this patch.  Corpus exposure of the residue is
  zero on the measured side: the surelog and uhdm2rtlil sweeps move **0 rows**,
  and `byteverify` finds **3 movers in 1310 databases**, all three predicted and
  all three explained above.

## 6. WHAT MOVED, AND THE PREDICTION THAT NAMED IT FIRST

`PREDICT.txt` was written from the SOURCES before the patched binary was ever
run over a corpus: a test can only move if it declares a parameter whose
initializer is a CALL WITH AN IDENTIFIER ARGUMENT.  That is 17 of 794 surelog
tests and 4 of 731 uhdm2rtlil tests.  The observed mover set is
`{Rggen/default, FuncInModule/default, FuncInModule/testflags}` — a strict
subset, with `FuncInModule` moving only in serialized object identity.

## 7. FILES

    gen_grid.py gen_grid2.py gen_grid3.py   the 69 cells, one axis per round
    cells/                                  the sources themselves
    run_grid.sh                             real Surelog + a slang-uhdm binary
    dumpscan.py                             the dump reader (calls|allcalls|params)
    report_grid.sh score.py                 the per-cell tables
    GRID_BASE.txt GRID_PAT.txt              those tables, both binaries
    CENSUS.txt                              Rggen func_call vpiTypespec census
    HEAD_R0_BEFORE/AFTER_default_Rggen.cmp  the official head, both binaries
    predict6.sh PREDICT.txt                 the mover prediction (src|db modes)
    byteverify.sh BYTEVERIFY_*.txt          the mover gate (SELFCHECK=1)
    boundary.sh BOUNDARY.txt                292 precedent arms, subdirs included
    gates.sh GATES.txt                      the five mandatory legs, as run
    ct8rows.sh canaries.sh ctcan2.sh canaudit.sh rowheads.sh rggencensus6.sh
