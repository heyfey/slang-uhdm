# r10uvm93 — § streamSliceTypeBits93

**The head (R0 of uvm92, all seven UVM row-modes + BuildUVMPkg, byte-identical
across the seven):**

```
LHS (golden)                       RHS (ours, pristine)
constant: , id:309934              constant: , id:114883, line:3494:11, endln:3494:14
 |vpiDecompile:32                   |vpiDecompile:int
 |vpiSize:64                        |vpiSize:64
 |UINT:32                           |UINT:0
 |vpiConstType:9                    |vpiConstType:9
```

`~/git-repos/Surelog/third_party/UVM/uvm-1.2/src/macros/uvm_object_defines.svh`
line 3494 is the body of `` `uvm_pack_intN ``:

```
     { << int { __array }} = {{($bits(int) - (SIZE % $bits(int))) {1'b0}}, __vector};
```

Column 11..13 is the `int` **after `<<`** — the streaming concatenation's
`slice_size`, *not* one of the `$bits(int)` arguments (those sit at columns 26+
and are a different, still-open family).  Golden holds the type's WIDTH; we
held its SPELLING.

**Which field fails first.**  `expr::Compare`
(`~/git-repos/UHDM/build/generated/src/expr.cpp`) reads `VpiDecompile`, then
`VpiSize`, then `Typespec`; `constant::Compare` then reads `VpiConstType`.
`VpiValue` is **not compared at all**.  So the single cmp-visible failure here
is `VpiDecompile` — `"32"` vs `"int"`.  `VpiSize` (64) and `VpiConstType` (9)
already agreed, and the loss of the location is invisible to the judge (this
pass drops it anyway, to match golden byte for byte in the dump).

---

## 1. The decoded model (Surelog)

`CompileHelper::compileExpression`, `paStreaming_concatenation`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp` ~3063-3121)
sends the slice size down **two different roads**:

```cpp
if (fC->Type(Slice_size) == VObjectType::paSlice_size) {
  NodeId Constant_expression = fC->Child(Slice_size);
  if (fC->Type(Constant_expression) == VObjectType::paSimple_type) {
    NodeId Integer_type = fC->Child(Constant_expression);
    NodeId Type = fC->Child(Integer_type);
    exp_slice = compileBits(component, fC, Type, compileDesign, Reduce::Yes,
                            operation, instance, false, muteErrors);
  } else {
    exp_slice = compileExpression(component, fC, Constant_expression, ...);
  }
  ...
}
```

The grammar (`grammar/SV3_1aParser.g4`) is
`slice_size: simple_type | constant_expression;` and
`simple_type: integer_type | non_integer_type | ps_type_identifier;`.  ANTLR
tries `simple_type` first, so **any bare identifier** — a user typedef, a
package-scoped type, *or a plain parameter* — takes the `compileBits` road.

`CompileHelper::compileBits` (same file, ~4663) **MINTS** its answer:

```cpp
UHDM::constant *c = s.MakeConstant();
c->VpiValue("UINT:" + std::to_string(bits));
c->VpiDecompile(std::to_string(bits));
c->VpiConstType(vpiUIntConst);
c->VpiSize(64);
```

— no `populateCoreMembers`, no `VpiParent`.  That is exactly golden's head
object: **location-less, parent-less, size 64, constType 9, value AND decompile
the WIDTH**.  Its switch recognises only the integer keyword parse nodes
(`paIntegerAtomType_{Byte,Int,Integer,LongInt,Shortint,Time}`,
`paIntVec_Type{Logic,Bit,Reg}`); everything else falls to `getTypespec`, which
returns nothing for a `ps_type_identifier`, so `bits` stays **0** and the
`exp` branch mints `UINT:0` / decompile `"0"`.  `time`/`realtime`/`real`/
`shortreal` reach `Bits()` but come back invalid and drop through to the final
`else`: a bare `$bits` `sys_func_call`, no arguments, no location, parented at
the stream operation.

### The law, as measured on golden

| slice_size | golden's first operand |
|---|---|
| `byte` | minted constant, NOLOC, decompile/value **8** |
| `shortint` | minted constant, NOLOC, **16** |
| `int`, `integer` | minted constant, NOLOC, **32** |
| `longint` | minted constant, NOLOC, **64** |
| `bit`, `logic`, `reg` | minted constant, NOLOC, **1** |
| `time`, `realtime`, `real`, `shortreal` | `sys_func_call` `$bits`, NOLOC, no args |
| any other identifier (typedef, `pkg::t`, enum/struct typedef, **a parameter**) | minted constant, NOLOC, **0** |
| numeric literal (`6`, `3`) | LOCATED constant with the literal's own value |
| parenthesised / compound expression (`(WREN+2)`) | LOCATED operation |
| absent | no first operand at all |

Matching is **case-sensitive and whole-token**: `INT`, `Int`, `int_t`, `tint`,
`logic_t`, `BIT` are identifiers and all fold to 0 (arm `g93_a6_case.sv`).
The HOME does not matter — class method, package function, module `initial`,
`always_comb`, generate block, macro body, DEF view and ELAB view all fold the
same way (arms `g93_a1_slice.sv`, `g93_a2_edge.sv`, `a5`).

---

## 2. What we did, and what we do now

`ExprEmit.cpp`, `ExpressionKind::Streaming`, parsed the token after `<<`/`>>`
out of the raw source text and emitted it verbatim as a LOCATED constant with
`VpiValue("UINT:" + <token>)` — so `int` became `vpiDecompile:int`, `UINT:0`.
Golden **never** emits a type name as a slice constant, so **every cell this
pass rewrites was already wrong**; there is no pristine-right → patched-wrong
cell available in this shape.

The patch classifies the token with `UhdmExporter::streamSliceTypeBits` and
only fires when the token is a `simple_type` **and** the stream concatenation's
`{` follows it directly (so `{<< W + 2 {..}}` — a `constant_expression` — keeps
the old spelling).  Numeric tokens are untouched.

---

## 3. Known residues (named, NOT fixed here)

* **`(WREN+2)`** — a parenthesised slice size: golden emits a located
  *operation*, we still emit a spelled constant.  Unchanged by this pass; not
  present in either corpus.
* **macro-ARGUMENT slice sizes** (`` `M(int, ...) `` where the macro body is
  `{ << TYP { ... }}`): `rawText(expr.sourceRange)` reads the macro BODY, so
  the token is the macro parameter name `TYP`.  Pristine emitted
  `vpiDecompile:TYP`, we now emit `0`; golden emits the argument's own width.
  Both are wrong, neither is comparable-equal, and **neither corpus contains
  the shape** (the UVM head's `int` is a macro-body literal, which reads
  correctly).  `rawTextExpr` is the lead if it ever matters.
* **`$bits(<type>)` as a call argument** on the same UVM line (3494 col 26+)
  is a *different* family (uvm89/buvm16 R3) and is untouched here.

---

## 4. The patch

`include/UhdmExporter.h` — declares `UhdmExporter::streamSliceTypeBits` plus the
two sentinels (`kStreamSliceNotType`, `kStreamSliceBits`) and carries the
decoded model.

`src/ExprEmit.cpp` —
* `streamSliceTypeBits` (next to `rawTextPkgFold`): the case-sensitive keyword
  table, the `$bits` set, and a whole-token `ps_type_identifier` test that
  accepts `::` scoping and rejects anything else;
* `ExpressionKind::Streaming`: the token after `<<`/`>>` is classified only
  when the stream concatenation's `{` follows it directly. Then
  * `$bits` set  → a `sys_func_call` `$bits`, parented at the operation, no
    args, no location;
  * width ≥ 0    → a MINTED constant, **no location and no parent**, `vpiSize`
    64, `vpiConstType` `vpiUIntConst`, `vpiDecompile` and `UINT:` both the
    width (0 for a typedef / identifier);
  * otherwise    → the pre-existing located source-token constant, byte for
    byte as before.

## 5. Measurements

**Heads** (`rowheads.sh`, pristine b1a0447 → patched; counts are DEPTH):

| row | mode | pristine | patched |
|---|---|---|---|
| SeqDriver | default / testflags | 28 / 28 | **164 / 164** |
| SimpleUVM | default / testflags | 28 / 28 | **164 / 164** |
| Scoreboard | default | 28 | **164** |
| MiniAmiq | default / testflags | 28 / 28 | **164 / 164** |
| BuildUVMPkg | default / testflags | 29 / 29 | 29 / 29 (unchanged) |
| Earlgrey_0_1 | default / testflags | 19 / 37 | 19 / 37 (unchanged) |
| Rggen | default | 36 | 36 (unchanged) |

The seven UVM row-modes' 28-line head is **CLEARED** and they surface ONE new
shared head — see R0 below.  BuildUVMPkg's 22 cells were fixed too, but its
head sits earlier in the walk and is unchanged.

**Movers** — byteverify `SELFCHECK=1`, pristine b1a0447 vs patched:
`uhdm2rtlil` **0 / 1358**; `surelog` **9 / 956**, exactly the predicted names.
Order-blind, id-blind whole-dump diffs:

| row | changed dump lines | content |
|---|---|---|
| SeqDriver / SimpleUVM / MiniAmiq (both modes), Scoreboard/default | 84 each | 14 cells x 6 lines: `\_constant: , line:3494:11..` → `\_constant: `, `int` → `32`, `UINT:0` → `UINT:32` |
| BuildUVMPkg (both modes) | 132 each | 22 cells x 6 lines: 18 `bit` → `1`, 4 `byte` → `8`, all located → loc-less |

Nothing else moved in any of the nine.

**Arms** (see `ARMS.r10uvm93.txt`): `g93_a6_case.sv` — the case-sensitivity /
near-miss / `real`+`shortreal` arm — **now PASSES the official `uhdm-cmp`**
(pristine: CMP_FAIL, 1 head).  `g93_a1_slice.sv` and `g93_a2_edge.sv` still fail
on exactly the two named residues in §3 and on nothing else.

**Boundary** (`BOUND.r10uvm93.txt`): 644 fenced arms from uvm77-92, buvm3-16,
sd8-12 — `LISTED=644 PROCESSED=644 MOVED=0`, with a positive control proving
the gate can see a moved cell.

## 6. R0 — the next head

All seven UVM row-modes now share ONE head, 164 cmp lines, at
`uvm_object_defines.svh:3674` (the `` `uvm_unpack_intN `` macro body,
`packer.m_bits[ (packer.count) +: $bits(int) ]`):

```
LHS golden : hier_path: (packer.m_bits[+:32])   |vpiName:packer.m_bits[+:32]
RHS ours   : hier_path: (packer.m_bits[])       |vpiName:packer.m_bits[]
```

Golden's `indexed_part_select` NAME carries the folded `[+:32]`; ours renders
`[]`.  The same object also shows a `ref_obj` `vpiFullName` split
(`uvm_pkg::uvm_tlm_generic_payload::do_unpack::packer.m_bits[+:32]::m_bits::count`
vs `...::do_unpack::count`) — but `vpiFullName` is DUMP-ONLY, so the judged
field is the `hier_path`/`indexed_part_select` **`VpiName` TEXT**, the same
name-text family uvm92's `ct92cen.cpp` oracle was built for.  Both the width
`32` and the base `packer.count` are already right in our `vpiWidthExpr` /
`vpiBaseExpr`; only the rendered NAME is short.

BuildUVMPkg's head is unchanged at 29 lines
(`byte_var: (uvm_pkg::uvm_packer::get_packed_bytes::i)`).
