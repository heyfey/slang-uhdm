# r10buvm24 — § `emptyArgSlotIntZero24` — **A WRITTEN-BUT-EMPTY ARGUMENT SLOT IS NOT THE FORMAL'S DEFAULT: Surelog mints a bare unparented `INT:0` there, whatever the default is — and the LEADING empty slot contributes nothing at all**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `c0f3a94` |
| worktree | `/tmp/wt_r10buvm24` |
| pristine binary | md5 `d35dfd84201d10e1e332201db22417fa` — reproduced the main tree's binary byte for byte — frozen `chmod 555` at `/tmp/r10buvm24_bin/pristine.bin` |
| patched binary | md5 `44024e438004a20693c409a5cecefbf0`, `/tmp/r10buvm24_bin/pat.bin` |
| production surface | `include/UhdmExporter.h` (1 declaration + 1 forward decl), `src/EmitHelpers.h` (2 readers), `src/ExprEmit.cpp` (1 minting member + the gate at 13 argument loops) |
| probe surface | `tools/probe/r10buvm24repro/` only |
| deliverable | `/tmp/r10buvm24.patch`, applies clean on a FRESH `c0f3a94` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass** — and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines AND against this pass's own pristine
sweep, in both corpora and both modes, status AND dump column.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **32 / 32** | **56 / 56** (a DEEPER head object, not a longer distance) |
| `BuildUVMPkg` cmp md5 (`2>&1`), both modes | `070cefa7005899f934be8d9900f37744` (buvm23's pin, hit exactly) | `8f6d48af61782566449277323fcf2c19` |
| head object | a `constant` `INT:0` ct 7 vs `UINT:0` ct 9 at `uvm_pkg.sv:30186` | a `foreach` loop variable `array_var` vs `class_var` at `uvm_pkg.sv:9847` (**R0**) |
| `CALL` census, `BuildUVMPkg`, judge-visible, MATCHING GOLDEN | 14 241 / 14 349 | **14 264** (+23; SURPLUS 59 → 36) |
| the same over all NINE movers | — | **+295 cells TO golden, 0 away, 0 new surplus** |
| the golden GRID `g24.sv`, judge-visible | MATCHING 58 / 295 | **288 / 295** (`+230`; SURPLUS 247 → **7**, and those 7 are a SUBSET of the pristine surplus) |
| the golden GRID `g24.sv`, NON-judge payload (value / span / parent) | MATCHING 58 / 295 | **295 / 295** — the placeholder's SPAN and its UNPARENTED-ness are byte-right too |
| grid OBJECT COUNT | golden 295, ours 305 | golden 295, ours **295** |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG

`/tmp/r10buvm24_wd/pris.default.cmp` (32 lines `2>&1`, md5
`070cefa7005899f934be8d9900f37744`, `grep -c '^LHS:'` = 1, byte-identical
between the two modes):

```
LHS  constant: , line:30186:82, endln:30186:82        <- UNPARENTED, at the CALL SITE
       |vpiDecompile:0  |vpiSize:64  |INT:0   |vpiConstType:7
RHS  constant: , line:24157:58, endln:24157:59        <- the DECLARATION's own literal
       |vpiParent: \_method_func_call: (open_recorder) @30186:42-55
       |vpiDecompile:0  |vpiSize:64  |UINT:0  |vpiConstType:9
```

**THE FIELD IS `VpiConstType`**, and the generated sources settle it rather than
the log.  `constant::Compare`
(`~/git-repos/UHDM/build/generated/src/constant.cpp:58`) is

```cpp
if ((r = basetype_t::Compare(other, context)) != 0) return r;   // expr
if ((r = lhs->VpiConstType() - rhs->VpiConstType()) != 0) { … }  // and NOTHING else
```

and `expr::Compare` (`generated/src/expr.cpp:83`) reads `BaseClass::Compare`
(VpiType / VpiName / VpiDefName), then `VpiDecompile` ("0" on both), `VpiSize`
(64 on both) and `Typespec` (null on both).  **`VpiValue` is never compared** —
`INT:0` vs `UINT:0` reaches the judge only through const type 7 (`vpiIntConst`)
vs 9 (`vpiUIntConst`).  No generated `Compare` reads `VpiParent`, `VpiFile` or
the line/col, so "unparented, at the call site" is model, not judge.

Site, `1800.2-2017-1.0/pp_output/uvm_pkg.sv:30186`, in
`uvm_default_report_server::execute_report_message`:

```systemverilog
uvm_recorder recorder = stream.open_recorder(report_message.get_name(),,report_message.get_type_name());
```

against `uvm_tr_stream::open_recorder(string name, time open_time = 0, string type_name="")`
at `:24156-24158` (the `0` is at `24157:58`).

**WHICH COPIES.**  The `CALL` census over the whole database answers the
brief's question exactly: golden `BuildUVMPkg` holds **23 placeholder objects
over 12 distinct source sites**; eleven of the twelve carry **two** copies (the
DEF and the ELAB listing of the class method) and the head site `30186:42`
carries **one**, which is the same one-copy shape buvm23 measured for its own
head in that very method.  So the head object is NOT shared — it is one of 23,
and all 23 move together.

## 2. THE LAW

> **§ `emptyArgSlotIntZero24`** — a subroutine call's argument slot that the
> source **WROTE and left EMPTY** does not carry the formal's default at all:
>
> * it carries a FRESH `constant` — `VpiValue "INT:0"`, `VpiDecompile "0"`,
>   `VpiSize 64`, `VpiConstType 7` (`vpiIntConst`), **no typespec**, **no
>   vpiParent**, spanned at the empty slot itself — **whatever the formal's
>   declared default is**: an unsized decimal, `32'h0`, `8'hFF`, `-1`, `""`,
>   `"zz"`, a byte character `"."`, `1.5`, `time 0`, `null`, an enum member, a
>   parameter reference, `PAR24+1`, or a CALL `help24(2)` — seventeen kinds
>   measured, one answer;
> * the **LEADING** empty slot contributes **NOTHING**: `f3(,2,3)` is TWO
>   arguments, `f3(,,3)` is two (placeholder, `3`), `f3(,,)` is two
>   placeholders — while `f3(1,,)` is THREE;
> * a formal that was **not written at all** still contributes nothing
>   (§ `writtenCallArgs16`, untouched), and a call written with NAMED
>   association still takes § `namedTfArgsFormalSlots4`'s LOC-LESS twin of the
>   same object (untouched — `emptyArgSlots24` refuses a list with any named
>   argument outright).
>
> The gate is POSITIONAL-ONLY and ALL-OR-NOTHING; every call in either corpus
> that writes no empty slot emits byte for byte as before, by construction.

## 3. DECODED FROM SURELOG (`~/git-repos/Surelog`), NOT INFERRED

`CompileHelper::compileTfCallArguments`, `src/DesignCompile/CompileHelper.cpp:4340`.
The by-position arm's `else` branch — reached when the `paArgument` node has no
child, i.e. an EMPTY slot — is the whole model:

```cpp
} else {                                  // Expression is an invalid NodeId
  constant* c = s.MakeConstant();
  c->VpiValue("INT:0");
  c->VpiDecompile("0");
  c->VpiSize(64);
  c->VpiConstType(vpiIntConst);
  fC->populateCoreMembers(argumentNode, argumentNode, c);   // <- the SPAN
  arguments->push_back(c);                                  // <- and NO VpiParent
}
```

It never looks at `io_decls` and never sees the formal — which is why the
default's KIND cannot matter.  Note the two deliberate absences: the sibling
branches all do `if (exp->VpiParent() == nullptr) exp->VpiParent(call);` and
this one does not, so the object is **unparented**; and
`populateCoreMembers(argumentNode, argumentNode, …)` gives it the empty slot's
own zero-width span (`30186:82-82`, the second comma of `,,`).

The SAME routine's NAMED arm, a few lines below, mints the same constant with
`VpiFile` and **no** `populateCoreMembers` — that is § `namedTfArgsFormalSlots4`
(buvm4), already in the tree as `namedSlotFiller4`, and this pass reuses it and
only adds the span.

**slang's side**, `source/ast/expressions/CallExpression.cpp:218`
(`CallExpression::bindArgs`):

```cpp
if (arg->kind == SyntaxKind::EmptyArgument) {
    // Empty arguments are allowed as long as a default is provided.
    expr = formal->getDefaultValue();
```

— the bound argument IS the DECLARATION's own expression object, which is
exactly why we emitted its encoding and its span.  The distinction only
survives in the INVOCATION SYNTAX (`SyntaxKind::EmptyArgument`), which is where
`emptyArgSlots24` reads it.

The LEADING-slot rule was **measured, not read**: Surelog's argument-list parse
simply yields no node for it (`g24.sv:79/81/83`), so the list shifts left.

## 4. THE GOLDEN GRID — `g24.sv`, 295 OBJECTS, BOTH VIEWS

`grid24.sh` compiles `g24.sv` with Surelog and with both binaries, with and
without `-elabuhdm`/`--elabuhdm`; `gridcmp24.py --ms` scores it as a TRUE
MULTISET per `(call loc, kind, name)` key.  The argument COUNT is deliberately
**not** in the key — this law changes it — and a positional pairing would then
report a BROKEN cell for a defect that was already there.

```
$ python3 gridcmp24.py cen.g.txt cen.pris.txt cen.pat.txt --ms
OBJECTS golden 295  pristine 305  patched 295
MATCHING GOLDEN  pristine 58  patched 288   (TO-GOLDEN +230)
SURPLUS (objects golden has not) pristine 247  patched 7
$ python3 gridcmp24.py cen.g.txt cen.pris.txt cen.pat.txt --ms --x   # value/span/parent
MATCHING GOLDEN  pristine 58  patched 295   (TO-GOLDEN +237)   SURPLUS 247 -> 0
```

The **7** remaining surplus objects are ONE cell — the io_decl default
`int b = help24(2)`'s own argument constant, whose `Typespec` is a
`ref_typespec` where golden has none — and they are a **strict SUBSET of the
pristine surplus** (checked item by item: `patched surplus NOT already in
pristine surplus = 0`).  They were wrong before this pass; what changed is that
ten CLONE copies of the same call, which used to pair against golden by
accident, are gone.  Per view: def 18 → 91 of 93, elab 40 → 197 of 202.

### 4.1 GOLDEN's answer — THE DEFAULT-KIND AXIS (`f(1,,4)`, middle slot empty)

Every row's golden middle argument is `C:ct=7:sz=64:dc=0:ts=-`, `INT:0`,
UNPARENTED, at the empty slot.  What we USED to emit:

| formal's default | ours, pristine | patched |
|---|---|---|
| `int b = 0` | `ct=9 UINT:0` (**the corpus head**) | FIXED |
| `int b = 7` | `ct=9 dc=7` | FIXED |
| `int b = 32'h0` | `ct=5 sz=32 dc=32'h0` | FIXED |
| `byte b = 8'hFF` | `ct=5 sz=8 dc=8'hFF` | FIXED |
| `int b = -1` | an `operation` | FIXED |
| `string b = ""` | `ct=6 sz=0 dc=""` | FIXED |
| `string b = "zz"` | `ct=6 sz=16 dc="zz"` | FIXED |
| `byte b = "."` | `ct=6 sz=8 dc="."` (**the corpus's `print_field_int`**) | FIXED |
| `real b = 1.5` | `ct=2 dc=1.5` | FIXED |
| `time b = 0` | `ct=9 UINT:0` | FIXED |
| `base24 b = null` | `ct=11` | FIXED |
| `e24_t b = E1` | `ref_obj (E1)` (**the corpus's `UVM_NORADIX`**) | FIXED |
| `int b = PAR24` | `ref_obj (PAR24)` | FIXED |
| `int b = PAR24+1` | an `operation` (**the corpus's `uvm_vreg::read`**) | FIXED |
| `int b = help24(2)` | a whole `func_call` | FIXED (and the surplus call object disappears) |
| `bit b = 1'b1` | `ct=3 sz=1` | FIXED |
| `bit [3:0] b = 4'b1010` | `ct=3 sz=4` | FIXED |

### 4.2 THE OMISSION-FORM AXIS — golden, read off `g24.sv:78-86`

| written | golden `narg` | golden arguments |
|---|---|---|
| `f3(1,,3)` | 3 | `1` · **PH** · `3` |
| `f3(1,2,)` | 3 | `1` · `2` · **PH** |
| `f3(1,,)` | 3 | `1` · **PH** · **PH** |
| `f3(,2,3)` | **2** | `2` · `3` — the LEADING slot VANISHES |
| `f3(,,3)` | **2** | **PH** · `3` |
| `f3(,,)` | **2** | **PH** · **PH** |
| `f3(1,2,3)` | 3 | unchanged |
| `f3(1)` | 1 | § `writtenCallArgs16`, unchanged |
| `f3()` | 0 | unchanged |
| `f3(.a(1), .c(3))` | 3 | `1` · **PH(no span)** · `3` — § `namedTfArgsFormalSlots4`, ALREADY correct on the pristine binary and byte-unchanged |

### 4.3 The other axes, all FIXED, both views

* **callee family** package `function` · package `task` · class method called
  BARE in-body · class method through a HANDLE (`o.mf3`) · through `this` ·
  module `function` · module `task` · a class **constructor** (`bh = new(1,,3)`);
* **home** class in-body · class OUT-OF-BODY (`function int c24::oob24`) ·
  package function · module `initial` · module function · class task;
* **position** r-value · statement (task calls) · nested as an ARGUMENT of
  another call with an empty slot (`f3(1,, f3(1,,3))` — both slots FIXED);
* **view** def and elab, identical rules.

After the patch the whole grid's judge-visible census is `SAME 91, DIFF 2,
GOLDEN-ONLY 0, OURS-ONLY 0` (def) and `SAME 197, DIFF 5, GOLDEN-ONLY 0,
OURS-ONLY 0` (elab) — every DIFF being the one `help24` cell of §4.

## 5. THE FENCE, ENUMERATED FROM THE SOURCES BEFORE THE CODE

`PREDICTION.txt` (written before the patched sweep existed) and `fence24.py`.
The population is LEXICAL — `,` before `,` or `)`, or `(` before `,`, with
comments gone and string literals replaced by a TOKEN (deleting them turns
`$display("%d", x)` into `(, x)` and floods the scan) — so it is a genuine
superset that can be enumerated rather than guessed.

| corpus | test-modes scanned | with an empty slot | predicted movers |
|---|---|---|---|
| `uhdm2rtlil` | 1 462 | **0** | **NONE**, 0 of 1358 |
| `surelog` | 1 573 | 62 | **9**, by name |

The 62 split three ways, and the split is the fence:

* **9 CMP_NOTEQUAL** — the UVM databases, 27 empty slots each:
  `default/BuildUVMPkg` `testflags/BuildUVMPkg` `default/MiniAmiq`
  `testflags/MiniAmiq` `default/SeqDriver` `testflags/SeqDriver`
  `default/SimpleUVM` `testflags/SimpleUVM` `default/Scoreboard`
  (Scoreboard's testflags row is `SLANG_REJECT`).  **The same nine buvm23
  moved**, and no CMP_EQUAL row is among them.
* **6 CMP_EQUAL** — and NOT ONE of their empty slots is a subroutine-call
  argument, each read by hand: `ImplicitPorts2` `dff u0 ( q,,clk);` (a module
  PORT connection), `SequenceInst` `p_multiclock(negedge clk2, , posedge clk1,…)`
  (a SEQUENCE instance), `SynthForeach` `foreach(B[q, r, , s])` (an index list),
  both modes each.  All six predicted NOT to move — and none did.
* **47 SLANG_REJECT** — no database at all.  Their empty slots are OVM/VMM/UVM
  library text plus `$past(x,,,clock)` (`LetExpr`, `SystemCall`), a SYSTEM call,
  which no arm this pass touches reaches.

**The probe tree is its own negative control.**  Four arms under
`tools/probe` hold a lexical empty slot: this pass's `g24.sv`, and
`r10svs11repro/c2_udpshape.sv` (`kie u12 (Clock, , e12i);`),
`r10svs12repro/v2_posedges.sv` (`leaf2 x1[4](Clock, );`),
`r10svs13repro/a3_udpboundary.sv` (`leafmixp s3p(, arr);`) — three MODULE
INSTANCE port lists, all three **byte-identical** in all four boundary runs.

## 6. THE GATES

All run from this worktree with `SLANG_UHDM` exported explicitly per binary and
every `cmds.txt` audited by binary PATH (2 981 lines per sweep, one path each).

| gate | result |
|---|---|
| (1) build both, md5 | pristine `d35dfd84201d10e1e332201db22417fa` (= main tree), patched `44024e438004a20693c409a5cecefbf0`, 0 errors |
| (2) goldens | patched `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `FAIL=23 PASS=0`; pristine `PASS=23 FAIL=0` |
| (3) `uhdm2rtlil` | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in BOTH modes; `ct8rows` **0 differing ROWS** vs the committed `results/gate_uhdm2rtlil.csv` AND vs this pass's own pristine sweep, status AND dump, both modes |
| (4) `surelog --mode both` | `936 CMP_EQUAL / 20 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM / 567 SLANG_REJECT / 48 SURELOG_FAIL / 1 TIMEOUT / 2 UNTRANSLATABLE` — identical to the pristine sweep; `ct8rows` **0 differing ROWS over the 1 588** against BOTH the committed `results/golden_surelog.csv` and the pristine sweep.  **NO ROW CONVERTED**; nothing promoted |
| (5) byteverify `SELFCHECK=1` | `uhdm2rtlil` **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, SELFCHECK 1357/1358; `surelog` **MOVERS 9 / 956 — exactly the nine §5 predicted BY NAME**, SELFCHECK 955/956 |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r); `ctcan2` PASS with `EXPECT_UNKNOWN=1` / `6`; `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| row heads | SeqDriver 50/50, SimpleUVM 108/108, Scoreboard 108/–, MiniAmiq 50/50, Earlgrey_0_1 216/216, Rggen 194/– **all unchanged**; BuildUVMPkg 32 → 56 (1 head throughout) |

### Protected databases (md5, pristine vs patched)

| DB | verdict |
|---|---|
| `InterfaceModPort` (both modes) | SAME `59a365f3ce2c` |
| `BlackParrotComplex` | SAME `e3e354129d5a` / `73a10e8217e5` |
| `YosysOldOr` (both modes) | SAME `d68e0796d62c` |
| `SVSwitch` (both modes) | SAME **`4842211c4030`** — the brief's pin, hit |
| `YosysVerx` (both modes) | SAME **`6ccda350c24a`** — the brief's pin, hit |

### The nine movers, ATTRIBUTED and SCORED

Three-way `CALL` census against each database's OWN golden (`movers24.sh`), and
an ORDER-BLIND path-normalised `uhdm-dump` diff (both dumps `sort`ed, ids
stripped) for attribution:

| database | call objects (golden) | matching golden, pristine → patched | new surplus |
|---|---|---|---|
| `BuildUVMPkg` ×2 | 14 349 | 14 241 → **14 264** (+23) | **0** |
| `MiniAmiq` ×2 | 24 799 | 23 321 → **23 366** (+45) | **0** |
| `SeqDriver` ×2 | 23 713 | 22 283 → **22 328** (+45) | **0** |
| `SimpleUVM` ×2 | 14 252 | 13 451 → **13 474** (+23) | **0** |
| `Scoreboard` (default) | 14 381 | 13 576 → **13 599** (+23) | **0** |

**295 cells moved TO golden, 0 away, 0 new surplus object anywhere.**  The
order-blind dump diff carries no collateral: for `BuildUVMPkg` the 308 changed
lines are 23 new `vpiConstType:7` + 23 `INT:0` + 22 `vpiDecompile:0` + 21
`vpiSize:64` against 23 removed `vpiParent:` and the cloned defaults they
replace (13 `vpiConstType:9`, 8 `vpiConstType:6` `"."` byte strings, 12
`vpiOpType:1` `-1` operations); `SeqDriver` 586 lines and `SimpleUVM` 298 lines
show the identical shape at 45 / 23.

## 7. THE BOUNDARY GATE

From a COPY of the WHOLE `tools/probe` tree (`/tmp/r10buvm24_probecopy`), **no
path filter**, `.sv` AND `.v`, per-FILE and per-DIRECTORY, in BOTH views.

```
MODE=file VIEW=def   PROCESSED=3174 LISTED=3174 DIFFER=2 PRIS_REJECT=130 PATCHED_REJECT=130
MODE=file VIEW=elab  PROCESSED=3174 LISTED=3174 DIFFER=2 PRIS_REJECT=140 PATCHED_REJECT=140
MODE=dir  VIEW=def   PROCESSED=1439 LISTED=1439 DIFFER=4 PRIS_REJECT=114 PATCHED_REJECT=114
MODE=dir  VIEW=elab  PROCESSED=1439 LISTED=1439 DIFFER=4 PRIS_REJECT=119 PATCHED_REJECT=119
```

`PROCESSED == LISTED` everywhere, reject counts symmetric.  The differing arms:

| arm | verdict |
|---|---|
| `r10buvm24repro/g24.sv` | this pass's own grid — the POSITIVE CONTROL (proves the gate can see) |
| `r10buvm22repro/g22.sv` | **12 lines, all PRE-EXISTING and all still wrong on BOTH binaries** — see R-ASSOC |
| `r10uvm75repro`, `r10uvm76repro` (dir mode only) | the PARALLEL-PARSE COIN buvm22/23 recorded; their ORDER-BLIND diff is **0 lines** in both views |

Every bind-window arm named in the brief (buvm3-15, uvm82-91, sd8-12,
§ `classArgBind12`, § `retNameRecvCollapseArgsBindLikeBody15`,
§ `collArgNamedBlkLocalNoBind15`, § `controlBodyNoBind28`,
§ `blkLocalSameCtrlDepthArgBinds57/64`, § `pkgVarBindsOnlyThroughInstance88`,
§ `formalDefaultBindsLikeBody13`, § `classInBodyRecvCallArgNoBind52`,
§ `superNewFormalBinds28`, § `newArrayArgNoBind16`, uvm81's formal contest,
sd10/sd12 `scopedReach`) is byte-identical: none appears in any `differ.txt`.
That includes § `formalDefaultBindsLikeBody13`, whose window this law sits
next to — a formal's default expression is still emitted, and still bound, in
its `io_decl`; only the CALL-SITE copy of it disappears.

## 8. RESIDUES

* **R-ASSOC — `g22.sv`'s associative-array range constants carry a number that
  depends on the BINARY.**  `typedef int ka_str_t[int]` gets, on both binaries,
  a `range` whose right bound is an `operation` over a 8-digit `UINT`
  (`22197601` pristine, `22205793` patched — the delta is exactly 8192, it does
  NOT change when the source is padded, and each binary is deterministic).
  Golden's right bound is a `constant` `STRING:"associative"` `ct 6` with a
  `ref_typespec`, so **both binaries are wrong at that cell and neither is
  closer**; this pass only shifted an address that was already leaking into a
  constant.  It reaches NO corpus database (u2r MOVERS 0, surelog MOVERS
  exactly the nine predicted).  Worth its own pass.
* **R-TS — an io_decl default's own sub-expression carries a `ref_typespec`
  golden has not.**  The grid's `int b = help24(2)` cell: golden's `2` has
  `Typespec` null, ours a `ref_typespec`.  7 grid objects, PRE-EXISTING (a
  strict subset of the pristine surplus), and it is the ONLY judge-visible
  difference left on the whole grid.
* **R-LEAD — the LEADING-slot drop has no corpus cell.**  `f3(,2,3)` is
  implemented and measured on the grid in both views, but no source in either
  corpus writes a leading empty slot (`fence24.py` finds `,,`-middle and
  trailing forms only), so the corpus does not test it.
* **R-NAMEDEMPTY — a NAMED argument written EMPTY (`f(.b())`) was not
  measured.**  `emptyArgSlots24` refuses any list containing a named argument,
  so that shape keeps § `namedTfArgsFormalSlots4`'s behaviour unchanged;
  Surelog's own by-name arm requires an expression sibling and its fall-through
  was not decoded here.  No corpus cell.
* **R-SYS — SYSTEM calls with empty slots (`$past(x,,,clock)`).**  Two surelog
  tests carry them and both are `SLANG_REJECT`, so there is nothing to compare;
  the sys-call arms were deliberately left alone.
* **R-OVERRUN — an empty slot BEYOND the bound argument list.**  If a call
  writes more slots than the callee has formals the bound list is shorter than
  the syntax list and the trailing placeholders are not emitted.  slang rejects
  that source, so it has no cell in either corpus.

## 9. R0 — THE NEXT HEAD

`/tmp/r10buvm24_wd/pat.default.cmp` (56 lines `2>&1`, md5
`8f6d48af61782566449277323fcf2c19`, `grep -c '^LHS:'` = 1, byte-identical
between the two modes):

```
LHS  array_var: (uvm_pkg::uvm_init::idx)  @9847:29-32
       |vpiParent: \_foreach_stmt: (uvm_pkg::uvm_init) @9847:3-10
       |vpiTypespec: \_ref_typespec: (uvm_pkg::uvm_init::idx)
                       |vpiActual: \_array_typespec:            <- UNNAMED
RHS  class_var: (uvm_pkg::uvm_init::idx)  @9847:29-32
       |vpiParent: \_foreach_stmt: (uvm_pkg::uvm_init) @9847:3-10
       |vpiTypespec: \_ref_typespec: (uvm_pkg::uvm_init::idx)
                       |vpiActual: \_class_typespec: (uvm_object_wrapper) @8507:1-19
```

**THE FIELD IS `VpiType` — `BaseClass::Compare`'s FIRST test** (`array_var`
vs `class_var`); the `Typespec` mismatch under it is the same defect one level
down.  Source:

```systemverilog
uvm_object_wrapper uvm_deferred_init[$];            // uvm_pkg.sv:8507
…
foreach(uvm_deferred_init[idx])                     // uvm_pkg.sv:9847
  uvm_deferred_init[idx].initialize();
```

The `foreach` loop variable of a **QUEUE of class handles**: golden makes it an
`array_var` whose typespec is an **unnamed `array_typespec`** — i.e. it types
the loop variable from the ARRAY, not from the element — while we make it a
`class_var` typed by the queue's ELEMENT type `uvm_object_wrapper`.  This is the
loop-variable KIND question § `foreachElabLoopVarAnyKindBinds17` (buvm17) left
open on the BINDING side; the next pass should census every `foreach` loop
variable in the nine UVM databases by (container kind × element kind × view),
calibrate golden-vs-golden first, and decode
`CompileHelper::compileForeachLoop` / the `Loop_vars` construction in Surelog
before touching `StmtEmit`'s foreach arm.

### buvm23's residues, RE-RANKED against this head

| was | now | why |
|---|---|---|
| **R-D** (widen the index gate from "a dot in the bracket" to "the index renders EMPTY": `sq[fidx(i)].len()`) | **still the highest-value hier_path widening**, but it is a `VpiName` residue with no measured corpus head; ranks BELOW R0 | R0 is the live head in the highest-value row |
| **R-A** (an index containing a NESTED bracket) | unchanged, 4 grid + 1 boundary cell | |
| **R-H / R-S / R-T / R-W** | not named in buvm23's README §8 under those letters; its residues are R-A/R-B/R-C/R-D/R-P/R-Q/R-V1/R-V2 and all are unchanged by this pass | the brief's letters do not map onto buvm23's own list — recorded here so the next brief can carry the real ones |
| — | **R-ASSOC** (new, §8) | a binary-dependent number in an assoc-array range; corpus reach 0, but it makes one boundary arm noisy for every future pass |
| — | **R-TS** (new, §8) | the only judge-visible cell left on this pass's grid |

## 10. HOW TO REPRODUCE

```bash
bash build24.sh /tmp/r10buvm24cen                          # the CALL census
python3 fence24.py <sweep workdir> <corpus root>...        # the fence, from SOURCES
bash sweeps24.sh <binary> <workroot> <worktree>            # both corpora, one binary
bash grid24.sh g24.sv <pristine> <patched> <wd> /tmp/r10buvm24cen
python3 gridcmp24.py <wd>/cen.g.txt <wd>/cen.pris.txt <wd>/cen.pat.txt [--ms] [--x] [--show]
python3 cencmp24.py <cen.golden> <cen.ours> [--x]
bash movers24.sh <pris sl wd> <pat sl wd> /tmp/r10buvm24cen <out> BuildUVMPkg MiniAmiq …
PRISTINE=… PATCHED=… ROOT=<a COPY of tools/probe> MODE=file|dir VIEW=def|elab bash bound24.sh
bash canaudit.sh canaries.sh ctcan2.sh
```
