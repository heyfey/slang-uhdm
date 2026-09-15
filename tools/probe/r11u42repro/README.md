# r11u42 — § `hpTrailSelPkgFold42` — **THE PACKAGE LEAF OF A TRAILING MEMBER-SELECT INDEX CARRIES ITS VALUE INTO THE PATH NAME, AT THE PLAIN-BASE SITE TOO** — `struct_member_expr_index` ×2 CONVERTS

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang,
Surelog, UHDM and uhdm2rtlil were **NOT** patched; `results/*.csv` were **READ
ONLY** and **NOT EDITED**; `GOLDEN_DEFER` stayed unset. The four slang-fenced
tests were never dispatched by any driver here; they are named only inside
`canaudit.sh`'s own `FENCED=` list, and its `FENCE-BREACH=0` is the check that
it worked.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b34a0b3c` |
| pristine binary | md5 `3d25111fd1adc7ffa1b393b18a05cf20`, built `-j 2` from this pass's OWN worktree at a clean `b34a0b3c` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm` at that commit** |
| patched binary | md5 `156b8c10d2f67b7af38968e991f2da75`, frozen `chmod 555` before any sweep |
| production surface | `src/ExprEmit.cpp` ONLY. **One collected fold table and the two call sites that consume it** — and the table is the one `emitMixedHierPath` has used since § `hpMixedIdxPkgFold34`. No new flag, no new pass, no new object, nothing reshaped: the patch only ever rewrites BRACKET TEXT inside a name that already existed. |
| probe surface | `tools/probe/r11u42repro/` only |

---

## THE LAW

> **§ hpTrailSelPkgFold42.** A hier_path's bracket text is `decompileHelper`
> applied to the compiled index **OBJECT**, and in that object a **package**
> parameter read has already been reduced to a `constant` — Surelog compiles
> packages before modules — while a module's own parameter or localparam is
> still a `ref_obj`. So a **package** leaf carries its **VALUE** into the name
> and every other scope carries its **IDENTIFIER**; the arithmetic AROUND the
> leaf does **not** reduce (`Reduce::No`), so the name reads `23 - 1`, never
> `22`. The **only** package leaves that stay spelled are those whose
> initialiser is a **concatenation or replication**. This law was implemented
> for `emitMixedHierPath` and the range-select arm; the **plain-base trailing
> member select** — `obj.member[idx]`, the builder entered when there is no
> select on the base — was handed a **null** table and kept its own raw text.
> That is r10uvm92's README residue **R3**, and it is closed here.

**The producer, cited in the pinned trees.**
`CompileHelper::compileSelectExpression` builds the name at
`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:1504`
(`idx_str = "[" + decompileHelper(idx) + "]"`, one index), `:1520` (per
dimension of a `var_select`) and `:1537` (a trailing range), appending
`"." + field_name + idx_str` at `:1523`.
`CompileHelper::decompileHelper`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:2544`) is the closed
dispatch: `constant`→`VpiDecompile`, `ref_obj`→`VpiName`,
`operation`→`ExprEval::prettyPrint`, `bit_select`→`"[" + … + "]"` for exactly
those three index kinds and **nothing** otherwise.
`UHDM::ExprEval::prettyPrint` (`~/git-repos/UHDM/templates/ExprEval.cpp:950`)
renders a `constant` by `VpiDecompile` and spaces every binary operator (and no
unary one) — which is why golden's spelling is `23 - 1` and `-8 + 9`.

The same two call sites carry the lvalue variants at
`CompileHelper.cpp:2485`/`2489` and `:4675`/`4677`.

---

## 1. THE HEAD, RE-MEASURED AT `b34a0b3c` ON THIS PASS'S OWN PRISTINE BUILD

`struct_member_expr_index`, uhdm2rtlil, **both modes**, `grep -c '^LHS:'` = **1**
head each (`evidence/HEAD.pristine.struct_member_expr_index.{default,testflags}.cmp`).

```
LHS:
decompile:
hier_path: (value.mantissa[23 - 1]), id:143, line:36:26, endln:36:55
…
  \_bit_select: (work@dut.value.mantissa[23 - 1].mantissa), id:148
  |vpiIndex:
  \_operation: , id:146
    |vpiOpType:11
    |vpiOperand:  \_constant: |vpiDecompile:23 |vpiSize:32 |UINT:23 |vpiConstType:9
    |vpiOperand:  \_constant: |vpiDecompile:1  |vpiSize:64 |UINT:1  |vpiConstType:9
|vpiName:value.mantissa[23 - 1]
RHS:
hier_path: (value.mantissa[p::MAN_BITS - 1]), id:123, line:36:26, endln:36:55
    … the SAME operation, the SAME two constants (23 size 32, 1 size 64) …
|vpiName:value.mantissa[p::MAN_BITS - 1]
```

Note what that head already proves about the LAW: **golden's own index object
holds `constant 23`** — the package read is folded in the OBJECT, the
subtraction is not folded at all, and `22` appears nowhere.

**The name text IS the row's last judged cell.** The whole-dump diff
(`evidence/DUMPDIFF.pristine.struct_member_expr_index.default.txt`, 158 lines)
holds exactly two families, and only one is judged:

* the **four** hier_path names (`value.mantissa[…-1]`, `value.mantissa[…-23]`,
  `value.exponent[…-1]`, `av.pair[…-22]`). `hier_path::Compare` reads
  `Path_elems`, `Root_value`, then **`VpiName`**, and both sides' elements are
  already byte-identical — so this is the whole judged difference;
* a `ref_typespec` **fullname** family (`p::arr_t.pair` vs `p::p::arr_t::pair`)
  plus two `vpiParent` lines. `ref_typespec::Compare`
  (`~/git-repos/UHDM/build/generated/src/ref_typespec.cpp:123`) reads
  `VpiName`, `VpiDefName` and `Actual_typespec`, and **never** `VpiFullName`;
  no generated `Compare` reads `VpiParent`. **Judge-invisible** — this is the
  row's CMP_ONLY residue (R1), and it is why the converted row's `dump` column
  reads `differ`, not `match`.

---

## 2. THE GOLDEN GRID  (question 3)

`grid42.sh` + `grid42/{g1,g2}/dut.sv`: two arms, **27 cells**, one REAL Surelog
golden each, **every rc recorded** — `SURELOG_RC=0`, `OURS_RC=0`,
`GOLDEN_DUMP_RC=0`, `OURS_DUMP_RC=0` on both arms and on BOTH binaries (an arm
whose compile failed would teach error recovery, not golden).
`evidence/GRID.pristine.r11u42.txt`, `evidence/GRID.patched.r11u42.txt`.

Axes: index-expression KIND × parameter SCOPE × path DEPTH × VIEW.

| cell | source | golden | pristine ours | patched ours |
|---|---|---|---|---|
| qualified pkg localparam | `v.m[q42::LP-1]` | `v.m[8 - 1]` | `q42::LP - 1` | **= golden** |
| qualified pkg parameter | `v.m[q42::PP-1]` | `v.m[4 - 1]` | `q42::PP - 1` | **= golden** |
| BARE qualified read | `v.m[q42::LP]` | `v.m[8]` | `q42::LP` | **= golden** |
| unary over a pkg leaf | `v.m[-q42::LP+9]` | `v.m[-8 + 9]` | `-q42::LP + 9` | **= golden** |
| two binary ops | `v.m[q42::LP*2-14]` | `v.m[8 * 2 - 14]` | `q42::LP * 2 - 14` | **= golden** |
| conditional | `v.m[q42::LP>2?1:0]` | `v.m[8 > 2 ? 1 : 0]` | `q42::LP > 2 ? 1 : 0` | **= golden** |
| TWO pkg leaves | `v.m[q42::LP-q42::PP]` | `v.m[8 - 4]` | `q42::LP - q42::PP` | **= golden** |
| wildcard-imported, bare | `v.m[LP-1]` | `v.m[8 - 1]` | `LP - 1` | **= golden** |
| array member (element, not bit) | `av.pr[q42::LP-7]` | `av.pr[8 - 7]` | `q42::LP - 7` | **= golden** |
| path depth 2 | `nv.inner.m[q42::LP-1]` | `nv.inner.m[8 - 1]` | `q42::LP - 1` | **= golden** |
| procedural LVALUE | `rv.m[q42b::LP-1]` | `rv.m[8 - 1]` | `q42b::LP - 1` | **= golden** |
| procedural rvalue | `q = v.m[q42b::LP-1]` | `v.m[8 - 1]` | `q42b::LP - 1` | **= golden** |
| function body | `return a.m[q42b::LP-1]` | `a.m[8 - 1]` | `q42b::LP - 1` | **= golden** |
| **module localparam** | `v.m[MLP-1]` | `v.m[MLP - 1]` | already right | **UNMOVED** |
| **module parameter** | `v.m[MPP-1]` | `v.m[MPP - 1]` | already right | **UNMOVED** |
| **concat-init pkg lp** | `v.m[q42::CATP-1]` | `v.m[q42::CATP - 1]` | already right | **UNMOVED** |
| **repl-init pkg lp** | `v.m[q42::REPP-1]` | `v.m[q42::REPP - 1]` | already right | **UNMOVED** |
| **sys_func_call index** | `v.m[$clog2(q42::LP)]` | `v.m` (group GONE) | already right | **UNMOVED** |
| **base-select (mixed builder)** | `arr[0].m[q42b::LP-1]` | `arr[0].m[8 - 1]` | already right | **UNMOVED** |
| **base-select index** | `arr[q42b::PP-4].m[3]` | `arr[4 - 4].m[3]` | already right | **UNMOVED** |
| literals | `v.m[7]`, `v.m[7-1]`, `av.pr[1]`, `rv.m[0]` | unchanged | already right | **UNMOVED** |

**PRISTINE 13 SAME / 14 DIFF → PATCHED 27 SAME / 0 DIFF. MOVED-WRONG 0,
AWAY-GOLDEN 0** — not one cell that agreed with golden before disagrees after.

The concat/replication pair is § `hpMixedIdxPkgFold34`'s V-F1 gate re-confirmed
here at **OBJECT** level, not merely in text: golden's operand for `q42::CATP`
stays a `ref_obj: (q42::CATP)` (arm g1 line 44). That is why
`aggregateAbstain34` is passed **true**, exactly as the mixed builder passes it.

---

## 3. THE CENSUS AND THE A-PRIORI MOVER PREDICTION  (question 5)

`ct42cen.py` is the census **and** the SHAPE LISTER that must sit beside one:
per database it prints every distinct `hier_path` `VpiName`'s shape
(`dotted<N>/{no-sel,trail-sel,base-or-mid-sel}`, `bare`) and flags a database
`CAND` when some top-level bracket group of some path name still spells a
**package-scope** parameter by identifier. Package parameters are read from the
dump's own labels (`\_parameter: (pkg::NAME)`; `work@mod.NAME` is not one).

The predictor is **sound by construction**: the fold table reaches only
`idxTxt9`, `idxTxt9` reaches only a hier_path NAME, so a database can move only
if one of its path names changes, and a name can change only if its bracket text
mentioned a package parameter.

### 3a. CALIBRATION, GOLDEN-vs-GOLDEN, FIRST

**uhdm2rtlil goldens — every cached golden the corpus uses, 1742 databases:
`CAND 0 / 1742`, `CELLS 0`, `BAD 0`.** In the whole uhdm2rtlil golden corpus
there is not ONE hier_path name whose bracket text still spells a package
parameter: **golden always folds, and golden is a FIXED POINT of this law.**
(`evidence/CENSUS.golden.u2r.r11u42.txt`.)

**Instrument controls, on the grid databases**
(`evidence/CENSUS.controls.r11u42.txt`):

| control | reading |
|---|---|
| golden-vs-golden, grid | `CAND 1/2`, and its two cells are exactly `v.m[q42::CATP - 1]` / `v.m[q42::REPP - 1]` — **the class golden does NOT fold**, so a residual CAND is a law, not a bug |
| POSITIVE control, pristine ours | `CAND 2/2`, **16 cells** — the instrument SEES movers |
| NEGATIVE control, patched ours | `CAND 1/2`, **the same two golden cells** — the patched side lands on golden's own residual set, cell for cell |

### 3b. THE PREDICTION, WRITTEN FROM PRISTINE DATA ALONE

**uhdm2rtlil — the exact census over ALL 1608 pristine databases (both modes):
`CAND 2 / 1608`, `CELLS 8`, `BAD 0`** — and both are the same test:

```
CAND …/default/struct_member_expr_index-8c9e49bc/slang.uhdm ::
  av.pair[p::MAN_BITS - 22] | value.exponent[p::EXP_BITS - 1]
  | value.mantissa[p::MAN_BITS - 1] | value.mantissa[p::MAN_BITS - 23]
CAND …/testflags/struct_member_expr_index-8c9e49bc/slang.uhdm :: (the same four)
```

Golden calibration on the surelog side is restricted to the fire set's own
goldens under 10 MB (**42 databases, `CAND 0 / 42`,
`evidence/CENSUS.golden.surelog-fireset.r11u42.txt`**) — outside the fire set
our text does not change, so golden's spelling there cannot bear on this pass;
the corpus-scale golden calibration is the uhdm2rtlil one above.

**surelog — two stages.** `predict42.sh sl` reads SOURCES only (no compile, no
dispatch, so the fenced tests are unreachable from it) and narrows **777 tests
with sources to 29 FIRE-CANDIDATES** — a design must BOTH declare a `package`
AND write a dotted member select with a letter inside its brackets. Of those 29,
**19 databases exist** in the pristine sweep (the rest are `SLANG_REJECT`,
`SURELOG_FAIL` or `DEFERRED` — a row with no database cannot move). The exact
census over those 19: **`CAND 0 / 19`, `CELLS 0`, `BAD 0`.**

> **PREDICTED, BY NAME, BEFORE THE PATCHED BINARY TOUCHED EITHER CORPUS:
> exactly TWO movers — `struct_member_expr_index` default and testflags —
> and ZERO on the surelog corpus. PREDICTED CONVERSIONS: `struct_member_expr_index`
> ×2, CMP_NOTEQUAL → CMP_EQUAL. No other row moves in either direction.**

**WHAT ACTUALLY MOVED: 2 / 1608 on uhdm2rtlil — exactly the two predicted, by
name — and 4 / 960 on surelog, ALL FOUR the documented pristine-nondeterministic
UVM pair (§4a), reproduced on the PRISTINE binary alone and `CAND 0` under the
exact census. Row conversions: `struct_member_expr_index` ×2, as predicted, and
nothing else in either corpus or mode.**

---

## 4. GATES

| gate | reading |
|---|---|
| build | both binaries `-j 2`, md5s taken separately; **pristine `3d25111fd1adc7ffa1b393b18a05cf20` = the main tree's own binary at `b34a0b3c`**; patched `156b8c10d2f67b7af38968e991f2da75`; every `cmds.txt` audited by binary PATH (`slang: /tmp/r11u42_patched.bin`) |
| goldens | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` negative control **0 PASS / 23 FAIL** |
| uhdm2rtlil testflags | pristine **779/25/67 = the committed `results/gate_uhdm2rtlil.csv`, 0 differing rows**; patched **780/24/67**, `ct8rows` shows **ONE** differing row and it is the law-named one |
| uhdm2rtlil default | pristine **779/25/67**; patched **780/24/67**, `ct8rows` shows the same single row |
| the CONVERTED row, quoted | `< struct_member_expr_index,testflags,CMP_NOTEQUAL,decompile:,,` → `> struct_member_expr_index,testflags,CMP_EQUAL,,,differ` and `< struct_member_expr_index,default,CMP_NOTEQUAL,decompile:,,` → `> struct_member_expr_index,default,CMP_EQUAL,,,differ` |
| uhdm2rtlil byteverify | `SELFCHECK=1`: `PATH_SETS_IDENTICAL (1608)`, **MOVERS 2 / 1608 — exactly the two predicted, by name** — `SELFCHECK 1607 / 1608 flagged` (the comparator can see) |
| u2r canaries | `canaries.sh` **ok=8 changed=0 absent=0**; `EXPECT_UNKNOWN=6 ctcan2.sh` **PASS** |
| canary audit | `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| surelog | 1596 rows; status histogram **474/9 default + 469/8 testflags UNCHANGED cell for cell — NO ROW CONVERTED IN EITHER DIRECTION**; `byteverify` MOVERS **4 / 960**, all four attributed to the documented pristine nondeterminism with a pristine-only positive control (§4a) |

### 4a. THE SURELOG CORPUS — NO ROW CONVERTED IN EITHER DIRECTION

1596 rows. **Both mode columns scored, and the status histogram is UNCHANGED
cell for cell**, pristine → patched and against the committed
`results/golden_surelog.csv` alike:

```
default    474 CMP_EQUAL   9 CMP_NOTEQUAL   5 DEFERRED  285 SLANG_REJECT  25 SURELOG_FAIL
testflags  469 CMP_EQUAL   8 CMP_NOTEQUAL   5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
```

`ct8rows` against the committed baseline reports **3 differing rows, and not one
is a status move**:

| row | reading |
|---|---|
| `LowMemLib,testflags` / `LowMemPkg,testflags` | `SURELOG_FAIL` on both sides; the DETAIL string embeds the sweep's own WORKDIR PATH. **The PRISTINE-vs-committed control shows the same two rows**, so this is a path artefact of the detail text, not this pass. |
| `Earlgrey_0_1,testflags` | `CMP_EQUAL,,,differ` → `CMP_EQUAL,,,` — the **DUMP COLUMN alone**, blank on a `uhdm-dump` timeout draw. The STATUS held `CMP_EQUAL`, and the DATABASE is the pin: `cmp -s` says the two files are **BYTE-IDENTICAL**, md5 `59d0ee6d10c3` (default `8bdf25272e08`), and `byteverify` does not list it as a mover. |

**Protected databases, md5 on BOTH binaries, BOTH modes — every one HELD:**
`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
`InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1` testflags `59d0ee6d10c3` /
default `8bdf25272e08`, `BlackParrotComplex` SAME, `YosysOldOr` SAME.

**Canaries:** `canaries.sh` **ok=51 changed=1 absent=0**, and the one `changed`
is the Earlgrey dump-column draw above (`CMP_EQUAL/differ -> CMP_EQUAL/`).
`EXPECT_UNKNOWN=1 ctcan2.sh` **PASS, ok=58 changed=0**.

**MOVER RULE — the UVM family.** `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`,
`SimpleUVM`, `Scoreboard` are **CMP_EQUAL before and after in every mode they
have a row for** (Scoreboard/testflags is `SLANG_REJECT` on both sides, byte
for byte).

**byteverify surelog: `PATH_SETS_IDENTICAL (960)`, MOVERS 4 / 960, SELFCHECK
959 / 960 flagged.** The four are `MiniAmiq` ×2 and `SeqDriver` ×2 — **NOT
predicted, and attributed in full** in
`evidence/MOVERS.surelog.attribution.r11u42.txt`:

* **the move is not this law's shape** — workdir-normalised, RAW **and**
  ORDER-BLIND (sorted) alike, each is **4 dump sides**, and all four are ONE
  `constant`'s value at ONE dump line: MiniAmiq `|vpiDecompile:1524 -> 1260`
  (and its `|UINT:`), SeqDriver `|vpiDecompile:787 -> 0`. Those are LINE
  NUMBERS; § `hpTrailSelPkgFold42` writes hier_path / bit_select NAME STRINGS
  and nothing else, and cannot write a constant's `UINT`;
* **POSITIVE CONTROL** — the **PRISTINE** binary alone, three runs on identical
  argv, produced **three different databases** (`ea5962b0cfc8`, `9e096e5515fc`,
  `b4206470d463`, none equal to the pristine sweep's own `a5ed10104679`), and
  the a-vs-b pair flips **at the same two dump lines, 1820474 / 1820476**
  (`1101 -> 1059`). The a-vs-c pair shows 80 sides — the wider macro-buffer
  `SourceLocation` class. **MiniAmiq is nondeterministic per invocation with no
  patch involved;**
* **the exact census** over those four PRISTINE databases: **`CAND 0 / 4`** —
  the law has no reachable cell in either test, in either mode;
* **the judge did not move**: all four rows are `CMP_EQUAL` on both binaries.

That also closes the one hole in the stage-1 superset: `predict42.sh sl` scans
each `.sl` file's OWN directory, and a test whose sources are reached only
through `+incdir+` (the UVM family) therefore never becomes a fire candidate.
The exact stage-2 census does not have that hole, and it was run on every byte
mover the sweep actually produced.

---

## 5. WHAT THE MOVE IS, AT THE BYTE LEVEL

The patched-vs-pristine dump diff of the moved database is **56 sides, one
family, REWRITE-ONLY** — nothing added, nothing removed, no object minted or
dropped:

```
< hp value.mantissa[p::MAN_BITS - 1]      > hp value.mantissa[23 - 1]
< hp value.mantissa[p::MAN_BITS - 23]     > hp value.mantissa[23 - 23]
< hp value.exponent[p::EXP_BITS - 1]      > hp value.exponent[8 - 1]
< hp av.pair[p::MAN_BITS - 22]            > hp av.pair[23 - 22]
   … and each one's `|vpiName:` and its bit_select's derived `|vpiFullName:`
```

The patched-vs-**golden** dump diff falls from **158 lines to 46**, and **zero**
of the remaining 46 mention a hier_path or a path name: they are the
judge-invisible `ref_typespec` fullname + `vpiParent` family alone
(`evidence/DUMPDIFF.patched-vs-golden.struct_member_expr_index.default.txt`).

---

## 6. RESIDUES

* **R1 — the converted row's CMP_ONLY residue.** `struct_member_expr_index` is
  now `CMP_EQUAL` with `dump: differ`. The 46 remaining dump lines are a
  `ref_typespec` **fullname** shape (`p::arr_t.pair` against our
  `p::p::arr_t::pair`) on a package struct's `typespec_member`s, plus a
  `vpiParent` golden does not print. No generated `Compare` reads either field,
  so this is invisible to the judge; it belongs to the `pkg::pkg::` naming
  family the campaign has recorded as **context-dependent — do not "fix"
  uniformly**.
* **R2 — the sibling `dyn_field_select` is NOT this face.** Its two paths carry
  the SAME `VpiName`; what differs is `Path_elems` SHAPE. It stays a singleton.
* **R3 — the concat/replication-initialised package parameter.** Golden keeps
  the IDENTIFIER (`v.m[q42::CATP - 1]`) and so do we, both before and after —
  but WHY Surelog leaves those two unreduced was not decoded here, only
  measured (arm g1 cells c08/c09, at object level). Corpus population: zero.
* **R4 — the lvalue bracket sub-arm.** When a TRAILING select is an lvalue and
  its index is a kind `decompileHelper` has no row for, the inner bracket text
  is still rendered from raw source text without the fold table. Grid
  population: zero; corpus population: zero (the census found no such cell on
  either corpus).

---

## R0 — what the next pass should take

**`dyn_field_select`** is the other half of the dissolved K11 and it is a
DIFFERENT face: golden nests a `bit_select(tbl[row_i])` carrying a `vpiIndex`
where we emit ONE composite `ref_obj` literally named `tbl[row_i][col_i]`. That
is a `Path_elems` SHAPE gap, not a name-text gap, and § `hpCompMultiSelElemShape`
(the pass-37 multi-step element law) is the nearest landed neighbour.

---

## 7. HOW TO REPRODUCE

```bash
# the grid (both binaries)
OURS=<binary> WD=<scratch> tools/probe/r11u42repro/grid42.sh
# the a-priori prediction, stage 1 (sources only)
tools/probe/r11u42repro/predict42.sh dirs ~/git-repos/uhdm2rtlil/test
tools/probe/r11u42repro/predict42.sh sl   ~/git-repos/Surelog/tests \
                                          ~/git-repos/Surelog/third_party/tests
# the census / shape lister, stage 2 (databases)
tools/probe/r11u42repro/ct42cen.py --roots <sweep workdir or golden cache dirs> \
                                   --label <name> --jobs 2
# the gates
tools/probe/r11u42repro/ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 tools/probe/r11u42repro/byteverify.sh <patched wd> <pristine wd>
tools/probe/r11u42repro/canaries.sh <fresh.csv> <baseline.csv>
EXPECT_UNKNOWN=<n> tools/probe/r11u42repro/ctcan2.sh <baseline.csv> <fresh.csv>
(cd tools/probe/r11u42repro && ./canaudit.sh canaries.sh ctcan2.sh)
```
