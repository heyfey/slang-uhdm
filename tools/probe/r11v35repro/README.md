# r11v35 — the ADVERSARIAL VERIFICATION of `§ typeParamAnonAggMemberNoReduce35`

**VERDICT: ACCEPT.** Every headline number in the implementer's report
reproduces on binaries this verifier built itself; the law's direction is
confirmed against real v1.87 goldens on six arms the implementer never wrote,
in every holder, view, shape and use they reach; **AWAY-GOLDEN is 0 on all six**;
no row's status moves in either corpus in either mode; every protected pin
matches; and the one head that moves on an arm is proved UNMASKED rather than
created.

Base `2c3df162`. LHS is ALWAYS golden. Judge: `uhdm-cmp` v1.87.

---

## 1. What was re-measured, not carried

| gate | verifier's own measurement |
|---|---|
| pristine build | `ed6dc5a7d3788f7470cb60667334e6e1` — the OPS pin, and the main tree's own binary at the start of this run |
| law build | `ea7475c5b8d85df95c35d88f457ad930` — the implementer's md5 exactly |
| patch | applies clean on a FRESH `2c3df162` (`git apply -3` rc=0, 0 conflict markers); surface = `src/TypeEmit.cpp` + `include/UhdmExporter.h` + `tools/probe/r11u35repro/`; ONE line removed (the `structMemberSymBound` assignment the new disjunct extends); fence check 0/0/0/0; `results/*.csv` untouched |
| goldens | pristine 23 PASS / 0 FAIL, law 23 PASS / 0 FAIL, `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL |
| u2r, both modes, both binaries | 774 / 30 / 67 each — the committed baseline; the two CSVs are **byte-identical between pristine and law** (0 differing lines in each mode); `ct8rows` PASS against the committed gate and against the verifier's own pristine |
| surelog, both modes, both binaries | 474/9 + 469/8 of 798 — the committed baseline; the two CSVs differ in **4 lines, all of them the `LowMem{Lib,Pkg}` `SURELOG_FAIL` detail string, which embeds the WORKDIR PATH** |
| `cmds.txt` audit | 1742 u2r + 1581 surelog per binary, every one naming the frozen binary; **0 occurrences of the main-tree binary in either sweep** |
| byteverify u2r | 2 / 1608 movers (`cva6_struct_param_field` ×2), SELFCHECK 1607/1608 |
| byteverify surelog | 11 / 960 movers — 6 the law's (the 3 predicted tests × 2 modes), 5 the UVM coin (§3) — SELFCHECK 959/960 |
| protected databases | every one byte-identical pristine↔law and equal to its OPS pin: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 `8bdf25272e08` / `59d0ee6d10c3`; BlackParrotComplex and YosysOldOr SAME |
| `rowheads.sh` | 0 heads on SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg and Earlgrey_0_1, both modes |
| `§ rangeBoundReduceEnc33` | `genscope_struct_member` and `latch_perf_counters` `CMP_EQUAL,match` both modes; `ibex_icache`, `ibex_pmp`, `iface_unpacked_struct_array`, `InterfaceUnpackedStructArrayDim` databases byte-UNCHANGED |
| the four implementer grid arms | re-run with the verifier's binaries: `golden_rc=0 ours_rc=0` on all four, and **`CENSUS.gold` / `CENSUS.law` reproduce byte-for-byte**, scores identical |
| the witness heads | `cva6_struct_param_field` 26:12, `StructParamFieldRange` 24:12, `mem_packed_2d_byte_write` 19:18, `iface_param_2level` 16:10 — all four quoted at the base exactly as briefed |

The law's diff on `StructParamFieldRange`/default is **310 dump lines on source
lines 24 and 25 only**, the implementer's number reproduced exactly.

## 2. The verifier's own six arms — the law tested where the implementer did not

`grid/v1..v6`, each compiled by BOTH producers, both rcs recorded:
**`golden_rc=0 ours_rc=0` on all six for both binaries, Surelog `[FATAL]:0
[ERROR]:0`.** (A seventh cell was dropped after it failed to compile on either
side — an arm whose compile fails teaches error recovery, not golden.)

| arm | what it adds | SET TO-GOLDEN | **AWAY-GOLDEN** | SET MOVED-WRONG |
|---|---|---|---|---|
| `v1_elab35` | the ELAB view: the same module instantiated 3× with `W` overridden (5/8/7) and the type parameter itself overridden, beside an anonymous struct on a VARIABLE, a NAMED module typedef and a plain packed typedef as controls | 3 | **0** | 0 |
| `v2_holder35` | package, interface, **class**, generate block, function body, `$unit`, a non-ANSI body parameter, an anonymous UNION and a NESTED anonymous struct | 7 | **0** | 2 |
| `v3_shape35` | 18 written member-bound shapes in one declaration and the **vpiName of every leaf** the judge reads | 15 | **0** | 1 |
| `v4_use35` | the assignment-pattern localparam, a cast, a port, a function-local, a re-passed type parameter, an anonymous ENUM default, an UNPACKED variable dim | 1 | **0** | 2 |
| `v5_patonly35` | the sharpest break attempt: a default whose type is used ONLY by the pattern localparam Surelog CLONES and REDUCES, beside one used by nothing at all | 1 | **0** | 2 |
| `v6_dims35` | the aggregate's OWN trailing packed dim, and a member that is a packed array of a named typedef | 2 | **0** | 0 |
| **total** | | **29** | **0** | **7** |

**Golden's answer is the law's, in every holder the verifier could write.** On
`v2_holder35` golden keeps `op11(...)` at the package (7:11, 8:11), interface
(19:11), class (24:57), union (35:11, 36:11), nested-struct (42:27, 43:11) and
generate-block (48:50) cells alike — and the law puts us on golden's shape at
every one of them that we emit. On `v1_elab35` golden carries **one symbolic
copy and no folded one** at the type-parameter cells (17:62, 21:11, 22:11) even
though the holder is instantiated three times with three different `W` — while
at the NAMED-typedef control on the same module (27:25) it carries three FOLDED
copies (`INT:4`/`INT:6`/`INT:7`, one per instance) beside the symbolic one.
That is the def-vs-elab fact the law rests on, measured on an arm written from
the producer decode rather than from the corpus.

**The leaf NAMES come out right.** `v3_shape35` reads the `vpiName` of every
operand the judge compares: `W`, `N`, `LW`, `shp35::QW` — golden's name on
every shape the law moves (minus-one, bare, ADD both orders, multiply,
parenthesised multiply, divide, shift, `$clog2`, localparam read, signed,
two packed dims). A literal member dim stays a literal.

### The seven SET MOVED-WRONG, read rather than counted (`cellcmp35.py`)

* **Four of them are the R0 cell and they move us CLOSER.** `v4_use35` 28:11/29:11
  and `v5_patonly35` 16:11/17:11: golden carries **both** shapes there — the
  declaration object keeps the written operation and
  `ExprEval::flattenPatternAssignments`'s CLONE is reduced — 2-to-3 symbolic
  copies against 1 folded. We carry 5 copies, folded before and symbolic after.
  Before: our copies matched golden's single clone and missed its 2-3
  declaration copies. After: the reverse. **Even in the pattern-ONLY arm,
  where the type is used by nothing but the pattern localparam, golden's copy
  set is 2 symbolic + 1 folded** — there is no legal shape in which golden's
  only copy is the fold, so the law's direction is right and the residue is
  the clone, exactly as the implementer's R0 says.
* **Two are the CROSS-PACKAGE LEAF rule, and they are new work the law
  exposes** (a residue, not a regression: both cells were wholly folded — and
  wholly unequal — at the base). `v2_holder35` 24:57, a CLASS type parameter
  whose member reads `pkv35::PW`: golden `op11(constant,constant)` (the package
  parameter's VALUE substituted), ours `op11(ref_obj,constant)`.
  `v3_shape35` 16:15, a `$unit` typedef used as a member type: golden
  `op11(ref_obj,constant)`, two of our four copies `op11(constant,constant)`.
  Our substitution rule fires in one context golden does not and misses one it
  does — see R-B.
* **One is a copy-count artefact** (`v6_dims35` 16:17, MULTISET only).

## 3. Breaking the law: what could NOT be made to fail

* **No CMP_EQUAL row is even a candidate.** The a-priori shape (an anonymous
  aggregate written as a `parameter`/`localparam type` default with at least one
  non-literal member dim) exists in exactly six corpus tests, and **all six are
  `CMP_NOTEQUAL`, `SLANG_REJECT` or row-less at the base**. The law cannot
  demote an equal row in this corpus; it is a structural fact, not a sweep
  result.
* **The two corpus tests that carry the shape with LITERAL bounds only**
  (`packed_array_struct`, `port_chained_type_param`) are byte-UNCHANGED: a
  written literal is not a reduction, and the law does not re-encode one.
* **The UVM family cannot be reached at all.** `grep` for the law's syntax over
  `Surelog/third_party/tests` returns `Ariane2024` ONLY, and over
  `Surelog/third_party/UVM` returns nothing. The 5 non-law surelog movers are
  therefore not this law, and the positive control says what they are: the
  PRISTINE binary alone, re-run from each test's own cwd with its recorded
  argv, moves `MiniAmiq` (both modes), `SeqDriver`/testflags and
  `Scoreboard`/default; and the order-blind dump diff puts all four movers in
  the SAME 4-line class — one `UINT:<n>` / `vpiDecompile:<n>` pair, flipping in
  BOTH directions (`|UINT:0` → `|UINT:1087`, and `|UINT:1169` → `|UINT:0`).
  That is r11u33's R7 uninitialised read, and it is a live per-run coin on
  every sweep of this base.
* **`Earlgrey_0_1,*,CMP_EQUAL,,,differ → CMP_EQUAL,,,` is a HARNESS artefact,
  and the verifier's own PRISTINE sweep shows it too, in both modes.**
  `verify_golden.py`'s `--timeout` defaults to 180 s and the dump column is
  recorded as `''` on `TimeoutExpired` (`scripts/verify_golden.py:626-635`);
  that database's `uhdm-dump` runs for minutes. The database itself is
  byte-identical between the two binaries AND equal to the OPS pin, so the
  dump column cannot have moved: the same bytes hash the same way.
* **The one head that MOVES on an arm is UNMASKED, not created.**
  `v3_shape35`: pristine's head is the law's own cell (21:11), the law's is the
  `$unit` typedef's own bound (16:15) whose cell the census shows **already
  unequal at the base**. `boundscope35.sh` settles the general case: on all
  nine arms and on the corpus movers, **every changed dump line lies inside a
  range-bound expression** — no `module_inst`, no `vpiInstance`, no variable,
  net, port, container list or typespec member changes — so any head that is
  not itself a bound constant/operation was already in the pristine database.
  The same holds for the corpus witness: `StructParamFieldRange`'s new head
  (the UNNAMED-vs-named `struct_typespec`, the implementer's R1) is present in
  the PRISTINE database at the same span with the same name.

## 4. Where the implementer's write-up needed correcting

* **The producer citation `CompileType.cpp:315` is in `compileVariable`, not in
  `compileTypespec`.** The member path the law actually rides is
  `compileTypespec`'s `paStruct_union` arm recursing into each member with the
  caller's `reduce` (`CompileType.cpp:1639` for the arm, the member recursion
  at `:1707-1708`); `:1295` is that function's own trailing-dimension
  `compileRanges`. The two hard-coded `Reduce::No` call sites
  (`CompileHelper.cpp:3475-3476` ANSI, `:3509-3510` `paTYPE`) and the reduction
  test (`CompileExpression.cpp:3963`, `Reduce::Yes` at `:4032`) are cited
  correctly, and the model they support is the one the goldens show.
* **The surelog mover set is a 5-line coin, not a 4-line one.** The verifier's
  sweep moved `SeqDriver` (both modes) where the implementer's moved
  `Scoreboard`/default — different draws of the same documented coin, which is
  itself the proof that neither belongs to the law.
* **`MOVED-WRONG` is not 0** — 2 on the implementer's grid, 7 on the
  verifier's. Every one is read out above; none is a cell that agreed with
  golden before, and the four on the R0 cell move us from matching 1 of
  golden's 3-4 copies to matching 2-3 of them.

## 5. Residues the verification adds (ranked, on top of the pass's R0-R4)

* **R-A — the member packed-array dim over a NAMED typedef member stays
  folded.** `v6_dims35` 18:10, `w6_t [N-1:0] m` inside a type-parameter
  default: golden `op11(ref_obj,constant)`, ours `const UINT:3@64 ct9`, and the
  law does not touch it — the flag reaches the member's own `logic_typespec`
  range, not the packed-array dim built over a named element
  (`namedElemPackedDimTs31`'s object). One gate away from the same family.
* **R-B — the cross-package leaf substitution is context-dependent and we have
  it backwards in two contexts.** In a CLASS type parameter golden substitutes
  the package parameter's VALUE and we emit a `ref_obj` (`v2_holder35` 24:57);
  in a `$unit` typedef reached as a member type golden keeps the `ref_obj` and
  two of our copies substitute a constant (`v3_shape35` 16:15). Both cells only
  became visible because this law stopped folding them.
* **R-C — a GENERATE-BLOCK type parameter's aggregate default emits no range on
  our side at all.** `v2_holder35` 48:50: golden has the cell (×2), we have no
  object, on both binaries. Unreachable to this law.
* **R-D — a FUNCTION-LOCAL type parameter's aggregate default is an object
  golden does not build.** `v2_holder35` 54:50: ours only, on both binaries;
  the law makes that extra object symbolic.
* **R-E — an aggregate default carrying its OWN trailing packed dimension is
  missing from our database.** `v6_dims35` 11:11 and 12:5: golden has both the
  member bound and the `[N-1:0]` dim, we emit neither.

## 6. Instruments

* `run35v.sh` — the two-sided runner, defaulted to THIS directory's `grid/` so
  neither pass's driver can be pointed at the other's scratch.
* `cellcmp35.py` — the CELL TABLE beside `score35.py`'s counters: GOLD | PRIS |
  LAW per (range-loc, side), so a MOVED-WRONG can be read instead of trusted.
* `boundscope35.sh` — THE BLAST-RADIUS GATE: strip object ids, diff the two
  databases' dumps, and count changed lines that name anything OUTSIDE a bound
  expression. 0 on all nine arms and on both corpus movers; it is what turns a
  moved head from an ambiguity into a fact.
* `grid/v1..v6` — the arms, their `dut.sv`, both rcs, `CENSUS.{gold,ours,law}`
  and `SCORE.txt`. The `slpp_all` trees, databases and raw dumps are
  regenerable and are not committed.
* `evidence/GATES.r11v35.txt` — every gate above with its raw output.
* `evidence/HEADMOVE.v3_shape35.txt` — the one moved head, with the census rows
  that show the cell was already unequal at the base.
