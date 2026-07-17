# slang-uhdm development notes

Running log of Surelog-shape observations, replicated quirks, and decisions.
See PLAN.md for the overall strategy. Anchor versions: UHDM `5523dfc`
(v1.86-31, installed to ~/.local), Surelog `cbdbea458c` (v1.86-114).

## Golden-dump observations (mux2, `surelog -parse -nobuiltin -nocache`)

Source of truth: `uhdm-dump` of `slpp_all/surelog.uhdm` for
`~/git-repos/uhdm2rtlil/test/mux2/dut.sv`.

- Design: `VpiName = "work@<first-top>"`. No vpiElaborated flag in folded
  output.
- **Folded model shares process objects**: `uhdmtopModules` module contains
  the *same* `always` object as `uhdmallModules` (dump prints a stub on
  revisit). Nets and ports, however, are **separate objects** in each view.
- Module def (allModules): has `VpiDefName` + `VpiFullName` (no `VpiName`);
  top module (topModules): `VpiName` + `VpiDefName` + `VpiFullName` +
  `VpiTop(1)` + `VpiTopModule(1)`. (dump prints vpiFullName only when it
  differs from vpiName, so def shows FullName and top shows Name)
- Net objects for port-connected signals take the **port-list location**
  (line 1), not the declaration location (line 2). `output reg Y` becomes a
  `logic_net` with `VpiNetType = 48` (vpiReg) — not a variable.
- Port `Low_conn` ref_obj naming differs between views:
  def view `work@mux2.S.S` (port-scoped), top view `work@mux2.S`.
- Typespecs: def-view nets carry **no** typespec; top-view nets carry
  `Typespec -> ref_typespec -> logic_typespec` (ts parent = the net). Ports in
  both views carry `Typespec` (dumped as `vpiTypedef`) `ref_typespec` with
  `VpiFullName = work@mod.<port>`.
- Typespec location = the declared type syntax; for implicit types a
  zero-width range at the declaration identifier (e.g. `input S;` ->
  2:11-2:11); for `reg Y` the `reg` keyword range (4:12-4:15).
- mux2 has **10** logic_typespec objects in the weaklyReferenced dump
  section: 3 unparented (one per declaration?), 3 parented to top nets S/B/Y
  (not A!), 4 unparented (port typedefs). Creation-order dependent; not yet
  replicated exactly — see Open questions.
- always block: `VpiAlwaysType(1)`; `@(*)` = `event_control` with **no**
  condition; assignment carries `VpiOpType(82)` (vpiAssignmentOp) +
  `VpiBlocking(1)`; ternary = `operation VpiOpType(32)` with operands
  [cond, true, false]; expression `ref_obj`s point (`Actual_group`) at the
  **def-view** nets.
- Locations are name-span based for named objects (`S` at 1:14 -> 1:14-1:15);
  end column is one past the last character.

## Replicated quirks

- `work@` prefix on def names, full names, and design name.
- Port-list location used for port-connected nets.
- `VpiNetType(48)` for variables that back ports (output reg).
- Def/top low_conn naming difference (`.S.S` vs `.S`).

## Open questions / not yet replicated

- Exact typespec object count/creation order (weaklyReferenced section
  order). May need a documented sort-normalization in converge.sh, or
  replicate Surelog's per-declaration + per-net typespec cloning rules
  (see Surelog NetlistElaboration.cpp / CompileType.cpp).
- Whether Surelog sets VpiFile on every object or only module_inst
  (dump only prints it on modules; uhdm-cmp will reveal).
- Design VpiName for multi-top designs (first top? all tops?).

## Status log

- 2026-07-17: M0/M1 scaffold written (tools/uhdm; CMake gated on
  find_package(UHDM)); UHDM installed to ~/.local; slang build reconfigured
  with CMAKE_PREFIX_PATH=~/.local. Building.
