# r11u9 — a const-function struct parameter reduces to an assembled packed BIN constant

§ `pkgStructFuncAssembleBin` + § `modStructFuncAssembleBin`. Everything here is
MEASUREMENT-ONLY; the judge is `uhdm-cmp` through `scripts/verify_golden.py`.

## 1. The producer, decoded from UHDM v1.87 itself

`UHDM/templates/ExprEval.cpp`, `reduceExpr`'s `uhdmstruct_var` arm (~4835):

```cpp
} else if (objtype == UHDM_OBJECT_TYPE::uhdmstruct_var) {
  const struct_var *sv = (const struct_var *)result;
  std::function<bool(const struct_typespec *, std::string &)> assemble = ...
  if (assemble(stps, bits) && !bits.empty()) {
    constant *c = s.MakeConstant();
    c->VpiValue("BIN:" + bits);
    c->VpiDecompile(bits);              // BARE — no `<w>'b` prefix
    c->VpiSize((int32_t)bits.size());
    c->VpiConstType(vpiBinaryConst);
    ...  c->Typespec(rtc);              // ref_typespec -> the struct_typespec
    return c;
  }
  return (expr *)result;                // BAIL: the Rhs stays a struct_var
}
```

A struct value computed by a member-by-member const function arrives as a
`struct_var`; the values its evaluation produced live as `Actual_value`
annotations on the SHARED struct typespec's `typespec_member`s (the EvalFunc
LEFTOVERS — `ExprEval::setValueInInstance`'s hier_path arm). The assembler
reads those leftovers back, first declared member at the MSBs, and mints ONE
packed BIN constant at the struct's packed width.

**THE BAIL RULE is the whole fence, and it is NOT a width limit.** `assemble()`
returns false when

* the member's size is invalid or 0 (an enum member falls back to its base
  typespec's width, or 32), **or**
* the member has neither an `Actual_value` nor a `Default_value`, **or**
* that value does not `reduceExpr` to a CONSTANT (a bare
  pattern/concat/replication/cast of constants is folded; anything else is
  not).

There is no `mw > 64` test anywhere in the arm — a 1024-bit
`logic [15:0][63:0]` member assembles fine (FuncStructValSimple's 1088-bit
constant is the proof). The r11u3 note that recorded a 64-bit per-member limit
described `hierarchicalSelector`'s member-slice arm, not this one; the
`asmOk8` fence r11u3 landed is a MEMBER-SELECT fence and is untouched here.

The two shapes the bail rule separates, both in the corpus, both CMP_EQUAL
BEFORE and AFTER this pass:

| test | why | golden elab Rhs |
|---|---|---|
| `FuncStructVal` | an untyped-enum pattern element never folds, so ONE of the 97 members has no leftover at all (golden has 96) | `struct_var` |
| `StructParamFuncBodyFieldCompare` | `r.Flag = (c.NrRules > 0) && (c.Length > 0)` reads a 1024-bit formal member whose caller pattern element is an unreduced sized cast, so the leftover is the function BODY's own assignment OPERATION (§ r10fsv3 S2) | `struct_var` |

## 2. What golden does, per holder and per view (measured on all witnesses)

Reproduce any cell with

```bash
cd <dir> && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv
~/git-repos/UHDM/build/bin/uhdm-dump slpp_all/surelog.uhdm > gold.dump
python3 pacen.py gold.dump          # per-param_assign Rhs cells, by section
python3 stamps.py gold.dump         # per-struct-copy leftover stamp census
```

**PACKAGE holder** (`localparam cfg_t CfgDefault = build_config();`):

| view | golden Rhs | leftover stamps |
|---|---|---|
| `uhdmallPackages` (DEF) | the unfolded `func_call` | CLEAN |
| `uhdmtopPackages` (ELAB) | assembled BIN, **bare** decompile, ct 3, ts ref -> struct_typespec | STAMPED |
| `uhdmallModules` import copy (`import p::*`) | assembled BIN | STAMPED |
| `uhdmtopModules` | assembled BIN | STAMPED |

**MODULE holder** (`parameter cfg_t Cfg = pkg::build_config();`): the elaborated
Rhs is the assembled BIN with a `<w>'b` PREFIX on the decompile — the constant
goes on through `CompileHelper::adjustSize` against the formal, which is what
renders the prefix — or a `struct_var` when the bail rule fires.

**Leftover ENCODINGS** — the leftover is the REDUCED RHS, which for several
shapes is an OBJECT golden reuses rather than a re-encoded value slice:

| body RHS | golden leftover | the value slice gives |
|---|---|---|
| `c.XLEN = 32` | UINT:32 size 64 decompile `32` | the same |
| `c.RVC = 1'b1` | BIN:1 size **1** decompile `1'b1` | UINT:1 size 64 |
| `c.XLEN = 32'd64` | DEC:64 size **32** decompile `32'd64` | UINT:64 size 64 |
| `c.VLEN = CfgXlen` (a package `int unsigned` localparam) | UINT:64 size **32** | UINT:64 size 64 |
| `c.u = uu` (a WHOLE formal read) | the CALLER argument parameter's own assembled BIN, size 64 | UINT:<decimal> size 64 |
| `c.derived = uu.dataWidth * 2` | INT:64 size 64 | the same (§ r10fsv2 L3) |

## 3. What WE did, and the heads it wore

Pristine, all six brief witnesses plus the four the predictor added — every one
CMP_NOTEQUAL with head field `decompile:`:

| test | pristine head object |
|---|---|
| `FuncStructValSimple` | golden the 1088-bit assembled constant, ours a `struct_var` — the pure assembler face |
| `def_ctx_struct_param`, `latch_decoder_partial`, `latch_tlb_napot`, `param_nested_struct_field_width`, `pkg_nested_struct_param_width`, `struct_member_cfg_width`, `portsel_struct_param`, `struct_param_field_shift`, `struct_param_func_config` | a `typespec_member`'s leftover constant, `RHS: <null>` — we stamped NOTHING for a package-held builder |

The package cell itself: golden `BIN` size 34 decompile
`0000000000000000000000000010000010` ct 3; ours `UINT:130` size **32**
decompile `130` (`def_ctx_struct_param`), and for a 96-bit struct ours was
`UINT:0` decompile `55340232358567608384` — the `pkgElabComputed` decimal fold
run on a value that does not fit its own 64-bit rendering.

## 4. The law

`src/ParamEmit.cpp` only. Two gated arms plus three leftover resolutions.

1. **`pkgStructFuncAssembleBin`** — the stamp-recording block's guard goes from
   `topView && !inPackage` to `topView`, and when `(inPackage || isImported)`
   the param_assign Rhs becomes the assembled BIN constant instead of the
   `pkgElabComputed` decimal fold: `BIN:<bits>` / BARE decompile /
   `VpiSize(slPackedWidth(type))` / `vpiBinaryConst` / the existing `wantTs`
   ref_typespec. The parameter's own `VpiValue` takes the same bits, and the
   constant registers as that parameter's `elabParamConst`. The gate is
   EXACTLY `pkgElabComputed`'s domain, so this arm takes only cases that
   already folded — and only those whose initializer is a
   `memLeftInitCall`.
   * The DEF package listing is `!topView` and never enters: golden leaves it
     CLEAN and so do we.
2. **Three leftover resolutions, read ONLY by a `pkgHolder` stamp** — the
   module-holder path is byte-for-byte what it was. `litRhs` shares the
   function body's own emitted RHS object for a LITERAL assignment
   (`bodyAsgRhsObj`, the same sharing § r10fsv3 S2 already uses); `argWhole`
   shares the caller argument parameter's elaborated constant for a WHOLE
   formal read; `paramRead` re-encodes at the READ parameter's own width and
   sign.
3. **`memLeftAsmParams`** — the drain stamps the struct typespec copy of every
   parameter this law assembled. A module that WILDCARD-IMPORTS the package
   carries its own materialized copy (`work@child.C` out of `import p::*`)
   that the TopPackages/TopModules walks never reach, and golden stamps it.
   Only copies this law produced are visited, so every def-view copy golden
   leaves clean stays clean.
4. **`modStructFuncAssembleBin`** — the MODULE holder's `struct_var` Rhs is
   replaced by the assembled constant (decompile `<w>'b<bits>`) **in the
   DRAIN**, and only when every member of that parameter's stamp survived the
   resolutions above AS A CONSTANT. That is the producer's own bail rule read
   where the producer reads it: after the member values are final.
   * The constant is MINTED IN THE DRAIN, never at the param site. The eager
     form left a discarded-but-serialized constant behind and moved
     `FuncStructVal`'s bytes (+191) on an identical dump; the lazy form leaves
     every bailing row BYTE-IDENTICAL.

Nothing outside `src/ParamEmit.cpp` and `include/UhdmExporter.h` (the two
record structs) is touched.

## 5. Instruments

* `predict.py <corpus-root>` — the A-PRIORI mover predictor, from the SOURCES
  alone. Names every test carrying a member-by-member builder call, tagged
  `pkg` (package holder) or `mod` (module holder). See its docstring for the
  controls.
* `pacen.py <dump...>` — per-`param_assign` census: section, Lhs name, Rhs
  object KIND and the constant fields `constant::Compare` reads.
* `stamps.py <dump...>` — per-struct-typespec-copy leftover census
  (`typespec_member |vpiExpr:`), which is golden's clean/stamped split.
* `shapes.py <gold.dump> <ours.dump>` — THE SHAPE LISTER (the r11v7 lesson): a
  side-by-side listing of the Rhs OBJECT-KIND CHAIN per param_assign key, and
  the count of shape-differing keys. A value scorer reads clean across a
  shape break; this does not.
* `shapecmp.sh <pristine-wd> <patched-wd> <mode> <names…>` — that count on both
  binaries per row. Must never GROW.
* `dirscore.sh <pristine-wd> <patched-wd> <mode> <names…>` — the DIRECTIONAL
  census: order-blind, path-normalised `uhdm-dump` distance to each row's own
  golden, on both binaries. TO-GOLDEN / AWAY-GOLDEN / NEUTRAL.
* `arm.sh <workdir/mode> <binary> <outdir> <names…>` — re-runs ONE sweep row
  with a chosen binary using the row's own command line; records `rc`.
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation canary
  battery, copied verbatim from `tools/probe/r10uvm221repro`.

## 6. What moved

THE ROWS CONVERT — two tests, four row-modes, CMP_NOTEQUAL → CMP_EQUAL:

* **uhdm2rtlil, BOTH modes, 743 → 745 equal and 61 → 59 not-equal:
  `pkg_nested_struct_param_width` and `portsel_struct_param`.**

The surelog corpus keeps 467/16 (default) and 463/14 (testflags) — no status
moves either way.

Movers, all PREDICTED BY NAME a priori by `predict.py` before any patched
sweep ran, and all TO-GOLDEN:

* uhdm2rtlil `byteverify.sh`: 22 / 1608 — eleven tests × two modes
  (`def_ctx_struct_param`, `latch_decoder_partial`, `latch_tlb_napot`,
  `param_nested_struct_field_width`, `pkg_nested_struct_param_width`,
  `portsel_struct_param`, `struct_member_cfg_width`,
  `struct_param_field_shift`, `struct_param_func_arg`,
  `struct_param_func_config`, `struct_param_func_loop`).
  `dirscore.sh`: **22/22 TO-GOLDEN, 0 AWAY-GOLDEN, 0 NEUTRAL**.
  `shapecmp.sh`: **0 rows GREW**, 4 IMPROVED per mode.
* surelog `byteverify.sh`: the law movers are `FuncStructValSimple` ×2 modes
  and `StructParamPatternInitCast` ×2 modes, both TO-GOLDEN and both still
  CMP_NOTEQUAL (their heads advance). `FuncStructVal` and
  `StructParamFuncBodyFieldCompare` are the BAIL witnesses and are
  BYTE-IDENTICAL. The remaining movers are `MiniAmiq` and `SeqDriver`, the
  proven UVM coin family — order-blind dump distance to golden UNCHANGED, and
  three runs of the PRISTINE binary alone give three distinct database hashes.

RESULTS CSVs ARE NOT EDITED BY THIS PASS. The two rows this pass CONVERTS are
still recorded as CMP_NOTEQUAL in `results/gate_uhdm2rtlil.csv` and
`results/golden_uhdm2rtlil.csv`; the promotions belong to the landing commit.

## 7. Residues, ranked

* **R0 — the member-select of an ASSEMBLED base.** `FuncStructValSimple` is now
  one head from equal: golden's `.INPUT_WIDTH(CVA6Cfg.INSTR_PER_FETCH)` is
  `BIN 32'b…010` ct 3, ours `INT:2` ct 7. Now that the base assembles, golden
  slices the member out of it (r11u3's § `structParamMemberOvBinary`), but two
  guards keep us on the old answer: `asmOk8` rejects any struct with a >64-bit
  member — a rule this pass shows the assembler does NOT have — and the
  `memLeftIntRead` / `!memLeftReadEnc` carve-out sends a leftover-resolved
  member read to the leftover's own encoding. **THE KEEPING SHAPE for that
  carve-out is now known and named: it is exactly the BAIL — `FuncStructVal`
  wants `INT:2` because its base does NOT assemble.** So the carve-out is not
  to be deleted but RE-GATED on "this base's stamp did not assemble", the same
  predicate § `modStructFuncAssembleBin` already computes. `portsel_struct_param`
  converted without it; `FuncStructValSimple` needs it.
* **R1 — the struct-typed `T'(0)` cast in the ELAB package view.** Golden keeps
  the CAST OPERATION (opType 67, a UINT:0 size-64 operand, ts ref ->
  struct_typespec); we fold it to a constant at the struct width, and our DEF
  view's cast carries an `integer_typespec` where golden carries the
  struct_typespec. That single law is the head of `def_ctx_struct_param`,
  `latch_decoder_partial` and `latch_tlb_napot` — three tests, one fix.
* **R2 — an override actual that is a bare reference to an assembled struct
  localparam.** `dcs_mid #(.Cfg(dcs_cfg_pkg::CfgDefault))` is golden
  `34'b…010` BIN ct 3 and ours `UINT:130`: the override copies the referenced
  parameter's assembled encoding through `adjustSize`, the same inheritance
  § `elabOvRefIntConst` already models for an INT-valued localparam.
* **R3 — a module parameter defaulted to a package localparam of this family.**
  `parameter cfg_t Cfg = p::C` is golden the assembled constant and ours a
  re-emitted `func_call` (`struct_param_func_config`).
* **R4 — outside ParamEmit.** `struct_member_cfg_width` wants a
  `ref_typespec` on a logic_net typed by a module-local typedef with
  parameter-driven member widths; `struct_param_field_shift` wants the formal's
  `int_typespec` stamped on a call ARGUMENT constant (the § r10fsv3 S8
  family); `param_nested_struct_field_width` wants `vpiLocalParam:1` on a
  `type_parameter`.
