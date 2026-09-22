# r11u93 — the program has no generate scope, and the interface port declaration keeps a net of its own

**TWO LISTING FACES, ONE BATCH — r11u92's R0 and R1, both closed, and both
turn out to be THE SAME MISSING `case` IN TWO DIFFERENT COLLECT WALKS.
LAW A (§ `caProgramGenFlattens93`): a PROGRAM home writes NO `gen_scope` at
all — every declaration written inside one is the PROGRAM's own, at its own
span, in source order, UNEVALUATED (an untaken `if (0)` arm is listed) and
UNROLLED ONCE (a two-iteration `for` lists one net) and UNDEDUPED (the same
name twice) — because `CompileProgram::collectObjects_` has ONE stop point,
`paClass_declaration`, and no generate case anywhere.
LAW B (§ `caIfacePortDeclNetMint93`): an INTERFACE's non-ANSI PORT
DECLARATION mints a net of its OWN, listed BEFORE every body declaration in
PORT-DECLARATION order, and the body's same-named declaration keeps its own —
because `CompileModule::collectInterfaceObjects_` has NO `paPort` case, so the
interface's `getPorts()` is still EMPTY when the port declaration is walked and
`setDirectionAndType`'s `found == false` arm pushes one `Signal` onto
`getPorts()` AND `getSignals()`.**

Base commit `80c9a2f5`, pins per `SUPPORT_MATRIX.md` (slang upstream
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 at
`~/git-repos/Surelog/build/bin/surelog` — the canonical golden producer
`scripts/verify_golden.py` names — uhdm2rtlil corpus v0.68).

| binary | md5 | what |
|---|---|---|
| pristine | `f8ea201098701fd023fe53946c621514` | built in this pass's OWN worktree at `80c9a2f5`, `-j 2`, md5 taken separately — **byte-identical to the main tree's `build/slang-uhdm` at `80c9a2f5` and to the OPS pin**, compared with `cmp`, not assumed |
| law | `406d16b57a8f6bd850da28e0d05d85ba` | this patch |

Both frozen `chmod 555` at immutable paths before any sweep; the four sweep
workdirs are this pass's own (`slla`/`slpr`/`u2la`/`u2pr`, same-length tags so
`byteverify.sh` can line them up) and every `cmds.txt` was audited by absolute
binary PATH.

`src/ParamEmit.cpp`, `src/EmitHelpers.h` and `src/ExprEmit.cpp` are **UNTOUCHED**
— the sister pass's ground.  The whole patch is `src/ModuleEmit.cpp` plus six
lines of `include/UhdmExporter.h`.  `results/*.csv` READ ONLY.

---

## 1. THE SWITCHES

Six, each droppable ALONE:

| switch | what it drops |
|---|---|
| `R11U93_PROGGEN_OFF=1` | LAW A: the program home's `gen_scope_array`/`gen_scope` (and its nets and cells) |
| `R11U93_PROGFLAT_OFF=1` | LAW A: listing the block's declarations as the program's own |
| `R11U93_IFPORTMINT_OFF=1` | LAW B: the port-declaration net itself |
| `R11U93_IFPORTORD_OFF=1` | LAW B: the PORT-DECLARATION order of the net and port vectors |
| `R11U93_IFPORTLOW_OFF=1` | LAW B: the port's `Low_conn` (binding and port-scoped naming) |
| `R11U93_IFPORTTYPE_OFF=1` | LAW B: the strength-erased mint's absent `vpiNetType` |
| `R11U93_OFF=1` | all six |
| `R11U93_NETDBG=1` | the three traces, OUTSIDE every gate |

`SWITCHES.r11u93.txt` is the ledger, summed over the whole 55-arm grid:

```
pristine                       2717
law, all switches ON            185     <- n11_ansistr 113 + pa9_proggenparam 72, both unclaimed
R11U93_OFF=1                   2717     <- EXACTLY the pristine total
R11U93_IFPORTMINT_OFF=1        2094
R11U93_IFPORTORD_OFF=1          215
R11U93_IFPORTLOW_OFF=1          457
R11U93_IFPORTTYPE_OFF=1         215
R11U93_PROGGEN_OFF=1           1148
R11U93_PROGFLAT_OFF=1           808
```

Stronger than the cmp-line total: with `R11U93_OFF=1` the law binary's database
is **BYTE-IDENTICAL to the pristine binary's on all 53 buildable grid arms**
(`cmp`, 53/53, 0 differing).  The patch is inert outside its gates.

The neighbour controls: `R11U90_OFF=1` moves NOTHING on this pass's arms (0 cmp
lines).  `R11U92_OFF=1` and `R11U88_OFF=1` do move them — not a leak but a
DEPENDENCY: `p7`/`pa*` stand on pass 92's program-cell drop and pass 88's
net-decl-assign listing, so switching those off re-opens the same shapes from
underneath.

---

## 2. QUESTION 1 — the committed witnesses re-run at `80c9a2f5`

`p7_proggennda`, `n3_strnonansi_if` and `n4_nonansi_plain_if` reproduce
r11u92's readings exactly on the pristine binary (56 / 102 / 110 cmp lines),
and `lister93.py` names the cells:

```
p7  DIFF work@dut.u_p    vpiNet   gold=[w_plain|3:15, w_gen|6:19]  ours=[w_plain|3:15]
    DIFF work@dut.u_p.g  vpiNet   gold=[]                          ours=[w_gen|6:19]
    DIFF work@dut.u_p.g  vpiContAssign gold=[]                     ours=[cont_assign|6:19]
    DIFF work@prg        vpiNet   gold=[w_plain|3:15, w_gen|6:19]  ours=[w_plain|3:15]

n4  DIFF work@dut.u_if   vpiNet   gold=[o|5:17, p|6:17, o|7:15, p|8:15]  ours=[o|7:15, p|8:15]
    DIFF work@ifc        vpiNet   gold=[o|5:17, p|6:17, o|7:15, p|8:15]  ours=[o|7:15, p|8:15]
    (+ port span 5:17 vs 4:16, Low_conn `work@ifc.o.o`@5:17 -> net@5:17 vs
       nameless `work@ifc.o`@4:16 -> net@7:15, and the port's `vpiTypedef`
       actual `logic_typespec`@5:10 vs @7:8)

n3  DIFF work@dut.u_if   vpiNet   gold=[o|3:17, p|4:17, p|6:15]  ours=[o|5:32, p|6:15]
    DIFF work@ifc        vpiNet   gold=[o|3:17, p|4:17, p|6:15]  ours=[o|5:32, p|6:15]
```

---

## 3. QUESTION 2 — the decode, in the pinned producer

### LAW A — the program road has no generate handling

`CompileModule::collectModuleObjects_` stops its collect walk at every generate
node (`~/git-repos/Surelog/src/DesignCompile/CompileModule.cpp:529-546`:
`paConditional_generate_construct`, `paGenerate_module_conditional_statement`,
`paLoop_generate_construct`, `paGenerate_module_loop_statement`, plus
`paGenerate_region` pushed at 542/545), and `collectInterfaceObjects_` stops at
that set plus the interface variants (`CompileModule.cpp:1027-1047`).
`CompileProgram::collectObjects_` stops at ONE node:

```cpp
std::vector<VObjectType> stopPoints = {
    VObjectType::paClass_declaration,
};                                  // CompileProgram.cpp:96-98
```

and its `switch` (`CompileProgram.cpp:148-397`) has no generate case either, so
the depth-first walk (`CompileProgram.cpp:398-412`) DESCENDS STRAIGHT THROUGH
the generate region and files the block's `paNet_declaration` /
`paData_declaration` as PROGRAM signals at their own spans, in source order.

Nothing on that road ever evaluates a condition or a genvar — which is why an
untaken `if (0)` arm is listed, both arms of an `if/else` are listed, and a
`for` loop's one written net is listed ONCE.  And because no generate handling
exists, `DesignElaboration` mints no child `ModuleInstance` for a program's
generate block, so `writeElabProgram`'s
`m->Gen_scope_arrays(netlist->gen_scopes())` (`UhdmWriter.cpp:1977`) writes
nothing; the DEFINITION view's `writeProgram` (`UhdmWriter.cpp:1795-1900`) has
no `Gen_scope_arrays` call at all.

### LAW B — the interface road has no header-port case

`compilePortDeclaration`'s `paPort` arm (`CompileHelper.cpp:1723-1782`) is what
turns a non-ANSI HEADER name into a `Signal` on `component->getPorts()`.  The
MODULE collector calls it (`CompileModule.cpp:613`, `case VObjectType::paPort:`).
**The INTERFACE collector has no `paPort` case at all** — its switch runs
`paPort_declaration`, `paAnsi_port_declaration`, `paNet_declaration`,
`paGenerate_begin_end_block`, … and never `paPort:`.

So when the interface road reaches `output [31:0] o;` and calls
`setDirectionAndType` (`CompileHelper.cpp:1615-1697`), `module->getPorts()` is
STILL EMPTY, `found` stays false, and the `found == false` arm
(`CompileHelper.cpp:1673-1682`) pushes the SAME fresh `Signal` onto BOTH
`getPorts()` and `getSignals()`.  The body's `wire [31:0] o = 32'd12;` then
pushes its OWN `Signal` (`compileNetDeclaration`, `CompileHelper.cpp:2184-2206`),
and the dedup that closes the DEFINITION collect
(`CompileModule.cpp:1519-1531`) only appends PORTS MISSING FROM the signal
list, so it removes neither.  `writeInterface` (`UhdmWriter.cpp:1679`) hands
`mod->getSignals()` to `writeNets` in that order and every entry becomes a net
(`UhdmWriter.cpp:889`).

Three consequences follow from the same reading and were each measured:

* **the ORDER is the PORT DECLARATION's, not the header's** — the `Signal`s
  were created when the DECLARATIONS were walked.  `pb16_ifdeclorder` writes
  `interface ifc (p, o);` above `output o; output p;` and golden lists
  `[o@3:17, p@4:17, …]`.  `getPorts()` was filled by the same arm, so the PORT
  vector obeys the same order.
* **the `Low_conn` binds the PORT-DECLARATION net and keeps its name** —
  `writeNets` fills `p->Low_conn()` on the FIRST signal of that name
  (`UhdmWriter.cpp:846-856`) and the second pass finds it non-null and keeps
  its `Actual_group` (`UhdmWriter.cpp:857-869`); and `writeInterface` **never
  calls `mapLowConns`**, which is exactly what OVERWRITES it on the module road
  (`UhdmWriter.cpp:1459` vs its absence at 1681) with a NAMELESS ref anchored at
  the header.
* **a mint whose body declaration the STRENGTH law erased carries NO
  `vpiNetType`** — the port `Signal` is typed by `compileNetDeclaration`'s
  `portRef->setType(fC->Type(NetType))` loop (`CompileHelper.cpp:2157-2163`),
  and the declaration that loop never reached is the one
  § `caNetDeclStrengthDropped90` removed.  `n3` golden: `o` (strength) prints
  `vpiName`/`vpiFullName` and nothing else, `p` (plain `wire`) beside it prints
  `vpiNetType:1`.

---

## 4. QUESTION 3 — THE GOLDEN GRID

55 arms, every golden regenerated by the pinned Surelog v1.87, both rc values
recorded on every arm.  `GRID.r11u93.txt` is the table; `grid/` holds every
source.

### 4a. LAW A — program generate shapes x declaration kinds

| arm | written | golden's program `vpiNet` (def AND elab alike) |
|---|---|---|
| `p7_proggennda` | `if (1)` + a net-decl-assign | `[w_plain@3:15, w_gen@6:19]` |
| `pa2_progif0` | `if (0)` | `[w_plain, w_gen@6:19]` — **UNTAKEN AND STILL LISTED** |
| `pa3_progifelse` | `if/else`, two names | `[w_plain, w_then@6:19, w_else@8:19]` — BOTH arms, SOURCE order |
| `pa12_progsamearm` | both arms declare `w_both` | `[w_plain, w_both@6:19, w_both@8:19]` — **NO dedup** |
| `pa4_progfor` | `for (genvar i=0;i<2;i++)` | `[w_plain, w_loop@6:19]` — **ONE copy** |
| `pa6_prognest` | nested blocks | `[w_plain, w_out@6:19, w_in@8:21]` |
| `pa7_progbare` | a bare named `begin : g` | `[w_plain, w_bare@6:19]` |
| `pa13_progcollide` | a gen net with the BODY net's name | `[w_dup@3:15, w_dup@6:19]` |
| `pa5_progvar` | `logic [31:0] v_gen;` | def-view NET (`vpiNetType:36`), elab-view `logic_var` — the program's ordinary data-declaration rule, applied inside the block |
| `pa8_proggenonly` | no body net at all | `[w_gen@5:19]` alone |
| `pa17_progtopgen` | a TOP-LEVEL program | same |
| `pa9_proggenparam` | a LOCALPARAM inside the block | flattened TOO (`vpiParameter LP` + its `param_assign` on the program) — **NOT CLAIMED**, see §7 R0 |
| `pa14_progvarbody` | THE CONTROL: the same variable in the program BODY | `cmp rc=0` on both binaries |
| `pa15_modgennda` / `pa16_ifacegennda` | THE CONTROLS: the same generate block in a MODULE and an INTERFACE home | `cmp rc=0` on both binaries |
| `p1`–`p9` | r11u92's program grid | `cmp rc=0` on both binaries |

Two arms teach nothing and are counted nowhere: `pa10_proggenmod` (a module
instantiated inside a program's block — **SLANG** rejects the source,
`ours_rc=3`, "cannot instantiate a module in a program") and
`pa11_proggenregion` (a net declared DIRECTLY in the generate region — the
pinned **SURELOG SEGFAULTS**, `golden_rc=139`).  An arm whose compile fails
teaches error recovery, not golden.

### 4b. LAW B — interface non-ANSI orders x anchors x views

| arm | written | golden (`work@ifc` AND `work@dut.u_if` alike) | ours at the base |
|---|---|---|---|
| `n4_nonansi_plain_if` | both body re-declarations plain | `[o@5:17, p@6:17, o@7:15, p@8:15]` | `[o@7:15, p@8:15]` |
| `n3_strnonansi_if` | a STRENGTH re-declaration of `o` | `[o@3:17, p@4:17, p@6:15]` — ONE `o`, no `vpiNetType` | `[o@5:32, p@6:15]` |
| `pb14_ifbothstr` | BOTH re-declarations carry a strength | `[o@3:17, p@4:17]` | `[o@5:32, p@6:34]` |
| `pb3_ifnoredecl` | no body re-declaration of `o` | `[o@3:17, p@4:17, p@5:15]` | `[p@5:15, o@3:17]` — the port net was in the BACK group |
| `pb4_ifrevorder` | body re-declarations in REVERSE order | `[o@4:17, p@5:17, p@6:15, o@7:15]` | `[p@6:15, o@7:15]` |
| `pb16_ifdeclorder` | header `(p, o)`, declarations `o` then `p` | `[o@3:17, p@4:17, …]` — **declaration order**, and the PORT vector too | `[…]` in header order |
| `pb17_ifonedecl` | `output [31:0] o, p;` | `[o@3:17, p@3:20, …]` — declarator order | — |
| `pb5_ifinput` | an INPUT port | same shape — not a direction | — |
| `pb7_iftwoports` | 3 ports, a plain body net between | `[o,p,r decls][o, mid, p, r body]` | body group alone |
| `pb15_ifnodim` | no packed dimension | same shape | — |
| `pb11_ifvarredecl` | the body re-declaration is a VARIABLE | elab `vpiNet=[o@3:17, p@4:17]` and the body pair in `vpiVariables`; def lists all four as nets | elab `vpiNet=[]` |
| `pb9_ifgen` / `pb8_ifmodport` / `pb10_ifnetuse` / `pb12_ifstrnonport` | a generate block / a modport / the net READ by a body assign / a strength net that is NOT a port, beside them | unchanged by any of them | — |
| `pb19_modportview` | a MODPORT PORT VIEW of the same interface | **`vpiNet` EMPTY** on `work@dut.u_s.m` — the mint is a HOME-view object | agreed at the base |
| `pb13_ifnoansiplainnouse` | THE CONTROL: no body declarations at all | `[o@3:17, p@4:17]`, port-scoped named `Low_conn` | identical (`cmp rc=0`) |
| `pb6_ifansi` | THE CONTROL: the ANSI header | identical (`cmp rc=0`) | — |
| `n1`, `n2`, `n5`–`n8`, `n10`, `m1`, `i1` | THE PASS-90/92 CONTROLS: the same shapes in a MODULE home | `cmp rc=0` on both binaries | — |

`pb18_ifnodecl` (a header port with NO port declaration, the shape where
`getPorts()` would stay empty) is **rejected by the pinned Surelog**
(`golden_rc=4`), so that branch of the decode is unreachable and is not claimed.

The faces were found IN THIS ORDER, each uncovered by the previous one closing:

```
n4  110 cmp lines   the MISSING NETS + the Low_conn
      0             MINT + ORDER + LOW landed
n3  102 -> 15       the mint's vpiNetType (the strength-erased body)
      0             TYPE landed
pb16 110 -> 30      the NET order closed, the PORT VECTOR order still open
        -> 16       (the head moved from the net to the port)
      0             ORDER extended to the port vector
pb19 144 -> 125     a PORT VIEW got two nets golden does not have
      0             the mint gated to the HOME view
```

---

## 5. QUESTION 4 — the laws, gated

`src/ModuleEmit.cpp` only.  The § blocks carry the full decode, the grid and
the citations; this is the shape.

* `collectNetOrder93(body, strPortRevert, ifacePortMint, programFlat)` — a
  WRAPPER around `collectNetOrder` (`src/EmitHelpers.h`, untouched).  It
  prepends the interface's PORT-DECLARATION group in declaration order,
  reconciles the base listing's own entry for a minted port (the
  port-declaration-only entry IS the mint, and a body entry the strength law
  erased is the declaration Surelog never filed), and merges the program's
  generate declarations into the body group by source location.
* `portDeclDeclarators93(body)` — the body's `PortDeclarationSyntax`
  declarators, in source order.  Port declarations are top-level members by
  grammar, so no recursion.
* `portOrder93(body, ifaceHome)` — the PORT vector in the same order.
* `programGenDecls93` / `programFlatDecls93` — the generate blocks' `Net` and
  `Variable` members, recursing through nested blocks, taking entry `[0]` of a
  `GenerateBlockArraySymbol` (ONE syntactic copy) and NOT testing
  `isUninstantiated` (the producer never evaluates the condition).
* `emitGenScopes` returns at the TOP for a `uhdmprogram`, before the first
  `Make` call, so nothing is minted and discarded.
* `emitPorts` (the shared def-view writer) — an interface port never `merged`s,
  binds the mint, and takes the mint's span; `emitInterfaceInstance`'s port loop
  does the same for the elaborated view, where the ref keeps its own name and
  anchor and only the actual moves.
* `ifaceMintNet93` (the six new lines of `include/UhdmExporter.h`) carries the
  mint from the net listing to the port writer.  It is CLEARED at the top of
  each interface net listing, so only the view being emitted is ever in it, and
  it is keyed by slang `Symbol*`, which no other home can collide with.

**A NULL THE GRID COULD NOT SEE.**  The first build of this patch read
`m->UhdmType()` unguarded at three sites.  `emitModuleDefPorts` passes
`DefInfo::mod`, which a definition the exporter never built leaves NULL, and
the whole grid missed it because every grid arm builds every definition.  The
WIDE BOUNDARY caught it: `MiniAmiq` went `CMP_EQUAL -> SLANG_REJECT` in both
modes, which `verify_golden.py` records for an `rc=139` SEGFAULT wearing the
last stderr warning ("no top-level modules found in design").  `gdb -batch -ex
run -ex bt` named `emitPorts` in one line.  All three sites now carry `m &&`.

---

## 6. QUESTION 5 — THE CENSUS, and the movers predicted BY NAME

### 6a. the SOURCE census, with a positive control

`srcscan93.py` answers both laws' syntactic questions — an INTERFACE with a
NON-ANSI header that also carries an input/output/inout declaration, and a
PROGRAM whose body contains a generate construct — over every `.v`/`.sv`/
`.svh`/`.vh` file in both corpora:

```
~/git-repos/Surelog/tests      files=843   interface headers=23  NON-ANSI=0  programs=11  with generate=0
~/git-repos/uhdm2rtlil/test    files=2924  interface headers=28  NON-ANSI=0  programs=0   with generate=0
```

**A census zero needs a POSITIVE CONTROL**: the same scanner, unchanged, on
this pass's own grid reads `lawB_ifaces=36  lawA_programs=28` across 64 files.
It can see.

### 6b. the EMITTER-TRACE census

`cellcen93.py` replays the harness's OWN argv per test (its `discover_*` /
`translate` / `location_args`, so a site cannot be missed because a driver
spelled a flag differently) with `R11U93_NETDBG=1`, which sits OUTSIDE every
gate:

* `R11U93IFMINT name=<n> body=<0|1> str=<0|1>` — one row per non-ANSI interface
  port reaching the interface net listing, with the body declaration's two
  facts.
* `R11U93PROGFLAT name=<n>` — one row per declaration a program home flattens.
* `R11U93PROGGEN home=<n> drop=1` — one row per program home whose generate
  scopes are dropped.

Its positive control, on the grid:

```
n4_nonansi_plain_if   2x R11U93IFMINT name=o body=1 str=0   (def view + elab view)
n3_strnonansi_if      2x R11U93IFMINT name=o body=1 str=1
pb13_ifnoansiplainnouse  2x R11U93IFMINT name=o body=0 str=0
p7_proggennda         2x R11U93PROGFLAT name=w_gen  +  1x R11U93PROGGEN drop=1
n6_nonansi_plain / m1_modnda   NOTHING — the module controls
```

The UVM family, traced test by test with the same binary:

```
MiniAmiq 0   SeqDriver 0   SimpleUVM 0   BuildUVMPkg 0   Scoreboard 0     R11U93 trace lines
```

Run over both corpora (`CENSUS.surelog.sites.r11u93.tsv`,
`CENSUS.u2r.sites.r11u93.tsv` — the NO-SITE rows are dropped, the totals and
the named sites are kept):

```
uhdm2rtlil  arms=1742  ifmint=0  ifmintBody=0  progFlat=0  progGen=0
surelog     arms=1573  ifmint=0  ifmintBody=0  progFlat=0  progGen=12
```

**`ifmint=0` and `progFlat=0` everywhere**: LAW B reaches no site at all, and
LAW A's listing face reaches no declaration at all, in either corpus.

**`progGen=12` NAMES A POPULATION, NOT A MOVER SET, and the trace over-reports
on purpose.**  `R11U93PROGGEN` prints for every PROGRAM home the gate reaches,
before it can know whether that home HAD any generate scope — so it names the
six surelog tests that instantiate a program at all (`InterfaceModPort`,
`OneNetInterf`, `OneNetModPort`, `OneNetModPortGeneric`, `OneNetRange`,
`SVSwitch`, twice each for the two modes).  None of those programs contains a
generate construct — the SOURCE census says so independently (0 programs with a
generate construct in 843 surelog files) — so there was nothing to drop, and
all twelve databases are **`cmp`-identical between the two binaries**, including
the two HARD byte pins among them (`SVSwitch` `4842211c4030`,
`InterfaceModPort` `59a365f3ce2c`).  Tightening the trace to count the scopes
first would need a rebuild; the source census and the byte comparison close the
same question from two other directions.

### 6c. the prediction

**Predicted mover set: EMPTY, by name, in both corpora and both modes.**

---

## 7. QUESTION 6 — THE GATES, all green

1. **BUILD.**  Both binaries `-j 2`, md5s taken separately.  The pristine is
   `cmp`-identical to the main tree's `build/slang-uhdm` at `80c9a2f5`
   (`f8ea201098701fd023fe53946c621514`, the OPS pin).
2. **GOLDENS.**  `tests/check_goldens.sh` with `SLANG_UHDM` exported to the law
   binary: **23 PASS, 0 FAIL**.  Negative control `SLANG_UHDM=/bin/false`:
   **0 PASS, 23 FAIL**.
3. **uhdm2rtlil, BOTH MODES.**  788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67
   SLANG_REJECT in each — the committed baseline.  Row-join `ct8rows.sh`:
   PASS against `results/gate_uhdm2rtlil.csv`, PASS against each mode of
   `results/golden_uhdm2rtlil.csv` (which holds BOTH modes, so it is split by
   mode first), and PASS against this pass's own pristine sweeps.  **No row
   moved, so none is quoted.**
4. **surelog, `--mode both`.**  474/9 default and 469/8 testflags — the
   committed baseline, status histogram identical in both modes.  Two rows
   differ against the committed CSV and both are the ENVIRONMENT: `LowMemLib`
   and `LowMemPkg`, `SURELOG_FAIL` on both sides, whose `detail` column embeds
   the workdir path —
   `[INF:CM0023] Creating log file "/tmp/m187base/sl/wd/testflags/LowMemLib-f068a766/slpp_all/surelog.log"`
   against
   `[INF:CM0023] Creating log file "/tmp/r11u93_wd/slla/testflags/LowMemLib-f068a766/slpp_all/surelog.log"`.
   Against this pass's own pristine sweep the same two rows plus
   `Earlgrey_0_1`'s DUMP COLUMN (`CMP_EQUAL,,,` against `CMP_EQUAL,,,differ`,
   both modes) — the documented `uhdm-dump` timeout draw; its DATABASE is the
   pin and it is byte-identical (below).
5. **BYTEVERIFY, `SELFCHECK=1`, against this pass's own pristine workdirs.**

   ```
   uhdm2rtlil   PATH_SETS_IDENTICAL (1608)   MOVERS 0 / 1608   selfcheck 1607/1608 flagged
   surelog      PATH_SETS_IDENTICAL (960)    MOVERS 5 / 960    selfcheck  959/960  flagged
   ```

   The five, **each named and attributed**:

   ```
   default/MiniAmiq    default/SeqDriver    default/SimpleUVM
   testflags/MiniAmiq  testflags/SeqDriver
   ```

   All five are the UVM family, and all five are the documented
   pristine-nondeterministic class, on three independent readings:

   * the **ORDER-BLIND** whole-dump diff (path-normalised, ids stripped, both
     sides sorted) reads **exactly 4 lines on every one**, and those four lines
     are always one `UINT:` / `vpiDecompile:` LINE-NUMBER pair per side — the
     class the OPS brief names.  No structural object, no vector size, no name.
   * the **TRACE** fires ZERO times on any of them, so neither law reaches a
     site in those tests.
   * the **PRISTINE binary is itself nondeterministic there**: three
     consecutive runs of the pristine binary on `MiniAmiq/default` produced
     THREE DIFFERENT md5s (`251819df8f09`, `db7b9f2717b1`, `255192fe3f84`), and
     one of the law binary's own repeat runs reproduced the md5 byteverify had
     reported as the PRISTINE side (`27419f6011b4`).  A "mover" both binaries
     draw at random is a coin, not a law.

   Their STATUS did not change: all seven conversion rows are CMP_EQUAL in both
   modes (`rowheads.sh`: SeqDriver, SimpleUVM, Scoreboard, MiniAmiq,
   BuildUVMPkg, Earlgrey_0_1 all `cmp rc=0`, 0 heads, both modes;
   SKIP-NOFILE on Scoreboard/testflags and Rggen/testflags as expected).

6. **CANARIES.**  `canaries.sh` ok=52 changed=0 absent=0 (surelog) and ok=8
   changed=0 absent=0 (uhdm2rtlil).  `ctcan2.sh` PASS on both.  `canaudit.sh`
   audited=29 UNCOVERED=0 FENCE-BREACH=0.  The protected databases, md5 against
   this pass's own pristine sweep, both modes:

   ```
   SVSwitch            4842211c4030  SAME (the OPS pin)
   YosysVerx           6ccda350c24a  SAME (the OPS pin)
   InterfaceModPort    59a365f3ce2c  SAME (the OPS pin, watched byte-for-byte)
   BlackParrotComplex  e3e354129d5a / 73a10e8217e5  SAME
   YosysOldOr          d68e0796d62c  SAME
   Earlgrey_0_1        8bdf25272e08 (default) / 59d0ee6d10c3 (testflags)  SAME (the OPS pins)
   ```

7. **FENCES.**  The four slang-fenced names: **0 occurrences in
   `git diff 80c9a2f5 -- src include`** and 0 files in this directory outside
   `canaudit.sh`'s own `FENCED=` line; no driver here dispatches one.
   `results/*.csv` never written.  `src/ParamEmit.cpp`, `src/EmitHelpers.h` and
   `src/ExprEmit.cpp` untouched.

### THE SCORE, PER CELL

`cacell93.py` (cells) and `netcell93.py` (net entries and per-holder ORDER),
summed over the 52 scorable arms:

| | pristine | law |
|---|---|---|
| CELLS DIFF | 0 | **0** |
| CELLS GOLD-ONLY | 0 | **0** |
| CELLS OURS-ONLY | 11 | **0** |
| NETS DIFF | 62 | **0** |
| NETS GOLD-ONLY | 87 | **1** |
| NETS OURS-ONLY | 11 | **0** |
| HOLDER ORDER-DIFF | 64 | **1** |

**MOVED-WRONG = 0** (no cell and no net took a value golden does not have) and
**AWAY = 0** (no arm got worse).  The one surviving GOLD-ONLY net and the one
ORDER-DIFF are both `n11_ansistr` — r11v90's R0, unclaimed, 113 cmp lines on
BOTH binaries.

Grid totals: **27 arms CONVERTED** (56/102/110/… -> 0), **22 controls unmoved
at 0**, **2 unchanged and unclaimed** (`n11_ansistr` 113 -> 113,
`pa9_proggenparam` 72 -> 72), **0 MOVED-WRONG**, 4 arms NOT GOLDEN.

The SET-WISE arbiter (`setaway93.py`, over the whole grid): **CONV=264,
AWAY=10**, and all ten AWAY lines are on `pa9_proggenparam` alone — see R0.

---

## 8. RESIDUES (ranked)

1. **THE PROGRAM FLATTENS ITS GENERATE BLOCK'S PARAMETERS TOO**
   (`pa9_proggenparam`, 72 cmp lines, unchanged by this pass).  Golden's
   `work@prg` carries `vpiParameter LP` and its `param_assign` — the localparam
   written inside the generate block, flattened by the SAME walk this pass
   decoded (`paLocal_parameter_declaration` has a case in
   `CompileProgram.cpp:257`, and the walk descends into the block).  We now
   write NEITHER: dropping the gen scope took our copy of `LP` with it, and the
   program's parameter vector is built by `emitParameters`
   (`src/ParamEmit.cpp`), **this pass's SISTER's ground, which the brief forbids
   editing**.  The ten set-wise AWAY lines are exactly that parameter and its
   assign (`|vpiName:LP`, `|UINT:7`, `|vpiLocalParam:1`, `|vpiSigned:1`,
   `|vpiDecompile:7`, `|vpiParameter:`, `|vpiParamAssign:`, `\_param_assign:`,
   `\_int_typespec:`, `\_constant:`).  The JUDGE's verdict is unchanged (72 cmp
   lines before and after — golden's program had the parameter and ours never
   did; only the holder of our stray copy changed), and the shape is
   CORPUS-INVISIBLE (0 programs with a generate construct in either corpus).
   Keeping the gen scope to keep `LP` would have been inventing an object
   golden does not have.  **R0.**
2. **THE IMPLICIT-NET MINT** (`n11_ansistr`, 113 cmp lines) — r11v90's own R0,
   re-measured and unmoved on both binaries: golden mints a bare net at the
   FIRST reference's span for a dropped name referenced by a direct member of
   its home's body.  **R1.**
3. **A NET DECLARED DIRECTLY IN A PROGRAM'S GENERATE REGION** (no block)
   SEGFAULTS the pinned Surelog (`pa11_proggenregion`, `golden_rc=139`).
   Recorded so the next pass does not re-ask; there is no golden to transcribe.
4. **A MODULE INSTANTIATED IN A PROGRAM'S GENERATE BLOCK** is rejected by SLANG
   (`pa10_proggenmod`, "cannot instantiate a module in a program") while the
   pinned Surelog accepts it.  A front-end divergence, not an exporter law;
   patching slang is out of scope.
5. The pass-82/83/85/87/88/89/90/92 residues stand unmoved and byte-identical:
   the `supply0`/`supply1`/`trireg` net type, `#(D)`'s min-typ-max wrapper, the
   delay operand tree, `#dv` / `#pk::PD`, the generate scope's missing
   `vpiDelay`, the net-DECLARATION delay written as a parameter name, the
   struct-parameter member read in a net-decl-assign, the negative package
   localparam's fold, the module home's enum-const fold width, the def-view
   enum fold, the element encodings, `i2_ifimpshape`, `j2_iftwoinst`,
   `w1_iface`, `b19_dblcollide`, `s5_ifacepath`, `v5_ifaceport`, `v6_ifacepkg`.

---

## 9. HOW TO RE-RUN

```bash
H=tools/probe/r11u93repro
GRID=$H/grid bash $H/rr93.sh <binary> <tag>            # every arm, both rc values
GRID=$H/grid bash $H/sw93.sh <pristine> <law>          # the switch ledger (R11U93_OFF must read the pristine total)
GRID=$H/grid bash $H/score93.sh <tag>                  # per-cell AND per-net/per-order totals
python3 $H/cacell93.py  <gold.dump> <ours.dump> [--rows]   # the per-cell arbiter
python3 $H/netcell93.py <gold.dump> <ours.dump> [--rows]   # per net entry + per holder ORDER
python3 $H/lister93.py  <gold.dump> [<ours.dump>]          # the SHAPE LISTER (program IS a holder)
python3 $H/setaway93.py <g.pris> <o.pris> <g.law> <o.law>  # SET-WISE AWAY (the arbiter)
python3 $H/srcscan93.py <dir> [<dir> …]                    # the source-level census (+ its positive control)
python3 $H/cellcen93.py <repo> <corpus> <binary> out.tsv   # the emitter-trace site census
R11U93_NETDBG=1 <binary> dut.sv …                          # the three traces
SELFCHECK=1 bash $H/byteverify.sh <law_workdir> <pristine_workdir>
bash $H/canaries.sh <fresh.csv> <baseline.csv>; bash $H/ctcan2.sh <baseline.csv> <fresh.csv>
(cd $H && bash canaudit.sh canaries.sh ctcan2.sh)
bash $H/rowheads.sh <sl_workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
```
