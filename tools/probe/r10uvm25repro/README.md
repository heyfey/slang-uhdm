# r10uvm25 — UVM pass 25

Pass 24's two unfinished edges are **closed**, and the two laws behind the rest
of the class-typedef residue are **decoded, purpose-built and implemented**.
The UVM-4's `vpiTypedef` listings — every class's and every package's, in BOTH
views — are now **byte-identical to golden**.

| metric | HEAD a17ff9f | this pass |
|---|---|---|
| `r10uvm23m.sh` class listings `tf/ts/var/par/pas` | 2 / **45** / 34 / 0 / 0 = **81** | 2 / **0** / 34 / 0 / 0 = **36** |
| `r10uvm25m.sh` package listings (`DEFPKG`+`ELABPKG`) | **-37/+4 = 41** | **0** |
| combined | **122** | **36** |

Gate on the final tree: goldens **23/23 PASS**; u2r testflags (732 rows) and
Surelog both-modes (1589 rows) **byte-identical** to the committed baselines
(`diff | wc -l` = 0 each, dump column included) — so SLANG_REJECT membership,
every canary and every `dump=match` are unchanged. **0 movers**: the four UVM
tests stay CMP_NOTEQUAL, on a distinguisher this pass MEASURED (see the ranking).

    R10B=<r10uvm23b build> tools/probe/r10uvm23m.sh <sweep workdir>   # class listings
    R10P=<r10uvm24p build> tools/probe/r10uvm25m.sh <sweep workdir>   # package listings (NEW)

---

## 1. `§ importPublishesPackageClasses25` — the DEF-view arm (pass 24's edge 1)

Pass 24 filled only the ELAB view; `DEFPKG[adpcm_pkg]` was still 90 entries
against golden's 124.  The reason is not the law but WHERE the two views come
from: `UhdmWriter.cpp`:4929 writes TopPackages from the elaborated `Package`,
:4966 writes AllPackages from `pack->getUnElabPackage()` — **two
DesignComponents, two DataTypeMaps**.  Measured, in golden AND in ours:

| | classes on the package view | own ts listing |
|---|---|---|
| `DEFPKG[uvm_pkg]` | **0** | 46 |
| `ELABPKG[uvm_pkg]` | 323 | 89 |
| `DEFPKG[adpcm_pkg]` | 0 | golden **124** |
| `ELABPKG[adpcm_pkg]` | 5 | golden 124 |

So the two views of uvm_pkg legitimately DIFFER (46 vs 89 — elaboration inserts
entries), while both views of the IMPORTER read the same 124.  The reason is
`insertDataType`'s pointer semantics: the unelab importer stores the imported
package's `ClassDefinition*`s, whose typespecs are filled during elaboration, so
at write time both views resolve to the very same objects.  Implementation: one
design-wide `clsSrc25` map, name -> the package view that actually carries the
class listings, used by both `run24` passes.  `DEFPKG` -37/+3 -> **0/0**.

`tools/probe/r10uvm25a.cpp` is the census probe behind the table
(`classes=` / `withRep=` / `noRep=` per package view).

## 2. `§ classRepresentativeSkipsTypeParamAlias25` (pass 24's edge 2)

Pass 24 introduced ONE over-emission: `ELABPKG[adpcm_pkg]` gained
`class_typespec 'adpcm_pkg::req_type'` at key `uvm_sequence_item`, which golden
does not have — golden has NO entry for that key at all.

`ElaborationStep.cpp`:258-262 is the only writer of a `ClassDefinition`'s
typespec:

```
typd->setTypespec(ts);
if (DataType* dt = (DataType*)typd->getDataType())
  if (dt->getTypespec() == nullptr) dt->setTypespec(ts);
```

For `typedef REQ req_type;` (uvm_sequencer_param_base) `typd->getDataType()` is
the type PARAMETER, not the class the parameter resolves to — so
`uvm_sequence_item` keeps a null typespec and `writeDataTypes` drops its whole
entry.  A class_typespec built for a type-parameter alias is therefore recorded
in `tpAliasClassTs25` and never offered as a representative.  Both `req_type`
and `rsp_type` are skipped, which is exactly why the key is absent.

## 3. `§ typedefAliasSharesTypespec25` — BOTH arms, one rule

`compileTypespec` hands a type-parameter alias the PARAMETER's own typespec
object, so every class typedef reaching the same **root of the parameter's
DEFAULT chain** is ONE object: written once, at the alphabetically first of
their names (the DataTypeMap key), under the SOURCE-LAST one's name
(`ts->VpiName(typd->getName())` re-runs per typedef).

`t35a` purpose-builds the rule and BOTH negative controls, and golden confirms
all four in one file:

| class | source | golden |
|---|---|---|
| `K #(type REQ = Base, type RSP = REQ)` + `typedef REQ req_type; typedef RSP rsp_type;` | one root (REQ) | **ONE** `class_typespec 'rsp_type'` |
| `L #(type IMP = int, type REQ_IMP = IMP, type RSP_IMP = IMP)` + three typedefs | one root (IMP) | **ONE** `int_typespec 'this_rsp_type'` |
| `M #(type A = Base, type B = Base)` + `typedef A aa_type; typedef B bb_type;` | TWO roots | **TWO** entries — no collapse |
| `N` + `typedef Base n1_type; typedef Base n2_type;` | no parameter | **TWO** entries — no collapse |

`t35a` is now **IDENTICAL** to golden.  The chain has to be read off the class
DECLARATION (`TypeAssignmentSyntax`): a specialization's `TypeParameterSymbol`
carries **no syntax of its own** (`getSyntax()` measured null), and its resolved
`targetType` is the OVERRIDE, which would hide the default that does the
sharing.

### 3b. `§ classTypedefOfPredefIntIsListed25`

The `L` arm needed an emission that did not exist: `t35b` shows golden lists all
five of a class's plain typedefs (`f_bit`, `f_en`, `f_int`, `f_st`, `f_vec`) and
we listed four — `PredefinedIntegerType` was the one simple target kind
`buildClassTypedefTs` had no branch for.  Adding it to the ScalarType branch
fixes the plain shape AND gives UVM's six `uvm_*_imp` classes their single
`int_typespec 'this_rsp_type'`.

## 4. `§ classRepresentativeIsFirstBoundTypedef25` (pass 24's ranked #4)

The setter decoded in §2 also settles the REPRESENTATIVE pick, and it is **FIRST
wins, not last**: `if (dt->getTypespec() == nullptr)`.  "First" is the order of
the `defs` vector `bindTypedefs_` builds up front (`ElaborationStep.cpp`:110-148)
— file contents, then PACKAGES, then modules, then programs, then
`design->getClassDefinitions()`, every one a `std::map`, so **qualified-class-name
order** in the last group.

That is SeqDriver's whole `type_id` cluster.  `adpcm_pkg::adpcm_driver` and
`uvm_pkg::uvm_algorithmic_comparator` both declare
`typedef uvm_component_registry #(...) type_id;`, and `adpcm_pkg::` sorts first,
so the ADPCM class's object represents `uvm_component_registry`.  Golden shows
exactly that: adpcm_driver's own `type_id` is the one requalified to
`adpcm_pkg::type_id` (it is written for a PACKAGE listing) while
uvm_algorithmic_comparator's stays BARE, and the identity dedup then leaves
adpcm_driver ONE entry, not two.  Pass 24 scanned only the imported package's own
listings, so an importing package's class could never win.  Implemented as one
design-wide `classRep25` map built in that order; `ts 10 -> 0`.

The same order is what keeps uvm_pkg's package-level `uvm_heartbeat_cbs_t` /
`uvm_mem_cb_iter` / `uvm_table_printer_knobs` representing their target classes
(packages are group 2, classes group 5) — pass 24's three "moved" entries
survive unchanged.

---

## RANKED #1 for pass 26 — `vpiAutomatic` on package-scope class_vars

This is the **first failing pair uhdm-cmp reports** for all four UVM tests, now
that the listings agree.  `variables::Compare` reads `VpiAutomatic`
(`UHDM/build/generated/src/variables.cpp`:256), and golden's
`uvm_pkg::uvm_default_table_printer` has it set where ours does not.

`tools/probe/r10uvm25v.cpp` is the census (`R10V <uhdm> [pkgFilter]`):
**exactly 9 names per view, all `class_var`, 36 diff-lines over the two views**
— `uvm_default_table_printer`, `uvm_default_tree_printer`,
`uvm_default_line_printer`, `uvm_default_packer`, `uvm_default_comparer`,
`uvm_resources`, `uvm_top`, `uvm_test_done`, `uvm_cmdline_proc` (golden 1, ours
0).  Everything else in the 66-entry listing already agrees, order included.

Source side: `ElaborationStep.cpp`:2350 is `VpiAutomatic(!sig->isStatic())`, and
`CompileHelper.cpp`:2294 computes `is_static = (component is ModuleDefinition ||
Program)` — **false for a package**, i.e. every package-scope variable should be
automatic.  But golden leaves `uvm_default_printer` (declared 27 lines after
`uvm_default_table_printer`, in the same file, the same way) and the eight
`uvm_phase *_ph` variables at 0, so a SECOND path writes those.  DECODE WHICH —
do not implement the blanket rule.  Both exception groups have a class type that
is only FORWARD-declared at the point of use (`uvm_printer`, `uvm_phase`), which
is the first thing to test with a purpose-built pair.

## Also ranked

* **`var 34`** (class listings) — unchanged by this pass; still the two
  opposite-direction laws pass 23/24 recorded (adpcm_driver missing its OWN
  `logic_var 'ADPCM'`).
* **`tf 2`** — BuildUVMPkg's pre-existing pair.
* **the `t35b` residue, 2 lines** — golden qualifies a type-parameter alias whose
  root default is a PACKAGE typedef: `enum_typespec 'pk2::q_en_b'` and
  `struct_typespec 'pk2::q_st_b'` where we emit them bare.  Same
  `writeDataTypes` requalification as §1, reached because the alias SHARES the
  package's own typespec object — so the object is in the package listing and
  gets the prefix there.  Cheap and fully reproduced in `t35b`.
* the `t33d` extern-prototype listing entry; hier_path root-degradation;
  `::`-qualified iterated names.

---

## Running the arms

    export SLANG_UHDM=<worktree>/build/slang-uhdm
    R10B=/tmp/r10uvm25b tools/probe/r10uvm25run.sh tools/probe/r10uvm25repro/t35a

Build the probes with the **STATIC** UHDM libs (a shared `-luhdm` restores
Surelog's `.uhdm` with NULL vector contents and every census silently measures
nothing), and generate the arm goldens with `~/git-repos/Surelog/build/bin/surelog`:

    g++ -std=c++20 -O2 tools/probe/r10uvm25a.cpp -o /tmp/r10uvm25a \
      -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
      $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
