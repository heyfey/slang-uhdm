# r10uvm200 — § `impCloneDeclRangeNoBind200` — **A WILDCARD-IMPORT CLONE'S OWN DECLARATIONS KEEP THE PRE-LATE-BINDING STATE OF THEIR TYPE RANGES** — the SeqDriver ×2 and MiniAmiq ×2 33-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED** in either direction. `GOLDEN_DEFER`
stayed unset. The four slang-fenced tests were never dispatched by any driver
here and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `1af5cdae` |
| pristine binary | md5 `71288bea3b53a2587f780bd635206a47`, built from this pass's OWN worktree at a clean `1af5cdae` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own build at that commit** |
| patched binary | md5 `1a507182eed3ad1ca2b961b525a1eee6`, frozen `chmod 555`. The patch applied to a **FRESH `1af5cdae` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on. |
| production surface | `include/UhdmExporter.h` (the law, its Surelog decode and its fence), `src/TaskFuncEmit.cpp` (SITE 1 the FORMAL, SITE 2 the BODY LOCAL — the flag only), `src/TypeEmit.cpp` (ONE added conjunct on the existing bind gate). 83 added lines, 1 changed; nothing deleted, no object created, no object re-pointed. |
| probe surface | `tools/probe/r10uvm200repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default and testflags, 33 cmp lines, ONE head each → 50**; **MiniAmiq default and testflags, 33 → 50**. One object in all four row-modes before, a DIFFERENT object of a DIFFERENT family after (§ 7). A cmp line count is the HEAD OBJECT'S decompile size (RESUME.md §7), so a rise with a changed head is a cleared head. |
| every other row's head | cmp log **BYTE-IDENTICAL** between the two binaries — SimpleUVM ×2 17, Scoreboard/default 95, BuildUVMPkg ×2 **0**, Earlgrey_0_1 56 / **0**, Rggen/default **0**. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against this pass's own pristine sweeps (1588 surelog rows, 731 + 731 uhdm2rtlil rows). Against the committed baseline exactly one row-SIDE differs, `Earlgrey_0_1,testflags` `CMP_EQUAL/differ` → `CMP_EQUAL/`, and this pass's own PRISTINE sweep reads it the same way: a uhdm-dump TIMEOUT under sweep load, not a model change. **NO ROW WAS CONVERTED.** |
| byte movers | **5 / 956** surelog — the FOUR the prediction named BY NAME from the pristine databases alone, plus Scoreboard/default, the ~50/50 COIN, whose ORDER-BLIND dump diff is **0 content lines**. **0 / 1358** uhdm2rtlil. |
| the attribution | each moved row loses exactly **4 dump lines — two `\|vpiActual:` and the two `\_constant:` lines under them — and ADDS NOTHING**: two removed bindings per row, the importing package's def and elab listings. |
| the census (11 row-modes, golden-vs-golden calibrated FIRST on every one) | SeqDriver ×2 **TO-GOLDEN 2**, MiniAmiq ×2 **TO-GOLDEN 3**, **AWAY-GOLDEN 0, MOVED-WRONG 0** on both. SimpleUVM ×2, Scoreboard/default, **BuildUVMPkg ×2**, **Earlgrey_0_1 ×2**, **Rggen/default**: every mover column **0**. |
| the grid (5 arms × 2 views, one REAL Surelog golden each) | **TO-GOLDEN 20, TO-GOLDEN-ARITY 2, AWAY-GOLDEN 0, MOVED-WRONG 0**; 0 nonzero rcs. |
| the a-priori prediction | `strict` non-zero on **exactly four row-modes over 948 scanned surelog databases** — `SeqDriver` ×2 and `MiniAmiq` ×2 — and on **none of the 1358** uhdm2rtlil ones, where the law's WIDE bound is **empty outright**. |
| the WIDE boundary (5243 arms, both views, both binaries) | `LISTED=5243 PROCESSED=5243 PRODUCED_DBS=5058`, **RC_DIFFS 0, MOVED_ARMS 5 — and all five are this pass's OWN grid arms**, the positive control. **NOT ONE earlier-pass arm moved.** |
| the protected rows | BuildUVMPkg ×2, Earlgrey_0_1/testflags and Rggen/default stay **CMP_EQUAL** and their databases are byte-identical to the pristine sweep's; SVSwitch `4842211c4030` and YosysVerx `6ccda350c24a` PINS HELD; InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical. |
| goldens | 23 PASS / 0 FAIL on both binaries; `/bin/false` 23 FAIL (the negative control). |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `1af5cdae` worktree; it
came out **byte-identical** to the main tree's binary at that commit. Its
956-row surelog sweep and both 731-row uhdm2rtlil sweeps reproduce the
committed baselines row for row (the one informational dump-column cell in
`GATES.r10uvm200.txt` §2 excepted, which the pristine sweep shows too).

`rowheads.sh` on that sweep:

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         33      1
SeqDriver      testflags       33      1
MiniAmiq       default         33      1
MiniAmiq       testflags       33      1
```

and all four are the same object pair (`head_pris_*.cmp`):

```
LHS: <null>
RHS: constant, line:410:30, endln:410:60
     |vpiParent: \_param_assign: , line:410:11, endln:410:62
     |vpiDecompile:115199   |vpiSize:32   |INT:115199   |vpiConstType:7
     |vpiTypespec: \_ref_typespec: (adpcm_pkg) -> int_typespec @410:1-410:62
```

uvm-1.2 `base/uvm_globals.svh:410` is
`parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;` (120·120·8−1 =
115199), and `adpcm_pkg` (SeqDriver) / `svaunit_pkg` (MiniAmiq) is the package
that writes `import uvm_pkg::*;`.

## 2. THE BRIEF'S FRAMING, REFUTED FIRST — THE `param_assign` Rhs IS NOT THE EDGE

The brief names the head as *"golden's import copy of the UVM_LARGE_STRING
`param_assign` has NO Rhs where ours holds the folded constant"*. It does not,
and `ct200own` settles it two ways on the pristine pair:

```
--norhs   GOLDEN  PARAM_ASSIGN-TOTAL=652  NO-RHS=0
          OURS    PARAM_ASSIGN-TOTAL=655  NO-RHS=0
--pa=adpcm_pkg    90 rows a side, PA-NO-RHS=0 on BOTH, and the named row is
          IDENTICAL on both sides in both listings:
            UVM_LARGE_STRING imp=uvm_pkg rhs=constant[ct=7 sz=32 dec=115199]
```

**THE REAL EDGE**, from the referrer index (`--refs`): our constant #3340 has
three referrers, and the `param_assign::Rhs` one compares EQUAL — which marks
the constant visited. The judge then meets it again through

```
REF .Actual_group  rel1  ref_obj(UVM_LARGE_STRING)@434:43-434:59
```

where **golden carries nothing**. `ref_obj::Compare` reads `Actual_group`
(generated `ref_obj.cpp`), and the SINGULAR `SafeCompare` overload's
`lhs == nullptr` branch is what printed `LHS: <null>` over OUR value
(RESUME §9). The owner is the `io_decl str` of uvm-1.2 `uvm_globals.svh:434`

```
function string uvm_bits_to_string(logic [UVM_LARGE_STRING:0] str);
```

**as the importing package holds it.** `--edge=UVM_LARGE_STRING` counts the
whole population: golden has 8 such `ref_obj`, **BOUND 6 / UNBOUND 2**, and the
two unbound ones are exactly that `io_decl` under `package(adpcm_pkg)`, one per
view; ours has 10, **BOUND 10 / UNBOUND 0**.

`--fn=uvm_bits_to_string` prints the four copies a side and the whole law falls
out of them:

```
GOLDEN uvm_pkg   DEF   io_decl(str) range ref -> operation @410:30-410:62
GOLDEN uvm_pkg   ELAB  io_decl(str) range ref -> constant  @410:30-410:60
GOLDEN adpcm_pkg both  io_decl(str) range ref -> <null>
GOLDEN all four        RETURN string_var #23129 — THE SAME OBJECT, i.e. the
                       clone SHARES the home's return variable
```

## 3. DECODING SURELOG — THE CLONE IS A SNAPSHOT TAKEN BEFORE THE WRITE-PHASE REPAIR

Four sites, one rule (the citations in full are in `DECODE.r10uvm200.txt` §2
and in `include/UhdmExporter.h`):

1. **The reference cannot be bound when it is compiled.** `compileExpression`'s
   identifier arm cannot resolve a package parameter from inside the
   subroutine, mints a dangling `ref_obj` and FILES it —
   `CompileExpression.cpp:5769-5786`, `component->needLateBinding(ref)`.
2. **The repair happens in the WRITE phase, off that list.**
   `UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294`) walks
   `mod->getLateBinding()` and, at `:3814-3823`,
   `if (m && m->UhdmType() == uhdmpackage) ref->Actual_group(p->Rhs());` —
   the package's own `param_assign` Rhs. That is why golden's HOME def listing
   binds the unreduced `operation` and its ELAB listing the folded `constant`.
3. **The import copy is taken long before that.**
   `CompilePackage::collectObjects_`'s `CollectType::FUNCTION` pass calls
   `importPackage` (`CompilePackage.cpp:141-151`), which `clone_tree`s each
   task_func when the importer is a PACKAGE (`CompileHelper.cpp:299-324`).
   `ref_obj::DeepClone` is the generated one (`*clone = *this` +
   `BaseClass::DeepCopy`, which only re-parents), so the copy inherits the
   pointer the original held THEN: null.
4. **The repair cannot reach the copy, because the list is POINTER-KEYED.**
   `importPackage` copies the home's late-binding REQUESTS —
   `for (auto& var : def->getLateBinding()) scope->needLateBinding(var);`
   (`CompileHelper.cpp:191-193`) — the ORIGINAL objects. The importing
   package's own `lateBinding` therefore re-visits the home's refs (already
   bound, `if (ref->Actual_group()) continue;`) and never the clones. Same
   shape as § `classScopedTdImportCopyLocalUnsupported198`'s `getSwapedObjects`
   map and § `impCopyStringConstSize`'s clone: **the import copy is a snapshot,
   and every later repair keyed on the original misses it.**

**Why the RETURN is exempt, and it is a UHDM fact, not a Surelog one.**
`function::DeepClone` (UHDM `templates/clone_tree.cpp:469`) does
`if (auto obj = Return()) clone->Return((variables*)obj);` — a POINTER COPY —
while `Io_decls` and `Variables` immediately below are DeepCloned element by
element. The clone therefore lists the home's own return variable, whose range
ref the write phase DID bind.

**`-elabuhdm` undoes all of it.** `ElaboratorListener::leaveRef_obj`
(`templates/ElaboratorListener.cpp:1498-1507`) re-binds every dangling
`ref_obj` it walks, so in the elab view golden's clone cells carry `parameter`
actuals and so do ours — the elab column of every grid arm reads TO-GOLDEN 0 /
AWAY 0 on both binaries. The law is inert there by construction.

## 4. DECODING SLANG — ONE SITE WRITES IT, ONE CONJUNCT DECLINES IT

`src/TypeEmit.cpp` (~13583) is the ONLY place we bind a declared-type range
reference in a package subroutine:

```cpp
// Inside a package function's return/arg TYPE range (logic [PARAM-1:0]), a
// reference to a package parameter binds to that param's def-init constant
if (tfTypeScope && !ref->Actual_group() && !tdCloneRefNoBind18) { ... }
```

`tfTypeScope` is set at four call sites in `src/TaskFuncEmit.cpp`: the RETURN
(~3887, ~4056), the **FORMAL** (~5138) and the **BODY LOCAL** (~5851). The law
adds `&& !impCloneDeclRangeNoBind200` to the gate and sets that flag at the
formal and body-local sites only, so the return keeps its binding **by
construction**, not by a test.

## 5. THE GRID — five arms, one real Surelog golden each, both views

`GRIDS.r10uvm200.txt` carries the scored runs; every arm is scored with
`ct200cen` + `score200.py` over JUDGE-VISIBLE payload only
(`ref_obj::Actual_group`, the field `ref_obj::Compare` reads).

| arm | what it DECIDES | def | elab |
|---|---|---|---|
| A `g200_a_sites` | WHERE the reference lives: io_decl formal, tf-level local, named-begin local, formal DEFAULT value, body STATEMENT ref, and a LITERAL range control | TO-GOLDEN 4 + ARITY 2, AWAY 0, WRONG 0 | 0 / 0 / 0 |
| B `g200_b_kinds` | WHAT it names: parameter, localparam, `parameter int`, ENUM CONSTANT, a THIRD package's parameter qualified and bare, and a reference used as an OPERAND | 8 / 0 / 0 | 0 / 0 / 0 |
| C `g200_c_scopes` | CLASS scopes: in-class method, OUT-OF-BODY method, constructor, nested class | 2 / 0 / 0 | 0 / 0 / 0 |
| D `g200_d_importers` | WHICH importer: package (wildcard), re-export chain, EXPLICIT item, and MODULE / INTERFACE / PROGRAM | 4 / 0 / 0 | 0 / 0 / 0 |
| E `g200_e_head` | the corpus head MINIMISED — the POSITIVE CONTROL | 2 / 0 / 0 | 0 / 0 / 0 |

**AWAY-GOLDEN 0 and MOVED-WRONG 0 on every arm in every view.** Arm E's def
view goes from **33 cmp lines with one head to 17**: it reproduces the corpus
head's exact SHAPE — `LHS: <null>` over our folded `constant` whose parent is
the importing package's `param_assign` — in a source of a few hundred objects
rather than SeqDriver's ~293 000, and clears it. Arm D's `defmod` / `defiface` /
`defprog` cells are the must-stay control and do not move: `importPackage`
SHARES the home task_func for a non-package importer, so golden's listing there
keeps the home's BOUND refs.

What the arms establish about the law's shape, measured rather than assumed:

* **KIND-BLIND** — parameter, localparam, `parameter int`, an enum constant and
  an operand of a larger expression all lose the actual in the clone (arm B).
* **SHAPE-BLIND** — a literal value (`WLIT = 7`) and a folded expression
  (`WEXP = 4*2-1`) behave identically (arm A).
* **SITE-KEYED** — formals and body locals go unbound; the RETURN stays bound;
  a literal range has no ref at all (arm A `flit`, arm B `f_num`).
* **SCOPE-BLIND inside a clone** — an out-of-body class method behaves exactly
  like a free subroutine (arm C).
* **IMPORTER-KEYED** — only a PACKAGE importer clones (arm D).
* **BODY REFS UNTOUCHED** — a body statement's reference to the same parameter
  is unbound in golden's clone AND in ours already (arm A `fb`).

## 6. THE FENCE THAT TOOK AWAY-GOLDEN TO 0 — a measured narrowing, recorded as such

The first cut gated on `importCopyTsInst`, the test that names ALL THREE clone
drivers, and **grid arm D convicted it**: three cells moved AWAY from golden
(`defmod` / `defiface` / `elabmod` `io_decl(a)` of `fd`), and the arm's def cmp
went 33 → 277 lines. The cause is a PRE-EXISTING object-identity residue, not
this law: the EXPLICIT `import p::f` driver does not set `pkgImportCloneEmit`,
so its clone overwrites `pkgElabSubTf` — the registry `TaskFuncEmit` documents
as *"a wildcard-import CLONE is not that twin"* — and a module importing the
SAME package then lists that clone object where golden lists the home's
elaborated twin. `ct200own --lst=fd` names both sides:

```
GOLDEN defmod / defiface / defprog  -> function(fd)#5    = pa200d's ELAB twin
OURS   defmod / defiface           -> function(fd)#170  = pexp200d's ELAB clone
```

Narrowing the gate to `pkgImportCloneEmit` — the WILDCARD drivers, which ARE
fenced out of that registry — takes AWAY-GOLDEN to 0 on every arm and leaves
the explicit-item half as **R1**. MiniAmiq is the proof that the narrowing does
not cost the corpus anything: its `defiface` listing holds `svaunit_pkg`'s OWN
wildcard clone, golden holds the same object, and that cell moves TO golden
with the other two.

## 7. THE PREDICTION, THE MOVERS AND THE NEW HEAD

`PREDICT.surelog.r10uvm200.txt` and `PREDICT.u2r.r10uvm200.txt` were written by
`predict200.sh` + `ct200pred` from the **PRISTINE** sweep workdirs alone, before
the patched sweep was read. The criterion is the one the emitter rewrites,
expressed in the database the emitter produced: a `ref_obj` in the declared type
range of an `io_decl` or a body VARIABLE of a subroutine listed under a PACKAGE,
whose declaration typespec is stamped `vpiInstance` = a DIFFERENT package (our
`importCopyTsInst` clone stamp), carrying an actual.

```
surelog     scanned=948 NODB=617 FENCED=8
  PREDCELLS MiniAmiq,default   strict=14   PREDCELLS MiniAmiq,testflags  strict=14
  PREDCELLS SeqDriver,default  strict=7    PREDCELLS SeqDriver,testflags strict=7
  every other row strict=0 AND wide=0
uhdm2rtlil  scanned=1358 NODB=104 FENCED=0
  no row, and the WIDE bound is EMPTY over the whole corpus
```

The patched sweep moved **exactly those four rows**, plus Scoreboard/default,
the coin (order-blind diff 0 content lines). `MOVERS.r10uvm200.txt` carries the
hashes and the line-shape attribution. The criterion OVER-covers by the
explicit-item clone half the fence excludes (arm D's `pexp200d` cells are
predicted and correctly do not move); it can therefore only name a row that
does not move, never miss one that does — and over 948 + 1358 databases it
named no such row.

**R0 — THE NEXT HEAD, and it is a different object of a different family.**
SeqDriver ×2 and MiniAmiq ×2 now read **50 cmp lines, one head**, and it is
§ 198's family one construct over — a CLASS-HANDLE typedef this time:

```
LHS: unsupported_typespec: (uvm_reg_field_cb_iter), line:1128:10, endln:1128:31
     |vpiParent: \_ref_typespec: (adpcm_pkg::uvm_reg_field::do_predict::cbs)
     |vpiInstance: \_package: uvm_pkg
RHS: class_typespec: (uvm_pkg::uvm_reg_field_cb_iter), line:334:9, endln:334:26
     |vpiName:uvm_pkg::uvm_reg_field_cb_iter
     |vpiTypedefAlias: \_ref_typespec -> class_typespec (uvm_pkg::uvm_mem_cb_iter)
     |vpiInstance: \_package: adpcm_pkg
     |vpiClassDefn: \_class_defn: (uvm_pkg::uvm_callback_iter) @uvm_callback.svh:1037
```

uvm-1.2 `reg/uvm_reg_field.svh:1128` declares
`uvm_reg_field_cb_iter cbs = new(this);` — a BODY LOCAL of the out-of-body
method `uvm_reg_field::do_predict`, read here in the WILDCARD-IMPORT CLONE the
importing package holds — and the type is `reg/uvm_reg_cbs.svh:354`,
`typedef uvm_callback_iter#(uvm_reg_field, uvm_reg_cbs) uvm_reg_field_cb_iter;`,
a PACKAGE-scope typedef of a PARAMETERISED class specialisation. MiniAmiq's is
the same object under `svaunit_pkg`, and its two modes are byte-identical.

Two things are wrong at once and the next pass has to separate them:

* golden DEGRADES the clone's local to an `unsupported_typespec` spanned at the
  DECLARATION (`1128:10-1128:31`) and instanced at the HOME package — § 198's
  law one construct over, except that § 198's `clsScopedTdLocalName198`
  predicate requires a CLASS-SCOPE `TypeAlias` and this typedef is at PACKAGE
  scope, so it declines by its stated fence;
* our side binds a SHARED `class_typespec` whose span is **`334:9-334:26`** —
  that is `uvm_reg_cbs.svh:334`, `typedef uvm_callback_iter#(uvm_mem,
  uvm_reg_cbs) uvm_mem_cb_iter;`, a DIFFERENT specialisation twenty lines
  earlier — renamed to `uvm_pkg::uvm_reg_field_cb_iter` with its
  `Typedef_alias` still chaining to the `uvm_mem_cb_iter` object. So the
  specialisation objects of `uvm_callback_iter#(...)` are being SHARED and
  renamed rather than minted per typedef, which is a second, independent
  question.

Decode it with `ct200own --refs` and `--mint` (the mint census answers "one
object per typedef or one shared object renamed" directly), and with § 198's
`ElaborationStep::bindTypedefs_` / `swapTypespecPointersInUhdm` decode.

## 8. THE WIDE BOUNDARY

```
LISTED=5243 PROCESSED=5243 PRODUCED_DBS=5058 MOVED_ARMS=5 RC_DIFFS=0
```

over a COPY of the WHOLE `tools/probe` tree (top level AND every subdirectory),
both views, both frozen binaries. **All five moved arms are this pass's own
`grid200/g200_*.sv` — the positive control that proves the gate can see — and
NOT ONE earlier-pass arm moved.** The floor is therefore untouched in full:
uvm198's five arms and its `classScopedTdImportCopyLocalUnsupported198` cells,
uvm197's `impCopyStringConstSize` size-stamp arms, uvm196's
`modUnitImportParamsTwice196` arms, uvm188's render arms, uvm170/184-195's
arms, and uvm82-91's 113, buvm3-15's 119 and sd8-12's 347 — every one
byte-identical in BOTH views. `RC_DIFFS=0` covers the 185 arms that produce no
database on either binary: they fail identically, so no rc=139 segfault can
read as a result (RESUME §9). Details in `BOUNDARY.r10uvm200.txt`.

## 9. RESIDUES

* **R1 — the EXPLICIT `import p::f` clone.** Its declaration ranges stay bound
  where golden leaves them dangling (arm D `pexp200d`, both views). Closing it
  needs the `pkgElabSubTf` twin fence FIRST (§ 6), because the module listing
  currently shares that clone object; declining without the fence moves three
  module/interface cells AWAY from golden. Unmoved on both binaries.
* **R2 — the ENUM-CONSTANT range bound, everywhere.** `logic [E1:0]` binds
  golden's `enum_const` in EVERY listing — the home package's, the module's AND
  the clone's return — and ours binds nothing (arm B `k4`, 10 cells). A
  pre-existing gap in the same `tfTypeScope` arm, in the OPPOSITE direction to
  this law, and orthogonal to it. Unmoved.
* **R3 — the named-begin body local's range.** In the HOME and module views
  golden folds `logic [WA:0] loc2` to the `constant` and we keep the
  `operation` (arm A, 3 cells); inside the CLONE we emit no range ref for it at
  all, which is the arity residue the scorer counts separately (golden lists
  that local TWICE in a clone, we once). Unmoved.
* **R4 — the third-package range bound.** `logic [pc200b::WC:0]` and its bare
  spelling are FOLDED away by Surelog (no `ref_obj` cell at all) and we emit
  refs — 22 ONLY-OURS cells in arm B, identical on both binaries. Unmoved.
* **R5 — the formal DEFAULT VALUE's reference.** Golden emits a `ref_obj` for
  `input int k = WA` (bound in the home, dangling in the clone) and we emit
  none (arm A, 4 ONLY-GOLDEN cells). Unmoved.
* **R6 — the ELAB-view in-class method range.** In an `-elabuhdm` run golden
  leaves an IN-CLASS method's own declaration ranges dangling in the home
  package's elab listing and we bind them (arm C, 7 cells). No clone involved;
  a different family. Unmoved.

## 10. HOW TO REPRODUCE

```bash
cd tools/probe/r10uvm200repro
g++ -O2 -std=c++17 ct200cen.cpp  -I ~/.local/include -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct200cen
g++ -O2 -std=c++17 ct200pred.cpp -I ~/.local/include -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct200pred
g++ -O2 -std=c++17 ct200own.cpp  -I ~/.local/include -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct200own

# the judge decode, on the head's own row
/tmp/ct200own <golden.uhdm> <ours.uhdm> --norhs --pa=adpcm_pkg --refs
/tmp/ct200own <golden.uhdm> <ours.uhdm> --edge=UVM_LARGE_STRING --fn=uvm_bits_to_string
/tmp/ct200own <golden.uhdm> <ours.uhdm> --lst=fd          # the § 6 fence

# the grid (one real Surelog golden per arm, both views, both binaries)
for a in grid200/g200_*.sv; do CEN=/tmp/ct200cen bash grid200.sh "$a" <PRISTINE> <PATCHED> /tmp/w_$(basename $a .sv); done
python3 score200.py /tmp/w_g200_a_sites/cen.g.def.txt /tmp/w_g200_a_sites/cen.a.def.txt /tmp/w_g200_a_sites/cen.b.def.txt --show

# the a-priori prediction, from a completed PRISTINE sweep workdir
PRED=/tmp/ct200pred bash predict200.sh <pristine workdir> /tmp/pred.txt

# the corpus census over the UVM row-modes
CEN=/tmp/ct200cen bash cen200.sh <pristine workdir> <patched workdir> /tmp/cen

# the mover attribution (order-blind; Scoreboard/default is a coin)
bash attrib200.sh <pristine wd> <patched wd> /tmp/attrib '^(SeqDriver|MiniAmiq|Scoreboard)$'

# the wide boundary
PRIS=<PRISTINE> PATCHED=<PATCHED> bash bound200.sh <a COPY of tools/probe> /tmp/bnd

# the canary audit
bash canaudit.sh canaries.sh ctcan2.sh
```
