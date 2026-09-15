# r11v42 — ADVERSARIAL VERIFIER of r11u42 (§ `hpTrailSelPkgFold42`)

**VERDICT: ACCEPT-WITH-FIX.** The claimed conversion is real and reproduces
bit for bit — `struct_member_expr_index` converts in BOTH modes — but the
admission test the patch shipped is WRONG on three measured faces, and on two
of them **pristine was RIGHT and the patch was WRONG** on legal SV. This
directory carries the refutations, the corrected law
(§ `pkgFoldTaintAndHomeScope42V`), and the re-gated battery.

**MEASUREMENT-ONLY probes.** `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`,
v1.87) and `scripts/verify_golden.py` are the only judges. slang, Surelog,
UHDM and uhdm2rtlil were NOT patched; `results/*.csv` were READ ONLY;
`GOLDEN_DEFER` stayed unset; no driver here dispatches the four slang-fenced
tests (`canaudit.sh` FENCE-BREACH=0). **LHS is ALWAYS golden (Surelog); RHS is
ALWAYS ours**, in every table and every script.

| | |
|---|---|
| base | `b34a0b3c`, verifier worktrees built from source `-j 2` |
| pristine binary | md5 `3d25111fd1adc7ffa1b393b18a05cf20` — **the ops pin, reproduced from a clean `b34a0b3c` tree** |
| r11u42's patched binary | md5 `156b8c10d2f67b7af38968e991f2da75` — **reproduced bit for bit from `/tmp/r11u42.patch` (md5 `aebaa539585aa4a0367304e38aeda030`), which applies clean on a fresh `b34a0b3c`** |
| VERIFIED binary | md5 `1607e1d7226351b52b2eba2442d3bb45` (this directory’s fix on top) |
| production surface | `src/ExprEmit.cpp` only |

---

## 1. The head, re-measured at `b34a0b3c` (my own pristine build)

`struct_member_expr_index`, u2r, **both** modes, `grep -c '^LHS:'` = **1** head
each, 76 cmp lines, and the two modes' heads are ID-BLIND IDENTICAL
(`evidence/HEAD.pristine.struct_member_expr_index.{default,testflags}.cmp`).
The head walks `hier_path` → `ref_obj: (value)` → `bit_select` →
`operation` → both `constant`s, and **every one of those lines agrees**; the
LAST cell is the name:

```
LHS: ... |vpiName:value.mantissa[23 - 1]
RHS: ... |vpiName:value.mantissa[p::MAN_BITS - 1]
```

Both sides' index operation carries the same `|vpiDecompile:23 |vpiSize:32
|UINT:23` and `|vpiDecompile:1 |vpiSize:64 |UINT:1`. **The name TEXT is the
row's only judged difference**, exactly as claimed and as
`tools/probe/r11v29repro/evidence/splits.txt` records it.

The converted row's leftover `dump: differ` is 24 lines, all `vpiFullName`
(`p::arr_t.pair` vs `p::p::arr_t::pair`) plus two `vpiParent` lines.
`ref_typespec::Compare` (`~/git-repos/UHDM/build/generated/src/ref_typespec.cpp:123`)
reads `VpiName`/`VpiDefName` and never `VpiFullName` — the dump SYNTHESISES it
(same file, `:43`) — so the residue is judge-invisible.
(`evidence/DUMPDIFF.verified-vs-golden.struct_member_expr_index.default.txt`.)

## 2. The producer — the citations check out

`CompileHelper::compileSelectExpression` spells the bracket at
`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:1504`
(`idx_str = "[" + decompileHelper(idx) + "]"`), `:1520` per `var_select`
dimension, `:1523` `hname.append(".").append(field_name).append(idx_str)`,
`:1537` the trailing range; `CompileHelper::decompileHelper`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:2544`) is the closed
dispatch `constant`→VpiDecompile, `ref_obj`→VpiName, `operation`→
`ExprEval::prettyPrint`, `bit_select`→bracketed. All four line numbers are
correct in the pinned v1.87 trees. **The name is a function of the compiled
index OBJECT** — that much of r11u42's model stands.

## 3. THREE REFUTATIONS of r11u42's admission test

Every cell below is golden from the pinned Surelog, measured with
`names42v.sh` (a KEYED join on `line:col`, never `paste`), all rcs 0.
`evidence/GRID.pristine-vs-r11u42patch.REFUTATIONS.txt`.

**(A) The concat abstain is not the top-level initialiser kind — 4 MOVED-WRONG cells.**
r11u42 abstains when the package parameter's initialiser IS a concatenation or
replication. Golden abstains for more:

| initialiser | golden | pristine | r11u42 |
|---|---|---|---|
| `CATN  = {2'b10,2'b01} + 0` | `v.m[pv5::CATN - 1]` | **right** | `v.m[9 - 1]` ✗ |
| `CATADD= {2'b10,2'b01} + 0` | `v.m[pa8::CATADD - 1]` | **right** | `v.m[9 - 1]` ✗ |
| `REPADD= {2{2'b01}} - 0` | `v.m[pa8::REPADD - 1]` | **right** | `v.m[5 - 1]` ✗ |
| `CATPAR= ({2'b10,2'b01})` | `v.m[pa8::CATPAR - 1]` | right | right (parens are transparent in slang) |
| `CATCALL=$clog2({2'b10,2'b01})` | `v.m[4 - 1]` | wrong | **right** (taint stops at a call) |

**(B) A read inside the DECLARING package is still symbolic — 4 MOVED-WRONG cells.**
The fold exists because Surelog compiles packages before modules. Inside the
declaring package's own body the substitution has not happened yet:

| site | golden | pristine | r11u42 |
|---|---|---|---|
| `pa7`'s own TASK, `a.m[LP-2]` | `a.m[LP - 2]` | **right** | `a.m[8 - 2]` ✗ |
| `pa7`'s own CLASS method, `a.m[LP-3]` | `a.m[LP - 3]` | **right** | `a.m[8 - 3]` ✗ |
| `pa7`'s own FUNCTION, `a.m[LP-1]` | def-view `a.m[LP - 1]` (elaborated copy `a.m[7]`) | **right on the def-view** | `a.m[8 - 1]` ✗ on both |
| `pa7`'s own function, QUALIFIED `a.m[pa7::LP-1]` | def-view `a.m[8 - 1]` | wrong | right |
| `pb8`'s function reading IMPORTED `LP` | def-view `a.m[8 - 1]` | wrong | right |

So the gate is narrow: **unqualified AND lexically inside the declaring
package**. (The landed MIXED builder carried the same over-fold before this
pass — arm v8 c02 — and the fix corrects it there too.)

**(C) A QUALIFIED `'d` literal does not keep its base — 6 AWAY cells, two of them
on a COMMITTED landed arm r11u42 never re-ran.**
`tools/probe/r10earl29repro/v1_scope.sv` c22/c24: `parameter logic [1:0] SP =
2'd1` read as `pkv::SP` is golden's `q.autoexecprogbuf[{1'b1,1}]`; r11u42 wrote
`{1'b1,2'd1}`. Arm v9 c04 `pz9::CNT = 2'd2` is golden's `q.w[{2{{1'b1}}}]`;
r11u42 wrote `{2'd2{...}}`. The discriminator is the QUALIFIER, not the base:
the SAME `2'd1` read UNQUALIFIED (wildcard-imported `PP`,
`tools/probe/r10earl29repro/b3_edges.sv` c35) is golden's `{1'b1,2'd1}` —
spelling kept. `4'hA`, `8'hA` and `32'h0000_000C` keep their base either way.
Arm **v11** re-measures (C) at the LANDED MIXED builder and finds the same
law — and a PRE-EXISTING wrongness there: golden names
`arr[0].m[pz11::SPD+2]` (`SPD = 2'd1`) `arr[0].m[1 + 2]` while PRISTINE
wrote `arr[0].m[2'd1 + 2]`. The verified binary fixes that landed cell too,
and leaves the unqualified read's `2'd1 + 2` (golden's own spelling) alone.

## 4. THE CORRECTED LAW (§ `pkgFoldTaintAndHomeScope42V`)

> A package parameter read folds into a hier_path's bracket text **unless**
> (A) its initialiser is CONCAT/REPLICATION-TAINTED — taint reaches through the
> operator tree and through a parameter RELAY, and STOPS at a call — or
> (B) the read is UNQUALIFIED and written inside the declaring package's own
> declaration. When it does fold it carries the initialiser literal's own
> spelling, separators stripped, **except** that a QUALIFIED read of a
> DECIMAL-BASED literal (C) carries plain digits.

All three refinements are gated on `aggregateAbstain34`, the flag the
element-select sites already pass, so the range arm is byte-unchanged.
`src/ExprEmit.cpp`: `concatTainted42V`, `insideOwnPkgText42V`, and the three
guards inside `collectPkgParamFolds`.

**(B) is SYNTAX ANCESTRY, not source offsets.** The first cut of this fix
tested buffer+offset containment and arm **v10** refuted it: a package body
that arrives through an `` `include `` — *the UVM packaging style* — puts the
read in a different BUFFER from the `package` keyword, the offset test said
"outside", and the fold fired where golden's package def-view keeps
`a.m[LP - 1]` (`evidence/GRID.v10-include-shape.offsettest-vs-ancestrytest.txt`:
one pristine-right → patched-wrong cell, found and closed BEFORE shipping).
The syntax parent chain spans the include and answers correctly in both
shapes; the offset test survives only as the fallback for a read with no
syntax node.

## 5. The re-gated grid

11 verifier arms (`grid42v/v1…v11`), 256 keyed cells, every rc recorded:

| | pristine SAME | VERIFIED SAME | FIXED | MOVED-WRONG |
|---|---|---|---|---|
| v1 value kinds | 20/34 | **34/34** | 14 | 0 |
| v2 spelling/macro | 8/25 | 19/25 | 11 | 0 |
| v3 scopes/instances | 12/22 | 20/22 | 8 | 0 |
| v4 views | 14/29 | 24/29 | 10 | 0 |
| v5 concat inits | 16/24 | **24/24** | 8 | 0 |
| v6 three instances | 8/12 | **12/12** | 4 | 0 |
| v7 in-package sites | 11/23 | 15/23 | 4 | 0 |
| v8 taint + mixed site | 27/41 | 29/41 | 2 | 0 |
| v9 concat context | 9/22 | 15/22 | 6 | 0 |
| v10 `include`d package body | 2/6 | 4/6 | 2 | 0 |
| v11 `'d` at the MIXED builder | 16/18 | **18/18** | 2 | 0 |

**MOVED-WRONG 0 in every arm, and AWAY 0**: the only cells where the verified
binary's text differs from pristine without matching golden are the package
def-view/elaborated PAIRS, where golden carries TWO names for one source site
(`a.m[7]` elaborated + `a.m[LP - 1]` def) and the verified binary matches the
def one where pristine matched neither — an improvement my set-valued scorer
prints as `MOVED-AWAY`, shown cell by cell in the evidence.

r11u42's OWN arms, rescored by this directory's keyed join:
**g1 49/49 SAME, g2 32/32 SAME, 28 FIXED, 0 MOVED-WRONG** — the verified binary
keeps every cell r11u42 claimed.

**61 LANDED witness arms** re-run pristine-vs-verified
(`r10earl34repro`, `r10uvm92repro`, `r11u34repro`, `r10uvm79repro`,
`r10earl29repro`; `evidence/LANDED.51arms.verified.r11v42.txt`):
**MOVED-WRONG 0, AWAY 0, 12 cells FIXED** (earl29 `v1_scope` 4 + `b3_edges` 2,
uvm92 `g92_a1_ppgrid` 2 + `v92_b1_break` 4). The landed hier-path laws' own
witnesses all stand. The ten arms of the four most recent hier-path passes
(`r11u37/38/39/40repro`, the multi-step element law among them) are
pristine-IDENTICAL cell for cell
(`evidence/LANDED.recent-hierpath-passes.r11v42.txt`); two of them build no
hier_path at all and are reported as teaching nothing rather than as green.

## 6. Census, with its controls

* **Calibration golden-vs-golden FIRST**: 1742 u2r golden databases,
  **FOLD-CAND 0, DBASE-CAND 0** — golden never leaves a package-parameter
  identifier or a `'d` literal in a bracket. Golden is a fixed point.
* **POSITIVE CONTROL** (a census zero needs one): the pristine
  `struct_member_expr_index` database reads **FOLD-CAND**, 8 cells by name; the
  r11u42-patched `v1_scope` database reads **DBASE-CAND**, 4 cells by name.
  Both detectors fire.
* **A priori, from PRISTINE databases, before the verified binary swept**:
  u2r 1608 databases → **FOLD-CAND 2 / DBASE-CAND 0**, both
  `struct_member_expr_index` (default + testflags), 8 cells each, BY NAME;
  surelog **all 960** databases (957 in one pass, the three over 20 MB in a
  second) → **DBASE-CAND 0** and **FOLD-CAND 2 — both `Earlgrey_0_1`**, whose
  candidate cells are `flash_ctrl_i.addr[0+:BankAddrW]` and
  `read_buf[i].addr[FlashWordsW+:PageW]`. Those are INDEXED PART-SELECT widths,
  the arm this law is NOT wired into, and `Earlgrey_0_1` is CMP_EQUAL — so
  **golden keeps those identifiers too** (`hier_path::Compare` reads `VpiName`),
  and the cells are a MUST-NOT-MOVE prediction, not a conversion one. They do
  not move (byteverify below, and the byte pins hold). Stage-1 source
  predictor: 777 surelog tests → 29 fire candidates (reproduces r11u42's
  number).
* A **SHAPE LISTER** is printed beside every census (`cen42v.py`).

**PREDICTED CONVERSIONS: `struct_member_expr_index` ×2, and nothing else.**

## 7. Gates (all green)

* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
* u2r, VERIFIED binary, both modes, the conversion quoted:
  `< struct_member_expr_index,default,CMP_NOTEQUAL,decompile:,,`
  `> struct_member_expr_index,default,CMP_EQUAL,,,differ` (and the same row in
  `testflags`) — **779/25/67 → 780/24/67 in BOTH modes**, every other row
  identical; pristine-vs-committed control **0 differing rows**.
* u2r byteverify vs my own pristine workdir: **MOVERS 2 / 1608**, exactly the
  two predicted by name; SELFCHECK 1607/1608. Verified-vs-r11u42-patched:
  **0 / 1608** — the fix is corpus-invisible, it only re-gates faces the corpus
  does not contain.
* surelog, both modes: histogram unchanged cell for cell, **474/9 default +
  469/8 testflags**; the only row differences against my own pristine sweep are
  two `SURELOG_FAIL` detail strings embedding the workdir path — **no status
  moved in either mode**. cmds.txt audit: all 1531 `slang:` lines name the
  frozen verified binary.
* surelog byteverify: **MOVERS 5 / 960**, all in the documented UVM coin family
  (`MiniAmiq` ×2, `SeqDriver` ×2, `SimpleUVM`), each a 4-line ORDER-BLIND diff
  of ONE constant's `vpiDecompile`/`UINT` — a line number, which this law never
  writes. The attribution is reproduced from scratch: the PRISTINE binary
  alone, three runs on identical argv, gave three different databases
  (`b4ceda6bc631`/`c04e5b9b6dab`/`547f53338e3c`) flipping the SAME two dump
  lines (`evidence/MOVERS.surelog.attribution.r11v42.txt`). All five rows stay
  CMP_EQUAL — the UVM family's converted status is untouched.
  (r11u42's own sweep moved the same family, 5 databases by my measurement
  rather than the 4 it reported; the fifth, `Scoreboard/default`, is the
  ~50/50 task-list ORDER coin whose order-blind diff is 0 lines.)
* byte pins HELD: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
  InterfaceModPort `59a365f3ce2c`, BlackParrotComplex, YosysOldOr,
  Earlgrey_0_1 (`8bdf25272e08` default / `59d0ee6d10c3` testflags).
  canaries u2r ok=8 changed=0 (both modes) and surelog ok=52 changed=0,
  ctcan2 PASS in both corpora (surelog ok=58 changed=0), canaudit audited=29
  UNCOVERED=0 FENCE-BREACH=0. `Earlgrey_0_1` — the corpus's ONLY fold
  candidate — is byte-identical in both modes.

## 8. Residues

* **R1** the converted row's `pkg::pkg::` `ref_typespec` fullname family
  (judge-invisible; do NOT fix uniformly — campaign memory).
* **R2** an index whose text comes from a MACRO does not fold (arm v2 c04/c05);
  `rawTextPkgFold` abstains on macro locations by construction.
* **R3** a hier_path through an INTERFACE INSTANCE (`u_if.v.m[pv3::LP-1]`,
  arm v3 c09) is built by another builder and still does not fold — golden does.
* **R4** a multi-dimension `var_select` trailing index
  (`av.pr[pv4::LP-7][pv4::LP-5]`, arm v4 c05) keeps raw text on both binaries.
* **R5** where golden folds a CONCAT-DERIVED value it prints the value's own
  base (`32'b1001`); this model ABSTAINS there rather than write a decimal
  golden never writes (arm v8 c07/c08/c09) — a miss, not a move.
* **R6** inside a package, golden's ELABORATED copy is FULLY reduced (`a.m[7]`)
  while its def-view keeps the identifier; we emit the def-view text twice
  (arm v7 c01) — one of two copies right, where pristine also had one.
* **R7** the RANGE / indexed-part-select arm (`aggregateAbstain34=false`) is
  deliberately byte-unchanged, and the census says that is the right call:
  the ONLY fold candidates in the whole surelog corpus are `Earlgrey_0_1`'s
  `addr[0+:BankAddrW]` / `addr[FlashWordsW+:PageW]`, where the row is
  CMP_EQUAL — golden keeps the identifier in a part-select width. Extending
  the fold to that arm would BREAK a byte pin. Whether (A)/(B)/(C) apply there
  in some other shape is unmeasured.

## 9. Reproducing

```bash
WD=/tmp/w GRID=$PWD/grid42v PRIS=<pristine> PAT=<verified> ./names42v.sh v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11
python3 cen42v.py --label L --jobs 2 <sweep-workdir-root>      # census + SHAPE LISTER
./attrib42v.sh <rootA> <rootB> <relpath>                       # order-blind mover attribution
```
