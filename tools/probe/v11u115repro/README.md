# v11u115 — adversarial verification of r11u115

**Verdict: ACCEPT-WITH-FIX.** The ship patch is `/tmp/r11u115.verified.patch`:
the implementer's patch plus two gates the verifier added, each droppable alone.

**Rggen/default CONVERTS**, `CMP_NOTEQUAL` → `CMP_EQUAL`, 0 uhdm-cmp lines,
with both the implementer's binary and the fixed binary:

```
results/golden_surelog.csv:  Rggen,default,CMP_NOTEQUAL,decompile:,,
LAW and FIX sweeps:          Rggen,default,CMP_EQUAL,,,differ
```

`results/*.csv` was not edited. ibex_icache stays `CMP_NOTEQUAL` in both
modes; its next head is 976:31 (`BUS_SIZE`, 50 lines).

Base `6158f101`. Pins per `SUPPORT_MATRIX.md`.

| binary | md5 | built from |
|---|---|---|
| pris | `792f69ec51a24e96b5658b66d1bb8690` | the verifier's worktree at 6158f101; the same md5 as the main tree |
| lawv | `1d5daafa48a3addbf3249413c0d9e104` | `/tmp/r11u115.patch` on a fresh 6158f101; the same md5 as the implementer's LAW binary |
| vfix | `b3b2339d5b15b2d4af381ff1204e8394` | `/tmp/r11u115.verified.patch` |

## What was reproduced

Every number below matched the implementer's report exactly.

* **Heads at the base** (`evidence/HEADS.txt`):
  * ibex_icache: 17 lines / 1 head in both modes. Golden has a ref_typespec
    on the folded count at 759:38; ours has `<null>`.
  * Rggen/default: 64 lines / 1 head. The value at 4:33 is `UINT:32` in
    golden and `UINT:64` in ours.
* **The implementer's grid** (155 arms, 310 arm-forms): every uhdm-cmp line
  count, head count and rc is the same as in r11u115repro/evidence/GRID115.txt.
  Golden rc is 0 with `[ERROR] : 0` on all 310.
* **Per-cell score of that grid**: TO 1280, AWAY 0, MOVED-WRONG 16, TAIL 491.
  The 16 moved-wrong cells are all w04/w05, where golden has one plain-array
  view `u.p` with C=32. Ours now reads C=32 on both elements, which is golden's
  value, so these are a keying artifact.
* **Drops**: all ten switches move the same arm counts (194/62/6/14/58/104/14/2/4/2).
  `R11U115_OFF` gives pristine on 310/310.
* **Controls** from earlier passes, 2096 compiles on three binaries
  (`evidence/CTL.txt`):
  * 2058 SAME on all three;
  * 14 DIFF, all of them this pass's named cells (c06, c18, t04, t09, f4 d01/d02/d03);
  * 24 RC with the same rc on every binary;
  * FIX = LAW on all 2096.
* **Sweeps**, both corpora and both modes, `--jobs 3`. Every cmds.txt names
  the right frozen binary.
  * Surelog: default 479/4 → 480/3, testflags 474/3 → 474/3.
  * u2r: 800/4/67 in both modes, unchanged.
  * Row joins against the committed CSVs show only Rggen/default. Earlgrey's
    dump column and the LowMem workdir paths also differ, and they differ
    the same way in the pristine sweep, so they are environment.
* **byteverify** (`evidence/BYTEVERIFY.txt`):
  * LAW vs pristine: u2r 2/1608 (ibex_icache ×2). Surelog 6/960: Rggen, plus
    MiniAmiq ×2, SeqDriver ×2 and SimpleUVM, each the order-blind 4-line
    UINT/vpiDecompile line-number class. The Scoreboard coin did not draw in
    this run.
  * FIX vs LAW: u2r 0/1608. Surelog 4/960, all in the UVM 4-line class.
    This matches the prediction written before the results were read
    (`evidence/PREDICT.vfix.txt`).
* **Pins**, byte-identical on pris, lawv and vfix in both modes: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
  Earlgrey `8bdf25272e08`/`59d0ee6d10c3`, BlackParrotComplex, YosysOldOr.
* **Battery**:
  * canaries: ok=50/51 (only Earlgrey's dump-column draw moves) and ok=8;
  * ctcan2: PASS on both corpora;
  * canaudit: PASS;
  * goldens: 23/0 on pris, lawv and vfix, and `/bin/false` 0/23.
* **Census** (`evidence/CENSUS.txt`): calibration is 0/1608 and 0/960. With
  LAW, only the ibex_icache (F1) and Rggen (PV) deltas clear. The FIX census
  equals the LAW census.

## What broke: the BREAK grid (`grid/`, `mkbrk115v.py`; 81 arms on real v1.87 goldens, both forms)

1. **`$bits(P)` in a generate-scope cont_assign** (f1/a03 `q + $bits(W)`,
   f1/a22 `$bits(L)`).
   * Golden folds the whole call to a constant in generate scope.
   * § caSysArgOpFoldTs115 stamped the argument of our sys_func_call, a
     binding golden does not have: AWAY 8 cells per arm-form, and the
     order-blind distance grows by 10.
   * At module scope (a21) golden keeps the call and stamps the argument, so
     the law is right there (TO).
   * **Fix: § caSysArgGenBitsFence115v** ([ExprEmit.cpp:17209](../../../src/ExprEmit.cpp#L17209)),
     switch `R11U115V_BITS_OFF`.
2. **The receiver's shadowing value is copied without its form** (§ pvRecvShadow115).
   * (a) Golden bounds the value by the INTERFACE parameter's declared type.
     With `bit [3:0] A = 4` and a receiver `int A = 101`, golden reads UINT:5
     where LAW wrote 101 (p18); `bit [7:0]` with 300 reads 44 (p19); 100
     reads 4 (p02, where LAW was AWAY).
   * (b) Golden keeps a BASED receiver literal in its based form: `8'h0A` →
     HEX:0A (p15), `'hA` (p16), an override `#(.A(8'h07))` → HEX:07 with
     decompile 32'h07 (p21), and `4'd5` → INT:5 (p14). LAW wrote UINT:<v>
     (MOVED-WRONG).
   * p12 (a signed `int A` shadowed by 32'hFFFF_FFF0) was MOVED-WRONG on A
     and on the operation default D (golden INT:8589934560, LAW -32).
   * **Fix: § pvRecvShadowForm115v** ([ModuleEmit.cpp:40748](../../../src/ModuleEmit.cpp#L40748)).
     An unsigned, explicitly typed interface parameter takes the value modulo
     2^w (p02, p18, p19 go TO). Any other out-of-range value abstains, and so
     does a based receiver literal and an operation fold with an out-of-range
     substituted value. Switches: `R11U115V_PVW_OFF` for the width half,
     `R11U115V_PVB_OFF` for the based half.

Summed over the break grid (`evidence/BRK.score.txt`):

| step | TO | AWAY | MOVED-WRONG |
|---|---|---|---|
| pristine → LAW | 763 | **36** (a03 16, a22 16, p02 4) | 36 |
| pristine → FIX | 769 | **0** | 2 |
| LAW → FIX | 44 | 2 | 26 |

* The two MOVED-WRONG cells left after the fix are p14's value kind on the
  untyped `C = A + 0`: golden INT:5, ours UINT:5, while the decompile goes
  TO. This is the R5b untyped value-kind class.
* The two LAW → FIX AWAY cells are p14's `A` decompile, in u2r and elab. LAW's
  `UINT:5` matched golden's decompile `5`, but its value was still wrong for
  the judge (golden INT:5). FIX abstains back to pristine's 16.
* The 26 LAW → FIX MOVED-WRONG cells are LAW's wrong values going back to
  pristine's values.

`R11U115V_OFF=1` gives the LAW database back on 162/162 break arm-forms.
Each sub-switch moves only its own arms: BITS a03 and a22; PVW p02, p12,
p18 and p19; PVB p14, p15, p16, p17 and p21. `R11U115_OFF=1` on the FIX
binary gives pristine on 162/162. The FIX binary equals LAW byte for byte on
all 310 of the implementer's arm-forms.

## Laws that held under the break grid (pristine → LAW: TO, AWAY 0)

* **Face 1** held on:
  * the positions `$signed`, `$unsigned`, `$countones`, `$clog2` in a ternary, a replication count that is a sys call, a mixed chain, bit, byte and negative shifts;
  * a case-generate, a module instantiated with two parameterizations, a generate loop inside an interface;
  * the pass-82 controls: `#1` delay and `(strong0, weak1)`. Their pre-existing Delay/strength heads mask the Rhs, and the Rhs cells still score TO.
* **Face 1c** held on a var_select in a concat, a `[W]` index into a
  part-select, a nested index, and an int index. A Lhs index (v01, v02),
  a qualified index (v07) and a nested generate (a17) are byte-identical.
* **Face 2b** held on out-of-scope named modports (a genfor passthrough, a
  multi-parameterized interface, a receiver shadow, a case-generate, a default
  interface, a hierarchical actual `g.i`): TO. Same-iteration, same-generate
  and nested-in-the-same-generate actuals keep the connected view and are
  byte-identical where golden agrees.
* **Face 3** held on double parentheses, a parenthesis under an operation,
  if-in-if, a case-generate ternary, a concat, a parenthesised ternary, the
  else branch, an outer loop-block localparam type, outer-if/inner-for and
  three levels: TO.

## Residues (ranked)

* **R0**: ibex_icache 976:31. It is a nested-generate always_ff Lhs index
  `b*BUS_SIZE`, where golden has a ref_obj and we fold. It is on the ExprEmit
  ground (§ genNestedScopePkgParamNoFold24 excludes `inLhs`).
* The value form of a receiver-shadowed interface parameter:
  * Golden writes HEX:<digits> in the parameter's own width (decompile
    `32'h07`).
  * An untyped interface parameter reads INT:.
  * An operation fold works in 64 bits (8589934560).
  * The verifier's gates abstain on all three shapes instead of modelling them.
* A typedef-typed package parameter, `parameter n_t N`: golden stamps
  `logic_typespec (n_t)`, we write none (a10, byte-identical).
* The pre-existing heads that masked the break arms (all byte-identical in
  the relevant cells):
  * `$bits` folded whole in a generate scope;
  * `$unsigned(S)`/`$signed(S)` def-view ref_obj;
  * `$clog2($clog2())`;
  * sized-literal defaults (p01);
  * the multi-parameterized plain view (p09);
  * a `localparam type` home (o01-o06).
* The implementer's residues stand: R2b, s10, plain-array views, R5b, R-qual,
  R1v, b07 and t09.

## Scripts

| script | what |
|---|---|
| `mkbrk115v.py` | writes `grid/` |
| `ctl115v.sh` | three-binary control byte compare |
| `drops115v.sh` | per-switch drops (the implementer's logic with its own scratch prefix; `SW` can be overridden) |
| `cen115v.sh` | census driver; its own scratch prefix and census binary |

Grids were run with `r11u115repro/grid115.sh` and scored with
`r11u115repro/score115.sh`.
