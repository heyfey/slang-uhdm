# r10earl71: the generate-scope HighConn DIRECT part-select bound

Implementer verdict: **ACCEPT** at base `ecdded75`.

This directory is the durable reproducer and measurement kit for the Earlgrey
head in both modes at `ecdded75`. The official `uhdm-cmp` is the judge; every
text tool here is a diagnostic. Everything below was measured in this pass,
not carried forward from law 70's write-up.

## R0 and the decoded law

The pristine binary has 46 comparison lines and one head in each mode
(`HEAD_BEFORE_default.cmp`, `HEAD_BEFORE_testflags.cmp`), at
`flash_phy_rd.sv:143:34-143:44`:

```systemverilog
.addr_i(addr_i[BankAddrW-1:LsbAddrBit])
                           ^^^^^^^^^^
```

in `top_earlgrey.u_flash_eflash.gen_flash_banks[0].i_core.i_rd.gen_bufs[0]
.i_rd_buf`. Golden keeps a located `ref_obj LsbAddrBit` whose `Actual_group`
is a fresh, **locless** `enum_const LsbAddrBit` (`UINT:1`, size 32). We emitted
a located `constant`, `UINT:1`, size 32, with a `ref_typespec` onto the package
`int_typespec`. `part_select::Compare` reaches `Right_range` through
`BaseClass::SafeCompare`, whose `VpiType` test fails first and names both sides
(RESUME §9's head-decode rule — read the MK line, not the shape).

`§ genScopeConnPsDirectBoundKeepsRef71` (src/ExprEmit.cpp) is the law. The
source-level mechanism, decoded from Surelog and then measured:

1. `CompileHelper::compilePartSelectRange`
   (`src/DesignCompile/CompileExpression.cpp:4240-4249`) compiles **both**
   ranges of a plain `paConstant_range` part_select with **`Reduce::No`**,
   whatever reduce the caller passed. The indexed-part-select base/width
   (`:4261-4270`) and the bit-select index are compiled with the caller's
   `reduce` — which is exactly why those fold in the same High_conn and a
   part-select bound does not.
2. Under `Reduce::No` the only substitution left is
   `CompileExpression.cpp:2861-2915`, which looks the name up in
   **`instance->getNetlist()->param_assigns()` of that instance alone** — no
   parent walk, unlike `ModuleInstance::getValue`
   (`src/Design/ModuleInstance.cpp:132-181`, which does climb). At an
   instantiation inside a generate scope the instance IS the gen scope, whose
   netlist carries only the block's own localparams; every outer name survives
   as a `ref_obj`.
3. `UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3951-3960`)
   then answers a name it can value with `mod->getValue(name)` and mints the
   locless `enum_const`; a module-scope name gets nothing and stays unbound.

`NetlistElaboration::high_conn_` recompiles the named actual at
`NetlistElaboration.cpp:1335-1337` (`Reduce::Yes`, `pexpr=nullptr`,
`instance=parent`) and the ordered actual at `:1090-1096`.

## Why the bound POSITION is not the axis (law 70's open question, answered)

Law 70 shipped only the subtraction-operand slice because a broad direct-bound
abstention scored 104/112 MOVED-WRONG on its own g1/g2 grids. Re-measured
here on golden, cell by cell, that refusal was about the **binding**, not the
abstention: golden keeps the ref for a direct bound too, but binds an
`enum_const` only for package symbols.

`d2_earl71.sv` crosses six symbol origins against twelve bound spellings in a
module-body, gen-for, gen-if and nested-gen home. In an ELAB port High_conn,
plain part-select bound:

| symbol origin | gen-scope home | module-body home |
|---|---|---|
| package parameter / package localparam | `ref_obj` -> locless `enum_const` | FOLDS |
| package ENUM MEMBER | `ref_obj` -> `enum_const` | `ref_obj` -> `enum_const` |
| module parameter / module localparam | `ref_obj`, **UNBOUND** | FOLDS |
| an OUTER gen block's localparam | `ref_obj`, **UNBOUND** | – |
| genvar | `ref_obj`, UNBOUND | – |
| the block's OWN localparam | **FOLDS** | – |

and it holds for the DIRECT bound and for an operand of `-`, `+`, `*`, `/`,
`^`, `&`, unary `+` and a parenthesised sub-expression alike — the operator is
not an axis either. The `+:`/`-:` base and width and the bit-select index fold
in every home, exactly as the `Reduce::No` reading predicts.

`d1_earl71.sv` (nine package-parameter RHS shapes x two homes x eight select
positions, 4128 golden cells) refutes the other candidate axis: a literal, a
cross-package read, `$clog2` of a literal, `$clog2` of a derived parameter
(Earlgrey's own `LsbAddrBit = $clog2(WidthMultiple)`), a quotient of two
cross-package parameters, a ternary and a subtraction all measure identically.
**The RHS shape does not decide whether the ref survives.** It decides only
what `lateBinding` can encode — see below.

## What this pass claims, and what it refuses

Shipped: the DIRECT bound of a plain part_select, package parameter or package
localparam, unqualified, nonnegative — plus law 70's subtraction operand
exactly as it landed. The module-scope / outer-gen-scope UNBOUND-ref class and
the own-localparam FOLD (which our emitter has inverted today) are ranked, not
claimed.

`§ pkgParamValueIsUnsigned71` is the second guard, and it is what keeps law
70's counterexample class from coming back. The minted `enum_const` copies the
value UHDM's `ExprEval::reduceExpr` stored on the parameter, and that reducer
types its constant **per operator**: `vpiSubOp`/`vpiMultOp`/`vpiDivOp`/
`vpiModOp` always `INT:`, `vpiAddOp` `UINT:` only when both operands are
themselves unsigned, shifts and bitwise AND/OR and `$clog2` always `UINT:`, a
comparison `INT:-1`, and bitwise XOR **no value at all** (golden leaves that
ref unbound). `d3_earl71.sv` measures all 25 shapes on golden; the encoder
this pass inherits writes `UINT:` for every nonnegative value, so the arm
claims only the shapes Surelog also stores unsigned and lets the rest keep the
pristine fold. `GRID_SCORE.txt` carries the table.

## Grids

`GRID_SCORE.txt` has the full counts. Plain view, every arm:

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG |
|---|---:|---:|---:|
| d1_earl71 | 112 | 0 | 0 |
| d2_earl71 | 96 | 0 | 0 |
| d3_earl71 | 240 | 0 | 0 |
| g1_earl70 | 104 | 0 | 0 |
| g2_earl70 | 112 | 0 | 0 |
| g3_enc70 | 88 | 0 | 0 |
| v1_axes70 | 80 | 0 | 0 |

Law 70's g1/g2/g3 and its verifier's v1_axes70 are **positive** controls for
this law, not negative ones: golden itself keeps the ref at their gen-scope
direct bounds, so they move, and every moved cell lands on golden. The
official `uhdm-cmp` agrees on all seven arms in BOTH views (no arm gets worse;
`GRID_SCORE.txt` lists the line counts).

The `--elabuhdm` census shows MOVED-WRONG exactly equal to TO-GOLDEN in every
arm. That is a census artifact and it is named as one: under `--elabuhdm` our
database carries the plain listing's copy AND the elaborated copy under one
census key (8 where golden has 4), the extra set being the weaklyReferenced
TAIL the judge cannot reach (RESUME §9), so the multiset join pads it against
`<none>`. The official judge improves in that view too.

## Corpus census and predicted movers

`CENSUS.txt`. Golden-vs-golden calibration first: 521401 cells in default and
799038 in testflags, all STILL-RIGHT.

| mode | cells | STILL-RIGHT | STILL-WRONG | TO-GOLDEN | away/wrong |
|---|---:|---:|---:|---:|---:|
| default | 531489 | 508238 | 23219 | 32 | 0 |
| testflags | 811229 | 770409 | 40756 | 64 | 0 |

`PREDICT_R0.txt`: the mover set was read from the PRISTINE databases before the
patched sweeps were scored — 0 of 1358 uhdm2rtlil databases carry a candidate,
and exactly two surelog databases do:
`default/Earlgrey_0_1-71da2fd7` and `testflags/Earlgrey_0_1-71da2fd7`.
Byte verification found exactly those, plus `default/Scoreboard-59431470`,
which is the known per-invocation coin (raw dump diff 92 lines, ORDER-BLIND
sorted diff 0 lines over 1099609 lines).

## Gates

`GATES.txt` records every number. In one line: both binaries built `-j 2` and
frozen `chmod 555`; 23/23 golden dumps pass and `/bin/false` gives 0/23; both
uhdm2rtlil sweeps and both surelog sweeps reproduce every committed row
byte-for-byte with identical status histograms (no conversion, `results/*.csv`
untouched); 0/1358 and 3/956 byte movers, all attributed; 52+8 canary rows
unchanged, both supplementary canary suites PASS, the canary audit reports
29 protected names, 0 uncovered, 0 fence breaches; all five protected pins
hold, including `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a`; and the
targeted head goes 46 -> 17 comparison lines, one head to one head, in both
modes with every other named row unchanged.

## Exhaustive boundary

Both drivers compare the frozen pristine and patched binaries twice — plain and
`--elabuhdm` serialization — over a COPY of `tools/probe` with no path filter,
`.sv` and `.v`.

| walk | processed | identical | differing | no output |
|---|---:|---:|---:|---:|
| every `.sv`/`.v` file | 3254 | 6220 | 14 | 274 |
| every unique directory | 1471 | 2691 | 10 | 241 |

The 14 file differences are the seven grid arms in both views and nothing else
(`BOUNDARY_WIDE.diff`). The 10 directory differences are `r10earl70repro`,
`r10earl71repro` and `r10vearl70repro` — the three directories that hold those
arms — plus `r10uvm75repro` and `r10uvm76repro`, both views. Those last four
are ONLY `design::Task_funcs` ordering: raw normalised diffs of 10–14 lines
over 9154–23569 dump lines, and **0 lines** once both dumps are sorted (the
`vpiTaskFunc` list order flip of RESUME §9). Every signal was symmetric
between the two arms — 20 `rc=139` entries in the file walk (ten pre-existing
elab segfaults, each on both binaries) and 10 in the directory walk — so there
is no new crash or timeout. The deliberately-moved grid arms are the walk's
own positive control that it can see.

## The next head (R0 for r10earl72)

Both modes now stop at the SAME single head, 17 lines, byte-identical modulo
object ids (`HEAD_AFTER_*.cmp`): a `RHS: <null>` SINGULAR miss, golden's

```
ref_typespec (work@top_earlgrey.u_flash_eflash.gen_flash_banks[0].i_core.i_rd)
  vpiParent -> constant 130:30-130:36     ("NumBuf" in {NumBuf{req_i}})
  vpiActual -> int_typespec 18:13-18:16   (flash_phy_pkg NumBuf's own int)
```

Our folded constant for that multi-concat repeat count carries no typespec at
all. It is PRE-EXISTING, not created here: `findobj71` locates the object in
the PRISTINE and the PATCHED database and reports `ts=NO_TS` in both, under
`constant <- operation <- operation <- operation <- cont_assign <-
module_inst(i_rd)` — a module-body cont_assign, which this law cannot reach.

## Reproduction

Build `tscen71.cpp` and `findobj71.cpp` against `~/.local/{include,lib64}`,
then:

- `earl71.sh <outdir> [default|testflags]` — the official Earlgrey comparison;
- `runarm71.sh <arm.sv> <dir>` + `armscore71.sh <dir> [o|oe]` — the golden grids
  (`gen_d1.py` regenerates `d1_earl71.sv`);
- `predict71.sh <sweep-workdir> <tscen71>` — the mover prediction;
- `tab71.sh` — the compact gen-scope bound table used in the tables above;
- `byteverify.sh`, `ct8rows.sh`, `rowheads.sh`, `canaries.sh`, `ctcan2.sh`,
  `canaudit.sh` — the sweep gates;
- `vwide71.sh` and `vdir71.sh` — the exhaustive boundary.

No integration, commit, main-tree edit, `results/` edit, stash, or fenced-test
dispatch belongs to this pass.
