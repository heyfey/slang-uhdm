# r10earl33 — § genCaArgPkgParamValueFolds33 + § genScopeBareArgKeepsRef33 + § argWrittenQualIsSyntaxKind33

**THE HEADLINE, FIRST.** The pass was given r10earl32's residue **F4** — "an
ELABORATED generate block does not fold, and golden does". Measured with a
**view-keyed** reader, F4's own description is **REFUTED**: the two cells it
names are in the module's **DEF LISTING**, not in the elaborated instances, and
the elaborated instances of the very same statement carried the **opposite**
defect — a *wrong* object r10earl32 introduced and its instrument could not
print. Both are fixed here. `Earlgrey_0_1/default` does **not** convert; its
row is byte-identical to the committed baseline and `results/*.csv` were not
edited.

---

## 0. THE LAWS

> **§ genCaArgPkgParamValueFolds33 — inside a DEF-VIEW GENERATE-BLOCK
> CONT-ASSIGN, a `pkg::P` subroutine-call argument that resolves to a PACKAGE
> PARAMETER is emitted by the ORDINARY BOUND-EXPRESSION emitter, so
> § fcArgPkgParamValueFolds32 and its § fcArgBareImportRef carve-out answer it —
> instead of the syntax path's own unconditional `ref_obj`.**

> **§ genScopeBareArgKeepsRef33 — a BARE (wildcard-imported) package-parameter
> call argument inside an ELABORATED GENERATE SCOPE keeps its gen-scoped ref.
> The gate is the GENERATE SCOPE and the MISSING QUALIFIER — the same pair
> § defGenProcWildcardPkgParamNoFold19 and § genNestedScopePkgParamNoFold24
> already turn on, in their third container.**

> **§ argWrittenQualIsSyntaxKind33 — "written qualified" is a SYNTAX KIND
> (`ScopedName` vs `IdentifierName`), not `rawText(...).find("::")`.**

| # | call site | what it does |
|---|---|---|
| 1 | `src/TypeEmit.cpp` ~12453 (`emitSyntaxExpr`, `case ScopedName`, the `parts.size() < 2 && raw.find("::")` branch) | § genCaArgPkgParamValueFolds33 — three-part gate, then `emitExpr` with the call as parent; returns whatever that returns |
| 2 | `src/ExprEmit.cpp` ~4620 (`emitExpr`, the `scope is a Package && symbol is a Parameter` block) | § argWrittenQualIsSyntaxKind33 (`fcArgQual33`) + § genScopeBareArgKeepsRef33 (`genScopeBareArg33`), which subtracts from `fcArgFold32` |
| 3 | `src/ExprEmit.cpp` ~4700 (§ fcArgBareImportRef's bare/qualified split) | the text test replaced by `fcArgQual33`, so the split and the arm that routes to it read the SAME predicate |

`git diff --stat a060719 -- src include` = **2 files, 175 insertions, 3
deletions** (comments included).

### STATED GATE == CODE GATE

`src/TypeEmit.cpp`, read verbatim:

```cpp
if (inDefGenCaExpr && parent &&
    (parent->UhdmType() == UHDM::uhdmfunc_call ||
     parent->UhdmType() == UHDM::uhdmtask_call)) {
    if (const ParameterSymbol* fp33 = crossPkgBoundParam9(raw)) {
        const Scope& fs33 = currentScope ? *currentScope
                                         : (const Scope&)comp.getRoot();
        ASTContext fx33(fs33, LookupLocation::max);
        auto& fe33 = Expression::bind(syn.as<syntax::ExpressionSyntax>(), fx33);
        if (!fe33.bad()) {
            auto& fs0 = stripImplicitConv(fe33);
            if (fs0.kind == ExpressionKind::NamedValue &&
                &fs0.as<NamedValueExpression>().symbol == (const Symbol*)fp33) {
                NetMap fnm33;
                if (auto* fo33 = emitExpr(fs0, parent, syntaxRefPrefix, fnm33))
                    return fo33;
            }
        }
    }
}
```

Three things and no more: (1) the def-view generate cont-assign context;
(2) the **direct** parent is a call — nothing walks; (3) the written text and
the AST bind must name **the same symbol** — a text match alone can never fold
a local shadow. **No view test beyond the flag, no import test, and the only
text reading is `crossPkgBoundParam9`'s own tokenizer.**

`src/ExprEmit.cpp`, read verbatim:

```cpp
const bool fcArgQual33 =
    expr.syntax ? expr.syntax->kind == syntax::SyntaxKind::ScopedName
                : rawText(expr.sourceRange).find("::") != std::string::npos;
const bool genScopeBareArg33 =
    fcArgPos32 && !fcArgQual33 && (inGenScopeCaRhs || inGenScopeProc);
const bool fcArgFold32 =
    fcArgPos32 && !genScopeBareArg33 &&
    !patParamNoFold(nv.symbol.as<ParameterSymbol>()) &&
    !paramDefRhsIsOp(nv.symbol.as<ParameterSymbol>(), /*aggregateToo=*/true);
```

The `expr.syntax`-less fallback is the OLD text answer on purpose: a re-emitted
clone with no syntax node keeps its previous reading, so no existing cell can
move on a null.

---

## 1. LOCALIZATION — F4 IS A DEF-VIEW DEFECT, AND ITS OWN ARM CARRIED THE
## OPPOSITE ONE

r10earl32's `cells32.py` keys a row on the argument's start span and **drops
every later row with the same key**. A generate body is emitted **twice** — once
in `uhdmallModules` (the module's DEF listing) and once per elaborated
`gen_scope` under `uhdmtopModules` — so that reader prints the DEF row and
**hides every elaborated one**. `cells33.py` carries the view in the key; its
`--selfcheck` is exactly that assertion and it RUNS:

```
$ python3 cells33.py --selfcheck
SELFCHECK rows=2 views=['uhdmallModules', 'uhdmtopModules'] kinds=['constant', 'ref_obj']
SELFCHECK: PASS (the SAME argument span in the DEF listing and in the ELABORATED
                 instance must stay TWO rows — cells32.py collapses them and
                 hides exactly this pass's defect; the vpiParent back-reference
                 stub must not be read as a second call or a second argument;
                 the ref_typespec under |vpiTypespec: must be found and its own
                 |vpiActual: read one level deeper)
```

Re-reading r10earl32's own `v4_more.sv` with it, at `a060719`:

```
arg@   view        GOLDEN                                  OURS
30:19  allModules  constant 12'h380 p=func_call            ref_obj p4::P     <== F4, DEF view
30:19  topModules  constant 12'h380 (+ formal ts)          constant 12'h380  <- already folded
30:31  allModules  ref_obj work@m4gen.gblk.P               ref_obj (same)    <- correct
30:31  topModules  ref_obj work@m4top.ug.gblk[0].P         constant 12'h380  <== NEW: WRONG OBJECT
```

**Two facts F4 states are wrong.** It is not the elaborated body that fails to
fold — the elaborated body already folds. And "the bare sibling at 30:31 stays a
ref on BOTH sides" is true only in the def listing; in the elaborated instances
we emit a `constant` where golden has a gen-scoped `ref_obj`.

**The def-view defect's mechanism.** A def-view generate-block cont-assign is
emitted from **SYNTAX** (`src/ModuleEmit.cpp` ~25932 sets `inDefGenCaExpr` and
calls `emitSyntaxExpr`), not from the bound AST. § fcArgPkgParamValueFolds32
lives in `emitExpr` and therefore never ran on one; every `pkg::P` call argument
in a generate body fell to `emitSyntaxExpr`'s unconditional `ref_obj`. That is
also why the containers r10earl32 measured (`a3_ctx` g3/g4/g5, all **processes**)
looked right: a def-view gen **process** goes through `emitProcess`/`emitExpr`,
a completely different path.

**The elab-view defect's mechanism, and that it is a REGRESSION — measured, not
reasoned.** Before r10earl32 the carve-out returned for *every* package
parameter in a call-argument position; the fall-through it introduced folds the
bare one. Run on a **pre-r10earl32 binary** (`266d3a6`, worktree `r10svs3pris`,
md5 printed by the driver) and on `a060719`, `a3_ctx.sv` cell g3's elaborated
twin:

```
                     46:18 topModules (elab gen process, BARE read)
golden               ref_obj (work@c32top.ua.gblk.P) 46:18-46:19
266d3a6 (pre-32)     ref_obj (work@c32top.ua.gblk.P) 46:18-46:19     = golden
a060719 (post-32)    constant 12'h380 p=param_assign + a ref_typespec  WRONG
```

---

## 2. THE GRID, CELL FOR CELL

Driver `arm33.sh` (r10earl32's `arm32.sh`, carried forward verbatim: LHS always
golden, `sed 1d` both dumps, binary md5 printed on every run, missing database
fatal, own scratch dir). Reader `cells33.py` (§1). Fence `pred33.sh` (§4).
Mover attribution `mv33.sh` (r10earl32's `mv32.sh`, unchanged).

### 2.0 THE ONE-LINE RESULT

| arm | cells | cell-diffs BEFORE | cell-diffs AFTER | what is left |
|---|---|---|---|---|
| `b1_gen` (the container axis) | 42 | 31 | **20** | R1 ts ×7, R2 port-actual, R3 elab-absent ×6, R5 escaped span ×4, R6 $clog2 ×2 |
| `b2_init` (the parameter axis) | 28 | 28 | **14** | R4 unfoldable kinds ×3(+6 elab), R7 untyped width, R3 elab-absent ×4 |
| `b3_text` (the text axis) | 10 | 8 | **5** | R5 escaped ×2, R8 cross-pkg init, R3 elab-absent ×2 |
| `v4_more` (r10earl32's F4 arm, adopted) | 15 | 13 | **9** | R1 ts ×3, r10earl32 R3 value encoding ×6 |
| `a3_ctx` (r10earl32's container arm, adopted) | 16 | 7 | **1** | R8 cross-package package-init only |

`a3_ctx` going 7 → 1 is the sharpest number in the pass: **every** container law
r10earl32 built that arm to protect still wins, and the elaborated over-fire it
did not know it had is gone.

### 2.1 b1_gen — THE CONTAINER AXIS

Parameter (`logic [11:0] P = 12'h380`), call and spelling held; only the
container moves.

| cell | container | golden | ours BEFORE | ours AFTER |
|---|---|---|---|---|
| k1 41:19 | **for-generate CA, qualified** (def view) — the F4 head | constant `12'h380` | ref_obj `p33::P` | **exact** |
| k2 49:19 | if-generate CA, qualified | constant | ref | **exact** |
| k3 56:19 / 59:19 | **both arms** of an if/else-generate (the untaken one too) | constant `12'h123` | ref ×2 | **exact ×2** |
| k5 41:32 | the **BARE** sibling in the same statement, DEF view | ref `work@k33.gfor.P` | ref ✓ | ref ✓ |
| k5' 41:32 | the same read, **ELABORATED** ×2 | ref `work@k33top.u1.gfor[i].P` | **constant — WRONG** | **exact ×2** |
| k6 77:20 | the argument is an **OPERATION** over the parameter | operation | operation ✓ | operation ✓ |
| k7 78:23 | the inner argument of a **NESTED** call | constant | ref | **exact** |
| k8 79:26 | a **QUALIFIED PACKAGE** call's argument (`p33::pfn(p33::P)`) | constant | ref | **exact** |
| k9 88:23 | `$clog2` — `sys_func_call` | constant, already equal | equal | unchanged |
| k9' 88:37 | an **`int`** parameter into a module function | constant `7` | ref | **exact** |
| k10 95:25 | an **INSTANCE PORT ACTUAL** that is a call, inside the generate block | constant | ref `…u_s.i_i.p33::P` | ref — **R2, not shipped** |
| k11 104:15 | **BARE** in a def-view gen **PROCESS** (§ 19) | ref | ref ✓ | ref ✓ |
| k11' 104:15 | the same read **ELABORATED** | ref | **constant + ts — WRONG** | **exact** |
| k12 105:15 | **QUALIFIED** in the SAME process | constant | constant ✓ | constant ✓ |
| k13 116:17 | BARE in a **NESTED** gen scope (§ 24) ×2 | ref | ref ✓ | ref ✓ |
| k14 117:17 | QUALIFIED in the same nested scope ×2 | constant | constant ✓ | constant ✓ |
| k15 149:19 | a for-generate CA in a module that is **NEVER INSTANTIATED** | constant | ref | **exact** |
| k16 160:17 | **THE NEGATIVE CONTROL** — the same call OUTSIDE any generate | constant (+ formal ts) | constant | unchanged (R1 only) |
| k17 132:20 | a **BARE ESCAPED** name **containing `::`** (`\x::y `), elab gen CA | ref `…gesc.x::y` | ref, span short | ref, span short (R5) |
| k18 133:25 | the same in a gen **PROCESS**, elaborated ×2 | ref `…gesc[i].x::y` | **constant — WRONG** | **ref, span short (R5)** |

k11/k12 and k13/k14 are the two pairs the brief required to survive: the **same
process**, the **same parameter**, one bare and one qualified, golden answering
differently — reproduced before and after, in **both** views.

k17/k18 are why § argWrittenQualIsSyntaxKind33 exists. `\x::y ` is ONE
identifier whose NAME contains `::`. Under `rawText(...).find("::")` both read
QUALIFIED; under the syntax kind both read BARE, which is what they are. Had the
gen-scope arm been written with the text test, k18 would have moved from one
wrong object (a folded constant) to a **different** wrong object (a
qualifier-spanned, package-bound ref). It moves to golden's KIND and NAME
instead, with only the escaped-span residue R5 left.

### 2.2 b2_init — THE PARAMETER AXIS, HELD AT THE NEW POSITION

The def-view generate cont-assign is a syntax path, so the discriminator had to
be re-measured there rather than inherited. It is **the same one**, cell for
cell (`allModules` view):

| cell | initialiser | golden | AFTER |
|---|---|---|---|
| N1 literal `12'h380` | | **FOLDS** | **exact** |
| N2 `{4'h1,4'h2}` CONCAT | | **ref, spanning `q33::`** | **exact — kind AND span** |
| N3 `{2{4'h3}}` REPLICATION | | ref | **exact** |
| N4 `8'({…})` CAST of a concat | | ref | **exact** |
| N5 `8'h1 + 8'h2` ARITHMETIC | | FOLDS | **exact** |
| N6 `logic [1:0][3:0] = 8'hAB` MULTI-dim literal | | FOLDS | **exact** |
| N7 multi-dim PATTERN | | ref | **exact** |
| N8 UNPACKED array pattern | | ref | **exact** |
| N9 `int` / N10 UNTYPED / N11 72-bit / N12 typedef'd / N13 enum / N18 signed | | FOLDS | **exact** (N10 width = R7) |
| N14 packed struct, PATTERN — the FuncStructVal cell | | **ref** | **exact** |
| N15 `8'hXZ` unknown / N16 `string` / N17 `real` | | FOLDS | **ref — R4, abstains** |

The kept refs are not merely kept: golden spans them at the `q33::`
**QUALIFIER** (`52:21-52:26`) where the syntax path's own `ref_obj` spanned the
whole `q33::N2` (`52:21-52:28`). Delegating to `emitExpr` gets the carve-out's
span too, so **six ref cells were fixed by a fold law that never folds them**.

### 2.3 b3_text — THE MANDATORY TEXT ARM

| cell | spelling | golden | AFTER |
|---|---|---|---|
| e1 35:20 | `mf(p33b::P)` written out | constant `12'h380` | **exact** |
| e2 36:20 | the SAME read **MACRO-written** (`mf(\`QP)`) | constant | **exact** |
| e3 37:20 | the **WHOLE CALL** macro-written | constant | **exact** |
| e4 38:20 | **ESCAPED** parameter name (`p33b::\e@x `) | constant | ref — **R5, abstains** |
| e5 39:20 | escaped name **CONTAINING `::`** (`p33b::\a::b `) | constant | ref — **R5, abstains** |
| e6 40:20 | **BARE** after a wildcard import, def view | ref | ref ✓ |
| s1 23:27 | a package localparam init calling its **OWN** package's param | ref | ref ✓ |
| s2 25:27 | the same on **ANOTHER** package's, qualified | constant | ref — **R8, unchanged** |

e2/e3 are the cells that had to exist: `rawTextExp` hands back the
**expansion**, so a macro-written `pkg::P` resolves and folds exactly like the
written one. e4/e5 **abstain** — `crossPkgBoundParam9` rejects a residual `::`
in the member half and slang stores an escaped name without its leading
backslash, so neither resolves. **An ABSENT object where golden folds, never a
WRONG one** — which is the direction r10earl32's F1 got backwards.

s1/s2 are the same-package / cross-package package-init abstentions the brief
required to stay: both are byte-unchanged.

---

## 3. WHAT THIS PASS REFUTED

* **F4's own statement: "an ELABORATED generate block does not fold".** The
  elaborated instances of the very cell it names (`v4_more.sv` 30:19) **already
  folded** at `a060719`; the failing view is the module's **DEF LISTING**. The
  reading came from an instrument that collapses the two views onto one row.
* **F4's control: "the BARE sibling at 30:31 stays a ref on BOTH sides".** True
  in the def listing, **false** in the elaborated instances, where we emitted a
  `constant` and golden a gen-scoped `ref_obj`. That is a REGRESSION
  r10earl32 shipped, proved by re-running its own arm on a pre-r10earl32 binary
  (§1) — not inferred from the diff.
* **My own first cut of the gen-scope arm, refused before it was written.**
  Spelling it with `rawText(...).find("::")` — the way every neighbouring arm
  spells it — would have routed a bare escaped `\x::y ` into the carve-out's
  QUALIFIED branch, replacing one wrong object with another. b1 k17/k18 are the
  cells; § argWrittenQualIsSyntaxKind33 is the answer.
* **"Re-implement the fold in the syntax path."** Rejected: it would fork
  § fcArgPkgParamValueFolds32's predicate. Delegating to `emitExpr` instead is
  what makes b2_init's six **non**-folding cells land on golden's span as well,
  which a second fold implementation would not have done.
* **The brief's item 2 — "if item 1's fold law reaches into this cont_assign's
  call args".** Measured: it does not. See §6.

---

## 4. THE SOURCE-DERIVED CORPUS FENCE (`pred33.sh`), run before the sweeps

`§ genCaArgPkgParamValueFolds33` can only fire where three things coexist in one
file: **A** a `::`-qualified name inside a call's argument list (the gate is in
the ScopedName arm, so the bare spelling cannot reach it at all — which is why
pred32.sh's wildcard-import condition B is printed here only for comparison),
**C** a generate construct, **D** a continuous assign.

```
u2r      files=1886   A=11   B=83    C=137   D=1405   A&C&D=0     -> 0 candidate dirs
sltests  files=824    A=29   B=104   C=143   D=254    A&C&D=7     -> 7 candidate dirs
sl3rd    files=11776  A=542  B=2090  C=3234  D=5156   A&C&D=225   -> 11 candidate dirs
```

**A&C&D = 0 for the whole uhdm2rtlil corpus: this pass predicts ZERO u2r
movers, from the sources, before a sweep was read.** The surelog candidates are
`ArianeElab ArianeElab2 BitsOp ForElab FuncStructVal FuncStructValSimple
ParamOverload3` and `ariane Ariane2024 AzadiRTL black-parrot Earlgrey_0_1
Earlgrey_nexysvideo Earlgrey_Verilator_0_1 Earlgrey_Verilator_01_05_21 Ibex
IncompTitan Opentitan`. **FALSIFIER: every measured byte mover must be in that
list.**

---

## 5. EVERY MOVER ATTRIBUTED, PER SHAPE, BY MULTISET

**ONE database moved in 1632, and it is the target.** `mv33.sh` (r10earl32's
`mv32.sh`, unchanged) takes the multiset delta of dump lines with indentation
stripped and looks every distinct changed shape up in **golden** with a
per-shape `grep -Fxc`, ADDED and REMOVED separately, with a fabricated-shape
control in **both** directions:

```
== Earlgrey_0_1/default: ADDED instances=9 over 9 shapes; REMOVED instances=9 over 9 shapes
  ADDED   x1 golden=1  ok   \_ref_obj: (prim_cipher_pkg::PRESENT_PERM32_INV), line:68:62, endln:68:79
  ADDED   x1 golden=1  ok   \_ref_obj: (prim_cipher_pkg::PRESENT_PERM32),     line:103:62, endln:103:79
  ADDED   x1 golden=1  ok   \_ref_obj: (prim_cipher_pkg::PRESENT_PERM64_INV), line:62:62, endln:62:79
  ADDED   x1 golden=32 ok   \_ref_obj: (prim_cipher_pkg::PRESENT_PERM64),     line:97:62, endln:97:79
  ADDED   x1 golden=1  ok   \_ref_obj: (prim_cipher_pkg::PRESENT_SBOX4_INV),  line:64:63, endln:64:80
  ADDED   x1 golden=1  ok   \_ref_obj: (prim_cipher_pkg::PRESENT_SBOX4_INV),  line:70:63, endln:70:80
  ADDED   x1 golden=1  ok   \_ref_obj: (prim_cipher_pkg::PRESENT_SBOX4),      line:101:63, endln:101:80
  ADDED   x1 golden=32 ok   \_ref_obj: (prim_cipher_pkg::PRESENT_SBOX4),      line:95:63, endln:95:80
  ADDED   x1 golden=0 OVER-FIRE   \_FABRICATED_SHAPE_r10earl31        <- the CONTROL, correct
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_PERM32_INV), line:68:62, endln:68:97
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_PERM32),     line:103:62, endln:103:93
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_PERM64_INV), line:62:62, endln:62:97
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_PERM64),     line:97:62, endln:97:93
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_SBOX4_INV),  line:64:63, endln:64:97
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_SBOX4_INV),  line:70:63, endln:70:97
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_SBOX4),      line:101:63, endln:101:93
  REMOVED x1 golden=0 ours_after=0 ok   \_ref_obj: (…PRESENT_SBOX4),      line:95:63, endln:95:93
  REMOVED x1 golden=0 ours_after=0 ok   \_FABRICATED_REMOVED_r10earl31   <- the CONTROL, correct
  ADDED  : 8 covered, 1 OVER-FIRE (the fabricated one)
  REMOVED: 8 correct + the control, 0 UNDER-FIRE
```

**Eight sharp ADDED shapes, every one present in golden at that exact span;
eight sharp REMOVED shapes, every one with golden count 0 AND ours-after 0.**
A one-for-one landing on golden in both directions, with **no bare field line in
the delta at all** — this pass changed no `|vpi…` line, so the instrument's
non-attributable class is empty here and every mover is a real object.

**AND THE MOVERS ARE NOT FOLDS.** All eight are `prim_present.sv` — the
`if (Decrypt) begin : gen_dec / if (DataWidth == 64) begin : gen_d64` def-view
generate cont-assigns:

```
prim_present.sv:62  assign data_state_sbox = prim_cipher_pkg::perm_64bit(data_state_xor,
                                                    prim_cipher_pkg::PRESENT_PERM64_INV);
```

`PRESENT_PERM64_INV` is a **concat-initialised packed array**, so
§ fcArgPkgParamValueFolds32 **refuses** to fold it and the delegation lands on
its § fcArgBareImportRef carve-out instead: the span goes from the whole
reference (`68:62-68:97`) to the **`prim_cipher_pkg::` qualifier**
(`68:62-68:79`), which is golden's. This is b2_init's N2/N3/N4/N7/N8/N14 cell
class on the real design, and it is why "delegate, don't re-implement" was the
right shape for the fix: a second fold implementation would have moved nothing
here.

Whole-design multiset distance to golden (`r10uvm55repro/msdist.sh` @a060719,
md5 `7c0d46b5da124cfe37d27eddc95eb7e7`):

```
BEFORE  golden-only 239036   ours-only 70483   MULTISET DISTANCE 309519
AFTER   golden-only 239030   ours-only 70477   MULTISET DISTANCE 309507   (-12)
dump length 4,654,895 -> 4,654,895 (UNCHANGED) against golden's 4,823,448
```

The dump length is unchanged because every mover is a **span edit on an existing
object**, not an added or removed one.

---

## 6. THE ROW HEAD — `Earlgrey_0_1/default` DOES NOT CONVERT, AND THE HEAD IS A DIFFERENT FAMILY

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- fresh (patched)
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,        <- results/golden_surelog.csv
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,   (both, unchanged)
```

`default` stays **467/13**, not 468/12. `results/*.csv` were **read only**.

**The head is UNMOVED and the two `uhdm-cmp` logs are BYTE-IDENTICAL** (1 head,
154 lines, pristine and patched):

```
$ cmp -s cmp_pristine.log cmp_patched.log  ->  IDENTICAL
```

**Censused BOTH SIDES, span-keyed, before claiming what** (`flash_ctrl.sv:315`,
`assign region_cfgs[MpRegions].base.q = '0;`, `localparam int MpRegions = 8`):

| field | GOLDEN | OURS |
|---|---|---|
| object | `hier_path` **`(region_cfgs[8].base.q)`** @315:10-315:21 | `hier_path` **`(region_cfgs[MpRegions].base.q)`** @315:10-315:21 |
| `vpiParent` | `cont_assign` @315:10-315:44 | **same** |
| element 1 | `bit_select (region_cfgs[8])` @315:10-315:21 | `bit_select (region_cfgs[MpRegions])` @315:10-315:21 |
| its index | `constant` 8, size 32, `UINT:8`, ct 9 @315:22-315:31 | **same value, same span** |
| the index's `vpiParent` | `param_assign` @28:18-28:37 | `bit_select` |
| the index's ts ref | `ref_typespec(work@flash_ctrl)` | `ref_typespec(region_cfgs[MpRegions]) -> int_typespec @28:14-28:17` |
| elements 2/3 | `ref_obj (region_cfgs[8].base)` / `…base.q)` | `…[MpRegions].base` / `.base.q` |

**Everything structural agrees.** The head is the **DISPLAY NAME**: Surelog
re-lexes a `hier_path`'s name off its **REDUCED** expression tree, so a
parameter index appears as its VALUE (`[8]`), and we re-lex ours off the
**WRITTEN** text (`[MpRegions]`). It is the same re-lex family as
§ hpSelParenStrip / § hpPartSelWsCompact (parentheses vanish, `+:` compacts) —
one more thing that tree does not carry, namely the identifier.

Whole-design census of the family, both sides:

```
hier_path names spelled `region_cfgs[MpRegions]…`   golden 0    ours 48
hier_path names spelled `region_cfgs[8]…`           golden 36   ours 0
distinct hier_path names carrying an IDENTIFIER index, whole design
                                                    golden 172  ours 176
```

**This is a hier-path NAMING law, not a fold law**, and item 1's law provably
does not reach it: the cont_assign at 315 has **no call in it at all**, and the
two cmp logs are byte-identical. As the brief instructed, it is
**characterised and reported, not forked into this pass.** It is R9 below, and
golden's 172-to-our-176 gap says the fix is nearly a whole-family one: 36 of our
48 wrong names on this design are `region_cfgs`, and the rule to test first is
"an index that REDUCES to a constant is displayed as that constant".

---

## 7. THE FIVE GATES, each with the number I measured

Binary under test **`899b52d9ca7ce8b9fb74f4040344201b`** at
`/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl33/build/slang-uhdm`;
worktree BASE `a060719294b588fdfc85918775a5ad49603dd569`, printed and checked.

### GATE 1 — BUILD

```
grep -c "Linking CXX executable slang-uhdm"  = 1     (a build that compiles nothing still exits 0)
grep -icE "error:"                            = 0
```

The md5 assertion ran as a **SEPARATE command**, baseline validated as 32 hex
first:

```
baseline length=32
BASELINE=365219cb664f4498d52c9aa68f605ba7
baseline OK 32 hex
--- (separate command) ---
FINAL=899b52d9ca7ce8b9fb74f4040344201b
MD5 CHANGED: PASS
BASE_r10earl33 = a060719…   BASE_r10earl33pris = a060719…
```

The pristine baseline is **corroborated, not asserted**, three ways: it is my
own build of `a060719` in my own worktree; its md5 is **identical** to the main
tree's independently produced build of the same commit; and it reproduces **both**
committed CSVs at **0 differing rows** (`ct8rows.sh`, §GATE 3/4 numbers below run
on it first). That is what makes GATE 5's byte comparison mean anything.

### GATE 2 — GOLDENS (pinned; the harness defaults `SLANG_UHDM` to the MAIN TREE)

```
SLANG_UHDM=<my build>  ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false  ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
GOLDEN_DEFER=[<unset>]
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

Both dump histograms are unchanged in every bucket; `Earlgrey_0_1/default` moved
**bytes** (GATE 5) without moving its row, which is exactly what the brief
predicted for it.

### GATE 5 — BYTE VERIFIER, both corpora, vs my own pristine `a060719`

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 1 / 953
             MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm
                   patched=fb053a2d299b  pristine=dcc8b974f5a1
             SELFCHECK 952/953 flagged        SELFCHECK1 = 2  (= 1 real + 1 injected)
```

**The prediction came from the SOURCES first and it held exactly.** §4's fence
computed `A&C&D = 0` for the whole uhdm2rtlil corpus **before any patched sweep
was read**, and uhdm2rtlil moved **0 of 679**. The one surelog mover,
`Earlgrey_0_1`, is inside the surelog candidate list (checked by name), and its
eight moved objects are in `prim_present.sv`, a file that carries A, C and D.
`Scoreboard`, the bistable row, did not move; its rows are byte-identical in both
CSVs.

### CANARIES

| check | corpus | result |
|---|---|---|
| `r10uvm55repro/ctcan2.sh`, `EXPECT_UNKNOWN=6` (baseline csv FIRST) | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown-patterns=6 → PASS |
| `r10uvm55repro/ctcan2.sh`, `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown-patterns=1 → PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** (named explicitly — several files share that basename) | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 (expected for a u2r csv) |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | ok=52 **changed=0 absent=0** unknown-names=7 (the u2r-only canaries) |
| `r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** → PASS |

BY NAME on the fresh surelog CSV, `diff`ed against the committed baseline and
**byte-identical**: `InterfaceModPort`, `BlackParrotComplex`, `FuncStructVal`,
`FuncStructValSimple`, `SVSwitch`, `Earlgrey_0_1`, plus every surelog test named
in §4's candidate list that produces a row (`ArianeElab`, `ForElab`, `BitsOp`,
`ParamOverload3`, `Ibex`). `UnsignedParam`, `HierPathEval`, `FileLocalParam` and
`TopParam` were **not dispatched by any driver** (`canaudit.sh`,
FENCE-BREACH=0).

### BOUNDARIES

**One collision, and it is reported rather than absorbed.**

* **§ fcArgPkgParamValueFolds32 (6498102)** owns the fold, its
  concat/replication/pattern abstention and § fcArgFoldParent32's parenting.
  This pass adds **no** fold: site 1 delegates to that arm and site 2 *subtracts*
  from its gate. Its predicate (`patParamNoFold`, `paramDefRhsIsOp` with
  `aggregateToo`) is **not edited** — b2_init measures all 18 of its shapes at
  the new position and every reducing/non-reducing answer is unchanged.
  **THE COLLISION**: § genScopeBareArgKeepsRef33 repairs a REGRESSION that pass
  shipped (§1, §3), so it does change one of that law's own cells — by
  restoring the answer the code gave **before** it. The proof is a measurement
  on a pre-r10earl32 binary, not an argument.
* **§ tfBodyConstArgNeedsEvaldBody60 (8633a1e)** owns evaluated-body membership.
  Neither site touches a subroutine body: `grep -c constArgBodyEvald60` over the
  production half of this patch = **0**.
* **§ defGenProcWildcardPkgParamNoFold19** and
  **§ genNestedScopePkgParamNoFold24** keep their containers: b1 k11 (104:15)
  and k13 (116:17) are refs before and after, and both arms return **above** the
  gate this pass edits. Their own F1 exposure is R6 below, **not taken**.
* **r10earl31 / r10earl30** own `ref_typespec` attachment and `vpiConstType` on
  folded constants: the whole Earlgrey shape delta (§5) contains **no
  `ref_typespec` line and no `vpiConstType` line at all**, added or removed.
* **Live passes r10uvm61 (`$bits` folds) and r10svs8 (covergroup sample)**: this
  patch creates no `sys_func_call`, no covergroup and no class member; all 23
  goldens and both UVM canary sets are byte-unchanged.
* `scripts/verify_golden.py` and `tests/check_goldens.sh` were **not** modified;
  `GOLDEN_DEFER` unset; no `git stash`; `results/*.csv` read only.

---

## 8. RANKED RESIDUES

**R1 — golden stamps the FORMAL'S TYPESPEC on a folded package-parameter
actual; we leave it bare.** r10earl32's R1, carried forward unchanged, and this
pass makes it visible at seven more cells (b1 41:19 elab ×2, 78:20/78:23 elab,
95:25 elab ×2, 160:17; v4 30:19 elab ×2, 46:18). Still the highest-value next
step for this position, still needs its own grid. **0 cells on the target
design.**

**R2 — the def-view gen-block INSTANCE PORT ACTUAL.** b1 k10 (95:25):
`k33sub u_s (.i_i(id(p33::P)))` inside a generate block. Golden folds; we keep
`ref_obj (work@k33.gport.u_s.i_i.p33::P)`. It is the SAME law one container
over — the gen-block port-actual dispatcher emits from syntax too but does not
set `inDefGenCaExpr`. **Deliberately not taken**: that flag has a second
consumer (`src/TypeEmit.cpp` ~11073) and widening it needs its own arm. One
cell measured, cheapest next step in this family.

**R3 — objects ABSENT from our ELABORATED gen scopes.** Nine cells: a NESTED
call and its argument (b1 78:20/78:23), a `>64`-bit and a struct argument
(b2 61:21, 64:21), a string and a real (b2 66:21, 67:21), a bare read (b3
40:20) — golden has them in each `gen_scope`, we emit nothing. Pre-existing,
identical before and after, and a different family (whole-call constant folding
in an elaborated gen scope: b1 k4's nested-gen cell shows golden collapsing
`mf(p33::P)` to one `BIN`-encoded constant where we render `UINT`).

**R4 — value kinds the module-side fold cannot express.** b2 N15 `8'hXZ`
(unknown bits — the fold requires `!hasUnknown()`), N16 `string`, N17 `real`:
golden folds all three at the def-view gen-CA position, we **abstain** and keep
the carve-out ref. r10earl32's R6, reached at a new position. Each needs its own
value-rendering arm.

**R5 — ESCAPED IDENTIFIERS, two distinct defects in one class.**
(a) `crossPkgBoundParam9` cannot resolve `pkg::\e@x ` (slang stores the name
without the backslash) or `pkg::\a::b ` (its second-`::` reject fires), so
b3 e4/e5 **abstain** where golden folds — an ABSENT object, the right failure
direction. (b) golden's SPAN for an escaped read overshoots the written text
(b3 e4 `38:20-38:35` vs ours `38:20-38:30`; b1 k17/k18 `132:20-132:30` vs
`132:20-132:25`). Same class as r10earl31's R4 and r10earl32's R5. Invisible to
`uhdm-cmp`; a real byte residue.

**R6 — F1 SURVIVES IN § defGenProcWildcardPkgParamNoFold19, and this pass
measured it.** b1 k18's `allModules` row (133:25): a **bare** `\x::y ` inside a
def-view gen-block process. Law 19's gate is
`rawText(expr.sourceRange).find("::") == std::string::npos`, which reads that
bare identifier as QUALIFIED, declines, and we fold `12'h456` where golden keeps
`ref_obj (work@k33.gesc.x::y)`. **The one-line fix is § argWrittenQualIsSyntaxKind33
itself** — swap the text test for the syntax kind, exactly as sites 2 and 3 of
this patch do. Not taken: law 19 is r10earl19's, and no cell of my grid measures
its *other* spellings, so shipping it would have been a gate change without a
grid. Fully characterised so the next pass starts from a cell, not a theory.

**R7 — an UNTYPED package parameter folds at 32 bits where golden reads 64.**
b2 N10 (60:21): every field agrees — `vpiDecompile:7`, `UINT:7`,
`vpiConstType:9`, span, parent — except `vpiSize` (golden 64, ours 32).
§ genNestedScopePkgParamNoFold24's own note records the same 64-vs-32 split for
its enum_const clone, so the discriminator is known and the arm is small.
Pre-existing in the module-side fold; this pass only made it visible here.

**R8 — a cross-package PACKAGE-INIT call argument** (a3 g9 / b3 s2): golden
folds `bfn(c32::P)` inside `package c32b`, we keep the `paramInitPkg`
cross-package ref and name it `c32b::c32::P` (a doubled scope). r10earl32's R4,
untouched by design — the same-package sibling (b3 s1) is the abstention that
must survive, and it does.

**R9 — THE TARGET'S HEAD: `flash_ctrl.sv:315`, a hier_path DISPLAY NAME.**
Golden re-lexes a `hier_path`'s name off its REDUCED expression tree, so a
parameter index prints as its VALUE (`region_cfgs[8]`); we print the WRITTEN
identifier (`region_cfgs[MpRegions]`). Everything else in the 154-line subtree
agrees — same spans, same index constant (8, size 32, UINT, ct 9), same element
chain — bar two secondary fields on that constant (`vpiParent`: golden
`param_assign@28:18`, ours the `bit_select`; and its ts ref's owner). Whole-design
census: golden 36 `region_cfgs[8]…` names against our 48 `region_cfgs[MpRegions]…`,
and 172 vs 176 distinct hier_path names carrying an identifier index overall.
**This is the next head on this design and it is a naming/re-lex law of the
§ hpSelParenStrip family, not a fold law.**

---

## 9. THE FILES IN THIS DIRECTORY

| file | what it is |
|---|---|
| `arm33.sh` | one arm's golden + ours + dumps + cmp. r10earl32's `arm32.sh`, carried forward verbatim |
| `cells33.py` | **THE VIEW-KEYED PER-CELL TABLE** — every call argument, both sides, keyed on (view, arg span, call, occurrence) so the DEF listing and the ELABORATED gen_scopes stay separate rows; `--only`, `--diffonly`, `--selfcheck` |
| `pred33.sh` | **the SOURCE-DERIVED mover fence**, A&C&D, computed before the sweeps were read |
| `mv33.sh` | per-shape mover attribution against golden by multiset, ADDED/REMOVED separately, fabricated-shape controls both directions (r10earl32's `mv32.sh`, unchanged) |
| `b1_gen.sv` | **THE CONTAINER ARM** — 18 cells: for/if/else/nested generate, cont-assign vs process vs instance port, bare vs qualified in one statement, never-instantiated module, the flat negative control, and the bare ESCAPED-`::` pair |
| `b2_init.sv` | **THE PARAMETER ARM** — 18 initialiser/type shapes at the def-view gen-CA position |
| `b3_text.sv` | **THE TEXT ARM** — macro-written argument and macro-written call, escaped name, escaped name containing `::`, bare-after-import, and the two package-init abstentions |
| `v4_more.sv` | r10earl32's verifier arm, adopted verbatim as the F4 seed |
| `a3_ctx.sv` | r10earl32's container arm, adopted verbatim as the abstention seed |

Reused unchanged and by ABSOLUTE path: `r10uvm55repro/{msdist.sh,ctcan2.sh,canaudit.sh}`,
`r10uvm52repro/canaries.sh`, `r10oth6repro/byteverify.sh`, `r10oth8repro/ct8rows.sh`.
