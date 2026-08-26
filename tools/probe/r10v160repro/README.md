# r10v160 — the ADVERSARIAL VERIFIER of r10uvm160 § `badConcatOperandsFromSyntax160`

**VERDICT: ACCEPT as shipped.** `/tmp/r10uvm160.patch` applies clean on a
FRESH `6b24843`, rebuilds to the **byte-identical binary the implementer
claimed**, and every headline number reproduces — most of them byte-for-byte.
**No pristine-right → patched-wrong cell was found on legal SystemVerilog**
across 87 independently-built cells × 2 views, so no fix was needed and
`/tmp/r10uvm160.verified.patch` differs from the implementer's patch **only by
this evidence directory**.

**MEASUREMENT ONLY.** Nothing here is an acceptance judge; the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is. **LHS is ALWAYS golden (Surelog);
RHS is ALWAYS ours.** slang was NOT patched, `results/*.csv` were READ-ONLY,
nothing was promoted, `GOLDEN_DEFER` stayed unset, no fenced test was
dispatched.

| | |
|---|---|
| BASE | `6b24843` (both worktrees created FRESH from it) |
| verifier worktrees | `/tmp/wt_v160` (patched), `/tmp/wt_v160pris` (pristine) |
| pristine binary | md5 `904532d3885d6362d6f515c3db951771`, frozen `chmod 555` at `/tmp/v160_bin/pris.bin` |
| patched binary | md5 **`995b3d45726c2a9aef48b76b87f497a2`** — **the implementer's claimed md5, reproduced bit-for-bit by an independent build** — frozen at `/tmp/v160_bin/pat.bin` |
| build | `cmake -DCMAKE_BUILD_TYPE=Release`, `cmake --build -j 2`, both worktrees, md5 taken separately |
| sweeps | `scripts/verify_golden.py --jobs 2`, own `--out`/`--workdir` per binary, `SLANG_UHDM` exported EXPLICITLY per binary |

---

## 1. Binary audit (RESUME §9's trap)

`verify_golden.py` silently defaults `SLANG_UHDM` to the MAIN-TREE binary.
Every `cmds.txt` was audited BY PATH, file by file:

```
u2r patched : 1462 cmds.txt, 1458 name /tmp/v160_bin/pat.bin
              the 4 that do not are the 2 SURELOG_FAIL rows x 2 modes,
              where slang is never invoked (quoted in GATES.r10v160.txt)
u2r pristine: names /tmp/v160_bin/pris.bin, never pat.bin
```

No `cmds.txt` names any other `slang-uhdm`; the
`~/.cache/slang-uhdm-goldens/...` hits are the GOLDEN cache, not a binary.

---

## 2. Every headline number, re-measured

### 2.1 The heads (`r10uvm67repro/rowheads.sh`, own sweeps)

| row-mode | pristine | patched | implementer claimed |
|---|---|---|---|
| SimpleUVM default | 67 / 1 head | **29 / 1** | 67 -> 29 ✔ |
| SimpleUVM testflags | 67 / 1 | **29 / 1** | ✔ |
| Scoreboard default | 67 / 1 | **145 / 1** | ✔ |
| SeqDriver default / testflags | 17 / 1 | 17 / 1 | ✔ |
| MiniAmiq default / testflags | 106 / 1 | 106 / 1 | ✔ |
| BuildUVMPkg default / testflags | 1371 / 1 | 1371 / 1 | ✔ |
| Earlgrey_0_1 default / testflags | 36 / 1 | 36 / 1 | ✔ |
| Rggen default | 0 / 0 (CMP_EQUAL) | 0 / 0 | ✔ |

**All TWENTY-FOUR committed head logs** (`head_pris_*.cmp` /
`head_pat_*.cmp`, 12 rows x 2 sides) are **byte-identical** to the ones this
verifier measured on its own binaries — including `Scoreboard.default`, the
~50/50 coin, which landed the same way here. The seven unchanged rows' head
logs are byte-identical between pristine and patched, exactly as claimed.

### 2.2 Byte movers

```
surelog     MOVERS 9 / 956   PATH_SETS_IDENTICAL   SELFCHECK 955/956 flagged
            exactly the nine the pass predicted BY NAME:
            {default,testflags} x {SimpleUVM, SeqDriver, MiniAmiq, BuildUVMPkg}
            + default/Scoreboard
uhdm2rtlil  MOVERS 0 / 1358  PATH_SETS_IDENTICAL   SELFCHECK 1357/1358 flagged
```

### 2.3 Every mover moves TOWARD golden (`vrowdd160.sh`)

Order-blind, path-normalised whole-dump distance to the row's OWN golden (read
out of that row's `cmds.txt`), plus the regression detector `DEL_THAT_G_HAS` —
a dump line GOLDEN has, our PRISTINE database had, and our PATCHED one LOST.

```
default/BuildUVMPkg   68038 -> 68011   ADDED 27  ADD_MATCHING_G 27  DELETED 0  DEL_THAT_G_HAS 0
testflags/BuildUVMPkg 68038 -> 68011   ADDED 27  ADD_MATCHING_G 27  DELETED 0  DEL_THAT_G_HAS 0
default/MiniAmiq     360271 -> 360150  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
testflags/MiniAmiq   360271 -> 360150  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
default/SeqDriver    343140 -> 343019  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
testflags/SeqDriver  343140 -> 343019  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
default/SimpleUVM    129620 -> 129499  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
testflags/SimpleUVM  129616 -> 129495  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
default/Scoreboard   120030 -> 119909  ADDED 153 ADD_MATCHING_G 137 DELETED 0  DEL_THAT_G_HAS 0
```

**DELETED = 0 on all nine**, so the Scoreboard/default COIN cannot have
flattered the result: the patched database is a strict SUPERSET of the pristine
one plus nothing removed, and the added set is 137/153 lines golden also has.

The 16 added lines golden does NOT have are, on every row, the SAME sixteen —
all of them PARENT-REFERENCE renderings carrying a span
(`\_operation: , line:132:50, endln:664:100` and friends). The recovered
object itself is field-for-field golden's: `uvm_utils::find_all`'s
`` `uvm_warning `` concatenation compares operand for operand with golden
(`constant "Instance of type '"`, `ref_obj TYPE::type_name` UNBOUND,
`constant " not found in component hierarchy beginning at "`,
`hier_path start.get_full_name` over `ref_obj start` + `method_func_call
get_full_name`), and only the last two operands' SPANS differ — golden at the
macro BODY (`133:10`, `133:60`), ours at the macro ARGUMENT (`664:28`,
`664:78`). **Independently verified that the judge cannot see it:** the
generated `Compare` bodies for `operation`, `constant`, `ref_obj` and
`hier_path` contain **zero** references to `VpiLineNo` / `VpiColumnNo` /
`VpiEndLineNo` / `VpiEndColumnNo` / `VpiFile`.

---

## 3. BREAKING THE LAW — 87 cells, one INDEPENDENT database each

The judge names only the FIRST differing object, so a multi-cell arm hides
every cell behind its head. `gencells160.py` therefore emits **one `.sv` per
cell**; each is built by Surelog and by BOTH binaries in BOTH views and judged
by the official `uhdm-cmp` on its own. Full table: `CELLS.r10v160.txt`.

```
-> CMP_EQUAL          57   pristine WRONG (43-141 cmp lines), patched EQUAL
unchanged (abstain)   21   byte-identical pristine and patched
EQUAL both (control)   5   the ACCEPTED-literal oracles k01-k06, EQUAL before and after
MOVED                  3   c05_pkgscope, h06_inst, h07_inst3 (all three below)
SLANG_REJECT both      1   z02_module; plus arm v160_e_reported, likewise rc=3 both
```

**Order-blind dump distance over every cell x view: TOWARD 116, UNCHANGED 48,
AWAY 0, DEL_THAT_G_HAS>0 in 0.**

### What went to CMP_EQUAL (the law is right there)

* **string literal shapes the pass never wrote**: an escaped quote `"a\"b"`,
  `\n`, `\\`, `\t`, the EMPTY literal `""`, a literal containing `::` and `.`,
  a literal with `%0d` — each also written as its ACCEPTED twin (`k01`-`k06`,
  which are CMP_EQUAL on both binaries and stay so). The recovery keeps
  Surelog's RAW-source convention (escapes stay backslash+letter, size follows
  the raw inner length) because it reads `rawText` exactly as the bound
  `StringLiteral` arm does.
* **the identifier operand in eight homes**: a formal, a method local, a class
  property, a STATIC class property, a class localparam, a class STRING type
  parameter, a PACKAGE parameter, an INHERITED property — all UNBOUND in
  golden too, all EQUAL.
* **the scoped operand**: a bare `T::tn`, a scoped call `T::mk()`, a THREE-
  segment `T::inr::tn` (Surelog keeps first::last — the left-most walk is
  right), a scoped call WITH arguments, a scoped call with a DOTTED actual.
* **the dotted operand**: `bh.gn()`, `bh.pn`, `bh.gn(p)`, `bh.gn(bh.pn)`.
* **all five shapes in ONE concatenation** (`f01_allfive`, 141/165 -> 0).
* **the bad face**: a method call, a MEMBER SELECT, a `::` STATIC call, a BAD
  ARGUMENT inside a good call, the ONLY operand bad, the FIRST operand bad,
  TWO bad operands, and the type parameter defaulting to **int, string, a
  packed STRUCT, an ENUM, a CLASS, `bit`, `real`**.
* **the concatenation's own context**: a declaration initialiser, a `return`,
  a call argument, a `$display` argument, a ternary arm, an `if` condition, a
  `case` SELECTOR, a `case` ITEM, a binary operand, a `foreach` body, a
  `fork`, an lvalue-concat statement standing beside it, two rejected concats
  in one method.
* **the home**: a task, a STATIC method, TWO type parameters, a class at
  COMPILATION-UNIT scope, a VIRTUAL method of a virtual generic class and a
  class extending a generic base, a generic class with one / two explicit
  specialisations declared beside its default.

### What abstained (the fences hold, byte-for-byte pristine)

`o01` an integer literal operand, `o02` a select, `o03` a `$sformatf`,
`o04` a parenthesised identifier, `o05` a ternary, `o06` a nested
concatenation, `o07` a BARE call, `o08` a replication, `o09` a cast,
`o10` a nested concat of identifiers; `d05`/`d06` a THREE-deep dotted name and
a dotted call on a dotted receiver; `x03` a bad argument in a good call whose
result is not one of the five, `x04` nested bad-in-good-in-bad, `x14` a select
on a bad type through two levels; `y10` the concat nested inside an accepted
one, `y11` a written cast, `y15` a property initialiser; **`z01` an LVALUE
concatenation one of whose TARGETS binds bad** (the `inLhs` fence);
`d10_repl` the concat as a REPLICATION body (slang's Invalid child is a
`Replication`, not a `Concatenation`).

### The REPORTED twin stays SLANG_REJECT

`v160_e_reported.sv` writes the identical bad operand in a PLAIN class, where
slang diagnoses it: **rc=3 on BOTH binaries in BOTH views**, no database
produced. So does `z02_module` (a MODULE type parameter's default IS
elaborated). And an EXPLICIT class specialisation is likewise reported
(`no member named 'gt' in 'T' (aka 'basev160')`) — measured, and the reason
the law's population really is the DEFAULT specialisation only.

### The three MOVED cells (all RESIDUES, none a regression)

`h06_inst` / `h07_inst3` (a typedef'd specialisation INSTANTIATED as a module
variable, one and three instances) go 67/75 -> 28/28: the concat head CLEARS
and the judge walks on to a **pre-existing** residue — golden spells the module
variable's type `unsupported_typespec (pv160::spec160)`, we spell it
`class_typespec`. Both our binaries emit the identical three `class_typespec`
objects, so the patch did not create it; it was MASKED behind the concat head.
Distance falls (219 -> 192 def, 269 -> 219 elab) with `DEL_THAT_G_HAS 0`.

### `c05_pkgscope` — the one cell where the RECOVERED OPERAND itself is wrong

`s = {"[", pvx160::VX, "]", t.gt()}` — a `::`-scoped operand whose qualifier is
a real PACKAGE with a `parameter string`. 79/83 -> **28/28 cmp lines, head
moved to that operand**:

```
LHS golden : constant  vpiDecompile:vx  vpiSize:16  STRING:vx  vpiConstType:6   @19:39-19:49
RHS ours   : ref_obj (pvx160::VX)  vpiFullName:pv160::hold160::m::pvx160::VX    @19:39-19:47
```

Surelog RESOLVES a package-qualified parameter and constant-FOLDS it, where
§ `typeParamScopedCallRef59`'s object (right for a TYPE-parameter qualifier,
cells `c01`-`c04`, all EQUAL) is a bare `ref_obj`. **This is not
pristine-right -> patched-wrong**: pristine emitted NO operand at all. The
order-blind distance still FALLS (221 -> 198 def, 271 -> 229 elab) with
`DEL_THAT_G_HAS 0`, so the cell moves TOWARD golden and lands on a residue.
Ranked R-V1 below. The corpus does not reach it (0 wrong cells in the 9 moved
databases).

---

## 4. THE WIDE BOUNDARY — 4462 committed arms, both views

`vbound160.sh` (subdirectories included, list on fd 3, children `</dev/null`,
PROCESSED asserted against LISTED, scratch keyed on the RELATIVE path, every
cell recording its own rc) over every committed `*.sv`, plus a second pass over
every committed `*.v`:

```
*.sv  LISTED=4481 PROCESSED=4481  RC_DIFFS=0   (4394 committed + 87 this verifier's own)
*.v   LISTED=68   PROCESSED=68    RC_DIFFS=0   MOVED=0
```
`4394 + 68 = 4462`, reconciling exactly with the implementer's LISTED.

**MOVED_ARMS = 71**, of which 65 are this pass's and this verifier's own arms
(the positive control: the gate can see). The **six earlier-pass arms** that
moved, each judged against golden:

| arm | verdict |
|---|---|
| `r10uvm158repro/g158_f_witness.sv` | 67/71 -> **0/0 CMP_EQUAL**; dist 89->62, 163->94, DEL 0 |
| `r10uvm59repro/vcells/c09_concat.sv` | 49/49 -> **0/0 CMP_EQUAL**; dist 88->52, 108->72, DEL 0 |
| `r10v158repro/arms/probe0.sv` | 67/71 -> **0/0 CMP_EQUAL**; dist 85->58, 128->80, DEL 0 |
| `r10v103repro/arms/v103_b5.sv` | head UNCHANGED 48/56; **TOWARD** 260->238, 399->373, ADDED all matching golden, DEL 0 |
| `r10buvm22repro/g22.sv` | **REFUTED** |
| `r10uvm154repro/l154_noenum.sv` | **REFUTED** |

**The two refutations are one known artifact, and the campaign already owns its
proof.** Both databases differ ONLY in a leaked pointer minted as the right
range of a class-scoped `typedef <T> name[string]`: `UINT:22552281` from the
pristine binary, `UINT:22556377` from the patched one — **exactly 4096 apart**,
and the constant sits below `\_weaklyReferenced:`, unreachable to the judge.
`l154_noenum.sv` is r10uvm154's own committed LAYOUT-PROOF source, whose header
records the same phenomenon at different addresses; it carries **no
concatenation and no enum**, so neither pass's code can execute on it. A
**THIRD binary** — the main tree at `400a941d`, md5
`e3d14ab934b7b9e6862f85620f3c60e7`, an unrelated commit — prints
**`22556377`**, agreeing with the patched binary and disagreeing with the
pristine one. Causally excluded.

`g22.sv` shows the identical value pair and an IDENTICAL head (3438 lines both
views) with dump distance unchanged at 2205/2569.

---

## 5. GATES — all green, on this verifier's own binaries

```
goldens patched   PASS 23  FAIL 0     (SLANG_UHDM=/tmp/v160_bin/pat.bin)
goldens pristine  PASS 23  FAIL 0     (SLANG_UHDM=/tmp/v160_bin/pris.bin)
goldens /bin/false PASS 0  FAIL 23    (negative control)
u2r ct8rows  committed baseline vs patched tf : PASS
             own pristine tf vs patched tf    : PASS
             own pristine def vs patched def  : PASS
u2r histogram both modes CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2
u2r byteverify SELFCHECK=1 : MOVERS 0 / 1358
surelog ct8rows  committed baseline vs patched : PASS
                 own pristine vs patched       : PASS
surelog histograms pristine and patched IDENTICAL line for line
                 default  CMP_EQUAL 471 SLANG_REJECT 283 SURELOG_FAIL 25 CMP_NOTEQUAL 10 DEFERRED 5
                 testflags CMP_EQUAL 466 SLANG_REJECT 284 SURELOG_FAIL 23 CMP_NOTEQUAL 9 DEFERRED 5
                          NO_DATABASE 3 UNTRANSLATABLE 2 TIMEOUT 1 NO_UHDM 1
surelog byteverify SELFCHECK=1 : MOVERS 9 / 956, all nine predicted BY NAME
CMP_NOTEQUAL row SETS identical pristine vs patched - NO ROW CONVERTED
canaries.sh   surelog ok=52 changed=0 ; u2r ok=8 changed=0
ctcan2.sh     EXPECT_UNKNOWN=1 PASS ; EXPECT_UNKNOWN=6 PASS
canaudit.sh   audited=29 UNCOVERED=0 FENCE-BREACH=0
protected DBs InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical
              both modes; SVSwitch pin 4842211c4030 ; YosysVerx pin 6ccda350c24a
determinism   the patched binary, 3 runs x 2 views on g160_b_operand.sv: one md5 each
fences       the four slang-fenced test names: 0 / 0 / 0 / 0 hits in the patch
surface       results/*.csv diff = 0 lines; main tree git status clean;
              tracked surface = include(1) + src(2) + tools/probe/r10uvm160repro(53)
```

---

## 6. THE CODE, READ NOT ASSUMED

* **ALL-OR-NOTHING is sound.** The mint pass cannot produce a SHORT operand
  list. `emitDroppedArg14` has no null return for the two kinds the shape pass
  admits (`IdentifierName`, and a `.`-separated `ScopedName` with two
  `IdentifierName` children); `emitDroppedCall14` returns null on exactly one
  condition, `droppedCallShape14(e) == nullptr`, which the shape pass already
  asked through the new `droppedCallShapeOk14` accessor; `splitScopedName12` is
  pure and deterministic; the string arm re-tests the same `rawText` guard.
* **the `::` arm cannot swallow a `.` name.** `splitScopedName12` requires
  `TokenKind::DoubleColon` at every level, so an `InvocationExpression` over a
  DOT-separated `ScopedName` that fails `droppedCallShapeOk14` falls through
  case (5) and ABSTAINS — measured as `d06_dot3call`, unchanged.
* **the literal's parenting is the bound arm's, transcribed.** The bound concat
  arm sets `suppressConstParent` (and clears `forceConstParent` under
  `inParamInit`) for a DIRECT literal operand when
  `!reemitting && !importedParamClone`, and the `StringLiteral` arm then tests
  `forceConstParent || (!suppressConstParent && parent is
  operation|bit_select|case_item)`. The recovery's `sup160`/`frc160` is that
  pair of decisions with the parent-kind test collapsed (the parent is always
  the recovered `operation`). The bound arm's `VpiEndColumnNo` backslash bump
  applies only under an `assignment` parent and so is correctly absent here —
  independently confirmed by `l03_escbs` reaching CMP_EQUAL.
* **no `noteUnsupportedAt` on the abstention path** — reproduced as a live
  hazard: `unsupportedKinds` drives `uhdm_main`'s exit code and
  `verify_golden.py` reads a non-zero rc as `SLANG_REJECT` (RESUME §9's rc=139
  trap in a milder form). Every one of the 19 abstaining cells here exits 0.

---

## 7. RANKED RESIDUES (all MEASURED; none is a regression)

* **R-V1 — a PACKAGE-qualified `::` operand.** Golden constant-FOLDS
  `pkg::PARAM` inside a rejected concatenation; the recovery mints
  § `typeParamScopedCallRef59`'s bare `ref_obj`. Cell `c05_pkgscope`, 28 cmp
  lines, both views. Corpus cost **0** (0 wrong cells across the 9 moved
  databases). Cheapest next step: gate shape (5) on the qualifier resolving to
  a package parameter and emit the folded constant instead.
* **R-V2 — five unmodelled operand shapes** (the implementer's R1, confirmed):
  a BARE call, a nested concatenation, a TERNARY, a REPLICATION, a call whose
  actual is itself a call. Corpus cost **2 cells**, both
  `uvm_registry_common::create`'s message (`uvm_registry.svh:563`), whose
  operands include `obj == null ? "null" : obj.get_type_name()`.
* **R-V3 — the concat as a REPLICATION BODY.** `{2{ {"[", t.gt(), "]"} }}`
  hands back an Invalid wrapping a `Replication`, so the gate never sees a
  `Concatenation` child; the head sits on the braces wrapper one level up.
  Cell `d10_repl`, 77/81 cmp lines, identical on both binaries.
* **R-V4 — the macro-ARGUMENT vs macro-BODY span** (the implementer's R2).
  Pre-existing, **dump-only**: verified that no generated `Compare` for
  `operation` / `constant` / `ref_obj` / `hier_path` reads any line, column or
  file field. 16 dump lines per moved UVM row.
* **R-V5 — the leaked pointer** in a class-scoped `typedef <T> name[string]`'s
  right range (`array_typespec` -> `range` -> `operation` -> `constant`,
  `vpiSize:64`, `UINT:<address>`). Pre-existing, binary-layout-dependent,
  below `weaklyReferenced`. Two committed arms carry it; one of them
  (`r10uvm154repro/l154_noenum.sv`) was written to prove exactly this.
* **R-V6 — a class declared inside an INTERFACE or a PROGRAM** does not reach
  the law at all (cell `z03_iface`: byte-identical on both binaries, distance
  unchanged 227/419). Unmeasured whether the concatenation is emitted there at
  all; the corpus does not reach it.
* **R-V7 — a typedef'd class specialisation used as a MODULE VARIABLE's type.**
  Golden spells it `unsupported_typespec`, we spell it `class_typespec` (cells
  `h06_inst`, `h07_inst3`; 28 cmp lines). Pre-existing on BOTH binaries, merely
  UNMASKED here by the concat head clearing.

## 8. THE NEXT HEAD (R0), independently confirmed

The implementer's `head_pat_SimpleUVM.default.cmp` is **byte-identical** to
this verifier's own: **`chandle_var
(uvm_pkg::uvm_component_name_check_visitor::visit::compiled_regex)` @257:18,
parent `begin` @259:3-260:58** — a `static` method-local in a generic class
(`uvm-1.2/src/base/uvm_traversal.svh:257`) that golden lists and we do not.
29 cmp lines, 1 head, SimpleUVM both modes. R0b (Scoreboard/default, 145 lines,
`class_typespec (uvm_analysis_imp)`) likewise reproduces byte-for-byte, but
that row is the ~50/50 coin — re-measure before dispatching on it.

## 9. FILE MAP

```
README.md              this file
CELLS.r10v160.txt      the 81-cell table (pristine vs patched, both views)
GATES.r10v160.txt      every gate's raw output, including the cmds.txt audit
BOUNDARY.r10v160.txt   4462 arms: LISTED/PROCESSED/RC_DIFFS + every moved arm judged
DUMPDIST.r10v160.txt   order-blind distance for the 9 moved corpus rows + the cells
gencells160.py         emits one .sv per cell (81 of them) into cells/
varm160.sh             one arm/cell -> golden + both binaries + official uhdm-cmp, both views
vdd160.sh              order-blind, path-normalised distance for one cell workdir
vrowdd160.sh           the same for one sweep ROW, golden read from that row's cmds.txt
vnewwrong160.sh        the ADDED lines our patched DB has that golden does NOT
vbound160.sh           the wide boundary (fd 3, </dev/null, PROCESSED asserted, per-cell rc)
arms/                  five multi-cell arms (kept for the record; the CELLS are the judge)
cells/                 81 one-cell sources
```
