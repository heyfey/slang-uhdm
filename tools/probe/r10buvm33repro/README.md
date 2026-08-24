# r10buvm33 — § foreachScopedArrayWrittenClassVar33

**The head.**  `foreach (this_type::m_typewide_sequences[i])` — the header of
`uvm_sequence_library::init_sequence_library`
(`UVM/uvm-1.2/src/seq/uvm_sequence_library.svh:496`, `pp_output/uvm_pkg.sv:56591`)
— was the first object the official `uhdm-cmp` disagreed on for **four
row-modes** at base `7fcedfe`: SeqDriver default+testflags and BuildUVMPkg
default+testflags, all four at 56 cmp lines.  It is the object
§ classScopeCallWrittenQualifierIsLookupKey32 uncovered when it cleared the
`this_type::add_typewide_sequence` CALL one line above it.

```
LHS (golden)  class_var  (…::init_sequence_library::this_type::m_typewide_sequences)
              line 496:12-496:23   vpiParent -> foreach_stmt
              vpiName:this_type::m_typewide_sequences
              vpiTypespec -> ref_typespec -> unsupported_typespec
                             (this_type::m_typewide_sequences) @496:12-496:23
RHS (ours)    ref_var    (…::init_sequence_library::m_typewide_sequences)
              line 496:12-496:32
              vpiName:m_typewide_sequences
              vpiTypespec -> ref_typespec -> unsupported_typespec
                             (m_typewide_sequences) @496:12-496:32
```

Re-measured on this worktree's own pristine build before any code was written
(`rowheads.sh` on the pristine sweep) — the same object, byte for byte.

---

## 1. The decoded law

> A `foreach` whose ARRAY REFERENCE is WRITTEN with a `::` scope is a
> **`class_var`** named `<first written segment>::<final identifier>`,
> spanning the scoped name's start up to the column the FINAL identifier
> starts at, over an **`unsupported_typespec`** of the SAME name and the SAME
> span.  The written text is the whole rule: no lookup, no registration key,
> no resolution.

**Surelog, line by line.**

* `CompileStmt.cpp:527` (`VObjectType::paFOREACH`) hands the loop list's
  `Ps_or_hierarchical_array_identifier` CHILD to **`compileVariable`** — the
  DECLARATION producer.  That is the whole difference from every other
  position a `::`-scoped data reference can take: an indexed read, an
  assignment Lhs or Rhs, a call argument and a method receiver all go to
  `compileExpression`, which is § staticScopedRef12's `ref_obj` and which we
  already match.
* `CompileType.cpp:554` — `compileVariable`'s `paClass_scope` arm reads
  `packageName = SymName(Child(Child(variable)))` (the FIRST written segment)
  and `typeName = SymName(Sibling(variable))` (the FINAL identifier), so
  `p33::der33::dq33` becomes `p33::dq33`: **every intermediate segment is
  dropped**.  It then tries `design->getPackage(packageName)->getDataType(
  typeName)` and `design->getClassDefinition({"", component, parent} +
  packageName)->getDataType(typeName)`, and ONLY a hit replaces the object
  kind.
* `CompileHelper.cpp:160/168/636` are the only callers of `insertDataType`,
  and they register **TYPEDEFS and CLASS DEFINITIONS — never a variable**.  So
  for an ARRAY reference both lookups miss BY CONSTRUCTION and `:614` runs

  ```cpp
  const std::string completeName = StrCat(packageName, "::", typeName);
  if (var == nullptr) var = s.MakeClass_var();
  var->VpiName(completeName);
  ```

  `class_var` is the DEFAULT, not a decision.
* the tail at `CompileType.cpp:658` stamps `populateCoreMembers(declarationId,
  declarationId, result)` — the `paClass_scope` node's OWN extent, which ends
  where the final identifier begins.  Same rule buvm32 measured on the CALL
  face; here it is stamped, not inferred.
* the typespec is `compileTypespec(component, fC, declarationId)`, whose own
  `paClass_scope` arm (`CompileType.cpp:1518`) builds the same two-segment
  `typeName` and falls through at `:1618` to an `unsupported_typespec` named
  it, at the same node's extent.
* **the ONE escape** (`CompileType.cpp:1573-1590`): before falling through,
  that arm asks `design->getPackage(<first segment>)`, and if the package owns
  a PARAMETER of the final name its `getParam_assigns()` scan answers a BARE
  `int_typespec` — no name, no span, no value (an unpacked-array parameter's
  `param_assign` Rhs carries none).  Cell `g33a2` S8, read off golden.

**THIS IS NOT § classScopeCallWrittenQualifierIsLookupKey32.**  On the CALL
face the written qualifier is a LOOKUP KEY and a registered spelling KEEPS its
`func_call`; buvm32's verifier had to widen that key to package free
functions, `$unit` and imported classes.  Here there is no lookup to key:
golden gives `class_var` for `this_type::`, for an alias, for the class's OWN
written name, for its BASE's name, for another class's name, for a real
PACKAGE qualifier over a package variable, for a `$unit` class, for a
wildcard-imported class, for an ESCAPED identifier, for a PARAMETERIZED
qualifier and for three-segment `pkg::Class::` alike — **sixteen spellings,
one answer** (§2).  § scopedCallKeyIsAnyRegistration32v is therefore
deliberately NOT asked on this face, and this pass does not touch it.

**Our bug.**  The foreach arm (`StmtEmit.cpp`, § foreachLoopVarObjs9's mint)
read `arrSym->name` — the LEAF, resolved through slang, which sees straight
through the `this_type` typedef — and spanned `nameSpan(start, leaf)`.  The
fix reads the WRITTEN syntax instead (`foreachScopedArrayName33`), and when it
is a `::` scope emits golden's four fields.  The UNQUALIFIED spelling is
untouched: it has no `paClass_scope` node, takes `compileVariable`'s
`slStringConst` arm, and is the `ref_var` we already emit.

---

## 2. The purpose-built grid (three arms, both views, read cell by cell)

`gridcmp33.py` reads every `foreach` header of an arm on all three sides —
golden, the PRISTINE binary, the PATCHED one — and votes SAME / FIXED /
RESIDUE / **BROKEN** (pristine-right, patched-wrong: the number that must be
zero).

| arm | view | FIXED | SAME | RESIDUE | **BROKEN** |
|---|---|---|---|---|---|
| `g33a1` | def / elab | 15 / 15 | 5 / 5 | 0 / 0 | **0 / 0** |
| `g33a2` | def / elab | 11 / 11 | 3 / 3 | 2 / 2 | **0 / 0** |
| `g33a3` | def / elab | 7 / 7 | 2 / 2 | 1 / 1 | **0 / 0** |

`g33a1.sv` — qualifier spelling x home x position:

| cell | written | golden | ours (pristine) |
|---|---|---|---|
| A1 | `foreach (this_type::dq33[i])` out-of-body home | **`class_var 'this_type::dq33'` 58:14-58:25** + uts | `ref_var 'dq33'` 58:14-58:18 |
| A2 | `der33::dq33` — the class's OWN written name | **`class_var 'der33::dq33'`** | `ref_var 'dq33'` |
| A3 | `alias33::oq33` — a typedef to ANOTHER class | **`class_var 'alias33::oq33'`** | `ref_var 'oq33'` |
| A4 | `other33::oq33` — another class by name | **`class_var`** | `ref_var` |
| A5 | `base33::bq33` — the BASE class by name | **`class_var`** | `ref_var` |
| A6/A7 | `dq33` / `inst33` — UNQUALIFIED controls | `ref_var` | same |
| A8-A13 | the SAME `this_type::dq33` as an indexed Rhs, an indexed Lhs, a `$display` argument, a method argument and a method receiver | `ref_obj`, unchanged | **already right** |
| B1-B7 | the whole set again from an IN-BODY method, plus `foreach (this_type::da33[i,j])` | identical split | |
| P1/P2 | from a PACKAGE FUNCTION: `der33::dq33`, `p33::pv33` (a real package over a package VARIABLE) | **`class_var`** both | `ref_var` |
| M1 | `p33::der33::dq33` from a MODULE | **`class_var 'p33::dq33'` 88:14-88:26** | `ref_var 'dq33'` |

**A2 and P2 are the cells that separate this law from buvm32's.**  `der33` IS
the defining class's written name and `p33` IS a registered package — the two
spellings the CALL face KEEPS — and golden degrades both here.  A8-A13 are the
other half of the same statement and are `ref_obj` on both sides before and
after: the split is the PRODUCER (`compileVariable` vs `compileExpression`),
not the position.

`g33a2.sv` — the interactions: `S1`/`S2` a scoped and a bare foreach with a
select-assignment of the same array armed in an ancestor block
(§ foreachArraySelfSelectAssignDropsTs19 — golden keeps the scoped cell's
`unsupported_typespec` in BOTH views, so the scoped arm is taken FIRST in the
code); `S3` an ASSOC array; `S4` a `$unit` class qualifier; `S5` a
WILDCARD-IMPORTED class; `S6` `pkg::Class::prop`; `S7` a package VARIABLE;
**`S8` a package PARAMETER array — golden's `class_var 'q33::QP33'` over a
BARE `int_typespec`**, the one escape §1 names; `G1`/`G2` a GENERIC class with
its own `typedef gen33 #(T,W) this_type`; `N1`/`N2`/`N3` the NEGATIVE controls
(`this.inst33` -> typespec-less `ref_var`, `peer33.inst33` -> `hier_path`,
bare -> `ref_var`), none of which may be caught — the helper matches only a
`DoubleColon` separator; `T1`/`T2` the same from a MODULE.

`g33a3.sv` — homes and token shapes: an INTERFACE function, a PROGRAM, a
module TASK and an `always` block in a module with TWO generate instances
(`R2` `s33::cell33::cq33` -> `s33::cq33` 35:14-35:27), an **ESCAPED**
qualifier (`\esc33 ::eq33` -> `esc33::eq33`), a **PARAMETERIZED** qualifier
(`par33#(2)::pq33` -> `par33::pq33` 66:14-66:25 — the parameter list is not
part of the name but IS part of the span) and `s33::par33#(2)::pq33` ->
`s33::pq33` 68:14-68:30.

**Span rule, measured on 16 cells:** golden's span ends at the COLUMN THE
FINAL IDENTIFIER STARTS AT, whatever the segment count and whatever is written
in between — `this_type::` is 11 characters from column 12, so `496:12-496:23`;
`p33::der33::` is 12 from 14, so `88:14-88:26`; `s33::par33#(2)::` is 16 from
14, so `68:14-68:30`.  Ours ended at `start + len(leaf)`, which is the span of
a DIFFERENT token.

**Order-blind whole-dump residue keys** (`msdiff33.py`, arena ids and paths
normalised, golden vs ours): `g33a1` def 166 -> 44, elab 337 -> 236; `g33a2`
def 238 -> 141, elab 368 -> 282; `g33a3` def 129 -> 65, elab 191 -> 133 —
with **NEW residue keys 0** everywhere except the two recorded in §7.

---

## 3. The corpus census (question 1, answered over all 956 databases)

`r10buvm33cen.cpp` enumerates two families by the SAME rule on both sides, so
the join is symmetric and neither producer's vocabulary decides the key:

* **`FEHDR`** — one row per `foreach_stmt` with the object under
  `vpiVariables` (kind, VpiName, span) and its ACTUAL typespec, marked
  `scoped=Y` when that name carries a `::`.
* **`SDREF`** — every DATA reference whose VpiName carries a `::`
  (`ref_obj` / `ref_var` / any `variables` / `hier_path` / `bit_select` /
  `part_select` / `indexed_part_select` / `var_select`), with its parent kind
  as POS, its nearest function / task / class_defn / package / module_inst as
  HOME, and REACH.  Call objects are excluded — that is buvm32's `SCALL`
  census.

`sweepcen33.sh` ran it over BOTH sides of every cell of the pristine AND the
patched surelog workdirs (956 databases x 2 modes; 617 cells have a missing
side and are COUNTED, not skipped) and of both uhdm2rtlil workdirs (1358
cells).  `cen33.py` joins as a MULTISET; the FEHDR key deliberately EXCLUDES
the array reference's name, because the name is exactly what the two producers
disagree about and a name in the key would hide every disagreement as a
MISSING/EXTRA pair.

```
                              pristine        patched
FEHDR  IDENTICAL                 8040           8066     (+26)
       PAIRED-DISAGREE           1374           1348     (-26)
       MISSING-OURS / EXTRA-OURS  0 / 0          0 / 0
       scoped=Y  golden / ours    26 / 0         26 / 26
SDREF  IDENTICAL                 9282           9308     (+26)
       MISSING-OURS               205            179     (-26)
       PAIRED-DISAGREE / EXTRA     48 / 167       48 / 167
```

Disagreement KEY SETS compared directly, pristine vs patched:
**FEHDR NEW=0 GONE=26; SDREF NEW=0 GONE=13** (13 distinct rows, 26 cells).
**TO-GOLDEN 26 / AWAY-GOLDEN 0 / STILL-WRONG 0.**

Split by qualifier, position and home, over the whole corpus: the 26 cells are
**ONE written name** — `this_type::m_typewide_sequences` — in **ONE home
shape** (the out-of-body class method `uvm_sequence_library::
init_sequence_library`, written at package scope) and **ONE position** (the
foreach HEADER); each (test, mode, home-package) contributes two cells, the
package's DEF and ELAB copies.  Every other `::`-scoped data reference in the
corpus sits in an EXPRESSION position and already agreed: the only other
`pos=foreach_stmt` rows in 956 databases are BuildUVMPkg's `cbs_type::add` and
`cbs_type::delete` — degraded CALLS in the loop BODY, buvm32's law, present and
IDENTICAL on our side before and after.  uhdm2rtlil has **zero** `scoped=Y`
foreach cells on either side, in either mode.

The qualifier question the brief asks — REGISTERED key or not — is answered
NO for this face: `der33::` (the defining class's own out-of-body name),
`p33::` (a package), `q33::impc33::` (an imported class) and `unitc33::` (a
`$unit` class) are all REGISTERED spellings by buvm32's test, and golden
degrades every one of them here (g33a1 A2/P2/M1, g33a2 S4/S5/S6/S7).

---

## 4. Mover prediction and attribution

`PREDICTION.txt` was written from the PRISTINE databases BEFORE the patched
binary was built: **9 databases, by name** — `{default,testflags} x
{BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM}` plus `default/Scoreboard`
(Scoreboard/testflags has no database), 26 cells; uhdm2rtlil **zero**, both
modes.

Measured: `byteverify.sh SELFCHECK=1` reports **MOVERS 9 / 956** — exactly the
nine predicted names and nothing else (SELFCHECK 955/956, so the instrument can
see) — and **0 / 1358** on uhdm2rtlil.

`movers33.sh` attributed all nine ORDER-BLIND (sorted, id- and
path-normalised dumps — the only sound attribution for `Scoreboard/default`
and `SeqDriver`, which r10vbuvm32's F3 proved are COINS):

```
default/BuildUVMPkg   36   default/SimpleUVM     36   testflags/BuildUVMPkg  36
default/MiniAmiq      72   default/Scoreboard    36   testflags/MiniAmiq     72
default/SeqDriver     72                              testflags/SeqDriver    72
                                                      testflags/SimpleUVM    36
```

468 lines total, and **every one of them mentions `m_typewide_sequences`: 0
unattributed lines in all nine**.  The 72-line rows are the two databases that
compile the UVM library twice (SeqDriver's `adpcm_pkg`, MiniAmiq's
`svaunit_pkg`).  36 lines = 2 cells x 18 lines (the `ref_var` -> `class_var`
kind, the name, the fullname on the var and on its ref_typespec, and the
`unsupported_typespec`'s name and span).

---

## 5. Head movement

`rowheads.sh` on the pristine and patched workdirs of this build:

| row | mode | pristine | patched | head object |
|---|---|---|---|---|
| SeqDriver | default | 56 | 56 | class_var@496:12 **CLEARED** -> int_var `i`@496:44 |
| SeqDriver | testflags | 56 | 56 | same |
| BuildUVMPkg | default | 56 | 56 | class_var@56591:12 **CLEARED** -> int_var `i`@56591:44 |
| BuildUVMPkg | testflags | 56 | 56 | same |
| SimpleUVM | both | 17 | 17 | unchanged (earlier head) |
| Scoreboard | default | 60 | 60 | unchanged |
| MiniAmiq | both | 60 | 60 | unchanged |
| Earlgrey_0_1 | both | 36 | 36 | unchanged |
| Rggen | default | 0 | 0 | still equal |

The four target row-modes' head **cleared**; the line count stayed 56 by
coincidence — RESUME §7: a cmp line count is the HEAD OBJECT's decompile size,
not a distance, and the new head object happens to decompile to the same
number of lines.  The new head is the LOOP VARIABLE of the SAME `foreach`, one
field later in `foreach_stmt::Compare` (`vpiVariables` then `vpiLoopVars`) —
see R0.

---

## 6. Gates (all green, on this worktree's own build)

The master's rotated controls for `7fcedfe` were pruned while this pass ran, so
**every baseline below is this worktree's OWN pristine sweep**, run with the
frozen pristine binary before any edit, plus the COMMITTED `results/*.csv`.

* build both binaries `-j 2`, md5 separately: pristine
  `ae34152a8fddb784814f747eefb923c5`, patched
  `9bb6af0a9bd2a50a7ab4fbb3fe375e2c`; both frozen `chmod 555` before any
  sweep, and every `cmds.txt` audited BY BINARY PATH (not by the string
  `slang-uhdm`, which also matches the golden cache directory): of 1573
  surelog `cmds.txt` **1523 name the frozen binary and 50 name none at all**
  (golden-cache-only cells where slang was never invoked), and of 1462
  uhdm2rtlil `cmds.txt` **1458 name it**.  **Zero cells, in either corpus, in
  either sweep, name the main-tree binary.**
* `tests/check_goldens.sh` with `SLANG_UHDM` exported explicitly to the
  patched binary: **23 PASS / 0 FAIL**; negative control `SLANG_UHDM=/bin/false`:
  **0 PASS / 23 FAIL**.
* uhdm2rtlil testflags AND default: **679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL** in both modes (identical to pristine); `ct8rows.sh`
  **0 differing rows** against the committed `results/gate_uhdm2rtlil.csv`
  AND against this build's own pristine sweep, in BOTH modes, status AND dump
  column.
* surelog `--mode both`, 1588 rows: `937 CMP_EQUAL / 567 SLANG_REJECT /
  48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE /
  2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM` — identical to pristine;
  `ct8rows.sh` **0 differing rows** against the committed
  `results/golden_surelog.csv` and against the pristine sweep.  **NO ROW IS
  CONVERTED** and `results/*.csv` is untouched.
* `byteverify.sh SELFCHECK=1`: **9 / 956** movers (all predicted by name,
  SELFCHECK 955/956) and **0 / 1358** on uhdm2rtlil.
* canaries `ok=52 changed=0 absent=0` / `ok=8 changed=0 absent=0`;
  `EXPECT_UNKNOWN=1` and `EXPECT_UNKNOWN=6` `ctcan2.sh` PASS on both corpora;
  `canaudit.sh canaries.sh ctcan2.sh` run FROM THIS DIRECTORY:
  **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* protected databases by name, md5 vs the pristine sweep: InterfaceModPort,
  BlackParrotComplex, YosysOldOr **SAME** in both modes; SVSwitch
  `4842211c4030`; YosysVerx `6ccda350c24a`.
* boundary gate `bound33.sh` over a COPY of the whole `tools/probe` tree, four
  configurations, PROCESSED == LISTED (3607 / 3607 / 1527 / 1527), no
  asymmetric reject — every differing arm accounted for in `BOUNDARY.txt`,
  including three committed r10vbuvm19 arms whose OWN uhdm-cmp head was this
  law's cell and is now CLEARED.
* the four slang-fenced tests are never dispatched and never spelled here.

---

## 7. Residues and R0

* **R1 — the ESCAPED-qualifier SPAN.**  `foreach (\esc33 ::eq33[i])` (g33a3
  E1): the kind, the name, the fullname and the typespec are golden's, and the
  end COLUMN is 23 against golden's 27.  This is r10vbuvm32's R-V4 — a Surelog
  column artefact on escaped tokens, in the opposite direction — and spans are
  not read by any generated `Compare`.  Pristine was wrong in kind AND name
  AND span here, so nothing regressed.
* **R2 — one dump-traversal print around a package PARAMETER.**  In `g33a2`'s
  ELABORATED view golden prints `\_parameter: (work@top33a2.QP33)` ten times
  and we print it nine.  The `class_var`/`int_typespec` cell itself matches;
  this is a print count in uhdm-dump's parent-chain expansion, on the one
  off-corpus shape (a foreach over a package parameter array).
* **R3 — the `q33::QP33` escape is modelled only for the `int_typespec`
  arm.**  `compileTypespec`'s `paClass_scope` arm can also answer with a
  package TYPEDEF's typespec or a `class_typespec` when the FINAL identifier
  names a type or a class; neither is a legal foreach array, no arm reaches
  them and no corpus cell contains one, so they are not modelled.  Nor is the
  `int_typespec`'s `VpiValue`: Surelog copies it from the `param_assign` Rhs,
  which is empty for every unpacked-array parameter — the only kind a foreach
  can iterate.
* **R4 — `r10vbuvm19repro/vg19e.sv --elabuhdm` SEGFAULTS (rc=139) on BOTH
  binaries**, alone and as a directory.  Pre-existing, symmetric, recorded
  rather than dressed up (RESUME §9: a `rc=139` is how `verify_golden.py`
  manufactures a phantom `SLANG_REJECT`; here the boundary gate records it as
  a symmetric BOTH-REJECT).
* **R5 — the g22 ADDRESS FAMILY** (buvm31/32's carried residue) is the only
  boundary delta that is neither this law nor a coin: three `|UINT:` /
  `|vpiDecompile:` constants, every value shifted by EXACTLY 4096, zero
  non-address lines, and `coin33.sh` on g22 alone reads raw=0 — it is binary
  layout, not behaviour.
* **R6 — the `MISSING-OURS 179 / EXTRA-OURS 167` SDREF families** (the
  `TYPE::type_name` / `uvm_root::get` residues buvm32 recorded as its R4) are
  the same census's other rows and are NOT touched here.

### R0 — the next head

With this landed, SeqDriver and BuildUVMPkg both modes stand at 56 cmp lines
and the new head is the SAME object in both — **the LOOP VARIABLE of the very
`foreach` this pass fixed**:

```
LHS: int_var  (uvm_pkg::uvm_sequence_library::init_sequence_library::i)
     line 496:44-496:45 (SeqDriver) / 56591:44-56591:45 (BuildUVMPkg)
     vpiParent -> foreach_stmt   vpiTypespec -> ref_typespec -> int_typespec
RHS: array_var (…::i) @496:44-496:45
     vpiTypespec -> ref_typespec -> array_typespec
```

It was MASKED by this law's cell, not created by it: `byteverify`'s nine mover
attributions contain **zero** lines mentioning that loop variable, so our
object is byte-identical before and after.

The law is already visible on this pass's own arms and needs no new census to
start: in `g33a1` golden answers `int_var 'i'` and we answer `array_var 'i'`
for the loop variable of a SCOPED foreach array in the OUT-OF-BODY, PACKAGE
FUNCTION and MODULE homes (cells A1-A5, P1, M1 — seven cells), while the
IN-BODY home (B1-B5) and every UNQUALIFIED control already agree.  Source-first
that is `UhdmWriter::swapForSpecifiedVar` (~:2490): it re-resolves the array
reference's name through `decodeHierPath` and feeds the result to
`getSimpleVarFromTypespec`, and a `<first>::<last>` name resolves to nothing,
so it takes the `int_var` fallback at `:2550` — where we resolve through slang
to the real array and hand back `array_var` + `array_typespec`.  Worth four
row-modes.

SimpleUVM stays at 17, Scoreboard/default and MiniAmiq at 60, Earlgrey_0_1 at
36, Rggen at 0.

---

## 8. Files

* `r10buvm33cen.cpp` + `build33.sh` — the `FEHDR` / `SDREF` census, linked
  STATICALLY against `~/.local` UHDM so it reads exactly the databases the
  sweeps wrote.
* `sweepcen33.sh` — the census over a whole verify_golden workdir, both sides,
  both modes; a missing side is counted, never skipped.
* `cen33.py` — the symmetric multiset join (`--fehdr`, `--sdref`,
  `--only-disagree`, `--filter`); the FEHDR key excludes the name on purpose.
* `fecell33.py` — the foreach-header cell reader for a single dump.
* `gridcmp33.py` — golden vs pristine vs patched, per foreach line, with the
  SAME / FIXED / RESIDUE / **BROKEN** verdict.
* `cells33.py` — per-source-line object comparison of two dumps.
* `msdiff33.py` — order-blind multiset dump diff; run golden-vs-pristine and
  golden-vs-patched and compare the KEY SETS to prove NEW=0.
* `arm33.sh` — one purpose-built arm, both views, golden vs one binary, every
  command and rc echoed into `cmds.txt`.
* `movers33.sh` — order-blind mover attribution.
* `bound33.sh` — the boundary gate; `coin33.sh` — the same-binary-twice
  nondeterminism control.
* `g33a1.sv` / `g33a2.sv` / `g33a3.sv` — the purpose-built goldens.
* `PREDICTION.txt` — the mover prediction, written before the patched sweep.
* `BOUNDARY.txt` — the boundary-gate results, arm by arm.
* `byteverify.sh` / `canaries.sh` / `ctcan2.sh` / `canaudit.sh` /
  `rowheads.sh` — the shared gate scripts, copied so `canaudit.sh` runs here.
