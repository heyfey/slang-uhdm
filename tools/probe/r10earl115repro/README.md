# r10earl115 — § `patGenCaHierPathElemNoBind115` — **A PATTERN-CARRIED `hier_path` IN AN ELABORATED GENERATE SCOPE BINDS ITS FIRST PATH ELEMENT AND LEAVES EVERY ELEMENT AFTER IT BARE, BECAUSE SURELOG HANDS UHDM'S ELABORATOR TAGGED PATTERNS WHERE WE HAND IT AN ALREADY-FLATTENED OPERAND LIST** — the Earlgrey_0_1 testflags element head CLEARED, the judge's next object named

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance
judge.  The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `89631b31` |
| pristine binary | md5 `fc4c6d192b7e39bf2e48728a17a6e29f`, built from this pass's OWN worktree at a clean `89631b31` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary | md5 `3c7aef193c82b156aee0ff76a5de2a89`, frozen `chmod 555`.  TWO EARLIER CUTS WERE BUILT AND CONVICTED BY THE WIDE BOUNDARY BEFORE THIS ONE (§6c): `d591540ed6d388a7e3e94d06dfd0fdad` (no namesake fence, no nested-instance fence) scored **AWAY 10 / 2 / 12** on three r10vearl113 arms, and `c848358c09a7d49b6654ee1dad0f71bd` (namesake walk stopping at the module's own body) still scored **AWAY 4** |
| production surface | `src/ModuleEmit.cpp` + `include/UhdmExporter.h` + `uhdm_main.cpp` (one recorder at the existing `flattenPatternCaRhs` call site, one post-elaborator walk, one call) |
| probe surface | `tools/probe/r10earl115repro/` only |
| the head | **Earlgrey_0_1/testflags, 37 cmp lines, ONE head → 92 cmp lines, ONE head.**  The failing field was a `Path_elems` element's `Actual_group` on the `hier_path` `tl_h_i[0].a_valid` (`tlul_socket_m1.sv:109`): `design::Compare` returned **−1** through the VECTOR SafeCompare over `Path_elems` and then the SINGULAR `ref_obj::Actual_group` SafeCompare with `LHS: <null>` against our `typespec_member('a_valid')` (`tlul_pkg.sv:33`).  It now returns **−1** on a DIFFERENT object — golden's `tagged_pattern` at `tlul_socket_m1.sv:241` against our flattened `bit_select` operand.  **THE LINE COUNT IS THE HEAD OBJECT'S DECOMPILE SIZE, NOT A DISTANCE** (RESUME.md §9's ladder law): a `tagged_pattern` carrying a `bit_select`, its `logic_var` actual, its index constant and a `ref_typespec` decompiles larger than a bare `typespec_member`. |
| Earlgrey_0_1/default | **31 lines, 1 head, cmp log BYTE-IDENTICAL** — r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null, untouched |
| goldens | 23 PASS / 0 FAIL on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| arm grid | 3 NEW arms + every arm the wide boundary flagged (r10earl112/113/114 and their verifiers), **27 arm files × 2 views = 54 arm/views**, 2 census families, calibrated golden-vs-golden with **ALL cells `SAME_AGREE`, 0 phantoms on every one**: **AWAY 0 and MOVED-WRONG 0 IN EVERY ARM/VIEW OF BOTH FAMILIES**, `PX` TO-GOLDEN 363, `P0` TO-GOLDEN 390.  THREE arms go from a head to fully CMP-EQUAL: `p1_pos115` **37 cmp lines / 1 head → 0 / 0**, r10vearl113's `v1_decl113` **37 / 1 → 0 / 0** and `v4_ctx113` **37 / 1 → 0 / 0** |
| corpus census | 2314 databases, both corpora × both modes, golden halves asserted byte-identical between the two sweeps: surelog **PX TO-GOLDEN 34 / AWAY 0 / MOVED-WRONG 0 / NOGOLD-MOVED 0**, **P0 identical**; uhdm2rtlil **not one cell of either family moved, and STILLWRONG 0** |

---

## 1. THE JUDGE, DECODED FIRST — `own115`, `sig115`, and what the head actually is

RESUME.md §9's head-decode discipline: read the generated `Compare` ORDER before
naming a field.  For a `hier_path` that order is

```
hier_path::Compare
  -> expr::Compare
       -> BaseClass::Compare   VpiType, VpiName, VpiDefName     (earl112 closed)
       -> VpiDecompile         (string compare)
       -> VpiSize              (int subtraction)                (earl113 closed)
       -> Typespec             (SafeCompare, singular)          (earl114 closed)
  -> Path_elems                (SafeCompare, VECTOR)            <-- THIS PASS
  -> Root_value                (SafeCompare, singular)
  -> VpiName                   (string compare)
```

and the VECTOR SafeCompare descends into each element with that element's OWN
generated `Compare`.  `ref_obj::Compare` (UHDM generated `ref_obj.cpp:122-156`)
reads **VpiType, VpiName, VpiDefName, VpiGeneric, `Actual_group`,
VpiStructMember** — and `bit_select`, `var_select` and `ref_var` inherit it.
So `Actual_group` on a path element IS a compared field, on all four kinds.

`own115 head` on this pass's own pristine build of arm `t3_member114`'s
elaborated view (which reproduces the corpus head byte for byte, 37 lines / 1
head on both):

```
== ITERATION 0 : design::Compare -> -1
   HEAD LHS(golden) = <null>
   HEAD RHS(ours)   = typespec_member name='a_valid'  @ 19:17-19:24
   OWNING hier_path (ours side), element index 1:
     hier_path name='tl_h_i[0].a_valid' size=0
        ts=ref_typespec(name='',dn='')->array_typespec('')   @ 47:32-47:49
     scope=gen_scope gd=1  carrier=operation(op75)<-cont_assign<-gen_scope
   OURS   Path_elems (2):
     [0:first] bit_select   name='tl_h_i'   ACTUAL -> array_var('tl_h_i')@module_inst
     [1:trail] ref_obj      name='a_valid'  ACTUAL -> typespec_member('a_valid')@struct_typespec
```

and `own115 paths`, which pairs EVERY `hier_path` in the two databases on
line/col + name (the key deliberately drops `VpiFile`: golden's hier_paths carry
the source path and ours are empty — RESUME.md §9's own note — and keying on it
joins **0 of 51** golden keys), reads golden's side of the same objects:

```
-- KEY 109:32-109:49|tl_h_i[0].a_valid   scope=gen_scope gd=1
   G: first:bit_select->array_var('tl_h_i')@module_inst ; trail:ref_obj-><null>
   O: first:bit_select-><null>                          ; trail:ref_obj-><null>
```

**Four facts the judge hands over, none inferred:**

1. **THE PASS BRIEF'S FRAMING IS REFUTED, AND THIS IS THE FIRST THING MEASURED.**
   The brief says "golden binds the FIRST element to the root object and leaves
   the TRAILING member elements bare; we do the opposite (member bound through
   the typespec road, first element bare)".  The FIRST HALF is right and the
   SECOND HALF IS WRONG: **we bind the first element too**, to the same
   `array_var`, on the head object and on every arm cell (`sig115`'s whole-arm
   census below, `pos=first ek=bit_select ACT=array_var` on both sides).  What
   we do is bind the first element AND the trailing one; golden binds the first
   ONLY.  **There is therefore ONE half-law here, not two** — suppress the
   trailing binds — and §3 measures the "add the first-element bind" half as
   already satisfied rather than shipping code for it.
2. **IT IS EVERY NON-FIRST POSITION, NOT THE LAST ONE.**  Arm `p1_pos115` runs
   2-, 3- and 4-component paths: golden leaves the ONE middle of a 3-component
   path and BOTH middles of a 4-component path bare as well as the trailing
   element, and we bound all of them.
3. **IT IS EVERY ELEMENT KIND.**  A trailing `ref_obj` member, a trailing
   `bit_select` (`tl_h_i[i].a_data[0]`) and a middle `bit_select`
   (`three_i[i].lo.f1[2]`) all bind on our side and are all bare in golden.  A
   trailing `indexed_part_select` is bare on BOTH sides already (neither UHDM
   arm writes it), which is why the law's clear-list is the four `ref_obj`-rooted
   kinds and nothing else.
4. **THE NEXT FIELD, READ AND NOT PREDICTED.**  The patched database's head is
   what the judge reports on it: a `tagged_pattern` at `tlul_socket_m1.sv:241`
   whose `Pattern` is a `bit_select` — golden did not flatten that member and we
   did.  `HEAD_AFTER_Earlgrey_testflags.cmp` holds it; it is R0 (§7).

---

## 2. THE DECODE — UHDM'S OWN SOURCE, READ, NOT INFERRED

**Both emitters hand the SAME code the same job.**  `uhdm_main.cpp` mirrors
Surelog's `UhdmWriter.cpp:5195-5199` argument for argument —
`ElaboratorContext(&s, false, false)`, `uniquifyTypespec(false)`,
`listenDesigns`, then `UhdmAdjuster` — so any divergence is in the TREE the
elaborator is handed, not in the elaborator.

**And BEFORE it runs, the two databases AGREE.**  Measured, not assumed: in the
PLAIN view every path element of every arm is bare on both sides — `sig115`
scores `p1` 48, `p2` 62, `p3` 58, `t1` 93, `t2` 58, `t3` 105, `t4` 78 cells, all
`SAME_AGREE`, **0 differing**.

### 2a. the two writers of a path element's `Actual_group`

**(i) `ElaboratorListener::leaveRef_obj`** (`~/git-repos/UHDM/templates/
ElaboratorListener.cpp:1499-1508`), reached from `leaveBit_select` /
`leaveVar_select` / `leavePart_select` / `leaveIndexed_part_select`:

```cpp
  const any* actual = (any_cast<ref_obj*>(object))->Actual_group();
  const any* parent = object->VpiParent();
  // Hier path binding leaf node is more accurately done in the clone_tree
  // operation because of variable name scope shadowing issues.
  if ((!actual) || (actual && parent && parent->UhdmType() != uhdmhier_path)) {
    if (any* res = bindAny(object->VpiName())) ((ref_obj*)object)->Actual_group(res);
  }
```

`bindAny` (same file, :899-939) searches the instance stack's netMap / paramMap /
modMap **by NAME**.  A path's FIRST element carries the ROOT signal's name and is
answered; a member element carries a STRUCT MEMBER's name and is not.  That is
the whole of golden's positive half, and it is why golden's first element is
bound and its members are not.

**(ii) `hier_path::DeepClone`** (`~/git-repos/UHDM/templates/clone_tree.cpp:
895-2190`) walks `Path_elems` PAIRWISE and resolves each element against the
PRECEDING one's `Actual_group`.  Its `uhdmarray_var` arm walks
`array_typespec → Elem_typespec → struct_typespec` and writes

```cpp
  for (typespec_member* member : *stpt->Members())
    if (member->VpiName() == name) { cro->Actual_group(member); previous = member; found = true; break; }
```

— the "typespec road", and the `uhdmtypespec_member` arm one level down repeats
it, which is how a THREE-component path gets both its middle and its trailing
element bound in one walk.  The predecessor is bound INSIDE the same walk,
because `bit_select::DeepCopy` (UHDM generated `bit_select.cpp:82-84`) ends in
`elaboratorContext->m_elaborator.leaveBit_select(clone, nullptr)`.

### 2b. why the two emitters diverge: WHAT the elaborator is handed

`cont_assign::DeepClone` (`clone_tree.cpp:764-826`) deep-clones the Rhs and then,
when the Lhs is a `ref_obj` whose `Actual_group` is a `struct_var`, runs
`ExprEval::flattenPatternAssignments` (`templates/ExprEval.cpp:750-935`) and
REPLACES the operand vector.  That function's operand loop bails at the first
operand that is not a `tagged_pattern`:

```cpp
  } else if (oper->UhdmType() == UHDM_OBJECT_TYPE::uhdmoperation) { return result;
  } else if (oper->UhdmType() == UHDM_OBJECT_TYPE::uhdmconstant)  { return result; }
```

* **SURELOG hands it TAGGED PATTERNS.**  Measured directly, `surelog -parse
  -elab` (the pre-UHDM-elaboration golden) on arm `t3_member114`:
  `gen_m1[0] → cont_assign → operation → tagged_pattern ×3`, and every path
  element bare.
* **WE hand it the ALREADY-FLATTENED list.**  `flattenPatternCaRhs`
  (`src/ModuleEmit.cpp`, r10earl113/114's site) replaces the tagged patterns with
  the bare member values in the ELABORATED gen-scope arm, so the operands are
  plain `hier_path` / `constant` / `ref_obj` objects.

The consequence is a matter of record on both sides, read off the final
databases with `gs2` (which prints the LIVE `Gen_scope_arrays()` vector, not
`AllObjects`):

```
GOLDEN gen_m1[0]  CA lhs=ref_obj(act=struct_var) rhs=operation
   operand hier_path 'tl_h_i[0].a_valid' : bit_select(act=array_var) ref_obj(act=<null>)
OURS   gen_m1[0]  CA lhs=ref_obj(act=struct_var) rhs=operation
   operand hier_path 'tl_h_i[0].a_valid' : bit_select(act=array_var) ref_obj(act=typespec_member)
```

Two consequences this pass acts on:

**(a) THE FIX HAS TO BE A POST-ELABORATOR PASS.**  The objects the served design
holds are the ELABORATOR'S CLONES of the emitted ones (`applyCaCastAdjust106`'s
own decode says the same thing for its field), so an emission-time change
cannot reach them.  `applyPatCaElemUnbind115` therefore records a KEY at
emission — gen-scope FULLNAME + the cont_assign's SPAN + the Lhs BASE NAME,
exactly r10earl106's key — and consumes it after `UhdmAdjuster`.

**(b) THE GATE IS NOT "EVERY GEN-SCOPE PATTERN".**  §3 measures four gen-scope
shapes where GOLDEN BINDS.

---

## 3. THE GOLDEN GRID — 14 arm/views, two census families

`grid115.sh` builds them, `sig115` reads them (a `UhdmListener` walk of the LIVE
design, not `Serializer::AllObjects`, so r10earl114's R3 arena orphans cannot
put a phantom `<null>` into a payload set), `sig115.py` scores `PX` (span + name
+ element index/position/kind + the SCOPE × CARRIER × ROOT-VALUE matrix) and
`P0` (the coarse key, which is what catches a cell whose root kind differs
between the two emitters).  `GRID.r10earl115.txt` holds every row and
`CALIB.r10earl115.txt` the golden-vs-golden calibration.

**Arm `p1_pos115` — THE POSITION AXIS.**  Five cells, all the head-reproducing
carrier (generate-for at depth 1, KEYED pattern in a continuous assign onto a
gen-local packed struct), varying the path LENGTH so "middle" is populated by
real cells:

| cell | path | golden, elaborated | ours, pristine | ours, patched |
|---|---|---|---|---|
| n1 | `two_i[i].a_valid` (2 components) | first BOUND, trail **bare** | trail bound | **bare, TO-GOLDEN** |
| n2 | `three_i[i].lo.f0` (3) | first BOUND, mid **bare**, trail **bare** | both bound | **both bare, TO-GOLDEN** |
| n3 | `four_i[i].md.lo.f0` (4) | first BOUND, TWO mids **bare**, trail **bare** | all three bound | **all bare, TO-GOLDEN** |
| n4 | `two_i[i].a_data[0]` (trailing SELECT) | trail `bit_select` **bare** | bound | **bare, TO-GOLDEN** |
| n5 | `three_i[i].lo.f1[2]` (middle-carrying select) | mid + trail **bare** | bound | **bare, TO-GOLDEN** |

**Its elaborated view is 37 cmp lines / 1 head on the pristine binary and
0 lines / 0 heads on the patched one — the arm is fully CMP-EQUAL.**

**Arm `p2_root115` — THE ROOT-KIND AXIS and THE DEPTH AXIS.**  A PORT unpacked
array (`array_var`, the corpus root), a MODULE-BODY unpacked array, a
`wire`-declared array (`array_net`), and the same leaf at generate depth 1,
depth 2 and in a generate-IF: golden leaves the non-first elements bare in ALL of
them, whatever the root's kind and whatever the depth, and all move here
(`PX`/`P0` TO-GOLDEN 23, AWAY 0).  **Two cells were CUT after being run, not
guessed away**: an undotted MODULE-BODY struct read from inside a generate scope
and a GEN-LOCAL struct root both draw `[ERR:UH0725] Unresolved hierarchical
reference` from Surelog's elaborator, and an arm whose golden is an error message
is not an arm that tests anything.  r10earl114's `t1_root114` carries the
gen-local half of that fence and the wide boundary re-scores it here (§6b).

**Arm `p3_fence115` — THE MUST-STAY FLOOR and THE AWAY RISKS.**  Every cell is a
shape where golden BINDS the non-first elements, or where the two emitters
already agree:

| cell | shape | golden | pristine → patched |
|---|---|---|---|
| x1 | MODULE-SCOPE keyed pattern | **BINDS** | **UNCHANGED** |
| x2 | gen-scope keyed pattern, target declared in the MODULE BODY, WHOLE-NAME Lhs (= r10earl114 t4 f2 = r10earl113's x2) | **BINDS** | **UNCHANGED — the fence** |
| x3 | gen-scope POSITIONAL pattern | **BINDS** | **UNCHANGED** |
| x4 | gen-scope PLAIN `cont_assign` Rhs (no pattern) | **BINDS** | **UNCHANGED** |
| x5 | gen-scope BINARY-OPERATION operand | **BINDS** | **UNCHANGED** |
| x6 | gen-scope `always_comb` pattern | bare | **UNCHANGED** (already agreed) |
| x7 | gen-scope keyed pattern with a SELECT Lhs (module-scope array element) | bare | **bare, TO-GOLDEN** |
| x8 | gen-scope keyed pattern, member value is a USER CALL argument | bare | the call's own operand **UNCHANGED** (residue R2); the sibling plain member **TO-GOLDEN** |

The x1..x6 rows are a `diff` of the arm's pristine and patched element censuses,
span by span, not a score summary — `p3_fence115_elab` moves at 80:37 / 81:37
(x7) and 92:32 (x8's sibling) and **at no other span**.

**THE TWO-FAMILY SCORE over all 14 arm/views** (`GRID.r10earl115.txt`):

```
PX  TOGOLD=147  AWAY=0  MOVEDWRONG=0   (NOGOLD_MOVED 9, all in r10earl114's
                                        t1 gen-local-root and t4 iface cells,
                                        where OUR root kind differs so the PX
                                        key does not join)
P0  TOGOLD=156  AWAY=0  MOVEDWRONG=0   NOGOLD_MOVED=0
CALIBRATION golden-vs-golden: PX 1212 cells, P0 1116 cells, ALL SAME_AGREE, 0 phantoms
PLAIN VIEWS: not one cell moved on any arm — the definition listing is inert
```

---

## 4. THE LAW

> **§ `patGenCaHierPathElemNoBind115`.**  A `hier_path` that is an OPERAND of an
> assignment-pattern operation in an ELABORATED GENERATE-SCOPE continuous assign
> binds `Path_elems[0]` to the root object and carries **NO `Actual_group` on any
> element after it** — not on a member `ref_obj`, not on a middle one, not on a
> trailing or middle `bit_select`.
>
> **EXCEPT in the three shapes where GOLDEN BINDS every element through
> `hier_path::DeepClone`'s typespec road and we already match:**
>   * a WHOLE-NAME Lhs whose target is declared OUTSIDE the generate block;
>   * a gen-local target whose NAME ALSO EXISTS as a variable, net or port of the
>     enclosing module — or of any module ABOVE it in the hierarchy (the
>     `CompileHelper::bindVariable` recursion `bindVariable(component,
>     scope->VpiParent(), …)`, which does not stop at a module boundary).  An
>     enclosing GENERATE BLOCK's namesake does NOT count;
>   * a gen scope inside a module instance that is ITSELF instantiated inside a
>     generate block.

### STATED GATE == CODE GATE

**STATED:** the continuous assign is emitted in the ELABORATED gen-scope arm of
`emitBlock`; its Rhs is a STRUCTURED assignment pattern and its Lhs type is a
packed struct (`patFlat9`, the pre-existing `flattenPatternCaRhs` gate); and its
Lhs is NOT a whole-name reference to a symbol declared outside every enclosing
generate block.

**CODE:** inside the existing `if (patFlat9 && rhs && rhs->UhdmType() ==
uhdmoperation)` block in `src/ModuleEmit.cpp`, `lsym115 && !lsym115->name.empty()
&& !(lhsWholeRef115 && !lhsGenLocal115)` records
`{gen-scope fullname, cont_assign span, Lhs base name}`; `applyPatCaElemUnbind115`
walks the design's **TOP MODULES ONLY**, descends `Gen_scope_arrays` →
`Gen_scopes`, matches that key, and for a Rhs `operation` with
`vpiAssignmentPatternOp` clears `Actual_group` on `Path_elems[1..]` of every
`hier_path` operand.  There is no condition in the code that is absent from the
prose and none in the prose that is absent from the code.

### the fences, each of them a measured cell

| fence | what it keeps out | the cell that measures it |
|---|---|---|
| (a) the SITE (`patFlat9` at `flattenPatternCaRhs`'s call) | every carrier we do not pre-flatten — the POSITIONAL pattern, the plain Rhs, the binary operand, the `always_comb`/`initial` pattern | `p3` x3/x4/x5/x6, all UNCHANGED; r10earl114 `t2` c2/c4/c5/c6/c7 |
| (b) TOP MODULES ONLY in the walk | the whole definition listing | every arm's PLAIN view scores 0 moved cells, and the ELAB view's `SC=module_inst/gd0` def copies are unmoved |
| (c) gen scopes only in the walk | the MODULE-SCOPE pattern, which golden BINDS | `p3` x1 and r10earl114 `t3` d0 / `v_o`, UNCHANGED |
| (d) `!(lhsWholeRef115 && !lhsGenLocal115)` | a gen-scope pattern whose target is declared in the MODULE BODY and read through a whole-name Lhs — golden binds it | `p3` x2 = r10earl114 `t4` f2, byte-identical pristine vs patched, and its payload counts match golden's exactly |
| (f) `!lhsNamesake115` — the NAMESAKE walk, climbing PAST the module boundary | a gen-local target whose name also exists in this module's body or in ANY module above it | r10vearl113 `v6_name113` g2 (a module-body NET), g5 (the module's own PORT), g3 (a namesake declared AFTER the block), `v1_decl113` a3 (a shadowed module-body variable) and a7 (the namesake ONE HIERARCHY LEVEL UP) — **26 cells that scored AWAY before this fence existed (§6c)**.  `v6_name113` g4 (an ENCLOSING GENERATE BLOCK's namesake) and g6 (no namesake, the positive control) keep the law and are measured `SAME_AGREE` / `TOGOLD` |
| (g) `genAbove` in the walk | a gen scope inside a module instance that is itself inside a generate block | r10vearl113 `v4_ctx113` e2: golden binds under `u_c` (instantiated in `gen_inst[k]`) and leaves bare under `u_a` / `u_b` (module scope) — read off golden's own parent chains with `chain115`.  The corpus head is NOT fenced by this: `u_sm1_17` is a direct child of `u_xbar_main` |
| (e) the key (fullname + span + Lhs name) | any cont_assign the emitter did not record, including one sharing a gen scope with a recorded comma-list sibling (r10v106's own trap) | the corpus census `PR`-equivalent: only the 34 predicted joined keys moved |

### the hypotheses this pass REFUTED

| candidate | refuted by |
|---|---|
| "our FIRST element is bare and golden's is bound" (the brief's framing) | `own115` and `sig115` on the head object and on every arm: `pos=first ek=bit_select ACT=array_var` on BOTH sides, pristine and patched |
| "this is TWO half-laws" | the same measurement — the first-element half is already satisfied, so shipping code for it could only move a cell that is already golden's |
| "it is only the TRAILING element" | `p1` n2/n3 — a 3-component path's middle and a 4-component path's two middles are bare in golden and were bound here |
| "it is only a `ref_obj` element" | `p1` n4/n5 — a trailing and a middle `bit_select` behave identically |
| "every gen-scope pattern is bare in golden" | `p3` x2 (module-body target) — golden BINDS, and this is the fence the law needed |
| "the axis is the SCOPE (gen vs module)" | `p3` x3/x4/x5 — three gen-scope carriers golden BINDS, all outside our pre-flatten site |
| "the emitters disagree before elaboration" | the PLAIN view of all 7 arms: every element bare on both sides, 0 differing cells |
| "clearing this field clears the head" | §1 fact 4 and §6 — the head becomes golden's unflattened `tagged_pattern` at `tlul_socket_m1.sv:241` |
| "a gen-scope keyed pattern onto a gen-local target is always bare in golden" | r10vearl113's `v6_name113` and `v1_decl113` — a NAMESAKE anywhere up the hierarchy makes golden bind, and the wide boundary convicted the first cut on exactly those cells |
| "the enclosing module instance's own context does not matter" | `v4_ctx113` e2 — ONE child module, four instances, and golden binds only in the two instantiated inside a generate block |

---

## 5. THE CORPUS CENSUS AND THE PREDICTION

`censweep115.sh` runs `sig115` over every database of all four sweeps with an
ACCOUNTING PASS on each (surelog LISTED 1573 / PROCESSED 956 / SKIPPED 617 /
TOOLFAIL 0; uhdm2rtlil LISTED 1462 / PROCESSED 1358 / SKIPPED 104 / TOOLFAIL 0,
identical for the pristine and the patched sweep), and **the two sweeps' GOLDEN
halves are asserted byte-identical before anything is scored** (`cmp -s`: they
are, for both corpora).  `cen115.py` joins them as a MULTISET per database.

| corpus | family | TO-GOLDEN | AWAY | MOVED-WRONG | NOGOLD-MOVED | SAME_AGREE | STILLWRONG |
|---|---|---|---|---|---|---|---|
| surelog | **PX** | **34** | **0** | **0** | **0** | 169964 | 2321 |
| surelog | **P0** | **34** | **0** | **0** | **0** | 108845 | 122 |
| uhdm2rtlil | **PX** | 0 | **0** | **0** | **0** | 8020 | **0** |
| uhdm2rtlil | **P0** | 0 | **0** | **0** | **0** | 7682 | **0** |

* **AWAY 0 and MOVED-WRONG 0 in every family of both corpora**, and every moved
  cell is in ONE row: `testflags/Earlgrey_0_1`.
* uhdm2rtlil's **STILLWRONG 0** says the element-binding family was already
  closed there before this pass; its 8020 `PX` cells are the control that the
  instrument can see and that the law does not fire where it must not.
* surelog's `PX` STILLWRONG 2321 / `P0` 122 are pre-existing divergences this law
  does not own (R2/R3 below), byte for byte what the pristine binary produced.

### THE PREDICTION, made from the PRISTINE databases FIRST

`predict115` reads only OUR pristine databases (it never sees a patched one) and
applies the law's gate expressed in UHDM terms — the same three halves the
record site applies in slang terms.  `PREDICT_sl.txt` / `PREDICT_u2r.txt`,
frozen before the patched binary was built:

```
surelog     bound non-first elements in gen-scope patterns : 464
            PREDICTED MOVE cells                           : 464
            FENCED KEEP cells                              : 0
            ROWS PREDICTED TO MOVE (1): testflags/Earlgrey_0_1-71da2fd7
uhdm2rtlil  gate-matching cells 0, rows 0, over 1358 databases
```

**The predicted ROW set is exactly what `byteverify.sh` measured** (§6), and
re-running the same predictor over the PATCHED sweep (`PREDICT_sl_AFTER.txt`)
finds **0 remaining bound non-first cells and 0 fenced-keep cells** across all
956 databases: the 464 predicted cells were cleared and nothing else was.

---

## 6. THE GATES — ALL GREEN

Both binaries were built from THIS pass's own worktree at a clean `89631b31` and
frozen `chmod 555` BEFORE any sweep; every `cmds.txt` in all four workdirs was
audited BY BINARY PATH — `/tmp/r10earl115_bin/pristine` in the two control
workdirs (1573 + 1462 files) and `/tmp/r10earl115_bin/patched3` in the two
patched ones (1573 + 1462), one distinct path per workdir and no other.

| gate | result |
|---|---|
| (1) build both, md5s | pristine `fc4c6d192b7e39bf2e48728a17a6e29f` (byte-identical to the main tree's `build/slang-uhdm`), patched `3c7aef193c82b156aee0ff76a5de2a89` |
| (2) goldens | **23 PASS / 0 FAIL** on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| (3) uhdm2rtlil, testflags AND default | **CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2** on both binaries, identical histograms; `ct8rows` **PASS** against the committed baseline AND against this pass's own pristine control, in BOTH modes |
| (4) surelog, `--mode both`, 1588 rows | identical status histograms on both binaries (default CMP_EQUAL 471 / SLANG_REJECT 283 / SURELOG_FAIL 25 / CMP_NOTEQUAL 10 / DEFERRED 5; testflags CMP_EQUAL 466 / SLANG_REJECT 284 / SURELOG_FAIL 23 / CMP_NOTEQUAL 9 / DEFERRED 5 / NO_DATABASE 3 / UNTRANSLATABLE 2 / TIMEOUT 1 / NO_UHDM 1); `ct8rows` **PASS — 0 differing rows** — against the committed baseline AND against the pristine control.  **NO ROW CONVERTED**, in either direction |
| (5) `byteverify.sh SELFCHECK=1` | uhdm2rtlil **MOVERS 0 / 1358**; surelog **MOVERS 2 / 956** — the ONE PREDICTED row `testflags/Earlgrey_0_1` (whose patched hash is IDENTICAL to the first cut's, so the two fences have zero corpus population) plus `default/Scoreboard`, **the documented ~50/50 parallel-parse COIN**: its ORDER-BLIND whole-dump diff is FOUR lines, being one header line on each side naming the workdir path, ZERO content, and its `uhdm-cmp` log is BYTE-IDENTICAL to the pristine one (`ATTRIB_Scoreboard_coin.txt`).  SELFCHECK flagged 1357/1358 and 955/956, so the comparator can see |
| rowheads | **Earlgrey_0_1 testflags 37 → 92 cmp lines, ONE head, on a DIFFERENT object**; every other row unchanged: SeqDriver 62/62, SimpleUVM at the depth artifact, Scoreboard/default 95, MiniAmiq 62/62, BuildUVMPkg 36/36, Earlgrey_0_1 default 31 with a **BYTE-IDENTICAL** cmp log, Rggen/default 0 |
| canaries | `canaries.sh` surelog **ok=52 changed=0**, uhdm2rtlil **ok=8 changed=0**; `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs, by name | `InterfaceModPort` `59a365f3ce2c`, `BlackParrotComplex` `e3e354129d5a`/`73a10e8217e5`, `YosysOldOr` `d68e0796d62c` — all SAME as pristine in both modes; `SVSwitch` **4842211c4030**, `YosysVerx` **6ccda350c24a**, both pins met (10 pins, all SAME) |
| the four slang-fenced tests | never dispatched; no probe file in this directory spells any of the four outside `canaudit.sh`'s own `FENCED=` line |

### 6a. THE ONE BYTE MOVER, ATTRIBUTED

`attrib115.sh` (r10earl114's sectioned, path-normalised, ORDER-BLIND whole-dump
diff, whose three-region cut keeps the weaklyReferenced TAIL out of the count)
on `testflags/Earlgrey_0_1` (`ATTRIB_Earlgrey.txt`):

```
RAW 1396   ORDER-BLIND 949
ADDED   total 1   -- the dump's own header line naming the workdir path
REMOVED total 948 -- 1 header line + 928 lines in ONE ELAB section, being
            464 |vpiActual:
             29 x 16  \_typespec_member: (a_valid) (a_opcode) (a_data) (a_mask)
                      (a_address) (a_param) (a_size) (a_user) (d_data) (d_error)
                      (d_opcode) (d_param) (d_ready) (d_sink) (d_size) (d_user)
```

**ZERO content is ADDED anywhere, in any region.**  The removed side is exactly
**464 `|vpiActual:` edges and the 464 `typespec_member` lines they named** — one
per predicted cell, 29 unrolled `gen_host_fifo` / `gen_idrouting` instances × the
16 members of `tlul_pkg::tl_h2d_t` / `tl_d2h_t` — and nothing else.  The count
`464` is the number `predict115` wrote down from the PRISTINE databases before
the patched binary existed.

### 6c. THE TWO REGRESSIONS THE WIDE BOUNDARY CAUGHT, AND THE FENCES THEY BOUGHT

The first cut of this law recorded every gen-scope structured-pattern
continuous assign whose Lhs was not a whole-name module-scope target.  It
cleared the head, scored `AWAY 0 / MOVED-WRONG 0` on all fourteen arm/views of
this pass's own grid and on both corpora — **and the wide boundary convicted it
anyway**, because it re-scores every OTHER pass's arms:

```
first cut  d591540e...   v1_decl113_elab  PX AWAY=10   v4_ctx113_elab  PX AWAY=2
                         v6_name113_elab  PX AWAY=12
second cut c848358c...   v1_decl113_elab  PX AWAY=4    (v4 and v6 cleared)
final      3c7aef19...   AWAY 0 / MOVED-WRONG 0 on all 54 arm/views, both families
```

Every one of those 26 cells is `G:{<null>, typespec_member}` against
`P:{<null>, typespec_member}` going to `Q:{<null>}` — pristine-right going
patched-wrong on legal SV, invisible to both corpora.  Read off golden's own
objects (`chain115` on the arm databases) they are two mechanisms, and both are
r10earl113's own axes, which is why ITS verifier arms are the ones that caught
this:

* **THE NAMESAKE.**  `v6_name113`'s whole point is a gen-local target whose name
  also exists elsewhere.  Golden BINDS the trailing element when the namesake is
  a module-body VARIABLE (`v1_decl113` a3), a module-body NET (`g2`), the
  module's own PORT (`g5`), a namesake declared AFTER the block (`g3`), or a
  namesake ONE HIERARCHY LEVEL UP in the parent module (`v1_decl113` a7) — and
  leaves it bare when the namesake is in an ENCLOSING GENERATE BLOCK (`g4`) or
  absent (`g6`).  That is exactly the reach of
  `CompileHelper::bindVariable`'s `bindVariable(component, scope->VpiParent(),…)`
  recursion, which does not stop at a module boundary; the second cut's walk did
  stop there and still scored AWAY 4 on `a7`.
* **THE NESTED INSTANCE.**  `v4_ctx113` instantiates one child module four ways.
  Golden's own parent chains say it plainly: bare under `u_a` / `u_b` (module
  scope), BOUND under `u_c` (instantiated inside `gen_inst[k]`).

With both fences the two convicting arms do not merely stop moving wrongly —
`v1_decl113` and `v4_ctx113` go **37 cmp lines / 1 head → 0 / 0, fully
CMP-EQUAL**, which is the strongest statement either arm can make.

### 6b. THE WIDE BOUNDARY

`widerun115.sh` stages a COPY of the whole committed `tools/probe` tree, lists
every `.sv`/`.v` at ANY depth, filters the four fenced names out of the list
BEFORE a single child runs (the list is read from `canaudit.sh`'s own `FENCED=`
line, so the filter cannot drift from the audit), and compares the
workdir-normalised `uhdm-dump` of both frozen binaries in BOTH views.

```
LISTED (BOUNDARY_WIDE.list)  : 5087     FENCED-NAME HITS IN THE LIST : 0
DISTINCT FILES IN THE rc LOG : 5087     FILES WITH != 4 rc LINES     : 0
FILES LISTED BUT NEVER RUN   : 0
PROCESSED=5087  identical=9749  DIFFERING=33  no_output=392
rc by side:  A/0 9391  A/3 376  A/4 391  A/139 16
             B/0 9391  B/3 376  B/4 391  B/139 16   <- perfectly SYMMETRIC
```

**LISTED == PROCESSED == 5087, every listed file with exactly its four
invocations (2 views x 2 binaries), none skipped**, and the rc histogram is
identical side for side — no arm rejects on one binary and not the other, and
the 16 `rc=139` segfaults are the same 16 on both sides.

**The 33 differing cells are 30 arm files in the ELAB view — every one of them
re-scored above with AWAY 0 / MOVED-WRONG 0 in both families (§3's 54 arm/views
ARE that re-score) — plus THREE files that differ in the PLAIN view, where this
law's post-elaborator pass cannot run at all.**  Those three are the documented
parallel-parse coin, proved rather than asserted: three runs of the PRISTINE
binary alone on each of them give three DIFFERENT hashes
(`BOUNDARY_COIN.txt`).

* **r10earl110's and r10earl111's arms are not in the differing list at all** —
  every one of their `.sv` files dumps byte-identically from the two binaries in
  both views, so those laws and their fences are untouched by construction.
* r10earl112's, r10earl113's, r10earl114's and their verifiers' arms ARE in the
  list, and every one is scored in §3's table: `PX`/`P0` AWAY 0, MOVED-WRONG 0,
  with `v1_decl113` and `v4_ctx113` going fully CMP-EQUAL and `s1_scope113` /
  `s2_opkind113` moving their head object's decompile size (37 → 58 and 37 → 36
  lines, one head throughout).

---

## 7. RESIDUES, and R0

* **R0 — THE UNFLATTENED `tagged_pattern`, READ not predicted.**  The patched
  Earlgrey_0_1/testflags head is golden's `tagged_pattern` at
  `tlul_socket_m1.sv:241:17` (its `Pattern` a `bit_select` on
  `gen_idrouting[0].hfifo_rspvalid`, its `Typespec` a `string_typespec('d_valid')`)
  against OUR bare flattened `bit_select` operand.  Golden did NOT flatten that
  pattern and we did — the mirror image of §2b's mechanism, one carrier over.
  `HEAD_AFTER_Earlgrey_testflags.cmp` holds it, and arm `p1_pos115`'s elaborated
  view is now CMP-EQUAL, so the next pass starts from a NEW arm, not this one.
* **R1 — the MULTIPLICITY residue** (r10earl112's R6 / r10earl113's R5 /
  r10earl114's R3).  Our elaborated tree holds more copies of a gen-scope
  `hier_path` than golden's (3 bare + 3 bound per gen instance where golden holds
  3), which is why a `PX` cell's payload SET can be `{<null>, array_var}` against
  golden's `{array_var}` and score `STILLWRONG` even where every judged object
  agrees.  No generated `Compare` reads a copy count; the SHAPE columns are the
  judged ones, on r10earl111/112/113/114's precedent, and both are printed.
* **R2 — the USER-CALL-ARGUMENT carrier.**  A `hier_path` inside a `func_call`
  that is itself a pattern member value (arm `p3` x8 / r10earl114 `t4` f6) is
  bare in golden and bound here; it is not an operand of the pattern operation,
  so this law's walk does not reach it, and r10earl112's user-call fence says why
  Surelog never compiles it with `Reduce::Yes`.  Left deliberately.
* **R3 — the MULTI-COMPONENT SPAN residue.**  For a path of three or more
  components our `hier_path` END COLUMN differs from golden's (`59:32-59:39`
  against golden's `59:32-59:48` on arm `p1` n2), which is why 10 `p1` keys are
  one-sided in both families.  Both sides are `<null>` at every element there, and
  no generated `Compare` reads a span — a dump-only residue, named because it is
  what the one-sided counts are.
* **R5 — THE TWO FENCES HAVE ZERO CORPUS POPULATION.**  The namesake fence and
  the nested-instance fence change no corpus cell: the moving database's hash is
  identical between the first cut and the final binary, and the corpus census
  scores identically (TO-GOLDEN 34, one row).  They exist because the wide
  boundary convicted the first cut on legal SV the corpora do not contain — the
  same reason r10earl60's two regressions were caught.  Both are decoded laws in
  their own right (§6c) and both deserve their own arm cells in whatever pass
  next touches this field.
* **R4 — r10earl110's, r10earl111's, r10earl112's, r10earl113's and
  r10earl114's laws are untouched.**  r10earl114's own four arms are re-scored
  here in this pass's two families with AWAY 0 / MOVED-WRONG 0, its `t4` f2 fence
  cell is byte-identical between the two binaries, and the wide boundary
  re-checks every other pass's arms.

---

## 8. FILES

| file | what it is |
|---|---|
| `own115.cpp` | the head decoder: runs the OFFICIAL `design::Compare`, finds the OWNING `hier_path` of a null-sided element head by SEARCHING the non-null side (a `typespec_member` is parented at its struct typespec, so the parent chain does NOT reach the path), prints every element's position class, kind and `Actual_group` on both sides, pairs every `hier_path` in the two databases (`paths` mode, key WITHOUT `VpiFile`), and masks field by field to READ the next head (`ladder` mode) |
| `sig115.cpp` | the per-element census: every `hier_path` in the LIVE design (a `UhdmListener` walk, not `AllObjects`), one row per element with its index/position/kind, its bound object's kind + name + owner, and the scope × carrier × root-value matrix |
| `sig115.py` | the TWO-FAMILY arm scorer (`PX` the law's surface, `P0` the coarse key) with SHAPE `TOGOLD`/`AWAY`/`MOVEDWRONG`/`STILLWRONG`/`NOGOLD_MOVED` |
| `cen115.py` | the same scorer over a whole corpus census, per database, naming the rows whose cells moved |
| `predict115.cpp` | the BY-ROW, BY-CELL mover prediction from PRISTINE databases, applying the law's gate in UHDM terms |
| `censweep115.sh` | the corpus sweep driver with its ACCOUNTING PASS (LISTED / PROCESSED / SKIPPED / TOOLFAIL) |
| `grid115.sh`, `TOPS.txt` | the arm grid driver (rc recorded per producer, children `</dev/null`, `-top` from `TOPS.txt`, `CENRC` asserted) and its `-top` table |
| `p1_pos115.sv` | THE POSITION AXIS: 2-, 3- and 4-component paths, plus a trailing select and a middle select |
| `p2_root115.sv` | THE ROOT-KIND AXIS (port array / module array / `wire` array) and THE DEPTH AXIS (gen-for 1, gen-for 2, gen-if) |
| `p3_fence115.sv` | THE MUST-STAY FLOOR: module scope, module-body target, positional pattern, plain Rhs, binary operand, `always_comb`, select Lhs, user-call argument |
| `chain115.cpp`, `gs2.cpp`, `mod115.cpp` | the three decode probes: the parent chain + per-element binding of every `hier_path` on one source line; the LIVE `Gen_scope_arrays` walk that showed golden's operand list is the tagged-pattern one; and the module-vector dump that proved the two `module_inst` shapes identical (so the divergence is not in the netMap the elaborator builds) |
| `attrib115.sh`, `secattr115.py` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (the weaklyReferenced TAIL is never counted) |
| `wide115.sh`, `widerun115.sh` | the wide boundary over every `.sv`/`.v` in `tools/probe` at any depth, both views, both binaries |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates (copied verbatim from their owning pass dirs) |
| `HEAD_BEFORE_*.cmp` / `HEAD_AFTER_*.cmp`, `ARM_*_BEFORE.cmp` / `ARM_*_AFTER.cmp` | the official `uhdm-cmp` output on the head row and on the two arms that reproduce it, both binaries |
| `GRID.r10earl115.txt`, `CALIB.r10earl115.txt` | the 14-arm/view two-family score and its golden-vs-golden calibration |
| `CENSUS_sl.txt`, `CENSUS_u2r.txt`, `PREDICT_sl.txt`, `PREDICT_u2r.txt`, `PREDICT_sl_AFTER.txt` | the corpus census scores, the frozen prediction, and the same predictor re-run on the patched sweep |
| `BOUNDARY_WIDE.*`, `BOUNDARY_COIN.txt`, `BOUNDARY_arms.txt`, `BOUNDARY_arms_FIRSTCUT.txt`, `CALIB_BOUNDARY.txt` | the wide boundary's independent accounting (reconstructed from the per-invocation rc log), its tally, per-side rc histogram and differing list; the proof that its three PLAIN-view cells are the parallel-parse coin; the two-family re-score of every arm it flagged, on the FINAL binary and on the FIRST CUT (the AWAY 10 / 2 / 12 that bought the two fences); and their golden-vs-golden calibration |
| `ATTRIB_Earlgrey.txt`, `ATTRIB_Scoreboard_coin.txt` | the order-blind whole-dump attribution of the one moving row, and of the second surelog byte mover (the documented Scoreboard/default coin, ZERO content differing) |

**Build the C++ instruments with**

```
g++ -O2 -std=c++17 <tool>.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <tool>
```
