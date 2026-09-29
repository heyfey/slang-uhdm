# r11u225: pass 225, the module/type ground: the interface-array element target's fresh elaborated cont_assign (InterfArrayBind d), the struct-member substitution's reference span, bare name and kept fill literal (OutputSizeWithParameterOfInstanceInitializedByStructMember d/t)

**Base** `75a564b0` (branch matrix-1.87). Production files touched: `src/ModuleEmit.cpp`, `src/TypeEmit.cpp` and a new
header `src/R225.h` (the switches, the trace, the owner registry); nothing in ExprEmit.cpp, EmitHelpers.h, StmtEmit.cpp
or ParamEmit.cpp (the sister's ground). Law names are written `§ name` in the source and `law name` here; a probe case
is called a case. The four slang-fenced tests are never named here: every driver reads them from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and fails closed (section 10).

## 0. Verdicts

| target | before (base `75a564b0`) | after | law(s) |
|---|---|---|---|
| **InterfArrayBind default** (brief item 5, r11u220 section 6.1) | `STRICT_NOTEQUAL differ:fullname(1)` | **`CMP_EQUAL` (CONVERSION)** | ifArrElemLitCaFresh225 |
| **OutputSizeWithParameterOfInstanceInitializedByStructMember default** (item 5, r11u220 section 6.2) | `STRICT_NOTEQUAL differ:line(8)` | **`CMP_EQUAL` (CONVERSION)** | initHierAtRefToken225, initHierCaLhsBareName225, initHierFillKept225 |
| **OutputSizeWithParameterOfInstanceInitializedByStructMember testflags** | `STRICT_NOTEQUAL differ:line(8)` | **`CMP_EQUAL` (CONVERSION)** | the same three |
| OutputSize... downstream | IDENTICAL | IDENTICAL (the slang lane's RTLIL, netlist and synth byte-identical to the Surelog lane's and to pristine's) | - |
| InterfArrayBind testflags | `CMP_EQUAL` | `CMP_EQUAL` (bytes move: the fresh cont_assign; 0 records change) | ifArrElemLitCaFresh225 |
| item (1) `UVM_SEQ_ARB_TYPE` (MiniAmiq d/t, SeqDriver d/t) | `line(2)` | unchanged: decoded further, not written (section 11.1) | - |
| item (2) `this_type` (SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t) | `file(40)` / `file(16)` / `line(19)` | unchanged: the small shapes bind the class's own typedef in golden; the UVM fallback is not reproduced by them (section 11.2) | - |
| items (3), (4), (6) | - | not attempted beyond re-measuring (section 11) | - |
| Earlgrey_0_1 d/t `fullname(19)` | first record #106660 | attributed: 19 records of five families on both grounds, no near conversion (section 11.5) | - |

**Three row-modes convert** (the fresh csv rows, `results/` untouched, [evidence/final/rows.csv](evidence/final/rows.csv)):

```
InterfArrayBind,default,CMP_EQUAL,,,equal                                            (was STRICT_NOTEQUAL differ:fullname(1))
OutputSizeWithParameterOfInstanceInitializedByStructMember,default,CMP_EQUAL,,,equal  (was STRICT_NOTEQUAL differ:line(8))
OutputSizeWithParameterOfInstanceInitializedByStructMember,testflags,CMP_EQUAL,,,equal (was STRICT_NOTEQUAL differ:line(8))
OutputSizeWithParameterOfInstanceInitializedByStructMember,IDENTICAL,NO_GATES,NO_GATES,0,0,,   (downstream, unchanged)
```

**Gates** (`tests/sweep.sh --jobs 3` with the law binary against the committed baselines; [evidence/final/sweep_wL.log](evidence/final/sweep_wL.log)):
**probe regressions=0 conversions=0 changes=0 (EQUAL 3448 / STRICT_NOTEQUAL 639, the csv byte-identical to
results/golden_probe.csv); surelog regressions=0 conversions=1 changes=0 (930 CMP_EQUAL + 24 STRICT_NOTEQUAL);
uhdm2rtlil regressions=0 conversions=2 changes=0 (1602 CMP_EQUAL + 4 STRICT_NOTEQUAL); downstream 803 IDENTICAL / 66
SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict diff 0 against the baseline and against the pristine sweep.** Byte
movers: 4 corpus row-modes + 1 downstream lane = the frozen prediction exactly, plus Scoreboard default, the known
storage coin (identical dumps and object lists, 38 symbol-table tail strings in another order; pristine draws the law
sweep's hash too: section 9). Away census 0 records lost (chain and flat), 15 toward golden.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u225_bin` before measurement)

| binary | md5 | what |
|---|---|---|
| `pristine` | `abaa83b8a0194539219d406e055c8b51` | the worktree at `75a564b0`, system-deps config, `-j 2`: byte-identical to the main tree's `build/slang-uhdm` |
| **`law`** (= `d4`) | **`3e17227217fcf1e151cd5a3d1d1e043c`** | **the final binary = `75a564b0` + this pass's src diff** |
| `d1`, `d2`, `d3` | `c374b0d9…`, `ad0b0c77…`, `6349b755…` | drafts (d1: the interface-array law and the three substitution laws, the fill law not yet sharing the definition's constant; d2: + the definition constant and the enum selector binding; d3: + the module-scope restriction of the bare-name law, the owner registry without a reservation); grid and target rows only |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the main tree's build (not edited) |

The patch (`/tmp/r11u225.patch`) applied to a fresh `75a564b0` worktree rebuilds `law` byte for byte (md5 `3e172272…`).
`d4` differs from `d3` only by two trace calls (the predictor's trigger on every branch, section 6); its grid bytes equal
`d3`'s on all 86 case-views. Sweeps (`tests/sweep.sh --jobs 3`, 15-character workdirs): pristine `/tmp/r11u225_wP`, law
`/tmp/r11u225_wL`; every `slang:` line of every `cmds.txt` names its sweep's binary (3273 of 3273 each). Both sweeps
exit 1 on the tests/LAWS.md staleness alone (the new law names; the patch carries the regenerated file); every compare
stage reads regressions=0.

## 2. InterfArrayBind d: § ifArrElemLitCaFresh225 (switch `R11U225_IFARRELEMCA_OFF`, ModuleEmit `emitContAssigns`)

**The head at the base** ([evidence/heads/InterfArrayBind_default_pristine.txt](evidence/heads/InterfArrayBind_default_pristine.txt)):

```
#183 fullname
  A: 5  ref_obj  IO_ONES  work@soc_tb.peripheral_io_bus[IO_ONES].write_en.IO_ONES  dut.sv 16 30 16 37   <- golden
  B: 5  ref_obj  IO_ONES  work@soc_tb.IO_ONES                                       dut.sv 16 30 16 37   <- ours
```

`assign peripheral_io_bus[IO_ONES].write_en = 32'hffffffff;` at module scope. The elaborated listing's index reference.
The landed § elabIfArrIdxChainName205 (ExprEmit) already writes golden's name for an elaborated-view Lhs, but our
elaborated listing never emitted one: ModuleEmit `emitContAssigns` SHARED the definition cont_assign (its share branch,
`cas->push_back(defInfo->contAssigns[myIdx])`, for a non-plain, non-dotted left side), and the `ifaceDotFresh` branch
that re-emits interface-member targets looks the base up as `body.find("peripheral_io_bus[IO_ONES]")`, which finds
nothing for an array element.

**Surelog's rule** (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp `UhdmWriter::writeCont_assign`, the
`if (simplified == false)` branch): every elaborated cont_assign's right side is reduced; when the reduce yields a constant
(any literal does), the cont_assign is `clone_tree`d, `adjustSize(tps, ...)` runs with `tps` null for a hier_path Lhs
(so it returns the reduced constant itself), and the clone's Rhs is that constant, re-parented at the clone
(`res->VpiParent(assign)`). The clone's Lhs is a fresh hier_path whose index reference computes its full name through
the path (the name § elabIfArrIdxChainName205 transcribes). A right side that reads a signal is not reduced to a
constant, so the definition object is kept (golden a03, a07: shared, and ours already shared).

**The law**: in the elaborated view, a continuous assignment whose left side is a member of an INTERFACE-ARRAY element
(`b[i].m`, the base an instance array of interfaces in the module body) and whose right side is a literal, with no
delay, is emitted as a fresh cont_assign (the definition's span and strengths) whose Lhs is emitted by `emitExpr` in the
elaborated view (so § elabIfArrIdxChainName205 names the index) and whose Rhs is the definition's constant OBJECT. An
enum-constant selector binds its enum_const through the instance body (`pendingEnumIdxRefs`; the emitter's own lookup
reads the stale `currentScope`, RESUME section 9, and left the elaborated index unbound: a stage-1 break of the first
draft on a01/a04, fixed before delivery). Traced `ifArrElemLitCaFresh225 <instance>` (and `nolhs` on the fallback,
which never fired).

## 3. OutputSize... d/t: the struct-member substitution (TypeEmit `emitInitHier`, ModuleEmit's unbased-fill fold)

**The head at the base** ([evidence/heads/OutputSize_default_pristine.txt](evidence/heads/OutputSize_default_pristine.txt), 8 objects):

```
#169 line      A: 7 hier_path Info.x  dut.sv 17 11 17 26   B: 7 hier_path Info.x  dut.sv 15 37 15 43
#172 col       A: 8 ref_obj   Info    dut.sv 15 42 15 43   B: 8 ref_obj   Info    dut.sv 15 37 15 41
#220 line      A: 8 hier_path Info.x  dut.sv  4 18  4 23   B: 8 hier_path Info.x  dut.sv 15 37 15 43
#221 fullname  raw fullname A: Info.x | B: work@top.u_otp_ctrl_ecc_reg.a.Info.x
#223, #234, #237: the same span pair on the port's copy
#242 decompile A: 4 constant dut.sv 6 15 6 17 '1 -1 BIN:1 3   B: 4 constant dut.sv 6 15 6 17 65535 16 UINT:65535 9
```

`localparam int NumScrmblBlocks = Info.x;` (a struct parameter's member) read by `logic [NumScrmblBlocks-1:0] data` and,
through the override `.Depth(NumScrmblBlocks)`, by the child's `output logic [Depth-1:0] a` with `assign a = '1;`. What
the plugin reads here: `get_src_attribute` (module.cpp) reads VpiFile/line/col of every object it names; the fill
constant is read by expression.cpp's `size == -1` branch (`'1` self-replicates to the context width), so the kept literal
and the folded 65535 give the same RTLIL: the downstream lane was IDENTICAL before and stays IDENTICAL.

Three laws, each decoded on the grid cases/OS (golden = the pinned Surelog; section 4):

* **§ initHierAtRefToken225** (switch `R11U225_INITHIERSPAN_OFF`, TypeEmit, the `emitInitHier` lambda of the
  member-initialized parameter bound): Surelog substitutes the parameter's value for the reference: golden's hier_path
  spans the REFERENCE it replaces (`NumScrmblBlocks` 17:11-26; the child's `Depth` 4:18-23; o02's `N` in `[N-1:0]` and
  `[N:0]`), and its elements carry the value's own spans in the parameter-initializer path shape (the base `Info` on the
  member token 15:42-43, exactly the param_assign copy's records at the base). The law emits the initializer under the
  parameter-initializer flags (`inParamInit`, the shape ExprEmit's landed `paramInitStructMember` branch writes; the same
  flag set as the sibling `emitSymCall` of this function) and sets the hier_path's span to the reference's
  (`NamedValueExpression::sourceRange` of the bound's parameter reference). Traced on every emission (`emit <owner>`)
  and on every hier_path result.
* **§ initHierCaLhsBareName225** (switch `R11U225_INITHIERCANAME_OFF`, TypeEmit, same site): the substituted path's
  ref_typespec is named `<owner full name>.<path>` in golden (`work@top.data.Info.x`) EXCEPT when the declared signal is
  the whole left side of a continuous assignment of its own MODULE scope, where golden keeps the bare path name
  (`Info.x`): o03 (a child net written by `'1`, and the port written from it), o08 (a top-level net written by `'1`),
  o11 (written from a port); the controls keep the scoped name: o10 (written by a process), o13 (the child port written
  by a process), o18 (a concatenation left side), o20 (an interface's `assign v = '1;`: golden `work@top.u.v.Info.x`).
  The mechanism is the writeCont_assign clone of the net's binding (not located further); the rule is transcribed from
  the grid.
* **§ initHierFillKept225** (switch `R11U225_INITHIERFILL_OFF`, ModuleEmit, the elaborated unbased-fill fold of
  `emitContAssigns`): a `'1` onto a whole signal whose packed range carries such a substitution keeps the literal as
  written (`'1`, BIN:1, size -1, the definition's constant object). Surelog's writeCont_assign reduces the Rhs and calls
  `CompileHelper::adjustSize` (CompileHelper.cpp), whose `Bits(ts, invalidValue, ...)` of a range bounded by the
  unreducible `Info.x` path comes back invalid, so `size` stays the literal's own (`if (!invalidValue) size = sizetmp;`)
  and nothing is masked; golden o01, o03, o08 (both views: the elaborated view of o01, o03 and o08 was stage 1 at the
  base on this constant and is EQUAL now). The signals are recorded by the TypeEmit site (src/R225.h
  `initHierOwners225`, declaring scope and name; an empty vector until the substitution fires, so a design it never
  reaches allocates nothing: § formalRegNoHeap223v's lesson) and read here; the fresh cont_assign carries the
  definition's constant object, and the over-64-bit re-encode of § caNonTernFoldEnc27 skips it.

## 4. The grid (cases/IA 23 cases, cases/OS 20 cases, both views; [evidence/grid_law.txt](evidence/grid_law.txt), [evidence/switches.txt](evidence/switches.txt))

drivers/grid.sh runs each case in both views with pristine, the law binary, and the law binary under `R11U225_OFF`;
drivers/switches.sh runs the law binary under each single switch.

**Totals: 86 case-views, 29 enter EQUAL (IA 11, OS 18), none leaves EQUAL, 60 move bytes, `R11U225_OFF` gives
pristine bytes on all 86.** Per switch: `R11U225_IFARRELEMCA_OFF` restores pristine bytes on every IA case-view the law
moves and moves no OS case-view; the three OS switches move no IA case-view, and each drops its own law alone (o02, o10,
o13, o17 move only under `INITHIERSPAN_OFF`; o06, o11 under `INITHIERSPAN_OFF` and `INITHIERCANAME_OFF`; o01, o03, o08
under all three).

| case | shape (law) | parse view: pristine -> law | elaborated view |
|---|---|---|---|
| IA/a01 (r11u220 IA/i01) | enum selector `b[E0].w = 1'b1` (ifArrElemLitCaFresh225) | fullname -> **EQUAL** | EQUAL, EQUAL |
| IA/a02 (i02) | localparam selector | fullname -> **EQUAL** | EQUAL, EQUAL |
| IA/a03 (i03) | right side reads a port (control: shared) | EQUAL, bytes same | EQUAL |
| IA/a04 (i04) | vector member `b[E0].v = 4'h3` | fullname -> **EQUAL** | EQUAL |
| IA/a05 (i05) | a bit select of the member `b[K].v[1]` (another branch) | stage 1, bytes same | stage 1, same |
| IA/a06 (i06) | the target inside a child module | fullname -> **EQUAL** | EQUAL |
| IA/a07 (i07) | an operation reading a port (control) | EQUAL, bytes same | EQUAL |
| IA/a08 (i08) | the right side a parameter (not a literal) | type, bytes same | type, same |
| IA/a09 | a numeric selector `b[1]` | EQUAL -> EQUAL (bytes move: the fresh object) | EQUAL -> EQUAL |
| IA/a10 | `'1` and an unsized decimal | fullname -> **EQUAL** | fullname -> **EQUAL** |
| IA/a11 | a two-dimensional interface array (not reached) | stage 1, bytes same | stage 1 |
| IA/a12 | an interface-array PORT, modport-qualified (not reached: an interface port, residue 11.6) | fullname, bytes same | EQUAL |
| IA/a13 | the module instantiated twice | fullname -> **EQUAL** | EQUAL |
| IA/a14 | a delayed assignment (excluded) | fullname, bytes same | EQUAL |
| IA/a15 | a comma list | fullname -> **EQUAL** | EQUAL |
| IA/a16 | inside a generate block (another branch) | stage 1, bytes same | stage 1 |
| IA/a17 | a module bound by `bind` holding the array | fullname -> **EQUAL** | EQUAL |
| IA/a18, a19 | a package enum selector, unqualified / qualified | stage 1 -> stage 1 (the same first path, bytes move) | stage 1 |
| IA/a20 | a parameter-expression selector `b[K-1]` | fullname -> **EQUAL** | EQUAL |
| IA/a21 | a module instance array (control: not an interface) | EQUAL, bytes same | EQUAL |
| IA/a22 | an interface holding the interface array (not reached) | stage 1, bytes same | stage 1 |
| IA/a24 | two files (`args`), the same shape in both | fullname -> **EQUAL** | EQUAL |
| OS/o01 | the row's own source (all three) | line -> **EQUAL** | stage 1 -> **EQUAL** |
| OS/o02 | top only, `[N-1:0]` and `[N:0]` (span) | line -> **EQUAL** | line -> **EQUAL** |
| OS/o03 | child net and port written by assign (all three) | line -> **EQUAL** | stage 1 -> **EQUAL** |
| OS/o04, o09 | plain integer override / plain localparam chain (controls) | EQUAL, bytes same | EQUAL, bytes same |
| OS/o05, o19 | `'0` (and `'z`) fills onto the substituted width | stage 1 -> stage 1 (head: the `'0` size, residue 11.4) | same |
| OS/o06 | `'x` onto the child port `[Depth:0]` | line -> **EQUAL** | line -> **EQUAL** |
| OS/o08 | top-level `'1` (all three) | line -> **EQUAL** | stage 1 -> **EQUAL** |
| OS/o10 | written by a process (control for the name) | line -> **EQUAL** | line -> **EQUAL** |
| OS/o11 | written by assign from a port | line -> **EQUAL** | line -> **EQUAL** |
| OS/o12 | a net declaration assignment of `'1` (not reached: residue 11.4) | stage 1 -> stage 1 | same |
| OS/o13 | a child port written by a process (control) | line -> **EQUAL** | line -> **EQUAL** |
| OS/o14 | a nested member `Info.a.b` (not reached: the member resolver declines) | stage 1, bytes same | same |
| OS/o15 | a package struct parameter `p::Info.x` | stage 1 -> stage 1 (the same first path) | same |
| OS/o16 | inside a generate block | type -> type (golden folds the bound there; the same record) | same |
| OS/o17 | a select left side | line -> **EQUAL** | line -> **EQUAL** |
| OS/o18 | a concatenation left side (control: scoped name) | line -> fullname (the pre-existing declarator name, `d1` for golden's `d2`) | same |
| OS/o20 | an interface instance (control) | line -> fullname (the pre-existing empty-owner name) | stage 1 both |
| OS/o21 | two instances of the child, two widths | stage 1 -> stage 1 (the same first path) | same |

Every stage-1 case-view that moves keeps its first differing path and its uhdm-cmp line count (o05 36, o15 68, o19 36,
o21 90/94, a18 19, a19 100 on both binaries); o18's and o20's new first records existed at the base behind the cleared
line records (the declarator naming of a shared list typespec, and the empty-owner name the interface typespec gets).

## 5. The gates ([evidence/final/](evidence/final/))

| gate | result |
|---|---|
| (1) build | `pristine` = the main tree's md5 `abaa83b8…`; `law` `3e172272…` |
| (2) probe | **regressions=0 conversions=0 changes=0**, EQUAL 3448 / STRICT_NOTEQUAL 639; the probe csv byte-identical to results/golden_probe.csv and to the pristine sweep's |
| (3) surelog | **regressions=0 conversions=1 changes=0** (InterfArrayBind default); 930 CMP_EQUAL + 24 STRICT_NOTEQUAL |
| (3) uhdm2rtlil | **regressions=0 conversions=2 changes=0** (OutputSize... d/t); 1602 CMP_EQUAL + 4 STRICT_NOTEQUAL |
| (4) downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**, verdict diff 0 against the baseline and the pristine sweep (the two csvs identical) |
| (5) uhdm-cmp | 0 lines, rc 0 on all five moved corpus row-modes; strict: InterfArrayBind d `STRICT_EQUAL 186 objects`, t `96`, OutputSize d `259`, t `169`; Scoreboard d `STRICT_NOTEQUAL file` as at the base |
| (6) byteverify | tools/probe/r11v75repro/byteverify.sh on hard-link mirrors without the 8 fenced row-mode databases (drivers/bvmirror.sh, `fenced_skipped=8` per side): PATH_SETS_IDENTICAL (2560), **MOVERS 5 / 2560**, SELFCHECK 2559 / 2560 flagged |
| canaries | tools/probe/r11u107repro/canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh` (surelog) PASS, `EXPECT_UNKNOWN=6 ctcan2.sh` (uhdm2rtlil) PASS |
| binaries | all 3273 `slang:` lines of the pristine sweep name `/tmp/r11u225_bin/pristine`, all 3273 of the law sweep `/tmp/r11u225_bin/law` |

## 6. Movers, predicted by name before the law sweep ([evidence/census/prediction_frozen.txt](evidence/census/prediction_frozen.txt), [evidence/final/movers.txt](evidence/final/movers.txt))

The firing census (drivers/census.sh: the law binary with `R11U225_TRACE` over every corpus row-mode but the fenced
ones, `--filter` built from `$FENCED`, every probe case, and every downstream lane) wrote one trace file per process that
fired, naming its output database; every branch of every law traces (the span law on every emission under its flags,
whatever the result; the interface-array law on its fallback too). drivers/predict.py turned them into the prediction,
frozen before the law sweep (md5 `8d9896b852ab7f1a284a97cff5c2be5d`): **5 databases**:

```
downstream/OutputSizeWithParameterOfInstanceInitializedByStructMember initHierAtRefToken225:6 initHierCaLhsBareName225:1 initHierFillKept225:1
surelog/default/InterfArrayBind ifArrElemLitCaFresh225:1
surelog/testflags/InterfArrayBind ifArrElemLitCaFresh225:1
uhdm2rtlil/default/OutputSizeWithParameterOfInstanceInitializedByStructMember (the same three laws, 6/1/1)
uhdm2rtlil/testflags/OutputSizeWithParameterOfInstanceInitializedByStructMember (the same)
```

No probe case fires (none of the 4087 has an interface-array element target with a literal right side at module scope,
or a struct-member-initialized parameter in a packed bound). **The byte movers of the two gate sweeps are exactly these
5** (drivers/movers.sh, movers_ds.sh: 0 of 4087 probe databases, 1 of 805 downstream lanes) **plus Scoreboard default**,
which no law fired on: its dumps are identical line for line, its objects identical in id order
(drivers/tool/idlist.cpp: 0 lines), and 38 strings of the symbol table's tail come in another order
(drivers/tool/symlist.cpp): the pre-existing address-order coin of § refFullNameThroughNamedExpr175 (section 9: the
pristine binary draws the law sweep's Scoreboard hash itself).

## 7. The away-moved-record census ([evidence/away_canonical.txt](evidence/away_canonical.txt), drivers/awayall.py)

Every database whose bytes differ between the pristine and the law sweep (5), walked with its golden by the gate's
comparator, each record keyed by its ancestor chain and flat: **chain_lost=0 chain_toward=15 flat_lost=0 flat_toward=15
flat_unpaired=0** (InterfArrayBind d 1, OutputSize d 7 and t 7; InterfArrayBind t and Scoreboard d 0 and 0). **Positive
control**: the census reversed (law as OFF) reads chain_lost=15 ([away_canonical_reversed.txt](evidence/away_canonical_reversed.txt)).
(The canonical walk leaves the full name out inside a typespec subtree, so OutputSize's eighth record, the raw full name,
is not counted by either key.)

## 8. Downstream ([evidence/ds_cases.txt](evidence/ds_cases.txt))

The gate sweep: 803 / 66 / 2 / 0, verdict diff 0; the only moved slang lane (OutputSize...) writes RTLIL, the nohier
RTLIL and the synthesized netlist byte-identical to the Surelog lane's and to pristine's. The grid cases through
scripts/downstream_uhdm2rtlil.py's own `one()` with each binary (drivers/dscases.py, a fresh `GOLDEN_CACHE`; a24 left out:
the case command line reads `dut.sv` alone): 42 cases, **no verdict changes**: 37 IDENTICAL on both, IA/a11 and OS/o15
DIVERGENT on both (a two-dimensional interface array; a package struct parameter), OS/o05, o19, o21 EQUIVALENT on both
(the `'0` fill onto a substituted width: residue 11.4, downstream-visible). No case leaves IDENTICAL.

## 9. Determinism ([evidence/det_law.txt](evidence/det_law.txt), [evidence/det_pris.txt](evidence/det_pris.txt), drivers/det.sh)

Three concurrent harness runs per binary on Earlgrey_0_1 and the five UVM rows in both modes:

| row-mode | pristine (3 draws) | law (3 draws) |
|---|---|---|
| Earlgrey_0_1 d / t | 1 hash each | 1 hash each (the same as pristine's) |
| MiniAmiq d | 1 (`accabd75`) | 1 (`accabd75`) |
| MiniAmiq t | 1 (`1d91262b`, where the pristine gate sweep drew `accabd75`) | 1 (`accabd75`) |
| SeqDriver d / t, SimpleUVM d / t, BuildUVMPkg d / t | 1 hash each | 1 hash each, the same as pristine's |
| Scoreboard d | 2 (`1a416c8d` twice, `25e129dc`) | 3 (`1a416c8d`, `25e129dc`, `44613c73`) |

Every UVM and Earlgrey row-mode the laws do not fire on draws pristine's hashes; the two coins are pre-existing:
MiniAmiq testflags' symbol-table order (r11u221's MiniAmiq coin; here the PRISTINE binary drew the minority hash) and
Scoreboard default's (pristine draws `1a416c8d`, the law sweep's "mover" hash, itself). The laws allocate nothing in a
design they do not reach (the owner registry is an empty vector until the substitution fires; the interface-array law
builds its strings only for a literal right side onto a hierarchical target).

## 10. Fence and process

* **The fence**: every driver that reads corpus sources or databases takes the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh and fails closed (drivers/env.sh, case.sh, census.sh with `--filter` built from
  them, predict.py, movers.sh, movers_ds.sh and bvmirror.sh skipping the fenced row-mode directories unread (8 per
  sweep), awayall.py, det.sh, uvmdist.sh, dscases.py). The gate sweeps dispatched every row, as the gate mandates; their
  csv verdicts are the only fenced facts used, and none is cited here. A grep of this directory for the four names reads 0.
* **Two unset-variable incidents (the pass-223 mechanism), no file written**: twice in the decode phase a one-off shell
  line called `$UHDM_DUMP gold_*/golden.uhdm` in a shell where the pins were not sourced (my own scratch directories
  /tmp/r11u225_s/g/scr_x/os and .../scr_x/E/e04), so bash executed the cached golden database as a script; both times
  it stopped at a syntax error before any redirection (`unexpected EOF while looking for matching` / `syntax error:
  unexpected end of file`), and a listing of both directories and a search for zero-byte files newer than the pass's
  start over its scratch and worktree found nothing. From then on every dump went through drivers/dump.sh, which
  sources the pins and refuses a non-executable tool; drivers/env.sh and case.sh refuse to run with any tool variable
  unset or non-executable.
* **Process**: the pristine binary was frozen before any edit; the prediction was written after the last law and frozen
  (md5 above) before the law sweep; the two gate sweeps ran one at a time; builds ran `-j 1` whenever `free -g` showed
  less than 6 GB available, `-j 2` otherwise; no process of another pass was touched.

## 11. Residues, ranked (the brief's items)

1. **Item (1) `UVM_SEQ_ARB_TYPE`, the first record of MiniAmiq d/t and SeqDriver d/t** (decoded further, not written;
   [evidence/heads/MiniAmiq_default_pristine.txt](evidence/heads/MiniAmiq_default_pristine.txt),
   [MiniAmiq_default_records_24913_*.txt](evidence/heads/)). Two records differ at the head, not one: golden's
   definition listing holds `set_arbitration`'s formal at the PROTOTYPE's token 332:40-56 where ours holds the
   definition's 1381:51-67, and golden's alias ref_typespec there expands to the aliased `uvm_sequencer_arb_mode`
   (depth 7) where ours carries no actual under it (the walk diverges at #24917). The small shapes
   ([evidence/decode/X_externalias](evidence/decode/X_externalias), x1-x9) are all stage 1 at the base where the formal
   reads an alias (x1, x3, x5-x8) and STRICT_EQUAL where it reads the enum itself (x2, x9) or the method is in-body
   (x4): the uhdm-cmp head is the elaborated package's typedef `Instance` link, golden's the elaborated (top) package,
   ours the definition package for every typedef of the top listing except a relocated enum
   ([pkglist.txt](evidence/decode/X_externalias/pkglist.txt), drivers/tool/pkglist.cpp); the alias is reached through
   the class method's formal only when it is the formal's type, so the judge never saw it before. **A judge-equal grid of
   the alias shape needs that link first (ground B: the top-package typedef listing in UhdmExporter / TypeEmit), then
   the writer exception of § tfArgClassMethodOrder176** (an out-of-body definition of an extern method is no writer of an
   alias; the prototype's populate is).
2. **Item (2) `this_type`, the first record of SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t** (not decoded to a rule):
   Surelog's design-wide fallback is `CompileHelper::compileDatastructureTypespec` (CompileType.cpp): the component's
   data types, then class definitions by `lib@name`, `component::name`, the parent scope's `::name` and the bare name,
   the parameters, the param_assigns, the interface ports, and last the first FileContent in
   `Design::getAllFileContents()` (a vector in file order) whose `getDataType(name)` answers (`insertDataType` is an
   `emplace`, so the first insertion of a name wins). Four small shapes with two and three classes declaring `this_type`
   in several orders ([evidence/decode/T_oobthistype](evidence/decode/T_oobthistype), t01-t04) all bind the method's OWN
   class's typedef in golden (and are stage 1 at the base for other reasons), so the UVM binding to
   `uvm_algorithmic_comparator`'s `this_type` needs a UVM-shaped reduction (parameterized base classes, `extends`, the
   include structure of uvm_pkg.sv) before a rule can be written.
3. **Item (3) module-scope formals of an imported scalar typedef** (v11u223 a07, a12, a31, re-measured, not written):
   golden mints a per-formal copy named by the WRITTEN name (`UVM_FILE`, not `p::UVM_FILE`) at the formal's token with a
   Typedef_alias to the package typedef, AND the call argument's ref_obj takes that copy as its typespec (a12's
   `a` in `h(a)`: golden `ref_typespec(work@top.a) -> int_typespec UVM_FILE 7:28-36`), where ours shares the import copy
   `p::UVM_FILE` at 3:11-14 on both. An extension of § tfArgScalarTdWriter223 (UhdmExporter's late pass) must re-point
   the call arguments too; typedefs of scalar typedefs, package-qualified scalar formals and pass 219's x03 as carried.
4. **The `'0` / `'z` fill and the net declaration assignment onto a substituted width** (OS/o05, o19, o21, o12; o05,
   o19, o21 EQUIVALENT downstream): golden keeps `'0` unsized (size -1) in both listings, ours sizes the DEFINITION
   constant at the instance width (ModuleEmit's def-view `'0` sizing, which runs before the substitution is recorded);
   the net declaration's `'1` (o12) folds in another ModuleEmit branch. § initHierFillKept225's rule, not reached there.
5. **Earlgrey_0_1 d/t `fullname(19)`** (attributed, [evidence/heads/Earlgrey_0_1_default_pristine.txt](evidence/heads/Earlgrey_0_1_default_pristine.txt)):
   #106660-#106722 six ref_typespec full names inside flash_ctrl's `region_cfgs[8]` typespec copy (golden
   `work@flash_ctrl`, ours `region_cfgs[8]`) and #119021-#121124 seven more (`work@flash_ctrl` for the port-scoped
   names ours writes: TypeEmit's typespec-copy naming, this ground), #121994 and #123996 hier_path index names
   (ExprEmit, ground A), #122230 a package parameter constant's column (ground A's qualifier span), #123519 a
   logic_typespec end column (TypeEmit), #123586 a genvar-scoped name, #130430 the structural record (a range where ours
   holds a ref_typespec). No single law converts it.
6. **Not reached by this pass's laws** (grid): an interface-array PORT target (IA/a12, `bi.mp pb[2]`), a
   two-dimensional interface array (a11), an interface holding the array (a22), a generate-block target (a16), a
   delayed assignment (a14); a nested member path (OS/o14), a package struct parameter (o15), the generate-block bound
   golden folds (o16).
7. **Invisible deviations**: golden re-parents the shared definition constant at the elaborated clone
   (`res->VpiParent(assign)`) for both the interface-array law and the fill law; ours leaves it parented at the
   definition cont_assign (uhdm-dump prints the same header, no comparator or plugin reads it).
8. **Carried, not attempted**: item (4)'s `$size` faces (parse-view fold, parameter arrays, the fixed-then-associative
   element type), item (5)'s nested-class writers (ModuleEmit enumImportParentDrain180) and BuildUVMPkg #26855 (it is the
   `this_type` head, item 2), item (6) (based range bounds in TypeEmit makeTypespec, formal columns in macros,
   cfg_func_width_loop #464 and struct_param_func_config's heads, both followed by a structural record:
   `line(3)` then a kept call at #382, `fullname(5)` then #1274), item (7) (the address-order loop, ground A).

**The sister's ground**: none of this pass's faces needed ExprEmit, EmitHelpers.h, StmtEmit.cpp or ParamEmit.cpp; the
interface-array law reuses ExprEmit's landed § elabIfArrIdxChainName205 by emitting an elaborated Lhs, and the span law
reuses ExprEmit's landed `paramInitStructMember` branch by setting the parameter-initializer flags.

## 12. Files

* **cases/**: IA (23: ifArrElemLitCaFresh225; a01-a08 are r11u220's IA/i01-i08, a24 two files with an `args` file),
  OS (20: initHierAtRefToken225, initHierCaLhsBareName225, initHierFillKept225; o01 is the corpus row's own source).
  Every case's first line names its law.
* **evidence/decode/**: X_externalias (x1-x9, item 1), T_oobthistype (t01-t04, item 2): each source is `dut.sv.txt`
  with an `args` file naming it, so the law index does not attach them to this pass's laws; `pkglist.txt`,
  `pristine_verdicts.txt`, `golden_binding.txt` are their measurements.
* **drivers/**: env.sh (pins, fence, tool guards), case.sh, dump.sh, pkgtd.sh, grid.sh, switches.sh, census.sh,
  predict.py, movers.sh, movers_ds.sh, bvmirror.sh, awayall.py, det.sh, uvmdist.sh, dscases.py; tool/pkglist.cpp (the
  per-package listing with Instance links), tool/idlist.cpp and tool/symlist.cpp (from r11u223repro).
* **evidence/**: grid_law.txt, switches.txt, census/prediction_frozen.txt, final/ (sweep summaries, movers, rows.csv),
  away_canonical{,_reversed}.txt, heads/, ds_cases.txt, det_{law,pris}.txt.
* tests/LAWS.md regenerated (`python3 scripts/law_index.py`).

**Note (v11u225, the adversarial verification of this pass, tools/probe/v11u225repro/README.md):** OS/o21 is not a
pure "same first path" case: § initHierFillKept225 moved its `'1` away from golden (golden and pristine
`UINT:65535` size 16 on u1, the law the unsized definition constant). Surelog reduces an untyped-pattern struct
parameter, so the fill premise fails there. The refinement § fillSymbolicRootOnly225v (`R11V225_FILLSYM_OFF`) records
an owner only for a cast or typed-pattern struct value.
