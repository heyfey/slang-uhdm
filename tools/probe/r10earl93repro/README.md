# r10earl93 — § srlgSizeCastUbShiftMask93

**THE 64-BIT CAST-MASK WRAP.**  A size cast whose width is 64 or more does not
keep the operand's bits: Surelog's folded value is
`operand & ((1ULL << (W % 64)) - 1)`, because `UHDM`'s `ExprEval` computes the
mask with a C++ shift whose count is the FULL width — undefined behaviour at 64
and above, which x86-64 evaluates modulo 64.

BASE `5c6cea7`, branch `auto5h`.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; **every
tool in this directory is MEASUREMENT ONLY**.

---

## 1. THE HEAD, re-measured on this pass's OWN pristine build

`Earlgrey_0_1`, **both modes**, 64 cmp lines (32 stdout + 32 stderr), **1
head**, and the two modes' head logs are BYTE-IDENTICAL to each other:

```
prim_lfsr.sv:39   parameter logic [LfsrDw-1:0] DefaultSeed = LfsrDw'(1),
instance work@top_earlgrey.u_aes.aes_prng.aes_prng_lfsr
  (from lowrisc_ip_aes_0.6/rtl/aes_prng.sv:46, `.LfsrDw ( DATA_WIDTH )`
   with `localparam int unsigned DATA_WIDTH = 64`)

  LHS (golden)  constant 39:47-39:57  vpiDecompile 0  UINT:0  vpiSize 64
                vpiConstType 9  Typespec -> logic_typespec 39:13-39:31
  RHS (ours)    constant 39:47-39:57  vpiDecompile 1  UINT:1  vpiSize 64
                vpiConstType 9  Typespec -> logic_typespec 39:13-39:31
```

Every other field matches — span, size, const type, the ref_typespec's own
fullname and actual.  It is a `constant::Compare` VALUE cell inside a
`param_assign`, not a structural one.  `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp`
carry both logs.

---

## 2. THE DECODED MODEL

`UHDM templates/ExprEval.cpp:4074`, the `vpiCastOp` case.  The branch table,
read out of the source and then MEASURED cell by cell on real Surelog
(`g4_kind93.sv`, one localparam per row, operand `64'hFFFF_FFFF_FFFF_FFFF`):

| written target | ExprEval arm | golden's fold | ours (pristine) |
|---|---|---|---|
| `N'` / `PARAM'` (a SIZE cast) | `uhdminteger_typespec` — **the mask arm** | `UINT:<v & mask>` at `vpiSize = N` | `UINT:<v>` |
| `integer'` | same arm, `cast_to` defaults to 32 | `UINT:4294967295` size 32 | keeps the operation |
| `int'` | `uhdmint_typespec` — no mask | `UINT:0` size 64 | keeps the operation |
| `longint'` | `uhdmlong_int_typespec` — no mask | `UINT:0` size 64 | keeps the operation |
| `shortint'` | `uhdmshort_int_typespec` — no mask | `UINT:0` size 16 | keeps the operation |
| `bit'` | `uhdmbit_typespec` — `& 1` | `BIN:1` size 1 | keeps the operation |
| an ENUM typedef | `uhdmenum_typespec` — no mask | `UINT:1` size 64 | `UINT:1` size 64 (agrees) |
| `byte'` / `logic'` / `time'` | **no arm at all** | keeps the cast | keeps the cast (agrees) |
| a vector TYPEDEF (`w64_t'`, `b64_t'`) | no arm | keeps the cast | folds (pre-existing) |

The mask arm:

```c
uint64_t mask = ((uint64_t)(1ULL << cast_to)) - 1ULL;   // UB for cast_to >= 64
resize(oper, cast_to);
uint64_t res = get_value(invalidValue, oper) & mask;
c->VpiValue("UINT:" + std::to_string(res));
c->VpiSize(static_cast<int32_t>(cast_to));
```

### 2a. THE ARITHMETIC PER WIDTH — MEASURED, NEVER DERIVED

`g1_width93.sv` crosses ten widths with nine operand classes, one localparam
per cell, nothing else varied.  Golden's mask, read off the values:

| W | mask | witness |
|---|---|---|
| 32 | `0xFFFFFFFF` | `32'(-1)` → `UINT:4294967295` |
| 63 | `0x7FFFFFFFFFFFFFFF` | `63'(all-ones)` → `UINT:9223372036854775807` |
| **64** | **0** | `64'(1)`, `64'(2)`, `64'(all-ones)`, `64'(a param read)` → `UINT:0`, every one |
| 65 | `0x1` | `65'(all-ones)` → 1; `65'(64'h1234_5678_9ABC_DEF0)` → 0 |
| 96 | `0xFFFFFFFF` | `96'(all-ones)` → 4294967295; `96'(64'h1234…DEF0)` → 2596069104 |
| 127 | `0x7FFFFFFFFFFFFFFF` | `127'(all-ones)` → 9223372036854775807 |
| 128 | 0 | every operand → `UINT:0` |
| 192 | 0 | every operand → `UINT:0` |

`vpiSize` keeps the FULL width (128, 192) — only the VALUE wraps.  A width
written as a PARAMETER NAME behaves exactly like the literal of the same value
(`PW64'` ≡ `64'`, `PW96'` ≡ `96'`; rows `c_PW64_*` / `c_PW96_*`).

### 2b. WHERE THE VALUE FLOWS — the CONTEXT table

`g2_ctx93.sv` (a CHILD module so DEF and ELAB really differ), `g3_home93.sv`
(gen-for / gen-if / a 3-deep instance chain / three instantiations of ONE span
at three widths), `g6_pkg93.sv` (package, import copy, instance actual):

| context | does golden wrap? | our site |
|---|---|---|
| `param_assign` Rhs, module ELAB | **YES** | `tryFoldConst(..., paramCtx=true)` — the head |
| `param_assign` Rhs, module DEF | golden keeps the whole cast operation, and so do we | — |
| package ELAB listing (`VIEW=PKG`) | **YES**, and the constant is re-typed to `vpiSize 32` | same site |
| a materialised IMPORT copy | **YES** | same site |
| an instance PARAMETER actual (`.SEED(96'(…))`) | **YES**, masked with the CAST's width while `vpiSize` stays the parameter's | **we do NOT** — the cell never reaches `tryFoldConst`; residue R8 |
| a gen-if / gen-for scope localparam | **YES** | **we do NOT** — the cell never reaches `tryFoldConst`; residue R8 |
| a 3-deep instance chain, and three instances of one span at 64/96/128 | **YES**, per instance | same site |
| a port `High_conn` actual, ELAB | **YES** (golden folds `96'(…)` → `UINT:4294967295`, `128'(…)` → `UINT:0`) | we KEEP the operation — residue R1 |
| a **`cont_assign` Rhs**, ELAB | **NO** — `assign w_ca = W'(64'd5)` is `UINT:5` at `vpiSize` 64 / 96 / 128, the operand's value UNMASKED, no location | a different producer; the fence |
| a PROCEDURAL assignment | neither side folds | — |

The `cont_assign` row is why the law carries `paramCtx`.  An earlier revision
masked every fold and turned those three cells from RIGHT to WRONG; the arm
scorer caught it, and `paramCtx` is true at exactly ONE call site — the
`param_assign` Rhs fold in `ParamEmit` — which is the one context every
measured cell says wraps.

### 2c. THE CHAIN RULE

ExprEval reduces the operand first, so a chain of size casts ANDs its masks.
`g7_nest93.sv`, golden, operand all-ones:

```
96'(65')   -> 1            96'(64')   -> 0            96'(63')  -> 4294967295
65'(32')   -> 1            65'(64')   -> 0            128'(65') -> 0
192'(128') -> 0            96'(96')   -> 4294967295
96'(65'(64'))  -> 0        128'(96'(65')) -> 0        96'(65'(A)) -> 1
```

The walk has to look THROUGH the parentheses: a cast's operand is bound from
`CastExpressionSyntax::right`, the parenthesised node, so a nested cast carries
`ParenthesizedExpression` as its OWN `syntax`.  Without that unwrap the chain
stopped at depth 1 and `96'(65'(all-ones))` kept 4294967295 where golden has 1.

**SLANG COLLAPSES A NARROWING OUTER CAST.**  When the outer width is smaller
than the inner (`32'(65')`, `65'(96')`, `128'(192')`) slang binds ONE
`ConversionExpression`, not two, so the inner width is not in the AST at all.
Every such row whose OUTER width is 64 or more still lands on golden because
the outer mask alone decides (`65'(96')` → 1, `64'(96')` → 0, `128'(192')` →
0).  The one row that does not is `32'(65'(all-ones))` — residue R2.

### 2d. THE `get_value` BAIL

`ExprEval::get_value` refuses a BIN/HEX/OCT constant whose **`VpiSize() > 64`**
(templates/ExprEval.cpp, the three `if (expr->VpiSize() > 64) invalidValue`
guards) and an INT/DEC one whose digits overflow `int64`, so golden keeps the
WHOLE cast operation there.  Measured on `g6_pkg93.sv`, and it proves the bail
is on the **SIZE**, not the value:

```
96'(96'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF)      golden: operation (bail)
96'(96'h0000_0000_FFFF_FFFF_FFFF_FFFF)      golden: operation (bail) <- fits u64
96'(96'b101)                                golden: operation (bail)
96'(96'd18446744073709551615)               golden: operation (parseInt64 overflow)
96'(96'd5)                                  golden: constant UINT:5   <- DEC, no guard
64'(64'hFFFF…) / 64'(64'd5) / 64'(5) / 64'('1)   golden: constant UINT:0
```

We fold all of them — a PRE-EXISTING over-fold this law neither creates nor
repairs.  The value we write in a bail cell changes from one wrong number to
another and the cell stays STILL-WRONG.  **ZERO corpus cells** (§3).

---

## 3. THE POPULATION — the WHOLE-UNIVERSE CENSUS, BEFORE ANY CODE

`cen93.sh` + `score93.py` over **every** database both pristine sweeps produced
— **956 surelog + 1358 uhdm2rtlil**, each joined against ITS OWN golden cache
entry, as a MULTISET (keys collide; a last-writer dict drops rows) — with three
families:

* **PA** — every `param_assign`: what object its Rhs is, in the fields the
  generated Compares read (`VpiSize` / `VpiConstType` / `VpiValue` /
  `VpiDecompile`; operation: `VpiOpType` + operand kinds).  **The head is a PA
  payload flip.**
* **CS** — every `operation` whose `VpiOpType` is `vpiCastOp`: where it lives,
  its target typespec kind and width, and whether its parent still REACHES it.
* **CV** — every `constant` of `vpiSize >= 32`: the value population this law
  can possibly touch (`BAND=W64UP`) plus a **32..63 CONTROL BAND**
  (`BAND=W32_63`).

Pristine buckets:

```
surelog     CS  BOTH-SAME   2 494   MOVED-WRONG   584  GOLDEN-ONLY   144  OURS-ONLY    160
            PA  BOTH-SAME  33 175   MOVED-WRONG   785  GOLDEN-ONLY 4 853  OURS-ONLY  5 077
            CV  BOTH-SAME 346 030   MOVED-WRONG 16 205  GOLDEN-ONLY 41 830 OURS-ONLY 31 249
uhdm2rtlil  CS  BOTH-SAME   1 744   MOVED-WRONG     2   GOLDEN-ONLY     2  OURS-ONLY      8
            PA  BOTH-SAME  66 816   MOVED-WRONG     8   GOLDEN-ONLY    36  OURS-ONLY     20
            CV  BOTH-SAME  92 216   MOVED-WRONG 1 312   GOLDEN-ONLY   410  OURS-ONLY    496
```

Classifying every MOVED-WRONG cell — constant vs constant, same `vpiSize`, both
`UINT:`, and golden's value equal to ours under `mask64(W)` for some W ≥ 64 —
**EXACTLY TWO CELLS IN THE WHOLE UNIVERSE ARE MASK-FAMILY CELLS, AND THEY ARE
THE SAME CELL IN BOTH MODES:**

```
default/Earlgrey_0_1   PA SPAN=39:32-39:57 LNAME=DefaultSeed VIEW=ELAB
testflags/Earlgrey_0_1   MOD=work@prim_lfsr
                         INST=work@top_earlgrey.u_aes.aes_prng.aes_prng_lfsr
                         golden UINT:0  ours UINT:1  vpiSize 64
```

(the CV family names the same two, at the constant's own span 39:47-39:57).
**uhdm2rtlil has NONE, in any family.**  The other surelog PA MOVED-WRONG cells
sort as: 680 differ in another field, 49 are a KIND flip, 38 a multiplicity
difference, 12 a size difference, 4 a value no mask explains.

---

## 4. THE LAW

`src/ExprEmit.cpp`, one helper (`srlgSizeCastUbMask93`) plus a gate at
`tryFoldConst`'s DECIMAL MINT — the single place every folded parameter value
is turned into digits.

```
fires  <- the top-level expression, after stripping implicit conversions, is a
          written CastExpression chain whose left is NOT a type syntax kind and
          whose type is integral, not an alias, not an enum, AND some cast in
          that chain is 64 bits or wider
mask   <- the AND over the chain of  (W % 64 == 0) ? 0 : (1 << (W % 64)) - 1
install<- fires AND paramCtx AND the fold is on the UNSIGNED decimal path
          (not `iv.isSigned() && iv.isNegative()`, not `isIntEncoded(expr)`)
value  <- (low 64 bits of slang's folded SVInt) & mask
```

`R10E93_OFF=1` disables the install (the A/B gate); `R10E93_CELLDBG=1` prints
one line per REACHED cell — chain depth, outermost width, composed mask, the
unsigned verdict, the stop reason and whether the law would install — and the
predicate is computed OUTSIDE the OFF switch, so the neutral binary still names
it.

### THE FENCES, each a measured negative control

* **`paramCtx`** — the `cont_assign` producer does not wrap (§2b).
* **THE UNSIGNED PATH** — ExprEval's `oper_signed` branch mints `INT:` through
  different arithmetic and does not sign-extend at all above 64 bits.  Every
  `N'(-1)` / `N'(64'sh…)` / `N'(signed'(…))` cell is left BYTE-IDENTICAL —
  wrong at 32 and 63 as well as above 64, i.e. a pre-existing family this law
  does not enter (`g1` `c_*_n`, `g4` `k_s64`/`k_s96`/`k_sd64`/`k_sd96`).
* **THE TARGET KIND** — § castTargetKeywordTypespecKind96's distinction, reused
  verbatim from § elabConnWrittenCastFold83.  `k_int`, `k_longint`,
  `k_shortint`, `k_bit`, `k_byte`, `k_logic`, `k_time`, `k_integer`, `k_enum`,
  `k_td64`, `k_td96`, `k_tdb64` are all BYTE-IDENTICAL before and after; the
  only `g4` movers are `k_size64`, `k_sizep`, `k_w64max`, `k_w65small`.
* **THE WRITTEN TICK** — § implicitStrConcatNoCast118's fence stands: a
  compiler-inserted widening carries no `CastExpression` syntax and never
  masks (`g5` `s_imp_w` / `s_imp_x` / `s_imp_y`, where golden's 96-bit copy is
  the UNMASKED `HEX:FFFFFFFFFFFFFFFF`).
* **THE STREAM** — § castOverStreamKeepsCast29's `T'({ << bit {x} })` is a TYPE
  cast, excluded by the target-kind fence and byte-identical (`g5` `s_ov_str`).
* **THE 32..63 CONTROL BAND** — `mask % 64 == mask` below 64 and slang has
  already truncated there, so no cell whose whole chain is under 64 can move.
  `g1`'s entire `c_32_*` and `c_63_*` blocks and `g7`'s `n_32_16` / `n_63_32` /
  `n_48_63` are byte-identical.
* **THE DEF VIEW** keeps whatever golden keeps: in a module DEF listing both
  sides hold the unfolded `vpiCastOp` operation, and the law never runs there
  because nothing folds there.

---

## 5. THE GRIDS

Seven arms, `arm93.sh` builds each with Surelog (GOLDEN) and with BOTH FROZEN
binaries and censuses all three; `score93arm.py` scores every KEY three ways.
`ARMS.r10earl93.txt` is the full output.

| arm | what it crosses | WRONG→RIGHT | RIGHT→WRONG | AWAY-GOLDEN |
|---|---|---|---|---|
| `g1_width93.sv` | 10 widths (32/63/64/65/96/127/128/192/`PW64`/`PW96`) × 9 operand classes (0 / 1 / 2 / all-ones / a high-bit value / a negative literal / a parameter read / a 96-bit operand / a 128-bit operand) | 62 | **0** | **0** |
| `g2_ctx93.sv` | 6 contexts × 3 child instances at 64 / 96 / 128 | 15 | **0** | **0** |
| `g3_home93.sv` | gen-for, gen-if, a 3-deep chain, three instantiations of ONE span at three widths | 14 | **0** | **0** |
| `g4_kind93.sv` | 15 cast-target spellings + signed + x/z + operand encodings | 8 | **0** | **0** |
| `g5_shape93.sv` | nested casts, a cast INSIDE an operation, a cast OVER an operation / concat / replication / stream / call / select, and the implicit-conversion fence | 18 | **0** | **0** |
| `g6_pkg93.sv` | package, import copy, instance parameter actual, and the `get_value` BAIL rows | 22 | **0** | **0** |
| `g7_nest93.sv` | the nested-cast chain grid, including the pairings slang collapses, plus a sub-64 control block | 26 | **0** | **0** |
| **total** | | **165** | **0** | **0** |

Both views are present in every arm (the arms run `-elabuhdm`, which emits the
DEF listing and the elaborated one in one database).

**THE RUN-TIME A/B GATE.**  `R10E93_OFF=1` on the PATCHED binary reproduces the
PRISTINE database BYTE FOR BYTE on all seven arms, while the law ON gives the
patched hashes.  100 % of each arm's byte delta is this law.

---

## 6. THE MOVER PREDICTION (made BEFORE any patched sweep was read)

`predict93.sh` re-runs each test's OWN slang command line — read out of THIS
PASS'S OWN pristine sweep's `cmds.txt`, in the test's OWN source directory,
recovered through the workdir's `sha1(dirpath)[:8]` suffix — with the PATCHED
binary under `R10E93_OFF=1` (byte-identical output) and `R10E93_CELLDBG=1`.
Output goes to `/dev/null`, so nothing it runs can move a database.

**THE FOUR SLANG-FENCED TESTS ARE NEVER DISPATCHED.**  `dirmap93.sh` OMITS
their source directories from the map, listing them only as OPAQUE `sha1[:8]`
hashes, so the driver finds no source, prints `FENCED-SKIP` and runs nothing —
8 skips on surelog, 2 on uhdm2rtlil.  No file in this directory spells them.

```
                 cells REACHED   fires=1   install=1
uhdm2rtlil            26            0           0
surelog              558            2           2
```

```
default/Earlgrey_0_1-71da2fd7    prim_lfsr.sv line=39 fires=1 depth=1
testflags/Earlgrey_0_1-71da2fd7  width=64 mask=0 uns=1 install=1
```

**PREDICTION: EXACTLY TWO DATABASES MOVE — `Earlgrey_0_1` default and
testflags.**  The 556 + 26 cells that reach the site and do not move are the
denominator: every one reports `fires=0` (no cast in its chain reaches 64).
THE DENOMINATOR COUNTS ONLY CELLS THAT REACH THE SITE, and two sub-families of
this same law never reach it at all — a generate-scope localparam and an
instance parameter actual are folded by a different path, so golden wraps them
and we do not, before AND after (residue R8, measured on this pass's own `g3`
and `g6` arms and on the verifier's `v3`/`v4`).  Neither is a mover and neither
is a corpus cell.  Two surelog command lines exit
rc=139 in the trace re-run under the neutral binary; that is the pre-existing
segfault family RESUME §9 records (earl82 R6 / earl83 R6 / earl84 R6 / earl85
R5 / earl89 R6 / earl90 R8 / earl91 R5), and it is NOT a mover.

Both Earlgrey databases are byte-deterministic per binary, so neither is a coin.

---

## 7. WHAT MOVED, AND THE GATES

`byteverify.sh SELFCHECK=1`, patched sweep vs THIS PASS'S OWN pristine sweep:

```
uhdm2rtlil  MOVERS 0 / 1358      SELFCHECK 1357/1358 flagged
surelog     MOVERS 2 /  956      SELFCHECK  955/ 956 flagged
    ./default/Earlgrey_0_1-71da2fd7    <- PREDICTED BY NAME
    ./testflags/Earlgrey_0_1-71da2fd7  <- PREDICTED BY NAME
```

Nothing unpredicted moved; the Scoreboard/default coin did not flip.

The census re-scored over the SAME universe, golden side asserted unchanged
(`CENSUS.r10earl93.txt`):

```
surelog   PA  MOVED-WRONG   785 ->   783    BOTH-SAME 33 175 -> 33 177
          CV  MOVED-WRONG 16 205 -> 16 203  BOTH-SAME 346 030 -> 346 032
          CS  every bucket unchanged
          GOLDEN-ONLY and OURS-ONLY unchanged in all three families
uhdm2rtlil    every bucket of all three families unchanged
```

**WRONG→RIGHT 2, RIGHT→WRONG 0, AWAY-GOLDEN 0, STILL-WRONG 0.**  An
order-blind multiset comparison of the recorded diff CELLS says **ADDED 0 /
REMOVED 4** on surelog (the head, in the PA and the CV view, once per mode) and
**ADDED 0 / REMOVED 0** on uhdm2rtlil.

Heads: `Earlgrey_0_1` default **64 → 29** cmp lines, testflags **64 → 50**, one
head each — the head is CLEARED.  Every other named row's head log is
BYTE-IDENTICAL (SeqDriver 6254 / SimpleUVM 62 / Scoreboard 62 / MiniAmiq 6222 /
BuildUVMPkg 55 / Rggen 0).

The whole battery, as run, is in `GATES.r10earl93.txt`; the new heads and the
ranked residues are decoded in `PREDICT_R0.txt`.

---

## 8. FILES

```
ct93cen.cpp    the CS / PA / CV census (build line in its header)
cen93.sh       run it over a whole sweep, joining each DB against its own golden
score93.py     the MULTISET join and bucket counts
arm93.sh       build one grid arm three ways (golden / pristine / patched)
score93arm.py  score one arm's keys: WRONG->RIGHT / RIGHT->WRONG / AWAY-GOLDEN
g1..g7_*.sv    the grids
dirmap93.sh    the workdir-hash -> source-dir map, with the FENCE
predict93.sh   the run-time mover prediction
bdlist93.sh / vwide93.sh / bdscore93.sh   the WIDE BOUNDARY
famclass93.py  classify a census family's MOVED-WRONG cells; names the
               MASK-FAMILY ones
r0probe93.cpp  print one instance's module-level relations on both sides
r0ref93.cpp    every ref_obj of a given name with its Actual_group -- the
               generic locator for an `RHS: <null>` head's OWNER
byteverify.sh canaries.sh ctcan2.sh canaudit.sh ct8rows.sh rowheads.sh
               the standing gate battery (carried forward unchanged)
```
