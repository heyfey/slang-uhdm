# r11u465: clone loop variables under a $unit import, transitive enum and struct typedef listing

Pass 465, the expression/parameter ground (src/ParamEmit.cpp only). Base dbf4f952. Two laws.
Pristine binary md5 d59c9ff65c1b72790be68a21e7794397 (the same as the main tree's build). Law
binary law5 md5 0d6857acbfa6cefc70fddf3c8a30045c. It links slang 12.0.0+545f88b2e.

## Target row: generated/uvm-examples/uvm_use_models_pipelined_get_put.sv

The row stays **DIFFERENT** (`uvm_use_models_pipelined_get_put,DIFFERENT,decompile:,`). Both of the
row's faces on this ground are now written:

- pass 446's localizer (evidence/tools are copies of the needed tools; clsloc ALL top) reads
  **500 -> 0** localized failures (evidence/rows/pipelined_clsloc_{pristine,law5}.txt);
- mbus_pipelined_env_pkg's typedef listing goes from 130 to 133 entries and now matches golden
  entry for entry (evidence/rows/env_pkg_listing_*.txt).

The new uhdm-cmp head (1385354 -> 1382776 lines) is on the **sister's ground**. It is the
uninstantiated interface definition work@mbus_pipelined_driver_bfm (design allInterfaces), whose
typedef listing has 131 entries in golden and 4 in ours. Golden lists the $unit-imported
mbus_pipelined_agent_pkg's whole transitive listing (uvm_pkg::UVM_FILE, ...). See
evidence/rows/pipelined_law5_ifc_listing_head.txt. The module listing face of top_hdl that pass
462 reported is behind it (ModuleEmit's interface listing).

Other rows the laws fire on. None changes status, and each moves toward golden:

- uvm_many_to_one (DIFFERENT): clsloc 1250 -> **0** through § cloneLvSharesHomeUnitTs465. Its
  head is still ModuleEmit's $unit-route typedef listing of module work@top, which is pass 463's
  face and the sister's.
- uvm_param_vif_config_db (DIFFERENT): § pkgTransImpAggTd465 lists 74 transitive entries in
  tb_params_pkg. The listing is golden 134 / pristine 59 / law 96 entries. The name overlap with
  golden goes 57 -> 94 with no new non-golden name. clsloc stays 1574 -> 1574.
- generated/rsd/rsd (SURELOG_CRASH, no golden): § pkgTransImpAggTd465 fires 524 times.

## Laws (src/ParamEmit.cpp, read through src/LawSwitch.h; R11U465_OFF drops both; R11U465_TRACE=<dir>)

1. **§ cloneLvSharesHomeUnitTs465** (`R11U465_CLONELVUNITTS_OFF`).
   - What golden does: under a $unit import of the home package (§ classPropUnitImport21 with
     § unitImpTransLateList459's chain), the shared clone loop-variable object of
     § cloneLoopVarShared37 binds the **same typespec object** that the home package's
     elaborated view gave its own loop variable.
   - The decode: Surelog's lateTypedefBinding runs the FileContent pass last. Its
     swapForSpecifiedVar gives the home loop variable the int_var fallback for a class property
     that the $unit scope cannot resolve, or the element's class_var for a package queue. The
     ref_var that every importer clone binds keeps that typespec. Golden ref_var
     uvm_pkg::uvm_default_factory::set_type_override_by_type::index is over int_typespec #478798,
     the same object as the class view's int_var. uvm_init::idx is over class_typespec
     uvm_object_wrapper, the same object as the class_var. Ours had the unsupported placeholder,
     or the answer of the unimported route (a class_typespec for an associative index, an index
     int_typespec at its keyword).
   - Design-final, at the end of drainPaNameCopySrc38, after every deferred binding of the shared
     object.
   - It abstains when the home loop variable is missing or ambiguous (two typespecs). It also
     abstains when the current typespec has the same kind and location as the home's. That is the
     string-formal case uvm_has_wildcard: the content is equal, and the home copy lacks the
     vpiInstance our existing object carries. Replacing it there made 13 new localized failures
     in law1; law2 and law3 narrowed this.
2. **§ pkgTransImpAggTd465** (`R11U465_TRANSAGGTD_OFF`).
   - What golden does: a package's enum and struct import clones list **transitively**, as the
     vector, scalar and class aliases already did. CompileHelper::importPackage copies the whole
     datatype map. The listing is the ONE shared clone per typedef, stamped by the last lister.
   - Only a wildcard import item reaches through, along wildcard edges. A transitive typedef that
     no earlier importer has cloned abstains (traced).
   - A clone that the walk listed and a direct item listed again is one entry (cases tl03, tl10).

## Grid (evidence/grid.txt; every exit code 0 on both binaries; every case accepted by upstream slang)

**LV, § cloneLvSharesHomeUnitTs465**

| case | shape | pristine | law5 |
|---|---|---|---|
| lv01 | class queue property, out-of-body method, $unit chain import | NOT_EQUAL 18 | **STRICT_EQUAL** |
| lv02 | the same with a direct $unit import of the home | 456 | 456, bytes move, head at the class listing (sister's, below) |
| lv03 | package queue of class handles (the uvm_init shape) | STRICT_NOTEQUAL type | **STRICT_EQUAL** |
| lv04 | associative property indexed by int | 14 | **STRICT_EQUAL** |
| lv05 | associative property indexed by a class | 18 | **STRICT_EQUAL** |
| lv06 | string formal (control) | byte-identical | byte-identical |
| lv07 | no $unit import (control) | byte-identical | byte-identical |
| lv08 | two importers, b importing a and h | 18 | 18 |

In lv08 the head moves later, from a's clone to b's clone. Golden binds b's body reads to a's
clone loop variable: a re-clone chain, not written. The dump distance is 40 -> 42 because the
replaced placeholder is now unreferenced (dump tail only).

**TL, § pkgTransImpAggTd465**

| case | shape | pristine | law5 |
|---|---|---|---|
| tl01 | env -> agent -> types | 528 | **STRICT_EQUAL** |
| tl02 | three hops | 354 | **STRICT_EQUAL** |
| tl05 | unpacked struct and classes | 328 | **STRICT_EQUAL** |
| tl07 | enum alias | 252 | **STRICT_EQUAL** |
| tl08 | two outer importers, last writer | 140 | **STRICT_EQUAL** |
| tl03 | direct item first (control) | byte-identical STRICT_EQUAL | byte-identical STRICT_EQUAL |
| tl09 | direct item only (control) | byte-identical STRICT_EQUAL | byte-identical STRICT_EQUAL |
| tl10 | transitive item first, then direct (control) | byte-identical STRICT_EQUAL | byte-identical STRICT_EQUAL |
| tl04 | the middle package imports explicitly | 234 | 234, byte-identical |
| tl06 | outer package imported at $unit | 192 | 385 |

In tl06 every package listing now equals golden and the dump distance is 8 -> 2. The head moved
later, to the design-level $unit typedef listing (`design vpiTypedef`), which lacks the
transitive enum: ModuleEmit / UhdmExporter, the sister's.

The pass-462 case r11u462repro EB/eb01 also goes NOT_EQUAL 160 -> **STRICT_EQUAL** (a transitive
enum). v11u462 VS/vs09 is unchanged (50), and so is VS/vs08 (76).

**Switch check** (evidence/switchcheck.txt):

- R11U465_OFF gives pristine's md5 on 18 of 18 case dirs.
- R11U465_CLONELVUNITTS_OFF restores every LV dir.
- R11U465_TRANSAGGTD_OFF restores every TL dir.

## Prediction and gates

The prediction (evidence/prediction.txt) was written before the sweep. It comes from a traced
census of law5 (evidence/census_*.txt, tools/r11u465_tracerun.py) over the union of two text
censuses, both fence-filtered by a file list read by a program:

- the first census finds file-scope import lines;
- the second finds chains of three packages.

The census covered 45 probe dirs, 97 surelog and 14 uhdm2rtlil row-modes, and 316 sv-tests rows.
The positive control is pipelined_get_put, which fires both laws. The prediction names exactly 4
firing sv-tests rows.

One full five-stage sweep on law5 (evidence/sweep_law5.log):

| stage | result |
|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63; regressions=0 conversions=0 changes=0; all 4087 databases identical to the control /tmp/intr11u462 by path-normalized uhdm-dump |
| surelog | 480 / 474 CMP_EQUAL; 0/0/0; csv equal to the control except the two LowMem log-path texts |
| uhdm2rtlil | 803 / 803 CMP_EQUAL; 0/0/0 |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; csv identical |
| sv-tests | EQUAL 1930, STRICT_NOTEQUAL 0, DIFFERENT 10, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=0 changes=0; csv byte-identical to the control |

- byteverify (SELFCHECK=1) against the control: surelog 0 of 962, uhdm2rtlil 0 of 1608,
  downstream 0 of 805 movers.
- The sweep's trace (evidence/sweep_trace_firings.txt) fires on exactly the 4 predicted rows,
  with the census counts (rsd 524, many_to_one 180, param_vif_config_db 74, pipelined_get_put
  186).
- 31 kept sv-tests databases differ in raw bytes. 27 are STRICT_EQUAL to the control under
  uhdm-strictcmp --no-canon (the serialization-order variance). The other 4 are the predicted law
  movers (evidence/svtests_rawbyte_movers_strict.txt).
- Canaries: ok=52 and ok=16; both ctcan2 checks PASS.
- Binary audit, fence-filtered: surelog 1523 of 1573 records name law5 (the other 50 hold only a
  Surelog line), uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346.
- The corpus command exits 0. The sv-tests stage runs through the main tree's tests/sweep.sh
  because the worktree's UVM folder is empty, and exits 1 on the main tree's law-index check
  alone.

## Goal 1

There are no new shapes on this ground. No SURELOG_ONLY, BOTH_REJECT or SLANG_CRASH row carries
an exporter 'unsupported' detail. Every detail is an upstream slang file:line diagnostic. The
black-parrot size guard stands (not measured this pass). The probe faces C::mk().arr[1],
u.mk(x).a[2] and this.mk().inner.s are not reached.

## Residues (ranked; all wrong on pristine too)

1. lv08: in a re-import chain, golden binds the outer importer's clone body reads to the inner
   importer's clone loop variable.
2. tl04: an explicit `import p::t;` in the middle package (golden lists more in the outer
   package).
3. param_vif_config_db's transitive class-specialization typedefs (`sfr_agent_pkg::this_type`,
   40 missing names).
4. lv02: the class listing under a direct $unit import of the home (vpiReg int_var face).
5. vs09 / vs08 ($bits(int) artefacts; the typedef range fold).
6. The carried lists of passes 463 and earlier.

## Sister-ground faces (reported, not written)

- **pipelined_get_put's head now.** The uninstantiated interface definition
  work@mbus_pipelined_driver_bfm lists 4 typedefs where golden lists 131. Its $unit-imported
  package's whole transitive listing is missing (ModuleEmit's interface typedef listing). The
  top_hdl interface-instance face sits behind it.
- **The design-level $unit typedef listing** (ModuleEmit d->Typespecs at the tds206 site, and
  UhdmExporter) lacks the transitive enum and struct clones (TL/tl06).
- **many_to_one**: ModuleEmit's $unit-route typedef listing of work@top (pass 463's face).

## Process

The worktree's first build was byte-identical to the main tree's, so there was no separate
pristine build. Intermediate binaries law1 to law4 got only case runs and runner calls on the
target rows. There was one full sweep, on law5 (the final binary), and one byteverify against
the master's control.

**Slip:** one 3-row runner call (law5 and pristine) ran while the sister r11u464's corpus sweep
was live. This affected timing only.

No fenced test was named, opened or run.
