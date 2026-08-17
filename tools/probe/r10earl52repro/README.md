# r10earl52 — § paramInitAdjustSizeElab52

**Earlgrey_0_1/default head CLEARED: 64 lines → 17 lines, 2 movers, both to
golden, and the whole 4.65M-line database delta is 4 changed lines.**

---

## THE HEAD

```systemverilog
// hw/ip/rv_core_ibex/rtl/rv_core_ibex.sv:67
localparam int FifoPass = PipeLine ? 1'b0 : 1'b1;
```

```
LHS(golden): constant INT:-1  size 32 decompile "-1"   vpiConstType:7
RHS(ours)  : constant BIN:1   size 32 decompile "1'b1" vpiConstType:3
```

## MY BRIEF WAS WRONG ABOUT THE MECHANISM, AND THE GRID SAYS SO IN ONE LINE

The brief said *"Surelog's constant-condition ternary reduce RESIZES the
selected 1-bit literal into the int target as SIGNED and lands on -1"* and told
me to characterise **which conversions the ternary fold runs**.

**The ternary is not a discriminator at all.** `a1_earl52.sv` and
`a2_earl52.sv` pair every `C ? 1'b0 : 1'b1` row with the same target written
`= 1'b1` **directly**, and golden is **byte-identical across all 17 target
types and all 18 literal spellings**:

```
              golden, elaborated view
localparam int T_int = C ? 1'b0 : 1'b1;   ->  INT:-1 size 32 dec "-1"  ct 7
localparam int D_int =              1'b1;  ->  INT:-1 size 32 dec "-1"  ct 7
```

`a3_earl52.sv` closes the other half: the condition's own shape is inert too —
module parameter / same-scope localparam / `int` parameter / bare literal /
comparison / negation / two levels of nesting / THEN-side-taken all read
`INT:-1`. The ternary contributes exactly one thing, and
**§ ovEncTernaryTakenBranch28 already knew it**: the taken branch, with no hop
of its own.

The real mechanism was already transcribed in this repo, two years of passes
ago, at the top of `src/ParamEmit.cpp`:

> **CONSUMER.** `CompileHelper::adjustSize` re-sizes that constant against the
> TARGET parameter's typespec. … BIN branches on the target typespec's KIND —
> logic truncates from the left when it is wider than the target, `int` (and
> only `int`: byte/shortint/longint/integer/bit typespecs have no arm)
> sign-extends a set MSB into a negative `vpiIntConst` when the target is
> SIGNED …

That model was implemented **only behind an `overridden` gate**, because
passes 8 and 28 only ever looked at `#(.P(...))` override actuals.
`FifoPass` is a plain non-overridden `localparam`. **The gate was never a
measured discriminator — it was the shape those passes happened to look at.**

## THE LAW

> **§ paramInitAdjustSizeElab52 — the adjustSize pipeline is not an override
> rule.** Surelog's `ElabCParam` runs the same {producer, `adjustSize`} pair
> over a parameter's OWN DECLARED initializer when it elaborates the instance.
> A non-overridden parameter whose value originates in a written literal (or
> in a constant-condition ternary or a chain of parameter hops over one) lands
> the encoding the pass-8/28 pipeline already computes — **in the ELABORATED
> view only**.

Implementation: `src/ParamEmit.cpp`, at the non-override emit chain's binding
tail, immediately before `pa->Rhs(rhs)`. `clsParam8` and `ovEnc8` are HOISTED
(verbatim, no logic change) out of the override block so both sites share one
encoder.

### The measured grid — 7 arms, 62 probe rows fixed, 0 broken, 0 DEF-view movers

Scored order-blind with `census52.py` over both views of every arm
(`{golden, pristine, patched}` joined on {Lhs fullname, Rhs span}):

```
a1/top FIXED=6   a2/top FIXED=24  a3/top FIXED=13  a4/top FIXED=8
v1/top FIXED=5   v2/top FIXED=5   v3/top FIXED=1
TOTAL fixed=62  broken=0  wrong->wrong=3 (all R1, the scoped-package family)
every arm, DEF view: 0 fixed / 0 broken / 0 moved
```

The tables below are the GOLDEN measurement — what Surelog does. F3 (see
below) lets the rule act on the `int` rows only; the rest are recorded because
they are what proves the mechanism, and they are residue R1b.

| source into `int` | golden | what produces it |
|---|---|---|
| `1'b1` | `INT:-1` sz32 `-1` | BIN, MSB set, signed `int` → twos-complement |
| `1'b0` | `BIN:0` sz1 `1'b0` | MSB clear → `size = min(1,32)` |
| `2'b10` | `INT:-2` sz32 | |
| `2'b01` | `BIN:01` sz2 | |
| `4'b1001` | `INT:-7` sz32 | |
| `1'sb1` | `INT:-1` sz32 | the `s` is dropped by the producer |
| `'0` | `BIN:0` sz32 `32'b0` | the fill takes the declared width |
| `4'h8` | `HEX:8` sz32 `32'h8` | HEX keeps digits, takes target width |
| `8'd5` | `INT:5` sz32 | DEC round-trips to a plain INT |
| `3'o7` | `UINT:7` sz32 | OCT collapses to unsigned |
| bare `1` | `UINT:1` sz32 | 64-bit UINT masked to 32 |
| `33'h1_0000_0001` | `HEX:100000001` sz32 | digits **not** truncated |

| `1'b1` into … | golden | why |
|---|---|---|
| `int`, `typedef int` | `INT:-1` sz32 | the ONLY sign-extending arm |
| `int unsigned` | `BIN:1` sz1 | `Int` arm, unsigned → `min(orig,w)` |
| `integer`, `byte`, `shortint`, `longint` | `BIN:1` sz1 | adjustSize has **no arm** |
| `logic`, `logic[31:0]`, `logic signed [31:0]`, `typedef logic[31:0]` | `BIN:1` sz1 | `Logic` arm, not wider → unchanged |
| `bit`, `bit[31:0]` | `BIN:1` sz1 | no arm |
| untyped, ranged-untyped, `real` | `BIN:1` sz1 | no typespec / no width |

`v2_earl52.sv` reaches the arms no other cell did, and every one lands:
`logic[3:0] = 8'b10101011` → `BIN:1011` sz4 `4'b1011` (the **left**-truncating
`Logic` arm); `bit[3:0] = 8'b10101011` → `BIN:10101011` sz8 (no arm, keeps the
source width); `byte = 16'b1000…1` → sz16; `logic[3:0] = 8'hab` → `HEX:ab` sz4
`4'hab`; and it holds one instance down and inside an **interface**.

### THE ONE ADDITION over the override path — and the census cell that proves it must stay there

`adjustSize`'s non-BIN arm only re-sizes, so the decompile has to be re-rendered
at the size it left behind: `4'h8 → 32'h8`, `8'hab → 32'hab`, `33'h… → 32'h…`.
That render is deliberately **NOT** hoisted into the pass-8/28 override block,
and the Earlgrey census says why in one pair of rows:

| row | path | golden | ours |
|---|---|---|---|
| `Depth` @`prim_fifo_sync.sv:12`, ×43 | **OVERRIDE** | `HEX:0` sz32 `"4'h0"` | `"32'h0"` |
| `FifoDepth` @`rv_core_ibex.sv:68` | **DECLARATION** | `HEX:0` sz32 `"32'h0"` | `"4'h0"` |

**Golden re-renders on the declaration path and does not on the override
path**, and the two rows point in opposite directions. Hoisting the render
would have turned 43 rows wrong in exactly the field it fixed one row in.

## THREE FENCES, EVERY ONE PAID FOR BY A REGRESSION A GATE CAUGHT

The unfenced rule was correct on 90 probe rows and still wrong on the corpus
three separate ways. Each fence below was found by a gate, characterised
against golden, and fixed **before landing**; none was guessed.

**F1 — `!defViewOrig9`, not just `topView`.**
`§ modDefImportShape` **force-flips `topView` to true** while emitting a
module's DEF listing of a materialized IMPORT COPY. `topView` alone let the
rule rewrite eleven DEF rows of `ibex_pkg.sv:476 parameter logic [1:0]
CSR_MISA_MXL = 2'd1` from golden's `DEC:1 sz2 "2'd1"` to `INT:1 sz2 "1"` —
golden keeps the producer encoding in the DEF copy and only the ELAB copy
becomes `INT:1`, **and we already had both right**. `defViewOrig9` is the
PHYSICAL view, exactly as `§ modDefImportShape`'s own RD note says.
`v3_earl52.sv` reproduces the whole shape in 19 lines
(`work@v3sub_earl52.K_dec` moved DEC→INT with F1 absent, and does not with it).

**F2 — no CONCATENATION / REPLICATION initializer.**
`ovEnc8`'s concat arm is measured on override ACTUALS, where the concat's own
width is the Value's width. On a DECLARATION it is not:
`tlul_socket_1n.sv:47 parameter bit [N*4-1:0] DReqDepth = {N{4'h2}}` (N=12)
reads **48 binary digits at size 32** in golden — a combination no arm of
`adjustSize` produces — and we already matched it. Re-deriving the size from
the concat width moved both `u_xbar_main.u_s1n_32` rows off golden. `a4`'s
`K_cat` / `K_cat1` / `K_litc` stay unequal (they were unequal before too);
**a corpus row that WAS equal outranks a probe row that was not.**

**F3 — `int` targets only.**
The surelog corpus gate then reported **10 rows** (5 tests x 2 modes) moving
CMP_EQUAL -> CMP_NOTEQUAL, all with a `decompile:` head, and every one of them
a target kind whose `adjustSize` arm is a NO-OP:

| test | declaration | golden | the unfenced rule |
|---|---|---|---|
| `SignedBinConst` | `parameter [1:0] p1 = 1'sb1` | `INT:3` sz2 `"3"` | `BIN:1` sz1 `"1'b1"` |
| `GenCase`, `GenCaseStmt` | `parameter bit signed x_1sb1 = 1'sb1` | `INT:-1` sz1 | `BIN:1` sz1 `"1'b1"` |
| `Scr1SvTests` | `localparam [SCR1_GPR_FIELD_WIDTH-1:0] SCR1_MPRF_ZERO_ADDR = 5'd0` | `INT:0` size **1** | `INT:0` size 5 |
| `PackedArrayHighConn` | `parameter logic [0:0][1:0] DioPadBank = '0` | `BIN:0` sz2 `"'0"` | `BIN:0` sz2 `"2'b0"` |

Two independent laws hide in there and NEITHER is modelled: a **SIGNED** based
literal (`'s`) sign-extends to the target width and turns INT on a declaration
(the producer's `s`-drop is an OVERRIDE-path rule), and a sized-DECIMAL
producer into a ranged-untyped target keeps a size — 1 — that no arm of the
model derives. `Scr1SvTests` is a named canary.

`SrlgTsK::Int` is the only target kind whose `adjustSize` arm does anything:
Logic only left-truncates a wider source, and Bit / Other have no arm at all,
so for those kinds this rule can only restate a size the emit chain already
chose. Restricting to `int` drops all five regressions, keeps both corpus
fixes, and costs `a1`'s 19 non-`int` probe rows — which were unequal before
this pass too.

## RESULT — census prediction vs measurement

`CENSUS_PREDICT52.txt` was written from the golden + pristine pair, before the
patched database was read. It predicted **exactly two movers, both to golden,
and zero DEF-view movers**.

Measured (order-blind, `census52.py`, keyed by {Lhs fullname, Rhs span}):

```
TOP view: keys base=10197 patch=10197   MOVED=2
  work@top_earlgrey.u_rv_core_ibex.FifoPass  @67:29:67:51
      base {ct=3 BIN:1  sz=32 dec="1'b1"} -> {ct=7 INT:-1 sz=32 dec="-1"}   == golden
  work@top_earlgrey.u_rv_core_ibex.FifoDepth @68:30:68:52
      base {ct=5 HEX:0  sz=32 dec="4'h0"} -> {ct=5 HEX:0  sz=32 dec="32'h0"} == golden
DEF view: keys base=2437 patch=2437     MOVED=0
```

Whole-database byte diff (workdir-normalised), 4 652 435 lines each side:

```
1292589c1292589   < |vpiDecompile:1'b1     > |vpiDecompile:-1
1292591c1292591   < |BIN:1                 > |INT:-1
1292599c1292599   < |vpiConstType:3        > |vpiConstType:7
1292610c1292610   < |vpiDecompile:4'h0     > |vpiDecompile:32'h0
```

**4 changed lines. Nothing else in 4.65M lines moved.** The DEF view
(lines 1..1196437) is byte-identical — `md5 c69245ac103c4a355e58b0ef99234970`
on both sides — as earl38's fence requires.

## THE NEW HEAD — R0 for r10earl53

Earlgrey_0_1/default now heads at **17 lines / 1 head**, and it is a MISSING
OBJECT (`RHS: <null>`), not an encoding disagreement:

```
LHS(golden): ref_typespec: (work@top_earlgrey.u_rv_core_ibex.fifo_i.reqfifo
                            .wdata.tl_h_i.a_opcode)
             |vpiParent: hier_path (tl_h_i.a_opcode), line:38:22, endln:38:37
             |vpiActual: struct_typespec (tlul_pkg::tl_h2d_t), line:32:11
RHS(ours)  : <null>
```

Golden hangs a `ref_typespec` off a `hier_path` operand inside the elaborated
`reqfifo.wdata` and we emit none. Same family as the typespec-linkage cluster,
not the parameter-encoding one.

## RESIDUES

| id | what | witnesses | changed by this pass? |
|---|---|---|---|
| **R1** | an EXPLICITLY package-SCOPED read (`pkg::S`) takes a Value round-trip that lands **BIN at the TARGET width**, not the literal chain — while the SAME parameter read through a wildcard `import pkg::*` takes the literal chain | `v1` `R_tern` golden `BIN:1 sz32 "32'b1"` vs `I_tern` golden `INT:-1`; `S_hop`/`R_hop`/`R_lit8` | **yes, wrong→wrong on 3 arm cells**; **zero corpus cells** (the Earlgrey census shows no such mover). A syntax-kind fence was built and REJECTED: it is leaky (a wildcard import in the same file makes slang hand back a non-`ScopedName` syntax for the same written text) and it costs `a4`'s `S_pk`, which the law fixes. |
| **R1b** | every NON-`int` target row in the table above (`integer` / `byte` / `shortint` / `longint` / `logic` / `bit` / untyped / ranged-untyped: golden `BIN:1` size 1, ours size = the target width) is fenced out by **F3** and stays unequal — 19 `a1` rows, plus `a2`'s `T_sb1` and `T_ub0`. Cracking them needs the two unmodelled laws F3 names (the signed-literal sign-extension and the sized-decimal ranged-untyped size). | `a1`, `a2` | no |
| **R2** | GENERATE-scope localparams never reach this site at all | `a3` `G_tern`/`G_dir`, `v2` `G_int`/`G_h`/`G_loop` — golden `INT:-1` / `32'h8`, ours unchanged | no |
| **R3** | a `real`-typed parameter with an integral ternary initializer keeps size 64; golden reads `BIN:1 sz1` | `a1` `T_real` | no — `clsParam8` returns width 0 for a non-integral target, so the rule declines it |
| **R4** | the 43 `Depth` override rows re-render where golden does not (see the table above) | census | no — the override path is byte-identical |
| **R5** | Earlgrey elab param_assign rows golden reads `INT:n` and we read `UINT:n` / `BIN:…` where the initializer is a SYSTEM CALL or ARITHMETIC (`Aw = $clog2(Depth)` ×3, `WordsPerPage` ×4, `AlignedMuxSize`, `Width`), and `DefaultSeed` (a VALUE disagreement) | census, 11 rows | no — `ovEnc8` declines every one of those shapes |
| **R6** | a function-scope localparam is fenced out (`funcScope`) and `v2`'s `USE_F` keeps a `func_call` Rhs where golden folds | `v2` | no |

## Files

| file | what it is |
|---|---|
| `a1_earl52.sv` | 17 target types × {ternary, direct} for one source literal — the arm that REFUTES the brief |
| `a2_earl52.sv` | 18 literal spellings × {ternary, direct} into `int` |
| `a3_earl52.sv` | condition shape / nesting / declaration site — the condition is inert |
| `a4_earl52.sv` | the blast-radius arm: concat, replication, param hops, enum/string/real/struct/unpacked, submodule, package |
| `v1_earl52.sv` | the cross-package hop (R1), scoped vs wildcard-imported |
| `v2_earl52.sv` | the truncating arms, interface, nested instance, generate, function scope |
| `v3_earl52.sv` | the `§ modDefImportShape` topView-flip reproduction (F1) |
| `grid52.py` | per-param_assign Rhs reader, keyed by parameter NAME |
| `census52.py` | the corpus census — keyed by {Lhs fullname, Rhs span}, order-blind |
| `CENSUS_PREDICT52.txt` | the prediction, written from the pristine pair before the patched run |
| `arm52.sh` `earl52.sh` `sweeps52.sh` `byteverify52.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `bndarms52.sh` `vbnd52.sh` `varm.sh` `vsweep52.sh` `vcell52.sh` `msdist.sh` | the gate harness, carried forward from `r10earl51repro` |

## Reproduce

```sh
git worktree add /tmp/wt_r10earl52 d853e76
cmake -S /tmp/wt_r10earl52 -B /tmp/wt_r10earl52/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build /tmp/wt_r10earl52/build -j 2
cd /tmp/wt_r10earl52/tools/probe/r10earl52repro
for a in a1 a2 a3 a4 v1 v2 v3; do
  SLANG_UHDM=/tmp/wt_r10earl52/build/slang-uhdm ./arm52.sh ${a}_earl52.sv /tmp/arm_$a
  paste <(python3 grid52.py /tmp/arm_$a/g.dump --view=top) \
        <(python3 grid52.py /tmp/arm_$a/o.dump --view=top | sed 's/.*| //')
done
SLANG_UHDM=/tmp/wt_r10earl52/build/slang-uhdm ./earl52.sh /tmp/r10earl52_wd
python3 census52.py /tmp/r10earl52_wd/o.dump --view=top
```

## GATES — every one run, both binaries, patched md5 `e67ce2d00256a95dbfad0fd3e3a4ffed`, pristine `67d1e2fc290e1429b50a60a5d9b02f8c`

| gate | result |
|---|---|
| (1) build both, md5 separately | PASS — both built `-j 2`, md5s above, printed by every harness run |
| (2) `tests/check_goldens.sh` | **23 PASS / 0 FAIL** on BOTH binaries; negative control `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| (3) uhdm2rtlil, both modes | committed `gate_uhdm2rtlil.csv` vs PRISTINE testflags: **0 differing rows** (baseline FIRST); vs PATCHED testflags: **0 differing rows**; default pristine-vs-patched: **0 differing rows**. `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in every one of the four |
| (4) surelog, `--mode both` | committed `golden_surelog.csv` vs PRISTINE: **0 differing rows over 1588** (baseline FIRST); vs PATCHED: **0 differing rows over 1588** |
| (5) byteverify `SELFCHECK=1 SELFCHECK1=1` | uhdm2rtlil **0 movers / 1358**; surelog **1 mover / 953** — `./default/Earlgrey_0_1-71da2fd7/slang.uhdm`, the intended target and the ONLY one. Both controls fire (`SELFCHECK` 1357/1358 and 952/953; `SELFCHECK1` exactly 1 and exactly 2 = the corruption + the real mover). Earlgrey_0_1/testflags is SLANG_REJECT on both binaries, so it has no database to move |
| canaries | `canaries.sh` **ok=66 changed=0 absent=0 unknown-names=0**; `ctcan2.sh` surelog `EXPECT_UNKNOWN=1` **ok=58 changed=0**, uhdm2rtlil `EXPECT_UNKNOWN=6` **ok=2 changed=0**, both PASS; `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| boundaries | `vbnd52.sh` over `r10earl38/45/46/47/48/49/50/51repro`: **total=81 identical=81 differing=0 no_output=0** |
| DEF fence | Earlgrey elab dump lines 1..1196437 `md5 c69245ac103c4a355e58b0ef99234970` on BOTH sides |

The whole-database byte diff is the attribution: **4 changed lines in
4 652 435**, every one of them named and predicted.
