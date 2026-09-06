# r10uvm181 — UVM pass 181

**§ `cloneBodyIsAScopeEvenWithNoOwnLocals181` — a wildcard-import CLONE body is
a clone-binding scope whether or not the subroutine declares anything at its
own level.**

| metric | pristine `e2190dd4` | this pass |
|---|---|---|
| SeqDriver `default` / `testflags` cmp lines | **29 / 29**, 1 head each | **13 / 13**, 1 head each |
| SeqDriver census `EMPTYTF\|LOOPVAR` MISS | 63 | **23** |
| SeqDriver census `EMPTYTF\|OTHER` MISS | 80 | **0** |
| SeqDriver census TOTAL MISS / EXTRA / BINDWRONG | 493 / 61 / 574 | **373** / **61** / **574** |
| MiniAmiq census TOTAL MISS / EXTRA / BINDWRONG | 512 / 76 / 136 | **392** / **76** / **136** |
| surelog rows differing from the committed baseline | — | **0 / 1588** |
| uhdm2rtlil rows differing (testflags + default) | — | **0 / 731** each |
| byte movers | — | **4 / 956** surelog, **0 / 1358** uhdm2rtlil |

Every mover was **predicted by name from pristine databases before the patched
sweep** (`PREDICT.r10uvm181.txt`), every mover is **additions only** (240
`vpiActual` edges filled, **0 removed**, `MOVERS.r10uvm181.txt`), and every
census/grid cell that moved moved **towards golden**: **AWAY = 0** and
**REGRESSION-CELLS = 0** in all four golden-grid arms and in all four
earlier-pass boundary arms that moved.

---

## 0. THE HEAD, DECODED FIRST — AND THE BRIEF'S FRAMING WAS WRONG

The brief (inherited from r10uvm180 § 9) reads the head as a **typespec**
question: "golden hangs a typespec reference on the foreach loop variable
pointing at the array's typespec; we hang none." The pristine head
(`head_pris_SeqDriver.default.cmp`, reproduced byte-identically on this pass's
own build) is

```
LHS(golden) = ref_var(j)@1018:19-1018:20 #8259
              < foreach_stmt(uvm_pkg::uvm_table_printer::calculate_max_widths)@1018:4
              vpiTypespec -> ref_typespec #8261 -> array_typespec #323101
RHS         = <null>
```

`BaseClass.h`'s SINGULAR `SafeCompare` (`:191-193`) sets `m_failedLhs = lhs` and
leaves `m_failedRhs` untouched, so the LHS printed is **the VALUE of a singular
edge golden has and we do not** — and the `vpiTypespec` subtree under it is
merely part of that value's decompile, not the failing field. The
owner-finder settles which edge it is by enumerating **every** edge of **every**
golden object that lands on `#8259` with the generated, kind-agnostic
`GetByVpiType`, and printing our counterpart's same edge
(`ct181own.cpp`, the direct-form mirror of r10uvm164's `ct164own.cpp`):

```
golden ref_obj(j)@1020:41 #126254   edge vpiType=700 (singular)   <- vpiActual
   ours ref_obj(j)@1020:41 #189608 -> singular <null>
   ours ref_obj(j)@1020:41 #243513 -> singular <null>
golden ref_obj(j)@1020:41 #190381   edge vpiType=700 (singular)
   ours ... -> singular <null>
golden ref_var(j)@1018:19 #126227   edge vpiType=700 (singular)
   ours ref_var(j)@1018:19 #189594 -> singular ref_var(j) #189597   (BOUND, agrees)
golden ref_typespec #8261           edge vpiType=81 (vpiParent, never compared)
```

**The head is a BINDING miss, not a typespec one.** `#8259` is golden's
§ `cloneLoopVarShared37` object — the third `ref_var` neither package view
lists — and the failing edge is a body reference's `vpiActual` onto it. Our
own shared object `#189597` exists and our clone's **listing** entries bind it
on both sides; what is bare is the `m_rows[j]` **index reference** in the clone
body. The typespec framing would have sent this pass to `TypeEmit`; the law
is in `TaskFuncEmit` and `UhdmExporter`.

`ct181ref.cpp` reads the four views apart at that one site:

| view | golden | ours (pristine) |
|---|---|---|
| `uvm_pkg` home, DEF listing | BARE | BARE (agrees) |
| `uvm_pkg` home, ELAB listing | `array_var j`@1018:19 | `array_var j`@1018:19 (agrees) |
| `adpcm_pkg` CLONE, DEF listing | `ref_var j` #8259 | **BARE** |
| `adpcm_pkg` CLONE, ELAB listing | `ref_var j` #8259 | **BARE** |

`adpcm_pkg` is SeqDriver's `package adpcm_pkg; import uvm_pkg::*;` wildcard
importer, so this is a CLONE question, not the HOME-listing question the brief
named.

## 1. THE DISTINGUISHER — ONE LINE OF DECLARATION COUNT

The same census at `uvm_printer.svh:1090`, `uvm_table_printer::emit`'s
`foreach (m_rows[i])`, in the SAME clone package, in the SAME statement shape
(`uvm_printer_row_info row = m_rows[i];`), **binds on our side already**. Two
sites, one package, one class, one shape; one binds and one does not. The
difference is the enclosing subroutine's own declarations:

```systemverilog
function string uvm_table_printer::emit();          //  <- string s; string user_format; ...
function void   uvm_table_printer::calculate_max_widths();   //  <- NOTHING at its own level
```

`calculate_max_widths` has no formals, no named return variable and no
function-scope local at all: `int name_len;` and `uvm_printer_row_info row;`
are declared inside the `foreach`'s own `begin`.

`TaskFuncEmit.cpp` builds a clone body's `lm9` map from `funcMap`, keeping only
symbols whose parent-scope chain reaches `sub` — and a block-local never
reaches `funcMap` at all (`emitStmt` registers it in the nested copy it hands
the block). For `calculate_max_widths` that map comes out **empty**, and the
pristine code refused to register the body:

```cpp
if (!lm9.empty())
    pkgCloneBodyLocals9[tf] = std::move(lm9);
```

`UhdmExporter.cpp`'s `bind9` — the single writer for § `pkgCloneHierBind9`,
§ `pkgCloneLocalRefBind37` and § `pkgCloneLoopVarBind37` — opens with

```cpp
auto bit9 = pkgCloneBodyLocals9.find(tf9);
if (bit9 == pkgCloneBodyLocals9.end())
    return;                       // <- the whole clone-binding law, switched off
```

**and only then** runs the innermost-out climb that finds the two targets that
are not in the map in the first place: `blockVar9` (an enclosing block's
`Variables()`) and `loopVar37` (an enclosing `foreach_stmt`'s `VpiLoopVars`
`ref_var`, whose `vpiActual` is the shared object). So the guard, meant to
avoid storing an empty map, silently disabled the climb for exactly the bodies
whose targets are reachable ONLY by the climb.

`name_len` still bound in the pristine build — which is why the first reading
of this head was wrong — but not through `bind9` at all: an ordinary
block-local reference binds during emission and § `cloneStmtHomeVarRef17` then
re-points it at the elaborated home's object. A foreach loop variable has no
such path: `StmtEmit`'s clone arm (`declLoopVar`, the
`classMethodNoBind || pkgDefViewBody9 || pkgImportCloneEmit` branch) returns
`nullptr` and registers nothing in `foreachLoopVarObjs9`, so `bind9` is its
only writer.

**THE LAW.** Register the clone body unconditionally.

```cpp
pkgCloneBodyLocals9[tf] = std::move(lm9);
```

Surelog has no such condition: `importPackage` re-resolves a clone body's names
against the IMPORTING package's symbol table for every cloned subroutine alike
(§ 37's decode of `CompileHelper::importPackage`; the clone's own listing is
built from the home's un-elaborated body whichever view it lands in). An empty
own-scope is not a reason to stop being a clone-binding scope. The map itself
is still the last resort inside `bind9`, and an empty one simply finds nothing,
so **no cell can move on the map's account** — every cell that moves moves
because the CLIMB found a block-local or a loop variable.

## 2. THE CENSUS — `CENSUS.r10uvm181.txt`

`ct181cen.cpp` joins golden's and our `vpiActual` for EVERY reference
(`ref_obj` / `ref_var` / `bit_select`) as a MULTISET keyed on
`package | subroutine | EMPTYTF? | LOOPVAR? | kind:name@line:col` plus the
occurrence's rank, so colliding keys cannot be dropped by a last-writer dict.
`EMPTYTF` is precisely the shape whose `lm9` is empty (no `Io_decls`, no
`Variables`); `LOOPVAR` is a reference whose name is an enclosing foreach's
loop variable.

SeqDriver / `default`, golden vs ours:

| bucket | MISS | EXTRA | BINDWRONG | OK |
|---|---|---|---|---|
| `EMPTYTF\|LOOPVAR` | 63 -> **23** | 0 -> **0** | 0 -> **0** | 99 -> **139** |
| `EMPTYTF\|OTHER` | 80 -> **0** | 0 -> **0** | 39 -> **39** | 2961 -> **3041** |
| `HASLOCALS\|LOOPVAR` | 287 -> **287** | 6 -> **6** | 4 -> **4** | 2966 -> **2966** |
| `HASLOCALS\|OTHER` | 63 -> **63** | 55 -> **55** | 531 -> **531** | 65304 -> **65304** |

120 cells move MISS -> OK; **EXTRA and BINDWRONG do not move at all**, and the
two `HASLOCALS` buckets are untouched cell for cell. MiniAmiq is the same
figure (512 -> 392 MISS, EXTRA 76 and BINDWRONG 136 both unchanged). Every
one of the 143 `EMPTYTF` misses in SeqDriver lives in `adpcm_pkg`, the clone —
none in `uvm_pkg`, none in a module.

The residue is the 23 that stay: `EMPTYTF|LOOPVAR` MISS 23 with `ONLY-G` 23 on
the same bucket, which is a different (cardinality) question — see § 6.

## 3. THE GOLDEN GRID — `GRID.r10uvm181.txt`

Four arms, each built as golden (Surelog, `def` and `elab`) plus BOTH frozen
binaries, scored three-way by `score181.py`. Names are unlike each other and
unlike the corpus's so that an arm which agrees agrees for a reason.

* **`g181_a_kinds.sv`** — the ARRAY-KIND axis in the EMPTYTF clone shape: fixed
  unpacked / queue / dynamic / associative `[string]` / packed vector / queue of
  packed struct / fixed array of string, each read in three positions
  (`bit_select` index, plain rvalue, nested expression); plus TWO controls, a
  twin with one function-scope local and a twin with a FORMAL (both
  `HASLOCALS`, both already bound).
  **TOGOLD=21 AWAY=0 REGRESSION-CELLS=0**, occurrences right 831 -> 877.
* **`g181_b_dims.sv`** — the ARITY axis: 1-D, 2-D and 3-D loop lists and every
  named-slot pattern (`[i]`, `[i,j]`, `[i,]`, `[,j]`, `[i,j,k]`, `[,,k]`,
  `[i,,k]`), a NESTED pair, and a nested pair that RE-USES the outer name.
  **TOGOLD=19 AWAY=0 REGRESSION-CELLS=0**, occurrences right 594 -> 632.
* **`g181_c_home.sv`** — the HOME axis: a package free function, a package free
  task, an OUT-OF-BODY class method (a package item, so cloned), an INLINE
  class method (never a package item, so never cloned) and a MODULE task.
  **TOGOLD=6 AWAY=0 REGRESSION-CELLS=0**; the six moving faces are exactly the
  free function, the free task and the out-of-body method, in both views, and
  the inline method's and the module task's rows are **byte-identical between
  the two binaries** (same md5 over their census rows).
* **`g181_d_negatives.sv`** — every name in an EMPTYTF clone body that golden
  must STILL leave bare: a class PROPERTY reached bare, `this`, a member of a
  CLASS-scope struct typedef, the implicit RETURN variable of a class method,
  alongside a package-scope struct member as the positive control, each with a
  `HASLOCALS` twin.
  **TOGOLD=4 AWAY=0 REGRESSION-CELLS=0** — only the LOOPVAR faces move; every
  negative stays exactly where it was.

**The one `MOVED-WRONG` in arm B is a NEVER-RIGHT cell and is named as such.**
`shadow181_fn` nests `foreach (gantry181_1d[keelson])` inside
`foreach (gantry181_2d[keelson])`: golden declares a SECOND loop variable at
85:29 and binds the inner body to it, while `declLoopVar`'s "a NESTED foreach
re-lists the enclosing loop's variable OBJECT" arm re-lists the OUTER object at
83:27 — in BOTH binaries. Pristine had 2 of the 6 occurrences bare and 4 bound
to the outer object; patched has all 6 bound to the outer object. Zero
occurrences agreed with golden before and zero agree now, which is why
`REGRESSION-CELLS=0`: nothing went right -> wrong. It is recorded as residue
R2 and it is not this law's to fix. The corpus confirms it does not occur in
a clone EMPTYTF body: `BINDWRONG` is unchanged at 574 (SeqDriver) and 136
(MiniAmiq) — a bare cell turning into a wrong target would have raised it.

## 4. THE GATES — `GATES.r10uvm181.txt`

All six, run in this worktree against the two FROZEN, `chmod 555` binaries,
with `SLANG_UHDM` exported explicitly per binary and every `cmds.txt` audited
by binary PATH:

1. both binaries built `-j 2`; md5s recorded separately.
2. goldens **23 PASS / 0 FAIL** on pristine AND on patched;
   `SLANG_UHDM=/bin/false` -> **0 PASS / 23 FAIL** (the negative control that
   proves the harness is reading the binary it was told to).
3. uhdm2rtlil, `testflags` **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**,
   baseline FIRST: **0 differing rows** (status AND dump column) against the
   committed `results/gate_uhdm2rtlil.csv`, and **0** again patched-vs-pristine
   in `default`.
4. surelog `--mode both`: **0 differing rows over 1588** against the committed
   `results/golden_surelog.csv`. **NO ROW WAS CONVERTED** — the `CMP_NOTEQUAL`
   population is 10 (`default`) + 9 (`testflags`), unchanged. `results/*.csv`
   were read only.
5. `byteverify SELFCHECK=1`: **4 movers / 956** surelog, **0 / 1358**
   uhdm2rtlil, `PATH_SETS_IDENTICAL` on both, SELFCHECK flagging 955/956 and
   1357/1358 (the instrument can see).
6. canaries `ok=52 changed=0` and `ok=8 changed=0`; both `ctcan2` PASS;
   `canaudit.sh canaries.sh ctcan2.sh` **audited=29 UNCOVERED=0
   FENCE-BREACH=0**; `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr`
   byte-identical pristine-vs-patched, `SVSwitch` pinned at `4842211c4030` and
   `YosysVerx` at `6ccda350c24a`.

The four slang-fenced tests were never dispatched and are never spelled in any
artefact here; `predict181.sh` writes its per-database log to SCRATCH and
commits only counts plus MOVER lines for exactly that reason.

### The movers — `MOVERS.r10uvm181.txt`

Predicted BY NAME from PRISTINE databases before the patched sweep
(`predict181.cpp` simulates the four conditions of the predicate and needs only
our own database): 9 candidate rows, of which the `loopvar > 0` sub-prediction
names **exactly** `MiniAmiq` and `SeqDriver` in both modes — the four rows that
actually moved. The other three (`BuildUVMPkg`, `Scoreboard`, `SimpleUVM`,
`loopvar=0 blockvar>0`) are the block-local half, which the ordinary emission
path had already bound; they did not move, and over-predicting a database costs
nothing while under-predicting one would hide a mover.

Each mover is **240 order-blind dump lines, 240 ADDED and 0 REMOVED** — filled
`vpiActual` edges and the objects they name, nothing retargeted and nothing
dropped — spread over seven EMPTYTF clone bodies:
`uvm_sequencer_base::grant_queued_locks` (28),
`uvm_table_printer::calculate_max_widths` (16), `uvm_reg_block::lock_model` (8),
`uvm_reg_block::sample_values` (4), `uvm_reg_block::needs_update` (4),
`uvm_reg_block::Xinit_address_mapsX` (2),
`uvm_component::m_get_tr_database` (2).

### The boundary — `BOUNDARY.r10uvm181.txt`

`bound181.sh` over a COPY of the whole of `tools/probe`, both binaries, DEF and
ELAB, fd-3 list with children `</dev/null`, recursive into subdirectory arms:
**LISTED=4967 PROCESSED=4967 PROCESSED-ASSERT-OK, MOVED=10**. Five of the ten
are this pass's own four arms. The other four are earlier-pass arms, and every
one was rebuilt against GOLDEN and scored:

| arm | verdict |
|---|---|
| `r10buvm19repro/grid19.sv` (its `imp19` wildcard-import arm) | TOGOLD=18 AWAY=0 REGRESSION-CELLS=0, right 1314 -> 1350 |
| `r10uvm21repro/t32d/t.sv` | TOGOLD=10 AWAY=0 REGRESSION-CELLS=0, right 381 -> 401 |
| `r10v171repro/v171_b_faces.sv` | TOGOLD=9 AWAY=0 REGRESSION-CELLS=0, right 2007 -> 2025 |
| `r10vbuvm19repro/vg19c.sv` | TOGOLD=4 AWAY=0 REGRESSION-CELLS=0, right 284 -> 292 |

`grid19.sv`'s 18 moved faces are ALL `imp19|…|EMPTYTF|LOOPVAR` — a committed
arm from another pass reproducing this law independently, on out-of-body
methods, free functions, a fork body and a named block alike.

`t32d/t.sv` is the one arm whose cmp LINE COUNT rose (1884 -> 1924 in the DEF
view). The head OBJECT is unchanged (`package pk`, a whole-package vector
mismatch that decompiles the entire package on both sides) and the cmp diff is
**40 added lines, 0 removed**: 20 newly-filled `|vpiActual:` edges and their
`ref_var` targets, all inside `pk1::C::run`. The head's decompile got longer
because we now hang edges golden hangs; the census says all 10 moved faces
moved TOWARD golden.

The § `hpTrailSelIdxDecompiled89` / `rendersAsItself89` / `selGroup89` cells,
the buvm14 `builtinRecvMultiDimStepIsBitSelectChain14` rows, the uvm84/85
`this.`/`super.` arms, the uvm77-79 hier_path joint arms, the uvm82-91,
buvm3-15 and sd8-12 arms and the § `cloneLoopVarShared37` / uvm178 / uvm180
arms are all inside the 4967 and **none of them moved**.

## 5. REPRODUCE

```bash
# the two frozen binaries
cmake --build build -j 2 && md5sum build/slang-uhdm

# the probes
for p in ct181own ct181ref ct181cen ct181grid predict181; do
  g++ -O2 -std=c++17 tools/probe/r10uvm181repro/$p.cpp -I ~/.local/include \
      -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/$p
done

# the head, decoded (SeqDriver's golden is the uvm-1.2 tree)
/tmp/ct181own <golden.uhdm> <ours.uhdm> calculate_max_widths
/tmp/ct181ref <golden.uhdm> <ours.uhdm> j 1020

# the census, and the four golden-grid arms
/tmp/ct181cen <golden.uhdm> <ours.uhdm>
for a in a_kinds b_dims c_home d_negatives; do
  bash tools/probe/r10uvm181repro/grid181.sh \
       tools/probe/r10uvm181repro/g181_$a.sv <pris.bin> <pat.bin> /tmp/g181/$a /tmp/ct181grid
  python3 tools/probe/r10uvm181repro/score181.py /tmp/g181/$a/cen.{g,a,b}.txt $a --quiet
done

# the prediction (PRISTINE workdir), and the wide boundary
bash tools/probe/r10uvm181repro/predict181.sh <pristine-workdir> /tmp/predict181 /tmp/raw.txt
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> \
  bash tools/probe/r10uvm181repro/bound181.sh
```

## 6. THE NEW HEAD — R0 FOR THE NEXT PASS

SeqDriver x2 falls 29 -> **13** cmp lines, still one head, and the head leaves
this family entirely (`head_pat_SeqDriver.default.cmp`):

```
LHS(golden) = func_call(max) #190554
              < hier_path(q.max)@1054:12-1054:17 #190551
RHS         = <null>
```

uvm-1.2 `base/uvm_printer.svh:1054`, `uvm_table_printer::emit`:

```systemverilog
int q[5];  int qq[$];
q = '{m_max_name,m_max_type,m_max_size,m_max_value,100};
qq = q.max;                     // <- 1054:12
```

Golden puts a `func_call` named `max` as the trailing element of the
`hier_path q.max` — a BUILT-IN ARRAY REDUCTION METHOD written with no argument
list — and we put nothing there at all, so the `hier_path`'s `Path_elems` is
one element short. That is the built-in-array-method family (adjacent to
buvm14's § `builtinRecvMultiDimStepIsBitSelectChain14`, which decoded the
`bit_select`-chain half of built-in receivers), and it is a new head: it is
neither this pass's family, nor the MiniAmiq unsupported-typespec head
(26 lines, unassigned), nor earl111's module-localparam width typespec.

MiniAmiq x2 stays at 26 lines on the same unassigned unsupported-typespec head
even though its bytes moved: this law fires below that head.

## 7. RESIDUES

- **R0 — the new head of § 6.** SeqDriver x2 at **13** cmp lines / 1 head:
  golden gives `q.max` a trailing `func_call(max)` element and we give the
  `hier_path` none, at uvm-1.2 `base/uvm_printer.svh:1054` in
  `uvm_table_printer::emit`. The built-in array-reduction-method family; a
  `hier_path::Path_elems` size mismatch, so `BaseClass.h`'s VECTOR
  `SafeCompare` names the OWNER on both sides when the sizes differ and the
  SINGULAR one names the value here.

- **R1 — the 23 `EMPTYTF|LOOPVAR` misses that remain**, with 23 `ONLY-GOLDEN`
  keys in the same bucket on both binaries and both before and after. Those
  are faces golden has that we do not emit at all (a cardinality question, not
  a binding one) and they are untouched by this law. They are the same 23 in
  SeqDriver and in MiniAmiq.

- **R2 — the nested-foreach SHADOWING cell** (`g181_b_dims.sv`'s
  `shadow181_fn`). When an inner `foreach` RE-USES the enclosing loop
  variable's NAME, golden declares a SECOND loop variable and binds the inner
  body to it; `declLoopVar`'s `openForeachVars` re-list arm gives us the OUTER
  object, in BOTH binaries. Zero occurrences agreed with golden before this
  pass and zero agree after (`REGRESSION-CELLS=0`); the corpus's `BINDWRONG`
  totals are unchanged, so the shape does not occur in a clone `EMPTYTF` body
  today. The arm is built and pins the cell for whoever takes it.

- **R3 — `EMPTYTF|OTHER` `BINDWRONG` 39 in SeqDriver** (0 in MiniAmiq), a
  wrong-TARGET population this law neither creates nor clears: `bind9` only
  ever fills a null. Now that the whole clone-binding law reaches these bodies,
  those 39 are the next thing a census of the clone bodies will see.

- **R4 — the brief's typespec framing, REFUTED.** The head's `vpiTypespec`
  subtree is part of the LHS VALUE's decompile, not the failing edge; the
  failing edge is `ref_obj::Actual_group` and the site is a CLONE listing, not
  the `uvm_pkg` HOME listing the brief named. Both halves were read off the
  owner-finder, and the home listing's two views agree with golden in the
  pristine build (bare in DEF, `array_var` in ELAB) — recorded here so the
  next reader does not re-derive it.
