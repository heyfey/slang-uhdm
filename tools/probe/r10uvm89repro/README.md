# r10uvm89 — § `hpTrailSelIdxDecompiled89` — **THE SEVEN-ROW-MODE UVM HEAD CLOSED, 96 → 89**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **no corpus row
passes cmp**.

## The headline

r10uvm88 left ONE head standing on all seven live UVM row-modes — a hier_path
**NAME-TEXT** fact:

```
uvm_port_base.svh:485:5    provider.m_provided_to[get_full_name()] = this;
LHS golden  hier_path (provider.m_provided_to[])                 @485:5-485:44
RHS ours    hier_path (provider.m_provided_to[get_full_name()])  @485:5-485:44
FIELD VpiName   SHAPE TEXT   site: uvm_port_base::connect
```

It is gone, and the whole sub-family with it. The seven row-modes go
**96 → 89 cmp lines**, and the new head is `method_func_call(super.new)`
**MISSING-OURS** — the family uvm88's own README named as "the next family behind
it". The **cmp line count goes DOWN**: this is not the next rung printing, it is
the rung removed.

| row-mode | cmp lines | head |
|---|---|---|
| SeqDriver ×2 / SimpleUVM ×2 / MiniAmiq ×2 / Scoreboard-default | 96 → **89** | `hier_path(provider.m_provided_to[])` **VpiName** → `method_func_call(super.new)` MISSING-OURS |
| BuildUVMPkg ×2 | 47 → **47** | unchanged (its own older `function` head) — but **11 objects moved per mode**, said out loud |
| Earlgrey_0_1 ×2, Rggen | 29/33/85 | untouched, and **provably byte-untouched** |

The `bracket-named hier_path` count now equals golden **EXACTLY** on SeqDriver
(1921), SimpleUVM (1030), Scoreboard (1030) and MiniAmiq (2025).

## The law

> A `hier_path`'s **NAME** renders each component select's index through
> Surelog's `decompileHelper` — a **CLOSED dispatch with no default arm**, so an
> index kind it has no row for renders as the **EMPTY STRING**.
>
> The **BRACKETS AROUND IT** survive an empty render **iff** the select is
> **MID-PATH**, **or** the hier_path is an **ASSIGNMENT LVALUE whose BASE
> COMPONENT CARRIES NO SELECT**. Otherwise the whole `[...]` group **VANISHES**.

### The decode, from Surelog

`CompileHelper::decompileHelper` (`CompileHelper.cpp:2544`) switches on the index
object's UHDM type and has **no `else`**:

```
constant            -> VpiDecompile
ref_obj             -> VpiName
operation           -> ExprEval::prettyPrint
bit_select          -> "[" + (its CONSTANT|REF_OBJ|OPERATION index) + "]",  "" otherwise
part_select         -> "[l:r]"
indexed_part_select -> "[b+:w]" / "[b-:w]"
var_select          -> the concatenation of its exprs
EVERYTHING ELSE     -> ""            <- func_call, method_func_call,
                                        sys_func_call, hier_path, …
```

Its **callers** then use one of **two conventions**, and they differ *only* for
an index kind with no row:

| | text appended per select | empty index |
|---|---|---|
| **A** `CompileExpression.cpp:5586`, and `compileSelectExpression`'s own copy at `:1503` | `"[" + decompileHelper(the INDEX) + "]"` | `[]` — **brackets survive** |
| **B** `CompileExpression.cpp:5547` | `decompileHelper(the ELEMENT)` | **the whole group vanishes** |

For a `part_select` / `indexed_part_select` / `var_select` element, B's own row
builds the same bracket text A does, so **A and B agree there** — which is why
this law cannot reach `packer.m_bits[+:32]` (residue R2).

### The axis, measured three independent ways

* **GOLDEN vs GOLDEN, the corpus grid** (`CENSUS`): a TRAILING `bit_select` with
  an index the dispatch has **no row for** is `[]` in **39 objects, EVERY ONE at
  `LVAL=1`**, and **DROPPED in 2, none at `LVAL=1`**. The negative control is in
  the same table: a TRAILING select with a CONSTANT / REF_OBJ / OPERATION index
  keeps its text at `LVAL=0`, `1` **and** `2` — **1379 objects** — so this is
  *not* "an rvalue loses its brackets". `MID` is `[]` at `LVAL=0` and `LVAL=2`
  alike: position-independent, exactly uvm79's law, untouched.
* **uvm79's residue R1, DECODED.** That pass recorded golden's trailing sites as
  "not even self-consistent — `uvm_reg_map.svh` writes `top_map.m_regs_by_offset`
  at 771 and `top_map.m_regs_by_offset[]` at 772 for the SAME index expression".
  The census shows both, with their `LVAL`: **771 is `LVAL=2`, 773 is `LVAL=0`,
  772 is the LVALUE**. Not inconsistent — **two Surelog call sites**.
* **ARM a1**, 17 index kinds × TRAILING/MID × 4 positions × 5 scopes, off ONE
  golden: `[gn()] [this.gn()] [hh.gn()] [f89(i)] [hh.q.size()] [$clog2(8)]
  [oo.f]` all → `[]`; `[ii[i]] → [[i]]`, `[pk[3:0]] → [[3:0]]`,
  `[pk[1+:2]] → [[1+:2]]`; `[2] [i] [i + 1] ["lit"] [{s,s}] [i ? 1 : 2]` keep
  their text. **FIXED=27 BROKE=0.**

### The half the first cut got WRONG, and the gate that caught it

The first cut gated the trailing arm on **`inLhs` alone**. The **BOUNDARY GATE**
flagged **one** of its 596 fenced arm sources — r10uvm81's `v81h_lvbase.sv` —
and reading it against golden refuted the gate **before it landed**:

```
m[idx[idx[i]]].mi[idx[idx[i]]] = 3;   golden  m[].mi        <- LVALUE, GROUP GONE
mm.mi[oo.f] = 2;                      golden  mm.mi[]       <- LVALUE, []
```

**ARM a2** was written to separate the two axes on one golden, 24 cells:

| | LVALUE | rvalue / condition / argument |
|---|---|---|
| base **not** selected | `[]` | gone |
| base **selected** | **gone** | gone |
| MID select, either base | `[]` | `[]` |

and the **SPAN is the tell**: golden's base-selected LVALUE hier_paths span the
**base token alone** (`36:7-36:8`) where the others span the whole written path
— i.e. Surelog reached them through a different builder, which is also why they
get a different bracket convention. So the gate is **`inLhs && !baseSelMode`**,
and `baseSelMode` is the predicate this emitter **already** uses to reproduce
that very span — the gate and the span it models cannot drift apart.

With the corrected gate the fenced arm's two cells go **PRISTINE-WRONG →
GOLDEN**: `m[].mi[idx[idx[i]]]` → `m[].mi`. **The boundary gate's one MOVED arm
moves TOWARD golden.**

## Where the code is

| site | file | what changed |
|---|---|---|
| the closed dispatch | `src/ExprEmit.cpp` (file-static `rendersAsItself89`) | **hoisted out of uvm79's lambda**, so both name sites read ONE copy |
| **SITE 1** | `src/ExprEmit.cpp` `emitMixedHierPath` (`selGroup89`) | renders the WHOLE bracket group; `mid \|\| (inLhs && !baseSelMode)` picks convention A, else B |
| **SITE 2 — the head's own site** | `src/ExprEmit.cpp`, ElementSelect case, the single-dim `chain` arm | `obj.member[idx]` with no further component and no base select is built HERE, not in `emitMixedHierPath` |

ONE file. 262 inserted lines, 26 deleted — the overwhelming majority of it the
measured tables above, written where the code is. Nothing is extracted or
refactored beyond the one hoist that removes a duplicate dispatch list
(`MEMORY.md`'s "no premature extraction").

## What did NOT move, and is recorded as residue

* **R1 — `ExprEval::prettyPrint`**, a SECOND closed dispatch. Golden drops a
  `hier_path` operand of an OPERATION index (`gp.m_byte_enable[i % ]`) and spaces
  its operators (`m_fields[idx - 1]` vs ours `m_fields[idx-1]`); an ASSIGNMENT
  PATTERN index comes out `['{,}]`. **28–29 MID + 1–3 TRAIL objects per UVM
  row** — the biggest remaining F1 sub-shape and the natural next pass. An
  OPERATION *has* a `decompileHelper` row, so this law deliberately leaves its
  text byte-for-byte alone.
* **R2 — a TRAILING `indexed_part_select` in a different emitter arm**: golden
  `packer.m_bits[+:32]`, ours `packer.m_bits[]`. **OURS IS TOO EMPTY**, the
  opposite direction. Conventions A and B agree for a range element, so the law
  cannot reach it. 4 objects per UVM row.
* **R3 — a select under a METHOD-CALL chain** (`m_streams[].exists`,
  `m_children[].get_type_name`): our path's element list has **no selected
  element at all**, so it is a STRUCTURAL family, not a name-text one.
  5–9 objects per UVM row, and the one remaining BuildUVMPkg MISSING-OURS.
* **R4 — the FOLD sub-shape, Earlgrey/Rggen only.** Golden decompiles an
  ELABORATED index (`reg2hw…q[0]`, `register_if[12].value[0+:1]`) where we still
  hold the genvar (`q[i]`, `register_if[6+7*i+6].value[0 + 1 * l+:1]`). **499
  objects.** The brief asked for it to be measured: it is (`CENSUS`), it is a
  *different mechanism* — orthogonal to which brackets survive — and this pass
  leaves **all 499 byte-identical**, proven by the class-table diff being
  **empty** on both rows.
* **EXTRA-OURS hier_paths for the index expressions themselves** (`gn().len`,
  `oo.f`) — present identically in pristine; a different family.

## The gates, in one line each

Build md5s `8c0c3117…` / `f43f3f12…`. Goldens **23/0** patched, **23/0**
pristine, **0/23** with `SLANG_UHDM=/bin/false`. uhdm2rtlil **679/50/2** both
modes both binaries, ct8rows **0 differing rows** (testflags vs the committed
gate CSV, and patched-vs-pristine over all 1462 rows for the default half the
gate CSV does not carry), byteverify **0 / 1358**. surelog
**470+11+5+283+25 / 466+9+5+3+1+284+23+1+2**, ct8rows **0 differing rows** on
1588, **NO ROW CONVERTED**. Bytes: **9 movers / 956**, exactly the nine `PREDICT`
named from pristine bytes, with their per-database cell counts; `SELFCHECK`
955/956, `SELFCHECK1` 10. Attribution: **four line kinds only**
(`hier_path`, `bit_select`, `vpiName`, `vpiFullName`), insertions == deletions.
Boundary **LISTED=596 PROCESSED=596 MOVED=1 (toward golden, named)
NO_OUTPUT=6 (both binaries)**. Canaries **56/0/0/8**, **58/0/0/1**,
**18/0/0/27**, **2/0/0/6**, `canaudit` **33 audited, 0 UNCOVERED, 0
FENCE-BREACH**. Pins hold: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical.
Full detail in `GATES.r10uvm89.txt`.

**The prediction was made first.** `pred89.sh` read the 956 pristine surelog and
1358 pristine uhdm2rtlil databases and named **9 movers** (with counts) and
**947 + 1358 byte-identical files** before the patched binary existed. The byte
gate returned exactly that.

## Reproducing

```sh
# census (golden vs ours, every row-mode of a workdir)
g++ -O2 -std=c++17 ct89cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10uvm89_ct89cen
./cen89.sh <workdir> <outdir> --paths
python3 dis89.py <outdir>/default_SeqDriver.{g,o} default_SeqDriver
python3 grid89.py <outdir>/default_SeqDriver.g          # golden-only grid
# arms
PRI=<pristine> PAT=<patched> ./arm89.sh g89_a2_base.sv
./three89.sh /tmp/r10uvm89_arm_g89_a2_base
# the mover predictor, PRISTINE bytes only
./pred89.sh /tmp/r10uvm89_wd_pris_surelog
# gates
./sweep89.sh <bin> surelog <tag>;  ./ct8rows.sh <baseline.csv> <fresh.csv>
./byteverify.sh <pat wd> <pris wd>;  SELFCHECK=1 …;  SELFCHECK1=1 …
./attr89.sh <pat wd> <pris wd> ./default/SeqDriver-32af76aa/slang.uhdm
./pins89.sh <pat wd> <pris wd>
PRI=… PAT=… ./bound89.sh
bash canaudit.sh canaries.sh ctcan2.sh
# the ladder (MEASUREMENT-ONLY)
CTLADDER=/tmp/r10uvm89_ctladder MAX=200 BUDGET=900 \
  ./rowladders89.sh <workdir> <outdir> default:SeqDriver default:BuildUVMPkg
```

## R0 — the new head, for the next pass

```
uvm_tlm_imps.svh:207:3   function new (string name, IMP imp);   (implicit super.new)
LHS golden  method_func_call (super.new)  id 252492  < begin < function(new)
                                          < class_defn(uvm_blocking_get_imp)
RHS ours    <null>                        SHAPE=MISSING-OURS
```
Golden emits an **implicit `super.new` call** in a constructor that does not
write one; we emit nothing. **30 objects / 30 rungs in 7 rows** — this is
`CLUSTERS.vladder1.md`'s **F13** (`method_func_call -> method_func_call |
MISSING-OURS`), and it is the family uvm88's README already named as sitting at
the pristine ladder's rungs 2/3/5/6. On the patched SeqDriver ladder it is rungs
**1, 2, 4, 5** and it repeats once per `uvm_*_imp` class.

The next **F1** rung, if the next pass prefers to finish the name family, is
**R1** above: `ExprEval::prettyPrint` — golden `gp.m_byte_enable[i % ]` and
`m_fields[idx - 1]` against our `[i % gp.m_byte_enable_length]` and
`[idx-1]`, 28–29 objects per UVM row, a second closed dispatch needing its own
census.
