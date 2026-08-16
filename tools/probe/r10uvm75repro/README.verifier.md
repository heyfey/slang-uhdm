# r10uvm75 — ADVERSARIAL VERIFICATION of § withIterRefBindsHoistNet75

**VERDICT: PASS**, with two findings that change the WRITE-UP and one that
belongs in the residue ranking. No gate fails, no regression reaches either
corpus, and every number the implementer reported reproduced from binaries I
built myself.

| | |
|---|---|
| patch | `/tmp/r10uvm75.patch`, md5 `ac37f061a988860ab3ca0b0a327b5454` — **matches** |
| applied to | a FRESH worktree at **bd4b122** (`git worktree add --detach /tmp/wt_v75av bd4b122`), NOT the implementer's tree |
| my patched binary | `daa1e43880aaefb321072807a687abcb` — **bit-for-bit equal to the implementer's** |
| my pristine binary | `e641888879aa9127aef922b2ad2dda2f` — **bit-for-bit equal to the implementer's** |
| production surface | `src/ExprEmit.cpp`, `src/TaskFuncEmit.cpp`, `include/UhdmExporter.h` — and nothing else |
| `README.verifier.md` in the patch | **absent** — correctly left to the verifier |

Two independently-configured trees reproducing the implementer's md5s exactly is
the strongest form of Gate 1 available here: it means the build is
deterministic and that every number below was measured on the same code the
implementer measured, not on a lookalike.

---

## 1. FINDINGS

### F-1 — the ApbSlave non-mover explanation is FACTUALLY WRONG (write-up defect; outcome unaffected)

The write-up accounts for the 7 predicted-but-non-moving databases with:

> `ApbSlave` and `ArrayMethodIterator` have `with` clauses in bodies that are
> **not** out-of-body class methods.

For `ArrayMethodIterator` this is **true** — its single with-clause is in
`uvm_callbacks::get_all`, written **inside** the class (`dut.sv`), which is arm
`b2`'s shape appearing in the corpus. Good.

For **`ApbSlave` it is false.** `ApbSlave.sl` compiles
`../../../UVM/svunit_base/svunit_pkg.sv`, and both of that package's array-method
with-clauses sit in **OUT-OF-BODY** methods of classes declared in it:

```
svunit_base/svunit_testsuite.sv:85   function void svunit_testsuite::report();
svunit_base/svunit_testsuite.sv:93     ... = list_of_testcases.find() with (item.get_results() == PASS);

svunit_base/svunit_testrunner.sv:75  function void svunit_testrunner::report();
svunit_base/svunit_testrunner.sv:80    ... = list_of_suites.find() with (item.get_results() == PASS);
```

and `ApbSlave/testbench.sv` **imports** `svunit_pkg`. So the law's OOB half and
its hoist half are **both satisfied** in ApbSlave. The stated reason does not
hold.

**What actually holds ApbSlave still** is the pair of properties the write-up
does not name:

1. `find()` is written with **EMPTY PARENS** — there is no written iterator
   argument, so **site A cannot fire** (`al9->parameters.empty()`).
2. `item` occurs **only as the leading element of a hier_path**
   (`item.get_results()`) — the law's own **refusal rule** — so **site B cannot
   fire** either (those elements are built from text by `buildDottedHierPath`
   and never reach the `NamedValue` arm).

Measured, not argued:

```sh
grep -rnE "^\s*(function|task)[^;(]*\w+::\w+" ~/git-repos/Surelog/third_party/UVM/svunit_base/*.sv
uhdm-dump <ApbSlave golden>/golden.uhdm | grep -cE '\\_logic_net: \([^)]*\.item\)'   # 0
uhdm-dump <ApbSlave ours>/slang.uhdm    | grep -cE '\\_logic_net: \([^)]*\.item\)'   # 0
# identical pair of zeros for Scoreboard
```

Golden mints **zero** logic_nets named `item` in ApbSlave *and* in Scoreboard,
and we mint zero before and after. **The outcome is correct; the reason given is
not.** And the correct reason is worth more than the one claimed: it makes
ApbSlave and Scoreboard **corpus-scale positive controls for the REFUSAL RULE**
(hier_path element is not a reference) and for the empty-parens half of site A —
two gates the write-up otherwise evidences only on synthetic arms. `RF-1` is
still right that Scoreboard does not hoist `uvm_pkg`; it just is not the whole
reason Scoreboard binds 0 of 12.

**Action: correct the Gate-5 accounting paragraph.** No measurement changes.

### F-2 — the law's MODULE half (convention c) is stated too widely; the multi-importer shape is wrong on BOTH sides (PRE-EXISTING, widened here)

The write-up's convention (c) is *"only a module that HOISTS the class's
package"*, and arm `b3` establishes *"one wire per NAME"*. **Both arms have
exactly one module**, so neither can see what happens when **two** modules hoist
the same package. I built that cell.

| arm (mine) | shape | golden | ours PRISTINE | ours PATCHED |
|---|---|---|---|---|
| `w3_twomods` | `top` instantiates `sub`, both import the pkg; unresolvable name is the **ITERATOR** | **one** wire, `work@sub75w3.item`; ref binds there. `top` gets **none** | no wire; ref **unbound** | **two** wires (`sub` *and* `top`); ref binds `work@top75w3.item` — **the wrong module** |
| `w5_proptwomods` | identical shape, unresolvable name is a **CLASS PROPERTY**, **no `with` clause anywhere** | **one** wire, `work@sub75w5.m_cnt` | **two** wires; ref binds `work@top75w5.m_cnt` | **byte-identical to pristine** (476 cmp lines, 31 dump-content, both) |
| `w6_siblings` | two **SIBLING** importers, neither instantiating the other | **one** wire, in `a75w6` (**FIRST in source order**); `b75w6` gets none | **two** wires; ref binds `b75w6` (**the LAST**) | (unchanged — no `with` clause) |

`w5` is the load-bearing control: it contains **no `with` clause at all**, so
r10uvm75's code cannot run in it, and it is **identical on the pristine
binary**. Therefore:

* **This defect is PRE-EXISTING**, and it belongs to `bindHoistedClassPropRefs`
  (`src/ModuleEmit.cpp:5285`), which mints into `nets` for **every** hoisting
  module and does `cpr.ref->Actual_group(bind9)` unconditionally, so the **last**
  module processed wins a **singular** field.
* Golden's actual rule is **narrower** than the write-up's (c): the wire is
  minted in **exactly ONE** hoisting module — the first in source order (`w6`) /
  the child (`w3`,`w5`) — never in all of them.
* r10uvm75 does **not** introduce it, but it **routes a new NAME FAMILY through
  it**, so `w3` is the patch turning an *unbound* ref into a *wrongly-bound* one
  and adding a net golden does not have (cmp 912 → 916). On this synthetic shape
  the patch is marginally worse.

**Why no gate caught it:** no test in either corpus has two modules importing a
package that contains unresolvable out-of-body names. SimpleUVM has one `top`,
SeqDriver one `top_tb`, BuildUVMPkg **no module at all**. I verified all five
gates green independently, so this is **latent, not a regression**.

**It should be added to the ranked residues** — the write-up's `R2`/`R3` are both
about *which* wires exist and *where* they are minted; this is about *how many
modules* get one, and it has a measured, reproducible three-arm characterisation
ready for whoever takes it.

### F-3 — three empty product cells filled; all three came out CLEAN

The grid had no cell for these. I wrote and ran them; the patch holds in all
three, on both binaries.

| arm (mine) | why it was the risk | golden | pristine | patched |
|---|---|---|---|---|
| `w1_declared` | the hoisting module **already declares** `logic item; logic [3:0] node;`. This patch newly injects **iterator names into a binding pool keyed by NAME**, and `item`/`node`/`i` are among the most common identifiers in real RTL — if golden did not bind to a declared signal, the patch would silently rewire one | binds the iterator refs to the **DECLARED** nets, at the **declaration** spans (`25:9`, `26:15`); mints nothing extra; 4 nets | 2/5 cells agree | **5/5 agree**, 4 nets, no spurious mint |
| `w2_implicit` | the **IMPLICIT** iterator (`find()` with no written argument), where **site B is the FIRST reference of the name**. `b1`/`b3`/`b4` all write the argument, and corpus cell 4 (`find with (item == i)` @859:52) only ever *bound a wire another cell had already minted* — so **nothing in the implementer's grid shows that site B can MINT** | **mints** `work@top75w2.item` at the with-expression's span `20:32`; the line-19 `item.req` hier_path element mints nothing | 1/2 | **2/2 agree** |
| `w4_task` | an out-of-body class **TASK** (not function), with-clauses inside a `for` loop | mints `item`@18:19, `node`@19:26 | 1/4 | **4/4 agree** |

`w2` is the most useful of the three: it establishes the minting half of site B,
which the pass claims and the pass's own arms do not isolate. `w1` was the
highest-risk cell of the whole review and it is clean.

---

## 2. STATED GATE == CODE GATE — read literally, in my own tree

Verified line by line, not accepted:

* **Site A** (`src/ExprEmit.cpp:12390`) `if (inClassBodyEmit && classBodyHomePkg75)`.
  `classBodyHomePkg75` is set **only** under `inClassBodyEmit`
  (`TaskFuncEmit.cpp:2747`), nulled before each per-subroutine set and again after
  the loop (`:5494`), so `inClassBodyEmit` is a **redundant but harmless**
  conjunct. Stated == code.
* **Site B** (`:8247`) `else if (classBodyHomePkg75 && withIterSyms75.count(&nv.symbol))`,
  chained `else` off the `ClassType`-parent arm, inside
  `if (inClassBodyEmit && !ref->Actual_group())`. An already-bound ref is never
  re-recorded. Stated == code.
* **`withIterSyms75` is filled only from `getIteratorInfo().second`.** I read
  slang: `CallExpression::SystemCallInfo::getIteratorInfo()`
  (`source/ast/expressions/CallExpression.cpp:840`) returns `{nullptr,nullptr}`
  unless `extraInfo` holds an **`IteratorCallInfo`**. `randomize() with {...}`
  carries a *different* variant, so it **cannot structurally** populate the set —
  residue R4 is a different family by construction, not merely by observation.
  The `SymbolKind::Iterator` trap is real (`foreach` vars share the kind) and
  `b4` proves the gate avoids it.
* **The nullable-`homePkg` asymmetry is not a divergence.** The class-property
  arm pushes even with `hp9 == nullptr`, while the new sites require non-null —
  but `bindHoistedClassPropRefs` opens with `if (!cpr.homePkg || ...) continue;`,
  so the behaviour is identical. Checked because it looked like a gap; it is not.
* **`withIterSyms75` is never cleared** and grows for the whole export. Reviewed
  and cleared: it is consulted only under `classBodyHomePkg75`; the insert at
  `:12398` precedes the with-expression's emission at `:12400`, so ordering
  inside one call is correct; slang symbols are arena-lived, so no address
  recycling can create a false positive. I could not construct an over-fire.
* **No new minting machinery.** Both sites `push_back` into the pre-existing
  `classPropRefs`; `bindHoistedClassPropRefs` is untouched. Confirmed by reading
  the whole function.

---

## 3. THE FIVE GATES — run independently, my binaries

### Gate 1 — BUILD
Two fresh worktrees at bd4b122, configured and built at absolute paths with
`-j 2`; **`[100%] Built target slang_uhdm` reached** in both before any
measurement. md5s asserted **separately**, both **32-hex**, and both **equal to
the implementer's**. Pristine tree `git status --porcelain` **empty**; both
`rev-parse HEAD` = `bd4b122066a310aad661c6258cc50a18be9308e2`.

### Gate 2 — GOLDENS (`SLANG_UHDM` exported explicitly)
| run | PASS | FAIL |
|---|---|---|
| patched | **23** | 0 |
| pristine | **23** | 0 |
| `SLANG_UHDM=/bin/false` | 0 | **23** |

### Gate 3 — uhdm2rtlil, `--mode testflags --jobs 2`
`679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`; dump `496 match / 183 differ
/ 52`; `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` = **0 differing ROWS (0 row-sides)**
over 731. Identical on the pristine binary, and the two CSVs are **byte-identical
to each other**. I ran this **in the baseline's own mode** — the instrument
defect the implementer reported (a default-mode sweep against a testflags
baseline printing 1462 bogus differing rows) is real and I avoided it.

### Gate 4 — surelog, both modes, `--jobs 2`
| mode | CMP_EQUAL | CMP_NOTEQUAL | SURELOG_FAIL | DEFERRED |
|---|---|---|---|---|
| default | **469** | **11** | **25** | **5** |
| testflags | **465** | **8** | **23** | **5** |

`ct8rows.sh` vs `results/golden_surelog.csv` = **0 differing ROWS** over 1588,
patched **and** pristine. Per-mode STATUS **and** dump histograms identical
baseline → fresh (default `225 match / 244 differ / 325`; testflags
`165 / 300 / 329`). `GOLDEN_DEFER` verified **UNSET**.

### Gate 5 — BYTE VERIFIER, both corpora, both modes, vs my own pristine build

**Prediction FIRST, from the PRISTINE artifacts, before any comparison:**

| corpus | can move | with-calls | DUMP_FAIL |
|---|---|---|---|
| uhdm2rtlil | **0** of 679 | 0 | 0 |
| surelog | **11** of 953 | 181 | 0 |

Same 11 names as reported. Measured:

| corpus | paths | movers | SELFCHECK | SELFCHECK1 |
|---|---|---|---|---|
| uhdm2rtlil | 679 | **0** | 678/679 | **1** (= 0 real + 1 corrupted) |
| surelog | 953 | **4** | 952/953 | **5** (= 4 real + 1 corrupted) |

`PATH_SETS_IDENTICAL` both. The u2r `SELFCHECK1 = 1` is what separates *"nothing
moved"* from *"the instrument saw nothing"* — it is the reading that makes the
zero meaningful. I also confirmed the sweeps genuinely re-ran our side: 679
fresh `slang.uhdm` files written inside the sweep's own 12-second window (only
Surelog's golden side is cached).

**Movers per-shape by MULTISET** (`sed 1d`, whitespace-stripped, sorted):

| database | REMOVED | ADDED | size delta |
|---|---|---|---|
| default/SimpleUVM | **0** | 38 | **+279** |
| testflags/SimpleUVM | **0** | 38 | **+285** |
| default/SeqDriver | **0** | 38 | **+315** |
| testflags/SeqDriver | **0** | 38 | **+317** |

Every delta **nonzero** ⇒ by the MOVER RULE each is a proven real change (a zero
would have proven nothing). `REMOVED = 0` on all four ⇒ **pure addition**;
nothing pre-existing was rewritten anywhere in either corpus. The 38 shapes are
12 `vpiActual` + 14 logic_net prints + the two `vpiNet` entries and their
name/fullname/parent/nettype — exactly as reported.

**11 predicted / 4 moved.** I verified each of the 7 non-movers **at the source**
rather than accepting the explanation: `BuildUVMPkg` contains **no module at
all** (it compiles only `uvm_pkg.sv`) — the corpus instance of `v75_nohoist`;
`Scoreboard/testbench.sv:2` is `import svunit_pkg::*`, not `uvm_pkg` — RF-1
confirmed at source; `ArrayMethodIterator` is an **in-body** method — the corpus
instance of `b2`; `ApbSlave` is **F-1**, held by the refusal rule and empty
parens, not by the reason given.

---

## 4. THE GRID — every cell re-measured on my binaries

| arm | pristine | patched | reported | reproduced |
|---|---|---|---|---|
| `b1_oob` | CMP_FAIL 1468, dump 66; cells 1/4; nets 4 g / **2** | CMP_FAIL 1480, dump **46**; cells **4/4**; nets **4/4** names+spans+ORDER | ✓ | **exactly** |
| `b2_inbody` | **PASS_CMP**, dump 54, cells 4/4 (golden nets NOTHING) | **PASS_CMP**, dump 54, cells 4/4 | ✓ | **exactly** |
| `b3_share` | CMP_FAIL 2232, dump 90; cells 2/6 | CMP_FAIL 2248, dump **68**; cells **6/6**; `item`@16:16 shared by f1+f2, `node`@23:24 | ✓ | **exactly** |
| `b4_foreach` | CMP_FAIL 1440, dump 57; cells 3/4 | CMP_FAIL 1444, dump **48**; cells **4/4**; `item` netted, **`fv` NOT** (nets 3/3) | ✓ | **exactly** |
| `v75_nohoist` | **PASS_CMP**, dump 44 | **PASS_CMP**, dump 44 | ✓ | **exactly** |

Corpus (SimpleUVM/default), all re-measured:

| measure | pristine | patched | reported |
|---|---|---|---|
| `item`/`node` cell keys | 84, **20** disagreeing | 84, **8** disagreeing | ✓ |
| …this law's 12 | 12 disagree | **0** | ✓ |
| with-clause keys with arg BOUND | 0 of 12 | **7** | ✓ |
| in-body keys (`199:21`, `295:46`) | `act=None` | **still `act=None`** | ✓ |
| `work@top` nets | 210 | **212** | ✓ |
| `item`@664:28-32, `node`@1922:44-48 | absent | **byte-equal to golden** | ✓ |
| golden-only net names | 34 | **32** | ✓ |

**No new divergence:** the 8 residual disagreeing keys are a **strict subset** of
the pristine 20 (`comm -23` of the key sets is **empty**). They are hier_path
fullname divergences and two `io_decl` bindings — other families.

---

## 5. THE HEAD — confirmed, including the implementer's own caveat

| row | pristine | patched |
|---|---|---|
| SimpleUVM default | 17 / 1, head `logic_net (work@top.item)` **id:197766** @664:28-32 | 17 / 1, head `logic_net (work@top.SEQ_TYPE_LOCK)` **id:197767** @664:54-67 |
| SimpleUVM testflags | 17 / 1, same | 17 / 1, same advance |
| Scoreboard default | 26 / 1 | cmp **byte-identical** |
| SeqDriver, BuildUVMPkg | 43 / 1, 94 / 1 | cmps **byte-identical** (SeqDriver moved bytes; head unchanged) |

`work@top.item` occurs **0 times** in the patched cmp. `197766 + 1 = 197767`, and
in golden's `work@top` Nets vector `item` and `SEQ_TYPE_LOCK` sit at **adjacent
indices 138 and 139** — so "golden's very next wire" is verified structurally,
not just by id arithmetic.

**The implementer's plain statement is correct and I confirm it: the line count
did not fall.** The targeted object is gone and a different object of the same
`logic_net`-vs-`<null>` shape stands behind it. A stable 17 here is not a stable
head, and the write-up says so without being asked.

---

## 6. BOUNDARIES

* **§ builtinRecvIndexedStepIsBitSelect74** — all six arms
  (`b1_idxkind`, `b2_position`, `b3_context`, `b4_foldidx`, `v74_edge`,
  `v74_edge2`) run on **both** binaries are **byte-identical**: same cmp lines,
  same dump content, same hunk counts; `b1`/`b2` stay `PASS_CMP`. **Holds.**
* **§ inheritedNameBindsPkgFn72** — this pass binds a `ref_obj`'s `vpiActual`
  and creates no call; untouched.
* **Live passes — NO COLLISION, tested rather than argued.** All three patches
  co-apply to a clean bd4b122 worktree:
  `git apply --check /tmp/r10uvm75.patch /tmp/r10sd6.patch /tmp/r10earl46.patch` → **rc 0**.
  Regions are disjoint: r10uvm75 takes `UhdmExporter.h@3866` + `ExprEmit.cpp` +
  `TaskFuncEmit.cpp`; r10earl46 takes `UhdmExporter.h@1142` + `ModuleEmit.cpp`;
  r10sd6 takes `ModuleEmit.cpp` only.
* **Naming-context memory** — no naming policy touched; the patch binds
  `vpiActual` and adds nets, and `VpiFullName` on the new wires comes from the
  pre-existing `bindHoistedClassPropRefs`.

## 7. CANARIES

| check | result |
|---|---|
| `canaries.sh` vs `gate_uhdm2rtlil.csv` | ok=**9** changed=**0** absent=**0** unknown-names=**25** (printed expectation) |
| `canaries.sh` vs `golden_surelog.csv` | ok=**52** changed=**0** absent=**0** unknown-names=**8** (printed expectation) |
| `canaudit.sh` | audited=**31** **UNCOVERED=0 FENCE-BREACH=0** |
| `ctcan2.sh` u2r, `EXPECT_UNKNOWN=6` | ok=1 changed=**0**, unknown-patterns=6 — PASS |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1` | ok=58 changed=**0**, unknown-patterns=1 — PASS |

Brief-protected names checked **BY NAME**, whole row, vs the committed baseline:
`InterfaceModPort`, `BlackParrotComplex`, `SimpleUVM`, `Scoreboard`, `SeqDriver`,
`BuildUVMPkg`, `ApbSlave`, `ArrayMethodIterator` — **all 16 rows IDENTICAL**. The
four slang-fenced names (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) are dispatched by **no driver** in this directory (asserted by
`canaudit.sh`); they appear only as ordinary corpus rows, unchanged.

---

## 8. RANKED RESIDUES (verifier's ranking)

* **V-R1 — the class-scope ENUM CONSTANT implicit wire (THE NEW HEAD).** Agrees
  with the implementer's R1. `SEQ_TYPE_LOCK`@664:54 (+`SEQ_TYPE_REQ`@763:40),
  same module, same statement, adjacent in golden's Nets vector. One object away.
* **V-R2 — the MULTI-IMPORTER law (F-2), NEW, not in the implementer's list.**
  Golden mints in exactly ONE hoisting module (first in source order / the
  child); we mint in every one and bind the singular `vpiActual` to the last.
  Pre-existing in `bindHoistedClassPropRefs`, corpus-invisible, and now reachable
  from one more name family. Characterised by `w3_twomods` / `w5_proptwomods` /
  `w6_siblings`, with `w5` proving it pre-dates this pass. Rank it **above** the
  write-up's R2/R3: it is a *wrong* object, not a *missing* or *mis-spanned* one.
* **V-R3 — the other 32 golden-only `work@top` net names** (implementer's R2).
  Six are DUPLICATED in golden's vector, which no one-per-name model explains;
  needs its own decode. Note V-R2 is a plausible mechanism for at least some of
  that duplication and the two should be looked at together.
* **V-R4 — implicit-wire SPAN disagreement on the shared bindings** (implementer's
  R3). Wholly pre-existing; this pass's two wires land at golden's spans exactly.
* **V-R5 — Scoreboard's `status` head, 26 lines** (implementer's R5). Parens-less
  call family. F-1 sharpens its context: Scoreboard *does* hoist `svunit_pkg`,
  which *does* contain out-of-body methods with with-clauses, so the design-level
  distinguisher search should start from the refusal rule, not from "no hoist".
* **V-R6 — `randomize() with {...}` calls we do not emit** (implementer's R4).
  Structurally a different variant of `SystemCallInfo::extraInfo`; confirmed it
  cannot reach this law's sites.
* **V-R7 — the arms' background `class_defn` head** (implementer's R6).
  Byte-identical before and after; genuinely unrelated.

---

## 9. WHAT I ADDED

`w1_declared.sv`, `w2_implicit.sv`, `w3_twomods.sv`, `w4_task.sv`,
`w5_proptwomods.sv`, `w6_siblings.sv` — the six verifier arms above. They run
under the implementer's own `ct75arm.sh` / `ct75cells.py` / `ct75nets.py` with no
changes, e.g.:

```sh
SLANG_UHDM=/tmp/wt_v75av/build/slang-uhdm \
  tools/probe/r10uvm75repro/ct75arm.sh w3_twomods.sv /tmp/wd_w3
python3 tools/probe/r10uvm75repro/ct75nets.py /tmp/wd_w3/g.dump /tmp/wd_w3/o.dump
```

`w5_proptwomods.sv` is the one to keep pointed at: it contains **no `with`
clause**, so it is a permanent, r10uvm75-independent witness for V-R2 and will
keep reporting the defect long after this pass is history.

## 10. WHAT I DID NOT CHANGE

**No production line was modified.** The verified patch re-cut carries the
implementer's production hunks **byte-for-byte** and adds only this file and the
six arms. Both F-1 (a paragraph) and F-2 (a residue entry) are write-up
corrections; neither is a reason to hold the pass, because neither changes a
measured number and neither is a regression that reaches a corpus.
