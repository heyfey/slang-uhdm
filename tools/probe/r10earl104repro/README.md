# r10earl104 — § `replFoldElabSelRead104`: the folded replication's minted typespec survives unless a POSITIVE enumeration of the parameter's reads finds one that takes it away

Everything in this directory is **MEASUREMENT ONLY**.  The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.

BASE `4fbf5d0`, branch `auto5h`.  Pristine binary `3002e867e713`, patched
`03e245f81087`.  `GOLDEN_DEFER` unset throughout; `results/*.csv` read only.

---

## 1. THE HEAD

`Earlgrey_0_1`, **both modes**, 34 cmp lines, **1 head, ONE object**
(`grep -c '^LHS:'` = 1 per run), the two modes' head logs byte-identical
(`HEAD_BEFORE_Earlgrey_*.cmp`), re-measured here on this pass's own pristine
build:

```
LHS (golden)  int_typespec  id 595640   no location, no name, no range
              |UINT:1
RHS (ours)    logic_typespec id 772036  no location
              |vpiRange -> range |vpiLeftRange constant UINT:31
                                 |vpiRightRange constant UINT:0
```

**The owner, re-confirmed** (`own104.cpp` = earl102's `ref_typespec` scan
verbatim; `OWNER.r10earl104.txt`) — ONE holder on each side and the SAME one,
so this is a `Typespec` EDGE, not a container:

```
module_inst work@top_earlgrey.u_pinmux
  > Param_assigns > param_assign 53:56-54:59          pinmux.sv
    > Rhs constant 54:22-54:59   (the folded {32{1'b1}} replication)
      > Typespec ref_typespec {work@top_earlgrey.u_pinmux}
        > THE HEAD
```

The two sides are different KINDS, so `BaseClass::Compare` fails at the
`VpiType` and the whole object is the head.  `int_typespec::Compare` reads
VpiType / VpiName / VpiDefName / `Typedef_alias` / `Instance` / `Cast_to_expr` /
`VpiSigned` / `Ranges` and **never `VpiValue`**; `typespec::Compare` never reads
`VpiFile` or the span.

```systemverilog
pinmux.sv:53   localparam logic [pinmux_reg_pkg::NMioPeriphOut-1:0] MioPeriphHasSleepMode
pinmux.sv:54                    = {pinmux_reg_pkg::NMioPeriphOut{1'b1}};
pinmux_reg_pkg.sv              parameter int NMioPeriphOut = 32;
```

---

## 2. WHY THE PREVIOUS ATTEMPT WAS WRONG, AND WHAT REPLACES IT

The mint itself is not in dispute.  `UHDM/templates/ExprEval.cpp`, `reduceExpr`,
`case vpiMultiConcatOp` (~3866) is the ONLY arm that hands its folded constant a
typespec:

```cpp
if (width) {                                   // width = the REPLICATED
  int_typespec *ts = s.MakeInt_typespec();     // OPERAND's own VpiSize
  ts->VpiValue("UINT:" + std::to_string(width));
  ref_typespec *rt = s.MakeRef_typespec();
  rt->Actual_typespec(ts); rt->VpiParent(c); c->Typespec(rt);
}
```

`{32{1'b1}}` therefore mints `UINT:1`, which is golden's value verbatim.
`DesignElaboration.cpp::collectParams_` (~2495-2545) stamps the DECLARED
typespec only `if (c->Typespec() == nullptr)`, so a replication fold KEEPS the
mint and caches it on the instance's `Value`; and
`NetlistElaboration.cpp::elab_parameters_` (~397-460) lets that cached `Value`'s
typespec override the declared one on the elaborated `param_assign` — unless a
READER made `ModuleInstance::getValue` (`Design/ModuleInstance.cpp:132`) resolve
the name out of the netlist's own `param_assigns` through
`exprBuilder.fromVpiValue(...)`, which produces a typespec-less Value.  So a
READ can take the mint away, and § `replFoldTsW1` (earl55) minted it only at
declared width 1 because at width > 1 the reader decides.

**r10earl103 decided the reader NEGATIVELY** — "the two AST scans
(§ `caOperandScanRead49` / § `selectReadNeedsReduce50`, via
`UhdmExporter::paramCaFoldRead`) found no reader, therefore there is none."
Those scans walk exactly three things: a **continuous assign**, an
**instance's parameter overrides and port connections**, and an **instantiated
generate block's body**.  Their own comments say so.  Everything else they never
enter, and a verifier convicted **twelve shapes** in those unentered positions,
**two of them `CMP_EQUAL` -> `CMP_NOTEQUAL`** (`vb2_genfor`, `vb4_instarr`).
"Not found by a scan that does not look" is not a measurement.

**This pass replaces that with a POSITIVE enumeration.**
`UhdmExporter::replFoldElabSelRead104` walks the parameter's home
module/interface/program **declaration syntax** and enumerates every
**SELECTED** reference to the parameter's name outside a procedural block, a
subroutine body and an assertion.  The two tests are **ANDed** at the call site,
so **either one firing BLOCKS the mint**: an unenumerated read position costs a
WIN and never a regression — the cell simply keeps the declared bounds pristine
already gave it.

---

## 3. THE POSITIVE READ ANALYSIS — cell by cell, measured

One module, one `localparam logic [W-1:0] X = {W{1'b1}}`, exactly ONE read of
it.  Golden `int_typespec@LOCLESS UINT:1` = the read **KEEPS** the mint (a cell
the law may win); golden `logic_typespec[W-1:0]` = the read **TAKES IT AWAY**
(a cell the law must not touch).  Widths {4, 32} where the arm crosses them.
Arms `g4_cons104` (15 consumers × 2 widths), `g5_gscope104` (10 read HOMES × 2
widths), `g6_mix104` (6 mixtures), `g7_pos104` (14 positions built for this
pass), and the r10earl103 verifier's `va1`-`va5` / `vb1`-`vb4` carried here
verbatim.  **No counterexample.**

### The SELECT column

| the read | golden | who blocks it |
|---|---|---|
| net / variable declared RANGE `logic [X[0]:0] w;` — va1.r5, va1.rc, vb1 | TAKES IT AWAY | **104** |
| typedef declared RANGE — va1.r8, vb3 | TAKES IT AWAY | **104** |
| packed struct MEMBER range, module level — va3.s1 | TAKES IT AWAY | **104** |
| UNPACKED array dimension `logic w3 [X[0]:0];` — va3.s3 | TAKES IT AWAY | **104** |
| another parameter's DIMENSION `localparam logic [X[0]:0] Y;` — va3.s6 | TAKES IT AWAY | **104** |
| INSTANCE ARRAY dimension `u_e [X[0]:0]` — va1.re, vb4 | TAKES IT AWAY | **104** |
| loop-generate CONTROL (init/stop/iter) — va1.r4, va3.s8, vb2 | TAKES IT AWAY | **104** |
| generate-if / generate-case CONDITION — g4.c5, g5.d3, g6.f3, va1.ra | TAKES IT AWAY | **104** |
| net RANGE inside a generate scope — va3.s5, g7.k8 | TAKES IT AWAY | **104** |
| another parameter's INITIALIZER *inside a generate scope* — va3.s4 | TAKES IT AWAY | **104** |
| a cont-assign / override / port connection — g4.c1, g4.c7, va2.h5, va3.s7, va3.sa, va5.e3, va2.ifr4 | TAKES IT AWAY | `paramCaFoldRead` **and** 104 |
| inside a PROCEDURAL block — va1.r9, va1.rd, g4.c8, g4.ca | keeps | *(excluded)* |
| a variable declaration's own range INSIDE a procedural block — g7.k9 | keeps | *(excluded)* |
| inside a FUNCTION body — va5.e4, g6.f6; and a function local's range — va3.s2 | keeps | *(excluded)* |
| inside a TASK body — g7.kc | keeps | *(excluded)* |
| inside a CONCURRENT ASSERTION — va5.e2 | keeps | *(excluded)* |

### The BARE column — never blocked by the syntax enumeration

| the read | golden | who blocks it |
|---|---|---|
| generate-if CONDITION `if (X)` — g7.k1 | **keeps** | nobody — WON |
| generate-case CONDITION `case (X)` — g7.k2 | **keeps** | nobody — WON |
| generate-case ITEM LABEL — g7.k3 | **keeps** | nobody — WON |
| net declared RANGE `logic [X:0]`, `[(\|X):0]`, `[X-14:0]` — g7.k4, va4.b1, va4.b3 | **keeps** | nobody — WON |
| instance-array RANGE `u_e [X:0]` — g7.k5 | **keeps** | nobody — WON |
| loop-generate control `(\|X)+1` — va4.b2 | **keeps** | nobody — WON |
| another parameter's INITIALIZER `\|X`, `$clog2(X)` — va1.r2, va1.r3, va4.b4 | **keeps** | nobody — WON |
| bare parameter-override actual `#(.P(X))` — g4.c6, g7.k7 | **keeps** | nobody — WON |
| a generate scope's cont-assign — g5.d1, d4, d5, d6, da | **keeps** | nobody — WON |
| a MODULE-BODY cont-assign that FOLDS — g4.c3 `assign o2 = X;`, g4.c9 `\|X`, g4.cb, g4.cc, g5.d7, g5.d8, g7.k6 `assign w6 = $bits(X);` | TAKES IT AWAY | `paramCaFoldRead` |
| a module-body cont-assign that does NOT fold — g4.cd `ext ^ (\|$bits(X))` | **keeps** | nobody — WON |
| a HIERARCHICAL read from the PARENT — va2.h1 | **keeps** | nobody — WON |
| no read at all — g4.c0, va1.r7, va1.rb, va2.h4, va2.if4, g7.ke | **keeps** | nobody — WON |

**Two recorded readings REFUTED here, both by the arms above.**
1. r10earl103's `paramGenCondRead103` harvested a **BARE** generate-condition
   name as well as a selected one, on the argument that harvesting more is
   "the safe side".  `g7.k1`, `g7.k2` and `g7.k3` measure that position
   directly: golden **keeps** the mint for a bare generate-if condition, a bare
   generate-case condition and a bare case-item label.  Harvesting them throws
   three measured wins away, so this pass counts SELECTS ONLY and
   `paramGenCondRead103` does not exist here.  The Earlgrey cells that scan
   existed for (`DioPeriphHasSleepMode`, `DioPeriphHasWkup`) are
   `if (Dio…[k])` — **selects** — so the select rule covers them.
2. earl55's README explains pinmux.sv:176 as *"a `$bits()'( )` cast (int,
   unreduced)"*.  `g4.cb`/`cc` put the same cast at MODULE level and golden
   takes the mint away at both widths; `g5.d4` is `cc` moved into a
   `for (genvar …)` and golden keeps it.  The cast is not the discriminator.

### The corpus is answered exactly

`MioPeriphHasSleepMode` is declared at `pinmux.sv:53-54` and read **once**, at
`:176`, and the enumeration is a grep over the whole file, not a scan's opinion:

```systemverilog
for (genvar k = 0; k < NMioPads; k++) begin : gen_mio_out
  ...
  assign sleep_mux = $bits(sleep_mux)'({MioPeriphHasSleepMode, 1'b1, 1'b1, 1'b1});
```

a **BARE** read inside a **generate scope** — arm `g5.d4` — so neither
enumeration fires and the mint survives, which is golden's `int_typespec UINT:1`.
`DioPeriphHasSleepMode` (`:108`, `:194`) and `DioPeriphHasWkup` (`:215`) are
`if (…[k])` **selects in generate-if conditions**, so the syntax enumeration
blocks them and they keep the declared `logic_typespec[14:0]` we already emit.

---

## 4. THE LAW

`src/ParamEmit.cpp`, § `replFoldElabSelRead104`, inside § `replFoldTs`'s
`PackedArrayType && isIntegral()` branch:

```cpp
const bool replRead104 = paramCaFoldRead(ps) || replFoldElabSelRead104(ps);
if (topView && !inPackage &&
    (rct.getBitWidth() == 1 || (!isImported && !replRead104))) {
    auto* itsW1 = s.MakeInt_typespec();
    itsW1->VpiValue("UINT:" + std::to_string(<the REPLICATED OPERAND's width>));
    rt->Actual_typespec(itsW1);
} else {
    /* unchanged: the declared bounds */
}
```

plus `replFoldElabSelRead104` and its per-declaration cache beside
`paramNameIsRead`.  The mint object, its `VpiValue` and the width-1 branch are
byte-for-byte earl55's; the only new thing is the condition at width > 1.

**FENCES, each with a witness.**
* `topView` + `!inPackage` are § `replFoldTsW1`'s own and are untouched — in a
  PACKAGE golden's folded Rhs carries **no typespec at all** (earl55's
  `pk5_55::PKW1`; `g3_home104`'s `pk3_104::PX` is byte-unchanged here), and
  every DEF row of every arm is `SAME`.
* `!isImported` keeps the question inside the body that OWNS the parameter:
  both enumerations resolve against the enclosing `InstanceBody` / module
  declaration, and an imported package parameter has neither, so "no read"
  would be an artefact of asking the wrong scope (`va2.h9`).
* At width 1 the reader is **not consulted**: earl55 measured 25 cells across
  11 consumers with no exception, so that answer stays unconditional.

---

## 5. THE CENSUS — predicted from PRISTINE, then re-scored

`cen104.cpp` censuses **every `param_assign`** on both sides of both corpora,
keyed on `(view, Lhs VpiFullName, param_assign line:col)`.  The VIEW is in the
key because DEF (`design::AllModules`) and ELAB (`design::TopModules`) hold
`param_assign`s at the SAME span for the SAME parameter (earl55's lesson); the
key carries NO FILE because our `param_assign`s have an empty `VpiFile` and
`param_assign::Compare` never reads it.  The payload is the typespec rendered
as a **STRING** — kind, loc-less-or-span, name, signedness, `VpiValue`, every
range bound verbatim — plus the Rhs constant's own encoding (uvm159's lesson:
score the STRING, never a count).  The ORIGIN of a folded ELAB constant is read
off the **GOLDEN** DEF-view `param_assign` at the same span, which still holds
the unfolded initializer (`op34` = `vpiMultiConcatOp`).

**CALIBRATION FIRST, golden vs golden:** Earlgrey/default
`agree=13190 disagree=0 only_golden=0 only_ours=0`; SeqDriver/default
`agree=472 disagree=0`.

**THE PRISTINE POPULATION** (956 surelog DBs + 1358 uhdm2rtlil DBs, before a
line of the law was written) — cells where golden holds a **loc-less
`int_typespec`** and we hold a `logic_typespec`, ANY origin, ANY view, BOTH
corpora: **EXACTLY 2**, both the head, `Earlgrey_0_1` default and testflags.
uhdm2rtlil holds **ZERO** `op34` `param_assign` cells at all — nothing to fix,
nothing to break, and that is also the instrument's calibration over 1358
databases.

**THE AWAY RISK, ENUMERATED BY NAME BEFORE THE BUILD.**  The universe the law
could touch (ELAB view, `op34` origin, ours a loc-less `logic_typespec`) is 84
surelog cells, **82 of which AGREE with golden today** — 82 chances to go
AWAY.  Every one was checked against its source first, and every one is a
SELECT (details in `PREDICT_R0.txt` §3): the pinmux `Dio…[k]` generate-if
conditions; `tlul_socket_1n.sv:184-187` `.ReqPass(DReqPass[i])` /
`.ReqDepth(DReqDepth[i*4+:4])`; `tlul_socket_m1.sv:122-125` the same shape for
`HReqPass`/`HReqDepth`/…; `ElabCParam` `DReqDepth[1*4+:4]`; `BitSelect`
`AlertAsyncOn[0]`.

**PREDICTION: EXACTLY TWO DATABASES MOVE — `Earlgrey_0_1` default and
testflags.  u2r: ZERO.  No row converts.  `ReplicationPassedToInstance` stays
CMP_EQUAL and byte-unchanged.**

**WHAT ACTUALLY MOVED** (`byteverify.sh SELFCHECK=1`, patched vs this pass's
OWN pristine sweep; both binaries frozen `chmod 555`; every `cmds.txt` audited
BY BINARY PATH — 2981 of 3035 name the frozen binary, the other 54 have no
`slang:` line at all, and **0 of 6070 name the main-tree binary**):

```
uhdm2rtlil  MOVERS 0 / 1358   PATH_SETS_IDENTICAL, SELFCHECK 1357/1358
surelog     MOVERS 2 /  956   PATH_SETS_IDENTICAL, SELFCHECK  955/956
    ./default/Earlgrey_0_1     5b86d1db45c6 <- 2ea0cb924f32
    ./testflags/Earlgrey_0_1   57e778aad5aa <- 2b5e58514535
```
the two PREDICTED databases and nothing else; Scoreboard/default did not flip
its coin this run.

**THE CENSUS RE-SCORED** (`score104.py` prints `GOLDEN-SIDE-IDENTICAL` first and
refuses to score otherwise) — `CEN_corpus_score.txt`:

| | surelog (39 986 cells) | uhdm2rtlil (68 518) |
|---|---:|---:|
| **AWAY-GOLDEN** | **0** | **0** |
| **MOVED-WRONG** | **0** | **0** |
| TO-GOLDEN | **2** | 0 |
| UNMOVED-GOOD | 5 573 | 27 320 |
| UNMOVED-BAD | 34 411 | 41 198 |
| ADDED / REMOVED | 0 / 0 | 0 / 0 |

and identically `AWAY 0 / MOVED-WRONG 0` on the `--judge`, `--ts` and
`--ts --judge` projections.

**THE WHOLE-DUMP ATTRIBUTION AGREES TO THE LINE** (`ATTRIB.r10earl104.txt`,
workdir-normalised): **15 changed lines in default** (of 4 717 847) and **15 in
testflags** (of 6 714 454).  One hunk per mode is in the BODY — the
`logic_typespec` -> `int_typespec` swap under `module_inst
work@top_earlgrey.u_pinmux > param_assign 53:56-54:59 > constant 54:22-54:59 >
ref_typespec{work@top_earlgrey.u_pinmux}` — and the other two (the new
typespec's own listing entry with its `|UINT:1`, and the old one's 11-line range
subtree) are BELOW the `_weaklyReferenced:` marker.  **Nothing else in either
database moved**, the `gen_mio_periph_in[0].data_mux` subtree included.

---

## 6. MOVED-WRONG AND AWAY, SCORED IN BOTH COLUMNS

**Among cells the judge can reach: AWAY-GOLDEN 0 and MOVED-WRONG 0** — on both
corpora, on all 26 grid arms in both views, and on every arm the wide boundary
flagged.  The two columns are scored separately below because that is where
r10earl103 was convicted.

**The FORGONE WINS — STILL-WRONG, not AWAY.**  Each is a cell where golden
holds the loc-less `int_typespec` and we still emit the declared bounds, i.e.
*exactly what pristine emitted*: nothing regressed, a win was declined.  Four
over-block classes, **15 cells** (30 rows across the two views), named:

| class | cells | why the enumeration cannot separate it |
|---|---|---|
| a SELECT in a **module-level** parameter initializer | `va1.u_r1_4.X`, `va1.u_r1_32.X`, `v4_v55.u_q4.u_n2.S` — **3 cells, 6 rows** | golden keeps the mint here but takes it away for the same select in a **gen-scope** parameter initializer (`va3.s4`); the walk does not separate them |
| a SELECT in a **non-constant** cont-assign expression | `a4_earl55.u_c2_4.X`, `a4_earl55.u_c2_15.X`, `g4.u_c2_4.X`, `g4.u_c2_32.X`, `g4.u_ce_4.X`, `g4.u_ce_32.X`, `va3.u_s9.X`, `g7.u_kd.X`, `v1_v55.u_n6.Y`, `v6_v55.u_s4b.OV` — **10 cells** | the walk cannot see that a net operand stopped Surelog's reduction |
| a SELECT inside an **uninstantiated** generate branch | `va5.u_e1.X` — **1 cell** | syntax cannot tell `if (0)` from `if (1)`, and the instantiated twin (`va3.s5`) must stay blocked |
| a SELECT in a packed-struct member range **inside a generate scope** | `g7.u_kb.X` — **1 cell** | golden keeps it there and takes it away for the module-level twin (`va3.s1`) |

Ten further cells still hold pristine's answer for reasons **outside this
branch** and are earl55's own recorded residues, not this law's: a SCALAR
`logic` parameter (`g2.u_b3.X`, `a5_earl55.u_e3.G` — earl55 R5), a `localparam`
declared **inside a generate scope** (`g3.u_e4.g[0..1].GX`,
`a5_earl55.u_e5.gen_b[0..1].J`, `v6_v55.u_s2.gf[0].gt.NG`,
`v6_v55.u_s2.gf[1].ge.NH` — earl55 R6), and a **substitution** rather than a
replication (`g1.u_aa.X` `= NM`, `a5_earl55.u_e6.K` `= pk5_55::PKW1`).

---

## 7. THE GRID — `GRID.r10earl104.txt`

26 arms × {plain, elab}, both binaries, each cell scored three-way against
golden.  **1606 shared keys, GOLDEN-SIDE-IDENTICAL, AWAY-GOLDEN 0 /
MOVED-WRONG 0 / TO-GOLDEN 240 / ADDED 0 / REMOVED 0** — and the same 0 / 0 on
the `--judge`, `--ts` and `--ts --judge` projections.

* `g1_form104` — ORIGINS: replication with a literal / module-parameter /
  package-parameter / expression count, a wider operand, a nested replication, a
  replication of a concat, against a plain CONCAT, an ARITHMETIC fold, a CAST
  fold, a bare SUBSTITUTION and a `'0` pattern.  agree 10 -> 17.
* `g2_type104` — DECLARED TYPES: `logic [7:0]`, `logic [0:0]`, scalar `logic`,
  `bit [7:0]`, `int`, `integer`, `byte`, a TYPEDEF, untyped, `logic signed
  [7:0]`, `logic [3:3]`.  agree 14 -> 18.
* `g3_home104` — HOMES: a PACKAGE, a MODULE, a CLASS, a GENERATE SCOPE, an
  INTERFACE, a FUNCTION body, the TOP module's own, and THREE INSTANCES of one
  span.  agree 9 -> 14; the PACKAGE row is byte-unchanged by the `!inPackage`
  fence.
* `g4_cons104` (15 consumers × 2 widths) agree 46 -> 56; `g5_gscope104` (10 read
  HOMES × 2 widths) agree 30 -> 40; `g6_mix104` (6 mixtures) agree 11 -> **14,
  disagree 0**.
* `g7_pos104` — the 14 positions built for this pass (§3's bare column, the
  procedural/function/task/assertion exclusions, the gen-scope struct range, the
  `$bits` cell).  agree 17 -> 27.
* **THE TWELVE CONVICTED SHAPES**, carried here verbatim from the r10earl103
  verifier: `va1_read104` (13 reader positions × 2 widths) agree 44 -> 56;
  `va2_home104` 11 -> 17; `va3_more104` 20 -> 21; `va4_bare104` 5 -> 9;
  `va5_edge104` 5 -> 7.
* **THE TWO `CMP_EQUAL` -> `CMP_NOTEQUAL` CONVICTIONS ARE MUST-STAY-EQUAL
  CONTROLS AND THEY HOLD**: `vb2_genfor` **0 cmp lines / 0 heads -> 0 / 0** and
  `vb4_instarr` **0 / 0 -> 0 / 0**, both byte-identical between the binaries and
  absent from the wide boundary's differing list.  `vb1_netrange` 18/1 -> 18/1
  and `vb3_tdefrange` 24/1 -> 24/1, also byte-identical.
* **earl55's arms re-run here**: `a1` agree 56 -> 85, `a4` 56 -> 64, `a5`
  28 -> 29, `v2` 21 -> 25, `v5` 21 -> 22, `v7` 8 -> **10, disagree 0**, `v8`
  11 -> **12, disagree 0**; `v1`, `v4`, `v6` byte-unchanged.  AWAY 0 and
  MOVED-WRONG 0 on every one.

---

## 8. THE BOUNDARY — `BOUNDARY_WIDE.*`, `BOUNDARY_ARMS.txt`

`wide104.sh` compiles **every `.sv` and `.v` under `tools/probe` at ANY depth**
— subdirectory arms included (the list spans path depths 6 to 10) — on both
frozen binaries, both views, and byte-compares the workdir-normalised
`uhdm-dump`.  The file list is read on **fd 3** with children `</dev/null`, and
PROCESSED is asserted against LISTED.

```
LISTED=4679   PROCESSED=4679   identical=8934   DIFFERING=50   no_output=374
rc symmetry (A=patched / B=pristine):  rc=0 8611/8611   rc=3 360/360
                                       rc=4 373/373     rc=139 14/14
FENCED=0 — the four slang-fenced names appear 0 times in the list and were
           never dispatched.
```

The 14 `rc=139` per side are the pre-existing probe segfaults recorded since
earl82, identical on both sides, and `byteverify` proves none is a mover.  The
gate demonstrably SEES (50 differing cells): that is its own positive control.

**All 50 differing cells accounted for, all 25 arms scored against GOLDEN.**

* **19 arms are this pass's own and earl55's** — every changed dump line is the
  same 15-line shape (`logic_typespec` -> `int_typespec`, the range subtree
  removed, `|UINT:n` added), one per TO-GOLDEN cell, one-to-one with the census.
  AWAY 0, MOVED-WRONG 0 (§7).
* `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv` — 12 and 8 changed
  lines, **every one BELOW the `_weaklyReferenced:` marker** (first hunk 5118 vs
  marker 4356 and 8095 vs 6471; 678 vs 645 and 714 vs 646), value pair
  `22544089` / `22539993`, differing by 4096.  That is uvm154's recorded
  **address-layout stamp**, which RESUME.md §9 (earl60's brief-refutation) says
  the judge cannot reach.  Official cmp byte-identical: `g22` 1719/1 -> 1719/1,
  `l154_noenum` 8/1 -> 8/1.
* `r10earl86repro/g3_anc86.sv` (3 cells), `r10v86repro/arms/vaB_tern86.sv` (2),
  `r10v85repro/arms/va5_ctx85.sv` (1) — **the typespec column moves on cells the
  judge cannot reach.**  In all six, **golden's Rhs is an unfolded `operation`
  op34 and ours is a `constant`, on BOTH binaries**: the recorded over-folds of
  § `srlgUnsizedBasedShiftBail85` and earl86's ternary-bail family.
  `param_assign::Compare` walks Lhs then Rhs and `BaseClass::Compare` fails at
  the Rhs's `VpiType` (`vpiOperation` vs `vpiConstant`) **before any typespec is
  read**, so the typespec underneath is unreachable on the pristine binary and
  on the patched one alike; `score104.py --ts` prints `[RHS-KIND-DIFFERS]` on
  every one.  The judge confirms it: **`g3_anc86` 31/1 -> 31/1 and 16/1 -> 16/1,
  `vaB_tern86` 123/1 -> 123/1 and 16/1 -> 16/1, `va5_ctx85` 47/1 -> 47/1 and
  12/1 -> 12/1 — byte-identical.**  (These are the 12 rows that make the
  boundary arms' raw score read `MOVED-WRONG 14` and, in the `--ts --judge`
  projection, `AWAY-GOLDEN 2`: all 12 carry `[RHS-KIND-DIFFERS]`.  Among cells
  the judge CAN reach both counts are **0**.)  Residue R1 below; the fence that
  would zero them belongs to another law — *do not fold what golden refuses to
  fold*.
* `r10v85repro/arms/va6_unbased85.sv` — one cell, `z08 = {4{'1}}`: golden's
  typespec is a loc-less `int_typespec` too, so on the judge's read fields this
  cell **moves TO GOLDEN**; only the judge-invisible `VpiValue`
  (`UINT:-1` vs `UINT:1`) and the constant's pre-existing `VpiSize` (`-4` vs
  `4`, unchanged by this pass) still differ.  cmp 32/1 -> 32/1.

---

## 9. GATES — all green

| gate | result |
|---|---|
| build both, md5s | pristine `3002e867e7137c2e5b2e2236d846dc2f`, patched `03e245f8108782c43b9605b3c3593d80` |
| goldens, `SLANG_UHDM` exported to the PATCHED binary explicitly | **PASS 23 / FAIL 0** |
| negative control `SLANG_UHDM=/bin/false` | **PASS 0 / FAIL 23** |
| u2r testflags vs committed `results/gate_uhdm2rtlil.csv` | `ct8rows` **PASS**, 0 differing rows |
| u2r testflags + default vs this pass's OWN pristine sweep | `ct8rows` **PASS**, 0 differing rows (status AND dump column) |
| u2r `byteverify SELFCHECK=1` | **MOVERS 0 / 1358**, PATH_SETS_IDENTICAL |
| surelog vs committed `results/golden_surelog.csv` (1588 rows) | `ct8rows` **PASS**, **0 differing rows — NO ROW CONVERTS** |
| surelog vs this pass's OWN pristine sweep | `ct8rows` **PASS**, 0 differing rows; status histogram unchanged (471/466 CMP_EQUAL, 10/9 CMP_NOTEQUAL, 283/284 SLANG_REJECT, 25/23 SURELOG_FAIL, …) |
| surelog `byteverify SELFCHECK=1` | **MOVERS 2 / 956**, both PREDICTED BY NAME |
| canaries (`canaries.sh`) | surelog `ok=52 changed=0`, u2r `ok=8 changed=0` |
| supplementary canaries (`ctcan2.sh`) | **PASS** both corpora (`ok=58` / `ok=1`, changed=0) |
| canary audit (`canaudit.sh canaries.sh ctcan2.sh`) | `audited=29 UNCOVERED=0 FENCE-BREACH=0` **PASS** |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `ReplicationPassedToInstance` | CMP_EQUAL both modes, byte-unchanged (`48d4b425cfca` / `761e1d318376`), **0 op34 cells** — the law cannot reach it |
| wide boundary | PROCESSED 4679 = LISTED, rc symmetric, all 50 differing cells attributed (§8) |
| `cmds.txt` audit BY BINARY PATH | 2981 of 3035 per sweep name the frozen binary; **0 of 6070 name the main-tree binary** |
| `GOLDEN_DEFER` | unset throughout |

**HEADS** (`rowheads.sh`, this pass's own sweeps):

| row | before | after |
|---|---|---|
| Earlgrey_0_1 default | 34 / 1 | **31 / 1** |
| Earlgrey_0_1 testflags | 34 / 1 | **50 / 1** |
| SeqDriver, SimpleUVM (both modes) | 82 / 1 | 82 / 1 |
| BuildUVMPkg (both modes) | 29 / 1 | 29 / 1 |
| Scoreboard default | 145 / 1 | 145 / 1 |
| MiniAmiq (both modes) | 106 / 1 | 106 / 1 |
| Rggen default | 0 / 0 | 0 / 0 |

The head OBJECT is gone from both modes.  Line counts are not comparable across
a change that removes a cascade mask (RESUME.md §9): the testflags head is now a
DIFFERENT object one level deeper — `pinmux.sv:176`'s own operand, where golden
substitutes the folded constant (`id 640534`, carrying **this same
`int_typespec`**) and we keep a `ref_obj` to the parameter — and the default
head is `LHS: <null>` on
`work@top_earlgrey.u_pinmux.gen_mio_periph_in[0].data_mux`.  Both were already
present and masked: the whole-dump attribution shows the `data_mux` subtree
**byte-identical, line numbers included**, between the two binaries.

---

## 10. RESIDUES

* **R0 — the next head is named and measured.**  `Earlgrey_0_1 testflags`:
  at `pinmux.sv:176` golden SUBSTITUTES the folded constant
  `32'b1111…` (`vpiConstType:3`, carrying the loc-less `int_typespec` this pass
  just started emitting) into the concatenation operand, while we emit a
  `ref_obj` to `work@top_earlgrey.u_pinmux.gen_mio_out[0].MioPeriphHasSleepMode`
  whose `vpiActual` is the parameter.  That is a substitution law for a
  generate-scope cont-assign operand, one level below the typespec this pass
  fixed, and it is the same parameter.  `Earlgrey_0_1 default`: `LHS: <null>`
  on `u_pinmux.gen_mio_periph_in[0].data_mux` — a `logic_var` we emit and golden
  does not, at `pinmux.sv:157`.
* **R1 — the over-folds this law rides over.**  `g3_anc86`, `vaB_tern86`,
  `va5_ctx85`: golden keeps an unfolded `operation` op34 where we emit a
  `constant`, on BOTH binaries.  Until that is fixed the typespec underneath is
  unreachable to the judge; the fix belongs to § `srlgUnsizedBasedShiftBail85`'s
  family, not here.
* **R2 — the 15 forgone cells of §6**, in four named classes.  Each needs a
  discriminator this syntax walk does not have: whether a parameter initializer
  is module-level or gen-scope, whether a cont-assign expression reduces,
  whether a generate branch is instantiated, and whether a struct member range
  sits in a generate scope.  Three of the four are visible in the AST; none is
  worth a second pass until the head above it moves.
* **R3 — `va6_unbased85`'s `z08 = {4{'1}}`** still disagrees on the
  judge-invisible `VpiValue` (`UINT:-1` vs `UINT:1`) and on the constant's
  `VpiSize` (`-4` vs `4`), both untouched by this pass.

---

## 11. FILES

| file | what it is |
|---|---|
| `cen104.cpp` | the param_assign typespec census; key = (view, Lhs fullname, line:col), payload = the typespec as a STRING, origin read off GOLDEN's DEF view |
| `cenrun104.sh` | runs it over a whole `verify_golden.py` workdir, golden path read from each test's OWN `cmds.txt`, every rc logged |
| `score104.py` | the three-way join; asserts the golden side unchanged first; four payload projections and `[RHS-KIND-DIFFERS]` on unreachable cells |
| `own104.cpp` | earl102's owner-finder, verbatim — the `Ranges()` container scan plus the `ref_typespec` `Actual_typespec` scan |
| `grid104.sh` | per-arm golden+ours build, uhdm-cmp lines/heads, cen104 |
| `wide104.sh` | the wide boundary (earl102's, renamed) |
| `g1_form104.sv` … `g6_mix104.sv` | origins / declared types / homes / 15 consumers / 10 read homes / the mixtures |
| `g7_pos104.sv` | **new here** — the 14 positions the positive enumeration needed and nothing had measured |
| `va1_read104.sv` … `va5_edge104.sv`, `vb1`-`vb4` | the r10earl103 verifier's twelve convicted shapes and its four judge-visible minimals, carried verbatim; `vb2_genfor` and `vb4_instarr` are the must-stay-CMP_EQUAL controls |
| `OWNER.r10earl104.txt` | the owner decode, both sides |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the head logs |
| `PREDICT_R0.txt` | the prediction made from pristine databases, and the outcome beside it |
| `CEN_corpus_score.txt` | the corpus three-way score, four payloads, plus the two TO-GOLDEN cells in full |
| `ATTRIB.r10earl104.txt` | the workdir-normalised whole-dump diff, both modes, sectioned by the weaklyReferenced marker |
| `GRID.r10earl104.txt` | the arm table, the three-way scores, the 240 TO-GOLDEN cells and every forgone cell |
| `BOUNDARY_WIDE.*` | tally / listed+FENCED / diff list / rc histogram / rc by side / signals |
| `BOUNDARY_ARMS.txt` | the six non-pass boundary arms scored against golden, with the tail-stamp and RHS-KIND-DIFFERS proofs |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the gate scripts this pass RAN, carried so the audit passes here |
