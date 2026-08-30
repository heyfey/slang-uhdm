# r10uvm164 — § castOperandNeverBindsInCondWindow164

**The `if` / `case` CONDITION column is the same cast window.**

*Base commit `578ffc2` (the r10uvm161 landing). LHS is ALWAYS golden (Surelog),
RHS is ALWAYS ours. The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
sole judge; every instrument in this directory is MEASUREMENT ONLY.*

---

## 1. The head, re-measured and re-decoded on this pass's own pristine build

`rowheads.sh` on this pass's own surelog sweep, run with a frozen pristine
binary whose md5 is byte-identical to the main tree's at `578ffc2`:

| row | mode | cmp lines | heads |
|---|---|---|---|
| SeqDriver | default / testflags | **29 / 29** | 1 / 1 |
| SimpleUVM | default / testflags | **29 / 29** | 1 / 1 |

`head_pris_*.cmp` holds all four. They are the SAME OBJECT on all four
row-modes:

```
LHS: <null>
RHS:
decompile:
io_decl: (action), id:87499, line:347:51, endln:347:57
|vpiParent:
\_function: (uvm_pkg::uvm_report_handler::format_action), id:87495, line:347:3, ...
```

`LHS: <null>` with a full RHS is `BaseClass.h`'s **SINGULAR** `SafeCompare`
(`:191-193`) — the MIRROR of the `RHS: <null>` form r10uvm161's owner-finder was
built for. The object the judge stopped on therefore lives in OUR database, and
the scan has to run the other way round. `ct164own.cpp` does exactly that
(`GetByVpiType`, the generated kind-agnostic edge accessor, so no field is named
by hand and none can be missed by omission):

```
MIRROR REFERENCE SCAN — every edge of OURS that lands on the head, and golden's:
  ours   function(format_action)@347:3-347:9
      edge vpiType=28 (vector index 0)     cast=-
      golden function(format_action)…  -> vector present size 1, [0] = io_decl(action)…
  ours   ref_obj(action)@350:25-350:31
      edge vpiType=700 (singular)          cast=castop
      golden ref_obj(action)@350:25-350:31 -> singular <null>          <<<< THE EDGE
  ours   ref_typespec()@0:0
      edge vpiType=81 (singular)           cast=-
      golden ref_typespec()… -> singular io_decl(action)…
```

Three edges land on the head; two agree. The failing one is **`vpiActual`
(700) of the `ref_obj action` at 350:25** — golden `<null>`, ours the io_decl.

**Every reference in the head function, both sides** (`ct164own.cpp` STEP 2 —
54 references per side, `uvm_report_handler.svh:347-364`):

```
        span   name           cast       GOLDEN                    OURS
        350:25 action         castop     BARE            BOUND -> io_decl(action)@347:51
        350:36 UVM_NO_ACTION  -          BARE                      BARE
        351:7  s              -          BARE                      BARE
        355:10 action         -          BARE                      BARE
        355:19 UVM_DISPLAY    -          BARE                      BARE
        …  356:10 357:10 358:10 359:10 360:10 361:10  action  -  BARE  BARE
        …  every `s` at 354/355/356/357/358/359/360/361/364        BARE  BARE
```

**Exactly one reference in the function carries a cast, and it is the head.**
The seven sibling `action` references at :355-361 the brief names are bare on
BOTH sides and stay bare: they sit one control body deeper than the formal's
declaration, which is § refVarLocalWindowBinds5's DEPTH half — nothing to do
with the cast.

The source (`uvm-1.2/src/base/uvm_report_handler.svh`):

```systemverilog
347:  static function string format_action(uvm_action action);
348:    string s;
350:    if(uvm_action_type'(action) == UVM_NO_ACTION) begin      <<<< the head
355:      if(action & UVM_DISPLAY)   s = {s, "DISPLAY "};        <<<< the siblings
```

---

## 2. The law, read from Surelog and not guessed

> **A cast's operand is never eagerly bound, at any depth under the cast — in
> the `if` and `case` CONDITION columns exactly as in the assert and case-item
> columns. Surelog draws no line between them: one `paCast` arm, one null
> `pexpr`.**

`CompileExpression.cpp:2637-2646`, the `paCast` / `paConstant_cast` arm:

```cpp
NodeId Expression = fC->Sibling(Casting_type);
operand = compileExpression(component, fC, Expression, compileDesign,
                            reduce, nullptr, instance, muteErrors);
//                                  ^^^^^^^ the pexpr argument
```

`CompileHelper::bindVariable` (`CompileStmt.cpp:3089-3092`) opens
`if (scope == nullptr) return nullptr;`. Both cast spellings take that arm: the
`'()` type/size cast (the `vpiCastOp` branch at `:2662`) and the signedness cast
(`$signed`/`$unsigned`, minted at `:2649-2661`) — the operand is compiled BEFORE
either wrapper exists. Neither line knows which statement the cast stands in.

**Why the term is still a class-method term — the module face.** The null
`pexpr` is not the end of the story. The name arm
(`CompileExpression.cpp:2833-2842`, again at `:2989-2995`) reads

```cpp
if (pexpr)          { if (var = bindVariable(component, pexpr,    name, …)) … }
else if (instance)  { if (var = bindVariable(component, instance, name, …)) … }
else if (component) component->needLateBinding(ref);
```

so a cast operand falls through to the **instance**. A class method living in a
package has none and reaches `needLateBinding`, where a formal and a subroutine
local find nothing — golden BARE. A **module** function, task or process HAS an
instance — golden **BOUND**. That is the counter-example r10v161's verifier
convicted its own first cut on, and it is re-measured here in the CONDITION
column: `v161_d_break.sv` **d61 146:14 `if (int'(loc) == 1)` in a module
function is golden-BOUND, pristine-BOUND and PATCHED-BOUND.**

`condMethodWindowDepth164` is raised by `MethodWindow161` only where the window
**actually lifts a set `classMethodNoBind`**, so the term is inert wherever
there is an instance or the flag was never set.

---

## 3. The edit

Three lines of behaviour, in the shape r10v161 designed for it.

1. `include/UhdmExporter.h` — one new counter, `condMethodWindowDepth164`, the
   CONDITION column's twin of `methodWindowDepth161v`, plus the law §.
2. `src/StmtEmit.cpp` — § refVarLocalWindowBinds5's three CONDITION sites
   (`if`, `if_else`, `case`) trade their hand-spelled
   `bool sX = classMethodNoBind; classMethodNoBind = false; … ; classMethodNoBind = sX;`
   for the `MethodWindow161` RAII that already does exactly that at the other
   three sites — and that also raises the depth, only when it lifts a set flag.
3. `src/ExprEmit.cpp` — one disjunct:

```cpp
bool castOperandNoBind161v =
    (methodWindowDepth161v > 0 || condMethodWindowDepth164 > 0) &&
    castOperandDepth161v > 0;
```

**The counter is SEPARATE on purpose.** § namedBlkLocalNoBind144v reads
`methodWindowDepth161v` alone, so r10v161's deliberately-left-standing
condition-column named-block twins **cannot** move with the cast cells. Arm D
measures that: d41 (a named-block local, no cast, `if` condition — golden BARE,
ours BOUND) is byte-for-byte what it was, while its cast twin d42 moves.

**No symbol half, and that is measured, not assumed.** A class property, a
class static property and an enum-typed property under a cast in a condition are
golden-BARE and ALREADY bare in the pristine binary (arm A a21/a23/a27, arm C
c17/c18/c21) — `bindVariable` has no class-scope case, so there is nothing to
take away. The corpus agrees: the predictor's `INERT-LATE` bucket is empty over
956 + 1358 databases. A conjunct with no cell behind it would be a hedge, so
there is none.

---

## 4. The measured population (CENSUS.r10uvm164.txt)

Every reference under a cast across the **nine UVM databases** × both modes ×
both views — the only databases in either corpus that compile
`uvm_report_handler` (BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM × default and
testflags, plus Scoreboard/default; Scoreboard/testflags has no database). The
other UVM-tree rows use the tree only as an include path and hold zero cells;
the predictor sweep over all 956 + 1358 databases found cells in these nine rows
and nowhere else.

**668 references under a cast**, keyed by context × home × cast kind:

| context | cells | DIFF before | DIFF after |
|---|---|---|---|
| ifcond | 164 | **9** | **0** |
| assign_rhs | 266 | 0 | 0 |
| body | 176 | 0 | 0 |
| arg | 35 | 0 | 0 |
| return | 27 | 0 | 0 |
| casecond / caseitem / assertcond | 0 | — | — |

| home | cells | DIFF before → after |
|---|---|---|
| function@class_defn | 333 | 9 → 0 |
| function@package | 227 | 0 → 0 |
| task@class_defn | 18 | 0 → 0 |
| function@design | 2 | 0 → 0 |
| none@none | 88 | 0 → 0 |

| cast kind | cells | DIFF before → after |
|---|---|---|
| castop | 668 | 9 → 0 |
| signcast | 0 | — |

All nine DIFF cells are the same cell:
`(ifcond, castop, function@class_defn, ref_obj, action, 350:25)` — `30800:25` in
BuildUVMPkg's `pp_output` flattening — golden BARE, ours BOUND.

**Scored pristine → patched: MOVED 9, TOWARD 9, AWAY 0, SIDEWAYS 0, RESHAPE 0.**

**Both one-sided sets, reported and unchanged**: ONLY-G 88 cells at
`(body, function@class_defn|function@package, castop)` and ONLY-O 88 cells at
`(body, none@none, castop)` — the SAME 88 enum-constant references
(`uvm_severity'(UVM_ERROR)` and friends), differing only in the HOME key because
golden gives them a subroutine parent and we do not. A pre-existing PARENTING
residue in the `body` context, outside this window entirely; identical before
and after.

**AWAY scored explicitly, both columns.** A cast operand left BARE where golden
BINDS is AWAY. The corpus has zero: the 227 package-function, 18 class-task, 2
design and 88 home-unattributed cells are byte-for-byte what they were. On the
grid, every module face (module function, module task, `initial`, package free
function, out-of-body method) is golden-BOUND and unmoved.

Per-database wide check (`score164.py`, the REF / VAR / CNT / OBJ / TYP families
r10v161's verifier used, plus CAS): each of the nine moved databases moves
**exactly 2 cells** — the CAS key and the REF key for the same reference — both
TOWARD; VAR, CNT, OBJ and TYP move **0** everywhere, and the ONLY-G / ONLY-O
counts are identical before and after, so nothing reshaped.

---

## 5. Prediction before any patched database existed (PREDICT.r10uvm164.txt)

`ct164pred.cpp` reads ONE **pristine** database and applies the term's own
conjuncts: a bound reference, under a cast, inside an `if`/`if_else`/`case`
`VpiCondition()` subtree read as an EDGE (a condition is re-parented to the
enclosing scope by both producers, so a parent-chain walk scores every condition
cell as "other" — the tool builds a pointer map of statement edges instead),
whose enclosing subroutine is a class method **whose own span lies inside its
class's span** (the structural in-body test; the bind SIGNATURE is kept as an
independent cross-check and is printed, but `do_print`'s unread `string v` shows
why the signature alone is not the test), and whose actual is declared IN that
subroutine.

```
surelog     -- databases=956   rows-with-cells=9  restore-fail=0
            -- PRED cells: 9   PRED-SIGN: 0   INERT-OOB: 48   INERT-LATE: 0
uhdm2rtlil  -- databases=1358  rows-with-cells=0  restore-fail=0
            -- PRED cells: 0
```

**Measured afterwards: `byteverify` MOVERS 9 / 956 and 0 / 1358 — exactly those
rows, by name.**

The `INERT-OOB` bucket is worth its own line: 48 cells, all out-of-body method
definitions, including `uvm_component.svh:2735 / 2797 / 3318`
`if (uvm_verbosity'(recording_detail) != UVM_NONE)` where golden **BINDS** the
class property through late binding. Those are exactly the cells an
un-discriminating term would have taken AWAY; the in-body gate leaves all 48
untouched, measured.

---

## 6. The grids (GRID.r10uvm164.txt)

Four arms × two views (DEF and ELAB), each against its own Surelog golden built
by `grid164.sh`, which records every command WITH ITS BINARY PATH and every rc
in the workdir's `cmds.txt` (an rc=139 segfault must never read as a result).

| arm | what it measures | pris DIFF | pat DIFF | moved |
|---|---|---|---|---|
| **A** `g164_a_ctx.sv` | the seven CONTEXTS (if / case cond / case item / assert / assignment / argument / return), each read TWICE — through a cast and bare — plus the same seven over a class property, a class static and a package variable | 27 | 15 | **12, all TOWARD** |
| **B** `g164_b_home.sv` | the HOME matrix: in-body method, in-body STATIC method, in-body task, constructor, virtual method, OUT-OF-BODY method, package free function, MODULE function, module task, `initial` | 21 | **1** | **20, all TOWARD** |
| **C** `g164_c_kinds.sv` | every cast KIND (`int'` `bit'` `unsigned'` `signed'` size enum typedef nested cast-of-cast cast-in-a-binary) × every referent (local, formal, method-static local, class property, class static, package variable, enum-typed property) × 1/2/3 instances per condition, plus `$cast`, `$bits`, `$signed`/`$unsigned` as SYSTEM CALLS | 99 | 11 | **92: 88 TOWARD, 4 NO-GOLDEN, 0 AWAY** |
| **D** `g164_d_notmove.sv` | the MUST-STAY matrix: every un-cast twin in the seven contexts; a cast OUTSIDE the window (assignment, argument, `while`/`for`/`repeat`/`do-while` control, `case … inside` item, `wait`, `return`); § 5's DEPTH half; § 144v's condition twin; a named `fork` arm | 19 | 7 | **12, all TOWARD** |
| **r10v161's own arm D** `v161_d_break.sv`, re-run | the module-function control the previous verifier convicted its first cut on | 43 | 15 | **28, all TOWARD** |

**MOVED-WRONG 0. AWAY 0 on every arm.**

The four `NO-GOLDEN` cells in arm C are one source line read twice per view:
`octet_t'(int'(barrow))`, a cast of a cast, where golden renders TWO nested
`vpiCastOp` operations and we render ONE — a pre-existing SHAPE difference that
puts the two sides on different census keys. The value still moves from BOUND to
golden's BARE; it is scored NO-GOLDEN rather than TOWARD because the key cannot
be joined, and it is named here rather than swept into the TOWARD count.

The sharpest single control is arm C **c11**:
`if ((int'(barrow) == 41) && (barrow == 41))` — ONE condition, two references to
the SAME local. `44:15` (under the cast) golden BARE, ours BOUND → BARE.
`44:34` (bare) golden BOUND, ours BOUND → **BOUND**. The term is the CAST, not
the position.

The second sharpest is arm C **c33/c34**: `$signed(plinth)` and
`$unsigned(drift)` written as SYSTEM CALLS are golden-BOUND and stay BOUND,
while `signed'(plinth)` / `unsigned'(barrow)` at the same depth in the same kind
of condition (c03/c04) are golden-BARE and move. Surelog renders both spellings
as one `sys_func_call`; our emitter separates them by SYNTAX
(`SignedCastExpressionSyntax` under the `ConversionExpression` arm), which is the
only place they are separable — a database-side census cannot, and
`ct164cen.cpp` says so in its own header.

The brief's `$cast` negative (arm C **c30/c31**) is exact: on golden, on the
pristine binary and on the patched binary alike, `$cast(stance, crumb)` stays a
`sys_func_call:$cast` and its four argument references keep the identical values
(`crumb@79:23` BOUND, `crumb@80:25` BARE, `stance@79:15` BARE,
`stance@80:17` BARE) — `CTX=arg`, `CAST=none`. It is a system call, not the
`paCast` arm, and nothing about it moves.

Arm B's must-stay column, in full: package free function (b01-b03),
out-of-body method (b31-b33), module function (b41-b44), module task
(b45/b46) and `initial` (b51-b53) are **golden-BOUND, pristine-BOUND,
patched-BOUND**. A constructor's local (b22) was already bare on both sides
(§ ctorSubLocalNoBind144) and stays bare.

---

## 7. The boundary (BOUNDARY.r10uvm164.txt)

`bound164.sh` over a COPY of the whole probe tree — top level AND
subdirectories, both views, both binaries, every child `</dev/null`, the file
list on fd 3, scratch keyed on the RELATIVE path, `PROCESSED` asserted against
`LISTED`. This pass's own four arms are the POSITIVE CONTROL: a gate reporting
zero movers over them cannot see.

Every arm outside this pass that moved was censused against its OWN Surelog
golden and is the same law:

| arm | cells | verdict |
|---|---|---|
| `r10buvm29repro/g29_c_carriers.sv` | 4 | all TOWARD (DIFF 4 → 0) — `__a` under a concat under an `inside` under a `castop`, in an in-body class method's `if` condition |
| `r10uvm96repro/g96_a2_homes.sv` | 4 | all TOWARD (DIFF 10 → 6) — `scaled` under a `castop` in an in-body method's `if` condition |
| `r10v161repro/v161_d_break.sv` | 28 | all TOWARD (DIFF 43 → 15) — the previous pass's own break arm, module-function control unmoved |
| `r10v161repro/v161_g_catshape.sv` | 8 | all TOWARD (DIFF 116 → 108) — a concatenation UNDER A CAST in an `if` condition. Its cast-free concat cells, r10v161's R0b, are **untouched** |

---

## 8. What this pass does NOT own (residues)

- **R-oob** — an OUT-OF-BODY class method at `$unit` scope: `v161_d_break.sv`
  130:12 / 131:16, golden BARE, ours BOUND, both binaries. `classMethodNoBind`
  is never set there, so no window opens and the term is inert. The same shape
  inside a PACKAGE (arm B b31-b33) is golden-BOUND and correct on both sides —
  the discriminator is § newArrayArgHoistNet130's conjunct (2): a package's
  late-binding list hoists into importing modules, `$unit`'s does not.
- **R-pkgvar** — a package variable read through a package-qualified name under
  a cast in a condition (arm A a25 `int'(pk_ctx164::pkg_gauge)`, arm C c20):
  golden BARE, ours BOUND, unmoved by this pass. The qualified reference never
  reaches this bind gate.
- **R-catshape** — `octet_t'(int'(x))`: golden emits two nested `vpiCastOp`
  operations, we emit one. A shape residue, arm C c09.
- **R-bodyhome** — the 88 enum-constant references under a cast in `body`
  position whose golden parent is the enclosing subroutine and whose ours is
  nothing (`none@none`). Both sides BARE; a parenting residue.
- **R0b (r10v161's)** — a plain CONCATENATION's operands in a class method:
  golden BARE, ours BOUND. Untouched here on purpose;
  `v161_g_catshape.sv` still shows DIFF 108 after this patch.

---

## 9. R0 — the next head on this row family

The head of SeqDriver×2 and SimpleUVM×2 moves **29 → 82 cmp lines**, ONE head,
still ONE object on all four row-modes (`head_pat_*.cmp`):

`uvm-1.2/src/base/uvm_misc.svh:651:13` — inside the PARAMETERIZED class
`uvm_utils #(type TYPE=int, string FIELD="config")`, which declares
`typedef TYPE types_t[$];`, the static method
`static function types_t find_all(uvm_component start);` declares a local
`types_t types;`.

- **golden** emits it as a plain `ref_var` whose `ref_typespec`'s actual is the
  NAMED `array_typespec (types_t)` at 642:11;
- **ours** emits an `array_var` (`vpiArrayType:4`) whose own `ref_typespec`
  points at an ANONYMOUS `array_typespec` at the declaration span 651:13, with
  the named `types_t` typespec demoted onto a nested `vpiReg` `ref_var`.

Two different `UhdmType`s, so the generated `Compare`'s type test fails first —
the head is the DECLARATION KIND of a queue-typed local in a parameterized
class. `BuildUVMPkg` stays at 29 (its head is a different object, the
`alias_name` argument binding — uvm165's), MiniAmiq at 106, Scoreboard/default
at 145, Earlgrey at 58/62, Rggen/default CMP_EQUAL.

---

## 10. The instruments in this directory

| file | what it is |
|---|---|
| `ct164cen.cpp` | the census. A strict SUPERSET of `r10v161repro/ctv161cen.cpp`: its five families (REF / TYP / VAR / CNT / OBJ) reproduced byte-for-byte so the must-not-move check is the same one, plus **CAS** — every reference keyed by CONTEXT × CAST × HOME. The context is read from a POINTER MAP of statement edges, not from `vpiParent`, because a condition parents at the enclosing scope. |
| `ct164own.cpp` | the MIRROR owner-finder for an `LHS: <null>` head, plus the whole-function reference listing of §1. |
| `ct164pred.cpp` | the a-priori predictor of §5. |
| `score164.py` | the cell scorer (TOWARD / AWAY / SIDEWAYS / RESHAPE / NO-GOLDEN). |
| `cencount164.py` | the corpus census cross-tab of §4 (multiset join; both one-sided sets). |
| `grid164.sh` | the arm driver (both views, both binaries, every rc recorded). |
| `census164.sh` | the corpus census driver (golden read out of each row's own `cmds.txt`; SKIP-NOFILE counted). |
| `predsweep164.sh` | the predictor sweep (RESTORE_FAIL counted). |
| `bound164.sh` | the wide boundary gate. |
| `g164_[a-d]_*.sv` | the four arms. |
| `head_pris_*.cmp` / `head_pat_*.cmp` | the seven named rows' heads, before and after. |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | copies of the campaign gate scripts, so `canaudit.sh` runs from this directory. |
