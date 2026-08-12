# r10uvm57 — THE HEAD ON ALL THREE TARGET ROWS IS **CLEARED**. And **MY BRIEF'S DIAGNOSIS WAS WRONG**: the object it says is missing was already there on both sides, letter for letter; the head was an **UNBOUND `vpiActual` on a call argument**. One law landed — **§ blockLocalSameCtrlDepthArgBinds57** — 7 byte movers, every one a **PURE ADDITION** and every added line **covered by golden**. **No conversion.** A third finding: **`r10uvm55repro/msdist.sh` is BROKEN and reports MULTISET DISTANCE 0 for dumps that differ by 90 lines** (§7).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; every driver here passes them that way and prints that it did.

Base **3500bc4** (pass 56's committed FINAL). Worktree
`.claude/worktrees/r10uvm57`; pristine control worktree
`.claude/worktrees/r10uvm57pris`, built by me at the same commit.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 3500bc4) | `71bd294b421e23a4feb7807f8c5b7a8f` | my own build of 3500bc4 — **byte-identical to the main-tree `build/slang-uhdm`** at the start of this pass, which is what makes it a valid control (`md5sum` on all three trees, §8) |
| FINAL (gated, shipped) | `b40329b21fb425f8a6efcd2d7d43f195` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) were **READ ONLY**; row counts are
lines-minus-one, because `wc -l` counts the header. Slang-fenced tests
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) were never
dispatched — audited mechanically in §6.4. `GOLDEN_DEFER` left at default: 5
DEFERRED in both surelog modes, as in the baseline.

---

## 0. HEADLINE

* **THE HEAD IS CLEARED ON ALL THREE TARGET ROWS.** `SimpleUVM` (default and
  testflags) and `Scoreboard` (default): the head at `uvm_registry.svh:260` is
  gone and has **ADVANCED to a new, characterised head** (§4). cmp lines
  **29 → 54**, still exactly **1** head (`grep -c '^LHS:'` at column 0).
* **NOTHING CONVERTED.** All four UVM rows stay `CMP_NOTEQUAL`;
  `Scoreboard,testflags` stays `SLANG_REJECT`. **0 differing ROWS against BOTH
  committed baselines** (§6.1, §6.2).
* **REFUTATION 1 — THE BRIEF'S DIAGNOSIS IS FALSE, and it is the whole pass.**
  The brief states: *"RHS: NOTHING. The object does not exist on our side …
  DIRECTION: ADD the object (and its typespec chain) to the block's variable
  listing."* Measured on the **control binary's own SimpleUVM database**
  (§1): our side already emits
  ```
  \_string_var: (uvm_pkg::uvm_object_registry::create::msg), line:260:14, endln:260:17
    |vpiParent:  \_begin: (uvm_pkg::uvm_object_registry::create), line:259:30, endln:266:8
    |vpiTypespec: \_ref_typespec … |vpiActual: \_string_typespec: , line:260:7, endln:260:13
    |vpiName:msg  |vpiFullName:uvm_pkg::uvm_object_registry::create::msg
  ```
  — the SAME parent, the SAME name, the SAME fullname, the SAME two spans and
  the SAME ref_typespec chain. Across a **50-line window of both dumps there is
  exactly ONE differing line**, and it is not on the variable at all: it is the
  `vpiActual` of the `msg` **reference at 265:34**, the second argument of
  `uvm_report_fatal("FCTTYP", msg, UVM_NONE);`. **Had I followed the brief I
  would have emitted a SECOND `string_var` into a listing that already had it.**
  The `RHS: <null>` in the head is `SafeCompare`'s SCALAR overload printing
  `m_failedLhs` (the object golden has at the failing field) with
  `m_failedRhs` unset — the field is `ref_obj::Actual()`, not a container.
* **REFUTATION 2 — the brief's fallback hypothesis is also false.** It says *"if
  we do not emit the `begin` at all in some shape, the missing variable is a
  symptom and the real law is about the block."* The `begin` is present, and
  **all eight of the brief's own arms (a1–a8) are BYTE-IDENTICAL between the
  control and FINAL binaries** (§3.1) — the block-variable emitter needed no
  change in any of the shapes the brief asked about, including the negative
  control.
* **REFUTATION 3 — `msdist.sh`, the campaign's "no alignment at all" instrument,
  IS BROKEN** and I proved it on this pass's own mover: it reports
  `MULTISET DISTANCE 0` for two dumps of 1100381 and 1100471 lines (§7). Every
  msdist figure in this campaign needs re-derivation.
* **ONE LAW LANDED — § blockLocalSameCtrlDepthArgBinds57**, 3 tagged sites
  (`grep -rn 'blockLocalSameCtrlDepthArgBinds57' include/ src/`: the law in
  `include/UhdmExporter.h`, the predicate + the gate in `src/ExprEmit.cpp`, the
  recorder in `src/StmtEmit.cpp`). DIRECTION: **ADD** (a `vpiActual` that was
  absent). Nothing is reshaped and nothing is deleted.
* **7 BYTE MOVERS on the surelog corpus, 0 on uhdm2rtlil** (§5). All 7 are UVM
  rows, all 7 are **PURE ADDITION** by multiset (`mv57.sh`, DELETED = 0 with a
  one-line-deletion self-check that fires), and **100 % of the added line
  instances exist in GOLDEN with at least that multiplicity** (`cov57.sh`, with
  an injected-line self-check that fires). SimpleUVM: **+45 `|vpiActual:`**,
  `52942 → 52987` against golden's `54189`.
* **THE ONLY ATTRIBUTABLE MEASURE, per shape.** The target line
  `\_string_var: (uvm_pkg::uvm_object_registry::create::msg), line:260:14, endln:260:17`
  (indentation stripped, `grep -Fxc`): **golden 3 — ours 2 → 3.** Exact.

---

## 1. THE HEAD, READ RATHER THAN ASSUMED

`rowheads.sh` on my pristine workdir, control binary:

| test | mode | cmp lines | heads |
|---|---|---|---|
| SimpleUVM | default | 29 | 1 |
| SimpleUVM | testflags | 29 | 1 |
| Scoreboard | default | 29 | 1 |
| Scoreboard | testflags | — | SKIP-NOFILE (`SLANG_REJECT`, no database — reported, not hidden) |
| SeqDriver | default/testflags | 85 | 1 |
| BuildUVMPkg | default/testflags | 58 | 1 |

The head is the brief's, verbatim. But the **dumps** settle what it means. Both
sides dumped with `sed 1d` (uhdm-dump's first line is the DATABASE PATH):

```
grep -c "uvm_object_registry::create::msg"   golden 10   ours 9
```

Nine of the ten lines are IDENTICAL and in the same order. The tenth, golden
only:

```
              \_ref_obj: (uvm_pkg::uvm_object_registry::create::msg), line:265:34, endln:265:37
                |vpiParent: \_func_call: (uvm_report_fatal), line:265:7, endln:265:48
                |vpiName:msg
                |vpiFullName:uvm_pkg::uvm_object_registry::create::msg
                |vpiActual:                                              <-- OURS LACKS THIS
                \_string_var: (…::create::msg), line:260:14, endln:260:17 <-- AND THIS
```

Two neighbouring cells decide the shape of the law, and both are BARE on BOTH
sides: the assignment LHS `msg` at **261:7**, and the sibling argument
`UVM_NONE` at **265:39**. So it is neither "all references to `msg`" nor "all
arguments of this call".

That places the defect inside **§ controlBodyNoBind28** (see
`include/UhdmExporter.h`): in an in-body class method a reference binds only at
the method's top level, and this one sits inside `if (!$cast(create, obj))
begin … end`.

---

## 2. THE LAW

**§ blockLocalSameCtrlDepthArgBinds57.** Inside the § classArgBind12 window — a
USER call's ARGUMENT list, which for an IN-BODY class method is **STATEMENT
POSITION only** (§ classInBodyBareCallArgStmtOnly53) and which SYSTEM calls and
CONCATENATION operands never enter — a reference whose symbol is declared in an
**UNNAMED STATEMENT BLOCK** BINDS even at `ctrlBodyDepth28 > 0`, **iff that
block was entered at exactly the `ctrlBodyDepth28` the reference is read at.**
Everything else keeps §28's silence.

The three conditions and the cell that fails without each:

| condition | cell that requires it (golden) |
|---|---|
| symbol is a VARIABLE declared in a STATEMENT BLOCK | `b1 f:30 sink(bodyloc)` method-body local at d1 → **bare**; `b1 f:31 sink(farg)` formal → **bare**; `b1 g:49 sink(prop)` class property → **bare** |
| the block is **UNNAMED** | `b2 f:24 nmd::nmdblk` → **bare**; `b3 f:47 inm::inmv` → **bare** (golden scopes them through the label) |
| **SAME control-body depth** | `b2 f:36 outr` (decl d1, read d2) → **bare**; `b3 f:64 lpv` (loop body local read one `if` deeper) → **bare**; `b4 e1:35 p0` (decl d0 plain block, read d1) → **bare** |

and the two cells that show the depth test is about **control bodies**, not
blocks: a PLAIN `begin` nested inside a control body does **not** raise the
depth (`b3 f:23 pln1` and `b3 f:24 ctl1` both **BIND**), and neither does a
`fork` arm (`b4 e9:120 g9` and `b4 e9:121 f9` both **BIND**).

Implementation, 3 tagged sites, all greppable by the § marker:

1. `include/UhdmExporter.h` — `blkCtrlDepth57`, the law and all 12 measured cells.
2. `src/StmtEmit.cpp` — `struct BlkCtrl57` + one push in `StatementKind::Block`,
   recording `(bs.blockSymbol, ctrlBodyDepth28)` for the block's whole emission.
3. `src/ExprEmit.cpp` — `UhdmExporter::blkLocalSameCtrlDepth57()` (the
   predicate) and one clause on `ctrlBodyNoBind28` (the gate). It lifts
   **only** §28: `classMethodNoBind`, `unitSubNoBind9` and
   § classInBodyRecvCallArgNoBind52 all still apply.

---

## 3. THE ARM TABLES

Every arm is one `.sv` in this directory, built by `arm.sh <arm.sv> <out>
<binary>` (the binary is **never** defaulted; its md5 prints on every run).
`cells.py <g.dump> <o.dump>` is the CELL TABLE: one cell per reference, keyed on
`(name, span, field, parent-kind)`, with `B`/`b` = carries `vpiActual` **at its
OWN CHILD DEPTH** (`indent+2`) or not. A **differing count**, not the table, is
each arm's verdict.

### 3.1 The brief's eight arms — a1…a8, ALL BYTE-IDENTICAL, control vs FINAL

| arm | what it asks | `ours.uhdm` md5 ctl → FINAL | dump ±, both binaries | verdict |
|---|---|---|---|---|
| a1_witness | the uvm shape: unnamed `begin` in a class method, inside an `if` | `27750557ab15` → same | 11 | **IDENTICAL** |
| a2_named | `begin : blk` — does the label enter the fullname? | `64b8122b6a12` → same | 11 | **IDENTICAL** |
| a3_scope | initial / always / package fn / module fn / module task | `4150ca4b544f` → same | **−2 (dumps byte-identical, 0 heads)** | **IDENTICAL** |
| a4_nested | two deep, different names; two siblings, SAME name | `b2ed28d6b39a` → same | 11 | **IDENTICAL** |
| a5_types | string/int/byte/vector/enum/struct/class handle/dyn array/typedef | `f5e69e07f400` → same | 42 | **IDENTICAL** |
| a6_multi | two on one decl; an INITIALIZER | `dce3448b0f49` → same | 11 | **IDENTICAL** |
| a7_forkfor | `fork`/`join` arm; `for`-body block (the over-fire trap) | `22bd7c04895d` → same | 17 | **IDENTICAL** |
| a8_negctrl | **NEGATIVE CONTROL**: block with NO decls; function-level local | `2dbfa185ef5c` → same | 11 | **IDENTICAL** |

**The negative-control cells are byte-identical, and so is every other a-arm.**
The a-arms' residual dump `±` is three UNRELATED pre-existing clusters, read and
named so they are not mistaken for this pass's:

* a class handle declared at MODULE scope is a `logic_net` **missing its
  `ref_typespec` → `class_typespec`**, and the top-level `class_typespec` is
  emitted **twice** in golden and once by us — 11 lines, present in every a-arm
  that declares a class, and absent from a3 (the only class-free arm, whose
  dumps are byte-identical).
* a5 only: golden emits a design-level `logic_typespec (byte_t)` with its
  `vpiTypedefAlias` and range for `typedef logic [7:0] byte_t` — 31 lines.
* a7 only: `task`'s `endln` is the whole body in golden (`6:3–30:10`) and the
  keyword alone for us (`6:3–6:9`) — not cmp-visible (`BaseClass::Compare`
  reads VpiType/VpiName/VpiDefName only), so a span figure is always a DUMP
  figure.

**What the a-arms DO answer**, since both sides agree letter for letter:

* **brief item 2 (naming).** A NAMED block's label **DOES** enter the variable's
  fullname: `work@named_c::f::blk::msg` vs the unnamed twin
  `work@named_c::f::msg2`. An UNNAMED block contributes **nothing**.
* **brief item 4 (nesting/shadowing).** Nested unnamed blocks add no component
  (`work@nest_c::f::outer`, `…::inner`), and two SIBLING blocks declaring the
  same name give **two distinct objects with IDENTICAL fullnames**
  (`work@nest_c::f::dup` twice), separated only by SPAN — which is exactly why
  a cell table must key on **name + span**. Class/package scopes use `::` all
  the way down, module scopes use `.` (`work@a4_nested.mdup`).
* **brief item 5 (types).** **All nine** get a full
  `ref_typespec → <kind>_typespec` chain: string, int, byte, `logic [7:0]`,
  `enum (e_t)`, `struct (s_t)`, `class (handle_c)`, the typedef name (a
  `logic_typespec`), and the dynamic array — which is a **PAIR**, the element
  `int_var` listed FIRST and then the `array_var`. The var's span is the NAME,
  the typespec's span is the TYPE, exactly as the brief describes for `msg`.
* **brief item 6 (initializer).** `string init = "x";` produces the
  `string_var` **and** a decl `assignment` at the declaration span
  (`14:14–14:24`) whose Lhs is the var itself.
* **brief item 7 (fork/for).** No over-fire hides there: a7 is byte-identical,
  and the `for`-with-inline-decl implicit wrapper (`ForLoopStatement` in
  `StmtEmit.cpp`) is still unwrapped exactly as before — the recorder attaches
  to the loop's **body** block, which is a real `StatementBlockSymbol`.

### 3.2 The arms that found and pinned the law — b1…b5

Differing cells, control → FINAL:

| arm | what it separates | ctl | FINAL |
|---|---|---|---|
| b1_argctrl | which symbol classes bind at `ctrlBodyDepth28 > 0`; in-body vs out-of-body vs package vs module | **2** / 57 | **0** / 57 |
| b2_shape | every block shape and depth (named, nested, siblings, for/while/repeat/case/else/fork/foreach) | **11** / 58 | **0** / 58 |
| b3_bound | plain-vs-control block boundary; named outer/inner both ways; deep nesting | **10** / 50 | **1** / 50 |
| b4_open | the cells the depth reading left open: receiver / `this.` / `super.` / task / virtual / return / nested-call / fork-in-if | **15** / 66 | **2** / 66 |
| b5_pos | **OVER-FIRE GUARD**: the same call POSITIONS at depth 0 | **0** / 46 | **0** / 46, `ours.uhdm` **BYTE-IDENTICAL** |

**b1 — the discriminator table** (`sink`/`sinki` are package functions;
`vpiArgument func_call` = a user call's argument):

| cell | line | depth | golden | ours ctl | ours FINAL |
|---|---|---|---|---|---|
| `blkloc` block local | 29:14 | 1 | **B** | b (UNDERBIND) | **B** |
| `bodyloc` method-body local | 30:14 | 1 | b | b | b |
| `farg` formal | 31:14 | 1 | b | b | b |
| `obj` formal int | 32:15 | 1 | b | b | b |
| `blkloc` in `$display(...)` | 33:18 | 1 | b | b | b |
| `blkloc` as assignment Lhs | 34:9 | 1 | b | b | b |
| `bodyloc`, block with NO decl | 38:14 | 1 | b | b | b |
| `gblk` block local, NON-static method | 48:14 | 1 | **B** | b (UNDERBIND) | **B** |
| `prop` class property | 49:14 | 1 | b | b | b |
| `bodyloc` | 22:12 | 0 | B | B | B |
| out-of-body `ob::f` — every cell | 59–67 | 0/1 | B | B | B |
| package fn `pf`, module fn `mf` — every cell | 74–101 | 0/1 | B | B | B |

**b2 — every block shape.** All 11 UNDERBINDs were `vpiArgument func_call` on
the block's OWN local, at depths 1 and 2, in `if`, `else`, named-vs-unnamed,
sibling, `for`, `while`, `repeat`, `case` item, `case default` and `foreach`
bodies. The **three golden-BARE** cells in the same arm are the law's edges:
`nmd::nmdblk` (NAMED block, 24:14), `outr` read one level deeper (36:16), and
`mbody` (method-body local at depth 2, 37:16). Two cells were **already
correct** and must stay so: `d0blk` (plain block at depth 0, 17:14) and
`frkblk` (fork arm at depth 0, 99:16) — `fork` raises no depth.

**b3 — the boundary.** `pln1` (declared in a PLAIN `begin` nested inside a
control body, 23:16) and `ctl1` (declared in the control body, read from that
plain inner block, 24:16) are **both golden-B and both fixed**, which kills the
reading "the declaring block must BE the current control body". The three-deep
D6 cells settle the rest: `l1`@71 B, `l2`@75 B, `l3`@79 B (each in its own
block) while `l2`@80 and `l1`@81 (read from deeper) stay bare — and all five now
match.

**b4 — the open cells, all fixed.** Receiver-qualified STATEMENT call
`o.bm(r2)` (58:14), `this.im(t4)` (68:17), `super.bm(s3)` (135:18), unqualified
inherited `bm(s3)` (136:12), a TASK call arg (77:14), a VIRTUAL method (87:14),
a sibling-method call (45:12) — golden binds all seven and so do we now.
**The EXPRESSION-position cells correctly stay bare**: `wrap(r2)` on an
assignment RHS (59:19), `return wrap(n7)` (96:21), and the two-deep
`wrap(str8(wrap(n8)))` (106:29) — the § classInBodyBareCallArgStmtOnly53 gate
already withheld the window there and the carve-out inherits it. **b5 exists to
prove that inheritance did not widen**: same positions at depth 0, dumps
byte-identical control-to-FINAL.

**A REFUTATION IN ARM DESIGN, recorded because it nearly produced a fake
golden.** Surelog emits `[ERR:CP0332] Function "sink" is not defined for
variable "this" of type shp` for an UNQUALIFIED package-function call written
inside some class bodies (b5:26, and b4's header records the same for a DERIVED
class). A golden produced under an error is an error-recovery, not a golden.
b4 therefore puts every cell except the deliberate `super.` one in a
NON-derived class; b5 kept the unqualified form and DID trip CP0332 — its dumps
come out byte-identical on both sides anyway, so it is still a valid
over-fire guard, but its depth-0 receiver cells should be re-measured with
`pb5::sink` before anything is built on them. **Ranked R4.**

---

## 4. THE NEW HEAD (SimpleUVM + Scoreboard), CHARACTERISED

cmp **29 → 54** lines, still **1** head. cmp length is a **HEAD-DEPTH** measure,
not a distance: the new head is simply a bigger object.

```
LHS: ref_var: (uvm_pkg::uvm_set_get_dap_base::get), id:173208, line:71:26, endln:71:27
     |vpiParent: \_function: (…::get), id:173207, line:71:4, endln:71:16
     |vpiTypespec: \_ref_typespec → |vpiActual: \_int_typespec: , line:80:45, endln:80:46
RHS: int_var: (uvm_pkg::uvm_set_get_dap_base::get), id:105718, line:71:26, endln:71:27
     |vpiParent: \_function: (…::get), id:105717, line:71:4, endln:71:34
     |vpiTypespec: \_ref_typespec → |vpiActual: \_int_typespec: , line:71:26, endln:71:27
     |vpiSigned:1
```

uvm-1.2 `src/base/uvm_set_get_dap_base.svh:71`,
`pure virtual function T get();` in a **parameterised** class. THREE differences
in one object: golden makes the return variable a **`ref_var`**, we make an
**`int_var` with `vpiSigned:1`**; golden's `int_typespec` is at **80:45** (the
specialisation's type-parameter site) and ours at the return-var's own span; and
the `function`'s `endln` is the prototype's `:16` in golden and `:34` for us.
`SeqDriver` and `BuildUVMPkg` heads are **byte-identical** control-to-FINAL
(85 and 58 lines) — this pass did not touch them.

### 4.1 The three distances, never conflated (SimpleUVM, default)

| measure | control | FINAL |
|---|---|---|
| cmp line count = **HEAD DEPTH** (1 head both) | 29 | 54 |
| `diff -u` content = **alignment-sensitive** | 238559 | **238341** (−218) |
| **MULTISET** distance, correctly computed (§7) | 140957 | **140871** (−86) |
| **PER-SHAPE `grep -Fxc`** of the target `string_var` line | golden 3, ours **2** | golden 3, ours **3** |
| `|vpiActual:` total | golden 54189, ours **52942** | ours **52987** (+45) |

The per-shape count is the only attributable one, and it is exact.

---

## 5. GATE 5 — THE BYTE VERIFIER, AND EVERY MOVER ATTRIBUTED BY CONTENT

`byteverify.sh` against the **pristine 3500bc4 workdir I built myself**, both
corpora, `SELFCHECK=1 SELFCHECK1=1`:

| corpus | paths | MOVERS | SELFCHECK (all-vs-one) | SELFCHECK1 (one corrupted) |
|---|---|---|---|---|
| uhdm2rtlil | 679 = 679, PATH_SETS_IDENTICAL | **0** | 678 / 679 flagged | **1** |
| surelog | 953 = 953, PATH_SETS_IDENTICAL | **7** | 952 / 953 flagged | **8** = 7 real + 1 corrupted |

Both controls fire on both corpora, so a "0 movers" reading here is a
measurement and not a silence.

The 7 movers, attributed **BY CONTENT** (`ct9movers.sh`, then `mv57.sh` for
pure-addition and `cov57.sh` for golden coverage). The brief warned that the UVM
alias/typespec population is BUILD-DEPENDENT
(`r10oth8repro/README.md` §0.1–0.2) — **it did not fire this pass: 0
`vpiSigned`, 0 `class_typespec`, 0 `vpiTypedefAlias` changed lines on every
mover.**

| row | dump lines pris → patched | DELETED | ADDED | verdict | added instances covered by golden |
|---|---|---|---|---|---|
| default/SimpleUVM | 1100381 → 1100471 | **0** | 90 | PURE ADDITION | **90 / 90** |
| default/Scoreboard | 1096969 → 1097059 | **0** | 90 | PURE ADDITION | **90 / 90** |
| default/SeqDriver | 1808892 → 1808982 | **0** | 90 | PURE ADDITION | **90 / 90** |
| default/BuildUVMPkg | 1076280 → 1076410 | **0** | 130 | PURE ADDITION | **130 / 130** |
| testflags/SimpleUVM | 1100441 → 1100531 | **0** | 90 | PURE ADDITION | **90 / 90** |
| testflags/SeqDriver | 1808952 → 1809042 | **0** | 90 | PURE ADDITION | **90 / 90** |
| testflags/BuildUVMPkg | 1076280 → 1076410 | **0** | 130 | PURE ADDITION | **130 / 130** |

Every mover's 90 (or 130) lines are **45 (or 65) `|vpiActual:` markers plus one
variable-header line each** — one new binding per pair, nothing else. The shapes
name the sites: `uvm_object_registry::create::msg` (the target),
`uvm_component_registry::create::msg`,
`uvm_report_catcher::uvm_process_report_message::{composed_message,rs}`,
`uvm_default_report_server::process_report_message::m`,
`uvm_report_handler::do_print::{_total_cnt,l_str}`,
`uvm_reg_single_access_seq::body::{status,v}`,
`uvm_reg_sequence::body::reg_item`, `uvm_heartbeat::m_hb_process::s`,
`uvm_by_level_visitor_adapter::accept::t`,
`uvm_tlm_generic_payload::do_{pack,unpack}::__array`,
`uvm_objection::m_report::sname`, `uvm_reg_predictor::write::predict_kind`,
`uvm_reg_mem_hdl_paths_seq::__m_uvm_field_automation::max__`.

`mv57.sh`'s SELFCHECK (patched vs patched-minus-one-line) reports exactly
`1 DELETED / CARRIES DELETIONS` on every row, and `cov57.sh`'s SELFCHECK
(an injected line golden cannot have) reports it as `OVER-FIRE … NOT
COVERED=1`. Neither verifier can read green on a bad input. *(Note: `cov57.sh`'s
awk exits 5 on an over-fire, but that status is swallowed when the output is
piped through `grep`; the `OVER-FIRE` line is the signal to read.)*

### 5.1 A "multiset excess" that is NOT an over-fire — attributed BY FIELD

`|vpiActual:` counted globally moved 52942 → 52987 while golden-only fell 88 and
**ours-only rose by 2**, which looks like an over-fire. It is not, and the way
to see that is a **per-FIELD census at own child depth**, never a whole-dump
multiset. One shape carries all of it:
`\_array_var: (uvm_pkg::uvm_tlm_generic_payload::do_unpack::__array), line:3657:11, endln:3657:18`
— total occurrences golden 24, ours 28 → 30. Split by the field it hangs off:

| field it hangs off | golden | ours ctl | ours FINAL |
|---|---|---|---|
| `|vpiActual:` | **6** | 4 | **6** |
| `|vpiParent:` | 12 | 12 | 12 |
| `|vpiVariables:` | 6 | 6 | 6 |
| `|vpiLhs:` | **0** | **6** | **6** |

Our two new `vpiActual`s take that field from 4 to **exactly golden's 6**; the
whole excess is the **pre-existing** 6 `vpiLhs` occurrences (our `__array =
new[...]` decl assignment takes the `array_var` as its Lhs where golden takes a
`ref_obj`), which this pass did not touch. **A generic header line shared by
four fields absorbs the attribution — split by field before calling anything an
over-fire.** The pre-existing `vpiLhs` shape is ranked **R3**.

---

## 6. THE FIVE GATES

### GATE 1 — BUILD
`cmake --build /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10uvm57/build -j 6`
(ABSOLUTE path). **`[100%] Linking CXX executable slang-uhdm` appeared in the
output** — a build that compiles nothing also exits 0, so the link line is the
gate. In a **SEPARATE** command: baseline `71bd294b421e23a4feb7807f8c5b7a8f`
asserted **32 hex characters** (a missing or malformed baseline is FATAL, exit 9
— an empty baseline once made this very assertion print OK against nothing) →
FINAL `b40329b21fb425f8a6efcd2d7d43f195`. **md5 CHANGED: OK.**

### GATE 2 — GOLDENS
`tests/check_goldens.sh`: **23 PASS / 0 FAIL**.
NEGATIVE CONTROL, quoted: `SLANG_UHDM=/bin/false bash tests/check_goldens.sh`
→ **`PASS=0 FAIL=23`**, e.g.
`FAIL wreduce_test0 (diff …/tests/golden/wreduce_test0.dump /tmp/tmp.9eUX4Nbr1o/slang.dump)`.

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`, own `--out`/`--workdir`
`679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`; dump column
`496 match / 183 differ / 52 blank`. Judged as WHOLE ROWS **including the dump
column** by `ct8rows.sh` against the committed baseline:

```
baseline: 732 lines = 731 ROWS (the header is not a row)
fresh   : 732 lines = 731 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, `--mode both`, `--jobs 2`
`default 467 CMP_EQUAL / 13 CMP_NOTEQUAL`, `testflags 463 / 10`, dump
`match 225` (default) `/ 165` (testflags), 5 DEFERRED in both modes.
`ct8rows.sh` against the committed baseline:

```
baseline: 1589 lines = 1588 ROWS (the header is not a row)
fresh   : 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

### GATE 5 — BYTE VERIFIER, both corpora
§5. `0 / 679` and `7 / 953`, both controls firing, all 7 attributed.

### 6.4 CANARIES — both scripts, both corpora, EXPECT_UNKNOWN declared

**The script is named**, because six files share the basename `canaries.sh`
with different name lists: **`tools/probe/r10uvm52repro/canaries.sh`** (33
names).

| script | corpus | result |
|---|---|---|
| `r10uvm52repro/canaries.sh` | uhdm2rtlil | `ok=8 changed=0 absent=0 unknown-names=25` |
| `r10uvm52repro/canaries.sh` | surelog | `ok=52 changed=0 absent=0 unknown-names=7` |
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=6` | uhdm2rtlil | `ok=1 changed=0 absent=0 unknown-patterns=6` → PASS |
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=1` | surelog | `ok=58 changed=0 absent=0 unknown-patterns=1` → PASS |

**changed=0 and absent=0 on all four runs.** The unknown counts are the
documented corpus split (25 surelog-only names on the u2r csv, 7 u2r-only names
on the surelog csv, and ctcan2's own measured 6/1).

**Checked BY NAME as the brief requires:**

```
InterfaceModPort     default   OK  CMP_EQUAL/differ
InterfaceModPort     testflags OK  CMP_EQUAL/differ
BlackParrotComplex   default   OK  CMP_EQUAL/differ
BlackParrotComplex   testflags OK  CMP_EQUAL/differ
```

(both are surelog-corpus rows; on the u2r csv they correctly print
`UNKNOWN-NAME`, which is the documented split and not a miss).

**The audit of the guards themselves** —
`r10uvm55repro/canaudit.sh r10uvm52repro/canaries.sh r10oth7repro/ctcan2.sh`:

```
---- audited=29  UNCOVERED=0  FENCE-BREACH=0
PASS: every brief-protected name and family is carried by a script that RUNS here.
UnsignedParam / HierPathEval / FileLocalParam / TopParam: not dispatched by any driver (OK)
```

---

## 7. REFUTATION 3 — `r10uvm55repro/msdist.sh` IS BROKEN

`msdist.sh` is the campaign's designated "no alignment at all" instrument, and
its own header sells it as the arbiter of "did we get closer". **It can report
`MULTISET DISTANCE 0` for two dumps that differ by 90 lines.** Run on this
pass's SimpleUVM mover:

```
$ msdist.sh <pristine.dump> <patched.dump>
golden-only line instances: 0
ours-only   line instances: 0
MULTISET DISTANCE (sum |dg-do|): 0
g lines=1100381  o lines=1100471          <-- its OWN output contradicts its verdict
```

The bug: it counts with `sort | uniq -c` over the **RAW** lines and only then
collapses indentation (`awk '{c=$1;$1="";print c"\t"$0}'` rebuilds `$0` with a
single-space OFS), after which it stores the per-key count with an
**ASSIGNMENT** — `g[$2]=$1`. Two raw lines that differ only in DEPTH collapse to
the same key, so the later one **overwrites** the earlier one's count instead of
adding to it. 350100 distinct raw lines collapse to **136799** keys, which is
the size of the hole. The identical awk with `+=`:

```
WITH += : pristine-only=0  patched-only=90
```

I did **not** patch `r10uvm55repro` (out of this pass's deliverable). Instead
`mv57.sh` and `cov57.sh` here strip indentation **before** counting and
accumulate with `+=`, and both carry a self-check that fires. **Consequence for
the campaign: no `msdist.sh` figure should be quoted again without
re-derivation, and the multiset figures in this README come from the corrected
instrument.**

---

## 8. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `a1…a8_*.sv` | the brief's eight arms (witness, named, scope, nested, types, multi, fork/for, negative control) |
| `b1…b5_*.sv` | the arms that found and pinned the law (arg/depth, block shapes, boundary, open cells, position over-fire guard) |
| `arm.sh` | build ONE arm's golden + ours, dump both (`sed 1d`), cmp both. Binary never defaulted; missing database is exit 6, never a verdict |
| `cells.py` | the CELL TABLE: one cell per reference, `vpiActual` read at OWN CHILD DEPTH, differing count last |
| `mv57.sh` | is a mover a PURE ADDITION or does it carry DELETIONS? Correct multiset (see §7). `SELFCHECK=1` deletes one line and must report 1 DELETED |
| `cov57.sh` | is every ADDED line a line GOLDEN ALSO HAS? Golden resolved from the row's own `cmds.txt`. `SELFCHECK=1` injects a line golden cannot have |

Control-binary identity, printed on both trees:
`md5sum build/slang-uhdm .claude/worktrees/r10uvm57pris/build/slang-uhdm` →
`71bd294b421e23a4feb7807f8c5b7a8f` twice.

**THE DELIVERED PATCH WAS RE-APPLIED AND RE-BUILT INDEPENDENTLY.** `git apply
--check` clean on a THIRD pristine 3500bc4 worktree (`r10uvm57ver`), then
`git apply` + a full `cmake --build` there — `[100%] Linking CXX executable
slang-uhdm` — produced
`b40329b21fb425f8a6efcd2d7d43f195`, **byte-identical to the gated FINAL
binary**. So every gate number above belongs to exactly what the patch
contains, and nothing in this write-up depends on an unshipped edit.

---

## 9. RANKED RESIDUE

**R1 — the if/case CONDITION twin of this pass's law. 1 arm cell, unfixed,
measured.** `b3 f:56` — `if (obj==3) begin string cndv; if (cndv=="c") sink(cndv); end`:
the reference to `cndv` in the **inner `if`'s CONDITION** (56:13, `vpiOperand
operation`) is golden-**B** and ours bare, control **and** FINAL. It is the same
depth-equality shape but outside the § classArgBind12 window
(`classArgBindDepth12 == 0`), so this pass's carve-out cannot see it. An
if/case condition already clears `classMethodNoBind` in `StmtEmit`; the missing
step is that it does not clear § controlBodyNoBind28. **Cheapest next law, and
b3 already contains the arm.** Risk: the §28 comment records that
`uvm_scope_stack::get`'s `if (v != "" && …)` MUST stay bare, so the depth-equality
and unnamed-block conditions are load-bearing there — measure that row before
widening.

**R2 — the new head: the return variable of a `pure virtual function T get()`
in a parameterised class.** `uvm_set_get_dap_base.svh:71`. Golden `ref_var` +
`int_typespec` at the SPECIALISATION site (80:45); ours `int_var` +
`vpiSigned:1` + own-span typespec; and the `function`'s `endln` is the
prototype's in golden. Blocks SimpleUVM and Scoreboard, and is very likely a
whole family (every `pure virtual` returning a type parameter).

**R3 — the block-local dynamic-array decl assignment takes the `array_var` as
its Lhs where golden takes a `ref_obj`.** 6 occurrences on
`uvm_tlm_generic_payload::do_unpack::__array` alone (§5.1); it is what makes our
per-shape count exceed golden's, and `StmtEmit.cpp`'s `emitDeclStmt9` already
carries a RANKED-RESIDUE comment about exactly this var-as-Lhs choice for the
PROGRAM case. Cheap, and it removes a standing source of false over-fire alarms.

**R4 — arm-hygiene debt, not a product defect.** `b5_pos.sv` trips Surelog's
`[ERR:CP0332]` on the unqualified `sink(...)` inside a class method; its dumps
happen to be byte-identical so it remains a valid over-fire guard, but its
depth-0 receiver cells should be re-measured with `pb5::sink` before any law
leans on them.

**R5 — the a-arm background residues, each already isolated by an arm.**
(a) a class handle declared at module scope is a `logic_net` missing its
`ref_typespec → class_typespec`, plus a doubled top-level `class_typespec`
(11 lines in every class-bearing a-arm); (b) a design-level
`logic_typespec` + `vpiTypedefAlias` missing for `typedef logic [7:0] byte_t`
(a5, 31 lines); (c) `task`/`function` `endln` = whole body in golden vs keyword
for us (a7, b2, b4 — not cmp-visible).

**R6 — golden names a reference inside an EXPRESSION-position receiver call
with the receiver path in its fullname**: `pb4::shp::e2::o.bm2::r2` vs our
`pb4::shp::e2::r2` (b4 59:31). The only differing cell left in b4, unchanged by
this pass, and it is a NAMING law, not a binding one.
