# r10uvm194 — § `homeRetNameSelBindSurvivesDefViewUnbind194` — **THE HOME PACKAGE'S DEF LISTING OF AN OUT-OF-BODY METHOD KEEPS THE RETURN-NAME SELECT BINDING** — BuildUVMPkg ×2 CONVERTED TO `CMP_EQUAL`

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY** and **NOT EDITED**;
`GOLDEN_DEFER` stayed unset. The four slang-fenced tests were never dispatched
and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `287bbc94` |
| pristine binary | md5 `982e5776891c48fb0e30ab832c3c05d4`, built from this pass's OWN worktree at a clean `287bbc94` and **byte-identical to the main tree's `build/slang-uhdm`**; frozen `chmod 555` before any sweep |
| patched binary | md5 `d9d6c87f4c7163b532bbb2c719e0991a`, frozen `chmod 555` |
| production surface | `src/TypeEmit.cpp` (one clause + its law in `classRetNameDefViewNoBind37`), `include/UhdmExporter.h` (the law on `funcRetSelBound`) — **+51 / −1 lines, two files, no new state, nothing minted** |
| probe surface | `tools/probe/r10uvm194repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **BuildUVMPkg default AND testflags, 31 cmp lines, ONE `^LHS:` each, the SAME object and byte-identical `.cmp` output in both modes → 0 lines / 0 heads.** |
| corpus rows changed | **exactly 2, and both are CONVERSIONS to `CMP_EQUAL`** — `BuildUVMPkg,default` and `BuildUVMPkg,testflags`. Quoted verbatim in §7. Every other row of both corpora, both modes, is byte-identical (status AND dump column) against the committed baselines AND against this pass's own pristine sweep. |
| byte movers | **surelog 3 / 956**: BuildUVMPkg ×2 (PREDICTED BY NAME from pristine databases alone, before the patched sweep ran) and Scoreboard/default, which is the documented ~50/50 COIN and scores **0 order-blind diff lines**. **uhdm2rtlil 0 / 1358.** |
| the corpus population | a bare reference to a subroutine's own return name, in the home package's DEF listing of an OUT-OF-BODY class method, whose body writes a SELECT on that name as a DIRECT statement of the enclosing block: **2 cells per BuildUVMPkg row-mode, and none anywhere else in either corpus.** |
| the census (956 surelog rows + 1358 u2r rows) | calibrated golden-vs-golden FIRST (**6628 AGREE, every other column 0**). surelog **TO-GOLDEN 8, AWAY-GOLDEN 0, MOVED-WRONG 0**; uhdm2rtlil **1974 cells, all AGREE, nothing moved**. |
| the grid (3 arms × both views, one real Surelog golden each) | **TO-GOLDEN 48, AWAY-GOLDEN 0, MOVED-WRONG 0**. Arm A goes 31/1 → **0/0 CMP_EQUAL** in both views, arm C likewise; arm B's head CHANGES to the residue it was built to name (R1). |
| the WIDE boundary (5159 arms × both views) | `LISTED=5159 PROCESSED=5159 PRODUCED_DBS=4994 MOVED_ARMS=5 RC_DIFFS=0`. Three are this pass's own arms (the POSITIVE CONTROL). The other two are r10uvm171's HOME grids, rebuilt against their OWN real Surelog goldens and scored **TO-GOLDEN 6 / AWAY 0 / MOVED-WRONG 0** each — one of them, `g171_b_homes.sv`, is the arm whose residual head r10uvm171's README recorded as *"a PRE-EXISTING, unrelated defect on the OUT-OF-BODY class method"*, and it goes 31/1 → **0/0 CMP_EQUAL**. |
| what the fence caught | arm C. Without the import-clone fence the exemption would have re-bound the clone's copies of the same method, which golden leaves NULL — a pristine-RIGHT → patched-WRONG AWAY. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `287bbc94` worktree (it came
out byte-identical to the main tree's), ran its 23/23 goldens, and reproduced
both committed baselines row for row (`ct8rows` 0 differing rows, status AND
dump column, over 1588 surelog rows and both u2r modes) before a line of code was
written. `rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default/tf      58      1
SimpleUVM      default/tf  664681      1
Scoreboard     default         95      1
MiniAmiq       default/tf      58      1
BuildUVMPkg    default/tf      31      1     <- the target
Earlgrey_0_1   default/tf   31 / 36     1
Rggen          default    CMP_EQUAL
```

The head, the same object in both modes (`head_pris_BuildUVMPkg.*.cmp`, the two
files byte-identical):

```
LHS
bit_select: (uvm_pkg::uvm_packer::unpack_string::unpack_string), id:72450, @22952:7-22952:23
|vpiParent:  \_assignment: , id:72448, @22952:7-22952:52
|vpiName:unpack_string
|vpiIndex:   \_ref_obj: (…::unpack_string::i), id:72449, @22952:21-22952:22
               |vpiActual: \_int_var: (…::unpack_string::i), id:72426, @22937:7
RHS: <null>
```

`uvm_pkg.sv:22952` is `unpack_string[i] = m_bits[m_unpack_iter +: 8];` inside
`function string uvm_packer::unpack_string();` — an OUT-OF-BODY class method.

---

## 2. DECODING THE JUDGE — THE BRIEF'S FRAMING IS REFUTED

The brief read the head as *"the owner is the assignment"*. It is not.
`ct194own.cpp` (the MIRROR scan, r10uvm164's `ct164own` form) enumerates every
GOLDEN object holding an edge onto the head with the generated, kind-agnostic
`GetByVpiType`, and prints OUR counterpart edge beside it. Full output in
`OWNER.pristine.r10uvm194.txt`; the shape:

```
HEAD bit_select(unpack_string)@22952:7 …  <function:unpack_string <class_defn:uvm_packer <package:uvm_pkg
  OWNER assignment()@22952:7          edge 77  (vpiLhs)     ours -> bit_select(…)      present
  OWNER ref_obj(unpack_string)@22943:5  edge 700 (vpiActual) ours -> bit_select(…)      present
  OWNER ref_obj(unpack_string)@22943:22 edge 700 (vpiActual) ours -> bit_select(…)      present
  OWNER ref_obj(i)@22952:21           edge 81  (vpiIndex)   ours -> bit_select(…)      present
  -- owners=4  null-on-ours=0

HEAD bit_select(unpack_string)@22952:7 …  <function:uvm_packer::unpack_string <package:uvm_pkg
  OWNER assignment()@22952:7          edge 77   ours -> bit_select(…)   present
  OWNER ref_obj(unpack_string)@22943:5  edge 700 ours -> <null>   <<< THE OWNER
  OWNER ref_obj(unpack_string)@22943:22 edge 700 ours -> <null>   <<< THE OWNER
  OWNER ref_obj(i)@22952:21           edge 81   ours -> bit_select(…)   present
  -- owners=4  null-on-ours=2
```

Three facts the scan settles, none of them guessable from the cmp text:

* **the assignment's `vpiLhs` is present on BOTH sides** — the head is not a
  missing Lhs, and the head's own `vpiParent` is a TRAP (no generated `Compare`
  reads `VpiParent`, RESUME §9);
* the failing edges are the `vpiActual` (relation **700**) of the two BARE
  `ref_obj` at **uvm_pkg.sv:22943**, `unpack_string = {unpack_string," "};` —
  the statement NINE LINES ABOVE the select;
* and only in the **PACKAGE-listed** copy of the method. The **CLASS-listed**
  copy of the very same body agrees on all four owners, on both sides. The
  question is a LISTING, not a construct.

The minimal reproducer is 26 lines (`grid194/g194_a_homes.sv` is its grid form)
and produces a 31-line, one-head cmp of exactly the same shape.

---

## 3. DECODING SURELOG — WHY GOLDEN BINDS, AND WHY uvm-1.2 DOES NOT

`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3294`) walks a
reference's PARENT CHAIN outward and stops at the first arm that answers.

| line | arm | what it does |
|---|---|---|
| `:3296` | the walk's first line | `if (ref->Actual_group()) continue;` — a reference already bound is never re-examined |
| `:3550-3575` | **`uhdmbegin`** | scans the block's own `Stmts()` for an `assignment` whose `Lhs()->VpiName() == name`, **SKIPS a `ref_obj` / `ref_var` lhs**, and binds the reference to that **LHS EXPRESSION** |
| `:3371-3381` | `uhdmfunction` | `if (parent->VpiName() == name)` clone the routine's `Return()` and bind, then `break` |

The `begin` is the reference's INNER parent, so the block arm answers FIRST. It
knows nothing about return variables or listings: it answers in EVERY listing of
the body, which is why golden's def-view copy binds. The `function` arm, one step
further out, is what § `classRetNameDefViewNoBind37` models — and it cannot
answer for an out-of-body definition's package listing at all, because that
listing is named `Class::method`, never `method`.

Three consequences, each of them a scored grid cell rather than an argument:

* **only a SELECT can answer.** A whole write is a `ref_obj` lhs and is skipped —
  arm B's `b_whole` is NULL on both sides.
* **only a DIRECT statement of the block can answer.** **This is why the four
  uvm-1.2 rows lack the face.** uvm-1.2's own `uvm_packer::unpack_string`
  (`src/base/uvm_packer.svh:1010-1029`) writes the select under
  `if(big_endian == 0) … else begin … end`, so neither copy is a direct statement
  of the enclosing `begin`; the 1800.2-2017-1.0 pp_output BuildUVMPkg compiles
  has it as a direct statement of the `begin` at `uvm_pkg.sv:22941`. Arm A's
  `a_out_ifsel` is that shape written on purpose and is NULL on both sides,
  before and after.
* **an import CLONE can never answer**, because `:3296` has already excluded its
  references — they were bound to the HOME package's objects when the clone was
  compiled. Arm C measures it on a real golden: the clone's copies of the method
  are golden-NULL.

---

## 4. DECODING SLANG — WE ALREADY PRODUCE THE BINDING, AND THEN REMOVE IT

`endSelTrack` (`src/StmtEmit.cpp:335-390`) IS the emitter's model of that
`uhdmbegin` arm: `noteSelectObj` registers the block's first select of a name
(and registers nothing when the innermost scope is not a block, which is the
`if`-arm case), the drain re-points the body's bare whole references to it, and
for the FUNCTION RETURN NAME it records the reference in **`funcRetSelBound`** so
that `drainFuncRet` cannot clobber it with a freshly minted return variable
(`src/ModuleEmit.cpp:25567`, `:25587`). The package free function and the module
function already agree with golden cell for cell.

What removed it again is `classRetNameDefViewNoBind37` (`src/TypeEmit.cpp`), the
DESIGN-FINAL unbind: `drainFuncRet` hands it the WHOLE `pf.refs` vector,
select-bound references included, and it nulls every one of them in a listing it
classifies as def-view or clone. `SLANG_UHDM_DBG37` on the minimal reproducer
prints the two classifications side by side:

```
DBG37 p194::C194::oob_str cd=0x…   def=0  top=1  clone=0 -> 0    class listing, KEPT
DBG37 p194::C194::oob_str cd=(nil) def=-1 top=-1 clone=0 -> 1    package listing, UNBOUND
```

`SLANG_UHDM_DBG56` prints `lawA-drops=0 lawB-drops=0` on the same file, so
§ `classMethodRetNameNoBind56` / § `retNameNewLhsNoBind56` are not involved and
were left untouched.

**THE LAW, as ONE gated clause in that unbind loop** — nothing is minted, no
emission site moves, and every reference outside the set is nulled exactly as
before:

```cpp
const bool cloneTf194 = pkgImportCloneTfs16.count(tf) != 0;
for (auto* r : refs)
    if (r && !(!cloneTf194 && funcRetSelBound.count(r)))
        r->Actual_group(nullptr);
```

---

## 5. THE GRID (`grid194.sh`, three arms, one REAL Surelog golden each, BOTH binaries, BOTH views)

Scored by `scoregrid194.sh` as a MULTISET join of the `ct194cen` listings; the
DEF and ELAB listings are kept in SEPARATE rows and never merged (r10uvm166 §6 /
r10v169's listcheck law). Full transcript in `GRIDS.r10uvm194.txt`.

```
arm        view   AGREE  TO-GOLDEN  AWAY  MOVED-WRONG   uhdm-cmp pristine -> patched
a_homes    def      18       4        0        0          31 / 1 -> 0 / 0   CMP_EQUAL
a_homes    elab     44       8        0        0          31 / 1 -> 0 / 0   CMP_EQUAL
b_kinds    def      14       8        0        0          31 / 1 -> 43 / 1  HEAD OBJECT CHANGED
b_kinds    elab     43      16        0        0          31 / 1 -> 43 / 1  HEAD OBJECT CHANGED
c_clone    def      10       4        0        0          31 / 1 -> 0 / 0   CMP_EQUAL
c_clone    elab     32       8        0        0          31 / 1 -> 0 / 0   CMP_EQUAL
```

(TO-GOLDEN counts a moved cell twice — once as the payload we gained, once as the
one we lost — so 48 is 24 real cells.)

**`g194_a_homes.sv` — THE HOME GRID.** Twenty cells in the DEF view, of which
exactly TWO differ from golden in the pristine binary and NONE after. Every
negative control is in the same arm and agrees on both binaries:

| home | golden | pristine | patched |
|---|---|---|---|
| package FREE function `a_free` (2 spans × 2 copies) | `bit_select` | `bit_select` | `bit_select` |
| class method IN BODY `a_in` | NULL | NULL | NULL |
| **class method OUT OF BODY `A194::a_out`, package listing** | **`bit_select`** | **NULL** | **`bit_select`** |
| the same method's class listing `a_out` | `bit_select` | `bit_select` | `bit_select` |
| out-of-body, NO select in the body (`a_out_noselect`) | NULL | NULL | NULL |
| out-of-body, select under an `if` (`a_out_ifsel`) | NULL | NULL | NULL |
| MODULE function `a_mod` | `bit_select` | `bit_select` | `bit_select` |

**`g194_b_kinds.sv` — SELECT KIND × RETURN TYPE, every cell in an out-of-body
method.** `bit_select` on a string, `part_select` and `indexed_part_select` on a
packed vector, a WHOLE write, TWO selects, and a select on a LOCAL of the same
shape. It is the arm that TESTS rather than agrees: it moved the `bit_select` and
the two-select cells to golden and left the `part_select` / `indexed_part_select`
cells where they were — which is R1 below, and is why the arm's head CHANGES
rather than clearing.

**`g194_c_clone.sv` — THE CLONE AXIS, and the arm that EARNED THE FENCE.** A
package that wildcard-imports the home carries a clone of its whole listing, and
§ 37 unbinds the clone's copies too. Golden:

| listing | golden | pristine | patched |
|---|---|---|---|
| out-of-body method, HOME package listing | `bit_select` | NULL | `bit_select` |
| out-of-body method, IMPORT CLONE's copies | **NULL** | NULL | **NULL** |
| free function, HOME package listing | `bit_select` | `bit_select` | `bit_select` |
| free function, IMPORT CLONE's copies | `string_var` (the home `Return`) | `bit_select` | `bit_select` (R2) |

Without `cloneTf194` the second row would have become `bit_select` on our side —
a pristine-RIGHT → patched-WRONG AWAY that no corpus row would have shown.

---

## 6. THE CENSUS (`ct194cen.cpp` + `score194.py`, BOTH corpora)

Population: every `ref_obj`/`ref_var` whose name is the enclosing subroutine's
own leaf name. Key: the subroutine's name, the reference's span and the NAMED
ancestor chain — the DEF and TOP listings of one routine give the SAME key on
purpose (RESUME §9), so the copies are counted as a MULTISET. Payload:
compare-visible only — the kind, name and span of `Actual_group`, or `NONE`.
`vpiParent` is in neither.

```
CALIBRATION golden-vs-golden, whole surelog corpus      TOTAL {'AGREE': 6628}   every other column 0

surelog, pristine -> patched, both scored against golden (956 rows, 617 SKIP)
  BuildUVMPkg default    {'AGREE': 486, 'STILL-EXTRA': 1, 'TO-GOLDEN': 4}
  BuildUVMPkg testflags  {'AGREE': 486, 'STILL-EXTRA': 1, 'TO-GOLDEN': 4}
  the other seven UVM row-modes: STILL-EXTRA/STILL-MISSING unchanged, 0 moved
  TOTAL {'AGREE': 6558, 'STILL-EXTRA': 68, 'STILL-MISSING': 66, 'TO-GOLDEN': 8}

uhdm2rtlil (1358 rows, 104 SKIP)                        TOTAL {'AGREE': 1974}
```

**TO-GOLDEN 8, AWAY-GOLDEN 0, MOVED-WRONG 0.** The 66/68 STILL cells are the
SPAN residues r10uvm171 already recorded (`1022:41` vs `120:33`, `1165:63` vs
`1176:63` in `uvm_vreg::allocate` / `uvm_mem::get_access`): every one of them
carries payload `NONE` or `string_var`, **never a select**, so none is in this
law's population. `STILL-EXTRA: 1` on BuildUVMPkg is an ours-only `create`
candidate OBJECT in `uvm_registry_common`, `NONE` on both sides, unchanged.

**PREDICTED MOVER SET, BY NAME, from PRISTINE databases and their goldens ALONE**
(`predict194.sh`, run before the patched sweep): **`BuildUVMPkg` ×2 on the
surelog corpus, 2 keys each; NOTHING on uhdm2rtlil** (`TOTAL-KEYS 0`). The
measured mover set is exactly that plus the documented Scoreboard coin.

---

## 7. THE GATES — AND THE ONE CLAIMED CONVERSION

All green; full transcript in `GATES.r10uvm194.txt`.

**THE CONVERSION, LOUDLY.** Two surelog rows change, and both change from
`CMP_NOTEQUAL` to `CMP_EQUAL`. `results/*.csv` were **NOT edited** — the
promotion is the integrator's:

```
< BuildUVMPkg,default,CMP_NOTEQUAL,decompile:,,
< BuildUVMPkg,testflags,CMP_NOTEQUAL,decompile:,,
> BuildUVMPkg,default,CMP_EQUAL,,,differ
> BuildUVMPkg,testflags,CMP_EQUAL,,,differ
```

The same two rows and no other appear against the COMMITTED baseline
`results/golden_surelog.csv` and against this pass's own pristine sweep at
`287bbc94`. (`differ` in the dump column is ordinary for a `CMP_EQUAL` row: 547
of the patched sweep's 939 `CMP_EQUAL` rows carry it, 545 of the pristine
sweep's 937 — only these two were added.)

* goldens **23 PASS / 0 FAIL** on the patched binary and on the pristine one,
  negative control `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**;
* uhdm2rtlil both modes: three `ct8rows` comparisons **PASS** (0 differing rows,
  status AND dump column), byteverify **0 movers / 1358**, SELFCHECK 1357/1358;
* surelog both modes: **2 differing rows over 1588, both the conversion above**;
  byteverify **3 movers / 956**, SELFCHECK 955/956 — two PREDICTED BY NAME
  (BuildUVMPkg ×2, order-blind **+4 lines each, −0**, UNATTRIBUTED 0: two
  `vpiActual:` markers and the two `bit_select` faces they name) and one the
  documented Scoreboard/default COIN with **0 order-blind diff lines**;
* canaries surelog `ok=50 changed=2` — the two changed rows ARE the conversion,
  named in the output — and u2r `ok=8 changed=0`; both `ctcan2.sh` **PASS**;
  `canaudit.sh` **audited=29 UNCOVERED=0 FENCE-BREACH=0**;
* protected databases byte-identical by name (InterfaceModPort,
  BlackParrotComplex, YosysOldOr) and both brief pins HELD: SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`;
* boundary `LISTED=5159 PROCESSED=5159 PRODUCED_DBS=4994 MOVED_ARMS=5
  RC_DIFFS=0`;
* the four slang-fenced tests were never dispatched and are named only inside
  `canaudit.sh`'s own fence list.

**Heads.** Only BuildUVMPkg moves; every other named row's `uhdm-cmp` output is
**byte-identical** pristine vs patched (`HEADS.r10uvm194.txt`).

```
                   pristine      patched
BuildUVMPkg  def    31 / 1  ->    0 / 0    CMP_EQUAL
BuildUVMPkg  tf     31 / 1  ->    0 / 0    CMP_EQUAL
SeqDriver    def/tf 58 / 1  ->   58 / 1    cmp output byte-identical
SimpleUVM    def/tf 664681/1 -> 664681/1   cmp output byte-identical
Scoreboard   def    95 / 1  ->   95 / 1    cmp output byte-identical
MiniAmiq     def/tf 58 / 1  ->   58 / 1    cmp output byte-identical
Earlgrey_0_1 def/tf 31 / 36 ->  31 / 36    cmp output byte-identical
Rggen        def    CMP_EQUAL -> CMP_EQUAL
```

---

## 8. THE BOUNDARY AND THE FLOOR

```
LISTED=5159 PROCESSED=5159 PRODUCED_DBS=4994 MOVED_ARMS=5 RC_DIFFS=0
```

Subdirectory arms are compiled (the file list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path), and PROCESSED is asserted
against LISTED. **Three of the five moved arms are this pass's own
`grid194/g194_*.sv` — the POSITIVE CONTROL, without which the gate could not be
shown to see.**

The other two were rebuilt with a REAL Surelog golden in BOTH views and scored:

| arm | TO-GOLDEN | AWAY | MOVED-WRONG | uhdm-cmp |
|---|---|---|---|---|
| `r10uvm171repro/g171_b_homes.sv` | 6 | 0 | 0 | 31/1 → **0/0 CMP_EQUAL**, both views |
| `r10v171repro/v171_c_homes.sv` | 6 | 0 | 0 | 31/1 → 48/1, head object CHANGED |

Both are r10uvm171's HOME grids — the arms that carry the out-of-body class
method this law is about. **r10uvm171's own README recorded `g171_b_homes`'
residual head as "a PRE-EXISTING, unrelated defect on the OUT-OF-BODY class
method (`bit_select (home_src_171::OutBody171::mth_out::mth_out)` @34:5)". That
is this head, and the arm now clears.** `v171_c_homes`' pristine head was the
same object (`bit_select (…::OutB171::m_out::m_out)` @35:5); after clearing it a
PRE-EXISTING `func_call (h_free)` binding defect surfaces as the new head — its
census cells are identical on both binaries (STILL-EXTRA 2 / STILL-MISSING 2
before and after), so it was masked, not caused.

Order-blind attribution of all five moved arms (`armattrib194.sh`): every changed
line is a `vpiActual:` marker or a select face, **UNATTRIBUTED 0**.

**THE FLOOR IS UNTOUCHED**, verified by name rather than by assumption
(`BOUNDARY.r10uvm194.txt`):

```
uvm184 (2) + v184 (7, § retNameArgKeepsReturnVar184v and the receiver-kind fence)
uvm185 (5)  uvm186 (3) + v186 (5)  uvm187 (6)  uvm188 (4)  uvm189 (3)
uvm190 (4)  uvm191 (3) + v191 (3)  uvm192 (4)
uvm82-91 (113)   buvm3-15 (119)   sd8-12 (347)
                                                        MOVED = 0
```

r10uvm190's R5 static-address false mover did not appear: all five moved arms are
accounted for by content.

---

## 9. RESIDUES

* **R1 — `part_select` and `indexed_part_select` on a return name never reach
  `funcRetSelBound` at all.** Arm B names it in both views and it is the arm's
  new head (`part_select: b_part … @27:5`). Two independent causes, both
  pre-existing and both LEFT ALONE here because each is a law of its own with
  corpus reach outside this population: ExprEmit's indexed-part-select site calls
  `noteSelectObj` only when the base is a `logic_net` in `netMap`, so a return
  name never registers; and `endSelTrack`'s § r10fsv3 S9 carve-out (a variable
  ALSO written whole keeps its binding against a FOLDED-bound `part_select`)
  skips the plain part-select. Golden binds both, in the class listing as well as
  the package one — the class-listing cells are wrong in the PRISTINE binary too
  (`ACT=bit_var` where golden has the select), which is why this is a residue and
  not a regression. **No corpus row reaches it**: the whole-corpus census finds
  the population empty outside BuildUVMPkg's two `bit_select` cells.
* **R2 — an import clone of a package FREE function takes the SELECT where golden
  takes the home `Return`.** Arm C, DEF view, 4 cells, identical on both
  binaries. Golden's rule is § 171's (`a clone binds the home function's own
  return variable`) and it outranks the select; ours lets `funcRetSelBound` win.
  Fixing it means changing `drainFuncRet`'s guard, which moves SeqDriver and
  MiniAmiq cells and needs its own census — deliberately not folded into this
  pass. No corpus row reaches it either (the whole-corpus census shows no such
  cell).
* **R3 — the SPAN residues in `uvm_vreg::allocate` and `uvm_mem::get_access`**
  (`1022:41` vs `120:33`, `1165:63` vs `1176:63`), 6-12 cells per UVM row-mode,
  payload-identical on both sides and untouched here. Already recorded by
  r10uvm171; they are macro-expansion line numbering, not binding.
* **R0 — THE NEXT HEAD.** BuildUVMPkg is `CMP_EQUAL` in both modes, so the row
  family CLOSES and the queue moves on. The remaining named heads at this base,
  measured on the patched binary:

```
SeqDriver    default/testflags   58 / 1  }  the SAME object in all four row-modes:
MiniAmiq     default/testflags   58 / 1  }  int_var (uvm_pkg::uvm_phase::sync::visited.exists::succ),
                                         }  @1896:9-1896:16, vpiParent method_func_call(exists) @1907:22
SimpleUVM    default/testflags   664681 / 1
Scoreboard   default             95 / 1
Earlgrey_0_1 default / testflags 31 / 36, 1 each
```

  The SeqDriver/MiniAmiq head (`head_pat_SeqDriver.default.cmp`,
  `head_pat_MiniAmiq.default.cmp` — the two differ only in serializer ids) is a
  **`visited.exists(succ)`** built-in-method argument at `uvm_phase.svh:1907`,
  the very call § `cloneBuiltinMethodArgBindsReceiver184`'s array arm fenced OUT
  as a MOVED-WRONG; it is the ranked successor for the UVM family.

  The two arms this pass moved also each name a fresh head worth taking:
  `v171_c_homes.sv` now stops on a `func_call (h_free)` **binding** difference in
  a wildcard-import clone (48 lines, one head, both views, reproducible from one
  committed 60-line arm), and `g194_b_kinds.sv` stops on R1's
  `part_select: b_part` — a one-file, one-object head for whichever pass takes
  the part-select half of this family.

---

## 10. THE FILES

| file | what it is |
|---|---|
| `ct194cen.cpp` | the RETURN-NAME REFERENCE census — every `ref_obj`/`ref_var` named for its enclosing subroutine, keyed on subroutine + span + named ancestor chain, payload = the compare-visible face of its `Actual_group` |
| `ct194own.cpp` | the OWNER-FINDER for an `RHS: <null>` head — every golden edge landing on the head with its `vpiType`, and OUR counterpart edge beside it, matched on kind+name+span and never on identity; prints `<<< THE OWNER` on a singular edge that is null on our side |
| `build194.sh` | builds both instruments against `~/.local` |
| `cen194.sh` | the corpus census driver — golden found through each row's OWN `cmds.txt`, never guessed from a test name; a missing side is printed as SKIP and COUNTED |
| `score194.py` | the golden × pristine × patched MULTISET join and its verdict (`--ours2` for the after column) |
| `predict194.sh` | the mover set from PRISTINE databases alone (golden binds a select, we bind nothing). Uses `comm` on whole lines, never `join` — the key contains `|` and a field-splitting join manufactures a cross product |
| `grid194.sh` / `scoregrid194.sh` | the arm driver (one REAL Surelog golden per arm, both views, every rc recorded) and its scorer |
| `attrib194.sh` / `armattrib194.sh` | ORDER-BLIND attribution for a sweep workdir and for an arm workdir |
| `bound194.sh` | the wide boundary gate |
| `grid194/g194_a_homes.sv` | the HOME grid: package free function / in-body method / **out-of-body method** / out-of-body with no select / out-of-body with the select under an `if` / module function |
| `grid194/g194_b_kinds.sv` | SELECT KIND × RETURN TYPE inside an out-of-body method: bit / part / indexed-part / whole-write / two selects / select on a local |
| `grid194/g194_c_clone.sv` | THE CLONE AXIS — the arm that earned the fence |
| `DECODE.` `OWNER.pristine.` `HEADS.` `CENSUS.` `CEN.BuildUVMPkg.*` `GRIDS.` `PREDICT.surelog.` `PREDICT.u2r.` `MOVERS.` `BOUNDARY.` `GATES.r10uvm194.txt`, `head_{pris,pat}_*.cmp` | the evidence (SimpleUVM's 33 MB cmp files are deliberately not committed; its counts are in `HEADS.r10uvm194.txt`) |

---

## 11. REPRODUCIBILITY

The patch applied to a FRESH `287bbc94` worktree (`git apply -3`, rc 0, no
conflict markers, 56 files) and built independently there reproduces the gated
binary BYTE FOR BYTE: `d9d6c87f4c7163b532bbb2c719e0991a`, 23/23 goldens. The
pristine binary built the same way is byte-identical to the main tree's own build
at `287bbc94` (`982e5776891c48fb0e30ab832c3c05d4`), so **both sides of every
measurement above are reproducible from the repository alone.**

---

## 12. REPRODUCING

```sh
./build194.sh /tmp/r10uvm194_bin                              # the two instruments
ct194own <golden> <ours> 22952 7 bit_select                   # the head, decoded from the judge
CEN=…/ct194cen ./cen194.sh <pristine wd> <outdir>             # the census, either corpus
./predict194.sh <pristine census dir> PREDICT.txt             # the movers, before any patched sweep
python3 score194.py <pristine census dir> [--ours2 <patched census dir>]
CEN=…/ct194cen ./grid194.sh grid194/g194_a_homes.sv <pris> <patched> <wd> && ./scoregrid194.sh <wd> a_homes
./attrib194.sh <patched wd> <pristine wd> <outdir> <rel...>
./armattrib194.sh <arm wd> [<arm wd> ...]
PRIS=… PATCHED=… ./bound194.sh <copy of tools/probe> <outdir>
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <wd> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
bash canaudit.sh canaries.sh ctcan2.sh
```
