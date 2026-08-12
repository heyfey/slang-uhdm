# r10svs9 — THE PARENTHESES, AGAIN: `@ a.b` IS ONE ref_obj AND `@(a.b)` IS A hier_path

**Verdict, up front: the SVSwitch head the brief set as the target is CLEARED in
BOTH modes, and SVSwitch DID NOT CONVERT.** A successor head appeared, in a
different cluster, and this pass **localized it to a four-cell arm** (§7 R1)
rather than guessing at it. Both rows are unchanged from the committed baseline:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

I am therefore in the **UNCONVERTED world** of GATE 4, and every gate below is
read against the UNCONVERTED expectation (`467/13` + `463/10`, histograms
unchanged, 0 differing rows).

```
head @595c2e3 (the brief's target, 48 cmp lines, IDENTICAL in both modes)
  LHS golden  ref_obj: (work@Environment::reset::input_intf), line:63:16, endln:63:32
              |vpiName:input_intf
              |vpiFullName:work@Environment::reset::input_intf
  RHS ours    hier_path: (input_intf.clock), line:63:16, endln:63:32
              \_ref_obj: (input_intf),                       63:16-63:26
              \_ref_obj: (work@Environment::reset::clock),   63:27-63:32

head on the shipped binary (17 cmp lines, IDENTICAL in both modes) — CLEARED,
replaced by a DIFFERENT cluster:
  LHS golden  ref_typespec: (work@testcase.env)
              \_logic_net: (work@testcase.env), line:20:13, endln:20:16
              |vpiActual:
              \_class_typespec: (Environment), line:20:1, endln:20:12
  RHS         <null>          — we emit the logic_net and NOT its typespec link.
```

* **ONE LAW, `§ parensLessEventPathBaseRef9`, ONE predicate, ONE call site.**
* **GRID: 42 cells across 4 arms**, both sides read at their own child depth by
  `ecread.py`, which walks the indent column so a `vpiParent` back-pointer is
  never double-counted. **EQ 18 → 28**; every non-EQ cell is classified and
  ranked (§3, §7), and **not one cell got worse**.
* **SVSwitch instruments, reported separately and never conflated:** cmp head
  depth 48 → 17 (**not a distance** — Compare dumps a whole subtree), dump
  content `+/-` 1934 → 1918, `o.dump` lines 25708 → 25698 (golden 25318).
* **FIVE GATES GREEN** (§5) under the UNCONVERTED expectation.
* **CANARIES** all green (§5.6), `InterfaceModPort` and `BlackParrotComplex`
  checked BY NAME first.
* **SIX REFUTATIONS** (§4, §6.1), two against this pass's own brief and **one
  against this pass's own census**, which under-counted the movers 2-vs-9 by
  omitting a corpus root — caught by GATE 5, not smoothed over.

Base commit `595c2e3`, branch `auto5h`.
Pristine binary md5 **`6ebf930f2b58e9b70373d9b9282db381`** (worktree
`r10svs9pris`, clean at 595c2e3, `strings | grep -c parensLessEventPathBase9`
= 0). Shipped binary md5 **`839408ac5c4c225717bd721cc3042ec3`**
(`strings | grep -c parensLessEventPathBase9` = 1).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 0. THE BRIEF'S FIRST QUESTION, ANSWERED BEFORE ANY CODE

The brief required decoding whether the witness's `.clock` is a **clocking
block** or a **plain signal**, because `§ vifClockingPathComponent5` (r10svs5)
owns clocking-block path components and would otherwise be the collision.

`Surelog/third_party/tests/SVSwitch/interface.sv:38-51`:

```systemverilog
interface input_interface(input bit clock);   // <- `clock` is the INPUT PORT
  logic           data_status;
  logic     [7:0] data_in;
  logic           reset;
  clocking cb@(posedge clock);                // <- the clocking block is `cb`
     default input #1 output #1;
     output    data_status;
     output    data_in;
  endclocking
  modport IP(clocking cb,output reset,input clock);   // <- `clock` re-exposed
endinterface
```

**`.clock` is a PLAIN SIGNAL**, the interface's own input port, re-exported by
the modport. The clocking block is `cb`. **There is NO collision with
§ vifClockingPathComponent5**, and the r10svs5 arms still read as landed: its
negative control a1 c9 (`@(posedge vif.clock)`) is reproduced here as a1 c7 and
is byte-identical to golden on both binaries, and its `cb`-recovery cells are
reproduced here as a1 c13 / a4 h6 (parenthesized, three elements, **EQ on both
binaries** — the recovery is untouched).

The two laws MEET in exactly one place and do not fight: a1 c12
(`@ vif.cb.rdy`, parens-less) and a4 h4 (`@ vif.cb.sig`). There
§ vifClockingPathComponent5 recovers `cb` into a three-element hier_path and
`§ parensLessEventPathBaseRef9` then replaces the whole path with the base
ref_obj — which is what golden ships. The parenthesized twins (a1 c13, a4 h6)
keep the three-element hier_path, so the recovery is still doing its job
everywhere it is golden's shape.

---

## 1. THE LAW, in the form a future pass can grep for

```
§ parensLessEventPathBaseRef9   src/StmtEmit.cpp        (predicate + THE call site)
                                include/UhdmExporter.h  (declaration + fwd-decl)
```

> An event control written **WITHOUT PARENTHESES** over a **DOT-separated path**
> (`@ a.b;`, `@ a.b.c;`) is **ONE `ref_obj`** in golden: `vpiName` is the path's
> **BASE identifier ALONE**, `vpiFullName` is that name joined to the enclosing
> prefix, and the **SPAN is the WHOLE dotted text**. Everything after the first
> dot is **DROPPED** — no hier_path, no path elements, however deep the path is
> written. The **PARENTHESIZED** spelling of the very same path keeps the FULL
> hier_path, and the same dotted read in any **other context** (assignment rhs,
> call argument, `if` condition) is untouched.

**THE DISCRIMINATOR IS THE PARENTHESES, NOT THE BASE'S TYPE.** SVSwitch's own
`Environemnt.sv` contains both spellings of the same path through the same
handle, and golden shapes them differently:

```
:63   repeat (4)     @ input_intf.clock;    -> ref_obj (…::input_intf) 63:16-63:32
:121  repeat(10000)  @(input_intf.clock);   -> hier_path (input_intf.clock) 121:20-121:36
                                               \_ref_obj (input_intf) 121:20-121:30
                                               \_ref_obj (…::clock)   121:31-121:36
```

That one file is the whole proof, and it is why a virtual-interface predicate
would have been wrong: arm a2 shows a **real interface INSTANCE**, a
**hierarchical module reference**, a **packed-struct member** and a
**class-object event member** all collapse in the parens-less form too.

**WHERE THE COLLAPSE COMES FROM.** The two spellings are DIFFERENT grammar
productions and slang keeps them apart to the last, so the AST node's own
`syntax` kind **is** the written form — no text scanning, no guessing:

```
slang/source/ast/TimingControl.cpp:59   case SyntaxKind::EventControl:
                               :60       SignalEventControl::fromSyntax(…EventControlSyntax…)
                               :63   case SyntaxKind::EventControlWithExpression:
                               :64       EventListControl::fromSyntax(…)
                               :86   result->syntax = &syntax;
```

Surelog's parens-less production evidently binds only the **leading identifier**
and then stretches that one reference over the whole `hierarchical_identifier`
node: name from the FIRST token, span from the LAST. Golden's object is exactly
that, and in a CLASS it carries **no `vpiActual`** at all (§3.1).

### STATED GATE == CODE GATE

The predicate is `UhdmExporter::parensLessEventPathBase9` (src/StmtEmit.cpp).
Each clause below is one clause of the code, in the code's order, with the arm
cell that **EXECUTES** it:

| # | stated gate | code | executed by |
| --- | --- | --- | --- |
| 1 | the event control is the PARENS-LESS form | `tc.syntax->kind != SyntaxKind::EventControl -> null` | **every `@( … )` twin declines**: a1 c2/c4/c6/c13, a2 d2/d4/d6/d8/d10/d12/d14, a3 g2, a4 h2/h6 |
| 2 | there is no edge and no `iff` — unspellable in this production, so an ASSERTION, not a filter | `sec.edge != EdgeKind::None \|\| sec.iffCondition -> null` | a1 c7 `@(posedge vif.clock)` (which also fails clause 1) |
| 3 | the written name is a DOT-separated path, every separator on its left spine a `.` and not a `::` | `kind != ScopedName -> null`; `separator.kind != TokenKind::Dot -> null` | a1 c8 `@ loc` (not dotted — DECLINES, already byte-identical to golden), a2 d11 `@ pk::pev` (`::` — DECLINES, already byte-identical) |
| 4 | the left spine bottoms out in a PLAIN IDENTIFIER, whose **TOKEN** supplies the name | `n->kind != IdentifierName -> null` | a3 g1 **FIRES** with the escaped name `esc.h`; a4 h1 (`this.…`) and a4 h7 (`$root.…`) **DECLINE** |

Clause (4) is why the name is read from the identifier **TOKEN** and never from
the source text: `\esc.h .clock` is an escaped identifier whose **own text
contains a dot**, and a text scan for the first `.` would split it in half and
ship a lie. Arm a3 g1 executes it and lands on golden's name and fullname
(§3.3). The ops rule that a dotted-name law is exactly where an escaped
identifier bites is **confirmed** here, and the syntax-token choice is what
answers it.

**THE LAW NEVER MOVES A SPAN.** The emitted ref_obj is located at
`sec.expr.sourceRange` — the SAME range the hier_path it replaces was already
located at, in every cell of every arm. So a spelling whose span already
disagreed with golden's (a3 g1's escaped identifier, R3) disagrees by **exactly
the same amount** after this change as before it, and no cell's span moved in
either direction. This is checkable directly: in the pristine-vs-patched diff of
arm a1's own dump, every `-\_hier_path: … line:X` line is answered by a
`+\_ref_obj: … line:X` line with **the identical span**.

**ONE CALL SITE.** The `EdgeKind::None` arm of `emitEventExpr`, immediately
before its `return emitExpr(sec.expr, …)`. There is no second site because there
is no second builder: the object is minted whole (`MakeRef_obj`, name, fullname
via `joinRef(prefix, name)`, parent, `setLoc`) rather than assembled from
hier_path elements, and `joinRef` is the same helper the leaf element of the
replaced hier_path already used — which is why `work@Environment::reset` +
`input_intf` comes out `work@Environment::reset::input_intf` in a class and
`work@top` + `u_if` comes out `work@top.u_if` in a module, with no separator
logic of its own.

---

## 2. THE HEAD, before and after (both modes, via THE HARNESS)

`svsgen.sh` drives `scripts/verify_golden.py --corpus surelog --mode both
--filter '^SVSwitch$'`, so the argv on both sides are the ones the committed
rows were produced with.

```
                     pristine 6ebf930f      shipped 839408ac
row (default)        CMP_NOTEQUAL           CMP_NOTEQUAL     <- NOT a conversion
row (testflags)      CMP_NOTEQUAL           CMP_NOTEQUAL
cmp head depth       48                     17               <- a SUBTREE, not a distance
cmp heads            1                      1
dump content +/-     1934                   1918
o.dump lines         25708                  25698            (golden 25318)
```

Both modes' `cmp.txt` are byte-identical to each other on both binaries
(`diff -q default.cmp.txt testflags.cmp.txt` → identical), which is the brief's
"identical both modes" restated on the shipped binary.

---

## 3. THE GRID, cell for cell

Four arms, **42 measured rows**. `EQ` = our event control's condition is
byte-identical to golden's for that source span — kind, name, fullname, span and
every `vpiActual` element. Read with `ecread.py g.dump o.dump`.

**TWO COUNTS, and they are not the same count.** The table below counts
`ecread.py` ROWS: one row per distinct event-control SPAN present on either
side, so each arm's own interface clocking block (`clocking cb @(posedge
clock)`) is a row, and a cell whose event-control span DIFFERS between the two
sides (a3 g1, a3 g2) shows up as TWO rows, one `<ABSENT>` on each side. The
per-cell tables in §3.1–§3.4 instead count WRITTEN CELLS, and they additionally
list the three spellings Surelog REFUSES to parse (a2 d13, a4 h3, a4 h8), which
produce no event control at all and therefore no row. Neither count is wrong;
conflating them is, so both are stated.

```
arm                         ecread rows   EQ pristine   EQ shipped
a1_parens   the parens matrix     11           7            11
a2_base     the base kind         14           8             8
a3_escaped  escaped + spelling    10           1             6
a4_spine    the left spine         7           2             3
                                ----        ----          ----
                                  42          18            28
```

Arm dump content `+/-`, pristine → shipped: a1 **89 → 20**, a2 **122 → 52**,
a3 **172 → 78**, a4 **128 → 88**.

### 3.1 a1 — THE PARENS MATRIX (the witness's own shape)

A class task holding `virtual in_if.IP vif`, mirroring SVSwitch's interface.

| cell | source | golden | pristine | shipped |
| --- | --- | --- | --- | --- |
| c1 | `repeat (4) @ vif.clock;` **THE WITNESS** | `ref_obj (vif\|full=work@C::c1::vif)@30:27-30:36` | `hier_path(vif.clock)` 2 elems | **EQ** |
| c2 | `repeat (4) @(vif.clock);` | `hier_path(vif.clock)` 2 elems | EQ | **EQ** (declines) |
| c3 | `@ vif.clock;` plain statement | `ref_obj (vif\|full=…::c3::vif)@36:16-36:25` | 2 elems | **EQ** |
| c4 | `@(vif.clock);` | 2 elems | EQ | **EQ** (declines) |
| c5 | `@ vif.cb;` the CLOCKING BLOCK as leaf | `ref_obj (vif\|full=…::c5::vif)@42:16-42:22` | 2 elems | **EQ** |
| c6 | `@(vif.cb);` | 2 elems | EQ | **EQ** (declines) |
| c7 | `@(posedge vif.clock);` NEGATIVE CONTROL | `operation()@48:16-48:33` | EQ | **EQ** (unchanged) |
| c8 | `@ loc;` parens-less, NOT dotted, NEGATIVE CONTROL | `ref_obj (loc\|full=…::c8::loc)` | EQ | **EQ** (declines, clause 3) |
| c9 | `r = vif.clock;` the same read as an ASSIGNMENT RHS | hier_path | — | **UNTOUCHED** |
| c10 | `$display("%b", vif.clock);` CALL ARGUMENT | hier_path | — | **UNTOUCHED** |
| c11 | `if (vif.clock) …` `if` CONDITION | hier_path | — | **UNTOUCHED** |
| c12 | `@ vif.cb.rdy;` THREE components, parens-less | `ref_obj (vif\|full=…::c12::vif)@66:17-66:27` | 3 elems (svs5 recovery) | **EQ** |
| c13 | `@(vif.cb.rdy);` its parenthesized twin | 3 elems, `cb` bare | EQ | **EQ** (declines) |

c9/c10/c11 are the cells the brief demanded ("golden may keep the hier_path
there: the fix must NOT rewrite those"). They are **not event controls at all**,
so `ecread.py` does not list them; the proof they are untouched is the direct
pristine-vs-patched diff of our own dump, in which the ONLY object changes are
the four parens-less event conditions (c1, c3, c5, c12) — 219 diff lines, of
which every one is either those four collapses or the workdir path in a
`class_defn`'s `file:` field.

### 3.2 a2 — THE BASE KIND: is it a virtual-interface law?  **NO.**

Module scope, every non-vif base, each with its parenthesized twin.

| cell | source | golden | shipped |
| --- | --- | --- | --- |
| d1 | `always @ u_if.clock` real interface INSTANCE | `ref_obj(u_if\|full=work@top.u_if)@40:12-40:22` **+ `vpiActual: logic_net`** | kind/name/fullname/span **EQ, `vpiActual` MISSING — R2** |
| d2 | `always @(u_if.clock)` | 2-elem hier_path | **EQ** (declines) |
| d3 | `always @ u_if.cb` clocking block, real handle | `ref_obj(u_if)@45:12-45:19` + actual | **R2** |
| d4 | `always @(u_if.cb)` | 2 elems | **EQ** (declines) |
| d5 | `always @ u_sub.sig` HIERARCHICAL module ref | `ref_obj(u_sub\|full=work@top.u_sub)@50:12-50:21` + actual | **R2** |
| d6 | `always @(u_sub.sig)` | 2 elems | **EQ** (declines) |
| d7 | `always @ st.f` packed-STRUCT member | `ref_obj(st\|full=work@top.st)@55:12-55:16` + actual | **R2** |
| d8 | `always @(st.f)` | 2 elems | **EQ** (declines) |
| d9 | `always @ ev.e` CLASS-OBJECT event member | `ref_obj(ev\|full=work@top.ev)@60:12-60:16` + actual | **R2** |
| d10 | `always @(ev.e)` | 2 elems | **EQ** (declines) |
| d11 | `always @ pk::pev` PACKAGE-SCOPED, `::` | `ref_obj(pk::pev)@65:12-65:19` | **EQ** (declines, clause 3) |
| d12 | `always @(pk::pev)` | `ref_obj(pk::pev)@67:12-67:16` | golden's span TRUNCATES; ours 67:12-67:19. **PRE-EXISTING, R4** |
| d13 | `always @ arr[1] …` parens-less with a SELECT | **SYNTAX ERROR in Surelog** — the production admits no select | cell is a refutation (§4.3) |
| d14 | `always @(arr[1])` | `bit_select(arr)@73:16-73:17` | **EQ** (declines) |

**a2's EQ count did not move (8 → 8), and this pass says so rather than
rounding it up.** What moved is the CONTENT of the five R2 cells: pristine had
the wrong OBJECT KIND (a 2-element `hier_path` where golden has a `ref_obj`);
shipped has the right kind, right name, right fullname and right span, and
differs only by golden's extra `vpiActual`. That is strictly closer and it is
still not EQ. See R2 in §7 for what that `vpiActual` is and why this pass
declined to invent it.

### 3.3 a3 — ESCAPED IDENTIFIERS AND SPELLING

| cell | source | golden | pristine | shipped |
| --- | --- | --- | --- | --- |
| g1 | `@ \esc.h .clock;` ESCAPED base, dot IN THE NAME | `ref_obj(esc.h\|full=work@C::g1::esc.h)@27:16-27:33` | `hier_path(esc.h.clock)@27:16-27:29` | **name + fullname + kind CONVERGE; span 27:16-27:29 vs golden's 27:16-27:33 — PRE-EXISTING, R3** |
| g2 | `@(\esc.h .clock);` its twin | `hier_path@30:16-30:33` | `@30:16-30:29` | **unchanged (declines); same R3 span gap** |
| g3 | `@ vif . clock;` SPACES around the dot | `ref_obj(vif)@33:16-33:27` | 2 elems | **EQ** |
| g4 | `@ vif.<newline>clock;` | `ref_obj(vif)@36:16-37:23` | 2 elems | **EQ** |
| g5 | `@ vif./*c*/clock;` COMMENT before the member | `ref_obj(vif)@40:16-40:30` | 2 elems | **EQ** |
| g6 | `` `ATPATH(vif); `` whole path via a MACRO | `ref_obj(vif)@43:16-43:25` | 2 elems | **EQ** |
| g7 | `@ vif.clock;` tight spelling | `ref_obj(vif)@49:16-49:25` | 2 elems | **EQ** |

g3 is the cell that **distinguishes this law from its prior art**: r10svs5's
clause (4) reads the raw source text and DECLINES on spaces around the dot (its
arm a5 g1, its residue R3). This law reads the syntax and **fires**, landing on
golden. g4/g5/g6 say the same thing three more ways.

### 3.4 a4 — THE LEFT SPINE

| cell | source | golden | shipped |
| --- | --- | --- | --- |
| h1 | `@ this.vif.clock;` | `ref_obj(this\|full=work@C::h1::this)@32:16-32:30` | **DECLINES** (clause 4: `this` is a keyword token). Ours stays `hier_path@32:16-32:20`. **R5** |
| h2 | `@(this.vif.clock);` its twin | **GOLDEN IS DEFECTIVE**: a bare `constant()@35:16-35:30` | unchanged. **Do not imitate** |
| h3 | `@ super.vif.clock;` | **SYNTAX ERROR in Surelog** ("no viable alternative at input '@ super'") | refutation (§4.3) |
| h4 | `@ vif.cb.sig;` THREE components through the cb | `ref_obj(vif\|full=work@C::h4::vif)@44:16-44:26` | **EQ** |
| h5 | `always @ u_sub.u_in.clock` deep hierarchy, THREE components | `ref_obj(u_sub\|full=work@top.u_sub)@54:12-54:28` + `vpiActual` | kind/name/fullname/span **EQ**, `vpiActual` missing — **R2** |
| h6 | `always @(u_sub.u_in.clock)` its twin | 3-elem hier_path | **EQ** (declines) |
| h7 | `always @ $root.top.raw` `$root`-rooted | `ref_obj(top\|full=work@top.top)@59:12-59:25` — golden names the element **AFTER** `$root` | **DECLINES** (clause 4). **R6** |
| h8 | `always @ pk::Q::qs` mixed separators | **SYNTAX ERROR in Surelog** | refutation (§4.3) |

---

## 4. REFUTATIONS

### 4.1 the brief's own paraphrase of golden's object was WRONG, and it said to re-measure

The brief carried an r10svs6-era reading — *"golden one ref_obj named for the
whole dotted text"* — and instructed: *"RE-MEASURE, do not trust either
paraphrase."* Re-measured, and **that paraphrase is REFUTED**:

```
\_ref_obj: (work@Environment::reset::input_intf), line:63:16, endln:63:32
  |vpiName:input_intf                                     <- the HANDLE ALONE
  |vpiFullName:work@Environment::reset::input_intf        <- the handle, scoped
```

The **NAME is the handle alone**; only the **SPAN** covers the whole dotted
text. Had the law been written from the paraphrase it would have emitted a
ref_obj named `input_intf.clock` and moved nothing. It also carries **no
`vpiActual`** in a class — the brief asked "what it binds via vpiActual", and
the measured answer is **nothing**.

### 4.2 the brief's collision warning is REFUTED: `.clock` is not a clocking block

The brief said `§ vifClockingPathComponent5` "may be the operative prior art or
the collision" and required decoding `.clock` first. It is the interface's
**plain input port**, re-exposed by `modport IP(…, input clock)` — quoted in
full in §0. The clocking block is `cb`, and this pass never touches r10svs5's
code. The two laws meet only in a1 c12 / a4 h4, where they compose correctly.

### 4.3 the parens-less production is NOT "the same expression without parens"

Three spellings that are legal inside `@( … )` are **SYNTAX ERRORS** outside it,
so the parens-less form is a strictly narrower grammar rule and not an optional
pair of characters:

```
a2 d13  always @ arr[1] raw <= 1;        -> "mismatched input '['"
a4 h3   @ super.vif.clock;               -> "no viable alternative at input '@ super'"
a4 h8   always @ pk::Q::qs raw <= 1;     -> "extraneous input '::'"
```

`this` and `$root` **are** accepted there (they appear in Surelog's own expected-
token list, and a4 h1/h7 parse), which is why those two are residues and not
refutations.

### 4.4 "it must be a virtual-interface law" — REFUTED by arm a2

The witness is a virtual interface, the head is a virtual interface, and
r10svs5's law next door is scoped to virtual interfaces. It would have been
natural to gate on that. Arm a2 refutes it in five different ways: a real
interface INSTANCE, a hierarchical module reference, a packed-struct member and
a class-object event member all collapse identically, and SVSwitch's own line
121 shows the **same virtual interface, same member** NOT collapsing when it is
parenthesized. A vif-gated predicate would have been right about the witness and
wrong about the law.

### 4.5 the census predicted the blast radius exactly, and the byte verifier confirmed it

`census.sh` found **seven** parens-less dotted event controls across both
corpora. Six are in tests that are `SLANG_REJECT` (UVMSwitch, OVMSwitch,
Monitor, Opentitan/Earlgrey) or have no `.sl` and therefore no row at all
(Google chapter-15, Icarus pr572). **SVSwitch is the only live carrier**, and
the uhdm2rtlil corpus has **zero** hits. Prediction: 0 movers on u2r, movers on
surelog confined to SVSwitch. Measured: **u2r 0 / 679**, **surelog 2 / 953, both
of them SVSwitch's two modes** (§6).

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

```
/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs9
[100%] Linking CXX executable slang-uhdm          <- the link line, waited for
[100%] Built target slang_uhdm
md5(build/slang-uhdm) = 839408ac5c4c225717bd721cc3042ec3   (32 hex, asserted separately)
strings | grep -c parensLessEventPathBase9 = 1

pristine worktree r10svs9pris, clean at 595c2e3 (git rev-parse + git status both checked):
md5 = 6ebf930f2b58e9b70373d9b9282db381
strings | grep -c parensLessEventPathBase9 = 0
```

A datum worth recording: the pristine worktree and the patched worktree, both
clean at 595c2e3, built **byte-identical** binaries
(`6ebf930f2b58e9b70373d9b9282db381` on both) before the patch was applied. That
is a stronger baseline assertion than "the same commit" — it is the same binary.

### GATE 2 — GOLDENS, with the negative control

```
SLANG_UHDM=<shipped> tests/check_goldens.sh   ->  23 PASS / 0 FAIL
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL   (control fires)
```

Evidentiary value, stated honestly: `grep -lE '@ *[A-Za-z_][A-Za-z_0-9]* *\.'
tests/golden/*.dump` matches **0 of 23** source-level parens-less paths — the
goldens prove this law did not break the unrelated corpus; they cannot confirm
it.

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep, judged the same way:   0 differing ROWS
```

### GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

**UNCONVERTED WORLD** — SVSwitch stays `CMP_NOTEQUAL` in both modes, so the
expectation is the unconverted one and it is met exactly:

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / …
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / …
dump histograms: UNCHANGED in both modes
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep: 0 differing ROWS
```

No `results/*.csv` was touched by this pass.

### GATE 5 — BYTE VERIFIER, both corpora, vs a PRISTINE 595c2e3 built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 9 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 10  (= the 9 real movers + 1 corrupted)

  ./default/SVSwitch      ./testflags/SVSwitch
  ./default/BuildUVMPkg   ./testflags/BuildUVMPkg
  ./default/SeqDriver     ./testflags/SeqDriver
  ./default/SimpleUVM     ./testflags/SimpleUVM
  ./default/Scoreboard    (testflags is SLANG_REJECT — no database)
```

**All nine are law content and nothing else** (§5.5), and the seven beyond
SVSwitch are the UVM library's own `@waiter.trigger;` — a carrier this pass's
first census MISSED and the byte verifier found (§6.1).

### 5.5 MOVERS PER SHAPE, BY MULTISET

`sed 1d` applied to every dump; ADDED and REMOVED counted **separately** and
never netted; and each ADDED shape checked against **GOLDEN's own count** for
that line, which is the only test that says a mover is a CONVERGENCE.

**SVSwitch** (identical in both modes), OUR side, pristine → shipped:

```
  REMOVED  3 x  \_hier_path: (input_intf.clock), line:63:16, endln:63:32     golden 0
  REMOVED  1 x    \_ref_obj: (input_intf), line:63:16, endln:63:26           golden 0
  REMOVED  1 x    \_ref_obj: (work@Environment::reset::clock), 63:27-63:32   golden 0
  REMOVED  2 x  |vpiParent:   2 x |vpiActual:   1 x |vpiName:input_intf.clock
  REMOVED  1 x  |vpiName:input_intf   1 x |vpiName:clock
  REMOVED  1 x  |vpiFullName:work@Environment::reset::clock
  ADDED    1 x  \_ref_obj: (work@Environment::reset::input_intf), 63:16-63:32 golden 1
  ADDED    1 x  |vpiName:input_intf
  ADDED    1 x  |vpiFullName:work@Environment::reset::input_intf
  o.dump lines 25708 -> 25698 (-10)      MULTISET DISTANCE 1384 -> 1368 (-16)
```

(The `hier_path` line's count of 3 is 1 real node plus the 2 `vpiParent`
back-pointers its children print; the reader in `ecread.py` is what keeps those
apart when reading the grid, and they are shown here because the raw multiset
does not.)

**BuildUVMPkg / SeqDriver / SimpleUVM / Scoreboard** — all four carry the SAME
single site and the SAME per-shape movement, to the line:

```
  REMOVED  3 x  \_hier_path: (waiter.trigger), line:L:6, endln:L:20                 golden 0
  REMOVED  1 x    \_ref_obj: (waiter), line:L:6, endln:L:12                         golden 0
  REMOVED  1 x    \_ref_obj: (uvm_pkg::…::wait_modified::trigger), L:13-L:20        golden 0
  REMOVED  2 x |vpiParent:  2 x |vpiActual:  1 x |vpiName:waiter.trigger
  REMOVED  1 x |vpiName:waiter  1 x |vpiName:trigger
  REMOVED  1 x |vpiFullName:uvm_pkg::uvm_config_db::wait_modified::trigger
  ADDED    1 x  \_ref_obj: (uvm_pkg::…::wait_modified::waiter), L:6-L:20            golden 1
  ADDED    1 x |vpiName:waiter
  ADDED    1 x |vpiFullName:uvm_pkg::uvm_config_db::wait_modified::waiter
  dump lines -10 in EVERY ONE     (L = 294, or 18064 in BuildUVMPkg's pp_output)
```

**Every ADDED shape lands on golden's count EXACTLY (golden 1, pristine 0,
shipped 1) and every REMOVED shape is one golden does not have (golden 0).**
There is no third shape, no relocation, and no net-zero pairing anywhere.

#### 5.5.1 THE KNOWN FLAKE, executed rather than cited

The ops rules name `Scoreboard/default` as MULTI-STABLE (≥3 hashes per binary)
and require a 3-rep plus a size delta before attributing anything there. Done,
on the SHIPPED binary:

```
rep1  md5=8e7bc11d047e6eaf  bytes=11133375   addedShape=1  oldHierPath=0
rep2  md5=a45b2431aaa187c5  bytes=11133375   addedShape=1  oldHierPath=0
rep3  md5=7b5947eca86ea488  bytes=11133375   addedShape=1  oldHierPath=0
                pristine    bytes=11133612
```

**THREE DIFFERENT HASHES, ONE SIZE, ONE LAW SHAPE.** The flake is confirmed and
is real — the md5 is worthless as a mover signal here — but the attribution
holds on the two instruments that are stable: the size delta (−237 bytes, and
−10 dump lines, the same delta every other carrier shows) and the per-shape
content, which is byte-identical across all three reps and lands on golden.

### 5.6 CANARIES

```
u2r      canaries.sh  ok=…  changed=0 absent=0
         ctcan2.sh    ok=…  changed=0 absent=0   unknown-patterns = EXPECT_UNKNOWN=6
surelog  canaries.sh  ok=…  changed=0 absent=0
         ctcan2.sh    ok=…  changed=0 absent=0   unknown-patterns = EXPECT_UNKNOWN=1
canaudit.sh canaries.sh ctcan2.sh -> audited=…  UNCOVERED=0  FENCE-BREACH=0
InterfaceModPort  : CMP_EQUAL both modes, row byte-identical to baseline
BlackParrotComplex: row byte-identical to baseline
```

---

## 6. WHAT MOVED, AND WHY IT IS ONLY THAT

The census is the whole story — **after this pass corrected it.** `census.sh`
over both corpora:

```
SVSwitch/Environemnt.sv:63              repeat (4) @ input_intf.clock;   <- LIVE ROW
UVMSwitch/Driver.sv:67                  repeat (4) @ input_intf.clock;   <- SLANG_REJECT
OVMSwitch/Driver.sv:67                  repeat (4) @ input_intf.clock;   <- SLANG_REJECT
Monitor/design.sv:32                    @_if.cb;                         <- SLANG_REJECT
Opentitan/…/rv_timer_scoreboard.sv:253  @cfg.clk_rst_vif.cb;             <- SLANG_REJECT
Opentitan/…/rv_timer_scoreboard.sv:277  @cfg.clk_rst_vif.cb;             <- SLANG_REJECT
Google/chapter-15/15.5.2--…:21          @top.e;                          <- no .sl, no row
Icarus/ivltests/pr572.v:33              @top.toplevel_event              <- no .sl, no row
uhdm2rtlil corpus                       (none)
```

Two of those — `@cfg.clk_rst_vif.cb` and `@_if.cb` — are three- and two-
component paths through a class member, i.e. exactly the shapes arms a1 c12 and
a4 h4 measured. **They become the live population the moment Opentitan or
Monitor stops being SLANG_REJECT**, and this law is already correct for them.

### 6.1 THE CENSUS'S FIRST RUN WAS WRONG, AND THE BYTE VERIFIER CAUGHT IT

The census above originally scanned `Surelog/tests`, `Surelog/third_party/tests`
and `uhdm2rtlil/test` — and **NOT `Surelog/third_party/UVM`**, which is a
separate root that those tests `-mtx`/include. On that census this pass
predicted **2 surelog movers, both SVSwitch**. GATE 5 reported **9**, and the
prediction was wrong by seven.

Re-run over the missing root, the extra carrier is a single line of the UVM
library itself:

```
UVM/1800.2-2017-1.0/src/base/uvm_config_db.svh:289   @waiter.trigger;
UVM/1800.2-2017-1.0/pp_output/uvm_pkg.sv:18064       @waiter.trigger;   (the same line, preprocessed)
```

`waiter` is a local class handle and `trigger` is an event — a **class-object
member**, arm a2 d9's shape exactly. Every test that compiles the UVM package
carries it once, which accounts for all seven:

```
SVSwitch     default + testflags     Environemnt.sv:63
BuildUVMPkg  default + testflags     uvm_pkg.sv:18064
SeqDriver    default + testflags     uvm_config_db.svh:294
SimpleUVM    default + testflags     uvm_config_db.svh:294
Scoreboard   default ONLY            uvm_config_db.svh:294
                                     (testflags is SLANG_REJECT — NO DATABASE,
                                      so there is nothing to move; the mode
                                      asymmetry is the corpus's, not the law's)
                                                                  = 9 movers
```

**This is recorded as a refutation of this pass's own method, not smoothed
over.** A census that names its roots is only as good as the roots it names, and
the byte verifier is what made the omission visible instead of leaving it as an
unexplained mover count.

---

## 7. RESIDUES, RANKED

**R1 — THE SUCCESSOR HEAD, and it is fully localized.** Golden gives a
class-typed net at design-component scope a `vpiTypespec -> ref_typespec ->
class_typespec (<ClassName>)`; we drop that link. **The discriminator is
ASSIGNMENT**, and arm `b5_newassign.sv` splits it in four cells:

```
program tc;  K r1;  K r2;  K r3;  K r4;
  initial begin r2 = new();  r3 = new(7);  r4 = r2; end

  r1  never assigned          golden: ref_typespec -> class_typespec (K)   ours: SAME   EQ
  r2  assigned by new()       golden: ref_typespec -> class_typespec (K)   ours: ABSENT
  r3  assigned by new(7)      golden: ref_typespec -> class_typespec (K)   ours: ABSENT
  r4  assigned from a handle  golden: ref_typespec -> class_typespec (K)   ours: ABSENT
```

SVSwitch's two sites (`testcase.sv:20-21`) are both assigned (`:26 spkt = new();`,
`:27 env = new(mem_intf,…)`), which is why both lose the link and why the head
landed on `env`. Four things were REFUTED as the discriminator on the way here
and each has its arm: **program scope** (b1 k5 — already EQ), **being
instantiated** and **having ports, including an interface-modport port** (b2
n1..n4 — `cmp heads=0`, all EQ), **`extends`** and **`constraint`** (b4 q1..q4 —
all EQ). It is a wide law (every class handle in every design-component DEF view
is in its blast radius) and it belongs to its own pass with its own grid; this
pass deliberately did **not** widen into it.

**R2 — the module-scope `vpiActual` on the collapsed ref_obj.** In a MODULE,
golden's collapsed ref_obj binds a `logic_net` (a2 d1/d3/d5/d7/d9, a4 h5); in a
CLASS it binds nothing (a1, a3, a4 h4 — all EQ). For d1/h5 the bound object is a
net **synthesized at the reference's own span** (`logic_net()@40:12-40:22`),
i.e. Surelog's implicit-net creation; for d7/d9 it is the declared object. This
pass emits no `vpiActual` rather than inventing an object, so those six cells
are right in kind, name, fullname and span and short one field. **ZERO live
carriers** — every census hit is in a class or a `SLANG_REJECT` test — so this
buys nothing today and would need its own measurement of when Surelog
synthesizes the net and when it binds the declaration.

**R3 — the escaped-identifier span, PRE-EXISTING and symmetric.** a3 g1/g2:
golden's span for a path whose base is `\esc.h ` runs four columns longer than
ours, in **both** the parens-less and the parenthesized spelling, on **both**
binaries. This law does not touch spans (§1), so the gap is identical before and
after. It is a source-column question about escaped identifiers, not about event
controls.

**R4 — `@(pk::pev)`'s truncated golden span.** a2 d12: golden gives the
parenthesized scoped reference `67:12-67:16` where the written text runs to
`67:19`; ours spans the text. Pre-existing, untouched, and the parens-less twin
(d11) is EQ on both binaries.

**R5 — `@ this.a.b`.** a4 h1: golden collapses to `ref_obj(this)` spanning the
whole path; clause (4) declines because `this` is a keyword token, not an
`IdentifierName`. Widening clause (4) to admit it is a two-line change and it
would converge h1 — but its parenthesized twin h2 shows golden emitting a bare
`constant()` for the same path, i.e. golden is **defective** in this
neighbourhood, and there is no live carrier. Ranked below R2 for that reason.

**R6 — `@ $root.a.b`.** a4 h7: golden names the element **AFTER** `$root`
(`ref_obj(top)`), not `$root` itself, so admitting it needs a *different* base
rule, not just a wider clause (4). No live carrier.

---

## 8. FILES

```
README.md          this record
svsgen.sh          the SVSwitch pair, both modes, through the harness itself
svs9arm.sh         one arm: Surelog + ours + dumps + cmp, in its own scratch dir
ecread.py          the grid reader: every event control's condition, span-keyed,
                   indent-walked so vpiParent back-pointers are not counted
census.sh          the parens-less-dotted-event-control census, both corpora
a1_parens.sv       the parens matrix (the witness's own shape)
a2_base.sv         the base kind: is it a virtual-interface law?  (no)
a3_escaped.sv      escaped identifiers and spelling
a4_spine.sv        the left spine
b1_clsnet.sv       R1: class-typed nets by scope
b2_progdef.sv      R1: instantiated / ported programs
b3_progcls.sv      R1: the class's own shape
b4_derived.sv      R1: extends / constraint
b5_newassign.sv    R1: THE SPLIT — assignment is the discriminator
byteverify.sh ct8rows.sh canaries.sh ctcan2.sh canaudit.sh msdist.sh msmovers.sh
                   the gate + canary harness, carried from r10svs8repro unchanged
```
