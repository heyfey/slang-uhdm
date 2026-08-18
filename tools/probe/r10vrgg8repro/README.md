# r10vrgg8 — ADVERSARIAL VERIFICATION of r10rgg8 (§ srlgUnvaluedActualLitRetFold8)

**VERDICT: ACCEPT WITH A PRODUCTION FIX.** Every headline number in the
implementer's report reproduces BIT-FOR-BIT from an independent build. The law
is real and the head move is real. But the shipped predicate was **wrong on
seventeen legal-SystemVerilog cells and SEGFAULTED on three more**, all of them
pristine-right → patched-wrong, none of them reachable from the two corpora —
so every gate the implementer ran was green while the binary was broken.
Eight fixes were made here; the verified binary is `BROKEN=0 CRASH=0` over
**206 golden cells** and keeps every one of the implementer's own numbers.

## 1. WHAT REPRODUCED, EXACTLY

| claim | implementer | this verification |
|---|---|---|
| base binary md5 | `ccf0476c397439cd36d208398d4fc306` | **same** |
| shipped patched md5 | `9d1b1f56b6a2a6bf2e2de83a43fc9236` | **same** |
| goldens base / patched / `/bin/false` | 23/0, 23/0, 0/23 | **same** |
| grid, implementer's 129 cells | FIXED 69, OK 754, BROKEN 0, STILL 43 | **same, cell for cell** |
| Rggen/default head | 66 → 122 cmp lines, 1 head | **same, and the new head file is BYTE-IDENTICAL to `HEAD_R0_AFTER`, same object id 353520** |
| cont_assign census | 7620 rows; g-vs-g 0, g-vs-base 4, g-vs-patched 2, 0 golden-only, 0 ours-only | **same** |
| u2r rows | 679/50/2 per mode, 0 differing rows | **same** |
| surelog rows | 0 differing over 1588, no row converted | **same** |
| byteverify | u2r 0/1358; surelog Rggen + the Scoreboard coin | **same; and `vattrib8.sh` re-ran the BASE binary twice: Scoreboard's two BASE runs differ (the coin), Rggen's do not** |
| firing sites | exactly one, `rggen_adapter_common.sv:40:27 → 55:14` | **same** |
| canaries / pins | all green, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |

## 2. WHAT BROKE — 17 WRONG CELLS AND 3 SEGFAULTS

`cells/` holds 77 new golden cells. Scored against **real Surelog 1.86** with
the implementer's own `gridscan`/`score.py`, the SHIPPED binary is
`BROKEN=17` and crashes on 3 (`vrungrid.sh` records each arm's rc, so a
segfault is its own category and can never read as agreement).

### 2a. THE SEGFAULT — the recursion guard never held

```cpp
frame8 = ReplayFrame8{&foldReplayStack8, *subp};   // shipped
```
This copy-assigns a **prvalue** whose destructor runs at the end of that very
statement and calls `st->erase(sub)`. The guard was erased the instant it was
taken, so a self-recursive callee re-entered `constCallFold` forever.

* `v8_recurse`, `v8_recurse_uncond` — base rc=0, **patched rc=139**.
* `v8_deadrec` — **the one that matters**: `if (PD) return '1; else return f(address);`
  instantiated `#(.PD(1))`. Perfectly legal, terminating SV — the recursive
  branch is DEAD at the only instance. Only a replay that reads the
  DECLARATION default (PD=0) walks into it, and only the shipped binary does.

`b_recursion` did not catch this because its condition (`address == 0`) reads a
formal, so it poisons before reaching the recursive call.

### 2b. THE ARM PICK read values Surelog never has (9 cells)

`srlgDefaultParamValue8` fell back to `ps.getValue()` for any parameter slang
does not flag `isOverridden()`. That value is the INSTANCE's whenever the
parameter DERIVES from an overridden one, or is retargeted by `defparam`:

| cell | declaration | instance | golden | shipped |
|---|---|---|---|---|
| `v8_lpderived` | `localparam int B = A;` (`A=1`) | `#(.A(0))` | KEEPS | folds |
| `v8_paramderived` | `parameter int B = A;` | `#(.A(0))` | KEEPS | folds |
| `v8_deriv2` | `B = A; C = B;` | `#(.A(0))` | KEEPS | folds |
| `v8_lpderived_inv` | `A = 0; localparam B = A;` | `#(.A(1))` | KEEPS | folds |
| `v8_defparam` | `parameter int A = 1;` | `defparam u0.A = 0;` | KEEPS | folds |

and then the decisive pair, with **no override anywhere**:

| cell | declaration | golden | shipped |
|---|---|---|---|
| `v8_lparm_derived` | `A = 0; localparam int B = A;` | **KEEPS** | folds |
| `v8_parm_expr` | `parameter int A = 1 - 1;` | **KEEPS** | folds |
| `v8_lparm_lit` | `localparam int B = 0;` | **FOLDS** | folds |

It is **not the override** that decides — it is whether the DECLARATION wrote a
simple literal. The shipped law's own clause 1 ("the arm is picked from the
declaration") was right; its implementation read a computed value instead.

And the literal must be **BARE**. One module, one changed token:

| default | golden | | default | golden |
|---|---|---|---|---|
| `bit A = 0` | FOLDS | | `bit A = 1'b0` | KEEPS |
| `byte A = 0` | FOLDS | | `int A = 32'd0` | KEEPS |
| `longint A = 0` | FOLDS | | `longint A = 64'd0` | KEEPS |
| | | | `int A = 4'h0` | KEEPS |
| | | | `int A = '0` | KEEPS |

The declared TYPE is irrelevant; the sizing is everything. `64'd0` and `4'h0`
were pristine-right → patched-wrong under the shipped parser, which accepted
`'0`, `'1` and any b/d/o-based form. Rggen's own site is
`parameter bit PRE_DECODE = 0` — bare — so the head survives the tightening.

### 2c. THE CONDITION EVALUATOR was arithmetic Surelog does not do (4 cells)

| cell | condition | shipped uint64 | SV | golden |
|---|---|---|---|---|
| `v8_signedcond` | `(A - 1) < 0`, `A=0` | false | **TRUE** | KEEPS |
| `v8_widthcond` | `(A + 2'd1)`, `A=2'd3` | 4 → true | **0** | KEEPS |
| `v8_cond_eqlit` | `A == 3`, `A=2` | false | false | **KEEPS** |
| `v8_cond_addlit` | `(A+1) == 3`, `A=2` | true | true | **KEEPS** |

The first two are plain semantic bugs (unsigned 64-bit arithmetic where SV is
signed and width-limited). The last two are the decisive ones: the arithmetic
**agrees** with SystemVerilog and golden still keeps the call — an operator in
the condition is simply outside what Surelog's reduction accepts here. (It does
grant some: `v8_shiftcond` and `v8_divcond` fold on golden. Those are left as
residues rather than guessed at.)

### 2d. THE CALLEE'S SHAPE (2 cells)

`v8_ctx_iffunc` (`bus_if.pre(bus_if.address)`, a modport `import`) and
`v8_fn_in_genblk` (`g.f(a)`) are **`hier_path` objects on golden, not
`func_call`s at all**. Base emitted golden's hier_path; the shipped patch
replaced it with a folded constant. A package call `p::pf(a)` carries `::`, not
`.`, and folds correctly (`v8_ctx_pkgfn_arg`).

### 2e. `'x` / `'z` — a four-state guard that never fired (2 cells)

```cpp
if (lv != logic_t(0) && lv != logic_t(1))   // shipped: NEVER TRUE for x/z
```
`logic_t::operator!=` is four-state; for `'x` it returns x, and
`explicit operator bool` on x is `!isUnknown() && value != 0` → **false**. So
`'x` and `'z` became fold bottoms, and the width rewrite
(`lv8 == logic_t(1) ? '1' : '0'`, four-state in the same way) turned both into a
silent `BIN:0`. `v8_xlit` was pristine-right → patched-wrong; `v8_zlit` turned
golden's `BIN:Z` into `BIN:0`.

### 2f. A LOOP WHOSE BOUND READS A PARAMETER (1 cell)

`b_loop_ret` (`for (int i = 0; i < 4; i++) return '1;`) FOLDS on golden.
`v8_loop_parambound`, the same body with `i < N`, **KEEPS** — the same refusal
`b_read_param` measured for a parameter read in the body. The shipped law folded
it from the first iteration.

## 3. THE EIGHT FIXES (production, all gated on `unvaluedFormals8`)

| # | what | cells it closes |
|---|---|---|
| F1 | set the replay guard's MEMBERS, never assign a temporary | the 3 segfaults |
| F2 | `srlgDefaultParamValue8` reads the DECLARATOR's own initializer text only; the `getValue()` fallback is GONE | 7 |
| F3 | `srlgCondValueFromDefaults8` keeps literal and bare-parameter LEAVES; every operator arm removed | 4 |
| F4 | a for-loop header that reads a name declared outside the subroutine poisons | 1 |
| F5 | `'x`/`'z` tested with `isUnknown()`, and the rewrite reads `.value` | 2 |
| F6 | the callee must be declared in THIS body / a package / `$unit`, **and** the call must be written as a plain (undotted) name | 2 |
| F7 | the unbased-unsized width rewrite requires an INTEGRAL return type | `v8_realret` (a wrong value, not a row regression) |
| F8 | `parseSimpleIntLit8` accepts a BARE UNSIZED DECIMAL and nothing else | 3 |

Every fix costs only residues: a refusal leaves the call standing, which is what
the base binary already did.

## 4. THE VERIFIED BINARY — FULL BATTERY

* build md5 `8e61361fa060105dce8566d84505f215` (base `ccf0476c397439cd36d208398d4fc306`)
* goldens **23/0**; `SLANG_UHDM=/bin/false` **0/23**
* grid, **206 cells** (129 implementer + 77 new): **FIXED 96, BROKEN 0, STILL 69, OK 1176, NOGOLD 4, CRASH 0**;
  implementer's 129 alone still **69 / 754 / 0 / 43**
* uhdm2rtlil: 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode;
  **0 differing rows** vs the committed baseline and vs my own base (1462 rows)
* surelog: **0 differing rows over 1588** vs the committed baseline and vs my own
  base; every per-mode status and dump histogram identical. **NO ROW CONVERTED**
* byteverify SELFCHECK=1: u2r 0 movers/1358; surelog **1 mover/956 —
  `default/Rggen`, PREDICTED BY NAME** in `PREDICT.txt` off pristine base
  databases before the sweep was scored
* boundary over rgg1/2/5/6/7 + vrgg2…7, fd-3 list, `</dev/null` children,
  PROCESSED asserted: see `BOUNDARY.txt`
* census: 7620 cont_assigns, golden-vs-golden 0, **golden-vs-verified 2**,
  0 golden-only, 0 ours-only — the residual is exactly the next head
* head: Rggen/default **66 → 122**, 1 head, byte-identical to the implementer's
* canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0`; pins SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`
* sitescan on the verified binary: **surelog rows-with-sites=1, distinct-sites=1**
  (`rggen_adapter_common.sv:40:27 → 55:14`), FENCED=8 skipped by name-hash;
  **u2r rows-with-sites=0**

## 5. FILES

| file | what |
|---|---|
| `cells/` | 77 new golden cells (arm pick, condition shapes, recursion, return types, actual shapes, contexts) |
| `vrungrid.sh` | grid runner that records EVERY arm's rc, so a SEGFAULT is its own category and a NODB cell still runs the slang arms |
| `vboundary.sh` | boundary with the list on **fd 3**, `</dev/null` children and a PROCESSED assertion |
| `vattrib8.sh` | order-blind mover attribution (runs the BASE binary twice) |
| `SCORE_shipped.txt`, `SCORE_fix.txt` | the three-side joins |
| `PREDICT.txt`, `CANDIDATES_*.txt` | the mover prediction and its pristine upper bound |
| `GATES.txt`, `BOUNDARY.txt` | every gate leg as run |
