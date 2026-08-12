# r10earl32 — § fcArgPkgParamValueFolds32

**THE HEADLINE, FIRST: `Earlgrey_0_1/default` does NOT convert.** The head this
pass was given is **CLEARED** — the row's first divergence leaves `dm_mem.sv`
entirely and lands on a `hier_path` in a different file — but the row stays
`CMP_NOTEQUAL`, byte-identical in the CSV to the committed baseline:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- fresh (patched)
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- results/golden_surelog.csv
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,   (both, unchanged)
```

Row counts are unchanged (`default` **467/13**, not 468/12), so there is nothing
for an integrator to promote and `results/*.csv` were **not** edited.

The head that replaces it (§6 R2): `flash_ctrl.sv:315`, a `hier_path`
`region_cfgs[8].base.q` where we emit something else — a hier-path law, not a
fold law.

---

## 0. THE LAW

> **§ fcArgPkgParamValueFolds32 — a PACKAGE PARAMETER passed as an ARGUMENT of a
> `func_call` or `task_call` is REPLACED BY ITS VALUE, and the ONE thing that
> stops that is the PARAMETER'S OWN INITIALISER being a CONCATENATION, a
> REPLICATION or an ASSIGNMENT PATTERN — not its type, not its dimensionality,
> not its width, not its signedness, not the call kind, and not the container.**

| # | call site | what it does |
|---|---|---|
| 1 | `src/ExprEmit.cpp` ~4573 (`emitExpr`, `NamedValueExpression`, the `scope is a Package && symbol is a Parameter` block) | computes `fcArgFold32` and turns the pre-existing § fcArgBareImportRef early-return into a CARVE-OUT: the ref is kept for exactly the parameters that arm was measured on, everything else falls through to the module-side fold below |
| 2 | `src/ExprEmit.cpp` ~5790 (same block, immediately before its `return c`) | § fcArgFoldParent32 — the new folded constant's `vpiParent` (and, in a process only, its own `ref_typespec`) |
| 3 | `src/ParamEmit.cpp` ~681 (`paramDefRhsIsOp`) | one defaulted parameter, `aggregateToo`, guarding the existing struct/union exception. Default `false`, so the two older call sites are byte-for-byte unchanged |

**STATED GATE == CODE GATE.** Read at `src/ExprEmit.cpp:4597-4608`:

```cpp
const bool fcArgPos32 =
    parent && (parent->UhdmType() == UHDM::uhdmfunc_call ||
               parent->UhdmType() == UHDM::uhdmtask_call);
const bool fcArgFold32 =
    fcArgPos32 &&
    !patParamNoFold(nv.symbol.as<ParameterSymbol>()) &&
    !paramDefRhsIsOp(nv.symbol.as<ParameterSymbol>(), /*aggregateToo=*/true);
```

Exactly two things: (1) the fold's **direct** parent is a call — nothing walks,
nothing looks through an operation; (2) the parameter's initialiser is not one of
the five non-reducing shapes. **No context flag, no view test, no import test and
NO TEXT TEST.** The qualified/bare `rawText(...).find("::")` split lives entirely
inside the carve-out body, which is unchanged, and inside § fcArgFoldParent32 —
and both spellings of that text test were measured against **macro-written** and
**escaped-identifier** cells (`a4_text.sv`, §3.4), because the standing law
requires it and because a macro-written `pk::P` has no `::` in its own written
range.

Everything the rule does not recognise keeps its previous answer. The fall-through
is deliberate: every no-fold CONTAINER law this file already carries
(§ defGenProcWildcardPkgParamNoFold19, § genNestedScopePkgParamNoFold24, the
package-init arms) now applies to a call argument for the first time, and
`a3_ctx.sv` is the arm that holds each of them (§3.3).

---

## 1. LOCALIZATION — which field, on which object

The witness, measured on the target at 981f2e3 with my own pristine build
(`uhdm-cmp`, LHS golden):

```
SOURCE  dm_mem.sv:365  abstract_cmd[2][63:32] = dm::load(ac_ar.aarsize, 5'd8, 5'd10, dm::DataAddr);
GOLDEN  constant @365:75-365:87   vpiDecompile:12'h380 vpiSize:12 HEX:380 vpiConstType:5
          vpiParent -> func_call (dm::load) @365:38   and NO vpiTypespec
OURS    ref_obj (dm::DataAddr) @365:75-365:79
          vpiName:dm::DataAddr   vpiActual -> parameter (dm::DataAddr) @34:27
```

`dm_pkg.sv:34` is `localparam logic [11:0] DataAddr = 12'h380;`.
**THE BRIEF'S SPAN QUESTION, DECODED FROM THE SOURCE AS INSTRUCTED**: the argument
text is the lone scoped identifier `dm::DataAddr`, 12 characters, cols 75..86.
Golden's constant spans **all twelve** (75..87 exclusive); our ref_obj spans
**four** — the `dm::` qualifier alone, which is what § fcArgBareImportRef's
`setLoc(ref, start .. start + pkgname.size() + 2)` produces. So the two spans are
not "the argument is wider than the identifier": they are *the whole read* versus
*the qualifier*, and the fold's ordinary `setLoc(c, expr.sourceRange)` lands on
golden's exactly.

`BaseClass::Compare` reads `VpiType` before anything else, so the OBJECT KIND —
`constant` vs `ref_obj` — was the row's whole head. That also bounds what this
pass can be: a fold-vs-ref law, not a field law.

---

## 2. THE MECHANISM — why the existing arm answered wrong

`src/ExprEmit.cpp` has carried, since r10earl11, an arm that returns a ref for
**every** package parameter in a call-argument position:

```cpp
// Function-call ARGS keep a pkg-scoped ref (named pkg::P, anchored at the
// package-qualifier span) bound to the package's def parameter object.
if (parent && (parent->UhdmType() == UHDM::uhdmfunc_call || ... uhdmtask_call))
```

Its § fcArgBareImportRef note names its two witnesses, and **both are
pattern-initialised**:

* Earlgrey `aes_sbox_canright`'s `aes_mvm(data_i, A2X)`, where
  `aes_sbox_canright_pkg.sv:87` is
  `parameter logic [7:0] A2X [8] = '{8'h98, ...};`
* `tools/probe/r10earl_repro/vi.sv` rows A/B, `pick(AVEC, sel_i)` /
  `pick(vip::AVEC, sel_i)`, where `AVEC` is `logic [7:0] AVEC [4] = '{...}`.

The arm then generalised "a call argument keeps its ref" to every parameter —
and **vi.sv's own rows C/D/E/F refute that, and always did**. Rows C–F are
`thru(ASCL)` / `thru(vip::ASCL)` with `parameter logic [7:0] ASCL = 8'h5;`, in a
cont-assign and in a process, and golden folds **all four** while we kept refs on
all four. That file has been in the tree since pass 11; the refutation was
measurable the day it was written.

---

## 3. THE GRID, CELL FOR CELL

Five arms, `arm32.sh` (r10earl31's driver, carried forward: LHS always golden,
`sed 1d` both dumps, binary md5 printed every run, missing database fatal, each
arm in its own scratch dir). Instruments: `census32.py` (the POLICY CENSUS —
every call argument cross-tabbed by call kind × object kind, then **joined
argument-for-argument on the argument's START span**, because the fold and the
ref disagree about the END span by construction), `cells32.py` (per-cell table:
kind, span, decompile, `vpiParent`, `vpiTypespec` → actual), `argref32.py` (what
golden's *kept* refs actually bind to). Both readers have a `--selfcheck` that
RUNS:

```
$ python3 census32.py --selfcheck
SELFCHECK calls=1 args=['constant', 'ref_obj']
SELFCHECK: PASS (the vpiParent stub of a call printed INSIDE its own argument
                 must not be counted as a second call, and the vpiFunction stub
                 must not be counted as an argument)

$ python3 cells32.py --selfcheck
SELFCHECK rows=1 -> ('constant', '5:12-5:18', "12'h380", 'param_assign',
                     'ref_typespec(work@m)->logic_typespec@3:54-3:59', '')
SELFCHECK: PASS (the vpiParent of the ARGUMENT must be read as param_assign and
                 NOT confused with the enclosing call; the ref_typespec
                 introduced by |vpiTypespec: must be FOUND and its own
                 |vpiActual: read one level deeper; the constant stub printed
                 inside that ref_typespec must not become a second row)
```

### 3.0 THE ONE-LINE RESULT

| arm | cells | cell-diffs BEFORE | cell-diffs AFTER | what is left |
|---|---|---|---|---|
| `a2_type` | 16 | 10 | **0** | — |
| `a1_kind` | 29 | 11 | 6 | 5 × R1 (formal ts) + 1 pre-existing `$clog2` parent |
| `a3_ctx` | 10 | 7 | 1 | R4 (cross-package pkg init) |
| `a4_text` | 9 | 9 | 9 | 9 × R1, of which 2 also carry R5 (escaped span) |
| `a5_init` | 14 | 9 | 7 | R3 (value encoding) ×3, R6 (unfoldable kinds) ×4 |

`a4_text`'s cmp head depth goes **48 → 17**; no arm's head got deeper.

### 3.1 a2_type — THE DISCRIMINATOR, AND THE TWO HYPOTHESES THE CORPUS CANNOT SPLIT

Position held at the witness's (module-local function-call argument, in a
process, qualified read, no import). Only the parameter changes.

**Why this arm exists.** On Earlgrey every folded call-arg parameter is BOTH
one-dimensional AND literal-initialised, and every ref-kept one is BOTH
multi-dimensional AND operation-initialised, so the design alone cannot tell
"type" from "initialiser". t3 and t2 break the correlation on purpose.

| cell | parameter | golden | ours before | ours after |
|---|---|---|---|---|
| t1 | `logic [11:0] T1 = 12'h380` — **the witness's own shape** | **FOLDS** | ref | **exact** |
| t2 | `logic [7:0] T2 = {4'h1, 4'h2}` — ONE-dim, **CONCAT** | **ref** | ref | ref ✓ |
| t3 | `logic [1:0][3:0] T3 = 8'hAB` — **MULTI-dim, LITERAL** | **FOLDS** | ref | **exact** |
| t4 | `logic [1:0][3:0] T4 = {4'h1, 4'h2}` | ref | ref | ref ✓ |
| t5 | `logic [7:0] T5 [2] = '{...}` — UNPACKED | ref | ref | ref ✓ |
| t6 | `int T6 = 3` | FOLDS | ref | **exact** |
| t7 | `T7 = 7` — UNTYPED | FOLDS | ref | **exact** |
| t8 | `logic [7:0] T8 = 8'h1 + 8'h2` — **ARITHMETIC init** | **FOLDS** | ref | **exact** |
| t9 | `logic signed [7:0] T9 = -8'sd3` | FOLDS | ref | **exact** |
| t10 | `logic [1:0][3:0] T10 = '{4'h1, 4'h2}` — PATTERN | ref | ref | ref ✓ |
| t11 | `logic [63:0] T11` — 64 bits | FOLDS | ref | **exact** |
| t12 | `logic [71:0] T12` — **72 bits, > 64** | FOLDS | ref | **exact** |
| t13 | `byte_t T13` — **TYPEDEF'd** type | FOLDS | ref | **exact** |
| t14 | `ps_t T14 = '{a:.., b:..}` — packed STRUCT, pattern | ref | ref | ref ✓ |
| t15 | `e_t T15 = E1` — **ENUM-TYPED** parameter | FOLDS | ref | **exact** |
| t16 | `{4'h0, y32::T16}` — the read inside a CONCAT | operation | operation | operation ✓ |

**16 of 16 cells now match golden on kind, span, decompile, parent and typespec.**
t3 vs t2 is the whole argument: a two-dimensional packed parameter with a plain
literal init FOLDS, a one-dimensional one with a concat init does NOT.

### 3.2 a1_kind — CALL KIND, SPELLING, CONTAINER, DEPTH

Origin held at the Earlgrey witness's (`logic [11:0] P12 = 12'h380`, qualified,
in a module with no import). **Golden folds in every call kind and every position
measured**, including the ones the brief asked about by name:

| cell | what | golden | ours after |
|---|---|---|---|
| c1 48 | **PACKAGE function**, qualified call, cont-assign — the witness's call kind | FOLDS | **kind/span/parent exact**, ts = R1 |
| c2 50 | MODULE-local function, cont-assign | FOLDS | exact, ts = R1 |
| c3 58 | **TASK CALL** (`task_call`, not `func_call`) | FOLDS | **exact** |
| c4 53 | `$clog2` — `sys_func_call` | folds on BOTH sides already | unchanged (parent residue R7) |
| c5 56 | package function **inside a process** | FOLDS, **bare** | **exact** |
| c6 57 | module function inside a process | FOLDS, bare | **exact** |
| c7 59 | the arg is an **OPERATION** over the param (`P12 + 12'h1`) | the operation's LEAF already folds on both sides | unchanged — the gate is a DIRECT-parent test, so the whole arg is never touched |
| c8 60 | **NESTED** call (`mf(sz, id12(k32::P12))`) | inner arg FOLDS | **exact** |
| c9 61 | **static CLASS METHOD** `kc::sm(k32::P12)` | Surelog emits no call at all (a bare `ref_obj (work@k32a.kc::sm)`) — **cell UNMEASURABLE**, both sides identical | unchanged |
| c10 62 | ternary arg | operation, leaf folds both sides | unchanged |
| c11 63 | concat + part-select arg | operation | unchanged |
| c12 70 | a call **inside a FUNCTION BODY** | FOLDS **and carries the formal ts** | **exact, ts included** (the stamper's `currentTf` branch already admits constants) |
| c13 86 | qualified read in a module that **DOES import** the package | FOLDS | exact, ts = R1 |
| c14 87 | the same read written **BARE** | FOLDS, **`vpiParent` = the PACKAGE's `param_assign`**, span = the identifier | **exact parent + span**, ts = R1 |
| c15 99 | a module that is **NEVER INSTANTIATED** (def listing only) | FOLDS | exact, ts = R1 |

c15 answers the brief's question (f) — *does the fold need an elaborated body?*
**No.** A def-only listing folds exactly like an elaborated one.
c7 answers question (b) — *does golden fold the whole arg or just the leaf?*
**Just the leaf**, and it already did on both sides, which is why the shipped gate
is a direct-parent test and not a walk.

### 3.3 a3_ctx — THE NO-FOLD CONTAINERS SURVIVE THE FALL-THROUGH

The fix is a fall-through, so every container law had to be re-measured against a
call argument. Each of these is a cell:

| cell | container | golden | ours after |
|---|---|---|---|
| g1 24 | a module **PARAMETER DEFAULT** that is a call | FOLDS | **exact** |
| g2 33 | a module **LOCALPARAM init** that is a call | FOLDS | **exact** |
| g3 46 | a **BARE** read in a **DEF-view generate-block process** | **ref** (§ defGenProcWildcardPkgParamNoFold19) | **ref ✓ — the law still wins** |
| g4 47 | a **QUALIFIED** read in the SAME process | FOLDS | **exact** |
| g5 58 | a bare read in a **NESTED generate scope** | **ref** (§ genNestedScopePkgParamNoFold24) | **ref ✓** |
| g6 | a call in a **port-connection actual** | folds both sides | unchanged |
| g7 68 | both arms of a **ternary** | FOLDS ×2 | **exact ×2** |
| g8 77 | a **package** localparam init reading its **OWN** package's param | **ref** | **ref ✓** |
| g9 78 | a package localparam init reading **ANOTHER** package's param, qualified | FOLDS | **ref — R4, not shipped** |
| g10 84 | a module **instantiated TWICE** (def + 2 elab) | FOLDS | **exact** |

g3/g4 are the sharpest pair in the pass: the **same process**, the **same
parameter**, one written bare and one qualified, and golden answers differently —
and the fall-through reproduces both.

### 3.4 a4_text — THE MANDATORY TEXT-TEST ARM

The shipped **gate** reads no text, but the code it hands the fold to does
(`rawText(expr.sourceRange).find("::")`, twice). The standing law requires macros
and escaped identifiers, and here is what they said:

| cell | spelling | golden | ours after |
|---|---|---|---|
| e1 42 | `mf(m32::P)` written out | constant @42:18-42:24, `p=func_call` | **kind/span/parent exact** |
| e2 43 | `mf(`QP)` — the SAME read **MACRO-WRITTEN** | constant @43:18-43:24 — **golden spans the EXPANSION, 6 chars, not the 3-char macro call** | **exact** — `rawText` returns the expanded `m32::P`, so the `::` test reads QUALIFIED and the parent is the call, as golden has it |
| e3 44 | the **whole call** macro-written | constant, `p=func_call` | **exact** |
| e4 45 | `mf(m32::\p@x )` — **ESCAPED param name**, qualified | constant, `p=func_call` | **exact except the span** (R5) |
| e6 46 | the FORMAL is **WIDER** than the parameter (`logic [19:0]` vs `logic [11:0]`) | constant `12'h380`, **vpiSize 12 — golden does NOT resize to the formal** | **exact (size 12)** |
| e7 47 | an **`int`** formal | constant `12'h380` | **exact** |
| e8 57 | `mf(P)` **BARE** after a wildcard import | constant @57:18-57:19, **`p=param_assign`** | **exact parent + span** |
| e9 58 | the same BARE read **MACRO-WRITTEN** | constant @58:18-58:19, `p=param_assign` | **exact** |
| e10 59 | **BARE + ESCAPED** name | constant, `p=param_assign` | **exact except the span** (R5) |

The macro pair e1/e2 is the cell that had to be built: a text test on a macro's
*call* range would have read e2 as BARE and re-parented its constant at the
package `param_assign`, where golden parents it at the call. It does not, because
slang's `sourceRange` for a macro-expanded expression covers the **expansion**.
Every ts cell in this arm is R1 (§6).

**One cell was BUILT AND REMOVED**: an **escaped PACKAGE name**
(`package \m32$esc ;` read as `\m32$esc ::E`) aborts Surelog during
"Compile package", so there is no golden for it. It is recorded as
**unmeasurable**, not as passing.

### 3.5 a5_init — THE PREDICATE'S EDGES

| cell | initialiser | golden | ours after |
|---|---|---|---|
| n1 | `12'h380` literal | FOLDS | **exact** |
| n2 | `{4'h1, 4'h2}` concat | ref | ref ✓ |
| n3 | `{2{4'h3}}` **REPLICATION** | ref | ref ✓ |
| n4 | `8'({4'h1, 4'h2})` **CAST of a concat** | ref | ref ✓ (the predicate looks through explicit casts) |
| n5 | `I5 = I2` — reads a CONCAT param | **FOLDS** | folds, **decompile differs** (R3) |
| n6 | `I6 = I1[7:0]` — a SELECT of a param | FOLDS | folds, decompile differs (R3) |
| n7 | `int'{default: 3}` — § castDefaultPatternConcat | FOLDS | folds, **value differs** (R3) |
| n8 | `f32(8'h2)` — a **FUNCTION-CALL** init | FOLDS | **exact** |
| n9 | `8'hXZ` — **UNKNOWN bits** | FOLDS | ref (R6) |
| n10 | `string "hi"` | FOLDS | ref (R6) |
| n11 | `real 1.5` | FOLDS | ref (R6) |
| n12 | packed struct, **LITERAL** init | FOLDS | ref (R6) |
| n13 | packed struct, **PATTERN** init | **ref** | **ref ✓ — this is the FuncStructVal regression's cell** |

---

## 4. THE CENSUS AND THE PREDICTION, BOTH RUN BEFORE CODING

### 4.1 THE WHOLE-DESIGN POLICY CENSUS — golden's answer for every call argument

`census32.py` on the complete Earlgrey dumps (4.82M / 4.65M lines, `sed 1d`
both), joined argument-for-argument on the START span:

```
                 BEFORE                                   AFTER
func_call    golden=ref_obj    ours=ref_obj    234    ->   234
func_call    golden=constant   ours=constant    70    ->    78
func_call    golden=constant   ours=ref_obj      8  <== THE PREDICTED MOVER SET
func_call    golden=operation  ours=operation   58    ->    58
   ... bit_select 30, part_select 13, hier_path 12, func_call 6, sys_func_call 134 ...
joined disagreements: 8   ->   0
```

**The prediction was exactly 8 objects, and the census named all eight before a
line was written** — `dm_mem.sv` 365, 375, 378, 386, 408, 416, 419, 429, every
one `dm::DataAddr` into `dm::load` / `dm::store` / `dm::float_load` /
`dm::float_store`. **Checked after coding on the same instrument: 8 → 0, with no
new disagreement anywhere and every other cell unchanged.** (The 6 golden-only /
6 ours-only slots are a pre-existing off-by-one in `prince_nibble_red16`'s
operation span, `97:45` vs `97:46`; identical before and after.)

### 4.2 THE NEGATIVE SIDE OF THE LAW, CENSUSED TOO

A fold law must explain the refs golden KEEPS. `argref32.py` classifies every
call argument by what its `vpiActual` names:

```
func_call  ref_obj  logic_var  105     func_call  ref_obj  parameter   23   <== the only cells in reach
func_call  ref_obj  logic_net   53     func_call  ref_obj  <none>      44
func_call  constant <none>      78     sys_func_call ...
```

**All 23** of the ref-kept `parameter` actuals are `prim_cipher_pkg::PRINCE_SBOX4`
/ `PRESENT_PERM64` / … — and that killed my first hypothesis (§5). They are
`parameter logic [15:0][3:0] … = {4'h4, 4'hD, …}` — **PACKED** two-dimensional
arrays with **concat** initialisers, not unpacked arrays.

### 4.3 THE SOURCE-DERIVED CORPUS FENCE (`pred32.sh`), run before the sweeps

Two necessary textual conditions, computed from the corpus SOURCES alone:
**A** a `::`-qualified name inside a call's argument list (the only way to write
the qualified spelling), **B** a wildcard package import (the only way to reach
the bare one).

```
uhdm2rtlil test tree     1886 files   A=11   B=83     -> 69  candidate test dirs
Surelog tests             824 files   A=29   B=104    -> 118 candidate test dirs
Surelog third_party      11776 files  A=542  B=2090   -> 39  candidate test dirs
```

A deliberately loose upper bound — it cannot tell a package parameter from an
enum literal or a type name, and it does not parse. The point is that it is
**falsifiable: every measured byte mover must be inside it.** The one measured
mover, `Earlgrey_0_1`, is in the third-party list (checked by name). 0 of the 69
u2r candidates moved.

---

## 5. WHAT THIS PASS REFUTED — including twice by my own hand

* **My first hypothesis: "an UNPACKED-ARRAY parameter keeps the ref, a scalar
  folds."** It fits `vi.sv` A/B, `aes_sbox_canright`'s `A2X` and every scalar
  cell — and it is **wrong**. §4.2's census shows all 23 ref-kept Earlgrey
  parameters are `logic [15:0][3:0]`, **packed**. a2_type t3 then killed
  dimensionality outright: a two-dimensional packed parameter with a literal init
  **folds**. Had I shipped the type test, t3 and t14-shaped cells would have gone
  the wrong way in both directions.
* **My first predicate, `paramDefRhsIsOp` with its struct/union exception.**
  MEASURED AS A REGRESSION, not reasoned: that exception exists for the
  `inParamInit` INLINING arm further down, and a call argument has no such
  inlining. The first patched build folded
  `build_config_pkg::build_config_func(cva6_config_pkg::cva6_cfg)` into the
  parameter's `op75` pattern tree and **demoted `FuncStructVal` and
  `FuncStructValSimple` from CMP_EQUAL to CMP_NOTEQUAL in BOTH modes**
  (surelog default 467 → **465**, testflags 463 → **461**). Caught by GATE 4 on
  the first sweep, fixed with `aggregateToo`, and re-swept: 467/463 restored,
  0 differing rows. a5_init n13 is now the arm cell that holds it.
* **My own formal-typespec half, built and then REFUSED.** Golden *does* stamp
  the formal's typespec on a folded package-parameter actual (14 measured cells),
  and the exemption that lets `emitCall`'s stamper see it was written and
  measured — and it **OVER-FIRED on two shapes golden leaves bare**: a call
  nested under an OPERATION in a def-view cont-assign (a3 g10, a5 n1/n5–n8) and a
  call in a def-view generate-block process (a3 g4). It was removed before
  landing. **An absent object, never a wrong one** — R1 records it with the
  measured discriminator so the next pass starts from evidence, not from scratch.
* **The brief's reading of the spans** ("the argument text may be wider than the
  bare identifier"). Decoded from the source (§1): the argument is a lone
  12-character scoped identifier; golden spans all of it and we spanned the
  4-character `dm::` qualifier. Nothing is wider than anything.
* **The brief's question (e)** — *does the folded constant ever carry a
  ref_typespec here, and does § psBoundPkgParamTs31's gate fire?* Measured on all
  8 target objects: golden is **bare** on every one, ours is bare on every one,
  and psBoundPkgParamTs31's walk (operations only, must reach a `part_select`)
  cannot leave a `func_call` — proved by the whole-design shape delta in §6,
  which contains **no `ref_typespec` line at all**.
* **earl30 R5** (*"the folded parameter VALUE may already be right; check it
  first"*). Checked first, as instructed: our fold produces `12'h380`, size 12,
  `HEX:380`, `vpiConstType:5` — identical to golden in every field, on all
  8 objects. The value path was never the problem; the object KIND was.

---

## 6. EVERY MOVER ATTRIBUTED, PER SHAPE, BY MULTISET

`mv32.sh` (r10earl31's `mv31.sh`, carried forward unchanged) takes the multiset
delta of dump lines with indentation stripped and looks every distinct changed
shape up in **golden** with a per-shape `grep -Fxc`, ADDED and REMOVED separately,
with a `SELFCHECK=1` fabricated-shape control on **both** directions:

```
== Earlgrey_0_1/default: ADDED instances=41 over 13 shapes; REMOVED instances=33 over 12 shapes
  ADDED   x1 golden=1 ok   \_constant: , line:365:75, endln:365:87
  ADDED   x1 golden=1 ok   \_constant: , line:375:74, endln:375:86
  ADDED   x1 golden=1 ok   \_constant: , line:378:68, endln:378:80
  ADDED   x1 golden=1 ok   \_constant: , line:386:75, endln:386:87
  ADDED   x1 golden=1 ok   \_constant: , line:408:76, endln:408:88
  ADDED   x1 golden=1 ok   \_constant: , line:416:75, endln:416:87
  ADDED   x1 golden=1 ok   \_constant: , line:419:69, endln:419:81
  ADDED   x1 golden=1 ok   \_constant: , line:429:76, endln:429:88
  ADDED   x8 golden=23     ok   |HEX:380                <- bare field line, ABSORBER
  ADDED   x8 golden=17877  ok   |vpiConstType:5         <- bare field line, ABSORBER
  ADDED   x8 golden=19     ok   |vpiDecompile:12'h380   <- bare field line, ABSORBER
  ADDED   x8 golden=1222   ok   |vpiSize:12             <- bare field line, ABSORBER
  ADDED   x1 golden=0 OVER-FIRE   \_FABRICATED_SHAPE_r10earl31   <- the CONTROL, correct
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:365:75, endln:365:79
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:375:74, endln:375:78
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:378:68, endln:378:72
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:386:75, endln:386:79
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:408:76, endln:408:80
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:416:75, endln:416:79
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:419:69, endln:419:73
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (dm::DataAddr), line:429:76, endln:429:80
  REMOVED x8 golden=8 ours_after=8 ok   \_parameter: (dm::DataAddr), line:34:27, endln:34:35
  REMOVED x8 golden=0 ours_after=0 ok   |vpiName:dm::DataAddr
  REMOVED x8 golden=233938 ours_after=222253 UNDER-FIRE |vpiActual:   <- ABSORBER, see below
  REMOVED x1 golden=0 ours_after=0 ok   \_FABRICATED_REMOVED_r10earl31 <- the CONTROL, correct
  ADDED  : 12 covered, 1 OVER-FIRE (the fabricated one)
  REMOVED: 11 correct, 1 UNDER-FIRE (the absorber)
```

**The eight sharp ADDED shapes each have golden count exactly 1, and the eight
sharp REMOVED shapes each have golden count exactly 0.** That is a one-for-one
landing on golden, in both directions, with no other object shape touched.

Two rows are named as what they are rather than allowed to stand as attributions:

* `\_parameter: (dm::DataAddr)` REMOVED ×8 — these are the `vpiActual`
  back-reference **stubs** that vanished with the refs. The real object count is
  unchanged: **golden 8, ours after 8**, printed by the instrument itself.
* `|vpiActual:` REMOVED ×8, flagged UNDER-FIRE — a **bare field line**, whose
  multiplicity once indentation is stripped is a whole-database aggregate and is
  therefore **non-attributable** (the instrument's own caveat). Counted anyway:
  golden 233938, ours **before 222261**, ours **after 222253**. The gap was
  11677 before this pass and 11685 after; the 8 lines removed are exactly the
  ones golden does not have at those eight sites, where golden holds a constant
  with no actual at all.

**Whole-design multiset distance to golden** (`r10uvm55repro/msdist.sh` @7c7eaa6,
md5 `7c0d46b5da124cfe37d27eddc95eb7e7`, run from my worktree's committed copy):

```
BEFORE  golden-only 239070   ours-only 70509   MULTISET DISTANCE 309579
AFTER   golden-only 239036   ours-only 70483   MULTISET DISTANCE 309519   (-60)
dump length 4,654,887 -> 4,654,895 (+8) against golden's 4,823,448
```

The final binary's Earlgrey dump is **byte-identical** to the first patched
build's (`cmp -s` = equal), so the `aggregateToo` correction changed nothing on
this design and every number above is the shipped build's.

---

## 7. RANKED RESIDUES

**R1 — golden stamps the FORMAL'S TYPESPEC on a folded package-parameter actual;
we leave it bare. 14 measured cells, 0 on the target design.** The full
discriminator, measured:

* **stamped**: the call is the direct RHS of a cont-assign (a4 e1/e2/e3/e6/e7,
  bare half e8/e9/e10; a1 c1/c2/c13/c14/c15; `vi.sv` rows C/D) — with the
  `ref_typespec` named after the **enclosing scope** and its `Actual_typespec`
  being **the FORMAL argument's declared type**, not the parameter's;
* **bare**: inside a process (a1 c5/c6/c3/c8, all 8 Earlgrey targets, `vi.sv`
  row F), a call nested under an OPERATION in a def-view cont-assign (a3 g10,
  a5 n1/n5–n8), and a call in a def-view generate-block process (a3 g4);
* **already correct without any change**: inside a subroutine body (a1 c12) —
  `emitCall`'s `currentTf` branch admits constants already.

The exemption (`emitCall`'s `!paramRef`) was built, over-fired on the second and
third bullets, and was removed (§5). Both over-fire shapes have an analogue
already in the file (`ndaOpCallArg9`; `inGenScopeProc`), so this is one arm's work
— but it is a formal-ts law, not a fold law. **It is the highest-value next step
for this position and it needs its own grid.**

**R2 — `Earlgrey_0_1/default`'s NEW head, `flash_ctrl.sv:315`.**

```
LHS(golden)  hier_path (region_cfgs[8].base.q) @315:10-315:21
               vpiParent -> cont_assign @315:10-315:44
               vpiActual -> bit_select (region_cfgs[8]) @315:10-315:21
                 vpiIndex -> constant 8 (UINT, size 32) parented at param_assign @28:18
```

A hier-path/select law on a generate-indexed struct member — a different field
entirely, and the next thing to look at for this design.

**R3 — the VALUE ENCODING of a folded parameter whose init is not a literal.**
a5 n5 `I5 = I2` (golden `8'b00010010`, ours `18`), n6 `I6 = I1[7:0]` (golden
`8'b10000000`, ours `128`), n7 `int'{default:3}` (golden `0`, ours `-1`). The
existing § *based-literal-initialized pkg param keeps its base encoding* rule
only inspects a literal initialiser, so a parameter initialised by another
parameter, by a select or by a default-pattern cast renders decimal where golden
renders the parameter's own encoding. **Pre-existing in the module-side fold
path — this pass only made it visible at a new position** (before, those cells
were `ref_obj` and failed one field earlier). Belongs beside r10earl30's
`vpiConstType` law; touching it here would have crossed that boundary.

**R4 — a cross-package PACKAGE-INIT call argument.** a3 g9: inside
`package c32b`, `localparam int G9 = bfn(c32::P);` — golden folds, we keep the
`paramInitPkg` cross-package `ref_obj` and name it **`c32b::c32::P`** (a doubled
scope). The fall-through reaches that arm before the fold, so this abstains by
construction. One arm cell; the doubled name is worth a look on its own.

**R5 — an ESCAPED-IDENTIFIER read spans differently on the two sides.** a4 e4
(golden `45:18-45:32`, ours `45:18-45:27`) and e10 (`59:18-59:27` vs
`59:18-59:22`). Golden's span for an escaped name overshoots the written text;
this is the same class as r10earl31's R4, now seen on a fold instead of a select.
Invisible to `uhdm-cmp` (no `Compare` reads a span), a real byte residue.

**R6 — value kinds the module-side fold cannot express.** a5 n9 `8'hXZ`
(**unknown bits** — the fold path requires `!cv.integer().hasUnknown()`), n10
`string`, n11 `real`, n12 a packed struct with a **LITERAL** init (caught by the
`ckP == PackedStructType` arm below the fold, which keeps a qualified ref).
Golden folds all four. Each needs its own value-rendering arm; none is reachable
by the gate this pass shipped.

**R7 — `vpiParent` on a `sys_func_call`'s folded argument.** a1 c4 and ~20 cells
in `dm_mem.sv` alone: golden parents such a constant at the call (or at the
package `param_assign`), we leave it unset. Pre-existing, unchanged by this pass,
and `vpiParent` is not a `Compare` field — a byte residue with wide reach.

---

## 8. THE FIVE GATES, each with the number I measured

Binary under test `64602ae6bd08de389cdd5c4911252109`, built at
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl32/build/slang-uhdm`.

### GATE 1 — BUILD

`grep -c "Linking CXX executable slang-uhdm"` = **1** (a build that compiles
nothing still exits 0, so the link line is the check); `grep -icE "error:"` = **0**.
The md5 assertion ran as a **SEPARATE command**, with the baseline validated as
32 hex characters first:

```
baseline length=32
BASELINE=a0ee9da69c335abd511be108d13ebf86
baseline OK 32 hex
--- (separate command) ---
FINAL=64602ae6bd08de389cdd5c4911252109
MD5 CHANGED: PASS
```

The pristine baseline is corroborated rather than asserted: the same build
reproduces **both** committed CSV baselines at **0 differing rows**
(`ct8rows.sh results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv`
against my pristine sweeps), which is what makes GATE 5's byte comparison mean
anything.

### GATE 2 — GOLDENS (pinned; the harness defaults `SLANG_UHDM` to the MAIN TREE)

```
SLANG_UHDM=<my build>  ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false  ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL   50 SLANG_REJECT   2 SURELOG_FAIL
dump       496 match  183 differ  52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv -> 0 differing ROWS (0 diff row-sides)
baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both --jobs 2`

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default   225 match / 242 differ / 327 blank
           testflags 165 match / 298 differ / 331 blank
ct8rows.sh results/golden_surelog.csv -> 0 differing ROWS (0 diff row-sides)
baseline 1589 lines = 1588 ROWS ; fresh 1589 lines = 1588 ROWS
PASS: every row byte-identical to the committed baseline
```

**`Earlgrey_0_1/default` does NOT convert** — `default` stays **467/13**, not
468/12; the row is quoted at the top of this file. `results/*.csv` untouched.

**A FLAKE THAT MUST NOT BE READ AS A GATE RESULT, recorded because it happened:**
an intermediate run with four sweeps in flight at once reported
`AssignBitsCallToSubmoduleParameter` and `AssignSizeOfVar` as `SLANG_REJECT`
(u2r 679 → 677). Both were re-run **in isolation with the same binary** and both
are `CMP_EQUAL`; the serial re-sweep quoted above shows 679/50/2 with 0 differing
rows. Every gate number in this file comes from a **serial** sweep.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine 981f2e3

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 1 / 953
             MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
                   patched=dcc8b974f5a1  pristine=813a083a29dd
             SELFCHECK 952/953 flagged        SELFCHECK1 = 2  (= 1 real + 1 injected)
```

**ONE mover in 1632 databases, and it is the target row** — inside the
source-derived fence of §4.3, attributed per shape against golden by multiset in
§6. `Scoreboard`, the per-run-instability row that has cost several passes a
paragraph, did not move.

### CANARIES

| check | corpus | result |
|---|---|---|
| `r10uvm55repro/ctcan2.sh`, `EXPECT_UNKNOWN=6` (baseline csv FIRST) | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown-patterns=6 → PASS |
| `r10uvm55repro/ctcan2.sh`, `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown-patterns=1 → PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** (named explicitly — several files share that basename) | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 (expected for a u2r csv) |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | ok=52 **changed=0 absent=0** unknown-names=7 (the u2r-only canaries) |
| `r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** → PASS |

BY NAME on the fresh surelog csv, each byte-identical to the committed baseline:

```
InterfaceModPort    default/testflags  CMP_EQUAL/differ
BlackParrotComplex  default/testflags  CMP_EQUAL/differ
FuncStructVal       default/testflags  CMP_EQUAL/differ     <- the regression, restored
FuncStructValSimple default/testflags  CMP_EQUAL/differ     <- the regression, restored
SVSwitch            default/testflags  CMP_NOTEQUAL/
Earlgrey_0_1        default CMP_NOTEQUAL/ ; testflags SLANG_REJECT/reqfifo_rdata.error
```

`UnsignedParam`, `HierPathEval`, `FileLocalParam` and `TopParam` were **not
dispatched by any driver** (asserted by `canaudit.sh`, FENCE-BREACH=0).

### BOUNDARIES

**No collision.**

* **r10earl31** (landed at my base) owns `ref_typespec` attachment on folded
  part-select-bound constants. Its § psBoundPkgParamTs31 walk is operations-only
  and must terminate at a `part_select`; a `func_call` parent stops it dead. The
  proof is in §6: this pass's entire whole-design shape delta contains **no
  `ref_typespec` line at all**, added or removed.
* **r10earl30** owns `vpiConstType` on folded constants. `grep -c VpiConstType`
  over the production half of the patch = **0**.
* **r10svs6** owns fixed-size unpacked-array class properties; **r10uvm60** owns
  macro-continuation constants in `uvm_report_error`. This patch creates no
  class member, no `ref_obj`, and touches no macro machinery; both UVM canaries
  and all 23 goldens are byte-unchanged.
* `scripts/verify_golden.py` and `tests/check_goldens.sh` were **not** modified.
  `GOLDEN_DEFER` unset. No `git stash` was used. `results/*.csv` were read only.

---

## 9. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm32.sh` | one arm's golden + ours + dumps + cmp; prints the binary's md5, existence-checks all four tools, `sed 1d` on both dumps, missing database fatal, own scratch dir. r10earl31's driver, carried forward |
| `census32.py` | **THE POLICY CENSUS** — every call argument by (call kind × object kind), both sides, then joined argument-for-argument on the START span; `--disagree`, `--gonly`, `--selfcheck` |
| `cells32.py` | **THE PER-CELL TABLE** — kind, span, decompile, `vpiParent`, `vpiTypespec` → actual, every cell of every arm, golden always argv[1]; `--selfcheck` |
| `argref32.py` | what golden's KEPT call-argument refs actually bind to — the law's negative side, censused |
| `pred32.sh` | **the SOURCE-DERIVED mover fence**, computed from corpus sources before the sweeps were read |
| `mv32.sh` | per-shape mover attribution against golden by multiset, ADDED/REMOVED separately, fabricated-shape controls in both directions, bare field lines named as non-attributable (r10earl31's `mv31.sh`) |
| `a1_kind.sv` | CALL KIND × spelling × container — 15 cells: package fn, module fn, TASK, sys-func, nested call, static class method, operation/ternary args, function body, import 2×2, never-instantiated module |
| `a2_type.sv` | **THE DISCRIMINATOR ARM** — 16 parameter types/inits in one position, with t3/t2 built to separate "type" from "initialiser" |
| `a3_ctx.sv` | **THE NO-FOLD CONTAINERS** — def-view gen process (bare AND qualified), nested gen scope, package inits (own and cross), param defaults, port connection, twice-instantiated module |
| `a4_text.sv` | **THE TEXT-TEST ARM** — macro-written qualified and bare reads, escaped identifiers, wider/`int` formals; records the escaped-PACKAGE-name cell as unmeasurable |
| `a5_init.sv` | the predicate's edges — replication, cast-of-concat, param-of-param, select, `int'{default:}`, function-call init, unknown bits, string, real, struct literal vs pattern |

Reused unchanged: `r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`,
`r10oth8repro/ct8rows.sh`, `r10earl_repro/vi.sv` (pass 11's own file, which
carried the refutation all along).
