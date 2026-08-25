# r10uvm133 — § `bitsCallArgNeverFolds133` — **`$bits` OVER A CALL IS NEVER FOLDED** — the BuildUVMPkg ×2 **60-line head CLEARED**

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f08eee0` |
| pristine binary | reproduced the campaign's `build/slang-uhdm` at `f08eee0` BYTE FOR BYTE (md5 `583b10a735e405dcfaeb2f49695d6632`), frozen `chmod 555` before any sweep |
| patched binary | md5 `7f81e89326a6057b6aa31d34a5efcb38`, frozen `chmod 555` |
| production surface | `src/ExprEmit.cpp` ONLY — **one** added condition in the `$bits` keep/fold decision, carrying the decoded law |
| probe surface | `tools/probe/r10uvm133repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **BuildUVMPkg default / testflags** | **60** | **64** | 1 — a **NEW HEAD**, a different object and a different family |
| SeqDriver default / testflags | 17 | 17 | 1 unchanged, head log **BYTE-IDENTICAL** |
| SimpleUVM default / testflags | 64 | 64 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Scoreboard default | 64 | 64 | 1 unchanged, head log **BYTE-IDENTICAL** |
| MiniAmiq default / testflags | 80 | 80 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Earlgrey_0_1 default / testflags | 150 | 150 | 1 unchanged, head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **2 / 956** surelog, **0 / 1358** uhdm2rtlil | |
| the ten own arm-views | — | **48 TOGOLD, 0 MOVED-WRONG, 0 AWAY, 0 MOVED-OTHER** | |
| the six foreign arm-views the wide boundary moved | — | **18 cells, ALL TOGOLD** | |

The a-priori prediction, made from the PRISTINE databases before `byteverify`
was run, named **TWO** movers out of 2314 databases and no others; the
measurement matched it name for name.

The cmp-line counts are DEPTH — the size of the head object's decompile — not a
count of remaining defects.

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`rowheads.sh` on this pass's own pristine sweep reproduces the master's head log
`/tmp/buildpkg_head_f08eee0.cmp` **BYTE FOR BYTE** for BuildUVMPkg/default (and
line for line, ids aside, for BuildUVMPkg/testflags) — `head_pris_default_BuildUVMPkg.cmp`,
sixty lines, `grep -c '^LHS:'` = 1:

```
LHS (golden)                                     RHS (ours, pristine)
sys_func_call: ($bits)      @82730:10-82731:48   constant:            @82730:10-82731:48
 |vpiParent: operation      @82730:10-82731:54    |vpiParent: operation @82730:10-82731:54
 |vpiArgument:                                    |vpiDecompile:32
 \_hier_path: (abstractions.size) @82731:28-47    |vpiSize:64
    |vpiActual: ref_obj (abstractions)  28-40     |UINT:32
    |vpiActual: method_func_call (size) 41-45     |vpiConstType:9
    |vpiName: abstractions.size
 |vpiName:$bits
```

**Which field fails.** The two sides are DIFFERENT OBJECT KINDS, so
`BaseClass::Compare` fails on `VpiType` before any per-kind field is read. It is
not a value defect and not a naming residue: golden holds a **call**, we held a
**constant**.

**The site.** `1800.2-2017-1.0/pp_output/uvm_pkg.sv:82730-82731`, the expansion
of `` `uvm_compare_qda_string `` reached from `` `m_uvm_field_qda_string ``
(`src/macros/uvm_object_defines.svh:1606,1612`) for

```systemverilog
   string abstractions[$];                      // uvm_reg_mem_hdl_paths_seq.svh:56
   `uvm_field_queue_string(abstractions, UVM_DEFAULT)      //                    :59
```

so the written text is `$bits(abstractions.size())` — **`$bits` of a METHOD CALL
on a queue property**. The same macro expansion writes it twice more, at
`82735:61` and `82742:61`, as the 4th argument of `compare_field_int` and
`compare_field`.

---

## 2. THE DECODED SURELOG MODEL — READ, NOT GUESSED

### 2a. `compileBits` folds ONLY when it has a TYPESPEC

`CompileHelper::compileBits`
(`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:4663`) is reached
from three sites (`:2424` `$bits`, `:3197` `bits`, `:5127` `bits`) and it is
**one gate**:

```cpp
  if (bits == 0) {
    tps = getTypespec(component, fC, typeSpecId, compileDesign, reduce, instance);
    if (m_elabMode && (reduce == Reduce::No) && tps) {          // <-- THE PROMOTION
      UHDM::ExprEval eval;
      if (eval.isFullySpecified(tps)) reduce = Reduce::Yes;
    }
    if ((reduce == Reduce::Yes) && tps)
      bits = Bits(tps, invalidValue, …);
    if ((reduce == Reduce::Yes) && (!tps)) {
      exp = compileExpression(…, Reduce::Yes, …);
      if (exp && typeSpecId) bits = Bits(exp, invalidValue, …);
    }
  }
  if ((reduce == Reduce::Yes) && tps  && !invalidValue && !sizeMode) { …mint a constant… }
  else if ((reduce == Reduce::Yes) && exp && !invalidValue && !sizeMode) { …mint a constant… }
  else if (sizeMode) { …MakeSys_func_call("$size")… }
  else               { …MakeSys_func_call("$bits") + compileTfCallArguments… }
```

`m_elabMode` is `true` by default (`CompileHelper.h:700`), and the definition
compile arrives with `Reduce::No`. So in the DEF listing the ONLY road to a
folded constant is: **`getTypespec` returns a typespec AND
`ExprEval::isFullySpecified` accepts it.** Otherwise `reduce` stays `No`, both
constant arms are skipped, and control reaches the final `else`, which MINTS the
`sys_func_call` **and compiles its arguments**.

### 2b. A CALL HAS NO TYPESPEC — the two roads and how each one refuses

`abstractions.size()` parses as a `paComplex_func_call`, so `compileBits` sets
`typeSpecId = Primary_literal` and `getTypespec` takes its
`paComplex_func_call` arm (`CompileExpression.cpp:4437`):

```cpp
    case VObjectType::paComplex_func_call: {
      UHDM::any *exp = compileExpression(component, fC, fC->Parent(id), …);
      if (exp) {
        if (exp->UhdmType() == uhdmhier_path) {
          result = (typespec *)decodeHierPath((hier_path *)exp, …, /*returnTypespec=*/true);
        } … else { basename = exp->VpiName(); }
      }
```

* **the dotted road.** `exp` is the `hier_path (abstractions.size)`, and
  `ExprEval::decodeHierPath(…, ReturnType::TYPESPEC)` hands the element NAMES to
  `hierarchicalSelector`, which walks **struct/class MEMBERS and select
  suffixes only**. `size` is a method, not a member, so the selector returns
  null, `decodeHierPath` sets `invalidValue` and returns null — `tps` is null.
* **the bare road.** For a free function `exp` is a `func_call`, and the `else`
  takes `basename = exp->VpiName()` — the SUBROUTINE's name. No `DataType`
  answers to it, so `tps` is null again.

With `tps` null the promotion never fires, `reduce` stays `Reduce::No`, the
second road (`compileExpression` + `Bits(exp,…)`) is not entered either, and the
`$bits` `sys_func_call` is minted.

**And when a caller DOES arrive with `Reduce::Yes`** (an elaborated parameter
init, a cast size) the refusal still holds one level down: `Bits()` is
`UHDM::ExprEval::size`, whose switch has **no case for a call** — a `func_call`
or `method_func_call` falls to `default: invalidValue = true`, and the
`uhdmhier_path` case re-runs the same failing `decodeHierPath` and sets it too.
`invalidValue` vetoes BOTH constant arms.

**So: golden NEVER folds `$bits` over a call, in any home, in either view.**
Measured, not assumed — §3's ten-view arm table is that measurement.

### 2c. The same gate explains the rest of the `$bits` table

The one gate in 2a is also why golden folds what it folds. Arm A (`g133_a_kinds.sv`,
twenty argument kinds in a class method) reads, on golden:

| written argument | `getTypespec` | golden |
|---|---|---|
| `int` / a typedef / a struct typedef | the type itself | **folds** 32 / 6 / 12 |
| a plain property, a select, a range select, an array element, a whole struct, a whole unpacked array | the ROOT declaration's typespec | **folds** (root width — § `bitsSelectIgnoredRootBits95`) |
| `s_mem.hi` (member access) | `decodeHierPath` resolves the MEMBER | **folds** 8 |
| a literal `5` | none | **keeps** |
| a package parameter, a class localparam | none | **keeps** |
| `i_var + 1`, `~i_var` | none | **keeps** |
| **a queue method call, a bare method call, `this.`-qualified, a reduction method, a free function** | **none** | **KEEPS** — THIS LAW |

---

## 3. WHAT WE DID, AND WHAT WE DO NOW

`ExprEmit.cpp`'s system-call arm computed `bitsKeep` from a closed list of
argument kinds (`UnaryOp`, `BinaryOp`, `ConditionalOp`, an overridable
`Parameter`, plus `srlgBitsFoldArg`'s typespec test over the name/select/member
shapes) and its own comment said out loud that *"anything else (a concatenation,
a cast, a **call**) keeps the old behaviour"* — the old behaviour being
`ASTContext::tryEval`, which answers `$bits` from slang's TYPE alone and folds
happily over a non-constant argument. That is where `32` came from.

The patch adds **one** condition to that same decision:

```cpp
  if (a0.kind == ExpressionKind::Call)
      bitsKeep = true;
```

with the decode of §2 written above it. Nothing else changed: the fold VALUE
roads, the package guard, § `bitsOwnClassPropFold61`, § `bitsSelectIgnoredRootBits95`
and § `bitsSelectThenMemberKeeps95` are untouched, and `bitsKeep` is consumed
only under `name == "$bits"`, so no sibling query function can see it (arm D
proves it on eight of them).

**Nothing has to be built for the argument.** Once the call survives, the
existing `sys_func_call` argument loop recurses into the built-in-method arm
that already builds `hier_path` + `ref_obj` + `method_func_call` (uvm124's
family), and the result is golden's subtree **byte for byte** — verified on the
corpus movers and on every arm cell.

### 3a. The arms (`ARMS.r10uvm133.txt`, ten own views + six foreign)

| arm | what it varies | def | elab |
|---|---|---|---|
| `g133_a_kinds.sv` | 20 argument KINDS in a class method | TOGOLD 5, wrong 0 | TOGOLD 5, wrong 0 |
| `g133_b_homes.sv` | 13 HOMES: class body, macro expansion ×3, package free function, module `initial`, `always_comb`, cont-assign, param_assign init, High_conn param override, generate block | TOGOLD 10, wrong 0 | TOGOLD 10, wrong 0 |
| `g133_c_inst.sv` | 1 / 2 / 3 instances, 5 elaborated copies of the cell | **CMP_EQUAL** (was CMP_NE/1 head) | **CMP_EQUAL** |
| `g133_d_siblings.sv` | `$size $clog2 $high $low $left $right $dimensions $increment` over the SAME call | **CMP_EQUAL** (was CMP_NE/1 head) | **CMP_EQUAL** |
| `g133_e_edge.sv` | 15 NEAR MISSES | TOGOLD 6, wrong 0 | TOGOLD 6, wrong 0 |

Two arms that the pristine binary FAILED now **PASS the official `uhdm-cmp`**,
in both views.

`g133_e_edge.sv` is the arm that says where the law stops. It moves
`$bits(eq.size)` written **without parentheses** (slang calls it a
`CallExpression`; golden's argument there is a two-`ref_obj` `hier_path`, and
ours comes out identical), `this.eq.size()`, `ec.gi133()` through a class
handle, `es.len()` and `$bits($clog2(4))`. It leaves ALONE — and measures that
it leaves alone — `ea[eidx133()]` and `ev[eidx133()]`, where the CALL is the
select's INDEX and golden folds the root width exactly as we do.

---

## 4. THE CENSUS (`CENSUS.r10uvm133.txt`)

`qcen133.py` classifies every `$bits $size $clog2 $high $low $left $right
$increment $dimensions` cell in a uhdm-dump by ARGUMENT KIND, reading the dump
TREE (a `\_X:` line under `|vpiParent:` is a back-reference stub and is skipped,
so nothing unreachable is counted). `qjoin133.py` joins two or three censuses on
the cell's START `line:col` — the one key BOTH producers anchor at the `$` of the
written call, and the only way to see a FOLDED cell at all, since a folded query
call is an anonymous constant with no name to match on.

* **Calibrated golden-vs-golden FIRST**: BuildUVMPkg's golden against itself —
  64 sites, ALL `BOTHKEEP`, **0 disagreements**.
* **Candidate pre-filter, a proven superset**: golden always keeps a `$bits`
  over a call, so a mover's golden must carry the string `$bits`. Only **43 of
  1523** surelog row-databases and **30 of 1358** uhdm2rtlil row-databases do.
* Over all 43 surelog candidates the `GOLDKEEP-OURSFOLD` sites are
  **250 `typekeyword`** (`$bits(int)`/`$bits(byte)` — uvm89/buvm16 R3, NOT this
  law), **12 `name`** (`$bits(uvm_reg_data_t)`, a typedef name — NOT this law)
  and **6 `methodcall`** — the 3 cells × 2 modes of BuildUVMPkg, **this law's
  entire corpus population**.
* Over all 30 uhdm2rtlil candidates there is **not one** `GOLDKEEP-OURSFOLD`
  site of any kind.
* **`GOLDFOLD-OURSKEEP` (AWAY) is ZERO in both corpora**, before and after — so
  the one-sided risk this pass could carry (keeping a call where golden folds)
  has no corpus population at all. The two AWAY cells that exist anywhere are
  `$bits(s_mem.hi)` in arms A/E, and they are **pristine's**, unchanged by this
  pass (§6 R2).

## 5. GATES, MOVERS, BOUNDARY

All five gates green — `GATES.r10uvm133.txt` carries the transcript:

* both binaries built `-j 2`, md5s taken separately, frozen `chmod 555` BEFORE
  any sweep; every `cmds.txt` audited **by binary PATH** (1523 surelog + 1458
  uhdm2rtlil per sweep, all one path);
* goldens **23 PASS / 0 FAIL** for each binary with `SLANG_UHDM` exported
  explicitly, **0 PASS / 23 FAIL** for the `/bin/false` negative control;
* uhdm2rtlil **679 / 50 / 2** in BOTH modes, `ct8rows` **0 differing rows**
  against the committed gate AND against this pass's own pristine sweep;
* surelog `--mode both`, `ct8rows` **0 differing rows over 1588** against the
  committed baseline AND against this pass's own pristine sweep — **NO ROW
  CONVERTED**, and the status histograms are IDENTICAL pristine vs patched, so
  no `rc=139` segfault is hiding inside a `SLANG_REJECT`;
* `byteverify SELFCHECK=1`: **2 / 956** surelog (both named in advance),
  **0 / 1358** uhdm2rtlil; canaries `ok=52 changed=0` and `ok=8 changed=0`,
  `ctcan2` PASS both, `canaudit` PASS (`UNCOVERED=0 FENCE-BREACH=0`);
  InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical, SVSwitch
  pinned at `4842211c4030`, YosysVerx at `6ccda350c24a`.

**Wide boundary** (`BOUNDARY.r10uvm133.txt`): 3935 sources × 2 views × 2
binaries, `LISTED=3935 FENCED_SKIPPED=0 PROCESSED=3935 MOVED=16
NO_OUTPUT_PAIRS=316`, `PROCESSED-ASSERT-OK`, zero `ASYMMETRIC_OUTPUT`. Ten of
the sixteen are this pass's own arms — which is the gate's positive control. The
other six are `r10v95repro/v95_b6_exprargs.sv` and
`r10vbuvm28repro/{gv28_d_reach,gv28_g_last}.sv`, both views each; scored against
THEIR OWN golden they are **18 cells, every one a `$bits` over a call (a free
function, or `$bits($signed(x))`), and every one TOGOLD**. Not one arm outside
the `$bits`-over-a-call family moved.

## 6. RESIDUES, NAMED AND NOT FIXED HERE

* **R1 — `$bits(<literal>)`, `$bits(<cast>)` and `$bits(<concatenation or
  replication>)`.** Golden keeps all of them (no typespec for any); we still
  fold. Arm A cell K04 (`$bits(5)`), arm E cells E08/E09 (`int'(ef133())`,
  `{ef133(), ef133()}`), and `v95_b6`'s `y[0]`–`y[3]`
  (concatenation, replication, `8'(pw)`, `int'(pw)`) and `y[10]`/`y[11]`
  (sized literals). **Corpus population 0**: every `literal` and `expr` cell in
  both corpora is already `BOTHKEEP` (CENSUS §4). Same one gate as §2a — the
  natural next widening, deliberately NOT taken here because each shape needs
  its own measured fence.
* **R2 — `$bits(<own struct property>.<member>)` folds in golden and we keep
  it** (arm A L34, arm E L37, `gv28_d_reach` 36/37). PRE-EXISTING and untouched:
  the pristine binary keeps them too. This is the only AWAY direction anywhere,
  and it has zero corpus population.
* **R3 — `$bits(this.<q>.<method>())`'s mockup `this` constant has no
  `vpiParent` in ours** where golden parents it at the `sys_func_call` (arm E
  L25, one dump line). Not a defect of this pass: uvm84's
  `mockupThisConst84` already RECORDS this exact case ("Golden ALSO parents it
  at a sys_func_call ARGUMENT … which the literal policy does not; `vpiParent`
  is read by no `Compare` method, so that difference is dump-only"). This pass
  merely makes that cell reachable.
* **R4 — `$bits(<type keyword>)` as a call ARGUMENT.** 250 corpus sites where
  golden keeps and we fold (uvm89/buvm16 R3, uvm93 §3). Untouched.

## 7. R0 — THE NEXT HEAD

BuildUVMPkg ×2, **64 cmp lines, 1 head**, `head_pat_default_BuildUVMPkg.cmp`:

```
LHS  struct_var: (uvm_pkg::uvm_reg_map_info::mem_range) @74749:27-74749:36
RHS  bit_var:    (uvm_pkg::uvm_reg_map_info::mem_range) @74749:27-74749:36
     everything else identical, INCLUDING the ref_typespec, whose vpiActual is
     struct_typespec (uvm_pkg::uvm_reg_map_addr_range) @61065:9-61069:4 on BOTH
     sides — so the TYPESPEC binding is already golden's and only the
     VARIABLE'S CLASS is wrong.
```

`pp_output:74749`, inside `class uvm_reg_map_info`:
`uvm_reg_map_addr_range mem_range;` — a class property whose written data type
is a **struct TYPEDEF NAME**. Golden builds a `struct_var`; we build a
`bit_var`. `BaseClass::Compare` fails on `VpiType`.

It reproduces in twenty lines: **arm `g133_a_kinds.sv` already carries it** —
`st133_t s_mem;` in `p133_a::kinds133_c` is `struct_var` on golden and `bit_var`
on ours, in both views (the first two lines of `diff g.dump pat.dump`). The lead
is `CompileHelper::compileVariable`'s named-typedef arm versus our
declarator-variable class choice; uvm129's README decodes the neighbouring
closed switch.

## 8. FILE MAP

| file | what it is |
|---|---|
| `arm133.sh` | one arm, BOTH producers, BOTH views (`-elabuhdm` handed to Surelog too), dumped, scored with the official `uhdm-cmp` |
| `qcen133.py` | the query-call census: every `$bits`/`$size`/`$clog2`/`$high`/`$low`/`$left`/`$right`/`$increment`/`$dimensions` cell of a dump, keyed on its START and classified by ARGUMENT KIND; skips `|vpiParent:` back-reference stubs |
| `qjoin133.py` | the two/three-way multiset join on that key: `BOTHKEEP` / `BOTHFOLD` / `GOLDKEEP-OURSFOLD` / `GOLDFOLD-OURSKEEP` / `ONLYGOLD` / `ONLYOURS`, and the TOGOLD / MOVEDWRONG / AWAY score |
| `cen133.py`, `score133.py` | the simpler per-line assignment-RHS census used for the arm tables |
| `wide133.sh` | the census over a whole sweep workdir; the golden path comes out of each row's OWN `cmds.txt` |
| `bound133.sh` | the wide boundary gate, reused verbatim from r10buvm30 via r10uvm120/r10uvm129 |
| `g133_a_kinds.sv` … `g133_e_edge.sv` | the five arms (kinds / homes / instances / siblings / near-misses) |
| `PREDICT` / `CENSUS` / `ARMS` / `BOUNDARY` / `GATES` / `MOVERS` `.r10uvm133.txt` | the measurements |
| `head_pris_*` / `head_pat_*.cmp` | the official `uhdm-cmp` head logs, before and after, for all seven rows |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `byteverify.sh` `ct8rows.sh` `rowheads.sh` | the standard gate scripts, copied verbatim so this directory runs on its own |
