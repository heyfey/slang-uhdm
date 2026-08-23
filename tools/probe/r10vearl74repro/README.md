# r10vearl74 — ADVERSARIAL VERIFICATION of r10earl74 (§ dimBoundInheritsParamEnc74)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's
report reproduces **bit-for-bit** from binaries this verifier built itself —
including both md5s, both heads, the grid, the censuses and both corpora. But
the design-final resolution walk is **unbounded**, and on legal SystemVerilog
it turns a **pristine-RIGHT bound into a patched-WRONG one**: 6 range cells per
view on `va1_v74.sv`. The fix is one statement (stop the walk at the instance
boundary), it costs nothing on any other measurement, and it is shipped as
`/tmp/r10earl74.verified.patch`.

**MEASUREMENT ONLY.** `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
**BASE `3dba439`.** `results/*.csv` was READ ONLY and is untouched; **no row
was converted** — `Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes.

---

## 1. Reproduction of the implementer's numbers

Two fresh worktrees at `3dba439`; both binaries built `-j 2`, copied to
immutable paths and `chmod 555` **before any sweep**; `SLANG_UHDM` exported
explicitly per binary; **every `cmds.txt` audited by binary PATH**. The main
tree is at a LATER commit than the base, so its build is not a control here —
both binaries were built from `3dba439` in this verifier's own worktrees.

| | this verifier's build | implementer's claim |
|---|---|---|
| pristine md5 | `9eacde42bc0cbeb98b1c8c33855b4e33` | same |
| shipped-patch md5 | `43ce65509e867ddc34386fa7a5dc4ece` | same |
| fixed md5 | `615df008da93feb8712e0c4283cdcbf3` | — (this verifier) |

| claim | measured here |
|---|---|
| patch applies clean on a FRESH `3dba439`, no `-3` | yes; surface = `include/UhdmExporter.h` + `src/TypeEmit.cpp` + `src/UhdmExporter.cpp` + `tools/probe/r10earl74repro/`, nothing else; fenced-name scan 0/0/0/0 |
| `HEAD_BEFORE_{default,testflags}.cmp` | **byte-identical** to the committed files |
| `HEAD_AFTER_{default,testflags}.cmp` | **byte-identical** to the committed files, with the FIX in |
| Earlgrey head | **36 → 17 cmp lines, one head to one head, both modes, byte-identical across modes** |
| `g1_dims74.sv`, `score74.py` | `TO-GOLDEN 159 / AWAY 0 / MOVED-WRONG 0 / STILL-WRONG 43`, **both views** |
| `law74.py` | golden **74/74**, pristine **44/74**, patched **74/74** |
| Earlgrey range census, default | 90,076 shared cells, `CT/TAG-ONLY` **9 → 0**, 3-way **TO-GOLDEN 9 / AWAY 0** |
| Earlgrey range census, testflags | 90,191 shared cells, `CT/TAG-ONLY` **13 → 0**, 3-way **TO-GOLDEN 13 / AWAY 0** |
| `param_assign` census | 30,808 cells, pristine vs patched **byte-identical** |
| uhdm2rtlil, both modes | **679 / 50 / 2**, **0 differing rows** vs the committed baseline and vs my own pristine sweep |
| surelog, `--mode both` | **0 differing rows over 1588**, identical nine-way histogram, **no row converted** |
| byte movers | **0/1358** and **2/956** — exactly the two Earlgrey databases |
| mover prediction from pristine DBs alone | u2r 1358 scanned / 0 flagged; surelog 956 / 3, and both false positives independently REFUTED from the source (see `VGATES.txt` §5) |
| canaries / protected DBs | 52 + 8 `changed=0`, both `ctcan2` PASS, `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`, all five protected DBs SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` |
| boundary | WIDE `PROCESSED=3382 identical=6478 DIFFERING=10 no_output=276`; DIR `PROCESSED=1491 identical=2726 DIFFERING=12 no_output=244` — the implementer's tallies plus this verifier's two extra grid files |

Every rc=139 pairs A with B on the same file and view; no new crash.

## 2. The regression, and the fix

`VREGRESSION.txt` carries the reproducer and the numbers. In one paragraph:
the design-final pass resolves the sizing parameter **by name**, walking the
bound's `VpiParent` chain **outward with no limit**. Once that walk leaves the
declaration's own instance body it lands on an unrelated same-named
`param_assign` in a parent instance. `module vq74; logic [3:0] q_pm
[vpk74::PM];` with `vpk74::PM = 4 * 2` is `INT:8` on golden in **every**
instance of `vq74`; under a parent carrying `localparam int PM = 4 + 4`
(`UINT:8` — same value, other tag) the shipped patch writes `UINT:8`.
Pristine was right. **6 cells per view, DEF and ELAB.**

Golden cannot do this: SystemVerilog name resolution stops at the module body,
and a package parameter is not on the instance chain at all — Surelog's own
outward walk (`CompileExpression.cpp:986-1024`) is only the FALLBACK after
`instance->getValue(name)` (`:966-981`) has already answered with the
package's value.

**Fix** (`src/UhdmExporter.cpp`): check each enclosing scope's
`Param_assigns()`, then **stop at the first `instance`** — `module_inst` /
`interface_inst` / `program` / `package` / `udp_defn`. `gen_scope` and
`gen_scope_array` are lexical, sit below that boundary, and are still walked,
so every gen-scope and multi-instance family the law was written for is
untouched.

**What it costs: nothing.** The implementer's grid, `law74.py`, the Earlgrey
head, both Earlgrey censuses, both corpora and all four canary suites are
identical with and without it. A WIDE boundary walk with **A = shipped,
B = fixed** over the whole probe tree reports `PROCESSED=3382
identical=6486 **DIFFERING=2**` — `va1_v74.sv` in its two views, the arm that
convicted the patch, and nothing else. `vcross74` scanned all 1358 u2r and all
956 surelog pristine databases for bounds whose walk answers differently with
and without the boundary: **0** and **2** (both Earlgrey), and both Earlgrey
candidates were refuted by running the SHIPPED binary on the row itself —
`ebeb06d8385ca17bec7282915455ef98` / `819970577a6179ab9e7f3abda20b246c`,
byte-identical to the fixed binary's databases.

## 3. The adversarial arms

| arm | what it crosses | shipped | fixed |
|---|---|---|---|
| `va1_v74.sv` | qualified and wildcard-imported package parameters vs a same-named, same-valued, other-tagged parameter in the parent instance, one and two hops up, plus a gen-scope collision, plus a collision-free control | **24 TO-GOLDEN / 6 AWAY**, both views | **33 TO-GOLDEN / 0 AWAY**, 162/162 |
| `va2_v74.sv` | `[D]`, `[D-1:0]`, `[0:D-1]`, `[D*2]`, `[D][E]`, `[$clog2(D)-1:0]`, `[D:D+3]`, packed and unpacked, on array_vars / nets / **ports** / typedef'd typespecs / an index expression / an **instance array**; 11 override actuals (× / ÷ / − / + / ≪ / ≫ / `$clog2` / bare ref / literal / based literal / cast) plus package parameters; homes module / gen-for / gen-if / nested gen / **interface** / **program**; 1..3 instances; 2- and 3-hop chains; negative and 64-bit values | 249 TO-GOLDEN / **0 AWAY** | identical |
| `va3_v74.sv` | a gen-scope localparam SHADOWING a module-level one of the same name, foldable and cast initializers | 12 TO-GOLDEN / **0 AWAY**, 66/66 | identical |

Typespec presence, bound size and **span presence** were scored on their own
field sets in every arm: `agreeP == agreeQ` everywhere — the law moves
`vpiConstType` and the value tag and **nothing else**.

A scoring note worth carrying forward: a **sorted-list** pairing re-pairs a
two-dimension `array_var` when one of its bounds moves and manufactures a
phantom AWAY-GOLDEN (it reported 4 on `s_2d [D][E]` that the raw rows show is
a clean TO-GOLDEN). `vmsjoin74.py` scores every owner key as a **multiset**
and reports 0.

## 4. Residues this verification adds or sharpens

- **R0 (the implementer's, confirmed independently)** — golden puts a
  `ref_typespec` on the REPLICATION-COUNT constant of
  `flash_phy_core.sv:190 prog_data_packed = {DataWidth{1'b1}}` (cols 27-36 are
  `DataWidth`), fullname = the owning instance, actual = the `int_typespec` at
  `flash_phy_pkg.sv:17:13-17:16` (`parameter int DataWidth = …`); we emit
  `RHS: <null>`. 17 cmp lines, one head, both modes.
- **R-A (NEW)** — a `program` body does not take the arm: `vprg74`'s
  `logic [3:0] r_d_sz [D]` is `INT:8` on golden and `UINT:8` on ours, before
  and after. 3 grid cells, 0 corpus.
- **R-B (NEW)** — a **typedef'd** dimension does not take the arm (the arm is
  gated on `array_var`/`array_net`): `s_td_t`/`s_tp_t` in `va2_v74.sv` carry
  45 + 40 still-disagreeing golden cells.
- **R-C (sharpened from the implementer's R3)** — the INLINE-EXPRESSION
  dimension `[D*2]` is folded at the wrong size AND tag (golden `INT`/64, ours
  `UINT`/32): 63 + 27 + 6 = **96** cells across `s_dbl`, `l_dbl`, `g_m_dbl`
  in `va2_v74.sv`. Zero corpus cells.
- **R-D (sharpened from r10earl73's R5)** — `r10buvm22repro/g22.sv`'s
  associative array `typedef C22 ka_cls_t[string];` gets a garbage
  allocation-count value as its dimension bound (`22383993` → `22392217`).
  Two pristine runs of the same file are byte-identical, so it is **not** a
  coin: it is a value that shifts with ANY code change, and it will keep
  showing up as a phantom boundary mover for every future pass until it is
  fixed.
- **Span presence** — golden's folded bound is LOC-LESS and ours carries a
  span almost everywhere (21 of 2598 cells agree). Invisible to the judge
  (`constant::Compare` and `range::Compare` read no location), unchanged by
  this pass, but it is what makes a span-carrying census payload dangerous.

## 5. Files

`VGATES.txt` (every gate number), `VREGRESSION.txt` (the break and the fix),
`VARMSCORE.txt` (three adversarial grids × two views × two binaries × four
field sets), `VCENSUS.txt` (Earlgrey censuses + the shipped-vs-fixed identity
proof), `VBOUNDARY.txt` + `VBOUNDARY_{WIDE,DIR,SHIPPED_VS_FIXED}.*`,
`VHEAD_{BEFORE,AFTER}_{default,testflags}.cmp`, and the instruments:
`va1_v74.sv`, `va2_v74.sv`, `va3_v74.sv`, `vcen74.cpp` (range census with
typespec presence and a separate span-presence mode), `vcross74.cpp`
(shipped-vs-fixed divergence predictor), `vmsjoin74.py` (multiset 3-way
scorer), `vscore74.py`, `varm74.sh`, `vwide74v.sh`, `vdir74v.sh`,
`canaudit.sh`.
