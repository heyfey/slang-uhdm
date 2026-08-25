# r10uvm138 — § `pkgRetBareEnumConstFold138` — **THE RETURNED ENUMERATOR THAT STAYED A `ref_obj`** — the `UVM_FRONTDOOR` head CLEARED on FIVE row-modes, 17 cells in 9 databases, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `11643b6` (= UVM pass 136) |
| pristine binary | built from a clean worktree at `11643b6`, frozen `chmod 555` before any sweep; its five head logs reproduce the brief's head object for object |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/StmtEmit.cpp` ONLY — **one block** inside `StatementKind::Return` |
| probe surface | `tools/probe/r10uvm138repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | 32 cmp lines, head = `constant INT:0` vs our `ref_obj (…::UVM_FRONTDOOR)` | **head CLEARED** — 334 lines to a NEW head of a different family |
| **Scoreboard default** | 32, the same head | **head CLEARED**, the same new head |
| **BuildUVMPkg default / testflags** | 32, the same head (at the 1800.2 `pp_output`'s `get_default_door`) | **head CLEARED** — 83 lines to a new head |
| SeqDriver default / testflags | 17, 1 head (a different family) | head log **BYTE-IDENTICAL** — its 3 cells sit below the head |
| MiniAmiq default / testflags | 56, 1 head (a different family) | head log **BYTE-IDENTICAL** — its 3 cells sit below the head |
| Earlgrey_0_1 default / testflags | 21302 / 21926, 1 head | head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL), byte-identical |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweeps |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine **PREDICTED BY NAME** from the pristine databases before the patched sweep ran |
| the law's corpus population | 17 wrong cells over 9 databases | **0** — `OVER-FOLD 0` on every one |
| the law's grid population | 32 wrong cells (arms a/b/c/d, DEF **and** ELAB views) | **0** — `MOVED-WRONG 0`, `AWAY 0` |
| the boundary | 4014 arms, 3870 databases built | 9 moved, **40 TOGOLD, 0 MOVED-WRONG, 0 AWAY**, 0 rc diffs |

`UVM_FRONTDOOR` appears in **FIVE** pristine head logs and in **ZERO** patched
ones.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm-1.2 src/reg/uvm_reg_block.svh:1914`, an **OUT-OF-BODY class method written
at package scope**:

```systemverilog
function uvm_path_e uvm_reg_block::get_default_path();
   if (this.default_path != UVM_DEFAULT_PATH)
      return this.default_path;
   if (this.parent != null)
      return this.parent.get_default_path();
   return UVM_FRONTDOOR;                       // line 1914
endfunction
```

```
LHS (golden)                          RHS (ours, pristine)
constant , 1914:11-1914:24            ref_obj (uvm_pkg::uvm_reg_block::
|vpiDecompile:0                                 get_default_path::UVM_FRONTDOOR)
|vpiSize:64                           |vpiParent: return_stmt 1914:4-1914:10
|INT:0                                |vpiName:UVM_FRONTDOOR
|vpiConstType:7                       |vpiActual: enum_const (UVM_FRONTDOOR)
```

`BaseClass::Compare`'s FIRST comparison is the object's `UhdmType()`, so a
`constant` and a `ref_obj` first-fail there, before a field is read. That is the
whole head. The brief named five row-modes and **all five carry it at
`11643b6`** — re-measured with `rowheads.sh` on this pass's own pristine sweep
(`head_pris_*.cmp`); BuildUVMPkg reads the 1800.2 `pp_output`, where the same
statement is `get_default_door` at line 79314.

---

## 2. THE DECODED MODEL — `reduceExpr` ANSWERS THE NAME FROM THE ENUM'S REGISTERED `Value`

Three Surelog sites, and the whole law falls out of them.

**(a) The WINDOW.** `compileStmt`'s `paRETURN` arm is the ONLY statement arm
that threads the elaborated package compile's `Reduce::Yes` into
`compileExpression` (`src/DesignCompile/CompileStmt.cpp:838`); every nested
construct hardcodes `Reduce::No`. That is § `pkgRetFoldHome86`'s window, already
built here.

**(b) The FOLD.** `compileExpression` runs `ExprEval::reduceExpr` over its whole
result at the end of every call (`CompileExpression.cpp:3648`). reduceExpr
answers a `ref_obj` through the `getValue` functor →
`CompileHelper::getValue`'s COMPONENT arm (`CompileExpression.cpp:1074-1090`):

```cpp
sval = component->getValue(name);
if (sval && sval->isValid()) {
  UHDM::constant* c = s.MakeConstant();
  c->VpiValue(sval->uhdmValue());
  c->VpiDecompile(sval->decompiledValue());
  c->VpiConstType(sval->vpiValType());
  c->VpiSize(sval->getSize());
}
```

The result carries no line, so `compileExpression`'s tail re-spans it over the
REFERENCE (`populateCoreMembers(child, child, result)`) and leaves it
**unparented** — exactly the head's constant.

**(c) The `Value`.** `component->getValue(name)` finds the enumerator only
because `CompileHelper::compileTypeDef` registered it:
`scope->setValue(enumName, value, m_exprBuilder)`
(`src/DesignCompile/CompileHelper.cpp:849`) — the SAME `value` object it then
publishes on the `enum_const` as `VpiValue` / `VpiDecompile` / `VpiSize`
(`:857-868`). **So the folded constant is a copy of the `enum_const`, not a
value re-render.** Our `enum_const` objects are already golden's on 20 of the 22
declarations arm b measures, which is why this pass touches no enum emission at
all.

### The `Value` model, measured on 22 enum declarations (arm b, one function each)

| declaration | golden's folded constant |
|---|---|
| `enum { A, B }` (no base) | `dc=1  sz=64  INT:1  ct 7` |
| `enum int { … }` | `sz=32` |
| `enum bit [3:0]` / `logic [7:0]` / `byte` / `shortint` / `longint` | `sz=4 / 8 / 8 / 16 / 64` |
| `enum int unsigned` (implicit member) | still `INT:1`, `sz=32` |
| `= 9` (unsized decimal) | `dc=9  sz=64  UINT:9  ct 9` |
| `= 4'hB` | `dc=4'hB  sz=4  HEX:B  ct 5` |
| `= 2'b10` / `= 1'b1` / `= 4'b0101` | `BIN:…  ct 3` at the literal's width |
| `= 8'd9` | `dc=9  sz=8  INT:9  ct 7` — **the base is DROPPED from the decompile** |
| `= 'd6` (unsized based) | `sz=-1` |
| `= -3` (a unary minus, not a literal) | `dc=-3  sz=64  INT:-3  ct 7` — the LITERAL's 64, not the base's 32 |
| `{ A = 2, B }` / `{ A = 1 << 2, B }` | `B` resumes the counter at the BASE width — `INT:3` / `INT:5` |

An IMPLICIT member is always `set(val, Type::Integer, baseSize)`, i.e. always
the `INT:` tag; an EXPLICIT one is `fromVpiValue` over the compiled initialiser,
i.e. the literal verbatim. `enumMemberSubstConst` (ExprEmit ~7821) already
builds precisely that object for the qualified-pattern substitution — including
the based-decimal `dc` rule — so it is what mints this one too.

### The fences, each with an arm cell that fails without it

| fence | arm cells |
|---|---|
| the **WINDOW** is `pkgRetFoldHome86`'s: the home package's DEF view, an IN-BODY class method, a module function and a `$unit` function all keep golden's `ref_obj`; an OUT-OF-BODY class method at package scope and every WILDCARD-IMPORT CLONE (in **BOTH** of the importer's views) fold | c `inb_ret` / `inb_cls` / `mf_ret` / `mu_ret` / `u_ret` vs `oob_ret`, `p138c2::*` |
| **DIRECT STATEMENT OF THE BODY** — a return nested in an `if`, an explicit `begin/end` or a `for` is not folded; a multi-statement body's SYNTHETIC begin is not such a nesting | a `f_ifret` / `f_begret` / `f_forret` / `f_two`, c `oob_if` |
| the read must **BE** the whole returned expression — an assignment rhs, a case-item expression, a variable initialiser and a call argument are not folded at all | a `f_rhs` / `f_case` / `f_init` / `f_callarg` |
| the value must be one `compileTypeDef` registered ON THE PACKAGE — a CLASS-SCOPE enum typedef registers on the class, a FUNCTION-LOCAL one on the function, and an ANONYMOUS package enum (`enum { BB_A, BB_B } bb_var;`) takes no `compileTypeDef` at all | c `oob_cls` / `inb_cls`, b `f_loc`, b `f_bb` |
| a WRITTEN-QUALIFIED `pkg::NAME` read is § `r10fsv3 S7`'s arm, not this one | a `f_qual` (residue R2) |
| the fold refuses to carry OUR OWN `enum_const` disagreement into a new place | b `f_b7` / `f_b7b` / `f_bh` / `f_bc` (residue R1) |

---

## 3. THE CHANGE (`src/StmtEmit.cpp`, `StatementKind::Return`)

One block, structured exactly like the § `negLitPkgRetFold86` block beside it:
`pkgRetFoldHome86` + the direct-statement-of-the-body test, then a
NamedValue-that-is-not-a-ScopedName test, then the package-typedef-enum home
test, then the enum_const-agreement fence, and only then
`enumMemberSubstConst(sym)` re-spanned over the reference and hung on the
`return_stmt`'s `vpiCondition`. **The tag is read off the `enum_const` BEFORE
anything is minted** — a constant built and thrown away still lands in the
Serializer and shifts every id after it.

---

## 4. WHAT MOVED

The corpus population, per database, from `pop138.py` over `cen138.py`
censuses of the golden/ours pairs (CENSUS.r10uvm138.txt):

| row-mode | pristine | patched |
|---|---|---|
| SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2 | 1 | **0** |
| SeqDriver ×2, MiniAmiq ×2 | 4 | **1** |

SeqDriver's and MiniAmiq's remaining cell is **NOT this law's**: it is the
wildcard-import clone's DEF view of `adpcm_pkg::uvm_revision_string` /
`svaunit_pkg::uvm_revision_string`, a package-PARAMETER substitution and
§ `pkgRetParamSubstIsRhsClone120`'s own residue R2.

A blunter key-free control over the WHOLE database — how many
`return_stmt`→`ref_obj` cells remain — reaches golden's own count exactly on
five row-modes and misses by that one parameter cell on the other four:

| row-mode | golden | ours pristine | ours patched |
|---|---|---|---|
| SimpleUVM default/testflags | 777 | 778 | **777** |
| Scoreboard default | 788 | 789 | **788** |
| BuildUVMPkg default/testflags | 819 | 820 | **819** |
| SeqDriver default/testflags | 1070 | 1074 | 1071 |
| MiniAmiq default/testflags | 1168 | 1172 | 1169 |

**17 enum cells cleared, 0 over-folded.** The three cells per SeqDriver /
MiniAmiq database are the home package's TOP view plus BOTH views of the
`adpcm_pkg` / `svaunit_pkg` wildcard-import clone — the clone half that
§ `pkgRetParamSubstIsRhsClone120` left as residue R2 for parameters is right
here for enumerators from the start, because `pkgRetFoldHome86` already names
that listing.

Arms: **32 TOGOLD, 0 MOVED-WRONG, 0 AWAY**, in the DEF view and again in the
ELAB view (ARMS.r10uvm138.txt) — arm d also proves the fold is PER LISTING and
not per instance: a package function called from three instantiations of the
same module folds in exactly two places (the free function and the out-of-body
method), not six. Boundary: 4014 arms, 9 moved, **40 TOGOLD, 0
MOVED-WRONG, 0 AWAY** (BOUNDARY.r10uvm138.txt) — among them
§ `pkgRetParamSubstIsRhsClone120`'s **residue R6**, `p120d::f_enum`, which this
law closes. Gates: all green (GATES.r10uvm138.txt).

---

## 5. RESIDUES

* **R1 — the FIVE arm-b cells the fold deliberately refuses**, four of them
  because OUR OWN `enum_const` already disagrees with golden there and a fold
  that copied it would carry that disagreement into a new place:
  `f_b7` / `f_b7b` (`enum int { X = -3 }` — golden's enum_const is `INT:-3` at
  the LITERAL's size 64, ours `BIN:…` at the base's 32), `f_bh` (an
  `int unsigned`-based enum's implicit member — golden `INT:1`, ours `UINT:1`)
  and `f_bc` (`8'o20` — golden `UINT:16`, ours `OCT:20`).  The fifth, `f_bg`
  (`= 'd6`, an UNSIZED based literal), is refused by `enumMemberSubstConst`'s
  own `sz <= 0` guard, where golden's folded constant carries `vpiSize:-1`.
  Fixing the `enum_const` builder would hand all five to the fold for free.
  Zero corpus witnesses. **R0 candidate for this family.**
* **R2 — the WRITTEN-QUALIFIED `pkg::NAME` read** (a `f_qual`, in BOTH views):
  golden folds it to the SAME `Value` (`dc=1 sz=64 INT:1 ct 7`) while our
  § `r10fsv3 S7` arm writes `UINT:1 ct 9` at a flat size 64. The two Surelog
  arms that can answer a qualified name (`pack->getValue`, which gives the
  registered `Value`, and `getValue`'s typedef-map arm at
  `CompileExpression.cpp:1130`, which hardcodes `VpiSize(64)` /
  `vpiUIntConst`) have not been distinguished, and § S7's model has corpus
  witnesses that currently PASS, so it was NOT touched.
* **R3 — an enumerator NESTED inside the returned expression.** Golden folds it
  too (a `f_cmp` → `INT:1` parented at the operation, a `f_tern` → `INT:1` /
  `INT:2`), but it arrives with the ENCLOSING expression reduced whole wherever
  it can be (a `f_op`: `return A_ONE + 1;` is ONE constant `INT:2` spanned over
  the reference, the operation gone; a `f_callarg`: the whole `f_help(A_ONE)`
  call is evaluated away). Folding the operand alone would move those cells
  without landing them, so the law stops at the whole returned expression.
  **Corpus population: ZERO** — no UVM database has a single nested cell on
  either side.
* **R4 — a FUNCTION-LOCAL enum typedef's body shape** (b `f_loc`): golden wraps
  that function's body in a `begin` and we do not, so the cell joins one-sided
  in both directions. Both sides hold the same unfolded `ref_obj`; a
  statement-list law, not this one.
* **R5 — `r10buvm22repro/g22.sv` is not build-reproducible.** Its class-scope
  associative-array typedef synthesizes a `[0 : N-1]` range whose N is an
  IMAGE-RELATIVE ADDRESS; the only delta between the two binaries is a shift of
  exactly +4096. § `pkgRetParamSubstIsRhsClone120` named this as its R7 and it
  is still true.

**R0 (next head): the new head on SimpleUVM ×2 and Scoreboard/default**
(334 cmp lines, ONE head, `head_pat_SimpleUVM_default.cmp`) — the CLASS-LOCAL
COPY of a package enum typedef, `uvm_sequence_base.svh:399`:

```
LHS (golden)                                 RHS (ours)
enum_typespec (uvm_pkg::uvm_sequence_state_enum)   enum_typespec (uvm_pkg::uvm_sequence_state)
|vpiParent: class_defn (work@env)            |vpiParent: module_inst (work@top)
|vpiName:uvm_pkg::uvm_sequence_state_enum    |vpiName:uvm_pkg::uvm_sequence_state
|vpiTypedefAlias: ref_typespec               (no Typedef_alias at all)
   (work@env::uvm_pkg::uvm_sequence_state_enum)
   -> enum_typespec (uvm_pkg::uvm_sequence_state)
|vpiInstance: package uvm_pkg                |vpiInstance: package uvm_pkg
```

Golden mints a SECOND enum_typespec for the class's own copy, names it after
the TYPEDEF (`…_enum`) and links it to the package's enum through
`Typedef_alias`; we hand out the package's object itself, under the wrong
parent and under the base name. `typespec::Compare` walks `Typedef_alias`
before `Instance`, and `BaseClass::Compare` reads `VpiName` first, so both
halves are in play. The enum_const values agree cell for cell on both sides
(`UINT:1` / `UINT:2` / `UINT:4` …), so this is a TYPESPEC IDENTITY head, not a
value head.

BuildUVMPkg's new head (83 lines, both modes) is a different object again:
`LHS: <null>` against our `function (uvm_pkg::uvm_reg_map)` at the 1800.2
`pp_output`:75228 — a SURPLUS task-func of ours (the class's `ceil`) that
golden's `uvm_reg_map` class_defn does not list.

---

## 6. INSTRUMENTS (all measurement-only; the judge is `uhdm-cmp`)

| file | what it is |
|---|---|
| `cen138.py` | the ENUM-CONSTANT REFERENCE census over the uhdm-dump **TREE** (never `Serializer::AllObjects`), one cell per `constant`/`ref_obj` keyed by (VIEW, SITE, SPAN) |
| `score138.py` | the three-way arm score — golden × patched × pristine → TOGOLD / MOVED-WRONG / AWAY / SAME-WRONG / SAME-OK, with the ONE-SIDED sets printed in both directions |
| `pop138.py` | the law's population out of two censuses, plus a SPAN-FREE control so no cell hides behind the uvm report macros' span shifts |
| `pred138.cpp` / `pred138.sh` | the A-PRIORI mover predictor, run on the PRISTINE databases before the patched sweep |
| `corpcen138.sh` | cen138 over a verify_golden workdir's named rows, golden path read from each row's OWN `cmds.txt` |
| `attr138.sh` | ORDER-BLIND attribution of every byte mover (sorted, id- and path-stripped dumps) — the Scoreboard/default COIN cannot hide a change and cannot be mistaken for one |
| `arm138.sh` / `elab138.sh` | one arm, golden + both binaries, DEF view and ELAB view |
| `bound138.sh` | the boundary gate over every `.sv`/`.v` in a COPY of `tools/probe` |
| `g138_a_ctx.sv` | arm a — CONTEXT grid (13 functions: return direct / in an if / in a begin / in a for / two-statement body / rhs / call arg / comparison / case item / initialiser / ternary / operation / qualified) |
| `g138_b_kinds.sv` | arm b — ENUM-KIND grid (22 declarations × one function each) |
| `g138_c_homes.sv` | arm c — HOME/VIEW grid (package free function, out-of-body class method, in-body class method, class-scope enum, wildcard-import clone, module function, `$unit` function) |
| `g138_d_inst.sv` | arm d — INSTANCE COUNT (one package, three instantiations of the module that calls it) |
