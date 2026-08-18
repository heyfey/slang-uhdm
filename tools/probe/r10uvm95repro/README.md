# r10uvm95 — § `bitsSelectIgnoredRootBits95` — **THE SEVEN-ROW-MODE UVM HEAD CLEARED**

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge.
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED** — but this pass's own arm `g95_a0_head.sv` **PASSES the official
`uhdm-cmp`** in BOTH views where pristine fails with the head, and that is said
out loud below.

## The headline

uvm94 left ONE head on all seven live UVM row-modes — 54 cmp lines, byte
identical across the seven (md5 `d50def21c86d` after id-stripping). It is gone.

```
uvm-1.2 macros/uvm_object_defines.svh:3364   (`uvm_record_int body)
    if (SIZE > 64)
  invoked from tlm2/uvm_tlm2_generic_payload.svh:575 with
    SIZE = $bits(m_data[i])   and   rand byte unsigned m_data[];

LHS golden  constant: , line:3364:13-3364:29 |vpiDecompile:8 |vpiSize:64
                                             |UINT:8 |vpiConstType:9
RHS ours    sys_func_call: ($bits), line:3364:13-3364:29
              |vpiArgument: bit_select (…do_record::m_data)
                              |vpiIndex: ref_obj (…do_record::i)
```

The span is the MACRO BODY position of the substituted formal: `SIZE` starts at
column 13 and `$bits(m_data[i])` is 16 characters, so `13 + 16 = 29`.

## The law

> **`CompileHelper::compileBits` never looks at the argument EXPRESSION.**
> For anything that is not a type keyword it walks
> `Expression → Primary → Primary_literal → StringConst` and hands that **BARE
> NAME** to `getTypespec`, whose `slStringConst` arm follows only siblings that
> are themselves `StringConst` — i.e. **dotted member suffixes**. A bracket
> suffix is a `Constant_bit_select` / `Part_select_range` node, never a
> `StringConst`, so **the selects are INVISIBLE to the fold**:
>
> | written | golden |
> |---|---|
> | `$bits(v32[3])`, `$bits(v32[7:0])`, `$bits(v32[i+:4])` | **32** (the whole `bit [31:0] v32`) |
> | `$bits(pk4[i])`, `$bits(pk4[i][3])` (`bit [7:0] pk4 [4]`) | **32** |
> | `$bits(w2[i][7:0])` (`bit [15:0] w2 [3]`) | **48** |
> | `$bits(md[i][1])` (`int md [2][3]`) | **192** |
> | `$bits(m_data[i])` (`byte m_data []`) | **8** — the head |
>
> and `Bits()` over that typespec **multiplies the FIXED unpacked dimensions
> while an UNSIZED one (`[]`, `[$]`, `[string]`) contributes exactly ONE**.
> `real`/`shortreal` answer **32**; `realtime`, `time`, `string`, `chandle` and
> class handles have **no answer** and the `sys_func_call` survives.

A **DOTTED** argument is a different road (`paComplex_func_call` →
`compileExpression` → `hier_path` → `decodeHierPath`) which DOES resolve
members and a trailing bit_select — untouched here, and named as R1/R2 below.

### Five orthogonal grids, golden-side, run BEFORE any code

| grid | home | cells | what it pins |
|---|---|---|---|
| `g95_a1_classsel.sv` | class method (in-block) | 42 | every argument shape over an OWN class property: bare / `[const]` / `[var]` / `[i][j]` / part-select / indexed-part-select / `.member` / `[i].member` / `this.` / `handle.`, over byte / int / packed vector / packed struct / enum / typedef / fixed unpacked / **dynamic** / **queue** / **assoc** / string / real / class handle / 2-D |
| `g95_a2_modsel.sv` | module `initial` | 25 | the SAME argument shapes over MODULE SIGNALS — the law is identical, which is what proves it belongs to `compileBits` and not to the class rule |
| `g95_a3_order.sv` | module + package classes | 37 | member-vs-select ORDER (`us.a[1]` folds to 8, `spa[1].hi` KEEPS), deeper chains, type names in a class, and the SIBLING queries `$size $clog2 $high $low $left $right $dimensions $unpacked_dimensions $increment` — golden keeps **every one of them** |
| `g95_a4_elemtype.sv` | module `initial` | 14 | the ELEMENT-TYPE table: real 32, shortreal 32, realtime KEEP, time KEEP, integer 32, unpacked struct 20, packed union 8, enum 3, `real ra[3]` 96, logic/reg/bit 1 |
| `g95_a5_oob.sv` | class, in-block vs OUT-OF-BLOCK twin | 14 | § `bitsOutOfBlockNoReduce95` — decoded, NOT shipped, see R3 |

The grids are deliberately not self-confirming: every cell carries a different
width, the fixed and unsized array shapes sit beside each other, the same
argument shape is asked in two different homes, and the cells that must NOT
move (`string`, `realtime`, `time`, a class handle, a select-then-member) sit
next to the ones that must.

## The corpus census, golden vs ours, made BEFORE the patch

`ct95cen.cpp` restores a database and emits one row per **candidate span** —
a span carrying either a type-query `sys_func_call` (`$bits $size $clog2 $high
$low $left $right $dimensions $unpacked_dimensions $increment`) or a constant
wearing compileBits' exact mint signature (`vpiSize == 64 && vpiConstType ==
vpiUIntConst`), plus a `SRC$`/`SRC-` flag saying whether the WRITTEN text at
that position starts with a `$` (the head's own span reads **`SRC-`**, because
the macro body writes `SIZE` there — which is why the census keys on the span
and never on the source text). `cen95.sh` + `join95.py` join golden against
ours on the span and compare only the JUDGED shape (kind + folded value).

| corpus | dbs | SAME | FOLD_G_KEEP_O | KEEP_G_FOLD_O | VALUE | OTHER |
|---|---|---|---|---|---|---|
| uhdm2rtlil | 1358 | 214 | **0** | **0** | **0** | 2 |
| surelog | 956 | 899 | **62** | **15** | 4 | 246 |

*(the surelog row's SAME / VALUE / OTHER columns were mis-transcribed in the
pass's first write-up as 518 / 0 / 239; `CENSUS.r10uvm95.txt` — the artifact
the numbers come from — has always read 899 / 4 / 246, and the adversarial
verifier re-measured 899 / 62 / 15 / 4 / 246 from its own sweeps. The four
`VALUE` cells are R7 below, pre-existing and byte-unchanged.)*

**The whole uhdm2rtlil corpus already agrees on every type-query cell it has**
— the fence the brief asked for is clean, and no u2r CMP_EQUAL row carries a
`$bits` the two sides disagree about. (The 2 `OTHER` are one span in
`SizeOfGeneratedWireArray` where golden holds one `$bits` call and we hold two
objects at the same span; both KEEP, and the row is CMP_EQUAL.)

The 62 `FOLD_G_KEEP_O` cells are this pass's target and they are **all one
shape**, `G=CONST:8 | O=CALL:$bits`, in exactly 9 databases:

```
  10  default_BuildUVMPkg      uvm_pkg.sv 58045 58066 58275 58302 58412
  10  testflags_BuildUVMPkg               58413 58415 58428 58429 58431
   6  default_SeqDriver        uvm_object_defines.svh 3364:13-29, 3364:13-36,
   6  testflags_SeqDriver                             3365:74-90, 3365:84-107,
   6  default_SimpleUVM                               3367:78-94, 3367:88-111
   6  testflags_SimpleUVM
   6  default_MiniAmiq         (uvm_object_defines.svh 3364/3365/3367 are the
   6  testflags_MiniAmiq        `uvm_record_int / `uvm_record_field bodies;
   6  default_Scoreboard        BuildUVMPkg's uvm_pkg.sv is the same macro
  ---                          expanded into the 1800.2 pp_output)
  62
```

The 15 `KEEP_G_FOLD_O` cells are a **pre-existing** over-fire this pass
deliberately does **not** ship — see R3. They are the reason no row converts.

## The patch

`src/ExprEmit.cpp` + one declaration block in `include/UhdmExporter.h`.

* `selChainRoot95(expr)` — the root symbol of a chain of ELEMENT/RANGE selects
  over a simple name, with **no member access anywhere**; null otherwise.
* `bitsSelectThenMember95(expr)` — true when a select sits BELOW a member
  access (`spa[1].hi`), which golden keeps.
* `srlgBitsRootWidth95(type, out)` — the single transcription of Surelog's
  `Bits()`: fixed unpacked dimensions multiply, unsized ones count as ONE,
  `real`/`shortreal` are 32, `realtime`/`time`/`string`/`chandle`/class handles
  have no answer.
* `bitsRootWidth95Owns(arg)` — **the narrowness gate.** The rule is applied
  only where it can differ from what we emitted before: the argument carries at
  least one SELECT, **or** it is a bare name of `real`/`shortreal`/`realtime`/
  `time`. A bare integral name is untouched in every view, so not one of the
  thousands of existing `$bits(<name>)` folds changes value.
* `bitsRootWidth95Applies(arg, out)` — Surelog's answer, or false (keep).
* `bitsOwnClassPropFold61` (uvm61's class rule) now accepts a select chain over
  an own class property and takes its width from `srlgBitsRootWidth95`, which
  also RETIRES uvm61's declared `real` under-fire (golden's 32 is now derived,
  not guessed) and fixes the dynamic/queue/assoc case slang's own bitstream
  width answers 0 for.
* the emission site: the value override runs FIRST and the pre-existing
  value paths only fill in when it declined; the keep override fires when
  `Bits()` has no answer for an owned cell.

## The arms — 140 cells per view, BOTH views, `BROKE = 0`

| arm | cells | ALREADY-OK | FIXED | **BROKE** | STILL |
|---|---|---|---|---|---|
| `g95_a0_head.sv` — the 54-line head in 30 lines | 8 | 1 | **7** | **0** | 0 |
| `g95_a1_classsel.sv` | 42 | 17 | **23** | **0** | 2 |
| `g95_a2_modsel.sv` | 25 | 13 | **10** | **0** | 2 |
| `g95_a3_order.sv` | 37 | 28 | **5** | **0** | 4 (10 elab) |
| `g95_a4_elemtype.sv` | 14 | 9 | **5** | **0** | 0 |
| `g95_a5_oob.sv` | 14 | 8 | 0 | **0** | 6 (7 elab) |

**`g95_a0_head.sv` CONVERTS**: pristine `CMP_FAIL`, 1 head, **54 cmp lines** —
the same count as the corpus head — → patched **`PASS_CMP`, 0 heads**, in
**both** `def` and `-elabuhdm`. Said loudly, as the brief requires; no
`results/*.csv` row was touched.

## Residues, each measured and named

* **R1 — a DOTTED argument with a trailing PART-SELECT.** `$bits(us.w[3:0])`
  is golden's **16** (the whole member `w`; `decodeHierPath` resolves a
  bit_select but not a part_select) where we emit 4. The dotted road is a
  separate dispatch and is untouched. **1 arm cell, corpus population 0.**
* **R2 — a MEMBER of an OWN class property.** `$bits(sp.hi)` inside a class
  method is golden's **12**; we keep the call (uvm61's rule wants a simple
  name, and the dotted road is one golden CAN resolve here). **2 arm cells,
  corpus population 0.**
* **R3 — § `bitsOutOfBlockNoReduce95`, DECODED BUT NOT SHIPPED — and it is the
  NEXT HEAD.** A class method whose body is written OUT OF BLOCK (`extern` +
  `C::m`) compiles with `Reduce::No`, so **every** arm of `compileBits` fails
  its `(reduce == Reduce::Yes)` guard and the bare `sys_func_call` survives —
  `$bits(byte)` and `$bits(int)` included, which is what pins this to the
  reduce MODE and not to name resolution (grid `g95_a5_oob.sv`: the in-block
  twin folds byte/int/own-typedef/package-typedef/own-property, the
  out-of-block twin folds none of them, and `$clog2` / `2+3` / `P*2` behave
  identically on both sides). It is **not shipped** because golden splits it by
  package COPY: in the DEF package listing the call SURVIVES, in the TOP
  listing the same cell FOLDS (grid g95_a5 golden line 202 vs line 1056 of the
  dump), and this pass has not decoded which of our two class-body copies is
  which — `curPkgEmitSym && !pkgEmitTopView` is provably NOT it (pristine folds
  in both). Shipping it un-split is a WASH (one cell right, one cell newly
  wrong), so it was refused. `bitsOutOfBlock95()` ships as a documented,
  UNCALLED predicate for the next pass.
* **R4 — a bare `$bits(<dynamic array>)` in a MODULE.** `$bits(dyn)` over
  `byte dyn[]` is golden's 8; the module path keeps the call because
  `r9DimsLiteral` refuses the unsized `[]` dimension. The CLASS path (the
  head's own) now folds it. **1 arm cell, corpus population 0.**
* **R6 — an OPERATION argument is typed by its LEFTMOST NAME.**
  `$bits(m_data[i] & be)` (`uvm_pkg.sv:58066`, `do_compare`) is golden's **8**:
  `compileBits`' default branch takes `Expression → Primary → Primary_literal
  → StringConst`, which for a binary operation is the FIRST operand's leading
  name. We keep the call (the argument is a `BinaryOp`). **2 corpus cells,
  both in BuildUVMPkg, the only 2 of the original 62 still open.**
* **R7 — `new [$bits(<enum member>)]`.** `uvm_pkg.sv:58248/58283` is golden's
  **0** where we fold to 32 — Surelog resolves nothing inside a `new[]` size.
  **4 corpus cells, PRE-EXISTING and byte-unchanged by this pass** (the census
  scores VALUE=4 before and after).
* **R8 — a QUALIFIED ROOT under a select. FOUND BY THE ADVERSARIAL VERIFIER
  (r10v95), corpus population 0, wrong-before and wrong-after.** When the
  select chain's root is reached through a QUALIFIER — a hierarchical instance
  path (`u_a.larr[1]`, `bi.blk[0]`), a package scope (`p11::pk_vec[1]`) or a
  `$unit`-scope declaration (`gWide[3]` declared outside any module) — golden
  KEEPS the `sys_func_call` outright: `compileBits`' `Primary_literal →
  StringConst` walk never reaches a bare name there. Pristine already folded
  those cells (with the SELECT's width); this pass folds them with the ROOT's
  width. Both are wrong and `uhdm-cmp` sees the same kind mismatch either way,
  so nothing regressed — but the value moved. Measured on the verifier's arms
  `v95_b5_hier.sv` (3 cells), `v95_b10_unit.sv` (6 cells) and
  `v95_b11_iface.sv` (4 cells), def and `-elabuhdm` alike. **Corpus population
  0**: byteverify moved exactly the 9 predicted databases and the u2r census is
  0/0/0 before and after. The one-line gate for a later pass is to refuse in
  `bitsRootWidth95Owns` when the stripped argument is a
  `HierarchicalValueExpression`, or when the root symbol's parent scope is a
  package / the compilation unit / a foreign instance body.

* **R5 — the SPAN of a kept `$bits`.** Golden's surviving `sys_func_call`
  wears a NAME-ONLY span (`$bits`, 5 columns); ours spans the whole call.
  `uhdm-cmp` reads neither, so this is dump-only.

## R0 — the new head, for the next pass

All seven UVM row-modes share ONE new head, **12 cmp lines**, byte-identical
across the seven after id-stripping (md5 `b9ae93ae0e1d`), at uvm-1.2
`tlm2/uvm_tlm2_time.svh:87`:

```
   local function real to_m_res(real t, time scaled, real secs);
      return t/real'(scaled) * (secs/m_res);      // col 16..20 is `real`

LHS golden  real_typespec: , line:87:16, endln:87:20
RHS ours    logic_typespec: , line:87:16, endln:87:20
```

It is the `vpiTypespec` of a `vpiCastOp` (opType 67) operation —
`real'(scaled)` — reached through a `ref_typespec`
(`uvm_pkg::uvm_tlm_time::to_m_res`). Golden mints a `real_typespec` for the
`real` cast keyword; we mint a `logic_typespec`. A pure typespec-KIND head, no
value and no name involved.

BuildUVMPkg keeps its own older 17-line head, byte-untouched by this pass.

The `$bits` family's own next step is **R3 above** — §
`bitsOutOfBlockNoReduce95` and its per-package-copy split — which owns 15
corpus cells across the same nine databases, plus **R6**: golden types an
`$bits(<expression>)` by its LEFTMOST NAME too (`$bits(m_data[i] & be)` at
`uvm_pkg.sv:58066` is golden's 8; we keep the call because the argument is a
BinaryOp). R6 is the last of the 62 census cells still open, 2 of 2 remaining.

## Reproducing

```sh
g++ -O2 -std=c++17 ct95cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10uvm95_ct95cen
./cen95.sh <sweep workdir root> <censusdir>     # golden + ours, every row-mode
python3 join95.py <censusdir> [--verbose]       # SAME / FOLD_G_KEEP_O / KEEP_G_FOLD_O / VALUE
PRI=… PAT=… MODE=def  ./three95.sh g95_a0_head.sv
PRI=… PAT=… MODE=elab ./three95.sh g95_a0_head.sv
PRI=… PAT=… ROOT=<worktree>/tools/probe ./bound95.sh        # BOTH views
./ct8rows.sh <baseline.csv> <fresh.csv> ; SELFCHECK=1 ./byteverify.sh <pat wd> <pris wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                 BuildUVMPkg Earlgrey_0_1 Rggen
./pins95.sh <pat wd> <pris wd> ; bash canaudit.sh canaries.sh ctcan2.sh
```
