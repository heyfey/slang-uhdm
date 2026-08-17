# r10rgg3 — the Rggen head: an interface PORT VIEW's member ranges follow the RECEIVING module

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` remains the sole
acceptance judge; everything here measures declaration RANGE constants against
real Surelog.

## The head this pass took

`default:Rggen`, 36 cmp lines / 1 head at `rggen_register_if.sv:10:10-10:23`:

```
   L constant "15"  < range < logic_typespec < logic_var(address)
                    < interface_inst(register_if[0])@block_0.sv:148:0
                    < module_inst(u_adapter) < module_inst(u_block_0)
   R constant "7"
```

The brief's three candidate causes — Surelog not applying overrides to interface
ARRAYS, not applying POSITIONAL overrides, or applying them to the param listing
but not to member typespec ranges — are **all three refuted**.  The real cause is
a fourth thing, and it was visible in golden without writing a line of code:

| golden scope | `address` left range | why |
|---|---|---|
| `u_block_0.register_if[0]` (the REAL instance) | **7** | the positional override 8 IS applied |
| `u_block_0.u_adapter.register_if[0]` (port view) | **15** | `u_adapter`'s own `ADDRESS_WIDTH` = 16 |
| `u_block_1.register_if[0]` | **6** | block_1's override 7 |
| `u_block_1.apb_if` (port view of `rggen_apb_if #(16,32) apb_if[2]`) | **6** | block_1's own `ADDRESS_WIDTH` = 7 — NOT the connected 16, NOT the interface default 16 |
| `u_bridge.apb_if` | **15** | `rggen_apb_bridge`'s own `ADDRESS_WIDTH` = 16 |

`u_block_1.apb_if.paddr` is the site that decides it: the connected instance says
16 and the interface's declared default says 16, and golden says **6**.  Only the
RECEIVING module's own parameter produces 6.

The port view's own `parameter` object still reads the interface DEFAULT
(`work@rggen.u_block_1.apb_if.ADDRESS_WIDTH` is `UINT:16` in golden) while its
member range reads 6 — the two are computed by different paths, which is why the
residue was never visible from the parameter listing.

## The law

See `GRID.txt` for the 37-cell measured table and the four disambiguations.  In
one paragraph:

> A REFERENCE-STYLE interface PORT VIEW re-elaborates the interface DEFINITION
> under the RECEIVING module instance.  Every interface parameter named in a
> member declaration takes the value of the receiving module's own same-named
> **parameter or localparam** (its ELABORATED value) when one exists, and the
> interface's declared default otherwise; the substitution is TRANSITIVE through
> the interface's own parameter and localparam defaults.  The CONNECTED
> instance's overrides are never read.  The single exception is the HOME-LIKE
> cell — a MODPORT-qualified port reached by a NAMED port connection to a
> NON-ARRAY instance — which reads the connected instance.  An interface-ARRAY
> ELEMENT port view takes the rule unconditionally: none of the emitter's four
> "read the connected instance" exceptions reaches it.

Modules are unaffected (`i1_module_array_pos`, `n7_module_same_named`).

## Files

| file | what it is |
|---|---|
| `gen_grid.py` | writes all 37 cells (`<cell>/dut.sv`) |
| `ranges.py` | extracts `(scope.member -> left,right)` from a uhdm-dump; a member printing no decompile reads `-` and is never dropped |
| `run_grid.sh` | `[BASE=] [PAT=] ./run_grid.sh <cell>...` — golden + each binary, line by line |
| `score.sh` | the same, scored: agreeing range lines / measured range lines per cell |
| `census.py` | corpus-wide source PREDICTION (upper bound) for both clauses of the law |
| `GRID.txt` | the measured table, the law, and the two unclaimed residues |
| `GRID.raw` | `score.sh`'s per-cell output for BASE and PAT |

Reproduce:

```sh
python3 gen_grid.py
BASE=<base binary> PAT=<patched binary> ./score.sh $(ls -d */ | tr -d /)
```

## Guards these drivers carry

* a cell whose GOLDEN side measured NOTHING prints `NO-GOLDEN` and is COUNTED —
  a cell that measured nothing must never score as agreement;
* a binary that produced no database scores `NO-DATABASE`, also counted;
* `census.py` is a SOURCE scan and says so: it OVER-predicts (it does not check
  that the port view is reference-style, nor that the two candidate values
  differ), so it is an upper bound and the byte verifier is the ground truth.
