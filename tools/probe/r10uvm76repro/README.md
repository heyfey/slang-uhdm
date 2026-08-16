# r10uvm76 — § classEnumConstBindsHoistNet76

**BASE f0d93e1.** Production surface: `src/ExprEmit.cpp` only. Probe surface:
`tools/probe/r10uvm76repro/` only.

---

## 1. THE LAW

```
§ classEnumConstBindsHoistNet76
```

A reference to a **CLASS-SCOPE ENUM CONSTANT**, written **UNQUALIFIED** inside
an **OUT-OF-BODY class method**, binds an **implicit `logic_net`** on the module
that HOISTS that class's package — the same wire the unresolvable class-property
names (`classPropRefs` / `bindHoistedClassPropRefs`) and the `with`-clause
iterators (§ withIterRefBindsHoistNet75) already bind.

Surelog compiles an out-of-body body in the HOME PACKAGE's scope, where the
class's own enum constants are exactly as invisible as its properties. The
reference falls into the late-binding pool, and the importing module binds it to
a net of that name, MINTING a bare `logic_net` (`vpiNetType:1`, no typespec)
when it declares none.

Four conventions travel with it, and all four are MEASURED, not assumed:

| # | convention | evidence |
|---|---|---|
| a | **UNQUALIFIED only** | a `::`-scoped read (`process::KILLED`, `uvm_mem_mam::GREEDY`, `uvm_resource_types::PRI_HIGH`) names its own scope, Surelog resolves it, and golden leaves it bare in BOTH views — arm `b3_qual`, and **24 such references in SimpleUVM** |
| b | **OUT-OF-BODY only** | an in-body method resolves at class scope and golden nets nothing — arm `b2_inbody`; corpus cells `uvm_report_catcher::process_report_catcher::CAUGHT` @678:15 and `uvm_reg_sequence::do_reg_item::LOCAL` @179:26 |
| c | **CLASS-scope only** | a PACKAGE-scope enum constant read from the same out-of-body body resolves and binds the real `enum_const` — arm `b1_oob`'s `G_X` cell, and SimpleUVM's 3753 `enum_const` bindings, none of which move |
| d | **one wire per NAME** | minted at the **FIRST** reference's span, then SHARED by every later method (`work@top.SEQ_TYPE_LOCK` @664:54 serves four references in three methods) — arm `b4_share` |

**Refusal rule.** A class **PROPERTY INITIALIZER** (`seq_parent_e parent_select
= LOCAL;`) is not inside a subroutine at all, so `curSubOob9` is false and the
law never reaches it. Golden leaves it bare and so do we — arm `b4_share`'s
`init` cell, corpus cell `uvm_reg_sequence::parent_select::LOCAL` @158:32.

**Site count: 1 of 1**, in `src/ExprEmit.cpp`, inside the pre-existing
`if (inClassBodyEmit && !ref->Actual_group())` block. No new binding machinery:
the site pushes into `classPropRefs`, and `bindHoistedClassPropRefs` — which
already owns the per-name, first-reference, hoist-gated mint — does the rest.

### STATED GATE == CODE GATE

The prose says *a class-scope enum constant, written unqualified, referenced
from an out-of-body class method's own body*. The code gate is exactly:

```cpp
else if (classBodyHomePkg75 && classScopeEnumConst76(nv.symbol) &&
         !(expr.syntax &&
           expr.syntax->kind == syntax::SyntaxKind::ScopedName))
    classPropRefs.push_back({ref, std::string(nv.symbol.name),
                             expr.sourceRange, classBodyHomePkg75});
```

with, unchanged and pre-existing,
`inClassBodyEmit = oob && classScope && !cloneMode` and `classBodyHomePkg75`
non-null **only** when `inClassBodyEmit` is true. Term by term:

| prose | code |
|---|---|
| out-of-body class method | `inClassBodyEmit` (enclosing `if`) + `classBodyHomePkg75` |
| class-scope enum constant | `classScopeEnumConst76(nv.symbol)` |
| written unqualified | `expr.syntax->kind != ScopedName` |
| binds the hoisting module's wire | `classPropRefs.push_back(...)` — `bindHoistedClassPropRefs` owns the module half |

The `else if` chain guarantees a reference is recorded at most once: the
class-PROPERTY arm and § withIterRefBindsHoistNet75's SITE B both precede it,
and the enclosing `!ref->Actual_group()` means an already-bound reference is
never re-recorded.

The predicate itself is the one this pass **extracted** out of the arm that
already computed it:

```cpp
static bool classScopeEnumConst76(const slang::ast::Symbol& sym) {
    if (sym.kind != SymbolKind::EnumValue) return false;
    for (auto sc8 = sym.getParentScope(); sc8;
         sc8 = sc8->asSymbol().getParentScope()) {
        auto k8 = sc8->asSymbol().kind;
        if (k8 == SymbolKind::ClassType) return true;
        if (k8 == SymbolKind::Package || k8 == SymbolKind::InstanceBody ||
            k8 == SymbolKind::CompilationUnit) return false;
    }
    return false;
}
```

LAW C's refusal arm (`curSubOob9 && ...`) held this walk as an inline lambda;
it now CALLS the helper, so the two halves of LAW C's reference side — the one
that refuses to stamp the `enum_const` and the one that nets it — cannot drift
apart. That substitution is **behaviour-identical by construction** (same
predicate, same order, same early-outs) and the pristine/patched byte
comparison confirms it: outside the 7 target cells, nothing moved.

**Why the WALK and not `getParentScope()`.** slang parents an
`EnumValueSymbol` on the **enum's own scope**, so a class-scope enum constant
is never a *direct* child of the `ClassType`. That is precisely why the
pre-existing class-PROPERTY arm in this same block — a direct-parent test,
`csc9->asSymbol().kind == SymbolKind::ClassType` — never saw one, and why the
head survived until now.

---

## 2. CENSUS FIRST — SimpleUVM (default), design-wide, span-keyed, BOTH SIDES

`ct76cen.py` keys every `ref_obj` by `(vpiFullName, span)` and records its
`vpiActual` as a **MULTISET**, because Surelog prints an out-of-body body TWICE
— once in the package listing, once in the module HOIST copy — and collapsing
the two would hide the exact half of the law this pass is about. A key present
on only one side prints `ABSENT` and COUNTS as a disagreement.

### 2.1 The whole design

| measure | value |
|---|---|
| `ref_obj` keys, union of both sides | **29059** |
| disagreeing, pristine | 6273 |
| …of which are **this law's** | **7** |

### 2.2 The population: every enum-constant-named reference

Restricted to refs whose leaf name is also printed as an `enum_const` somewhere
in the database (2898 keys), by ACTUAL-MULTISET SHAPE, in **golden**:

| shape | keys | what it is |
|---|---|---|
| `NxNONE` (N≥1) | 1288 | bare in every view — package-scope enums under macro spans, and the qualified reads |
| `Nxenum_const` | 1603 | resolved; we match all of them |
| **`1xNONE + 1xlogic_net`** | **7** | **THIS LAW — the entire population, design-wide** |

**Seven keys. That is the whole population in SimpleUVM**, and all seven
disagreed before the patch and agree after it:

| # | cell | method | form | golden actual | pristine | patched |
|---|---|---|---|---|---|---|
| 1 | `SEQ_TYPE_LOCK` @664:54 | `grant_queued_locks` | OOB | `logic_net work@top.SEQ_TYPE_LOCK` @664:54 | NONE | **= golden** |
| 2 | `SEQ_TYPE_LOCK` @677:65 | `grant_queued_locks` | OOB | same wire @664:54 | NONE | **= golden** |
| 3 | `SEQ_TYPE_LOCK` @1069:21 | `wait_for_grant` | OOB | same wire @664:54 | NONE | **= golden** |
| 4 | `SEQ_TYPE_LOCK` @1175:21 | `m_lock_req` | OOB | same wire @664:54 | NONE | **= golden** |
| 5 | `SEQ_TYPE_REQ` @763:40 | `m_choose_next_request` | OOB | `logic_net work@top.SEQ_TYPE_REQ` @763:40 | NONE | **= golden** |
| 6 | `SEQ_TYPE_REQ` @893:38 | `m_wait_for_available_sequence` | OOB | same wire @763:40 | NONE | **= golden** |
| 7 | `SEQ_TYPE_REQ` @1079:19 | `wait_for_grant` | OOB | same wire @763:40 | NONE | **= golden** |

All five methods are `extern`-declared and defined as
`function/task uvm_sequencer_base::<name>` — out-of-body, every one.
`SEQ_TYPE_GRAB`, the enum's third constant, is **declared and never
referenced**, and golden mints no wire for it. Neither do we.

### 2.3 The NEGATIVE cells in the same census — every one stays bare

These are what fix the gate. All are class-scope or enum-constant references
in the same design, and golden binds **no** wire to any of them:

| cell | why golden nets nothing | ours (both builds) |
|---|---|---|
| `process::KILLED` @664:102, `process::FINISHED` @664:118 (and @755:50/@756:50) | **QUALIFIED** — and `process` is a class, so the class-scope walk says YES | NONE |
| `uvm_mem_mam::GREEDY` @981:22, `::BROAD` @982:22 | **QUALIFIED**, another class | NONE |
| `uvm_resource_types::{PRI_HIGH, PRI_LOW, NAME_OVERRIDE, TYPE_OVERRIDE}` (9 refs) | **QUALIFIED** | NONE |
| `uvm_report_catcher::process_report_catcher::{CAUGHT, UNKNOWN_ACTION}` | class-scope, unqualified, but the method is **IN-BODY** (`local function int process_report_catcher();` at line 664 of `uvm_report_catcher.svh`) | NONE |
| `uvm_reg_sequence::do_reg_item::LOCAL` @179:26, @189:26 | class-scope, unqualified, **IN-BODY** (`virtual task do_reg_item` line 170) | NONE |
| `uvm_reg_sequence::parent_select::LOCAL` @158:32 | a class **PROPERTY INITIALIZER** — no subroutine at all | NONE |
| `uvm_agent::is_active::UVM_ACTIVE`, `uvm_sequencer_base::m_arbitration::UVM_SEQ_ARB_FIFO`, and 1276 more | **PACKAGE-scope** enum constants — the walk returns false at the Package | NONE |

**24 qualified class-scope-enum references inside out-of-body methods.** A law
written without convention (a) would have minted a wire for every one of them.

### 2.4 The module's Nets vector, by NAME

`ct76nets.py` over `work@top`:

| | golden | pristine | patched |
|---|---|---|---|
| `work@top` nets | 235 | 212 | **214** (+2 = `SEQ_TYPE_LOCK`, `SEQ_TYPE_REQ`) |
| golden-only NAMES (multiset) | — | 32 | **30** |

The +2 are exactly this law's two wires, at golden's spans
(`SEQ_TYPE_LOCK` @664:54, `SEQ_TYPE_REQ` @763:40). In golden's vector they sit
at indices 148 and 150, immediately after `item` @664:28 (index 147) — the wire
§ withIterRefBindsHoistNet75 landed one pass ago, in the SAME statement.

---

## 3. THE GRID — cell for cell, five arms, LHS is ALWAYS golden

`ct76arm.sh`, both binaries. The arms' own heads are a pre-existing `class_defn`
divergence unrelated to this law; they are reported as background.

| arm | pristine | patched | dump content-diff |
|---|---|---|---|
| `b1_oob` | CMP_FAIL (head 1740) | CMP_FAIL (head 1752) — same head object | 42 → **22** |
| `b2_inbody` | **PASS_CMP** | **PASS_CMP** | 12 → 12 (unchanged) |
| `b3_qual` | CMP_FAIL (1444) | CMP_FAIL (**1444**) | 22 → **22** — byte-identical |
| `b4_share` | CMP_FAIL (1840) | CMP_FAIL (1852) — same head object | 64 → **44** |
| `v76_nohoist` | **PASS_CMP** | **PASS_CMP** | 20 → 20 (unchanged) |

### b1 — OUT-OF-BODY, the positive arm (4 cells): 1/4 → **4/4 AGREE**

| cell | golden | pristine | patched |
|---|---|---|---|
| `E_A` @19:14 (first read) | `logic_net work@top76a.E_A` @19:14 | NONE | **= golden** |
| `E_B` @20:14 | `logic_net work@top76a.E_B` @20:14 | NONE | **= golden** |
| `E_A` @21:14 (later read) | the SAME wire @19:14 | NONE | **= golden** |
| `G_X` @22:14 — **PACKAGE-scope** | `enum_const (G_X)` @8:17 | `enum_const` | `enum_const` (untouched) |

Nets: golden `c, r, m, E_A, E_B` / pristine `c, r, m` / patched **`c, r, m, E_A,
E_B`** — names, spans AND ORDER identical to golden. (`m` is the class PROPERTY
wire the pre-existing law already minted; `E_C` is declared and never read, and
no side nets it.)

### b2 — IN-BODY, the gate's negative (4 cells): 4/4 AGREE → **4/4 AGREE**

Byte-for-byte b1 with the method written inside the class. Golden mints **no**
wire at all and its whole Nets vector is just `c, r` — not even the class
property. Both builds agree, before and after. **This arm is why the law says
OUT-OF-BODY.**

### b3 — QUALIFIED, the OVER-FIRE GUARD (3 cells): 3/3 AGREE → **3/3 AGREE**

`c76::E_A`, `c76::E_B` (own class) and `d76::F_A` (another class), all read
from the same out-of-body method. `classScopeEnumConst76` returns **true** for
all three — they are class-scope enum constants — and only the `ScopedName`
test keeps them out. Golden's Nets vector is `c, r, m`: **no E_A, no E_B, no
F_A**. Patched output is **byte-identical to pristine** (cmp 1444 lines both,
dump content-diff 22 both).

Had this test been left out, the arm would have gone `3/3 → 0/3` here and the
corpus would have grown 24 wires SimpleUVM's golden does not have.

### b4 — SHARING + the initializer (4 cells): 3/4 → **4/4 AGREE**

Two out-of-body methods; `f1` reads `E_A`, `f2` reads `E_B` then `E_A`.

| cell | golden | patched |
|---|---|---|
| `f1` `E_A` @19:15 | `work@top76d.E_A` (**minted here**) | **= golden** |
| `f2` `E_B` @24:15 | `work@top76d.E_B` (minted here) | **= golden** |
| `f2` `E_A` @25:14 | `work@top76d.E_A` @19:15 — **the same wire** | **= golden** |
| `m = E_A` @13:15 — property **INITIALIZER** | NONE | NONE (untouched) |

Nets: golden 5 / pristine 3 / patched **5**, `E_A` @19:15 and `E_B` @24:15 —
**one wire per name, at the first reference**, measured rather than assumed.

### v76 — NO HOIST (2 cells): 2/2 AGREE → **2/2 AGREE**

b1's package compiled but never imported. Golden binds nothing; both builds
bind nothing; `PASS_CMP` on both. This is Scoreboard's and BuildUVMPkg's shape,
reduced.

---

## 4. THE FIVE GATES

### Gate 1 — BUILD

Both trees configured and built at ABSOLUTE paths with `-j 2`; **the link line
was reached** (`[100%] Linking CXX executable slang-uhdm` →
`[100%] Built target slang_uhdm`) in both before any measurement. md5 asserted
**separately**, both 32-hex, and **different** from each other:

```
a72eeb765b73c70687aaa58f1f3cca89  /tmp/wt_r10uvm76/build/slang-uhdm       (patched)
2ecf28a8494750468a6edcd435b8f874  /tmp/wt_r10uvm76pris/build/slang-uhdm   (pristine)
```

Both worktrees `rev-parse HEAD` = `f0d93e15aeab7fd559d9c7c00c6196fcc99023e6`.
The pristine tree is **`git status --porcelain` EMPTY** — genuinely BASE
f0d93e1, not a stale or half-reverted build. The patched tree's porcelain is
`M src/ExprEmit.cpp` + the untracked probe directory, and nothing else.

Every sweep's `cmds.txt` was grep-checked for the binary it actually ran, e.g.
`slang: /tmp/wt_r10uvm76/build/slang-uhdm`.

### Gate 2 — GOLDENS

Run with `SLANG_UHDM` **exported explicitly** (`check_goldens.sh` and
`verify_golden.py` both silently default it to the main-tree binary):

* patched binary: **23 PASS / 0 FAIL**
* `SLANG_UHDM=/bin/false`: **0 PASS / 23 FAIL** — the harness genuinely reads
  the binary under test.

### Gate 3 — uhdm2rtlil corpus (`--mode testflags`, `--jobs 2`)

| | patched | pristine (control) |
|---|---|---|
| status | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** | identical |
| dump | **496 match / 183 differ / 52 blank** | identical |
| `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS (0 row-sides)** over 731 rows | 0 / 0 |

Whole-row diff, dump column included. The mode matches the baseline's mode
(`testflags`) — a gate compared against a baseline in a different mode reports
total failure and measures nothing. **The pristine sweep was run through the
same gate first**, so the baseline is proven reachable on this machine before
the patched result is credited.

### Gate 4 — surelog corpus, both modes (`--jobs 2`)

| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default | **469** | **11** | **25** | **5** |
| testflags | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv`: **0 differing ROWS (0 row-sides)**
over 1588 rows, patched AND pristine. Per-mode STATUS **and** dump-column
histograms identical baseline → fresh (default `225 match / 244 differ / 325`;
testflags `165 / 300 / 329`).

### Gate 5 — BYTE VERIFIER, both corpora, both modes, vs the PRISTINE f0d93e1 build

**Census prediction FIRST** (`ct76predict.py`, artifact-based, run on the
PRISTINE workdirs before either comparison):

| corpus | databases that CAN move | class-scope enum constants | DUMP_FAIL |
|---|---|---|---|
| uhdm2rtlil (testflags) | **0** of 679 | **0** | 0 |
| surelog (both modes) | 574 of 953 | 3663 | 0 |

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678 / 679 | **1** = 0 real + 1 corrupted |
| surelog | 953 | **4** | 952 / 953 | **5** = 4 real + 1 corrupted |

`PATH_SETS_IDENTICAL` on both. `SELFCHECK1` returning exactly `real + 1` is the
proof the comparator can see one changed law; on uhdm2rtlil, where the
prediction was **0** and the measurement was **0**, `SELFCHECK1 = 1` is what
separates "nothing moved" from "the verifier saw nothing".

**The uhdm2rtlil prediction is EXACT and the surelog one is a loose envelope**,
and the difference is the point: the corpus contains **zero** class-scope enum
constants, so *no* database there can reach the site — that half is an iff. On
surelog 574 databases declare one, 4 moved, and the 570 non-movers are the
three conditions the artifact cannot show (unqualified / out-of-body / hoisted)
doing their job. The looseness is reported, not hidden (RF-4).

All four movers were **flagged** by the prediction:

```
PREDICT_MOVE default/SeqDriver-32af76aa    classEnumConsts=120
PREDICT_MOVE default/SimpleUVM-1dc93a62    classEnumConsts=120
PREDICT_MOVE testflags/SeqDriver-32af76aa  classEnumConsts=120
PREDICT_MOVE testflags/SimpleUVM-1dc93a62  classEnumConsts=120
```

#### Movers, per-shape by MULTISET (whitespace-stripped, sorted, `sed 1d` both)

| database | REMOVED | ADDED | size delta |
|---|---|---|---|
| default/SimpleUVM | **0** | 28 | **+287** |
| testflags/SimpleUVM | **0** | 28 | **+290** |
| default/SeqDriver | **0** | 28 | **+254** |
| testflags/SeqDriver | **0** | 28 | **+254** |

**Every size delta is NONZERO — by the MOVER RULE each is a proven real
change.** (A zero delta would have proven nothing.) `REMOVED=0` on all four
makes this a **PURE ADDITION**: nothing that existed was rewritten. The 28
added shapes are, identically in every database:

```
  7  |vpiActual:                          <- the 7 bindings (§2.2's cells 1-7)
  5  \_logic_net: line:664:54             <- SEQ_TYPE_LOCK: 4 bindings + 1 decl
  4  \_logic_net: line:763:40             <- SEQ_TYPE_REQ:  3 bindings + 1 decl
  2  |vpiNet:  +  2 \_module_inst:        <- the two Nets entries
  2  |vpiParent:  2 |vpiNetType:1
  1  |vpiName:SEQ_TYPE_LOCK   1 |vpiFullName:…SEQ_TYPE_LOCK
  1  |vpiName:SEQ_TYPE_REQ    1 |vpiFullName:…SEQ_TYPE_REQ
```

5 + 4 = 9 `logic_net` prints against golden's own 5 + 4. SeqDriver's module is
`work@top_tb` (testbench.sv:210) and its two wires are
`work@top_tb.SEQ_TYPE_LOCK` / `…SEQ_TYPE_REQ` at the SAME uvm spans — the law
reproduces on a second design with a different top.

**And the design-wide census agrees with the byte count**: SimpleUVM's
`ct76cen.py` disagreement total goes **6273 → 6266**, exactly −7. Not one other
key in 29059 moved.

---

## 5. THE TARGET ROWS — the head

Measured with `rowheads.sh` (heads counted with `grep -c '^LHS:'` anchored at
column 0; a missing side prints SKIP-NOFILE and is COUNTED).

| row | pristine | patched | head OBJECT before | head OBJECT after | verdict |
|---|---|---|---|---|---|
| **SimpleUVM default** | 17 / 1 | 26 / 1 | `logic_net (work@top.SEQ_TYPE_LOCK)` @664:54 | `ref_obj (…grant_queued_locks::status)` @664:87 | **CLEARED, ADVANCED** |
| **SimpleUVM testflags** | 17 / 1 | 26 / 1 | same | same | **CLEARED, ADVANCED** |
| **Scoreboard default** | 26 / 1 | 26 / 1 | `ref_obj (…::status)` @664:87 | *unchanged* | cmp **BYTE-IDENTICAL** |
| Scoreboard testflags | SKIP-NOFILE | SKIP-NOFILE | — | — | SLANG_REJECT, counted |
| SeqDriver default | 1422659 / 1 | 1422687 / 1 | `LHS: <null>` vs the whole `uvm_pkg` container | *same object* | +28 lines = the law's own |
| SeqDriver testflags | 1422659 / 1 | 1422687 / 1 | same | same | +28 lines = the law's own |
| BuildUVMPkg both | 94 / 1 | 94 / 1 | `struct_typespec (…m_uvm_factory_type_pair_t)` | *unchanged* | cmp **BYTE-IDENTICAL** |
| ApbSlave both | 0 / 0 | 0 / 0 | PASS_CMP | PASS_CMP | unchanged |

**The 17-line head this pass was sent to kill is GONE on BOTH SimpleUVM rows**
— `work@top.SEQ_TYPE_LOCK` no longer appears in either cmp — and the head
advanced from column 54 to column 87 of the SAME source statement.

**Say the new number plainly: 17 → 26. The line count went UP, and that is an
advance, not a regression.** The head is `SafeCompare`'s first disagreement and
its `m_visited` short-circuit hides everything behind it; a *deeper* object
standing at the head prints a *bigger* subtree. The 17 lines were one
`logic_net` against `<null>`; the 26 are a `ref_obj` against a
`method_func_call`, printed on both sides. Reporting "17 → 26, worse" would
have been the false reading, exactly as "17 → 17, no progress" was the false
reading one pass ago.

**And the new head is not a new problem — it is Scoreboard's.** SimpleUVM's
head object is now byte-for-byte the object standing at **Scoreboard's** head:

```
LHS  ref_obj: (uvm_pkg::uvm_sequencer_base::grant_queued_locks::status), line:664:87
RHS  method_func_call: (status), line:664:87
```

Two UVM rows that had different heads for this whole block now share ONE.
Residue **R1** (`§ parensLessCallIsPathRefObj`, r10uvm75's R5) has become a
**two-row** fix, and its distinguisher is already characterised: SimpleUVM's
`uvm_domain::jump`-side hier_paths get it right in the same design.

SeqDriver's head is the standing **vector-form `<null>` prints the CONTAINER**
case — golden's side is `<null>` for the whole `uvm_pkg` vector, so ours prints
the entire package. Its cmp grew by exactly the 28 lines this law adds, and
with object ids stripped (`sed -E 's/, id:[0-9]+//g'`) the delta is
**28 added, 0 removed**, all of them `|vpiActual:` /
`logic_net (work@top_tb.SEQ_TYPE_{LOCK,REQ})`. The rest of the raw text churn
is pure **id renumbering** — inserting 2 objects shifts every later id — and is
reported here rather than buried, because a 16936-line raw cmp diff that is
really 28 lines of content is exactly the reading that would otherwise look
like a catastrophe.

---

## 6. CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `results/gate_uhdm2rtlil.csv` | ok=9 changed=**0** absent=0, unknown-names=25 (the printed expectation) |
| `canaries.sh` vs `results/golden_surelog.csv` | ok=52 changed=**0** absent=0, unknown-names=8 (the printed expectation) |
| `canaudit.sh` | audited=31 **UNCOVERED=0 FENCE-BREACH=0** |
| `ctcan2.sh` u2r, baseline FIRST, `EXPECT_UNKNOWN=6` | ok=1 changed=**0**, unknown-patterns=6 — PASS |
| `ctcan2.sh` surelog, baseline FIRST, `EXPECT_UNKNOWN=1` | ok=58 changed=**0**, unknown-patterns=1 — PASS |

Brief-protected names checked **BY NAME** against the committed baseline, row
for row: `InterfaceModPort` (`CMP_EQUAL/differ` ×2) OK, `BlackParrotComplex`
(`CMP_EQUAL/differ` ×2) OK, and the five UVM rows this pass touches or could
have touched — `SimpleUVM`, `Scoreboard`, `SeqDriver`, `BuildUVMPkg`,
`ApbSlave` — all byte-identical to `results/golden_surelog.csv`. The four
SLANG-FENCED names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by **no** driver here, asserted by `canaudit.sh`
rather than by inspection.

---

## 7. REFUTATIONS — stated plainly

**RF-1. The brief's central worry — "the R2 DUPLICATED names contradict
one-wire-per-name; decode the duplication axis BEFORE widening the mint" —
DECODED, and it is not a per-name axis at all.** The brief (carrying r10uvm75's
R2) records that six names — `bld`, `common`, `cs`, `error_str`, `val`,
`uvm_random_seed_table_lookup` — appear TWICE in golden's `work@top` Nets
vector, and asks whether the axis is per-REFERENCING-CLASS or per-METHOD.
**Neither.** Ordering the vector by index shows golden repeats a **contiguous
33-net RUN verbatim**:

```
idx 10..42  uvm_start_uvm_declarations, uvm_aa_string_key, …, s_spaces
idx 43..75  uvm_start_uvm_declarations, uvm_aa_string_key, …, s_spaces   (identical)
```

Same names, same spans, same order, twice. All 33 are `uvm_pkg`'s package-scope
static VARIABLES and every one carries a `vpiTypespec` → `ref_typespec` — they
are the **declared-net** family, not the bare `vpiNetType:1` implicit wires
this law mints. The "six duplicated names" were simply the subset of that run
our side lacks entirely, so only they surfaced in a multiset difference; the
other 27 have one copy on each side and cancelled. The axis is a **repeated
declaration BLOCK**, i.e. `uvm_pkg` materialised twice into `work@top`.

`SEQ_TYPE_LOCK` and `SEQ_TYPE_REQ` each appear **EXACTLY ONCE**. One wire per
name is therefore safe here and **the mint was not widened** — decoded before
any code moved, as the brief required. The repeated block stays residue **R3**.

**RF-2. `SymbolKind::EnumValue` + "class scope" is NOT the gate, and a rule
written on it over-fires 24 times in SimpleUVM alone.** `classScopeEnumConst76`
returns **true** for `process::KILLED`, `uvm_mem_mam::GREEDY` and
`uvm_resource_types::PRI_HIGH` — they really are class-scope enum constants
referenced from out-of-body methods. Golden nets none of them, because they are
written **qualified**: the `::` carries its own scope and Surelog resolves the
name. Arm `b3_qual` is the purpose-built proof, and it is byte-identical
before and after. Without the `ScopedName` test this pass would have added 24
wires SimpleUVM's golden does not have — and Gate 4 would still have printed
`0 differing ROWS`, because SimpleUVM is `CMP_NOTEQUAL` in the baseline either
way. **The row gate cannot see this class of error; only the cell census and
the arm can.**

**RF-3. The brief's grid hypothesis "in-body (golden nets nothing in-body per
uvm75 b2)" is RIGHT, but for a reason worth stating: golden binds nothing AT
ALL in-body, not even the `enum_const`.** Arm `b2_inbody`'s four cells are
`1xNONE` each and its whole Nets vector is `c, r` — golden does not even hoist
the class property `m` there. The corpus agrees:
`uvm_report_catcher::process_report_catcher::CAUGHT` and
`uvm_reg_sequence::do_reg_item::LOCAL` are unqualified class-scope enum
constants in in-body methods and golden leaves both bare. Had the gate been
"an unresolvable class-scope enum constant", those cells would have moved.

**RF-4. The predictor over-fires on the surelog corpus by construction and says
so — but it is EXACT on uhdm2rtlil.** `ct76predict.py` flags any database that
declares a class-scope enum constant. It cannot see the unqualified half, the
out-of-body half, or the hoist half, all three of which are real gates with
measured negatives (`b3_qual`, `b2_inbody`, `v76_nohoist`). A flagged non-mover
is EXPECTED; an unflagged mover would be a FINDING, and there was none. On
uhdm2rtlil the count is **0 of 679** — a genuine impossibility proof for that
whole corpus, not an estimate.

**RF-5. The reason this head survived 75 passes is a one-line shape fact, and
it is worth writing down.** The hoist pool's pre-existing class-PROPERTY arm
tests `nv.symbol.getParentScope()->asSymbol().kind == SymbolKind::ClassType` —
a DIRECT-parent test. slang parents an `EnumValueSymbol` on the **enum's own
scope**, never on the `ClassType`, so that arm has never once seen an enum
constant, even though the mechanism it drives was exactly the right one. The
fix is not new machinery; it is the same pool reached through a scope WALK.

**RF-6. This pass changed a live arm of LAW C, and the change is
behaviour-identical BY MEASUREMENT, not by assertion.** LAW C's refusal arm
(`curSubOob9 && EnumValue && <inline lambda>`) now reads
`curSubOob9 && classScopeEnumConst76(nv.symbol)`. The helper is the lambda,
term for term and early-out for early-out, plus an explicit `EnumValue` test
that the arm's own `&&` already supplied. The proof it did not drift is Gate 5:
across 1632 databases and both corpora, the ONLY byte differences are the 7
bindings and 2 nets this law adds, with `REMOVED=0` everywhere.

---

## 8. RANKED RESIDUES

**R1 — `§ parensLessCallIsPathRefObj` on `item.process_id.status` (THE NEW
HEAD, and now on THREE rows).** Golden emits `ref_obj (…grant_queued_locks::
status)` @664:87 as the last element of the `hier_path (item.process_id.status)`;
we emit `method_func_call (status)`. It is now the head of **SimpleUVM default,
SimpleUVM testflags AND Scoreboard default** — one object, three rows.
r10svs2's `§ parensLessCallIsPathRefObj` / `§ parensLessFuncRefIsRefObj` already
own this family and found a counterexample to the naive law; the distinguisher
to find is why the identical uvm source line emits a `ref_obj` for
`process::status` here. *Highest-ranked: three rows, one object, and the
machinery is already named.*

**R2 — the other 30 golden-only `work@top` net names.** `p` (263:3),
`param_t`, `phase_runner_proc`, `req_item`, `sz`, `t`, `top`, `clp`, `addr`,
`local_addr`, `n`, `setting`, `m_override_info`, `m_type_overrides`,
`m_reg_process`, `m_uvm_applied_cl_{action,sev}`, `uvm_phase`, … Each is
another name family the hoist pool does not yet reach (block locals, formal
arguments, type names read as values). Same mechanism, same module; each needs
its own gate measured the way this one was.

**R3 — the repeated 33-net declaration BLOCK (RF-1's decode).** Golden emits
`uvm_pkg`'s 33 package-scope static variables into `work@top` **twice**, at
vector indices 10–42 and 43–75, identical names and spans. We emit the run
once. This is the declared-net (`ref_typespec`-carrying) family, not the
implicit-wire family, and it accounts for 12 of the 30 golden-only names in R2
by itself. *Its own pass: the question is what makes Surelog materialise the
package's declaration group a second time.*

**R4 — implicit-wire SPAN disagreement on the shared bindings.** Both sides
bind a wire of the right name but golden minted it at a different FIRST
reference (`clp`: golden @801:27, ours @339:3; `default_hdl_path`: golden
@388:7, ours @2085:7; `m_parent`: golden @1001:10, ours @1925:11). A
mint-ORDER law about `classPropRefs`' emission order, entirely pre-existing and
**unchanged by this pass** — this pass's own two wires land at golden's spans
exactly, and its two arms' vectors match golden's ORDER as well as its names.

**R5 — the arms' background head.** `b1`/`b3`/`b4` still CMP_FAIL on a
`class_defn (p76x::c76)` head that is byte-identical before and after. The
arms' own unrelated background (a `class_defn` field this repo does not yet
match), not this law's business.

**R6 — the surelog predictor's looseness (RF-4).** 574 of 953 flagged, 4 moved.
A sharper artifact predicate would require reading the reference side (scoped
vs bare, and whether the printing method is an out-of-body copy), which the
current one-pass indentation walk does not do. Named so the next pass does not
mistake a loose envelope for a tight one.

---

## 9. FILES

| file | role |
|---|---|
| `b1_oob.sv` | arm: OUT-OF-BODY, the positive (4 cells, incl. the package-scope control) |
| `b2_inbody.sv` | arm: IN-BODY, the gate's negative — same code, same names |
| `b3_qual.sv` | arm: QUALIFIED `::` reads — the over-fire guard |
| `b4_share.sv` | arm: one wire per NAME at the FIRST reference, + the property initializer |
| `v76_nohoist.sv` | arm: package compiled but never imported — Scoreboard's shape |
| `ct76arm.sh` | arm driver — golden + ours + cmp + dump-diff |
| `ct76cen.py` | design-wide REF-ACTUAL census by MULTISET, both sides, span-keyed |
| `ct76nets.py` | module Nets-vector census by NAME, both sides, with ORDER |
| `ct76predict.py` | artifact-based mover PREDICTION, run before the sweeps |
| `byteverify.sh` | Gate 5, with `SELFCHECK` + `SELFCHECK1` negative controls |
| `mv76.sh` | per-shape mover analysis by MULTISET |
| `rowheads.sh` | head depth for named rows |
| `ct8rows.sh` | whole-ROW gate vs the committed baselines |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | canaries + the audit of the canaries |
