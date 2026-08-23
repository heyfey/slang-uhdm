# r10buvm31 — § assocPropPatternInitRidesElem31

**Base commit `265eea9`. The head this pass was given:** the 47-line
BuildUVMPkg and SeqDriver `uhdm-cmp` head, both modes, over
`uvm_sequence_library.svh`

```
protected int seqs_distrib[string]  = '{default:0};
```

`LHS:` golden's `operation` (op 75) with `vpiParent -> int_var
(uvm_pkg::uvm_sequence_library::seqs_distrib)`; `RHS: <null>`.

**Result: the head is CLEARED on four row-modes (SeqDriver default+testflags
47 → 46, BuildUVMPkg default+testflags 47 → 46), nine databases move and every
one of them was predicted by name before the sweep, every other row in both
corpora is byte-identical, and two purpose-built goldens
(`g31a3.sv`, `r10svs6repro/b4_qual.sv`) go from one head to ZERO heads —
whole-design `uhdm-cmp` EQUAL — in BOTH views.**

---

## 1. The head, decoded from the pristine cmp log

`variables::Compare` (UHDM `build/generated/src/variables.cpp`) reads
`Expr()`; `array_var::Compare` runs `variables::Compare` first and then walks
`Variables()`, which is the `vpiReg` ELEMENT.  So the walk on
`array_var (…::seqs_distrib)` compares the ARRAY's `vpiExpr` (equal — we
already emitted it), then descends into the element `int_var` and compares
ITS `vpiExpr`: golden has the operation, we had nothing.  `SafeCompare`'s
SINGULAR overload with `rhs == nullptr` names the VALUE as LHS and leaves RHS
unset — which is exactly the printed head, and why the head's own text shows
the operation's `vpiParent` as an `int_var`.

Golden's object, read off `~/.cache/slang-uhdm-goldens/…/golden.uhdm`:

```
array_var: (uvm_pkg::uvm_sequence_library::seqs_distrib)  56269:18-30
 |vpiExpr:  operation 56269:42-54            <-- carrier 1
 |  vpiParent -> int_var (…::seqs_distrib)   <-- parented at the ELEMENT
 |  vpiOpType:75
 |  vpiOperand: tagged_pattern 56269:52-53
 |     vpiPattern:  constant  UINT:0  size 64  constType 9  decompile 0
 |     vpiTypespec: ref_typespec -> string_typespec (default) 56269:44-51
 |vpiArrayType:3
 |vpiReg: int_var (…::seqs_distrib) 56269:18-30
      |vpiExpr: THE SAME operation                <-- carrier 2
```

## 2. DECODED FROM THE PRODUCER (Surelog), not guessed

* `TestbenchElaboration.cpp:769` — a class property's initializer is compiled
  by `ElaborationStep::exprFromAssign_`.
* `ElaborationStep.cpp:1574` — that function calls `compileExpression(…,
  Reduce::No, …)`: a class body folds NOTHING.
* `CompileHelper::compileAssignmentPattern`, `CompileExpression.cpp:3671` —
  `operation` with `VpiOpType(vpiAssignmentPatternOp)` (75); one
  `tagged_pattern` per KEYED item (`:3785`), spanned at the item's VALUE; and
  at `:3793` the key decode: when the key's `Constant_expression` has NO
  `Constant_primary` child it mints a `string_typespec` — named by the key
  identifier if the key is a `slStringConst`, and named **`"default"`**
  otherwise — spanned at the KEY.  A key WITH a `Constant_primary` (a literal
  such as `"a"` or `3`) instead runs `compileTypespec`, which is where
  golden's unnamed `integer_typespec` tags come from.
* `ElaborationStep::makeVar_` — the two-carrier fact, in two lines over ONE
  object: `:2097` `var->Expr(assignExp)` on the element and `:2289`
  `array_var->Expr(assignExp)` on the wrapper.  `assignExp->VpiParent` was
  last written by the element arm (`:1969`/`:1836`), which is why golden's
  operation is parented at the element and not at the array_var.

Nothing about the TREE had to be invented: ExprEmit's default-setter arm
already builds op 75 + `tagged_pattern` + `ref_typespec` -> `string_typespec
(default)` at golden's spans, byte for byte (measured — see §4).  What was
missing was the CARRIER and the constant WIDTH.

## 3. THE LAW

**§ assocPropPatternInitRidesElem31** — a DYNAMIC / QUEUE / ASSOCIATIVE
variable whose declaration initializer is an ASSIGNMENT PATTERN (simple,
structured or replicated) or a CONCATENATION carries ONE operation that

1. is **parented at the `vpiReg` ELEMENT variable**, not at the `array_var`;
2. hangs off **BOTH** the `array_var`'s and the element's `vpiExpr` — the same
   object; and
3. has its **DIRECT** constant operands sized at the **ELEMENT** width
   wherever `emitExpr` left the bare-decimal default of 64.

It holds at all THREE carriers, which is why the patch has three call sites
and one law: a CLASS property (`UhdmExporter.cpp`, the deferred
`§ classPropInit29` drain), a MODULE/instance-scope variable
(`TypeEmit.cpp emitDynArrayVar`), and a PACKAGE-scope variable
(`ParamEmit.cpp emitPkgArrayVar`).  The FIXED-array twin already obeyed it on
both the class side (`§ fixedClassPropIsArrayVar6`) and the module side
(`emitArrayVar`, "Array-pattern initializer"), and is untouched.

Clause (3) is fenced to DIRECT constant operands, and that is a measurement:
a TAGGED operand is not a constant, so `'{default:0}` keeps golden's 64 for
free (which is what the corpus head needs), while `'{1,2,3}` on an `int`
element gives three size-32 constants, on a `byte` element size 8, and
`'{3{2}}` (op 76) gives the COUNT operand 32 with the NESTED concat's own
operand left at 64.

### What the law does NOT do
* It never invents an initializer.  The kind test is the gate and the
  `uhdmoperation` test is the second gate, so a shape that folds elsewhere
  stays off exactly as `§ classPropPatternInit29` already required.
* It does not touch FIXED arrays, scalars, `new`/call/system-call/scoped-ref
  initializers, or any subroutine/block-local array (those carriers were never
  in the measured population).

## 4. MEASUREMENT — the census

`r10buvm31cen.cpp` prints one row per `variables` object: name span, UHDM
kind, `vpiArrayType`, the JUDGE-VISIBLE shape of `vpiExpr` (op type, operand
tree, tag kind+name+span, constant `constType`/`size`/`decompile` — every
field a generated `Compare` reads and none it does not), the expression's own
`vpiParent` KIND beside it as a non-key column, and a reachability flag.
`cmp31.py` joins GOLDEN / PRISTINE / PATCHED as a MULTISET on
(loc, kind, arrayType, name).

| arm | what it covers | FIXED | MOVED-WRONG | MOVED-STILL-UNEQUAL | UNCHANGED-UNEQUAL |
|---|---|---|---|---|---|
| `g31a1.sv` | assoc `[string]`/`[int]`, `bit[7:0]` elem, keyed, dyn, queue, `string` elem, module twin, package twins, class-in-module, protected/local/static/rand | **17** | 0 | 0 | 0 |
| `g31a2.sv` | simple/concat/replicated patterns, `byte` elem, 2-D assoc, `[int]` keys, fixed-array controls, module + package twins | **30** | 0 | 0 | 0 |
| `g31a3.sv` | the same class + module population with NO package variable | **21** | 0 | 0 | 0 |

`grid31.sh` builds all three databases per arm in BOTH views (`def` and
`--elabuhdm`) and runs the OFFICIAL `uhdm-cmp` on each side:

```
g31a3.sv  def : pristine 1 head  ->  patched 0 heads     (uhdm-cmp EQUAL)
g31a3.sv  elab: pristine 1 head  ->  patched 0 heads     (uhdm-cmp EQUAL)
```

`g31a1.sv` / `g31a2.sv` keep ONE head after the patch, and it is a DIFFERENT,
PRE-EXISTING law: golden puts `vpiSigned:1` on a PACKAGE-scope `array_var`
and nothing on its element, while `emitPkgArrayVar` does the opposite
(`§ arrayVarSignedWritten8` was never applied at that third site).  That is
residue R1 below; it masks the initializer field, which is why the census —
not the head — is this pass's cell-level evidence, and why `g31a3.sv` (no
package array variable) exists to show the law reaching CMP_EQUAL on its own.

### Negative controls that FIRE
* FIXED arrays at class and module scope (`cf_fix`, `cfd_fix`, `mf_fix`) are
  already equal on both binaries and stay untouched.
* The module-scope CONCATENATION (`m_cat`, and the corpus's `UnsizedArray`)
  was already equal before the patch and is byte-identical after it.
* Package/module scalar variables, class scalar properties and every
  `= new` / call / `$system` initializer are outside the kind gate.

## 5. MEASUREMENT — the corpus, PREDICTED BEFORE THE SWEEP

`sweepcen31.sh` + `sweepceng31.sh` ran the census over EVERY control database
at `265eea9` (surelog: 956 of ours, 1523 golden cache entries; uhdm2rtlil:
1358 of ours, 1458 golden), and `mover31.py` split the population.  The
prediction is committed verbatim in `PREDICTION.txt`:

* **A (class scope — the element gains `vpiExpr`)**: NINE databases, one cell
  each, all of them the SAME `seqs_distrib` line —
  `default/{BuildUVMPkg,MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}` and
  `testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}`
  (`testflags/Scoreboard` has no database — SKIP-NOFILE — so it cannot move).
* **B (module/package scope — both carriers gain it)**: ZERO databases in
  either corpus.  Golden holds 160 unsized-array initializers across 40
  surelog test-modes, but every one is a CONCATENATION we already emit
  (`UnsizedArray`) or lives in a test with no database of ours (AmiqEth,
  IbexGoogle, Opentitan, CoresSweRV, … all SLANG_REJECT / SURELOG_FAIL).

`byteverify.sh SELFCHECK=1` then measured **MOVERS 9 / 956** (surelog) and
**MOVERS 0 / 1358** (uhdm2rtlil) — the predicted set exactly, name for name.
`movers31.sh` attributes each one ORDER-BLIND (sorted, path- and
id-normalised dumps — the only sound reading for the Scoreboard/default coin):
**four lines per database, identical in all nine**

```
< \_array_var: (uvm_pkg::uvm_sequence_library::seqs_distrib)   <- old operation parent
> \_int_var:   (uvm_pkg::uvm_sequence_library::seqs_distrib)   <- new operation parent
> \_operation: , line:…:42, endln:…:54                          <- the element's new
> |vpiExpr:                                                        vpiExpr
```

## 6. GATES (all green, on the worktree binary at every step)

| gate | result |
|---|---|
| build | `slang_uhdm` built `-j 2`; pristine `c7c8fb93c856c9eb9bc57b534f9d770a`, patched `80926ef2e2ca81f480cbb436e0283652` |
| goldens | 23 PASS / 0 FAIL; negative control `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL |
| uhdm2rtlil testflags | vs committed `results/gate_uhdm2rtlil.csv` **0 differing rows**; vs `/tmp/ctl_u2r_265eea9.csv` 0 |
| uhdm2rtlil default | vs `/tmp/ctl_u2r_def_265eea9.csv` **0 differing rows** |
| surelog both modes | vs committed `results/golden_surelog.csv` **0 differing rows of 1588** (status AND dump column); histogram unchanged: default 471 CMP_EQUAL / 10 CMP_NOTEQUAL, testflags 466 / 9. NO conversion is claimed and `results/*.csv` is untouched. |
| byteverify SELFCHECK=1 | surelog 9/956 movers (all predicted, all attributed); uhdm2rtlil 0/1358 |
| canaries | surelog `ok=52 changed=0`; uhdm2rtlil `ok=8 changed=0`; `ctcan2.sh` PASS both; `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| row heads | SeqDriver 47→**46** both modes; BuildUVMPkg 47→**46** both modes; SimpleUVM 56, Scoreboard 56, MiniAmiq 60, Earlgrey 11664/11404, Rggen 0 — all unchanged |

### Boundary gate (`bound31.sh`, four configurations)
Every `.sv`/`.v` under a COPY of the whole probe tree, both binaries, both
views, file mode AND directory mode (the sd8-12 subdirectory arms):

```
MODE=file VIEW=def   PROCESSED=3545 LISTED=3545 DIFFER=3  asym rejects 0
MODE=file VIEW=elab  PROCESSED=3545 LISTED=3545 DIFFER=3  asym rejects 0
MODE=dir  VIEW=def   PROCESSED=1516 LISTED=1516 DIFFER=6  asym rejects 0
MODE=dir  VIEW=elab  PROCESSED=1516 LISTED=1516 DIFFER=6  asym rejects 0
```

* `r10svs6repro/b4_qual.sv`, `r10uvm29repro/t39a/dut.sv`,
  `r10uvm29repro/t39c/dut.sv` — the law's own cells (class-scope assoc/dyn/
  queue properties with pattern initializers).  Scored with `grid31.sh` +
  `cmp31.py` against golden: **FIXED 4 / 1 / 3, MOVED-WRONG 0 in all three**,
  and `b4_qual.sv` goes 1 head → **0 heads** (whole-design `uhdm-cmp` EQUAL)
  in BOTH views.  Its two remaining unequal cells are pass-29's own recorded
  residues (a based literal keeping `32'hff` vs our decimal `255`; a
  `time`-vs-`real` var kind) and are untouched.
* `r10uvm75repro`, `r10uvm76repro`, `r10v109repro` (directory mode only) — the
  documented `vpiTaskFunc` LIST-ORDER COIN.  ORDER-BLIND sorted diff = **0
  lines** on all three, in both views: re-ordering of the same objects, no
  content change.
* Every bind-window arm (`§ classArgBind12`,
  `§ retNameRecvCollapseArgsBindLikeBody15`, `§ collArgNamedBlkLocalNoBind15`,
  `§ controlBodyNoBind28`, `§ blkLocalSameCtrlDepthArgBinds57/64`,
  `§ pkgVarBindsOnlyThroughInstance88`, `§ formalDefaultBindsLikeBody13`,
  `§ classInBodyRecvCallArgNoBind52`, `§ superNewFormalBinds28`,
  uvm81's formal contest, sd10/sd12 `scopedReach`, `§ newArrayArgNoBind16`'s
  `paDynamic_array_new` arm) is byte-identical in all four configurations —
  this law owns NO binding window: it never calls a bind, and the only
  argument it changes in any `emitExpr` call is the PARENT pointer of the
  top-level operation.

## 7. Residues (ranked) and R0

* **R1 — `§ arrayVarSignedWritten8` never reached `emitPkgArrayVar`.**  For a
  PACKAGE-scope unsized array of a signed integer atom, golden puts
  `vpiSigned:1` on the `array_var` and NOTHING on the `vpiReg` element; we do
  the exact opposite.  `variables::Compare` reads `VpiSigned`, so it is the
  head of `g31a1.sv`/`g31a2.sv` on both binaries.  It is the SAME split the
  class-scope and module-scope carriers already model (the ADD half on the
  array_var, the SUPPRESS half on the element); only the package copy is
  missing it.  Corpus reach: none measured (no package-scope unsized array of
  a signed atom in either corpus), so it is a purpose-built-golden residue.
* **R2 — a BASED literal initializer keeps its source spelling.**  Pass 29's
  own recorded residue: golden `constType 5, decompile 32'hff` where we emit
  `constType 9, decompile 255` (`t39a d_bas`).
* **R3 — `time` vs `real` var kind** for a `time`-typed class property
  (`t39c t_rt`), also pass 29's.
* **R4 — the CONSTANT-WIDTH rule at other carriers.**  Clause (3) is applied
  only where this pass measured it (the unsized-array carrier).  Whether a
  scalar class property's concatenation/pattern operands follow the same
  element-width rule is NOT measured here and is deliberately not changed.

**R0 (the next head).**  With this landed, SeqDriver and BuildUVMPkg both
modes stand at 46 cmp lines and the new head is the SAME object in both:

```
LHS: ref_obj (uvm_pkg::uvm_sequence_library::m_add_typewide_sequence::this_type::add_typewide_sequence)
     line 413:3-14 (SeqDriver) / 56491:3-14 (BuildUVMPkg)
     vpiParent -> begin (…::m_add_typewide_sequence)
     vpiName:this_type::add_typewide_sequence
```

— a `this_type::<method>` STATEMENT-level scoped call inside a class method
body, i.e. the STATEMENT twin of `§ classPropScopedCallIsRefObj29` (which owns
the same degradation in a property INITIALIZER).  SimpleUVM/Scoreboard stay at
56 and MiniAmiq at 60, so this head is worth four row-modes.

## 8. Files

* `r10buvm31cen.cpp` + `build31.sh` — the census (statically linked against
  `~/.local` UHDM so it reads exactly the databases the sweeps wrote).
* `sweepcen31.sh` / `sweepceng31.sh` — census sweeps over a control workdir
  (ours / golden-cache side).
* `mover31.py` — the mover predictor (produced `PREDICTION.txt`).
* `grid31.sh` — three databases per arm × two views + `uhdm-cmp` on each side.
* `cmp31.py` — the three-way multiset scorer.
* `movers31.sh` — order-blind mover attribution.
* `bound31.sh` — the boundary gate (`bound24.sh`, unchanged but for its header
  and default OUT).
* `g31a1.sv` / `g31a2.sv` / `g31a3.sv` — the purpose-built goldens.
* `PREDICTION.txt` — the mover prediction, written before any sweep.
* `byteverify.sh` / `canaries.sh` / `ctcan2.sh` / `canaudit.sh` /
  `rowheads.sh` — the shared gate scripts, copied so `canaudit.sh` runs here.
