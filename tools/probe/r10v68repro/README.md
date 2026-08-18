# r10v68 — ADVERSARIAL VERIFICATION of r10earl68 (§ genvarWholeCaRhsFold68)

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number in
`tools/probe/r10earl68repro/README.md` reproduces bit-for-bit from an
independent build.  The LAW is right; its SIZE clause was **incomplete** and
moved **four pristine-RIGHT distance-0 cells AWAY from golden** on legal
SystemVerilog that neither corpus contains.  The fix is in this patch
(`src/ModuleEmit.cpp`, `caLhsAdjustSize68`), it changes **nothing** on either
corpus (byteverify FIXED vs shipped-patched: **0/1358 u2r, 0/956 surelog**) and
it leaves Earlgrey **byte-identical** to the shipped patched binary in both
modes — i.e. the pass's whole result is preserved and only the out-of-corpus
regression is removed.

Binaries, all built here, `-j 2`, frozen at `555` before any sweep:

| binary | md5 |
|---|---|
| pristine `3175257` | `ce3e5a94c3727c249cad47a83ac70a62` — **matches the claim** |
| shipped `r10earl68.patch` | `54adbbaef787ad399de94ddbb9439f6d` — **matches the claim** |
| this `r10earl68.verified.patch` | `d0fe852735e78cc9b8e560755496313e` |

---

## 1. Reproduction of every headline claim (shipped patch)

| claim | reproduced |
|---|---|
| pristine md5 `ce3e5a94…`, patched `54adbbae…` | **YES**, both rebuilt from scratch |
| patch applies clean on FRESH `3175257`, surface = `src/ModuleEmit.cpp` + `r10earl68repro/` | **YES** (`git apply -3` rc 0; 30 files; 0 fenced-name hits; no `results/*.csv`) |
| `+81/-8` in two files | **NO — it is `+99/-3` in ONE file** (cosmetic; README corrected) |
| goldens 23 PASS / 0 FAIL on both binaries, `/bin/false` 0/23 | **YES** |
| u2r both modes both binaries 679 / 50 / 2 | **YES** |
| `ct8rows` u2r vs committed baseline and vs pristine sweep, both modes | **PASS, 0 differing rows** (status AND dump) |
| `byteverify` u2r `MOVERS 0/1358`, selfcheck 1357/1358 | **YES** |
| surelog `--mode both` histogram identical to pristine (470/466 CMP_EQUAL, 11/9 NE) | **YES** |
| `ct8rows` surelog vs committed baseline and vs pristine sweep | **PASS, 0 differing rows**, both modes |
| `byteverify` surelog `MOVERS 3/956` | **YES — but the third mover is `SeqDriver`/testflags, not `Scoreboard`/default** (§4) |
| Earlgrey both modes 32 → 216 lines, 1 head each | **YES** |
| the two BEFORE logs byte-identical, the two AFTER logs byte-identical | **YES**, and byte-identical to the committed `HEAD_R0_{BEFORE,AFTER}_*.cmp` (`710148f51aa2` / `3dced0faef87`) |
| whole-design census 89 TO-GOLDEN / 0 AWAY / 0 MOVED-WRONG, 178 lines per mode | **YES**, both modes (default 163,641 cells; testflags 160,598) |
| calibration 0 differing / **162,259**, golden re-read byte-identical | **YES** |
| arm scores §5 (280/210/29, 280/131/29, 176/147/27, 176/109/21, 140/111/27, 140/83/24) | **YES**, all six, 0 AWAY / 0 MOVED-WRONG |
| corpus fence scan over 2,314 pristine DBs, **33** databases | **NO — 51** (41 CAND, 12 FOLD, 2 both); the FOLD list also misses `FuncBindGen` |
| canaries ok=52 / ok=8 changed=0; ctcan2 PASS/PASS; canaudit 29/0/0 | **YES** |
| protected DBs SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | **YES**, both modes |
| `rowheads`: only Earlgrey moved (SeqDriver 99202, SimpleUVM/Scoreboard 99106, MiniAmiq 99202, BuildUVMPkg 52, Rggen 683) | **YES** |
| WIDE boundary 3,101 `.sv`/`.v`; per-DIRECTORY boundary 1,407 dirs | **YES**, both counts exact (§5) |

`cmds.txt` audited BY BINARY PATH in every arm: 1458 u2r + 1523 surelog lines
per binary, every one a frozen `/tmp/v68_{pristine,patched,fixed}.bin`, **0**
references to any main-tree binary.  `SLANG_UHDM` exported explicitly per
binary; `GOLDEN_DEFER` unset; `results/*.csv` never written.  The 2 `rc=-11`
surelog rows are present on all three binaries — pre-existing.

---

## 2. BREAKING THE LAW — the four cells that moved AWAY from golden

Eleven new arms (`v1`–`v11`), Surelog golden vs pristine vs patched, scored by
a 3-way multiset join on the positional key with a **no-span, judge-fields-only
payload**, in BOTH views.  Ten arms are clean.  `v11_d0.sv` — the same
declarations at **distance 0, where the PRISTINE emitter already minted 64 and
therefore already agreed with golden** — convicts the size clause:

| Lhs declaration, distance 0 | golden | pristine | shipped patch | verified patch |
|---|---:|---:|---:|---:|
| module-level **implicit net** (`assign imp2 = i;`) | 64 | 64 ✓ | **1 ✗** | 64 ✓ |
| bare **`var bv;`** | 64 | 64 ✓ | **1 ✗** | 64 ✓ |
| **`shortreal`** | 64 | 64 ✓ | **32 ✗** | 64 ✓ |
| **`realtime`** | 64 | 64 ✓ | **32 ✗** | 64 ✓ |
| `real` | 32 | 64 ✗ | 32 ✓ | 32 ✓ |
| `logic l1;` | 1 | 64 ✗ | 1 ✓ | 1 ✓ |

`v11_d0` plain view, shipped patch: `AWAY-GOLDEN 4`; verified patch:
`AWAY-GOLDEN 0`.  Same in the elab view.  Across all eleven arms × two views
the shipped patch scores **18 AWAY-GOLDEN + 16 MOVED-WRONG**; the verified
patch scores **0 AWAY-GOLDEN + 6 MOVED-WRONG**, and those 6 are one
pre-existing NAMING residue, not a size (§6, R2).

**The decode, read out of the golden database, not guessed.**  `adjustSize`
returns immediately when `tps == nullptr`, so the constant keeps the Value's
64-bit encoding.  Surelog leaves exactly these declarations typespec-less, and
`uhdm-dump` of the arm goldens shows it directly:

* `real x;` → `real_var` **with** `vpiTypespec -> real_typespec`; UHDM
  `ExprEval::size` (templates/ExprEval.cpp:1304) gives **32**.
* `shortreal x;` → `short_real_var` with **NO `vpiTypespec` at all** → 64.
* `realtime x;` → `time_var` with a `time_typespec` → **64**.
* `var vv;` → `logic_net` with **no `vpiTypespec`** → 64, while `logic l1;`
  and `wire w1;` both carry a `logic_typespec` → 1 (a net's implicit type
  still spans its `wire` keyword).
* an implicit net minted from the assign → no typespec → 64.

This emitter had already decoded the same two bare-declaration cases for the
DEF/ELAB signal emitter (`implicitNet` at `ModuleEmit.cpp:908`, `bareImplicit`
/ `hasBareImplicitType` at `:360`/`:7229`) and the real-vs-shortreal typespec
split at `:7676`.  The fix REUSES those predicates rather than re-deriving
them, so there is one model in the file, not two.

`v7_flt68.sv` proves the floating split is about the KIND and not the
declaration order: one floating declaration per module, and a module with
`shortreal` declared before `real` — golden is 32 / 64 / 64 / (64, 32) in every
arrangement.

### Everything else the brief asked to break — all held

`v1_pos68` (0 AWAY / 0 MOVED-WRONG, both views) puts a genvar in every position
at distances 0/1/2 and scores each against golden:

| position | golden | ours after the patch |
|---|---|---|
| whole Rhs | constant, sized | **folded — the law** |
| `i+1`, `i*2`, `-i`, `~i`, `i&1`, `i==0` | golden folds the WHOLE Rhs | unchanged (STILL-WRONG, ranked R4 by the pass) |
| `i ? din : ~din` (a NET in the arms) | ref KEPT | ref KEPT ✓ |
| bit/array-select **index** `mem[i]` | ref KEPT (4,683/4,683 in Earlgrey) | ref KEPT ✓ — **rgg14 § genvarIdxFoldRerender14 intact** |
| ips **base** `wide[i +: 8]`, computed base `wide[i*8 +: 8]` | ref KEPT | ref KEPT ✓ |
| part-select **bounds** `wide[i+7 : i]` | refs KEPT on both bounds | KEPT ✓ |
| concat, replication | golden folds whole Rhs | unchanged ✓ |
| cast `W'(i)` | golden folds | unchanged ✓ |
| USER call arg `f68(i)`, NESTED `f68($clog2(i+2))` | ref KEPT | KEPT ✓ — **earl67's `callArgDepth - sysCallArgDepth22 == 0` fence intact** |
| SYSTEM call `$clog2(i+2)` | golden folds whole Rhs | unchanged ✓ |
| LHS index `mem[i] = din` | ref KEPT | KEPT ✓ |
| parenthesised `(i)` | golden FOLDS (same as bare) | folded ✓ |
| net-decl-assign `logic [7:0] nda0 = i;` | ref KEPT in the decl `Expr` | KEPT ✓ |
| procedural `always_comb` / `always @*` | not a cont_assign | untouched ✓ |
| range bound `logic [i:0]`, localparam init | unchanged | ✓ |
| port actual / High_conn (`v4_hc68`) | bare, indexed and operation actuals | **0 AWAY / 0 MOVED-WRONG — earl61/64/65/66 High_conn laws intact** |
| hier_path `read_buf[i].addr[FlashWordsW +: PageW]` (the new R0 family) | — | untouched ✓ |

`v3_nest68` (0 AWAY / 0 MOVED-WRONG): **three** nested genvars read at
distances 1/2/3, gen-if under gen-for under gen-if, **UNNAMED** blocks
(`genblk1`), **case-generate**, an interface gen scope at distance 2, 1..3
unrollings × **three** child instances, and module-parameter / package-parameter
/ real gen-localparam whole-Rhs negative controls — the generate-only walk
never takes a parameter (72 TO-GOLDEN plain, 43 elab).

`v8_ty68` (10/10 TO-GOLDEN): packed **union** 8, 2-D packed 32, typedef chain
12, `reg` 8, `wire signed` 8, parameterised width 6, interface-BODY variable
64, gen-local-in-interface 64.  `v5_enum68`: 3-bit enum-base target masks to 3.
`v2_lhs68`: 63 / 64 / 65 / 128-bit targets, `bit`, `signed`, `shortint`,
`longint`, `time`, packed struct 8 and 32, select Lhs kinds 64, interface
member Lhs 64 — and a **NEGATIVE genvar** (`for (genvar i = -3; i < 0; i++)`),
where the patch's mask reproduces golden's `sz 8 UINT:253/254/255` exactly.

---

## 3. The fix

`src/ModuleEmit.cpp`, `caLhsAdjustSize68` only (+28 lines over the shipped
patch).  Same gate, same call site; it only refuses to size a constant whose
Lhs declaration Surelog writes without a typespec, and splits the floating
kinds:

```
if (sym.kind == SymbolKind::Net && sym.as<NetSymbol>().isImplicit) return 64;
if (hasBareImplicitType(sym))                                      return 64;
if (canonical kind == FloatingType)
    return floatKind == FloatingType::Real ? 32 : 64;
```

---

## 4. The third surelog mover, named correctly

`byteverify` surelog reports 3/956 movers on both the shipped and the fixed
binary: `Earlgrey_0_1` default + testflags (the PREDICTED set) and
**`SeqDriver`/testflags** — *not* `Scoreboard`/default as the pass README says.
Attributed, not assumed:

* order-blind (sorted) dump diff **0 lines**, byte size identical, unsorted
  diff **40 lines**;
* those 40 lines are a swap of two `uvm_pkg` typespecs (`uvm_reg_addr_t` /
  `uvm_reg_data_t`) at dump line 1,816,341 of 1,817,381 — **inside the
  `weaklyReferenced` tail**, which starts at line 1,706,789 and is unreachable
  to the judge;
* `rowheads` gives `SeqDriver` 99202 lines / 1 head on pristine, shipped and
  fixed alike, and `ct8rows` PASSes the row;
* standalone (10 runs across the three binaries, from the test directory) the
  three binaries agree byte-for-byte; only under the sweep harness do the
  pristine and patched hashes split, stably (3/3 each way).

So the pass's own claim ("Scoreboard/default coin") is the right CLASS with the
wrong NAME: this family of UVM rows carries a judge-invisible list-order
instability, and which row shows it varies.  Independent proof it is not the
patch: the three per-directory boundary rows below produce **three different
hashes in three consecutive runs of the SAME pristine binary**.

---

## 5. Boundaries (fixed binary vs pristine, both views, both frozen)

Run from a COPY of `tools/probe` with **no path filter**, `.sv` **and** `.v`,
list on fd 3, children `</dev/null`, `PROCESSED` asserted, rc recorded per cell.

```
WIDE   (per FILE) : PROCESSED=3101 identical=5926 DIFFERING=6 no_output=270
PER-DIRECTORY     : PROCESSED=1407 identical=2574 DIFFERING=7 no_output=233
```

* WIDE's 6 = `r10earl68repro/a{1,2,3}_gv68|lhs68|bind68.sv` × 2 views — the
  pass's own arms, i.e. the **positive control that proves the gate can see**,
  and all three score 0 AWAY / 0 MOVED-WRONG against golden (§1).
* PER-DIRECTORY's 7 = `r10earl68repro` × 2 (same arms) plus **5 cells in
  `r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro`**, every one order-blind
  **0 lines** and every one a `vpiTaskFunc` package-list order flip — and the
  SAME pristine binary produces THREE DIFFERENT hashes in three consecutive
  runs of each, so they are nondeterministic, not movers.
* `rc=139` appears on `r10buvm8repro/v21shadow8.sv`,
  `r10buvm8repro/vshadowcells8/v21_s9.sv`, `r10uvm84repro`, `r10uvm92repro`
  and three `r10vrgg8repro/cells/v8_recurse*` — on **both** sides, i.e.
  pre-existing segfaults, not introduced.

---

## 6. Residues, ranked

* **R0 (unchanged):** the pass's own `PREDICT_R0.txt` head — Earlgrey both
  modes, `flash_phy_rd.sv:122:43`, golden re-renders a `hier_path`'s VpiName
  from its FOLDED indexed-part-select bounds (`read_buf[i].addr[7+:8]`) where
  we keep the source spelling.  Confirmed here: 216 cmp lines, 1 head, the two
  AFTER logs byte-identical, and identical under the verified patch.
* **R1:** golden's gen-block index for a **negative** genvar is the unsigned
  wrap (`g_neg[18446744073709551613]`); we name it `g_neg[-3]`.  Pre-existing
  (pristine identical), and the only reason 6 arm cells score MOVED-WRONG —
  their payloads match golden exactly.  A NAMING law, cheap and self-contained.
* **R2:** `real` sized 32 but `shortreal`/`realtime`/bare-`var`/implicit-net
  left at 64 is a *typespec-presence* rule, not a width rule.  Any future pass
  that sizes a folded constant from an Lhs must ask the same question; the
  predicate now lives in one place.
* **R3:** the pass's own ranked R1–R5 (the genvar hier-path index, 261 cells
  testflags-only; the operand folds; the ELAB High_conn remainder; the
  whole-Rhs reduces of concat/cast/localparam) are unchanged and re-measured
  here as STILL-WRONG, never MOVED-WRONG.

## 7. Instruments

`v1_pos68.sv` … `v11_d0.sv` (the eleven arms above), `vwide_v68.sh` /
`vdir_v68.sh` (the two boundaries, own STAGE, `.v` included, rc per cell),
`fencescan_v68.sh` (the corpus fence rerun), and the standard battery
(`canaries.sh`, `ctcan2.sh`, `canaudit.sh`).  Censuses and scoring reuse
`r10earl68repro/{tscen68.cpp,cen68.sh,nospan68.sh,score68.py,gvfence68.cpp}`
unchanged — MEASUREMENT ONLY; the official `uhdm-cmp` stays the judge.
