# r10vbuvm30 — the ADVERSARIAL VERIFIER of r10buvm30 (§ `negLitPkgRetFoldNested30`)

**Verdict: ACCEPT WITH FIX.**  The shipped patch's headline reproduces
bit-for-bit, but the law as shipped folded FOUR written literal shapes that
golden leaves standing, and folded a RANGED part-select bound that golden
leaves standing too — five classes of **pristine-RIGHT -> patched-WRONG on
legal SystemVerilog**.  Both are fixed here, minimally and inside this pass's
own surface, and the whole battery is re-run on the fixed binary.
Deliverable: `/tmp/r10buvm30.verified.patch`.

---

## 1. WHAT REPRODUCED

Built all three binaries myself (`-j 2`, md5 taken separately, frozen `chmod
555` before any sweep):

```
pristine  0726167                          70c97f0137784c3efeb1fdf8050130d0   <- implementer's number
shipped   0726167 + /tmp/r10buvm30.patch   a663c2234783ed907fb4d74f42f5566b   <- implementer's number
verified  shipped + the fix below          d13f0abae6993c6249a9502c3458a943
```

Every headline number reproduced: goldens 23/0 and `/bin/false` 0/23; u2r
679/50/2 in both modes; surelog 937 CMP_EQUAL / 19 CMP_NOTEQUAL, row for row,
NO conversion; `ct8rows` PASS against the committed baselines and against my
own pristine CSVs; **byteverify MOVERS 9/956 and 0/1358**, the nine exactly the
nine `PREDICT.r10buvm30.txt` names, 13 sorted-dump lines each (39 where the
site has three import-clone copies) and **every line at the one folded site**;
heads BuildUVMPkg 42 -> 46 both modes and Scoreboard/default 42 -> 565, with
all four committed `head_*.cmp` logs reproducing **byte-identical** from my own
sweeps.  Full battery in `GATES.r10vbuvm30.txt`.

The decoded model — `FunctorCompilePackage`'s twin compile, `compileStmt`'s
`paRETURN` arm as the only carrier of `Reduce::Yes`, and `compileExpression`
running `reduceExpr` at the tail of EVERY call so the fold reaches any depth —
is correct as written, and the two fences the pass added (a minus directly
under a minus; anything inside a `func_call`'s argument subtree) both hold on
purpose-built goldens.

---

## 2. WHAT BROKE — five classes, all measured on golden

The pass modelled the folded value as *the literal's own bits read as an
unsigned decimal, negated*.  That is not what Surelog does.
`ExprEval::reduceExpr`'s `vpiMinusOp` arm (UHDM `templates/ExprEval.cpp:3307`)
negates **`get_value()` of the constant Surelog built**, and REFUSES the fold
whenever `get_value` sets `invalidValue`.  `get_value`
(`templates/ExprEval.cpp:1946`) parses the constant's `VpiValue` **digit
string**, never the width-truncated value, and carries two refusals:

* `vpiDecConst` — the digits go through the STRICT int64 `NumUtils::parseInt64`.
  `64'd9223372036854775808` overflows and **nothing folds**.  There is no size
  check, so `128'd5` DOES fold, at size 128.
* `vpiBinaryConst` / `vpiOctConst` / `vpiHexConst` — `VpiSize() > 64` refuses
  outright, and otherwise the digits are parsed LENIENTLY (int64, then uint64
  cast down).

Consequences, every one of them measured on a purpose-built golden
(`GOLDENFACTS.r10vbuvm30.txt` is the full table):

| # | written, inside the window | golden | shipped patch | pristine |
|---|---|---|---|---|
| **A** | `-64'd9223372036854775808` | keeps the OPERATION | folds to `INT:-9223372036854775808` | **matches golden** |
| **B** | `-70'b1`, `-68'h1`, `-128'hFFFFFFFFFFFFFFFFFFFF` | keeps the OPERATION (`VpiSize > 64`) | folds | **matches golden** |
| **C** | `-4'd20` / `-4'hFF` / `-2'b1111` / `-3'o77` | `-20` / `-255` / `-15` / `-63` | `-4` / `-15` / `-3` / `-7` | operation |
| **D** | `-64'hFFFFFFFFFFFFFFFF` | `INT:1` | `INT:-18446744073709551615` | operation |
| **E** | `return v[-1 : -2];` | default run: BOTH bounds stay OPERATIONS; elab run: bound folds spanning the WHOLE `-1` | folds with the MINUS-TOKEN span, in both views | **matches golden in both views** |

**A, B and E are outright regressions**: the pristine binary reproduced golden
byte for byte at those cells and the patch destroyed it.  On `vg30_i_digits`
the shipped patch is a NET LOSS against pristine — golden-agreeing cells
97 -> 90 (def) and 95 -> 90 (elab).  C and D are not regressions (pristine
differs too) but they MINT values golden never holds, which contradicts the
report's "ZERO minted that golden lacks" claim outside the corpus sample it
was measured on.

E is the sharpest: `inPsRangeBound` — the flag this emitter already carries for
exactly this distinction — is documented in `UhdmExporter.h` with the measured
law that *a RANGED part_select keeps its bound TREES* while an
indexed-part-select base and a bit_select index fold.  § `connIpsPkgParamBound-
NoTs65` carves the same shape out for the enum-const fold.  The pass added a
third fold at that site without the carve-out.

---

## 3. THE FIX (production surface: `src/EmitHelpers.h`, `src/ExprEmit.cpp`)

1. **`srlgNegLitGetValue30()`** (EmitHelpers.h) — `ExprEval::get_value`
   transcribed for the literal about to be folded: base and digits from the
   literal's own source text (`rawTextLit`), size from its slang type, the
   strict/lenient `NumUtils` parsers reproduced with `std::from_chars`.  It
   returns `false` exactly where `get_value` would set `invalidValue`, which
   is the refusal that classes A and B need, and returns the untruncated
   digit value, which is what classes C and D need.  The negation is done
   through unsigned arithmetic so `INT64_MIN` wraps the way
   `int64_t val = -val0;` does instead of trapping.
2. **the fold gate** (ExprEmit.cpp) gains `!inPsRangeBound` — class E — and
   calls the helper BEFORE emitting the operand, so a refusal leaves no stray
   constant in the arena for the ordinary unary-op path to shadow.

Nothing else moves.  § `negLitPkgRetFold86`'s own top-level arm in
`StmtEmit.cpp` is DELIBERATELY untouched (see residue R1).

After the fix, on nine purpose-built goldens x 2 views (`ARMS.r10vbuvm30.txt`):
**every arm's golden-agreeing cell count is >= pristine's, and the only
remaining `LOST` rows are the class_defn section-attribution artifact** (golden
files the unfolded class_defn copy under `uhdmtopPackages`; our dump files it
under `uhdmallClasses` — a pre-existing structural difference, present on the
pristine binary too, and `AGREE_pat > AGREE_pris` on every arm where it shows).

```
                       SHIPPED                 VERIFIED
  arm/view             AGREE pris->pat  LOST   AGREE pris->pat  LOST
  vg30_a_positions/def   127 -> 134       4      127 -> 138       0
  vg30_a_positions/elab  129 -> 135       5      129 -> 137       3 (artifact)
  vg30_c_values/def       97 -> 104       2       97 -> 107       0
  vg30_c_values/elab      97 -> 104       2       97 -> 107       0
  vg30_i_digits/def       97 ->  90      10       97 -> 104       0
  vg30_i_digits/elab      95 ->  90       8       95 -> 102       0
  (b_homes, d_import, e_targets, f_fence, g_ctrl, h_macro: LOST 0 in both)
```

---

## 4. INSTRUMENTS

* `vcells30.py` — a **VIEW-GENERAL** cell census of a `uhdm-dump`: one row per
  `constant` / `operation` / `ref_obj` / call / select / `hier_path` /
  `return_stmt`, keyed by *(top-level design section, source span, kind)* and
  carrying exactly the fields the generated `Compare` bodies read
  (`VpiDecompile`, `VpiSize`, typespec presence, `VpiOpType`, `VpiName`,
  `VpiConstType`) plus the raw value for diagnosis.  The section is part of the
  key, so the same source cell in two views is two rows and a view-swap cannot
  hide.  `vpiParent` back-edges (which the dump renders as child objects) are
  dropped.
* `vscore30.py` — a MULTISET three-way join (never a last-writer dict):
  `LOST` = a golden-agreeing cell the candidate destroyed, `GAIN` = one it
  created, `NEWMINT` = a cell neither golden nor pristine has.
* `vgarms30.sh` — golden (Surelog) + pristine + candidate, every `vg30_*.sv`,
  **both** views (default and `-elabuhdm`), fd-3 list, children `</dev/null`,
  PROCESSED asserted.
* `vbound30.sh` — the wide boundary gate, over a COPY of `tools/probe` with NO
  path filter, `.sv` AND `.v`, recursive; rc compared per cell; and every MOVED
  arm is then SCORED against a REBUILT Surelog golden with the same
  view-general comparator, so a mover is reported TOWARD or AWAY from golden
  rather than merely "different".
  `LISTED=3433 PROCESSED=3433 MOVED=34 PROCESSED-ASSERT-OK`, 0 `RC_MISMATCH`,
  0 `ASYMMETRIC_OUTPUT` (`BOUNDARY.r10vbuvm30.txt`).

The 34 movers: 12 the implementer's own arms, 18 mine, 2 `r10uvm86repro/
g86_a2_ctx.sv` (both TOWARD golden, `GAIN` 1 and 2, `LOST` 0), and 2
`r10buvm22repro/g22.sv` — see residue R5, which is NOT this pass's doing.

---

## 5. RESIDUES, RANKED

* **R1 — § `negLitPkgRetFold86` still carries the OLD value model.**  The
  top-level `return -<literal>;` arm in `StmtEmit.cpp` (~3878) computes the
  same truncated-bits string this pass's nested arm used to.  So after this
  landing `return (m == -4'hFF);` reaches golden's `INT:-255` while
  `return -4'hFF;` still emits `INT:-15`, and `return -70'b1;` still folds
  where golden keeps the operation.  Left ALONE on purpose: it is a landed
  law outside this pass's surface, it was already wrong at `0726167`, and
  changing it would move cells this pass never measured.  The fix is
  mechanical — route that arm through `srlgNegLitGetValue30` too — and is the
  single highest-value follow-up.  Zero corpus witnesses on either side
  (`vg30_c_values` / `vg30_i_digits` are the arms).
* **R2 — the enclosing expression golden EVALUATES WHOLE.**  `$signed(-1)`,
  `int'(-1)`, `eq_t'(-1)`, `{2{-1}}`, `(1 == -1)`, `(-1) ? 1 : 2`, a package
  function call: golden holds ONE constant where we hold the whole
  call/cast/operation.  Compare stops at the differing enclosing object, so
  the operand below is never reached.  Unchanged by this pass; § 86's own R3
  family, one level larger.
* **R3 — an operand with UNKNOWN bits.**  `-4'b1x01` folds in golden to
  `INT:-1` size 4, because `NumUtils::parseBinary` stops at the `x` and
  returns 1.  `isNegLitFoldShape30` refuses any literal with unknown bits, so
  we keep the operation.  A pure under-fold (pristine does the same), left
  fenced rather than guessed: `4'hx` and `1'bz` must still NOT fold, and that
  asymmetry deserves its own measured pass.
* **R4 — a REAL operand.**  `-1.5` -> `REAL:-1.500000` ct 2 in golden; we do
  not fold.  Zero corpus witnesses.  § 86's R2, unchanged.
* **R5 — an ASSOCIATIVE-ARRAY typedef leaks a BUILD ADDRESS into the
  database.**  `typedef int ka_str_t[int];` (`r10buvm22repro/g22.sv:70-72`)
  makes our `array_typespec` carry `vpiRange` = `range(0, operation(vpiSubOp,
  constant))` whose constant is `UINT:22392185` on the pristine binary and
  `UINT:22395425` on the verified one — deterministic per binary, different
  between binaries, and in the address range of the executable.  The size
  comes from `mkB(fua.range.width(), ...)` in `src/TypeEmit.cpp` (~10444),
  reached with an associative-array canonical type, i.e. a `range` read out of
  the wrong object.  Golden emits an `int_typespec` index there and holds no
  such cell, so `LOST=0 GAIN=0` and no corpus row moves — but it means ANY
  patch that shifts code layout can move that cell, and mover attribution on
  arms containing associative-array typedefs is not trustworthy until it is
  fixed.  **PRE-EXISTING at `0726167`; not introduced by r10buvm30.**  It also
  contradicts the campaign note that address order provably does not reach the
  database.
* **R6 — the concat arm's literal-slot test is not fold-aware.**  The
  `pkgRetFoldExpr30 && isNegLitFoldShape30(*olit)` clause in the
  `Concatenation` arm sets `suppressConstParent` on the written SHAPE, not on
  whether the fold will actually happen, so a `{-70'b1, 1}` inside such a
  return takes the literal-slot path with no fold behind it.  Measured
  harmless (`vg30_f_fence`: the inner constant keeps its `vpiParent`, and no
  generated `Compare` reads `VpiParent`), zero corpus witnesses; recorded so
  the next toucher knows.
* **R7 — the class_defn SECTION artifact.**  Golden's `-elabuhdm` dump files
  the unfolded class_defn copy of a package class under `uhdmtopPackages`;
  ours files it under `uhdmallClasses`.  Pre-existing, visible on the pristine
  binary, and the sole source of the three remaining `LOST` rows in
  `vg30_a_positions/elab` and the two in `g30_e_calls` / `g30_f_callshapes`.

## 6. REPORT CORRECTIONS

* "Seven purpose-built goldens" in §2 of the implementer's README; the table
  below it lists EIGHT (`g30_a` … `g30_h`), and the top-level report says
  eight.  The README's prose is the wrong one.
* `g30_a_shapes` is described as the control that proves the fence, "26 minus
  sites written OUTSIDE a return, MOVED=0".  `arms30.sh` computes MOVED with
  `retcmp30.py`, which renders ONLY `return_stmt` subtrees of the
  `uhdmtopPackages` view — so for sites written outside a return that
  measurement is vacuous.  The claim is nonetheless TRUE: the wide boundary
  gate compares WHOLE dumps and `g30_a_shapes.sv` is not among the 34 movers,
  in either view, for either the shipped or the verified binary.
* "ZERO minted that golden lacks" is true of the corpus census it was measured
  on, and false in general — see classes C and D above.
