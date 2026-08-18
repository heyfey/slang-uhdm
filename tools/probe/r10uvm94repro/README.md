# r10uvm94 — § `hpIdxBaseHierPathEmpty94` — **THE SEVEN-ROW-MODE UVM HEAD CLEARED, 164 → 54**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` remain the
authorities for every number quoted here. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED** — but this pass's own arm `g94_a0_head.sv` **PASSES the official
`uhdm-cmp`** in BOTH views where pristine fails with the head, and that is said
out loud below.

## The headline

uvm93 left ONE head on all seven live UVM row-modes — 164 cmp lines, byte
identical across the seven. It is gone.

```
uvm-1.2 src/macros/uvm_object_defines.svh:3674   (`uvm_unpack_enumN body)
    { << { VAR }} = packer.m_bits[packer.count +: SIZE];
  invoked from tlm2/uvm_tlm2_generic_payload.svh:544/550 with SIZE = 32

LHS golden  hier_path (packer.m_bits[+:32])   |vpiName:packer.m_bits[+:32]
RHS ours    hier_path (packer.m_bits[])       |vpiName:packer.m_bits[]
FIELD VpiName   SHAPE TEXT
```

| row-mode | cmp lines | head |
|---|---|---|
| SeqDriver ×2 / SimpleUVM ×2 / MiniAmiq ×2 / Scoreboard-default | 164 → **54** | `sys_func_call($bits)` vs golden's folded `constant 8` (R0) |
| BuildUVMPkg ×2 | 84 → 84 | unchanged, **byte-untouched** |
| Earlgrey_0_1 ×2 (64/64), Rggen-default (104) | unchanged | untouched, and **provably byte-untouched** |

## The law

> A hier_path NAME is built by appending, per component select, the text of
> Surelog's `CompileHelper::decompileHelper` (`CompileHelper.cpp:2544`) —
> uvm79/89's **first** closed dispatch. Its `indexed_part_select` row is
>
> ```
> "[" + decompileHelper(Base_expr) + ('+'|'-') + ":" +
>       decompileHelper(Width_expr) + "]"
> ```
>
> and both recursive calls run through the **same** closed dispatch:
> `constant` → `VpiDecompile`, `ref_obj` → `VpiName`, `operation` →
> `ExprEval::prettyPrint` (uvm92's **second** closed dispatch), `bit_select` /
> `part_select` / `indexed_part_select` / `var_select` → their own bracket text,
> **everything else → the EMPTY STRING**.
>
> **`hier_path` HAS NO ROW.** A DOTTED base therefore renders as **NOTHING**
> while the `+:`/`-:` token and the width **SURVIVE** — the same "operand
> vanishes, operator stays" asymmetry uvm92 measured one dispatch down.

`packer.count` is a hier_path, so golden's name is `packer.m_bits` + `[` +
**nothing** + `+:` + `32` + `]`. Both the base and the width were **already
right** in our `vpiBaseExpr`/`vpiWidthExpr` (uvm93's R0 said so); only the NAME
text was short. `hier_path::Compare` reads `VpiName`; `VpiFullName` is dump-only.

Why *our* text was `[]` rather than `packer.count+:32`: the site renders the
select from `rawText(rs.left()…rs.right())`, and inside a macro **body** that
span crosses buffers and comes back empty. Outside a macro the same defect reads
`packer.m_bits[packer.count+:32]` — arm `g94_a0_head.sv` reproduces **both** the
164-line head and that spelling in 19 lines of SystemVerilog.

### The decode is an ORACLE, and it was run over EVERY golden FIRST

`ct94cen.cpp` **widens uvm92's `ct92cen`** from "path elements whose index is an
OPERATION" to **every select-bearing path element**, and adds the
`indexed_part_select` row this pass owns. It still **LINKS the real
`UHDM::ExprEval::prettyPrint`** and transcribes `decompileHelper`, applies the
composition to each path element of a database's **own** tree, and compares it to
the bracket text that database's hier_path NAME actually carries. `gvg94.sh`, run
**before any code**:

| golden set | dbs | `indexed_part_select` elems | `IPS_Y` | `IPS_N` |
|---|---|---|---|---|
| the WHOLE golden cache | 3673 | 8116 | **7736** | **380** |
| surelog corpus goldens | 1516 | 4519 | 4193 | 326 |
| uhdm2rtlil corpus goldens | 1458 | 26 | **26** | **0** |

`IPS_N` is not a refutation, and the census says why in one column. Over the
**seven** refuting databases, every `indexed_part_select` cell splits **perfectly**
on one signature:

```
   380  EXPM=N   has a vpiIntConst (constType 7) operand
  1254  EXPM=Y   no vpiIntConst operand
```

A `vpiIntConst` select operand is Surelog **REDUCING** the object *after* the
name was composed — `l2r_request.data[byte_lane * 8+:8]` whose `Base_expr` is now
the constant `296`, `tl_h_i[i].a_source[8 - 1-:1]` whose base is now `7`. Those
names are **fossils of a pre-reduction tree** and no transcription off the final
tree can reproduce them. Outside that class the row is **exact, 7736/7736**.

(uvm92's verifier noted its oracle validates the *transcription* but not our C++
*re-transcription*. Both are validated here: the oracle above proves the
transcription on golden, and the three-way arm tables — `three94.sh`, which runs
the **same** oracle over golden, pristine and patched — prove the shipped C++
reproduces it, `FIXED=29 BROKE=0` over 62 arm cells in **both** views.)

## The corpus census, golden vs ours, made BEFORE the patch

`cen94.sh` + `join94.py`, every row-mode of both corpora, classifying each
range-select cell as `SAME` / `FIX` (the law fixes it) / `BREAK` (the law would
break it) / `STILL`:

| corpus | SAME | FIX | BREAK | STILL | UNMATCHED |
|---|---|---|---|---|---|
| surelog, 956 dbs | 2412 | **54** | **65** | 174 | 126 |
| uhdm2rtlil, 1358 dbs | 252 | **0** | **0** | 0 | 0 |

**The whole uhdm2rtlil corpus is already byte-identical to golden on every one
of its 252 range-select cells** — the fence the brief asked for is clean, and no
u2r CMP_EQUAL row carries a `[]`.

The 65 BREAK cells were the pass's real finding, and they split the gate:

```
   65  BREAK  part_select            <- ALL of them, all Earlgrey_0_1
   54  FIX    indexed_part_select    <- ALL of them
  174  STILL  indexed_part_select
```

Every BREAK is a `part_select` and **no `indexed_part_select` breaks**; every FIX
is an `indexed_part_select`. All 65 carry `LK=constant(7)` — the same
post-reduction fossil the oracle found on golden (`G=[SubAW - 1:0]` while the
tree now holds `[1:0]`). Gating the law on the `indexed_part_select` element
alone therefore gives **BREAK = 0 on both corpora**, and uvm92's **R2** (the
part_select arm, which reproduces golden's `sub.adr[ADR - 1:]` from ONE source
span) stays untouched **by construction**.

## The patch, and why the gate is narrower than the row

`src/ExprEmit.cpp` only — one file-static helper and six one-line calls.

`hpIdxBaseHierPathEmpty94(hier_path*)` runs after `Path_elems` is complete, at
all six hier_path-building sites in the expression emitter, and fires only when

* the **LAST** path element is an `indexed_part_select`, **and**
* its `Base_expr` object is a `hier_path` (the row golden has and we lacked), **and**
* its `Width_expr` object is a `constant` or a `ref_obj` — the two kinds this
  function renders **exactly** (`VpiDecompile` / `VpiName`), **and**
* the name really has a trailing top-level bracket group.

Then the group's body is replaced by `"+:"`/`"-:"` + the width text, and the
`indexed_part_select`'s own `VpiFullName` follows the same substitution when it
mirrored the path name.

An **operation** width would need `prettyPrint`, whose UHDM implementation
dereferences `oper->Operands()` **unchecked** (`ExprEval.cpp:1015`, `1086`, `1095` — uvm93's
crash lesson), and whose corpus population under this gate is **ZERO**; it keeps
the pre-existing raw-text rendering. Every cell the gate takes is a cell where
golden's own name equals the composition, proven per object by the oracle.

## The arms — 62 cells, BOTH views, `BROKE = 0`

| arm | cells | ALREADY-OK | FIXED | **BROKE** | STILL-WRONG |
|---|---|---|---|---|---|
| `g94_a0_head.sv` — the 164-line head in 19 lines; base kinds hier_path / ref_obj / constant / operation, `+:`/`-:`, a part_select and a bit_select beside them | 8 | 6 | **2** | **0** | 0 |
| `g94_a1_idxbase.sv` — base-kind × width-kind × carrier (LHS / cast / streaming / call arg / by-ref) × depth 1-3 × class-method / package-function / module homes | 26 | 9 | **13** | **0** | 4 |
| `g94_a2_homes.sv` — interfaces, module hierarchy, struct and packed-union members, generate and task homes, and the base kinds the gate must REFUSE | 20 | 3 | **9** | **0** | 8 |
| `g94_a3_widthref.sv` — the `ref_obj` WIDTH row (an overridable module parameter), plus operation/`$bits` widths and a name with no bracket group | 8 | 1 | **5** | **0** | 2 |

Identical counts in `def` and `-elabuhdm`, `rc=0` on every cell in both views.

**`g94_a0_head.sv` CONVERTS**: pristine `CMP_FAIL`, 1 head, 164 cmp lines →
patched **`PASS_CMP`, 0 heads**, in **both** views. Said loudly, as the brief
requires; no `results/*.csv` row was touched.

The arms are deliberately not self-confirming: base kinds sit on differently
named members of differently named holders, widths differ per cell, `+:` and
`-:` alternate, and the cells that must NOT move (`ref_obj`, `constant` and
`operation` bases, part_selects, bit_selects, dotted **indices** over local
targets) sit beside the ones that must. `g94_a2`'s `t1`/`t2` prove the structural
precondition: a dotted **index** over a **local** target builds no hier_path at
all, so the law cannot reach it.

## Residues, each measured and named

* **R1 — an OPERATION base.** `chan94.lane[cel.where * 2 + 1 +: 28]` is golden's
  `[ * 2 + 1+:28]`: `prettyPrint` renders the hier_path operand EMPTY and keeps
  the operator and its spaces (uvm92's law, one level in). We keep the raw text.
  **2 arm cells, corpus population 0.**
* **R2 — a CAST base.** `chan94.lane[int'(cel.where) +: 27]` is golden's
  `[+:27]`: `vpiCastOp` has no `prettyPrint` row. **1 arm cell, population 0.**
* **R3 — a `bit_select` base.** `chan94.lane[nibs[2] +: 25]` is golden's
  `[[2]+:25]` — `decompileHelper`'s own bracket row on the BASE.
  **1 arm cell, population 0.** (uvm92's R4 is the same row at the receiver site.)
* **R4 — an OPERATION or `$bits` WIDTH.** `[+:SRAMAW94 + 2]`, `[+:48]`: the gate
  refuses them rather than call `prettyPrint`. **2 arm cells, population 0.**
* **R5 — the base/width FOLD, Earlgrey only.** Golden folds
  `[FlashWordsW+:PageW]` to `[7+:8]` and `rp94::RW94` to `7` in a BASE, and keeps
  a module localparam width SPELLED where we fold it. 24 corpus cells the census
  scores `FIX` that this gate does not take (their base is a constant, not a
  hier_path) plus 114 `STILL` cells; **all in `Earlgrey_0_1`, already
  CMP_NOTEQUAL, and this pass leaves every one of them byte-identical.**
* **R6 — operator SPACING in a width**, `[0+:IDW-STIDW]` vs golden
  `[0+:IDW - STIDW]`. **2 Earlgrey cells, untouched.**
* **R7 — the post-reduction FOSSIL**, the oracle's own 380: a `vpiIntConst`
  base/width whose name predates the reduction. **Unreachable by construction**
  from a final tree; it is what makes the part_select family a fence and not a
  target.

## The gates, in one line each

Build md5s `3856ec23…` (pristine, byte-identical to the main tree at 913bc0f) /
`646a349f…` (patched). Goldens **23/0** patched, **23/0** pristine, **0/23** with
`SLANG_UHDM=/bin/false`. uhdm2rtlil **679/50/2** both modes, ct8rows **0
differing rows** against the committed gate CSV *and* against my own pristine
sweep, both modes. surelog **470+11+5+283+25 / 466+9+5+3+1+284+23+1+2**, ct8rows
**0 differing rows** on 1588, **NO ROW CONVERTED, NO ROW REGRESSED**. Bytes:
**7 movers / 956** and **0 / 1358** — exactly what `PREDICT.r10uvm94.txt` named
from pristine bytes before the gate ran. Attribution, **order-blind and
id-blind**: `ins == del == 28` on every mover, **four line kinds only**
(`hier_path`, `indexed_part_select`, `vpiName`, `vpiFullName`), all
`packer.m_bits[]` → `packer.m_bits[+:32]`; Scoreboard/default, the ~50/50 coin,
shows the same order-blind delta and nothing else. Boundary **LISTED=2837
PROCESSED=2837 MOVED=4 ASYMMETRIC_OUTPUT=0** over **both views** — the 4 are this
pass's own two new arms in def and elab, the positive control, and **zero** of
the 2833 pre-existing arms moved. Canaries **56/0/0**, **9/0/0**, ctcan2
**58/0/0** and **1/0/0**; `canaudit` **33 audited, 0 UNCOVERED, 0 FENCE-BREACH**.
Pins **SAME=10 MOVED=0**: `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`,
InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical. Full detail in
`GATES.r10uvm94.txt`.

**The prediction was made first**, and it is INTRINSIC: `ct94cen` computes
`decompileHelper` on a database's own tree, so `pred94.py` needs neither a golden
nor a patched binary. It named 7 databases and 28 cells; the byte gate returned
exactly those 7 and exactly 28 changed cells.

## R0 — the new head, for the next pass

All seven UVM row-modes share ONE new head, **54 cmp lines**, byte-identical
across the seven after id-stripping (md5 `d50def21c86d`), at
`uvm_object_defines.svh:3364` — the `` `uvm_record_int `` / `` `uvm_record_field ``
body, where `SIZE` is `$bits(m_data[i])`:

```
LHS golden  constant: , line:3364:13, endln:3364:29
              |vpiParent: \_operation:
              |vpiDecompile:8  |vpiSize:64  |UINT:8  |vpiConstType:9
RHS ours    sys_func_call: ($bits), line:3364:13, endln:3364:29
              |vpiParent: \_operation:
              |vpiArgument: \_bit_select: (…do_record::m_data)
                              |vpiIndex: \_ref_obj: (…do_record::i)
              |vpiName:$bits
```

(Head counts for BuildUVMPkg / Earlgrey_0_1 / Rggen read 84 / 64 / 104 here where
uvm93's write-up read 29 / 19+37 / 36: those were measured in uvm93's worktree at
its own base `b1a0447`, and BuildUVMPkg pass 5, Earlgrey pass 53 and YosysVerx
landed between that base and 913bc0f. Both numbers quoted above — pristine and
patched — come from the SAME base 913bc0f with the SAME `rowheads.sh`, and those
three rows are byte-identical between them.)

Golden **FOLDS `$bits(<expression>)` to the width** (`8` for a `byte` element of
`m_data`) and we keep the call. This is the `$bits(<expr>)` family uvm89/buvm16
listed as R3 and uvm93 §3 explicitly deferred — now the head. BuildUVMPkg keeps
its own older head (84 lines, unchanged).

## Reproducing

```sh
g++ -O2 -std=c++17 ct94cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10uvm94_ct94cen
./gvg94.sh ~/.cache/slang-uhdm-goldens        # golden-vs-golden: the decode as an ORACLE
./gvg94.sh <pristine workdir>/sl              # or scoped to a corpus
./cen94.sh <workdir> <outdir>                 # golden + ours, every row-mode
./cenjoin94.sh <outdir>                       # SAME / FIX / BREAK / STILL
python3 join94.py <out>/default_SeqDriver.{g,o} --verbose
python3 pred94.py <pristine census dir>       # the movers, from PRISTINE bytes alone
PRI=… PAT=… MODE=def  ./arm94.sh g94_a0_head.sv ; ./three94.sh /tmp/r10uvm94_armwd/g94_a0_head_def
PRI=… PAT=… MODE=elab ./arm94.sh g94_a0_head.sv ; ./three94.sh /tmp/r10uvm94_armwd/g94_a0_head_elab
PRI=… PAT=… ROOT=<worktree>/tools/probe ./bound94.sh    # BOTH views, 2837 sources
./ct8rows.sh <baseline.csv> <fresh.csv>  ;  SELFCHECK=1 ./byteverify.sh <pat wd> <pris wd>
./attr94.sh <pat wd> <pris wd> default/SeqDriver-32af76aa
./pins94.sh <pat wd> <pris wd>
bash canaudit.sh canaries.sh ctcan2.sh
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                 BuildUVMPkg Earlgrey_0_1 Rggen
```
