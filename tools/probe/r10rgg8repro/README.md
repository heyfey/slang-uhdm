# r10rgg8 — § srlgUnvaluedActualLitRetFold8: a cont-assign call whose value does not depend on its argument folds to the RETURN LITERAL

**MEASUREMENT-ONLY directory.** The official `uhdm-cmp` remains the sole
acceptance judge. **BASE `f3c36d9`.** `results/*.csv` was READ ONLY and is
untouched. **Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS
CONVERTED** — this pass says so up front.

Target: `default:Rggen`'s official head after r10rgg7 (66 cmp lines, 1 head) —
golden folds `assign inside_range = pre_decode(bus_if.address);`
(`rggen_adapter_common.sv:40`) to ONE constant `BIN:1 vpiSize 1` whose LOCATION
is the callee's `return '1;` at **55:14**, at both ELAB instances, and keeps the
call in the DEF view. We kept the call in all three.

**RESULT. THE `pre_decode` HEAD IS CLEARED and the whole `cont_assign` surface of
Rggen is now two rows from golden.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): **66 cmp lines / 1 head →
  122 / 1 head**, and the head object moves to a DIFFERENT FAMILY entirely (a
  constant-predicate ternary — see § 6). **Read the line count correctly: it is
  the SIZE OF THE HEAD OBJECT'S SUBTREE, never a distance.** The new head's RHS
  is a three-operand `operation` with a `{WORDS{...}}` replication under it, so
  the count GOES UP while the disagreement moves ON.
* The cont_assign census over the WHOLE Rggen database (7620 cont_assigns, both
  views) goes from **4 differing rows → 2**, with **0 golden-only and 0
  ours-only**; golden-vs-golden calibrates to **0**.
* The measurement-only ladder: **rungs 92 → 90**, `stop=FIXPOINT` on both sides,
  and **exactly one family moves** (`constant|VpiType|KIND:constant>func_call`
  2 → 0).
* Corpus: **uhdm2rtlil 0 movers over 1358 databases; surelog 2 movers over 956 —
  `default/Rggen` (predicted by name before the gate ran) and
  `default/Scoreboard`, the documented ~50/50 COIN, which `attrib8.sh` shows
  differs between TWO RUNS OF THE SAME BASE BINARY while base and patched are
  BYTE-IDENTICAL on it.** 0 differing ROWS on either corpus, either mode,
  against the committed baselines AND against my own base.
* The 129-cell golden grid: **FIXED 69, OK 754, BROKEN 0, STILL 43.**

---

## 1. THE HEAD, decoded from the GOLDEN DATABASE FIRST

```
LHS golden: constant , line 55:14-55:16   BIN:1  vpiSize 1  vpiConstType 3
              < cont_assign @rggen_adapter_common.sv:40:11-40:53
RHS ours  : func_call (pre_decode) @40:27-40:53
              vpiArgument hier_path (bus_if.address)
```

`cacensus` is a census of EVERY `cont_assign` in the database — DEF
(`uhdmallModules` + `uhdmallInterfaces`) and ELAB (`uhdmtopModules`) — keyed
`(view, instance path, line:col, Lhs name)` and reading only shapes and the
value fields `Compare` reads. Calibrated golden-vs-golden FIRST: **0 differing
rows**. Then:

| | golden vs BASE | golden vs PATCHED |
|---|---|---|
| rows compared | 7620 | 7620 |
| differing | **4** | **2** |
| golden-only / ours-only | 0 / 0 | 0 / 0 |

and the four are two families, not one:

```
ELAB …u_block_0.u_adapter.u_adapter_common  40:11 inside_range
ELAB …u_block_1.u_adapter.u_adapter_common  40:11 inside_range
        golden constant(ct=3,sz=1,BIN:1,dec=1)@55:14   ours func_call(pre_decode)
ELAB …u_block_0.g_register_2.u_register.u_register_common 68:11 write_data
ELAB …u_block_0.g_register_4.u_register.u_register_common 68:11 write_data
        golden constant(ct=7,sz=64,INT:0,dec=0)@0:0     ours operation(op=32,n=3)
```

**The census decided the pass before any code was written**: the law had to move
exactly the first pair and nothing else, and the second pair was declared the
NEXT head up front. It is. The DEF-view row for the same source line
(`work@rggen_adapter_common 40:11`) is a `func_call` on BOTH sides already —
so the DEF half needed no code at all.

## 2. THE LAW

> **§ srlgUnvaluedActualLitRetFold8.** Surelog's
> `UhdmWriter::writeCont_assign` reduces every ELABORATED `cont_assign` RHS it
> has not already simplified (`UhdmWriter.cpp`, the trailing
> `if (simplified == false)` arm — the same arm `§ ifaceDotEnumConstFold1`
> transcribed), and for a user function call that reduction is
> `ExprEval::evalFunc`, which **EXECUTES THE BODY**. An actual `evalFunc` cannot
> value simply leaves the formal unset — it is not an error — so a function whose
> **EXECUTED** path never reads that formal still returns, and the RHS is
> REPLACED by the returned literal's own object. The folded constant therefore
> carries **the RETURN LITERAL's source location**, not the call site's.
>
> Three clauses, each measured, none assumed:
>
> 1. **THE ARM IS PICKED FROM THE DECLARATION.** `writeCont_assign` passes the
>    module DEFINITION (`DesignComponent* mod`) as the value scope, so an
>    INSTANCE PARAMETER OVERRIDE NEVER REACHES THE REDUCTION. `PD = 0` overridden
>    to `1` still takes the `else` arm; `PD = 1` overridden to `0` still takes the
>    `if` arm; two instances of one definition with DIFFERENT overrides both get
>    the arm the DECLARATION names.
> 2. **THE ACTUAL'S SHAPE DECIDES WHETHER THE REDUCTION IS ATTEMPTED.**
>    `evalFunc` reduces every actual first, and a reduce that poisons
>    `invalidValue` discards the whole result even though the formal is never
>    read. A plain name, a constant, an operation/concat, a constant-indexed
>    select and a nested user call all pass. A hierarchical reference passes ONLY
>    when its base is an interface port carrying a **MODPORT** — which is exactly
>    Rggen's `rggen_bus_if.slave bus_if`. A plain interface port, a struct member,
>    a submodule net and a variable-indexed select all refuse.
> 3. **THE VALUE MUST COME OUT OF AN EXECUTED `return` OF A LITERAL, AND THE
>    LITERAL MUST NOT BE HEX.** `evalFunc` ends by masking the returned constant
>    to the return type's width via `get_value(invalidValue, c)`, and `get_value`
>    POISONS on a `HEX:`-encoded value: `8'h2a`, `4'h5`, `32'hdead` are the ONLY
>    literal forms golden refuses, and they refuse in all four return types
>    tested. `'1` / `'0` come out as the RETURN TYPE's width in BINARY form
>    (`logic` → `BIN:1` sz 1 decompile `1`), never as slang's size `-1`,
>    decompile `'1`.

Applied to Rggen:

```
parameter bit PRE_DECODE = 0;                        // the DECLARATION
assign inside_range = pre_decode(bus_if.address);    // bus_if is `rggen_bus_if.slave`
function automatic logic pre_decode(logic [ADDRESS_WIDTH-1:0] address);
  if (PRE_DECODE) begin ... return (address >= ...); end
  else            begin return '1; end               // <-- executed, reads nothing
endfunction
=> the ELAB RHS is the `'1` at 55:14, BIN:1, size 1 (the return type is `logic`),
   at BOTH elaborated instances; the DEF view keeps the call.
```

## 3. THE GRID — 129 cells against REAL SURELOG

`GRID.md` carries the whole table (and `GRID_TABLE.md` the raw per-cell join).
The results that shaped the predicate:

* **`f_override0` is the cell that forced clause 1.** Declaration `PD = 1`,
  instance `.PD(0)`: golden KEEPS the call. A predicate reading the instance value
  folds it. Its mirror `f_override1` (declaration 0, instance 1) golden FOLDS, and
  `f_split` folds BOTH of two instances whose overrides differ.
* **`h_intlhs` vs `h_mp_noports` isolated clause 2** to one token: identical
  source but `bus_t bus_if` vs `bus_t.slave bus_if`, and they split. The LHS shape
  is NOT the axis — `h_modport` drives an output port, `h_full` and
  `h_mp_noports` drive an internal `logic`, all three fold.
* **A 64-cell literal × return-type sub-grid decided clause 3.** Only the
  HEX-based forms refuse; `'1 '0 0 1 3 42 1'b1 8'd42 8'b101010 8'sd3 1'd0 2'b11`
  all fold; the eight `'1`/`'0` cells all assign to the SAME 32-bit net and come
  out at 1 / 8 / 32 / 1 bits, which is what proves the width is the RETURN TYPE's.
* **29 cells REFUSE on golden, and the patched binary refuses every one of
  them**: 12 hex-literal cells (`8'h2a`/`4'h5`/`32'hdead` x 4 return types), 5
  actual-shape refusals (`c_hierpath_actual`, `h_intlhs`, `h_ifparam`,
  `h_struct`, `h_submod`, `h_arr`), and the body refusals — the executed path
  reads the actual (`b_taken_reads`, `b_else_reads`, `f_pd1`, `f_override0`), no
  return on the executed path (`b_noelse`), recursion (`b_recursion`), a
  `localparam` in the body (`b_localparam`), a write outside the function
  (`b_sideeffect`), a returned module net (`b_read_modsig`), a select of a
  parameter (`b_read_param`), `$clog2(<unvalued>)` (`b_clog2_of_arg`).
  BROKEN = 0 is exactly this list holding.

## 4. THE NEAR-MISS — MY OWN FIRST PREDICATE BROKE FOUR `uhdm2rtlil` ROWS

This is the most important paragraph in this file. The first build of the law
reused the existing straight-line replay wholesale, and the replay models an
ACCUMULATOR body by keeping the pre-loop literal:

```
function [WIDTH-1:0] func_loop;      // uhdm2rtlil/test/function_loop
  input [WIDTH-1:0] x;
  begin
    func_loop = 0;                                     // <-- the replay stops here
    for (i=0;i<WIDTH;i=i+1) func_loop[i] = x[WIDTH-1-i];
  end
endfunction
assign out = func_loop(x);
```

Golden KEEPS that call. My first binary folded it to `UINT:0`, and did the same in
`func_forloop_onehot` (`encode = '0;` then a loop), `function_mixed` and
`many_functions` (`result = 0;` then a `case`, then `func_mixed = result;`).
`ct8rows.sh` caught all four: the row STATUS stayed `CMP_EQUAL` — because on
golden the DEF and ELAB `cont_assign` are the SAME OBJECT and `Compare`'s
`m_visited` short-circuit never looks at the ELAB copy — but the **dump column
went `match` → `differ` on 4 rows × 2 modes**. A status-only gate would have shipped
it. THE WHOLE ROW IS THE GATE.

Three clauses were added and the four rows returned to `match`:

* **the fold must come from an EXECUTED `return`** (`r.terminal`); an accumulator
  `f = <literal>` is refused;
* **a loop with no `return` POISONS** in the new territory — the replay does not
  iterate, so a loop that refines the return value would leave a WRONG literal
  standing;
* **an unmodelled statement that writes ANY name poisons**, not just one that
  writes the return variable — a `case` that refines a LOCAL which a later
  `return <local>;` reads would otherwise fold the stale pre-case value.

All three cost only residues (`b_fname_assign`, `b_loop_noret`, `b_case_param`
stay unfolded), and BROKEN went from 5 sites to 0 on the grid as well.

## 5. THE IMPLEMENTATION — 2 files, +476 lines, no new emission machinery

| where | what |
|---|---|
| `include/UhdmExporter.h` | `unvaluedFormals8` (the opt-in gate, null everywhere but one call site), `foldReplayStack8` (the recursion guard), `CallFold::unbased8`, two declarations |
| `src/ModuleEmit.cpp` | `parseSimpleIntLit8` + `srlgDefaultParamValue8` + `srlgCondValueFromDefaults8` (clause 1); the actual-shape gate `reducible8` / `modportBase8` at the ELAB cont-assign RHS site (clause 2); `constCallFold`'s unvalued-formal binding, `Conditional` arm, terminal-return / loop / unmodelled-write poisons, HEX refusal (clause 3); the unbased-unsized constant rewrite; an env-gated `[rgg8]` site print |

**Everything downstream already existed.** `constFnRet` — the `cfr.lit` path the
all-constant call fold has used since r10oth5 — emits the literal AT ITS OWN
SITE, which is precisely the `55:14` the head asks for; the only new emission
code is the four-line rewrite of an unbased-unsized constant to the return type's
width. Every new clause is guarded on `unvaluedFormals8`, which is set for the
duration of ONE `constCallFold` call at ONE site, so **no pre-existing fold law
changes shape** — proven by the 488-file boundary run over r10rgg1/2/5/6/7 +
r10vrgg2…7 (0 movers, 0 asymmetries) with a 77-mover positive control.

## 6. THE NEW R0 — the next pass's head, characterized

```
LHS golden: constant (NO location)  INT:0  vpiSize 64  vpiConstType 7
              < cont_assign @rggen_register_common.sv:68:11-68:78
RHS ours  : operation @68:29-68:78  vpiOpType 32 (vpiConditionOp)
              vpiOperand ref_obj (work@rggen_register_common.WRITABLE)
              vpiOperand operation (multi-concat {WORDS{register_if.write_data}})
              vpiOperand constant '0
```

`assign write_data[0] = (WRITABLE) ? {WORDS{register_if.write_data}} : '0;` —
`WRITABLE` is a parameter, 0 at these two instances, so golden's reducer takes
the `'0` arm and installs a **LOC-LESS** `INT:0` of the reducer's own 64-bit
width; we keep the ternary. Golden: 2 ELAB `cont_assign`s folded
(`u_block_0.g_register_2` and `g_register_4`), the DEF one and every other
instance kept as the operation. Family: **a cont-assign whose RHS is a ternary
with a CONSTANT predicate, folded to a loc-less constant in the ELAB view only.**
This pass's own grid already measured four more members of that same family
(`b_ternary`, `c_operand_call`, `d_paraminit`, `b_bits_of_arg` — all loc-less
`@0:0` on golden), so the next pass starts with its calibration done.

## 7. RANKED RESIDUES

* **R1 — the LOC-LESS half of this very mechanism.** When the replay bottoms out
  at an EXPRESSION rather than a literal (a concat, a parameter read, a ternary,
  `$bits(...) == 8`), golden still folds, to a LOC-LESS constant of the reducer's
  own width: cells `a_concat` (`BIN:1011` sz 4), `a_param` (`UINT:5` sz 32),
  `b_ternary`, `b_bits_of_arg`. We keep the call. This is the SAME family as the
  new R0 and should be closed with it.
* **R2 — the size/encoding rules for a SIZED literal return are only half
  modelled.** 15 grid cells fold on both sides with a different size or const
  type (`L_1d0_lg`: golden `UINT:0` sz 32, ours `DEC:0` sz 1; `L_2b11_lg`: golden
  truncates to `BIN:1` sz 1). Every one of them was ALREADY wrong on the base
  binary (base kept the call), so none is a regression; the rule is
  return-type-driven truncate-then-widen and is written out in `GRID.md § 4`.
* **R3 — a cont-assign inside a GENERATE scope does not fold** (`d_gen_ca`:
  golden folds, we keep the call). The gen-scope cont-assign emission is a
  different code path from `emitContAssigns`; the law was not wired into it and
  the corpus has no such site.
* **R4 — the nested-call unvalued binding only reaches ONE level.**
  `b_nested_call_arg` (`return g(address);` where `g` ignores its formal) golden
  folds; our nested `constCallFold` builds a fresh `env` and cannot see the outer
  one, so it refuses. `b_nested_call` (no argument) folds correctly.
* **R5 — two grid cells are unmeasurable on this side.** `b_outformal` (an
  `output` formal called from a cont-assign) and `e_classmethod` (a class method
  called from a cont-assign) are rejected by SLANG ITSELF, identically on base and
  patched — a pre-existing slang/Surelog divergence, counted by `run_grid.sh` as
  NOSLANG, outside this pass.
* **R6 — `funcParamCallSeen9`-style cost gating was NOT needed.** The new path
  runs only for a cont-assign RHS that IS a user call with a non-constant actual;
  the whole surelog sweep cost is unchanged within noise. Named so a future pass
  that widens the reach knows there is no guard here yet.
* **R7 — carried untouched from r10rgg7:** its R2 (golden's 13 Rggen `func_call`s
  carrying a `vpiTypespec` in the other view), R3 (gen-scope localparam chains
  emit no ELAB `param_assign` calls), R5 (the two SPAN-only typespec residues in
  the reducer region).

## 8. FILES

| file | what it is |
|---|---|
| `gen_grid.py` | writes ALL 129 cells (`cells/<cell>/dut.sv`); verified to reproduce the checked-in tree byte-identically |
| `run_grid.sh` | REAL SURELOG + any number of slang binaries per cell; NODB / NOSLANG printed and COUNTED |
| `gridscan.cpp` | per-site shape reader: cont_assign / param_assign / procedural assignment / port high-conn / var-decl init, both views, per instance path |
| `cacensus.cpp` | the whole-database cont_assign census of § 1 |
| `score.py` | the three-side join and the order-blind FIXED / BROKEN / STILL / OK verdict |
| `predict.py` | the candidate-site upper bound, read off PRISTINE base databases; no binary dispatched; fenced rows skipped by name-hash and counted |
| `sitescan.py` | every FIRING site over a corpus, re-running verify_golden.py's OWN recorded `slang:` argv with `SLANG_UHDM_RGG8_SITES=1`; candidate-filtered; fenced rows skipped and counted |
| `attrib8.sh` | order-blind attribution of a byteverify mover (runs the BASE binary TWICE) |
| `gates.sh`, `ct8rows.sh`, `byteverify.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `boundary.sh`, `rowheads.sh` | the gate legs, carried forward |
| `PREDICT.txt`, `PREDICT_MOVERS.txt` | the prediction and the mover set BY NAME, filed before the patched sweeps |
| `GRID.md`, `GRID_TABLE.md`, `SCORE.txt` | the measured grid, the law's clause-by-clause evidence, the refuted clauses |
| `GATES.txt` | every gate leg's output, every mover named and attributed |
| `CENSUS.txt` | the § 1 census, all three sides, with the golden-vs-golden calibration |
| `SITES_*.txt`, `CANDIDATES_*.txt` | firing sites and the pristine upper bound, per corpus |
| `BOUNDARY.txt`, `BOUNDARY_POSITIVE_CONTROL.txt` | the boundary run and its 77-mover positive control |
| `BYTEVERIFY_*.txt` | the mover gate, both corpora, with SELFCHECK |
| `HEAD_R0_{BEFORE,AFTER}_default_Rggen.cmp` | the official `uhdm-cmp` head, both sides |

Reproduce:

```sh
python3 gen_grid.py
g++ -O2 -std=c++17 gridscan.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10rgg8_gridscan
GRIDSCAN=/tmp/r10rgg8_gridscan ./run_grid.sh /tmp/g <base-bin> base <pat-bin> pat
python3 score.py /tmp/g base pat | tail -1
```
