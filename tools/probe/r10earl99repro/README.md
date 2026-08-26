# r10earl99 — § caTernaryArmPatternFlatten99

**The Earlgrey/testflags head: the `'1` of `'{data: …, mask: '1}` inside a
cont_assign's `? :` chain, which golden re-types against the member width and
we leave unsized.**

BASE `1f9906a`, branch `auto5h`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; everything
in this directory is **MEASUREMENT ONLY**.

---

## 1. The head

`rowheads.sh` on this pass's own pristine build, `Earlgrey_0_1`:
**default 31 cmp lines / 1 head, testflags 36 cmp lines / 1 head**, which is
exactly what r10earl97's `PREDICT_R0.txt` named. The testflags head
(`HEAD_BEFORE_Earlgrey_testflags.cmp`), `hmac_core.sv:114-119`:

```
assign sha_rdata =
  (!hmac_en)             ? fifo_rdata                                               :
  (sel_rdata == SelIPad) ? '{data: i_pad[(BlockSize-1)-32*pad_index-:32], mask: '1} :
  ...

LHS(golden) constant 116:83-116:85, parent operation 116:30-116:86
              |vpiDecompile:15  |vpiSize:4   |UINT:15  |vpiConstType:9
RHS(ours)     the same constant, the same span, the same parent
              |vpiDecompile:'1  |vpiSize:-1  |BIN:1    |vpiConstType:3
```

`mask` is `logic [WordByte-1:0]` = **4 bits** in `hmac_pkg::sha_fifo_t`.
`constant::Compare`
(`~/git-repos/UHDM/build/generated/src/constant.cpp:58-72`) adds `VpiConstType`
to `expr::Compare` (`expr.cpp:83-102`: `VpiDecompile`, `VpiSize`, `Typespec`),
so all four printed fields are read.  (`uhdm-cmp` prints `decompile:` twice per
SIDE for one head — `grep -c '^LHS:'` is the head count, and it reads 1.)
`vpiConstType 9` is `vpiUIntConst`, `3` is `vpiBinaryConst`
(`~/.local/include/uhdm/vpi_user.h:487,493`).

`g0_head99.sv` reproduces it in a 36-line module — one head on the pristine binary,
`uhdm-cmp` **EQUAL** after the law, in **both views**.

---

## 2. The decoded model

**Surelog re-types an unbased unsized literal in an assignment pattern inside
`UHDM::ExprEval::flattenPatternAssignments`, and that function does not care
what stands between the cont_assign and the pattern as long as everything
between them is a conditional operator.**

`UhdmWriter::writeCont` (Surelog `src/DesignCompile/UhdmWriter.cpp:2178-2216`)
hands the LHS signal's typespec to the flatten and then to
`CompileHelper::expandPatternAssignment`. **Both** begin with the same
recursion:

```c++
// UHDM templates/ExprEval.cpp:757-763
if (op->VpiOpType() == vpiConditionOp) {
  VectorOfany *ops = op->Operands();
  ops->at(1) = flattenPatternAssignments(s, tps, (expr *)ops->at(1));
  ops->at(2) = flattenPatternAssignments(s, tps, (expr *)ops->at(2));
  return result;
}
// Surelog src/DesignCompile/CompileHelper.cpp:5069-5075 — verbatim twin
```

`ops[1]` and `ops[2]` only: the **arms**, never `ops[0]`, the condition. And
the recursion stops dead at the first operand that is neither a `conditionOp`
nor an `assignmentPatternOp`, so a pattern buried in an arm's arithmetic is
never reached. That is the whole shape of the carrier.

Once the flatten is standing on the pattern, its per-member arm
(`ExprEval.cpp:889-916`) reads the tagged_pattern's `Pattern()` alone:

```c++
if (c->VpiSize() == -1) {
  uint64_t uval = get_uvalue(invalidValue, c);
  if (uval == 1) {
    uint64_t size = ExprEval::size(fieldTypes[index], …);
    uint64_t mask = NumUtils::getMask(size);
    c->VpiValue("UINT:" + std::to_string(mask));
    c->VpiDecompile(std::to_string(mask));
    c->VpiConstType(vpiUIntConst);
    c->VpiSize((int32_t)size);
  } else if (uval == 0) { … same, with 0 … }
}
```

which is § patFlatUnsizedMemberWidth61's law, already implemented — **only the
carrier gate was too narrow**: `ModuleEmit`'s cont_assign site set `patFlatTs`
if and only if the RHS *was* the pattern. `hmac_core.sv:114` writes a nested
ternary chain, `hmac.sv:257` writes a single ternary, and neither reached it.

Two pieces of Surelog's own arithmetic had to be modelled with it, because
widening the reach makes both observable (`g1_lit99` measures both):

* **`NumUtils::getMask` SATURATES AT 64 BITS** (UHDM `templates/NumUtils.cpp:97-104`:
  `wide >= 64 ? (uint64_t)-1 : (1<<wide)-1`), and the flatten stores that value
  whole while stamping the TRUE width on `VpiSize` — it has no `>64` branch,
  unlike `CompileHelper::adjustUnsized`. Golden on a 65-bit member writes
  `UINT:18446744073709551615` at `vpiSize 65`; `SVInt::setAllOnes()` gave
  2^65-1. This is exactly the LANDMINE r10earl61 recorded and left ("do not
  widen the >64-bit reach without clamping to `getMask`").
* **THE SIZE WALK ABORTS ON A MEMBER 65 BITS OR WIDER.**
  `expandPatternAssignment`'s untagged arm
  (`CompileHelper.cpp:5259-5265`) copies each operand's bits one at a time and
  returns from the whole function the first time the shift would reach 64;
  at `i == 0` the shift **is** `csize-1`, so `csize >= 65` returns immediately —
  after `adjustOpSize` has already stamped that operand. Golden therefore
  stamps the 65-bit member and nothing after it.

---

## 3. The change

`include/UhdmExporter.h` — two members: `caCondPatTs99` (the LHS signal's
struct typespec) and `caCondPatSet99` (the AST pattern nodes the chain
reaches).

`src/ModuleEmit.cpp` (`emitContAssigns`, the module-level cont_assign site) —
when the elaborated RHS is a `ConditionalOp` over a struct-typed LHS net, walk
**exactly the chain Surelog's two recursions walk** (arms only, any depth) and
record the `StructuredAssignmentPattern` nodes it lands on. A **set of AST
nodes, not a flag**: a flag would leak into subtrees the flatten never sees,
and `g2_ctx99`'s `c_arith` row (a pattern under an arm's arithmetic, which
golden leaves alone) is the witness that this matters.

`src/ExprEmit.cpp` (the `StructuredAssignmentPattern` case) — a pattern in that
set becomes a flatten carrier with the LHS typespec and the size-stamping pass,
plus the two arithmetic corrections above.

Nothing else changed: 3 files, +143 / −20.

---

## 4. The population, counted before a line was written

`pop99.cpp` over **all 956 surelog and all 1358 uhdm2rtlil pristine
databases** (`POP_sl.txt`, `POP_u2r.txt`):

```
CHAIN carrier   uhdm2rtlil     0 cells / 1358 DBs   -- the corpus has NONE
                surelog       28 cells /  2 tests
                   Earlgrey_0_1  default   10 (7 unsized)
                   Earlgrey_0_1  testflags 10 (6)
                   CondOpPattern default    4 (0)
                   CondOpPattern testflags  4 (0)
```

`CondOpPattern` is **CMP_EQUAL in both modes** — a live must-stay row this
carrier does cover. Measured directly, both views, both frozen binaries: its
`.uhdm` files are **byte-identical** pristine vs patched (its arms are named
members already in declaration order carrying sized literals, so the flatten is
the identity there).

The DIRECT carrier — the landed one, which the `getMask` clamp and the `>=65`
abort also touch — is 272 surelog + 92 uhdm2rtlil cells. Eleven have a member
64 bits or wider, **all with `unsized=0`**, and the only `>=65` one is a
single-operand pattern where "stamp and stop" and "stamp and carry on" are the
same vector. So neither correction has any corpus reach outside Earlgrey; both
are measured on `g1_lit99` instead.

**PREDICTION: EXACTLY TWO DATABASES MOVE — `Earlgrey_0_1` default and
testflags. uhdm2rtlil: ZERO movers.**

---

## 5. What actually moved

`byteverify.sh SELFCHECK=1`, patched vs this pass's own pristine sweep; both
binaries frozen `chmod 555` at immutable paths of the **same length**
(`/tmp/r10earl99_pris.bin`, `/tmp/r10earl99_lawC.bin`); every `cmds.txt`
audited **by binary path** — 0 of 1462 + 1573 name the main-tree binary:

```
uhdm2rtlil  MOVERS 0 / 1358      <- as predicted (SELFCHECK 1357/1358 flagged)
surelog     MOVERS 2 /  956      <- as predicted, and NOTHING ELSE
    ./default/Earlgrey_0_1
    ./testflags/Earlgrey_0_1     (SELFCHECK 955/956 flagged)
```

The whole-database census (`ct99cen` + `reg99.py`, calibration golden-vs-golden
**0 rungs** on 783 183 / 1 061 095 keys):

```
Earlgrey default    TO-GOLDEN 4  AWAY-GOLDEN 0  ADDED 1  REMOVED 0
                    STILL-WRONG 5892 -> 5887   BOTH-SAME 739268 -> 739272
Earlgrey testflags  TO-GOLDEN 2  AWAY-GOLDEN 0  ADDED 1  REMOVED 4
                    STILL-WRONG 391301 -> 391291  BOTH-SAME 1017021 -> 1017022
```

**MOVED-WRONG 0 and AWAY-GOLDEN 0 in both columns**, and **neither one-sided
key set moves by a single key** (GOLDEN-ONLY 32708 / 34179 and OURS-ONLY
27076 / 73829, before and after). Six keys change per mode and **every one of
them lands on golden's multiset exactly** — the full quotation is in
`CENSUS.r10earl99.txt`; the cells are

| cell | golden | pristine | candidate |
|---|---|---|---|
| `hmac_core.sv:116:83` `mask:'1` | ct 9 sz 4 dec 15 | ct 3 sz −1 dec `'1` | = golden |
| `hmac_core.sv:117:83` `mask:'1` | ct 9 sz 4 dec 15 | ct 3 sz −1 dec `'1` | = golden |
| `hmac_core.sv:119:16` `'{default:'0}` | TWO constants {9,32,0}+{9,4,0} | ONE {3,1,`'0`} | = golden |
| `hmac.sv:257:86` `mask:'1` | ct 9 sz 4 dec 15 | ct 3 sz −1 dec `'1` (+ a surplus orphan) | = golden |
| `pinmux.sv:268:46` ref_obj `lc_strap_taps` | VpiSize 2 | VpiSize 0 | = golden |

The `ADDED 1` is the second constant of `'{default:'0}`, an object **golden
has**; the `REMOVED 4` (testflags) are surplus duplicate copies **golden does
not have**.

`pinmux.sv:268` is the arm that shows the size walk is part of the law and not
a side effect: `'{valid: 1'b1, straps: lc_strap_taps}` in a ternary arm has no
unbased literal at all, and golden still stamps `VpiSize 2` on the `ref_obj`
that stopped the walk (§ patFlatAdjustStopsAtUnvaluable27's rule).

---

## 6. Gates (all green, on the shipped binary)

1. build `-j 2`, md5 taken separately; **0 errors**;
2. `check_goldens.sh` **23 PASS / 0 FAIL**, and `SLANG_UHDM=/bin/false`
   **23 FAIL / 0 PASS** (the negative control), `SLANG_UHDM` exported
   explicitly to each binary;
3. uhdm2rtlil testflags **679 / 50 / 2** and default **679 / 50 / 2**,
   `ct8rows` **PASS** (status AND dump column) against this pass's own
   pristine sweep and against `results/gate_uhdm2rtlil.csv`;
4. surelog `--mode both`, histogram identical to pristine
   (default 471 CMP_EQUAL / 10 CMP_NOTEQUAL, testflags 466 / 9),
   `ct8rows` **PASS** over 1588 rows against pristine and against
   `results/golden_surelog.csv` — **NO row converted, and none claimed**;
5. `byteverify SELFCHECK=1` — 2 movers, both predicted by name (§5);
6. canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2`
   PASS on both; `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
   protected DBs by name — InterfaceModPort / BlackParrotComplex / YosysOldOr
   byte-identical to pristine, SVSwitch `4842211c4030`, YosysVerx
   `6ccda350c24a`;
7. boundary — `BOUNDARY_OWN.txt`: this pass's five arms in both views,
   **8 cells moved, 2 identical** (`g4_neg99`, the negative control), golden
   side identical on all ten — the positive control that the gate can see a
   moved cell. `BOUNDARY_WIDE.*`: every `.sv`/`.v` under a COPY of
   `tools/probe` at ANY depth, both views, both binaries, workdir-normalised
   dump byte-compare, list on fd 3, children `</dev/null`,
   **LISTED=4418 == PROCESSED=4418**, identical 8466, **DIFFERING 14**, and
   the rc histogram is SYMMETRIC side for side (`0_A 8113 / 0_B 8113`,
   `139_A 14 / 139_B 14`, `3_A 342 / 3_B 342`, `4_A 367 / 4_B 367`).
   Of the 14: 8 are this pass's own arms; 2 are `r10earl61repro/v4_v61.sv`
   — r10v61's adversarial arm whose D2 row is written verbatim as "cont_assign
   whose RHS pattern is nested inside a ternary", i.e. this law's own shape —
   re-measured against golden it moves **TOWARD** it (dump distance 435→391
   plain, 590→522 elab; census TO-GOLDEN 6 / 2, AWAY-GOLDEN 0, in the two
   views); and 4 are `r10buvm22repro/g22.sv` and
   `r10uvm154repro/l154_noenum.sv` in both views — **the pre-existing layout
   artifact r10uvm154 §7 characterised**, which this pass re-proved with a
   THIRD binary (see §8 R7).

The four slang-fenced test names are never dispatched and appear in no driver
here; `canaudit.sh` asserts it.

---

## 7. The head after

`Earlgrey_0_1` default **31 → 31** (unchanged: it is r10earl98's own head, the
surplus gen-scope `fifo_wptr`), testflags **36 → 26594 cmp lines, still ONE
head — and the head OBJECT CHANGED**, which is why the line count went up: the
new head is a `module_inst`, and `uhdm-cmp` decompiles it whole.

```
LHS/RHS: module_inst work@sha2_pad (work@top_earlgrey.u_hmac.u_sha2.u_pad)
```

A `Variables` **VECTOR SIZE** mismatch: ours carries one `struct_var`
`fifo_rdata` (`sha2.sv:19:25`) that golden's `u_pad` does not list. The census
proves it is **pre-existing and untouched** — that key reads
`pristine 1 / candidate 1 / golden 0` before and after, and the OURS-ONLY key
set does not move.

---

## 8. Ranked residues this pass MEASURED and deliberately did not take

* **R1 — A POSITIONAL PATTERN IN A TERNARY ARM IS A DIFFERENT FUNCTION.**
  `g2_ctx99` `c_pos` (`'{'1, '0}` on {3,5} members), golden first:
  `'1` → UINT 7 at size 3, but `'0` → **BIN `'0` at size 5** — decompile and
  const type **kept**, only `VpiSize` stamped. That is
  `expandPatternAssignment`'s untagged arm → `adjustOpSize` → `adjustUnsized`
  (`CompileHelper.cpp:4921-4942`), which rewrites the value **only when it is
  1**. Ours: `'1` sized 3 but not re-typed, `'0` left at −1. Its own law, its
  own census. **Measured denominator: 0 corpus cells** (`pop99` reports no
  positional chain-carrier pattern anywhere in either corpus).
* **R2 — A NESTED PATTERN'S MEMBERS ARE NOT RE-TYPED.** `g2_ctx99` `c_nest`
  (`'{inner: '{a:'1, b:'0}, c:'1}`): golden re-types the inner members too
  (UINT 7 sz 3, UINT 0 sz 5) through the flatten's **own** recursion
  `opi = flattenPatternAssignments(s, fieldTypes[index], patt_op)`, which
  needs no carrier permission at all; our nested recursion hands the member
  typespec down but not the re-typing permission (the landed gate is
  `patFlatAdjust ||  the default setter`, and `patFlatAdjust` models the
  SIZE walk, which does **not** recurse). Splitting the two flags is the fix;
  it also reaches the landed DIRECT carrier. 2 cells per view on the arm,
  **0 corpus cells** in either corpus.
* **R3 — A FUNCTION ARGUMENT'S UNBASED LITERAL IS RE-TYPED, BY A THIRD
  MECHANISM.** `g2_ctx99` `c_arg` (`f99('1)` on a `logic [7:0]` formal):
  golden writes **BIN `11111111` at size 8** with a `ref_typespec` to the
  formal's `logic_typespec` — `adjustSize`'s `uhdmlogic_typespec` arm, not the
  flatten's UINT mask. Ours leaves it `'1` at −1. Identical before and after.
* **R4 — THE STRUCT_TYPESPEC RANGE CONSTANTS.** Every arm here carries 4-8
  golden-only `{dec, sz 64, ct 9}` constants on the packed dimensions of the
  test's own `typedef struct packed`. Present identically before and after;
  it is `g3_home99`'s remaining head.
* **R5 — A PORT-CONNECTION PATTERN.** `g2_ctx99` `u_sub .p('{a:'1, b:'0})`:
  golden flattens and re-types it (UINT 7 sz 3 + UINT 0 sz 5); we fold the
  whole `high_conn` into one `8'd224` constant. A different shape entirely —
  the port `high_conn` laws own it, and the standing boundary fences them.
* **R6 — A PACKED-ARRAY PATTERN TARGET.** `g4_neg99` `n_parr`
  (`sel ? 4'h0 : '{'1,'0,'1,'0}`): golden folds the whole pattern to one
  `4'd10`; we emit four constants. Untouched by this law (the carrier requires
  a `struct_typespec`). Identical before and after.
* **R7 — THE ASSOCIATIVE-ARRAY TYPEDEF'S LAYOUT-DERIVED CONSTANT.** A
  class-scoped `typedef <T> name[string]` makes us emit an `array_typespec`
  whose range right bound is a garbage number — golden emits a
  `string_typespec` index and **no numeric constant at all** — and that number
  tracks the BINARY LAYOUT. r10uvm154 §7 characterised it and committed
  `l154_noenum.sv` to prove it; this pass re-proved it independently with a
  **third binary**: a build of the PRISTINE SOURCE carrying the law's two
  members with **no behaviour attached** (`/tmp/r10earl99_padd.bin`) produces
  the PATCHED number `22552281` on `g22.sv`, where the plain pristine build
  produces `22548185` — the cell tracks the size of the exporter object, not
  the law. It is not environment-dependent (0 / 4 / 200 / 5000 bytes of
  environment padding all give the pristine number) and is run-stable per
  binary. Scored against golden: `g22.sv` reads `uhdm-cmp` 3438 lines / 1 head
  and census TO-GOLDEN 0 / AWAY-GOLDEN 0 / ADDED 0 / REMOVED 0 on **both**
  binaries in **both** views, and `l154_noenum.sv` reads 17 cmp lines / 1 head
  on **all three** binaries — equidistant, which is r10uvm154's own verifier
  correction reproduced with an independent third point.
* **R8 — THE PRE-EXISTING PROBE / BOUNDARY SEGFAULTS.** The wide boundary's rc
  histogram is symmetric side for side (14 per side); recorded by earl82 R6 …
  earl97 R5; `byteverify` proves none of them is a mover.

---

## 9. R0 — the next head

See `PREDICT_R0.txt`.

---

## 10. What is in this directory

| file | what it is |
|---|---|
| `arm99.sh` | the arm driver (both views, workdir-isolated, md5 printed) |
| `g0_head99.sv` … `g4_neg99.sv` | the golden grid: head witness, literal×width, contexts, homes, negatives |
| `ct99cen.cpp` / `reg99.py` | the census and its three-way scorer |
| `ct99tree.cpp` | the cont_assign RHS tree printer (Earlgrey's dump is gigabytes) |
| `pop99.cpp` | the population counter (CHAIN vs DIRECT carriers) |
| `POP_sl.txt` / `POP_u2r.txt` | the population, per database |
| `ARMS.` / `CENSUS.` / `GATES.` / `BOUNDARY_*` | the transcripts |
| `HEAD_BEFORE_*` / `HEAD_AFTER_*` | the official cmp head, before and after |
| `rowheads.sh` `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `vwide99.sh` | the gates, copied verbatim so this pass is re-runnable |
