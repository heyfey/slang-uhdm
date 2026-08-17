# r10rgg7 — § genIfUnvaluedFuncParam7: a generate-if whose condition reads a parameter Surelog never valued is FALSE

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  **BASE `6da448b`.**  Target: `default:Rggen`'s official head
after rgg6 — the TREE-SHAPE divergence rgg5 declared unfixable by any value law:
golden's `u_mux.g.u_reducer` takes `else : g_reduce` (an `always_comb` assigning
`o_result = next_data[0]`) where slang folds `NEXT_N = 7` correctly, takes the
`if` arm and instantiates another `u_reducer` — **17 instances against golden's
13**.

**RESULT.  THE TREE-SHAPE HEAD IS CLEARED, and the whole `rggen_or_reducer`
region of the database is now golden's.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): **85 cmp lines / 1 head →
  66 / 1 head**, and the head object moves to a DIFFERENT FAMILY entirely
  (`rggen_adapter_common.sv:40`'s `pre_decode` cont-assign fold — see § 6).
  Read the line counts correctly: `uhdm-cmp` prints the FIRST disagreement and
  nothing else, so its count is the SIZE OF THE HEAD OBJECT'S SUBTREE, never a
  distance.
* **17 → 13** elaborated `rggen_or_reducer` `module_inst`, matching golden
  path-for-path; the four ours-only nested paths are gone.
* The per-instance census (`census7.py`) over the 14 shared keys goes from
  **2 differing → 0**, with **0 golden-only and 0 ours-only keys**.
* Each adapter mux's `g_reduce` subtree goes **160 objects → 8**, kind-for-kind
  golden's 8, and the whole-database signature census over the reducer region
  goes from **149 EXTRA / 12 MISSING signatures (798 / 14 objects)** to
  **2 / 2 signatures (14 / 14 objects), all of them SPAN-only** on typespecs —
  and `Compare` never reads a span.
* **Rggen still does NOT pass `uhdm-cmp`**, and this pass says so up front.
* Corpus: **u2r 0 movers over 1358 databases; surelog 2 movers over 956 —
  `default/Rggen` (predicted by name before the gate ran) and
  `default/Scoreboard`, the documented ~50/50 COIN, which `attrib7.sh` shows
  differs between TWO RUNS OF THE SAME BASE BINARY.**  0 differing ROWS on
  either corpus, either mode.

---

## 1. THE HEAD, decoded from the GOLDEN DATABASE FIRST

```
LHS golden: gen_scope (work@rggen.u_block_0.u_adapter.u_adapter_common
                       .u_mux.g.u_reducer.g_reduce)  line 97:10-101:8
              vpiProcess -> always @98:7 (vpiAlwaysType 2)
                begin -> assignment (op 82, blocking)
                  vpiLhs ref_obj  o_result
                  vpiRhs bit_select next_data, vpiIndex constant UINT:0 size 64
RHS ours  : <null>
```

The census that decided this pass, `census7.py`, is a per-instance shape census
of EVERY `rggen_or_reducer` `module_inst` in BOTH views (DEF `uhdmallModules`,
ELAB `uhdmtopModules`), keyed on (view, instance path) and reading only shapes
and the value fields the brief names — never a fullname, never a span:

| field | golden, all 13 | BASE, the 13 shared | verdict |
|---|---|---|---|
| `g_reduce` arm | `MODINST=0 ALWAYS=1`, `ref_obj(o_result) <= bit_select(next_data) idx=constant(sz=64,ct=9,dec=0)` | identical at the **11 read-data muxes**, `MODINST>0` at the **2 adapter muxes** | the ONLY divergence |
| `SUB_N_LIST` param_assign Rhs | unfolded `func_call(get_sub_n_list)` @62:47 | same | already right |
| `OFFSET_LIST` | unfolded `func_call(get_offset_list)` @63:47 | same | already right |
| `NEXT_N` | unfolded `func_call(get_next_n)` @64:47 | same | already right |
| `next_data` | `logic_typespec`, no folded range | same | already right |
| the instance `always_comb` (`i < NEXT_N`) | agrees | agrees | already right |
| DEF listing | 4 rows, NO gen scope | identical | already right |

So brief items (c) and (d) — "NEXT_N's own param_assign / next_data range / the
for-loop bound emitted as golden has them" and "the ELAB value for instances that
no longer exist" — needed **NO CODE**: the pristine base already emits every one
of them exactly as golden does.  And item (a)'s hard part, "the else arm's body
must bind", was already PROVEN by the eleven instances that carry that arm
byte-identically.  What was left is the ARM DECISION, which is items (a)+(b).

**Golden's `NEXT_N` param_assign Rhs is the whole story: an UNFOLDED
`func_call`.  Surelog's ExprEval produced no value for `NEXT_N` at all** — at
every one of the 13 instances, in both views.  A parameter with no value makes
its generate-if condition FALSE, which is § `genIfUnitMisevalFalse`'s already
measured rule with a second source of the valuelessness.

## 2. THE LAW

> **§ genIfUnvaluedFuncParam7.**  Surelog's `ExprEval` refuses to reduce some
> constant-function calls, and when the refused call is a **parameter's
> initializer** the elaborated parameter never receives a value at all: its
> `param_assign` keeps the symbolic `func_call` the def view wrote (the fold gate
> in `emitParameters`, and `elabParamCallSymbolic` which reads the same bails
> from the reference side).  A **conditional generate whose condition reads such
> a parameter** therefore behaves exactly as § `genIfUnitMisevalFalse` measured
> for a valueless `$unit` parameter: **the condition evaluates FALSE**, the chain
> walks on to the next arm and, in the end, to the `else`.
>
> The refusals that count are the fold gate's three BAILS —
>   * the body POISONS `ExprEval` (a select of a function-scope object under a
>     poison-propagating operator: `((l[i] != 0) ? 1 : 0)`, i.e.
>     `rggen_or_reducer`'s own `get_next_n`);
>   * the body declares a LOCALPARAM (`const_func_block_var`);
>   * an ARGUMENT lies outside `ExprEval`'s system-call repertoire (`$floor`);
>
> and the valuelessness is **TRANSITIVE** through parameter reads, whatever the
> reading expression is — including the ARGUMENT of a call that itself folds.
> The function may live in a PACKAGE.
>
> **`packedDimCount(type) >= 2` is NOT one of the refusals.**  It also keeps the
> Rhs symbolic, and golden REFUTES generalising to it: `cells/y_mdpacked_n8`
> keeps slang's arm.  Surelog has the value; it just never rewrites the Rhs
> object.

Applied to `rggen_or_reducer`:

```
localparam int NEXT_N = get_next_n(SUB_N_LIST);   // get_next_n POISONS
generate if (NEXT_N > 1) begin : g_reduce  <rggen_or_reducer u_reducer>  end
         else            begin : g_reduce  <always_comb o_result = next_data[0]> end
=> the condition is FALSE at EVERY instance => the ELSE arm, at every instance,
   which is exactly golden's 13-instance no-nesting tree.
```

and the arithmetic it predicts, which is why golden has 13 and slang builds 17:
slang's own chains are `25 -> 7 -> 2 -> 1` and `20 -> 5 -> 2 -> 1`, i.e. 2 extra
instances per adapter mux, `13 + 4 = 17`.

## 3. THE GRID — 63 cells against REAL SURELOG

See `GRID.md` for the full table.  The three results that decide the shape of the
predicate:

* **the saturated regime is IRRELEVANT.**  A poisoning function over a PLAIN
  VALUED pattern array — no r10rgg2 write-back escape anywhere — reads the ELSE
  arm on golden at every N in {2,3,4,5,8,20,25} (`cells/p_pat_n*`).  The brief's
  suggested predicate (a call whose actual is a saturated/escaped packed-array
  parameter) is therefore WIDER THAN NEEDED and would have been narrower than
  golden; the measured axis is the refused reduction alone.
* **it is the CONDITION that is FALSE, not the identifier reading 0**:
  `if (NEXT != 1)` and a bare `if (NEXT)` both take the ELSE arm
  (`cells/k_*_ne1`, `cells/k_*_bare`) where a zero read would have made them
  true.  Same separation r10scr4 measured for the `$unit` form.
* **22 CONTROL cells keep slang's arm**, and `c_fold_*` is the one that carries
  the argument: a `func_call` Rhs PER SE does not falsify a condition — golden
  values `addup(8)` and takes the `if` arm.  Only the REFUSED reduction falsifies.

`verdict.py` over the whole grid: **FIXED 37, BROKEN 0, OK 108, MISSING-SIDE
rows 0.**  The patched binary reproduces golden's arm on **82 of 82** ELAB rows
(base: 45) and on 63 of 63 DEF rows.

## 3b. THE BOUNDARY FOUND TWO CELLS THE CAMPAIGN ALREADY OWNED — BOTH CORRECTIONS

`boundary.sh` over the rgg1-6 / vrgg2-6 repro directories (500 source files,
subdirectory arms included, 404 identical, 94 uncompilable, 0 asymmetries) found
**2 movers**, and each was re-measured against **REAL SURELOG** on a PRIVATE COPY
of that exact cell (the r10rgg6 directory is untouched):

| cell | what it is | golden | base | patched |
|---|---|---|---|---|
| `r10rgg6repro/cells/r3_gen_cond` | `if (f3(P2) > 1)` with **no else clause**, `P2 = f2(f1(N))` and `f1` poisons | **0** gen_scope_array | 2 | **0** |
| `r10rgg6repro/cells/rec_p2_n4_yes_typed_param` | the Rggen shape verbatim: `P3 = f3(P2)`, recursive `m #(.N(P3))` | 2 `g_reduce` gsa, 42 `work@m` inst lines | 6 gsa, 76 lines | **2 gsa, 42 lines** |

The first is also the "no else" face § `genIfUnitMisevalFalse` measured for the
`$unit` form (r10scr4: `if (P_WR == 26) A` → golden emits NO `gen_scope_array`
at all), reproduced here for the second source and answered by the SAME chain
walk with no extra code.  r10vrgg6's residue R1 named `r3_gen_cond` as a cell
where the pristine base agreed with golden BY ACCIDENT on the typespec question;
on the ARM question it was wrong, and it is right now.

POSITIVE CONTROL for the same comparator, this pass's own cells: files=63
identical=30 **MOVERS=33** — a "0 movers" reading elsewhere is not the driver
failing to look.

## 3c. THE MEASUREMENT-ONLY LADDER

`r10ladder1`'s `ctladder` (NOT a judge) over Rggen/default: **rungs 94 → 92**,
`stop=FIXPOINT` on both sides, `escalated=0 nofield=0`.  The family census goes
19 families → 18 and **exactly one family moves**:

```
gen_scope|<rhs-null>|MISSING-OURS      2 -> 0
```

No other family moves a single rung.

## 4. THE IMPLEMENTATION — 3 files, 169 inserted lines, no new emission machinery

| where | what |
|---|---|
| `include/UhdmExporter.h` | `funcParamCallSeen9` (the design-wide cost gate), `funcParamUnvalued9` (per-parameter memo + recursion guard), two declarations |
| `src/ParamEmit.cpp` | `callArgOutsideEvalRepertoire`, `srlgParamCallUnvalued` (the law), `srlgGenIfCondUnvalued` (the condition scan); one line inside `computeCompoundWriteBack`'s existing parameter-initializer walk sets the gate |
| `src/ModuleEmit.cpp` | `genIfUnitMisevalFalse` admits the new source (its early-out and its per-arm miseval test) and gains the env-gated `[genif7]` measurement print |

**Nothing else was needed.**  The `GenIfPick::Skip` / `::Emit` consumer at
`ModuleEmit.cpp` ~15700 already emits an UNINSTANTIATED arm through `emitBlock`
and skips the slang-taken one, so items (a) and (b) of the brief are the SAME two
lines of existing machinery; skipping the `if` arm removes the nested
`module_inst` and everything under it because emission is a tree walk.  The
slang AST is untouched, so every value the r10rgg2/r10rgg5 laws compute from the
instance list (including the shared 400-bit width) is unchanged.

## 5. THE COST GATE, and why it is exact enough

`srlgGenIfCondUnvalued` resolves identifiers, and `lookupName` forces lazy
elaboration — the trap the `srlgMisevalSyntax` cost guard records (an unguarded
version ran BlackBePipeInt out of 10 GB).  It therefore runs only behind
`funcParamCallSeen9`, set from the walk `computeCompoundWriteBack` already
performs over every definition's parameter initializers.  A design in which no
parameter initializer calls a user function cannot hold such a parameter, so the
gate cannot hide a firing site — except for a parameter declared in a PACKAGE or
a generate scope, which that walk does not reach (residue R4).

## 6. THE NEW R0 — the next pass's head, characterized

```
LHS golden: constant , line 55:14-55:16   BIN:1  vpiSize 1  vpiConstType 3
              < cont_assign @rggen_adapter_common.sv:40:11-40:53
RHS ours  : func_call (pre_decode) @40:27-40:53
              vpiArgument hier_path (bus_if.address)
```

`assign inside_range = pre_decode(bus_if.address);` — `pre_decode`'s body is
`if (PRE_DECODE) ... else return '1;` and `PRE_DECODE` is 0, so the function is
constant **regardless of its non-constant argument**.  Surelog's netlist
elaboration folds the cont-assign Rhs to that constant and the constant carries
the RETURN LITERAL'S OWN LOCATION (`55:14`, the `return '1;`) and width 1, not
the call site's.  Golden: 2 ELAB cont_assigns folded, the DEF-view one KEPT as a
`func_call`.  We keep the call in all three.  Family: a const-function call whose
value does not depend on its arguments, folded in the ELAB view only.

## 7. RANKED RESIDUES

* **R1 — the same valuelessness has a VALUE face we do not model.**
  `cells/x_argchain_n8`: golden keeps `NEXT = addup(RAW)`'s param_assign Rhs as
  an unfolded `func_call` because `RAW` has no value; **we fold it to a
  constant**.  This is § `elabUnitMisevalNoFold`'s rule one source over, and it
  is a VALUE law, not an arm law.  Corpus exposure: ZERO (Rggen's own `NEXT_N`
  Rhs already stays a call on both sides).  A pass that closes R1 should reuse
  `srlgParamCallUnvalued` as its predicate.
* **R2 — golden's 13 Rggen `func_call`s carrying a `vpiTypespec` in the OTHER
  view** (neither `allModules` nor `topModules`); we emit 0.  Carried from
  r10rgg6 R6, untouched, and it now sits behind the `pre_decode` head.
* **R3 — gen-scope localparam chains emit no ELAB `param_assign` calls at all**
  (r10vrgg6 R5).  Untouched.
* **R4 — the cost gate's reach.**  `funcParamCallSeen9` is set only from MODULE
  definitions' parameter initializers.  A generate-if reading a PACKAGE
  parameter (or a gen-scope localparam) whose initializer is a refused call
  would not fire.  NOT MEASURED — `cells/x_pkgfunc_n8` measures a package
  FUNCTION with a module parameter, which is a different face.  Closing it means
  widening the gate's walk, and it must not be done without its own boundary run.
* **R5 — the two SPAN-only typespec residues** in the reducer region
  (`logic_typespec 5:11:5:24` vs golden's `5:11:5:35`, `int_typespec 8:55:8:58`
  vs `3:13:3:16`, 14 objects each).  `Compare` reads no span, so they are
  invisible to the judge; they are named so a future byte-identity pass finds
  them already measured.

## 8. FILES

| file | what it is |
|---|---|
| `gen_grid.py` | writes all 63 cells (`cells/<cell>/dut.sv`) |
| `run_grid.sh` | REAL SURELOG + any number of slang binaries per cell; NODB / NOSLANG printed and COUNTED |
| `armscan.py` | WHICH ARM a database elaborated, per instance, both views; exits 3 on a dump with no instance |
| `score.py`, `verdict.py` | the three-side join and the order-blind FIXED/BROKEN/STILL/OK verdict |
| `dumptree.py` | the shared indent-tree parser for uhdm-dump output (containment edges only; `vpiParent` skipped) |
| `census7.py` | the per-instance shape census of `rggen_or_reducer` (the § 1 table) |
| `subtree7.py` | the object-kind census of each `g_reduce` gen_scope_array subtree |
| `sitescan.py` | enumerates every site the predicate fires at over a whole corpus, using verify_golden.py's OWN argv construction, with the PROBE binary |
| `gates.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `boundary.sh`, `rowheads.sh` | the gate legs, carried forward |
| `PREDICT.txt` | the prediction, filed from PRISTINE databases before the patched binary existed |
| `PREDICT_MOVERS.txt` | the mover set, BY NAME, filed before `byteverify.sh` ran |
| `GRID.md` | the measured grid, the law's clause-by-clause evidence, the refuted clause |
| `GATES.txt` | every gate leg's output, every mover named and attributed |
| `HEAD_R0_{BEFORE,AFTER}_default_Rggen.cmp` | the official `uhdm-cmp` head, both sides |
| `CENSUS.txt` | census7/subtree7 output for golden, base and patched |

Reproduce:

```sh
python3 gen_grid.py
./run_grid.sh /tmp/g <base-bin> base <pat-bin> pat
python3 score.py /tmp/g base pat > /tmp/score.txt && python3 verdict.py /tmp/score.txt
```
