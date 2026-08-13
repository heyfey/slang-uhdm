# r10uvm65 — § emptyFnBodyEndLabelBegin65: the briefed 13-line head **CLEARED on all THREE target rows** — 7 movers, all 7 predicted; 27 objects shipped and every one byte-identical to golden — and **MY OWN FIRST LAW WAS WRONG AND A BUILT, MEASURED BINARY WAS THROWN AWAY TO FIX IT**

**FIRST LINE, as the standing rules demand.** `SimpleUVM` and `Scoreboard`
**DID NOT CONVERT**: they are `CMP_NOTEQUAL` before and after, and no conversion
was expected. `results/gate_uhdm2rtlil.csv` (**731** rows) and
`results/golden_surelog.csv` (**1588** rows) are **byte-identical** to the
committed baselines in **both** of my sweeps, patched and pristine — whole ROW,
dump column included.

**SECOND LINE.** The briefed head is **GONE from all three target row-modes**
(`SimpleUVM/default`, `SimpleUVM/testflags`, `Scoreboard/default`). All three
went from **13 cmp lines to 262** and now head on the same different, deeper
object that was masked behind this one:
`begin (uvm_pkg::uvm_cause_effect_link::get_link) @255:7-255:29`, which is
another law (§6, residue 1). The rising line count is HEAD DEPTH, not distance:
`grep -c do_open` on all three fresh cmp logs is **0**.

**THIRD LINE, and it is the one this pass exists to record.** I wrote a law,
built it, measured it, watched the head clear on all three rows — **and the law
was still wrong.** My first gate said *FUNCTION only*, on the strength of eight
golden-bare TASK cells across b1/b2. The whole-design per-cell audit of
SimpleUVM then found golden's

```
1798  task uvm_reg_block::readmemh(string filename);
1799     // TODO
1800  endtask: readmemh        golden: begin @1800:10-1800:18  == `readmemh`
```

— a **task** carrying exactly the object I had just declared tasks never get.
Every one of my eight bare task cells happened to be written `task foo();`, with
**empty parens**; `readmemh` has a formal. Arm `b3_taskport.sv` separates the two
candidate discriminators cell by cell and the answer is the **tf_port_list**, not
the subroutine kind and not out-of-body-ness. The wrong binary
(`0f1b1b15702ba3d164dce0efdb63b9b3`) shipped **7** objects; the shipped one
(`caf4aa4b69f3fa155eb3d2b0afb415b3`) ships **27**. **Had I stopped when the head
cleared, I would have landed a law that was right about the head and wrong about
18 of the 25 subroutines it should cover.** The head is not the law.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order; `ct65arm.sh` and `rowheads.sh` print that they did on every run.

Base **575f51d**. Worktree `/tmp/wt_r10uvm65`; pristine control worktree
`/tmp/wt_r10uvm65pris`, configured and built by me at the same commit. Both
`git rev-parse HEAD` print `575f51d14dace52ccfff05e1037eb527d0ad3b10`.

| binary | md5 | what it is |
|---|---|---|
| CONTROL (pristine 575f51d) | `2dc0aff2ad7a0e04c304fcb71923de7b` | my own build of the base commit |
| INTERMEDIATE (REFUTED, discarded) | `0f1b1b15702ba3d164dce0efdb63b9b3` | the "FUNCTION only" gate — head cleared, law wrong |
| **FINAL (shipped)** | **`caf4aa4b69f3fa155eb3d2b0afb415b3`** | every gate number below was measured on THIS binary |

BUILD DIR (absolute): `/tmp/wt_r10uvm65/build`. The link line
(`[100%] Linking CXX executable slang-uhdm` → `[100%] Built target slang_uhdm`)
was waited for and read before any md5 was taken; every md5 was asserted in its
own command and every one is 32 hex digits. `git stash` was never used. The four
slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched — `canaudit.sh` proves it mechanically
(FENCE-BREACH=0). `GOLDEN_DEFER` left **UNSET** (echoed as `[UNSET]` at every
sweep launch; **5 DEFERRED** in both surelog modes, as in the baseline). slang
was not patched. `results/*.csv` were only ever read.

---

## 0. THE LAW

### § emptyFnBodyEndLabelBegin65

*A subroutine whose body is **SYNTACTICALLY EMPTY** and which is closed with a
written **`end… : <label>` END LABEL** carries, in golden, a `vpiStmt`: an
**EMPTY `begin`** whose **whole span IS THE LABEL'S TOKEN**, whose `vpiParent` is
the subroutine and whose only other field is the subroutine's `vpiFullName`. A
**FUNCTION** gets one unconditionally; a **TASK** gets one only if it also wrote
a **NON-EMPTY `tf_port_list`**. The class **CONSTRUCTOR never** gets one.*

```
544  protected virtual function void do_open(uvm_tr_stream stream,
545                                          time open_time,
546                                          string type_name);
547  endfunction : do_open
                    ^^^^^^^  golden:  begin @547:18-547:25
```

* **DIRECTION: ADD ONLY.** The patch mints one object per fire site, deletes
  none, re-parents none, moves no span, and touches no binding. **Measured, not
  asserted**: across all 8 databases `mv65.sh` reports `REMOVED line
  instances=0`, and the only ADDED line shapes are `|vpiStmt:`, the `begin`
  header, `|vpiParent:`, the parent `function`/`task` back-reference line and
  `|vpiFullName:<fullname>` — five lines per fire site, 135 per UVM database
  (§4).
* **The four terms and the four things that are NOT terms** are each a measured
  arm cell (§2), never an inference.
* `grep -rn 'emptyFnBodyEndLabel65' src/ include/` → declared once, defined
  once, called from **one** site.

### STATED GATE == CODE GATE — read off the source, not the comment

| | |
|---|---|
| **the whole predicate** | `TaskFuncEmit.cpp` `emptyFnBodyEndLabel65(sub)`: `!Constructor` · `sub.getSyntax()` kind is `FunctionDeclaration` or `TaskDeclaration` · `fd.items.empty()` · if `subroutineKind == Task` then `fd.prototype->portList && !portList->ports.empty()` · `fd.endBlockName` with a located `name` token → returns that clause |
| **the whole call site** | after every body-drop rule and the param wrapper: `if (!body) if (auto* ebn65 = emptyFnBodyEndLabel65(sub)) { eb65 = s.MakeBegin(); eb65->VpiParent(tf); eb65->VpiFullName(fullName); setLoc(eb65, ebn65->name.range()); body = eb65; }` |
| **not in the gate** | no scope test · no `virtual`/`protected`/`static`/`automatic` test · no return-type test · no FUNCTION port-list test · no out-of-body test · no name test · no `Stmts` vector (golden's block has none, so ours has none) · no new state, no new counter, no new member |

**Why the gate is SYNTAX (`items.empty()`) and not "the body has no statements".**
Our emitter hands `body == nullptr` to this point for **three** different
sources: a truly empty body, a body holding only a variable **declaration**, and
a body holding only a **null statement `;`**. Golden gives the block to the
**first only** (c01 fires; c17, c21, d03 are golden-BARE). A statement-level gate
would have over-fired on three measured cells. `FunctionDeclarationSyntax::items`
is the one test that separates them, and it is also the test the end label
belongs to.

**Why the TASK term is the PORT LIST and not the node type.** `TaskDeclaration`
and `FunctionDeclaration` share the same syntax node TYPE in slang, so the kind
alone cannot carry it. The mechanism is the off-by-one
§ constructorBodyElementShift27 already measures for constructors: with no
`tf_port_list` node Surelog's body walk starts one element late and consumes the
end-label node as if it were the port list, leaving nothing to compile. A
FUNCTION carries an extra `data_type_or_void` element and stays in step, which is
why it fires with `()` (c01), with no parens at all (e27) and with no written
return type (e12/e16/e19). Written parens holding nothing are **not** a
`tf_port_list`: `task t();` (e02) and `task t;` (e28) are both bare, so the test
is `ports NON-EMPTY`, not `portList != nullptr`.

---

## 1. WHAT WAS MEASURED BEFORE ANY CODE WAS WRITTEN

### 1.1 The head, on my own pristine build

```
rowheads.sh /tmp/r65_ctl_wd …   SimpleUVM Scoreboard
  SimpleUVM   default     13 cmp lines  1 head
  SimpleUVM   testflags   13 cmp lines  1 head
  Scoreboard  default     13 cmp lines  1 head
  Scoreboard  testflags   SKIP-NOFILE (SLANG_REJECT, no database — reported, not hidden)
```

All three logs are the same 13 lines up to object ids:

```
LHS:
decompile:
begin: (uvm_pkg::uvm_recorder::do_open), id:147278, line:547:18, endln:547:25
|vpiParent:
\_function: (uvm_pkg::uvm_recorder::do_open), id:147268, line:544:4, endln:544:13
|vpiFullName:uvm_pkg::uvm_recorder::do_open
                                          … (the same block printed twice)
RHS: <null>
```

### 1.2 THE CENSUS OF BOTH SIDES, span-keyed, BEFORE any missing-object claim

The brief offered three mechanisms — (a) golden has a block we drop entirely,
(b) both have it and the CHILDREN differ, (c) an end-label/name FIELD difference
— and asked which. **It is (a), and the census settles it in one grep.**

`grep -F "uvm_recorder::do_open)"` over both whole dumps: **golden 6 lines, ours
4**. Golden's six are four `function` cross-references + the `begin` header + the
`begin`'s own `vpiParent` back-reference; ours are the four cross-references and
nothing else.

| | golden `/tmp/r65_g.dump` | ours `/tmp/r65_o.dump` |
|---|---|---|
| `function do_open` header, span, `vpiName`, `vpiFullName`, `vpiMethod:1`, `vpiVisibility:2`, `vpiVirtual:1` | 815716..815723 | 809463..809470, **identical** |
| all three `io_decl`s with their `ref_typespec` → `class_typespec` / `time_typespec` / `string_typespec` | 815724..815762 | 809471..809509, **identical** |
| **`vpiStmt:` → `begin @547:18-547:25`** | **815763..815767** | **ABSENT — the next line is the following `vpiMethod:`** |

The block golden emits carries **only** `vpiParent` and `vpiFullName`: no
`vpiName`, and **no `Stmts` at all**. It is empty on golden's side too.

### 1.3 THE BAIL THE BRIEF POINTED AT DOES NOT EXIST

Read first, as the rules require. The emitter's own note list for this compile:

```
slang-uhdm: unsupported constructs encountered:
  expression kind: UnboundedLiteral
  system method call: size
```

Two entries, neither at line 547, neither a block or a statement. **No bail is
involved anywhere near the head.** The brief's framing — *"a begin whose entire
content we drop or fold away renders EMPTY on one side"* — is false in the way
that matters: **golden's block is empty as well.** Nothing is dropped from
inside the block; the BLOCK is what is missing. `do_open`'s source body is three
lines of prototype and an `endfunction`, and there is no content to lose.

### 1.4 THE SPAN IS THE END LABEL, read off the source

`uvm_recorder.svh:547` is `   endfunction : do_open`. Columns 4–14 are
`endfunction`, 16 is the colon, and **18–24 are `do_open`, so `endln` is 25**.
Golden's `547:18-547:25` is the label token, exactly. Confirmed independently on
`endfunction:d04_nospace` (arm d04, no spaces around the colon → `23:13-23:24`)
and on `endtask: readmemh` (`1800:10-1800:18`).

---

## 2. THE FIELD-POLICY GRID, cell for cell

`ct65cells.py <g.dump> <o.dump>` finds every `function`/`task`, keeps each at its
**fullest occurrence**, reads **own-child-indent** fields only, and reports what
sits at `vpiStmt` on each side — by KIND **and** SPAN **and** emptiness (`*E` =
a block with no `Stmts`). Traps encoded, each paid for earlier in this campaign:
an object is not a dump occurrence (uhdm-dump reprints it under every parent that
references it); own fields only (the same field text two indents deeper belongs
to a grandchild); a key present on one side only is `-NOOBJ-`/`UNMEASURED` and
**never** counts as agreement; "has a vpiStmt" is not the measurement, because
golden's empty block, a non-empty block and a bare statement are three different
answers.

`G` = golden. `pre` = ours pristine `2dc0aff2…`. `post` = ours shipped
`caf4aa4b…`. Every DIFF cell below moved DIFF→SAME; no cell moved the other way.

### 2.1 Arm `b1_empty.sv` — is there a block at all?

| cell | source | G | pre | post |
|---|---|---|---|---|
| c01 | `function void c01_f_lbl(); endfunction : c01_f_lbl` (class) | `begin@20:17-20:26*E` | `-NONE-` | **`begin@20:17-20:26*E`** |
| c02 | `task c02_t_lbl(); endtask : c02_t_lbl` | `-NONE-` | `-NONE-` | `-NONE-` |
| c03 | `function int …` (non-void return) | `begin@26:17-26:30*E` | `-NONE-` | **match** |
| c04 | `protected virtual function void …(int a, string b)` | `begin@29:17-29:31*E` | `-NONE-` | **match** |
| c05 | `function void …; endfunction` — **NO end label** | `-NONE-` | `-NONE-` | `-NONE-` |
| c06 | `task …; endtask` — no label | `-NONE-` | `-NONE-` | `-NONE-` |
| c07 | `function int …; endfunction` — no label | `-NONE-` | `-NONE-` | `-NONE-` |
| c08 | `protected virtual function void …(int a, string b); endfunction` — no label | `-NONE-` | `-NONE-` | `-NONE-` |
| c09 | body is an explicit `begin end` | `begin@46:5-47:8*E` | same | same |
| c10 | body is an explicit `begin : lbl end : lbl` | `named_begin@51:13-51:20*E` | same | same |
| c11 | body is ONE statement | `func_call@57:5-57:16` | same | same |
| c12 | body is TWO statements | `begin@63:5-63:17` (non-empty) | same | same |
| c13 | `function new(); endfunction : new` — **CONSTRUCTOR** | `-NONE-` | `-NONE-` | `-NONE-` |
| c15 | whole declaration on ONE line | `begin@71:53-71:66*E` | `-NONE-` | **match** |
| c16 | `static function void …` | `begin@75:17-75:29*E` | `-NONE-` | **match** |
| c17 | body is ONLY `int c17_v;` — a **DECLARATION** | `-NONE-` | `-NONE-` | `-NONE-` |
| c18 | module-scope function, label | `begin@87:17-87:26*E` | `-NONE-` | **match** |
| c19 | module-scope task, label | `-NONE-` | `-NONE-` | `-NONE-` |
| c20 | module-scope function, no label | `-NONE-` | `-NONE-` | `-NONE-` |
| c21 | module-scope function, decl-only body | `-NONE-` | `-NONE-` | `-NONE-` |
| c22 | package-scope function, label (**two views, both fire**) | `begin@100:17-100:26*E` | `-NONE-` | **match** |
| c23 | package-scope task, label | `-NONE-` | `-NONE-` | `-NONE-` |
| c24 | function in a class in a package | `begin@105:19-105:28*E` | `-NONE-` | **`begin@105:19-105:28*E`** (cell UNMEASURED: the FUNCTION's own span differs, §6 residue 3) |

### 2.2 Arm `b2_scopes.sv` — every scope, and the shapes with no body syntax

| cell | source | G | pre | post |
|---|---|---|---|---|
| d01 | `$unit`-scope function, label | `begin@12:15-12:27*E` | `-NONE-` | **match** |
| d02 | `$unit`-scope task, label | (golden emits **no object**) | `-NONE-` | `-NONE-` |
| d03 | body is ONLY a **null statement `;`** | `-NONE-` | `-NONE-` | `-NONE-` |
| d04 | `endfunction:d04_nospace` — no spaces | `begin@23:13-23:24*E` | `-NONE-` | **match** |
| d05 | `extern` prototype + **OUT-OF-BODY** definition | proto `-NONE-`; defn `begin@37:15-37:22*E` | `-NONE-` | **`begin@37:15-37:22*E`** (cell UNMEASURED: the definition's HOME differs, §6 residue 4) |
| d06 | OOB **task**, empty parens | (golden emits no defn object) | `-NONE-` | `-NONE-` |
| d07 | `pure virtual` — **no body syntax at all** | `-NONE-` | `-NONE-` | `-NONE-` |
| d08 | in-body control for d05 | `begin@33:17-33:27*E` | `-NONE-` | **match** |
| d09/d10 | `virtual` method on a base class and its **override** | `begin@45:17-45:22*E` / `begin@49:17-49:22*E` | `-NONE-` | **both match** (cells UNMEASURED, residue 3) |
| d11 | **interface**-scope function | `begin@55:17-55:27*E` | `-NONE-` | **match** |
| d12 | interface-scope task, empty parens | `-NONE-` | `-NONE-` | `-NONE-` |
| d13 | **program**-scope function | `begin@63:17-63:27*E` | `-NONE-` | **match** |
| d15 | `function automatic void` | `begin@71:17-71:25*E` | `-NONE-` | **match** |
| d17/d18 | function in an INSTANTIATED module (def **and** elab views) | `begin@78:17-78:24*E` / `begin@84:17-84:24*E` | `-NONE-` | **both match** |

### 2.3 Arm `b3_taskport.sv` — THE COUNTEREXAMPLE ARM

Built only because the whole-design audit refuted "FUNCTION only". It separates
(T1) a non-empty `tf_port_list` from (T2) out-of-body-ness, and tests (T3) the
function-side analogue (an omitted return type).

| cell | source | G | pre | post |
|---|---|---|---|---|
| e01 | **task** `e01_t_port(int a)`, in-body, label | `begin@26:15-26:25*E` | `-NONE-` | **match** |
| e02 | task `e02_t_noport()`, in-body, label | `-NONE-` | `-NONE-` | `-NONE-` |
| e03 | task, **module** scope, port | `begin@74:13-74:27*E` | `-NONE-` | **match** |
| e04 | task, **package** scope, port | `begin@63:13-63:27*E` | `-NONE-` | **match** |
| e05 | task, **`$unit`** scope, port | (golden emits **no object**) | `-NONE-` | `begin@69:11-69:26*E` — §6 residue 6 |
| e06 | task, **OUT-OF-BODY**, port (the corpus shape) | `begin@51:13-51:27*E` | `-NONE-` | **match** |
| e07 | function, port (control) | `begin@34:19-34:29*E` | `-NONE-` | **match** |
| e08 | task, port, **NO end label** | `-NONE-` | `-NONE-` | `-NONE-` |
| e09 | task, **interface** scope, port | `begin@85:13-85:26*E` | `-NONE-` | **match** |
| e10 | task, **OUT-OF-BODY**, **empty parens** | `-NONE-` | `-NONE-` | `-NONE-` |
| e12 | function, **no written return type**, port | `begin@37:19-37:30*E` | `-NONE-` | **match** |
| e13 | function `void`, port | `begin@39:19-39:29*E` | `-NONE-` | **match** |
| e16 | function, no return type, **no port** | `begin@42:19-42:37*E` | `-NONE-` | **match** |
| e17 | function, OUT-OF-BODY, port | `begin@59:17-59:31*E` | `-NONE-` | **match** |
| e18 | task, module scope, empty parens | `-NONE-` | `-NONE-` | `-NONE-` |
| e19 | function, module scope, no return type | `begin@79:17-79:32*E` | `-NONE-` | **match** |
| e20 | task, port written `input int a` | `begin@92:13-92:22*E` | `-NONE-` | **match** |
| e21 | `task automatic …(int a)` | `begin@95:13-95:23*E` | `-NONE-` | **match** |
| e22 | **`function new(int a)`** — constructor WITH a port | `-NONE-` | `-NONE-` | `-NONE-` |
| e23 | `virtual task …(int a)` | `begin@107:15-107:25*E` | `-NONE-` | **match** |
| e24 | `task automatic …(int a)` in a package class | `begin@109:15-109:26*E` | `-NONE-` | **match** |
| e25 | `function new()` — constructor, no port | `-NONE-` | `-NONE-` | `-NONE-` |
| e26 | **OOB** `function b3c4::new(int a)` — constructor | `-NONE-` | `-NONE-` | `-NONE-` |
| e27 | `function void e27_f_noparens;` — **NO PARENS AT ALL** | `begin@128:17-128:31*E` | `-NONE-` | **match** |
| e28 | `task e28_t_noparens;` — no parens | `-NONE-` | `-NONE-` | `-NONE-` |

**e22 / e25 / e26 together are why the constructor exclusion is unconditional**
and not a restatement of the port-list term: a constructor with a port, without
one, and out-of-body are all golden-bare, while every non-constructor function
with the same shape fires.

### 2.4 Arm totals (`ct65cells.py`, whole file, every subroutine)

| arm | pristine | shipped |
|---|---|---|
| `b1_empty.sv` | SAME=33 **DIFF=7** UNMEASURED=2 | SAME=40 **DIFF=0** UNMEASURED=2 |
| `b2_scopes.sv` | SAME=22 **DIFF=8** UNMEASURED=10 | SAME=30 **DIFF=0** UNMEASURED=10 |
| `b3_taskport.sv` | SAME=30 **DIFF=16** UNMEASURED=1 | SAME=46 **DIFF=0** UNMEASURED=1 |

And the arms' whole-dump `diff -u` content, which is the judge the cmp head
cannot be (`m_visited` hides everything behind a head):

| arm | pristine content lines | shipped | what is left |
|---|---|---|---|
| b1 | 51 | **8** | the c24 function-span law (4) + golden listing a decl-only body's var TWICE (4) |
| b2 | 90 | **51** | where an OOB definition LIVES, the `virtual`/`pure` span laws, `$unit` task listing, `vpiAutomatic`, program instance listing |
| b3 | 208 | **118** | the same families + the e05 `$unit` task object |

---

## 3. THE CENSUS-PREDICT, run BEFORE the verifier

`census65.py` scans SOURCE (comments and string literals stripped first) for
every site the four terms can fire on. It is deliberately independent of the
patch — predicting from the patched binary's own output is the measurement
restated, not a prediction. It states its own bound: **exact on distinct
SUBROUTINES, a LOWER bound on dump-line movers**, because a source scan cannot
know how many VIEWS (def / elab / package clone / OOB hoist) each subroutine is
emitted in.

**PREDICTION (UVM sources, i.e. every UVM-compiling test): 25 fire sites** —
`uvm_recorder` `do_open`/`do_close`/`do_free`, `uvm_tr_stream`
`do_open`/`do_close`/`do_free`, `uvm_reg_indirect_data::build` (7 functions);
`uvm_reg_block` `readmemh`/`writememh`, `uvm_vreg` ×4, `uvm_vreg_cbs` ×4,
`uvm_vreg_field` ×4, `uvm_vreg_field_cbs` ×4 (18 tasks).

**MEASURED: 27 emitted blocks = 25 distinct subroutines**, the two OOB tasks
`readmemh`/`writememh` each emitted in **two views**. The prediction is exact on
subroutines and the surplus is precisely the documented view multiplicity.

**PREDICTION (rest of the corpora): 8 sites in 7 directories** —
`u2r rp32/degu/r5p_csr.sv`, `Surelog tests/SimpleClass`, `tests/ConcatVal`,
`tests/PreprocUhdmCov`, `third_party/tests/Rp32`, and 3 in Opentitan
(`alert_esc_base_monitor`, `i2c_env_pkg` ×2).

**MEASURED: none of them moved, and every one has a stated reason** —
`rp32_r5p_csr` is `SLANG_REJECT` with **no database**; `SimpleClass`,
`ConcatVal`, `PreprocUhdmCov` and `Opentitan` are `SLANG_REJECT` in **both**
modes; `Rp32` has no row in this corpus. A fire site in a source file no test
successfully compiles cannot move a byte.

**PREDICTED MOVER SET, before the verifier ran:** the tests that both compile
`uvm_pkg.sv` and produce a database. Of the 28 UVM-referencing `.sl` files, 20
are `SLANG_REJECT`/`SURELOG_FAIL`/`NO_DATABASE`/`DEFERRED`, and 4 more
(`ApbSlave`, `YosysMarlann`, `YosysRiscv`, `YosysVerx`) name `uvm-1.2` only on an
`+incdir+` and compile `svunit_pkg.sv`, not `uvm_pkg.sv` — verified on their own
`cmds.txt`. That leaves **`BuildUVMPkg`, `Scoreboard`, `SeqDriver`,
`SimpleUVM`**, i.e. **7 databases** (Scoreboard/testflags is SLANG_REJECT).
**The verifier found exactly those 7.**

---

## 4. THE MOVERS, PER SHAPE, BY MULTISET

`mv65.sh` reports three different numbers and never conflates them: the
multiset distance to golden before and after; ADDED and REMOVED line
**instances**, separately and never netted; and a three-way
golden/pristine/patched count of every added line TEXT.

All 7 movers, every one measured (`mv65.sh`, LHS always golden):

| mover | multiset distance to golden, pristine → patched | ADDED | REMOVED |
|---|---|---|---|
| `default/BuildUVMPkg` | 81115 → 81030 (gain 85) | 135 | **0** |
| `default/Scoreboard` | 134770 → 134669 (gain 101) | 135 | **0** |
| `default/SeqDriver` | 367603 → 367482 (gain 121) | **155** | **0** |
| `default/SimpleUVM` | 144463 → 144362 (gain 101) | 135 | **0** |
| `testflags/BuildUVMPkg` | gain 85 | 135 | **0** |
| `testflags/SeqDriver` | gain 121 | **155** | **0** |
| `testflags/SimpleUVM` | gain 101 | 135 | **0** |

`ADD-ONLY HOLDS: REMOVED == 0` on all seven. A law claimed to be add-only is
falsified by a single removed shape, so the two figures are never netted.

**The 20 extra lines on `SeqDriver` are the PACKAGE-CLONE view, and they are the
single most load-bearing measurement in §4.** `SeqDriver` has
`package adpcm_pkg; import uvm_pkg::*;`, so our emitter re-emits uvm_pkg's class
methods as CLONES into it (§ pkgCloneHierBind9's machinery). Golden carries the
empty block in the clone view **twice** per out-of-body task, and after the patch
so do we, at the identical span:

```
[    \_begin: (adpcm_pkg::uvm_reg_block::readmemh),  line:1800:10, endln:1800:18]  golden=2  pristine=0  patched=2
[    \_begin: (adpcm_pkg::uvm_reg_block::writememh), line:1807:10, endln:1807:19]  golden=2  pristine=0  patched=2
```

`155 = 135 + 4 blocks × 5 lines`. Because the gate sits on the one shared body
path in `emitTaskFuncs`, the def view, the elab view, the out-of-body hoist and
the package clone are all covered from one place — and the three-way count proves
every one of them lands on a count golden already had, not past it.

`135 = 27 blocks × 5 lines` (and `155 = 31` on SeqDriver), and the five shapes
are exactly:

| shape | per site |
|---|---|
| `\|vpiStmt:` | 1 |
| `\_begin: (<fullname>), line:L:C, endln:L:C2` | 1 |
| `\|vpiParent:` | 1 |
| `\_function:`/`\_task: (<fullname>), …` (the parent back-reference the block prints) | 1 |
| `\|vpiFullName:<fullname>` | 1 |

Multiset distance to golden, `SimpleUVM/default`: **144463 → 144362, gain 101**.
85 of the 135 added lines sit at a text golden has and we lacked; the rest are
`|vpiStmt:`/`|vpiParent:` texts already in surplus at that indent — a documented
property of a multiset instrument (it cannot see WHICH object holds a line), not
a defect in the patch. The authority on that is §5.

**PER-CELL AUDIT OF EVERY SHIPPED OBJECT.** All **25 distinct** shipped `begin`
header lines were grepped against golden's dump: **25 found byte-identical, 0
NOT-IN-GOLDEN.** Nothing was minted that golden does not have, at the span
golden has it.

**THE REVERSE AUDIT — whole design, SimpleUVM, every subroutine:**

| | pristine | shipped |
|---|---|---|
| `ct65cells.py` totals | SAME=3049 **DIFF=64** UNMEASURED=1604 | SAME=3073 **DIFF=40** UNMEASURED=1604 |
| golden has an empty block, we have none (**under-fire**) | **24** | **0** |
| we have an empty block golden lacks (**over-fire**) | 0 | **0** |

24 cells + the one `uvm_reg_indirect_data::build` cell whose enclosing function
object has a pre-existing span disagreement (so the grid keys it UNMEASURED, and
our block there is still at golden's exact `58:17-58:22`) = the 25 subroutines.
**Zero under-fire and zero over-fire across 3113 measured subroutines.**

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

`/tmp/wt_r10uvm65/build`, absolute. `[100%] Linking CXX executable slang-uhdm`
then `[100%] Built target slang_uhdm` read before any measurement. md5s asserted
in their own commands, 32 hex each: control `2dc0aff2ad7a0e04c304fcb71923de7b`,
shipped `caf4aa4b69f3fa155eb3d2b0afb415b3`. Both worktrees at
`575f51d14dace52ccfff05e1037eb527d0ad3b10`.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped> ./tests/check_goldens.sh   ->  PASS=23  FAIL=0
SLANG_UHDM=/bin/false ./tests/check_goldens.sh  ->  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil, `--jobs 2`, own `--out`/`--workdir`

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump column:            match 496        differ 183         (blank) 52
ct8rows.sh vs results/gate_uhdm2rtlil.csv:
  731 ROWS both sides · WHOLE-ROW diff (status AND dump column): 0 differing ROWS
  PASS: every row byte-identical to the committed baseline
```

### GATE 4 — surelog, both modes, `--jobs 2`, `GOLDEN_DEFER` echoed `[UNSET]`

```
[default]   794 tests  CMP_EQUAL 467  CMP_NOTEQUAL 13  DEFERRED 5  SLANG_REJECT 284  SURELOG_FAIL 25
[testflags] 794 tests  CMP_EQUAL 463  CMP_NOTEQUAL 10  DEFERRED 5  SLANG_REJECT 286  SURELOG_FAIL 23
                       NO_DATABASE 3  NO_UHDM 1  TIMEOUT 1  UNTRANSLATABLE 2
ct8rows.sh vs results/golden_surelog.csv:
  1588 ROWS both sides · WHOLE-ROW diff: 0 differing ROWS
  per-mode STATUS histograms: identical    per-mode DUMP histograms: identical
  PASS: every row byte-identical to the committed baseline
```

### GATE 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE 575f51d I built

```
u2r      : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
           SELFCHECK 678/679 flagged         SELFCHECK1 = 1
surelog  : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
           SELFCHECK 952/953 flagged         SELFCHECK1 = 8  (= 7 real + 1 corrupted)
```

Both negative controls fire in both corpora, so a "0 movers" reading here is a
measurement and not a mis-wired driver. The 7 movers are
`default/{BuildUVMPkg,Scoreboard,SeqDriver,SimpleUVM}` and
`testflags/{BuildUVMPkg,SeqDriver,SimpleUVM}` — the predicted set, exactly, and
each one carries `REMOVED=0` (§4).

### MULTI-STABILITY, and the size delta

`detcheck.sh`, `Scoreboard/default`, 3 runs each:

| binary | distinct sha256 | bytes (all runs) |
|---|---|---|
| pristine `2dc0aff2…` | **3** | 11 133 994 |
| shipped `caf4aa4b…` | **2** | 11 133 116 |

The hash flake is **PRE-EXISTING and worse on the pristine binary** — the
campaign's known emitter nondeterminism (SourceLocation compares across macro
buffers under parallel parse). Per the standing rule, **same size = flake**: the
size is stable within each binary, so nothing in this pass introduced it, and it
is not something this pass fixed either.

The **size DELTA between binaries is stable and real: −878 bytes**, identical on
`SimpleUVM` and `Scoreboard`. **A shrink from an add-only patch is not a
contradiction, and it is not hand-waved:** UHDM serializes with
`writePackedMessageToFd` (`UHDM/templates/Serializer_save.cpp:122`), and capnp's
packed encoding elides zero bytes, so file size is not monotonic in content.
The authority on content is the DUMP (+135 lines, **0 removed**, §4) and
`uhdm-cmp` (head cleared, walk advanced) — both of which say added, and both of
which the byte size cannot see.

### CANARIES

```
canaries.sh  vs u2r baseline     : ok=8   changed=0  absent=0  unknown-names=25 (the surelog-only names)
canaries.sh  vs surelog baseline : ok=52  changed=0  absent=0  unknown-names=7  (the u2r-only names)
ctcan2.sh EXPECT_UNKNOWN=6 (u2r) : ok=1   changed=0  absent=0  unknown-patterns=6   PASS
ctcan2.sh EXPECT_UNKNOWN=1 (sl)  : ok=58  changed=0  absent=0  unknown-patterns=1   PASS
canaudit.sh canaries.sh ctcan2.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0        PASS
BY NAME: InterfaceModPort  default CMP_EQUAL/differ  testflags CMP_EQUAL/differ  == baseline
BY NAME: BlackParrotComplex default CMP_EQUAL/differ testflags CMP_EQUAL/differ  == baseline
```

Both canary scripts were run against **both** baselines, mode-matched, and the
expected-unknown counts were stated to the scripts rather than read back out of
them.

---

## 6. RANKED RESIDUES

1. **The new head, on all three target rows** (262 cmp lines):
   `begin (uvm_pkg::uvm_cause_effect_link::get_link) @255:7-255:29`. Both sides
   HAVE this block; its `Stmts` differ (golden's `method_func_call set` +
   `return_stmt` against ours). **It is pre-existing and was masked**, proved
   mechanically: the pristine→shipped dump diff of SimpleUVM is 7 hunks and 135
   lines, none of them within 100 000 lines of this object. This is the next
   law and it is a body-block CONTENT law, not a block-existence law.
2. **40 remaining DIFF subroutine cells in SimpleUVM**, all of them a body
   block's **SPAN** (the "second-item anchor" family, e.g.
   `uvm_object::compare` golden `1050:3-1050:20` vs ours `1049:3-1049:13`) or a
   macro-loc span. **Zero of them involve emptiness** — the two greps for
   under-fire and over-fire return nothing.
3. **The FUNCTION's own span when `virtual` leads the qualifiers** in some
   scopes: golden collapses it onto the `virtual` token (b1 c24, b2 d09/d10,
   `uvm_reg_indirect_data::build`), we span the whole declaration. A
   § function-span law. Our block is at golden's exact span in every one of
   those cells, which is why they read UNMEASURED rather than DIFF.
4. **Where an out-of-body definition LIVES**: golden lists `b2c::d05_oob` in the
   design's `Task_funcs` under a dotted name; we list `work@b2c::d05_oob` inside
   the class. 51 residual b2 lines. § 65 furnishes the block correctly on both
   sides of that disagreement.
5. **A declaration-only body lists its local var TWICE in golden** under
   `vpiVariables` (b1 c17/c21) — 4 residual lines, unrelated.
6. **e05, the one place § 65 adds lines golden does not have**: a `$unit`-scope
   TASK. Golden emits **no object at all** for it (a listing law), so our whole
   `task` object is already extra and § 65 correctly furnishes the extra object
   with its block — 5 lines inside an object that is 100% surplus either way.
   **No corpus site**: the source census finds no `$unit`-scope empty labelled
   ported task anywhere in either corpus, and the byte verifier's 953 databases
   contain no such mover. Fixing it belongs to the listing law, not to this gate.
7. `$unit` task spans (d02) and pure-virtual prototype spans (d07) — measured,
   unrelated, unchanged.

---

## 7. REFUTATIONS, stated plainly

1. **"MY BRIEF: `RHS: <null>` here means the whole begin is missing… and check
   the unsupported notes, a dropped block is likely a noted bail."** Half right
   and half wrong, and both halves were measured before coding. The block IS
   missing (mechanism (a) of the three offered) — but **no bail is involved**:
   the emitter's unsupported list for this compile has two entries, neither at
   line 547 and neither a statement. The brief's "a begin whose entire content we
   drop or fold away renders EMPTY on one side" is **false**: golden's block is
   empty too. There is no content on either side; the BLOCK is the object.
2. **"§ endBlockLabelAllOwners62 owns end labels."** It owns the `vpiEndLabel`
   FIELD. This is a whole synthesized statement block that merely happens to be
   LOCATED at the end-label token. Different object, different field, different
   owner; § 62 is untouched.
3. **"uvm64 R1 recorded a NAMED-block-local over-bind (DELETE-direction) — if
   your head turns out to be that…"** It is not. This patch deletes nothing,
   re-parents nothing and touches no binding: `REMOVED line instances = 0` in all
   8 measured databases, and the object added has no reference fields at all.
4. **MY OWN FIRST LAW, "FUNCTION only", IS REFUTED — and the refutation came
   from measuring past the head, on a binary that had already cleared it.**
   Eight golden-bare task cells said tasks never get the block; every one of them
   was written `task foo();`. `uvm_reg_block::readmemh(string filename)` has the
   block. The term is the **`tf_port_list`**, and b3 shows it is not
   out-of-body-ness either (e06 OOB+port fires, e10 OOB+portless is bare, e01
   in-body+port fires). 7 shipped objects became 27.
5. **"An empty body is an empty body."** Refuted three ways: a decl-only body
   (c17, c21) and a `;`-only body (d03) are golden-BARE while our emitter gives
   all three a null `vpiStmt`. The gate had to be SYNTAX (`items.empty()`).
6. **"A written return type / the function's port list must matter, by symmetry
   with the task."** Refuted: `function e12_f_noret(int a)`,
   `function e16_f_noret_noport()`, `function e19_f_mod_noret(int a)` and
   `function void e27_f_noparens;` all fire.
7. **"The constructor exclusion is just the port-list term in disguise."**
   Refuted: e22 (constructor **with** a port), e25 (without) and e26
   (out-of-body, with a port) are all golden-bare.
8. **"A shrinking database means content was lost."** Refuted at the source:
   UHDM writes a **packed** capnp message, so size is not monotonic in content;
   the dump shows +135 / −0 and the per-object audit shows 25/25 byte-identical
   to golden.

---

## 8. FILES

| file | what it is |
|---|---|
| `b1_empty.sv` | 24 cells: is there a block at all — kinds, labels, scopes, empty vs decl-only vs one/two statements, the constructor |
| `b2_scopes.sv` | 15 cells: `$unit`/interface/program/out-of-body/derived scopes, `pure virtual`, a null-statement body, a label with no spaces, def+elab views |
| `b3_taskport.sv` | 26 cells: THE COUNTEREXAMPLE ARM — task port list vs out-of-body, the omitted return type, no parens at all, three constructor shapes |
| `ct65arm.sh` | one-arm driver: golden + ours, `sed 1d` both dumps, cmp head depth, dump-diff content, unsupported count |
| `ct65cells.py` | the field-policy grid: fullest occurrence, own-child indent, `-NOOBJ-`/UNMEASURED, block emptiness as `*E` |
| `census65.py` | the census-predict: source-only fire sites, per file and per directory, with its own stated bound |
| `mv65.sh`, `msdist.sh` | per-shape movers: multiset distance, ADDED/REMOVED never netted, three-way line counts |
| `rowheads.sh` | cmp lines + head count for a named subset of a workdir |
| `ct8rows.sh` | the row gate: whole-ROW diff vs the committed baseline + status/dump histograms |
| `byteverify.sh`, `manifest.sh` | the byte verifier with both negative controls |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canaries and the audit of the canaries |
| `detcheck.sh` | determinism: N runs, distinct hashes, sizes |
