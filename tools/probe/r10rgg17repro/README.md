# r10rgg17 — § hpConnElemIdxFold17: a hier_path PORT ACTUAL's element index and its part-select BASE are FOLDED, and the path NAME is re-rendered from the folded elements

**MEASUREMENT-ONLY directory.**  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `f969774`.**  `results/*.csv` was READ ONLY and is untouched.
**Rggen still does NOT pass `uhdm-cmp`, and NO CORPUS ROW WAS CONVERTED** —
this pass says so up front.  The production change is one gate and one element
shape in `src/ExprEmit.cpp` (335 inserted lines, of which 131 are the law's
comment); everything else here is instrument or evidence.

Target: `default:Rggen`'s official head after r10rgg16 — 194 cmp lines
(97 on stderr + 97 on stdout), 1 head, at `f969774`.  It is r10rgg16's R0,
promoted from r10rgg15's R-C and first named by r10rgg14's R-C.

**RESULT.  THE HEAD IS CLEARED, and with it EVERY remaining `hier_path`
disagreement in the Rggen database.**

* `rowheads.sh` (official `uhdm-cmp`, Rggen default): the head object moves to a
  **DIFFERENT FAMILY** (§ 8, R0) — 194 → 64 cmp lines.  A cmp line count is the
  head OBJECT's decompile size, so that number is **not** a progress metric and
  is not reported as one.  The arbiters are the whole-dump diff and the census.
* **The whole-dump path-normalised diff of Rggen, base vs patched, is 984
  removed / 480 added lines over 1,580,758 dump lines a side, in EXACTLY 24
  hunks, EVERY ONE of them at `rggen-sample/block_1.sv:356` — the 24 head
  objects and NOTHING ELSE** (`DUMPDIFF_rggen_base_vs_pat.txt`).
* The 24 sites are now **byte-identical to golden** on every field the dump
  prints: the multiset of all dump lines carrying a `356:` span, ids stripped,
  is **IDENTICAL** between golden and our patched database (15 distinct lines).
* Census of **every `hier_path` in the whole Rggen database** (6,422 reachable
  keys a side, both views): golden-vs-ours **differing 24 → 0**, ours-only 0.
  Restricted to PORT ACTUALS: 77 keys a side, **differing 24 → 0**.
  Golden-vs-golden calibration against a FRESH `surelog -parse` run whose
  database is byte-identical to the cached golden
  (md5 `98176c6e44638c913a47fd319fa3729f` both): **6,525 / 6,525 identical,
  0 differing keys.**
* Corpus: **0 byte movers over 1,358 uhdm2rtlil databases** and **2 over 956
  surelog databases — `default/Rggen`, the target, and `default/Scoreboard`,
  THE DOCUMENTED COIN, proved here rather than asserted.**  Both numbers were
  **PREDICTED BY NAME from the PRISTINE databases BEFORE the patched sweep
  existed** (`PREDICT_db_*.txt`), and the predictor's REACH was measured so the
  `0` is a measurement and not a blind instrument (`REACH_*.txt`).
* **0 differing ROWS** in either corpus, either mode, status AND dump column,
  against the committed baselines AND against my own base sweeps.
* Wide boundary over a COPY of the WHOLE `tools/probe` tree, no path filter:
  **3,128 sources, 2,997 identical, 4 movers — three of them this pass's OWN
  grid cells (the positive control), the fourth `r10buvm22repro/g22.sv`, which
  is DECODED to a pre-existing TYPE-CONFUSION read in `TypeEmit.cpp` and is
  neither closer to nor further from golden** (`BOUNDARY_g22_DECODE.txt`) —
  0 asymmetries.

---

## 1. THE HEAD, decoded from the PRISTINE cmp LOG and the GENERATED Compare

`HEAD_R0_BEFORE_default_Rggen.cmp` is the verbatim pristine log (LHS is ALWAYS
golden).  Read `hier_path::Compare`
(`UHDM/build/generated/src/hier_path.cpp:110`) before naming a field:

```c++
int32_t hier_path::Compare(...) {
  if ((r = basetype_t::Compare(other, context)) != 0) return r;   // expr::Compare
  if ((r = SafeCompare(lhs, lhs->Path_elems(), rhs, rhs->Path_elems(), ...))) return r;
  if ((r = SafeCompare(lhs->Root_value(), rhs->Root_value(), ...))) return r;
  if ((r = lhs->VpiName().compare(rhs->VpiName())) != 0) { ... }
}
```
and `expr::Compare` (`expr.cpp:83`) opens with `basetype_t::Compare` =
`BaseClass::Compare`, which reads **VpiType, then VpiName, then VpiDefName**.

**THE FAILING FIELD IS THE HIER_PATH'S OWN `VpiName`, READ INSIDE
`BaseClass::Compare` — BEFORE A SINGLE `Path_elem` IS LOOKED AT.**  Both sides
carry TWO elements, so this is *not* a `Path_elems` size mismatch; the element
shapes are the next three failures queued behind the name.

```
golden : hier_path (register_if[12].value[0+:1])            356:42-356:78
           [0] bit_select vpiName register_if, vpiFullName register_if[12]
                 vpiIndex = constant INT:12 sz 64 ct 7 dec "12"  @356:54-356:59
           [1] indexed_part_select vpiName value, cs 1, type 1
                 Base  = constant INT:0  sz 64 ct 7 dec "0"      @356:69-356:70
                 Width = constant UINT:1 sz 64 ct 9 dec "1"      @356:76-356:77
ours   : hier_path (register_if[6+7*i+6].value[0 + 1 * l+:1]) 356:42-356:78
           [0] ref_obj vpiName "register_if[6+7*i+6]"            @356:42-356:62
           [1] indexed_part_select vpiName value, cs 1, type 1
                 Base  = operation op 24 (+) over UINT:0 and
                         operation op 25 (*) over UINT:1, UINT:0
                         (the genvar `l` SUBSTITUTED, the arithmetic NOT folded)
                 Width = constant UINT:1 sz 64 ct 9
```

The site is `rggen-sample/block_1.sv:356:42`

```systemverilog
.i_sw_write_enable (register_if[6+7*i+6].value[0+1*l+:1])
```

inside `for (l = 0; l < 2; ++l) begin : g` inside `if (1) begin : g_bit_field_2`
inside a genvar-`i` loop; `register_if` is the interface ARRAY
`rggen_register_if #(7,32,32) register_if[20]()` (`block_1.sv:44`).

## 2. THE LAW

> **§ hpConnElemIdxFold17.**  In the **ELABORATED** view, inside an instance
> **PORT CONNECTION** actual, a `hier_path` component written `name[E]` whose
> index expression **READS A GENVAR** is NOT a flat `ref_obj` named after the
> written text: it is a **`bit_select`** named by the ARRAY, carrying the
> reduction of `E` as its `vpiIndex`, and the trailing indexed part-select's
> **BASE** folds by the same rule.  Both constants take
> § genvarIdxFoldRerender14's encoding — `VpiDecompile` re-rendered by
> `std::to_string`, `VpiSize` 64, `VpiConstType` the reduction's own
> (`vpiIntConst` when a `*` / `/` / `-` / unary minus is on the spine, else
> `vpiUIntConst`), the SPAN the expression node's FIRST CHILD (for a binary
> operation, its LEFT OPERAND) — and they are **UNPARENTED**, as golden's are.
>
> **THE NAME follows from the elements, not from the source.**  Surelog builds
> a path name by CONCATENATION in `compileSelectExpression`
> (`CompileExpression.cpp:5547/5586`), appending `decompileHelper(<element>)`
> per component (`CompileHelper.cpp:2544`): a `bit_select` renders
> `"[" + its constant's VpiDecompile + "]"`, an `indexed_part_select`
> `"[" + base + "+:" + width + "]"`.  Folding the elements therefore turns
> `register_if[6+7*i+6].value[0 + 1 * l+:1]` into
> `register_if[12].value[0+:1]` — the missing spaces are not a spelling rule,
> they are the absence of the `ExprEval::prettyPrint` that renders an operation.
>
> **SURELOG'S MECHANISM.**  `NetlistElaboration::high_conn_` re-compiles the
> ELABORATED actual with `Reduce::Yes`; `compileExpression` reaches the
> `hier_path` builder at `CompileExpression.cpp:5455-5720`, whose per-component
> loop calls `compileSelectExpression(..., reduce, path, instance, ...)` and
> `compilePartSelectRange(..., reduce, ...)` with the instance's parameter map
> bound, so `ExprEval::reduceExpr` folds each index and base in place; the
> running `the_name` is grown by `decompileHelper` of whatever those calls
> returned, and `path->VpiName(the_name)` at :5700 is what the judge reads.
>
> **THE POSITION IS THE AXIS.**  A gen-scope **CONT-ASSIGN** writing the SAME
> select keeps it SYMBOLIC in golden — `arr[6 + 7 * i].value[0+:4]`, a
> `bit_select` over an `operation` with `prettyPrint` spacing — which is
> r10rgg14 § 3's finding, re-measured here on purpose-built golden as grid
> `g3`'s CONTROL, and the patched emitter leaves it byte for byte as it was.

## 3. THE GRIDS — measured on GOLDEN first (`GOLDEN_SHAPES_grid.txt`)

`cells/g1` (index-shape and tail-shape axes), `cells/g2` (base-kind and array
DIRECTION axes), `cells/g3` (scope axis + the cont-assign control).  Score is
order-blind over the whole Compare-visible payload, golden / base / patched.

| cell | axis | FIXED | BROKEN | STILL-WRONG | STILL-RIGHT |
|---|---|---|---|---|---|
| g1 | index shape × tail shape | **12** | **0** | 8 | 13 |
| g2 | base kind × array direction | **6** | **0** | 2 | 6 |
| g3 | genvar scope + the CONTROL | **10** | **0** | 2 | 4 |
| | **total** | **28** | **0** | 12 | 23 |

What golden does, read off `g1` (ELAB rows; the DEF listing keeps the symbolic
form on both sides and is unchanged):

| written index | golden's folded constant | ct | span |
|---|---|---|---|
| `arr[i]` | `UINT:0` / `UINT:1` sz 64 | 9 | the `i` |
| `arr[3+i]` | `UINT:3` / `UINT:4` sz 64 | 9 | the `3` |
| `arr[6+7*i+6]` | `INT:12` / `INT:19` sz 64 | **7** | the **`6+7*i`** |
| `arr[P+i]` | `UINT:2` / `UINT:3` sz 64 | 9 | the `P` |
| `arr[P]` (bare param) | `UINT:2` sz **32** | 9 | — **ABSTAIN** |
| `arr[LP]` (bare localparam) | `UINT:3` sz **32** | 9 | — **ABSTAIN** |
| `arr[7]` (literal) | `UINT:7` sz 64 | 9 | unchanged |

and the trailing part-select BASE, same table: `[0+1*i+:4]` → `INT:0` / `INT:1`
ct 7 sz 64 at the `0`, while a **bare literal** base `[0+:4]` stays `UINT:0`
ct 9 (r10earl64's § connIpsBareBaseUint64 — no reduction ever runs on it, and
this pass's genvar gate leaves it alone).

`g2` proves the DIRECTION rule the r10vrgg14 verifier paid for: `sif dn[20:10]`
with `dn[12+2*i]` gives golden **12, 14** and `dn[10+i]` gives **10, 11** — the
slot is `range.lower() + k`, and both cells are FIXED.

`g3`'s CONTROL is the whole fence in one line: golden's gen-scope cont-assign
`assign w1 = arr[6+7*i].value[0+:4];` keeps `bit_select` over an unfolded
`operation`, and base and patched emit **identical bytes** there.

## 4. THE PRODUCTION CHANGE

`src/ExprEmit.cpp`, the "Range select over a DOTTED interface-member path" arm
of `emitExpr` (~18641).  Three pieces, all inside that one arm:

1. a FOLD PLAN computed before the path name is rendered — per mid component,
   `{decompile, const type, span}`, plus the same for the indexed part-select
   base;
2. the NAME re-rendered from the folded component texts (only when something
   folded, so every pre-existing cell keeps its bytes);
3. the folded component emitted as a `bit_select` + UNPARENTED constant, and
   the part-select `Base_expr` replaced by its folded constant.

**THE GATE, and every clause of it is a measured abstention:**

* `genvarConnFold && elabConnEmit21` — an ELABORATED instance PORT CONNECTION
  actual and nothing else.  `genvarConnFold` is already disarmed for the child
  body and re-armed for the actual only (§ genConnIdxFoldConnOnly21), which is
  what keeps `g3`'s cont-assign control out.
* the index must **read a genvar** (`srlgIdxHasGenvar14`, looked up in
  `connGenScope61` — the generate block enclosing THIS instantiation, so an
  OUTER loop's genvar resolves through `Scope::lookupName`'s upward walk).  A
  bare parameter / localparam index is r10rgg11's declaration-constant copy at
  the parameter's OWN size (r10rgg14's R-B) and is left exactly as it was.
* `srlgRedCt14` must model the whole expression; `%`, `**`, `^`, based
  literals, calls, ternaries and selects all return 0 and ABSTAIN.
* the VALUE is never computed by a second evaluator: the element index is
  **read off the RESOLVED path** — slang already bound `register_if[6+7*i+6]`
  to one `InstanceSymbol`, and its slot in the enclosing `InstanceArraySymbol`
  IS the index (`range.lower() + k`, r10vrgg14's descending-array fix
  included); the part-select base is `tryEval` of the BOUND expression, the
  same call the sibling `genvarConnFold` arm below already makes.
* a MULTI-DIMENSIONAL component (`a[i][j].m`) is unmeasured and abstains.

**MEASURED CORRECTION made during the pass, worth recording because it cost a
build.**  The first revision matched the resolved path element BY NAME.  It
found nothing and the whole law silently abstained: the debug dump of
`cells/g1` shows the resolved path of `arr[E].value` is THREE elements —
`InstanceArray(arr)`, the array ELEMENT `Instance`, and the `Variable` — and
**the element carries an EMPTY name**.  It is matched by its PARENT ARRAY's
name, never by its own.  A silent abstention reads exactly like a law that does
not apply, which is why the grid was run before the corpus.

## 5. THE CENSUS INSTRUMENT (`hpcensus17.cpp`, built by `build17.sh`)

Reads a `.uhdm` DIRECTLY with the same STATIC `~/.local` UHDM the sweeps,
`uhdm-cmp` and `uhdm-dump` use, and emits one row per `hier_path` with the
Compare-visible payload of the object and of every `Path_elem`
(`VpiName / VpiDefName / VpiDecompile / VpiSize / Root_value` + per-element
kind and index/base/width `value,size,constType,decompile`).  **No fullname and
no span is in the payload, because no generated `Compare` reads either**; the
span appears in the KEY only, as cross-side object identity.

Two traps this instrument had to be corrected for, both of which first produced
CONFIDENT WRONG NUMBERS:

* **`Serializer::AllObjects()` also returns the WEAKLY-REFERENCED TAIL.**  On
  Rggen our arena holds 6,578 `hier_path`s of which **156 are unreachable** —
  `uhdm-dump` does not print them and the judge never compares them.  A census
  over `AllObjects` manufactured **156 phantom "ours-only" port actuals** and a
  "233 vs 77" story that was pure noise.  The population is now taken from
  `UhdmListener::listenDesign`, the same reachable walk `uhdm-dump` makes
  (golden 6,525 reachable = its whole arena, ours 6,422 + 156 tail).
* **A KEY TOO COARSE INVENTS FAMILIES.**  Keying on (owner kind, owner name,
  span) collapsed all 45 gen-scope copies of one unnamed `cont_assign` into ONE
  key and reported six phantom "families" that were multiset-size mismatches.
  The key now carries the nearest NAMED ancestor scope.  Conversely, putting
  the OWNER's span in the key split 1,017 keys on a one-column difference that
  no `Compare` reads — the owner span is out again.

**CALIBRATION FIRST, as the campaign requires**: golden vs a FRESH
`surelog -parse` into my own `-o` dir, byte-identical database, **6,525 / 6,525
identical, 0 differing**.  NEGATIVE CONTROL: the same census golden vs PRISTINE
ours reports exactly this pass's 24 objects, and on the grid it reports the 28
cells the patch then fixes — so the instrument is not blind.

## 6. THE GATES

All legs and their verbatim numbers are in `GATES.txt`.  Summary:

| leg | result |
|---|---|
| build both, `-j 2`, md5 after `Built target` | base `c140b820…`, patched `57d0f4f1…` |
| goldens (base / patched) | **23 PASS / 0 FAIL** each |
| goldens with `SLANG_UHDM=/bin/false` | **0 PASS / 23 FAIL** |
| uhdm2rtlil, both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL per mode, base and patched IDENTICAL |
| u2r rows vs my own base sweep | **0 differing / 1462** (status AND dump) |
| u2r rows vs committed `results/gate_uhdm2rtlil.csv` | **0 differing / 731** |
| u2r byteverify, SELFCHECK=1 | **MOVERS 0 / 1358**, selfcheck 1358/1358, **predicted 0** |
| surelog, both modes | 936 CMP_EQUAL / 20 CMP_NOTEQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 NO_UHDM / 1 TIMEOUT — base and patched IDENTICAL |
| surelog rows vs my own base sweep | **0 differing / 1588** |
| surelog rows vs committed `results/golden_surelog.csv` | **0 differing / 1588** |
| surelog byteverify, SELFCHECK=1 | **MOVERS 2 / 956** — `default/Rggen` (PREDICTED BY NAME) and `default/Scoreboard` (THE COIN, proved) |
| canaries / ctcan2 / canaudit | `ok=52/8 changed=0`, `PASS/PASS`, `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| canary byte pins | `InterfaceModPort` `BlackParrotComplex` `YosysOldOr` byte-identical; `SVSwitch` **4842211c4030**; `YosysVerx` **6ccda350c24a** |
| `rowheads.sh`, seven rows, base vs patched | identical everywhere except `Rggen/default` 194 → 64 |

Every `cmds.txt` in all four workdirs was audited BY BINARY PATH: **0 carry a
binary other than the intended one**; the files without the intended path have
no `slang:` line at all (SURELOG_FAIL / NO_DATABASE — slang never ran).

### 6b. The two byteverify movers, both explained

* **`default/Rggen`** — the target, PREDICTED BY NAME before the patched sweep
  existed.  `predict17.py` flags a database iff its PRISTINE ours database has
  a port-parented `hier_path` whose FIRST element is a `ref_obj` carrying a
  bracket — the exact object the law rewrites.  Over 956 surelog databases it
  predicts **1** (Rggen, 24 objects) and over 1,358 uhdm2rtlil databases **0**.
  `reach17.py` shows the instrument REACHES: 25 surelog databases carry 12,445
  port `hier_path`s and 40 uhdm2rtlil databases carry 124, and only Rggen
  carries the shape.  **The predicted set is a strict superset of the measured
  mover set and every predicted database moved.**
* **`default/Scoreboard`** — THE DOCUMENTED COIN, and this pass proves it
  rather than asserting it (`COIN_scoreboard.txt`): six runs of the **BASE**
  binary on the row's own command line give **four distinct** databases
  (`c0d96865`, `fac72e76`, `3e1c7201`×4) and six runs of the PATCHED binary
  give `3e1c7201`×5 and `7e1133fd`.  The mover is nondeterminism.

## 7. THE INSTRUMENTS

```
build17.sh        build hpcensus17 against the STATIC ~/.local UHDM
hpcensus17.cpp    THE CENSUS: every reachable hier_path, Compare-visible payload
census17join.py   the multiset join / family clustering over two censuses
score17.py        the order-blind 3-way grid scorer (golden / base / patched)
cell17.sh         one grid cell: surelog -parse + slang --single-unit + uhdm-cmp
predict17.py      the PRISTINE-database mover predictor (§ 6b)
reach17.py        the predictor's REACH, so a 0 is a measurement
gates17.sh        the four mandatory sweep legs, SLANG_UHDM exported per leg
ct17rows.sh       differing-row counter, status AND dump, via python's csv module
byteverify17.sh   byte-compare two workdirs, with SELFCHECK
boundary17.sh     the wide boundary (subdirectories included, asymmetries loud,
                  the four slang-fenced test names never dispatched)
canaries.sh / ctcan2.sh / canaudit.sh   the canary battery and its audit
cells/g1..g3      the golden grids (§ 3); they double as the boundary's
                  positive control
```

Reproduce:

```sh
git worktree add /tmp/wt_r10rgg17 f969774 && git apply /tmp/r10rgg17.patch   # in it
cmake -S /tmp/wt_r10rgg17 -B /tmp/r10rgg17_build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build /tmp/r10rgg17_build -j 2
bash tools/probe/r10rgg17repro/build17.sh
for c in g1 g2 g3; do bash cell17.sh "$PWD/cells/$c" <base-bin> .base; done
for c in g1 g2 g3; do bash cell17.sh "$PWD/cells/$c" <pat-bin>  .pat;  done
```

## 8. RESIDUES AND THE NEXT HEAD

**R0 — THE NEW HEAD of `default:Rggen` (64 cmp lines: 32 stderr + 32 stdout,
1 head).  It is r10rgg16's R-B, promoted by this pass** — the SIGNED
`START_ADDRESS` family:

```
rggen-sample/block_1.sv:33:59, in
work@rggen.u_block_1.…g_register_0.g[0].g[0].u_register.u_register_common.g_decoder[0]
  golden : constant  UINT:64  vpiSize 7  ct 9  vpiDecompile "64"
  ours   : constant  UINT:0   vpiSize 7  ct 9  vpiDecompile "-64"
```
`expr::Compare` fails on **`VpiDecompile`** (`"64"` vs `"-64"`) before it ever
reaches `VpiSize`.  A 7-bit value written as a `param_assign` Rhs is rendered
SIGNED by us and UNSIGNED by golden; r10rgg16 counted **7 rows** of it and
called it "a pure `toString` signedness fix with a census that scores it
exactly".  It is now the head.

**RE-RANKING of the rest:**

* **R-A — 810 census rows, still the biggest Rggen family by row count.**
  Golden's ELAB view keeps `op11[ref(WIDTH), UINT:1]` in gen-scope INTERFACE
  VARIABLE range bounds where we fold to `const INT:<n>`.  Unchanged, and
  untouched by this pass (a range bound is not a port actual).  Ranked below R0
  because R0 is the actual head.
* **R-B is now R0** (above).
* **R-D — `decompileHelper` SPACING in a KEPT-SYMBOLIC hier_path name**, now
  MEASURED and enlarged by this pass's grid `g3`: golden's gen-scope
  CONT-ASSIGN writes `arr[6 + 7 * i].value[0+:4]` with a `bit_select` over an
  `operation` (ExprEval's `prettyPrint` spacing) where we emit a flat `ref_obj`
  named `arr[6+7*i]`.  **This is the same STRUCTURAL defect this pass fixed —
  in the position where golden does NOT fold.**  `cells/g3` is the arm.
* **R-E — a gen-scope LOCALPARAM index in a cont_assign IS folded by golden.**
  Unchanged.
* **R-F / R-G / R-N1 / R-N2** (r10rgg15's `'1`-into-a->64-bit formal, the
  BASED-unsized override actual, the plain-interface-port `param_assign` law,
  SeqDriver's invented modport).  All unchanged.

**FOUR residues this pass MEASURED and deliberately declined:**

* **R-N3 — 103 `hier_path`s golden emits in the ELABORATED view that we do NOT
  emit at all**, and the largest untaken Rggen family after R-A.  Census
  gold-only keys, base AND patched: the two biggest are
  `rggen_register_common.sv:106:11` `register_if.value` (44 scopes) and
  `:68:49` `register_if.write_data` (42 scopes) — both inside
  `work@…u_register_common` ELAB copies.  We emit the DEF-listing object and a
  minority of the ELAB copies (`cont_assign` at 106:11: golden 135 dump
  occurrences, ours 47).  This is a MISSING-OBJECT family, not an encoding one,
  and the census scores it in one run.
* **R-N4 — the OTHER TWO hier_path builders do not fold.**  Grid `g1`'s
  `arr[2+3*i].value` (plain member tail — the ElementSelect/MemberAccess arm)
  and `arr[2+3*i].value[3]` (bit-select tail) keep the symbolic index where
  golden folds it to `INT:2` / `INT:5`.  **Zero reach in Rggen** (the census
  finds 0 differing port `hier_path`s of that shape), which is why they were
  left; `cells/g1` cells A8/A9 are the arms.
* **R-N5 — the base kind axis: an unpacked VARIABLE array.**  Grid `g2`'s
  `sarr[2+3*i].f[0+:4]` (an array of packed structs) is folded by golden to
  `INT:2` / `INT:5` and kept symbolic by us.  This pass's value source is the
  `InstanceArraySymbol` slot, which a variable array does not have; it needs
  `tryEval` of the written index and a separate measurement of the abstain
  cases.  Zero corpus reach today.
* **R-N6 — a TYPE-CONFUSION read in `TypeEmit.cpp`, found by the boundary.**
  `buildUnpackedArrayTypedefTs` (`src/TypeEmit.cpp:10345`) does
  `ct.as<FixedSizeUnpackedArrayType>()` UNCHECKED and then reads `fua.range`.
  For `typedef C22 ka_cls_t[string];` the canonical type is an
  `AssociativeArrayType`, so the emitted range bound is whatever lies in that
  memory — `22186169` on three unrelated binaries and `22202553` on this
  pass's.  **Golden emits a `string_typespec` and NO range at all, so both
  sides are wrong and neither is closer.**  Deterministic per binary; NOT pure
  link layout (a layout-only control build still prints the old number); ZERO
  corpus reach.  Full decode and controls in `BOUNDARY_g22_DECODE.txt`.

## 9. WHAT THIS PASS DOES **NOT** CLAIM

* Rggen does **not** pass `uhdm-cmp`.  **NO CORPUS ROW WAS CONVERTED** in
  either corpus, in either mode, and `results/*.csv` was never written.
* 194 → 64 cmp lines is **not** a regression and **not** progress: it is the
  next head object's decompile size.  The claims that rest on evidence are the
  24-hunk whole-dump diff, the 24 → 0 census with its golden-vs-golden
  calibration, the 28-FIXED / 0-BROKEN grid, the two 0-differing-row corpus
  gates and the predicted-and-explained mover sets.
* The law is implemented for ONE builder — the dotted-base range-select arm of
  `emitExpr` — and for a base that is an INSTANCE ARRAY element.  The two
  sibling builders (R-N4) and the variable-array base (R-N5) are measured,
  named and untouched.
