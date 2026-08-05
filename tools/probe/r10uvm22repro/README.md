# r10uvm22 — UVM pass 22

Three loop-variable laws, gated clean, **0 movers** — and the pass-21 ranked
**#2**, "VIEW MULTIPLICITY", is **CRACKED and measured** (decoded only; no code,
per the assignment).  UVM-4 body residue **15516 -> 15495**, three of the four
tests down.

| | BuildUVMPkg | Scoreboard | SeqDriver | SimpleUVM | TOTAL |
|---|---|---|---|---|---|
| HEAD 0e511ed | 2800 | 2827 | 5735 | 4154 | 15516 |
| + § foreachAssocIdxAliasTs22 | 2796 | 2824 | 5735 | 4148 | 15503 |
| + § foreachShadowFormalWins22 + § foreachClassPropStringVar22 | 2797 | 2824 | 5738 | 4148 | 15507 |
| + registering them in § foreachLoopVarObjs9 | **2795** | **2823** | **5732** | **4145** | **15495** |

The third row is the honest intermediate: getting the loop variable's KIND right
made the metric go UP by 4 until the body-binding half was added — the same
"once the kind stops being int_var, golden binds it" pattern pass 19 and pass 20
each hit.  It is recorded because it is the evidence that the registration test
belongs to the law, not a tuning knob.

Gates on the final tree: goldens 23/23, u2r testflags (732 rows) and Surelog
both-modes (1589 rows) **byte-identical** to the committed baselines
(`diff | wc -l` = 0 each); SLANG_REJECT membership unchanged at 570; canaries
including the `dump` column unchanged.

Measure with (from this worktree, `SLANG_UHDM` exported):

    python3 scripts/verify_golden.py --corpus surelog --mode default \
      --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
      --out /tmp/x.csv --workdir /tmp/xw --jobs 2
    R10B=<r10uvm7b build>  R10W=/tmp/xw tools/probe/r10uvm19m.sh <slang-uhdm> /tmp/m
    R10B=<r10uvm20b build> R10W=/tmp/xw tools/probe/r10uvm19rank.sh 25 /tmp/m
    R10W=/tmp/xw R10A=<r10uvm20a build> tools/probe/r10uvm22cen.sh /tmp/m /tmp/cen

---

## RANKED #1 (pass 21): the ONE unimplemented index-mapping cell — NOT blocked

Pass 21 ranked it "BLOCKED on there being no `makeTypespec(const Type&)`, only
the `Symbol`-keyed one".  That is false: **`assocIndexTs(const Type&, const
Symbol&)`** (`UhdmExporter.cpp:931`) is already the Type-keyed index-typespec
builder for the DECLARATION's `vpiIndexTypespec`, and it is backed by
**`sharedAliasTs(const Type&)`** (`:851`), a Type-keyed lookup into
`pkgTopTypedefTs` / `typedefTs` — the objects we already emit for every typedef.

### § foreachAssocIdxAliasTs22

> An associative array's loop variable is its INDEX
> (§ foreachAssocIndexVar19); when the index type is written as a **TYPEDEF
> NAME**, `getSimpleVarFromTypespec` is handed that typedef's own typespec
> object, so the loop variable takes the var class UHDM's mapping gives it and
> carries the typedef's typespec **by name**.

`uvm_reg_map_addr_range` (a struct) -> `struct_var
struct_typespec 'uvm_pkg::uvm_reg_map_addr_range'`;
`uvm_reg_addr_t` (`typedef bit [...]`) -> `bit_var bit_typespec 'uvm_reg_addr_t'`.
Only kinds `varForTypespec` maps are taken, so an unmappable index still falls
back to the int default instead of registering a loop variable no body reference
could bind.  **-13**, and it closes the whole 44 + 16 census head in the views we
emit (the remaining 40 + 28 sit inside views the multiplicity law below is
missing).

## The other two laws

### § foreachShadowFormalWins22  (the `this.<prop>` exception pass 21 could not see)

> `foreach (this.<name>[i])` where the ENCLOSING SUBROUTINE also declares
> `<name>` resolves its LOOP VARIABLE through the **subroutine's** declaration,
> not the class property — regardless of § classPropUnitImport21's `$unit` gate.

`uvm_reg_block` writes exactly that four times — `get_registers(ref uvm_reg
regs[$])` / `get_memories` / `get_maps` / `get_blocks`, each iterating
`this.<same name>` — and `uvm_vreg::get_fields` is a fifth.  Golden answers
`class_var 'uvm_reg'` etc. in **Scoreboard and SimpleUVM**, the two tests whose
`$unit` import says a class property must not resolve at all.  Those 4-count
census rows were the only sites where pass 21's gate looked WRONG, and they are
not counter-examples to it: they never took the class-property route.

**Purpose-built, both directions, with the two routes made to DISAGREE**
(`t33d` / `t33e`): a property `int p_a[string]` (property route -> `string_var`
by the assoc INDEX rule) shadowed by a formal `ref Cel p_a[$]` (formal route ->
`class_var 'Cel'`, an io_decl carrying the ELEMENT typespec).  Golden reads
`class_var 'Cel'` in BOTH arms — with the `$unit` import (t33d) and without it
(t33e) — while the same file's UN-shadowed `p_b` still tracks the gate
(`int_var` in t33d, `string_var` in t33e).  Only the loop variable moves:
golden's iterated reference is still § classPropIterThisRefVar21's typespec-less
`ref_var`.  The BARE spelling needs no rule — slang's own name resolution
already binds it to the shadowing declaration.

### § foreachClassPropStringVar22

> A RESOLVING class property that is a plain `string` is iterated over its
> CHARACTERS: `getSimpleVarFromTypespec` of a `string_typespec` is a
> `string_var`, where the pass-21 arm (queue / dynamic / fixed only) dropped to
> the bare int default.

`uvm_component::get_depth`'s `foreach (m_name[i])` over `protected string
m_name` is the corpus site (4, all in views we emit); t33e pins it directly,
bare and `this.`-prefixed alike.

### ...and the registration half

`§ foreachLoopVarObjs9` registers the loop-variable object for body references
only when it is the RESOLVED one, tested as "int_var, array_var or the assoc
index".  All three pass-22 arms produce a resolved object of some OTHER class,
and golden binds them in the body exactly as it binds an int_var — see the table
at the top: **without** the registration the three arms are net **+4**; with it
they are net **-8** on top of the alias law.

---

## THE VIEW-MULTIPLICITY LAW — CRACKED (decoded, not implemented)

Pass 21 left this as "golden's SeqDriver ELABPKG lists every uvm_pkg body once
per importing-package class (6 views x 150) where we emit one: a structural
listing-population law".  It is neither a listing of bodies nor about views:

> **§ classInheritsContainerImports22** — a CLASS inherits the whole content of
> every package imported by its **CONTAINER** (the package / module / compilation
> unit it is declared in), copied into the class's OWN `vpiTaskFunc`,
> `vpiTypedef`, `vpiVariables`, `vpiParameter` and `vpiParamAssign` listings,
> BEFORE the class's own members.

Source-first, exactly: `CompileClass::compile_class_`
(`CompileClass.cpp:150-169`) builds `pack_imports` from the class's own
FileContent **plus** `m_class->getContainer()->getObjects(paPackage_import_item)`
and calls `CompileHelper::importPackage(m_class, ...)` for each;
`importPackage` (`CompileHelper.cpp:127`) copies the imported package's
typespecs (`:162`), variables (`:170`), parameters (`:198`), param_assigns
(`:241`) and task_funcs (`:300`) into that scope.  `UhdmWriter::writeClass`
(`:981`) then writes `classDef->getTask_funcs()` straight out.

Two asymmetries fall out of the same code and are both visible in the goldens:

* the **task_func** loop has a `duplicate` name check (`:311`) and the typespec
  copy is a map insert, but the **variable** and **parameter** loops have
  neither — so when a class's own FileContent *is* its container's (a `$unit`
  class under a `$unit` import), the import runs twice and the variables and
  parameters land TWICE while the tasks and typespecs de-duplicate.
* `inPackage` is false for the class caller (`:319`), so a class SHARES the
  package's task_func objects rather than cloning them.

### Measured, purpose-built, both directions (t33a / t33b / t33c)

`tools/probe/r10uvm22a.cpp` is the listing-population census
(`<view> tf= cds= ts= vars=` per package/module, `<view>::<class> tf= ts= vars=
params=` per class).  `pk1` has 2 task_funcs, 2 typedefs, 1 variable, 1
parameter; `pk2` adds its own and declares `class C` with 1 method and 1
property.

| arm | import | golden `C` | ours |
|---|---|---|---|
| t33a | `package pk2; import pk1::*;` | `tf=3 ts=2 vars=2 params=1` | `tf=1 ts=0 vars=1 params=0` |
| t33b | **none** (control) | `tf=1 ts=0 vars=1 params=0` | `tf=1 ts=0 vars=1 params=0` |
| t33c | `import pk1::*;` at `$unit`, `C` at `$unit` | `tf=3 ts=2 vars=3 params=2` | `tf=1 ts=0 vars=1 params=0` |

t33a: `C` gains pk1's 2 task_funcs, 2 typedefs, 1 variable and 1 parameter — and
**only pk1's**, never pk2's own `f2` / `byt_t` / `gv2` / `P2`, which is what
`importPackage` (and nothing else) predicts.  t33b is byte-identical between
golden and us, so the discriminator is the import and nothing else.  t33c is the
Scoreboard / SimpleUVM shape and shows the double-count exactly: `vars=3`
(gv1 twice + own `m`) and `params=2` (P1 twice) against `tf=3` / `ts=2`.

t33d incidentally adds a fourth arm: a `$unit` `import pk::*` of the class's OWN
package copies pk's task_funcs into pk's OTHER class (`ELABPKG[pk]::Cel` lists
`C::run`), because `def == scope` only skips when the scope IS the package.

### What it is worth on the corpus

`tools/probe/r10uvm22a.cpp` on SeqDriver, golden vs ours — 16 of the 344 census
rows differ, and the five below are the whole of the structural gap (the other
eleven are typespec/variable COUNT rows: the four importing SCOPES
(`DEFPKG[adpcm_pkg]`, `ELABPKG[adpcm_pkg]`, `DEFMOD[]`, `ELABMOD[work@top_tb]`)
at `ts=124/125` against our 90/91, and `ELABMOD` at `vars=66` against our 25 —
the same import copy seen on the importing scopes' own listings — plus seven
uvm_pkg classes off by one typespec):

| view | golden | ours |
|---|---|---|
| `ELABPKG[adpcm_pkg]::adpcm_driver` | `tf=899 ts=123 vars=36 params=45` | `tf=5 ts=1 vars=2 params=0` |
| `ELABPKG[adpcm_pkg]::adpcm_seq_item` | `tf=905 ts=123 vars=36 params=45` | `tf=11 ts=1 vars=3 params=0` |
| `ELABPKG[adpcm_pkg]::adpcm_sequencer` | `tf=898 ts=124 vars=34 params=45` | `tf=4 ts=1 vars=1 params=0` |
| `ELABPKG[adpcm_pkg]::adpcm_test` | `tf=901 ts=124 vars=37 params=45` | `tf=7 ts=1 vars=4 params=0` |
| `ELABPKG[adpcm_pkg]::adpcm_tx_seq` | `tf=901 ts=124 vars=36 params=45` | `tf=7 ts=1 vars=3 params=0` |

`adpcm_pkg` imports `uvm_pkg`, so each of its five classes carries adpcm_pkg's
whole imported content (894 task_funcs) plus its own — ~4500 task_func,
~600 typespec, ~160 variable and 225 parameter listing entries per test that we
do not emit at all.  Scoreboard's `DESIGNCLS[work@my_scoreboard]` and SimpleUVM's
`DESIGNCLS[work@env]` are the `$unit` form of the same thing.

**None of it is visible in the pass-19 body-residue metric** — `r10uvm19m.sh`
walks matched task_func bodies, so a listing our side never populates simply
never gets compared.  The 2086 `O[<missing>]` rows in `r10uvm22cendiff.py`'s
output ARE this law (2086 of the 2110 loop-variable census disagreements), and
they are the only measurement of it that the current tooling produces.  Any pass
that implements it must bring its own metric.

---

## Ranked residue after this pass

`tools/probe/r10uvm19rank.sh 25` is unchanged in character from pass 21 (io_decl
890 + 753, logic_net 738, function 600, package 574, class_ts 571 — all BINDING
POLICY per the pass-20 presence census; then the three exposed families Stmt
`<null> vs ref_obj` 476, Io_decls `<null> vs ref_obj` 459, `ref_var vs <null>`
333).

**Ranked #1 for pass 23: § classInheritsContainerImports22.**  It is fully
decoded above with the Surelog line numbers, a three-arm purpose-built pair and a
corpus census; it is the only remaining STRUCTURAL gap in the UVM-4 (everything
else in the 344-row listing census matches), and no test can convert while five
class listings are two orders of magnitude short.  Implementation notes: the
package's OWN emitted listings already match golden in every view (our
`ELABPKG[adpcm_pkg] tf=894` equals golden's), so the objects to copy exist —
what is needed is the IMPORTED SUBSET of them (not the container's whole list:
a container's own members must not leak into its classes), pushed ahead of the
class's own members, per view, sharing the objects.  `emitClassDefn`
(`UhdmExporter.cpp:484`) is the one place; `unitScopeWildcardImports()`
(`ModuleEmit.cpp:3040`) already enumerates the `$unit` half.

**Ranked #2: the hier_path ROOT-DEGRADATION cell** (16 sites, both halves in
`uvm_phase::get_predecessors_for_successors`).  § foreachHierPathAlwaysRes21
says a dotted iterated reference always resolves; these two say what it resolves
*to* when the root is not a plain named declaration of the scope:

| written | root | golden | ours |
|---|---|---|---|
| `foreach (successors[s].m_predecessors[pred])` | an ELEMENT SELECT on a local dynamic array | `array_var array_typespec''` (the ROOT's own object) | `class_var 'uvm_phase'` |
| `foreach (pred.m_predecessors[next_pred])` | another foreach's LOOP VARIABLE (a `bit_var` there) | `int_var` | `class_var 'uvm_phase'` |

i.e. `decodeHierPath` stops at the root it can name and never reaches
`m_predecessors`.  Purpose-build it before coding — the two arms want opposite
answers and neither is the current model.

**Ranked #3, smalls** (8 sites total, all pinned by the census): a `::`-qualified
iterated name never resolves (`foreach (this_type::m_typewide_sequences[i])` ->
golden `int_var`, ours `array_var`, 4); and 3 sites in SeqDriver's
`ELABPKG[adpcm_pkg]` view where golden's loop variable stays an unresolved
`ref_var` for a package function COPIED into the importing package while the
same function resolves in `uvm_pkg`'s own view — likely the same `inPackage`
clone/share split as the law above, so decode them together.

## Files

* `r10uvm22a.cpp` — listing-population census (packages, modules, classes).
* `r10uvm22cen.sh` + `r10uvm22cendiff.py` — the UVM-4 loop-variable census diff,
  splitting view-multiplicity rows from real loop-variable rows.
* `t33a` / `t33b` / `t33c` — the listing-population pair (import / no import /
  `$unit`).
* `t33d` / `t33e` — the shadowing-formal and string-property pair (with and
  without the `$unit` import).

Run an arm with `tools/probe/r10uvm13run.sh <dir>` after copying it somewhere
writable (`SLANG_UHDM` exported); read the censuses off `gd/sd/ge/se.uhdm` with
`r10uvm20a` (loop variables) and `r10uvm22a` (listings).
