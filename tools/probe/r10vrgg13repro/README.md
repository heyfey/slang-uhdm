# r10vrgg13 — ADVERSARIAL VERIFICATION of r10rgg13 (§ genLpPaCallArgCopy13)

**MEASUREMENT-ONLY directory.**  The official `uhdm-cmp` is the sole judge.
**BASE `49634d2`.**  `results/*.csv` was READ ONLY and is untouched.

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number in the implementer's
write-up reproduced bit-for-bit from my own builds.  One **pristine-right →
patched-wrong** cell was found on legal SystemVerilog and is fixed here by
**gate clause (5)**; the fix is inert on the target (Rggen's database is
byte-identical to the shipped patch's).  Ship `/tmp/r10rgg13.verified.patch`.

---

## 1. REPRODUCTION — every headline number, from my own binaries

Two fresh worktrees at `49634d2` (`/tmp/wt_vrgg13pris`, `/tmp/wt_vrgg13`),
patch applied with `git apply --check` then `git apply`, both built `-j 2`,
md5 taken only after `Built target slang_uhdm`, both `chmod 555` before any
sweep, `SLANG_UHDM` exported explicitly per binary, every `cmds.txt` audited
by binary PATH.

| claim | implementer | **verifier** |
|---|---|---|
| base binary md5 | `cddfb450fab71ea1d2820f0f2366ad7f` | **identical** |
| patched binary md5 | `02e1ee388232ba895cb220d77873e879` | **identical** |
| goldens base / patched / `/bin/false` | 23-0 / 23-0 / 0-23 | **23-0 / 23-0 / 0-23** |
| u2r both modes, status histogram | 679/50/2 per mode | **1358 CMP_EQUAL / 100 SLANG_REJECT / 4 SURELOG_FAIL over both** |
| u2r testflags vs committed `gate_uhdm2rtlil.csv` | 0 differing rows | **0 differing ROWS** (base and patched) |
| u2r patched vs my own base, both modes, whole row | 0 | **0 differing ROWS** |
| surelog vs committed `golden_surelog.csv`, 1588 rows | 0 differing rows | **0 differing ROWS** (base and patched) |
| u2r byteverify SELFCHECK=1 | 0 movers / 1358 | **selfcheck 0; base-vs-patched 0 MOVERS / 1358** |
| surelog byteverify | 2 movers: `default/Rggen`, `default/Scoreboard` | **exactly those two, 954 identical / 956** |
| Rggen/default head | 64 → 36 cmp lines, 1 head | **64 → 36, 1 head** |
| all other named rows | unchanged | **unchanged** (SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 164, BuildUVMPkg 84, Earlgrey_0_1 64, both modes) |
| Rggen whole-dump path-normalised diff | 22 removed / 22 added over 1,580,844 | **22 / 22 over 1,580,844** — the 11 constants' `VpiValue` + `VpiConstType`, nothing else |
| Rggen census, Compare-visible | FIXED 22, BROKEN 0, 868 → 846 | **FIXED 22, BROKEN 0, MOVED-STILL-WRONG 0; 868 → 846 over 42,307 keys** (42,303 golden rows) |
| canaries / ctcan2 / canaudit | 52-0, 58-0 unknown=1, 29 UNCOVERED=0 | **52-0 (surelog) and 8-0 (u2r tf slice); ctcan2 58-0 unknown-patterns=1; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| byte pins | held | **SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical, both modes** |

### 1a. The head, decoded independently from MY pristine cmp log

`golden constant INT:2 sz 32 ct 7` at `rggen_or_reducer.sv:62:62-62:63`,
parented at `N`'s own `param_assign` (3:17-3:26), typespec `int_typespec@3:13`;
ours `UINT:2 sz 32 ct 9`, parented at `func_call(get_sub_n_list)@62:47`,
typespec `int_typespec@8:55`.  Read off the GENERATED code, not the dump:
`constant::Compare` → `expr::Compare` (VpiDecompile `2`==`2`, VpiSize 32==32,
`SafeCompare(Typespec())`) → `VpiConstType` 7 vs 9.  `int_typespec::Compare`
reads only `Cast_to_expr` / `VpiSigned` / `Ranges`, so the two DIFFERENT
typespec objects compare EQUAL.  **`VpiConstType` is the only failing field**,
and no generated `Compare` reads `VpiValue` or `VpiParent`.  Confirmed.

### 1b. `default/Scoreboard` IS the coin — proved, not asserted

`evidence/COIN_scoreboard_VERIFIED.txt`.  Six repeats of the exact sweep
command line per binary, from the test's own source directory:

* BASE binary: **6/6** → `3bfa612c78c8f2d308e8545745d464d6`
* PATCHED binary: **5/6** → the SAME `3bfa61…` hash, 1/6 → `64250f…`
* the two sweep databases: base `3bfa61…`, patched `ec98da…` (a THIRD face)
* `uhdm-dump`, 1,099,524 lines a side: raw diff **172 lines**, order-blind
  (sorted, `id:` stripped) diff **0 lines**

The patched binary reproduces the base sweep's exact bytes in five runs out of
six and the difference is pure ORDER.  Attribution accepted.

---

## 2. THE ADVERSARIAL GRID — 179 cells, 11,930 census keys, BOTH views

`gen_arms_v13.py` builds one cell per shape; `runarms_v13.sh` builds the
GOLDEN, BASE and PATCHED database of every cell in the **default** view AND in
the **`-elabuhdm`** view, cmps all six and censuses all six.  Axes crossed:

* **12 argument shapes** — bare parameter, bare localparam, `P+1`, `ARRP[1]`,
  `fn2(P)` (nested call), literal `3`, `int'(P)` (cast), `{P[3:0],P[3:0]}`
  (concat), `P>1?P:Q` (ternary), `{2{P[1:0]}}` (replication), `-P`, `$clog2(P)`
* **12 formal types** — `int`, `integer`, `byte`, `shortint`, `longint`,
  `bit [7:0]`, `logic [31:0]`, `bit signed [31:0]`, bare-implicit `n`,
  `signed n`, typedef'd `int`, typedef'd `bit [7:0]`
* **6 override encodings per cell** — `2`, `8'h03`, `4'b0101`, `3'o5`, `1+3`,
  none (declaration default `8'h07`), plus `'h4`/`'d5`/`'o6` unsized and a
  negative override in their own cells
* **parameter kinds / homes** — module parameter port, body localparam,
  gen-if / gen-for scope, package, `$unit`, class, interface
* **callees** — module function, package function, `$unit` function, class
  static method, named association in formal order, named association
  REORDERED, a defaulted formal, two arguments
* **positions** — `param_assign` Rhs, cont-assign, port actual, parameter
  override actual, declaration range bound
* **dimension axis** — 1-D, 2-D, 3-D, typedef'd 2-D, vector typedef + extra
  dim, unpacked array
* **instances** — 1, 2, 3, and 7 instances with distinct overrides, two
  identical instances (body dedup), nested `mid`→`leaf` re-specialization
* **the `elabCallFormal` collision** — the same parameter ALSO passed to a
  bare-implicit / ranged formal elsewhere, in both declaration orders

Result, Compare-visible fields, DEFAULT view and `-elabuhdm` view alike:

```
SHIPPED patch : FIXED=140  BROKEN=2  MOVED-STILL-WRONG=56  OK=10519  STILL=1213  TOTAL=11930
VERIFIED patch: FIXED=140  BROKEN=0  MOVED-STILL-WRONG=54  OK=10521  STILL=1215  TOTAL=11930
```

Only ELAB-view rows move; the DEF view is byte-untouched, as the write-up says.
Every one of the 54 MOVED-STILL-WRONG rows was read: each moved TOWARD golden
(value / size / constType now match, only the clause-2 typespec KIND still
differs) or laterally (`g_nested_inst`: base `dec=3`, patched `dec=32'h03`,
golden `dec=8'h03` — `expr::Compare` fails at the same field either way).
**No row moved away from golden on a field the judge reads.**

---

## 3. THE DEFECT — `cells/vg1`, pristine-right → patched-wrong

```systemverilog
module mid #(parameter int P = 8'h07)(output logic o);
  function automatic int sym(int n); return n; endfunction
  localparam int S = sym(P);                    // S's own Rhs is a FOLDED USER CALL
  function automatic bit [P-1:0][15:0] flp(int n); ... endfunction
  localparam bit [P-1:0][15:0] LP = flp(S);     // the argument is S
endmodule
module top; mid #(.P(2)) u1(); mid #(.P(8'h03)) u2(); endmodule
```

Census, instance `u1`, key `ELAB|ARG|work@top.u1|LP|fc:flp|0`:

```
golden  const(UINT:2, sz 32, ct 9, dec 2)   /P:param_assign@3:18   <- golden DOES take the copy
base    const(UINT:2, sz 32, ct 9, dec 2)   /P:func_call@7:37      <- RIGHT on every compared field
patched const(BIN:0…010, sz 32, ct 3, dec 32'b0…010)               <- BROKEN
```

**The law is right; the SOURCE is not.**  Golden's argument really is a clone of
`S`'s own `param_assign` Rhs — golden's `S` Rhs is `UINT:2 ct 9`.  **Ours is
not**: for `localparam int S = sym(P)` this exporter already emits
`BIN:0…010 ct 3` (the ExprEval-producer encoding of a folded user const-call —
a pre-existing, unrelated residue, visible as a `STILL` on the `ELAB|PA|…|S`
row in BOTH binaries).  The copy therefore carries a DIFFERENT law's error into
an argument the pre-existing UINT fold happened to get right.  2 census rows
BROKEN (the `ARG` row and the enclosing `PA` row are the same object seen
twice); the cell's `uhdm-cmp` line count does not move, so **only the census
sees it** — a cmp-line-count-only check would have shipped this.

### The fix — gate clause (5), 22 lines including the comment

```cpp
// (5) THE SOURCE PARAMETER'S OWN INITIALIZER MUST NOT CONTAIN A SUBROUTINE CALL.
static bool paramInitCallFold13(const slang::ast::ParameterSymbol& ps);   // AST scan
...
    if (paramInitCallFold13(ps))
        return nullptr;
```

Surelog's clone arm copies `param_ass->Rhs()`, so the copy is a faithful model
of golden's only when OUR OWN `param_assign` Rhs for that parameter is the one
golden has.  A parameter whose initializer is itself a user const-call is
exactly the case where it is not.  The clause is conservative in the other
direction (a source whose *declaration default* is a call but whose instance
override is a literal simply keeps the pre-existing fold — a `STILL`, never a
break).

**The fix is INERT ON THE TARGET.**  Rebuilt binary
`4269caa03e161001eccea6ca93867988`; the Rggen database it produces is
**byte-identical** to the shipped patch's, head still 64 → 36 with 1 head, and
the Rggen census is still FIXED 22 / BROKEN 0 / 868 → 846.

---

## 4. THE WIDE BOUNDARY — 2,912 arms, from a COPY

`boundary_v13.sh` over a COPY of the whole `tools/probe` tree (`slpp_all`
pruned), file list on **fd 3**, every child `</dev/null`, PROCESSED asserted
against LISTED, uncompilable and asymmetric arms counted, never skipped:

```
-- PROCESSED=2912 LISTED=2912 identical=2786 MOVERS=1 uncompilable=125 asymmetries=0
PROCESSED-ASSERT OK
MOVER r10rgg13repro/cells/pc1/top.sv   (base rc=0 pat rc=0 sizes 18369/18330)
```

**The only mover in the entire probe tree is the pass's own positive-control
cell**, which is simultaneously the proof that the comparator can see this
law's difference.  Every precedent arm — r10rgg1…12, r10vrgg2…11, r10rggen*,
r10earl*, r10uvm*, r10buvm*, r10sd*, r10scr*, everything else — is byte-
identical.  In particular **r10rgg11's copy-only re-cut cells and r10rgg12's
symbolic-call arms do not move**, and `cells/pc2` (the `func_upto` fence),
`pc3` (gen-scope home), `pc4` (non-int formal) and `pc5` (bare-implicit formal)
do not move.  The same walk against the VERIFIED binary is in
`evidence/BOUNDARY_base_vs_verified.txt`.

---

## 5. MEASURED CORRECTIONS to the write-up (no number is wrong; two are
   described more narrowly than the code behaves)

**C1 — gate clause (2) is not "the formal is a predefined integer type".**
`argIntFormal13(arg)` reads `arg->type`, which is the FORMAL's type only when
slang inserted a conversion.  For an `int` parameter passed to a
`bit signed [31:0]` formal the two types are equivalent, **no conversion node is
built, `arg->type` stays `int`, and the copy FIRES on a non-predefined-integer
formal.**  Measured, `cells/vg2` (= arm `a_bare__bitsgn`, 6 instances): the arm
fires, the argument's typespec stays `bit_typespec` where golden's is
`int_typespec`, and all six rows move TOWARD golden (base `UINT:3` → patched
`HEX:03` = golden's value/size/constType).  No break — but the law's true reach
is "no conversion, or conversion to a predefined integer type", and the
clause-2 rationale in § 4 of the implementer's README should say so.  The
`func_upto` fence is unaffected: that row is excluded by clause (1).

**C1b — the law also fires in an INTERFACE body**, which the write-up does not
mention (it names module instances only).  Arm `b_ifacehome`
(`interface ifc #(parameter int P)(); localparam bit [P-1:0][15:0] LI = flp(P);`)
goes **64 cmp lines → 0** — golden agrees, so this is correct reach, not a leak.
Arms that must NOT fire and do not: `b_genscope`, `b_genscope_outerparam`,
`b_pkghome`, `b_pkgparam`, `b_unitparam`, `b_class`, `c_classstatic`, `c_pkgfn`
(clause 3 and the `paramInitPkg` / `callArgDepth` guards), `e_1d` (clause 1),
`f_portactual`, `f_rangebound` (position), `d_barefirst_collision` /
`d_barelast_collision` / `d_rangedformal_collision` (the `elabCallFormal`
first-wins collision I hypothesised as an escape — REFUTED, base == patched).
`c_named_reordered` proves `argIdx` maps to the FORMAL slot, not the written
slot: golden's arg0 is `P`'s `HEX:03` and the patch reproduces it while arg1's
`bit [7:0]` formal correctly stays out of the arm.

**C2 — `elabParamPa` is keyed by symbol and holds the LAST emitted
`param_assign` for it.**  Verified harmless here (slang gives distinct
`ParameterSymbol`s to distinct specializations and dedups identical ones, so
the value is the same either way): arms `g_threeinst` (7 instances incl. two
identical) and `g_nested_inst` (re-specialization one level down) both behave.

---

## 6. RANKED RESIDUES (re-measured, not carried forward)

1. **R0, the new `default:Rggen` head (36 lines, 1 head)** — a `bit_select`
   index constant whose `vpiDecompile` still carries the genvar text
   (`"10+i"` vs `"10"`), same family as the 24 `hier_path` port rows.  25
   objects.  Confirmed present in my own patched database.
2. **R-A, 810 census rows** — `op11[ref(WIDTH),UINT:1]` range bounds in
   gen-scope-homed interface declarations.  Unmoved, and my grid agrees it is
   not this law's mirror (position, not operation, is the discriminator).
3. **clause-2 residue** — a copy under a non-`int` formal keeps OUR formal
   typespec where golden keeps the parameter's; 54 arm rows, 0 corpus rows.
   `cells/vg2` is the arm.
4. **`e_typedefvec_extradim`** — golden folds the whole `w_t [3:0] LP = flp(P)`
   initializer to a 64-bit BIN constant and has NO surviving call at all, where
   we keep the `func_call`.  Structural, pre-existing, 0 corpus reach; the new
   law fires inside a call golden does not have.  Worth a pass of its own.
5. **`g_symbolic_rhs_param` instance u2** — golden keeps a bare `ref(S)` where
   we fold a constant, because golden's `S` Rhs stayed a `func_call` and ours
   did not.  Pre-existing (`refSymCall9` models the right rule but our own
   `S` folded), untouched by the fix.

## 7. FILES

| file | what it is |
|---|---|
| `gen_arms_v13.py` | the 179-cell adversarial grid generator |
| `runarms_v13.sh` | golden + base + patched, DEFAULT and `-elabuhdm`, cmp + census per cell |
| `refix_v13.sh` | re-reads ONLY the verified-binary side (golden and base sides are immutable) |
| `boundary_v13.sh` / `boundary2_v13.sh` | the 2,912-arm wide boundary (fd-3 list, children `</dev/null`, PROCESSED asserted) |
| `cells/vg1` | THE REGRESSION: source parameter initialised by a folded user const-call |
| `cells/vg2` | the clause-2 escape: `bit signed [31:0]` formal, no conversion inserted |
| `evidence/` | scores, censuses, boundary walks, the coin proof, the Rggen dump diff |
