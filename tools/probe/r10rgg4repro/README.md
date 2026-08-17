# r10rgg4 — § sizeDimOvrChain4: an interface-array size dimension is reduced through the OVERRIDE CHAIN, never through the leaf's declared type

**MEASUREMENT-ONLY directory.** The official `uhdm-cmp` remains the sole
acceptance judge; everything here measures declaration RANGE bounds against real
Surelog.

**`default:Rggen`'s head is CLEARED.** 50 cmp lines / 1 head -> 64 / 1 head
(deeper; `cmp` LINE COUNT IS HEAD DEPTH, never a distance). Two objects to
golden, zero away, and the whole 1.58M-line database delta is **18 dump
line-sides**.

---

## THE HEAD (R0 of the pass, cleared)

```
rggen_adapter_common.sv:18   rggen_register_if.host  register_if[REGISTERS]

LHS(golden): constant  sz=64  UINT:25  ct=9  dec "25"   NO typespec
RHS(ours)  : constant  sz=32  UINT:25  ct=9  dec "25"
             + vpiTypespec -> ref_typespec(work@rggen.u_block_0.u_adapter
                                           .u_adapter_common)
                           -> int_typespec @7:13-7:16
```

Both sides agree on the decompile and disagree on TWO things at once — the SIZE
and the PRESENCE of a typespec — which is why the brief called it two defects.
It is one law.

## THE DISTINGUISHER, VISIBLE IN GOLDEN BEFORE A LINE OF CODE

`rggen_apb_adapter` and `rggen_adapter_common` declare the SAME port at the SAME
line with the SAME parameter name, and golden gives them the SAME answer (64,
bare) — but we were already right on one and wrong on the other:

| golden scope | override reaching `REGISTERS` | golden | ours (pristine) |
|---|---|---|---|
| `u_block_0.u_adapter` | `.REGISTERS(25)` — a LITERAL | 64 UINT bare | 64 UINT bare ✔ |
| `u_block_0.u_adapter.u_adapter_common` | `.REGISTERS(REGISTERS)` — a REFERENCE | 64 UINT bare | **32 UINT + int_typespec** ✘ |

The pre-§ code had exactly one override arm and it only fired when
`emitSyntaxExpr` of the override syntax happened to yield a constant. A literal
does; a reference to the parent's own parameter does not, so the reference case
fell through to "clone this instance's own `param_assign` Rhs", which is the
DECLARATION-SITE value (`int` -> 32, typed).

**Golden never reads the declaration-site value for an overridden parameter.**

## THE LAW

> **§ sizeDimOvrChain4 — an ELABORATED interface-array port whose dimension is
> the SIZE form `[P]` with `P` a bare parameter reference takes its `0 : P-1`
> right-bound operand from Surelog's OVERRIDE-EXPRESSION reducer, not from the
> declaration-site {producer, `adjustSize`} pair that fills `P`'s own
> `param_assign`.**
>
> Consequences, both measured on every overridden cell of arms a/b/g/h:
> * the leaf parameter's DECLARED TYPE never narrows the bound, and
> * the bound carries **no `vpiTypespec` at all**.
>
> The chain is walked TRANSITIVELY — `#(.R(R))` hops into the parent's own `R`,
> which may itself be overridden — and the TERMINAL decides the shape:
>
> | terminal | size | const type |
> |---|---|---|
> | a NON-overridden parameter `Q` | `Q`'s declared-type width | `vpiUIntConst` |
> | an integer/vector literal or a concatenation | the literal object VERBATIM — except a DECIMAL-based one, re-encoded `INT` / `vpiIntConst` with a bare-decimal decompile | |
> | a SIGNED arithmetic operator (`+ - * / % **`, unary or binary) | 64 | `vpiIntConst` |
> | a comparison/shift/logical operator, a call, an explicit cast, a conditional | 64 | `vpiUIntConst` |
>
> **And the companion clause, on the NON-overridden side:** the reduced value
> carries `P`'s type link only for a parameter declared plain, SIGNED `int`.
> `integer`, `longint`, `shortint`, `byte`, `int unsigned` and `bit [7:0]` all
> reduce to a BARE constant. The pre-§ gate was `isPredefinedInteger()`, five
> types too wide.

## FOUR HYPOTHESES THE GRID KILLED BEFORE THE CODE WAS WRITTEN

| hypothesis | killed by |
|---|---|
| "the SIZE is the leaf parameter's declared width" | arm b's nine `_paramref` cells: `int`/`integer`/`longint`/`shortint`/`byte`/`bit[7:0]`/`logic[7:0]`/`int unsigned`/untyped ALL read **64** once overridden |
| "an overridden size dim is always 64" | `a6`/`a6b`/`a6c`: an override that REFERENCES a non-overridden parent parameter, a top localparam, or a package parameter reads **32** |
| "the typespec follows the value's origin" | arm b's `_noovr` column: five predefined-integer types with a 32/16/64/8-bit value and NO typespec; only plain `int` has one |
| "arithmetic folds are signed, so key on the operator" | `hd_cmp_sum` `(3>1)+5`: a `+` whose comparison operand makes the sum UNSIGNED, and golden encodes it `UINT` |

## WHAT MOVED

**One binary difference in the whole campaign corpus.** The byte verifier over
955 surelog databases and 1358 uhdm2rtlil databases reports **1 mover**:
`default/Rggen`. Its entire dump delta:

```
- |vpiSize:32                              (work@rggen.u_block_0.u_adapter.u_adapter_common)
+ |vpiSize:64
- |vpiTypespec: -> ref_typespec -> int_typespec        [7 lines removed]
- |vpiSize:32                              (work@rggen.u_block_1.u_adapter.u_adapter_common)
+ |vpiSize:64
- |vpiTypespec: -> ref_typespec -> int_typespec        [7 lines removed]
```

Both to golden. `rggencensus.sh` prints the golden-vs-ours census of all six
elaborated interface_array bounds in that design: **6/6 now identical to
golden**, DEFICIT 2 -> 0.

The ladder (`r10ladder1repro/ctladder`, measurement-only) attributes it the same
way — 63 rungs FIXPOINT -> 61, with the family census identical row for row
except `constant|VpiSize|INT:G>O`, which goes **2 -> 0**.

## THE IMPLEMENTATION

`src/ModuleEmit.cpp`, one file-local helper (`sizeDimOvrEnc4`) plus two edits
inside `fillSizeDimRange`'s fold block — the only site that receives a
`foldScope`, i.e. the ELABORATED interface_array port and nothing else. The
override chain is walked over slang's BOUND initializer
(`ParameterSymbol::getInitializer()`), which `ParameterBuilder` resolves in the
INSTANTIATING context, so a bare `#(.R(R))` reference resolves to the PARENT's
symbol without any scope plumbing. Unmodelled override shapes keep the pre-§
path verbatim; only the typespec drop is unconditional.

## FILES

| file | what it is |
|---|---|
| `gen_grid.py` | writes all 78 cells (`<cell>/dut.sv`) |
| `attrib.py` | pulls every RANGE-BOUND constant out of a uhdm-dump, one line per bound; exits 3 on an empty read |
| `run_grid.sh` | `[BASE=] [PAT=] ./run_grid.sh <cell>...` — golden + each binary, line by line |
| `score.py` | order-blind FIXED/BROKEN/STILL/OK/MISS join of the three sides |
| `census.py` | corpus-wide SOURCE prediction (which tests can move, by name) |
| `rggencensus.sh` | the golden-vs-ours census of Rggen's own six bounds |
| `boundary.sh` | re-runs the committed r10rgg3 (37 cells) + r10vrgg3 (52 cells) grids |
| `foldbnd.sh` | the fold-law family boundary: 47 earl49/51/52/55 sources, whole-dump byte compare, with a positive control |
| `gates.sh` | the five gate legs |
| `ct8rows.sh`, `byteverify.sh`, `canaries.sh` | carried forward verbatim |
| `GRID.txt` | the measured table, the law, and the five named residues |
| `GRID.raw` | `run_grid.sh`'s per-cell output for GOLD/BASE/PAT |
| `SCORE.txt` | `score.py`'s per-cell scoreboard |
| `CENSUS_PREDICT4.txt` | the source census |
| `PREDICT_R0.txt` | the prediction, filed BEFORE the byte verifier ran |
| `GATES.txt` | every gate leg's output |
| `LADDER.md` | the ladder family census, base vs patch, and the new head |

Reproduce:

```sh
python3 gen_grid.py
BASE=<base binary> PAT=<patched binary> ./run_grid.sh $(ls -d */ | tr -d /)
python3 score.py $(ls -d */ | tr -d /)
```

## GUARDS THESE DRIVERS CARRY

* `attrib.py` emits a line for EVERY bound of EVERY range and exits 3 on an
  empty read, so a vanished object reads as a MISSING LINE, never as agreement.
* `score.py` reports a key present on one side only as `MISS` and COUNTS it. Its
  first version keyed on the full site SPAN and turned ONE pre-existing DEF-view
  `array_typespec` column difference into 816 phantom `MISS` rows; the key is now
  normalised to the site's START LINE and the reason is written at the code.
* `run_grid.sh` prints `NO-GOLDEN` / `NO-DATABASE` and counts them.
* `census.py` counts the declarations it DROPPED as well as the ones it matched.
* `foldbnd.sh` has a POSITIVE control (`CTRL=1`) that cross-compares each patched
  dump with the WRONG source's pristine dump: 47/47 flagged, so a "0 movers"
  reading is not the comparator failing to look.
* `byteverify.sh` keeps both of its negative controls (`SELFCHECK`,
  `SELFCHECK1`): 954/955 and exactly 1+1.
* The `r10vrgg3repro` boundary was FIRST run through `score2.sh`, which scored
  `-1/N` for both binaries on all 52 cells because that driver does not BUILD the
  databases — `boundary.sh` documents it and `run.sh` (the official-`uhdm-cmp`
  driver) was used instead. **An arm agreeing is not an arm testing.**
