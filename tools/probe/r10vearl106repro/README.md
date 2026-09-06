# r10vearl106 — the ADVERSARIAL VERIFIER of r10earl106 (§ `genCaCastFoldAdjustSize106`)

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number in the implementer's report
reproduced **bit for bit** on binaries this verifier built itself, and the law's
decode holds on 8 new adversarial faces.  Two shapes made it **turn a
judge-EQUAL cell into a judge-UNEQUAL one**; both are fixed here, both fixes are
minimal and re-gated, and the fixed binary is a **strict improvement** on the
implementer's own arms (identical scores) as well as on the verifier's.

* BASE `143df9df`, branch `auto5h`.  Worktrees `/tmp/wt_v106` (patch + fixes),
  `/tmp/wt_v106pris` (pristine).
* Binaries, all frozen `chmod 555` before any sweep:
  `pristine 9793b8253cc81350201a215044061a4f`,
  `patched  72a6413dafd7567d87898e5f5731f470` (the implementer's, reproduced),
  `verified 9c74c1bad869163cfb2c091281cb08f8` (patch + the two fixes).
* `results/*.csv` READ ONLY.  `GOLDEN_DEFER` unset.  `slang` not patched.

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Built both binaries from scratch in fresh worktrees; `SLANG_UHDM` exported
explicitly per binary; **every** `cmds.txt` audited by binary PATH.

| the implementer claimed | this verifier measured |
|---|---|
| pristine md5 `9793b825…`, patched `72a6413d…` | **identical** |
| goldens 23 PASS / 0 FAIL; `/bin/false` 0 / 23 | **identical** |
| surelog status histogram 937/19/567/48/10/3/2/1/1 | **identical on both binaries** |
| surelog `ct8rows` vs committed AND vs own pristine | **PASS, 0 differing rows, no row converts** |
| u2r 679 / 50 / 2 both modes; `ct8rows` 0 rows | **identical** |
| u2r `byteverify` MOVERS 0 / 1358 | **identical**, PATH_SETS_IDENTICAL |
| surelog `byteverify` MOVERS 2 / 956 | **identical** — `testflags/Earlgrey_0_1` and `default/Scoreboard` |
| Scoreboard = the coin: 92 raw / **0** order-blind changed lines | **92 / 0**, to the line |
| Earlgrey testflags changed **5 lines of 6 715 900**, BODY 5 / TAIL 0 | **5 of 6 715 900**, the diff hunk is the single `padctrl.sv:39` constant at dump line 3 465 148, and the `_weaklyReferenced:` boundary is at 4 683 187 — **BODY 5 / TAIL 0** |
| heads 26/1 → 32/1 with a DIFFERENT head object | **identical**; pristine head is `constant id:1054135` (loc-less, dc 63, sz 8), patched head is `constant id:704546 157:14-157:16` under `operation 155:43-158:4` |
| every other head row unchanged | **identical** (SeqDriver 50/1, SimpleUVM 17/1, Scoreboard/default 95/1, MiniAmiq 106/1, BuildUVMPkg 106/1, Earlgrey/default 31/1, Rggen/default 0/0) |
| canaries `ok=52` / `ok=8` changed=0; ctcan2 PASS ×2; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **identical** |
| protected DBs byte-identical; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **identical** |
| the pass's own grid: AWAY 0 / MOVED-WRONG 0 / UNREACHABLE-CHANGED 0 on all 10 rows, `h1_head106` and `g1_home106` elab 13/1 → 0/0 | **identical, cell for cell** |

One evidence defect, not a measurement one: the committed `PREDICT_R0.txt:4`
names the patched binary as `5448452a3a47e4651dc22a61b81a0e17`, but the patch
builds `72a6413dafd7567d87898e5f5731f470` (which is what `README.md:16` and
`:411` say).  The prediction text is stale by one build; nothing else in it is.

---

## 2. WHAT BROKE — two shapes, one root cause each

### DEFECT 1 (the serious one) — the record key COLLIDES on a comma-list `assign`

`applyCaCastAdjust106` keys its record map on
`(gen-scope FULLNAME, cont_assign SPAN)` and fills it with `std::map::emplace`,
so the **first** record wins a key collision; the consumer then hands that width
to **every** cont_assign at the key.

The collision is reachable in plain legal SV.  In the **elaborated** view every
cont_assign of a COMMA-LIST `assign a = …, b = …;` carries the span of the
**whole statement** — measured, `va3_span106`:

```
DEF   \_cont_assign: , line:38:12, endln:38:37     (d4x)
      \_cont_assign: , line:38:39, endln:38:65     (d16x)     distinct
ELAB  \_cont_assign: , line:38:12, endln:38:65     (d4x)
      \_cont_assign: , line:38:12, endln:38:65     (d16x)      SAME KEY
```

The worst case is `va7_mix106` `m_mix`, which pairs a **binding** module-body Lhs
with a **non-binding GEN-LOCAL** Lhs in one comma list.  The gen-local one is
never recorded at all — `bindVariable` fails on it, and golden therefore leaves
it alone — yet it is re-encoded anyway:

```
assign f8x = P8'(6'h3F), locz = P8'(6'h3F);      // locz is gen-local

locz   golden    constant  LOC 26:46-26:65   vpiSize 64  UINT:63  NO decompile
       pristine  constant  LOC 26:46-26:65   vpiSize 64  UINT:63  NO decompile   <- JUDGE-EQUAL
       patched   constant  LOC-LESS          vpiSize  8  UINT:63  vpiDecompile 63 <- JUDGE-UNEQUAL
```

`constant::Compare` reads `VpiDecompile` first and `VpiSize` second and reads no
location at all, so this is **pristine-RIGHT → patched-WRONG on legal SV**.
`m_mix2` is the same thing with the list order reversed (`locy` first).
`m_mix3` / `va3_span106` `m_comma` / `m_comma2` are the all-binding version:
`h16x` golden `63 / 16`, patched `15 / 4`.

Scored by the pass's own `score106.py`: `va7_mix106` elab
**AWAY-GOLDEN 2, MOVED-WRONG 1**; `va3_span106` elab **MOVED-WRONG 2** and its
cmp line count rises 13 → 14.  Note the arms' *head* counts barely move — this
is exactly the corpus-invisible class the wide boundary exists for.

**THE FIX** — the Lhs NAME closes the key.  `caLhsAdjustBind106` hands back the
bound symbol's name, the record carries it, and the consumer reads the
elaborated `cont_assign`'s `Lhs()` `ref_obj` `VpiName()` to look the record up.
A cont_assign whose Lhs is not a plain `ref_obj` (a bit-select, a part-select, a
`hier_path`) never recorded a width and is now skipped outright, which is the
pristine answer and cannot regress.

### DEFECT 2 — a `time` Lhs is adjusted when golden does not adjust it

`caLhsAdjustBind106` accepts any integral Lhs by `getBitWidth()`.  slang makes
`time` a 64-bit integral, but Surelog's `adjustSize` does not size a `time_var`
— measured on golden, `va2_lhs106` `t_time`:

```
golden    constant  sz 64  UINT:63  NO decompile   LOC-LESS
pristine  constant  sz 64  UINT:63  NO decompile   LOCATED     <- JUDGE-EQUAL
patched   constant  sz 64  UINT:63  vpiDecompile 63 LOC-LESS   <- JUDGE-UNEQUAL
```

This is the integral twin of the fact r10v68 already decoded for the floating
kinds (`shortreal` / `realtime` get no typespec, so 64 survives), which this
pass's copy inherited only for floats.  Scored: `va2_lhs106` elab
**MOVED-WRONG 1** before, **0** after.

**THE FIX** — the `PredefinedIntegerType::Time` guard already used verbatim at
`src/ExprEmit.cpp:4119`.

`real` at 32 is **correct** and was left alone (golden `sz 32`, `va2_lhs106`
`t_real` TO-GOLDEN on both binaries).

---

## 3. THE ARMS (`va1`–`va7`, driver `gridv106.sh`, tops in `TOPS.txt`)

| arm | face |
|---|---|
| `va1_word106` | word-boundary Lhs widths 63 / 64 / 65 / 96 / 128 × literal vs parameter cast widths — the `getMask(w) = ~0 for w >= 64` law |
| `va2_lhs106` | the Lhs TYPE ZOO: packed struct (7), packed arrays (32 / 6), `int`, `integer`, `byte`, `shortint`, `longint`, `bit`, scalar `logic`, `logic signed`, **`time`**, `real`, `wire [7:0]`, `wire`, an enum cast |
| `va3_span106` | span-collision attack: a macro expanding to two assigns, two macro invocations on one line, and the **comma-list `assign`** (both orders) |
| `va4_cast106` | nested casts (4 spellings), concat / replication under a cast, sized and unsized literals with and without a cast, a cast of a parameter vs a literal, arithmetic and ternary operands, `8'(6'bzzzzzz)` |
| `va5_scope106` | reachability: a 3-iteration gen-FOR, one module instantiated twice with different widths, an **instance ARRAY** holding a gen scope, a module two levels down, an interface inside it, a module-body control |
| `va6_neg106` | negative and X/Z values, signed spellings, the full 64-bit patterns (`UINT:-1` vs `UINT:18446744073709551615`), and 5 NON-cast gen-scope controls that must not move |
| `va7_mix106` | **the pristine-right → patched-wrong witness** (defect 1) |

### GRID — patched (implementer's) vs verified (fixed), ELAB rows

| arm | patched | verified |
|---|---|---|
| `va1_word106` | 13/1 → **0/0**, TO-GOLDEN 10, AWAY 0 | same |
| `va2_lhs106` | 8/1, TO-GOLDEN 15, **MOVED-WRONG 1** | 8/1, TO-GOLDEN 15, **MOVED-WRONG 0** |
| `va3_span106` | 13/1 → **14/1**, TO-GOLDEN 8, **MOVED-WRONG 2** | 13/1 → **0/0**, TO-GOLDEN **10**, MOVED-WRONG 0 |
| `va4_cast106` | 17/1, TO-GOLDEN 10, AWAY 0 | same |
| `va5_scope106` | 13/1 → **0/0**, TO-GOLDEN 9, AWAY 0 | same |
| `va6_neg106` | 35/1, TO-GOLDEN 8, AWAY 0 | same |
| `va7_mix106` | 13/1, TO-GOLDEN 3, **AWAY-GOLDEN 2, MOVED-WRONG 1** | 13/1 → **0/0**, TO-GOLDEN **4**, **AWAY 0 / MOVED-WRONG 0** |

Every arm's PLAIN row is byte-identical between the binaries on both — the ELAB
fence holds.  `AWAY-GOLDEN 0 / MOVED-WRONG 0 / UNREACHABLE-CHANGED 0` on all 14
verified rows.

The implementer's own 10 grid rows score **identically** on the verified binary
(`h1_head106` and `g1_home106` elab 13/1 → 0/0, `g2` TO-GOLDEN 17, `g3` 16,
`g4` 2) — the fixes cost the law nothing.

r10earl104's two must-stay-EQUAL controls hold: `vb2_genfor` **0 cmp lines / 0
heads**, `vb4_instarr` **0 / 0**, on pristine and verified alike.

---

## 4. FACES THAT HELD (no fix needed)

* **word boundary** — 63 / 64 / 65 / 96 / 128 all TO-GOLDEN, `UNMOVED-BAD 0` on
  `va1_word106`; the `w >= 64 ? ~0 : (1<<w)-1` mask is `NumUtils::getMask`.
* **negative / full-range values** — `UINT:-1` and
  `UINT:18446744073709551615` land on the same pattern, as decoded; golden's
  `y_allf` is literally `18446744073709551615` and we reach it.
* **X / Z** — `8'(6'bzzzzzz)` / `6'bxxxxxx` / `6'b1z10x1` stay operations on
  both sides where golden does, and where golden folds (`y_mixed`) we follow.
* **DEF view** — never moves, on any arm, on either binary.
* **instance arrays** — `u_arr[0..2].gen_leaf.lv` ARE reached by the walk and
  are correct (`sz 8 / dc 63 / LOC-LESS`, SAME on golden and both binaries).
* **the non-cast gen-scope controls** — `n_lit` / `n_par` / `n_cat` / `n_ones` /
  `n_zero` are byte-identical patched vs pristine; the written-cast fence holds.
* **the width-1 mints** (r10earl55 territory) — `bit`, scalar `logic`, `wire`
  all give golden's `sz 1 / UINT:1 / dc "1"`.

---

## 5. FILES

| file | what |
|---|---|
| `va1_word106.sv` … `va7_mix106.sv` | the seven arms |
| `TOPS.txt` | the `-top` each arm needs (kept out of the `.sv` so the arms stay byte-stable for the wide boundary) |
| `gridv106.sh` | r10earl106's `grid106.sh` pointed at these arms |
| `score106.py`, `wide106.sh` | copied verbatim from `r10earl106repro` so this directory runs standalone |
| `GRID.r10v106.txt` | the grid on the implementer's patched binary AND on the verified binary |
| `GATES.r10v106.txt` | every gate, both binaries |
| `BOUNDARY_WIDE.*`, `BOUNDARY_ARMS.txt` | the wide boundary, verified vs pristine, and the three-way score of every differing cell |
| `ATTRIB.r10v106.txt` | the Earlgrey / Scoreboard mover attribution |

**DIRECTORY NAME**: `tools/probe/r10v106repro` is ALREADY TAKEN at `143df9df` —
it is the UVM-106 verifier's directory, committed at `70dd1c0c`.  This
verification lives in `r10vearl106repro`, matching `r10vearl104repro` /
`r10vearl105repro`.  The wide boundary was measured before the rename, so
`BOUNDARY_WIDE.diff` is relabelled; the arm FILES are byte-identical to the ones
measured.

---

## 6. THE WIDE BOUNDARY (verified vs pristine)

```
LISTED = 4775   PROCESSED = 4775   identical = 9153   DIFFERING = 19
rc SYMMETRIC   rc=0 8785/8785   rc=3 362/362   rc=4 387/387   rc=139 16/16
FENCED = 0
```

The 19 differing cells are the implementer's 12 plus this verifier's 7 arms —
**no other committed arm moved**.  All scored three-way against a fresh golden
or sectioned; **AWAY-GOLDEN 0 / MOVED-WRONG 0 everywhere**, and the two
r10uvm154 layout-artifact files are **BODY 0** with TAIL 12 / 12 / 8 / 8.
Details in `BOUNDARY_ARMS.txt`.
