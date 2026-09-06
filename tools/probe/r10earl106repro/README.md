# r10earl106 — § `genCaCastFoldAdjustSize106`: an elaborated gen-scope cont_assign whose Rhs is a CAST and whose Lhs `bindVariable` finds re-encodes its folded constant through `CompileHelper::adjustSize`

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

`Earlgrey_0_1` **testflags** went from **26 cmp lines / 1 head to 32 / 1** — a
line count that rises because the head **OBJECT CHANGED**: the constant at
`padctrl.sv:39` is gone and a different object at `pinmux.sv:157` is now first
(RESUME.md §9).  `Earlgrey_0_1` **default** is **byte-identical**.  Two
databases moved, one by the law and one by the recorded coin, and the census
scores **AWAY-GOLDEN 0 / MOVED-WRONG 0 / TO-GOLDEN 1** on surelog and
**0 / 0 / 0** on uhdm2rtlil.

* BASE COMMIT `143df9df`, branch `auto5h`.  Worktree `/tmp/wt_r10earl106`.
* Pristine binary md5 `9793b8253cc81350201a215044061a4f`, patched
  `72a6413dafd7567d87898e5f5731f470`.  Both frozen `chmod 555` at immutable
  paths **before any sweep**; every `cmds.txt` audited BY BINARY PATH
  (**0 of 6070 name the main-tree binary**).
* Production diff: `src/ModuleEmit.cpp`, `include/UhdmExporter.h`,
  `uhdm_main.cpp`.  One new static predicate, one new exporter method, one
  record site, one call.  `slang` is NOT patched.  `results/*.csv` were READ
  ONLY.  `GOLDEN_DEFER` unset throughout.

---

## 1. THE HEAD, and WHICH FIELD FAILS FIRST — decoded before a line of law

`rowheads.sh` on this pass's **own pristine build** (not carried forward):
`Earlgrey_0_1` **testflags 26 / 1**, **default 31 / 1** — different objects;
only testflags is this pass's.

```
LHS (golden)  constant  id:1054135   NO LOCATION
              |vpiDecompile:63  |vpiSize:8  |UINT:63  |vpiConstType:9
RHS (ours)    constant  id:1479540   line:39:24-39:38
              |no vpiDecompile  |vpiSize:64 |UINT:63  |vpiConstType:9
```

```systemverilog
padctrl.sv:36  logic [AttrDw-1:0] warl_mask;      // AttrDw == 8
padctrl.sv:37  if (Impl == prim_pkg::ImplGeneric) begin : gen_generic
padctrl.sv:39    assign warl_mask = AttrDw'(6'h3F);
```

**THE JUDGE, read out of the generated `Compare`s and not assumed**
(`~/git-repos/UHDM/build/generated/src/{BaseClass,expr,constant}.cpp`):

| order | reader | field | here |
|---|---|---|---|
| 1–3 | `BaseClass::Compare` | `VpiType`, `VpiName`, `VpiDefName` | all equal |
| 4 | `expr::Compare` | **`VpiDecompile`** | **`"63"` vs `""` — THE FIRST FAILURE** |
| 5 | `expr::Compare` | `VpiSize` | 8 vs 64 |
| 6 | `expr::Compare` | `Typespec` | `NONE` on both |
| 7 | `constant::Compare` | `VpiConstType` | 9 on both |

**No location is read anywhere** — not `VpiFile`, not `VpiLineNo`, not
`VpiColumnNo`.  So the loc-less-ness this pass also fixes is a FAITHFULNESS
question, not a judge question, and it is fixed because golden's object does not
carry one.  Note too that `expr::Compare` never reads `VpiValue`: the value
reaches the judge only through the decompiled spelling.

### The owner (`own106.cpp`, `OWNER.r10earl106.txt`)

`own106` is r10earl105's `own105.cpp` with ONE addition — the target may be named
`id:<UhdmId>`, because a LOCATION-LESS head cannot be named by span.  **ONE
holder, and it is the same one on both sides, object for object:**

```
golden constant#1054135  <- SINGULAR cont_assign 39:12-39:38  Rhs
                         <- gen_scope       work@top_earlgrey.u_padctrl.gen_generic
                         <- gen_scope_array work@top_earlgrey.u_padctrl.gen_generic
                         <- module_inst     work@top_earlgrey.u_padctrl
                         <- module_inst     work@top_earlgrey
ours   constant#1479540  <- the IDENTICAL chain
containers: VECTOR=0 SINGULAR=1   (both sides)
```

So this is a **WHOLE-Rhs** question on a SINGULAR edge — not an `Operands`
element (which is what r10earl105's head was), not a container size, and not a
typespec.

---

## 2. THE SURELOG DECODE — read out of the source, in three files

**`UhdmWriter::writeCont_assign`** (`Surelog/src/DesignCompile/UhdmWriter.cpp:2118`):

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {
    if (rhs->UhdmType() == uhdmoperation) {
      … clone_tree(assign) …
      any* rhstmp = m_helper.reduceExpr((expr*)rhs, invalidValue, …);
      if (expr* exp = any_cast<expr*>(var))                 // the LHS's
        if (const ref_typespec* rt = exp->Typespec())        //  TYPESPEC
          if (const typespec* t = rt->Actual_typespec()) tps = t;
      if ((invalidValue == false) && rhstmp)
        if (rhstmp->UhdmType() == uhdmconstant)
          rhstmp = m_helper.adjustSize(tps, mod, …, (constant*)rhstmp, /*uniquify*/true);
      assign->Rhs((expr*)rhstmp);
```

**THE PRODUCER** — `UHDM/templates/ExprEval.cpp:4074`, the `vpiCastOp` case.  Its
constant is `s.MakeConstant()` and is **never given a location**, which is
exactly why golden's is loc-less.  The branch depends on the cast typespec KIND,
and the two that matter here behave DIFFERENTLY:

| cast typespec | written as | value | size | mask at the cast width? |
|---|---|---|---:|---|
| `int_typespec` | a PARAMETER NAME (`AttrDw'`), and `int'` | `UINT:(int32_t)val0` | 64 | **NO** |
| `integer_typespec` | a LITERAL / expression (`8'`, `($clog2(256))'`) | `UINT:val0 & mask` | the cast width | YES (r10earl93 owns the ≥64 wrap) |
| `bit_` / `short_int_` / `long_int_` | | | 1 / 16 / 64 | |
| **anything else** | `byte'`, `logic'` | **`break` — NO FOLD** | | |

Neither branch writes a `vpiDecompile`.  Measured discriminator (`g2_form106`):
`4'(6'h3F)` onto a `logic[7:0]` gives golden **15**, `WU4'(6'h3F)` onto the same
Lhs gives golden **63** — same width, same operand, different spelling of the
width, and only the literal one masks.

**THE CONSUMER** — `CompileHelper::adjustSize` (`CompileHelper.cpp:3949`), the
`vpiUIntConst` arm (`:3990-4002`):

```cpp
int32_t size = Bits(ts, …);                                   // the LHS width
uint64_t uval = (uint64_t)eval.get_value(c) & NumUtils::getMask(size);
c = clone_tree(c);                                            // uniquify
c->VpiValue("UINT:" + std::to_string(uval));
c->VpiDecompile(std::to_string(uval));                        // THE SPELLING
c->VpiConstType(vpiUIntConst);
c->VpiSize(size);
```

`NumUtils::getMask(w)` (`NumUtils.cpp:94`) is `~0ULL` for `w >= 64`, so a
wider-than-word Lhs masks nothing.  `ExprEval::get_value`'s `vpiUIntConst` arm
(`ExprEval.cpp:2013`) parses with `NumUtils::parseIntLenient` into an `int64_t`,
so `UINT:-1` and `UINT:18446744073709551615` are the same 64-bit pattern — which
is why `WU96'(64'hFFFF…)` lands on golden's `18446744073709551615` at size 96.

**WHEN THE BIND FAILS THERE IS NO ADJUST AT ALL.**
`CompileHelper::bindVariable`'s scope walk (`CompileStmt.cpp:3089`) switches on
`function` / `task` / `begin` / `module_inst` **only** — it walks a `gen_scope`'s
parent chain straight past every gen-local declaration and stops dead at an
`interface_inst`.  Golden then keeps the fold's own 64-bit spelling-less
encoding **at the cast's span**, which this pipeline **already produces**.

---

## 3. WHERE THE CONSTANT COMES FROM ON *OUR* SIDE — the fact that moved the law

The law was written to re-encode in `emitGenScopes`.  **It cannot**, and that was
measured, not guessed: when `emitGenScopes` pushes the cont_assign, its Rhs is
**still the `vpiCastOp` operation**.  The constant appears afterwards, in
`uhdm_main.cpp`'s post-export passes:

* `UHDM::ElaboratorContext::listenDesigns` **CLONES the whole gen-scope tree**
  (the emitted `gen_scope` is unreachable tail by the time the design is saved:
  two `gen_scope` objects named `work@…gen_generic` exist, and only the clone is
  in the serialized `Gen_scope_arrays`);
* `UHDM::UhdmAdjuster::updateParentWithReducedExpression`
  (`UHDM/templates/UhdmAdjuster.cpp:331-345`) runs the SAME
  `ExprEval::reduceExpr` and then **stamps the operation's location onto the
  folded constant** — which is precisely the located, spelling-less, 64-bit
  object the head shows.

Surelog never reaches that adjuster arm for a bound Lhs, because
`writeCont_assign` has already replaced the Rhs with the ADJUSTED constant.  So
the pass records the consumer half during emission (the emitter is the only
place that knows the slang Lhs symbol and the written syntax) and applies it
**after the adjuster**, keyed on the gen scope's FULLNAME and the cont_assign's
SPAN — never on the pointer, which the elaborator has already replaced.

**THIS IS WHAT MAKES THE LAW SAFE.**  It only ever re-encodes a constant the
adjuster already made; it can never invent one.  Every cast neither tool folds
is structurally out of reach.

---

## 4. THE LAW

> **§ genCaCastFoldAdjustSize106** — In the ELABORATED view, a **gen-scope**
> continuous assignment whose **written Rhs is a CAST** and whose Lhs
> `bindVariable` finds (a plain name of a MODULE-BODY net/variable, a port
> included, whose declaration carries a typespec) re-encodes its folded
> `vpiUIntConst` Rhs through `CompileHelper::adjustSize`: **LOCATION-LESS**,
> `vpiSize` = the bound declaration's width, `VpiValue` masked to that width,
> and `vpiDecompile` the **decimal** spelling of the masked value.

`src/ModuleEmit.cpp` — `caLhsAdjustBind106` (the predicate), one record site in
the gen-scope cont-assign loop, and `applyCaCastAdjust106` (the post-adjuster
pass); `include/UhdmExporter.h` — the record vector and the method;
`uhdm_main.cpp` — one call, inside the `elabUhdm` block, after the adjuster.

`caLhsAdjustBind106` is a **deliberate copy** of r10earl68's `caLhsAdjustSize68`,
not a refactor of it.  That function answers 64 for TWO different facts — "no
bind / no typespec, so `adjustSize` does nothing" and "bound to a genuinely
64-bit declaration" — and its callers (r10earl68's genvar fold, r10earl78's
replication fold) neither can nor need to tell them apart.  **This law must**,
because the two have OPPOSITE golden answers:

```
assign t64a = 8'(6'h3F);    Lhs logic [63:0]  golden UINT:63 size 64 dc "63" LOCLESS
assign loc_c = W8'(6'h3F);  Lhs GEN-LOCAL     golden UINT:63 size 64 no dc   LOCATED
```

The copy is **strictly narrower** than the original: every case where
`caLhsAdjustSize68` returns 64 as "no adjust" returns `false` here, and the two
floating kinds it cannot distinguish (`shortreal`, `realtime`) return `false` as
well, since no arm of this pass measured them.  The campaign defers helper
extraction until 0 NE; rewriting `caLhsAdjustSize68` would put r10earl68's and
r10earl78's landed measurements at risk for no gain.

### The fences, each with a witness

| fence | witness (golden) |
|---|---|
| **ELAB only** | `applyCaCastAdjust106` runs inside `uhdm_main.cpp`'s `elabUhdm` block and walks `TopModules` only; every arm's PLAIN row is byte-identical between the two binaries (grid + boundary) |
| **a gen scope only** | the module-body twin `assign warl_mask2 = AttrDw'(6'h3F)` was ALREADY right on the pristine binary (`h1_head106`), and the 20 `mod`-home cast constants in the corpus census are all SAME |
| **a WRITTEN cast only** | `g3_val106`'s 8 NON-CAST rows: golden adjusts them too, but `n_litx` keeps `6'h3F` **and its location**, `n_parx` keeps its location, `n_catx` stays BINARY — a general re-encode would move cells AWAY.  Those shapes belong to § genvarWholeCaRhsFold68 / § genCaReplWholeFold78 / § genCaEnumWholeRhsFold25 and are untouched |
| **the Lhs must BIND** | `g1_home106` `gen_c` (gen-LOCAL), `gen_d` (bit-select), `gen_e` (part-select) and the INTERFACE row `if1_106.gen_if` — golden LOCATED, no decompile, 64, and all four are **SAME on both binaries** |
| **`vpiUIntConst` only** | `g2_form106`'s `c_negs` (`8'(signed'(-8'sd3))`) is a `vpiIntConst` with a signed `logic_typespec` and **already matches golden byte for byte, LOCLESS included** |
| **a cast neither tool folds is unreachable** | `byte'` / `logic'` (no ExprEval branch for those typespecs) and `8'(6'bzzzzzz)` (`get_value` invalid on X/Z) stay operations on BOTH sides — `g2_form106` c_byte / c_logic, `g3_val106` v_zzx |
| **r10earl105's window is UNDISTURBED** | `g4_fence106` §A is r10earl105's own head shape, `$bits(sleep_mux)'({MASKP,1'b1,1'b1,1'b1})` in a top-level loop body: our Rhs is an OPERATION there and stays one.  The wide boundary re-ran every committed r10earl105 arm and **none of them moved** |

---

## 5. THE GOLDEN GRID — the home axis, measured first (`g1_home106`)

One cell per row, ELAB view, the same cast `pg1_106::W8'(6'h3F)` throughout.

| home | LHS | golden | ours (pristine) |
|---|---|---|---|
| module body | `logic [7:0]` | LOCLESS 63 / 8 | **SAME** |
| gen-IF | `logic [7:0]` | LOCLESS 63 / 8 | LOC 64, no dc |
| gen-IF | `logic [3:0]` | LOCLESS **15 / 4** | LOC 64, no dc |
| gen-IF | `logic [15:0]` | LOCLESS 63 / **16** | LOC 64, no dc |
| gen-FOR | `logic [7:0]` | LOCLESS 63 / 8 | LOC 64, no dc |
| gen-IF inside gen-FOR | `logic [7:0]` | LOCLESS 63 / 8 | LOC 64, no dc |
| gen-else branch | `logic [7:0]` | LOCLESS 63 / 8 | LOC 64, no dc |
| CHILD instance's gen-IF | `logic [7:0]` | LOCLESS 63 / 8 | LOC 64, no dc |
| gen-IF | **GEN-LOCAL** | LOCATED no dc / 64 | **SAME** |
| gen-IF | **bit-select** | LOCATED no dc / 64 | **SAME** |
| gen-IF | **part-select** | LOCATED no dc / 64 | **SAME** |
| **INTERFACE**'s gen-IF | iface `logic [7:0]` | LOCATED no dc / 64 | **SAME** |

and the value axis (`g2_form106`, 20 cast-width forms; `g3_val106`, 20 value
forms + 8 non-cast controls; `g4_fence106`, 6 fence shapes) is in
`GRID.r10earl106.txt`.

---

## 6. THE CENSUS — predicted from PRISTINE, then re-scored

`cen106.cpp` is r10earl105's `cen105.cpp` with three changes, each forced by the
edge this pass moves and each written into its header:

1. **the node SPAN leaves the key.**  cen105 joined on it because a substituted
   constant and the `ref_obj` it replaced share a span; here golden's constant is
   LOC-LESS and ours is anchored at the cast, so a span in the key would split
   every moving cell into ONLY-GOLDEN + ONLY-OURS and score nothing.  The key is
   `(view, home, cont_assign Lhs fullname, cont_assign span, cont_assign
   ORDINAL, node DEPTH, occurrence index)`.
2. **the span is still MEASURED, in its own `LOC=` / `LOCLESS` column**, printed
   beside the payload and projected away by `--judge` — earl60's lesson read the
   other way round: a span-carrying payload HID a flip, so the span is reported
   and not judged.
3. **an ORIGIN column**: the shape of the GOLDEN DEF-view twin of each
   cont_assign (`org=operation,op=67` for a cast), so the population can be
   counted PER FOLD ORIGIN — which is what the law is gated on.

It also walks the two design ROOTS instead of scanning the arena, because this
corpus holds several cont_assign objects with the same
`(view, home, Lhs fullname, span)` and a map without an ordinal silently merged a
folded one with an unfolded one (measured on `g1_home106`: six phantom
ONLY-OURS rows).  RESUME.md §9: "a last-writer dict drops rows."

**CALIBRATION FIRST, golden vs golden** (`g1_home106`):
`agree=40 disagree=0 only_golden=0 only_ours=0`.

**THE PRISTINE POPULATION** (956 surelog + 1358 uhdm2rtlil databases, before a
line of the law was written) — ELAB depth-0 cells whose fold ORIGIN is a
`vpiCastOp`:

| | surelog | uhdm2rtlil |
|---|---:|---:|
| `operation > operation` in a gen scope (**unreachable to this law**) | 274 | 2 |
| `operation > operation` in a module body | 134 | 96 |
| `constant > constant` in a module body (already right) | 20 | 44 |
| `constant > constant` in a gen scope (already right) | 2 | 2 |
| **DIFF** | **4** | **0** |
| total | 434 | 144 |

The 4 DIFFs are: **2** module-body cast-TYPESPEC span cells
(`integer_typespec@866:29` vs `@866:0`) — a different family this law never
touches — and **2** that are the SAME Earlgrey `padctrl.sv:39` cell, one per
mode.  The two already-right gen-scope cells are `FuncBindGen` /
`CastInFunctionInGenBlock`'s `assign o = int'(get_casted_param())` onto the
32-bit `output int o`, where the re-encode is the **IDENTITY** (`UINT:4 / 32 /
"4"` in and out) — the must-stay floor, and the only cell in either corpus that
this law can reach and that was already correct.

**PREDICTION, WRITTEN DOWN BEFORE THE PATCHED SWEEPS** (`PREDICT_R0.txt` §4):
exactly ONE law-driven mover (`Earlgrey_0_1` **testflags**); `Earlgrey_0_1`
**default** does NOT move because our Rhs there is still an operation; uhdm2rtlil
ZERO; no row converts; AWAY-GOLDEN 0 and MOVED-WRONG 0.

**WHAT ACTUALLY MOVED** — `byteverify.sh SELFCHECK=1`:

```
uhdm2rtlil  MOVERS 0 / 1358   PATH_SETS_IDENTICAL, SELFCHECK 1357/1358
surelog     MOVERS 2 /  956   PATH_SETS_IDENTICAL, SELFCHECK  955/956
    ./testflags/Earlgrey_0_1  6d603492b6f9 <- da7542fd91e5   PREDICTED
    ./default/Scoreboard      d55c0ea322c7 <- 099b89b3bf80   THE COIN
```

**THE CENSUS RE-SCORED** (`score106.py`, which prints `GOLDEN-SIDE-IDENTICAL`
first and refuses to score otherwise) — `CEN_corpus_score.txt`:

| | surelog (666 798 cells) | uhdm2rtlil (47 008) |
|---|---:|---:|
| **AWAY-GOLDEN** | **0** | **0** |
| **MOVED-WRONG** | **0** | **0** |
| TO-GOLDEN | **1** | 0 |
| UNMOVED-GOOD | 645 410 | 46 952 |
| UNMOVED-BAD | 2 065 | 54 |
| UNREACHABLE / -CHANGED | 19 322 / **0** | 2 / 0 |
| ADDED / REMOVED | 0 / 0 | 0 / 0 |

and identically **AWAY 0 / MOVED-WRONG 0 / TO-GOLDEN 1** on the `--judge`
projection.  The single TO-GOLDEN cell is
`ELAB|genif|work@top_earlgrey.u_padctrl.gen_generic.warl_mask|39:12-39:38`:

```
constant,sz=64,ct=9,v=UINT:63,dc=,TS=NONE  LOC=39:24-39:38
   >  constant,sz=8,ct=9,v=UINT:63,dc=63,TS=NONE  LOCLESS
```

**THE WHOLE-DUMP ATTRIBUTION AGREES** (`ATTRIB.r10earl106.txt`,
workdir-normalised, sectioned at `_weaklyReferenced:`): the Earlgrey testflags
database changed by **5 lines out of 6 715 900**, all of them that one object,
**BODY 5 / TAIL 0**.  The Scoreboard mover is **92 raw changed lines and ZERO
order-blind (sorted-dump) changed lines** — RESUME.md §9's recorded coin to the
line — and `cen106` finds **ZERO** cast-origin cont_assign cells in Scoreboard on
either side, so the law cannot reach it.

---

## 7. MOVED-WRONG AND AWAY, SCORED IN BOTH COLUMNS

**AWAY-GOLDEN 0 and MOVED-WRONG 0** — on both corpora, on all 10 grid rows of
this pass's own arms in both views, on the 6 rows of r10earl68's/r10v68's arms
the boundary flagged, and on all 12 differing boundary cells.  The two columns
are scored separately throughout.

**THE FORGONE WINS — STILL-WRONG, not AWAY.**  Each is a cell where golden
adjusts and we still emit *exactly what pristine emitted*:

| class | where | why the law declines it |
|---|---|---|
| a cast whose OPERAND our emitter does not fold | `g3_val106` `v_catx` / `v_ccx` / `v_repx` (`8'({2'b11,4'hF})`, `8'({6{1'b1}})`) | the Rhs is still an OPERATION after the adjuster, so there is no constant to re-encode |
| the **PLAIN view** of every cast cell | every arm's `plain` row | golden's plain view carries the adjusted constant too; we keep the whole cast operation there because neither the adjuster nor this pass runs.  Residue R1 |
| `Earlgrey_0_1` **default**'s own copy of the head cell | `padctrl.sv:39` in default mode | our Rhs there is an `operation` whose cast typespec binds as a NAMED `int_typespec`, so the adjuster never folds it.  Unreachable to the judge in that mode anyway (the default head is an earlier object).  Residue R2 |
| a wider-than-word cast whose PRE-adjust value we get wrong | `g2_form106` `c_w96` is NOT one of these — it converges — but the class exists wherever our producer differs | the re-encode is faithful to whatever our producer gave; where that is already wrong the cell stays wrong, never AWAY |

---

## 8. THE BOUNDARY — `BOUNDARY_WIDE.*`, `BOUNDARY_ARMS.txt`

`wide106.sh` compiles **every `.sv` and `.v` under a COPY of this worktree's
`tools/probe` at ANY depth** — subdirectory arms included — on both frozen
binaries, both views, and byte-compares the workdir-normalised `uhdm-dump`.  The
file list is read on **fd 3** with children `</dev/null`, and PROCESSED is
asserted against LISTED.

```
LISTED=4768   PROCESSED=4768   identical=9146   DIFFERING=12   no_output=378
rc symmetry (A=patched / B=pristine):  rc=0 8771/8771   rc=3 362/362
                                       rc=4 387/387     rc=139 16/16
FENCED=0 — the four slang-fenced names appear 0 times in the list and were
           never dispatched.
```

The 16 `rc=139` per side are the pre-existing probe segfaults recorded since
r10earl82, identical on both sides.  The gate demonstrably SEES (12 differing
cells): its own positive control.

**All 12 scored against GOLDEN on both binaries (`BOUNDARY_ARMS.txt`):
AWAY-GOLDEN 0 and MOVED-WRONG 0 on every one.**

* **5 are this pass's own arms** (elab only) — TO-GOLDEN only; `h1_head106` and
  `g1_home106` converge **13/1 → 0/0**.
* **3 are r10earl68 / r10v68 arms** — the same `adjustSize` consumer, whose arms
  carry gen-scope cast cont_assigns beside their genvar ones:
  `a1_gv68` TO-GOLDEN 2, `v1_pos68` TO-GOLDEN 2, and **`v5_enum68` 13/1 → 0/0**,
  a free win on another pass's verifier arm.
* **4 are two files × two views and are r10uvm154's DOCUMENTED layout
  artifact**: `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv`.
  Sectioned at `_weaklyReferenced:`, **BODY 0 changed lines in all four**, TAIL
  12 / 12 / 8 / 8.  `l154_noenum.sv` is r10uvm154's committed LAYOUT PROOF source
  and its own header names the mechanism — a class-scoped
  `typedef <T> name[string]` mints a binary-layout-derived number into a tail
  constant, so ANY code motion moves it.  Neither file holds a generate scope or
  a cast.  The tail is unreachable to the judge (RESUME.md §9).

---

## 9. GATES — all green

| gate | result |
|---|---|
| build both, md5s | pristine `9793b8253cc81350201a215044061a4f`, patched `72a6413dafd7567d87898e5f5731f470` |
| goldens, `SLANG_UHDM` exported to the PATCHED binary explicitly | **PASS 23 / FAIL 0** |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags vs committed `results/gate_uhdm2rtlil.csv` | `ct8rows` **0 differing rows** |
| u2r testflags + default vs this pass's OWN pristine sweep | `ct8rows` **0 differing rows** (status AND dump column) |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL |
| surelog vs committed `results/golden_surelog.csv` (1588 rows) | `ct8rows` **0 differing rows — NO ROW CONVERTS** |
| surelog vs this pass's OWN pristine sweep | `ct8rows` **0 differing rows**; status histogram IDENTICAL (937 CMP_EQUAL, 19 CMP_NOTEQUAL, 567 SLANG_REJECT, 48 SURELOG_FAIL, 10 DEFERRED, 3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM) |
| surelog `byteverify SELFCHECK=1` | **MOVERS 2 / 956** — 1 PREDICTED BY NAME, 1 the attributed coin |
| canaries (`canaries.sh`) | surelog `ok=52 changed=0`, u2r `ok=8 changed=0` |
| supplementary canaries (`ctcan2.sh`) | **PASS** both corpora |
| canary audit (`canaudit.sh canaries.sh ctcan2.sh`) | `audited=29 UNCOVERED=0 FENCE-BREACH=0` **PASS** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `ReplicationPassedToInstance` | CMP_EQUAL both modes, byte-unchanged |
| wide boundary | PROCESSED 4768 = LISTED, rc symmetric, all 12 differing cells attributed (§8) |
| `cmds.txt` audit BY BINARY PATH | **0 of 6070 name the main-tree binary** |
| `GOLDEN_DEFER` | unset throughout |

**HEADS** (`rowheads.sh`, this pass's own sweeps):

| row | before | after |
|---|---|---|
| **Earlgrey_0_1 testflags** | 26 / 1 | **32 / 1 — a DIFFERENT head object** |
| Earlgrey_0_1 default | 31 / 1 | 31 / 1 (head log byte-identical) |
| SeqDriver (both modes) | 50 / 1 | 50 / 1 |
| SimpleUVM (both modes) | 17 / 1 | 17 / 1 |
| Scoreboard default | 95 / 1 | 95 / 1 |
| MiniAmiq (both modes) | 106 / 1 | 106 / 1 |
| BuildUVMPkg (both modes) | 106 / 1 | 106 / 1 |
| Rggen default | 0 / 0 | 0 / 0 |

---

## 10. RESIDUES

* **R0 — the next head is named, measured AND ITS OWNER FOUND.**
  `Earlgrey_0_1 testflags`, 32 cmp lines / 1 head
  (`HEAD_AFTER_Earlgrey_testflags.cmp`):

  ```
  LHS (golden)  constant  157:14-157:16
                |vpiDecompile:0   |vpiSize:2   |UINT:0  |vpiConstType:9
  RHS (ours)    constant  157:14-157:16
                |vpiDecompile:'0  |vpiSize:16  |BIN:0   |vpiConstType:3
  ```

  `own106` on the golden database names the holder, and it is NOT what the
  `vpiParent` chain alone would suggest:

  ```
  constant#704546  <- VECTOR operation op=75 155:43-158:4  Operands[1]
                   <- port 49:21-49:31  pwr_peri_i
                     <- module_inst work@top_earlgrey.u_pwrmgr 690:3-716:5
                       <- module_inst work@top_earlgrey
  containers: VECTOR=2 SINGULAR=0
  ```

  i.e. the **second member of a STRUCT ASSIGNMENT PATTERN** that is the
  **high_conn of a PORT**:

  ```systemverilog
  pwrmgr_pkg.sv:154   // default value (for dangling ports)
  pwrmgr_pkg.sv:155   parameter pwr_peri_t PWR_PERI_DEFAULT = '{
  pwrmgr_pkg.sv:156     wakeups: WakeUpPeris'(1'b1),
  pwrmgr_pkg.sv:157     rstreqs: '0
  pwrmgr_pkg.sv:158   };
  top_earlgrey.sv:710   .pwr_peri_i(pwrmgr_pkg::PWR_PERI_DEFAULT),
  ```

  Golden RE-TYPES the unbased `'0` to the MEMBER's own width as a **decimal
  `vpiUIntConst` of size 2** (`rstreqs` is `logic [HwRstReqs-1:0]`); we keep the
  literal's own **16-bit `BIN:0` with the `'0` spelling**, so `expr::Compare`
  fails at `VpiDecompile` (`"0"` vs `"'0"`) and then at `VpiSize` (2 vs 16).
  Both the SIZE and the SPELLING are wrong, and the size is wrong in a way that
  says we never sized it at the member at all.  The family is the standing
  brief's own — the assignment-pattern / `tagged_pattern` laws and the `'0`
  re-typing precedents (`grep "'0 re-typing"`, `grep "assignment pattern member
  default"`) — crossed with the port `high_conn` laws (the holder is a PORT, not
  a `param_assign`), and it is a DIFFERENT family from this pass's whole-Rhs
  `adjustSize`.  `VECTOR=2` is worth carrying forward: TWO operation objects at
  that span hold the same operand, so a fix must not assume a single writer.
  `Earlgrey_0_1 default` still stops at `LHS: <null>` on
  `u_pinmux.gen_mio_periph_in[0].data_mux` (`pinmux.sv:157`, a `logic_var` we
  emit and golden does not) — a DIFFERENT object, unchanged by this pass.
* **R1 — the PLAIN view of the whole family.**  Golden's plain view carries the
  ADJUSTED constant too (measured on `h1_head106`: LOCLESS `63` / 8); we keep the
  entire cast operation there, because on our side the fold is
  `UHDM::UhdmAdjuster`'s and the adjuster only runs under `-elabuhdm`.  Fixing it
  needs a PRODUCER (a fold), not this consumer.  Corpus cost: **zero** — every
  corpus cell in this family is in an elaborated database.
* **R2 — `Earlgrey_0_1` DEFAULT's copy of the very same cell.**  In default mode
  our Rhs at `padctrl.sv:39` is still an `operation` whose cast typespec binds as
  a NAMED `int_typespec` (`@12:17`, `name=AttrDw`) rather than the loc-less one
  the testflags build produces, and the adjuster does not fold it.  Same law,
  same cell, blocked one level below by § `castSizeElabScopeBind57`'s territory.
  Unreachable to the judge in that mode (the default head is an earlier object).
* **R3 — a cast whose OPERAND we do not fold.**  `8'({2'b11,4'hF})`,
  `8'({4'h3,4'hF})` and `8'({6{1'b1}})` in a gen scope: golden folds the whole
  thing to `UINT:63 / 8`, our Rhs stays an operation, so there is nothing to
  re-encode (`g3_val106` v_catx / v_ccx, `g4_fence106` §C).  Three arm cells,
  zero corpus cells.
* **R4 — the two module-body cast-TYPESPEC cells** the census turned up
  (`integer_typespec@866:29-866:50` in golden against `@866:0-866:0` in ours, one
  per mode).  A cast-typespec SPAN question in a `mod` home; this law only ever
  touches the constant, and only in gen scopes.

---

## 11. FILES

| file | what it is |
|---|---|
| `PREDICT_R0.txt` | the head decode, the Surelog decode, the prediction written BEFORE the patched sweeps, and the measured outcome beside it — including the one prediction whose REASONING was wrong and why |
| `OWNER.r10earl106.txt` | `own106`'s answer on both sides |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{testflags,default}.cmp` | the head logs, `uhdm-cmp` stderr |
| `own106.cpp` | the owner finder (r10earl105's, plus an `id:` selector) |
| `cen106.cpp`, `cenrun106.sh`, `score106.py` | the census, its corpus driver and the three-way scorer |
| `CEN_corpus_score.txt` | both corpora, plain and `--judge` |
| `grid106.sh`, `GRID.r10earl106.txt`, `TOPS.txt` | the arm grid |
| `h1_head106.sv` | the head shape, reduced from `padctrl.sv:36-45` |
| `g1_home106.sv` | the HOME axis (12 cells) |
| `g2_form106.sv` | the CAST-WIDTH FORM axis (20 cells) |
| `g3_val106.sv` | the VALUE FORM axis + 8 NON-CAST controls |
| `g4_fence106.sv` | the fences, r10earl105's own head shape first |
| `wide106.sh`, `BOUNDARY_WIDE.*`, `BOUNDARY_ARMS.txt` | the wide boundary and every differing cell scored |
| `ATTRIB.r10earl106.txt` | every byte mover, attributed line by line |
| `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the gate battery, copied from their owning passes unchanged |
