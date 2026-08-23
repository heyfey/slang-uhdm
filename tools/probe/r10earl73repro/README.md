# r10earl73 — § ovActReduceIntOp73: a parameter VALUE's encoding is decided by the ACTUAL's OPERATOR, not by the formal's declared type

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `6c74d2a`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl72 named as R0 — 64 cmp lines, one head,
byte-identical in both modes — is CLEARED in both modes. 64 -> 36 lines,
one head to one head, and every other named row's head is unchanged.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_default.cmp` / `HEAD_BEFORE_testflags.cmp` are the verbatim
pristine logs (binary md5 `26fbd8c01ce0de4b3e257726f388de86`, rebuilt from
`6c74d2a` in my own worktree and byte-identical to the main tree's build).
They are identical to each other modulo nothing at all — the two modes produce
the same object ids here — and they reproduce r10earl72's committed
`HEAD_AFTER_*` exactly, so this pass starts on the object earl72 named.

```
LHS (golden)                          RHS (ours)
constant     16:32-16:35              constant     16:32-16:35
|vpiParent -> param_assign 16:17-16:35   |vpiParent -> param_assign 16:17-16:35
|vpiDecompile:128                     |vpiDecompile:128
|vpiSize:32                           |vpiSize:32
|INT:128                              |UINT:128
|vpiTypespec -> ref_typespec ->       |vpiTypespec -> ref_typespec ->
|   int_typespec 16:13-16:16          |   int_typespec 16:13-16:16
|vpiConstType:7                       |vpiConstType:9
```

**Which arm.** Read the generated `Compare` order before naming the field:

```c++
// UHDM/build/generated/src/expr.cpp:83
int32_t expr::Compare(...) {
  basetype_t::Compare(...)                            // VpiType/VpiName/VpiDefName
  lhs->VpiDecompile().compare(rhs->VpiDecompile())    // "128" == "128"
  lhs->VpiSize() - rhs->VpiSize()                     // 32 == 32
  SafeCompare(lhs->Typespec(), rhs->Typespec(), ...)  // both -> int_typespec 16:13
}
// UHDM/build/generated/src/constant.cpp:58
int32_t constant::Compare(...) {
  basetype_t::Compare(...)                            // = expr::Compare above
  lhs->VpiConstType() - rhs->VpiConstType()           // 7 vs 9  <-- THE HEAD
}
```

So the failing field is **`vpiConstType`, and it is the last field reached**.
`vpiValue` (`INT:128` vs `UINT:128`) is **not compared at all** — `uhdm-dump`
prints it, the judge does not read it — but it is stamped from the same
`Value` as the const type and must follow.

**Which object.** `prim_flash.sv:16`

```systemverilog
  parameter int WordsPerPage = 256, // words per page
```

instantiated at `flash_phy_core.sv:213-217`

```systemverilog
  prim_flash #(
    .PagesPerBank(PagesPerBank),
    .WordsPerPage(WordsPerPage / WidthMultiple),   // 256 / 2 = 128
    ...
  ) i_flash (
```

where `WordsPerPage` (256) and `WidthMultiple` (`DataWidth / BusWidth` = 2) are
`parameter int`s of the wildcard-imported `flash_phy_pkg`
(`flash_phy_pkg.sv:11` and `:34`). The span `16:32-16:35` is the
**declaration's** `256`, not the actual's text — Surelog stamps the elaborated
override constant with `assign->getAssignId()`'s core members
(`NetlistElaboration.cpp:443`). The three sibling overrides on the same
instantiation — `.PagesPerBank(PagesPerBank)`, `.DataWidth(DataWidth)`,
`.SkipInit(SkipInit)`, all bare parameter references — are `UINT:`/ct 9 in
golden AND in ours. **Only the one whose actual is a DIVISION differs.**

---

## 2. The law

**§ ovActReduceIntOp73 — the vpiConstType and value TAG of an instantiation
parameter's elaborated value are decided by the ACTUAL EXPRESSION'S TOP
OPERATOR, through UHDM's `ExprEval::reduceExpr`, and NOT by the formal
parameter's declared type. Subtraction, multiplication, division, modulo,
power and unary minus store `INT:`/`vpiIntConst`; addition stores `UINT:` only
when NEITHER reduced operand is itself `INT:`; shifts, bitwise AND/OR,
`$clog2`, a cast, a plain decimal literal and a bare parameter reference store
`UINT:`/`vpiUIntConst`. The DIGITS are the MATHEMATICAL fold computed as
64-bit words, with its own sign, NEITHER masked to the formal's width NOR
wrapped at the actual's own type; the SIZE is the formal's declared width.**

### Decoded from Surelog

The override path, end to end:

1. `DesignElaboration::collectParams_`
   (`~/git-repos/Surelog/src/DesignCompile/DesignElaboration.cpp:2147`) compiles
   the named actual with `Reduce::Yes`. `CompileHelper::compileExpression`
   builds the `operation` and reduces it at
   `src/DesignCompile/CompileExpression.cpp:4288` —
   `result = reduceExpr(result, ...)` — i.e. `UHDM::ExprEval::reduceExpr`.
2. `ExprEval::reduceExpr` types the folded constant **PER OPERATOR**
   (`~/git-repos/UHDM/templates/ExprEval.cpp`):

   | arm | line | result |
   |---|---|---|
   | `vpiSubOp` | 3343 | `"INT:" + to_string(v)`, size 64, `vpiIntConst` |
   | `vpiMultOp` | 3379 | same |
   | `vpiModOp` | 3609 | same |
   | `vpiPowerOp` | 3684 | same |
   | `vpiDivOp` | 3703 | same |
   | unary `vpiMinusOp` | 3307 | same, size = the operand's |
   | `vpiAddOp` | 3160 | `UINT:` **only when neither reduced operand is `vpiIntConst`/`vpiStringConst`/`vpiRealConst`/`vpiDecConst`**; the `:3198` else-arm gives `INT:` |
   | `vpiLShiftOp`/`vpiRShiftOp`, `vpiBitAndOp`/`vpiBitOrOp`, `$clog2` | — | `UINT:`, `vpiUIntConst` |

   Every one of these computes in `int64_t`/`uint64_t` on the values
   `get_value()` reads out of the REDUCED OPERANDS — never at the actual's
   SystemVerilog type — which is why a `int'` overflow is not wrapped.
3. `DesignElaboration.cpp:2170` turns the folded constant back into a `Value`:
   `value = m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize())`, and
   `ExprBuilder::fromVpiValue` (`src/Expression/ExprBuilder.cpp:924-946`)
   reads the TYPE off the string prefix (`INT:` -> `Value::Type::Integer`,
   `UINT:` -> `Unsigned`). `instance->setValue(name, value, ...)` stores it.
4. `NetlistElaboration::elab_parameters_`
   (`src/DesignCompile/NetlistElaboration.cpp:429-432`) stamps ALL FOUR
   judge-visible fields from that ONE `Value`:

   ```c++
   c->VpiValue(value->uhdmValue());          // Value.cpp:880  "INT:"/"UINT:" + digits
   c->VpiDecompile(value->decompiledValue());// Value.cpp:925  the SAME digits, no prefix
   c->VpiSize(value->getSize());             // 64 here
   c->VpiConstType(value->vpiValType());     // Value.cpp:951  vpiIntConst/vpiUIntConst
   ```
5. `NetlistElaboration.cpp:448` then runs
   `CompileHelper::adjustSize(<the formal's typespec>, ...)`
   (`src/DesignCompile/CompileHelper.cpp:3949`). **`adjustSize` has NO arm for a
   `vpiIntConst`**: the `vpiUIntConst` arm masks the digits to the target width
   (`:3993-4001`), the `vpiBinaryConst` arm re-renders them, and everything else
   falls straight through to `:4127`

   ```c++
   } else {
     c->VpiSize(size);      // size = Bits(<formal typespec>)
   }
   ```

   — the size becomes the formal's declared width and **the digits are left
   exactly as `reduceExpr` computed them**.

That is the whole mechanism, and it explains every cell of the grid: 128 at
size 32 for an `int` formal, `INT:512` at **size 4** for a `bit [3:0]` one,
`INT:-2` at size 4 for `0 - B`, and `INT:10000000000` at size 32 for
`C * C` with `C = 100000`.

`srlgAdjustSize` (`src/ParamEmit.cpp` ~3327), which r10earl64's
§ elabCaPortParamPaCopy64 already built as a mirror of `adjustSize`, ALREADY
models that fall-through (`if (e.ct != vpiBinaryConst) { e.size = w; return; }`).
So the patch only has to supply the PRODUCER stage.

### Measured on golden

`g1_shapes73.sv` (generated by `gengrid73.py`) crosses **6 declared types x 24
actual shapes x 3 homes**; `g2_hops73.sv` adds the shapes g1 cannot reach.
`GOLDEN_TABLE.txt` has every cell. The headline: **the declared type is not an
axis and the home is not an axis.**

| actual (A = 256, B = 2, both `parameter int`) | golden, for ALL of `int` / untyped / `bit [9:0]` / `logic [31:0]` / `integer` / `signed [15:0]` |
|---|---|
| `A / B`, `A * B`, `A - B`, `A % B`, `2 ** B`, `-B`, `256 / 2`, `A * B / B` | **`INT:` / ct 7** at the declared width |
| `(A > B) ? 2 ** B : 4` (ternary onto an INT branch) | **`INT:` / ct 7** |
| `A + (B - 1)`, `(A / B) + 1`, `1 + 8'd4`, `A + WORDS`, `A % B + 1`, `-(A / B)`, `((A - B))` | **`INT:` / ct 7** |
| `128`, `A`, `A + B`, `B << 1`, `A >> 1`, `$clog2(A)`, `(A>B)?1:2`, `int'(A)`, `A & B`, `(A/B) << 1`, `(A/B) & 8'hff`, `B ? 3 : (A/B)`, no override at all | `UINT:` / ct 9 |
| `8'd128` (a based-DECIMAL literal) | `INT:` / ct 7 — r10earl71's verifier shape |
| `'h80` (an UNSIZED based literal) | `HEX:80` / ct 5, decompile `'h80` — **not claimed** |
| `A == B` (a comparison) | `BIN:0` / ct 3 / size 1 — **not claimed** |
| `A ^ B` | golden does not fold it at all (the Rhs stays an `operation`) — **not claimed** |

and the DIGITS, measured across formal widths (`g2_hops73.sv`):

| cell | golden |
|---|---|
| `parameter bit [3:0] P`, `.P(A * B)` (=512) | `INT:512` size **4** — no mask |
| `parameter bit [3:0] P`, `.P(0 - B)` | `INT:-2` size **4** |
| `parameter bit [39:0] P`, `.P(C * C)` (C=100000) | `INT:10000000000` size 40 |
| `parameter int P`, `.P(C * C)` | `INT:10000000000` size **32** — a 64-bit word, not slang's 32-bit wrap (1410065408) |
| `parameter bit [3:0] P`, `.P(WORDS)` with `localparam int WORDS = A / B` | `INT:128` size 4 |

The HOMES: `top73g` (a gen-for, two iterations) and `top73n`/`top73m` (a nested
gen inside three instances of the containing module) answer identically to the
module body in every one of the 24 shapes.

---

## 3. What is claimed, and what is refused

The change is **ONE ARM inside `ovEnc8`** in `src/ParamEmit.cpp` — the
override-encoding pipeline r10earl28 built and r10earl64 extended — plus the
two helper lambdas it needs. `ovEnc8` has three call sites and the arm rides
all three: the ELAB override (~6959), the parameter-reference HOP inside
`ovEnc8` itself (~5975), and the `int`-target DECLARATION site (~13158) that
r10earl52 gated. Nothing else in the file moves.

* **Claimed**: an actual (or a hop's initializer, or a constant-condition
  ternary's taken branch) whose top operator is `-` (binary or unary), `*`,
  `/`, `%`, `**`, or a `+` with a demonstrably `INT:` operand. The constant is
  minted `vpiIntConst` with the mathematical fold rendered as a signed decimal
  and size 64, and `srlgAdjustSize` then does to it exactly what
  `CompileHelper::adjustSize:4127` does.
* **Refused, deliberately, with the measurement that says why**:
  * an **EXPLICIT CAST** around arithmetic. `int'(A / B)` is golden `UINT:128`
    and `unsigned'(A - B)` is golden `INT:254` — one `ConversionExpression`
    node, two answers — so neither is claimed and both keep the pristine
    encoding. (`int'(A/B)` already matches; `unsigned'(A-B)` stays wrong. R4.)
  * an **UNSIZED based literal** (`'h80` -> golden `HEX:80` ct 5), a
    **COMPARISON** actual (`A == B` -> golden `BIN:0` ct 3 size 1) and a
    **XOR** actual (golden does not fold). All three are pre-existing and
    unchanged; they are the `STILL-WRONG 130` in g1's score.
  * anything whose fold does not fit `int64_t`, divides by zero, or reaches a
    leaf slang cannot value: the arm returns false and the pristine encoding
    stands.

Every combining step in `ovMath73` is overflow-CHECKED
(`__builtin_{add,sub,mul}_overflow` on `__int128`), and an overflow is a
REFUSAL, never a wrapped answer.

`ovMath73` reads a LEAF as the value slang has already STORED for it (an
`ASTContext::tryEval`), which is what `reduceExpr` sees when it substitutes a
parameter's own emitted constant, and which keeps r10vrgg18's
§ genLpFoldRefValueNotInitializer18v trap shut: a truncated
`bit [7:0] T8 = 16'h1234` contributes 52, not 4660.

---

## 4. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 64 cmp lines, 1 head | **36 cmp lines, 1 head** |
| Earlgrey_0_1 / testflags | 64 cmp lines, 1 head | **36 cmp lines, 1 head** |

The two modes stay identical modulo object ids (`HEAD_AFTER_*.cmp`).

**Earlgrey census** (`CENSUS.txt`, `pacen73` — every `param_assign` the
`UhdmListener` reaches, read STRAIGHT out of the `.uhdm`; Earlgrey's
`uhdm-dump` is >1 GB. Golden-vs-golden calibrated first: 31,897 / 39,977 cells,
0 differing):

| mode | shared cells | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|---:|
| default | 28,655 | **12** | 0 | 0 | 182 (was 194) |
| testflags | 36,735 | **20** | 0 | 0 | 182 (was 202) |

Three families moved, and they are the whole `(vpiConstType, tag)` disagreement
between golden and us on Earlgrey's `param_assign`s in the overridden class:

| parameter | site | actual | golden | cells (def) |
|---|---|---|---|---|
| `WordsPerPage` | `flash_phy_core.sv:215` | `WordsPerPage / WidthMultiple` | `INT:128` sz 32 | 8 (4 objects) |
| `Width` | `usbdev.sv:259` | `3*NEndpoints` | `INT:36` sz 32 | 2 (1 object) |
| `AlignedMuxSize` | `pinmux.sv:207` | `(NMioPads+2 > NDioPads) ? 2**$clog2(NMioPads+2) : 2**$clog2(NDioPads)` — **not overridden**, the declaration site | `INT:64` sz 32 | 2 (1 object) |

The `WordsPerPage` family is four objects because `prim_flash` passes it on to
`prim_generic_flash u_impl_generic` inside its own `gen_generic` block, in each
of `gen_flash_banks[0]` and `[1]`.

**Grids** (`GRID_SCORE.txt`), 3-way, BOTH views, identical in both:

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|
| `g1_shapes73.sv` (144 cells x homes) | **362** | 0 | 0 | 130 |
| `g2_hops73.sv` | **34** | 0 | 0 | 2 |

g1's 130 are the four refused shapes (`hlit`, `bxor`, `eq`, and the
`signed [15:0]` concat) times 6 declared types times the homes; g2's 2 are the
one `unsigned'(A - B)` cast cell.

---

## 5. Gates

All green — `GATES.txt` has every number. In one line: both binaries built
`-j 2` and frozen `chmod 555` before any sweep, every `cmds.txt` audited by
binary PATH; goldens 23/0 on both binaries and 0/23 on `/bin/false`;
uhdm2rtlil **679/50/2 in both modes with 0 differing rows** against the
committed baseline AND against my own pristine sweep; surelog **0 differing
rows over 1588** with an identical status histogram — **no row converted and
`results/*.csv` not edited**; byte movers **0/1358** and **2/956**, the two
being exactly the PREDICTED Earlgrey databases; 52 + 8 canary rows unchanged,
both supplementary canary suites PASS, `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0; all five protected databases byte-identical with
`SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on their pins; and every
other named row's head is unchanged while Earlgrey goes 64 -> 36 in both modes.

**Movers were PREDICTED BY NAME from the PRISTINE databases first**
(`PREDICT_R0.txt`, `predict73.sh` + `ctdiff73.py`): 0 of 1358 uhdm2rtlil
databases carry a `(vpiConstType, tag)` disagreement at all, so the prediction
was "no uhdm2rtlil database can move" and 0 moved; on the surelog side only
Earlgrey carries a disagreement of a shape this law claims, and only Earlgrey
moved.

---

## 6. Boundary

A COPY of `tools/probe` with **no path filter**, `.sv` and `.v`, at ANY depth,
both views, both frozen binaries, workdir-normalised whole-dump byte compare;
the file list is read on fd 3 with children `</dev/null`, `PROCESSED` is
asserted and every cell records its `rc`.

- **WIDE, per file**: `PROCESSED=3346 identical=6368 DIFFERING=50 no_output=274`
- **DIR, per directory**: `PROCESSED=1485 identical=2685 DIFFERING=42 no_output=243`

25 sources moved (x2 views = 50), two of them this pass's own grids — the
walk's positive control that it can see. Every rc=139 (20 wide, 10 dir) pairs
A with B: the pre-existing `--elabuhdm` segfaults, on both binaries. No new
crash, no new timeout.

**`ARMS.txt` adjudicates every moved arm**, with the official `uhdm-cmp` line
count pristine-vs-patched and the 3-way census. **AWAY-GOLDEN is 0 in every
arm and every view, and no arm's judge count gets worse.** Two findings are
worth naming here:

* **A NEUTRAL-BINARY CONTROL separates "the law fired" from "the build
  shifted".** A third binary was built from the patched source with the arm
  short-circuited at run time — semantically the pristine binary, but
  allocating the two extra `std::function` objects the patch adds. Re-running
  all 25 moved sources with it against the pristine binary leaves **exactly one
  source still differing: `r10buvm22repro/g22.sv`, in both views.** Every other
  moved source is byte-identical with the arm off, i.e. it moved because the law
  fired.
* **`r10buvm22repro/g22.sv` is therefore NOT this law's**, and it cannot be:
  the file declares no parameter at all. Its only changed cell is the right
  bound of the range on `typedef C22 ka_cls_t[string];` (`g22.sv:70`), where
  golden writes `STRING:associative` / `vpiConstType:6` with a `string_typespec`
  and we write an operation over a garbage number. That number tracks the
  BINARY's allocation layout, not the source: three pristine runs from three
  directories and one under a 200 kB environment pad all reproduce `22371705`
  exactly, while any rebuilt binary moves it (to `22375801` here). A
  pre-existing defect of the associative-dimension bound — recorded as R5.
* The 2 MOVED-WRONG cells in `r10vearl71repro/v3_enc71.sv` are one object
  (`B5`) seen twice: it moved onto golden's `ct=7`/`INT:12` — the fields this
  law owns — and is still missing the `ref_typespec` golden carries, which is a
  different, pre-existing residue. The scorer calls any still-unequal cell
  MOVED-WRONG; the payload in `ARMS.txt` is why this one is not a regression.
* The directory walk adds `r10uvm75repro` and `r10uvm76repro`: the documented
  `design::Task_funcs` list-ORDER coin — raw diffs of 10-18 lines over
  9,154-23,569, and **0 lines** once both dumps are sorted.

The named boundaries hold: `§ genCaNestedModuleLhsOpRhsBinds59`'s binder-mirror
arms, the port `High_conn` laws' arms (`r10earl61…69repro`, `r10v6*repro`
except the two named above), the assignment-pattern / `tagged_pattern` arms and
every uvm/buvm arm except the g22 allocation artifact are byte-identical
between the two binaries in both views.

---

## 7. Residues, ranked (R0 first)

**R0 — THE NEW EARLGREY HEAD, both modes, 36 lines, 1 head, identical modulo
ids (`HEAD_AFTER_*.cmp`). The SAME encoder, one hop further out: a folded
parameter substituted into an UNPACKED-ARRAY DIMENSION does not inherit the
encoding the `param_assign` already gives it.**

```
prim_generic_flash.sv:39   localparam int WordsPerBank = PagesPerBank * WordsPerPage;   // 256*128
prim_generic_flash.sv:271  prim_ram_1p #( ... .Depth(WordsPerBank) )
prim_generic_ram_1p.sv:31  logic [Width-1:0] mem [Depth];
                                                 ^^^^^  31:30-31:35

golden  constant <- operation(vpiSubOp) <- range <- array_var(mem)   INT:32768  ct 7  sz 32
ours    the same object                                              UINT:32768 ct 9  sz 32
```

Decompile (`32768`) and size (32) already agree; only `vpiValue`'s prefix and
`vpiConstType` differ, exactly as the cleared head did. **The `param_assign`
for `Depth` is ALREADY `INT:32768 ct 7` in both the pristine and the patched
database, and so is `WordsPerBank`'s** — the defect is that the ARRAY-DIMENSION
carrier re-renders the value instead of copying the parameter's encoding, so
the fix belongs at the array-var / typespec range site (`src/TypeEmit.cpp`
`makeBoundConst`/`emitBound` and `src/ModuleEmit.cpp`'s array-var path), not in
`ParamEmit`.

`rngcen73` (committed here) is the instrument. Earlgrey/default, every `range`
the listener reaches, 90,076 shared cells: **the (ct, tag)-only disagreements
are 9, and they are byte-for-byte the SAME 9 before and after this pass** —

| cells | golden | ours |
|---:|---|---|
| 6 | `INT:32768` ct 7 | `UINT:32768` ct 9 — R0, under `gen_flash_banks[0]` and `[1]` … `u_impl_generic/array_var(mem)` |
| 3 | `UINT:9` ct 9 | `INT:9` ct 7 — the SAME family INVERTED, so a fix must be an inheritance rule, not a sign rule |

(The other 23,009 differing range cells are a wholly separate pre-existing
family — bound SHAPES, not encodings — and are out of this head's reach.)

**R1 — earl72's R1, unchanged and still the largest Earlgrey family: the
gen-scope `cont_assign` typespec twin, 58 objects / 174 census cells, BOTH
modes.** Golden stamps the fold's `ref_typespec` and we do not, on every one;
all are owned by a `gen_scope` (the `u_xbar_main/u_sm1_*` family) and the
typespec golden wants is an UNSIGNED `int_typespec`. Site
`src/ModuleEmit.cpp` ~14786 / `gs->Cont_assigns` ~16198 (a carrier that never
sets `contAssignView`), position `ipsWidFold9`'s. `r10earl72repro/g2_origin72.sv`
row H1 is the ready-made positive control.

**R2 — the `unsigned'(...)` cast.** `g2_hops73.sv` `u_int_uns`:
`.P(unsigned'(A - B))` is golden `INT:254` and we write `UINT:254`, while
`.P(int'(A / B))` is golden `UINT:128` and we already match. One
`ConversionExpression` node, two answers; a pass that decodes what Surelog does
with `vpiCastOp` in `reduceExpr` clears both. 2 cells in the grid, 0 in either
corpus.

**R3 — the three refused ACTUAL shapes**, all measured on golden, all
pre-existing, all absent from Earlgrey's head chain: an UNSIZED based literal
actual (`'h80` -> golden `HEX:80` ct 5 decompile `'h80`, we write `UINT:128`);
a COMPARISON actual (`A == B` -> golden `BIN:0` ct 3 **size 1**, we write
`UINT:0` at the declared width); and a bitwise-XOR actual (golden leaves the
Rhs an `operation`, we fold it). 130 of g1's cells; `BuildUVMPkg` (2 cells) and
`BlackParrotComplex` (1 cell) carry one of these in both modes, which is why
they show in `predict73.sh` stage 1 and did not move.

**R4 — earl72's R2/R3/R4 carried forward unchanged**: an IMPLICITLY typed
package parameter's fold typespec is UNSIGNED in golden and SIGNED in ours; a
`$clog2` ARGUMENT fold in a DEF-view cont-assign carries the stamp in golden and
not in ours; and the `--elabuhdm` net-decl-assign whole-Rhs fold. None occurs in
either corpus.

**R5 — NEW, found by the neutral-binary boundary control: our
ASSOCIATIVE-ARRAY dimension bound is a garbage number that tracks the binary's
ALLOCATION LAYOUT.** `typedef C22 ka_cls_t[string];` — golden's range right
bound is a `constant` `STRING:associative`, decompile `associative`,
`vpiConstType:6`, with a `string_typespec`; ours is an `operation` over a
number in the tens of millions that is stable for a given binary and moves for
any other. It is invisible to both corpora today (`r10buvm22repro` is a probe
arm, not a corpus row) but it makes EVERY future pass's boundary walk report a
spurious mover on that one file, so it is worth clearing on its own.

**Carried forward from r10earl71, unchanged and ranked below the above:** its
R1 (the gen-scope UNBOUND-ref class — module parameter / outer gen localparam /
genvar bounds, golden keeps a ref with a NULL actual) and its R2 (the
own-localparam fold we have INVERTED); and earl69's R1 / R5 prettyPrint names.

---

## 8. Reproduction

Build the three direct `.uhdm` readers against `~/.local/{include,lib64}`:

```
g++ -O2 -std=c++17 <pacen73|rngcen73|findobj73>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <name>
```

then

- `SLANG_UHDM=<bin> ./earl73.sh <outdir> [default|testflags] --nodump` — the
  official Earlgrey comparison (golden comes from the immutable cache, never
  re-run; NEVER dump Earlgrey);
- `pacen73 <db>` — the `param_assign` value-encoding census;
  `msjoin73.py <golden.pa> <ours.pa> [--base <base.pa>]` — the MULTISET join,
  3-way when `--base` is given; `ctdiff73.py <g.pa> <o.pa>` — the keyed
  (vpiConstType, tag) disagreement count;
- `rngcen73 <db>` + `rgjoin73.py` — R0's own census (every `range`);
- `findobj73 <db> <line> <col>` — locate an object by span and print its owner
  chain;
- `gengrid73.py > g1_shapes73.sv` — regenerate the grid;
  `PACEN73=… PRIS=… [PATCHED=…] ./arm73.sh <arm.sv> <dir>` — build one arm with
  Surelog and both frozen binaries in both views and census all of them;
  `grid73_tbl.py` / `grid73_tbl_g2.py` / `grid73_tbl_home.py` render the tables
  in `GOLDEN_TABLE.txt`;
- `PACEN73=… PRIS=… PATCHED=… ./armscore73.sh <arm.sv> <dir>` — adjudicate one
  boundary arm (official `uhdm-cmp` count + 3-way census);
- `predict73.sh <sweep-workdir> <pacen73> [jobs]` — the mover prediction
  (stage 1; the four slang-fenced tests are FENCED-SKIPped and never named);
- `byteverify.sh`, `ct8rows.sh`, `rowheads.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh` — the sweep gates;
- `PATCHED_BIN=… PRISTINE_BIN=… PROBE_ROOT=… STAGE=… vwide73.sh <filelist> <out>`
  and `vdir73.sh <dirlist> <out>` — the exhaustive boundary.

No integration, commit, main-tree edit, `results/` edit, stash or fenced-test
dispatch belongs to this pass.
