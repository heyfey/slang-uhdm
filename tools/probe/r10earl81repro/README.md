# r10earl81 — § connBitSelIdxModParamFold81

**THE EARLGREY HEAD CLEARED IN BOTH MODES** (default 32 cmp lines → a new head,
testflags 36 → the SAME new head; the def/tf asymmetry is GONE).
BASE 9ac2763, branch `auto5h`, worktree `/tmp/wt_r10earl81`.
`results/*.csv` was **READ ONLY** and is untouched — **NO ROW WAS CONVERTED**
(`Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes; its head is cleared, the
design has more — see `PREDICT_R0.txt`).

## 1. The law

**Golden folds the INDEX of a `bit_select` that sits in an ELABORATED port
`High_conn` and names a MODULE-SCOPE parameter, to that instance's stored
`Value` — which is *not* the parameter's own `param_assign` constant when the
parameter was overridden at the instantiation. We kept the `ref_obj`.**

The head, `tlul_socket_1n.sv:215:25-215:26`, the `N` of

```systemverilog
tlul_err_resp err_resp (.clk_i, .rst_ni,
                        .tl_h_i (tl_u_o[N]),
                        .tl_h_o (tl_u_i[N]));
```

in `top_earlgrey.u_spi_device.u_reg.u_socket` (`parameter int unsigned N = 4` at
`tlul_socket_1n.sv:40`, overridden `.N(2)` at `spi_device_reg_top.sv:65`):

| | LHS (golden) | RHS (ours, pristine) |
|---|---|---|
| kind | `constant` | `ref_obj` |
| | `vpiDecompile:2` | `vpiName:N` |
| | `vpiSize:64` | `vpiFullName:…u_socket.N` |
| | `UINT:2` | `vpiActual: parameter …u_socket.N` |
| | `vpiConstType:9` | *(the `vpiActual` on the **testflags** copy only — 4 lines, and the whole 32-vs-36 asymmetry)* |

**Which arm — read the MK line, not the shape.** `bit_select::Compare`
(`UHDM/build/generated/src/bit_select.cpp:95-110`) reads `VpiConstantSelect`
first and then `SafeCompare(lhs->VpiIndex(), rhs->VpiIndex())`. Both operands
are non-null with different `UhdmType`, so `BaseClass.h:188`'s two-non-null arm
names both sides and the head is a **KIND mismatch inside `BaseClass::Compare`'s
`VpiType` line**, before any per-kind field of either side is read.

## 2. Decoded from Surelog, not guessed

1. `NetlistElaboration::high_conn_` recompiles the named actual **in the parent
   instance with `Reduce::Yes`** (`NetlistElaboration.cpp:1332-1337`; the
   ordered form at `:1088-1096`), and
   `CompileHelper::compileSelectExpression` (`CompileExpression.cpp:1258-1340`)
   compiles a bit-select **index** with the caller's `reduce`. That is exactly
   why the index folds here while a part-select **bound** does not:
   `compilePartSelectRange` hardcodes `Reduce::No` — the fact
   **§ genScopeConnPsDirectBoundKeepsRef71** rests on, and this pass leaves that
   population untouched (0 moved).
2. Under `Reduce::Yes` the identifier arm answers from the instance's stored
   `Value` (`CompileExpression.cpp:962-982`): `sval = instance->getValue(name)`,
   then `VpiValue`/`setRange`/`VpiDecompile`/`VpiConstType`/`VpiSize` from
   `sval`, and **no typespec** is attached — the position × view split
   § connIpsPkgParamBoundNoTs65 / § elabConnSelFoldNoTs21 already carry.
3. **Where that `Value` comes from is the whole encoding law, and it splits on
   OVERRIDDEN vs NOT** — § ovHopOverriddenKeepsValue80's law at a new consumer:
   * **Overridden** at this instantiation: `DesignElaboration::collectParams_`
     (`DesignElaboration.cpp:2147-2172`) compiles the actual in the parent
     instance and stores `fromVpiValue(c->VpiValue(), c->VpiSize())` — **no
     `adjustSize` anywhere on that path**, so the Value keeps the actual's own
     encoding *and its own width*. A bare decimal actual is Surelog's unsized
     **64**.
   * **Not overridden**: the default is compiled and `adjustSize(ts, …)` runs
     **before** the capture (`DesignElaboration.cpp:2519-2534`), so the stored
     Value already carries the declared type's width — **32** for `int`.

   Golden's own `param_assign` for that very `N` in that very instance is
   `UINT:2 size 32`, so **a plain copy of the param_assign would be a new wrong
   answer at exactly the head.** The fold reads the *instantiation's actual*.

## 3. The fences, each a measured negative control

| | fence | measured |
|---|---|---|
| (a) | `elabConnEmit21` — the **DEF listing keeps the ref** | golden's own `ref_module(err_resp)` listing has `ref_obj N` in the same two ports (4 row-instances) and so do we; 0 moved |
| (b) | the index must have **survived as a `ref_obj`** | every index some earlier law folds (a genvar, a package parameter, a gen-scope localparam, an operation) reaches this code already a constant, so the call site *cannot* move a cell that already agrees |
| (c) | **not a package symbol** | those fold on § selFold9's path at their own measured width (32) |
| (d) | **user-call argument depth** (`callArgDepth - sysCallArgDepth22`) | **convicted by golden**: in a user call's argument golden ITSELF keeps the `ref_obj` (`uFa`), so folding there would be a MOVED-WRONG; a *system* call's argument does fold (`uFb`) |
| (e) | nonnegative, known, integer | an `x`/`z`-bearing or negative value has an encoding this model does not name |
| (f) | **every producer but one abstains** | shipped: a parameter overridden with a **bare decimal integer literal**, Value `fromVpiValue("UINT:<v>", 64)`. Refused and left pristine: based actuals (`4'h6`→HEX sz4, `8'd6`→INT sz8, `8'o7`→UINT sz8, `4'b0110`→BIN sz4), expression actuals (width is the *reducer's*: `1+1`→sz64 but a derived localparam→sz32), and non-overridden parameters/localparams (golden sz 32, and a `ref_typespec` on exactly the signed-`int_typespec` sub-case) |

The full 25-cell table is `GRID_G2.txt`. **Six cells fold, all six land on
golden exactly; nineteen are refused and not one moved.**

## 4. Corpus-wide

The target shape exists in **exactly two** of 2,314 pristine databases
(`Earlgrey_0_1` default and testflags) and **zero** uhdm2rtlil ones. Outside
Earlgrey the 640 port-High_conn ref_obj indices name a **genvar or a variable**,
never a parameter — and all sit under a DEF-listing chain, refused twice over.
See `CENSUS.txt`.

**The per-instance proof:** the 16 Earlgrey keys are 8 socket instances × 2
ports carrying **eight different override values** — 2, 2, 2, 3, 4, 8, 12, 13 —
each landing on golden exactly. A hardcode or a shared-Value bug could not
produce that.

## 4a. How this sits against the two neighbouring landed laws

**§ genLpBitSelIdxOneHopFold67 (r10earl67) independently corroborates the
"no typespec" half of this decode.** That pass folds a *gen-scope localparam*
read in a bit_select index inside an ELABORATED **gen-scope cont_assign**, and
its **fence (1)** exists precisely because the **port `High_conn`** face behaves
differently: it measured golden's `.o(idx_tree[Pa])` High_conn index as
`constant … ` **"with no typespec at all"**, while the cont_assign twin two
lines away carries the located `int_typespec`. `expr::Compare` walks
`Typespec()`, so folding the High_conn face *with* a typespec would mint a new
head. This pass folds exactly that High_conn face and attaches **no typespec** —
the same value earl67 measured from the other side of the fence.

**earl67's own residue R3 is left standing, by construction.** Its "19 remaining
ELAB High_conn cells" are *gen-scope localparam* reads; a localparam is never
`isOverriddenParam`, so fence (f) refuses every one of them. Measured, not
argued: g1's `uGa` (a gen-block `localparam GL = gi + 1` read as a High_conn
index) did **not** move, and `r10earl67repro` / `r10v67repro` are **byte-identical**
between the two binaries in both views in the per-directory boundary walk.

**§ genScopeConnPsDirectBoundKeepsRef71's KEEPS-REF face is untouched**, and the
Surelog decode says why it must be: `compilePartSelectRange` hardcodes
`Reduce::No`, so a part-select **bound** never reaches the `getValue`
substitution that a bit-select **index** does. Measured: 0 moved on every
part-select LEFT/RIGHT and indexed-part-select BASE/WIDTH slot in g1, and
`r10earl71repro` is byte-identical in both views.

Every one of the 26 precedent repro directories named in this campaign's ops
rules — earl60/61/63/64/65/66/67/68/69/71/72/73/74/79/80, their verifier twins,
rgg14/16/18 and buvm30 — is **byte-identical** between the two binaries in both
views. See `BOUNDARY_NOTES.txt`.

## 5. Scores — MOVED-WRONG 0 / AWAY 0 everywhere

| population | TO-GOLDEN | AWAY | MOVED-WRONG |
|---|---|---|---|
| Earlgrey default, port High_conn | 32 | 0 | 0 |
| Earlgrey testflags, port High_conn | 48 | 0 | 0 |
| Earlgrey default, **whole database** | 32 | 0 | 0 |
| Earlgrey testflags, **whole database** | 48 | 0 | 0 |
| `g1_conn81.sv` plain / elab | 24 / 36 | 0 | 0 |
| `g2_enc81.sv` plain / elab | 24 / 36 | 0 | 0 |
| `g3_norm81.sv` plain / elab | 4 / 6 | 0 | 0 |

The family is **CLOSED**: remaining target-shape cells 0 in both modes
(pristine 32 in both).

`R10E81_OFF=1` (the kill switch) makes the patched binary's censuses
**byte-identical** to pristine on all three arms in both views — the delta is exactly
this law and nothing else.

### A census-instrument note, stated because it looks like a regression and is not
Patched testflags carries **16 more** `bit_select` census rows than pristine.
That is the listener's **pointer dedup**, not new objects: a `ref_obj` shared
across two of three sites is visited once, three freshly-made constants are
visited three times. The control settles it — `uH` (a plain **literal** index
this law never touches) and `uD` (a package parameter folded by § selFold9) are
golden 2 / ours **3** in *both* pristine and patched. The patch moves the target
cells into the same multiplicity every already-folded constant index in our
elaborated view already had, and in Earlgrey the patched per-key multiset
matches golden **exactly** (3 constants per key, golden 3).

## 6. Instruments

| file | what it is |
|---|---|
| `selcen81.cpp` | select-slot census, reads `.uhdm` **directly** (Earlgrey's uhdm-dump is >1 GB and was never produced) |
| `score81.py` | 2-way and 3-way **multiset** scorer; key carries **no span** |
| `fencescan81.sh` + `hcfam81.py` | corpus-wide target-shape scan, golden from each test's **own** `cmds.txt` |
| `oursshape81.sh` | the **shape the gate could fire on**, golden-agreeing cells included |
| `arm81.sh` | one arm: Surelog golden + both frozen binaries + the `R10E81_OFF=1` neutral, both views |
| `attr81.sh` | attributes a boundary mover: same-binary repeat + law-disabled run |
| `g1_conn81.sv` | referent × slot × home grid + body-position twins, 3 instances |
| `g3_norm81.sv` | the digit-normalisation edge: a leading-zero and an underscored decimal actual, both measured against golden |
| `g2_enc81.sv` | the 25-cell encoding grid and the call-arg fences |
| `vwide81.sh` / `vdir81.sh` | the two boundary walks (fd 3, `</dev/null`, PROCESSED asserted) |
| `byteverify.sh` | mover detection with `SELFCHECK=1` |
| `ct8rows.sh` | whole-row CSV gate against the committed baselines |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its self-audit |

Every scanner **reads databases and dispatches nothing**. The four slang-fenced
tests are never dispatched and appear in `FENCED=` lists only — `canaudit.sh`
asserts `FENCE-BREACH=0`.
