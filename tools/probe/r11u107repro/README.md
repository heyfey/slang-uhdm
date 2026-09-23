# r11u107 — head cluster C, the type-parameter typespec faces

Base `772d5083`. The pins are in `SUPPORT_MATRIX.md`:

* slang `7d61e0ad1`
* UHDM v1.87
* Surelog v1.87 `0445655ee7`
* uhdm2rtlil v0.68

The production files are `src/TypeEmit.cpp` and `src/UhdmExporter.cpp`. The four
fenced files (`ModuleEmit.cpp`, `ExprEmit.cpp`, `EmitHelpers.h`, `ParamEmit.cpp`)
are untouched. `results/*.csv` is untouched.

| binary | md5 |
|---|---|
| pristine (this worktree, `-j 2`) | `b8e8c23a6916473019f14f514584f349` (= the OPS pin) |
| law | `2ceece032fafe538ae7c8a482ef2dc39` (the same md5 when the patch is rebuilt on a fresh `772d5083`) |

## The three laws. Each has its own switch; `R11U107_OFF=1` turns off all three.

With `R11U107_OFF=1`, all 55 grid arms are byte-identical to the pristine
binary. Each single switch turns off only its own law (evidence below).

### Law 1: § anonPackedAggDimTs107 (TypeEmit.cpp, `makeTypespec` fallback). Switch: `R11U107_ANONAGG_OFF`

An anonymous `struct packed {..} [d]` or `union packed {..} [d]` becomes a
`packed_array_typespec`, not the `logic_typespec` fallback.

* The array spans the keyword through `packed`.
* It has one range per written dimension. The existing vector bound builder
  folds the ranges.
* Its element is an unnamed ref to the aggregate, which sits at the bare keyword.
* The members are parented at the array.

Source in Surelog `src/DesignCompile/CompileType.cpp`:

* 1273-1296: the dimension search skips every member.
* 1639-1689: the `paStruct_union` arm builds the wrapper.
* 1690-1716: the members are compiled after `result` has become the array.

Gates:

* The written type is the StructUnion syntax.
* `packed`.
* Not `signed`. Golden a10 drops the dimensions entirely.
* No unpacked dimension. a17 was never decoded and is left alone.
* The leaf is exactly one packed struct or union.

The fallback `logic_typespec` is `Erase`d. It never reaches the database.

### Law 2: § typeParamAnonAggDefault107 (TypeEmit.cpp, `makeTypeParamDefaultTs`). Switch: `R11U107_TPAGG_OFF`

An anonymous packed struct or union written as a type-parameter default
becomes its own `struct_typespec` or `union_typespec` at the keyword. With
outer dimensions, it becomes the same wrapper as Law 1. The bounds are
`Reduce::No` (§ typeParamDefaultBoundNoReduce20).

Source: Surelog `CompileHelper.cpp:3508-3510` hands the default to the same
`compileTypespec` arm.

Gates:

* Packed only. An unpacked default (t08) is minted per use in golden.
* Signed together with dimensions is refused.
* Enum defaults (t07) are not touched.

### Law 3: § tpElemRebindDefView107 (UhdmExporter.cpp, a post-pass at the end of `exportDesign`). Switch: `R11U107_TPREBIND_OFF`

The DEFINITION's `type_parameter` has a § 31 default of the form
`id_t [DEPTH-1:0]`. It is re-pointed to a rebuilt `packed_array_typespec`:

* same span and parent;
* the SAME range vector;
* a new element ref named `id_t` that points at the LAST elaborated instance's
  binding.

The definition's ports keep the original object.

Source:

* `ElaborationStep::elabTypeParameter_` (Surelog `ElaborationStep.cpp:1716-1757`)
  runs on the definition object `sit->getUhdmParam()`.
* `bindTypespec` (`CompileType.cpp:667-714`) always clones, so the
  definition's parameter ends up with the last instance's binding.
* An instance that overrides the array parameter itself contributes nothing
  (o10).

The law mints only when the binding differs from the definition element in a
way the judge can see (`Compare`).

## Face 2 is FENCED, and its site was verified by a probe that is not shipped

The site is `src/ModuleEmit.cpp:28355` (`defPts = tit->second;`), with its
dimensioned twin at `:28366`.

* The top-module port writer builds the def-view unpacked wrapper at `:28278`
  (`defPts = ats`).
* It then overwrites that wrapper with the type-parameter default for every
  port typed by a type parameter.
* A non-top child keeps the wrapper, because emitPorts wraps it.

The PROBE (`R11U107_PROBE_F2`) sets the wrapper's element ref to the default
and leaves `defPts` alone. The probe is NEVER in this patch, and the file was
restored. With the probe:

* `type_param_unpacked_port` reads **0 lines in both modes**.
* Grid u01, u02 and u05 go to 0.
* u04 (`logic [7:0]` default) moves to a different head, so it needs its own
  grid.

## Fenced for report only: type_param_packed_dim (R0)

The head is golden `packed_array_var` against our `logic_var` for `rt_t rt_i`.

* The factory `emitTypeParamArrayVar` (TypeEmit.cpp; pristine line 21884,
  `dt.kind != PackedArrayType`) serves only WRITTEN dimensions (`T [1:0] x`).
* A declaration typed by a § 31 type parameter with no written dimensions
  falls through.
* The call site is `ModuleEmit.cpp:11985`.

Grid arms o01-o09 now all reach this same head.

## Evidence (`evidence/`)

| file | contents |
|---|---|
| `GRID107.txt` | 55 arms, uhdm-cmp lines and heads for pris and law |
| `HEADS107.grid.txt` | the heads |
| `DIST107.txt` | whole-dump distance |
| `CELLS107.*` | the name-keyed cell scorer (`cell107.py`). Grid: MOVED-WRONG 0, GAINED 92. The five rows × 2 modes: MOVED-WRONG 0, GAINED 18 |
| `ROWS107.txt` | the five rows × 2 modes before and after |
| `SRCCEN107.txt` | the source census |

The positional slot scorer (r11u101 `slot101.py`) reports one MOVED-WRONG on
anon_struct_packed_dim. It is a POSITION artifact:

* Golden's `vpiVariables[0]` is `vvm`.
* Ours is our surplus `struct_var content_q`.

Keyed by name, that cell GAINED. The cell scorer's positive control (one
kind flipped by hand) reads MOVED-WRONG=1.

Tools: `grid107.sh`, `cmp107.sh`, `dist107.sh`, `cell107.py`,
`srccen107.py`, `path107.cpp`. The canary battery is copied from
r10uvm221repro.
