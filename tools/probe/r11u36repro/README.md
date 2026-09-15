# r11u36 — an interface-ARRAY ELEMENT port view carries its param_assigns

Base `34b04279` (branch `matrix-1.87`). Pins per `SUPPORT_MATRIX.md`: slang
upstream-master `7d61e0ad1`, UHDM v1.87, Surelog v1.87
(`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

Target: the r11u29 triage's **K10**, "an interface ARRAY element is absent
from our elaborated view" (`tools/probe/r11u29repro/TRIAGE.md`, the K10
section).

---

## 0. THE TRIAGE'S FRAMING IS REFUTED — the object was never absent

K10 reads *"Both are `RHS: <null>` on an `interface_inst` whose `vpiName`
carries the `[0]` subscript and whose `vpiVariables` golden fills in. **We
produce no such object.**"*

We produce it. Both heads are the **VECTOR** `SafeCompare` overload's
one-sided arm (`~/.local/include/uhdm/BaseClass.h:217`,
`(lhs != nullptr) && !lhs->empty() && (rhs == nullptr)`): it sets
`m_failedLhs` to the **OWNER** and leaves `m_failedRhs` unset, so uhdm-cmp
prints the whole owning `interface_inst` against `RHS: <null>`. The owner is
present on both sides; what is missing is one of its vectors.

The vector is `Param_assigns`, read by `scope::Compare`
(`~/git-repos/UHDM/build/generated/src/scope.cpp:346`), which
`interface_inst::Compare` reaches through `basetype_t::Compare` on its very
first line (`interface_inst.cpp:273`) — ahead of every interface-specific
field. This is exactly the misread `RESUME.md` §9 warns about
(*"`ctladder`'s `SHAPE=MISSING-OURS` is misleading when `FIELD=<rhs-null>`"*).

Proof, from the pristine whole-dump diff of `interface_array_fanout`
(`diff golden.dump ours.dump`, 503 lines): the ONLY golden-only hunks at
`work@dut.f.m[0]` and `work@dut.f.m[1]` are their 21-line `|vpiParamAssign:`
subtrees. Every other field of both objects — `vpiName`, `vpiFullName`,
`vpiVariables`, `vpiDefName`, `vpiModport`, `vpiPort` — is byte-identical.

## 1. The measured heads at the base

`interface_array_fanout` (uhdm2rtlil, **default and testflags**), baseline
rows quoted verbatim from the committed CSVs
(`results/golden_uhdm2rtlil.csv` lines 400 and 1271;
`results/gate_uhdm2rtlil.csv` line 400):

```
interface_array_fanout,default,CMP_NOTEQUAL,decompile:,,
interface_array_fanout,testflags,CMP_NOTEQUAL,decompile:,,
```

One head (`grep -c '^LHS:'` = 1), 175 lines:

```
LHS:
decompile:
interface_inst: work@myif (work@dut.f.m[0]), id:551, …/dut.sv, line:38:0
|vpiParent:
\_module_inst: work@fanout (work@dut.f), id:966, …
|vpiName:m[0]
|vpiFullName:work@dut.f.m[0]
|vpiVariables: … |vpiParamAssign: … |vpiDefName:work@myif |vpiModport: … |vpiPort: …
RHS: <null>
```

`Rggen` (Surelog corpus). **The OPS line "Rggen is CMP_EQUAL/default and MUST
STAY equal" is STALE at this base** — read, not inherited,
`results/golden_surelog.csv` lines 1190–1191:

```
Rggen,default,CMP_NOTEQUAL,decompile:,,
Rggen,testflags,SURELOG_FAIL,[INF:UH0707] Elaborating UHDM...,,
```

Its default row is NOT-EQUAL at the base and stays NOT-EQUAL after this pass
(§5). Its testflags row is a Surelog-side failure and has no slang-uhdm
content at all. Re-measured head, one head, 401 lines, re-read byte-stable:

```
LHS:
decompile:
interface_inst: work@rggen_register_if
        (work@rggen.u_block_0.u_adapter.register_if[0]), id:18251,
        …/rggen-sample/block_0.sv, line:148:0
|vpiName:register_if[0]
|vpiFullName:work@rggen.u_block_0.u_adapter.register_if[0]
…   (five |vpiParamAssign: subtrees)
RHS: <null>
```

## 2. The producer

`src/ModuleEmit.cpp`, the interface-port loop's whole-array arm
(`conn.first->kind == SymbolKind::InstanceArray`). It builds each element
view with `emitInterfaceInstance(…, portView=&inst, …)` — which since r11u1
(§ `ifacePortViewParamAssignsOnly`) correctly gives a port view its full
`Param_assigns` vector and no `Parameters` vector — and then threw both away
at the call site:

```cpp
// An ARRAY-PORT element view (.m(arr)) is a minimal
// reference-style view: it drops BOTH the parameter and
// the override param_assign (interface_array_fanout).
ei->Param_assigns(nullptr);
ei->Parameters(nullptr);
```

That is § `ifaceArrayElemPortViewNoPa`, calibrated against **v1.86** goldens
(its own text: *"all 89 of [Rggen's] element port views listed 5
param_assigns against golden's 0"*). It is the last v1.86 survivor of the
producer change r11u1 decoded: `NetlistElaboration::elab_interface_`
(Surelog `src/DesignCompile/NetlistElaboration.cpp:1913-1934`, commit
`38aa041c48`) now ends EVERY `interface_inst` build by elaborating the copy's
own parameters when its netlist carries none, and the
`if (interf->Param_assigns()) continue;` guard added at
`UhdmWriter.cpp:4411` makes `writeElabParameters` — the only thing that ever
put a `Parameters` vector on a port copy — unreachable. An array ELEMENT
reaches that code through the same door as a scalar port copy, so it gets the
same shape. Nothing about the element-ness survives.

## 3. The GOLDEN GRID (`grid1/dut.sv`, real Surelog v1.87)

```
cd grid1 && ~/git-repos/Surelog/build/bin/surelog -parse -elabuhdm -d uhdm dut.sv
```

**rc = 0, `[ERROR] : 0`, `[WARNING] : 10`** — one file, one arm per row.
`tif #(parameter int W = 8, parameter p::cfg_t CFG = p::DEF)` with
`localparam int BYT = W/8 + CFG.A`; holder arrays declared
`#(.W(32), .CFG(p::OVR))` (`arr`, `wid`, `one`) and bare (`dfl`).
Census `elemcen.py --elems` (max child counts per fullname — the dump
abbreviates repeated objects, so a first/min reading manufactures phantoms):

| view | port form | actual | golden par | golden pa | W |
|---|---|---|---|---|---|
| `work@top.a0.m[0..1]` | `tif.mp m [1:0]` | `arr` (overridden) | 0 | 3 | 8 |
| `work@top.a1.m[0..1]` | `tif.mp m [1:0]` | `dfl` (defaults) | 0 | 3 | 8 |
| `work@top.a2.m[0..1]` | `tif.mp m [2]` (size form) | `arr` | 0 | 3 | 8 |
| `work@top.a3.m` | `tif m [1:0]` (PLAIN, no modport) | `arr` | 0 | 3 | 8 |
| `work@top.a4.q` | `tif.mp q` (scalar) | `arr[0]` | 0 | 3 | 8 |
| `work@top.hm[0..1]` | array port at an INTERFACE holder | `arr` | 0 | 3 | 8 |
| `work@top.a6.w[0..3]` | `tif.mp w [3:0]` (4-wide) | `wid` | 0 | 3 | 8 |
| `work@top.a7.u[0]` | `tif.mp u [0:0]` (1-wide) | `one` | 0 | 3 | 8 |
| `work@top.g[0].a8.m[0..1]` | `tif.mp m [1:0]` in a generate loop | `arr` | 0 | 3 | 8 |
| `work@top.arr[0..1]` | HOME view (holder's own array) | — | 3 | 3 | 32 |
| `work@top.dfl[0..1]`, `wid[0..3]`, `one[0]` | HOME view | — | 3 | 3 | 8/32 |
| `work@tif` | DEF view | — | 3 | 3 | 8 |

Uniform: **every per-element PORT view is `par=0 pa=ALL`, the same shape a
scalar port view carries** — array size, `[msb:lsb]` versus size form,
modport-qualified versus plain, module versus interface holder, inside a
generate loop or not, overridden actual or default actual. Only the HOME and
DEF views keep `Parameters`.

The **VALUE** law is untouched: every element view folds at the
DECLARATION DEFAULTS (`W=8`, `BYT=2`), never at the connected array's
override (`W=32`, `BYT=13`) — § `ifaceDefaultScope`, unchanged.

The corpus confirms the grid on a multi-parameterised def: golden's
`work@rggen.u_block_{0,1}.u_adapter.register_if[0]` each carry `par=0 pa=5`.

## 4. The law

`src/ModuleEmit.cpp`, the array-port element loop:
`ei->Param_assigns(nullptr);` **deleted**, `ei->Parameters(nullptr);` kept,
and § `ifaceArrayElemPortViewParamAssignsOnly` written in its place with the
grid above. The stale § `ifaceArrayElemPortViewNoPa` comment block in
`emitInterfaceInstance` is marked REFUTED-AND-REMOVED and kept as history.
No other production change.

Grid proof, pristine vs law (name sets IDENTICAL; `elemcen.py --elems`):
15 objects change, every one an array-port element view, every one
`par=0 pa=0` → `par=0 pa=3`, which is golden's shape for all 15. No
`work@top.{arr,dfl,wid,one,hm}[N]` and no `work@tif` moves.

## 5. Movers — PREDICTED A PRIORI, then measured

`predict.sh` reads only the **PRISTINE** databases (never the patched ones)
and names every row that can move: a database moves only if it already holds
an `interface_inst` whose own `vpiName` ends in `[<digits>]` with an EMPTY
parameter shape (`par=0 pa=0`) — the footprint the deleted nulling leaves.
It is a deliberate SUPERSET (an element view of an UNPARAMETERISED interface
reads `par=0 pa=0` too and cannot move), so a mover OUTSIDE it refutes the
model. POSITIVE CONTROL: `POSCTL=` asserts a known mover is in the set — a
blind lister prints an empty set exactly like a clean run.

* uhdm2rtlil, 1608 pristine databases: **18 rows predicted**
  (`genvar_iface_struct`, `iface_array_count`, `iface_array_internal_assign`,
  `iface_array_modport_drive`, `iface_array_port`, `iface_array_struct`,
  `iface_array_struct_field`, `iface_array_struct_whole`,
  `interface_array_fanout`, each ×2 modes). `POSCTL ok:
  interface_array_fanout is predicted`.
* Surelog corpus: see `PREDICT.surelog.txt`; `POSCTL ok: Rggen is predicted`.

MEASURED (`SELFCHECK=1 byteverify.sh <law wd> <my own pristine wd>`):

* uhdm2rtlil: `PATH_SETS_IDENTICAL (1608 paths)`, **MOVERS 2 / 1608**,
  `SELFCHECK 1607 / 1608 flagged`. Both movers are
  `interface_array_fanout` (default + testflags) — both PREDICTED, both
  CONVERSIONS.
* Surelog: see `MOVERS.r11u36.txt`.

The eight predicted-but-still non-movers are explained, not lucky: their
interfaces declare no parameters at all (the `#(…)` in
`iface_array_modport_drive` and `genvar_iface_struct` is on the MODULE, not
on `myif`), so their element views carry an empty vector either way.

## 6. CONVERSIONS — say it loudly

**`interface_array_fanout` CONVERTS in BOTH modes.** The committed baseline
rows

```
interface_array_fanout,default,CMP_NOTEQUAL,decompile:,,     (results/golden_uhdm2rtlil.csv:400)
interface_array_fanout,testflags,CMP_NOTEQUAL,decompile:,,   (results/gate_uhdm2rtlil.csv:400)
```

become

```
interface_array_fanout,default,CMP_EQUAL,,,differ
interface_array_fanout,testflags,CMP_EQUAL,,,differ
```

(`differ` in the dump column is the normal state of 482 already-equal
uhdm2rtlil rows; the DATABASE compare is the judge.) `results/*.csv` is NOT
edited by this pass.

uhdm2rtlil per-mode status histogram, both modes: `774 CMP_EQUAL / 30
CMP_NOTEQUAL / 67 SLANG_REJECT` → `775 / 29 / 67`.

## 7. Rggen — the head moves DEEPER, the row does not convert

Predicted before the sweep and confirmed: `Rggen/default` stays
`CMP_NOTEQUAL`. Its head moves from the 401-line whole-`interface_inst`
`RHS: <null>` to a 32-line `constant` inside the very `param_assign` vector
the law now emits. The residue is the port-view **VALUE** face, which this
pass does not touch and which Rggen already carries on ~90 SCALAR port views
at the base (golden `ADDRESS_WIDTH<-constant=8|7`, ours `16`). The law puts
5 of 5 param_assigns on each of the two element views, 4 of 5 values
byte-right per view. Strictly closer, never further.

## 8. Files

* `elemcen.py` — SHAPE LISTER: per-`interface_inst` max `vpiParameter` /
  `vpiParamAssign` counts + the array-element flag (keyed on the object's own
  `vpiName`, so a scalar view inside an element holder is not counted).
* `predict.sh` — the a-priori mover predictor with its positive control.
* `ifcen.py`, `cen.sh` — the r11u1 value census, reused unchanged.
* `grid1/dut.sv` — the golden grid.
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh` — the r10uvm221 battery, current
  generation, copied unchanged.
* `GRID.*.txt`, `PREDICT.*.txt`, `MOVERS.r11u36.txt`, `GATES.r11u36.txt` —
  the measurements.
