# r10uvm54 — pass-50 residue R2 CRACKED. TWO laws; the base-pick key ANSWERED and the brief's spelling of it REFUTED; every class-nested class-handle typedef cell on both UVM corpora now cmp-EQUAL; the head moved twice; **NO conversion**

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order. Every dump excerpt is passed through `sed '1d'` — uhdm-dump's FIRST LINE
is the DATABASE PATH and always differs — so every "content +/-" figure here is
real content with no +2 bias, and the `RAW - 2` subtraction is only the two
`diff -u` header lines.

Base **a4b4d8d**.

| binary | md5 | what it is |
|---|---|---|
| HEAD control | `ee0345153f52c86181b9e61f8015893b` | this worktree's build of pristine a4b4d8d — **byte-identical to the main-tree `build/slang-uhdm` at the start of this pass**, which is what makes it a valid control |
| law 1 only | `186da4242b2db00fa4e264b95e4b4fe9` | intermediate, used to attribute each move to one law |
| FINAL (gated, shipped) | `b66b71221f0672b192a3360b6b082b8e` | every gate below ran on this binary |

`git stash` was never used. `results/gate_uhdm2rtlil.csv` and
`results/golden_surelog.csv` were **read only** — never rebuilt, edited or
included — and their row counts (**731** and **1588**) come from `csvdiff.py`'s
parsed dict, never from `wc -l` (which would say 732 / 1589 because of the
header).

## 0. HEADLINE — honest

* **NOTHING CONVERTED.** `SimpleUVM`, `SeqDriver`, `Scoreboard` and
  `BuildUVMPkg` are still `CMP_NOTEQUAL` in both modes. **No row in either
  committed baseline changed: `csvdiff.py` reports ROW DIFFS 0 against both.
  There is NO promotion to make and the SEVEN ROWS did NOT move.**
* **PASS-50's RESIDUE R2 IS CRACKED, and that is this pass's result.**
  `classNestedClassTdGroupNoAnchor54` closes the whole class-nested
  class-handle typedef question on both UVM corpora: the `tdgroup.py`/`join.py`
  cell table over **145 keys (BuildUVMPkg)** and **146 keys (SimpleUVM)** goes
  from **EQ 47 / EQ 86** to **EQ 144 / EQ 145**, and the one cell left on each
  side is a PRE-EXISTING `SPAN_ONLY` that this pass restored to exactly its
  a4b4d8d state (§5).
* **THE BRIEF'S KEY CLAIM IS REFUTED IN ITS SPELLING AND CONFIRMED IN ITS
  DIRECTION.** The brief said the base-pick key is "THE SPECIALISATION NAME".
  It is **the DECLARING CLASS's fully-qualified Surelog design-map key**
  (`<pkg>::<cls>`, or `work@<cls>` for a compilation-unit class), tie-broken by
  the TYPEDEF's own name. Three candidate keys are refuted with cells, one of
  them the brief's own (§3b). The brief's "concrete specialisation" carve-out is
  **UNNECESSARY** and its witness is a CLONE in golden, not an excluded
  non-member (§3c).
* **TWO laws landed:**
  * **`classNestedClassTdGroupNoAnchor54`** — `include/UhdmExporter.h`
    (`grep -n 'struct ClassNestedTd54'`), collected in
    `src/UhdmExporter.cpp` (`grep -n 'classNestedTd54.push_back'`), drained
    design-final (`grep -n 'void UhdmExporter::drainClassNestedTdGroups54'`,
    called at `grep -n 'drainClassNestedTdGroups54();'`).
    DIRECTION: **RESHAPE (span) + ADD (the alias)**.
  * **`classParamWrittenTypeTypespec54`** — `src/UhdmExporter.cpp`
    (`grep -n 'wtSyn54'`), inside `emitClassParameters`.
    DIRECTION: **RESHAPE (typespec KIND + SPAN)**. It exists because it became
    the cmp head of all seven rows the moment law 1 landed.
* **THE HEAD MOVED TWICE, on both measured rows, to two different families.**
  Both moves are proved with the intermediate binary, and BOTH distance numbers
  are reported because cmp line count is a head-DEPTH measure, not a distance:

  | test (mode `default`) | measure | HEAD `ee034515` | law 1 `186da424` | FINAL `b66b7122` |
  |---|---|---|---|---|
  | BuildUVMPkg | cmp lines / heads | 17 / 1 | 16 / 1 | **58 / 1** |
  | BuildUVMPkg | dump content +/- | 168339 | 167074 | **167059** |
  | SimpleUVM | cmp lines / heads | 17 / 1 | 16 / 1 | **13 / 1** |
  | SimpleUVM | dump content +/- | 240093 | 238666 | **238633** |
  | SeqDriver | cmp lines / heads | 17 / 1 | — | **85 / 1** |
  | Scoreboard | cmp lines / heads | 17 / 1 | — | **13 / 1** |

  `rowheads.sh` on the gate-4 workdir and on the control workdir gives the same
  numbers in BOTH modes, and it **CONFIRMS the brief's claim that all seven
  comparable rows were 17 cmp lines with ONE head at a4b4d8d** — measured here,
  not inherited.

  **BuildUVMPkg's cmp GREW 16 -> 58 while its dump distance FELL.** That is a
  head ADVANCE into a deeper object, not a regression, and §6 names the new
  head on both rows and shows it is pre-existing.
* **ONE over-fire actually HAPPENED and the CORPUS caught it** — law 1 without
  its `tpAliasRoot25` half moved `uvm_sequencer_param_base::rsp_type` AWAY from
  golden on both tests (§3d), which is why that half exists. **A second one was
  PREVENTED by an arm control cell before it could happen**: a2's two IMPLICIT
  class-parameter cells are byte-equal to golden already, so law 2 is gated on
  "a data type was WRITTEN" and an ungated version would have rewritten the shape
  the live `ClassParamAsParam` canary carries (§4a). I distinguish the two
  because only the first is a measured regression.

## 1. GOLDEN'S OWN OBJECTS — the census the brief asked me to confirm, CONFIRMED and CORRECTED

The brief's census of the head is right in substance:

| thing counted | brief says | I measure (BuildUVMPkg golden) |
|---|---|---|
| distinct `class_typespec (type_id)` SPANS in golden | (not stated) | **4** — 26247:12-31, 50690:12-34, 13903:11-39, 13776:11-42 |
| `class_typespec: (type_id)` DUMP LINES, golden | 226 "any" | **336** (`grep -c`), of which 242 are at 26247 |
| the same, ours at a4b4d8d | 61 | **89** |
| `ref_typespec (uvm_pkg::<cls>::type_id)` lines, golden | — | **89** |
| the same, ours at a4b4d8d | — | **2** |

**These are DUMP LINES, not objects, and the two must not be mixed** — a
back-referenced object is printed under every owner. The OBJECT counts, measured
with `tdgroup.py` (which keys objects and UNIONs their fields over occurrences),
are in §2, and they are the numbers every claim below uses.

The brief's `195` for "class_typespec (type_id) at line:453:12" is **exactly
right** for SimpleUVM golden (`grep -c` gives 195) — but 453:12 is **not a
declaration site**. It is `uvm-1.2/src/macros/uvm_object_defines.svh:453`
— `typedef uvm_object_registry #(T) type_id;`, the BODY of the
`m_uvm_object_registry_param` macro, read in the source. (The
`uvm_component_registry` group's `483:12-34` is line 483 of the same file,
`typedef uvm_component_registry #(T) type_id;`, and SeqDriver's `440:12-31` is
line 440, `uvm_object_utils`' own body.) That answers the brief's
"settle the macro-expansion declaration site" item: **in uvm-1.2 every
`type_id` typedef reports the MACRO BODY's span, so 195 dump lines collapse onto
one line number on BOTH sides and the span half of the law is nearly free there;
in the 1800.2 pp_output the sources are already preprocessed and every typedef
reports its own line, so the span half does all the work.** That is why the two
UVM versions need separate arithmetic and why mixing their line numbers has bitten
this cluster: BuildUVMPkg's `uvm_object_registry` lives at pp 13652, uvm-1.2's at
`base/uvm_registry.svh:189`.

## 2. THE OBJECT-LEVEL POSITION, both sides, before anything changed

`tdgroup.py summary`, control binary `ee034515`:

| measure | BuildUVMPkg golden | BuildUVMPkg ours | SimpleUVM golden | SimpleUVM ours |
|---|---|---|---|---|
| class-nested class-handle typedef OBJECTS | **145** | **145** | **146** | **146** |
| distinct GENERIC classes they group under | **44** | **44** | **21** | **21** |
| groups with >1 member | **11** | **11** | **7** | **7** |
| multi-member groups whose members share ONE span | **11** | **2** | **6** | **2** |
| objects carrying `vpiTypedefAlias` | **106** | **9** | **67** | **8** |

The **(owner, typedef-name) KEY SETS ARE IDENTICAL** on both sides — `diff` of
the two sorted key lists is **0 lines** on BuildUVMPkg. So we already mint the
right set of objects under the right owners; only the SPAN and the ALIAS differed.
Ours' 9 / 8 existing aliases are exactly the members whose group HAS a
package-level anchor (pass-50 law 4 already handles those), and they are the
groups **[TOOL DOES NOT EXIST — see integration note C1]** reports as "base outside".

## 3. LAW 1 — `classNestedClassTdGroupNoAnchor54`

**Sites, all tagged `NOTE § classNestedClassTdGroupNoAnchor54`:**
`include/UhdmExporter.h` (`grep -n 'struct ClassNestedTd54'`), the collection in
`buildClassTypedefTs` (`grep -n 'classNestedTd54.push_back'`), the sort-key
transcription (`grep -n 'std::string UhdmExporter::surelogClassKey54'`), the drain
(`grep -n 'void UhdmExporter::drainClassNestedTdGroups54'`) and its design-final
call site (`grep -n 'drainClassNestedTdGroups54();'`).

**Predicate / gate.**

```
group key         = the target's GENERIC class symbol when the target is a
                    specialization, else the target ClassType itself
in scope          = a class-nested TypeAlias whose target's canonical kind is
                    ClassType, and which is NOT a type-parameter alias
                    (!tpAliasRoot25.count(&ta))
group is MINE     = classTdGroupBase50 has NO entry for the key
                    (i.e. NO package-level anchor -> pass-50 law 4 did nothing)
base              = the member sorted FIRST by
                    (declaring class's Surelog design-map key, typedef name)
action on the base           = NOTHING
action on every other member = copy the base's line/col/endline/endcol/file,
                               and add a vpiTypedefAlias ref_typespec whose
                               vpiFullName is `<owner key>::<typedef name>` and
                               whose vpiActual is the base
groups with ONE member       = NOTHING
```

**DIRECTION: RESHAPE (span) + ADD (the alias).** The object is still minted,
still carries its own `vpiName` and its own `vpiClassDefn`.

### 3a. SURELOG'S MECHANISM, TRANSCRIBED not guessed

`ElaborationStep::bindTypedefs_`
(`Surelog/src/DesignCompile/ElaborationStep.cpp`, `grep -n 'bool ElaborationStep::bindTypedefs_'`)
builds ONE `defs` vector and walks it once:

1. every FileContent's `getTypeDefMap()`, 2. every PACKAGE's, 3. every MODULE's,
4. every PROGRAM's, 5. **every CLASS's, in `design->getClassDefinitions()`
order**.

For a class-handle typedef the target is a `DummyType` with no typespec, so
`noTypespec` is true; `bindTypeDef_` resolves it, `typd->setDataType((DataType*)def)`
makes the typedef's DataType **the shared target ClassDefinition**, and then:

* if `def->getTypespec()` is **null** — the first walker — `compileTypespec` mints
  a bare `class_typespec` with `populateCoreMembers` (the NAME-TOKEN span, no
  parameters, no alias) and `dt->setTypespec(ts)` **stores it on the shared
  target**;
* every LATER walker finds `def->getTypespec()` non-null, `UHDM::clone_tree`s it
  and hangs `tpclone->Typedef_alias(rt)` with `rt->Actual_typespec(tps)` on the
  clone.

So **"the base" is simply "walked first"**, and the order among class-nested
typedefs is `Design::m_classDefinitions`, a
`std::multimap<std::string, ClassDefinition*, StringViewCompare>` whose key is the
name `ResolveSymbols` registered:
`<pkg>::<cls>` for a class declared in a package and `<lib>@<cls>` = `work@<cls>`
for a compilation-unit one
(`Surelog/src/DesignCompile/ResolveSymbols.cpp`, `grep -n 'fullSubName'`).
Within one class the order is `DesignComponent::TypeDefMap`, a
`std::map<std::string, TypeDef*>` keyed by the TYPEDEF's name
(`Surelog/include/Surelog/Design/DesignComponent.h`, `grep -n 'using TypeDefMap'`).

**The same walk explains pass-50 law 4 for free**: packages are walked at step 2,
before classes at step 5, so a package-level typedef of the same target ALWAYS
wins the base — which is exactly why this law's gate is "no
`classTdGroupBase50` entry" and not a re-sort over the merged set.

### 3b. THE BASE-PICK KEY — the corpus, and THREE REFUTATIONS

**[TOOL DOES NOT EXIST — see integration note C1]** over every multi-member group with a class-nested base:
**OWNER-FIRST-OK 9, REFUTED 0** on BuildUVMPkg and **OWNER-FIRST-OK 4,
REFUTED 0** on SimpleUVM — **13 groups, zero counter-examples.** Two of those
groups are individually decisive:

| golden group | members | golden's BASE | the key that picks it | the keys it REFUTES |
|---|---|---|---|---|
| `uvm_pkg::uvm_object_registry` (BuildUVMPkg) | 62 | `uvm_pkg::uvm_barrier::type_id` @26247:12-31 | owner name (`uvm_barrier` is first of 62 owners) | **TYPEDEF NAME** — `uvm_pkg::uvm_object_registry::this_type` is a member and `this_type` < `type_id`, so a name-first key picks it and golden does NOT. **SOURCE ORDER** — the earliest member is pp 13654, golden's base is pp 26247. **RAW SPECIALISATION ARGUMENT** — `uvm_resource::type_id`'s argument text is `this_type`, which sorts before `uvm_barrier` |
| `uvm_pkg::uvm_component_registry` (BuildUVMPkg) | 13 | `uvm_pkg::uvm_algorithmic_comparator::type_id` @50690:12-34 | owner name (`uvm_algorithmic_comparator` is first of 13) | **RAW SPECIALISATION ARGUMENT** — **FIVE** of the 13 members are spelled `#(this_type)` and are therefore TIED under that key, so it cannot pick among them at all. **SOURCE ORDER** — earliest is pp 13533 |
| `uvm_pkg::uvm_abstract_component_registry` (BuildUVMPkg) | 8 | its OWN `this_type` @13776:11-42 | owner name (`uvm_abstract_component_registry` < `uvm_agent`) | — |
| `uvm_pkg::uvm_registry_common` (BuildUVMPkg) | 5 | `uvm_pkg::uvm_abstract_component_registry::common_type` @13777:11-30 | owner name | — |
| `uvm_pkg::uvm_object_registry` (SimpleUVM) | 49 | `uvm_pkg::uvm_built_in_pair::type_id` @453:12-31 | owner name | as above |
| `uvm_pkg::uvm_typed_callbacks` (both) | 2 | `uvm_pkg::uvm_callbacks::super_type` | owner name | — |
| `uvm_pkg::uvm_callbacks_base` (both) | 2 | `uvm_pkg::uvm_callbacks_base::this_type` @26619:11-29 | owner name | — |

**Why the brief's spelling looked right:** the `uvm_*_utils` macros pass the
CONTAINING class as the specialisation argument, so the raw-argument key and the
owner key agree on 49 of the 50 `uvm_object_registry` members. They disagree on
exactly one — pp 16779 inside `class uvm_resource #(type T=int)` — and the brief
resolved that disagreement by adding a "concrete specialisation" exclusion. §3c
shows that exclusion is not what golden does.

### 3c. THE BRIEF'S "CONCRETE SPECIALISATION" CARVE-OUT IS UNNECESSARY — measured

`uvm_pkg::uvm_resource::type_id` (pp 16779,
`typedef uvm_object_registry#(this_type) type_id;` inside the generic class
`uvm_resource`) is **present in golden's group as a CLONE**, not excluded:

| field | LHS golden (BuildUVMPkg) | RHS ours at a4b4d8d | RHS FINAL |
|---|---|---|---|
| span | `26247:12-26247:31` — the BASE's | `16779:11-16779:30` — its own | **`26247:12-26247:31`** |
| `vpiTypedefAlias` | `ref_typespec (uvm_pkg::uvm_resource::type_id)` -> `class_typespec (type_id)` @26247:12-31 | **absent** | **present, target correct** |

So golden does not skip it for being inside a generic class; the owner key simply
sorts `uvm_barrier` before `uvm_resource`. **No carve-out exists in the shipped
code, and none is needed.**

### 3d. THE `tpAliasRoot25` HALF — an OVER-FIRE the CORPUS caught

With the group gate but without the type-parameter-alias half, ONE cell moved
AWAY from golden on **both** tests:

| cell | LHS golden | RHS a4b4d8d | RHS law 1 WITHOUT the half | RHS FINAL |
|---|---|---|---|---|
| `uvm_pkg::uvm_sequencer_param_base::rsp_type` (BuildUVMPkg) | span `53934:58-61`, alias **NONE** | span `53758:11-14`, alias NONE | span `53758:11-14`, **alias -> `req_type`** — WRONG | span `53758:11-14`, alias NONE — back to pre-existing |
| the same, SimpleUVM | span `211:58-61`, alias **NONE** | span `35:11-14`, alias NONE | span `35:11-14`, **alias -> `req_type`** | span `35:11-14`, alias NONE |

`typedef REQ req_type; typedef RSP rsp_type;` — both type parameters resolve to
`uvm_sequence_item` in the default specialization, so they landed in one group.
Golden hands such a typedef the PARAMETER's own typespec object
(`§ typedefAliasSharesTypespec25`) and it has no clone and no alias. The gate is
`!tpAliasRoot25.count(&ta)`; the residual span difference on that cell is
PRE-EXISTING and is residue **R2** below.

### 3e. ARM a1 — every cell, BOTH SIDES

`tools/probe/r10uvm54repro/a1/dut.sv`, read with `cells.sh`. Every cell name is a
TYPEDEF name in that file. `gold.sh a1` at the control binary:
`85 cmp lines / 1 head`, dump +/- **545**; at FINAL: `85 / 1`, dump +/- **509**.
**a1's cmp head never moves in this pass and four of its cells are fixed** — the
`m_visited` trap in the flesh, which is why the arm is judged on
`diff`-of-dump cells and not on cmp.

| cell (dut.sv line) | what it tests | LHS golden span / alias target | RHS a4b4d8d | RHS FINAL |
|---|---|---|---|---|
| `b_owner54::td_aaa54` (71) | owner-name vs TYPEDEF-NAME vs SOURCE order, all three disagreeing | `77:13-77:16` / `class_typespec (r54::td_zzz54)` | `71:13-71:16` / NONE | **`77:13-77:16` / correct — FIXED** |
| `a_owner54::td_zzz54` (77) | the BASE that key picks | `77:13-77:16` / NONE | same | unchanged (base untouched) |
| `c_owner54::t_bbb54` (83) | within-class tiebreak; `t_bbb54` is declared FIRST | `84:13-84:16` / `class_typespec (r54::t_aaa54)` | `83:13-83:16` / NONE | **`84:13-84:16` / correct — FIXED** |
| `c_owner54::t_aaa54` (84) | the TYPEDEF-NAME-first base inside one class | `84:13-84:16` / NONE | same | unchanged |
| `zbb54::aa54::n_z54` (98) | cross-PACKAGE group; FULL-name order says the base is in `raa54` | `91:13-91:16` / `class_typespec (r54::n_r54)` | `98:13-98:16` / NONE | **`91:13-91:16` / correct — FIXED** |
| `work@mm54::n_u54` (104) | the `work@` spelling of a `$unit` class | `91:13-91:16` / `class_typespec (r54::n_r54)` | `104:11-104:30` / NONE | **`91:13-91:16` / correct — FIXED** |
| `raa54::zz54::n_r54` (91) | the base the FULL-name key picks | `91:13-91:16` / NONE | same | unchanged |
| `a_owner54::h_only54` (78) | a group with exactly ONE member | `78:13-78:16` / **NONE** | same | **unchanged — the singleton gate** |
| `b_owner54::ka_bbb54` (72) | a group WITH a package anchor (pass-50 law 4) | `63:11-63:14` / `class_typespec (s54::k_anchor54)` | already correct | **untouched** |
| 21 further keys | the same objects re-listed by other classes | — | — | all EQ |
| **join total** | | | **BOTH 4 / EQ 26** | **EQ 30 / non-EQ 0** |

**The `n54` group is the cell that decides the SPELLING.** Owners are
`raa54::zz54`, `zbb54::aa54` and `work@mm54`. FULL-name order is
`raa54::zz54 < work@mm54 < zbb54::aa54`, so it picks `zz54`; SHORT-class-name
order is `aa54 < mm54 < zz54`, so it picks `aa54`. **Golden's base is
`n_r54`, declared in `raa54::zz54`** — the SHORT-name spelling is REFUTED and the
package-qualified one confirmed. The alias fullnames our code writes are
byte-equal to golden's, including `work@mm54::n_u54`.

**The fourth corner is not measurable and that is recorded, not glossed:** a1
cannot make a group whose base is a MODULE-declared or class-NESTED class, because
`surelogClassKey54` has no measured spelling for those; the code's fallback is
`work@<cls>` and the header says so as an UNMEASURED HALF.

### 3f. THE `tdgroup.py` OWNER AXIS — a REFUTATION of the obvious instrument

The instrument keys a row by the **LISTING** `class_defn` (the node under whose
printed `vpiTypedef` list an occurrence appears), NOT by the object's own
`vpiParent`. That is deliberate and it is a measurement:
`UhdmWriter::writeDataTypes` does `tps->VpiParent(parent)` for EVERY class that
lists a shared typespec, so **`vpiParent` ends up naming the LAST LISTER.** In
SimpleUVM golden the `uvm_object_registry` group's base carries
`vpiParent class_defn (work@env)` while its declaring class is a `uvm_pkg` class.
Keying on `vpiParent` produced **6 spurious base-pick refutations and 10 phantom
`RHS_ONLY` keys**; keying on the listing class gives 0 refutations and a
0-line key-set diff. The listing class is also the axis `BaseClass::Compare`
walks (`class_defn -> Typespecs[i]`), so it is the axis that decides cmp.

The `vpiParent` back-edge is still CAPTURED and PRINTED — `tdgroup.py parents`
reports, per row, the vpiParent it carries and flags every row where that names a
different class than the listing owner: **SimpleUVM golden 10 of 146 rows are
LAST-LISTER, BuildUVMPkg golden 0 of 145.** Those 10 are exactly the 10 phantom
keys the wrong axis produced, so the instrument now prints the number that
justifies its own choice. `--selftest` asserts both halves (the key AND the
capture) and both NEGATIVE controls in §7 were run.

## 4. LAW 2 — `classParamWrittenTypeTypespec54`

**Site:** `src/UhdmExporter.cpp`, `emitClassParameters` (`grep -n 'wtSyn54'`).

**Why it exists:** the moment law 1 landed, the cmp head of BOTH measured rows
became this pair, identically:

```
LHS golden(BuildUVMPkg): string_typespec, line:13652:48, endln:13652:54
                         |vpiParent parameter (uvm_pkg::uvm_object_registry::Tname)
RHS ours:                int_typespec,    line:13652:48, endln:13652:72
```

(uvm-1.2 spells the same class at `base/uvm_registry.svh:189`, and the head there
is the same pair at `189:48-54` vs `189:48-72`.) The site was building an
`int_typespec` spanning the WHOLE DECLARATION unconditionally.

**Predicate.**

```
wtSyn54    = the parameter's DeclaredType::getTypeSyntax()
explicit   = wtSyn54 != null && wtSyn54->kind != SyntaxKind::ImplicitType
kind       = string_typespec  when the canonical type is StringType
             int_typespec     when it is a PredefinedIntegerType of kind Int
             (anything else -> FALL THROUGH to the old shape, deliberately)
span       = wtSyn54->sourceRange()      -- the DATA TYPE, not the declaration
implicit   = UNCHANGED: int_typespec spanning the whole declaration, keeping the
             sized-literal packed range
```

The one object is shared between the parameter and its fold CONSTANT on both
sides, and that sharing is unchanged.

### 4a. ARM a2 — every cell, BOTH SIDES, ONE golden

`tools/probe/r10uvm54repro/a2/dut.sv`, read with `clsparam.py rows`. Every cell
name is a PARAMETER name in that file. `gold.sh a2`: control `18 cmp lines /
1 head`, dump +/- **210**; FINAL `18 / 1`, dump +/- **190**.

| cell | written type | LHS golden kind / span | RHS control | RHS FINAL |
|---|---|---|---|---|
| `pstr54::scell` | `string` | **string_typespec** / `20:18-20:24` | int_typespec / `20:18-20:40` | **string_typespec / `20:18-20:24` — FIXED** |
| `pint54::icell` | `int` | int_typespec / `23:18-23:21` | int_typespec / `23:18-23:31` | **int_typespec / `23:18-23:21` — FIXED** |
| `puns54::ucell` | `int unsigned` | int_typespec / `26:18-26:30` | int_typespec / `26:18-26:40` | **int_typespec / `26:18-26:30` — FIXED** |
| `ptwo54::t1cell` | `int`, 1st of two declarators | int_typespec / `46:18-46:21` | int_typespec / `46:18-46:44` | **`46:18-46:21` — FIXED** |
| `ptwo54::t2cell` | `int`, 2nd declarator | int_typespec / `46:18-46:21` | int_typespec / `46:18-46:44` | **`46:18-46:21` — FIXED** |
| `pimp54::pcell` | **IMPLICIT** `#(pcell = 3)` | int_typespec / `30:18-30:27` = WHOLE DECLARATION | int_typespec / `30:18-30:27` | **unchanged — the CONTROL, already equal** |
| `psz54::zcell` | **IMPLICIT**, sized literal `8'hAA` | int_typespec / `34:17-34:30` | int_typespec / `34:17-34:30` | **unchanged — the packed-range control** |
| `pbyt54::bcell` | `byte` | **byte_typespec** / `38:18-38:22` (+`vpiSigned:1`) | int_typespec / `38:18-38:32` | unchanged — **DECLINED, residue R3** |
| `pvec54::vcell` | `bit [7:0]` | **bit_typespec** / `41:18-41:27` | int_typespec / `41:18-41:41` | unchanged — **DECLINED, residue R3** |

**The two IMPLICIT cells are why the gate carries `explicit`.** Golden's implicit
answer is byte-identical to what this site already produced, and that shape is
what the live `ClassParamAsParam` / `ClassTypeParam` canaries carry — an ungated
law would have rewritten both.

**a2's cmp head does NOT move in this pass, and it is the `byte` cell I
declined** (`byte_typespec @38:18-22 |vpiSigned:1` vs our
`int_typespec @38:18-32`). I say that plainly rather than quoting a2's cmp as
evidence: a2's evidence is its cell table and its dump +/-.

### 4b. WHY THE KIND SET IS ONLY `{string, int}` — deliberate restraint, with the cost stated

Golden's answer for `byte` and for `bit [7:0]` is MEASURED above. It is not
taken, because neither corpus row needs it (the 12 class value parameters across
both UVM tests are 10 `string` and 2 `int`/`int unsigned`) and because widening to
`bit`/`logic` needs a packed-range rule no arm here measures. Every other written
type falls through to the previous shape instead of guessing a kind. That is
residue **R3**, with both sides recorded.

### 4c. THE CORPUS CENSUS — `clsparam.py kinds`, both sides

| | BuildUVMPkg golden | ours control | ours FINAL |
|---|---|---|---|
| `string_typespec` class parameters | **5** | 0 | **5** |
| `int_typespec` class parameters | **2** | 7 | **2** |
| total class value parameters | 7 | 7 | 7 |
| spans equal to golden's | — | **0 of 7** | **7 of 7** |

All seven BuildUVMPkg spans are byte-equal to golden's after the law
(`13774:63-69`, `13901:57-63`, `13531:54-60`, `13652:48-54`, `14031:88-94`,
`17220:22-34`, `17247:23-35`), and all five of SimpleUVM's `uvm_pkg` class
parameters likewise (`51:54-60`, `189:48-54`, `640:34-40`, `130:22-34`,
`153:23-35`).

*Measured aside, recorded because it will mislead the next reader of
`clsparam.py`:* on SimpleUVM the instrument reports **50** class parameters in
golden and **5** in ours. That is NOT 45 missing objects — golden re-parents the
`uvm_pkg` PACKAGE parameters (`UVM_STDOUT`, `uvm_revision`, …) onto the listing
class_defn, so `clsparam.py`'s `vpiParent` key credits them to `work@env`, while
on our side the same objects keep `vpiParent = package uvm_pkg`. Spot-checked:
`uvm_pkg::uvm_revision` is a `string_typespec @31:11-31:17` on BOTH sides
already, so the package-parameter path was never wrong.

## 5. WHERE THE CELL TABLES END UP — the corpus, both tests

`join.py` over `tdgroup.py rows`, LHS golden vs RHS ours:

| test | keys | control | law 1 only | FINAL |
|---|---|---|---|---|
| BuildUVMPkg `default` | 145 | EQ 47, BOTH 97, SPAN_ONLY 1 | EQ 144, BOTH 1 | **EQ 144, SPAN_ONLY 1** |
| SimpleUVM `default` | 146 | EQ 86, ALIAS_ONLY 12, BOTH 47, SPAN_ONLY 1 | EQ 145, BOTH 1 | **EQ 145, SPAN_ONLY 1** |

The single remaining cell on each side is `uvm_sequencer_param_base::rsp_type`,
whose alias is correctly absent again and whose SPAN difference is PRE-EXISTING at
a4b4d8d (residue **R2**). **No cell moved away from golden on either test.**

## 6. THE NEW HEADS — named, and shown to be pre-existing

**BuildUVMPkg FINAL head** (58 cmp lines, 1 head) — a local variable whose
declared type is a class TYPE PARAMETER:

```
LHS golden: ref_var (uvm_pkg::uvm_registry_common::__deferred_init::rgtry) @14104:16-21
            |vpiTypespec -> int_typespec @14031:45-48   (the type PARAMETER's own)
RHS ours:   int_var (same name, same span) |vpiSigned:1
            |vpiTypespec -> int_typespec @14104:6-15    (its own declaration)
```

**SimpleUVM FINAL head** (13 cmp lines, 1 head) — a `new` call golden holds and we
do not:

```
LHS golden: method_func_call (new) |vpiParent assignment @uvm_registry.svh:207:19-30
RHS: <null>
```

Both are **PRE-EXISTING**: neither law touches `ref_var`/`int_var` selection nor
`new`-call emission, and both objects have exactly the same shape in the control
binary's dump — they were simply behind the removed heads. They are residues
**R4** and **R5**.

**cmp LENGTH IS A HEAD-DEPTH MEASURE.** BuildUVMPkg's cmp went 16 -> 58 while its
dump distance fell 167074 -> 167059 and its cell table went EQ 144 -> EQ 144: the
new head is simply a bigger object. SimpleUVM's went 16 -> 13 across the same
change. Quoting either number alone would have been a wrong story, so both are in
the headline table.

## 7. DRIVERS AND THEIR EXERCISED GUARDS

| asset | what it is |
|---|---|
| `tdgroup.py` | **new** — per (LISTING class, typedef name): span, `vpiClassDefn`, `vpiTypedefAlias` target, occurrence count, and the captured `vpiParent`; plus a `groups` view that prints each group's members and its no-alias BASE. Fields are UNIONed over occurrences because uhdm-dump abbreviates repeated objects. GUARDS: exits **4** with `UNMEASURED:` on a dump with no class_defn-owned class_typespec (**RUN**: on a one-line fixture it prints exactly that and exits 4); prints `UNMEASURED` / `CONFLICT{...}` per field; `--selftest` is the POSITIVE control and **PASSES**. **NEGATIVE CONTROLS RUN, both:** breaking the field UNION makes the selftest print `union of occurrences lost vpiClassDefn` and exit 1; making the owner key follow `vpiParent` instead of the listing node makes it print `expected 3 LISTING-keyed rows, got ...` and exit 1. |
| `join.py` | **new** — joins two `rows` outputs and classifies each cell EQ / ALIAS_ONLY / SPAN_ONLY / BOTH / LHS_ONLY / RHS_ONLY. It compares the alias TARGET triple and deliberately NOT the ref's own `vpiFullName`, because that fullname is a separate known residue (pass-50 R3) and folding it in would hide every real move. GUARD: exits 4 when either side parsed zero rows. |
| `clsparam.py` | **new** — per class value parameter: its typespec KIND and SPAN, and the parameter's own span. GUARDS: exits 4 when it finds no class_defn-owned parameter; prints `UNMEASURED` for a parameter with no typespec and COUNTS those rows; `--selftest` (an object printed once detailed and once abbreviated, plus one with no typespec) **PASSES**. |
| `cells.sh` | the arm cell table for one `gold.sh` outdir: both sides, joined, plus both group views. Existence- AND size-checks both dumps (exit 6) and propagates the probes' exit codes instead of swallowing them. |
| `fams.sh` | **new** — the FAMILY canaries `canaries.sh` cannot enumerate (`Black*`, `EvalFunc*`, `ParamFile*`), compared WHOLE ROW. GUARD: a prefix matching zero baseline rows is `EMPTY-FAMILY` and exit 5. **NEGATIVE CONTROL RUN:** `ZZZ_TYPO_FAMILY` prints `EMPTY-FAMILY` and exits 5. **SELF-CHECK RUN:** baseline against itself gives `IDENTICAL` on all three with rc 0. Run it on the SUREOG csv — on the u2r csv all three families legitimately match 0 rows, which is stated in its header. |
| `rowheads.sh` | **new** — cmp lines / heads for a NAMED SUBSET of a sweep workdir. It replaces `heads.sh`, which was NOT copied into this pass: `heads.sh` walks the whole workdir (953 cmps on the surelog corpus) and its `HEAD_MD5_IDNORM` column hashes the WHOLE cmp file rather than the head, a defect pass 53 documented and did not fix. `rowheads.sh` has no md5 column at all. GUARDS, **both fired in the run that produced §9a's table**: `SKIP-NOFILE` (existence-checked BOTH sides, because uhdm-cmp exits 0 on a missing input) and `UNKNOWN-NAME`, plus the golden path resolved out of the workdir's own `cmds.txt` with the cache DIRECTORY turned into `.../golden.uhdm`. **A defect in this script was found by running it and fixed**: its `rc=` column read `$?` after a command substitution and printed `rc=0` for a cmp that had exited 255. |
| `detcheck.sh` | **new** — N runs of one binary on one input, sha256 each. Replaces `sbflake.sh` (not copied): same question, one script, and it works on any input rather than only on Scoreboard. GUARDS: a run that emits no database is `NO_OUTPUT` and counted; the pass condition is printed as "1 distinct and 0 NO_OUTPUT". **Exercised on 3 (binary, input) pairs, and it correctly FAILS (exit 1) on Scoreboard** (§10b). |
| `gold.sh`, `canaries.sh`, `bvcompare.sh`, `manifest.sh`, `csvdiff.py` | copied from `r10uvm53repro` (only the `r10uvm53repro` -> `r10uvm54repro` self-reference retagged). **Every one of them was RUN in this pass**, and each cited guard was exercised here rather than inherited: `canaries.sh`'s typo negative control (§9), `bvcompare.sh`'s comparator negative control AND its no-shared-path guard (exit 5, §10), `manifest.sh`'s database count printed on all four manifests, `gold.sh`'s tool existence checks on both arms. `heads.sh` and `sbflake.sh` were deliberately NOT copied — see the two rows above — so no unexercised driver ships here. |
| `a1/dut.sv` | **new** — the no-anchor group: owner order vs typedef-name order vs source order made to disagree, a within-class tiebreak, a singleton group, an anchored control group, and a cross-package + `$unit` group that decides the key's SPELLING. |
| `a2/dut.sv` | **new** — the class value parameter: written `string` / `int` / `int unsigned` / `byte` / `bit [7:0]`, two declarators on one line, and the two IMPLICIT controls. |

**A cited canary the script does not cover has shipped in this campaign, so I
grepped for every name the brief protects.** All 30 per-name canaries are in
`canaries.sh`'s `NAMES`, all 3 families are in `fams.sh`, and **none of the four
slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) appears in any driver** — they were never dispatched.

## 8. GATES — all five, with MY numbers

| gate | result |
|---|---|
| 1. `cmake --build build -j 3` | rc 0; md5 printed BEFORE and AFTER every build. `ee034515` (control) -> `186da424` (law 1) -> **`b66b7122`** (FINAL). **The md5 CHANGED at each step**, so no gate below ran on a stale binary. No rebuild happened while a sweep was running. **THE GATED BINARY IS THE SHIPPED SOURCE**: after gate 5 the restored source was rebuilt once more and came out `b66b71221f0672b192a3360b6b082b8e` again. |
| 2. 23 goldens, `SLANG_UHDM` exported to MY build | **PASS 23 / FAIL 0** |
| 2b. negative control `SLANG_UHDM=/bin/false` | **FAIL 23 / PASS 0** — the harness really used the exported binary |
| 3. uhdm2rtlil, `--mode testflags --jobs 2`, own `--out`/`--workdir` | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `csvdiff.py` vs `results/gate_uhdm2rtlil.csv` **ROW DIFFS 0** |
| 4. surelog, `--mode both --jobs 2`, own `--out`/`--workdir` | §9 |
| 5. byte verifier, BOTH corpora, same workdir paths | §10 |

## 9. GATE 4 — the surelog corpus

`--mode both --jobs 2 --out /tmp/r10uvm54_sl.csv --workdir /tmp/r10uvm54_sl_wd`,
`SLANG_UHDM` exported to my build, md5 `b66b7122` printed BEFORE and AFTER.

* `default` **467 CMP_EQUAL / 13 CMP_NOTEQUAL**; `testflags` **463 / 10** — both
  exactly the a4b4d8d figures the brief quotes.
* totals **930 CMP_EQUAL / 23 CMP_NOTEQUAL / 570 SLANG_REJECT / 48 SURELOG_FAIL
  / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM**.
* dump **390 match / 540 differ / 658 blank** — **the match counts DID NOT
  FALL** (390 = 225 default + 165 testflags).
* `csvdiff.py` vs `results/golden_surelog.csv`: **ROW DIFFS 0** — whole row,
  status AND dump.
* `LowMemPkg,testflags`' baseline row carries an absolute session-scratchpad
  path; it reproduced identically and is NOT touched and NOT reported as a
  regression.

**Canaries, spot-checked INDIVIDUALLY BY NAME**: `ok=58 changed=0 absent=0
unknown-names=8`, rc 0 — exactly pass 53's documented surelog numbers. Both live
fragile conversions intact: `InterfaceModPort` CMP_EQUAL/CMP_EQUAL,
`BlackParrotComplex` CMP_EQUAL/CMP_EQUAL. `ClassParamAsParam`, `ClassTypeParam`,
`SVSwitch`, `SimpleConstraint`, `ApbSlave`, `YosysBigSimReed`, `YosysOldOpen`,
`YosysOldOr`, `TypespecExpr`, `ClogCast`, `PartSelect4`, `Scr1SvTests`,
`BasicOh`, `Earlgrey_0_1`, `LowMemPkg` all at baseline. **The four target rows
are still `CMP_NOTEQUAL` (and `Scoreboard,testflags` still `SLANG_REJECT`) —
there is no conversion to report.**
**NEGATIVE CONTROL RE-RUN:** injecting `ZZZ_TYPO_NOT_A_TEST` into `NAMES` makes
it appear BY NAME as a ninth unknown (`ok=58 ... unknown-names=9`), so a typo'd
canary cannot read as green. **POSITIVE CONTROL:** the real list on the clean
surelog csv exits rc 0.
**FAMILY canaries** (`fams.sh`, which per-name lists cannot cover):
`Black` **34 rows IDENTICAL**, `EvalFunc` **10 IDENTICAL**, `ParamFile`
**8 IDENTICAL**, rc 0.
**The four slang-fenced tests (`UnsignedParam`, `HierPathEval`,
`FileLocalParam`, `TopParam`) were NEVER dispatched** and appear in no driver.

### 9a. per-row cmp, FINAL binary, straight out of the gate-4 workdir

`rowheads.sh /tmp/r10uvm54_sl_wd ... SimpleUVM SeqDriver BuildUVMPkg Scoreboard`:

| test | mode | cmp lines | heads |
|---|---|---|---|
| SimpleUVM | default / testflags | **13 / 13** | 1 / 1 |
| SeqDriver | default / testflags | **85 / 85** | 1 / 1 |
| BuildUVMPkg | default / testflags | **58 / 58** | 1 / 1 |
| Scoreboard | default | **13** | 1 |
| Scoreboard | testflags | SKIP-NOFILE (SLANG_REJECT at baseline) | — |

`Scoreboard` lands on `SimpleUVM`'s head. **`SeqDriver`'s is a THIRD family**, and
it is a MODULE LISTING, not a span or an alias:

```
LHS golden: class_typespec (adpcm_pkg::type_id) @440:12-440:31
            |vpiParent  module_inst work@top_tb          <- golden LISTS it
            |vpiInstance package adpcm_pkg
            |vpiParameter type_parameter (work@top_tb.adpcm_pkg::type_id.T)
RHS: <null>
```

440:12-31 is `uvm-1.2/src/macros/uvm_object_defines.svh:440`,
`typedef uvm_object_registry#(T,`"S`") type_id;` — the `uvm_object_utils` macro
body, read in the source, not inferred. The object EXISTS on our side (18 dump
lines in the control database, 84 in golden); what differs is its OWNER — golden's
detailed occurrences print `vpiParent module_inst work@top_tb`, ours print
`vpiParent class_defn (adpcm_pkg::adpcm_seq_item)` / `(adpcm_pkg::adpcm_driver)`. That is pass-50's R3 /
`§ modulePublishesPackageClasses45` territory, it is PRE-EXISTING (this law only
writes a span and an alias onto objects that already exist; it never creates a
module listing), and it is residue **R4b**.

**Both of `rowheads.sh`'s guards fired in the run that
produced this table** — `SKIP-NOFILE` for `Scoreboard,testflags` and
`UNKNOWN-NAME` for a deliberately injected `ZZZ_TYPO_NOT_A_TEST` — and a
defect in my own script was found and fixed by that run: its `rc=` column read
`$?` after a command substitution and printed `rc=0` for a cmp that had exited
255. It now captures cmp's own status and prints `cmp rc=255`.

## 10. GATE 5 — the byte verifier, BOTH corpora

Run BACKWARDS, as passes 50-53 did: the POST manifests come from the gate-3 and
gate-4 sweeps on `b66b7122`; then the source was restored to pristine a4b4d8d
(`git checkout a4b4d8d -- src/UhdmExporter.cpp include/UhdmExporter.h`, **never
`git stash`**), rebuilt — **the control md5 `ee0345153f52c86181b9e61f8015893b`
was REPRODUCED exactly** — and run into the **SAME workdir paths**. My edits were
copied to `/tmp/r10uvm54_mine/` first and put back afterwards; `git diff a4b4d8d`
after the restore is **byte-identical** to the diff taken before it (both
`md5 458ba0185d2bf4c781399a29ac8b032a`), printed as `RESTORE IS BYTE-IDENTICAL`.

Both control sweeps reproduced the committed baselines exactly
(`csvdiff.py` ROW DIFFS 0 against both), which independently validates them as
controls.

| corpus | head dbs | post dbs | paired | identical | DIFFER | UNPAIRED |
|---|---|---|---|---|---|---|
| uhdm2rtlil (`testflags`) | 679 | 679 | 679 | **679** | **0** | **0** |
| surelog (`both`) | 953 | 953 | 953 | **946** | **7** | **0** |

Path sets IDENTICAL on both corpora (UNPAIRED 0, printed explicitly).

### 10a. THE 7 MOVERS ARE EXACTLY THE 7 TARGET ROWS AND NOTHING ELSE

```
    [TARGET, and also KNOWN-NONDETERMINISTIC] default/Scoreboard-59431470/slang.uhdm
    MOVER default/BuildUVMPkg-bf853d43     MOVER testflags/BuildUVMPkg-bf853d43
    MOVER default/SeqDriver-32af76aa       MOVER testflags/SeqDriver-32af76aa
    MOVER default/SimpleUVM-1dc93a62       MOVER testflags/SimpleUVM-1dc93a62
```

**ZERO collateral out of 1632 databases** (679 u2r + 953 surelog), which is the
bar the brief set. `Scoreboard,testflags` is `SLANG_REJECT` and emits no database,
so seven movers is every comparable target row and nothing besides.

**Comparator NEGATIVE CONTROL, run:** flipping ONE character of ONE hash in the
u2r POST manifest makes `bvcompare.sh` report
`identical 678 / DIFFER 1 / MOVER testflags/1DUnpackedArray-a9848385/slang.uhdm`,
so a real difference cannot pass unnoticed. **Second guard, run:** joining the
u2r head manifest against the surelog post manifest gives
`paired: 0 / REFUSING TO REPORT: the two manifests share no path` and **exit 5**,
so a mis-paired verifier cannot report "0 differ".

### 10b. DETERMINISM — measured, because this law iterates a POINTER-KEYED map

`drainClassNestedTdGroups54` groups through a `std::map<const void*, ...>` keyed
by a slang symbol pointer, so the ORDER in which its alias `ref_typespec` objects
are minted — and therefore their UHDM ids and the serialized arena order — could
in principle vary run to run. **Measured with `detcheck.sh`, 4 runs each:**

| binary | input | distinct sha256 in 4 runs |
|---|---|---|
| FINAL `b66b7122` | BuildUVMPkg (44 groups, 97 aliases minted) | **1** |
| control `ee034515` | arm a1 | **1** |
| FINAL `b66b7122` | **Scoreboard** | **2** (runs 1-3 one hash, run 4 another, byte LENGTH identical) |

So this law's own ordering hazard does not materialise (BuildUVMPkg mints 97 alias
objects through the pointer-keyed map and is byte-stable 4/4). It is recorded as
residue **R10** rather than left silent, and `detcheck.sh` ships so the next pass
can re-measure it in seconds.

**Scoreboard's 2-of-4 is the KNOWN PRE-EXISTING macro-buffer flake, reproduced
here as the brief instructed** (re-run 4x per binary). It is why
`bvcompare.sh` labels Scoreboard's byte mover as *neither clean evidence nor a
clean pass*, and why the gate-5 mover list separates it from the six real ones.
Its cmp answer, by contrast, was stable at **13 lines / 1 head** in the gate-4
workdir.

## 11. RANKED RESIDUE — most reachable first, ONE number per residue

**R1. `classNestedTdCarriesSpecParams54` — a class-nested class-handle typedef of
a `#(...)`-SPECIALIZED generic carries the specialization's
`vpiParameter`/`vpiParamAssign` and a `vpiInstance` in golden, and none in ours.
DIRECTION: ADD. Depth: medium. RANK 1 — it is arm a1's cmp head and it is
PRE-EXISTING (a1's first 40 cmp lines are byte-identical before and after this
pass).** Witness, a1: golden `class_typespec (r54::h_only54) @78:13-78:16` carries
`vpiInstance package zbb54`, a `type_parameter (zbb54::r54::h_only54::T)` and a
`param_assign`; ours carries none. **NOT a corpus head**: in both UVM goldens
these objects have NO parameters and no instance (measured on
`uvm_abstract_component_registry::this_type` @13776 and on `uvm_agent::type_id`),
which is why a1 shows it and the corpus does not. Do not "fix" it from the corpus.

**R2. `typeParamAliasTdSpanIsParamDecl` — a class typedef whose target is a TYPE
PARAMETER takes the PARAMETER DECLARATION's span in golden and the typedef's own
span in ours. DIRECTION: RESHAPE (span only). Depth: shallow. RANK 2, and it is
the LAST non-EQ cell in both corpus cell tables (1 of 145 / 1 of 146).**
Witness: `uvm_pkg::uvm_sequencer_param_base::rsp_type`, golden
`53934:58-53934:61` (BuildUVMPkg) / `211:58-211:61` (SimpleUVM), ours
`53758:11-53758:14` / `35:11-35:14`, alias correctly NONE on both sides.
PRE-EXISTING at a4b4d8d and untouched here. It lives in
`§ typedefAliasSharesTypespec25`'s territory, not this pass's.

**R3. `classParamWrittenTypeOtherKinds54` — a class value parameter whose written
type is neither `string` nor `int` keeps our int_typespec. DIRECTION: RESHAPE
(kind + span). Depth: shallow for `byte`, medium for packed vectors. RANK 3, and
it is arm a2's cmp head.** Both sides measured in §4a: `byte bcell` golden
`byte_typespec @38:18-38:22` with `vpiSigned:1`, ours `int_typespec @38:18-38:32`;
`bit [7:0] vcell` golden `bit_typespec @41:18-41:27`, ours
`int_typespec @41:18-41:41`. DELIBERATELY declined here: no corpus row needs it
and the packed-vector half needs a range rule no arm measures.

**R4. `typeParamTypedLocalIsRefVar` — a local variable whose declared type is a
class TYPE PARAMETER is a `ref_var` in golden, typed by the PARAMETER's own
typespec; we emit an `int_var` typed by its own declaration. DIRECTION: REPLACE.
Depth: unknown. RANK 4, and it is BuildUVMPkg's FINAL cmp head (58 lines).**
Witness in §6. PRE-EXISTING.

**R4b. `moduleOwnsPackageClassTdBase` — golden RE-PARENTS a class-handle typedef
group's BASE onto the TOP MODULE (`vpiParent module_inst work@top_tb`, plus the
package's `vpiInstance` and the specialization's `vpiParameter`); we leave the same
object parented at a `class_defn`. DIRECTION: MOVE (the parent/listing).
Depth: medium. RANK 4b, and it is SeqDriver's FINAL cmp head (85 lines, both
modes) — the only one of the seven rows whose head is not shared with another
row.** Measured on the CONTROL database, so **PRE-EXISTING** is a measurement and
not an argument: the object `class_typespec (adpcm_pkg::type_id) @440:12-31`
exists on BOTH sides (84 dump lines in golden, 18 in the control database), and
the printed `vpiParent` of its detailed occurrences is
`module_inst work@top_tb` on the golden side against
`class_defn (adpcm_pkg::adpcm_seq_item)` / `class_defn (adpcm_pkg::adpcm_driver)`
on ours. Same family as pass-50's R3; belongs with
`§ modulePublishesPackageClasses45`.

**R5. `classNewCallUnderAssignment` — `uvm_registry.svh:207`'s
`... = new(...)` gives golden a `method_func_call (new)` under the assignment that
we do not emit at all. DIRECTION: ADD. Depth: unknown. RANK 5, and it is
SimpleUVM's FINAL cmp head (13 lines).** Witness in §6. PRE-EXISTING.

**R6. `scopedClassTsNameDropsSpecialization` — a SCOPED, `#(...)`-spelled class
handle is NAMED with the parameter text included. DIRECTION: RESHAPE (name only).
Depth: SHALLOW. RANK 6.** Pass 53's R2, carried forward UNCHANGED and NOT
re-measured here. Site: `grep -n 'rawText(sn0->sourceRange())' src/TypeEmit.cpp`.

**R7. `containerPrefixJoiner` for pass-50 law 4's alias fullnames — law 4 writes
`clsName + "::" + name` where `clsName` can be the SHORT class name.
DIRECTION: REPLACE. Depth: shallow. RANK 7, and it is DUMP-ONLY
(`BaseClass::Compare` never reads `VpiFullName`).** Measured here on both UVM
tests: golden `uvm_pkg::uvm_callbacks::this_type`, ours
`uvm_callbacks::this_type`; a1 golden `r54::b_owner54::ka_bbb54`, ours
`b_owner54::ka_bbb54`. **This pass's own law writes the FULL key and is
byte-equal to golden**, so the fix is to route law 4 through
`surelogClassKey54` — one line, but it changes bytes on every law-4 row and needs
its own five-gate run.

**R8. `assocArrayVarCarriesElemSign` — golden puts `vpiSigned` on the array_var of
a signed-element assoc/queue/dyn array, we put it on the element reg.
DIRECTION: MOVE. RANK 8.** Pass 52's R4 / pass 53's R5, carried forward
UNCHANGED and NOT re-measured here.

**R9. the `LHSgolden=BOUND / RHSours=NONE` half of the ref_obj binding table —
302 disagreements. DIRECTION: ADD. Depth: unknown. RANK 9.** Pass 53's R6,
carried forward UNCHANGED and NOT re-measured here.

**R10. `classNestedTdGroupPointerOrder54` — `drainClassNestedTdGroups54` iterates
a `std::map<const void*, ...>` keyed by a slang symbol pointer, so its alias
objects' MINT ORDER (hence their UHDM ids and the arena order) is pointer-order
dependent. DIRECTION: REORDER (sort the groups by their base's (owner, name)).
Depth: shallow — 6 lines. RANK 10, and it is NOT observed: `detcheck.sh` gives
1 distinct sha256 in 4 runs on BuildUVMPkg and 4 on arm a1 (§10b).** Not taken
here because taking it would change the mint order and therefore invalidate the
five gates already run on `b66b7122`; it is the first thing to fold into the next
pass that re-gates this file anyway.

## Corrections applied at integration by the master (verifier C1-C10)

**C1 — A CITED INSTRUMENT THAT DOES NOT EXIST, and it carried this pass's CENTRAL
refutation.** Sections 2 and 3b attributed the base-pick result
("OWNER-FIRST-OK 9, REFUTED 0 / 4, REFUTED 0 — 13 groups, zero counter-examples")
to a tool called `basecheck`. I checked myself: `grep -rln basecheck` in this
directory hits **only README.md**, and `tdgroup.py` exposes exactly
`groups|parents|rows|summary`. **The headline result was not reproducible as
written.** The CONCLUSION survives — the verifier reproduced it with a substitute
(golden's alias-fullname SET per group is identical to the non-base member set, so
set equality implies the same base pick): **BuildUVMPkg 9 groups, 0 base-pick
mismatches; SimpleUVM 6, 0.** Its SimpleUVM count is 6 where this README says 4,
because the counting base differed and the original tool never shipped. Zero
counter-examples on either corpus stands.

**THIS IS THE THIRD CONSECUTIVE PASS WITH THIS DEFECT CLASS** — a cited guard that
did not exist, then a cited canary the script did not cover (52 rows across three
families), now a cited instrument that was never written. Every claim's instrument
must be RUN, not named.

**C2 — a cited NEGATIVE CONTROL that cannot fire.** `tdgroup.py`'s union self-test
passes under BOTH readings of the mutation its comment prescribes, because max
`occ` in the fixture is **1** and the "abbreviated" occurrence sits under
`vpiActual` while `collect()` filters `rel == 'vpiTypedef'` — so the docstring's
"printed once WITH children and once ABBREVIATED" is false for `collect()`. The
union path IS load-bearing (SimpleUVM golden has rows with occ 2, 5 and 26), so
the code is right and the control is vacuous. Its SECOND cited control (the
vpiParent key) DOES fire verbatim.

**C3 — same defect in `clsparam.py`**: its documented negative control does not
fire (every write site is already guarded). The mutation that DOES pin it is
row-level (`rows.setdefault` -> fresh row), which fails with the exact quoted
message. The comment must name that mutation.

**C4 — THIS README "CORRECTED" THE MASTER'S CENSUS BY COMPARING TWO DIFFERENT
TESTS.** Section 1 set the brief's `226`/`61` and `195`/`10` beside BuildUVMPkg's
`336`/`89` as though the brief needed correcting. Those brief figures are
**SimpleUVM** and the verifier measured them EXACTLY. A CORPUS CONFLATION
PRESENTED AS A REFUTATION — the same error class the campaign has hit with
uvm-1.2 versus 1800.2 line numbers, and the reason every figure must name its
test. The census was right, and the law does exactly what it predicted: at FINAL
ours has **1** `ref_typespec (uvm_pkg::uvm_set_before_get_dap::type_id)` and **2**
occurrences of the string against golden's 1 and 2, and on BuildUVMPkg
`ref_typespec (uvm_pkg::<cls>::type_id)` goes **2 -> 89** against golden's **89**.

**C5 — BuildUVMPkg's CONTROL dump distance is 168297, not 168339** (re-measured
twice, with that database shown byte-stable 4/4 on the control binary). The other
three dump figures are exact.

**C6 — `rsp_type`'s ours-side span is one line low in three places**: stated
`53758:11-14` / `35:11-35:14`, measured `53759:11-53759:14` / `36:11-36:14`.
pp_output 53758 is `typedef REQ req_type;`; 53759 is `typedef RSP rsp_type;`.

**C7 — R2's name is not supported by its own witness.**
`typeParamAliasTdSpanIsParamDecl` claims golden takes "the PARAMETER DECLARATION's
span", but golden's `53934:58-61` sits inside `extern function void
m_last_req_push_front(REQ item);` — a method prototype's ARGUMENT.

**C8 — the determinism cell measured the wrong binary.** Section 10b's a1 cell runs
on the CONTROL binary, which has NO DRAIN, so it says nothing about R10. Re-run on
FINAL: **1 distinct hash over 4 runs**. And Scoreboard re-run 4x per binary gives
**FINAL 3 distinct / CONTROL 2 distinct** — so the flake is PRE-EXISTING, which is
the control cell 10b omitted. A determinism claim about a law must be measured on
the binary that HAS the law.

**C9 — minor**: section 7 says "all 30 per-name canaries are in `canaries.sh`'s
NAMES"; NAMES has **37** entries, and all 30 brief-protected names are present
(verified by name).

**C10 — minor**: `canaries.sh`'s header still carries pass 53's `ok=52
unknown-names=7 … eighth unknown` figures, which its own body now contradicts.
