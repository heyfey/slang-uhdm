# r10svs3 — ADVERSARIAL VERIFICATION

**VERDICT: PASS.** The patch is sound, every gate reproduces, and the localization is
correct. Two findings are against the **write-up**, not the code: the implementer
mis-diagnosed the `testflags/SeqDriver` mover and shipped a residue (R3) built on that
wrong diagnosis. No finding touches the shipped predicate or any gate number.

I did not trust the implementer's worktree, binary, scripts or arms. I created my own
worktrees, applied `/tmp/r10svs3.patch` to a fresh `266d3a6`, built both sides myself,
wrote my own localization instrument, my own mover-attribution instrument, and my own
43-cell arm set, and re-ran all five gates end to end.

---

## 0. PROVENANCE — every binary, its BASE COMMIT and its md5

`git -C <wt> rev-parse --short HEAD` and `md5sum` for each binary I compared:

| binary | BASE | md5 | mine vs theirs |
| --- | --- | --- | --- |
| main tree `build/slang-uhdm` | `f3083f0`¹ | `663899bcad3b7696f1d3f9fa972ec085` | — |
| **my pristine**, built from scratch | **`266d3a6`** | `663899bcad3b7696f1d3f9fa972ec085` | **= their pristine** |
| **my patched**, from the patch alone | **`266d3a6`** | `d1ccd848dd088a9b37918cb944336423` | **= their shipped** |
| their worktree `r10svs3/build` | `266d3a6` | `d1ccd848dd088a9b37918cb944336423` | — |
| their `r10svs3pris/build` | `266d3a6` | `663899bcad3b7696f1d3f9fa972ec085` | — |

¹ `f3083f0` is `266d3a6` plus probe-only commits; its binary is byte-identical to the
`266d3a6` build, which is why the pristine md5 matches it.

**The strongest provenance result available: applying the patch to a clean `266d3a6`
and building it independently reproduces the shipped md5 `d1ccd848…` bit-for-bit.**
The patch and the binary every gate number came from are the same artefact. Their
claim "the binary matches the shipped source" is confirmed, not taken on trust.

md5 asserted CHANGED in a command separate from the build: `663899bc…` → `d1ccd848…`,
both 32 hex chars, neither missing nor malformed.

---

## 1. FIVE GATES — mine beside theirs

| gate | theirs | **mine** | |
| --- | --- | --- | --- |
| 1 build | link line waited for, md5 changed | `grep -c "Linking CXX executable slang-uhdm"` = **1** in each of my two build logs, `BUILD_RC=0`, absolute `-B` path, md5 asserted separately | ✅ |
| 2 goldens | 23 PASS / 0 FAIL; `/bin/false` 0/23 | **23 PASS / 0 FAIL** (rc 0); `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** (rc 1) | ✅ |
| 3 u2r testflags | 679 / 50 / 2; dump 496/183/52; 0 rows | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; `ct8rows.sh` **0 differing ROWS (0 diff row-sides)**, "PASS: every row byte-identical" | ✅ |
| 4 surelog both | default 467/13, testflags 463/10, dump 225/165, 0 rows | default **467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED**, testflags **463 / 10 / 5**, dump match **225 / 165**, `ct8rows.sh` **0 differing ROWS** | ✅ |
| 5 byte verifier | u2r 0/679; surelog 9/953; controls 678/952, 1/10 | u2r **MOVERS: 0 / 679**, SELFCHECK **678 / 679**, SELFCHECK1 **1**; surelog **MOVERS: 9 / 953**, SELFCHECK **952 / 953**, SELFCHECK1 **10**; `PATH_SETS_IDENTICAL` both | ✅ |

`GOLDEN_DEFER` left at default (5 DEFERRED both modes). Sweeps at `--jobs 2` with my own
`--out`/`--workdir`. `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` never
dispatched — `canaudit.sh` confirms all four are "not dispatched by any driver (OK)".

I also ran the **pristine** binary through the full surelog sweep and put it through the
row judge: `0 differing ROWS` against the committed baseline. So both sides of Gate 5 are
anchored to the authoritative CSVs, not just to each other.

**Canaries** — all reproduced exactly:

```
u2r      ctcan2 (EXPECT_UNKNOWN=6): ok=1  changed=0 absent=0 unknown-patterns=6   PASS
surelog  ctcan2 (EXPECT_UNKNOWN=1): ok=58 changed=0 absent=0 unknown-patterns=1   PASS
u2r      r10uvm52repro/canaries.sh: ok=8  changed=0 absent=0
surelog  r10uvm52repro/canaries.sh: ok=52 changed=0 absent=0
canaudit.sh: audited=29  UNCOVERED=0  FENCE-BREACH=0
```

`InterfaceModPort` and `BlackParrotComplex` **by name**, baseline vs my fresh CSV — both
are surelog-corpus rows and both are byte-identical:

```
base:  InterfaceModPort,default,CMP_EQUAL,,,differ      fresh: (identical)
base:  InterfaceModPort,testflags,CMP_EQUAL,,,differ    fresh: (identical)
base:  BlackParrotComplex,default,CMP_EQUAL,,,differ    fresh: (identical)
base:  BlackParrotComplex,testflags,CMP_EQUAL,,,differ  fresh: (identical)
```

**SVSwitch did NOT convert**, quoted from my own sweep `/tmp/r10svs3v_sl.csv`:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

identical to `results/golden_surelog.csv`. Nothing to promote; `results/` never written.

---

## 2. PATCH SCOPE — asserted, full output

`git apply --stat` (complete, untruncated): **18 files**, `2318 insertions(+), 2 deletions(-)`
— `include/UhdmExporter.h` (4), `src/StmtEmit.cpp` (149), `src/TaskFuncEmit.cpp` (14),
and 15 files under `tools/probe/r10svs3repro/`. `git apply --check -v` clean on a fresh
`266d3a6`, `CHECK_RC=0`.

```
$ git status --short results/ scripts/ tests/     # BEFORE apply
(empty)
$ git status --short results/ scripts/ tests/     # AFTER apply
(empty)
$ git diff --name-only 266d3a6 | grep -v '^(include/UhdmExporter.h|src/StmtEmit.cpp|src/TaskFuncEmit.cpp)$'
(empty)
```

No `results/*.csv`, no `scripts/verify_golden.py`, no `tests/check_goldens.sh`, no slang
header. `include/UhdmExporter.h` is the emitter's own header, which the ops rules permit.
md5 of the patch: `880eb4b207423f86df256e3be2b902f8` — matches the claim.

**r10uvm58 boundary respected.** The entire production diff is 24 lines of predicate plus
5 call sites. Grepping every added production line for
`Return\(|ret_var|int_var|ref_var|VpiSigned|setLoc|VpiLineNo|VpiEndLineNo|Typespec\(`
returns **nothing**. No return-variable object of a class method is touched, and no span
code was written at all.

---

## 3. INDEPENDENT LOCALIZATION — I reach the SAME field, and I can prove it from source

Reproduced on my own binaries through the harness (`--filter '^SVSwitch$'`, both modes):

| | pristine | patched |
| --- | --- | --- |
| cmp HEAD DEPTH | **1512** (heads=1) | **78** (heads=1) |
| dump content ± (alignment-sensitive) | **2632** | **2578** |
| MULTISET distance (`msdist.sh` @7c7eaa6) | **1992** | **1950** |

All three of their headline numbers reproduce exactly, in both modes.

The pristine head is the briefed one:

```
LHS: begin: (work@packet::byte_unpack), id:2288, line:84:3, endln:84:22
     \_function: (work@packet::byte_unpack), id:2278, line:82:1, endln:82:8
RHS: begin: (work@packet::byte_unpack), id:1690, line:84:3, endln:84:22
     \_function: (work@packet::byte_unpack), id:1680, line:82:1, endln:93:26
```

**A structural proof they did not give.** `begin::Compare` (UHDM
`build/generated/src/begin.cpp`) compares `basetype_t::Compare` then
`SafeCompare(lhs, lhs->Stmts(), rhs, rhs->Stmts(), context)`. The vector overload in
`templates/BaseClass.h:202` is:

```cpp
if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
  context->m_failedLhs = lhs_obj;      // <-- the PARENT, not an element
  context->m_failedRhs = rhs_obj;
  return 1;
}
```

A **list-length mismatch attributes the failure to the owning object**. A head that *is*
the `begin`, with `VpiName` equal on both sides, is therefore the signature of a
`Stmts()` size mismatch and of nothing else. 1512 was head depth, exactly as the brief warned.

Then the direct measurement, with my own dump-walking census (`vpiStmt` children at own
child depth, indentation-derived, independent of their `svsstmts.cpp`):

| `begin: (work@packet::byte_unpack)` 84:3-84:22 | elements |
| --- | --- |
| **golden** | **7** — 83:3, 84:3, 85:3, 86:3, foreach 88:3, 90:3, if 91:3 |
| ours **pristine** | **8** — the same plus `assignment 87:3-87:34` |
| ours **patched** | **7** — element list identical to golden's |

`Packet.sv:87` is `this.data = new[bytes.size - 4];`. **Same field, same cause, same
element. Their localization is confirmed, not merely plausible.**

### The head that remains (their R1) — confirmed

```
LHS: hier_path: (this.data),    id:2431, line:122:29, endln:122:41
RHS: hier_path: (this.data[i]), id:1829, line:122:29, endln:122:41
```

Sole head, 78 lines. R1 is correctly identified and correctly ranked first.

---

## 4. THE SPAN QUESTION — the brief's leading hypothesis is REFUTED, independently

Re-derived from `~/git-repos/UHDM` myself:

```
$ cd ~/git-repos/UHDM/build/generated/src && grep -l "::Compare" *.cpp | wc -l
233
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiLineNo|VpiEndLineNo|VpiColumnNo|VpiEndColumnNo|VpiFile"
0
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiName\(\)"     # control
37
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiSigned\(\)"   # control
13
```

and I read the four classes the brief named, in full: `begin::Compare` → basetype +
`Stmts()`. `BaseClass::Compare` → `VpiType`, `VpiName`, `VpiDefName`, nothing else.
`function::Compare` → `VpiSigned`, `VpiSize`, `VpiFuncType`. `task_func::Compare` → the
method/visibility/DPI scalars plus `Left_range`, `Right_range`, `Return`, `Class_defn`,
`Io_decls`, `Stmt`, `Instance`. `scope::Compare` → `VpiName` plus its object lists.
**Not one line, column or file field anywhere.**

Spans are cmp-invisible. Golden ending a class method's `function` span at the qualifier
(`82:1-82:8`) can never be a cmp head. Declining to write a span policy was the right
call, and **not writing one is the single largest risk this pass avoided** — a setLoc
policy touches every function in every design for zero cmp movement. R4 is correctly
classified as dump-only phase-3 work.

---

## 5. EMPTY PRODUCT CELLS — I built 43 of them across 7 arm files. ZERO regressions, ZERO over-fires.

Axes of `§ thisSuperNewAssignNoStmt3`: (statement syntax kind) × (assignment operator) ×
(RHS `new` form) × (LHS path shape) × (statement position) × (subroutine kind / ctor-ness /
in-line vs out-of-line). Arms `a1..a5` cover the middle of that space; I built the edges.
My arms and instruments are at `/tmp/r10svs3v_arms/b{1..7}_*.sv`, `/tmp/r10svs3v_arm.sh`,
`/tmp/r10svs3v_3way.sh`, `/tmp/r10svs3v_cnt.py`, `/tmp/r10svs3v_att.sh`.

Verdicts are 3-way (golden / pristine / patched), keyed on span, indentation stripped.
`CONVERGED` = patched now equals golden. `STILL-DIFF` = unchanged pristine→patched and
still unequal (i.e. pre-existing residue, no regression). No cell anywhere came back
`**REGRESSION**`.

### 5.1 The discriminator, verified independently (arm b7)

One class, one property, two spellings, adjacent methods — head depth 69 → 17:

| cell | golden | pristine | patched | |
| --- | --- | --- | --- | --- |
| `d = new[3]` (implicit this) | 2 | 2 | 2 | KEPT, untouched |
| `this.d = new[3]` (written) | **0** | 2 | **0** | DROPPED, converged |
| `e = new[3]` (control) | 2 | 2 | 2 | untouched |

**The gate really is the written keyword.** Their `m3`/`m4` claim holds.

### 5.2 The two cells that are LIVE IN THE MEASURED CORPUS and that arms a1..a5 never built

A source census of both corpora plus the UVM tree turned up exactly three law sites in
`uvm-1.2/src` — and **two of them are shapes the shipped arms never measured**:

```
reg/uvm_vreg.svh:779          this.atomic = new(1);                      (measured by a1/a4)
reg/uvm_mem_mam.svh:658       this.default_alloc = new;                  BARE new, NO PARENS
reg/uvm_reg_backdoor.svh:271  this.m_update_thread[element] = new(...);  INDEXED this-path LHS
```

and `uvm_mem_mam.svh:658` sits inside `function uvm_mem_mam::new(...)` — an **out-of-line
constructor**, a third unmeasured axis. Arm b1 fills them:

| cell | golden | pristine | patched | verdict |
| --- | --- | --- | --- | --- |
| `this.h = new;` — BARE `new`, no parens (`uvm_mem_mam.svh:658`) | 0 | 3 | **0** | CONVERGED |
| `this.hq[k] = new(1)` — INDEXED, dynamic (`uvm_reg_backdoor.svh:271`) | 0 | 3 | **0** | CONVERGED |
| `this.haa[k] = new(1)` — INDEXED, associative | 0 | 3 | **0** | CONVERGED |
| `super.hq[k] = new(1)` — `super.` + indexed | 0 | 3 | **0** | CONVERGED |
| `super.h = new;` — `super.` + bare | 0 | 3 | **0** | CONVERGED |
| `this.d = new[4](this.d)` — copy form, this-path source | 0 | 2 | **0** | CONVERGED |
| element of a **labelled** `begin` | 0 | 2 | **0** | CONVERGED |
| whole body of a **task** | 0 | 2 | **0** | CONVERGED |
| inside `fork … join_none` | 0 | 2 | **0** | CONVERGED |
| `for` body / `else` branch / `repeat` body / `do-while` body | 1 | 2 | 2 | STILL-DIFF = R2, no regression |

The predicate lands on golden in all six unmeasured LHS/RHS shapes, and correctly declines
to fire in the four unmeasured *kept* positions. The four `STILL-DIFF` rows are R2 and R2
alone: the remaining head on that arm is `LHS: <null>` vs `RHS: method_func_call: (new)` —
golden's Lhs-less/Rhs-less assignment.

### 5.3 The begin-WRAPPER boundary — the cell I most expected to break (arm b3)

Our emitter decides the unnamed-`begin` wrapper on `eff9 > 1` **before** the drop
(`StmtEmit.cpp` ~2845), so a body of exactly two statements one of which is dropped yields
a `begin` with one element. Does golden wrap it? Nobody had asked.

| body | golden begin | ours begin | golden elems | pristine | patched |
| --- | --- | --- | --- | --- | --- |
| 2 stmts, ONE dropped | `15:5-15:11` | identical span | 1 | 2 | **1** |
| 2 stmts, **BOTH** dropped | `21:5-21:21` | identical span | **0** | 2 | **0** |
| 3 stmts, one dropped | `27:5-27:21` | identical span | 2 | 3 | **2** |
| local decl + drop | `34:5-34:21` | identical span | 1 | 2 | **1** |

All four land exactly on golden — including the empty-`begin` case, where golden keeps a
`begin` whose span comes from the *dropped* statement's line and we now do the same. This
axis was unmeasured and it is clean.

### 5.4 Constructor and out-of-line axes (arm b2), and the gate-in-code check

The shipped comment's constructor claim was already caught overstated once, so I checked
the code, not the comment. `StmtEmit.cpp:2809` — `if (tfBodyCtor27 && tfBodyStmt9 ==
(const void*)&stmt) return emitCtorBody27(...)` — sits inside `case StatementKind::List`
**above** call sites 3 and 4, and `emitCtorBody27`'s `EK_FSN` case pushes its element
unconditionally. So a ctor's own list element is never tested → KEPT; a nested block
inside a ctor recurses into the Block arm → call sites 1/2, ungated → DROPPED.
**Gate in code == gate in comment**, including the a5 correction.

| cell | golden | pristine | patched | verdict |
| --- | --- | --- | --- | --- |
| ctor body = ONE explicit `begin`, drop its only stmt | 0 | 2 | **0** | CONVERGED (unmeasured cell) |
| ctor body = ONE explicit `begin`, drop among others | 0 | 2 | **0** | CONVERGED (unmeasured cell) |
| ctor OWN list, after `super.new()` | 1 | 2 | 2 | R2, kept correctly |
| ctor OWN list, drop LAST | 1 | 2 | 2 | R2, kept correctly |
| ctor WITH PORTS, own list | 1 | 2 | 2 | R2, kept correctly |
| ctor with local decl then drop | 1 | 2 | 2 | R2, kept correctly |
| **extern** ordinary method, whole body | 0 | 2 | **0** | CONVERGED |
| **extern** method, drop as list element | 0 | 2 | **0** | CONVERGED |
| `c10::sd = new[3]` — class-scope LHS, must NOT fire | 0 | 2 | 2 | does not fire ✔ (see finding 4) |
| `this.d = new[this.mk()]` — `new` written, non-const arg | 0 | 2 | **0** | CONVERGED |

Arm b6 adds ctor element ordering and the last positions — named `fork` (0/2/**0**),
`begin` nested two levels down (0/2/**0**), `for` whose body *is* a `begin`
(0/2/**0**); `forever` body, `case` default item and a no-ports ctor's sole element all
`STILL-DIFF` = R2, unchanged.

**The out-of-line-constructor cell, priced on the real corpus rather than synthetically.**
My synthetic `extern function c8::new()` showed golden = 0 and ours = 2, which reads like an
under-fire — but it is confounded: for *every* extern method in that arm (`c7`, `c8`, `c9`)
ours emits an extra `function` object at the out-of-line definition span that golden does
not have at all, a pre-existing divergence unrelated to this law. On the **real** site,
`uvm_mem_mam.svh:658` inside `function uvm_mem_mam::new(...)` in `BuildUVMPkg`, golden
**does** have the out-of-line object and **does keep** the assignment there:

```
GOLDEN  \_assignment: , line:70583:4, endln:70583:28
          \_begin: (uvm_pkg::uvm_mem_mam::new)
          |vpiOpType:82   |vpiBlocking:1                      <-- EMPTY: no Lhs, no Rhs
OURS    \_assignment: , line:70583:4, endln:70583:28
          |vpiOpType:82   |vpiBlocking:1
          |vpiRhs: \_method_func_call: (new)                   <-- R2: we populate it
          |vpiLhs: \_hier_path: (this.default_alloc), 70583:4
```

The shipped `!tfBodyCtor27` gate keeps it, golden keeps it — **the behaviour is correct at
the live site**, and the residual delta is R2. The out-of-line axis is genuinely
unmeasured by the shipped arms, and it comes out clean.

### 5.5 The two RHS forms the predicate EXCLUDES, priced (arms b4/b5)

* **`NewCovergroupExpression` (their R5, "unmeasured").** Not a silent gap: the emitter
  *already* reports it as an unsupported construct. `slang-uhdm: unsupported constructs
  encountered: class property type: CovergroupType / expression kind: NewCovergroup`, and
  slang additionally refuses `this.cgv = new;` with `error: cannot assign to read-only
  variable 'cgv'`. R5 cannot silently produce a wrong database. It should be **downgraded**.
* **Non-blocking `this.d <= new[3]` — a STATED GATE, now EXECUTED.** The comment asserts
  "none of them can take a `new` on the right". Surelog's own grammar agrees:
  `[SNT:PA0207] b5_nb.sv:8:14: Syntax error: mismatched input 'new' expecting {…}` — `new`
  is not in the follow set of `<=`. The cell is unreachable, so requiring
  `AssignmentExpression` is exact, as claimed.

---

## 6. MOVER ATTRIBUTION — my own instrument, ADDED and REMOVED never netted

All 9 surelog movers reproduce with the same paths and the same md5 pairs. Per-shape 3-way
census (golden / pristine / patched), `grep -Fxc`, indentation stripped:

| mover | REMOVED | ADDED | source lines the removals touch |
| --- | --- | --- | --- |
| default/SVSwitch, testflags/SVSwitch | **54** | **0** | `Packet.sv:87` only |
| default/BuildUVMPkg, testflags/BuildUVMPkg | **70** | **0** | `71511` (enclosing begin), `71523` |
| default/SimpleUVM, testflags/SimpleUVM | **70** | **0** | `767` (enclosing begin), `779` |
| default/Scoreboard | **70** | **0** | `767`, `779` |
| default/SeqDriver | **140** | **0** | `767`, `779` |
| testflags/SeqDriver | **160** | **20** | `59`, `73`, `767`, `779` |

`uvm_vreg.svh:767` is `this.n_used_bits = 0;` — it appears only as the enclosing
`\_begin: (uvm_pkg::uvm_vreg::configure), line:767:4` back-reference whose element list
shrank. `:779` is `this.atomic = new(1);`. So on eight of nine movers the removals touch
exactly one law site plus its parent line.

**SVSwitch, the strongest attribution available — the full removed set, indentation KEPT:**
all **54** removed lines belong to the single `assignment: , line:87:3, endln:87:34`
subtree plus the one `|vpiStmt:` field label that carried it. **Not one line comes from
anywhere else in the design**, and ADDED = 0. The blast radius on the target is exactly
one statement.

That structural proof also disposes of three shapes my aggregate instrument flagged as
`**OVERSHOT**` on SVSwitch — `vpiStmt:` (g=454 p=454 n=453), `vpiArgument:` (110/110/109)
and `vpiName:this.data` (1/1/0) — shapes where the *pristine* count happened to equal
golden's. They are cancellation artifacts of counting a shape that occurs many times, the
exact heuristic failure the implementer warned about. Proof for the sharpest one:

```
GOLDEN's single  |vpiName:this.data   is at Packet.sv:122   (the R1 site)
OUR pristine's   |vpiName:this.data   was at Packet.sv:87   (the object the law removes)
OUR patched at 122 emits |vpiName:this.data[i]  — golden count for that shape: 0
```

Two independent defects — an extra object at 87, a wrong name at 122 — summed to golden's
count of 1 by coincidence. Removing the 87 object is correct; the 122 gap is R1, untouched.
**Their reporting gap here is real** (see finding 3): their 3-way census lists 9 shapes,
all `CONVERGED`, and a reader could not learn that these three existed or why they are benign.

---

## 7. FINDINGS, most severe first

### FINDING 1 — Their explanation of the `testflags/SeqDriver` mover is WRONG. It is not nondeterminism; it is a pure dump RELOCATION, and their original build-dependence hypothesis was right.

They wrote: *"the real cause is **parallel-parse nondeterminism on the pristine side** — 4/4
serial determinism, and the sweep DB differing from serial at identical byte size"*, and
they explicitly retracted their own build-dependence hypothesis as "wrong".

Both halves fail. I ran each binary three times on that exact test:

```
$ # pristine 663899bc…, testflags/SeqDriver, 3 independent harness runs
run1 00c280fa05a9a3dd bytes=17981993
run2 00c280fa05a9a3dd bytes=17981993
run3 00c280fa05a9a3dd bytes=17981993
sweep 00c280fa05a9a3dd bytes=17981993     <-- the 794-test --jobs 2 sweep DB
$ # patched d1ccd848…, same test, 3 independent runs
run1 e4effe1d96ea3675 bytes=17980243
run2 e4effe1d96ea3675 bytes=17980243
run3 e4effe1d96ea3675 bytes=17980243
sweep e4effe1d96ea3675 bytes=17980243
```

**Both binaries are perfectly deterministic, and each isolated run reproduces its own
loaded-sweep DB byte for byte.** There is no parallel-parse nondeterminism here to blame.
The 20 added lines are a real, reproducible consequence of the patch.

What they actually are:

```
$ diff -u pristine.dump patched.dump   ->  REMOVED=160  ADDED=20
$ # the 20 ADDED lines vs the 20 removed lines of the uvm_reg_*_t alias shapes:
IDENTICAL MULTISET -> pure relocation, zero semantic change
$ msdist.sh pristine.dump patched.dump
MULTISET DISTANCE (sum |dg-do|): 140
```

Every one of the 10 added shapes has **pristine count == patched count**
(`bit_typespec: (uvm_reg_addr_t)` 691/691, `(uvm_reg_data_t)` 689/689,
`range:` 190/190 and 259/259, `ref_typespec:` 86/86 and 63/63, the `vpiName`/`vpiFullName`
pairs likewise). The same objects, printed at a different point in the dump. **The
multiset distance between pristine and patched is 140 — identical to `default/SeqDriver`'s
REMOVED=140 — so the semantic change on `testflags/SeqDriver` is exactly the same
140-line removal as on every other UVM mover, and the 20/20 contributes zero.**

The mechanism is the one already in the project's own memory: *"Alias population is
build-dependent — pointer-keyed `std::map` iteration (address order) in the typespec/alias
path shifts UVM alias counts on a semantically-null edit."* Dropping one assignment
subtree changes the allocation sequence, which changes address order, which changes which
alias representative is printed where. Their law-off control (`4bcce04a…` byte-identical to
pristine) does **not** refute that: forcing the predicate `false` allocates exactly the
same objects as pristine, so of course the DB is identical. The control was insensitive to
the hypothesis it was used to reject, and its meaning was inverted.

Severity: does not change any gate number or the code, but it is a wrong causal claim in
the landed record, and it retracts a correct hypothesis in favour of an incorrect one.
`msdist.sh` — already in the repo, already carrying a header warning about this exact LCS
trap — settles it in one command.

**Command that shows it:** the three-run md5 table above, then
`msdist.sh <pristine>.dump <patched>.dump` → `140`, then
`diff <sorted removed alias lines> <sorted added lines>` → identical.

### FINDING 2 — Residue R3 is built on Finding 1's wrong diagnosis, and its premise is false.

R3 says *"the byte verifier can't distinguish a law from parallel-parse nondeterminism —
shipped `svs3way.sh` (3-way census) as the fix."* There is no parallel-parse
nondeterminism to distinguish (Finding 1: 3/3 determinism on both binaries). The byte
verifier's real limitation is that `diff -u` is **alignment-sensitive**, and the fix for
that already exists and is already mandated by the measurement laws: `msdist.sh`, whose own
header says *"when diff picks a different alignment the count can move by thousands with
almost no content change."* A 3-way per-shape census is a useful instrument and worth
keeping, but it is not the fix for the problem R3 names, and R3 as written will send the
next pass hunting a phantom.

**Command:** `head -16 tools/probe/r10uvm55repro/msdist.sh` beside the R3 paragraph, plus
the determinism table.

### FINDING 3 — The shipped SVSwitch 3-way census under-reports: three flagged shapes are absent from it.

Their §6.1 census lists 9 shapes, all `CONVERGED`. A complete per-shape pass over the
34 changed shapes also turns up `vpiStmt:` (454/454/453), `vpiArgument:` (110/110/109) and
`vpiName:this.data` (1/1/0) — three shapes where the pristine count equalled golden's and
the patched count does not. All three are benign cancellation artifacts (§6 above proves
`vpiName:this.data` case by case, and the 54-line structural attribution proves the rest),
but the README as shipped gives the integrator no way to discover them, and the brief's
rule *"a REMOVED line golden HAS is a finding"* flags them. The write-up should either
list and dispose of them, or state that it reports only shapes whose golden count is 0.

**Command:** `/tmp/r10svs3v_att.sh <golden> <pristine> <patched> default/SVSwitch` →
`FINDING-SHAPES=12`, three of them `**OVERSHOT**`.

### FINDING 4 — Under-fire candidate, unresolved and worth its own pass: golden also drops a CLASS-SCOPE `<Class>::<prop> = new[…]`.

Arm b2 cell `c10`: a static method containing `c10::sd = new[3];`. Golden gives
`function: (work@c10::sm)` **no statement at all** (golden count 0); we emit one (2, both
pristine and patched — the predicate correctly declines, since the ScopedName root is an
`IdentifierName`, not `ThisHandle`/`SuperHandle`). If golden's drop there is the *same*
law, then the stated gate — *"THE GATE IS THE `this`/`super` KEYWORD ON THE LHS"* — is
narrower than golden's actual behaviour.

I could **not** settle it and I am not claiming it as a defect: our side of that cell emits
`ref_obj: (work@c10::sm::c10::@@BAD_SYMBOL@@)`, so we fail to resolve `c10::sd` at all, and
golden's empty method may equally be Surelog declining the class-scope LHS for an unrelated
reason. The clean control (`c10::sd = 5;`, a non-`new` RHS) was not run. It is an
under-fire at worst — a missed convergence, never a regression — and it does not occur in
either corpus (the source census found zero `<Class>::<prop> = new` sites). Filed as
residue V1 below.

### FINDING 5 (minor) — R5 is over-stated as a risk.

R5 calls `NewCovergroupExpression` "deliberately excluded, unmeasured". Measured: the
emitter already reports `expression kind: NewCovergroup` as an unsupported construct, and
slang rejects the `this.`-spelling outright (`cannot assign to read-only variable`). The
exclusion cannot silently produce a wrong database. Downgrade it.

---

## 8. RANKED RESIDUE (mine)

**V1 — `hier_path` golden `(this.data)` vs ours `(this.data[i])`, `Packet.sv:122`.** Their
R1, confirmed as SVSwitch's sole remaining head (78 cmp lines, quoted in §3). Only thing
between SVSwitch and `CMP_EQUAL`. Highest value in the corpus right now.

**V2 — golden's EMPTY assignment (`vpiOpType 82`, `vpiBlocking 1`, no `Lhs`, no `Rhs`).**
Their R2, and my arms make it the single most frequently-hit residue: it is the *whole* of
every `STILL-DIFF` cell across b1/b2/b6 (11 cells) and it is live in the corpus at
`uvm_mem_mam.svh:658` inside an out-of-line constructor (§5.4 quotes both sides). Golden's
model is "always build the empty assignment, then omit it from list slots"; ours is "build
a full assignment, omit it from list slots". Closing V2 subsumes R2 and would convert every
kept-position cell.

**V3 — fix the causal record for `testflags/SeqDriver` (Findings 1 & 2).** Replace the
nondeterminism paragraph with the relocation proof, restore build-dependence as the
mechanism, and re-scope R3 to "`diff -u` is alignment-sensitive; use `msdist.sh`". Cheap,
and it stops the next pass chasing a phantom.

**V4 — resolve the class-scope drop (Finding 4).** One arm: `c10::sd = 5;` versus
`c10::sd = new[3];`, plus a spelling that our resolver does not turn into
`@@BAD_SYMBOL@@`. Decides whether the law's gate is "written `this`/`super`" or "any
written scope qualifier". Zero corpus sites, so it is correctness-of-statement, not
convergence.

**V5 — the extra out-of-line `function` object.** Ours emits a second `function` object at
the `function C::m();` definition span for every extern method; golden emits only the
in-class prototype (§5.4, arm b2: `c7`, `c8`, `c9`). Pre-existing, unrelated to this law,
and it made my synthetic extern cells unreadable — worth fixing for the sake of future
arms.

**V6 — function-span policy.** Their R4. cmp-invisible (§4, proven over all 233 Compare
methods), so dump-only phase-3 work. Their arm `a4` already carries the qualifier matrix.
Do not spend a pass on it.

**V7 — `NewCovergroupExpression`.** Their R5, downgraded per Finding 5: already fenced by
an unsupported-construct report. Note it and move on.

---

## 9. Disk

Deleted all my own sweep workdirs and dumps under `/tmp/r10svs3v_*` — **1013 MB**
(two 363 MB surelog sweeps, two 37 MB u2r sweeps, six 18 MB determinism runs, two 53 MB
UVM dumps, arms and logs). `/tmp/claude-1000` untouched. `results/` never written by any
command in this verification.
