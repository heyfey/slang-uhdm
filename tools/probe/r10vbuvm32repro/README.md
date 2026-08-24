# r10vbuvm32 — the ADVERSARIAL VERIFICATION of r10buvm32
## § scopedCallKeyIsAnyRegistration32v (the verifier's clause)

**Verdict: ACCEPT WITH FIX.**  Every headline number of `r10buvm32` reproduces
bit-for-bit on independently built binaries (pristine md5
`b4900a013105152c57a347bda1e33990`, implementer's patched
`1e399328f1007101d1fc61edc65a0544` — the SAME md5s the pass reported).  The
decoded law is right about WHAT Surelog keys on.  Its one-clause CODE GATE
(`f12 == <defining class name>`) is narrower than the key, and three shapes of
legal SystemVerilog that PRISTINE got right were degraded by it.  This
directory holds the arms that convict them and the clause that fixes them.

---

## 1. What the law gets right (independently re-measured)

`getTaskFunc` (Surelog `CompileExpression.cpp:349-436`) is keyed on the LITERAL
string `<first written segment>::<final identifier>`, built at `:5268` from
`SymName(Class_type_name)` and `SymName(Class_scope_name)`; the only `::` names
ever registered come from OUT-OF-BODY headers (`CompileStmt.cpp:2600` /
`:2692`, `SymName(Child(Class_type)) + "::" + SymName(suffixname)`).  Read from
the Surelog source, not carried forward.

Measured against golden, cell by cell, both views, on the pass's own arms and
on six new ones:

* `g32a1` 26 keys move TO golden / 0 away; `g32a2` 16/0; `g32a3` 14/0 and its
  elaborated view goes **46 cmp lines / 1 head -> 0 / 0, byte-EQUAL**.
* `vb32s1.sv` (a three-deep inheritance chain, a typedef of the BASE, a local
  variable shadowing the method name): 10 keys TO golden / 0 away, and the arm
  goes **42 / 1 -> 0 / 0 byte-EQUAL in BOTH views**.
* `vb32m1.sv` (the wide matrix: 4 qualifier spellings x statement / Rhs /
  if-cond / while-cond / argument / concat member / `void'()` cast / array-
  element Rhs / return / cont_assign / port actual, x function and TASK, x
  out-of-body, in-body, package-function and module homes, x two generic-class
  specializations): **43 keys TO golden in the def view, 28 in elab**, and
  exactly ONE key away — see §2.
* `vb32h1.sv` ($unit class, module-declared class, interface, program, generate
  loop with two instances, `always`, chained `C::m().n()`): 0 keys move at all —
  every call there writes its defining class's name and is correctly KEPT,
  including the three-segment `u32::this_type::uf32(2)` and
  `m32::this_type::mf32(5)`, which key on `u32::uf32` / `m32::mf32` and HIT.
  (That answers half of the pass's residue R1 from a golden.)
* `vb32e1.sv` (ESCAPED identifiers, a second specialization): the escaped
  qualifier that IS the defining class keeps its call; `this_type::` degrades.
* uvm111's `v111_b2.sv` / `v111_b7.sv`, each alone, both views: **30 / 1 -> 0 /
  0 byte-EQUAL**; the seven `r10v111repro/arms` compiled as a DIRECTORY move 4
  keys TO golden and 0 away in both views.

---

## 2. THE FIX — three golden HITS the one-clause gate threw away

`getTaskFunc` does not only match the defining class's own registration.  All
three of these were **pristine-right and patched-wrong**, read off golden:

| arm | written | why golden KEEPS the call | pristine | r10buvm32 | fixed |
|---|---|---|---|---|---|
| `vb32r1` R1/R2, `vb32m1` W33 | `pr32::hostr32::mcoll32(1)` | key `pr32::mcoll32`; `design->getPackage("pr32")` owns a FREE `mcoll32` (`:353-370`) | `func_call` | **`ref_obj`** | `func_call` |
| `vb32r2` S1 | `aliasq32::dv32(7)` | key `aliasq32::dv32`; a **$unit** class `aliasq32` registered it, found by the all-file-contents fallback (`:423-436`) | `func_call` | **`ref_obj`** | `func_call` |
| `vb32r3` D2 | `twin2_32::dfn2_32(2)` | same, through a WILDCARD-IMPORTED package (`getFuncFromPackage`, `:400-416`) | `func_call` | **`ref_obj`** | `func_call` |

`vb32r1` alone: **42 cmp lines / 1 head (pristine) -> 46 / 1 (r10buvm32) -> 0 /
0 byte-EQUAL (fixed)** in the default view, and the head r10buvm32 printed
there IS the R1 cell it broke.

**REACHABILITY IS PART OF THE RULE**, and `vb32r3` D1 is the cell that pins it:
the decoy class sits in a package the caller does NOT import, and **golden
DEGRADES**.  A first cut of this clause that scanned every syntax tree in the
design for out-of-body headers kept D1's call — the ONE away-from-golden key it
introduced — and was thrown away.  The shipped clause instead looks the written
qualifier up as a NAME from the scope that ENCLOSES the callee's own class:
`lookupName` walks that scope and its parents and honours its imports, so D2 is
found, D1 is not, and a class-internal `this_type` / `alias32` typedef is
invisible from there.

A second refutation is in the code as an owner test: slang's `Scope::find`
answers with INHERITED members, so without it `der32::bv32` (A5), `der32::bt32`
(W11), `d32::f32` / `d32::g32` (X1/X4) and `tder32::tbt32` all wrongly kept
their calls — golden degrades every one.  Measured, then gated.

The clause is asked ONLY when the written qualifier is not the defining class's
own name, which in the whole 956-database corpus happens for exactly one name
(`this_type::add_typewide_sequence`), so it changes no corpus cell.

---

## 3. Gates on the FIXED binary (`a361672e3a419b5f30c7f5acb97ae511`)

Both binaries built `-j 2`, md5'd separately, frozen `chmod 555` before any
sweep; every `cmds.txt` audited BY PATH — surelog 1523 of 1573 name the frozen
binary and 50 name none (golden-cache-only cells), uhdm2rtlil 1458 of 1462,
**zero name the main-tree binary** in any of the six sweeps.

* goldens **23 PASS / 0 FAIL** (pristine, implementer's patched AND fixed);
  `SLANG_UHDM=/bin/false` **23 FAIL**.
* surelog `--mode both`, 1588 rows: `937 CMP_EQUAL / 567 SLANG_REJECT /
  48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE /
  2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM` — identical to pristine.
  `ct8rows.sh` **0 differing rows** against `results/golden_surelog.csv`,
  against the pristine sweep AND against the implementer's patched sweep
  (status AND dump column).  **NO ROW CONVERTED**; `results/*.csv` untouched.
* uhdm2rtlil testflags and default: **679 / 50 / 2** each; `ct8rows.sh` 0
  differing rows against the committed baseline and against pristine.
* `byteverify.sh SELFCHECK=1`: **MOVERS 9 / 956** — the nine databases
  `PREDICTION.txt` named and nothing else (SELFCHECK 955/956) — and
  **0 / 1358** on uhdm2rtlil.  Fixed-vs-implementer's-patched: 2 files, both
  `SeqDriver`, **order-blind 0** (see §4).
* `movers32.sh`, order-blind: `26 / 52 / 26 / 52 / 26 / 26 / 52 / 52 / 26`
  lines — the pass's own numbers — and every line is the
  `this_type::add_typewide_sequence` call, its `seq_type` argument or the
  dropped `vpiFunction` (the residue is bare field labels of those objects;
  0 unattributed).
* `rowheads.sh`: SeqDriver default+testflags **46 -> 56**, BuildUVMPkg
  default+testflags **46 -> 56** with the head CLEARED (head decoded from the
  pristine and fixed cmp logs directly: `ref_obj (…this_type::
  add_typewide_sequence) @413:3-413:14` -> `class_var (…this_type::
  m_typewide_sequences) @496:12` with `unsupported_typespec`); SimpleUVM 17,
  Scoreboard/default 60, MiniAmiq 60, Earlgrey_0_1 90, Rggen 0 — unchanged.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2.sh` PASS on both
  corpora; `canaudit.sh canaries.sh ctcan2.sh` run FROM THIS DIRECTORY:
  **audited=29 UNCOVERED=0 FENCE-BREACH=0**.
* protected databases: InterfaceModPort / BlackParrotComplex / YosysOldOr
  byte-identical to pristine in both modes; SVSwitch `4842211c4030`; YosysVerx
  `6ccda350c24a`.
* the four slang-fenced tests are never dispatched and never spelled here.

---

## 4. Boundary — 4 configurations, pristine vs FIXED, over a COPY of the
whole `tools/probe` tree (no path filter, `.sv` and `.v`, list on fd 3,
children `</dev/null`, PROCESSED asserted, rc per cell)

```
MODE=file VIEW=def    PROCESSED=3591 LISTED=3591  DIFFER=9  REJECT 138/138
MODE=file VIEW=elab   PROCESSED=3591 LISTED=3591  DIFFER=9  REJECT 152/152
MODE=dir  VIEW=def    PROCESSED=1524 LISTED=1524  DIFFER=7  REJECT 121/121
MODE=dir  VIEW=elab   PROCESSED=1524 LISTED=1524  DIFFER=6  REJECT 127/127
```

`PRIS_REJECT == PATCHED_REJECT` in all four — no asymmetric reject.  Every
differing arm accounted for:

* `r10buvm32repro` (g32a1, g32a2, **g32a3**) and `r10vbuvm32repro` (mine) —
  the pass's and the verifier's own goldens, each re-measured against golden
  above.
* `r10v111repro/arms` — uvm111's binding face; byte-EQUAL to golden per file
  and 4 keys TO golden / 0 away as a directory.
* `r10uvm75repro`, `r10uvm76repro`, `r10v109repro`, `r10uvm88repro` — **COINS**,
  not movers: the SAME pristine binary run twice gives `raw=18 / 14 / 18 / 0`
  with `order-blind=0` every time, and pristine-vs-fixed is order-blind 0 on
  each.  `r10uvm88repro` differs in `dir/def` only.

**BIND WINDOWS**: every committed arm of § classArgBind12,
§ retNameRecvCollapseArgsBindLikeBody15, § collArgNamedBlkLocalNoBind15,
§ controlBodyNoBind28, § blkLocalSameCtrlDepthArgBinds57/64,
§ pkgVarBindsOnlyThroughInstance88, § formalDefaultBindsLikeBody13,
§ classInBodyRecvCallArgNoBind52, § superNewFormalBinds28,
§ newArrayArgNoBind16, § emptyArgSlotIntZero24, § writtenCallArgs16,
§ namedTfArgsFormalSlots4, uvm81's formal contest and sd10/sd12 `scopedReach`
lives in that tree and is byte-identical in all four configurations.  The
clause opens and closes no bind window: it only decides which of two EXISTING
objects a `::`-scoped class call becomes.

---

## 5. Findings on the pass as submitted

* **F1 (fixed here).**  Three registration shapes golden HITS were degraded —
  §2.  All three are judge-visible on purpose-built arms; none is corpus-
  reachable, which is why the corpus gates could not see them.
* **F2 (documentation).**  `BOUNDARY.txt` reports `PROCESSED=3584` for the
  file-mode arms and lists four differing ones.  The tree it copied predates
  `g32a3.sv`: with that file present the count is 3585 and `g32a3.sv` differs
  too (correctly — it is the arm whose elaborated view goes byte-EQUAL).  The
  pass's own third arm was therefore outside its boundary gate.  No
  consequence beyond the numbers.
* **F3 (nondeterminism).**  `SeqDriver` is a COIN as well as `Scoreboard`:
  fixed-vs-implementer's-patched differs on `default/SeqDriver` and
  `testflags/SeqDriver` byte-wise, and the order-blind (sorted, id-normalised)
  dump diff is **0** — while both differ from pristine by the same 52
  order-blind lines.  Any future attribution on that row must be order-blind.

---

## 6. Residues

* **R-V1** the ACCESS-PACKAGE and OWN-COMPONENT halves of Surelog's literal
  search are modelled by a name lookup from the callee class's enclosing scope.
  A registration reachable to Surelog through a chain that lookup does not walk
  (an instance-chain module definition, `CompileExpression.cpp:415-421`) is not
  covered; no arm reaches it and no corpus row contains one.
* **R-V2** an IN-BODY class method called as `pkg::C::m()` where `pkg` owns a
  free `m` is a golden `func_call` (`vb32r3` D3) and is a `ref_obj` on BOTH
  binaries: § classScopeCallOfOutOfBodyMethodIsFuncCall26's `outOfBlockIndex`
  gate, deliberately not touched here.
* **R-V3** the restored call's `vpiFunction` links slang's resolved subroutine,
  while golden links the function `getTaskFunc` actually found — visible on
  `vb32m1` W33 (`q32::coll32::qfree32` vs golden's `q32::qfree32`).  It is
  pristine's own binding, it is masked in every arm measured (`func_call::
  Compare` short-circuits on an already-visited LHS), and correcting it is a
  binding change, not a gate change.
* **R-V4** with an ESCAPED identifier in a middle segment the degraded
  ref_obj's span ends 4 columns before golden's (`vb32e1` line 40:
  ours `40:10-40:28`, golden `40:10-40:32`) — a Surelog column artefact on
  escaped tokens.  Spans are not read by `Compare`.
* **R-V5** method-body EMISSION COUNTS around a restored call differ from
  golden in both directions and with compile context (`vb32r1` `mcoll32`'s body
  3x vs golden 2x in BOTH pristine and fixed; `vb32r3` D2's body 2x per file,
  1x per directory) — the pass's own R5 family, untouched.
* the pass's R1 is now half-answered from a golden: a three-segment spelling
  whose FIRST segment is the defining class (`u32::this_type::uf32`) keys on
  `u32::uf32` and KEEPS its call (`vb32h1` H2/H5).  A first segment that is
  neither a package nor any class is still unmeasured.

---

## 7. Files

`vb32r1.sv` package-free-function key · `vb32r2.sv` $unit literal key ·
`vb32r3.sv` the reachability frontier (D1 unimported / D2 imported / D3 in-body)
· `vb32m1.sv` the wide shape x position x home matrix · `vb32h1.sv` homes,
chaining, three-segment keys · `vb32s1.sv` inheritance and shadowing ·
`vb32e1.sv` escaped identifiers and specializations · `varm32.sh` golden +
pristine + patched, both views, rc per command · `cells32v.py` the VIEW-GENERAL
multiset comparator (key = kind + span + the last two `::` segments of the
printed name; producer-specific fullname prefixes are never keyed) ·
`bound32.sh` `coin32.sh` `movers32.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh`
copied from the pass so this directory is self-sufficient.
