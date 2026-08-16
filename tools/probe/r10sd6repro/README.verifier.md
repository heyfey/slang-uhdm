# r10sd6 — ADVERSARIAL VERIFIER REPORT

## VERDICT

**PARTIAL on the SHIPPED patch** (`/tmp/r10sd6.patch`, md5
`5a440d46ff2af1a2dcf780952f7e22aa`). **PASS on the re-cut**
`/tmp/r10sd6.verified.patch`.

The law is real, the 43-line head is genuinely cleared on **both** SeqDriver
rows, and **every number in the implementer's report reproduces exactly** —
both binary md5s bit for bit on builds I configured and ran myself, all five
gates, the whole-population census (52/37/38, delivered `diff` vs golden
**identical line for line**), the five movers with every size delta, the
per-shape multiset, the three distances to golden, the mover prediction name for
name, the masking experiment, all four canary drivers, and the brief's
four-branch refutation.

Three things stop it being a clean PASS. One of them is a code defect that would
have landed.

* **F1 (STATED GATE != CODE GATE, latent under-fire, FIXED in the re-cut).**
  The header claims the walk *"descends operations, **selects** and call
  arguments — the same shape as `bindInitRefsIn47`"*. **It does not descend
  selects.** `bit_select`, `part_select`, `indexed_part_select` and `var_select`
  are all `final : public ref_obj`, and UHDM's `any_cast` is **is-a**, so the
  `ref_obj` arm at the top claims every one of them and `return`s — the
  `case UHDM::uhdmbit_select:` and `case UHDM::uhdmpart_select:` arms below it
  are **unreachable dead code**. `bindInitRefsIn47` is safe because it
  dispatches on `UhdmType()`, which is exact; this function copied the cases and
  not the dispatch. Golden disagrees on **three measured cells**; **zero corpus
  witnesses**, so no gate breaks and it would have shipped as a latent defect
  *documented as covered*. **Fixed and re-verified below.**

* **F2 (an instrument is unsound on one of the five movers).** `Scoreboard`
  `default` is **nondeterministic at BASE `e07cb9c`**: the **pristine** binary
  produces **3 distinct md5s in 5 runs** at **one** size. `byteverify.sh`
  compares md5s, so it will report that row as a mover **between a binary and
  itself**. The 5-mover claim survives — the **size** delta is stable (+340) and
  `ct6pred` named the same five rows from the artifact — but the md5 evidence
  cited for Scoreboard carries nothing on its own. The implementer's own
  `detcheck.sh` exists for exactly this and was run only on grid cell `g6`, a
  20-line, 10 212-byte file. Ranked **R1**; driver `vsd6det.sh` added.

* **F3 (hygiene).** The shipped patch contains
  `tools/probe/r10sd6repro/__pycache__/dumptree.cpython-311.pyc` — a compiled
  Python artifact. In scope directory-wise, but it is build output. Removed in
  the re-cut.

And one refutation of the law's own wording, which costs nothing today but
would mislead the next pass:

* **F4.** *"**every** `ref_obj`/`ref_var` in the copied initialiser is re-named
  onto the copy's owner chain"* is **false as stated**. Cell `v3`
  (`int b3 = st3.f3;`): golden re-names the path's **second** element to
  `q3::c3::b3::f3` and leaves the **first** as the bare `st3` — on both sides.
  A blanket implementation would over-fire on element 0. The shipped code never
  reaches a `hier_path`, so this is a defect in the LAW STATEMENT, not in the
  binary. Ranked **R2**; the re-cut records the counterexample at the call site
  rather than acting on it.

LHS is **ALWAYS golden** (Surelog); RHS is **ALWAYS ours**, everywhere below.

---

## 0. WHAT I BUILT, AND THE ANCHORS

Applied to a **FRESH `e07cb9c`** obtained with `git worktree add --detach` —
not to the implementer's tree, and not to `bd4b122` (main's head; `r10uvm74`
landed during this pass). Both the shipped patch and my re-cut
`git apply --check` clean at `bd4b122` as well as at BASE, and `r10uvm74` is
`src/ExprEmit.cpp`-only — **no file overlap**.

| worktree | base | content | md5 of `build/slang-uhdm` |
|---|---|---|---|
| `/tmp/wt_sd6vpris` | `e07cb9c` | pristine, `git status --porcelain` **empty** | **`1831781597e37e8817f84e1e6d225dd4`** |
| `/tmp/wt_sd6v` | `e07cb9c` | + SHIPPED patch | **`032d68d611c8fc7154c7a367d1abe24d`** |
| `/tmp/wt_sd6vfix` | `e07cb9c` | + patch + my F1/F3 fix | **`d3ba485bea4629971cf4e84de193c233`** |

```bash
cmake -S <wt> -B <wt>/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++
cmake --build <wt>/build -j 2      # WAIT for the link line, THEN md5
grep -E "Linking CXX executable|Built target slang_uhdm$" bld.log
md5sum <wt>/build/slang-uhdm       # separate command, 32 hex
git -C <wt> rev-parse HEAD | grep -c '^e07cb9c01fb9367b549626e4a3eff8490a4fdf58$'
```

**Both claimed md5s reproduced bit for bit.** `[100%] Linking CXX executable
slang-uhdm` → `[100%] Built target slang_uhdm` read **before** any md5 in every
build; `grep -c 'error:'` = **0** in all three logs; every BASE printed **and**
grep-checked = **1**.

`git stash` never used. slang never patched. `results/*.csv` only ever READ
(`ct8rows.sh` is the only reader). `GOLDEN_DEFER` echoed **`[UNSET]`** at every
sweep launch. Sweeps `--jobs 2`, own `--out`/`--workdir` under `/tmp/sd6vs`.

### SLANG_UHDM pin — verified by reading every `cmds.txt`, not by trusting the export

```bash
for r in u2r sl; do for t in pris del; do
  echo "$r/$t: cmds.txt=$(find /tmp/sd6vs/wd_${r}_$t -name cmds.txt|wc -l) \
with-slang-line=$(grep -rl '^slang:' /tmp/sd6vs/wd_${r}_$t --include=cmds.txt|wc -l)"
done; done
grep -rh '^slang:' /tmp/sd6vs/wd_sl_del /tmp/sd6vs/wd_u2r_del --include=cmds.txt \
  | awk '{print $2}' | sort -u
```
```
u2r/pris: cmds.txt=1462 with-slang-line=1458    sl/pris: cmds.txt=1573 with-slang-line=1523
u2r/del : cmds.txt=1462 with-slang-line=1458    sl/del : cmds.txt=1573 with-slang-line=1523
/tmp/wt_sd6v/build/slang-uhdm          <- delivered sweeps name exactly ONE binary
/tmp/wt_sd6vpris/build/slang-uhdm      <- pristine sweeps name exactly ONE binary
```
**1523 + 1458**, the implementer's figures exactly, and **0** naming any other
binary.

### Patch hygiene

`git apply --stat` on a pristine `e07cb9c`: **40 files, +4041 −0**.
`src/ModuleEmit.cpp` **+77 −0** is the only production file; everything else is
under `tools/probe/r10sd6repro/`. No probe writes to `results/`; none touches
`GOLDEN_DEFER`; `ct6arm.sh` and `ct6grid.sh` give `SLANG_UHDM` **no default**
(`${SLANG_UHDM:?}`) — the trap that a stale main-tree binary reads as green.
**No `README.verifier.md` in the shipped patch** (it is mine — this file).

**F3:** one file is build output —
`tools/probe/r10sd6repro/__pycache__/dumptree.cpython-311.pyc`. Removed in the
re-cut.

---

## 1. FINDINGS

### F1 — the SELECT arms are UNREACHABLE DEAD CODE, and the stated gate is not the code gate

`importCopyRefs6` is written as

```cpp
if (auto* ro6 = any_cast<UHDM::ref_obj*>(e)) { …rename…; ro6->Actual_group(nullptr); return; }
if (auto* rv6 = any_cast<UHDM::ref_var*>(e)) { … return; }
switch (e->UhdmType()) {
    case UHDM::uhdmoperation:   …operands…     return;
    case UHDM::uhdmbit_select:  …VpiIndex…     return;   // <- never reached
    case UHDM::uhdmpart_select: …L/R ranges…   return;   // <- never reached
    default: break;
}
```

and the header claims it *"descends operations, **selects** and call arguments —
the same shape as `bindInitRefsIn47`"*. The shape is **not** the same.
`bindInitRefsIn47` opens with `switch (e->UhdmType())`, which is **exact-type**,
so its select cases are live. `importCopyRefs6` opens with `any_cast`, which is
**is-a** (`RTTI.h`'s `AsOfTypeRecurse` walks the whole base chain), and every
select spelling derives from `ref_obj`:

```
$ grep -n 'class .*: public ref_obj' ~/.local/include/uhdm/*.h
bit_select.h:41:          class bit_select          final : public ref_obj
part_select.h:41:         class part_select         final : public ref_obj
indexed_part_select.h:41: class indexed_part_select final : public ref_obj
var_select.h:41:          class var_select          final : public ref_obj
```

Mechanical proof rather than inference — `vsd6rtti.cpp`, which constructs each
node and casts it:

```
any_cast<ref_obj*>(bit_select)          = NON-NULL  -> intercepted
any_cast<ref_obj*>(part_select)         = NON-NULL  -> intercepted
any_cast<ref_obj*>(indexed_part_select) = NON-NULL  -> intercepted
any_cast<ref_obj*>(var_select)          = NON-NULL  -> intercepted
any_cast<ref_obj*>(ref_var)             = null (ok, unrelated hierarchies)
```

**The behavioural consequence, measured on golden.** The `ref_obj` arm re-names
the select itself — which golden **does** want — and then returns, so the
select's **index / base** is never visited. `gridv/`, scored with `vsd6ref.cpp`
(which walks selects and paths, unlike `ct6clsref.cpp`, whose `walkExpr` has the
identical is-a blindness and therefore **cannot see this cell**):

| cell | node | GOLDEN | pristine | SHIPPED | re-cut |
|---|---|---|---|---|---|
| `v1` `logic b1 = a1[idx1];` | root `bit_select` | `q1::c1::b1::a1`, null | `p1::b1::a1` | **==GOLDEN** | ==GOLDEN |
| | index `ref_obj` | `q1::c1::b1::idx1`, **null** | `p1::b1::idx1`, **BOUND** | **`p1::b1::idx1`, BOUND** ✗ | **==GOLDEN** |
| `v8` `int b8 = arr8[i8];` | root `bit_select` | `q8::c8::b8::arr8` | `p8::b8::arr8` | **==GOLDEN** | ==GOLDEN |
| | index `ref_obj` | `q8::c8::b8::i8`, null | `p8::b8::i8`, BOUND | **`p8::b8::i8`, BOUND** ✗ | **==GOLDEN** |
| `v5` `logic[3:0] b5 = a5[i5 +: 4];` | root `indexed_part_select` | `q5::c5::b5::a5` | `p5::b5::a5` | **==GOLDEN** | ==GOLDEN |
| | base `ref_obj` | `q5::c5::b5::i5` | `p5::b5::i5` | **`p5::b5::i5`** ✗ | **==GOLDEN** |
| `v2` `int b2 = f2(a2);` | arg `ref_obj` | `q2::c2::b2::a2`, null | `p2::b2::a2`, BOUND | **==GOLDEN** ✓ | ==GOLDEN |
| `v6` `logic[7:0] b6 = {a6,a6};` | both operands | `q6::c6::b6::a6`, null | `p6::b6::a6`, BOUND | **==GOLDEN** ✓ (`CMP_FAIL`→`PASS_CMP`) | ==GOLDEN |

`v1` goes **`CMP_FAIL` → `PASS_CMP`** on the re-cut. The call-argument and
operation arms — the two the implementer measured — are correct as shipped.

**Two arms are an EMPTY PRODUCT CELL and are named as such rather than claimed.**
`part_select`'s ranges: SV requires constant part-select bounds and they fold
before this point — cell `v7` (`a7[H7:0]` with a package **parameter** bound)
has **no nested reference on either side**. `var_select`: an unpacked element
select arrives as a `bit_select` (cell `v8`), never a `var_select`. The re-cut
descends them anyway, and says so in the code: the law is about the copy owning
its initialiser's references and cannot be conditioned on a spelling that cannot
be witnessed, and omitting them would rebuild the very dead-arm hazard.

**WITNESS HUNT — zero, which is why no gate broke.** `vsd6ref.cpp` over every
database both sweeps produced:

```bash
cd /tmp/sd6vs/wd_u2r_del && for f in $(find . -name slang.uhdm|sort); do
  /tmp/sd6v_ref "$f" | grep -E 'via=(bsIndex|psL|psR|ipsBase|ipsW|vsIndex|hpElem)'
done
```
```
scanned=1358 witnesses=0
SeqDriver / SimpleUVM / Scoreboard, golden AND ours: select/hier-nested refs = 0
```

So F1 breaks nothing today. It is a latent defect **documented as covered**, and
the documentation is what makes it dangerous: the next pass reading
`importCopyRefs6` finds two select cases and concludes selects are handled.

### F2 — `Scoreboard`/`default` is NONDETERMINISTIC at BASE, so `byteverify.sh`'s md5 verdict is unsound on it

The mover set is asserted from `byteverify.sh`, which compares **md5s**. Run the
**pristine** binary — the one with no patch at all — five times on that row:

```bash
tools/probe/r10sd6repro/vsd6det.sh /tmp/wt_sd6vpris/build/slang-uhdm 5 \
  ~/git-repos/Surelog/third_party/tests/Scoreboard <the row's own argv>
```
```
run 1: md5=6f06c6d79638b3e6  bytes=11138212
run 2: md5=6f06c6d79638b3e6  bytes=11138212
run 3: md5=edcbfee270e012d4  bytes=11138212
run 4: md5=0c936464296e24da  bytes=11138212
run 5: md5=6f06c6d79638b3e6  bytes=11138212
distinct md5=3  distinct sizes=1
ARENA-ORDER NONDETERMINISM (size stable): md5 movers on this row are NOISE
```

**Three distinct md5s from one binary, at one size.** A byte comparator run
pristine-vs-pristine would report `default/Scoreboard` as a mover. This is
pre-existing at `e07cb9c` — the patch does not cause it — and it matches the
campaign's standing note on emitter nondeterminism.

It bit me directly: my first `byteverify.sh` of the re-cut against the shipped
patch reported **`MOVER ./default/Scoreboard`**, and for a few minutes that read
as a regression I had introduced. It is noise. The sound comparison is by size:

```
SIZE-based fix-vs-del: surelog 953 compared, 0 size-differing
                       u2r    1358 compared, 0 size-differing
```

**What survives, and what does not.** Of the five movers, four are on
**deterministic** rows and are bit-for-bit solid (3 runs each, 1 distinct md5):

| row | pristine | shipped | re-cut | size delta |
|---|---|---|---|---|
| SeqDriver default/testflags | `e87f6633` | `618440bf` | `618440bf` | **+1856 / +1858** |
| SimpleUVM default/testflags | `105413fb` | `201de013` | `201de013` | **+285 / +281** |
| Scoreboard default | *3 hashes* | *2 hashes* | *4 hashes* | **+340** (stable) |

The Scoreboard mover **is real** — its size moves by a stable +340 and `ct6pred`
independently named it from the artifact — but the *evidence the report cites
for it* (md5 inequality) does not establish it. Report the size, not the hash,
on that row.

### F3 — a `__pycache__/*.pyc` in the delivered patch

```
diff --git a/tools/probe/r10sd6repro/__pycache__/dumptree.cpython-311.pyc …  Bin
```
Build output. Removed in the re-cut.

### F4 — the law's universal quantifier has a measured counterexample

> *"**every** `ref_obj`/`ref_var` in the copied initialiser is re-named onto the
> copy's owner chain … and left UNBOUND"*

Cell `v3` (`typedef struct { int f3; } s3_t; s3_t st3; int b3 = st3.f3;`),
golden:

```
HIER q3::c3  b3  hier_path  full=st3.f3
REF  q3::c3  b3  ref_obj via=hpElem name=st3  full=st3                  actual=<null>
REF  q3::c3  b3  ref_obj via=hpElem name=f3   full=q3::c3::b3::f3       actual=<null>
```

Golden re-names element **1** and leaves element **0** bare. A `hier_path` arm
written to the law as stated would rename `st3` to `q3::c3::b3::st3` and
over-fire. Our side leaves element 0 bare too, so today the two agree there and
disagree only on element 1 (`p3::b3::f3` vs `q3::c3::b3::f3`) — a residue with
**zero corpus witnesses**. The re-cut records the counterexample at the call
site and **does not** implement the arm: one cell is not a law.

---

## 2. EVERY CLAIMED NUMBER, REPRODUCED

### 2.1 The brief's hypothesis — REFUTED in all four branches (independently)

`ct6pkgv` on SeqDriver, `uvm_pkg`, both views:

```
ALL VARIABLES size=33      TOP VARIABLES size=33          (golden)
ALL [  2] class_var  uvm_default_table_printer  @610:19-610:52
          expr=method_func_call  ts=class_typespec(uvm_table_printer)  auto=1 vis=1
diff GOLDEN vs PRISTINE : 0 sides
diff GOLDEN vs DELIVERED: 0 sides
```

**33 == 33**, entry rows byte-identical in both views, on **both** binaries.
Golden does not omit the entry, does not strip its `vpiExpr(new)`, does not use
a different kind, and no earlier sibling shifts a slot. Every branch of the
brief's model is dead, exactly as reported.

### 2.2 The population census — delivered is `diff`-identical to golden

`ct6clsref`, all three UVM rows:

| row | classes / entries / refs | golden bound | pristine bound | delivered bound | `diff` del-vs-golden |
|---|---|---|---|---|---|
| SeqDriver | 336 / 1206 / **52** | 0 | **5** | **0** | **IDENTICAL** |
| SimpleUVM | 332 / 1094 / **37** | 0 | 2 | 0 | **IDENTICAL** |
| Scoreboard | 336 / 1103 / **38** | 0 | 2 | 0 | **IDENTICAL** |

(pristine-vs-golden: 50 / 20 / 20 differing sides.) Every figure as claimed.

### 2.3 The head — CLEARED on both rows, and the new head was already there

```
SeqDriver default   pristine cmp = 43 lines   delivered = 1 421 701
SeqDriver testflags pristine cmp = 43 lines   delivered = 1 421 701
```

Pristine head is the brief's target verbatim (`LHS <null>` /
`RHS class_var(uvm_pkg::uvm_default_table_printer) @610:19-610:52`, `vpiExpr ->
method_func_call(new)`). Delivered head is a **different** object.

`ct6mask` — seed `m_visited` with the 52 golden objects, re-run against the
**pristine** database:

```
PRISTINE db:  BASELINE LHS=<null> RHS=class_var(uvm_default_table_printer)@610:19-610:52
              -- seed = 52 objects
              SEEDED   LHS=<null> RHS=package(uvm_pkg)@28:1-39:11
DELIVERED db: BASELINE LHS=<null> RHS=package(uvm_pkg)@28:1-39:11
```

**Bit for bit the delivered binary's head.** The head advanced; it was masked.
Head SIZE is the failing object's subtree, not a distance — and the distance
moved the right way (§2.5).

### 2.4 Grid — cell for cell, on all three binaries

| cell | GOLDEN | pristine | shipped | re-cut | cmp |
|---|---|---|---|---|---|
| `g1_direct_ref` | `q1::c1::b1::a1`, null | `p1::b1::a1`, bound | **==GOLDEN** | ==GOLDEN | **CMP_FAIL→PASS_CMP** |
| `g6_class_handle_new` | `q6::c6::dfl6::tbl6`, null | `p6::dfl6::tbl6`, bound | **==GOLDEN** | ==GOLDEN | **CMP_FAIL→PASS_CMP** |
| `g2_nested_in_operation` | `q2::c2::b2::a2`, null | bound | **==GOLDEN** | ==GOLDEN | 36-line head both sides |
| `g5_explicit_import` | `q5::c5::b5::a5`, null | bound | **==GOLDEN** | ==GOLDEN | 65-line head both sides |
| `g3_class_own_var_control` | — | — | unchanged | unchanged | `PASS_CMP`, ours-dump **byte-identical** to pristine |
| `g4_no_import_control` | EMPTY-SCORE both sides | — | unchanged | unchanged | `PASS_CMP`, ours-dump **byte-identical** to pristine |

The `g3`/`g4` byte-identity claim needed one correction of method: the raw
dumps differ because the **workdir path is embedded in the dump**. Normalised
(`sed 's#/tmp/r10sd6_grid_v[a-z]*_##g'`) they are identical, and `g1/g2/g5/g6`
change by exactly **6 sides** each — 2 delivered lines against 4 pristine ones:
the ref's own line and its `vpiFullName` are rewritten, and the pristine
`|vpiActual:` + `\_int_var: (p1::a1)` pair disappears. Nothing else moves.

`g4`'s score is **EMPTY on both sides**, and the implementer's own `ct6grid.sh`
prints `EMPTY-SCORE` rather than letting it read as agreement. That guard is
real and it fires — good hygiene, credited.

Determinism: `g6` × 3 → **1 distinct sha256**, on the shipped **and** re-cut
binaries.

### 2.5 Movers — predicted, observed, per-shape

`ct6pred` on the **pristine artifacts**, calibrated against golden (0/0 on all
three):

```
./default/SeqDriver    rename=25 unbind=5  PREDICT-MOVER
./default/SimpleUVM    rename=10 unbind=2  PREDICT-MOVER
./default/Scoreboard   rename=10 unbind=2  PREDICT-MOVER
./testflags/SeqDriver  rename=25 unbind=5  PREDICT-MOVER
./testflags/SimpleUVM  rename=10 unbind=2  PREDICT-MOVER
-- files=953 restore-fail=0 PREDICTED MOVERS=5
u2r: files=1358 restore-fail=0 PREDICTED MOVERS=0
golden calibration: rename=0 unbind=0 on SeqDriver / SimpleUVM / Scoreboard
```

**Observed == predicted, name for name.** `byteverify.sh`: u2r **0 / 1358**,
surelog **5 / 953**, `PATH_SETS_IDENTICAL` both; `SELFCHECK` **1357/1358** and
**952/953**; `SELFCHECK1` **1** and **6**. All as claimed. (Read F2 before
quoting the Scoreboard hash.)

Per-shape, SeqDriver, `ct6shape.py` — ADDED and REMOVED never summed:

```
ref_obj       ADDED 25   REMOVED 25
vpiFullName   ADDED 25   REMOVED 25
class_var     ADDED 0    REMOVED 5
vpiActual     ADDED 0    REMOVED 5
TOTAL         ADDED 50   REMOVED 60          <- no other shape moves
DISTANCE TO GOLDEN: ref_obj 17777->17727  vpiFullName 22883->22833
                    class_var 4087->4082  vpiActual 5025->5028  (+3)
TOTAL 361257 -> 361155  (-102)
```

**The `vpiActual +3` is exactly what the implementer says it is (R5), and I
verified the mechanism** rather than accepting the label. A `|vpiActual:` line's
multiset key is **indentation only**, so the instrument is position-blind:

| indent | golden | pristine | delivered | \|g−p\| | \|g−d\| |
|---|---|---|---|---|---|
| 12 | 12463 | 12032 | 12030 | 431 | **433** |
| 14 | 12147 | 12210 | 12209 | 63 | **62** |
| 16 | 10048 | 9694 | 9693 | 354 | **355** |
| 18 | 8971 | 8727 | 8726 | 244 | **245** |

At three of the four depths we were **already short** of golden, so removing a
correct binding reads as one worse; at depth 14 we were long, so it reads as one
better. Net +3. The object census (§2.2) is the right instrument and it reads
**0 vs 0**.

Distances, all three rows:

```
SeqDriver  361257 -> 361155      SimpleUVM 141284 -> 141244
Scoreboard 131518 -> 131478
```

`BuildUVMPkg` both modes: **`8b55754ef056`, 11 097 662 bytes, identical on all
three binaries.**

### 2.6 The five gates, run independently

1. **BUILD** — §0. Both md5s bit for bit, 0 errors, link line waited for, BASE
   grep-checked, pristine tree clean.
2. **GOLDENS** — `23 PASS / 0 FAIL`; `SLANG_UHDM=/bin/false` → `0 PASS / 23
   FAIL`. Re-cut also **23/0**.
3. **u2r** — `679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL`, **both modes,
   all three binaries**; dump column testflags `496 match / 183 differ / 52`;
   `ct8rows` vs the committed testflags-only `gate_uhdm2rtlil.csv` = **0 rows**;
   pristine-vs-delivered = **0 rows**.
4. **surelog** — default `469/11/25/5/284`, testflags `465/8/24/5/286`, both
   binaries; **all four dump histograms identical** (default `225 match / 244
   differ / 325`, testflags `165/300/329`). vs the committed
   `golden_surelog.csv`: **1 row**, `Google,testflags` `TIMEOUT` →
   `SURELOG_FAIL` — a **golden-side** outcome of the longer `--timeout 600`,
   **identical on both binaries**. Decisive control: **pristine-vs-delivered =
   0 differing rows on BOTH corpora.**
5. **BYTE VERIFIER** — §2.5, both corpora, both modes, `SELFCHECK=1
   SELFCHECK1=1`, per-shape by multiset, ADDED/REMOVED separate,
   census-predict **first** and artifact-based.

### 2.7 Canaries

```
canaries.sh  surelog: ok=52 changed=0 absent=0 unknown-names=7   (expected 7)
canaries.sh  u2r    : ok=8  changed=0 absent=0 unknown-names=25  (expected 25)
ctcan2.sh    EXPECT_UNKNOWN=1 surelog: ok=58 changed=0 unknown=1  PASS rc=0
ctcan2.sh    EXPECT_UNKNOWN=6 u2r    : ok=1  changed=0 unknown=6  PASS rc=0
canaudit.sh  audited=29  UNCOVERED=0  FENCE-BREACH=0
             UnsignedParam / HierPathEval / FileLocalParam / TopParam: not dispatched (OK)
```

`InterfaceModPort` and `BlackParrotComplex` **by name**, both modes, all three
CSVs (`golden_surelog.csv`, pristine, delivered): `CMP_EQUAL,,,differ` — four
rows, identical text everywhere.

### 2.8 Boundaries

* **§ importedClassVarIsOwnCopyNoInstance5** (pass 5, same function). `ct5cls`
  on SeqDriver, pristine vs delivered: **`diff` = 0 sides**. `V=own 1206`,
  `X own named INST 63`, `span=NAME 1206`, `inst=<null> 1143 / adpcm_pkg 49 /
  uvm_pkg 14` — cell for cell unchanged. `grid5` **v1–v6**: every cell's
  ours-dump **byte-identical** pristine ↔ shipped ↔ re-cut, same `PASS_CMP` /
  `CMP_FAIL` verdicts and the same `content=` counts.
* **sd4's q-grid** — all **13** cells (`q1…q11`, `qv12`, `qv13`): ours-dump
  **0 differing sides** pristine ↔ shipped ↔ re-cut.
* **`bindListingInitRefs47`** — the package's own listing is untouched
  (`ct6pkgv` §2.1, `diff` golden-vs-delivered 0 sides; §2.4 `g4` byte-identical).
* **StmtEmit / TaskFuncEmit** (uvm55 / 66 / 71) — not in the file set.
* **uvm73 R1** — measured, not assumed: the target's type `uvm_table_printer`
  is a plain class name and the package listing matches golden **33/33**.
* **Live passes** — `r10uvm74` landed at `bd4b122` (`src/ExprEmit.cpp` only, no
  overlap); both patches apply clean there. `r10earl46` is
  `ParamEmit`/`ExprEmit` — no overlap with `src/ModuleEmit.cpp`.

---

## 3. THE RE-CUT

`/tmp/r10sd6.verified.patch` — shipped patch **+ F1 fix + F3 removal +
this file + 8 `gridv/` cells + 4 verifier drivers**. `src/ModuleEmit.cpp`
**+131 −0** (was +77); still one production file.

The fix moves the select dispatch **inside** the `ref_obj` arm, where the is-a
cast has already claimed those nodes, and records at the call site *why* it
cannot live beside it:

```cpp
if (auto* ro6 = any_cast<UHDM::ref_obj*>(e)) {
    if (!ro6->VpiName().empty())
        ro6->VpiFullName(owner + "::" + std::string(ro6->VpiName()));
    ro6->Actual_group(nullptr);
    switch (e->UhdmType()) {            // INSIDE the arm, not beside it
        case UHDM::uhdmbit_select:          …VpiIndex…                break;
        case UHDM::uhdmpart_select:         …Left_range/Right_range…  break;
        case UHDM::uhdmindexed_part_select: …Base_expr/Width_expr…    break;
        case UHDM::uhdmvar_select:          …Exprs()…                 break;
        default: break;
    }
    return;
}
…
if (e->UhdmType() == UHDM::uhdmoperation) { …operands…; return; }   // no derived kinds
```

**The re-cut's own gates**

| gate | result |
|---|---|
| build | 0 errors, link line waited for, md5 `d3ba485bea4629971cf4e84de193c233`, BASE grep-checked |
| goldens | **23 / 0** |
| u2r | 679/50/2 both modes; `ct8rows` vs shipped = **0 rows**; byteverify vs shipped **0 / 1358** |
| surelog | 469/11/25/5/284 and 465/8/24/5/286; `ct8rows` vs shipped = **0 rows**; **size-compare vs shipped 0 / 953** |
| `gridv` | `v1` **CMP_FAIL→PASS_CMP**; `v1`/`v5`/`v8` **==GOLDEN**; `v2`/`v6` unchanged and ==GOLDEN; `v3`/`v4`/`v7` unchanged |
| `grid6` | identical to the shipped patch, cell for cell |
| `grid5` + q-grid | **0 differing sides** on all 19 cells |
| SeqDriver / SimpleUVM | **bit-identical to the shipped patch** (`618440bf`, `201de013`), 3 runs each |
| determinism | `g6` × 3 → 1 hash |

`Scoreboard` is the only row whose md5 differs, and F2 shows that row does not
reproduce its own md5 on **any** binary including pristine; its **size** is
identical to the shipped patch's (11 138 552), and the whole-corpus **size**
comparison is **0 / 953** and **0 / 1358**. The fix therefore changes **no
corpus artifact** — it closes a latent hole and un-documents a false claim.

---

## 4. RESIDUES, RANKED

1. **R1 — `Scoreboard`/`default` is nondeterministic at BASE** (3 md5s in 5
   pristine runs, 1 size). Every md5-based mover reading on that row is noise.
   `vsd6det.sh` is the driver; the campaign's standing note on
   `SourceLocation` comparisons across macro buffers is the likely mechanism.
   **This is the highest-value residue in this report**: it silently degrades
   the campaign's primary mover instrument on a canary row.
2. **R2 — the law over-quantifies.** `hier_path` element 0 is a measured
   counterexample (`v3`). Fix the statement before the next pass builds on it.
3. **R3 — SeqDriver's next head**, `LHS <null>` / `RHS package(uvm_pkg)
   @28:1-39:11`, reproduced and proven pre-existing. The implementer's
   `ct4scan` neighbourhood claim (`class_typespec@199:3-199:20` in
   `function(uvm_report_warning)`'s `begin`, the sd3/sd4 statement-local
   `vpiInstance` family) I did **not** independently re-derive — flagged as
   unverified, not disputed.
4. **R4 — `ct6clsref.cpp` shares the is-a blindness of the code it scores.** Its
   `walkExpr` stops at any select and never walks a `hier_path` or a call
   prefix, so the census that certifies this law **cannot see the cells F1 is
   about**. It scored 52/52 and was right — for shapes it can see.
   `vsd6ref.cpp` is the instrument that can see the rest.
5. **R5 — the multiset shape instrument is position-blind** (§2.5). Pair every
   small per-shape delta with an object census; the implementer already says
   this and the mechanism is now measured rather than asserted.
6. **R6 — `g2`'s residual head** (`constant` / `vpiDecompile`, 36 lines) and
   **`g5`'s** (`package q5`, 65 lines) are unchanged by this pass and unrelated
   to it; both have small reproducers.
7. **R7 — `ct6clsref` does not cover the MODULE-container arm** (implementer's
   own R6): a class declared in a module, not a package. An empty score there
   would read as agreement. `vsd6ref.cpp` inherits the same gap.
8. **R8 — pass-5's instance split 42/21 vs 49/14** (7 objects) and **the TOP-view
   instance deficit** (golden 16 759 vs ours 13 024): pre-existing, untouched,
   carried forward verbatim from the implementer's R2/R7.

---

## 5. WHAT I DID NOT VERIFY

* `ct4scan`'s neighbourhood naming for the next head (R3) — the head itself I
  reproduced bit for bit; its *neighbourhood* I took on trust.
* `ct6path.py` / `ct6ref.cpp` / `cells.py` / `slots.py` / `rowheads.sh` /
  `manifest.sh` — read for hygiene (no `results/` writes, no `GOLDEN_DEFER`, no
  `SLANG_UHDM` default), not re-run. The claims that rest on them
  (§2.1 refutation, the package listing's 10 refs) I re-derived with `ct6pkgv`
  and `ct6clsref` instead.
* The `folded` mode — no `folded` rows exist in either committed baseline and
  the brief's gates do not name it.

Sweep workdirs `/tmp/sd6vs/wd_*` deleted after measurement; the CSVs and the
three worktrees are kept.
