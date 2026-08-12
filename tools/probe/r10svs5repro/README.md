# r10svs5 — THE CLOCKING BLOCK IS A PATH COMPONENT THAT SLANG THREW AWAY

**Result, up front: the SVSwitch head the brief set as the target is CLEARED, in
BOTH modes.** SVSwitch stays `CMP_NOTEQUAL` — **it is NOT a conversion** — and the
successor head is a **different cluster** (a missing `array_var` for an
array-of-virtual-interface class property, quoted in §2). Zero rows moved on
either corpus; **7 byte movers on the surelog corpus, 6 of them law content that
lands on EXACTLY golden's per-shape counts, and the 7th has MULTISET DISTANCE 0**
(a build-order relocation, proved in §6.3).

```
head @01deff4 (the brief's target, 74 cmp lines, both modes)
  LHS golden  hier_path: (input_intf.cb.data_status), line:53:11, endln:53:36
              \_ref_obj: (input_intf), line:53:22, endln:53:24
              \_ref_obj: (cb),         line:53:22, endln:53:24
              \_ref_obj: (data_status),line:53:25, endln:53:36
  RHS ours    hier_path: (input_intf.data_status)  — `cb` gone from the NAME and
                                                     from the ELEMENT LIST
head on the shipped binary (8542 cmp lines, both modes)  — CLEARED, replaced by
  LHS golden  class_defn: (work@Environment) … \_array_var: (work@Environment::output_intf), line:17:31
  RHS ours    class_defn: (work@Environment) … \_class_var: (work@Environment::drvr), line:19:10
              i.e. golden emits an `array_var` for `virtual output_interface.OP
              output_intf[4]` (Environemnt.sv:17) and WE EMIT NOTHING for it.
              PRE-EXISTING: golden 4 such lines, pristine 0, shipped 0.
```

* **ONE LAW, `§ vifClockingPathComponent5`, ONE predicate, THREE call sites.**
* **GRID: 45 cells across 5 arms**, both sides read at own child depth.
  **EQ 18 → 40**; the five non-EQ cells are each classified and ranked (§3, §7).
* **SVSwitch instruments, all three reported separately and never conflated:**
  cmp head depth 74 → 8542 (**not a distance** — Compare dumps the whole
  successor subtree), dump content `+/-` 2548 → 2051, and the alignment-free
  **MULTISET DISTANCE 1926 → 1485 (−441)**.
* **FIVE GATES GREEN** (§5): goldens 23/0 with the `/bin/false` control at 0/23;
  u2r 679/50/2 + dump 496/183/52 + **0 differing rows**; surelog 467/13 and
  463/10 + dump 225/165 + **0 differing rows**; byte verifier **u2r 0/679**,
  **surelog 7/953** with both negative controls firing.
* **CANARIES: all green, `changed=0 absent=0` everywhere**, and
  **InterfaceModPort — the live conversion in this pass's blast radius — was
  checked FIRST and holds `CMP_EQUAL` in both modes** (§5.6).
* **FOUR REFUTATIONS**, three of them against this pass's own earlier text (§4):
  the brief's "probably the ClockVar resolution collapsing member access" is only
  half the mechanism; a macro-spelled path CONVERGES rather than declining; a
  comment or newline before the recovered component CONVERGES; and the brief's
  reach warning ("a clocking/modport law can reach every interface-bearing test")
  is **REFUTED by measurement** — the 41-test interface cluster did not move one
  byte, because the law is scoped to the VIRTUAL-interface base and arm a2 proves
  real handles were already right.

Base commit `01deff4`, branch `auto5h`.
Pristine binary md5 **`2e9d37d3a78a57b4010043cc2abebbca`** (worktree
`r10svs5pris`, clean at 01deff4, `strings | grep -c vifCollapsedComponents5` = 0).
Shipped binary md5 **`8b1765a433cd50f40a16588b3a9fbb7a`**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script in
this directory.

---

## 1. THE LAW, in the form a future pass can grep for

```
§ vifClockingPathComponent5   src/ExprEmit.cpp   (predicate + SITE 1/2/3)
                              include/UhdmExporter.h   (declaration)
```

> A dotted reference through a **VIRTUAL INTERFACE** keeps **every path component
> the source wrote**. `vif.cb.data_status` is a **THREE-element** `hier_path`
> named `vif.cb.data_status`: base `ref_obj (vif)`, a **BARE** intermediate
> `ref_obj (cb)` (`vpiName` only — no `vpiFullName`), then the leaf. The same
> holds for a nested interface INSTANCE inside the interface
> (`vfull.sub.icb.isig` is FOUR elements). A **REAL** interface handle — module
> instance, interface port, modport port, hierarchical `u_mid.m.cb.ds` — was
> **already correct** and is untouched.

**WHAT IS LOST AND WHY** (both halves verified in slang's own source, quoted):

```
slang/source/ast/Lookup.cpp:1438  void Lookup::selectChild(const Type& virtualInterface, …
                          :1467      auto& vit = …as<VirtualInterfaceType>();
                          :1468      if (vit.modport) result.found = vit.modport;
                          :1470      else            result.found = &vit.iface;
                          :1485      lookupDownward(nameParts, unused, context, …, result);
slang/source/ast/Expression.cpp:1228  // If we were accessed via a virtual interface wrap the
                                      // result up in a member access expression …
                               :1232  expr = comp.emplace<MemberAccessExpression>(
                                          *expr->type, *accessViaExpr, *symbol, result.nameRange);
```

ONE lookup consumes the WHOLE selector list, and the result is wrapped in ONE
`MemberAccessExpression` over the vif expression. So `vif.cb.data_status` reaches
the exporter as `MemberAccess(member = ClockVar data_status, value = NamedValue
vif)`: the components in between are **absent from the AST chain**, and the
hier_path built from that chain came out with 2 elements. The brief guessed
"probably the ClockVar resolution collapsing member access" — the ClockVar half is
right, but it is not specific to clocking blocks: the SAME collapse eats a nested
interface INSTANCE (arm a4 f7, `vfull.sub.isig`), which is why the predicate walks
SCOPES and not clock-var-ness (§4.1).

### STATED GATE == CODE GATE

The predicate is `UhdmExporter::vifCollapsedComponents5` (src/ExprEmit.cpp). Each
clause below is one clause of the code, in the code's order, with the arm cell
that EXECUTES it:

| # | stated gate | code | executed by |
| --- | --- | --- | --- |
| 1 | the accessed VALUE's canonical type is a virtual interface | `cvt.kind != SymbolKind::VirtualInterfaceType → false` | a2 (11 real handles decline; d1..d11) |
| 2 | the scope walk from the leaf reaches THAT vif's interface body through nothing but named CLOCKING BLOCKs and nested interface INSTANCE bodies | `ClockingBlock` / `InstanceBody` allowlist, everything else `return false`; `sc == stop` required | a3 e5/e6 (modport member declines), a4 f6/f7 (instance body fires) |
| 3 | at least one component was collected | `if (!reached \|\| names.empty()) return false` | a1 c7/c9/c10 (nothing collapsed → untouched) |
| 4 | the written text before the leaf token is EXACTLY `<comp>.` per component | `rawText(SourceRange(start, cursor)) != nm + "." → false`, plus the leaf-token text check | **a5 g1 declines; a5 g2/g3/g4 fire** |

Clause 4 is the one that makes the recovered SPANS measurements: they are computed
by walking BACKWARD from the leaf's name token, so an unexpected character in that
window would make them lies. **Arm a5 executes it in both directions** (§3.5).

The three call sites mint the elements themselves, because the three hier_path
builders disagree on what an element is:

| site | builder | shape it owns | live arm cell |
| --- | --- | --- | --- |
| SITE 1 | the `MemberAccess` `chain` arm in `emitExpr` | plain dotted path, lvalue and rvalue | a1 c1–c6, a3 e4/e7/e9, a4 f3/f4/f5/f6/f7, a5 g0/g2/g3/g4 |
| SITE 2 | `emitMixedHierPath` | a SELECT ON THE BASE below the collapsed component | a4 f2 `varr[0].cb.ds` |
| SITE 3 | the `RangeSelect`-over-`MemberAccess` arm | `vif.cb.din[3:0] <= 4'h5` | a3 e2 |

Two details that are law, not incident, and both were measured:

* the **BARE** intermediate element. Golden gives the recovered component a
  `vpiName` and **no** `vpiFullName`; only the leaf takes a dotted/scoped one
  (a4 f2, quoted in §3.4). `BaseClass::Compare` reads `VpiType`, `VpiName`,
  `VpiDefName` and **never** `VpiFullName` (UHDM/templates/BaseClass.cpp:163-187,
  quoted in §6.2), so this half buys nothing in cmp and everything in bytes — and
  bytes are what GATE 5 measures.
* the **LVALUE BASE ANCHOR**. On an lvalue path golden puts the base ref_obj and
  the recovered component **BOTH on the recovered component's token**
  (`ref_obj (vif) 53:22-53:24` + `ref_obj (cb) 53:22-53:24`), while on an rvalue
  the base sits on its own token (`vif 42:9-42:12`, `cb 42:13-42:15`). The brief
  said "measure, do not assume, whether that is general" — **it is general**, and
  it is the same lvalue/rvalue split the builders already applied to written
  paths; the only change is which token counts as "the first member".

---

## 2. THE HEAD, before and after (both modes, shipped binary)

`svsgen.sh` drives **the harness itself** (`scripts/verify_golden.py --corpus
surelog --mode both --filter '^SVSwitch$'`), so the argv on both sides are the
ones the committed rows were produced with.

```
                     pristine 2e9d37d3      shipped 8b1765a4
row (default)        CMP_NOTEQUAL           CMP_NOTEQUAL     <- NOT a conversion
row (testflags)      CMP_NOTEQUAL           CMP_NOTEQUAL
cmp head depth       74                     8542             <- a SUBTREE, not a distance
dump content +/-     2548                   2051
MULTISET DISTANCE    1926                   1485             (−441)
o.dump lines         25402                  25567            (golden 25318)
```

The successor head is quoted in the banner above: golden's `class_defn
work@Environment` carries an `array_var` for `virtual output_interface.OP
output_intf[4]` and ours does not (`grep -c "array_var: (work@Environment::output_intf)"`
→ **golden 4, pristine 0, shipped 0**). It is **pre-existing and out of this
pass's scope** — an array-of-virtual-interface *declaration* shape, not a path
component. It is NOT evidence about distance: head depth in this campaign went
78 → 25 → 74 → 8542 while the corpus converged monotonically.

---

## 3. THE GRID, cell for cell

Five arms, 45 cells. `EQ` = ours is byte-identical to golden for that path
(elements, kinds, names, spans). Read with `gridread.sh g.dump o.dump`, which
walks the indent column so a `hier_path` printed as a `|vpiParent:` back-pointer
is not double counted.

```
arm                      cells   EQ pristine   EQ shipped
a1_kinds   access kind      11        3            11
a2_handles the handle       11       11            11
a3_vifshape select/shape    10        4             8
a4_base    the base          8        0             6
a5_guards  clause (4)        5        0             4
                          ----     ----          ----
                            45       18            40
```

### 3.1 a1 — ACCESS KIND, through a vif in a class (the witness shape)

| cell | source | golden | pristine | shipped |
| --- | --- | --- | --- | --- |
| c1 | `vif.cb.ds <= 1;` (nonblocking write — THE WITNESS) | `hp(vif.cb.ds)` `{vif 38:9-11}{cb 38:9-11}{ds 38:12-14}` | `hp(vif.ds)` 2 elems | **EQ** |
| c2 | `vif.cb.din <= 8'h5a;` vector clockvar | 3 elems, base+`cb` on the `cb` token | 2 elems | **EQ** |
| c3 | `r = vif.cb.dout;` read | `{vif 42:9-12}{cb 42:13-15}{…::dout 42:16-20}` | 2 elems | **EQ** |
| c4 | `r = vif.cb.dout + 8'h1;` in an expression | 3 elems | 2 elems | **EQ** |
| c5 | `if (vif.cb.rdy)` condition | 3 elems | 2 elems | **EQ** |
| c6 | `$display("%0d", vif.cb.dout);` call argument | 3 elems | 2 elems | **EQ** |
| c7 | `@(vif.cb);` event control ON the clocking block | `hp(vif.cb)` 2 elems, leaf scoped | EQ | **EQ** (untouched — `cb` IS the leaf) |
| c8 | `@(vif.cb.rdy);` event control on a clockvar | 3 elems | 2 elems | **EQ** |
| c9 | `@(posedge vif.clock);` NEGATIVE CONTROL | `hp(vif.clock)` 2 elems | EQ | **EQ** (unchanged) |
| c10 | `vif.reset <= 1;` plain modport signal, NEGATIVE CONTROL | `hp(vif.reset)` 2 elems | EQ | **EQ** (unchanged) |
| c11 | `b = r[vif.cb.dout];` clockvar as an INDEX | `hp(vif.cb.dout) 60:11-22`, 3 elems | 2 elems | **EQ** |

Arm residue after the patch: dump `+/-` 132 → **24**, and none of the 24 is a path
element — they are golden-only `class_typespec`/`logic_net` objects plus the
pre-existing index-ref fullname residue
`work@drv_a::go::r::dout` (golden) vs `work@drv_a::go.r::dout` (ours), which
another cluster owns.

### 3.2 a2 — THE HANDLE: every non-vif way to reach a clocking block

**All ELEVEN paths were ALREADY byte-identical to golden at pristine, and the
patched dump is byte-identical to the pristine dump (`diff | grep -c '^[<>]'` =
0).** This is the arm that scopes the law:

```
d1  p.cb.ds     <= 1;   modport PORT               EQ  (base+cb both 32:7-32:9)
d2  p.cb2.ds    <= 1;   second clocking block      EQ
d3  q.ds        <= 1;   modport with NO clocking    EQ  (2 elems, control)
d4  i_b.cb.ds   <= 1;   module-scope INSTANCE       EQ
d5  i_b.cb2.din <= 8'h1;                            EQ
d6  i_b.ds      <= 1;   same signal RAW, control    EQ  (2 elems)
d7  @(i_b.cb);          event control               EQ
d8  w.cb.din    <= 8'h3; plain interface PORT       EQ
d9  r = i_b.cb.dout;    rvalue through an instance  EQ
d10 u_mid.m.cb.ds <= 1; DEEP hierarchy, 4 elems     EQ  (u_mid+m both 71:11-12)
d11 r = u_mid.m.clock;  deep NON-clocking, control  EQ
```

### 3.3 a3 — THE SHAPES of the vif access

| cell | source | golden | shipped |
| --- | --- | --- | --- |
| e1 | `vif.cb.din[3] <= 1;` element select | `hp(vif.cb.din[3])` `{vif 41:9-11}{cb 41:9-11}{bit_select …vif.cb.din[3]::din}` | **DECLINED — still `hp(vif.din[3])`. Residue R2** |
| e2 | `vif.cb.din[3:0] <= 4'h5;` range select | 3 elems + `part_select …vif.cb.din[3:0]::din` | **EQ** (SITE 3) |
| e3 | `r = vif.cb.dout[2];` rvalue element select | 3 elems + `bit_select` | **DECLINED. Residue R2** |
| e4 | `vfull.cb.ds <= 1;` vif with NO modport | 3 elems | **EQ** |
| e5 | `vnocb.ds <= 1;` modport WITHOUT clocking | 2 elems | **EQ** (declines, correctly) |
| e6 | `vif.raw <= 1;` plain modport member | 2 elems | **EQ** (declines, correctly) |
| e7 | `vif.cb.alias_ds <= 1;` RENAMED clocking item | 3 elems, leaf `alias_ds` | **EQ** |
| e8 | `vfull.ds <= 1;` same signal raw | 2 elems | **EQ** |
| e9 | `vfull.cb.din <= 8'h2;` and through the cb, same task | 3 elems | **EQ** |
| e10 | `@(vfull.cb);` | 2 elems | **EQ** |

e5/e6 are the load-bearing negative controls for clause (2): a
`ModportPortSymbol`'s parent scope **is the modport**, which is not on the
allowlist, so the walk declines before it can invent a component.

### 3.4 a4 — THE BASE

| cell | source | golden | shipped |
| --- | --- | --- | --- |
| f1 | `this.vif.cb.ds <= 1;` | **GOLDEN IS DEFECTIVE**: `hp(this.vif.cb)` — it drops the LEAF `ds` and keeps `cb` | DECLINED (`chain.size()==1` gate). `hp(this.vif.ds)`. **Residue R1 — do not imitate** |
| f2 | `varr[0].cb.ds <= 1;` array-of-vif base | `{bit_select varr[0] 39:5-9}{ref_obj (cb) 39:13-15, vpiName:cb, NO fullname}{ref_obj (varr[0].cb.ds) 39:16-18}` | **EQ** (SITE 2, after the fullname correction in §4.3) |
| f3 | `a.cb.ds <= 1;` vif task ARGUMENT | 3 elems | **EQ** |
| f4 | `loc.cb.din <= 8'h7;` vif LOCAL to the task | 3 elems | **EQ** |
| f5 | `vif.cb.din <= 8'h8;` class property (witness shape) | 3 elems | **EQ** |
| f6 | `vfull.sub.icb.isig <= 1;` nested INSTANCE then its cb | **FOUR** elems `{vfull 49:11-14}{sub 49:11-14}{icb 49:15-18}{isig 49:19-23}` | **EQ — two components recovered in one reference** |
| f7 | `vfull.sub.isig <= 1;` nested instance only | 3 elems | **EQ** |
| f8 | `@(posedge this.vif.clock);` NEGATIVE CONTROL | golden emits **no** hier_path at 53 | unchanged from pristine (`hp(this.vif.clock)`); pre-existing extra shape, not this law |

### 3.5 a5 — THE GUARD ARM: clause (4) executed in both directions

```
g0  vif.cb.ds <= 1;              tight spelling            FIRES   EQ
g1  vif . cb . ds <= 1;          spaces around the dots    DECLINES  (golden 3 elems,
                                                            ours 2) -- Residue R3
g2  vif./*c*/cb.din <= 8'h1;     comment BEFORE the comp   FIRES   EQ
g3  vif.\n   cb.din <= 8'h2;     newline inside the path   FIRES   EQ  (golden and
                                                            ours both: vif 39:8-10,
                                                            cb 39:8-10, din 39:11-14)
g4  `CBSEL(vif) <= 1;            whole path via a MACRO    FIRES   EQ  (both tools
                                                            put every element at the
                                                            macro CALL site, 41:9-14)
```

Arm dump `+/-` 95 → **35**; the 35 are g1's cell plus golden-only class objects.

---

## 4. REFUTATIONS — of the brief, and of this pass's own earlier text

### 4.1 the brief's mechanism is half right, and the half it misses widens the law

The brief: *"where slang LOSES the `cb` component (probably the ClockVar
resolution collapsing member access to the underlying signal)"*. The collapse is
real but it is **not about clock vars**: `Expression.cpp:1228` wraps **whatever
the vif lookup found** in one MemberAccess, so a **nested interface INSTANCE** is
eaten identically (a4 f7 `vfull.sub.isig`, one recovered component; a4 f6
`vfull.sub.icb.isig`, TWO). A predicate written on clock-var-ness would have
missed both. The code therefore walks SCOPES with an allowlist.

### 4.2 the brief's REACH WARNING is REFUTED by measurement

The brief called this *"the strongest reach warning of this campaign"* and pointed
at the memory's 41-test interface DIFF cluster and the modport `vpiDirection`
distinguisher. **Neither moved.** Arm a2 is why: every non-virtual handle —
module-scope instance, plain interface port, modport port, deep hierarchical —
was **already byte-identical to golden**, so there was nothing for the law to do
there, and clause (1) keeps it out. The corpus agrees: `InterfaceModPort`,
`InterfaceBinding`, `InterfaceModExp`, `SimpleInterface`, `GenerateInterface` and
`BlackParrotComplex` are all row-identical, and the byte verifier finds **0
movers on u2r and exactly 7 on surelog**. A reach warning that measurement
refutes is worth recording as loudly as one it confirms.

### 4.3 THREE corrections this pass made to its OWN in-flight text

| # | what an earlier revision of the code comment said | status |
| --- | --- | --- |
| C1 | SITE 2's live cells are "a3 e1/e3" (`vif.cb.din[3]`, `r = vif.cb.dout[2]`) | **FALSE, and the cells prove it.** Those are `ElementSelect` over `MemberAccess` over a NamedValue base, which the `ElementSelect` case routes to the single-dim `chain` arm — `emitMixedHierPath` is only entered when the chain bottoms out in ANOTHER select. e1/e3 were **still 2-element** on the first patched binary. SITE 2's real live cell is **a4 f2**. Comment corrected AT the site; e1/e3 recorded as R2 with their measured ZERO corpus reach. |
| C2 | "a path spelled with a macro formal DECLINES rather than shipping guessed spans; residue R4" | **REFUTED — it CONVERGES.** a5 g4: `` `CBSEL(vif) `` with body `H.cb.ds` fires and is byte-identical to golden. "R4" is deleted, not renumbered. |
| C3 | "a comment, a space **or** an escaped identifier between the dots would make them LIES" | **TOO BROAD.** Only the window `<comp>.` immediately left of each recovered component is read; a comment or newline to the LEFT of the component is invisible and those cells CONVERGE (a5 g2/g3). The space case is the one that really declines (a5 g1). |
| C4 | (code defect, not text) SITE 2 gave the recovered component a dotted `vpiFullName` (`varr[0].cb`) where golden leaves it BARE | **FIXED before landing**, `Comp::vifIns5` + the `if (comp.vifIns5)` arm. a4 f2 went from "name converged, one extra fullname line" to **byte-identical to golden**; SVSwitch's dump lost the 4 corresponding lines (25571 → 25567 ours). |

**And a refutation the brief invited:** *"if it predicts NONE beyond SVSwitch,
distrust the census"*. The census predicted movers beyond SVSwitch and named them
(§6.1) — `SeqDriver` and `SimpleUVM` — and both moved, so the census is not being
distrusted here; what it OVER-predicted is the `<UVM-LIBRARY>` bucket (§6.1).

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

```
/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs5
[ 88%] Linking CXX executable slang-uhdm          <- the link line, waited for
[100%] Built target slang_uhdm
md5(build/slang-uhdm) = 8b1765a433cd50f40a16588b3a9fbb7a   (32 hex, asserted separately)
pristine worktree r10svs5pris, clean at 01deff4:
md5 = 2e9d37d3a78a57b4010043cc2abebbca ; strings|grep -c vifCollapsedComponents5 = 0
```

Reproducibility datum: the final comment-only edit produced a **bit-identical**
binary (`8b1765a4…` before and after), and `find src include -newer build/slang-uhdm`
is empty on the shipped tree.

### GATE 2 — GOLDENS, run EARLY and again on the shipped binary

```
SLANG_UHDM=<shipped> tests/check_goldens.sh   ->  23 PASS / 0 FAIL
SLANG_UHDM=/bin/false tests/check_goldens.sh  ->   0 PASS / 23 FAIL   (control fires)
```

**Their evidentiary value here is NEAR ZERO and this pass says so out loud:**
`grep -lE 'clocking_block|modport' tests/golden/*.dump` matches **0 of 23**, and
only **1 of 23** contains a `hier_path` at all. The goldens prove this law did not
break the unrelated corpus; they cannot confirm it.

### GATE 3 — u2r `testflags --jobs 2`

```
679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL
dump: 496 match / 183 differ / 52 blank
WHOLE-ROW diff vs results/gate_uhdm2rtlil.csv: 0 differing ROWS (0 row-sides)
PRISTINE control sweep, judged the same way:  0 differing ROWS
```

### GATE 4 — surelog `--mode both --jobs 2` (`GOLDEN_DEFER` left UNSET)

```
default   : 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED / 284 SLANG_REJECT / 25 SURELOG_FAIL
testflags : 463 CMP_EQUAL / 10 CMP_NOTEQUAL / 5 DEFERRED / 286 SLANG_REJECT / 23 SURELOG_FAIL
            + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM
dump: default 225 match / 242 differ / 327 blank
      testflags 165 match / 298 differ / 331 blank
WHOLE-ROW diff vs results/golden_surelog.csv: 0 differing ROWS
PRISTINE control sweep: 0 differing ROWS
```

**SVSwitch did NOT convert** — both rows stay
`SVSwitch,{default,testflags},CMP_NOTEQUAL,decompile:,,`, byte-identical to the
committed baseline. No `results/*.csv` was touched by this pass.

### GATE 5 — BYTE VERIFIER, both corpora, against a PRISTINE 01deff4 built here

`byteverify.sh` with `SELFCHECK=1 SELFCHECK1=1`:

```
u2r     : PATH_SETS_IDENTICAL (679 paths)  MOVERS: 0 / 679
          SELFCHECK 678/679 flagged        SELFCHECK1 = 1
surelog : PATH_SETS_IDENTICAL (953 paths)  MOVERS: 7 / 953
          SELFCHECK 952/953 flagged        SELFCHECK1 = 8  (= the 7 real movers + the
                                           1 deliberately corrupted file)
```

### 5.6 CANARIES — both scripts, both corpora, `EXPECT_UNKNOWN` declared

```
u2r      canaries.sh  ok=8   changed=0 absent=0   (25 unknown-names = surelog-only canaries)
         ctcan2.sh    ok=1   changed=0 absent=0   unknown-patterns=6 = EXPECT_UNKNOWN=6
surelog  canaries.sh  ok=52  changed=0 absent=0   (7 unknown-names = u2r-only canaries)
         ctcan2.sh    ok=58  changed=0 absent=0   unknown-patterns=1 = EXPECT_UNKNOWN=1
canaudit.sh canaries.sh ctcan2.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0
```

`ctcan2.sh` on the surelog pair reads **ok=58**, matching r10svs2's F4 correction
(the brief's "=1" is the u2r figure).

**BY NAME — InterfaceModPort FIRST, as the brief requires, because it is a LIVE
CONVERSION with interface content squarely in this law's blast radius:**

```
InterfaceModPort    default   CMP_EQUAL / differ    == committed baseline   OK
InterfaceModPort    testflags CMP_EQUAL / differ    == committed baseline   OK
BlackParrotComplex  default   CMP_EQUAL / differ    == committed baseline   OK
BlackParrotComplex  testflags CMP_EQUAL / differ    == committed baseline   OK
```

The four slang-fenced tests (`UnsignedParam`, `HierPathEval`, `FileLocalParam`,
`TopParam`) were never dispatched; `canaudit.sh` reports `FENCE-BREACH=0`.

---

## 6. REACH: the census, the prediction, and the 7 movers

### 6.1 CENSUS FIRST, THEN PREDICT (`census.sh`, run over `third_party/UVM` too)

```
NAMED CLOCKING BLOCKS declared in the corpora: 50
`.<cb>.<id>` use sites: 1187
   650 <UVM-LIBRARY>   168 Ibex(SLANG_REJECT)  102 Tnoc(SLANG_REJECT)
    77 Opentitan(SLANG_REJECT)  34 wav-lpddr-hw(NO ROW)  33 SVSwitch(CMP_NOTEQUAL)
    30 ariane(NO ROW)  29 OVMSwitch(REJECT)  23 UVMSwitch(REJECT)
    15 SimpleInterface(REJECT)  8 Driver(REJECT)  6 SeqDriver(CMP_NOTEQUAL)
     4 SimpleUVM(CMP_NOTEQUAL)  2 Monitor(REJECT)  2 CoresSweRVMP(SURELOG_FAIL)
     2 CoresSweRV(SURELOG_FAIL)  1 Icarus(REJECT)  1 GenerateInterface(REJECT)
   uhdm2rtlil: ZERO sites in any test  ->  predict 0 u2r movers
```

**PREDICTION, written before the sweeps: exactly three tests can move — SVSwitch,
SeqDriver, SimpleUVM — i.e. 6 mode-rows, plus whatever the `<UVM-LIBRARY>` bucket
reaches (BuildUVMPkg, Scoreboard, and the same three).** Everything else either
`SLANG_REJECT`s (no database to move), `SURELOG_FAIL`s, or has no row.

**OUTCOME: 6 law-content movers, exactly the predicted three tests × 2 modes**
(Scoreboard/testflags is `SLANG_REJECT`, so Scoreboard can only ever contribute
one row), **plus 1 zero-content mover.** The over-prediction was the
`<UVM-LIBRARY>` bucket, and the reason is now measured: all 650 of those sites
live under `third_party/UVM/*/examples/` (`apb_master.sv`,
`wishbone/driver.sv`, …) and the tests compile `uvm-1.2/src/uvm_pkg.sv` +
`svunit_base/svunit_pkg.sv` only — the examples are never on the command line
(quoted from `cmds.txt` in §6.3). 206 of the hits are the clocking block `mck`
and 162 are `.mem.` matches that are not clocking blocks at all in those files.
**Census gap recorded honestly:** `census.sh` greps clocking-block names only, so
the NESTED-INTERFACE-INSTANCE sub-shape (a4 f6/f7) is NOT in it; GATE 5 bounds it
post hoc — every added element in every mover is named `cb`, so no corpus mover
carries that sub-shape.

### 6.2 what gates cmp, quoted, so the law's two halves are not confused

```
UHDM/templates/BaseClass.cpp:163  int32_t BaseClass::Compare(…) {
                             :170    if ((r = VpiType() - rhs->VpiType()) != 0) …
                             :175    if ((r = VpiName().compare(rhs->VpiName())) != 0) …
                             :180    if ((r = VpiDefName().compare(rhs->VpiDefName())) != 0) …
```

`VpiFullName` and every line/column field are read by **no** Compare method; the
element LIST and the hier_path `VpiName` are what gate. The span and fullname work
in this pass is therefore **byte** convergence, and GATE 5 is where it is judged.

### 6.3 THE 7 MOVERS, per shape, by MULTISET, ADDED and REMOVED separately

`msmovers.sh <golden> <pristine-ours> <patched-ours>` (indent preserved) plus
`shapecount5.sh` (per-shape `grep -Ec`, both a span-free and a span-keyed key).

| mover | shapes moved | CONV | DIV | ADDED | REMOVED |
| --- | --- | --- | --- | --- | --- |
| `SVSwitch` default & testflags (identical) | 284 | 281 | 3 | 156 | 118 |
| `SeqDriver` default & testflags | 62 | 61 | 1 | 28 | 22 |
| `SimpleUVM` default & testflags | 40 | 35 | 5 | 19 | 15 |
| `Scoreboard` default | **0** | 0 | 0 | **0** | **0** |

**Every DIVERGED line is accounted for, and none is a defect:**

* SVSwitch's 3 and SeqDriver's 1 are `|vpiParent:` / `|vpiActual:` — the generic
  marker lines the standing brief names as NON-ATTRIBUTABLE absorbers (they move
  because the object count moved).
* SimpleUVM's 5 are 2 markers plus **3 keys of ONE object**: golden puts
  `hier_path (m_if.cb.result)` at the **macro DEFINITION site 116:15**, both our
  binaries put it at the **call site 33:21** (`uvm_info(… m_if.cb.result …)`,
  testbench.sv:33). Span-keyed that reads `G=0 P=0 A=1 DIVERGED`; keyed on the
  NAME — the field Compare reads — it is `|vpiName:m_if.cb.result  G=1 P=0 A=1`,
  **CONVERGED**. Pre-existing macro-location residue (campaign memory:
  "map through `getFullyOriginalLoc`"), ranked R4.

**Per-shape, against golden (`shapecount5.sh`; G=golden P=pristine A=patched):**

```
SVSwitch (both modes)
  hier_path NAME <h>.<mid>.<leaf>        G=34   P=1    A=34    <- 1 -> EXACTLY golden
  bare middle element |vpiName:cb        G=42   P=9    A=42    <- EXACTLY golden
  ref_obj: (cb) WITH span (span-keyed)   G=33   P=0    A=33    <- EXACTLY golden, spans included
  hier_path NAME <h>.<leaf> (2-comp)     G=72   P=102  A=73    <- +30 -> +1, and the +1 is
                                                                  PRE-EXISTING (below)
  CONTROL vpiSigned / class_typespec / vpiTypedefAlias:  P == A on all three
SeqDriver (both modes)
  bare middle element |vpiName:cb        G=927  P=897  A=903
  ref_obj: (cb) span-keyed               G=126  P=120  A=126   <- and the SET is identical
                                                                  to golden's (comm: empty
                                                                  both ways)
SimpleUVM (both modes)
  bare middle element |vpiName:cb        G=516  P=512  A=516
  ref_obj: (cb) span-keyed               G=76   P=72   A=76    <- set-diff is exactly ONE
                                                                  line: golden 116:20 vs
                                                                  ours 33:26 (the macro site)
Scoreboard default
  EVERY law row: P == A.  No law shape moved.
```

SVSwitch's residual 2-component `+1` is `|vpiName:input_intf.clock`, golden 4 /
ours 5: we emit one extra at `line:63:16` — and **pristine emits it too** (`grep -c`
= 3 occurrences in both), so it is pre-existing and not this law's.

**The Scoreboard mover, explained rather than waved at.** Its dump is
1 096 799 lines on both binaries, `msdist.sh p.dump a.dump` reports **MULTISET
DISTANCE 0** (golden-only 0, ours-only 0), and `diff` shows 92 lines = ONE 46-line
block of `\_function:`/`\_task:` entries **relocated**. Determinism controls:

```
same binary, same argv, two runs   -> md5 identical (53380a2face5 both), and
                                      identical to the sweep's database
pristine binary                    -> different byte layout, multiset distance 0
```

So this is the campaign's documented **build-dependent object ordering**
(pointer-keyed map iteration / arena address order), reproducible per binary and
invisible to `Compare` — its CSV row is byte-identical to the committed baseline.
It is reported as a mover because the byte verifier is honest, not because
anything about it changed semantically.

---

## 7. RANKED RESIDUES

| # | residue | measured reach | why not fixed here |
| --- | --- | --- | --- |
| **R1** | `this.vif.cb.sig` — **GOLDEN ITSELF drops the LEAF** (`hp(this.vif.cb)`, a4 f1) while we drop the middle | SVSwitch has no such site; corpus reach 0 measured | imitating a defective golden is how a campaign gets a distinguisher it cannot ever explain. `chain.size()==1` declines deliberately. Needs its own pass with a decision about whether to match a bug. |
| **R2** | element-select over a clockvar (`vif.cb.din[3]`, `r = vif.cb.dout[2]`) stays 2-element (a3 e1/e3) | **ZERO in both corpora**: the only `.<cb>.<sig>[` sites are 12 lines in `ariane` (NO ROW), through a real interface port | the fix is a 4th call site in the single-dim `ElementSelect` chain arm. Zero reach does not justify a new site in this pass's blast radius; a future pass that needs it has the arm and the exact cells. |
| **R3** | `vif . cb . ds` (spaces around the dots) declines and stays 2-element (a5 g1) | corpus writes paths tight; 0 sites | the spans are computed by walking backward from the leaf token; a trivia-aware backward scan is a real change to span computation and would need its own arm set (this is r10svs2's F2 residue in a new place). **Declining is not being right** — it is refusing to guess. |
| **R4** | a path inside a MACRO ARGUMENT gets the CALL-site span where golden gives the macro DEFINITION site (`m_if.cb.result` 33:21 vs 116:15) | 1 object in SimpleUVM ×2 modes, 2 in SeqDriver's copies | pre-existing (pristine has the same span on the 2-element form); it is the known `getFullyOriginalLoc` mapping gap, and it is span-only — `Compare` does not read it. |
| **R5** | the SUCCESSOR HEAD: no `array_var` for `virtual output_interface.OP output_intf[4]` (golden 4 lines, ours 0) | SVSwitch, both modes | a declaration-shape cluster, not a path-component one. Named here so the next pass on SVSwitch starts with it instead of re-deriving it. |
| **R6** | `@(posedge this.vif.clock)` — we emit a `hier_path` where golden emits none (a4 f8) | 1 arm cell; no corpus site found | pre-existing, unchanged, and a `this`-rooted shape that R1's pass should take with it. |

---

## 8. WHAT CHANGED IN THE EMITTER

Two files. Every hunk carries the `§ vifClockingPathComponent5` tag, and every
tag names the arm cell that measured it.

```
include/UhdmExporter.h   +  forward decl of MemberAccessExpression
                         +  vifCollapsedComponents5 declaration + the law summary
src/ExprEmit.cpp         +  the predicate (with the slang citations and the gate,
                            clause by clause)
                         +  SITE 1  the MemberAccess `chain` arm  (name, elements,
                            lvalue base anchor)
                         +  SITE 2  emitMixedHierPath  (comps splice, Comp::vifIns5,
                            the BARE recovered component)
                         +  SITE 3  the RangeSelect arm  (name, elements, base anchor)
```

## 9. THE SCRIPTS IN THIS DIRECTORY

| script | what it is for |
| --- | --- |
| `svsgen.sh` | SVSwitch both modes THROUGH THE HARNESS; prints dumps, `+/-`, cmp head depth |
| `svsarm.sh` | one arm `.sv` through surelog + slang, `-nobuiltin` both sides |
| `gridread.sh` | reads the GRID: every `hier_path` as one line of (name, span, element kinds+spans), indent-walked |
| `census.sh` | the blast-radius census, over `third_party/UVM` too, intersected with the row sets |
| `msdist.sh` | alignment-free MULTISET dump distance (whitespace-preserving) |
| `msmovers.sh` | 3-way per-shape mover attribution, ADDED/REMOVED reported separately |
| `shapecount5.sh` | per-shape `grep -Ec` for THIS law's shapes, span-free and span-keyed, with the alias-churn controls |
| `mvdump.sh` | dumps a mover's golden / pristine / patched databases into one directory |
| `byteverify.sh` | GATE 5, with `SELFCHECK` and `SELFCHECK1` |
| `a1_kinds.sv` `a2_handles.sv` `a3_vifshape.sv` `a4_base.sv` `a5_guards.sv` | the 45-cell grid |
