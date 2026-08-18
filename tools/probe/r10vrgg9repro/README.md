# r10vrgg9 — ADVERSARIAL VERIFICATION of r10rgg9 § srlgCondOpInstValueTernFold9

**MEASUREMENT ONLY.** The official `uhdm-cmp` remains the sole acceptance judge.
**BASE `0168d0a`.** `results/*.csv` was READ ONLY and is untouched. **No corpus
row was converted; Rggen still does NOT pass `uhdm-cmp`.**

## VERDICT

**ACCEPT WITH A PRODUCTION FIX.** Every headline number in the implementer's
report reproduces BIT-FOR-BIT from binaries I built myself. The law itself
survives 116 fresh adversarial cells against real Surelog — **except one
outcome it did not model**, which broke **13 cells that were RIGHT on the
pristine binary**. Fixed here (§ srlgCondOpSysFuncEvalable9, +1 lambda, +1
early return in `leafValue9`); ship `/tmp/r10rgg9.verified.patch`.

Binaries (all frozen at immutable paths, `SLANG_UHDM` exported explicitly per
binary, every `cmds.txt` audited):

| | md5 | |
|---|---|---|
| base  | `cd92f3869af2f23de95eb3aef497b361` | **identical to the implementer's** |
| pat   | `04b4e446c8a31bd2decfd49767a37ed4` | **identical to the implementer's** |
| ver   | `4753a25ff9cbc08080235072560a7e92` | base + implementer patch + F1 |

## THE DEFECT — a THIRD outcome of `reduceExpr`'s conditional arm

The shipped law modelled two outcomes of Surelog's `ExprEval::reduceExpr`:
folds to `INT:<v> sz 64 ct 7 LOC-LESS`, or `get_value` poisons on a reduced
constant and the ARM'S OWN object is installed. There is a **third**: when the
reduce of the value-producing operand hands back a `sys_func_call` instead of a
`constant` — because `ExprEval` DOES NOT IMPLEMENT that system function —
`reduceExpr` **abandons and the whole `operation` survives**.

The shipped predicate folds whatever **slang** can constant-evaluate. Golden
folds only what **Surelog's `ExprEval`** can. Measured, per cell, on real
Surelog:

```
IMPLEMENTED, golden FOLDS:   $clog2 $bits $size $high $low $left $right
NOT implemented, golden KEEPS THE WHOLE OPERATION:
    $countones $onehot $onehot0 $isunknown $dimensions
    $unpacked_dimensions $increment $rtoi $ceil $sqrt
FOLDS, but to a value slang does not compute (EXCLUDED, refusal = base):
    $signed   `$signed(4'b1111)` golden INT:-7,  slang -1
    $unsigned `$unsigned(-1)`    golden INT:-1,  slang 4294967295
```

**13 pristine-right → patched-wrong cells** (base == golden, patched != golden):

| cell | source | golden & base | shipped patch |
|---|---|---|---|
| `x_countones` | `(P) ? $countones(4'b1011) : 7` | operation kept | `INT:3` |
| `x_onehot`    | `(P) ? $onehot(4'b0010) : 7` | operation kept | `INT:1` |
| `x_isunknown` | `(P) ? $isunknown(4'b0010) : 7` | operation kept | `INT:0` |
| `x_dims`      | `(P) ? $dimensions(vec) : 7` | operation kept | `INT:1` |
| `y_onehot0`   | `(P) ? $onehot0(4'b0010) : 7` | operation kept | `INT:1` |
| `y_increment` | `(P) ? $increment(vec) : 7` | operation kept | `INT:1` |
| `y_unpkdims`  | `(P) ? $unpacked_dimensions(vec) : 7` | operation kept | `INT:0` |
| `y_rtoi`      | `(P) ? $rtoi(3.7) : 7` | operation kept | `INT:3` |
| `y_ceil`      | `(P) ? int'($ceil(3.2)) : 7` | operation kept | `INT:4` |
| `y_sqrt`      | `(P) ? int'($sqrt(16.0)) : 7` | operation kept | `INT:4` |
| `y_arm_op_cnt`| `(P) ? ($countones(4'b1011)+1) : 7` | operation kept | `INT:4` |
| `y_arm_cat_cnt`|`(P) ? {1'b0,$countones(4'b1011)} : 7` | operation kept | `INT:3` |
| `y_pred_cnt`  | `($countones(4'b1011)) ? 42 : 7` | operation kept | `INT:42` |

The last three force the two shape clauses of the fix: the guard must be
**DEEP** (the sys call may sit inside an operation, a concat or a cast) and it
must cover the **PREDICATE**, not just the arm.

It must NOT be pushed into `operandOk9`: golden's `constantOperands` accepts a
`sys_func_call` OPERAND unchecked, and cell **`y_untk_cnt`**
(`(P) ? 42 : $countones(...)`, P=1) **folds on golden** — the implementer's
clause-3 transcription is right and stays.

### The fix (F1), `src/ModuleEmit.cpp`, `emitContAssigns`

`srlgSysEvalable9` — a `makeVisitor` walk of the value-producing expression
that refuses any `CallExpression::isSystemCall()` whose name is not in a
**CLOSED** whitelist of the seven measured-implemented functions — called at
the top of `leafValue9`, the single place a VALUE is taken (every nested
predicate and the final taken arm). Refusal reproduces the base binary exactly.

**Result: BROKEN 0 on all 116 cells, and every FIXED count preserved.**

| grid | base-vs-pat | base-vs-ver |
|---|---|---|
| cells (51) | FIXED 35 / OK 171 / STILL 11 / NOGOLD 1 | **same** |
| cells2 (15) | FIXED 16 / OK 62 / STILL 2 | **same** |
| cells3 (20) | **BROKEN 4** / FIXED 9 / OK 68 / STILL 5 | **BROKEN 0** / FIXED 9 / OK 72 / STILL 5 |
| cells4 (15) | **BROKEN 9** / FIXED 6 / OK 47 | **BROKEN 0** / FIXED 6 / OK 56 |
| implementer's 57-cell grid | FIXED 41 / OK 214 / **BROKEN 0** / STILL 6 | **identical** |
| the 3 boundary movers | FIXED 4 / BROKEN 0 | **identical** |

The fix is **CORPUS-NULL**: patched-vs-verified is **0 movers over 1358**
uhdm2rtlil databases, and over 956 surelog databases the only byte difference
is `default/Scoreboard` — the documented ~50/50 parallel-parse coin, attributed
ORDER-BLIND (sorted whole-dump diff = **0 lines**; four serial base runs and two
serial ver runs all produce md5 `44c0ee47c8e6702e12dcd2998fd962bb`). Rggen's
own database is **byte-identical** between pat and ver, and all 694 boundary
files are byte-identical between pat and ver.

## WHAT I REPRODUCED, BIT FOR BIT

* both binaries built from scratch in my own worktrees — **both md5s match the
  implementer's exactly**;
* goldens **23/0** on base, pat and ver; `SLANG_UHDM=/bin/false` **0/23**;
* uhdm2rtlil `--mode both`: **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**
  per mode; **0 differing ROWS over 1462** base→pat and base→ver, and **0** vs
  the committed `results/gate_uhdm2rtlil.csv` (its 731 rows are the *testflags*
  mode — comparing it against a both-mode CSV is a 731-row artefact, not a
  regression);
* surelog `--mode both`: **0 differing ROWS over 1588** base→pat, base→ver,
  pat→ver, AND my base reproduces the committed `results/golden_surelog.csv`
  **byte for byte** (0 rows);
* `cmds.txt` audit: 1523/1523 (surelog) and 1358/1358 (u2r) carry the intended
  frozen binary; **0** cmds.txt in any workdir names a foreign binary;
  **rc=139 count 0** everywhere;
* census: Rggen 7620 cont_assigns, golden-vs-base **2**, golden-vs-pat **0**,
  golden-vs-ver **0** — and the two rows are exactly
  `u_block_0.g_register_{2,4}...68:11 write_data`;
* head: **122 → 76 cmp lines, 1 head**, both for pat and ver;
* grid: the implementer's 57 cells reproduce **FIXED 41 / OK 214 / BROKEN 0 /
  STILL 6**, NODB 0, NOSLANG 0, `rcaudit9.sh` rc=0 on all 57 for both binaries,
  **0 rc=139**;
* boundary over rgg1/2/5/6/7/8 + vrgg2…8 (**694 files**, subdirectory arms
  included, children `</dev/null`, file list on fd 3, positive control asserted):
  594 identical, **3 MOVERS — all three r10rgg1's own ternary cells**, 97
  uncompilable **rc 3/3 symmetric**, 0 asymmetries, **0 SEGFAULT**; the rgg8 +
  vrgg8 grid is 206 files inside that run with **0 movers** (I count 3
  uncompilable-by-both / 203 byte-identical, where the implementer reported
  10/196 — either way its FIXED 96 / BROKEN 0 / CRASH 0 cannot have moved);
* canaries: `canaudit` audited 29, UNCOVERED 0, FENCE-BREACH 0; `canaries.sh`
  ok=52 changed=0 (surelog) and ok=16 changed=0 (u2r); `ctcan2.sh` ok=58
  changed=0; **SVSwitch `4842211c4030`** and **YosysVerx `6ccda350c24a`** intact
  (md5 of `slang.uhdm`, first 12); InterfaceModPort / BlackParrotComplex /
  YosysOldOr / FuncInModule databases byte-identical base↔ver; FuncInModule
  stays CMP_EQUAL with an unchanged dump column.

## WHAT SURVIVED THE ATTACK (116 fresh cells, all rc=0, 0 rc=139)

Every "passes unchecked" arm of the operand gate is CORRECT, measured one shape
per cell with a CONSTANT taken arm so only the untaken operand varies:

* untaken **operation / concat / replication / bit_select / unpacked-array
  select / hierarchical ref / packed-struct member / interface member /
  `$bits`** → golden **FOLDS**, and so do we (`v_untk_*`, all FIXED);
* untaken **part_select / indexed_part_select / plain variable** → golden
  **KEEPS**, and so do we (OK);
* taken **bit_select / part_select / hier_path / operation-containing-a-net** →
  golden **KEEPS** (OK).

Predicate provenance and shape: **defparam** (`v_pred_defpar`), cast, a local
function call, a **package** function call, `<`, `>>`, `!=`, `==`, `&&`, `||`,
`!`, a **bit-select of a packed parameter**, a **nested ternary predicate**, a
real-parameter compare, a string-parameter compare — all fold to golden's exact
object. **x / z predicates** (`v_pred_xz`, `v_pred_z`) and a **specparam**
predicate: golden KEEPS, we KEEP.

Arms: `'0 '1` sized/unsized, decimal, hex, binary, `-4'd1`, exactly-64-bit
(`INT:-1`), **65-bit** (arm's own `HEX sz 65 @8:25` object — the poison path,
FIXED), `$clog2/$bits/$size/$high/$low/$left/$right`, `2**5`, a string concat,
an unpacked-array parameter element, a **recursive** function (`INT:6`), a
`case` function, a param concat/replication.

Contexts: module body, **1 / 2 / 3 instances with mixed overrides**, nested
module instantiation, comma-list cont-assign, LHS = plain net / vector
bit-select / part-select / indexed part-select / concat / 2-D unpacked element
/ packed-struct member / interface member, `assign #1`, `assign (strong0,
strong1)`, a wildcard package import.

Recursion / self-reference: **rc is 0 on every one of 312 arm-cell dispatches**
across three binaries; no `rc=139` anywhere in this pass.

## RESIDUES I MEASURED THAT THE REPORT DOES NOT NAME

* **V1 — the fold silently stops at 33 levels of ternary nesting.** The
  implementer's `for (int g9 = 0; g9 < 32 && ...)` cap is a real boundary, and
  I bisected it: depth 30/31/32 fold (matching golden), **depth 33 and 34 do
  not, and golden folds them** (`cells/v_deep{30..34}`, golden at 33 =
  `INT:42 LOC-LESS`). Refusal direction only — never a wrong value, never a
  crash — but it is a legal-SV miss the report presents as unbounded.
* **V2 — an x/z-valued PARAMETER arm folds on golden to a plain `INT`, not to
  the parameter's own object.** `localparam logic [3:0] XZ = 4'b10xz` in the
  taken arm gives golden `INT:2 sz 64 ct 7 LOC-LESS` — Surelog's value
  conversion reads the binary digits and stops at the first `x` (`"10"` → 2).
  The README's stated reason for refusing ("a poisoning PARAMETER read would
  install the parameter's own constant") is **REFUTED**; the refusal is still
  the safe choice, but for a different reason (`v_takn_xzparam`).
* **V3 — Surelog's evaluator folds several things to values slang does not
  compute**, so where golden folds and we now also fold, the VALUE can differ:
  a for-loop function body (`x_fnloop` golden `INT:3`, slang 6), a while-loop
  body (`x_fnwhile` golden `INT:-4611686018427387903`), a shift past the word
  (`x_shiftbig` `1<<100` golden `68719476736`, slang 0), `$signed`/`$unsigned`
  (V-fix excludes these two). All four are STILL on both binaries — base kept
  the operation — so none is a regression, but they mark where the value model
  and `get_value` provably part company.
* **V4 — `$bits` of a TYPE PARAMETER** (`w_typeparam`): golden keeps
  `sys_func_call:$bits`, we fold to 16. Contaminated by a pre-existing DEF-view
  bug (base already folds it inside the operation), so it scores STILL, not
  BROKEN; `$bits` stays whitelisted because every non-type-argument `$bits`
  cell folds on golden.
* **V5 — a REAL-typed elaborated parameter** is `constant(ct=9,sz=32,UINT:1)`
  on golden and `REAL:1.000000` for us, and our real DECOMPILE prints
  `1.000000` where golden prints `1.0` / `1.5` (`v_pred_real`, `v_takn_real`).
  Unrelated to this law, pre-existing on base, unnamed anywhere I could find.
* Confirmations of the report's own residues, with extra cells: **R1** gen-scope
  (`v_genif`, `v_genfor` × 2 instances — golden folds, we keep), **R2**
  interface-body cont_assign (`v_iface_ca`), **R3** port high-conn (golden
  installs the ARM's own `DEC:42 sz 8 @5:21` object — note it is the arm object,
  not an `INT:64`, so the `tps`-null clause 4 is corroborated).

## FILES

`gen_vgrid9.py` writes `cells/`; `cells3/` and `cells4/` are the two
evaluator-power grids (generated inline, sources committed). `run_vgrid9.sh`
dispatches REAL SURELOG plus any number of slang binaries per cell, records
**rc per binary per cell**, prints and counts NODB / NOSLANG / SEGFAULT, and
emits the cell list on fd 3. `vboundary9.sh` is the boundary driver with
`</dev/null`, per-file rc, an fd-3 list and two positive controls.
`SCORE_*.txt` are three-way (base/pat/ver) joins scored by the implementer's
own `score9.py`. `GATES.txt`, `CENSUS.txt`, `RCAUDIT.txt`,
`vrgg9_BOUNDARY_*.txt` carry the runs.
