# r10sd10 — the SeqDriver head: § classTdLocalVarKindFollowsCompileOrder10

**THE SeqDriver HEAD IS CLEARED, ON BOTH ROWS.** `default/SeqDriver` and
`testflags/SeqDriver` go **56 cmp lines → 38** and the head OBJECT is a
different object entirely — the `class_var` / `struct_var` disagreement on
`uvm_resource_types::access_t access_record` at `uvm_resource.svh:483:34` is
gone, together with the other nine variable-kind rows of its family. The rows
do **not** yet reach `PASS_CMP`: the new head is a TYPESPEC defect on the very
next declaration of the very same typedef family, and it is reported below as
R0 rather than dressed up.

| | |
|---|---|
| BASE | `5425d65` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd10` (delivered), `/tmp/wt_r10sd10pris` (pristine control, `git status --porcelain` = 0) |
| delivered binary | md5 `dc7d420bfb77f0c730e9774d94baec1e` |
| pristine binary | md5 `34a24bb3eea7d84ccd6175c0a710f0bc` |
| production files | `src/EmitHelpers.h`, `src/TaskFuncEmit.cpp`, `src/StmtEmit.cpp`, `src/TypeEmit.cpp`, `include/UhdmExporter.h` |
| probe files | `tools/probe/r10sd10repro/` |

---

## 1. THE LAW

> **§ classTdLocalVarKindFollowsCompileOrder10** — a SUBROUTINE-scope
> declaration (a body local, a block-item local, or the RETURN VARIABLE) whose
> declared type names a typedef that lives inside a **CLASS** takes the object
> class that typedef's typespec implies **only if Surelog had already compiled
> the owning class when it compiled this declaration**. Otherwise it falls
> back, and WHICH fallback is decided by how the type was WRITTEN:
> **`Owner::td` (a ScopedName) → a bare `class_var`; `td` (a bare name) → a
> bare `ref_var`.** In both fallbacks the name, full name, span, parent and
> `ref_typespec` — and that ref's `vpiActual`, the real typespec, patched in
> afterwards by `needLateTypedefBinding` — are IDENTICAL to the resolved arm.
> **Only the object class changes.**

### 1.1 WHICH SIDE IS WHICH — read off the head, not off the shorthand

sd8's note reads "class_var vs struct_var(access_record)". **LHS is always
golden**, and the head confirms it literally: golden emits `class_var`, we emit
`struct_var`, and *every other line of the object is byte-equal*, including the
`vpiActual` `struct_typespec (access_t)@126:11-132:4` that both sides bind.

```
LHS:  class_var:  (uvm_pkg::uvm_resource_base::record_read_access::access_record), line:483:34
RHS:  struct_var: (uvm_pkg::uvm_resource_base::record_read_access::access_record), line:483:34
        both:  |vpiParent \_begin: (…::record_read_access) @483:5
               |vpiTypespec \_ref_typespec → \_struct_typespec: (access_t) @126:11-132:4
               |vpiName:access_record  |vpiFullName:uvm_pkg::…::access_record
```

So the question is NOT "is `access_t` a struct" (it is, and both sides know it)
— it is "what object class did Surelog mint before it knew".

### 1.2 WHY, read off Surelog and then measured

`CompileHelper::compileVariable`'s **`paClass_scope`** arm
(`src/DesignCompile/CompileType.cpp` ~553) resolves the owner with THREE
lookups and no more —

```
getClassDefinition(<written scope name>)
getClassDefinition(<declaring component's own full name> :: <scope name>)
getClassDefinition(<declaring component's PARENT scope's name> :: <scope name>)
```

— then asks the owner's `DataType` for a typespec and ends
`if (var == nullptr) var = s.MakeClass_var();`. The **bare-name** arm
(same file, ~340) runs the same question through `component->getDataType` and
ends its own chain at `MakeRef_var`. A class's typedefs have a typespec only
once that class's `CompileClass` has run, and `CompileDesign::compile` runs its
passes in this order:

> packages (strict order) → **FILE CONTENTS** → modules → programs → **CLASSES, LAST**

iterating `ClassNameClassDefinitionMultiMap`, a
`std::map<std::string, …, StringViewCompare>` whose comparator is literally
`a < b`. **Class bodies are therefore compiled in LEXICOGRAPHIC ORDER OF THEIR
FULLY-QUALIFIED NAMES.** `uvm_pkg::uvm_resource_base` < `uvm_pkg::uvm_resource_types`,
so `access_t` has no typespec when `record_read_access` is compiled.

### 1.3 THE GRID — golden's rule, cell by cell

`grid10/`, nine cells, each run on BOTH binaries by `ct10grid.sh` and scored on
the whole-design cmp verdict, the dump-content count AND the variable-KIND
table (`<uhdm class> <fullname> @line:col`) golden-vs-ours.

| axis | cell | golden |
|---|---|---|
| **KIND is irrelevant** | `g2` — struct / enum / int / logic / bit / string / real / time / class-handle, all scoped, owner sorts AFTER | **all nine `class_var`** |
| the same kinds, owner sorts BEFORE | `g1` | each kind's own var class |
| **SITE is irrelevant** | `g2` function local, task local, begin-block local | all three `class_var` |
| **RETURN variable** | `g7` `r_late_struct` / `r_late_cls` | `class_var` (ours `struct_var` / `ref_var`) |
| **SOURCE ORDER IS IRRELEVANT** | `g8` — BOTH owners written before both users | `auser`+`zholder` → `class_var`; `zuser`+`ahold` → `struct_var` |
| **OUT-OF-BODY body** | `g6` `v_ext_bare` / `v_ext_scoped` / `v_ext_sibling` | `ref_var` / `class_var` / `class_var`, against `struct_var` for all three INLINE |
| **REACH: another package** | `g4` `v_imported` | `class_var` |
| REACH: own typedef, class scope | `g4` `v_self`, `g6` `f_inline_*` | resolved |
| REACH: class NESTED in the declaring class | `g4` `v_inner` | `class_var` (its key is the declaring key + a suffix) |
| **REACH: `$unit` scope is NOT NAMEABLE** | `g9` `v_unit_sibling`, `v_unit_self_scoped` | **`class_var` even though the owner IS compiled** |
| the same shape at MODULE scope | `g9` `v_mod_sibling` | `struct_var` (the lookup spells `work@top::mholder`) |
| BARE spelling is LEXICAL, not key-based | `g9` `v_unit_self_bare` | `struct_var` |
| BARE + owner not compiled | `g5` `v_inherited_bare` / `_enum` / `_cls` | **`ref_var`, all three** |
| **NEGATIVE: package scope** | `g3` `c_pkg_scope` (`qy::qrec_t`) | `struct_var` both sides, unmoved |
| context: module / `initial` local | `g3` `init_late` / `init_early` | `class_var` (compiled before every class) |

**The `$unit` cell `g9` is the one that made the predicate honest.** Before it,
question (3) REACH was strictly implied by question (4) ORDER and the code was
carrying a redundant term. `g9` shows it is not: at `$unit` scope a class is
registered as `work@<name>`, a spelling none of the three lookups produces, so
a `$unit` sibling — and a `$unit` class's OWN typedef, self-qualified — is a
`class_var` **even though the owner is compiled**. The first delivered binary
had that arm WRONG (it answered `struct_var`); it was found by writing the cell,
fixed, and re-gated from scratch.

---

## 2. STATED GATE == CODE GATE

**STATED**, as one predicate (`src/EmitHelpers.h`, `classTdLocalVarKind10`) and
three call sites, and nowhere else:

1. **(1) OWNER** — the declared type is a `TypeAlias` whose home scope is a
   `ClassType`. Anything else returns `Resolved` and nothing changes.
2. **(2) BODY FORM** — an OUT-OF-BODY (`extern`) definition is compiled in the
   FileContent pass, before any class at all, so it resolves nothing.
   `outOfBlockIndex != 0`, the same test `src/ExprEmit.cpp:1697` already uses.
3. **(3) REACH** (scoped spelling only) — the owner must be the declaring class
   or a SIBLING in its parent scope, **and that parent scope must be
   NAMEABLE**: a Package, a ClassType or an InstanceBody. `$unit` is not.
4. **(4) ORDER** — `owner.name < declaringClass.name`, the leaf comparison,
   valid because two siblings' map keys differ only there; the declaring class's
   own typedef is always compiled first.

**SITES** — three, all of them a `switch` over the same enum, all of them
`if (!v)` so no existing arm is preempted:

* `src/TaskFuncEmit.cpp` ~4991 — the SUBROUTINE-BODY local (**this replaces the
  `onDemandClassTypedefs` proxy**, deleted here and in `src/TypeEmit.cpp` /
  `include/UhdmExporter.h`).
* `src/StmtEmit.cpp` ~1330 — the BLOCK-ITEM local.
* `src/TaskFuncEmit.cpp` ~3067 — the RETURN variable.

**CODE** — `git diff 5425d65 --numstat`: `src/EmitHelpers.h` **+186/−0**,
`src/TaskFuncEmit.cpp` **+53/−11**, `src/StmtEmit.cpp` **+19/−0**,
`src/TypeEmit.cpp` **+8/−7**, `include/UhdmExporter.h` **+0/−4**. Of the 266
inserted lines, **156 are comment or blank**; the executable change is
**110 lines**, of which 68 are the one predicate.

### 2.1 WHAT THE PROXY WAS, AND WHY IT WAS BOTH BLIND AND WRONG

The pristine tree already carried this law's *sentence* — `src/TypeEmit.cpp`'s
comment says, verbatim, "A CLASS-NESTED typedef referenced from a class that
sorts EARLIER by name (`uvm_resource_base` -> `uvm_resource_types::access_t`)".
What it did **not** carry was the law's *question*. Its gate was
`onDemandClassTypedefs`: "did OUR emission order have to build the owner's
typedefs on demand?"

* **BLIND** — we emit `uvm_resource_types` before `uvm_resource_base`, so the
  typedef was already registered, no on-demand build happened, and the head
  stayed `struct_var`. Our emission order is slang's; Surelog's is
  lexicographic. **The grid could not see this**: `g8`, written to refute
  source order, is answered correctly by BOTH binaries. Only the corpus
  exposed it.
* **WRONG** — it fired on the BARE spelling too, where golden's fallback is
  `ref_var` and not `class_var`: grid `g5` `v_inherited_bare`, pristine
  `class_var` against golden `ref_var`. That over-fire is fixed here.

### 2.2 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| (1) owner is a class-nested `TypeAlias` | **FIRES BOTH WAYS** | 166 corpus rows take it; `g3` `c_pkg_scope` and every non-alias local take the else and are byte-unchanged |
| (2) `outOfBlockIndex != 0` | **FIRES BOTH WAYS** | `uvm_component::m_set_cl_action` / `m_set_cl_sev` / `m_set_cl_verb` / `m_apply_verbosity_settings` on the corpus; `g6` scores both arms; boundary cell `qgrid4/qv13` moves on it |
| (3) REACH, sibling-or-self | **FIRES BOTH WAYS** | `g4` `v_imported` takes the reject arm; every corpus row takes the accept arm |
| (3) REACH, NAMEABLE scope | **never rejects on the corpus** | every corpus class is package-homed. PROVED, not assumed: the binary WITHOUT this guard and the binary WITH it produce **byte-identical databases** on `SeqDriver`, `SimpleUVM` and `BuildUVMPkg` (all three deterministic, md5s equal across the two builds) and an identical size and census on `Scoreboard`. `g9` is the guard's only coverage, and it is the cell that put it there |
| (4) ORDER, leaf-name compare | **FIRES BOTH WAYS** | `g8` both directions in one cell; on the corpus 10 `class_var` rows per design accept and the surrounding declarations reject |
| bare arm with no enclosing class | **UNEXERCISED, and deliberately inert** | a bare name cannot reach a class-nested typedef from a module or package scope; the arm returns `Resolved` rather than guess a fallback that was never measured |

The last row is carried and named for sd8 F4's reason: an unexercised guard
that goes unmentioned is how a stated gate stops being the code gate.

### 2.3 A LIMIT OF THE ORDER TEST, STATED

(4) compares LEAF NAMES and therefore only decides SIBLINGS; every other owner
is treated as "not compiled", which is the fallback direction. For the scoped
spelling that changes nothing — (3) already forces the fallback there. For the
bare spelling the only way to reach a non-sibling owner is INHERITANCE ACROSS
SCOPES, and this predicate does not reconstruct the two full keys. On this
corpus that case is `adpcm_pkg::…` inheriting from `uvm_pkg::…`, where the full
key relation (`adpcm_pkg` < `uvm_pkg`, so the base is compiled LATER) agrees
with the fallback anyway. Filed as residue R6.

---

## 3. THE MOVERS

### 3.1 Census-predict, made FIRST and from the ARTIFACT — `ct10pred` / `ct10scan.sh`

`ct10pred` joins every `variables` object of the two databases on
*(vpiFullName, line:col)* — total, since a declaration produces one variable at
one place — and buckets the CLASS disagreements FOUR ways, never netted:
`G_CLASSVAR` / `G_REFVAR` (golden's class, ours something else) and
`O_CLASSVAR` / `O_REFVAR` (the reverse, i.e. an over-fire of ours).

**Calibrated before use**: golden-vs-golden on `SeqDriver` = `shared=8592
same=8592`, every bucket **0**.

Run over every PRISTINE database of both corpora, before any delivered database
was compared:

| corpus | databases | accounted | with rows | G_CLASSVAR | G_REFVAR | O_CLASSVAR | O_REFVAR |
|---|---|---|---|---|---|---|---|
| surelog | **953** | 953 | **7** | **70** | 148 | 0 | 0 |
| uhdm2rtlil | **1358** | 1358 | **0** | 0 | 0 | 0 | 0 |

```
PREDICT default/BuildUVMPkg   default/Scoreboard   default/SeqDriver   default/SimpleUVM
        testflags/BuildUVMPkg testflags/SeqDriver  testflags/SimpleUVM
```

**Delivered score over the same 953**: the same 7 databases,
**G_CLASSVAR 70 → 0** and **G_REFVAR 148 → 52**; `O_CLASSVAR` and `O_REFVAR`
stay **0 → 0**, so the patch creates no new disagreement anywhere.
**166 census rows converted.**

`ct10pred`'s own limit is stated in its header and is why the delivered score is
part of the procedure: `G_REFVAR` is a SUPERSET — `ref_var` is also
§ aliasClassRefVar10's and § typeParamRetIsRefVar58's answer — so the number
predicts the CANDIDATE SET and the difference is the claim. The 52 residual
rows are named in §6.

**`ct10scan.sh` caught itself twice, and both are in its source as comments.**
Its first version scanned **687 of 1358** databases and printed a clean
`candidates=0`: one `$(( ))` syntax error, on a legitimately EMPTY join
(`[S] KINDS shared=0`), killed the whole loop. The accounting guard —
*every database found must be accounted for by exactly one of scanned /
no_golden / no_line* — is the only reason that was not reported as a clean scan,
and it is a hard error (exit 6) for that reason.

### 3.2 The MOVER RULE — size delta on every mover

`byteverify.sh`, both corpora, `SELFCHECK=1 SELFCHECK1=1`:

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 021 280 | 18 021 613 | **+333** |
| `testflags/SeqDriver` | 18 021 694 | 18 022 046 | **+352** |
| `default/Scoreboard` | 11 145 637 | 11 145 680 | **+43** |
| `default/SimpleUVM` | 11 141 435 | 11 141 475 | **+40** |
| `testflags/SimpleUVM` | 11 141 774 | 11 141 814 | **+40** |
| `default/BuildUVMPkg` | 11 105 834 | 11 105 918 | **+84** |
| `testflags/BuildUVMPkg` | 11 105 834 | 11 105 918 | **+84** |

All seven nonzero: **REAL movers** by the standing law, and they are **exactly
the seven predicted databases, name for name**. `testflags/Scoreboard` is
`SLANG_REJECT` at baseline (`use of undeclared identifier 'my_scoreboard'`,
verified in both CSVs), produces no database, and is a **SKIP** — never
agreement.

### 3.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct7shape.py` on `sed 1d`-stripped, workdir-path-normalised dumps.

| design | ADDED / REMOVED | shapes IMPROVED | shapes WORSENED | msdist pris → new |
|---|---|---|---|---|
| `SeqDriver` | 283 / 243 | **4** | **0** | 359 484 → **359 010 (−474)** |
| `SimpleUVM` | 101 / 101 | **3** | **0** | 140 145 → **139 971 (−174)** |
| `Scoreboard` | 101 / 101 | **3** | **0** | 130 447 → **130 273 (−174)** |
| `BuildUVMPkg` | 120 / 120 | **4** | **0** | 77 855 → **77 651 (−204)** |

**ZERO worsened shapes on all four designs** — the first pass in this SeqDriver
series with no shape cost at all (sd9 worsened `vpiClassDefn` and `vpiActual`
on `SeqDriver`; this pass IMPROVES `vpiActual` by 20). The transcription:

```
SeqDriver     ref_var +240/−12   class_var +23/−116   struct_var 0/−115   vpiActual +20/−0
SimpleUVM     ref_var  +78/−12   class_var +23/−52    struct_var 0/−37
Scoreboard    ref_var  +78/−12   class_var +23/−52    struct_var 0/−37
BuildUVMPkg   ref_var  +90/−10   class_var +30/−50    struct_var 0/−46   enum_var 0/−14
```

and every one of those shapes' DISTANCE TO GOLDEN falls: e.g. `SeqDriver`
`ref_var` 6156 → 5956, `class_var` 4082 → 3943, `struct_var` 183 → **68**.

### 3.4 The seven live UVM rows — head tuples on BOTH binaries

| row | pristine head | delivered head | cmp lines |
|---|---|---|---|
| `default/SeqDriver` | `class_var(access_record)@483:34` / `struct_var` | **`unsupported_typespec(uvm_resource_types::rsrc_q_t)@717:5` / `class_typespec(rsrc_q_t)@40:11`** | **56 → 38** |
| `testflags/SeqDriver` | same | **same new head** | **56 → 38** |
| `default/SimpleUVM` | `part_select: arb_sequence_q@681:23` both sides | **identical object** | 142 → 142 |
| `testflags/SimpleUVM` | same | identical | 142 → 142 |
| `default/Scoreboard` | same | identical | 142 → 142 |
| `default/BuildUVMPkg` | `struct_typespec(uvm_pkg::m_uvm_factory_type_pair_t)@11947:40` / `logic_typespec@11965:5` | identical | 94 → 94 |
| `testflags/BuildUVMPkg` | same | identical | 94 → 94 |

Every head `grep -c '^LHS:' == 1`. The other three designs' heads are reached
EARLIER by unrelated defects (a `part_select`, a package `struct_typespec`),
which is why 60 converted census rows there buy no head — measured, not assumed:
the two cmp logs differ only in the arena `id:` of the RHS objects.

---

## 4. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex | both worktrees `BASE 5425d65` grep-checked **=1**; both ` error:` count **0**; `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`dc7d420bfb77f0c730e9774d94baec1e`**, pristine **`34a24bb3eea7d84ccd6175c0a710f0bc`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | 679/50/2, `ct8rows` 0 rows | default **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, testflags **679/50/2**, BOTH binaries; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (testflags-filtered first — the 731-row trap) → **0 differing ROWS (0 row-sides)**; pristine-vs-committed → **0**; pristine-vs-delivered (both modes, 1462 rows) → **0** |
| **4 surelog** | 469/11 + 465/8, FAIL 25/23, DEFER 5/5, histograms unchanged, 0 rows | default **469 / 11 / 25 / 5 / 284**, testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM), BOTH binaries. All four dump histograms **identical** to committed (default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329). `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS** over 1588; pristine-vs-committed → **0** |
| **5 BYTE VERIFIER** | both corpora, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | surelog **7 / 953**, u2r **0 / 1358**; `PATH_SETS_IDENTICAL` both; SELFCHECK **952/953** and **1357/1358**; SELFCHECK1 **8** and **1** — arithmetic consistent (1 corruption + 7 real; 1 corruption + 0 real). The 7 are **exactly the predicted set** (§3.1), all with nonzero SIZE-DELTA (§3.2); per-shape movers are the transcription and nothing else (§3.3) |

`GOLDEN_DEFER` printed **`[UNSET]`** before the sweeps. All sweeps `--jobs 2`
with private `--out` / `--workdir`. **`SLANG_UHDM` pin verified by reading
`cmds.txt` exhaustively on all FOUR trees**: surelog 1573 cmds files /
**1523 `slang:` lines, 1523 name the right binary, 0 name any other**; u2r
1462 / **1458, 1458 / 0**. `results/*.csv` READ ONLY. No `git stash`. slang not
patched.

### 4.1 CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names 7 (the documented u2r-only names) — vs committed **and** vs this pass's pristine sweep |
| `canaries.sh` u2r | at baseline | **ok=8** vs committed (testflags-filtered), **ok=16** vs pristine (both modes), changed=0 absent=0 |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1`, baseline FIRST | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS**, vs committed and vs pristine |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6`, testflags-only CSV | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch` databases | **byte-identical** | all four, **both modes**, `cmp -s` **BYTE-IDENTICAL** between the two binaries |

### 4.2 BOUNDARIES — every prior grid RE-RUN on BOTH binaries

`ct10bound.sh`, 44 cells over `qgrid4` (13), `grid6` (6), `grid7` (6),
`grid7v` (3), `grid8` (6), `vgrid8` (3), `grid9` (7):
**IDENTICAL 43, MOVED 1, UNSCORABLE 0.**

The one mover is **`qgrid4/qv13_clstype_flat_oob`**, and it moves in this
pass's own direction and toward golden:

```
  t13_t l13;            <- a BARE own-typedef local in an OUT-OF-BODY method
  GOLDEN     ref_var  (p13::c13::f13::l13) @11:11
  PRISTINE   struct_var                      <- wrong
  DELIVERED  ref_var                          == GOLDEN
```

whole-cell dump content **56 → 44**. Every other cell of every other grid —
including all seven of sd9's `grid9`, sd8's `grid8`+`vgrid8` and the standing
counterexample `vgrid8/v1` — is **byte-identical between the two binaries**
after the workdir-path normalisation described below.

> **The first run of `ct10bound.sh` reported all 44 cells as MOVED.** uhdm-dump
> embeds the workdir path in every `file:` field and the two arms run in
> different directories by construction (Surelog synthesises `builtin.sv` into
> the cwd). That is the same trap that caught r10sd9's verifier; the
> normalisation, and the note, are now in the script.

**DETERMINISM.** `detcheck.sh` with the delivered binary on `g2`, `g4`, `g6`
and `g7`: **3 runs each, 1 distinct sha256, 0 NO_OUTPUT.**

---

## 5. REFUTATIONS

### 5.1 "a class-scope-qualified local is a class_var" — REFUTED at the first cell

The obvious reading of the head (`Cls::td` in a declaration ⇒ `class_var`) was
the first hypothesis and `g1` killed it in one Surelog run: `holder::srec_t
a_scoped_struct;` is a **`struct_var`** in golden, exactly what we already
emit. Six more single-variable cells (`c2`…`c11`) then produced the discriminator
by accident — two cells identical except for the DECLARING CLASS'S NAME gave
different answers — and `c12`/`g8` turned that into the refutation of source
order.

### 5.2 "the `virtual` keyword is the discriminator" — REFUTED

`c2` and `c3` (both `virtual class`) gave `class_var` and `c4`/`c5` (plain
`class`) gave `struct_var`, which is a perfectly convincing wrong answer.
`c6` (non-virtual, extends), `c7` (virtual, no extends) and `c8` (plain, no
extends) all gave `class_var` and dissolved it: what those three shared was a
declaring class named `base_c`, which sorts before `holder`.

### 5.3 "REACH is implied by ORDER" — REFUTED by `g9`, after the code already assumed it

The first delivered predicate computed `reached` and then never used it: any
owner it could call "compiled" was self-or-sibling and therefore reachable.
`g9` shows the hole — a `$unit` sibling, and a `$unit` class's own
self-qualified typedef, are **compiled and still not reachable**, because a
`$unit` class's map key is `work@<name>` and none of the three lookups ever
spells that. Measured on golden (`class_var` for both) against the same shape
at MODULE scope (`struct_var`), fixed, and re-gated from a clean rebuild.

### 5.4 "the fallback is always `class_var`" — REFUTED; the SPELLING decides

`g5` and `g6`: the BARE spelling's fallback is `ref_var`, for a struct typedef,
an enum typedef and a class-handle typedef alike. The pristine binary emitted
`class_var` there — a pre-existing OVER-FIRE of the proxy, fixed here, and the
reason the corpus has 96 `G_REFVAR` rows to convert on top of the 70
`G_CLASSVAR` ones.

### 5.5 `Scoreboard` IS NONDETERMINISTIC, ON BOTH BINARIES — and it nearly cost an attribution

Between the two delivered builds `default/Scoreboard`'s md5 changed while
`SeqDriver`, `SimpleUVM` and `BuildUVMPkg` stayed equal, which reads exactly
like "the new guard fired on Scoreboard". It did not. **The same binary, run
four times on the same input from the test's own directory, produces two
different databases** — `30a9cd9884b2` / `fd6ba3b2d2e0` on the delivered binary
and `24c186cfa00a` / `86286047dd38` on the PRISTINE one — with the SIZE stable
(`11145637` pristine ×4, `11145680` delivered ×3) and a 92-line dump difference
in one `vpiTaskFunc` listing of `svunit_pkg`. This is the standing emitter-
nondeterminism note, now with a named instance and a reproducer.

Consequences, applied here:
* the **size delta is the attribution**, not the md5 — `Scoreboard`'s `+43` is
  stable across every run of both binaries, so it is a REAL mover;
* `SeqDriver`, `SimpleUVM` and `BuildUVMPkg` were re-measured and are
  **deterministic 3/3**, so the head claim of §3.4 rests on a stable database;
* any future pass comparing `Scoreboard` md5s across builds must re-run it
  first. Filed as residue R9.

### 5.6 "the grid will catch it" — IT DID NOT; the corpus did

`g8` is the cell written to prove the law, and **both binaries answer it
correctly**. The pristine proxy happens to agree with the law on every cell a
small hand-written source can express, because in a small file our emission
order and Surelog's name order rarely disagree. The defect only appears where
a class is emitted before a later-sorting class it references — which is the
UVM corpus and not the grid. That is why §3.1's census runs over the whole
corpus and not over `grid10`.

---

## 6. RESIDUES, RANKED

1. **R0 — THE NEW `SeqDriver` HEAD: a scoped CLASS-HANDLE typedef's TYPESPEC
   stays `unsupported_typespec` in golden.** `uvm_resource.svh:717:5`,
   `uvm_resource_types::rsrc_q_t rq;`. Golden:
   `unsupported_typespec (uvm_resource_types::rsrc_q_t) @717:5-717:25`, named
   with the WRITTEN SCOPED SPELLING and spanning the declaration. Ours:
   `class_typespec (rsrc_q_t) @40:11`, the resolved listing object. This is the
   TYPESPEC half of the very law this pass implements: when the owner is not
   compiled, `needLateTypedefBinding` patches a STRUCT typedef's typespec in
   (which is why `access_record` binds a real `struct_typespec` on both sides)
   but leaves a CLASS-HANDLE typedef's as the unsupported placeholder. **One
   condition, on the same predicate, at the typespec factory instead of the
   variable factory — the cheapest next item and the direct continuation.**
2. **R1 — a SCOPED class-handle typedef whose owner IS compiled is a
   `class_var`, not `ref_var`.** Grid `g1` `a_scoped_cls` and `g7`
   `r_early_cls`: golden `class_var`, ours `ref_var`. § aliasClassRefVar10
   answers the BARE-name question at a site that also sees the scoped spelling;
   for the scoped spelling Surelog resolves through `cl->getDataType` and
   `getSimpleVarFromTypespec(class_typespec)` → `class_var`. Deliberately left
   alone here (this pass never touches the RESOLVED arm). Zero corpus rows
   today, 2 grid cells.
3. **R2 — the `process p = process::self();` family, 4 rows per UVM design.**
   `uvm_component::m_apply_verbosity_settings::p`,
   `uvm_process_report_message::p`, `uvm_reg::XatomicX::m_reg_process`,
   `uvm_root::run_test::phase_runner_proc`: golden `ref_var`, ours `class_var`.
   The declared type is a BARE BUILT-IN CLASS NAME (`work@process`), not a
   typedef at all, so no arm of this law reaches it. The largest single block
   of the 52 residual `G_REFVAR` rows.
4. **R3 — two RETURN variables per design read `logic_var` against golden's
   `ref_var`**: `uvm_report_message_element_container::get_elements@338:20` and
   `uvm_utils::find_all@649:19`. An implicit/queue return shape, not a
   class-nested typedef.
5. **R4 — golden emits a return variable at the PROTOTYPE span of an `extern`
   method and we emit only one at the definition span.** Grid `g7`
   `r_ext_early@36:21` / `r_ext_own@37:21` exist on the golden side only. A
   missing-object defect, not a kind defect.
6. **R5 — `uvm_reg_map_info::mem_range@29:27`, golden `struct_var` / ours
   `bit_var`.** A class PROPERTY, § classScopedTypedefPropIsBareLogicVar73's
   neighbourhood, one row.
7. **R6 — the ORDER test compares LEAF names and therefore decides SIBLINGS
   only** (§2.3). Exact for every corpus row; a bare inherited typedef whose
   base lives in another package is decided by the fallback rather than by the
   two full keys. Closing it needs a reconstruction of Surelog's registered
   class name (`pkg::c`, `work@mod::c`, `work@c`), which is `emitClassDefn`'s
   `fullName` and is not available to a free helper today.
8. **R7 — `ct10pred` cannot separate this law's `ref_var` rows from
   § aliasClassRefVar10's and § typeParamRetIsRefVar58's**, so its `G_REFVAR`
   number is a superset and the delivered score is load-bearing (§3.1). Stated
   in its own header.
9. **R9 — `default/Scoreboard` is NONDETERMINISTIC on both binaries** (§5.5):
   two databases of identical SIZE and different content, differing by 92 dump
   lines in a `vpiTaskFunc` listing of `svunit_pkg`, reproducible in four runs
   of one binary. Pre-existing (the pristine binary flips too), unrelated to
   this law, and a trap for any md5-based attribution.
10. **R8 — a BARE own-typedef RETURN on an out-of-body definition is golden
   `ref_var` at BOTH spans, and slang REJECTS the shape** ("return type for
   out-of-block method must use class scope"), so our emitter can never be
   asked the question. Measured on the golden side only and recorded in `g7`'s
   own comment rather than as a cell.

---

## 7. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct10pred.cpp` | **THE VARIABLE-KIND CENSUS**: joins both databases on *(vpiFullName, line:col)* and buckets the CLASS disagreements four ways, golden-first, never netted. Calibrated golden-vs-golden = 0; empty join = exit 5. |
| `ct10scan.sh` | `ct10pred` over every database of a sweep workdir, pairing each with the golden its own `cmds.txt` names. Carries the ACCOUNTING GUARD that caught its own 687-of-1358 silent truncation, and the `< /dev/null` that keeps a child from eating the list. |
| `ct10grid.sh` `grid10/g1…g9.sv` | the nine cells of §1.3, each scored on cmp verdict + head count + the golden-vs-ours variable-KIND table, on both binaries. |
| `ct10bound.sh` | the boundary re-run: every earlier pass's grid on both binaries, dumps NORMALISED for the workdir path first, `IDENTICAL`/`MOVED` per cell with the moved lines printed in full. |
| `ct4*` `ct5*` `ct6*` `ct7*` `ct8*` `ct9*` `qgrid4/` `grid6/` `grid7/` `grid7v/` `grid8/` `vgrid8/` `grid9/` | sd4…sd9's kits, carried forward unchanged and RE-RUN as §4.2's boundary checks. |
| `byteverify.sh` `msdist.sh` `ct7shape.py` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `TAP.md` | carried forward unchanged. |

---

## 8. THE PATCH

`/tmp/r10sd10.patch` — `git diff` vs `5425d65`, `include/` + `src/` +
`tools/probe/r10sd10repro` only. Reproducible with:

```sh
cd /tmp/wt_r10sd10 && git add -A tools/probe/r10sd10repro
git diff 5425d65 --binary -- include src tools/probe/r10sd10repro > /tmp/r10sd10.patch
md5sum /tmp/r10sd10.patch
```

The md5 is delivered with the pass's final report and NOT written here: this
file is inside the patch, so any md5 recorded here is stale the moment it is
written.
