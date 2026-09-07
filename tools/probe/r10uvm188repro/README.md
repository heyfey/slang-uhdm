# r10uvm188 — § `enumConstLitArithRender188` — **AN ENUM CONSTANT WHOSE INITIALISER IS ARITHMETIC OVER INTEGER LITERALS IS RENDERED BY SURELOG'S `prettyPrint` AND SIZED BY SURELOG'S `LValue`, AND THE ENUM'S BASE TYPE PLAYS NO PART** — the BuildUVMPkg ×2 36-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list — the wide boundary compiles `tools/probe` arms
exclusively and dispatches no corpus test at all.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `4bf4d571` |
| pristine binary | md5 `b15c4f042d5928e133f3bde9806352c4`, built from this pass's OWN worktree at a clean `4bf4d571` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own binary at that commit** |
| patched binary | md5 `68c7dfe93c50cdb63be7e224a1c935f0`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` only (one file-static renderer + one gate in `buildEnumTs`, +307 lines, nothing deleted) |
| probe surface | `tools/probe/r10uvm188repro/` only |

---

## READ THIS FIRST — the numbers

| | pristine | patched |
|---|---|---|
| `BuildUVMPkg` cmp lines, default / testflags | **36 / 36** | **33 / 33** |
| `BuildUVMPkg` heads (`grep -c '^LHS:'`) | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp md5, both modes | `7f92233e04ae` | `492bbfad6a5e` |
| head object | `enum_const(UVM_DEEP)` — decompile `1<<16` vs golden `1 << 16` | a **different object and a different kind**: an EXTRA `constant` of ours under a package `param_assign`, `LHS: <null>` (**R0**) |
| the other twelve head-set cmp logs | — | **byte-identical between the two binaries** |
| grid cells, four arms × real Surelog goldens | 74 match | **192** — **TO-GOLDEN 118, AWAY-GOLDEN 0, CHANGED-STILL-WRONG 0, WRONG-KEPT 0** |
| corpus enum-constant census (34910 cells) | 7777 match | **7783** — TO-GOLDEN 6, AWAY 0, CHANGED-STILL-WRONG 0 |
| byte movers | — | **2 / 956** surelog (BuildUVMPkg ×2, **predicted by name from pristine databases first**), **0 / 1358** u2r |
| boundary | — | 5071 listed = 5071 processed, **12 moved arms**: 4 this pass's own, 5 that move TO-GOLDEN 2 / AWAY 0 each, 3 attributed to a `.bss` ADDRESS this pass did not write (§ 5.2) |

---

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

`/tmp/…/heads_pris/BuildUVMPkg.default.cmp`, 36 lines, md5 `7f92233e04ae`,
`grep -c '^LHS:'` = 1, byte-identical to the testflags log — read before a line
of code was written:

```
LHS:
enum_const: (UVM_DEEP), id:61526, line:7932:3, endln:7932:31
|vpiParent: \_enum_typespec: (uvm_pkg::uvm_recursion_policy_enum), id:61515
|vpiName:UVM_DEEP
|UINT:65536
|vpiDecompile:1 << 16
|vpiSize:80
RHS:
enum_const: (UVM_DEEP), id:293, line:7932:3, endln:7932:31
|vpiParent: \_enum_typespec: (uvm_pkg::uvm_recursion_policy_enum), id:288
|vpiName:UVM_DEEP
|INT:65536
|vpiDecompile:1<<16
|vpiSize:64
```

The source (`1800.2-2017-1.0/pp_output/uvm_pkg.sv`):

```
7856  parameter UVM_FIELD_FLAG_RESERVED_BITS = 28;
7859  typedef bit [UVM_FIELD_FLAG_RESERVED_BITS-1 : 0] uvm_field_flag_t;
7930  typedef enum uvm_field_flag_t {
7931    UVM_DEFAULT_POLICY = 0,
7932    UVM_DEEP           = (1<<16),
7933    UVM_SHALLOW        = (1<<17),
7934    UVM_REFERENCE      = (1<<18)
7935   } uvm_recursion_policy_enum;
```

### 1.1 THE LADDER — which field fails, and what sits behind it

Read out of the generated `Compare`s, not guessed
(`~/git-repos/UHDM/build/generated/src/{enum_const,expr}.cpp`):

| step | reader | golden | ours | verdict |
|---|---|---|---|---|
| 1 | `BaseClass::Compare` `VpiType` / `VpiName` / `VpiDefName` | `enum_const` / `UVM_DEEP` | same | equal |
| 2 | `expr::Compare` **`VpiDecompile`** | `1 << 16` | `1<<16` | **FAILS FIRST** |
| 3 | `expr::Compare` `VpiSize` | 80 | 64 | next |
| 4 | `expr::Compare` `Typespec` | null | null | equal |
| 5 | `enum_const::Compare` `VpiName` / `VpiDecompile` / `VpiSize` | (the same three again) | | |

**`VpiValue` is NOT a field any `Compare` on this object reads.** (The verifier
re-read the generated sources and narrowed this: NO generated `Compare` reads a
`VpiValue` at all — `constant::Compare` adds only `VpiConstType` on top of
`expr::Compare`. The conclusion for this head is unchanged.) The
`UINT:` vs `INT:` split in the dump is therefore invisible to the judge; this
pass corrects it anyway, because it is the same `Surelog::Value` the SIZE comes
from and leaving half of one object's state wrong makes the next census
unreadable.

So the head is **two compared fields on one object**, and they are **one law**:
both come from the pair of Surelog evaluators the enum-constant builder runs.

---

## 2. THE LAW, DECODED FROM SURELOG

`CompileHelper::compileTypeDef` (`CompileHelper.cpp` ~820–870) and
`CompileHelper::compileTypespec`'s enum arm (`CompileType.cpp` ~1314–1375)
build a written enum initialiser the same way:

```cpp
any* exp = compileExpression(scope, fC, enumValueId, compileDesign, reduce, …);
if (exp && exp->UhdmType() == uhdmconstant)
     value = m_exprBuilder.fromVpiValue(c->VpiValue(), c->VpiSize());
else value = m_exprBuilder.evalExpr(fC, enumValueId, scope);
econst->VpiDecompile(UHDM::ExprEval().prettyPrint(exp));  // CompileHelper.cpp:864
econst->VpiSize(value->getSize());                        //   CompileType.cpp:1367
econst->VpiValue(value->uhdmValue());
```

A **LITERAL** always compiles to a `constant`, so it takes the first path and
keeps its written spelling, encoding and width — that is the branch this pass
does not touch. An **OPERATION** only folds to a constant under `Reduce::Yes`,
i.e. in the ELABORATED listing; the DEFINITION listing gets the operation
itself, and with it both of Surelog's own renderers.

### 2.1 `UHDM::ExprEval::prettyPrint` — the SPACING table, extending buvm14's R5

`UHDM/templates/ExprEval.cpp:949+`, read arm by arm:

| node | rendering |
|---|---|
| `constant` | its own `VpiDecompile` (the written spelling) |
| `parameter` / `enum_const` | `VpiValue` with everything up to `:` trimmed |
| `ref_obj` | `VpiName` |
| BINARY `- / % == != === !== > >= < <= << >> + * && \|\| & \| ^ ^~ <<< >>> ** -> \|=> \|->` | `op0` **SPACE** token **SPACE** `op1` |
| UNARY `- + ! ~ & ~& \| ~\| ^ ~^ ++ --` | token immediately followed by `op0`, **no space** |
| `? :` | `c` ` ? ` `a` ` : ` `b` |
| concat / assignment pattern | `{a,b}` / `'{a,b}` — commas, **no spaces** |
| multi-concat | `{n{x}}` |
| `inside` | `x inside {a,b}` |
| post inc/dec | `x++` / `x--` |
| part select / indexed part select | `l:r` / `b+:w`, `b-:w` |
| `var_select` | `name[e0][e1]…` |
| **PARENTHESES** | **there is no arm for them at all — they VANISH** |

`(1<<16)` therefore renders `1 << 16`; `(2 + 3) * 4` renders the misleading
`2 + 3 * 4`; `((1) << (3))` renders `1 << 3`.

### 2.2 `ExprBuilder::evalExpr` + `Surelog::LValue` — the SIZE and the ENCODING

`ExprBuilder.cpp:72+` reduces through `Surelog::LValue`, whose arithmetic is
**not the language's** (`Value.cpp`):

| operator | size | `Value::Type` |
|---|---|---|
| `a << b` (`LValue::shiftLeft`, Value.cpp:1837) | `a.size` **+ b's VALUE** | **Unsigned, unconditionally** |
| `a >> b` (`LValue::shiftRight`, :1849) | `a.size` **− b's VALUE** | **Unsigned, unconditionally** |
| `+ − * /` (`plus`/`minus`/`mult`/`div`, :872+) | `max(a.size, b.size)` | **A's OWN type**: Integer→Integer, Scalar/Unsigned/…→Unsigned |

and a leaf's size comes from `evalExpr`'s `slIntConst` arm
(`ExprBuilder.cpp:419`):

| leaf | call | size | type |
|---|---|---|---|
| plain decimal `1` | `value->set(uint64_t)` (Value.cpp:1070) | **64** | **Unsigned** |
| SIZED based `8'h1` | `set(v, Type::Unsigned, intsize)` | the **written size** | Unsigned |
| UNSIZED based `'h10` | `set(v, Type::Integer, 0)` | **0** | **Integer** |

`LValue::uhdmValue` then prints `UINT:` for Unsigned and `INT:` for Integer.
So `1 << 16` is **80** bits and **UINT**; `256 >> 3` is **61**; `8'h1 << 9` is
**17**; `'h10 << 4` is **4**; `'h3 + 40` encodes **INT** while `40 + 'h4`
encodes **UINT**. The ENUM'S BASE TYPE never enters any of it.

### 2.3 The ELABORATED listing

There `compileExpression` folds, so the value is rebuilt from the FOLDED
constant with `fromVpiValue(c->VpiValue(), c->VpiSize())` and the decompile is
`prettyPrint(constant)` = the folded digits. Measured across 30 shapes:

* size **64** for every shape EXCEPT a PURE `+` TREE, which carries the **same
  modelled size** the definition listing does (`3'h2 + 3'h1` folds to `3` at
  size **3**, `4'h5 + 4'h3` to `8` at size **4**), with a width-indeterminate 0
  published as Surelog's unsized marker **−1** (`'h1 + 'h2` folds to `3` at
  −1).  **CORRECTED BY THE VERIFIER** (`r10v188repro/README.md` § 2,
  `r10v188repro/arms/v188_f_fold.sv`): this pass first wrote "64 when the
  OUTERMOST operator is a shift", which seven shapes against a real golden
  refute — `4'hF * 4'h3`, `4'hC - 4'h2`, `4'hC / 4'h2`, `'h6 * 'h3`,
  `'h9 - 'h2`, `3'h1 + 3'h1 * 3'h3` and `(1 << 2) + 3'h1` all fold at 64 while
  their definition listings measure 4, 4, 4, 0, 0, 3 and 66.  The discriminator
  is `anyShift || anySubMulDiv`, i.e. a shift ANYWHERE plus the same
  signed-reduction flag the encoding below uses;
* encoding **INT** when the expression contains a SUBTRACTION, MULTIPLICATION or
  DIVISION, **UINT** otherwise — the generalisation of § `unitArithShape`'s
  "a subtraction reduces signed";
* **except** a shift whose LEFT operand is an UNSIZED based literal
  (`'h1 << 12`), which UHDM declines to fold at all: the elaborated listing
  then REPEATS the definition one (golden lists it once, `N=2`).

A CLASS / MODULE / INTERFACE home has only ONE listing and it is the
DEFINITION render (arm b).

---

## 3. THE PATCH

One file-static renderer (`SrlgLitArith` + `srlgEnumLitArith`) above
`buildEnumTs`, mirroring §2 arm for arm, and one gate inside the enum-constant
loop placed **before** every base-width branch — because §2 proves the base
plays no part. It fires only when the initialiser is a BinaryOp tree over
`+ − * / << >>` whose leaves are all integer literals, and it **abstains**
(leaving the constant exactly as the pristine binary writes it) on everything
else: a reference, a call, a concatenation, a conditional, a unary operator, an
`x`/`z` digit, a signed tick, a written size above 64 bits, a shift of 64 or
more, a division by zero, a negative modelled size, or a `$unit` enum
(§ `unitArith` / § `unitArithShape` own that listing) or an IMPORT-LISTING
CLONE (its own measured rules). The last guard is the strongest: **the
emulated value must equal slang's own folded value or the whole render is
discarded**.

---

## 4. THE GRID — four arms, each against a REAL SURELOG GOLDEN

`grid188.sh` builds one real `surelog -parse -d coveruhdm` golden per arm (and
again with `-elabuhdm`) plus both binaries' databases in both views, recording
every rc.

| arm | what it varies | cells | TO-GOLDEN | AWAY | CHANGED-STILL-WRONG | WRONG-KEPT |
|---|---|---|---|---|---|---|
| `probe0.sv` | the head's own shape, different names/case/numbers | 18 | **6** | 0 | 0 | 0 |
| `grid188/g188_a_shapes.sv` | 13 initialiser shapes × 3 BASES (none / written `bit[23:0]` / typedef name) | 88 | **60** | 0 | 0 | 0 |
| `grid188/g188_b_scopes.sv` | 3 shapes × 5 HOMES (package / class / module / interface / imported package) | 34 | **16** | 0 | 0 | 0 |
| `grid188/g188_c_order.sv` | listing ORDER, CASE, interior WHITESPACE, redundant PARENTHESES, shift magnitudes 1…63, unsized based literals in every operand position | 52 | **36** | 0 | 0 | 0 |
| | | **192** | **118** | **0** | **0** | **0** |

Arm `b` goes from **36 cmp lines / 1 head to 0 lines / 0 heads** — the whole
arm compares EQUAL. Arm `a`'s three bases carry the SAME golden rows, which is
the measurement that moved the gate off `baseSyn` and onto the SHAPE.

Two of this pass's rules were written *because an arm refuted the first cut*:
the folded size (from `r10earl66repro/g2_enc66.sv`, flagged by the boundary
gate: `3'h2 + 3'h1` folds at 3, not 64) and the unsized folded marker (arm c
`c_I`/`C_H`: `'h1 + 'h2` folds at −1, not 0).

---

## 5. THE BOUNDARY

`bound188.sh`, over a COPY of the whole probe tree: **5071 listed = 5071
processed**, children `</dev/null`, the file list on fd 3, scratch keyed on the
RELATIVE path. This pass's own four arms are the POSITIVE CONTROL and all four
moved, so the gate can see.

### 5.1 The five arms this law really moved — each scored against a REAL golden

| arm | cmp lines pris → pat | TO-GOLDEN | AWAY | CHANGED-STILL-WRONG |
|---|---|---|---|---|
| `r10earl66repro/g2_enc66.sv` | 36 → 36 | 2 | 0 | 0 |
| `r10uvm138repro/g138_b_kinds.sv` | 36 → 36 (head ADVANCES `BA_A` → `BA_B`) | 2 | 0 | 0 |
| `r10v138repro/v4_kinds.sv` | 36 → 36 | 2 | 0 | 0 |
| `r10v154repro/v154_c_muststay.sv` | 36 → 36 | 2 | 0 | 0 |
| `r10v66repro/v5_odd66.sv` | 34 → 36 (head ADVANCES `EE` → `LL`) | 2 | 0 | 0 |

The two arms whose cmp log grew are the head ADVANCING onto the next, older
residue on the same enum — a cmp line count is the head object's decompile
size, not a distance.

### 5.2 The three arms that moved on an ADDRESS this pass did not write

`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv` and
`r10uvm185repro/grid185/g185_e_kinds.sv` move with **zero** enum-constant
census movement, and their whole path-normalised dump diff is ONE number:

```
- |vpiDecompile:22613753      (= 0x1590EF9)
+ |vpiDecompile:22621945      (= 0x1592EF9)
```

on the range of an ASSOCIATIVE dimension (`typedef C22 ka_cls_t[string];`).
The binaries are non-PIE (`ELF … executable`, not `pie executable`), and
`readelf -SW` places both values at the **same offset 0x14B9 inside `.bss`**:

```
pristine  .bss 0x158FA40   0x1590EF9 - 0x158FA40 = 0x14B9
patched   .bss 0x1591A40   0x1592EF9 - 0x1591A40 = 0x14B9
```

`.bss` moved by exactly 0x2000 because `.rodata`/`.eh_frame` grew. The value is
the **static address of a `.bss` object leaking into the database** — a
pre-existing latent defect on a construct this law cannot reach, and one that
ANY code change large enough to move a page would shift. Recorded as **R2**.
(A comment-only null edit was built first and produced a BYTE-IDENTICAL binary,
so it could not decide the question; the ELF section arithmetic did.)

---

## 6. THE HEAD AFTER — AND R0

```
BuildUVMPkg default and testflags, 33 cmp lines, ONE head each,
both cmp logs BYTE-IDENTICAL to each other (md5 492bbfad6a5e)

uvm_pkg.sv:7856   parameter UVM_FIELD_FLAG_RESERVED_BITS = 28;

LHS: <null>
RHS ours    constant: , id:24, @7856:42-7856:44
            |vpiParent: \_param_assign: , id:23, @7856:11-7856:44
            |vpiDecompile:28  |vpiSize:64  |UINT:28  |vpiConstType:9
            |vpiTypespec: \_ref_typespec: (uvm_pkg), id:25
                            |vpiActual: \_int_typespec: , id:26, @7856:1-7856:44
```

**R0** — `LHS: <null>` with a full RHS is the SINGULAR `SafeCompare` overload
naming OURS: golden's `param_assign` for a package parameter with a written
constant carries **no `Rhs` where we mint one** (or carries no such
`param_assign` at all). A package-parameter `param_assign` Rhs-population law,
a different object and a different kind from this pass's — decode which of the
two it is from the golden database's own `param_assign` list before writing
anything.

**R1 — the enum constant's REFERENCE sites.** A folded `constant` that
inherits an enum constant's fields (an `initial z0 = cor::C_x;`, arm c
`corm`) now inherits the corrected definition render, where golden carries the
FOLDED digits (`4` / 64 / `UINT:4`): golden re-folds at the reference instead
of copying. Wrong before this pass (`1 <<  2` / 64 / `INT:4`) and wrong after
(`1 << 2` / 66 / `UINT:4`), so it is CHANGED-STILL-WRONG on a `constant`, not
an `enum_const` — a separate object family with its own law. **Zero corpus
cells** (byteverify saw 2 movers, both BuildUVMPkg, and its census is
TO-GOLDEN 6 / AWAY 0).

**R2 — a `.bss` ADDRESS in the database** (§ 5.2): the range of an ASSOCIATIVE
dimension carries the static address of a `.bss` object as a `UINT` constant,
on three probe arms and zero corpus rows. It makes every boundary gate in this
campaign report spurious movers on any patch that grows the binary by a page.
Worth fixing on its own.

**R3 — the shapes this law abstains on.** `prettyPrint` renders the WHOLE
operator table of § 2.1 and `evalExpr` has arms for `% > >= < <= == != && || &
| ^ **` as well; this pass models only `+ − * / << >>` over literal leaves
because that is what it could measure end to end. The corpus population of the
rest is **zero** among comparable rows: the corpus-wide golden census found
only 41 enum-constant rows with a spaced decompile, and outside BuildUVMPkg
every one of them is in a test that is `SLANG_REJECT`, `SURELOG_FAIL` or
`NO_DATABASE` (Opentitan, Monitor, CoresSweRV, CoresSweRVMP, rp32, Ariane2024).

**R4 — the enum constant's LISTING COUNT.** 862 of the census's 34910 cells are
WRONG-KEPT and almost all of them are MULTIPLICITY: golden lists a constant 4,
6, 10 or 16 times where we list it twice. A listing-population family, wholly
untouched here.

---

## 6b. THE VERIFIER

`tools/probe/r10v188repro/README.md` — **ACCEPT-WITH-FIX.** Every number in this
document reproduced bit for bit from freshly built binaries (pristine
`b15c4f04…`, patched `68c7dfe9…`). Seven new shapes against a real Surelog
golden refuted the folded listing's SIZE clause; § 2.3 above carries the
corrected rule and the shipped patch carries the corrected code
(`anyShift || anySubMulDiv`, binary `5b4e62c7…`). R2 was reproduced
independently from the ELF section table.

## 7. THE FILES

| file | what it is |
|---|---|
| `ct188cen.cpp` | the enum-constant census (parent kind/name, const name, span, decompile, size, value), walked FLAT over `Serializer::AllObjects()` so no per-kind recursion can miss one |
| `build188.sh` | builds it, linking UHDM statically out of `~/.local` |
| `cen188.sh` | the corpus-wide census: every test directory, both modes, golden found through each test's OWN `cmds.txt` |
| `score188.py` | the golden × pristine × patched MULTISET join and its verdict |
| `predict188.sh` | the mover set, named from PRISTINE databases alone |
| `grid188.sh` | the arm driver — one REAL Surelog golden per arm, both views, every rc recorded |
| `probe0.sv` | the head's own shape in twenty lines |
| `grid188/g188_a_shapes.sv` | 13 shapes × 3 bases |
| `grid188/g188_b_scopes.sv` | 3 shapes × 5 homes |
| `grid188/g188_c_order.sv` | order / case / whitespace / parentheses / magnitude / unsized-based — the arm that TESTS rather than agrees |
| `bound188.sh` | the wide boundary gate |
| `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `rowheads.sh` `canaudit.sh` | the standard gate battery, carried verbatim |
| `GATES.` `GRIDS.` `CENSUS.` `PREDICT.` `BOUNDARY.` `MOVERS.r10uvm188.txt` | the evidence |

## 8. REPRODUCING

```sh
./build188.sh                                         # the census instrument
CEN=/tmp/r10uvm188_cen ./predict188.sh <pristine wd> PREDICT.txt
CEN=/tmp/r10uvm188_cen ./grid188.sh probe0.sv <pris> <patched> <wd>
python3 score188.py <wd>/g.cen <wd>/a.cen <wd>/b.cen --only-moved
CEN=/tmp/r10uvm188_cen ./cen188.sh <workdir> <prefix>
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq \
                                 BuildUVMPkg Earlgrey_0_1 Rggen
PRIS=… PATCHED=… ./bound188.sh <copy of tools/probe> <outdir>
bash canaudit.sh canaries.sh ctcan2.sh
```
