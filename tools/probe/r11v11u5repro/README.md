# r11v11u5 — adversarial verification of r11u5 (the IBEX family)

Verifier's own worktrees `/tmp/wt_v11u5` + `/tmp/wt_v11u5pris` at `ec81cb73`,
own frozen binaries, own sweeps. Judge is `uhdm-cmp` through
`scripts/verify_golden.py`. Everything here is measurement-only except the ONE
production hunk in `src/ParamEmit.cpp` (§ elabStrLitParamDeclWidth) that this
verification landed.

## 1. Verdict

**ACCEPT-WITH-FIX.** r11u5's patch is honest, safe and correctly measured: it
is probe-only (7 files under `tools/probe/r11u5repro/`), it edits no
production file and no `results/*.csv`, and its headline numbers reproduce
bit-for-bit on an independently built pristine binary. Its decision NOT to
land the § pkgParamVecTdCloneViewFold experiment (byte-moving, zero-gain) was
the right call.

Three of its measured claims are WRONG or mis-attributed, and the correction
turns the pass from **0 conversions into 1** (both modes):

* the family is **FOUR** clusters, not three — `ibex_counter` is not the
  `PRIM_STRINGIFY` cluster;
* that fourth cluster is a **landable one-hunk law**, now landed and gated;
* R3's proposed exporter-side whitespace normalisation is **not** a free trim —
  `b5/dut.sv` is a legal-SV row that is CMP_EQUAL today and that an
  unconditional trim would break; and the 9 leaked spaces come from a place
  other than the one R3 names.

## 2. Reproduced bit-for-bit

| headline | r11u5 | this verification |
|---|---|---|
| pristine binary md5 | `2f28c372da15bec082e100bd0dfdea51` | same (built from a fresh worktree) |
| patched binary md5 | — | `2f28c372…` — IDENTICAL, so the patch cannot move a database |
| goldens | 23 PASS / 0 FAIL; `/bin/false` 23 FAIL | same |
| u2r ibex rows | 14 CMP_NOTEQUAL / 12 SLANG_REJECT / 2 CMP_EQUAL, both modes | same, and the two mode sets are name-for-name identical |
| u2r totals | 741 / 63 / 67 | same, both modes |
| heads | 1 per row (`grep -c '^LHS:'`) | same, all 14 |
| cmp lines | 46×9, 36×3, 64, 34 | same (= stdout + stderr; `uhdm-cmp` prints the head to STDERR) |
| head objects | `HEADS.txt` | same, ids included, EXCEPT `ibex_counter` (see §3) |
| `g1` witness | 46 cmp lines, cluster-A head | same: 46 lines, 1 head, `ref_obj (p::PermDflt::lfsr_perm_t::LfsrWidth)` under `sys_func_call ($clog2)` |
| `predict.py` on surelog | 10 tests | same 10 |
| `Earlgrey_0_1` unreachable | claimed | CONFIRMED with a positive control: `lfsr_perm_t` occurs in 59 files of the surelog corpus and in **0** under `Earlgrey_0_1` |

All 1742 `cmds.txt` in the pristine u2r workdir were audited by binary PATH:
every one names `/tmp/v11u5_pristine.bin` on its `slang:` line; zero name
anything else. `SLANG_UHDM` was exported explicitly on every sweep.

`g1`'s fold census (`tsloc.py`) reproduces r11u5 §3 exactly — golden's
parameter-owned pair is `['constant','constant']` + `['operation',
'operation/clog2arg=ref_obj']`, ours is `['operation',
'operation/clog2arg=constant']` twice, and the DEF (`uhdmallPackages`) copy
agrees with golden on both sides. R0 and R1 are accurately stated.

## 3. FINDING 1 — the family is FOUR clusters. `ibex_counter` is its own.

r11u5 puts `ibex_counter` in cluster B ("`constant` @ 33:10, the `$error`
arg"). Its own `HEADS.txt` contradicts that: `ibex_counter`'s head is at
**61:27**, not 33:10. Measured head:

```
LHS  constant: , line:61:27  |vpiParent \_param_assign  |vpiDecompile:no |vpiSize:32  |STRING:no  |vpiConstType:6
RHS  constant: , line:61:27  |vpiParent \_param_assign  |vpiDecompile:no |vpiSize:16  |STRING:no  |vpiConstType:6
```

Nothing to do with `PRIM_STRINGIFY`: the source is
`rtl/ibex_counter.sv:61  localparam int UseDsp = "no";` — a STRING literal
initialising an INTEGRALLY-typed parameter. Cluster B is **3** rows (csr,
fetch_fifo, load_store_unit), each leaking exactly 9 spaces (72 bits).

(`HEADS.txt` also records `ibex_counter`'s head id from the DEFAULT-mode run
while its other 13 rows carry testflags ids — that row is the only one in the
family whose head id is mode-dependent. Cosmetic, but it shows the table was
assembled from two sweeps.)

`d1/dut.sv` (8 lines) is the minimal witness. Golden's rule, read off it:

| declaration | DEF listing | ELAB listing |
|---|---|---|
| `localparam int UseDsp = "no"` | 16 | **32** |
| `localparam int Four = "abcd"` | 32 | 32 |
| `localparam int Long = "abcdef"` | 48 | **32** (truncates) |
| `localparam byte B = "z"` | 8 | 8 |
| `localparam string S = "no"` | 16 | 16 |
| `localparam UseD2 = "no"` (untyped) | 16 | 16 |

Ours sized every one of them at the literal's character width in BOTH views.

## 4. THE LAW LANDED — § elabStrLitParamDeclWidth

`src/ParamEmit.cpp`, immediately before `pa->Rhs(rhs)` in `emitParameters`'
generic tail:

> A parameter with an **explicitly written** integral type whose initializer
> is a **string literal** keeps its STRING encoding but is sized at the
> DECLARED type's width in the ELABORATED listing; the DEF listing keeps the
> literal's own character width.

This is the same adjustSize walk the emitter already models one level down —
the `default: "inv"` struct-pattern arm in the same file re-sizes a
`vpiStringConst` to the MEMBER width and never folds it to the numeric value
of its characters. § elabStrLitParamDeclWidth is that walk on the un-nested
case.

The gate is `topView && typedParam` plus `vpiStringConst` plus a
`StringLiteral` init plus an integral, non-string, non-zero-width declared
type.

**`typedParam` is load-bearing and was found by measurement, not by reading.**
The first build keyed on slang's INFERRED type instead. That version converted
`ibex_counter` in both modes and moved exactly the 2 predicted u2r databases —
and **demoted three CMP_EQUAL surelog rows**: `ParamFile` (both modes),
`ParamFileNoTop` and `ParamFileOverr` (default). Cause, read off the head:
`parameter SRAMInitFile = "";` is implicitly typed, slang canonicalises the
empty literal to an 8-bit integral type, and golden emits that constant with
**no `vpiSize` at all** — so the inferred-type rule wrote `vpiSize:8` over a
field golden leaves unset. Keying on the WRITTEN type removes the demotion and
keeps the conversion.

## 5. Gates — all green on the fixed law

* builds: pristine `2f28c372da15bec082e100bd0dfdea51` (= the main tree at
  `ec81cb73`); r11u5's patched tree builds byte-identical to it; the law binary
  is `75b2098c608dd7ebd50199dd1c27ccbb`, all at `-j 2`, md5 taken separately.
* goldens on the law binary: **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false`
  **23 FAIL / 0 PASS**.
* **u2r, BOTH mode columns scored: 741 → 742 CMP_EQUAL, 63 → 62 CMP_NOTEQUAL,
  67 SLANG_REJECT unchanged.** `ct8rows` against `results/golden_uhdm2rtlil.csv`
  and `results/gate_uhdm2rtlil.csv` moves exactly the rows quoted in §7 and
  nothing else. No `match` → `differ` demotion (527/531 unchanged).
* **surelog, both modes: every row identical to the pristine baseline** —
  `459/18` testflags and the default column unchanged, `ParamFile*` back to
  CMP_EQUAL.
* `byteverify SELFCHECK=1` on u2r: **MOVERS 2 / 1608**, both named a priori —
  `default/ibex_counter-*/slang.uhdm` and `testflags/ibex_counter-*/slang.uhdm`.
  Positive control: SELFCHECK flags 1607/1608, so the comparator can see.
* canaries: `canaries.sh` **ok=8 changed=0**; `ctcan2.sh` PASS. No canary
  carries the shape (`SVSwitch`, `YosysVerx`, `YosysOldOr`, `InterfaceModPort`,
  `BlackParrotComplex` — the two BlackParrot `dut.sv` were scanned directly and
  contain zero instances of it).
* `results/*.csv` NOT edited.

## 6. A-priori mover prediction, with its positive control

The law can only reach a parameter written with an integral type keyword and
initialised by a string literal. Scanning both corpora for that shape:

* **uhdm2rtlil: one file**, `ibex/rtl/ibex_counter.sv` — compiled by exactly
  one test, `ibex_counter`. Predicted movers: 2 databases (one per mode).
  **Measured: exactly those 2.**
* **surelog: three files**, all under `third_party/tests` —
  `black-parrot/external/basejump_stl/bsg_test/bsg_nonsynth_dpi_cycle_counter.v`,
  `…/bsg_nonsynth_dpi_clock_gen.v`, `Verilator/t_param_array.v`. No `.sl`
  names the first two; the third is reached only by the `Verilator` batch test,
  which is SLANG_REJECT at the baseline in both modes. Predicted movers: **0**.
  **Measured: 0** (every surelog row identical to pristine). The census zero's
  positive control is the u2r side, where the same scan predicted a nonzero set
  and the comparator found precisely it.

## 7. THE CONVERSION — said loudly, quoted, NOT written into results/*.csv

```
- ibex_counter,default,CMP_NOTEQUAL,decompile:,,
- ibex_counter,testflags,CMP_NOTEQUAL,decompile:,,
+ ibex_counter,default,CMP_EQUAL,,,differ
+ ibex_counter,testflags,CMP_EQUAL,,,differ
```

**ONE uhdm2rtlil test converts, in BOTH modes.** `results/golden_uhdm2rtlil.csv`
lines 308 and 1179 are the rows the integrator promotes;
`results/gate_uhdm2rtlil.csv` carries the testflags one. This verification did
not edit them.

## 8. FINDING 2 — R3 is mis-attributed, and its fix is not a free trim

`b1/dut.sv` (12 lines) reproduces cluster B on its own: 36 cmp lines, 1 head,
golden `STRING:MyName` vs ours `STRING:         MyName`.

**Where the 9 spaces come from.** R3 says "keeps the continuation-line indent
… 9 spaces from `prim_assert.sv:33`". They come from line **32** — the
whitespace between the last token and its line-continuation backslash.
`b8/dut.sv` separates the two theories in one file: `CONT`'s stringify sits on
a continuation line indented by FOUR spaces whose previous line has ONE space
before the `\`, and exactly ONE space leaks. (`prim_assert.sv:32` happens to
carry 9 spaces before its `\` and line 33 happens to be indented 9 — which is
why the misreading survived.) `SAME`, whose stringify is on the same line as
its preceding tokens, does not leak at all: the trigger is a
line-continuation with tokens before it in the macro body.

**Why a trim is not free.** `b5/dut.sv` declares
`` `define LIT `"  hello  `" `` — golden KEEPS the two leading and two
trailing spaces, we keep them too, and the file is **CMP_EQUAL on the pristine
binary today** (`uhdm-cmp` rc 0, zero lines). An unconditional trim in
`ExprEmit.cpp`'s `macroQuoted9` branch — the obvious place, and the branch that
already carries a Surelog-shaped carve-out (§ macroPasteDotText104) — turns
that equal row unequal. Any R3 attempt must discriminate whitespace that came
from macro-body trivia from whitespace written inside the stringification.

## 9. Residues, re-ranked by population (measured, not inherited)

* **R0 — the `$clog2` argument of a symbolic typespec range bound. 9 rows.**
  Unchanged from r11u5 and confirmed here on `g1` + `tsloc.py`. Still the
  widest single law in the family.
* **R1 — the two elaborated copies sit on the wrong edges. Blocks R0.**
  Confirmed: golden's parameter-owned pair is (reduced, symbolic), ours is
  (half-reduced, half-reduced). Tell the copies apart by `Instance()`/edge,
  never by dump order.
* **R2 — `` `PRIM_STRINGIFY `` leaks the pre-backslash whitespace. 3 rows**
  (csr, fetch_fifo, load_store_unit — NOT 4). Witness `b1`; counterexample
  `b5`; discriminator `b8`. Reachable exporter-side only with a provenance
  test, and worth 3 rows, so it now outranks R2-as-was.
* **R3 — a bare package-parameter ref as an inline range bound. 1 row**
  (`ibex_tracer`). Confirmed head: golden keeps `ref_obj PMP_ADDR_MSB` with
  `vpiActual → constant`, we fold to `constant UINT:33` size 64.
* **CLOSED — a string literal initialising an integrally-typed parameter.
  1 row (`ibex_counter`), landed here.**

## 10. Files

* `d1/dut.sv` — the cluster-D witness; CMP_NOTEQUAL (64 lines, 1 head) on the
  pristine binary, CMP_EQUAL on the law binary. Also pins the truncate/widen
  and string/untyped boundaries in one file.
* `b1/dut.sv` — minimal cluster-B (R2) witness, 36 cmp lines, 1 head.
* `b5/dut.sv` — the R2 COUNTEREXAMPLE; must stay CMP_EQUAL.
* `b8/dut.sv` — discriminates "continuation-line indent" from "pre-backslash
  whitespace"; `SAME` must stay clean, `CONT` leaks exactly one space.
* `heads.sh <workdir> <mode> <outdir> <test>…` — per-row head + cmp-line
  extractor. Reads the golden path out of each test's own `cmds.txt` and
  counts heads on **stderr**, where `uhdm-cmp` prints them.

Reproduce a witness with

```bash
cd d1 && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv dut.sv
<slang-uhdm> dut.sv --single-unit --nobuiltin -o ours.uhdm
~/git-repos/UHDM/build/bin/uhdm-cmp slpp_all/surelog.uhdm ours.uhdm
```

`--nobuiltin` is required on both sides, as r11u5 records.
