# r11u35 — § typeParamAnonAggMemberNoReduce35

**A TYPE PARAMETER'S DECLARATION DEFAULT IS COMPILED WITH `Reduce::No` ALL THE
WAY DOWN: THE MEMBER DIMENSIONS OF ITS ANONYMOUS `struct` / `union` KEEP THE
WRITTEN EXPRESSION, IN EVERY HOLDER AND EVERY VIEW.**

Base `2c3df162`. LHS is ALWAYS golden. Judge: `uhdm-cmp`
(`/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp`, v1.87).

---

## 1. The three witnesses, RE-MEASURED at `2c3df162`

Own pristine binary (md5 `ed6dc5a7d3788f7470cb60667334e6e1`, byte-identical to
the main tree's `build/slang-uhdm` at the base), own sweeps, own workdirs,
`SLANG_UHDM` exported per binary and every `cmds.txt` audited by binary PATH.
Every row carries EXACTLY ONE head (`grep -c '^LHS:'` = 1) in both modes.

**`StructParamFieldRange` (surelog) and `cva6_struct_param_field` (u2r) — the
same face in both corpora.** Head at the `x` member of
`localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] x; ... }`:

```
LHS (golden)                                RHS (ours)
operation: , line:24:12, endln:24:22        constant: , line:24:12, endln:24:20
|vpiParent: \_range: 24:11..24:25           |vpiParent: \_range: 24:11..24:25
|vpiOpType:11                               |vpiDecompile:63
|vpiOperand: \_hier_path: (Cfg.XLEN)        |vpiSize:64
|vpiOperand: \_constant UINT:1 @64 ct9      |INT:63
                                            |vpiConstType:7
```

(`cva6_struct_param_field` is the same objects two lines further down its own
file, 26:12 / 26:11..26:25 — the two designs are the same reproducer.)

**`mem_packed_2d_byte_write` (u2r).** Head at `typedef logic [NDATA-1:0]
[DATA_SIZE-1:0] mem_t [DEPTH];`, 19:18 — golden `operation op11(ref_obj NDATA,
constant UINT:1@64 ct9)`, ours `constant UINT:1@64 ct9` wearing
`vpiDecompile:"NDATA-1"`.

**`iface_param_2level` (u2r), the OPPOSITE direction.** Head at
`logic [SYS_DAT-1:0] reg_data;` inside the elaborated `inner`, 16:10 — golden
`constant INT:31@64 ct7`, ours `operation op11(hier_path s.CFG.BUS.DAT, ...)`.

Status at the base, quoted from the pass's own sweeps: all eight rows
`CMP_NOTEQUAL,decompile:` — `StructParamFieldRange` ×2,
`cva6_struct_param_field` ×2, `mem_packed_2d_byte_write` ×2,
`iface_param_2level` ×2.

**Whole-dump distance at the base** (the number that says whether a row can
CONVERT on one law):

| row | golden dump lines | differing lines |
|---|---|---|
| `mem_packed_2d_byte_write` | 2445 | 157 |
| `StructParamFieldRange` / `cva6_struct_param_field` | 1952 | 653 |
| `iface_param_2level` | 2852 | 951 |

**PREDICTED LOUDLY, BEFORE A LINE WAS WRITTEN: THIS PASS CONVERTS NOTHING.**
Not one of the three witnesses is within reach of this law — each carries
independent residues an order of magnitude larger than the fold cells
(`mem_packed_2d_byte_write`: a missing `vpiNetType:36` and the
`work@dut.mem.mem.i` hier-path naming; the `Cfg.XLEN` pair: the
`struct_typespec` span and name, the `type_parameter`'s own location, the
`Cfg.XLEN'(1)` cast `op67` golden keeps, `tagged_pattern` parents,
`string_typespec` extras). The whole family of six comparable corpus tests was
measured the same way and the tightest is 60 differing dump lines. The pass is
landed for the LAW and for the HEADS it advances, not for a scoreboard move,
and it says so before the measurement rather than after.

## 2. The call-site census — WHICH producer sites compile a def-view range `Reduce::No`

Read out of the pinned Surelog v1.87 sources, every line cited:

| site | file:line | `reduce` | what it governs |
|---|---|---|---|
| a type parameter's typespec, ANSI `paList_of_type_assignments` | `CompileHelper.cpp:3476` | **hard-coded `Reduce::No`**, null instance | § typeParamDefaultBoundNoReduce20 (landed) + **this pass** |
| a type parameter's typespec, `paTYPE` (body / non-ANSI / package / class) | `CompileHelper.cpp:3510` | **hard-coded `Reduce::No`**, null instance | the same |
| a MODULE body `paData_declaration` (every typedef in it) | `CompileModule.cpp:653` | **`Reduce::No`** | R0 below |
| an INTERFACE body `paData_declaration` | `CompileModule.cpp:1130` | **`Reduce::No`** | R0 below |
| a PACKAGE body `paData_declaration` | `CompilePackage.cpp:263` | the pass's own `reduce` — a package is compiled TWICE and the second pass is `Reduce::Yes` (`CompilePackage.cpp:74`, `:90`) | why a package typedef FOLDS |
| the typedef itself | `CompileHelper.cpp:501` `compileTypeDef(..., Reduce reduce, ...)` — `:607` the unpacked `Variable_dimension`, `:649` the packed one, `:1061` the SimpleType element | inherited | R0 below |
| a struct/union member's dims | `CompileType.cpp:315`, `:1295` — `compileRanges(component, fC, Packed_dimension, compileDesign, reduce, ...)` | inherited from `compileTypespec` | **this pass** |
| the reduction itself | `CompileExpression.cpp:3963` `compileRanges`, the `Reduce::Yes` test at `:4032` | — | every site |

The chain this pass rides is therefore: `compileParameterDeclaration`
(`Reduce::No`, hard-coded) → `compileTypespec`'s ONE `paStruct_union` arm →
`compileRanges` with that `Reduce::No` → **no member bound of a type
parameter's aggregate default is ever folded.** Because the `Reduce::No` is
written at the call site and not inherited from the holder's compile pass, the
rule is HOLDER-INDEPENDENT — measured identical in a module, an interface and a
package on `g2_tpdef35` — which is exactly what distinguishes it from the
NAMED-struct-typedef rule already in the emitter (`structMemberSymBound`:
symbolic in a module, FOLDED in a package).

**Corpus cells per site.** The predictor (`pred35.py`, §6) names every test in
either corpus whose sources carry the shape: `cva6_struct_param_field`,
`cva6_equiv` (u2r) and `StructParamFieldRange`,
`StructParamFuncBodyFieldCompare`, `StructParamPatternInitCast`, `Ariane2024`
(surelog). `Ariane2024` is `SLANG_REJECT`/`NO_DATABASE` and `cva6_equiv`
carries no comparable row, so FOUR rows-with-databases hold the family.

## 3. The golden grid

Four arms, `grid/`, each compiled by BOTH producers with BOTH rcs recorded:
`golden_rc=0 ours_rc=0` on all four for the pristine binary and for the law
binary, Surelog `[FATAL] : 0 [ERROR] : 0` on all four.

* **`g1_site35` — THE HOLDER, for a TYPEDEF.** `logic [NU-1:0]`, `[NU:0]`,
  `[7:0]`, two packed dims, a literal and a symbolic unpacked dim, a named
  struct, `signed`, `bit` — as module-body, interface-body, package, `$unit`,
  gen-scope and function-local typedefs, under a module instantiated twice
  (default and `#(.NU(9))`). **This arm is the CONTROL: the law must not touch
  it, and does not (0 movers on both axes).** It is also where the def-vs-elab
  fact was read: golden's DEFINITION listing (`uhdmallModules|work@g1sub35`)
  keeps every module-body typedef bound as `op11(ref_obj,constant)` / a bare
  `ref_obj`, and its ELABORATED listing folds the same declarations per
  instance (`INT:4` under `NU=5`, `INT:8` under `NU=9`) — and OUR def view
  already agrees cell for cell (21 cells, 0 DIFF).
* **`g2_tpdef35` — THE HOLDER and THE MEMBER SHAPE, for a TYPE PARAMETER's
  aggregate default.** A package type parameter, an interface one, an ANSI one,
  the corpus's hier-path member read, a plain param-ref operation, a bare name,
  a literal, a nested anonymous struct, an anonymous union, an anonymous enum's
  base, a packed 2-D member, a NAMED struct named as the default, a keyword
  default with dims, and an OVERRIDDEN type parameter.
* **`g3_shape35` — THE BOUND SHAPE.** Twenty-one written member bounds on one
  declaration: minus-one, bare, literal, sized literal, both ADD orders, an ADD
  with a based-decimal operand, multiply, parenthesised multiply, divide,
  shift, `$clog2`, a localparam read, signed / untyped / byte parameters, a
  struct-param MEMBER read and its bare form, a QUALIFIED package parameter,
  two packed dims, a `signed` member — plus two declarators on one `localparam
  type` keyword.
* **`g4_view35` — THE VIEW and THE USE.** The corpus witnesses' own
  declaration, reached as a plain variable, as a PORT type, as the type of an
  assignment-pattern localparam (the shape whose FLATTEN CLONE Surelog folds),
  as a function-local variable, and re-passed to a child module's own type
  parameter; two instances of the holder.

**ONE CELL IS NOT ON THIS GRID.** An override written as an inline anonymous
aggregate (`#(.ANSI_T(struct packed { logic [3:0] a; }))`) is refused by slang
outright — *"missing '(' in parameter list"*, `dut.sv:75:12` — and an arm whose
compile fails teaches error recovery, not golden, so the override arm names a
typedef instead, which is the corpus's own shape.

### The score (gold × pristine × law, per cell)

`score35.py` reports TWO axes, because they answer different questions.
**SHAPE-SET** is the fold-decision axis — the set of distinct bound
shapes+encodings at a cell — and is the one this law moves. **MULTISET** is the
same with multiplicities: our typespec POOL carries a different NUMBER of
copies of one declaration's typespec than Surelog's does (the residue r11u33's
R0 already named — `cva6_struct_param_field` carries FIVE copies of the bound
where golden carries FOUR), a fact that predates this pass and that no fold
decision can close. Both are printed so the copy-count residue is never
silently folded into the law's own score.

| arm | axis | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG | UNMOVED |
|---|---|---|---|---|---|---|
| `g1_site35` | SET | 0 | **0** | **0** | 43 | 55 |
| `g2_tpdef35` | SET | **12** | **0** | **0** | 2 | 35 |
| `g3_shape35` | SET | **22** | **0** | **0** | 0 | 35 |
| `g4_view35` | SET | 1 | **0** | 2 | 5 | 19 |
| **total** | SET | **35** | **0** | **2** | 50 | 144 |
| `g1_site35` | MULTISET | 0 | **0** | 0 | 54 | 44 |
| `g2_tpdef35` | MULTISET | 2 | **0** | 10 | 22 | 15 |
| `g3_shape35` | MULTISET | 0 | **0** | 22 | 26 | 9 |
| `g4_view35` | MULTISET | 1 | **0** | 2 | 7 | 17 |
| **total** | MULTISET | **3** | **0** | **34** | 109 | 85 |

**AWAY-GOLDEN is 0 on every arm and on both axes: nothing that agreed with
golden stopped agreeing.** `g3_shape35` is the clean statement of the law —
every one of its twenty-one written shapes, re-derived exactly, including the
three the law must NOT invent: a bare decimal literal stays `UINT:7@64 ct9`, a
SIZED literal comes out golden's `DEC:7@8 ct1` because the written literal is
what is kept, and a QUALIFIED package-parameter leaf comes out
`op11(constant,constant)` because § crossPkgRangeBoundFold already substitutes
that leaf and this law does not disturb it.

**THE TWO SET MOVED-WRONG, named and attributed.** Both are `g4_view35` 28:11
and 29:11 — the `it_t` members of the corpus witnesses' own declaration, the
one whose type is also the type of an assignment-pattern localparam. Golden
carries BOTH shapes at that cell (`const INT:63@64 ct7` AND
`op11(hier_path,constant)`): `ExprEval::flattenPatternAssignments` CLONES the
struct typespec for the pattern and REDUCES the clone, while the declaration
object keeps the written operation — the very mechanism the two tests' own
header comments describe. We carry one shape at that cell, folded before and
symbolic after, because our copies are clones of the one object this law
governs and there is no clone-time fold. It is not a regression (nothing that
agreed stopped agreeing) and it is not new: the cell was unequal before and is
unequal after. It is **R0**, below, and it is refused here rather than guessed
at — our five copies do not map onto golden's four, and picking which of ours
to fold without a distinguisher is exactly the guess this campaign does not
make.

## 4. What the head does on the witness

The law does not convert `StructParamFieldRange`, and it was predicted not to.
It **moves the head past the fold**: at the base the single head is the range
bound (`operation` vs `constant`, §1); with the law the single head is the
`struct_typespec` itself —

```
LHS: struct_typespec: , id:566, line:23:26, endln:23:32   (golden: UNNAMED)
RHS: struct_typespec: (it_t), id:331, line:23:26, endln:26:4
     |vpiName:it_t  |vpiInstance: \_module_inst: work@StructParamFieldRange
```

— a NAME and an INSTANCE the anonymous default must not carry, and a span that
ends at the closing brace instead of the keyword. That is the next cell on this
road and it is named in R1.

## 5. What was written

Two production files; no line removed.

* `src/TypeEmit.cpp` — `isTypeParamAnonAggDefault35`, the ONE syntax test
  (walk the aggregate scope's syntax ancestors for a
  `TypeParameterDeclaration`), asked by both aggregate builders so the two can
  never drift; the gate added to `buildStructTs`'s `structMemberSymBound`
  computation; the same gate added to `buildUnionTs`, which never set that flag
  at all and so inherited whatever its caller left — hence an explicit
  save/restore there.
* `include/UhdmExporter.h` — the declaration and the law, with the producer
  chain cited line by line.

**The abstentions, each measured on the grid:**

1. **A named typedef NAMED as the default** (`localparam type nm_t =
   named_s_t`) is not this law's: its scope's syntax is the TYPEDEF's, so the
   test answers false and the named-typedef rule keeps owning it —
   `g2_tpdef35` 52:33, equal before and after.
2. **A keyword default with dims** (`localparam type kw_t = logic [NU-1:0]`) is
   § typeParamDefaultBoundNoReduce20's own arm and is untouched — `g2_tpdef35`
   55:32, equal before and after.
3. **An OVERRIDE does not exempt the default.** `g2_tpdef35`'s `u_ov`
   overrides `ANSI_T` and golden still keeps 27:60 symbolic, because the object
   this rule governs is the DECLARATION's, built once at definition-compile
   time with a null instance. There is therefore no `isOverridden()` gate here,
   unlike § 20's packed-dim arm where the OVERRIDE's own written type is a
   different object compiled during elaboration.
4. **A LITERAL bound is not a reduction** and is not re-encoded: the law only
   decides whether to fold, and a written literal is emitted as written
   (`g2_tpdef35` 39:49, `g3_shape35` 22:11 and 23:11).

## 6. Instruments

* `rangecensus35.py` — the census AND the SHAPE LISTER, **keyed on the VIEW**.
  A new one was needed: `r11u33repro/rangecensus33.py` lists `vpiTypedef` in
  its `BACK` set, so the DEFINITION module's own typedef list — the very site
  `CompileModule.cpp:653`'s `Reduce::No` shows at — is never walked, and its
  `view` column collapses every section onto one. A census that cannot see the
  def view cannot measure a def-vs-elab law. It also prints every section it
  reached and found EMPTY, with its zero.
* `cmpcensus35.py` — pairs two listings with the VIEW in the key
  (SAME / DIFF / OURS-MISSING / GOLD-MISSING).
* `score35.py` — the three-way cell score on both axes (§3).
* `pred35.py` — names the mover set A PRIORI, with `--selftest` as its POSITIVE
  CONTROL (the three arms that must be predicted and the one that must not).
  It reads the SOURCES and says why: once the bound is folded, the pristine
  database carries a plain `constant` under a `typespec_member`,
  byte-indistinguishable from a named typedef's folded member — the
  distinguishing fact survives only in the syntax the law keys on.
* `run35.sh` — the two-sided grid runner (inherited from `r11u33repro/run33.sh`
  unmodified except its default `GRID`); both producers, both rcs recorded.
* `heads35.sh` — the ONE head per row, golden(LHS) vs ours(RHS), read straight
  out of a harness workdir by resolving each `cmds.txt`'s golden-cache entry.
* `dumpdiff35.sh` — the whole-dump distance per row beside the head, the number
  that says whether a row can convert on one law.
* `attr35.sh` — ORDER-BLIND mover attribution: dumps both databases, strips the
  banner, NORMALISES the embedded workdir paths (a dump path embeds the
  workdir), sorts, diffs. Zero lines means same content in a different order —
  the coin, not a law.
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `byteverify.sh`, `ct8rows.sh` —
  the current-generation battery, byte-identical copies of `r11u33repro`'s.
* `grid/` — the four arms and their `CENSUS.gold` / `CENSUS.ours` /
  `CENSUS.law` / `SCORE.txt`. The `slpp_all` trees, the `.uhdm` databases and
  the raw dumps are regenerable and are not committed.
* `evidence/` — the re-measured heads, the a-priori prediction with its
  positive control, the byte verifier's output and the gate log.

## 7. Gates

All in `evidence/GATES.r11u35.txt`, every one against the pass's OWN pristine
binary and OWN pristine workdirs.

| gate | result |
|---|---|
| pristine worktree build | md5 `ed6dc5a7d3788f7470cb60667334e6e1` — byte-identical to the main tree at `2c3df162` |
| law build | md5 `ea7475c5b8d85df95c35d88f457ad930` |
| goldens | 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` → 23 FAIL / 0 PASS (negative control) |
| pristine sweeps | u2r 774/30/67 in EACH mode; surelog 474/9 + 469/8 of 798 — the committed baseline exactly |
| u2r both modes, law | 774/30/67 in EACH mode; `ct8rows` PASS against the COMMITTED `results/gate_uhdm2rtlil.csv` and against the pass's own pristine, in both modes: **every row byte-identical** |
| surelog both modes, law | 474/9 + 469/8; STATUS histogram identical in both modes; three rows differ and all three are resolved below |
| byteverify u2r | **2 / 1608** movers, SELFCHECK 1607/1608 |
| byteverify surelog | **10 / 960** movers, SELFCHECK 959/960 |
| canaries | `canaries.sh` sl ok=51 changed=1 (resolved below) / u2r ok=8 changed=0; `ctcan2.sh` PASS ×2; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected databases | every one byte-UNCHANGED; `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1 8bdf25272e08` / `59d0ee6d10c3` all matched |
| `rowheads.sh` | 0 heads on every UVM-family row and on `Earlgrey_0_1`, both modes |
| `results/*.csv` | untouched |

**THE CONVERSIONS: NONE, exactly as predicted in §1 before the code was
written.** No row's status moves in either corpus in either mode. The pass
lands a producer-cited law that puts 35 grid cells onto golden with 0
AWAY-GOLDEN, and advances the head on both cross-corpus witnesses (§4).

### Every mover, named a priori and attributed

The a-priori prediction (`evidence/PREDICTION.txt`, positive control PASS)
named six tests. `cva6_equiv` carries no comparable row in either baseline and
no database in the harness; `Ariane2024` is `SLANG_REJECT`/default and
`NO_DATABASE`/testflags — neither can move a byte. The remaining four have
databases in both modes, and **all six law movers are exactly those four × the
modes they run in**: `cva6_struct_param_field` ×2 (u2r),
`StructParamFieldRange` ×2, `StructParamFuncBodyFieldCompare` ×2,
`StructParamPatternInitCast` ×2 (surelog). Each is 310 differing dump lines,
order-blind and in order alike, and on `StructParamFieldRange`/default the
diff touches **source lines 24 and 25 only** — the two member declarations of
`localparam type it_t` — removing ten `INT:63` constants and adding ten
`op11(hier_path Cfg.XLEN, UINT:1)` trees. Nothing else in any database changed.

**The other four surelog movers are NOT this law**: `MiniAmiq` (both modes),
`SimpleUVM`/default and `Scoreboard`/default. Order-blind attribution puts
`MiniAmiq` and `SimpleUVM` at 4 lines, the `UINT:<n>` / `vpiDecompile:<n>` pair
that is r11u33's R7 (the uninitialised read on `uvm_misc.svh`'s queue typedef's
`array_typespec` bound), and `Scoreboard`/default at **0 lines order-blind and
92 in order**, the documented `svunit_pkg` `vpiTaskFunc` ORDER coin. **The
POSITIVE CONTROL is decisive: the PRISTINE binary alone, run a second time,
moves `MiniAmiq` (both modes) and `SimpleUVM`/default in exactly the same
4-line class** — `MiniAmiq`/default `9a944fa5a052` on the second pristine run
against `5e0f4b570880` on the first. Every UVM row stays `CMP_EQUAL` with 0
heads.

### The three moved surelog rows, resolved

```
< Earlgrey_0_1,testflags,CMP_EQUAL,,,differ
> Earlgrey_0_1,testflags,CMP_EQUAL,,,
< LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../p_sl/...surelog.log".,,
> LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../l_sl/...surelog.log".,,
< LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../p_sl/...surelog.log".,,
> LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file ".../l_sl/...surelog.log".,,
```

`LowMemLib` and `LowMemPkg` carry the WORKDIR PATH inside the `SURELOG_FAIL`
detail string; the two sweeps used two workdirs. Not a row move.

**`Earlgrey_0_1`/testflags is a HARNESS TIMEOUT, and it is a new trap worth
recording.** `verify_golden.py`'s `--timeout` defaults to 180 s and the dump
column is recorded as `''` on `TimeoutExpired`
(`scripts/verify_golden.py:626-635`). On this machine `uhdm-dump` on that
database takes **309 s** and produces **6 730 762 lines** — so the dump column
of `Earlgrey_0_1`/testflags is a MACHINE-LOAD COIN, not a measurement of the
binary. Resolved by hand on the LAW database: `rc=0`, `sha256(body)` =
`f2ca2ea8…` against `golden.dumphash` `63e80341…` → **`differ`**, i.e. exactly
the committed row `Earlgrey_0_1,testflags,CMP_EQUAL,,,differ`. The database
itself is byte-identical to the pristine one and to the OPS pin
(`59d0ee6d10c3`), and its STATUS never moved.

## 8. Residues

* **R0 — THE NEXT HEAD: the ASSIGNMENT-PATTERN FLATTEN CLONE, the other half of
  this cell.** Golden carries the type parameter's aggregate default TWICE at
  the same source cell when a localparam of that type is initialised by an
  assignment pattern: the DECLARATION object keeps the written operation (this
  law) and `ExprEval::flattenPatternAssignments`'s CLONE is reduced against the
  instance's parameter values. `g4_view35` 28:11 / 29:11 hold both faces in one
  design, and `StructParamFieldRange`'s golden database shows the copy layout
  exactly: four copies of the `x` member's `logic_typespec` — one parented by
  the `typespec_member` (symbolic), three by a `ref_typespec` (`…x` folded,
  `…I.x` folded, `…I.x` symbolic). Ours carries FIVE — two `typespec_member`,
  three `ref_typespec` — so the copy sets do not map onto each other and the
  fold cannot be aimed at the right one without first closing the COUNT. That
  count is the pre-existing typespec-pool residue; it is the gate on this
  residue, not this law.
* **R1 — the anonymous aggregate default's own `VpiName` and `vpiInstance`.**
  The head this pass exposes on `StructParamFieldRange`: golden's
  `struct_typespec` for `localparam type it_t = struct packed {...}` is
  UNNAMED, carries no `vpiInstance`, and spans `23:26..23:32` (the `struct
  packed` keywords); ours is named `it_t`, carries the def-view `module_inst`,
  and spans to the closing brace `23:26..26:4`. Three judged fields
  (`VpiName` is read by `typespec::Compare`) on one object, in both corpora.
* **R2 — the MODULE/INTERFACE-BODY TYPEDEF's ELEMENT typespec under an UNPACKED
  dimension.** `mem_packed_2d_byte_write`'s head. Producer:
  `compileDataDeclaration` is called with a hard `Reduce::No` from
  `CompileModule.cpp:653` (module body) and `:1130` (interface body), and
  `compileTypeDef` (`CompileHelper.cpp:501`) hands that `reduce` to the element
  `compileTypespec` at `:1061`; the `array_typespec` wrapper is rebuilt per
  instance and FOLDS its own unpacked bound, while the ELEMENT object is the
  definition-compiled one and never is. Measured on `g1_site35`: golden keeps
  `op11(ref_obj,constant)` in all three copies of `b_mem_t`'s and `b_umem_t`'s
  element typespec while folding the array's own `[NU]` bound per instance
  (`INT:4` / `INT:8`); our census carries NO such element object for `b_mem_t`
  at all, and carries three FOLDED ones for `mem_packed_2d_byte_write`'s
  `mem_t`. A plain packed typedef is NOT in this residue — golden folds those
  per instance in the elab view and our def view already agrees cell for cell
  (`g1_site35` `uhdmallModules`, 21 cells, 0 DIFF). Left standing: it converts
  nothing (`mem_packed_2d_byte_write` also carries a missing `vpiNetType:36`
  and the `work@dut.mem.mem.i` hier-path naming) and its blast radius —
  every module-body memory typedef in both corpora — wants its own census.
* **R3 — `iface_param_2level`, the OPPOSITE direction, and it is a SEPARATE
  FACE.** r11u33 left it open as R1/R4 and asked whether it is this site law's
  other half. The census answers NO: every cell this pass moves is a
  DEFINITION-compile object (`Reduce::No` hard-coded at
  `CompileHelper.cpp:3476`/`:3510`), while `iface_param_2level`'s head is on the
  ELABORATED `inner.reg_data`'s range, built by `NetlistElaboration` from an
  override actual that crossed an interface-port hop. Our own landed rule there
  (`ovHierParam`, `src/TypeEmit.cpp`) keeps it symbolic and golden folds it;
  closing it means INSTALLING a fold in the elaborated view, which is neither
  this law's direction nor its producer. Not touched.
* **R4 — our typespec POOL copy COUNT.** Visible on every arm as the whole of
  the MULTISET/SET gap (34 MULTISET MOVED-WRONG against 2 SET). `g2_tpdef35`
  reads it plainly: golden carries ONE pool copy of a member typespec where we
  carry three, and `g1_site35` reads the mirror (golden two per instantiated
  module, ours one). It predates this pass, no fold decision reaches it, and it
  is the gate on R0.
