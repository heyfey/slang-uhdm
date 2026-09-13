# r11u16 — the ELABORATED continuous assignment slices the member out of the assembled constant

§ `caAsmMemberSliceFold`.  Everything here is MEASUREMENT-ONLY; the judge is
`uhdm-cmp` through `scripts/verify_golden.py`.  Base commit `6c6d4768`, pins per
`SUPPORT_MATRIX.md` (slang upstream `7d61e0ad1`, UHDM v1.87, Surelog v1.87,
uhdm2rtlil v0.68).

## 1. The corpus head, RE-MEASURED on this pass's own pristine build

The two rows moved at pass 13, so the committed prior diffs are stale.  Pristine
at `6c6d4768` (md5 `d84acd3f88dab953d1b7348d80682a2d`, byte-identical to the main
tree's build), uhdm2rtlil 757 / 47 / 67 in BOTH modes.  ONE head each
(`grep -c '^LHS:'` = 1), and it is **the same head on both rows**:

`struct_param_func_arg`, `assign o_direct = CFG.n;` (dut.sv:22) —

```
LHS:                                   RHS:
decompile:                             decompile:
constant: , id:296                     hier_path: (CFG.n), id:127, line:22:21
|vpiDecompile:000…00011                |vpiActual:
|vpiSize:32                            \_ref_obj: (CFG), id:128
|BIN:000…00011                         |vpiActual:
|vpiTypespec:                          \_ref_obj: (work@dut.n), id:129
\_ref_typespec: (work@dut), id:297     |vpiName:CFG.n
  |vpiActual:
  \_int_typespec: , id:287, line:2:27
|vpiConstType:3
```

`struct_param_func_loop`, `assign o_n = CFG.n;` (dut.sv:60) — the same face, the
same field, the same shape: golden `BIN` size 32 ct 3 `…00010` with a
`ref_typespec -> int_typespec` at the member's own declaration, ours the
unfolded `hier_path (CFG.n)`.

The two designs differ in the HOLDER (`arg` is a module PARAMETER with a
`p::build()` default, `loop` a module LOCALPARAM) and in the BUILDER (literal
writes vs a concat write).  Neither matters: one fix converts both rows.

## 2. The producer, decoded

`UhdmWriter::writeCont_assign`'s `simplified == false` tail (Surelog
`src/DesignCompile/UhdmWriter.cpp` ~2243) runs `CompileHelper::reduceExpr` over
the WHOLE Rhs of every ELABORATED cont_assign, then `CompileHelper::adjustSize`
over the result.  A `hier_path` Rhs enters `ExprEval::decodeHierPath` (UHDM
`templates/ExprEval.cpp` ~2228), which answers the base name out of the
instance's own `param_assign` Rhs, skips the base at `level == 0` and walks the
selectors in `hierarchicalSelector`.

**The mint** is `hierarchicalSelector`'s FIRST arm (~2331) — the base is a
CONSTANT carrying a `struct_typespec`:

```cpp
constant *c = s.MakeConstant();
c->VpiValue("BIN:" + mbits);
c->VpiDecompile(mbits);            // BARE — no `<w>'b` prefix
c->VpiSize((int32_t)mbits.size());
c->VpiConstType(vpiBinaryConst);
if (mts_found) { ref_typespec *rtc = …; rtc->Actual_typespec(mts_found); … }
```

with no `populateCoreMembers`, so the constant is LOCATION-LESS, and with the
FIRST DECLARED MEMBER OCCUPYING THE MSBs.  It refuses a slice that is not fully
defined ("Only a FULLY-DEFINED slice is a usable value" — the producer's own
comment, written for `param_nested_struct_field_width`).

**The DEFINITION listing does not fold.**  `uhdmallModules` is written before
instance elaboration, so golden keeps the symbolic `hier_path` there — measured
on every arm of the grid and on both corpus rows, where our def view is already
byte-for-byte golden's.

**THE READING CONTEXT CONTRIBUTES EXACTLY ONE NUMBER.**  `adjustSize`
(CompileHelper.cpp:4065) computes `size = Bits(<the Lhs typespec>)` FIRST and
then REPLACES its `ts` with the constant's own — the member's — typespec, so the
branch it takes is chosen by the MEMBER's typespec kind while only `VpiSize`
(and, for a logic member, a truncation) ever sees the Lhs width.  Grid `d11`
measures all three branches:

| member typespec | Lhs | golden |
|---|---|---|
| `int_typespec` (`int unsigned n`, 32) | 8-bit bound net | 32 binary digits at **VpiSize 8** — the value is NOT truncated |
| `logic_typespec` (`logic [63:0] base`) | 8-bit bound net | value AND decompile truncated to the LOW 8 digits, VpiSize 8 |
| `byte_typespec` (`byte b`, 8) | 32-bit bound net | unchanged: 8 digits, VpiSize 8 |
| `int_typespec` | part-select / concat / gen-local target | unchanged: VpiSize 32 |

The Lhs width exists only when `CompileHelper::bindVariable` binds — a plain
module-body net or variable reference — which is the predicate
`caLhsAdjustBind106` already decodes for r10earl106 and which this law reuses
rather than re-deriving.

## 3. THE GOLDEN GRID — 14 arms, every arm's rc recorded

`grid.sh` builds the Surelog golden and both binaries per arm.  All fourteen:
`slrc=0`, `[ERROR] : 0`, `gold=yes`, `pris_rc=0`, `pat_rc=0`.

| arm | what it varies | what it pins |
|---|---|---|
| `d1` | nine Rhs SHAPES on a MODULE-held parameter | only the BARE member select folds this way; `CFG.n+1`→`UINT:4`, `{CFG.n,CFG.n}`→a decompile-less concat BIN 64, `CFG.base[12]`→`1'b1` BIN 1, `CFG.base[31:0]`→the member's LOW 32 digits, `CFG` whole→the base constant OBJECT itself |
| `d2` | `d1`'s PACKAGE-holder twin (`p::C.n`) | the elaborated cells are IDENTICAL to `d1`'s — the holder is not a field of the fold |
| `d3` | MODULE LOCALPARAM holder + a wildcard-import copy | `struct_param_func_loop`'s own shape; both fold |
| `d4` | a 1024-bit packed-array member | the assembler does NOT bail on width — golden assembles 1056 bits and the member read still folds (r11u11's `asmOk8` width fence is NOT this site's rule) |
| `d5` | NEGATIVE CONTROLS: a PATTERN-built base, a plain int param, a member of a struct VARIABLE | a pattern-built base folds `UINT` through a different arm; a variable's member reads the EvalFunc leftover — neither is this law and neither moves |
| `d6` | a NESTED struct + packed-array members | golden's assembler BAILS (`struct_var`) and the reads fall to the leftover arm |
| `d7` | a SIGNED `int` member into signed and unsigned Lhs | golden re-renders `INT:-3` / `INT:4294967293` ct 7 through `adjustSize`'s `constantIsSigned` branch AND mutates the shared member typespec's `VpiSigned` — fenced OFF, ranked residue |
| `d8` | the ASSIGN TARGET kinds: plain, part-select, bit-select, concat, comma-list, gen-scope, net-decl | the target kind changes NOTHING but the size; every one folds in golden |
| `d9` | the VIEW MATRIX: one child instantiated twice + a grandchild re-pass | each elaborated copy folds to ITS OWN value (3 and 5) while the def listing stays symbolic |
| `d10` | the NON-cont_assign reading sites: procedural, port connection, range bound | **0 differing cells on the pristine binary** — the fold is the continuous assignment's |
| `d11` | THE SIZE AND ENCODING MATRIX (the table in §2) | ten cells, three `adjustSize` branches |
| `d12` | an INTERFACE body, a generate-FOR body, a child instance | all fold in golden; the interface and gen-scope emission sites are not this law's, recorded as residues |
| `d13` | the BUILDER-SHAPE matrix: nested-by-pattern / nested-by-member / packed array / enum / flat | names the ONE place our assemble answer is not golden's (see §4.2) |
| `d14` | TOP vs CHILD, DEFAULT vs OVERRIDE | the child instance is not the distinguisher — the OVERRIDE is, and it is an inherited residue |

## 4. The law

`src/ModuleEmit.cpp` (the record), `src/ParamEmit.cpp` (the drain),
`src/UhdmExporter.cpp` (one call) and one record struct in
`include/UhdmExporter.h`.  Nothing else is touched.

1. **RECORD, don't write.**  The producer's assembler bail is only final once
   both assemble arms have run (§ `modStructFuncAssembleBin`,
   § `pkgStructFuncAssembleBinBail`), so `emitContAssigns`'s top view records
   `{instance, the cont_assign slot, whether that slot IS the def object, the
   family base, the member, its MSB-first offset, its width, the struct's packed
   width, the bound Lhs width}` and `drainCaAsmMemberSlice` — called straight
   after `stampEvalFuncLeftovers` — reads the answer off the base's own
   elaborated `param_assign` Rhs.  A bail writes nothing and MINTS NOTHING, so
   the database stays byte-identical (the r11u9 lesson): the slot and the Lhs
   shape are both resolved BEFORE the first `MakeConstant`.
2. **The bits are the base constant's own.**  They are sliced out of its
   `VpiValue`, never re-derived from slang, and the constant must be EXACTLY the
   struct's packed width or the offset does not index the assembly.
3. **The def listing keeps its `hier_path`.**  Where the elaborated view was
   SHARING the definition object, the drain replaces that slot with a fresh
   `cont_assign` carrying a fresh Lhs — which is what golden does at exactly
   this point (`writeCont_assign`'s `cloned == false` guard).
4. **The typespec is the member's own object**, taken off the struct typespec
   this parameter actually points at — golden's `mts_found`.  A member whose
   typespec we cannot see declines the fold.
5. **The size rule is `adjustSize`'s, branch by branch** (§2's table), with
   `caLhsAdjustBind106` answering "does the Lhs bind".

### 4.1 THE FENCES, each with its measured witness

* **A bare member select only.**  An operation, a part-select, a bit-select or a
  member-of-member around the read is a different reduce arm with its own
  encoding (`d1`, `d6`).
* **THE NESTED-STRUCT FENCE.**  `d13` measures the one place our assemble/bail
  answer and golden's part company: a struct with a PACKED-STRUCT member written
  by a NAMED assignment pattern (`r.u = '{w:9, t:8'hA5}`) makes the producer's
  `assemble()` give up — its `tagged_pattern` operands do not reduce to
  constants — so golden's elaborated Rhs stays a `struct_var` and `C.n` folds
  `UINT:4` through the leftover arm, while WE assemble it.  Folding off our own
  constant there would move a cell that is merely wrong today onto a DIFFERENT
  wrong answer, so any struct with a packed-struct member is declined outright.
  `m_nest_mem` (the same struct written member-by-member, which golden DOES
  assemble) is declined with it — a residue, not a regression.
* **A SIGNED `int` member is declined** (`d7`): its branch re-renders the
  constant as `INT`/`vpiIntConst` and WRITES `VpiSigned(false)` onto the SHARED
  member typespec, which `int_typespec::Compare` reads.  That is a mutation law
  of its own; the corpus rows this pass converts read `int unsigned`.
* **A non-`ref_obj` Lhs is declined** on the shared path: the law only ever
  changes the Rhs, and a target shape it has not cloned is one it declines
  rather than guesses at.

### 4.2 What the four landed family laws keep

Pass 8's assemble arms, pass 10's member slice at the override site, pass 12's
whole-read encoding and pass 13's leftover encoding are all UNTOUCHED — this law
adds one new reading site and reads its answer OFF pass 8's constant.  Their
converted tests and bail witnesses are gated in §7.

## 5. Instruments

* `carhs.py <gold.dump> [<a.dump> [<b.dump>]]` — **THE CONTINUOUS-ASSIGNMENT RHS
  CENSUS**, keyed `(section, module, ORDINAL in that module's vpiContAssign
  list, span)` with the Rhs object KIND and, for a constant, the four fields
  `constant::Compare` / `expr::Compare` read UNCLIPPED plus its typespec chain;
  joined three ways and scored TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG /
  SAME-WRONG / SAME-RIGHT.  Four traps are encoded in it and documented in the
  file: (a) the dump's BACKREFERENCE form — a cont_assign the elaborated view
  SHARES prints with no children at all, which is recorded as the distinct
  payload `SHARED-WITH-DEF` rather than "an empty Rhs"; (b) `|vpiParent:`
  subtrees, which make every cont_assign print its own enclosing module inside
  itself and re-key a naive scanner; (c) THE ORDINAL, NOT THE Lhs NAME, IS THE
  KEY — a shared cell has no Lhs to key on, so an Lhs-keyed census reads every
  share as a missing key on one side and a phantom on the other (the first cut
  of this instrument did exactly that); (d) an ABSENT key and an unreadable Rhs
  print differently.
* `predict.py <corpus-root> [names...]` — the A-PRIORI mover predictor, from the
  SOURCES alone.  Names every test carrying `assign <t> = <P>.<m>;` where `<P>`
  is fed, possibly through a chain of bare references, by a member-by-member
  const function; tags `CA:` (this law's shape), `NDA:` (a net-declaration
  assign — golden folds it, this law's emission site does not reach it) and
  `~NEST` (the nested-struct fence).  Over-names by design.
  * REACH CONTROL: `testdirs()` WALKS — 861 uhdm2rtlil dirs, 700 Surelog suite
    dirs, 93 third-party dirs reached.
  * POSITIVE CONTROLS: `struct_param_func_arg` and `struct_param_func_loop`, the
    ONLY two names out of 861 uhdm2rtlil dirs, both `CA:CFG.n`.
  * The Surelog names are `StructParamFuncBodyFieldCompare` (`CA:Cfg.Flag` — the
    ASSEMBLER BAIL witness, whose head must not move), `FuncStructVal`
    (`NDA:CVA6Cfg.RVV` only) and third-party `Ariane2024` (`NDA:` only).
* `grid.sh`, `arm.sh`, `subset.sh`, `shapes.py` (THE SHAPE LISTER),
  `shapecmp.sh`, `dirscore.sh` (the order-blind directional census),
  `dirline.sh`, `rowcen.sh`, `pacen.py`, `pacmp.py`, `stamps.py` — carried from
  `tools/probe/r11u14repro` / `r11vu13repro`.
* `canaries.sh` / `ctcan2.sh` / `canaudit.sh` — the current-generation battery.

RESULTS CSVs ARE NOT EDITED BY THIS PASS.

## 6. What moved

**TWO ROWS CONVERT, both of them, in BOTH modes:**

```
< struct_param_func_arg,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_func_arg,testflags,CMP_EQUAL,,,differ
< struct_param_func_loop,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_func_loop,testflags,CMP_EQUAL,,,differ
< struct_param_func_arg,default,CMP_NOTEQUAL,decompile:,,
> struct_param_func_arg,default,CMP_EQUAL,,,differ
< struct_param_func_loop,default,CMP_NOTEQUAL,decompile:,,
> struct_param_func_loop,default,CMP_EQUAL,,,differ
```

uhdm2rtlil **757 -> 759 equal, 47 -> 45 not-equal in BOTH modes**; SLANG_REJECT
unchanged at 67.  Those four row-sides are the ONLY rows that differ against the
committed `results/gate_uhdm2rtlil.csv`, against `results/golden_uhdm2rtlil.csv`
and against this pass's own pristine sweeps.  The Surelog suite stays **468/15
(default) and 464/13 (testflags)** — zero status and zero dump-column moves.

`byteverify SELFCHECK=1`, uhdm2rtlil, patched vs this pass's own pristine
workdirs: **4 movers / 1608** (selfcheck 1607/1608 — the positive control that
the gate can see).  `struct_param_func_arg` and `struct_param_func_loop`, each in
both modes, and NOTHING ELSE.  Both were PREDICTED BY NAME by `predict.py` from
the sources before any patched sweep ran, and they are the ONLY two names it
gives out of 861 uhdm2rtlil test directories — the measured mover set is exactly
the predicted set.  `dirscore.sh`: **4/4 TO-GOLDEN, 0 AWAY-GOLDEN, 0 NEUTRAL**
(`struct_param_func_arg` 225 -> 200, `struct_param_func_loop` 429 -> 404
order-blind dump lines from golden, both modes).  `shapecmp.sh`: **0 rows GREW**
a shape-differing `param_assign` key.  `carhs.py` three-way on all four: every
moved cell TO-GOLDEN, **AWAY-GOLDEN 0, MOVED-WRONG 0**.

`byteverify SELFCHECK=1`, Surelog suite: **5 movers / 960** (selfcheck 959/960)
— `MiniAmiq` x2 modes, `SeqDriver` x2 modes, `SimpleUVM` default: the **proven
UVM coin family**, and nothing else.  Attributed ORDER-BLIND on
path-normalised sorted dumps: each is EXACTLY 4 lines and every one of them is
of the `UINT:<line>` / `vpiDecompile:<line>` LINE-NUMBER class
(`UINT:764`<->`UINT:1257`, `UINT:0`<->`UINT:861`, `UINT:1274`<->`UINT:694`,
`UINT:1241`<->`UINT:0`, `UINT:0`<->`UINT:1253`).
**POSITIVE CONTROL, pristine alone:** the PRISTINE binary run TWICE on
`MiniAmiq`'s own command line gives two DIFFERENT database md5s
(`f1a7220a397d…` vs `8325c4802ff6…`).  The count is a per-run draw, so these are
pinned by the NAME and the CLASS, never by the count.

The two Surelog names `predict.py` DOES give are the family's own BAIL
WITNESSES, and both are **byte-identical**: `StructParamFuncBodyFieldCompare`
(`CA:Cfg.Flag` — the assembler bails, so the drain writes nothing; still
CMP_NOTEQUAL, head unmoved) and `FuncStructVal` (`NDA:` only — a net-declaration
assign, which this emission site does not reach; still CMP_EQUAL).  Third-party
`Ariane2024` (`NDA:` only) builds no database on either binary in either mode.

**THE GRID.**  `carhs.py` three-way across all 14 arms: **TO-GOLDEN 32,
AWAY-GOLDEN 0, MOVED-WRONG 0**, SAME-RIGHT 99, SAME-WRONG 43.  `shapes.py`
across the grid: **no arm GREW** a shape-differing `param_assign` key (d1, d5,
d6 and d13 keep their 1, every other arm stays at 0).  `d1`'s head MOVES
FORWARD — `CFG.n` is now equal and the first difference is the part-select
`CFG.base[31:0]` (residue R2).  `subset.sh` over the 14 arms: NEW-DIFF-LINES 0
on twelve of them, RESOLVED 267; `d1` and `d2` show 2 "new" lines each, all four
of them bare structural lines (`|vpiParent:`, `|vpiActual:`,
`|vpiFullName:work@dut`) whose MULTIPLICITY changed because a folded constant
adds a subtree — the known family conflation in an order-blind LINE multiset,
and the keyed census reads AWAY-GOLDEN 0 / MOVED-WRONG 0 on both.

**THE BOUNDARY over every committed arm of the family**, both binaries:

| arm set | result |
|---|---|
| `r11u11repro` `a1`–`a12` | **12 of 12 BYTE-IDENTICAL**, `subset.sh` NEW 0 |
| `r11u13repro` `b1`–`b9` | **9 of 9 BYTE-IDENTICAL**, `subset.sh` NEW 0 |
| `r11u14repro` `c1`–`c10` | 9 BYTE-IDENTICAL; `c10` — the arm whose README named this pass's R0 as its head — **CONVERTS (1 head -> 0)**, NEW 0, RESOLVED 27 |
| `r11v11u9repro` `g1`–`g18`, `b2`, `b3` | 15 of 21 BYTE-IDENTICAL; `g7` **CONVERTS (1 head -> 0)**; `g1`,`g2`,`g3`,`g5`,`g13` move, every one TO-GOLDEN by the keyed census (AWAY 0, MOVED-WRONG 0) with their heads unchanged.  `g5` shows 2 "new" order-blind LINE-multiset entries (a `ref_typespec` line whose multiplicity changed) — the same conflation as `d1`/`d2`; its head is byte-for-byte what pristine had |
| `r11v11u9repro` `b1` | EXCLUDED: a multi-file arm with its own `vgrid.sh`, which the single-file driver cannot compile — an arm whose compile fails teaches error recovery, not golden |

## 7. Gates

| gate | result |
|---|---|
| pristine build md5 vs the main tree at `6c6d4768` | `d84acd3f88dab953d1b7348d80682a2d` — BYTE-IDENTICAL |
| patched build md5 | `ed5a9c1ae38338608d206509e5cbce88` |
| `tests/check_goldens.sh` (patched) | 23 PASS / 0 FAIL |
| `SLANG_UHDM=/bin/false` negative control | 0 PASS / 23 FAIL |
| u2r testflags vs `results/gate_uhdm2rtlil.csv` | 2 differing rows, quoted in §6 |
| u2r both modes vs `results/golden_uhdm2rtlil.csv` | the same 2 rows per mode, nothing else |
| u2r patched vs this pass's own pristine sweeps, both modes | the same 2 rows per mode, nothing else |
| surelog patched vs `results/golden_surelog.csv` | 468/15 (default) and 464/13 (testflags) — 0 status and 0 dump-column moves; 2 rows differ ONLY in the WORKDIR PATH inside a `SURELOG_FAIL` detail string (`LowMemLib`, `LowMemPkg`) |
| surelog patched vs this pass's own pristine sweep | the same 2 workdir-path-only rows, nothing else |
| `byteverify SELFCHECK=1` u2r | 4 / 1608, selfcheck 1607/1608; both names predicted a priori, every moved cell TO-GOLDEN |
| `byteverify SELFCHECK=1` surelog | 5 / 960, selfcheck 959/960 — the proven UVM coin family only, attributed order-blind to 4 line-number-class lines each, with a pristine-only positive control |
| `canaries.sh` surelog / u2r | ok=52 changed=0 absent=0 / ok=8 changed=0 absent=0 |
| `ctcan2.sh` surelog / u2r | PASS (ok=58 changed=0) / PASS (ok=1 changed=0) |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| HARD byte pins | `SVSwitch` 4842211c4030, `YosysVerx` 6ccda350c24a — both modes, both binaries |
| STATUS pins | `InterfaceModPort` 59a365f3ce2c, `BlackParrotComplex`, `YosysOldOr` — byte-identical pristine vs patched, both modes |
| `rowheads.sh` on the UVM / Earlgrey / Rggen rows | IDENTICAL pristine vs patched (12 measured, 2 SKIP-NOFILE as expected) |
| family bail witnesses | `FuncStructVal` CMP_EQUAL, `FuncStructValSimple` CMP_EQUAL, `StructParamFuncBodyFieldCompare` CMP_NOTEQUAL head unmoved, `struct_param_func_config` CMP_EQUAL, `param_nested_struct_field_width` / `struct_param_field_shift` / `struct_member_cfg_width` / `cva6_struct_param_field` / `latch_tlb_napot` CMP_NOTEQUAL, `pkg_nested_struct_param_width` / `portsel_struct_param` / `def_ctx_struct_param` / `latch_decoder_partial` CMP_EQUAL — all unchanged and all byte-identical |
| fence check (the four slang-fenced tests) | 0 hits in the production diff; 0 hits anywhere in `tools/probe/r11u16repro/`; no driver dispatches them |
| the patch on a FRESH `6c6d4768` | `git apply --check` rc 0, 0 conflict markers, and the rebuild reproduces md5 `ed5a9c1ae38338608d206509e5cbce88` |
| `results/*.csv` | UNTOUCHED |

Every sweep exported `SLANG_UHDM` explicitly and every `cmds.txt` was audited by
BINARY PATH: `u2rp` 1742 rows and `slp` 1531 rows all on the pristine binary,
`u2rq` 1742 and `slq` 1531 all on the patched one, 0 rows on any other binary.

## 8. Residues, ranked

* **R0 — the OVERRIDDEN function-built struct parameter is not assembled as
  BIN.**  Grid `d14` `kid_ovr` and `d9`/`d12`: `child #(.C(p::build(9)))` is
  golden the assembled `96'b…` BIN, and ours a `96'h…` HEX fold — so this law
  DECLINES it (§4, the packed-width guard) and every member read under such an
  instance stays unfolded.  It is the last structural gap between our
  assemble arm and golden's on this family, it is what leaves `d9`'s four cells
  and `d12`'s child and interface cells SAME-WRONG, and it is a PARAM-site law
  (§ `modStructFuncAssembleBin`'s surface), not this one.  No corpus row carries
  the shape today.
* **R1 — the WHOLE read of an assembled parameter in a continuous assignment.**
  Grid `d1`/`d2` `assign o_whole = CFG;`: golden's elaborated Rhs IS the
  assembled constant — the very OBJECT on a module holder (a backreference in
  the dump), a separate expanded copy on a package holder — where we share the
  def view's `ref_obj`.  An object-IDENTITY question of its own, and the
  holder split has to be decoded before it can be written.
* **R2 — a PART-SELECT or BIT-SELECT around the member read.**  Grid `d1`
  `CFG.base[31:0]` (now the arm's head) and `CFG.base[12]`, `d4`
  `CFG.wide[0]`, `d6` `CFG.arr[0]`: golden folds each through a DIFFERENT
  ExprEval arm — a part-select is the member's LOW `Bits(Lhs)` digits with the
  MEMBER's typespec, a bit-select a `1'b<x>` BIN 1 with NO typespec.  Measured
  cell by cell; deliberately outside this pass's surface.
* **R3 — the NESTED-STRUCT fence.**  Grid `d13` `m_nest_mem`: a struct whose
  packed-struct member is written MEMBER-BY-MEMBER does assemble in golden and
  its member reads fold, but the fence declines it along with the
  pattern-written twin `m_nest_pat`, where our assemble answer and golden's
  genuinely differ.  Lifting it needs the assemble arm to take the producer's
  `tagged_pattern` bail first.
* **R4 — a SIGNED `int` member.**  Grid `d7`: `adjustSize`'s `constantIsSigned`
  branch re-renders the slice as `INT:-3` / `INT:4294967293` with
  `vpiIntConst`, and — when the Lhs is unsigned — WRITES `VpiSigned(false)` onto
  the SHARED member typespec, which `int_typespec::Compare` reads.  A typespec
  MUTATION law; fenced off here.
* **R5 — the emission sites this law does not reach.**  A gen-scope cont_assign
  (`emitGenScopes`), an elaborated INTERFACE cont_assign (the fold-and-share
  builder in `emitInstance`) and a NET-DECLARATION assign all fold in golden
  (grid `d8`, `d11`, `d12`) and are untouched: the record rides
  `emitContAssigns`'s explicit-assign loop only.  `FuncStructVal`'s
  `NDA:CVA6Cfg.RVV` is the corpus witness, CMP_EQUAL and byte-identical.
* **R6 — the CONCAT around a member read.**  Grid `d1`/`d2`
  `assign o_cat = {CFG.n, CFG.n};`: golden mints the concat BIN at the sum of
  the operand sizes with NO decompile (§ r11u14's own concat rule, at a reading
  site instead of a leftover), where we keep the operation.
