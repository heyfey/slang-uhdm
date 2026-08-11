# r10uvm51 — the type-parameter array dimension. TWO laws, head advanced TWICE, NO conversion

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order. Every dump excerpt is passed through `sed 's#/home/[^ ,]*/##g'` and
`sed '1d'` (uhdm-dump's first line is the DATABASE PATH — the +2 bias the
pass-50 integration fixed campaign-wide; all four drivers here carry the fix).

Base **01967cb**. My worktree's control build of pristine 01967cb came out
`md5 6b9bb86c97f0273c66966afb601648e0`, **byte-identical to the main-tree
`build/slang-uhdm` at the start of this pass**, which independently validates it
as the HEAD control. Final build: `7bb8c2bfd082debaa4dfaa10487779a8`.

## 0. HEADLINE — honest

* **NONE of the four tests CONVERTED.** `SimpleUVM`, `SeqDriver`, `BuildUVMPkg`
  and `Scoreboard` are still `CMP_NOTEQUAL`. **No row in either committed
  baseline changed. There is NO CONVERSION to promote.**
* What DID happen, measured on the corpus (`SimpleUVM`, `default`, my own
  golden + my own build, `/tmp/r10uvm51_gsu`):

  | stage | binary md5 | cmp lines | heads | head family |
  |---|---|---|---|---|
  | 01967cb control | `6b9bb86c` | **15** | 1 | assoc `vpiIndexTypespec` at the `KEY` token |
  | + law 1 | `f5ea534a` | 180 | 1 | `array_var` `vpiArrayType` 1-vs-3 + missing `vpiRange` |
  | + law 2 (final) | `7bb8c2bf` | **29** | 1 | class-method CALL-ARGUMENT `vpiActual` (NEW family) |

  The head moved **twice** and is now a **completely different UHDM family** from
  the one the brief pointed me at. The associative-array residue R1 that pass 50
  handed me is **FINISHED as far as the def-view class property can see it**.
* Two laws, each with its own witness and its own arm:
  `assocIdxTypeParamNoIndexTs51` (3 sites) and
  `assocTypeParamDimIsStaticSize51`.
* **All seven comparable rows moved and NOTHING else did.** The byte verifier
  pairs 1632 databases across both corpora and reports exactly **7 movers = the 7
  target rows, 0 collateral** (§10). Both committed baselines: **ROW DIFFS 0**.
* The four tests now sit behind **two already-named residues**, one of them pass
  50's own: the three uvm-1.2 tests share a new single head that is residue
  **R1** below (class-method call-argument `vpiActual`), and **BuildUVMPkg's new
  head is PASS-50's residue R2** (`classNestedClassTdGroupWithoutPkgAnchor`) —
  see §9's per-row census.
* **cmp line count is NOT a distance metric across head families** — an
  `array_var` subtree prints ~180 lines where a bare `ref_typespec` prints 15.
  The metric that is comparable is the DUMP distance, and it fell everywhere:

  | arm | 01967cb content ± | final content ± |
  |---|---|---|
  | a1 | **342** | **268** |
  | a3 | (head at the MK index typespec) | **101** |

  (`content ±` = `diff -u g.dump o.dump \| grep -c '^[-+]'` minus the 2 `diff -u`
  header lines, on dumps whose first line is already stripped.)

## 1. THE BRIEF'S MODEL IS REFUTED IN ITS CENTRAL CLAIM

The brief said, of `protected T pool[KEY];`:

> *"the index is the CLASS TYPE PARAMETER `KEY`, whose DEFAULT is `int`. We are
> RESOLVING A TYPE PARAMETER TO ITS DEFAULT and emitting an index typespec for
> it. Surelog emits none. So the candidate law is: in the DEF view, an
> associative array whose INDEX is a TYPE PARAMETER gets NO index typespec."*

Both halves are wrong, and the second one would have produced a WRONG fix.

**(a) It is not about the DEFAULT, and it is not VIEW-SCOPED.** The brief named
the deciding cell and it is arm **a3**: `module sub51 #(parameter type MK = int);
int p_tp[MK];` instantiated once as `sub51 #(.MK(string)) u1` and once defaulted.
In the ELABORATED view `MK` is a REAL type (`string`), fully overridden, nothing
defaulted — and **golden STILL emits no index typespec**. Golden's only two index
typespecs in the whole of a3 are the `[string]` control at `14:13`, one per view.
So the suppression is unconditional on the view AND on whether the parameter was
overridden. A view-scoped gate would have been wrong.

**(b) The fix is NOT "SUPPRESS", it is "SUPPRESS **and** RESHAPE".** Golden does
not emit a bare associative array with a missing index typespec. **Golden never
saw an associative array at all.** Surelog's dimension compiler resolves the
bracket name in the PARAMETER map first, so `[KEY]` is compiled as a SIZE
EXPRESSION: the array_var is a `vpiStaticArray` carrying `[0 : KEY-1]`.
Corpus witness, `uvm_pkg::uvm_pool::pool` (g.dump:808867 / o.dump:802938 at
01967cb):

| field | LHS golden | RHS ours 01967cb |
|---|---|---|
| `vpiArrayType` | **1** (static) | **3** (assoc) |
| `vpiRange` | `range 42:20-42:23`, `[0 : KEY-1]` (`vpiOpType:11`, `ref_obj KEY`) | ABSENT |
| `array_typespec` | BARE | `vpiIndexTypespec -> ref_typespec -> int_typespec 42:20-42:23` |

Both `VpiArrayType()` and `Ranges()` are read by `array_var::Compare`
(`~/git-repos/UHDM/build/generated/src/array_var.cpp:128` and `:134`), which is
**exactly why LAW 1 alone moved the head instead of clearing it** — it took the
`array_typespec` off the table and handed cmp the `array_var` behind it. Anyone
who had implemented only the brief's suppression would have reported a head move
and no conversion, and would not have known why.

**(c) The absence WAS real** — the one thing the brief got right, and I
re-verified it rather than inheriting it: `grep -c "int_typespec: , line:42:20,
endln:42:23"` is **2** in my 01967cb `o.dump`, **0** in `g.dump`, and golden's
`array_typespec` prints bare in its own dump.

## 2. Drivers and arms (all committed here, all with working guards)

| asset | what it is |
|---|---|
| `gold.sh` | one arm: golden + ours, dump + cmp. Copied from `r10uvm50repro` with the `sed '1d'` fix intact. Guards: both databases existence-checked before cmp (uhdm-cmp EXITS 0 on a MISSING input); the slang path + md5 printed every run. |
| `corpdump.sh` | both sides of one CORPUS test out of a `verify_golden` workdir. |
| `heads.sh` | per-test cmp lines / head count / id-normalised head md5 over a workdir; reports `SKIP-NOFILE` and counts it, so a driver that reaches nothing cannot read as perfection. |
| `csvdiff.py` | WHOLE-ROW diff (status AND dump) of a sweep CSV against a committed baseline, plus both histograms. Row counts from the parsed dict, never `wc -l`. |
| `manifest.sh` / `bvcompare.sh` | the byte verifier's two halves. Both refuse to report on an empty manifest / an empty join. |
| `canaries.sh` | per-NAME canary check; prints ABSENT and counts it. **Extended this pass** with the five pass-50 collateral movers (`ClassParamAsParam`, `ClassTypeParam`, `SVSwitch`, `SimpleConstraint`, `ApbSlave`) and the four UVM targets. |
| `explainmover.sh` | HEAD-vs-POST dump diff for one mover. |
| `a1/dut.sv` | **new** — the 7-cell index grid: type param with default / concrete keyword control / type-param element queue + dynarray / type param without default / plain-class controls / packed bound that is a VALUE parameter. |
| `a2/dut.sv` | **new** — the REACH cells: package scope, module scope, subroutine-local, INNER dimension, outer-type-param + inner-concrete, controls beside each. |
| `a3/dut.sv` | **new** — THE VIEW-SCOPE DECIDER (§1a). |
| `a4/dut.sv` | **new** — HEAD 3: which call-argument ref_objs golden binds, incl. the CLASS-vs-PACKAGE distinguisher on ONE binary. |

**All four arms are cmp-VISIBLE**, so unlike pass 49/50's `a1` these arms do not
need the dump to show a verdict. Exact figures, and I am stating which binary each
was measured on because that is a measurement too: `a1`/`a2`/`a3` = **15 cmp
lines, 1 head each at 01967cb** (`6b9bb86c`), the same shape as the corpus head;
`a4` = **128 cmp lines, 1 head on the FINAL binary** (`7bb8c2bf`) — `a4` was built
after laws 1+2 landed and was never run at 01967cb, and its cells are all
concrete-index so neither law reaches them. I judged every law on
`diff -u g.dump o.dump` regardless of cmp.

## 3. LAW 1 — `assocIdxTypeParamNoIndexTs51`

**Predicate** (`src/EmitHelpers.h`, `grep -n 'bool assocIdxIsTypeParam51'`): the
index type's `kind` is `SymbolKind::TypeAlias` **and** its syntax node's kind is
`syntax::SyntaxKind::TypeAssignment`. **Direction: SUPPRESS** — and the typespec
is not merely unlinked, it is never MINTED (an orphan would still join the
design's typespec arena, and `design::Compare` walks `Typespecs()` as a
size-checked vector).

**Three sites, all tagged `§ assocIdxTypeParamNoIndexTs51` in the code**:

| site | file | what it serves | arm cell |
|---|---|---|---|
| 1 | `src/UhdmExporter.cpp`, `emitAssocDims`, `if (idx[0] && !assocIdxIsTypeParam51(*idx[0]))` | CLASS PROPERTY — **the corpus head** | a1 c1/c5, a2 c5 |
| 2 | `src/TypeEmit.cpp`, `if (leadingUnsized && dims[0].indexType && !assocIdxIsTypeParam51(...))` | MODULE / interface instance-level array_var | a2 c1, a3 |
| 3 | `src/ParamEmit.cpp`, `emitPkgArrayVar`, `if (idx && !assocIdxIsTypeParam51(*idx))` | PACKAGE-scope data declaration | a2 c2 |

A FOURTH copy of the index rule exists (`src/TaskFuncEmit.cpp`,
`grep -n assocIoRange9` / `assocDim0`) and **needed no change**: it already
models a name-written dimension as the SIZE form, and a2 cell 3
(`T loc_pool[KEY]` inside a method) is already correct on both sides. **I
measured that before concluding it, rather than editing all five copies.**

### WHY THE GATE IS "TYPE PARAMETER" AND NOT "WRITTEN AS A NAME"

This is the refutation that keeps the law narrow, and it is the reason the
existing `namedIdx0` rule in `TaskFuncEmit` **must not** be copied to these three
sites: at these sites a TYPEDEF-name index is associative in golden and DOES
carry an index typespec.

### ARM TABLE — every cell, BOTH SIDES (a1 / a2 / a3, 01967cb → final)

| cell | source | LHS golden | RHS 01967cb | RHS final |
|---|---|---|---|---|
| a1 c1 index = type param WITH default | `T tp_pool[KEY];` (generic class) | **no index typespec** | `int_typespec 17:15-17:18` (the `KEY` token) | **none** |
| a1 c5 index = type param, own class | `int nd_pool[KEY2];` | **no index typespec** | `int_typespec 26:17-26:21` | **none** |
| a1 c2 CONTROL concrete, SAME generic class | `int c_pool[string];` | `string_typespec 18:16-18:22` | same | **same — did not move** |
| a1 c2b type-param ELEMENT, TYPEDEF index | `T tp2_pool[myint51];` | `int_typespec (myint51) 13:11-13:14` | same | **same** |
| a1 c6 plain class, `[string]` | `int pc_pool[string];` | `string_typespec 31:17` | same | **same** |
| a1 c6 plain class, TYPEDEF | `int pt_pool[myint51];` | `int_typespec (myint51) 13:11` | same | **same** |
| a1 c6 plain class, `[int]` | `int pi_pool[int];` | `int_typespec 33:17-33:20` | same | **same** |
| a1 c7 packed bound = VALUE param | `int vw_pool[logic [W-1:0]];` | `logic_typespec 39:17-39:30` | same | **same** |
| a2 c2 PACKAGE scope, `parameter type` | `int pk_pool[PKEY];` | **none** | `int_typespec 15:15-15:19` ×2 (one per package view) | **none** |
| a2 c1 MODULE scope, `parameter type` | `int mk_pool[MKEY];` | **none** | `int_typespec 35:15-35:19` | **none** |
| a2 c5 OUTER type param, inner concrete | `T oo_pool[KEY][string];` | **none** | `int_typespec 20:15-20:18` | **none** |
| a2 c4 INNER dim is the type param | `T ii_pool[string][KEY];` | `string_typespec 19:15` (outer) | same | **same** |
| a2 c3 SUBROUTINE-local | `T loc_pool[KEY];` | **none** | **none already** | none |
| a2 controls `[string]` ×3 / `[myint51b]` | | present | present | **present** |
| a3 DEF view | `int p_tp[MK];`, MK defaulted | **none** | `int_typespec 13:12-13:14` | **none** |
| a3 ELAB view, MK **OVERRIDDEN** `string` | same, `u1` | **none** | `string_typespec 13:12-13:14` | **none** |
| a3 control both views | `int p_ctl[string];` | `string_typespec 14:13` ×2 | ×2 | **×2, unmoved** |

**HOW THE GATE WAS PROVED NECESSARY AND SUFFICIENT.** Final `a1`: our 6 index
typespecs are now the SAME SIX as golden's, span for span
(`string 18:16`, `myint51 13:11`, `string 31:17`, `myint51 13:11`, `int 33:17`,
`logic 39:17`) — 8 before, 6 after, and the 2 removed are exactly the two
type-parameter cells. Final `a3`: 4 → 2, and the 2 removed are the two views of
`[MK]`. Zero control moved in any arm.

**Deliberately NOT gated: the INNER dimensions** (`emitAssocDims`' `i>=1` loop).
Golden does not suppress a typespec there, it emits a WHOLE DIFFERENT SHAPE —
a2 `T ii_pool[string][KEY]` gives golden a static `range 19:23-19:26` `[0:KEY-1]`
on the array_var and NO associative marker constant at all. Suppressing the
marker's typespec would be wider than the evidence and closer to nothing.
Residue **R2**.

## 4. LAW 2 — `assocTypeParamDimIsStaticSize51` (`src/UhdmExporter.cpp`, `emitAssocDims`)

**Direction: RESHAPE (associative → static).** This is the law the brief did not
have, and the one that actually moved the corpus head off this family.

**Predicate.** The declaration has EXACTLY ONE written associative dimension
(`idx.size() == 1`) and `assocIdxIsTypeParam51(*idx[0])`. Then:
`av->VpiArrayType(vpiStaticArray)` and `av->Ranges({[0 : <name>-1]})`, and return
before the index-typespec and marker blocks. The range shape is
`§ assocIoRange9`'s (`src/TaskFuncEmit.cpp`, `grep -n assocIoRange9`) with one
addition golden requires here and not there: the `ref_obj` carries a
`vpiFullName` of `<array fullname>::<name>` (`uvm_pkg::uvm_pool::pool::KEY`).
The helper is the lambda `tpSizeRange51` at the top of `emitAssocDims`.

**WITNESS — the corpus head after law 1** (`SimpleUVM` `default`,
`uvm_pkg::uvm_pool::pool`):

| field | LHS golden | RHS after law 1 | RHS after law 2 |
|---|---|---|---|
| `vpiArrayType` | 1 | 3 | **1** |
| `vpiRange` | `[0 : KEY-1]` @42:20-42:23 | ABSENT | **present, compares EQUAL** |
| `vpiIndexTypespec` | absent | absent (law 1) | absent |

**HOW THE GATE WAS PROVED NECESSARY.** The corpus: `SimpleUVM`'s cmp went
**180 lines → 29** and the head left the `array_var` family entirely (§6). The
arms: `a1`'s `nd_pool` and `tp_pool` hunks — 29 and 27 diff lines of
`vpiArrayType` + `vpiRange` at 01967cb — are **GONE** from the final `a1` diff;
what is left on those two objects is only the `vpiSigned` placement (residue R4,
pre-existing and unrelated).

**WHY THE `idx.size() == 1` HALF OF THE GATE IS NECESSARY** — a MIXED
multi-dimension declaration is a THIRD shape, not this one (a2, both sides):

| a2 cell | LHS golden array_var | LHS golden array_typespec |
|---|---|---|
| `T ii_pool[string][KEY]` | `vpiArrayType 3` **and** a `[0:KEY-1]` range @19:23 | `vpiIndexTypespec -> string` |
| `T oo_pool[KEY][string]` | `vpiArrayType 3`, **NO** range | NESTED PAIR: outer `arrayType 3` + `vpiElemTypespec ->` inner holding the `[0:KEY-1]` range @20:15 |
| `T pool[KEY]` (a1/corpus) | `vpiArrayType 1` + the range | BARE |

Widening law 2 to those would be wider than the evidence. Residue **R2**. The
corpus witness `uvm_pool.svh:42` is single-dimension, so the gate costs the
corpus nothing.

## 5. SITE 2 AND SITE 3 GOT LAW 1 BUT NOT LAW 2 — and that is a MEASURED, NOT a silent, gap

Law 2 is implemented at the CLASS-PROPERTY site only. So at the module and
package sites the head moved from "an extra index typespec" to "the wrong array
kind", which the arms show directly (final heads):

* `a2` head: `array_var (p51b::pk_pool)` — the PACKAGE site.
* `a3` head: `array_var (work@a3_top.u1.p_tp)` — the MODULE site, `vpiArrayType`
  1 vs 3 plus golden's `range 13:12-13:14`.

That is residue **R3**, ranked and named below. **It cannot demote a corpus row**,
and the reasoning is checkable: for a row to be CMP_EQUAL today at those sites,
our index typespec would have to match golden's — and golden emits none there, so
no such row can be equal today. Gates 3/4/5 confirm it: zero row diffs.

## 6. WHERE THE HEAD IS NOW — HEAD 3, decoded, with its distinguisher measured

`SimpleUVM` `default`, 29 cmp lines, 1 head, `LHS: <null>` / RHS an `io_decl`.
Source: uvm-1.2 `base/uvm_pool.svh:87`, `if (!pool.exists(key))` inside
`virtual function T get (KEY key);` (line 86). The failing field is the
`vpiActual` of the ARGUMENT `ref_obj` (g.dump:809229 / o_p2.dump:803300):

| | LHS golden | RHS ours |
|---|---|---|
| arg `ref_obj` vpiFullName | `uvm_pkg::uvm_pool::get::pool.exists::key` | `uvm_pkg::uvm_pool::get::key` |
| arg `ref_obj` **vpiActual** | **ABSENT** | `io_decl (key)` — **the cmp head** |

**This is NOT "golden never binds an argument".** Golden binds `vpiActual ->
io_decl` **6911 times** in the same database. Arm `a4` isolates the
distinguisher, and both halves are measured **on ONE binary in ONE run** so they
cannot be an artefact of two runs:

| a4 cell | shape | LHS golden `vpiActual` | RHS ours |
|---|---|---|---|
| 7 | PACKAGE function calling a PACKAGE function, `pkgcallee51(p, v)` | **PRESENT** -> `io_decl` (g.dump:168) | present — **MATCHES** |
| 4 | CLASS method calling a CLASS method, `g51(v)` | **ABSENT** | present — **DIFFERS** |
| 1 | CLASS method, BUILT-IN assoc method, `pool.exists(key)` | **ABSENT** | present — **DIFFERS** |
| 3 | CLASS method, user method via a handle, `h51.m51(v)` (formal) | ABSENT | absent — matches |
| 5 | same, argument is a LOCAL, `h51.m51(loc)` | ABSENT | absent — matches |
| 2 | CLASS method, queue built-in, `q51.push_back(v)` | ABSENT | absent — matches |

and the corpus corroborates cell 7 independently: golden's
`uvm_hdl_force_time` (a PACKAGE function) calling `uvm_hdl_deposit(path, value)`
DOES carry `vpiActual -> io_decl` on both arguments (`g.dump:5293` and `:5301`).

So the law is **`classMethodCallArgUnbound51` — inside a CLASS METHOD, a
call-argument `ref_obj` carries NO `vpiActual`; inside a PACKAGE subroutine it
does.** Golden's second half (the `<sub>::<hier_path>::<arg>` fullname) is
**`vpiFullName` and therefore NOT cmp-visible** — DUMP_MATCH phase-3 work.

**I did NOT implement it, and the reason is a scope judgement I am stating
openly.** The generic bind is `src/ExprEmit.cpp` (`grep -n
"ref->Actual_group(it->second)"`, the arm guarded by the `netMap` lookup and the
`fnLocalParamInitBare` exclusion list) — the most heavily conditioned expression
path in the tree, in **the file the other slot of this frontier is editing**, and
its blast radius is every class method in both corpora. Landing it needs its own
pass with its own gate budget, not the tail of this one. It is residue **R1**,
rank 1, and it is fully decoded above: an implementer needs the gate
(class-method context), the two arm halves, and nothing else.

## 7. RANKED RESIDUE — most reachable first

**R1. `classMethodCallArgUnbound51` — a call-argument `ref_obj` inside a CLASS
METHOD carries no `vpiActual`. DIRECTION: SUPPRESS. Depth: medium (one predicate,
but in `src/ExprEmit.cpp`'s generic `netMap` bind — the tree's most conditioned
path, and the other slot's file). RANK 1 — it is the LIVE head of the UVM rows
and the only thing between this pass's laws and a conversion.** Fully decoded in
§6 including the CLASS-vs-PACKAGE distinguisher measured on one binary (arm `a4`
cells 4 and 7) and corroborated on the corpus (`uvm_hdl_force_time`). The arm
already exists: `a4`, cmp-visible at 128 lines / 1 head on the final binary.
**Expect a FURTHER head behind it** — 29 cmp lines is ONE head, not the last one,
and a4's own head is residue R4, so R1 and R4 will have to be taken together
before that arm can reach zero.

**R2. `assocTypeParamMixedDims` — a MIXED multi-dimension declaration where some
dimension is a type parameter. DIRECTION: RESHAPE. Depth: medium. RANK 2.** Two
distinct golden shapes, both measured in §4's table (`ii_pool` keeps
`vpiArrayType 3` and gains the static range beside the assoc index typespec;
`oo_pool` grows a NESTED `array_typespec` pair). Also covers `emitAssocDims`'
INNER-dimension marker constants, which golden replaces with a static range
rather than emitting without a typespec. Not corpus-blocking — the UVM witness is
single-dimension.

**R3. `assocTypeParamStaticSizeAtSites2And3` — law 2 at the MODULE and PACKAGE
array_var sites. DIRECTION: RESHAPE. Depth: SHALLOW — the same lambda, two more
call sites (`src/TypeEmit.cpp` `grep -n assocIdxSiteFour43` and
`src/ParamEmit.cpp` `grep -n assocIdxSiteFive44`). RANK 3.** Measured: it is the
final head of `a2` (`array_var (p51b::pk_pool)`) and of `a3`
(`array_var (work@a3_top.u1.p_tp)`, `vpiArrayType` 1 vs 3 + golden's
`range 13:12-13:14`). Proved unable to demote a corpus row (§5) and confirmed by
zero row diffs in gates 3/4. I did not do it because it buys the four target
tests nothing and a code change costs a full re-gate; **HONESTLY NOT DONE.**

**R4. `assocArrayVarCarriesElemSign` — which object carries `vpiSigned` on an
ASSOC / QUEUE / DYNAMIC array with a SIGNED element. DIRECTION: MOVE (element reg
-> array_var). Depth: shallow per site. RANK 4, and it is the HEAD of arms a1 and
a4.** Golden puts `vpiSigned:1` on the **array_var** and nothing on the element
`reg`; we do the exact opposite. `variables::Compare` reads `VpiSigned`
(`~/git-repos/UHDM/build/generated/src/variables.cpp:251`), so this is
cmp-visible. Measured in a1 on **eight** objects and in a4 on `pool` and `q51`
(`int pool[string]`, `int q51[$]`). **PRE-EXISTING at 01967cb** and untouched by
this pass. It does nothing for the four UVM tests (`uvm_pool::pool`'s element is
the class `uvm_void`, unsigned), but it is cheap and cmp-visible and may be worth
more than R1 across the corpus — MEASURE ITS REACH FIRST, `int x[string]` class
properties are common.

**R5. type-parameter typespec IDENTITY — golden binds the SHARED
`type_parameter` typespec object, we mint a fresh one at the use site.
DIRECTION: REPLACE (point at the existing object). Depth: unknown. RANK 5, and
it is DUMP-ONLY.** `uvm_pool::get`'s `io_decl (key)`: golden's `vpiTypedef` ref
resolves to the `int_typespec` at `191:34-191:37` whose `vpiParent` is
`type_parameter (uvm_pkg::uvm_pool::KEY)`; ours resolves to a fresh
`int_typespec 86:27-86:30` spanned at the `KEY` token. Locations are not
cmp-visible and both sides HAVE the object, so this is DUMP_MATCH work — but it
is the same "resolve a type parameter" family as laws 1 and 2 and is likely one
fix with several beneficiaries. Same shape on `class_typespec (uvm_void)`
(golden `100:39`, ours the use site).

**R6. `hierPathCallArgFullName` — golden's argument fullname under a hier_path is
`<sub>::<hier_path>::<arg>`. DIRECTION: RENAME. Depth: shallow. RANK 6, NOT
convertible work** — `BaseClass::Compare` never reads `VpiFullName`. Measured in
a4 cells 1/3/5 (`p51c::c51::f51::pool.exists::key`,
`…::h51.m51::v`, `…::h51.m51::loc`); ours spells all three without the hier
segment. Bundle with R1, which touches the same objects.

## 8. Gates — every one, with the numbers I measured

Binary md5 printed BEFORE and AFTER every sweep; **no rebuild happened while a
sweep was running** (the two md5s straddling the u2r sweep are both
`7bb8c2bfd082debaa4dfaa10487779a8`). `git stash` was never used.

| gate | result |
|---|---|
| 1. `cmake --build build -j 3`, my own worktree | rc 0, `7bb8c2bfd082debaa4dfaa10487779a8` |
| 2. 23 goldens, `SLANG_UHDM` exported to MY build | **PASS 23 / FAIL 0** |
| 2b. negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** — the harness really is using the exported binary |
| 3. uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir` | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `csvdiff.py` vs `results/gate_uhdm2rtlil.csv`: **ROW DIFFS 0** |
| 4. surelog, `--mode both --jobs 2`, own `--out`/`--workdir` | see §9 |
| 5. byte verifier, BOTH corpora, same workdir paths | see §10 |

`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` were **read only,
never rebuilt, edited or included.** Their row counts come from the parsed dict
(731 and 1588), never from `wc -l` (732 and 1589 with the header).

## 9. GATE 4 — the surelog corpus, and the PER-ROW head census

`--mode both --jobs 2`, `--out /tmp/r10uvm51_sl.csv`,
`--workdir /tmp/r10uvm51_sl_wd`, `SLANG_UHDM` exported to my build; md5
`7bb8c2bf` before AND after.

* `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**, `testflags` **463 / 10**.
* totals **930 CMP_EQUAL / 23 CMP_NOTEQUAL / 570 SLANG_REJECT / 48 SURELOG_FAIL
  / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM**.
* dump **390 match** = **225 default + 165 testflags** (counted per mode off the
  CSV, not inferred) / 540 differ / 658 blank. **The match counts did not fall.**
* `csvdiff.py` vs `results/golden_surelog.csv`: **ROW DIFFS 0**.
* No `Google,testflags` SURELOG_FAIL-vs-TIMEOUT flake appeared this run — it
  would have shown as a row diff, and there were none.
* `LowMemPkg,testflags`' baseline row carries an absolute session-scratchpad path
  and reproduced identically; not touched, not reported as a regression.

**Canaries, spot-checked INDIVIDUALLY BY NAME** (`canaries.sh`, which prints and
counts ABSENT so a typo cannot read as green):

* surelog corpus: **52 canary rows, `ok=52 changed=0 absent=0`**. The two live,
  fragile conversions are intact — `InterfaceModPort` `CMP_EQUAL/differ` both
  modes, `BlackParrotComplex` `CMP_EQUAL/differ` both modes. `YosysBigSimReed`
  and `YosysOldOpen` `CMP_EQUAL/differ` both modes, unregressed. The five
  pass-50 collateral movers (`ClassParamAsParam`, `ClassTypeParam`, `SVSwitch`,
  `SimpleConstraint`, `ApbSlave`) all unchanged.
* uhdm2rtlil corpus: **8 canary rows, `ok=8 changed=0 absent=0`**.
* whole families diffed as blocks against the baseline: `Black*` **34 rows
  IDENTICAL**, `EvalFunc`+`ParamFile` **18 rows IDENTICAL**.
* the four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
  `TopParam`) were never dispatched.

### The seven comparable UVM rows, HEAD vs POST, measured with `heads.sh`

HEAD half read off `/tmp/r10uvm51_sl_wd` after the control sweep; POST half from a
filtered re-run of exactly those four tests
(`--filter 'SimpleUVM|SeqDriver|BuildUVMPkg|Scoreboard'`, workdir
`/tmp/r10uvm51_uvm4_wd`) on the final binary.

| test | mode | HEAD lines/heads/md5 | POST lines/heads/md5 |
|---|---|---|---|
| BuildUVMPkg | default | 15 / 1 / `921a513a` | **17 / 1 / `a6786ca7`** |
| BuildUVMPkg | testflags | 15 / 1 / `921a513a` | **17 / 1 / `a6786ca7`** |
| Scoreboard | default | 15 / 1 / `aff2b034` | **29 / 1 / `8ba5d8da`** |
| SeqDriver | default | 15 / 1 / `aff2b034` | **29 / 1 / `8ba5d8da`** |
| SeqDriver | testflags | 15 / 1 / `aff2b034` | **29 / 1 / `8ba5d8da`** |
| SimpleUVM | default | 15 / 1 / `aff2b034` | **29 / 1 / `8ba5d8da`** |
| SimpleUVM | testflags | 15 / 1 / `aff2b034` | **29 / 1 / `8ba5d8da`** |
| Scoreboard | testflags | SKIP-NOFILE (SLANG_REJECT at baseline) | SKIP-NOFILE |

The HEAD column reproduces the brief's stated pass-50 table md5-for-md5, which is
an independent re-measurement of it rather than an inheritance.

**Every head md5 changed, and the shapes SPLIT — which is progress, not noise:**

* the three uvm-1.2 tests now share **ONE NEW head**, `8ba5d8da`, and it is
  residue **R1** verbatim: `LHS: <null>` / RHS `io_decl (key)` in
  `function uvm_pkg::uvm_pool::get` at `86:31-86:34` (§6). Verified by reading
  `cmp_default_SeqDriver.txt` and `cmp_default_Scoreboard.txt` individually, not
  by trusting the md5 equality.
* **BuildUVMPkg's new head is PASS-50's OWN residue R2**, not a new family:
  `LHS ref_typespec (uvm_pkg::uvm_pool::type_id) -> class_typespec (type_id)
  @26247:12-26247:31` / `RHS: <null>` — the missing `vpiTypedefAlias` on a
  class-nested class-handle typedef whose generic class has no package-level
  anchor (`classNestedClassTdGroupWithoutPkgAnchor`, pass-50 §10 R2, RANK 2
  there). BuildUVMPkg compiles **1800.2-2017-1.0**, the other three uvm-1.2 — the
  two versions' line numbers are NOT interchangeable and 26247 is a pp line in
  BuildUVMPkg's own preprocessed `uvm_pkg.sv`.

So the four tests now sit behind **two** named, already-decoded residues, and
neither is the associative-array family this pass closed.

## 10. GATE 5 — the byte verifier, BOTH corpora, and EVERY mover explained

Run BACKWARDS, as pass 50 did: the POST manifests come from the gate-3/gate-4
sweeps, then the HEAD binary was run into the **SAME workdir paths** and its
manifests taken. **The main-tree binary is NOT a usable control in this pass** —
it was `6b9bb86c` at the start of the pass and the other slot had rebuilt it to
`4a5ef68f` by gate time — so the HEAD binary was rebuilt HERE from
`git checkout 01967cb -- src/EmitHelpers.h src/ParamEmit.cpp src/TypeEmit.cpp
src/UhdmExporter.cpp`, which reproduced **`6b9bb86c97f0273c66966afb601648e0`
exactly**, the same md5 as my first control build. My edits were copied aside and
copied back (**never `git stash`**), and `git diff 01967cb` after the restore is
**byte-identical** to the diff taken before it (`diff` of the two patch files is
empty — printed as `RESTORE IS BYTE-IDENTICAL`). Both HEAD sweeps reproduced the
committed baselines exactly (`ROW DIFFS 0` against both), which independently
validates them as controls.

| corpus | paired | identical | DIFFER |
|---|---|---|---|
| uhdm2rtlil (`testflags`) | 679 | **679** | **0** |
| surelog (`both`) | 953 | 946 | **7** |

Path sets are IDENTICAL on both corpora (head 679 = post 679 = paired 679; head
953 = post 953 = paired 953). **Comparator negative control:** flipping one
character of one hash in the u2r POST manifest makes `bvcompare.sh` report
`identical 678 / DIFFER 1 / MOVER testflags/1DUnpackedArray-…`, so a real
difference cannot pass unnoticed.

**The 7 movers are EXACTLY the 7 target rows and NOTHING else:**

```
    [NOT EVIDENCE] default/Scoreboard-59431470/slang.uhdm
    MOVER default/BuildUVMPkg   MOVER testflags/BuildUVMPkg
    MOVER default/SeqDriver     MOVER testflags/SeqDriver
    MOVER default/SimpleUVM     MOVER testflags/SimpleUVM
```

`bvcompare.sh`'s `[NOT EVIDENCE]` label on `default/Scoreboard` is **misleading
and inherited** — the pass-50 integration already recorded this: Scoreboard IS
target #4, so its database is an EXPECTED mover (head md5 `aff2b034` -> POST
`8ba5d8da`) *and* it is the known-nondeterministic one, i.e. usable as neither
clean evidence nor a clean pass. I did not change the label; I am naming it.

**ZERO COLLATERAL MOVERS in either corpus.** That is the strongest statement this
pass can make about reach: the two laws changed exactly the seven databases they
were aimed at, out of 1632 emitted databases, and every one of the 183
u2r `CMP_EQUAL`+dump-differ rows — where the CSV diff is BLIND — is byte-identical.
Contrast pass 50, which had 10 collateral rows to explain.


## Corrections applied at integration by the master (pass-51 verifier)

1. **ARM ROW ASSERTED, NOT MEASURED — and I confirmed it by reading the arm.**
   `a1/dut.sv` labelled cell 5 *"index = TYPE PARAMETER WITHOUT a default"* in two
   places, but the class is `class gnd51 #(type KEY2 = int);` — it **HAS** one. The
   without-default cell the brief explicitly asked for was **never measured**. The
   arm is relabelled in place. The verifier then BUILT the missing cell: golden
   gives `class gnodef51 #(type KEYND); int nodef_pool[KEYND];` **no index
   typespec**, same as with a default — **so the law survives** — but OUR side is
   structurally unmeasurable there, because we emit **no properties at all** for a
   defaultless generic class (`grep -c nodef_ctl` = 0 in ours, 13 in golden).
   PRE-EXISTING at 01967cb and patch-neutral, but it is a real hole: a generic
   class with no type-parameter default produces an empty body on our side.
2. **R3 is NOT "the same lambda, two more call sites".** `tpSizeRange51` hardcodes
   `"::"` for the `ref_obj` `vpiFullName`, which is right at the CLASS and PACKAGE
   sites but **WRONG at the module-instance site**, where golden spells
   `work@a3_top.u1.p_tp.MK` with a **DOT**. That is the container-kind joiner rule
   already established twice (pass-49 §3, pass-50 R3): `.` for `module_inst`, `::`
   for package and class. Not cmp-visible, but R3's depth is "shallow **plus the
   joiner rule**", not "shallow".
3. **A cited command does not produce its claim.** `a2/dut.sv:4` says the five
   copies of the associative-index rule are found with `grep -n sharedAliasTs src/`
   — that returns 17 hits and is the wrong symbol entirely. The copies are located
   by their own law tags: `§ assocIdxSiteFour43` (src/TypeEmit.cpp),
   `§ assocIdxSiteFive44` (src/ParamEmit.cpp), `§ assocIoRange9`
   (src/TaskFuncEmit.cpp) — all three verified present.
4. **Copy numbering collides with the in-tree comments.** This README calls
   TaskFuncEmit's copy "a FOURTH copy" while the code already names TypeEmit the
   FOURTH and ParamEmit the FIFTH AND LAST. Read it as "the remaining copy".
5. `heads.sh`'s header claims it runs "for every UVM-4 database"; it iterates the
   ENTIRE workdir (953 measured / 620 skipped in the verifier's run). Harmless, but
   it understates the cost.
6. `bvcompare.sh`'s `[NOT EVIDENCE]` label on Scoreboard is still misleading —
   pass 50's integration already flagged this. Scoreboard is BOTH a target AND
   known-nondeterministic; the label should say so.
7. **A CORRECTION TO THE MASTER'S OWN BRIEF.** The id+line-normalised md5
   `75752698` I quoted for the seven rows does NOT reproduce under the verifier's
   normalisation, which gives `4d4087f2…`. Both of us independently confirmed the
   thing that MATTERS — that all seven rows share ONE value — so the INVARIANT
   holds and only the printed value is instrument-dependent. **Never re-quote a
   normalised md5 across instruments; quote the equality, not the number.**
   Likewise the head object ids in that brief (`52802/52799/52801`) are RUN-LOCAL —
   the verifier saw `49922/49919/49921` for the identical shape. Do not re-quote
   ids either.

**Citations the verifier checked and found EXACT**, recorded so nobody re-checks:
`array_var.cpp:128`/`:134`, `variables.cpp:251`, the `uvm_pool::pool` and
`uvm_hdl_force_time` dump lines, the 6911 bind count, uvm-1.2 `uvm_pool.svh:35/42/86/87`
and the column arithmetic (`KEY` = 42:20-22, `key` = 86:31-33), and BuildUVMPkg's
26247 correctly kept as 1800.2-2017-1.0 with no UVM-version mix-up. All four
drivers carry the `sed '1d'` fix, no +2 bias survives, no hard-coded worktree
paths, and every cited asset exists.

**One figure reported as UNREPRODUCED, not disputed:** the middle row of the
15 -> 180 -> 29 trajectory. The verifier did not build a law-1-only binary. The
trajectory is consistent with everything else measured (`array_var::Compare` reads
both `vpiArrayType` and `vpiRange`, and the law-1-only-equivalent module site is
180 cmp lines today), but that one number rests on the implementer alone.
