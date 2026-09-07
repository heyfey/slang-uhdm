# r10vearl117 — the ADVERSARIAL VERIFICATION of r10earl117 (§ `patCaGenIdxBareBitSel117`) — **ACCEPT, UNCHANGED**

**MEASUREMENT ONLY.**  Nothing in this directory is an acceptance judge.  The
official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for every
number below.  slang was **NOT** patched; `results/*.csv` were **READ ONLY**;
nothing was promoted; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests
were never dispatched.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| VERDICT | **ACCEPT.**  The implementer's patch is shipped UNCHANGED — no verifier fix was needed and none was made |
| what was reproduced | every headline number, on binaries this verifier built in its own worktrees at `cc77bafe`, including all THREE binary md5s bit-for-bit |
| what was attacked | four NEW adversarial arms (37 cells), 8 arm/views, over the call-shape, carrier, carrier-scope and index-form axes the pass's own grid does not spell |
| pristine-right → patched-wrong | **ZERO**, in every arm, every view, every family, and on the whole corpus |
| the one thing the attack DID find | fence (f) is load-bearing on **four MORE faces** than the pass measured — this verifier's own no-fence cut breaks them, the shipped cut holds all four (§3) |
| residues found by this verifier | R-V1 (a parameter-array carrier: byte-only, judge-invisible, zero corpus population) — §4 |

---

## 1. THE HEADLINE NUMBERS, REPRODUCED BIT-FOR-BIT

Everything in `VGATES.r10vearl117.txt`, run end to end on binaries this verifier
built with `cmake --build build -j 2` in fresh `git worktree add ... cc77bafe`
trees, md5'd separately and frozen `chmod 555` before any sweep:

* **pristine `fdcdcfce45ae27fbcb3b9fd8560cfa7c`, patched `bedbfc2053724475e877f555bd149bc3`** — both bit-identical to the implementer's.
* a THIRD binary, built by this verifier by neutering
  § `patCaGenIdxNeverInUserCallArg112v`'s test itself, came out
  **`88732eb14e3fd1c39783baca886632a4`** — also bit-identical to the
  implementer's convicted no-fence cut.
* goldens **23/0 on both**, `/bin/false` **0/23**.
* u2r **679/50/2 in both modes on both binaries**; `ct8rows` PASS ×3;
  `SELFCHECK=1 byteverify` **MOVERS 0/1358**.
* surelog `--mode both`, 1588 rows: `ct8rows` against the committed baseline
  **and** against this verifier's own pristine sweep each report **exactly one
  differing row**, the same one, and it is the CONVERSION:

```
< Earlgrey_0_1,testflags,CMP_NOTEQUAL,decompile:,,
> Earlgrey_0_1,testflags,CMP_EQUAL,,,
```

* `SELFCHECK=1 byteverify` on surelog: **MOVERS 3/956** — the two Earlgrey
  databases the pass predicted BY NAME, plus `Scoreboard/default` whose
  order-blind whole-dump diff this verifier measured at **0 lines** (118 RAW),
  i.e. the documented parallel-parse coin.
* the two real movers, attributed by this verifier's own path-normalised
  ORDER-BLIND diff of the 4.7-million-line dumps: **58 `ref_obj
  (…gen_idrouting[N].i)` blocks removed and 58 `constant` blocks added, per
  database, and NOT ONE OTHER LINE SHAPE** (`testflags` carries the extra
  `|vpiActual:` / `\_parameter:` pair because there the reference is bound).
  58 is exactly the predicted number.
* **cmds.txt audited file by file**: 5962 `slang:` lines across both sweeps and
  both corpora, every one naming the correct frozen binary, zero naming the
  main tree.
* row heads, canaries (ok=51 changed=**1**, the conversion), ctcan2 ×2,
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`, protected DBs SAME with
  both brief pins exact (`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`).
* the head itself: pristine `Earlgrey_0_1/testflags` is 36 cmp lines / ONE head,
  golden a `constant … |vpiDecompile:0 |vpiSize:64 |UINT:0 |vpiConstType:9`
  parented at `\_bit_select (…gen_idrouting[0].hfifo_rspvalid)` at
  `tlul_socket_m1.sv:241:32`; patched is a **0-byte** cmp log, `uhdm-cmp` rc 0.
  `Earlgrey_0_1/default` keeps its 31-line `LHS: <null>` head against our
  `logic_var (…u_pinmux.gen_mio_periph_in[0].data_mux)` at `pinmux.sv:157:39`,
  and its cmp log is byte-identical across the patch — R0 confirmed as read,
  and confirmed as a POPULATION question (we emit an object golden does not),
  not a rendering one.
* the pass's own four arms, re-run by this verifier: **AWAY 0 / MOVEDWRONG 0 in
  all eight arm/views**, TO-GOLDEN 3+7+4+2 = **16 keys per view**,
  SPELLED_BROKEN 0 with 33 spelled keys per view held (34 with `q4_head116`).
  `VARMS_IMPL.r10vearl117.txt`.

---

## 2. THE ATTACK — FOUR NEW ARMS, DIFFERENT NAMES, LETTERS, WIDTHS AND
## UNROLLING COUNTS

An arm that AGREES is not an arm that TESTS.  All four arms produce a NON-EMPTY
pristine-vs-patched dump diff in both views (`VGRID.r10vearl117.txt`), so every
one of them reaches the law.  Scored with the pass's own `sig117` / `armtab117`
/ `spelled117`, plus this verifier's `vgrid117.sh`, which additionally takes a
path-normalised WHOLE-DUMP diff so a regression OUTSIDE the select-bound census
family cannot hide.

**Verdict across all 8 arm/views: `AWAY 0`, `SPELLED_BROKEN 0`,
`SPELLED_MOVEDWRONG 0`, KEYSET IDENTICAL (no span moved) — and the official
`uhdm-cmp` log is BYTE-IDENTICAL between the two binaries on every arm and
view.**  The judge sees no change in either direction on any adversarial arm.

### `va1_calls117` — the CALL-SHAPE faces (§ 112's fence MUST HOLD)

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| n1 | `vp117::pkgfn({3'b0,BUS[j]})` — a PACKAGE-SCOPED user call | (no select cell) | `ref_obj j` | **unchanged** |
| n2 | `mixfn(.a({3'b0,BUS[j]}))` — a NAMED argument | SPELLS | spells | **spells — fence held** |
| n3 | `din[0] ? mixfn(…) : 4'h0` — user call in a BRANCH | SPELLS | spells | **spells — fence held** |
| n4 | `4'(mixfn(…))` — user call inside a CAST | SPELLS | spells | **spells — fence held** |
| n7 | `mixfn($unsigned(mixfn(…)))` — THREE deep | SPELLS | spells | **spells — fence held** |
| n5 | `{2{BUS[j], BUS[j]}}` — a REPLICATION operand (2 cells) | folds | spells | **golden's** |
| n6 | `{3'b0, BUS[j]}` — plain concat (control) | folds | spells | **golden's** |
| n8 | `$unsigned({3'b0,BUS[j]}) ^ mixfn(4'h1)` — SYSTEM arg | folds | spells | **golden's** |
| n9 | `{<<4{{3'b0, BUS[j]}}}` — a STREAMING operand | agrees | agrees | **unchanged** |

### `va2_carrier117` — the CARRIER faces the pass's `p1_car117` does not spell

| cell | carrier | golden | patched |
|---|---|---|---|
| b1 | a WHOLE unpacked-array element `UMEM[j]` | folds | **golden's** |
| b2 | a bit-select on a **WIRE NET** `WNET[j]` (the head's carrier is a `logic_var`) | folds | **golden's** |
| b5/b9 | 2-D UNPACKED `U2[j][0]` / `U2[0][j]` (`var_select` dims) | folds | unchanged — the pass's residue R1, re-measured |
| b6 | the same bit-select in a pattern **NESTED in a pattern** (depth 2) | folds | **golden's** (2 cells) |
| b7 | the head shape itself (control) | folds | **golden's** |
| b8 | a HIERARCHICAL select `gen_other[0].osig[j]` in a pattern value | folds | unchanged (a `hier_path` carrier — the pass's R5 neighbourhood) |
| b10 | the same carrier in the same gen scope with **NO pattern** (control) | spells | **spells — MUST-STAY held** |
| b3/b4 | a module-localparam array `MPARR[j]` / a gen-scope localparam array `LARR[j]` | golden has **no select object at all** | see §4, residue R-V1 |

### `va3_scope117` — the CARRIER-SCOPE faces (gate (a) `inGenScopeCa67`)

| cell | carrier scope | golden | patched |
|---|---|---|---|
| t1 | a cont_assign inside a GENERATE **CASE** arm | folds | **golden's** |
| t9 | a cont_assign in the **ELSE** branch of a generate-if | folds | **golden's** |
| t7 | a NESTED generate, the pattern indexed by the **OUTER** genvar *and* by the inner one | folds | **golden's** (both) |
| t10 | a GEN-LOCAL target written by the pattern | folds | **golden's** |
| t5 | the CHILD module's OWN genvar, in a child instantiated inside a generate | folds | **golden's** |
| t3 | a pattern in an **`always_latch`** | folds | unchanged — the pass's residue R3, re-measured on a new procedural carrier |
| t2 | a pattern in an **`always_ff`** | agrees | **unchanged** |
| t6 | a `for`-loop VARIABLE (not a genvar) index in an `always_comb` | agrees | **unchanged** |
| t8 | a pattern in a MODULE-SCOPE cont_assign, generate **depth 0** | **SPELLS** `ref_obj SEL` | **spells — MUST-STAY held** |
| t4 | a pattern in an INSTANCE **PORT CONNECTION** inside a generate | — | **untouched: the whole-dump diff contains not one line at that source line** |

### `va4_index117` — the INDEX-FORM faces (earl113's namesake axis)

| cell | index | golden | patched |
|---|---|---|---|
| u1 | the genvar **DECLARED OUTSIDE the loop** (`genvar i; for (i = …)`) | `constant #64#9` | **golden's** — `isFromGenvar()` holds for that declaration form too |
| u8 | the bare genvar (control) | `constant #64#9` | **golden's** |
| u2 | a gen-scope localparam **initialised FROM the genvar** (`localparam int LX = i`) | `constant #**32**#9` | unchanged — and CORRECTLY so: folding it at width 64 would be a NEW wrong answer |
| u3 | a plain gen-scope localparam `LY` | `constant 1#32#9` | unchanged |
| u4/u5 | **UNSIZED** constants `UBUS['d2]`, `UBUS['h1]` | agree | **unchanged** |
| u6 | an explicit CAST of the genvar `int'(i)` | golden `constant #64#9` (empty decompile) | unchanged — `stripImplicitConv` does not strip an explicit cast |
| u7 | a module parameter index | already folded by an earlier law | **unchanged BY CONSTRUCTION** (the still-a-`ref_obj` test) |
| u9 | a genvar in a **PART-SELECT bound** in the same gen scope | SPELLS | **spells — earl110's floor held** |

---

## 3. WHAT THE ATTACK FOUND: FENCE (f) IS LOAD-BEARING ON FOUR **MORE** FACES

This verifier built the no-fence cut ITSELF (`if (false && callArgDepth -
sysCallArgDepth22 != 0)`), got the same md5 as the implementer's
(`88732eb1…`), and scored it on `va1_calls117` — an arm the implementer never
saw (`VNOFENCE.r10vearl117.txt`):

```
  shipped cut,  va1_calls117, plain and elab:  AWAY 0  SPELLED_BROKEN 0
  NO-FENCE cut, va1_calls117, plain and elab:  AWAY 4  SPELLED_BROKEN 4
      AWAY 58:31-58:32  mixfn(.a(...))            named argument
      AWAY 59:38-59:39  cond ? mixfn(...) : ...   user call in a ternary BRANCH
      AWAY 60:31-60:32  4'(mixfn(...))            user call inside a CAST
      AWAY 65:44-65:45  mixfn($unsigned(mixfn())) user in system in user
```

**Four pristine-RIGHT → cut-WRONG cells per view on legal SV, on four call
shapes beyond the three the pass measured**, and the shipped cut scores 0 on
all four.  Fence (f) is not merely inherited paperwork at the new site: it is
the only thing standing between this law and eight wrong cells per view on
ordinary SystemVerilog.  It **MUST STAY**.

---

## 4. THE ONE MEASURED FINDING — residue R-V1, byte-only and judge-invisible

`va2_carrier117` cells b3/b4 (`MPARR[j]`, `LARR[j]` — a parameter-array element
read indexed by the genvar, inside a pattern member value in a gen-scope
cont_assign) score `MOVEDWRONG` in the census, and the reason is that **golden
has no select object there at all**: Surelog constant-folds a parameter-array
element read into a single `constant`, so its census row does not exist.  We
emit a `bit_select` on BOTH binaries; the patch only changes that
already-divergent object's index from `ref_obj j` to `constant`.

Consequences, measured rather than argued:

* the divergence is at the OWNER (`bit_select` vs `constant`), which
  `BaseClass::Compare` decides on `VpiType` before ever reading an index — the
  index rendering is unreachable to the judge in that cell;
* the arm's official `uhdm-cmp` log is **byte-identical** between the two
  binaries, in both views;
* corpus population is **ZERO**: `byteverify` moved exactly three databases in
  956 and two of them are attributed line for line to the head's own 58 cells,
  so no cell of this shape moved anywhere in either corpus.

It is a byte-level residue on a pre-existing structural divergence, not a
regression, and it does not block the landing.  Stated so the next pass on the
parameter-array carrier knows it is there.

---

## 5. THE BOUNDARY, RE-RUN INDEPENDENTLY AND WIDENED

This verifier re-ran the wide boundary from scratch on its own binaries and its
own staging paths, over the probe tree **including its own four new arms**:

```
LISTED=5154  FENCED_REMOVED=0
PROCESSED=5154 identical=9896 DIFFERING=18 no_output=394
PROCESSED==LISTED (5154)
rc by side:  A/0 9523  A/3 378  A/4 391  A/139 16
             B/0 9523  B/3 378  B/4 391  B/139 16      IDENTICAL per side
```

The 18 differing file/views are, in full: this verifier's four arms (8), the
pass's four arms (8), and `r10earl116repro/q4_head116.sv` (2).  **Nothing else
among 5145 other probe sources moved a byte on either binary** — which is
r10earl110–116's arms, and every other landed pass's arms, re-run at the
strictest resolution there is.

`q4_head116` re-scored by this verifier: **1 TO-GOLDEN cell (`48:44-48:45
bit_select rspvalid_i`, `ref_obj i` → `constant 0/1/2 #64#9`), AWAY 0,
SPELLED_BROKEN 0, and its own `uhdm-cmp` log byte-identical.**  It carries this
law's shape by construction and moves the right way.

r10earl116's OWN family census (`sig116`) on all ten flagged arm/views and on
**both moving Earlgrey databases** (132 rows each): **byte-identical pristine
vs patched everywhere.**  § `patCaFlatLhsWholeName116`'s split gate is exactly
where it was left.

---

## 6. FILES

| file | what it is |
|---|---|
| `va1_calls117.sv` | THE CALL-SHAPE ATTACK: package-scoped call, named argument, ternary branch, cast wrapper, three-deep nesting, replication, streaming, plain concat |
| `va2_carrier117.sv` | THE CARRIER ATTACK: whole unpacked element, wire net, parameter arrays, 2-D unpacked, depth-2 nested pattern, hierarchical select, and the no-pattern control |
| `va3_scope117.sv` | THE CARRIER-SCOPE ATTACK: generate case, generate-if else, nested generate with the OUTER genvar, gen-local target, child module's own genvar, `always_ff` / `always_latch` / `always_comb` loop variable, module-scope depth 0, instance port connection |
| `va4_index117.sv` | THE INDEX-FORM ATTACK: genvar declared outside the loop, localparam-from-genvar, plain localparam, unsized constants, explicit cast, module parameter, part-select bound |
| `vgrid117.sh` | the adversarial grid driver: three databases per arm/view, the official `uhdm-cmp` on both of ours, `sig117` on all three, AND a path-normalised WHOLE-DUMP diff so a regression outside the census family cannot hide.  rc recorded per producer, children `</dev/null`, `CENRC` asserted |
| `VGRID.r10vearl117.txt` | the per-arm run table (rc, cmp lines/heads, dump-diff size) |
| `VARMTAB.r10vearl117.txt` | the per-CELL table for all four arms, both views |
| `VSPELLED.r10vearl117.txt` | the MUST-STAY column, scored on its own |
| `VNOFENCE.r10vearl117.txt` | the no-fence cut this verifier built, and the four AWAY cells per view that convict it |
| `VARMS_IMPL.r10vearl117.txt` | the PASS's own four arms, re-scored by this verifier |
| `VATTRIB_arms.r10vearl117.txt` | order-blind dump-diff attribution for every arm this verifier ran, including `q4_head116` |
| `VATTRIB_Earlgrey_testflags.txt` | the order-blind attribution of the `testflags` corpus mover (58 in, 58 out, nothing else) |
| `VCT8_sl_vs_baseline.txt`, `VCT8_sl_vs_pristine.txt` | the one differing corpus row, against the committed baseline AND against this verifier's own pristine sweep |
| `VHEAD_*_Earlgrey_*.cmp` | the official `uhdm-cmp` output on the head row before and after (the `testflags` AFTER file is EMPTY on purpose) |
| `VBOUNDARY.*` | the independently re-run wide boundary over 5154 probe sources |
| `VGATES.r10vearl117.txt` | every gate this verifier ran, in order, with its output |
