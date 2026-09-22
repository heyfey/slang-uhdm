# r11u95 — the program flattens every member kind, and a loop that never runs still writes its one copy

**THREE FACES, ONE BATCH — r11u93's R0 and R1, both closed, plus the field the
first of them uncovered.
LAW A (§ `caProgramGenFlattensEveryKind95`): a PROGRAM home's generate block
contributes its `initial`/`final` constructs, its tasks and functions and its
class declarations to the PROGRAM's own vectors, in SOURCE ORDER across the
body's and the block's, because `CompileProgram::collectObjects_` has a case
for every one of those kinds and its walk descends straight through the
generate region.  r11u93 re-homed only `Net` and `Variable`, so everything else
VANISHED with the scope we stopped building.
LAW B (§ `caGenLoopZeroIterStillWritten95`): a loop-generate whose entry list
is EMPTY still has one written copy — the producer walks the syntax and never
evaluates the bound — and slang hands it over in the array's own scope, not in
`entries`, which is why reading `entries[0]` listed nothing.
§ `caProgTaskFuncInstIsElab95`: a PROGRAM's `task_func` carries the ELABORATED
program in `vpiInstance`, never the definition, because `writeProgram` is the
only one of the five definition-side writers that omits the first-writer-wins
`Instance()` stamp.**

Base commit `5a20468f`, pins per `SUPPORT_MATRIX.md` (slang upstream
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 at
`~/git-repos/Surelog/build/bin/surelog` — the canonical golden producer
`scripts/verify_golden.py` names — uhdm2rtlil corpus v0.68).

| binary | md5 | what |
|---|---|---|
| pristine | `8b04ca25ae24cab79525249c4e5390a5` | built in this pass's OWN worktree at `5a20468f`, `-j 2`, md5 taken separately — **`cmp`-identical to the main tree's `build/slang-uhdm` at `5a20468f` and to the OPS pin**, compared with `cmp`, not assumed |
| law | `e24c5248b9db1698182192bfe6f857ad` | this patch |

Both frozen `chmod 555` at immutable paths before any sweep; the four sweep
workdirs are this pass's own (`slla`/`slpr`/`u2la`/`u2pr`, same-length tags so
`byteverify.sh` can line them up) and every `cmds.txt` was audited by absolute
binary PATH.

`src/ParamEmit.cpp`, `src/EmitHelpers.h` and `src/ExprEmit.cpp` are
**UNTOUCHED** — the sister pass's ground.  The whole patch is
`src/ModuleEmit.cpp`.  `results/*.csv` READ ONLY.

---

## 1. THE SWITCHES

Five, each droppable ALONE (`SWITCHES.r11u95.txt`, summed over the whole
35-arm grid):

| switch | what it drops | ledger |
|---|---|---|
| — | pristine | 1936 |
| — | law, all switches ON | **171** |
| `R11U95_OFF=1` | all five | **1936** — EXACTLY the pristine total |
| `R11U95_PROGPROC_OFF=1` | LAW A's PROCESS face | 1129 |
| `R11U95_PROGTF_OFF=1` | LAW A's TASK/FUNC face | 776 |
| `R11U95_PROGCLASS_OFF=1` | LAW A's CLASS face | 372 |
| `R11U95_PROGTFINST_OFF=1` | § `caProgTaskFuncInstIsElab95` | 1147 |
| `R11U95_GENZERO_OFF=1` | LAW B | 487 |
| `R11U95_NETDBG=1` | the five traces, OUTSIDE every gate | — |

Stronger than the cmp-line total: with `R11U95_OFF=1` the law binary's database
is **BYTE-IDENTICAL to the pristine binary's on all 35 grid arms** (`cmp`,
35/35, 0 differing).  The patch is inert outside its gates.

The neighbour controls: the whole **r11u93 grid (53 arms) is unmoved** —
`GRID.pris` and `GRID.lawx` are line-identical apart from the PID in the
pinned-Surelog segfault message on `pa11_proggenregion`, `n11_ansistr` reads
113 on both binaries and `pa9_proggenparam` 72 on both, and the **53 databases
are `cmp`-identical**.  On the **r11v93 verifier grid** exactly the four
witnesses this pass targets move (`v4` 57→0, `v5` 64→0, `v7` 56→0, `v11`
57→0) and the other **11 databases are `cmp`-identical**.

---

## 2. QUESTION 1 — the committed witnesses re-run at `5a20468f`

`v4_proggeninit`, `v5_proggentask`, `v7_progforzero` (and `v11_progclass`
beside them) reproduce the r11v93 verifier's readings exactly on the pristine
binary — 57 / 64 / 56 / 57 cmp lines — and `v14_modgeninit`, the MODULE
control, reads 0.

The SET-WISE lines, golden against ours on the pristine binary
(`GOLD-ONLY` = what golden lists and we do not; **`OURS-ONLY` is ZERO on all
four**, so nothing we wrote was wrong — the objects were simply gone):

```
v4_proggeninit   gold=99 ours=87  GOLD-ONLY=12 OURS-ONLY=0
   \_begin: (work@dut.u_p), line:7:15, endln:9:10
   \_initial: , line:7:7, endln:9:10
   \_sys_func_call: ($display), line:8:9, endln:8:23
   \_constant: , line:8:18, endln:8:22
   |vpiProcess:  |vpiStmt:  |vpiArgument:  |vpiName:$display
   |vpiDecompile:"hi"  |STRING:hi  |vpiSize:16  |vpiConstType:6

v5_proggentask   gold=96 ours=76  GOLD-ONLY=20 OURS-ONLY=0
   \_function: (work@prg.f_gen), line:6:7, endln:6:60
   \_task: (work@prg.t_gen), line:7:7, endln:7:38
   \_int_var: (work@prg.f_gen)  \_int_typespec:  \_ref_typespec:
   \_return_stmt: , line:6:39, endln:6:45   \_constant: , line:6:46
   |vpiTaskFunc:  |vpiName:f_gen  |vpiName:t_gen
   |vpiFullName:work@prg.f_gen  |vpiFullName:work@prg.t_gen
   |vpiReturn:  |vpiStmt:  |vpiCondition:  |vpiAutomatic:1
   |vpiVisibility:1  |vpiSigned:1  |UINT:7  |vpiDecompile:7

v7_progforzero   gold=87 ours=76  GOLD-ONLY=11 OURS-ONLY=0
   \_logic_net: (work@prg.w_loop), line:6:19, endln:6:25
   \_logic_net: (work@dut.u_p.w_loop), line:6:19, endln:6:25
   \_ref_typespec: (work@prg.w_loop)  \_ref_typespec: (work@dut.u_p.w_loop)
   \_logic_typespec: , line:6:7, endln:6:18   \_range: , line:6:12, endln:6:18
   \_constant: , line:6:13  \_constant: , line:6:16
   |vpiName:w_loop  |vpiFullName:work@prg.w_loop
   |vpiFullName:work@dut.u_p.w_loop

v11_progclass    gold=100 ours=87 GOLD-ONLY=13 OURS-ONLY=0
   \_class_defn: (work@prg::C), line:6:7, endln:6:31
   \_int_var: (work@prg::C::x)  \_int_typespec:  \_ref_typespec:
   |vpiClassDefn:  |vpiVariables:  |vpiName:C  |vpiName:x
   |vpiFullName:work@prg::C  |vpiFullName:work@prg::C::x
   |vpiAutomatic:1  |vpiVisibility:1  |vpiSigned:1
```

All four are **CONVERTED to 0** by this patch, and the set-wise arbiter reads
`CONV=12 / 20 / 11 / 13` with `AWAY=0` on each.

---

## 3. QUESTION 2 — the decode, in the pinned sources

### LAW A — the program road has a case for every kind, and no generate case

`CompileProgram::collectObjects_`'s stop-point list is ONE node
(`~/git-repos/Surelog/src/DesignCompile/CompileProgram.cpp:96-98`:
`{ VObjectType::paClass_declaration }`) and its `switch` has no generate case,
so the depth-first walk (`CompileProgram.cpp:398-412`, which pushes
`current.m_child` unless the node is a stop point) DESCENDS STRAIGHT THROUGH
the generate region.  What it files on the way down is every case in that
switch:

```
paInitial_construct        CompileProgram.cpp:313  -> m_program->getProcesses()
paFinal_construct                           :326  -> m_program->getProcesses()
paFunction_declaration                      :202  -> the task/func vector
paTask_declaration                          :195  -> the task/func vector
paClass_declaration                         :275  -> the class definitions
paLocal_parameter_declaration               :257  -> the parameter vector
paNet_declaration / paData_declaration      :292 / :299   (r11u93's face)
paContinuous_assign                         :233
```

and `writeProgram` (`UhdmWriter.cpp:1795-1900`) hands each of those vectors
straight to the object: `m->Class_defns(dest_classes)`,
`m->Process(mod->getProcesses())`, `m->Task_funcs(mod->getTask_funcs())`.
Nothing on that road evaluates a generate condition or a genvar — which is why
an untaken `if (0)` arm is listed (`a8`), both arms of an `if/else` are listed
(`a9`), a two-iteration `for` lists ONE copy (`a12`), and the order is the
walk's, i.e. source order (`a5`, `a6`, `a7`).

**THE CONT_ASSIGN FACE IS NOT FLATTENED, and that is measured, not assumed.**
`paContinuous_assign` has a case at `:233` like the rest, but golden's program
carries NO `cont_assign` for a generate-block assign in ANY shape this grid
writes — `c11_proggennda` (a net-decl-assign), `c12_proggenassign` (a
standalone `assign`) and `a17_progforzeronda` (both, in a zero-iteration loop)
all read `cmp rc=0` on the BASE binary, i.e. golden has none and neither do we.
This pass therefore moves no cont_assign, and the r11u93 landing that stopped
writing them stands.

### LAW B — slang hands the zero-iteration copy over in the array's scope

`GenerateBlockArraySymbol::fromSyntax`
(`~/git-repos/slang/source/ast/symbols/BlockSymbols.cpp:908-926`) copies the
entries span FIRST and only then, when it came out empty, makes the one written
copy and adds it to the ARRAY's scope:

```cpp
    result->entries = entries.copy(comp);
    if (entries.empty()) {
        // Create block and add it so visitors can access the uninstantiated block; …
        createBlock(SVInt(32, 0, true), true);
        result->addMember(*entries[0]);
    }
    else {
        for (auto entry : entries)
            result->addMember(*entry);
    }
```

So `arr.entries` is EMPTY while `arr.members()` holds the block — and reading
`entries[0]`, which is what `programGenDecls93` did, listed nothing.  The block
carries `isUninstantiated = true`, which the r11u93 walk already declines to
test for exactly the same reason (`pa2_progif0`: an untaken arm is listed).

### § `caProgTaskFuncInstIsElab95` — one omission among five identical loops

`vpiInstance` on a subroutine is stamped FIRST-WRITER-WINS,
`if (tf->Instance() == nullptr) tf->Instance(m);`, in five places in
`UhdmWriter.cpp`: `writeModule` `:1512`, `writeInterface` `:1765`,
`writeElabProgram` `:2030`, `writeElabModule` `:4200`, `writeElabInterface`
`:4392`.  **`writeProgram`'s own loop (`:1870-1874`) sets `VpiParent` alone and
no `Instance` at all.**  A module and an interface therefore keep their
DEFINITION in the field (the def writer got there first); a program's is left
null by the def writer and filled by `writeElabProgram` with the ELABORATED
program — and an UNINSTANTIATED program, which is never elaborated, keeps the
field EMPTY.  All three readings are in the grid (`c4`, `a3`, `a21`).

---

## 4. QUESTION 3 — THE GOLDEN GRID

35 arms, every golden regenerated by the pinned Surelog v1.87, both rc values
recorded on every arm (`GRID.pris.r11u95.txt`, `GRID.lawx.r11u95.txt`;
`grid/` holds every source).

### 4a. LAW A — member kinds x program shapes

| arm | written | golden's program listing | pris | law |
|---|---|---|---|---|
| `a1_proggeninit` | an `initial` in `if (1)` | `vpiProcess` -> `initial@7:7`, its `begin` named for the ELAB home `work@dut.u_p` | 57 | **0** |
| `a2_progfinal` | a `final` | `vpiProcess` -> `final_stmt@6:7` | 43 | **0** |
| `a3_proggentask` | a function AND a task | `vpiTaskFunc` -> `work@prg.f_gen`, `work@prg.t_gen` | 64 | **0** |
| `a4_progclass` | a class | `vpiClassDefn` -> `work@prg::C`, **DEF VIEW ONLY** (the elab program lists none) | 57 | **0** |
| `a5_proginitorder` | a BODY initial ABOVE the block's | ONE vector, SOURCE order: `4:3` then `9:7` | 108 | **0** |
| `a6_proginitorder2` | a BODY initial BELOW the block's | `6:7` then `11:3` — the walk's order, not "body first" | 108 | **0** |
| `a7_progtaskorder` | body `f`, gen `f`, body `t` | `f_body@3:3`, `f_gen@6:7`, `t_body@9:3` — INTERLEAVED | 133 | **0** |
| `a8_proggeninit0` | an initial in an UNTAKEN `if (0)` | **STILL LISTED** — nothing evaluates the condition | 57 | **0** |
| `a9_proginitelse` | an initial in BOTH arms | both, source order | 65 | **0** |
| `a10_proginitnest` | nested blocks, an initial in each | both, source order (`6:7`, `10:9`) | 65 | **0** |
| `a11_proginitfor1` | loop bound 1 | one net + one initial | 57 | **0** |
| `a12_proginitfor2` | loop bound 2 | **ONE copy** of each | 57 | **0** |
| `a18_proggenmixed` | net + class + function + initial + task + final in ONE block | all of them, each in its own vector | 144 | **0** |
| `a19_progtopgeninit` | a TOP-LEVEL (uninstantiated) program | the DEF road; the `begin` is named `work@prg` | 57 | **0** |
| `a21_progtopgentask` | a top-level program, a body `f` and a gen `f` | both listed, and **NEITHER carries `vpiInstance`** | 109 | **0** |
| `a22_progtwoinsttask` | TWO instances of the same program | one shared object set, `vpiInstance` = an elab program | 135 | **0** |
| `a20_proggenparam` | a LOCALPARAM inside the block | flattened TOO (`vpiParameter LP` + its `param_assign` on the program) — **NOT CLAIMED**, §8 R0 | 72 | 72 |

### 4b. LAW B — loop bounds 0 / 1 / 2 x what the block writes

| arm | written | golden | pris | law |
|---|---|---|---|---|
| `a13_progforzero` | `for (genvar i=0;i<0;i++)` + a net-decl-assign | the net on BOTH views (`work@prg.w_loop`, `work@dut.u_p.w_loop`) | 56 | **0** |
| `a14_progforzeroinit` | + an `initial` | the net AND the process | 78 | **0** |
| `a15_progforzerovar` | a `logic [31:0]` VARIABLE | def-view NET, elab-view `logic_var` — the program's ordinary data-declaration rule, applied inside a loop that never ran | 56 | **0** |
| `a16_progforzeronest` | a NESTED block inside the zero loop | both nets, source order | 70 | **0** |
| `a17_progforzeronda` | a net + a standalone `assign` | the NET only — no cont_assign (see §3) | 56 | **0** |
| `a11` / `a12` | bounds 1 and 2, the same block | one copy either way | 57 | **0** |

### 4c. THE CONTROLS

| arm | what it holds | pris | law |
|---|---|---|---|
| `c1_modgeninit` | the same initial-in-generate in a MODULE home | 0 | **0** |
| `c2_ifacegeninit` | …in an INTERFACE home | 0 | **0** |
| `c3_progbodyinit` | the same initial in the program BODY | 0 | **0** |
| `c5_progbodyclass` | the same class in the program BODY | 0 | **0** |
| `c6_modforzero` | a ZERO-iteration loop in a MODULE home | 0 | **0** |
| `c7_ifaceforzero` | …in an INTERFACE home | 0 | **0** |
| `c9_modgentask` | a function and a task in a MODULE's generate block | 0 | **0** |
| `c11_proggennda` / `c12_proggenassign` | the r11u93 program arms | 0 | **0** |
| `c13_progtwoinstbody` | a program BODY initial with TWO instances | 0 | **0** |
| `c4_progbodytask` | a function and a task in the program BODY, **no generate anywhere** | **133** | **0** |
| `c8_modfinalgen` | a `final` in a MODULE's generate block | 29 | 29 |
| `c10_modgenclass` | a class in a MODULE's generate block | 70 | 70 |

`c4` is the arm that turned a control into a law.  It reads 133 cmp lines on
the BASE binary with a **set-wise diff of ZERO** — every object and every field
present on both sides — because the only difference is the `vpiInstance` field
on the two subroutines.  Landing LAW A's task/func face without correcting it
would have written that wrong value onto every flattened subroutine too, and it
did: the first build of this patch took `a3` from 64 to **133** and `a18` from
144 to **271**.  That is why § `caProgTaskFuncInstIsElab95` rides the same
batch.

`c8` and `c10` are MODULE-home faces nothing here claims: golden's module
carries the generate block's class as `work@sub::C` (`c10`, 13 GOLD-ONLY
lines) and names the `final`'s `begin` `work@sub.g` (`c8`, 1 GOLD-ONLY line).
Both read the same on both binaries.  §8 R1.

### the faces were found IN THIS ORDER, each uncovered by the previous closing

```
v4/v5/v7/v11   57/64/56/57   the missing processes, subroutines, classes and
                             the zero-iteration copy
a3   64 -> 133               the flattened subroutine took the DEF program in
a7  133 -> 171               vpiInstance — the face c4 was already carrying
a18 144 -> 271
                 0           § caProgTaskFuncInstIsElab95 landed; a3/a7/a18
                             AND c4 all go to 0
```

---

## 5. QUESTION 4 — the laws, gated

`src/ModuleEmit.cpp` only.  The § blocks in the source carry the full decode,
the grid and the citations; this is the shape.

* `genArrayBody95(arr)` — LAW B.  `arr.entries[0]` when the loop ran, else the
  first `GenerateBlock` in `arr.members()`.  Used by BOTH r11u93 walks
  (`programGenDecls93`) and by this pass's own, so one helper answers the whole
  law.  The trace fires BEFORE the gate.
* `programGenBlocks95(body)` — every generate block a program home writes, in
  source order, recursing through nested blocks and taking ONE syntactic copy
  of a loop.  Three faces read it.
* `programFlatProcs95(body)` — the `ProceduralBlockSymbol`s inside those
  blocks.
* **PROCESS face, ELAB road** — `emitInstance`'s `progInst` loop builds its
  procedural-block list explicitly, appends the flattened ones and re-sorts by
  source location; the existing per-block body (the ConcurrentAssertionMember
  skip, `emitProcess`, the def-view fold) is unchanged.
* **PROCESS face, DEF road** — an UNINSTANTIATED program (`progTops` ->
  `uninstProgDefs`) has no elab instance, so `emitModuleDef` emits and sorts
  there instead (`a19`, `a21`).
* **TASK/FUNC face** — `emitTaskFuncs` is called once per generate block with
  the PROGRAM as the owner and the PROGRAM's prefix, which is exactly what
  `emitGenScopes` already does for a module's gen scope; the instance arm of
  `emitTaskFuncs` APPENDS, and the listing is then re-sorted by span so the two
  groups interleave (`a7`).
* **CLASS face** — the def-view class loop collects the blocks' `ClassType`
  members beside the body's and sorts the same way.  Golden lists them on the
  DEFINITION alone, which is where this listing lives.
* **§ `caProgTaskFuncInstIsElab95`** — the def clears `Instance` on a program's
  own subroutines (the omission), and `emitInstance`'s taskFuncs share stamps
  it first-writer-wins (`if (!tf->Instance()) tf->Instance(m)`), exactly as
  `writeElabProgram` does.

**EVERY SORT IS CONDITIONAL ON SOMETHING HAVING BEEN FLATTENED INTO IT.**  A
program with no generate block, and every module, interface and package, takes
the identical code path it took before — which is what `R11U95_OFF=1` proves to
the byte on 35/35 arms.

**NO ALLOW-LIST.**  The r11v93 verifier recorded that gating the r11u93 scope
drop on "blocks we can fully re-home" cannot be written, because slang models a
loop genvar as a `ParameterSymbol` and any kind allow-list would silently push
the landed `pa4_progfor` out.  These faces widen the RE-HOME instead, which
needs no such test — and `pa4_progfor` still reads 0.

---

## 6. QUESTION 5 — THE CENSUS, and the movers predicted BY NAME

### 6a. the SOURCE census, with a positive control

`srcscan95.py` answers all three syntactic questions — a PROGRAM whose body
holds a generate construct AND one of the re-homed kinds inside it (LAWA), a
PROGRAM with a loop-generate (LAWB), and a PROGRAM that declares a task or
function at all (LAWC, the WIDEST face because it needs no generate construct)
— over every `.v`/`.sv`/`.svh`/`.vh` file in both corpora, `third_party`
INCLUDED (`CENSUS.src.r11u95.txt`):

```
Surelog/tests               LAWA=0  LAWB=0  LAWC=4
Surelog/third_party/tests   LAWA=0  LAWB=0  LAWC=7
uhdm2rtlil/test             NOTHING
POSITIVE CONTROL, this pass's grid:
   LAWA.initial=24 LAWA.final=4 LAWA.function=10 LAWA.task=4 LAWA.class=4
   LAWB=14 LAWC=12
```

**LAW A and LAW B are CORPUS-INVISIBLE**; the scanner can see them (the control
says so).  The eleven LAWC rows are named, not summarised: `ClassCons/top.sv`,
`SimpleClass/top_1.sv`, `SimpleClass/top_2.sv`, `SimpleConstraint/top.sv`, and
in `third_party` the seven ariane testbench programs
(`cb_filter_tb`, `sub_per_hash_tb`, `tb_amoport`, `tb_readport` x2,
`tb_writeport` x2).

### 6b. the EMITTER-TRACE census — the authority

`cellcen95.py` replays the harness's OWN argv per test (its `discover_*` /
`translate` / `location_args`, so a site cannot be missed because a driver
spelled a flag differently) with `R11U95_NETDBG=1`, which sits OUTSIDE every
gate.  Over both corpora
(`CENSUS.surelog.sites.r11u95.tsv`, `CENSUS.u2r.sites.r11u95.tsv`; the
NO-SITE rows are dropped, the totals and the rc histogram kept):

```
surelog     arms=1573  progProc=0 progTf=0 progClass=0 progTfInst=0 genZero=0
uhdm2rtlil  arms=1742  progProc=0 progTf=0 progClass=0 progTfInst=0 genZero=0
PREDICTED MOVERS: NONE, in both corpora.
```

The source census's four Surelog LAWC rows do NOT reach the trace, and the
reason is in golden: `SimpleConstraint`'s program lists `vpiClassDefn` and
nothing else — its `function`s are CLASS METHODS, which `emitTaskFuncs` emits
in class scope with `info == nullptr`, so they never enter the program's own
`taskFuncs`.  Traced directly through their own sweep argv, `SimpleConstraint`,
`SimpleClass` and `ClassCons` fire **0** trace lines each.  The scanner
over-approximates on purpose; the trace is the instrument that decides.

### 6c. the prediction, and what was measured

**Predicted mover set: EMPTY, by name, in both corpora and both modes.**
**Measured: `uhdm2rtlil` 0 / 1608.  `surelog` 4 / 960** — `MiniAmiq` and
`SeqDriver`, both modes each, all four the UVM family and all four the
documented pristine-nondeterministic class, attributed three independent ways
in `GATES.r11u95.txt` §4: order-blind, exactly 4 payload lines each and every
one a `UINT:`/`vpiDecompile:` LINE-NUMBER pair; trace, 0 lines on all four (and
on `SimpleUVM`, `Scoreboard` and `BuildUVMPkg`); and the PRISTINE binary drew
THREE DIFFERENT md5s in three consecutive runs of the same arm, none of them
the md5 it wrote during its own sweep.  Sharpest of the three: `MiniAmiq` and
`SeqDriver` compile the IDENTICAL argv and sources in this corpus, and the same
pristine binary still wrote `920d7c8c4d45` for one and `2fb39f8b4130` for the
other during one sweep.

---

## 7. QUESTION 6 — THE GATES, all green

`GATES.r11u95.txt` carries all six in full.  In one line each:

1. **BUILD** — pristine `cmp`-identical to the main tree at `5a20468f`
   (`8b04ca25ae24cab79525249c4e5390a5`, the OPS pin); law
   `e24c5248b9db1698182192bfe6f857ad`.
2. **GOLDENS** — 23 PASS / 0 FAIL; negative control `/bin/false` 0 / 23.
3. **uhdm2rtlil, BOTH MODES** — 788/16/67 in each, row-join PASS against
   `results/gate_uhdm2rtlil.csv`, against BOTH mode-halves of
   `results/golden_uhdm2rtlil.csv`, and against this pass's own pristine
   sweeps.  **No row moved, so none is quoted.**  (`GATES.r11u95.txt` §3
   records that the FIRST testflags sweep, run concurrently with the surelog
   sweep and three other jobs on a 15 GB machine, read 782/18/1 with harness
   errors — `[Errno 2] … cmds.txt`, `kj::ExceptionImpl`, bare `stack:` — and
   that re-running it ALONE gives 788/16/67.  The number above is the solo
   run, and the contended one is written down rather than quietly dropped.)
4. **surelog, `--mode both`** — 474/9 default and 469/8 testflags, identical
   histograms on both binaries.  Law vs this pass's own pristine sweep: exactly
   the two `LowMemLib`/`LowMemPkg` rows whose `detail` embeds the workdir path,
   `SURELOG_FAIL` on both sides.  Against the committed CSV, those two plus
   `Earlgrey_0_1`'s DUMP COLUMN in both modes — which reads the same on the
   PRISTINE sweep, i.e. the documented `uhdm-dump` timeout draw, and whose
   DATABASE is byte-identical to the OPS pins.
5. **BYTEVERIFY `SELFCHECK=1`** — u2r 0/1608, surelog 4/960, every one named
   and attributed (§6c).
6. **CANARIES** — `canaries.sh` ok=52 changed=0 against this pass's own
   pristine sweep (ok=50 changed=2 against the committed CSV, the two being
   Earlgrey's dump column); u2r ok=8 changed=0; `ctcan2.sh` PASS on both;
   `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.  Every protected
   database SAME, including `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
   `InterfaceModPort 59a365f3ce2c` and `Earlgrey_0_1 8bdf25272e08` /
   `59d0ee6d10c3`.  All seven conversion rows CMP_EQUAL in both modes.
7. **FENCES** — the four slang-fenced names: 0 occurrences in
   `git diff 5a20468f -- src include`, 0 in this directory outside
   `canaudit.sh`'s own `FENCED=` line, and no driver here dispatches one.
   `results/*.csv` never written.  `src/ParamEmit.cpp`, `src/EmitHelpers.h`,
   `src/ExprEmit.cpp` untouched.

### THE SCORE, PER CELL AND PER SUBTREE

`cacell95.py` scores `cont_assign` CELLS and `netcell95.py` net entries and
per-holder ORDER; **the r11v93 verifier's finding was that both are BLIND to
the vectors this pass moves**, so `subtree95.py` is carried beside them: it
scores every `vpiProcess` / `vpiTaskFunc` / `vpiClassDefn` entry, keyed by
(kind, name, span) AND by `vpiInstance`'s identity and the process's block
name — the two fields a name+span key would miss, and the second of which IS
§ `caProgTaskFuncInstIsElab95`.  Summed over the 35 grid arms
(`SCORE.pris.r11u95.txt`, `SCORE.lawx.r11u95.txt`):

| | pristine | law |
|---|---|---|
| CELLS DIFF / GOLD-ONLY / OURS-ONLY | 0 / 0 / 0 | **0 / 0 / 0** |
| SUBTREE MATCH | 19 | **71** |
| SUBTREE GOLD-ONLY | 57 | **5** |
| SUBTREE OURS-ONLY | 8 | **4** |
| SUBTREE ORDER-DIFF | 0 | **0** |

**MOVED-WRONG = 0** and **AWAY = 0**: the set-wise arbiter over the whole grid
(`setaway95.py`, `AWAY.r11u95.txt`) reads **CONV=321, AWAY=0**, and not one arm
has a single AWAY line.

Grid totals: **22 arms CONVERTED** (57/64/56/…/133 -> 0), **10 controls unmoved
at 0**, **3 unchanged and unclaimed** (`a20_proggenparam` 72 -> 72,
`c8_modfinalgen` 29 -> 29, `c10_modgenclass` 70 -> 70).

The 5 surviving SUBTREE GOLD-ONLY and 4 OURS-ONLY entries are on two arms and
neither is this pass's: `c10_modgenclass` (1 GOLD-ONLY, the MODULE-home class,
§8 R1) and `a22_progtwoinsttask` (2 + 2, which the JUDGE reads as `cmp rc=0`).
`a22`'s is **PRE-EXISTING and proved so**: `c13_progtwoinstbody`, a program with
a BODY initial and two instances and no generate anywhere, shows the identical
shape on the PRISTINE binary at `cmp rc=0` — golden's def view keeps the LAST
instance's copy of the shared process (its `begin` is named `work@dut.u_p2`)
and ours keeps the FIRST (`work@dut.u_p1`), which is the choice the base code
already documents ("with several instances Surelog's fold is unobserved; the
FIRST instance's copy is the one the def keeps").  §8 R3.

### THE WIDE ARM BOUNDARY

`bnd95.sh` compiles **every one of the 4298 directories under `tools/probe`
that holds a `.sv`/`.v` source** with both binaries on identical argv and
compares the databases BYTE FOR BYTE (`BOUNDARY.r11u95.txt`; subdirectory arms
included, `PROCESSED==LISTED`).  **100 arms move, and every one is accounted
for:**

* **44** are this pass's own grid arms (22 arms, each also reached through its
  `slpp_all/lib/work` copy);
* **4** are the r11u93 verifier's witnesses `v4`/`v5`/`v7`/`v11` — the targets;
* **38** are DETERMINISTIC and **named by the trace** (`R11U95PROGTFINST` on
  35, `R11U95PROGPROC` on 3);
* **3** are DETERMINISTIC with no trace line — residue R2, proved below;
* **11** are COIN: the PRISTINE binary disagrees WITH ITSELF across THREE
  consecutive runs of the same arm.

44 + 4 + 38 + 3 + 11 = 100.  Measured against golden (regenerated per arm by
the pinned Surelog), the JUDGE reads the **SAME cmp line count on pristine and
law for all 39** that produce a golden and two databases — nothing got worse on
the judge.  On the 19 whose golden regenerates cleanly, the set-wise arbiter
reads **CONV=7 AWAY=0** and the subtree arbiter, summed:

```
pristine  MATCH=1759  GOLD-ONLY=80  OURS-ONLY=116  ORDER-DIFF=10
law       MATCH=1779  GOLD-ONLY=60  OURS-ONLY=98   ORDER-DIFF=10
```

Every counter moves TOWARD golden or stands still; no arm regresses on any of
them.

The **3 remaining arms carry no trace line, and they are NOT this pass** —
they are §8 R2, proved below.

---

## 8. RESIDUES (ranked)

1. **THE PROGRAM FLATTENS ITS GENERATE BLOCK'S PARAMETERS TOO**
   (`a20_proggenparam` / r11u93's `pa9_proggenparam`, 72 cmp lines, unchanged
   by this pass).  Golden's `work@prg` carries `vpiParameter LP` and its
   `param_assign` — the localparam written inside the generate block,
   flattened by the SAME walk this pass decoded
   (`paLocal_parameter_declaration` at `CompileProgram.cpp:257`).  We write
   NEITHER: the r11u93 gen-scope drop took our copy with it, and the program's
   parameter vector is built by `emitParameters` (`src/ParamEmit.cpp`), **this
   pass's SISTER's ground, which the brief forbids editing**.  The set-wise
   arbiter reads `CONV=0 AWAY=0` on the arm (golden had the parameter and we
   never did; only the holder of our stray copy changed, back in r11u93).
   CORPUS-INVISIBLE.  **R0.**
2. **A MODULE HOME FLATTENS ITS GENERATE BLOCK'S CLASSES, AND NAMES A
   GEN-BLOCK PROCESS'S `begin` FOR THE BLOCK** — two MODULE-home faces this
   pass deliberately does not claim.  `c10_modgenclass` (70 cmp lines, 13
   GOLD-ONLY set-wise lines): golden's `work@sub` carries `class_defn
   (work@sub::C)` for a class written inside `if (1) begin : g`, and we write
   none.  `c8_modfinalgen` (29 lines, 1 GOLD-ONLY line): golden names the
   `final`'s statement block `work@sub.g`.  Both read the same on both
   binaries.  The interface home agrees with golden in every shape this grid
   writes (`c2`, `c7`).  **R1.**
3. **A POINTER VALUE LEAKS INTO AN ASSOCIATIVE ARRAY'S SYNTHESIZED RIGHT
   RANGE**, and it moves whenever the binary is relinked.  `typedef C22
   ka_cls_t[string];` makes an `array_typespec` whose `vpiRightRange` operand
   is a constant reading `|vpiDecompile:23298809 |UINT:23298809` on the
   pristine binary and `23339865` on the law binary; golden writes
   `|vpiDecompile:associative |STRING:associative` there, so BOTH are wrong and
   neither is closer.  **THE PROOF that it is the BINARY and not any r11u95
   law:** with `R11U95_OFF=1` the law binary's database on all three arms
   (`r10buvm22repro`, `r10uvm154repro`, `r10uvm185repro/grid185`) is
   BYTE-IDENTICAL to its own law-ON database and still differs from pristine —
   the switch that reproduces pristine on 35/35 grid arms cannot reach it.  The
   two values sit just above each binary's own size (pristine 23258064, law
   23310776) and the delta is a CONSTANT 41056 across all three arms and across
   two distinct constants inside one arm: a relocated image ADDRESS, not a
   computed number.  It reaches NEITHER CORPUS.  The site is a typespec face
   (the `array_typespec` range builder), not ModuleEmit's listing code, so it
   is recorded rather than fixed.  **R2.**
4. **THE DEF VIEW KEEPS THE FIRST INSTANCE'S COPY OF A SHARED PROGRAM PROCESS
   WHERE GOLDEN KEEPS THE LAST** (`a22_progtwoinsttask`, and `c13_progtwoinstbody`
   which has no generate at all).  Judge-invisible (`cmp rc=0` on both arms,
   both binaries) and pre-existing; visible only to `subtree95.py`, which reads
   the block's `vpiFullName`.  **R3.**
5. **`n11_ansistr`** (113 cmp lines, r11v90's R0) and the pass
   82/83/85/87/88/89/90/92/93 residues stand unmoved and byte-identical: the
   whole r11u93 grid is 53/53 `cmp`-identical between the two binaries.
6. **Two front-end facts** carried forward unchanged: a net declared DIRECTLY
   in a program's generate REGION segfaults the pinned Surelog
   (`pa11_proggenregion`, `golden_rc=139`), and a module instantiated in a
   program's generate block is rejected by slang while Surelog accepts it
   (`pa10_proggenmod`).  Neither teaches golden.

---

## 9. HOW TO RE-RUN

```bash
H=tools/probe/r11u95repro
GRID=$H/grid bash $H/rr95.sh <binary> <tag>          # every arm, both rc values
GRID=$H/grid bash $H/sw95.sh <pristine> <law>        # the ledger + the R11U95_OFF byte identity
GRID=$H/grid bash $H/score95.sh <tag>                # per cell, per net, per subtree
python3 $H/subtree95.py <gold.dump> <ours.dump> [--rows]   # THIS PASS'S arbiter
python3 $H/cacell95.py  <gold.dump> <ours.dump> [--rows]   # cont_assign cells
python3 $H/netcell95.py <gold.dump> <ours.dump> [--rows]   # net entries + holder ORDER
python3 $H/lister95.py  <gold.dump> [<ours.dump>]          # the SHAPE LISTER
python3 $H/setaway95.py <g.pris> <o.pris> <g.law> <o.law>  # SET-WISE AWAY
python3 $H/srcscan95.py <dir> [<dir> …]                    # the source census (+ control)
python3 $H/cellcen95.py <repo> <corpus> <binary> out.tsv   # the emitter-trace site census
bash $H/bnd95.sh <pristine> <law> <outdir> tools/probe     # the wide arm boundary
R11U95_NETDBG=1 <binary> dut.sv …                          # the five traces
SELFCHECK=1 bash $H/byteverify.sh <law_workdir> <pristine_workdir>
bash $H/canaries.sh <fresh.csv> <baseline.csv>; bash $H/ctcan2.sh <baseline.csv> <fresh.csv>
(cd $H && bash canaudit.sh canaries.sh ctcan2.sh)
bash $H/rowheads.sh <sl_workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
```
