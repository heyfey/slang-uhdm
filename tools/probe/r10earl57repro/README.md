# r10earl57 — § castSizeElabScopeBind57 + § castGenScopeCaParamFreshTs57

**The 236-object `int_typespec > integer_typespec` family (LADDER1's F116,
LADDER54's 333-rung family) is GONE. Root cause: `emitInstance` never sets
`currentScope`, so every size cast written in an elaborated instance bound its
TARGET NAME in whatever DEFINITION was compiled last — 834 failed binds in one
design. 890 cast typespecs to golden, AWAY-GOLDEN 0, DEF view byte-identical,
and the new head was PREDICTED down to golden's own object id.**

Head: **20 cmp lines → 46**, 1 head → 1 head. **THE LINE COUNT WENT UP AND THAT
IS NOT A REGRESSION** — `cmp` line count is HEAD DEPTH, never a distance. The
ladder is the distance instrument and it says the walk ADVANCED past 85 rungs:
the pristine top-130 ladder holds 85 rungs of this family, the patched top-40
holds **0**, and **NEW = 0** (every patched rung has a pristine twin). The new
head simply prints a deeper subtree than the old one.

---

## THE HEAD (R0 of the pass, cleared)

```
LHS(golden): int_typespec (DepthW)  id:985050  prim_fifo_sync.sv:16:27-16:27
             UINT:2
             < ref_typespec{…u_dm_top.i_dm_csrs.i_fifo.gen_normal_fifo} #985049
             < operation(vpiCastOp) 72:45-72:59 < operation 72:20-74:80
             < cont_assign < gen_scope(gen_normal_fifo) < module_inst(i_fifo)
RHS(ours)  : integer_typespec  id:235799  :72:45-72:51
             NO name, NO value, NO vpiExpr, NO file
```

`hw/ip/prim/rtl/prim_fifo_sync.sv`:

```systemverilog
module prim_fifo_sync #(
  parameter  int unsigned Depth      = 4,
  localparam int unsigned DepthWNorm = $clog2(Depth+1),
  localparam int unsigned DepthW     = (DepthWNorm == 0) ? 1 : DepthWNorm   // 16
) ( … output [DepthW-1:0] depth );
  …
  end else begin : gen_normal_fifo
    assign depth = (full)                 ? DepthW'(Depth) :                // 72
                   (wptr_msb == rptr_msb) ? DepthW'(wptr_value) - …         // 73
                   (DepthW'(Depth) - DepthW'(rptr_value) + …) ;             // 74
```

Six cast sites, 127 elaborated `gen_normal_fifo` copies, 762 cells.

## WHAT THE DEFECT ACTUALLY WAS — AND WHY NINE PASSES WALKED PAST IT

The cast arm's shape logic was already right. **The INPUT was garbage.**

`emitModuleDef` opens with `currentScope = &body`. `emitInstance` — the
elaborated-instance emitter — sets `currentScope` NOWHERE. So while the 127
elaborated `prim_fifo_sync.gen_normal_fifo` copies are emitted,
`Expression::bind(cesyn.left /* DepthW */, ASTContext(*currentScope, …))` looks
`DepthW` up in **whatever module definition happened to be compiled last**.
Instrumented (a temporary `fprintf` in the cast arm, reverted before the
deliverable), the corpus reads:

```
[E57] txt=DepthW line=72:45 reemit=0 szKind=0(Invalid)  x127
[E57b] scope=dm_csrs        lookup=NULL
[E57b] scope=tlul_fifo_async lookup=NULL      (80 of the 127)
[E57b] scope=tlul_err        lookup=NULL
[E57b] scope=prim_fifo_async lookup=DepthW    <- the 36 that WORKED, because
                                                 that module has its own DepthW
[E57c] prefix=work@top_earlgrey.u_dm_top.i_dm_csrs.i_fifo.gen_normal_fifo
```

**834 of the 870 `DepthW` cast emissions bound in a scope that cannot see the
name.** A bad expression makes `emitExpr` return null, so the deferred and
catch-all arms hand back an `integer_typespec` at the cast-site token with no
value, no `vpiExpr` and **no `VpiFile`** — the empty file field in the head's
`@:72:45-72:51` is the fingerprint of the deferred drain, and it is the reason
the family looks like a "typespec KIND bug" in every ladder census.

That is why the family survived: every previous pass read it as a cast-shape
question, and the cast shape was never the problem.

## THE LAW — TWO CLAUSES, EACH WITH ITS OWN CORPUS WITNESS

> **§ castSizeElabScopeBind57 — when a size cast's target expression FAILS to
> bind in `currentScope`, re-bind it in the scope the cast SITE belongs to
> (`castSiteScope57`: the instance body, narrowed to the gen block for a
> gen-scope cont-assign). A GENVAR target is excluded.**
>
> **§ castGenScopeCaParamFreshTs57 — a CONT-ASSIGN cast written inside an
> ELABORATED GENERATE BLOCK mints the FRESH NAMED `int_typespec` whatever the
> target parameter's declared default was. § castTgtDefaultIsLiteral is the
> MODULE-SCOPE / function / procedural rule and does not reach a gen-block
> cast.**

**THE FENCE IS THE FAILURE ITSELF.** The re-bind runs only when the stale bind
is `bad()`, so no cast that resolves today can move, and the DEF view (where
`castSiteScope57` is null) cannot move at all.

### DECODED FROM SURELOG SOURCE, THEN MEASURED

`CompileType.cpp`, `compileTypespec` case `slStringConst`, in order:

| step | condition | object |
|---|---|---|
| 2 | `reduce == Reduce::Yes` and `getValue(name)` folds | `integer_typespec` AT THE CAST SITE with the value |
| 3 | the **INSTANCE's netlist** has a `param_assign` for the name with a **constant** RHS | `buildIntTypespec(file, name, value, param_assign->VpiLineNo(), VpiColumnNo(), <same>, <same>)` — an `int_typespec` **NAMED** after the parameter, **ZERO-WIDTH at the param_assign's own line:col** |
| 4 | the **COMPONENT's** `param_assigns` (def compile), constant RHS | same shape; an `operation` RHS takes that operation's typespec |
| 6 | `compileDatastructureTypespec` → `getParamAssignVec` | the parameter's **OWN declaration typespec**, plus a `Cast_to_expr` `ref_obj` hung on it |

`NetlistElaboration::elab_parameters_` copies `mod_assign->VpiLineNo/ColumnNo`
onto the instance `param_assign`, and for `localparam int unsigned DepthW` in
the PARAMETER PORT LIST that is `16:27` — golden's
`int_typespec(DepthW)@16:27-16:27` **to the column**. Our existing fresh arm
already writes `setLoc(its, SourceRange(psym.location, psym.location))` +
`VpiName(psym.name)` + the folded `UINT`, i.e. step 3 exactly.

### THE GOLDEN GRID (v1/v2/v3 — one golden row per cell, every cast operand a PORT so nothing folds away, every module a CHILD instance so both views exist)

**v1 — 14 targets at MODULE scope.** `castTgtDefaultIsLiteral` is the whole
rule, and the DECLARATION SITE is irrelevant:

| target | declared | default | golden ELAB ts |
|---|---|---|---|
| PLIT | port `parameter int unsigned` | `8` | **fresh** `int_typespec(PLIT)@10:27-10:27` |
| PDEP | port `parameter int unsigned` | `PLIT+1` | the **DECL ts** `int_typespec()@11:14-11:26` |
| QLIT | port `localparam` | `5` | fresh |
| QDEP | port `localparam` | `(PLIT==0)?1:PLIT` | **DECL ts** |
| PINTG | `integer` | `6` | fresh `int_typespec(PINTG)` |
| PUNT | UNTYPED | `7` | fresh |
| PLOG | `logic [7:0]` | `8'd9` | fresh `int_typespec(PLOG)` |
| PBIT | `bit [5:0]` | `6'd10` | fresh |
| POVR | port param, literal default, **OVERRIDDEN at instantiation** | fresh |
| BLIT / BUNT | module-BODY localparam, literal | fresh |
| BDEP | body localparam `$clog2(PLIT+1)` | **DECL ts** |
| BREF | body localparam `= PLIT` | **DECL ts** |
| `(BLIT+1)'` | expression | `integer_typespec@42:17-42:23` at the cast site |

**and we already agreed on all 42 v1 cells** — v1 is this pass's NEGATIVE
control and its dump is **byte-identical** between the two binaries.

**v2/v3 — the same targets, one CONTEXT per copy.** The context moves the
answer and nothing in v1 predicted it:

| context | literal default | computed default |
|---|---|---|
| module cont_assign | fresh | DECL ts |
| function body | fresh | DECL ts |
| `always_comb` at module scope | fresh | DECL ts |
| **`initial` INSIDE a gen block** | fresh | **DECL ts** |
| **GEN-IF cont_assign** | fresh | **FRESH** |
| **GEN-FOR body cont_assign** | fresh | **FRESH** |
| **NESTED gen scope cont_assign** | fresh | **FRESH** |
| **`always_comb` INSIDE a gen block** | fresh | **FRESH** (residue R1) |

and the other v3 spellings, all measured:

| spelling in a gen block | golden ELAB |
|---|---|
| a GEN-SCOPE-DECLARED localparam (`GLIT`, `GDEP`) | fresh, at the gen localparam's name token `31:29-31:29` |
| a bare IMPORTED package param (`PKL'`) | fresh `int_typespec(PKL)@8:27` — we already agreed |
| a QUALIFIED package param (`p57::PKW'`) | LOC-LESS bare `int_typespec` (§ castScopedPkgParamIntTs17) — we already agreed |
| an EXPRESSION (`(QDEP+1)'`) | `integer_typespec` at the cast site — agreed |
| `signed'(x)` | no cast op at all (a `$signed` sys_func_call) — agreed |
| a TYPEDEF (`t57_t'`) | `logic_typespec(t57_t)` — agreed |
| NESTED casts (`QDEP'(BDEP'(x))`) | BOTH fresh |
| a **GENVAR** (`gi'` in a for-generate) | **`unsupported_typespec(gi)` at the cast site — the def view's object survives**; the fence excludes it |

The DEF view of every identifier-target gen-block cast is
`unsupported_typespec(NAME)` at the cast-site token on BOTH sides — already
correct, and untouched.

## CENSUS: PREDICTED SITE-FOR-SITE, 890 MOVED

`census57.py` keys every `vpiOpType:67` operation on **(the cast op's own
line:col, the FULLNAME its `ref_typespec` carries, the occurrence index)** and
records the target typespec's KIND / VpiName / span / has-vpiExpr. Both of
earl56's instrument corrections are baked into that key: the occurrence index
because uhdm-dump prints a subtree once per listing parent, and the fullname
because the ELAB listing holds each gen-scope assign twice.

**CALIBRATION FIRST, golden vs golden** (a detector that flags everything is a
broken detector): `census57.py a1/g.dump a1/g.dump` → **agree 7, DISAGREE 0,
ONLY-GOLD 0, ONLY-OURS 0**.

Earlgrey_0_1/default:

| | pristine | predicted | measured |
|---|---:|---:|---:|
| agree | 570 | 1460 | **1460** |
| DISAGREE | 892 | 2 | **2** |
| TO-GOLDEN | — | 888* | **890** |
| **AWAY-GOLDEN** | — | **0** | **0** |
| STILL-WRONG | — | 0 | **0** |
| UNMOVED-BAD | — | 2 | **2** |
| KEY-ONLY-ONE-SIDE (pre-existing) | 149 | unchanged | **149** |

\* `CENSUS_PREDICT57.txt`'s SITE LIST is exact — all eight groups, every count.
Its headline `888` is an arithmetic slip in that file (it subtracted the two
`enum_typespec` cells from a total that had already excluded them); the site
list sums to 890 and 890 moved.

The 890, by site — **every one a failed bind, ours a value-less
`integer_typespec`**:

| n | site | golden | clause |
|---:|---|---|---|
| 762 | `prim_fifo_sync.sv` 72:45 73:45 73:67 74:21 74:38 74:60 × 127 gen_normal_fifo | `int_typespec(DepthW)@16:27-16:27` | BOTH |
| 46 | `tlul_socket_m1` 131:51 in `u_socket.gen_u_o[i]` | `int_typespec(NWD)@49:27-49:27` | BOTH |
| 72 | `prim_fifo_async.sv` 144/145/146/158/159/160 × 6, **module scope** | `int_typespec()@12:14-12:26` (the DECL ts) | BIND only |
| 5 | `dm_mem` 105/106/107/109/111:36 | `int_typespec()@61:14-61:26` (DECL ts) | BIND only |
| 2 | `dm_mem` 110/112:36 | `int_typespec(NrHarts)@20:33-20:33` | BIND only |
| 1 | `prim_lfsr` 315:30 in `gen_gal_xor` | `int_typespec(LfsrDw)@33:32-33:32` | BOTH |
| 1 | `rstmgr` 225:52 | `int_typespec(ExtResetReasons)@8:18-8:18` | BIND only |
| 1 | `pinmux` 211:25 | `int_typespec()@207:14-207:17` (DECL ts) | BIND only |

The **NAMED RISK** in `CENSUS_PREDICT57.txt` — that the 78 DECL-ts rows would
miss `defMap[def].paramTs` and land on the catch-all — **did not materialise**;
all 78 reached golden, `ref_obj(work@prim_fifo_async.DepthW.DepthW)` and all.

**The 2 residual cells are the two predicted `enum_typespec(dm::csr_reg_t)`
cells** (`dm_mem` 388:47 / 427:47): golden `@383:41-383:50`, ours
`@244:3-301:15`, **same kind and same name**, so not a `Compare` difference at
all — a SPAN-only census artefact, pristine == patched, byte-identical.

### The arms, three-way (golden / pristine / patched), ELAB and PLAIN

| arm | elab TO-GOLDEN | elab AWAY | plain TO-GOLDEN | plain AWAY | predicted |
|---|---:|---:|---:|---:|---:|
| `a1_earl57` (the corpus shape, reduced) | **4** | **0** | 3 | **0** | 4 |
| `v1_paramkinds57` (14 targets, module scope) | **0** | **0** | 0 | **0** | 0 |
| `v2_contexts57` (5 contexts) | **7** | **0** | 7 | **0** | 7 |
| `v3_gengrid57` (17 positions in the block) | **18** | **0** | 9 | **0** | 18 |

`CENSUS_PREDICT57.txt` predicted 4 / 0 / 7 / 18 — **exact on all four** — and
named v3's five UNMOVED-BAD cells in advance:

* `42:23` ×2 and `43:23` ×2 — `always_comb` INSIDE the gen block. Golden mints
  the fresh ts there too; this pass fences on the CONT-ASSIGN because the
  procedural axis has a measured COUNTEREXAMPLE three lines away (`45:18`
  `initial`, where golden keeps the DECL ts and we already agree). Residue R1.
* `69:18` — the GENVAR cast, excluded by the fence on purpose.

## THE CENSUS WAS BLIND TO 128 CELLS — AND THEY ALSO WENT TO GOLDEN

`dmov57.sh`, the whole-dump mover reader earl56 added for exactly this reason,
reported movers the cast census does not key on:

```
REMOVED (pristine-only)              ADDED (patched-only)
  1780 integer_typespec                1858 int_typespec
   128 sys_func_call ($bits)             81 ref_typespec
   128 operation                         78 ref_obj  (Cast_to_expr)
    81 ref_typespec                      78 parameter (re-print)
                                         940 |UINT:…  (128 of them UINT:64)
```

`pinmux.sv` 160 / 174 / 175 / 176: `assign data_mux = $bits(data_mux)'({…});`
inside `gen_mio_periph_in`. The cast target's KIND, NAME and SPAN are
`integer_typespec@160:23-160:38` on all three sides — so the census calls it
`agree` — but its `vpiExpr` is not:

| | top-level prints of that object | with `UINT:64` | with the symbolic `$bits` |
|---|---:|---:|---:|
| golden | 65 | **32** | **1** (the def view) |
| pristine | 33 | **0** | **33** |
| patched | 33 | **32** | **1** |

The re-bind makes `$bits(data_mux)` resolvable, the elaborated gen scope folds
it, and **the patched side reproduces golden's def-symbolic / elab-folded split
exactly** — 128 more cells to golden (4 sites × 32 elaborated copies), which the
census could not see. **Third time this campaign has learned that a
slot/field-keyed census is blind below its key; and `dmov57.sh` has its own
blind spot — it groups `\_kind:` OBJECT lines, so a FIELD-ONLY change shows as a
one-sided REMOVAL with no matching ADD. Both instruments had to be read
together, and the arbiter was the raw normalised diff.**

## THE WHOLE-DESIGN BLAST RADIUS

Earlgrey_0_1/default, path-normalised whole-dump diff: **9 729 diff lines, and
every single one is a cast typespec, a cast typespec's `vpiExpr`, or the
`UINT` value that replaced it.** Line-shape histogram of the diff:

```
1780 \_integer_typespec:  (removed)     1524 \_int_typespec: (DepthW)  (added)
 940 |UINT:#                             834 |vpiName:DepthW
 128 \_sys_func_call: ($bits)             92 \_int_typespec: (NWD)
 128 \_operation:                         72 \_ref_obj: (work@prim_fifo_async.DepthW.DepthW)
```

**ZERO `vpiDecompile` lines. ZERO net, var, port, process, assign, module or
instance objects.** No other file and no other identifier than
`prim_fifo_sync` `DepthW`, `tlul_socket_m1` `NWD`, `prim_fifo_async` `DepthW`,
`dm_mem` `NrHarts`/`NrHartsAligned`, `prim_lfsr` `LfsrDw`, `rstmgr`
`ExtResetReasons`, `pinmux` `AlignedMuxSize`/`data_mux`.

**DEF VIEW**: the `uhdmallModules` subtree, **1 046 523 lines**, md5
**`3694eca02c308c3419cb5ae30405f505`** on **BOTH** binaries. The earl38 fence
holds.

## THE NEW HEAD WAS PREDICTED (`PREDICT_R0.txt`)

Written from `lad_pris40.txt` before the patched binary produced an Earlgrey
database. The pristine ladder's first SIX rungs are all this pass's family, so
the new head had to be pristine rung 7:

```
PREDICTED  L constant@prim_fifo_sync.sv:131:29-131:38  #291799
           R ref_obj(PTR_WIDTH)@:131:29-131:38         #236039
           KINDP=operation  FIELD=VpiType  SHAPE=KIND:constant>ref_obj
MEASURED   L constant  id:291799  131:29-131:38  UINT:2  vpiSize:32
           R ref_obj(…gen_depth_gt1.storage.fifo_wptr.PTR_WIDTH) id:236039
```

**Exact on both sides, ids included** — `storage[fifo_wptr[PTR_WIDTH-2:0]] <=
wdata;` in the `always_ff` of `gen_depth_gt1`, the PROCEDURAL member of the
OPPOSITE-direction family r10earl56 named R3/R5 and deliberately fenced off
(`directBound56`). Not this pass's law and not a new defect. R0 of pass 58.

## LADDER: 85 RUNGS CLEARED, NEW = 0 (`LADDER57.md`)

Matched-depth pairs only, and the horizon is respected.

| | rungs | stop | F116 rungs |
|---|---:|---|---:|
| pristine `--max=40` | 40 | MAX | **31** |
| pristine `--max=90` | 90 | MAX | **65** |
| pristine `--max=130` | 130 | MAX | **85** |
| patched `--max=40` | 40 | MAX | **0** |

`ladidx57.py` (earl56's horizon splitter) against the 130-rung pristine ladder:

```
COMPARISON HORIZON = pristine rung 130
CLEARED   = 87    int_typespec>integer_typespec  85  idx 1..123
                  constant|VpiDecompile|O-EXTRA-PREFIX(')  2  idx 127..129
UNREACHED = 0
NEW       = 0
```

> **THE 2 NON-FAMILY "CLEARED" RUNGS ARE UNREACHED, NOT FIXED, AND THIS PASS
> PROVES IT RATHER THAN CLAIMING THEM.** They are `tlul_adapter_sram.sv`
> 132:18 and 138:18, golden decompile `"0"` against ours `"'0"`. The
> whole-dump diff contains **ZERO `vpiDecompile` lines**, so those objects are
> byte-identical between the two binaries. The lesson is about the instrument:
> `ladidx`'s horizon rule ("the last pristine site still present in the patched
> ladder") is not a sound ordering bound, because MASKING REORDERS THE WALK — a
> site at pristine index 127 can sit beyond a patched walk that still contains
> index 130. **The whole-dump diff is the arbiter, not the ladder.**

`NEW = 0` against the 130-rung pristine ladder is the strong statement: with the
comparison run to a depth that actually covers the patched walk, **the patched
ladder introduces no rung and no family the pristine ladder did not already
carry.** (Against the SHORT 40-rung pristine ladder the same join reports
`NEW = 25` — pure horizon artefact, and reporting that number would have been
claiming 25 regressions that do not exist.)

## GATE RESULTS

| gate | measurement | result |
|---|---|---|
| 1 build | both binaries, `-j 2`, md5 separately | pristine **`8add453b54945397904d8162cd75f5c1`**, patched **`b506b6152052b650d33e1d11b243dc50`** |
| 2 goldens | `tests/check_goldens.sh`, `SLANG_UHDM` exported to EACH | patched **23 PASS / 0 FAIL**, pristine **23 / 0**, `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** |
| 3 u2r | `ct8rows.sh`, **baseline FIRST** | testflags: baseline↔pristine **0** differing rows, baseline↔patched **0**, pristine↔patched **0**. default: pristine↔patched **0**. Status **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** unchanged in both modes and both binaries; dump histograms identical (testflags 496/183/52, default 492/187/52) |
| 4 surelog | both modes concatenated, **1588 rows** | baseline↔pristine **0 differing rows** (`PASS: every row byte-identical`); baseline↔patched and pristine↔patched **1 differing ROW — A CONVERSION, quoted in full below** |
| 5 byteverify | `byteverify57.sh` + both controls | u2r **1358 paths, 0 movers**; surelog **955 common paths, 2 movers** + **1 patched-only path**, all three named and attributed below. Controls: `SELFCHECK` 1357/1358 flagged, `SELFCHECK1` = **1** |

## § GATE 4 CONVERTED A ROW, AND IT IS A SEGFAULT FIX ON LEGAL SYSTEMVERILOG

**LOUDLY, and `results/*.csv` was NOT edited:**

```
< Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,      (committed baseline AND this pass's pristine)
> Earlgrey_0_1,testflags,CMP_NOTEQUAL,decompile:,,               (patched)
```

testflags status histogram, the only cells that moved:
`SLANG_REJECT 285 → 284`, `CMP_NOTEQUAL 8 → 9`. Default mode: **identical**
(`470 CMP_EQUAL / 11 CMP_NOTEQUAL / 5 DEFERRED / 283 SLANG_REJECT / 25
SURELOG_FAIL` on both binaries).

**That `SLANG_REJECT` was a SEGFAULT wearing the last stderr warning** — exactly
the trap the standing ops rules name. Reproduced directly, four runs each:

| binary | rc | database |
|---|---|---|
| pristine | **139 (SIGSEGV)**, 3/3 runs | none |
| patched | 4 (`unsupported constructs: expression kind: Invalid`), 3/3 runs | 95 350 040 bytes, md5 `b500b433dd8a` **identical every run** |

and the pristine backtrace names THIS PASS'S OBJECT GRAPH, top to bottom:

```
module_inst → module_inst → gen_scope_array → gen_scope → cont_assign
  → operation(vpiCastOp) → ref_typespec → integer_typespec → sys_func_call
  → UHDM::UhdmAdjuster::updateParentWithReducedExpression
  → UHDM::ExprEval::reduceExpr                                  SIGSEGV
```

That is `pinmux.sv:160/174/175/176`, `assign data_mux = $bits(data_mux)'({…});`
inside `gen_mio_periph_in` — the same four sites the `$bits` section above
measures. The stale-scope bind left the elaborated gen-scope cast typespec
carrying a SYMBOLIC `$bits` sys_func_call that `UhdmAdjuster` (which only runs
under `--elabuhdm`, i.e. only in testflags mode) walks into and dies on. The
re-bind resolves `$bits(data_mux)` in its own gen block, the width folds to
`UINT:64` — **golden's shape** — and there is nothing left to crash on.

So the conversion is not a status shuffle: **the row went from "we crash" to "we
produce a comparable 95 MB database", and the mechanism is the law.** The row is
still `CMP_NOTEQUAL` and this pass claims no more than that.

`Earlgrey_0_1/testflags` therefore has a head for the first time — **R0 of the
testflags row, 33 cmp lines, 1 head**:

```
LHS(golden): <null>
RHS(ours)  : parameter (work@top_earlgrey.u_dm_top.i_dm_mem.DbgAddressBits)
             id:237107  rv_dm/dm_mem.sv:59:27-59:41  UINT:12  vpiLocalParam:1
             ts -> int_typespec@59:14-59:26
```

an EXTRA-OURS elaborated localparam in `i_dm_mem` — a `parameter`-LISTING
question, not a cast one, and a brand-new frontier this pass opens rather than
closes.

### GATE 5's THREE ITEMS, all attributed

```
PATCHED-ONLY PATH  ./testflags/Earlgrey_0_1-71da2fd7/slang.uhdm
MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=4a9747462854 pristine=e90ede538a14
MOVER ./default/Scoreboard-59431470/slang.uhdm    patched=6069fe0c3ceb pristine=ffb678634d24
```

1. **The patched-only path is the segfault fix** above. `byteverify57.sh`
   correctly REFUSES to report "no movers" across asymmetric path sets and exits
   4; the run above is the same comparison over the **955 common** paths, with
   the asymmetry quoted rather than hidden.
2. **Earlgrey_0_1/default is this pass's own mover** — 890 cast typespecs + 128
   `$bits` vpiExprs, every one enumerated above. Its md5 reproduces exactly
   across two independent runs from two different output directories
   (`e90ede538a14` pristine, `4a9747462854` patched), so the 46-line head is not
   a coin. *(Note for the ledger: r10earl56's README records its landed patched
   database as `2e03b1496f9a`; this pass's pristine — built in a fresh worktree
   at that very commit — reads `e90ede538a14` reproducibly. Something outside
   this patch moved between the two passes, most plausibly the UHDM install.
   Every number in this pass is a comparison between ITS OWN two binaries, built
   minutes apart in the same worktree, so the attribution does not depend on it —
   but the earlier pin should not be trusted as a cross-pass baseline.)*
3. **Scoreboard is PRE-EXISTING EMITTER NONDETERMINISM, and it was PROVED.**
   Re-running the exact `cmds.txt` invocation:

   | binary | runs | `ffb678634d24` | `6069fe0c3ceb` |
   |---|---:|---:|---:|
   | pristine | 14 | 11 | **3** |
   | patched | 6 | 5 | 1 |

   **The pristine binary produces BOTH md5s on its own**, including the one the
   patched sweep produced, so neither value belongs to a binary — the documented
   SourceLocation-across-macro-buffers ordering flip. Its CSV row is unchanged
   in both sweeps (gate 4's row diff names ONE row and it is not this one).

### CANARIES

`canaries.sh` (vs the committed baselines): surelog **ok=51 changed=1 absent=0**
— and **the one CHANGED row is the conversion itself**
(`Earlgrey_0_1 testflags SLANG_REJECT/ → CMP_NOTEQUAL/`); u2r **ok=8 changed=0
absent=0**. `ctcan2.sh` **58 / 0 / 0** (surelog, `EXPECT_UNKNOWN=1`) and
**1 / 0 / 0** (u2r, `EXPECT_UNKNOWN=6`), both `PASS`. `canaudit.sh`
**audited=29 UNCOVERED=0 FENCE-BREACH=0**, with `UnsignedParam`,
`HierPathEval`, `FileLocalParam` and `TopParam` dispatched by no driver here.

**The two DATABASE PINS hold byte-exactly on BOTH binaries and BOTH modes:
SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`.** `InterfaceModPort`
(`59a365f3ce2c` both modes), `BlackParrotComplex` (`e3e354129d5a` /
`73a10e8217e5`) and `YosysOldOr` (`d68e0796d62c` both modes) are byte-identical
between the binaries.

### HEADS, measured via the official driver on the SWEEP databases

`rowheads.sh`, LHS always golden, heads counted with `grep -c '^LHS:'` anchored
at column 0:

```
pristine  Earlgrey_0_1 default     20 lines  1 head  cmp rc=255
pristine  Earlgrey_0_1 testflags    - SKIP-NOFILE   (the SEGFAULT: no database)
patched   Earlgrey_0_1 default     46 lines  1 head  cmp rc=255
patched   Earlgrey_0_1 testflags   33 lines  1 head  cmp rc=255   <- NEW ROW
```

and every canary row reads `0 lines / 0 heads / rc=0` on BOTH binaries in BOTH
modes: YosysVerx, SVSwitch, BlackParrotComplex, InterfaceModPort, YosysOldOr.
`measured=11 SKIP-NOFILE=1` pristine, `measured=12 SKIP-NOFILE=0` patched.

The 22 u2r cast rows (`CastClog2`, `CastExpression`, **`CastInFunctionInGenBlock`**,
`CastInFunctionToParameterWidth`, `CastSize`, `CastStruct`, `CastStructArray`,
`CastToSumWithParameterInSubmodule`, `CastToSumWithParameterIn2InstancesOfSubmodule`,
`CastWidthFromPackage`, `ImportedDoubleCastedParameter`, `nested_cast_repro`,
`OneCast`, `PackageCast`, `size_cast`, …) are **all CMP_EQUAL and all
byte-identical row-wise** in both modes — `CastInFunctionInGenBlock` is the
`inGenBlockFn` precedent this law sits next to, and it does not move.

### WIDE BOUNDARY (`vbndall57.sh`)

**958 arms × 2 views = 1916 runs, 1888 identical, DIFFERING = 6** — and all six
are `a1_earl57`, `v2_contexts57`, `v3_gengrid57`, this pass's own arms, in BOTH
views. **`v1_paramkinds57` is byte-identical in both views** (the negative
control), and **nothing else in the entire probe corpus moved**: earl45-56's
wide boundary arms, earl47's one-hop grid, earl49's operand walk, earl50's nine
positions, earl51's member-LHS cast, earl52's adjustSize, earl54's conn-repl
arms and every earlier `vpiCastOp` precedent arm are byte-identical between the
binaries. Signals symmetric — `patched=2 pristine=2`, both `rc=139` on
`r10buvm8repro/v21shadow8.sv` and `r10uvm84repro/v84x8_break.sv`, pre-existing.
`no_output=22`, symmetric by construction.

### THE CAST PRECEDENTS THIS LAW DOES NOT TOUCH, AND WHAT EACH OWNS

| precedent | the cast shape it owns | moved? |
|---|---|---|
| `static_cast_simple` / `wrapSignCast9` | `signed'`/`unsigned'` merged into a size cast → `$signed`/`$unsigned` sys_func_call | no (v3 `sg1` agrees, and the arm sweep is byte-identical) |
| `jj.sv` `16'(16'h1)` | a LITERAL-width cast whose operand folds | no (`cesyn.left` is an IntegerLiteral, a different arm entirely) |
| `defaultPatternAssignment` cast arm | `T'{…}` assignment-pattern casts, `int` only | no (`isTypeSyntaxKind` / TypeAlias arms) |
| § castQualPkgWidthElabBareTs27 | `pkg::P'(x)` — a ScopedName left | no (v3 `pk1` agrees on both sides) |
| § castTypedParamDeclTs / § castTgtDefaultIsLiteral | a TYPED, computed-default target at MODULE scope | **still owns it** — v1's PDEP/QDEP/BDEP/BREF rows and prim_fifo_async's 72 cells are exactly this rule, and the gen clause is fenced off them |
| `inGenBlockFn` | a cast inside a FUNCTION declared in a gen block | no (v2's function rows agree; `CastInFunctionInGenBlock` is byte-identical) |

## RESIDUES (measured, named, NOT fixed)

* **R1 — the gen-block PROCEDURAL cast.** `always_comb` inside a generate block
  takes golden's FRESH named typespec (v3 42:23 / 43:23, 4 cells) but `initial`
  three lines away keeps the DECL ts (v3 45:18, where we already agree). Two
  procedural forms, opposite answers, in the same block — a second axis with an
  unmeasured corpus population, so it is a separate law. `inGenScopeProc` and
  `currentGenBlkScope` are already wired for whoever takes it.
* **R2 — the GENVAR cast.** `gi'(x)` in a for-generate body: golden keeps the
  def view's `unsupported_typespec(gi)`, we emit an `integer_typespec` at the
  same span. Explicitly excluded by the fence (`isFromGenvar`) so the pass moves
  nothing there; fixing it means minting an unsupported_typespec in the ELAB
  view, which no other arm does.
* **R3 — `currentScope` IS STILL STALE EVERYWHERE ELSE IN `emitInstance`.** This
  pass repaired the SYMPTOM at one reader (the cast-size bind) and deliberately
  did not set `currentScope = &body` in `emitInstance`, because every other
  reader of `currentScope` was calibrated against the stale value. That is the
  biggest single lead this pass produces: any other law that binds syntax during
  elaborated emission is reading the same garbage. `castSiteScope57` is the
  scope to hand it.
* **R4 — the 2 `enum_typespec(dm::csr_reg_t)` SPAN cells** (`dm_mem` 388:47 /
  427:47). Same kind, same name, different span; not a `Compare` difference.
  Pristine == patched.
* **R5 — the 149 KEY-ONLY-ONE-SIDE cast sites** (137 golden-only, 12 ours-only),
  identical in both binaries: pre-existing missing/extra cast operations, a
  different family from the typespec they carry.

## FILES

| file | what it is |
|---|---|
| `census57.py` | the CAST-TYPESPEC census, keyed on (cast op line:col, ref_typespec fullname, occurrence); `--list` prints the grid, `--attrib` is the three-way join whose AWAY-GOLDEN column must be 0. **Its blind spot is documented above and it must be read together with `dmov57.sh`.** |
| `dmov57.sh` | the whole-dump mover reader (carried from earl56), path-normalised. Blind to FIELD-only changes — see the `$bits` section. |
| `a1_earl57.sv` | the corpus shape reduced to 33 lines: a param-port-list localparam with a computed default, size-cast inside an if-generate, in a child instance |
| `v1_paramkinds57.sv` | the MODULE-SCOPE grid, 14 target kinds — this pass's NEGATIVE control, byte-identical in both views |
| `v2_contexts57.sv` | the CONTEXT grid: if-generate, nested gen scope, for-generate, function body, `always_comb` |
| `v3_gengrid57.sv` | INSIDE the block: cont-assign / `always_comb` / `initial`, gen-scope localparams, package params bare and qualified, expression widths, `signed'`, typedef, nested casts, genvar |
| `arm57.sh` `armplain57.sh` | arm drivers, `-elabuhdm`/`--elabuhdm` on both sides and with neither |
| `earl57.sh` | the Earlgrey_0_1/default driver (golden from the immutable cache) |
| `CENSUS_PREDICT57.txt` `PREDICT_R0.txt` | written before the patched binary was built / run |
| `LADDER57.md` | the matched-depth ladder pairs and the horizon correction |
| `lad_pris40.txt` `lad_pris90.txt` `lad_pris130.txt` `lad_pat40.txt` | the four ladder runs `LADDER57.md` reads |
| `sweeps57.sh` `ct8rows.sh` `byteverify57.sh` `canaries.sh` `canaudit.sh` `ctcan2.sh` `rowheads.sh` `vbndall57.sh` `varm.sh` `ladcmp57.py` `ladidx57.py` `v57span3.py` | carried-forward harness |

## THE PATCH REBUILDS TO THE SAME BINARY FROM A FRESH BASE

`git worktree add /tmp/wt_r10earl57_fresh 9d9e2a4`, `git apply --check` **clean**,
`git apply`, configure, `cmake --build -j 2` → md5 **`b506b6152052b650d33e1d11b243dc50`**,
byte-identical to `b506b6152052b650d33e1d11b243dc50`, the binary every gate above
was run with. The deliverable is not "the patch that happens to be in my
worktree": it is the patch that reproduces the measured binary.

## WHAT THE NEXT PASS SHOULD KNOW

1. **R0 of `Earlgrey_0_1/default` is `PREDICT_R0.txt`'s rung 7** — earl56's
   R3/R5 residue, `storage[fifo_wptr[PTR_WIDTH-2:0]] <= wdata;` at
   `prim_fifo_sync.sv:131:29`, golden folds the select-bound operand and we keep
   the `ref_obj`. It is the PROCEDURAL member of a family earl56 measured at
   2 099 slots and fenced deliberately; taking it means extending
   § genLpUseFoldParentScope47 to a procedural select bound.
2. **R0 of `Earlgrey_0_1/testflags` exists for the first time** (33 lines): an
   EXTRA-OURS elaborated localparam `i_dm_mem.DbgAddressBits`. A whole row's
   worth of frontier that was behind a segfault until now.
3. **`currentScope` is stale throughout `emitInstance`** (R3 above). This pass
   fixed one reader and left the rest alone on purpose. Any law that binds
   syntax during elaborated emission is reading garbage; `castSiteScope57` is
   the scope to hand it, and the cheapest next experiment is to set
   `currentScope = &body` in `emitInstance` and read the blast radius with
   `vbndall57.sh` + `dmov57.sh`.
4. **Two instruments, two blind spots, one arbiter.** A cast census keyed on
   (kind, name, span) cannot see a `vpiExpr` change; a mover reader grouped by
   OBJECT lines cannot see a FIELD-only change. The raw path-normalised
   whole-dump diff saw both. Run all three.
