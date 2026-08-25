# r10v86 — the ADVERSARIAL VERIFIER of r10earl86

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's
report reproduces bit-for-bit from independently built binaries, and the
`Earlgrey_0_1` **default** head really is cleared. Ten new arms then broke the
law once: the transcribed comparison arm compares **UNSIGNED** where
`ExprEval::reduceCompOp` compares **SIGNED**, which is a **RIGHT->WRONG on
legal SystemVerilog** in the `--elabuhdm` view. The fix is
§ `compOpUnsignedReadSignedCompare86v`, five lines in
`src/ExprEmit.cpp`; ship `/tmp/r10earl86.verified.patch`.

**MEASUREMENT-ONLY directory.** `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
sole acceptance judge. **BASE `aef5007`.** `results/*.csv` untouched — **NO
ROW CONVERTED**. slang not patched.

---

## 1. Reproduction of the implementer's numbers (independent build)

Both binaries were configured and built in **fresh worktrees at `aef5007`**
(`/tmp/wt_v86pris` pristine, `/tmp/wt_v86` = `aef5007` + the patch, applied
with `git apply -3`, rc 0, **0 conflict markers**, 38 files, no `results/*.csv`
in the surface, fenced-name scan all four counts **0**), frozen `chmod 555`
before any sweep, and every `cmds.txt` in every sweep workdir was audited BY
BINARY PATH.

| claim | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `e36cb36103acbc3c2e44797ddc81a745` | **same** |
| patched binary md5 | `774b905631bc3746deb00824309b2566` | **same** |
| golden dumps, both binaries | 23 PASS / 0 FAIL | **same**; `/bin/false` 0/23 |
| surelog rows vs committed baseline AND own pristine | 0 differing / 1588 | **same**, both modes |
| surelog status histogram | unchanged | **same** (937/567/48/19/10/3/2/1/1) |
| uhdm2rtlil rows, both modes | 0 differing | **same**; histogram `679 / 50 / 2` |
| uhdm2rtlil byte movers | 0 / 1358 | **0 / 1358** |
| surelog byte movers | 2 / 956, both `Earlgrey_0_1` | **2 / 956**, same two |
| pristine Earlgrey/testflags hash | `664f81104e1f` | **same** |
| `R10E86_OFF=1` reproduces it | byte for byte | **byte for byte** |
| `uhdm-cmp` ours-vs-ours, testflags | rc 0, 0 lines | **rc 0, 0 lines** |
| `uhdm-cmp` ours-vs-ours, default | exactly one head, 90 lines | **one head, 90 lines** |
| head Earlgrey default | 90 / 1 -> **150 / 1, object GONE** | **same** |
| head Earlgrey testflags | 150 / 1 unchanged | **same** |
| other named rows | 17 / 124 / 124 / 17 / 54 / 0 | **identical, both binaries** |
| canaries / ctcan2 / canaudit | 52, 8, PASS/PASS, 29-0-0 | **same** |
| protected DBs | 3 byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **same** |
| wide boundary | `PROCESSED=3857 identical=7403 DIFFERING=17 no_output=294` | **byte-identical tally, rc histogram AND the 17-line differing list** |
| corpus census, surelog | BOTH-SAME 45 441 -> **45 442**, FAMILY-SUBFOLD **1 -> 0** | **same**, and the one FAMILY-SUBFOLD cell is `BankAddrMask`, `Earlgrey_0_1/default` |
| census, other buckets | OPKEPT 2, OVSTAMP 16, OTHER-DIFF 1824, ONLY-GOLDEN 8898, ONLY-OURS 9628 | **all identical, before and after** |
| GATE-REACHABLE | 117 = 115 DEF + **2 ELAB, both `default`** | **117 = 58 DEF default + 57 DEF testflags + 2 ELAB default** |

The four committed `HEAD_*.cmp` logs are **content-identical** to my own
captures (they differ only in the stdout/stderr interleaving of the capture,
`sort | md5sum` matches on all four). The `HEAD_AFTER` default log, the
`HEAD_BEFORE` testflags log and the `HEAD_AFTER` testflags log are the SAME
object — `flash_erase_ctrl.sv:12:18 PagesPerBank`, `vpiOverriden:1` — so the
implementer's R0 is confirmed from the measurement, not from the write-up.

`r10buvm22repro/g22.sv`'s two boundary cells were re-attributed independently:
`R10E86_OFF=1` on the patched binary reproduces the **PATCHED** normalised
dump hash, not the pristine one, so that delta survives the kill switch and is
**not this law** (earl84 R5 / earl85 §7). The five other-author arms that move
were re-scored against GOLDEN and every one is **WRONG->RIGHT with
RIGHT->WRONG 0**: `r10earl85repro/g2_earl85.sv` 1, `g3_ov85.sv` 1,
`g2_leaf85.sv` 2, `r10v85repro/arms/va1_unary85.sv` 1, `va4_leaf85.sv` 2.

---

## 2. THE DEFECT — § `compOpUnsignedReadSignedCompare86v`

`arms/va9_elabedge86.sv` and `arms/va7_signcmp86.sv`, built with
`--elabuhdm` / `-elabuhdm`:

```systemverilog
localparam logic[23:0] e_gt = ~(('h1 << (((1 << 63) > 5) + 3)) - 1'b1);
```

| | golden | pristine | patched (shipped) |
|---|---|---|---|
| the reduced Rhs | `INT:7` | **`INT:7`** | `INT:15` |

`(1 << 63)` reduces to `UINT:9223372036854775808` at size 64. The comparison
that consumes it is `ExprEval::reduceCompOp`
(`~/git-repos/UHDM/templates/ExprEval.cpp:1667-1668`):

```c++
int64_t v0 = get_uvalue(invalidValueI, reduc0);
int64_t v1 = get_uvalue(invalidValueI, reduc1);
...  case vpiGtOp: val = (v0 > v1); break;
```

— an **UNSIGNED read landing in a SIGNED variable**, so every ordered arm
compares two `int64_t`. `9223372036854775808` read that way is negative, and
Surelog answers `BIN:0`. The shipped transcription kept both operands in
`uint64_t` and answered `BIN:1`, so the shift amount became 4 instead of 3 and
the whole parameter became 15 instead of 7.

**Why this is a REGRESSION and not another residue.** In the `--elabuhdm`
view the PRISTINE binary is RIGHT: it leaves the tree unfolded and
`UHDM::UhdmAdjuster` reduces it with **this very `ExprEval`**, landing on
golden. The patched binary pre-folds it with the wrong comparison and the
adjuster then only propagates the wrong constant. That is the view
`Earlgrey_0_1/testflags` and every `-elabuhdm` test in both corpora runs in.

Measured, JUDGE payload, `--elabuhdm`:

| arm | shipped patch | after the fix |
|---|---|---|
| `va9_elabedge86.sv` | SAME 56 **RIGHT->WRONG 6** | **SAME 62, R2W 0, W2O 0** |
| `va7_signcmp86.sv` | SAME 18 **RIGHT->WRONG 5** W2O 1 | **SAME 23, W2R 1, R2W 0, W2O 0** |

and in the plain view the same six/six cells were MOVED-WRONG and are now
WRONG->RIGHT (`va9` W2R 19 -> **25**, `va7` W2R 2 -> **8**). `==` and `!=` did
not move in either direction — signedness cannot change an equality, which is
exactly the discrimination the decode predicts.

**The fix** (`src/ExprEmit.cpp`, inside `srlgReduceOpFold86`'s comparison arm):
read both operands with the unsigned reader as before, then compare them as
`int64_t`. Five lines plus the decode comment. Nothing else in the pass
changes: the implementer's five arms score **exactly** their published numbers
with the fixed binary (§ 4 C).

---

## 3. What ELSE was tried and did NOT break

Eleven arms, both views, three databases each (Surelog GOLDEN + both frozen
binaries), every child `</dev/null` with its rc recorded, scored on the JUDGE
payload (spans stripped) **and** the FULL payload (spans in). The two payloads
give **identical bucket counts on all twenty runs** (the eleventh arm was added after the fix and is scored in ARMS.r10v86.txt section F) — the spans land where
golden puts them on interfaces, gen scopes, three-instance grids and every
operator corner, which is an independent confirmation of the implementer's
`populateCoreMembers(child, child, result)` decode.

| arm | what it adds over the implementer's grid |
|---|---|
| `va1_iface86.sv` | **the INTERFACE home** — absent from `g3_anc86.sv` entirely — x gen-if / gen-for inside an interface x 3 interface instances x a module taking the interface as a port |
| `va2_over86.sv` | OVERRIDDEN parameters as subtree LEAVES (int / `logic[7:0]` / `bit signed[7:0]` / untyped / `signed[7:0]` / `signed`), both operands overridden, unary over an overridden leaf, package leaves bare and qualified, x **3 instances with DIFFERENT overrides and one with none** |
| `va3_pos86.sv` | POSITIONS: the shift AMOUNT, the shift BASE, a base carrying the unsized literal, a SUBTRACT operand, BOTH operands, the root being the shift itself, a sibling branch, a comparison operand |
| `va4_sign86.sv` | the § `valueRangeImplicitSigning86` widening stressed: `signed [0:0] [3:0] [7:0] [15:0] [31:0]`, bare `signed`, `unsigned`, untyped, **HEADER-declared and not overridden**, in a gen-if and a gen-for, read foldably (`+`) and bare (through a `^` carrier golden never folds) |
| `va5_shape86.sv` | `A+B+C`, `A+(B+C)`, `(A+B)*C`, `A+(B*C)`, `(A-B)*C`, a ternary with a **PARAM condition** (4 shapes + a nested one), a CONCAT inside a foldable subtree, `$clog2` inside (3 shapes), `$bits`, LITERAL-ONLY subtrees, a BARE identifier amount (4 shapes), bit- and part-selects |
| `va6_edge86.sv` | two unsized-based literals added (size(-1) propagation), a nested bail, comparisons against unsized operands, negative operands through both readers, enum and typedef leaves, `'o1 'b1 'd1 'sh1` carriers |
| `va7_signcmp86.sv` | **the comparison reader's signedness** (the defect) |
| `va8_struct86.sv` | a module instantiated inside a gen-for and a gen-if, **three hierarchy levels**, nested generate scopes, a NEVER-INSTANTIATED module (DEF only), and two ELAB copies whose values must not leak (the walk MUTATES the operand vector in place) |
| `va9_elabedge86.sv` | the `--elabuhdm` corners: top-bit-set comparisons, shift counts of 63 / 64 / 70, bit and logical ops over top-bit-set operands, `+` overflow, unary minus, power and modulo corners |
| `vaA_pow86.sv` | `**` results that do NOT fit a double's 53-bit mantissa (`7**20`, `3**39`, `5**25`, `2**60`, `3**41`), `<<<` / `>>>`, signed `/` and `%` with a negative divisor |
| `vaB_tern86.sv` | the TERNARY SHORT-CIRCUIT's corners: a **PACKAGE-parameter condition** (earl85's leaf fold refuses those, so OUR condition stays a `ref_obj` where Surelog's is a constant), a comparison condition, a condition with a top-bit-set operand, nested ternaries, arms of different kinds, a ternary under the concat and replication fences, and an untaken `/0` arm — **W2R 16 / R2W 0 / W2O 0** plain, **R2W 0 / W2O 0** elab |

Two findings worth stating because they are the interesting NEGATIVES:

* the walk **mutates the emitted operand vector in place**, so a shared Rhs
  would leak one instance's values into another. It does not:
  `va2_over86.sv` `c_oi` is `8 / 11 / 8` across `i0 / i1 / i2` and golden is
  `8 / 11 / 8`, **including the size split** (`sz64` where the parameter was
  overridden, `sz32` where it was not). `va8_struct86.sv` carries the same
  test three hierarchy levels down and through a gen-for, W2R 34 / R2W 0.
* the `**` arm is transcribed with `powl` (long double) where Surelog uses
  `std::pow<int64_t>` (double). `vaA_pow86.sv` puts five results outside a
  double's exact range through it and finds **R2W 0 / W2O 0** — the concern is
  refuted, not assumed away. The one STILL cell there (`p_ovf`, `3**41`) is
  the pass's own declared out-of-range refusal.

---

## 4. The scoreboard

`ARMS.r10v86.txt` has every run. Summed over the first ten verifier arms x two views:

| | WRONG->RIGHT | **RIGHT->WRONG** | WRONG->OTHER | STILL-WRONG |
|---|---|---|---|---|
| the SHIPPED patch | 328 | **11** | 27 | 179 |
| after the fix | **342** | **0** | **14** | 179 |

The 14 remaining MOVED-WRONG cells are ALL downstream of two **pre-existing**
leaf defects the pass did not create and does not claim (§ 5, R1 and R2); no
cell moves away from golden for any reason inside this law.

**C. the implementer's own five arms, re-measured with the FIXED binary** —
every published number reproduced, none moved by the fix:

| arm | plain | elab |
|---|---|---|
| `g1_ops86.sv` | SAME 44 W2R 27 R2W 0 W2O 0 STILL 1 | SAME 71 W2R 1 STILL 0 |
| `g2_leaves86.sv` | SAME 109 W2R 51 R2W 0 W2O 0 STILL 2 | SAME 144 W2R 16 STILL 2 |
| `g3_anc86.sv` | SAME 37 W2R 18 R2W 0 W2O 0 STILL 20 | SAME 57 W2R 0 STILL 30 |
| `g4_neg86.sv` | SAME 30 W2R 2 R2W 0 W2O 0 STILL 4 | SAME 31 W2R 1 STILL 4 |
| `g5_leaf85copy86.sv` | SAME 61 W2R 2 R2W 0 W2O 0 STILL 1 | SAME 64 W2R 0 STILL 0 |

---

## 5. Ranked residues (measured, with the arm and corpus counts)

**R1 — earl85's OVERRIDDEN-leaf size rule is wrong for a RANGED declaration.**
`elabParamOpLeafValueFold85` stamps `VpiSize(ovL ? 64 : src->VpiSize())`.
Measured through a `^` carrier golden never folds
(`arms/va2_over86.sv` row `c_xs`, `parameter signed [7:0] OVS` overridden to
`8'sd7`): golden's leaf is `constant sz=8 INT:7`, ours is `sz=64 INT:7`.
Row `c_xr` (`parameter signed OVR`, no packed range, overridden) is `sz=64` in
golden AND in ours. **The `64` is right only when the declaration carries no
explicit packed range; with one, Surelog uses the declared width.** 8 of the
14 MOVED-WRONG cells are this defect propagating into a folded value's size
(`c_ol` `c_ob` `c_os` golden `sz32` vs ours `sz64`) or into a `~` mask width
(`c_ong` golden `sz8 UINT:253` vs ours `sz64 UINT:18446744073709551613`).
Pre-existing: pristine's leaf is equally wrong. 0 corpus cells today.

**R2 — a 1-bit SIGNED parameter's leaf value is not sign-extended.**
`localparam signed [0:0] B_S1 = 1'sb1`: golden's leaf is `INT:-1`, ours is
`INT:1` in BOTH binaries (`arms/va4_sign86.sv` row `z_s1`). The remaining 6
MOVED-WRONG cells are that value flowing into a fold (`a_s1`: golden `INT:2`,
ours `INT:4`). Pre-existing, and one level below anything earl86 touches.

**R3 — the comparison arm still refuses a size(-1) operand.** `reduceCompOp`
RESIZES it in place (`ExprEval.cpp:1657-1661`); the pass does not model that
and keeps the operation. `arms/va6_edge86.sv` `e_cmp` / `e_cm2`. A refusal,
never a wrong answer.

**R4 — `**` outside int64.** `3 ** 41` overflows; Surelog casts the double and
we refuse. `arms/vaA_pow86.sv` `p_ovf`, 1 arm cell, 0 corpus cells.

**R5 — the implementer's own R2 (the gen-scope home) reproduced.** 12 arm
cells in `g3_anc86.sv` and 18 more in `arms/va5_shape86.sv`'s ELAB view; a
gen-scope `param_assign` never reaches the bail gate. Still the cheapest next
widening.

**R6 — the interface home is structurally behind, not foldwise.**
`arms/va1_iface86.sv` shows ONLY-GOLDEN 10 / ONLY-OURS 26 in BOTH binaries
(golden lists interface `param_assign`s we place differently) with W2R 20 /
R2W 0 inside the joined rows: the fold itself is right in an interface, the
listing around it is a different law's cell.

**R0 for the next pass is unchanged from the implementer's:**
`flash_erase_ctrl.sv:12:18 PagesPerBank`, `param_assign::VpiOverriden`, 16
corpus cells, both Earlgrey modes on the same object — verified here from the
`HEAD_AFTER` logs of both modes.

---

## 6. The files

| file | what it is |
|---|---|
| `arms/va1..vaB_*.sv` | the eleven adversarial arms (§ 3) |
| `varm86.sh` / `varmF86.sh` | one arm x Surelog + two frozen binaries, plain and `-elabuhdm`, rc recorded, censused with `pacen86` (the F variant drives the verifier-fixed binary) |
| `score86.py` | the implementer's 3-way multiset scorer, unmodified — JUDGE and FULL payloads |
| `vwide86.sh` | the implementer's wide-boundary walk, re-run here unmodified against BOTH binary pairs — run 1 (shipped patch) reproduces the committed artifacts byte for byte; run 2 (patch + fix) gives the SAME tally, the SAME rc histogram and the SAME 17-line differing set, so the fix moves nothing at the boundary |
| `CENSUS.before.surelog.txt` / `CENSUS.afterfix.surelog.txt` | the corpus census, re-run from this verifier's own sweeps |
| `BOUNDARY_WIDE.notes` | what every one of the 17 differing files is, and how the two that are NOT this law were attributed |
| `ARMS.r10v86.txt` | every arm scored: before the fix, after the fix, the implementer's arms, the other authors' arms, and the FULL payload |
| `GATES.r10v86.txt` | the whole battery re-run from this verifier's own binaries |
| `BOUNDARY_WIDE.*` | the wide boundary with the FIXED binary |
| `HEAD_*.cmp` | the verifier's own `uhdm-cmp` head logs |
