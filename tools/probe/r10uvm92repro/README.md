# r10uvm92 — § `hpIdxOpPrettyPrint92` — **THE SEVEN-ROW-MODE UVM HEAD CLOSED, 176 → 28**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
PASSES cmp**.

## The headline

r10uvm91 left ONE head on all seven live UVM row-modes — a hier_path
**NAME-TEXT** fact. It is gone, and the whole family behind it.

```
uvm-1.2 src/tlm2/uvm_tlm2_generic_payload.svh:464   (uvm_tlm_generic_payload::do_compare)
    rhs_be = gp.m_byte_enable[i % gp.m_byte_enable_length];
LHS golden  hier_path (gp.m_byte_enable[i % ])                          @464:22-464:67
RHS ours    hier_path (gp.m_byte_enable[i % gp.m_byte_enable_length])   @464:22-464:67
FIELD VpiName   SHAPE TEXT
```

| row-mode | cmp lines | head |
|---|---|---|
| SeqDriver ×2 / SimpleUVM ×2 / MiniAmiq ×2 / Scoreboard-default | 176 → **28** | `hier_path(gp.m_byte_enable[i % ])` **VpiName** → `constant` **vpiDecompile** (R0) |
| BuildUVMPkg ×2 | 29 → 29 | unchanged — but **18 objects moved per mode** (buvm14's residue R5, said out loud) |
| Earlgrey_0_1 ×2 (29/30), Rggen-default (76) | unchanged | untouched, and **provably byte-untouched** |

## The law

> A hier_path NAME renders each component select's index through Surelog's
> `CompileHelper::decompileHelper` (§ uvm79/89's **first** closed dispatch), and
> that function's **OPERATION** row hands the object to
> `UHDM::ExprEval::prettyPrint` — a **SECOND closed dispatch** with a
> `default: break` on **BOTH** levels, the object kind *and* the `vpiOpType`.
>
> So: every **binary** operator is rendered **SPACED** whatever the source
> wrote; every **unary** one is **not**; **parentheses are gone**, because
> prettyPrint never emits one and never consults precedence; and an operand it
> has **no row for renders as the EMPTY STRING while its operator and that
> operator's spaces SURVIVE**.

### The decode, transcribed from UHDM and then measured

`ExprEval::prettyPrint`, `UHDM/templates/ExprEval.cpp:949` (**byte-identical**
in the installed 1.84 and in HEAD — the two bodies `diff` empty):

| object kind | text |
|---|---|
| `constant` | `VpiDecompile` — `4`, `8'hFF`, `$` |
| `parameter` / `enum_const` | `VpiValue`, `':'`-trimmed |
| `ref_obj` | `VpiName` |
| `sys_func_call` | `name "(" args ")"`, `,`-joined, **no space** |
| `part_select` | `l:r` — **no brackets of its own** |
| `indexed_part_select` | `b+:w` / `b-:w` |
| `var_select` | `name` + `[expr]` per expr |
| `operation` | the table below |
| **everything else** | **`""`** ← `hier_path`, `bit_select`, `func_call`, `method_func_call`, `tagged_pattern` |

| `vpiOpType` | text |
|---|---|
| the 12 **unary** ops | `token + op0` — **no space** (`-i`, `~&w`) |
| the 27 **binary** ops | `op0 " " token " " op1` — **spaced** (`i + 1`) |
| `vpiConditionOp` | `op0 " ? " op1 " : " op2` |
| `vpiConcatOp` / `vpiAssignmentPatternOp` | `{…}` / `'{…}`, `,`-joined, no space |
| `vpiMultiConcatOp` | `"{" mult "{" op "}}"` |
| `vpiInsideOp` | `op0 " inside {" rest "}"` |
| `vpiPostIncOp` / `vpiPostDecOp` | `op0 "++"` / `op0 "--"` |
| **everything else** | **`""`** ← `vpiCastOp`, `vpiWildEqOp`, `vpiWildNeqOp`, `vpiStreamLROp/RLOp`, `vpiMultiAssignmentPatternOp` |

Two spellings are **not** the same string, and the asymmetry is in Surelog's own
two tables: **binary** `vpiBitXNorOp` is `^~`, **unary** `vpiUnaryXNorOp` is
`~^`. Golden, arm a1 c14 vs c35: `i~^3` → `i ^~ 3`, `~^pkw` → `~^pkw`.

### The decode is an ORACLE, and it was run over EVERY golden FIRST

`ct92cen` **links the real `UHDM::ExprEval::prettyPrint`** and transcribes
`decompileHelper`, applies the composition to each path element of a database's
**own** tree, and compares it to the bracket text that database's hier_path NAME
actually carries. On GOLDEN that is a per-object proof of the decode, and a
single mismatch anywhere refutes it. `gvg92.sh`, run before any code:

| corpus | goldens | hier_paths with an operation index | `EXPM_Y` | `EXPM_N` |
|---|---|---|---|---|
| surelog | 1523 | 10021 | **10036** | **0** |
| uhdm2rtlil | 1458 | 1840 | **1844** | **0** |

**11 880 cells over 2 981 golden databases, zero exceptions.**
(Three census bugs were found and fixed getting there, each of which printed as
a REFUTATION and none of which was one: a component name matched inside a longer
one — `memory` in `i_memory_tb`, `data` in `data_o` — and a second-dimension
element carries **no** VpiName at all, `rw.value[idx][i0 * 8+:8]`.)

### The corpus census, golden vs ours, made BEFORE the patch

`cen92.sh` + `cenjoin92.py`, every row-mode of both corpora:

* the **four CMP_EQUAL surelog rows** that carry an operation index —
  `BitSelectExpr`, `CarryAdd`, `GenScopeHierPath3`, `Scr1SvTests` — are
  **already byte-identical to golden** on every one of their cells
  (`[2 - 2]`, `[i - 1]`, `[j - 1]`, `[LAST_START + j]`, `[CHUNK - 1]`,
  `[start + 3]`, `[SCR1_CSR_ADDR_WIDTH - 1]`);
* **the whole uhdm2rtlil corpus** — 1358 databases, 14 test names with an
  operation index — is likewise **already identical to golden**, every key;
* on the UVM rows the join reads **`REACHED-BY-PP` = 100 %, `RESIDUE` = 0**:
  every differing name becomes golden's exactly when its bracket is replaced by
  `prettyPrint` of **our own tree**.

That last line is the pass's real finding: **our OPERATION TREE was already
right and only the NAME TEXT was the source's raw spelling.** Joined cell by
cell on arm a1, golden's bracket text equals `prettyPrint(OUR tree)` in **97 of
98** cells while ours agreed in only 20.

## The three sites

| | site | what it names |
|---|---|---|
| **1** | `ExprEmit.cpp` `emitMixedHierPath` → `idxText34` | every MID/base component select of a mixed path |
| **2** | `ExprEmit.cpp`, ElementSelect case, the single-dim `chain` arm | `obj.member[idx]` with no further component — **the head's own site** |
| **3** | `ExprEmit.cpp`, the METHOD-CALL RECEIVER (`recvTx11`) | `m_fields[idx-1].get_lsb_pos()` — **buvm14's residue R5** |

SITE 3 rebuilds the name from `segs11`, the **same** segment decomposition the
path ELEMENTS are emitted from, so the name and the elements cannot drift; it
fires only when some segment's index really is a UHDM operation, so a receiver
this law cannot reach keeps its raw text **byte for byte**.

`§ hpTrailSelIdxDecompiled89`'s `rendersAsItself89` was also **re-cut from one
source of truth**: `decompileHelper`'s bit_select row keeps its brackets for a
CONSTANT, a REF_OBJ **or an OPERATION**, and `Inside` **is** an operation
(`vpiInsideOp`). uvm89 listed it as "no row" and dropped the whole group; golden
keeps it (arm a1 c38: `oo = hh.aidx[i inside {1,2}]` is golden's
`hh.aidx[i inside {1,2}]`, ours was `hh.aidx`).

## The three cells the model would have got WRONG, and what caught each

1. **A string literal in a STRING concatenation.** slang inserts a
   `ConversionExpression` of kind **`Explicit`** with **no syntax node**
   (`OperatorExpressions.cpp:1979`) when it converts an operand of a string
   concat, so `stripImplicitConv` — which tests `isImplicit()` — leaves it
   standing and the first model rendered `{s,"x"}` as `{s,}`. Surelog never sees
   such a node: only a cast **written** in the source is a UHDM operation, and
   only a written one carries a `syntax` pointer. **Caught by arm a1's own BROKE
   row** (`hh.amap[{s,"x"}]`), fixed by `stripConv92`, and `int'(i)` — which
   golden renders EMPTY — keeps its own arm.
2. **A built-in array/string method.** slang calls `bb.q.size()` a *system*
   call; Surelog builds it as a `method_func_call`, which has no prettyPrint
   row. **Caught by arm a2 k25**; the gate is now "the name starts with `$`",
   and the corpus witness is MiniAmiq's
   `copy.checks_details[copy.checks_details.size() - 1]` → golden `[ - 1]`.
3. **`$` in a queue bound.** `ExpressionKind::UnboundedLiteral` was missing from
   the constant row, so `t[$-1].f` came out `t[ - 1].f` where golden — **and
   pristine** — write `t[$ - 1].f`. **Caught by the BOUNDARY GATE**, on
   r10buvm6repro's fenced arm `v5_hierpathparent.sv`, **two pristine-right →
   patched-wrong cells refuted and fixed BEFORE landing.**

## The arms

| arm | cells | ALREADY-OK | FIXED | **BROKE** | STILL-WRONG |
|---|---|---|---|---|---|
| `g92_a1_ppgrid.sv` — 45 operators × 27 operand kinds × MID/TRAIL × LVAL 0/1/2 × five scopes | 99 | 20 | **78** | **0** | 1 |
| `g92_a2_ppkinds.sv` — assignment patterns, streaming, `->`/`<->`, literal spellings, class localparams, statics, `$bits`/`$size`/`$urandom`, nested replication, escaped identifiers | 37 | 13 | **22** | **0** | 2 |
| `g92_a3_recv.sv` — the METHOD-CALL RECEIVER site, receiver depth 1/2/3 × operation and non-operation indices | 13 | 4 | **8** | **0** | 1 |

The arms are deliberately **not** `a_t/b_t/c_t` over `A/B/C`: operators, operand
names, literal bases and scopes all vary, and every cell that must **not** move
(`items[i].gv()`, `items[2].gv()`, `md.arr[i].gv()`) sits beside the one that
must.

## Residues, each measured and named

* **R1 — the § hpMixedIdxPkgFold34 fold at SITE 2.** `hh.aidx[i + q92::PK92]`:
  golden folds a QUALIFIED package-parameter read to `6`, our SITE-2 tree keeps
  a `ref_obj`. That fold was applied to the MIXED builder only and this pass does
  not extend it. **1 arm cell, corpus population 0.**
* **R2 — the RANGE-select hier_path arm** (`ExprEmit.cpp:~16894`) is deliberately
  **untouched**: it renders `l:r` from ONE source span, and that is exactly how it
  reproduces golden's `sub.adr[ADR - 1:]` (an empty right range) on a CMP_EQUAL
  uhdm2rtlil row. Splitting it would regress that cell. Its cost is Earlgrey's
  `tl_h_i[i].a_source[0+:IDW-STIDW]`, **29 objects, one span**.
* **R3 — the FOLD, Earlgrey/Rggen only** (uvm89's R4). Golden decompiles an
  ELABORATED index (`register_if[12].value[0+:1]`) where we still hold the genvar.
  **24 Rggen objects**; a different mechanism, and this pass leaves them
  byte-identical.
* **R4 — a `bit_select` index at the RECEIVER site.** `items[plain[i]].gv()` is
  golden's `items[[i]].gv` (decompileHelper's own bracket row); SITE 3 implements
  only the OPERATION row and keeps the raw text. **1 arm cell, corpus population 0.**
* **R5 — `HierarchicalValue` as an operand** keeps the pristine raw-text
  rendering rather than being guessed EMPTY: it is the one operand kind neither
  arm reaches. **Corpus population 0** (no OPK column in either corpus names it).

## The gates, in one line each

Build md5s `778f81f7…` / `24b21f18…`. Goldens **23/0** patched, **23/0**
pristine, **0/23** with `SLANG_UHDM=/bin/false`. uhdm2rtlil **679/50/2** both
modes both binaries, ct8rows **0 differing rows** (testflags vs the committed
gate CSV, and patched-vs-pristine over all 1462 rows). surelog
**470+11+5+283+25 / 466+9+5+3+1+284+23+1+2**, ct8rows **0 differing rows** on
1588, **NO ROW CONVERTED, NO ROW REGRESSED**. Bytes: **9 movers / 956** and
**0 / 1358**, exactly what `PREDICT.r10uvm92.txt` named from pristine bytes
before the gate ran — including the three databases it named as
*predicted-but-not-reachable* (Earlgrey ×2, Rggen), which are byte-identical.
`SELFCHECK` 955/956 and 1357/1358, `SELFCHECK1` 10. Attribution, **order-blind**:
**four line kinds only** (`hier_path`, `vpiName`, `bit_select`, `vpiFullName`),
insertions == deletions. Boundary **LISTED=619 PROCESSED=619 MOVED=7
NO_OUTPUT=7 (symmetric)**, every mover judged against golden: **FIXED=10,
BROKE=0**. Canaries **56/0/0/8**, **18/0/0/27**, **58/0/0/1**, **2/0/0/6**;
`canaudit` **33 audited, 0 UNCOVERED, 0 FENCE-BREACH**. Pins **SAME=10 MOVED=0**:
`SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, InterfaceModPort /
BlackParrotComplex / YosysOldOr byte-identical. Full detail in
`GATES.r10uvm92.txt`.

**The prediction was made first**, and it is INTRINSIC: `ct92cen` computes
`decompileHelper ∘ prettyPrint` on a database's own tree, so `pred92.sh` needs
neither a golden nor a patched binary. It named 12 databases with reachable-
looking cells and then named 3 of them as *not* reachable, with the reason; the
byte gate returned exactly the remaining 9.

## R0 — the new head, for the next pass

```
LHS golden  constant: , id:309934
              |vpiDecompile:32   |vpiSize:64  |UINT:32  |vpiConstType:9
RHS ours    constant: , id:114883, line:3494:11, endln:3494:14
              |vpiDecompile:int  |vpiSize:64  |UINT:0   |vpiConstType:9
```
Golden holds the **width 32** where we hold the spelling `int`: a constant
Surelog has already reduced to a type width and we have not. **ONE head on all
seven UVM row-modes.** BuildUVMPkg keeps its own older `io_decl` head.

## Reproducing

```sh
g++ -O2 -std=c++17 ct92cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10uvm92_ct92cen
./gvg92.sh  <workdir>              # golden-vs-golden: the decode as an ORACLE
./cen92.sh  <workdir> <outdir> --op
python3 cenjoin92.py <out>/default_SeqDriver.{g,o} --verbose
./pred92.sh <pristine workdir>     # the movers, from PRISTINE bytes alone
PRI=… PAT=… ./arm92.sh g92_a1_ppgrid.sv ;  ./three92.sh /tmp/r10uvm92_arm_g92_a1_ppgrid
./sweep92.sh <bin> surelog <tag>  ;  ./ct8rows.sh <baseline.csv> <fresh.csv>
./byteverify.sh <pat wd> <pris wd>   # SELFCHECK=1 / SELFCHECK1=1
./attr92.sh <pat wd> <pris wd> ./default/SeqDriver-32af76aa/slang.uhdm
./pins92.sh <pat wd> <pris wd>
PRI=… PAT=… ./bound92.sh ;  ./bmove92.sh /tmp/r10uvm92_bound /tmp/r10uvm92_BOUND.txt
bash canaudit.sh canaries.sh ctcan2.sh
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                 BuildUVMPkg Earlgrey_0_1 Rggen
```
