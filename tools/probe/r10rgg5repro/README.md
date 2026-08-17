# r10rgg5 — § satArrArgFirstElem5: the corrupted evaluation's ARRAY, at the FIRST evaluating instance's width

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge.  BASE `39d8bb3`.  Target: `default:Rggen`'s official head —
rgg4's R0, the 400-bit `SUB_N_LIST` constant Surelog hands the INLINED
`get_next_n` call inside `logic [NEXT_N-1:0][WIDTH-1:0] next_data`'s range.

**RESULT.  The head is CLEARED.**  `rowheads.sh` (official `uhdm-cmp`, Rggen
default): **64 cmp lines / 1 head -> 17 / 1 head**, the head object moves off
`rggen_or_reducer.sv:64:58`, the ladder goes **61 -> 60 rungs FIXPOINT** with the
ONE family `constant|VpiDecompile|DIGITS-ONLY` 1 -> 0 and no other family moving a
single rung, and **all thirteen** of golden's `get_next_n` argument constants
become byte-identical to golden (census DEFICIT 26 -> 12, and the 12 are objects
we do not emit at all — a different family, § 6).

**Rggen does NOT pass `uhdm-cmp`, and this pass says so up front.**  Our tree
still elaborates the recursive `u_reducer` chain that Surelog's corrupted fold
never built (17 instances against 13) — slang folds `NEXT_N` CORRECTLY, so
`if (NEXT_N > 1)` is taken where Surelog could not evaluate it at all.  That is a
tree-shape divergence, not a field one, and no value law can close it.

---

## 1. WHAT THE HEAD ACTUALLY WAS — decoded from the golden database first

Golden, at every one of the 13 elaborated `rggen_or_reducer` instances, hands the
inlined `get_next_n` call a 400-bit `vpiBinaryConst` whose value is **4** (the two
adapter muxes, N=25 and N=20) or **2** (the eleven read-data muxes, N=2).  We
handed it the packed list our own fold computes (`4,4,4,4,4,2,3` at N=25).

Decoding golden's number was the whole pass:

* it is **NOT** the result of the outer evaluation, and **NOT** a truncation:
  it is **ELEMENT 0 ALONE** of `get_sub_n_list(N)`, every higher element zero;
* **element 0 is the one element the corrupted and the correct evaluations
  agree on**, because the first loop iteration indexes `list_index == 0`
  whatever the corrupted literal holds — so "element 0 only" needs no value
  model at all beyond slang's own fold;
* and its **width is not the instance's**.  Eleven of Rggen's thirteen
  instances are N=2 — `bit [1:0][15:0]`, 32 bits — and golden gives them
  **400**, the N=25 adapter mux's width.  Ours gave 32.

## 2. THE MECHANISM, transcribed then measured on 32 purpose-built cells

Both halves are the SAME write-back r10rgg2 named, one variable over.

`UHDM/templates/ExprEval.cpp::setValueInInstance`:

```cpp
rhsexp = reduceExpr(st->Rhs());   // for `list = '0` this IS the tree's literal
...                               // the element-write arm builds `lhsbinary`
if ((c->VpiSize() == -1) && (c->VpiConstType() == vpiBinaryConst)) {
    uint64_t size = ExprEval::size(lhsexp, ...);   // <- ONCE, per OBJECT
    c->VpiValue("BIN:" + bval); c->VpiDecompile(bval); c->VpiSize(size);
}
...
for (int32_t i = 0; i < size_rhs; i++)
    if (((index * size_rhs) + i) < si && ... )     // si = THAT shared width
        lhsbinary[(index * size_rhs) + i] = tobinary[i];   // else DROPPED
```

* `list = '0`'s literal becomes the array variable's value object, and its
  `VpiSize` is stamped by the **FIRST** evaluating instance and never re-stamped —
  so every later instance's array value string is that first width, and the
  element-write bound `si` is that width too.
* `list_index += 1`'s literal is § compoundLitWriteBackSat2's accumulator.  Once
  it has escaped `list`'s bound the write index is out of range from **iteration
  2 onward for ANY literal value at or past the element count**, which is what
  makes "element 0 alone" count-INDEPENDENT.

MEASURED, `run_grid.sh` over 32 cells, golden = real Surelog:

| clause | cells | result |
|---|---|---|
| the shared width is the FIRST instance's | 26 with >= 2 instances | **26/26**, including the three orders that separate "first" from "widest" (`a4_2_25` -> 32, `a5_20_25` -> 320, `a3_25_2` -> 400) |
| only element 0 survives in the saturated regime | 20 escaping instances | **20/20**, no counterexample |
| element 0 = the FIRST index-0 write | 21 escaping instances where E0 != Z | 13 yes, **8 no** (§ 5) |

## 3. THE LAW

> **§ satArrArgFirstElem5.**  Inside § compoundLitWriteBackSat2's SATURATED
> regime — escape ∧ >= 2 elaborated instances ∧ the r10vrgg2 DEMAND GATE ∧ the
> `+=` fixpoint, **no new gate of its own** — the value an ELABORATED
> parameter-initializer `func_call` ARGUMENT receives for the escaping
> MULTIDIMENSIONAL packed-array parameter is the array a corrupted evaluation
> whose write index has ALREADY ESCAPED leaves behind: **element 0 alone**
> (the first loop iteration's write, i.e. the correctly-folded element 0), every
> higher element ZERO, rendered at the width of the **FIRST INSTANTIATED
> instance's** array — one shared width for every instance of the definition,
> zero-extended or left-truncated to it.  The instance's own FORMAL width does
> not re-stamp that constant.

## 4. THE IMPLEMENTATION — 3 files, one new gate-free pass, one consult

| where | what |
|---|---|
| `include/UhdmExporter.h` | `satArrArgVals` — per instance `ParameterSymbol` -> `{BIN digits, shared width}` |
| `src/ParamEmit.cpp` | `SrlgWriteBack::arrState()` (the replay's tracked arrays, already element-wise since r10rgg2) + `wbReturnedArraySym()` (the returned array, found STATICALLY because the corrupted replay never reaches the `return`) + a SECOND replay pass **inside** the existing saturated branch: one run per instance with the escaping literal PRE-SEEDED past any bound |
| `src/ExprEmit.cpp` | the consult at `elabParamArgFold`'s `packedDimCountE > 1` branch, and `satArrFold5` suppressing the formal-width re-stamp ~700 lines below |

The second replay is deliberately a SEPARATE pass over the same instance list:
r10rgg2's first pass, its literal state, its escape detection and its
`compoundWbLits` output are untouched, which is what makes the 612-read-position
rgg2 boundary come back byte-identical.

## 5. THE COUNT WALL, RESTATED HONESTLY

Element 0's VALUE is **count-dependent**, and this pass does not pretend
otherwise.  When the doubling literal finally reaches the uint64 fixpoint 0 the
index stops escaping, the loop RUNS TO COMPLETION with every write pinned at
index 0, and element 0 then holds the **LAST** index-0 write.  8 grid cells read
that way (`a2_25x2 u01`, `a5_20_25 u01`, `b6_13x2 u01`, `b8_21x2 u01`,
`b9_33x2 u00`+`u01`, `c6_33_25 u01`, `c7_25_33 u01`).  Four candidate
distinguishers were each killed by a cell (GRID.txt § 3) — including "the first
instance always gets the first write", which `b9_33x2 u00` refutes.  What decides
it is r10rgg2 § 2's demand count, PROVEN not source-derivable.

The pass ships the first-write half because:
* **ALL THIRTEEN Rggen instances are on that side**, and for N=2 and N=20 the two
  halves coincide, so only the N=25 head instance rests on the claim;
* on all 8 counterexample cells the BASE binary emitted the full multi-element
  list, which is neither answer — so nothing goes right -> wrong;
* `verdict.py` over the whole grid: **FIXED 52, BROKEN 0**, MOVED-WRONG 38
  (wrong -> differently wrong), STILL 23, OK 23.

## 6. THE NEW R0 — the next pass's head, characterized

```
LHS golden: <null>
RHS ours  : ref_typespec (work@rggen.u_block_0.u_adapter.u_adapter_common
                          .u_mux.g.u_reducer)   id 17063
   parent chain: func_call(get_sub_n_list) @62:47-62:61 < param_assign @62:33
                 < module_inst(u_reducer) @rggen_mux.sv:19:7 < gen_scope(g)
                 < module_inst(u_mux) < u_adapter_common < u_adapter < u_block_0
   vpiActual  : bit_typespec @36:56-36:59   (get_offset_list's `sub_n_list` formal)
```

We stamp `get_offset_list`'s FORMAL typespec onto the ELABORATED
`get_sub_n_list(N)` call (the § elabParamTsRebind clause in ExprEmit, whose
comment cites `FuncInModule`); **golden's elaborated copy carries no
`vpiTypespec` at all**, and its ARGUMENT is a folded `UINT:25` constant carrying
an `int_typespec` where ours is the same constant carrying the same ref — so the
`<lhs-null>` EXTRA-OURS rung is the whole divergence.  It is rung 2 of the base
ladder and rung 1 of the patched one; the ladder's
`<null>|<lhs-null>|EXTRA-OURS` family has **3** rungs, so the next pass has a
three-object target.  Distinguisher to chase: `FuncInModule` is a DEF-view
single-instance shape while Rggen's is an ELABORATED instance copy whose
referenced parameter's own Rhs stayed symbolic.

## 7. FILES

| file | what it is |
|---|---|
| `gen_grid.py` | writes all 32 cells (`<cell>/top_<cell>.sv`) |
| `argconst.py` | pulls EVERY `get_next_n` call's argument out of a uhdm-dump (kind, size, constType, decompile, instance path); exits 3 on a dump with zero calls |
| `run_grid.sh` | golden (real Surelog) + each binary, per cell |
| `score.py` | the per-(cell, instance, site) join of the three sides |
| `verdict.py` | the order-blind FIXED / BROKEN / STILL / MOVED-WRONG classification |
| `rggencensus5.sh` | the golden-vs-ours census of Rggen's own 26 argument constants |
| `boundary.sh` | re-runs r10rgg2's four write-back grids + `real/` + `vsweep` + r10vrgg2's 40-cell demand grid, from PRIVATE COPIES |
| `foldbnd.sh` | the fold-law family boundary (47 earl49/51/52/55 sources, whole-dump byte compare, positive control) |
| `gates.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh` | the five gate legs, carried forward |
| `GRID.txt` | the measured tables, the law, the four refuted distinguishers, 5 ranked residues |
| `GRID.raw`, `SCORE.txt`, `VERDICT.txt` | the grid's raw output, the join, the verdict |
| `GATES.txt` | every gate leg's output, every mover named and attributed |
| `CENSUS_PREDICT5.txt` | the prediction, filed BEFORE the patched binary was measured |
| `HEAD_R0_{BEFORE,AFTER}_default_Rggen.cmp` | the official `uhdm-cmp` head, both sides |
| `ladder_{BEFORE,AFTER}_default_Rggen.txt` | the measurement-only ladders |
| `BOUNDARY.txt`, `FOLDBND.txt`, `RGGEN_DELTA.txt` | boundary output and the 134-line-side Rggen delta |

Reproduce:

```sh
python3 gen_grid.py
BASE=<base> PAT=<patched> ./run_grid.sh /tmp/grid $(python3 -c \
  "import gen_grid; print(' '.join(c for c,_ in gen_grid.CELLS))") > GRID.raw
python3 score.py GRID.raw > SCORE.txt && python3 verdict.py SCORE.txt
```

## 8. GUARDS THESE DRIVERS CARRY (each an ops trap this pass paid for)

* `argconst.py` prints a line for EVERY call, marks an unparsed argument `??` and
  COUNTS it, and **exits 3 on a dump with no call at all** — a vanished object
  reads as a MISSING LINE, never as agreement.
* Its first version read the argument's fields at the WRONG INDENT and printed
  `size=None ct=None dec=-` for all 27 golden calls.  The bug was caught because
  the census printed `None` where the head cmp had printed 400: **an instrument
  that reports nothing must not be read as reporting agreement.**
* `score.py` reports a key present on one side only, and `verdict.py` splits it
  into GOLD-ONLY (we emit no object) and OURS-ONLY (no golden object) rather than
  lumping shape divergences into the value verdict.
* `boundary.sh`'s first `rgg2lit` arm used a KEY JOIN over `cells.py` rows.
  `cells.py` prints SEVERAL rows per position, so the join cross-producted them
  and manufactured 100+ phantom `BASE!=PAT` rows on grids whose whole dumps are
  byte-identical.  It is a straight row-list DIFF now and the reason is written
  at the code.
* `boundary.sh` (rgg2byte) and `foldbnd.sh` both carry POSITIVE CONTROLS
  (12/12 and 47/47 flagged), so a "0 movers" reading is not the comparator
  failing to look.
* `byteverify.sh` keeps both negative controls (954/955 and 1+the real movers).
* THE SCOREBOARD MOVER WAS NOT ATTRIBUTED BY ARGUMENT.  The base binary alone,
  run three times on the same test, produced three different md5s — one of them
  byte-identical to the patched database.  See GATES.txt gate 5.
