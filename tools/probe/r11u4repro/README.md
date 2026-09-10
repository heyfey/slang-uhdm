# r11u4 — § `ifacePortViewPaFoldsDeclDefault`

A PORT VIEW's `param_assign` vector is the one the interface's **declaration
defaults** produce, and it carries no `vpiOverriden` stamp.  The one exception
is a modport-qualified view reached by a NAMED port connection, which is the
connected instance's vector verbatim.

Everything in this directory is MEASUREMENT-ONLY.  The judge is `uhdm-cmp`
through `scripts/verify_golden.py`.  The production surface of the pass is one
block in `src/ModuleEmit.cpp`.

## 1. The producer mechanism

Surelog v1.87 `NetlistElaboration::elab_interface_`
(`src/DesignCompile/NetlistElaboration.cpp:1913-1934`) ends every
interface_inst build with `elab_parameters_` when the copy has no
param_assigns of its own, and that runs `reduceExpr` over the interface
DEFINITION's parameter declarations.  Only `propagateIfaceParams_` — reached
from `getInterfaceInstance_`, the base-name match `namedModportPortView9`
models — ever copies the CONNECTED instance's vector on top.  So a port view
that is not that one cell shows the declaration's own reduction.

## 2. The golden grid (real Surelog v1.87, every arm rc 0 / `[ERROR] : 0`)

`run.sh <armdir> <binary> <tag>` builds the golden and our database for one arm
and records the Surelog rc, its error count, the slang rc, the cmp rc and the
head count.  `pagrid.py <dump>` reads, per `interface_inst`, one line per
param_assign: the `vpiOverriden` stamp, whether the Rhs carries a
`vpiTypespec` ref, the Rhs object kind and span, and its value lines.

### `g1` — VALUE KINDS x port/connection form, singly-parameterized scalars

`interface tif #(int PI=3, int NI=-3, logic[7:0] HX=8'hA5, real RE=2.5,
string ST="def"); localparam int BYT = PI*2;` instantiated
`tif #(.PI(9), .NI(-9), .HX(8'h5A), .RE(4.5), .ST("ovr")) u_ov()` plus a bare
`tif u_df()`:

| view | port form | connection | PI | NI | HX | RE | ST | BYT | ovr |
|---|---|---|---|---|---|---|---|---|---|
| `work@tif` | def | – | 3 | *op* | 8'hA5 | 2.5 | def | *op* | 0 |
| `top.u_ov` | home | – | 9 | -9 | 8'h5A | 4.5 | ovr | 18 | 1 |
| `top.u_df` | home | – | 3 | -3 | 8'hA5 | 2.5 | def | 6 | 0 |
| `top.a0.q` | `tif` | `.q(u_ov)` | 3 | -3 | 8'hA5 | 2.5 | def | 6 | **0** |
| `top.a1.q` | `tif` | `(u_ov)` pos | 3 | -3 | 8'hA5 | 2.5 | def | 6 | **0** |
| `top.a2.q` | `tif.mp` | `.q(u_ov.mp)` | 9 | -9 | 8'h5A | 4.5 | ovr | 18 | **1** |
| `top.a3.q` | `tif.mp` | `(u_ov.mp)` pos | 3 | -3 | 8'hA5 | 2.5 | def | 6 | **0** |
| `top.a4.q` | `tif` | `.q(u_df)` | 3 | -3 | 8'hA5 | 2.5 | def | 6 | **0** |

`a2` — the named modport — is the ONLY view that reads the instantiation, on a
def that is MULTI-parameterized (`u_ov` and `u_df` are two parameterizations).
The typespec column of the same arm:

| param | default init | def view | home views | a0/a1/a3/a4 | a2 |
|---|---|---|---|---|---|
| PI, HX, RE, ST | a literal | HAS-TS | HAS-TS | **HAS-TS** | HAS-TS |
| NI (`-3`), BYT (`PI*2`) | an OPERATION | no-ts | HAS-TS | **no-ts** | HAS-TS |

and the folded constant's span narrows to the operation's left-most token
(`NI` 5:36-5:37 against 5:36-5:38, `BYT` 9:24-9:26 against 9:24-9:30) — no
generated `Compare` reads a span, so that half is invisible to the judge.

### `g2` — the AGGREGATE half and the SCOPE half

`interface tif #(p::cfg_t CFG = p::CDEF, int W = 4); localparam int BYT =
CFG.BUS.DAT/8;` with `tif #(.CFG(p::COVR), .W(9)) u_ov()`, an array `tif arr[1:0]()`,
a re-passing `mid`/`midm`, and a generate block:

| view | port form | connection | actual lives | CFG | W | BYT | ovr |
|---|---|---|---|---|---|---|---|
| `a0.q` | `tif` | `.q(u_ov)` | same scope | DEF | 4 | 4 | 0 |
| `a1.q` | `tif.mp` | `.q(u_ov.mp)` | same scope | OVR | 9 | 8 | **1** |
| `a2.r` | `tif` | `.r(u_ov)` | same scope | DEF | 4 | 4 | 0 |
| `a2.b0.q` | `tif` | `.q(r)` | a RE-PASSED plain port | DEF | 4 | 4 | 0 |
| `a2.b1.q` | `tif.mp` | `.q(r.mp)` | a RE-PASSED plain port | **DEF** | **4** | **4** | **0** |
| `a3.r` | `tif.mp` | `.r(u_ov.mp)` | same scope | OVR | 9 | 8 | **1** |
| `a3.b2.q` | `tif.mp` | `.q(r)` | a RE-PASSED modport port | OVR | 9 | 8 | **1** |
| `a4.q` | `tif` | `.q(arr[0])` | array element | DEF | 4 | 4 | 0 |
| `g.a5.q` | `tif` | `.q(u_ov)` | OUTSIDE the gen block | DEF | 4 | 4 | 0 |
| `g.a6.q` | `tif.mp` | `.q(u_ov.mp)` | OUTSIDE the gen block | **DEF** | **4** | **4** | **0** |

The two bold DEF rows on a *named modport* connection are residue **R0**: the
base-name lookup misses when the actual is a re-passed PLAIN port selected with
`.mp`, or when it lives outside the instantiating generate block.  `a3.b2.q`
proves the distinguisher is not "re-passed" alone — a re-passed MODPORT port
connected bare KEEPS the connected values.

### `g3` — the two def flavours the RANGE gate exempts

| view | def | port form | W | ovr |
|---|---|---|---|---|
| `c0.q` | GENERATE-bearing | named plain | **4 (default)** | 0 |
| `c1.q` | GENERATE-bearing | named modport | 9 | 1 |
| `c2.q` | TEXT-multi | named plain | **4 (default)** | 0 |
| `c3.q` | TEXT-multi | positional plain | **4 (default)** | 0 |
| `c4.q` | TEXT-multi | named modport | 9 | 1 |

So the generate-bearing and text-multi exemptions belong to `ifaceDefaultScope`
— which decides how the interface's VAR RANGES fold — and NOT to the
param_assign half.  That is why this pass adds a second, independently gated
block instead of widening the existing one.

The value is not always the bare declaration default: `ifacePortViewFoldScope`
substitutes the RECEIVING module's same-named parameters, which is why
OneNetRange's `work@TOP.dut1.middle1.conn` reads `width <- 16` (from `middle`'s
own `width`) and not the declaration's 1.  Restamping from the Lhs parameter
object — the r11u1 rule — would have written 1 there; this pass does not touch
the value.

## 3. What the law writes, and the corpus witness for each face

* **(A) the stamp** — `pa->VpiOverriden(false)` on every param_assign of a
  non-named-modport port view.  Witness **OneNetRange**, whose ENTIRE residual
  head is this bit: golden and we agree on `width <- UINT:16 size 32` and
  differ only in the stamp.
* **(B) the aggregate Rhs** — the DEF view's op75 tree, CLONED.  Witness
  **iface_array_elem_cfg_param**: golden `work@top.u.s` is
  `operation@13:45-13:54 UINT:8`, the same cell as `work@bus_if`'s; ours was
  the connected `arr[]`'s `operation@24:12-24:15 UINT:16`.
* **(C) the reduced operation default** — drop the folded constant's
  `vpiTypespec` ref.  Witness **GenForIfaceLocalparamBound**, whose head IS
  that ref (`LHS: <null>` against our `ref_typespec (work@top.c.sub)` under the
  folded `BYT`).

The DEF view is the oracle for (B) and (C): its param_assign Rhs IS the
unreduced declaration default, so its UHDM kind decides the face.

**Clone, do not share.** The first patched build pointed the port view's Rhs at
the def view's object.  `uhdm-cmp` called it EQUAL — no generated `Compare`
reads `VpiParent` — but `uhdm-dump` then ELIDES the port view's subtree as a
repeat, and this directory's own scorer read the shared cell as empty and
scored a converted test as unchanged.  `UHDM::clone_tree` gives each view its
own object, matching golden's graph.

## 4. Predicting the movers, and the scorer that convicts

`predict.py <workdir>` names, from PRISTINE databases ALONE, every test the law
can move: a COLUMN-0 `interface_inst` (our port-view anchor) with a param_assign
carrying `vpiOverriden:1`, or an op75 Rhs whose def-view counterpart is op75,
or a typespec-bearing constant Rhs whose def-view counterpart is a non-75
operation.  It is deliberately a SUPERSET — the dump does not say whether a
view is the exempt named-modport cell — and every ACTUAL mover must fall
inside it.

`pagree.sh <pristine-wd> <patched-wd> <name>...` is THE anti-regression scorer.

**`r11v1repro/agree.sh` must not be used for this law and this directory says
so out loud.**  Its census (`r11u1repro/ifcen.py`) renders an aggregate Rhs as
the bare word `operation` with no value, so a port view holding the wrong
struct value and one holding the right one produce the SAME census row.
Measured: `agree.sh <patched> <pristine> iface_array_elem_cfg_param` — the
POSITIVE CONTROL, which must read this pass's only u2r conversion back as a
loss — scores `LOST=0` and prints PASS.  It is blind, exactly as residue R1b
warned.  `pagree.sh` keys on the param_assign GRID instead and its positive
control names the cell:

    iface_array_elem_cfg_param/default   agree 4 -> 3   LOST 1
        LOST work@top.u.s  CFG  ovr=0  HAS-TS  operation@13:45-13:54 ... UINT:8

## 5. Files

| file | what it is |
|---|---|
| `g1/ g2/ g3/` | the golden-grid arms (one `dut.sv` each) |
| `run.sh` | build one arm's golden + our database, record every rc |
| `pagrid.py` | the param_assign grid reader (resolves uhdm-dump's elided repeats) |
| `tsprobe.py` | the Rhs `vpiTypespec`-presence reader |
| `predict.py` | a-priori mover prediction from pristine databases |
| `pagree.sh` | the anti-regression scorer + positive control |
| `oblind.sh` | order-blind attribution of one mover (the coin test) |
| `coin.sh` | re-run one test N times on ONE binary to prove nondeterminism |

## 6. Residues, ranked, with witnesses

**R0 — the exempt cell is narrower than `namedModportPortView9`.**  Golden
folds a NAMED MODPORT port view at the declaration default too when the
base-name lookup misses: when the actual is a re-passed PLAIN interface port
selected with `.mp` (`g2 a2.b1.q`, `mid(tif r)` + `.q(r.mp)` -> CFG DEF, W 4,
ovr 0) and when the actual lives outside the instantiating generate block
(`g2 g.a6.q` -> DEF, ovr 0).  A re-passed MODPORT port connected BARE keeps the
connected values (`g2 a3.b2.q` -> OVR, W 9, ovr 1), so "re-passed" alone is not
the distinguisher.  `actualOutOfScope16` (ModuleEmit.cpp, still computed and
still unread) already models the out-of-scope half; the re-pass half needs the
extra clause "the found actual is itself an InterfacePort AND the connection
expression selects a modport".  Feeding either into the PARAM_ASSIGN gate only
— never into `ifaceDefaultScope`, which is the RANGE gate — is the next step.

**R1 — the scalar VALUE half is untouched by this pass.**  On a
default-folding port view we still emit the CONNECTED instance's scalar values.
`g1` measures it exactly: after the patch `a0/a1/a3` read PI 9, NI -9, HX
8'h5A, RE 4 against golden's 3, -3, 8'hA5, 2.500000 (ST already matched at
"def", because our string-override capture is itself broken, which is why the
stamp clear alone converted that one cell).  Two sub-defects of our OWN
override capture surface on the HOME view in the same arm and are NOT port-view
bugs: a `real` override folds to a truncated `UINT` (`u_ov` RE = UINT:4 size 32
against golden REAL:4.500000 size 64 — ParamEmit.cpp's `cvo.isReal()` arm) and
a `string` override is dropped entirely (`u_ov` ST = "def" against golden
"ovr").  The fix is to emit the port view's parameters against
`ifacePortViewFoldScope(def, portView)` — note that scope is NOT always the
bare declaration default: it substitutes the RECEIVING module's same-named
parameters, which is what makes OneNetRange's `width` 16 and not 1.

**R2 — a NAMED aggregate member emits `tagged_pattern` where golden emits the
member expression, ON THE DEF VIEW.**  This is what still separates
GenIfIfaceParamStructField and GenForIfaceLocalparamNestedGen, and it is not a
port-view question at all: both moved strictly toward golden here (their head
advanced from the whole `param_assign` object to a node three levels inside the
Rhs) but their `work@bus_if` DEF view already carries the wrong shape, so
cloning it (face B) faithfully reproduces it.

    golden  operation:      line:6:37-6:46  vpiOpType:75  -> constant UINT:1
    ours    tagged_pattern: line:6:37-6:46  vpiPattern: operation opType 75
                                                        -> tagged_pattern ...

Source in both tests is `'{BUS: '{DAT: 32}}` / `'{HSK: '{DLY: 1}}` — a named
assignment-pattern member.  Fix the DEF view and both convert.

**R3 — `iface_param_2level` is a different law.**  Its head is in the CHILD
MODULE, not on any interface: `inner #(.SYS_DAT(s.CFG.BUS.DAT))` reaches
`logic [SYS_DAT-1:0] reg_data`, where golden folds the range bound to
`constant INT:31` and we keep the unfolded `operation` over
`hier_path (s.CFG.BUS.DAT)`.  Its interface param census is exact on both
sides, before and after this pass.  It was on this pass's candidate list and it
does not belong to the interface-parameter VALUE family.
