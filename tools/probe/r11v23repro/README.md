# r11v23 — the adversarial verification of r11u23, and the fence it forced

Base commit `5346c1e9`, fresh worktrees (`/tmp/wt_v11u23pris`, `/tmp/wt_v11u23`)
built from source by this verifier. Every number below was re-measured on this
verifier's own binaries against the REAL v1.87 goldens
(`surelog -parse -nobuiltin -nocache -sv dut.sv`, the canonical producer
`scripts/verify_golden.py` names); nothing is carried forward from the
implementer's write-up. **`results/*.csv` ARE NOT EDITED BY THIS PASS.**

| binary | md5 | what it is |
|---|---|---|
| pristine | `b46b0f3e573c5b435bb827c097e47091` | `5346c1e9` built from source — BYTE-IDENTICAL to the OPS-stated main-tree md5 |
| implementer's law | `63a492555c0733b54ecd0214e801becb` | `/tmp/r11u23.patch` on a fresh `5346c1e9` — reproduces the implementer's md5 exactly |
| VERIFIED law | `3c4bad5e15c4f7ab3efbfe50f31fc1fe` | the same plus the amendment in §2 |

## 1. WHAT REPRODUCED, BIT FOR BIT

* **The conversion is real and it is the only corpus row that moves.**
  uhdm2rtlil, this verifier's own sweeps, both binaries, both modes:
  pristine `767 CMP_EQUAL / 37 CMP_NOTEQUAL / 67 SLANG_REJECT`, law
  `768 / 36 / 67`. Diffed row by row against `results/golden_uhdm2rtlil.csv`,
  exactly ONE row moves in each mode and it CONVERTS:

  ```
  genscope_outer_reg_inner_ff,default,CMP_NOTEQUAL   ->  ...,default,CMP_EQUAL
  genscope_outer_reg_inner_ff,testflags,CMP_NOTEQUAL ->  ...,testflags,CMP_EQUAL
  ```

* **The surelog corpus does not move at all**: `469/14` default and `465/12`
  testflags on pristine, on the law and on the verified law — 0 rows moved
  against `results/golden_surelog.csv` for all three.
* **The committed grid reproduces**: 112 arms, every arm `golden_rc=0` and
  `ours_rc=0` on both binaries, **39 CONVERT / 0 REGRESS / 1 improve (`d09`
  75 -> 37) / 72 UNCHANGED** by `uhdm-cmp` rc — the implementer's headline
  exactly. Under the verified law it becomes **40 CONVERT** (`h09` joins;
  see §2).
* **The a-priori prediction contains the movers.** `pred23.py` over the
  PRISTINE databases: u2r `SCANNED=1608 FLAGGED=4` (the witness ×2 modes,
  `UNS=1`; `ibex_compressed_decoder` ×2 modes, `UNS=0`), surelog
  `SCANNED=960 FLAGGED=4` (`Earlgrey_0_1` ×2, `Scr1SvTests` ×2). byteverify
  then measures **u2r 2 movers / 1608** — both the converting row — with the
  `SELFCHECK` positive control flagging 1607/1608, so the comparison can see.
  `ibex_compressed_decoder`, `Earlgrey_0_1` and `Scr1SvTests` are all measured
  BYTE-IDENTICAL.

## 2. WHAT BROKE — the fence read the wrong thing

`genCaUnboundTernConcatFence23`'s decode is right and its transcription was
not. `ExprEval::reduceExpr`'s `vpiConcatOp` arm kills the whole concat on an
operand of UHDM **`VpiSize() == 64`**; the shipped fence tested the operand's
slang AST **kind** instead. The two part company wherever Surelog's written
width is not slang's:

| operand as written | slang width | Surelog `VpiSize` | producer |
|---|---|---|---|
| `16'd1`, `32'd2` (sized literal) | 16 / 32 | 16 / 32 | appends — folds |
| `1`, `5` (UNSIZED decimal) | 32 | **64** | KILLS the concat |
| `'d1` (unsized, based) | 32 | its MINIMUM width | appends other bits |
| an ENUM VALUE `E1` | the enum's | **64** | KILLS the concat |
| a GENVAR `i` | 32 | **64** | KILLS the concat |
| `int K` / a sized param | its own | its own | appends — folds |

**FIVE arms go pristine-CMP_EQUAL -> law-CMP_NOTEQUAL on legal SV** (golden
keeps the whole ternary in each; the law installs a folded constant):

| arm | Rhs arm | pristine | law | verified |
|---|---|---|---|---|
| `w01` / `v12` | `{1, 2}` | 0 | 46 | 0 |
| `w02` | `{16'd1, 5}` | 0 | 46 | 0 |
| `w08` | `{E1, E1}` | 0 | 50 | 0 |
| `w09` | `{i, i}` | 0 | 46 | 0 |
| `x10` | `32'd1 + {16'd0, 5}` | 0 | 59 | 0 |

and FIVE more are AWAY-GOLDEN installs on arms that were already unequal —
a differently-wrong object where pristine had simply left the ternary:

| arm | source | golden | law installed |
|---|---|---|---|
| `w04` | `{'d1, 'd2}` | `INT:6` (1 bit + 2 bits) | `INT:4294967298` |
| `w13` | `{2{3}}` | `BIN:<128 bits>` at size 128 | `INT:12884901891` |
| `x06` | `{2{E1}}` | the ternary kept | a 64-bit fold |
| `x07` | `{2{i}}` | the ternary kept | a 64-bit fold |
| `v24` | a gen-local `lv` shadowing a module `localparam lv` | the ternary kept | `'0` |

`v24` is the second defect and it is in `caLhsUnboundOwnLocal23`, not the
concat fence: the module-body namesake walk rejected only a `Net`/`Variable`
namesake, and golden does not fold a cell whose gen-local name also names a
module-body PARAMETER (there the elaborated writer resolves the Lhs to the
parameter's `UINT:7` and the cell is not the unbound arm at all).

### THE AMENDMENT (in the verified patch)

1. `genTernConcatSafe23` now asks the producer's own question — *what width
   will the writer give this operand, and is it 64?* It can answer only for an
   explicitly sized literal and for a parameter/specparam reference; an
   unsized literal, an enum value, a genvar (slang elaborates a generate
   index into a `ParameterSymbol`, so the parameter arm reads
   `isFromGenvar()`) and anything 64 wide are DECLINED.
2. The `operands.size() == 1` exemption is kept for a NON-leaf operand
   (`h06` `{4{8'd1 + 8'd2}}` folds) and withdrawn for a poisoned LEAF (`w13`).
3. An EXPLICIT cast is judged on its OWN width instead of on what it wraps —
   which is also why `h10` `{16'd0, 16'(PBal)}` folds where the bare enum
   cannot, and why `h09` `{16'd0, 16'($clog2(33))}` now CONVERTS (it was the
   implementer's own R7 over-decline).
4. `caLhsUnboundOwnLocal23` declines on ANY module-body namesake.

Every clause is a NARROWING except (3): a declined arm keeps the whole
ternary, which is exactly the pristine emission, so it can lose a fold and can
never install a differently-wrong object.

## 3. THE ADVERSARIAL GRID — 68 arms, `adv/`, `ADV.r11v23.txt`

Faces: the value machine at 64 with no `adjustSize` to mask it (32-bit add /
multiply / shift overflow, unsigned wrap, signed subtract, arithmetic
right-shift, signed divide, `**`, `$clog2(0)`, divide and modulo by zero);
concat and replication operands of every leaf kind and width; Lhs namesakes at
module scope (output port, input port, net, variable declared AFTER the
generate block, localparam); fills `'0 '1 'x 'z` taken and untaken; the
interface gen scope and the bare interface body; three-deep generate nesting;
`int`/`byte` gen-local targets; two cells in one block where only one folds;
a two-instance generate loop; 35 nested ternaries (the loop cap); an unsized
literal in the UNTAKEN arm and in the CONDITION.

Every arm `golden_rc=0` and `ours_rc=0` on all three binaries.

| binary | CONVERT | REGRESS | AWAY-GOLDEN / changed-still-diff |
|---|---|---|---|
| implementer's law | 38 | **5** | **5** |
| VERIFIED law | 38 | **0** | **0** |

## 4. GATES ON THE VERIFIED BINARY

* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **23 FAIL** (negative
  control). Pristine binary also 23 PASS.
* uhdm2rtlil both modes **768 / 36 / 67** — one row moved, the conversion,
  quoted above. Surelog both modes **469/14 + 465/12**, 0 rows moved.
* byteverify u2r **2 movers / 1608**, both the converting row, SELFCHECK
  1607/1608.
* byteverify surelog **4 movers / 960**: `MiniAmiq` (both modes),
  `SeqDriver/default`, `SimpleUVM/default` — the proven UVM coin, convicted
  three ways: `pred23` flags ZERO cells in any of the four databases; the
  order-blind delta is the 4-line `UINT:<n>` + `vpiDecompile:<n>`
  line-number class in every one; and the PRISTINE binary ALONE drew three
  different databases in three runs of MiniAmiq's own command line
  (`f73aa5575c5f` / `6492eb7a3feb` / `bf70e95927ef`). `Earlgrey_0_1` and
  `Scr1SvTests` — the only two surelog databases `pred23` flags — are
  BYTE-IDENTICAL in both modes.
* protected databases, pristine vs verified, with the OPS pins hit exactly:
  SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
  `59a365f3ce2c`, BlackParrotComplex and YosysOldOr SAME, Earlgrey_0_1
  `8bdf25272e08` / `59d0ee6d10c3` SAME.
* `canaries.sh` vs this verifier's own pristine sweep **ok=52 changed=0**
  (vs the committed baseline it reads ok=50 changed=2 — Earlgrey's DUMP
  column only, and the PRISTINE binary shows the same two, so it is this
  workdir's `uhdm-dump` timeout, not the law). `ctcan2` PASS both corpora.
  `canaudit.sh` from the pass directory `audited=29 UNCOVERED=0
  FENCE-BREACH=0`. `rowheads` identical pristine vs verified; Earlgrey 0
  heads, cmp rc 0, both modes.
* **cmds.txt audit**: 9,819 `cmds.txt` across six sweep workdirs, each naming
  one of the three FROZEN binaries by absolute path, **0 naming the main
  tree**.
* `R11U23_OFF=1` reproduces the pristine bytes on six arms.
* wide boundary gate (`boundary23.sh`, every `tools/probe` source, top-level
  and subdirectory alike, file list on fd 3, children `</dev/null`,
  `PROCESSED == LISTED` asserted): see `BOUNDARY.r11v23.txt`.

## 5. RESIDUES

* **R1** `h03` `{16'd0, 16'd1 + 16'd2}` stays a decline: the operand is an
  OPERATION Surelog folded before writing, and this emitter cannot see the
  written width. A miss, never a wrong install.
* **R2** `w04` `{'d1, 'd2}` — golden appends an unsized BASED literal at its
  MINIMUM width (`'d1` 1 bit, `'d2` 2 bits, `INT:6`). Modellable, declined.
* **R3** the implementer's R2/R3/R4/R5/R6/R8 stand as written (the
  non-ternary Rhs face, the ancestor gen-local literal, the non-`ref_obj`
  Lhs, the interface, `bindVariable` by name, string/`$bits`, the installed
  constant's `vpiParent`).
* **R4 — the BOUND half r11u22 landed carries the same defect.** Its own
  concat fence is the one this pass inherited, so a bound-half cell with an
  unsized-decimal, enum or genvar concat operand folds where golden does not.
  No corpus or boundary arm exhibits it and this pass stays inside its own
  movers, so it is RECORDED, not touched. It is the natural R0 of whoever
  reopens that face.
