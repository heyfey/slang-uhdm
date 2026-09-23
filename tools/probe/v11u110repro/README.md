# v11u110 — adversarial verification of r11u110 (the override element of a packed-array type-parameter typespec)

Base `751362a0`. Pins as in `SUPPORT_MATRIX.md`. Verdict: **ACCEPT-WITH-FIX**. The fix is one
droppable gate in `src/UhdmExporter.cpp`. No fenced file and no `results/` file is edited.

| binary | md5 |
|---|---|
| pristine | `1dae94065a1ba3fe44c9b50007752e64` (the pin) |
| law, r11u110.patch | `53761406d096e3b700d440e9ca1fd67f`, the same md5 the implementer reported |
| verified patch | `1fd10542f5e2b48dfbdc3f9a16daab0f`, rebuilt to the same md5 from a fresh `751362a0` |

## The conversion

The uhdm2rtlil row `type_param_override_elem_sel` **CONVERTS in both modes**. At the base it
has 47 lines and 1 head in each mode. With the law it has 0 lines and 0 heads, and there is
no next head. The committed rows are:

```
type_param_override_elem_sel,default,CMP_NOTEQUAL,decompile:,,
type_param_override_elem_sel,testflags,CMP_NOTEQUAL,decompile:,,
```

The law and verified sweeps both read:

```
type_param_override_elem_sel,default,CMP_EQUAL,,,differ
type_param_override_elem_sel,testflags,CMP_EQUAL,,,differ
```

## The decode, checked independently (`who110v.cpp`, on golden)

* Golden's port `work@dut.u.rt_i` points at a fresh `packed_array_typespec` at 17:31.
* Its parent is the definition's `type_parameter rt_t`.
* Its element ref is `id_t`, with full name `work@child.rt_t.id_t`.
* The element is a parentless `logic_typespec` at 32:17. This is a distinct object from the
  instance's `TPAR u.id_t`, so it is a clone and not a share.
* The instance's `TPAR u.rt_t` and the definition's `rt_t` are the same object: the last
  rebind.
* The restored range-vector pointers differ, so vector sharing does not survive
  serialization. No Compare reads it either way.

The producer is Surelog `ElaborationStep.cpp` 1716-1757, `bindTypespec` at `CompileType.cpp`
667-714 (the loop has no break across levels), and the `compileTypespec` fallback at
`CompileType.cpp` 1995-2006.

## The break that needed a fix: a named type with packed dims as the override

The implementer's law was pristine-wrong → patched-wrong in 5 arms:

* `v3/a35` (`.id_t(pk::s_t [1:0])`)
* `v4/q01` (`s_t [1:0]`)
* `v4/q02` (`pk::w_t [1:0]`)
* `v4/q03` (`w_t [1:0]`)
* `v4/q05` (a `$unit` typedef with `[1:0]`)

Golden's instance `type_parameter id_t` binds the NAMED typedef and drops the written dims.
Ours keeps the dimensioned type (a fenced ParamEmit residue). The port element followed ours:
per-cell NE→NE, the first head unchanged, and whole-dump distance −1 to −3.

The gate: slang parses such an override as an `IdentifierSelectName`, possibly behind a
`ScopedName`. When the winning (outermost) override has that form, the law abstains.
`V11U110_FIX_OFF=1` drops the gate.

Measured over 399 arms:

* The verified binary is byte-identical to the law everywhere except those 5 arms, which
  return to pristine bytes.
* `V11U110_FIX_OFF` is byte-identical to the law on all 399 arms.
* Controls that do not have the dims form still fire: `q04` (`pk::s_t`) and `q06`
  (`logic [1:0][1:0]`).

## Break arms (`brk/`: 72 arms; golden-crashing or slang-illegal arms removed)

* **`v1`** (45 arms).
  * Port law: unnamed generate block, generate-for instance array, two parents, a parent
    passing its own type, multi-dim/byte/int-unsigned/bit-vs-logic overrides, two type
    parameters, an ordered middle level under a named outer level, a top with its own type
    parameter, genvar-dependent overrides, `input var` / output ports, an unconnected port,
    a parent-local struct, a typedef-named element under a same-named outer override.
  * Face 2: unbased, block-local, const, negative, top-default, initial-local, generate-body,
    non-local-parameter and int-element initialisers; initialised, top, overridden and 2-state
    unpacked elements; two declarators and two attributes on the written-dims attribute cell;
    nested anonymous, chain-3, scalar, signed, two-member, parameter-used and variable
    multi-dim members.
* **`v3`/`v4`/`v5`/`v6`**: an escaped instance name, two differently named middle modules, an
  interface parent control, the dims-form family, a 16-kind override sweep, and the
  single-dim chain control.

## Scores (`evidence/`)

**Per-cell scores** (`CELLS.txt`, `cell110` keyed by name):

* The seven committed grids (325 arms), pristine → verified patch: 95 cells TO-GOLDEN, AWAY
  0, MOVED-WRONG 0. This matches the implementer's count.
* Break arms, pristine → verified patch: TO-GOLDEN 35 + 4 + 2 + 12, AWAY 0.
* The remaining coarse-cell MOVED-WRONG are explained:
  * `v1/c02`: the reg kind is now golden's `packed_array_var`. The rest of the cell is
    golden's operand `vpiSize:2` quirk.
  * The struct-port cells on the multi-dim arms: `typespec::Compare` walks `vpiInstance`
    into the package, where the DEF listing moved TO-GOLDEN (`cellm108` member cells
    TO-GOLDEN). The remaining head is R0's member-span wrapper element.

**Whole-dump distance** (`DIST.txt`): distance never increases on a break arm. On the
committed grids it rises only on the four multi-dim arms the implementer disclosed
(+1/+5/+5/+1).

**Switch ownership** (`SWITCH.txt`): 370 arms. 111 arms move, each with exactly one owner,
and no arm breaks the switch-identity rule (BAD=0). `R11U110_OFF` equals pristine on every arm.

## Gates (`GATES.txt`, `CENSUS.txt`)

* **Goldens:** 23/0, and `/bin/false` gives 0/23.
* **uhdm2rtlil, both modes:** the whole-row join changes only the two conversion rows.
  byteverify gives 2/1608 movers, exactly the predicted pair.
* **Surelog, both modes:** statuses are identical (474/9 and 469/8).
  * byteverify on the law sweep gives 4 movers; on the verified sweep, 6. All are in the UVM
    family.
  * Compared order-blind, each is the 4-line `UINT`/`vpiDecompile` class, except Scoreboard
    default, which is a 0-line draw. All stay CMP_EQUAL.
* **Canaries:** ok=52 and ok=8. ctcan2 PASS ×2, canaudit PASS.
* **Pins:** SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` in both modes, InterfaceModPort
  `59a365f3ce2c`, Earlgrey `8bdf25272e08` / `59d0ee6d10c3`, plus BlackParrotComplex and YosysOldOr.
  All are byte-identical to pristine.
* **Census:** calibration is 0 on 2568 databases. The shape exists only in the target row and
  in `type_param_packed_dim` (EQ, unmoved). The target row is the positive control.
* **Wide boundary:** 8982 files, PROCESSED = LISTED, 0 RCDIFF, 31 MOVED.
  * 28 are control-grid movers, already scored.
  * 3 are layout-tail arms: LAYOUTPROOF OK, with the diffs below `vpiWeaklyReferenced`.

## Residues (ranked)

The implementer's R0–R5 stand as measured. This pass adds:

* **R6 (fenced ParamEmit):** a named-type-with-dims override (`s_t [1:0]`): golden's
  `TPAR id_t` binds the dims-dropped typedef. The port law abstains (gate above).
* **R7 (pre-existing, not this law):** a generate-for instance array (`v1/a03`) emits no
  instances at all.
* **R8:** in `v1/b10` (generate-body variable) and `v1/b04`/`b09` (block-local initialised
  variables), the law abstains. The heads there are unrelated.

## Tools

| tool | what it does |
|---|---|
| `who110v.cpp` | Object identity per port and type parameter. |
| `cen110v.cpp` / `cenrun110v.sh` | Law-1 shape census with golden-vs-golden calibration. |
| `gridrun110v.sh` | Every grid through `r11u110repro/grid110.sh`. |
| `sweep110v.sh` | The corpus sweep driver. |
