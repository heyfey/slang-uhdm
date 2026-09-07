# r10earl117 — § `patCaGenIdxBareBitSel117` — **A GENERATE INDEX INSIDE AN ASSIGNMENT-PATTERN MEMBER VALUE RENDERS AS ITS VALUE ON A BARE BIT-SELECT TOO, BECAUSE SURELOG'S `compileSelectExpression` HANDS THE PATTERN'S `Reduce::Yes` TO ITS NON-DOTTED ARM AS WELL** — the Earlgrey_0_1/testflags head and every one of the 58 cells behind it CLEARED, and **THE ROW CONVERTED TO `CMP_EQUAL`**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY** and **nothing was
promoted**.  **ONE CORPUS ROW *DID* CONVERT** and it is said loudly and quoted
in full in §6 — `Earlgrey_0_1 / testflags`, `CMP_NOTEQUAL` → `CMP_EQUAL`; the
baseline CSV was left exactly as committed and the promotion is the
integrator's to make.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `cc77bafe` |
| pristine binary | md5 `fdcdcfce45ae27fbcb3b9fd8560cfa7c`, built from this pass's OWN worktree at a clean `cc77bafe` and frozen `chmod 555` before any sweep |
| patched binary (SHIPPED) | md5 `bedbfc2053724475e877f555bd149bc3`, frozen `chmod 555`.  **REPRODUCED TWICE**: the patch's `src/ExprEmit.cpp`, reconstructed onto a clean `cc77bafe` and rebuilt, gives the SAME md5 — and so does a later comment-only correction of four stale `~line` references (line count preserved).  The shipped source provably IS the source of the measured binary |
| a THIRD binary, BUILT AND CONVICTED | md5 `88732eb14e3fd1c39783baca886632a4` — the NO-FENCE cut, § `patCaGenIdxNeverInUserCallArg112v`'s test neutered: **AWAY 3 per view** on arm `p3_fence117`, three pristine-right → cut-wrong cells on legal SV (§3c, `NOFENCE.r10earl117.txt`) |
| production surface | `src/ExprEmit.cpp` ONLY — ONE new call of an EXISTING helper, plus the law text |
| probe surface | `tools/probe/r10earl117repro/` only |
| the head | **Earlgrey_0_1/testflags, 36 cmp lines, ONE head → 0 cmp lines, 0 heads, `uhdm-cmp` rc 0 — THE ROW CONVERTED (§6).**  Golden a folded `constant` (`vpiDecompile:0`, `UINT:0`, `vpiSize:64`, `vpiConstType:9`) at `tlul_socket_m1.sv:241:32`, ours a `ref_obj('i')` bound to the gen instance's genvar `parameter`.  The failing field is `BaseClass::VpiType`, **7 (constant) − 608 (ref_obj) = −601**, and every later field is unreachable |
| Earlgrey_0_1/default | 31 lines, 1 head, r10earl107's pre-existing `u_pinmux.gen_mio_periph_in[0].data_mux` null — untouched by this law.  Its DATABASE moves (predicted by name, §5) |
| goldens | 23 PASS / 0 FAIL on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| arm grid | 4 NEW arms × 2 views × 2 census families, calibrated golden-vs-golden with every cell `SAME_AGREE` and 0 phantoms in all 16 calibration cells: **AWAY 0 and MOVED-WRONG 0 in every arm/view of the law's own family (FX)**, TO-GOLDEN **16 keys per view, 32 across the eight arm/views**.  The MUST-STAY column scored separately: **SPELLED_BROKEN 0 and SPELLED_MOVEDWRONG 0 in all eight**, 33 spelled keys per view held |
| corpus census | 2314 databases, both corpora × both modes, golden halves asserted byte-identical between the two sweeps: surelog **FX TO-GOLDEN 4 keys / 116 cells, AWAY 0, MOVED-WRONG 0**; uhdm2rtlil **not one cell of either family moved**.  Movers PREDICTED BY NAME from pristine databases and confirmed: `sl default/Earlgrey_0_1`, `sl testflags/Earlgrey_0_1`, plus the documented Scoreboard/default COIN (order-blind dump diff **0 lines**) |
| corpus row | **`Earlgrey_0_1 / testflags` CONVERTS `CMP_NOTEQUAL` → `CMP_EQUAL`** — said loudly, quoted in §6, `results/*.csv` NOT edited, nothing promoted.  Surelog corpus-wide `CMP_EQUAL 937 → 938`, `CMP_NOTEQUAL 19 → 18`; every other row of 1588 byte-identical in status AND dump column |
| wide boundary | 5150 `.sv`/`.v` under `tools/probe` at any depth × 2 views × 2 binaries, `PROCESSED==LISTED`, per-side rc histograms IDENTICAL, **10 of 9906 comparable file/views differ**: this pass's four arms and r10earl116's `q4_head116`, which carries this law's shape and moves TO GOLDEN (§7) |

---

## 1. THE JUDGE, DECODED FIRST — `own117`, the owner finder AND the ladder

RESUME.md §9's head-decode discipline: read the generated `Compare` ORDER before
naming a field.  The two kinds that meet at this head compare as

```
constant::Compare                       ref_obj::Compare
  -> expr::Compare                        -> expr::Compare
       -> BaseClass::Compare                   -> BaseClass::Compare
            VpiType, VpiName, VpiDefName            VpiType, VpiName, VpiDefName
       -> VpiDecompile, VpiSize, Typespec      -> VpiDecompile, VpiSize, Typespec
  -> VpiValue, VpiConstType               -> Actual_group, ...
```

so a `constant` against a `ref_obj` fails at `BaseClass::Compare`'s **VERY
FIRST** field and nothing after it is read.  `own117.cpp` runs the OFFICIAL
`design::Compare` (the same call `uhdm-cmp` makes), prints each field's own
result, then READS the owner chain and the owning pattern's siblings instead of
guessing any of them.  Full output in `OWNER_BEFORE.r10earl117.txt`:

```
== ITERATION 0 : design::Compare -> -601
   HEAD LHS(golden) = constant id:797692  tlul_socket_m1.sv 241:32-241:33
        payload: dec='0' size=64 value='UINT:0' ts=<null> ct=9
   HEAD RHS(ours)   = ref_obj  id:635315  241:32-241:33
        payload: name='i' size=0 ts=<null> actual=parameter('i')[val=UINT:0]
   -- FIELD BISECTION (generated Compare order) --
      BaseClass VpiType   : 7 (constant) vs 608 (ref_obj) -> -601
      *** the head is decided HERE; every later field is unreachable.
   -- OWNER CHAIN (identical on both sides) --
     bit_select 'hfifo_rspvalid'  actual=logic_var
       operation optype=75 ops=10        @240:29-251:6   (vpiAssignmentPatternOp)
         cont_assign                     @240:12-251:6
           gen_scope                     @233:36-252:6
             gen_scope_array 'gen_idrouting[0]'
               module_inst 'u_sm1_17' -> module_inst 'u_xbar_main'
   GOLDEN pattern siblings (10 operands of optype 75):
      d_valid   bit_select 'hfifo_rspvalid'  index=constant[dec=0]   <- THE HEAD
      d_opcode  hier_path  'drsp_fifo_o.d_opcode'
      d_param / d_size / d_sink / d_data / d_user / d_error   hier_paths
      d_source  ref_obj 'hfifo_rspid'
      a_ready   bit_select 'hgrant'          index=constant[dec=0]
   OURS   pattern siblings: the same ten, both bit_selects spelling `i`
```

Six facts the judge hands over, none inferred:

1. **The failing field is `BaseClass::VpiType`, and the arithmetic proves it.**
   `−601` is `7 − 608`, `uhdmconstant − uhdmref_obj`.  A `VpiDecompile` or
   `VpiSize` failure is not reachable — the objects are of different KINDS.
2. **The owner is a BARE `bit_select` on a module-scope `logic_var`**, not a
   `hier_path` element.  `hfifo_rspvalid` and `hgrant` are declared
   `logic [M-1:0]` at `tlul_socket_m1.sv:202` and `:79` — module scope, packed,
   undotted.  That is the whole distinguisher against r10earl112 (§3).
3. **Its parent is `vpiAssignmentPatternOp` (optype 75)** — the operand list
   r10earl116's § `patCaFlatLhsWholeName116` restored to `tagged_pattern` form.
4. **Eight of the ten siblings already agree**: they are the dotted
   `drsp_fifo_o.*` `hier_path`s and a whole-name `ref_obj`.  The two that do
   not are the two BARE BIT-SELECTS.  It is one law, not one cell.
5. **THE LADDER, six iterations, is ONE LAW.**  `own117` masks each head by
   pointing golden's owning `bit_select` at OUR `ref_obj` and re-runs the
   official `design::Compare`.  Iterations 0–5 are, in order,
   `hfifo_rspvalid[i]` @241:32 and `hgrant[i]` @250:24 at unrolling **0**, then
   the same two at unrolling **1**, then the same two at unrolling **2** —
   `gen_idrouting[0..2]` of `u_sm1_17`, `M = 3`.  Masking reorders the walk
   (RESUME.md §9's ladder law), so six is a LOWER BOUND; the census (§5) is the
   arbiter and it says **58 cells in this database**.
6. **The encoding golden uses is r10earl112's, byte for byte**: `UINT:<n>`,
   `VpiSize` **64**, `vpiConstType` **9** (`vpiUIntConst`), `VpiDecompile` the
   decimal, spanning the genvar TOKEN (`241:32-241:33`, one character).

### the source

```systemverilog
 79:  logic [  M-1:0] hgrant;                       // module scope, packed
202:  logic [  M-1:0] hfifo_rspvalid;               // module scope, packed
233:  for (genvar i = 0 ; i < M ; i++) begin : gen_idrouting
240:    assign hrsp_fifo_i[i] = '{
241:      d_valid:  hfifo_rspvalid[i],              <- THE HEAD
242:      d_opcode: drsp_fifo_o.d_opcode,           <- earl112's carrier, already ours
                       ... seven more ...
250:      a_ready:  hgrant[i]                       <- one ladder step behind
251:    };
252:  end
```

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

### 2a. THE REDUCTION IS r10earl112's, AND IT IS THE SAME ONE

`CompileHelper::compileAssignmentPattern`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:3671`) opens with

```cpp
  if (component && valuedcomponenti_cast<Package *>(component)) {
    reduce = Reduce::Yes;
  } else if (instance) {
    reduce = Reduce::Yes;                                        // :3688
  }
```

and then compiles **every** member value with that `reduce` (`:3735` for the
positional arm, `:3745` for the keyed arm).  Nothing new: this is exactly
§ `patCaGenIdxValueRender112`'s §2.

### 2b. THE ROAD IS THE **OTHER ARM OF THE SAME FUNCTION** — this is the answer

r10earl112 followed that `reduce` into `CompileHelper::compileSelectExpression`
(`CompileExpression.cpp:1258`) — but into its **hier_path** branch
(`:5560-5591`), the one that builds a dotted path's element list and composes
the path's `VpiName` from the element objects with `decompileHelper`.

The head at :241 is not dotted.  It reaches the SAME function's **bare
`bit_select` branch**, seventy lines from the top of it:

```cpp
1307:          expr *sel =
1308:              (expr *)compileExpression(component, fC, bitexp, compileDesign,
1309:                                        reduce, pexpr, instance, muteErrors);
                   //                       ^^^^^^ the INHERITED reduce
      ...
1330:            bit_select *bit_select = s.MakeBit_select();
1331:            bit_select->VpiName(name);
      ...
1335:            bit_select->VpiIndex(sel);
1336:            bit_select->VpiParent(pexpr);
```

and the substitution itself is the identifier arm of `compileExpression`:

```cpp
2853:            if ((reduce == Reduce::Yes) && instance)
2854:              sval = instance->getValue(name);
```

— the unrolled `gen_idrouting[k]` instance's own value for `i`.  So the answer
to "§ 112's pattern-compile reduction reaching the tagged operand tree, or
another road?" is measured, not guessed: **it is § 112's road, one branch over
in the same function.**  Nothing about the tag matters — `reduce` is decided at
`:3688`, long before any `tagged_pattern` exists.

**A NEIGHBOURING ARM THAT DOES *NOT* INHERIT IT, named because it is the
obvious confusion.**  `compileSelectExpression`'s *other* bare-bit-select arm
(`:5422-5450`, the `paConstant_bit_select` / `paBit_select` shape at `:5424`)
compiles its index with a HARD-CODED `Reduce::No` (`:5429-5432`) and builds its
`bit_select` at `:5435`.  Two arms of one function build the same UHDM kind and
only one of them inherits the pattern's `reduce`.  That is why "a bit-select
index folds inside a pattern" cannot be asserted from the grammar alone and has
to be MEASURED — which §3 does, carrier by carrier, on golden.

### 2c. WHAT THE TWO EMITTERS DO, in one module, eleven lines apart

`sig117` on the two Earlgrey_0_1/testflags databases, the pattern-value column
of `tlul_socket_m1.sv` (`SPAN|SELKIND|SELNAME|CARRIER|SCOPE|GD|PAT|SIDE|POS`):

```
  :109  a_valid: tl_h_i[i].a_valid       a DOTTED path element   (earl112's)
    G  109:26-109:27 bit_select tl_h_i cont_assign gen_scope 1 1 R idx  constant 0#64#9
    O  109:26-109:27 bit_select tl_h_i cont_assign gen_scope 1 1 R idx  constant 0#64#9

  :241  d_valid: hfifo_rspvalid[i]       a BARE bit-select       (THIS PASS)
    G  241:32-241:33 bit_select hfifo_rspvalid cont_assign gen_scope 1 1 R idx  constant 0#64#9
    O  241:32-241:33 bit_select hfifo_rspvalid cont_assign gen_scope 1 1 R idx  ref_obj  i@parameter
```

One class diverges, it is the class §2b names, and it is the class the judge
stopped on.

---

## 3. THE GOLDEN GRID — the CARRIER axis, measured one cell at a time

Four arms, `-parse` and `-parse -elabuhdm`, one golden per arm.  `grid117.sh`
builds them; `sig117` reads them; `armtab117.py` prints the per-cell table
(`GRID.r10earl117.txt`), `cen117.py` scores the two families, `spelled117.py`
scores the must-stay column.  Every producer's rc is recorded, children get
`</dev/null`, the `-top` comes from `TOPS.txt`, and `sig117`'s own `CENRC 0`
accounting line is asserted on all three sides of all eight arm/views.

### 3a. arm `p1_car117` — WHICH CARRIER GOLDEN FOLDS, pattern shape held fixed

One keyed pattern, one genvar, gen depth 1, ELAB and DEF views identical:

| cell | carrier | golden | ours, pristine | ours, patched |
|---|---|---|---|---|
| c1 | bit-select on a MODULE-SCOPE packed vector (`v[i]`) — **the head's carrier** | `constant` 0/1/2 `#64#9` | `ref_obj i` | **golden's** |
| c2 | bit-select on a GEN-LOCAL packed vector (`gv[i]`) | `constant` | `ref_obj i` | **golden's** |
| c8 | bit-select on an input PORT vector (`pin[i]`) | `constant` | `ref_obj i` | **golden's** |
| c3 | DOTTED element index (`sarr[i].f_v`) | `constant` | `constant` | unchanged — r10earl112 already owns it |
| c4 | `var_select` dimension (`ua[i][0]`) | `constant` | `ref_obj i` | unchanged — **residue R1** |
| c5 | `var_select` dimension, 2-D packed (`m2[i][0]`, `m2[0][i]`) | `constant` | `ref_obj i` | unchanged — **residue R1** |
| c7 | INDEXED-PART-SELECT base (`v[i +: 1]`) | `constant` | `ref_obj i` | unchanged — **residue R2** |
| c6 | PART-SELECT bounds (`v[i+1:i]`) | **`operation` / `ref_obj i` — SPELLED** | the same | unchanged — MUST-STAY |
| c9 | the pattern's own **Lhs** index (`wout[i]`) | **SPELLED** | the same | unchanged — MUST-STAY |
| c10 | the same bit-selects in a PLAIN cont_assign | **SPELLED** | the same | unchanged — MUST-STAY |

So "the index of a select inside a pattern" is **not** uniformly folded, and the
boundary is measured rather than assumed: a part-select's BOUNDS stay spelled
where a bit-select's INDEX folds, in the same pattern, one member apart.

### 3b. arm `p2_shape117` — the PATTERN-SHAPE axis and the DEPTH axis

| cell | shape | golden | patched |
|---|---|---|---|
| s1 | keyed member value, depth 1 | VALUED | **golden's** |
| s2 | POSITIONAL element | VALUED | **golden's** |
| s3 | a pattern NESTED in a pattern | VALUED | **golden's** |
| s4 | a `default:` key's value | VALUED | **golden's** |
| s7 | generate **DEPTH 2** (`for` in `for`, 6 unrollings) | VALUED | **golden's** |
| s8 | inside a GENERATE-IF nested in the `for` | VALUED | **golden's** |
| s10 | a gen-scope pattern writing a MODULE-SCOPE target | VALUED | **golden's** |
| s5 | a pattern in an `always_comb` in the generate body | VALUED | **unchanged — residue R3** (gate (a) is a cont_assign; r10earl112's R4/R1 owns it) |
| s6 | a pattern in an `initial` in the generate body | **SPELLED** | unchanged — MUST-STAY |
| s9 | a pattern at generate **DEPTH 0** (module body), index a module parameter | **SPELLED** (`ref_obj MP`, both views) | unchanged — MUST-STAY, and gate (a) is what keeps it out (the carrier's scope is `module_inst`) |

The axis is the CARRIER, not the depth — and both ends are measured on golden
here, not carried over: s7's depth-2 cells fold and s9's depth-0 cell is
`ref_obj MP` on BOTH sides.  An
`initial` does not fold while an `always_comb` does — the same split r10earl112
measured on the dotted carrier, re-measured here on the bare one.

### 3c. arm `p3_fence117` — THE FENCES, each one a measured cell

**The USER-CALL fence, § `patCaGenIdxNeverInUserCallArg112v`, re-measured on
THIS carrier** (all cells are pattern member values in a gen-scope cont_assign):

| cell | written | golden | patched |
|---|---|---|---|
| k1 | `f8({3'b0, v[i]})` — a USER call's argument | **SPELLED** | **SPELLED — the fence held** |
| k3 | `f8($unsigned({3'b0, v[i]}))` — system in user | **SPELLED** | **SPELLED** |
| k4 | `$unsigned(f8({3'b0, v[i]}))` — user in system | **SPELLED** | **SPELLED** |
| k2 | `$unsigned({3'b0, v[i]})` — a SYSTEM call's argument | VALUED | **golden's** |
| k6 | `4'(v[i])` — a CAST | VALUED | **golden's** |
| k7 | `v[i] ? 4'h1 : 4'h2` — a ternary CONDITION | VALUED | **golden's** |

**Fence (f) is MEASURED here, not inherited.**  A SECOND binary (md5
`88732eb14e3fd1c39783baca886632a4`) was built from the shipped tree with that
ONE line neutered and scored on the same goldens (`NOFENCE.r10earl117.txt`):

```
  shipped cut, p3_fence117, plain and elab:  TOGOLD 4  AWAY 0  SPELLED_BROKEN 0
  NO-FENCE cut, p3_fence117, plain and elab: TOGOLD 4  AWAY 3  SPELLED_BROKEN 3
      AWAY  75:22-75:23 bit_select v ... (k1)  ref_obj i -> constant 0/1/2 #64#9
      AWAY  77:32-77:33 bit_select v ... (k3)  ref_obj i -> constant 0/1/2 #64#9
      AWAY  78:32-78:33 bit_select v ... (k4)  ref_obj i -> constant 0/1/2 #64#9
```

— **three pristine-RIGHT → cut-WRONG cells per view on legal SV**, and the
other three arms are unchanged between the two cuts (AWAY 0 everywhere else),
so the regression is fence (f)'s alone.  The arithmetic gets every nesting
right: `callArgDepth − sysCallArgDepth22` is 1−0 at k1 and 2−1 at k3 and k4
(all three abstain), and 1−1 at k2 (folds).

**The INDEX-FORM axis:**

| cell | index | golden | patched |
|---|---|---|---|
| e1 | bare genvar `i` | `constant` `#64#9` | **golden's** |
| e4 | a MODULE parameter `MP` | `constant 1#32#9` | already ours, untouched BY CONSTRUCTION (fence (e)) |
| e2 | arithmetic `i+1` | `constant`, spanning `i` ALONE | unchanged — **residue R4** (an `operation` spanning `i+1`); r10earl112's R2 |
| e3 | a GEN-SCOPE localparam `LB` | `constant 1#32#9` — **width 32, not 64** | unchanged — MUST-STAY; a different encoding is a different law (fence (d), `isFromGenvar()`) |

**The MUST-STAY FLOOR:**

| cell | shape | golden | patched |
|---|---|---|---|
| h1 | earl110's own corpus shape in a PLAIN cont_assign, `tl_h_i[i].a_source[IDW-1 -: STIDW]` | agrees with ours already | **byte-identical to pristine** |
| h3 | a genvar in a PART-SELECT bound, plain cont_assign | SPELLED, agrees | **byte-identical to pristine** |
| h2 | the same select half INSIDE a pattern member value | golden folds the `[g]`, we spell it | unchanged — **residue R5**, r10earl112's fence (c) |

### 3d. arm `p4_head117` — THE HEAD REPRODUCER

`tlul_socket_m1.sv:233-252` cut to three members, the array element also feeding
an instance port, the carrier module a CHILD instance.  Both bare bit-selects
(`hfifo_rspvalid[i]` and `hgrant[i]`) go from `ref_obj` to golden's constant in
both views; the dotted sibling is untouched.  **2 TO-GOLDEN cells per view, AWAY
0, and the arm's own `uhdm-cmp` log is BYTE-IDENTICAL between the two binaries**
— the arm's head is an unrelated pre-existing divergence ABOVE this field (a
DEF-listing `logic_net` shadow of an unpacked array of packed structs; residue
R6).

### 3e. the hypotheses this pass REFUTED, each on an arm cell or on the judge

| candidate | refuted by |
|---|---|
| "the head is a `VpiDecompile` or `VpiSize` mismatch" | §1 — the two sides are different KINDS; `BaseClass::Compare` returns −601 on `VpiType` and reads nothing else |
| "the fold needs r10earl116's tagged operand" | §2b — `reduce` is set at `CompileExpression.cpp:3688`, before any `tagged_pattern` exists; and the arms' patterns include untagged positional ones (p2 s2) that fold identically |
| "every select bound inside a pattern folds" | p1 c6 — a PART-SELECT's bounds stay SPELLED in the same pattern, one member from a folded bit-select |
| "the DEF view keeps the identifier" | every p1/p2/p3/p4 cell scores the SAME in `plain` and `elab`: Surelog unrolls the generate in both, and `instance->getValue` answers in both |
| "any call argument abstains" | p3 k2 — a SYSTEM call's argument FOLDS; the test is the USER-call depth |
| "a genvar and a gen-scope localparam take the same fold" | p3 e3 — golden's `LB` constant is `VpiSize` **32**, the genvar's is 64 |
| "the axis is the generate depth" | p2 s7 — depth 2 folds; p2 s9 — depth 0 does not |
| "clearing the head clears only the head" | §6 — it cleared all **58** cells of the row and `uhdm-cmp` now returns 0: `Earlgrey_0_1/testflags` is CMP_EQUAL.  The judge's ladder said SIX objects; the census said 58; the census was right about what exists |
| "the `var_select` / indexed-part-select carriers must ship with it" | §5a — their corpus population in BOTH corpora is **zero**; they are arm-only, and shipping two more production sites for cells that do not exist is surface without convergence (residues R1, R2) |

---

## 4. THE LAW

> **§ `patCaGenIdxBareBitSel117`.**  The INDEX of a **bare `bit_select`** — a
> select on a PLAIN name, not a component of a dotted `hier_path` — that sits
> inside an ASSIGNMENT-PATTERN OPERAND VALUE, in an ELABORATED generate-scope
> CONTINUOUS ASSIGN, takes the GENVAR'S VALUE: one `constant`, `UINT:<n>`,
> `VpiSize` 64, `vpiConstType` 9 (`vpiUIntConst`), `VpiDecompile` the decimal,
> spanning the genvar TOKEN.  It is § `patCaGenIdxValueRender112`'s law with
> § `patCaGenIdxValueRender112`'s gate, at a THIRD call site — Surelog reaches
> it through the same `Reduce::Yes` and the same `instance->getValue`, by the
> BARE-BIT-SELECT branch of the same function (`compileSelectExpression`,
> `CompileExpression.cpp:1307-1338`) instead of its hier_path branch.

### STATED GATE == CODE GATE

**STATED:** the index expression of a bit-select on a plain name, inside an
assignment-pattern operand value, inside an elaborated gen-scope continuous
assign, that is a bare genvar reference with a known integer value, that no
earlier law has already folded, and that is not inside a user subroutine call's
argument list.

**CODE:** the `ExpressionKind::ElementSelect` NamedValue-base arm, after the
index emission, `ix->UhdmType() == UHDM::uhdmref_obj`, then the EXISTING
`patCaGenIdxFold112(es.selector())` whose own body is `inGenScopeCa67 &&
patValDepth112 > 0`, `callArgDepth - sysCallArgDepth22 == 0`,
`stripImplicitConv(sel).kind == NamedValue`, `symbol.kind ==
SymbolKind::Parameter && isFromGenvar()`, and `getValue().isInteger() &&
!hasUnknown()`.  There is no condition in the code that is absent from the
prose and none in the prose that is absent from the code.

### the fences, and what happens to r10earl112's fence (c)

Fences (a) `inGenScopeCa67`, (b) `patValDepth112 > 0`, (d) `isFromGenvar()` +
known integer, (e) the still-a-`ref_obj` test, and (f) the USER-call-argument
depth all transfer UNCHANGED: they live inside `patCaGenIdxFold112`, and §3
measures each of them on THIS carrier rather than inheriting r10earl112's
verdict — (a) at p2 s6/s9, (b) at p1 c9/c10, (d) at p3 e3, (e) at p3 e4, and
(f) by BUILDING the cut without it and scoring its three AWAY cells per view.

Fence **(c)**, r10earl112's "the builder itself", is **structurally VACUOUS at
the new site and is replaced by nothing, because there is nothing to keep
consistent.**  That fence existed because `emitMixedHierPath` COMPOSES a
`hier_path`'s `VpiName` out of its element objects, so folding an index there
rewrites a NAME.  A bare `bit_select`'s `VpiName` / `VpiFullName` are the BASE
name alone (`bs->VpiName(nv.symbol.name); bs->VpiFullName(joinRef(prefix,
nv.symbol.name));`, the first two statements of that arm) — no bracket text is
composed from the index — and `hpNameBareIdxFold69` is a `hier_path` renderer
that never sees this object.  The head's own `uhdm-cmp` output is the proof:
the owning `bit_select`'s synthesized name is
`…gen_idrouting[0].hfifo_rspvalid` on BOTH sides, before and after.

The shape fence (c) was protecting — earl110's
`tl_h_i[i].a_source[IDW-1 -: STIDW]` — cannot reach this site at all: it is a
`RangeSelect`, a different `ExpressionKind`, handled by a different `case`.
Arm `p3_fence117` h1 and h3 measure it and both come out **byte-identical to
pristine**, which is that claim's own test.

### THE ENCODING

Unchanged from § `genvarConnFold` / § `patCaGenIdxValueRender112` and
re-measured on golden in all four arms and on the corpus head: `UINT:<n>`,
`VpiSize` 64, `vpiConstType` 9, `VpiDecompile` the decimal, spanning the genvar
TOKEN.  The constant takes the `bit_select` as its `VpiParent`, which is
golden's own parenting and the pristine `ref_obj`'s; no generated `Compare`
reads `VpiParent` (RESUME.md §9), so this is a BYTES decision, not a judge one.

---

## 5. THE CORPUS CENSUS — 2314 databases, both corpora × both modes

`censweep117.sh` runs `sig117` over every database of a `verify_golden`
workdir, OURS and GOLDEN, with an ACCOUNTING PASS so a sweep that reached
nothing cannot read as "no rows differ":

```
surelog      ACCOUNTING PASS  LISTED=1573 PROCESSED=956  SKIPPED=617 TOOLFAIL=0
uhdm2rtlil   ACCOUNTING PASS  LISTED=1462 PROCESSED=1358 SKIPPED=104 TOOLFAIL=0
```

### 5a. THE PREDICTION, frozen from PRISTINE censuses only

`predict117.py` selects the cells the STATED gate admits using only what a
census row can see, and states its own upper-bound caveat in the code (a row
cannot see `isFromGenvar()` or the user-call depth).  Run BEFORE the patched
sweep existed (`PREDICT_sl.txt`, `PREDICT_u2r.txt`):

```
surelog     TOTAL databases=1 cells=58 golden#64#9=58 golden-other=0
              testflags/Earlgrey_0_1        cells=58  golden#64#9=58
uhdm2rtlil  TOTAL databases=0 cells=0
```

and with `--unbound`, which drops the `@parameter` requirement and so makes the
DEF-view (`default` mode) population visible (there our `ref_obj` has no
`Actual_group` yet), exactly **two** databases:

```
  default/Earlgrey_0_1     cells=58  golden#64#9=58  golden-other=0
  testflags/Earlgrey_0_1   cells=58  golden#64#9=58  golden-other=0
```

**PREDICTED MOVER SET, BY NAME: `surelog default/Earlgrey_0_1` and `surelog
testflags/Earlgrey_0_1`, and nothing else in either corpus.**

The SAME script with `--anysel` widens the scan to EVERY select-bound carrier —
a `var_select` dimension, a part-select bound, an indexed-part-select base —
inside a gen-scope pattern operand value that we still spell, and finds **one**
class in the whole of both corpora:

```
  BY CARRIER (select kind | bound position):
    bit_select|idx                 cells=116        <- and nothing else, either corpus
```

i.e. the `var_select` and `indexed-part-select` carriers of residues R1/R2 have
**ZERO corpus population**; they exist only on arm `p1_car117`.  That is why
this pass ships ONE site and states the other two as residues rather than
widening the surface for cells that do not exist.

### 5b. THE SCORE (`CENSUS_sl.txt`, `CENSUS_u2r.txt`)

Calibrated golden-vs-golden FIRST, and the two sweeps' GOLDEN halves asserted
**byte-identical** to each other before anything was scored:

```
surelog    CALIB  FX  SAME_AGREE 22583  TOGOLD 0  AWAY 0  MOVEDWRONG 0  STILLWRONG 0  NOGOLD_MOVED 0
surelog    CALIB  F0  SAME_AGREE  3857  TOGOLD 0  AWAY 0  MOVEDWRONG 0  STILLWRONG 0  NOGOLD_MOVED 0
surelog    SCORE  FX  SAME_AGREE 22503  TOGOLD 4  AWAY 0  MOVEDWRONG 0  STILLWRONG 76 NOGOLD_MOVED 0
surelog    SCORE  F0  SAME_AGREE  3845  TOGOLD 4  AWAY 0  MOVEDWRONG 0  STILLWRONG  8 NOGOLD_MOVED 0

uhdm2rtlil CALIB  FX  SAME_AGREE  2044  everything else 0
uhdm2rtlil SCORE  FX  SAME_AGREE  2044  TOGOLD 0  AWAY 0  MOVEDWRONG 0  STILLWRONG 0  NOGOLD_MOVED 0
uhdm2rtlil CALIB/SCORE F0  SAME_AGREE 1024  everything else 0
```

**AWAY 0 and MOVED-WRONG 0 in both families of both corpora.**  The four TOGOLD
keys are, in full — and they are the prediction, name for name:

```
  TOGOLD  default/Earlgrey_0_1    241:32-241:33 bit_select hfifo_rspvalid cont_assign gen_scope 1 1 R idx
             pris {ref_obj i@<null> : 29}     patch {0#64#9:13, 1#64#9:13, 2#64#9:3}
  TOGOLD  default/Earlgrey_0_1    250:24-250:25 bit_select hgrant         cont_assign gen_scope 1 1 R idx
             pris {ref_obj i@<null> : 29}     patch {0#64#9:13, 1#64#9:13, 2#64#9:3}
  TOGOLD  testflags/Earlgrey_0_1  241:32-241:33 bit_select hfifo_rspvalid cont_assign gen_scope 1 1 R idx
             pris {ref_obj i@parameter : 29}  patch {0#64#9:13, 1#64#9:13, 2#64#9:3}
  TOGOLD  testflags/Earlgrey_0_1  250:24-250:25 bit_select hgrant         cont_assign gen_scope 1 1 R idx
             pris {ref_obj i@parameter : 29}  patch {0#64#9:13, 1#64#9:13, 2#64#9:3}
```

**116 cells**, 29 per key — the 29 unrollings of `gen_idrouting` across every
`tlul_socket_m1` instance in `top_earlgrey`, in BOTH views.  `uhdm2rtlil`: not
one cell of either family moved anywhere.

**AND THE FAMILY IS NOW EMPTY.**  Re-run over the PATCHED surelog census, every
`sig117` cell where golden and ours still disagree falls into 12 classes and
**not one of them has `PAT > 0`**: they are `part_select` bounds, `var_select`
dimensions and bit-select indices in `module_inst` scope, OUTSIDE any assignment
pattern, all of the `<absent>` shape (a cell golden has at a span ours does not
carry — a structure/span residue, not an index-rendering one).  The
pattern-operand select-index family this law and § 112 share has **zero**
remaining divergent cells in the surelog corpus, both modes.

---

## 6. THE HEAD, AFTER — **THE ROW CONVERTED**

```
$ uhdm-cmp <golden> <ours, patched>          # Earlgrey_0_1 / testflags
$ echo $?
0
```

**Earlgrey_0_1/testflags: 36 cmp lines / 1 head → 0 cmp lines / 0 heads,
`uhdm-cmp` rc 0.**  `HEAD_AFTER_Earlgrey_testflags.cmp` is an EMPTY FILE, which
is what a cleared row looks like.

**A CORPUS ROW CONVERTED — SAID LOUDLY, AND `results/*.csv` WAS NOT EDITED.**
`ct8rows.sh` against the committed baseline reports exactly one differing row
out of 1588, and it is this one:

```
< Earlgrey_0_1,testflags,CMP_NOTEQUAL,decompile:,,
> Earlgrey_0_1,testflags,CMP_EQUAL,,,
```

Corpus-wide the surelog status histogram goes `CMP_EQUAL 937 → 938` and
`CMP_NOTEQUAL 19 → 18`.  The promotion of that row in `results/golden_surelog.csv`
is the integrator's to make, not this pass's; nothing here was promoted.

The judge's own ladder (§1 fact 5) named six objects; the census named 58 cells
in this database; clearing them clears the database.  Both counts were right
about what they measure — the ladder counts what the masking walk REACHES, the
census counts what EXISTS (RESUME.md §9's ladder law), and the official
comparator is what settles it.

`Earlgrey_0_1/default` keeps its 31-line, one-head r10earl107 `LHS: <null>`
divergence (`u_pinmux.gen_mio_periph_in[0].data_mux`) and its cmp log is
**byte-identical** before and after; its DATABASE moves, as predicted by name.

---

## 7. THE BOUNDARY

### 7a. THE WIDE BOUNDARY — every `.sv`/`.v` under `tools/probe`, at any depth

`widerun117.sh` stages a COPY of `tools/probe`, builds the file list at any
depth, filters the four slang-fenced names out of it by reading `canaudit.sh`'s
own `FENCED=` line (so they are never spelled here and the filter cannot drift),
then runs both frozen binaries over every file in both views and compares
workdir-normalised dumps.  The list is read on fd 3 and every child gets
`</dev/null`.

```
LISTED=5150  FENCED_REMOVED=0  (of 5150 found)
PROCESSED=5150 identical=9896 DIFFERING=10 no_output=394
PROCESSED==LISTED (5150)
-- rc by side --            A/0 9515   A/3 378   A/4 391   A/139 16
                            B/0 9515   B/3 378   B/4 391   B/139 16
```

The per-side rc histograms are **IDENTICAL**, so no file crashes on one binary
and not the other (the 16 `rc=139` are pre-existing segfaults present on BOTH).
The ten differing file/views are this pass's own four arms (8) and
**`r10earl116repro/q4_head116.sv`** (2) — nothing else among 5145 other files.

### 7b. THE ONE ARM THE BOUNDARY FLAGGED THAT IS NOT THIS PASS'S

`q4_head116.sv` is r10earl116's HEAD REPRODUCER, and it carries this law's shape
by construction: `assign hrsp[i] = '{d_valid: rspvalid_i[i], …}` — a bare
bit-select on a module-scope packed vector inside a keyed pattern member value
in a gen-scope continuous assign.  Re-scored (`BOUNDARY_arms.txt`):

```
  plain / elab, FX and F0:   SAME_AGREE 3  TOGOLD 1  AWAY 0  MOVEDWRONG 0
  the moved cell: 48:44-48:45 bit_select rspvalid_i  ref_obj i -> constant 0/1/2 #64#9
  MUST-STAY column:  SPELLED_AGREE 1, SPELLED_BROKEN 0
  its own uhdm-cmp line count is UNCHANGED (58/1 -> 58/1) — its head is the
  same pre-existing DEF-listing `logic_net` shadow above this field.
```

### 7c. r10earl110–116's LAWS, RE-SCORED IN r10earl116's OWN FAMILY

`sig116` (the assignment-pattern FLATTENED-NESS census, keyed on Lhs kind / Lhs
actual kind / scope / depth / carrier) run on all three sides of every arm the
wide boundary flagged, and on the two moving corpus databases:

```
  q4_head116, p1_car117, p2_shape117, p3_fence117, p4_head117, both views:
      earl116-family census pristine-vs-patched: IDENTICAL,  patched-vs-golden: AGREES
  Earlgrey_0_1/default    earl116-family census BYTE-IDENTICAL (131 rows)
  Earlgrey_0_1/testflags  earl116-family census BYTE-IDENTICAL (131 rows)
```

r10earl116's § `patCaFlatLhsWholeName116` split gate is exactly where it was
left, on the arms and on the corpus.  r10earl110's SPELLED genvar select-half
cells (`p3_fence117` h1/h3), r10earl112's five fences and its user-call fence
(`p3_fence117` k1/k3/k4, e3, e4), r10earl113/114/115's arms (byte-identical in
the wide boundary, which lists every one of their `.sv` files) are all held.

### 7d. THE TWO EARLGREY MOVERS, ATTRIBUTED ORDER-BLIND

`attrib116.sh` (copied verbatim from r10earl116) path-normalises both whole
dumps, diffs them RAW and ORDER-BLIND, sections them at `|uhdmtopModules:` and
never counts the weaklyReferenced tail.  `ATTRIB_Earlgrey.txt`:

```
  Earlgrey_0_1/default      RAW 696   ORDER-BLIND 533   all of it in sec=10 (an ELAB section)
      added   58 x { \_constant: , |vpiDecompile:N, |vpiSize:N, |UINT:N, |vpiConstType:N }
      removed 58 x { \_ref_obj: (...gen_idrouting[N].i), |vpiName:i, |vpiFullName:... }

  Earlgrey_0_1/testflags    RAW 812   ORDER-BLIND 679   all of it in sec=10
      added   58 x { \_constant: , |vpiDecompile:N, |vpiSize:N, |UINT:N, |vpiConstType:N }
      removed 58 x { \_ref_obj: (...gen_idrouting[N].i), |vpiName:i, |vpiFullName:...,
                     |vpiActual:, \_parameter: (...gen_idrouting[N].i) }
```

**58 per database, exactly the predicted number, and not one other line shape
moved in either 350 MB dump.**  The `testflags` blocks carry one extra pair of
lines because there the `ref_obj` is BOUND to the genvar `parameter` and the
`default` one is not — which is the same `@parameter` / `@<null>` split §5a's
`--unbound` flag exists for.  The third mover, `Scoreboard/default`, has an
order-blind diff of **0 lines** (81 RAW) and is the documented parallel-parse
coin, not this law (`ATTRIB_Scoreboard_coin.txt`).

### 7e. THE MUST-STAY COLUMN, SCORED AS ITS OWN COLUMN

`spelled117.py` restricts the census to cells where GOLDEN spells (its payload
contains a `ref_obj`) and asks only "do we still spell them":

```
  p1_car117   plain/elab  SPELLED_AGREE  8   SPELLED_BROKEN 0
  p2_shape117 plain/elab  SPELLED_AGREE 11   SPELLED_BROKEN 0
  p3_fence117 plain/elab  SPELLED_AGREE 13   SPELLED_BROKEN 0
  p4_head117  plain/elab  SPELLED_AGREE  1   SPELLED_BROKEN 0
  q4_head116  plain/elab  SPELLED_AGREE  1   SPELLED_BROKEN 0
```

**34 spelled KEYS per view, 68 across the ten arm/views, SPELLED_BROKEN 0 and
SPELLED_MOVEDWRONG 0 in every one** (a key holds one cell per unrolling, so the
cell count is larger; the scorer counts keys).  The complementary FOLDED column
scores FIXED 17 keys per view, BROKEN 0, and STILL 9 keys per view — the
residues of §8.

---

## 8. RESIDUES, and R0

* **R0 — THE Earlgrey FAMILY'S NEXT HEAD IS `Earlgrey_0_1/default`, READ not
  predicted.**  With `testflags` at 0/0, the row that remains is
  `Earlgrey_0_1/default`: **31 cmp lines, ONE head, `LHS: <null>`** against our
  `logic_var (work@top_earlgrey.u_pinmux.gen_mio_periph_in[0].data_mux)` at
  `pinmux.sv:157:39`, parented at the `gen_scope
  u_pinmux.gen_mio_periph_in[0]`.  It is r10earl107's, unchanged and untouched
  here; `HEAD_AFTER_Earlgrey_default.cmp` holds it and is BYTE-IDENTICAL to
  `HEAD_BEFORE_Earlgrey_default.cmp`.  RESUME.md §9's null law applies: read
  `BaseClass.h`'s SafeCompare overloads before naming a field — an `LHS:
  <null>` with a full RHS is the SINGULAR overload naming OURS as the extra
  object, i.e. **we emit a `logic_var` golden does not**, a DEF/ELAB population
  question and not a rendering one.  Corpus-wide 18 `CMP_NOTEQUAL` rows remain
  in surelog (10 default, 8 testflags) and 0 in uhdm2rtlil.
* **R1 — THE `var_select` DIMENSION.**  Arm `p1_car117` c4/c5: golden folds the
  genvar in `ua[i][0]` and in both brackets of `m2[i][0]` / `m2[0][i]` inside a
  pattern member value; we keep the reference.  Same law, same encoding
  (`#64#9`), a DIFFERENT builder (two `var_select` sites in the ExprEmit
  nested-select arms).  **Not shipped because its corpus population is ZERO** —
  §5a's widened scan finds the bit-select index carrier and nothing else in
  either corpus — so shipping it would add two production sites for cells that
  do not exist outside this arm.  THREE keys / NINE cells per view, measured and
  stated rather than dressed up.
* **R2 — THE INDEXED-PART-SELECT BASE.**  Arm `p1_car117` c7: golden folds the
  genvar in `v[i +: 1]`'s BASE inside a pattern member value; we keep the
  reference.  ONE key / three cells per view; SIX `MakeIndexed_part_select`
  sites in `ExprEmit.cpp` would have to carry it, and, again, its corpus
  population is **zero**.  Its neighbour is the fence: a PART-SELECT's two
  BOUNDS (`v[i+1:i]`, c6) golden leaves SPELLED, and so do we — that pair is
  the reason "the index of a select inside a pattern folds" cannot be stated
  without the carrier boundary of §3a.
* **R3 — THE PROCEDURAL PATTERN.**  Arm `p2_shape117` s5: a pattern in an
  `always_comb` inside the generate body folds in golden and does not here,
  because gate (a) `inGenScopeCa67` is a CONTINUOUS ASSIGN flag.  This is
  r10earl112's own residue (its arm g2 c2), unchanged in kind and now measured
  on the bare carrier too.  Its twin `initial` (s6) golden SPELLS, and we spell
  it — so the fix is not "widen gate (a)", it is a procedural-carrier law with
  its own split.
* **R4 — THE ARITHMETIC INDEX.**  Arm `p3_fence117` e2: golden renders `v[i+1]`
  as one `constant UINT:<n>` spanning the `i` TOKEN ALONE (`85:19-85:20`),
  while we emit an `operation` spanning `i+1` (`85:19-85:22`).  r10earl112's R2,
  unchanged: the gate here is `stripImplicitConv(sel).kind == NamedValue`, so an
  arithmetic index is unreachable by construction, and the span rule
  (§ `genvarIdxFoldRerender14`'s first-child re-span) is a second law that would
  have to come with it.
* **R5 — THE RANGE-SELECT PATH'S ELEMENT INDEX.**  Arm `p3_fence117` h2
  (`104:34-104:35`): in `'{r1: tl_h_i[g].a_source[IDW-1 -: STIDW], …}` golden
  folds the `[g]` and we spell it, because a `hier_path` carrying a
  `RangeSelect` is built by a different arm than `emitMixedHierPath` and
  r10earl112's sites 1/2 never see it.  The same cell also carries a
  PRE-EXISTING span difference in the indexed-part-select BASE (golden
  `104:46-104:49`, ours `104:46-104:51`) which is r10earl110's territory and is
  byte-identical across this patch.
* **R6 — THE ARMS' OWN HEADS ARE NOT THIS LAW'S.**  None of `p1`–`p4` goes to 0
  cmp lines (58, 58, 30, 58) and **the cmp log is byte-identical between the two
  binaries on all four, in both views**.  Each arm's head is an unrelated
  pre-existing divergence above this field — `p4`'s is a DEF-listing `logic_net`
  shadow of an unpacked array of packed structs, the same one r10earl116's R4
  named for `q4`.  The new arms' instrument is the CENSUS; the thing that goes
  to fully CMP-EQUAL here is the CORPUS ROW.
* **R7 — r10earl110–116's laws are untouched**, re-scored by the wide boundary
  over all 5150 probe sources and, for the one arm it flagged, in r10earl116's
  own family with AWAY 0 / MOVED-WRONG 0 (§7b, §7c).

---

## 9. FILES

| file | what it is |
|---|---|
| `own117.cpp` | THE JUDGE, DECODED FIRST: the owner finder, the field bisector in generated `Compare` order, the owner chain, the pattern siblings, and the MASK LADDER that names the objects behind the head |
| `sig117.cpp` | the census: one row per SELECT BOUND (bit_select index, var_select dimension, part_select bounds, indexed_part_select base/width, and the same four carried by a hier_path element) reachable from a cont_assign or a process statement, keyed on span / select kind / select name / carrier / scope / gen depth / PATTERN-VALUE DEPTH / side / position.  Prints its own `CENRC 0` accounting line |
| `cen117.py` | the two-family scorer (`FX` the law's own surface, `F0` the coarse span-less key) with SHAPE `TOGOLD`/`AWAY`/`MOVEDWRONG`/`STILLWRONG`/`NOGOLD_MOVED`, keyed per database, multiset-joined |
| `armtab117.py` | the per-CELL arm table (golden / pristine / patched, only where they disagree) plus the KEY-SET assertion that no span moved |
| `spelled117.py` | THE MUST-STAY COLUMN scored on its own: the cells where GOLDEN spells, and whether we still spell them |
| `predict117.py` | the BY-ROW mover prediction from PRISTINE censuses only, with its upper-bound caveat stated in the code |
| `censweep117.sh` | the corpus sweep driver with its ACCOUNTING PASS (LISTED / PROCESSED / SKIPPED / TOOLFAIL) |
| `grid117.sh`, `TOPS.txt` | the arm grid driver (rc recorded per producer, children `</dev/null`, `-top` from `TOPS.txt`, `CENRC` asserted) and its `-top` table |
| `p1_car117.sv` | THE CARRIER AXIS: module-scope / gen-local / port bit-selects, a dotted element, a `var_select` dimension, a 2-D select, a part-select's bounds, an indexed-part-select base, the pattern's own Lhs index, and the plain-cont_assign control |
| `p2_shape117.sv` | THE PATTERN-SHAPE AXIS and THE DEPTH AXIS: keyed, positional, nested, `default:`, `always_comb`, `initial`, depth 2, generate-IF, depth 0, module-scope target |
| `p3_fence117.sv` | THE FENCES: user call / system call / user-in-system / system-in-user / cast / ternary condition, the index forms (genvar, arithmetic, gen-scope localparam, module parameter), and earl110's must-stay select halves in both positions |
| `p4_head117.sv` | THE HEAD REPRODUCER: `tlul_socket_m1.sv:233-252` cut to three members, with the array element also feeding an instance port |
| `attrib116.sh`, `secattr116.py` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution (copied verbatim from r10earl116; the weaklyReferenced TAIL is never counted) |
| `wide117.sh`, `widerun117.sh` | the wide boundary over every `.sv`/`.v` in `tools/probe` at any depth, both views, both binaries |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the landing gates (copied verbatim from their owning pass dirs) |
| `HEAD_*_Earlgrey_*.cmp` | the official `uhdm-cmp` output on the head row, both modes, both binaries.  **`HEAD_AFTER_Earlgrey_testflags.cmp` is EMPTY on purpose** — the comparator printed nothing and returned 0 |
| `ATTRIB_Earlgrey.txt`, `ATTRIB_Scoreboard_coin.txt` | the sectioned, path-normalised, ORDER-BLIND whole-dump attribution of the two Earlgrey movers and of the documented Scoreboard/default coin |
| `ARM_*_BEFORE.cmp` / `ARM_*_AFTER.cmp` | the official `uhdm-cmp` output on each arm, both views, both binaries |
| `OWNER_BEFORE.r10earl117.txt` | `own117`'s six-iteration ladder on the pristine databases |
| `GRID.r10earl117.txt`, `CALIB.r10earl117.txt`, `SPELLED.r10earl117.txt` | the per-cell arm table, its golden-vs-golden calibration, and the must-stay column |
| `CENSUS_sl.txt`, `CENSUS_u2r.txt`, `PREDICT_sl.txt`, `PREDICT_u2r.txt` | the corpus census scores and the frozen prediction |
| `BOUNDARY_WIDE.*`, `BOUNDARY_arms.txt` | the wide boundary's independent accounting and the re-score of every arm it flagged |
| `NOFENCE.r10earl117.txt` | the NO-FENCE cut — a second binary built with § patCaGenIdxNeverInUserCallArg112v's test neutered, and the three AWAY cells per view that convict it |
| `GATES.r10earl117.txt` | every landing gate's output, in order |

**Build the C++ instruments with**

```
g++ -O2 -std=c++17 sig117.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o sig117
g++ -O2 -std=c++17 own117.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own117
```
