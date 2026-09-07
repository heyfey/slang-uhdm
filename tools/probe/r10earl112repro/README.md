# r10earl112 — § `patCaGenIdxValueRender112` — **A GENERATE INDEX INSIDE AN ASSIGNMENT-PATTERN MEMBER VALUE RENDERS AS ITS VALUE, AND THE SAME INDEX ONE STATEMENT AWAY STAYS SPELLED** — the Earlgrey_0_1 testflags `VpiName` head CLEARED, the object's next field named

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance
judge.  The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `7e06ae0c` |
| pristine binary | md5 `783d8623136cecc3099bdfb052a83c08`, built from this pass's OWN worktree at a clean `7e06ae0c` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `39717fd1ff3fc5377292befa29419dc4`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` + `include/UhdmExporter.h` ONLY |
| probe surface | `tools/probe/r10earl112repro/` only |
| the head | **Earlgrey_0_1/testflags, 364 cmp lines, ONE head.**  The failing field was `hier_path::VpiName` — `design::Compare` returned **−57** = `'0' − 'i'`.  It now returns **−1**: the NAME is golden's byte for byte, and the head has moved to the NEXT field of the SAME object, `expr::VpiSize` (0 vs 1).  The line count is unchanged at 364 because the head object is unchanged — this pass CLOSES A FAMILY corpus-wide, it does not clear the object; §7 names the three fields that remain and what each one costs. |
| Earlgrey_0_1/default | **31 lines, 1 head, cmp log BYTE-IDENTICAL** — r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null, untouched |
| goldens | 23 PASS / 0 FAIL on the patched binary; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| grids | 4 arms × 2 views × 2 census families, calibrated golden-vs-golden at **0 DIFF** on all 8 arm/views: **SHAPE AWAY 0 and SHAPE MOVED-WRONG 0 in every cell of both families**, `ONE-SIDED-CHANGED 0`; the law's own family scores SHAPE TO-GOLDEN **54** cells, and THE REST family scores TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0 — i.e. the law moved its own field and nothing else |

---

## 1. THE JUDGE, DECODED FIRST — `own112`, the owner finder AND field bisector

RESUME.md §9's head-decode discipline: read the generated `Compare` ORDER
before naming a field.  For a `hier_path` that order is

```
hier_path::Compare
  -> expr::Compare
       -> BaseClass::Compare   VpiType, VpiName, VpiDefName
       -> VpiDecompile         (string compare)
       -> VpiSize              (int subtraction)
       -> Typespec             (SafeCompare, singular)
  -> Path_elems                (SafeCompare, vector)
  -> Root_value                (SafeCompare, singular)
  -> VpiName                   (string compare)
```

`BaseClass::Compare` reads `VpiName` FIRST, so on a `hier_path` pair whose
names differ the head is decided THERE and `hier_path`'s own trailing
`VpiName` line is never reached.  `own112.cpp` runs the OFFICIAL
`design::Compare` (the same call `uhdm-cmp` makes), prints each field's own
comparison result, then READS the parent chain, both `Path_elems` lists and
the OWNING OPERATION'S SIBLINGS instead of guessing any of them.  Full output
in `OWNER_BEFORE.r10earl112.txt` / `OWNER_AFTER.r10earl112.txt`:

```
== ITERATION 0 : design::Compare -> -57
   HEAD LHS(golden) = hier_path id:793448  tlul_socket_m1.sv 109:19-109:36
        payload: name='tl_h_i[0].a_valid' size=0 ts=ref_typespec->array_typespec
   HEAD RHS(ours)   = hier_path id:1292551          109:19-109:36
        payload: name='tl_h_i[i].a_valid' size=1 ts=<null>
   -- FIELD BISECTION (generated Compare order) --
      BaseClass VpiName   : 'tl_h_i[0].a_valid' vs 'tl_h_i[i].a_valid' -> -57
      expr VpiSize        : 0 vs 1 -> -1
      expr Typespec       : ref_typespec vs <null>
      hier_path Path_elems: 2 vs 2      Root_value: array_var vs array_var
   GOLDEN Path_elems (2):
     [0] bit_select 'tl_h_i'  |vpiIndex -> constant dec='0' size=64 value='UINT:0' ct=9
                              |vpiActual -> array_var('tl_h_i')
     [1] ref_obj 'a_valid'    |vpiActual -> <null>
   OURS   Path_elems (2):
     [0] bit_select 'tl_h_i'  |vpiIndex -> ref_obj 'i'
     [1] ref_obj 'a_valid'    |vpiActual -> typespec_member('a_valid')
   -- OWNER CHAIN (both sides, identical) --
     operation optype=75 ops=10  @108:26-119:6      (vpiAssignmentPatternOp)
       cont_assign                @108:12-119:6
         gen_scope                @89:36-139:6
           gen_scope_array 'gen_host_fifo[0]'
             module_inst 'u_sm1_17'  ->  module_inst 'u_xbar_main'
   GOLDEN siblings (10 operands of optype 75):
      tl_h_i[0].a_valid  tl_h_i[0].a_opcode  tl_h_i[0].a_param  tl_h_i[0].a_size
      shifted_id  tl_h_i[0].a_address  tl_h_i[0].a_mask  tl_h_i[0].a_data
      tl_h_i[0].a_user  tl_h_i[0].d_ready
   OURS   siblings: the same ten, every one spelling `[i]`
```

Five facts the judge hands over, none inferred:

1. **The failing field is `VpiName`, and the arithmetic proves it.**  −57 is
   `'0' − 'i'` = 48 − 105, a `std::string::compare` result at the one differing
   character.  A `VpiSize` failure would have returned 0 − 1 = −1 — which is
   exactly what the judge returns AFTER this pass.
2. **The owner is `vpiAssignmentPatternOp` (optype 75).**  Not the
   `cont_assign`, not the `gen_scope`: the object hangs directly off the
   pattern operation, and that is the whole distinguisher (§2).
3. **All nine sibling paths agree with the head, on both sides.**  Golden
   values the genvar in every one of the ten member values; we spell it in
   every one.  It is one law, not one cell.
4. **The first element is a `bit_select` whose `VpiIndex` is a `constant` in
   golden and a `ref_obj` in ours** — the object behind the name, and the
   thing this pass actually changes (§4).
5. **The object carries FOUR compare-visible differences, in judge order:**
   `VpiName`, `VpiSize` (0 vs 1), `Typespec` (a `ref_typespec` vs `<null>`)
   and `Path_elems[1].Actual_group` (`<null>` vs `typespec_member`).  This
   pass owns the FIRST.  `own112`'s mask ladder, re-run on the PATCHED
   databases, walks the other three in order and each is named in §7.

### the source

```systemverilog
 89:  for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
105:    assign unused_tl_h_source = tl_h_i[i].a_source[IDW-1 -: STIDW];
108:    assign hreq_fifo_i = '{
109:      a_valid:    tl_h_i[i].a_valid,       <- THE HEAD
110:      a_opcode:   tl_h_i[i].a_opcode,
                       ... eight more ...
118:      d_ready:    tl_h_i[i].d_ready
119:    };
```

Golden reads `tl_h_i[0].a_valid` at :109 and `tl_h_i[i].a_source[8 - 1-:2]`
at :105 — the genvar VALUED four lines below where earl110's
§ `hpSelHalfOpParamFold110` deliberately SPELLS it.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

`CompileHelper::compileAssignmentPattern`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:3671`) opens
with:

```cpp
  if (component && valuedcomponenti_cast<Package *>(component)) {
    reduce = Reduce::Yes;
  } else if (instance) {
    reduce = Reduce::Yes;                                        // :3688
  }
```

and then compiles **every** member value with that `reduce`
(`compileExpression(component, fC, Expression, compileDesign, reduce,
operation, instance, false)`, :3735 and :3745).  So inside a pattern — and
only there — an elaborated instance's generate index is resolved to a
`constant` BEFORE `CompileHelper::compileSelectExpression`
(`CompileExpression.cpp:1376-1546`) composes the path's `VpiName`.  And that
name is a FUNCTION OF THE OBJECTS: `compileSelectExpression` appends, per
path element, the text `CompileHelper::decompileHelper`
(`CompileHelper.cpp:2544`) renders **from the element object** —
`constant -> VpiDecompile`, `ref_obj -> VpiName`.  A reduced index therefore
prints its VALUE and an unreduced one prints its IDENTIFIER, in the same
generate body, four lines apart.

That is the same closed dispatch § `hpNameBareIdxFold69` already models on our
side, and it is why this pass needs no name renderer of its own (§4).

---

## 3. THE GOLDEN GRID — the CARRIER axis, measured one cell at a time

Four arms, `-parse` and `-parse -elabuhdm`, one golden per arm, the SAME
dotted path in every cell so the only variable is the carrier.
`grid112.sh` builds them; `cen112` reads them; `GRID.r10earl112.txt` and each
arm dir's `cen.gold.txt` hold the raw rows.

**Arms g1/g2, generate depth 1, ELAB view — WHICH CARRIER VALUES THE GENVAR:**

| cell | carrier | golden's index | golden's name |
|---|---|---|---|
| g1 c1 | assignment-pattern member value, KEYED | `constant` | `tl_h_i[0].a_valid` |
| g1 c2 | assignment-pattern element, POSITIONAL | `constant` | `tl_h_i[0].a_valid` |
| g2 c4 | pattern NESTED inside a pattern | `constant` | VALUED |
| g2 c6 | pattern with a `default:` key (golden keeps the `tagged_pattern`) | `constant` | VALUED |
| g2 c2 | pattern in an `always_comb` | `constant` | VALUED — **residue R4** |
| g2 c3 | pattern in an `initial` | `ref_obj` | `tl_h_i[i].a_valid` |
| g1 c3 | plain `cont_assign` Rhs | `ref_obj` | SPELLED |
| g1 c4 | operand of a binary operation | `ref_obj` | SPELLED |
| g1 c5 | ternary arm | `ref_obj` | SPELLED |
| g1 c6 | concatenation operand | `ref_obj` | SPELLED |
| g1 c7 | port `High_conn` actual | `constant` | VALUED — **and ALREADY ours** (§ `genvarConnFold`) |

**Arm g3 — the DEPTH axis and the INDEX-FORM axis:**

| cell | shape | golden |
|---|---|---|
| d0 | pattern at generate depth 0 (module body), index `MP` | **SPELLED** |
| e1 | depth 1, bare genvar `i` | VALUED, `UINT:<n>` **size 64** ct 9 |
| e2 | depth 1, arithmetic `i+1` | VALUED — **residue R2** |
| e3 | depth 1, gen-scope `localparam int LB` | VALUED, `UINT:1` **size 32** — **residue R3** |
| e4 | depth 1, MODULE `parameter int MP` | VALUED, `UINT:1` size 32 — ALREADY ours |
| e5 | depth 1, literal `2` | a constant on both sides |
| d2 | **depth 2**, `for` in `for` AND `if` in `for` | **VALUED** |

So the axis is the **CARRIER**, not the depth — earl110's law folds only at
depth exactly one, this one folds at depth 1 AND 2 and not at depth 0.  The
DEF view keeps the identifier in every arm, on both sides, already
byte-identical.

**Arm g4 — THE MUST-STAY FLOOR, ELAB view:**

| cell | shape | golden | ours, patched |
|---|---|---|---|
| h1 | earl110's own corpus shape in a PLAIN cont_assign, `tl_h_i[i].a_source[IDW-1 -: STIDW]` | `tl_h_i[i].a_source[8 - 1-:2]` | **byte-identical to pristine** |
| h2 | the SAME select half INSIDE a pattern | `tl_h_i[0].a_source[7-:2]` | **byte-identical to pristine** — fence (c), §4 |
| h3 | genvar in a part-select bound, plain cont_assign | `tl_h_i[i].a_source[i + 1:i]` | unchanged |
| h4 | genvar bit-select on the MEMBER, plain cont_assign | `tl_h_i[i].a_source[i]` | unchanged |
| h5 | a pattern with NO genvar | unchanged | unchanged |
| h6 | the pattern head's twin on a different root array | VALUED | **VALUED** |

---

## 4. THE LAW

> **§ `patCaGenIdxValueRender112`.**  A COMPONENT SELECT of a dotted
> `hier_path` that sits inside an ASSIGNMENT-PATTERN OPERAND VALUE, in an
> ELABORATED generate-scope CONTINUOUS ASSIGN, takes its index at the
> GENVAR'S VALUE: one `constant`, `UINT:<n>`, `VpiSize` 64,
> `vpiConstType` 9 (`vpiUIntConst`), `VpiDecompile` the decimal, spanning the
> genvar TOKEN.  **The NAME follows from the OBJECT and is not rendered
> separately** — § `hpNameBareIdxFold69` already composes a `hier_path`'s
> `VpiName` from its elements with `decompileHelper`'s own closed dispatch,
> which is exactly Surelog's order.
>
> **THE LEAF TEST IS `ParameterSymbol::isFromGenvar()`.**  A gen-scope
> localparam takes the same VALUE but at ITS OWN declaration width
> (`UINT:1` at `VpiSize` **32**, arm g3 e3), which is a different encoding and
> therefore a different law — § `genvarIdxFoldRerender14` states the same
> split in the same words ("a PARAMETER-only index is NOT this law's — golden
> gives it the parameter's own declaration constant, `VpiSize` included").
> Un-narrowed, that ONE cell was the ONE arm key that scored
> SHAPE-MOVED-WRONG; the narrowing is measured, not defensive.

### STATED GATE == CODE GATE

**STATED:** a `hier_path` component-select index, inside an assignment-pattern
operand value, inside an elaborated gen-scope continuous assign, whose index
is a bare genvar reference with a known integer value, and which no earlier
law has already folded.

**CODE:** `inGenScopeCa67 && patValDepth112 > 0`, the emitted index still a
`uhdmref_obj`, `stripImplicitConv(sel).kind == NamedValue`,
`symbol.kind == SymbolKind::Parameter && isFromGenvar()`, and
`getValue().isInteger() && !hasUnknown()`.  There is no condition in the code
that is absent from the prose and none in the prose that is absent from the
code.

### the fences, each of them a measured cell

> **VERIFIER AMENDMENT (r10vearl112).** The gate as first written carried five
> fences; the adversarial verification measured a SIXTH that was missing and
> that cost five pristine-right -> patched-wrong cells on legal SV, and added
> it. Read row (f) below and
> `tools/probe/r10vearl112repro/README.md` section 2 for the decode and the
> golden grid.  The five rows below are unchanged and still hold.


| fence | what it keeps out | the cell that measures it |
|---|---|---|
| (a) `inGenScopeCa67` | the DEF listing, every procedural block, every module-scope statement, every port `High_conn` | g2 c3 (`initial`, golden SPELLS), g3 d0 (depth 0, golden SPELLS), g1 c7 (`High_conn`, already ours through § `genvarConnFold` — folding twice would be a second law on one cell) |
| (b) `patValDepth112 > 0` | every non-pattern carrier in the SAME gen-scape cont_assign | g1 c3/c4/c5/c6 — plain Rhs, binary operand, ternary arm, concat operand, all four SPELLED by golden and all four byte-identical here |
| (c) **the builder itself** | every path with a RANGE select in it | `emitMixedHierPath` accepts only MemberAccess and ElementSelect components and returns `nullptr` on anything else (`ExprEmit.cpp:7904-7920`), so every bracket group in the names it composes is a bit-select index THIS law renders: the name it produces is golden's WHOLE name or the pristine bytes. earl110's `tl_h_i[i].a_source[IDW-1 -: STIDW]` is built by the OTHER arm and is unreachable from here — arm g4 h1 AND h2 are both byte-identical across the patch, which is the fence's own test |
| (d) `isFromGenvar()` | a gen-scope localparam (width 32, not 64) and a module parameter (already folded elsewhere) | g3 e3 and g3 e4 |
| (f) `callArgDepth - sysCallArgDepth22 == 0`, § `patCaGenIdxNeverInUserCallArg112v` (added by r10vearl112) | a pattern member value that is a USER subroutine call's ARGUMENT — Surelog's `compileTfCallArguments` (`CompileHelper.cpp:4340`) compiles it with `pexpr = call`, so the pattern's `Reduce::Yes` never reaches it and golden KEEPS the identifier | verifier arms v1 k1/k5 and v6 j1/j2/j5, both views, all unrollings: golden SPELLS; v1 k2, v6 j3 and v6 j4 measure the other side — a SYSTEM call's argument and a cast DO fold, which is why the test is the USER-call depth and never a plain `callArgDepth == 0` |
| (e) the still-a-`ref_obj` test | every index an earlier law already folded | g3 e4 — `MP` arrives as a `constant UINT:1` size 32 and is untouched BY CONSTRUCTION, exactly the way § `connBitSelIdxModParamFold81` is placed |

### the hypotheses this pass REFUTED, each on an arm cell or on the judge

| candidate | refuted by |
|---|---|
| "the head is a `Path_elems` size mismatch" | §1 — `own112` prints both lists: 2 vs 2 |
| "the axis is the generate DEPTH, like earl110's" | g3 d2 — depth 2 folds; g3 d0 — depth 0 does not |
| "the axis is DEF versus ELAB" | every arm's DEF row is byte-identical on both sides, and the ELAB rows split by CARRIER inside one database |
| "any procedural context folds" | g2 c2 `always_comb` folds, g2 c3 `initial` does not |
| "a genvar and a gen-scope localparam take the same fold" | g3 e3 — golden's `LB` constant is `VpiSize` **32**, the genvar's is 64 |
| "a bare genvar READ anywhere under a pattern folds" | out of scope by construction AND by arm: `patValDepth112` is read at exactly ONE site — a `hier_path` component-select index — so a genvar read in any other position is unreachable; arm g2 c7 (`{4'h0, 4'(i)}`, a bare genvar read with no select at all) is byte-identical across the patch |
| "fixing the name clears the head" | §1 fact 5 and §7 — the same object carries three more differing fields, and the judge reaches `VpiSize` next |

---

## 5. THE CORPUS CENSUS — 2314 databases, both corpora × both modes

`cen112` over every database of both sweeps (`censweep112.sh`,
`ACCOUNTING PASS` on each: surelog LISTED 1573 / PROCESSED 956 / SKIPPED 617 /
CENFAIL 0, uhdm2rtlil LISTED 1462 / PROCESSED 1358 / SKIPPED 104 / CENFAIL 0),
split by `sweepsplit112.sh` — which **asserts the two sweeps' GOLDEN halves are
byte-identical** before anything is scored — and joined as a MULTISET by
`cen112.py`.  Full output in `CENSUS.r10earl112.txt`.

| corpus | family | keys joined | SHAPE TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG | ONE-SIDED-CHANGED |
|---|---|---|---|---|---|---|---|
| surelog | **HPN** (the law) | 29190 | **18** | **0** | **0** | 7 | 0 |
| surelog | **HPR** (the rest) | 29190 | 0 | **0** | **0** | 1199 | 0 |
| uhdm2rtlil | **HPN** | 686 | 0 | **0** | **0** | 0 | 0 |
| uhdm2rtlil | **HPR** | 686 | 0 | **0** | **0** | 0 | 0 |

* **AWAY 0 and MOVED-WRONG 0 in all four cells**, and `ONE-SIDED-CHANGED 0` —
  no key appeared, vanished or changed on one side only.
* The **HPR** row is the proof that the law moved its own field and nothing
  else: TO-GOLDEN 0 / AWAY 0 / MOVED-WRONG 0 means every other
  compare-visible field of every `hier_path` in both corpora is exactly what
  the pristine binary produced.
* `STRICT` (the exact multiset) reports TO-GOLDEN 9 / MOVED-WRONG 9 on the
  surelog HPN row: the nine DEFAULT-mode cells match golden's multiplicity
  exactly (30 objects at the span on both sides) while the nine TESTFLAGS
  cells carry our 3× arena-copy count (88 where golden has 30) with the SAME
  payload SET.  No generated `Compare` counts arena copies, which is why both
  scores are printed and the SHAPE line is the judged one — earl111's
  precedent and the same reason.
* The 7 SHAPE-STILL-WRONG cells are ONE pre-existing UVM cell (`133:12-133:28`)
  in five rows, untouched on both binaries.

### THE PREDICTION, made from the PRISTINE databases FIRST

`predict112.py` reads only the PRISTINE sweep census (our pristine databases
and the goldens; it never sees a patched database) and names every cell the
law can reach.  `PREDICT_sl.txt`:

```
--- PREDICTED MOVE cells: 18 ---
--- RISK cells (must not move): 32718  (of which already AGREEING 29165) ---
ROWS PREDICTED TO MOVE (2):
  default/Earlgrey_0_1-71da2fd7
  testflags/Earlgrey_0_1-71da2fd7
```

`PREDICT_u2r.txt`: **0 cells, 0 rows** over 1358 databases.

**The predicted 18-cell set and the measured SHAPE-TO-GOLDEN 18-cell set are
IDENTICAL, key for key** (`diff` of the two sorted lists is empty).  They are
the nine `tl_h_i[i].<member>` path values of the `tlul_socket_m1.sv:108-118`
pattern, in each of the two modes — nine and not ten because `a_source` takes
`shifted_id`, which is a plain `ref_obj` and not a path.

---

## 6. THE GATES — ALL GREEN

Both binaries were built from THIS pass's own worktree at a clean `7e06ae0c`
and frozen `chmod 555` BEFORE any sweep; every `cmds.txt` in all four workdirs
was audited BY BINARY PATH (`/tmp/r10earl112_bin/pristine` in the two control
workdirs, `/tmp/r10earl112_bin/patched` in the two patched ones, one distinct
path per workdir and no other).

| gate | result |
|---|---|
| (1) build both, md5s | pristine `783d8623136cecc3099bdfb052a83c08` (byte-identical to the main tree's `build/slang-uhdm`), patched `39717fd1ff3fc5377292befa29419dc4` |
| (2) goldens | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (the negative control) |
| (3) uhdm2rtlil, testflags AND default | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2** on both binaries, identical histograms; `ct8rows` **PASS** (0 differing rows, status AND dump column) against the committed baseline AND against this pass's own pristine control, in BOTH modes |
| (4) surelog, `--mode both`, 1588 rows | identical status histograms on both binaries (CMP_EQUAL 937, CMP_NOTEQUAL 19, SLANG_REJECT 567, SURELOG_FAIL 48, DEFERRED 10, NO_DATABASE 3, NO_UHDM 1, UNTRANSLATABLE 2, TIMEOUT 1); `ct8rows` **PASS** against the committed baseline AND against the pristine control.  **NO ROW CONVERTED**, in either direction |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 3 / 956** — the two PREDICTED Earlgrey rows plus `Scoreboard/default`, which is RESUME.md §9's documented coin and is attributed as such in §6a.  SELFCHECK flagged 1357/1358 and 955/956, so the comparator can see |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, uhdm2rtlil **ok=8 changed=0**; `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs, by name | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c` — all SAME as pristine in both modes; `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**, both pins met |
| the four slang-fenced tests | never dispatched; `awk` over the patch finds 0 files naming any of them outside `canaudit.sh`'s own `FENCED=` line |

### 6a. THE THREE BYTE MOVERS, ATTRIBUTED

`attrib112.sh` path-normalises both dumps, diffs them RAW and ORDER-BLIND, and
sections the order-blind diff at `|uhdmtopModules:` into DEF / ELAB / the
weaklyReferenced TAIL (never counted).

* **`Scoreboard/default` — RAW 94 lines, ORDER-BLIND 0 lines.**  A pure
  ordering flip: RESUME.md §9's `svunit_pkg vpiTaskFunc` list-order coin
  ("~92 dump lines"), which flips per invocation on an unchanged binary.  Not
  this law — the law cannot reach `Scoreboard` at all: `predict112.py` names
  0 cells there, and the census scores every one of its keys SAME_AGREE or
  STILL-WRONG-unchanged.
* **`Earlgrey_0_1/default` and `Earlgrey_0_1/testflags`** — the two rows the
  prediction named, with the 18 cells the census scored TO-GOLDEN.  Attributed
  TWO independent ways, both in `ATTRIB_Earlgrey.txt`:
  1. the SECTIONED ORDER-BLIND whole-dump diff.  In BOTH modes every changed
     line, in BOTH directions, is one of the law's own shapes — added: the
     folded `constant` with its `UINT:`/`vpiDecompile`/`vpiSize`/`vpiConstType`
     lines, `bit_select (tl_h_i[N])`, and the nine
     `hier_path (tl_h_i[N].<member>)` with their names; removed: the
     `ref_obj (…gen_host_fifo[N].i)` with `vpiName:i`, `bit_select (tl_h_i[i])`
     and the nine `[i]` names.  **There is no other shape**, and the whole diff
     sits in ONE ELAB section — the DEF section and the weaklyReferenced TAIL
     are untouched.
  2. `kinds112`, the WHOLE-DATABASE census over `Serializer::AllObjects` (every
     object, reachable or not, by kind and by kind+name).  In DEFAULT the ONLY
     kind whose count changed in 1.4 M objects is `constant`, **+261** = 9
     pattern members × 29 unrolled `gen_host_fifo` instances; `ref_obj` named
     `i` is UNCHANGED, because the index `ref_obj` is still minted into the
     arena and then DROPPED by the law's post-emission gate.  In TESTFLAGS:
     `constant` **+261** and `ref_obj` **−522**, the two extra copies of the
     now-unreferenced index under this mode's 3× arena multiplicity (R6).
     **No other kind, and no other name, moved in either mode.**

### 6b. THE WIDE BOUNDARY

`widerun112.sh` stages a COPY of the whole committed `tools/probe` tree, lists
every `.sv`/`.v` at ANY depth (the file list is read on fd 3, children get
`</dev/null`), filters the four fenced names out of the list BEFORE a child
runs, and compares the workdir-normalised `uhdm-dump` of both frozen binaries
in BOTH views.

```
LISTED=4984  FENCED_REMOVED=0  (of 4984 found)
PROCESSED=4984 identical=9588 DIFFERING=0 no_output=380
rc by side:  A/0 9199  A/3 364  A/4 389  A/139 16
             B/0 9199  B/3 364  B/4 389  B/139 16      <- perfectly SYMMETRIC
```

`PROCESSED == LISTED`.  **DIFFERING = 0 over 4984 committed arm files × 2
views**, and the rc histogram is identical side for side — no arm rejects on
one binary and not the other, and the 16 `rc=139` segfaults are the same 16 on
both sides (`BOUNDARY_WIDE.signal`).

**THE POSITIVE CONTROL** (RESUME.md §9: "a positive control — a deliberately
moved cell — proves the gate can see").  The SAME instrument, same two frozen
binaries, run over THIS pass's own four arms:

```
LISTED=4  PROCESSED=4 identical=0 DIFFERING=8 no_output=0
rc by side: A/0 8  B/0 8
differing: elab+plain of g1_head112 g2_carrier112 g3_depth112 g4_fence112
```

All eight move.  The boundary can see, and it sees nothing in 4984 landed arms.

---

## 7. RESIDUES, and R0

The full ladder with its arithmetic name proof is in `PREDICT_R0.txt`; the
short form:

* **R0 — `expr::VpiSize` ON THE SAME OBJECT, and it is a DIFFERENT FAMILY.**
  `design::Compare` returned **−57** (`'0' − 'i'`) before this pass and returns
  **−1** after it: `0 − 1`, the `VpiSize` subtraction.  Golden gives a
  gen-scope cont-assign pattern's FIRST operand **no size at all**; we give it
  the member width.  Measured on nine arm cells across four designs, with the
  MODULE-scope twin as the negative control (golden DOES size there, and the
  landed "re-emitted outermost patterns size their first operand" law is right
  about it).  Surelog's gen-scope path runs
  `ExprEval::flattenPatternAssignments` — which resizes only a `constant` whose
  `VpiSize` is −1 — while the module-scope path additionally runs
  `expandPatternAssignment` → `adjustOpSize` behind `substituteAssignedValue`;
  which pipeline a gen-scope cont_assign takes is the thing to decode.  ONE
  line of ours is implicated (`ExprEmit.cpp`, the `memberSetters` `reemitting`
  branch's `operands->empty()` sizing).  **This is the next pass.**
* **R1 — `expr::Typespec` on the same object.**  Golden hangs a
  `ref_typespec` → `array_typespec` (the ROOT array's own) on the
  pattern-carried path; we hang nothing.  **Not reproduced by any arm here** —
  every arm's root array came out an `array_net` and golden leaves those bare,
  including `g4 h6`, which was written specifically to try for an `array_var`
  root and still came out a net.  The corpus cell has an `array_var` root
  because `tl_h_i` is an unpacked-struct-array PORT of an INSTANTIATED child.
  A pass taking R1 must build that shape first or it is guessing.
* **R2 — `Path_elems[1].Actual_group`.**  Golden's trailing `ref_obj a_valid`
  is UNBOUND; ours binds it to the `typespec_member`.  Golden's FIRST element
  IS bound (`Actual_group -> array_var`), so it is a per-position rule and
  needs its own grid.  `own112`'s mask ladder reaches it in one hop
  (`OWNER_AFTER.r10earl112.txt`, iteration 1).
* **R3 — a gen-scope LOCALPARAM index in the same carrier.**  Golden folds
  `tl_h_i[LB]` to `UINT:1` at `VpiSize` **32** — the parameter's own
  declaration width, not the genvar's 64.  Fenced out here on
  `isFromGenvar()`; § `genvarIdxFoldRerender14` states the same split.
  **Corpus population: ZERO.**
* **R4 — the `always_comb` carrier.**  Golden VALUES the genvar in a pattern
  inside a gen-scope `always_comb` (arm g2 c2) and SPELLS it in a gen-scope
  `initial` (g2 c3).  The `inGenScopeCa67` fence leaves both on their pristine
  bytes.  **Corpus population: ZERO** — all 18 census cells are cont_assign.
* **R5 — the ARITHMETIC index.**  Golden folds `tl_h_i[i+1]` (arm g3 e2); this
  pass takes only a bare identifier, because § `hpNameBareIdxFold69`'s name
  rewrite substitutes only into a single-identifier bracket group.  **Corpus
  population: ZERO.**
* **R6 — the arena COUNT residue.**  In TESTFLAGS our elaborated tree holds 88
  copies of the head path at one span where golden holds 30 (identical payload
  SETS); in DEFAULT the multisets match exactly.  Invisible to the judge — no
  generated `Compare` counts arena copies — and pre-existing on both binaries.
  Reported so the STRICT and SHAPE scores can be read against each other
  rather than one being quietly chosen.
* **R7 — earl110's pattern-carried twin.**  Arm `g4 h2`: inside a pattern,
  golden folds the WHOLE select half too (`tl_h_i[0].a_source[7-:2]` where the
  plain cont_assign three lines up keeps `tl_h_i[i].a_source[8 - 1-:2]`).  That
  path is built by the OTHER hier_path arm (a RangeSelect makes
  `emitMixedHierPath` return `nullptr`), so this law cannot reach it and the
  cell is byte-identical across the patch — which is what keeps MOVED-WRONG at
  0 rather than turning `[i]` into `[0]` beside an unfolded half.  **Corpus
  population: ZERO** in the pattern carrier.

---

## 8. FILES

| file | what it is |
|---|---|
| `own112.cpp` | the owner finder AND field bisector: runs the OFFICIAL `design::Compare`, prints every field in the generated order with its own result, both `Path_elems` lists, the parent chain and the owning operation's siblings, then masks and re-runs |
| `cen112.cpp` | the census: every `hier_path` carrying a component select, in TWO families — `HPN` (the law's surface: `VpiName` + every select's INDEX object) and `HPR` (the rest, compare-visible) |
| `cen112.py` | the MULTISET join and scorer (earl111's, unchanged): STRICT and SHAPE, `TOGOLD` / `AWAY` / `MOVEDWRONG` / `STILLWRONG` / `ONE-SIDED-CHANGED` |
| `score112.py` | the per-arm three-way scorer used while the grid was being built |
| `grid112.sh`, `TOPS.txt` | the grid driver and its `-top` table |
| `calib112.sh`, `CALIB.r10earl112.txt` | golden-vs-golden calibration, 0 DIFF on all 8 arm/views |
| `g1_head112.sv` | the head shape and the CARRIER matrix at depth 1 |
| `g2_carrier112.sv` | the remaining carriers: `always_comb`, `initial`, nested, port actual, `default:` key, the genvar as a member VALUE, two bracket groups |
| `g3_depth112.sv` | the DEPTH axis (0 / 1 / 2) and the INDEX-FORM axis |
| `g4_fence112.sv` | THE MUST-STAY FLOOR — earl110's own shapes, in and out of a pattern |
| `censweep112.sh`, `sweepsplit112.sh`, `predict112.py` | the corpus census sweep, the two-sweep splitter (which ASSERTS the two sweeps' golden halves identical), and the BY-NAME mover prediction from PRISTINE databases |
| `attrib112.sh`, `secattr112.py`, `ATTRIB_Earlgrey.txt` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (the weaklyReferenced TAIL is never counted) |
| `kinds112.cpp` | the WHOLE-DATABASE kind/name census over `Serializer::AllObjects` — the attribution instrument for a database whose dump is too large to diff, and the one that cannot miss a change outside the shapes a dump diff happened to show |
| `wide112.sh`, `widerun112.sh`, `BOUNDARY_WIDE.*` | the wide boundary over every `.sv`/`.v` in `tools/probe` at any depth, both views, both binaries, workdir-normalised dump compare |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates (copied verbatim from their owning pass dirs) |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp` | the official `uhdm-cmp` output on the head row, both modes, both binaries |
| `OWNER_BEFORE.r10earl112.txt` / `OWNER_AFTER.r10earl112.txt` | `own112` on the pristine and on the patched databases |
