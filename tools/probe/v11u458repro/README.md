# v11u458 — adversarial verification of r11u458

Pass 458, the module/type ground, base 2f99dba8f. The implementer's patch is
/tmp/r11u458.patch (md5 b3487ea4feb0984479c992009c48970b). It changes
`src/UhdmExporter.cpp` and `src/TaskFuncEmit.cpp` and adds
tools/probe/r11u458repro.

**Verdict: CONFIRMED, no break, no production change.** The verified patch is
the implementer's patch plus this directory and the regenerated
`tests/LAWS.md`.

## Binaries (frozen before any measurement)

| binary | path | md5 |
|---|---|---|
| pristine | /tmp/v11u458_bin/pristine/slang-uhdm (the main tree's build/slang-uhdm at 2f99dba8f) | d0dfe22c35b7dc0c5d3ab323a4e7a34d |
| law | /tmp/v11u458_bin/law/slang-uhdm (built once in /tmp/wt_v11u458 with -j 2) | 2bc868e0bde5fcc16f311b8b0d5cd30c, equal to the implementer's law7 |

The law binary reports slang 12.0.0+545f88b2e and UHDM 1.87.

No-header audit: the added source lines hold no getenv, no src/R*.h and no
reader function. Every law reads its switch through lawOn(458, ...) and logs
through lawTrace(458, ...).

## The targeted row

generated/uvm-examples/uvm_ef_vif_config_db.sv:

| reading | result |
|---|---|
| control (the master's /tmp/intr11u456) | STRICT_NOTEQUAL differ:fullname(427) |
| law binary, sweep | `generated/uvm-examples/uvm_ef_vif_config_db.sv,EQUAL,,equal` |
| three concurrent draws | one hash in 3 of 3, uhdm-cmp 0 lines, STRICT_EQUAL 840299 objects |

Switch split, from the runner rerun with each switch set
(`evidence/efv_switches.txt`):

| switch | result |
|---|---|
| `R11U458_MEMBALIASNAME_OFF=1` | differ:fullname(371) |
| `R11U458_SUBRCOPYNAME_OFF=1` | differ:fullname(56) |
| `R11U458_OFF=1` | differ:fullname(427) |

So the conversion is § memberAliasFollowsMemberName458 (371 objects) together
with § subrAggCopyNamesByChain458 (56 objects), as the implementer decoded it.
The decode of the module write order was checked against the Surelog source:
`ModuleNameModuleDefinitionMap` is a `std::map` keyed by name in
include/Surelog/Common/Containers.h, and UhdmWriter walks it.

## The gate (one full five-stage sweep on the law binary, workdir /tmp/v11u458sw1)

The sweep was launched after three quiet readings, once the sister r11u459's
sweep had ended. The four corpus stages ran from the worktree. The sv-tests
stage ran through the main tree's tests/sweep.sh, because the worktree's UVM
submodule is empty. That stage exits 1 only because the main tree's law index
is stale.

| stage | result |
|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0; csv identical to the control |
| surelog | 480 + 474 CMP_EQUAL, 0/0/0; csv identical to the control |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0; csv identical to the control |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0; csv identical to the control |
| sv-tests | EQUAL 1928, DIFFERENT 12, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346 |

The sv-tests stage reads regressions 0, conversions 1, changes 0. Its csv
differs from the control only in the converted row.

Byteverify against the control (SELFCHECK=1, `evidence/byteverify.txt`):

* surelog: 4 of 962 move, MiniAmiq default and testflags, SeqDriver default
  and testflags. These are the implementer's predicted movers with the
  implementer's hashes, and all four stay CMP_EQUAL with strict equal.
  * The move is toward golden: the full name
    `svaunit_pkg::uvm_reg_map::do_bus_write::accesses::uvm_pkg::uvm_reg_bus_op::data::uvm_reg_data_t`
    occurs 8 times in golden, 2 times on pristine and 8 times on law.
  * SeqDriver testflags' sweep hash moves to d06eaeb7d1c2, so the master must
    re-record it at landing.
* uhdm2rtlil: 0 of 1608 move.
* downstream: 0 of 805 move.
* self-checks: 961/962, 1607/1608 and 804/805.

Probe databases, compared by path-normalized uhdm-dump (`evidence/probe_movers.txt`):

* 1 of 4087 moves, r10uvm180repro/g180_a_kinds, the implementer's prediction.
  It stays EQUAL.
* The move is toward golden: the name
  `kx180_clone::howlite_fn::keel::kx180_home::howlite_et` occurs 12 times in
  golden, 0 on pristine and 6 on law.
* Positive control: the first, un-normalized pass flagged all 4087 databases
  on their tree path.

Trace: the sweep logged firings in 27 databases (4 surelog, 1 probe, 22
sv-tests rows: rsd and 21 uvm-examples rows).

| law | firings |
|---|---|
| § memberAliasFollowsMemberName458 | 15 |
| § subrAggCopyNamesByChain458 | 4681 |
| § cloneDeclOnlyTwinOwnObject458 | 0 |

Other checks:

* Canaries: ok=52 changed=0 and ok=16 changed=0; both ctcan2 checks PASS.
* Binary audit (fence-filtered): surelog 1523 of 1573 cmds.txt name the law
  binary, and the other 50 hold only a Surelog line (two of them mention the
  repository path only through uvm_pkg.sv). uhdm2rtlil 1740 of 1740 and
  sv-tests 2346 of 2346 name the law binary.
* Determinism (`evidence/determinism.txt`): SeqDriver testflags and MiniAmiq
  default each read one hash in 4 of 4 (the sweep plus three concurrent
  draws).

## The implementer's grid, reproduced

All 27 case dirs reproduce on exit code, uhdm-cmp count and strict verdict
(`evidence/implementer_grid_*.txt`). The tally matches the implementer's:

* 16 go to STRICT_EQUAL.
* ma09 is STRICT_EQUAL on both binaries and its bytes move.
* 6 are byte-identical controls.
* 4 stay at their pristine heads: mb02 (uhdm-cmp 1580 -> 1602 lines, same
  head), mb09, lt02 and lt06.

## Attack grid (43 fresh case dirs under cases/, `evidence/grid_*.txt`)

Every case is accepted by upstream slang (`slang --single-unit`). VB/vb09 was
first written with $unit types read inside a package, which slang rejects, and
was rewritten in place as a module function. Every exit code is 0 on both
binaries. `R11U458_OFF=1` gives pristine's bytes on all 43. Each moving case's
single-law switches are in `evidence/switches.txt`.

### VA — § memberAliasFollowsMemberName458 (12 cases)

* To STRICT_EQUAL from STRICT_NOTEQUAL fullname:
  * va01: module names b_top, a_top in reverse of name order.
  * va06: generate-block variable.
  * va08: three modules mm, zz, aa and two structs.
* Byte-identical controls:
  * va02: $unit typedefs.
  * va03: alias from another package.
  * va05: interface and module.
  * va07: unpacked-array member.
  * va09: package variable and class property.
  * va10: one top over two children.
  * va12: unpacked union.
* Bytes move with the uhdm-cmp head unchanged:
  * va04: typedef of a typedef member, head the member alias ref (a_t), 17 lines.
  * va11: enum with a typedef base, head enum_const R, 36 lines.

### VB — § subrAggCopyNamesByChain458 and its stray-copy branch (19 cases)

* To STRICT_EQUAL:
  * vb01: module function with struct formal and return, from fullname.
  * vb08: nested packed struct in a queue local of an importer copy, from
    fullname. Every renamed name occurs as often as in golden (20, 8, 40, 16
    and so on).
  * vb19: package struct queue in a child module's task, from fullname.
* vb10 moves closer: module task with dynamic, associative and fixed arrays
  of a struct. It was fullname(8) plus one type divergence; the 8 fullnames
  clear and the type divergence stays (the struct_var element golden lists
  beside the array_var; implementer residue 3).
* vb11 stays at fullname(51): a class declared inside a module, where golden
  names work@hvl_top::K::... (not reached).
* Bytes move with the uhdm-cmp head unchanged, every renamed name counted
  toward golden:
  * vb04: output and ref formals in a package with an importer, 656 lines.
  * vb05: named-begin and fork locals in a class task.
  * vb07: generate-block function.
  * vb12: export p::* chain, every renamed name equal to golden's count.
  * vb13: union queue local, renamed names 12 where golden has 16 and pristine 8.
  * vb15: module-local struct shadowing the package's.
* Byte-identical controls:
  * vb02: interface task.
  * vb03: program task.
  * vb06: module-local typedef with two instances.
  * vb09: $unit types in a module function.
  * vb14: task-local typedef.
  * vb16: interface-local typedef with two instances (stray-copy control).
  * vb17: program-local typedef (stray-copy control).
  * vb18: generate-block typedef (stray-copy control).
* No stray copy fired on a struct that a module, interface or program listing
  holds.

### VT — § cloneDeclOnlyTwinOwnObject458 (12 cases)

* To STRICT_EQUAL from depth or type:
  * vt02: free package task.
  * vt04: non-void function with a logic local.
  * vt06: two importer packages.
  * vt07: typedef local.
  * vt08: static local.
  * vt12: three declarators and a two-level import chain.
* vt03 (struct local): uhdm-cmp 360 -> 382 lines at the same head, the
  package struct's parent. The added lines are the twin variable now expanded
  as its own object, as in golden's dump: golden lists two distinct struct_var
  objects with their own ref_typespec.
* vt05 (initialized local) and vt10 (fixed-array local): bytes move toward
  golden's twin, with the head unchanged.
* Byte-identical controls:
  * vt01: in-body class function.
  * vt11: explicit import p::C, where no copy is made.
* vt09 unchanged at STRICT_NOTEQUAL depth. Golden repeats `a` for
  `function void f(); int a; int b;` (two items), which § 412v's twin does not
  produce: not reached, the same on pristine.

### Downstream

Downstream verdicts (`evidence/downstream_cases.txt`): 7 sampled cases
IDENTICAL on both binaries, and vb10 EQUIVALENT on both.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The five open uvm-examples rows at their pristine heads, as the
   implementer reports them: id_register, many_to_one and param_vif_config_db
   on this ground; ac_config_db and pipelined_get_put on the sister's.
2. A struct member's per-member typedef alias for a MODULE-local or
   INTERFACE-local struct typedef: uhdm-cmp head
   `ref_typespec (work@sub.op_s.addr.a_t)` on VB/vb06 (two instances) and
   `(work@bus_if.op_s.addr.a_t)` on VB/vb16. Law A covers only the package
   shape. This is the next face of the law's family, on this ground.
3. A typedef-of-typedef member alias (VA/va04) and an enum with a typedef base
   (VA/va11, head at enum_const R).
4. A class declared inside a module: subroutine aggregates named
   `work@hvl_top::K::...` in golden (VB/vb11, fullname(51)).
5. The two-item declaration-only function `int a; int b;`, where golden
   repeats the first variable (VT/vt09; § fnDeclOnlyFirstTwice412v's shape is
   not reached).
6. The struct_var element of dynamic and associative struct arrays in
   subroutines (VB/vb10, implementer residue 3), and the union faces
   (VB/vb13; LT/lt02 and lt06 on the sister's ParamEmit packed-union
   vpiInstance).
7. MB/mb02 and mb09 (package p against ap), MA/ma06, VA/va05 (interface
   instance listing), VA/va09 (module class-handle listing), VB/vb02 and vb03
   (interface and program heads), VB/vb14 (task-local typedef begin listing),
   VB/vb18 (generate-scope listing), VT/vt05 (initializer assignment) and
   VT/vt10 (fixed-array local): each is at a pre-existing head.

## Sister-ground faces

The implementer reported two; this verifier found no new one:

* ParamEmit's packed-union member vpiInstance.
* `return q.size()` in an importer copy.

## Process

* Within the budget:
  * No pristine build: the main tree's binary was frozen as pristine.
  * One law build.
  * One full five-stage sweep.
  * No verified build, since nothing changed.
* Extra runs: one single-row runner call per switch on the targeted row, and
  three concurrent draws each on three rows.
* Every build, grid and runner call waited until the sister r11u459's sweep
  had ended, after three quiet readings.
* The fence list was read into a file by a program and never printed. Every
  tree-wide list (the cmds.txt audit) was filtered on it first. No fenced test
  was named, opened or run.
* No other agent's process was touched.
