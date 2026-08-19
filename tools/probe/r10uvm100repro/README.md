# r10uvm100 — § `parenStmtDelayNamelessRef100` — the SeqDriver/MiniAmiq head (R0) CLEARED

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `e30c5b4` |
| worktree | `/tmp/wt_r10uvm100` |
| pristine binary | md5 `4e93b58c9954e569b670437ae459cc7a`, frozen `chmod 555` |
| patched binary | md5 `59f45b74fd50c43b16b4b0a1c958f72c`, frozen `chmod 555` (re-built from the FINAL source after the comment was corrected — same md5, so every gate below is the final tree's) |
| production surface | `src/StmtEmit.cpp` ONLY — the parenthesised arm of `emitDelayControl` |
| probe surface | `tools/probe/r10uvm100repro/` only |

## READ THIS FIRST — the head moved ON, not DOWN

| row-mode | pristine cmp lines | patched | heads | note |
|---|---|---|---|---|
| SeqDriver default / testflags | **13** | **26** | 1 | **R0 CLEARED**; a NEW, DIFFERENT head |
| MiniAmiq default / testflags | **13** | **26** | 1 | **R0 CLEARED**; same new head |
| SimpleUVM default / testflags | 108 | 108 | 1 | R2, untouched (bytes moved, head masked) |
| Scoreboard default | 108 | 108 | 1 | R2, untouched (bytes moved, head masked) |
| BuildUVMPkg default / testflags | 32 | 32 | 1 | unchanged (bytes moved, head masked) |
| Earlgrey_0_1 default / testflags | 216 | 216 | 1 | unchanged, byte-identical |
| Rggen default | 64 | 64 | 1 | unchanged, byte-identical |
| corpus rows changed | — | **0** (both corpora, both modes) | | |

*(BuildUVMPkg **32** and Rggen **64** are what I measure at THIS base with my
own frozen pristine binary; uvm99's README recorded 166 and 194 for those two
rows. My own pristine sweep is the authority for a pristine-vs-patched delta,
and it is the same binary that produced the patched column.)*

**A cmp line count is the DEPTH of the head object's decompile, never a
distance.** The 13→26 growth is the old head LEAVING and a deeper, unrelated
one arriving: the walk moved from `uvm_objection.svh:1260` to
`uvm_objection.svh:1276`. `head_pris_default_SeqDriver.cmp` is the whole OLD
13-line head (uvm99's R0); `head_pat_default_SeqDriver.cmp` and
`head_pat_default_MiniAmiq.cmp` are the whole NEW 26-line one (the new **R0**).

## The head, decoded from `BaseClass.h` + the generated `delay_control::Compare` FIRST

`delay_control::Compare`
(`~/git-repos/UHDM/build/generated/src/delay_control.cpp:83`) reads, in order,
`atomic_stmt::Compare` (which is `VpiType`/`VpiName`/`Attributes`), then
`SafeCompare(Stmt())`, then `SafeCompare(Delay())`. **It never reads
`VpiDelay`, and no generated `Compare` reads a span** — so of the two defects
this pass found, only the missing `Delay()` object is judge-visible; the span
is dump-only and is fixed here for fidelity, not for the judge.

The SINGULAR `SafeCompare` (`~/.local/include/uhdm/BaseClass.h:187-191`) with
`lhs != nullptr && rhs == nullptr` sets `m_failedLhs` to the VALUE and leaves
RHS unset — which is exactly the pristine head, `RHS: <null>`:

```
LHS  ref_obj: (uvm_pkg::uvm_test_done_objection::all_dropped), id:306155,
     line:1260:15, endln:1260:27
     |vpiParent: \_begin: (…::all_dropped), id:306145, line:1257:11, endln:1264:14
     |vpiFullName:uvm_pkg::uvm_test_done_objection::all_dropped
RHS: <null>
```

The `ref_obj` has **no `vpiName`**; the dump's `vpiFullName` line is the
SYNTHESIZED parent-chain name of the enclosing scope, not the object's own.
The site is `` `uvm_delay(stop_timeout) `` at
`uvm-1.2 base/uvm_objection.svh:1260`, inside the `fork begin` at `:1257-1264`,
with `` `define uvm_delay(TIME) #(TIME); ``. Column 13 is the backtick and the
macro body `#(stop_timeout)` is 15 characters, which is why golden's
`delay_control` spans `1260:13-1260:28`.

## The law

> **§ `parenStmtDelayNamelessRef100` — A PARENTHESISED DELAY VALUE IN
> STATEMENT POSITION MINTS A *NAMELESS* `ref_obj` AS `Delay()`, AND THE
> `delay_control` KEEPS THE WHOLE `#(…)` AS ITS SPAN.**
>
> `CompileHelper::compileProceduralTimingControlStmt`
> (`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:3016`) is the
> STATEMENT arm. Its whole decision is four lines (`:3032-3044`):
>
> ```cpp
> NodeId IntConst = fC->Child(Delay_control);
> const std::string_view value = fC->SymName(IntConst);
> if (value[0] == '#') { dc->VpiDelay(value); }
> else { ref_obj* ref = s.MakeRef_obj();
>        ref->VpiName(value); ref->VpiParent(pstmt);
>        fC->populateCoreMembers(IntConst, IntConst, ref);
>        dc->Delay(ref); }
> fC->populateCoreMembers(Delay_control, Delay_control, dc);   // the WHOLE `#…`
> ```
>
> The grammar (`grammar/SV3_1aParser.g4:2424-2426`) gives `delay_control` two
> productions, and they put two different NODES under `Child(Delay_control)`:
>
> | source | `Child(Delay_control)` | `SymName` | golden emits |
> |---|---|---|---|
> | `#5`, `#1ns` | a `Pound_delay` token node | `"#5"` / `"#1"` | `VpiDelay` string, **no** `Delay()` |
> | `#Tp` | the identifier node | `"Tp"` | `Delay()` = `ref_obj` **named** `Tp`, fullname `work@m.tk.Tp` |
> | `#(anything)` | the `mintypmax_expression` NODE | **`""`** | `Delay()` = **NAMELESS** `ref_obj` spanning the value |
>
> A non-terminal `mintypmax_expression` node carries **no symbol name**, so
> `value` is empty, `value[0] != '#'`, and Surelog mints the ref with an EMPTY
> name. **The namelessness is not a macro effect** — it is the general shape
> of `#(…)` in statement position, and the grid measures it with no macro
> anywhere in sight.
>
> **THE FENCE IS THE POSITION.** `CompileHelper::compileDelayControl` (`:3085`)
> and the INTRA-ASSIGNMENT arm (`:4559-4567`) both span the `delay_control`
> with `fC->Child(Delay_control)` — the value ALONE, parens stripped — and
> **never mint a ref at all**. That is the pre-existing behaviour of our
> parenthesised arm, and it is CORRECT there; this pass leaves it exactly as
> it was. The `#(Tp+1) -> 6:12-6:16` shrink the old comment claimed for every
> position is measurably the INTRA-ASSIGNMENT cell (`b <= #(Tp+1) 3;` at
> line 6 column 5 puts `Tp+1` at 12-16).
>
> **NOT THIS ARM.** Clocking-block skews (`default input #1step output #2`)
> are a DIFFERENT mint site — `ModuleEmit.cpp` `emitClockingSkew` — and are
> untouched; net-declaration, continuous-assign and gate delays produce **no
> `delay_control` at all** in golden (arm `a5`), they hang a `vpiDelay` expr
> straight off the `cont_assign`/net.

**Measured on golden, one plain module, NO macro** — line numbers are the
committed arm `g100_a1_modtask.sv`, so every cell is re-measurable (its
pristine cmp is the SAME 13-line head shape as SeqDriver's):

| line | source | position | golden `delay_control` span | `vpiDelay` | golden `Delay()` |
|---|---|---|---|---|---|
| 7 | `#(Tp)` | statement | 7:5-7:10 (whole `#(Tp)`) | — | `ref_obj` **nameless** @7:7-7:9 |
| 8 | `#(Tp+1)` | statement | 8:5-8:12 | — | nameless @8:7-8:11 |
| 9 | `#Tp` | statement | 9:5-9:8 | — | `ref_obj` **`Tp`** (`work@m1a.tk.Tp`) @9:5-9:8 |
| 10 | `#5` | statement | 10:5-10:7 | `#5` | — |
| 11 | `#(5)` | statement | 11:5-11:9 | — | nameless @11:7-11:8 |
| 12 | `#1ns` | statement | 12:5-12:9 | `#1` | — |
| 13 | `#(1ns)` | statement | 13:5-13:11 | — | nameless @13:7-13:10 |
| 14 | `#(Tp*2+1)` | statement | 14:5-14:14 | — | nameless @14:7-14:13 |
| 26 | `always #(Tp)` | statement | 26:10-26:15 | — | nameless @26:12-26:14 |
| 20 | `b <= #(Tp) 1` | intra-assign | 20:12-20:14 (**value alone**) | — | — |
| 21 | `b <= #Tp 2` | intra-assign | 21:10-21:13 | — | — |
| 22 | `b <= #(Tp+1) 3` | intra-assign | 22:12-22:16 | — | — |
| 23 | `b <= #9 4` | intra-assign | 23:10-23:12 | `#9` | — |
| 24 | `b <= #(9) 5` | intra-assign | 24:12-24:13 | — | — |

Two things fall out of that table beyond the law itself: `#1ns` keeps only
`#1` as its string (the `time_unit` is a separate token, **R7**), and the
intra-assignment `#Tp` carries **no string at all** while the intra-assignment
`#9` does — the `SymName` of `Child(Delay_control)` is empty for an identifier
in that position and non-empty in statement position, which is why our two
arms already differed there and why this pass leaves the intra arm alone.

## The grid, golden-side, seven arms × both views (`three100.sh`, `GRID.r10uvm100.txt`)

Every cell is scored TWICE — **MULTISET** (the dump's copy multiplicity kept)
and **SET** (dropped).

| arm | what it pins | golden's answer | def | elab |
|---|---|---|---|---|
| `g100_a1_modtask.sv` | **the law, minimised**: every spelling, statement AND intra-assignment, module task + `initial` + `always`, no macro | the table above | **CMP_FAIL(13) → PASS_CMP**, FIXED 7 BROKE 0 | same |
| `g100_a2_class.sv` | CLASS method bodies (the head's home): a `fork begin`, a named `begin`, an out-of-block method, a package task, three live instances | identical rule, DEF and ELAB alike | FIXED 5 BROKE 0 | FIXED 3 BROKE 0 |
| `g100_a3_macro.sv` | the SAME delays via `` `define D3(T) #(T); `` (the `uvm_delay` shape) with an IDENTIFIER arg and an EXPRESSION arg, in a task, an `initial` and a `fork` | **macro expansion is NOT a discriminator** | FIXED 2 BROKE 0 | FIXED 2 BROKE 0 |
| `g100_a4_homes.sv` | HOMES: package task, program, interface task, `repeat`/`while`/`forever` bodies, a generate block | same rule in every home | FIXED 7 BROKE 0 | FIXED 8 BROKE 0 |
| `g100_a5_net.v` | **FENCE**: net-decl delay, gate delay, continuous-assign delay | golden mints **no `delay_control`** here at all | **byte-identical**, 0 cells | **byte-identical**, 0 cells |
| `g100_a6_corpus.v` | the CORPUS shapes: Yosys svinterfaces' bare `#(2);` and a `#(f6(1));` call delay | same rule | **CMP_FAIL(13) → PASS_CMP**, FIXED 2 BROKE 0 | same |
| `g100_a7_fence.sv` | **THE FENCE**: `#Tp7` / `#5` / `#1ns` / `#10ps` statements and EVERY intra-assignment spelling | already ours | **PASS_CMP → PASS_CMP**, byte-identical, FIXED 0 **BROKE 0** | same |

**`BROKE` is 0 in all 28 runs** (7 arms × 2 views × 2 scorings). `a5` and `a7`
— the two fences — are **byte-identical** pristine vs patched (whole dump,
banner line excluded), which is the whole safety argument: the law is the
IDENTITY everywhere the delay is not a parenthesised statement delay.

The `STILL` cells that remain are **not this family** and `P=[]` proves it:

* `a2`/`a4` ELAB — golden carries an ELAB copy of a PACKAGE task
  (`work@m2a.oob`, `work@m2a.pk2`, `work@m4a.pt4`) that **we do not emit at
  all**, pristine or patched. A pre-existing copy-count family (**R8**).
* `a3` — the one MULTISET bucket that still differs holds the
  MACRO-EXPANDED **non-parenthesised** `` `define E3(T) #T; ``: our named-ref
  arm takes the ref's name from `rawText`, which in a macro expansion spills
  the rest of the buffer (`vpiName:T;\nmodule m3a;…`). **Pre-existing and
  untouched** — 1 occurrence in the pristine dump, 1 in the patched
  (**R6**). The three parenthesised delays in the same bucket all went to
  golden.

## The corpus census, three-way, keyed on what the judge reads

`dc100.py` + `cen100.sh`. One row per `delay_control` **in the `uhdm-dump`
tree** — the dump is exactly the REACHABLE tree, so no row can name an object
the judge cannot see (uvm97's `AllObjects` trap). KEY = (nearest named
ancestor, the ANCHOR); the ANCHOR is the span of the DELAYED STATEMENT, or of
the OWNER when there is none — deliberately **not** the `delay_control`'s own
span, which is one of the values under measurement. VALUE = the
`delay_control`'s span, its `vpiDelay` STRING, and its `Delay()` object's kind
/ **own `vpiName`** / span / `vpiActual` presence. Never the file, never the
source text. (`refname()` reads the `|vpiName:` FIELD, never the dump's
`(…)` header — that header is a synthesized `vpiFullName` and prints a
nameless ref as its enclosing scope.)

**Calibrated golden-vs-golden FIRST**: SeqDriver's `default` and `testflags`
goldens produce **93 rows each and 0 differing lines** — the key is
view-general and the instrument manufactures no cells.

```
default/SeqDriver-32af76aa         [MULTISET] cells 45  ALREADY-OK 39  TO-GOLDEN 6  AWAY-GOLDEN 0  STILL 0
testflags/SeqDriver-32af76aa       [MULTISET] cells 45  ALREADY-OK 39  TO-GOLDEN 6  AWAY-GOLDEN 0  STILL 0
default/SimpleUVM-1dc93a62         [MULTISET] cells 29  ALREADY-OK 24  TO-GOLDEN 5  AWAY-GOLDEN 0  STILL 0
testflags/SimpleUVM-1dc93a62       [MULTISET] cells 29  ALREADY-OK 24  TO-GOLDEN 5  AWAY-GOLDEN 0  STILL 0
default/MiniAmiq-544c7f61          [MULTISET] cells 48  ALREADY-OK 42  TO-GOLDEN 6  AWAY-GOLDEN 0  STILL 0
testflags/MiniAmiq-544c7f61        [MULTISET] cells 48  ALREADY-OK 42  TO-GOLDEN 6  AWAY-GOLDEN 0  STILL 0
default/Scoreboard-59431470        [MULTISET] cells 31  ALREADY-OK 27  TO-GOLDEN 4  AWAY-GOLDEN 0  STILL 0
default/BuildUVMPkg-bf853d43       [MULTISET] cells 27  ALREADY-OK 24  TO-GOLDEN 3  AWAY-GOLDEN 0  STILL 0
testflags/BuildUVMPkg-bf853d43     [MULTISET] cells 27  ALREADY-OK 24  TO-GOLDEN 3  AWAY-GOLDEN 0  STILL 0
```

**`AWAY-GOLDEN 0` AND `STILL 0` on every database and both scorings** — after
this pass the `delay_control` family is 100 % golden on all nine UVM
databases. The R0 cell is named explicitly in the census output:

```
TO-GOLDEN ('uvm_pkg::uvm_test_done_objection::all_dropped', 'OWNER begin@1257:11-1264:14')
    G=['dcspan=1260:13-1260:28 str=- ref=ref_obj/<nameless>/1260:15-1260:27/actual=n']
    P=['dcspan=1260:15-1260:27 str=- ref=-']
    Q=['dcspan=1260:13-1260:28 str=- ref=ref_obj/<nameless>/1260:15-1260:27/actual=n']
```

## The mover set, PREDICTED BY NAME first (`PREDICT.r10uvm100.txt`)

`predict100.sh` reads **only OUR PRISTINE databases** — never golden, never the
patched binary. Our pristine emitter renders a `delay_control` with NEITHER a
`vpiDelay` string NOR a `Delay()` object in exactly three places, and two are
excluded by OWNER KIND: an `assignment` owner is the intra-assignment position
(the other arm of `emitDelayControl`, untouched) and a `clocking_block` owner
is a skew from `emitClockingSkew` (a different function entirely). What is
left is the statement-position parenthesised delay.

The LOOSE predicate (owner `assignment` alone) **over-predicts by exactly one
test, both modes** — `InterfaceModPort`, whose two cells are
`default input #1step output #2` clocking skews and which `byteverify`
measures as **SAME** (`PREDICT.r10uvm100.txt` records both counts,
LOOSE and STRICT, as the honest record of the refinement).

```
uhdm2rtlil: PREDICTED 0 / 1358 databases   <- THE FENCE, and it is NOT vacuous:
                                              128 delay_control objects live in
                                              those databases; none is a
                                              parenthesised statement delay
surelog   : PREDICT_SL_LINE
```

`byteverify SELFCHECK=1` then measured **`MOVERS 0 / 1358`** on uhdm2rtlil
(selfcheck 1357/1358) and **`MOVERS 9 / 956`** on surelog (selfcheck 955/956)
— exactly the predicted set, zero unpredicted, and all nine were already
`CMP_NOTEQUAL` rows:

```
default/{BuildUVMPkg,MiniAmiq,Scoreboard,SeqDriver,SimpleUVM}
testflags/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}
```

Each mover's path-normalised, id-stripped whole-dump diff (`attrib100.sh`) is
**ORDERED == ORDER-BLIND on all nine** — no coin flipped this run — and the
count is **exactly 7 lines per predicted `parenStmtDc`**:

```
default/BuildUVMPkg-bf853d43   ORDERED=35  ORDER-BLIND=35   (5 predicted x 7)
testflags/BuildUVMPkg-bf853d43 ORDERED=35  ORDER-BLIND=35   (5 predicted x 7)
default/MiniAmiq-544c7f61      ORDERED=70  ORDER-BLIND=70   (10 predicted x 7)
testflags/MiniAmiq-544c7f61    ORDERED=70  ORDER-BLIND=70   (10 predicted x 7)
default/Scoreboard-59431470    ORDERED=42  ORDER-BLIND=42   (6 predicted x 7)
default/SeqDriver-32af76aa     ORDERED=70  ORDER-BLIND=70   (10 predicted x 7)
testflags/SeqDriver-32af76aa   ORDERED=70  ORDER-BLIND=70   (10 predicted x 7)
default/SimpleUVM-1dc93a62     ORDERED=51  ORDER-BLIND=51   (7 predicted x 7)
testflags/SimpleUVM-1dc93a62   ORDERED=51  ORDER-BLIND=51   (7 predicted x 7)
```

Every one of those 7-line groups is the same three things and nothing else:
the `delay_control` span growing by one column at each end (`#(` … `)`), and
the five lines of a new NAMELESS `ref_obj` under `|vpiDelay:` —

```
<   \_delay_control: , line:41238:11, endln:41238:48
>   \_delay_control: , line:41238:9,  endln:41238:49
>     |vpiDelay:
>     \_ref_obj: (uvm_pkg::uvm_component::m_set_cl_verb), line:41238:11, endln:41238:48
>       |vpiParent:
>       \_begin: (uvm_pkg::uvm_component::m_set_cl_verb), line:41235:35, endln:41250:10
>       |vpiFullName:uvm_pkg::uvm_component::m_set_cl_verb
```

## Gates

`GATES.r10uvm100.txt` has the full transcript. Summary: goldens **23/0** on
both binaries and **0/23** for `/bin/false`; u2r **679/50/2** on both modes and
both binaries; surelog `--mode both` **470/283/25/11/5** default and
**466/284/23/9/5/3/2/1/1** testflags, identical on both binaries; `ct8rows`
**PASS, 0 differing rows** against the committed baselines AND against my own
pristine sweeps (u2r both modes, surelog 1588 rows) — **NO ROW CONVERTED,
nothing promoted**; `cmds.txt` audited by binary PATH (1523 surelog / 1458 u2r
per sweep, every line the frozen pristine or the frozen patched binary and
nothing else); `byteverify SELFCHECK=1` u2r **0/1358**, surelog **9/956**, all
predicted by name first and each attributed line by line; canaries `ok=52` /
`ok=8` `changed=0`, `ctcan2` PASS on both, `canaudit audited=33 UNCOVERED=0
FENCE-BREACH=0`; pins `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr`
**SAME**, `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**,
`SAME=10 MOVED=0`.

## The boundary (`BOUNDARY.r10uvm100.txt`, `DBOUNDARY.r10uvm100.txt`)

From a **COPY** of the whole `tools/probe` tree, **no path filter**, `.sv`
**and** `.v`, fd-3 list, children `</dev/null`, PROCESSED asserted, rc recorded
and compared per cell, **both views**, per-FILE and per-DIRECTORY:

```
PROCESSED-ASSERT-OK on both halves.
per-FILE       FILE_ARMS: LISTED=3209 FENCED_SKIPPED=0 PROCESSED=3209 MOVED=10
               NO_OUTPUT_PAIRS=270 RC_PAIRS=6418 RC_DIFF=0 ASYM=0
per-DIRECTORY  DIR_ARMS:  LISTED=1453 PROCESSED=1453 MOVED=7
               NO_OUTPUT_PAIRS=239 RC_PAIRS=2906 RC_DIFF=0 ASYM=0
```

**All 10 per-FILE movers are my OWN arms** (a1, a2, a3, a4, a6 × 2 views) —
which is the gate's positive control: it can see. `a5` and `a7`, the two
fences, do **not** move in either view, and **the per-file half has NO non-own
mover at all** among 3209 files × 2 views.

Of the 7 per-DIRECTORY movers, 2 are my own directory (both views) and the
other 5 are cells of `r10uvm75repro` (×2), `r10uvm76repro` (×2) and
`r10uvm88repro` (×1).
**All of them are attributed three-way against golden in
`DIRMOVERS.r10uvm100.txt` and every one is `ORDER-BLIND = 0` with `0`
`delay_control` lines and a BYTE-IDENTICAL uhdm-cmp head** — a `vpiTaskFunc`
list REORDERING, the known nondeterminism family (RESUME.md §9), not this law.
The mover SET itself flickers between runs, which is the coin's own signature.

uvm92's boundary law ("only cells your law names may move") holds.

## Residues, named for the queue — RE-RANKED

Ranking after this landing, by how many row-modes each blocks and how deep it
is masked:

| rank | residue | rows blocked | evidence |
|---|---|---|---|
| **R0** | `event_stmt` vpiName at `uvm_objection.svh:1276` (NEW) | SeqDriver ×2, MiniAmiq ×2 — the visible head of 4 of the 9 UVM row-modes | `head_pat_default_SeqDriver.cmp`, `head_pat_default_MiniAmiq.cmp` (26 lines, 1 head, both modes) |
| **R2** | `before_export` `vpiPrefix` in `uvm_algorithmic_comparator::write` | SimpleUVM ×2, Scoreboard/default — the visible head of 3 row-modes, 108 lines, byte-identical through this pass | uvm99's `head_pat_default_SimpleUVM.cmp` |
| **R3** | `inside`-operand enum scoping, `uvm_sequencer_base.svh:664` | masked on 4 row-modes; the one `STILL` cell of uvm99's census | uvm99 |
| **R1a** | uvm99's splice half — a parenthesised/compound FIRST BOUND of an `inside` range | no corpus reach measured (all nine uvm99 movers are single primaries) | uvm99 arms a1 `k8`, a7 `h3` |
| **R1 (uvm98)** | the OUT-OF-BLOCK `cls::m(own_td_t p)` type mis-bind | BuildUVMPkg family, masked behind uvm98's own R0 | uvm98 arm a5 |
| **R6** | macro-expanded `#IDENT` ref name from `rawText` (NEW) | **0** corpus rows (`PREDICTED 0/1358`; the nine surelog movers are all parenthesised) | arm `g100_a3_macro.sv` |
| **R8** | ELAB copy of a package-scope task body (NEW) | probe-only so far | arms `a2`/`a4` ELAB |

Detail:



**R0 — THE NEW HEAD of SeqDriver ×2 / MiniAmiq ×2 (26 lines, 1 head).** An
`event_stmt` golden NAMES and we leave nameless, at
`uvm-1.2 base/uvm_objection.svh:1276`, `->m_events[obj].all_dropped;` inside
`if (m_events.exists(obj))`:

```
LHS  event_stmt: (m_events), id:306199, line:1276:7, endln:1276:35
     |vpiParent: \_if_stmt: , line:1275:5, endln:1276:35
     |vpiName:m_events
     |vpiBlocking:1
RHS  event_stmt: , id:111135, line:1276:7, endln:1276:35
     |vpiParent: \_if_stmt: , line:1275:5, endln:1276:35
     |vpiBlocking:1
```

`atomic_stmt::Compare` reads `VpiName` — so this is a NAME defect, not a
missing object. Golden names the event_stmt for the **BASE identifier of the
triggered hierarchical path** (`m_events`, not `m_events[obj].all_dropped`),
which is the same "base identifier alone" shape as
§ `parensLessEventPathBaseRef9`. `head_pat_default_SeqDriver.cmp` and
`head_pat_default_MiniAmiq.cmp` are the whole 26-line head.

**R2 — SimpleUVM ×2 / Scoreboard/default head, 108 lines, unchanged.** The
`method_func_call (before_export)` in `uvm_algorithmic_comparator::write`
(`131:10-131:23`), whose golden `vpiPrefix` is a `ref_obj (…::write::comp)`;
our side is empty. Carried from uvm99 unchanged and re-measured here.

**R3 — the `inside`-operand enum scoping family** (`uvm_sequencer_base.svh:664`).
Carried from uvm99, untouched.

**R8 — the ELAB copy of a PACKAGE task.** Golden carries an ELAB copy of a
package-scope task body (`work@m2a.pk2`, `work@m4a.pt4`) and of an
out-of-block class method reached through the module (`work@m2a.oob`); we
emit none. Arms `a2`/`a4`, ELAB view only. Not a delay family — the delay
cells inside those copies are simply absent on our side entirely.

**R6 — NEW: the macro-expanded NON-parenthesised statement delay takes its
ref name from `rawText`.** `` `define E3(T) #T; `` gives our `ref_obj` the
name `T;\nmodule m3a;\n…` — `rawText` over a macro-expansion range spills the
rest of the buffer. Pre-existing (1 occurrence in the pristine dump, 1 in the
patched, byte-identical), deliberately NOT fixed here because it is the OTHER
arm of `emitDelayControl` and no corpus row reaches it (`PREDICTED 0/1358` and
the nine surelog movers are all parenthesised). Arm `g100_a3_macro.sv`.

**R7 — `#1ns` keeps only `#1` as its `vpiDelay` string in golden** (the
`time_unit` is a separate token, `pound_delay_value: Pound_delay time_unit?`).
We already model it; recorded because the grid measures it and a future pass
must not "fix" it.

## Files

```
dc100.py       the delay_control census, read off a uhdm-dump text tree
               (reachable objects only); ANCHOR-keyed, span-free key
cen100.sh      run the census three-way (golden / pristine / patched) over one
               (mode, test) of a verify_golden workdir; golden is read from
               that test's OWN cmds.txt
three100.sh    three-way arm scorer, golden / pristine / patched, rc recorded,
               scored MULTISET and SET
predict100.sh  the a-priori mover predictor, from OUR PRISTINE databases only
attrib100.sh   attribute one mover: path-normalised id-stripped whole-dump
               diff, ORDERED and ORDER-BLIND
bound100.sh    the wide boundary gate, per-FILE  (fd-3 list, children
               </dev/null, PROCESSED asserted, per-cell rc, both views, no
               path filter, .sv AND .v)
dbound100.sh   the same gate, per-FILE and per-DIRECTORY
pins100.sh     the named pins, md5 of the database, patched vs pristine
g100_a1..a7    the seven golden arms (a5 and a7 are the fences)
CENSUS / GRID / GATES / BOUNDARY / DBOUNDARY / PREDICT / ATTRIB /
DIRMOVERS .r10uvm100.txt   the measurements
head_pris_default_SeqDriver.cmp   the OLD head, whole (13 lines) = uvm99's R0
head_pat_default_SeqDriver.cmp    the NEW head, whole (26 lines) = R0
head_pat_default_MiniAmiq.cmp     the same new head on MiniAmiq (26 lines)
byteverify.sh canaries.sh ctcan2.sh canaudit.sh ct8rows.sh rowheads.sh
               carried forward unchanged from r10uvm99repro / r10oth{4,8}repro /
               r10uvm{52,67}repro
```
