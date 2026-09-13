# r11u12 — a cast folds in the elaborated listing only for six target typespec kinds

§ `castElabFoldTargetKinds` (+ § `elabOvRefAsmBinConst`). Base commit
`735de740`, pins per `SUPPORT_MATRIX.md`. Pristine binary md5
`b895cb0435893c2af6edf08661fccc54` — byte-identical to the main tree at the
base. Law binary md5 `0fae8ee5712893f86d8042143d37ae7c`. The judge is the
official `uhdm-cmp` through `scripts/verify_golden.py`; everything in this
directory is measurement-only. `results/*.csv` ARE NOT EDITED BY THIS PASS.

**TWO uhdm2rtlil tests CONVERT in BOTH modes** (§6) — four row-modes:

    def_ctx_struct_param      latch_decoder_partial

`latch_tlb_napot` clears this head too and lands on an unrelated one (a
statement-level `part_select`, §7 R4).

## 1. The head, re-measured on my own pristine build

The pristine build reproduces the base exactly: u2r **754 CMP_EQUAL / 50
CMP_NOTEQUAL / 67 SLANG_REJECT in BOTH modes**, surelog **467/16** (default)
and **463/14** (testflags); `ct8rows.sh` reads
`PASS: every row byte-identical to the committed baseline` on u2r for both
modes, and on surelog names only the two LowMem* workdir-path detail strings.

All three brief candidates wear **ONE head each, and it is the SAME head**
(`grep -c '^LHS:'` on stderr; `HEADS` in `GATES.r11u12.txt`):

| row | golden Rhs | ours | cmp lines |
|---|---|---|---|
| `def_ctx_struct_param` | `operation` opType **67**, ts ref → `struct_typespec`, one `UINT:0` size-64 operand | `constant UINT:0` size **34** ct 9 | 37 |
| `latch_decoder_partial` | same, at `14:31` | same | 37 |
| `latch_tlb_napot` | same, at `14:31` | same | 37 |

That is the `uhdmtopPackages` (ELABORATED package) `param_assign` of

```systemverilog
  localparam cfg_t CfgEmpty = cfg_t'(0);
```

`pacen.py` on `def_ctx_struct_param`, per design listing — the whole picture,
including where r11u9 already agrees:

| listing | cell | GOLDEN | OURS at 735de740 |
|---|---|---|---|
| allPackages | `CfgEmpty` | the cast `operation` | the cast `operation` |
| **topPackages** | `CfgEmpty` | **the cast `operation`** | **`UINT:0` sz 34 ct 9** |
| topPackages | `CfgDefault` | `BIN` sz 34 ct 3 | the same (r11u9) |
| allModules | `dcs_leaf.Cfg`, `dcs_mid.Cfg` | `operation` | `operation` |
| topModules | `u_mid.Cfg`, `u_mid.u_leaf.Cfg` | `34'b…010` BIN ct 3 | `UINT:130` ct 9 |

So the cluster is ONE head deep and TWO laws wide: the cast must survive the
elaborated listing, and the override actual that reads the assembled sibling
must inherit that sibling's BIN encoding. Both are in `src/ParamEmit.cpp`.

**A MASKED DIFFERENCE, recorded because it is real and invisible.** In the
DEF listing our cast's `ref_typespec` resolves to an `integer_typespec` where
golden's resolves to the `struct_typespec`. `uhdm-cmp` never reports it:
`scope::Compare` walks `Parameters()` BEFORE `Param_assigns()`, so golden's
`struct_typespec` is already in `CompareContext::m_visited` when the cast's
typespec is reached, and every generated `Compare` opens with
`if (!context->m_visited.insert(this).second) return r;` — a second visit
returns 0 = EQUAL whatever the RHS is. The residue is §7 R1.

## 2. The producer, decoded from UHDM v1.87 itself

`UHDM/templates/ExprEval.cpp`, `reduceExpr`'s `vpiCastOp` arm (~4185):

```cpp
case vpiCastOp: {
  expr *oper = reduceExpr(operands[0], invalidValue, inst, pexpr, muteError);
  uint64_t val0 = get_value(invalidValue, oper);
  if (invalidValue) break;
  const typespec *tps = nullptr;
  if (const ref_typespec *rt = op->Typespec()) tps = rt->Actual_typespec();
  if (tps == nullptr) break;
  UHDM_OBJECT_TYPE ttps = tps->UhdmType();
  if      (ttps == uhdmint_typespec)       { … UINT, size 64  … result = c; }
  else if (ttps == uhdmlong_int_typespec)  { … UINT, size 64  … result = c; }
  else if (ttps == uhdmbit_typespec)       { … BIN,  size 1   … result = c; }
  else if (ttps == uhdmshort_int_typespec) { … UINT, size 16  … result = c; }
  else if (ttps == uhdminteger_typespec)   { … the SIZED cast … result = c; }
  else if (ttps == uhdmenum_typespec)      { … UINT, size 64  … result = c; }
  break;                       // every other target: result is still `op`
}
```

**THE WHOLE RULE IS THAT IF/ELSE CHAIN.** Six target typespec kinds mint a
constant; for everything else `result` is still the ORIGINAL OPERATION and the
elaborated listing keeps the whole `vpiCastOp` tree. There is no width test,
no value test and no view test in the arm — a packed STRUCT target never
folds, in any listing.

The keyword→typespec map is § `castTargetKeywordTypespecKind96`'s (already
decoded, `src/EmitHelpers.h`): `int`→`int_typespec`, `longint`→
`long_int_typespec`, `shortint`→`short_int_typespec`, `integer`→
`integer_typespec`, `bit`→`bit_typespec`, and **`byte`→`byte_typespec`,
`time`/`realtime`→`time_typespec`, `logic`/`reg`→`logic_typespec`** — the last
three are NOT in the arm's chain, so `byte'(x)` does not fold either. A SIZE
cast `N'(v)` takes the `integer_typespec` road and DOES.

## 3. The golden grid (17 arms, every arm's rc recorded)

`gen.sh` writes the arms, `run.sh <binary> <tag>` builds golden + that binary
per arm and records `golden_rc`, `ours_rc`, the head count and the cmp-line
count (`GRID.pristine.txt`, `GRID.law.txt`). `pacen.py` is the SHAPE LISTER
beside the census — it lists each `param_assign`'s section, Lhs name and Rhs
object KIND plus the fields `constant::Compare` reads (`CELLS.r11u12.txt`).
`vdist.sh` scores the order-blind, path-normalised dump distance to golden on
both binaries (`VDIST.txt`).

Golden's split — **golden mints NO elaborated constant** for

| arm | shape |
|---|---|
| `g1` | `localparam s_t C = s_t'(0);`, package holder, qualified reference |
| `g2` | …read through `import p::*` |
| `g3` | …read through `import p::s_t; import p::C;` |
| `g4` | `s_t'(X)` over a package `int` localparam |
| `g5` | a NESTED cast `s_t'(int'(35))` |
| `g8` | a packed UNION target `u_t'(0)` |
| `g10` | a vector typedef target `v_t'(5)` (`typedef logic [7:0] v_t`) |
| `g13` | a packed-array typedef target `pa_t'(35)` |
| `g14` | the KEYWORD casts `byte'(35)`, `time'(3)`, `logic'(1)` |
| `g15`, `g16`, `g17` | the struct cast re-read by a second localparam / an override actual / a module localparam over a wildcard import |

and golden DOES mint one for

| arm | shape | golden |
|---|---|---|
| `g9` | an ENUM typedef target `e_t'(1)` | `UINT:1` sz 2 |
| `g11` | `int'(35)` | `UINT:35` sz 32 |
| `g12` | a SIZE cast `(W)'(35)` | `UINT:35` sz 8 |
| `g14` | `shortint'`, `longint'`, `integer'`, `bit'` | sz 16 / 64 / 32 / 1 |

`g6` and `g7` are the MODULE holders of the struct cast (a module localparam
and a module parameter default): neither binary folds them and both are
cmp-EQUAL — the conservatism there is pre-existing and identical.

rc: `golden_rc=0` on all 17. `ours_rc=4` on every arm whose source writes a
NAMED-type cast — our front end reports `expression kind: Invalid` for the type
name that sits left of the `'` (an unrelated, pre-existing diagnostic; the
database is complete and `uhdm-cmp` judges it). The keyword and size-cast arms
(`g6`, `g7`, `g11`, `g12`, `g14`) are `ours_rc=0`.

**THE SIZE-CAST ESCAPE, and why the syntax alone cannot decide.** `(W)'(35)`
with `W = 8` (g12, folds) and `v_t'(5)` with `typedef logic [7:0] v_t` (g10,
does not) are the SAME `CastExpression` syntax with an `IdentifierName` on the
left AND the same slang type — a packed 8-bit vector. The discriminator is
`Type::isAlias()`: a named type cast's conversion type IS the `TypeAliasType`,
a size cast's is an anonymous vector. That is what `castElabFoldsTarget` keys
on for the non-keyword half.

## 4. The law

`src/EmitHelpers.h` (one new helper) and `src/ParamEmit.cpp` (four gates).
Nothing else is touched.

1. **`castElabFoldsTarget(SyntaxKind, const Type*)`** (`EmitHelpers.h`) — the
   producer's chain, read where the producer reads it. A KEYWORD target
   answers off the keyword (`int`/`longint`/`shortint`/`integer`/`bit`/`enum`
   fold; `logic`/`reg`/`byte`/`time`/`shortreal`/`real`/`realtime` do not). A
   non-keyword target that is NOT an alias is the size-cast road and folds; an
   ALIAS folds only when its canonical type is an enum, a
   `PredefinedIntegerType` of Int/Integer/LongInt/ShortInt, or the `bit`
   `ScalarType`.
2. **`elabFoldShape9`'s size-cast arm** — its `!isTypeSyntaxKind(left)` test
   names the size cast AND every named-type cast; it now returns
   `castElabFoldsTarget(...)` instead of an unconditional `true`, so a
   struct-typed cast no longer sets `pkgElabComputed`.
3. **`pkgTypeCastFold9`** — the KEYWORD half, gated the same way: `byte'`,
   `time'` and `logic'` leave the chain (grid `g14`).
4. **The general elab fold's `tryFoldConst` chain** — one new conjunct. That
   chain is where the named-type cast actually folded: `tryFoldConst`'s own
   `foldTypeCasts` guard refuses only KEYWORD casts, so `cfg_t'(0)` walked
   straight through it.
5. **The import-copy cast fold** (`isImported && !inPackage && typedParam &&
   castLit9`) — its measured matrix is all SIZE casts; a named-type cast with
   a literal operand wore the same syntax and took the same fold. Gated
   (grid `g2` / `g3` / `g17`).
6. **§ `elabOvRefAsmBinConst`** — a new arm in the override-actual constant
   chain, immediately before § `elabOvRefIntConst`, which it mirrors exactly.
   When the formal is a packed STRUCT and the actual is a bare reference to a
   parameter whose elaborated Rhs is the assembled packed BIN constant (the
   § r11u9 `pkgStructFuncAssembleBin` family), the actual copies that
   constant's value, width and `vpiBinaryConst` and renders the `<w>'b`
   decompile prefix `CompileHelper::adjustSize` gives a constant re-rendered
   against a formal. It CHAINS: `#(.Cfg(Cfg))` one level down inherits the
   same encoding (`def_ctx_struct_param` has two levels).

## 5. Instruments

* `predict.py <corpus-root>…` — the A-PRIORI mover predictor, from the SOURCES
  alone, run BEFORE any patched sweep. Names every test whose parameter
  initializer is a cast to a non-folding target, with the NEG control (every
  folding cast form it found, which must stay off the list) and the POSITIVE
  control (the three brief rows must appear). `PREDICT.u2r.txt`,
  `PREDICT.surelog.txt`.
* `gen.sh` / `run.sh` — the golden grid and its runner; every arm's rc.
* `pacen.py` — the per-`param_assign` SHAPE LISTER (section, Lhs, Rhs object
  KIND, `constant::Compare`'s fields). Copied from `r11u9repro`.
* `vdist.sh` — the boundary DIRECTIONAL scorer (order-blind, path-normalised
  dump distance to golden, both binaries).
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation canary
  battery, copied verbatim from `r10uvm221repro` via `r11u9repro`.
* `GATES.r11u12.txt` — the full gate record, including the coin positive
  control.

## 6. What moved

THE ROWS CONVERT — two tests, four row-modes, CMP_NOTEQUAL → CMP_EQUAL:

* **uhdm2rtlil, BOTH modes, 754 → 756 equal and 50 → 48 not-equal:
  `def_ctx_struct_param` and `latch_decoder_partial`.**

The surelog corpus keeps 467/16 (default) and 463/14 (testflags) — no status
moves either way.

Movers, all PREDICTED BY NAME a priori by `predict.py` before any patched
sweep ran:

* uhdm2rtlil `byteverify.sh`: **6 / 1608** — three tests × two modes
  (`def_ctx_struct_param`, `latch_decoder_partial`, `latch_tlb_napot`).
  `dirscore.sh`: **6/6 TO-GOLDEN, 0 AWAY-GOLDEN, 0 NEUTRAL**.
  `shapecmp.sh`: **0 rows GREW**, 6 IMPROVED (shape_diff 1 → 0).
* surelog `byteverify.sh`: **4 / 960**, and all four are `MiniAmiq` ×2 and
  `SeqDriver` ×2 — the proven UVM coin family. Order-blind attribution: 4
  lines per row, every one of the line-number class. Positive control on the
  PRISTINE binary ALONE: six arm re-runs of MiniAmiq give six distinct
  hashes, two `--filter` sweeps of SeqDriver/testflags give two more, and
  pristine-vs-pristine carries the IDENTICAL 4-line signature. Every other
  predicted surelog name is byte-identical (most are SLANG_REJECT or
  DEFERRED and have no database to move).

On the BOUNDARY (`VDIST.txt` + `GRID.*.txt`), by the JUDGE: 8 arms improve
(`g1` 37→0, `g2` 37→0, `g3` 37→0, `g4` 44→8, `g5` 36→29, `g8` 37→0,
`g14` 37→31, `g17` 37→0), 9 are unchanged, **0 worsen**; `g15` and `g16` keep
their cmp-line count but their HEAD ADVANCES (from the package's own cell to
the re-read / the override actual). `vdist.sh` reads `g5` and `g8` AWAY on the
raw dump metric while the judge reads them 36→29 and 37→**0**: the unfolded
cast reaches typespecs that carry `vpiInstance` / `vpiParent` back-pointers and
an extra operation subtree, and no generated `Compare` reads either.

RESULTS CSVs ARE NOT EDITED BY THIS PASS. The two rows this pass CONVERTS are
still recorded as CMP_NOTEQUAL in `results/gate_uhdm2rtlil.csv` and
`results/golden_uhdm2rtlil.csv`; the promotions belong to the landing commit.

## 7. Residues, ranked

* **R0 — the SUBSTITUTED read of a non-folding cast parameter.** Golden
  answers a bare reference to such a parameter with the referenced parameter's
  own unfolded Rhs: `localparam s_t D = C;` is the whole `vpiCastOp` tree in
  golden's elaborated package listing (`g15`), and an override actual
  `#(.K(p::C))` is that same tree in `uhdmtopModules` (`g16`). We still fold
  both to `UINT:35` at the struct width. § `elabOvRefAsmBinConst` already does
  exactly this inheritance for an ASSEMBLED BIN source; the operation source
  is the same law with an object copy instead of a value copy. Two grid arms,
  no corpus row — the widest remaining piece of this family.
* **R1 — the DEF-view cast typespec.** Our cast's `ref_typespec` resolves to
  an `integer_typespec` where golden's resolves to the `struct_typespec`
  (`g1`…`g5`, and the corpus rows). It is MASKED wherever the parameter's own
  `ref_typespec` reached the same `struct_typespec` first (§1), which is every
  witness measured here — but the mask is a property of the design, not of the
  emitter, and a design whose cast target typespec is not otherwise visited
  would report it. The mint site is ExprEmit's cast-typespec fallback, which
  keys on the slang type and collapses a named aggregate onto
  `integer_typespec`.
* **R2 — the cast OPERAND is not reduced in the elaborated listing.** Golden's
  `uhdmtopPackages` for `s_t'(int'(35))` is `op67(constant UINT:35 size 64)`;
  ours keeps `op67(op67(constant))` (`g5`, 29 cmp lines). The producer's arm
  returns the ORIGINAL `op` — the operand reduction happens before it — so
  this is an elaborated-view operand rewrite we do not perform.
* **R3 — `bit'` folds to the wrong encoding.** The producer's `bit_typespec`
  arm mints `BIN:<v&1>` at `vpiConstType 3`; we mint `UINT:1` ct 9 (`g14`,
  the remaining 31 cmp lines are this and the `byte'`/`time'`/`logic'` typespec
  spans). One arm, no corpus row.
* **R4 — outside ParamEmit, and what `latch_tlb_napot` now wants.** Its new
  head is a statement-level `part_select`: golden's
  `patched_pte[3:0] = flush_vaddr_i[3:0];` inside `always_comb` is a
  `part_select` with `vpiConstantSelect:1` and two `UINT` range constants,
  where we emit the whole `logic_net`. A different family entirely.
* **R5 — the vector/packed-array typedef arms are fixed at the
  `param_assign` and still not equal.** `g10` and `g13` now match golden cell
  for cell on every `param_assign` and keep their pre-existing head: a
  `logic_typespec` for the typedef itself, carrying `vpiTypedefAlias` /
  `vpiInstance` / range shapes we do not reproduce. Unrelated to the cast.
