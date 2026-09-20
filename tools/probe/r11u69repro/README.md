# r11u69 — ROAD E / R2: the elaborated share decision runs for `cont_assign`s
# inside GENERATE BLOCKS

Base commit `c69f6ec7`. Pristine binary md5 `6c5ffa96f18afef53d6f390fd9daefab`
(byte-identical to the main tree's `build/slang-uhdm` at that commit; built in
this pass's own worktree and md5-compared, not assumed). Patched binary md5
`907291f20f19eb59fe4497ecf5821e4a`.

---

## 1. THE BRIEF'S TWO NAMED CORPUS SITES ARE BOTH REFUTED — SAY IT LOUDLY

The brief named `struct_param_field_shift` and "`cva6_equiv`" as the corpus
sites. Re-measured at `c69f6ec7` with this pass's own pristine sweep (both
modes, `/tmp/r11u69_pris.bin` audited in every `cmds.txt`):

```
struct_param_field_shift,testflags,CMP_EQUAL,,,differ
struct_param_field_shift,default,CMP_EQUAL,,,differ
cva6_struct_param_field,testflags,CMP_NOTEQUAL,decompile:,,
cva6_struct_param_field,default,CMP_NOTEQUAL,decompile:,,
```

(there is no row named `cva6_equiv` in either corpus; the only `cva6_*` row is
`cva6_struct_param_field`, and both its rows are quoted above.)

**`struct_param_field_shift` is not a site for this law.** Its two generate-scope
`cont_assign`s ALREADY AGREE object for object — golden and we both keep the
concatenation:

```
work@struct_param_field_shift.gen_blk[0]  ca@33:12  LHS=bit_select(...acc)  RHS=operation()@33:21 vpiOpType=33   (golden)
work@struct_param_field_shift.gen_blk[0]  ca@33:12  LHS=bit_select(...acc)  RHS=operation()@33:21 vpiOpType=33   (ours)
```

It is fenced three times over: the parameter is FUNCTION-BUILT
(`build_config(64)`, § caStructParamPatternSubst55's declared fence), the Rhs is
a concatenation rather than a field read, and the Lhs is an array element. Its
`differ` dump column is some other family's.

**`cva6_struct_param_field` is not a site either.** Its head is not a
`cont_assign` at all and not in a generate block — it is the `range` of a
localparam TYPE's struct member width:

```
LHS:  constant: , id:464 |vpiDecompile:63 |vpiSize:64 |INT:63 |vpiConstType:7
RHS:  operation: , id:280, line:26:12  |vpiParent: \_range: , id:279, line:26:11
      |vpiOpType:11  |vpiOperand: \_hier_path: (Cfg.XLEN), id:281
```

`dut.sv:26` is `logic [Cfg.XLEN-1:0] x;` inside `localparam type it_t = struct
packed {…}`. That is road C / typespec ground, not road E.

**PREDICTION, made before the patched sweep and stated as such: no corpus row
CONVERTS and no corpus row ADVANCES from this law.** §5 below is the census that
says why, with its positive control; §6 is the patched sweep that confirms it
byte for byte.

---

## 2. The producer fact, confirmed against the pinned sources

Surelog v1.87 (`0445655ee7`).

`UhdmWriter::writeCont_assign` (`src/DesignCompile/UhdmWriter.cpp:2090`) walks
`netlist->cont_assigns()` — the ELABORATED INSTANCE's list. A generate block's
assignments are on that same list; nothing in the function knows what a
`gen_scope` is. At `:2245`:

```cpp
      if (simplified == false) {
        bool invalidValue = false;
        …
        any* res = m_helper.reduceExpr((expr*)rhs, invalidValue, mod, …, assign, true);
        if (invalidValue == false) {
          if (res && (res->UhdmType() == uhdmconstant)) {
            if (cloned == false) {
              ElaboratorContext elaboratorContext(&s, false, true);
              assign = (cont_assign*)UHDM::clone_tree(assign, &elaboratorContext);
              assign->VpiParent(m);
              lhs = assign->Lhs();
              cloned = true;
              res = m_helper.adjustSize(tps, mod, m_compileDesign,
                                        netlist->getParent(), (constant*)res, true);
              res->VpiParent(assign);
            }
            assign->Rhs((constant*)res);
```

The ONE thing it reads about the target is `tps`, filled at `:2099` from
`lhs->Typespec()->Actual_typespec()` — see §4.

CLONE, NEVER SHARE, per elaborated instance: `clone_tree` at `:2247` and
`adjustSize`'s own uniquify. Arm `g9_child` measures it directly — two
instances of one leaf with different overrides get **different** substituted
values, `u_a` -> `UINT:3`@`7:29`, `u_b` -> `UINT:8`@`8:29`.

The definition listing is untouched: `compileContinuousAssignment` compiles the
Rhs with a hard `Reduce::No` (`CompileHelper.cpp:2500`), and our def view
already agrees (§3's def-view control).

---

## 3. The golden grid

Runner `run69.sh <binary> <tag>`; scorer `cell69.sh <arm> <tag> [elab|def]`;
shape lister `shapes69.py <dump> [elab|def]`. **Every arm compiles rc=0 on BOTH
sides in BOTH tags** (`golden_rc=0 ours_rc=0`), so no arm is teaching
error-recovery instead of golden.

### 3a. The SHAPE LISTER, and the trap it exists to avoid

`shapes69.py` lists every elaborated `cont_assign` with its owning scope, its
Lhs and its Rhs kind + the fields the judge reads. It also resolves
**`uhdm-dump`'s repeat elision**: an object the dump has already printed is
printed again as a bare stub with no children, and a reader that takes that at
face value sees a field-less object where the database holds a full one. Every
`!=shared-repeat` row below is such a stub, resolved against the first full
print of an object with the same kind and location (approximate — the resolved
SIZE can be the first print's, which is why §4's size column is read off the
FULL prints only).

### 3b. `g1_genkind` — the generate KIND is not a discriminator

One Rhs (`CFG.n`, reaching its pattern through a package localparam = the W1
chain), one Lhs kind, six homes. Pristine:

| home | golden | ours (pristine) | ours (patched) |
|---|---|---|---|
| module level (CONTROL) | `constant` `UINT:3`/32 @`8:31` | identical | identical |
| gen-for | `constant` `UINT:3`/32 @`8:31` | `hier_path (CFG.n)` | identical |
| named gen-if TRUE arm | same | `hier_path` | identical |
| gen-if ELSE arm | same | `hier_path` | identical |
| gen-case | same | `hier_path` | identical |
| UNNAMED gen-if (`genblk5`) | same | `hier_path` | identical |

`cmp_rc 255, heads 1, cmplines 26` -> `cmp_rc 0, heads 0, cmplines 0`. **CONVERTS.**

### 3c. `g5_nest` — nesting is not a discriminator

gen-if in gen-for, gen-for in gen-for, gen-if in gen-if, and a three-level
`if/for/if` nest. Golden substitutes in all four; we did in none. Patched: the
three whole-name-Lhs cells identical, the two array-element-Lhs cells declined
(§4). `cmp_rc 255 -> 0`. **CONVERTS.**

### 3d. `g2_iter` — iterations get per-iteration clones and per-iteration values

A three-iteration gen-for: golden substitutes in EVERY iteration. In the arm
whose member pick depends on the genvar, each iteration gets its OWN value —
`ggv[0]` -> `CFG.n`@`7:31`, `ggv[1]`/`ggv[2]` -> `CFG.m`@`7:37`. Every cell in
this arm has an array-element Lhs, so the law declines all six; the arm is
judge-EQUAL on BOTH binaries (`cmp_rc 0` pristine and patched) and is the
control that the decline does not move it.

### 3e. `g3_rhskind` — the Rhs kinds, in one generate block

| Rhs | golden | ours pristine | ours patched |
|---|---|---|---|
| `CFG.n` 1-level field read | `constant UINT:3`/32 @`7:33` | `hier_path` | **identical** |
| `OC.sub.n` 2-level (W2) | `constant UINT:11`/32 @`8:41` | `hier_path` | **identical** |
| `CFG.h` sized HEX member | `constant HEX:BEEF`/16 @`7:39` (shared) | `hier_path` | `HEX:BEEF`/16 @`7:39` |
| `CFG.n + 1` operation | `constant UINT:4`/32, NO location | `operation` op 24 | unchanged (R1) |
| `{16'h0, CFG.n[15:0]}` concat | `constant BIN:…11`/32, NO location | `operation` op 33 | unchanged (R1) |
| `p::AP[0]` array-param element | agree | agree | agree |
| `CFG.n + a_i` (CONTROL) | `operation` | agree | agree |
| `a_i` (CONTROL) | shared | agree | agree |

The operation and concat cells fold in golden to a **location-less** constant —
a different mint from this law's (which stamps the value's own source), so they
are RECORDED AS R1 and left alone rather than approximated.

### 3f. `g7_enc` — pass 56's encoding table and pass 63's fill width compose

Eight member encodings, each written ONCE at module level (the control) and
ONCE in a generate block. **All eight module-level controls are already EQUAL on
the pristine binary**, and after this pass all eight generate twins carry the
same object: `UINT:300`/32, `HEX:BEEF`/16 spelling untouched, `BIN:10100101`/8,
`DEC:4660`/16 (the `'d` ABSTENTION), `INT:-5` (the `vpiMinusOp` arm), `UINT:4`
for `K + 1` with the value already reduced, `'1` on an 8-bit member as
`UINT:255`/8 and `'0` as `UINT:0`/32. Nothing in this pass re-derived any of
that — it is `emitCaStructParamSubst55`, the module-level law's own body.

The arm's remaining head is NOT a `cont_assign`: it is the `param_assign`'s
`vpiAssignmentPatternOp` operand for `neg: -5` (golden `INT:-5`/64, ours an
`operation`), which is the SISTER PASS's ParamEmit op75 ground. The head is
byte-identical pristine and patched.

### 3g. `g9_child` — per-instance, through an override

Two instances of one leaf. Golden substitutes each instance's OWN override
value inside the generate block; the module-level twins were already equal on
both binaries. `cmp_rc 255 -> 0`. **CONVERTS.**

### 3h. `g4_lhskind` — the Lhs kinds, and `adjustSize` read off golden

Rhs held at exactly `CFG.n` (member value 300), seven Lhs inside one gen block:

| Lhs | golden | patched |
|---|---|---|
| `logic [31:0]` | `UINT:300` size **32** | identical |
| `logic [7:0]` | `UINT:44` size **8** (value MASKED) | identical |
| `logic [63:0]` | `UINT:300` size **64** | identical |
| `logic signed [31:0]` | `UINT:300` size 32 | identical |
| bit-select | the SHARED source object | declined (§4) |
| part-select | the SHARED source object | declined (§4) |
| array element | the SHARED source object | declined (§4) |

`cmp_rc 255 -> 0`. **CONVERTS.** The three whole-name widths are three DISTINCT
objects in golden — that is `adjustSize`'s UINT uniquify-clone, and it is
§ caStructParamPatternSubst55 (W3) doing the work unchanged.

### 3i. `g10_lhsbind` — where golden CLONES and where it SHARES

| Lhs target | golden |
|---|---|
| a module PORT (g1, every generate kind) | CLONES, at the Lhs width |
| a gen-local with a MODULE-BODY NAMESAKE (`gname.nm`) | **CLONES**, `UINT:3`/32 |
| the block's OWN local (`gown.lv`) | SHARES the source object |
| an ANCESTOR gen scope's local (`ganci.av`) | SHARES |
| a gen-local NET (`gnet.wv`) | SHARES |

This is §4's gate, measured. The arm's head (`LHS: <null>` vs our
`logic_var gown.lv`) is a PRE-EXISTING gen-local binding face, byte-identical
pristine and patched.

### 3j. `g8_fence` / `g12_fencetwin` — the fences, and the module-level parity check

`g12` writes every fenced shape TWICE, once at module level and once in a
generate block, so "does the module-level law already serve this?" is answered
per row instead of assumed:

| row | module level (pristine) | generate block |
|---|---|---|
| `LP.n`, the landed law's shape | EQUAL | pristine DIFF -> **patched EQUAL** |
| `FB.n`, FUNCTION-BUILT param | EQUAL (§ caAsmMemberSliceFold serves it) | golden folds; we DECLINE — **R2** |
| `vcfg.n`, a struct VARIABLE's field | DIFF (we share the def CA) | DIFF, unchanged — **R3** |
| `LP.n` onto a bit-select Lhs | DIFF, unchanged | DIFF, unchanged (§4) |
| `LP.n` onto an array-element Lhs | DIFF, unchanged | DIFF, unchanged (§4) |

`g8` adds the EXPLICIT-CAST fence (`leaf #(.C(p::cfg_t'(p::OTHER)))`, the r11v55
cast fence): golden declines and so do we, in the generate block as at module
level — `work@dut.u_c.gl` is SAME on both binaries. `g8`'s head is the
function-built `param_assign`'s operation, byte-identical pristine and patched.

### 3k. `g11_iface` — the interface fence, MEASURED

The same read inside an INTERFACE's generate scope: golden SHARES the source
object there, although `i_gen` is declared in the interface body and in no
generate block. `CompileHelper::bindVariable`
(`~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp:3095-3155`) switches on
`uhdmfunction`, `uhdmtask`, `uhdmbegin` and `uhdmmodule_inst` **and nothing
else** — an `interface_inst` falls to `default` and the recursion goes to the
ENCLOSING MODULE, where the name is not found. The interface half is therefore
declined and filed as R4; the arm's head is byte-identical pristine and patched.

### 3l. THE DEF-VIEW CONTROL

`emitGenScopes` runs only from the instance view ("Generate scopes exist only in
the instance view", `src/ModuleEmit.cpp` ~13217, plus the interface caller
~36509), so the def view cannot be reached by construction — and it is SCORED,
not asserted. On every one of the eleven arms the whole `uhdmallModules` section
of our own database is **byte-identical** pristine vs patched (md5 per arm), and
the def-view `cell69.sh … def` listing is 0 differing lines. Two def-view
residues exist on `g1` (gen-case block naming) and `g3` (`p::AP[0]` written as a
`ref_obj` where golden writes a `bit_select`); both are pre-existing, neither
moves.

---

## 4. THE LAW, GATED

`§ caStructParamGenScopeSubst69` (`src/ModuleEmit.cpp`, the gen-scope
`cont_assign` Rhs site inside `emitGenScopes`).

> The elaborated `cont_assign` Rhs substitution of
> § caStructParamPatternSubst55 runs for a `cont_assign` written inside a
> GENERATE BLOCK exactly as it does at module level, because the producer runs
> ONE reducer over `netlist->cont_assigns()` and that list is the elaborated
> instance's, generate blocks included.

This pass **adds nothing to the decision or the emission**. Both were lifted out
of the module-level emitter into
`caStructParamSetter55(rhsExpr, plainLhs, memberTy, pureDef)` and
`UhdmExporter::emitCaStructParamSubst55(setter, memberTy, pureDef, lhsExpr, ca,
prefix, netMap)`, and the module-level site now CALLS them, so the two homes
cannot drift and the module-level bytes are provably unchanged (§6's mover
census). W1 (the initializer chain), W2 (nested reads), W3 (`adjustSize`
against the Lhs declaration), the cast fence, the value-source location and
§ caSubstLeafEncReduceTable56's encoding table all ride along unmodified.

THE GATES, each with its measured cell:

1. **ELAB VIEW ONLY** — structural: `emitGenScopes` has no def-view caller
   (§3l).
2. **MODULE gen scopes only** — an `interface_inst` home is declined, because
   `bindVariable` has no `uhdminterface_inst` case (§3k, arm `g11_iface`).
3. **WHOLE-NAME Lhs only** (`ExpressionKind::NamedValue`) — the landed Lhs
   fence of § caStructParamPatternSubst55, kept: no site in either corpus
   writes a struct-param dotted read onto a select Lhs.
4. **`!genCaLhsGenLocal113`** — and this is the producer's own test, not a new
   one. `writeCont_assign` fills `tps` from `lhs->Typespec()` at `:2099` and
   `CompileHelper::adjustSize` (`CompileHelper.cpp:4065`) returns AT ONCE when
   `ts == nullptr`, so with no typespec golden's Rhs is the SOURCE OBJECT
   ITSELF — shared with the elaborated `param_assign`'s operand — and with one
   it is a per-assign uniquify clone at the Lhs width. Which targets carry a
   typespec is `bindVariable`'s reach, which
   § genScopeCaPatNoFirstSize113 already decoded and already computes here,
   namesake walk included. Arm `g10_lhsbind` measures all five cells (§3i), and
   the three SHARE cells are DECLINED rather than approximated: we do not model
   sharing the `param_assign` operand, and minting a fresh constant there would
   be a different object from golden's.
5. `R11U69_OFF=1` restores the pristine behaviour in the shipped binary;
   `R11U69_CELLDBG=1` names EVERY generate-scope `cont_assign` that reaches the
   site with the predicate's answer AND the gate's — not only the shape the law
   intends to change.

---

## 5. THE CENSUS, BOTH CORPORA, BOTH MODES, WITH A POSITIVE CONTROL

`census69.sh <workdir/mode-dir> <out.tsv>` dumps golden and ours for every test
in a sweep workdir and lists every `cont_assign` whose owning scope is a
`gen_scope` (the SHAPE LISTER beside it). `cenjoin69.py` joins them on
(test, owner, ca-location, Lhs) and names the cells where golden's Rhs is a
CONSTANT and ours is not — this law's candidate sites — and the reverse.

A dump that outruns its budget writes a `TIMEOUT-G` / `TIMEOUT-O` ROW; it is
never silently dropped, so a census zero cannot hide one.

**POSITIVE CONTROL.** The `g1_genkind` arm's own two databases were planted in a
workdir-shaped directory and censused with the same script: it reports
`GOLDEN-FOLDS-WE-DO-NOT: 5 cells, 1 tests` and names all five generate kinds.
The instrument can see the shape it is looking for.

### 5a. GOLDEN-vs-GOLDEN FIRST (the calibration)

`census69.sh <dir> <out> golden` reads the golden database on BOTH sides.
Over 45 uhdm2rtlil tests picked for having generate blocks (the `ibex_*`,
`gen*`, `struct_param*`, `stamped_gen_param`, `arb_idx_cast`,
`LocalParamInNestedForLoops`, `SumOfParametersInNestedForLoops` families),
**2703 cells, 0 differing** — whole row, fields included. The instrument reads
no noise.

### 5b. SHAPE CENSUS — uhdm2rtlil, BOTH MODES

804 golden/ours database pairs per mode (the 67 `SLANG_REJECT` rows have no
database of ours to read). 77 tests carry a generate-scope `cont_assign` at all;
2817 golden cells against 2815 of ours.

```
GOLDEN-FOLDS-WE-DO-NOT: 0 cells, 0 tests      (default)
GOLDEN-FOLDS-WE-DO-NOT: 0 cells, 0 tests      (testflags)
WE-FOLD-GOLDEN-DOES-NOT: 0 cells, 0 tests     (both modes)
```

The whole-row join (fields included) finds 17 differing cells in 6 tests in each
mode, and **not one of them is a struct-parameter field read**:
`LocalParamInNestedForLoops` / `SumOfParametersInNestedForLoops` (we share an
object golden mints fresh, on a localparam fold), `ibex_pmp` / `ibex_wb_stage`
(COLUMN-only location differences, which no generated `Compare` reads),
`stamped_gen_param` / `arb_idx_cast` (per-iteration pairing, `<none>` on one
side of each pair).

### 5c. SITE CENSUS — BOTH CORPORA, BOTH MODES, EVERY CELL THAT REACHES THE SITE

`cellcen69.py` replays the harness's OWN discovery and its OWN slang argument
vector with `R11U69_CELLDBG=1`, so every generate-scope `cont_assign` that
reaches the law's site is named with the predicate's answer AND each gate's.
It refuses to dispatch the four slang-fenced names, reading them out of
`tools/probe/r10sd4repro/canaudit.sh`'s own `FENCED=` line rather than
respelling them. Every invocation's rc is recorded.

| gate profile | uhdm2rtlil | surelog |
|---|---|---|
| `plainLhs=1 genLocal=0 iface=0` **sps=1** (the law FIRES) | **0** | **0** |
| `plainLhs=1 genLocal=0 iface=0 sps=0` (gates pass, PREDICATE declines) | 234 | 7572 |
| `plainLhs=1 genLocal=1` (the `bindVariable` gate declines) | 3658 | 5000 |
| `plainLhs=0` (select Lhs; the landed Lhs fence declines) | 1686 | 15560 |
| `iface=1` (the interface fence declines) | 10 | 4 |
| **total cells reaching the site** | **5588** | **28136** |

**THE LAW FIRES ON ZERO CORPUS CELLS IN EITHER CORPUS.** The 234 + 7572 cells
that clear every gate are declined by the PREDICATE — they are not
constant-valued reads of a struct parameter's field — so no gate is hiding a
corpus site; the corpora simply do not write this shape inside a generate
block. 4551 surelog cell rows carry `rc=-11`: those tests' compiles SEGFAULT,
which the harness itself records as `SLANG_REJECT`, and the census names them
rather than dropping them.

**POSITIVE CONTROL for the site census**, run against the grid's own arms with
the shipped binary:

```
g1_genkind   5 cells, all  plainLhs=1 genLocal=0 iface=0 sps=1     (the law fires 5/5)
g10_lhsbind  gown/ganci/gnet  genLocal=1 sps=0 ; gname  genLocal=0 sps=1
g11_iface    work@dut.u_i.gi  iface=1 sps=0
```

The instrument sees the shape it is looking for, and it sees each gate answer
the way §3i and §3k measured golden.

---

## 6. THE GATES

All five gates green. Both sweeps run from this pass's own worktree, with
`SLANG_UHDM` exported explicitly and **every** `cmds.txt` audited by BINARY PATH
(`/tmp/r11u69_pris.bin`, `/tmp/r11u69_pat.bin`), into this pass's own workdirs;
no shared `/tmp/ctl_wd_*` control was read.

**(1) BUILD.** Pristine built in this worktree: md5
`6c5ffa96f18afef53d6f390fd9daefab` — byte-identical to the main tree's
`build/slang-uhdm` at `c69f6ec7`. Patched: `907291f20f19eb59fe4497ecf5821e4a`.
Both `-j 2`, md5 taken separately, both frozen `chmod 555` before any sweep.

**(2) GOLDENS.** `23 PASS / 0 FAIL`; negative control `SLANG_UHDM=/bin/false`
gives `0 PASS / 23 FAIL`.

**(3) uhdm2rtlil, BOTH MODES.** `787 CMP_EQUAL / 17 CMP_NOTEQUAL / 67
SLANG_REJECT` in each mode, unchanged. Whole-row join (status AND dump column)
against `results/gate_uhdm2rtlil.csv` (testflags) and against the committed
`results/golden_uhdm2rtlil.csv`'s default rows: **PASS — every row
byte-identical to the committed baseline**, in both modes. No row moved, so
none is quoted.

**(4) surelog, `--mode both`.** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default and
`469 CMP_EQUAL / 8 CMP_NOTEQUAL` testflags — the committed baseline exactly, and
the per-mode STATUS histograms are identical row for row. Three rows differ in
the whole-row join and all three are named:

```
Earlgrey_0_1,default,CMP_EQUAL,,,differ   ->  Earlgrey_0_1,default,CMP_EQUAL,,,
LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] … "/tmp/<workdir>/…/surelog.log".
LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] … "/tmp/<workdir>/…/surelog.log".
```

The two `LowMem*` rows carry the WORKDIR PATH inside the `SURELOG_FAIL` detail —
they differ against any baseline swept elsewhere, and they differ between this
pass's own pristine and patched runs for the same reason. `Earlgrey_0_1`'s DUMP
COLUMN reads blank on a `uhdm-dump` timeout draw; per the ops rule the
DATABASE byte-compare is the pin, and it holds:

```
Earlgrey_0_1 default    pat=8bdf25272e08  pris=8bdf25272e08  SAME   (the pin)
Earlgrey_0_1 testflags  pat=59d0ee6d10c3  pris=59d0ee6d10c3  SAME   (the pin)
```

Its STATUS is `CMP_EQUAL` in both modes on both binaries.

**(5) BYTEVERIFY, `SELFCHECK=1`, against this pass's own pristine workdirs.**

```
uhdm2rtlil:  PATH_SETS_IDENTICAL (1608 paths)   MOVERS: 0 / 1608
             SELFCHECK 1607 / 1608 flagged
surelog:     PATH_SETS_IDENTICAL (960 paths)    MOVERS: 5 / 960
             SELFCHECK  959 /  960 flagged
```

uhdm2rtlil is **0 movers, exactly as predicted by name before the patched
sweep** (§5: the law fires on zero cells).

The five surelog movers are named and attributed:

```
default/MiniAmiq   default/SeqDriver   default/SimpleUVM
testflags/MiniAmiq testflags/SeqDriver
```

Every one of them is the UVM family the ops brief names pristine-
nondeterministic, and every one lands in the documented class: the
path-normalised, SORTED (order-blind) dumps differ by **exactly 4 lines**, one
`UINT:` + one `vpiDecompile:` pair, a macro-buffer line number:

```
MiniAmiq/default    UINT:800  vs UINT:998         SeqDriver/default  UINT:749 vs UINT:1002
SimpleUVM/default   UINT:564  vs UINT:0           MiniAmiq/testflags UINT:1531 vs UINT:634
SeqDriver/testflags UINT:1522 vs UINT:875
```

**THE POSITIVE CONTROL that convicts nondeterminism and not this law:** the
PRISTINE binary alone, run four times on `MiniAmiq`/default, produces FOUR
DIFFERENT databases —

```
run0 7a4d27158da0   run1 d11f753b148c   run2 2e1605738980   run3 4e6e3934987d
```

— none of which equals either sweep's hash. Their ROWS are unchanged
(`CMP_EQUAL` both modes) and `rowheads.sh` reads `0 cmplines / 0 heads` for
`SeqDriver`, `SimpleUVM`, `Scoreboard`, `MiniAmiq`, `BuildUVMPkg` and
`Earlgrey_0_1` in every mode measured (`SKIP-NOFILE` on `Scoreboard`/testflags
and `Rggen`/testflags is expected; `Rggen`/default stays at its baseline
64 cmplines / 1 head).

**A SECOND ATTRIBUTION CONTROL, in the shipped binary.** With `R11U69_OFF=1`
the patched binary reproduces the PRISTINE database **byte for byte on all
eleven grid arms** (`identical=11 differing=0`), so 100 % of the patched delta
is this law and the module-level extraction introduced no drift.

**CANARIES.**

```
canaries.sh  u2r/testflags   ok=8  changed=0  absent=0
canaries.sh  surelog         ok=50 changed=2  absent=0
   the two: Earlgrey_0_1 default + testflags, CMP_EQUAL/differ -> CMP_EQUAL/
            (the dump-column draw above; STATUS unchanged, both DB pins hold)
ctcan2.sh    u2r  EXPECT_UNKNOWN=6   PASS
ctcan2.sh    surelog EXPECT_UNKNOWN=1  ok=58 changed=0   PASS
canaudit.sh  (run from this directory, over canaries.sh + ctcan2.sh)
             audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
```

Protected databases by name, patched vs this pass's own pristine:

```
SVSwitch            4842211c4030  both modes   (the HARD pin, held)
YosysVerx           6ccda350c24a  both modes   (the HARD pin, held)
InterfaceModPort    59a365f3ce2c  both modes   (held)
BlackParrotComplex  e3e354129d5a / 73a10e8217e5  SAME
YosysOldOr          d68e0796d62c  both modes   SAME
```

**SCORE.** MOVED-WRONG **0**, AWAY-GOLDEN **0**, both mode columns scored on
both corpora. Grid: **four arms CONVERT** (`g1_genkind`, `g4_lhskind`,
`g5_nest`, `g9_child`: `cmp_rc 255 -> 0`, heads `1 -> 0`, cmplines
`26/26/26/26 -> 0`); `g2_iter` is judge-EQUAL on both binaries and stays so; the
six arms that keep a head (`g3`, `g7`, `g8`, `g10`, `g11`, `g12`) keep the SAME
head, byte for byte, pristine and patched — none of those heads is a
generate-scope `cont_assign`. Corpus: **0 rows CONVERT, 0 rows ADVANCE, 0 rows
REGRESS** — which is the prediction §1 made before the patched sweep, and §5 is
why.

---

## 7. RESIDUES

* **R1 — the operation and concat Rhs cells** (`g3_rhskind`). Golden folds
  `CFG.n + 1` and `{16'h0, CFG.n[15:0]}` inside a generate block to a
  **location-less** constant; this law stamps the value's own source location,
  so the object would be a different one. Measured, declined, unchanged on both
  binaries.
* **R2 — the FUNCTION-BUILT parameter in a generate block** (`g8_fence`,
  `g12_fencetwin`). Golden folds `FB.n` there, and the MODULE-LEVEL twin is
  already equal because § caAsmMemberSliceFold serves it. Extending THAT law to
  the generate listing is the same move this pass made for
  § caStructParamPatternSubst55 and is the obvious next cell; it is a different
  law's site and is not claimed here.
* **R3 — a struct VARIABLE's field** (`g12_fencetwin` row `t_var`). Golden folds
  `vcfg.n` to `UINT:64` at MODULE level too, where we share the def
  `cont_assign`. Pre-existing and untouched; the generate row is the same
  divergence one scope in.
* **R4 — the INTERFACE generate scope** (`g11_iface`). Golden shares the source
  object; modelling that needs the share-the-`param_assign`-operand machinery
  this pass declines, so the interface home is fenced out (§4 gate 2).
* **R5 — the select-Lhs cells** (`g2_iter`, `g4_lhskind`, `g5_nest`,
  `g12_fencetwin`). Golden's Rhs is the shared source object; declined by the
  landed Lhs fence. Every one of the arms that carries them is judge-EQUAL on
  the patched binary anyway, so the cells are dump-visible only.

**R0 — THE NEXT MOVE.** Road E's R2 is CLOSED for the module-generate-scope
half: the share decision now runs for `cont_assign`s inside generate blocks,
four grid arms convert, and the gate is the producer's own `tps` test. The
corpus does not read this shape in either corpus (§5), so the next road-E cell
worth a pass is **R2 above — § caAsmMemberSliceFold's function-built struct
parameter, extended to the same generate-scope listing** — which is the arm the
`struct_param_field_shift` family actually writes, followed by R1's
location-less operation/concat mint.
