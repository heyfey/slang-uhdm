# r10earl50 — § selectReadNeedsReduce50

**THE HEADLINE: r10earl49's residue R1 — "a SELECT of a parameter ANYWHERE in
the module is a read" — is REFUTED on NINE measured positions and REPLACED, and
the set it was supposed to be is not what earl49 said it was. Keyed on the
CELL instead of on (instance, kind, span), the Earlgrey golden-vs-ours
BARE/LOCATED disagreement set is 12 cells, not 77; 7 of them are R1, and all 7
move, plus an 8th in the standalone-top listing. Design-wide the disagreement
count goes 38 → 23 with ZERO cells entering. The 52-line head is NOT cleared:
it is R0, a cast fold, and three purpose-built arms REFUTE its three obvious
discriminators.**

Corpus movers: Earlgrey_0_1 (8 cells), Scr1SvTests (1 cell, both modes),
`ParameterInitializedByPartSelectOfParametersAssignedToVar` (1 cell, both
modes), `rp32_r5p_mouse` and `rp32_r5p_mouse_soc_simple_top` (3 cells, both
modes). **Every one is strictly toward golden and every one is named below.**
All 8 corpus sweeps: 0 differing CSV rows.

---

## R1, as earl49 left it

`paramNameIsRead` counted a select on a parameter's name ANYWHERE in the
enclosing module declaration's SYNTAX as a read, which gives the parameter's
elaborated `param_assign` Rhs constant Surelog's loc-less BARE typespec. The
brief named five witnesses (`b1.P4`, `b2.P4`, `c1.C6`, `d1.D3`, `e1.E7`) where
golden answers LOCATED and we answer BARE.

Sixty-two new cells, seven arms, one read position each, measured against real
Surelog, say the rule is wrong in nine distinct positions and right in four:

| position | golden | pristine | arm cells |
|---|---|---|---|
| select in a **PROCEDURAL** statement | LOCATED | BARE ✗ | h1.H4, h1.HC, h2.ID |
| select in an **UNTAKEN generate BODY** | LOCATED | BARE ✗ | h1.H7, h2.IE, h3.J6/J7/J9 |
| **PART-SELECT** operand of a cont-assign | LOCATED | BARE ✗ | h1.H2, h1.HA, c1.C6, e1.E7 |
| bit-select operand the **walk never reaches** | LOCATED | BARE ✗ | h1.H9, h1.HB, h4.K7 |
| bit-select whose **INDEX does not fold** | LOCATED | BARE ✗ | h3.J1, h3.J2 |
| select in a **NET-DECL initializer** | LOCATED | BARE ✗ | h2.I8, h2.I9, h4.K2 |
| select in a **ternary branch, net condition** | LOCATED | BARE ✗ | h2.I1, b1.P4, b2.P4 |
| select inside a **CALL** beside a net | LOCATED | BARE ✗ | h2.IB |
| **BARE NAME** cont-assign inside a gen scope | LOCATED | BARE ✗ | h3.JM, h3.J9 |
| select in a **GENERATE CONDITION** | BARE | BARE ✓ | h1.H6, h3.JA, h3.JB |
| select in a **NET-DECL ternary PREDICATE** | BARE | BARE ✓ | h4.K5, h3.J3 |
| select in a **NET's declared RANGE** | BARE | BARE ✓ | h5.L7 |
| select in an **INSTANCE override / port conn** | BARE | BARE ✓ | h1.HE, h1.HF, h2.I4 |

---

## THE LAW

> **§ selectReadNeedsReduce50.** A SELECT of a parameter's name reaches
> Surelog's `getValue`/`setRange` rewrite only where Surelog's reducer runs
> over it. Three carriers decide it, and each was separated by a PAIR of cells
> differing in exactly one thing:
>
> 1. **CONT-ASSIGN vs NET-DECL.** `h4.K1` `assign o = K1[0] | n1[0];` is
>    golden-BARE and `h4.K2` `wire t = K2[0] | n1[0];` — the same expression —
>    is golden-LOCATED. A net-declaration assignment resolves NOTHING except
>    its ternary PREDICATE (`h4.K5`, `h3.J3`, openmsp430 `bcsctl1_wr`).
> 2. **MODULE BODY vs GEN SCOPE.** A BARE NAME resolves in a module-body
>    cont-assign (`h4.K9`, `c1.C1`) and NOT in a gen_scope one (`h3.JK`,
>    `h3.JL`, `h3.JM` — all golden-LOCATED); a SELECT resolves in both
>    (`h1.H1`, `h1.H8`, `h4.K3`, `h4.K8`).
> 3. **TAKEN vs UNTAKEN.** An untaken branch's BODY resolves nothing at all
>    (`h1.H7`, `h2.IE`, `h3.J6/J7/J9`) while its CONDITION still does
>    (`h3.JA`).
>
> Inside a cont-assign, r10earl49's `§ caOperandScanRead49` operand walk still
> decides which operands are reached, with ONE addition that the pre-scan alone
> could not give: **an operand the pre-scan STEPPED OVER is then REDUCED, and
> `reduceExpr`'s bit-select arm (`UHDM/templates/ExprEval.cpp:4724`) reduces
> the INDEX first and only then resolves the base NAME**:
>
> ```cpp
>     uint64_t index_val = get_value(invalidValue, reduceExpr(index, ...));
>     if (invalidValue == false) { any *object = getObject(name, inst, ...); }
> ```
>
> so `h2.IA` `{31'b0, n1[IA[2:0]]}` is BARE (the index's own select resolves),
> `h1.H1` `H1[k] | n[k]` is BARE (the index folds, the base resolves), and
> `h3.J1` `{31'b0, J1[n1[2:0]]}` is LOCATED (the index does not fold, so the
> base is never reached). A PART-select operand never gets there — it stopped
> the walk.
>
> And an INSTANCE's parameter overrides and port connections are reduced too:
> a SELECT anywhere in the actual resolves (`h1.HE`, `h1.HF`, `h2.I4`, and
> Surelog's own `LargeHex` `#(.ReqDepth(DReqDepth[0+:4]))`), a BARE NAME does
> not (`h2.I3`, `h2.I5`, `c1.C9`).

Implementation: `collectSrlgReadNames` now fills a third map, `wide50` = `out`
minus five syntax contexts (cont-assign, generate BODY, instance connections,
procedural blocks, net/variable declarator initializers); `paramCaFoldRead`
walks the INSTANTIATED generate blocks and the instance connections from the
AST, carrying `genScope` (which suppresses the bare-name harvest) and the
bit-select reduce above. `narrow` — the RANGED-UNTYPED path — is untouched.

**The LargeHex counterexample that justified the old wide rule is not a
parameter-initializer read.** `parameter bit [75:0] DReqDepth` is also read as
`tlul_fifo_sync #(.ReqDepth(DReqDepth[0+:4]))`, and it is that INSTANCE
OVERRIDE that earns its bare typespec; `h1.H5` measures the
parameter-initializer position on its own and golden answers LOCATED.

---

## THE ARMS — 7 files, 62 cells, one read position each

| arm | what it separates |
|---|---|
| `h1_earl50.sv` | the 16 select positions: gen cond, untaken body, procedural, part-sel vs bit-sel operand, walk reached vs stopped, override, port conn |
| `h2_earl50.sv` | the instance-connection regime and the ternary predicate: `I1` (net branches, LOCATED) vs `I2` (bit-sel branches, BARE) is the pair that kills a blanket predicate rule |
| `h3_earl50.sv` | TAKEN vs UNTAKEN, and the gen-scope BARE-NAME cells `JK`/`JL`/`JM` |
| `h4_earl50.sv` | the three carriers, each isolated: `K1`/`K2` (CA vs net-decl), `K3`/`JK` (gen scope), `K5`/`K2` (the net-decl ternary exception) |
| `h5_earl50.sv` | the TRANSITIVE axis — a select inside ANOTHER parameter's initializer, in eight variants of what that other parameter is used for |
| `h6/h7/h8_earl50.sv` | R0, the 52-line head: the size-cast fold, in three cuts |

Plus the whole r10earl49 grid (`b1 b2 c1 d1 e1 f1 g1 a1` + `v1..v8`) re-run
with both binaries: **exactly the five brief-named cells moved, all to golden,
and `v7.M4x`/`v7.M5x` moved with them.** Every other cell of those 20 arms is
byte-unchanged.

---

## THE CENSUS — and earl49's 77-cell claim, REFUTED

`CENSUS_PREDICT50.txt` was written from the PRISTINE pair before the patched
Earlgrey run. Its instrument is `grid50.py`, keyed on the CELL
(`<instance>.<param>`), not on earl49's `(instance, typespec kind, span)`:

| | earl49's census49 | this pass's grid50 |
|---|---|---|
| golden-vs-ours disagreements | 77 lines | **12 cells** |
| of which R1 (ours BARE, golden LOCATED) | claimed "all" | **7** |
| ours LOCATED, golden BARE | — | 2 (residue R2) |
| cells ours emits and golden does not | — | 3 (residue R4) |

The prediction — the seven named cells and nothing else — landed EXACTLY on
the elaborated view. It **missed one**: `work@jtag_mux.TieOffValues` in the
STANDALONE-TOP listing, because the instrument was scoped to the last
`|uhdmtopModules:` block. It is the same law and the same direction
(`(jtag_en) ? TieOffValues[k] : in_padring_i[k]`, cell `b1.P4`), and it lands
ON golden's row. Whole-dump result:

| | pristine | patched |
|---|---|---|
| BARE/LOCATED cells | 12547 | 12546 |
| disagreements vs golden | **38** | **23** |
| cells that ENTERED the set | — | **0** |

The eight movers, each named, each strictly toward golden:

| cell | why golden says LOCATED |
|---|---|
| `u_aes.aes_prng.aes_prng_lfsr.CustomCoeffs` | `assign coeffs = CustomCoeffs[LfsrDw-1:0];` inside `if (CustomCoeffs > 0)` — an UNTAKEN branch (prim_lfsr.sv:305/330) |
| `u_alert_handler.i_ping_timer.i_prim_lfsr.CustomCoeffs` | the same |
| `u_dm_top.i_dm_mem.{Data,ProgBuf,AbstractCmd,Flags}BaseAddr` | read only by a select in an `always_comb`/`case` (dm_mem.sv:290-313) |
| `u_usbdev.usbdev_impl.u_usb_fs_nb_pe.u_usb_fs_rx.DJ` | `dpair = DJ[1:0];`, procedural (usb_fs_rx.sv:83) |
| `work@jtag_mux.TieOffValues` | `(jtag_en) ? TieOffValues[k] : in_padring_i[k]` — the net condition stops the walk |

`shapes50.sh` confirms the multiset: **8 bare loc-less `logic_typespec`s
removed, 8 span-bearing ones added**, at spans 41:13 (×2), 64/66/68/72:14,
74:14 and 11:13 — the eight cells and nothing else.

---

## R0 — the 52-line head, SCORED and its three obvious discriminators REFUTED

The head is `sram2tlul.sv:42`

```systemverilog
assign tl_o.a_size = top_pkg::TL_SZW'(SRAM_DWB);   // SRAM_DWB a localparam
```

```
LHS(golden): operation, vpiOpType:67, vpiTypespec -> int_typespec,
             vpiOperand -> ref_obj (work@sram2tlul.SRAM_DWB)
RHS(ours)  : constant UINT:2
```

Golden keeps the size cast UNFOLDED and we fold it. That is a **cast-fold**
law, not a typespec-linkage law: nothing in § selectReadNeedsReduce50 touches
it, and the head is unchanged at 52 lines / 1 head. Three arms narrow it for
earl51, and all three REFUTE a candidate discriminator:

| arm | cut | result |
|---|---|---|
| `h6_earl50.sv` | six plain size-cast cont-assigns (package param size, local param size, literal size, cast as an operand, literal operand, net operand) | **DUMP_MATCH** — golden and ours agree on all six. The cast SHAPE is not it. |
| `h7_earl50.sv` | the same with the LHS a packed-struct MEMBER (`tl_o.a_size`) | PASS_CMP; golden emits the elaborated cont-assign's BODY where we emit only the list reference. The struct-member LHS is not it. |
| `h8_earl50.sv` | h7 INSTANTIATED with parameter overrides, as in top_earlgrey | PASS_CMP; golden has TWO `vpiOpType:67` operations (def + elaborated instance) and ours has ONE — but ours omits that elaborated cont-assign's body entirely rather than folding it. The instantiation is not it either. |

So for earl51: the head's family is **"the elaborated instance's cont-assign
Rhs size cast"**, we produce a FOLDED CONSTANT there and golden an unfolded
`vpiOpType:67` operation, and the discriminator is NOT the cast shape, NOT the
struct-member LHS and NOT the instantiation. What is left to try is the
compilation context (`+define+SYNTHESIS`, `--single-unit`, the `.scr`
filelist) and UHDM's `m_skipOperationTypes`
(`UhdmAdjuster.cpp:334` — `{vpiAssignmentPatternOp, vpiMultiAssignmentPatternOp,
vpiConcatOp, vpiMultiConcatOp, vpiBitNegOp}`, which notably does NOT list
`vpiCastOp`).

---

## RESIDUES

| id | what | witnesses | direction | changed by this pass? |
|---|---|---|---|---|
| **R2** | a BARE-NAME **port connection** is golden-BARE and we say LOCATED | `h2.I6` `.q(I6)`, `h3.JN`; Earlgrey `u_usbdev.AVFifoWidth`, `u_memory_2p.LocalDataBitsPerMask` | ours LOCATED / golden BARE | no — identical before and after |
| **R3** | a whole-RHS `ctx.tryEval` fold harvests EVERY name, including one under a PART-SELECT the reducer's walk would have stopped at | `h2.IC` `(IC[3:0] \| 32'h0) & 32'h1` | ours BARE / golden LOCATED | no |
| **R4** | three Earlgrey cells ours emits and golden does not (a typespec-PRESENCE family) | `u_flash_ctrl.u_flash_erase_ctrl.{Bank,Page}AddrMask`, `u_pwrmgr.i_cdc.i_ast_sync.ResetValue` | — | no |
| **R5** | a select in ANOTHER PARAMETER's INITIALIZER measures golden-LOCATED in EIGHT variants (`h5.L1..L8`, `h1.H5`) — yet the `BlackParrotComplex` canary needs the BARE answer | `h5` + `BlackParrotComplex` | ours BARE / golden LOCATED on the arm, ours BARE / golden BARE on the canary | **deliberately kept unchanged** — see README.verifier.md V1 |
| **R6** | `v3.S9` (multi-dim packed param) has no cell in ours at all; `v7.M1` (cast operand) takes the classifier's conservative Stop | earl49's own | — | no |

---

## Files

| file | what it is |
|---|---|
| `h1..h5_earl50.sv` | the 62-cell select-position grid |
| `h6..h8_earl50.sv` | the R0 cast-fold scoring arms |
| `{a1,b1,b2,c1,d1,e1,f1,g1}_earl49.sv`, `v1..v8_v49.sv` | r10earl49's grid, re-run as boundary arms |
| `grid50.py` | per-CELL BARE/LOCATED reader (the census instrument) |
| `census50.py` | earl49's span-keyed census, carried forward |
| `CENSUS_PREDICT50.txt` | the prediction, written before the patched run |
| `earl50.sh` `arm50.sh` `sweeps50.sh` `byteverify50.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `bndarms50.sh` `msdist.sh` `shapes50.sh` `vsweep.sh` `varm.sh` `vbnd.sh` | the gate harness, carried forward |

## Reproduce

```sh
git worktree add /tmp/wt_r10earl50 113a511
cmake -S /tmp/wt_r10earl50 -B /tmp/wt_r10earl50/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build /tmp/wt_r10earl50/build -j 2
cd /tmp/wt_r10earl50/tools/probe/r10earl50repro
for a in h1 h2 h3 h4 h5; do
  SLANG_UHDM=/tmp/wt_r10earl50/build/slang-uhdm ./arm50.sh ${a}_earl50.sv /tmp/arm_$a
  paste <(python3 grid50.py /tmp/arm_$a/g.dump) <(python3 grid50.py /tmp/arm_$a/o.dump)
done
SLANG_UHDM=/tmp/wt_r10earl50/build/slang-uhdm ./earl50.sh /tmp/r10earl50_wd
python3 grid50.py /tmp/r10earl50_wd/o.dump --all
```
