# r10vearl121 — ADVERSARIAL VERIFICATION of r10earl121 § `genCaPatKeepTagDefView121` — **VERDICT: ACCEPT-WITH-FIX.  Every headline number reproduced bit-for-bit from a fresh `c7a9d46c` (both binary md5s identical, `Earlgrey_0_1/default` 386 → 31 with the head OBJECT gone, 0/1358 and 1(+coin)/956 byte movers, 53 boundary cells all in the plain view).  ONE BREAK FOUND AND FIXED: the law also fired on a TYPE-QUALIFIED pattern (`T'{a: …}`), where Surelog's writer flattens through a THIRD path the decode missed — the `else if` arm that reads the RHS OPERATION's own `Typespec()` — and golden holds NO wrapper.  One conjunct added; the fix is corpus- and boundary-NEUTRAL (0 differing cells against the shipped binary over every committed arm, both views).**

**MEASUREMENT-ONLY.**  The official `uhdm-cmp` and `scripts/verify_golden.py` are
the only judges.  slang was NOT patched; `results/*.csv` were READ ONLY and
nothing was promoted; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests
were never dispatched and are named only inside the carried `canaudit.sh`'s own
`FENCED=` list, which this directory's boundary list-builder reads.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**  Every golden here was
built with `~/git-repos/Surelog/build/bin/surelog`, spelled in full (earl120 R4).

| | |
|---|---|
| BASE | `c7a9d46c`, two fresh worktrees (`/tmp/wt_vearl121`, `/tmp/wt_vearl121pris`) |
| pristine | md5 `56588c9fb921b2f7454ec8d10bfe1f7e` — **identical to the implementer's** |
| implementer's patched | md5 `5bbe3900b4c2d433fb0b42a4a035706d` — **identical**; the patch applied clean to a FRESH `c7a9d46c` |
| VERIFIED (shipped) | md5 `0012aafdad5e340faa6690773a21b0e6` — the same patch plus the one conjunct below |

---

## 1. WHAT WAS REPRODUCED, INDEPENDENTLY

Built both binaries myself, froze them `chmod 555`, exported `SLANG_UHDM`
per binary, and audited every `cmds.txt` BY BINARY PATH.

```
goldens          23 PASS / 0 FAIL on pristine, patched AND verified
                  0 PASS / 23 FAIL on /bin/false
uhdm2rtlil       679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, BOTH modes,
                 all three binaries;  ct8rows PASS (committed baseline, and
                 pristine-vs-patched in each mode);  byte movers 0 / 1358
surelog          1588 rows;  ct8rows pristine-vs-patched PASS (0 differing rows,
                 status AND dump);  byte movers 1 / 956 = default Earlgrey_0_1
                 (the PREDICTED name; the Scoreboard coin did not flip in my run)
heads            SeqDriver 50/50  SimpleUVM 17/17  Scoreboard 95/95  MiniAmiq 50/50
                 BuildUVMPkg 0/0 + 0/0   Rggen/default 0   Earlgrey/testflags 0
                 Earlgrey_0_1/default  386 -> 31, ONE head throughout
head OBJECT      before  LHS: tagged_pattern @tlul_socket_m1.sv:109:19  / RHS: hier_path
                 after   LHS: logic_var (…gen_host_fifo[0].shifted_id) @94:21 / RHS: <null>
canaries         51 + 8 ok;  ctcan2 PASS twice;  canaudit audited=29 UNCOVERED=0
                 FENCE-BREACH=0
protected DBs    InterfaceModPort / BlackParrotComplex / YosysOldOr SAME in both
                 modes;  SVSwitch 4842211c4030;  YosysVerx 6ccda350c24a
cmds.txt audit   surelog 1523/1573 correct, 0 wrong (50 without a slang line =
                 48 SURELOG_FAIL + 1 NO_UHDM + 1 TIMEOUT)
                 uhdm2rtlil 1458/1462 correct, 0 wrong (4 = 2 SURELOG_FAIL x 2 modes)
```

The one row-side differing from the committed baseline —
`Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` → `CMP_EQUAL,,,` — **appears in my
PRISTINE sweep too**, so it is not this patch's and not a conversion.  Status
unchanged; only the dump diagnostic column empties (`uhdm-dump` timeout under
concurrent sweeps, as earl119/earl120 recorded).  `results/*.csv` untouched.

---

## 2. THE BREAK — **A THIRD FLATTEN CALLER THE DECODE MISSED**

The implementer's law names two callers of
`ExprEval::flattenPatternAssignments`: Surelog's `UhdmWriter::writeCont_assign`
(gated by `bindVariable` finding the Lhs, i.e. `!genCaLhsGenLocal113`) and
`cont_assign::DeepClone` inside UHDM's `ElaboratorListener` (gated by
`--elabuhdm`).  There is a THIRD entry, in the SAME writer:

```cpp
      if (tps) { ... flattenPatternAssignments(s, tps, rhs) ... }      // caller (1)
      else if (rhs->UhdmType() == uhdmoperation) {                     // <== THE MISS
        operation* op = (operation*)rhs;
        if (const ref_typespec* ro1 = op->Typespec())
          if (const typespec* tps = ro1->Actual_typespec()) {
            UHDM::ExprEval eval(true);
            expr* tmp = eval.flattenPatternAssignments(s, tps, (expr*)rhs);
```
(`Surelog/src/DesignCompile/UhdmWriter.cpp:2219-2243`)

`bindVariable` never runs for this arm.  It reads the RHS OPERATION's own
`Typespec()` — and **a type qualifier on the pattern is exactly what fills
it**.  So a gen-local whole-name packed-struct target written `T'{a: …}` IS
flattened by the writer, in EVERY view, and golden holds no `tagged_pattern`
there at all.

**MEASURED** (`v6_cast2.sv`, three cells that differ in nothing but the
qualifier; `vgrid121.sh`, default view):

| cell | Rhs | golden | pristine | implementer's patch | VERIFIED |
|---|---|---|---|---|---|
| n1 module-local typedef | `s_t'{…}` | op **67** (cast), 1 operand, **ntag=0** | ntag=0 | **ntag=3 — AWAY** | ntag=0 |
| n2 gen-local typedef | `g_t'{…}` | op **67**, **ntag=0** | ntag=0 | **ntag=3 — AWAY** | ntag=0 |
| n3 plain (control) | `'{…}` | op 75, **ntag=3** | ntag=0 | ntag=3 (TO-GOLDEN) | ntag=3 |

and again as cell `f3` of `v2_fence121.sv`, beside thirteen cells that must not
move: golden ntag=0, pristine ntag=0, the shipped patch ntag=3, **the only cell
in every shape I could build where the patch went AWAY from golden**.

**HOW BAD:** judge-INVISIBLE today.  `operation::Compare`
(`~/git-repos/UHDM/build/generated/src/operation.cpp:98-128`) reads `VpiOpType`
BEFORE `Operands`, and golden's `67` against our `75` stops the walk above the
wrappers.  Corpus exposure is ZERO — no gen-scope pattern continuous assign in
either corpus or in any committed arm carries a type qualifier, which is why
every gate number below is the SAME with and without the fix.  It is fixed
anyway: a law must not claim a site whose golden shape it does not model, and
the census projection this campaign scores by calls that cell AWAY-GOLDEN.

### The fix — ONE conjunct

```cpp
auto& rc121 = stripImplicitConv(ae.right());
bool patTyped121 =
    rc121.syntax &&
    rc121.syntax->kind == syntax::SyntaxKind::AssignmentPatternExpression &&
    rc121.syntax->as<syntax::AssignmentPatternExpressionSyntax>().type != nullptr;
if (patFlat9 && genCaLhsGenLocal113 && !elabUhdmView121 && !patTyped121)
    patFlat9 = false;
```

`src/ModuleEmit.cpp` only; the `.type` idiom is the one `src/ParamEmit.cpp:644`
and `src/TypeEmit.cpp:14869` already use.  It is a strict NARROWING: on a
type-qualified pattern the emitter goes back to exactly what pristine did.

---

## 3. THE FIX IS CORPUS- AND BOUNDARY-NEUTRAL

Every gate re-run on the verified binary:

```
goldens                                   23 / 0
uhdm2rtlil  both modes                    679 / 50 / 2
  ct8rows  committed baseline vs verified            PASS
  ct8rows  pristine  vs verified   (tf and default)  PASS
  ct8rows  patched   vs verified   (tf)              PASS
  byteverify  verified vs pristine                   0 / 1358
  byteverify  verified vs patched                    0 / 1358
surelog     1588 rows
  ct8rows  pristine vs verified                      PASS (0 differing rows)
  ct8rows  patched  vs verified                      PASS (0 differing rows)
  byteverify verified vs pristine  2/956  = Earlgrey_0_1/default (PREDICTED)
                                          + Scoreboard/default (the COIN:
                                            raw diff 94 lines, ORDER-BLIND 0)
  byteverify verified vs patched   1/956  = Scoreboard/default (the coin ONLY)
                                            -- Earlgrey_0_1/default is
                                            BYTE-IDENTICAL to the shipped patch
heads       identical to the table in §1, Earlgrey_0_1/default 31, one head
canaries 51 + 8 ok · ctcan2 PASS twice · canaudit audited=29 UNCOVERED=0
protected DBs and both pins unchanged · cmds.txt 1523/1573 and 1458/1462, 0 wrong
```

**WIDE BOUNDARY** (`vwide121.sh`, list on fd 3, children `</dev/null`,
PROCESSED asserted, rc per side; the fence names filtered out of the list before
a child runs, read from `canaudit.sh`'s own `FENCED=` line).  The list is every
`.sv`/`.v` under a COPY of `tools/probe` that contains a `'{` — 489 of 5276,
`FENCED_REMOVED=0`; a file with no assignment pattern cannot reach this code at
all.

```
VERIFIED vs PATCHED   PROCESSED=489  identical=964  DIFFERING=0   no_output=14
                      rc by side  A/0 943  A/139 2  A/3 12  A/4 21
                                  B/0 943  B/139 2  B/3 12  B/4 21   SYMMETRIC
VERIFIED vs PRISTINE  PROCESSED=489  identical=911  DIFFERING=53  no_output=14
                      all 53 in the PLAIN view, ZERO in elab
```

53 is the implementer's own number, reproduced.  The differing set is
r10earl112-116's gen-scope pattern family and its verifier arms, plus
`r10earl61repro/v4_v61.sv` + `v5_v61.sv`, `r10vearl117repro/va3_scope117.sv`
and this pass's `a1_axis121` / `a3_net121` — every one of them named in the
implementer's report.  **The must-stay floor holds by name**: no
`r10earl106/110/111/117/118/119/120repro` arm, no `r10uvm8x`, no `r10buvm`,
no `r10sd8-12` file is in the list.  And DIFFERING=0 against the shipped
binary means every census and boundary number the implementer measured carries
over to the verified binary verbatim.

---

## 4. THE LAW'S DEFAULT HALF — 38 IN-WINDOW CELLS, ALL TO-GOLDEN, ZERO AWAY

Three arms built to break it, scored cell by cell against golden
(`vgrid121.sh`; `ntag` = `tagged_pattern` operands of that continuous assign's
Rhs).  In the DEFAULT view **golden == verified on every cell, and pristine is
0 on every cell**:

* **`v1_axis121.sv`** — 20 cells: baseline `for` generate; `if` generate; nested
  `for` with the target in the inner block; target in the OUTER block written
  from the inner one; an ANONYMOUS packed struct; `'{default: '0}`; member key
  MIXED with a default; a NESTED keyed pattern; concat/replication member
  values; a genvar-valued member; a gen-local localparam member; `var s_t`;
  a module-scope NAMESAKE that is a PARAMETER (must stay gen-local — golden
  TAGGED, and it is); a single-member struct; a function-call member; a DELAYED
  `assign #1`; a COMMA-LIST assign (two targets); a package-qualified type; a
  generate `if` nested in a generate `for`; and the same construct under a
  module instantiated TWICE.
* **`v3_probe121.sv`** — 12 cells: a NET-DECL-ASSIGN in a generate block; an
  explicit `wire`; an UNNAMED generate block; an explicit
  `generate`/`endgenerate` region; member values read from ANOTHER generate
  block; a generate `else` branch; a DRIVE-STRENGTH assign; a CASE generate;
  an all-constant pattern; a target read in its own block; and the whole
  construct inside an **interface**.
* **`v7_more121.sv`** — 6 cells: a typedef CHAIN; the target declared after the
  assign; a member value reading the target's own member; member keys mixed with
  `default:`; a nested struct with a nested keyed pattern; and a PARAMETERISED
  module instantiated with two different parameter values.

In the `--elabuhdm` view the verified and pristine dumps are **byte-identical**
on all three arms and on the fence arm — the law declines there by construction,
and the boundary says so independently (0 of the 53 differing cells is `elab`).

**The official judge on every arm, pristine → patched → VERIFIED** (each arm's
golden built with the harness Surelog and OUR side run with `--nobuiltin`, which
is what `verify_golden.py:664` adds for the harness's own `-parse -nobuiltin`
golden — WITHOUT it our extra `builtin` package makes `design::Compare` fail at
the `AllPackages` vector and every arm reads ~20 000 lines of whole-design head,
which is what the shipped `wide121.sh` would produce if it were ever pointed at
a golden; it is not, it only compares our two binaries to each other, so that is
a trap for the NEXT reader, not a defect in this pass):

```
a1_axis121   50  ->    0  ->    0     rc=0  CMP_EQUAL     (the implementer's number, reproduced)
a2_fence121  30  ->   30  ->   30
a3_net121    30  ->   30  ->   30
v1_axis121  342  ->  342  ->  342     head = named_begin (work@vaxis121.g5), DEF view
v2_fence121 486  ->  486  ->  486
v3_probe121 196  ->  196  ->  196
v6_cast2     17  ->   17  ->   17     head = ref_typespec -> unsupported_typespec (s_t)
                                             on golden's cast operation / RHS: <null>
v7_more121   54  ->   31  ->   31     IMPROVED
```

Not one arm goes UP; one improves; and `v2_fence121`/`v6_cast2` reading the SAME
count on the shipped patch as on pristine is the independent proof that the
break found in §2 is judge-invisible today.

**`v2_fence121.sv`** — 14 cells that must not move: a MODULE-scope target
written from a gen scope; a gen-local target whose NAME is a module-body
variable (the namesake half); a `bit_select` Lhs; a member (`hier_path`) Lhs;
a POSITIONAL pattern; a REPLICATION; a module-scope continuous assign; an
`always_comb`; a gen-scope localparam initialiser; an UNPACKED struct target;
a packed UNION target; and the type-qualified cell above.  Verified == golden
on all fourteen; the shipped patch differed on exactly one (f3).

---

## 5. RESIDUES, RANKED

* **R1 (biggest, and BIGGER than the implementer's framing) — THE `-elabuhdm`
  HALF OF EARL116'S LAW IS WRONG WHENEVER SURELOG MODELS THE GEN-LOCAL TARGET
  AS A `struct_net`.**  `cont_assign::DeepClone` tests
  `Actual_group<struct_var>`; a `struct_net` never flattens.  The implementer
  filed this as a `wire`-only corner (their R1, arm `a3_net121`).  It is not a
  corner: in `v1_axis121` **every one of the 20 gen-local targets comes out
  `struct_net` in golden** — `s_t c;`, `var s_t c;`, package-qualified or not —
  and golden is therefore **TAGGED in the ELAB view too**, where we are FLAT on
  all 20 cells, on BOTH binaries.  `q1_lhs116`'s `c1_t` is a `struct_var` and
  does flatten, so the two arms disagree and the discriminator is still unnamed.
  PRE-EXISTING and untouched by this pass (the elab dumps are byte-identical
  pristine-vs-verified), but it is a whole family, not one cell.  Start from
  `v1_axis121.sv` cell c1 and `q1_lhs116.sv` cell c1 side by side.
* **R2 — R0's family.**  `Earlgrey_0_1/default`'s new head,
  `LHS: logic_var (…gen_host_fifo[0].shifted_id)` at `tlul_socket_m1.sv:94:21`
  / `RHS: <null>`: golden lists a gen-local declared-and-continuously-assigned
  object under the gen scope's own vector and we do not.  Confirmed
  pre-existing (present on the pristine binary), merely unmasked.
  `a3_net121.sv` and `v1_axis121.sv` are both reduced repros.
* **R3 — `bindVariable` HAS NO `interface_inst` CASE either.**  Its walk knows
  `function`/`task`/`begin`/`module_inst` only, so an INTERFACE-BODY target
  written from a generate block inside that interface is NOT found and golden
  keeps its wrappers — while `genCaLhsGenLocal113` calls it "not gen-local" and
  we flatten.  Same direction on both binaries (this pass changed nothing
  there), so it is earl113's residue, not this one's; `v3_probe121.sv`'s
  interface cell is the in-window half and passes, the module-body-of-an-
  interface half is unbuilt.
* **R4 — HYGIENE.**  `tools/probe/r10earl121repro/widerun121.sh` does
  `rm -rf "$COPY"` on a DEFAULT hard-coded path (`/tmp/r10earl121_probecopy`),
  and `wide121.sh` defaults `STAGE` the same way.  Both are env-overridable, so
  the brief's "no `rm -rf` on hard-coded scratch" is only softly breached — but
  a concurrent pass that reused the default would have its stage deleted
  underneath it.  This directory's `vwide121.sh` requires `STAGE` and does not
  delete anything.

---

## 6. FILES

| file | what it is |
|---|---|
| `v1_axis121.sv` | 20-cell IN-WINDOW axis (generate shape × member form × instance count) |
| `v2_fence121.sv` | 14-cell FENCE, including the type-qualified cell that broke the law |
| `v3_probe121.sv` | 12 shapes that could have given the writer a typespec (net-decl-assign, unnamed/case/else generate, strengths, interface) |
| `v6_cast2.sv` | the BREAK, minimal: module-local and gen-local typedef casts beside a plain control |
| `v7_more121.sv` | 6 further in-window shapes (typedef chain, decl-after-use, self-reading member, default mix, nested, parameterised ×2) |
| `vcells121.py` | per-`cont_assign` census of a `uhdm-dump`: Rhs kind, `vpiOpType`, operand kinds, `ntag` |
| `vgrid121.sh` | builds each arm's golden BOTH ways with the harness Surelog and each named binary in each view, and prints the `ntag` line per side |
| `vwide121.sh` | the boundary: A-vs-B binary over a file list, both views, workdir-normalised dump compare, rc per side, PROCESSED asserted |
