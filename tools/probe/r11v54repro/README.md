# r11v54 — ADVERSARIAL VERIFICATION of r11u54 (FOLDMAP roads D + B)

Verifier worktrees `/tmp/wt_v11u54` (patch applied) and `/tmp/wt_v11u54pris`
(pristine), both at `a7b98161`; own scratch `/tmp/v11u54_*`; no shared
`/tmp/ctl_wd_*` control was read; `GOLDEN_DEFER` unset; every build `-j 2`; no
fenced test was ever dispatched.  Pins per `SUPPORT_MATRIX.md`: slang
upstream-master `7d61e0ad1`, UHDM v1.87, Surelog v1.87
(`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil v0.68.

Every golden in this directory is a real Surelog v1.87 run; every arm records
`golden_rc` AND `ours_rc`.  Instruments reused unmodified from
`tools/probe/r11u54repro`: `run54.sh` (the runner) and `shape54.py` (the SHAPE
LISTER).  `vshape54.sh` here only lines the three readings up.

---

## 1. Headline numbers, reproduced bit for bit

* Pristine build in this verifier's own worktree = md5
  `cf14ad224f6125a553825b3a6d29c842`, byte-identical to the main tree at
  `a7b98161`.
* `/tmp/r11u54.patch` (md5 `b36ed9fd58eb738ae3e67000a668f6a4`) applies clean on
  a fresh `a7b98161` and reproduces `src/ParamEmit.cpp` md5
  `01cf707fd7a0f3c7851f6f3dd5450e49`.  Surface: `src/ParamEmit.cpp` +
  `tools/probe/r11u54repro/` only; `results/*.csv` untouched; fence-name scan over
  the four slang-fenced names (from the ops FENCED list, not spelled here)
  0/0/0/0.
* Patched build = md5 `018aca601129dc0e9e259bc9b5aec5fd` — the implementer's
  value, reproduced independently.
* Goldens 23 PASS / 0 FAIL on both binaries; `SLANG_UHDM=/bin/false`
  0 PASS / 23 FAIL.
* Every `cmds.txt` audited BY BINARY PATH: 1742 uhdm2rtlil arms name
  `/tmp/v11u54_pris.bin` in the pristine workdir and `/tmp/v11u54_pat.bin` in
  the patched one, with no third path.

## 2. The producer, re-read

`CompileHelper::substituteAssignedValue`
(`Surelog/src/DesignCompile/CompileExpression.cpp:83-105`) is verbatim as the
implementer quotes it, recursion included.  Its CALL SITES matter for the
reading, and they are all LEAF reads — `getObject` `:242`/`:288`, `getValue`
`:927`/`:998`/`:1100`, the `pkg::NAME` arm `:2742`/`:2790`,
`NetlistElaboration.cpp:280`, `DesignElaboration.cpp:2215`/`:2599`,
`UhdmWriter.cpp:2203` — i.e. the function answers "may the ref to parameter X
be replaced by X's own Rhs", not "may this Rhs be replaced by its reduction".
The double package compile is `CompilePackage.cpp:61-71` with
`setElabMode(reduce == Reduce::Yes)` at `:80`.  **The implementer's "one honest
gap" is real and this verification does not close it either**: the line that
makes the elaborated package's OWN Rhs survive a concat is still unpinned.  The
law below is therefore a MEASURED law, and the measurements are extended here.

## 3. What the golden grid says that the landed law does not

Seven new arms (`grid/xb*`), all `golden_rc=0`; `xb1` and `xb3` are recorded
but NOT scored, because our exporter rejects a select whose base is a
concatenation (`range select base`, `element select base`, `ours_rc=4`) — an
arm whose compile fails teaches error-recovery, not golden.  `xb1b`/`xb3b` are
those arms with the unsupported cells removed.

### 3a. The widening is CORRECT everywhere it was tested

golden's ELABORATED package listing KEEPS the tree, pristine folded it, patched
now reproduces golden's tree CELL FOR CELL:

| arm | cell | golden ELAB | pristine | patched |
|---|---|---|---|---|
| xb1b | `X6 = ~{2{C0}}` | op tree, `ref_obj` leaf | one constant | **= golden** |
| xb1b | `X7 = ({C0,C3} != 4'b0000)` | op tree | one constant | **= golden** |
| xb1b | `X8 = {2{C0}}` | op tree | one constant | **= golden** |
| xb1b | `X9 = {(C0[0]?C0:C3), C3}` | op + `ref_obj` leaves | folded leaves | **= golden** |
| xb2 | `Y1` localparam `{C0,C3}` | op + 2 `ref_obj` | 2 constants | **= golden** |
| xb2 | `Y2` localparam `4'({2{C0}})` | cast op tree | one constant | **= golden** |
| xb3b | `Z6 = signed'({C0,C3})` | `$signed` + `ref_obj` leaves | folded leaves | **= golden** |
| xb4 | `W3 = {C0, 2'b11}` | op + `ref_obj` | 2 constants | **= golden** |
| xb4 | `W4 = {2{C0}}` | op tree | one constant | **= golden** |
| xb5 | `IC = {C0,2'b11}` | op + `ref_obj` | 2 constants | **= golden** |
| xb5 | `IR = {2{C0}}` | op tree | one constant | **= golden** |
| xb5 | `IB = {C0,2'b11} \| 4'b0001` | op tree + `ref_obj` | one constant | **= golden** |

And the substituting shapes stay substituted — no over-fire was found:
`X2 = (C0[0]?{C0}:C3)+2'b01`, `X4 = $clog2({C0,C3})`, `X5 = f4({C0,C3})`,
`Y4 = pq::QC` (a cross-package read of a CONCAT-valued parameter — golden folds
it whole), `Y5 = pq::QC + 4'd1`, `Z4 = $bits({C0,C3})`, and every cell of
`xb7` below.

### 3b. MODULE scope stays out, measured

`xb1b`'s module controls `M1 = ({pk::C0,pk::C3}==4'b0111)?pk::C0:pk::C3`,
`M2 = {2{pk::C0}}`, `M3 = ~{2{pk::C0}}`: golden folds all three whole in the
elaborated MODULE listing and keeps all three in the definition listing; ours
does the same, unchanged by the patch.  `xb5`'s materialized IMPORT copies
(`work@top.IC/IR/IB`) are unchanged by the patch as well.

### 3c. Class body, real, string, time — unmoved

`xb5` carries `parameter real`, `parameter string`, `parameter time` and a
package CLASS body with two concat localparams.  Every one of those cells is
byte-identical between the pristine and the patched reading.  The pass-48
family's declines are untouched.

## 4. THE LAW'S STATED EXCEPTION IS FALSE AS WRITTEN — `xb7` is the cut

The landed § comment says the walk "does NOT descend into a conditional"
because `wb1`'s `S5 = C0 ? {C0} : C3` substitutes.  `S5` reproduces (golden
substitutes it, a `BIN:0001` size-4 constant stamped at the selected branch).
But the exception is stated as a property of the CONDITIONAL, and it is not:

| `xb7` cell | shape | golden ELAB |
|---|---|---|
| `V1 = C0 ? {C0} : C3` | concat in a BRANCH | **substitutes** |
| `V2 = (C0==4'b0001) ? {C0} : C3` | concat in a BRANCH | **substitutes** |
| `V4 = C0 ? {2{C0[1:0]}} : C3` | replication in a BRANCH | **substitutes** |
| `V5 = C0 ? {2'b01,2'b10} : C3` | literal concat in a BRANCH | **substitutes** |
| `V6 = C0 ? (C3 ? {C0} : C3) : C3` | nested, inner BRANCH | **substitutes** |
| `V7 = 4'(C0 ? {C0} : C3)` | BRANCH, under a cast | **substitutes** |
| `V3 = ({C0[1:0],C3[1:0]}==4'b0111) ? C0 : C3` | concat in the **CONDITION** | **KEPT** |

`xb1b`'s `X1` and `xb3b`'s `Z8` are the same CONDITION shape and golden keeps
both; `xb3b`'s `Z5 = 4'(logic'(1) ? {C0,C3} : 4'd0)` is kept too, and its
blocker is the CAST IN THE CONDITION, not the concat in the branch (`V7`
isolates that: same cast, plain condition, substitutes).

**So the rule is: a concat/replication in a conditional's CONDITION blocks the
whole-Rhs substitution; one in a BRANCH does not.**  The landed predicate
answers NO for both, so it UNDER-fires on `V3`/`X1`/`Z8` — we fold, golden
keeps.  That is a residue, not a regression: the pristine binary folds those
cells too, and `xb7` is byte-identical between the two binaries
(residue 183/35 both).  It is the cheapest next cut and the arm is committed.

## 5. The leaf half is incomplete for a CROSS-PACKAGE leaf

In a tree golden KEEPS, golden still SUBSTITUTES a leaf that reads another
package, while keeping a same-package leaf as a `ref_obj`:

```
xb2 Y3 = {pq::Q0, C0}    golden ELAB: [constant 2'b10, ref_obj(pk::C0)]
xb4 W5 = {2{pq::Q1}}     golden ELAB: [constant 2, [constant 2'b01]]
xb4 W6 = {pq::Q0,C0}|... golden ELAB: [[constant 2'b10, ref_obj(pk::C0)], ...]
```

`pkgElabSymOperands` keeps EVERY leaf symbolic, so ours prints
`ref_obj (pk::pq::Q0)` where golden has a constant.  This is still a MOVE
TOWARD golden — `xb6` isolates `W5` alone and the judge's head goes from the
WHOLE Rhs (`operation` vs `constant`, 48 cmp lines) to that one leaf (25 cmp
lines) — and `xb4`'s residue goes 297/61 -> 248/32.  But it is the law's next
conjunct and it is NOT in the § comment.

## 6. Scores

| arm | cmp lines pris -> pat | order-blind residue (g/o) pris -> pat |
|---|---|---|
| xb1b | 72 -> 72 (head advanced) | 427/99 -> 350/57 |
| xb2  | 41 -> 16 | 728/271 -> 671/243 |
| xb3b | 69 -> 69 | 142/63 -> 133/54 |
| xb4  | 59 -> 59 | 297/61 -> 248/32 |
| xb5  | 41 -> 32 | 304/109 -> 264/87 |
| xb6  | 48 -> 25 | 44/45 -> 30/31 |
| xb7  | 31 -> 31 | 183/35 -> 183/35 (inert) |
| vb1 (re-cut) | 29 -> 135 (head advanced past `P4`) | 141/17 -> 135/12 |
| vb2 (re-cut) | 45 -> 0, **cmp rc 0, judge-EQUAL** | 70/62 -> 1/6 |
| wb1 (re-cut) | 69 -> 69 | 327/155 -> 188/150 |
| vd1/wd1/wd2/wd3 (road D) | unchanged | unchanged (road D not landed) |

`vb1`'s cmp-line jump is a MASK LIFT, not a regression: the patched head is the
module `cont_assign` bit-select tree, whose 28 golden-only lines are present
IDENTICALLY in the pristine residue.  The only bytes the patch changes in
`vb1` are `P4`'s operand (constant -> `ref_obj (pk::C0)` + `vpiActual`) and the
operation's `vpiReordered:1` — both golden's.

MOVED-WRONG 0 / AWAY-GOLDEN 0 on every arm, scored CELL BY CELL against the
three-way shape table (`ARMS.shapes.txt`): every cell the patch moves lands on
golden's own tree, and no cell golden folds is left unfolded.  The line-level
subset test is reported here too, with its trap named: the id- and indent-blind
set difference of golden-only lines is 0..5 lines per arm, and every one of
those is a SCALAR FIELD line (`|vpiSize:2`, `|vpiDecompile:2'b11`,
`|vpiConstType:3`) that a now-deleted folded constant used to satisfy in the
MULTISET — not a golden object lost.  The one place the subset test is clean
end to end is the corpus witness: `ibex_tracer`'s golden-only and ours-only
sets both shrink by 126 lines with EMPTY newly-unmatched sets on both sides.

---

## 7. Corpus census, movers, positive controls

**A-priori census (`vcen54.py`, a deliberate SUPERSET):** every test directory
declaring a package parameter or localparam whose Rhs carries a brace —
**54 uhdm2rtlil directories and 308 surelog directories**.  POSITIVE CONTROL:
the dispatched road-B witness's source directory (`ibex/rtl`, where
`ibex_tracer`'s sources live behind its `project.f` filelist) and the road-D
witness (`StructParamFuncBodyFieldCompare`) both fall out of the scan.

**Exhaustive byte census** (`byteverify.sh SELFCHECK=1`, patched vs this
verifier's OWN pristine workdirs — no shared control was read):

```
uhdm2rtlil  1608 paths  PATH_SETS_IDENTICAL  SELFCHECK 1607/1608
  MOVERS 2/1608   ./default/ibex_tracer-573593b3   ./testflags/ibex_tracer-573593b3
surelog      960 paths  PATH_SETS_IDENTICAL  SELFCHECK  959/960
  MOVERS 5/960    default/{MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}  testflags/MiniAmiq
```

The five surelog movers are the documented UVM nondeterminism, attributed
ORDER-BLIND (sorted, path- and id-normalised dumps): `default/MiniAmiq` 4 lines
(`UINT`/`vpiDecompile` 1035 -> 0), `default/SeqDriver` 4 lines (0 -> 1438),
`default/SimpleUVM` 4 lines (576 -> 0), `testflags/MiniAmiq` 4 lines
(1355 -> 1120), `default/Scoreboard` **0 lines** — a pure `vpiTaskFunc` order
flip.  The 0-or-4-line `UINT`/`vpiDecompile` line-number class, exactly as
documented.

**POSITIVE CONTROL for that attribution, and it is decisive:** the PRISTINE
binary run a SECOND time into a third workdir (`--filter
'MiniAmiq|SeqDriver|SimpleUVM|Scoreboard|BuildUVMPkg'`) moves SIX of its own
nine UVM databases against the first pristine sweep — and two of the new draws
are BYTE-IDENTICAL to what the PATCHED binary produced
(`default/SimpleUVM` -> `d4f8cd018f2d`, `default/Scoreboard` -> `1621aec6c9f3`).
A hash the patched binary "produced" is therefore a draw the pristine binary
also produces; `BuildUVMPkg` draws identical in both modes.  All of these rows
are and stay `CMP_EQUAL` (`rowheads.sh`: SeqDriver / SimpleUVM / Scoreboard /
MiniAmiq / BuildUVMPkg / Earlgrey_0_1 all `cmp rc=0`, 0 heads).

**`ibex_tracer` — the one real mover — moves TOWARD golden and only toward it.**
Order-blind whole-dump against its own golden, indent- and id-blind:

```
            golden-only   ours-only
pristine       17389         4148
patched        17263         4022        (-126 / -126)
```

and the newly-unmatched sets are EMPTY on both sides — no golden line we used
to produce was lost, no new ours-only line appeared.  **TO-GOLDEN 126,
AWAY-GOLDEN 0, MOVED-WRONG 0.**  Its head CLEARS: the road-B head
(`ref_obj (ibex_tracer_pkg::OPCODE_C0)` vs our folded `constant`) is gone and
the new head is an ours-only `enum_const (OPCODE_LUI)` with `LHS: <null>` — a
different family — with cmp lines **36 -> 19 in both modes**.  **ADVANCE, not
CONVERT**, as predicted.  `StructParamFuncBodyFieldCompare` is UNMOVED (36 cmp
lines, 1 head, both modes, both binaries) — road D is not in the patch.

NOTE on arithmetic: the implementer reports this residue as 17375/4134 ->
17103/3862 (-272).  Re-measured here with `dumpdiff51.sh` unmodified the
pristine reading is 17389/4148 and the patched one 17291/4050 (-98 raw,
-126 indent-blind).  The DIRECTION and the AWAY-0 result are the same; the
delta's magnitude is not reproduced and the numbers above are the measured ones.

## 8. Road D — the refutation is independently upheld

`wd2`'s elaborated PACKAGE listing, re-cut here from its own Surelog v1.87 run:
golden leaves every pattern element at the COMPILED size — `A`/`B`/`C` 64 into
an `int unsigned` member, `D` 32 into a `logic [7:0]` member, `E` 64, `L`'s cast
128 — and our PRISTINE binary already matches all six.  So the brief's D-law
("the elaborated PACKAGE copy re-stamps EVERY element to its member's width") is
FALSE as a property of the view, and a build that read it that way would move
matching cells away.  `wd3` — the same package plus
`function automatic r_t build(u_t c);` and
`parameter pk::r_t R = pk::build(pk::BASE)`, nothing else — flips golden to the
member widths: `A`/`B`/`C`/`E` 64 -> **32**, `D` 32 -> **8**, `L`'s cast op
gains `vpiSize:128`.  The const-function whole read is NECESSARY; the
implementer's `FuncStructVal` counter-example makes it NOT SUFFICIENT.  Road D
correctly lands nowhere.

## 9. Gates

1. Builds: pristine `cf14ad224f6125a553825b3a6d29c842` (= main tree at
   `a7b98161`); implementer's patched `018aca601129dc0e9e259bc9b5aec5fd`;
   verifier's comment-corrected `490c201cceef32cff72cfd7192df9396`.  All frozen
   `chmod 555` before any sweep.  Every `cmds.txt` audited by BINARY PATH
   (1742 u2r arms per workdir, one path each, no third path).
2. Goldens 23 PASS / 0 FAIL on both binaries; `/bin/false` 0 PASS / 23 FAIL.
3. uhdm2rtlil both modes: `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv`, vs the
   `default` half of `results/golden_uhdm2rtlil.csv`, and vs this verifier's own
   pristine — **0 differing rows in all three**.  784 / 20 / 67 both modes.
4. surelog `--mode both`: vs `results/golden_surelog.csv` — 3 differing rows,
   ALL non-law: `LowMemLib` and `LowMemPkg` `SURELOG_FAIL` details echo the
   workdir path, and `Earlgrey_0_1,testflags` dump column `differ` -> blank.
   That last row changes IDENTICALLY IN THE PRISTINE SWEEP (the documented
   uhdm-dump timeout draw); its status stays `CMP_EQUAL` and its database byte
   pin holds.  Patched vs this verifier's own pristine: only the two
   path-echo rows.  **474/9 default + 469/8 testflags, unchanged.**
5. `byteverify SELFCHECK=1` vs this verifier's own pristine workdirs — §7.
6. Canary byte pins, patched vs pristine, ALL SAME and at their stated values:
   SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort
   `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a`/`73a10e8217e5`, YosysOldOr
   `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08`/`59d0ee6d10c3`.
   `canaries.sh` ok=8 changed=0 (u2r) and ok=51 changed=1 (surelog) — the ONE
   changed row is Earlgrey_0_1/testflags's dump column, which changes the same
   way under the PRISTINE binary.  `ctcan2.sh` PASS on both.  `canaudit.sh`
   (r10uvm221repro) audited=29 UNCOVERED=0 FENCE-BREACH=0.
7. `results/*.csv` untouched; patch surface is `src/ParamEmit.cpp` +
   `tools/probe/r11u54repro/` only; fence-name scan 0/0/0/0; no fenced test
   dispatched; no shared control read.

## 10. Residues, ranked

1. **R0 (this law's own next cut) — the conditional's CONDITION.**  A concat or
   replication in a conditional's CONDITION keeps the whole Rhs in golden's
   elaborated package copy; the landed predicate folds it.  Three measured
   cells: `xb7` `V3`, `xb1b` `X1`, `xb3b` `Z8`.  The fix is one `case` in
   `concatBearing54` that recurses into `ConditionalExpression::conditions()`
   and NEVER into its branches — `xb7`'s `V1`/`V2`/`V4`/`V5`/`V6`/`V7` are the
   fence that says the branches must stay out.  Blast radius: package
   parameters of the shape `(<concat-bearing expression>) ? a : b`.
2. **The CROSS-PACKAGE leaf inside a kept tree.**  golden substitutes a leaf
   that reads another package (`xb2` `Y3`, `xb4` `W5`/`W6`) while keeping a
   same-package leaf symbolic; `pkgElabSymOperands` keeps both symbolic.  Still
   a move toward golden (`xb6` isolates it: head goes from the whole Rhs to the
   one leaf, 48 -> 25 cmp lines), but it is the law's missing conjunct.
3. **A select whose base is a concat is EXPORTER-UNSUPPORTED** — `{C0,C3}[3:2]`
   and `{2{C0}}[2]` make our binary print `range select base` / `element select
   base` and exit 4 (`grid/xb1`, `grid/xb3`, kept unscored for exactly that
   reason).  golden keeps those trees in the elaborated package copy, so the
   law's silence there costs nothing until the construct is supported.
4. The operand ORDER of a kept concat (`vpiReordered`) does not always agree
   with golden's (`xb2` `Y3`, `xb5`'s class-body `KC`) — pre-existing, unmoved.
5. The unpinned producer line for the elaborated package's own-Rhs concat
   refusal: `substituteAssignedValue`'s call sites are all LEAF reads, so the
   function cannot be the whole-Rhs gate the law describes.  Unclosed by this
   verification too, and named as such.
6. Road D's R0 stands as the implementer states it (`wd2`/`wd3` reproduced).

---

## 11. The verifier's own change, and the proof that it is inert

`/tmp/r11u54.verified.patch` = the implementer's patch, plus this directory,
plus ONE production change: the `§ pkgElabConcatTreeNoFold54` comment block in
`src/ParamEmit.cpp` now states the measured boundary — the BRANCH is the
exception, the CONDITION is a residue — instead of "the walk does NOT descend
into a conditional".  **No executable line changes**; `concatBearing54`'s body,
both call sites and every gate are the implementer's, byte for byte.

A comment edit is not free in this build (`-O3 -DNDEBUG`, assertion line
numbers are `.rodata` constants), so the claim is MEASURED, not asserted:

* verifier binary md5 `490c201cceef32cff72cfd7192df9396`; it differs from the
  implementer's `018aca601129dc0e9e259bc9b5aec5fd` in **58 bytes**, twenty of
  them the GNU build-id and the rest a `.rodata` run of line constants.
* a FULL sweep with it, both corpora both modes, into its own workdir:
  goldens 23 PASS / 0 FAIL; u2r 784/20/67 both modes, `ct8rows.sh` PASS against
  `results/gate_uhdm2rtlil.csv` AND the `default` half of
  `results/golden_uhdm2rtlil.csv`; surelog 474/9 + 469/8, and vs
  `results/golden_surelog.csv` only the two workdir-path-echo `SURELOG_FAIL`
  rows differ — `Earlgrey_0_1,testflags` reads `differ` again, as committed.
* `byteverify SELFCHECK=1` verifier vs implementer: **0 movers / 1608** on
  uhdm2rtlil, and on surelog only four UVM-coin files (one of which,
  `default/Scoreboard`, draws `e70775324004` — the PRISTINE sweep's own hash).
* `canaries.sh` **ok=52 changed=0** (surelog) and ok=8 changed=0 (u2r);
  `ctcan2.sh` PASS both; all six canary databases at their stated pins;
  `ibex_tracer` 19 cmp lines / 1 head in both modes, as under the implementer's
  binary.

`cmds.txt` audited by BINARY PATH in all three workdir sets: 1531 surelog arms
and 1742 uhdm2rtlil arms each naming exactly one binary, with no third path.
