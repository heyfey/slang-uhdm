# r10earl37 — INDEPENDENT VERIFIER REPORT

**VERDICT: PASS**, with **9 numbered findings**. Every headline number in
`README.md` reproduces — both binaries bit-for-bit, all five gates, every canary,
the 11-object mover fence, the per-shape accounting to the unit, the design-scale
invariant re-derived with my own counter. The head is CLEARED and no gate,
canary, corpus row or database moves except the target.

What does **not** survive is part of the WRITE-UP: two of the law's stated
clauses are REFUTED by golden on shapes neither grid arm contains (both with zero
corpus reach), one claimed axis is an EMPTY PRODUCT, the FIXED/ok split of both
grids is off by 2, the pass's own **F4** is refuted by building the rejected
alternative, and **F5**'s cell does not reach the code path F5 names (though
F5's conclusion survives on a cell I had to build). The §0 claim that the change
is "NARROW and MONOTONE ... it can only replace ONE object at ONE slot" is
**false**: on an escaped-identifier base it fabricates path elements that neither
golden nor pristine has, and that is the one measured regression in this
verification (arm distance 122 → 128).

Verified against a FRESH `45716d3` worktree of my own (`/tmp/wt_v37`,
`/tmp/wt_v37pris`). The patch also `git apply --check`s clean on the CURRENT main
head `a27a874` (r10svs14 landed during this verification).

---

## 0. Binaries — both md5s reproduced EXACTLY

| binary | md5 measured here | implementer's | BASE grep-asserted |
|---|---|---|---|
| PRISTINE `45716d3` | `65f339fdc5b4497ec6a2773f7462113f` | same | `45716d32f8be…` ✓, `git status --porcelain` empty |
| PATCHED | `ff9f076343d0253cc7f3b310a65b5381` | same | `45716d32f8be…` ✓ |
| (my F4-attack variant, §F-5) | `271244ba73ab4d81630e30aee4e62312` | — | `45716d3` ✓ |

Both 32-hex-asserted, md5 taken in a separate step from the build, link line
waited for (`grep -E "Built target slang_uhdm$"` — note `slang_uhdm_obj_lib`
substring-matches a naive grep and will report a link that has not happened),
`grep -cE 'error:'` = **0** on all three.

Reproducing both md5s exactly means every number below is a **re-measurement**,
not a re-derivation.

## 1. Patch hygiene — clean

* `git apply --numstat`: `src/ModuleEmit.cpp` **63 / 4** is the ONLY production
  file. No `include/` change, so no new member. ✓
* Comment/code split counted mechanically off the ModuleEmit hunks:
  **added 63 = 49 comment + 14 code; removed 4 = 2 comment + 2 code.** Exactly
  as claimed. ✓
* **STATED GATE == CODE GATE**: the three quoted blocks in §0 are verbatim the
  code. ✓
* `README.verifier.md` in the patch **is THIS pass's own**, carries no verdict,
  and says so — the stale-carry trap is not repeated. ✓ (This file replaces it.)
* **earl34 arms hold**: `a1_idxkind`, `a2_shape`, `a3_escaped` — pristine vs
  patched dumps **0 differing row-sides** after normalising the workdir path
  (the arm bakes its own workdir into the dump; an un-normalised `cmp` reports a
  spurious difference on all three).
* **earl36 arms hold**: `a1_bound`, `a2_noimport`, `a3v_gaps` — **0** likewise.
* **Live passes**: `r10uvm66` touches `StmtEmit.cpp` + the header — disjoint.
  `r10svs14` touches `src/ModuleEmit.cpp` but at `@@ -22497` (`emitInterfaceInst`)
  against earl37's `@@ -2356 / -25482 / -25513`. `svs14 → earl37 → uvm66` apply
  clean in sequence onto one 45716d3 tree. **No collision.**
* Main tree carries no `earl37` residue (`ls tools/probe | grep -c earl37` = 0) —
  the implementer's self-disclosure is accurate.

## 2. The five gates — all GREEN, every number reproduced

| gate | measured here | claimed |
|---|---|---|
| **1 BUILD** | link line waited, `error:` = 0, md5 separate + 32-hex, BASE grepped | same |
| **2 GOLDENS** | `SLANG_UHDM` set EXPLICITLY: **23 PASS / 0 FAIL**; `/bin/false`: **0 / 23** | same |
| **3 u2r j2 both modes** | default **679/50/2**, testflags **679/50/2**; testflags dump **496 match / 183 differ / 52 blank**; default dump **492/187/52**; `ct8rows` vs `results/gate_uhdm2rtlil.csv` **0 differing ROWS (0 row-sides)** | same |
| **4 surelog j2 both modes** | default **467 CMP_EQUAL / 13 CMP_NOTEQUAL**, testflags **463 / 10**; `SURELOG_FAIL` **25 / 23**; `ct8rows` vs `results/golden_surelog.csv` **0 differing ROWS**; dump histograms UNCHANGED both modes (**327/242/225**, **331/298/165**) | same |
| **5 BYTE VERIFIER** | u2r **0 / 1358**, SELFCHECK **1357/1358**, SELFCHECK1 **1**; surelog **2 / 953** (see **F-8**), SELFCHECK **952/953**, SELFCHECK1 **3** | u2r same; surelog claimed 1/953, SELFCHECK1 2 |

The u2r row gate was fed the testflags projection because the committed baseline
carries testflags rows only (`awk` count of non-testflags baseline rows = 0) —
731 rows against 731, the committed gate and not a weakened one. Confirmed.

**CANARIES**, each reproduced exactly:
`canaries.sh` vs `golden_surelog.csv` **ok=52 changed=0 absent=0** unknown=7;
vs the u2r testflags projection **ok=8 changed=0 absent=0** unknown=25;
`ctcan2 EXPECT_UNKNOWN=1` (surelog, baseline FIRST) **PASS ok=58/0/0** unknown=1;
`ctcan2 EXPECT_UNKNOWN=6` (u2r) **PASS ok=1/0/0** unknown=6;
`canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** (the four SLANG-FENCED names
dispatched by no driver);
`InterfaceModPort` / `BlackParrotComplex` / `Earlgrey_0_1` **BY NAME** base ==
fresh.

## 3. The target and the design — reproduced to the unit

* `uhdm-cmp` golden vs **PRISTINE** Earlgrey/default: **48 lines**, head
  `hier_path: (flash_ctrl_i.rd) … id:90798 … line:129:13` — the briefed head,
  byte for byte.
* `uhdm-cmp` golden vs **PATCHED**: **596 lines**, head
  `named_begin: (work@padring.gen_mio_pads.gen_mio_input)`. **HEAD CLEARED.**
  Its LHS carries two `assignment` objects at `126:13-126:23` and
  `126:25-126:34` that our RHS lacks — R3 confirmed as a `vpiStmt` vector-size
  family, not a naming one.
* Dump line counts: golden **4823448**, pristine **4654903**, patched
  **4654959** — the pristine figure is r10earl36's landed line count, so this
  build reproduces the committed baseline.
* Whole-design `diff o.dump p.dump`: **16 removed / 72 added**, **27** ed-script
  change groups. (`diff -u` reports **8** hunks — see **F-7**.)
* **The 11 movers, cell for cell**: 5 `ref_obj → hier_path` at `flash_phy.sv`
  129/130/131/132/134, and 6 leaf-fullname stamps at `pinmux.sv`
  238/239/241/244/245/246. **Nothing else changed anywhere in 4.65 M lines.**
  Each of the 6 pinmux fullnames occurs **1× in golden, 1× in patched, 0× in
  pristine**; the target's whole subtree is byte-for-byte golden's print.
* **Per-shape, 3-way, indent preserved**: **61** distinct line shapes changed,
  **59** reach EXACT golden parity; `|vpiParent:` (deficit) 54551 → 54561 against
  golden's 56207, `|vpiActual:` (surplus) 59488 → 59498 against golden's 59376.
  `SUM |g−o| = 1836`, `SUM |g−p| = 1768`, **delta −68** — matching the
  whole-design multiset delta to the unit, so no line outside the 61 moved.
* **MULTISET distance vs golden**: pristine **309329** (238937 / 70392) →
  patched **309261** (238875 / 70386). **−68**, golden-only −62, ours-only −6.
* **Whole-design DEF-view HighConn census**: **34542** rows, of which **12733**
  DEF; distance to golden **128 → 106 row-sides**.
* **DESIGN-SCALE INVARIANT, re-derived with MY OWN counter** (`inv37.py`, not
  the implementer's query):

  | | golden | pristine | patched |
  |---|---|---|---|
  | DEF port HighConn that is a `ref_obj` with a DOTTED `vpiName` | **0** | **5** | **0** |
  | DEF port HighConn `hier_path` whose LAST element is a fullname-less `ref_obj` | **0** | **6** | **0** |

  Confirmed, and the 5 + 6 are exactly the 11 movers.
* **R1's population** re-counted off the residual DEF census: the 53 still-wrong
  DEF rows are **27 `bit_select` + 15 `hier_path` + 10 `ref_obj` + 1 `constant`**
  — R1's "15 hier_path + 27 bit_select" is exact.

---

## FINDINGS

### F-1 — the FIXED/ok split of BOTH grids is wrong by 2 (MINOR)

Claimed a1 **FIXED 10 / ok 14**, a2 **FIXED 18 / ok 16**. Measured:

```
diff <(grep ^DEF cen_<arm>_gold.txt) <(grep ^DEF cen_<arm>_{pris,pat}.txt)
a1_pact  cells=24  gold-vs-pristine rows=8   gold-vs-patched rows=0
a2_fence cells=35  gold-vs-pristine rows=17  gold-vs-patched rows=1
```

so **a1 FIXED = 8, ok = 16**; **a2 FIXED = 16, ok = 18, STILL WRONG = 1**.
The cell totals (24, 35), STILL WRONG (0, 1) and **REGRESSIONS (0, 0)** are
exact; only the split is off. The a1 table lists exactly **8** FIXED marks — its
own summary line contradicts it. The a2 table under-lists two cells that DO move
(`f_ifsig` `addr_i` and `f_ifloc` `addr_i`, both `pin_i.addr`) while its summary
over-counts by two. Net effect on the verdict: none — 24 cells fixed, not 28.

### F-2 — the "named vs positional" axis is an EMPTY PRODUCT (MODERATE)

`README.md` §0 states the rule is indifferent to "named or positional", and
a1_pact.sv's header lists `conn form: named / positional` as a crossed axis
(`i_gp` line 61, `i_pp` line 101 — 6 written port connections).

**Golden emits no `ref_module` for a positionally-connected instance at all.**
`grep -n "ref_module" g.dump` lists `i_pn i_pl i_pnst i_gn i_gl i_gnst i_gps
i_gop i_gw` and never `i_gp` / `i_pp`; both appear ONLY under `module_inst`
(ELAB). The census therefore has **0 DEF rows** for them on every side, which is
also why a1 has 24 DEF cells and not 30.

Consequence: the positional axis is neither confirmed nor refuted at the position
the law governs. It should be struck from the law statement, or measured
somewhere it produces a cell.

### F-3 — the leaf-fullname clause is REFUTED on a `::`-qualified dotted actual (MODERATE, new over-fire, zero corpus reach)

`a2_fence.sv`'s `f_pkgc` fences `::` with **no dot**; the gate's dot conjunct
therefore never fenced `::` **with** a dot, and `pred37.py`'s `DOTTED` regex
cannot match one either. I built the cell (`v1_stamp.sv`, `i_vpk`,
`.rd_i(q39::CFG.rd)` in a genvar block):

| | GOLDEN | PRISTINE | PATCHED |
|---|---|---|---|
| kind | `hier_path` | `ref_obj` | `hier_path` ✓ |
| hier_path `vpiName` | **empty** | — | `q39::CFG.rd` ✗ |
| base element span | `47:13-47:18` (`q39::`) | — | `47:13-47:21` ✗ |
| leaf `ref_obj` fullname | **NONE** | — | `work@top39.gen_v.i_vpk.rd_i.rd` ✗ |

The patch **advances** the cell (the KIND now matches, and pristine's doubled
`ref_obj` is gone), but the law's clause *"the LAST element, WHEN IT IS A
`ref_obj`, carries `<scope>.<instance>.<formal>.<component>`"* is **false here**:
golden abstains. Zero corpus reach (the 11-object fence closes and every gate is
green), so this is a law-SCOPE defect, not a regression. The law statement must
say `::`-qualified bases are a different rule, in both directions.

### F-4 — an ESCAPED IDENTIFIER containing a dot is a measured REGRESSION, and refutes the "NARROW and MONOTONE" claim (MODERATE, zero corpus reach)

The ops rules require escaped identifiers on any name-reading gate. This gate
reads raw TEXT for `'.'` and the `ScopedName` arm then SPLITS the raw text on
`'.'`. Neither arm contains an escaped identifier and the README never mentions
one. `v2_esc.sv`, `.rd_i(\pin.i .rd)` in a genvar block:

* **GOLDEN**: `hier_path` `pin.i.rd`, **TWO** elements — `ref_obj(pin.i)` (the
  escaped name kept whole) + `ref_obj(work@top40.gen_e.i_esc.rd_i.rd)`.
* **PRISTINE**: one `ref_obj` named `\pin.i .rd` — wrong kind, one object.
* **PATCHED**: `hier_path` with **THREE** elements — `ref_obj(\pin)`,
  `ref_obj(i )`, `ref_obj(…rd_i.rd)`. Two of the three are **fabricated**: no
  such path components exist in golden or in pristine.

Arm distance to golden (`msdist.sh`, matched workdirs): **122 → 128, +6**. It is
the only regression measured anywhere in this verification. It also refutes §0's
*"The change is NARROW and MONOTONE ... it can only replace ONE object at ONE slot
with the hier_path the ELAB emitter already builds"* — here it mints an object
the ELAB emitter does not build. Corpus reach is zero (0 extra movers in 2311
databases), so no gate sees it; it is a residue that must be recorded before a
later pass cites the monotonicity argument.

### F-5 — F4 is REFUTED: the rejected alternative was built and does NOT break `f_selint` / `f_mparr` (MODERATE)

The README nominates this as "the cheapest way to attack this pass" and predicts
the alternative breaks. I built it: call site 1 wrapped in
`syntaxRefPrefix = branchPrefix + "." + iname + "." + formal` with the post-stamp
**deleted** (`/tmp/v37alt`, md5 `271244ba73ab4d81630e30aee4e62312`).

**Its DEF census on a1 AND a2 is byte-identical to the shipped patch's.**
`f_selint` and `f_mparr` do not move; the only a2 row still wrong is `f_pkgc`, the
same one. The stated mechanism is wrong: a `hier_path` ELEMENT `bit_select` takes
its fullname from `dottedSoFar` / `spaceOps(pname)` (`TypeEmit.cpp` ~12690,
~12787, ~12843), **not** from `syntaxRefPrefix`; and the pinmux index refs' scoped
fullnames come from UHDM's lazy `ComputeFullName` off the parent chain, which
yields the same string either way.

**The post-stamp is still the right choice** — for a reason the README does not
give: it also overrides the `genVarBaseEmitted` raw-dotted-leaf branch
(`TypeEmit.cpp` ~12986), which the prefix-set version leaves standing. See F-6.
Per-arm distance on my probe: shipped **339**, alternative **347**.

### F-6 — F5's cell never reaches the code path F5 names; I built the one that does (MODERATE)

F5 argues `f_mparr` (`arr_if[b].mp`) refutes `genVarBaseEmitted`'s raw-leaf law.
That cell never sets the flag: a 2-part path whose left is an
`IdentifierSelectName` sets `baseSelSyn`, so the SYMBOLIC-base arm fires and
`genVarBaseEmitted` stays false — its own signature (the hier_path end re-anchored
to the base element) is absent from BOTH sides at `132:26`. The flag needs **≥3
parts with a selected base**, which no cell in either arm has.

I built it (`v1_stamp.sv`, `i_vg3`, `.rd_i(darr_i[b].mid.inner.rd)`):

* **F5's CONCLUSION SURVIVES** — golden's leaf is
  `work@top39.gen_v.i_vg3.rd_i.rd`, the child-port scoping, not the raw text;
  pristine wrote the raw `darr_i[b].mid.inner.rd`; the shipped patch matches
  golden and the F-5 alternative does not.
* **A RESIDUE THE README DOES NOT LIST**: on that shape the hier_path SPAN is
  re-anchored to the base element (`35:13-35:19`) where golden keeps the whole
  path (`35:13-35:35`). Pre-existing (`genVarBaseEmitted`'s re-anchor), untouched,
  and now the ONLY error left on the cell.

### F-7 — "27 hunks" is the plain-`diff` group count, not a unified-hunk count (MINOR)

`diff o.dump p.dump | grep -cE '^[0-9]'` = **27**; `diff -u` reports **8**
hunks. `16 removed / 72 added` reproduce exactly either way. Nomenclature only.

### F-8 — GATE 5 surelog reports **2** movers here, not 1; the second is the documented flake, ATTRIBUTED (ENVIRONMENTAL)

```
MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm   sizes 49937235 vs 49936155  <- THE TARGET
MOVER ./default/Scoreboard-59431470/slang.uhdm     sizes 11133116 vs 11133116  <- same size
MOVERS: 2 / 953 ; SELFCHECK 952/953 ; SELFCHECK1 3
```

Attribution, 3 single-test runs per binary:

```
patched   07cb55be13cf  07cb55be13cf  07cb55be13cf
pristine  07cb55be13cf  0d9fd494d189  0d9fd494d189
```

The **pristine binary alone** emits two different md5s at the identical size, and
the patched binary's md5 is one of the pristine binary's own two. Documented
multi-stable emitter nondeterminism, not this patch. `Scoreboard`'s CSV row is
byte-identical to baseline (GATE 4, 0 differing rows). **1 real mover in 2311
databases, and it is the target** — the claim holds; only "the flake did not
fire" is a property of the implementer's run, not reproducible.

### F-9 — `a2_fence.sv`'s own header mis-describes `f_hier` (MINOR)

The file header says `f_hier  a HIERARCHICAL read out of a SIBLING gen branch`.
The cell is `.rd_i(sib_w)` — a plain module-body wire. The README's table
describes it correctly ("a plain module wire, NO dot") and it does its job as the
dot conjunct's fence, but **no arm cell tests a cross-gen-branch hierarchical
read**, which the header claims is covered.

---

## RANKED RESIDUES (verifier's ordering)

1. **R1 (implementer's), CONFIRMED and re-counted** — the select-TAILED path leaf:
   **27 `bit_select` + 15 `hier_path`** of the 53 DEF rows still wrong on
   Earlgrey. Cheapest true extension; witness one index-position from `f_selint`.
2. **F-3** — `::`-with-a-dot: golden's hier_path is UNNAMED, its base element
   spans the qualifier only, and its leaf takes NO fullname. Narrow the law and
   fence the stamp.
3. **F-4** — escaped identifier containing a dot: the raw-text split fabricates
   path elements. The only measured regression (122 → 128 on its arm).
4. **F-6's span residue** — `genVarBaseEmitted` re-anchors the hier_path span to
   the base element where golden keeps the whole path; the last error on the
   ≥3-part genvar-base shape.
5. **R3 (implementer's), CONFIRMED** — the new head: golden emits two
   `assignment` objects for `logic unused_out, unused_oe;` at `padring.sv:126`
   and we emit none; a `vpiStmt` vector-size family.
6. **R2 (implementer's)** — `::`-with-no-dot folds to a constant in golden.
   Now clearly the *fifth* face of a rule whose *sixth* is F-3.
7. **R4 / R5 / R6 (implementer's)** — the three pre-existing a2 ELAB defects, the
   pre-existing `|vpiActual:` surplus (+10 here, stated not netted), and
   `pred37.py`'s 200× over-count. All confirmed as stated; `pred37.py` is
   additionally blind to F-3's shape.

## WHAT WOULD HAVE CAUGHT THE FINDINGS

F-2/F-3/F-4/F-6 are all the same gap: the fence arm was built from the axes the
TARGET has, not from the axes the *emitter* has. The gate reads (i) a syntax
KIND that also covers `::`, and (ii) raw SOURCE TEXT that an escaped identifier
can contain a `.` in; the arm it feeds SPLITS that text and has a
`genVarBaseEmitted` branch the post-stamp overrides. One cell per code branch
downstream of the gate — `pkg::X.m`, `\a.b .m`, a ≥3-part genvar-base path —
would have produced all four, and three of them are one line of SystemVerilog.

## REPRODUCTION

```sh
git worktree add /tmp/wt_v37 45716d3 && cd /tmp/wt_v37 && git apply /tmp/r10earl37.patch
~/.local/bin/cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && ~/.local/bin/cmake --build build -j6
# grid + verifier probes (all four sources are in this directory / §F-3,F-4,F-6 above)
SLANG_UHDM=/tmp/wt_v37/build/slang-uhdm ./arm37.sh a1_pact.sv  /tmp/v37arm_a1_pact_pat
SLANG_UHDM=/tmp/wt_v37/build/slang-uhdm ./arm37.sh a2_fence.sv /tmp/v37arm_a2_fence_pat
python3 pactcen.py <dump> | grep '^DEF'      # per-cell census, then diff gold vs {pris,pat}
# design scale
python3 pactcen.py /tmp/v37eg/{g,o,p}.dump   # 34542 rows each; 12733 DEF
bash ../r10uvm55repro/msdist.sh /tmp/v37eg/g.dump /tmp/v37eg/{o,p}.dump   # 309329 -> 309261
diff /tmp/v37eg/o.dump /tmp/v37eg/p.dump     # 16 removed / 72 added / 27 groups
```
