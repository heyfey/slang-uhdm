# r10earl65 — § connIpsPkgParamBoundNoTs65

**BASE 903bbea.  Earlgrey_0_1, BOTH modes.  The head earl64 named as R0 is
CLEARED; the new head is in `PREDICT_R0.txt`.**

Pristine binary md5 `7726630ba6667945be188d5ed47ee259`,
patched binary md5 `66e1e8bb63d8f8f8db9f40fe954c5f0b`.
Golden caches (immutable, read-only): `00d4794526e44dc553f3` (default),
`d7348d2d2fe67abe767b` (testflags).

---

## 1. The head, decoded before any code

```
LHS: <null>
RHS: ref_typespec (work@top_earlgrey.u_flash_eflash.gen_flash_banks[0]) id:255925
     |vpiParent -> constant id:255924  line:133:38 endln:133:47
     |vpiActual -> int_typespec id:763  line:19:14 endln:19:17
```

`expr::Compare` (UHDM/build/generated/src/expr.cpp) runs the **singular**
`SafeCompare(lhs->Typespec(), rhs->Typespec(), context)`; BaseClass.h:194's
`(lhs == nullptr) && (rhs != nullptr)` arm sets **only** `m_failedRhs`.  So
`LHS: <null>` + a full RHS means **we carry a typespec where golden carries
none** — a TYPESPEC-PRESENCE head, not a value head.  All four constant fields
(`ct 9`, `sz 32`, `UINT:16`, decompile `16`) agree on both sides.

The owner is the **`Width_expr` of the `indexed_part_select` inside the
ELABORATED port `High_conn`** of

```systemverilog
// flash_phy.sv:133, inside `for (genvar bank …) begin : gen_flash_banks`
.addr_i(flash_ctrl_i.addr[0 +: BankAddrW]),
// flash_ctrl_pkg.sv:19  localparam int BankAddrW = PageW + WordW;   // = 16
```

Confirmed by direct-reader census, never by a whole-dump diff (Earlgrey's
uhdm-dump is >1 GB — earl61-64's rule): `tscen65` walks the DEF listing and the
ELAB instance tree and prints one keyed line per leaf of every cont_assign,
port High_conn and param_assign, with the constant's typespec **presence, kind
and span** in the payload.  Golden's DEF view has **no** High_conn rows at all
for these ports, so the head is an ELAB-only object on both sides.

## 2. The census: 9 ours-only, 95 golden-only, and the discriminator

Whole-design multiset join, keyed `(sec, owner-instance, site, positional
route, line:col)` — the span's FILE part is normalised away because our objects
carry an empty `VpiFile` (RESUME §9).  Both modes, pristine binary:

```
TS-ONLY differing cells (every other compare-visible constant field EQUAL):
   G_ts=int_typespec   O_ts=-              : 95
   G_ts=-              O_ts=int_typespec   :  9
   G_ts=int_typespec   O_ts=logic_typespec :  1
```

The **9** are all ELAB port-High_conn indexed-part-select bounds whose value is
a folded **PACKAGE** localparam:

| site | role | source | value |
|---|---|---|---|
| `u_flash_ctrl.u_flash_prog_ctrl` `HC_op_addr_i` | `/hp[2]/w` | `AddrW` | UINT:17 |
| `u_flash_ctrl.u_flash_rd_ctrl` `HC_op_addr_i` | `/hp[2]/w` | `AddrW` | UINT:17 |
| `u_flash_ctrl.u_flash_erase_ctrl` `HC_op_addr_i` | `/hp[2]/w` | `AddrW` | UINT:17 |
| `u_flash_eflash.gen_flash_banks[0].i_core` `HC_addr_i` | `/hp[1]/w` | `BankAddrW` | UINT:16 |
| `u_flash_eflash.gen_flash_banks[1].i_core` `HC_addr_i` | `/hp[1]/w` | `BankAddrW` | UINT:16 |
| `u_flash_ctrl.u_flash_mp` `HC_req_addr_i` | `/b` | `WordW` | UINT:8 |
| `u_flash_ctrl.u_flash_mp` `HC_req_addr_i` | `/w` | `AllPagesW` | UINT:9 |
| `u_flash_ctrl.u_flash_mp` `HC_req_bk_i` | `/b` | `BankAddrW` | UINT:16 |
| `u_flash_ctrl.u_flash_mp` `HC_req_bk_i` | `/w` | `BankW` | UINT:1 |

The **95** are the MIRROR family and this pass does NOT take them (R1 in
`PREDICT_R0.txt`): 87 `STIDW` cells in ELAB cont_assign ips widths, 6
`N_TIMERS` cells in ELAB High_conn ips widths, 2 `NumBuf` operands, 1
param_assign.  They are a DIFFERENT OBJECT — golden's typespec there is a
**bare** `int_typespec` with **no span, no name, no ranges, `VpiSigned(1)`**,
while the typespec this pass removes is the parameter's **located declaration**
typespec (`flash_ctrl_pkg.sv:19:14-19:17`).  Two different Surelog mints; only
one law each.

### The discriminator, measured on GOLDEN

`tsdet65` dumps every judge-visible typespec field for the constants at a given
span.  Golden, ELAB port `High_conn`:

| origin of the folded read | ips WIDTH | ips BASE | bit-select INDEX | part-select BOUNDS |
|---|---|---|---|---|
| **package** localparam | none | none | none (§ elabConnSelFoldNoTs21) | **located declaration ts** |
| **module-body** localparam | bare signed int_typespec | bare | bare | located |
| **port** parameter | bare (or none when the override is untyped) | — | — | — |
| literal / genvar / loop var | none | none | none | none |

and in an ELAB **cont_assign** every one of those origins carries the **located
declaration typespec** (`flash_phy.sv:65` `BankAddrW`/`BankW`, `ibex_core.sv:928`
`PMP_D`, `prim_ram_2p_async_adv.sv:225` `Width` — 18/2/4/3 cells respectively,
all located).  So the split is **position × view**, not origin alone, and the
part-select bound is the NEGATIVE CONTROL that keeps the old behaviour.

### Where it comes from in Surelog (decoded, not guessed)

`NetlistElaboration::high_conn_` (src/DesignCompile/NetlistElaboration.cpp:854)
compiles a port-connection actual with

```cpp
m_helper.compileExpression(parent_comp, fC, node, m_compileDesign,
                           Reduce::Yes, /*pexpr=*/nullptr, /*instance=*/parent);
```

i.e. it **re-compiles the actual in the parent INSTANCE's context** instead of
cloning the DEF-view expression.  In that path a parameter read is minted from
its `Value` (`CompileExpression.cpp` ~3005: `MakeConstant` + `VpiValue`/
`VpiDecompile`/`VpiConstType`/`VpiSize`, and a typespec **only** under
`sval->isSigned()`, which yields exactly the bare `VpiSigned(1)` int_typespec
the mirror family shows).  The DEF-view fold's located declaration typespec is
simply not reproduced — which is what the 9 cells are.

## 3. The law and the code

> **§ connIpsPkgParamBoundNoTs65** — inside an ELABORATED port `High_conn`, a
> PACKAGE-parameter fold that lands in an `indexed_part_select` **bound**
> (`Base_expr` or `Width_expr`) carries **NO** typespec.  A fold in a
> `part_select` bound in the same position keeps the parameter's own
> declaration typespec, unchanged.

This is the indexed-part-select twin of the landed **§ elabConnSelFoldNoTs21**
(`selFoldTs21 = selFold9 && !elabConnEmit21`, the bit-select INDEX half), and it
reuses that pass's marker verbatim.  Three gates in `src/ExprEmit.cpp`, all of
the form `&& !elabConnEmit21`:

1. `ipsWidFold9` (~8467) — the plain `d[0 +: P]` arm, both bounds.
2. the hier-path `stampFoldedPkgParamTs(wc9, …)` at the `§ elabHierSelWidthFold`
   width mint (~17755) — the dotted `st.f[0 +: P]` arm, which is the HEAD's own
   shape.
3. the same mint in the base-select spelling (~18057).

Nothing else changes: `§ psBoundPkgParamTs31`, `§ caPartSelBoundFoldTs`,
`§ caOpFoldTs`, `§ refModConnOpFoldTs`, `§ elabCaPortParamPaCopy64`,
`§ connIpsBareBaseUint64` and every DEF-view arm are untouched.

## 4. Arms (the grid), scored against golden

`g1_conn65.sv` — package localparam / module-body localparam / port parameter ×
ips WIDTH / ips BASE / bit-select index / part-select bounds / bare actual /
operation operand, in the module body, a gen-for and a gen-if, plus the
cont_assign homes.
`g2_hier65.sv` — the DOTTED (hier_path) spelling of the same cells, which is the
head's own emission path.

`score65.py` 3-way multiset join (golden / pristine / patched), payload reduced
to the fields the judge reads:

```
ARM 1  cells 250  STILL-RIGHT 232  TO-GOLDEN 2  STILL-WRONG 16  AWAY 0
ARM 2  cells  59  STILL-RIGHT  56  TO-GOLDEN 2  STILL-WRONG  1  AWAY 0
```

The four TO-GOLDEN cells are exactly `u_pkg_w HC/w`, `u_pkg_b HC/b`,
`u_h_w HC/hp[1]/w`, `u_h_b HC/hp[1]/b`; the part-select arms
(`u_pkg_ps`, `u_loc_ps`, `u_h_ps`) are STILL-RIGHT — the negative control held.
With a SPAN-carrying payload arm 1 scores one cell `MOVED-WRONG`: that is the
judge-invisible column residue recorded as R3 in `PREDICT_R0.txt`, and it is
earl60's attrv60.py lesson seen again — a span in the payload lies about a cell
that is right on every field `Compare` reads.

## 5. Gates (all run in this worktree, both binaries frozen at 555)

| gate | result |
|---|---|
| build both, md5 | `7726630b…` pristine / `66e1e8bb…` patched |
| `tests/check_goldens.sh` | **PASS 23 / FAIL 0** |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| u2r default | 679 / 50 / 2 |
| `ct8rows` u2r tf vs **committed** `results/gate_uhdm2rtlil.csv` | **PASS, 0 differing rows** |
| `ct8rows` u2r tf/def vs this pass's own pristine sweep | **PASS, 0 differing rows** |
| `byteverify SELFCHECK=1` u2r (1358 DBs) | **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| surelog `--mode both` (1588 rows) | see §5b |
| Earlgrey both modes | head CLEARED, 1 head each, AFTER logs byte-identical |
| whole-design census, both modes | **9 cells TO-GOLDEN, 0 AWAY**, and those 9 are the ONLY cells that changed |
| WIDE boundary (2,893 .sv, PROCESSED == LISTED, both views, both binaries) | only this pass's 2 arms differ |
| per-DIRECTORY boundary (1,355 dirs, both views) | only this pass's arm dir differs; `r10uvm75repro`/`r10uvm76repro` are the KNOWN order coin — proven, §6 |

`cmds.txt` audited by BINARY PATH in every arm
(`slang: /tmp/r10earl65_pristine.bin …` / `…_patched.bin …`), `SLANG_UHDM`
exported explicitly per binary, `GOLDEN_DEFER` unset, `results/*.csv` never
written.

## 6. The two boundary "movers" that are not movers

`r10uvm75repro` and `r10uvm76repro` differ between the two binaries in the
per-directory arm — and differ between two runs of the **same** binary:

```
pristine run 1  30b791020f3c75b82da2e04323ae6613
pristine run 2  e7d78631c7d243650c799847fbb3fdb2
pristine run 3  ecc0a9e596f20ed4f464a7241b16306f
```

and the A-vs-B diff is **order-blind ZERO** on all four (dir, view) cells.  It
is the documented `vpiTaskFunc` list-order coin (RESUME §9), not this pass.
The 8 `rc=139` signals the wide boundary raised appear on **both** binaries,
paired one-for-one — pre-existing, not introduced.

## 7. Instruments (measurement only; the official `uhdm-cmp` is the judge)

* `tscen65.cpp` — whole-design typespec-presence census (direct `.uhdm` reader,
  never uhdm-dump), positional route key, payload = constant fields + typespec
  presence/kind/span/name.  Extends `r10earl64repro/excen64.cpp`.
* `cen65.sh` — normalises the span FILE part so golden and ours join.
* `tsdet65.cpp` — every judge-visible typespec field for the constants at a
  span (kind, `VpiSigned`, ranges, `Typedef_alias`, name, span, parent kind).
* `score65.py` — 3-way multiset join, TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
  STILL-RIGHT / STILL-WRONG (from `r10earl64repro/score64.py`).
* `vwide65.sh` / `vdir65.sh` — the recursive and per-directory boundaries
  (from `r10v64repro`); list on fd 3, children `</dev/null`, PROCESSED asserted.
* `earl65.sh` — one Earlgrey run, one binary, md5 printed, golden from cache.
* `armscore65.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `ct8rows.sh`,
  `byteverify.sh`, `rowheads.sh` — the standard battery.
