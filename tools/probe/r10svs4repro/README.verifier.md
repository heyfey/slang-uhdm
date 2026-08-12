# r10svs4 — ADVERSARIAL VERIFIER record

**VERDICT: PARTIAL.** Every number the implementer reported reproduces — all of
them, including both binary md5s bit-for-bit, all five gates, all 9 movers, every
multiset distance and every shape count. The law itself is real, correctly
localized, and I could not break it on any legitimate `this`-keyword shape in 12
newly-constructed cells. **PARTIAL for exactly one reason: the predicate's
STATED gate is not the gate in the code, and I have an executable counterexample
where that gap turns two cmp-VISIBLE fields from correct (pristine) to incorrect
(patched)** — finding F1. Its corpus blast radius is grep-provably **0 rows**, so
no gate number moves, and the fix is one line or one struck sentence. Land after
F1; nothing else blocks.

Verifier worktrees: `.claude/worktrees/r10svs4v` (patched), `.claude/worktrees/r10svs4vpris`
(pristine `bc6abbb`, built by me from scratch). Both `git rev-parse --short HEAD`
= `bc6abbb`.

---

## 0. HEADLINE AGREEMENTS

**SVSwitch does NOT convert** — independently confirmed from my own sweep, both
modes, byte-identical to the committed baseline:

```
$ grep -E '^SVSwitch,' results/golden_surelog.csv      # COMMITTED BASELINE (read only)
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
$ grep -E '^SVSwitch,' /tmp/v_svs4_sl.csv              # MY SWEEP, patched binary
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

So the conversion-adjusted expectations (468/12, 464/9, 4 differing row-sides) do
NOT apply, and the implementer was right to run the un-adjusted gate. `results/*.csv`
untouched by the patch and by me (§2).

**The implementer's refutation of their own brief is CORRECT and I confirm it.**
The brief's premise — "the LAST HEAD BEFORE CMP_EQUAL … the verifier confirmed
this is the sole survivor" — is false. It was the sole *head*. I reproduced the
head walk on my own binaries: golden id `2431` (`Packet.sv:122`, the briefed head)
→ cleared; a second head at `Driver.sv:38` → cleared; the survivor is golden id
`1479` at `Driver.sv:53`, and it is a **clocking-block** law, not an
index-presence one:

```
LHS (golden): hier_path: (input_intf.cb.data_status), id:1479, 53:11-53:36
              { ref_obj(input_intf) 53:22-24, ref_obj(cb) 53:22-24, ref_obj(data_status) 53:25-36 }
RHS (ours):   hier_path: (input_intf.data_status),    id:1963, 53:11-53:36
              { ref_obj(input_intf) 53:25-36, ref_obj(data_status) 53:25-36 }
```

Golden keeps the modport clocking-var `cb` as a path COMPONENT; we drop it. Out
of this pass's territory, correctly filed as R1.

---

## 1. EVERY NUMBER, MINE BESIDE THEIRS

| gate / measure | implementer | **verifier (independent)** | |
| --- | --- | --- | --- |
| GATE 1 pristine `bc6abbb` md5 | `d1ccd848dd088a9b37918cb944336423` | **`d1ccd848dd088a9b37918cb944336423`** | ✅ bit-identical |
| GATE 1 shipped md5 | `c8afd5decdfde67a959062181263f06d` | **`c8afd5decdfde67a959062181263f06d`** | ✅ bit-identical |
| GATE 1 `Linking CXX executable slang-uhdm` grep | 1 each | **1 each** | ✅ |
| GATE 2 goldens PASS / FAIL | 23 / 0 | **23 / 0** | ✅ |
| GATE 2 `SLANG_UHDM=/bin/false` control | 0 / 23 | **0 / 23** | ✅ |
| GATE 3 u2r testflags | 679 / 50 / 2 | **679 / 50 / 2** | ✅ |
| GATE 3 dump column | 496 match / 183 differ / 52 | **496 / 183 / 52** | ✅ |
| GATE 3 ct8rows | 0 differing ROWS (0 row-sides) | **0 / 0** | ✅ |
| GATE 4 default | 467 / 13 (+5 DEFERRED) | **467 / 13 / 5 DEFERRED** | ✅ |
| GATE 4 testflags | 463 / 10 (+5 DEFERRED) | **463 / 10 / 5 DEFERRED** | ✅ |
| GATE 4 dump match default / testflags | 225 / 165 | **225 / 165** | ✅ |
| GATE 4 ct8rows | 0 differing ROWS | **0 differing ROWS** | ✅ |
| GATE 5 u2r movers | 0 / 679 | **0 / 679** | ✅ |
| GATE 5 u2r SELFCHECK / SELFCHECK1 | 678 / 1 | **678 / 679, 1** | ✅ |
| GATE 5 surelog movers | 9 / 953 | **9 / 953, same 9 names** | ✅ |
| GATE 5 surelog SELFCHECK / SELFCHECK1 | 952 / 10 | **952 / 953, 10** | ✅ |
| CANARY ctcan2 u2r (EXPECT_UNKNOWN=6) | ok=1 changed=0 absent=0 unknown=6 | **ok=1 / 0 / 0 / 6** | ✅ |
| CANARY ctcan2 surelog (EXPECT_UNKNOWN=1) | ok=58 changed=0 absent=0 unknown=1 | **ok=58 / 0 / 0 / 1** | ✅ |
| CANARY `r10uvm52repro/canaries.sh` u2r | ok=8 changed=0 absent=0 | **ok=8 / 0 / 0** | ✅ |
| CANARY `r10uvm52repro/canaries.sh` surelog | ok=52 changed=0 absent=0 | **ok=52 / 0 / 0** | ✅ |
| CANARY `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 | **29 / 0 / 0** | ✅ |
| BY NAME InterfaceModPort / BlackParrotComplex | OK both modes | **CMP_EQUAL,,,differ ×4, byte-identical** | ✅ |
| SVSwitch head DEPTH pristine → patched | 78 → 74 | **78 → 74**, heads=1 each | ✅ |
| SVSwitch dump +/- | 2578 → 2548 | **2578 → 2548** | ✅ |
| SVSwitch MULTISET distance | 1950 → 1926 | **1950 → 1926** | ✅ |

Mover attribution, all nine, my own `mv4.sh`/`msmovers.sh` runs. **ADDED and
REMOVED reported separately, never summed:**

| mover | msdist pristine → patched | moved | CONV | DIV | LAT | ADDED | REMOVED | vs theirs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SVSwitch (both modes) | 1950 → **1926** | 28 | 25 | 3 | 0 | 10 | 8 | ✅ identical |
| BuildUVMPkg (both) | 82500 → **82274** | 222 | 206 | 16 | 0 | 63 | 113 | ✅ identical |
| SeqDriver (both) | 369300 → **368714** | 353 | 333 | 19 | 1 | 93 | 210 | ✅ identical |
| SimpleUVM default | 146169 → **145869** | 295 | 278 | 17 | 0 | 85 | 163 | ✅ identical |
| SimpleUVM testflags | 146165 → **145865** | 295 | 278 | 17 | 0 | 85 | 163 | ✅ identical |
| Scoreboard default | 136425 → **136127** | 294 | 277 | 17 | 0 | 85 | 162 | ✅ identical |

Every distance falls. `Scoreboard`/`default` is the known run-to-run flake
(macro-buffer `SourceLocation`); it did **not** flake in my run — its numbers came
out identical to theirs, and my whole-row judge read 0 differing rows.

`shapecount.sh`, the no-over-fire proof, reproduced on all five surelog movers:

| test | `hier_path (this.…[…])` | `bit_select` w/ `this.<m>[` | `var_select` w/ `this.<m>[` | CONTROL `bit_select` `::`+`[` |
| --- | --- | --- | --- | --- |
| SVSwitch | G=0 P=3 **A=0** | G=0 P=2 **A=0** | 0/0/0 | G=2 P=4 **A=2** |
| BuildUVMPkg | G=0 P=42 **A=0** | G=0 P=28 **A=0** | 0/0/0 | G=558 P=574 **A=546** |
| SeqDriver | G=0 P=108 **A=0** | G=0 P=72 **A=0** | 0/0/0 | G=1172 P=1224 **A=1152** |
| SimpleUVM | G=0 P=54 **A=0** | G=0 P=36 **A=0** | 0/0/0 | G=636 P=656 **A=620** |
| Scoreboard | G=0 P=54 **A=0** | G=0 P=36 **A=0** | 0/0/0 | G=636 P=656 **A=620** |

The invariant hits golden's 0 everywhere, and the control delta equals the erased
count to the unit in every test (`4−2=2`, `574−28=546`, `1224−72=1152`,
`656−36=620`). I also read the row their table omitted — `hier_path (this.…)`
BARE dotted name — and it is the strongest single number in the pass on
**SVSwitch: G=66 P=63 A=66, an exact hit on golden.** On the four UVM movers the
bare count rises past golden (SeqDriver G=3572 P=3912 A=4008), which is the
arithmetic their §6.5 already reconciles and which I re-derived independently:
total this-rooted paths `3912+108 = 4020 → 4008+0 = 4008`, so our SURPLUS over
golden fell `448 → 436`. Their §6.5 is right.

**DIVERGED verified, not taken on trust.** SVSwitch's 3 are one root cause:
`\_assignment: , line:38:6, endln:38:20` **G=1 P=1 A=2** plus two depth-keyed
`|vpiParent:` aggregates. I read the block and confirmed the cause — golden
parents the assignment's LHS ref at an artifact `hier_path: (pkt)`, we parent it
at the `assignment`, so the assignment line prints once more. `ref_obj::Compare`
reads no parent ⇒ dump-only. Their R6 is exact. SeqDriver's 19 and
BuildUVMPkg's 15 aggregate keys all have **golden's count exceeding ours both
before AND after** (e.g. `|vpiParent:` G=26635 P=25417 A=25411), i.e. a
pre-existing deficit our spurious objects were padding — as claimed.

**The BuildUVMPkg "cancelling errors" claim: CONFIRMED by owning context**, which
is the only way to see it:

```
$ grep -B4 -F "|vpiFullName:uvm_pkg::uvm_mem_mam::release_region::i" <dump> | grep -oE '\\_[a-z_]+: \([^)]*\)'
golden        : 2 × \_method_func_call: (this)      <- the delete(i) ARGUMENTS
pristine ours : 2 × \_bit_select: (…this.in_use[i]…) <- our spurious path indices
patched  ours : neither
```

Two unrelated errors cancelling in the total; the law deleted our wrong two and
UNMASKED the fact that golden's right two were never ours (their R4). Correct.

---

## 2. PATCH SCOPE — clean

```
$ git status --short results/ scripts/ tests/     # BEFORE apply
(empty)
$ git apply --check --verbose /tmp/r10svs4.patch  # all 14 files, no error
$ git apply /tmp/r10svs4.patch && git status --short
 M include/UhdmExporter.h
 M src/ExprEmit.cpp
?? tools/probe/r10svs4repro/
$ git status --short results/ scripts/ tests/     # AFTER apply
(empty)
$ md5sum results/gate_uhdm2rtlil.csv results/golden_surelog.csv   # == main tree, byte for byte
b8e5e57796326d48006221f056b28d42  results/gate_uhdm2rtlil.csv
ac4cab4119732769756cee08325dd99e  results/golden_surelog.csv
```

`git apply --stat` full output: 14 files, `include/UhdmExporter.h` (9),
`src/ExprEmit.cpp` (185), `tools/probe/r10svs4repro/*` (12 files, 1264).
**No `results/*.csv`, no `scripts/`, no `tests/`, no slang.** md5 `26215bf6f6f5673c97af902127992ed1`
confirmed; `git apply --check` clean against pristine `bc6abbb`.

**NO COLLISION with either concurrent pass.**
* r10uvm58 (class-method return variables): its landed commit `81b8e0c` touches
  `UhdmExporter.h`, `EmitHelpers.h`, `StmtEmit.cpp`, `TaskFuncEmit.cpp`,
  `UhdmExporter.cpp` — **not `ExprEmit.cpp`**, which is where all 185 production
  lines of this patch live. `grep -nE '^\+.*(ret_var|returnVar|ReturnStatement|ref_var|retName)' /tmp/r10svs4.patch`
  matches only README prose, no code. Overlap is a possible textual merge in the
  header only (integrator's problem, not a semantic one).
* r10earl29 (concat-index TEXT rendering inside hier_path names): the added code
  builds its name from MEMBER NAMES ONLY — it calls neither `spaceIdxOps` nor
  `rawText` and contains no index-text rendering at all, so it **structurally
  cannot** change that text. I verified this is not merely unexercised: my cell
  v18 shows golden's index-text form (`pkt.data[]`) still unmatched and
  **unchanged** by the patch, exactly where r10earl29's territory begins.

---

## 3. HUNTING THE EMPTY PRODUCT CELLS

Their grid varied receiver × index kind × position × array kind. **The axis it
never varied is WHAT THE SELECT IS**: every measured cell selects an element out
of an unpacked collection. A BIT select of a packed vector, a packed-struct field
bit select, a STRING index and a PARTIAL 2-D index are all `ElementSelect` /
`RangeSelect` in slang too — same call site, same predicate, unmeasured verdict.
Three new arms, 28 + 9 + 8 cells: `v1_empty.sv`, `v2_copy.sv`, `v3_escaped.sv`.

Arm `v1_empty.sv` moved `dump content +/- 887 → 509` and multiset **817 → 439**.

| cell | source | GOLDEN | patched matches? |
| --- | --- | --- | --- |
| v1 | `this.vec[3]` **BIT select of a PACKED vector** | erased → `hier_path (this.vec)`, 2 `ref_obj` | **yes, byte-for-byte** |
| v3 | `this.vec[5:2]` **PART select of a packed vector** | erased | **yes** |
| v5 | `this.ps.f[2]` packed-STRUCT field bit select | **golden CONSTANT-FOLDS it** | no — LATERAL, pre-existing fold gap (same family as their d2/d6) |
| v7 | `this.vv[k][3]` elem-then-bit on a PACKED element | erased (handle twin is a `var_select`) | **yes** |
| v9 | `this.s[k]` **STRING index** | erased | **yes** |
| v11 | `this.m2[k]` **PARTIAL index of a 2-D array** | erased | **yes** |
| v13 | `this.child[k].fld` handle-in-array then member | erased → `this.child.fld`, 3 `ref_obj` | **yes** |
| v15 | `this.child[k].bump()` | surelog rejects the cell (CP0332) — not comparable | n/a |
| v17 | `this.ch.data[k] + 1` | **golden CONSTANT-FOLDS it** (null handle) | no — LATERAL, = their d2 |
| v18 | `pkt.data[this.data[k]] = …` **this-path as index, LVALUE** | golden names the outer path `pkt.data[]` — EMPTY brackets | no — R5, pre-existing, r10earl29's text territory |
| v19 | `this.data[k] + pkt.data[k]` both receivers, one op | this erased, pkt kept | **yes, both** |
| v20 | `this.data[k]++` **read-modify-write** | erased; leaf is NOLOC + scoped fullname (LVALUE convention) | cmp fields yes; **span/fullname no — finding F2** |
| v21 | `{this.data[k], this.data[k+1]}` CONCATENATION | both erased | **yes, both** |
| v22 | `$display("%0d", this.data[k])` SYSTEM-call arg | erased, parented at the `sys_func_call` | **yes** |
| v23 | `this.q.push_back(this.data[k])` builtin-method arg | `method_func_call (this)` + erased argument | no — **pre-existing**, pristine identical (their R4) |
| v24 | `(k>0) ? this.data[k] : 0` ternary arm | erased | **yes** |
| v25 | `case (this.data[k])` CASE selector | erased | **yes** |
| v26 | `this.aa[this.data[k]]` this-path index of a this-path | outer erased, inner vanishes | **yes** |
| v27 | `this.data[k]` in a **PARAMETERIZED class** | erased | **yes** |
| v28 | `this.data[k] = …` parameterized class LVALUE | erased, NOLOC + `work@Pgrid::f::data` | **yes, byte-for-byte** |
| v2,4,6,8,10,12,14,16 | every `pkt.` twin | kept | **yes, untouched** |

**12 newly-measured in-scope cells, 12 golden-erased, 12 matched byte-for-byte.**
No over-fire on any legitimate `this`-keyword shape. Two cells (v5, v17) sit
where golden constant-folds: both wrong before and after, LATERAL, and the
patched build is no worse than pristine.

I also re-ran their own three arms cell-by-cell rather than trusting the table.
Their claim "all 18 in-scope indexed cells match golden byte-for-byte including
spans" **holds**: in `g1_thisidx.sv` the only three lines that differ are c21
(handle `var_select` span, pre-existing), c22 (the declared R2 unindexed control)
and c25 (the declared R5); in `g2_thisdeep.sv` d1/d4/d5/d7/d9 match exactly and
every mismatch is one they declared — including d8, where I confirm golden really
does emit `hier_path (this.@@BAD_SYMBOL@@)` and their refusal to imitate a
resolver failure is right; in `g3_assoc.sv` **all five hier_paths match**,
confirming r10svs3's `§ thisSuperNewAssignNoStmt3` is undisturbed.

---

## 4. FINDINGS, most severe first

### F1 — MEDIUM / cmp-VISIBLE / latent (0 corpus rows). The stated gate is NOT the gate in the code: `symbol.name == "this"` is a NAME test, and escaped identifiers break it.

The shipped predicate and its comment:

```cpp
    // The WRITTEN keyword is the gate. slang names the implicit self variable
    // `this`, and names it that ONLY when the keyword was written ..., so the name
    // test IS the written-keyword test.
    if (nv.symbol.name != "this")
        return nullptr;
```

**That parenthetical is false.** SystemVerilog escaped identifiers make `\this `
a perfectly ordinary variable whose `symbol.name`, after the escape is stripped,
is exactly `this`. Counterexample, `v3_escaped.sv` cells x6/x8 — **module scope,
no class, no self, no keyword**:

```systemverilog
typedef struct { byte arr[4]; byte s; } holder_t;
module mesc3;
   holder_t \this ;
   initial begin
      r = \this .arr[k];    // x6
      \this .arr[k] = 8'h9; // x8
   end
endmodule
```

```
x6  GOLDEN   hier_path: (this.arr[k])  + bit_select (work@mesc3.this.arr[k].arr) + ref_obj(k)
    PRISTINE hier_path: (this.arr[k])  + bit_select (work@mesc3.this.arr[k].arr) + ref_obj(k)   <- MATCHES golden
    PATCHED  hier_path: (this.arr)     + ref_obj(this) + ref_obj(arr)                            <- index ERASED, ref_obj(k) DROPPED
```

Both fields the pass itself localized as the gating ones regress:
`hier_path::VpiName` goes `this.arr[k]` (= golden) → `this.arr` (≠ golden), and
the element `VpiType` goes `bit_select` (= golden) → `ref_obj` (≠ golden). x8
(lvalue) behaves the same. The `mems.empty()` guard does absorb the *bare*
escaped select (`\this [k]`, cells x1–x3 byte-identical pristine vs patched) —
only the dotted-member form reaches the predicate.

**Blast radius today: zero, and grep-proven:**

```
$ grep -rlE '\\this[ \t]' ~/git-repos/Surelog/tests ~/git-repos/Surelog/third_party/tests \
        ~/git-repos/Surelog/third_party/UVM ~/git-repos/uhdm2rtlil/test \
        --include=*.sv --include=*.svh --include=*.v --include=*.vh
(no output)
```

That is why no gate moves. Two mitigating facts, stated fairly: (a) the same
string convention already exists PRE-patch at `src/ExprEmit.cpp:2067`
(`dotted.rfind("this.", 0) == 0`), so the pattern is inherited, not invented —
though at that site the escaped cell was *already* dump-only-wrong (my x7 shows
pristine and patched both mis-emit `\this .s`), whereas the new site flips two
**cmp-visible** fields from right to wrong; (b) one interesting fact in the
predicate's favour, discovered while building the arm: **inside a class slang
resolves the name `this` to the implicit self even when an escaped member
`\this` is declared**, so `\this [k]` in a class method does not compile at all
("value of type 'Cesc' cannot be indexed"). The exposure is module scope only.

**Required action, either one:** narrow the predicate to the symbol's IDENTITY —
slang stores the implicit self as `ClassType::thisVar` / `SubroutineSymbol::thisVar`
(`~/git-repos/slang/source/ast/symbols/ClassSymbols.cpp:256`,
`SubroutineSymbols.cpp:937`), and a cheap sufficient narrowing is to additionally
require the base to be of class type (`cur->type->isClass()`, which excludes the
`holder_t` struct of x6) — **I did not build and verify that line, so treat it as
a proposal, not a measurement** — OR strike the "ONLY when the keyword was
written" sentence and state plainly that the gate is a name comparison with a
known escaped-identifier counterexample and zero corpus incidence. The standing
law is "the stated gate must be the gate in the CODE"; today it is not.

### F2 — LOW / cmp-INVISIBLE / new. A read-modify-write target gets the RVALUE span/name convention where golden uses the LVALUE one.

Cell v20, `this.data[k]++`:

```
GOLDEN   hier_path (this.data) 63:7-63:19 { ref_obj(this) 63:12-16,
                                            ref_obj  vpiName:data  vpiFullName:work@Vgrid::f::data  NOLOC }
PATCHED  hier_path (this.data) 63:7-63:19 { ref_obj(this) 63:12-16,
                                            ref_obj  vpiName:data  (no fullname)  63:12-16 }
```

`VpiName` agrees (`data`), so `ref_obj::Compare` is satisfied and this can never
head — it is dump-only. Cause: the new code branches on `inLhs`, which slang
leaves false for `++`/`--`, so the rvalue arm runs. Note the surrounding code
uses the tighter `inLhs && inProcessEmit`; the new site uses bare `inLhs`.
Belongs with residue R2, whose brief already expects the dump histogram to move.

### F3 — LOW / latent over-fire of LAW 2 (0 corpus rows). `CopyClass` into a target where golden emits NO statement at all.

`v2_copy.sv`. Golden emits **nothing** at the `this`-rooted and
declaration-initializer targets; pristine already emitted a spurious assignment
there (r10svs3's no-statement law covers `new()`, not `CopyClass`); the new arm
makes each spurious statement **one object larger**:

| cell | source | GOLDEN | PRISTINE | PATCHED |
| --- | --- | --- | --- | --- |
| w2 | `this.p = new gp;` | nothing at line 27 | assignment + hier_path (spurious) | + `ref_obj(gp)` argument |
| w4 | `this.parr[0] = new gp;` | nothing at line 29 | spurious, index kept | spurious, index erased, + argument |
| w8 | `P dp = new gp;` decl init | typespec + var only | spurious assignment | + `ref_obj(gp)` argument |
| w1/w7 | plain local target | assignment + `method_func_call (new)` + arg | **Rhs was NULL** | **matches golden** |
| w9 | module scope `np = new gp;` | assignment + `ref_obj(work@mw.gp)` | **`gp` ref MISSING** | **gains it — converges** |

Arm multiset **233 → 208**, so law 2 is net-positive even on an arm built to
stress it. Corpus incidence of the bad cells: none — every live `= new <handle>`
site is in `ovm-2.1.2` / `vmm-1.1.1a` or commented out, and none has a
`this`-rooted target. On SVSwitch itself `\_method_func_call: (new)` goes
G=27 **P=24 → A=26**, i.e. toward golden. File as a residue.

### F4 — LOW / documentation. §6.4's context table quotes 8 / 8 / 6; the anchored key is 6 / 6 / 4.

```
$ grep -cE '^\s*\|vpiFullName:uvm_pkg::uvm_mem_mam::release_region::i$' <dump>
golden 6   pristine 6   patched 4
$ grep -Fc  '|vpiFullName:uvm_pkg::uvm_mem_mam::release_region::i'      <dump>
golden 8   pristine 8   patched 6
```

The 8s are the *unanchored* count, which also matches
`…release_region::in_use` (the shorter key is a prefix of the longer). The
conclusion is untouched — equal totals before, a drop after, and I confirmed the
cancellation by owning context (§1) — but the quoted figures should be anchored.

### F5 — LOW / undocumented. SeqDriver's one LATERAL overshoots golden and is never named.

```
LATERAL  RECOUNT  G=103  P=106  A=100   |vpiName:map
```

We were 3 dump-occurrences over golden and are now 3 under. The README reports
"LATERAL 1" without naming the key. Dump-occurrence aggregate on a back-pointered
name, cmp-invisible, but a LATERAL that crosses golden should always be named.

### F6 — INFO / residue-worthy. Erasing the select also erases the index expression's `refCollector` sighting.

The predicate never emits the index subtree, so a symbol referenced **only**
inside such an index is never inserted into `refCollector`. Consistent with
SeqDriver `|vpiName:i` **G=165 P=155 A=154** (one occurrence further from golden
on that aggregate, while golden exceeds us on both sides). Zero row cost, and the
invariant shapes still hit golden exactly — flagged because MEMORY records alias
population as build-dependent, so this is the kind of thing that shifts under a
later unrelated edit.

### F7 — INFO / a nuance R5 omits. Golden's index-text suppression on the OUTER handle path is POSITION-dependent.

* rvalue `pkt.data[this.data[k]]` → golden names it **`pkt.data`** (their c25).
* LVALUE `pkt.data[this.data[k]] = …` → golden names it **`pkt.data[]`** — empty
  brackets, not dropped brackets (my v18).

R5 records only the rvalue form. This is index-TEXT rendering inside a hier_path
name, i.e. r10earl29's territory, so leaving it alone was right; whoever picks R5
up must know golden has two forms.

---

## 5. RANKED RESIDUES (theirs, re-ranked with mine folded in)

1. **F1 — narrow the `this` predicate or strike its stated gate.** One line or
   one sentence; the only item I consider blocking.
2. **R1 — clocking-block `cb` as a hier_path COMPONENT.** SVSwitch's new head,
   fully characterised, and MEMORY prices the clocking/modport family at a
   41-test interface cluster. **Check the r10earl29 collision first** — it edits
   interface-member name synthesis.
3. **R4 + F3 — the `this.<member>.<builtin>(args)` shape**, now the load-bearing
   deficit in four UVM tests. Golden: `method_func_call (this)` + `vpiPrefix`
   constant `vpiDecompile:this` + the erased argument (I confirmed the shape at
   `v1_empty.sv:66` and `uvm_mem_mam.svh:783`). F3's `CopyClass`-into-a-
   no-statement-target belongs in the same pass.
4. **R2 + F2 — the UNINDEXED `this.<member>` span/name shape and the `++`
   convention.** Both cmp-invisible, both would move every class test's dump
   column, so both need a brief that expects gates 3/4 to move.
5. **R3 — `super`-rooted paths emit no hier_path at all.** Golden's verdict is
   measured (`hier_path (super.data)`, identical in form to the `this` law) and I
   reconfirmed it at `g2_thisdeep.sv:33`. Needs the keyword recovered from
   syntax; do NOT widen the name test.
6. **R5 + F7 — a this-rooted path used as an INDEX.** Two golden forms, not one.
   r10earl29's text territory.
7. **The constant-fold family (their d2/d6, my v5/v17)** — golden folds
   `this.h.data[k]`, `this.data.size()` and `this.ps.f[2]`; we emit paths. LATERAL
   today, and the fold gap will keep producing spurious this-paths (part of the
   436-occurrence surplus).
8. **R6 — assignment-LHS handle ref parents at an artifact `hier_path`.**
   Dump-only, verified, the whole of SVSwitch's DIVERGED column.
9. **F6 — index-only symbols lose their refCollector sighting.**
10. **R7 — `.` vs `::` in a handle-rooted leaf fullname.** Reconfirmed at d10/v14.

---

## 6. PROCESS NOTES

Both of the implementer's self-reported process slips check out and neither
contaminates a number. The `GOLDEN_DEFER=1` trap is real: `verify_golden.py:161-167`
treats a non-`0` value as a **comma-list of test names**, so `GOLDEN_DEFER=1`
sets the defer set to the literal name `1` and runs the five OOM/timeout tests.
Their re-run was necessary and my own gate 3/4 runs (env unset) show the mandated
**5 DEFERRED**. I found no stray file outside my own worktrees.

Reproduce this record:

```bash
git worktree add -b r10svs4vwt .claude/worktrees/r10svs4v      bc6abbb
git worktree add --detach      .claude/worktrees/r10svs4vpris  bc6abbb
cd .claude/worktrees/r10svs4v && git apply /tmp/r10svs4.patch
# both trees: cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
#   -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DCMAKE_PREFIX_PATH=$HOME/.local
#   && cmake --build build -j 8   (WAIT for "Linking CXX executable slang-uhdm"; md5 in a SEPARATE command)
R=tools/probe/r10svs4repro
$R/svsarm.sh $R/v1_empty.sv   /tmp/v_g1pat  $PWD/build/slang-uhdm   # the empty product cells
$R/svsarm.sh $R/v2_copy.sv    /tmp/v_g2pat  $PWD/build/slang-uhdm   # LAW 2's cells
$R/svsarm.sh $R/v3_escaped.sv /tmp/v_g3bpat $PWD/build/slang-uhdm   # F1's counterexample
$R/gridread.sh /tmp/v_g1pat/g.dump /tmp/v_g1pat/o.dump 'hp\['        # read cells side by side
```

New verifier files: `v1_empty.sv` (28 cells), `v2_copy.sv` (9), `v3_escaped.sv`
(8, incl. F1). All sweep workdirs (`/tmp/v_svs4*wd`) deleted.
