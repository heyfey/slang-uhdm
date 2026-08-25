# r10uvm132 — § `macroPasteRecvMisreadIsAstChain132` — **THE SINGLE-NAME RECEIVER WHOSE DEFINITION-SITE READ LANDS ON THE WRONG CHARACTERS** — SimpleUVM ×2 / Scoreboard-default: the `M_UVM_QUEUE_RESIZE` head CLEARED, 84 cells, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f611e1b` |
| pristine binary | built from a clean worktree at `f611e1b`, frozen `chmod 555` before any sweep; its head log reproduces the master's `SimpleUVM` head **byte for byte** (`diff` clean, ids included) |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/ExprEmit.cpp` ONLY — one gate, one span lambda, and four one-line span switches inside the built-in-method arm |
| probe surface | `tools/probe/r10uvm132repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | head = `hier_path (ZE(ARG,"") \.size)` @1566:9 | **head CLEARED** — a NEW head, a different KIND at a different file and line |
| **Scoreboard default** | the same head | **the same new head** |
| SeqDriver default / testflags | 17 cmp lines, 1 head | head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 294, 1 head | head log **BYTE-IDENTICAL** |
| BuildUVMPkg default / testflags | 54, 1 head | head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 90 / 150, 1 head | head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweep |
| byte movers | — | **7 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the seven **PREDICTED BY NAME** from the pristine census before the patched sweep ran |
| direction, all 7 movers | — | **75 lines out, 75 lines in** — a pure substitution; every added line is one GOLDEN also emits (**AWAY 0**), no removed line is (**MOVED-WRONG 0**) |
| the law's population, both corpora | 84 wrong cells | **0** |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
line for line. The head is `uvm_object_defines.svh:1566`, the body of
`` `M_UVM_QUEUE_RESIZE(ARG,VAL) ``:

```systemverilog
while(ARG.size()<sz) ARG.push_back(VAL); \
while(ARG.size()>sz) void'(ARG.pop_front()); \
```

reached from `uvm_reg_mem_hdl_paths_seq.svh:56`'s
`` `uvm_field_queue_string(abstractions, UVM_DEFAULT) ``:

```
LHS (golden)                                    RHS (ours, pristine)
hier_path (abstractions.size)  1566:9-1566:28   hier_path (ZE(ARG,"") \.size)  1566:9-1566:28
  ref_obj (abstractions)       1566:9-1566:21     ref_obj (ZE(ARG,"") \)       1566:9-1566:21
  method_func_call (size)      1566:22-1566:26    method_func_call (size)      2010:1-2010:5
```

`hier_path::VpiName` and `ref_obj::VpiName` **are** read by the generated
`Compare` (a TEXT law, RESUME §9); the spans are not, and are dump fidelity.
This is § `macroSplitRecvIsAstChain128`'s README residue **R0**.

---

## 2. WHY THE TEXT IS WRONG — INSTRUMENTED, AND R0's GUESS REFUTED

R0 proposed the gate *"the receiver's span, MAPPED TO ORIGINALS, starts and ends
in different FILES"*. **Measured on the real SimpleUVM command line, that is
FALSE here.** One `fprintf` in the built-in-method arm prints, per receiver,
both span ends' buffer, offset, macro-ness, `getFullyOriginalLoc`, `rawText`,
and the AST-chain rebuild:

```
S = b11514/o0 /MacroArg  orig=uvm_object_defines.svh:2009:33  emit=1566:9
E = b11514/o12/MacroArg  orig=uvm_object_defines.svh:2009:45  emit=1566:21
sameBuf=1   raw=`ZE(ARG,"") \`   chain=`abstractions`   fit=3   mdepth=4
```

Both ends are in **one** buffer and map to **one** file, exactly the token's
width apart. The read is internally consistent — and points at the wrong
characters: `uvm_object_defines.svh:2009:33` is the `Z` of `_RESIZE` inside

```
            `M_UVM_``TYPE``_RESIZE(ARG,"") \
```

three columns short of the `ARG` at 2009:36, so the twelve characters `rawText`
returns are `ZE(ARG,"") \`.

**THE DISCRIMINATOR IS THE `` `` `` TOKEN PASTE, measured on the grid, not
guessed.** Arm A reaches the same class property five ways:

| shape | `rawText` reads |
|---|---|
| pasted nested — `` `G132_``TYPE``_RESIZE(ARG,"") `` | **`ZE(ARG,"" `** — WRONG |
| pasted with a different suffix — `` `G132_``TYPE``_TRIM(ARG,V) `` | **`IM(ARG,V) `** — WRONG |
| the SAME nesting, NO paste — `` `G132_QUEUE_RESIZE(ARG,"") `` | `qnest132` — right |
| a single-level macro argument | `qone132` — right |
| macro BODY text | `qbody132` — right |
| plain source | `qplain132` — right |

Only the pasted invocation misplaces the argument buffer's origin. Nesting,
argument substitution and multi-line bodies are all innocent.

**`rawText`'s LENGTH is right even when its POSITION is not.** It returns
`end.offset() - start.offset()` characters and those two offsets are the
argument buffer's own ends — so the misread is always exactly as long as the
written token. That is why the pristine `ref_obj` span (1566:9-1566:21) is
already golden's, why only the NAME is garbage, and why substituting the bound
name (same length) moves no element span.

---

## 3. THE DECODED SURELOG MODEL

Surelog compiles the **preprocessed token stream** and never sees a macro
buffer. `CompileHelper::compileExpression`'s dotted-path loop
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5501-5710`) is
the whole builder for `abstractions.size()`:

| iteration | what it pushes |
|---|---|
| `abstractions` (`slStringConst`) | `tmpName` := `abstractions`; `the_name` accumulates |
| `size` with a `paList_of_arguments` look-ahead | the `paBuilt_in_method_call` branch (`:5613-5650`): `fcall->VpiName(method_name)` and **`fC->populateCoreMembers(method_name_node, method_name_node, fcall)` — the METHOD NAME TOKEN ALONE** |
| tail (`is_hierarchical`) | the trailing `ref_obj` spanned by `populateCoreMembers(name, name, ref)` on ITS own token, then `path->VpiName(the_name)` = `abstractions.size` |

So each element's span is its **own written token's** span in the EXPANDED
stream, and the path's name is the dotted join — field for field what this law
emits. Golden's columns are the definition line with each argument
substitution's width applied: `abstractions` 9-20, `.` 21, `size` 22-25,
`()` 26-27, `<` 28, `sz` 29-30 — and our `macroInvLineCol` / `macroArgShift`
already produce exactly that for the receiver.

---

## 4. THE LAW

> **§ `macroPasteRecvMisreadIsAstChain132`.** When a built-in method's receiver
> is **macro-expanded at both ends** and the dotted name rebuilt from the
> **bound AST chain** both **describes the receiver's written span exactly**
> (first component starting at the span start, last component ending at the
> span end) and **differs from `rawText`'s answer**, the definition-site read
> has MISSED the receiver: take the chain's name, and lay the elements and the
> call out by a **cumulative COLUMN walk** from the receiver's own start
> column.

Three fences, each with a control that must not move:

* **THE FIT.** An ESCAPED IDENTIFIER binds to `q$esc132` while the written
  token is `\q$esc132`, so the chain's component cannot reach the span's
  start: `fit` reads 2, the law declines, the written text is kept (arm G,
  byte-identical). A scoped name fails the same test for the same reason.
  It is the **fit**, not a spelling test, that fences them.
* **THE `this`/`super` HEAD.** slang models `this.q` as a two-link chain whose
  head is a `NamedValue` named `this`, and it **can** pass the fit — measured.
  That receiver family belongs to § `thisStmtHandleCall85` / uvm84-85's laws,
  so this one refuses it outright (§ `vifClockingPathComponent5`'s rule).
  Arm F's `this.` cell is byte-identical.
* **ONE BUFFER.** A receiver whose two ends are in DIFFERENT buffers is
  § `macroSplitRecvIsAstChain128`'s own cell; the 132 face declines every one,
  so that law's emission is untouched by construction (arm F's dotted cell,
  0 moved).

**Why a column walk and not each link's own end location.** § `128`'s decode
warns against a cumulative walk — correctly, for ITS face, where the components
live in different buffers and one is spelled as a macro FORMAL of a different
length (it measured the over-run at `12 − 3` columns). On THIS face the whole
receiver lies in ONE buffer, so the expanded stream spells it exactly as the
chain joins it and the walk is exact. The converse was measured too: taking
each link's own end put arm A's two-component cell's second element END and its
call at `34:4` instead of golden's `18:25` / `18:26`, because that end is one
PAST the last character of its own argument-part buffer and does not map.

### The object, after

```
hier_path (abstractions.size)  1566:9-1566:28
  ref_obj (abstractions)       1566:9-1566:21
  method_func_call (size)      1566:22-1566:26
```

**Byte-identical to golden**, checked as a `diff` of the two dumps' 837-line
regions over all three `M_UVM_QUEUE_RESIZE` invocation sites (SimpleUVM/default,
ids stripped): **412 differing lines → 10**, and the ten are

* 6 — three copies of the `ref_obj (…::tmp__)` that `M_UVM_QUEUE_RESIZE(ARG,tmp__)`
  passes as `VAL`, ending at `2064:21` where golden writes `1566:61`.  It is a
  call ARGUMENT, not a receiver, built by a different path, and it reads
  `2064:21` in the PRISTINE too (residue R4);
* 4 — the fixed-size extraction window ending at a different object in the two
  dumps.

**Every object this law owns is byte-identical to golden**, name and span:
`hier_path`, its two `Path_elems`, and the statement calls with their
`vpiPrefix`.

---

## 5. THE POPULATION — CENSUSED OVER BOTH CORPORA BEFORE THE PATCH

`cen132.sh` re-ran every slang command line this pass's own pristine workdirs
recorded — **1523** surelog database-modes and **1458** uhdm2rtlil ones,
LISTED == PROCESSED + SKIPPED, SWAPFAIL/NODIR 0 — under a census-instrumented
binary (the instrument is an `fprintf` behind `getenv("CEN132")`; the
instrumented build is not shipped, the driver and its traps are).

| | surelog | uhdm2rtlil |
|---|---|---|
| built-in method receiver reads | **23,709** | 8 |
| `recv->syntax != NULL` | **0** | 0 |
| the law's gate holds | **84** (7 database-modes × 12) | **0** |
| § `…AstChain128`'s own cells (two buffers) | 7 | 0 |
| CORRECT macro-located reads (must not move) | **739** | 0 |
| CORRECT file-located reads, 0 mismatching | 21,086 | 8 |
| chain DECLINES (select / call / scoped) | 1,793 | 0 |

The 1,793 declines **contain** § `128`'s own 87-row `m_streams[…]` negative
control: the chain refuses a select outright, so those rows never reach any
fence. Over both corpora there is **no** cell where the read differs from the
chain and the law neither fires nor is stopped by a measured control.

Full tables in `CENSUS.r10uvm132.txt` (+ the raw scorer output in
`CENSUS.surelog.r10uvm132.txt` / `CENSUS.uhdm2rtlil.r10uvm132.txt`); the
a-priori prediction in `PREDICT.r10uvm132.txt`; the measured movers in
`MOVERS.r10uvm132.txt`.

---

## 6. THE GRID

Seven arms × DEF and ELAB (six scored against Surelog by `armscore132.py`, one
slang-only). Full table and the arm-design traps in `ARMS.r10uvm132.txt`.

| arm | def PRIS → PAT (SAME / ONLY-GOLDEN / ONLY-OURS) | elab PRIS → PAT |
|---|---|---|
| A shapes | 19/23/21 → **33/9/9** | 53/70/64 → **96/27/27** |
| B methods | 5/7/7 → **11/1/1** | 16/22/22 → **35/3/3** |
| C receiver kinds | 12/28/24 → **40/0/0** | 30/74/64 → **104/0/0** |
| D homes | 22/50/46 → **70/2/2** | 48/105/106 → **149/4/13** |
| E instances × name lengths | 18/30/24 → **48/0/0** | 55/92/74 → **147/0/0** |
| F fences | 1/3/1 → **1/3/1** (0 cells moved) | 3/7/4 → **3/7/4** (0 moved) |
| G escaped identifier (no golden) | dump **BYTE-IDENTICAL** | dump **BYTE-IDENTICAL** |

`SAME` rises in every scored arm and both residue columns fall in every one; C
and E reach **0/0 in both views**. The `UNPARSEABLE` counter — dump
continuation lines, i.e. objects whose NAME contains a newline, which the
pristine emits for a misread receiver — falls with them (arm E elab 363 → 111)
while golden's stays fixed.

---

## 7. GATES

All green; the numbers are in `GATES.r10uvm132.txt`. Goldens 23/0 and 0/23 on
`/bin/false`, `SLANG_UHDM` exported explicitly per binary and every `cmds.txt`
audited by BINARY PATH; both corpora both modes **0 rows differ** against the
committed baselines AND against this pass's own pristine sweep (u2r 679/50/2
in both modes; surelog status histogram unchanged); **7 / 956** and
**0 / 1358** byte movers, every one predicted by name; canaries `ok=52` /
`ok=8` `changed=0`, `ctcan2` PASS ×2, `canaudit` PASS with FENCE-BREACH 0;
InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical, SVSwitch
pinned at `4842211c4030`, YosysVerx at `6ccda350c24a`.

---

## 8. RESIDUES

**R0 — THE CALL-NAME SPAN WHEREVER NEITHER LAW FIRES.**
§ `macroSplitRecvIsAstChain128`'s residue R1, unchanged and now named by its
population: both call sites walk `recv->sourceRange.end() + 1` (expression) and
`recv->sourceRange.start() + recvText.size() + 1` (statement) as RAW OFFSETS,
which run off the end of a one-token macro-argument buffer; `macroInvLineCol`'s
newline guard then refuses and `setLoc` falls back to the invocation site. This
law fixes it **only on its own cells**. Arm A's CONTROL cells `qnest132` /
`qone132` — correct names, `rawText` right, the law declines — still read
`method_func_call (size) 18:18-33:4` where golden writes `18:18-18:22`. The
census can bound the population: 739 correct macro-located receiver reads on
the surelog corpus, every one of them exposed to the same walk. It bites only
when the invocation line is shorter than the walk, which is why the corpus rows
do not show it.

**R1 — the USER-method twin.** Arm B's `g132_user`, a user method reached
through the same paste, ends at `26:8-47:3` where golden writes `26:8-26:17`.
That call is built by the USER-method arm (§ `deepRecvCall11`'s SITE 2), which
this law does not reach; its name, prefix and argument all agree with golden.

**R2 — the out-of-body class method, ELAB.** Arm D: golden's prefix fullname is
`work@top_d132.cls_d132::out_d132.qout132` and ours is `::` throughout
(`VpiFullName`, which **no** generated `Compare` reads — the "naming is
context-dependent" dead-end), and in ELAB we emit **three** copies of the
out-of-body body where golden has **two**. Both PRE-EXISTING: the pristine
emits the same three copies, with garbage names the span-and-name census could
not key at all, which is why the patched arm's `ONLY-OURS` reads 13 where the
pristine's read 106.

**R3 — the `this.`/`super.` receiver inside a paste macro.** Measured, fenced
OUT, and NOT modelled: arm F's `this.qthis132` passes the fit (slang's `this`
is a `NamedValue` named `this`) and its `rawText` is garbage, so a fenceless
version of this law would rename it. It is byte-identical after this pass. The
family belongs to uvm84/85's `this.`/`super.` laws; whoever takes it must
measure golden for the paste shape first.

**R4 — a `constant` argument's own span.** Inside the law's own region, the
`ref_obj (…::tmp__)` that `M_UVM_QUEUE_RESIZE(ARG,tmp__)` passes as `VAL` ends
at `2064:21` where golden writes `1566:61`. It is a call ARGUMENT, not a
receiver, built by a different path; identical in the pristine and after, and
it is one of the three lines the region diff still shows.

---

## 9. THE FILES

| file | what it is |
|---|---|
| `cen132.sh` | the whole-corpus census driver (the instrumented binary is not shipped; the traps it encodes are — including the per-child output files that a shared `>>` redirect corrupts) |
| `score132.py` | classifies the census rows: the gate, the two faces, the negative controls, the declines |
| `arm132.sh` + `armscore132.py` | one grid arm through Surelog and BOTH frozen binaries, DEF and ELAB, scored by a SPAN-and-NAME multiset census (HP / MFC / OP rows) |
| `fence132.sh` | a fence arm Surelog cannot compile, scored by PRISTINE-vs-PATCHED dump identity |
| `attr132.sh` | per-mover PATH-NORMALISED **ORDER-BLIND** dump diff |
| `bound132.sh` | the wide boundary over a COPY of `tools/probe`, with the `.svh` sidecar copy these arms need |
| `g132_defs.svh` | the arms' macro DEFINITIONS — in their own file on purpose |
| `g132_{a..g}_*.sv` | the seven arms |
| `head_pris_*` / `head_pat_*` | the whole head logs, before and after |
| `PREDICT` / `MOVERS` / `CENSUS` / `ARMS` / `BOUNDARY` / `GATES` `.r10uvm132.txt` | the evidence |
