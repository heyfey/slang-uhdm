# r10svs5 — ADVERSARIAL VERIFICATION of `§ vifClockingPathComponent5`

**VERDICT: PASS.** Every number in the implementer's report reproduces on a
binary I built myself from a fresh 01deff4 + `/tmp/r10svs5.patch` — including
both md5s, bit for bit. The brief's head IS cleared in both modes, the five gates
are green, and the strongest safety property I could test holds: **across the
shipped 45-cell grid AND 29 cells I built to fill its empty products, there is
not one case where the law invents a path component golden does not have.**
Every disagreement that survives is an UNDER-emission (a deliberate decline) or a
pre-existing shape.

Eight findings follow. **None is a behavioural defect in the landed code.** Four
are accuracy defects in the *record* (a stated gate rationale that measurement
refutes, a refutation that was itself over-broad, a census explanation that is
factually wrong, one mislabelled cell), three are empty-product coverage gaps
that turn into ranked residues, one is an ops nit. The two that matter are **F1**
(the `chain.size()==1` gate is justified by a claim my cell refutes) and **F2**
(escaped identifiers decline, and the in-flight comment that said so was deleted
as "too broad" without ever building the cell).

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

---

## 0. WHAT I BUILT AND WHERE

| | path |
| --- | --- |
| verifier worktree (patched) | `/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs5v` |
| verifier worktree (PRISTINE 01deff4) | `/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/r10svs5vpris` |
| patched binary | `.../r10svs5v/build/slang-uhdm` md5 **`8b1765a433cd50f40a16588b3a9fbb7a`** |
| pristine binary | `.../r10svs5vpris/build/slang-uhdm` md5 **`2e9d37d3a78a57b4010043cc2abebbca`** |

Both md5s are **identical to the implementer's**, from an independent `cmake`
configure and an independent 6-way build — so the build is bit-reproducible and
the two reports are talking about the same two binaries.

```
$ git apply --check --verbose /tmp/r10svs5.patch     -> clean, 17 files
$ md5sum /tmp/r10svs5.patch
1071302d8d16de03d31a213c3e49982d  (98525 bytes)   == claimed
$ grep -E "Linking|Built target slang_uhdm$" /tmp/v5build.log
[100%] Linking CXX executable slang-uhdm
[100%] Built target slang_uhdm                       <- link line waited for
$ strings <patched> | grep -c vifCollapsedComponents5   -> 2
$ strings <pristine> | grep -c vifCollapsedComponents5  -> 0
$ (in r10svs5vpris) git status --porcelain               -> empty, HEAD 01deff4
$ (in r10svs5v)     find src include -newer build/slang-uhdm  -> empty
```

## 1. PATCH HYGIENE AND THE PRIOR ART — clean, and provably so

```
$ git apply --stat /tmp/r10svs5.patch
 include/UhdmExporter.h  | 11 +      src/ExprEmit.cpp | 240 +
 tools/probe/r10svs5repro/{README.md, 5 arms, 8 scripts}
 17 files changed, 1746 insertions(+), 1 deletion(-)
```

The strongest hygiene statement available, and I measured it rather than reading
the § tags:

```
$ diff <pristine ExprEmit.cpp> <patched ExprEmit.cpp>
  added lines: 239
  REMOVED lines: exactly ONE  ->  "            if (baseSelMode && !comp.isBase) {"
$ diff <pristine UhdmExporter.h> <patched UhdmExporter.h>
  added 11 lines, removed 0
```

That one removed line is replaced by
`if (comp.vifIns5) { /*nothing*/ } else if (baseSelMode && !comp.isBase) {`, and
`Comp::vifIns5` has an in-class `= false` initialiser and is set **only** in the
new splice. So for every pre-existing component the else-chain is
byte-for-byte the old predicate. **A semantic change to `§ thisPathSelectErased4`,
`§ parensLessCallIsPathRefObj` or `§ concatIdxDecompile29` is not merely absent —
with one deleted line and no edits inside their bodies it is unreachable.**
(`emitThisPathSelectErased` is still called *before* the touched arm, at
ExprEmit.cpp:12753.) `results/*.csv` untouched in every tree;
`tools/probe/r10svs5repro/msdist.sh` is **byte-identical** to the pinned
`7c7eaa6:tools/probe/r10uvm55repro/msdist.sh`.

### the mechanism citations are real

I read them in slang and UHDM rather than trusting the quote:

```
slang/source/ast/Lookup.cpp:1438  void Lookup::selectChild(const Type& virtualInterface, …
                          :1467      auto& vit = virtualInterface.getCanonicalType().as<VirtualInterfaceType>();
                          :1468-70   if (vit.modport) result.found = vit.modport; else result.found = &vit.iface;
                          :1485      lookupDownward(nameParts, unused, context, LookupFlags::None, result);
slang/source/ast/Expression.cpp:1228 // If we were accessed via a virtual interface wrap the result up …
                              :1232  expr = comp.emplace<MemberAccessExpression>(*expr->type, *accessViaExpr,
                                                                                *symbol, result.nameRange);
UHDM/templates/BaseClass.cpp:163-187  Compare reads VpiType, VpiName, VpiDefName — and NOTHING else
                                      (grep for VpiFullName in any Compare: no hits)
```

`result.nameRange` is the **leaf name's** range, which is why
`ma.sourceRange.end() - member.name.size()` lands on the leaf token — and the
code text-checks that anyway. Underflow is safe: `rawText` returns `""` when
`start > end`, so every backward-walk arithmetic failure DECLINES.

## 2. THE HEAD — cleared, verified with my own `uhdm-cmp`

```
$ uhdm-cmp <golden> <PRISTINE ours>     head depth = 74
  LHS: hier_path: (input_intf.cb.data_status), id:1479, line:53:11, endln:53:36
       \_ref_obj: (input_intf) 53:22-53:24   \_ref_obj: (cb) 53:22-53:24   …
$ uhdm-cmp <golden> <PATCHED  ours>     head depth = 8542
  LHS: class_defn: (work@Environment), … Environemnt.sv, line:12:1, endln:146:9
```

The pristine head is the brief's target verbatim; the patched head is a
different object. Successor head confirmed pre-existing:
`grep -c 'array_var: (work@Environment::output_intf)'` → **g=4 p=0 a=0**.

SVSwitch instruments, all three, never conflated — **all reproduce exactly**:

| instrument | pristine | patched | claimed |
| --- | --- | --- | --- |
| cmp head depth (a SUBTREE) | 74 | 8542 | 74 → 8542 ✓ |
| dump content `+/-` | 2548 | 2051 | ✓ |
| MULTISET DISTANCE | 1926 | 1485 | 1926 → 1485 ✓ |
| ours dump lines (golden 25318) | 25402 | 25567 | ✓ |

**SVSwitch did NOT convert**, re-run by me through the harness:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,      == results/golden_surelog.csv
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,    == results/golden_surelog.csv
```

## 3. THE FIVE GATES, run independently

| gate | my measurement | claimed |
| --- | --- | --- |
| 1 BUILD | link line waited for; md5s asserted separately, 32 hex; grep-check 2 / 0 | ✓ identical md5s |
| 2 GOLDENS | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → **0 PASS / 23 FAIL** | ✓ |
| 2′ golden evidentiary value | `grep -lE 'clocking_block\|modport' tests/golden/*.dump` → **0 of 23**; `hier_path` → **1 of 23** | ✓ stated honestly |
| 3 u2r testflags j2 | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496/183/52**; whole-row diff vs `results/gate_uhdm2rtlil.csv` = **0** (pristine control also 0) | ✓ |
| 4 surelog both j2 | default **467/13/5/284/25**; testflags **463/10/5/286/23** + 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM; dump **225 / 165**; whole-row diff vs `results/golden_surelog.csv` = **0** both binaries; patched-vs-pristine CSV diff = 0 | ✓ |
| 5 BYTE VERIFIER | u2r **0 / 679**, SELFCHECK 678/679, SELFCHECK1 **1**; surelog **7 / 953**, SELFCHECK 952/953, SELFCHECK1 **8**; PATH_SETS_IDENTICAL both | ✓ |

`GOLDEN_DEFER` left **UNSET** (echoed before dispatch). No `results/*.csv` written.
The four slang-fenced tests were never dispatched.

### canaries — InterfaceModPort FIRST, as the brief requires

```
InterfaceModPort    default   CMP_EQUAL/differ   == committed baseline
InterfaceModPort    testflags CMP_EQUAL/differ   == committed baseline
BlackParrotComplex  both      CMP_EQUAL/differ   == committed baseline
u2r      canaries.sh ok=8   changed=0 absent=0   (25 unknown-names, u2r-side)
         ctcan2.sh   ok=1   changed=0 absent=0   unknown-patterns=6 = EXPECT_UNKNOWN
surelog  canaries.sh ok=52  changed=0 absent=0   (7 unknown-names)
         ctcan2.sh   ok=58  changed=0 absent=0   unknown-patterns=1 = EXPECT_UNKNOWN
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
```

All exactly as reported, including the `ctcan2 ok=58` correction.

## 4. THE MOVERS — priced per shape, by MULTISET, ADDED/REMOVED separate

Byte verifier named the same 7 databases:

```
MOVER ./default/Scoreboard   MOVER ./default/SeqDriver   MOVER ./default/SimpleUVM
MOVER ./default/SVSwitch     MOVER ./testflags/{SeqDriver,SimpleUVM,SVSwitch}
```

`msmovers.sh` (whole-line key, indentation preserved):

| mover | shapes moved | CONV | DIV | ADDED | REMOVED | claimed |
| --- | --- | --- | --- | --- | --- | --- |
| SVSwitch ×2 modes | 284 | 281 | 3 | 156 | 118 | ✓ |
| SeqDriver ×2 | 62 | 61 | 1 | 28 | 22 | ✓ |
| SimpleUVM ×2 | 40 | 35 | 5 | 19 | 15 | ✓ |
| Scoreboard default | **0** | 0 | 0 | 0 | 0 | ✓ |

Every DIVERGED line accounted for and none a defect: SVSwitch's 3 and
SeqDriver's 1 are `|vpiParent:` / `|vpiActual:` absorbers; SimpleUVM's 5 are 2
absorbers plus **3 span-keys of ONE object** —
`hier_path (m_if.cb.result)` at golden's macro-definition site 116:15 vs our
call site 33:21. Name-keyed (the field Compare reads) I measured
`|vpiName:m_if.cb.result` **G=1 P=0 A=1 → CONVERGED**.

Per shape against golden (`shapecount5.sh`, G/P/A) — **every quoted figure exact**:

```
SVSwitch   3-component hier_path NAME     G=34   P=1    A=34
           bare middle  |vpiName:cb       G=42   P=9    A=42
           ref_obj: (cb) span-keyed       G=33   P=0    A=33
           2-component NAME               G=72   P=102  A=73
SeqDriver  |vpiName:cb                    G=927  P=897  A=903
           ref_obj: (cb) span-keyed       G=126  P=120  A=126   set-diff vs golden: 0 / 0
SimpleUVM  |vpiName:cb                    G=516  P=512  A=516
           ref_obj: (cb) span-keyed       G=76   P=72   A=76    set-diff: exactly 1 (116:20 vs 33:26)
Scoreboard every law row                  P == A
CONTROLS vpiSigned / class_typespec / vpiTypedefAlias:  P == A on ALL FOUR movers
```

The build-dependent UVM alias churn did **not** fire — I confirm the control row.

**Scoreboard is a zero-content mover, and I re-derived the determinism claim
rather than accepting it:**

```
msdist.sh <pristine ours> <patched ours>   ->  MULTISET DISTANCE 0  (1096799 lines both)
diff                                        ->  92 lines = ONE relocated block of \_task:/\_function:
patched binary, THREE independent runs      ->  md5 53380a2face5… identical every time
pristine binary                             ->  3c9f5dabc9f1… , distance 0
```

Documented build-dependent object ordering, invisible to `Compare`. Its CSV row
is byte-identical to baseline.

Census reproduced exactly: **50 named clocking blocks, 1187 `.<cb>.<id>` sites**,
same per-test distribution, `third_party/UVM` included.

---

## 5. EMPTY PRODUCT CELLS — 29 cells I built that the grid does not contain

New arms in this directory: `v1_direction.sv`, `v2_spelling.sv`, `v3_handle.sv`,
`v4_site2.sv`, `v5_nested.sv`. Read with the implementer's own `gridread.sh`.
**19 of 29 EQ; the other 10 are DECLINES or pre-existing shapes — no over-fire.**

### v1 — the DIRECTION axis the brief demanded and the grid never built (6/6 EQ)

| cell | source | result |
| --- | --- | --- |
| v1a/a2 | `vif.cb.io <= 1;` / `r = vif.cb.io;` — **INOUT** clocking direction | **EQ** both |
| v1b | `input #2 skewed;` explicit per-item **SKEW**, read | **EQ** |
| v1c | `@(vif.cb.io);` event control on an inout clockvar | **EQ** |
| v1d | a **packed 2-D** clockvar `inout pk;`, whole-object write | **EQ** |
| v1e | `vif.cb.o <= ##2 1;` intra-assignment **clocking drive** | **EQ** |

The law is direction-blind, as it should be. This is the brief's named axis and
it comes back clean.

### v2 — SPELLING: clause (4) read character by character (2/6 EQ, 4 new declines)

| cell | source | golden | ours |
| --- | --- | --- | --- |
| v2a | `vif.cb.ds <= 1;` control | 3 elems | **EQ** |
| v2b | `vif.\cb2 .ds <= 1;` **ESCAPED clocking-block name** | `hp(vif.cb2.ds)` 3 elems, base+`cb2` both 41:9-41:18 | `hp(vif.ds)` 2 — **DECLINES** |
| v2c | `vif.cb.\esc$ds <= 1;` **ESCAPED clocking-item name** | `hp(vif.cb.esc$ds)` 3 elems | `hp(vif.esc$ds)` 2 — **DECLINES** |
| v2d | `vif.cb.`LEAF <= 1;` leaf from a **MACRO** | 3 elems | 2 — **DECLINES** |
| v2e | ``vif.`COMP .ds <= 1;`` component from a **MACRO** | 3 elems | 2 — **DECLINES** |
| v2f | `` `VIA(vif) <= 8'h1; `` macro spells handle→leaf | 3 elems | **EQ** |

### v3 — HANDLE KIND / the clause-(2) allowlist (3/6 EQ)

| cell | source | golden | ours |
| --- | --- | --- | --- |
| v3a | `vfull.cb.ds <= 1;` control | 3 elems | **EQ** |
| v3b | `vtd.cb.ds <= 1;` through a **TYPEDEF'd** `virtual iface` type | 3 elems | **EQ** — clause (1)'s canonical test proven through a typedef |
| v3c | `vstat.cb.ds <= 1;` a **STATIC** class property | 3 elems | **EQ** |
| v3d | `vfull.gblk.gsig <= 1;` a **GENERATE BLOCK** in the interface | `hp(vfull.gblk.gsig)` 3 elems | `hp(vfull.gsig)` 2 — **DECLINES** (not on the allowlist) |
| v3f | `vfull.lfa[0].lcb.lsig <= 1;` an **interface INSTANCE ARRAY** in the interface | 4 elems `{vfull}{bit_select lfa[0]}{lcb}{lsig}` | `hp(vfull.lsig)` 2 — **DECLINES, TWO components lost** |
| v3g | `ho.h.cb.ds <= 1;` the vif held by **ANOTHER OBJECT** | `hp(ho.h.cb.ds)` **4 well-formed elems** `{ho 63:8-9}{h 63:8-9}{cb 63:10-12}{ds 63:13-15}` | `hp(ho.h.ds)` 3 — **DECLINES** (`chain.size()==1`) |

### v4 — SITE 2, the only site that splices into a list carrying SELECTS (4/6 EQ)

| cell | source | golden | ours (patched) | pristine |
| --- | --- | --- | --- | --- |
| v4a | `varr[0].cb.ds <= 1;` (== a4 f2) | `{bit_select varr[0]}{cb}{ds}` | **EQ** | 2 elems |
| v4b | `r = varr[1].cb.dout;` **rvalue** base select | 3 elems | **EQ*** (leaf fullname `::`vs`.`, F6) | 2 elems |
| v4c | `varr[0].cb.din[3] <= 1;` base select **+ leaf bit select** | `hp(varr[0].cb.din)` — **golden ERASES the leaf select** | `hp(varr[0].cb.din[3])`, `cb` recovered, select kept | `hp(varr[0].din[3])` |
| v4d | `varr[1].cb.din[3:0] <= 4'h5;` base + **range** select | `hp(varr[1].cb.din)` erased | unchanged from pristine — a **different builder already had `cb`** | `hp(varr[1].cb.din[3:0])` |
| v4e | `v2d[0][1].cb.ds <= 1;` **2-D** base select | 5 elems | **EQ** | 3 elems, no `cb` |
| v4f | `r[0] = varr[0].cb.dout[2];` rvalue, base+leaf selects | 4 elems | **EQ** | 2 elems |

### v5 — ACCESS KIND × NESTED INSTANCE (4/5 EQ)

`@(vfull.sub.icb)` — the leaf IS the nested clocking block, so clause (3) sees
ONE component where a1 c7 saw none — is **EQ** (4 elems). Rvalue read, call
argument and `@(posedge vfull.sub.clock)` are **EQ**. Only
`if (vfull.sub.icb.ibus[0])` declines (the R2 element-select family, here losing
**two** components).

### the safety property, measured across all nine arms

```
for each arm: hier_path NAMES present in OURS but absent from GOLDEN
  a1 none | a2 none | v1 none
  a3 vif.din[3] vif.dout[2]            (R2 declines)
  a4 this.vif.ds this.vif.clock        (R1 golden-defective + pre-existing R8)
  a5 vif.ds                            (g1 spaced-dots decline)
  v2 vif.ds ×3, vif.esc$ds             (declines)
  v3 ho.h.ds vfull.gsig vfull.lsig     (declines) + d.ho span (pre-existing)
  v4 varr[0].cb.din[3] varr[1].cb.din[3:0]   (golden's leaf-select erasure)
```

**Not one over-fire.** The law never emits a component golden lacks — it only
fails to emit ones golden has.

---

## 6. FINDINGS

**F1 — the `chain.size()==1` gate is justified by a claim my cell REFUTES.**
*(accuracy, MEDIUM — the largest missed population, mis-explained)*
The comment at ExprEmit.cpp SITE 1 says a longer chain "means the vif was
reached through a further member — the `this.vif.cb.sig` shape, where GOLDEN
ITSELF is defective … and must not be imitated". Golden's defect is specific to
the written `this` **keyword**, not to chain length: for a vif held by another
object, golden is perfectly well-formed.
```
$ ./svsarm.sh v3_handle.sv /tmp/v5arm/v3_handle_pat <patched>
$ ./gridread.sh /tmp/v5arm/v3_handle_pat/{g,o}.dump | grep ho.h
GOLDEN hp[ho.h.cb.ds] {ref_obj (ho) 63:8-9}{ref_obj (h) 63:8-9}{ref_obj (cb) 63:10-12}{ref_obj (ds) 63:13-15}
OURS   hp[ho.h.ds]    {ho}{h}{ds}
```
So the gate over-declines a shape whose golden is good, and the record's reason
for the gate is false. Priced: `X.Y.<cb>.<id>` has **635 source sites** across the
corpora (487 `<UVM-LIBRARY>`, 77 Opentitan, 34 wav-lpddr-hw, 22 Ibex, 15
SimpleInterface) — **zero in any test with a CMP row today**, all in
SLANG_REJECT / NO-ROW tests or never-compiled library, which is why no gate
moves. It becomes the live population the moment Opentitan/Ibex/SimpleInterface
stop being SLANG_REJECT. Ranked **R1b**, above R1.

**F2 — "the space case is the one that really declines" is REFUTED: ESCAPED
identifiers decline too, in BOTH positions.** *(accuracy, MEDIUM)*
README §4.3 row C3 deletes the earlier comment's escaped-identifier clause as
"TOO BROAD" and asserts only the space case declines. No escaped-identifier cell
was ever built. Two cells say the deleted clause was right:
```
v2b  vif.\cb2 .ds <= 1   golden hp(vif.cb2.ds) 3 elems   ours hp(vif.ds) 2   DECLINE
v2c  vif.cb.\esc$ds <= 1 golden hp(vif.cb.esc$ds) 3      ours hp(vif.esc$ds) 2  DECLINE
```
Mechanically: for v2c the leaf text check passes (`name` = `esc$ds`, the last 6
chars of `\esc$ds` read back equal) and the **component** window is then `b\`
instead of `cb.` — the second guard is what saves it, not the first. This is the
same escaped-identifier family the r10svs4 verifier caught before landing, so the
campaign's own history predicted it. Reach 0 and the direction is safe (decline,
never a wrong span): 54 corpus files contain an escaped identifier inside a
dotted path and **none of them declares a clocking block**
(`for f in $(grep -rlE '\.\\[!-~]+ *\.' …); do grep -lE 'clocking +[A-Za-z_][A-Za-z0-9_]* *[@;]' $f; done | wc -l` → 0).
Ranked **R3b**.

**F3 — a MACRO supplying ONE path token also declines; C2's refutation is
narrower than stated.** *(accuracy, LOW-MEDIUM)*
`v2d vif.cb.`LEAF` and `v2e vif.`COMP .ds` both stay 2-element. C2 ("a
macro-spelled path CONVERGES, R4 is deleted") is true only for a macro that
spells the path from the handle down (a5 g4; my v2f reproduces it). Reach: 8
`.`MACRO` path-component sites corpus-wide (SplitFile, Opentitan, Ibex), none in a
clocking path. Ranked **R3c**.

**F4 — clause (2)'s allowlist has two unbuilt interface scopes, both real.**
*(coverage, MEDIUM)*
`ClockingBlock | InstanceBody` omits a **generate block** and an **interface
instance array** inside the interface. v3d loses one component, v3f loses two —
both DECLINE, so nothing regresses, but neither was measured before I built it.
Population is not hypothetical: 10 corpus files declare a clocking block and also
carry a generate-ish construct in an interface file, **including InterfaceModPort
and SimpleUVM**. Ranked **R4**.

**F5 — §6.1's explanation of the over-prediction is factually wrong (the
conclusion still holds).** *(census accuracy, LOW)*
Claimed: "all 650 of those sites live under `third_party/UVM/*/examples/`".
Measured:
```
332 vmm-1.1.1a/sv   168 (=84+84) uvm-1.{2,1d}/examples   23 uvm-1.2/src
 23 uvm-1.1d/src    23 1800.2-2017-1.0/src   23+23 docs   23 pp_output   12 vmm/shared
```
Only 168/650 are under `examples/`, and sites DO exist in `uvm-1.2/src`, which
the UVM tests compile. I re-derived the conclusion the right way: all 23
`uvm-1.2/src` hits are `.mem.` **false positives** (`this.mem.get_full_name()` in
`reg/uvm_vreg.svh` — a class handle, not a clocking block), and vmm appears only
on `+incdir+` search paths in ~10 tests' `.sl` lines, never as a compiled file.
So "no compiled source carries a live site" stands; the stated reason does not.

**F6 — one cell is labelled EQ while a name field differs.** *(labelling, LOW)*
a1 **c11** (`b = r[vif.cb.dout]`) is marked **EQ** in §3.1's table, but the leaf
ref is `work@drv_a::go::r::dout` (golden) vs `work@drv_a::go.r::dout` (ours) — 2
of that arm's 24 residual lines. The prose discloses it; the table does not. Same
for my v4b. Pre-existing (identical in pristine), `Compare`-invisible.

**F7 — SITE 2's live-cell claim undercounts, in the implementer's favour, and it
uncovers a golden law nobody has named.** *(coverage, LOW)*
The comment says "THE LIVE CELL HERE IS ARM a4 f2". Six SITE-2 cells fire; three
more reach golden exactly (v4b rvalue, v4e 2-D base select, v4f rvalue with both
selects). The two that do not reveal something: for a base-select vif lvalue,
**golden ERASES the leaf select** — `hp(varr[0].cb.din)` with a plain `ref_obj`
leaf where the source wrote `varr[0].cb.din[3]` — an unnamed sibling of
`§ thisPathSelectErased4`. v4d's `cb` was already present pre-patch (a different
builder reaches that shape), so only v4c moved. Ranked **R7**.

**F8 — three arms exit slang rc=4 and the record never says so.** *(ops, LOW)*
`a4_base.sv` → `unsupported constructs: class property type:
FixedSizeUnpackedArrayType`; my `v3_handle.sv` → `typedef target:
VirtualInterfaceType`. Dumps are still produced and the cells readable, but a
reader re-running `svsarm.sh` meets an unexplained nonzero rc — and a4's
unsupported construct *is* residue R6's declaration shape, which is worth saying
out loud.

### refutations of the implementer's own refutations — upheld

* the brief's **REACH WARNING is genuinely refuted**. I confirm it independently:
  every non-virtual handle in a2 is byte-identical to golden on both binaries
  (`diff` of the patched vs pristine a2 dumps = **0** lines), the 140 golden-vs-ours
  a2 diff lines contain **no** `hier_path`/`ref_obj` at all, InterfaceModPort holds
  in both modes, and the byte verifier finds 0 u2r / 7 surelog movers.
* the brief's **mechanism guess is half right** — upheld, and I verified the
  widening cell myself (`vfull.sub.isig`, `vfull.sub.icb.isig`, plus my
  `@(vfull.sub.icb)`), against the slang source lines quoted above.
* **C1** (SITE 2's cells are not a3 e1/e3) — upheld: e1/e3 are still 2-element on
  the shipped binary, and R2's zero corpus reach reproduces.
* **C2** (macro path converges) — upheld for the whole-path macro; narrowed by F3.
* **C4** (the bare recovered component) — upheld: a4 f2's `\_ref_obj: (cb)` carries
  `|vpiName:cb` and no `|vpiFullName`, byte-identical to golden.
* golden's **lvalue base+component-on-one-token** convention is general — upheld
  on every new firing cell (v1, v3a/b/c, v4a/e, v5).

## 7. RANKED RESIDUES (merged; NEW = found by this verification)

| # | residue | reach measured | note |
| --- | --- | --- | --- |
| **R1b** | **NEW** `X.vif.cb.sig` — vif reached through another object/member; golden is CORRECT and we decline | 635 source sites, **0 live rows** | F1. The gate's stated rationale is false; the real discriminator is the `this` keyword |
| **R1** | `this.vif.cb.sig` — **golden itself drops the leaf** | 0 | declined deliberately; unchanged |
| **R2** | element select over a clockvar (a3 e1/e3, v5c) — and in the nested case it loses **two** components | 12 lines in `ariane`, NO ROW | needs a 4th call site |
| **R7** | **NEW** base-select vif lvalue with a leaf select: golden ERASES the leaf select, we keep it (v4c/v4d) | 0 live rows | F7; an unnamed sibling of `§ thisPathSelectErased4` |
| **R4** | **NEW** allowlist gap: generate block / interface instance array inside the interface (v3d/v3f) | 10 files pair a clocking block with a generate-ish interface | F4 |
| **R3** | `vif . cb . ds` spaced dots decline | 0 | unchanged |
| **R3b** | **NEW** escaped identifier as component or leaf (v2b/v2c) | 54 files, **none with a clocking block** | F2 |
| **R3c** | **NEW** macro supplying one path token (v2d/v2e) | 8 sites, none clocking | F3 |
| **R5** | macro-ARGUMENT path gets the call-site span (golden the definition site) | 1 object ×2 modes in SimpleUVM | span-only, `getFullyOriginalLoc` gap |
| **R6** | successor head: no `array_var` for `virtual output_interface.OP output_intf[4]` | SVSwitch both modes | pre-existing, g=4 p=0 a=0; F8 notes slang's own rc=4 for the same shape |
| **R8** | `@(posedge this.vif.clock)` — we emit a `hier_path`, golden emits none | 1 arm cell | pre-existing |

## 8. WHAT I RAN (re-runnable)

```
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build build -j 6                                  # both worktrees
SLANG_UHDM=<bin> tests/check_goldens.sh                   # and with /bin/false
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus surelog    --mode both      --jobs 2 …
SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 …
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh <patched wd> <pristine wd>   # both corpora
./mvdump.sh ./default/<mover> <patched wd> <pristine wd> /tmp/v5mv/<t>_d
./shapecount5.sh …/{g,p,a}.dump ; ./msmovers.sh …/{g,p,a}.dump ; ./msdist.sh …
./svsarm.sh {a1..a5,v1..v5}.sv <out> <bin> ; ./gridread.sh <g.dump> <o.dump>
./census.sh ; bash tools/probe/r10uvm52repro/canaries.sh <new.csv> <baseline.csv>
EXPECT_UNKNOWN=<n> bash tools/probe/r10uvm55repro/ctcan2.sh <new.csv> <baseline.csv>
bash tools/probe/r10uvm55repro/canaudit.sh <canaries.sh> <ctcan2.sh>
```

All sweep workdirs under `/tmp/v5sv`, `/tmp/v5arm`, `/tmp/v5mv` deleted after the
run. The five new arms (`v1_direction.sv` … `v5_nested.sv`) stay in this
directory so the empty products this pass filled do not have to be re-derived.
