# r10v83 — the adversarial verification of r10earl83 (§ `elabConnWrittenCastFold83`)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's
report reproduces **bit for bit** from this agent's own builds, sweeps and
head logs. One defect was found by breaking the law on legal SV, fixed here
in one guarded block, and the whole battery re-run on the fixed binary.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `0df1393`, branch `auto5h`.** `results/*.csv` was **READ ONLY** and is
untouched — **NO ROW WAS CONVERTED**. slang was **NOT** patched.

---

## 1. What reproduced, independently

Three binaries, each built by this agent from a fresh worktree at `0df1393`
and frozen `chmod 555` before any sweep:

| | md5 |
|---|---|
| pristine `0df1393` | `62a546a2e309c01971d212d7cf31605d` |
| `0df1393` + `r10earl83.patch` | `41cf48fb2313b0b59f4a752457bb7efa` |
| + the r10v83 fix (**shipped**) | `d0ec27bdfa7134f0179e270cdd712f72` |

The first two are the implementer's md5s **exactly**. So are:

* the **four committed head logs** — `HEAD_BEFORE_Earlgrey_{default,testflags}.cmp`
  and `HEAD_AFTER_…` are **byte-identical** to this agent's own
  `rowheads.sh` output on its own sweeps;
* the head movement **58 → 240 (default) / 58 → 268 (testflags), one head
  each**, with every other named row's head log byte-identical;
* the four purpose-built arm tallies (`g1` 24/5/0/3, `g2` 40/6/0/21,
  `g3` 37/17/0/8, `g4` 1/1/0/0 — `SAME→SAME / WRONG→RIGHT / RIGHT→WRONG /
  WRONG→WRONG`), re-measured with the **fixed** binary;
* every gate in `GATES.r10earl83.txt`. This agent's own battery is
  `GATES.r10v83.txt`.

The **new head in both modes** is `flash_ctrl.sv:171`
`reg2hw.addr.q[2+:17]` — the R0 the implementer predicted, not a side effect.

### The head decode, checked against the source, not the write-up

`UHDM/templates/ExprEval.cpp:4074`'s `vpiCastOp` arm was read directly. The
`uhdminteger_typespec` branch does exactly what the law says —
`cast_to` from the typespec's own `VpiValue` (32 when it is empty),
`resize(oper, cast_to)`, `res = val0 & mask`, `UINT:<res>` /
`VpiSize = cast_to` / `vpiUIntConst`, no typespec and no decompile — and its
`oper_signed` test reads **the operand constant's own signed typespec**, which
is why an `8'sd9` operand takes the `INT:` + signed-`logic_typespec` branch and
a bare `0` does not. `mask = ((uint64_t)(1ULL << cast_to)) - 1ULL` is C++ UB at
`cast_to >= 64`; the law's refusal there is correct and was re-measured
(`64'(64'h…F)` golden `sz64 UINT:0`, and `63'(64'h…F)` golden
`sz63 UINT:9223372036854775807`, which the law DOES take and matches).

---

## 2. THE DEFECT — a fabricated constant value on legal SV

`v6_signwidth83.sv`, six new cells that no committed arm reached: an **unbased
decimal literal of 2**31 or more** as the operand of a size cast in an
ELABORATED port `High_conn`.

| written | golden | pristine | r10earl83 |
|---|---|---|---|
| `40'(4294967296)` | `constant sz40 UINT:4294967296` | `op67`, operand `UINT:4294967296` | `constant sz40` **`UINT:0`** |
| `40'(2147483648)` | `constant sz40 UINT:2147483648` | `op67`, operand `UINT:2147483648` | `constant sz40` **`UINT:1097364144128`** |

**Why.** slang types an UNBASED decimal literal as a 32-bit **signed** `int` —
that is precisely why the law needs its `unbasedDec83` escape at all (a bare
`0`, the head's own operand, reads back `isSigned()`). But the same escape lets
through a written value slang has already destroyed: `2147483648` arrives as the
32-bit pattern `0x80000000` and `as<uint64_t>()` sign-extends it
(`0xFF80000000` after the 40-bit mask = 1097364144128), and `4294967296`
arrives as `0`. Surelog's constant still carries the written value, so the
fold **wrote a number that is in neither the source nor golden**, replacing an
operand that had carried the right one. It also contradicts the law as
written (`VpiValue = "UINT:" + (value & ((1<<W)-1))`, *value* being the
literal's).

**THE FIX** (`src/ExprEmit.cpp`, inside the law's own block, +40 lines): take
the unbased-decimal escape **only when the written digits round-trip** —
`rawText(<the literal's syntax>)` with `_` stripped must equal
`std::to_string(*uv83)`. It can only ever REFUSE. Based literals are
untouched (they carry their own width; one wider than 64 bits already fails
`as<uint64_t>()` — `32'(65'h1_0000_0000_0000_0001)` is left alone).

**Measured after the fix**: `v6` `WRONG→OTHER` **2 → 0**, `WRONG→RIGHT`
unchanged at 4; **every other arm's tally is identical**, the implementer's
four arms included; and the fix moves **no corpus database at all** — the
verified binary's three surelog byte movers carry the **same md5s** as the
implementer binary's.

---

## 3. Breaking the law — what was tried and what held

Six new arms, scored 3-way against Surelog goldens over the union of the three
databases' written-cast spans. **`RIGHT→WRONG` is 0 on every one**
(`ARMS.r10v83.txt`).

| arm | what it holds | SAME→SAME | WRONG→RIGHT | **RIGHT→WRONG** |
|---|---|---:|---:|---:|
| `v1_shapes83.sv` | 24 CAST SHAPES as BARE ELAB High_conn actuals: `integer'(0)`, `int'(5)`, `byte'(300)` truncating, a typedef'd `bit[3:0]`, `shortint'(-1)`, `signed'`, `unsigned'`, a typedef'd `logic[11:0]`, `integer'(PARAM)`, `integer'(A+B)`, `int'($clog2(N))`, a cast of a cast, the three corpus shapes, `8'(8'sd9)`, `32'(1'bx)`, `integer'(7)`, an enum target, W=64, W=63, a cast in a string concat | 27 | 9 | **0** |
| `v2_ctx83.sv` | 15 CONTEXTS for one `W83'(0)`: bare actual, operation operand, user-call arg, system-call arg, part-select bound, bit-select index, cont_assign, nested cont_assign, `always_comb`, **case item**, instance-parameter actual, param init, gen-scope High_conn, declaration range bound, an interface instance | 18 | 4 | **0** |
| `v3_homes83.sv` | HOMES × INSTANCE COUNT: module scope ×1 and ×3, an INSTANCE ARRAY `[2:0]`, gen-for ×3, gen-if (both arms), for-in-if-in-for, an **interface instance's** port, and a second top instantiating the first | 9 | 14 | **0** |
| `v4_muststay83.sv` | THE MUST-STAY CONTROLS: buvm29's written cast over a stream (bare and nested, and a cast of a cast over a stream), uvm118's cast inside a string concat and `const'(<string var>)`, a compiler-inserted widening, a case item, a case expression — plus one positive control | 12 | 1 | **0** |
| `v5_span83.sv` | SPAN AND WHITESPACE: spaces inside the parens, `24 'h FFFFFF`, `24'h FFFFFF`, `32'h1234_5678`, a cast split across two lines, redundant parentheses, a space before the tick | 5 | 5 | **0** |
| `v6_signwidth83.sv` | SIGNEDNESS AND OPERAND WIDTH: unsized decimals at 2**32, 2**31 and 2**31−1, `'d5`, `'sd5`, `32'hFFFFFFFF`, `32'shFFFFFFFF`, `4'sb1`, `6'o17`, a 65-bit literal, `'1`, `'0` | 13 | 4 | **0** |

Independently confirmed, each on golden:

* **the DEF fence.** In `v1`/`v3`/`v5`, **every** `PORTPAR=ref_module` cell is
  `SAME→SAME`; not one DEF-listing cast moved. `v1`'s raw `o.rows` vs `q.rows`
  diff is exactly **9 changed cells, all `module_inst`**.
* **`callArgDepth == 0`** and **`!inPsRangeBound`** — `v2` K03 and K05 both
  unchanged, golden keeping the cast in both.
* **the interface instance is NOT covered** — `v3` H06 (`PORTPAR=interface_inst`)
  is the one cell where golden folds (`constant sz12 UINT:6`) and the law
  abstains. A residue, not a regression (R2 below).
* **buvm29 and uvm118 hold.** `v4`'s stream casts, string concat and `const'`
  cells are byte-unchanged, and the wide boundary re-ran **every**
  `r10uvm118repro`, `r10v118repro`, `r10buvm29repro` and `r10vbuvm29repro`
  arm: byte-identical in both views.
* **the official judge never grows.** golden-vs-ours `uhdm-cmp` lines drop on
  every arm (`v1` 13613→13379, `v2` 8347→8217, `v3` 9539→9175,
  `v4` 6275→6249, `v5` 4685→4529), heads stay 1.

`WRONG→OTHER` is **2 across all ten arms**, both the shape the implementer
already declared: the cast is a proper sub-expression of a constant-valued
expression that golden folds WHOLE and stamps at the cast's own span
(`v2` K02 `.a(W83'(0) | 64'h10)`, `g1` C2 `.a(integer'(0) + 64'd2)`). Neither
binary agrees there before or after; the census FAMILY is bare actuals only.

---

## 4. The Earlgrey movers, attributed object by object

`v83all.cpp` + `score83v.py` — a whole-database identity census, because a
span-keyed cast census is blind below its own slot. Golden from the cache path
named in each test's own `cmds.txt`.

* **default** 783,183 golden objects; ours 772,215 → 772,206.
  **TO-GOLDEN 12, AWAY 0.**
* **testflags** 1,061,095 golden; ours 1,482,133 → 1,482,115.
  **TO-GOLDEN 14, AWAY 1.**

Two corrections to the implementer's accounting, neither a defect:

1. **the family is nine folded operations, not six.** The census key
   `SPAN+CTX+PORTPAR` collapses the **two identical ELAB copies** each site has
   in testflags. Measured object counts: `operation OPT=67` at
   `flash_ctrl.sv:137` pristine 1→0 (default) and **2→0** (testflags);
   `pwrmgr_pkg.sv:156` 1→0 and **2→0**; `alert_handler.sv:87` 2→1 and **3→1**
   (the surviving one is the DEF listing, which golden also keeps). At
   `137:18-137:30` in testflags the verified database is now **exactly**
   golden's two objects.
2. **one more cell changes in testflags**: `constant '0` at
   `pwrmgr_pkg.sv:157:14-157:16` (`rstreqs: '0`, the member beside the folded
   cast in `PWR_PERI_DEFAULT`), `VpiSize` 64 → 16. It is an **orphan** — its
   parent walk ends at a `constant`, never at `design` — so `uhdm-cmp` never
   reaches it, and **golden holds neither form** (`g=0` for 64 and for 16).
   Every design-reachable row at that span (`PARAMINIT`, `PORTHC`, `PROCESS`)
   is byte-identical pristine vs verified.

`Scoreboard/default` is the documented ~50/50 order coin: ordered dump diff 92
lines, **path-normalised order-blind diff 0 lines**, head log byte-identical.

---

## 5. The one boundary cell that is not this law's, and the proof

The wide boundary on the **verified** binary reports one file the implementer's
binary did not: `r10buvm22repro/g22.sv`, both views, 12 dump lines.

**It cannot be the law.** `g22.sv` contains **zero** written casts (`'(`
appears 0 times in the file) and **zero** module instantiations, so neither
§ `elabConnWrittenCastFold83` nor the r10v83 fix — both inside
`ExpressionKind::Conversion`, both gated on `elabConnEmit21` and on
`effCastSyn->kind == CastExpression` — can execute while compiling it.

**What actually differs** is the right range bound our
`array_typespec` emitter gives `typedef C22 ka_cls_t[string];` (`g22.sv:70`):
a `vpiSubOp` over a constant whose value has no source-level meaning —
`22437337` from the pristine and implementer binaries, `22441433` from the
verified binary **and from the main-tree binary at `7bfb9707`**, three
unrelated landings later. The two values differ by exactly `0x1000`. It is
stable across runs, independent of the working directory and of the
environment block (so not ASLR, not the stack), and a semantically dead
code block of comparable size added to the pristine tree does **not** move it.
It is an **address-shaped garbage value read for an associative array's
`[string]` index dimension** — a pre-existing latent defect of the
array-typespec range emitter, judge-visible in principle, listed as R1 below.

**It touches neither corpus**: the verified binary's surelog movers are the
same three databases with the same md5s as the implementer binary's, and
`uhdm2rtlil` moves 0 of 1358.

---

## 6. Ranked residues

* **R1 — the associative-array `[string]` range bound is garbage.** Section 5.
  Our `array_typespec` for `typedef T name[string]` carries
  `[0 : <address-shaped number> - 1]`. It is deterministic per binary and
  therefore silently re-rolls on unrelated landings, which makes any wide
  boundary that includes `r10buvm22repro/g22.sv` a coin. Worth its own pass;
  until it is fixed, a boundary cell on that file must be attributed by
  reading the file, not by assuming the law.
* **R2 — an INTERFACE instance's port `High_conn` is not covered.**
  `v3_homes83.sv` H06: golden folds (`constant sz12 UINT:6`) and we keep the
  cast, because `elabConnEmit21` is only armed for the module-instance
  connection mint (`ModuleEmit.cpp:10062`). One arm cell, zero corpus cells.
  The cheapest extension of this law.
* **R3 — `'0` / `'1` operands.** `12'('1)` folds to `UINT:4095` and `12'('0)`
  to `UINT:0` in golden; the law refuses (the operand is not an
  `IntegerLiteral` with a written decimal or based form). `v6` Q11/Q12.
* **R4 — a cast in redundant parentheses is missed.** `v5` P06 `((W83'(6)))`:
  golden folds, our conversion arrives with a `logic_typespec` target and the
  predicate declines. Pre-existing shape difference, zero corpus cells.
* **R5 — the based-literal span strip is one space short.** `24'(24 'h FFFFFF)`:
  golden's object ends at `15:34`, ours at `15:35`, in the pristine binary as
  well as the patched one. Not judge-visible (Compare reads no span), but it
  means `basedLiteralSpaceCount` does not model the size-to-base gap.
* **R6 — the ≥64-bit cast width.** ExprEval's `mask = (1ULL << cast_to) - 1`
  is UB and x86 shifts modulo 64, so golden's `64'(64'h…F)` is `sz64 UINT:0`.
  The law's refusal is right; a future pass that wants those cells must encode
  `mask = (1ULL << (W % 64)) - 1` deliberately.
* **R7 — 14 symmetric `rc=139` elab-view probe segfaults** in the boundary
  (earl82's R6), unchanged in count and in file set.

---

## 7. Files

| | |
|---|---|
| `v1_shapes83.sv` … `v6_signwidth83.sv` | the six adversarial arms |
| `v83all.cpp` | the whole-database identity census (direct `.uhdm` reader, Compare-visible payload only) |
| `score83v.py` | its 3-way multiset scorer (`TO-GOLDEN` / `AWAY` / `STILL`) |
| `ARMS.r10v83.txt` | every arm's tally and every non-`SAME` cell |
| `CENSUS.r10v83.txt` | the Earlgrey census, both modes |
| `GATES.r10v83.txt` | this agent's own full gate battery |
| `BOUNDARY_WIDE.*` | the wide boundary on the verified binary |

Build the census with
`g++ -O2 -std=c++17 v83all.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o v83all`.
The arms are driven by `../r10earl83repro/arm83.sh` and scored by
`../r10earl83repro/score3_83.py`; the boundary by
`../r10earl83repro/vwide83.sh`.
