# r10earl80 — § ovHopOverriddenKeepsValue80: an OVERRIDDEN parameter on an override chain is not a Value round trip at all

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `08918a1`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl79 named as R0 — 64 cmp lines, one head,
byte-identical in both modes — is CLEARED in both modes. 64 → 32 lines
(default) and 64 → 36 (testflags), one head to one head, and every other named
row's cmp log is byte-identical.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_default.cmp` / `HEAD_BEFORE_testflags.cmp` are the verbatim
pristine logs (binary md5 `f00c80b5d81b496f56f6cb3ec1f270b3`, rebuilt from
`08918a1` in my own worktree). They are byte-identical to each other **and to
the master's `/tmp/earlgrey_head_08918a1.cmp`**, so this pass starts on exactly
the object r10earl79's `PREDICT_R0.txt` named.

```
LHS (golden)                              RHS (ours)
constant     12:40-12:41                  constant     12:40-12:41
|vpiParent -> param_assign 12:26-12:41    |vpiParent -> param_assign
|vpiDecompile:4'h0     <-- THE HEAD       |vpiDecompile:32'h0
|vpiSize:32                               |vpiSize:32
|HEX:0                                    |HEX:0
|vpiTypespec -> ref_typespec -> int_ts    |vpiTypespec -> ref_typespec -> int_ts
|vpiConstType:5                           |vpiConstType:5
```

**Which arm.** Read the generated `Compare` order before naming the field:

```c++
// UHDM/build/generated/src/param_assign.cpp:94
//   VpiConnByName, then VpiOverriden (:107 — the judge DOES read it), then Rhs
// UHDM/build/generated/src/expr.cpp:83
int32_t expr::Compare(...) {
  basetype_t::Compare(...)                            // VpiType/VpiName/VpiDefName
  lhs->VpiDecompile().compare(rhs->VpiDecompile())    // "4'h0" vs "32'h0"  <-- HEAD
  lhs->VpiSize() - rhs->VpiSize()                     // 32 == 32
  SafeCompare(lhs->Typespec(), rhs->Typespec(), ...)  // both int_typespec
}
// UHDM/build/generated/src/constant.cpp:58 — VpiConstType 5 == 5
```

`VpiDecompile` is the **first** field `expr::Compare` reads and it is the
failing one; `VpiSize`, the typespec and `VpiConstType` are all below it and all
agree. `vpiValue` (`HEX:0`) is not compared at all but must follow.

**Which object, and the chain.**

```systemverilog
tlul_socket_1n.sv:16    parameter bit [3:0] HReqDepth = 4'h2
spi_device_reg_top.sv:70  tlul_socket_1n #( … .HReqDepth (4'h0) … ) u_socket
tlul_socket_1n.sv:47      tlul_fifo_sync #( .ReqDepth(HReqDepth) … ) fifo_h
tlul_fifo_sync.sv:12        parameter int unsigned ReqDepth = 2
tlul_fifo_sync.sv:32      prim_fifo_sync #( … .Depth(ReqDepth) ) reqfifo
prim_fifo_sync.sv:12        parameter int unsigned Depth = 4
```

so the head is `Depth`'s `param_assign` Rhs in
`top_earlgrey.u_spi_device.u_reg.u_socket.fifo_h.reqfifo`, **two instance hops
below a 4-bit hex literal written at the instantiation site.** Golden's
decompile still says `4'h0` there; we re-rendered it at 32 twice on the way
down.

---

## 2. The law

**§ ovHopOverriddenKeepsValue80 — an OVERRIDDEN parameter on an
instantiation-override chain is NOT a `Value` round trip: the actual's own
`Value` passes through it untouched — no `adjustSize`, no re-render — and only
the formal the chain ENDS at adjusts it. A NON-overridden parameter is the
opposite case and keeps the round trip it already had.**

### Decoded from Surelog

1. `DesignElaboration::collectParams_`
   (`~/git-repos/Surelog/src/DesignCompile/DesignElaboration.cpp:2147-2170`)
   compiles the override ACTUAL in the **parent** instance and stores

   ```c++
   UHDM::expr* complexV = m_helper.compileExpression(parentDefinition, …,
                              Reduce::Yes, nullptr, parentInstance, false);
   const std::string_view v = c->VpiValue();
   value = m_exprBuilder.fromVpiValue(v, c->VpiSize());   // :2169-2170
   ```

   — **there is no `adjustSize` anywhere on this path**, so the instance's
   stored `Value` is the actual's raw one, at the actual's own width.

2. `NetlistElaboration::elab_parameters_`
   (`NetlistElaboration.cpp:406-448`) mints the `param_assign` constant FROM
   THAT `Value`:

   ```c++
   c->VpiValue(value->uhdmValue());
   c->VpiDecompile(value->decompiledValue());
   c->VpiSize(value->getSize());
   c->VpiConstType(value->vpiValType());
   …
   m_helper.adjustSize(tps, instance->getDefinition(), …, c);   // :448
   ```

   and `SValue::decompiledValue` (`src/Expression/Value.cpp:298-322`) renders a
   based Value as `<m_size>'<base><digits>` — **the Value's size, not the
   constant's.**

3. `CompileHelper::adjustSize` (`CompileHelper.cpp:3949`) then runs over **the
   constant only**. Its `vpiHexConst` / `vpiOctConst` / `vpiIntConst`
   fall-through at `:4127` is

   ```c++
   } else {
     c->VpiSize(size);          // and NOTHING else
   }
   ```

   which is exactly why golden's cell reads `vpiSize:32` while its
   `vpiDecompile` still says `4'h0`.

4. The **next** hop reads the stored `Value` (step 1), not that constant. So an
   overridden intermediate contributes nothing at all, while a NON-overridden
   one — whose stored `Value` came from its own declaration, where `adjustSize`
   ran before the capture — propagates its width, its mask and its
   sign-extension.

### Measured on golden

`gengrid80.py` builds the head's own three-module chain

```
top --.A(<S>)--> h1( <M> A ) --.B(A)--> h2( int unsigned B ) --.D(B)--> lf( int unsigned D )
```

so `A` is the ZERO-hop cell, `B` the ONE-hop cell and `D` the TWO-hop cell.
Two grids, **1728 + 1440 = 3168 scored cells**:

* `g1_hops80.sv` — **the width axis**: 12 source spellings (`4'h2` `8'h2`
  `4'd2` `4'b10` `4'o2` `'0` `'h2` `2` `16'h2` `1'b1` `4'h0` `33'h1`) ×
  8 intermediate declared types (`bit [3:0]` `bit [7:0]` `logic [7:0]`
  `int unsigned` `int` `bit [31:0]` untyped `bit`) × 3 homes for the source
  value (**DECL** = `A`'s own declared default; **OVR** = the literal written at
  the instantiation site, the Earlgrey shape; **LP** = a top-level localparam of
  type `<M>` passed as the actual, the r10earl27/28 `qc28` shape).
* `g2_mask80.sv` — **the truncation/sign axis**: 10 sources that `adjustSize`
  would MASK, TRUNCATE or SIGN-EXTEND (`8'b10110011` `8'hff` `300` `4'sb1000`
  `8'sh80` `16'habcd` `2` `1'sb1` `8'd200` `5'b11111`) × 8 types × the same 3
  homes.

> **In all 720 golden chains the decompile is decided ONCE, where the Value is
> born, and hop 1 and hop 2 are IDENTICAL to hop 0.**

| home | golden's width, at every hop |
|---|---|
| **OVR** | the WRITTEN literal's own width — `4'h2` into `bit [7:0]` stays `4'h2`, into `int` stays `4'h2`, into `bit` stays `4'h2`; `16'h2` and `33'h1` stay 16 and 33 bits wide into every formal |
| **DECL** | the DECLARED type's width (`4'h2` as `bit [7:0] A` reads `8'h2`; as `int` `32'h2`; as `bit` `1'h2`), and the literal's own width when `A` is untyped |
| **LP** | the LOCALPARAM's declared width, and `A` (overridden) keeps it |

**And it is not only the width — that is what `g2_mask80.sv` is for:**

| written | one hop on, through … | golden |
|---|---|---|
| `.A(300)` | an OVERRIDDEN `bit [3:0] A` | `UINT:300` size 32 — **unmasked** |
| `300` as `bit [3:0] A`'s DEFAULT | a NON-overridden hop | `UINT:12` — masked |
| `.A(8'b10110011)` | an OVERRIDDEN `logic [3:0] A` | `BIN:10110011` size 8 — **untruncated** |
| same as the DEFAULT | a NON-overridden hop | `BIN:0011` size 4 — truncated |

Skipping only the *re-render* would have left both of those wrong, which is why
the whole round trip goes.

### The code

One clause, in `ovEnc8`'s `NamedValue` arm (`src/ParamEmit.cpp`), guarded by an
A/B gate (`R10E80_OFF=1` restores the pre-pass path — that is the NEUTRAL
binary every boundary walk and every grid arm scores against):

```c++
if (!ovHopOff80 && !o8.dec.empty() && isOverriddenParam(pp8))
    return true;                       // the hop contributes NOTHING
SrlgTsK sk8; bool ss8; int32_t sw8;     // …and the pre-existing round trip
clsParam8(pp8, in8, sk8, ss8, sw8);     //    still runs for a NON-overridden
srlgAdjustSize(o8, sk8, ss8, sw8);      //    hop, unchanged
srlgOvRender(o8);
```

**THE ONE FENCE, and the grid named it.** The unbased-unsized `'0` producer
above deliberately leaves `o8.dec` EMPTY and lets the hop's own `srlgOvRender`
mint the decompile at the width it settles on. The first patched run therefore
bound an **empty** `vpiDecompile` on all 28 `'0` cells of `g1_hops80.sv`
(MOVED-WRONG 28). Golden wants `'b0` at size 32 there — an UNSIZED size the
`SrlgOvEnc` model does not carry — so `!o8.dec.empty()` keeps the whole `'0`
family on the pristine path, wrong exactly as it was, and it is ranked as R1 in
`PREDICT_R0.txt`. **MOVED-WRONG went 28 → 0.**

`§ ovEncScalarSourceSkipsHops28`'s `o8.size == 1` clause sits ABOVE this one and
is untouched: it fires on NON-overridden hops too (`1'b1` as an `int` A's
declared default reads `1'b1`, not `INT:-1`, one hop on), so it is a different
and wider rule.

---

## 3. What moved, and what did not

**The corpus (`CENSUS.txt`, `PREDICT_R0.txt`, `GATES.txt`).**

| | pristine | patched |
|---|---|---|
| Earlgrey/default `param_assign` cells differing from golden | 182 | **98** |
| Earlgrey/testflags | 182 | **98** |
| 3-way vs pristine, both modes | — | **TO-GOLDEN 84 / AWAY-GOLDEN 0 / MOVED-WRONG 0** |
| surelog corpus rows differing from the committed baseline | 0 / 1588 | **0 / 1588** |
| uhdm2rtlil rows | 0 / 731 | **0 / 731** |
| byte movers, surelog | — | **2 / 956**, both Earlgrey_0_1, predicted by name |
| byte movers, uhdm2rtlil | — | **0 / 1358**, predicted |

All 84 converted cells are `prim_fifo_sync.sv:12 Depth` (`4'h2` ×44, `4'h0`
×40); the other ten families of the 182 are unchanged cell for cell and are
ranked in `PREDICT_R0.txt`.

**The grids.**

| | cells | pristine differ | patched differ | TO-GOLDEN | AWAY | MOVED-WRONG |
|---|---|---|---|---|---|---|
| `g1_hops80.sv` | 1728 | 484 | 254 | **230** | **0** | **0** |
| `g2_mask80.sv` | 1440 | 428 | 224 | **204** | **0** | **0** |

**The boundary walks (the only instrument that convicts a corpus-invisible
regression).** Every `.sv` under a copy of `tools/probe`, at any depth, both
views, patched vs pristine, workdir-normalised whole-dump byte compare — file
list on fd 3, children `</dev/null`, `PROCESSED` asserted against the list
length. Full accounting in `BOUNDARY_NOTES.txt`.

```
WIDE (one file per unit)   PROCESSED=3569 (LISTED 3569) identical=6836 DIFFERING=12
PER-DIR (a dir per unit)   PROCESSED=1523 (LISTED 1523) identical=2783 DIFFERING=9
```

The wide walk's 12 are **six files × two views**, and all six are positive
controls or sibling arms scored against golden:

* `r10earl80repro/g1_hops80.sv`, `g2_mask80.sv` — this pass's own grids; they
  MUST move, and they are the proof the walk can see.
* `r10earl_repro/qb28.sv` — pass-28's own arm.
  **UNCHANGED-EQ 106, UNCHANGED-NE 4, TO-GOLDEN 2, AWAY-GOLDEN 0,
  MOVED-WRONG 0**, both views. The two rows are a `logic`-typed sink reached
  through an overridden `bit [3:0]` hop: golden `4'h0`, pristine `32'h0`,
  patched `4'h0`.
* `r10earl_repro/qc28.sv` — pass-28's discriminator grid.
  **UNCHANGED-EQ 144, UNCHANGED-NE 10, TO-GOLDEN 4, AWAY-GOLDEN 0,
  MOVED-WRONG 0**, both views. The four rows are `qc28`'s `TB` (`parameter bit`)
  reached via `.HB(DirWide)` with `localparam int DirWide = 8'hab`: golden
  `32'hab` (the NON-overridden `int` localparam hop renders at 32, the
  OVERRIDDEN `bit` hop then adds nothing), pristine `1'hab`, patched `32'hab`.

The per-directory walk's 9 are `r10v64repro` (both views, **TO-GOLDEN 5,
AWAY-GOLDEN 0, MOVED-WRONG 0** — the same law, the same two files) plus
`r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro` and `r10v109repro`, which are
**emitter nondeterminism, proved not asserted**: their `param_assign` censuses
do not move at all (TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0, both views); four runs
of the **pristine** binary on three of them give four DISTINCT dump hashes each,
so a single-shot A/B read there is luck; `r10uvm88repro` is in fact identical
between the two binaries over eight further runs; and the **order-blind (sorted)
whole dump is BYTE-IDENTICAL** between the two binaries, three runs each
(`r10uvm75repro` 33097b10b9, `r10uvm76repro` 60436c0faa, `r10v109repro`
13f209133f — all six hashes equal, per directory). `r10earl80repro` itself is a
`no_output` in this walk: `g1` and `g2` declare the same module names, so the
two-file unit does not compile — which is why the WIDE walk is the one carrying
this pass's positive control.

Every `rc=139` line in either `.signal` file (14 wide, 12 per-dir) appears on
**both** sides, A and B — pre-existing segfaults, not this pass's.

**Every other named row's `uhdm-cmp` log is byte-identical** before and after:
SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg, Rggen — see
`GATES.txt`.

---

## 4. Reproducing

```bash
# the two grids, golden + pristine + patched + neutral, censused
PACEN80=<pacen80> PRIS=<pristine> PATCHED=<patched> bash arm80.sh g1_hops80.sv /tmp/g1
GRID80=g1 python3 score80.py /tmp/g1/g.pa /tmp/g1/q.pa /tmp/g1/o.pa   # 3-way
GRID80=g1 python3 val80.py   /tmp/g1/g.pa /tmp/g1/o.pa                # full payload
# the corpus-wide param_assign family census (reads databases, dispatches NOTHING)
PACEN80=<pacen80> bash fencescan80.sh <sweep-workdir> /tmp/fs.tsv
# the head
bash ../r10uvm67repro/rowheads.sh <sweep-workdir> <outdir> Earlgrey_0_1
```

`pacen80.cpp` is r10earl74's `pacen74` unchanged: a DIRECT `.uhdm` reader
(Earlgrey's `uhdm-dump` is >1 GB and is NEVER produced), payload restricted to
the fields the generated `Compare` reads plus `VpiValue`, **no span**
(earl60/earl65: a span-carrying payload hides flips).
