# r11u33 — § rangeBoundReduceEnc33

**THE ENCODING OF A REDUCED RANGE BOUND IS `ExprEval::reduceExpr`'S OWN
ANSWER: THE OPERATOR TABLE ON THE OUTSIDE AND THE PARAMETER'S STORED `Value`
ON THE LEAVES.**

Base `c731550c`. LHS is ALWAYS golden. Judge: `uhdm-cmp`.

---

## 1. The brief, and what it asked first

The target was the r11u29 triage's K5 + K6 + K3 — ten tests on one decision,
"when does Surelog's constant reducer run at a range bound". The brief ordered
a CENSUS before a line was written, and the census split the ten into three
disjoint families that are NOT one law:

| family | tests | golden vs ours | this pass |
|---|---|---|---|
| **the fold ENCODING** (K6) | `genscope_struct_member`, `ibex_pmp`, `latch_perf_counters` | both sides FOLD; the constant's size / const type / value tag differ | **LANDED** |
| **the DEF-side no-reduce** (K5a) | `cva6_struct_param_field`, `StructParamFieldRange`, `mem_packed_2d_byte_write` | golden KEEPS the written operation, we fold | declined — R3 |
| **the ELAB-side reduce** (K5b) | `iface_param_2level` | golden FOLDS, we keep the operation | declined — R4 |
| **away from a range** (K3) | `bits_of_type_param`, `ibex_tracer`, `struct_param_pattern_packing` | not a range bound at all | declined — R5 |

Only the first is a decision about ENCODING. The other two are decisions about
whether to fold at all, they run in OPPOSITE directions, and suppressing a fold
is a different kind of change from re-encoding one. They are named residues
with their producer line cited, not claims.

## 2. The ten heads, re-measured at c731550c

Own pristine binary (md5 `723cb6db…`, byte-identical to the main tree's
`build/slang-uhdm` at the base), own sweeps, own workdirs. Every row carries
EXACTLY ONE head in both modes:

```
cva6_struct_param_field   76 cmplines 1 head      genscope_struct_member    36  1
mem_packed_2d_byte_write  56          1           ibex_pmp                  36  1
iface_param_2level       126          1           latch_perf_counters       36  1
bits_of_type_param        56          1           ibex_tracer               36  1
struct_param_pattern_packing 52       1           StructParamFieldRange(sl) 76  1
```

One head is a LOWER BOUND, not a cell count (masks cascade), so the WHOLE-DUMP
diff was taken beside it. It is what selected the landing:

| test | dump lines | differing dump lines |
|---|---|---|
| `genscope_struct_member` | 1456 | **4** (2 cells, one field) |
| `latch_perf_counters` | 2432 | **12** (2 cells, three fields) |
| `mem_packed_2d_byte_write` | 2445 | 155 |
| `bits_of_type_param` | 1398 | 121 |
| `struct_param_pattern_packing` | 3204 | 614 |
| `cva6_struct_param_field` | 1952 | 651 |
| `iface_param_2level` | 2852 | 949 |
| `ibex_pmp` | 80446 | 17138 |
| `ibex_tracer` | 181873 | 49741 |

`genscope_struct_member` and `latch_perf_counters` are the only two whose
ENTIRE database differs in this law's cells alone — the conversion candidates,
predicted before the code was written and confirmed after.

## 3. The census, and THE DISTINGUISHER

`rangecensus33.py` reads a `uhdm-dump` listing's own nesting and emits one row
per RANGE BOUND: `<view> <holder-chain> <range loc> <side> <shape+encoding>`.
It is the SHAPE LISTER as well as the census — an operation prints as
`op<type>(<operand kinds>)` and a constant as `<TAG>:<v>@<size>ct<ct>` — so a
"size" difference and a "kept the operation" difference can never be confused.
`cmpcensus33.py` pairs two listings; `score33.py` scores three (gold ×
pristine × law) into TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG /
UNMOVED. A cell present on one side only is its own bucket and is printed:
a census that reaches nothing must never read as perfection.

Read on the four grid arms of §4, the distinguisher is **not a site, a holder
or a view** — the packed-dim (`logic_typespec`) and the unpacked-range-dim
(`array_var`) sites agree cell for cell, and so do a module, an interface and
a package. It is the WRITTEN EXPRESSION, through `reduceExpr`'s own per-operator
arms:

```
bound                golden                bound              golden
[NU:..]  int unsigned 5   UINT:5  @32  ct9  [7:..]   literal   UINT:7  @64 ct9
[NS:..]  int          6   UINT:6  @32  ct9  [8'd7:..] sized    DEC:7   @8  ct1
[NX:..]  UNTYPED      7   UINT:7  @32  ct9  [NU+1:..]          UINT:6  @64 ct9
[NB:..]  byte         9   UINT:9  @8   ct9  [1+NU:..]          UINT:6  @64 ct9
[NL:..]  logic [7:0] 11   UINT:11 @8   ct9  [NU+8'd2:..]       INT:7   @32 ct7
[NU+MU:..]               UINT:8  @32  ct9  [NU-1:..]           INT:4   @64 ct7
[NB+NB:..]               UINT:18 @8   ct9  [NU*2:..]           INT:10  @64 ct7
[NU+NS:..]               UINT:11 @32  ct9  [NU/1:..]           INT:5   @64 ct7
[LU:..]  localparam int unsigned  @32  ct9  [NU<<1:..]         UINT:10 @64 ct9
[LX:..]  UNTYPED localparam       @32  ct9  [$clog2(NU):..]    UINT:3  @64 ct9
```

and the WIDTH a name lends is the parameter's STORED value width, which tracks
the OVERRIDE ACTUAL and not the formal — the same written `[NU:1]` under five
instances of one definition:

```
u_def   (default, int unsigned)       UINT:5  @32
u_lit   #(.NU(9))         bare decimal UINT:9  @64
u_nam   #(.NU(TOP_NU))    int unsigned UINT:12 @32
u_byt   #(.NU(TOP_NB))    byte         UINT:10 @8
u_exp   #(.NU(TOP_NU+1))  expression   UINT:13 @64
```

## 4. The producer, decoded

`CompileHelper::compileRanges`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:3963`) builds a
range's two bounds and reduces them ONLY when the call site passed
`Reduce::Yes` (`:4032`). The reduction is
`UHDM::ExprEval::reduceExpr` (`~/git-repos/UHDM/templates/ExprEval.cpp`), and
each operator arm stamps its own result constant:

| arm | line | size | const type |
|---|---|---|---|
| `vpiAddOp` / `vpiPlusOp` unsigned | `:3291` | `max(expr0->VpiSize(), expr1->VpiSize())` | `vpiUIntConst` |
| `vpiAddOp` signed | `:3305` | the same max | `vpiIntConst` |
| `vpiAddOp` real | `:3319` | the same max | `vpiRealConst` |
| `vpiSubOp` | `:3443` | 64 | `vpiIntConst` |
| mult / div | — | 64 | `vpiIntConst` |
| the shifts | `:3237` | 64 | `vpiUIntConst` |
| a system call | `:4542`, `:4567` | 64 | `vpiUIntConst` |

The ADD arm is the ONLY binary arm that carries an operand's size through, and
it takes the SIGNED branch when either reduced operand is
`vpiIntConst`/`vpiStringConst`/`vpiRealConst`/`vpiDecConst` (`:3267-3278`) —
which is why a based-decimal operand (`NU+8'd2`) flips the whole fold to `INT`.

A NAME reduces through `CompileHelper::getValue`'s instance arm
(`CompileExpression.cpp:980`), which mints the operand from the instance's
stored `Value`: `c->VpiConstType(sval->vpiValType())`,
`c->VpiSize(sval->getSize())`. That stored `Value` is
§ rangeBoundStoredWidth82's subject and `ovActualStoredWidth82`'s answer —
`adjustSize`d against the declared type when the parameter is not overridden,
the override actual's own constant (NO `adjustSize` on that path) when it is.

**The precedent this follows.** § dimExprBoundFold79 decoded the same operator
table for the SIZE-FORM `[N]` dimension and said in its own header what it was
leaving open: *"an ADD whose operands the model cannot size — a NAME, whose
reduced size is the parameter's own stored one — is REFUSED"*. This pass is
that name arm and nothing else in the table changes.

## 5. THE GOLDEN GRID

Four arms, `grid/`, every one compiled by BOTH producers with both rcs
recorded (`golden_rc=0`, `ours_rc=0` on all four; Surelog `[FATAL] : 0
[ERROR] : 0`). One cell per declaration, read at every site a range bound can
sit at, in every view the dump carries.

* `g1_shape33` — THE BOUND SHAPE. 20 written bounds × the packed-dim site and
  the unpacked-range-dim site. This is the table in §3.
* `g2_site33` — THE SITE, for three fixed shapes (`NU`, `NU+MU`, `NU-1`):
  PORT, body variable (packed / unpacked-range / unpacked-size), NET, TYPEDEF,
  a typedef's struct MEMBER, a localparam's declared type, a package parameter
  qualified and wildcard-bare, and a function local.
* `g3_hold33` — THE HOLDER and THE VIEW: a module instantiated five ways
  (default, bare-decimal override, named-typed override, narrower-typed
  override, expression override), an interface, and a package.
* `g4_keep33` — THE KEEP/FOLD DECISION: a struct-typed parameter's member read
  as a bound at every site, the same read through an interface MODPORT PORT,
  and a `localparam type` whose anonymous struct members carry it.
  ONE CELL IS NOT ON THIS GRID: a LOCAL interface instance used as
  `#(.SD(s.CFG.X))` is refused by slang outright (*"reference to 'CFG' by
  hierarchical name is not allowed in a constant expression"*), and an arm
  whose compile fails teaches error recovery, not golden — so the corpus's own
  modport-port shape is what the arm carries.

**Score (gold × pristine × law, per cell):**

| arm | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG | UNMOVED |
|---|---|---|---|---|---|
| `g1_shape33` | 18 | **0** | 0 | 4 | 40 |
| `g2_site33` | 8 | **0** | 1 | 3 | 44 |
| `g3_hold33` | 7 | **0** | 1 | 3 | 16 |
| `g4_keep33` | 0 | **0** | 0 | 6 | 21 |
| **total** | **33** | **0** | **2** | **16** | **121** |

The two MOVED-WRONG are not regressions and are not new classes: both are
cells whose SHAPE is a §7 residue (golden keeps an operation / a `ref_obj`
where we fold) and whose ENCODING this law corrected inside the wrong shape —
`g2` 78:17, a FUNCTION-local array bound golden keeps as `ref_obj (NU)`
(pristine `INT:5@64`, law `UINT:5@32`), and `g3` 12:9, a package variable whose
DEF copy golden keeps as `op24` (pristine two folds at 64, law two at 32, golden
one fold at 32 and one operation). Nothing that agreed with golden stopped
agreeing, on any arm.

## 6. What was written

Two production files, 247 added lines, no line removed.

* `src/TypeEmit.cpp` — `dimRedSzP33`, `dimRedSz79` **with the name arm** (the
  parameter's stored width via `ovActualStoredWidth82`, 64 when § 82 abstains
  on an OVERRIDDEN parameter because that abstention IS golden's answer there,
  and a full abstention otherwise); `boundReduceEnc33`, the two halves together
  with three abstentions.
* `src/TypeEmit.cpp` — the call at the **unpacked RANGE-DIM site**
  (`buildUnpackedRanges`' `mkBound`), which wrote a blanket `INT:<v>` ct 7 at
  64 for EVERY non-literal bound. Twelve of `g1`'s sixteen `array_var` cells
  were wrong in tag, const type and size at once; the four that already agreed
  (`[NU-1:1]`, `[NU*2:1]`, `[NU/1:1]`, a literal) are re-derived identically by
  the table and do not move.
* `src/TypeEmit.cpp` — the call at the **packed-dim site** (`makeTypespec`'s
  bound emitter), where `redInt` is already `reduceExpr`'s const-type table and
  the SIZE was the only thing missing, **gated on the top operator being an
  ADD**. `boundReduceEnc33` answers 64 on every other arm, so the gate costs
  nothing (the grid scores identically with and without it) — but it is not
  merely an optimisation: `boundReduceEnc33` RESOLVES NAMES, and a name
  resolution during definition-phase emission is the documented Heisenbug
  (RESUME.md §9, *"do not force AST binding during the DEF phase"*). Asking it
  on every binary bound reordered ONE `logic_typespec` block inside
  `Earlgrey_0_1`'s typespec pool — content-identical (the path-normalised
  ORDER-BLIND dump diff was 0 lines in both modes) and invisible to the judge,
  but a byte move in a PINNED database for no gain. With the gate,
  `Earlgrey_0_1` is not a mover at all.
* `include/UhdmExporter.h` — the three declarations and the law.

**The three abstentions, each measured:**

1. **A bare LITERAL is not a reduction.** `reduceExpr` hands a constant back
   untouched. `g1`'s `[8'd7:..]` is golden `DEC:7` ct 1 at 8 — an encoding this
   function does not spell — and the literal `0` right bound of
   `genscope_struct_member`'s own range is golden 64 on BOTH sides. Refusing
   both literal kinds is what keeps those cells still.
2. **A leaf § 82 cannot size and is NOT overridden.** `g1`'s
   `LX = NU + MU`, an UNTYPED localparam with a computed initializer, is golden
   32; guessing 64 would move a wrong cell to a differently wrong one.
3. **A negative fold** cannot wear the `UINT:` tag this encoder writes.

## 7. Residues

* **R0 — THE NEXT HEAD: the fold DECISION at a range bound, both directions,
  which this pass measured and declined.** `g4_keep33` holds both faces in one
  design. Golden KEEPS the written operation at a `localparam type`'s
  anonymous-struct MEMBER dimension (`59:11` `op11(hier_path,constant)`,
  `60:11` `op11(ref_obj,constant)` — BOTH bound shapes, so the rule is
  shape-independent) and at a body TYPEDEF's dimension, while FOLDING the very
  same written `Cfg.X-1` on the module's PORT (`32:47` → `INT:63@64`). We do the
  opposite at both. The producer says why: `compileRanges` reduces only under
  `Reduce::Yes`, and `CompileHelper::compileParameterDeclaration` builds a type
  parameter's typespec with `Reduce::No` and a null instance
  (`CompileHelper.cpp:3476`, `:3510` — § typeParamDefaultBoundNoReduce20's own
  citation), so the law wanted is **that § reaching the MEMBER dimensions of a
  type parameter's anonymous-struct default, and a body typedef's dimensions**.
  Corpus witnesses: `cva6_struct_param_field` + `StructParamFieldRange` (the
  same face in both corpora, head at the `localparam type` member) and
  `mem_packed_2d_byte_write` (head at a body typedef). It is a fold
  SUPPRESSION, not a re-encoding, and it needs its own census first:
  `cva6_struct_param_field`'s pristine database carries FIVE copies of that
  bound where golden carries TWO, so clearing the fold alone leaves a count
  mismatch standing.
* **R1 — the packed-dim BARE-NAME leaf that names a PACKAGE parameter.**
  `ibex_pmp`'s head is `logic [PMP_ADDR_MSB:0] region_start_addr [...]` with
  `parameter int unsigned PMP_ADDR_MSB = 33` wildcard-imported: golden
  `UINT:33` at 32, ours at 64. `g2_site33` 65:9 (`[g2pk33::PU:0]`, qualified)
  and 66:9 (`[PU:0]`, wildcard-bare) are the purpose-built twins, and 66:9 shows
  our two copies of ONE bound already disagreeing with each other (32 and 64).
  A MODULE parameter's bare packed bound already lands (every `g1` `[NU:0]`
  cell); this is § crossPkgRangeBoundFold / § patDefBoundPkgParamSubst's
  territory, a third site, and it converts nothing on its own — `ibex_pmp` has
  36 further STILL-WRONG range cells behind that head.
* **R2 — the ELAB interface array bound.** `g3_hold33`'s `logic if_arr [IU:1]`
  inside an interface instance is golden `UINT:6@32` and ours `UINT:6@64`: it
  goes through `buildUnpackedRanges`' dedicated `arrParentIdBound` interface
  arm, which returns before the fallback this pass re-encoded. One cell, no
  corpus witness found.
* **R3 — a FUNCTION-local array's bound.** `g2_site33` 78:17: golden keeps
  `ref_obj (NU)` unfolded; we fold. R0's family at a different site.
* **R4 — `iface_param_2level`, the OPPOSITE direction.** Golden folds
  `s.CFG.BUS.DAT-1` to `INT:31@64` on the elaborated `reg_data`'s range; we keep
  an `op11` whose operand is the OVERRIDE ACTUAL expression substituted into the
  bound (a `hier_path` carrying `work@…u.u_inner.reg_data.s.CFG.BUS.DAT`).
  `g4_keep33` 32:47 / 33:9 reproduce it. Closing it means INSTALLING a fold, the
  third kind of change again.
* **R5 — K3, away from a range.** `bits_of_type_param` (golden keeps
  `$bits(req_t)` as a `param_assign` Rhs, we fold `UINT:97@64`), `ibex_tracer`
  (golden keeps `ref_obj ibex_tracer_pkg::OPCODE_C0` as an operand, we fold
  `BIN 2'b00`), `struct_param_pattern_packing` (golden FOLDS `hier_path CFG.n`
  to `UINT:3@32`, we keep). Re-measured at the base, unchanged by this landing,
  and not range bounds at all — they belong to
  `tools/probe/r11u27repro/README.md:407` R0's own surface.
* **R7 — an UNINITIALISED read on a QUEUE typedef's `array_typespec` bound,
  found by this pass's own attribution and left standing.** `uvm_misc.svh:642
  typedef TYPE types_t[$]` gets an `array_typespec` whose range right bound our
  emitter fills from stale memory: the PRISTINE binary alone, run four times on
  `MiniAmiq`, wrote `1213`, `1530`, `760` and `1452` there (three distinct
  database md5s in three back-to-back runs). It is the whole of the UVM
  family's 4-line order-blind residue, it varies per INVOCATION on either
  binary, and no row's status depends on it. It is not this law's — a queue is
  not a `FixedSizeUnpackedArray` and neither call site reaches it — but it is
  the reason a byte-level attribution in that family must be order-blind AND
  run more than once.
* **R6 — a PACKAGE-scope `array_var`'s ranges are absent from our listing
  altogether.** `g3_hold33`'s `logic pa_nu [PU:1]` in a package: golden carries
  the range in both the def and the elaborated package copies (`ref_obj
  g3pk33::pa_nu::PU` and `UINT:4@32`), ours carries no such object. Two
  OURS-MISSING cells; a different family, found by this grid and left standing.

## 8. Instruments

* `rangecensus33.py` — the census AND the shape lister (one row per range
  bound: view, holder chain, loc, side, shape+encoding).
* `cmpcensus33.py` — pairs two listings (SAME / DIFF / OURS-MISSING /
  GOLD-MISSING).
* `score33.py` — the three-way cell score (gold × pristine × law).
* `pred33.py` — names the mover set A PRIORI from the PRISTINE databases, by
  the two signatures the law can reach, with `--selftest` as its positive
  control.
* `run33.sh` — the two-sided grid runner (inherited from `r11u27repro/run27.sh`).
* `grid/` — the four arms, their per-arm `CENSUS.gold` / `CENSUS.ours` /
  `CENSUS.law` and `SCORE.txt`. The `slpp_all` trees, the `.uhdm` databases and
  the raw dumps are regenerable and are not committed.
* `evidence/` — the ten pristine heads, the a-priori prediction, the byte
  verifier's output, the per-mover attribution and the gate log.

## 9. Gates

All in `GATES.r11u33.txt`, all green, every one against the pass's OWN
pristine binary and OWN pristine workdirs:

| gate | result |
|---|---|
| pristine worktree build | md5 `723cb6db14308de6a257e5c3bfd45f8f` — byte-identical to the main tree at `c731550c` |
| goldens | 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` → 23 FAIL (negative control) |
| u2r both modes | 768/36 → **770/34** in EACH mode; ct8rows names exactly the two converted rows and nothing else, in both directions |
| surelog both modes | 474/9 + 469/8 → **474/9 + 469/8**; every status and dump histogram identical |
| byteverify u2r | 10 / 1608 movers, SELFCHECK 1607/1608, all predicted a priori |
| byteverify sl | 7 / 960 movers, SELFCHECK 959/960, all predicted a priori |
| canaries | `canaries.sh` sl ok=51 / u2r ok=8, `ctcan2.sh` PASS ×2, `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected databases | every one byte-UNCHANGED, `Earlgrey_0_1` included (`8bdf25272e08` / `59d0ee6d10c3`) |
| `results/*.csv` | untouched |

**THE CONVERSIONS, predicted by name before the code was written and quoted in
full:**

```
< genscope_struct_member,default,CMP_NOTEQUAL,decompile:,,
> genscope_struct_member,default,CMP_EQUAL,,,match
< genscope_struct_member,testflags,CMP_NOTEQUAL,decompile:,,
> genscope_struct_member,testflags,CMP_EQUAL,,,match
< latch_perf_counters,default,CMP_NOTEQUAL,decompile:,,
> latch_perf_counters,default,CMP_EQUAL,,,match
< latch_perf_counters,testflags,CMP_NOTEQUAL,decompile:,,
> latch_perf_counters,testflags,CMP_EQUAL,,,match
```

Both go to `match` in the dump column as well: the whole database becomes
byte-identical to golden's, not merely judge-equal. `results/*.csv` is
READ-ONLY here — the rows above are the ones a landing may promote.
