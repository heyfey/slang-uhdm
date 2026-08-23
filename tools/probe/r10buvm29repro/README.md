# r10buvm29 — § `castOverStreamKeepsCast29` — **THE 17-LINE `BuildUVMPkg` HEAD CLEARED**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW WAS CONVERTED**. But five arm-views —
`g29_f_head.sv` (the head, minimised) and `g29_e_homes.sv` in **both** views,
and `g29_c_carriers.sv` in the elaborated view — **PASS the official
`uhdm-cmp`** with the patch where pristine fails with R0's head, and that is
said out loud in §7.

| | |
|---|---|
| BASE | `d71c34e` |
| worktree | `/tmp/wt_r10buvm29` |
| pristine binary | md5 `c0544c563e6f68b1f43072e5d4db5476` (byte-identical to the campaign control for `d71c34e`) |
| patched binary | md5 `3f5cdd274ec4e3bead38f22eb6d08085` |
| production surface | `src/ExprEmit.cpp` ONLY — **one predicate widened: +23 / -3 lines, the 3 being the replaced two-line comment and the old `if`; 20 of the 23 are comment; 0 other behaviour changed** |
| probe surface | `tools/probe/r10buvm29repro/` only |
| deliverable | `/tmp/r10buvm29.patch`, applies clean on a FRESH `d71c34e` |

## 0. THE HEADLINE

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines (`2>&1`), default / testflags | **17 / 17** | **29 / 29** (a DEEPER object — the 17-line head object is GONE) |
| `uhdm-cmp` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5, both modes byte-identical | `4b761630ccd5` | `834eea13faf5` |
| head object | golden's `ref_typespec` vs `RHS: <null>` on the CAST at `uvm_pkg.sv:58249` | a `ref_var` ours has and golden lacks at `uvm_pkg.sv:53993` (**R0**) |
| corpus census `MISSING-CAST`, surelog | **4** | **0** |
| corpus census `FALSE-CAST`, both corpora | 0 | **0** |
| surelog sweep | 937 `CMP_EQUAL` / 19 `CMP_NOTEQUAL` | 937 / 19 — **unchanged**, 0 differing rows |
| u2r sweep, both modes | 679 / 50 / 2 | 679 / 50 / 2 — 0 differing rows, **0 byte movers / 1358** |
| byte movers, surelog | — | **2 / 956**, both PREDICTED BY NAME, no coin flip |
| every other row's head | — | byte-identical (SeqDriver 29, SimpleUVM 17, Scoreboard 29, MiniAmiq 348, Earlgrey 64, Rggen PASS) |

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG

The pristine log is 17 lines `2>&1`, `grep -c '^LHS:'` = 1, and the two modes
are byte-identical (`head_pris_BuildUVMPkg.cmp`). Source:
`1800.2-2017-1.0/src/tlm2/uvm_tlm2_generic_payload.svh` expanded through
`src/macros/uvm_packer_defines.svh:211` (`VAR = TYPE'({ << bit { __array }});`)
into `pp_output/uvm_pkg.sv:58245-58250`, inside
`function void uvm_tlm_generic_payload::do_unpack(uvm_packer packer)`:

```systemverilog
  begin
    bit __array[] = new [32];
    packer.unpack_bits(__array, 32);
    __array = new [$bits(m_command)] (__array);              // buvm28's head
    m_command = uvm_tlm_command_e'({ << bit { __array }});   // :58249  <-- R0
  end
```

```
LHS golden  ref_typespec: (uvm_pkg::uvm_tlm_generic_payload::do_unpack), id:179326
              |vpiParent: \_operation: , id:179325, line:58249:17, endln:58249:58
              |vpiActual: \_enum_typespec: (uvm_pkg::uvm_tlm_command_e)
RHS: <null>
```

**THE SLOT AND THE FIELD, from the generated sources.** `assignment::Compare`
reaches `Rhs`; both sides carry an `operation`, so `operation::Compare` runs —
and its FIRST act is `basetype_t::Compare`, i.e. `expr::Compare`
(`~/git-repos/UHDM/build/generated/src/expr.cpp:83`), whose order is
`VpiDecompile`, `VpiSize`, **`Typespec`**. Both sides' decompile is empty and
both sizes are 0, so the third field decides — and golden's cast operation
carries a `ref_typespec` where our bare stream operation carries none.
`SafeCompare`'s SINGULAR overload with `rhs == nullptr` names the VALUE and
prints `RHS: <null>` (`BaseClass.h`). `operation::Compare` never gets as far as
`VpiOpType` (`operation.cpp:105`), so the judge never reports "67 vs 72" —
it reports the missing ref. 17 lines is that ref's decompile depth, printed
twice.

**The copies.** Two spans (`:58249` and `:58284`, `m_command` and
`m_response_status`), two modes, and the DEF and ELAB views of a package class
method — four corpus cells, `BuildUVMPkg` only. The census in §3 found no
fifth anywhere in 956 + 1358 databases.

## 2. THE LAW

> **A conversion around a streaming concatenation loses its cast node only
> when the conversion is COMPILER-INSERTED. A cast the user WROTE keeps it.**
>
> Surelog's cast arm — `CompileHelper::compileExpression`,
> `VObjectType::paCast` / `paConstant_cast`,
> `src/DesignCompile/CompileExpression.cpp:2635-2691` — is an ORDINARY cast
> arm. It takes `Casting_type = fC->Child(child)`, compiles
> `fC->Sibling(Casting_type)` as the operand **without ever inspecting what
> that operand is**, mints `operation` / `VpiOpType(vpiCastOp)` /
> `populateCoreMembers(parent, parent, operation)`, pushes the operand, and
> hangs `compileTypespec(Simple_type)` off a fresh `ref_typespec` as
> `Actual_typespec`. A streaming operand is nothing special to it.
>
> Surelog's streaming arm — `VObjectType::paStreaming_concatenation`,
> `CompileExpression.cpp:3063-3121` — mints the stream `operation`
> (`vpiStreamLROp` for `>>`, else `vpiStreamRLOp`, lines 3097-3101), gives it
> the span of the INNER `{...}` node
> (`populateCoreMembers(Stream_concatenation, Stream_concatenation, operation)`,
> line 3096), pushes the `paSlice_size` as the FIRST operand — through
> `compileBits` when it is a `paSimple_type` keyword (line 3080, uvm93's
> § `streamSliceTypeBits93`) and through `compileExpression` otherwise — then
> a `vpiConcatOp` operation located at the WHOLE streaming node (line 3109)
> holding the stream expressions. Nothing in either arm couples them.
>
> **slang is the odd one.** It models `T'(<stream>)` as a
> `ConversionExpression`, and — critically — it ALSO models a bare stream in
> an assignment-like context as a `ConversionExpression`:
> `ConversionKind::StreamingConcat` and `ConversionKind::BitstreamCast` both
> sit at or above `StreamingConcat` in the enum, and
> `ConversionExpression::isImplicit()` is `conversionKind <
> ConversionKind::StreamingConcat`, so **neither is implicit** and both reach
> our cast arm. Our emitter told them apart by looking at the OPERAND —
>
> ```cpp
> // A cast around a streaming concat is dropped (Surelog emits the
> // stream operation directly).
> if (stripImplicitConv(conv.operand()).kind == ExpressionKind::Streaming)
>     return emitExpr(stripImplicitConv(conv.operand()), parent, prefix, netMap);
> ```
>
> — which is right for the compiler-inserted ones (every `{<< 8 {x, y}}` in
> the corpus) and wrong for the written one. **The written `'` is the whole
> distinguisher**: the fix keeps the cast when and only when this conversion
> carries `CastExpression` syntax (`effCastSyn`, already computed two lines
> above for the nested-cast road). One predicate, one `&&`.

The cast's TARGET typespec then rides uvm96's
§ `castTargetKeywordTypespecKind96` unchanged — the kind is a pure function of
the keyword written left of the `'`. `g29_b_targets.sv` asserts that the
keyword table still holds when the operand is a stream: 12 target spellings,
12/12 FIXED, 0 BROKE (§7).

## 3. THE CORPUS CENSUS, MADE BEFORE THE PATCH, FROM PRISTINE DATABASES

`ct29cen.cpp` walks the design roots with `UhdmListener` — the REACHABLE
objects, not the whole serializer arena — and emits one row per `operation`
whose `VpiOpType` is `vpiCastOp` (67), `vpiStreamLROp` (71) or
`vpiStreamRLOp` (72), with its span, the `Typespec()` -> `ref_typespec` ->
`Actual_typespec` KIND, the operand count and kinds, the parent and the owner.
`join29.py` multiset-joins golden against ours on `(line, owner)`.

*(Two traps paid for here. The ARENA walk `Serializer::AllObjects()` counted
the weakly-referenced DEF-phase clones and reported every elaborated-view cell
as a duplicate — `STILL 24` on an arm `uhdm-cmp` scores `PASS`; the listener
walk fixed it. And the join is a MULTISET, because a DEF and an ELAB clone
share a key and a last-writer dict drops one — buvm22's trap.)*

| corpus | dbs | dbs with a golden stream | golden CAST-OVER-STREAM | MISSING-CAST | FALSE-CAST | golden BARE streams |
|---|---|---|---|---|---|---|
| uhdm2rtlil | 1358 | 10 | **0** | 0 | 0 | 24 |
| surelog | 956 | 11 | **4** | **4** | 0 | 196 |

The four sit in exactly two databases — `default/BuildUVMPkg` and
`testflags/BuildUVMPkg`, two cells each. **That IS the mover prediction**, and
byteverify measured exactly it (§6).

**The fence, found FIRST from the pristine databases and confirmed at the
source.** 196 + 24 golden BARE streams — every one a compiler-inserted
conversion whose cast must stay dropped. `grep -rnE "'\s*\(\s*\{\s*(<<|>>)"`
over every `.sv`/`.svh`/`.v` of both corpora finds only `uvm_pkg.sv:58249`,
`:58284`, their macro body, and `Verilator/t_stream.v:95-99`. The Verilator
five cannot reach our emitter at all: **slang REJECTS a SIZE cast over a
streaming concatenation** — *"cannot change width or signedness of
non-integral expression (type is `void`)"* — for a fixed-size operand too, so
`t_stream` is `SLANG_REJECT` and out of scope. The database census and the
source grep agree independently: `uvm_pkg.sv:58249`/`:58284` are the only
written-cast-over-a-stream cells in either corpus.

## 4. THE GRID, GOLDEN-SIDE, RUN BEFORE ANY CODE

| arm | what varies | cells | what it pins |
|---|---|---|---|
| `g29_a_slices.sv` | **only the stream** — `<<`/`>>`, no slice size / numeric / `bit` / `byte`, 1-4 members, dynamic arrays | 23 | the stream's golden structure under a cast: slice-size constant FIRST (`UINT:1` for `bit`, `UINT:8` for `byte` — uvm93's `compileBits`), then the `vpiConcatOp`; plus three cast-over-a-NON-stream controls |
| `g29_b_targets.sv` | **only the target keyword** (stream and carrier held) | 24 | uvm96's keyword table survives a stream operand: base-less enum, based enum, packed struct, `int`, `byte`, `shortint`, `longint`, `integer`, `bit`, `logic`, a typedef'd vector, a SCOPED typedef |
| `g29_c_carriers.sv` | **only the carrier** | 16 | assignment Rhs, call argument, condition, concat member, binary operand, **a NESTED cast of a cast**, an INDEX, a return value |
| `g29_d_fence.sv` | **NEGATIVE — the fence** | 9 / 13 | every bare-stream shape the corpus has, in a continuous assign, an `always_comb`, an `initial`, a function return |
| `g29_e_homes.sv` | **only the home** | 20 / 24 | in-body class method, **OUT-OF-BLOCK class method (the head's own home)**, OOB task, package function, module function, module task, `initial`, `always_comb` |
| `g29_f_head.sv` | the head, minimised | 4 | a package class whose OOB method writes `m_command = tlm_command_e'({ << bit { __array }});` |

Golden's node structure per stream-cast cell, measured (`g29_f_head.sv`,
`uvm_pkg.sv:58249` and buvm28's `g28_c_castr0.sv` agree):

```
assignment
 |vpiRhs
 \_operation  vpiOpType 67   span = target keyword .. one past the stream's `}`
     |vpiTypespec \_ref_typespec (name EMPTY; the parenthesised text in the
     |               dump is vpiFullName, SYNTHESISED from the parent chain,
     |               and no generated Compare reads it)
     |    |vpiActual \_<enum|struct|int|logic|byte|...>_typespec
     |vpiOperand
     \_operation  vpiOpType 72 (`<<`) / 71 (`>>`)   span = the INNER `{...}`
         |vpiOperand \_constant  UINT:<slice bits>  vpiSize 64  constType 9
         |             (NO location, NO parent — Surelog's compileBits mints
         |              neither; absent when no slice size is written)
         |vpiOperand
         \_operation  vpiOpType 33 (concat)  span = the WHOLE streaming node
             |vpiOperand \_<the stream expressions>
```

Neither the cast nor the stream carries a `VpiDecompile` or a `VpiSize` on
either side — measured, not assumed, and it matters because those are the two
fields `expr::Compare` reads before `Typespec`.

## 5. THE FIX

`src/ExprEmit.cpp`, the `ExpressionKind::Conversion` arm. `effCastSyn` is
already computed immediately above (it is how the nested-cast road recovers a
syntax-less inner conversion), so the whole change is a conjunct:

```cpp
if (stripImplicitConv(conv.operand()).kind == ExpressionKind::Streaming &&
    (!effCastSyn ||
     effCastSyn->kind != syntax::SyntaxKind::CastExpression))
    return emitExpr(stripImplicitConv(conv.operand()), parent, prefix, netMap);
```

Everything downstream — the target typespec (uvm96's keyword table), the
`ref_typespec` wrap, the re-emit `pendingCastTs` deferral for the elaborated
view, the span — is the EXISTING cast road, untouched. Nothing was added for
the stream case: the corpus dump shows the new cast operation landing at
`58249:17-58249:58`, **golden's span exactly**, because slang's
`ConversionExpression::sourceRange` for `T'({...})` already ends where
Surelog's parse node does.

## 6. THE MOVERS — PREDICTED BY NAME, THEN MEASURED

`SELFCHECK=1 byteverify.sh`, patched workdir vs **this pass's own** pristine
workdir (no shared `/tmp/ctl_wd_*` was read):

```
surelog     MOVERS: 2 / 956    SELFCHECK 955/956 flagged
            ./default/BuildUVMPkg-bf853d43/slang.uhdm    93fa77493972 <- 861b8d9cf5c1
            ./testflags/BuildUVMPkg-bf853d43/slang.uhdm  93fa77493972 <- 861b8d9cf5c1
uhdm2rtlil  MOVERS: 0 / 1358   SELFCHECK 1357/1358 flagged
```

Exactly the predicted set. Scoreboard/default — the ~50/50 `svunit_pkg`
`vpiTaskFunc`-order coin — did not flip. Inside the two databases the
path-normalised whole-dump diff is **84 lines, +24 net, every one at
`uvm_pkg.sv:58249` or `:58284`**: the assignment's `vpiRhs` changes from the
bare `vpiOpType 72` operation to golden's `vpiOpType 67` cast wrapping it.

## 7. ARMS, GATES, BOUNDARY

Three-way (golden / pristine / patched), BOTH views, 13 scored arm-views:
**FIXED 174, BROKE 0, STILL 2** (`ARMS.r10buvm29.txt` has the table).

**SAID OUT LOUD:** `g29_f_head.sv` (the head, minimised) and `g29_e_homes.sv`
**PASS the official `uhdm-cmp` in BOTH views**, and `g29_c_carriers.sv`
passes in the elaborated view, where PRISTINE FAILS with R0's 16-line head.
`results/*.csv` were not touched, nothing was promoted, and **no corpus row
was converted** — `BuildUVMPkg` is `CMP_NOTEQUAL` before and after.

**The fence arm `g29_d_fence.sv` PASSES `uhdm-cmp` on BOTH binaries in BOTH
views**, is `ALREADY-OK` on all its cells, and does not appear among the
boundary movers.

Every landing gate is green — build md5s, goldens 23/0 with the `/bin/false`
negative control at 23, u2r 679/50/2 both modes with 0 differing rows against
the committed baseline AND against this pass's own pristine sweep, surelog
937/19 with 0 differing rows, byteverify with every mover named, all named
pins SAME (`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
`InterfaceModPort`/`BlackParrotComplex`/`YosysOldOr` byte-identical),
canaries `ok=52` / `ok=8` `changed=0`, both `ctcan2` PASS, and
`canaudit.sh` `audited=33 UNCOVERED=0 FENCE-BREACH=0`.
Full numbers in `GATES.r10buvm29.txt`.

**Boundary**, a COPY of `tools/probe` with NO path filter, `.sv` AND `.v`,
subdirectories included, fd-3 list, children `</dev/null`, PROCESSED
asserted: `LISTED=3400 PROCESSED=3400 MOVED=15 NO_OUTPUT_PAIRS=276`. Fourteen
movers are this pass's own arms and buvm28's two cast grids — the built-in
positive controls. The fifteenth was NOT predicted by name and is attributed
in `BOUNDARY.r10buvm29.txt`: `r10uvm92repro/g92_a2_ppkinds.sv` lines 50 and 52
are `oo = bb.dyn[int'({>>{w}})];` and `int'({<<{w}})` — the law, in an index —
scored against purpose-built golden as `CELLS 5 FIXED 4 BROKE 0 STILL 0`, with
the arm's residual head byte-identical between the binaries. A TO-GOLDEN move.

## 8. NEW R0 AND RESIDUES

**R0 — the new `BuildUVMPkg` head**, both modes, **29 lines**, one head, cmp
logs byte-identical between modes (md5 `834eea13faf5`), at
`uvm_pkg.sv:53993`:

```systemverilog
function void uvm_sequencer_param_base::send_request(uvm_sequence_base sequence_ptr,
                                                     uvm_sequence_item t,
                                                     bit rerandomize = 0);
  REQ param_t;                                     // :53993  <-- R0
```

```
LHS: <null>
RHS ours  ref_var: (uvm_pkg::uvm_sequencer_param_base::send_request::param_t)
            |vpiParent: \_begin: (…::send_request) @53995:3-53997:6
            |vpiTypespec: \_ref_typespec:
                |vpiActual: \_unsupported_typespec: (REQ) @53993:3-53993:6
```

`LHS: <null>` is the SINGULAR overload's mirror — **OURS carries an object
golden does not**. `REQ` is the class's TYPE PARAMETER; in the DEF view
Surelog leaves the declaration out of the subroutine's variable list entirely,
while we mint a `ref_var` whose typespec is an `unsupported_typespec` named
`REQ` and, worse, parent it to the `begin` block at `:53995` rather than to the
function. **Population unmeasured beyond this row; the next pass should census
`ref_var`s over `unsupported_typespec` across the nine UVM databases first.**

**Residues this pass measured and deliberately left**

* **R-STREAMSPAN — the stream operation's own span, 57 arm cells.** Surelog
  gives it the span of the INNER `{...}` node
  (`CompileExpression.cpp:3096`); we compute
  `(first operand start - 1) .. (last operand end + 1)`, which coincides only
  when no whitespace separates a brace from an operand — true of every
  bare-stream site in either corpus, false of `{ << bit { __array }}`.
  **Invisible to the judge**: `g29_f_head.sv` PASSES `uhdm-cmp` with the span
  still off by one at each end. Deliberately not shipped — it would move the
  bare-stream bytes of 21 corpus databases for zero judged effect. **Corpus
  judged population 0.**
* **R-NESTCAST — `int'(int'(v1))`.** Golden emits TWO nested cast operations;
  we collapse them to one. PRE-EXISTING, unrelated to streams, and the
  nested-cast-over-a-STREAM cell (`int'(ze'({ << bit { __a }}))`) IS fixed
  here. **2 arm cells, corpus population 0.**
* **R-SIZECASTSTREAM — slang refuses `N'({<<{x}})`** ("cannot change width or
  signedness of non-integral expression (type is `void`)") even for a
  fixed-size operand, which puts `Verilator/t_stream.v`'s five sites
  permanently out of scope. Not a defect of ours; recorded so a future pass
  does not chase them.

**buvm28's queue, RE-RANKED by what this pass measured**

1. **R-G22RANGE** — the unchecked `ct.as<FixedSizeUnpackedArrayType>()` at
   `src/TypeEmit.cpp:10359`. **Now the top of the queue.** This pass paid for
   it twice: it is the residual head of `g29_b_targets.sv`'s first draft (an
   unused `typedef bit [7:0] uarr_t [4];` produced a 606-line head that had to
   be deleted to see the law's own arm) and it remains the boundary polluter
   whose value shifts with any allocation-order change. Byte-identical between
   this pass's binaries.
2. **R0 above** — the `REQ param_t` `ref_var`, the current head, 2 corpus rows
   x 2 modes.
3. **R-ELABSEG** — the pre-existing SIGSEGV on legal SV under `-elabuhdm`.
   RE-CONFIRMED here and now with a NAME: `r10uvm92repro/g92_a2_ppkinds.sv`
   exits **rc=139 on BOTH binaries** in the elaborated view (Surelog itself
   exits rc=4), and it is one of the boundary's 276 `NO_OUTPUT_PAIRS`. A
   reproducer that is already committed to the tree makes this cheap to fix.
4. **R-GENFOLD** (buvm27's) — a gen-scope `Reduce::No` context for `$bits`;
   would retire buvm27's verifier fence AND uvm95's R3's 15 corpus cells.
   Unchanged by this pass.
5. **R-DOTTED** / **R-ENUMDOTTED** — `compileBits`' `paComplex_func_call` ->
   `decodeHierPath` arm; one fix, 6 + 3 arm cells. Unchanged.
6. **R-HIERKEEP**, **R-ENUMCONCAT**, **R-ENUMPARAM**, **R-ENUMRANGE** — all
   corpus population 0 by buvm28's own predictor, all unchanged and
   byte-re-verified here. They stay at the bottom.
7. **R-CONCATOVER**, **R-BOUNDEDQ**, buvm26's **R-TRAILMEM** / **R-LITARG** —
   unchanged and unmeasured by this pass.

## 9. REPRODUCE

```sh
g++ -O2 -std=c++17 ct29cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10buvm29_ct29cen
./cen29.sh <sweep workdir root> <censusdir>     # golden + ours, every row-mode
python3 join29.py <censusdir> [--verbose]       # CASTOVERSTREAM / MISSING / FALSE / BARE
PRI=… PAT=… MODE=def  ./three29.sh $PWD/g29_f_head.sv        # builds golden + both
PRI=… PAT=… MODE=elab ./three29.sh $PWD/g29_d_fence.sv
python3 four29.py <G.cen> <PRI.cen> <PAT.cen> [-v]   # ALREADY-OK/FIXED/BROKE/STILL
PRI=… PAT=… ROOT=<a COPY of tools/probe> BWD=… ./bound29.sh   # BOTH views, .sv AND .v
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <pat wd> <pris wd>
UHDM_CMP=~/git-repos/UHDM/build/bin/uhdm-cmp ./rowheads.sh <wd> <outdir> \
    SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./pins29.sh <pat wd> <pris wd> ; bash canaudit.sh canaries.sh ctcan2.sh
~/git-repos/Surelog/build/bin/surelog -parse -nocache -d coveruhdm g29_f_head.sv
```

Evidence files: `INPUTS.r10buvm29.txt`, `GATES.r10buvm29.txt`,
`CENSUS.r10buvm29.txt`, `PREDICT.r10buvm29.txt`, `BOUNDARY.r10buvm29.txt`,
`ARMS.r10buvm29.txt`, `head_pris_BuildUVMPkg.cmp`, `head_pat_BuildUVMPkg.cmp`.
