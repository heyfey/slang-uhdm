# r10svs4 — SVSwitch's 78-line head: an indexed `this.<member>` select renders with the SELECT ERASED

**Base commit `bc6abbb`. Emitter-only. TWO laws, four call sites, five gates.**

Headline, first, because the brief asked for it first:

> **SVSwitch does NOT convert.** It stays `CMP_NOTEQUAL` in both modes. The
> briefed head is **CLEARED** (78 cmp lines → 25), a second head under it was
> also cleared, and a **THIRD, unrelated head** is now SVSwitch's sole survivor.
> **The brief's premise — "the LAST HEAD BEFORE CMP_EQUAL … the verifier
> confirmed this is the sole survivor" — is REFUTED.** It was the sole head, but
> a head is not a distance: clearing it exposed two more laws stacked beneath.

| number | pristine `bc6abbb` | shipped | note |
| --- | --- | --- | --- |
| SVSwitch cmp HEAD DEPTH | 78 | **74** | briefed head CLEARED; a THIRD law is the new head |
| SVSwitch heads (`grep -c '^LHS:'` col 0) | 1 | 1 | ONE head per run, always |
| SVSwitch dump content +/- | 2578 | 2548 | ALIGNMENT-SENSITIVE — do not read as progress |
| SVSwitch MULTISET distance | 1950 | **1926** | `msdist.sh`, the authoritative distance |
| SVSwitch row, both modes | `CMP_NOTEQUAL` | `CMP_NOTEQUAL` | **no promotion; `results/*.csv` untouched** |

THREE DISTINCT NUMBERS, never conflated: head DEPTH (one head's subtree size),
alignment-sensitive dump +/-, and multiset distance. Note the trap this pass
walked into and out of: head depth went 78 → **25** with law 1 alone, then **up**
to 74 when law 2 cleared the 25-line head and exposed a bigger subtree. Head
depth is NOT monotone in progress. Multiset distance is (1950 → 1931 → 1926).

---

## 0. THE BINARIES — which number came from which

| binary | md5 | what it is |
| --- | --- | --- |
| main tree `build/slang-uhdm` @ `bc6abbb` | `d1ccd848dd088a9b37918cb944336423` | the committed baseline build |
| **pristine worktree, built from scratch here** | `d1ccd848dd088a9b37918cb944336423` | **byte-identical to the main tree** |
| law 1 only (not shipped; measured in §4) | `b2dff1e87fab73384726ca44337bc0e1` | § thisPathSelectErased4 alone |
| **SHIPPED (both laws)** | `c8afd5decdfde67a959062181263f06d` | every gate below |

The pristine worktree binary is byte-identical to the main tree's and to the md5
the brief quotes for the landed `bc6abbb`. That is the stale-binary control
working in the useful direction: the pristine side of every comparison here
really is `bc6abbb`, built by this agent. `git rev-parse --short HEAD` = `bc6abbb`
in both worktrees; the source delta is exactly the two production files below.

---

## 1. LOCALIZATION — the gating FIELDS, read out of the generated Compare methods

The head is a `hier_path`. A head is a SUBTREE (78 lines), so the failing FIELD
had to be localized rather than assumed. `hier_path::Compare`
(`~/git-repos/UHDM/build/generated/src/hier_path.cpp`) reads exactly three
things:

```cpp
if ((r = basetype_t::Compare(other, context)) != 0) return r;          // BaseClass
if ((r = SafeCompare(lhs, lhs->Path_elems(), rhs, rhs->Path_elems(), context))) return r;
if ((r = SafeCompare(lhs->Root_value(), rhs->Root_value(), context))) return r;
if ((r = lhs->VpiName().compare(rhs->VpiName())) != 0) { ... }
```

`BaseClass::Compare` (`~/git-repos/UHDM/templates/BaseClass.cpp:163`) reads
`VpiType`, `VpiName`, `VpiDefName` — nothing else. `ref_obj::Compare` OPENS with
`VpiType() - other->VpiType()`, then `VpiName`, `VpiDefName`, `VpiGeneric`,
`Actual_group`, `VpiStructMember`. `bit_select::Compare` reads
`VpiConstantSelect` and `VpiIndex`.

So the cmp-visible half of this head is **exactly two fields**:

1. the `hier_path`'s **`VpiName`** (`this.data` vs `this.data[i]`), and
2. the second path element's **`VpiType`** (`ref_obj` vs `bit_select`).

**`VpiFullName` is read by NO Compare method, and neither is any line/column
field** — confirmed over the whole generated tree, the same census r10svs3 ran:

```
$ cd ~/git-repos/UHDM/build/generated/src && grep -l "::Compare" *.cpp | wc -l
233
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiLineNo|VpiEndLineNo|VpiColumnNo|VpiEndColumnNo|VpiFile"
0
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiFullName\(\)"
0
$ awk '/int32_t [a-z_]*::Compare/,/^}/' *.cpp | grep -cE "VpiName\(\)"        # control
37
```

233 Compare methods, 0 span reads, 0 fullname reads, control non-zero. Every
span and fullname figure in this document is therefore **dump-only** — recorded
because the law reproduces them for free, never as a cmp claim.

The head, reproduced on the pristine binary through the harness itself
(`svsgen.sh`, which builds both argvs with `scripts/verify_golden.py` so they are
byte-for-byte the ones the committed rows were produced with):

```
$ svsgen.sh /tmp/r10svs4_pris <pristine>
SLANG=...r10svs4pris/build/slang-uhdm  md5=d1ccd848dd088a9b37918cb944336423
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
== default    cmp rc=255  cmp HEAD DEPTH=78  heads=1
== testflags  cmp rc=255  cmp HEAD DEPTH=78  heads=1
```

---

## 2. THE FREE CELL SETTLED IT IN ONE GREP — and refuted three of the brief's four hypotheses

The brief named the sibling expression on the SAME line as "the single most
informative free cell". It is, and it is decisive. `Packet.sv:122` is

```systemverilog
foreach(this.data[i])
if(pkt.data[i] !== this.data[i])
```

Both operands of that ONE comparison, in GOLDEN:

```
hier_path: (pkt.data[i])  122:13-122:24   { ref_obj(pkt) 122:13-16,
                                            bit_select(work@packet::compare::pkt.data[i]::data) 122:22-23 + index }
hier_path: (this.data)    122:29-122:41   { ref_obj(this) 122:34-38, ref_obj(data) 122:34-38 }
```

Same line, same foreach, same loop variable `i`, same rvalue-in-comparison
position, same array. **The only thing that differs is the receiver.** So the
gate is the written `this` keyword and nothing else — the same discriminator
r10svs3 landed (`§ thisSuperNewAssignNoStmt3`), i.e. the brief's hypothesis (b).
Hypotheses (a), (c) and (d) are refuted, and §3 refutes them cell by cell.

---

## 3. THE GRID, CELL FOR CELL

Three arms, 46 cells, all in `tools/probe/r10svs4repro`. `G` = golden verdict,
`A` = ours after the patch. "erased" = the hier_path's name carries NO index and
every element is a plain `ref_obj`; "kept" = the index survives in the name and
the element is a `bit_select`/`var_select`.

### 3.1 `g1_thisidx.sv` — receiver × index kind × position (27 cells)

| cell | source | G: index | G: last elem | A matches G? |
| --- | --- | --- | --- | --- |
| c1 | `this.data[i]` foreach var, rvalue-cmp | **erased** | `ref_obj` | **yes, byte-for-byte** |
| c2 | `pkt.data[i]` **same line** | kept | `bit_select` | yes (untouched) |
| c3 | `this.data[j]` for-loop var | **erased** | `ref_obj` | yes |
| c4 | `pkt.data[j]` | kept | `bit_select` | yes |
| c5 | `this.data[2]` **CONSTANT index** | **erased** | `ref_obj` | yes |
| c6 | `pkt.data[2]` | kept | `bit_select` | yes |
| c7 | `this.data[k]` argument var | **erased** | `ref_obj` | yes |
| c8 | `pkt.data[k]` | kept | `bit_select` | yes |
| c9 | `this.data[k] = …` **LVALUE** | **erased** | `ref_obj`, LOC-LESS, scoped | yes |
| c10 | `pkt.data[k] = …` lvalue | kept | `bit_select` | yes |
| c11 | `this.data[1] = …` lvalue, const | **erased** | `ref_obj` | yes |
| c12 | `g(this.data[k])` **call argument** | **erased** | `ref_obj` | yes |
| c13 | `g(pkt.data[k])` | kept | `bit_select` | yes |
| c14 | `r = this.data[k]` plain assign rhs | **erased** | `ref_obj` | yes |
| c15 | `r = pkt.data[k]` | kept | `bit_select` | yes |
| c16 | `this.fx[k]` **FIXED** array | **erased** | `ref_obj` | yes |
| c17 | `pkt.fx[k]` | kept | `bit_select` | yes |
| c18 | `this.q[k]` **QUEUE** | **erased** | `ref_obj` | yes |
| c19 | `pkt.q[k]` | kept | `bit_select` | yes |
| c20 | `this.m2[k][1]` **2-D**, both dims | **erased** | `ref_obj` (not `var_select`) | yes |
| c21 | `pkt.m2[k][1]` | kept | `var_select` | yes |
| c22 | `this.scalar` UNINDEXED **control** | n/a | `ref_obj` | **NO — residue R2, deliberate** |
| c23 | `data[k]` no receiver written | n/a | plain `bit_select`, no hier_path | yes (identical both sides) |
| c24 | `this.data[k+1]` expression index | **erased** | `ref_obj` | yes |
| c25 | `pkt.data[this.data[k]]` this-path AS index | golden drops the index TEXT from the **pkt** name too | `bit_select` | **NO — residue R5** |
| c26 | `gh.data[kk]` **module scope** | kept | `bit_select` | yes (identical both sides) |
| c27 | `gh.data[1]` module scope, const | kept | `bit_select` | yes (identical both sides) |

### 3.2 `g2_thisdeep.sv` — the shapes that reach the OTHER call sites (13 cells)

| cell | source | G: index | G: shape | A matches G? |
| --- | --- | --- | --- | --- |
| d1 | `this.st[k].fld` select-THEN-member | **erased** | `this.st.fld`, 3 plain `ref_obj` | **yes, byte-for-byte** |
| d2 | `r = this.h.data[k]` rvalue | golden emits a **`constant`** (folds a null handle) | — | no — pre-existing, residue R4 |
| d3 | `super.data[k]` | **erased** (`super.data`) | 2 `ref_obj` | **no — we emit NO hier_path at all; residue R3** |
| d4 | `this.data[k][3]` bit-in-element | **erased** | `this.data` | yes |
| d5 | `this.data[k][3:0]` **part select** | **erased** | `this.data` | yes (SITE 2) |
| d6 | `this.data.size()` | golden emits a **`constant`** | — | no — pre-existing, not this law |
| d7 | `this.st[2].fld` const idx | **erased** | `this.st.fld` | yes |
| d8 | `this.st[k].fld = …` lvalue | **`this.@@BAD_SYMBOL@@`** | — | **NO, and deliberately: golden is DEFECTIVE here (see below)** |
| d9 | `this.h.data[k] = …` lvalue | **erased** | `this.h.data`, all non-base elems LOC-LESS + scoped | **yes, byte-for-byte** |
| d10 | `o.st[k].fld` HANDLE | kept | `bit_select` | yes except a `.`-vs-`::` leaf separator (r10svs2's R2, reconfirmed) |
| d11 | `o.h.data[k]` HANDLE | kept | `bit_select` | yes |
| d12 | `o.data[k][3]` HANDLE | kept | `var_select` | yes except a span |
| d13 | `o.st[k].fld = …` HANDLE lvalue | kept | `bit_select` | no — pre-existing naming residue |

**d8 is a refutation of GOLDEN, not of the law.** Surelog fails to resolve the
lvalue `this.st[k].fld` and emits a path literally named
`this.@@BAD_SYMBOL@@`. We emit the honest `this.st.fld` with golden's exact span
convention. This is the one cell where matching golden would mean reproducing a
resolver failure, and it is not done. No comparable corpus test has this shape.

### 3.3 `g3_assoc.sv` — the index kind the OTHER corpus test would present (6 cells)

Rggen is the only other corpus source with a this-rooted indexed select
(`rggen_backdoor_pkg.sv:15,34`), both sites STRING-KEYED ASSOCIATIVE arrays, both
behind `` `ifdef RGGEN_ENABLE_BACKDOOR `` which `Rggen.sl` never defines — so
they are dead today. Measured anyway, so "the gate is the receiver, not the index
kind" is a measurement rather than an extrapolation:

| cell | source | G: index | A matches G? |
| --- | --- | --- | --- |
| e1 | `this.vif[path] = vif` assoc **[string]** lvalue | **erased** | **yes, byte-for-byte** |
| e2 | `this.wrapper[path] = new(vif)` | NO statement at all | **yes** — r10svs3's `§ thisSuperNewAssignNoStmt3` still governs, undisturbed |
| e3 | `this.iv[3] = vif` assoc **[int]** lvalue | **erased** | yes |
| e4 | `return this.vif[hdl_path]` rvalue in a **return** | **erased** | yes |
| e5 | `return vif[hdl_path]` no receiver | n/a | yes |
| e6 | `o.vif[p] = 1` HANDLE | kept | yes |

Arm 3's every `hier_path` matches golden **exactly**; its only residual cmp head
is an unrelated `int_typespec` `vpiSigned` on an `int` formal.

### 3.4 What the grid REFUTES

* **NOT the foreach context** (brief hypothesis a) — c5 is a literal constant
  index outside any loop and is erased; c2 is the same foreach's own loop var on
  a handle and is kept.
* **NOT loop-var-ness** (hypothesis c) — c5 (constant), c7 (an argument), c24
  (`k+1`), e1 (a string) all erase.
* **NOT the syntactic position** (hypothesis d) — rvalue-in-comparison, plain
  assign rhs, call argument, return expression and lvalue ALL erase. Position
  gates only the cmp-invisible SPANS.
* **NOT the array kind** — dynamic, fixed, queue, 2-D and associative all erase.
* **NOT the select kind or depth** — element select, range select, and two
  stacked selects all erase; a select below a further member erases too.
* **`super` behaves IDENTICALLY in golden** (d3) — so the law is really about the
  written implicit-self keyword. It is out of the shipped predicate because
  slang resolves `super.data` straight to the inherited member and hands us no
  `super` base: we emit no `hier_path` there at all. That is a MISSING-SHAPE gap,
  not an index-presence one. Residue **R3**.

---

## 4. THE LAWS, AND THE STATED GATE IS THE GATE IN THE CODE

### § thisPathSelectErased4 — `src/ExprEmit.cpp`, definition + **3 call sites**

```
$ grep -n 'thisPathSelectErased' src/ExprEmit.cpp include/UhdmExporter.h
```

Definition (after `emitMixedHierPath`), and SITE 1 `case ExpressionKind::ElementSelect`,
SITE 2 `case ExpressionKind::RangeSelect`, SITE 3 `case ExpressionKind::MemberAccess`
(for the select-below-a-further-member shape, d1/d7/d8). Each site calls it
**before** every arm that would mint a `bit_select`/`var_select`.

The predicate, and it is the whole gate:

```cpp
    if (!sawSelect || mems.empty())    return nullptr;   // no select -> not ours
    if (cur->kind != ExpressionKind::NamedValue) return nullptr;
    auto& nv = cur->as<NamedValueExpression>();
    if (nv.symbol.name != "this")      return nullptr;   // THE WRITTEN KEYWORD
```

`nv.symbol.name != "this"` **is** the written-keyword test: slang names the
implicit self variable `this` and produces that base only when the keyword was
written (an implicit member reference resolves straight to the member symbol).
The unindexed form is excluded by `!sawSelect`, on purpose (residue R2).

Emitted shape, position-gated exactly as §3 measured:

| field | LVALUE | rvalue / argument / return |
| --- | --- | --- |
| `hier_path` loc | the `this` token | the WHOLE written expression |
| `VpiName`/`VpiFullName` | the bare dotted member path | same |
| elem[0] `this` loc | the FIRST MEMBER's name token | same |
| elem[i>0] | LOC-LESS + `joinRef(prefix, name)` | own member token, BARE name |

No `Actual_group` is bound on any element, because golden's dump shows none.

### § copyClassIsNewCall4 — `src/ExprEmit.cpp`, **1 call site** (a new `case`)

Clearing law 1 exposed a head where golden had a `method_func_call (new)` and
ours had **`RHS: <null>`** — `pkt = new gpkt;` (`Driver.sv:38`), the SHALLOW-COPY
constructor. `ExpressionKind::CopyClass` had **no arm at all**, so `emitExpr`
returned null and the assignment lost its whole Rhs. The arm mirrors the
`NewClass`/`NewArray` arms either side of it: loc-less `method_func_call` named
`new`, the copied handle as its one `vpiArgument`. Two details are measured, not
copied: it does **not** `setLoc` (golden's node carries no span) and it does
**not** call `stripRefFullNames11` (golden's argument keeps
`vpiFullName:work@Driver::start::gpkt`).

### THE NEW HEAD — a THIRD law, characterised and NOT touched

```
LHS (golden): hier_path: (input_intf.cb.data_status), id:1479, 53:11-53:36
              { ref_obj(input_intf) 53:22-24, ref_obj(cb) 53:22-24, ref_obj(data_status) 53:25-36 }
RHS (ours):   hier_path: (input_intf.data_status),    id:1963, 53:11-53:36
              { ref_obj(input_intf) 53:25-36, ref_obj(data_status) 53:25-36 }
```

`Driver.sv:53` is `input_intf.cb.data_status <= 1;` where `cb` is a **CLOCKING
BLOCK** reached through modport `MEM(clocking cb, …)`. Golden keeps `cb` as a
path COMPONENT (three elements); slang resolves the clocking-var access and we
drop it (two elements). This is a missing-COMPONENT law in the
clocking-block/modport family, not an index-presence or element-kind one, so it
is **out of this pass's territory** and filed as **R1**. It is also the reason
head depth rose 25 → 74: this head's subtree is simply bigger.

Golden's id ordering is the progress check that head depth cannot give:
the cleared heads were golden ids 2431 then 1447; the new head is id **1479**,
and its source moved `Packet.sv:122` → `Driver.sv:38` → `Driver.sv:53`.

---

## 5. THE FIVE GATES

### GATE 1 — BUILD

Absolute paths; each build waited for `Linking CXX executable slang-uhdm` (grep
count **1** in each log); every md5 asserted in a SEPARATE command; all four
md5s above are 32 hex characters.

```
$ md5sum .../r10svs4pris/build/slang-uhdm .../r10svs4/build/slang-uhdm .../slang-uhdm   # baseline
d1ccd848dd088a9b37918cb944336423  (all three, byte-identical)
$ md5sum .../r10svs4/build/slang-uhdm                                                   # SHIPPED
c8afd5decdfde67a959062181263f06d
```

### GATE 2 — GOLDENS: **23 PASS / 0 FAIL**, and the control **0 PASS / 23 FAIL**

```
$ SLANG_UHDM=<shipped> bash tests/check_goldens.sh | grep -c '^PASS'   -> 23
$                                          ... | grep -c '^FAIL'      -> 0
$ SLANG_UHDM=/bin/false bash tests/check_goldens.sh | grep -c '^PASS' -> 0
$                                          ... | grep -c '^FAIL'      -> 23
```

The `/bin/false` arm is what makes the 23 mean anything: it proves the harness
really runs the binary under test rather than a cached artefact.

### GATE 3 — uhdm2rtlil, testflags, `--jobs 2`: **679 / 50 / 2**, dump **496 / 183 / 52**, ct8rows **0 differing rows**

```
[testflags] 731 tests   CMP_EQUAL: 679   SLANG_REJECT: 50   SURELOG_FAIL: 2
---- WHOLE-ROW diff (status AND dump column): 0 differing ROWS (0 diff row-sides)
  testflags  base :  52  183 differ  496 match
  testflags  fresh:  52  183 differ  496 match
PASS: every row byte-identical to the committed baseline
```

### GATE 4 — Surelog, `--mode both`, `--jobs 2`: **default 467/13, testflags 463/10**, dump match **225 / 165**, **0 differing rows**

```
[default]   467 CMP_EQUAL  13 CMP_NOTEQUAL  5 DEFERRED  284 SLANG_REJECT  25 SURELOG_FAIL
[testflags] 463 CMP_EQUAL  10 CMP_NOTEQUAL  5 DEFERRED  286 SLANG_REJECT  23 SURELOG_FAIL
            3 NO_DATABASE  1 NO_UHDM  1 TIMEOUT  2 UNTRANSLATABLE
---- WHOLE-ROW diff: 0 differing ROWS (0 diff row-sides)
  default    base/fresh:  327  242 differ  225 match
  testflags  base/fresh:  331  298 differ  165 match
PASS: every row byte-identical to the committed baseline
```

5 DEFERRED, i.e. `GOLDEN_DEFER` at its default. **SVSwitch did NOT convert**, so
the conversion-adjusted expectations (468/12, 464/9, 4 differing row-sides) do
NOT apply and the un-adjusted numbers are the right ones. `results/*.csv` were
read only. *An earlier run of this gate was discarded and re-run: it had been
launched with `GOLDEN_DEFER=1`, which sets the defer set to the literal name
`1` and would have run the five OOM/timeout tests. Every number above is from
the clean re-run.*

### CANARIES

```
u2r      : ctcan2.sh EXPECT_UNKNOWN=6 -> ok=1  changed=0 absent=0 unknown=6  PASS
u2r      : tools/probe/r10uvm52repro/canaries.sh -> ok=8  changed=0 absent=0
surelog  : ctcan2.sh EXPECT_UNKNOWN=1 -> ok=58 changed=0 absent=0 unknown=1  PASS
surelog  : tools/probe/r10uvm52repro/canaries.sh -> ok=52 changed=0 absent=0
canaudit.sh -> audited=29  UNCOVERED=0  FENCE-BREACH=0  PASS
BY NAME  : InterfaceModPort   default/testflags  OK  CMP_EQUAL/differ
           BlackParrotComplex default/testflags  OK  CMP_EQUAL/differ
           SVSwitch           default/testflags  OK  CMP_NOTEQUAL/
```

### GATE 5 — BYTE VERIFIER, both corpora, vs the pristine `bc6abbb` workdirs

```
uhdm2rtlil : PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
             SELFCHECK  678 / 679 flagged      SELFCHECK1  1
surelog    : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 9 / 953
             SELFCHECK  952 / 953 flagged      SELFCHECK1  10
```

Both negative controls green on both corpora: the all-vs-one arm flags every
path, and the single-corruption arm reports exactly `1` (u2r) and `9 + 1 = 10`
(surelog). A verifier that cannot see one corrupted byte cannot see one law.

---

## 6. THE MOVERS — attributed PER SHAPE against GOLDEN, by MULTISET

### 6.1 My blast-radius prediction was WRONG, and the verifier caught it

Before patching I grepped the corpora for `this.<id>[` and found the only
*comparable* test was SVSwitch, and predicted **1 mover**. The verifier found
**9**. The grep covered `Surelog/tests`, `Surelog/third_party/tests` and
`uhdm2rtlil/test` and **omitted `Surelog/third_party/UVM`** — which the four UVM
tests compile in, and which carries both shapes
(`uvm_mem_mam.svh` 15 sites, `uvm_vreg.svh` 14, `uvm_reg_block.svh` 5, …).
**A source grep over test directories is not a blast radius when tests pull in a
vendored library.** The u2r half of the prediction did hold: 0 movers / 679.

All 9 movers are `CMP_NOTEQUAL`-or-`differ` rows, so the row gates were blind
inside them by construction — this is precisely what gate 5 exists for.

### 6.2 Every mover CONVERGED. `ADDED` and `REMOVED` reported separately.

`msmovers.sh` (3-way multiset: golden / pristine-ours / patched-ours), never
`diff -u`:

| mover (both modes unless noted) | multiset distance | shapes moved | CONVERGED | DIVERGED | LATERAL | ADDED | REMOVED |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SVSwitch | 1950 → **1926** | 28 | 25 | 3 | 0 | 10 | 8 |
| BuildUVMPkg | 82500 → **82274** | 222 | 206 | 16 | 0 | 63 | 113 |
| SeqDriver | 369300 → **368714** | 353 | 333 | 19 | 1 | 93 | 210 |
| SimpleUVM (default) | 146169 → **145869** | 295 | 278 | 17 | 0 | 85 | 163 |
| SimpleUVM (testflags) | 146165 → **145865** | 295 | 278 | 17 | 0 | 85 | 163 |
| Scoreboard (default only) | 136425 → **136127** | 294 | 277 | 17 | 0 | 85 | 162 |

Multiset distance falls in all nine. `Scoreboard`/`default` moved in `default`
only; its `default` database is the known PRE-EXISTING run-to-run flake
(macro-buffer `SourceLocation`), so per the verifier's own header a Scoreboard
byte difference is never evidence either way — its shape counts below are
nonetheless identical in form to the others.

### 6.3 THE LAW'S OWN SHAPES LAND EXACTLY ON GOLDEN — in all 9 movers

The multiset table alone cannot say whether the LAW landed, only that the file
moved. `shapecount.sh` counts, indent-blind, the exact shapes the law destroys
and creates (`G` golden, `P` pristine ours, `A` patched ours):

| test | `hier_path (this.…[…])` | `bit_select` w/ `this.<m>[` | `var_select` w/ `this.<m>[` | CONTROL: `bit_select` w/ `::`+`[` |
| --- | --- | --- | --- | --- |
| SVSwitch | G=0 P=3 **A=0** | G=0 P=2 **A=0** | 0/0/0 | G=2 P=4 **A=2** |
| BuildUVMPkg | G=0 P=42 **A=0** | G=0 P=28 **A=0** | 0/0/0 | G=558 P=574 A=546 |
| SeqDriver | G=0 P=108 **A=0** | G=0 P=72 **A=0** | 0/0/0 | G=1172 P=1224 A=1152 |
| SimpleUVM | G=0 P=54 **A=0** | G=0 P=36 **A=0** | 0/0/0 | G=636 P=656 A=620 |
| Scoreboard | G=0 P=54 **A=0** | G=0 P=36 **A=0** | 0/0/0 | G=636 P=656 A=620 |

**The two invariant shapes hit golden's 0 exactly, everywhere.** And the CONTROL
delta is exactly the number of this-rooted bit_selects erased, in every test:
`4−2=2`, `574−28=546`, `1224−72=1152`, `656−36=620`. The law touched **nothing
else** — that arithmetic is the no-over-fire proof.

### 6.4 The DIVERGED shapes are NOT regressions — two of them are UNMASKINGS

Worked all the way down, because a DIVERGED verdict left unexplained is how a
regression ships.

**SVSwitch's 3 DIVERGED** have ONE root cause. All are the count of an
`\_assignment: , line:38:6, endln:38:20` / `|vpiParent:` back-pointer at a given
depth. Law 2's own `method_func_call` line matches golden exactly; what diverges
is that golden parents the assignment's **LHS** ref at an artifact
`hier_path: (pkt)` where we parent it at the assignment:

```
GOLDEN            \_ref_obj: (work@Driver::start::pkt) 38:6-38:9
                    |vpiParent:  \_hier_path: (pkt)          <-- artifact hier_path
OURS              \_ref_obj: (work@Driver::start::pkt) 38:6-38:9
                    |vpiParent:  \_assignment: 38:6-38:20
```

`ref_obj::Compare` reads no parent, so this is dump-only and it is not the next
head. It is PRE-EXISTING — law 2 only made the assignment node reachable one
extra time, exposing it. Residue **R6**.

**BuildUVMPkg's specific DIVERGED shape is a coincidental cancellation.** The key
`|vpiFullName:uvm_pkg::uvm_mem_mam::release_region::i` read `G=1 P=1 A=0`. Broken
down by OWNING CONTEXT, indent-blind:

| side | total | contexts |
| --- | --- | --- |
| golden | 8 | 2 × `method_func_call: (this)` + 1 × `ref_var` (× depths) |
| pristine ours | 8 | 2 × `bit_select (…this.in_use[i]::in_use)` + 1 × `ref_var` |
| patched ours | 6 | 1 × `ref_var` |

Golden's two are the ARGUMENTS of `this.in_use.delete(i)`
(`uvm_mem_mam.svh:783`); ours were spurious path indices. **The pristine total
of 8 = golden's 8 was two unrelated errors cancelling.** The law correctly
deleted our wrong two; the right two were never ours. The real defect —
we do not emit `this.<member>.delete(i)` in golden's `method_func_call (this)` +
`vpiPrefix` constant shape — is residue **R4** and belongs to the method-call
arm. The remaining DIVERGED keys are the generic depth-keyed aggregates
`|vpiParent:` / `|vpiName:i` / `|vpiIndex:`, which sum thousands of unrelated
objects and cannot attribute anything on their own (r10svs3's README names this
same class); in every case golden's count EXCEEDS ours both before and after, so
they measure a pre-existing deficit that our spurious objects were padding.

### 6.5 One arithmetic gap, closed

108 indexed this-paths were erased in SeqDriver but the bare count rose only 96.
Reconciled: total this-rooted hier_paths went 4020 → 4008, i.e. **12 hier_paths
vanished entirely** — index-expression subtrees that go with the index they lived
in. Witness `uvm_mem_mam.svh:815`, `return this.in_use[this.for_each_idx];`:
pristine emitted the outer path AND an inner one for the index; golden and the
patched build emit only `this.in_use`. Our surplus of this-paths over golden fell
448 → 436, i.e. those 12 moved toward golden too.

---

## 7. RANKED RESIDUE

**R1 — SVSwitch's new head: a CLOCKING-BLOCK member is a hier_path COMPONENT.**
*Highest: it is the only thing between SVSwitch and its next head, and it is
fully characterised in §4.* `input_intf.cb.data_status` → golden 3 elements
(`input_intf`, `cb`, `data_status`), ours 2. Belongs to the clocking-block/
modport family, which the MEMORY notes is a 41-test interface cluster — so it is
probably worth far more than one test. **Caution: it edits interface-member path
name synthesis, which is where r10earl29's concat-index text rendering lives —
check for the collision before coding.**

**R2 — the UNINDEXED `this.<member>` span/name shape.** *Second: measured, free
to fix, and deliberately NOT shipped.* Golden (c22, and `this.da` at
`Packet.sv:105`) spans the hier_path over the WHOLE expression, anchors BOTH
elements on the member token, and leaves the leaf name BARE; we span the `this`
token, anchor elem[0] on `this`, and scope the leaf. **cmp-INVISIBLE** (§1), so
it can never move a row — which is exactly why it is out: it would change the
dump of every class test in both corpora, and gates 3/4 pin those dump columns
to the byte. Fix it in a pass whose brief expects the dump histogram to move.
The shipped emitter is therefore internally INCONSISTENT on purpose: indexed
this-paths get golden's shape, unindexed ones keep ours.

**R3 — `super`-rooted paths emit no hier_path at all.** *Third: golden's verdict
is already measured (d3: `super.data[k]` → `hier_path (super.data)`, identical to
the `this` law).* slang resolves `super.data` to the inherited member and leaves
us no `super` base, so this needs the written keyword recovered from syntax, not
a predicate widening. Do not simply add `|| name == "super"` — there is no such
symbol to test.

**R4 — `this.<member>.<builtin>(args)` is not golden's shape.** *Fourth: it is
the other half of what §6.4 unmasked, and it now shows up as a DIVERGED count in
four UVM tests.* Golden: `method_func_call (this)` whose `vpiArgument` is the
call's argument and whose `vpiPrefix` is a `constant` with
`vpiDecompile:this`; also `this.data.size()` folds to a `constant` (d6). Ours
emits a hier_path with a `method_func_call` element. Overlaps the parens-less
call arm r10svs2 landed — read `§ parensLessCallIsPathRefObj` first.

**R5 — a this-rooted path used AS AN INDEX drops the index text from the OUTER
(handle) path's name too.** *Fifth: golden's verdict is measured (c25:
`pkt.data[this.data[k]]` → golden names the outer path `pkt.data`), the mechanism
is not.* Bounded and rare; no comparable corpus test has it.

**R6 — an assignment LHS class-handle ref parents at an artifact `hier_path`
named for the handle.** *Sixth: dump-only, and the whole of SVSwitch's DIVERGED
column.* Golden parents `pkt`'s ref at `hier_path: (pkt)`; we parent it at the
assignment. `ref_obj::Compare` reads no parent, so it can never head.

**R7 — `.` vs `::` in a HANDLE-rooted path's leaf fullname.** *Lowest: r10svs2's
R2, independently reconfirmed here at grid cell d10* (`work@Other::g.fld` vs
golden `work@Other::g::fld`). Also cmp-invisible.

---

## 8. REPRODUCING

```bash
cd <worktree>
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
      -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build build -j 3        # WAIT for "Linking CXX executable slang-uhdm"
md5sum build/slang-uhdm         # SEPARATE command

R=tools/probe/r10svs4repro
$R/svsgen.sh /tmp/svs4 $PWD/build/slang-uhdm          # the SVSwitch pair, both modes
$R/svsarm.sh $R/g1_thisidx.sv  /tmp/g1 $PWD/build/slang-uhdm   # grid arm 1 (27 cells)
$R/svsarm.sh $R/g2_thisdeep.sv /tmp/g2 $PWD/build/slang-uhdm   # grid arm 2 (13 cells)
$R/svsarm.sh $R/g3_assoc.sv    /tmp/g3 $PWD/build/slang-uhdm   # grid arm 3 (6 cells)
$R/gridread.sh /tmp/g1/g.dump /tmp/g1/o.dump 'this\.'          # read the grid cells
```

```bash
# GATE 5 and the attribution, exactly as §6 ran them:
$R/byteverify.sh <patched_wd> <pristine_wd>            # SELFCHECK=1 SELFCHECK1=1
$R/mv4.sh <mode> <Test> <patched_wd> <pristine_wd>     # per-shape multiset, 3-way
$R/shapecount.sh <g.dump> <p.dump> <a.dump>            # the invariant shape counts
$R/msdist.sh <g.dump> <o.dump>                         # THE distance number
```

**Judge movers by `msmovers.sh` + `shapecount.sh`, never by `diff -u` counts.**
`diff -u` reports an ALIGNMENT: this integration watched it read 39 ADDED /
109 REMOVED on a mover whose true multiset was 70 removed / 0 added. And judge
the LAW by `shapecount.sh`, not by `msmovers.sh` alone — §6.4 is a worked example
of a multiset aggregate reading DIVERGED on a shape where the law was right.

Files: `g1_thisidx.sv` `g2_thisdeep.sv` `g3_assoc.sv` (the grid),
`svsgen.sh` `svsarm.sh` (runners, carried from r10svs3repro with the paths
re-pointed), `gridread.sh` (the cell reader), `msdist.sh` (carried from
r10uvm55repro @7c7eaa6, the whitespace-fixed version), `msmovers.sh`
`shapecount.sh` `mv4.sh` (new here), `byteverify.sh` (carried from r10oth6repro,
the SELFCHECK1-capable one).
