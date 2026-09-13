# r11u10 — the unpacked-struct-array pattern is a ONE-ELEMENT fold

Base commit `056796c3`, worktree `/tmp/wt_r11u10`. Pristine binary md5
`0978a9156e9c598936519e7a86ff505d` — byte-identical to the main tree at the
base. Law binary md5 `734455b3bb05aec1571d65f3579c6fc7`. The judge is the
official `uhdm-cmp` through `scripts/verify_golden.py`; everything in this
directory is measurement-only. `results/*.csv` ARE NOT EDITED BY THIS PASS.

**SIX uhdm2rtlil tests CONVERT in BOTH modes** (§6) — twelve row-modes, each
confirmed at `uhdm-cmp` rc 0 against the golden the sweep itself used:

    ibex_branch_predict   ibex_compressed_decoder   ibex_decoder
    ibex_multdiv_slow     param_struct_field_bitsel param_unpacked_struct_array

Three more ibex rows (`ibex_alu`, `ibex_multdiv_fast`, `ibex_wb_stage`) clear
this head and land on a new, unrelated one; `ibex_icache`, `ibex_pmp` and
`ibex_tracer` carried the same defect behind their own heads and are byte-
corrected without converting.

## 1. The head, re-measured on my own pristine sweep

The pristine build reproduces the base exactly: u2r **746 CMP_EQUAL / 58
CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH modes**, and `ct8rows.sh` reads
`PASS: every row byte-identical to the committed baseline` against
`results/gate_uhdm2rtlil.csv`.

Seven rows wear ONE head each (`grep -c '^LHS:'` on **stderr**), identical in
both modes — `HEADS.pristine.*.txt`:

| row | head | cmp lines |
|---|---|---|
| ibex_alu | `operation` @ `ibex_pkg.sv 750:52` | 2267 |
| ibex_branch_predict | same | 2267 |
| ibex_compressed_decoder | same | 2267 |
| ibex_decoder | same | 2267 |
| ibex_multdiv_fast | same | 2267 |
| ibex_multdiv_slow | same | 2267 |
| ibex_wb_stage | same | 2267 |

`ibex_pkg.sv:750` column 52 is the `'{` of

```systemverilog
  parameter pmp_cfg_t PmpCfgRst[PMP_MAX_REGIONS] = '{
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 0
    …                                                                      // 16 in all
  };
```

**THE VECTOR SIZES FIRST, as the brief demands.** `shape10.py` on both
databases of `ibex_alu`, per design listing:

| listing | GOLDEN | OURS at 056796c3 |
|---|---|---|
| allPackages | `op75 n=16` → 16 × `op75 n=5` | identical |
| topPackages | `op75 n=16` → 16 × `op75 n=5` | identical |
| allModules | `op75 n=16` → 16 × `op75 n=5` | identical |
| **topModules** | `op75 n=16` → 16 × `op75 n=5` | **`op75 n=80`, all leaves** |

So the 2267 lines are **ONE vector-size print** — `uhdm-cmp`'s VECTOR overload
dumps the whole golden vector when the sizes differ — not a distance, and not
2267 wrong objects. Sixteen against eighty, in the module ELABORATED listing
and nowhere else. Two more rows carry the same shape on their own head:
`param_unpacked_struct_array` (`TBL` 4 → 12) and `param_struct_field_bitsel`
(`TBL` 4 → 8).

## 2. DECODE — the producer, read from source

The object is built by UHDM itself, not by Surelog's own code.

`CompileHelper::expandPatternAssignment` (Surelog v1.87
`src/DesignCompile/CompileHelper.cpp:5233`) hands the Rhs to

    rhs = eval.flattenPatternAssignments(s, tps, rhs);

and **both** roads that build an elaborated copy call it: the parameter's own
elab `param_assign` (`DesignElaboration.cpp:2601`) and the instance CONNECTION
(`NetlistElaboration.cpp:281`).

`ExprEval::flattenPatternAssignments` (UHDM v1.87 `templates/ExprEval.cpp:751`)
is where the element count decides everything:

```cpp
    VectorOfany *orig = op->Operands();
    if (orig->size() == 1) {                       // ExprEval.cpp:808
      for (auto oper : *orig)
        if (oper->UhdmType() == uhdmoperation) {
          operation *opi = (operation *)oper;
          if (opi->VpiOpType() == vpiAssignmentPatternOp) {
            op = opi; orig = op->Operands(); break; //   descend into the element
          }
        }
    }
    …
    for (auto oper : *orig) {
      if (oper->UhdmType() == uhdmtagged_pattern) { …ordered… }
      else if (oper->UhdmType() == uhdmoperation) { return result; }   // :862-863
```

The descent into the element's nested pattern at `:808` is guarded by the
OUTER operand vector holding **exactly one** operand. With two or more
elements the descent never happens, `operand[0]` is the first element's own
`vpiAssignmentPatternOp`, the walk falls into the `uhdmoperation` arm at
`:862` and returns `result` — **the unmodified definition tree**. Only the
one-element array reaches `recursiveFlattening` (`ExprEval.cpp:942`), which
strips the `tagged_pattern` tags into the flat member list.

Separately, and **outside** the fold, `DesignElaboration::elaborateInstance_`
(`DesignElaboration.cpp:2606-2637`) stamps every elaborated parameter whose
Rhs came back an `operation`:

```cpp
    if (ts->UhdmType() != uhdmunsupported_typespec) {
      if (op->Typespec() == nullptr) { … op->Typespec(tsRef); }
      op->Typespec()->Actual_typespec(ts);
    }
```

unconditionally — whether or not `expandPatternAssignment` changed anything.
That is the second half of the law.

**Ours at 056796c3.** `UhdmExporter::foldUnpackedStructArrayPattern`
(`src/ParamEmit.cpp`) modelled the flatten with NO element-count test, so it
absorbed the element struct at every array size, and it minted the
`ref_typespec` itself — so the typespec was only ever right on the rows where
the flatten was (wrongly) applied.

## 3. The golden grid (`GRID.pristine.txt`, `GRID.law.txt`, `GRID.law2.txt`, `grid10.sh`, `mkgrid.py`, `grid/h*`)

Sixteen arms, every one compiled `--nobuiltin` on the slang side (REQUIRED),
every arm recording `surelog_rc`, `ours_rc` and `cmp_rc`. All sixteen read
`surelog_rc=0 ours_rc=0`. Each varies ONE axis of the same package parameter
`s_t P[N] = '{'{m0: …, …}, …}`.

| arm | elems × members | GOLDEN topModules | pristine | law |
|---|---|---|---|---|
| h1 | 1 × 1 scalar | `n=1` `[constant]` | same | same |
| h6 | 1 × 2 | `n=2` `[2 constants]` | same | same |
| h2 | 1 × 3 | `n=3` `[3 constants]` | same | same |
| h7 | 1 × 1 ENUM | `n=1` `[constant]` | `[ref_obj]` | `[ref_obj]` (residue R1) |
| hD | 1 × 1 VECTOR | `n=1` `[constant]` | same | same |
| h9 | 1 × 1, port-passed | `n=1` `[constant]` | same | same |
| hB | 1 × 1 SUB-STRUCT | `n=1` `[op75[constant]]` | tags kept | tags kept (residue R2) |
| h5 | 2 × 1 | `n=2` `[op75 ×2]` | `n=2` flat | **FIXED** |
| hG | 3 × 2 | `n=3` `[op75 ×3]` | `n=6` flat | **FIXED** |
| h3 | 4 × 1 | `n=4` `[op75 ×4]` | `n=4` flat | **FIXED** |
| hF | 2 × 3 | `n=2` `[op75 ×2]` | `n=6` flat | **FIXED** |
| hE | 4 × 2 VECTOR | `n=4` `[op75 ×4]` | `n=8` flat | **FIXED** |
| h4 | 4 × 3 | `n=4` `[op75 ×4]` | `n=12` flat | **FIXED** |
| h8 | 4 × 3 + ENUM | `n=4` `[op75 ×4]` | `n=12` flat | **FIXED** |
| hA | 4 × 3, port-passed | `n=4` `[op75 ×4]` | `n=12` flat | **FIXED** |
| hC | 4 × 1 SUB-STRUCT | `n=4` nested + ts | fold bailed, ts MISSING | **FIXED** by the ts half |

**The element count is the whole distinguisher.** Member count, member kind
(scalar / enum / vector / sub-struct) and whether the parameter is passed
through a port move NOTHING — h9 vs h1 and hA vs h4 are the port negative
controls, and they are byte-identical to their non-port twins on both sides.

Scored against golden, listing by listing, all four listings × 16 arms:

    FIXED = 9   UNCHANGED-OK = 53   STILL-WRONG = 2   BROKEN = 0

The two STILL-WRONG cells are h7 and hB, both **one-element** arms that the
law deliberately does not touch; both were already wrong at pristine and are
byte-identical before and after (§8, R1/R2).

The two witnesses that BUILT the original fold are the one-element shape and
must stay folded — `StructArrayParameterInitializedByPatternPassedAsPort` and
`NestedStructArrayParameterInitializedByPatternPassedAsPort` both declare
`data_region_attr_t HwDataAttr[1]`. Both are CMP_EQUAL before and after.

## 4. The law (two halves, `src/ParamEmit.cpp` only)

### § unpackedStructArrPatOneElemFold

`foldUnpackedStructArrayPattern` returns `nullptr` unless the outer simple
assignment pattern has **exactly one** element. One test, placed before the
function mints any object, so a declined shape costs nothing. It gates BOTH
call sites — the parameter road (`ParamEmit.cpp`) and the connection road
(`ModuleEmit.cpp`) — because Surelog reaches both through the one
`flattenPatternAssignments`.

### § unpackedStructArrPatElabTs

In the ELABORATED module listing only, an unpacked-array-of-packed-struct
parameter whose Rhs is an `operation` with no typespec gets a `ref_typespec`
to the parameter's own `array_typespec`, `VpiFullName` = the instance prefix
(trailing `::` stripped — spelled exactly as the fold spelled it). Never over
an operation that already carries a ref, so every arm that still reaches the
fold keeps the fold's own. This is `elaborateInstance_`'s unconditional stamp,
which we previously only ever performed as a side effect of flattening.

Measured in that order: the first half alone took the seven ibex rows from
2267 cmp lines to **8**, and the residual 8-line head was
`ref_typespec … RHS: <null>` — the SINGULAR overload naming a value golden has
and we do not. `hB`/`hC` carried that identical head at PRISTINE, which is how
the second half is known to be an independent pre-existing defect rather than
fallout.

## 5. A-PRIORI mover prediction (`predict10.py`, `predict10b.py`, `PREDICT.u2r.*.txt`)

Run on the PRISTINE databases, before the law was written.

`predict10.py` reports a row when one parameter carries, in some listing, an
`op75` with K ≥ 2 operands that are themselves `op75` (the definition tree)
AND, in another listing, an `op75` with a leaf-only operand vector (our flat
fold). `predict10b.py` covers the connection road by finding every `op75`
under an `array_typespec` with a leaf-only vector of ≥ 2 operands anywhere in
the database, not only under a `param_assign`.

**POSITIVE CONTROL** (`predict10.py` on the grid arms' own databases): it
flags `h4_4e3m` and `h5_2e1m` — the ≥2-element arms — and flags NEITHER the
one-element arms (h1/h2/h9/hD/hB) NOR the two corpus witnesses gW1/gW2. The
scanner sees exactly the shape the law removes.

Predicted movers, BOTH modes, twelve rows:

    ibex_alu  ibex_branch_predict  ibex_compressed_decoder  ibex_decoder
    ibex_icache  ibex_multdiv_fast  ibex_multdiv_slow  ibex_pmp  ibex_tracer
    ibex_wb_stage  param_struct_field_bitsel  param_unpacked_struct_array

`predict10b.py` adds no row: the other seven rows it lists
(`FunctionParam`, `LocalParamInNestedForLoops`, `LocalParamSelect`,
`ModuleInstantiationAndIndirectParams`, `NestedForLoops`,
`PatternParameterInSubmodule`, `SelectGivenBySelectOnParameterInFunction`)
carry a flat `op75` under an `array_typespec` built by a different path — an
unpacked array of a VECTOR, which `foldUnpackedStructArrayPattern` never
touches because it requires a packed-struct leaf. None of them moves a byte.

## 6. Gates

1. **Builds.** Pristine md5 `0978a9156e9c598936519e7a86ff505d` = the main tree
   at `056796c3`. Law md5 `734455b3bb05aec1571d65f3579c6fc7`. Both `-j 2`,
   md5 taken separately, both frozen `chmod 555` before any sweep; every
   `cmds.txt` audited by binary PATH.
2. **Goldens.** `check_goldens.sh` 23 PASS / 0 FAIL with
   `SLANG_UHDM=<law binary>`; the `/bin/false` negative control 0 PASS /
   23 FAIL.
3. **u2r both modes** (`ct8rows.sh`, `GATES.r11u10.txt`). testflags and
   default each go **746 → 752 CMP_EQUAL, 58 → 52 CMP_NOTEQUAL, 67
   SLANG_REJECT unchanged**. The ONLY rows that differ from the committed
   baseline are the six named above, each `CMP_NOTEQUAL → CMP_EQUAL`, each
   quoted in `GATES.r11u10.txt`. No row regresses in either column.
4. **surelog both modes.** Histogram byte-identical to the committed
   `results/golden_surelog.csv` AND to my own pristine sweep: default
   **467 CMP_EQUAL / 16 CMP_NOTEQUAL**, testflags **463 / 14**, every other
   status class and both dump columns unchanged. The only two rows `ct8rows.sh`
   prints are `LowMemLib` and `LowMemPkg`, whose `SURELOG_FAIL` DETAIL STRING
   embeds the workdir path — same status, same dump column, not a row move.
   `PREDICT.surelog.{testflags,default}.txt` had already read **rows=0**: the
   family does not occur in that corpus.
5. **byteverify SELFCHECK=1** against my own pristine workdirs.
   * u2r: `PATH_SETS_IDENTICAL (1608 paths)`, **`MOVERS: 24 / 1608`**,
     selfcheck `1607 / 1608 flagged`. The 24 are exactly the 12 predicted rows
     × 2 modes. **Zero unpredicted movers.**
   * surelog: `PATH_SETS_IDENTICAL (960 paths)`, **`MOVERS: 5 / 960`**,
     selfcheck `959 / 960`. All five are the PROVEN UVM COIN family —
     `MiniAmiq` (both modes), `SeqDriver` (both modes), `Scoreboard/default`.
     Attributed ONLY order-blind, as the mover rule requires: each is a
     0-or-4-line sorted-dump delta whose every changed line is a line-number-
     class `UINT:` / `vpiDecompile:` pair (`Scoreboard/default` = 0 lines, a
     pure order flip). **POSITIVE CONTROL**: the PRISTINE binary alone, run
     four times with identical arguments on `MiniAmiq/testflags`, yields four
     DISTINCT md5s (`09fed3c15a4d`, `a93226b69ed1`, `bf5dfe67e1bf`,
     `2de51ee676d7`), none equal to the sweep's own `6434d08e1e9a` — the row is
     nondeterministic per invocation before any law is applied.
6. **Canaries.** u2r `canaries.sh ok=8 changed=0`, `ctcan2.sh ok=1 changed=0`
   PASS; surelog `canaries.sh ok=52 changed=0`, `ctcan2.sh ok=58 changed=0`
   PASS; `canaudit.sh audited=29 UNCOVERED=0 FENCE-BREACH=0` PASS.
   Hard byte pins hold: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`
   (both modes). Status pins byte-identical to the control: InterfaceModPort
   `59a365f3ce2c`, BlackParrotComplex (`73a10e8217e5` / `e3e354129d5a`),
   YosysOldOr `d68e0796d62c`.

The patch surface is `src/ParamEmit.cpp` plus this directory, nothing else;
`git apply --check` on a FRESH `056796c3` worktree succeeds; and the four
slang-fenced names appear in no file of the patch outside `canaudit.sh`'s own
fence list.

## 7. The census (`cen10.py`, `away10.py`, `CENSUS.r11u10.txt`)

Per mover row, three path-normalised id-stripped `uhdm-dump` line multisets —
golden, pristine, patched — scored both modes:

    TOTAL TO-GOLDEN = 16784      TOTAL AWAY-GOLDEN = 788

and the AWAY number is **the multiset trap, in full**. `away10.py` prints the
lines it counted; across all 24 mover databases the complete set of distinct
AWAY lines is

    |vpiActual:      |vpiOperand:      |vpiParent:

three content-free structural tags whose count at a given indent changed
because the tree got one level deeper. Not one line carries a name, value,
type, size or span. `ibex_branch_predict` scores AWAY=15 and is CMP_EQUAL at
judge rc 0 — a row cannot be simultaneously byte-perfect to the judge and
moved away from golden, which is the proof the scorer is reading tags.

Beside it, as the brief requires, the SHAPE LISTER on the real corpus rows:
`PmpCfgRst` on `ibex_alu` and `TBL` on both `param_*` rows are, after the law,
**shape-identical to golden in all four listings** including operand counts,
op types, sizes and typespec kinds.

## 8. Residues

* **R0 — the ONE-ELEMENT absorb is still wrong in two shapes.** Both are
  arms the law deliberately leaves alone, both wrong at pristine, both
  byte-identical before and after, and neither is on any corpus row's head:
  * **R1 (`grid/h7_1e1menum`)** — a one-element array whose struct member is
    an ENUM constant: golden's absorbed operand is a folded `constant`
    (`BIN:00`, vpiSize 2), ours is the `ref_obj` to the enum constant.
    `recursiveFlattening` reduces the member value; our `foldField` re-emits
    the source expression.
  * **R2 (`grid/hB_1e1msub`)** — a one-element array whose struct member is
    itself a STRUCT: golden absorbs and drops the `tagged_pattern` tags
    (`op75[op75[constant]]`), our `foldField` bails on an all-scalar
    sub-struct and keeps the full tagged tree.
* **R3 — `ibex_alu`'s new head is a different family.** `LHS: <null>` naming
  a `logic_var work@ibex_alu.butterfly_result` at `ibex_alu.sv 407:16` that we
  emit and golden does not — a spurious variable, not a parameter question.
  `ibex_multdiv_fast` and `ibex_wb_stage` land on the same 15-line head.
* **R4 — `ibex_icache` @ `17:44`** (INT-vs-UINT param constant, 32 lines),
  **R5 — `ibex_pmp` @ `34:10`** (range constant vpiSize 32 vs 64, 18 lines) and
  **R6 — `ibex_tracer` @ `ibex_tracer_pkg.sv 305:87`**
  (`ref_obj ibex_tracer_pkg::OPCODE_C0`, 18 lines) are unchanged by this pass:
  each carried the `PmpCfgRst` defect BEHIND its own head, so each is byte-
  corrected without its head moving.

## 9. Instruments

* `shape10.py` — THE instrument. The operand TREE of a named parameter's
  `param_assign` Rhs, per design listing: kind, `vpiOpType`, **operand count**,
  `vpiSize`, `vpiConstType`, the typespec's actual kind and name, and the
  value. `SHAPE_DEPTH` sets the recursion depth. It exists because a cmp LINE
  COUNT is not a distance when the head is a vector-size mismatch — only the
  counts at every level say what moved.
* `grid10.sh` / `mkgrid.py` — the 16-arm golden grid; every rc recorded.
* `heads10.sh` — one head per row from the databases the SWEEP built, read off
  STDERR.
* `predict10.py` / `predict10b.py` — the a-priori mover prediction, with the
  grid-arm positive control (§5).
* `cen10.py` / `away10.py` — the directional census and the instrument that
  tells the multiset trap from a real break (§7).
* `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied byte-for-byte unmodified.
