# r10uvm182 — § `builtinArrayReadBindsMintedFuncCall182` — **the SeqDriver head cleared and the family closed corpus-wide**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **no corpus row
converted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `6fee5084` |
| worktree | `/tmp/wt_r10uvm182` |
| pristine binary | md5 `86973e02d6a070958700f9a63ffe3ffe` |
| patched binary | md5 `f565aadff569261cfd5efc04ec223cba` |
| production surface | `src/UhdmExporter.cpp` ONLY — 135 inserted / 1 deleted, of which **41 are code lines**; the rest is the decode written where the code is |
| probe surface | `tools/probe/r10uvm182repro/` only |

## THE HEADLINE

`SeqDriver` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT make
it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing ROWS`
against the committed baselines.  What it does is clear the head r10uvm181 left
as its residue R0, and **close the family corpus-wide**.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), SeqDriver default / testflags | 1 / 1 | 1 / 1 |
| cmp lines, SeqDriver default / testflags | **13 / 13** | **29 / 29** |
| head object | `func_call(max)` < `hier_path(q.max)@1054:12`, `RHS <null>` | `string_var(uvm_pkg::uvm_table_printer::emit::dash)@1040:17` < `begin(…::emit)@1039:3`, `RHS <null>` (**R0**) |
| corpus census, SeqDriver + MiniAmiq × 2 modes, DISAGREE | 42 each | **40 each** |
| byte movers, surelog / uhdm2rtlil | — | **4 / 956** and **0 / 1358**, all four PREDICTED BY NAME |

**The cmp line count goes UP and that is the head OBJECT changing, not a partial
fix** (RESUME.md §7): 29 is the new head's own decompile size, the new head is a
`string_var` in a different family, and the whole-dump attribution below shows
that the ONLY thing this patch writes anywhere in SeqDriver's 1.8 M-line dump is
the two `vpiActual` edges the law is about.  The other ten cmp logs of the
seven-row head set are **byte-identical between the two binaries**.

## 1. THE HEAD, DECODED — **and r10uvm181's `Path_elems` framing is REFUTED**

r10uvm181's R0 (and this pass's brief) recorded the head as a CARDINALITY miss:
*"golden appends a trailing `func_call` (max) element to the `hier_path`; our
`Path_elems` is one short."*  **It is not a cardinality miss and no element is
missing.**  `ct182own.cpp` — the mirror of r10uvm164's owner-finder, scanning
GOLDEN's every edge with the generated, kind-agnostic `GetByVpiType` so no field
is named by hand — lands on ONE edge:

```
HEAD LHS(golden) = func_call(max)@0:0-0:0#190554
HEAD RHS(ours)   = <null>
HEAD LHS parent chain:
    < hier_path(q.max)@1054:12-1054:17#190551
    < assignment()@1054:7-1054:17
    < begin()@1048:4  < begin()@1039:3
    < function(uvm_table_printer::emit)@1036:1
    < package(adpcm_pkg)@10:1          <- the wildcard-import CLONE listing
EDGE SCAN — every edge of GOLDEN that lands on the head, and ours:
  golden ref_obj(max)@1054:14-1054:17#190553
      edge vpiType=700 (singular)                       <- vpiActual
      elems n=2 : ref_obj(q)@1054:12-1054:13  ref_obj(max)@1054:14-1054:17
      ours   ref_obj(max)@1054:14-1054:17#189737 -> singular <null>
      ours   ref_obj(max)@1054:14-1054:17#243642 -> singular <null>
```

`vpiType` 700 is `vpiActual` (`sv_vpi_user.h:172`), so the failing edge is
`ref_obj::Actual_group` through `BaseClass.h`'s **SINGULAR** `SafeCompare`
(`:191-193`, which sets the VALUE as `m_failedLhs` and leaves RHS unset).  Both
sides' `Path_elems` are `n=2` **with byte-identical element faces** — kind, name
and span — so `hier_path::Compare`'s vector `SafeCompare` never fails at all and
the size-mismatch arm that would have named the two `hier_path`s is never
reached.  A pass that went hunting for a missing element would have been looking
for something that is not there.

The four copies of the site, golden and ours, side by side (`ct182cen.cpp`):

| listing | golden `q` | golden `max` | ours `q` | ours `max` |
|---|---|---|---|---|
| `class_defn:uvm_table_printer/package:uvm_pkg` (DEF) | bare | bare | bare | bare |
| `package:uvm_pkg` (the hoisted home) | bare | bare | bare | bare |
| `package:adpcm_pkg` ×2 (the CLONE) | `array_var(q)@1049:11` | **`func_call(max)@0:0`** | `array_var(q)@1049:11` | **bare** |

We already bind the BASE the way golden does (r10uvm181's clone-body law).  The
one thing missing is the trailing element's actual.

## 2. DECODED FROM THE PRODUCER — and the producer is **UHDM**, not Surelog

`uvm-1.2/src/base/uvm_printer.svh:1049-1054`, `uvm_table_printer::emit`:

```systemverilog
begin
   int q[5];  int m;  int qq[$];
   q  = '{m_max_name,m_max_type,m_max_size,m_max_value,100};
   qq = q.max;                     // <- 1054:12
```

`CompileHelper::importPackage` runs `UHDM::clone_tree` over every imported
subroutine listing (`CompileHelper.cpp:317-323`), and `hier_path::DeepClone`
(`~/git-repos/UHDM/templates/clone_tree.cpp:895+`) walks `Path_elems` PAIRWISE,
resolving each element against the PRECEDING one's `Actual_group`.  Four of its
cases — `array_net`, `array_var`, `packed_array_var`, `packed_array_net` —
carry the same five-name block:

```cpp
if (name == "size" || name == "exists" || name == "find" ||
    name == "max"  || name == "min") {
  func_call* call = context->m_serializer->MakeFunc_call();
  call->VpiName(name);
  call->VpiParent(clone);                 // the CLONED hier_path
  if (ref_obj* cro = any_cast<ref_obj*>(current))
    cro->Actual_group(call);
  found = true;  previous = (any*)call;   // "Builtin method"
}
```

The name is not looked up anywhere: the object is **minted**.  It carries
`VpiName` and a parent and NOTHING else — no span, no `Function`, no
`Tf_call_args` — and `func_call::Compare` reads exactly those, so a bare mint is
the whole of it.  `packed_array_net`'s copy of the list writes `exists` TWICE
and therefore has **no `find` row**; that typo is UHDM's and is **MODELLED, not
fixed** (`GOLDEN IS THE SPEC`).

## 3. THE LAW

> **§ builtinArrayReadBindsMintedFuncCall182** — inside a WILDCARD-IMPORT CLONE
> BODY, a `hier_path` element that is a **`ref_obj`**, whose **PREDECESSOR
> element's `vpiActual` is an ARRAY OBJECT** (`array_var`, `packed_array_var`,
> `array_net`, `packed_array_net`), and whose own name is one of **exactly
> `size`, `exists`, `find`, `max`, `min`**, binds its `vpiActual` to a **NEWLY
> MINTED `func_call`** named after the method, parented at the `hier_path`, with
> **no span, no `Function` and no arguments**.  It is not looked up: a body
> LOCAL of that name loses to it, and a struct MEMBER of that name beats it.

### STATED GATE == CODE GATE

**CODE:** `src/UhdmExporter.cpp` only, inside `pkgCloneHierBind9`'s element
loop, as `bindBuiltin182` sitting BETWEEN the two rules already there:

```cpp
if (!prev10 || (!bindMember10(e0, prev10, o9) && !bindBuiltin182(e0, prev10, o9)))
    bind9(e0, o9);
```

after `pkgCloneMember10` (a struct member of the name is `DeepClone`'s LAST
writer and wins — its member scan is in the second switch with no `!found`
guard) and before `bind9` (a body local of the name is not looked up at all and
loses).  The clone-body gate is the SAME `ownerTf9` /`pkgCloneBodyLocals9` pair
`pkgCloneMember10` uses, so the two rules cannot drift apart about what a clone
body is.

### the gates that were REFUTED or CONFIRMED, each on a golden

| candidate gate | verdict, and the cell that says so |
|---|---|
| "the `Path_elems` vector is one short" (the brief, carried from r10uvm181's R0) | **REFUTED** — §1: both sides are `n=2` with identical element faces; the edge is `ref_obj::Actual_group` |
| "the trailing element should be a `func_call` ELEMENT" | **REFUTED** — golden's element is a `ref_obj`; the `func_call` hangs off it as its ACTUAL and is not in `Path_elems` at all |
| "parens do not matter" | **REFUTED** — arm D puts `sluice.size` and `sluice.size()` in ONE function on ONE queue: the bare read's `ref_obj` element takes the mint and the parens-ful read's `method_func_call` element takes **nothing** — golden's whole database holds exactly ONE minted `func_call`, so there is not even an unreferenced orphan to model |
| "a body local of the name wins" | **REFUTED** — arm C cell C3: golden binds the MINT where the pristine binary bound the `int_var(size)@47:9` |
| "the mint always wins" | **REFUTED** — arm C cell C2 (`nook.size`, a queue of a struct that HAS a member `size`): golden binds `typespec_member(size)`, and we already did |
| "any array-TYPED predecessor" | **REFUTED** — arm C cell C4 (`crate.hoard.size`, the queue is a struct MEMBER): the predecessor is a `typespec_member`, `DeepClone`'s typespec_member arm has no mint, golden leaves it BARE |
| "every built-in method" | **REFUTED** — arm A: `sum`, `product`, `num` stay bare beside `max`/`min`/`size` on the same receivers, and `len` on a `string_var` receiver stays bare |
| "the home listing takes it too" | **REFUTED in the DEF view** (arm A, arm C: every home-listing cell bare on both sides) and **CONFIRMED in the ELAB view**, which is the SAME law applied a second time by UHDM's own elaborator — `uhdm_main.cpp` already runs that `ElaboratorContext`, which is why arm A's elab view had golden at exactly TWICE our count in the imported listing and EQUAL in the home |
| "a module body takes it" | **REFUTED** — arm C cell C5: no clone, and golden leaves even the BASE unbound |

## 4. THE ARMS — 4 files, 8 view-runs, **CONVERTED 25 / OVER-FIRE 0 / MOVED-STILL-WRONG 0**

`grid182.sh` builds the golden (Surelog) and BOTH binaries in BOTH views with
every command and every **rc** recorded in `cmds.txt` (an rc=139 segfault must
never read as a result); `score182.py` is the three-way scorer, keyed on the
element's own IDENTITY — span + hier_path name + index/arity + kind + name +
LISTING — because a location-only key collapses a single-file arm into one
bucket and a name-only key cannot separate the home listing's copy of a line
from the clone listing's.

| arm | what it grids | def | elab |
|---|---|---|---|
| `g182_a_methods.sv` | 10 method names × 6 receiver kinds (fixed / queue / dynamic / associative / queue-of-struct / string) in one clone body | CONVERTED **15**, OVER-FIRE 0, MSW 0, RESIDUE 24, SAME 73 | identical |
| `g182_b_ctx.sv` | ONE read in 8 contexts: assignment Rhs, `if` condition, call argument, another expression's INDEX, a binary operand, a for-loop condition, the return expression, and `.max` into a queue | CONVERTED **8**, OVER-FIRE 0, MSW 0, RESIDUE 0, SAME 24 | identical |
| `g182_c_edges.sv` | the five adversarial edges C1–C5 | CONVERTED **1** (C3), OVER-FIRE 0, MSW 0, RESIDUE 0, SAME 19 | CONVERTED 1, SAME 21 |
| `g182_d_parens.sv` | `sluice.size` and `sluice.size()`, same function, same queue | CONVERTED **1**, OVER-FIRE 0, MSW 0, RESIDUE 0, SAME 7 | identical |

Arm A's cells, in full: `max` / `min` / `size` are minted on the fixed, queue,
dynamic, associative and queue-of-struct receivers alike; `sum`, `product`,
`num` and `len` (string) stay BARE beside them; and the package-level-array
control (`bard182_pkgfixed.size`) leaves BOTH elements bare in golden and in
ours, because its base never binds and the law is never reached.

**Arm A's RESIDUE 24 is one pre-existing family and it is NOT this one** (see
R1): three source lines spelling `.xor` and `.unique` parens-less.  Surelog's
grammar recognises `and` / `or` / `xor` / `unique` as `paBuilt_in_method_call`
KEYWORDS even with no argument list, so golden's `hier_path` there is named
after the RECEIVER ALONE and carries a `method_func_call` element, where
§ `parensLessCallIsPathRefObj` gives us a `ref_obj` element and a
`<recv>.<method>` name.  Both binaries produce the identical wrong shape; this
patch does not touch it.

## 5. THE PREDICTION WAS MADE FIRST, FROM PRISTINE BYTES

`ct182pred.cpp` + `predsweep182.sh` read the **956 pristine surelog** and
**1358 pristine uhdm2rtlil** databases and named the movers BEFORE the patched
sweeps existed.  The pristine signature is the law's own shape minus the one
gate bytes cannot see (whether the owning subroutine is a clone body), so it is
an UPPER BOUND:

```
-- databases scanned=956   databases with candidates=4
CANDIDATES 2  …/default/MiniAmiq-544c7f61/slang.uhdm      CAND q.max 1054:14 max  (x2)
CANDIDATES 2  …/default/SeqDriver-32af76aa/slang.uhdm     CAND q.max 1054:14 max  (x2)
CANDIDATES 2  …/testflags/MiniAmiq-544c7f61/slang.uhdm
CANDIDATES 2  …/testflags/SeqDriver-32af76aa/slang.uhdm
-- databases scanned=1358  databases with candidates=0    (uhdm2rtlil)
```

`byteverify.sh` returned **exactly those 4 movers / 956** on surelog and
**0 / 1358** on uhdm2rtlil, with `SELFCHECK` 955/956 and 1357/1358.  No mover
was unpredicted and no prediction failed to move.

**Attribution** (`uhdm-dump` both sides, workdir path normalised,
SeqDriver/default): **0 deletions, 12 insertions**, and every one of them is
this law:

```
> |vpiActual:                          (x2, inline, at the two adpcm_pkg copies)
> \_func_call: (max)
> \_func_call: (max)                   (x2, the whole-object tail, 4 lines each)
>   |vpiParent:  \_hier_path: (q.max), line:1054:12, endln:1054:17
>   |vpiName:max
```

Nothing else in 1 816 399 dump lines moved.  This is r10v181's object-population
law read the other way: a filled edge here LENGTHENS the dump by the object it
now reaches.

**MiniAmiq's bytes moved and its cmp log did NOT** — `26 / 1 head` before and
after, byte-identical — because this law fires BELOW MiniAmiq's own head (the
unassigned unsupported-typespec head, r10uvm183's).  Said out loud rather than
counted as a win.

## 6. THE CORPUS CENSUS (`ct182cen.cpp` + `cenjoin182.py` + `cenall182.sh`)

Every `hier_path` ELEMENT's `vpiActual`, golden against ours, over the UVM row
set × both modes.  **CALIBRATION FIRST, golden against golden**
(SeqDriver/default): `AGREE 27957 / DISAGREE 0 / MISSING 0 / EXTRA 0`.

| row / mode | AGREE pris → pat | DISAGREE pris → pat | MISSING-OURS | EXTRA-OURS |
|---|---|---|---|---|
| SeqDriver default & testflags | 24 943 → **24 945** | 42 → **40** | 2 972 (unchanged) | 2 505 (unchanged) |
| MiniAmiq default & testflags | 25 491 → **25 493** | 42 → **40** | 2 996 (unchanged) | 2 527 (unchanged) |
| BuildUVMPkg ×2, Scoreboard, SimpleUVM ×2 | unchanged | 0 → 0 | unchanged | unchanged |

**−2 DISAGREE / +2 AGREE per moved database, every other class frozen, and the
one-sided sets untouched.**  The family view names the converted key and nothing
else:

```
-  ONLY-GOLDEN x2 1054:14-1054:17|q.max|1/2|ref_obj|max|IN=package:adpcm_pkg   => ACT=func_call(max)@0:0
-  ONLY-OURS   x2 1054:14-1054:17|q.max|1/2|ref_obj|max|IN=package:adpcm_pkg   => ACT=-
```

(MiniAmiq's clone listing is `svaunit_pkg`; the same two rows.)  Every OTHER
family row that still disagrees is a SPAN difference on `this.size` /
`<recv>.size()` — r10uvm84/85's `this.`/`super.` family and the method-call span
family — and is untouched here.

### the census's own measured trap

The first cut keyed on the FILE as well and reported
`AGREE 8246 / DISAGREE 0 / MISSING 19711 / EXTRA 19647` on a pair that agrees
about almost everything.  **Our `hier_path`s carry an EMPTY `VpiFile`**
(buvm14 §7's trap), so `ct182cen` inherits one from the nearest ancestor that
has one — and the two producers' nearest ancestors are different objects
(golden's SeqDriver key reads `uvm_printer.svh`, ours `testbench.sv`).  No
generated `Compare` reads `VpiFile` at all, so the file is now OUT of the key
and the span, the names and the LISTING carry it.  The DEF/ELAB view is out of
the key too, for buvm14's reason; the LISTING (`package:uvm_pkg` vs
`package:adpcm_pkg`) is IN it, because that is real structure the judge reaches
through two different package objects.

## 7. THE GATES, EACH IN ONE LINE

1. **Builds.** pristine `86973e02d6a070958700f9a63ffe3ffe`, patched
   `f565aadff569261cfd5efc04ec223cba`, `-j 2`, md5 taken separately, both frozen
   `chmod 555` at `/tmp/r10uvm182_bin/` BEFORE any sweep.
2. **Goldens.** patched **23 PASS / 0 FAIL**, pristine **23 / 0**,
   `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (`SLANG_UHDM` exported
   explicitly to each binary).
3. **uhdm2rtlil.** `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in both
   modes on both binaries.  `ct8rows` **0 differing ROWS** — testflags against
   the committed `results/gate_uhdm2rtlil.csv` AND against my own pristine
   sweep, and default against my own pristine sweep.  Every `cmds.txt` audited
   by BINARY PATH: 1458/1458 lines name `/tmp/r10uvm182_bin/pat.bin`.
4. **surelog.** default `471+283+25+10+5`, testflags `466+284+23+9+5+3+2+1+1`,
   identical on both binaries; `ct8rows` **0 differing ROWS over 1588** against
   the committed `results/golden_surelog.csv` AND against my own pristine sweep.
   **NO ROW CONVERTED**; nothing promoted; `results/*.csv` never written.  Every
   `cmds.txt` audited: 1523/1523 name `/tmp/r10uvm182_bin/pat.bin` (and the
   pristine pair 2981/2981 name `pris.bin`).
5. **Bytes.** surelog **4 / 956**, all four PREDICTED BY NAME from pristine
   bytes; uhdm2rtlil **0 / 1358**; `SELFCHECK` 955/956 and 1357/1358.
6. **Canaries.** `canaries.sh` surelog **ok=52 changed=0 absent=0**, u2r
   **ok=8 changed=0 absent=0**; `ctcan2.sh` **ok=58 changed=0** (surelog,
   `EXPECT_UNKNOWN=1`, PASS) and **ok=1 changed=0** (u2r, `EXPECT_UNKNOWN=6`,
   PASS); `canaudit.sh canaries.sh ctcan2.sh` **audited=29 UNCOVERED=0
   FENCE-BREACH=0**, and all four slang-fenced names report "not dispatched by
   any driver".
7. **Pins**, patched against pristine, by name and by md5:
   `InterfaceModPort 59a365f3ce2c` (both modes), `BlackParrotComplex e3e354129d5a`
   / `73a10e8217e5`, `YosysOldOr d68e0796d62c`, **`SVSwitch 4842211c4030`**,
   **`YosysVerx 6ccda350c24a`** — every one SAME.
8. **The seven-row head set.** heads `1 -> 1` everywhere; **ten of the twelve
   cmp logs byte-identical between the two binaries**; only SeqDriver's two
   moved, `13 -> 29`, and its two modes are byte-identical to each other on both
   binaries.  `SimpleUVM` 664681, `Scoreboard` 95, `MiniAmiq` 26,
   `BuildUVMPkg` 52, `Earlgrey_0_1` 31 / 364, `Rggen` 0 — all unchanged.
9. **The WIDE BOUNDARY GATE.** `bound182.sh` over every `.sv`/`.v` found
   anywhere under a COPY of `tools/probe/` (subdirectories included; the list
   travels on fd 3 and every child gets `</dev/null`; PROCESSED asserted
   against LISTED): **LISTED=4988 FENCED_SKIPPED=0 PROCESSED=4988 MOVED=8
   NO_OUTPUT_PAIRS=380, PROCESSED-ASSERT-OK**.  The 8 MOVED are this pass's own
   four arm sources × two views and NOTHING ELSE — buvm14's `a1_dims14`,
   uvm89's `a1`/`a2` and the fenced `v81h_lvbase`, uvm181's `g181_a..d`,
   uvm84/85's, uvm77-79's and the sd8-12 SUBDIRECTORY arms are all
   byte-identical between the two binaries in both views.  **The must-stay
   floor stayed: AWAY-GOLDEN 0, MOVED-STILL-WRONG 0 on every earlier arm,
   trivially, because none of them moved at all.**
10. **The corpus census** of §6, calibrated golden-vs-golden first.

## 8. RESIDUES, each measured and left deliberately

* **R0 — THE NEW HEAD.**  SeqDriver ×2, 29 cmp lines, one head:
  ```
  LHS golden  string_var(uvm_pkg::uvm_table_printer::emit::dash) @1040:17-1040:21
              < begin(uvm_pkg::uvm_table_printer::emit) @1039:3-1039:22
              vpiTypespec -> ref_typespec -> string_typespec @1040:10-1040:16
  RHS         <null>
  ```
  `uvm_printer.svh:1040` is `static string dash;` **inside** the `begin` block
  of `uvm_table_printer::emit` (which opens at 1039:3).  Golden LISTS the
  function-local STATIC as a variable of that `begin`; we list it somewhere else
  or not at all, so `BaseClass.h`'s SINGULAR `SafeCompare` names golden's value
  with `RHS: <null>`.  A **function-local-static LISTING** question — neither
  this family, nor MiniAmiq's unsupported-typespec head (26 lines, r10uvm183),
  nor earl112's genvar-rendering-context head.  Decode it with `ct182own.cpp`
  before naming a field.
* **R1 — the parens-less KEYWORD built-ins `and` / `or` / `xor` / `unique`.**
  Surelog's grammar reaches `paBuilt_in_method_call` for those four names with
  no argument list at all (`CompileExpression.cpp:5620-5634` renames
  `paAnd_call` / `paOr_call` / `paXor_call` / `paUnique_call`), so golden's
  `hier_path` is named after the RECEIVER ALONE and its trailing element is a
  `method_func_call`; § `parensLessCallIsPathRefObj` gives us a `ref_obj`
  element and a `<recv>.<method>` name.  **24 arm-A cells, both binaries
  identical, untouched.**  A name-and-kind pass of its own, and note that it
  would then MEET this law: a `method_func_call` element takes NO mint (arm D).
* **R2 — `exists` and `find` have no measured corpus cell.**  Both need an
  argument list, so the written form is parens-ful, so the element is a
  `method_func_call` and the mint never fires; the two names are implemented
  because `DeepClone`'s list carries them and a parens-less spelling would be
  legal for neither.  The corpus census confirms zero occurrences: the only
  candidates anywhere in 2314 pristine databases are the four `q.max` sites.
* **R3 — `packed_array_var` / `array_net` / `packed_array_net` predecessors are
  implemented and UNREACHED.**  `DeepClone` lists all four kinds; only
  `array_var` has a measured cell (arm A gives it five receiver spellings), and
  the predictor found no candidate of any other kind in either corpus.  They are
  in the code so the law and its producer say the same thing, with
  `packed_array_net`'s missing `find` row modelled exactly.
* **R4 — the ORPHAN mint is not modelled, and it does not exist.**  `DeepClone`
  writes `MakeFunc_call()` BEFORE it tests the element's kind, so reading the
  code alone predicts an unreferenced `func_call` for a parens-ful
  `<array>.size()` in a clone body.  Arm D measures that face directly, on one
  golden, in one function, on one queue: golden's database holds **exactly one**
  minted `func_call`, the bare read's.  No orphan is emitted here either.  Were
  one to exist it would be compare-invisible anyway (no `Compare` edge reaches
  it), but the arm means that is not the reason.

## 9. REPRODUCING

```sh
g++ -O2 -std=c++17 ct182own.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct182own
g++ -O2 -std=c++17 ct182cen.cpp  -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct182cen
g++ -O2 -std=c++17 ct182pred.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct182pred

./ct182own  <golden.uhdm> <ours.uhdm> [hp-name-substr]   # the head's owner + edge
./ct182cen  <db.uhdm>                                    # one row per hier_path element
./predsweep182.sh <PRISTINE workdir> <out.txt>           # movers, from PRISTINE bytes
./cenall182.sh    <workdir> <outdir> SeqDriver MiniAmiq BuildUVMPkg Scoreboard SimpleUVM
python3 cenjoin182.py <g.cen> <o.cen> [--fam]
./grid182.sh g182_a_methods.sv <pris.bin> <pat.bin> <workdir> ./ct182cen
python3 score182.py <g.cen> <pris.cen> <pat.cen>
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ../r10oth4repro/byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                 BuildUVMPkg Earlgrey_0_1 Rggen
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=/tmp/r10uvm182_bound ./bound182.sh
bash canaudit.sh canaries.sh ctcan2.sh
```
