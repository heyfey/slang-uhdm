# r11v11u8 -- adversarial verification of r11u8 (§ macroQuoteContLeak11)

Verifier's own worktrees `/tmp/wt_v11u8` + `/tmp/wt_v11u8pris` at `0076cdd9`,
own frozen binaries, own sweeps, own instruments. The judge is the official
`uhdm-cmp` through `scripts/verify_golden.py`. Everything in this directory is
measurement-only; the one production change this verification adds is the BOUND
inside `UhdmExporter::macroQuoteContLeak` (§3).

`results/*.csv` ARE NOT EDITED. No fenced test was dispatched.

## 1. Verdict -- ACCEPT-WITH-FIX

r11u8's decode is right, its gate is the right gate, and every headline number
reproduces bit-for-bit on independently built binaries. Its BOUND was wrong:
it measured the whitespace the macro body writes immediately after the `` `" ``
marker, and that is not the whitespace the value is entitled to keep. Two
legal-SV shapes that are CMP_EQUAL on the pristine binary become CMP_NOTEQUAL
under the submitted patch:

```
`define AB(__a,__b)  `"  __a  __b`"      `AB(,yy)   golden+pristine `    yy`  law `  yy`
`define AB3(__a,__b) `"__a  __b`"        `AB3(,yy)  golden+pristine `  yy`    law `yy`
```

(arms `v11/`, `v13/`; Surelog rc 0, ours rc 0, no line continuation anywhere.)
The cause is the SAME slang mechanism the law decodes: an EMPTY ACTUAL
ARGUMENT is an `EmptyMacroArgument` too, so `MacroOpEvaluator::append` parks
its trivia in `emptyArgTrivia` and prepends it to the next token exactly the
way it parks a line continuation's -- and Surelog's body-text substitution
produces the identical string. Whitespace written after a formal that expands
to nothing is therefore LEGITIMATE leading whitespace on both sides.

The fix reads the enclosing `define's FORMAL LIST out of the same source buffer
and lets the bound walk cross those names, and nothing else. It costs the pass
NOTHING: the whole uhdm2rtlil corpus is BYTE-IDENTICAL between the submitted
law and the fixed law (byteverify 0 movers / 1608 databases), the three
conversions stand, and two more arms (`v12`, `v13`) convert that the submitted
law left wrong.

## 2. Reproduced bit-for-bit (independent build, independent instruments)

| headline | r11u8 | this verification |
|---|---|---|
| pristine md5 | `d9f02d33ac97b1570209e2e4b1862ab7` | same, from a fresh worktree at `0076cdd9` |
| law md5 | `ed82305a891da199c68f521ea94f752b` | same |
| goldens both binaries | 23 PASS / 0 FAIL; `/bin/false` 23 FAIL | same (and 23/0 for the fixed binary) |
| u2r pristine | 743 / 61 / 67 both modes, = committed baseline | same; `ct8rows` PASS, every row byte-identical |
| u2r law | 746 / 58 / 67 both modes | same; exactly 3 rows move, both modes |
| the head | NINE rows, not eleven | same nine, each 18 cmp lines / 1 head, 9 leaked spaces, every vpiSize as tabulated |
| `ibex_pmp` | NOT on this head | confirmed: its head is a `range` constant `vpiSize 32` vs `64` at 34:10 |
| b1 / b8 / b5 pristine | 18 / 18 / 0 cmp lines | same |
| u2r byte movers | 20 / 1608, all predicted by name | same 20, independently predicted (my own scanner: 24 flagged of 1608, minus `asgn_expr_sv` + `ibex_tracer`, whose leading-space strings are plain `$fwrite`/attribute literals) |
| surelog | 465/18 + 461/16, identical to pristine | same; the only two `ct8rows` rows are the WORKDIR PATH inside a `SURELOG_FAIL` message |
| surelog byte movers | 6, the UVM coin | 5 here (the coin is per-run): MiniAmiq x2, Scoreboard, SimpleUVM, SeqDriver -- 0-or-4 order-blind lines, every one a `UINT:` + its `vpiDecompile:`, ZERO `STRING:` lines, direction flipping both ways (2 TO-GOLDEN, 2 AWAY, 1 zero) |
| null-sweep control | MiniAmiq/SeqDriver/SimpleUVM move on a fixed binary | reproduced: MiniAmiq MOVED re-running the PRISTINE binary against its own sweep database |
| canaries | sl ok=52/0, u2r ok=8/0, ctcan2 PASS x2, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | same |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, 3 SAME | same, both modes, pristine vs fixed law |
| rowheads | identical pristine vs law | same (12 measured, 2 SKIP-NOFILE) |
| `v14_crossmacro` | moves TOWARD golden | confirmed: pristine has 2 leaked strings (` a-b`, ` c-d` vs golden `a-b`, `c.d`); law AND fixed law have ZERO string differences |

## 3. The fix

`src/ExprEmit.cpp`, inside `UhdmExporter::macroQuoteContLeak`. The gate is
unchanged; only the BOUND is. The walk from the marker now crosses a name that
is a FORMAL of the enclosing `define -- located by scanning back to the owning
`` `define `` in the same buffer -- and stops at everything else. Measured
reasons for "everything else":

* a NESTED MACRO reference does not vanish on the golden side: Surelog renders
  an empty one as the literal text `@@EMPTY_MACRO@@` (arm `v14/`), so a value
  reached across one can never equal golden anyway, and crossing it leaves a
  leak half-trimmed (arm `v1/` went from converted to ` thing leaked`);
* a PLAIN WORD never vanishes, and crossing it costs a real conversion --
  `` `define LIT `"  hello  `" `` reached across a one-space leak needs the
  bound to stop at `hello` (r11u8's own `gB` arm B1S);
* if the enclosing `` `define `` cannot be located the law ABSTAINS.

Cost, measured, not argued: `byteverify` between the submitted law's u2r sweep
and the fixed law's -- **MOVERS 0 / 1608**, and the two CSVs are identical row
for row in both modes.

## 4. The arms (`v1/`..`v14/`, run with `vgrid.sh <binary> <tag>`)

Every arm compiled `--nobuiltin` on both sides, every rc recorded; all arms
`slrc=0 ourrc=0` except `v11`'s first draft, which Surelog REJECTED (`rc=7`,
`` `A1() `` omits the only argument) and which was rewritten -- a golden whose
compile fails scores nothing.

| arm | shape | pristine | submitted law | fixed law |
|---|---|---|---|---|
| v1 | stringify OPENS with a nested macro ref, + leak | 18 | **0 CONVERTS** | **0 CONVERTS** |
| v2 | argument-borne whitespace, + leak | 18 | 0 CONVERTS | 0 CONVERTS |
| v3 | a COMMENT after the marker (golden KEEPS `/*c*/`, we drop it) | 18 | 18 | 18 (wrong before, wrong after) |
| v4 | TAB body / SPACE leak and the mirror | 18 | 0 CONVERTS | 0 CONVERTS |
| v5 | empty macro argument, no body whitespace between formals | **0 EQUAL** | 0 EQUAL | 0 EQUAL |
| v6 | continuation INSIDE the stringify, in front | 20 | 20 | 20 |
| v7 | continuation before the CLOSING marker | 20 | 20 | 20 |
| v8 | plain `"   literal"` in a macro body across a leak | **0 EQUAL** | 0 EQUAL | 0 EQUAL |
| v9 | stringify as an ASSIGNMENT Rhs, + leak | 14 | 0 CONVERTS | 0 CONVERTS |
| v10 | whitespace-ONLY stringification, + leak | **0 EQUAL** | 0 EQUAL | 0 EQUAL |
| v11 | `` `"  __a  __b`" `` with `__a` EMPTY, NO continuation | **0 EQUAL** | **18 BROKEN** | **0 EQUAL** |
| v12 | the same shape WITH a leak | 18 | 18 (over-trimmed) | **0 CONVERTS** |
| v13 | `` `"__a  __b`" `` with `__a` EMPTY, with and without a leak | **18 (one face EQUAL)** | **18, and the EQUAL face BROKEN** | **0 CONVERTS** |
| v14 | empty NESTED MACRO at the front (`@@EMPTY_MACRO@@`) | 18 | 18 | 18 |
| b5 (r11u8) | the fence: intentional spaces in the literal | **0 EQUAL** | 0 EQUAL | **0 EQUAL** |

## 5. The wide boundary, and a finding that is NOT this pass's

`bound221.sh` over the whole probe tree, subdirectories included, pristine vs
the FIXED binary: **LISTED=5751 PROCESSED=5751 RC_DIFFS=0 ONESIDE=0
MOVED_ARMS=42** = 21 files x 2 views. Seventeen are law arms -- r11u8's own
b1/b8/gA/gB/gC/gD (**b5 did NOT move**: the fence's second face), r11v11u5's
b1/b8, nine of this directory's v-arms, and `r10v104repro/v14_crossmacro.sv`
(the law, moving toward golden: pristine has 2 leaked strings ` a-b` / ` c-d`
against golden `a-b` / `c.d`; the law and the fixed law have ZERO string
differences from golden). **v5, v7, v8, v10 and v11 did not move** -- every
CMP_EQUAL fence arm is untouched.

The other three arms are not string arms at all:
`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
`r10uvm185repro/grid185/g185_e_kinds.sv` (and `r10v104repro/v14_crossmacro.sv`,
which is the law, moving toward golden).

They are **BINARY-LAYOUT ARTEFACTS, not law movers**, and the proof is a
positive control: a PRISTINE build with nothing but a 16 KB `volatile char`
pad appended to `uhdm_main.cpp` -- no law code at all -- moves the same three
arms, to yet different hashes. The changed fields are an unsupported-typedef
`range` bound emitted as `UINT:22838841` / `UINT:22842937` -- values that differ
by exactly **4096**, one page, tracking the image size (pristine 22718296 B,
fixed 22722704 B; r11u8's own law binary grew only 152 B and stayed inside the
page, which is why its boundary run did not show these three).

**RESIDUE, NEW, NOT OURS: an emitter cell writes an ADDRESS-DERIVED constant
into the database.** It reaches `typedef C22 ka_cls_t[string];`-class
associative-array / unsupported-typedef range bounds. No corpus row touches it
(u2r byteverify between two binaries a page apart shows 0 movers over 1608
databases), but any future pass whose binary crosses a page boundary will see
unexplained wide-boundary movers until it is fixed.

## 6. Files

* `v1/`..`v14/dut.sv` -- the arms above.
* `vgrid.sh <binary> <tag> [arm...]` -- golden vs ours per arm: both rc's, the
  cmp rc, cmp lines, head count (`^LHS:` on STDERR) and a SORTED, order-blind
  diff of the two string-constant multisets.
* `vheads.sh <workdir/mode> <outdir> <rowglob...>` -- per-row head and cmp-line
  count straight from a `verify_golden` workdir, resolving the golden out of
  `cmds.txt`; it PRINTS the stderr head, because `uhdm-cmp` exits 0 when an
  input file is missing and a SLANG_REJECT row otherwise reads as "equal".
* `vpredict.sh <workdir>` -- the independent a-priori mover predictor: every
  database holding a string constant whose value starts with whitespace.

## 7. Gates, final (all on the FIXED binary unless stated)

* builds `-j 2`, md5 separately: pristine `d9f02d33ac97b1570209e2e4b1862ab7`
  (= the main tree at `0076cdd9`), submitted law `ed82305a891da199c68f521ea94f752b`,
  fixed law `70777d4d3e139fe445210d8c68132421` -- and a rebuild after the
  comment-only edit reproduces that md5 byte for byte, so the shipped source is
  the measured source. All three frozen `chmod 555` before any sweep.
* goldens 23 PASS / 0 FAIL on all three binaries; `SLANG_UHDM=/bin/false`
  0 PASS / 23 FAIL.
* every sweep exported `SLANG_UHDM`; every `cmds.txt` audited BY BINARY PATH --
  u2r 1742/1742 and surelog 1531/1581 name the pass's own frozen binary, the
  other 50 carry no `slang:` line at all, ZERO name any other binary.
* u2r both modes: pristine 743/61/67 = the committed baseline byte for byte
  (`ct8rows` PASS); fixed law 746/58/67, exactly the three rows of §1 moving,
  `match` count unchanged.
* surelog both modes: 465/18 + 461/16 on pristine AND fixed, every row
  identical; the only two `ct8rows` rows are a WORKDIR PATH inside a
  `SURELOG_FAIL` log message.
* byteverify `SELFCHECK=1` vs this verification's own pristine workdirs:
  u2r **20 / 1608**, every one predicted BY NAME beforehand (positive control
  1607/1608); surelog **3 / 960**, all the proven UVM coin -- 4 order-blind
  lines each, every one a `UINT:` + its `vpiDecompile:`, ZERO `STRING:` lines,
  direction mixed, and a NULL SWEEP moves `MiniAmiq` against its own sweep
  database on BOTH the pristine and the fixed binary (positive control
  959/960).
* byteverify submitted law vs fixed law on u2r: **0 / 1608**. The fix is
  corpus-invisible.
* canaries `canaries.sh` sl ok=52 changed=0, u2r ok=8 changed=0;
  `ctcan2.sh` PASS on both corpora; `canaudit.sh` audited=29 UNCOVERED=0
  FENCE-BREACH=0.
* protected databases by md5, fixed vs pristine, both modes: **SVSwitch
  `4842211c4030` and YosysVerx `6ccda350c24a` HELD**; InterfaceModPort
  `59a365f3ce2c`, BlackParrotComplex, YosysOldOr SAME.
* rowheads on SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
  Earlgrey_0_1 / Rggen: IDENTICAL pristine vs fixed (12 measured, 2
  SKIP-NOFILE as expected).
* `results/*.csv` NOT edited; no fenced test dispatched; the patch surface is
  `src/ExprEmit.cpp` + `include/UhdmExporter.h` + the two probe directories.
