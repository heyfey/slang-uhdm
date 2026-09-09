# r11u5 — the IBEX family: re-measured, clustered, decoded. NO LAW LANDED.

Everything here is MEASUREMENT-ONLY; the judge is `uhdm-cmp` through
`scripts/verify_golden.py`. Base commit `ec81cb73`, pristine binary md5
`2f28c372da15bec082e100bd0dfdea51` (byte-identical to the main tree).

**This pass converts NOTHING and changes no production file.** It exists
because the 14 ibex rows were first-contact (new in uhdm2rtlil v0.68) and had
never been clustered. The clustering below, and the negative result in §4, are
the deliverable: the next pass should start from §5, not from scratch.

## 1. The target, verified

`results/golden_uhdm2rtlil.csv` carries 14 ibex rows CMP_NOTEQUAL, and the
`default` and `testflags` sets are IDENTICAL (both 14, same names). Re-measured
on my own pristine build: `CMP_NOTEQUAL: 14, SLANG_REJECT: 12, CMP_EQUAL: 2`
over 28 discovered tests — the baseline reproduces exactly.

`results/*.csv` ARE NOT EDITED BY THIS PASS. No row converts, so there is
nothing to promote.

## 2. THREE clusters, not one (`HEADS.txt`)

Every row wears exactly ONE head (`grep -c '^LHS:'` = 1). The cmp-line counts
cluster tightly — 46×9, 36×3, 64, 34 — and the head objects split the family
three ways:

| cluster | rows | head object | golden vs ours |
|---|---|---|---|
| **A** | **9** | `ref_obj (…RndCnstLfsrPermDefault::lfsr_perm_t::LfsrWidth)` @ ibex_pkg.sv 721:40 | golden keeps a `ref_obj`; we emit `constant UINT:32` |
| **B** | 4 | `constant` @ 33:10 (`$error` arg, prim_assert.sv) | golden `"IbexCSREnValid"` size 112; ours `"         IbexCSREnValid"` size 184 |
| **C** | 1 | `ref_obj (PMP_ADDR_MSB)` @ ibex_pkg.sv 772:20 | golden keeps a `ref_obj`; we emit `constant UINT:33` |

Cluster A rows: alu, branch_predict, compressed_decoder, decoder, icache,
multdiv_fast, multdiv_slow, pmp, wb_stage — all nine `project.f`s list
`ibex_pkg.sv`, and the head is the SAME shared object in all nine. Cluster B
rows (csr, counter, fetch_fifo, load_store_unit) list NO package at all, which
is why they were never part of the package family.

**The struct-parameter / struct-ASSEMBLER family owns NONE of these heads.**
No ibex head is a `struct_var`, an assembled BIN constant, or an EvalFunc
leftover. The sister passes' residues do not reach ibex.

## 3. What the A/C head actually is

ibex_pkg.sv:721 is

```systemverilog
parameter int LfsrWidth = 32;
typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] lfsr_perm_t;   // 721
parameter lfsr_perm_t RndCnstLfsrPermDefault = { … };               // 723
```

The head is the `$clog2` ARGUMENT (col 40) — **not** the first dimension's
`LfsrWidth` (col 15), which agrees. It agrees because `Compare` reads
`VpiName` and never `VpiFullName`: our dim-1 `ref_obj` carries the same
`VpiName:LfsrWidth` under a different synthesized fullname
(`…RndCnstLfsrPermDefault.LfsrWidth` vs golden's `…::lfsr_perm_t::LfsrWidth`),
and that difference is invisible to the judge.

Our DEF-view typespec listing is byte-identical to golden. The divergence is
confined to the **elaborated copies of a package parameter's typespec**.

`g1/dut.sv` is a faithful 12-line witness: **46 cmp lines, 1 head, the same
head object** as the nine cluster-A rows. `g3/dut.sv` is the same shape with
`$clog2` removed, and `g2/dut.sv` is g3 without the module-side import.
Reproduce any of them with

```bash
cd g1 && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv
<slang-uhdm> dut.sv --single-unit --nobuiltin -o ours.uhdm
~/git-repos/UHDM/build/bin/uhdm-cmp slpp_all/surelog.uhdm ours.uhdm
```

`--nobuiltin` is REQUIRED (the harness passes it); without it the builtin
package makes the whole design a vector-size mismatch and the head is
meaningless — 5278 cmp lines of noise.

`tsloc.py <dump>…` is the instrument: per typespec block it prints the design
listing it sits in, the owner it hangs under, and for each of its OWN ranges
whether the left bound is folded (`constant`) or symbolic
(`operation`/`ref_obj`), plus whether a `$clog2` argument inside it is folded.
Read off g1 it gives, for the parameter-owned clones:

```
GOLDEN  copy#1 ['constant','constant']                     copy#2 ['operation','operation/clog2arg=ref_obj']
OURS    copy#1 ['operation','operation/clog2arg=constant'] copy#2 ['operation','operation/clog2arg=constant']
```

So golden mints TWO elaborated copies with DIFFERENT reduction policies — one
fully reduced, one fully symbolic (its `$clog2` argument included) — and we
mint two half-reduced ones.

## 4. The law that was decoded, tried, and REJECTED

§ `pkgParamOwnDefRange` (ParamEmit.cpp:16940) already states the governing
rule: *a PACKAGE parameter's own declared range is view-dependent — the
symbolic operation survives ONLY in the package's own DEF listing, and every
other copy carries the reduced constant.* It is already applied to a typed
parameter's typespec range (§ pkgParamTsRef, TypeEmit ~3833) and to the
`bit`/`int`/`byte` typedef clone (`tfContext = ownDef18`, ParamEmit ~17900).
The **vector** (`logic`) typedef clone was the one builder that still
hardcoded `tfContext = true` — in both of its arms (~18191 and ~18228).

Changing those two to `tfContext = pkgParamOwnDefView(ps)` was built and
measured. Traced, the gate fires exactly as designed (`ownDef=1 → UNFOLDED`,
`ownDef=0 → FOLD`), and on g3 it brings every fold-state into agreement with
golden except one inverted pair. On the corpus it is **INERT**:

* all 14 rows: cmp-line counts and head objects BIT-FOR-BIT unchanged
  (46/36/64/34 before and after; 1 head each) — 0 conversions.
* it nonetheless MOVES 10 databases — exactly the predicted ibex rows that
  include `ibex_pkg` (the 9 cluster-A rows + tracer); the 4 cluster-B rows
  stay byte-identical, as predicted.

It was therefore **reverted, not landed**: a byte-moving, zero-gain change
would hand the next pass on this family a half-reduced baseline while
converting nothing. The predicted mover set is recorded in §6 so a future
attempt does not have to re-derive it.

The reason it is inert is now clear and is the real finding: **the law fixes
the divergence BEHIND the head, not the head.** Cluster A's head is the
`$clog2` ARGUMENT inside the copy that stays symbolic; cluster C's head is a
BARE ref bound in an inline (non-typedef) range. Neither is a typedef-clone
range bound.

## 5. Residues, ranked by population — START HERE

* **R0 — the `$clog2` argument of a symbolic typespec range bound (9 rows,
  cluster A).** In the elaborated copy golden keeps symbolic, golden's
  `sys_func_call ($clog2)` keeps its argument as a `ref_obj`; we fold it to
  `constant UINT:32` carrying a `ref_typespec → int_typespec`. Our own
  package DEF-listing object gets this RIGHT (`clog2arg=ref_obj`), so the bug
  is confined to the per-parameter CLONE built by `makeTypespec` from syntax.
  `crossPkgFoldBoundLeaves9` (TypeEmit:734) is NOT the culprit — it recurses
  only into `uhdmoperation` and never into a `sys_func_call`. Witness `g1`.
  This is the widest single remaining law in the family.
* **R1 — the two elaborated copies are INVERTED (blocks R0 from converting).**
  Golden's parameter-owned pair is (reduced, symbolic); with the §4 law ours
  is (symbolic, reduced). Until the two copies are put on the edges golden
  puts them on, folding alone cannot converge a row. Witness `g3` +
  `tsloc.py`; the two copies are text-identical apart from the fold, so they
  must be told apart by `Instance()`/edge, never by dump order.
* **R2 — a BARE package-parameter ref as an inline range bound (1 row,
  ibex_tracer).** `parameter logic [PMP_ADDR_MSB:0] PmpAddrRst[…]`
  (ibex_pkg.sv:772): golden keeps `ref_obj PMP_ADDR_MSB` (with
  `vpiActual → constant`), we fold to `constant UINT:33`. Distinct from A —
  the bound is a bare ref, not an operation, and the type is written inline,
  not through a typedef.
* **R3 — `` `PRIM_STRINGIFY `` keeps the continuation-line indent (4 rows,
  cluster B).** `prim_assert.sv:21` `` `define PRIM_STRINGIFY(__x) `"__x`" ``,
  reached from `ASSERT_ERROR`'s `$error(…)` whose last argument sits on a
  continuation line indented by NINE spaces (`prim_assert.sv:33`). Golden's
  string constant is `"IbexCSREnValid"` (`vpiSize` 112 = 14 chars); ours is
  `"         IbexCSREnValid"` (`vpiSize` 184 = 23 chars = 9 + 14). **Scope
  warning:** the stringification happens in slang's PREPROCESSOR, and
  patching slang is out of scope — so this must either be normalised
  exporter-side or ranked as unreachable. It is the only cluster whose rows
  need no package at all, and it is likely to recur on any design that uses
  `prim_assert.sv`.

## 6. Predicted movers for any future attempt at the §4 law

`predict.py <corpus-root>…` lists every test whose sources declare a package
parameter typed by a SYMBOLIC-bound vector typedef (deliberately over-broad:
a name it does not list cannot move).

* u2r (both modes), 20 rows, all ibex — the 14 CMP_NOTEQUAL minus the 4
  cluster-B rows (csr, counter, fetch_fifo, load_store_unit, which have no
  package), plus the 10 currently SLANG_REJECT/CMP_EQUAL ibex rows.
  Measured movers were a subset: 10.
* surelog, 10 rows: Ariane2024, ArianeElab, ArianeElab2, AzadiRTL,
  BlackParrotMuteErrors, Earlgrey_Verilator_01_05_21, Earlgrey_nexysvideo,
  IncompTitan, MultiConcat, ariane.

**No canary is reachable.** SVSwitch, YosysVerx, YosysOldOr, InterfaceModPort
and BlackParrotComplex carry the shape nowhere. `Earlgrey_0_1` is the one that
looks at risk and is NOT: it vendors an OLDER `alert_pkg.sv`/`aes_pkg.sv` with
no `lfsr_perm_t` at all, so the shape cannot be reached — verified by scanning
its own `src/` tree, not assumed from the test name.

## 7. Gates run

* pristine build md5 `2f28c372da15bec082e100bd0dfdea51` — byte-identical to
  the main tree at ec81cb73.
* `tests/check_goldens.sh` on the pristine binary: **23 PASS / 0 FAIL**;
  negative control `SLANG_UHDM=/bin/false`: **23 FAIL / 0 PASS**.
* every sweep exported `SLANG_UHDM` explicitly and every `cmds.txt` was
  audited by binary PATH (`/tmp/r11u5_pristine.bin`), never by the name
  `slang-uhdm`.
* the full gate battery (u2r both modes, surelog both modes, ct8rows,
  byteverify, canaries) was NOT run, because no production file changed: the
  final tree is byte-identical to ec81cb73 and there is nothing for those
  gates to judge.
