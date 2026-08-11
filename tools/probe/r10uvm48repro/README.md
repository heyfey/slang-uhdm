# r10uvm48 — UVM pass 48

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours. Every `uhdm-cmp` invocation
in this pass is `uhdm-cmp <golden.uhdm> <ours.uhdm>`, never the other way round.**

**TWO laws. ZERO conversions. The `uvm_comparer.svh:156` head the brief put in
front of three tests is GONE on all three, and the head it walked to is the SAME
LAW AS `BuildUVMPkg`'s — so where pass 47 handed forward one law in front of
THREE tests, this pass hands forward ONE LAW IN FRONT OF ALL FOUR.**

| | HEAD `e0ad2b2` (re-measured, not inherited) | after laws 1+2 |
|---|---|---|
| `SeqDriver` full cmp, both modes | **38 lines**, md5 `58763907ba9b` | **50 lines**, md5 `d0133c2a250a` |
| `SimpleUVM` full cmp, both modes | **38**, md5 `58763907ba9b` | **50**, md5 `94e68124ad89` |
| `Scoreboard` full cmp, default | **38**, md5 `58763907ba9b` | **50**, md5 `8b6c80911ce8` |
| `BuildUVMPkg` full cmp, both modes | **50**, md5 `65e682317a01` | **50**, md5 `65e682317a01` — byte-identical |
| the head object | `ref_obj uvm_object::__m_uvm_status_container` vs our `method_func_call 'scope'` | **`class_typespec uvm_pkg::uvm_id_verbosities_array` + `vpiTypedefAlias` — `BuildUVMPkg`'s law** |
| verdict, all four, both modes | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` |

md5s are of the id-normalised cmp output (`sed 's/id:[0-9][0-9]*/id:N/g'`,
`headmd5.sh`). Heads are counted with `grep -c '^LHS:'` at COLUMN 0: **every run
in this pass printed `heads=1`**, confirming the master's own correction that
uhdm-cmp reports exactly ONE head per run. The brief's two md5s
(`58763907ba9b`, `65e682317a01`) both reproduced exactly; `Scoreboard,testflags`
is `SLANG_REJECT` with no database, exactly as briefed.

Binaries: HEAD `d1b37c08f7555f844a3ea4e7f5b96bdc` (built from pristine `e0ad2b2`
in this worktree), laws 1+2 **`c2ac2753c23d4e7e7163d8ac9670eb33`** (the SHIPPED
one). An earlier cut, `f3df096c832da786bf0b652a94625a35`, passed all four gates
and the byte verifier too, and then `t67e` I4 found a real defect in law 2 that
only the parent gate fixes (§ 2) — so **every gate was re-run on the shipped
binary** and both sets of numbers are reported. A comment-only edit between the
two rebuilds left the md5 BIT-IDENTICAL (`f3df09…` twice), which is how I know
the gate numbers belong to the source that shipped.

## 0. WHERE THE HEAD ENDED UP — the most useful line in this handoff

The three tests **still share one law**, and it is now the SAME law as the fourth
test's:

    (SPANS BELOW ARE AS SeqDriver/SimpleUVM/Scoreboard SPELL THEM, i.e. the
     uvm-1.2 sources. BuildUVMPkg is the SAME LAW at DIFFERENT LINES: its head is
     line:30449:9 endln:30449:17 and its RHS line:30483:3 endln:30483:27, in
     1800.2-2017-1.0/pp_output/uvm_pkg.sv. Corrected by the pass-48 verifier —
     the original block printed the uvm-1.2 numbers for all four containers.)
    LHS(golden)  class_typespec (uvm_pkg::uvm_id_verbosities_array) @29:9-29:17
                 vpiParent = the IMPORTING CONTAINER
                   SeqDriver   -> module_inst work@top_tb   (vpiInstance = package adpcm_pkg)
                   SimpleUVM   -> class_defn  work@env      (vpiInstance = package uvm_pkg)
                   Scoreboard  -> class_defn  work@my_scoreboard (vpiInstance = package uvm_pkg)
                   BuildUVMPkg -> the PACKAGE itself        (vpiInstance = package uvm_pkg)
                 vpiName uvm_pkg::uvm_id_verbosities_array,
                 vpiTypedefAlias -> ref_typespec (<container>.uvm_pkg::uvm_id_verbosities_array)
                   -> vpiActual class_typespec (uvm_pkg::uvm_id_actions_array) ALSO @29:9-29:17,
                 vpiClassDefn = class_defn uvm_pkg::uvm_pool
    RHS(ours)    class_typespec (uvm_pool) @62:3-62:27, vpiParent = the CLASS_VAR
                 uvm_pkg::uvm_report_handler::id_verbosities, vpiName uvm_pool

So the brief's RANKED #2 has grown from "part of one test" to **all four tests**,
and it has grown a second half: golden publishes that alias chain not only in the
PACKAGE (`src/ParamEmit.cpp:19040-19070`, which already builds exactly this
shape) but in every IMPORTING CONTAINER — a module and a class here. That is
residue item 1 in § 5, and it is why I did not start it with the budget left: it
is a listing law across three container kinds, not a patch to the existing block.

## 1. § staticScopedChainDrops48 — direction: REPLACE

`src/ExprEmit.cpp` (`scopedChainRootName48`, `scopedChainDropBase48`,
`scopedChainDropRef48`, new, next to § staticScopedRef12's helpers; hooked ahead
of `emitExpr`'s whole dispatch), `include/UhdmExporter.h`.

**A `::`-WRITTEN reference standing at the base of a `.member` / select /
`.method(...)` CHAIN collapses to the bare ref_obj that reference alone would
produce, and the WHOLE tail — members, selects, the call and every argument — is
DISCARDED. Wherever it stands.** Name = FIRST written segment `::` FINAL `::`
identifier (intermediate segments dropped); span = the scoped name's start up to
(NOT including) that final identifier; UNBOUND.

This is the CLASS-SCOPE half of a collapse this emitter already documents for a
package-qualified variable (`isPkgQualifiedVarRef`, r10apb3 repro 10), and it is
an EXTENSION of § staticScopedRef12 — same object, same naming convention, one
new position — not a parallel law. § staticScopedRef12 did not fire at the corpus
site because it reads the BASE SUB-EXPRESSION's syntax and **slang leaves a
chained base's `syntax` NULL** (§ 3 — the first cut of this law reached NOTHING
because of it, measured, not guessed).

### THE DECIDER: statement rule or expression rule

The corpus site is a STATEMENT and cannot tell them apart. `t67a` C5/C6/C10 and
`t67b` D8 / `t67d` H7 / `t67c` G7 put the SAME chain in five other positions:

| position | cell | golden (LHS) |
|---|---|---|
| whole STATEMENT (the corpus shape) | C1 | `ref_obj base67::stat`@73:7-73:15 as the function's `vpiStmt` |
| operand of `+ 1` | **C5** | `operation(24)`@85:11-49 whose operands are `ref_obj base67::stat`@85:11-**19** and `constant 1` — **the surrounding expression SURVIVES** |
| whole assignment Rhs | C6 | `ref_obj`@88:11-19 |
| `$display` argument | C10 | `ref_obj`@100:23-31 |
| USER call argument | H7 | `ref_obj`@66:12-20, **unbound even inside § classArgBind12's window** |
| `if` CONDITION | D8 | `ref_obj`@101:11-19 under `operation(18)` |
| CONTINUOUS ASSIGN Rhs | G7 | `ref_obj q67::qs`@111:16-21 |

**EXPRESSION RULE.** Hence the hook sits ahead of `emitExpr`'s dispatch, not in
the statement emitter. Reader context is irrelevant: class method (C1..C14),
package function (C15), module initial (C16/G8), module function (H8) all
collapse, and a TASK call collapses like a function call (H10).

### THE GATES, each named by the cell that fails without it

| gate | cell | golden (LHS) | what happens without the gate |
|---|---|---|---|
| the reference must be WRITTEN with `::` | **G9** `stat.scope.set_arg(nm)` — the IDENTICAL chain, unqualified, from inside the declaring class | `method_func_call 'scope'`@71:12-17 with `vpiPrefix ref_obj 'stat'`@71:7-11 — the full shape, which we already emit | every class-static receiver in the corpus collapses; this is the must-not-move control and it is the whole reason the law keys on SYNTAX |
| a CLASS-scoped referent collapses whatever its KIND | C1 (static class handle), **G3** (`base67::LPARR[1]`, a class LOCALPARAM), E1 (a static array), G10b (a class ENUM member) | all `ref_obj first::last`, qualifier-only span | narrowing to "static variable" would leave the localparam and array halves wrong |
| a package VARIABLE collapses | C12/C13/C14 (inside its own package), E3/E4/E5, G4/G7 (from outside) | `ref_obj p67::pkgh` / `p67::pstruct` / `q67::qs` | — |
| **a package PARAMETER must NOT** | **G1** `p67::PCFG.a` (struct member), **E2** `p67::PARR[1]` | golden keeps a RESOLVED `hier_path`/`bit_select` **bound to the parameter** | a `pkg::PARAM.field` / `pkg::PARAM[i]` read is everywhere in the synthesisable corpus; collapsing it would be a mass regression |
| **a package ENUM CONSTANT must NOT** | **G10a** `p67::E1.name()` | golden FOLDS it to `constant UINT:1`@95:11-14 and drops the chain | we would emit a ref_obj where golden has a constant — the fold is a DIFFERENT law (residue 3) |
| there must be at least ONE step | C11 `y = base67::sint;`, D6 `p67::base67::sint` | unchanged `ref_obj base67::sint`@103:11-19 | the bare case is § staticScopedRef12's own arm and is already correct |
| a call with a NULL `thisClass` is not a chain | **D1/D2** `p67::pf67(nm)` (package FUNCTION), **D3/D4** `base67::sfunc()` (STATIC METHOD) | `func_call p67::pf67` with its bound argument / `ref_obj base67::sfunc` — **all four already equal at HEAD** | the natural "the syntax is a ScopedName" implementation swallows every package function call in the corpus |

The package half is keyed on **the first written segment being the declaring
package**, NOT on `isPkgQualifiedVarRef`, whose extra `pkgViewVarObjs9` gate
("inside the declaring package the name is written bare and resolves") is
**REFUTED for a chain**: C12/C13/C14 and E4/E5 write `p67::pkgh…` INSIDE `p67`
and golden collapses them exactly as it does from outside (G4). The BARE
qualified read inside the declaring package (G6) is a separate, cmp-VISIBLE
residue and is deliberately NOT touched here (§ 5 item 4).

When the base IS `isPkgQualifiedVarRef`, the collapse re-emits the base
expression so it keeps the object that landed law already builds — including the
`vpiActual` golden binds in a module (G7). Only the class-scope and
in-declaring-package cases mint, and they mint § staticScopedRef12's object.

## 2. § staticScopedLvalueBad48 — direction: REPLACE

`src/ExprEmit.cpp` (`scopedLvalueBadRef48`, new; called from the § 1 hook and
from inside the § staticScopedRef12 arm), `include/UhdmExporter.h`.

**As an assignment TARGET, a `::`-written reference is named FIRST-SEGMENT
`::@@BAD_SYMBOL@@` and spans the WHOLE written lvalue** — not the qualifier-only
span the READ form takes.

`t67d` H1 is the cell that decided this is a property of LVALUE-NESS and not of
the chain, and it exposes **an unmeasured half of § staticScopedRef12 itself**.
The law has ONE gate, and `t67e` I4 is what named it: **the placeholder reaches
only the object the assignment hangs its `Lhs` on** (`assignTargetParent48` —
parent is `assignment` / `assign_stmt` / `cont_assign`). `inLhs` stays true for
the whole lvalue subtree, so without that gate a `::`-rooted chain sitting in
ANOTHER lvalue's INDEX (`arr[base67::stat.hval] = 3;`) was renamed too, where
golden puts the plain READ form (§ 6a). That defect shipped in the first cut and
**all four gates and the byte verifier were green on it** — only the arm cell
caught it.

| cell | source | golden (LHS) | ours at HEAD | ours POST |
|---|---|---|---|---|
| **H1** | `base67::sint = 3;` BARE, no chain | `ref_obj base67::@@BAD_SYMBOL@@`@54:7-**19** (the whole name) | `ref_obj base67::sint`@54:7-15 — **a cmp-VISIBLE wrong VpiName** | golden |
| H3 | `base67::sbits[1] = 1'b1;` select | `base67::@@BAD_SYMBOL@@`@60:7-23 | `bit_select 'sbits'`@60:7-23 | golden |
| C9 | `base67::stat.hval = 3;` chain | `base67::@@BAD_SYMBOL@@`@97:7-24 | `hier_path 'stat.hval'` | golden |
| D7 | `base67::stat.scope.sub.depth = 4;` deep chain | `base67::@@BAD_SYMBOL@@`@98:7-35 | `hier_path` 4 elems | golden |
| E5 | `p67::pstruct.a = 5;` package struct | `p67::@@BAD_SYMBOL@@`@120:7-21 | `hier_path 'pstruct.a'` | golden |
| H2 (control) | `q67::qi = 3;` package var, bare | `q67::@@BAD_SYMBOL@@`@57:7-14 | name already right (landed pkg arm) | unchanged |
| H4 | `q67::qh.hval = 3;` package chain | `q67::@@BAD_SYMBOL@@`@63:7-**19** | name right, span 63:7-14 | golden |

The READ form of the same declarations keeps `first::last` over the qualifier
alone (C11/H1's read twin), so the two forms are measured against each other on
one golden, not asserted.

## 3. REFUTATIONS AND CORRECTIONS

1. **The brief's "THE ARM TO BUILD FIRST … decides whether golden's rule is a
   STATEMENT rule or an EXPRESSION rule" — answered: EXPRESSION rule**, and by a
   wider margin than the r-value cell alone (7 positions, § 1). A statement-rule
   implementation would have been wrong in six of them.
2. **The brief's reading of the head is CONFIRMED in every detail I could check**
   — the qualifier-only span (`uvm_object::`, 12 characters, cols 7..18), the
   full-member-path name, the `begin` parent, and "§ staticScopedRef12 already
   produces exactly this shape". Both head md5s reproduced. Nothing in the
   brief's § 1 needed correcting.
3. **But "Find why staticScopedRef12 does not fire here" has a mechanical answer
   the brief could not have known: slang leaves a CHAINED base sub-expression's
   `syntax` NULL.** Every `steps>=1` base in `t67a` printed `syn=-1` under a
   temporary debug counter. The first cut of law 1 asked
   `scopedNameSyntax12(base->syntax)` — the same question § staticScopedRef12
   asks — and therefore **reached nothing and measured zero**, on an arm where
   golden and ours differ in 339 dump lines. It is the brief's own "A FIX THAT
   REACHES NOTHING MEASURES ZERO AND READS AS A REFUTATION" trap, and the only
   thing that caught it was re-running the arm rather than the corpus. The
   shipped law takes the `::` name from the WHOLE CHAIN's syntax
   (`scopedChainRootName48`) and the eligibility from the AST base's SYMBOL.
4. **`isPkgQualifiedVarRef`'s `pkgViewVarObjs9` gate is REFUTED for chains**
   (C12/C13/C14/E4/E5 vs G4) — see § 1. The first shipped cut of law 1 reused
   that predicate as its package half and left five cells wrong; the arm caught
   it, not the corpus (the corpus does not contain the shape).
5. **A `::`-rooted chain whose step is a BUILT-IN method does NOT collapse in our
   build and golden says it should** (G10b `base67::CE1.name()` -> golden
   `ref_obj base67::CE1`@96:11-19, ours a `hier_path`). The reason is
   mechanical and is recorded so the next pass does not re-derive it: slang binds
   `x.name()` as a system-subroutine `CallExpression` whose receiver is
   **`arguments()[0]`, not `thisClass()`**, so the walk in § 1 never sees a step.
   Residue item 2. I did not widen the walk to argument[0] without a golden for
   the OTHER built-ins (`.size()`, `.len()`, `.num()`), because that is exactly
   the "law that only ever saw one spelling" trap.
6. **The pass-47 README's residue item 1 said "Direction: REPLACE. Depth: one
   statement emitter."** The depth was right; the POSITION was not — it is an
   expression hook, and it also carries an lvalue half (law 2) that item 1 did
   not predict.

## 4. GATES — all four, plus the byte verifier, ON THE SHIPPED BINARY

`SLANG_UHDM` was pinned to this worktree's binary for **every** run
(`scripts/verify_golden.py:52` and `tests/check_goldens.sh:5` both default to the
MAIN-TREE binary and a false pass is indistinguishable from a real one). **No
build ran while a sweep was in flight**; `gateall.sh` printed the binary md5
before AND after each sweep and both values matched
(`c2ac2753c23d4e7e7163d8ac9670eb33`, and `f3df096c832da786bf0b652a94625a35` for
the earlier cut).

1. **Build** `cmake --build build -j 3`: `Built target slang_uhdm`, 0 errors.
2. **Goldens**: **23 PASS / 0 FAIL**, rc=0. NEGATIVE CONTROL on the gate script
   itself: `SLANG_UHDM=/bin/false` -> **0 PASS / 23 FAIL, rc=1**.
3. **uhdm2rtlil `testflags`, --jobs 2, own --out**: 731 rows,
   **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, dump
   **496 match / 183 differ / 52 blank** — **0 whole-row diff lines** against
   `results/gate_uhdm2rtlil.csv` (`csvdiff.sh`), and the per-mode STATUS and DUMP
   tallies (`csvcount.py`) are IDENTICAL to the baseline's, so no
   `match -> differ` hides inside an aggregate. (Same on both binaries.)
4. **surelog `--mode both`, --jobs 2, own --out**: 1588 rows,
   default **466 CMP_EQUAL / 14 CMP_NOTEQUAL**, testflags **462 / 11**, dump
   match **default 225 / testflags 165** — **0 whole-row diff lines** against
   `results/golden_surelog.csv` INCLUDING the DUMP column; per-mode tallies
   identical to the baseline. **No `Google,testflags` SURELOG_FAIL-vs-TIMEOUT
   line appeared**: the committed baseline itself holds
   `Google,testflags,TIMEOUT` and our sweep reproduced it, so the known
   environment flake did not fire — I am naming its absence, not claiming credit.
   Canaries by NAME, all at their baseline values: `InterfaceModPort` CMP_EQUAL
   both modes (the b33d11b conversion held), `InterfaceBinding` /
   `InterfaceModExp` / `EnumConcat` / `BindHierPath` CMP_EQUAL + `match`,
   `LowMemPkg` CMP_EQUAL + `match` (default only — its testflags row is
   `SURELOG_FAIL` at baseline), `ClassExtends`, `FuncStruct`, `FuncStructVal`,
   `FuncIoTypespec`, `Scr1SvTests`, `BasicOh` CMP_EQUAL; `Earlgrey_0_1` default
   `CMP_NOTEQUAL` / testflags `SLANG_REJECT` at baseline. uhdm2rtlil:
   `paramod_genscope_child` + `issue326_packed_mem` CMP_EQUAL + `match`;
   `assignment-pattern`, `genscope_cells`, `genvar_loop_decl_3`, `hier_path`,
   `MultirangesStartNotFromZero` CMP_EQUAL at their baseline dump values.
5. **BYTE VERIFIER** (the whole-row CSV diff is blind inside the already-
   `CMP_NOTEQUAL` rows), HEAD binary vs SHIPPED binary, BOTH runs writing to the
   SAME workdir path: **953 databases, 946 identical, exactly 7 DIFFER** —
   `default/{SeqDriver,SimpleUVM,Scoreboard,BuildUVMPkg}` and
   `testflags/{SeqDriver,SimpleUVM,BuildUVMPkg}`. **Nothing else in either corpus
   moved a byte.** `Scoreboard` has no `testflags` database (SLANG_REJECT), which
   is why the count is 7 and not 8. `BuildUVMPkg` moves bytes because the laws
   fire inside UVM's own source, while its cmp head is unchanged and
   id-normalised-identical (`65e682317a01`) — a moved byte is not a moved head.
   The earlier cut produced the SAME seven-database set.
6. **`Scoreboard`'s known nondeterminism, settled by RE-RUNNING as instructed**:
   its post-law head md5 `8b6c80911ce8` reproduced on **two independent sweeps**
   into two different workdirs (the UVM-4 sweep and the byte verifier's POST
   run), and again on the shipped binary. Its byte difference is still NOT used
   in any identity claim.
7. **`default` mode of uhdm2rtlil was NOT run** — it has no committed baseline.
   Nothing here is row-checked there and nothing here implies it is.
8. **The heads were re-measured on the SHIPPED binary** and are md5-identical to
   the earlier cut's (`d0133c2a250a` / `94e68124ad89` / `8b6c80911ce8` /
   `65e682317a01`): the parent gate of § 2 changes nothing in this corpus, which
   is itself worth knowing — I4's shape is not in the UVM-4.

## 5. RANKED RESIDUE, most reachable first

1. **THE GENERIC-CLASS SPECIALISATION `class_typespec` + `vpiTypedefAlias`
   PUBLICATION — now the head of ALL FOUR tests. Direction: REPLACE. Depth: the
   typedef listing, in THREE container kinds. HONESTLY NOT DONE** (not started:
   the budget went to laws 1+2 and their gates). Everything known about it is
   § 0 plus the brief's two warnings, both re-confirmed by reading the code:
   `src/ParamEmit.cpp:19040-19070` already builds one `class_typespec` per
   generic class as the base and clones the rest with a `vpiTypedefAlias` ref
   carrying the DOUBLED `pkg::pkg::` fullname (the doubling is deliberate and
   commented at its line, not a print artifact), it picks the base **by NAME
   ORDER** (`std::get<0>(...) < ...`) where golden's base here is the
   SOURCE-FIRST typedef — they coincide only because `uvm_id_actions_array`
   sorts before `uvm_id_verbosities_array` — and `typedefTs` / `pkgTopTypedefTs`
   are populated at `17589-18006` (NOT 18857-18860), so NEVER-MUTATE-A-SHARED-OBJECT /
   `isSharedAliasTs` bites directly. **The new half this pass adds to the
   ranking: golden publishes the same chain in the importing MODULE
   (`work@top_tb`) and in importing CLASSES (`work@env`,
   `work@my_scoreboard`), with `vpiInstance` pointing at the package the
   specialisation came from (`adpcm_pkg` for SeqDriver, `uvm_pkg` for the
   others) — so this interacts with § modulePublishesPackageClasses45 and
   § classInheritsContainerImports23 and must respect the design-final
   ordering.**
2. **A `::`-rooted chain whose step is a BUILT-IN METHOD** (`.name()`, and by
   inspection `.len()`/`.size()`/`.num()`). Direction: REPLACE. Depth: one more
   step in `scopedChainDropBase48` (`SystemCallExpression::arguments()[0]`
   instead of `thisClass()`). Witness G10b (`s = base67::CE1.name();` -> golden `ref_obj base67::CE1`@96:11-19, ours a `hier_path`), both sides in § 3.5. **Needs a
   golden for the other built-ins before the walk is widened.** Also note the
   PACKAGE spelling of the same shape is residue 4, not this one — golden folds
   there and collapses here, which is exactly why they are ranked apart.
3. **A `::`-rooted chain with a CALL IN THE MIDDLE**
   (`y = base67::stat.get_scope().val;`, t67e I6) produces NO object at all:
   `noteUnsupported("member access base")` fires and the assignment has no Rhs,
   **at HEAD and POST alike** — a pre-existing hole this law does not reach, not
   a regression. Golden gives the ordinary collapse
   (`ref_obj base67::stat`@49:11-19). Direction: REPLACE. Depth: find why
   `scopedChainDropBase48` does not match it — check FIRST whether the OUTER
   MemberAccess carries `syntax`, since a chained base provably does not (§ 3.3).
4. **A package ENUM CONSTANT at the root of a chain FOLDS**: G10a
   `s = p67::E1.name();` -> golden `constant UINT:1`@95:11-14 (note the odd
   first-segment-only span), ours a `hier_path`. Direction: REPLACE (fold, not
   collapse). Depth: § pkgClassEnumFold13 plus the chain drop.
5. **A package variable read WRITTEN QUALIFIED inside its own declaring package
   keeps the qualified name in golden** — G6 `y = p67::pkgi;` inside `p67` ->
   golden `ref_obj p67::pkgi`@92:11-16 UNBOUND, ours `ref_obj pkgi`@92:11-20
   BOUND. **cmp-VISIBLE (VpiName).** Direction: REPLACE. Depth: the
   `pkgViewVarObjs9` gate in `isPkgQualifiedVarRef`. Same family as pass 47's
   residue 3 (`p1::q_qual`), and it needs its own arm because naming is
   context-dependent.
6. **The landed pkg-qualified arm's SPAN, FULLNAME and class-method BINDING.**
   Golden spans the QUALIFIER ALONE for a `::`-qualified package variable
   (G4 85:11-**16**, G5 89:11-**16**, G7 111:16-**21**, E3 114:11-**16**) where
   we span the whole name; golden joins the fullname with `::`
   (`p67::rdr67::h2::q67::@@BAD_SYMBOL@@`) where we use `.` (H2, `joinPath`);
   and golden binds NO `vpiActual` inside a CLASS METHOD (G4/G5) where we bind
   one — that last half is cmp-reachable, the first two are dump-only.
   Direction: REPLACE. Depth: three lines in the existing arm plus a
   class-method gate that needs its own cell.
7. **The pkg-PARAMETER struct-member `hier_path` carries a `vpiName` and a
   member `vpiFullName` golden does not** (G1). Direction: REMOVE, dump-only.
8. **An index sub-expression's `prefix` leaks the index owner into a collapsed
   ref's `vpiFullName`** (t67e I4: `…i4.arr::base67::stat` where golden has
   `…i4::base67::stat`; the NAME and SPAN match). Dump-only. Direction: REPLACE.
9. **A static UNPACKED-ARRAY class property is an unsupported construct**
   (`class property type: FixedSizeUnpackedArrayType`): golden emits
   `array_var p67::base67::sarr` and we emit nothing (t67b, and it is most of
   t67b's residual 545 dump lines). Direction: ADD.
10. **The pre-existing `isPkgQualifiedVarRef` lvalue arm has the defect `t67e` I4
   found in law 2 and does not have the fix.** It renames on `inLhs` alone, so
   `arr[q67::qh.hval] = 3;` should give it `q67::@@BAD_SYMBOL@@` where I4's
   golden says the READ form belongs in an index. Direction: REPLACE (add
   `assignTargetParent48`). Depth: one condition. **Not measured on golden for
   the package spelling** — I4 measured the class spelling only, which is why I
   did not change a landed law on inference.
11. Carried from pass 47 § 5, **all INHERITED and NOT re-measured**: the
   `p1::q_qual` def/top asymmetry; the module-hoisted integral-typedef
   `logic_var` with no initialiser; the module hoist's missing OOB-ctor locals;
   the `::`-qualified fold's constant SIZE; pass 46's `vpiAutomatic` class-method
   residue; and the whole pass-46 § 6 panel (`BINDWRONG` 757 / `BINDTOTAL` 1681,
   `LISTDIRECT` 80 vs 56, `CPTOTAL` 580, `TSINSTTOTAL` 1074, …). **The metric
   panel was NOT re-measured this pass either** — the frontier was in hand and
   the brief's first method law forbids retreating into another counter.

## 6. THE ARM TABLE, and the residual diff per arm

`armdiff.sh` diffs the two `uhdm-dump`s of one arm verbatim (only `file:` paths
normalised). LHS is golden, RHS ours:

| arm | golden lines | difflines at HEAD | difflines POST | what is left |
|---|---|---|---|---|
| `t67a` (C1..C16) | 1389 | **339** | **58** | nothing of this law: an unrelated `class_typespec` span/duplicate residue |
| `t67b` (D1..D9, E1..E5) | 2344 | **672** | **545** | almost all of it is residue 7 (the unsupported static unpacked array); of the cells, only E3's span/fullname |
| `t67c` (G1..G10) | 2228 | **582** | **557** | residues 3, 4, 5, 6 — every one of them measured on both sides above |
| `t67d` (H1..H10) | 953 | **134** | **56** | H2's fullname separator (residue 5) and object ORDER in the trailing all-objects list |

Cell-by-cell verdicts (`cell.sh` prints both sides of one cell): **C1-C10, C12-C16,
D5, D7, D8, D9, E1, E4, E5, G3, G8, H1, H3, H4, H7, H8, H10 moved from DIFFERENT
to BYTE-IDENTICAL-to-golden**; **C11, D1, D2, D3, D4, D6, E2, G1, G9 are
must-not-move controls and did not move**; **G4, G5, G6, G7, E3, H2, G10a, G10b
are the residues ranked in § 5.**

### 6a. `t67e` — the halves the SHIPPED walk reaches, and the DEFECT it found

| cell | source | golden (LHS) | ours POST |
|---|---|---|---|
| I1 | `y = base67::sbits[3:1];` PART-SELECT read | `ref_obj base67::sbits`@37:11-19 | **golden** |
| I2 | `base67::sbits[3:1] = 3'b0;` PART-SELECT lvalue | `ref_obj base67::@@BAD_SYMBOL@@`@40:7-25 | **golden** |
| I3 | `y = base67::sbits[k +: 2];` INDEXED part-select | `ref_obj base67::sbits`@43:11-19 | **golden** |
| **I4** | `arr[base67::stat.hval] = 3;` the chain INSIDE another lvalue's INDEX | `bit_select 'arr'`@46:7-29 whose `vpiIndex` is the **READ** form `ref_obj base67::stat`@46:11-**19** | **golden in NAME and SPAN** after the parent gate; the `vpiFullName` prefix still carries the index owner (`p67::rdr67::i4.arr::base67::stat` vs `…i4::base67::stat`) — dump-only, residue 6a |
| I6 | `y = base67::stat.get_scope().val;` a CALL in the MIDDLE | `ref_obj base67::stat`@49:11-19 | **the assignment has NO Rhs at all** and `noteUnsupported("member access base")` fires — **identical at HEAD**, so it is a PRE-EXISTING hole this law does not reach, not a regression. Residue 2b |

**I4 is why law 2 has a parent gate**: without it we emitted
`base67::@@BAD_SYMBOL@@`@46:11-28 into the index — a cmp-VISIBLE wrong
`VpiName`, found by an arm cell written specifically to test a half the code
reached but no cell had spelled. The first shipped cut had that defect and all
four gates plus the byte verifier were GREEN on it.

## 7. APPARATUS

Drivers (cloned from `r10uvm47repro` with a PREFIX-ANCHORED sed so no probe
binary got renamed — pass 44's lesson): `gold.sh`, `goldfile.sh`, `cmp4.sh`,
`csvdiff.sh`, `byteverify.sh`, `uvm4.sh`, `probebuild.sh`, `gate2.sh`. New:

* **`headmd5.sh`** — the id-normalised md5 + `^LHS:`-at-column-0 head count of a
  cmp file. Prints `NOHEAD` for a missing or head-less file so a shared-head
  claim can never come from an empty comparison.
* **`cell.sh`** — one arm CELL's tree out of BOTH dumps, bounded by the next
  `vpiMethod:`/`vpiTaskFunc:` sibling. A cell name found in NEITHER dump prints
  `CELL-NOT-FOUND` and returns 4 rather than an empty tree.
* **`armdiff.sh`** / **`arms67.sh`** — regenerate an arm on a named binary and
  diff golden against ours; FATAL on a missing or empty dump, `NO_OUTPUT` when
  our side produced nothing (uhdm-cmp exits 0 on a missing file, so no probe
  here trusts an exit code).
* **`gateall.sh`** — gates 3 and 4 back to back with the binary md5 printed
  BEFORE and AFTER each sweep.
* **`csvcount.py`** — per-mode STATUS and DUMP tallies of a sweep CSV, because a
  `match -> differ` can hide inside an aggregate that the row diff also covers;
  refuses to tally a file that is not a sweep CSV.

Arms: **`t67a`** (16 cells: the statement-vs-expression decider and every reader
context), **`t67b`** (14: the must-not-move controls — package function call,
static method call — plus three-segment roots, deep lvalues, conditions, selects
and the package-parameter gate), **`t67c`** (10: the symbol gate, the span
question, the compilation-unit class, the unqualified must-not-move control and
the enum roots), **`t67d`** (7: the lvalue half and the argument/task/module-
function positions), **`t67e`** (5: the halves the shipped walk reaches).

All arm intermediates are namespaced `/tmp/r10uvm48_*`.


## Line-number citations, established by the master at land — THREE were wrong

This is the THIRD consecutive pass in which a `src/ParamEmit.cpp` line citation
for the generic-class typedef-alias machinery was propagated without being
opened. All three prior figures were wrong, including the master's own and the
pass-47 verifier's. Verified at `ed653b4` + this patch, by `grep`/`sed`:

| what | CORRECT citation | what was claimed |
|---|---|---|
| `pkgClassTd9` declared | `src/ParamEmit.cpp:16985` | — |
| `pkgClassTd9` filled (one entry per generic-class typedef) | **`18953`** | "18844" (pass-48 verifier) |
| the alias loop: base pick BY NAME ORDER + doubled `pkg::pkg::` fullname + `Typedef_alias` | **`19040-19070`** — name-order compare at `19047-19049`, doubled fullname at `19068`, `Typedef_alias(art9)` at `19070` | "18869-18876" (master's pass-47/48 briefs, inherited from the pass-47 verifier); "18927-18962" (pass-48 verifier); "18926-18962" (this README) |
| `typedefTs` / `pkgTopTypedefTs` filled | **`17589`, `17594`, `17596`, `17612`, `17894`, `18006`** | "18857-18860", which is actually an `elemTs2` search loop over `typedefTs` |

**How this happened, and the rule it earns:** the pass-47 verifier reported a
line number, the master put it in the pass-48 brief without opening the file, the
pass-48 implementer copied it into this README, and the pass-48 verifier
"corrected" it to a second wrong figure. **A LINE NUMBER IS A MEASUREMENT.** Open
the file before citing it, and cite a SYMBOL as well as a line so the next reader
can re-find it after the file moves — `pkgClassTd9`, `base9`, `art9` and
`Typedef_alias` are all greppable and none of them drift.

The SUBSTANTIVE claims that rested on those citations are all CONFIRMED at the
corrected lines: the base really is picked by NAME ORDER
(`std::get<0>(pkgClassTd9[i]) < std::get<0>(pkgClassTd9[it9->second])`), which is
NOT golden's rule (golden uses the SOURCE-FIRST typedef; the two coincide in
`BuildUVMPkg` only because `uvm_id_actions_array` sorts before
`uvm_id_verbosities_array`), and the doubled `prefix + prefix + name` fullname is
built deliberately rather than being a print artifact.

## Findings the pass-48 VERIFIER added on its own arms (not in the implementer's cells)

### GOLDEN'S SPAN RULE IS CONTEXT-DEPENDENT — a genuinely unmeasured half
Verifier arm `t68v` V1, `localparam int LP1 = base68::LPARR[1];` at MODULE scope
— a `param_assign` Rhs, a context no pass-48 cell spells. Golden emits
`ref_obj (work@t68v.base68::LPARR)` spanning **@39:24-39:40, the WHOLE WRITTEN
SELECT**, where § `staticScopedChainDrops48` gives **@39:24-39:32** (qualifier
only), and where cell E1 inside a class method genuinely IS qualifier-only
(108:11-19). So "the span is the qualifier alone" is TRUE for the contexts this
pass measured and FALSE for a param_assign Rhs.

It is still a **net improvement**: the NAME matches golden (`base68::LPARR`) and
at HEAD ours was a `bit_select` named `LPARR` — a CMP-VISIBLE wrong name. The
residue is span-only, therefore DUMP-only, because `BaseClass::Compare` reads
`VpiType`/`VpiName`/`VpiDefName` and never a location. Direction REPLACE, depth
one `setLoc`. **Do not "fix" the span globally** — E1 proves the qualifier-only
span is correct in a class method, so this needs a context predicate and its own
arm grid.

### Positive INTERACTION check with pass 47, previously unmeasured
Verifier arm `t68v` V2, `int vinit = base68::stat.hval;` at PACKAGE scope: ours is
**byte-identical to golden**, and pass-47's § `pkgInitRefBindsOwnListing47`
correctly leaves the collapsed ref UNBOUND. The two laws compose. Worth keeping as
a regression cell for anyone touching either.

### Residue 8 is WIDER than stated
The `vpiFullName` index-owner leak affects the **READ** index too, not only I4's
lvalue: `y = arr[base68::stat.hval];` gives ours `…v3.arr::base68::stat` where
golden has `…v3::base68::stat`. Dump-only.

### Law 2's gate is NARROWER than its prose (unmeasured half, not a regression)
`assignTargetParent48` accepts only `assignment`/`assign_stmt`/`cont_assign`, but
`src/ExprEmit.cpp` parents an assignment-EXPRESSION's lvalue at an `operation`
(or `enclosingAssign`). So `{a, x::y} = z`-style concatenation lvalues, and
assignment-as-expression / output-argument lvalues, keep the READ form. That is
HEAD behaviour (not a regression) and NO GOLDEN WAS READ for it — it belongs
beside residue 10, which already flags that the pre-existing package arm still
renames on `inLhs` alone.

### FIRST-EVER BYTE VERIFICATION OF THE uhdm2rtlil CORPUS
No pass had byte-checked u2r before, and the row diff is blind there because 183
rows are `CMP_EQUAL` + dump `differ`. The verifier ran it: **679 databases, 679
IDENTICAL, 0 differ.** Combined with the surelog byte verifier (953 databases, 946
identical, exactly the 7 intended UVM movers), the total cross-corpus reach of
both laws is EXACTLY those 7 databases. **Fold `bv_u2r.sh` into this directory and
run it every pass** — it converts "the u2r row diff is empty" from a weak claim
into a byte-level one.
