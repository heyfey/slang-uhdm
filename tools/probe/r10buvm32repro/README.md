# r10buvm32 — § classScopeCallWrittenQualifierIsLookupKey32

**The head.** `this_type::add_typewide_sequence(seq_type);` — the one statement
in `uvm_sequence_library::m_add_typewide_sequence`
(`UVM/1800.2-2017-1.0/src/seq/uvm_sequence_library.svh:385`) — was the first
object the official `uhdm-cmp` disagreed on for **four row-modes** at base
`09dec240`: SeqDriver default+testflags and BuildUVMPkg default+testflags, all
four at 46 cmp lines.

```
LHS (golden)  ref_obj  (…::m_add_typewide_sequence::this_type::add_typewide_sequence)
              line 413:3-413:14   vpiParent -> begin   no arguments, no call object
RHS (ours)    func_call (this_type::add_typewide_sequence)
              line 413:3-413:12   vpiArgument -> ref_obj seq_type
                                  vpiFunction -> function uvm_pkg::uvm_sequence_library::add_typewide_sequence
```

---

## 1. The decoded law

> A `C::m(...)` call keeps its `func_call` / `task_call` only when the qualifier
> the CALL SITE WROTE is character-for-character the name of the class that
> DEFINES `m` out of body.  Being out-of-body is necessary; it is not
> sufficient.

**Surelog, line by line.**

* `CompileStmt.cpp:250` — a `paSubroutine_call_statement` is handed to
  `compileTfCall`, and `CompileHelper.cpp:4207` sends a `paClass_scope` leaf
  straight to `compileComplexFuncCall`.  Statement position and expression
  position therefore reach the SAME producer; there is no statement/expression
  split in this family (the pass brief's "compileStmt's subroutine-call arm" is
  a one-line forwarder).
* `CompileExpression.cpp:5253-5290` — the `paClass_scope` arm reads
  `packagename = SymName(Class_type_name)` (the FIRST written segment, without
  its `#(...)` parameter list, which is a sibling node) and
  `functionname = SymName(Class_scope_name)` (the FINAL identifier), builds
  `basename = packagename + "::" + functionname`, and asks
  `getTaskFunc(basename, ...)`.  On a HIT it makes a `func_call`/`task_call`
  named `basename` spanning the class-name TOKEN and carrying the arguments;
  on a MISS (`:5375`) it falls through to `compileExpression` on the scoped
  name, which yields a bare `ref_obj` — no call object, **no arguments at all**,
  spanning the qualifier through the last `::`.
* `CompileExpression.cpp:349` — `getTaskFunc` first tries the first segment as
  a PACKAGE name and looks for a task_func called `functionname` inside it;
  failing that it matches `tf->VpiName() == name` **literally** against the
  component chain, the file contents, the imported packages, the instance chain
  and finally every file content in the design.
* `CompileStmt.cpp:2600` (`compileTaskPrototype`) and `CompileStmt.cpp:2692`
  (`compileFunctionPrototype`) are the ONLY places that ever register a
  task_func under a `::` name, and they build it as
  `SymName(Child(Class_type)) + "::" + SymName(suffixname)` — **the class
  identifier written in the OUT-OF-BODY HEADER**.

So `getTaskFunc("this_type::add_typewide_sequence")` misses: nothing was ever
registered under that string.  `uvm_sequence_library` registers
`uvm_sequence_library::add_typewide_sequence`, because that is what
`uvm_sequence_library.svh:393` writes.  `this_type` is the class's own
`typedef uvm_sequence_library #(REQ,RSP) this_type;` (`:311`), and a typedef is
invisible to a literal string lookup.

**Our bug.** § classScopeCallOfOutOfBodyMethodIsFuncCall26 decoded the
out-of-body half of the same lookup correctly but gated on
`sub.outOfBlockIndex != 0` ALONE — a property of the CALLEE, read through
slang's resolution, which sees through the typedef.  The written spelling never
entered the gate.  The fix is one clause: `f12 == pscS->asSymbol().name`,
where `f12` is the first written segment `splitScopedName12` already extracts
and `pscS` is the callee's defining class scope the arm already holds.

**Everything else about the arm is unchanged**: the ref_obj it falls through to
is the object § staticScopedCall12 / § typeParamScopedCallRef59 /
§ classPropScopedCallIsRefObj29 already build (name = first written segment
`::` final identifier, fullname = caller prefix joined to that, span = the
scoped name's start up to the column the final identifier starts at, no
arguments, no link).  This pass adds no builder and no object; it only widens
the population that reaches the existing one.

**Relation to § classPropScopedCallIsRefObj29** — the same collapse in a class
PROPERTY INITIALIZER, and the same producer, reached through
`UhdmExporter.cpp:694`'s second call site.  buvm31's README named this head "the
STATEMENT twin"; the measurement says it is not a statement law at all: the two
faces share one Surelog arm and one key, and the statement/expression axis is
flat (g32a1 A8-A13, g32a2 G5/G7/G8 — Rhs, if-condition and argument positions
all flip exactly when the qualifier does).

---

## 2. The golden grid (three purpose-built arms, both views, read cell by cell)

`g32a1.sv` — plain classes.  `arm.sh`-style: Surelog `-parse -d coveruhdm`
(± `-elabuhdm`) vs our binary (± `--elabuhdm`), whole-dump comparison per
source line.

| cell | written | callee | golden | ours (pristine) |
|---|---|---|---|---|
| A1 | `der32::dv32(1)` | out-of-body in `der32` | `func_call` | same |
| A2 | `this_type::dv32(2)` | out-of-body in `der32` | **`ref_obj` 45:5-45:16** | `func_call` 45:5-45:14 |
| A3 | `alias32::dv32(3)` | out-of-body in `der32` | **`ref_obj`** | `func_call` |
| A4 | `base32::bv32(4)` | out-of-body in `base32` | `func_call` | same |
| A5 | `der32::bv32(5)` | out-of-body in `base32` | **`ref_obj` 48:5-48:12** | `func_call` |
| A6/A7 | `der32::dinb32` / `this_type::dinb32` | IN-BODY | `ref_obj` | same |
| A8-A9 | the same pair in an assignment Rhs | | as A1/A2 | |
| A10-A11 | the same pair in an `if` condition | | as A1/A2 | |
| A12-A13 | the same pair in a `$display` argument | | as A1/A2 | |
| B1-B8 | the whole set again from an IN-BODY method home | | identical split | |
| P1-P4 | and again from a PACKAGE FUNCTION home | | identical split | |
| M1/M2/M5 | `p32::der32::dv32(31)` | out-of-body | **`ref_obj` `p32::dv32` 76:5-76:17** | `func_call` `p32::dv32` 76:5-76:8 |
| M3 | `der32::dv32(33)` via `import p32::*` | out-of-body | `func_call` | same |
| M4 | `p32::pkgrun32()` | package free function | `func_call` | same |

**A5 is the cell that names the law.**  `der32::bv32` and `base32::bv32` are
the SAME subroutine, both out-of-body, differing only in the qualifier the call
site wrote — and golden keeps one and degrades the other.  No rule phrased over
the callee can produce that; only the literal lookup key can.

`g32a2.sv` — the UVM shape (a generic class with its own
`typedef gen32 #(T,W) this_type;`), a NON-CONSTANT argument, and the
parameter-list question:

| cell | written | golden | note |
|---|---|---|---|
| G1 | `this_type::gv32(seed)` | `ref_obj`, **argument GONE** | a bound `ref_obj` to `seed` is what we emitted beside the call; golden has neither |
| G2 | `gen32::gv32(seed)` | `func_call` + argument | |
| G9/G10 | the same pair from an IN-BODY method | same split | |
| G11/Q1/Q5 | `gen32#(int,1)::gv32(seed)` | `func_call` | **the parameter list is not part of the key** |
| Q2 | `gen32#(int,1)::ginb32(seed)` | `ref_obj` | in-body callee |
| N1 | `q32::host32::hv32(s)` | `ref_obj` `q32::hv32` 59:5-59:18 | first segment is a PACKAGE, and `q32` has no `hv32` |
| N2 | `q32::host32::hinb32(s)` | `ref_obj` `q32::hinb32` | already right |
| N3 | `q32::qrun32(s)` | `func_call` | package free function, a different arm |
| N4 | `q32::gen32#(int,1)::gf32(s)` | `ref_obj` `q32::gf32` 62:9-62:29 | |

`g32a3.sv` — the TASK half (the gate is shared by the `func_call` and
`task_call` arms) plus the negative controls in one file: T1-T10 repeat the
four spellings against an out-of-body static TASK, an in-body TASK and an
out-of-body FUNCTION; C1-C7 are an implicit-`this` call, `this.m()`, `h.m()`,
an unqualified and a package-qualified free-function call, `super.new()` and a
`super.` method call; U1-U3 repeat `pkg::Class::` from a module home.

**Span rule (measured, not derived).**  Golden's ref_obj ends at the COLUMN THE
FINAL IDENTIFIER STARTS AT: `this_type::` is 11 characters from column 3, so
`413:3-413:14`; `der32::` is 7 from column 5, so `48:5-48:12`;
`q32::gen32#(int,1)::` is 20 from column 9, so `62:9-62:29`.  Ours ended at the
CLASS-NAME TOKEN (`nameSpan(start, f12)`), which is the span Surelog gives the
*kept* call — `413:3-413:12`.  Both spans already exist in the code; this pass
changes only which one a cell takes.

---

## 3. The corpus census (question 1, answered over all 956 databases)

`r10buvm32cen.cpp` enumerates the `SCALL` family — every `func_call`,
`task_call`, `method_func_call` and `ref_obj` whose VpiName carries a `::` —
with span, kind, `vpiFunction`/`vpiTask`/`Actual_group` link, argument count,
enclosing home, parent kind and reachability.  Both producers are enumerated by
the SAME rule, so the join is symmetric.  `sweepcen32.sh` ran it over the whole
pristine surelog workdir (956 databases × 2 modes = 1573 cells; 617 cells have
a missing side and are COUNTED, not skipped).  `cen32.py` joins as a MULTISET
on (test, mode, span, name, home), and for the kind question re-keys WITHOUT
the span so a span shift cannot masquerade as a kind flip.

Reachable cells (unreachable objects are invisible to the judge):

```
IDENTICAL                  7305
MISSING-OURS                 50   uvm_root::get / Tregistry::type_name / TYPE::type_name residues
EXTRA-OURS                   37   the mirrors of those
KIND, other                  10
CALL -> REF, this law        13   ONE name: this_type::add_typewide_sequence
```

Split by home and position, over the whole corpus: the disagreement is 100 %
`out-of-body method home / statement position`, and 0 % everywhere else —
because `this_type::add_typewide_sequence` is the only call in the corpus whose
written qualifier is not its callee's defining class name.  Every other
`::`-written call in nine UVM databases either writes the defining class
(`uvm_root::get`, `uvm_reg::get_max_size` — kept, correctly) or reaches an
in-body callee (degraded, correctly, since pass 26).

Cross-check from OUR side alone: of every `::`-named tf_call in the corpus,
exactly three names have a first segment differing from their bound callee's
owner — `this_type::add_typewide_sequence` (26 objects) and
`uvm_pkg::m_uvm_string_queue_join` bound to `adpcm_pkg::…` / `svaunit_pkg::…`
(12 + 12).  The latter two are PACKAGE FREE FUNCTIONS; the arm this pass
touches requires `SymbolKind::ClassType`, so they are unreachable from it, and
the sweep confirms they did not move.  There is not one UNBOUND `::`-named
tf_call in the corpus, so the `pendingScopedCallBind26` path is not exercised
either.

---

## 4. Mover prediction and attribution

`PREDICTION.txt` was written from the PRISTINE databases before the patched
sweep: **9 databases, by name** — `{default,testflags} × {BuildUVMPkg, MiniAmiq,
SeqDriver, SimpleUVM}` plus `default/Scoreboard` (Scoreboard/testflags has no
database).  `grep -rl add_typewide_sequence` over every `slang.uhdm` in the
pristine workdir returns exactly those nine.  uhdm2rtlil: zero, both modes.

Measured: `byteverify.sh SELFCHECK=1` reports **MOVERS 9 / 956** — the nine
predicted names and nothing else (SELFCHECK 955/956, so the instrument can
see) — and **0 / 1358** on uhdm2rtlil.

`movers32.sh` attributed all nine ORDER-BLIND (sorted, path- and id-normalised
dumps — the only sound attribution for Scoreboard/default, which is a ~50/50
coin per invocation):

```
default/BuildUVMPkg   26   default/SimpleUVM     26   testflags/BuildUVMPkg  26
default/MiniAmiq      52   default/Scoreboard    26   testflags/MiniAmiq     52
default/SeqDriver     52                              testflags/SeqDriver    52
                                                      testflags/SimpleUVM    26
```

Every one of those lines mentions `this_type::add_typewide_sequence`, its
`seq_type` argument, or the `vpiFunction` link being dropped — **0 unattributed
lines in all nine**.  The 52-line rows are the two databases that compile the
UVM library twice (SeqDriver's `adpcm_pkg`, MiniAmiq's `svaunit_pkg`), so they
carry the statement twice.

Direction: TO-GOLDEN 13 cells / AWAY-GOLDEN 0 / STILL-WRONG 0 (the census
`CALL -> REF` set is empty after the patch, and no new disagreement appears —
see §6).

---

## 5. Head movement

`rowheads.sh` on the pristine and patched workdirs of this build:

| row | mode | pristine | patched | head object |
|---|---|---|---|---|
| SeqDriver | default | 46 | 56 | ref_obj@413:3 -> **class_var@496:12** |
| SeqDriver | testflags | 46 | 56 | same |
| BuildUVMPkg | default | 46 | 56 | ref_obj@56491:3 -> **class_var@56591:12** |
| BuildUVMPkg | testflags | 46 | 56 | same |
| SimpleUVM | both | 17 | 17 | unchanged (earlier head) |
| Scoreboard | default | 60 | 60 | unchanged |
| MiniAmiq | both | 60 | 60 | unchanged |
| Earlgrey_0_1 | both | 90 | 90 | unchanged (byte-identical cmp log) |
| Rggen | default | 0 | 0 | still equal |

The four target row-modes' head **cleared**; the line count rose because the
NEXT head is a bigger object (RESUME §7: a cmp line count is the head object's
decompile size, and it may rise when the object changes).  SimpleUVM,
Scoreboard and MiniAmiq were movers too — their two cells now agree — but their
heads sit earlier in the walk and are untouched.

---

## 6. Gates (all green, on this worktree's own build)

* build both binaries `-j 2`, md5 separately: pristine
  `b4900a013105152c57a347bda1e33990`, patched `1e399328f1007101d1fc61edc65a0544`;
  both frozen `chmod 555` before any sweep, and every `cmds.txt` audited BY
  BINARY PATH, not by the string `slang-uhdm` (which also matches the golden
  cache directory): of 1573 surelog `cmds.txt` 1523 name the frozen binary and
  50 name none at all (golden-cache-only cells where slang was never invoked),
  and of 1462 uhdm2rtlil `cmds.txt` 1458 name it.  **Zero cells, in either
  corpus, name the main-tree binary.**  The pristine control sweep audits the
  same way against the pristine path.
* `tests/check_goldens.sh` with `SLANG_UHDM` exported explicitly: **23 PASS /
  0 FAIL**; negative control `SLANG_UHDM=/bin/false`: **23 FAIL**.
* uhdm2rtlil testflags + default: **679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL** in both modes; `ct8rows.sh` **0 differing rows** against the
  committed `results/gate_uhdm2rtlil.csv` AND against this build's own pristine
  sweep, status AND dump column.
* surelog `--mode both`: 1588 rows, `937 CMP_EQUAL / 567 SLANG_REJECT /
  48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE /
  2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM`; `ct8rows.sh` **0 differing rows**
  against the committed `results/golden_surelog.csv` and against the pristine
  sweep.  **NO ROW IS CONVERTED** and `results/*.csv` is untouched.
* `byteverify.sh SELFCHECK=1`: 9/956 movers (all predicted by name) and 0/1358.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2.sh` PASS on both
  corpora; `canaudit.sh canaries.sh ctcan2.sh` PASS.
* protected databases by name, md5 vs the pristine control: InterfaceModPort,
  BlackParrotComplex, YosysOldOr **SAME** in both modes; SVSwitch
  `4842211c4030`; YosysVerx `6ccda350c24a`.
* boundary gate `bound32.sh` over a COPY of the whole `tools/probe` tree —
  every `.sv`/`.v` arm, both binaries, `MODE=file` and `MODE=dir`, `VIEW=def`
  and `VIEW=elab`, arm list on fd 3, children `</dev/null`, PROCESSED asserted
  against LISTED: see `BOUNDARY.txt`.
* the four slang-fenced tests are never dispatched and never spelled here;
  `canaudit.sh` is run from this directory.

---

## 7. Residues and R0

* **R1 — the `pkg::Class::method` NAME is still golden's, but is it right for
  every first segment?**  This pass measured `pkg::Class::m` (g32a2 N1/N4,
  g32a1 M1/M2/M5) and `Class::m`.  A THREE-segment spelling whose first segment
  is neither a package nor the defining class (`A::B::C::m`) is not in the
  corpus and was not measured; the existing builder would name it `A::m`, which
  is what Surelog's `SymName(Class_type_name)` implies but was not read off a
  golden.
* **R2 — the `A5` shape has no corpus instance.**  `der32::bv32(5)` (the
  derived class name for a base's out-of-body method) is a purpose-built cell
  only; the corpus reaches this law solely through `this_type::`.  If a future
  corpus row writes it, the gate already covers it.
* **R3 — one extra dump traversal line in `g32a3`'s elaborated view**
  (`int_var r`, printed 36 times against golden's 35).  The official `uhdm-cmp`
  reads g32a3/elab as **EQUAL (0 lines, 0 heads)** after the patch, against 46
  lines before, so this is a parent-chain print count and not a database
  object; recorded rather than dressed up.
* **R4 — the `TYPE::type_name` / `uvm_root::get` MISSING-OURS set (50 cells)
  and its EXTRA-OURS mirror (37)** are the same census's other two families and
  are NOT touched here.
* **R5 — a generic class's IN-BODY method body is emitted more often than
  golden emits it.**  `g32a2` G9/G10 (`this_type::gv32` / `gen32::gv32` inside
  `gen32::gmeth32`) appear 6 times on our side against golden's 4, in BOTH the
  pristine and the patched database — the KIND is right on both sides, the
  SPECIALIZATION COUNT is not.  Pre-existing, untouched, and not reached by the
  judge on this arm (a2's head is an `int_typespec vpiSigned` on the `int W`
  class parameter).

### R0 — the next head

With this landed, SeqDriver and BuildUVMPkg both modes stand at 56 cmp lines
and the new head is the SAME object in both:

```
LHS: class_var (uvm_pkg::uvm_sequence_library::init_sequence_library::this_type::m_typewide_sequences)
     line 496:12-496:23 (SeqDriver) / 56591:12-56591:23 (BuildUVMPkg)
     vpiParent -> foreach_stmt (…::init_sequence_library)
     vpiName:this_type::m_typewide_sequences
     vpiTypespec -> ref_typespec -> unsupported_typespec (this_type::m_typewide_sequences)
```

— `foreach (this_type::m_typewide_sequences[i])` at
`uvm_sequence_library.svh:480-481`: the same `this_type::` qualifier, now on a
STATIC CLASS PROPERTY reached as a foreach array, where golden gives a real
typespec and we give an `unsupported_typespec`.  It is the DATA face of the
qualifier this pass decoded on the CALL face, and it is worth four row-modes.
SimpleUVM stays at 17, Scoreboard and MiniAmiq at 60, Earlgrey_0_1 at 90.

---

## 8. Files

* `r10buvm32cen.cpp` + `build32.sh` — the `SCALL` census, linked STATICALLY
  against `~/.local` UHDM so it reads exactly the databases the sweeps wrote.
* `sweepcen32.sh` — the census over a whole verify_golden workdir, both sides,
  both modes; a missing side is counted, never skipped.
* `cen32.py` — the symmetric multiset join (`--only-disagree`, `--pred`).
* `kindflip32.py` — the same join re-keyed WITHOUT the span, which is what
  turns "285 disagreeing cells" into the 13 this law owns.
* `arm32.sh` — one purpose-built arm, both views, golden vs one binary.
* `cells32.py` — per-source-line cell comparison of two dumps (how the §2 grid
  was read).
* `msdiff32.py` — order-blind multiset dump diff; run golden-vs-pristine and
  golden-vs-patched and compare the KEY SETS to prove NEW=0.
* `grid32.sh` — three databases per arm × two views + official `uhdm-cmp` on
  each side.
* `movers32.sh` — order-blind mover attribution.
* `bound32.sh` — the boundary gate (with a fix: MODE=dir lists the tree ROOT
  as `.`, whose key was the EMPTY string, so the cleanup `rm -rf "$OUT/"` aimed
  at the whole run directory; that arm is now named ROOT).
* `coin32.sh` — the nondeterminism control: the SAME binary run twice on one
  directory arm, raw diff vs order-blind diff.
* `g32a1.sv` / `g32a2.sv` / `g32a3.sv` — the purpose-built goldens.
* `PREDICTION.txt` — the mover prediction, written before the patched sweep.
* `BOUNDARY.txt` — the boundary-gate results.
* `byteverify.sh` / `canaries.sh` / `ctcan2.sh` / `canaudit.sh` /
  `rowheads.sh` — the shared gate scripts, copied so `canaudit.sh` runs here.
