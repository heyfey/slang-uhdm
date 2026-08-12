# r10earl31 — ADVERSARIAL VERIFIER REPORT (§ psBoundPkgParamTs31)

**VERDICT: PASS — with one required follow-up.** Every number in the
implementer's report was reproduced on my own build, from a fresh `63ff1fb`, and
my patched binary came out **bit-identical** to theirs
(`00ec475cf42b95b0bcbcf570e1842643`). The head IS cleared, `Earlgrey_0_1/default`
does **not** convert (as they said FIRST), and no corpus row or byte moved
anywhere except the one target database.

The follow-up is mine, not theirs to concede: the shipped gate **over-fires on
the TRUE ARM of a conditional inside a part-select bound**, a cell the grid never
built. I have a 24-line minimal witness that goes `PASS_CMP + DUMP_MATCH` →
`CMP_FAIL` with the patch (F1 below). Measured corpus reach today: **zero**
(no file in either corpus writes a ternary inside select brackets), which is
exactly why the gates are green — the defect is latent, cmp-visible, and one
structural condition away from being closed.

* Verifier worktrees: `.claude/worktrees/r10earl31v` (patched, branch
  `r10earl31vwt`) and `.claude/worktrees/r10earl31vpris` (pristine, detached
  `63ff1fb`). Main tree untouched.
* New verifier arms (mine): `v1_empty.sv`, `v2_edge.sv`, `v3_tern.sv`,
  `v4_ops.sv`, `v5_hier.sv` in this directory, driven by the implementer's
  `arm31.sh` / `cells31.py` / `census31.py` / `mv31.sh` unchanged.

---

## 1. PATCH HYGIENE — clean

| check | command | result |
|---|---|---|
| md5 of deliverable | `md5sum /tmp/r10earl31.patch` | `918f532020720652f8a0b027d4407d28` ✓ |
| applies to pristine 63ff1fb | `git apply --check -v` in `r10earl31vpris` | clean, 13 files ✓ |
| applies to TODAY's main HEAD (`80892a3`, after r10uvm59 + r10svs5 landed) | `git apply --check` in main tree (read-only) | **rc=0 — no textual conflict** |
| files touched | `git apply --stat` | `include/UhdmExporter.h` (+11−2 region), `src/ExprEmit.cpp` (+111), `tools/probe/r10earl31repro/*` only; 1610 insertions / 2 deletions ✓ |
| whitespace | `git apply` | one trailing-space warning, `e4_ctrl.sv:1365` — that is the **escaped identifier** `\blk@1 `, where the trailing space is required by SV. Not a defect. |
| **no `vpiConstType` write** (earl30 territory) | `grep -nE "VpiConstType" /tmp/r10earl31.patch` | 0 hits in production code ✓ |
| **no `ref_obj` created/rebound** (r10uvm59 boundary) | `grep -n "MakeRef_obj" patch` | 0 ✓ |
| **no clocking-block / hier_path *content*** (r10svs5 boundary) | `grep -nE "clocking\|Path_elems"` | 0; the only production `hier_path` mention is the structural type test `VpiParent()->UhdmType() == uhdmhier_path` ✓ |
| helper's two older call sites unchanged | `declTsOnly` defaults `false`; early return guarded by it (`src/ExprEmit.cpp:3388`) | ✓ and independently proved by 0/679 u2r byte movers |
| main tree free of this pass | `grep -rn "psBoundPkgParamTs31\|declTsOnly" src include` in main tree | **0** ✓ (their revert claim holds) |
| new compiler warnings | `grep -icE "warning:"` both build logs | 20 pristine, 20 patched — **no new warnings** |

**STATED GATE == CODE GATE.** Read at `src/ExprEmit.cpp:5254-5359`: (1) the
enclosing `if` at 4144 is `scope is Package && symbol is Parameter`; (2)
`if (!c->Typespec())` — purely additive; (3) an operation-only walk (bounded 32)
that must land on `uhdmpart_select`. No context flag, no view/import test, **no
text test**. That is exactly the stated law. The localization claims check out
against the generated Compare code as well:
`expr::Compare` (`~/git-repos/UHDM/build/generated/src/expr.cpp:83`) reads
decompile → size → `SafeCompare(Typespec())`; `ref_typespec::Compare:131` reads
`VpiName`, `VpiDefName`, `Actual_typespec`; `BaseClass::Compare:170` reads
`VpiType`/`VpiName`/`VpiDefName` — **`VpiFullName` and spans are compared
nowhere**, which is what makes F2–F4 below dump-only residues.

---

## 2. THE FIVE GATES, INDEPENDENTLY

### GATE 1 — BUILD (absolute paths, link line waited for, md5 asserted separately)

```
BASE (pristine)  /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl31vpris/build/slang-uhdm
BASE (patched)   /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10earl31v/build/slang-uhdm
grep -c "Linking CXX executable slang-uhdm" = 1   (both)   grep -icE "error:" = 0 (both)
baseline OK 32 hex: 839ca7d61e574b269300ed4b7518a095      <- my build == their baseline (4th independent build)
FINAL=00ec475cf42b95b0bcbcf570e1842643                    <- my build == their FINAL, BIT-IDENTICAL
MD5 CHANGED: PASS
```

### GATE 2 — GOLDENS (pinned; the harness defaults `SLANG_UHDM` to the MAIN TREE)

```
SLANG_UHDM=<my patched build>  ./tests/check_goldens.sh   rc=0  PASS=23  FAIL=0
SLANG_UHDM=/bin/false          ./tests/check_goldens.sh   rc=1  PASS=0   FAIL=23
```

### GATE 3 — uhdm2rtlil `--mode testflags --jobs 2`, own `--out`/`--workdir`

```
testflags  679 CMP_EQUAL  50 SLANG_REJECT  2 SURELOG_FAIL
dump       496 match  183 differ  52 blank
ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/v31/u2r_pat.csv
  baseline 732 lines = 731 ROWS ; fresh 732 lines = 731 ROWS
  0 differing ROWS (0 diff row-sides)  -> PASS: every row byte-identical
```

### GATE 4 — surelog `--mode both --jobs 2` (conversion question answered FIRST)

```
default    467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
testflags  463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
           3 NO_DATABASE  2 UNTRANSLATABLE  1 TIMEOUT  1 NO_UHDM
dump       default 225 match / 242 differ / 327 blank ; testflags 165/298/331
ct8rows.sh results/golden_surelog.csv /tmp/v31/sl_pat.csv -> 0 differing ROWS (0 diff row-sides)
```

**`Earlgrey_0_1/default` does NOT convert.** `default` is **467/13**, not 468/12.
The row, mine vs the committed baseline, byte for byte:

```
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,      <- /tmp/v31/sl_pat.csv (my patched sweep)
Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,      <- results/golden_surelog.csv
Earlgrey_0_1,testflags,SLANG_REJECT,reqfifo_rdata.error,,   (both, unchanged)
```

`results/*.csv` untouched (I never wrote them; `git status` in both worktrees
shows only the untracked probe dir).

### GATE 5 — BYTE VERIFIER, both corpora, my patched build vs MY pristine build

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
             SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog    : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 1 / 953
             MOVER ./default/Earlgrey_0_1-71da2fd7/slang.uhdm  patched=813a083a29dd pristine=60455a1c30c3
             SELFCHECK 952/953 flagged        SELFCHECK1 = 2  (1 real + 1 injected)
```

**1 mover in 1632 databases**, and it is the target row. `Scoreboard` did not
move for me either.

### CANARIES (all named explicitly, all executed)

| check | corpus | result |
|---|---|---|
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=6` | uhdm2rtlil | ok=1 **changed=0 absent=0** unknown=6 → PASS |
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=1` | surelog | ok=58 **changed=0 absent=0** unknown=1 → PASS |
| `tools/probe/r10uvm52repro/canaries.sh` | uhdm2rtlil | ok=8 **changed=0 absent=0** unknown-names=25 |
| `tools/probe/r10uvm52repro/canaries.sh` | surelog | ok=52 **changed=0 absent=0** unknown-names=7 |
| `r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>` | static | audited=29 **UNCOVERED=0 FENCE-BREACH=0** |
| BY NAME | surelog csv | `InterfaceModPort` CMP_EQUAL/differ both modes; `BlackParrotComplex` CMP_EQUAL/differ both modes; `SVSwitch` CMP_NOTEQUAL both modes and **not in the mover list** |

`GOLDEN_DEFER` unset in my environment (`env | grep -i golden` → nothing).
`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` never dispatched
(canaudit FENCE-BREACH=0).

---

## 3. THE HEAD, RE-RUN BY ME IN BOTH DIRECTIONS

`uhdm-cmp <golden cache>/golden.uhdm <my slang.uhdm>` on `Earlgrey_0_1/default`:

```
PRISTINE (17 lines)  LHS ref_typespec (work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data) id:78753
                       |vpiParent -> constant 408:65-408:69   |vpiActual -> logic_typespec 25:14-25:25
                     RHS: <null>                              <- EXACTLY the brief's head
PATCHED  (34 lines)  LHS constant 408... GONE.  New head, different file, different law:
                       LHS constant 365:75-365:87 vpiDecompile:12'h380 under func_call (dm::load)
                       RHS ref_obj (dm::DataAddr) 365:75-365:79 -> parameter (dm::DataAddr) 34:27
```

**Head cleared, confirmed.** The new head is a fold-vs-ref question at
`dm_mem.sv:365`, which the implementer had already measured as `e3_pos.sv` p11.
`cmp` reaching the `Typespec()` compare in the pristine run also *proves* their
refutation of earl30's R5 for this cell: `expr::Compare` compares decompile and
size **before** the typespec, so our value already matched golden.

Their two refutations of the brief check out against the sources:

```
dm_csrs.sv:408  abstractauto_d.autoexecdata    = 12'(dmi_req_i.data[dm::DataCount-1:0]);
dm_csrs.sv:409  abstractauto_d.autoexecprogbuf = 16'(dmi_req_i.data[dm::ProgBufSize-1+16:16]);
dm_pkg.sv:25    localparam logic [3:0] DataCount     = 4'h2;   <- cols 14..25 = `logic [3:0]`
dm_pkg.sv:22    localparam logic [4:0] ProgBufSize   = 5'h8;
```

The brief quoted line **409**'s text as 408, and the `vpiActual` is the
**parameter's own** declared type in `dm_pkg.sv`, not the `dmi_req_i.data`
member's. Both refutations stand.

---

## 4. MOVER ATTRIBUTION, CENSUS, DISTANCE — all reproduced

`mv31.sh` (SELFCHECK=1, VERBOSE=1) on my three path-normalized dumps:

```
ADDED instances=15 over 12 shapes (14/11 real + the fabricated control); REMOVED 1 over 1 (the control only)
  ok  x1 golden=2      \_ref_typespec: (work@dm_csrs.csr_read_write.dmi_req_i.data[4'h2 - 1:0].data)
  ok  x1 golden=2      \_ref_typespec: (work@dm_csrs.csr_read_write.dmi_req_i.data[5'h8 - 1 + 16:16].data)
  ok  x1 golden=1      |vpiFullName:...data[4'h2 - 1:0].data        ok x1 golden=1 |vpiFullName:...[5'h8 - 1 + 16:16].data
  ok  x1 golden=26     \_logic_typespec: , line:25:14, endln:25:25   ok x1 golden=17 \_logic_typespec: , line:22:14, endln:22:25
  ok  x2 golden=91157  |vpiTypespec:      x2 golden=233938 |vpiActual:   x2 golden=723816 |vpiParent:   (bare absorbers)
  OVER-FIRE x1 golden=0 \_constant: , line:408:65, endln:408:78
  OVER-FIRE x1 golden=0 \_constant: , line:409:65, endln:409:80
  ADDED: 9 covered, 3 OVER-FIRE (incl. the fabricated one)   REMOVED: 0 UNDER-FIRE
```

Their §5.1 explanation of the two flags is **correct and I extended it to the
line they only argued for 408**:

| span | golden | ours before | ours after |
|---|---|---|---|
| `408:65-408:69` (golden's 4-char class) | 2 | 0 | 0 |
| `408:65-408:78` (our wider span) | 0 | 1 | 2 |
| `409:65-409:69` | 2 | 0 | 0 |
| `409:65-409:80` | 0 | 1 | 2 |

One extra **print** (the `vpiParent` stub inside the new `ref_typespec`) of a
pre-existing object at a span that already disagreed. No object created.

`census31.py`, span-keyed join, pristine → patched (both against golden):

```
part_select/vpiLeftRange   TS_GOLDEN_ONLY  2 -> 0      (row disappears)
part_select/vpiLeftRange   TS_BOTH same  145 -> 147
every other cell UNCHANGED — ips/vpiWidthExpr TS_GOLDEN_ONLY stays 10 (their R2),
  ips OURS_ONLY 3 and base OURS_ONLY 2 unchanged, param_assign TS_GOLDEN_ONLY 1 (their R6)
NO new TS_OURS_ONLY anywhere.  Policy table matches their §4(a) row for row
  (constants golden=136822 ours=131483; ps/left 327/3291 vs 228/3291 -> 230/3289).
```

`msdist.sh` @`7c7eaa6` (md5 `7c0d46b5da124cfe37d27eddc95eb7e7`):

```
309589 -> 309579 (-10)   golden-only 239082 -> 239070   ours-only 70507 -> 70509
dump lines 4,654,873 -> 4,654,887 (+14)   vs golden 4,823,448
```

`pred31.sh` source fence reproduced exactly: u2r 1886 files A=1 B=37; Surelog
tests 824 A=8 B=32; third_party 11776 A=215 B=1002 — and the one mover is in A.

### The grid, re-run cell for cell

`arm31.sh` with both binaries into the **same** workdir path (so file-path text
cannot fake a mover), then `cells31.py` with golden always on the left:

```
arm            cmp lines (pris -> pat)   dump-diff sides   our dump: +added / -removed
e1_psbound      17  ->   0  PASS_CMP     498 -> 428        +98 / 0   (14 new ref_typespec)
e2_origin      267  -> 267               804 -> 780        +36 / 0   ( 5 new ref_typespec + 1 top-level int_typespec print)
e3_pos         100  -> 100                71 ->  71        +0  / 0   BYTE-IDENTICAL
e4_ctrl         17  ->   0  PASS_CMP     474 -> 429        +63 / 0   ( 9 new ref_typespec)
```

Per-cell mismatch audit after the patch (**every** part-select cell of every arm,
both sides, multiplicity kept) leaves exactly the residues they declared and
nothing else:

* **e1: zero mismatches** — 12/12 cells' fullname and `Actual_typespec` identical
  to golden (only the span differs: their R3).
* **e2: one** — c5 `41:16`, the typedef-typed param, golden
  `logic_typespec@19:11-19:22`, ours `<bare>`: the declared abstention. Their
  claimed origin column is exact, including c3's whole-`ParameterDeclaration`
  `int_typespec@22:3-22:39` and the enum-literal / literal negative controls.
* **e3: one** — `46:21 indexed_part_select/vpiWidthExpr` golden-only (their R2),
  pre-existing and untouched. The arm is byte-identical before/after.
* **e4: only the escaped-identifier span shift at 37:20 vs 37:24** (their R4);
  the macro-written bound (k3), the nested-struct hier_path (k4) and the
  gen-FOR's **three** views (`gblk`, `gblk[0]`, `gblk[1]`) are byte-exact.

One documentation nit: §3.0 says e2 gained "6 stamps"; the measured count is
**5** new `ref_typespec` objects plus one extra top-level `int_typespec` print
that lands ON golden (6→7, golden 7). §3.2's table lists 5 movers correctly.

---

## 5. FINDINGS — the empty product cells

I built 12 positions/scopes their grid skips (`v1_empty.sv`), 7 operator/scope
edges (`v2_edge.sv`, `v4_ops.sv`), the untested fullname branch (`v5_hier.sv`)
and one minimal witness (`v3_tern.sv`). Priced against the mover list first: the
byte verifier already says **no corpus database except Earlgrey moved**, so every
finding below has **0 measured corpus reach** — they are latent, and F1 is the
one that would bite.

### F1 — OVER-FIRE: the TRUE ARM of a conditional inside a part-select bound
### (cmp-VISIBLE, latent, recommend gating before/with landing)

The stated law says "through OPERATIONS ONLY … every operation depth". Golden
does **not** treat a conditional's operands alike. `v4_ops.sv:24`
(`x2 = 32'(d[(pk::DC ? pk::DC : pk::DC)-1:0]);`), one line, three positions,
golden's own tree (`vpiOpType:32`):

```
operand[0]  condition  24:17  GOLDEN STAMPED (span 24:17-24:21, the 4-char class)   ours stamped  ✓
operand[1]  TRUE  arm  24:26  GOLDEN **BARE**  (span 24:26-24:32, the 6-char class)  ours STAMPED  <-- OVER-FIRE
operand[2]  FALSE arm  24:35  GOLDEN STAMPED (span 24:35-24:39)                      ours stamped  ✓
```

Minimal witness `v3_tern.sv` — 24 lines, one statement
`a1 = 32'(d[(1 ? pk::DC : 1)-1:0]);`:

```
SLANG_UHDM=<pristine> ./arm31.sh v3_tern.sv   ->  PASS_CMP   DUMP_MATCH      (byte-perfect vs golden)
SLANG_UHDM=<patched>  ./arm31.sh v3_tern.sv   ->  CMP_FAIL   DUMP_DIFF content=7 hunks=1
```

So the patch converts a **cmp-equal, dump-identical** design into
`CMP_NOTEQUAL`. It is invisible in the gates because the shape does not exist in
the corpora — measured, not assumed:

```
grep -rlE "\[[^]]*\?[^]]*:[^]]*\]" --include='*.sv' --include='*.v' --include='*.svh'
  ~/git-repos/uhdm2rtlil/test        -> 0 files
  ~/git-repos/Surelog/tests          -> 0 files
  ~/git-repos/Surelog/third_party/tests -> 0 files
```

**Concrete fix, one structural condition, no text and no context flag:** while
walking up, refuse if the child is reached as **operand index 1 of an
`operation` with `VpiOpType() == 32`** (compare the child pointer against the
parent's `Operands()` list). That keeps the condition and the false arm, which
golden stamps, and drops only the arm golden leaves bare. It needs its own arm
cell (`v4_ops.sv` is ready-made) because the asymmetry is bizarre enough that it
must be measured on a second spelling before it is transcribed.

### F2 — a hier_path select in a PORT CONNECTION gets the def-view prefix on one of two copies (dump-only)

`v5_hier.sv:26`, `v5sub u1 (.a(32'(o.a[pk::DC-1:0])), …)` — **both** stamps here
are new (pristine had none):

```
26:24 GOLDEN  ref_typespec(work@v5.u1.a.o.a[4'h2 - 1:0].a)   x2  (def + elab)
26:24 ours    ref_typespec(work@v5.u1.a.o.a[4'h2 - 1:0].a)        <- one exact
26:24 ours    ref_typespec(work@v5.o.a[4'h2 - 1:0].a)             <- one WRONG (def-view prefix)
```

Cause: the new hier_path branch builds `prefix + "." + fn + "." + name` with **no
"prefix already present" guard**, unlike the pre-existing arm at
`src/ExprEmit.cpp:5150` (`fn9.compare(0, prefix.size(), prefix) != 0`). Every
shipped hier_path cell has an *unscoped* select fullname, so the branch's scoped
case was never exercised. `VpiFullName` is compared nowhere, so this is a byte /
dump residue only — but it is a **new** object with a wrong name, which is the
class of defect this pass otherwise fixed twice before landing.

### F3 — streaming-concat select: the new stamp inherits an UNSCOPED fullname (dump-only)

`v1_empty.sv:52` (`w2 = {>>{d[pk::DC-1:0]}};`): golden
`ref_typespec(work@v1.blk.d)`, ours `ref_typespec(d)`. Root cause is
**pre-existing**: our own `part_select` at 52:14 is named `d` where golden names
it `work@v1.blk.d`. The law copies the select's fullname verbatim, so it
faithfully propagates the older defect into a new object.

### F4 — interface hier_path select: the new stamp carries the UNFOLDED bracket text (dump-only)

`v1_empty.sv:72` (`w7 = 32'(ii.s[pk::DC-1:0]);`): golden
`work@v1.ii.s[4'h2 - 1:0].s`, ours `work@v1.ii.s[pk::DC - 1:0].s`. Again the root
cause is pre-existing (our `hier_path`/`part_select` keep the unfolded text), and
that older difference becomes the arm's head once the typespec head is cleared —
so this cell's *cmp* residue is not the new object but the select's own name.

### F5 — 12 previously unmeasured positions/scopes CONFIRM the law's positive direction

Golden stamps **every** one of them, and after the patch we match byte for byte
(fullname + `Actual_typespec`; span per R3) except where noted above:

| new cell | golden | ours after |
|---|---|---|
| part_select as an **assignment TARGET** (`lhs1[pk::DC-1:0] = …`) | stamped | **exact** |
| the same **nonblocking** in `always_ff` | stamped | **exact** |
| part_select of an **unpacked-array element** (`mem[2][…]`) | stamped, fullname `work@v1.blk.mem.mem` — golden doubles the last component ITSELF | **exact** |
| **two folds in ONE bound** (`d[pk::DC+pk::DC:0]`) | stamped ×2 | **exact ×2** |
| package **`parameter`** (not localparam) origin | stamped → that param's own `logic_typespec@23:14` | **exact** |
| **task** body | stamped | **exact** |
| **class-method** body (`work@v1c::cc::f::z`) | stamped | **exact** |
| **generate-IF** scope | stamped ×2 | 1 exact + 1 pre-existing mangled name (present in PRISTINE too, not this pass's) |
| **port connection** actual | stamped ×2 | 1 exact + 1 pre-existing mangled name (pristine too) |
| **interface** body | stamped | **exact** |
| **explicit single-item import** (`import pk::DC;`) | stamped | **exact** |
| **`$unit`-scope wildcard import**, unqualified read | stamped | **exact** |
| shift / concat / unary-minus / comparison / cast in the bound; **5 operations deep** | stamped | **exact** |

The two "mangled" elab names (`work@v1.gi.d.work@v1.d.d`,
`work@v1.d.work@v1.u1.a.d.d`) are present **identically in the pristine build**
(`grep -c` = 2 each in both), i.e. they belong to an older arm and gate 2
(`!c->Typespec()`) correctly kept this pass off them.

### F6 — pre-existing UNDER-FIRE in a package's own function (not this pass's field)

`v2_edge.sv:27`, `pk2::p2f`'s body reads `pk::DC` in a part-select bound: golden
folds it and stamps (`ref_typespec(pk2::p2f::w)`), **we emit no constant at
all**. Same family as their R1 (fold-vs-ref), one scope over.

---

## 6. RANKED RESIDUES (theirs re-measured, mine added)

1. **R1 (theirs) — `Earlgrey_0_1/default`'s new head**: golden folds
   `dm::DataAddr` as a func-call argument, we keep a `ref_obj`
   (`dm_mem.sv:365`). Verified by my own cmp run; the next thing for this row.
2. **F1 (mine) — the conditional's TRUE ARM over-fire.** cmp-visible, 0 corpus
   reach today, one structural condition to close, minimal witness shipped.
3. **R2 (theirs) — `indexed_part_select/vpiWidthExpr`**: census confirms
   `TS_GOLDEN_ONLY = 10` on the target, plus 3 ips-width + 2 ips-base stamps of
   ours golden lacks. Same law one position over, needs its own arm.
4. **R3 (theirs) — the qualified-fold SPAN** (golden spans `pk::` only, 4 chars;
   ours spans the whole `pk::DC`). Present on every stamped cell of every arm,
   invisible to cmp, and the reason mv31 flags two shapes.
5. **F2 (mine) — the missing "prefix already present" guard** in the new
   hier_path fullname branch (port-connection cell).
6. **F3/F4 (mine) — two pre-existing select-naming defects now propagated into
   new `ref_typespec` fullnames** (streaming concat; interface hier_path).
7. **R4 (theirs) — escaped-identifier select span shift**; **R5** typedef-typed
   pkg param's decl ts unreachable at fold time (the abstention; typespec-linkage
   cluster); **R6** one `param_assign/vpiRhs` value-then-typespec cell.
8. **F6 (mine) — no constant at all for a pkg-param fold inside another
   package's function body.**

---

## 7. WHAT I COULD NOT FAULT

* No measurement in the implementer's report was overstated in my re-run: build
  md5s, all four sweep histograms, both row gates, both byte-verifier lines with
  both self-checks, the 14/0 per-shape mover table, the census prediction in both
  directions, the multiset distance, the dump lengths, the source fence, and
  every grid cell.
* The two "OVER-FIRE" flags they *reported themselves* are genuinely the
  pre-existing span residue, by count, on both lines.
* Both of their self-caught errors (the doubled fullname, the wrong
  `int_typespec`) are absent from the shipped binary, and the abstention is real
  (e2 c5 stays bare rather than minting a wrong object).
* Boundaries with `r10svs5` (clocking path components) and `r10uvm59`
  (type-param scoped-call ref_objs) are clean, and the patch still applies to
  today's main HEAD with both of those landed.

Sweep workdirs (`/tmp/v31/wd_*`), the three Earlgrey dumps and all arm scratch
dirs were deleted after the numbers above were taken.
