# vrgg10 — ADVERSARIAL VERIFICATION of r10rgg10 (§ genLpPortConnRead10)

**BASE `66f9c73`.** Worktrees `/tmp/wt_vrgg10` (patched, then fixed) and
`/tmp/wt_vrgg10pris` (pristine). `results/*.csv` READ ONLY and untouched.
Measurement-only directory; the official `uhdm-cmp` remains the sole judge.

## VERDICT

**ACCEPT the law, REJECT the shipped gate — one clause of the rule was
missing and the patch was WRONG where the PRISTINE BASE WAS RIGHT on legal
SystemVerilog.** Fixed here, gated, shipped as `/tmp/r10rgg10.verified.patch`.

Every headline number in the r10rgg10 report reproduces BIT-FOR-BIT
(`GATES.txt`), including both binary md5s, the 76→36 head, the 0/1358 and
0/956 row gates, the two movers and the database-level prediction.

## THE DEFECT — 12 pristine-right → patched-wrong cells, all legal SV

The patch counted a SELECT of the localparam **anywhere** inside a port
connection. Golden does not: inside a **USER function/task call argument** the
rewrite fires only when the argument **IS** the select (or is another such
call). Wrap it in anything and the declaration typespec survives.

| port connection actual | golden | pristine base | r10rgg10 patch | verified fix |
|---|---|---|---|---|
| `f8(IV[3:0])`               | BARE | decl | BARE | BARE |
| `h2(8'h0, IV[3:0])`         | BARE | decl | BARE | BARE |
| `f8(g8(IV[3:0]))`           | BARE | decl | BARE | BARE |
| `8'(f8(IV[3:0]))`           | BARE | decl | BARE | BARE |
| `$clog2({4'h0,IV[3:0]})`    | BARE | decl | BARE | BARE |
| `$bits(IV[3:0])` / `$signed(IV[3:0])` | BARE | decl | BARE | BARE |
| **`f8({4'h0,IV[3:0]})`**    | **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8(8'(IV[3:0]))`**       | **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8(IV[3:0] + 1)`**       | **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8(~IV[3:0])`**          | **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8(1'b1?IV[3:0]:4'h0)`** | **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8({2{IV[3:0]}})`**      | **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`h2(8'h0,{4'h0,IV[3:0]})`**| **decl**| **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8(g8({4'h0,IV[3:0]}))`**| **decl** | **decl (RIGHT)** | **BARE (WRONG)** | decl |
| **`f8({4'h0,{2'h0,IV[1:0]}})`**| **decl**|**decl (RIGHT)**| **BARE (WRONG)** | decl |

("BARE" = golden's LOC-LESS `logic_typespec` with bare `UINT:` bounds;
"decl" = the declaration's located `bit_typespec`.  Full 4-column table with
every cell: `CALLARG_LAW.txt`.)

A **SYSTEM** call does not block — its operands compile in place.  The
r10rgg10 report's stated reason for its own `portcast` cell ("an EXPLICIT size
cast is golden-LOCATED") is **REFUTED**: `8'(IV[3:0])`, `8'({4'h0,IV[3:0]})`
and `8'(f8(IV[3:0]))` are all golden-BARE.  The real discriminator on a cast is
BARE NAME vs SELECT, not the cast.

## THE FIX — § genLpCallArgSelBlocks10v

`src/ModuleEmit.cpp`, inside r10rgg10's own arm: the flat
`ElementSelect`/`RangeSelect` visitor is replaced by a walker that intercepts
`CallExpression`.  For a **user** call it inspects each argument directly —
counting it only if the argument (implicit conversions stripped) IS a select of
the parameter, recursing only into further calls — and never descends into a
wrapped argument.  For a **system** call it descends normally.  Everything
outside a call is unchanged.

## HOW IT WAS FOUND (the adversarial grids)

Four independent grids, 188 cells, compiled with Surelog AND all three binaries,
scored two ways — a **depth-keyed identity census** of the head's own
Compare-visible field (`pacensusv.py`: the ELAB `param_assign` Rhs constant's
`ref_typespec` Actual, keyed on the Lhs parameter) and a **sectioned
whole-dump path-normalised multiset diff** (`dumpcensusv.py`), plus the
official `uhdm-cmp` per cell.

* **gridv** (145 cells): read kind x declared type x scope x initializer x
  overrides.  Types: bit/logic/reg/bit1/int/integer/byte/shortint/longint/
  untyped/signed/unsigned/[N-1:0]/2-D packed/3-D packed/[0:7]/[3:1]/unpacked/
  typedef/typedef-of-typedef/enum/packed struct/packed union/real/string/time/
  `parameter`.  Scopes: module body, if-gen, for-gen, case-gen, nested,
  unnamed, else-branch, child module x1/x2/x3, interface, program, package,
  `$unit`.  Initializers: sized/unsized/bin/oct/dec/negative/x/z/concat/
  replication/cast/`$clog2`/param-expr/function call.  Overrides: `#()`
  width, `#()` value, `defparam`, generate condition, for-body.
  **67 FIXED, 1 BROKEN (`f1__portcallsel`).**
* **gridv6/gridv7** (43 cells): the call/cast/override neighbourhood — this is
  where the clause was pinned.  **11 more BROKEN under the patch.**
* **gridv8** (10 cells): robustness — a module NEVER instantiated (DEF view
  only), 4-deep gen nesting, recursive instantiation, instance arrays and
  2-D instance arrays, an interface instance in the scope, an instance with an
  interface port, an interface with parameters and a port, `bind`, an instance
  array whose RANGE reads the localparam, 8-iteration for-gen.
  **0 breaks, 0 crashes, 0 asymmetries.**

With the fix: **0 BROKEN over all 188 cells**, FIXED counts unchanged or
higher.

## RESIDUES (measured here, none introduced here, ranked)

1. **R1 (carried, biggest)** module-body scope: golden gives the bare rewrite
   to a module-body parameter read by a plain port connection; we do not.
2. **R-new/a — a SELECT in a PARAMETER OVERRIDE is golden-BARE.**
   `#(.W(IV[3:0]))`, `#(.W({4'h0,IV[3:0]}))` and `#(.W(f8(IV[3:0])))` are all
   golden-BARE while a bare-name override `#(.W(IV))` is golden-declaration.
   The r10rgg10 law says "never its parameter overrides" — true for the bare
   name, FALSE for a select.  Under-fire, so safe; unfixed here deliberately
   (this pass's brief is the port-connection clause).
3. **R-new/b — the instance ARRAY RANGE is a read.** `sink u [IV[1:0]:0] (...)`
   is golden-BARE; we give the declaration typespec.
4. **R-new/c — a bare name as a user-call argument takes a THIRD outcome.**
   `.i_value(f8(IV))` and `assign w = f8(IV)` give golden the FUNCTION's own
   located `logic_typespec`, neither the declaration nor the bare clone.
   Both binaries are wrong; pre-existing.
5. **R-new/d — a TYPEDEF-named ranged localparam never gets the rewrite.**
   `typedef bit [7:0] t; localparam t IV` keeps golden's named `bit_typespec
   (t)`; we emit an `int_typespec` (pre-existing, unrelated to this law).
6. **R2 (carried)** the CONT-ASSIGN scan's own over-fires: `assign w = f8({4'h0,
   IV[3:0]})` is golden-declaration and the PRISTINE base already binds the
   bare clone.  The call-argument clause proved here applies to the CA scan too
   and would fix it; left alone because it is pre-existing and out of this
   pass's surface.
7. **R0 (carried)** the new `default:Rggen` head — the port actual's own folded
   constant (`HEX:ab sz8 ct5` vs our `UINT:171 sz64 ct9`).  Unchanged by the fix.

## REPRODUCE

```sh
python3 gen_gridv.py  /tmp/vrgg10_grid    # + gen_gridv6/7/8.py
ls -d /tmp/vrgg10_grid/*/ | xargs -P 3 -I{} ./cellv.sh {} <base-bin> <new-bin>
python3 pacensusv.py   /tmp/vrgg10_grid   # depth-keyed identity census
python3 dumpcensusv.py /tmp/vrgg10_grid   # whole-dump multiset census
```
