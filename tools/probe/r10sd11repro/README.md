# r10sd11 — the SeqDriver head: § classScopedTdDeclTsUnsupported11

**The SeqDriver head is CUT and MOVED PAST, on both rows.** The
`unsupported_typespec (uvm_resource_types::rsrc_q_t)` /
`class_typespec (rsrc_q_t)` disagreement that r10sd10 left as its R0 is gone at
every one of the 28 places it stood, on all four UVM designs; the new head is a
DIFFERENT object, LATER in Compare's walk, and it is reported below as R0 rather
than dressed up. The rows do **not** reach `PASS_CMP`.

| | |
|---|---|
| BASE | `f07fd6e` (grep-checked `=1` in both worktrees) |
| worktrees | `/tmp/wt_r10sd11` (delivered), `/tmp/wt_r10sd11pris` (pristine control, `git status --porcelain` = 0) |
| delivered binary | md5 `a06e72d3f0199943ede01bbbcdb9b4e1` |
| pristine binary | md5 `f6fa4ec2fa18c75a23d8df4949b049a8` |
| production files | `src/EmitHelpers.h`, `src/TypeEmit.cpp`, `src/TaskFuncEmit.cpp`, `src/StmtEmit.cpp`, `include/UhdmExporter.h` |
| probe files | `tools/probe/r10sd11repro/` |

---

## 1. THE LAW

> **§ classScopedTdDeclTsUnsupported11** — a declaration whose type is WRITTEN
> `Owner::td`, with `Owner` a **CLASS**, does NOT bind `td`'s real typespec. It
> binds an `unsupported_typespec` **NAMED with the WRITTEN SCOPED TEXT** and
> **SPANNED over the CLASS-SCOPE PREFIX** (`Owner::` — the start of the written
> type to the start of its LAST segment) — **UNLESS `td` is the typedef that
> CLAIMED its target's typespec slot**, in which case the real typespec binds
> and nothing changes. The claim goes to the typedef with the smallest
> (group, container-name, typedef-name) key, where group is Surelog's
> `bindTypedefs_` pass order — `$unit` → **PACKAGE** → module → program →
> **CLASS, last** — and both levels iterate name-ordered maps.

### 1.1 WHY, read off Surelog and then measured

`CompileHelper::compileTypespec`'s `paPackage_scope / paClass_scope` arm
(`src/DesignCompile/CompileType.cpp` ~1518) resolves the scope with **exactly
one lookup**, `design->getPackage(<written scope name>)`. **There is no class
lookup at all.** So `Owner::td` with a CLASS owner always falls to the arm's
tail:

```cpp
if (result == nullptr) {
  unsupported_typespec* ref = s.MakeUnsupported_typespec();
  ref->VpiName(typeName);                       // "uvm_resource_types::rsrc_q_t"
  fC->populateCoreMembers(type, type, ref);     // the paClass_scope NODE = "Owner::"
  result = ref;
}
```

`compileVariable`'s own `paClass_scope` arm (~554) then overwrites the
variable's typespec with that same object and calls
`component->needLateTypedefBinding(var)`.

The placeholder is repaired later, in `ElaborationStep::bindTypedefs_`, and
**only** through a `std::map<std::string, typespec*> specs` whose class-scoped
key `Owner::td` is added at exactly ONE place — the `noTypespec == true`
branch, which a typedef takes **only when its TARGET DataType's typespec slot
was still EMPTY when the typedef was processed**:

```cpp
const DataType* prevDef = typd->getDefinition();
if (prevDef) {
  prevDef = prevDef->getActual();
  if (prevDef->getTypespec() == nullptr) noTypespec = true;
  else { specs.emplace(prevDef->getTypespec()->VpiName(), …); … }   // WRONG KEY
}
…
if (noTypespec) { … specs.emplace(StrCat(cls->getName(), "::", typd->getName()), ts); }
```

A typedef whose target already carries a typespec keys `specs` off the
**already-claimed typespec's own name**, so `Owner::td` is never a key, the
swap never fires, and the placeholder survives into the database.

`bindTypedefs_`'s `defs` vector is built file-contents → packages → modules →
programs → **classes last**, and `getTypeDefMap()` is
`std::map<std::string, TypeDef*, StringViewCompare>` while
`getClassDefinitions()` is the same name-ordered multimap r10sd10's law reads.
**That is the claim order, and nothing else is.**

For UVM: `typedef uvm_queue#(uvm_resource_base) rsrc_q_t;` competes for the
`uvm_queue` slot with `uvm_queue#(T)`'s own `typedef uvm_queue#(T) this_type;`,
and `uvm_pkg::uvm_queue` < `uvm_pkg::uvm_resource_types`. **`this_type` claims;
`rsrc_q_t` degrades.** That is the whole SeqDriver head.

### 1.2 THE GRID — golden's rule, cell by cell

`grid11/`, eight cells, each run on BOTH binaries by `ct11grid.sh` and scored
on the cmp verdict, the dump-content count AND the BOUND-TYPESPEC table
(`<variable fullname> -> <typespec class> (<name>) @line:col`) golden-vs-ours.

| axis | cell | golden |
|---|---|---|
| **TARGET DECLARED IN PLACE never degrades** | `g1` `a_i` `a_e` `a_s` `a_sp` `a_v` `a_t` `a_m` `a_n` — int / enum / struct / packed struct / logic vector / string / `int m_t[string]` / `int n_t[4]` | **all nine resolve**, owner sorting LATE is irrelevant |
| **CLAIM, by NAME inside one class** | `g1` `c_t` vs `ca_t` / `cq_t` (all three name `zelem1`) | `c_t` resolves; `ca_t`, `cq_t` **degrade** |
| CLAIM, a typedef of a TYPEDEF | `g1` `ss_t` (`typedef zholda1::s_t ss_t`) | **degrades** — `s_t` owns the slot |
| **CLAIM, across CONTAINERS** | `g7` `n7::a_t` vs `x7::b_t` | `a_t` resolves; `b_t` **degrades** |
| **CLAIM groups SPECIALISATIONS of one generic** | `g7` `n7::p_a` = `zg7#(int)`, `x7::p_b` = `zg7#(byte)` | `p_a` resolves; `p_b` **degrades** |
| **a PACKAGE typedef claims ahead of every class typedef** | `g7` `pk_t` vs `n7::c_t` / `x7::d_t`; `g6` `pkg_td6`; `g4` `pkg_c_t` | both class typedefs **degrade** |
| the ONLY typedef naming its target | `g7` `n7::u_t`, `g6` `t_fwd` / `t_parm`, `g5` `q_t` / `p_t`, `g3` `c_t` | **resolve** |
| **ORDER of the OWNER class is irrelevant** | `g1` (owner sorts AFTER) vs `g2` (identical source, owners RENAMED to sort BEFORE) | **the same twelve answers** |
| **SITE is irrelevant** | `g3` — return type, three formals, body local, initialised body local, block-item local, array-declarator local, task local | all eight **resolve** on a claiming typedef |
| **the DECLARATOR-ARRAY site** | `g8` `a_aa` `a_q` `a_da` `a_fx` (degrading) vs `k_aa` `k_q` `k_da` `k_fx` (claiming) | placeholder on BOTH the array_typespec's ELEMENT ref and the element variable's ref; real typespec for the claiming four |
| **BARE spelling never reaches this arm** | `g4` `b_inh` `b_own` `o_inh` `o_own` | resolve (a different, pre-existing span defect, R3) |
| **PACKAGE root is the control** | `g4` `p_scoped` (`px4::pkg_c_t`), `p_bare`, `p_struct` | resolve — `::` alone is not the trigger |
| **SPAN** | `g1` `zholdb1::cq_t` 21:7→21:16 (a 9-char prefix); `g8` 35:7→35:11; SeqDriver 717:5→717:25 over `uvm_resource_types::` | the CLASS-SCOPE PREFIX, never the whole type name |

**`g7` is the cell that made the predicate honest.** Before it, "the target is a
name" alone fitted every UVM row and every cell of `g1`; `g7` shows two
specialisations of ONE generic share ONE claim and that a package typedef beats
every class typedef, which is exactly the pair of facts that puts
`uvm_queue#(T)::this_type` ahead of `uvm_resource_types::rsrc_q_t`.

---

## 2. STATED GATE == CODE GATE

**STATED**, as ONE predicate (`UhdmExporter::classScopedTdUnsupName11`, with
`tdDegrades11` carrying questions (2)+(3)) and FIVE call sites, and nowhere
else:

1. **(1) SPELLING** — the declared type syntax is a `NamedType` over a
   `ScopedName` of IDENTIFIER segments whose ROOT resolves to a `ClassType`
   (or a `GenericClassDef`'s default specialisation) and whose LEAF is a
   `TypeAlias`.
2. **(2) TARGET IS A NAME** — `tdSlot11` peels declarator containers, chases a
   chain of typedef NAMES to its end, and reports the GENERIC for a
   specialisation. A chain that ends at a type declared IN PLACE reports the
   typedef ITSELF, which can never lose the race, so it resolves.
3. **(3) CLAIM** — some typedef with a smaller (group, container, name) key
   names the same slot. The table is built once, lazily, over compilation
   units (group 0), packages (1), instantiated module bodies (2), and — reached
   recursively from those — classes and every specialisation of every generic
   class (4), each class keyed by Surelog's registered name (`pkg::c`,
   `work@mod::c`, `work@c`).
4. **A DECLINED ARM, stated** — when the typedef's OWN written target is a
   CLASS-SCOPED name AND that target typedef itself degrades, golden's object
   is the TYPEDEF's own `unsupported_typespec` (named `td`, spanned at the
   typedef) and not this factory's. `g6` `v_td` is that cell; the predicate
   declines rather than mint a plausible wrong object.

**SITES** — five, all of them `if (auto* uts11 = makeScopedTdUnsupTs11(sym))`
applied to the BINDING and to nothing else, so no variable's class, name, span
or parent moves:

* `src/TaskFuncEmit.cpp` ~5151 — the SUBROUTINE-BODY local (site 1).
* `src/StmtEmit.cpp` ~1370 — the BLOCK-ITEM local (site 2).
* `src/TaskFuncEmit.cpp` ~3400 — the RETURN variable (site 3).
* `src/TaskFuncEmit.cpp` ~1161 / ~1360 — `makeQueueDynArrayVar` /
  `makeAssocArrayVar`, where the substitution is made on `elemTs` so BOTH the
  array_typespec's element ref and the element variable's ref take it (sites
  4a/4b).
* `src/TaskFuncEmit.cpp` ~4785 and `src/StmtEmit.cpp` ~1298 — the FIXED-SIZE
  declarator-array pair, tf-item and block-item forms (sites 4c/5).

**CODE** — `git diff f07fd6e --numstat`: `src/EmitHelpers.h` **+211/−0**,
`src/TypeEmit.cpp` **+211/−0**, `src/TaskFuncEmit.cpp` **+45/−4**,
`src/StmtEmit.cpp` **+18/−4**, `include/UhdmExporter.h` **+33/−0**.

### 2.1 COVERAGE OF THE CODE'S OWN GUARDS — declared, not assumed

| guard | fires on the corpus? | what proves it |
|---|---|---|
| (1) SPELLING, ScopedName rooted at a class | **FIRES BOTH WAYS** | 28 corpus rows accept; `g4` `b_inh` / `b_own` (bare) and `p_scoped` (package root) take the reject arm |
| (1) IDENTIFIER segments only | **never rejects on the corpus** | a PARAMETERISED owner (`aparm#(int)::td`) is a `ClassName` node, is outside every measured cell, and is refused rather than guessed at. UNEXERCISED and named |
| (2) target declared IN PLACE | **FIRES BOTH WAYS** | `g1`'s nine in-place cells reject; `uvm_resource_types::access_t` / `override_t` on the corpus reject and are byte-unchanged |
| (3) CLAIM | **FIRES BOTH WAYS** | `g7` in one cell (`a_t` rejects, `b_t` accepts); on the corpus 28 rows accept |
| generic-specialisation walk | **LOAD-BEARING on the corpus** | without it `uvm_queue#(T)::this_type` is invisible and `rsrc_q_t` reads as the unique claimant — the head does not move at all |
| module group (2), instantiated bodies only | **UNEXERCISED** | a typedef in a module the design never instantiates is invisible to the table; that can only ever answer "claimed" (the unchanged direction). Stated, not hidden |
| the DECLINED arm (§2 item 4) | **never fires on the corpus** | `g6` `v_td` is its only coverage; `rsrc_q_t`'s target is `uvm_queue#(uvm_resource_base)`, a plain unscoped name |

---

## 3. THE MOVERS

### 3.1 Census-predict, made FIRST and from the ARTIFACT — `ct11pred` / `ct11scan.sh`

`ct11pred` joins every `variables` object of the two databases on
*(vpiFullName, line:col)* — total, since a declaration produces one variable at
one place — and buckets the BOUND-TYPESPEC disagreements five ways, never
netted: `G_UNSUP` (golden binds an unsupported_typespec, ours does not),
`O_UNSUP` (the reverse, i.e. an OVER-fire of ours), `TS_KIND`, `TS_NAME`,
`TS_SPAN`.

**Calibrated before use**: golden-vs-golden on `SeqDriver` = `shared=8592
same=8592`, every bucket **0**.

Run over every PRISTINE database of both corpora, before any delivered database
was compared:

| corpus | databases | accounted | with rows | G_UNSUP | O_UNSUP | TS_KIND | TS_NAME | TS_SPAN |
|---|---|---|---|---|---|---|---|---|
| surelog | **953** | 783 scanned + 170 empty-join | **7** | **326** | 0 | 16 | 1115 | 2343 |
| uhdm2rtlil | **1358** | 1086 + 272 | **0** | 0 | 0 | 0 | 2 | 6 |

```
PREDICT default/BuildUVMPkg   default/Scoreboard   default/SeqDriver   default/SimpleUVM
        testflags/BuildUVMPkg testflags/SeqDriver  testflags/SimpleUVM
```

**Delivered score over the same 953**: the same 7 databases,
**G_UNSUP 326 → 142**; `O_UNSUP` stays **0 → 0**, and `TS_KIND` / `TS_NAME` /
`TS_SPAN` are **unchanged at 16 / 1115 / 2343**, so the patch creates no new
disagreement of any kind anywhere. **184 census rows converted**
(SeqDriver 72→44, SimpleUVM 36→10, Scoreboard 36→10, BuildUVMPkg 37→12, ×2
modes where the row exists).

`ct11pred`'s own limit is stated in its header: `G_UNSUP` is a **SUPERSET** —
golden's `unsupported_typespec` at a given place may equally come from
§ oobParamClassTypeParamFormalUnsupported31 or
§ baseClassTypeParamFormalUnsupported34 — so the number predicts the CANDIDATE
SET and the DIFFERENCE between the pristine and delivered scores is the claim.
The 142 residual rows are `REQ` / `RSP` / `process` / `uvm_*_cb_iter` /
`uvm_cmdline_parsed_arg_t` / `m_verbosity_setting`, all BARE names and none of
them this law's.

`ct11scan.sh` carries r10sd10's ACCOUNTING GUARD and it earned its keep here
too: an EMPTY JOIN prints `[S] TS shared=0 EMPTY-JOIN` and has **no bucket
fields**, and the first version's `$((…))` swallowed four of them silently. It
is now its own counted bucket and the accounting is `scanned + empty_join +
no_golden + no_line == found`, a hard error otherwise.

### 3.2 The MOVER RULE — size delta on every mover

`byteverify.sh`, both corpora, `SELFCHECK=1` and `SELFCHECK1=1`:

| row | pristine | delivered | Δ |
|---|---|---|---|
| `default/SeqDriver` | 18 021 623 | 18 023 230 | **+1607** |
| `testflags/SeqDriver` | 18 022 056 | 18 023 661 | **+1605** |
| `default/SimpleUVM` | 11 141 480 | 11 142 600 | **+1120** |
| `testflags/SimpleUVM` | 11 141 821 | 11 142 946 | **+1125** |
| `default/Scoreboard` | 11 145 687 | 11 146 573 | **+886** |
| `default/BuildUVMPkg` | 11 105 985 | 11 106 999 | **+1014** |
| `testflags/BuildUVMPkg` | 11 105 985 | 11 106 999 | **+1014** |

All seven nonzero: **REAL movers** by the standing law, and they are **exactly
the seven predicted databases, name for name**. `testflags/Scoreboard` is
`SLANG_REJECT` at baseline, produces no database, and is a **SKIP**.

### 3.3 Per-shape movers by MULTISET, ADDED and REMOVED separately

`ct7shape.py` on `sed 1d`-stripped, workdir-path-normalised dumps.

| design | ADDED / REMOVED | shapes IMPROVED | shapes WORSENED | distance pris → new |
|---|---|---|---|---|
| `SeqDriver` | 100 / 52 | 3 | **2** | 358 874 → **358 746 (−128)** |
| `SimpleUVM` | 88 / 48 | 5 | **0** | 139 903 → **139 767 (−136)** |
| `Scoreboard` | 88 / 48 | 5 | **0** | 130 205 → **130 069 (−136)** |
| `BuildUVMPkg` | 82 / 43 | 5 | **0** | 77 580 → **77 455 (−125)** |

The transcription, identical in shape on all four:

```
unsupported_typespec  +67/−0    class_typespec  0/−40
vpiName               +33/−0    class_defn      0/−6     vpiClassDefn 0/−6      (SeqDriver)
```

**`SeqDriver`'s TWO worsened shapes are `class_defn` and `vpiClassDefn`, +6
each, and they are the SAME SIX OBJECTS that IMPROVE by 6 on the other three
designs.** They are the six RETURN variables: our anonymous `class_typespec`
carried a `vpiClassDefn` (and so a `class_defn` line), golden's placeholder
carries neither, so removing them is CORRECT object by object — SeqDriver
simply already had FEWER `class_defn` lines than golden overall, and the
per-shape aggregate cannot see which six moved. This is the standing
"per-shape aggregation can MASK named lines" rule, stated rather than netted.

### 3.4 A SIDE EFFECT, found by this verifier and REMOVED before landing

The first delivered binary also changed ONE constant on `SeqDriver`:
`uvm_utils#(TYPE)::types_t`'s `[$]` right range went `UINT:0` → `UINT:1475`
(two dump lines, `vpiDecompile` and `UINT`, both moving AWAY from golden, which
writes `STRING:$`). Nothing in the law touches a range. The cause was
`buildTdClaims11` calling `GenericClassDefSymbol::getDefaultSpecialization`,
which **MINTS a specialisation that did not exist** and perturbs slang's
elaboration. The claim table now walks `specializations()` only — every
claimant the corpus needs is in a REAL specialisation — and the constant is
back to the pristine value. `ct7shape.py`'s per-shape distance is the only
instrument that saw it: the two lines are invisible in the row gates, in the
census and in `msdist`'s total.

### 3.5 The seven live UVM rows — head tuples on BOTH binaries

| row | pristine head | delivered head | cmp lines |
|---|---|---|---|
| `default/SeqDriver` | `unsupported_typespec(uvm_resource_types::rsrc_q_t)@717:5` / `class_typespec(rsrc_q_t)@40:11` | **`class_var(…sort_by_precedence::all)@955:34` / `ref_var`** | 38 → **52** |
| `testflags/SeqDriver` | same | **same new head** | 38 → **52** |
| `default/SimpleUVM` | unchanged | identical | 128 → 128 |
| `testflags/SimpleUVM` | unchanged | identical | 128 → 128 |
| `default/Scoreboard` | unchanged | identical | 128 → 128 |
| `default/BuildUVMPkg` | unchanged | identical | 94 → 94 |
| `testflags/BuildUVMPkg` | unchanged | identical | 94 → 94 |

Every head `grep -c '^LHS:' == 1`.

**READ THE 38 → 52 CORRECTLY.** `cmp lines` is HEAD DEPTH, never a distance —
it is how much of ONE object uhdm-cmp decompiles. The old head was an
`unsupported_typespec`, which prints ONE field; the new head is a `class_var`,
which prints its parent, its typespec chain and its full name. The head OBJECT
is different and strictly LATER in Compare's walk: the whole `rsrc_q_t`
typespec family at 717 / 868 / 872 / 873 / 955 / 987 / … is now byte-equal, and
the first divergence has moved to the ELEMENT VARIABLE of the declaration at
955 whose typespec this pass just fixed. The distance measures agree —
`SeqDriver` −128, census −28 rows on this row alone.

---

---

## 4. THE FIVE GATES

| gate | required | measured |
|---|---|---|
| **1 BUILD** | absolute path, `-j 2`, link line waited for, md5 asserted separately, 32-hex | both worktrees `BASE f07fd6e` grep-checked **=1**; delivered build ` error:` count **0**; `Linking CXX executable slang-uhdm` → `Built target slang_uhdm` seen **before** any md5 was read; delivered **`a06e72d3f0199943ede01bbbcdb9b4e1`**, pristine **`f6fa4ec2fa18c75a23d8df4949b049a8`** — 32 hex each, different. Pristine worktree `git status --porcelain` = **0 lines** |
| **2 GOLDENS** | 23 / 0 and `/bin/false` 0 / 23 | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** |
| **3 u2r** | 679/50/2, `ct8rows` 0 rows | default **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, testflags **679/50/2**, BOTH binaries; `ct8rows` vs committed `results/gate_uhdm2rtlil.csv` (testflags-filtered FIRST — the 731-row trap, which this pass walked into once and then filtered) → **0 differing ROWS (0 row-sides)**; pristine-vs-committed → **0**; pristine-vs-delivered (both modes, 1462 rows) → **0** |
| **4 surelog** | `--mode both`, `ct8rows` 0 rows over 1588 | default **469 CMP_EQUAL / 11 CMP_NOTEQUAL / 25 SURELOG_FAIL / 5 DEFERRED / 284 SLANG_REJECT**, testflags **465 / 8 / 23 / 5 / 286** (+3 NO_DATABASE, 2 UNTRANSLATABLE, 1 TIMEOUT, 1 NO_UHDM), BOTH binaries. All four dump histograms **identical** to committed (default 225 match / 244 differ / 325 blank; testflags 165 / 300 / 329). `ct8rows` vs committed `results/golden_surelog.csv` → **0 differing ROWS** over 1588; pristine-vs-committed → **0**; pristine-vs-delivered → **0** |
| **5 BYTE VERIFIER** | both corpora, `SELFCHECK=1 SELFCHECK1=1`, per-shape movers by multiset, ADDED/REMOVED separate, census-predict FIRST | surelog **7 / 953**, u2r **0 / 1358**; `PATH_SETS_IDENTICAL` both; SELFCHECK **952/953** and **1357/1358**; SELFCHECK1 **8** and **1** — arithmetic consistent (1 corruption + 7 real; 1 corruption + 0 real). The 7 are **exactly the predicted set** (§3.1), all with nonzero SIZE-DELTA (§3.2); per-shape movers are the transcription and nothing else (§3.3), and the one shape that was NOT the transcription was found and removed before landing (§3.4) |

`GOLDEN_DEFER` printed **`[UNSET]`** before the sweeps. All sweeps `--jobs 2`
with private `--out` / `--workdir`. **`SLANG_UHDM` pin verified by reading
`cmds.txt` exhaustively**: surelog 1573 cmds files / **1523 `slang:` lines,
1523 name the delivered binary, 0 name any other**; u2r 1462 / **1458, 1458 /
0**. `results/*.csv` READ ONLY. No `git stash`. slang not patched.

### 4.1 CANARIES

| check | required | measured |
|---|---|---|
| `canaries.sh` surelog | at baseline | **ok=52 changed=0 absent=0**, unknown-names 7 (the documented u2r-only names) — vs committed **and** vs this pass's pristine sweep |
| `canaries.sh` u2r | at baseline | **ok=8** vs committed (testflags-filtered), **ok=16** vs pristine (both modes), changed=0 absent=0 |
| `ctcan2.sh` surelog | `EXPECT_UNKNOWN=1` | **ok=58 changed=0 absent=0 unknown-patterns=1**, **PASS** |
| `ctcan2.sh` u2r | `EXPECT_UNKNOWN=6` | **ok=1 changed=0 absent=0 unknown-patterns=6**, **PASS** |
| `canaudit.sh` | UNCOVERED=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0**, **PASS**, run against THIS directory's scripts |
| fenced names | dispatched by no driver | `UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam` — all four **not dispatched by any driver** |
| `InterfaceModPort`, `BlackParrotComplex`, `YosysOldOr`, `SVSwitch` databases | **byte-identical** | all four, **both modes**, `cmp -s` **BYTE-IDENTICAL** between the two binaries |

### 4.2 BOUNDARIES — every prior grid RE-RUN on BOTH binaries

`ct10bound.sh`, **68 cells** over `qgrid4` (13), `grid6` (6), `grid7` (6),
`grid7v` (3), `grid8` (6), `vgrid8` (3), `grid9` (7), **`grid10` (9)** and
**`vgrid10` (15)** — r10sd10's own grid and its verifier's, both added to the
boundary set by this pass: **IDENTICAL 67, MOVED 1, UNSCORABLE 0.**

The one mover is **`grid10/g7_return_var`**, and it moves in this pass's
direction and ONTO golden:

```
  function zholder::zcls_t r_late_cls();     <- a SCOPED class-handle typedef return
  GOLDEN     unsupported_typespec (zholder::zcls_t) @30:14-30:23
  PRISTINE   class_typespec (anonymous)              @30:14-30:29   <- wrong
  DELIVERED  unsupported_typespec (zholder::zcls_t) @30:14-30:23   == GOLDEN
```

and the cell's dump content falls 64 → 61. `zcls_t` and `aholder::acls_t` both
name `kx`, `acls_t` sorts first, so `zcls_t` loses the race — the law read off
a cell written for a different pass, a year of grids later.

**DETERMINISM.** `detcheck.sh` with the delivered binary on `g1`, `g7` and
`g8`: **3 runs each, 1 distinct sha256, 0 NO_OUTPUT.**

### 4.3 THE GRID SCORE — every cell, both binaries

`ct11grid.sh`, differing TYPESPEC-table sides (golden-vs-ours, both sides
counted). **ZERO cells worsened.**

| cell | pristine | delivered |
|---|---|---|
| `g1` target axis, owner LATE | 18 | **10** |
| `g2` the same, owner EARLY | 18 | **10** |
| `g3` site axis on a CLAIMING typedef | 2 | **2** (nothing moved — the negative control) |
| `g4` spelling axis + package controls | 14 | **8** |
| `g5` the UVM shape, uniquely claimed | 4 | **4** (nothing moved) |
| `g6` which target degrades | 29 | **11** |
| `g7` claim order | 10 | **2** |
| `g8` declarator arrays | 16 | **8** |

---

## 5. REFUTATIONS

### 5.1 "the class-handle KIND is the discriminator" — REFUTED at the first cell

The brief's model was "a STRUCT typedef is late-bound and a CLASS-HANDLE
typedef is not". `g1` killed it in one Surelog run: `zholdb1::c_t`, a typedef of
a plain CLASS NAME, **RESOLVES**, while `zholdb1::cq_t` and `ca_t` — the same
class name with a queue and an assoc declarator — degrade. Kind is not the
axis at all; three typedefs of ONE target are, and only the first survives.

### 5.2 "the target being a NAME is the discriminator" — REFUTED by `g7`

The formal-site law § classScopedTdFormalUnsupported34 already carries that
reading ("exactly when that typedef's WRITTEN TARGET is itself a NAME"), and it
fits `g1`, `g6` and every UVM row. `g7` refutes it: `n7::a_t` and `x7::b_t` are
the same shape over the same class and only `b_t` degrades. What separates them
is the CLAIM, and nothing else.

### 5.3 "compile ORDER of the OWNER decides" — REFUTED by `g2`

`g2` is `g1` with the owners renamed so they sort BEFORE the declaring class
instead of after. Every one of the twelve answers is the same. r10sd10's law
(the variable's CLASS) turns on owner order; this one (the variable's
TYPESPEC) does not, and the two had to be separated before either could be
stated.

### 5.4 "the grid will catch a side effect" — IT DID NOT; the SHAPE VERIFIER did

The `UINT:0` → `UINT:1475` regression of §3.4 is invisible to every cell of
`grid11`, to both row gates, to the census and to the total distance. Only the
PER-SHAPE distance table, read shape by shape with ADDED and REMOVED never
summed, showed two lines moving away from golden — and the cause was a slang
API call that MINTS state (`getDefaultSpecialization`), not anything in the law.

### 5.5 "a `Cls::td` formal degrades" — REFUTED for a CLAIMING typedef

`g3` writes the same claiming typedef at eight sites including three formals
(plain, `ref`, `input`) and golden RESOLVES all of them. The formal site's
older predicate has no claim test and would fire; it is left untouched here
because zero corpus rows disagree today, and it is filed as R1 with `g3` as its
cell rather than merged on a hunch.

---

## 6. INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct11pred.cpp` | **THE VARIABLE-TYPESPEC CENSUS**: joins both databases on *(vpiFullName, line:col)* and buckets the BOUND-TYPESPEC disagreements five ways, golden-first, never netted. Calibrated golden-vs-golden = 0; an empty join is exit 5, not a clean score. |
| `ct11scan.sh` | `ct11pred` over every database of a sweep workdir, pairing each with the golden its own `cmds.txt` names. Carries the ACCOUNTING GUARD (`scanned + empty_join + no_golden + no_line == found`, hard error otherwise) and the `< /dev/null` that keeps a child from eating the list. |
| `ct11grid.sh` `grid11/g1…g8.sv` | the eight cells of §1.2, each scored on cmp verdict + head count + the golden-vs-ours BOUND-TYPESPEC table, on both binaries. `LC_ALL=C sort` before `comm`, because a locale-collated sort reports every row as differing. |
| `ct10bound.sh` + `qgrid4/ grid6/ grid7/ grid7v/ grid8/ vgrid8/ grid9/ grid10/ vgrid10/` | the boundary re-run of §4.2, 68 cells, dumps NORMALISED for the workdir path first. |
| `byteverify.sh` `msdist.sh` `ct7shape.py` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `detcheck.sh` `rowheads.sh` `manifest.sh` `dumptree.py` `census.py` `slots.py` `cells.py` `ct8arm.sh` `ct4*`…`ct10*` `TAP.md` | carried forward from r10sd10 unchanged. |

---

## 7. THE PATCH

`/tmp/r10sd11.patch` — `git diff` vs `f07fd6e`, `include/` + `src/` +
`tools/probe/r10sd11repro` only. Reproducible with:

```sh
cd /tmp/wt_r10sd11 && git add -A tools/probe/r10sd11repro
git diff f07fd6e --binary -- include src tools/probe/r10sd11repro > /tmp/r10sd11.patch
md5sum /tmp/r10sd11.patch
```

The md5 is delivered with the pass's final report and NOT written here: this
file is inside the patch, so any md5 recorded here is stale the moment it is
written.

## 8. RESIDUES, RANKED

1. **R0 — THE NEW `SeqDriver` HEAD: the DECLARATOR-ARRAY element is a
   `class_var` in golden and a `ref_var` in ours.** `uvm_resource.svh:955:34`,
   `uvm_resource_types::rsrc_q_t all[int];`. The array_var, its
   array_typespec, its ranges, the element's span, full name and — after this
   pass — the element's TYPESPEC are byte-equal; only the element variable's
   CLASS differs. `grid11/g8` scores it in both directions and gives the law in
   one line: **golden's declarator-array element over a CLASS-HANDLE typedef is
   a `class_var`, whether that typedef claims its slot or degrades** (8 of 8
   cells, `a_*` and `k_*` alike), while ours is a `ref_var` in all eight. It is
   NOT this law — this law never changes a variable's class — and it is not
   r10sd10's either, whose predicate sees the ARRAY type and answers
   `Resolved`. One predicate, at `makeAssocArrayVar` / `makeQueueDynArrayVar` /
   the two fixed-size pairs, is the cheapest next item and the direct
   continuation.
2. **R1 — the FORMAL site keeps § classScopedTdFormalUnsupported34's older,
   CLAIM-BLIND predicate.** That law degrades a formal whenever the typedef's
   written target is a NAME, with no claim test; `g1`/`g7` show a CLAIMING
   typedef must resolve. Zero corpus rows disagree today (the four `ref` formals
   of `rsrc_q_t` are byte-right on both binaries), so the site is deliberately
   untouched; `g3`'s three formals are the cell that will score the merge.
3. **R2 — the non-`ref` FORMAL's span.** `uvm_resource.svh:1308:33`,
   `print_resources(uvm_resource_types::rsrc_q_t rq, …)`: golden
   `1308:33-1308:53` (the `Owner::` prefix, the same span this law uses) and
   ours `1308:33-1308:61` (the whole type). The four `ref` formals (919:57,
   954:47, 1158:46, 1650:56) span the WHOLE type on BOTH sides, so the
   discriminator is the direction keyword and it is measured, not guessed.
4. **R3 — a BARE class-nested typedef's typespec is bound at the OWNER's own
   class span in golden and at the typedef's in ours.** `g4` `b_inh` / `b_own`
   / `o_inh` / `o_own`, four cells, unchanged by this pass.
5. **R4 — a RETURN variable typed `Owner::td` binds an ANONYMOUS
   `class_typespec` at the return-type token in ours where golden binds the
   typedef's own named object.** `g3` `r_scoped`, `g5` `r5`. This pass fixes the
   six UVM rows where golden wants the PLACEHOLDER; the CLAIMING case is still
   wrong and is a different factory's defect.
6. **R5 — the nested DECLINED arm (§2 item 4), `g6` `v_td`.** Golden's object
   is the TYPEDEF's own `unsupported_typespec`; modelling it means changing the
   typedef LISTING emission.
7. **R6 — the claim table cannot see typedefs in UN-INSTANTIATED modules**
   (§2.1). Unexercised; the miss direction is always "claimed", which changes
   nothing.

---

# VERIFIER ADDENDUM — vsd11 (adversarial verification of r10sd11)

Fresh worktrees `/tmp/wt_vsd11` + `/tmp/wt_vsd11pris` at `f07fd6e`, both built
independently `-j 2`.

## V.1 EVERY HEADLINE NUMBER REPRODUCED BIT-FOR-BIT

The shipped patch's binaries rebuilt to the **same md5s**: delivered
`a06e72d3f0199943ede01bbbcdb9b4e1`, pristine `f6fa4ec2fa18c75a23d8df4949b049a8`.
Goldens 23/0 and `/bin/false` 0/23; u2r 679/50/2 both modes both binaries and
`ct8rows` **0 differing ROWS** three ways; surelog 469/11/25/5/284 and
465/8/23/5/286/3/2/1/1, `ct8rows` **0 over 1588** three ways; SLANG_UHDM pin
1573/1523/1523/0 and 1462/1458/1458/0; byteverify **7/953** (the same seven
names) and **0/1358**; census golden-vs-golden 8592/8592 all buckets 0, pristine
**G_UNSUP 326**, delivered **142**, `O_UNSUP` 0→0, TS_KIND/NAME/SPAN
**16/1115/2343** unchanged; per-shape 100/52, 88/48, 88/48, 82/43 with distances
**−128 / −136 / −136 / −125**; boundary **68 cells, 67 IDENTICAL, 1 MOVED**
(`grid10/g7_return_var`, onto golden); heads **38 → 52** on both SeqDriver rows,
every `grep -c '^LHS:'` = 1.

## V.2 THREE REGRESSIONS FOUND — PRISTINE-RIGHT -> PATCHED-WRONG — AND FIXED

`vgrid11/`, twelve cells. Three of them scored the shipped binary WORSE than
pristine on legal SV: pristine bound a `class_typespec` whose CLASS and NAME
matched golden's and the shipped binary replaced it with an
`unsupported_typespec` golden does not have.

| cell | declaration | golden | pristine | shipped | V-FIXED |
|---|---|---|---|---|---|
| `v3` | `binner3::s_in` (nested class, self-scoped) | `class_typespec (s_in)` | `class_typespec (s_in)` | **`unsupported_typespec (binner3::s_in)`** | `class_typespec (s_in)` |
| `v5` | `zbase5::base_t` (an interface class also names the target) | `class_typespec (base_t)` | `class_typespec (base_t)` | **`unsupported_typespec (zbase5::base_t)`** | `class_typespec (base_t)` |
| `vb` | `zclsb::shr2_t` (same) | `class_typespec (shr2_t)` | `class_typespec (shr2_t)` | **`unsupported_typespec (zclsb::shr2_t)`** | `class_typespec (shr2_t)` |

Three causes, each with its own bracketing cell:

1. **A NESTED class's container key is its SHORT name.** `surelogClassKey11`
   spelled it `pkg::Outer::Inner`. `v3` (`binner3` beats `pv3::aouter3`) and
   `va` (`zzinna` LOSES to `pva::aouta` — the same shape renamed) bracket the
   key from both sides and rule out `Outer::Inner` and "nested is reached
   first".
2. **INTERFACE CLASSES ARE NOT IN THE LIST.** `vb` `aifb::only_t` is the SOLE
   typedef naming its target — every claim model resolves it — and golden
   DEGRADES it; `aifb::shr_t` sorts first and still loses to `zclsb::shr2_t`.
   So an interface class neither claims a slot nor registers a repair key.
3. **QUESTION (5), REACH, which the shipped predicate never asked.** The repair
   key is `<the class the typedef is DECLARED in>::<name>`, ONE segment.
   `vc` isolates it — every typedef there is the sole namer of its target, so
   only reach can separate them — and golden DEGRADES `adervc::inh_t` (the
   derived class's spelling) and `abasec::innerc::deep_t` (multi-segment) while
   RESOLVING `abasec::inh_t`, `adervc::own_t` and `innerc::deep_t`.
   `v9 deep_int_t` kills the shipped law's "an IN-PLACE target can never
   degrade": golden degrades `aout9::ainn9::deep_int_t`, whose target is `int`.

The NAME golden writes when reach fails is `<first segment>::<LAST segment>`,
not the whole text — `aout9::ainn9::deep_t` -> `aout9::deep_t` (`v9`),
`abasec::innerc::deep_t` -> `abasec::deep_t` (`vc`), and, independently,
`o11::m11::m_t` -> `o11::m_t` in **sd10's own `vgrid10/v11`**, which the fix
converts to golden-exact.

## V.3 WHAT THE LAW MUST NOT TOUCH — MEASURED, NOT ASSUMED

`v1` puts the degrading typedef at a PACKAGE variable, a MODULE variable and a
CLASS PROPERTY in all five declarator forms: the patched dump is **byte-identical
to pristine**. `makeAssocArrayVar` / `makeQueueDynArrayVar` are shared factories
but are only ever called from `TaskFuncEmit`'s tf-item arm and `StmtEmit`'s
block-item arm, so the five sites really are the subroutine scope and nothing
else. `v8` scores the untouched FORMAL site in both directions.

## V.4 THE CLAIM TABLE'S BLIND SPOTS ARE UNDER-FIRE ONLY

`v7` puts the would-be claimant in a NESTED module instance, an INTERFACE and a
GENERATE block. All three are invisible to `buildTdClaims11`; all three leave
the class typedef reading "claimed", i.e. UNCHANGED, which is the safe
direction, and golden's disagreement on `c_sub` / `c_if` is identical on both
binaries. `v2` proves the residual `getDefaultSpecialization` call in
`scopedTdLeaf11` is **DEAD CODE**: slang rejects `GenericCls::td` outright
("cannot refer to generic class with '::' without providing parameter
assignments"), so the arm cannot be reached from any source slang accepts.

## V.5 `default/Scoreboard` IS NOT BYTE-STABLE — ON THE BASE COMMIT TOO

Four solo runs of each binary on the Scoreboard command line:

```
V-FIXED  346c6ef8… 346c6ef8… 4d9848c2… e9898251…   (3 distinct)
PRISTINE c90452e8… c90452e8… c90452e8… 489756c0…   (2 distinct)
```

The instability is a pure PERMUTATION of the top-level task_func listing:
**SIZE is identical across every run** (11 146 573 fixed / 11 145 687 pristine)
and the MULTISET DISTANCE between any two runs of one binary is **0**. The
`+886` size delta and the `130205 -> 130069` distance are therefore REAL and
stable; the row's md5 is not, so a byte-level fix-vs-delivered comparison on
that ONE row is uninterpretable and is reported as such rather than as a mover.
Two of the four V-FIXED runs produced the shipped binary's exact database.

## V.6 GATES ON THE V-FIXED BINARY (`4b5a417a77aa135ab300c8e05b8ae56f`)

Goldens **23/0**, `/bin/false` **0/23**. u2r **679/50/2** both modes,
`ct8rows` **0 rows** vs committed and vs pristine. surelog
**469/11/25/5/284** + **465/8/23/5/286/3/2/1/1**, `ct8rows` **0 rows over 1588**
vs committed and vs pristine, all four dump histograms unchanged. byteverify
**7/953** and **0/1358**, `PATH_SETS_IDENTICAL`, SELFCHECK **952/953** and
**1357/1358**, SELFCHECK1 **8** and **1**. Census **G_UNSUP 142, O_UNSUP 0**,
TS_KIND/NAME/SPAN **16/1115/2343** — identical to the shipped binary, so the
fix adds NO new disagreement anywhere. Per-shape identical to the shipped
table. `grid11` scores **10/10/2/8/4/11/2/8** — identical to the shipped
binary, so no grid11 cell regresses. `vgrid11` **v9 / va / vc go to ZERO
differing sides**, `v3` 6→2, `v5` 8→2, `vb` 6→2. Boundary **68 cells,
66 IDENTICAL, 2 MOVED** — `grid10/g7_return_var` and `vgrid10/v11_nested_scopes`,
**both onto golden**, and **ZERO variable-KIND lines moved in either**, so
sd10's law is untouched. Canaries `ok=52/0/0` (unknown 7) vs committed and vs
pristine, u2r `ok=8` / `ok=16`; `ctcan2` 58 PASS and 1 PASS; `canaudit`
`audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS`; `InterfaceModPort`,
`BlackParrotComplex`, `YosysOldOr`, `SVSwitch` byte-identical both modes.

## V.7 THE REMAINING MISSES, NAMED WITH THEIR CELLS (all UNDER-fire, none new)

`vgrid11/vd` and `vgrid11/ve` were added after the fix and score two more reach
shapes. Both confirm the rule and both name a residue rather than a regression:

* **`vd` `acd::k_t`** — a `$unit` class's OWN typedef, sole namer of its target,
  reach and claim both satisfied, and golden **DEGRADES** it. The registered name
  of a `$unit` class is `work@acd`, which no written scope can spell — exactly
  sd10's `g9` fact. The fix does not model it; it is an under-fire, identical on
  both binaries. (`vd` `acd::c_t`, the claim-losing sibling, IS fixed: 4 → 2
  differing sides.)
* **`ve` `alias_c::home_t`** — the owner written through a TYPEDEF ALIAS of the
  class. `scopedTdLeaf11` requires the root to resolve to a ClassType and an
  alias does not, so the predicate declines; golden degrades. Under-fire,
  identical on both binaries.
* **`ve` `ahome::amid::ainner::deep_t`** — THREE segments — is the third
  independent confirmation of the name and span rules, and the fix makes it
  golden-exact (`unsupported_typespec (ahome::deep_t) @29:7-29:28`).

Determinism: `detcheck.sh`, 3 runs each, **1 distinct hash and 0 NO_OUTPUT** on
`v3 v5 v9 va vb vc vd ve` and on `grid11 g1 g7 g8`.

The V-FIXED patch applied to a FRESH `f07fd6e` worktree and built there
independently reproduces md5 **`4b5a417a77aa135ab300c8e05b8ae56f`**.
