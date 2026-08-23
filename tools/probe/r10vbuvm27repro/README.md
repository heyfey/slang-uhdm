# r10vbuvm27 — the ADVERSARIAL VERIFIER of r10buvm27 (§ `binOpLeftmostSelectBits27`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number of `r10buvm27` reproduced
bit-for-bit from scratch (both binaries rebuilt here, both md5s hit exactly).
The decoded law is CORRECT and the head clears. But the law had **one
unfenced home**: `$bits` inside a **generate block**, where Surelog folds
NOTHING and the pristine emitter already agreed with it. The shipped patch
turned those agreeing cells into disagreeing ones — **74 arm cells over five
arms in both views, corpus population 0**. This directory adds the fence
(§ `genBlockBitsNoLeftmostFold27v`, `src/ExprEmit.cpp`), which restores exact
pristine behaviour inside generate blocks and **changes not one byte of either
corpus**: the fixed binary is byte-identical to the implementer's patched
binary over all 956 surelog and all 1358 uhdm2rtlil databases.

**MEASUREMENT-ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py`
are the only judges. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**
slang was NOT patched, `results/*.csv` were READ ONLY, nothing was promoted,
`GOLDEN_DEFER` unset, the main tree was never written to.

| | |
|---|---|
| BASE | `4c36d4b` |
| worktrees | `/tmp/wt_vbuvm27` (patched+fix), `/tmp/wt_vbuvm27pris` (pristine) |
| pristine binary | md5 `e9a8db733bb9a47e21953a189e23696e` (implementer's pin, hit exactly) |
| implementer's patched binary | md5 `1f1aeb7efc0e9d743d3ace3c07f71f13` (implementer's pin, hit exactly) |
| **verified binary** | md5 `9053d04684a79cd879ba8647d992eca0` |
| production surface | `src/ExprEmit.cpp` only (implementer's substitution + this fence) |
| deliverable | `/tmp/r10buvm27.verified.patch` |

## 1. WHAT WAS REPRODUCED (independently, from a fresh 4c36d4b)

| claim | reproduced |
|---|---|
| pristine / patched binary md5 | **yes, both exactly** |
| goldens 23 PASS / 0 FAIL (each binary, `SLANG_UHDM` exported per binary) | yes; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL |
| u2r both modes 679 / 50 / 2 | yes |
| surelog 471+466 = **937 CMP_EQUAL**, 10+9 = **19 CMP_NOTEQUAL** | yes, identical to pristine |
| `ct8rows` vs committed baselines and vs pristine, both corpora, both modes | **0 differing ROWS** (status AND dump column) everywhere |
| byte movers | surelog **2 / 956** (the two PREDICTED `BuildUVMPkg` rows; the Scoreboard coin did NOT flip in this run), u2r **0 / 1358** |
| `BuildUVMPkg` head 76 → 32, one head, modes byte-identical | yes; pristine cmp md5 `0f7013a40fb6e761208de1ca0fee3c2d`, patched `c8959ae94a5c768e14dc450e000e3426` — both pins hit |
| all other rowheads unchanged (SeqDriver 64, SimpleUVM 22, Scoreboard 22, MiniAmiq 348, Earlgrey_0_1 46, Rggen 0) | yes |
| census SAME 917→919, FOLD_G_KEEP_O **2→0**, KEEP_G_FOLD_O 15, VALUE 4, OTHER 246, OUT_OF_SCOPE_DIFF 17687 | yes, every column |
| canaries sl ok=52/u2r ok=8 changed=0, `ctcan2` PASS ×2, `canaudit` audited=33 UNCOVERED=0 FENCE-BREACH=0 | yes |
| protected DBs: InterfaceModPort / BlackParrotComplex / YosysOldOr SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | yes, pins SAME=10 MOVED=0 |
| `g27_a0_head.sv` CMP_FAIL → **PASS_CMP**, 0 heads, both views | yes (pristine 76 cmp lines in `def`, **88** in `elab` — the README's "76 in both views" is `def` only) |
| every `cmds.txt` names the frozen binary | yes: 1523/1523 sl and 1458/1458 u2r slang lines name `/tmp/vbuvm27_bin/{pris,pat}.bin`; **0** name the main-tree binary (the 50 sl / 4 u2r files with no slang line are the SURELOG_FAIL / NO_DATABASE rows) |

**Head decoded again from the pristine log, not carried forward.**
`method_func_call::Compare` → `tf_call::Compare`
(`~/git-repos/UHDM/build/generated/src/tf_call.cpp:87-95`): basetype, then
`Scope`, then **`Tf_call_args` as a VECTOR**. Both sides carry 4 args, so the
vector overload walks element-wise and stops at element 3 on `VpiType`
(`vpiConstant` vs `vpiSysFuncCall`) — the SINGULAR overload with BOTH sides
set. Source site verified in the preprocessed UVM:
`1800.2-2017-1.0/pp_output/uvm_pkg.sv:58066` is
`$bits(m_data[i] & be)` over `rand byte unsigned m_data[]`, golden 8. The law
is confirmed against Surelog's own source
(`CompileExpression.cpp:4663-4724`): the default branch takes `Child`,
`Child`, and either keeps a `paComplex_func_call` or takes a third `Child`.

**Boundary reproduced**: `LISTED=3291 PROCESSED=3291 MOVED=10` (their 8 own-arm
cells + the 2 `r10v95repro/v95_b6_exprargs` cells). Their `BOUNDARY` artifact
reports `LISTED=3290 MOVED=8` — their listing missed `r10buvm27repro/ast27.sv`
(2 cells, their own arm). Immaterial, but the number is 10.

## 2. THE DEFECT — § `genBlockBitsNoLeftmostFold27v`

> **Surelog folds NO `$bits` inside a generate block.**

Measured golden-side (`v27_f_gen.sv`, `v27_g1_gen.sv`,
`v27_g2_gencarriers.sv`, `v27_g4_genforms.sv`) across every written generate
form and every carrier inside one:

| written form | carrier | golden | pristine | implementer's patch |
|---|---|---|---|---|
| `for`-generate | `assign` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| `for`-generate | `initial` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| `for`-generate | `always` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| `for`-generate | function body | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| `if`-generate | `assign` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| `case`-generate | `assign` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| bare `generate begin:b` | `assign` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| nested generate | `assign` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| interface `for`-generate | `assign` | **KEEP** | KEEP ✓ | **CONST 32 ✗** |
| module INSTANTIATED in a generate block, own body | `assign` | FOLD 32 | KEEP | FOLD 32 ✓ |
| the same text one line OUTSIDE the block | `assign`/`initial` | FOLD 32 | KEEP | FOLD 32 ✓ |

The instantiated-child row is what makes the rule **LEXICAL**, not
instance-path: the fence therefore asks the SYNTAX tree
(`GenerateRegion` / `GenerateBlock` / `LoopGenerate` / `IfGenerate` /
`CaseGenerate` among the expression's syntax ancestors), which is also the
test `ModuleEmit.cpp` already uses for `genScopeProcInLoop`.

**Why the pass's gates could not see it.** Its grid `g27_b_shapes.sv` asks ten
homes and none of them is a generate block; the census could not see it
because the surelog corpus has **zero** `$bits(<select> op x)` cells inside a
generate block (`KEEP_G_FOLD_O` stayed 15 → 15); and the wide boundary over
all 3291 committed probe sources could not see it because **no committed arm
writes that shape in a generate block** either. It is a corpus-invisible,
boundary-invisible regression on legal SV — exactly the class the wide
boundary exists to catch, and the class that only a new arm can convict.

**The fence is the narrowest possible one**: it suppresses the § 27
substitution only, so inside a generate block the emitter behaves EXACTLY as
pristine (a binary/ternary `$bits` argument always set `bitsKeep`). It cannot
move a cell pristine got right, and it does not touch the pre-existing
single-argument over-fold in the same home (residue **R-GENFOLD** below).

## 3. ARMS — four-way (golden / pristine / patched / fixed), BOTH VIEWS

`vscore27.sh` + `vfour27.py`: a VIEW-GENERAL multiset join on the SPAN (the
DEF/ELAB view is kept OUT of the key; payload = the JUDGED shape, i.e. object
KIND — a surviving type-query CALL vs a folded 64-bit UINT constant — and its
NAME/DECOMPILE). Never a last-writer dict.

| arm | cells | patched BROKE | **fixed BROKE** | FIXED (both) |
|---|---|---|---|---|
| `v27_a_homes` (14 homes: class in-block / OOB / static / task / package fn+task / interface / program / module fn+task+initial+always / cont_assign / localparam / parameter / **generate**) def, elab | 43 / 43 | **1**, **1** | **0**, **0** | 18, 18 |
| `v27_b_types` (18 leftmost-operand types) def, elab | 48, 48 | 0, 0 | 0, 0 | 16, 16 |
| `v27_c_shapes` (29 written shapes: paren / cast / unary / nested / concat / replication / ternary / call / this. / handle / member / macro formal) def, elab | 41, 42 | 0, 0 | 0, 0 | 11, 11 |
| `v27_d_pos` (17 positions: constraint / case expr+item / call arg positional+named / index / concat / ternary / if / while / for / repeat / sys arg / param actual / part-select bound / default arg) def, elab | 48, 48 | 0, 0 | 0, 0 | 17, 17 |
| `v27_e_inst` (1..3 instances of a parameterised module) def, elab | 12, 12 | 0, 0 | 0, 0 | 0, 0 |
| **`v27_f_gen`** (every generate form × every carrier, module + interface) def, elab | 46, 46 | **17**, **17** | **0**, **0** | 8, 8 |
| `v27_g1_gen` def, elab | 23, 23 | **5**, **5** | **0**, **0** | 4, 4 |
| `v27_g2_gencarriers` def, elab | 17, 17 | **8**, **8** | **0**, **0** | 2, 2 |
| `v27_g3_ifgen` (interface gen scope + child module in a gen block) def, elab | 23, 23 | 0, 0 | 0, 0 | 8, 8 |
| `v27_g4_genforms` def, elab | 18, 18 | **6**, **6** | **0**, **0** | 2, 2 |
| `v27_h_types2` (packed-struct array / mixed packed-unpacked / enum array / wildcard assoc / bounded queue / 3-D unpacked / static prop) def, elab | 33, 33 | 0, 0 | 0, 0 | 12, 12 |
| **TOTAL** | | **74** | **0** | |

The implementer's own arms are unchanged by the fence: `g27_a0_head` 1 FIXED,
`g27_a_leftmost` 6 FIXED / 3 STILL, `g27_b_shapes` 40 FIXED / 10 STILL,
`r10v95repro/v95_b6_exprargs` 7 FIXED / 10 STILL — identical counts for the
patched and the fixed binary, BROKE 0 in both, both views.

**VALUES CHECKED AGAINST GOLDEN, not against each other**: 4, 3, 130, 24, 8,
8, 8, 8, 24, 16, 6, 96, 64, 48, 24 (`v27_b_types`) and 36, 64, 15, 1, 192, 16,
32 (`v27_h_types2`) — every one is golden's, including `real ra[2]` → 64 and
`logic [64:0] w65[2]` → 130, which no expression-width rule produces.

## 4. GATES FOR THE FIXED BINARY — ALL GREEN

1. build `-j 2`, md5 separately, frozen `chmod 555` before any sweep; every
   `cmds.txt` audited by binary PATH.
2. goldens **23 PASS / 0 FAIL**; `/bin/false` **0 / 23**.
3. u2r `testflags` and `default`: **679 / 50 / 2**; `ct8rows` vs the committed
   baseline, vs pristine and vs the implementer's patched CSV — **0 differing
   ROWS** each.
4. surelog `--mode both`: **471 + 466 CMP_EQUAL, 10 + 9 CMP_NOTEQUAL**;
   `ct8rows` vs `results/golden_surelog.csv`, vs pristine and vs patched —
   **0 differing ROWS over 1588**. **No row converted, no baseline edited.**
5. byteverify `SELFCHECK=1`: surelog **2 / 956** vs pristine (both PREDICTED
   BY NAME) and **0 / 956 vs the implementer's patched binary**; u2r **0 /
   1358** vs both. Selfcheck negative control 955/956 and 1357/1358.
6. rowheads: `BuildUVMPkg` **32 / 32**, 1 head, modes byte-identical, cmp md5
   `c8959ae94a5c768e14dc450e000e3426`; every other row unchanged.
7. canaries / ctcan2 / canaudit / pins — all PASS, pins SAME=10 MOVED=0.
8. wide boundary `vbound27.sh` from a COPY of `tools/probe`, **no path
   filter, `.sv` AND `.v`, recursive, fd-3 list, children `</dev/null`,
   PROCESSED asserted, rc per cell**, DEF and ELAB:
   `LISTED=3302 FENCED_SKIPPED=0 PROCESSED=3302 MOVED=30 PROCESSED-ASSERT-OK`,
   0 `ASYMMETRIC_OUTPUT`. All 30 movers are arms of this pass (8 in
   `r10buvm27repro`, 20 in `r10vbuvm27repro`) plus the 2 cells of the uvm95
   verifier's `r10v95repro/v95_b6_exprargs.sv`; every one is scored against a
   rebuilt golden in `ARMS.r10vbuvm27.txt` with **BROKE 0**. The same gate on
   the implementer's binary reads `LISTED=3291 PROCESSED=3291 MOVED=10`.

## 5. R0 AND RESIDUES

**R0 — confirmed, and its site read from the source.** The new 32-line
`BuildUVMPkg` head is `pp_output/uvm_pkg.sv:58248`
`__array = new [$bits(m_command)] (__array);` inside
`uvm_tlm_generic_payload::do_unpack`, `m_command` a `uvm_tlm_command_e`.
Golden mints `constant UINT:0` in the `method_func_call (new)` size slot; we
fold the enum's 32. A pure VALUE head. (The implementer's write-up says
"`$bits(<enum member>)`" — it is an enum-typed VARIABLE; the `new[]` size slot
is the point either way.)

Ranked residues this verification measured:

1. **R-GENFOLD (new, and it is the same family as uvm95's R3)** — golden keeps
   `$bits(<anything>)` inside a generate block; we still over-fold the
   SINGLE-argument form there (`$bits(mpk4[gv])` → 32 where golden keeps),
   pristine did too. Corpus population **0** on both corpora. Modelling it
   properly (a gen-scope `Reduce::No` context, alongside §
   `bitsOutOfBlockNoReduce95`) would retire this fence AND uvm95's R3 in one
   law; that is the right next `$bits` move after R0. Arm cells: 5 in
   `v27_g1_gen`, 2 in `v27_g3_ifgen`, 2 in `v27_f_gen`.
2. **R-BOUNDEDQ (new)** — `byte q[$:3]`: golden's root width is **32** (the
   bound counts), `srlgBitsRootWidth95` counts an unsized dimension as ONE and
   answers 8. PRE-EXISTING (the single-argument twin is already wrong on the
   pristine binary), and the substitution routes the binary form into the same
   answer. Corpus population 0. One line in `srlgBitsRootWidth95`
   (`QueueType::maxBound`) — the cheapest correction in the family.
3. **R-DEFAULTARG (new)** — a `$bits(<select> op x)` written as a subroutine
   FORMAL'S DEFAULT VALUE keeps on our side where golden folds
   (`v27_d_pos.sv:9`, both views). PRE-EXISTING, unchanged by the patch;
   § `formalDefaultBindsLikeBody13` owns the neighbouring bind question.
4. **R-TDDIM (new)** — `typedef logic [$bits(mpk[1] & 8'h0F)-1:0] t;` at module
   level: golden 32 in both copies, we emit a kept CALL in one copy and
   `CONST 8` in the other. PRE-EXISTING (the substitution never reaches it —
   the dimension is emitted by `TypeEmit`, not this site) and unchanged.
5. The implementer's own R-DOTTED / R-CONCATOVER / R-CONSTPARENT / R-BITSSPAN
   and § `bitsOutOfBlockNoReduce95` are all confirmed as stated and all
   byte-unchanged by the patch.

## 6. REPRODUCE

```sh
g++ -O2 -std=c++17 ../r10buvm27repro/ct27cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/vbuvm27_ct27cen
CEN=/tmp/vbuvm27_ct27cen PRI=<pris> PAT=<patched> FIX=<fixed> MODE=def \
    ./vscore27.sh v27_f_gen.sv          # ALREADY-OK / FIXED / BROKE / STILL, four ways
PRI=<pris> PAT=<fixed> ROOT=<a COPY of tools/probe> JOBS=8 ./vbound27.sh
```
