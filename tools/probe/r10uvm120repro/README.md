# r10uvm120 — § `pkgRetParamSubstIsRhsClone120`

**THE HEAD.** SeqDriver and MiniAmiq, both modes, 50 cmp lines, ONE head
(`grep -c '^LHS:'` = 1), at BASE `9e04993`:

```
LHS (golden)                              RHS (ours)
constant , line:34:10, endln:34:22        ref_obj (uvm_pkg::uvm_revision_string::uvm_revision)
|vpiParent: param_assign 31:18-31:42      |vpiParent: return_stmt 34:3-34:9
|vpiDecompile:"UVM.1.2"                   |vpiName:uvm_revision
|vpiSize:56                               |vpiActual: constant 31:33-31:42
|STRING:UVM.1.2
|vpiTypespec: ref_typespec (uvm_pkg)
   -> string_typespec 31:11-31:17
|vpiConstType:6
```

`uvm-1.2 src/base/uvm_version.svh`:

```systemverilog
parameter string uvm_revision = `UVM_VERSION_STRING;   // line 31

function string uvm_revision_string();
  return uvm_revision;                                  // line 34
endfunction
```

`expr::Compare` reads `BaseClass::Compare`'s VpiType first, so the object KIND
was the whole head.  The SAME cell is the return-window population of all five
UVM rows (SimpleUVM, Scoreboard and BuildUVMPkg read the same function;
BuildUVMPkg compiles the 1800.2-2017-1.0 `pp_output`, where the text is
`"Accellera:1800.2-2017:UVM:1.0"` and vpiSize is 232).

---

## 1. The decoded model

`CompileHelper::compileExpression`'s primary-literal arm, on a name it could not
answer from a value, walks the component's `param_assigns`
(**`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:2918-2980`**)
and, for the FIRST `param_assign` whose Lhs NAME matches, does exactly three
things:

```cpp
ElaboratorContext elaboratorContext(&s, false, true);
result = UHDM::clone_tree(param_ass->Rhs(), &elaboratorContext);
result->VpiParent(param_ass);
fC->populateCoreMembers(child, child, result);   // child == the REFERENCE node
```

(and only if the clone came back with no typespec does it attach one to the
parameter's declared type — a `param_assign` Rhs already carries its own, so
that branch is inert for every shape measured here).

So the substituted object is **the param_assign's Rhs VERBATIM** — every
constant field, its `ref_typespec` included — re-parented at the `param_assign`
and re-spanned over the REFERENCE text.  Three consequences, each measured:

1. **It is a CLONE, not a value re-render.**  We were building the constant from
   the parameter's slang VALUE and its declared width, which is right only for a
   decimal-literal initialiser: for `parameter byte b = 8'sd5` golden clones
   `8'sd5` / `DEC:5` / ct 1 and we wrote `5` / `UINT:5` / ct 9; for `4'hA` and
   `8'hFF` likewise (arm a `f_byt` / `f_vec` / `f_typ`).
2. **It reaches EVERY parameter type**, because a clone needs no value model.
   Our two gates — `resolveConstExpr` demanding an `IntegerLiteral` initialiser,
   and the fold demanding `ConstantValue::isInteger()` — are exactly why the
   STRING read missed the window.  Arm a folds all nine of string, int, untyped,
   `byte`, `bit [3:0]`, `real`, a typedefed vector, a `localparam` and an EMPTY
   string (which carries NO `vpiSize` at all).
3. **The lookup is NAME-KEYED**, not scope-resolved: the loop matches
   `param_ass->Lhs()->VpiName()` and never consults the enclosing scopes, so a
   function LOCAL or a FORMAL ARGUMENT carrying a package parameter's name reads
   back as the PARAMETER (arm d `f_localsh` — `int A; A = 9; return A;` in a
   package whose parameter `A` is 3 returns **3** — and `f_argsh`).

**THE WINDOW is § `pkgRetFoldHome86`'s**, and its DIRECT-STATEMENT half was
MISSING from our fold.  `FunctorCompilePackage` compiles a package twice and only
the elaborated copy carries `Reduce::Yes`; inside such a body only
`compileStmt`'s `paRETURN` arm threads that reduce into `compileExpression`
(CompileStmt.cpp:838).  Our fold fired for ANY top-view package return, so a
`return K;` nested in an `if`, an explicit `begin/end` or a `for` was folded
where golden keeps the bound `ref_obj` — three PRISTINE-WRONG cells, now right
(arm b `f_ifret` / `f_begret` / `f_forret`).  A multi-statement body's synthetic
`begin` is NOT such a nesting (arm b `f_two`, folded on both sides).

The VIEW half was already right and the arms prove it (arm c, MOVED=0 on the
whole arm): the home package's DEF twin keeps the `ref_obj`, an IN-BODY class
method keeps it, a module function and a `$unit` function keep it.

---

## 2. The change (`src/StmtEmit.cpp`, `StatementKind::Return`)

* the returned expression is resolved to a package parameter by SYMBOL and, when
  slang bound the name to something else, by NAME within the subroutine's own
  package (Surelog reads `component->getParam_assigns()`, which is the package
  being compiled — a wildcard-imported name is therefore NOT eligible);
* the folded constant's value fields are CLONED from the Rhs object THIS VIEW
  emitted for the parameter (`pkgParamDefRhs`, which the top-view parameter pass
  re-registers, so inside `pkgTopEmit` it is the ELABORATED listing's own
  constant; `pkgParamConst` is the def-view fallback).  The old integer
  re-render survives only where no Rhs constant exists, so no previously
  golden-matching cell changes shape;
* a parameter whose def-view Rhs is not a constant (`B = A + 1`, and chains of
  those) has no `pkgParamConst` entry, so the parent is taken from the view's own
  Rhs instead (arm d `f_b` / `f_c` / `f_ep`);
* the DIRECT-STATEMENT-OF-THE-BODY fence gates the substitution, and a parameter
  read whose window is CLOSED no longer falls into the literal arm — `cf.lit` is
  the PARAMETER'S INITIALISER there, and emitting it would put the initialiser's
  span and fields where golden holds the `ref_obj`;
* the typespec construction is untouched (`foldCloneTs` / `makeParamTs` with the
  package instance), because the three integer cells it already produced were
  byte-identical to golden and stayed so.

**FENCED to what was measured.**  The read must BE the whole returned
expression: an operand, a call argument, a select index and a concatenation
element are positions where golden REDUCES THE ENCLOSING EXPRESSION WHOLE
instead (`K + 1` -> 6, `{K, K}` -> one 64-bit BIN constant, `helper(K)` -> 5,
`ARR[K]` -> 6, `-K` -> INT -5) — § `negLitPkgRetFoldNested30`'s R2 family, not
this law.  A `pkg::NAME` read is fenced out too: it goes through Surelog's
`paPackage_scope` arm, whose constant carries NO typespec, NO parent and the RAW
`decompiledValue()` — a string WITHOUT its quotes.

---

## 3. What moved

| row | mode | cmp lines | head |
|---|---|---|---|
| SeqDriver | default, testflags | 50 -> 58 | **CLEARED**; new head is `bit_select` vs `bit_var` on `uvm_pkg::uvm_oneway_hash::crc1` 386:12 — a different family |
| MiniAmiq | default, testflags | 50 -> 58 | **CLEARED**, same new head |
| SimpleUVM | default, testflags | 13 -> 13 | unchanged (`method_func_call (new)`), ids +2 |
| Scoreboard | default | 13 -> 13 | unchanged, ids +2 |
| BuildUVMPkg | default, testflags | 13 -> 13 | unchanged, ids +2 |
| Earlgrey_0_1 | default, testflags | 36 -> 36 | cmp log byte-identical |
| Rggen | default | 0 | byte-identical |

`uvm_revision` / `UVM.1.2` / `Accellera:1800` appear in FOUR pristine head logs
and in **ZERO** patched head logs.  The cmp-line counts are DEPTH, not distance.

No row converted; the corpus census's return-window population went to golden
EXACTLY on SimpleUVM, Scoreboard and BuildUVMPkg (ONLY_GOLDEN 1 -> 0, ONLY_OURS
0) and by one cell each on SeqDriver (7 -> 6) and MiniAmiq (22 -> 21), whose
remainder is residue R1.

Arms: **13 TOGOLD, 0 MOVED-WRONG, 0 AWAY** (ARMS.r10uvm120.txt).
Gates: all green (GATES.r10uvm120.txt).  Boundary: 3714 arms, 10 moved cells,
every one attributed (BOUNDARY.r10uvm120.txt).

---

## 4. Residues

* **R1 — the `paramFromPackage` sibling, 6 (SeqDriver) + 21 (MiniAmiq) cells per
  mode, and the LARGEST measured population left in this family.**  Surelog's
  OTHER substitution clause fires with `Reduce::NO` whenever the matched
  parameter carries a non-empty `VpiImported` and its Rhs is a constant, in any
  statement position: `macros/uvm_object_defines.svh:162`'s
  `if (what__ inside {UVM_SETINT, UVM_SETSTR, UVM_SETOBJ})` inside every
  wildcard-import copy of `__m_uvm_field_automation`.  We ALREADY emit the right
  constants there (`131078` / `131079` / `131080`, size 32, ct 9, identical
  decompile and value); what golden has and we do not is a
  `ref_typespec -> int_typespec 217:1-217:38` on each.  **R0 candidate.**
* **R2 — the wildcard-import CLONE's DEF view.**  Golden copies the FOLDED
  object into BOTH of the importer's views (parent = the `return_stmt`,
  `clone_tree` having re-parented it); we now match in the TOP view and still
  emit a `ref_obj` in the DEF view (arm c `p120c2::pf` / `oob` / `oobs`; corpus:
  the `adpcm_pkg` and `svaunit_pkg` copies of `uvm_revision_string`, 4 cells).
  Also here: a surviving `sys_func_call`'s ARGUMENT takes this exact
  substitution (arm b `f_sysarg` / `f_sysfmt`), which we leave to the general
  fold.
* **R3 — the OUT-OF-BODY class method at package scope.**  Golden substitutes in
  its elaborated copy exactly as in a free function (arm c `p120c1::c120c::oob`
  and `oobs`); we keep the `ref_obj`.  Zero corpus witnesses.
* **R4 — our own `real`-parameter Rhs.**  Our `param_assign` Rhs for
  `parameter real r = 1.5` reads `1.500000` at size 64 where golden reads `1.5`
  at size 32, so the faithful clone inherits it (arm a `f_real`, the one
  MOVED-OTHER cell).  A defect in the parameter emission, not in this law.
* **R5 — the `pkg::NAME` spelling** (arm d `f_qual` / `f_squal`): golden's
  constant has NO typespec, NO parent and the RAW `decompiledValue()` (`sa`, not
  `"sa"`), in BOTH views.  Fenced out here.
* **R6 — a BARE enum-constant read** in the same window folds in golden to UINT
  at size **64**, ct 9, no typespec, unparented (`getValue`'s enum-const arm);
  § `r10fsv3 S7` covers only the WRITTEN-QUALIFIED spelling (arm d `f_enum`).
* **R7 — not this law, but found by the boundary and worth naming.**
  `r10buvm22repro/g22.sv`'s class-scope associative-array typedef
  (`typedef C22 ka_cls_t[string];`) emits a synthesized `[0 : N-1]` range whose
  N is an IMAGE-RELATIVE ADDRESS.  Proven with a positive control: a third
  binary built from the same source plus 8192 bytes of unrelated padding shifts
  the value by exactly +8192.  That arm's dump is not build-reproducible and any
  code change "moves" it.

**R0 (next head): R1** — put the `ref_typespec -> int_typespec` on the
imported-parameter substitution (`paramFromPackage`, `Reduce::No`), 27 cells per
mode on SeqDriver + MiniAmiq, and it is the same `getValue` mechanism this pass
decoded.

---

## 5. Instruments (all measurement-only; the judge is `uhdm-cmp`)

| file | what it does |
|---|---|
| `cen120.py` | a-priori census of Surelog's substitution, read off a GOLDEN dump alone (parent is a `param_assign`, span OUTSIDE it) |
| `uvmcen120.sh` | runs it over golden AND ours for every named row of a sweep workdir; multiset join |
| `rets120.py` | per-view, per-subroutine rendering of every `return_stmt` condition subtree |
| `pred120.py` | a-priori MOVER predictor from a PRISTINE dump alone |
| `score120.py` | TOGOLD / MOVEDWRONG / STILLDIFF / MOVED-OTHER per arm cell |
| `arms120.sh` | runs every `g120_*.sv` under Surelog + both binaries (fd-3 list, PROCESSED asserted) |
| `bound120.sh` | the WIDE boundary (reused verbatim from `r10buvm30/bound30.sh`) |
| `g120_a_types.sv` | the parameter-TYPE face (9 types) |
| `g120_b_positions.sv` | the POSITION face and the window fence (20 functions) |
| `g120_c_homes.sv` | the HOME/VIEW face (6 homes) |
| `g120_d_shapes.sv` | the LOOKUP face (chains, operation inits, enums, shadows, qualification) |
