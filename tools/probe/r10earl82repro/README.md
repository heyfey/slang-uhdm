# r10earl82 — § rangeBoundStoredWidth82

**THE EARLGREY HEAD CLEARED IN BOTH MODES** (`[MpRegions:0]`, `flash_ctrl.sv:310`
— golden `vpiSize:32`, ours `64`, and nothing else about the object differed).
36 cmp lines → a new head, in both modes, and the two head logs stay
byte-identical.
BASE `29c1576`, branch `auto5h`, worktree `/tmp/wt_r10earl82`.
`results/*.csv` was **READ ONLY** and is untouched — **NO ROW WAS CONVERTED**
(`Earlgrey_0_1` stays `CMP_NOTEQUAL` in both modes; its head is cleared, the
design has more — see `PREDICT_R0.txt`).

## 1. The law

**The width a RANGE BOUND folds at is the width of the parameter's STORED
VALUE — the DECLARED type's width when the parameter was not overridden, and
the OVERRIDE ACTUAL's own width when it was, followed hop by hop through
bare-reference actuals. That width belongs to EVERY copy of the written
dimension, the DECLARATION-side one included.**

The head, `flash_ctrl.sv:310`:

```systemverilog
  flash_ctrl_reg2hw_mp_region_cfg_mreg_t [MpRegions:0] region_cfgs;
  //                                      ^col 43..52 = `MpRegions`
```

with `localparam int MpRegions = 8;` at `flash_ctrl_pkg.sv:28`, wildcard-imported
by `module flash_ctrl import flash_ctrl_pkg::*;`.

| | LHS (golden) | RHS (ours, pristine) |
|---|---|---|
| kind | `constant` 310:43-310:52 | `constant` 310:43-310:52 |
| | `vpiParent -> range` 310:42-310:55 | `vpiParent -> range` 310:42-310:55 |
| | `vpiDecompile:8` | `vpiDecompile:8` |
| | **`vpiSize:32`** | **`vpiSize:64`**  ← THE WHOLE HEAD |
| | `UINT:8` | `UINT:8` |
| | `vpiConstType:9` | `vpiConstType:9` |

**Which arm — read the MK line, not the shape.** `constant::Compare` reaches
`VpiSize` inside `expr::Compare` (`VpiDecompile`, then `VpiSize`, then
`Typespec`), so the mismatch is the `VpiSize` line itself: no kind dispatch, no
null side, and `Typespec` is never reached — which is why the typespec-carrying
sibling copy of the same bound was invisible to the judge.

## 2. Decoded from Surelog, not guessed

1. Surelog stores a parameter's value ONCE PER INSTANCE.
   `DesignElaboration::collectParams_` compiles the override **actual** in the
   PARENT instance and stores `fromVpiValue(c->VpiValue(), c->VpiSize())` with
   **no `adjustSize` anywhere on that path**; the NON-overridden default is
   `adjustSize`d against the declared typespec **before** the capture
   (`DesignElaboration.cpp:2519-2534`).
2. Every later read answers from that stored `Value`:
   `CompileHelper::getValue`'s instance arm takes `sval->getSize()` verbatim
   (`CompileExpression.cpp:962-982`).  A range bound naming the parameter is
   such a read, so it renders at the stored width.
3. So the width splits exactly on the OVERRIDE ACTUAL's shape, and this pass
   measured every shape on `g5_enc82.sv`:
   * a **bare decimal**, a parenthesised one, or an **arithmetic expression** →
     Surelog's unsized **64** (earl81's population — the must-not-move set);
   * a **based literal** → the literal's own base and width (`4'h7` → HEX:7 sz4);
   * a **bare NAME** → the named parameter's own stored width, RECURSIVELY;
   * **not overridden** → the DECLARED type's width.
4. `flash_ctrl_pkg`'s `MpRegions` is never overridden and is declared `int`, so
   golden's stored width is 32 — and the DECLARATION-side copy of the dimension
   carries it just like the typespec-side copy does.

**Our own emitter already knew the answer at one of the two copies.**  For the
head's very dimension, our `packed_array_typespec` range was already
`UINT:8 sz32` + `ref_typespec -> int_typespec`, byte-identical to golden's;
only the `packed_array_var` copy was minted at the unsized 64.  That is why the
declaration-side half of the law calls **`pkgBoundValueConst9`**, the encoder
§ patDefBoundPkgParamSubst already uses on the typespec side, and then drops the
typespec (golden puts it on the typespec copy only).

## 3. What changed — two call sites, one law

* `src/TypeEmit.cpp`, the packed/port range-bound fold (`makeTypespec`'s bound
  builder): a new `ovActualStoredWidth82` walks the override chain and, when
  the parameter at this bound IS overridden, sets the bound's `VpiSize` to the
  stored width.  Only the SIZE moves — the `INT`/`UINT` pick stays with the
  existing `intEnc`, and no `ref_typespec` is attached
  (§ overriddenBoundParamNoFoldTs19 measured that an overridden parameter's
  folded bound carries none, and golden agrees on every `OV*` cell of the grid).
  The OVERRIDDEN half of the old `litBoundOwnPar9` lambda is superseded and now
  returns false; its NON-overridden half is untouched.
* `src/TypeEmit.cpp`, both DECLARATION-side packed_array_var bound builders: a
  new `pkgVarDimBoundEnc82` re-encodes a plain-identifier bound naming an
  explicitly typed PACKAGE parameter through `pkgBoundValueConst9`, bare.

`R10E82_OFF=1` restores the pre-pass path at both sites; `R10E82_DBG=1` prints
one line per candidate at each branch point.

## 4. The fences, each a measured negative control on `g5_enc82.sv`

| | fence | measured |
|---|---|---|
| (a) | the override ACTUAL must be a **bare NAME** | a bare decimal / `(8)` / `4+4` / a cast actual is golden **64** and we already wrote 64 — `OVI`, `OVU`, `OVB`, `OVX`, `OVW`, 0 moved |
| (b) | the chain must **end at a non-overridden parameter** | the HOP chain `#(.HW(40))` → `.HW(HW)` → a leaf bound is golden **64** because its ROOT actual is a bare decimal; the OLD test looked one hop up, found the literal 40 and lent 32 — this pass makes it 64 (**a fix**, `HOP`) |
| (c) | what is lent is the **ACTUAL's** width, never the FORMAL's | `OVJ` (`byte` formal ← `int` actual) is golden **32** and `OVK` (`int` formal ← `byte` actual) is golden **8**; the old code answered 8 and 32 (**both fixed**) |
| (d) | a **BASED-literal** initialiser is refused | golden keeps the literal's base AND width (`PKD` `int = 8'd8` → `INT:8 ct7`, `PKV` `bit[3:0] = 4'h7` → `HEX:7 ct5`); a size-only law would leave the value and constType behind — 0 moved |
| (e) | an **UNTYPED** parameter is refused | golden is two-faced (`PKU` is sz32 on the typespec copy and sz64 on the others) — 0 moved |
| (f) | the declaration-side arm takes **PACKAGE** referents only | for a MODULE parameter golden emits `3 x ref_obj` + `6 x constant` on that copy where we emit `9 x constant`: a KIND gap, so a re-size could only move cells that cannot land — every `NO*`/`OV*`/`LP*` cell 0 moved |

The full 136-cell table is `GRID_G5.txt`. **Eighteen cells move, all eighteen
land on golden exactly; one hundred and eighteen are refused and not one moved.**

## 5. Corpus-wide

`rngcen82` (a DIRECT `.uhdm` reader — Earlgrey's uhdm-dump is >1 GB and was
never produced) censused **2,306 comparable pristine databases**.  Range-bound
keys whose ONLY divergence from golden is `vpiSize`:

    surelog       8   — Earlgrey_0_1 default 4 + testflags 4, the SAME four spans
    uhdm2rtlil    0   of 1358

and the four spans are `flash_ctrl.sv:310` (the head, a package localparam at the
declaration-side copy), `rstmgr_info.sv:18` and `:19` (a module parameter at a
PORT range, overridden `.Reasons(ResetReasons)`), and
`flash_{rd,prog}_ctrl.sv:44` (a module parameter at a body range, overridden
`.AddrW(AddrW)`) — 21 cell-instances per mode.  **All 21 land on golden in both
modes and the family is CLOSED: 0 SIZE-ONLY range-bound cells remain anywhere in
either corpus.**  `CENSUS.txt`.

## 6. Scores — AWAY 0 / MOVED-WRONG 0

| population | TO-GOLDEN | AWAY | MOVED-WRONG |
|---|---|---|---|
| Earlgrey default, whole database (5,663+ range keys) | 4 | 0 | 0 |
| Earlgrey testflags, whole database | 4 | 0 | 0 |
| surelog corpus, **all 45,264 range keys** | 8 | 0 | 0 |
| uhdm2rtlil, **all 11,656 range keys** | 0 | 0 | 0 |
| `g5_enc82.sv` (136 cells) | 18 | 0 | 0 |
| `g6_earl82.sv` (the three Earlgrey cells) | 1 | 0 | 0 |
| boundary movers, SIZE field | 9 | 0 | 0 (+1 CLOSER) |

`byteverify.sh SELFCHECK=1`: **2 movers of 956** (Earlgrey both modes) and **0 of
1358**, exactly the two predicted from the pristine census before any patched
sweep was read.  `GATES.txt`, `PREDICT_R0.txt`.

## 7. How this sits against the landed dimension-bound laws

**§ dimBoundInheritsParamEnc74 and § dimExprBoundFold79 own the UNPACKED
DIMENSION and are untouched.**  earl74's law is an ENCODING law (`vpiConstType`
and the value tag) on a SIZE-FORM unpacked dim, and it says in as many words
that the bound copy is *not* `adjustSize`d; this pass changes no `ct` and no tag
anywhere, and touches no size-form dimension.  Measured, not argued:
`r10earl74repro` and `r10earl79repro` are byte-identical between the two
binaries in both views in both boundary walks, and on earl74's verifier arm
`va2_v74.sv` the 197 size-form keys are UNMOVED — the single key that moved is
the PACKED range `logic [D:D+3]`, and it moved strictly closer to golden.

**§ connBitSelIdxModParamFold81's 16 cells are the must-not-move set and did not
move.**  earl81's law deliberately writes 64 at its own site because THERE golden
writes 64 — an overridden parameter whose actual is a bare decimal.  That is
fence (a) here, and it is the reason this law is keyed on the ACTUAL's shape
rather than on the parameter or the literal.  `r10earl81repro` and `r10v81repro`
are byte-identical in both views in both walks.

**§ boundOverriddenParamWidth24 is the law this pass corrects, in its own
terms.** Its `litBoundOwnPar9` carve-out asked whether the actual's parameter had
an INTEGER-LITERAL initialiser; the corpus shape it was measured on
(`ibex_counter #(.CounterWidth(MHPMCounterWidth))`, where `MHPMCounterWidth` is
overridden in turn by a REF) still answers 64 under the recursion, and so does
`BasicOh`'s `oh_dsync #(.SYNCPIPE(SYNCPIPE))`, which still lends 32.  What
changes is the shape neither witness had: an actual naming a parameter whose
initialiser is an EXPRESSION (`1 + ExtResetReasons + 1`, `BankW + PageW + WordW`)
— 18 of the 21 Earlgrey cells.

## 8. Instruments

| file | what it is |
|---|---|
| `rngcen82.cpp` | range-bound census, reads `.uhdm` **directly** |
| `score82.py` | multiset join + 3-way scorer; `--diff` / `--score` / `--cons` / `--field` |
| `cencon82.py` | span-keyed constant census over a `uhdm-dump` text (the small arms) |
| `rngscan82.sh` | corpus-wide scan, golden from each test's **own** `cmds.txt`; the fence list is supplied by the operator, never spelled here |
| `gen82.py` / `grid82.py` | generate and score the discriminator grid |
| `arm*.sv` | see `ARMS.txt` |
| `armscore82.sh` | scores one boundary mover against GOLDEN with the official `uhdm-cmp` |
| `attr82.sh` | attributes a mover: self-repeat, kill switch, then the diff |
| `dirattr82.sh` | is a per-directory diff even comparable? (earl81's R6, re-proved) |
| `vwide82.sh` / `vdir82.sh` | the two boundary walks (fd 3, `</dev/null`, PROCESSED asserted) |
| `byteverify.sh` | mover detection with `SELFCHECK=1` |
| `ct8rows.sh` | whole-row CSV gate against the committed baselines |
| `rowheads.sh` | cmp lines / head count for the named rows |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its self-audit |

Every scanner **reads databases and dispatches nothing**.  The four slang-fenced
tests are never dispatched and are never named in this directory —
`canaudit.sh` asserts `FENCE-BREACH=0`.
