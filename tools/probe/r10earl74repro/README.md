# r10earl74 — § dimBoundInheritsParamEnc74: a folded array-dimension bound wears the ENCODING of the parameter it substituted

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `3dba439`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl73 named as R0 — 36 cmp lines, one head,
byte-identical in both modes — is CLEARED in both modes. 36 -> 17 lines, one
head to one head, and every other named row's head is unchanged.**

---

## 1. The head, decoded before any code was written

`HEAD_BEFORE_default.cmp` / `HEAD_BEFORE_testflags.cmp` are the verbatim
pristine logs (binary md5 `9eacde42bc0cbeb98b1c8c33855b4e33`, rebuilt from
`3dba439` in my own worktree and **byte-identical to the main tree's build**).
They reproduce r10earl73's committed `HEAD_AFTER_*` **byte for byte**, so this
pass starts on exactly the object earl73 named.

```
LHS (golden)                             RHS (ours)
constant     31:30-31:35                 constant     31:30-31:35
|vpiParent -> operation 31:30-31:35      |vpiParent -> operation 31:30-31:35
|vpiDecompile:32768                      |vpiDecompile:32768
|vpiSize:32                              |vpiSize:32
|INT:32768                               |UINT:32768
|vpiConstType:7                          |vpiConstType:9
```

**Which arm.** Read the generated `Compare` order before naming the field:

```c++
// UHDM/build/generated/src/range.cpp   — reads VpiSize, Left_expr, Right_expr
// UHDM/build/generated/src/expr.cpp:83
int32_t expr::Compare(...) {
  basetype_t::Compare(...)                            // VpiType/VpiName/VpiDefName
  lhs->VpiDecompile().compare(rhs->VpiDecompile())    // "32768" == "32768"
  lhs->VpiSize() - rhs->VpiSize()                     // 32 == 32
  SafeCompare(lhs->Typespec(), rhs->Typespec(), ...)  // both absent
}
// UHDM/build/generated/src/constant.cpp:58
int32_t constant::Compare(...) {
  basetype_t::Compare(...)                            // = expr::Compare above
  lhs->VpiConstType() - rhs->VpiConstType()           // 7 vs 9  <-- THE HEAD
}
```

So the failing field is **`vpiConstType`, and it is the last field reached**.
`vpiValue` (`INT:` vs `UINT:`) is **not compared at all** — `uhdm-dump` prints
it, the judge does not read it — but it is stamped from the same `Value` and
must follow.

**Which object.** `prim_generic_ram_1p.sv:31`

```systemverilog
  logic [Width-1:0]     mem [Depth];
                             ^^^^^  31:30-31:35
```

The `[Depth]` size form is Surelog's `[0 : Depth-1]`, so the head constant is
the substituted **value of `Depth`** sitting as operand 0 of the `-1`
operation. `Depth` reaches this instance through

```
prim_generic_flash.sv:39   localparam int WordsPerBank = PagesPerBank * WordsPerPage;  // 256*128
prim_generic_flash.sv:271  prim_ram_1p #( .Width(DataWidth), .Depth(WordsPerBank), ... ) u_mem
prim_ram_1p.sv:38          prim_generic_ram_1p #( ..., .Depth(Depth) ) u_impl_generic
```

in `top_earlgrey.u_flash_eflash.gen_flash_banks[0|1].i_core.i_flash
.gen_generic.u_impl_generic.u_mem.gen_generic.u_impl_generic`.

**The corpus carries its own positive AND negative control, in the SAME module
and the SAME declaration.** `pacen74` on both databases:

| instance of `prim_generic_ram_1p` | `Depth` param_assign, golden AND ours | golden's `mem [Depth]` bound | ours, pristine |
|---|---|---|---|
| `u_spi_device…u_mem…u_impl_generic` | `UINT:512` ct 9 sz 32 | `UINT:512` ct 9 | `UINT:512` ct 9 ✓ |
| `u_rom_rom.u_prim_rom…u_impl_generic` | `UINT:4096` ct 9 sz 32 | `UINT:4096` ct 9 | `UINT:4096` ct 9 ✓ |
| `u_ram1p_ram_main.u_mem…u_impl_generic` | `UINT:16384` ct 9 sz 32 | `UINT:16384` ct 9 | `UINT:16384` ct 9 ✓ |
| `gen_flash_banks[0]…u_impl_generic` | **`INT:32768` ct 7** sz 32 | **`INT:32768` ct 7** | `UINT:32768` ct 9 ✗ |
| `gen_flash_banks[1]…u_impl_generic` | **`INT:32768` ct 7** sz 32 | **`INT:32768` ct 7** | `UINT:32768` ct 9 ✗ |

Golden's bound tracks the `param_assign` in all five; we wrote `UINT:` in all
five. **And the inverse exists too**: `flash_mp.sv:14`
`localparam int TotalRegions = MpRegions+1;` sizing `flash_mp.sv:54`
`logic [AllPagesW-1:0] region_end[TotalRegions]` — golden's bound is `UINT:9`
ct 9, ours is `INT:9` ct 7, and the `TotalRegions` param_assign is `UINT:9`
ct 9 **on both sides**. So the rule cannot be a sign rule; it must be
INHERITANCE.

`rngcen74` (this pass's census, r10earl73's `rngcen73` unchanged) reproduces
r10earl73's count exactly: Earlgrey/default, 90,076 shared `range` cells,
**9 (ct, tag)-only disagreements** — the 6 `mem` cells and the 3 `region_end`
cells, and nothing else. (`CENSUS.txt`, and `who74.py` prints their owner
chains.)

---

## 2. The law

**§ dimBoundInheritsParamEnc74 — the folded constant inside a SIZE-FORM
unpacked array dimension (`[N]` -> `[0 : N-1]`) carries the `vpiConstType` and
the value TAG of the `param_assign` of the parameter that sized it, read out of
the NEAREST ENCLOSING SCOPE. Only the encoding: not the size, not the
decompile, not the typespec.**

### Decoded from Surelog

1. `CompileHelper::compileRanges`
   (`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:4038-4155`)
   builds the size form as

   ```c++
   constant *lexpc = s.MakeConstant();            // :4045-4050
   lexpc->VpiConstType(vpiUIntConst); lexpc->VpiSize(64);
   lexpc->VpiValue("UINT:0"); lexpc->VpiDecompile("0");
   range->Left_expr(lexpc);
   expr *rexp = any_cast<expr*>(compileExpression(component, fC, rexpr,
                    compileDesign, reduce, range, instance, muteErrors));
   ...
   operation *op = s.MakeOperation();             // :4136  "Decr by 1"
   op->VpiOpType(vpiSubOp);
   op->Operands()->push_back(rexp);
   constant *one = s.MakeConstant();
   one->VpiValue("INT:1"); one->VpiConstType(vpiIntConst); one->VpiSize(64);
   op->Operands()->push_back(one);
   ```

   — the exact shape `rngcen74` prints, `INT:1`/64 tail included.

2. When `rexpr` names a parameter, `compileExpression` lands in
   `CompileHelper::getValue` (same file, `:871-1120`), whose instance arm is

   ```c++
   sval = instance->getValue(name);               // :966 / :973
   if (sval && sval->isValid()) {
     UHDM::constant *c = s.MakeConstant();
     c->VpiValue(sval->uhdmValue());              // "INT:" / "UINT:" + digits
     setRange(c, sval, compileDesign);
     c->VpiDecompile(sval->decompiledValue());
     c->VpiConstType(sval->vpiValType());         // vpiIntConst / vpiUIntConst
     c->VpiSize(sval->getSize());
     result = c;
   }
   ```

   and whose fallback arm (`:986-1024`) **walks the ModuleInstance chain
   outward**, finds the `param_assign` in `netlist->param_assigns()` whose
   `Lhs()->VpiName()` is the name, and `clone_tree`s its `Rhs`.

3. That `Value` is the SAME object `NetlistElaboration::elab_parameters_`
   (`src/DesignCompile/NetlistElaboration.cpp:429-432`) stamps into the
   parameter's own `param_assign` Rhs constant:
   `VpiValue(value->uhdmValue())`, `VpiDecompile(value->decompiledValue())`,
   `VpiSize(value->getSize())`, `VpiConstType(value->vpiValType())`.
   **So the bound's encoding IS the param_assign's, by construction.**

4. **But not the size.** `NetlistElaboration.cpp:448` then runs
   `CompileHelper::adjustSize(<the formal's typespec>, …)` over the
   `param_assign` copy — and over the bound copy it does not. Measured on
   golden: `s_sz [D]` in `g1_dims74.sv` has bound size **64** where its own
   `param_assign` is size **32**. That is why this pass touches ONLY
   `VpiConstType` and the `VpiValue` prefix and leaves every size arm of
   `buildUnpackedRanges` — § dimFoldOverriddenParam23,
   § dimFoldOverrideChainWidth26, § dimFoldReducedTypedWidth26 — exactly as
   they were measured.

### Measured on golden

`gengrid74.py` generates `g1_dims74.sv`: **7 dimension spellings**
(`[D]`, `[D-1:0]`, `[0:D-1]`, `[D][2]`, a PACKED `[D-1:0]`, an `array_net`, a
typedef'd unpacked array) x **what the dimension reads** (14 module-localparam
initializer shapes — literal / `*` / `/` / `-` / `+` / `%` / `**` / `<<` /
`>>` / `&` / `$clog2` / a bare ref / a constant ternary / a cast; an untyped
localparam; a QUALIFIED and a WILDCARD-IMPORTED package parameter; 13 override
actuals; a genvar-derived localparam) x **the home** (module body, gen-for,
nested gen-for, three sink instances, a two-hop override chain, DEF and ELAB
views).

`law74.py` is the test, and `GOLDEN_TABLE.txt` is its output:

> **over the 74 size-form dimension bounds that have a `param_assign` for their
> sizing parameter in the SAME instance, GOLDEN INHERITS THE ENCODING ON 74 AND
> DIFFERS ON 0** — in both directions and in every home.

| what the dimension reads | golden's bound = its param_assign |
|---|---|
| `localparam int L = A * B` / `A / B` / `A - B` / `A % 7` / `2 ** B` | `INT:` ct 7 |
| `localparam int L = A + B` / `B << 2` / `A >> 5` / `A & 384` / `$clog2(A)` / `8` / `A` / a ternary | `UINT:` ct 9 |
| `localparam` UNTYPED `= A * B` | `INT:` ct 7 (bound size 64, pa size 32) |
| wildcard-imported `pk74::PM = 4 * 2` | `INT:` ct 7 |
| wildcard-imported `pk74::PP = 8` | `UINT:` ct 9 |
| `.D(A*B)` / `.D(A/B)` / `.D(A-B)` on an instance | `INT:` ct 7 |
| `.D(A+B)` / `.D(B<<2)` / `.D($clog2(A))` / `.D(A)` / `.D(8)` | `UINT:` ct 9 |
| `.D(LM)` with `localparam int LM = A*B` (the Earlgrey shape) | `INT:` ct 7 |
| `.D(LA)` with `localparam int LA = A+B` | `UINT:` ct 9 |
| gen-for `localparam int Gmul = A*B` / nested gen `Nmul` | `INT:` ct 7 |
| gen-for `localparam int Ggv = (gi+1)*4` (GENVAR-derived) | `INT:` ct 7 |
| gen-for `localparam int Ggvs = gi + 8` | `UINT:` ct 9 |
| two-hop chain `chain74 -> mid74(.MD(CM)) -> snk74(.D(MD))` | `INT:` ct 7 at every hop |

The DEF and ELAB views answer identically in every cell, and so do the two
gen-for iterations and the three sink instances.

---

## 3. What is claimed, and what is refused

The change is **one predicate plus one design-final pass**:

* `src/TypeEmit.cpp` `buildUnpackedRanges`, the size-form param-sized arm:
  resolve the sizing parameter's already-emitted `param_assign` encoding when
  it is available, and record `(the bound constant, the parameter's name)`;
  the three existing emit arms take the inherited `(ct, tag)` in place of their
  hard-coded one and are otherwise untouched.
* `src/UhdmExporter.cpp`, design-final: for each recorded pair, walk the bound's
  own `VpiParent` chain outward, take the first enclosing `scope` whose
  `Param_assigns()` holds a `param_assign` of that name with a constant `Rhs`,
  and stamp its `vpiConstType` and value prefix onto the bound.

**The design-final pass is the authoritative one.** Both steps read the same
source of truth (the parameter's own elaborated value), and where the
design-final walk finds a `param_assign` it overwrites whatever the emit-time
step wrote, so the two cannot disagree; where it finds none, the emit-time
value stands. The emit-time step is kept because it is the natural place for
the rule and because it is what makes `R10E23_DIMDBG`'s new `inh=` field report
what was knowable at emission — which is how the ordering problem below was
found in the first place.

**Why design-final.** The array declaration is emitted BEFORE its own instance
body's `param_assigns` exist, and the ELAB-instance and gen-scope producers
live in `ModuleEmit`, not `ParamEmit`, so `paramRhsObj` / `elabParamRhsObj6`
never see them. `R10E74_ENCDBG=1` reports `elab=0 def=0` for every instance
parameter and every gen-scope localparam; a symbol-map version of this law
moved 51 of the grid's 159 cells and left the whole gen-scope and multi-instance
families behind. Reading the EMITTED `param_assign` instead of a symbol map is
also what makes the rule per-INSTANCE by construction — and it is what Surelog
itself does at `CompileExpression.cpp:986-1024`.

`R10E23_DIMDBG=1` now also prints `inh=<ct><TAG>` per unpacked dim fold, and
`R10E74_ENCDBG=1` prints one line per recorded pair with the `param_assign` it
resolved.

**Claimed**: a size-form unpacked dimension on an `array_var` or an `array_net`
whose size names a parameter, when BOTH the bound and that parameter's
`param_assign` Rhs are one of the two DECIMAL encodings (`vpiIntConst` /
`vpiUIntConst`).

**Refused, deliberately, each with the measurement that says why**:

* **A LITERAL size.** `sizeSyn->kind != IntegerLiteralExpression` guards the
  arm, so a written `[24]` or `[2]` never reaches it and no record is made.
  **Both of the mover predictor's false positives are exactly this**, and both
  are refuted in `PREDICT_R0.txt` by reading the source:
  `rggen_register_common.sv:57 logic [DATA_WIDTH-1:0] write_mask[2]` (whose `2`
  coincides with the same instance's `localparam int WORDS = DATA_WIDTH /
  BUS_WIDTH`, `INT:2`) and `prim_keccak.sv:248 localparam logic [63:0] RC [24]`
  (whose `24` coincides with `localparam int MaxRound = 12 + 2*L`, `INT:24`).
  Golden writes `UINT:2` and `UINT:24` on those bounds — the literal's own
  encoding — and so do we, before and after. The patched Earlgrey database
  still reports the `RC` cells unmoved, which is the positive check that the
  literal guard holds.
* **Any home that is not an `array_var` or an `array_net`.** The arm this law
  rides is already gated on `parent->UhdmType() == uhdmarray_var ||
  uhdmarray_net`, so a `parameter`'s own unpacked-array typespec, a package
  `array_typespec` and a DEF-view `io_decl` dim are all outside it. No corpus
  or grid cell measures golden either way on those homes; the restriction is
  inherited from the existing arm and is deliberately NOT widened here.
* **The RANGED spellings** `[D-1:0]` and `[0:D-1]`, packed or unpacked: golden
  folds the WHOLE bound to a single constant there (`INT:257`, no operation)
  and we already match, in every one of the grid's rows.
* **A parameter whose own `param_assign` we do not fold to a constant.**
  `localparam int Lcast = int'(A / B)` — golden folds the cast and we keep an
  `operation`, so there is no encoding to inherit and the bound keeps what it
  had. 6 grid cells, still wrong before and after; r10earl73's R2.
* **The CROSS-PACKAGE PACKED bound** (`logic [pk74::PM-1:0] x`), a different
  builder (§ crossPkgRangeBoundFold). Golden `INT:8`, ours `UINT:8`, 6 grid
  cells, and ZERO cells in either corpus. Ranked below as R2.
* **An INLINE EXPRESSION dimension** (`logic [3:0] w_mul [A * B]`, no parameter
  named): golden's bound is the reduce of the expression at size 64
  (`INT:512`), ours is `UINT:512` at 32. 15 grid cells, ZERO in either corpus.
  Ranked below as R3.

---

## 4. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 36 cmp lines, 1 head | **17 cmp lines, 1 head** |
| Earlgrey_0_1 / testflags | 36 cmp lines, 1 head | **17 cmp lines, 1 head** |

The two modes stay identical byte for byte (`HEAD_AFTER_*.cmp` differ in
nothing at all).

**Earlgrey range census** (`CENSUS.txt`, `rngcen74` read STRAIGHT out of the
`.uhdm` — Earlgrey's `uhdm-dump` is >1 GB and was never produced):

| mode | shared range cells | (ct,tag)-only disagreements before | after | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG |
|---|---:|---:|---:|---:|---:|---:|
| default | 90,076 | **9** | **0** | **9** | 0 | 0 |
| testflags | 90,191 | **13** | **0** | **13** | 0 | 0 |

The other 23,009 differing range cells are the wholly separate pre-existing
bound-SHAPE family and are byte-for-byte unchanged.

**The `param_assign` census did not move at all**: `pacen74`, pristine vs
patched, 30,808 shared cells, **0 differing**. Golden vs ours stays at 182
differing before and after.

**Grid** (`GRID_SCORE.txt`), 3-way, BOTH views, identical in both:

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|
| `g1_dims74.sv` (2,152 range cells) | **159** | 0 | 0 | 43 |

and the law test on our own output goes from **44 / 74 inherited** to
**74 / 74** — the same number golden scores.

The 43 break down exactly: **6** cross-package packed bounds (R2), **6** cast
cells (R4), **15** inline-expression cells (R3), **15** on `.D(A+B)`'s
64-vs-32 bound SIZE (a pre-existing size residue, tag already equal on both
sides) and **1** on the typedef'd unpacked array's shape.

---

## 5. Gates

All green — `GATES.txt` has every number. In one line: both binaries built
`-j 2` and frozen `chmod 555` before any sweep, every `cmds.txt` audited by
binary PATH; goldens 23/0 on both binaries and 0/23 on `/bin/false`;
uhdm2rtlil **679/50/2 in both modes with 0 differing rows** against the
committed baseline AND against my own pristine sweep; surelog **0 differing
rows over 1588** with an identical nine-way status histogram — **no row
converted and `results/*.csv` not edited**; byte movers **0/1358** and
**2/956**, the two being exactly the PREDICTED Earlgrey databases; 52 + 8
canary rows unchanged, both supplementary canary suites PASS, `canaudit`
audited=29 UNCOVERED=0 FENCE-BREACH=0; all five protected databases
byte-identical with `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on
their pins; and every other named row's head is unchanged while Earlgrey goes
36 -> 17 in both modes.

Movers were **PREDICTED BY NAME from the PRISTINE databases first**
(`PREDICT_R0.txt`, `predict74.sh` + `inhchk74`): 0 of 1358 uhdm2rtlil databases
carry a bound/param_assign encoding disagreement of any kind, so the prediction
was "no uhdm2rtlil database can move" and 0 moved; on the surelog side the
over-approximating stage 1 flagged three names and stage 2 refuted one of them
by reading its source (`Rggen`'s literal `[2]` dims), leaving the two Earlgrey
databases — and exactly those two moved.

---

## 6. Boundary

`ARMS.txt` adjudicates every moved arm and `NEUTRAL.txt` separates "the law
fired" from "the build shifted" with a third, arm-disabled binary.

- **WIDE, per file**: `PROCESSED=3380 identical=6478 DIFFERING=6 no_output=276`
- **DIR, per directory**: `PROCESSED=1491 identical=2727 DIFFERING=11 no_output=244`

Three sources moved in the wide walk: this pass's own grid (the positive
control), `r10vearl73repro/v6_v73.sv` (**6 cells TO-GOLDEN, 0 away** — an
earlier pass's arm carrying this law's shape), and `r10buvm22repro/g22.sv`,
which the neutral binary proves is NOT this law: with the arm off it still
differs, and the whole difference is the associative-array bound's
allocation-tracking garbage number. The dir walk adds `r10uvm75repro`,
`r10uvm76repro` and `r10uvm88repro`, all **0 lines once both dumps are
sorted** — the documented `design::Task_funcs` list-ORDER coin. Every rc=139
pairs A with B on both binaries; no new crash, no new timeout.

---

## 7. Residues, ranked (R0 first)

**R0 — THE NEW EARLGREY HEAD, both modes, 17 lines, 1 head, byte-identical
across the two modes (`HEAD_AFTER_*.cmp`). Golden puts a `ref_typespec` on a
REPLICATION-COUNT constant and we put none.**

```
flash_phy_core.sv:190      prog_data_packed = {DataWidth{1'b1}};
                                               ^^^^^^^^^  190:27-190:36
in top_earlgrey.u_flash_eflash.gen_flash_banks[0].i_core

LHS (golden)  ref_typespec  vpiFullName: work@top_earlgrey.u_flash_eflash
                                         .gen_flash_banks[0].i_core
              vpiParent -> constant 190:27-190:36
              vpiActual -> int_typespec  flash_phy_pkg.sv:17:13-17:16
RHS           <null>
```

The `int_typespec` is the declared type of `flash_phy_pkg.sv:17
parameter int DataWidth = flash_ctrl_pkg::DataWidth;`, read through
`module flash_phy_core import flash_phy_pkg::*;`, and the ref's fullname is the
OWNING INSTANCE, not the package. The owner is named by the head itself (the
`vpiParent` line): the `constant` at `190:27`. This is the same family as
r10earl72's R1 — *golden stamps a folded constant's `ref_typespec` and we do
not* — reached one hop further in: a replication COUNT rather than a
`cont_assign` fold.

**R1 — earl72's R1, unchanged and still the largest Earlgrey family: the
gen-scope `cont_assign` typespec twin, 58 objects / 174 census cells, BOTH
modes.** Golden stamps the fold's `ref_typespec` and we do not, on every one;
all owned by a `gen_scope` (the `u_xbar_main/u_sm1_*` family) and the typespec
golden wants is an UNSIGNED `int_typespec`. Site `src/ModuleEmit.cpp` ~14786 /
`gs->Cont_assigns` ~16198. `r10earl72repro/g2_origin72.sv` row H1 is the
ready-made positive control. **Promoted in rank by this pass's finding: R0 and
R1 are almost certainly ONE law** — both are a missing `ref_typespec` on a
folded constant whose typespec golden takes from the parameter it folded.

**R2 — NEW: the CROSS-PACKAGE PACKED bound does not inherit either.**
`logic [pk74::PM-1:0] x` and `logic [PM-1:0] x` with
`localparam int PM = 4 * 2` in a wildcard-imported package: golden's left-bound
operand is `INT:8` ct 7, ours is `UINT:8` ct 9. Six cells in `g1_dims74.sv`
(the orphan `logic_typespec` rows in `GRID_SCORE.txt`), **ZERO in either
corpus**. It is § crossPkgRangeBoundFold's builder in `src/TypeEmit.cpp`
~3164-3250, not `buildUnpackedRanges`, which is why this pass does not reach
it. The same one-line inheritance would clear it once the same
"walk-out-and-read-the-param_assign" step is available there.

**R3 — NEW: an INLINE EXPRESSION dimension is not folded the way golden folds
it.** `logic [3:0] w [A * B]` with no parameter named: golden's bound operand
is the ExprEval reduce at SIZE 64 (`INT:512` ct 7 for `*` `/` `-`, `UINT:8` at
64 for `<<` and `$clog2`), ours is `UINT:512` at the declared width 32 — both
the size and the tag. 15 cells in `g1_dims74.sv`, **ZERO in either corpus**.
This is r10earl71's per-operator ENCODER table applied to a dimension
expression rather than to an override actual; `ovEnc8`/`ovMath73` in
`src/ParamEmit.cpp` already model it and would have to be reachable from
`TypeEmit`.

**R4 — earl73's R2 (the `unsigned'(...)` cast) reaches further than earl73
knew: it now BLOCKS a dimension bound too.** `localparam int Lcast =
int'(A / B)` sizing `logic [3:0] h_cast_sz [Lcast]`: golden's param_assign is
the folded `UINT:128` and ours is still an unfolded `operation` (op 67), so
there is no encoding for the bound to inherit and the bound stays `INT:128`
where golden has `UINT:128`. Clearing the cast fold clears 6 grid cells here
for free. 0 cells in either corpus.

**R5 — earl73's R5, reproduced and re-confirmed by this pass's neutral-binary
control: our ASSOCIATIVE-ARRAY dimension bound is a garbage number that tracks
the binary's ALLOCATION LAYOUT.** `typedef C22 ka_cls_t[string];` — golden's
range right bound is a `constant` `STRING:associative`, decompile
`associative`, `vpiConstType:6`, with a `string_typespec`; ours is an
`operation` over a number in the tens of millions (`22383993` on the pristine
binary, `22392217` on both the patched and the neutral one). Site
`src/TypeEmit.cpp` ~10359 (`mkB` in `buildUnpackedArrayTypedefTs`). Invisible
to both corpora, but it makes EVERY future pass's boundary walk report a
spurious mover on that one file.

**R6 — earl73's R3 (the three refused ACTUAL shapes: an unsized based literal,
a comparison actual, a XOR actual) and its R4, carried forward unchanged; then
earl71's R1 / R2 and earl69's R1 / R5 prettyPrint names.**

---

## 8. Reproduction

Build the four direct `.uhdm` readers against `~/.local/{include,lib64}`:

```
g++ -O2 -std=c++17 <rngcen74|pacen74|findobj74|inhchk74>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <name>
```

then

- `SLANG_UHDM=<bin> ./earl74.sh <outdir> [default|testflags] --nodump` — the
  official Earlgrey comparison (golden comes from the immutable cache, never
  re-run; NEVER dump Earlgrey);
- `rngcen74 <db>` — the RANGE-bound census; `rgjoin74.py <g.rg> <o.rg>` — the
  keyed join with the CT/TAG-ONLY vs OTHER split; `who74.py <g.rg> <o.rg>` —
  the owner chain of every (ct,tag)-only disagreement;
  `score74.py <g.rg> <pris.rg> <patched.rg>` — the 3-way scorer;
- `pacen74 <db>` + `msjoin74.py` — the `param_assign` value-encoding census
  (used here only to prove nothing moved there);
- `law74.py <db.rg> <db.pa> <src.sv>` — **THE LAW TEST**: every size-form
  dimension bound next to the `param_assign` of its sizing parameter;
- `findobj74 <db> <line> <col>` — locate an object by span and print its owner
  chain;
- `gengrid74.py > g1_dims74.sv` — regenerate the grid;
  `RNGCEN74=… PRIS=… [PATCHED=…] ./arm74.sh <arm.sv> <dir>` — build one arm with
  Surelog and both frozen binaries in both views and census all of them;
  `grid74_tbl.py <g.rg> <o.rg> [filter]` — render golden vs ours per cell;
- `INHCHK=… ./predict74.sh <sweep-workdir> <out.txt>` — the mover prediction
  (stage 1; it only READS databases a sweep already produced, so no test is
  dispatched and none of the four slang-fenced tests is named);
- `byteverify.sh`, `ct8rows.sh`, `rowheads.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh` — the sweep gates;
- `PATCHED_BIN=… PRISTINE_BIN=… PROBE_ROOT=… STAGE=… vwide74.sh <filelist> <out>`
  and `vdir74.sh <dirlist> <out>` — the exhaustive boundary;
- `R10E23_DIMDBG=1` (one line per unpacked dim fold, now with `inh=`) and
  `R10E74_ENCDBG=1` (one line per recorded bound with the `param_assign` the
  design-final pass resolved) are the two traces.

No integration, commit, main-tree edit, `results/` edit, stash or fenced-test
dispatch belongs to this pass.
