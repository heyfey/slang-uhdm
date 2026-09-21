# r11u74 — the generate-scope Lhs points at the NAMESAKE, and the
# function-built member fold joins the generate-scope listing

Base commit `71490354`. Pristine binary md5 `598195b29a98fb7ee3263d01d53861e6`
— built in this pass's own worktree, `-j 2`, md5 taken separately, and
**byte-identical to the main tree's `build/slang-uhdm` at `71490354` and to
the OPS pin**, compared not assumed. Patched binary md5
`6180aae9131eb1fb658f28a58044163a`. Both frozen `chmod 555` at immutable paths
before any sweep; every `cmds.txt` audited by binary PATH (1742/1742 u2r,
and the surelog sweeps likewise).

---

## 0. THE BRIEF'S LAW A PREMISE IS REFUTED — SAY IT LOUDLY

> "struct_param_field_shift (a REAL u2r corpus test, CMP_NOTEQUAL both modes)
> actually writes the generate-scope arm"

**It is CMP_EQUAL in BOTH modes at the base**, and it always was. The
committed baseline says so in three places —

```
results/golden_uhdm2rtlil.csv:739 :  struct_param_field_shift,default,CMP_EQUAL,,,differ
results/golden_uhdm2rtlil.csv:1610:  struct_param_field_shift,testflags,CMP_EQUAL,,,differ
results/gate_uhdm2rtlil.csv:739   :  struct_param_field_shift,testflags,CMP_EQUAL,,,differ
```

— and re-measured on the OPS-pinned pristine binary it reads `cmp_rc=0`,
**0 heads, 0 cmp lines**.

**AND GOLDEN DOES NOT FOLD ITS GENERATE-SCOPE CELLS.** The test's gen-scope
assign is

```systemverilog
assign acc[k] = {{Cfg.XLEN_ALIGN_BYTES{1'b0}}, (8'hAB + k) << Cfg.XLEN_ALIGN_BYTES};
```

and golden keeps the whole `operation` with a symbolic
`hier_path (Cfg.XLEN_ALIGN_BYTES)` in **both** `gen_blk[0]` and `gen_blk[1]`
of `uhdmtopModules` — the reduce does not yield a constant, so
`writeCont_assign`'s `simplified == false` tail installs nothing. The Rhs is
not a bare member select either, so § caAsmMemberSliceFold's shape is not what
that row writes at all.

**THE WHOLE RESIDUE, SECTIONED (the r11u70 method), pristine vs golden,
default mode — 206 dump lines and NOT ONE OF THEM JUDGE-REACHABLE:**

| section | lines | what they are |
|---|---|---|
| `uhdmallPackages` | 0 | — |
| `uhdmtopPackages` | 12 | constant SPANS (`20:46` vs `20:33`) — no generated `Compare` reads `VpiFile`/line/col |
| `uhdmallModules` (DEF) | 2 | a `vpiParent` we write on a gen-scope constant and golden does not — no generated `Compare` reads `VpiParent` |
| `uhdmtopModules` (ELAB, tail excluded) | 4 | one constant's end column (`24:55` vs `24:45`) — span again |
| weaklyReferenced TAIL | 188 | unreachable to the judge by construction |

**PREDICTION, LOUD, MADE BEFORE THE PATCHED SWEEP: `struct_param_field_shift`
CONVERTS NOTHING, because there is nothing left in it for the judge to see.**
It was CMP_EQUAL before this pass and it is CMP_EQUAL after it, both modes,
dump column `differ` both times. The promotion question this pass answers is
therefore: **0 corpus rows CONVERT** — and §5's census says why, a priori and
by name.

The adjacent rows that ARE `CMP_NOTEQUAL` both modes on this family
(`cva6_struct_param_field`, `cfg_func_width_loop`, `stamped_gen_param`) write
`localparam type` struct fields, a package function-width loop and a 2-D
packed-array member select — none of them a generate-scope cont_assign whose
whole Rhs is a member of a function-built struct parameter.

---

## 1. LAW B IS JUDGE-VISIBLE — THE FIRST QUESTION, ANSWERED BY MEASUREMENT

The brief's first question for LAW B is whether the Lhs ref's `vpiActual` is
judge-visible. It is, **directly**, and the source says so before the grid
does:

```
UHDM/build/generated/src/cont_assign.cpp:124   SafeCompare(lhs->Lhs(), rhs->Lhs(), context)
UHDM/build/generated/src/ref_obj.cpp:150       SafeCompare(lhs->Actual_group(), rhs->Actual_group(), context)
BaseClass.h:191-193                            lhs != nullptr && rhs == nullptr -> m_failedLhs = lhs; return 1
```

**THE ISOLATING CELL** (arm `b1_bindvis`) is one gen block, one module-body
namesake, a constant Rhs, and nothing else:

```systemverilog
module dut (input logic a_i, output logic [31:0] o);
  logic [31:0] ns;                    // module-body namesake
  for (genvar i = 0; i < 1; i = i + 1) begin : gl
    logic [31:0] ns;                  // gen-local namesake hit
    logic [31:0] uq;                  // no namesake anywhere  <- CONTROL
    assign ns = 32'd7;
    assign uq = 32'd7;
  end
  …
```

Its **whole-database** diff against golden on the pristine binary is TEN
lines: **two** are the `vpiActual`, four are `vpiParent` inside a bit_select
and four are `vpiParent` in the weaklyReferenced tail. `cmp_rc 255`, **ONE
head**:

```
LHS:
logic_var: (work@dut.ns), id:89, line:6:16, endln:6:18
…
RHS: <null>
```

and the control row `uq` agrees on both sides. So a cell whose ONLY
difference is the binding reads `cmp_rc 255` one way and `cmp_rc 0` the
other. **VISIBLE. The law is landed, gated.**

The same head is what `x4_genarray` (the verifier's r11v71 arm, re-run here at
`71490354` on the pristine binary) carries: `cmp_rc=255`, 1 head,
`LHS: logic_var (work@dut.ns)` / `RHS: <null>`, 15 cmp lines.

---

## 2. LAW B DECODED — `§ caGenScopeLhsNamesakeBind74`

> A generate-scope `cont_assign` whose target is a VARIABLE DECLARED IN THAT
> GENERATE SCOPE points its Lhs `ref_obj` at the IMMEDIATELY ENCLOSING
> SCOPE's namesake — the enclosing generate scope's local, or the instance
> body's variable or net when the generate scope IS the outermost one — and
> never at the local it names. With no such namesake the cell keeps whatever
> the landed suppression laws give it.

**AMENDED BY THE VERIFIER (r11v74): THE WALK IS ONE SCOPE AND DOES NOT
CLIMB.** This text first read "the NEAREST ENCLOSING SCOPE's namesake", and
the code walked outwards until it found one. Verifier arms `v9_hops` and
`v1_nearest` measured golden on three nesting levels with a namesake at each:
golden binds only the IMMEDIATELY enclosing scope's namesake and writes NO
actual at all when the namesake is two or three scopes out, where pristine
also wrote none. The climbing walk was therefore AWAY-GOLDEN on those cells
(two in `v9_hops`, two in `v1_nearest`, judge-visible through
`cont_assign::Compare` -> `ref_obj::Compare` -> `Actual_group`); the shipped
law stops at the first searchable scope. See
`tools/probe/r11v74repro/README.md`.

**IT IS NOT `writeCont_assign`'s `:2165`.** That site
(`Surelog/src/DesignCompile/UhdmWriter.cpp:2165`, `ref->Actual_group(var)`) is
gated on `rhs->UhdmType() == uhdmoperation`, and arm `b3_rhskind` shows golden
binding the namesake for **eight Rhs kinds out of eight**. The pointer rides
on the netlist ref and `clone_tree` copies it
(`ref_obj::DeepClone`, `UHDM/build/generated/src/ref_obj.cpp:108-109`:
`bindAny(VpiName())` first, the original's `Actual_group()` second) — which is
also why golden's DEFINITION listing carries no actual at all on these cells
(`b1`'s `uhdmallModules` ref `work@dut.gl.ns` is bare) while every elaborated
copy carries one. The rule is therefore read off golden arm by arm, not
transcribed from one call site.

### 2a. `b2_homes` — the walk, one row per home kind (golden, both iterations)

| row | shape | golden's `vpiActual` |
|---|---|---|
| `v_ns` | gen-local var, module-body VARIABLE namesake | `logic_var work@dut.v_ns` |
| `n_ns` | gen-local var, module-body NET namesake | `logic_net work@dut.n_ns` |
| `w_ns` | namesake of a **16-bit** module var (target is 32) | `logic_var work@dut.w_ns` — width is not read |
| `p_in` | namesake of a module PORT net | `logic_net work@dut.p_in` |
| `own` | no namesake anywhere | **none** |
| `netown` | gen-local NET, no namesake | **none** |
| `netns` | gen-local **NET** with a module namesake | **none** — the target kind fences it |
| `P_NS` | namesake is a module **PARAMETER** | golden's Lhs is not a ref at all (a `constant`) — a different road, DECLINED |
| `mod_only` | a MODULE-LEVEL target written from the block | `logic_var work@dut.mod_only` — **R1**, not this law |
| `gin.deep` | nested block, no namesake | **none** |
| `gin.anc` | ANCESTOR gen scope's local as the TARGET | `logic_var work@dut.ga[1].anc` — **R1** |
| `gin.v_ns` | namesake in the ancestor gen scope AND the module body | `logic_var work@dut.ga[1].v_ns` — **the ONE HOP decides**; the target is the ancestor's own local here, so it is R1's cell, and r11v74 `v1_nearest` re-measures the same question with the target declared in the inner block |

### 2b. `b5_walkedge` — where the walk stops (golden)

| row | golden |
|---|---|
| `u_if.gi[0].i_ns` — an INTERFACE's generate scope | `logic_var work@dut.u_if.i_ns` (the interface BODY's namesake) |
| `u_if.gi[0].i_up` — namesake only in the INSTANTIATING module | **none** |
| `u.gl[0].lf_ns` — namesake in the leaf's own body | `logic_var work@dut.u.lf_ns` |
| `u.gl[0].up_ns` — namesake only in the PARENT INSTANCE | **none** |

So the walk **dies at the instance body**, which is exactly where it parts
company with `bindVariable`'s SIZE walk (`genCaSubstAdjustW71`, pass 71),
whose `default:` recursion DOES climb into the instantiating scope. Two
different roads, measured apart rather than assumed the same.

### 2c. `b3_rhskind` — THE ARM THAT CONVICTS THE LAW

One gen block; every Lhs a gen-local `logic [31:0]` with a module-body
namesake of the same name; the rows differ only in the Rhs.

| Rhs | golden | pristine | patched |
|---|---|---|---|
| `32'd7` (literal) | `work@dut.r_lit` | **none** | `work@dut.r_lit` |
| `a_i \| 32'd0` | `work@dut.r_op` | `work@dut.gb[0].r_op` | `work@dut.r_op` |
| `a_i` (whole ref) | `work@dut.r_ref` | `work@dut.gb[0].r_ref` | `work@dut.r_ref` |
| `CFG.n` (struct-param member) | `work@dut.r_hp` | **none** | `work@dut.r_hp` |
| ternary | `work@dut.r_tern` | `work@dut.gb[0].r_tern` | `work@dut.r_tern` |
| `32'(a_i[7:0])` (cast) | `work@dut.r_cast` | `work@dut.gb[0].r_cast` | `work@dut.r_cast` |
| `a_i \| '0` (unsized inside) | `work@dut.r_uns` | `work@dut.gb[0].r_uns` | `work@dut.r_uns` |
| `{16'd0, a_i[15:0]}` | `work@dut.r_cat` | `work@dut.gb[0].r_cat` | `work@dut.r_cat` |

**The Rhs is not a discriminator: 8 of 8.** And the pristine defect has TWO
faces — MISSING on two rows (§ genCaLiteralRhsLhsNoBind22 and
§ genCaConstRhsLhsNoBind25 suppress there) and WRONG-TARGET on six. One write
closes both. `cmp_rc 255 -> 0`. **CONVERTS.**

### 2d. `b4_nonamesake` — THE CONTROL THAT PROTECTS THE LANDED LAWS

`b3`'s nine-row twin with **no namesake anywhere** (the gen-local NET row
included) is **`cmp_rc 0` ON THE PRISTINE BINARY**: golden and pristine agree
object for object on every Rhs kind. The landed suppression laws are exactly
right where there is no namesake, and this pass fires only where there is
one — the set those laws already decline to move
(`caLhsUnboundOwnLocal23`'s namesake clause, `caLhsBindVariableFinds25`). It
installs the object they refused to guess, and `b4` is byte-unchanged.

### 2e. A MOVED-WRONG CAUGHT BY THE GRID BEFORE ANY GATE

The first cut walked outward from the TARGET's DECLARING scope instead of
from the scope that WRITES the assign. On `b2`'s `gin.v_ns` that skipped the
ancestor gen scope and bound the module body's `v_ns` — golden's answer is
`ga[1].v_ns`, so the cell went from wrong-by-omission to wrong-by-commission.
The fix is one line (`const Scope* w74 = blk.asSymbol().getParentScope();`)
plus the own-scope fence; `score74.py` reports BROKEN 0 on the shipped binary.

---

## 3. LAW A DECODED — `§ caAsmMemberSliceFoldGenScope74`

> § caAsmMemberSliceFold's member/slice fold for a FUNCTION-BUILT struct
> parameter runs for a `cont_assign` written inside a GENERATE BLOCK exactly
> as it does at module level, because `UhdmWriter::writeElabGenScope`
> (`UhdmWriter.cpp:2367-2372`) hands the generate scope's own
> `netlist->cont_assigns()` to the SAME `writeCont_assign`.

This pass **adds nothing to the decode or the emission**: the same
`SrlgCaMemSel` record, drained by the same `drainCaAsmMemberSlice`. The full
model (the `ExprEval::hierarchicalSelector` slice, the bare-digit encoding,
`adjustSize` branch by branch, the `d13` nested-struct fence) is at the record
struct in `include/UhdmExporter.h` and is unchanged.

### 3a. `a1_fbgenkind` — the generate KIND is not a discriminator

`FB.n` / `FB.m` off a `p::cfg_t` built by an automatic function, written once
at module level and once in a gen-for, a named gen-if TRUE arm, a gen-case, a
two-deep nest and an UNNAMED gen-if. Golden folds **every** generate row to
the module-level row's own object —

```
constant (no location)
 |vpiDecompile:00000000000000000000000001000000     <- BARE digits, no <w>'b
 |vpiSize:32
 |BIN:00000000000000000000000001000000
 |vpiTypespec: ref_typespec -> the MEMBER's own int_typespec
 |vpiConstType:3
```

— while pristine keeps the symbolic `hier_path` in all five elaborated rows.
Patched: all five match golden. `cmplines 33 -> 15`.

### 3b. `a2_fbwidths` — the size rule, member kind x Lhs width (golden, gen rows)

| member | Lhs | golden |
|---|---|---|
| `int unsigned` (32) | 8 | `BIN` **sz=8**, 32 digits — value NOT truncated |
| `int unsigned` (32) | 64 | sz=32 |
| `logic [39:0]` | 8 | value AND decompile truncated to the LOW 8 digits, sz=8 |
| `logic [39:0]` | 64 | untouched, sz=40 |
| `byte` (8) | 32 | sz=8 |
| `bit` (1) | 32 | sz=1 |
| `enum logic [1:0]` | 32 | sz=2 |
| `int unsigned` | part-select Lhs (no bind) | sz=32, member width stands |

All eight generate rows: pristine DIFF -> patched EQUAL. The width comes from
`genCaSubstAdjustW71`, which is pass 71's decode of the `tps` that
`UhdmWriter.cpp:2168-2172` takes from `bindVariable`'s name hit; `0` is the
producer's `ts == nullptr` return-at-once.

### 3c. `a3_fbfence` — the fences, each with its MODULE-LEVEL twin

| row | module level | generate block |
|---|---|---|
| `NS.n`, struct-BEARING struct (the `d13` fence) | DIFF | DIFF — parity |
| `NS.u.w`, a member OF a member | DIFF | DIFF — parity |
| `FBP.n + 1`, an operation AROUND the select | equal | DIFF — r11u69's R1, unmoved |
| `{16'd0, FBP.n[15:0]}`, a concat around it | DIFF | DIFF — parity |
| `LP.n`, the PATTERN-built twin | equal | equal (r11u69's landed law) |
| `FBP.n` onto a BIT-SELECT Lhs | equal | **pristine DIFF -> patched EQUAL** |
| `FBP.n` onto an ARRAY-ELEMENT Lhs | equal | **pristine DIFF -> patched EQUAL** |

The two select-Lhs rows fold in golden too: the fold is an Rhs decision and
the Lhs only ever reaches `adjustSize`.

---

## 4. THE LAWS, GATED

`§ caAsmMemberSliceFoldGenScope74` and `§ caGenScopeLhsNamesakeBind74`, both
in `src/ModuleEmit.cpp` and nowhere else. Production surface: **303 inserted
lines in one file, no deletions, no edits to any existing line** —
`ParamEmit.cpp` (`__LINE__`-sensitive) is not touched at all.

**LAW A's gates**
1. ELAB VIEW ONLY — structural: `emitGenScopes` has no def-view caller, and
   golden's definition listing keeps the symbolic `hier_path` (`a1`).
2. The whole Rhs must BE the member select (`a3` operation / concat rows).
3. Packed-struct base with NO packed-struct member — r11u16's `d13` fence,
   copied cell for cell (`a3` `NS.n`, `NS.u.w`).
4. The drain declines unless the base's own elaborated `param_assign` Rhs is
   the assembled BIN constant of EXACTLY the struct's packed width — a bail
   writes nothing and mints nothing.

**LAW B's gates**
1. The target is a **Variable** — a gen-local NET is declined (`b2` `netns`).
2. The target is declared in **THIS** generate scope — a target declared
   outside it is R1's class, left exactly as pristine leaves it.
3. The namesake must be a **Variable or Net** — a parameter namesake is a
   different road (`b2` `P_NS`).
4. The walk **stops at the instance body** (`b5` `u.gl[0].up_ns`).
5. A namesake that does not resolve to an emitted object writes nothing —
   declined, never moved onto a third object.

**Droppable alone.** `R11U74_FOLD_OFF=1`, `R11U74_BIND_OFF=1`,
`R11U74_OFF=1` (both), `R11U74_CELLDBG=1` (the cell trace, outside the A/B
switch, naming the DECLINED cells too). `R11U74_OFF=1` on the shipped binary
reproduces the pristine database **byte for byte on all 8 arms**.

---

## 5. THE CENSUS — THE MOVER SET, A PRIORI AND BY NAME

`cellcen74.py` replays the harness's OWN discovery and its OWN slang argv
(`verify_golden.discover_*` / `translate` / `location_args`), runs the PATCHED
binary with `R11U74_CELLDBG=1`, and writes one row per generate-scope
`cont_assign` that reaches either site — **the declined cells included**.
Every invocation's rc is recorded. The four slang-fenced names are read off
`canaudit.sh`'s own `FENCED=` line and never dispatched.

| corpus | arms | gen-scope CA cells traced | LAW B namesake cells | LAW A fold cells |
|---|---|---|---|---|
| uhdm2rtlil | 871 x 2 modes | 3892 | **4** | **0** |
| surelog | 798 x 2 modes | 12574 | **0** | **0** |

The 4 are all one test: `genvar_loop_decl_3`, cells `work@gate.gen:229` and
`work@gold.gen:517`, in both modes — `assign y = x + 1;` inside `begin : gen`
whose `integer y` shadows the module's `output reg [15:0] y`.

**THE CENSUS ZERO HAS A POSITIVE CONTROL** (a census zero needs one): the same
trace on arm `a1_fbgenkind` names **5** FOLD cells and on `b2_homes` **8**
namesake BIND cells — the exact converted sets. The instrument can see.

`rc != 0` arms are recorded and carry no blind spot: the 578 surelog and 131
u2r `rc=3` arms emit NO trace rows at all (the compile failed, so nothing was
emitted and the sweep has no database for them), while the 900 `rc=-11` arms —
the census's own `-o /dev/null` artifact, after emission — DO emit their rows
(898 of the 12574 cells come from them).

**PREDICTED MOVER SET, WRITTEN BEFORE THE PATCHED SWEEP: exactly two
databases, `genvar_loop_decl_3` default and testflags. Nothing else in either
corpus, either mode.**

---

## 6. THE GATES

### 6a. Build and binaries

```
pristine  598195b29a98fb7ee3263d01d53861e6   == main tree @71490354 == the OPS pin
patched   6180aae9131eb1fb658f28a58044163a
```

### 6b. Goldens

```
patched   PASS 23   FAIL 0
pristine  PASS 23   FAIL 0
/bin/false PASS 0   FAIL 23        (negative control)
```

### 6c. uhdm2rtlil, both modes

```
testflags vs results/gate_uhdm2rtlil.csv   PASS: every row byte-identical
testflags vs this pass's own pristine      PASS: every row byte-identical
default   vs results/golden_uhdm2rtlil.csv 0 rows differing
default   vs this pass's own pristine      0 rows differing
testflags vs results/golden_uhdm2rtlil.csv 0 rows differing
```

788 CMP_EQUAL / 16 CMP_NOTEQUAL / 67 SLANG_REJECT in both modes on both
binaries — the committed baseline exactly. `struct_param_field_shift` stays
CMP_EQUAL / `differ` in both modes on both binaries, as §0 predicted.

### 6d. BYTE VERIFY, uhdm2rtlil — every mover named and attributed

```
databases: patched=1608 pristine=1608
PATH_SETS_IDENTICAL (1608 paths)
MOVER ./default/genvar_loop_decl_3-673e2544/slang.uhdm
MOVER ./testflags/genvar_loop_decl_3-673e2544/slang.uhdm
MOVERS: 2 / 1608
SELFCHECK (every file vs one fixed file): 1607 / 1608 flagged
```

**2 / 1608, and both were predicted BY NAME by §5's census.** Attributed
ORDER-BLIND (both dumps path-normalised and sorted) the whole delta is FOUR
lines per mode and every one of them is the law:

```
- \_integer_var: (work@gate.gen.y)      <- pristine: the OWN gen-local
- \_integer_var: (work@gold.gen.y)
+ \_logic_net:   (work@gate.y)          <- patched: the module-body namesake
+ \_logic_net:   (work@gold.y)
```

and golden carries `logic_net (work@gate.y)` / `logic_net (work@gold.y)` on
exactly those two refs. **Distance to golden 12 -> 8 lines in BOTH modes:
TO-GOLDEN 4, AWAY-GOLDEN 0, MOVED-WRONG 0.**

### 6e. Surelog suite, both modes

Status histogram, **identical on the committed baseline, on this pass's own
pristine sweep and on the patched sweep**:

```
default    474 CMP_EQUAL   9 CMP_NOTEQUAL   285 SLANG_REJECT  25 SURELOG_FAIL   5 DEFERRED
testflags  469 CMP_EQUAL   8 CMP_NOTEQUAL   286 SLANG_REJECT  23 SURELOG_FAIL   5 DEFERRED
           + 3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
```

Whole-row join (status AND dump column), 1596 rows:

| join | rows differing | which |
|---|---|---|
| committed vs **pristine** | 2 | `Earlgrey_0_1` default + testflags, dump column `differ` -> blank |
| committed vs **patched** | 1 | `Earlgrey_0_1` testflags, same blanking |
| pristine vs **patched** | 1 | `Earlgrey_0_1` default, blank -> `differ` |

Every one of those is the **`uhdm-dump` TIMEOUT draw under load**, which the
ops rules name as environment: the STATUS is `CMP_EQUAL` in all six readings,
the blank appears on the PRISTINE binary too (on both modes, where the patched
binary blanked only one), and **the database byte pin holds exactly**:
`Earlgrey_0_1 default 8bdf25272e08`, `testflags 59d0ee6d10c3`. The two
`LowMemLib` / `LowMemPkg` testflags rows carry the sweep's own WORKDIR PATH
inside a `SURELOG_FAIL` detail string on every run and differ from the
committed baseline on the pristine binary as well — a path, not a status.

Canaries: `ok=51 changed=1` (that one row is `Earlgrey_0_1 testflags`'s dump
column, above), `ctcan2 ok=58 changed=0 PASS`, `canaudit audited=29
UNCOVERED=0 FENCE-BREACH=0 PASS`. Protected databases by md5, patched vs
pristine: `InterfaceModPort 59a365f3ce2c` SAME both modes,
`BlackParrotComplex` SAME both modes, `YosysOldOr d68e0796d62c` SAME both
modes, **`SVSwitch 4842211c4030` SAME both modes**, **`YosysVerx
6ccda350c24a` SAME both modes**.

The UVM family stays CONVERTED: `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`,
`SimpleUVM` `CMP_EQUAL` in both modes and `Scoreboard` `CMP_EQUAL` default
(its testflags row is the committed `SLANG_REJECT`).

**Binary path audit.** 1581 `cmds.txt` per sweep; 1531 name the frozen binary
on each side and the 50 that do not are the **same 50 paths** on both — arms
whose Surelog side failed, so no exporter was invoked at all.

### 6f. BYTE VERIFY, surelog — 6 movers, all the documented UVM class

```
databases: patched=960 pristine=960
PATH_SETS_IDENTICAL (960 paths)
MOVERS: 6 / 960
SELFCHECK (every file vs one fixed file): 959 / 960 flagged
```

`MiniAmiq`, `Scoreboard`, `SeqDriver`, `SimpleUVM` (default) and `MiniAmiq`,
`SeqDriver` (testflags). §5's census predicted **ZERO** movers in this corpus,
so every one of these is attributed ORDER-BLIND (both dumps path-normalised
and sorted) before anything is claimed:

| database | order-blind diff lines | what they are |
|---|---|---|
| `Scoreboard` default | **0** | a pure ORDER DRAW — the documented `svunit_pkg` `vpiTaskFunc` list-order coin |
| `MiniAmiq` default | 4 | `UINT:1235`/`vpiDecompile:1235` vs `UINT:616`/`616` |
| `SeqDriver` default | 4 | `UINT:0`/`0` vs `UINT:923`/`923` |
| `SimpleUVM` default | 4 | `UINT:0`/`0` vs `UINT:694`/`694` |
| `MiniAmiq` testflags | 4 | `UINT:1143`/`1143` vs `UINT:1309`/`1309` |
| `SeqDriver` testflags | 4 | `UINT:0`/`0` vs `UINT:1180`/`1180` |

Every non-zero delta is a **`UINT:<n>` + `vpiDecompile:<n>` PAIR and nothing
else** — the macro-buffer `SourceLocation` LINE-NUMBER class the ops rules
name for exactly this family ("the 0-or-4-line `UINT`/`vpiDecompile`
line-number class — a 0-line order draw also occurs"), and both the 0-line and
the 4-line draw are present here. **Not one of the six carries a `vpiActual`
line or a folded `constant` — this pass's two signatures — and the census
found no cell of either law anywhere in this corpus.** Status unchanged, all
six still `CMP_EQUAL`.

### 6g. Grid score (the resolving span-free shape lister, `NOSPAN=1`)

Calibration golden-vs-golden: **0 differing on all 8 arms**. Positive control:
a single `lhsact` flip in one cell of one golden dump is caught
(`DIFFERING 0 -> 1`). The lister marks `SHARED-AMBIG` rather than guess when
a span carries two different full prints.

```
a1_fbgenkind     OK=   7 FIXED=  4 BROKEN=  0 STILL=  1
a2_fbwidths      OK=  25 FIXED=  8 BROKEN=  0 STILL=  2
a3_fbfence       OK=  18 FIXED=  2 BROKEN=  0 STILL= 11
b1_bindvis       OK=   7 FIXED=  1 BROKEN=  0 STILL=  0
b2_homes         OK=  25 FIXED=  8 BROKEN=  0 STILL=  4
b3_rhskind       OK=  26 FIXED=  8 BROKEN=  0 STILL=  0
b4_nonamesake    OK=  19 FIXED=  0 BROKEN=  0 STILL=  2
b5_walkedge      OK=  14 FIXED=  2 BROKEN=  0 STILL=  2
TOTAL OK=141 FIXED=33 BROKEN=0 STILL=22
```

`cmp_rc` per arm, pristine -> patched: `b1_bindvis` **255 -> 0**,
`b3_rhskind` **255 -> 0**, `b4_nonamesake` 0 -> 0 (the control holds),
`a1_fbgenkind` 255 -> 255 (`cmplines 33 -> 15`; its remaining head is a
nested-gen module-port Lhs binding residue that is byte-identical on both
binaries), `a2` / `a3` / `b2` / `b5` keep a pre-existing head. Every arm
`golden_rc=0 ours_rc=0` — no arm teaches error recovery.

---

### 6h. THE SCORE

**MOVED-WRONG 0. AWAY-GOLDEN 0. TO-GOLDEN 4** (the two `genvar_loop_decl_3`
databases, 2 lines each, distance 12 -> 8 in both modes). Both mode columns
scored on both corpora. Grid: **2 arms CONVERT** (`b1_bindvis`,
`b3_rhskind`, `cmp_rc 255 -> 0`), 33 cells FIXED, **0 BROKEN**. Corpus:
**0 rows CONVERT, 0 rows ADVANCE, 0 rows REGRESS** — which is the prediction
§0 and §5 both made before the patched sweep, and §5 is why.
`results/*.csv` untouched (`grep -c '^diff --git a/results' /tmp/r11u74.patch`
= 0). No fenced name is dispatched by any driver here (`canaudit`
FENCE-BREACH 0).

---

## 7. RESIDUES

* **R1 — THE TARGET DECLARED OUTSIDE THE WRITING SCOPE.** Golden binds a
  generate-scope cont_assign's Lhs to an ANCESTOR gen scope's local
  (`b2` `gin.anc` -> `work@dut.ga[1].anc`), to a namesake that is itself the
  ancestor's local (`b2` `gin.v_ns` -> `work@dut.ga[1].v_ns`) and to a
  MODULE-LEVEL target written from inside the block (`b2` `mod_only` ->
  `work@dut.mod_only`); pristine carries none of the three and this pass
  leaves all three exactly as pristine left them. It is the same class —
  "the target is declared outside the scope that writes the assign, and
  golden binds it to itself" — and it is § genCaLiteralRhsLhsNoBind22's own
  ground: that law's text says OWN-SCOPE but its `lhsSuppress` condition tests
  only `pk0 == GenerateBlock && lsym0.kind == Variable`, so it over-fires on
  an ancestor target with a literal Rhs. Judge-visible, four cells measured,
  a landed law's fence to widen — its own pass, with its own corpus census.
* **R2 — r11u69's R1, the LOCATION-LESS operation/concat mint.**
  `a3_fbfence` `g_op` (`FBP.n + 1`, golden `UINT:65` at 32) and `g_cat`
  (`{16'd0, FBP.n[15:0]}`, golden the 32-digit `BIN`) fold in a generate
  block and we keep the operation. Unmoved on both binaries; the module-level
  `t_cat` twin is the same divergence one scope out.
* **R3 — the STRUCT-BEARING STRUCT and the MEMBER-OF-A-MEMBER.**
  `a3` `NS.n` / `NS.u.w`, fenced at module level by r11u16's `d13` decision
  and fenced here for the same reason — PARITY with the module-level home is
  the arm's target and it is met.
* **R4 — the nested-gen module-PORT Lhs binding.** `a1` `g_nest`
  (`work@dut.gn.gn2[0]`): golden's Lhs ref carries no `vpiActual`, ours carries
  `logic_net (work@dut.g_nest)`. PRE-EXISTING and byte-identical pristine and
  patched — it became the arm's remaining cell only because the Rhs ahead of
  it was fixed.
* **R5 — the INTERFACE DEFINITION listing.** `b5`'s two remaining cells are
  `uhdmallInterfaces` cont_assigns golden writes and we do not write at all.
  Pre-existing, unmoved, a different home's law.
* **R6 — the MODULE-level PART-SELECT Lhs row.** `a2` line 41: the lister
  keys golden's and our Lhs differently there. Pre-existing on the pristine
  binary, unmoved.
* **R7 — r11u71's R2 (the package-imported namesake) and R3 (the
  unpacked-array namesake that zeroes the VALUE)** are ADJACENT cells on this
  ground and were NOT widened into: both are width/value faces of
  `adjustSize`, not of the Lhs binding, and neither shape appears in either
  corpus. Recorded, not approximated.
* **R8 — SHARING.** Golden hands one constant object to several cells; we
  mint one per cell with the same fields. Invisible to the judge (no
  generated `Compare` reads `VpiParent`) and the reason `shapes74.py` marks
  `SHARED-AMBIG` rather than guessing.

**R0 — THE NEXT MOVE.** Both of pass 71's named R0s are now closed:
§ caAsmMemberSliceFold reaches the generate-scope listing, and the
generate-scope Lhs points where the producer points it. The corpus writes the
namesake shape in exactly one test and the function-built generate fold in
none (§5), so the next cell on this ground is **R1 above — the target declared
OUTSIDE the writing scope**, which is judge-visible, measured on four golden
cells today, and is a fence to widen on a LANDED law
(§ genCaLiteralRhsLhsNoBind22) rather than a new site; after it, **R2**
(r11u69's location-less operation/concat mint), whose module-level twin is
already unequal and which would close `a3`'s `g_op`/`g_cat` and the
module-level `t_cat` together.

---

## 8. REPRODUCE

```bash
GRID=<writable copy of grid> bash vrun74.sh /tmp/r11u74_pris.bin pris
GRID=<writable copy of grid> bash vrun74.sh /tmp/r11u74_pat.bin  pat
python3 score74.py <grid>                          # FIXED/BROKEN/STILL per arm
NOSPAN=1 python3 shapes74.py cmp <arm>/gold.pat.dump <arm>/ours.pat.dump
NOSPAN=1 python3 shapes74.py cmp <arm>/gold.pat.dump <arm>/gold.pat.dump   # calibrate: 0
python3 cellcen74.py <repo> uhdm2rtlil <patched> cells_u2r.tsv
python3 cellcen74.py <repo> surelog    <patched> cells_sl.tsv
SELFCHECK=1 bash byteverify.sh <patched-workdir> <pristine-workdir>
R11U74_OFF=1 / R11U74_BIND_OFF=1 / R11U74_FOLD_OFF=1 / R11U74_CELLDBG=1
```
