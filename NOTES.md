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

## Hierarchy quirks (AssignSumOfConstantsInSubmodule, 2026-07-17)

- AllModules = ALL used definitions, name-sorted; def content is filled
  LAZILY as the instance tree first reaches each definition. Per-instance
  creation order: def fill -> instance vars/nets -> children (recursive) ->
  instance ports -> cont_assigns/processes. weaklyReferenced dump order
  depends on this exactly.
- Def view: children appear as ref_module (name, defName, Actual_group->def
  module, loc=instance name span) with ports carrying only High_conn
  ref_objs named work@<mod>.<inst>.<formal>.<actual> pointing at def nets.
- Top view: children are full module_inst objects: VpiName/VpiFullName
  (instance path), VpiDefName, VpiDefFile+VpiDefLineNo, Instance(parent) AND
  Module_inst(parent) back-refs (Module_inst is invisible in uhdm-dump but
  checked by uhdm-cmp!), loc = whole instantiation statement. Contents are
  re-emitted per instance (instance-path fullnames); only TOP modules share
  the def's process objects (their prefix equals the def prefix).
- Child ports: loc = def port loc; LowConn ref at the formal name in the
  connection (.a -> `a` token), full = instpath.formal, actual = child
  net/var. HighConn = plain expression ref bound in PARENT scope (parent
  netmap, parent prefix, actual = parent net/var).
- When a parent signal feeds a child HighConn, the signal's typespec gets
  VpiParent(re-set) to the signal (source of the mux2 {S,B,Y}-style parent
  pattern for vars; nets always get ts parent at creation).
- Top-view cont_assign Rhs is CONSTANT-FOLDED when the expression is
  constant and not a plain literal: constant with decimal decompile,
  UINT:<val>, vpiSize = expr type width, no loc/parent. Def view keeps the
  unfolded expression.
- Bare unsized decimal literals: UINT:<digits>, vpiSize 64, vpiConstType 9.
  Sized/based literals: BIN/HEX/OCT/DEC:<digits>, vpiSize = literal size,
  vpiDecompile = source text. Constants get VpiParent only as operation
  operands (and in typespec range bounds, where they're 64-bit UINT).
- `int` ports: def view = plain logic_net (no netType); top view = int_var
  (Signed, Visibility 1) in Variables; int_typespec (VpiSigned) everywhere.
- uhdm-cmp compares fields the dump never prints (Module_inst, typespec
  Instance) — DUMP_MATCH alone is not sufficient; always require PASS_CMP.
