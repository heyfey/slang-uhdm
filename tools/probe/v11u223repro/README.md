# v11u223: adversarial verification of r11u223 (pass 223, the module/type ground)

**Base** `896ec643` (branch matrix-1.87). **Verdict: CONFIRMED WITH TWO REFINEMENTS.** Every headline number of
tools/probe/r11u223repro/README.md reproduces bit for bit with binaries built here. Fresh cases found two faults
where the base was right, and both are fixed here behind their own switches:

1. **§ unsizedInnerSizeDeclines223 does not decline. It invents a value.** ExprEval::size never sizes the placeholder
   element. It sizes the placeholder's typespec, and the placeholder has none, so it adds 0 bits without setting
   invalidValue. The adjuster then writes `UINT:0` in place of `$size` of `int md [4][]`, where the dimension's
   size is 4. § ndaAdjSizeFoldSized223 then sizes it and strips its location. The fix is
   **§ sizeDeclineTsInvalid223v** (`R11V223_SIZEINVALID_OFF`).
2. **tfArgScalarTdWriter223's registry turns two byte-deterministic row-modes into coins.** The coins are MiniAmiq
   (default 9 : 10 over 19 concurrent draws, testflags 17 : 2) and SimpleUVM default (three hashes over 19 draws).
   The base binary drew one hash in 38 of 38 draws on MiniAmiq and 19 of 19 on SimpleUVM default. The law binary
   under `R11U223_OFF` drew the base's hash in 16 of 16 on MiniAmiq. The dumps are identical; only the tail of the
   symbol table is reordered. The fix is **§ formalRegNoHeap223v** (`R11V223_DETREG_OFF`). It gives one hash in 32
   of 32 draws on MiniAmiq and 19 of 19 on SimpleUVM default, and the symbol table equals the base's string for
   string.

`R11V223_OFF` drops both refinements, and `R11U223_OFF` still restores the base's bytes on every case-view. The
final binary reads the same verdicts as the law binary in every gate stage.

Law names are written `§ name`, a probe case is called a case, and the four slang-fenced tests are never named
here. Every driver reads the fenced names from the `FENCED=` line of tools/probe/r11u107repro/canaudit.sh and fails
closed.

## 0. Verdicts per target (base -> law -> final binary)

| target | base `896ec643` | r11u223 (`law`) | this verification (`fix2`) |
|---|---|---|---|
| MiniAmiq d/t | `differ:file(7)` | `differ:line(2)` | `differ:line(2)` |
| SeqDriver d/t | `differ:file(7)` | `differ:line(2)` | `differ:line(2)` |
| SimpleUVM d/t | `differ:file(56)` | `differ:file(42)` | `differ:file(42)` |
| Scoreboard d | `differ:file(32)` | `differ:file(18)` | `differ:file(18)` |
| BuildUVMPkg d/t | `differ:line(31)` | `differ:line(31)`, 406 records toward golden per mode | same |
| order-blind distance (MiniAmiq / SeqDriver / SimpleUVM / Scoreboard) | 5941 / 4598 / 1544 / 1105 | 5238 / 3779 / 934 / 601 | 5238 / 3779 / 934 / 601 |
| probe | 3432 + 655 | 3436 + 651: 4 conversions, 2 changes | same |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, 0 of 805 slang lanes move | same |
| elaborated `$size` of `int md [4][]`, `mq [2][$]`, `m7 [2][][int]` | rc 139 | rc 0, **the invented constant `UINT:0` sized to the net** | rc 0, **the call stays** |
| MiniAmiq d/t, SimpleUVM d bytes | one hash (38/38, 19/19) | **coins** (MiniAmiq d 9:10, t 17:2; SimpleUVM d 9:9:1) | one hash (32/32, 19/19) |

No corpus row-mode converts, under either binary.

## 1. Binaries and sweeps

| binary | md5 | what |
|---|---|---|
| `pristine` | `b47000e7909cadf602db20c266431038` | `/tmp/wt_v11u223pris` at `896ec643`, system-deps config, `-j 1`; equal to the main tree's `build/slang-uhdm` |
| `law` | `2a3d1e1b815930691a1fd6a5d83c660d` | `896ec643` + `/tmp/r11u223.patch` (md5 `17a32599…`, applied clean), `-j 1`; equal to the implementer's `law_d5` |
| `fix` | `b65d671021a1900619bff77f658ba52a` | law + § sizeDeclineTsInvalid223v only (grid use only) |
| **`fix2`** | **`f27e266d029bfa4466716df930afb08d`** | **law + both refinements = the verified patch**; a rebuild after the last (comment-only) source edit reproduces it byte for byte |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build, identical to both worktrees' builds |

All binaries were frozen (`chmod 555`, `/tmp/v11u223_bin`) before any measurement.

Gate sweeps (`tests/sweep.sh --jobs 3`, 15-character workdirs):

* `/tmp/v11u223_wP`: `pristine`, run from the pristine worktree.
* `/tmp/v11u223_wL`: `law`, run from the verification worktree.
* `/tmp/v11u223_wF`: `fix2`, run from the verification worktree.
* `/tmp/v11u223_wQ`: the probe stage only, with `pristine`, run from the verification worktree. A probe database
  embeds its case's source path, so a byte comparison needs both sweeps run from the same checkout.

Every sweep's `slang:` lines name only its own binary: 3273 of 3273 each in wP, wL and wF. Every EXIT=1 is the law
index staleness alone. The main tree at `896ec643` also reads stale, and this patch carries the regenerated file.

## 2. Reproduction of the implementer's numbers

| claim (r11u223 README) | measured here | evidence |
|---|---|---|
| `law_d5` md5 `2a3d1e1b…` | `2a3d1e1b…`, rebuilt from the patch | section 1 |
| probe 0 / 4 / 2, EQUAL 3436 / STRICT_NOTEQUAL 651 | **same**. Conversions: g125_b_shapes, g125_d_homes, t47a, t47b. Changes: t48a `line(10) -> name(2)` and t48c `line(8) -> fullname(3)`, both strict subsets of the base's fields | [gates/sweep_wL.log](evidence/gates/sweep_wL.log) |
| surelog 0 / 0 / 7; uhdm2rtlil 0 / 0 / 0 | **same**, the seven rows of section 0 | same |
| downstream 803 / 66 / 2 / 0, 0 of 805 slang lanes move | **same**: 805 slang-lane databases byte-identical to pristine | [gates/sweep_wL.log](evidence/gates/sweep_wL.log) |
| census: 25 databases, 4712 firings, all tfArgScalarTdWriter223 | **same**: the census re-run with `R11U223_TRACE` over every non-fenced row-mode (both corpora and modes, `--filter` from `$FENCED`), every probe case and every downstream lane. MiniAmiq d/t 650, SeqDriver d/t 650, BuildUVMPkg d/t 406, SimpleUVM d/t 398, Scoreboard d 398, 16 probe cases. No firing of any other law, and none downstream | [census/prediction_frozen.txt](evidence/census/prediction_frozen.txt) (md5 `375725b8…`, frozen before the law sweep) |
| byte movers 9 corpus + 16 probe = the prediction | **same**: byteverify on fence-safe mirrors, PATH_SETS_IDENTICAL 2560, MOVERS 9, SELFCHECK 2559 / 2560 flagged; probe 16 of 4087; name lists equal to the frozen prediction | [gates/byteverify_law_vs_pristine.txt](evidence/gates/byteverify_law_vs_pristine.txt) |
| away census: chain 0 lost / 5942 toward; flat 234 lost, all paired in place; reversed control 5942 lost | **same**: `chain_lost=0 chain_toward=5942 flat_lost=234 flat_unpaired=0`; reversed `chain_lost=5942` | [away_law_vs_pristine.txt](evidence/away_law_vs_pristine.txt), [_reversed](evidence/away_law_vs_pristine_reversed.txt) |
| UVM heads with the law: `UVM_SEQ_ARB_TYPE` 1381:51 (golden 332:40), `this_type` | **same** records #24915 / #24898 / #26887 / #26895 / #26855 | section 7 |
| order-blind distances 5941→5238, 4598→3779, 1544→934, 1105→601 | **same** | [uvmdist.txt](evidence/uvmdist.txt) |
| canaries ok=47 changed=5 (law csv vs pristine csv); ctcan2 PASS both | **same** | [gates/canaries.txt](evidence/gates/canaries.txt) |
| uhdm-cmp 0 lines on the nine moved row-modes | **same**, rc 0 on all nine (final binary) | [gates/uhdmcmp_moved_rows_fix2.txt](evidence/gates/uhdmcmp_moved_rows_fix2.txt) |
| grid: 82 case-views, 31 enter EQUAL, none leaves, `R11U223_OFF` = pristine on all 82 | **same** | [grid_r11u223_cases.tsv](evidence/grid_r11u223_cases.tsv) |
| v11u219 S/s08 elaborated stage 1 -> STRICT_EQUAL, s01c rc 139 -> stage 1 | **same** | [grid_pass219_size_cases.tsv](evidence/grid_pass219_size_cases.tsv) |
| "the fold declines and the call stays" (dynamic / queue inner) | **false**: section 3 | |
| "`law_d5` final: MiniAmiq d/t 1 hash each, SimpleUVM d the pre-existing coin" | **false**: section 4 | |

A smaller count: v11u219 S/s04 elaborated reads 32 -> 17 uhdm-cmp lines here, against the implementer's 30 -> 16.
Line counts of `case.sh`'s `.cmp` file depend on the case path.

## 3. Break 1: the dynamic / queue decline invents `UINT:0` (§ sizeDeclineTsInvalid223v)

UHDM ExprEval::size (third_party/Surelog/third_party/UHDM/templates/ExprEval.cpp, `case uhdmarray_var`) reads the
element variable, then sizes `regv->Typespec()`'s actual: `if (const ref_typespec *rt = regv->Typespec()) bits +=
size(...)`. Its default branch is where invalidValue gets set, but it never reaches that branch for r11u223's placeholder.
The placeholder `chandle_var` has no typespec, so `bits` stays 0 and invalidValue stays false. The `$size`
generic handler then multiplies 0 by the array's last range, sets `found`, and returns `UINT:0`.
`UhdmAdjuster::updateParentWithReducedExpression` replaces the call with it, because the value is not invalid, and
§ ndaAdjSizeFoldSized223 sizes the invented constant to the net without a location. Measured (`uhdm-dump` of the
elaborated instance, case S/s10):

| case (elaborated view) | pristine | law | fix2 |
|---|---|---|---|
| r11u223repro S/s02 (`$size(md)` of `int md [4][]`, `$size(mq)`) | rc 139 | rc 0, **two constants `UINT:0`, size 8, no location** | rc 0, both `sys_func_call $size` kept |
| v11u219repro S/s01_dyn_inner, s01b_queue_inner | rc 139 | rc 0, `UINT:0` | rc 0, call kept |
| own S/s09_genfor_dyn (`$size(md, 1)` beside a generate-for `$size(bp)`) | rc 139 | rc 0, `UINT:0` for `md` | rc 0, the `md` call kept, the `bp` folds unchanged |
| own S/s10_dyn_queue_decline (`md [4][]`, `mq [2][$]`, `m7 [2][][int]`, and one in a generate block) § sizeDeclineTsInvalid223v | rc 139 | rc 0, four invented constants | rc 0, every call kept |

Surelog writes no database for these shapes (SURELOG_FAIL), so there is no golden record to read. The base did not
write a wrong value; it crashed. The law turned the crash into an invented constant. That breaks "golden writes
nothing on a miss", and a downstream consumer would read the constant as the net's value. The law's own stated
intent is "the fold declines and the call stays".

**§ sizeDeclineTsInvalid223v** (uhdm_main.cpp, next to § unsizedInnerSizeDeclines223): the placeholder carries a
`ref_typespec` to a `chandle_typespec`. ExprEval::size does not size that kind: its default branch sets invalidValue,
so the adjuster returns and the call stays. Both objects live outside the serializer, like the placeholder. The
walker path (`walk_ts` on the element typespec) reads nothing from a chandle_typespec, the same as from no
typespec. A shape the base did not crash on never reaches the generic `size()` with a placeholder, because the
base's reach to it was the crash. Switch `R11V223_SIZEINVALID_OFF`.

Measured:

* **Crash shapes:** exactly 5 of the 218 grid case-views with a database from both binaries move against `law`:
  r11u223repro S/s02_el, v11u219 S/s01_dyn_inner_el and s01b_queue_inner_el, and own S/s09_el and S/s10_el. The law
  wrote `UINT:0` sized 8 there for `wd` (s09) and for `w1`-`w4` (s10); `fix2` keeps each call.
* **Byte parity:** every other case-view writes the law's bytes. The fixed-then-associative shapes (C/c01-c08,
  v11u219 s01c, own B/b04) are unchanged, because their element exists.
* **Switch control:** `R11V223_SIZEINVALID_OFF` gives the law's bytes on s09_el and s10_el.
  `R11U223_SIZEDECLINE_OFF` gives rc 139 on both, the base's crash.
* **Gates:** no gate database moves.

## 4. Break 2: the registry makes MiniAmiq and SimpleUVM byte coins (§ formalRegNoHeap223v)

The draws came from drivers/det.py: the harness command of each row-mode, concurrent processes, and a md5 per
draw ([det/draws.txt](evidence/det/draws.txt)).

| row-mode | `pristine` | `law` (`2a3d1e1b`) | `law` + `R11U223_OFF` | **`fix2`** | `fix2` + `R11V223_DETREG_OFF` | `fix2` + `R11U223_OFF` |
|---|---|---|---|---|---|---|
| MiniAmiq default | 3bb66bff ×19 (3 + 16) | **a473b5fb ×9, bb1109be ×10** | 3bb66bff ×8 | **7f3c0003 ×16** | bb1109be ×8 | 3bb66bff ×8 |
| MiniAmiq testflags | 3bb66bff ×19 | **bb1109be ×17, a473b5fb ×2** | 3bb66bff ×8 | **7f3c0003 ×16** | bb1109be ×8 | 3bb66bff ×8 |
| SimpleUVM default | 782fae78 ×19 | **6a99b31a ×9, 0aa54033 ×9, 842e0baa ×1** | | **0aa54033 ×19** | | |
| SimpleUVM testflags | 788feb14 ×19 | 74382048 ×19 | | 74382048 ×19 | | |
| BuildUVMPkg d / t | bb147c1f ×3 / ×3 | 8863bec7 ×19 / ×19 | | 8863bec7 ×19 / ×19 | | |
| SeqDriver d / t, Earlgrey_0_1 d / t | one hash each (×3) | one hash each (×3) | | one hash each (×3) | | |
| Scoreboard default | 3 hashes in 3 (the known coin) | 1 hash in 3 | | 3 hashes in 3 | | |

* **Law variants:** every pair of law variants reads identical in `uhdm-dump`. They differ only in the order of 100
  (MiniAmiq) or 296 (SimpleUVM) symbol-table tail strings, the family r11u223 README section 9 decoded:
  § refFullNameThroughNamedExpr175's address-order walk (ExprEmit.cpp, the sister's ground, called from ParamEmit
  drainPaNameCopySrc38).
* **Where the walk runs:** drainPaNameCopySrc38 runs in exportDesign before r11u223's design-final pass. The only
  thing r11u223 does before it is record formals during emission, and the reserved `std::vector` allocated at the
  first recorded formal (1.5 MB) is the only allocation that recording makes. The controls place the coin there:
  `R11U223_OFF` never records and draws the base's hash every time, and the static-storage registry below draws
  one hash with the base's symbol order.
* **§ formalRegNoHeap223v** (src/R223.h `FormalTdReg223`, read at the § tfArgScalarTdWriter223 pass in UhdmExporter):
  the registry is a static-storage array of 65536 entries. Emission allocates nothing for it, so its heap traffic is
  the base's. Entries beyond capacity spill, in order, to the r11u223 heap vector. Emission order is unchanged, so
  the design-final pass writes the same records.
* **Symbol table:** `fix2`'s MiniAmiq and SimpleUVM symbol tables equal pristine's string for string (0 differing
  lines). The law's two MiniAmiq variants differ from pristine's in 874 and 1032 lines, and its SimpleUVM variant
  6a99b31a in 296. Its other SimpleUVM variant, 0aa54033, is byte-identical to `fix2`'s database.
* **Dumps:** `fix2`'s dump equals the law's. Its bytes differ from pristine's only in the records the law moves.
* **Switch control:** `R11V223_DETREG_OFF` restores the law's reserved-vector registry and draws the law's variant
  bb1109be.

This is a determinism fix only. It moves no record: the gate verdicts of `fix2` equal `law`'s in every stage
(section 6). The root cause, the address-order walk in ExprEmit, is left at its decode on the sister's ground:
collect the objects and sort them by UhdmId, as § lawSCopyIdOrder186 did.

## 5. Fresh cases (53 cases, 106 case-views; [grid_fresh.tsv](evidence/grid_fresh.tsv))

Every case names its law in its first line. Goldens are Surelog v1.87 with the probe arguments, in both views
(r11u223repro drivers/case.sh through drivers/grid.sh).

**29 case-views enter EQUAL and none leaves.** No case-view exits 139 under `fix2`, where the base crashed on 3
(B/b04, S/s09 and S/s10, elaborated). Cases a15 and b01 exit 4 on every binary: unsupported class-property constructs,
with the database written. For every case-view:

* `fix2` under `R11U223_OFF` writes pristine bytes, and exits 139 wherever pristine crashed (all 7 crash
  case-views across the three grids).
* `fix2` under `R11V223_OFF` writes the law's bytes.

Chain-keyed away census of `fix2` against pristine on the 85 moved case-views with a golden
([away_fresh_cases.txt](evidence/away_fresh_cases.txt)): **0 lost, 355 toward**. Flat: 2 lost, both paired in place
(A/a03, both views: the declaration-span `A_T` record replaced at its formal by golden's token copy).

**A: the scalar-typedef formal** (§ tfArgScalarTdWriter223 unless noted), with golden, pristine and law in both
views:

| case | shape | pristine | law = fix2 |
|---|---|---|---|
| a01_typeparam | class type parameter defaulting to the typedef; module `parameter type` formal | stage 1 | unchanged (no firing) |
| a02_inherited | `f(UVM_FILE a, b, input int k, UVM_FILE d)`, `task t(output UVM_FILE o1, o2)` | line | **EQUAL** both views |
| a03_tdoftd | typedef of a typedef (`B_T` of `A_T`) and `A_T` | stage 1 | stage 1; the `A_T` formal right; `B_T` untouched (golden MOVES the listing `p::B_T` to the token: residue 4) |
| a04_logicvariants | `logic`, `reg [3:0]`, `logic signed [7:0]`, `bit signed [7:0]`, `int unsigned` | line | **EQUAL** |
| a05_ctor_static | `new` with a default, static, virtual, an override in an importing package | line | **EQUAL** |
| a06_ifaceclass | interface class pure virtual, implements, virtual class pure virtual | stage 1 | stage 1, 2 toward |
| a07_pkgfunc_calls | package function called from a module (`inc(a)`, `p::inc(a)`) | line | name (residue 3) |
| a08_shadow | a class-local `typedef byte UVM_FILE` shadowing the package's | stage 1 | stage 1, 1 toward |
| a09_iface_gen | interface task/function with modport import, generate-block function | stage 1 | stage 1, 7 toward; downstream IDENTICAL both |
| a10_nested | method of a nested class | line | **EQUAL** |
| a11_var_constref | `input var`, `const ref`, `ref ... [4]` | stage 1 | stage 1, 2 toward |
| a12_explicit_import | `import p::UVM_FILE;` module function | line | name (residue 3) |
| a13_twopkg_same | two packages with the same typedef name | stage 1 | stage 1, 2 toward |
| a14_dpiexp | § tfArgScalarTdExportFirst223: `export "DPI-C" c_f = function f;` and `export ... task t;` before the definitions | stage 1 | stage 1; `R11U223_SCALARTDEXP_OFF` moves only this case |
| a15_covergroup | `covergroup ... with function sample(NIB x)` | EQUAL (rc 4: unsupported covergroup property) | EQUAL |
| a16_program | program function | stage 1 | stage 1 |
| a17_fixedunpacked | `x [2]`, `y [1:0][3]`, `z [string]` | line | **EQUAL** |
| a18_multiline_comments | comments inside the formal, a multi-line `input` formal with a default | line | **EQUAL** |
| a19_twofiles | two files, the same declarator position in both | line | **EQUAL** |
| a20_include_macro | a formal in an included header, a macro-built formal, a formal inside `` `ifdef/`else `` | file | col (the inactive-branch column: residue 6) |
| a21_crlf | CRLF, a formal on its own line | EQUAL | EQUAL |
| a22_extern_oob | extern prototypes and out-of-body definitions, a static with a typedef return | EQUAL / fullname (elab) | same, 15 toward |
| a23_modclass_unit | `$unit` class and module-scope class | line | **EQUAL** |
| a24_elab_twice | module function in a module instantiated twice with different parameters | name | name; downstream IDENTICAL both |
| a25_import_clone | a package function calling an imported package function | line / stage 1 (elab) | fullname / stage 1, 10 toward |
| a26_reexport | `export p::*` re-export | line | **EQUAL** |
| a27_modalias | module-local and package-local alias of the typedef | stage 1 | unchanged (no firing) |
| a28_paramclass_spec | value-parameterized class, specializations, derived specialization | line | **EQUAL** |
| a29_samefile_twoformals_sameline | several methods on one line | line | **EQUAL** |
| a30_modclass_elab | module class in a module instantiated twice | line | **EQUAL** (parse); fullname (elab, the pre-existing class full name) |
| a31_registry_order | § formalRegNoHeap223v § tfArgScalarTdWriter223: formals across packages, classes, a module and an interface | line | name (parse: residue 3), **EQUAL** (elab) |

**B: the fixed-then-associative element** (§ fixedOuterAssocInnerReg223): b01_contexts, b02_elemkinds, b03_typedef_init,
b04_size_elab (§ unsizedInnerSizeDeclines223 too), b05_downstream, b06_{struct, class, bitbyte, wild, string,
queueinner} and b07_pkg_func_ctx. Every one is stage 1 on both binaries, on the `[N]` bound that golden keeps as an
operation (ground A).

* **Element kinds:** in `uhdm-dump`, law's element equals golden's for class, `bit [3:0]` with a byte index,
  wildcard, `string` and `logic` with a queue behind, in both views.
* **b06_struct:** golden writes a module-scope struct-element array as an **array_net** (no array_var), so the
  law's `struct_var` element sits inside an object that was already wrong. This is wrong to wrong: chain 0 lost,
  and the extra uhdm-cmp lines only print a larger unmatched subtree.
* **b07:** a package variable or function local `int pa [3][int]` already carries a `logic_var` element at the
  base, where golden has an `int_var`. The law does not reach it (same bytes): residue 7.
* **Downstream:** b05 goes **EQUIVALENT -> IDENTICAL**; every other B case keeps its verdict.
* **b04 elaborated:** rc 139 -> 0.

**S: the elaborated `$size` sizing** (§ ndaAdjSizeFoldSized223):

* **s01-s05 elaborated go stage 1 -> EQUAL (5 of 5).** The shapes:
  * s01: masking to a 2-bit net, signed nets, an ascending `[0:7]` net;
  * s02: a typedef'd net, a packed two-dimensional net, a 70-bit net;
  * s03: per-instance parameters, where each instance folds its own value;
  * s04: an interface net and a generate-block net;
  * s05: `$size(x, 2)` on enum and int arrays.
* **s06 and s07 do not fire.** s06 is `$size` of an unpacked port. s07 is not a whole initializer, a separate
  `assign`, or a variable initializer.
* **s08 elaborated** is stage 1 on both binaries. `$size(e_t)` of a type is right now. `$size(P)` of a
  parameter array is kept unfolded by golden, where the base's adjuster already folded it. The law resizes that
  wrong constant: wrong to wrong, 0 records lost (residue 5).
* **s09 and s10 are the § sizeDeclineTsInvalid223v shapes** (section 3).
* **Downstream:** every S case reads DIVERGENT on both binaries. The downstream lane is the parse view, where golden
  folds `$size` through ExprEval's generic handler and ours keeps the call (residue 2).

Switch controls ([switches_fresh.txt](evidence/switches_fresh.txt)): the final binary under each switch alone, on
every fresh case-view.

* `R11U223_SCALARTDTOK_OFF` gives pristine bytes on every A case-view where the law fires, and moves no B or S
  case-view.
* `R11U223_SCALARTDEXP_OFF` moves a14 only.
* `R11U223_ASSOCREG_OFF` gives pristine bytes on every B case-view. The exception is b04 elaborated, where pristine
  crashed and the decline now keeps the call.
* `R11U223_ADJSIZE_OFF` gives pristine bytes on s01-s05 elaborated.
* `R11U223_SIZEDECLINE_OFF` gives rc 139 on s09 and s10 elaborated.
* `R11V223_SIZEINVALID_OFF` gives the law's bytes there.
* `R11V223_DETREG_OFF` moves no case-view.

Downstream through scripts/downstream_uhdm2rtlil.py's `one()` ([ds_cases.txt](evidence/ds_cases.txt)): 19 cases, and
none leaves IDENTICAL. B/b05 goes EQUIVALENT -> IDENTICAL; the S DIVERGENT verdicts are unchanged.

## 6. Gates of the final binary (`fix2`, `/tmp/v11u223_wF`; [gates/](evidence/gates/))

| gate | result |
|---|---|
| (1) build | `pristine` = main tree `b47000e7…`; `fix2` `f27e266d…` (a rebuild reproduces it) |
| (2) probe | **regressions=0 conversions=4 changes=2**, EQUAL 3436 / STRICT_NOTEQUAL 651: the law's rows exactly |
| (3) surelog | **regressions=0 conversions=0 changes=7**: the seven UVM row-modes of section 0 |
| (3) uhdm2rtlil | **0 / 0 / 0** |
| (4) downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**, not excused 0; 805 slang lanes byte-identical to pristine |
| (5) uhdm-cmp | 0 lines, rc 0 on all nine moved row-modes |
| (6) byteverify | against pristine: PATH_SETS_IDENTICAL 2560, **MOVERS 9**, SELFCHECK 2559 / 2560. Probe movers 16. The 25 names equal the frozen prediction. Against `law`: MOVERS 2 (MiniAmiq d/t: the law sweep drew variant bb1109be, `fix2` draws 7f3c0003; identical dumps, section 4) and probe 0 |
| canaries | fix2 vs pristine csv: surelog ok=47 changed=5 (the claimed rows), uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil PASS |
| away census (`fix2` vs pristine) | chain_lost=0, chain_toward=5942, flat 234 all paired in place |
| order-blind distances | 5238 / 3779 / 934 / 601 |

The fresh csv rows of the moved row-modes (none converts): `MiniAmiq,default|testflags,STRICT_NOTEQUAL,differ:line(2)`,
`SeqDriver,default|testflags,STRICT_NOTEQUAL,differ:line(2)`, `SimpleUVM,default|testflags,STRICT_NOTEQUAL,differ:file(42)`,
`Scoreboard,default,STRICT_NOTEQUAL,differ:file(18)`, `BuildUVMPkg,default|testflags,STRICT_NOTEQUAL,differ:line(31)`
([gates/uvm_rows_wF.csv](evidence/gates/uvm_rows_wF.csv)). The probe conversions:
`r10uvm125repro/g125_b_shapes,EQUAL,,equal`, `r10uvm125repro/g125_d_homes,EQUAL,,equal`,
`r10uvm35repro/t47a,EQUAL,,equal`, `r10uvm35repro/t47b,EQUAL,,equal`
([gates/probe_moved_rows_wF.csv](evidence/gates/probe_moved_rows_wF.csv)). results/ is untouched.

tools/probe/r11u107repro/canaries.sh read against the committed baselines gives 7 CHANGED rows on the pristine
sweep itself. Earlgrey `fullname(19)` and BuildUVMPkg `line(19)` are among them: the committed csv's detail text
predates later integrations, and compare_results reads 0 changes there. That is why this check was run against
the pristine csv.

## 7. Residues, ranked (after the verified patch)

1. **`UVM_SEQ_ARB_TYPE`: extern-prototype writer of an alias-of-alias.** This heads MiniAmiq d/t (#24915) and
   SeqDriver d/t (#24898): golden writes 332:40, ours 1381:51. It is r11u223 residue 1, and it is this ground's.
2. **`this_type`: an out-of-body formal binding another class's typedef.** This heads SimpleUVM d/t (#26887),
   Scoreboard d (#26895) and BuildUVMPkg d/t (#26855): golden writes uvm_algorithmic_comparator.svh 74:11 and ours
   uvm_sequence_library.svh 330:12. It is r11u223 residue 2.
3. **Module-scope formals of an imported scalar typedef.** Seen in own A/a07, a12 and a31: a package function
   called from a module, a module function under `import p::T`, and module `m(T2 m1)`. Golden writes a bare-named
   `T2` / `UVM_FILE` at the formal's token (a31: 33:28). Ours writes the module's import copy `p::T2` at the
   declaration, on both binaries. The law skips it by design, because the name holds `::`. Two fields are wrong
   (name and span), and both belong to the module-scope import copy of LAW S (TypeEmit, this ground). In a25, the
   importer's clone of a package function also names its formal through the wrong function (`q::inc::f` where
   golden writes `q::twice::f`).
4. **Typedefs of scalar typedefs and package-qualified scalar formals: relocation, not copy.** Own A/a03: golden
   MOVES the listing `p::B_T` to the formal's token 6:22 and names the depth-2 listing there too. r11u223's residue
   3 (`p::UVM_FILE`) is the same family. Both need § tfArgClassMethodOrder176's writer model extended to scalar
   typedef chains.
5. **Golden keeps `$size` of a parameter array unfolded.** Own S/s08 `$size(P)`: golden's argument is the
   substituted pattern, which ExprEval's handler does not size. Ours folds the call in the adjuster at the base, and
   § ndaAdjSizeFoldSized223 resizes that constant. This is wrong to wrong. The fix is to decline the fold for a
   parameter operand, in uhdm_main or ModuleEmit.
6. **Parse-view `$size`, downstream-visible.** Every own S case reads DIVERGENT downstream on both binaries. The lane
   is the parse view, where golden writes ExprEval's generic-handler constant (`$size(bp)` of `bit [3:0][1:0]`
   -> 2, not the language's 4), and ours keeps the call, which the plugin evaluates to 4. This is r11u223 residue 5.
   Transcribing ExprEval's `$size` generic handler into ModuleEmit's rqSizePlan216 would turn these IDENTICAL.
7. **Columns of formals inside macros and inactive `` `ifdef `` branches** (own A/a20; r11u223 residue 7): our
   preprocessor model, UhdmExporter.
8. **Element kind of a package-level or function-local fixed-then-associative array** (own B/b07): ours writes
   `logic_var` where golden writes `int_var`, on both binaries, through another emission path. A module-scope struct
   element is an `array_net` in golden (b06_struct).
9. **The address-order walk**, § refFullNameThroughNamedExpr175 (ExprEmit, the sister's): the root of both coins in
   section 4. § formalRegNoHeap223v only stops this pass from exposing it.
10. r11u223's residues 4 (x03), 6 (based range bounds) and 8 (the `[N]` bound, ground A) stand as written there.

## 8. Fence and process

* **The fence.** Every driver reads the four names from canaudit.sh's `FENCED=` line and fails closed:
  drivers/env.sh, census.sh (`--filter` built from `$FENCED` for both corpora and downstream), det.py, and
  r11u223repro's bvmirror.sh and awayall.py, which skip fenced directories unread (8 per sweep). The gate sweeps
  dispatched every row as the gate mandates, and only their csv verdicts were read. No binary, gdb run or script
  touched a fenced test's sources or databases outside them. A grep of this directory for the four names, as words
  or substrings, reads 0.
* **Order of work.**
  * The pristine binary was frozen before any edit.
  * The census and the prediction ran with the law binary before the law sweep, and the prediction was frozen
    (md5 above) before that sweep.
  * The sweeps ran one at a time: wP, then the census, wL, and wF.
  * A first `fix` sweep was stopped at its surelog stage when § formalRegNoHeap223v was added; only this pass's own
    processes were stopped, each checked by command line.
  * The implementer's warning about a `.uhdm` executed through an unset variable was honoured: drivers/env.sh
    refuses to run without all three tools.
* **Scratch.** Everything is under `/tmp/v11u223_*`, `/tmp/wt_v11u223` and `/tmp/wt_v11u223pris`. The golden store
  for cases is `/tmp/v11u223_s` and the downstream case cache is `/tmp/v11u223_dsgc`. All of it can be pruned at
  landing.

## 9. Files

* **cases/** (53, each naming its law in its first line):
  * A: a01-a31, tfArgScalarTdWriter223; a14 tfArgScalarTdExportFirst223; a31 also formalRegNoHeap223v.
  * B: b01-b07, fixedOuterAssocInnerReg223; b04 also unsizedInnerSizeDeclines223.
  * S: s01-s09, ndaAdjSizeFoldSized223; s09 also unsizedInnerSizeDeclines223; s10 sizeDeclineTsInvalid223v.
  * a19 is two files with an `args` file; a20 has an included header.
* **drivers/:**
  * env.sh: pins, fence, frozen-binary directory `$B`.
  * grid.sh: one case in both views under chosen binaries and switches, through r11u223repro's case.sh.
  * switches.sh: every switch alone.
  * census.sh: the traced firing census.
  * det.py: concurrent draws of a row-mode's harness command.
  * caseaway.py: the chain / flat away census of one case.
  * symlist.sh: builds r11u223repro's symbol-table lister.
  * r11u223repro's own drivers, reused here: case.sh, bvmirror.sh, awayall.py, uvmdist.sh.
* **evidence/:**
  * grid_fresh.tsv, grid_r11u223_cases.tsv, grid_pass219_size_cases.tsv
  * switches_fresh.txt, away_fresh_cases.txt, ds_cases.txt
  * away_{law,fix2}_vs_pristine.txt and the reversed control
  * uvmdist.txt
  * census/: the frozen prediction and its md5
  * gates/: the sweep logs, byteverify, canaries, the moved csv rows, uhdm-cmp
  * det/draws.txt
