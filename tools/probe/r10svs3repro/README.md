# r10svs3 — SVSwitch's 1512-line head: `this.<member> = new…` contributes NO statement-list element

**Base commit 266d3a6. Emitter-only. One law, five call sites, five arms, five gates.**

Headline, stated first because the brief asked for it in the first line:
**SVSwitch does NOT convert.** It stays `CMP_NOTEQUAL` in both modes. What this
pass did is **clear the briefed head** — 1512 cmp lines → 78 — and expose the
next one, which is a different law (§ residue R1). The row is quoted from this
agent's own sweep in §6.

| number | pristine 266d3a6 | shipped | note |
| --- | --- | --- | --- |
| SVSwitch cmp HEAD DEPTH | 1512 | **78** | head CLEARED, a new head exposed |
| SVSwitch dump content +/- | 2632 | 2578 | ALIGNMENT-SENSITIVE |
| SVSwitch MULTISET distance | 1992 | **1950** | `msdist.sh` at 7c7eaa6, indentation KEPT |
| SVSwitch row, both modes | CMP_NOTEQUAL | CMP_NOTEQUAL | **no promotion** |

THREE DISTINCT NUMBERS, never conflated — head depth, alignment-sensitive
content, multiset distance. They are three different measurements of the same
change and this table is the only place they appear together.

---

## 0. THE BINARIES — which number came from which

| binary | md5 | what it is |
| --- | --- | --- |
| main tree `build/slang-uhdm` at 266d3a6 | `663899bcad3b7696f1d3f9fa972ec085` | the committed baseline build |
| **pristine worktree, built from scratch by this agent** | `663899bcad3b7696f1d3f9fa972ec085` | **byte-identical to the main tree** |
| law-off arm (§5.3, not shipped) | `4bcce04afe5a975f54a76da6e2f5708e` | predicate forced `false`, all call sites still compiled in |
| **SHIPPED** | `d1ccd848dd088a9b37918cb944336423` | every gate below |

The pristine worktree binary is **byte-identical** to the main tree's. That is
the stale-binary control working in the useful direction: the pristine side of
every comparison here really is 266d3a6, built by this agent, with no inherited
artefact. Both worktrees are at `git rev-parse --short HEAD` = `266d3a6`; the
source delta between them is exactly the three production files in the patch.

**The shipped binary md5 is the SAME binary every gate was measured on.** After
gates 2–5 ran, two comment-only edits went in (§5.4's corrected constructor
paragraph, and removing §5.3's arm line). Rebuilding produced
`d1ccd848dd088a9b37918cb944336423` again — bit-for-bit the gate-run binary — so
no gate number is stale with respect to the shipped source. That comments do not
move the binary is not an assumption here; it was measured (§5.2).

---

## 1. THE FUNCTION-SPAN QUESTION, WHICH WAS ASSIGNED TO THIS PASS — ANSWERED: SPANS ARE cmp-INVISIBLE

The brief said: *"FIRST establish whether uhdm-cmp's Compare even READS
VpiLineNo/VpiEndLineNo on these objects… If spans are cmp-INVISIBLE, the span law
is dump-only (phase-3) work… If spans DO gate, it is likely THE law behind this
head."*

They are cmp-invisible. **This refutes the brief's leading hypothesis**, and it
is the reason no span code was written.

`begin::Compare` (`~/git-repos/UHDM/build/generated/src/begin.cpp:83`) compares
exactly two things:

```cpp
int32_t begin::Compare(const BaseClass *other, CompareContext* context) const {
  int32_t r = 0;
  if (!context->m_visited.insert(this).second) return r;
  if ((r = basetype_t::Compare(other, context)) != 0) return r;
  ...
  if ((r = SafeCompare(lhs, lhs->Stmts(), rhs, rhs->Stmts(), context)) != 0) return r;
  return r;
}
```

and `BaseClass::Compare` (`~/git-repos/UHDM/templates/BaseClass.cpp:163`)
compares `VpiType()`, `VpiName()`, `VpiDefName()` — and nothing else. `function`
adds `VpiSigned/VpiSize/VpiFuncType`; `task_func` adds the method/visibility/DPI
scalars plus `Io_decls`, `Stmt`, `Return`, `Class_defn`; `scope` adds its object
lists. No line, column or file field appears in any of them.

Proof over the WHOLE generated tree, not just the three classes:

```
$ cd ~/git-repos/UHDM/build/generated/src
$ grep -l "::Compare" *.cpp | wc -l
233
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiLineNo|VpiEndLineNo|VpiColumnNo|VpiEndColumnNo|VpiFile"
0
```

and the controls proving that `awk` window really does see field reads:

```
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiName\(\)"
37
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiSigned\(\)"
13
```

**233 Compare methods, 0 span reads, controls non-zero.** So golden ending a
class method's `function` span at the qualifier (`82:1-82:8` covering
`virtual `) while ours runs to the body end (`82:1-93:26`) can never be a cmp
head. It is dump-only, phase-3, and it is filed as residue **R4** with the
qualifier matrix already measured in arm a4 (q3/q4/q5/q6/q7/q10) so the next pass
does not have to build it. A span policy touches every function in every design;
spending this pass on a cmp-invisible field would have been the whole blast
radius for no cmp movement.

---

## 2. LOCALIZATION — THE FAILING FIELD IS `begin::Stmts()`, AND IT IS A LIST LENGTH

Reproduced on the pristine binary through the harness itself
(`svsgen.sh`, which builds the argv with `scripts/verify_golden.py` so both sides
carry the exact flags the committed rows were produced with):

```
$ svsgen.sh /tmp/r10svs3_pris_svs <pristine>
SLANG=...r10svs3pris/build/slang-uhdm  md5=663899bcad3b7696f1d3f9fa972ec085
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
== default
  cmp rc=255  cmp HEAD DEPTH=1512  heads=1
== testflags
  cmp rc=255  cmp HEAD DEPTH=1512  heads=1
```

`grep -c '^LHS:'` = 1 at column 0: ONE head, exactly the briefed one.

1512 cmp lines is **HEAD DEPTH** — the begin's whole subtree printed. The failing
field is somewhere inside. `svsstmts.cpp` reads the only thing `begin::Compare`
can fail on, the `Stmts()` list, through the vpiStmt relation itself (never by
grepping a dump — an object is not a dump occurrence):

```
$ svsstmts golden.uhdm ours.uhdm work@packet byte_unpack
A(golden) function 'byte_unpack' Packet.sv:82:1-82:8
B(ours)   function 'byte_unpack' :82:1-93:26
A body container begin '' Packet.sv:84:3-84:22
B body container begin '' :84:3-84:22
STMTS golden=7 ours=8  *** LENGTH MISMATCH ***
  [0] EQ    A assignment Packet.sv:83:3-83:21   B assignment :83:3-83:21
  [1] EQ    A assignment Packet.sv:84:3-84:21   B assignment :84:3-84:21
  [2] EQ    A assignment Packet.sv:85:3-85:25   B assignment :85:3-85:25
  [3] EQ    A assignment Packet.sv:86:3-86:35   B assignment :86:3-86:35
  [4] DIFFERKIND  A foreach_stmt Packet.sv:88:3-88:10   B assignment :87:3-87:34
  [5] DIFFERKIND  A assignment   Packet.sv:90:3-90:15   B foreach_stmt :88:3-88:10
  [6] DIFFERKIND  A if_stmt      Packet.sv:91:3-92:16   B assignment  :90:3-90:15
  [7] ONLY_B      A <null>                              B if_stmt     :91:3-92:16
TOTALS EQ=4 DIFFER=0 DIFFERKIND=3 ONLY=1
```

**THE NAMED FIELD: `begin::Stmts()` of `work@packet::byte_unpack`'s body — golden
7 elements, ours 8.** Elements [0..3] compare EQ; our extra element at
`Packet.sv:87:3-87:34` desynchronises the list, and the three `DIFFERKIND`s plus
the `ONLY_B` are one insertion, not four separate defects. `Packet.sv:87` is

```systemverilog
this.data = new[bytes.size - 4];
```

### 2.1 The brief's other candidate features, each CHECKED rather than assumed

The brief listed six features inside the subtree and required them enumerated and
localized before any fix. The census settles five of them at once, because
elements [0..3] compare **EQ**:

| feature | site | verdict |
| --- | --- | --- |
| `this.<member>` lvalue hier_path | [0] `this.da = bytes[0]` 83:3 | **EQ — not the field** |
| bit-select of a const-ref formal | [0]–[2] `bytes[0]`, `bytes[1]`, `bytes[2]` | **EQ — not the field** |
| the parens-less query `bytes.size` | [3] `this.fcs = bytes[bytes.size - 1]` 86:3 | **EQ — r10svs2's law HOLDS here** |
| `const ref logic [7:0] bytes[]` io_decl | `task_func::Io_decls`, compared before `Stmt` | **not reached — no head** |
| `foreach(data[i])` over a class property | golden [4] / ours [5] | EQ once realigned |

r10svs2 landed the parens-less law and the brief said *"check it holds INSIDE this
function (its arms measured other sites)"* — it does: element [3] is the
`bytes.size` site and it compares equal. Verified, not assumed. The `const ref`
formal is likewise exonerated: `task_func::Compare` compares `Io_decls()` BEFORE
`Stmt()`, so a formal defect would have produced a head above this one.

---

## 3. THE LAW

### § thisSuperNewAssignNoStmt3

> An assignment written `<this|super>[.<name>]… = new[…]` or `… = new(…)`
> contributes **NO ELEMENT** to a Surelog statement LIST. The enclosing block
> survives — EMPTY if that was its only element — and when the assignment is the
> whole body of a plain subroutine the subroutine gets no `vpiStmt` at all.
> **The gate is the written `this`/`super` KEYWORD on the LHS *and* a written
> `new` on the RHS**, and the ONE exception is a class constructor's **own**
> statement list.

Greppable at the definition and at all five call sites:

```
$ grep -n "thisSuperNewAssignNoStmt3" src/*.cpp include/*.h
include/UhdmExporter.h:2095  (declaration)
src/StmtEmit.cpp:554         (definition + the full decode)
src/StmtEmit.cpp:1232        CALL SITE 1 of 5 — written begin/fork statement list
src/StmtEmit.cpp:1249        CALL SITE 2 of 5 — written begin's single statement
src/StmtEmit.cpp:2842        CALL SITE 3 of 5 — single-effective-statement list
src/StmtEmit.cpp:2973        CALL SITE 4 of 5 — THE SVSwitch SITE
src/TaskFuncEmit.cpp:4966    CALL SITE 5 of 5 — unwrapped subroutine body
```

Surelog does not delete the construct: it builds an assignment with **neither
`vpiLhs` nor `vpiRhs`** (`vpiOpType 82`, `vpiBlocking 1`) and whether that object
survives depends entirely on the slot it lands in. That is why this is a
LIST-APPEND test and not an "emit nothing, ever" test — and it is why the `if` /
`while` / `foreach` / `case_item` rows below must NOT fire.

**Read the SYNTAX, not the bound AST.** An implicit class-property reference is a
`MemberAccess` on an implicit `this` in slang, so the AST cannot tell `d` from
`this.d`. The predicate walks `ScopedNameSyntax` down to its root and requires
`ThisHandle` or `SuperHandle`; a bare name is an `IdentifierName` and never a
`ScopedName`, which is exactly what keeps `d = new[3]` (golden KEEPS it) out.

---

## 4. THE ARMS — 5 files, 55 cells, every boundary measured

`svsall.sh` runs a1–a4 (45 cells) and prints one row per cell; `svsarm.sh` +
`svsnest.cpp` cover a5. LHS is ALWAYS golden throughout.

### 4.1 What the gate is NOT (arm a1, 10 cells) — the natural experiment

`SVSwitch/Packet.sv` holds two ADJACENT methods of ONE class with one `new[…]`
each, and golden treats them differently:

```
line 71  byte_pack    bytes = new[data.size + 4];        golden KEEPS it
line 87  byte_unpack  this.data = new[bytes.size - 4];   golden DROPS it
```

| cell | written | golden | reading |
| --- | --- | --- | --- |
| m1 | `loc = new[3]` (local) | KEEPS | not "a `new[]` assignment" |
| m2 | `bytes = new[d.size+4]` (ref formal) | KEEPS | the byte_pack shape |
| m3 | `d = new[3]` (BARE property) | KEEPS | **not "a class-property lvalue"** |
| m7 | `d = new[bytes.size-4]` (bare, exact size expr) | KEEPS | not the size expression |
| m6 | `h.d = new[3]` (another object) | KEEPS | **not "a member-select lvalue"** |
| m4 | `this.d = new[3]` | **DROPS** | the byte_unpack shape |
| m5 | `this.d = new[e.size+4]` | **DROPS** | |
| m8 | `this.d = new[7]` (constant size) | **DROPS** | no query needed |
| m9 | `this.h = new()` (class handle) | **DROPS** | **not about `new[]` at all** |
| m10 | `this.s = 5` (non-`new` RHS) | KEEPS | the other half is load-bearing |

m3 vs m4 is the whole discriminator: the SAME property, spelled two ways.

### 4.2 The two halves, separately (arm a2, 13 cells)

`n1` `this.d = e` and `n2` `this.h = g` — this-LHS, non-`new` RHS — are **KEPT**,
so the RHS half is required. `n3` `this.h.d = new[3]` (deeper this-path), `n4`
`this.d = new[3](e)` (the copy form) and `n5` `super.d = new[3]` all **DROP**, so
the gate is the path ROOT keyword and `super` behaves as `this`. `n12`
(`d = new[3]` beside `this.s = 1`) is the control and is KEPT.

### 4.3 STATEMENT POSITION (arms a3/a4/a5) — the boundary the law lives or dies on

| position | golden | predicate |
| --- | --- | --- |
| element of a statement list | OMITS | **fires** (a2 n10/n11, a3 p9/p10) |
| sole element of an EXPLICIT begin | OMITS, begin survives **n=0** | **fires** (a3 p4) |
| statement list of a `fork` | OMITS, fork survives **n=0** | **fires** (a3 p8, a5 r3) |
| whole body of a plain function/task | no `vpiStmt` at all | **fires** (a1 m4/m8/m9, a2 n3/n4/n5/n8, a3 p1/p3) |
| nested TWO list levels deep | OMITS | **fires** (a4 q8, a5 r4/r5) |
| sole branch of an `if` | KEEPS the empty assignment | must NOT fire (a2 n6) |
| sole body of a `while` | KEEPS | must NOT fire (a3 p5) |
| sole body of a `foreach` | KEEPS | must NOT fire (a3 p6) |
| a `case_item`'s statement | KEEPS | must NOT fire (a3 p7) |
| **a constructor's OWN statement list** | **KEEPS** | **must NOT fire** (a2/a3/a4 `new`, a5 `ctorplain::new`) |

Golden's `fork_stmt` and explicit `begin` both survive with `BLOCK n=0`, measured:

```
$ svsnest … work@solo p8          $ svsnest … work@solo p4
A(golden) task a3:60:3-64:10      A(golden) function a3:40:3-44:14
  fork_stmt a3:61:5-63:9 [BLOCK n=0]  begin a3:41:5-43:8 [BLOCK n=0]
```

### 4.4 The full a1–a4 table, pristine → shipped

`ONLY` = the statement LISTS are different lengths (this pass's cell).
Totals over the 45 cells:

| arm | pristine | shipped |
| --- | --- | --- |
| a1 head depth / dump ± | 69 / 183 | **46 / 36** |
| a2 head depth / dump ± | 79 / 370 | **25 / 106** |
| a3 head depth / dump ± | 69 / 387 | **25 / 123** |
| a4 head depth / dump ± | 2920 / 417 | **2322 / 118** |
| cells with `ONLY` > 0 | **17** | **0** |
| cells that regressed EQ→DIFFER or SAME→MISMATCH | — | **0** |

Every length mismatch cleared. The cells that stay `DIFFER` are the ones where
the predicate correctly does NOT fire and golden's **empty assignment** is a
separate, unfixed law (residue **R2**): a1 m6, a2 n6/n7/`new`, a3 `new`/p5/p6/p7,
a4 `new`. Three cells went DIFFER→**EQ** purely from nested behaviour — a3 p8
(fork), a3 p11 (begin inside an `if`), a4 q8 (two list levels) — which is the
nested walk matching golden without a call site of its own.

### 4.5 ARM a5 — THE GAP THE OTHER FOUR ARMS LEFT OPEN, and it REFUTES the shipped comment

This arm exists because of a source reading, not the brief. The constructor
exception is enforced in only two places, and **neither covers a nested block**:
call site 5 tests `!tfBodyCtor27`; call sites 3/4 are unreachable for a
constructor because `emitStmt` diverts at
`if (tfBodyCtor27 && tfBodyStmt9 == (const void*)&stmt) return emitCtorBody27(…)`
— but that names the **top-level body statement only**, and `emitCtorBody27`'s
`EK_FSN` case recurses straight back into `emitStmt`:

```cpp
case EK_FSN:
    if (auto* u = emitStmt(*el[i].st, sparent, prefix, netMap))
        stmts->push_back(u);
    break;
```

Call sites 1 and 2 have **no constructor gate at all**, so a drop written inside
an explicit block inside a constructor reaches them and fires. An earlier draft of
the shipped comment said the exception was **"ANYWHERE INSIDE A CLASS
CONSTRUCTOR"**. If that had been true, this law would over-fire on every
uvm-1.2 constructor that wraps its body in a `begin/end`. It is not true:

```
$ svsnest … work@ctornest new        # function new(int k); s=k; begin this.d=new[3]; s=2; end
A(golden)  begin [BLOCK n=2]
             assignment a5:36:5-36:10
             begin a5:37:5-40:8 [BLOCK n=1]
               assignment a5:39:7-39:12        <-- only `s = 2`; golden DROPPED the new
B(pristine) begin a5:37:5-40:8 [BLOCK n=2]     BLOCK[1] golden=1 ours=2  *** N MISMATCH ***
B(shipped)  begin a5:37:5-40:8 [BLOCK n=1]     BLOCK[1] golden=1 ours=1  n-ok
```

**One block level down, golden drops it exactly as it does outside a
constructor.** So the ungated call sites 1/2 are CORRECT, gating them would have
re-broken this cell, and the exception is the constructor's **own list** only.
The comment at `src/StmtEmit.cpp:538` now says that, names a5 as the refutation,
and names the two mechanisms that actually implement it — **the stated gate is
now the gate in the code**, which is the standing law this campaign has shipped
violations of three times.

| a5 cell | written | pristine | shipped |
| --- | --- | --- | --- |
| r1 `ctornest::new` | ctor, drop in a NESTED begin | MISMATCH | **MATCH** |
| r2 | drop in a begin inside an `if` | MISMATCH | **MATCH** |
| r3 | drop inside `fork`/`join` | MISMATCH | **MATCH** |
| r4 | drop sole content of a nested begin | MISMATCH | **MATCH** |
| r5 | plain function, nested begin | MISMATCH | **MATCH** |
| r7 | CONTROL: nested begin, NO drop | MATCH | MATCH (unchanged) |
| `ctorplain::new` | CONTROL: ctor's OWN list | MATCH | MATCH (**correctly not fired**) |

5 correct fires, 2 controls unmoved, **0 over-fires**. Arm a5 head depth
162 → 25, dump ± 220 → 55.

---

## 5. REFUTATIONS THIS PASS OWES ITS BRIEF

**5.1 — The span law is not the head.** §1: 233 Compare methods, 0 span reads.
The brief called it *"likely THE law behind this head"*; it cannot be any head.

**5.2 — "`new[…]` / dynamic array" is a coincidence of the corpus site.** The
brief framed the site as a const-ref dynamic-array question. `new()` on a class
handle drops identically (a1 m9, a4 q9), and `new[…]` on a bare property does not
drop at all (a1 m3/m7). The independent UVM corroboration is
`uvm_vreg.svh:779`, `this.atomic = new(1);` — a class `new` **with an argument**,
in an ordinary method, which golden also drops (§6.3). A comment-only edit was
also confirmed not to change the binary: appending a comment to the pristine
`src/StmtEmit.cpp` and rebuilding reproduced md5
`663899bcad3b7696f1d3f9fa972ec085` exactly.

**5.3 — My own build-dependence hypothesis was WRONG, and the arm that killed it.**
GATE 5 reported 12 finding-shapes on `testflags/SeqDriver`, all
`uvm_reg_data_t`/`uvm_reg_addr_t` typespec-alias shapes — the exact signature of
the recorded "alias population is build-dependent" note. Rather than cite it, it
was tested: a **law-off arm** (predicate forced `false`, all five call sites still
compiled in, md5 `4bcce04afe5a975f54a76da6e2f5708e` — a genuinely different
binary layout) produced a SeqDriver database **byte-identical** to the pristine
binary's. Binary layout alone therefore causes none of it, so the churn was
really the law. The true explanation is §6.2, and it is a different mechanism.

**5.4 — The shipped comment overstated the constructor gate.** §4.5. Found by
reading the call sites against `emitCtorBody27`, refuted by arm a5, comment fixed
before landing.

---

## 6. THE GATES

### GATE 1 — build, with the link line and a SEPARATE md5 assertion

```
$ cmake --build /…/worktrees/r10svs3/build -j 3
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm
$ md5sum build/slang-uhdm            # SEPARATE command
d1ccd848dd088a9b37918cb944336423     # 32 hex, CHANGED from 663899bc…
```

Both worktrees were configured and built from scratch by this agent with an
absolute build path, and `Linking CXX executable slang-uhdm` was waited for in
the output of each (a build that compiles nothing still exits 0). Baseline md5
present and well-formed (32 hex chars). **PASS.**

### GATE 2 — goldens 23/0, and the harness proven live

```
$ SLANG_UHDM=<shipped> bash tests/check_goldens.sh   ->  PASS=23  FAIL=0
$ SLANG_UHDM=/bin/false bash tests/check_goldens.sh  ->  PASS=0   FAIL=23
FAIL AssignSumOfConstants (diff …/tests/golden/AssignSumOfConstants.dump /tmp/…/slang.dump)
```

23 PASS / 0 FAIL, and 0 PASS / 23 FAIL with `/bin/false`. **PASS.**

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`

```
[testflags] 731 tests
  CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
dump: 496 match / 183 differ / 52 blank
```

Whole-row judge against the committed baseline via `r10oth8repro/ct8rows.sh`:

```
baseline: 732 lines = 731 ROWS (the header is not a row)
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

679 / 50 / 2, dump 496 / 183 / 52, **0 differing rows**. **PASS.**

### GATE 4 — surelog, `--mode both`, `--jobs 2`

| mode | CMP_EQUAL | CMP_NOTEQUAL | DEFERRED | dump match |
| --- | --- | --- | --- | --- |
| default | **467** | **13** | 5 | **225** |
| testflags | **463** | **10** | 5 | **165** |

```
baseline: 1589 lines = 1588 ROWS
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
PASS: every row byte-identical to the committed baseline
```

`GOLDEN_DEFER` left at default (5 DEFERRED both modes). **0 differing rows.**
**PASS.**

### GATE 5 — BYTE VERIFIER, both corpora, against a pristine tree built here

`r10oth6repro/byteverify.sh` with both negative controls, patched vs pristine:

```
=== u2r corpus ===                        === surelog corpus ===
databases: patched=679 pristine=679       databases: patched=953 pristine=953
PATH_SETS_IDENTICAL (679 paths)           PATH_SETS_IDENTICAL (953 paths)
MOVERS: 0 / 679                           MOVERS: 9 / 953
SELFCHECK: 678 / 679 flagged              SELFCHECK: 952 / 953 flagged
SELFCHECK1: 1                             SELFCHECK1: 10   (9 real + 1 corrupted)
```

Both controls behaved on both corpora, so a "no movers" reading here is not a
mis-lined-up comparison. **u2r: 0 movers** — the law fires nowhere in that
corpus. The 9 surelog movers:

| mover | REMOVED | ADDED |
| --- | --- | --- |
| default/SVSwitch, testflags/SVSwitch | 54 | 0 |
| default/BuildUVMPkg, testflags/BuildUVMPkg | 70 | 0 |
| default/SimpleUVM, testflags/SimpleUVM | 70 | 0 |
| default/Scoreboard | 70 | 0 |
| default/SeqDriver | 140 | 0 |
| testflags/SeqDriver | 160 | 20 |

#### 6.1 Per-shape attribution, ADDED and REMOVED reported separately

`svsmovers.sh` looks EVERY changed dump line up in GOLDEN with a per-shape
`grep -Fxc`, indentation KEPT. Eight of the nine movers are REMOVED-only with
**every** removed shape at `golden=0` — we stopped emitting objects golden lacks,
which is pure convergence and zero findings. The ninth,
`testflags/SeqDriver`, reported **12 finding-shapes**, and they are resolved in
§6.2 rather than summarised away.

For SVSwitch — the target — the attribution is exact. A **3-way** census
(golden / pristine / patched) was added, because `svsmovers.sh`'s rule *"a REMOVED
line golden HAS is a finding"* is a heuristic that misreads any shape occurring
many times: what matters is whether OUR count moved toward golden's.

```
golden=0   pristine=1  patched=0   CONVERGED   \_assignment: , line:87:3, endln:87:34
golden=0   pristine=2  patched=0   CONVERGED   \_hier_path: (this.data), line:87:3-87:7
golden=0   pristine=2  patched=0   CONVERGED   \_hier_path: (bytes.size), line:87:19-87:29
golden=0   pristine=1  patched=0   CONVERGED   \_method_func_call: (new), line:87:15-87:34
golden=0   pristine=1  patched=0   CONVERGED   |vpiName:this.data
golden=7   pristine=8  patched=7   CONVERGED   \_begin: (work@packet::byte_unpack), 84:3-84:22
golden=33  pristine=34 patched=33  CONVERGED   |vpiBlocking:1
golden=59  pristine=60 patched=59  CONVERGED   |vpiLhs:  /  |vpiRhs:  /  |vpiOpType:82
golden=35  pristine=37 patched=35  CONVERGED   |vpiOperand:
```

Every shape owned by the removed statement goes to `0` where golden has `0`, and
**the head itself lands exactly on golden: `\_begin: (work@packet::byte_unpack)`
7 vs 8 → 7.** ADDED = 0.

A handful of generic, depth-keyed property lines (`|vpiParent:`, `|vpiActual:`,
`|vpiStmt:`, `|UINT:1`) are scored "diverged" by the distance metric. They are
not law-owned shapes: we sit far BELOW golden on those aggregates because
SVSwitch still has residue **R1** open, and removing 1–6 lines we are already
hundreds short of moves the distance the "wrong" way while changing nothing about
this law. Stated rather than netted, per the standing rule.

#### 6.2 ~~THE 12 FINDINGS — parallel-parse nondeterminism on the PRISTINE side, proven~~ — **THE DIAGNOSIS BELOW IS WRONG (verifier FINDING 1); read this box, not §6.2**

> **MASTER'S CORRECTION AT INTEGRATION.** The verifier re-measured and refuted
> this section's causal story: BOTH binaries are perfectly deterministic on
> `testflags/SeqDriver` (3 isolated runs each reproduce their own sweep DB byte
> for byte — pristine `00c280fa…` ×3, patched `e4effe1d…` ×3), so there is no
> "parallel-parse nondeterminism on the pristine side". The 20 ADDED / 20 of the
> REMOVED lines are a **PURE RELOCATION** — identical multisets (`bit_typespec
> (uvm_reg_addr_t)` 691/691, `(uvm_reg_data_t)` 689/689, `range` 190/190 and
> 259/259, …), `msdist.sh` distance **140 = exactly the same 140-line removal as
> `default/SeqDriver`** — i.e. the law's own effect plus a position shift of
> equal-content alias lines. **§6.2's law-off control was insensitive to the
> hypothesis it rejected** (forcing the predicate false allocates the same
> objects as pristine, so a byte-identical DB was guaranteed either way).
>
> ON THE MECHANISM, the master endorses NEITHER agent's wording: the verifier
> attributes the relocation to "pointer-keyed std::map iteration (the memory
> note)", but that note was itself REFUTED by r10det1 for pure ADDRESS
> perturbation (an env-guarded heap pad that provably permuted the address
> order moved nothing — `tools/probe/r10det1repro/`). Both experiments stand
> together as: address order alone does NOT reach the database, and a SEMANTIC
> code change CAN relocate equal-multiset alias lines through emission-order
> effects downstream of the change. The precise carrier of that reordering is
> UNPROVEN. What matters operationally: judge movers by MULTISET and per-shape
> counts (`msdist.sh`, fixed at 7c7eaa6), never by `diff -u` line counts —
> which is also the correction to residue R3 below (its "verifier cannot
> distinguish a law from nondeterminism" premise is false; the real limitation
> is that `diff -u` is alignment-sensitive, and the fix already exists).

All 12 were `uvm_reg_data_t`/`uvm_reg_addr_t` `bit_typespec` / `ref_typespec` /
`range` / `vpiName` / `vpiFullName` shapes in ONE mover. Three measurements
resolve them, and none of them is a citation:

1. **Serial determinism, both binaries.** `r10uvm55repro/detcheck.sh` on
   SeqDriver testflags: pristine 4 runs → **1 distinct hash**
   (`9d0a79aafa6c29d2`, 17981993 bytes); shipped 3 runs → **1 distinct hash**
   (`3697218dafb94e05`, 17980243 bytes). Neither binary is nondeterministic when
   run alone. (The instrument's `NO_OUTPUT` guard also fired correctly first,
   from the wrong cwd, and was not mistaken for "all identical".)
2. **The sweep's pristine database disagrees with the serial one.**

   | SeqDriver testflags | md5 | bytes |
   | --- | --- | --- |
   | pristine, sweep at `--jobs 2` | `00c280fa05a9` | 17981993 |
   | pristine, serial ×4 | `64ac9f4f592c` | **17981993** |
   | shipped, sweep at `--jobs 2` | `e4effe1d96ea` | 17980243 |
   | shipped, serial ×3 | `e4effe1d96ea` | 17980243 |

   **Identical byte size, different content** — the equal-size content flip of the
   recorded "SourceLocation compares across macro buffers flip per run under
   parallel parse" note. The pristine side of that one comparison was an unstable
   reference; the shipped side happened to land the same way both times.
3. **The clean serial pair has no findings at all.** Re-attributing
   `testflags/SeqDriver` on the two deterministic serial databases:

   ```
   SeqDriver testflags, SERIAL pair:  REMOVED=140  ADDED=0
   golden=0  pristine=2   patched=0    CONVERGED   \_assignment: , line:779:4, endln:779:24
   golden=0  pristine=6   patched=0    CONVERGED   \_hier_path: (this.atomic), line:779:4-779:8
   golden=0  pristine=3   patched=0    CONVERGED   \_ref_obj: (this), line:779:9, endln:779:15
   golden=0  pristine=3   patched=0    CONVERGED   |vpiName:this.atomic
   golden=8  pristine=10  patched=8    CONVERGED   \_begin: (adpcm_pkg::uvm_vreg::configure)
   golden=4  pristine=5   patched=4    CONVERGED   \_begin: (uvm_pkg::uvm_vreg::configure)
   ```

   **ADDED=0**, the 20 added lines and all four "golden HAS this removed line"
   `bit_typespec` shapes are gone, and both `\_begin:` counts land **exactly** on
   golden. The 140 removed lines are the same count as `default/SeqDriver`, which
   was clean all along.

**GATE 5 verdict: 9 movers, 0 real findings, ADDED=0 on every deterministic
pair.** The verifier limitation this exposed is filed as residue **R3**.

#### 6.3 The UVM site, which corroborates the law independently

`~/git-repos/Surelog/third_party/UVM/uvm-1.2/src/reg/uvm_vreg.svh:779`:

```systemverilog
   this.parent.add_vreg(this);

   this.atomic = new(1);
endfunction: configure
```

A `this.<member> = new(<arg>)` in an ordinary method (not a constructor), which
golden drops exactly as it drops `Packet.sv:87` — a different file, a different
`new` form, the same law. This is what the four UVM movers are.

### CANARIES

| check | corpus | result |
| --- | --- | --- |
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=6` | u2r | `ok=1 changed=0 absent=0 unknown-patterns=6` PASS |
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=1` | surelog | `ok=58 changed=0 absent=0 unknown-patterns=1` PASS |
| **`tools/probe/r10uvm52repro/canaries.sh`** | u2r | `ok=8 changed=0 absent=0` |
| **`tools/probe/r10uvm52repro/canaries.sh`** | surelog | `ok=52 changed=0 absent=0` |
| `r10uvm55repro/canaudit.sh` | — | `audited=29 UNCOVERED=0 FENCE-BREACH=0` PASS |

The canary script is named explicitly because **six files share that basename**
(`r10uvm50`…`r10uvm55`); the one run here is `r10uvm52repro/canaries.sh`.
All `changed=0 absent=0`. `canaudit.sh` also confirms the four slang-fenced names
(`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) are dispatched by
no driver here — they were never measured by this pass.

**BY NAME, as the brief requires:**

```
InterfaceModPort   base: CMP_EQUAL/differ  CMP_EQUAL/differ   mine: IDENTICAL
BlackParrotComplex base: CMP_EQUAL/differ  CMP_EQUAL/differ   mine: IDENTICAL
```

**SVSwitch, quoted from this agent's own sweep — it did NOT convert:**

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

Identical to the committed baseline, so there is nothing to promote and
`results/*.csv` was read and never written.

---

## 7. RANKED RESIDUE

**R1 — SVSwitch's next head: `hier_path` extent on an indexed `this.<member>`
inside `foreach`.** *Highest value: it is the only thing between SVSwitch and
CMP_EQUAL, and it is now the sole head at 78 cmp lines.*

```
LHS (golden): hier_path: (this.data),    id:2431, line:122:29, endln:122:41
RHS (ours):   hier_path: (this.data[i]), id:1829, line:122:29, endln:122:41
```

`Packet.sv:122` is `foreach(this.data[i])`. Golden names the hier_path
`this.data` and keeps the index elsewhere; we fold `[i]` into the path name, and
our child `ref_obj: (this)` span is `122:29-122:33` against golden's
`122:34-122:38`. A `vpiName`/child-extent question on the foreach loop variable,
NOT a statement-list question. Bounded and local.

**R2 — golden's EMPTY assignment (`vpiOpType 82`, no `vpiLhs`, no `vpiRhs`).**
*Second: it is the other half of THIS law and the arms already isolate it in 9
cells.* Where the drop is the sole statement of an `if` / `while` / `foreach` /
`case_item`, or anywhere in a constructor's own list, golden emits an assignment
with both operands missing and we emit a full one. Cells a2 n6/n7, a3 p5/p6/p7,
a2/a3/a4 `new`, a1 m6. This is a *construction* law, not a list law, so it needs
its own predicate at the assignment builder — deliberately NOT merged here.

**R3 — ~~the byte verifier cannot distinguish a law from parallel-parse
nondeterminism~~ RE-SCOPED AT INTEGRATION (verifier FINDING 2): the premise is
FALSE — there was no nondeterminism (§6.2 correction box). The real, standing
limitation is that `diff -u` is ALIGNMENT-SENSITIVE and can present a pure
relocation as ADDED+REMOVED lines; the fix already exists and is already
mandated: judge movers by MULTISET (`msdist.sh` @7c7eaa6) and per-shape counts.
`svs3way.sh` below remains useful as a 3-way census, but it is not the fix for
the problem R3 originally named — a next pass hunting "nondeterminism" from this
entry would be hunting a phantom.** `byteverify.sh` and
`svsmovers.sh` compare sweep workdirs produced at `--jobs 2`; for UVM tests the
pristine side can flip content at constant byte size (§6.2). Two fixes, both
cheap: attribute movers on **serial** re-runs, and add the **3-way**
(golden/pristine/patched) census used in §6.1 so a many-occurrence shape is
judged by whether OUR count moved toward golden rather than by golden's count
alone. **`svs3way.sh` in this directory is that census**, shipped with the traps
in its header; `svsmovers.sh` is left unchanged so the two readings stay
comparable, and its heuristic is documented as such rather than silently patched.
On SVSwitch's 44 changed shapes it reports `CONVERGED=40 DIVERGED=4 UNCHANGED=0`,
the 4 being the generic depth-keyed aggregates named above.

**R4 — the function-span policy (dump-only, phase 3).** *Lowest for cmp, but the
measurement is already done.* Golden ends a class method's `function` span at the
qualifier keywords, ours at the body end. **cmp-INVISIBLE** (§1), so it can never
move a row; it is a dump-diff contributor only. Arm a4 already carries the
qualifier matrix — q3 `virtual`, q4 plain, q5 `static`, q6 `task`, q7 `extern`
out-of-body, q10 `protected virtual` — so the next pass inherits the arms. Blast
radius is every function in every design; do not start it without a cmp reason.

**R5 — `NewCovergroupExpression` is deliberately out of the predicate.** No arm
measured it and a covergroup handle is not assignable through `this.` anywhere in
this corpus, so it is excluded rather than assumed to behave like the other two
`new` kinds. If a covergroup site ever appears, measure it before widening.

---

## 8. REPRODUCING

```bash
cd <worktree> && cmake --build build -j 3     # wait for "Linking CXX executable slang-uhdm"
md5sum build/slang-uhdm                        # SEPARATE command

tools/probe/r10svs3repro/svsbuild.sh svsstmts  # -> /tmp/r10svs3_svsstmts
tools/probe/r10svs3repro/svsbuild.sh svsnest   # -> /tmp/r10svs3_svsnest
tools/probe/r10svs3repro/svsgen.sh  /tmp/out <slang>          # the SVSwitch pair, both modes
tools/probe/r10svs3repro/svsall.sh  /tmp/arms <slang>         # arms a1-a4, 45 cells
tools/probe/r10svs3repro/svsarm.sh  tools/probe/r10svs3repro/a5_ctornest.sv /tmp/a5 <slang>
/tmp/r10svs3_svsnest <golden.uhdm> <ours.uhdm> work@ctornest new   # the a5 r1 refutation
```

```bash
# GATE 5 attribution, the way §6.1/§6.2 did it:
tools/probe/r10svs3repro/svsmovers.sh <patched_wd> <pristine_wd>   # read R3 FIRST
diff -u <pristine.dump> <patched.dump> | grep '^-' | grep -v '^---' | cut -c2- |
  sort -u | tools/probe/r10svs3repro/svs3way.sh <g.dump> <p.dump> <a.dump>
```

Prefer **serial** re-runs of both binaries as `svs3way.sh` inputs for UVM tests;
a `--jobs 2` sweep workdir can flip content at constant byte size (residue R3).

Files: `svsbis.cpp` is the generic VPI bisector carried from `r10earl17c` (kept
for the next pass; the localization in §2 did not need it once
`begin::Compare` was read and `svsstmts.cpp` could read the list directly).
