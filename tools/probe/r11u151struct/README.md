# r11u151struct: the expression-ground structural classes, decoded and checked in scratch (analyst pass, measurement only)

Base `738014d6` (branch matrix-1.87). This directory is the whole deliverable. Nothing under `src/`, `scripts/`,
`results/`, `tests/` or `third_party/` is edited. The law is in [law.patch](law.patch), a `git diff 738014d6 -- src`
of `src/ParamEmit.cpp`, `src/ExprEmit.cpp`, `src/StmtEmit.cpp` and `src/EmitHelpers.h` (pair A's files only). It
applies cleanly at `738014d6`.

Pair A's r11u145 landed while this pass ran (`1fb349a9`, src byte-identical to `/tmp/r11u145.verified.patch`). Its
§ defaultFillImportCopies145 is the same rule as this pass's DEFPAT law, so `law.patch` conflicts with it in one
hunk. [law_after_r11u145.patch](law_after_r11u145.patch) is the same law without DEFPAT, rebased on `1fb349a9`. It
applies cleanly there, and pair A's refill (r11u147) should land that one. `drivers/compose_r11u145.py` is the
two-hunk conflict resolution that produced it.

Law names below are written `law <name>` with no section sign, so `scripts/law_index.py` does not read this
directory as a pass of laws. The patch names its laws with the section sign at their sites. The landing must run
`python3 scripts/law_index.py` and commit `tests/LAWS.md`. Every sweep here reads `law index STALE` for one reason:
the worktree's edited `src/`. Every measured binary was frozen before its sweep, so no stage result depends on that
check. This README writes the slang-fenced tests as `FENCED=`. The census drivers hold them in a `FENCED` set and
abort before any dispatch if a command names one (`evidence/census/fenced_skipped.txt`: 8 row-modes skipped).

## Binaries (frozen with `chmod 555` before any measurement)

| binary | md5 (12) | what |
|---|---|---|
| `pris` | `134fb0c36f02` | worktree `/tmp/wt_r11u151` at 738014d6, system-deps config, `-j 2`. Byte-identical to the main tree's `build/slang-uhdm`. |
| `law13` | `5770aa17de7e` | 738014d6 + law.patch. The worktree's final build; a clean rebuild reproduced the same md5. |
| `pairA` | `0d37333d17a0` | 738014d6 + r11u145.verified src (= `1fb349a9` src) |
| `pairA_law13` | `0bfdca775f6f` | the above + law_after_r11u145.patch |
| `law13_c3s` | `67931f7d7683` | law13 + [evidence/pairB_c3_scratch.patch](evidence/pairB_c3_scratch.patch) (pair B's file, scratch only) |
| `strictcmp` | `5d4617d0458f` | the main tree's `build/uhdm-strictcmp`, unchanged. No defect was found in it, so it is not edited. |
| `strictcmp_x` | `db96066ac072` | `tools/probe/r11u142map/drivers/strictcmp_x.cpp` (`--dump-ids`) |
| `tsmem_db`, `arrexpr_db` | | `drivers/*.cpp`, built with `drivers/cc.sh`. One reads every typespec_member's Default/Actual value, the other every array_expr's element objects, with UhdmIds and parent chains. |

Every `cmds.txt` of every sweep names its binary by path (`/tmp/r11u151_bin/<name>`).

## 1. Reproduction at 738014d6

`verify_golden.py --filter` on the ten tests, both modes, with `pris`. All 20 row-modes match
`results/golden_*.csv` exactly. `/tmp/strict_sweep` predates 738014d6, so it was not used.
[evidence/rows/heads_738014d6.txt](evidence/rows/heads_738014d6.txt) holds every head (`uhdm-strictcmp --max 50`,
A = golden, B = ours). `evidence/rows/*.recdiff.txt` holds the whole-record diffs of the default mode.
[evidence/identities.txt](evidence/identities.txt) holds the object identities, which `drivers/identities.sh`
regenerates from the grid databases.

## 2. Per class: the object golden lists, the decode, the law, the conversions, what is left

### D2: the swapped cast targets (def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot; N2383 + N2384)

**Face.** In golden, each package listing's `CfgEmpty = cfg_t'(0)` cast references that listing's own `cfg_t`:

| listing | golden cast target | ours at 738014d6 |
|---|---|---|
| definition package (uhdmallPackages) | struct_typespec id 115, the definition typedef (clean) | id 64, the elaborated typedef (stamped by evalFunc: `c.XLEN = 32`, `c.RVC = 1'b1`, `c.RVH = 1'b0`) |
| elaborated package (uhdmtopPackages) | id 3, the elaborated typedef (stamped) | id 14, the definition typedef (clean) |

The head reads `#43 depth`: golden goes to the next member, ours lists two stamp constants.

**Decode.** Surelog `src/DesignCompile/CompilePackage.cpp:60`, `FunctorCompilePackage::operator()`, compiles the
package twice: `compile(Reduce::Yes)` on the package, then `compile(Reduce::No)` on `getUnElabPackage()`. Each
compile runs `collectObjects_(DEFINITION)` before `OTHER`, so a parameter's cast resolves the bare name in its own
compile's DataType map. The evalFunc member stamps (`setValueInInstance`) exist only on the Reduce::Yes typedef.
Grid d05 adds a refinement: a QUALIFIED `p::cfg_t'(0)` resolves through the design's package, the elaborated one,
in both listings (golden: id 3 in both).

On our side, pass 140's law pkgTypedefCastTargetTs140 deferred only the definition listing's cast and bound it to
`pkgTopTypedefTs`. The elaborated listing's cast took the next branch (`typedefTs.count`), which is the definition
typedef.

**Law pkgTdCastTargetOwnView151**, switch `R11U151_D2_OFF`:

- The elaborated listing defers its cast too (ExprEmit).
- The drain (ParamEmit `drainShareDefParamTs`) binds a definition-listing reference spelled bare to `typedefTs`, the
  definition typedef.
- Everything else binds `pkgTopTypedefTs`.

**Converts** def_ctx_struct_param, latch_decoder_partial and latch_tlb_napot, both modes: 6 row-modes
`STRICT_NOTEQUAL differ:depth(1) -> CMP_EQUAL`. Their downstream rows stay IDENTICAL (quoted in section 3).

**Grid** `cases/D2`, 8 cases:

| outcome | cases |
|---|---|
| converts | d06 |
| head moves from depth to endcol | d01, d04, d05, d08 |
| control, strict-equal, unmoved | d02 (no stamps, both typedefs read alike) |
| stage 1 at pristine too | d03, d07 (other faces) |

**Left:** d01/d04/d05/d08's next face is the module parameter default `p::D` fold's endcol (15:37-41 against ours
15:37-40). That is outside this class.

### ARR: the procedural whole-reference binding (array_assign; N0046)

**Face.** `pb = pa;` in `always_comb`. Golden's `ref_obj pa` (61:14) binds the `var_select pa[0][0]` at 56:9, the
first Lhs in the same block. Ours bound the definition `logic_net pa` (53:11) and listed its 3 records.

**Decode.** See `src/DesignCompile/UhdmWriter.cpp:3297`, `UhdmWriter::lateBinding`. For every pooled ref_obj it
walks `VpiParent` upward. At a `uhdmbegin` (3554, and the `named_begin` / `fork_stmt` / `named_fork` copies after
it) it asks, in order:

1. `Variables()`
2. `Parameters()`
3. the block's DIRECT `Stmts()`: the first `assignment` / `assign_stmt` whose `Lhs()->VpiName()` is the name and
   whose Lhs is not a `ref_obj` / `ref_var`

A procedural ref reaches the pool because `CompileExpression.cpp` calls `bindVariable(component, pexpr, ...)` with
`pexpr` = the statement, which answers nothing.

Our net model (StmtEmit `endSelTrack`, fed by `noteSelectObj`) registered bit_select and part_select lvalues only,
never a var_select. It also registered only BLOCKING writes: "a NONBLOCKING bit-write keeps the net" was the old
reading of unpacked_array_shift_ff. Question 3 never reads VpiBlocking. That row keeps the net because its whole
write sits in a SIBLING begin (grid a14).

**Laws:**

- **blockLhsVarSelBindsWholeRef151**, switch `R11U151_ARR_OFF`. A var_select lvalue (both ExprEmit var_select sites:
  the element select, and the element select with a trailing range) registers exactly as the bit_select does: a net,
  a blocking write.
- **nonblockingSelLhsBindsWholeRef151**, switch `R11U151_ARRNB_OFF` (also read by `R11U151_ARR_OFF`). This is
  question 3 for a NET written by a nonblocking select. It uses `noteLocalStmtSel122`'s own direct-statement
  registry: the assignment object's Lhs, first in statement order per block. In `endSelTrack`, a whole ref still on
  the net binds the first registered lvalue of the innermost block in its chain that has one.

  A first version (law12) fed nonblocking selects into the old first-select model instead. It moved YosysOldOr
  (or1200_dc_fsm.v:523 `addr_r <= {tag, addr_r[H:2], 2'd0}` bound the part_select it READS; golden keeps the net).
  That is recorded in `evidence/sweeps/law12_superseded/`, and grid a19 pins it. law13 leaves YosysOldOr
  byte-identical.

**Converts** array_assign, both modes (2 row-modes, `STRICT_NOTEQUAL differ:depth(1) -> CMP_EQUAL`), downstream
IDENTICAL.

**Grid** `cases/ARR`, 21 cases:

- Conversions: a01 (the row's shape), a07 a13 a16 a18 (nonblocking), a20 (stage 1 at pristine, now strict-equal).
- Binding-only moves the strict walk cannot see, read off the dumps in `evidence/identities.txt` (golden = law13 in
  every one):
  - a15: `y <= v` binds the bit_select.
  - a17: the var_select with a trailing range, where pristine bound a LATER bit_select.
- Controls unmoved and equal: a02-a06 a08-a12 a14 a19 a21.

**Census:** after the fix, ARRNB rebinds nothing in the corpora or the probe set. ARR registers in 35 rows or cases.
It moves bytes in array_assign only (plus the UVM coin, section 3).

**Left (R-ARR2, pristine behaviour, strict-blind, not this pass's):** the BLOCKING net model's `selFirstSelect` also
records select READS. Grid a21 is a19's shape with `=`: pristine and law13 bind the sibling begin's whole write
`r = {x, r[3:2], 2'd0}` to the part_select 11:15 it reads, where golden keeps the net (`evidence/identities.txt`).
The fix is to feed the blocking half from the same direct-statement registry. It moves the net model's own ground, so
it needs its own census and pass.

### DEFPAT: the default fill's import copies (DefaultPatternInt; N2385)

**Face.** In the module copies of `pack::V = '{default: 3}`, golden's array_expr lists two UINT:3 size-32 constants
at 4:45-4:46, while the package listing lists one. Pass 140's defaultFillOneConstant140 made every listing one.
`arrexpr_db` shows the object identity on six grid cases: golden `constant#166 constant#167` in both module copies
and `constant#64 constant#64` in the package.

**Law defaultFillImportPerElement151**, switch `R11U151_DEFPAT_OFF`: an import copy (`isImported`) mints one constant
per element. This is the same rule as r11u145's defaultFillImportCopies145, which is now landed.

**Converts** DefaultPatternInt, both modes (2 row-modes). The grid is `cases/DEFPAT`, 6 cases:

- p01 moves from depth to type (a function-body face).
- p02 p04 p05 p06 are stage 1 for other faces. Their element identity equals golden's after the law
  (`evidence/identities.txt`).
- p03 (module-local) keeps its one shared constant, as golden does.

On top of r11u145 the law is a no-op, which is why `law_after_r11u145.patch` drops it.

### G: the kept concatenation (BlackParrotComplex; N0724 + N1129)

**Face 1 (N0724).** `routing_matrix_p = (dims_p == 2) ? StrictXY : StrictX`. Golden's elaborated param_assign
(40:48) Rhs IS StrictXY's elaborated Rhs operation (9:31-25:33, UhdmId 770, parent StrictXY's param_assign),
already walked. Ours folded to `constant UINT:553163846905791 size 50` with a location-less logic_typespec.

**Decode.** `third_party/UHDM/templates/ExprEval.cpp:3863`, the `vpiConditionOp` case of `reduceExpr`, reduces the
taken operand. The reference reduces to the parameter's Rhs object. `get_value` (1947) reads only constants,
variables and parameters, so it fails on an operation and `result = the_val` hands the object back.

Whether the taken parameter's Rhs stays an operation is the `vpiConcatOp` case (3993). It reduces a concatenation
unless an operand is itself a concat or pattern operation (`c1 = nullptr`), or a 64-bit INT/UINT in a
multi-operand concat. Grid g01 (a flat concat of constants) folds in golden: INT:503. An assignment-pattern case is a
CLONE in golden, not a share (grid g03: golden lists a full copy at 4:25), so it is excluded.

**Law condTakenParamRhsShared151**, switch `R11U151_G_OFF`, in ParamEmit before `pa->Rhs(rhs)`. It applies to an
elaborated (physical) module parameter that is not in a package, not imported and not overridden, whose default is
a constant-condition ternary chain ending on a bare reference to a parameter of the same body. When that
parameter's elaborated Rhs is a concatenation ExprEval cannot reduce, that object becomes the Rhs, shared and not
reparented.

**Face 2 (N1129, unmasked by face 1).** Module `bottom`'s `parameter int A3[0:2] = {1, 2, 3}`. Golden's elaborated
Rhs operation references the DEFINITION parameter's array_typespec (id 6, element ref raw name `work@bottom.A3`).
Ours minted a fresh one named by the instance prefix (`work@bottom`).

**Law concatArrParamDefTs151**, switch `R11U151_G2_OFF` (also read by `R11U151_G_OFF`). For a module's own,
non-imported unpacked-array parameter whose elaborated Rhs is a concatenation, the Rhs op's ref_typespec takes
`defParamArrayTs`. A pattern keeps its own copy (grid h02, equal either way).

**Converts** BlackParrotComplex, both modes (2 row-modes, `STRICT_NOTEQUAL differ:depth(1) -> CMP_EQUAL`).

**Grid** `cases/G` (14) + `cases/G2` (5):

- Conversions: g10 g11 g12 g14 (nested concat: true case, false case, chain, two readers) and h04 (bottom's shape).
- g13 (the width-converted target) moves bytes: its extra folded constant is gone, and the head (an earlier
  typespec line) is unmoved.
- h01, h03 and h05 move from fullname to file. The next face is the `assign o = A3[k]` element-read fold's location
  (golden keeps the concat operand's 4:34 with its file). That is a cont_assign fold, pair B's ModuleEmit.
- The g01-g09 controls are byte-identical to pristine. Most of them are stage 1 for faces outside this class.

### D: the member-default leftovers (StructParamFuncBodyFieldCompare, StructParamPatternInitCast; N0045 + N0758)

**Face 1 (N0045).** `r.XLEN = c.XLEN` in a builder called from a MODULE parameter default
`cfg_pkg::build_config(cfg_pkg::Base)`. Golden lists the XLEN leftover (the caller's pattern element 30:23
`UINT:64 size 32`, twice per member) under every stamped `cfg_t`. Ours stamped the element object the Base listing
had already walked, so the walk listed nothing (`#192 depth`).

**Decode** (`tsmem_db`, `evidence/identities.txt`, grid e01-e07 and the corpus): golden's stamped object hangs
under an operation no listing walks.

- FuncStructVal: `constant#9772 < tagged_pattern#9769 < operation#9768 < param_assign#989`. The op is not a walked
  record (`strictcmp_x --dump-ids`); the param_assign's walked Rhs is another object.
- Grid e03: the op is a clone relocated to the argument (`operation#88@11:30`).

These are the two getValue roads. `CompileExpression.cpp:871` `CompileHelper::getValue`'s qualified-name case runs
`expandPatternAssignment` and writes the copy back (`param->Rhs(rhs)`, 943). The component case `clone_tree`s the
Rhs and `populateCoreMembers(child, ...)` relocates it (2906/2974). Either way the element ExprEval reads, and
`setValueInInstance` stamps, is not the listed one.

**Law patLeftoverOrphanCopy151**, switch `R11U151_D_OFF`, in ParamEmit `stampEvalFuncLeftovers` (the r10fsv2 L1
resolution). A CONSTANT pattern-element leftover is stamped as a copy with the same value, size, type, decompile,
span, parent, and a ref_typespec copy. Anything else keeps the share.

**Face 2 (N0758, unmasked by face 1).** `Cfg.XLEN'(1)`: golden types the size cast by the PARAMETER's struct
typespec (`struct_typespec cfg_t`, with its stamps). Ours minted an `integer_typespec` over the hier_path.

**Law hierSizeCastBaseStructTs151**, switch `R11U151_DCAST_OFF` (also read by `R11U151_D_OFF`), in the ExprEmit
size-cast fallback. When the width is a member-access chain on a struct-typed parameter, the cast type is that
typedef's elaborated typespec. Identity is outside the strict contract.

**Result.** Neither row converts, and no structural record is left in either:

- StructParamFuncBodyFieldCompare, both modes: `differ:depth(1) -> differ:endcol(17)`.
- StructParamPatternInitCast, both modes: `differ:fullname(2) -> differ:fullname(17)`.

The walks no longer diverge, so the counts are unmaskings (`evidence/sweeps/changecheck.txt`). The same two laws
move StructParamFieldRange and cva6_struct_param_field (`endcol(5) -> endcol(9)`), FuncStructVal and
FuncStructValSimple, and the probe grid `r11u109repro/grid/f1` (30 cases). All of these are unmaskings except
FuncStructVal d/t and p03_ready, noted below.

**Grid** `cases/D`, 7 cases:

| outcome | cases |
|---|---|
| converts | e06 |
| depth to line | e02 |
| depth to fullname | e07 |
| unmoved in head | e01 e05 (the first head is the r11u145-ground ref_typespec name `cfg_pkg`) |
| stage 1 | e03 e04 |

**Left:**

1. **R-D1 (pair B, TypeEmit).** The `localparam type it_t = struct packed {...}` struct_typespec span. Golden has
   42:26-42:32 in both listings; ours has 42:39 / 45:4.
2. **R-D2 (N0756, ExprEmit hier_path).** `(Cfg.XLEN - 1)` in the definition module's parameter init. Golden has
   ref_obj `Cfg` at 47:31-34 and `XLEN` named `work@<mod>.XLEN` at 47:35-39. Ours anchors both at the member span
   and leaves XLEN unnamed.
3. **R-D3 (N0759).** Under the MODULE holder's own stamped copy of cfg_t (golden struct_typespec #10290/#1090,
   parented at the module parameter's ref_typespec), golden's Flag operation is a clone parented at the member.
   Its ref_objs read `<in>cfg_pkg::cfg_t.Flag.NrRules`, where ours shares the function body's (`cfg_pkg::build_config::NrRules`).

   Matching it needs a per-module-holder copy of the stamped struct typespec with member-parented clones of the
   operation leftovers. That is 4 records per module listing (2 listings in StructParamFuncBodyFieldCompare), and
   it copies the operation golden holds once in the package typedef. Not written.
4. **R-D4, FuncStructVal testflags,** moves its divergence EARLIER (#14385 -> #13254; gap -2092 -> +695 objects). This is
   an accidental agreement unmasked.

   In build_config's body, golden's `cfg.DCACHE_USER_WIDTH` ref_obj binds a cfg_t member with no value (another
   copy: `DCACHE_USER_LINE_WIDTH` there carries a location-less INT:128). Ours binds the stamped typedef's member,
   whose leftover used to be an already-walked object and is now the listed copy.

   The binding of the function body's member references to golden's unstamped copy is the residue. The default
   mode improves (divergence #7595 -> #7975, gap 2088 -> 288).
5. **Probe r11u109repro/grid/f1/p03_ready** also keeps a divergence, moved later (#126 -> #284).

### C3: the port connection operation (StructArray… / NestedStructArrayParameterInitializedByPatternPassedAsPort; N0417 + N0534)

**Face.** The elaborated port `region_attrs_i`'s high_conn operation:

| | golden | ours at 738014d6 |
|---|---|---|
| span | the ACTUAL's, 23:23-23:33 | the parameter's pattern span, 6:49-10:5 |
| ref_typespec full name | `work@top.u_hw_sel.region_attrs_i` | `work@top.u_hw_sel.u_hw_sel.region_attrs_i` (the instance doubled) |

The Nested twin adds two ref_typespecs, in the param_assign flavour of the fold, where golden stores no full name.
Ours stored `work@top` / `work@top.u_hw_sel`.

**Decode.** `NetlistElaboration.cpp` compiles the actual with `Reduce::Yes`. `compileExpression`'s parameter case
(`CompileExpression.cpp:2903-2906`) `clone_tree`s the param_assign Rhs and `populateCoreMembers(child, child,
result)` relocates the clone's root to the REFERENCE. The port name is the formal's.

The nested member ops are ExprEval::flattenPatternAssignments' copies. Their ref_typespec is never parented (the
reference pkgPatReadTsNoParent131 already cites), so the full name computes to nothing. In the connection flavour,
golden's nested reference names through the port (#594 `work@top.u_hw_sel.region_attrs_i`).

**Law nestedPatOpTsNoParent151** (the ParamEmit half), switch `R11U151_C3_OFF`. In
`foldUnpackedStructArrayPattern`'s param_assign flavour (`!connFold`), the nested member op's ref_typespec has no
parent. The row changes: Nested… both modes, `differ:fullname(4) -> differ:line(2)`, which is now exactly the
non-nested twin's head. Grid c05 converts and c02 moves from fullname to line.

**The span and the name sit on pair B's file** (ModuleEmit `emitInstance`, the `.port(HwDataAttr)` fold): `cfn9` is
built from `prefix + inst.name + ps.name`, where `prefix` already ends in the instance, and the fold keeps the
initializer's span. The fix, drop `inst.name` and `setLoc(fop9, ce9.sourceRange)`, is not in law.patch. It is
written as [evidence/pairB_c3_scratch.patch](evidence/pairB_c3_scratch.patch) (switch `R11U151_C3S_OFF`) and
measured in scratch only:

- With law.patch it converts all four row-modes, StructArray… and Nested…, both modes, `-> CMP_EQUAL`.
- It converts grid c01-c05.
- `evidence/grid/c3_pairB_scratch.txt` holds these. The full sweep of that binary is section 3's last table.

**Left:** c06 (a two-element array, where the fold declines) is stage 1 for another face.

## 3. Gates

The pristine sweep `/tmp/r11u151_swP` and the law sweep `/tmp/r11u151_swL` both used same-length workdirs, the full
`tests/sweep.sh --jobs 3` from the worktree, and `GOLDEN_DEFER` unset. Logs are in
`evidence/sweeps/sweep_{pristine,law13}.log`.

| gate | pristine | law13 |
|---|---|---|
| probe vs golden_probe.csv | 0 / 0 / 0 (EQUAL 2308, STRICT_NOTEQUAL 1779) | regressions 0, conversions 0, changes 30 (all `r11u109repro/grid/f1`, D + DCAST) |
| surelog vs golden_surelog.csv | 0 / 0 / 0 | regressions 0, conversions 4, changes 10 |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | 0 / 0 / 0 | regressions 0, conversions 8, changes 4 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 | 803 / 66 / 2 / 0; the verdict column is identical to pristine on all 871 rows |

**Conversions** (`evidence/sweeps/fresh_rows.csv`), all `STRICT_NOTEQUAL -> CMP_EQUAL,,,equal`:

- uhdm2rtlil: array_assign, def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot (both modes).
- surelog: BlackParrotComplex, DefaultPatternInt (both modes).

**Changes.** `drivers/changecheck.sh` reads the comparator's own summary on the pristine and on the law database
(`evidence/sweeps/changecheck.txt`):

- 39 of the 44 changes are **unmaskings**: pristine read "walk diverged", and law13 is aligned, with only field
  differences left.
- NestedStructArray… is aligned in both, and its count falls 4 -> 2.
- FuncStructVal d/t and probe p03_ready still diverge. The divergence moves later, except FuncStructVal testflags
  (R-D4 above).

**Downstream rows of every touched u2r test** (`evidence/sweeps/fresh_downstream_rows.csv`):

```
array_assign,IDENTICAL,NO_GATES,NO_GATES,0,0,,
cva6_struct_param_field,IDENTICAL,OK,OK,1,1,,
def_ctx_struct_param,IDENTICAL,OK,OK,2,2,,
latch_decoder_partial,IDENTICAL,OK,OK,1,1,,
latch_tlb_napot,IDENTICAL,OK,OK,2,2,,
NestedStructArrayParameterInitializedByPatternPassedAsPort,IDENTICAL,NO_GATES,NO_GATES,0,0,,
StructArrayParameterInitializedByPatternPassedAsPort,IDENTICAL,NO_GATES,NO_GATES,0,0,,
```

**uhdm-cmp** reads 0 lines on all 62 byte movers: 31 corpus and 31 probe (`evidence/sweeps/uhdmcmp_movers.txt`).

**Canaries.** Measured against the 738014d6 baselines, `/tmp/wt_r11u151/results`. The main tree's `results/` had
moved to `1fb349a9` by the time these ran, and there Scr1SvTests/BasicOh differ for that reason alone.

| check | result |
|---|---|
| canaries.sh surelog | ok=48, changed=4: BlackParrotComplex d/t (the conversion) and FuncStructVal d/t (D) |
| canaries.sh uhdm2rtlil | ok=16, changed=0 |
| ctcan2 `EXPECT_UNKNOWN=1` surelog | reads FAIL on BlackParrotComplex d/t alone, the claimed conversion; ok=56 |
| ctcan2 `EXPECT_UNKNOWN=6` uhdm2rtlil | PASS |

**byteverify** (`tools/probe/r11v75repro/byteverify.sh`, `SELFCHECK=1`), in `evidence/sweeps/byteverify_*.txt`:

| corpus | movers | selfcheck flagged | path sets |
|---|---|---|---|
| surelog | 19 / 960 | 959 / 960 | identical |
| uhdm2rtlil | 12 / 1608 | 1607 / 1608 | identical |
| probe (databases compared by `cmp`) | 31 / 4087 | | |

**Movers, predicted by name before the byte comparison.** `drivers/census.py` runs law13 under `R11U151_TRACE=1` on
every pristine-sweep command and every probe case, 7352 runs, fail-closed on FENCED. Its output is in
`evidence/census/`, and each firing row's laws are in `firing.txt`.

- **Every one of the 62 movers is on the census's firing list.**
- Firing without moving a byte: 26 corpus row-modes and 2 probe cases. These are ARR registrations with no whole
  reference in the chain: 2DFunctionArg, Earlgrey_0_1, BuildUVMPkg, `r10earl_repro/u` and others.
- **The UVM coin.** MiniAmiq d/t, Scoreboard d and SeqDriver d/t are ARR-registering rows. Their order-blind
  uhdm-dump diff is 0 or 4 lines (`UINT` / `vpiDecompile`: 782 <-> 0), the known coin
  (`evidence/sweeps/uvm_coin_orderblind.txt`).
- The 5 `rc=-11` runs in the census (Tnoc d/t and three rp32 testflags rows) are SLANG_REJECT rows in the pristine
  sweep too.

**Switch attribution** (`drivers/swcheck_rows.py`, `drivers/swcheck_grid.sh`):

- For every non-coin corpus mover, `R11U151_OFF=1` and the owning class switch alone each rewrite the pristine sweep's
  exact bytes (`evidence/sweeps/switch_check_rows.txt`).
- On the 67 grid cases, the same holds for all 39 that the law moves (`evidence/grid/switch_check.txt`). As the
  positive control, the law binary with no switch moves those 39.

**Composition with r11u145.** `1fb349a9` src = r11u145.verified. `/tmp/r11u151_swA` is pairA and `/tmp/r11u151_swC`
is pairA_law13, both full sweeps (`evidence/sweeps/sweep_r11u145_*.log`).

| gate | r11u145 alone | r11u145 + law_after_r11u145 |
|---|---|---|
| probe | 0 / 44 / 4 | 0 / 44 / 34 |
| surelog | 0 / 2 / 11 | 0 / 4 / 21 |
| uhdm2rtlil | 0 / 4 / 28 | 0 / 12 / 32 |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, verdict column identical to r11u145 alone |

`drivers/compose_rows.py` (`evidence/sweeps/composition_r11u145.txt`) classes all 147 rows that move in any of the
three runs as ADDITIVE. The combined verdict equals the one run that moved the row. The one row both runs move,
DefaultPatternInt d/t, converts in both.

Byte movers of the composed binary against r11u145 alone number 29. They are law13's 31 minus DefaultPatternInt d/t,
with the UVM coin varying (`evidence/sweeps/byteverify_r11u145_plus_law_vs_r11u145.txt`).

**Pair B's C3 scratch** (`law13_c3s` = law13 + evidence/pairB_c3_scratch.patch, full sweep `/tmp/r11u151_swB`,
`evidence/sweeps/sweep_law13_plus_pairB_c3_scratch.log`), measured against the law13 sweep:

- **Conversions:** StructArray… and NestedStructArray…PassedAsPort, both modes, `-> CMP_EQUAL`. The surelog stage is
  unchanged.
- **Probe:** two more improvements, `r11u10repro/grid/h9_1e1m_port` and `hD_1e1mvec`, both
  `differ:fullname(7) -> differ:fullname(5)`.
- **Downstream:** the verdict column is identical (803 / 66 / 2 / 0).
- **Byte movers over law13:** the 4 C3 row-modes, the 2 probe cases and the UVM coin
  (`evidence/sweeps/byteverify_pairB_scratch_vs_law13.txt`). Pair B lands this with its own grid and census.

## 4. Totals and ranked residue

**Converted by law.patch:** 12 corpus row-modes (6 tests, both modes) and 14 grid cases. Nothing regressed, and no
downstream verdict moved. With pair B's scratch C3 fix, the class's 4 row-modes convert too, so all of the brief's
rows except the two D tests are cleared.

**Structural rows after this law:** of the brief's 20 row-modes, none keeps a depth, type or count head except
FuncStructVal testflags. That row is not in the brief; its divergence moved earlier (R-D4).

Ranked residue:

1. **C3 span and name** (4 row-modes, pair B, ModuleEmit). Fix written and measured in
   `evidence/pairB_c3_scratch.patch`.
2. **D's module-holder copy** (R-D3): 2 row-modes' Flag names. It needs a per-holder stamped struct copy; not
   written. Also R-D2: the definition-module rvalue hier_path spans and names (ExprEmit, the hier_path ground).
3. **R-D1**, the `localparam type` struct span (pair B, TypeEmit): StructParamFuncBodyFieldCompare and
   StructParamPatternInitCast d/t, plus the 30 f1 probe cases.
4. **R-D4**, function-body member references binding golden's unstamped cfg_t copy (FuncStructVal testflags).
5. **R-ARR2**, the blocking net model's read selects (grid a21, strict-blind).
6. **G2 h01/h03/h05**, the cont_assign element-read fold's location (pair B).

No class copies an object golden holds once:

- D2 rebinds.
- ARR rebinds to objects golden lists.
- DEFPAT mints the per-element constants golden lists.
- G shares golden's shared object.
- G2 shares the definition typespec.
- D copies only an object golden holds as an unwalked orphan.
- DCAST references the existing typedef.
- C3 removes a parent.

## 5. Files

- **law.patch**: the law at 738014d6.
- **law_after_r11u145.patch**: the law without DEFPAT, on `1fb349a9`.
- **cases/{ARR,C3,D,D2,DEFPAT,G,G2}**: 67 cases, one `dut.sv` each. Goldens are built by `drivers/grid1.sh` with
  the pinned Surelog and check_probe's arguments, into `/tmp/r11u151_g/<class>/<case>/gold/`. Nothing is written
  under `cases/`.
- **drivers/**:
  - `grid1.sh` and `gridall.sh` run the grid.
  - `census.py` is the fail-closed predictor.
  - `changecheck.sh` separates unmaskings from new differences.
  - `swcheck_rows.py` and `swcheck_grid.sh` do the switch attribution.
  - `compose_rows.py` and `compose_r11u145.py` handle the composition with pair A.
  - `probegold.py` reads a probe case's cached golden.
  - `identities.sh`, `tsmem_db.cpp` and `arrexpr_db.cpp` read the identities; `cc.sh` builds the readers.
- **evidence/**:
  - `rows/`: the heads at 738014d6 and the record diffs.
  - `identities.txt`
  - `grid/`: the grid table, the switch check and the C3 pair-B scratch.
  - `census/`
  - `sweeps/`: the logs, byteverify, the change check, the canaries' inputs, the UVM coin, the composition, and the
    superseded law12 run.
  - `pairB_c3_scratch.patch`
