# r10uvm128 — § `macroSplitRecvIsAstChain128` — **A BUILT-IN METHOD'S RECEIVER WHOSE WRITTEN TEXT NO SINGLE BUFFER HOLDS** — the SimpleUVM ×2 / Scoreboard-default **124-line DROPPED-OPERAND head CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `b7995eb` |
| pristine binary | reproduced the main tree's `build/slang-uhdm` at `b7995eb` BYTE FOR BYTE (md5 `92184b36c03d7e2f698a54f34bf5173a`), frozen `chmod 555` before any sweep |
| patched binary | md5 `af9f894eb946239440803abed2945521`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` ONLY — one file-static helper (`astDottedRecv128`) carrying the law, and two hunks in the built-in-method arm |
| probe surface | `tools/probe/r10uvm128repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SimpleUVM default / testflags** | **124** | **64** | 1 — the dropped-operand head is GONE; a **NEW HEAD**, a different object at a different source line |
| **Scoreboard default** | **124** | **64** | 1 — the same new head |
| SeqDriver default / testflags | 17 | 17 | 1 unchanged, head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 17 | 17 | 1 unchanged, head log **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 54 | 54 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 214 / 144 | 214 / 144 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes | |
| byte movers | — | **7 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the seven **PREDICTED BY NAME** from the PRISTINE databases before the patched sweep ran | |
| direction, all 7 movers | — | **+20 dump lines, −0**: a ONE-SIDED ADD set, every added line golden's | |
| the law's population, both corpora | 7 wrong cells | **0** | |

`head_pris_*_*.cmp` are the whole pristine heads; `head_pat_*_*.cmp` are the new
SimpleUVM / Scoreboard ones. Every row-mode whose head this pass leaves untouched
has a patched head log byte-identical to its pristine twin — checked with `cmp`,
not by eye.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
line for line (`diff` clean, ids included). The head is an **operand VECTOR SIZE
MISMATCH**, which is why `uhdm-cmp` prints BOTH whole containers and the log is
124 lines (RESUME §9: the VECTOR `SafeCompare` overload sets both sides).

`uvm_object_defines.svh:1978`, inside the `UVM_COMPARE` arm of
`` `uvm_field_queue_string(ARG, FLAG) ``:

```systemverilog
if(ARG.size() != local_data__.ARG.size()) begin
```

instantiated by `uvm_reg_mem_hdl_paths_seq.svh:56`
(`` `uvm_field_queue_string(abstractions, UVM_DEFAULT) ``) inside
`uvm_reg_mem_hdl_paths_seq::__m_uvm_field_automation`:

```
LHS (golden)                                RHS (ours)
operation, 1978:21-1978:76, vpiOpType 15    operation, 1978:21-1978:76, vpiOpType 15
  operand hier_path (abstractions.size)       operand hier_path (abstractions.size)
  operand hier_path                           <MISSING>
          (local_data__.abstractions.size)
```

The two operands are written with the SAME macro formal `ARG`. The only
difference is that the second prefixes it with a name from the macro BODY — and
that is exactly what killed it.

---

## 2. WHY THE OPERAND WAS DROPPED — INSTRUMENTED, NOT GUESSED

Three instrumented builds, each a print at one site, run on the real SimpleUVM
command line:

1. `ExprEmit.cpp`'s `ExpressionKind::BinaryOp` arm pushes only the operands
   `emitExpr` returns non-null. Over the **whole surelog corpus** it drops an
   operand in exactly **7 database-modes**, all at this one site, `L=1 R=0`,
   both sides `Call`. Over **uhdm2rtlil, 0**.
2. The right operand is a `Call`, and the emitter reached
   `noteUnsupportedAt("system method call: size")` — the fall-through at the
   bottom of the built-in-method arm — and returned NULL. Exactly one such note
   in the entire database.
3. At that site the receiver is `arguments()[0]`, kind `MemberAccess`,
   **`recv->syntax == nullptr`**, and `rawText(recv->sourceRange)` is **`""`**.
   The arm's whole body is gated on `if (!recvText.empty())`.

**Why `rawText` cannot answer.** slang models a built-in array/string/enum
method as a SYSTEM call whose receiver hides in `arguments()[0]`, and that
receiver expression is SYNTHESISED by `Expression::bindLookupResult` — it
carries **no syntax node at all** (measured: `syn=0`). Its span's two ends are
in two DIFFERENT expansion buffers (measured: `bufS=11436 offS=795`,
`bufE=11446 offE=12`), because `local_data__` is a token of the macro BODY and
`ARG` is a token of the macro ARGUMENT. `rawText` maps both ends through
`getFullyOriginalRange` and they land in **two different files**
(`uvm_object_defines.svh` and `uvm_reg_mem_hdl_paths_seq.svh`), so the `substr`
over one file's text is meaningless. `rawTextExp` cannot help either: it
rebuilds text from a node's TOKENS and there is no node.

**And WHICH meaningless answer it gives is an accident of file offsets.** Both
faces are in the grid (arm A):

| end-offset vs start-offset | `rawText` | what the emitter does |
|---|---|---|
| below (or past the file) | `""` | the arm falls through, the call returns NULL, **the operand is dropped** — the corpus head |
| above | a garbage span of the WRONG FILE | the arm builds a `hier_path` **named with source text, newlines and all** — golden `peer128.q.size`, ours ``peer128.ARG.size()) rc128 = 3; \ …`` |

That is why this law's gate is **not** "the text is empty". It is **"no buffer
holds this text"**.

---

## 3. THE DECODED SURELOG MODEL

Surelog compiles the **preprocessed token stream** and never sees a macro buffer
at all. `CompileHelper::compileExpression`'s dotted-path loop
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5501-5710`) walks
the `dotedName` siblings and, for `local_data__.abstractions.size()`:

| iteration | node | what it pushes |
|---|---|---|
| 1 | `abstractions` (`slStringConst`) | `ref_obj` for the PREVIOUS name, `VpiName`/`VpiFullName` = `local_data__`, spanned by `populateCoreMembers(name, name, ref)` on the `local_data__` token; `tmpName` := `abstractions` |
| 2 | `size` (`slStringConst`), look-ahead `paList_of_arguments` | `ref_obj` `abstractions`, spanned on the `abstractions` token; then the `method_func_call` branch: `VpiName("size")`, `populateCoreMembers(dotedName, …)` on the `size` token, `compileTfCallArguments`, `fcall->VpiParent(path)` |
| tail | `is_hierarchical` | `path->VpiName(the_name)` = `local_data__.abstractions.size` — and `hier_path::VpiName` **IS read by Compare** (a TEXT law, RESUME §9) |

So **each element's span is its own written token's span**, and the path's name
is the dotted join. That is field for field what this law now emits.

---

## 4. THE LAW

> **§ `macroSplitRecvIsAstChain128`.** When a built-in method's receiver has
> **no syntax node** and its span's two ends live in **different buffers** — i.e.
> no buffer holds the written text and `rawText`'s answer is meaningless whatever
> it is — rebuild the written dotted receiver **from the bound AST chain**: one
> component per `MemberAccess` / `NamedValue` link, innermost first, each
> carrying **its own end location**. A chain containing anything else (a select,
> a call, `this`, a scoped name) **DECLINES** and keeps the pristine emission.

`astDottedRecv128` is the whole helper: a three-case recursion over
`NamedValue` / `HierarchicalValue` / `MemberAccess` that returns `(name, end
location)` per link and `false` for everything else. `astRecv128` stays EMPTY
off the law, and the one line further down that reads it is written so that an
empty vector **is** the pristine code.

**Why the end locations and not the arm's cumulative offset walk.** The arm
builds element spans by walking `recv->sourceRange.start()` forward by
`name.size() + 1` per component — exact whenever the written text and the bound
names have the same lengths. Across a macro-argument substitution **they do
not**: in the body the second component is spelled `ARG` (3 characters) while
the bound name is `abstractions` (12), and `macroInvLineCol` turns a body offset
into `invocation column + offset` with the argument-expansion shift applied to
everything AFTER the formal. Walking +12 from the formal's start over-runs it —
**measured**: the element END came out at column **78** where golden writes
**69**, exactly `12 − 3` too far. The END location of each AST link is the end
of the NAME TOKEN AS WRITTEN (for a substituted component that token lives in
the ARGUMENT buffer, so its mapped column is already the expanded one), and
`end − name.size()` is its start **because a name token never crosses a
buffer**.

**Declining is not being right.** A receiver the chain cannot describe keeps the
pristine emission, which for the head shape is a drop. That is
§ `vifClockingPathComponent5`'s rule and it is why the helper's `default:`
returns `false` instead of guessing.

### The object, after

```
hier_path (local_data__.abstractions.size), 1978:44-1978:76
  ref_obj (local_data__)          1978:44-1978:56
  ref_obj (abstractions)          1978:57-1978:69
  method_func_call (size)         1978:70-1978:74
```

**Byte-identical to golden**, checked as a `diff` of the two dumps' 40-line
regions, not by eye.

---

## 5. THE POPULATION — CENSUSED OVER BOTH CORPORA BEFORE AND AFTER

The census re-ran **every** slang command line this pass's own pristine
workdirs recorded — 1523 surelog database-modes and 1458 uhdm2rtlil ones,
LISTED == PROCESSED, SWAPFAIL 0 — under a build carrying the law behind an
instrument-only kill switch, so the pristine emission is byte-for-byte pristine.

*(Ops trap paid for here: `verify_golden.py` runs each test with `cwd` = the
TEST'S SOURCE DIRECTORY and does not record it in `cmds.txt`. A first census
`cd`-ed to the workdir, compiled nothing for every test with relative sources,
and reported the population as 2 cells instead of 7. `cen128.sh` reconstructs
the source directory from `sha1(dirpath)[:8]`, the same hash the workdir name
embeds, and asserts a hit for all 1573 of them.)*

| | surelog | uhdm2rtlil |
|---|---|---|
| the law's gate holds | **7** | **0** |
| …of them EMPTY text | 7 | — |
| …of them GARBAGE text | 0 | — |
| binary operations dropping an operand (pristine) | **7 — the same seven** | **0** |

All seven at ONE source site. `BuildUVMPkg`'s golden is the 1800.2 `pp_output`,
which has no macros at all, so it carries no cell — and it did not move.
Full tables in `CENSUS.r10uvm128.txt`; the a-priori prediction in
`PREDICT.r10uvm128.txt`; the measured movers in `MOVERS.r10uvm128.txt`.

---

## 6. THE GRID

Five arms × DEF and ELAB, scored against golden with `score128.py` (a
SPAN-and-NAME-keyed multiset census — never on file, never on `VpiFullName`).

| arm | def PRIS → PAT | elab PRIS → PAT |
|---|---|---|
| A handles | SAME 29→**35**, ONLY-GOLDEN 32→**26** | SAME 62→**74**, ONLY-GOLDEN 64→**52** |
| B property × method | SAME 7→**13**, ONLY-GOLDEN 18→**12** | SAME 19→**31**, ONLY-GOLDEN 36→**24** |
| C position | SAME 10→**16**, ONLY-GOLDEN 19→**13** | SAME 22→**34**, ONLY-GOLDEN 38→**26** |
| D home | SAME 10→**14**, ONLY-GOLDEN 12→**8** | SAME 27→**36**, ONLY-GOLDEN 27→**18** |
| E count/spelling | SAME 10→**22**, ONLY-GOLDEN 28→**16** | SAME 24→**48**, ONLY-GOLDEN 56→**32** |

`ONLY-OURS` never grows except in arm A, where it grows by exactly the six
hier_paths the pristine emitted with a **garbage name containing a newline** —
rows the census cannot key at all. The `UNPARSEABLE` counter is those
continuation lines: arm A def **236 → 85**, elab **419 → 117**, golden unchanged
at 50 / 78. They are not new wrongness; they are six unrowable objects that
became well-formed.

**Two arm-design traps this grid paid for, both recorded in
`ARMS.r10uvm128.txt`:** a macro DEFINED AND INVOKED IN ONE FILE reproduces the
symptom through a DIFFERENT mechanism (the first cut of arm A showed twelve
one-operand operations and the law never fired); and a macro body that begins on
the `` `define `` line itself lands in `macroInvLineCol`'s single-line regime,
where our spans map to the INVOCATION line and golden's to the DEFINITION line,
so no cell can converge. Both were found by instrumenting the arm, not by
reading it.

---

## 7. GATES

All green — the full battery, with the numbers, is `GATES.r10uvm128.txt`.
Goldens 23/0 and 0/23 on `/bin/false`; both corpora both modes **0 rows
differ** against the committed baselines AND against this pass's own pristine
sweep; **7 / 956** and **0 / 1358** byte movers, every one predicted by name;
canaries `ok=52` / `ok=8` `changed=0`, `ctcan2` PASS ×2, `canaudit` PASS with
FENCE-BREACH 0; SVSwitch pinned at `4842211c4030` and YosysVerx at
`6ccda350c24a`; the wide boundary `LISTED=3839 PROCESSED=3839 MOVED=12` with ten
of the twelve this pass's own arms.

---

## 8. RESIDUES

**R0 — THE SIBLING OF THIS HEAD, AND THE NEW SimpleUVM / Scoreboard HEAD.**
The *other* face of the same cross-buffer read, at a **single-name** receiver,
which this law's two-buffer gate cannot see because one name is one token in one
buffer. `uvm_object_defines.svh:1566`, `` `M_UVM_QUEUE_RESIZE(ARG,VAL) ``:

```systemverilog
while(ARG.size()<sz) ARG.push_back(VAL);
```

golden names the path `abstractions.size`, we name it ``ZE(ARG,"") \.size``.
Censused: **84 cells over 7 UVM database-modes** (every row-mode except
BuildUVMPkg), methods `size` / `push_back` / `pop_front`, `recv->syntax` NULL
there too. The gate the next pass wants is almost certainly *"the receiver's
span, MAPPED TO ORIGINALS, starts and ends in different FILES"* — which is TRUE
here and FALSE for the shapes that must not move (`pkg::v`, an escaped
identifier, an indexed receiver, whose raw text is the right answer). The
census's own negative control for that filter is in `CENSUS.r10uvm128.txt`:
87 further rows, all `m_streams[stream.get_name()]`-shaped, whose text is
CORRECT and which must keep it.

**R1 — the `method_func_call` element's END span through a macro-ARGUMENT
buffer, PRE-EXISTING and NOT this law's.** `mStart + name.size()` where
`mStart = recv->sourceRange.end() + 1` is a raw offset walk past the end of a
one-token argument buffer; `macroInvLineCol`'s newline guard then refuses and
`setLoc` falls back to the invocation site. It is computed IDENTICALLY for the
FIRST operand of every arm cell — hier_paths this law never touches — and every
one of those is wrong in the pristine too. **On the corpus it does not bite**
(the invocation line `` `uvm_field_queue_string(abstractions, UVM_DEFAULT) `` is
long enough that the walk stays on it) and the corpus head object is
byte-identical to golden. `ExprEmit.cpp`'s own comment at that line already
records a corrupt `299:66-778:9` from the same cause.

**R2 — a constant whose value depends on the BINARY LAYOUT, not the source.**
The wide boundary's only non-arm mover: three `constant` objects under the
`vpiRightRange` of `r10buvm22repro/g22.sv:70` (`[string]`, columns 28-34), whose
`vpiDecompile`/`UINT` reads 22449657 on the pristine binary and 22453753 on the
patched one — **deterministic per binary** (three runs each) and **identical
with this law ON and OFF in the same binary** (four binaries, eight runs; the
table is in `BOUNDARY.r10uvm128.txt`), differing between binaries in steps of
exactly 4096. No corpus database carries the shape.

**R3 — a receiver whose AST chain is not a pure dotted name.** `astDottedRecv128`
declines a select, a call, `this`, and a scoped name, so a cross-buffer receiver
of those shapes keeps the pristine drop. No corpus cell has one (the census's 7
are all two-name `MemberAccess` chains), so there is no golden to model — which
is why the helper refuses rather than guesses.

---

## 9. THE FILES

| file | what it is |
|---|---|
| `score128.py` | the span-and-name multiset census over a `uhdm-dump` (OP rows: opType × span × operand count; HP rows: name × span × element list), plus the UNPARSEABLE continuation-line counter |
| `cen128.sh` | the whole-corpus census driver (the instrumented BINARY is not shipped; the traps it encodes are) |
| `arm128.sh` | one grid arm through Surelog and BOTH frozen binaries, DEF and ELAB, scored |
| `attr128.sh` | per-mover PATH-NORMALISED **ORDER-BLIND** dump diff (Scoreboard/default is a coin) |
| `bound128.sh` | the wide boundary over a COPY of `tools/probe`, plus a `.svh` sidecar copy this pass's arms need |
| `g128_defs.svh` | the arms' macro DEFINITIONS — in their own file on purpose (§6) |
| `g128_{a,b,c,d,e}_*.sv` | the five arms |
| `head_pris_*` / `head_pat_*` | the whole head logs, before and after |
| `PREDICT` / `MOVERS` / `CENSUS` / `ARMS` / `BOUNDARY` / `GATES` `.r10uvm128.txt` | the evidence |
