# r11u71 — § caStructParamGenScopeShareCut71: the "share" half is not a share
# decision, and `bindVariable`'s NAME hit is the only thing `adjustSize` reads

Base commit `d2fe2435`. Pristine binary md5 `ed42e95baf0385529f25f139e2eb32d2`
— byte-identical to the main tree's `build/slang-uhdm` at `d2fe2435` and to the
OPS pin, built in this pass's own worktree and md5-compared, not assumed.
Patched binary md5 `8218fa497f10cd0ce05add9441e162ab`. Both `-j 2`, md5 taken
separately, both frozen `chmod 555` before any sweep.

---

## 0. THE BASE MOVED UNDER THIS PASS — SAY IT LOUDLY

While this pass ran, the main tree advanced from `d2fe2435` to `9637b9fd`
("v1.87 pass 69 — a typed pattern cast is a cast over one concat; 1 test
CONVERTS"), which is **not an ancestor of `d2fe2435`** and which rewrote
`results/gate_uhdm2rtlil.csv` (the row `typed_named_pattern,testflags`
`CMP_NOTEQUAL` -> `CMP_EQUAL`). Every baseline join below is therefore taken
against **`d2fe2435`'s OWN committed CSVs** (this pass's worktree copy), which
are the baselines the brief names and which read `787/17/67` for uhdm2rtlil in
both modes — the brief's own figure. Joined against the MAIN TREE's newer
working copy, `typed_named_pattern` reads as a one-row difference on BOTH this
pass's pristine and patched sweeps, i.e. it is pass 69's conversion and not
this law's. The patch is a `git diff` against `d2fe2435` and applies there; the
master should re-verify it on `9637b9fd`.

---

## 1. THE BRIEF'S "LAW A" IS REFUTED AS STATED — THE HEAD IS THE Lhs BINDING,
## NOT A MINTED VARIABLE

The brief said our emitter "mints a `logic_var` that golden DOES NOT CARRY" and
asked which declaration road mints it. Measured at `d2fe2435`, golden carries
that variable and carries it in the same list, at the same kind, for every
declaration kind (arm `n5_declkind`, read straight out of golden's
`uhdmtopModules` gen scope):

```
logic  [31:0] d_logic     -> vpiVariables  logic_var
bit    [31:0] d_bit       -> vpiVariables  bit_var
integer       d_int       -> vpiVariables  integer_var
logic  [31:0] d_undriven  -> vpiVariables  logic_var     (the undriven control)
reg    [31:0] d_reg       -> vpiNet        logic_net  vpiNetType 48
wire   [31:0] d_wire      -> vpiNet        logic_net  vpiNetType 1
```

What golden does NOT carry is the substituted `cont_assign`'s **Lhs `ref_obj`
`vpiActual`**. `w9_sharehead`'s head at the base is exactly that — `LHS:
<null>` against our `logic_var work@dut.g.lv` — while three lines above it in
the same golden dump the `logic_var (work@dut.g.lv)` sits in `vpiVariables`.

The producer reason is already decoded and already landed:
`UhdmWriter::writeCont_assign` CLONES the assign whenever the reduce yields a
constant (`UhdmWriter.cpp:2246`), and a cloned Lhs ref is not in
`mod->getLateBinding()`, so it is never late-bound
(§ genCaUnboundTernFold23's fact 3). Our § genCaConstRhsLhsNoBind25
(r10earl25) ALREADY models it — it drops the `vpiActual` on an OWN-SCOPE
gen-local variable target as soon as the emitted Rhs is a constant. It simply
never fired here, because the Rhs never became a constant.

**So LAW A needs no line of its own: it is LAW B's own consequence, and the
grid scores it.** Arm `n5_declkind` converts (`cmp_rc 255 -> 0`) with the
binding dropped on all five driven kinds and the undriven control untouched.

---

## 2. THE PRODUCER FACT, QUOTED FROM THE PINNED SOURCE

Surelog v1.87 (`0445655ee7`), `src/DesignCompile/UhdmWriter.cpp:2121-2176`:

```cpp
      const typespec* tps = nullptr;
      if (const ref_typespec* rt = lhs->Typespec()) tps = rt->Actual_typespec();
      …
      if (lhs->UhdmType() == uhdmref_obj) {
        UHDM::any* var =
            m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
        if (var) {
          if (rhs->UhdmType() == uhdmoperation) { … clone …
            ref_obj* ref = (ref_obj*)lhs;
            ref->Actual_group(var);                          // :2164
            cloned = true; }
          if (expr* exp = any_cast<expr*>(var)) {            // :2168
            if (const ref_typespec* rt = exp->Typespec()) {
              if (const typespec* temp = rt->Actual_typespec()) {
                tps = temp;                                  // :2172
```

`:2168-2172` sits **outside** the `rhs is operation` arm and **inside**
`if (var)`. For EVERY `cont_assign` whose Lhs ref NAME `bindVariable` finds,
`tps` becomes THAT FOUND DECLARATION's typespec — whatever the Rhs is, and
whatever the ref's own `vpiActual` points at. `CompileHelper::adjustSize`
(`CompileHelper.cpp:4065`) then returns AT ONCE on `ts == nullptr`.

**The pass-68 gate's premise is therefore refuted: there is no "share" branch
to decline.** The producer substitutes on every cell; the name hit decides only
whether the substituted constant is RE-SIZED. (Sharing the `param_assign`
operand object is real but INVISIBLE to the judge — no generated `Compare`
reads `VpiParent`, and the one object golden hands to two cells carries one
field set, which a per-cell clone with the same fields reproduces.)

`CompileHelper::bindVariable` (`CompileStmt.cpp:3095-3155`) switches on
`uhdmfunction`, `uhdmtask`, `uhdmbegin` and `uhdmmodule_inst` and NOTHING ELSE;
a `gen_scope` and an `interface_inst` fall to the `default` and recurse through
`scope->VpiParent()`; the design carries no `Variables()`, so the walk dies at
the compilation unit.

---

## 3. THE GOLDEN GRID

34 arms: this pass's four (`n1`,`n2`,`n3`,`n5`), all eleven of r11u69's and all
nineteen of r11v69's, re-measured from scratch at `d2fe2435`. **Every arm
compiles `golden_rc=0 ours_rc=0`**, so no arm is teaching error-recovery
instead of golden. Runner `vrun71.sh <binary> <tag>`; shape lister
`shapes71.py`; cell scorer `score71.py <grid>`.

### 3a. THE SHAPE LISTER, and the trap this pass had to fix in it

`shapes71.py` is r11v69's resolving lister with one correction. `uhdm-dump`
prints a REVISITED shared object as a bare header, so the r11v69 lister
resolved a stub against the first full print at the same `(kind, span)`. That
map is SECTION-BLIND, and the same span is printed with DIFFERENT fields in the
package listing and in the elaborated one (`w9`'s `300` is `vpiSize:64` under
`uhdmallPackages` and `32` under `uhdmtopModules`), so it read `AMBIG` on
exactly the cells this law moves. `shapes71.py` builds one resolve map PER
SECTION. Where a section still holds two distinct full prints at one span —
golden's SHARED source object AND an `adjustSize` uniquify clone, which is
`n3_ifacegrid` — the stub is marked `SHARED-AMBIG` and never guessed at: a
guess manufactures AWAY-GOLDEN phantoms, and a nearest-preceding guess was
tried and measured WRONG against the judge on that very arm.

* Calibration golden-vs-golden: **0 differing** on every arm.
* Positive control: a single `UINT:300` -> `UINT:301` flip, and separately a
  `vpiSize:32` -> `33` flip, inside one `cont_assign` Rhs are each caught.

### 3b. `w9_sharehead` / `w10_sharesize` — THE SHARE HALF, RE-MEASURED AT THE BASE

`w10`'s four cells, no namesake anywhere, read off golden's own dump (the full
print lives under `vpiParamAssign`, the cells hold stubs of the SAME object):

| member | Lhs | golden |
|---|---|---|
| `8'hA5` (8 bits) | 32 | `HEX:A5` `vpiSize:8` decompile `8'hA5` |
| `300` (32 bits) | 8 | `UINT:300` `vpiSize:32` — **one object shared with** |
| `300` (32 bits) | 64 | **the row above** |
| `64'd70000` (64 bits) | 32 | `DEC:70000` `vpiSize:64` decompile `64'd70000` |

The Lhs is never consulted in either direction, which is `adjustSize` returning
at once on a null `tps`. `w9`'s single cell is the same fact with the head
isolated. Both CONVERT.

### 3c. `v1_namesake` — THE NAMESAKE WIDTH, AND THE BRIEF'S SECOND INVERSION

The brief asked for the clone's size to come from "the SLANG-RESOLVED target
(`caLhsAdjustBind106(ae.left())`), never from the name-bind namesake". The
measurement says the OPPOSITE, and golden is the spec:

```
ga: gen-local `logic [31:0] nw`, module-body namesake `logic [7:0] nw`
    golden  UINT:44  vpiSize:8    Lhs vpiActual -> logic_var (work@dut.nw)
    base    UINT:300 vpiSize:32   Lhs vpiActual -> <null>
gb: gen-local `logic [7:0] ww`,  module-body namesake `logic [63:0] ww`
    golden  UINT:300 vpiSize:64
    base    UINT:300 vpiSize:32
```

The size is the NAMESAKE's, never the target's and never the member's. After
the fix all 18 of the arm's cells agree (`DIFFERING=0`); the arm keeps one head,
the pre-existing Lhs-binding residue of §7 R1.

### 3d. `n2_bindhomes` — WHICH SCOPE DOES THE WALK SEARCH?

One member (32 bits, value 300) onto targets whose name lives in a different
home each time. The substituted constant's SIZE is the answer.

| target's namesake home | `adjw` | golden |
|---|---|---|
| nowhere (`gown.lv`) | 0 | member width 32 |
| module body, 8 bits (`gmb.mb`) | 8 | 8 |
| a module PORT, 16 bits (`gpo.po`) | 16 | 16 |
| an ANCESTOR INSTANCE's body, 4 bits (`u_l.gi.anc`) | 4 | 4 |
| a module `localparam` (`glp.lpn`) | 0 | member width (not a Variable/Net) |
| a 1-bit module net (`gimp.imp`) | 1 | 1 |
| an ANCESTOR GEN scope's local (`ganc0.gin` -> `av`) | 0 | member width |
| a gen-local NET (`gnet.wv`) | 0 | member width |

`v2_ancnamesake` is the hierarchy-crossing cell on its own — `adjw=8` from the
PARENT instance's namesake — and it CONVERTS.

### 3e. `n1_sharewidths` — ENCODINGS x WIDTHS, ALL SIXTEEN CELLS EQUAL

Seven members (`8'hA5`, `16'd4660`, `16'b1010010111000011`, `300`, `64'd70000`,
`'1` on an 8-bit member, `12 + 1`) onto Lhs widths that contradict every one of
them, all gen-local with no namesake. `DIFFERING=0` over all 16 cells: pass 56's
encoding table, pass 63's fill width and pass 68's member stamp compose
correctly under the null-`tps` return. The arm's remaining head is NOT a
`cont_assign` — it is the `param_assign`'s `vpiAssignmentPatternOp` operand for
`k32: 12 + 1`, the SISTER PASS's ParamEmit ground, byte-identical pristine and
patched.

### 3f. `n3_ifacegrid` / `v7_ifacemix` — THE INTERFACE FENCE, REPLACED BY THE WALK

`bindVariable` has no `uhdminterface_inst` case, so the interface body is
SKIPPED and the walk goes on to the INSTANTIATING MODULE. Measured:

```
scope/cell    namesake home                  adjw  golden
gi.ifonly     interface body only             0    SHARES, member width 32
gi.both       ALSO in the instantiating module 16   CLONES at the MODULE's 16
gi.iflocal    interface gen-local, nowhere     0    SHARES, member width 32
gm.mv         module gen scope (CONTROL)       0    member width 32
```

(`gm.mv`'s member is 32 and its Lhs is 32, so the "no hit" reading and a
hypothetical Lhs reading coincide there — which is exactly why the arm needed
`gi.both`, where they cannot.)

and `v7_ifacemix`'s `gi.shared` is the cell that proves `tps` and the Lhs
binding are two different things: golden's constant is `UINT:31` at **16** (the
MODULE namesake's width) while its Lhs `vpiActual` points at
`work@dut.u_if.shared`, the INTERFACE's own 32-bit variable. Both arms CONVERT.
Pass 68's `ifaceHome69` fence is therefore not narrowed but REPLACED: the walk
answers both interface cells correctly without it.

### 3g. `n5_declkind` — LAW A's decode control (§1). CONVERTS.

### 3h. THE BOUNDARY, over every committed arm

`R11U71_OFF=1` on the SHIPPED binary reproduces the PRISTINE database **byte
for byte on all 34 arms** (`OFF=PRIS` 34/34), so 100 % of the patched delta is
this law. Eleven arms move; the other 23 are byte-identical pristine vs
patched, r11u69's `g1/g2/g3/g4/g5/g7/g8/g9/g12` included.

Cell scoreboard over all 34 arms (`score71.py`, golden vs pristine vs patched):

```
FIXED 34   BROKEN 0   STILL 37   MOVED-STILL-WRONG 10
```

Nine of the ten MOVED-STILL-WRONG are `SHARED-AMBIG` artifacts of §3a on arms
the OFFICIAL judge scores `cmp_rc 0`. The tenth is real and is §7 R2.

**NO LANDED CONVERSION IS LOST.** The nine arms already `cmp_rc 0` on the
pristine binary — `g1_genkind`, `g2_iter`, `g4_lhskind`, `g5_nest`,
`g9_child`, `v4_nestinst`, `v5_deadarm`, `w1_netlhs`, `w5_ovr` — are all still
`cmp_rc 0`, and every one of the nine databases is byte-identical pristine vs
patched.

**SEVEN ARMS CONVERT** (`cmp_rc 255 -> 0`, `heads 1 -> 0`):
`w9_sharehead`, `w10_sharesize`, `v2_ancnamesake`, `v7_ifacemix`,
`v10_arraysel`, `n3_ifacegrid`, `n5_declkind`.
Three arms keep a head but lose cmplines (`v1_namesake` 18->15,
`n2_bindhomes` 18->15, and every cell of `v1`/`g10_lhsbind` now agrees).
`w8_unitname` goes 15->18 with its head object CHANGED — the old head was the
Lhs binding face, now fixed; the new head is §7 R2.

### 3i. THE DEF-VIEW CONTROL

`emitGenScopes` has no def-view caller ("Generate scopes exist only in the
instance view", `src/ModuleEmit.cpp` ~13217 and the interface caller ~36972),
and it is SCORED not asserted: every `uhdmallModules` cell in `score71.py`'s
listing is unchanged pristine vs patched on all 34 arms.

---

## 4. THE LAW, GATED

`§ caStructParamGenScopeShareCut71` (`src/ModuleEmit.cpp`, beside
`emitGenScopes` and inside `emitCaStructParamSubst55`'s W3 step).

> **(A) THE CUT.** § caStructParamPatternSubst55's substitution fires for EVERY
> generate-scope `cont_assign` with a whole-name Lhs, in a module gen scope and
> in an interface gen scope alike, because `UhdmWriter::writeCont_assign` makes
> no test about the target before reducing.
>
> **(B) THE WIDTH.** `adjustSize`'s width is `bindVariable`'s NAME hit —
> `module_inst` scopes searched, `interface_inst` and `gen_scope` recursed past,
> the compilation unit unreachable — with `caLhsAdjustBind106`'s own fence set
> applied to whatever that walk finds (an implicit net, a bare `var d;`, a
> `time`, a non-`real` float and a non-integral leave `adjustSize` nothing to
> size with). No hit means `tps == nullptr`, which is `adjustSize` returning at
> once: the member's own width and spelling stand.

THE GATES, each with its measured cell, each droppable alone:

1. **`R11U71_OFF=1`** puts the FIRE decision back on pass 68's
   `!genCaLhsGenLocal113 && !ifaceHome69` AND the width back on
   `caLhsAdjustBind106` — the whole pass off, verified byte-identical to
   pristine on all 34 arms (§3h).
2. **`R11U71_NS_OFF=1`** keeps the cut and drops (B): the name walk never runs,
   so a namesake sizes at the member width exactly as pass 68 shipped.
3. **`R11U71_IF_OFF=1`** keeps the interface home fenced out, so (A) can land
   without the interface half.

   Both measured on the shipped binary, official `uhdm-cmp` rc per arm:

   ```
   arm                 pristine  patched  NS_OFF  IF_OFF
   w9_sharehead          255       0        0       0     (the cut alone)
   v2_ancnamesake        255       0      255       0     (needs the WIDTH)
   n3_ifacegrid          255       0      255     255     (needs BOTH)
   v7_ifacemix           255       0      255     255     (needs BOTH)
   v1_namesake           255     255      255     255     (§7 R1 keeps a head)
   n2_bindhomes          255     255      255     255     (§7 R1 keeps a head)
   ```
4. **WHOLE-NAME Lhs only** — pass 55's landed Lhs fence, kept and untouched
   (`v10_arraysel`'s three select cells, 1696 u2r + 15562 surelog corpus cells).
5. **ELAB VIEW ONLY** — structural, and scored (§3i).
6. **The MODULE-LEVEL home is untouched by construction**: `adjustW71`
   defaults to `-1`, which means "ask `caLhsAdjustBind106`", and the
   module-level call site passes the default. A module-body target inside a
   generate scope also takes the `caLhsAdjustBind106` answer FIRST, so every
   cell pass 68 converted answers with pass 68's own code.
7. **`R11U71_CELLDBG=1`** names EVERY generate-scope `cont_assign` that reaches
   the site with the predicate's answer, each gate's, `adjw`, and `spsAny` —
   the predicate recomputed for every whole-name-Lhs cell whatever the gates
   said, so a gate cannot hide a corpus site. The trace calls only pure
   predicates; it Makes no serializer object.

---

## 5. THE CENSUS, BOTH CORPORA, BOTH MODES, WITH POSITIVE CONTROLS

`cellcen71.py <repo> <corpus> <binary> <out.tsv>` replays the harness's OWN
discovery and its OWN slang argument vector, runs the shipped binary with
`R11U71_CELLDBG=1` and writes one row per cell; it refuses to dispatch the four
slang-fenced names, reading them out of `tools/probe/r10sd4repro/canaudit.sh`'s
own `FENCED=` line rather than respelling them. Every invocation's rc is
recorded. `cenjoin71.py` prints the profile table and the A-PRIORI MOVER SET.

| gate profile | uhdm2rtlil | surelog |
|---|---|---|
| **the law FIRES** (`sps=1`) | **0** | **0** |
| CUT-OPEN half (`genLocal=1` or `iface=1`), PREDICATE declines | 3658 | 5002 |
| pass-68 half, PREDICATE declines | 234 | 7572 |
| `plainLhs=0`, the landed Lhs fence declines | 1696 | 15562 |
| **cells reaching the site** | **5588** | **28136** |
| tests censused | 871 | 789 |
| invocations with no generate-scope `cont_assign` | 1596 | 1506 |

**THE LAW FIRES ON ZERO CORPUS CELLS IN EITHER CORPUS, AND THE HALF THIS PASS
CUT OPEN IS EMPTY TOO.** `spsAny` is 0 on every one of those cells, so no gate
is hiding a site: the corpora simply do not write a constant-valued read of a
struct parameter's field inside a generate block. 4549 surelog cell rows carry
`rc=-11` — those compiles SEGFAULT, which the harness itself records as
`SLANG_REJECT`; the census NAMES them rather than dropping them. 18 uhdm2rtlil
rows carry `rc=4`.

**A-PRIORI MOVER SET: 0 tests, both corpora** — stated before the byte gate,
and §6 measures 0 movers on uhdm2rtlil exactly.

**POSITIVE CONTROL for the site census**, the same scripts over this pass's own
grid with the shipped binary:

```
n2_bindhomes   8 cells: 4 CUT-OPEN sps=1, 4 PASS-68-HALF sps=1
u69_g11_iface  1 cell : iface=1 sps=1          (the interface home, CUT-OPEN)
A-PRIORI MOVER SET: 2 tests, both NEWFIRE
```

**SHAPE CENSUS calibration, GOLDEN-vs-GOLDEN FIRST** — `census71.sh <mode-dir>
<out> golden` reads the golden database on BOTH sides with the resolving lister.
A dump that outruns its budget writes a `TIMEOUT-G`/`TIMEOUT-O` row, and the
LISTER has a budget of its own (`TIMEOUT-P`): a multi-hundred-megabyte dump
parses for far longer than any dump budget, and an unbounded parse looks exactly
like a census that finished. Nothing is silently dropped.

Measured over the uhdm2rtlil/testflags workdir, alphabetically through 318
entries before the run was stopped for wall time:

```
tests scored 303    cells 1484    DIFFERING 0    tests with a differing cell 0
TIMEOUT-P 15 (recorded, not dropped)
```

**The instrument reads no noise.** That calibration plus the per-arm
golden-vs-golden (0 differing on all 34 arms) is what licenses §3's numbers.
The corpus question itself is decided by the SITE census above, which is exact
and complete on both corpora, and by §6's byte gate — not by the shape census.

---

## 6. THE GATES

All five gates green. Both sweeps run from this pass's own worktree, with
`SLANG_UHDM` exported explicitly and **every** `cmds.txt` audited by BINARY
PATH, into this pass's own workdirs; no shared `/tmp/ctl_wd_*` control was read.

**(1) BUILD.** Pristine `ed42e95baf0385529f25f139e2eb32d2` — byte-identical to
the main tree's `build/slang-uhdm` at `d2fe2435` and to the OPS pin. Patched
`8218fa497f10cd0ce05add9441e162ab`.

**(2) GOLDENS.** `23 PASS / 0 FAIL`; negative control `SLANG_UHDM=/bin/false`
gives `0 PASS / 23 FAIL`.

**(3) uhdm2rtlil, BOTH MODES.** `787 CMP_EQUAL / 17 CMP_NOTEQUAL / 67
SLANG_REJECT` in each mode on BOTH binaries. Whole-row join (status AND dump
column) against `d2fe2435`'s `results/gate_uhdm2rtlil.csv` (testflags) and
against the `default` rows of `d2fe2435`'s `results/golden_uhdm2rtlil.csv`:
**PASS — every row byte-identical to the committed baseline**, both modes. The
patched-vs-own-pristine join is PASS in both modes too. No row moved, so none
is quoted. (§0 explains the one row that differs against the MAIN TREE's newer
working copy of that CSV.)

**(4) surelog, `--mode both`.** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` default and
`469 CMP_EQUAL / 8 CMP_NOTEQUAL` testflags on BOTH binaries — the committed
baseline exactly, and the per-mode STATUS histograms are identical row for row
in both joins. Three rows differ in the whole-row join against the committed
baseline and all three are named:

```
Earlgrey_0_1,default,CMP_EQUAL,,,differ    ->  Earlgrey_0_1,default,CMP_EQUAL,,,
Earlgrey_0_1,testflags,CMP_EQUAL,,,differ  ->  Earlgrey_0_1,testflags,CMP_EQUAL,,,
LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] … "/tmp/<workdir>/…/surelog.log".
LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] … "/tmp/<workdir>/…/surelog.log".
```

The two `LowMem*` rows carry the WORKDIR PATH inside the `SURELOG_FAIL` detail,
so they differ against any baseline swept elsewhere AND between this pass's own
pristine and patched runs. `Earlgrey_0_1`'s DUMP COLUMN reads blank on a
`uhdm-dump` timeout draw; per the ops rule the DATABASE byte-compare is the pin,
and it holds in both modes on both binaries.

**(5) BYTEVERIFY, `SELFCHECK=1`, against this pass's own pristine workdirs.**

```
uhdm2rtlil:  PATH_SETS_IDENTICAL (1608 paths)   MOVERS: 0 / 1608
             SELFCHECK 1607 / 1608 flagged
surelog:     PATH_SETS_IDENTICAL  (960 paths)   MOVERS: 4 /  960
             SELFCHECK  959 /  960 flagged
```

uhdm2rtlil is **0 movers, exactly as §5 predicted BY NAME before the patched
sweep**. The four surelog movers are named and attributed:

```
default/MiniAmiq  default/SimpleUVM  testflags/MiniAmiq  testflags/SeqDriver
```

Every one is the UVM family the ops brief names pristine-nondeterministic, and
every one lands in the documented class: the path-normalised, SORTED
(order-blind) dumps differ by **exactly 4 lines**, one `UINT:` + one
`vpiDecompile:` pair, a macro-buffer line number:

```
MiniAmiq/default    UINT:1000 vs UINT:892     SimpleUVM/default   UINT:529 vs UINT:0
MiniAmiq/testflags  UINT:0    vs UINT:856     SeqDriver/testflags UINT:626 vs UINT:0
```

**THE POSITIVE CONTROL that convicts nondeterminism and not this law:** the
PRISTINE binary alone, run four times on `MiniAmiq`/default, produces FOUR
DIFFERENT databases —

```
run0 64af31207d87  run1 b48c6b5c6487  run2 196c745f0ed8  run3 3f2cfb97891e
```

— none of which equals either sweep's hash (`e112d68a979a` pristine,
`b8a9547a1f15` patched).

**CANARIES.**

```
canaries.sh  u2r/testflags   ok=8  changed=0 absent=0
canaries.sh  surelog         ok=50 changed=2 absent=0
   the two: Earlgrey_0_1 default + testflags, CMP_EQUAL/differ -> CMP_EQUAL/
            (the dump-column draw above; STATUS unchanged, both DB pins hold)
ctcan2.sh    surelog EXPECT_UNKNOWN=1  ok=58 changed=0   PASS
ctcan2.sh    u2r     EXPECT_UNKNOWN=6  ok=1  changed=0   PASS
canaudit.sh  (run from this directory, over canaries.sh + ctcan2.sh)
             audited=29  UNCOVERED=0  FENCE-BREACH=0   PASS
rowheads.sh  SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg /
             Earlgrey_0_1 = 0 cmplines 0 heads in every mode measured
             (SKIP-NOFILE on Scoreboard/testflags and Rggen/testflags expected);
             Rggen/default stays at its baseline 64 cmplines / 1 head
```

Protected databases by name, patched vs this pass's own pristine:

```
SVSwitch            4842211c4030  both modes   (the HARD pin, held)
YosysVerx           6ccda350c24a  both modes   (the HARD pin, held)
InterfaceModPort    59a365f3ce2c  both modes   (held)
BlackParrotComplex  e3e354129d5a / 73a10e8217e5  SAME
YosysOldOr          d68e0796d62c  both modes   SAME
Earlgrey_0_1        8bdf25272e08 default / 59d0ee6d10c3 testflags  SAME (the pins)
```

**SCORE.** MOVED-WRONG **0**, AWAY-GOLDEN **0**, both mode columns scored on
both corpora. Grid: **seven arms CONVERT**, `BROKEN 0`, 34 cells FIXED.
Corpus: **0 rows CONVERT, 0 rows ADVANCE, 0 rows REGRESS** — the prediction §5
made before the patched sweep, and §5 is why. `results/*.csv` untouched.

---

## 7. RESIDUES

* **R1 — THE NAMESAKE Lhs BINDING.** Golden points a namesake cell's Lhs
  `ref_obj` at the MODULE-BODY namesake (`v1_namesake` `ga`: `vpiActual ->
  logic_var (work@dut.nw)`), where we carry no `vpiActual` at all. **This is
  PRE-EXISTING and UNMOVED by this pass** — the base's own dump carries the
  same `<null>` (§ genCaConstRhsLhsNoBind25 already dropped it there, pass 68
  having already fired on namesake cells), and the byte diff of `v1_namesake`
  pristine-vs-patched touches only the constant. It became the arm's HEAD only
  because the object ahead of it was fixed. Modelling it means re-pointing a
  gen-scope Lhs at a namesake for EVERY gen-scope `cont_assign`, not only this
  law's, and the base has 3658 u2r + 5002 surelog `genLocal=1` cells — a wider
  blast radius than this pass earned. Its cells: `v1_namesake` ga/gb,
  `n2_bindhomes` gmb/gpo/gimp, `g10_lhsbind` gname.
* **R2 — THE PACKAGE-IMPORTED NAMESAKE.** `w8_unitname` `gp`: golden re-sizes
  to the imported package signal's 16 bits and binds the Lhs to a MODULE-LEVEL
  `logic_var (work@dut.pkgname)` that Surelog materialises for the import and
  that we do not emit at all. `slang::ast::Scope::find` returns `nullptr` for an
  `ExplicitImport` by design (`Scope.cpp:560`), so the walk cannot see it
  without a `members()` scan — and even with the width fixed the arm would keep
  a head for the missing module-level variable. MEASURED, declined, recorded.
  The `$unit` namesake beside it (`gu`) is measured NOT found by golden and is
  CORRECT on the patched binary.
* **R3 — THE INTERFACE'S MODULE-LEVEL `cont_assign`.** `g11_iface`'s head is
  `assign i_top = C.n;` written in the INTERFACE BODY, not in a generate scope:
  golden folds it (`UINT:6`/32) and § caStructParamPatternSubst55's
  module-level home does not run for an `interface_inst`. Byte-identical
  pristine and patched; a different home's law.
* **R4 — r11u69's R1/R2/R3 stand unchanged.** The location-less operation and
  concat mint (`g3_rhskind`), the FUNCTION-BUILT parameter in a generate block
  (`g8`/`g12`, § caAsmMemberSliceFold's ground) and a struct VARIABLE's field
  (`g12` `t_var`) are untouched by this pass and unmoved on the byte diff.
* **R5 — SHARING ITSELF.** Golden hands ONE constant object to several cells
  and to the `param_assign` operand; we mint one per cell with the same fields.
  Invisible to the judge (no generated `Compare` reads `VpiParent`) and
  measured so on seven converting arms — but it is why `shapes71.py` must mark
  `SHARED-AMBIG` rather than guess (§3a).

**R0 — THE NEXT MOVE.** The gen-scope substitution is now the producer's own
rule end to end: it fires on every whole-name-Lhs cell and `bindVariable`'s name
hit alone decides the width. The corpus does not write this shape (§5), so the
next road-E cell worth a pass is still **r11u69's R2 — § caAsmMemberSliceFold's
FUNCTION-BUILT struct parameter, extended to the same generate-scope listing**,
which is the arm the `struct_param_field_shift` family actually writes; after it,
r11u69's R1 (the location-less operation/concat mint). R1 above — the namesake
Lhs re-point — is a separate, WIDER law and wants its own pass with its own
corpus census over the 8660 `genLocal=1` cells.

---

## 8. REPRODUCE

```bash
GRID=<writable copy of grid> bash vrun71.sh <pristine> pris
GRID=<writable copy of grid> bash vrun71.sh <patched>  pat
python3 score71.py <grid>                      # FIXED/BROKEN/STILL per cell
NOSPAN=1 python3 shapes71.py cmp <arm>/gold.pat.dump <arm>/ours.pat.dump
python3 cellcen71.py <repo> uhdm2rtlil <patched> cells_u2r.tsv
python3 cellcen71.py <repo> surelog    <patched> cells_sl.tsv
python3 cenjoin71.py cells_u2r.tsv             # the gate table + mover set
bash census71.sh <workdir>/testflags out.tsv golden     # calibration FIRST
R11U71_OFF=1 / R11U71_NS_OFF=1 / R11U71_IF_OFF=1 / R11U71_CELLDBG=1
```
