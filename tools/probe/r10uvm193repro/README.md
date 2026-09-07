# r10uvm193 — § `cloneArrayRecvArgMintsElemVar193` — **AN ARRAY RECEIVER'S ARGUMENT DOES NOT TAKE THE RECEIVER: IT TAKES A RENAMED COPY OF THE ARRAY'S OWN ELEMENT VARIABLE** — the SeqDriver ×2 / MiniAmiq ×2 58-line head CLEARED

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**. `GOLDEN_DEFER` stayed unset. The
four slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `9c358cda` |
| pristine binary | md5 `d5a59dbbef4563591865e0da88492e57`, built from this pass's OWN worktree at a clean `9c358cda` and frozen `chmod 555` before any sweep |
| patched binary | md5 `95ea482622bc432f0f2460e6739a6ad6`, frozen `chmod 555` |
| production surface | `include/UhdmExporter.h` (the law, one set, two declarations), `src/UhdmExporter.cpp` (one mint helper, one design-final drain, one call site, one `<functional>` include) |
| probe surface | `tools/probe/r10uvm193repro/` only |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **SeqDriver default/testflags AND MiniAmiq default/testflags, 58 cmp lines, ONE `^LHS:` each, the SAME object in all four row-modes → cleared** (58 → 29 lines, still ONE head, a NEW object). |
| corpus rows changed | **0** — both corpora, both modes. `ct8rows` PASS against the committed baselines AND against this pass's own pristine sweep, status AND dump column. |
| byte movers | **surelog 4 / 956**, all four PREDICTED BY NAME from the PRISTINE databases and their goldens alone. **0 / 1358** uhdm2rtlil, matching `PREDICTED=0` exactly. |
| the a-priori prediction | `LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4 CELLS=40` — SeqDriver ×2, MiniAmiq ×2, **10 cells each**, and nothing else. |
| the corpus population | the DIRECT `ref_obj` arguments of a method call whose RECEIVER is bound to an `array_var`, inside a wildcard-import clone body: **5 keys × 2 clone listings = 10 cells** per moving row-mode, in three UVM subroutines. |
| the census (nine UVM row-modes) | SeqDriver ×2 and MiniAmiq ×2 **TOWARD 10 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0 / ORPHAN MINTS 0** (golden 10 mints, pristine 0, patched 10); SimpleUVM ×2, Scoreboard/default and BuildUVMPkg ×2 score **TOWARD 0 / AWAY 0 / MOVED-WRONG 0** and hold no mint on any of the three sides. Calibrated golden-vs-golden-vs-golden FIRST: every column 0 but UNTOUCHED, on every row. |
| the grid (4 arms × both views) | A **TOWARD 6**, B **TOWARD 10**, C **TOWARD 18**, D **TOWARD 2** — **AWAY 0, MOVED-WRONG 0, ONLY-OURS-MOVED 0 and ORPHAN MINTS 0 in every arm, every view**, each calibrated golden-vs-golden-vs-golden at every column 0 first. Arm C's DEF view goes `uhdm-cmp` rc=255 → **rc=0**. |
| the WIDE boundary (5160 arm files × both views) | `LISTED=5160 FENCED_SKIPPED=0 PROCESSED=5160 PROCESSED-ASSERT-OK`, no `ASYMMETRIC_OUTPUT`, **MOVED 20 arm-views**: this pass's own four arms (8), the three DECODED static-address false movers (6), and three arms that hold this law's OWN cells (6) — `r10uvm184repro/g184_b_kinds.sv`, `r10v184repro/gv184_d_recvmeth.sv` and `r10uvm39repro/t55b/dut.sv` — each re-scored against its OWN real Surelog golden at **TOWARD 4 / AWAY 0 / MOVED-WRONG 0** in both views, same head object on both binaries. |
| the MUST-STAY floor, scored in both columns | § `cloneBuiltinMethodArgBindsReceiver184`'s STRING cells (`cable.substr(1,kink)`, `cable.getc(kink)`) read `string_var (cable) @17:13` — THE RECEIVER — **byte-identically on the pristine and the patched binary**, in the same arm and the same clone listing where § 184's ARRAY cells move to golden. § 186's, § 189's, § 191's, § 139's, uvm180-183/185/187/188/190's, uvm82-91's, buvm3-15's and sd8-12's arms are byte-identical in the wide boundary. |
| what the first cut got wrong, and what caught it | the `pushVar` half's subtree walk followed EVERY edge instead of containment, escaped through a `variables`' `vpiInstance` into the HOME listing and scored **AWAY 3 (def) / AWAY 2 (elab)** on arm A. See §5. |
| the patch reproduces | applied to a FRESH `9c358cda` worktree with `git apply -3` (two files, cleanly, 0 conflict markers) and built there, the tree produces md5 `95ea482622bc432f0f2460e6739a6ad6` — the very binary every number above was measured on. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

This pass built its own pristine binary from a clean `9c358cda` worktree, ran
its 23/23 goldens (`/bin/false` 0/23), and reproduced the committed baselines
row for row — surelog `937/567/48/19/10/3/2/1/1`, uhdm2rtlil `679/50/2` in both
modes, `ct8rows` PASS on all of them, status AND dump column — before a line of
code was written. `rowheads.sh` on that sweep (`HEADS.r10uvm193.txt`):

```
TEST           MODE      CMPLINES  HEADS
SeqDriver      default         58      1
SeqDriver      testflags       58      1
SimpleUVM      ×2          664681      1
Scoreboard     default         95      1
MiniAmiq       default         58      1
MiniAmiq       testflags       58      1
BuildUVMPkg    ×2             300      1
Earlgrey_0_1   default/tf   31 / 92     1
Rggen          default    CMP_EQUAL
```

The head, the same object in all four row-modes (`head_pris_*.cmp`):

```
LHS (golden)
int_var: (uvm_pkg::uvm_phase::sync::visited.exists::succ)  line:1896:9-1896:16
|vpiParent:  method_func_call: (exists)                    line:1907:22-1907:28
|vpiTypespec: -> ref_typespec -> int_typespec              line:1896:5-1896:8
|vpiName:succ
|vpiSigned:1
RHS (ours)
ref_var: (adpcm_pkg::uvm_phase::sync::succ)                line:1906:34-1906:38
|vpiParent:  foreach_stmt                                  line:1906:7-1906:14
|vpiTypespec: -> ref_typespec -> unsupported_typespec (succ)
|vpiName:succ
```

A **both-sides VALUE mismatch**, not a null (RESUME §9's singular `SafeCompare`
naming a value). `ct193arg own` runs the OFFICIAL `design::Compare` and then
scans BOTH databases with `GetByVpiType` — the generated, kind-agnostic edge
accessor, so no field is named by hand and none can be missed — for every edge
that lands on the head object:

```
GOLDEN  int_var(succ)@1896:9-1896:16
  parents <method_func_call:exists:1907 <hier_path:visited.exists:1907
          <operation:1907 <begin:1906 <foreach_stmt:1906 <begin:1900
          <while_stmt:1900 … <function:sync:1879 <class_defn:uvm_phase:134
          <package:uvm_pkg:28/ELAB
  edges landing on it:
    ref_obj(succ)@1907:29-1907:33   vpiActual (singular)   listing adpcm_pkg/DEF
    ref_typespec()                  vpiParent
OURS    ref_var(succ)@1906:34-1906:38   — our `foreach` LOOP VARIABLE
  edges landing on it: six `vpiActual`s and the foreach's own loop-var list
```

**Exactly ONE reference in golden binds that object: the ARGUMENT of
`visited.exists(succ)`** (uvm-1.2 `uvm_phase.svh:1907` over
`int visited[uvm_phase]` at `:1896`), in the adpcm_pkg CLONE listing — and the
object it binds is not a declaration anywhere. It is a **MINT**: a variable
whose `VpiParent` is the CALL, named after the ARGUMENT, kinded and spanned at
the ARRAY's own declaration.

`ct193arg at <db> 1896` says where the kind and the span come from, on both
sides at once:

```
array_var(visited)@1896:9-1896:16   vpiVariables[1] = int_var()@1896:9-1896:16
```

**The mint is a RENAMED COPY of `array_var (visited)`'s own element variable**,
and both databases already carry that element variable identically.

---

## 2. THE DECODED MODEL — one UHDM block, two branches, and § 184 is the other one

> **§ `cloneArrayRecvArgMintsElemVar193`.** In a WILDCARD-IMPORT **clone** of a
> package subroutine, a direct name argument (`ref_obj`) of a method call
> written on a receiver whose binding is an **`array_var`** does not take the
> receiver: it takes a fresh copy of that array's own **ELEMENT VARIABLE**,
> **renamed after the argument**, left at the array declaration's span and
> parented at the call. At HOME the argument keeps its ordinary binding.

**THE PRODUCER, read rather than inferred.** `method_func_call::DeepClone`
(`~/git-repos/UHDM/templates/clone_tree.cpp:119-186`), which
`CompileHelper::importPackage` runs over every imported subroutine listing:

```cpp
if (parent->UhdmType() == uhdmhier_path) {
  hier_path* phier = (hier_path*)parent;
  any* last = phier->Path_elems()->back();          // THE RECEIVER
  if (ref_obj* last_ref = any_cast<ref_obj*>(last)) {
    if (const any* actual = last_ref->Actual_group()) {
      if (ref_obj* refarg = any_cast<ref_obj*>(arg)) {
        bool override = false;
        if (const any* act = refarg->Actual_group()) {
          if (act->VpiName() == obj->VpiName()) override = true;
        } else override = true;
        if (override) {
          if (actual->UhdmType() == uhdmarray_var) {          // <- THIS LAW
            array_var* arr = (array_var*)actual;
            if (arr->Variables() && !arr->Variables()->empty()) {
              variables* var = arr->Variables()->front();
              if (variables* varclone = (variables*)clone_tree(var, context)) {
                varclone->VpiName(obj->VpiName());
                varclone->VpiParent(const_cast<any*>(obj->VpiParent()));
                actual = varclone;
                elaboratorContext->m_elaborator.pushVar(varclone);
                pushedVar = varclone;
              }
            }
          }
          refarg->Actual_group((any*)actual);      // <- § 184 in every other case
        }
      }
    }
  }
}
```

So **a STRING (or any non-array) receiver hands the argument the RECEIVER —
that is § `cloneBuiltinMethodArgBindsReceiver184`, landed at `b71d5feb`,
unchanged and untouched here — and an ARRAY receiver hands it a renamed clone
of the array's element variable.** § 184's README called that other object R2
and fenced it out deliberately; r10v184 widened R2 to string arrays and queues.
This pass is R2, and the decode says the two are one block, not two families.

Every measured field of the head follows from those six lines:

| field | producer | measured |
|---|---|---|
| kind | `clone_tree(arr->Variables()->front())` | `int_var` for `int visited[uvm_phase]`, `class_var` for `uvm_reg regs[$]`, `string_var` for `string skein[3]` |
| span | `clone_tree` copies it | `1896:9-1896:16` = `visited`'s own name span; `2134:13-2134:17` = `regs`'s |
| typespec | `clone_tree` deep-copies it | `ref_typespec -> int_typespec @1896:5-1896:8` — the `int` keyword of the array declaration |
| name | `varclone->VpiName(obj->VpiName())` | `succ`, `this`, `gauge193` — the ARGUMENT's |
| parent | `varclone->VpiParent(obj->VpiParent())` | the **HOME** call `method_func_call (exists) @1907:22 #15086`, which is why the mint's chain reads `uvm_pkg` while its only referrer sits in `adpcm_pkg` |
| how many | one `clone_tree` per clone listing | golden has 4 `int_var(succ)` and 6 `class_var(this)` mints in SeqDriver — 5 keys × the clone's two listings |

**`ElaboratorListener::bindAny` is NOT the producer here**, and this pass says so
explicitly because § 184's own write-up names it: `bindAny`
(`ElaboratorListener.cpp:899`) dereferences a `ref_obj` hit to
`r->Actual_group()`, which can only ever return an object that already exists.
It cannot mint. The mint is `clone_tree`'s, and the head object's high UhdmId
(`197528`, against the home call's `15086`) is the arithmetic of that.

### THE CORPUS POPULATION, read off the two pristine databases (`ct193arg mfc`)

Of the **26** method calls written on a receiver bound to an `array_var` that
carry arguments in the two clone listings, **10 argument cells** mint in golden
and **16 do not**, and the split is the producer's `any_cast<ref_obj*>(arg)`
alone:

| listing ×2 | subroutine | call | golden | ours pristine | ours patched |
|---|---|---|---|---|---|
| clone | `uvm_phase::sync` | `visited.exists(succ)` @1907:22 | `int_var(succ)@1896:9` MINT | `ref_var(succ)@1906:34` | **golden's** |
| clone | `uvm_phase::unsync` | `visited.exists(succ)` @1955:22 | `int_var(succ)@1946:9` MINT | `ref_var(succ)@1954:34` | **golden's** |
| clone | `uvm_reg_map::do_print` | `regs[j].get_address(this)` @2155:132 | `class_var(this)@2134:13` MINT | **BARE** | **golden's** |
| clone | `uvm_reg_map::do_print` | `mems[j].get_address(0,this)` @2160:132 | `class_var(this)@2136:13` MINT | **BARE** | **golden's** |
| clone | `uvm_reg_map::do_print` | `vregs[j].get_address(0,this)` @2164:136 | `class_var(this)@2135:13` MINT | **BARE** | **golden's** |
| clone | `uvm_root::m_do_config_settings` ×3, `m_do_factory_settings` ×2, `m_process_config` ×2 | `args[i].substr(1, len-1)` etc. | **BARE** (`constant`/`operation` arguments) | BARE | **BARE** |
| clone | `uvm_reg_field::do_write` | `fields[i].get_access(rw.local_map)` @1496:23 | **BARE** (a `hier_path` argument) | BARE | **BARE** |
| HOME `uvm_pkg/DEF` | all of the above | **BARE** | BARE | **BARE** |
| HOME `uvm_pkg/ELAB` | `visited.exists(succ)` | `class_var(succ)@1906:34` (the foreach fixup's) | the same | **the same** |

**Three facts the corpus itself states, with no rule of ours:**

* the law is **NOT about built-in methods** — six of the ten cells are
  `get_address`, a USER-DEFINED class method;
* the law is **NOT about associative arrays** — six of the ten are QUEUES
  (`uvm_reg regs[$]`, `uvm_mem mems[$]`, `uvm_vreg vregs[$]`) reached through a
  `bit_select`, which `any_cast<ref_obj*>` accepts because `bit_select` IS-A
  `ref_obj`, and which § 184's recorder's exact-`UhdmType` receiver filter is
  what keeps out of THAT law;
* it fires at **argument 0 and argument 1** alike, and never on an argument
  that is not a `ref_obj`.

---

## 3. WHAT SHIPPED

Two files, one law, one drain.

* `include/UhdmExporter.h` — the law in full, the set `cloneArrayArgMint193`
  (audit only) and the two declarations.
* `src/UhdmExporter.cpp` —
  * `mintArrayElemVar193(src, name, parent)`: the producer's own
    `<kind>::DeepClone` first half verbatim — make the same UHDM variable class,
    `*clone = *src`, restore the UhdmId — so every scalar field
    `variables::Compare` reads (VpiArrayMember, VpiSigned, VpiAutomatic,
    VpiAllocScheme, VpiConstantVariable, VpiIsRandomized, VpiRandType,
    VpiStructUnionMember, VpiScalar, VpiVisibility, VpiVector) and every field
    `expr::Compare` reads (VpiDecompile, VpiSize) travels with the assignment,
    and so does the span. The second half — `DeepCopy` re-cloning the typespec —
    is replaced by a FRESH `ref_typespec` of our own that SHARES the element's
    actual typespec: no generated `Compare` reads `VpiParent` (RESUME §9), so a
    shared leaf and a cloned leaf are the same object to the judge, and cloning
    it would drag a whole `class_defn` behind a `class_typespec` for nothing.
    The stale inherited `VpiFullName` is cleared so the dump SYNTHESISES the one
    it prints, exactly as it does for golden's mint. Sixteen variable kinds are
    covered; `array_var`, `packed_array_var`, `var_bit`, `ref_var`, `gen_var`
    and `virtual_interface_var` are refused, which costs a STILL-WRONG at worst
    and can never cost an AWAY.
  * `drainCloneArrayRecvArgMint193()`: ONE pass over the arena's `hier_path`s.
    The listing gate is § 16's registry `pkgImportCloneTfs16` of WILDCARD-import
    clone subroutines — the same window § 9, § 10 and § 184 bind in and which is
    populated for nothing else — reached by a `VpiParent` walk that STOPS at the
    first listing root, so a home body can never be mistaken for a clone. The
    receiver is `Path_elems[i-1]`, the element written before the call, exactly
    as the producer reads `Path_elems()->back()`.
  * the call site: **immediately BEFORE `drainCloneMfcArgRecv184()`**, which
    keeps § 184 dead last and its pool untouched. An argument § 184 has already
    claimed is skipped here outright, so the two halves of the one producer can
    never both write a cell — the skip is written down rather than argued, and
    the two sets are disjoint in the corpus and in every arm.

**The `pushVar` half** is the producer's own: it pushes the mint into the
elaborator's scope and pops it only after the `With()` clause, so every LATER
reference of that NAME under the SAME call resolves to the mint. Arm A's
`skein193[0].substr(gauge193, gauge193 + 1)` is the minimal reproducer and
golden gives BOTH `gauge193` references the same `string_var` mint. Corpus
incidence: **ZERO** — the four moved corpus databases are byte-identical
(`0f90d144a575`, `ec361b2b9f92`, `c7d27b71e110`) between the cut without this
half and the cut with it.

---

## 4. THE GOLDEN GRID — four arms, one real Surelog golden each, both views

Every arm is CALIBRATED golden-vs-golden-vs-golden first (every column 0 but
UNTOUCHED). `GRID.r10uvm193.txt` carries the full output.

| arm | view | UNTOUCHED | TOWARD | AWAY | MOVED-WRONG | STILL-WRONG | ONLY-OURS-MOVED |
|---|---|---|---|---|---|---|---|
| A `g193_a_recvkind.sv` | def | 199 | **6** | **0** | **0** | 6 | **0** |
| A | elab | 246 | **6** | **0** | **0** | 10 | **0** |
| B `g193_b_method.sv` | def | 225 | **10** | **0** | **0** | 1 | **0** |
| B | elab | 301 | **10** | **0** | **0** | 29 | **0** |
| C `g193_c_argface.sv` | def | 345 | **18** | **0** | **0** | 1 | **0** |
| C | elab | 453 | **18** | **0** | **0** | 19 | **0** |
| D `g193_d_propfence.sv` | def | 61 | **2** | **0** | **0** | 0 | **0** |
| D | elab | 77 | **2** | **0** | **0** | 0 | **0** |

Arm C's DEF view goes `uhdm-cmp` **rc=255 (58 lines, one head) → rc=0**.

### Arm A `g193_a_recvkind.sv` — the RECEIVER-KIND axis

| cell | receiver | golden's clone answer | ours pristine | ours patched |
|---|---|---|---|---|
| A1 | `int bag193[int]` ASSOCIATIVE | `int_var(kink193)` MINT at `bag193`'s span | its own declaration | **golden's** |
| A2 | `int rope193[$]` QUEUE | (statement position, see arm B) | — | — |
| A5 | `string skein193[3]` element | `string_var(gauge193)` MINT at `skein193`'s span | `int_var(gauge193)`, its own declaration | **golden's** |
| A5′ | the SAME name inside `gauge193 + 1` | the SAME mint (`pushVar`) | its own declaration | **golden's** |
| A6 | `string cable193` PLAIN STRING | **the RECEIVER** (§ 184) | the receiver | **the receiver — UNMOVED** |
| A7 | a PACKAGE-scope associative array | its own declaration | the same | **the same** |
| Skiff193 | the EXPLICIT-import copy | mints | does not | does not (**R1**) |

### Arm B `g193_b_method.sv` — the METHOD axis

`exists` (built-in, associative), `delete` (built-in, statement position),
`num`/`size` (no argument at all — nothing to mint), `first`/`next` (a REF
argument), `find_index with` (an ITERATOR, not a `Tf_call_args` name), a
USER-DEFINED method on a QUEUE ELEMENT at argument 0 AND argument 1 (the
corpus's own `get_address` shape), the SAME user method on a plain class HANDLE
(nothing moves), and a built-in STRING method on a plain string (§ 184's cell,
which keeps the receiver). **TOWARD 10 / AWAY 0 / MOVED-WRONG 0** in both views:
the method genuinely does not matter, and the non-array receivers do not move.

### Arm C `g193_c_argface.sv` — the ARGUMENT-FACE and DECLARING-SCOPE axis

A direct name that is a function-level LOCAL, a FORMAL, a CLASS PROPERTY, a
PACKAGE variable, a BLOCK LOCAL, a FOREACH INDEX and the subroutine's own RETURN
NAME all take the mint; a CONSTANT, an OPERATION and a DOTTED (`hier_path`)
argument are all refused, exactly as the corpus's sixteen non-minting cells are;
a SELECTED (`bit_select`) argument is reached; two names in one call both mint.
**TOWARD 18 / AWAY 0 / MOVED-WRONG 0** in both views.

### Arm D `g193_d_propfence.sv` — the CLASS-PROPERTY RECEIVER FENCE

Split out of arm A because **Surelog itself** reports
`[ERR:UH0725] Unresolved hierarchical reference "m_hoard193.exists"` in the
ELABORATED view of a class-property array receiver in an OUT-OF-BODY method —
which IS the fence, stated by the producer rather than by a rule of ours:
`ElaboratorListener::enterTask_func` collects a class's `Variables()` only when
the task_func's `VpiParent` is a `class_defn`, and an out-of-body method hoisted
into the package listing has a PACKAGE parent, so the receiver never binds,
there is no `array_var` to read, and golden hands the argument nothing. D2 is
the control: the same out-of-body method with a SUBROUTINE-LOCAL array mints
normally (**TOWARD 2**), so the fence is about the receiver's DECLARING SCOPE
and not about the listing.

---

## 5. THE REGRESSION THE ARMS CAUGHT — reachability is not containment

The first cut of the `pushVar` half walked the later arguments' subtrees by
descending EVERY `GetByVpiType` edge, excluding only the immediate `VpiParent`.
That is not a subtree walk: a `variables` carries `vpiInstance` to its PACKAGE,
so following the argument's `vpiActual` to its own declaration and then that
declaration's edges escapes into the whole design. Arm A convicted it:

```
AWAY package:Quay193/ELAB | a5_strelem193 | NAME | CALLARG | 81:31 | gauge193
AWAY package:Quay193/ELAB | a5_strelem193 | NAME | CALLARG | 81:41 | gauge193
AWAY package:Quay193/ELAB | a5_strelem193 | NAME | PLAIN   | 73:5  | gauge193
    pris = act=int_var(gauge193)@72:12      gold = act=int_var(gauge193)@72:12
    pat  = act=string_var(gauge193)@71:12 MINT
```

Three references in the **HOME** `Quay193/ELAB` listing — including
`gauge193 = 1;` at 73:5, which is not under any call at all — were bound to a
mint made for the CLONE. The fix is one line: descend only where
`e->VpiParent() == n`, which is the sound definition of "inside". After it,
arm A reads **TOWARD 6 / AWAY 0** in both views.

### A second measurement worth carrying: the arms' ELAB view already mints

Under `-elabuhdm` our PRISTINE binary already produces some of these mints,
because UHDM's own elaborator re-clones the design and runs the very producer
this law models (arm D elab: golden 9 mints, pristine 7, patched 9, and the
patched multiset of REFERRERS equals golden's). **The corpus rows do not use
that flag**, which is why the corpus pristine has ZERO mints. This is also why a
census keyed on the MINT's OWN LISTING is unsound and this pass's is keyed on
the REFERENCE — see §7 and the header of `ct193arg.cpp`.

---

## 6. THE A-PRIORI PREDICTION (over all 956 surelog + 1358 u2r databases)

`predict193.sh` replays a COMPLETED PRISTINE sweep workdir: for every row it
reads the row's OWN golden out of the row's `cmds.txt` (never guessed) and asks
`ct193arg pred` the law's question of that pair alone — *is there an argument of
a method call written on a receiver where GOLDEN's `vpiActual` is a MINT and the
PRISTINE database's is not?* A row with no such key cannot move. The predicate
is a SUPERSET of the shipped gate (a database cannot say whether a listing is a
WILDCARD-import clone or an EXPLICIT-import copy, and it asks nothing about the
receiver's kind or the `override` test), so it can OVER-name and never
under-name.

```
PREDICT default/MiniAmiq-544c7f61   cells=10
PREDICT default/SeqDriver-32af76aa  cells=10
PREDICT testflags/MiniAmiq-544c7f61 cells=10
PREDICT testflags/SeqDriver-32af76aa cells=10
LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4 CELLS=40
```

Every row that produced a pristine database was processed and every one had its
golden (`NOGOLDEN=0`), so the prediction covers the whole comparable population.
`byteverify.sh SELFCHECK=1` on the accepted patched sweep then reported
**MOVERS 4 / 956 — precisely those four and no others** (SELFCHECK 955/956), and
**0 / 1358** on uhdm2rtlil. `Scoreboard/default` — the documented svunit_pkg
`vpiTaskFunc` COIN (RESUME §9) — sat out this run; it DID land on an earlier
sweep of an earlier cut of the same law, and its path-normalised ORDER-BLIND
dump diff there was 0 content lines.

---

## 7. MOVER ATTRIBUTION, ORDER-BLIND AND NAMED

`attrib193.sh` dumps both databases, normalises the workdir out, strips `id:`
numbers, and diffs PLAIN and SORTED. All four movers: **144 order-blind content
lines**, **4 out and 140 in**, no `UNEXPECTED-MOVER`.

```
OUT (4 lines, the two wrong bindings × the clone's two listings)
  \_ref_var: (adpcm_pkg::uvm_phase::sync::succ),   line:1906:34
  \_ref_var: (adpcm_pkg::uvm_phase::unsync::succ), line:1954:34

IN (140 lines) — the ten mint objects and nothing else:
  \_int_var:   (…::uvm_phase::sync::visited.exists::succ)          ×2 listings
  \_int_var:   (…::uvm_phase::unsync::visited.exists::succ)        ×2
  \_class_var: (…::uvm_reg_map::do_print::regs[j].get_address::this)  ×2
  \_class_var: (…::uvm_reg_map::do_print::mems[j].get_address::this)  ×2
  \_class_var: (…::uvm_reg_map::do_print::vregs[j].get_address::this) ×2
  + their ref_typespecs, their |vpiParent: method_func_call lines,
    |vpiName:succ ×4, |vpiName:this ×6, |vpiSigned:1 ×4, and the SIX
    |vpiActual: markers that filled a previously BARE `this` argument.
```

Every mint's printed `vpiFullName` is SYNTHESISED from the parent chain
(`adpcm_pkg::uvm_phase::sync::visited.exists::succ`), which is why the stale
inherited one had to be cleared; golden's synthesises `uvm_pkg::…` because its
mint is parented at the HOME call. `VpiFullName` is read by no generated
`Compare` (RESUME §9) — see R3.

### The WIDE boundary

`bound193.sh` compiles EVERY `.sv`/`.v` under a copy of `tools/probe` with both
binaries in both views and diffs the dumps:
`LISTED=5160 FENCED_SKIPPED=0 PROCESSED=5160 MOVED=20 NO_OUTPUT_PAIRS=394
PROCESSED-ASSERT-OK`, no `ASYMMETRIC_OUTPUT`. Three groups:

1. **This pass's own four arms** (8 arm-views) — the grid above.
2. **The DECODED static-address false mover** (6 arm-views:
   `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
   `r10uvm185repro/grid185/g185_e_kinds.sv`). Their ENTIRE diff is constants
   whose `vpiDecompile`/`UINT` value shifts by exactly **8192** — two pages,
   because the binary grew; filtering those two patterns leaves **0 differing
   lines** in every one of the six, and `ct193arg cenall` on the same databases
   reports **0 changed reference rows**. Zero census movement is the tell
   (r10uvm191's R5).
3. **Three arms that hold this law's own cells** (6 arm-views), each re-run
   through `grid193.sh` against its OWN real Surelog golden:

   | arm | view | TOWARD | AWAY | MOVED-WRONG | ONLY-OURS-MOVED | head object |
   |---|---|---|---|---|---|---|
   | `r10uvm184repro/g184_b_kinds.sv` | def / elab | **4 / 4** | **0** | **0** | **0** | same on both binaries (146 / 154 lines, one head) |
   | `r10v184repro/gv184_d_recvmeth.sv` | def / elab | **4 / 4** | **0** | **0** | **0** | same (42 / 42, one head) |
   | `r10uvm39repro/t55b/dut.sv` | def / elab | **4 / 4** | **0** | **0** | **0** | same (20 / 20, one head) |

   `g184_b_kinds.sv` is § 184's own RECEIVER-KIND fence arm and is the place the
   MUST-STAY floor is scored in both columns at once:

   | cell, clone listing `Stanchion184` | golden | pristine | patched |
   |---|---|---|---|
   | `cable.substr(1,kink)` | `string_var(cable)@17:13` | `string_var(cable)@17:13` | **`string_var(cable)@17:13` — UNMOVED** |
   | `cable.getc(kink)` | `string_var(cable)@17:13` | `string_var(cable)@17:13` | **`string_var(cable)@17:13` — UNMOVED** |
   | `tackle.exists(kink)` | `int_var(kink)@20:13` MINT | `int_var(kink)@23:13` | **golden's** |
   | `rope.find_index(lot)` | `int_var(lot)@47:15` MINT | `array_var(lot)@48:15` | **golden's** |

   `r10uvm39repro/t55b/dut.sv`'s CELL D (`parr[i4].one56(f4)`, an indexed
   receiver) and CELL E (`loc5.exists(k5)`) are the same two shapes; that arm's
   own comment called CELL E "the measured exception in the corpus
   (`visited.exists(succ)` keeps SELF)", and this pass supersedes that reading
   with its own golden. Every § 139 / § 186 / § 189 / § 191 / uvm180-183 / 185 /
   187 / 188 / 190 / uvm82-91 / buvm3-15 / sd8-12 arm is byte-identical.

---

## 8. GATES

* build `-j 2`, md5 taken separately: pristine
  `d5a59dbbef4563591865e0da88492e57`, patched
  `95ea482622bc432f0f2460e6739a6ad6`, both frozen `chmod 555` BEFORE any sweep,
  and every `cmds.txt` audited by BINARY PATH (1523 of 1573 surelog and 1458 of
  1462 uhdm2rtlil `cmds.txt` name the frozen patched binary in the patched
  workdirs — the rest are golden-cache-hit rows with no slang line — and
  **zero** name the pristine binary or the main-tree build);
* goldens **23 PASS / 0 FAIL** with `SLANG_UHDM` exported explicitly to the
  patched binary, and **0 PASS / 23 FAIL** with `SLANG_UHDM=/bin/false`
  (negative control); the pristine binary is 23/0 too;
* uhdm2rtlil `679 / 50 / 2` in BOTH modes, `ct8rows` **0 differing rows**
  against the committed `results/gate_uhdm2rtlil.csv` IN THIS WORKTREE and
  against this pass's own pristine sweep, status AND dump column, both modes;
* surelog `--mode both` `937/567/48/19/10/3/2/1/1`, `ct8rows` **0 differing rows
  over 1588** against the committed `results/golden_surelog.csv` IN THIS
  WORKTREE and against this pass's own pristine sweep. **NO ROW CONVERTED**;
  `results/*.csv` were read only;
* `byteverify.sh SELFCHECK=1` **4/956** and **0/1358**, every mover named and
  attributed above, PREDICTED BY NAME from the pristine databases first;
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (uhdm2rtlil);
  `ctcan2` PASS with `EXPECT_UNKNOWN=1` / `EXPECT_UNKNOWN=6`;
  `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* protected databases by name: `InterfaceModPort`, `BlackParrotComplex` and
  `YosysOldOr` byte-identical in both modes; `SVSwitch` pinned `4842211c4030`;
  `YosysVerx` pinned `6ccda350c24a`.

---

## 9. RESIDUES AND R0

* **R0 — the next head.** SeqDriver ×2 and MiniAmiq ×2, **29 cmp lines, ONE
  `^LHS:`**, the SAME object in all four row-modes, and it is a `LHS: <null>`
  mirror — an object OURS has that golden does not:
  `ref_var (uvm_pkg::uvm_root::run_test::phase_runner_proc) @411:11-411:28`
  under `begin (uvm_pkg::uvm_root::run_test) @403:3-403:51`, its
  `ref_typespec` resolving to `unsupported_typespec (process) @411:3-411:10`.
  The source is `process phase_runner_proc;` (uvm-1.2 `uvm_root.svh:411`), a
  `process`-typed local inside `uvm_root::run_test`: golden does not list it as
  a variable of that `begin` and we do. A LISTING law, not a binding one, and
  the first head of this family in a long while. `head_pat_*.cmp`. (SimpleUVM's
  own 664681-line cmp log is a depth artifact and is deliberately not carried
  here.)
* **R1 — the EXPLICIT-import copy.** `import P::fn;` produces a copy that golden
  mints in exactly like the wildcard clone (arm A, `package:Skiff193`, four
  cells), and this law cannot fire there because its listing gate is § 16's
  wildcard-only registry `pkgImportCloneTfs16`. **Corpus incidence: zero** — the
  superset predictor, which cannot tell the two apart, names no such cell in
  956 + 1358 databases. (r10uvm184's R1, r10uvm186's, r10uvm189's and
  r10uvm191's are the same face for their own laws.)
* **R2 — the six refused variable kinds.** `mintArrayElemVar193` declines
  `array_var`, `packed_array_var`, `var_bit`, `ref_var`, `gen_var` and
  `virtual_interface_var`, whose `*clone = *src` would SHARE an owned vector.
  An array of arrays therefore keeps its own declaration where golden mints.
  Corpus incidence: zero (the corpus needs `int_var` and `class_var`); arm
  incidence: zero. A STILL-WRONG at worst, never an AWAY.
* **R3 — the mint's LISTING PREFIX in the dump.** Golden parents its mint at the
  HOME listing's call (`obj->VpiParent()`, the ORIGINAL argument's parent), so
  the dump synthesises `uvm_pkg::uvm_phase::sync::visited.exists::succ`; we
  parent ours at the CLONE's own call and synthesise
  `adpcm_pkg::…`. `VpiFullName` and `VpiParent` are read by NO generated
  `Compare` (RESUME §9), so the axis is worth nothing to the judge, and buying
  it would mean finding the home listing's twin of every call. Same shape as
  r10uvm191's R3 and r10uvm186's R2.
* **R4 — the arms' `-elabuhdm` view already mints, the corpus rows do not.**
  Under that flag UHDM's own elaborator re-clones the design and runs this very
  producer, so an arm's ELAB column measures a partly-converged starting point
  (arm D: golden 9 mints, pristine 7, patched 9). Corpus rows carry no
  `-elabuhdm`, which is why their pristine mint count is 0. Any future pass
  reading an arm's ELAB column has to know this.
* **R5 — the static-address false mover, again, and one page wider.**
  `typedef int ka_str_t[int];` (r10buvm22's `g22.sv:70`) makes our emitter write
  a `constant` whose `vpiSize:64` `UINT` value is a raw static ADDRESS —
  `22634233` pristine, `22642425` patched, exactly **8192** apart this time.
  Present in three probe arms and in ZERO corpus rows; identical on both
  binaries in every way that is not the address. Not this pass's, but it is a
  latent nondeterminism in any pass that changes the binary's size.
* **R6 — § 184's statement-position boundary stands** as r10v184 recorded it
  (its residue 2): golden's answer for a built-in STRING method call in
  STATEMENT position is the argument's own declaration, while § 184's written
  law claims the receiver. Untouched here — this law's gate is the receiver's
  `array_var` binding and never reaches that arm — and still worth recording
  before anyone extends § 184.

---

## 10. REPRODUCING

```sh
g++ -O2 -std=c++17 ct193arg.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o ct193arg

./ct193arg own    <golden.uhdm> <ours.uhdm>          # decode the judge, both sides
./ct193arg skip   <golden.uhdm> <ours.uhdm> [rounds] # the heads BEHIND the first
./ct193arg mfc    <db.uhdm> [substr]                 # one row per receiver-method call
./ct193arg mint   <db.uhdm>                          # every mint, every referrer
./ct193arg at     <db.uhdm> <line>                   # what Surelog wrote at a declaration
./ct193arg cenall <db.uhdm>                          # the reference census + mint/orphan counts
./ct193arg pred   <golden.uhdm> <ours.uhdm>          # the movable cells of this pair

CT193=./ct193arg ./grid193.sh g193_a_recvkind.sv  <pris.bin> <pat.bin> <workdir>
CT193=./ct193arg ./grid193.sh g193_b_method.sv    <pris.bin> <pat.bin> <workdir>
CT193=./ct193arg ./grid193.sh g193_c_argface.sv   <pris.bin> <pat.bin> <workdir>
CT193=./ct193arg ./grid193.sh g193_d_propfence.sv <pris.bin> <pat.bin> <workdir>
python3 score193.py <wd>/cen.g.<view>.txt <wd>/cen.a.<view>.txt <wd>/cen.b.<view>.txt [-v]

CT193=./ct193arg ./predict193.sh <PRISTINE workdir> <out.txt>
CT193=./ct193arg ./cenall193.sh  <pris wd> <pat wd> <outdir> SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg
./attrib193.sh <pris wd> <pat wd> <outdir> 'SeqDriver|MiniAmiq|Scoreboard'
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=/tmp/r10uvm193_bound ./bound193.sh
./ct8rows.sh <baseline.csv> <fresh.csv>
SELFCHECK=1 ./byteverify.sh <patched wd> <pristine wd>
./rowheads.sh <workdir> <outdir> SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen
./canaries.sh <fresh.csv> <baseline.csv>;  EXPECT_UNKNOWN=<n> ./ctcan2.sh <baseline.csv> <fresh.csv>
bash canaudit.sh canaries.sh ctcan2.sh
```

Recorded outputs: `HEADS.r10uvm193.txt`, `GRID.r10uvm193.txt`,
`CENSUS.r10uvm193.txt`, `PREDICT.r10uvm193.txt`, `MOVERS.r10uvm193.txt`,
`BOUNDARY.r10uvm193.txt`, `GATES.r10uvm193.txt`, and the per-row
`head_pris_*.cmp` / `head_pat_*.cmp`.
