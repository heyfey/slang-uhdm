# r11u271 — pass 271, the module/type ground (refill after pass 269)

Base commit `9cb6fddb` (pass 269). Production surface: `src/TypeEmit.cpp`, `src/UhdmExporter.cpp`,
`src/ModuleEmit.cpp` and the new `src/R271.h`. Nothing under `results/`, `tests/` (apart from the regenerated
`tests/LAWS.md`) or `third_party/` is touched. No file of the sister's ground (ExprEmit, EmitHelpers.h, StmtEmit,
ParamEmit) is edited.

| binary | md5 | what |
|---|---|---|
| pristine | `6712ed7d618895d7c33dcfd915d13981` | built in the worktree at the base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `ae0f712864424d1c4301f8eb5e8f1df7` | the delivered patch, frozen (`chmod 555`) before the firing census and every gate sweep |

Both link slang 12.0.0+545f88b2e.

## Verdict per targeted row (before -> after, on this pass's own pristine and law sweeps)

| row-mode | pristine | law | what moved |
|---|---|---|---|
| SeqDriver default | `differ:depth(1)` head #218195 | `differ:fullname(6)` | the type-parameter use face (#218195 and the `static function T create` return #218260) cleared by § tpUseSharesOwnTs271; the walk runs to the end of the design (objects equal on both sides). ALL SIX remaining records are on the sister's ground (the `inside`-set package-parameter face, below). SeqDriver d/t convert once the sister lands that face. |
| SeqDriver testflags | `differ:depth(1)` head #218207 | `differ:fullname(6)` | the same |
| MiniAmiq default | `differ:endcol(2)` heads #217949 (sister) and #223178 | `differ:endcol(5)` | #223178 cleared (§ tpUseSharesOwnTs271); the count grows because the walk now runs past it: the first record #217949 is unchanged (the sister's `$sformatf` endcol), then three records of the `inside`-set face (#227043 / #227046 / #227049, sister) and the walk divergence #227149 (a cast to an alias enum typedef binding an object whose alias is null, sister; below). Away census 0 lost. |
| MiniAmiq testflags | `differ:endcol(2)` | `differ:endcol(5)` | the same |

No corpus row converts on this base: every record left on the two UVM rows after this pass is on the expression /
parameter ground. Earlgrey_0_1 d/t, BuildUVMPkg d/t, SimpleUVM d/t, Scoreboard d, Rggen d and BlackBePipeInt d/t stay
CMP_EQUAL; BuildUVMPkg, SimpleUVM, Scoreboard and ArrayMethodIterator move bytes only (identity), their strict
columns unchanged.

Composite heads, `uhdm-strictcmp --max 3/8`: `evidence/uvm_heads_pristine.txt` (base) and `evidence/uvm_heads_law.txt`.
At the base (pristine), SeqDriver default:

```
#218195 depth
  A: 4  class_var   uvm_pkg::uvm_component_registry::create_component  uvm_registry.svh 63 20 63 33
  B: 6  class_typespec uvm_component                                    uvm_registry.svh 51 39 51 52
```

Golden lists nothing under `create_component::obj`'s ref_typespec (its actual is the type parameter `T`'s own
`class_typespec uvm_component 51:39`, already listed inside `this_type`'s class_typespec, where the strict walk never
re-expands a class body), ours listed a per-use copy.

## The laws (src/R271.h: each law reads its own `R11U271_<LAW>_OFF`; `R11U271_OFF` drops all and gives pristine's bytes; `R11U271_TRACE=<dir>` logs every firing)

### § tpUseSharesOwnTs271 (TypeEmit `classTpDefaultTsDrain180` + UhdmExporter, right after that drain) — switch `R11U271_TPUSESHARE_OFF`, the formal branch also under `R11U271_TPFORMALSHARE_OFF`

A declaration written with one of its class's own type parameters — a property, a method-body or nested-block local,
a return value (`static function T create`), a queue / array element, a subroutine formal — is typed in golden by the
type parameter's OWN typespec object, not a copy: Surelog's `CompileHelper::compileTypespec`, the
`uhdmtype_parameter` branch (src/DesignCompile/CompileType.cpp), hands back the parameter's typespec itself.
§ classTpDefaultTsAtUse180 gave each use a per-use object carrying the own object's name and span, and
§ typeParamDefersToTpUse186 deferred pass 183's sharing law to it because, at pass 186, sharing made BuildUVMPkg's
bytes a coin. The strict walk canonicalises the per-use copy only while the own object has not been listed inside a
class_typespec (a class body stays visited once): once a specialization listing (`this_type`, `type_id`) has listed the
parameter's object, golden's later references list nothing and ours listed the copy — `differ:depth`. The law redirects,
design-final, every ref_typespec whose actual is one of § 180's use objects (and every formal's object of
§ classTpFormalMovesTs180, after the last formal moved the own object) to the parameter's own object; for a chain member
(`type U = T`) the chain root's object (§ classTpChainRootShares180), the member's own object included. The redirect
walks the ref_typespecs in UhdmId order (the target is order-independent). The per-use objects are left unreferenced.
The keyword-default type parameters (§ classTpKeywordTsAtDefault188's uses) go through the same list.

Determinism (pass 186's concern): with the law, BuildUVMPkg default reads ONE hash in 10 of 10 draws (the sweep, three
concurrent harness draws, six concurrent direct runs), and every other row-mode of the determinism set one hash in
4 of 4 (`evidence/determinism_law.txt`).

### § ndaConstRhsFreshLhs271 (ModuleEmit `emitContAssigns`' net-declaration-assignment home and § caIfaceElabNetDeclAssignListing88's interface home) — switch `R11U271_NDACONSTLHS_OFF`

Surelog's `UhdmWriter::writeCont_assign` clones the net-declaration cell, its Lhs net included, whenever `reduceExpr`
turns the Rhs into a constant (the `simplified == false` branch: `if (res->UhdmType() == uhdmconstant) { if (cloned ==
false) clone_tree(assign) ... }`), whatever produced the constant: a literal, a module parameter, a package parameter
(`pk::PK`, a wildcard-imported `PQ`), an interface parameter, a package or local enum member. It also clones on an
`inside` Rhs (an operation `flattenPatternAssignments` hands back against the net's typespec; `containsOperation` does
not list `Inside`). We cloned on a literal or an operation and on a parameter `substNdaParamRefs` substituted, and
shared the listed net when the constant came from a package parameter or an enum member folded earlier (module home)
or from LAW C's substitution (interface home): golden's walk then lists the cell's Lhs net in full where ours had
listed it already (`differ:depth`). A Rhs that stays a reference (a net, a variable) keeps the shared net (N/n06).

### § ndaImpEnumConstUnlocated271 (ModuleEmit, both homes) — switch `R11U271_NDAIMPENUM_OFF`

An enum member read as a BARE name in a net declaration assignment (`wire w = ED;`, through a wildcard import or
declared in the scope itself) is reduced by `writeCont_assign` to the member's constant, UNLOCATED (no file, 0:0) and
parented at the cloned cell, where the qualified `pk::ED` keeps the name's span. The interface home located it at the
name (`differ:file`, r11v88repro v28, N/n01, n15); the module home kept the `ref_obj ED` (uhdm-cmp stage 1, N/n02, n17).

## Grid (`cases/`, 49 dirs, both views; drivers/grid.sh, every line with its exit code: `evidence/grid.txt`, `evidence/grid_summary.txt`)

Configurations: P (pristine), L (law), OFF (law + `R11U271_OFF`), and the law with each switch off.
98 case-views, 686 lines: `R11U271_OFF` gives pristine's bytes on 98 of 98; 76 case-views move; 63 enter
STRICT_EQUAL; none leaves; no exit code changes; no uhdm-cmp line count changes; 70 movers are moved by exactly one
switch (`R11U271_TPUSESHARE_OFF` 52, `R11U271_NDACONSTLHS_OFF` 14, `R11U271_NDAIMPENUM_OFF` 4) and the other 6
(N/n01, n15, n16 in both views: a bare enum member in an INTERFACE net declaration) carry both nda shapes, each
switch alone leaving a third md5 (the Lhs clone and the unlocated constant are two separate records). Away census (drivers/awaychain.py, chain-keyed and flat): 0 lost on all 76 movers
(`evidence/away_grid_movers.txt`). Downstream (drivers/dscases.py) on all 49 dirs: 47 IDENTICAL and 2 SLANG_REJECT
(t10, t16: the class-only cases in the `-DSYNTHESIS` lane) on both binaries, the same verdicts
(`evidence/downstream_cases.txt`).

| cases | law | shape | pristine -> law |
|---|---|---|---|
| T/t01_prop, t03_ret, t04_static_ret, t05_prop_queue, t07_nested_local, t02_local | § tpUseSharesOwnTs271 | property, return, static return, queue element, nested-block local, method local, each behind a specialization `typedef reg_c #(sbase, "sbase") type_id` in another package | depth -> STRICT_EQUAL (both views) |
| T/t08_formal_and_local, t17_extern_formal, t18_two_formals, t21_task_output | § tpUseSharesOwnTs271 | formals (`R11U271_TPFORMALSHARE_OFF` leaves the formal branch out: a third md5, depth) | depth -> STRICT_EQUAL |
| T/t09_chain_local | § tpUseSharesOwnTs271 | `type U = T` chain, local written `U` | depth -> STRICT_EQUAL |
| T/t13_all_sites, t14_qual_default, t15_no_spec, t16_two_specs, t19_macro_body, t20_included_header, t23_nested_class, t25_pure_virtual, t26_static_prop, t27_queue_push, t28_module_decl, t29_uvm_registry | § tpUseSharesOwnTs271 | every site at once, `type T = up::comp`, no specialization, two specializations, members written inside a macro body, the class in an included header, a nested class, a virtual class with a pure prototype, static property + getter, the `uvm_queue` shape, a module-level specialization, the UVM registry (`this_type`, `me`, `create_component`, `create`) | depth -> STRICT_EQUAL |
| T/t11_kw_local, t12_kw_prop | § tpUseSharesOwnTs271 | keyword default `type T = int`: bytes move, the first record is pass 269's residue 3 (the base type_parameter's span, `file`) | file -> file |
| T/t24_param_class_default | § tpUseSharesOwnTs271 | `type T = holder#(int)` | stage 1 / name, unchanged verdicts |
| T/t06_local_array, t10_extern_local | § tpUseSharesOwnTs271 | NEGATIVE: a method-local array (ours writes its element as a logic_typespec, residue) and an out-of-body local (golden: no type parameter in scope) | no move |
| N/n03_iface_qual_enum, n05_mod_pkg_param, n07_iface_inside, n08_mod_inside, n09_iface_import_param, n10_mod_import_param, n12_mod_two_inst_enum | § ndaConstRhsFreshLhs271 | `pk::ED` in an interface, `pk::PQ` in a module, `inside` in both homes, imported parameters, two instances | depth -> STRICT_EQUAL (n08 default view keeps a definition-view depth face) |
| N/n04_mod_param, n06_mod_net_ref, n11_mod_sysfunc, n13_gen_enum, n14_struct_net_param | § ndaConstRhsFreshLhs271 | CONTROLS: a substituted module parameter (already fresh), a net reference (stays shared), `$clog2` / `$bits`, a generate-block net, a struct parameter (stage 1 on both) | no move |
| N/n01_iface_import_enum, n02_mod_import_enum, n15_iface_local_enum_bare, n16_iface_import_enum_named, n17_mod_local_enum_bare | § ndaImpEnumConstUnlocated271 | bare enum members (wildcard import, local, named import) in both homes | file / stage 1 -> STRICT_EQUAL; n16 stays stage 1 (the named-import listing, residue) |
| R/r01_cast_alias_iface, r02_inside_pkgparam_class, r03_eq_pkgparam_class, r04_inside_pkgparam_module | § tpUseSharesOwnTs271 | the SISTER-GROUND faces the law's walk reaches on MiniAmiq / SeqDriver, reproduced (no move: decode only, below) | depth / fullname / STRICT_EQUAL (r03 control) / fullname, unchanged |

## Byte controls (drivers/controls.sh: `evidence/controls.txt`, `evidence/controls_movers.txt`)

23 earlier repro dirs (pass 118's and pass 119's grids r11u118repro / r11v11u118repro / r11u119repro, r11u120repro,
r11v120repro, r11u124repro, r11v124repro, r11u131repro, r11v131repro, and the grids of the laws this pass composes
with: r11u180repro, r11u183dec, r11u186repro, r11u188repro, v11u188repro, r11u247repro, r11u269repro, v11u269repro,
r11u88repro, r11v88repro, r11u267repro, v11u267repro, r11u265repro, v11u265repro), path lists filtered by `$FENCED`
before any case is opened: 1629 dirs, 3258 case-views. 254 move bytes, all in the type-parameter grids
(r11u180, r11u183dec, r11u186, r11u188, v11u188, r11u247, r11u269 U, v11u269 VU) and r11v88 v15 / v23; 4 enter
STRICT_EQUAL (r11u269repro U/u01_class_actual — pass 269's residue 1, the type-parameter use — and v11u269repro
VU/vu09_iface_class_clone — pass 269's residue "vu09 a U = T default now the first record" — both views); none
leaves; no exit code changes; no uhdm-cmp line count changes; on the 50 other movers whose verdict is not
STRICT_EQUAL the strict fields line (first field, per-field counts, objects) is identical on both binaries. Away
census: 0 lost on all 254 (`evidence/away_control_movers.txt`).

## Gates (this pass's own sweeps, `tests/sweep.sh --jobs 3`, workdirs of equal length)

| stage | pristine | law |
|---|---|---|
| probe | EQUAL 3593 + STRICT_NOTEQUAL 494, regressions 0 | EQUAL 3604 + STRICT_NOTEQUAL 483, **regressions 0, conversions 11, changes 2** |
| surelog | 476 + 4 / 470 + 4, regressions 0 changes 0 | the same counts, **regressions 0, conversions 0, changes 4** (MiniAmiq d/t endcol(2) -> endcol(5), SeqDriver d/t depth(1) -> fullname(6)) |
| uhdm2rtlil | 1606 + 0, regressions 0 | 1606 + 0, regressions 0, changes 0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same, csv identical to pristine's |

Both sweeps exit 1 on the law-index staleness check alone (the case files predate the regenerated index the patch
carries). Probe conversions (all `§ ndaConstRhsFreshLhs271`, v28 also `§ ndaImpEnumConstUnlocated271`):
r11u88repro/grid/a3_ndassign, q1_ifnda, q2_ndakinds, q7_ndamod, r11v88repro/grid/v1_pkgshadow, v20_ndahier,
v25_enumshadowmod, v26_pkgvecshadow, v28_ndaimport, v2_enumshadow, r11v96repro/v6_modhome96v (all `depth(1) -> EQUAL`).
Probe changes: r10uvm99repro/g99_a2_proc `depth(1) -> count(0)` (§ ndaConstRhsFreshLhs271's `inside` branch: the old
head #232 `logic_net wire99` is cleared, every record now equal, and the walk ends on one trailing `logic_net flg99`
under the `assign flg99 = ...` ref_obj that pristine lists too — 242 vs 243 objects; away 0 lost) and
r11u88repro/grid/q12_ndaparamenc `endcol(2) -> endcol(1)` (one of its two endcol records was the Lhs net; the other,
`-3`'s constant span 8:31-8:32 against ours 8:33, is ParamEmit's).

- byteverify (fence-filtered hard-link mirrors, SELFCHECK=1): 2560 databases, PATH_SETS_IDENTICAL, SELFCHECK 2559 /
  2560 flagged, **11 movers**: ArrayMethodIterator, BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM in both modes and
  Scoreboard default (`evidence/byteverify_corpus.txt`); probe 133 of 4087 databases move (positive control 4087 of
  4087); downstream slang lane 0 of 805 (positive control 805 of 805).
- The firing census (drivers/tracecensus.sh, frozen BEFORE the law sweep: `evidence/predict.txt`, 144 lines, md5 in
  `evidence/predict.md5`) named exactly these 11 corpus and 133 probe movers, line for line, and no uhdm2rtlil
  database. The trace fires on every redirect of § tpUseSharesOwnTs271 and on every firing of the two nda laws that
  changes the cell (a Rhs already fresh by the old rule is not traced).
- uhdm-cmp: 0 lines on all 11 corpus movers (`evidence/uhdmcmp_corpus_movers.txt`).
- Away census, chain-keyed and flat: 0 lost on the 11 corpus movers, the 133 probe movers, the 76 grid movers and the
  254 control movers.
- R11U271_OFF on the 11 corpus movers: pristine's bytes, 11 of 11.
- Canaries: surelog ok=50 changed=2 (SeqDriver d/t), uhdm2rtlil ok=16; ctcan2 PASS on both
  (`evidence/canaries_audit.txt`).
- Binary-path audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, the other 50 carry no slang line.
- Determinism: three concurrent harness draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen: one hash each, equal to the sweep's; six more concurrent BuildUVMPkg runs: one hash.

## Residues, ranked

1. **The UVM rows' remaining records, all on the SISTER ground** (report only; nothing written there):
   - SeqDriver d/t, all six records, and MiniAmiq d/t #227043 / #227046 / #227049: a package parameter folded as an
     `inside` set member (`if (what__ inside {UVM_CHECK_FIELDS, UVM_END_FUNCS, UVM_START_FUNCS})` in the
     `__m_uvm_field_automation` macro body). Golden parents the folded constant at the parameter's `param_assign` and
     its ref_typespec's full name is the enclosing design unit (`adpcm_pkg::adpcm_seq_item`, `work@top`), ours the
     subroutine (`...::__m_uvm_field_automation`, `work@top.auto`). A `==` operand already agrees (R/r03). Reproduced
     by R/r02 (class method) and R/r04 (module function), `differ:fullname`. Writer: ExprEmit `emitExpr`'s
     package-parameter fold under the `inside` operation (gdb on R/r04: the two ref_typespecs minted in
     `emitExpr < emitExpr < emitStmt`). Once that face lands, SeqDriver d/t read 0 records on this base.
   - MiniAmiq #217949: `$sformatf(...)` ending with a macro argument, golden 434:75, ours 434:85 (ExprEmit; pass 269's
     decode).
   - MiniAmiq #227149, the walk divergence: `uvm_severity_type'(severity)` in svaunit_reporter's `compose_message`
     (`typedef uvm_severity uvm_severity_type;`) binds an `enum_typespec uvm_pkg::uvm_severity_type` whose
     Typedef_alias ref_typespec has NO actual, where golden's one listing object aliases `uvm_severity`. Ours holds two
     `uvm_severity_type` objects (the def-pass alias clone the cast binds, alias null, and the listing's, alias set).
     Reproduced by R/r01 (`differ:depth`). The null alias is minted by ParamEmit `emitPackage`'s enum-alias branch
     (`typedefTs[&ta] = ets` in the def pass; the TOP pass binds the alias of the object it finds in `typedefTs`,
     which by then is not the cast's), and the cast binding is ExprEmit's; identity traces in `evidence/sister_decode.txt`.
2. § ndaConstRhsFreshLhs271's neighbours: N/n08's definition view (an `inside` operand's `ref_obj p` actual, depth),
   g99_a2's trailing `logic_net flg99` under a written `assign`'s Lhs ref_obj (present on pristine), N/n16 (a NAMED
   import `import pk::ED;`: the import listing, uhdm-cmp stage 1 on both), N/n14 (a struct-parameter net, stage 1 on
   both), q12's `-3` span (ParamEmit).
3. The localparam / parameter `type` struct with an array variable (`localparam type my_t = struct packed {...}; my_t
   [2:0] arr;`, probe r11u112repro k03 / k12 / k14 / k16 / k17 and five more of the map's
   structMemberWrittenQueueArrayTs149 bucket, `differ:fullname`): DECODED, not written. Surelog's
   `NetlistElaboration::elabSignal` (the `DummyType` branch: a net whose declared type is a type parameter) sets the
   parameter's struct typespec's PARENT to the element struct_net (`spec->VpiParent(stv)`; for packed dims the
   struct_net under the packed_array_net), so the ONE object's member ref_typespecs read `work@top.arr.arr.a`; the
   last such net wins (two arrays: `y.y.a`), and a written `assign s = ...` to a SCALAR net of the type resets the
   parent to null (`writeCont_assign`'s `tps->VpiParent(nullptr)`), which is why `my_t s` reads `a`. Ours keeps the
   type parameter's struct unparented and its member refs' stored full name bare `a`. Eight fresh cases measured on
   pristine (scratch only).
4. T/t06_local_array: a method-local array written `T a[2]` gets a logic_typespec element in ours (golden the
   parameter's class object); T/t11 / t12 / t24: pass 269's residue 3 (the base type_parameter span) and the
   parameterized-class default.
5. Items (2) to (7) of the brief beyond the two UVM rows and the r11u88 bucket: not attempted (pass 269's U/u04 / u05 /
   u06, the package listing order, pass 267's and 265's residues, pass 260's typedefParentModel134 cast copy).

## Probe residue by writer (494 STRICT_NOTEQUAL at the base, joined with tools/probe/r11u230map/probe_fail_list.csv's ground column)

Ground A (ExprEmit / ParamEmit / StmtEmit, the sister's) 271, ground B (this ground) 223. Ground B's largest buckets by
first writer: ModuleEmit § caIfaceElabNetDeclAssignListing88 14 (11 converted here), TypeEmit
§ structMemberWrittenQueueArrayTs149 12 (residue 3 above), TypeEmit § suSigningNotInSpan130 11, ModuleEmit
deferredPortUnpackedArrayTs 8, TaskFuncEmit § blockLocalTdDeclIsRefVarUnsupported155 7, TypeEmit
§ classSpecExprArgUnlocated202 6, § tfSigningSpanFollowsCompilePath200 6, modStructMemberPkgFold 6.
After this pass: 483 STRICT_NOTEQUAL.

## Process notes

- The fence: every corpus path list was filtered by `$FENCED` (word boundary) before anything was opened; byteverify
  ran on fence-filtered hard-link mirrors (8 fenced row-mode databases left out); the census used the fence filter;
  gdb and idobj ran on this pass's own cases and on the non-fenced MiniAmiq / SeqDriver databases only. No process
  signalled.
- A case generator re-run part-way through overwrote seven T cases' hand edits (the statement after a local, t10's
  out-of-body definition, t16's second specialization); caught on the grid (rc 4 / SLANG_FAIL lines), the edits were
  re-applied and those dirs' grid lines rerun and joined; the delivered grid holds only the final files.
- drivers: copied from r11u269repro (grid.sh switch list, gridsum271.py new, idobj.cpp prints par / tgt / alias by
  UhdmId and the typespec alias).
