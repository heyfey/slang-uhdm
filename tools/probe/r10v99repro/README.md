# r10v99 — ADVERSARIAL VERIFICATION of r10uvm99 (§ `insideSetFirstRangeTruncates99`)

**VERDICT: ACCEPT (with a comment-only correction to `r10uvm99repro/bound99.sh`).**
No pristine-right → patched-wrong cell was found on legal SystemVerilog in any
arm, any view, either corpus. The production surface (`src/ExprEmit.cpp`) is
**unchanged by the verifier** — it is byte-identical to the shipped patch.

**MEASUREMENT ONLY.** `~/git-repos/UHDM/build/bin/uhdm-cmp` and
`scripts/verify_golden.py` are the only acceptance judges used here.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**
slang was NOT patched; `results/*.csv` were READ ONLY; nothing was promoted;
**no corpus row converted.**

| | |
|---|---|
| BASE | `40a0097` |
| verifier worktrees | `/tmp/wt_v99` (patched), `/tmp/wt_v99pris` (pristine) — both fresh at `40a0097` |
| pristine binary | md5 `213ee8e1cada6a1013f277e4f7f7c8d2` (frozen `chmod 555`) |
| patched binary | md5 `73e9b33d1cd399d1ef0cc60d2292cc00` (frozen `chmod 555`) |

Both binaries were rebuilt from scratch by the verifier (`-j 2`, Release,
gcc-toolset-14) and **both md5s reproduce the implementer's headline hashes
bit-for-bit**.

## 1. Every headline number, re-measured independently

| claim | verifier measurement |
|---|---|
| goldens 23/0 both binaries, `/bin/false` 0/23 | **reproduced** |
| u2r `679 / 50 / 2` both modes both binaries | **reproduced** |
| surelog default `470/283/25/11/5` | **reproduced**, both binaries |
| surelog testflags `466/284/23/9/5/3/2/1/1` | **reproduced**, both binaries |
| all three CSVs byte-identical pristine vs patched | **reproduced** (`cmp -s`) |
| `ct8rows` PASS vs committed baselines AND vs own pristine sweeps | **reproduced** (6 comparisons, all PASS) |
| `cmds.txt` audit 1523 surelog / 1458 u2r per sweep, own binary only | **reproduced** (1573/1462 files scanned; 100 % of `slang:` lines name the frozen path) |
| `byteverify SELFCHECK=1` u2r **0/1358** | **reproduced** (selfcheck 1357/1358) |
| `byteverify SELFCHECK=1` surelog **9/956**, exactly the nine names | **reproduced** (selfcheck 955/956) |
| each mover's whole-dump diff **17 lines ORDER-BLIND on all nine** | **reproduced** — 17/17 on all nine (my pristine run did not flip the coin, so ordered == order-blind == 17 everywhere) |
| the 17 lines = the `vpiOpType:37` wrapper + `UVM_PHASE_CLEANUP` leaving, `UVM_PHASE_STARTED` taking operand 2 | **reproduced**, line for line |
| all nine movers were already `CMP_NOTEQUAL` rows | **reproduced** (no `CMP_EQUAL` row moved, status or dump) |
| heads: SeqDriver ×2, MiniAmiq ×2 **50 → 13** | **reproduced** |
| heads: SimpleUVM ×2, Scoreboard/default **108 → 108**, byte-identical | **reproduced** (`diff` IDENTICAL) — the **CORRECTION to uvm98's R0 stands** |
| BuildUVMPkg 166, Earlgrey 216, Rggen 194 unchanged | **reproduced** |
| committed `head_pat_default_SeqDriver.cmp` / `head_pris_default_SeqDriver.cmp` / `head_pat_default_SimpleUVM.cmp` | all three **byte-identical** to my re-measured heads |
| canaries `ok=52` / `ok=8` `changed=0`; `ctcan2` PASS ×2; `canaudit audited=33 UNCOVERED=0 FENCE-BREACH=0` | **reproduced** |
| pins `SAME=10 MOVED=0`, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **reproduced** |
| determinism ×3 on SeqDriver | **reproduced** (3 × byte-identical) |
| patch applies clean on a FRESH `40a0097`, surface = `src/ExprEmit.cpp` + `r10uvm99repro/` only, fence check 0/0/0/0 | **reproduced** |

The census was re-run with an **independent instrument** (`vcen99.py`): same
uhdm-dump tree source, but the payload is **SPAN-FREE** (operand kinds, names,
values and nested op-types only; the span appears in the identity KEY, never in
the compared value). Golden-vs-golden calibration on SeqDriver default vs
testflags: **51 rows each, 0 differing lines**. On the nine movers:

```
default/SeqDriver-32af76aa     cells 49  ALREADY-OK 46  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 1
default/SimpleUVM-1dc93a62     cells 47  ALREADY-OK 45  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
default/MiniAmiq-544c7f61      cells 56  ALREADY-OK 53  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 1
default/Scoreboard-59431470    cells 47  ALREADY-OK 45  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
default/BuildUVMPkg-bf853d43   cells 13  ALREADY-OK 11  TO-GOLDEN 2  AWAY-GOLDEN 0  STILL 0
(+ the four testflags rows, identical counts; MULTISET and SET agree on all nine)
```

Identical to the implementer's table, cell for cell, from a different payload.
The two TO-GOLDEN slots are always `('INSIDE', 'find@199:38-199:101')` and
`('LISTOP', 'find@199:63-199:100')` (BuildUVMPkg: the same site at its
pp_output line 35470). **AWAY-GOLDEN 0 everywhere.**

## 2. The law, re-derived from the grammar (not from the write-up)

The implementer's mechanism is correct AND has a grammatical reason the write-up
does not state. `SV3_1aParser.g4`'s `expression` rule lists
`expression (LESS | LESS_EQUAL | GREATER | GREATER_EQUAL | INSIDE)
attribute_instance* expression` **before**
`expression INSIDE OPEN_CURLY open_range_list CLOSE_CURLY`. ANTLR takes the
first alternative that matches, so:

* `{1, 2, 3}` **is** a syntactically valid concatenation → the EARLIER
  alternative wins → `rval` is `Expression → Primary → Concatenation` →
  `Child(Child(rval))` is the Concatenation and the sibling walk yields
  **every member**;
* `{[1:3]}`, `{4,[6:8],11}` are **not** valid concatenations (a `[a:b]`
  value_range is not an expression) → the later alternative wins → `rval` is
  the `Open_range_list` → `Child(Child(rval))` is the FIRST `Value_range`'s
  FIRST bound `Expression`, and `Expression = fC->Child(false_concat)` then
  walks **that node's children** (`CompileExpression.cpp:2362-2371`).

So the discriminator really is **"any member is a `[a:b]` range"**, and it is
the PARSE that decides, exactly as `insideTrunc99` implements it.

## 3. The adversarial grid — 7 own arms × 2 views × 2 scorings, **BROKE 0 in all 28 runs**

Arms written from scratch by the verifier (different names, orders, widths,
literal values and scopes from the implementer's, per "an arm agreeing is not an
arm testing"). `vthree99.sh` = golden / pristine / patched three-way, rc per
cell, both views.

| arm | what it pins | def | elab |
|---|---|---|---|
| `v99_b1_shapes.sv` | 18 set shapes in `if` conditions: bare value, plain list, `[a:b]`, range-first, range-last, two ranges, localparam bounds, **enum bounds**, `[4:$]`, `[$:6]`, **negative bounds**, **string range**, unpacked-array member + range, queue member + range, element-select bounds, **parenthesised** first bound, compound first bound, **narrow LHS / int bounds** | FIXED 29 **BROKE 0** STILL 4 | FIXED 29 **BROKE 0** STILL 4 |
| `v99_b2_homes.sv` | cont-assign, net-decl-assign, `always_comb`, `always @(*)`, `while`, ternary, `initial`, function, task, **class constraint**, class method, **out-of-block method**, immediate `assert`, named `property`, inline `assert property`, and `find / find_index / find_first / find_last / unique / sum / min` **with**-clauses on queue, dynamic and associative arrays — **3 module instances** | FIXED 37 **BROKE 0** STILL 5 | FIXED 22 **BROKE 0** STILL 40 |
| `v99_b3_fence.sv` | **THE FENCE**: 10 range-free sets in 9 homes, `case … inside` with ranges, `covergroup` bins `{[0:3]}` / `{4,[5:7]}`, `constraint`, `dist { [1:3] := 1 }` | **FIXED 0 BROKE 0**, cmp 17 → 17 | **FIXED 0 BROKE 0**, 17 → 17 |
| `v99_b4_deep.sv` | nested parens, parenthesised LHS, **function-call bound**, **cast bound**, **concatenation bound**, `inside` **nested inside** `inside`, two `inside`s in one expression, negated `inside`, queue-element LHS, **genvar-dependent bound**, 3 instances | FIXED 34 **BROKE 0** STILL 0 — **`CMP_FAIL` → `PASS_CMP`** | FIXED 25 **BROKE 0** — **`CMP_FAIL` → `PASS_CMP`** |
| `v99_b5_conv.sv` | the **implicit-conversion hypothesis**: 64-bit LHS with `byte` bounds, 4-bit LHS with `shortint` bounds, signed/unsigned mixes, plus `foreach`, `wait`, `randcase`, `sequence`, covergroup `with` | FIXED 10 **BROKE 0** STILL 6 | FIXED 10 **BROKE 0** STILL 6 |
| `v99_b6_paren.sv` | **parenthesised compound bounds** (see R1a below) | FIXED 2 **BROKE 0** STILL 10 | FIXED 2 **BROKE 0** STILL 10 |
| `v99_b7_order.sv` | ordering / reduction methods: `sort`, `rsort`, `reverse`, `unique_index`, `product`, `max`, `sum`, `find`, `find_index` on queue, dynamic **and associative** arrays | FIXED 12 **BROKE 0** STILL 0 | FIXED 6 **BROKE 0** STILL 6 |

Every `STILL` cell was re-checked with `vstill.py`, which splits `STILL` into
`P == Q` (untouched) and `STILL-MOVED` (both wrong, but differently). **Every
single `STILL-MOVED` cell moves the payload TOWARD golden** — the operand list
becomes golden's; what remains is the pre-existing ELAB copy-count / naming
family (golden's extra copy scoped `…::i1b2.qb2.itb2`, `work@mub2` vs
`work@topb2.i1b2`). **Not one cell moved away from golden in any arm.**

The **implicit-conversion hypothesis is REFUTED**: `b5` lines 15 and 17
(64-bit LHS with `[bb5+1:bb5+4]`, 4-bit LHS with `[sh5+1:9]`) both reach the
`nullptr` arm and keep the pristine emission — slang does not wrap a
`ValueRange` bound in a `Conversion` node that could sneak a compound bound
past the R1 gate.

## 4. The wide boundary — per-FILE **and** per-DIRECTORY, from a COPY, both views

`vbound.sh`, over a COPY of the whole patched `tools/probe` tree, no path
filter, `.sv` **and** `.v`, fd-3 list, children `</dev/null`, PROCESSED
asserted, rc recorded and compared per cell.

```
FILE_ARMS: LISTED=3182 FENCED_SKIPPED=0 PROCESSED=3182 MOVED=16
           NO_OUTPUT_PAIRS=270 RC_PAIRS=6364 RC_DIFF=0 ASYM=0   PROCESSED-ASSERT-OK
DIR_ARMS : LISTED=1438 PROCESSED=1438 MOVED=7
           NO_OUTPUT_PAIRS=239 RC_PAIRS=2876 RC_DIFF=0 ASYM=0
```

The **file** half reproduces the implementer's `MOVED=16` cell for cell (14 own
arms — the positive control — plus `r10uvm92repro/v92_b1_break.sv` in both
views).

The **directory** half is NEW (`bound99.sh` runs per-file arms only, although
its header claimed otherwise; corrected in this patch). Its 7 moved cells are:

| cell | verdict |
|---|---|
| `r10uvm99repro/` def+elab | the pass's own arms (positive control) |
| `r10uvm92repro/` def (50 lines) | the `v92_b1_break.sv` contribution, attributed below |
| `r10uvm75repro/` def (16) + elab (14) | **order-blind diff = 0** |
| `r10uvm76repro/` def (20) + elab (18) | **order-blind diff = 0** |

The uvm75/uvm76 cells are the documented emitter NONDETERMINISM (a `vpiTaskFunc`
list order flip), not this patch: running the **pristine binary alone** three
times over the same `r10uvm75repro` directory arm flips **12 lines** run to run
(`pris1 vs pris2 = pris1 vs pris3 = pris2 vs pris3 = 12`). Order-blind, nothing
moves. **Zero real non-own regressions in either half, in either view.**

`v92_b1_break.sv` re-attributed three-way against golden, both views:
`CMP_FAIL` → `CMP_FAIL`, head **18 lines, byte-identical** pristine vs patched;
census FIXED 2, **BROKE 0**; and a sorted `vpiName` / `vpiFullName` /
`hier_path` line extraction is **byte-identical** (0 lines moved) — uvm92's
`§ hpIdxOpPrettyPrint92` is untouched.

Because the boundary compares the WHOLE dump byte-for-byte over every committed
arm in `tools/probe`, it is strictly stronger than a field-scoped comparator:
the `vpiListOp` precedent arms, uvm97/98's typedef laws, buvm18/20's
class-typespec arms, uvm82–91, buvm3–15 and sd8–12 are all inside it and all
show **no move**.

## 5. Residues found or refined by the verifier

* **R1a (NEW, measured).** *A PARENTHESISED compound first bound behaves as a
  PRIMARY in golden.* `v99_b6_paren.sv`, golden operand 2:

  | source | golden | ours (pristine **and** patched) |
  |---|---|---|
  | `{[(PV6+1):QV6]}` | `op24{4|1}` — the whole `PV6+1` | `op37{op24{4|1}|20}` |
  | `{[(-PV6):QV6]}` | `op1{4}` | `op37{op1{4}|20}` |
  | `{[(sel6 ? 1 : 2):QV6]}` | `op32{sel6|1|2}` | `op37{op32{…}|20}` |
  | `{[((PV6+1)):QV6]}` | `op24{4|1}` | `op37{op24{4|1}|20}` |
  | `{[PV6+1:QV6]}` (no parens) | `4 , unsupported_expr , 1` — the R1 splice | `op37{…}` |

  Cause: `expression : OPEN_PARENS expression CLOSE_PARENS` gives the
  `Expression` node exactly ONE child, so Surelog's walk compiles it whole —
  but slang drops parentheses, so `insideTrunc99` sees `BinaryOp` / `UnaryOp` /
  `ConditionalOp` and returns `nullptr`. This is a **MISSED FIX, never a
  regression** (patched == pristine on all four). Fixable by consulting
  `expr.syntax->kind == SyntaxKind::ParenthesizedExpression` before the kind
  switch. **No corpus reach** (see below), so it is left for a later pass.

* **R1b (refinement of the implementer's R1).** A **unary** first bound does not
  splice an `unsupported_expr`; it **duplicates**. `{[-9:-2]}` gives golden
  `LHS , op1{9} , 9` — the operator node compiles the WHOLE unary expression and
  the operand primary is then compiled AGAIN as a separate operand
  (`v99_b1_shapes.sv:41`). The implementer's README frames R1 only as the
  binary `unsupported_expr` splice. Both stay pristine under the gate.

* **R1 corpus reach: measured NONE.** `uhdm2rtlil` contains **zero** ranged
  `inside` sets (grep over all 731 tests), which is why `byteverify` reads
  `0 / 1358`. Every one of the nine surelog movers has exactly one moving site,
  `uvm_domain.svh:199`, whose bounds are both bare enum primaries.

* **Non-comparable shapes (informational).** Surelog cannot PARSE a ranged
  `inside` in a constant expression (`localparam bit K = (5 inside {[1:9]});`)
  or in a generate-if condition (`if (P inside {[1:2]})`) — both are
  `[SNT:PA0207]` syntax errors, so those rows are `SURELOG_FAIL` and
  non-comparable. Our binary emits a truncated operand list there; harmless,
  but it is not evidence for the law either.

* The implementer's **R0** was verified at the object level, not just the text:
  our `delay_control @1260:15-1260:27` under
  `uvm_pkg::uvm_test_done_objection::all_dropped` carries **only** `vpiParent`
  — **no `vpiDelay` child at all** — against golden's `@1260:13-1260:28`
  carrying a `ref_obj @1260:15-1260:27`. Two defects at one site
  (`` `uvm_delay(stop_timeout) ``, `uvm-1.2 base/uvm_objection.svh:1260`), as
  claimed. (The golden `ref_obj` has no `vpiName`; the
  `uvm_pkg::uvm_test_done_objection::all_dropped` string the dump prints for it
  is the SYNTHESISED fullname from the parent chain, not a name it owns.)

## 6. Files

| file | what it is |
|---|---|
| `v99_b1..b7_*.sv` | the seven verifier arms |
| `vthree99.sh` | three-way arm scorer (golden / pristine / patched), rc per cell, both views |
| `vcen99.py` | the independent, SPAN-FREE census instrument |
| `vstill.py` | splits `STILL` into `P == Q` and `STILL-MOVED`, and re-checks `BROKE` |
| `vbound.sh` | the wide boundary, per-FILE **and** per-DIRECTORY arms |
| `vattrib.sh` | per-mover ordered + order-blind whole-dump attribution |
| `vcorpcen.sh` | the corpus census driver (golden from the cache path in `cmds.txt`) |
| `VERIFY.r10v99.txt` | the full transcript of every number above |
