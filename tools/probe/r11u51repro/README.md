# r11u51 — the fold DECISION census (MEASUREMENT ONLY)

**Base** `24f51df9` (`matrix-1.87`). **Patch surface**
`tools/probe/r11u51repro/` only — zero production files, zero `results/*.csv`
edits. Pins per `SUPPORT_MATRIX.md`: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`0445655ee7`), uhdm2rtlil v0.68. Binary used for every
measurement: the main tree's `build/slang-uhdm`, md5 `9be297f87ce752ca318a4d32b204ebe9`
(the pristine base binary — nothing was rebuilt).

**The deliverable is [FOLDMAP.md](FOLDMAP.md)** — the decision map, with a
dispatchable brief per road. This README is the measurement record behind it.

---

## 1. What the pass was asked, and what it answers

TRIAGE2 ranked C2 — `bits_of_type_param`, `ibex_tracer`,
`mem_packed_2d_byte_write`, `StructParamFuncBodyFieldCompare`,
`struct_param_pattern_packing` — as the largest surface on the board (5 tests /
10 rows) and held it back because "the two directions have never been shown to
be one switch"
([tools/probe/r11u44repro/TRIAGE2.md:179](tools/probe/r11u44repro/TRIAGE2.md#L179)).

**They are not one switch.** The grid finds five separate producer sites with
five separate gates, and it also finds that two of TRIAGE2's five one-line
descriptions were wrong about what the head actually is (§6). What the five DO
share is a single principle — the producer reduces WHOLE EXPRESSIONS at named
sites and substitutes the reduced OBJECT, never rewriting a surviving
expression's leaf, while our emitter folds bottom-up per node with no site
model. FOLDMAP.md states it and works it out road by road.

---

## 2. The ten heads, re-measured at the base

`scripts/verify_golden.py` over the five names only, own `--out`/`--workdir`,
`--jobs 2`, `SLANG_UHDM` exported explicitly; heads by
`tools/probe/r10uvm67repro/rowheads.sh`. Every arm's rc recorded.

```
TEST                              MODE      CMPLINES  HEADS  cmp rc
bits_of_type_param                default         56      1     255
bits_of_type_param                testflags       56      1     255
ibex_tracer                       default         36      1     255
ibex_tracer                       testflags       36      1     255
mem_packed_2d_byte_write          default         56      1     255
mem_packed_2d_byte_write          testflags       56      1     255
struct_param_pattern_packing      default         52      1     255
struct_param_pattern_packing      testflags       52      1     255
StructParamFuncBodyFieldCompare   default         36      1     255
StructParamFuncBodyFieldCompare   testflags       36      1     255
-- measured=10  SKIP-NOFILE=0  UNKNOWN-NAME=0
```

Ten rows, ten `CMP_NOTEQUAL`, one head each, both modes identical. The five
heads are committed verbatim under [evidence/heads/](evidence/heads); each one
is quoted below with the VIEW it lives in, which is the fact TRIAGE2 did not
have.

### 2a. `bits_of_type_param` — the DEFINITION listing (both listings differ)

```
LHS (golden)                                  RHS (ours)
sys_func_call: ($bits), line:17:39            constant: , line:17:39
|vpiParent: \_param_assign: , line:17:26      |vpiParent: \_param_assign: , line:17:26
|vpiArgument:                                 |vpiDecompile:97
\_ref_obj: (work@dut.req_t), line:17:45       |vpiSize:64
  |vpiName:req_t                              |UINT:97
|vpiName:$bits                                |vpiTypespec: -> int_typespec 17:16
                                              |vpiConstType:9
```

Golden keeps the call in `uhdmallModules` **and** in `uhdmtopModules`. The
control in the same module — `localparam int DIRECT = $bits(pk::req_t)` —
folds on BOTH sides to `UINT:97` at 64 in the definition listing and at 32 in
the elaborated one, byte for byte.

### 2b. `ibex_tracer` — the ELABORATED package listing

```
LHS (golden)                                        RHS (ours)
ref_obj: (ibex_tracer_pkg::OPCODE_C0), line:305:87  constant: , line:305:87
|vpiParent: \_operation: , line:305:86              |vpiParent: \_operation: , line:305:86
|vpiName:OPCODE_C0                                  |vpiDecompile:2'b00
|vpiFullName:ibex_tracer_pkg::OPCODE_C0             |vpiSize:2
|vpiActual: \_constant: , line:9:37                 |BIN:00 |vpiConstType:3
```

Golden keeps the `ref_obj` in all FOUR copies (unelaborated package,
elaborated package, and the module's two imported copies). We keep it in the
unelaborated package only — so our definition package copy AGREES and the head
fires on the elaborated one. The enclosing concat carries `11'h?` and reduces
on neither side.

### 2c. `mem_packed_2d_byte_write` — the module-body typedef's ELEMENT typespec

```
LHS (golden)                              RHS (ours)
operation: , line:19:18  (vpiOpType:11)   constant: , line:19:18
|vpiParent: \_range: , line:19:17         |vpiParent: \_range: , line:19:17
|vpiOperand: ref_obj (NDATA) 19:18        |vpiDecompile:NDATA-1
|vpiOperand: constant 1 UINT:1 @64        |vpiSize:64 |UINT:1 |vpiConstType:9
```

Golden keeps the operation in all three copies of `mem_t`'s element typespec
(once as `ref_obj (NDATA)`, twice as `ref_obj (mem_t.NDATA)`); we carry three
folded constants whose `vpiDecompile` is still the source text `NDATA-1`.
The array wrapper's own `[DEPTH]` bound is a different object and is symbolic on
both sides in the definition listing.

### 2d. `StructParamFuncBodyFieldCompare` — the ELABORATED package listing

```
LHS (golden)                              RHS (ours)
constant: , line:30:23                    constant: , line:30:23
|vpiParent: \_operation: , 29:32..32:37   |vpiParent: \_sys_func_call: ($unsigned)
|vpiDecompile:64                          |vpiDecompile:64
|vpiSize:32                               |vpiSize:64
|UINT:64 |vpiConstType:9                  |UINT:64 |vpiConstType:9
```

`expr::Compare` reads `VpiDecompile` then `VpiSize`
([../UHDM/build/generated/src/expr.cpp](../UHDM/build/generated/src/expr.cpp)),
so the judged failure here is **`VpiSize`, 32 against 64** — not the wrapper.
Both databases carry the `sys_func_call`; the unelaborated package copies agree
(64 on both sides, both with the tagged pattern's `Pattern` pointing at the
CONSTANT and the call surviving only as that constant's stale `vpiParent`, a
field no generated `Compare` reads). §6 records this as a correction to
TRIAGE2's C2 table.

### 2e. `struct_param_pattern_packing` — the ELABORATED module listing

```
LHS (golden)                           RHS (ours)
constant: , line:18:34                 hier_path: (CFG.n), line:40:19
|vpiParent: \_cont_assign: , 40:10     |vpiParent: \_cont_assign: , 40:10
|vpiDecompile:3 |vpiSize:32            |vpiActual: ref_obj (CFG) 40:19
|UINT:3 |vpiConstType:9                |vpiActual: ref_obj (work@dut.n) 40:23
                                       |vpiName:CFG.n
```

The DEFINITION listings are IDENTICAL — golden keeps the `hier_path` there too.
Golden's elaborated constant is stamped `18:34`, the literal `3` inside
`localparam cfg_t LIT = '{n: 3, base: 64'h1000};` — the producer substitutes
the pattern element's object, it does not mint at the read.

---

## 3. The producer, decoded

Full line-by-line decode in [FOLDMAP.md](FOLDMAP.md); the five sites:

| road | site | the gate |
|---|---|---|
| A | `CompileExpression.cpp:4686` `compileBits` | `getTypespec` (`:4414`, name lookup at `:4541`) must resolve the argument through the component's TYPEDEF map or its PORTS/SIGNALS; then `ExprEval::isFullySpecified` upgrades `Reduce::No -> Yes` at `:4752`. A TYPE PARAMETER is in neither map. Mint at `:4779-4785`, always `VpiSize(64)`. |
| B | `CompilePackage.cpp:61-71` (`compile(Reduce::Yes)` then `compile(Reduce::No)`), `:80` `setElabMode` | the elaborated copy replaces the Rhs only when the WHOLE Rhs reduces to one constant; a leaf inside a surviving operation is never rewritten |
| C | `CompileModule.cpp:653` (module body) / `:1130` (interface body) → `CompileHelper.cpp:2263` `compileDataDeclaration` → `:2278` `compileTypeDef` → `:1060` element `compileTypespec` | a **hard** `Reduce::No`, not the `m_instance != nullptr ? Reduce::Yes : Reduce::No` the parameter cases beside it use — so the element bound never reduces in any copy |
| D | the elaborated PACKAGE copy's `adjustSize` over the assignment pattern | every element constant is re-stamped to its member's width and re-parented to the pattern operation |
| E | `UhdmWriter.cpp:2090` `writeCont_assign`, the `simplified == false` branch at `:2245` | an unconditional `reduceExpr` + `adjustSize` per ELABORATED instance; outside the `lhs->UhdmType()==uhdmref_obj` test, and blind to the Rhs kind. `compileContinuousAssignment` (`CompileHelper.cpp:2418`) compiles the Rhs with a hard `Reduce::No` at `:2499`, which is why the definition listing always keeps the written expression |

**Is it one switch?** No. A and C are "no reduce site, or the site's reduce
refuses"; B, D and E are "a reduce site we do not run". The grid proves it
per-road: change the ARGUMENT KIND and road A flips with holder and view held
fixed (§4 a1); change the HOLDER and it does not (a2). Change the Rhs KIND and
road E flips with holder and LHS held fixed (e1); change the LHS kind and it
does not (e2). Two roads cannot be one switch when their distinguishers are
disjoint.

---

## 4. The golden grid

15 arms, `run51.sh <binary> base` (golden = pinned Surelog `-parse -nobuiltin
-nocache -sv`, ours = the base binary `--single-unit --nobuiltin`), every arm's
rc recorded for BOTH sides. Full scored output: [evidence/GRID.txt](evidence/GRID.txt),
regenerable with `score51.sh`.

```
a1_bits_argkind   golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
a2_bits_holder    golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
a3_bits_iface     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
b1_leafsubst_pkg  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=18
b2_leafsubst_mod  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=32
b3_leafsubst_ca   golden_rc=0 ours_rc=0  cmp_rc=0   heads=0 cmplines=0
c1_typedef_mod    golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
c2_typedef_pkg    golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=350
c3_typedef_iface  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
d1_cast_pkg       golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=5
d2_cast_mod       golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=17
d3_cast_pkgread   golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=15
e1_ca_rhskind     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=26
e2_ca_lhskind     golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=26
e3_ca_structparam golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=31
```

Every arm compiles on both sides (no `rc=3`, no `rc=139`); `b3` is judge-EQUAL
and is therefore a measured NEGATIVE cell, not a broken arm.

**Four of the five corpus heads are reproduced exactly.** Blinded of ids, of
every source location and of every identifier, the arm's head and the corpus
row's head are the same md5 — 28, 18, 28 and 26 lines respectively
([evidence/HEADID.txt](evidence/HEADID.txt), `blindhead51.py`):

```
44b61f4b1117  a1_bits_argkind   == bits_of_type_param
6b045787b03a  b1_leafsubst_pkg  == ibex_tracer
ae8f00dab551  c1_typedef_mod    == mem_packed_2d_byte_write
4168f893816f  e1_ca_rhskind     == struct_param_pattern_packing
```

The cell tables (argument kind × holder × view for A; reducibility × scope for
B; typedef shape × scope for C; wrapper kind × scope × view for D; Rhs kind and
LHS kind for E) are in [FOLDMAP.md](FOLDMAP.md) under each road. The three that
decide the map:

* **A** — golden KEEPS `$bits` of a `parameter type`, of a `localparam type`
  and of an interface's type parameter, in BOTH views; it FOLDS `$bits` of a
  package typedef, of a package scalar typedef and of a built-in keyword, in
  both views, and we match it in all three of those (the positive control).
  A module-local `typedef pk::req_t loc_t` is a fourth, view-dependent cell:
  golden keeps in the definition listing and folds in the elaborated one.
* **C** — the trigger is the UNPACKED dimension. In one module body golden
  keeps the element bound of `mem_t [DEPTH]` and `up1_t [DEPTH]` and we fold
  them; the plain packed `pk1_t`, a struct member's bound, a net declaration
  and a port declaration all agree cell for cell on both sides.
* **E** — the trigger is the `hier_path` Rhs. With the holder fixed, golden and
  ours BOTH fold a `ref_obj` Rhs and an operation Rhs to the same constant at
  the same size; golden alone folds `CFG.n` and `CFG.base`. With the Rhs fixed,
  golden folds under all five LHS kinds — plain net, bit-select, part-select,
  unpacked-array element, signed net — and we fold one.

---

## 5. The residue arithmetic — what stands behind each head

Order-blind whole-dump diff per row (`dumpdiff51.sh`: `uhdm-dump` both
databases, normalise the embedded workdir path, `sort`, `diff`). Per-row line
censuses in [evidence/](evidence) as `residue.<row>.txt`.

| row | golden lines | ours lines | golden-only | ours-only | what is behind the head |
|---|---|---|---|---|---|
| `bits_of_type_param` | 1398 | 1461 | 20 | 83 | the fold (~14 g / ~20 o) + two golden-only `type_parameter` objects (`req_t`, `data_t`) + three ours-only `logic_typespec`/`range`/`operation` triples for `data_t = logic [DATA_WIDTH-1:0]` |
| `mem_packed_2d_byte_write` | 2445 | 2360 | 120 | 35 | the fold (~110 g) + a missing `vpiNetType:36` on our `logic_net (work@dut.mem)` (judged: `net::Compare` reads it) + a doubled hier-path segment (golden `work@dut.mem.mem.i` / `work@dut.wdata.wdata.i`, ours `work@dut.mem.i` / `work@dut.wdata.i`) + one extra golden copy of the `[DEPTH]` bound |
| `struct_param_pattern_packing` | 3204 | 2920 | 303 | 19 | mostly NOT the fold: a golden-only `struct_typespec (p::cfg_t)` at `21:38` — the FUNCTION ARGUMENT `cfg_t C` of `p::in_region` — with 7 copies, its `typespec_member`s, its `param_assign`s and its `vpiRefFile` stamps |
| `StructParamFuncBodyFieldCompare` | 3061 | 3055 | 345 | 339 | TRIAGE2's C3 (the anonymous `localparam type it_t = struct packed {…}`: golden's `struct_typespec` spans `42:26..42:32`, ours `42:26..45:4`) + ten ours-only `hier_path (Cfg.XLEN)` per copy, which is road E's law inside the module's `INT` localparam |
| `ibex_tracer` | 181873 | 168632 | **17389** | **4148** | the leaf substitution is 326 of the 17389; the rest is other families — 948 golden-only `range`s, 744 `logic_typespec`s, 619 `vpiInstance` stamps, 437 ours-only `tagged_pattern`s, 276 ours-only `enum_const` lines |

**No road converts its row on its own.** The two closest are
`mem_packed_2d_byte_write` (35 ours-only lines, three residues, two of them
one-object) and `bits_of_type_param` (83 ours-only lines, roughly a quarter of
them not the fold).

---

## 6. Corrections to TRIAGE2's C2 table

Both are measured, and both change what a pass implementing C2 would build.

1. **`StructParamFuncBodyFieldCompare` is a SIZE, not a wrapper.** TRIAGE2 reads
   "golden DROPS the `unsigned'()` wrapper … we keep `sys_func_call
   ($unsigned)`, size 64". Both databases carry the `sys_func_call` and both
   tagged patterns point at the CONSTANT; the difference the judge stops on is
   `expr::Compare`'s `VpiSize`, 32 against 64, on the ELABORATED package copy.
   `d1_cast_pkg` shows the law has nothing to do with casts: the BARE LITERAL
   `D: 64` moves from 64 to 32 in golden's elaborated package exactly as
   `unsigned'(64)` and `$unsigned(64)` do, and `32'(64)` agrees only because it
   was 32 already. `d2_cast_mod` shows our MODULE-body path already performs
   this adjust — so this is a package-scope gap in our emitter, not a missing
   law.
2. **`ibex_tracer` is a LEAF substitution, not a whole-expression fold.** The
   direction tally is right (golden keeps, we fold) but the mechanism is
   narrower: golden keeps the leaf `ref_obj` inside EVERY surviving expression,
   including one (`b1`'s `R`) that reduces perfectly well, and replaces only
   when the whole Rhs IS the reference. And it is package-scope specific:
   `b2_leafsubst_mod` (module-body localparam) and `b3_leafsubst_ca`
   (cont_assign) both show the two producers agreeing.

---

## 7. Residues this pass found and left standing

* **R0 — the five roads themselves.** [FOLDMAP.md](FOLDMAP.md) ranks them
  C > A > D > E > B by tests-per-fix against boundary risk, with a dispatchable
  brief each and the corpus blast radius measured per road (C: 3 test
  directories; A: 7; E: 20; B: 10). This is what the next passes implement
  from.
* **R1 — a module-local typedef ALIAS is a fourth road-A cell, view-dependent.**
  `a1_bits_argkind` W3: `typedef pk::req_t loc_t; localparam int W3 =
  $bits(loc_t);` — golden KEEPS the `sys_func_call` in the definition listing
  and FOLDS it in the elaborated one; we fold both. `srlgBitsFoldArg` already
  takes an `elabView` argument, so there is somewhere to put it, but no corpus
  witness was found and it wants its own arm.
* **R2 — our PACKAGE-scope unpacked-dimension typedef is missing entirely.**
  `c2_typedef_pkg`: golden carries `pk::mem_t`'s `[DEPTH]` bound
  (`ref_obj (pk::pk::mem_t::DEPTH)`) and both element bounds; our database
  carries none of them, and the arm's head is a whole-package mismatch, not the
  bound. A bigger structural gap than road C's fold and on the same construct.
* **R3 — an X-digit concat folds to different digits at module scope.**
  `b2_leafsubst_mod`: `localparam logic [15:0] X = {3'b000, 11'h?, {pk::C0}}`
  — golden folds to `16'b0000000000100000`, we fold to
  `16'b000zzzzzzzzzzz00`. Same direction (both fold), different value string;
  it is this arm's head and it is not road B.
* **R4 — our def-view encoding changes when a package struct localparam is read
  through a module parameter.** `d3_cast_pkgread`: with the package alone
  (`d1`) our definition copy writes `UINT:64`@64 under the `sys_func_call`,
  matching golden; add `parameter cfg_pkg::user_cfg_t C = cfg_pkg::Base` to a
  module and our definition copy becomes a 32-bit `BIN` where golden still has
  `UINT:64`@64. An our-side instability, found by this grid, unexplained.
* **R5 — `e1`'s elaborated listing shows our cont_assign SHARING the definition
  object** (`uhdm-dump` prints the elaborated `cont_assign` with no children)
  where golden clones per instance. Invisible to the judge today — no
  generated `Compare` reads `VpiParent` — but it is the mechanism road E's fix
  has to break, and it is worth knowing before the fix is written rather than
  after.

---

## 8. Instruments (all measurement-only)

* `run51.sh <binary> <tag> [arms]` — the grid runner, inherited unmodified from
  `tools/probe/r11u35repro/run35.sh`: golden + the chosen binary per arm, rc
  recorded for both, `uhdm-cmp` head count by `grep -c '^LHS:'` on STDERR.
* `score51.sh [binary]` — re-runs the grid and prints every road's cells,
  VIEW-sectioned. The committed tree keeps only `dut.sv`, `rc.base.txt` and
  `cmp.base.err` per arm; this script regenerates the dumps the tables are read
  from.
* `cell51.sh <arm> <tag> <line:col> …` — the site-keyed, view-sectioned cell
  reader. Keys on the SOURCE location because that is what lines the two
  producers' copies up; a site with zero hits on a side prints `MISSING` and is
  counted, so an arm that reaches nothing can never read as agreement.
* `blindhead51.py <cmp log> …` — head-shape identity. Blinds ids, locations,
  file names and identifiers and prints an md5. Two normalisations are
  mandatory and each cost a reading: `uhdm-cmp` writes the head to STDERR and a
  copy to STDOUT, so a merged log carries each side's `decompile:` block twice
  (only the first is kept); and only the first `LHS:`/`RHS:` pair is read.
* `dumpdiff51.sh <rowdir> <outprefix>` — order-blind whole-dump residue for one
  corpus row.

The committed `grid/*/cmp.base.err` logs have the pass's own worktree prefix
rewritten to `<GRID>/` so the evidence does not carry a session path; nothing
else in them is edited. Re-running `score51.sh` writes the real paths back.

## 9. Ops record

Worktree `/tmp/wt_r11u51` at `24f51df9`; scratch `/tmp/r11u51_*`. No build was
run — every measurement used the main tree's pristine binary (md5
`9be297f87ce752ca318a4d32b204ebe9`, unchanged before and after). `GOLDEN_DEFER`
unset. No `git stash`. `results/*.csv` untouched. None of the four
slang-fenced tests was dispatched: the sweeps ran with an explicit `--filter`
naming only the five C2 rows.

---

## 10. Verifier record (r11v51)

This pass was adversarially verified at the same base. The verifier built its
own pristine binary from a fresh `24f51df9` worktree (`cmake --build build -j 2`,
md5 `9be297f87ce752ca318a4d32b204ebe9` — identical to the main tree's),
re-measured all ten corpus heads, re-ran all fifteen arms, recomputed the four
head identities and all five residue totals, and checked every producer
citation against the pinned Surelog `0445655ee7`. **Everything in §2–§5
reproduced bit for bit.**

It then cut **eight new arms** (`grid/va1_bits_signal`, `grid/vb1_pkg_oper`,
`grid/vb2_concat_bound`, `grid/vb3_concat_sel`, `grid/vc1_typedef_shapes`,
`grid/vd1_pattern_width`, `grid/ve1_ca_lhs_fixedrhs`, `grid/ve2_ca_rhs_more`)
on operand kinds, holders and views this pass did not try. Road A's rule
predicted all seven of its new cells; road D's law was confirmed and sharpened;
road E's LHS-kind conclusion survived a properly controlled arm. **Road B's
gate was refuted** — it is the CONCATENATION, not "the whole Rhs IS the
reference" — and roads C and E gained new divergent cells.

The verdict, the corrected laws, the new cell tables and the smaller
corrections are the **VERIFIER CORRECTION BLOCK** at the end of
[FOLDMAP.md](FOLDMAP.md); the scored cells are in
[evidence/VGRID.txt](evidence/VGRID.txt) and the re-counted blast radii in
[evidence/VBLAST.txt](evidence/VBLAST.txt). Read the correction block before
dispatching any road — road B's brief as written would regress six cells that
match golden today.
