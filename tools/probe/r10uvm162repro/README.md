# r10uvm162 — § `badConcatCompoundOperands162` — **A REJECTED CONCATENATION'S OPERAND IS ITS ACCEPTED TWIN'S OBJECT AT EVERY DEPTH, SO THE REBUILD RECURSES: A TERNARY, A BINARY OPERATOR, A NESTED CONCATENATION AND A REPLICATION ARE ADMITTED WHEN EVERY SUB-OPERAND IS** — the BuildUVMPkg ×2 **321-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `fe4a739` |
| worktree | `/tmp/wt_r10uvm162` |
| pristine binary | md5 `83258cd958cb88be667bf6729dcb0b9d`, built from this worktree at a clean `fe4a739` and frozen `chmod 555` before any sweep |
| patched binary | md5 `834a54ee7996ba8b29b245895a4eaee8`, frozen `chmod 555`. `/tmp/r10uvm162.patch` applied to a FRESH `fe4a739` worktree and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5, and its goldens read 23/0 — the patch IS the artifact every number below was measured on |
| production surface | `src/ExprEmit.cpp` (the law, the measured operator map, the plain-decimal predicate, one constant-parenting helper, six new operand branches and one `depth > 0` refusal inside § 160's shape (5)), `include/UhdmExporter.h` (one signature, two declarations) |
| probe surface | `tools/probe/r10uvm162repro/` only |


## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **BuildUVMPkg default / testflags** | **321** | **29** | 1 — a **NEW object**, `ref_obj::Actual_group` at `uvm_pkg.sv:14098:35` (§7) |
| SeqDriver default / testflags | 17 | 17 | 1 unchanged, head log BYTE-IDENTICAL |
| SimpleUVM default / testflags | 29 | 29 | 1 unchanged, head log BYTE-IDENTICAL |
| Scoreboard default | 145 | 145 | 1 unchanged, head log BYTE-IDENTICAL |
| MiniAmiq default / testflags | 106 | 106 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 default | 132 | 132 | 1 unchanged, head log BYTE-IDENTICAL |
| Earlgrey_0_1 testflags | 26594 | 26594 | 1 unchanged, head log BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** — both corpora, both modes, against the COMMITTED baselines AND this pass's own pristine sweep; surelog `CMP_NOTEQUAL` stays **10 default + 9 testflags**, uhdm2rtlil stays `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2` | |
| byte movers | — | **3 / 956** surelog — **2 PREDICTED BY NAME** before the patched sweep ran, the third the `Scoreboard/default` COIN, attributed ORDER-BLIND and by a NULL SWEEP (§9) — and **0 / 1358** uhdm2rtlil | |
| the corpus census (3 moved DBs, five row families) | — | **9 cells TOWARD per BuildUVMPkg row, 0 on Scoreboard; WRONG 0, AWAY 0, RESHAPE 0, ONLY-A 0 everywhere** | |
| the whole-dump ORDER-BLIND diff | — | **+154 lines, ALL 154 golden lines VERBATIM; 0 deleted; distance 68022 → 67878 on both BuildUVMPkg rows. Scoreboard +0 / −0** | |
| the grid (7 arms, both views, RHS-narrowed, `--nospan`) | — | **RIGHT 168, TOWARD 130, WRONG 0, STILL 56, AWAY 0, ONLY-G 0, ONLY-A 0** | |
| the ORACLE PROOF | — | **75 golden `ok_`/`bd_` pairs, TWIN 75, NOTTWIN 0** | |
| the WIDE boundary (4593 arms, both views) | — | **MOVED_ARMS 17, RC_DIFFS 0** — 7 are this pass's own positive control, 8 go to **CMP_EQUAL**, 2 move TOWARD, none away | |

Counts are **DEPTH, not distance**: a cmp line count is the HEAD OBJECT'S
decompile size (RESUME.md §7). `Scoreboard/testflags` is `SLANG_REJECT` and
`Rggen/testflags` has no golden — both print SKIP-NOFILE and are COUNTED, never
read as perfection.


---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this worktree's own pristine sweep reproduced the brief
exactly — **BuildUVMPkg default and testflags, 321 cmp lines, 1 head each, and
the two head logs are BYTE-IDENTICAL to each other**
(`head_pris_BuildUVMPkg.default.cmp`).

```
LHS:
decompile:
operation: , id:161051, line:14061:13, endln:14064:70
|vpiParent:
\_assignment: , id:161049, line:14061:7, endln:14064:70
|vpiOpType:33
|vpiOperand:  \_constant: "Factory did not return a "                  14061:14-14061:41
|vpiOperand:  \_ref_obj: (…::create::Tcreator::base_type_name)         14061:43-14061:53
|vpiOperand:  \_constant: " of type '"                                 14061:71-14061:83
|vpiOperand:  \_ref_obj: (…::create::Tregistry::type_name)             14061:84-14061:95
|vpiOperand:  \_constant: "'. A component of type '"                   14062:9 -14062:35
|vpiOperand:  \_operation: vpiOpType 32                                14062:36-14062:78
|vpiOperand:  \_constant: "' was returned instead. Name="              14063:9 -14063:40
|vpiOperand:  \_ref_obj: (…::create::name)                             14063:41-14063:45
|vpiOperand:  \_constant: " Parent="                                   14063:46-14063:56
|vpiOperand:  \_operation: vpiOpType 32                                14064:9 -14064:51
|vpiOperand:  \_constant: " contxt="                                   14064:52-14064:62
|vpiOperand:  \_ref_obj: (…::create::contxt)                           14064:63-14064:69
RHS: <null>
```

Source — `uvm-1.2/src/base/uvm_registry.svh:558-570`, which BuildUVMPkg's
preprocessed `uvm_pkg.sv` carries at `:14055-14065`:

```systemverilog
class uvm_registry_common #(type Tregistry=int, type Tcreator=int, type Tcreated=int);
  static function Tcreated create(string name, uvm_component parent, string contxt);
    uvm_object obj;
    ...
    if (!$cast(create, obj)) begin
      string msg;
      msg = {"Factory did not return a ", Tcreator::base_type_name(), " of type '",Tregistry::type_name,
        "'. A component of type '",obj == null ? "null" : obj.get_type_name(),   // :14062  <- THE TERNARIES
        "' was returned instead. Name=",name," Parent=",
        parent==null?"null":parent.get_type_name()," contxt=",contxt};           // :14064
      uvm_report_fatal("FCTTYP", msg, UVM_NONE);
    end
  endfunction
```

### (1) WHICH `SafeCompare` PRINTED THE NULL — SETTLED BY MEASUREMENT, NOT CARRIED FORWARD

`ct162own` (§ 160's `ct160own`, unchanged) runs the real `design::Compare`,
finds OUR counterpart by kind + span + opType + parent-kind, reads the
enclosing `assignment::Rhs` edge on both sides and then walks
`operation::Compare`'s own field order
(`~/git-repos/UHDM/build/generated/src/operation.cpp:98-129`):

```
operation::Compare field order:
   VpiType      LHS=2251  RHS=2251
   VpiOpType    LHS=33    RHS=33
   VpiReordered / VpiFlattened / VpiOpStrong  equal
-> Operands     LHS=12    RHS=null    [VECTOR overload, RHS NULL -> m_failedLhs = the OWNER]
```

**THE FIELD IS `operation::Operands`, THE VECTOR OVERLOAD, RHS NULL, OWNER = THE
`operation`** — the same arm § 160 decoded, at a site § 160 deliberately
abstained on. Our vector is *null* rather than *empty* because our emitter
stores a present-but-EMPTY vector and the UHDM serializer restores an empty
vector as a NULL one, which is what puts the head on `BaseClass.h:217` rather
than on the size-mismatch arm at `:209`.

---

## 2. THE LAW

> **§ `badConcatCompoundOperands162`** — *inside a concatenation slang rejected,
> golden's object for an operand is FIELD FOR FIELD the object our own BOUND
> path emits for the SAME written operand in a concatenation slang ACCEPTS —
> at every depth. So § `badConcatOperandsFromSyntax160`'s rebuild recurses: a
> **ternary**, a **binary operator** from a measured closed map, a **nested
> concatenation** and a **replication** are admitted operands exactly when
> every one of their sub-operands is itself an admitted shape, recursively; a
> `null` literal and a plain decimal integer literal join the atomic set to make
> that recursion reach the corpus; and parentheses are TRANSPARENT. The rebuild
> stays ALL OR NOTHING, and it stays a SILENT abstention.*

### THE ORACLE, PROVEN AND NOT ASSUMED

Every grid arm writes each cell TWICE inside one generic class: once in a
concatenation slang ACCEPTS (`ok_*`) and once in the SAME concatenation with
one trailing operand slang rejects (`bd_*`). `twin162.py` cuts both out of ONE
database, dedents the `bd_` body (its type-parameter local puts the statement
one `begin` deeper), erases spans and the method name, drops the trailing
operand the `bd_` twin adds, and compares what is left.

```
g162_a_tern    GOLDEN  TWIN=14 NOTTWIN=0
g162_b_shapes  GOLDEN  TWIN=15 NOTTWIN=0
g162_c_opmap   GOLDEN  TWIN=32 NOTTWIN=0
g162_d_fold    GOLDEN  TWIN=14 NOTTWIN=0
```

**75 pairs, TWIN 75, NOTTWIN 0** — in BOTH views. And every `ok_` cell of those
arms is BYTE-IDENTICAL between golden and our PRISTINE binary except the two
package-qualified ones (R-V1, §6). So the recovery has a checkable target that
is not a guess: *produce what our own bound path produces for the same written
expression*, and the arm's `ok_` cell says what that is.

The same instrument run on OUR databases is the cell table: pristine
`TWIN=1/75`, patched `TWIN=52/75`, and **every one of the 22 NOTTWIN cells the
law refuses prints `bd=4 lines` — an ABSTENTION (the empty operand vector),
never a wrongly-minted object** (`TWIN.r10uvm162.txt`; the 23rd, `bd_b15`, is
§ 160's own top-level `::` recovery and is untouched — R-V1).

### THE SHAPES, EACH READ OFF GOLDEN

| written form | golden's object | arm |
|---|---|---|
| `( e )` | **NOTHING** — parentheses are transparent and the inner expression keeps its OWN range (the operand `(prop == "" ? "a" : "b")` is reported 47-69, not 46-70). A ternary whose PREDICATE is parenthesised still spans from the open paren, because that is where its own syntax node starts (46-70, with the `==` inside it at 47-57) | `a3`, `a4` |
| `c ? t : f` | `operation` **vpiConditionOp (32)**, three operands in written order, each parented to it INCLUDING a literal | `a1`-`a14`, `c26`-`c32` |
| `a <op> b` | `operation`, opType from the map below, two operands | `c01`-`c20` |
| `null` | `constant`, **vpiConstType 11** (`vpiNullConst`), decompile `0`, size 64, `UINT:0` | `a1`, `c32` |
| `<digits>` | `constant`, **vpiConstType 9** (`vpiUIntConst`), decompile = the digits, size 64, `UINT:<digits>` | `c27`, `c28` |
| `{ a, b }` | `operation` **vpiConcatOp (33)**, and its OWN direct literals are unparented exactly as the outer one's are | `b3`, `b4` |
| `{ n { a } }` | `operation` **vpiMultiConcatOp (34)** over [the count, the inner CONCATENATION]. A literal count is UNPARENTED, a `ref_obj` count is PARENTED | `b5`, `b6` |

**THE OPERATOR MAP, MEASURED NOT TRANSCRIBED.** `g162_c_opmap.sv` writes one
accepted concatenation per operator; all 32 of its `ok_` cells are
byte-identical between golden and our pristine binary, so the opType is READ
off a database:

```
==  14   !=  15   === 16   !== 17   >   18   >=  19   <   20   <=  21
&&  26   ||  27   &   28   |   29   ^   30   +   24   -   11   *   25
/   12   %   13   <<  22   >>  23
```

**THE PARENTING ASYMMETRY IS GOLDEN'S, AND IT BELONGS TO THE SLOT.** The
top-level concatenation's `"["` carries NO `vpiParent`; the ternary's `"null"`
and the `==`'s `null` both carry one; a nested concatenation unparents its own
direct literals in turn; a replication unparents a LITERAL count but parents a
`ref_obj` one. `badConcatParentConst162` is the one place that decision is
made, keyed on whether the operand sits in a concatenation's own operand slot
(or a replication COUNT) or deeper.

### WHAT IS DELIBERATELY LEFT OUT — each because golden gives it an object this pass has NOT modelled

* a **BARE call** `f()` / `f(args)` — golden's `func_call` (with the argument
  parented to it), a new object KIND minted unbound (`b1`, `b2`, `d10`);
* a **UNARY operator** — golden's opTypes ARE measured (`c21`-`c25`: `!`→3,
  `~`→4, `-`→1, `&`→5, `|`→7) but its LITERAL operand is UNPARENTED where a
  binary's is parented (`d1`, `(i == -1)`), and unary minus over a literal is
  § `negLitPkgRetFoldNested30`'s fold window;
* a call whose **ACTUAL is itself a call** — § `droppedCall14`'s own argument
  predicate refuses those actuals and this law asks that predicate (`b7`);
* a **SIZED / BASED / REAL** literal (`c29`-`c31`: `8'd65` is `DEC:65` size 8
  constType 1, `32'h0000_00FF` is `HEX:000000FF` size 32 constType 5 with the
  `_` stripped, `1.5` is constType 2), a **SYSTEM call** (`d11`), an **INDEX
  SELECT** (`d12`), a **CAST** (`d13`) and `this.<member>` (`d14`).

### GOLDEN DOES NOT FOLD, AND THAT WAS MEASURED BEFORE IT WAS RELIED ON

`g162_d_fold.sv` writes every foldable face the new shapes can reach. Golden
keeps `-1` as an `operation` opType 1 over a constant (`d1`), `1 + 2` as an
`operation` opType 24 over two constants (`d2`), `1 ? "a" : "b"` as a whole
ternary (`d3`), and a LOCALPARAM (`d4`), an UNQUALIFIED package parameter
(`d5`) and a class TYPE PARAMETER (`d8`) as bare `ref_obj`s. The ONE face it
DOES fold is the package-QUALIFIED parameter — R-V1, §6.

### ALL OR NOTHING, AND SILENT

One unmodelled leaf at any depth abstains the WHOLE concatenation:
`operation::Compare` reads the operand vector's SIZE first
(`operation.cpp:126` → `BaseClass.h:207-213`), so a short list only moves the
head from `RHS: <null>` to a size mismatch. The shape pass IS the mint pass
with `mint == false` — every branch's shape test and mint test are the same
expression — and it runs BEFORE anything is minted (serializer GC is off, so an
abandoned object would still reach the database).

**AND NO `noteUnsupportedAt` ON THE WAY OUT**, § 160's measured trap kept:
`unsupportedKinds` is what `uhdm_main` turns into a NON-ZERO EXIT CODE, and
`verify_golden.py` reads a non-zero rc as `SLANG_REJECT`.

---

## 3. THE CHANGE

**`src/ExprEmit.cpp`** — the law, the slang and Surelog citations, the measured
shape table and the operator map, plus:

* `badConcatBinOp162(SyntaxKind)` — the twenty-row measured operator map;
* `plainDecDigits162(const std::string&)` — digits only, nothing else;
* `UhdmExporter::badConcatParentConst162(constant*, BaseClass*, bool direct)` —
  the two constant-parenting decisions in ONE place (§ 160's transcribed
  direct-literal rule, and the ordinary rule every literal arm in the file
  applies), so the recursion cannot drift from the bound path;
* six new branches in `emitBadConcatOperand160` — `null`, a plain decimal
  literal, a ternary, a binary operator, a nested concatenation, a replication
  — and a paren-unwrap at the top;
* the signature gains `bool direct = true, int depth = 0`, so **every existing
  call site is unchanged and the five atomic shapes behave exactly as they did**.

**THE ONE REFUSAL ADDED INSIDE § 160's SHAPE (5), AND WHY IT IS GATED ON
`depth > 0`.** A `::` operand whose first segment names a PACKAGE and whose
final identifier is that package's PARAMETER is one golden CONSTANT-FOLDS
(R-V1). Inside the NEW recursion the law refuses it, because minting a `ref_obj`
there would be introducing an operand measured to be wrong. At the TOP level it
does NOT refuse: that is § 160's landed, gate-verified shape (5), with a
committed verifier cell of its own (`r10v160repro/cells/c05_pkgscope.sv`), and
**a first cut that refused there too was MEASURED to move that arm's head from
28 cmp lines to 79 (def) and 28 to 83 (elab) — an earlier-pass arm moving AWAY
from golden, which is a fail condition (RESUME.md §7).** With the gate the arm
is 28/28 in both views and byte-identical.

**`include/UhdmExporter.h`** — the signature, its documentation, and the
`badConcatParentConst162` declaration.

**Nothing else changed.** When the law abstains, § 160's unwrap still stands
and the object is byte-for-byte what it is today — which is what the 0/1358
uhdm2rtlil byte gate and the 4576 unmoved boundary arms measure.

**FENCES (all measured, all must-stay):** § 160's LVALUE fence (`inLhs`), its
NON-EMPTY bad-concat-child fence, its `classArgBind12` window, its DIRECT-literal
parenting transcription, and § `droppedCall14` / § `droppedIdxRecvCall26` /
§ `invalidNewCallFromSyntax55` / § `typeParamScopedCallRef59`'s predicates —
none touched.

---

## 4. THE PREDICTION, MADE FROM THE PRISTINE DATABASES BEFORE ANY PATCHED ONE EXISTED

`predsweep162.sh` + `predjoin162.py` census BOTH pristine sides of every row of
a `verify_golden` workdir and print every cell whose golden side is PRESENT and
ours ABSENT or TRUNCATED, plus the mirror buckets.

```
surelog    : rows=956  SKIP-NOFILE=617  PRED-TOWARD 2  PRED-AWAY 0  PRED-TRUNC 0  PRED-GROW 14
uhdm2rtlil : rows=1358 SKIP-NOFILE=104  PRED-TOWARD 0  PRED-AWAY 0  PRED-TRUNC 0  PRED-GROW  0
```

**The corpus population of the shapes § 160 left unmodelled is EXACTLY 2 CELLS
— which is what § 160's own prediction said and what this sweep independently
re-measures.** Both are the same site in the same database, in both modes:

```
default/BuildUVMPkg-bf853d43/    PRED-TOWARD-OP  ELABPKG
    uvm_pkg::uvm_registry_common::create  14061:13-14064:70  op33
    G = 12 operands: constant, ref_obj, constant, ref_obj, constant, OPERATION,
        constant, ref_obj, constant, OPERATION, constant, ref_obj
    O = NULL operand vector (-1)
testflags/BuildUVMPkg-bf853d43/  (the same cell)
```

`predmovers162.py` splits them on GOLDEN's own operand kind list and gives
**RECOVER 2 / ABSTAIN 0** and this **mover set, BY NAME**:

```
MOVER default/BuildUVMPkg-bf853d43
MOVER testflags/BuildUVMPkg-bf853d43
```

i.e. **2 databases on surelog, 0 on uhdm2rtlil**. The predicate is optimistic
about an `operation` operand — whether ITS sub-operands are admitted cannot be
read off a top-level kind list — so both cells were checked BY HAND against
golden's own dump first: each is `vpiOpType 32` over [`operation` `vpiOpType 14`
over [`ref_obj`, `constant` constType 11], `constant` constType 6, `hier_path`],
every leaf an admitted shape.

**THE REFUSAL'S OWN PREDICTION — that it removes NOTHING — is a measurement
too.** Censusing our PRISTINE databases for every `::`-qualified `ref_obj`
inside any `operation`, over BuildUVMPkg, SimpleUVM, SeqDriver, MiniAmiq and
Scoreboard, returns only CLASS and TYPE-PARAMETER qualifiers —
`uvm_config_db::get`, `process::KILLED`, `uvm_policy::FINISHED`,
`TYPE::type_name`, `comp_type::comp`, `this_super_type::m_t_inst`, … — and
**not one `<package>::<parameter>`**. The only package in these designs is
`uvm_pkg`.

`byteverify.sh --selfcheck` then measured **MOVERS 3 / 956** on surelog and
**0 / 1358** on uhdm2rtlil: the two predicted, plus `default/Scoreboard`, which
is RESUME.md §9's known ~50/50 coin and is attributed in §9 below — not by a
hash, but order-blind and by a null sweep.

`PRED-GROW`'s 14 cells are `uvm_report_fatal` / `uvm_report_warning`'s
DEFAULT-ARGUMENT filling (§ 160's R4), byte-identical here.

---

## 5. THE GRID — 7 ARMS, BOTH VIEWS, JUDGED THREE WAYS

`grid162.sh` builds Surelog's golden, our pristine and our patched database for
each arm in BOTH views, echoes every command into the arm's own `cmds.txt` with
its binary PATH and its own `rc=` line, and puts the OFFICIAL `uhdm-cmp` on
both of ours.

| arm | what it varies |
|---|---|
| `g162_a_tern.sv` | THE TERNARY, field by field: the corpus shape spaced and unspaced, a parenthesised predicate, a parenthesised whole ternary, a bare-identifier predicate, `!=`, each of the three positions holding a dotted call / a bare identifier / a `::` name, a nested ternary in the FALSE arm and in the PREDICATE, a package-qualified arm, TWO ternaries in one concatenation, a literal on the LEFT of the comparison, and an accepted-only control |
| `g162_b_shapes.sv` | THE OTHER FOUR unmodelled shapes of § 160's R1 plus the sub-operand kinds a ternary can hold: bare call with and without arguments, nested concat, nested concat holding a ternary, replication with a constant and with a parameter count, a call whose actual is a call, an integer literal, a unary `!`, three more operators, a dotted name and a `::` name as ternary arms, and the package-qualified operand |
| `g162_c_opmap.sv` | THE OPERATOR MAP: twenty binary and five unary operators, one accepted concatenation each, plus the plain-decimal / sized / based / real / `null` literal faces |
| `g162_d_fold.sv` | THE FOLD TRAPS: `-1`, `1 + 2`, a constant-predicate ternary, a localparam, an unqualified package parameter, a package-QUALIFIED parameter in a ternary arm and in a replication count, a type parameter, a nested concat in a ternary arm, a bare call in a ternary arm, a system call, an index select, a cast, `this.prop`, and the reduced corpus witness |
| `g162_e_context.sv` | WHERE THE REJECTED CONCATENATION SITS: assignment Rhs, concat operand, call argument, return value, system-call argument, `if` condition, ternary arm, an LVALUE concat control, a bad concat followed by a good one, two rejected concats in one method, and a rejected concat inside a rejected concat |
| `g162_f_home.sv` | WHERE IT LIVES: in-body method, out-of-body method, task, static method, two type parameters — plus the two CONTROLS that must not move (a generic class whose default argument is a REAL class, and a NON-parameterized class) and ONE, TWO and THREE explicit specializations beside the default in one database |
| `g162_g_witness.sv` | THE REDUCED CORPUS WITNESS — `uvm_registry.svh:558-570` |

Arm F carries its own fence, and it is the § 160 lesson repeated: an EXPLICIT
`#(int)` specialization makes SLANG REPORT the bad member access, and a
reported error is `SLANG_REJECT` — out of scope by decision. A first cut of the
arm wrote `holdf162 #(int) i3;` and our own binary exited 3. **An arm our own
tool refuses is not an arm that measures anything**, so the explicit
specializations use a type argument that DOES carry the method.

### THE OFFICIAL JUDGE ON EVERY ARM (`GRID.cmp.r10uvm162.txt`)

```
arm              view  pristine        patched
g162_a_tern      def   161 / 1 head    32 / 1     (head = R-V1's folded pkg param on the ACCEPTED twin, §6)
g162_a_tern      elab  177 / 1          36 / 1
g162_b_shapes    def    77 / 1          77 / 1    (head = bd_b1, a BARE call — abstained by design)
g162_b_shapes    elab   85 / 1          85 / 1
g162_c_opmap     def   143 / 1         131 / 1    (head = c21, a UNARY `!` — abstained by design)
g162_c_opmap     elab  155 / 1         139 / 1
g162_d_fold      def    18 / 1          18 / 1    (head = the arm's own `localparam int` typespec, unrelated and unchanged)
g162_d_fold      elab   18 / 1          18 / 1
g162_e_context   def   161 / 1        **0 / 0  CMP_EQUAL**
g162_e_context   elab  177 / 1        **0 / 0  CMP_EQUAL**
g162_f_home      def   161 / 1          17 / 1    (a NEW object: golden's `logic_net work@topf162.bh`, pre-existing, unmasked)
g162_f_home      elab  165 / 1        1449 / 1    (a NEW object: an ONLY-OURS `class_defn`; DEPTH, not distance)
g162_g_witness   def   321 / 1        **0 / 0  CMP_EQUAL**
g162_g_witness   elab  353 / 1        **0 / 0  CMP_EQUAL**
```

**The witness reproduces the corpus head EXACTLY — 321 cmp lines, the same
number the corpus rows report — and `uhdm-cmp` judges the patched database
EQUAL in BOTH views.** Every arm's residual head is named above, and each is
either a deliberately-abstained shape or a pre-existing residue at another
object.

### THE ORDER-BLIND WHOLE-DUMP DISTANCE (`GRID.dist.r10uvm162.txt`)

**All 14 arm-views TOWARD, none AWAY**, e.g. `g162_g_witness` 158 → 4 (def) and
280 → 4 (elab), `g162_e_context` 953 → 110 and 1976 → 462, `g162_a_tern`
1245 → 216 and 2506 → 662.

### THE THREE-WAY CELL SCORE (`armscore162.py`, `GRID.scorerhs.r10uvm162.txt`)

Narrowed to the assignment `vpiRhs` — the object this law builds — and
`--nospan`, because no generated `Compare` reads `VpiLineNo`/`VpiColumnNo`
(RESUME.md §9) and the whole-method slice otherwise carries r10uvm158's
block-span residue and, in the ELAB view, golden's own shared `ref_typespec`
actual, both at other objects:

```
RIGHT=168  TOWARD=130  WRONG=0  STILL=56  AWAY=0  ONLY-G=0  ONLY-OURS=1  ONLY-A=0
```

* **`WRONG = 0`** — no cell that was right pristine is wrong patched.
* **`AWAY = 0`** — nothing changed and stayed wrong.
* **`ONLY-A = 0`** — nothing was deleted.
* The whole-method score with spans included is in `GRID.score.r10uvm162.txt`;
  its larger `AWAY` column is entirely the two span residues above, which the
  judge cannot see and which `--nospan` removes.
* **arm E is the CONTEXT result**: every one of its bad-concat contexts
  recovered and the arm is judged **CMP_EQUAL**; its LVALUE control `e8` never
  moved.
* **arm F's two controls stayed RIGHT** and all five generic homes recovered,
  with one, two and three explicit specializations in the database beside the
  default one.

---

## 6. THE RESIDUES THIS PASS DOES NOT CLOSE (each MEASURED, none guessed)

**R-V1 — golden CONSTANT-FOLDS a PACKAGE-QUALIFIED PARAMETER, and our BOUND
path does not.** Measured on the ACCEPTED twin, so it is not a property of the
recovery at all:

```
ok_b15:  sres = {"[", pb162::PKGP162, "]"};
  GOLDEN  \_constant: 63:47-63:61  |vpiDecompile:pp  |vpiSize:16  |STRING:pp  |vpiConstType:6
  OURS    \_ref_obj: (pb162::holdb162::ok_b15::PKGP162) 63:47-63:61  |vpiName:PKGP162
```

The same disagreement appears in `ok_a12`, in a ternary arm (`ok_d6`) and in a
replication count (`ok_d7`). **Both columns, scored explicitly:**

| cell | pristine | patched |
|---|---|---|
| `bd_b15` — a `::` operand at the TOP level | § 160 RECOVERS it, minting the `ref_obj` | **unchanged** (the refusal is gated on `depth > 0`) — `STILL`, not `AWAY` |
| `bd_a12`, `bd_d6`, `bd_d7` — a `::` operand INSIDE a new compound shape | abstained | **abstained** — the refusal keeps them there rather than minting a `ref_obj` golden folds |
| corpus cells of either kind | **0** | **0** |

The grid's `AWAY` column is **0** as a result. Closing R-V1 properly means
modelling the fold, which is § `stampFoldedPkgParamTs`'s family and a different
law.

**R1 — four operand shapes are still not modelled, and the law abstains on the
WHOLE concatenation when it meets one.** All 22 remaining `bd_` abstentions are
exactly these, and each prints an EMPTY operand vector, never a wrong object: a
BARE call (`b1`, `b2`, `d10`), a UNARY operator (`b9`, `c21`-`c25`, `d1`), a
call whose ACTUAL is a call (`b7`), a SIZED/BASED/REAL literal (`b8`,
`c29`-`c31`), and — outside the family — a SYSTEM call (`d11`), an INDEX SELECT
(`d12`), a CAST (`d13`) and `this.<member>` (`d14`). **Corpus cost: 0 cells**
(§4's sweep finds no other bad concat in either corpus).

**R2 — a rejected concatenation still loses its SPAN when it is a macro
ARGUMENT**, § 160's R2 unchanged; DUMP-ONLY, and `uhdm-cmp` never reads a span.

**R3 — a rejected block still loses its own span and its type-param local's
`int_typespec` span**, r10uvm158's R1/R3 unchanged. It is the WHOLE difference
between golden's and our patched `bd_a1` slice: four lines, all spans.

**R4 — `uvm_report_fatal` / `uvm_report_warning` still get 7 arguments where
golden gets 5.** Pristine `PRED-GROW`, 14 cells, byte-identical after this pass.

**R5 — our elaborated `set_type_alias` OVER-BINDS an argument ref**; that is
R0, §7, and it is PRE-EXISTING (the pristine database has it too).

---

## 7. THE NEXT HEAD (R0)

BuildUVMPkg default and testflags, **29 cmp lines, 1 head each, the two logs
BYTE-IDENTICAL** (`head_pat_BuildUVMPkg.default.cmp`):

```
LHS: <null>
RHS:
decompile:
io_decl: (alias_name), id:86640, line:14091:46, endln:14091:56
|vpiParent:
\_function: (uvm_pkg::uvm_registry_common::set_type_alias), line:14091:3, endln:14091:9
|vpiDirection:1
|vpiName:alias_name
|vpiTypespec: \_ref_typespec -> \_string_typespec @14091:39-14091:45
```

**THE OWNER IS ALREADY NAMED, and it is not the `io_decl`.** `LHS: <null>` with
a full RHS is the SINGULAR overload's MIRROR (`BaseClass.h`), which names OUR
VALUE; the edge is **`ref_obj::Actual_group`**, and the two sides are:

```
uvm_pkg.sv:14098   factory.set_type_alias(alias_name, rgtry);
GOLDEN  \_ref_obj: (uvm_pkg::uvm_registry_common::set_type_alias::alias_name) 14098:35-14098:45
          |vpiName:alias_name  |vpiFullName:…::alias_name        <- NO vpiActual
OURS    \_ref_obj: (…::set_type_alias::alias_name)               14098:35-14098:45
          |vpiName:alias_name  |vpiFullName:…::alias_name
          |vpiActual: \_io_decl: (alias_name) 14091:46-14091:56  <- WE BIND IT
```

**We OVER-BIND.** The distinguisher is inside the same method and is therefore
sharp: golden DOES bind the same formal at `:14092`
(`m__type_aliases.push_back(alias_name)`, a method call on a class PROPERTY at
the function's top level) and does NOT bind it at `:14098` (a method call on a
LOCAL handle, inside a `begin` block inside a nested `if`). The next pass must
decide which of those two differences carries the rule — the receiver's kind, or
the statement's nesting — on an arm that separates them.

It is **PRE-EXISTING**: our pristine BuildUVMPkg database carries the identical
`vpiActual` at `14098:35`; this pass only removed the bigger head in front of it.

---

## 8. THE CORPUS CENSUS AND THE WHOLE-DUMP DIFF — 3 MOVED DATABASES

`scoreall162.sh` censuses golden, our pristine and our patched database for each
moved row and scores every OP / ASGN / ARG / COND / HP cell
(`CENSUS.r10uvm162.txt`). Identical on both BuildUVMPkg rows:

| family | RIGHT | TOWARD | WRONG | STILL | RESHAPE | AWAY | ONLY-A |
|---|---|---|---|---|---|---|---|
| OP | 5949 | **5** | 0 | 43 | 0 | **0** | 0 |
| ASGN | 4703 | 0 | 0 | 3 | 0 | 0 | 0 |
| ARG | 9449 | **2** | 0 | 0 | 0 | **0** | 0 |
| COND | 5911 | 0 | 0 | 0 | 0 | 0 | 0 |
| HP | 4652 | **2** | 0 | 0 | 0 | **0** | 0 |

The **5 OP** cells are the outer concatenation plus the two ternaries and the
two `==` operations; the **2 HP** are `obj.get_type_name` and
`parent.get_type_name`; the **2 ARG** are those two calls' argument lists.
`default/Scoreboard` scores **TOWARD 0 / WRONG 0 / AWAY 0 / ONLY-A 0 in every
family** — the coin moved no cell.

**THE ORDER-BLIND WHOLE-DUMP DIFF** closes the attribution
(`DUMPDIFF.r10uvm162.txt`):

```
row                     added  deleted   order-blind distance to golden
default/BuildUVMPkg      +154       -0     68022 -> 67878    TOWARD
testflags/BuildUVMPkg    +154       -0     68022 -> 67878    TOWARD
default/Scoreboard         +0       -0    119951 -> 119951   SAME
```

**ZERO deleted lines on every row, and ALL 154 added lines are GOLDEN LINES
VERBATIM.** (The multiset total rises by 5 rather than 0 because four
`|vpiSize:64` labels and one `|vpiActual:` label now appear at an indent whose
count golden does not match — dump label lines, not objects.)

---

## 9. THE THIRD BYTE MOVER, ATTRIBUTED — NOT EXCUSED

`default/Scoreboard` moved bytes and is **not** this law. RESUME.md §9 names it
in advance: Scoreboard/default is a ~50/50 COIN per invocation (the svunit_pkg
`vpiTaskFunc` list ORDER flip, ~92 dump lines, from macro-buffer
`SourceLocation` ordering under slang's PARALLEL parse). Three independent
measurements say so here:

* **order-blind whole-dump diff, pristine vs patched: 0 lines** (94 raw). The
  two databases hold the same objects with the same fields in a different order.
* **the census over OP / ASGN / ARG / COND / HP: TOWARD 0, WRONG 0, AWAY 0,
  ONLY-A 0** — not one cell moved.
* **a NULL SWEEP.** Run serially from the test's own directory, three times per
  binary, the PATCHED binary reproduces the PRISTINE database BYTE FOR BYTE:

```
pristine  x3  ->  86a9fa4fd934  86a9fa4fd934  86a9fa4fd934
patched   x3  ->  86a9fa4fd934  86a9fa4fd934  86a9fa4fd934
```

  `86a9fa4fd934` is the hash the pristine SWEEP also produced; the patched
  sweep's `eb2a3e30c551` is the coin's other face, and it appears only under
  `--jobs 2` load. Its head log is byte-identical to the pristine one (145 cmp
  lines, 1 head) either way.

---

## 10. THE GATES

All green; the full battery with its numbers is `GATES.r10uvm162.txt`. In one
line: goldens **23/0** on both binaries and `/bin/false` **0/23**; uhdm2rtlil
**679/50/2** both modes with **0 differing rows** against BOTH the committed
baseline and this pass's own pristine sweep, and **0/1358 byte movers**;
surelog **0 differing rows over 1588** against both, with **3/956 byte movers,
2 predicted by name and the third attributed in §9**; every one of the 2981
pristine and 2981 patched `cmds.txt` command lines audited BY BINARY PATH
(`/tmp/r10uvm162_pris.bin`, `/tmp/r10uvm162_pat.bin` — never the main tree's);
canaries **52/8 ok, 0 changed**, `ctcan2` PASS both corpora, `canaudit`
**audited=29 UNCOVERED=0 FENCE-BREACH=0**; the six protected databases
byte-identical with `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on
their pins; the wide boundary **LISTED=4593 PROCESSED=4593 PRODUCED_DBS=4441
MOVED_ARMS=17 RC_DIFFS=0**, seven of the seventeen being this pass's own
positive control and the other ten all r10uvm160/r10v160 cells of its own R1
residue — **eight go to CMP_EQUAL** (`g160_e_edge`, `o04_paren`, `o05_ternary`,
`o06_nestcat`, `o08_repl`, `o10_binary`, `y10_nestgood`, `d10_repl`) and **two
move TOWARD** (`g160_b_operand` 260→150 / 524→339, `v160_d_ctx` 290→214 /
585→453). None moves away.

**NO CORPUS ROW CONVERTED.** `CMP_NOTEQUAL` stays 10 (default) + 9 (testflags)
on surelog; `results/*.csv` were read only.

---

## 11. FILE MAP

| file | what it is |
|---|---|
| `g162_a_tern.sv` … `g162_g_witness.sv` | the seven grid arms |
| `grid162.sh` | the arm driver — three databases per view, `cmds.txt` with binary PATH and rc, and the OFFICIAL `uhdm-cmp` on both of ours |
| `slice162.py` | cuts a `uhdm-dump` into one slice per class METHOD and compares two sides cell by cell |
| `twin162.py` | THE ORACLE PROOF — is a rejected concatenation's operand its accepted twin's object? Run on golden it proves the oracle; run on ours it is the cell table |
| `armscore162.py` | the three-way cell score (RIGHT / TOWARD / WRONG / STILL / AWAY / ONLY-G / ONLY-OURS / ONLY-A), `--nospan`, `--rhs` |
| `dist162.sh` | the order-blind whole-dump distance to golden, pristine vs patched, per arm and view |
| `ct162cen.cpp` | the census — one row per `operation`, `assignment`, call, condition-bearing statement and `hier_path` |
| `ct162own.cpp` | the OWNER-FINDER — runs the real `design::Compare` and walks `operation::Compare`'s own field order |
| `predsweep162.sh`, `predjoin162.py`, `predmovers162.py` | the a-priori prediction from the PRISTINE databases only, and the RECOVER/ABSTAIN split that names the mover set |
| `scoreall162.sh`, `score162.py` | the corpus census over the moved rows |
| `dumpdiff162.sh` | the whole-dump, path-normalised, ORDER-BLIND diff |
| `bound162.sh` | the wide boundary gate |
| `rowheads.sh`, `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing instruments, copied unchanged |
| `head_pris_*.cmp`, `head_pat_*.cmp` | the official `uhdm-cmp` head logs for all seven named rows, both modes, on this worktree's own pristine and patched sweeps |
| `PREDICT.r10uvm162.txt`, `CENSUS.r10uvm162.txt`, `DUMPDIFF.r10uvm162.txt`, `TWIN.r10uvm162.txt`, `GRID.*.r10uvm162.txt`, `BOUNDARY.r10uvm162.txt`, `GATES.r10uvm162.txt` | the measurements |
