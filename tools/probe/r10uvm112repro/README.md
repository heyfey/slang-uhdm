# r10uvm112 — § `classTdCloneSpecOverridesOwnArgs112` — **THE SeqDriver `type_id::T` HEAD**

## 0. The head, re-measured on this pass's own pristine build

`rowheads.sh` at `d4d4642`, my own frozen pristine binary, SeqDriver **32 cmp
lines / 1 head, both modes** — byte-identical to the master's head log.

```
LHS:  class_typespec: (adpcm_driver),    line:468:35, endln:468:65
      |vpiParent: \_ref_typespec:  (adpcm_pkg::adpcm_sequencer::type_id::T)
      |vpiName:adpcm_driver
      |vpiClassDefn: \_class_defn: (adpcm_pkg::adpcm_driver)      testbench.sv:77
RHS:  class_typespec: (adpcm_sequencer), line:468:35, endln:468:59
      |vpiParent: \_type_parameter: (adpcm_pkg::adpcm_sequencer::type_id::T)
      |vpiName:adpcm_sequencer
      |vpiClassDefn: \_class_defn: (adpcm_pkg::adpcm_sequencer)   testbench.sv:122
```

`class_typespec::Compare` reads `VpiName` (through the basetype chain) and
`Class_defn`; it never reads `VpiParent`, `VpiFullName` or the span. So the
head is **one field**: which class `T` is bound to. The `ref_typespec` /
`type_parameter` parent difference and the `:65` / `:59` end columns are
NOT what the judge stopped on.

## 1. What the head is NOT: the macro-location hypothesis, REFUTED

The brief's leading hypothesis was a macro-expansion-location cache — every
expansion of `uvm_object_defines.svh:468` sharing ONE typespec, first-writer-
wins keyed by `file:line:col`. Three measurements make that story *fit*
SeqDriver:

* golden has **exactly one** name per macro line — `adpcm_driver` ×42 at
  `468:35-468:65`, `adpcm_seq_item` ×202 at `440:31-440:65` — where we mint
  three and two;
* the macro users are `uvm_component_utils` at testbench.sv:79/124/174 and
  `uvm_object_utils` at :25/:139, and golden's choice is the FIRST of each
  in file order;
* the golden span decodes exactly: `468:65 − 468:35 = 30 =
  len("#(adpcm_driver,\"adpcm_driver\")")`, i.e. the *driver's* expansion text
  with `` `"S`" `` stringified. Ours is `21 =
  len("#(adpcm_driver,`\"S`\")")` — S left unexpanded (that is uvm104's
  macro-stringification span residue, span-only, not compared).

**It is still wrong.** `MiniAmiq` refutes it in one cell. Golden binds
`svaunit_pkg::svaunit_sequence_test::type_id::T` to `svaunit_base` at
`@468:35-468:65`, while our own emission for that same typedef sits at
`@483:35-483:70`. Those are **two different macros** in
`uvm-1.2/src/macros/uvm_object_defines.svh`:

* `467` `` `define m_uvm_component_registry_internal(T,S) `` — body on 468
* `483` `` `define m_uvm_component_registry_param(T) `` — body on 484,
  `typedef uvm_component_registry #(T) type_id;`

Golden puts a `m_uvm_component_registry_param` expansion in the SAME group as
the `m_uvm_component_registry_internal` expansions. A key made of the macro's
`file:line:col` cannot do that. What both macros share is the class they
specialize — `uvm_component_registry`.

Arms `a6`/`a7`/`a9` kill the hypothesis outright: they contain **no macros at
all** and reproduce the identical collapse.

The macro is a red herring — grid cell `b12` of the parent law already said so
("typedef produced by a MACRO … macro IRRELEVANT").

## 2. The real law, and it was already half-written in this tree

`§ classTdSpecParamsForeignHome1` (`src/UhdmExporter.cpp`,
`emitClassTdSpecParams1` / `copyClassTdSpecParams1`) already models Surelog's
typedef **clone** mechanism, and its own header comment names this very head:

> a clone carries the BASE's specialization and NOT the one its own `#(...)`
> text would produce … all 60 UVM `type_id` / `this_type` clones bind T to
> `adpcm_seq_item` / `adpcm_driver`.

That is why ~57 of SeqDriver's 60 `type_id::T` cells ALREADY agree with golden.
The three that do not are the ones the clone half **refused**:

```cpp
if (!dst || !base || dst == base || dst->Parameters() || !base->Parameters())
    return;                              //          ^^^^^^^^^^^^^^^^^^ the gap
```

with the call site reasoning
"*a clone whose own gate already fired keeps what it has … which is the b22
base/base case where both members' own text agrees anyway*".

**That reasoning is false whenever a group's members specialize the same
foreign generic with DIFFERENT arguments** — precisely what the two
`uvm_*_registry` groups do.

### Surelog, verbatim

`src/DesignCompile/ElaborationStep.cpp:194-201`:

```cpp
} else if (typespec* tps = def->getTypespec()) {
  ElaboratorContext elaboratorContext(&s, false, true);
  tpclone = (typespec*)UHDM::clone_tree((any*)tps, &elaboratorContext);
  ref_typespec* rt = s.MakeRef_typespec();
  rt->VpiParent(tpclone);
  rt->Actual_typespec(tps);
  tpclone->Typedef_alias(rt);
}
```

`clone_tree` of the BASE is **unconditional**. The clone's own
`Parameter_value_assignment` is never compiled; `compileDatastructureTypespec`
is not reached for it at all. **The clone half is TOTAL** — that is the whole
law of this pass.

### The group, and its base

Unchanged from `§ classNestedClassTdGroupNoAnchor54` and re-confirmed here:

* the group key is the **TARGET generic class** (`uvm_component_registry`,
  `uvm_object_registry`) — never the typedef's name, never the macro line;
* the base is the member whose declaring class's Surelog design-map key
  (`<pkg>::<cls>`) sorts **first by ASCII**, tie-broken by the typedef name.

For SeqDriver: `adpcm_pkg::adpcm_driver` < `adpcm_pkg::adpcm_sequencer` <
`adpcm_pkg::adpcm_test` < `uvm_pkg::…` ⇒ base `adpcm_driver`; and
`adpcm_pkg::adpcm_seq_item` < `adpcm_pkg::adpcm_tx_seq` ⇒ base
`adpcm_seq_item`. Both match golden.

## 3. The change

`copyClassTdSpecParams1` gains `overwrite1`; the no-anchor clone loop in
`drainClassNestedTdGroups54` passes `true`. Nothing else moves: the base
itself, every copy of the base's own declaration, and any member that already
carried an alias are all skipped **before** the call, and the second call site
(`copyClassTdSpecParams1(cts, bts50)`, the package-anchored clone) keeps the
refusing default.

## 4. Arms — the golden grid (`run112.sh`, `score112.py`, both views)

LHS is always golden. `score112.py` is span-free and order-blind (a SET of
actual names per `type_parameter` fullname), so a byte-order flip cannot score.

| arm | shape | golden | pristine | tests the law? |
|---|---|---|---|---|
| `a6_sortbase.sv` | 3 class tds of ONE foreign generic, source order `zeta6, alpha6, Mid6`, ASCII key order `Mid6 < alpha6 < zeta6` | all three `Q = Mid6` | `alpha6`, `zeta6` keep their own | **YES** — 2 DIFF |
| `a7_twogroups.sv` | TWO foreign generics interleaved, 5 tds | group P → `Ba7`, group Q → `Cq7` | 3 keep their own | **YES** — 3 DIFF |
| `a9_diffnames.sv` | one generic, **different typedef names** `first_id9`/`second_id9` | both `Q = Kb9` | `ra9` keeps its own | **YES** — 1 DIFF |
| `a10_sameargs.sv` | one generic, **same** argument twice | ONE object `@11:20` x6 | TWO objects, `@11:20` and `@14:20` | **YES, and it surprised me** — see below |
| `sub5/` (3 files) | the group's members in TWO packages and TWO FILES, target in a third | `qq5`'s Q = `Nn5` | `qq5` keeps its own | **YES** — 1 DIFF; the group spans FILES and PACKAGES |
| `a8_single.sv` | group of ONE declaration | `solo8` | `solo8` | control — no base, 0 DIFF |
| `a1_macroline.sv` | one macro line ×3, OWN-package target | agree | agree | inert (own-package ⇒ probe hits ⇒ no specialization) |
| `a2_twomacros.sv` | two macro lines interleaved ×5, own-package | agree | agree | inert, same reason |
| `a3_generic.sv` | generic body specialized twice (no macro) | no specialization either side | — | inert — cell `b19` territory (`namesAParamOf1` refuses) |
| `a4_control.sv` | two hand-written tds, own package | agree | agree | inert |

`a6` is the load-bearing one: **source order, lowercase-alphabetical order and
case are all separated**, and golden picks the ASCII-first key `Mid6` — not the
source-first `zeta6`. Source order and case-insensitive order are REFUTED.

`a9` proves the group key is the target generic class and NOT the typedef name.
`sub5/` is the SUBDIRECTORY arm (compiled as three sources, `-I` on the
subdir): it proves the group is DESIGN-WIDE — a clone in `pk5u2`, in its own
file, takes the base from `pk5u1` in another file.

`a10` was written as a NAME-neutral control ("both members already name
`shared10`, so the overwrite must be a no-op") and it is not one. Golden has
**one** `shared10` typespec, at the BASE's span `11:20-11:42`, referenced six
times. Pristine has **two** — the clone kept an object of its own at its own
text `14:20-14:42`. After the patch we have one, at `11:20`, like golden. So
the refusal was wrong even where the NAME agreed: it left a duplicate object
wearing the clone's own span. The name was never the whole of it. (This is
span/identity only — neither is read by `Compare` — so it does not change any
row, but it does mean the control is a POSITIVE cell, and the README says so
rather than keeping the tidier claim.)

After the patch **every arm scores DIFF=0 against golden in BOTH views**
(`a6` 2->0, `a7` 3->0, `a9` 1->0, `sub5` 1->0; the controls `a8`/`a10` and the
inert `a1`-`a4` are unchanged at 0).

The `ONLY-GOLDEN` / `ONLY-OURS` rows every arm shows are the base object's
**synthesized fullname** (`pk6use::pk6use::tid6::Q` vs
`pk6use::Mid6::pk6use::tid6::Q`) — a pre-existing PARENTING residue, and
`VpiFullName` is not read by any generated `Compare`. Disclosed, not touched.

## 5. Prediction, a priori, from PRISTINE databases only

`pred112.py` reads a pristine `uhdm-dump` and names every cell that must move:
a `class_typespec` that carries a `|vpiTypedefAlias` (⇒ it is a clone) **and**
its own `|vpiParameter` whose actual name differs from the base's. Because
`uhdm-dump` prints a back-referenced object shallow, the base's bindings come
from a global index keyed on (paren-text, span), taking the richest occurrence.

Predicted movers, **13 cells, all in the UVM family**:

```
SeqDriver   adpcm_sequencer::type_id  T  adpcm_sequencer -> adpcm_driver
SeqDriver   adpcm_test::type_id       T  adpcm_test      -> adpcm_driver
SeqDriver   adpcm_tx_seq::type_id     T  adpcm_tx_seq    -> adpcm_seq_item
MiniAmiq    svaunit_concurrent_assertion_details -> svaunit_base_sequence
MiniAmiq    svaunit_concurrent_assertion_info    -> svaunit_base_sequence
MiniAmiq    svaunit_immediate_assertion_details  -> svaunit_base_sequence
MiniAmiq    svaunit_immediate_assertion_info     -> svaunit_base_sequence
MiniAmiq    svaunit_reporter                     -> svaunit_base_sequence
MiniAmiq    svaunit_vpi_wrapper                  -> svaunit_base_sequence
MiniAmiq    svaunit_sequence_test                -> svaunit_base
MiniAmiq    svaunit_sequencer                    -> svaunit_base
MiniAmiq    svaunit_test                         -> svaunit_base
MiniAmiq    svaunit_test_suite                   -> svaunit_base
```

SimpleUVM, Scoreboard and BuildUVMPkg predict **0**.

Every one of the 13 was checked against its own golden dump before the patch
was built: **TO-GOLDEN 13, AWAY-GOLDEN 0, STILL-WRONG 0**.

Corpus screen, pristine databases only:

* **uhdm2rtlil — all 1358 rows dumped and screened: 0 predicted movers.**
  (76 rows carry a `Typedef_alias` at all; none has a clone with its own
  differing specialization.)
* **Surelog — all 956 pristine databases screened to completion**
  (`screen_sl.sh`, output in `SCREEN.sl.txt`): the ONLY hits are `SeqDriver`
  (3 cells) and `MiniAmiq` (10 cells), in BOTH modes — 4 database-modes,
  26 `PREDICT` lines, nothing else in the corpus.

Two fully independent instruments agree cell for cell: this predictor, which
reads PRISTINE databases only and never sees the patched side, and the patched
sweep's `byteverify`, which compares actual database BYTES and reports
**MOVERS 4 / 956** — the same four database-modes.

## 6. Gates

Two frozen binaries, `chmod 555`, every `cmds.txt` audited by BINARY PATH:

| | md5 |
|---|---|
| pristine (`d4d4642`) | `af17c942bc7afeaaf6a78678eadcafcd` |
| patched | `231b37ef82337f352d35919add9a9a10` |

* **goldens** — pristine 23 PASS / 0 FAIL; patched 23 PASS / 0 FAIL;
  negative control `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
* **uhdm2rtlil** — patched `testflags` 679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL, `default` identical. `ct8rows` PASS against BOTH the pass's
  own pristine control AND `results/gate_uhdm2rtlil.csv` (status AND dump).
  `SELFCHECK=1 byteverify` **MOVERS 0 / 1358**, `PATH_SETS_IDENTICAL`,
  selfcheck 1357/1358 flagged (the detector demonstrably sees).
  All 1458 `cmds.txt` name `ship112.bin`.
* **Surelog** — see §7.
* **canaudit** — `bash canaudit.sh canaries.sh ctcan2.sh`: audited 29,
  UNCOVERED 0, FENCE-BREACH 0. The four slang-fenced tests are dispatched by
  no driver in this directory and are named nowhere in these artifacts except
  that audit's own assertion list.

## 7. Residues, and what this pass does NOT fix

1. **The `type_id` span is still ours, not golden's.** Golden's shared object
   spans the FIRST expansion's fully-stringified text
   (`#(adpcm_driver,"adpcm_driver")`, 30 chars, `468:35-468:65`); ours spans
   `#(adpcm_driver,` + an unexpanded `` `"S`" `` (21 chars, `468:35-468:56`).
   That is uvm104's macro-stringification residue. **No generated `Compare`
   reads a span**, so it is invisible to the judge — disclosed, not chased.
2. **The base object's synthesized `vpiFullName` differs**
   (`pk6use::pk6use::tid6::Q` golden vs `pk6use::Mid6::pk6use::tid6::Q` ours;
   `work@top_tb.adpcm_pkg::type_id.T` vs
   `adpcm_pkg::adpcm_driver::adpcm_pkg::type_id::T`). `VpiFullName` is
   dump-only and never compared. It is a PARENTING residue, not a naming one.
3. **Golden emits an extra `type_parameter` per group carrying the GENERIC
   class's own default** (`uvm_object` `@189:36-189:46`, `uvm_component`
   `@51:39-51:52`) that we do not emit at all. Present in every `type_id::T`
   census row; a separate missing-object family, untouched here.
4. Arms `a1`–`a4` are **inert** for this law and are kept as documentation of
   which shapes carry no specialization at all (own-package target ⇒ Surelog's
   `getClassDefinition` probes hit ⇒ bare `class_typespec`; and a generic body
   whose argument names its own type parameter ⇒ cell `b19`).

## 8. Boundary — and two earlier-pass arms that move

`bnd112.sh`, per-file half, from a COPY of `tools/probe`, no path filter,
both views: **LISTED 3486, PROCESSED 3486, RC_DIFF 0, ASYM 0, MOVED 28**,
`PROCESSED-ASSERT-OK`. The 28 are 14 files x 2 views; full accounting in
`BOUNDARY.txt`. Twelve are this pass's own arms (four, plus Surelog's own
`slpp_all/lib/work/` copies of them). The other two are EARLIER-PASS arms, and
the rule is that each must be re-measured against golden and must move toward
it. Both do:

* **`r10sd1repro/grid/b22_foreign_two.sv`** — the very cell the struck comment
  cited. `pb::wb::tidb::T` goes `wb` -> `ub`; golden's set is `{baseb, ub}`.
  TO-GOLDEN 1, AWAY 0, both views. The parent law's README *already* said
  "cell b22's `pb::wb::tidb` binds T to `ub`" — golden was documented right and
  the emitter simply never delivered it, because of the refusal.
* **`r10uvm54repro/a1/dut.sv`** — THREE cells, and their actuals are UNNAMED
  BUILTIN typespecs, not class ones:

  | cell | pristine | patched | golden |
  |---|---|---|---|
  | `r54::b_owner54::td_aaa54::T` | `int @71:18` | `byte @77:18` | `byte @77:18-77:22` |
  | `r54::c_owner54::t_bbb54::T` | `int @83:18` | `short_int @84:18` | `short_int @84:18-84:26` |
  | `zbb54::aa54::n_z54::T` | `byte @98:18` | `int @91:18` | `int @91:18-91:21` |

  All three land on golden exactly, kind AND span, where pristine had all three
  wrong. **`VpiType` is the first field every generated `Compare` reads**, so
  these are judge-visible cells — four extra correct cells (b22 + these three)
  that no corpus row exercises. It also shows the law is **not class-specific**:
  it governs any type-parameter actual a clone carries.

The per-DIRECTORY half (`MODE=dir`, LISTED 1523, PROCESSED 1523, RC_DIFF 0,
ASYM 0, MOVED 27) adds four directories — `r10uvm75repro`, `r10uvm76repro`,
`r10uvm88repro`, `r10v109repro` — whose cells all report **`sorted=0`**: the
two dumps are identical as MULTISETS and only the emission ORDER differs. That
is the documented per-run nondeterminism, not a content change; re-running
`r10uvm75repro` / `r10uvm76repro` by hand gives byte-identical pristine and
patched dumps, and `r10uvm88repro`'s whole difference is a two-line
`vpiTaskFunc` order flip. Attributing order-blind is what separates them from
`r10uvm54repro/a1`, whose `sorted=18 / 129` is a real move onto golden.

### A limitation of `pred112.py`, stated plainly

The predictor I ran corpus-wide identified a typespec by its parenthesised
NAME, so it saw only CLASS actuals and would have missed the `uvm54` cells had
a corpus row had them. It has since been extended to identify an actual by
(kind, name-or-span) and re-run: it names the `uvm54` three and `b22`'s one
exactly, and still finds **exactly 13** in the UVM databases — no additional
non-class cells anywhere in the corpus. The corpus-wide authority is not the
predictor in any case but `byteverify`: **4 movers / 956 databases**, so the
952 untouched databases provably contain no moved cell of any kind.
It still cannot see `a10`'s move (both sides name `shared10`; only the object
identity and span change) — that class of move is judge-invisible by
construction.

## 9. Result

### The head cleared

`SeqDriver` **32 -> 62 cmp lines, both modes, and the head OBJECT CHANGED.**
The `class_typespec (adpcm_driver) / (adpcm_sequencer)` head is gone; the new
62-line head is a different family entirely — a `range` bound at
`SeqDriver/testbench.sv:105:15` where golden folds `32-1` to `constant 31`
(`vpiConstType:7`) and we keep the unfolded `operation vpiOpType:11` over
`32` and `1`. That is the WRITTEN `-1` FOLD, the family sister pass **buvm30**
owns. A rising line count is the new head object's decompile size, not a
partial fix.

Every other head is **byte-identical** before and after:
`MiniAmiq` 348 (both modes), `SimpleUVM` 42 (both), `Scoreboard/default` 42,
`BuildUVMPkg` 42 (both), `Earlgrey_0_1` 36 (both), `Rggen/default` 0.
MiniAmiq's ten cells sat BEHIND its head, so its family moved without its head
moving.

### The cells

Order-blind, span-free, name-containment scoring of the moved databases
(`tg112.py`, golden vs pristine vs patched):

| database | TO-GOLDEN | AWAY-GOLDEN | STILL-WRONG | STILL-RIGHT |
|---|---|---|---|---|
| SeqDriver | **3** | **0** | **0** | 167 |
| MiniAmiq | **10** | **0** | **0** | 168 |

Exactly the 13 cells predicted a priori, every one toward golden, none away.
The FIRST expansion's `T` — the control — stays right on both sides in both
databases (it is the base; it is never touched).

### Rows

**No conversions and no regressions.** The Surelog status histogram is
IDENTICAL to pristine, cell for cell: 471/466 CMP_EQUAL, 10 default +
9 testflags CMP_NOTEQUAL, 283/284 SLANG_REJECT, 25/23 SURELOG_FAIL, 5/5
DEFERRED, 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM.
`ct8rows` PASS over all 1588 rows against BOTH the committed
`results/golden_surelog.csv` and this pass's own pristine control.
`results/*.csv` was not touched.

The 13 cells are all BEHIND their databases' heads except SeqDriver's three,
so the family moves without any row changing status — this is groundwork that
clears one head and shrinks two families.

## 10. R0 — the next head

`SeqDriver`'s new head, both modes, 62 lines, is the **written `-1` fold**:

```
LHS  constant: @105:15-105:17  |vpiDecompile:31 |INT:31 |vpiConstType:7
     parent \_range: @105:14-105:22
RHS  operation: @105:15-105:19 |vpiOpType:11 (subtraction)
     operand \_constant: |vpiDecompile:32 |UINT:32 |vpiConstType:9
     operand \_constant: |vpiDecompile:1  |UINT:1  |vpiConstType:9
```

at `Surelog/third_party/tests/SeqDriver/testbench.sv:105`, a `[32-1:0]` range
bound golden folds to `31` and we leave written. That family is **already
owned by sister pass `buvm30`** (heads SimpleUVM / Scoreboard / BuildUVMPkg) —
SeqDriver now joins its row list rather than needing a new pass. Note the
folded constant is `vpiConstType:7` (INT) against our `9` (UINT), and
`vpiSize:64` on both sides.

Secondary residues, in the order they will bite (all measured in §7):
1. the macro-stringification SPAN on the shared `type_id` actual (uvm104);
2. the missing per-group `type_parameter` carrying the GENERIC class's own
   default (`uvm_object` / `uvm_component`), present in every golden
   `type_id::T` row and absent from ours;
3. the base object's synthesized `vpiFullName` (a PARENTING residue).

None of the three is read by any generated `Compare`, so none can be a head on
its own — (2) is the only one that could become one, since a missing object
IS comparable when it is reachable.
