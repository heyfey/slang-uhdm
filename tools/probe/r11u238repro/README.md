# r11u238 — pass 238, the expression/parameter ground (implementer)

Base `0a1c70e0` (matrix-1.87). Ground: `src/StmtEmit.cpp`, `src/ParamEmit.cpp` and the new switch header
`src/R238.h` (four laws plus one sub-switch; each reads its own `R11U238_<LAW>_OFF`, `R11U238_OFF` drops all and
restores the pristine bytes; `R11U238_TRACE=<dir>` writes `<dir>/<pid>.238`, first line `OUT <-o path>`, then one
`<law> <detail>` line per firing). The four slang-fenced tests are never named here: every driver reads them from
the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`, fail-closed; nothing fenced was dispatched outside the
gate sweeps, read, decoded or opened (the census ran with a `--filter` built from `$FENCED`, byteverify and the away
census ran on mirrors / path lists filtered by `$FENCED` before any file was opened).

## Verdict per targeted row (base -> this pass; fresh rows of the law sweep `/tmp/r11u238_wL`)

No corpus row converts. Every corpus change is a first record moved later in the walk with no golden-agreeing
record lost (chain-keyed AND flat away census 0 on all nine movers). **Thirteen probe cases CONVERT.**

| row-mode | base | after | first record after, and whose ground |
|---|---|---|---|
| BuildUVMPkg d/t | `differ:file(2)` #77588 | `differ:line(16)` #81218 | #77588 (`foreach (m_name[i])` in `uvm_component::get_depth`) and #79836 (`foreach (values[i])` in `uvm_component::m_set_cl_verb`) cleared. Next: `uvm_driver`'s `REQ req;` / `RSP rsp;` (uvm_pkg.sv 50989): golden's `class_typespec uvm_sequence_item` sits at the type parameter's DEFAULT `REQ=uvm_sequence_item` (50947:29-46), ours at the specialization typedef's argument (`typedef uvm_driver #(uvm_sequence_item, uvm_sequence_item) uvm_default_driver_type`, 57038:25-42): the class_defn listing's type-parameter-typed property, **ground B** (class body / type-parameter writers, UhdmExporter / TypeEmit) |
| Scoreboard d | `differ:type(1)` #79148 | `differ:file(11)` #80496 | #79148 cleared; next is the same `uvm_driver` face (`uvm_driver.svh 44:29-46` vs `uvm_seq.svh 38:25-42`), **ground B** |
| MiniAmiq d/t | `differ:depth(1)` #64612 | `differ:fullname(8)` #68597 | #64612 cleared (the importer clone's loop variable binding), then MiniAmiq #66872 / #67322 (two more clone faces, below) cleared too. Next: the ref_typespec full names inside the `array_typespec` of the body-local associative array `uvm_factory_queue_class sorted_override_queues[string]` (uvm_factory.svh 1524) in the class-method clone `svaunit_pkg::uvm_default_factory::print` (golden's names non-empty, ours empty): the body-local declaration's typespec, TaskFuncEmit, **ground B** |
| SeqDriver d/t | `differ:depth(1)` #64568 / #64580 | `differ:fullname(8)` #68553 / #68565 | the same as MiniAmiq (adpcm_pkg clone), **ground B** |
| SimpleUVM d/t | `differ:line(3)` #75572 | `differ:line(8)` #75572 | first record unchanged (the late-bound net `work@top.m_parent`, decoded below, not written); the count grows because the walk now diverges later: the old divergence (the foreach face of BuildUVMPkg's #79836 shape) is cleared and the walk reaches the `uvm_driver` face (#80104); chain away census 0 |

Fresh rows (`/tmp/r11u238_wL/surelog.csv`, the law binary):

```
BuildUVMPkg,default,STRICT_NOTEQUAL,differ:line(16),,differ:line(16)
BuildUVMPkg,testflags,STRICT_NOTEQUAL,differ:line(16),,differ:line(16)
MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
Scoreboard,default,STRICT_NOTEQUAL,differ:file(11),,differ:file(11)
SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
SeqDriver,testflags,STRICT_NOTEQUAL,differ:fullname(8),,differ:fullname(8)
SimpleUVM,default,STRICT_NOTEQUAL,differ:line(8),,differ:line(8)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:line(8),,differ:line(8)
```

**PROBE: THIRTEEN CONVERSIONS** (STRICT_NOTEQUAL -> EQUAL; `results/golden_probe.csv` untouched; fresh rows of
`/tmp/r11u238_wL/probe.csv`, each `<case>,EQUAL,,equal`):

| case | base | law(s) |
|---|---|---|
| r10uvm204repro/g204_b_ctx | `differ:depth(1)` | cloneForIncBindsHomeVar238 (free + class clones) |
| r10uvm204repro/g204_c_shadow | `differ:depth(1)` | cloneForIncBindsHomeVar238 (class clones) |
| r10uvm204repro/g204_e_head | `differ:depth(1)` | cloneForIncBindsHomeVar238 (class clones) |
| r10uvm20repro/t31_t | `differ:type(1)` | foreachFlatLocalRefTs238 |
| r10uvm21repro/t32d_t | `differ:type(1)` | cloneLoopVarClassPropArrayTs238 |
| r10uvm22repro/t33e_t | `differ:file(2)` | foreachClassPropStringTsShared238 |
| r10v180repro/v180_a_share | `differ:depth(1)` | cloneForIncBindsHomeVar238 (free clones) |
| r10v181repro/v181_e_idxbase | `differ:type(1)` | cloneLoopVarClassPropArrayTs238 |
| r10v181repro/v181_f_mixed | `differ:type(1)` | cloneLoopVarClassPropArrayTs238 |
| r10v204repro/v204_c_clones | `differ:depth(1)` | cloneForIncBindsHomeVar238 (class clones) |
| r10v204repro/v204_m_module | `differ:depth(1)` | cloneForIncBindsHomeVar238 (class clones) |
| r10v204repro/v204_s_shadow | `differ:depth(1)` | cloneForIncBindsHomeVar238 (class clones) + cloneLoopVarClassPropArrayTs238 (`this.` spelling) |
| r10v204repro/v204_v_extra | `differ:depth(1)` | cloneForIncBindsHomeVar238 (class clones) |

One probe CHANGE: `r10uvm180repro/g180_a_kinds` `differ:depth(1) -> differ:line(5)` (cloneForIncBindsHomeVar238
clears the depth record; the walk then reaches a pre-existing face: golden's `enum_typespec kx180_home::howlite_et`
located at 109:46-56, ours at the typedef 20:3-64 — a typespec copy's location, ground B; chain away 0, toward 3).

## The laws

### § foreachClassPropStringTsShared238 (switch `R11U238_PROPSTRTS_OFF`; StmtEmit, § foreachClassPropStringVar22's branch; drain fallback in ParamEmit drainShareDefParamTs)

BuildUVMPkg d/t #77588 (brief item 1). `foreach (m_name[i])` over the class property `string m_name` in the
out-of-body `uvm_component::get_depth`: golden's loop variable `string_var i` binds the PROPERTY'S own
`string_typespec` (uvm_pkg.sv 38343:3-9, the written keyword), ours a fresh unlocated one. Surelog: the loop
variable is `CompileHelper::getSimpleVarFromTypespec` of the typespec `decodeHierPath` answers for the property
(CompileType.cpp, the `uhdmstring_typespec` branch, then `var->Typespec()->Actual_typespec(spec)`): the declaration's
object itself. **Law**: the loop variable binds the class_defn's listed property's `string_typespec`; the property's
ref_typespec is bound late, so the loop variable's ref is mirrored by the existing `pendingLoopVarTs9` drain
(`foreachClassPropStringTsShared238 defer` in the trace); a ref the mirror misses keeps the base's fresh object
(`_miss`, fired nowhere). Only a property written with the `string` keyword: a typedef'd property (`str_t m_al`,
grid f16) is golden's typedef object named `str_t` where ours names the property's typespec `p::str_t`, so the law
abstains there. Cases (§ foreachClassPropStringTsShared238): F/f05, f08 (`differ:file -> EQUAL`, both views: an
out-of-body method, an inherited property), f13 (a parameterized class and its typedef specialization, `this.` and
bare; stage 1 at the base on `p::cb_t`, dump-checked equal to golden on every loop variable), f14 (a `$unit` import,
a dotted `o.m_name[k]`, a shadowing formal, a static property; stage 1 at the base, dump-checked), f15 (a class in a
module: no package, the branch's gate is closed, bytes unchanged), f16 (a typedef'd property, abstains; the plain
`string m_n2` beside it fires and is dump-checked), f01-f03 (in-body methods, a module function's string formal, a module
string: controls, unchanged).

### § foreachFlatLocalRefTs238 (switch `R11U238_FLATLOCALREFTS_OFF`; StmtEmit, the foreach iterated-array ref_var branch)

Scoreboard d #79148 / BuildUVMPkg #79836 (brief item 1). `static string values[$];` in the PAREN-LESS out-of-body
`function void uvm_component::m_set_cl_verb;`: Surelog's TF-ITEM production (§ blockItems9) flattens the body
local to its element variable (`string_var values` over a `string_typespec`, which ours already writes); golden's
`foreach (values[i])` then binds the iterated `ref_var values` to that very `string_typespec` (uvm_pkg.sv
41169:10-16), exactly as its loop variable already does, where ours deferred an array bind and minted an empty
`array_typespec`. **Law**: a subroutine-local whose emitted declaration is a non-array variable binds the reference
to the declaration's own typespec. **Refined before delivery** (the first law sweep regressed
`r10v148repro/v148_g_corpus` to stage 1): where § tfItemLocalLosesToPkgVar148 hands the name to a same-named
PACKAGE variable (`int names_v7 [3]` both in the package and in the paren-less body), the late binder reads the
package listing and the base's deferred array bind stands (grid f21 dump-checked: `names`/`vals` keep the package's
`array_typespec`, `other` takes `int_typespec 11:5-8`, all three equal to golden). Cases (§ foreachFlatLocalRefTs238):
F/f11, f12, f18 (`differ:type -> EQUAL`, both views: class method, package function, module function and task,
nested `begin`), f17 (seven shapes in one paren-less body: static string queue, dynamic, fixed, associative,
class-handle queue, two-dimensional, a paren-less task; stage 1 at the base on the associative loop variable,
dump-checked equal to golden on all seven), f19 (an interface function, an import clone), f20 (a `$unit` import,
dump-checked), f21 (the package-variable shadow), f04, f06, f07, f09, f10 (array_var declarations and parenthesized
bodies: controls, unchanged).

### § cloneForIncBindsHomeVar238 (switches `R11U238_CLONEFORINC_OFF`, and `R11U238_CLONEFORINCCLS_OFF` for class-method clones alone; StmtEmit ForLoop branch, drained in ParamEmit drainPaNameCopySrc38)

MiniAmiq #64612, SeqDriver #64568 / #64580 (brief item 1, pass 236's "binding face"). In the wildcard-import clone
`svaunit_pkg::uvm_oneway_hash` golden binds every reference to the for-header loop variable `_byte` (the
condition, the increment `_byte++`, the body's `string_in[_byte]`) to the HOME function's object
`uvm_pkg::uvm_oneway_hash::_byte` (uvm_misc.svh 378:12-17); the clone's own `int_var _byte` is only the init
declaration. The strict walk lists the home object once, under the increment (the first of the three it reaches),
which is the depth record. Decoded with uhdm-dump on grid k01 (free function) and k12 (class method): golden binds
6 of 6 clone references of each loop variable to the home object, pristine 0, this law 6 of 6
([evidence/decode_dumps.txt](evidence/decode_dumps.txt)). Which home object: for a FREE subroutine the home's LAST
emission outside any clone (the home package's elaborated listing; binding the definition listing's object leaves
golden's record unlisted, k01/k02), for an out-of-body CLASS METHOD the FIRST (the class listing; the last one
carries a folded range golden's object keeps as `64-1`, MiniAmiq stage 1 under that experiment). **Law**: the
clone's for statement (both views) records every `ref_obj` bound to its header loop variable (a UhdmListener bounded
to the statement's own subtree: an object outside it is marked visited on entry, because UhdmListener follows
`vpiParent` and bindings), and the drain re-binds them to the home object; no home object leaves the clone's own.
**Refined before delivery** (the second law sweep's away census read 28 records lost on
`r10v180repro/v180_a_share`): the re-bind first ran in drainShareDefParamTs, BEFORE TypeEmit
importCloneBareTdAlias16's design walk (§ cloneBodyBareTdAlias180), whose UhdmListener then followed the clone's
reference into the home body and stripped `quarry_pk::` from seven `ledge_ty` aliases; the re-bind now runs in
drainPaNameCopySrc38, after that walk, and v180_a_share converts. Cases (§ cloneForIncBindsHomeVar238): K/k01, k02,
k03, k06, k11 (`differ:depth -> EQUAL`; the `-elabuhdm` view has no import clone and is unchanged: k01 nested loops,
k02 two header variables, `+=`, `=`-increments, `++r`; k03 a function with output, an external loop variable
(unchanged form); k06 a class method with a `W-1` range loop variable and an in-body method; k11 a task clone,
nested loops, `<<=`, a for inside a foreach), k07 (k11 with a `byte` loop variable: stage 1 at the base on that
`byte_var`, unchanged count), k08 (a parameterized class base, `$unit` import; stage 1 at the base, unchanged count).

### § cloneLoopVarClassPropArrayTs238 (switch `R11U238_CLONEPROPARR_OFF`; StmtEmit, § cloneLoopVarHomeObject183's branch)

MiniAmiq #66872 / SeqDriver #66828, exposed by the previous law. In a class-method clone, `foreach
(m_wildcard_inst_overrides[i])` over the class property `uvm_factory_override m_wildcard_inst_overrides[$]`:
golden's shared clone object `ref_var uvm_pkg::uvm_default_factory::register::i` binds a fresh, EMPTY
`array_typespec` — what the home listing's lateTypedefBinding resolves (§ foreachClassPropArrayVar21:
getSimpleVarFromTypespec mints `array_var` + a fresh array_typespec for a queue, dynamic or fixed array without an
index) — ours kept the unsupported placeholder. **Law**: a class property that is a queue, dynamic or fixed array
gives the shared object a fresh `array_typespec`, under the home listing's own gate (the property's package not
imported at `$unit`, § classPropUnitImport21), for the bare and the `this.` spelling, and always for a dotted
list (§ foreachHierPathAlwaysRes21; `foreach (m_one.v[k])`). Cases (§ cloneLoopVarClassPropArrayTs238): K/k04
(queue, dynamic, fixed and associative properties; `differ:type -> EQUAL` both views), k10 (an inherited property and
a dotted member array; `differ:type -> EQUAL` both views), k05 (in-body methods, a subclass in the importer:
unchanged, EQUAL), k09 (`$unit` import: stage 1 at the base, unchanged bytes), k12 (`this.` spellings around nested
for loops; stage 1 at the base on package `p`, dump-checked: both loop variables' shared objects equal golden's).

## Binaries (frozen before any measurement; every cmds.txt audited by binary path)

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/r11u238_bin/pristine`) | `f5497dc77d1cdf48a3b6702d2e1d2e03` | built at `0a1c70e0` with the system-deps config, identical to the main tree's; reports slang 12.0.0+545f88b2e |
| law (`/tmp/r11u238_bin/law3`) | `a4a9d9c8d90ecf5e6072a48ab625a2a1` | this patch (the worktree rebuilt from the delivered sources writes the same md5) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build of `tools/uhdm-strictcmp` |
| strictcmp_x | `886f030233ecdbcce7d0e29ac0c4df2c` | `drivers/strictcmp_x.cpp` (map 15's variant + a fence check), built by `drivers/cc_x.sh`, for the away census |

`law` and `law2` were the two earlier law binaries; each was superseded by a refinement found by a gate (above) and
its sweep discarded; every number below is `law3`'s. Every `cmds.txt` of the pristine sweep names
`/tmp/r11u238_bin/pristine` only (3273 of 3273), of the law sweep `/tmp/r11u238_bin/law3` only (3273 of 3273).
Development binaries (`dev1`-`dev16`) ran only on cases and filtered UVM / probe subsets, never on a gate.

## Gates (from the worktree, SLANG_UHDM exported, `tests/sweep.sh --jobs 3`)

| stage | pristine sweep (`/tmp/r11u238_wP`) | law sweep (`/tmp/r11u238_wL`) |
|---|---|---|
| probe | EQUAL 3463 + STRICT_NOTEQUAL 624, 0 / 0 / 0 | EQUAL 3476 + 611: **regressions 0, conversions 13, changes 1** |
| surelog | 469 + 11 / 465 + 9, 0 / 0 / 0 | the same counts: **regressions 0, conversions 0, changes 9** (BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, Scoreboard d, SimpleUVM d/t, quoted above) |
| uhdm2rtlil | 802 + 1 per mode, 0 / 0 / 0 | **0 / 0 / 0** |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0 | **803 / 66 / 2 / 0, not excused 0, verdict diff 0** |

Both sweeps print `law index STALE` first (the base's committed `tests/LAWS.md` predates its own commit); the patch
carries the regenerated file and `scripts/law_index.py --check` reads current. uhdm-cmp on every corpus mover reads
0 lines (each mover is STRICT_NOTEQUAL, i.e. stage 1 equal). Canary battery on the law csvs
([evidence/canaries.txt](evidence/canaries.txt)): `canaries.sh` surelog ok=45 changed=7 (the seven changed UVM
row-modes above), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS (ok=58 changed=0),
`EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS (ok=2 changed=0).

## The mover prediction, frozen before the law sweep ([evidence/census/](evidence/census/))

`drivers/census.sh` ran `law3` with `R11U238_TRACE` over both corpora in both modes (`--filter` built from
`$FENCED`) and every probe case, `drivers/dscensus.py` every downstream lane (the harness's translated command line).
`drivers/predict.py` names every database whose process fired a byte-writing branch (the drain's `_nohome` line
writes nothing and is listed apart): **23 predicted movers** (9 surelog row-modes, 14 probe cases, 0 uhdm2rtlil, 0
downstream lanes), frozen at 2026-10-04T20:49:52 (md5 `c227a54e652f68297cd4176c1db42bf6`, `frozen_at.txt`) before
the law sweep started. Firings: cloneForIncBindsHomeVar238 126 (free clones) + 2728 (class clones),
cloneLoopVarClassPropArrayTs238 347, foreachClassPropStringTsShared238 8, foreachFlatLocalRefTs238 12;
`foreachClassPropStringTsShared238_miss` 0.

**byteverify** (`tools/probe/r11v75repro/byteverify.sh` on hard-link mirrors of both sweeps without the fenced
paths, `drivers/bvmirror.sh`; [evidence/movers/byteverify.txt](evidence/movers/byteverify.txt)):
`PATH_SETS_IDENTICAL (2560 paths)`, **MOVERS: 9 / 2560**: BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM
d/t, Scoreboard d — exactly the nine predicted. `SELFCHECK (every file vs one fixed file): 2559 / 2560 flagged` is
the self-check reading correctly, not a movers line: the comparator is run with one side replaced by one fixed file,
and that file compared with itself is the one path it cannot flag. **Probe**: 14 of 4087 databases move, exactly the
14 predicted ([evidence/movers/probe_downstream_movers.txt](evidence/movers/probe_downstream_movers.txt)).
**Downstream lanes**: 0 of 871 lane databases differ between the two sweeps (positive control: two different lanes
compared read as differing).

## Away-moved-record census (map 12's, `drivers/awayrows.py` with strictcmp_x; [evidence/movers/away.txt](evidence/movers/away.txt))

Over the 23 databases that differ between the pristine and the law sweeps: **chain-keyed away 0 and flat away 0 on
every one**, toward 2920 (MiniAmiq 862 per mode, SeqDriver 478 per mode, BuildUVMPkg 3, SimpleUVM 3, Scoreboard 2,
probe 3 to 62 each). The second law binary read away 28 on `r10v180repro/v180_a_share`; that is the refinement of
§ cloneForIncBindsHomeVar238 above.

## Determinism — a finding ([evidence/det_law.txt](evidence/det_law.txt), [evidence/det_pristine.txt](evidence/det_pristine.txt), [evidence/det_seqdriver.txt](evidence/det_seqdriver.txt))

`drivers/det.sh` (three concurrent harness runs on Earlgrey_0_1 and the five UVM rows, both modes): pristine one hash
per row-mode on all 11; law one hash on 10 of 11, **SeqDriver default two hashes** (2 + 1). Measured further on
SeqDriver default: pristine 21 of 21 runs one hash; `law3` 3 of 9 runs the second hash; `R11U238_OFF` 6 of 6 the
pristine bytes; EACH law alone (the other three off) also shows the second hash (1 or 2 of 6 each). The two
databases are order-blind identical (sorted uhdm-dump differs only in its header line) and give the same verdict
(uhdm-cmp rc 0, strict `fullname` on both): two pairs of UNREFERENCED minted variables
(`adpcm_pkg::uvm_phase::sync::visited.exists::succ` and `...unsync...`; `adpcm_pkg::uvm_reg_map::do_print::
{regs,mems,vregs}[j].get_address::this`) swap creation order. Their minting pass, UhdmExporter
`drainCloneArrayRecvArgMint193`, iterates `s.AllObjects()`, a `std::map<const BaseClass*, uint32_t>` keyed by OBJECT
ADDRESS, so their order follows the heap placement of two `hier_path` objects; the pristine allocation sequence
happens to keep them ordered, and any of these laws' changes to the sequence ahead of them exposes the address order,
which is not stable run to run. The pass is ground B (UhdmExporter): the fix is to iterate in UhdmId order (or sort
the hier_paths by id) before minting; not written here. Until then SeqDriver default is an ORDER COIN (gate verdict
unaffected, byteverify would flag it): **the integrator should land the ground-B fix with or before this patch, or
list SeqDriver/default among the known coins**.

## Grid (cases/, 33 cases, both views; `drivers/grid.sh`, `drivers/gridsum.py`; [evidence/grid.txt](evidence/grid.txt), [evidence/grid_summary.md](evidence/grid_summary.md))

528 runs (pristine, law, law with `R11U238_OFF`, the law with each of the five switches; default and `-elabuhdm`
views), **every exit code 0**. `R11U238_OFF` writes the pristine bytes on 66 of 66 case-views; each switch alone
reverts exactly its own law's cases (PROPSTRTS 10, FLATLOCALREFTS 14, CLONEFORINC 7, CLONEFORINCCLS 2, CLONEPROPARR 6
case-views). 36 case-views move bytes; **19 enter STRICT_EQUAL, none leaves**; no uhdm-cmp line count changes on any
stage-1 case (f13 28, f14 1232/1720, f15 304/308, f16 46, f17 56, f20 384/554, f21 122, k07 60, k08 1424/2288,
k09 1084/1440, k12 1548/1610 on both binaries), and the stage-1 cases a law moves were checked against golden with
uhdm-dump on the objects the law writes (f13, f14, f16, f17, f20, f21, k12: every one equal to golden, f16's
typedef'd property abstaining; k07's default view moves through the loops k11 converts, its stage-1 head the
`byte` loop variable; [evidence/decode_dumps.txt](evidence/decode_dumps.txt)). Fresh-case coverage for the
brief's list: interface bodies (f19), class specializations (f13, k08), `this.` paths (f13, k09, k12), extern and
pure virtual prototypes (f05, f16), `$unit` imports (f14, f20, k08, k09), class in a module (f15), task clones (k11),
every for-increment form (k02, k07, k11). Implicit nets and named calls are outside these laws' reach (no law reads
or writes either).

## Sister-ground faces (decode only, call sites)

1. BuildUVMPkg d/t #81218, Scoreboard d #80496, SimpleUVM's next records (#80104): `uvm_driver`'s type-parameter-typed
   properties `REQ req; RSP rsp;`: golden locates the `class_typespec uvm_sequence_item` at the parameter default
   (`REQ=uvm_sequence_item`), ours at the argument of the `uvm_default_driver_type` specialization typedef — the
   class_defn listing's property typespec for a type parameter, the class body writers (UhdmExporter / TypeEmit).
2. MiniAmiq d/t #68597, SeqDriver d/t #68553 / #68565: the body-local associative array `sorted_override_queues
   [string]` in the class-method clone `<importer>::uvm_default_factory::print`: golden's ref_typespecs under the
   local's `array_typespec` carry full names, ours none — the body-local declaration typespec (TaskFuncEmit).
3. The determinism hazard above: UhdmExporter `drainCloneArrayRecvArgMint193`'s address-ordered `s.AllObjects()` walk.
4. `r10uvm180repro/g180_a_kinds` #1067: an import clone's `enum_typespec kx180_home::howlite_et` located at the
   typedef (20:3-64) where golden locates the copy at its use (109:46-56) — a typespec copy's location (TypeEmit).

## Residues, ranked (ground A)

1. **SimpleUVM d/t #75572** (brief item 1, decoded, not written): Surelog `UhdmWriter::lateBinding`
   (UhdmWriter.cpp 3297-4010) mints a module net per unbound reference of `mod->getLateBinding()` and later
   references find it by name, so the net carries the location of the FIRST unbound reference in that list:
   golden's `work@top.m_parent` sits at `uvm_phase.svh 1001:10-18` (`uvm_phase::get_parent`'s `return m_parent;`),
   whose own walked reference is unbound in both databases (the late-binding list holds a copy the walk does not
   list), while ours mints at the first reference our emitter binds (`uvm_component.svh 1925:11-19`); `this`
   (golden 902:36-40, no file) and `m_inst_count` (golden `uvm_object.svh` 845:10-22) the same. A law needs the
   late-binding list's order (class compile order) at ExprEmit's mint; not attempted in this pass.
2. BlackBePipeInt d/t N2471 (brief item 2; unchanged `fullname(73)` / `(75)`; pass 236's decode stands: the
   importing package's re-listed `all_cfgs_gp` element struct needs its own member ref names, ParamEmit
   `makeParamTs` / `drainDefParamTs`), then N0028, N0118, N0873: not attempted.
3. Brief items (3) to (7) (pass 236's and pass 232's residues, the BuildUVMPkg expression/parameter clusters N0033,
   N0025, ..., map 15's ground-A brief, the carried items): not attempted. BuildUVMPkg's first record after these
   laws alone is #81218 on ground B (item 1 of the sister faces), so the decode's ground-A clusters sit behind it.
4. Clone loop variables of other kinds: a `byte` header variable (k07: stage 1 at the base on the `byte_var` itself),
   a foreach loop variable referenced in a clone (golden's shared object is already ours), a for loop whose variable
   is declared outside the header (k03's `int i; for (i = 0; ...)`: unchanged form, golden equal).
5. A typedef'd string property (f16): golden names the loop variable's typedef object `str_t`, ours names the
   property's `p::str_t` (§ foreachClassPropStringTsShared238 abstains; the base's fresh object stands).

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed, compiled helpers included)

`env.sh`, `case.sh` (from r11u236repro), `grid.sh` (the grid; `LAWBIN` overrides the law binary), `gridsum.py` (the
grid table), `census.sh`, `dscensus.py`, `predict.py` (the prediction; `_nohome` lines listed apart), `bvmirror.sh`,
`det.sh`, `uvmdist.sh` (copied, not run: the UVM order-blind distance was not measured in this pass), `awayrows.py`,
`strictcmp_x.cpp` + `cc_x.sh` (map 15's variant comparator with a fence check).

## Process notes

- Every command ran from the worktree `/tmp/wt_r11u238` (base `0a1c70e0`); scratch under `/tmp/r11u238_*`; the main
  checkout was never written. No submodule was initialised in the worktree.
- Every tool reached through a variable was guarded (`[ -x ]` in env.sh / case.sh and before every uhdm-dump call);
  no database was executed.
- Three case files were rewritten after a first run because they were illegal or tripped an unrelated stage-1 face
  (k03 called a task from a function; f13's `void'(a + b)` is a Surelog syntax error; f16 declared a pure virtual
  method in a non-virtual class; k12's property shared package `q`'s name): every grid number is the final files'.
- No process of another agent was listed or signalled; this pass killed nothing.
- Two gate findings made refinements after a full law sweep (the v148_g_corpus regression; the v180_a_share away
  records); each time the census was redone with the new binary, the prediction re-frozen, and the sweep rerun.
