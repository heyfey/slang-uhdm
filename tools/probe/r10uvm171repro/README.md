# r10uvm171 — § `retNameSelBindsHomeReturnInCloneOnly171`

**BASE `3d549e59`.  Row family: SeqDriver (both modes).  Judge: the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else; every instrument in
this directory is MEASUREMENT-ONLY.  LHS is ALWAYS golden (Surelog), RHS is
ALWAYS ours.**

---

## 0. The law

> *In a **wildcard-import clone** of a package's free subroutine, a **select**
> on the return name (`uvm_instance_scope[pos]`) and the **method-receiver**
> spelling of it (`uvm_instance_scope.len()`, `uvm_instance_scope.substr(0,pos)`)
> bind the **home** function's own `Return` variable — the same object a bare
> reference there already binds.  At home (the declaring package's own views)
> and in a class method anywhere, both positions stay **bare**.*

Four emission sites, one gate, one drain.  The gate is a pointer
(`funcRetSelRefs171`) that is non-null only while a wildcard-import clone body
is walked, so every other body in the corpus emits byte-identically.

---

## 1. The head, decoded with the owner-finder FIRST

`rowheads.sh` on a pristine sweep at `3d549e59`:

```
SeqDriver      default         27      1 cmp rc=255
SeqDriver      testflags       27      1 cmp rc=255
```

One head, the same object in both modes:

```
LHS:
string_var: (uvm_pkg::uvm_instance_scope), id:2425, line:340:10, endln:340:16
|vpiParent:
\_function: (uvm_pkg::uvm_instance_scope), id:445, line:340:1, endln:358:12
...
RHS: <null>
```

`BaseClass.h`'s **singular** `SafeCompare` naming a VALUE (RESUME §9).  The
owner-finder `ct171own.cpp` (r10uvm161's form: it links the same generated
`Compare`, enumerates every edge of every golden object with the generated,
kind-agnostic `GetByVpiType`, and prints ours beside it) named the failing
edges outright — `vpiActual`, relation **700**:

```
golden bit_select(uvm_instance_scope)@352:26   ours -> singular <null>
golden bit_select(uvm_instance_scope)@354:28   ours -> singular <null>
golden ref_obj   (uvm_instance_scope)@351:9    ours -> singular <null>
golden ref_obj   (uvm_instance_scope)@357:24   ours -> singular <null>
```

and, in the SAME report, the `Return` edge (relation **666**) AGREEING on both
sides:

```
golden function(uvm_instance_scope)@340:1-358:12
    edge vpiType=666 (singular)
    ours function(uvm_instance_scope) -> singular string_var()@340:10-340:16
```

**The dispatch brief's reading is REFUTED.**  It framed the head as "we leave
the `Return` edge unset and parent the local at the begin".  The `Return` edge
is set on our side, everywhere; `ct171ret.cpp` (the return-edge / body-local
census) confirms it corpus-wide on SeqDriver: **not one key differs in
`Return`-edge presence between the two sides.**  The head is a **binding**.

Source (uvm-1.2 `src/base/uvm_misc.svh`), the nine references in the body and
what each side does with them in the clone:

```
340 function string uvm_instance_scope();
346   if(uvm_instance_scope != "")                       bare    golden BOUND  ours BOUND
347     return uvm_instance_scope;                       bare    golden BOUND  ours BOUND
349   $swrite(uvm_instance_scope, "%m");                 bare    golden BOUND  ours BOUND
351   pos = uvm_instance_scope.len()-1;                  recv    golden BOUND  ours BARE  <-
352   c = uvm_instance_scope[pos];                       select  golden BOUND  ours BARE  <-
354     c = uvm_instance_scope[--pos];                   select  golden BOUND  ours BARE  <-
356     uvm_report_error("SCPSTR", $sformatf(…,uvm_instance_scope));
                                                         bare    golden BOUND  ours BOUND
357   uvm_instance_scope = uvm_instance_scope.substr(0,pos);
        LHS                                              bare    golden BOUND  ours BOUND
        RHS                                              recv    golden BOUND  ours BARE  <-
```

All nine of golden's clone references land on ONE object — `string_var`
`id:2425`, the HOME function's `Return`.  We already bind the five bare ones
(`drainFuncRet`'s `pf.bindVar` / `rv9` branch).  This pass hands the other four
the SAME target and mints nothing.

---

## 2. The golden grid that fixes the two axes (`ct171list.cpp`, SeqDriver)

Every copy of every return-name select in the database, 30 rows a side:

| home                                                | golden | ours (pristine) |
|-----------------------------------------------------|--------|-----------------|
| `<function:uvm_instance_scope <package:uvm_pkg`      | BARE   | BARE  (4 spans × 2 copies) |
| `<function:uvm_instance_scope <package:adpcm_pkg`    | **BOUND** | BARE (4 spans × 2 copies) |
| `<function:… <class_defn:… <package:uvm_pkg` (12 rows) | BARE | BARE |

The twelve class rows — `uvm_packer::unpack_field` / `unpack_field_int` /
`unpack_string`, `uvm_mem_mam::reserve_region` / `convert2string`,
`uvm_vreg::allocate` / `convert2string`,
`uvm_report_catcher::get_report_catcher`,
`uvm_report_message::new_report_message` — are the law's negative control
INSIDE the same database: a class method's return-name select stays bare, and
so does the declaring package's own view.  **Clone-only on both axes.**

MiniAmiq is the same shape with `svaunit_pkg` as the importing package.

---

## 3. Surelog

The clone is a SECOND compile of the same body in the importing package's
scope, and by then the subroutine's return variable is in the listing the name
resolver reads: `CompileHelper::bindVariable` (`CompileStmt.cpp:3089`) answers
a name out of the enclosing scope's `Variables()`, and a function's `Return`
variable IS listed there — golden's dump prints
`string_var (uvm_pkg::uvm_instance_scope)` under the function's `vpiVariables`
beside `c` and `pos`.  At home the body was compiled before that listing
existed, so the same two positions stay bare.

`UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294-3383`) cannot rescue them
either: its `uhdmfunction` arm tests `parent->VpiName() == name` FIRST and
`break`s — the same `break` § `tfItemBodyLocal148` already cites for the
bare-reference half.  (Its clone-and-bind branch is also not what produced
golden's edges: it would parent the bound variable at the REF, and golden's
`id:2425` is parented at the FUNCTION.)

---

## 4. Corpus census and the mover prediction, made BEFORE the patched sweep

`ct171pred.cpp` lists, from ONE database, every select-family object and every
leading `ref_obj` of a method-receiver `hier_path` whose name equals the
enclosing subroutine's name.  `predsweep171.sh` runs `ct171list` (both sides)
over every row of a sweep workdir; `score171.py` joins the two listings per row
as multisets keyed on `(line:col, kind, BOUND|BARE)` — the home chain is
evidence, never a key (RESUME §9: the two producers label the clone's home
differently).

Run on the PRISTINE control workdirs at `3d549e59`:

```
surelog   rows=1573 SKIP=617 WITH-CANDIDATES=35
          TOTAL agree=337 TO-GOLDEN=32 AWAY=0 OTHER=14
u2r/def   rows=731  SKIP=52  WITH-CANDIDATES=17   agree=666 TO-GOLDEN=0 AWAY=0
u2r/tf    rows=731  SKIP=52  WITH-CANDIDATES=17   agree=666 TO-GOLDEN=0 AWAY=0
```

Every one of the 32 TO-GOLDEN cells is one of four spans in two rows:

```
SeqDriver  (default, testflags)   351:9 ref_obj  352:26 bit_select  354:28 bit_select  357:24 ref_obj
MiniAmiq   (default, testflags)   ditto
```

**PREDICTED MOVER SET, BY NAME: `SeqDriver` ×2 and `MiniAmiq` ×2 on the
surelog corpus; NOTHING on uhdm2rtlil.**

The SAME scan over the PATCHED surelog sweep closes it:

```
surelog   TOTAL agree=369 TO-GOLDEN=0 AWAY=0 OTHER=14
```

agree 337 -> 369 — **exactly the 32 predicted cells, all TO-GOLDEN;
AWAY 0 and MOVED-WRONG 0 before and after.**  The 14 OTHER cells are span
residues owned by other passes (`1022:41` vs `1030:18` and `120:33` in
`uvm_vreg::allocate`), BARE on both sides before and after.

The corpus DOES hold return-name `part_select` / `indexed_part_select`
candidates (50 rows surelog, 12 u2r) — every one of them in a MODULE function
(`<module_inst:`), never in a package import clone, so the clone gate excludes
them by construction and the two part-select sites below cannot move a corpus
cell.

---

## 5. The four sites

| site | file | what it mints |
|------|------|---------------|
| 1 | `src/ExprEmit.cpp`, `case ExpressionKind::ElementSelect` | `bit_select` |
| 2 | `src/ExprEmit.cpp`, the built-in method arm's `dots` loop | the leading `ref_obj` of the receiver `hier_path` |
| 3 | `src/ExprEmit.cpp`, `case ExpressionKind::RangeSelect` (indexed) | `indexed_part_select` |
| 4 | `src/ExprEmit.cpp`, `case ExpressionKind::RangeSelect` (simple) | `part_select` |

(`grep -n retNameSelBindsHomeReturnInCloneOnly171 src include` finds all of
them plus the gate, the drain and the law.)

Each calls `noteRetNameSelRef171(symbol, object)`, which is a no-op unless
`funcRetSelRefs171` is non-null — armed in `emitTaskFuncs` (`TaskFuncEmit.cpp`)
for `pkgImportCloneEmit` bodies only, saved/restored around the body walk like
`funcRetSym` / `funcRetRefs`.  `drainFuncRet` (`ModuleEmit.cpp`) binds the
collected objects inside its EXISTING `pf.bindVar` branch, to the same
`rv9 ? rv9 : pf.bindVar` target the bare references take, under `!Actual_group()`.

The collected objects are kept in `PendingFuncRet::selRefs171`, deliberately
APART from `refs`: `refs` also feeds `drainFuncRet`'s per-reference local mint
and the design-final unbind pools (`classRetNameRefs37`, `retNameRefs56`), and
golden's answer here contradicts all three.

Site 2 reads the symbol off `recv` (`k74 == 0 && dots.size() == 1`), not off the
name TEXT: only the first element of a one-name receiver can be the return
value, and a text test cannot tell a shadowing local of the same spelling apart.

---

## 6. Grid (`grid171.sh`, three arms, Surelog golden + both binaries, both views)

`g171_a_pos.sv` — POSITION × HOME.  One package free function touching its own
return name in six positions, and a second package that wildcard-imports it, so
the SAME six references must read differently in the two packages.  Plus a
control function doing all six on an ORDINARY LOCAL, and a packed-vector return
carrying `bit_select` / `part_select` / `indexed_part_select`.

`g171_b_homes.sv` — HOME grid: package free function / class method IN BODY /
class method OUT OF BODY / void function / task / module function, each
reachable from the importing package.

`g171_c_shapes.sv` — BODY-SHAPE and USE grid, all inside the clone: leading
declaration block / named `begin` / mid-body declaration / no locals / two
blocks; return name assigned-only / read-only / selected-only; select at body
top level, in a named begin, in a `for`, in a `while`, in an `if`.  If the law
were about a DECLARATION LISTING rather than a BINDING these cells would split.
They do not.

Scored as diff-lines between each binary's listing and GOLDEN's, per view
(the DEF and ELAB listings are kept in separate files and never merged —
r10uvm166 §6 / r10v169's listcheck law):

```
arm        view  cells  pristine-vs-golden  patched-vs-golden
a_pos      def     28          28                  0
a_pos      elab    63           0                  0
b_homes    def     21          12                  0
b_homes    elab    45           0                  0
c_shapes   def     88          88                  0
c_shapes   elab   198           0                  0
```

**`g171_a_pos.sv` earned the widening.**  Its first run scored the patched
binary at 8 diff-lines, not 0: cells `pv_shape[7:4]` @39:5 (`part_select`) and
`pv_shape[kx +: 2]` @40:5 (`indexed_part_select`) were golden-BOUND and
patched-BARE while the `bit_select` two lines above them had already moved.
Sites 3 and 4 exist because the arm convicted the first cut.

**The official judge on the same arms** (uhdm-cmp, pristine -> patched cmp
lines / head count):

```
g171_a_pos.sv     def   27 / 1  ->   0 / 0   TOWARD-GOLDEN (CMP_EQUAL)
g171_a_pos.sv     elab   0 / 0  ->   0 / 0   SAME
g171_c_shapes.sv  def   27 / 1  ->   0 / 0   TOWARD-GOLDEN (CMP_EQUAL)
g171_c_shapes.sv  elab   0 / 0  ->   0 / 0   SAME
g171_b_homes.sv   def   31 / 1  ->  31 / 1   SAME, head UNMOVED
g171_b_homes.sv   elab  31 / 1  ->  31 / 1   SAME, head UNMOVED
```

b_homes' residual head is a PRE-EXISTING, unrelated defect on the OUT-OF-BODY
class method (`bit_select (home_src_171::OutBody171::mth_out::mth_out)` @34:5)
— the very construct Surelog itself refuses (see the RC census below).  It sits
still under the patch, which is what a negative control is for.

RC census: every command `rc=0` except Surelog's own ELAB run of
`g171_b_homes.sv`, which exits 4 on
`[ERR:UH0725] … :33:10: Unresolved hierarchical reference "mth_out.len"` — a
Surelog limitation on the out-of-body class method — while still writing the
database, so the arm's 45 golden cells are real and are scored.  Recorded, not
hidden.

---

## 7. Gates (all on the frozen binaries)

```
pristine  600f33a71a99d749f2ca8f9223d6d20e   (built fresh in this pass's worktree at
                                              3d549e59 and BYTE-IDENTICAL to the main
                                              tree's build/slang-uhdm)
patched   40f4e1997a14ba258c37b706bb4ce319
```

All green.  Full transcript in `GATES.r10uvm171.txt`; here is the one-line form:

* goldens **23 PASS / 0 FAIL**, negative control `SLANG_UHDM=/bin/false`
  **0 PASS / 23 FAIL**;
* uhdm2rtlil both modes: three `ct8rows` comparisons **PASS** (0 differing rows,
  status AND dump column), byteverify **0 movers / 679** in each mode,
  SELFCHECK 678/679;
* surelog corpus both modes: `ct8rows` vs `results/golden_surelog.csv` and vs
  the 3d549e59 control both **PASS** — **0 differing rows over 1588**.
  **NO ROW CONVERTED; `results/*.csv` NOT EDITED.**
* surelog byteverify **7 movers / 956**, SELFCHECK 955/956 — four PREDICTED BY
  NAME (SeqDriver ×2, MiniAmiq ×2; order-blind **+16 lines each, −0**), three
  order-only with byte-identical `uhdm-cmp` output (BuildUVMPkg ×2 inside the
  `weaklyReferenced` tail, Scoreboard/default the documented 92-line coin);
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r), both
  `ctcan2.sh` **PASS**, `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
  the four slang-fenced tests appear only as FENCED skips and are never
  dispatched;
* protected databases byte-identical, both brief pins held: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`;
* boundary `LISTED=4780 PROCESSED=4780 PRODUCED_DBS=4623 MOVED_ARMS=12
  RC_DIFFS=0` — 3 of the 12 are this pass's own arms (the positive control that
  proves the gate can see), the other 9 are order-only with content-identical
  dumps and byte-identical cmp text (`BOUNDARY.r10uvm171.txt`).

**Heads.**  Only SeqDriver moves; every other named row's cmp output is
byte-identical pristine vs patched.

```
                  pristine      patched
SeqDriver    def    27 / 1  ->   33 / 1    HEAD OBJECT CHANGED
SeqDriver    tf     27 / 1  ->   33 / 1    HEAD OBJECT CHANGED
SimpleUVM  def/tf   17 / 1  ->   17 / 1
Scoreboard   def    95 / 1  ->   95 / 1
MiniAmiq   def/tf  106 / 1  ->  106 / 1
BuildUVMPkg def/tf 106 / 1  ->  106 / 1
Earlgrey_0_1 def    31 / 1  ->   31 / 1
Earlgrey_0_1 tf     26 / 1  ->   26 / 1
Rggen        def     0 / 0  ->    0 / 0
```

**MiniAmiq is a byte mover whose HEAD does not move** — its head is the
`unsupported_typespec (uvm_severity)` that r10uvm170 owns, and this pass leaves
it untouched while retiring eight of its binding cells.  Flagged for the
integrator: the two passes both write MiniAmiq bytes and must be integrated one
at a time.

---

## 8. Reproducibility

The patch applied to a FRESH `3d549e59` worktree (`git apply -3`, rc 0, no
conflict markers) and built independently reproduces the gated binary byte for
byte: `40f4e1997a14ba258c37b706bb4ce319`.  The pristine binary built the same
way is byte-identical to the main tree's own build at `3d549e59`
(`600f33a71a99d749f2ca8f9223d6d20e`), so both sides of every measurement above
are reproducible from the repository alone.

---

## 9. Residues

* **R1 — the clone's body locals are parented at the SUBROUTINE, not at the
  `begin`.**  `ct171ret.cpp` on SeqDriver: golden's import-clone views list a
  function's/task's `Variables()` with `vpiParent` = the `function`/`task`
  (`parents=functionx2`, `parents=taskx2`); we share the begin-parented objects
  (`parents=beginx2`).  The vector SIZES match and **no generated `Compare`
  reads `VpiParent`** (RESUME §9), so this is invisible to the judge — dump
  fidelity only, and a re-parent would touch 574 census keys for zero cmp
  benefit.  This is the half of the dispatch brief that survives, demoted to a
  byte-fidelity residue.
* **R2 — `var_select`.**  The census shows `var_select` objects on both sides
  (`g=4 o=0 var_select … act=io_decl` and friends in SeqDriver) but not one of
  them wears a return name, so the family is outside this law's population and
  has no site here.
* **R0 — THE NEXT HEAD.**  SeqDriver, both modes, now 33 cmp lines / 1 head,
  and the head OBJECT has changed — it is the MIRROR overload (`LHS: <null>`,
  a full RHS), i.e. an object WE have and golden does not:

```
LHS: <null>
RHS:
constant: , id:367, line:368:36, endln:368:48
|vpiParent:
\_param_assign: , id:366, line:368:11, endln:368:48
|vpiDecompile:32'h04c11db6
|vpiSize:32
|HEX:04c11db6
|vpiTypespec:
\_ref_typespec: (uvm_pkg), id:368
  |vpiActual:
  \_int_typespec: , id:369, line:368:1, endln:368:48
|vpiConstType:5
```

  `uvm_misc.svh:368` is `parameter UVM_STR_CRC_POLYNOMIAL = 32'h04c11db6;` —
  a **package-scope untyped `parameter`'s `param_assign` constant**, ours
  carrying `vpiTypespec -> ref_typespec (uvm_pkg) -> int_typespec @368:1-368:48`
  where golden's `param_assign` has no counterpart at that position at all.
  Decode it with `ct171own.cpp`'s MIRROR form (r10uvm164's `ct164own.cpp`),
  which scans OUR edges for the head and prints golden's counterpart.
