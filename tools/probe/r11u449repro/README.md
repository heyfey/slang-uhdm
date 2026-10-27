# r11u449 — expression/parameter ground, pass 449: the importer-package clone bodies of the uvm-examples rows

Base 84452b82f (pass 446). Implementer pass on the expression/parameter ground
(src/StmtEmit.cpp, src/ParamEmit.cpp, src/EmitHelpers.h; ExprEmit, TypeEmit,
ModuleEmit, UhdmExporter, TaskFuncEmit, include/ and uhdm_main.cpp unchanged).
Final binary `law5`, md5 c1d444154eb3fc539c31cdd6546704ed, linking slang
12.0.0+545f88b2e. The pristine is the frozen copy of the main tree's build
(md5 0629d46c68933a364c6dcac8b2a3967b, which the worktree's own base build
reproduced); the pristine reading is the master's control sweep at this base,
/tmp/intr11u446 (its five csvs equal the committed results/*.csv; the brief
named /tmp/intr11u447, the control of the base before pass 446 landed).

## Verdict

THREE SV-TESTS ROWS CONVERT, DIFFERENT -> STRICT_NOTEQUAL (uhdm-cmp now
equal), with 0 regressions and 0 changes in all five stages. Fresh rows of the
law sweep (/tmp/r11u449_sw/svtests.csv):

    generated/uvm-examples/uvm_messaging_example.sv,STRICT_NOTEQUAL,differ:file(5),differ:file(5)
    generated/uvm-examples/uvm_priority_arbitration.sv,STRICT_NOTEQUAL,differ:file(5),differ:file(5)
    generated/uvm-examples/uvm_priority_grab_lock.sv,STRICT_NOTEQUAL,differ:file(5),differ:file(5)

sv-tests at the end: EQUAL 1914, STRICT_NOTEQUAL 3, DIFFERENT 23, SURELOG_ONLY
75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346;
`regressions=0 conversions=3 changes=0`.

These are pass 446's three 18-failure rows. Every localized failure on them was
on this ground (pass 446's sister-ground list), and all of them are written
here except one (the constructor clone's `rh`, written in StmtEmit through the
body's symbol map, see law 6). Localized failures (pass 446's localizer
evidence/tools/clsloc.cpp, golden vs ours):

| row | base (control) | law5 |
|---|---|---|
| uvm_messaging_example | 16 | 0 |
| uvm_priority_arbitration | 16 | 0 |
| uvm_priority_grab_lock | 16 | 0 |
| uvm_test_init | 128 | 0 (uhdm-cmp still unequal: package listing, see residues) |
| uvm_use_models_unidirectional | 16 | 0 (uhdm-cmp still unequal: interface listing) |
| uvm_generation_seq_persistence / _poly / _randomization | 49 | 1 |
| uvm_use_models_bidir_get_put / _item_done | 28 | 12 |
| uvm_ac_config_db, uvm_ef_vif_config_db, uvm_vif_config_db | 69 | 37 |
| uvm_id_register | 109 | 61 |
| uvm_many_to_one | 1320 | 1250 |
| uvm_param_vif_config_db | 1617 | 1579 |
| uvm_use_models_pipelined_get_put | 2035 | 2007 |

(evidence/uvm_rows_localized_base_vs_law4.txt; law4 and law5 differ only in
law 2's typedef abstention, which no UVM row reaches.)

Goal 1: nothing on this ground. No rejecting row carries an exporter message
(the sv-tests stage's SURELOG_ONLY / BOTH_REJECT rows read as at the base);
the black-parrot size guard (§ macroVecLitTokenText403) stays, bp_unicore not
remeasured (no change near it). The goal-1 probe faces of item (a)
(C::mk().arr[1], u.mk(x).a[2], this.mk().inner.s) were not reached.

## Laws (switch `R11U449_OFF` drops all; `R11U449_TRACE=<dir>` logs each firing)

All read through src/LawSwitch.h (`lawOn(449, ...)`, `lawTrace(449, ...)`); no
src/R*.h, no getenv, no reader function; one record type and one accessor in
EmitHelpers.h (`CloneLvFormalTd449`, `cloneLvFormalTd449()`).

1. **§ macroCloneLoopVarPerSub449** (StmtEmit, the § cloneLoopVarShared37 key;
   `R11U449_LVKEYSUB_OFF`). One shared home loop-variable object per HOME
   SUBROUTINE, not per source position. The macro-written UVM methods
   (`M__UVM_GET_PACKED(byte)`, `(int)`, `(longint)` and the SET twins,
   uvm_packer.svh 551 / 620) put every expansion's `foreach (stream[i])` at the
   one macro-body position, so the position key gave get_packed_ints and
   _longints the object get_packed_bytes minted first (byte_typespec 551:49).
   Golden mints one per method over its own formal's element typespec (int
   551:48, longint 551:52). The key gains the loop variable's full name with
   the importer's leading package dropped, so both views of one clone and
   every importer still reach one object. Grid cases/MC (mc01 to mc04
   STRICT_NOTEQUAL depth -> STRICT_EQUAL).
2. **§ pkgVarArrCloneLoopVarTs449** (StmtEmit; `R11U449_PKGVARARR_OFF`). A
   foreach over a PACKAGE variable resolves the shared home object the way a
   class property does (§ cloneLoopVarClassPropArrayTs238's decode of
   getSimpleVarFromTypespec): a queue, dynamic or fixed array a fresh empty
   array_typespec, an associative array its index typespec, a string its
   string_typespec. UVM uvm_init `foreach (uvm_deferred_init[idx])`
   (uvm_globals.svh 373). Abstains on a typedef'd array (golden binds the
   typedef's listing object, pv07) and on a package a $unit import reaches
   (golden binds the element, pv09). Grid cases/PV (pv01 and pv10 STRICT_NOTEQUAL
   type -> STRICT_EQUAL; pv02 to pv06, pv08 keep an earlier face of the package
   variable listing, their shared object now equal to golden's; pv07, pv09
   byte-identical).
3. **§ formalClsElemMemberDrill449** (StmtEmit; `R11U449_FORMALCLSMEM_OFF`).
   When the iterated name resolves to a formal whose element type is a class
   that declares a property of the same name, the shared home object takes
   that property's route (Surelog's decodeHierPath looks the path name up in
   the class it reached). UVM uvm_reg_block::get_blocks(ref uvm_reg_block
   blks[$]) `foreach (this.blks[blk_])`: golden binds the property `blks
   [uvm_reg_block]`'s index class_typespec at 42:30, ours the formal's element
   at 1274:45. Grid cases/TS: ts04, ts05 (bare spelling), ts06, ts09 (string
   index), ts10 (a property of another class B) drill to golden's object;
   ts01, ts07 (B has no property of that name), ts08 (no property named like
   the array), ts02, ts03 byte-identical.
4. **§ cloneLvFormalTdTopListing449** (record in StmtEmit, rebind in ParamEmit
   drainUnsizedBasedRhs106; `R11U449_FORMALTDTOP_OFF`). The shared home object
   of a foreach over a formal typed by a package struct, union or enum typedef
   binds the typedef's shared listing clone (the object the home package's TOP
   view and every importer list, § pkgImportAggCloneLastWriter32's), not the
   home DEF typedef nor the clone formal's private copy, and is parented at the
   home foreach_stmt (§ 258's placement, so § cloneAggLocalOwnCopy241 takes no
   private copy of it). UVM uvm_reg_map::perform_accesses `foreach
   (accesses[i])` over `ref uvm_reg_bus_op accesses[$]`: golden
   uvm_pkg::uvm_reg_bus_op at 58:42 owned by messaging_pkg (members leading to
   the qualified uvm_pkg::uvm_reg_addr_t), ours the private copy at 244:9. Grid
   cases/IT (it01 STRICT_NOTEQUAL line, 20 objects -> fullname, 4 objects, a
   pre-existing member-name face; it03 binding golden's object with the verdict
   unchanged; it02, it04 behind an earlier package-listing face).
5. **§ freeCloneCmCallKeepsClassMethod449** (ParamEmit
   bindPkgTfBodyClassMethodClones192, fence 3; `R11U449_FREECLONECM_OFF`). An
   unqualified free function is "owned" by the package only when it is not
   itself an import clone: a wildcard importer's copy of the home's FREE
   subroutine keeps its `C::m()` calls on the class_defn's method, as its
   `C::m` copies already do. UVM uvm_init `top = uvm_root::get();`
   (uvm_globals.svh 381) in messaging_pkg's clone. Grid cases/FC (fc01 binding
   golden's method, dump distance 60 -> 56; fc02 behind another face; fc03, an
   in-body static method, byte-identical).
6. **§ cloneCtorEatenLocalNoBind449** (StmtEmit emitCtorBody27;
   `R11U449_CTOREATEN_OFF`). In a wildcard-import clone the declaration a
   no-port constructor's compiler ate (§ ctorFirstBodyItemIsUnlistedNoBind144)
   binds nothing: the declaration leaves the clone body's symbol map, so
   neither the reference emitter nor § pkgCloneHierBind9's name map (recorded
   after the body) reaches it. UVM uvm_root::new `uvm_report_handler rh;
   super.new(...); rh = new("reporter"); set_report_handler(rh);`: golden
   unbound in both importer views, ours the clone's class_var rh at 366:22.
   Grid cases/CE (ce01 NOT_EQUAL -> STRICT_EQUAL; ce02, ce03 closer, 101 -> 63
   and 145 -> 107, behind the class-property implicit-net face). A first
   attempt nulling the reference in ExprEmit moved no byte (the UhdmExporter
   name binder re-bound it) and was removed before any runner call.

## Grid (34 case dirs; evidence/grid_law5.txt, evidence/grid_switch_dist_law5.txt)

Every exit code 0 on both binaries. pristine -> law5: 7 to STRICT_EQUAL (MC
mc01 to mc04, PV pv01, pv10, CE ce01; FC fc01 was already STRICT_EQUAL and
now binds golden's method), it01 20 -> 4 strict objects, 18 more cases move
bytes with the same verdict, 8 byte-identical (fc03, pv07, pv09, ts01, ts02,
ts03, ts07, ts08), none further on the strict axis. R11U449_OFF gives
pristine's bytes and exit code on 34 of 34; each case's own law switch alone
restores pristine on every one of its 26 movers. The normalized dump distance
grows by 1 to 12 lines on MC and PV although strict reads equal: golden prints
the shared home objects in the dump's tail (parented at the HOME foreach) and
ours inline (parented at the clone's), a pre-existing placement (residue 3).

## Census, predicted by name before the sweep, and the sweep

Candidate rows: every corpus row and probe case whose sources hold a package
with a wildcard import inside it (drivers/candidates.py, fence-filtered before
any file is read): surelog 40 (+ Scoreboard, SimpleUVM, BuildUVMPkg), uhdm2rtlil
9, probe 212, sv-tests 172 (the `uvm` tag plus the package-import scan).
Traced runs of law5 on them (drivers/probecen.sh for probe, verify_golden.py
--filter for the corpora, the runner for sv-tests) predicted: surelog byte
movers MiniAmiq d/t and SeqDriver d/t (§ formalClsElemMemberDrill449 only,
status unchanged), no uhdm2rtlil and no probe mover or firing (positive control
MC/mc01 fires 4 through the same driver), the 3 sv-tests conversions and
firings on the 17 uvm-examples rows and the SLANG_ONLY rows uvm_overriding,
uvm_slave_agent, uvm_slave_agent_multi_seq_item and uvm_wait_for_signal. The
sweep's trace (/tmp/r11u449_sw_tr) names exactly those 25 databases.

The one five-stage sweep on law5 (drivers/fullsweep.sh, trace on):

- probe: EQUAL 4023, STRICT_NOTEQUAL 64 of 4087, regressions=0 conversions=0
  changes=0; 0 of 4087 databases move by path-normalized dump.
- surelog: default 480 + 0, testflags 474 + 0, regressions=0 conversions=0
  changes=0 (Tnoc d/t CMP_NOTEQUAL standing); byteverify 4 of 962 movers, the
  predicted MiniAmiq d/t and SeqDriver d/t (strict still equal; the
  get_blocks blk_ object moves from 1228:45 to golden's 43:30), self-check 961.
- uhdm2rtlil: 803/1/67 both modes, regressions=0 conversions=0 changes=0
  (stamped_gen_param d/t CMP_NOTEQUAL standing); byteverify 0 of 1608.
- downstream: 803 IDENTICAL, 66 SLANG_REJECT, 2 EQUIVALENT, 0 DIVERGENT; csv
  identical to the control; byteverify 0 of 805.
- sv-tests: as in the verdict.
- canaries ok=52 and ok=16 (changed 0); ctcan2 PASS on surelog
  (EXPECT_UNKNOWN=1) and uhdm2rtlil (EXPECT_UNKNOWN=6).
- binary audit (fence-filtered cmds.txt): surelog 1523 of 1573 naming law5,
  the other 50 holding only a Surelog line; uhdm2rtlil 1740 of 1740; sv-tests
  2346 of 2346; none naming another binary.
- determinism: three concurrent law5 runs of uvm_messaging_example from the
  sweep's working directory read the sweep's hash, 4 of 4 (the bytes depend on
  the working directory on pristine too).
- The new byte hashes the master re-records: MiniAmiq default and testflags
  2045a4349505..., SeqDriver default 76376697c46f..., testflags 904727dc7e44...

## Residues, ranked (all wrong on pristine too, none moved away)

1. **The three converted rows' strict faces (file(5), walk diverged).** (a)
   Clone-body locals and the do_bus_access local array of type
   uvm_pkg::uvm_reg_bus_op hold private struct copies at the typedef 244:9
   where golden has the home DEF listing's 1793:40 (UhdmExporter
   § cloneAggLocalOwnCopy241 / § cloneSharedAggOwnCopy265 relocate to the
   copy's own span, the sister's); (b) in the importer's DEF-view clone golden
   binds the left-side indexed part-select `data[i0*8+:8]` (uvm_reg_map.svh
   2003) to the home elaborated local `data`; the clone binders (UhdmExporter
   § pkgCloneHierBind9, TypeEmit § cloneStmtHomeVarRef17) handle ref_obj,
   ref_var and bit_select only. Decoded on evidence/residue/IP: binds only for
   an assignment left side over a local with a non-constant base, only in the
   importer's first (DEF) view, a part-select or a constant base never; not
   written (the binders are the sister's, the trigger not fully decoded).
2. **Diamond imports in importer package listings** (uvm_generation_seq_*,
   uvm_test_init): golden lists the imported package's whole signal vector per
   import path (test_lib_pkg: uvm_pkg's 26 variables four times, 104, ours 78)
   and Param_assigns likewise (164 vs 123) while Parameters stay deduplicated
   by name (123 = 123). Ours deduplicates diamonds: ParamEmit `impVars9`'s
   seen set and collectImportedParams' `vis` set. Decoded, not written: the
   variable half is a path guard instead of a visited set, but the
   param_assign half needs duplicate param_assigns without duplicate
   parameters and reaches module scopes too; golden also lists 78 package
   nets there that ours does not.
3. **The shared home loop-variable object's parent** is the clone's
   foreach_stmt where golden's is the home's (only law 4's records and § 258's
   are re-parented); invisible to both judges, visible in dump order.
4. uvm_use_models_unidirectional: the interface instance adpcm_driver_bfm's
   listing (vpiParameter UVM_ALL_ON, a port net's actual), ModuleEmit's.
5. PV pv02 to pv06, pv08: the package variable's own listing (int q[$] as
   array_var over int_var), ParamEmit emitPackageVar, not decoded; pv07's
   typedef'd array object; pv09's $unit-reached element route.
6. CE ce02/ce03: the class-property implicit net of an out-of-body constructor
   (LAW C); FC fc02: an importer's own body calling C::m; IT it02/it04: the
   typedef listing location (first use) in small packages.
7. The carried lists of passes 447 and earlier (the brief's items (b) to ({)),
   not reached this pass.

## Sister-ground faces (reported, not written)

- UhdmExporter § cloneAggLocalOwnCopy241 / tryOwnCopy265: private copies of a
  home struct in a clone body take the copy's span (244:9) where golden reads
  the home DEF listing object's (1793:40): the first strict face of the three
  converted rows.
- UhdmExporter § pkgCloneHierBind9 (bindable37) and TypeEmit
  § cloneStmtHomeVarRef17: an indexed_part_select is not a clone-binding kind
  (residue 1b).
- ModuleEmit: uvm_use_models_unidirectional's interface listing (residue 4).

## Process

- Budget: no pristine sweep, no pristine build beyond the worktree's base
  build (md5-checked against the main tree, then left unused); law1 to law5
  used on case runs and targeted runner calls (the 3 rows on law2 to law4, the
  26 open rows on law4, the 172-row census on law5); one five-stage sweep on
  law5. The sweep driver's first launch passed the four corpus names
  unquoted, so tests/sweep.sh printed its usage and ran nothing; the sv-tests
  stage ran, then the four corpus stages were run on the same binary and
  workdir after a quiet check.
- Slips, none affecting a measurement: the 26-row runner call on law4 started
  while the sister r11u448's sweep was in its surelog stage (the pgrep output
  was read after launch); my waits were then gated on a quiet reading. One
  shell ran `$UHDM_CMP` unset, which executed three golden databases as
  scripts in their row work directories under /tmp/r11u449_rw26; no file was
  written there or in the golden cache (mtimes unchanged), the commands rerun
  with the variable guarded. Two waiter loops matched their own command lines
  and were stopped by task id before they gated anything.
- Fence: the fence list was read into /tmp/r11u449_fence.txt by a program and
  never printed; every tree-wide list (candidates, cmds.txt audit) was
  filtered on it before any file was opened. No fenced test named, opened or
  run.
- Drivers: drivers/run1.sh (one case, golden cached per case text),
  grid.sh, dist.sh (normalized dump distance), candidates.py, probecen.sh,
  fullsweep.sh. Tools: evidence/tools (pass 446's clsloc.cpp; dumpids, tsx,
  tdown, pkgvec, pkgnames, subdump, recctx.py, lvx.sh), all linked statically
  against ~/.local/lib64 libuhdm.a, libcapnp.a, libkj.a.
