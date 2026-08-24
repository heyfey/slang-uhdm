# r10v121 — ADVERSARIAL VERIFICATION of r10uvm121 / § `thisSuperNewAssignEmpty121`

**VERDICT: ACCEPT — production unchanged.**  Every headline number of the
implementer's report reproduced BIT-FOR-BIT on binaries this verifier built
itself, and nine purpose-built arms over axes the implementer's grid never
varied found **ZERO** pristine-right → patched-wrong cells.

**MEASUREMENT-ONLY probes.**  The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`)
and `scripts/verify_golden.py` are the authorities.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY** (the copies in this worktree) and **NO CORPUS
ROW WAS CONVERTED**.  **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `9e04993`, worktrees `/tmp/wt_v121` (patched) + `/tmp/wt_v121pris` (pristine) |
| patch verified | `/tmp/r10uvm121.patch` — `git apply -3` rc 0, 0 conflicts, and `git apply --check --reverse` of the applied tree rc 0 (the tree is EXACTLY base+patch, nothing else) |
| production surface | `src/ExprEmit.cpp` ONLY (+113 lines) — confirmed by enumerating every `diff --git` path |
| fence check | the four slang-fenced names (they are NOT spelled here; `canaudit.sh` is their authority) — 0 hits each in the patch outside `canaudit.sh`, on the implementer's patch and on this one |
| pristine md5 | `0939d5a31f760a196a231823eb75ad7f` — **reproduced** |
| patched md5 | `ca06e73aebcf65fc3b26f5d623a377b2` — **reproduced** |

## 1. WHAT WAS REPRODUCED, INDEPENDENTLY

Both binaries rebuilt from scratch (`cmake --build build -j 2`, md5 taken
separately) and FROZEN `chmod 555` at `/tmp/v121_pris.bin` / `/tmp/v121_pat.bin`
BEFORE any sweep.  `SLANG_UHDM` exported explicitly per binary; every `cmds.txt`
audited BY BINARY PATH.

| claim | implementer | this verifier |
|---|---|---|
| binary md5s | `0939d5a3…` / `ca06e73a…` | **identical** |
| goldens | 23 PASS / 0 FAIL; `/bin/false` → 0/23 | **23/0**, negative **0/23**, pristine also **23/0** |
| uhdm2rtlil, both modes, vs committed baseline AND own pristine | 0 differing rows, 679/50/2 | **0 differing rows** in all three comparisons; **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, dump histogram 183/187 differ unchanged |
| surelog, both modes, vs committed baseline AND own pristine | 0 differing rows over 1588 | **0 differing ROWS (0 row-sides)** in both comparisons; 471+466 = **937 CMP_EQUAL**, 10+9 = **19 CMP_NOTEQUAL**, unchanged |
| `cmds.txt` audit | 1523 surelog + 1458 u2r, one binary each | **1523/1523 and 1458/1458**, and **zero** references to any other `slang-uhdm` path in 1573+1462 files |
| byteverify `SELFCHECK=1` | 9/956 · 0/1358 | **MOVERS 9/956** and **0/1358**; SELFCHECK 955/956 and 1357/1358 |
| a-priori prediction | 9 DBs, 26 cells, from 2314 pristine DBs | **re-run from MY OWN pristine sweeps: 9 DBs, 26 cells, byte-identical to `PREDICTION.txt` (WIDE counts included)** — `PREDICTION.v121.txt` |
| census, 12 UVM row-modes | SAME 123697 · OURS-FULL 26→0 · EMPTY-BOTH 0→26 · GOLD-FULL 0 · DIFF 16 · ONLY-G 808 · ONLY-O 892 | **every number identical**, and the per-row-mode blocks diff clean against the committed `CENSUS.{pristine,patched}.txt` |
| grid | `g121_a` 19/21/**0**/0/0 + rc 0 · `g121_b` 10/1/**0**/4/1 | **identical, both** |
| heads | 13→148 (SimpleUVM ×2, Scoreboard/def, BuildUVMPkg ×2); 50/50, 36/36, 0/0 unchanged | **identical**, and the 148-line head is **byte-identical** to the committed `raw/head_pat_default_SimpleUVM.cmp` |
| unchanged heads | "byte-identical" | **verified**: SeqDriver ×2, MiniAmiq ×2, Earlgrey ×2 `cmp` logs are byte-identical pristine vs patched |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **identical** |
| protected DBs | 3 byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **all ten row-modes byte-identical**, both pins exact |
| attribution | added = 0, removed = only the law's lines | **546 removed / 0 ADDED** over all 9 movers, order-blind (sorted, path-normalised); the union of removed line texts is exactly `assignment`/`method_func_call (new)`/`hier_path (this.default_alloc)`/`ref_obj (this)`/`ref_obj (…::default_alloc)` and their labels |
| boundary, file mode | DIFFER=10, both views, PROCESSED==LISTED, rejects symmetric | **the SAME TEN ARMS, NAME FOR NAME**, both views (my run adds 5 because my own arms are in the tree copy) |
| boundary, dir mode | DIFFER=10 (def) / 9 (elab) | **10 (def), name for name; 11 (elab)** — the extra is `r10uvm88repro`, proved ORDER-ONLY below |

## 2. THE SURELOG DECODE, RE-DERIVED FROM SOURCE

`CompileHelper::compileBlockingAssignment` (`CompileHelper.cpp:4456`) was read in
full.  The implementer's account is exact: the routine picks
`Variable_lvalue = fC->Child(Operator_assignment)` unless the node is already a
`paVariable_lvalue`/`slStringConst`, then tries three arms
(`paHierarchical_identifier || slStringConst`, `paVariable_lvalue`,
`Type(Operator_assignment) == paHierarchical_identifier`), and falls out of its
own bottom with `lhs_rf == rhs_rf == nullptr` — after which
`VpiOpType(vpiAssignmentOp)` / `VpiBlocking(true)` / `Lhs(nullptr)` /
`Rhs(nullptr)` run unconditionally.  `SV3_1aParser.g4:2310` and `:3709/:3716`
confirm that BOTH the `class_new` alternative and the `dynamic_array_new`
alternative admit an `implicit_class_handle DOT` prefix, so a written `this.` /
`super.` makes the child a prefix node and all three arms miss.

## 3. TRYING TO BREAK IT — NINE NEW ARMS, EIGHTEEN ARM-VIEWS

`grid_v121.sh` compiles each arm with the REAL Surelog and BOTH binaries in
BOTH views, runs the official `uhdm-cmp`, and scores every cell with the
implementer's `score121.py` (golden as truth).  Full log: `GRID.v121.txt`.

| arm | axis the implementer's grid never varied | def | elab |
|---|---|---|---|
| `v121_a` | **`this.x = new[N]` and `super.x = new[N]` in KEPT slots** (A02/A05/A16/A17 — g121_a has NO `new[N]` cell at all), an **in-body** constructor, `repeat` / `do…while` / `else` / DEFAULT and multi-label `case_item` bodies, **the same statement twice in one body** (A03/A04), a **deeper `this.a.b`** path, `this.super.` (A20), named arguments | **22 TO-GOLDEN / 0 AWAY**, `uhdm-cmp` **rc 0** | **42 / 0**, **rc 0** |
| `v121_b` | class in a **MODULE**, `virtual` base, **parameterized** class, **nested** class, `extern` methods | 0/0, 7 STILL-WRONG (pre-existing, both binaries) — dumps differ ONLY in the `<DB>:` banner | 0/0, 14 STILL-WRONG |
| `v121_c` | **THE NEGATIVE CONTROLS**: bare property, `this.` + non-`new`, another object's property (`other.stud = new`), compound `+=`, NONBLOCKING `<=`, delayed `#1`, an identifier that merely CONTAINS "new" | **4 / 0**, **rc 0** | **18 / 0**, **rc 0** |
| `v121_d` | **out-of-block refs inside the `new` argument list** (§ `oobRefVarLocalHoistNet107`'s family), a **COVERGROUP** `new`, and § 3's DROP slots restated | **3 / 0**, **rc 0** | **7 / 0**, **rc 0** |
| `v121_e` | **`new[n](src)` array-copy**, a **STATIC property written through `this.`**, `virtual` method kept slots, a class in an **INTERFACE**, a class in a **PROGRAM** | 11 / **0** | 21 / **0** |
| `v121_e2` | `v121_e` with the interface removed — proves the 6088-line patched head of `v121_e` is the PRE-EXISTING "class inside an interface is not emitted" gap, unmasked | **11 / 0**, **rc 0** | **21 / 0**, **rc 0** |
| `v121_f` | **ASSERT pass and fail action blocks**, an **event-controlled** statement, a **WAIT body**, an **array-element** lvalue, **array element THEN member**, `super.` reaching a **cross-package** base | 9 / **0** | **17 / 0**, **rc 0** |
| `v121_g` | class at **`$unit` scope**, `function automatic` method, a `static` method beside it | 4 / **0** | 9 / **0** |
| `v121_h` | ROBUSTNESS: unbindable / over-supplied / wrong-typed `new` arguments | `PRIS_RC=3 PAT_RC=3` — **symmetric refusal, no segfault** | same |

**TOTAL: 199 cells TO-GOLDEN, `AWAY-GOLDEN = 0` in all eighteen arm-views, and
nine arm-views reach `uhdm-cmp` rc 0 (CMP_EQUAL to Surelog's own database).**

Two of the arms' remaining patched heads were chased to ground rather than
asserted: `v121_e` def/elab is the interface-class gap (`v121_e2` removes the
interface and the arm goes EQUAL), and `v121_g` is `vpiAutomatic` (§5 R-auto).

## 4. THE ACQUITTAL, RE-DONE FROM SCRATCH

`acq_v121.sh` re-compiles ALONE, with the real Surelog and in BOTH views, the
eight boundary-differing arms that live OUTSIDE this pass's own probe directory,
and scores each against its own golden.  `ACQUITTAL.v121.txt`:

**`AWAY-GOLDEN = 0` in all sixteen arm-views**, 46 cells TO-GOLDEN.  The only
non-trivial cells are `r10svs4repro/v2_copy.sv`'s `CHANGED-STILL-WRONG` pair
(w2 `this.p = new gp;`, w4 `this.parr[0] = new gp;`): golden has **no statement
at all** there (a § `thisSuperNewAssignNoStmt3` DROP slot whose RHS half omits
`CopyClassExpression`), pristine emitted a POPULATED surplus and patched emits
an EMPTY one — strictly closer, never a regression.  That is the implementer's
R-copy121, confirmed.

### 4b. The boundary itself

`BOUNDARY.v121.txt`: four combinations over a COPY of the whole probe tree
(3718 `.sv`/`.v` arms — the implementer's 3712 plus my six), NO path filter.

| | PROCESSED / LISTED | FENCED | DIFFER | rejects |
|---|---|---|---|---|
| file / def | 3718 / 3718 | 0 | 15 | 139 / 139 |
| file / elab | 3718 / 3718 | 0 | 15 | 153 / 153 |
| dir / def | 1547 / 1547 | 0 | 10 | 124 / 124 |
| dir / elab | 1547 / 1547 | 0 | 11 | 130 / 130 |

`PROCESSED == LISTED` in all four; **`asym.txt` does not exist in any of the four
output roots** (no arm accepted by one binary and refused by the other) and no
`FATAL` line was printed.  The ORDER arms were MEASURED, not asserted: the
`r10uvm75repro` directory compiled **four times with the ONE PRISTINE BINARY**
gives raw dumps `4be4500b 2901092c 2bbfb55d c65f8529` and the SORTED dump
`caf8079e` every time — **and the patched binary's sorted dump on that directory
is `caf8079e` too**.  The same identity holds for `r10uvm117repro`,
`r10uvm76repro`, `r10v109repro`, `r10v117repro` and `r10uvm88repro` in BOTH
views (`ACQUITTAL.v121.txt`), so § `pkgVarBindsOnlyThroughInstance88` and the
rest of the bind-window family (buvm13/15/16, uvm90, sd8-12,
§ `controlBodyNoBind28`, § `blkLocalSameCtrlDepthArgBinds57/64`,
§ `superNewFormalBinds28`, § `classInBodyRecvCallArgNoBind52`,
§ `newArrayArgNoBind16`) are proved untouched, and so are the uvm89/92/94/95
hier_path NAME-TEXT arms — none of them differs at all.

## 5. WHAT THIS VERIFIER FOUND THAT THE IMPLEMENTER'S REPORT DID NOT

* **R-doc121 (a factual error in `README.md` §5, no code impact).**  The report
  says `uvm_reg_backdoor.svh:271` and `rggen_backdoor_pkg.sv:34` "are
  subscripted lvalues that are not `ScopedName` roots and that neither law
  reaches".  **Both halves are wrong.**  `this.peg[0] = new;` and
  `this.ring["a"] = new;` (arm `v121_c` C08/C09) parse as a `ScopedName` whose
  root IS a `ThisHandle` — slang hangs the select on the RIGHT-hand
  `IdentifierSelectName` — so the predicate DOES fire, and it is RIGHT to:
  golden empties both (grammar alternative 3 carries `select` after the
  identifier), and both cells score TO-GOLDEN in both views.  `v121_f` F01/F06
  say the same for `this.ridge[0] = new(s)` and `this.ridge[1].kame = new`.
  The CONCLUSION (no mover from those two corpus sites) survives for a different
  reason, measured here: `uvm_reg_backdoor.svh:271` sits inside
  `` `ifdef UVM_USE_PROCESS_CONTAINER `` and is not compiled at all — the object
  in the pristine SimpleUVM database is line **273**, the `` `else `` arm
  `this.m_update_thread[element] = process::self();`, whose RHS is not a `new`
  at all — and `rggen_backdoor_pkg.sv:34` is a § 3 DROP slot.  `this.atomic`
  (`uvm_vreg.svh:779`) appears **0** times in the pristine dump, confirming its
  own drop.
* **The law also covers a COVERGROUP `new`, correctly.**  §3's predicate comment
  says `NewCovergroupExpression` is deliberately excluded; §121 reads the
  SYNTAX, where `this.cg = new;` is a `NewClassExpression`, so it fires — and
  golden is EMPTY there too (arm `v121_d` D03, TO-GOLDEN in both views).  The
  law statement should say so; § `covergroupNewCall7` is untouched because it
  only ever sees BARE lvalues.
* **R-auto121 (new, pre-existing, 0 corpus cells).**  A class method declared
  `function automatic` gets `vpiAutomatic:1` in golden and **nothing** from
  either binary (arm `v121_g`, `$unit`-scope class `Saw::file_it`; the same
  field is present on golden and absent on pristine, so this pass neither
  creates nor repairs it).  It is `v121_g`'s remaining 214-line head.
* **R-modparam121 (new, pre-existing, 0 corpus cells).**  A PARAMETERIZED class
  declared inside a MODULE with `extern` method bodies contributes **no
  assignments at all** from either binary (arm `v121_b`: seven cells golden has
  and we do not emit, in the def view; fourteen in elab).  Both binaries
  identical — their dumps differ only in the `<DB>:` banner.
* **Instrument trap worth recording.**  `uhdm-cmp` returns **rc 0** when the
  RHS database FILE DOES NOT EXIST.  Arm `v121_h` prints `cmp rc=0` on both
  sides while both binaries refused the source (`rc=3`); only `RC.txt`'s
  per-binary rc distinguishes "equal" from "nothing to compare".  Any arm driver
  must record the compile rc separately, and `grid_v121.sh` does.

## 6. RESIDUES CARRIED FORWARD (ranked)

1. **R0 — the next head, verified.**  `bit_typespec (uvm_reg_cvr_t)` from
   `uvm-1.2 src/reg/uvm_reg_model.svh:105`, 148 lines, ONE head, on SimpleUVM
   both modes / Scoreboard default / BuildUVMPkg both modes.  Golden carries a
   `vpiTypedefAlias` `ref_typespec` and a FOLDED `constant INT:31` left bound;
   ours is named `uvm_pkg::uvm_reg_cvr_t`, has no `Typedef_alias`, and its left
   bound is an unfolded `operation` over 32 and 1.  Read off my own patched
   head, byte-identical to the committed evidence.
2. **R-scope121** — `Cls::x = new` / `pkg::x = new` (`g121_b` b08/b09):
   pristine and patched alike emit a populated statement golden omits.  0 corpus
   cells; fixing it widens § 3's DROP half.
3. **R-copy121** — `this.x = new <expr>` as a plain-list element: still a
   surplus, now EMPTY rather than populated.  0 corpus cells.
4. **R-doc121 / R-auto121 / R-modparam121** — §5 above.

## 7. INSTRUMENTS IN THIS DIRECTORY

* `v121_a…h.sv` (+ `v121_e2.sv`) — the nine adversarial arms.
* `grid_v121.sh` — arm driver: real Surelog + both binaries + official
  `uhdm-cmp` + `score121.py`, BOTH views, rc recorded per binary.
* `acq_v121.sh` — the independent boundary acquittal.
* `GRID.v121.txt`, `ACQUITTAL.v121.txt`, `PREDICTION.v121.txt`, `raw/`.
