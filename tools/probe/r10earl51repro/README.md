# r10earl51 — § memberLhsCastNoElabFold51

**THE HEADLINE: R0 — the Earlgrey_0_1/default 52-line head that r10earl49 named
and r10earl50 scored — is CLEARED, and the discriminator is the ONE thing
r10earl50 explicitly REFUTED. The cont-assign's LHS being a struct MEMBER is the
whole rule; earl50's refutation was an artefact of our side ACCIDENTALLY
matching on its arm. The Earlgrey delta is ONE hunk of six lines, exactly the
predicted cell, and the whole rest of the 4,652,435-line database — DEF view
included — is byte-identical.**

Corpus movers: `Earlgrey_0_1` and nothing else (byte-deterministic: slang.uhdm
md5 `3d1f5771…` → `ed708d6c…`). All 8 corpus sweeps: 0 differing CSV rows.

---

## R0, as r10earl50 left it

`sram2tlul.sv:42`

```systemverilog
localparam int unsigned SRAM_DWB = $clog2(SramDw/8);
...
assign tl_o.a_size = top_pkg::TL_SZW'(SRAM_DWB);   // Max Size always
```

```
LHS(golden): operation, vpiOpType:67, vpiTypespec -> int_typespec,
             vpiOperand -> ref_obj (work@sram2tlul.SRAM_DWB)
RHS(ours)  : constant UINT:2 size 2, loc-less
```

r10earl50 cut this three ways and declared all three dead ends:

| earl50 arm | its reading |
|---|---|
| `h6` six plain size-cast cont-assigns | DUMP_MATCH — "the cast SHAPE is not it" |
| `h7` the same with a packed-struct MEMBER LHS | PASS_CMP — "the struct-member LHS is not it" |
| `h8` `h7` instantiated with overrides | PASS_CMP — "the instantiation is not it" |

**`h7` is the counterexample and it was read backwards.** `h7` PASSES because our
side never folds there: `output h7p::tl_h2d_t tl_o` elaborates to a struct_**NET**,
the `dottedLhs` net-base test in `emitContAssigns` keeps the SHARE of the def
cont_assign, and the def cont_assign carries the operation. Earlgrey's
`output tlul_pkg::tl_h2d_t tl_o` elaborates to a struct_**VAR** (its `tl_h2d_t`
has an enum-typed member and a nested packed struct), the share is dropped, the
fold runs, and the head appears. Two features moved between `h6` and `h7` at
once — the LHS *and* the localparam's provenance — and the pass attributed the
result to neither.

---

## THE LAW

> **§ memberLhsCastNoElabFold51.** In the ELABORATED view, a cont_assign whose
> Lhs is a struct-MEMBER access (a `hier_path`) keeps a CAST Rhs as an
> unreduced `operation vpiOpType:67`. Every other reducible Rhs shape on the
> very same Lhs still folds, and the very same cast on a whole-signal Lhs folds
> too.

**THE MECHANISM, transcribed from Surelog** (`src/DesignCompile/UhdmWriter.cpp:2090`,
`UhdmWriter::writeCont_assign`). That function reduces the Rhs in exactly TWO
places:

1. `if (lhs->UhdmType() == uhdmref_obj)` — a WHOLE-signal Lhs — `reduceExpr` +
   `adjustSize`, result written back with `assign->Rhs(...)`. A `hier_path` Lhs
   never enters it.
2. the trailing `if (simplified == false)` reduce.

Between them sits

```cpp
      } else if (rhs->UhdmType() == uhdmoperation) {
        operation* op = (operation*)rhs;
        if (const ref_typespec* ro1 = op->Typespec()) {
          if (const typespec* tps = ro1->Actual_typespec()) {
            expr* tmp = eval.flattenPatternAssignments(s, tps, (expr*)rhs);
            if (tmp->UhdmType() == uhdmoperation) {
              ... clone_tree(assign) ...
              simplified = true;
```

reached exactly when the Lhs yielded NO typespec (a `hier_path` does not) **and
the Rhs operation CARRIES ONE**. A cast operation always carries its target
typespec; a plain binary / unary / ternary / concat operation never does. So
`simplified` is set, arm 2 never runs, and the cast rides out into a freshly
cloned cont_assign — which is precisely golden's shape at `sram2tlul.sv:42`
(a fresh `operation` id 967109 whose `vpiOperand` is still the DEF's `ref_obj`
id 190522).

---

## THE ARMS — 4 files, 47 cells, one read position each

Every cell is one cont-assign; golden is real Surelog; the reader is
`castgrid51.py` (per-cont_assign Rhs SHAPE, keyed on
`<instance fullname> <source span>`, with object-sharing normalised away).

| arm | what it separates | result |
|---|---|---|
| `i1_earl51.sv` | module-with-params vs module-without × plain-net LHS vs struct-member LHS × four operand kinds (localparam from literals, localparam through a module parameter, plain localparam, the parameter itself) | **the LHS is the only carrier**: all 5 net-LHS cells fold, all 6 member-LHS cells keep the operation, in BOTH modules |
| `i2_earl51.sv` | the same crossing over an Earlgrey-shaped struct (enum member + nested packed struct) so OUR side takes the fresh-CA path — the head, REPRODUCED | golden op / ours const on `tl_o.size` and `tl_o.k2`; `tl_o.k4` (bare ref), `k5`/`k6` (literals) and the net twins agree |
| `i3_earl51.sv` | the RHS axis: size cast, `LP2\|4'h1`, `4'h1\|4'h2`, constant ternary, concat, `~4'h1`, `int'(LP2)` — each with its plain-net twin | **only the two CASTS keep the operation**; the other five member-LHS shapes fold exactly as the net twins do |
| `i4_earl51.sv` | the boundary: a CHILD instance view (×2 overrides), a NESTED member (`tl.user.rsvd`), an INTERNAL struct var, a LITERAL cast operand, a cast of a NET (control), and part-/bit-select LHS | the law holds in child views and at depth 2; select-LHS cells are untouched (they already share) |

`h6`/`h7`/`h8` from r10earl50 are carried forward and are **byte-identical**
before and after — h6 has no member LHS, h7/h8 have a struct-NET base.

## The grid, one table

| cell | Lhs | Rhs | golden | pristine | patched |
|---|---|---|---|---|---|
| i1 42/43, 61/62/63 | net | size cast | constant | constant ✓ | constant ✓ |
| i1 44/45, 64..67 | member (struct_NET base) | size cast | operation | operation ✓ | operation ✓ |
| i2 61 / i3 45 / i4 40 | member (struct_VAR base) | `SZW'(localparam)` | operation | constant ✗ | **operation ✓** |
| i2 62 / i3 45 | member | `SZW'(plain localparam)` | operation | constant ✗ | **operation ✓** |
| i3 51 | member | `int'(LP2)` TYPE cast | operation | constant ✗ | **operation ✓** |
| i4 41 | member | `SZW'(3)` literal operand | operation | constant ✗ | **operation ✓** |
| i4 43 | member ×2 deep | `7'(LP2)` | operation | constant ✗ | **operation ✓** |
| i4 44 | member of an INTERNAL struct var | size cast | operation | constant ✗ | **operation ✓** |
| i3 46..50 | member | `\|`, `\|` on literals, ternary, concat, `~` | constant | constant ✓ | constant ✓ |
| i2 64..67, 69..71 | member | bare ref / literals / `'0` | constant | constant ✓ | constant ✓ |
| i2 74..78, i3 54..60, i4 48/49 | net | all seven shapes | constant | constant ✓ | constant ✓ |
| i4 42 | member | `SZW'(net)` — cannot fold | operation | operation ✓ | operation ✓ |
| i4 45/46 | part-/bit-select over a packed var | size cast | operation | operation ✓ | operation ✓ |
| **i2 63 / i2 76** | member / **net** | `SRAM_DWB[1:0] \| 2'h0` | operation | constant ✗ | constant ✗ (residue R1) |

---

## THE CENSUS — predicted before, landed exactly

`CENSUS_PREDICT51.txt` was written from the PRISTINE pair. Instrument:
`castgrid51.py --view=top`, 16,424 rows per side, `=def` sharing markers
stripped before diffing.

| | pristine | patched |
|---|---|---|
| golden-vs-ours disagreeing cont_assign cells | **98** | **97** |
| cells that ENTERED the set | — | **0** |
| Earlgrey_0_1/default cmp head | 52 lines / 1 head | **CLEARED** |

The one cell that left is `work@sram2tlul 42:10-42:53`, named in the prediction.
The whole-database delta is ONE hunk:

```
1221835,1221839c1221835
<     \_constant:
<       |vpiDecompile:2
<       |vpiSize:2
<       |UINT:2
<       |vpiConstType:9
---
>     \_operation: , line:42:27, endln:42:53
```

Line 1221835 is inside the `work@sram2tlul` TOP-module listing. The DEF view
(lines 1..1196437) is byte-identical, as earl38's fence requires.

The remaining 97 cells, for the record, are four other families and this pass
moves none of them: `work@rv_plic_target 73:18` (81 cells, ours `ref_obj` /
golden constant), `work@prim_arbiter_tree 114:20` (8, same),
`work@prim_ram_2p_async_adv 171/172` and `work@padctrl 39:12` (3, ours operation
/ golden constant — the OPPOSITE direction), and 4 span-end-column-only rows in
`work@gpio` and `work@prim_packer`.

---

## THE NEW HEAD — R0 for r10earl52

Earlgrey_0_1/default now heads at 64 lines / 1 head, `rv_core_ibex.sv:67`:

```systemverilog
localparam int FifoPass = PipeLine ? 1'b0 : 1'b1;
```

```
LHS(golden): constant INT:-1  size 32 decompile "-1"   vpiConstType:7
RHS(ours)  : constant BIN:1   size 32 decompile "1'b1" vpiConstType:3
```

a **param_assign** Rhs, not a cont_assign: Surelog's constant-condition ternary
reduce takes the selected 1-bit literal, resizes it into the `int` target as
SIGNED and lands on `-1`, where we keep the branch literal's own binary
encoding. It is byte-identical between the pristine and patched databases (the
whole delta is the six lines above), so it is PRE-EXISTING and was simply behind
R0. It is the same encoding question as `§ elabCaTernaryFoldIntConst22`, one
level up — in the parameter, not the cont-assign.

---

## RESIDUES

| id | what | witnesses | direction | changed by this pass? |
|---|---|---|---|---|
| **R1** | an operation containing a **PART-SELECT of a localparam** is not reduced by golden, on a member Lhs AND on a plain net Lhs; we fold both | `i2.63` `tl_o.k3 = SRAM_DWB[1:0] \| 2'h0`, `i2.76` `n_k3 =` the same | ours constant / golden operation | no — byte-identical before and after |
| **R2** | a member-Lhs NON-cast fold keeps its **natural 64-bit width and a parent**, because the `hier_path` Lhs yields no typespec and Surelog's `adjustSize` is skipped | `i3.46` `tl.c2 = LP2 \| 4'h1` — golden `UINT:3 size 64` parented at the ca, ours `UINT:3 size 4` unparented (the i3 head, 32 lines) | ours size 4 / golden size 64 | no |
| **R3** | a size cast on a NET Lhs masks at the **CAST** width in golden and at the **LHS** width in ours | `i4.49` `n2 = i4p::SZW'(3)` — golden `UINT:3`, ours `UINT:15` (the i4 head, 28 lines) | — | no |
| **R4** | the other 97 Earlgrey elab cont_assign disagreements (4 families, listed above) | census | mixed | no |
| **R5** | our elab member-Lhs cont_assign SHARES the def Rhs operation object where Surelog `clone_tree`s a fresh one | every moved cell | invisible to uhdm-cmp (content-identical) | no |

---

## Files

| file | what it is |
|---|---|
| `i1..i4_earl51.sv` | the 47-cell grid that states and bounds the law |
| `castgrid51.py` | the census instrument — per-cont_assign Rhs SHAPE, sharing-normalised |
| `CENSUS_PREDICT51.txt` | the prediction, written from the pristine pair before the patched run |
| (boundary arms) | NOT copied here — `bndarms51.sh` stages the 70 `.sv` arms of `r10earl38/45/46/47/48/49/50repro` straight out of the main tree, so there is exactly one copy of each and it cannot drift |
| `earl51.sh` `arm51.sh` `sweeps51.sh` `byteverify51.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `bndarms51.sh` `msdist.sh` `shapes51.sh` `vsweep.sh` `varm.sh` `vbnd.sh` `grid51.py` `census51.py` `vcmpgrid.py` | the gate harness |

## Reproduce

```sh
git worktree add /tmp/wt_r10earl51 4e3ca19
cmake -S /tmp/wt_r10earl51 -B /tmp/wt_r10earl51/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build /tmp/wt_r10earl51/build -j 2
cd /tmp/wt_r10earl51/tools/probe/r10earl51repro
for a in i1 i2 i3 i4; do
  SLANG_UHDM=/tmp/wt_r10earl51/build/slang-uhdm ./arm51.sh ${a}_earl51.sv /tmp/arm_$a
  paste <(python3 castgrid51.py /tmp/arm_$a/g.dump --view=top) \
        <(python3 castgrid51.py /tmp/arm_$a/o.dump --view=top | sed 's/.*| //')
done
SLANG_UHDM=/tmp/wt_r10earl51/build/slang-uhdm ./earl51.sh /tmp/r10earl51_wd
python3 castgrid51.py /tmp/r10earl51_wd/o.dump --view=top
```
