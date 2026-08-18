# r10buvm23 — § `dottedIdxRecvFromSyntax23` — **a `.` INSIDE A SUBSCRIPT IS NOT A PATH SEPARATOR: a method-call receiver whose index expression contains a dot is built from the SYNTAX, and the index text its hier_path NAME carries is `decompileHelper`'s — EMPTY for a `hier_path` or a call**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `f969774` |
| worktree | `/tmp/wt_r10buvm23` |
| pristine binary | md5 `c140b82036818ac7f5ca2058b47ca85b` — reproduced the main tree's pin byte for byte — frozen `chmod 555` at `/tmp/r10buvm23_bin/pristine.bin` |
| refactor-only NULL CONTROL | md5 `5c3a404350259e18c575f1b0d45ea3bf`, `/tmp/r10buvm23_bin/refac.bin` |
| patched binary | md5 `a4d7b6498629dd0a043012fea0a49356`, `/tmp/r10buvm23_bin/pat.bin` |
| production surface | `include/UhdmExporter.h` (3 declarations), `src/ExprEmit.cpp` (the gate, two extracted members, and four gated arms) |
| probe surface | `tools/probe/r10buvm23repro/` only |
| deliverable | `/tmp/r10buvm23.patch`, applies clean on a FRESH `f969774` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass** — and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines in both corpora and both modes.  What it
does is clear buvm22's R0 and retire the text-splitter's whole fossil family.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **166 / 166** | **32 / 32** |
| `BuildUVMPkg` cmp md5 (`2>&1`), both modes | `b0d8ba9e85acfcdb4650c0743e17352e` (buvm22's pin, hit exactly) | `070cefa7005899f934be8d9900f37744` |
| head object | `hier_path (m_streams[].exists)` vs `(m_streams[ro.get_name()].exists)` | a `constant` `INT:0` vs `UINT:0` at `uvm_pkg.sv:30186` (**R0**) |
| `hier_path` census, `BuildUVMPkg`, JUDGE-VISIBLE payload | SAME 7 631 · **DIFF 15** · GOLDEN-ONLY 96 · OURS-ONLY 97 | SAME 7 645 · **DIFF 8** · GOLDEN-ONLY 89 · OURS-ONLY 97 |
| text-split FOSSILS (a non-`hier_path` object whose `VpiName` carries a bracket or a paren) | **18** | **4** — and those 4 are a pre-existing `indexed_part_select` family, not a split |
| the golden GRID `g23.sv`, judge-visible | — | **FIXED 123, BROKEN 0**, still-wrong 17, still-right 33 (173 cells) |
| the golden GRID `g23.sv`, incl. `VpiFullName` | — | **FIXED 104, BROKEN 0**, still-wrong 39, still-right 30 |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG — AND buvm22's DECODE CORRECTED

`/tmp/r10buvm23_wd/pris.default.cmp` (166 lines `2>&1`, 83 on stderr, md5
`b0d8ba9e85acfcdb4650c0743e17352e`, `grep -c '^LHS:'` = 1, byte-identical
between the two modes):

```
LHS  hier_path: (m_streams[].exists)                @30163:48-94
       |vpiActual: \_bit_select: (m_streams[])        @30163:48-57
                     |vpiName:m_streams  |vpiFullName:m_streams[]
                     |vpiIndex: \_hier_path: (ro.get_name)   @30163:58-60
                                  ref_obj (ro) · method_func_call (get_name)
       |vpiActual: \_method_func_call: (exists)       @30163:73-79
                     |vpiArgument: \_hier_path: (rh.get_name)
       |vpiName:m_streams[].exists
RHS  hier_path: (m_streams[ro.get_name()].exists)   @30163:48-94
       |vpiActual: \_ref_obj: (m_streams[ro)          @30163:48-60
       |vpiActual: \_ref_obj: (get_name()])           @30163:61-72
       |vpiActual: \_method_func_call: (exists)       @30163:73-79   <- already agreed
       |vpiName:m_streams[ro.get_name()].exists
```

**THE FIELD IS `VpiName`, NOT `Path_elems` — buvm22's README (and the brief
carried forward from it) name the wrong one, and the generated source settles
it.**  `hier_path::Compare`
(`~/git-repos/UHDM/build/generated/src/hier_path.cpp:110`) is

```cpp
if ((r = basetype_t::Compare(other, context)) != 0) return r;      // <- FIRST
if ((r = SafeCompare(lhs, lhs->Path_elems(), rhs, rhs->Path_elems(), context))) return r;
if ((r = SafeCompare(lhs->Root_value(), rhs->Root_value(), context))) return r;
if ((r = lhs->VpiName().compare(rhs->VpiName())) != 0) { … }
```

and `basetype_t` is `expr` → `BaseClass`, whose `Compare` tests **`VpiType`,
then `VpiName`, then `VpiDefName`** before `expr::Compare` even reads
`VpiDecompile` / `VpiSize` / `Typespec`.  Both names are non-empty and differ,
so the walk stops at `BaseClass::Compare`'s `VpiName` and `Path_elems` is never
reached.  The two decodes are indistinguishable in the LOG — the vector overload
names both CONTAINERS on a size mismatch and the singular `VpiName` arm names
the same two objects — which is exactly why RESUME §9 says to read the generated
`Compare` rather than trust a carried-forward framing.  It matters here in one
concrete way: **the NAME alone would have cleared this head**, and a fix that
only rewrote the text would have left the 2-vs-3 `Path_elems` mismatch to
surface as the next head.  This pass fixes both, because both are the same
defect.

Source, `1800.2-2017-1.0/pp_output/uvm_pkg.sv:30163`, inside
`uvm_default_report_server::execute_report_message`; `m_streams` is declared at
`:29792` as `protected uvm_tr_stream m_streams[string][string];` (an
assoc-of-assoc keyed by string — **not** the
`uvm_report_message_element_container` the brief names):

```systemverilog
if (m_streams.exists(ro.get_name()) && (m_streams[ro.get_name()].exists(rh.get_name())))
  stream = m_streams[ro.get_name()][rh.get_name()];
```

**THE OWNER, and WHICH COPIES.**  The head object is the `vpiCondition`
operand of the `if_stmt` in `execute_report_message`, in the **ELABPKG** listing
only (the census reports it in no other view; that method's body is carried by
one copy).  Its sibling sites at `:40585` / `:40594` (in
`uvm_component::free_tr_stream`) carry the SAME defect in **both** DEFPKG and
ELABPKG — 5 judge-visible rows in all.

**THE SECOND SITE THE BRIEF ASKED ABOUT — `:30164` — IS NOT THIS DEFECT.**
`stream = m_streams[ro.get_name()][rh.get_name()];` is a plain select chain, not
a method-call receiver, and it goes through the PLAIN path builder, which has
been syntax-driven all along: golden and we both emit a `var_select` whose two
`Exprs` are the nested `hier_path`s `ro.get_name` / `rh.get_name`, byte for
byte, on the pristine binary.  So does `:30182` and so does `:40589`.  The
defect is confined to the **method-call receiver** builders, which are the only
ones that tokenise SOURCE TEXT.

## 2. THE LAW

> **§ `dottedIdxRecvFromSyntax23`** — when a method-call RECEIVER PATH's written
> text puts a `.` INSIDE A BRACKET PAIR, that dot is **not** a path separator:
>
> * the path COMPONENTS are the AST's member-access / element-select chain, so
>   `m_streams[ro.get_name()]` is ONE component — a `bit_select` named for the
>   BASE, with the index expression emitted as an expression and hung off it —
>   and never two `ref_obj`s named `m_streams[ro` and `get_name()]`;
> * the index text that component contributes to the hier_path **NAME** is
>   `CompileHelper::decompileHelper` applied to the index OBJECT, which has **no
>   row for a `hier_path` and no row for a `func_call` / `method_func_call`** and
>   therefore renders the EMPTY STRING while the brackets the composer adds
>   survive: golden's `m_streams[].exists`;
> * in STATEMENT position the same receiver's `vpiPrefix` is the **BASE NAME**
>   with the subscript dropped (`m_streams`, spanned to the `[`), the call is
>   named after the METHOD, and it KEEPS its own arguments.
>
> The gate is the bracket, and only the bracket: a `.` inside PARENTHESES is
> deliberately out (residue R-P), and every receiver with no dot inside a
> subscript emits BYTE FOR BYTE as before, by construction.

## 3. DECODED FROM SURELOG (`~/git-repos/Surelog`), NOT INFERRED

Two producers, both already decoded by earlier passes and both re-read here:

* **the composer** — `CompileExpression.cpp:5586`'s `while (BitSelect)` loop
  (quoted verbatim at § `builtinRecvMultiDimStepIsBitSelectChain14`'s header in
  `src/ExprEmit.cpp`) appends `"[" + decompileHelper(index) + "]"` per written
  dimension.  **The brackets are unconditional; only their CONTENTS come from
  the dispatch.**  Hence `m_streams[]` and not `m_streams`.
* **the dispatch** — `CompileHelper::decompileHelper` (`CompileHelper.cpp:2544`),
  uvm79/89's FIRST closed dispatch, with **no `else`**: `constant` →
  `VpiDecompile`, `ref_obj` → `VpiName`, `operation` → `ExprEval::prettyPrint`
  (uvm92's SECOND closed dispatch), the SELECT kinds → their own bracket text,
  **everything else → `""`**.  A method call on a handle (`ro.get_name()`) is a
  UHDM `hier_path`; a free call (`sf23(hh.nm)`) is a `func_call`; neither has a
  row.

This emitter already carried a transcription of that dispatch — § `hpMidSelIdxDecompiled79`'s
`idxDecompile79` MID arm, inside the PLAIN path builder.  It is now
`UhdmExporter::hpCompIdxDecompile23`, moved VERBATIM, and the receiver builders
call it, so the two sites cannot drift.  `idxText34` moved out of the same
lambda as `UhdmExporter::hpIdxText34` for the same reason.  **The move was
proved behaviour-neutral before any law was added**: the refactor-only binary
(`refac.bin`) produces a `BuildUVMPkg` database byte-identical to the pristine
one (`9c00ac1c5053b774278101b71acc023f`) and passes the golden suite 23/0.

## 4. THE GOLDEN GRID — 173 SCORED CELLS, BOTH VIEWS

`g23.sv` is compiled by Surelog with and without `-elabuhdm` and by both
binaries with and without `--elabuhdm`; `gridcmp23.py` scores every
`(listing, view, owner, loc)` cell three ways as a MULTISET (so a change in
MULTIPLICITY cannot hide).

```
$ bash grid23.sh g23.sv <pristine> <patched> <wd> <cen>
$ python3 gridcmp23.py <wd>/cen.g.txt <wd>/cen.pris.txt <wd>/cen.pat.txt
CELLS 173   FIXED 123  BROKEN 0  STILL-WRONG 17  STILL-RIGHT 33
$ python3 gridcmp23.py … --full          # adds VpiFullName, which no Compare reads
CELLS 173   FIXED 104  BROKEN 0  STILL-WRONG 39  STILL-RIGHT 30
```

**BROKEN 0** under both payloads is the load-bearing number.

### 4.1 GOLDEN's answer, read off the two Surelog runs — THE INDEX AXIS

| index expression | golden hier_path NAME | ours, patched |
|---|---|---|
| `q2[hh.f()]` — method call on a handle | `q2[].size` | **FIXED** |
| `q2[hh.nm]` — member access | `q2[].size` | **FIXED** |
| `q2[sf23(hh.nm)]` — a CALL with dotted arguments | `q2[].size` | **FIXED** |
| `q2["x.y"]` — a STRING LITERAL containing a dot | `q2["x.y"].size` — **KEPT** (`constant` → `VpiDecompile`) | **FIXED** |
| `q2[{hh.nm, "z"}]` — concatenation | `q2[{,"z"}].size` — operator kept, dotted operand EMPTY | **FIXED** |
| `q2[c ? hh.nm : "z"]` — ternary | `q2[c ?  : "z"].size` — same asymmetry | **FIXED** |
| `q2[hh.a23[i]]` — a select THROUGH a member | `q2[].size` | still wrong (**R-A**) |
| `q2[skeys[i + hh.ix]]` — a NESTED select | `q2[[i + ]].size` | still wrong (**R-A**) |
| `q2[skeys[i]]` — a nested select with NO dot | `q2[[i]].size` | unchanged, gate OFF (**R-B**) |

The literal row is the one that proves the model rather than the patch: the gate
FIRES on `"x.y"` (there is a dot inside the bracket) and the answer is still
byte-right, because what decides is the DISPATCH on the index OBJECT and a
string literal is a `constant`.

### 4.2 The other axes, all FIXED, both views

* **trailing** `.exists(k)` · `.size()` · `.num()` · a further index `[k]` · a
  MEMBER (`hq[hh.f()].nm`) · a USER method (`hq[hh.f()].f()`) · PARENS-LESS
  (`q2[hh.f()].size`) · a deeper path (`hq[hh.f()].a23[i].len()`);
* **position** if-condition · assignment Rhs · statement · `void'(…)` statement ·
  (call ARGUMENT is R-C, below);
* **home** class in-body · class OUT-OF-BODY · package function · module
  function · module `initial`;
* **container** `[string]` · `[int]` · `[$]` · `[]` · `[4]` — all identical, as
  § `builtinRecvIndexedStepIsBitSelect74` already found;
* **STATEMENT position** `q2[hh.f()].delete(hh.f())` and `.delete()`: golden's
  call is named `delete`, prefix `ref_obj (q2)` scope-joined and spanned to the
  `[`, argument kept — and the patched emitter is **byte-identical to golden**
  at the corpus twin `uvm_pkg.sv:40593` (whole 26-line block, ids stripped).

## 5. THE FENCE, ENUMERATED FROM THE DATABASES BEFORE THE CODE

`PREDICTION.txt` (written before the patched sweep existed) and `fence23.sh`.
The population this law can reach is `dotInBracket23`, and every member of it
leaves a fossil in the PRISTINE database, so it is ENUMERABLE rather than
guessed:

| corpus | scanned | DOTIDX rows / DBs | predicted movers |
|---|---|---|---|
| `uhdm2rtlil` | 1 358 | **0 / 0** | **NONE** |
| `surelog` | 956 | 87 / **9** | those **9**, by name |

> `default/BuildUVMPkg` `testflags/BuildUVMPkg` `default/MiniAmiq`
> `testflags/MiniAmiq` `default/SeqDriver` `testflags/SeqDriver`
> `default/SimpleUVM` `testflags/SimpleUVM` `default/Scoreboard`
> (Scoreboard's testflags row is `SLANG_REJECT`)

all nine already `CMP_NOTEQUAL`, so **no CMP_EQUAL row is inside the fence at
all** — the u2r corpus has not one receiver with a dot in a subscript, and the
surelog corpus has them only in the five UVM rows.  The four source shapes
behind all 87 rows are `m_streams[<h>.get_name()].exists(...)` /
`.size()` / `.delete(...)` and `m_children[child.get_name()].get_type_name()`.

## 6. THE GATES

All run from this worktree with `SLANG_UHDM` exported explicitly per binary and
every `cmds.txt` audited by binary PATH (2 981 lines per sweep, one path each).

| gate | result |
|---|---|
| (1) build both, md5 | pristine `c140b82036818ac7f5ca2058b47ca85b` (= main tree), patched `a4d7b6498629dd0a043012fea0a49356`, 0 errors |
| (2) goldens | patched `PASS=23 FAIL=0`; negative control `SLANG_UHDM=/bin/false` → `FAIL=23 PASS=0`; pristine `PASS=23 FAIL=0` |
| (3) `uhdm2rtlil` | `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL` in BOTH modes; `ct8rows` **0 differing rows** vs the committed `results/gate_uhdm2rtlil.csv` AND vs this pass's own pristine sweep, status AND dump, both modes |
| (4) `surelog --mode both` | `936 CMP_EQUAL / 20 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 1 NO_UHDM / 567 SLANG_REJECT / 48 SURELOG_FAIL / 1 TIMEOUT / 2 UNTRANSLATABLE` — identical to the pristine sweep; `ct8rows` **0 differing rows over the 1 588** against BOTH the committed `results/golden_surelog.csv` and the pristine sweep.  **NO ROW CONVERTED**; nothing promoted |
| (5) byteverify | `uhdm2rtlil` **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL, SELFCHECK 1357/1358; `surelog` **MOVERS 9 / 956 — exactly the nine §5 predicted by name** |
| canaries | `ok=52 changed=0` (surelog), `ok=8 changed=0` (u2r); `ctcan2` PASS with `EXPECT_UNKNOWN=1` / `6`; `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0` |

### Protected databases (md5, pristine vs patched)

| DB | verdict |
|---|---|
| `InterfaceModPort` (both modes) | SAME `59a365f3ce2c` |
| `BlackParrotComplex` | SAME `e3e354129d5a` / `73a10e8217e5` |
| `YosysOldOr` (both modes) | SAME `d68e0796d62c` |
| `SVSwitch` (both modes) | SAME **`4842211c4030`** — the brief's pin, hit |
| `YosysVerx` (both modes) | SAME **`6ccda350c24a`** — the brief's pin, hit |

### The nine movers, each ATTRIBUTED and each SCORED against golden

Every mover was attributed by an ORDER-BLIND, path-normalised `uhdm-dump` diff
(both dumps `sort`ed, ids stripped) and then scored cell-by-cell against its own
golden by the same three-way census the grid uses:

| database | hier_path cells | FIXED | **BROKEN** | still-wrong | still-right |
|---|---|---|---|---|---|
| `BuildUVMPkg` ×2 | 7 696 | 14 | **0** | 158 | 7 524 |
| `MiniAmiq` ×2 | 14 504 | 22 | **0** | 1 756 | 12 726 |
| `SeqDriver` ×2 | 14 217 | 22 | **0** | 1 729 | 12 466 |
| `SimpleUVM` ×2 | 8 165 | 12 | **0** | 963 | 7 190 |
| `Scoreboard` (default) | 8 194 | 12 | **0** | 969 | 7 213 |

**152 cells moved TO GOLDEN, 0 away, across the nine.**  The order-blind diff
carries NO collateral: for `BuildUVMPkg` the only lines outside this law's own
objects are the dump's own path banner, and for `MiniAmiq` the extra lines are
the § `hpIdxOpPrettyPrint92` fullname twins below plus six `io_decl (stream)`
printings that take our count from **63 to 69 — exactly golden's 69**.

## 7. THE BOUNDARY GATE

From a COPY of the WHOLE `tools/probe` tree (`/tmp/r10buvm23_probecopy`), **no
path filter**, `.sv` AND `.v`, per-FILE and per-DIRECTORY, in BOTH views.

```
MODE=file VIEW=def   PROCESSED=3126 LISTED=3126 DIFFER=6 PRIS_REJECT=130 PATCHED_REJECT=130
```

`PROCESSED == LISTED`, reject counts symmetric (no `asym.txt`).  All six
differing arms were REBUILT AGAINST GOLDEN and scored:

| arm | judge-visible | incl. VpiFullName | what moved |
|---|---|---|---|
| `r10buvm23repro/g23.sv` | this pass's own grid — the POSITIVE CONTROL (proves the gate can see) | | |
| `r10uvm74repro/v74_edge.sv` | **FIXED 2, BROKEN 0** | FIXED 1, BROKEN 0 | `sq[ih.k].len()` → golden's `sq[].len` with a `bit_select` and a `hier_path` index |
| `r10buvm14repro/a1_dims14.sv` | FIXED 0, **BROKEN 0**, still-wrong 3 | — | `m1[hh.s1[a]].size()` — a NESTED bracket inside the index (R-A): 3 bogus elements → 2, so the element COUNT now matches golden, the kind does not |
| `r10uvm92repro/g92_a3_recv.sv` | FIXED 0, **BROKEN 0** | **FIXED 2**, BROKEN 0 | `items[items.size()-1]` / `items[i+md.one.fld]` bit_select FULLNAMES follow the NAME § `hpIdxOpPrettyPrint92` already gave: `items[ - 1]`, `items[i + ]` |
| `r10uvm92repro/v92_b1_break.sv` | FIXED 0, **BROKEN 0** | **FIXED 1**, BROKEN 0 | `list[k + mm.one.fld]` → `list[k + ]` |
| `r10uvm92repro/v92_b3_recv.sv` | FIXED 0, **BROKEN 0** | **FIXED 3**, BROKEN 0 | `pool[u + tp.md.q]` → `pool[u + ]`, `pool[u ? tp.md.q : v]` → `pool[u ?  : v]` |

The uvm92 arms are the model's own consistency proof: on five operation-index
cells the NEW dispatch reproduces § `hpIdxOpPrettyPrint92`'s rendering
CHARACTER FOR CHARACTER (the hier_path NAMES are byte-unchanged; only the
`bit_select` fullnames, which lagged behind them, moved — and they moved to
golden).  Every bind-window arm in the tree (buvm13/15/16, uvm88/90, sd8-12,
§ `classArgBind12`, § `controlBodyNoBind28`,
§ `blkLocalSameCtrlDepthArgBinds57/64`, § `pkgVarBindsOnlyThroughInstance88`,
§ `formalDefaultBindsLikeBody13`, § `classInBodyRecvCallArgNoBind52`,
§ `superNewFormalBinds28`, § `newArrayArgNoBind16`, uvm81's formal contest,
sd10/sd12 `scopedReach`) is byte-identical: none of them appears in
`differ.txt`.

```
MODE=file VIEW=elab  PROCESSED=3126 LISTED=3126 DIFFER=6 PRIS_REJECT=140 PATCHED_REJECT=140   (the SAME six)
MODE=dir  VIEW=def   PROCESSED=1434 LISTED=1434 DIFFER=6 PRIS_REJECT=114 PATCHED_REJECT=114
MODE=dir  VIEW=elab  PROCESSED=1434 LISTED=1434 DIFFER=5 PRIS_REJECT=119 PATCHED_REJECT=119
```

The dir-mode runs add `r10uvm75repro` and `r10uvm76repro`, which are the
PARALLEL-PARSE COIN buvm22 recorded (the pristine binary alone yields different
dumps run to run): their ORDER-BLIND diff is **0 lines** in both views.
`r10uvm92repro` does not differ in the `elab` dir view.

## 8. RESIDUES

* **R-A — an index that itself contains a NESTED BRACKET.**  `q2[hh.a23[i]]`,
  `q2[skeys[i + hh.ix]]`, `m1[hh.s1[a]]` (buvm14's own arm).  `stepIdxGroups14`
  REFUSES a step whose bracket groups do not tile it with no nesting, so the
  whole receiver falls back to ONE flat `ref_obj`.  Golden wants a `bit_select`
  with a `hier_path` index and the name `q2[].size` / `qn[[i]].size`.  The gate
  still helps — the element COUNT goes 3 → 2 and the bogus fossil names are
  gone — but the KIND and the name text stay wrong.  4 grid cells + 1 boundary
  arm.  The fix is in `stepIdxGroups14`/`builtinRecvStepSelectors74`, whose
  refusal rule is text-based; the tree already has the answer.
* **R-B — a nested-select index with NO dot** (`q2[skeys[i]]`, `qn[idxarr[i]]`):
  golden `q2[[i]].size` (decompileHelper's own bit_select row, which emits its
  brackets for a ref_obj index), ours the raw text.  The gate is OFF here, so
  this is PRE-EXISTING and byte-unchanged; it is R-A's twin one level up.
* **R-C — a receiver rooted in a CALL** (`sf23($sformatf(…, q2[hh.f()].size()))`
  as a `.len()` receiver): golden emits no hier_path at that site at all.  The
  gate fires (the inner `hh.f()` is inside a bracket) and the element count goes
  4 → 3, but the family is a different one.  2 grid cells.
* **R-D — THE HIGHEST-VALUE WIDENING, and it is measured.**  The gate is "a dot
  inside a bracket", but the LAW is "the index object has no `decompileHelper`
  row".  `v74_edge.sv:47` `sq[fidx(i)].len()` — a `func_call` index with NO DOT
  — is golden `sq[].len` and ours `sq[fidx(i)].len`, unchanged, because the gate
  never fires.  Widening the gate from the TEXT to "the index renders EMPTY"
  would take that class too — at the cost of a fence that can no longer be
  enumerated from the pristine databases, which is why this pass did not.
* **R-P — a `.` inside PARENTHESES is still split.**  MiniAmiq's
  `control_assertion_dpi(a_sva.<x>)` and `get_cover_statistics_dpi(cover_info[index]…)`
  receivers still mint `ref_obj (control_assertion_dpi(a_sva)` fossils (12 + 2
  rows, both modes).  Golden's shape for them was NOT measured here; the gate is
  brackets only, deliberately.
* **R-Q — `q[0].delete();` in STATEMENT position.**  The base-name prefix is
  gated on the dot, so an INDEXED receiver with no dot keeps its written
  component as the prefix name.  Golden's answer there was not measured and has
  no corpus cell in the fence.
* **R-V1 — a compound index's element FULLNAMES.**  `v74_edge`'s `ih.k` index
  gives its second element the scope-joined `work@…::sq[].len::k` where golden is
  name-only.  `VpiFullName` is read by no generated `Compare`; the convention is
  the pre-existing `joinRef(prefix, dotted)` for a non-`NamedValue` index.
* **R-V2 — a census-keying note, not a defect.**  On the grid's
  `p_stmt_delete` cell golden's ELAB listing shows ONE argument `hier_path`
  where we show two: the source has three copies of the task in BOTH databases
  and golden SHARES one subtree across two of them while we clone it.  Sharing
  vs copying is invisible to the judge (no generated `Compare` reads
  `VpiParent`), and it is only visible now because the pristine binary emitted
  no argument at all.

## 9. R0 — THE NEXT HEAD

`/tmp/r10buvm23_wd/pat.default.cmp` (32 lines `2>&1`, 16 on stderr, md5
`070cefa7005899f934be8d9900f37744`, `grep -c '^LHS:'` = 1, byte-identical
between the two modes):

```
LHS  constant: , line:30186:82, endln:30186:82        <- UNPARENTED, at the CALL SITE
       |vpiDecompile:0  |vpiSize:64  |INT:0   |vpiConstType:7
RHS  constant: , line:24157:58, endln:24157:59        <- the DECLARATION's own literal
       |vpiParent: \_method_func_call: (open_recorder) @30186:42-55
       |vpiDecompile:0  |vpiSize:64  |UINT:0  |vpiConstType:9
```

**THE FIELD IS `VpiConstType`.**  `constant::Compare`
(`generated/src/constant.cpp`) reads `basetype_t::Compare` first — `VpiType`,
`VpiName`, `VpiDefName`, then `expr`'s `VpiDecompile` ("0" both), `VpiSize` (64
both) and `Typespec` (null both) — and then compares **`VpiConstType` ONLY**;
`VpiValue` is NOT a compared field, so `INT:0` vs `UINT:0` matters only through
the const type 7 (`vpiIntConst`) vs 9 (`vpiUIntConst`).

Site, `uvm_pkg.sv:30186` inside the same `execute_report_message`:

```systemverilog
uvm_recorder recorder = stream.open_recorder(report_message.get_name(),,report_message.get_type_name());
```

— an **OMITTED middle argument** (`,,`) filling the formal
`time open_time = 0` declared at `:24157`.  Golden RE-ENCODES the default as a
`vpiIntConst` located at the CALL SITE's empty slot and leaves it UNPARENTED;
we clone the DECLARATION's own `0` literal (its `vpiUIntConst` encoding, its
`24157:58` span) and parent it at the call.  This is the same
"golden re-encodes rather than copies" family earl67 documented for the
port-actual/param_assign copy (§ `genLpPortConnCopyableOnly11v`), reached here
through a DEFAULTED formal — and note that § `writtenCallArgs16` deliberately
drops a defaulted formal that was NOT written, so the rule for an OMITTED-BUT-
POSITIONALLY-PRESENT argument (`,,`) is a distinct arm from it.

## 10. HOW TO REPRODUCE

```bash
bash build23.sh /tmp/r10buvm23cen                        # the hier_path census
bash fence23.sh <sweep workdir> /tmp/r10buvm23cen <out>  # the fence, from pristine DBs
python3 hpcen23.py <cen.golden> <cen.ours> [--cmponly] [--full]
bash grid23.sh g23.sv <pristine> <patched> <wd> /tmp/r10buvm23cen
python3 gridcmp23.py <wd>/cen.g.txt <wd>/cen.pris.txt <wd>/cen.pat.txt [--full]
bash sweeps23.sh <binary> <workroot> <worktree>          # both corpora, one binary
PRISTINE=… PATCHED=… ROOT=<a COPY of tools/probe> MODE=file|dir VIEW=def|elab bash bound23.sh
bash canaudit.sh canaries.sh ctcan2.sh
```
