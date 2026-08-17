# r10uvm86 — § `negLitPkgRetFold86` — **THE FIVE-ROW NEGATED-LITERAL HEAD, CLOSED**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was NOT patched; `results/*.csv`
were **READ ONLY**; **nothing was promoted** and **no corpus row passes cmp**.

## The headline

r10uvm85 left ONE head standing on five UVM rows (seven row-modes) — a
**constant-fold**, the first head of this campaign that is neither a class-body
shape nor a chain:

```
return -1;                        uvm_sequencer_base.svh:1685:10
LHS golden  constant   vpiDecompile:-1  vpiSize:64  INT:-1  vpiConstType:7
RHS ours    operation  vpiOpType:1  ->  constant  decompile:1  UINT:1  ct:9
```

That head is gone, and so is its whole (three-object) family. The cmp line count
falls **38 → 28** on SeqDriver ×2 / SimpleUVM ×2 / Scoreboard / MiniAmiq ×2, and
the census after the patch is an **exact set join** with golden — zero
golden-only and zero ours-only objects in either population, in all six measured
databases (CENSUS Part 3). Seven databases of 955 moved; **BuildUVMPkg did not,
which is what the census predicted from the pristine bytes alone.**

| row | head BEFORE | head AFTER |
|---|---|---|
| SeqDriver / SimpleUVM / Scoreboard / MiniAmiq (both modes) | `constant(INT:-1)` vs `operation(vpiOpType:1)` @**1685:10** | `class_typespec(rsp_type)` vs `class_typespec(uvm_sequence_item)` @**211:58** |
| BuildUVMPkg (both modes) | `ref_typespec uvm_pkg::uvm_is_match::s` | unchanged (its own older head) |

This also closes a residue **r10uvm19** recorded and named: its remaining
`Stmt constant vs operation` bucket was "19 genuine expressions (`return -1`
folds its unary minus in golden, we keep `op1(1)`)".

## The law

> Surelog compiles every **PACKAGE TWICE** — `FunctorCompilePackage`
> (CompilePackage.cpp:60-72) runs the elaborated `Package` with **`Reduce::Yes`**
> and its `getUnElabPackage()` twin with `Reduce::No`, and `UhdmWriter` puts the
> first in `design.TopPackages` and the second in `AllPackages`. A **MODULE**
> (CompileModule.cpp:776/783), a **`$unit` FileContent**
> (CompileFileContent.cpp:94) and a **CLASS BODY** (CompileClass.cpp:489/521/…)
> all hardcode `Reduce::No`.
>
> Inside such a body, `compileStmt`'s **`paRETURN` arm is the ONLY statement arm
> that threads the inherited reduce into `compileExpression`**
> (CompileStmt.cpp:838) — every nested construct hardcodes `Reduce::No`. With
> `Reduce::Yes`, `compileExpression`'s tail runs `ExprEval::reduceExpr`
> (CompileExpression.cpp:3648), and a **UNARY MINUS over an INTEGER LITERAL**
> collapses to ONE `constant`:
>
> * the **SPAN is the MINUS TOKEN ALONE**. reduceExpr's result carries no line,
>   so the tail's `populateCoreMembers(parent, parent, result)` (:3656) uses the
>   `paUnary_Minus` node — one character, whatever the operand's width;
> * `vpiSize` is the **LITERAL'S OWN** size: 64 unsized decimal, N sized, and
>   **-1** for an unsized BASED literal (`-'d1`);
> * `vpiValue` = `INT:-<D>` and `vpiDecompile` the same text, where `<D>` is the
>   literal's **RAW BIT PATTERN read as an UNSIGNED decimal** — and `-0` reads a
>   plain `0`;
> * `vpiConstType` becomes **7 (`vpiIntConst`)**, replacing the operand's
>   base-derived type, the constant is **UNPARENTED**, and a signed based
>   literal's own `int_typespec` ref does **not** survive.
>
> The reach is exactly: a package's own function/task, an **OUT-OF-BODY
> class-method DEFINITION written at package scope**, and every
> **WILDCARD-IMPORT CLONE** of either — which copies the already-folded object
> into **BOTH** of the importer's views. NOT the home package's own DEF view,
> NOT an in-body class method, NOT a module / `$unit` subroutine, and NOT a
> return one level down.

### Why the corpus head is on a CLASS METHOD

`uvm_sequencer_base::get_seq_kind` is written **out of body**, at `uvm_pkg`
scope, so `CompilePackage` compiles it — twice, with the reduce pair. Then
`UhdmWriter::writePackage` splits its name on `::` and **moves the object into
the class_defn** (UhdmWriter.cpp:1237-1277). That is the whole reason a
package-compile law surfaces as a class-method difference, and it is why
`§ pkgRetTopExpr8`'s own note — "a class method … is compiled once, with
`Reduce::No`, and is bare — hence the `pkgScopeInst` half of the gate" — is
right for an **in-body** method and one case short for an out-of-body one. This
pass supplies that case; buvm8's fence is untouched.

## The fix — two flags and one rewrite

| site | file | what changes |
|---|---|---|
| 1 | `include/UhdmExporter.h` | `pkgRetFoldHome86`, with the Surelog derivation |
| 2 | `src/TaskFuncEmit.cpp`, beside `pkgDefViewBody9` | sets it: `homePkg86 && !(pkgDefViewBody9 && !pkgImportCloneEmit)` |
| 3 | `src/StmtEmit.cpp`, the `Return` arm | the fold, inside the same direct-statement window `§ pkgRetTopCallArgFormalTs8` uses |

The rewrite **emits the OPERAND and mutates it** rather than building a constant
from scratch, because a5's sixteen positive controls (`return 8'd3;` …
`return 32'hFFFFFFFF;`) are already **byte-identical to golden on both
binaries** — so the operand's own size/span machinery is golden's, and only
value, decompile, const type, span and typespec are overwritten. It also means
no operation object is minted and discarded: the patched `weaklyReferenced`
population is golden's exactly (81 objects / 77 `int_typespec`, from a
pristine 85 / 81).

## Fences, each with a cell that fails without it

1. **THE VIEW.** `!(pkgDefViewBody9 && !pkgImportCloneEmit)`. Arm a4 measures
   all five folded listings and all four controls on ONE golden, and the CORPUS
   proves the fence is load-bearing: golden folds `adpcm_pkg`'s / `svaunit_pkg`'s
   import clone of `get_seq_kind` in **both** views but keeps `uvm_pkg`'s **own
   DEF-view** copy of the same source line as an operation. Without the fence the
   SeqDriver count would be 4, not 3.
2. **THE HOME.** A package's own subroutine, or an out-of-body definition whose
   class_defn's `VpiParent` is a package. a4's `work@m4.c4m::mod_oob` (class in a
   module) and `unit_own` (`$unit`) are golden's own unfolded controls.
3. **IN-BODY vs OUT-OF-BODY.** a3 `b_only` / `i_only` are the same one-line body
   written both ways in one class; golden folds only the out-of-body one.
4. **DIRECT STATEMENT OF THE BODY.** An explicit `begin/end`, `if`, `if..begin`,
   `for`, `while`, `case`, `do..while` and a named block all close the window
   (a3, eight cells against `d_only` / `d_multi`). **The corpus depends on it:**
   of uvm-1.2's 12 out-of-body `return -1;`, **eleven are nested** and golden
   keeps every one of their operations.
5. **INTEGER LITERAL ONLY.** A REAL operand folds too (`-1.5` →
   `REAL:-1.500000` ct 2) but by a different formatting rule and with **zero**
   corpus witnesses, so it is left as measured residue R2 rather than guessed —
   the same reasoning r10uvm85 used to leave its own R1 unlanded.
6. **The PARAM / CLASS-PROPERTY negation laws are untouched.** `ParamEmit.cpp`
   (~305/397) owns the *parameter value* negative constant (`-3` → `INT:-3`
   size 64 ct 7) and `UhdmExporter.cpp:1436` / `§ classPropInit29` /
   `§ classScopedTypedefPropIsBareLogicVar73` own the *class-property
   initializer*, where golden **keeps** a bare `vpiMinusOp` (`int depth = -1`,
   `real r = -2.5`). This law lives only in a RETURN statement and reads neither
   context; a1's `a_decl` cell (a function-local `int b = -1`) is unchanged on
   both binaries, and v86bound.sh compiles r10uvm19 / r10uvm29 / r10uvm73's own
   arms to byte-identical dumps.

## The grid — 5 arms, 208 cells, every one compiled by BOTH tools

| arm | what it measures | cells DIFF pris → pat |
|---|---|---|
| `g86_a1_kinds.sv` | 13 return-expression spellings, plus assignment / decl-init / call-arg / compare / case-item / task controls | 15 → **8** |
| `g86_a2_ctx.sv` | the OTHER return expressions golden folds in the same window (param, localparam, call, arith, ternary, compare, concat, string, `$bits`, enum, formal) | 14 → **11** |
| `g86_a3_nest.sv` | the NESTING LADDER + in-body/out-of-body twins + a package's own functions | 4 → **0**, `CMP_FAIL` → **PASS_CMP** |
| `g86_a4_scope.sv` | the SCOPE ladder: package / module / `$unit`, DEF vs TOP view, and the WILDCARD-IMPORT clones | 10 → **3** |
| `g86_a5_vals.sv` | the VALUE/SIZE table (`-0`, `-2'b10`, `-4'hF`, `-8'd200`, `-32'hFFFFFFFF`, `-64'd1`, `-1'sb1`, `-2'sb10`, `-4'sd8`, `-8'sh80`, `-3'o7`, `-1_0`) + 16 positive controls | 13 → **1** |

**33 cells cured, ZERO cells regressed** — the pris→pat cell-set diff is all `<`
lines in every arm. One arm reaches `PASS_CMP`; **no corpus row does.**

## The instruments (all MEASUREMENT-ONLY)

| tool | what it answers |
|---|---|
| `ct86cen.cpp` | the three populations of ONE database (`Serializer::AllObjects`, each object once), tagged with the LISTING (DEFPKG/TOPPKG/DEFMOD/TOPMOD) and DIRECT/nested; `--list` is the span/size/value/owner join |
| `pred86.sh` | `ct86cen` over a whole sweep workdir — the predicted movers, BY NAME, from pristine bytes |
| `arm86.sh` | golden + BOTH binaries in ONE scratch dir; cmp verdict, head count, dump distance, pristine/patched byte compare |
| `cell86.sh` | the PER-CELL comparator: reduces both dumps to per-subroutine, per-listing operation/constant field lists |
| `v86bound.sh` | the BOUNDARY runner: every neighbouring pass's arm sources, both binaries, dump bytes |
| `sweep86.sh` | the sweep driver (echoes `GOLDEN_DEFER`, exports `SLANG_UHDM`, greps the workdir's own `cmds.txt`) |
| `g86_*.sv` | the grid |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the committed gate drivers, carried forward BYTE-IDENTICAL (md5-checked against r10uvm85repro) |

**One ops trap worth carrying forward:** a golden cache directory holds
`golden.uhdm`, not the `slpp_all/surelog.uhdm` its `cmds.txt` line suggests, and
handing `ct86cen` the wrong path throws a `kj` I/O exception and prints
**nothing** — which would have read as "golden has no such objects".

## RESIDUES (ranked)

**R0 — THE NEW HEAD, shared by the same five rows.** `class_typespec` for the
type parameter `rsp_type` at `uvm_sequencer_param_base.svh:211:58`:
```
LHS golden  class_typespec (rsp_type) @211:58-211:61, vpiParent = class_defn
            uvm_pkg::uvm_sequencer_param_base, vpiClassDefn -> uvm_sequence_item
RHS ours    class_typespec (uvm_sequence_item), NO span, NO vpiParent,
            vpiClassDefn -> the same uvm_sequence_item
```
Golden names the class_typespec after the **type parameter as written** and spans
it at the parameter's own text inside the class header, parented at the
parameterised class; we name it after the **actual** class and give it neither
span nor parent. 28 cmp lines on all seven row-modes. It is a **naming/parenting**
law of the parameterised-class header, not a fold.

**R1 — the general RETURN fold, same window, seven more expression kinds.** a2
measures each on golden: `return PW;` → the parameter's constant, `return LW;` →
`INT:-3`, `return pf_neg();` → the callee's own folded constant object,
`return PW + 1;` → `UINT:6`, `return 1 == 2;` → `BIN:0` size 1,
`return {2'b01,2'b10};` → `BIN:0110` size 4, `return $bits(int);` → `UINT:32`,
`return E1;` → `UINT:1`, and `return a + -1;` folds only the **-1 OPERAND**
(`INT:-1` ct 7) inside a surviving `vpiOpType:24`. `§ pkgRetTopCallArgFormalTs8`
and `foldedRet`/`pkgParamConst` already own part of this family for a package's
OWN functions; extending it to out-of-body methods and to the operand-level fold
is the next law in this window. Not landed here: each kind has its own value rule
and the corpus head needed none of them.

**R2 — the negated REAL.** a1 `r_real`: golden folds `return -1.5;` to
`REAL:-1.500000` / decompile `-1.500000` / size 64 / ct 2 (a `%f` rendering of
the negated value, *not* `"-" + source text` — our operand decompiles `1.5`).
Wrong on both binaries. ZERO corpus witnesses; one arm cell away.

**R3 — the recursive and non-minus unary folds.** a1 `r_dbl` (`-(-1)` → `INT:1`),
`r_tilda` (`~1` → `UINT:18446744073709551614`), `r_add` (`1 - 2` → `INT:-1`).
`r_uplus` (`+1`) is golden's OWN operation and already agrees — the fold is not
uniform over unary operators, which is itself a fact worth keeping.

**R4 — our `1_0` literal reads value 1.** a5 `f_negund`, in the DEF view, on
BOTH binaries: golden's operand constant is `decompile 10 / UINT:10`, ours
`decompile 1_0 / UINT:1`. An UNDERSCORE in an unsized decimal literal loses
everything after it in our literal arm. The FOLDED twin is correct here only
because this law takes its magnitude from slang's `SVInt`, not from the text.
Pre-existing, cmp-visible, and the only remaining a5 cell.

**R5 — a MODULE-scope out-of-body class method has no body at all.** a4
`work@m4.c4m::mod_oob`: golden emits the return operation, we emit nothing.
Pre-existing, identical on both binaries, unrelated to any fold.

**R6 — the import clone's shared object.** a4 `p4b::c4a::oob_task`: golden's
clone SHARES the home object's statement subtree (uhdm-dump prints the operand
constant twice), ours is a fresh copy printed once. Dump-only, both binaries,
both views.
