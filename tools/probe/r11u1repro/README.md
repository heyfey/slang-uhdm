# r11u1 — the interface PORT-VIEW parameter shape under Surelog v1.87

§ `ifacePortViewParamAssignsOnly`. Everything here is MEASUREMENT-ONLY; the
judge is `uhdm-cmp` through `scripts/verify_golden.py`.

## 1. The producer change (decoded from the v1.86 → v1.87 Surelog diff)

Two commits in the 182-commit bump moved the interface-parameter golden shape:

* `38aa041c48` "Resolve interface parameters/localparams reached through a
  modport port" — `NetlistElaboration::elab_interface_`
  (`src/DesignCompile/NetlistElaboration.cpp:1913-1934`) now ends EVERY
  `interface_inst` build with

  ```cpp
  if (netl->param_assigns() == nullptr) {
    elab_parameters_(interf_instance, true);
    elab_parameters_(interf_instance, false);
  }
  if (auto pas = netl->param_assigns())
    if (sm->Param_assigns() == nullptr) { sm->Param_assigns(pas); ... }
  ```

  so an interface-port COPY that used to reach `UhdmWriter` with no
  `param_assigns` now always has them, elaborated from the copy's own
  `ModuleInstance` (which is built from the interface DEFINITION).
  It also stops `ModuleInstance::getComplexValue`'s upward parameter walk at an
  interface boundary (`src/Design/ModuleInstance.cpp:98`).

* `e2f01837ce` "Fix interface parameter override propagation through modport
  ports" — `getInterfaceInstance_` now also matches the BASE instance name when
  a modport select is present, `propagateIfaceParams_` clones the connected
  instance's `param_assigns` onto the port copy, and `UhdmWriter.cpp:4411` adds
  `for (interface_inst* interf : *subInterfaces) { if (interf->Param_assigns())
  continue; ... writeElabParameters(...); }`.  After `38aa041c48` every copy
  already HAS `Param_assigns`, so that fallback — the only thing that ever put a
  `Parameters` vector on a port copy — is unreachable.

Net effect on the golden: **a port view lists NO `Parameters` and its FULL
`Param_assigns` vector.**  The four other interface commits in the bump
(`c56ea785bc`, `12e466e946`, `3ef83f4cb1`, `6bbab534c5`) change VALUES inside
that shape, not the shape.

## 2. The golden grid (real Surelog v1.87, `[ERROR] : 0` on every arm)

`grid1/dut.sv`, `grid2/dut.sv`, `grid3/dut.sv` — reproduce with

```bash
cd grid1 && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv
~/git-repos/UHDM/build/bin/uhdm-dump slpp_all/surelog.uhdm > golden.dump
python3 ../ifcen.py golden.dump | sort -u
```

`grid1` = `interface tif #(int W = 16, p::cfg_t CFG = CFG_DEF); localparam int
BYT = CFG.BUS.DAT/8;` with `tif #(.W(32), .CFG(CFG_OVR)) u_ov()`, a default
`u_df()`, an array `arr[2]` at `#(.W(8))`, and seven receivers.

| view | kind | port form | connection | par | pa | W | vpiOverriden |
|---|---|---|---|---|---|---|---|
| `work@tif` | def | – | – | 3 | 3 | 16 | 0 |
| `work@top.u_ov` | home | – | – | 3 | 3 | 32 | 2 |
| `work@top.u_df` | home | – | – | 3 | 3 | 16 | 0 |
| `work@top.arr[i]` | home | – | – | 3 | 3 | 8 | 1 |
| `work@top.a0.q` | port | `tif.mp` | `.q(u_ov.mp)` | **0** | 3 | **32** | **2** |
| `work@top.a1.q` | port | `tif.mp` | `(u_ov.mp)` pos | **0** | 3 | 16 | 0 |
| `work@top.a2.q` | port | `tif` | `.q(u_ov)` | **0** | 3 | 16 | 0 |
| `work@top.a3.q` | port | `tif` | `(u_ov)` pos | **0** | 3 | 16 | 0 |
| `work@top.a4.q` | port | `tif.mp` | `.q(arr[0].mp)` | **0** | 3 | 16 | 0 |
| `work@top.a5.q` | port | `tif.mp` | `.q(u_df.mp)` | **0** | 3 | 16 | 0 |
| `work@top.g.a6.q` | port | `tif.mp` | `.q(u_ov.mp)` in gen | **0** | 3 | 16 | 0 |
| `work@top.fl.ty` (grid3) | port | nested iface | `.ty(ty)` | **0** | 2 | default | 0 |
| `work@top.u1.gi` (grid3) | port | generic | `.gi(ty)` | **0** | 2 | default | 0 |
| `work@top.u_df` col-0 tail dup (grid2) | dup | – | – | **0** | 3 | shared | 0 |

Read three ways:

1. **Presence** — par = 0 on EVERY port view and on the col-0 tail dup; pa is
   always the full vector.  This is what v1.87 changed.
2. **Value** — only `a0.q` (NAMED + MODPORT-qualified) takes the connected
   instance's override; every other cell folds at the declaration DEFAULT.
   This is the r10ie matrix already encoded as `ifaceDefaultScope`, unchanged.
3. **`vpiOverriden`** — carried by exactly the cells that take the connected
   values (the home views and `a0.q`), by nothing else.  Same switch as (2).

`grid2` is the SINGLE-parameterization variant (no override anywhere): it
isolates the presence law from the value law, and our patched build matches it
cell for cell.

## 3. Instruments

* `ifcen.py <dump>` — per-`interface_inst` census: fullname, `par=` (count of
  `|vpiParameter:`), `pa=` (count of `|vpiParamAssign:`), each parameter's
  inline value and each param_assign's Lhs name and Rhs decompile.
* `cen.sh <verify_golden workdir> <outdir> <names...>` — dumps GOLDEN and OURS
  for each named test out of a sweep workdir (golden path read from that row's
  own `cmds.txt`) and diffs the two censuses.
* `predict.py <workdir>` — the a-priori MOVER PREDICTOR.  Names, from PRISTINE
  databases alone, every test whose bytes the law must move: a database holding
  at least one `interface_inst` emitted at COLUMN 0 (our port views and our
  col-0 tail dups both anchor there; a home view keeps the instantiation
  statement's real column, a def view the declaration's) that carries at least
  one `|vpiParameter:` child.
  * POSITIVE CONTROL: `grid2` compiled by the PRISTINE binary reads `True`;
    the same source compiled by the patched binary reads `False`.  The
    predictor flips exactly when the law lands.
  * NEGATIVE CONTROLS: `iface_modport` and `iface_passthrough` — CMP_EQUAL rows
    that DO contain interfaces — both read `False`.

## 4. The law

`src/ModuleEmit.cpp`, three faces of one rule (`§ ifacePortViewParamAssignsOnly`):

1. `emitInterfaceInstance` — for a PORT VIEW (`portView != nullptr`), keep the
   whole `Param_assigns` vector emitParameters built (deleting the five v1.86
   filtering arms: the `actualOutOfScope16` gate, the array-element drop, the
   plain-port drop, the positional-modport drop, and the keep-localparams-only
   filter) and set `Parameters(nullptr)`.
2. `makeIfaceRefDup` — the col-0 TAIL DUP stops building its own
   default-valued parameter objects and only shares the home view's
   `Param_assigns`.
3. `emitInterfaceInstance`, in the `ifaceDefaultScope` block — a port view that
   folds at the DEFAULT scope clears `vpiOverriden` on its param_assigns and
   restamps each scalar constant Rhs from its Lhs parameter's inline
   (declaration-default) value.

Faces 1 and 2 are the PRESENCE law v1.87 introduced; face 3 is the VALUE half
of the pre-existing r10ie matrix, which only became observable once the vector
stopped being dropped.

`grid2` (single parameterization) reproduces GOLDEN EXACTLY after the patch —
`diff GRID.golden.txt GRID.patched.txt` over its section is empty.

## 5. Results

See `GATES.r11u1.txt` (every gate, with the negative controls),
`MOVERS.r11u1.txt` (mover attribution incl. the pristine-vs-pristine coin
proof for MiniAmiq / SeqDriver / Scoreboard) and `POPULATION.r11u1.txt`
(the 36 converted rows quoted, and the ranked residues R1..R4).

36 rows convert: uhdm2rtlil 719/85 -> 733/71 in BOTH modes, surelog
455/28 -> 459/24 (default) and 451/26 -> 455/22 (testflags).

`canaries.sh`, `ctcan2.sh` and `canaudit.sh` are verbatim copies of the current
generation in `tools/probe/r10uvm221repro`, kept here so the audit runs in this
pass's own directory as the ops rules require.
