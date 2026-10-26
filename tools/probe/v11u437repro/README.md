# v11u437 — adversarial verification of r11u437

Base 535fde87 (pass 435). Implementer's patch /tmp/r11u437.patch (md5
e0b2653be167470d7d438f104b38c252) applied clean on a fresh 535fde87 worktree.
The production files are src/ExprEmit.cpp and src/StmtEmit.cpp only.

**Verdict: CONFIRMED.** On legal SV, no case was found where pristine was
right and the law is wrong. The verifier made no production change, so the
verified patch carries the implementer's ExprEmit and StmtEmit hunks
byte-identical.

## Targeted row

| row | before (golden_svtests.csv) | after (verifier's law sweep) |
|---|---|---|
| generated/uvm-examples/apb_protocol_monitor.sv | STRICT_NOTEQUAL differ:col(1) | **EQUAL** `generated/uvm-examples/apb_protocol_monitor.sv,EQUAL,,equal` |

The pristine record reproduced on the kept pair (uhdm-strictcmp against the
cached golden):

```
A: 7 bit_select APB_protocol_cg  work@apb_monitor.APB_protocol_cg apb_monitor.sv 145 21 145 22
B: 7 bit_select APB_protocol_cg  work@apb_monitor.APB_protocol_cg apb_monitor.sv 145 5  145 23
```

The targeted runner call (evidence/apb_runner.csv) reads `JUDGE_EQUAL,differ:col(1)` on
pristine and `EQUAL,equal,IDENTICAL` on law.

## Laws verified (each read through src/LawSwitch.h)

The no-header audit of the added lines finds no src/R*.h, no getenv and no
reader function.

- § newLhsSelCgCopyAtIndex437 (ExprEmit; R11U437_NEWLHSKIND_OFF)
- § newLhsVarSelNameSpan437 (ExprEmit; R11U437_NEWLHSVS_OFF)
- § newLhsHpSelFirstSpan437 (ExprEmit; R11U437_NEWLHSHP_OFF)
- § foreachCgArrLoopVarRef437 (StmtEmit; R11U437_FECGREF_OFF)
- § dynArrNewElemLvalueBase437 (ExprEmit; R11U437_DYNNEWELEM_OFF)

## Builds and binaries

- Law binary rebuilt once in /tmp/wt_v11u437 (`-j 2`). Its md5 is
  c98178f96356a1857de530783a24f19b, equal to the implementer's law3. It links
  slang 12.0.0+545f88b2e. It is frozen at /tmp/v11u437_bin/law.
- No pristine build. The pristine binary is the implementer's frozen copy at
  the base, md5 fd1a6e97920597b5c8c497956b4e6f1a (the brief's pristine md5),
  frozen at /tmp/v11u437_bin/pristine and used for case runs only. The
  pristine sweep reading is the master's control, /tmp/intr11u435.
- No verified build, because nothing needed refining.

## Gates: one five-stage sweep on the law binary

Workdir /tmp/v11u437_LW, with R11U437_TRACE on. It started after three
quiet readings. The four corpus stages ran through the worktree's
tests/sweep.sh. The sv-tests stage ran through scripts/check_svtests.py with
`--baseline` set to the worktree's results/golden_svtests.csv (535fde87),
because the worktree's UVM submodule is empty. scripts/ and tests/sweep.sh are
unchanged between 535fde87 and the main tree's HEAD, so this is the same stage.

| stage | result | vs control csv |
|---|---|---|
| probe | EQUAL 4023 + STRICT_NOTEQUAL 64, regressions=0 conversions=0 changes=0 | identical |
| surelog | default 480 / testflags 474 CMP_EQUAL, 0/0/0 | differs only in the two LowMem log-path texts |
| uhdm2rtlil | 803/1/67 in both modes, 0/0/0 | identical |
| downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0; not excused 0 | identical |
| svtests | EQUAL 1907, STRICT_NOTEQUAL 1, DIFFERENT 32, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1; regressions=0 conversions=1 changes=0 | differs only in the apb row; identical to the implementer's law3 svtests.csv on all 2346 rows |

The law index is current.

**byteverify (SELFCHECK=1), law workdir against /tmp/intr11u435:**

| corpus | movers | self-check flagged |
|---|---|---|
| surelog | 0 of 962 | 961 of 962 |
| uhdm2rtlil | 0 of 1608 | 1607 of 1608 |
| downstream | 0 of 805 | 804 of 805 |

The 4087 probe databases are identical to the control by path-normalized dump
(drivers/probedump.sh). A positive control, one database against a different
database, reads MOVER.

**Canaries and ctcan2:**

| check | result |
|---|---|
| canaries, surelog | ok=52, changed=0 |
| canaries, uhdm2rtlil | ok=16, changed=0 |
| ctcan2 surelog, EXPECT_UNKNOWN=1 | PASS (ok=58) |
| ctcan2 uhdm2rtlil, EXPECT_UNKNOWN=6 | PASS (ok=2) |

**Binary audit (fence-filtered cmds.txt):**

| corpus | records naming /tmp/v11u437_bin/law |
|---|---|
| surelog | 1523 of 1573. The other 50 hold only a Surelog line; two of those contain the text slang-uhdm inside a repository path. |
| uhdm2rtlil | 1740 of 1740 |
| sv-tests | 2346 of 2346 |

**Trace census (evidence/trace_census.txt):** across all five stages the laws
fire on exactly ONE database, sv-tests apb_protocol_monitor, through
§ foreachCgArrLoopVarRef437 on APB_protocol_cg and § newLhsSelCgCopyAtIndex437.
They fire on no corpus row and no probe case. This matches the implementer's
by-name prediction.

**Determinism:** three concurrent apb_protocol_monitor draws on law read one
hash (a97d0ff467) in 3 of 3.

## The implementer's grid reproduced (evidence/impl_grid_reproduced.tsv)

All 40 grid lines reproduce exactly on exit code, uhdm-cmp count and strict
verdict.

- `R11U437_OFF` gives pristine's bytes on 40 of 40.
- Each case's own switch restores pristine on 28. The other 12 need
  R11U437_NEWLHSKIND_OFF as well; they are the FC/NS foreach cases that also
  assign `cs[i] = new`.
- Downstream on the 24 class-free cases (evidence/impl_downstream.txt):
  - NS/ns07, DN/dn01, dn02 and dn08 go DIVERGENT -> IDENTICAL.
  - DN/dn03 goes EQUIVALENT -> IDENTICAL.
  - Every other case keeps its verdict.

## Attack grid: 95 fresh case dirs (cases/VA, VD, VF, VS, VX, VY)

Upstream slang (~/.local/bin/slang dut.sv --single-unit) accepts every case.
Every exit code is equal on pristine and law: 0, except VX/vx02 which exits 4
on both. Results are in evidence/attack_grid.tsv and evidence/attack_ddist.txt
(path-normalized dump distance to golden).

**Pristine -> law:**

| outcome | cases |
|---|---|
| STRICT_NOTEQUAL -> STRICT_EQUAL | 36 |
| NOT_EQUAL -> STRICT_EQUAL | 16 |
| NOT_EQUAL on both, closer by dump distance | 33 |
| NOT_EQUAL on both, same distance, bytes moved | 1 (VX/vx06, below) |
| byte-identical | 9 |
| further from golden | **none** |

The 9 byte-identical cases are VA/va10, va15, va16, VD/vd17, VF/vf09,
VS/vs08, vs14, vs18 and VX/vx04.

The shapes tried, per law:

- **§ newLhsSelCgCopyAtIndex437:** `cs[0] = new` without parentheses; with
  arguments; in a function, a for loop, an instantiated interface, a generate
  block and a program; a macro index; an associative cg array; `cs[idx[0]]`;
  in a fork, an if/else and an uninstantiated interface. The copy form
  `new src` in a module, a class method, a package-class array, a dynamic
  array, from a function result, and into a queue element; `this.c[1] = new
  this.c[0]` (byte-identical, § thisSuperNewAssignNoStmt3's empty assignment).
  - STRICT_EQUAL: every case except va07, va13 and the controls.
  - va07 (interface instance) and va13 (assoc cg) are closer.
- **§ newLhsVarSelNameSpan437:** loops; three dimensions; an index on the next
  line; a class-method local; a class property with and without `this.`; a
  macro index; a generate block; spaced brackets; a nested select index; a
  2-D cg array. All STRICT_EQUAL except vs06 (a class-method local, closer).
- **§ newLhsHpSelFirstSpan437:** `h.c[0][1]`, `h.arr[0].c[1]`, a function
  argument, a class member chain, the copy form `h.c[1] = new h.c[0]`, and
  `h.c[idx[1]]`.
  - STRICT_EQUAL: all of those.
  - Abstaining and byte-identical: an interface-instance path `u.c[0]` (vs08,
    STRICT_NOTEQUAL endcol on both) and `h[0].c[1]` (vs18).
  - vs04, a struct member `s.c[0]`, is closer.
- **§ foreachCgArrLoopVarRef437:** `cs[i,j]`; in a function and a task; with
  arguments; two instances; nested in an int foreach; beside a `sample()`
  loop; a `[1:0]` range; a `ref` argument; a package covergroup; a named
  block; an automatic local; an if body.
  - STRICT_EQUAL: all of those except the package covergroup.
  - Closer:
    - `cs[, j]` (vf03): golden writes an unnamed ref_var for the skipped
      slot.
    - a generate block (vf04): golden gives the iterated reference a fresh
      `unsupported_typespec cs` at the foreach.
    - a typedef'd cg array (vf12): the typedef head is the sister's.
    - a package cg (vx08).
  - vf09, the control, is byte-identical.
- **§ dynArrNewElemLvalueBase437:** a function local, a class-method local, a
  class property, three dimensions, a loop index, a package function, an
  interface, a generate block, a program, the copy form `new[n](src)`, a
  logic vector, a class-handle element, `int a[int][]`, two instances,
  always and final, a typedef'd dyn element, a task, a macro lvalue, a `ref`
  argument, $unit, `d[idx[0]] = new[idx[1]+1]`, byte.
  - The assignment now matches golden in every case: ref_obj `d` over the
    whole lvalue, bound to the net.
  - Every case is closer (vd03, a class property, is STRICT_EQUAL).
  - The remaining first difference is the declaration's dynamic-dimension
    range (`[0:unsized]`, `2-1`), the sister's TypeEmit face.
  - uhdm-cmp line counts grow on some (48 -> 56, 48 -> 101) because the first
    difference moved later in the walk, from the assignment to the
    declaration's array_var range, which golden prints whole.
  - vd17 (dotted, the § 110 control) is byte-identical.

**Switches** (evidence/off_grid.tsv, evidence/own_switch.txt):

- `R11U437_OFF` gives pristine's bytes and exit code on 125 of 125 case dirs
  (both grids).
- Each case's own switch restores pristine on 96. The other 29 (the
  implementer's 12 plus 17 VF/VX foreach cases that also assign
  `cs[i] = new`) need R11U437_NEWLHSKIND_OFF too.

**Downstream on the 53 class-free attack cases** (evidence/attack_downstream.txt):

| pristine -> law | cases |
|---|---|
| IDENTICAL -> IDENTICAL | 30 |
| DIVERGENT -> IDENTICAL | 6 |
| EQUIVALENT -> IDENTICAL | 4 |
| STATUS_DIFF -> IDENTICAL | 1 (VX/vx05) |
| EQUIVALENT -> EQUIVALENT | 3 |
| STATUS_DIFF -> STATUS_DIFF | 6 |
| DIVERGENT -> DIVERGENT | 1 |
| STATUS_DIFF -> DIVERGENT | 1 (VD/vd08) |
| IDENTICAL -> STATUS_DIFF | 1 (VX/vx03) |

Two of these need explaining:

- **VX/vx03 is not a break.** The case is `function automatic void f(ref int
  d[2][]); d[0] = new[2]; endfunction`. Pristine read IDENTICAL only because
  BOTH lanes failed to read, for different reasons:
  - Golden fails Yosys's `width < WIDTH_LIMIT` assert on the io_decl's
    `[0:unsized]` range.
  - Pristine fails with "Could not find wire 'd' for bit select".
  - The law's assignment is now golden's exactly: no dump line differs in the
    assignment, and the remaining differences are the io_decl's and x's
    ranges. Our lane now reads (NO_GATES) while golden's still fails.
  - The dump distance drops from 57 to 45.
- **VD/vd08:** our lane read-failed on pristine. It now reads, and differs
  only in the generate-scope net's width (`\g.d` at 64 bits in golden, 1 bit
  in ours).

## Earlier-pass census (wider than the implementer's)

The census covers 7128 fence-filtered case dirs under tools/probe. Every
r11u4*/v11u4* dir is in it, plus every other dir whose dut.sv contains `new`,
`foreach` or `covergroup`. Each ran on pristine and law.

- Exit codes are equal everywhere.
- 20 dirs exit 3 on both with no database.
- 12 movers, all toward golden (evidence/census_movers_judged.tsv, against
  freshly built goldens):
  - The implementer's 5: r11u436 IU/iu12 and iu13, v11u436 VC/vc03 and vc05,
    v11u413 VS/vs04, all to STRICT_EQUAL.
  - **7 more, outside the implementer's census, all toward golden:**
    - r11u181repro adv/a04: STRICT_NOTEQUAL endcol -> STRICT_EQUAL.
    - r11u190verify NW/n01: NOT_EQUAL -> STRICT_EQUAL.
    - r11u190verify NW/n02: STRICT_NOTEQUAL endcol -> STRICT_EQUAL.
    - r11v158repro rz/z04: STRICT_NOTEQUAL endcol -> STRICT_EQUAL.
    - r11v181repro lv/l06: STRICT_NOTEQUAL col -> STRICT_EQUAL.
    - r11v181repro lv/l12: STRICT_NOTEQUAL col -> STRICT_EQUAL.
    - r11u296repro CI/ci10_two_sel_path: NOT_EQUAL on both, dump distance
      512 -> 488.

## Goal 1 (reproduced)

All 75 SURELOG_ONLY rows carry an upstream slang diagnostic: 0 details name an
exporter message, and there is no SLANG_CRASH row.

| case | upstream slang | Surelog | pristine | law |
|---|---|---|---|---|
| v11u415 VT/vt03 | 0 | 3 | 0 | 0 |
| v11u413 VC/vc04 | 0 | 3 | 4 | 4 |
| v11u413 VI/vi06 | 0 | 3 | 4 | 4 |

bp_unicore measured alone on law exits 3 (the basic_string::substr message
under pass 403's size guard) in 14.6 s at 840 MB max RSS, so the guard stands.

## Residues (all wrong on pristine too, none moved away), ranked

1. **The dynamic-dimension range of `T d[N][]`, `T a[int][]`, `ref int d[2][]`.**
   Golden writes it as an operation `N-1` or as `[0:unsized]` on the
   declaration. This is the sister's face (TypeEmit), and the first difference
   on every DN/VD/VX dynamic-array case (DIVERGENT downstream on vd08 for the
   generate-scope net width).
2. **Covergroup-array foreach shapes the law does not reach:**
   - a generate block or an instantiated interface: golden mints a fresh
     `unsupported_typespec <array>` for the iterated reference (VF/vf04, FC/fc05);
   - the skipped slot `cs[, j]`, which golden writes as an unnamed ref_var
     (vf03);
   - dynamic and queue cg arrays (fc04, fc10);
   - a package covergroup (VX/vx08), a typedef'd cg array (vf12), program cg
     arrays (fc06) and a loop variable shadowing a module int (fc11).
3. **Class-new left sides the span laws abstain on:**
   - an interface-instance path `u.c[0] = new` (VS/vs08, STRICT_NOTEQUAL endcol);
   - `h[0].c[1] = new` (vs18);
   - a struct member `s.c[0] = new` (vs04);
   - a class-method local 2-D array (vs06);
   - an associative cg array (VA/va13);
   - a cg array in an instantiated interface (va07).
4. **VX/vx06 `C::d[0] = new[2]`** (a class-scoped static property). Golden
   keeps the assignment with no lhs and no rhs. Pristine wrote ref_obj
   `C::@@BAD_SYMBOL@@` and the law writes ref_obj `d`. It is wrong on both at
   the same dump distance (17) and the same uhdm-cmp count (25), outside the
   decoded shape (§ dynArrayNewLvalueBase110's R-static110). Bytes move with no
   gain; a narrowing abstention on a class-scoped base would be byte hygiene
   only.
5. The carried backlog of passes 435 and earlier, untouched.

## Sister-ground faces (reported, not written)

- **TypeEmit:** the declaration range of a dynamic or associative unpacked
  dimension, as in item 1.
- **ModuleEmit:**
  - the generate-scope dyn-array net's width (VD/vd08 downstream);
  - the instantiated interface's covergroup-array listing (va07, fc05);
  - the extra elaborated array_var for dynamic and queue cg arrays (fc04,
    fc10).

## Process

The verifier stayed within the budget: one law build, no pristine build, no
verified build, one five-stage sweep. Nothing of its own overlapped another
agent's sweep. Its attack and implementer grids (case runs) ran while the
sister r11u440's pristine sv-tests runner batch was live; that is a slip, and
it affects no measurement. Its own sweep started after three quiet readings,
once its census and downstream case runs had ended.

The fence list was read into a file by a program without printing it, and
every tree-wide list was filtered on it first. No fenced test was named,
opened or run. No other agent's process was touched.

Drivers are under drivers/: grid.sh, ddist.sh, ownsw.sh, census1.sh,
probedump.sh and dsgrid.py.
