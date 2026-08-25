# r10earl88 — § pkgScopedPaStructStrictNetVar88: packed dimensions on a `pkg::T` port swap the LOOSE struct member scan for the STRICT one

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` remains the sole acceptance judge.
**BASE `d0499f7`.** `results/*.csv` was READ ONLY and is untouched — **no row
was converted**; the master promotes rows, not this pass.

**The Earlgrey_0_1 head r10earl87 named as R0 — a `module_inst` Variables/Nets
vector size mismatch, 21 302 cmp lines in default and 21 926 in testflags, one
head each — is CLEARED in both modes** (17 lines, one head, a different family
in a different object). Every other named row's head is unchanged.

---

## 1. The head, reproduced before any code was written

This pass built its own binary from `d0499f7` (`3f628b1cfc10`) and re-measured
the head on it with `rowheads.sh` rather than trusting earl87's write-up:

```
Earlgrey_0_1   default      21302      1 head
Earlgrey_0_1   testflags    21926      1 head
```

Both sides of the head are the SAME `module_inst`
(`work@top_earlgrey.u_flash_ctrl.u_flash_mp`), which is
`BaseClass::SafeCompare`'s VECTOR overload on a SIZE MISMATCH: it sets both
containers and names the OWNER on both sides, so the cmp log cannot say which
vector (RESUME §9). `module_inst : instance : scope`, and `scope::Compare`
walks `Variables()` while `instance::Compare` walks `Nets()`; the BASE runs
first, so the judge hits `Variables` first. The five-figure line count is the
head's decompile DEPTH, not a distance.

`pafld88` (this pass's direct `.uhdm` field reader — Earlgrey's `uhdm-dump` is
>1 GB, earl61's rule: never a whole-dump diff on Earlgrey) names the one object
that crossed and prints its whole field table on both sides:

```
flash_mp.sv:21
  input flash_ctrl_reg_pkg::flash_ctrl_reg2hw_mp_region_cfg_mreg_t
        [TotalRegions-1:0] region_cfgs_i

  GOLDEN                                    OURS
  [VAR] packed_array_var  visibility=1      [NET] packed_array_net  netType=1
    Typespec: <no ref_typespec>               Typespec: <no ref_typespec>
    Ranges: 1  loc 21:68-21:86                Ranges: 1  loc 21:68-21:86
      Left  constant '8'  size 64 cT 7          Left  constant '8'  size 64 cT 7
      Right constant '0'  size 64 cT 9          Right constant '0'  size 64 cT 9
    Element struct_var                        Element struct_net
      name=''                                   name='region_cfgs_i'
      fullname=…u_flash_mp.region_cfgs_i        fullname=…region_cfgs_i.region_cfgs_i
      ts -> struct_typespec                     ts -> struct_typespec
            flash_ctrl_reg_pkg::…mreg_t               flash_ctrl_reg_pkg::…mreg_t
  PORT dir=1 lowconn ref_obj->packed_array_var   ref_obj->packed_array_net
```

**Everything except the object KIND, its container, the element's empty
`vpiName` and the element's un-DOUBLED `vpiFullName` is already byte-equal** —
the ranges, both folded bound constants, their locations and the element
typespec link all match. The `Low_conn` follows the object automatically
because the same `topNets` entry feeds it.

---

## 2. Question 1 — the DECODE, from Surelog's source

Two member scans decide net-vs-var for a struct, and **they disagree on
exactly one thing: a NESTED STRUCT member.**

**The LOOSE scan** — `NetlistElaboration::elabSignal`, the
`ttmp == uhdmstruct_typespec` arm
(`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:1996`):

```c++
} else if (ttmp == uhdmstruct_typespec) {
  struct_typespec* the_tps = (struct_typespec*)tmp;
  if (the_tps->Members()) {
    isNet = true;
    for (typespec_member* member : *the_tps->Members()) {
      if (const typespec* mtps = member->Typespec()->Actual_typespec()) {
        UHDM_OBJECT_TYPE mtype = mtps->UhdmType();
        if (mtype != uhdmlogic_typespec && mtype != uhdmstruct_typespec) {
          isNet = false; break;                    // logic OR struct is net-like
        } } } }
```

**The STRICT scan** — `SURELOG::Struct::isNet()`
(`src/Design/Struct.cpp:44`), reached from `bindStructInPackage`
(`src/DesignCompile/ElaborationStep.cpp:1233`):

```c++
bool Struct::isNet() const {
  if (!m_typespec) return false;
  if (m_typespec->UhdmType() != UHDM::uhdmstruct_typespec) return false;
  for (typespec_member* member : *tps->Members())
    if (… rt->Actual_typespec()->UhdmType() != uhdmlogic_typespec) return false;
  return true;                                     // logic ONLY
}
```

**WHICH ONE GOVERNS IS DECIDED BY THE WRITTEN PACKED DIMENSIONS.**

1. `compileAnsiPortDeclaration` / `getSignalType`
   (`src/DesignCompile/CompileHelper.cpp:1895`, `:1501`) records a `pkg::T`
   spelling as `paClass_scope`, and `elabSignal`'s opening ladder
   (`NetlistElaboration.cpp:1933`) sets `isNet = false` for it. The direction
   override right below fires only for `paIntVec_TypeLogic`, so **direction
   never enters the rule** (earl77's `§ pkgScopedPortAnyDirVar77`).
2. `ElaborationStep::bindPortType_` then calls `bindStructInPackage`, and THAT
   is the only place a `pkg::T` spelling can get `isNet` back:
   ```c++
   if (actual->getCategory() == DataType::Category::STRUCT) {
     Struct* st = (Struct*)actual;
     if (st->isNet()) signal->setType(VObjectType::paNetType_Wire);   // STRICT
   }
   ```
   `paNetType_Wire` is not in the `isNet = false` list, so the signal is a NET.
3. Back in `elabSignal`, the typespec dispatch runs — and its FIRST arm is
   ```c++
   if (ttmp == uhdmpacked_array_typespec) {
     if (ref_typespec* ert = ((packed_array_typespec*)tmp)->Elem_typespec())
       tmp = ert->Actual_typespec();          // ttmp is NOT recomputed
   } else if (ttmp == uhdmstruct_typespec) {  // <- UNREACHABLE for a packed array
   ```
   **With written packed dimensions the typespec is a
   `packed_array_typespec`, the LOOSE scan is SKIPPED, and the STRICT verdict
   from step 2 is final.** Without them the struct arm runs and the LOOSE scan
   overwrites it.

So: **no dims ⇒ LOOSE, dims ⇒ STRICT.** The head's element struct is
`struct packed { struct packed {logic q;} en; … }` — six NESTED STRUCT
members — which the LOOSE scan calls net-like and the STRICT scan refuses. That
one disagreement is the whole head. Its neighbour `bank_cfgs_i`
(`flash_mp.sv:22`, `struct packed { logic q; }`) passes STRICT and is correctly
a `packed_array_net` on both sides — the second witness, on the same module.

The variable itself is then built by `ElaborationStep::makeVar_`
(`ElaborationStep.cpp:1703`); the `(found == false) && tps` block turns the
`packed_array_typespec` into `s.MakePacked_array_var()` with the element's own
typespec ref — which is exactly the shape our `emitPackedStructArrayVar`
already emits (§4).

---

## 3. Question 2 — the golden GRIDS (`SCORE.g*.txt`)

`arm88.sh` builds each arm with Surelog (golden), with BOTH frozen binaries in
BOTH views, runs the OFFICIAL `uhdm-cmp` on all four ours-databases and
censuses all five with `sig88` (EVERY `Nets`/`Variables`/`Array_nets` entry of
every `module_inst`, `gen_scope` and `interface_inst`) and `pareach88` (the two
member scans). Every cell records its `rc`. `score88.py` keys on the CELL
IDENTITY and carries only judge-visible fields in the payload — **no span**
(earl60/earl77: a span-carrying payload hides a flip, and a payload field left
in the KEY manufactures phantoms); payloads are DEDUPED per key because our
databases list a definition cell and an elaborated cell under one owner name.

### `g1_elemdims88.sv` — 10 element kinds × 3 dimension forms × {input, output}, one leaf instantiated FOUR ways (driven / **UNDRIVEN** / twice inside a generate-for) plus the same 60 types as module-body declarations

**GOLDEN, and the container is the STRICT scan on all 36 packed-array cells,
0 exceptions — in BOTH directions:**

| written element type | LOOSE | STRICT | `pkg::T` (no dims) | `pkg::T [1:0]` and `[1:0][2:0]` |
|---|:--:|:--:|---|---|
| `s_flat_t`  `{logic a; logic[3:0] b;}` | 1 | 1 | **struct_net** | **packed_array_net** / struct_net |
| `s_nest_t`  one nested struct member   | 1 | 0 | **struct_net** | **packed_array_var** / struct_var |
| `s_deep_t`  struct-in-struct-in-struct | 1 | 0 | **struct_net** | **packed_array_var** / struct_var |
| `s_parr_t`  `logic [1:0][2:0]` member  | 1 | 1 | struct_net | packed_array_net / struct_net |
| `s_enum_t`  an enum member             | 0 | 0 | struct_var | packed_array_var / struct_var |
| `s_bit_t`   a `bit` member             | 0 | 0 | struct_var | packed_array_var / struct_var |
| `e88_t`  (enum)                        | 1 | 0 | enum_var  | packed_array_var / enum_var |
| `v8_t`   (`logic [7:0]`)               | 1 | 0 | logic_var | packed_array_var / logic_var |
| `s1_t`   (`logic`)                     | 1 | 0 | logic_var | packed_array_var / logic_var |
| `b8_t`   (`bit [7:0]`)                 | 1 | 0 | bit_var   | **bit_var** (dims ride the typespec) |

A `logic [1:0][2:0]` member is a `logic_typespec` with two ranges in Surelog,
not a `packed_array_typespec` — which is why `s_parr_t` passes STRICT and stays
a net. That row is the reason the scan must read the EMITTED typespec and not
the slang type.

**Score, elaborated view (the definition view scores identically — our two
views list the same signal objects):**

| arm | RIGHT | TO-GOLDEN | AWAY-GOLDEN | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|---:|
| `g1_elemdims88.sv` | 202 | **72** | **0** | **0** | 86 (was 158) |
| `g2_spellkw88.sv`  |  43 | **13** | **0** | **0** | 2 |
| `g3_homes88.sv`    |  29 | **18** | **0** | **0** | 4 |

The 72 are the 16 STRICT-failing struct port cells × the 4 leaf homes, plus the
8 module-body cells (`w_*_s_nest_d1/d2`, `w_*_s_deep_d1/d2`). Driven, undriven
and generate-for instances all move identically — **drivenness is not in this
rule** (unlike earl77's R3 family).

### `g2_spellkw88.sv` — the BOUNDARY: every spelling × every keyword × every direction, ANSI and non-ANSI

| port | golden | pristine | patched |
|---|---|---|---|
| `input/output/**inout** q88::f_t [1:0]` (STRICT 1) | **net** | net | **net** |
| `input/output/**inout** q88::n_t [1:0]` (STRICT 0) | **var** | net | **var** |
| `input wire q88::f_t [1:0]` | net | net | net |
| `input wire / output wire q88::n_t [1:0]` | var | net | **var** |
| `input var / output var q88::n_t [1:0]` | var | net | **var** |
| `input var q88::f_t [1:0]` | var | **net** | **net** (R2) |
| `input q88::fpa_t` / `q88::npa_t` (the TYPEDEF carries the dims) | **bare packed_array_var, ts -> `q88::fpa_t`** | packed_array_net | **exactly golden** |
| `uf_t [1:0]` / `un_t [1:0]` ($unit, bare) | var | var | var |
| NON-ANSI `q88::f_t [1:0]` / `q88::n_t [1:0]` / module-local | unchanged | unchanged | unchanged |
| `q88::n_t [1:0] x_dirless_n` (no direction keyword) | struct_var | struct_net | struct_net (R3) |

The `q88::fpa_t` row is the second conjunct of the law: Surelog reads
`Struct::isNet()` off the TYPEDEF's own typespec, which is a
`packed_array_typespec` there, so the strict test fails at its first line and
the port is a variable **even though the element struct is all-logic**. Our
patched database lands on golden's exact shape, ts name included.

### `g3_homes88.sv` — HOMES: a 3-deep instance chain, two sibling instances, two generate-block instances, an interface, a program

18 TO-GOLDEN spread over `u_d1.u_c.u_a`, `u_d1.u_c.u_b`, `u_d1.u_c`, `u_d1`,
the `u_d1b` twin, `u_gs.gb[0].u_g`, `u_gs.gb[1].u_g`, `u_gs` and `top88`'s own
body declaration — ports and body declarations alike, at every depth.
AWAY-GOLDEN 0, MOVED-WRONG 0. The 4 STILL-WRONG are the gen-scope and
interface homes (R1, R4), unchanged by this pass.

---

## 4. The law

**§ pkgScopedPaStructStrictNetVar88 — a signal whose type is written
`pkg::T`-SCOPED with PACKED DIMENSIONS ON THE DECLARATION backs a `packed_array_NET`
only while the element struct passes the STRICT member scan
(`SURELOG::Struct::isNet()`: EVERY member's typespec is a plain
`logic_typespec`). One nested-struct / enum / `bit` member — or packed
dimensions that come from the TYPEDEF instead of the declaration — and it is a
`packed_array_VAR` of `struct_var`s, in EVERY direction, with or without a
`wire` keyword, driven or not. The LOOSE scan keeps its own job: it still
governs the SAME typedef written with NO packed dimensions.**

Two hunks, both in existing arms.

`src/EmitHelpers.h` — the strict scan next to the loose one it does not
replace:

```c++
inline bool structTsIsNetStrict(const UHDM::typespec* ts) {
    if (!ts || ts->UhdmType() != UHDM::uhdmstruct_typespec) return false;
    auto* sts = (const UHDM::struct_typespec*)ts;
    if (!sts->Members()) return true;
    for (auto* mem : *sts->Members()) {
        auto* mrt = mem->Typespec();          if (!mrt) return false;
        auto* mts = mrt->Actual_typespec();   if (!mts) return false;
        if (mts->UhdmType() != UHDM::uhdmlogic_typespec) return false;
    }
    return true;
}
```

A member with no typespec is a FAILURE here, not a skip — Surelog `return
false`s on both, where the loose scan's `if (const typespec* mtps = …)` skips.

`src/ModuleEmit.cpp` — the PORT arm, which had NO member test at all
(`scopedWrittenType` alone), gains the strict one and hands the refused rows to
the variable arm it already had:

```c++
const bool paScoped88 = scopedWrittenType(*it.sym);
UHDM::typespec* paElemTs88 = paScoped88 ? packedStructArrayElemTs(*it.sym) : nullptr;
const bool paNet88 = paElemTs88 != nullptr &&
                     it.sym->getDeclaredType()->getType().kind != SymbolKind::TypeAlias &&
                     structTsIsNetStrict(paElemTs88);
if (auto* pan = paNet88 ? emitPackedStructArrayNet(…) : nullptr)      { …nets… }
if (auto* pav8 = (!paScoped88 || paElemTs88 != nullptr)
                     ? emitPackedStructArrayVar(…) : nullptr)          { …vars… }
```

and the BODY arm swaps `structTsIsNetLike` for `structTsIsNetStrict` in the
predicate it already ran.

**The fences, all convicted on golden BEFORE the line was written:**

* **the name must still be SPELLED SCOPED.** `scopedWrittenType` is untouched:
  a `$unit` or imported-bare typedef keeps the arm it had (`g2`'s
  `i_un_f`/`i_un_n`/`o_un_n`, `leaf2bare`, `leaf2na`'s non-ANSI rows — not one
  moves).
* **the packed dimensions must be WRITTEN AT THE DECLARATION.** The
  `kind != SymbolKind::TypeAlias` conjunct is Surelog's `m_typespec->UhdmType()
  != uhdmstruct_typespec` first line, and `g2`'s three `q88::fpa_t`/`npa_t`
  rows land byte-exact on golden because of it.
* **NO PACKED DIMENSION MEANS NO CHANGE.** Every `d0` cell in `g1` — six struct
  kinds × two directions × four homes — is byte-identical pristine vs patched;
  the loose scan still owns them.
* **the earlier arms still own their shapes.** `emitArrayVar` (unpacked),
  `childDrivenOut9`, `genReadPort9`, `bareAnsiPort9`, the `wire`-keyword and
  `var`-keyword arms all return before this one; `g1`/`g2`/`g3` exercise each
  and none moves except through this predicate.
* **only the packed-array-of-STRUCT shape is reachable.** `paElemTs88` is
  non-null only when the leaf is a `PackedStructType` with a registered typedef
  typespec, so a scoped enum / vector element still falls through to the path
  it had (R5) — the arm the law does not widen into.

---

## 5. Question 3 — the CORPUS CENSUS (`CENSUS.*.txt`, `REACH.*.txt`)

`cen88.sh` runs `sig88` over EVERY database of a sweep workdir and over its
GOLDEN, read from the cache path named in that test's OWN `cmds.txt`. It READS
DATABASES AND DISPATCHES NOTHING. `cencount88.py` joins them as a MULTISET
(RESUME §9: keys collide, a last-writer dict drops rows) and scores BOTH
one-sided sets explicitly, because both vectors change size: a var ADDED where
golden has none is AWAY, and a net REMOVED where golden keeps one is AWAY.

| bucket | surelog before | surelog after | u2r before | u2r after |
|---|---:|---:|---:|---:|
| BOTH-SAME | 217 700 | **217 702** | 31 788 | 31 788 |
| **FAM-NET2VAR** (golden packed_array_var, ours packed_array_net) | **2** | **0** | 0 | 0 |
| OTHER-CONTAINER | 4 | 4 | 0 | 0 |
| DIFF-KIND | 0 | 0 | 0 | 0 |
| DIFF-PAYLOAD | 22 | 22 | 2 | 2 |
| ONLY-GOLDEN | 400 | 400 | 0 | 0 |
| ONLY-OURS | 4 923 | 4 923 | 0 | 0 |
| GATE-REACHABLE (ours: packed_array_net + struct_net element) | 24 | 22 | 2 | 2 |

The golden side is asserted unchanged — the two golden census files are
byte-identical across the before and after runs. A line diff of the two `ours`
files prints **exactly four lines, the two moved cells**:

```
- …u_flash_mp|region_cfgs_i|NET|packed_array_net|ELEM=struct_net   (default)
+ …u_flash_mp|region_cfgs_i|VAR|packed_array_var|ELEM=struct_var
- …u_flash_mp|region_cfgs_i|NET|packed_array_net|ELEM=struct_net   (testflags)
+ …u_flash_mp|region_cfgs_i|VAR|packed_array_var|ELEM=struct_var
```

**WRONG→RIGHT 2, RIGHT→WRONG 0, AWAY-GOLDEN 0, MOVED-WRONG 0, corpus-wide.**

`pareach88` scores the whole packed-array population against golden by the two
scans, and **the STRICT scan predicts golden's container with 0 exceptions in
both corpora**:

| ours / golden | LOOSE / STRICT | surelog | u2r |
|---|---|---:|---:|
| NET / NET | 1 / 1 | 22 | 2 |
| **NET / VAR** | **1 / 0** | **2** ← the family | 0 |
| VAR / VAR | 0 / 0 | 6 | 2 |
| VAR / VAR | 1 / 0 | 24 | 16 |
| VAR / VAR | 1 / 1 | 41 | 28 |

The last row is the reason the change had to be a TIGHTENING of the net arm
and not a widening of the var arm: 69 cells are already variables under other
arms with a STRICT=1 element, and golden agrees with every one.

---

## 6. Result

| | before | after |
|---|---|---|
| Earlgrey_0_1 / default | 21 302 cmp lines, 1 head | **17 cmp lines, 1 head** |
| Earlgrey_0_1 / testflags | 21 926 cmp lines, 1 head | **17 cmp lines, 1 head** |

The two after-logs are byte-identical, so there is ONE R0, not two
(`PREDICT_R0.txt`).

---

## 7. Gates

All green — `GATES.r10earl88.txt` carries every number. In one line: both
binaries built `-j 2` and frozen `chmod 555` before any sweep, and **every one
of the 1573 + 1462 `cmds.txt` files audited BY BINARY PATH — 0 name the
main-tree binary**; goldens 23/0 on BOTH binaries and 0/23 on `/bin/false`;
uhdm2rtlil **679/50/2 with 0 differing rows in BOTH modes** against the
committed baseline AND against this pass's own pristine sweep; surelog **0
differing rows over 1588** with an identical status histogram — **no row
converted and `results/*.csv` not edited**; byte movers **0/1358** and
**3/956**, two of them the PREDICTED Earlgrey databases and the third the
documented Scoreboard/default coin (92 raw dump lines, **0 order-blind**); the
run-time A/B gate reproduces the pristine Earlgrey databases byte for byte with
`R10E88_OFF=1` in both modes; 52 + 8 canary rows unchanged, both supplementary
canary suites PASS, `canaudit` audited=29 UNCOVERED=0 FENCE-BREACH=0; all five
protected databases byte-identical with `SVSwitch 4842211c4030` and
`YosysVerx 6ccda350c24a` on their pins; and every other named row's head is
unchanged.

Movers were **PREDICTED BY NAME from the PRISTINE databases first**
(`PREDICT_R0.txt` Part 1): 26 GATE-REACHABLE rows corpus-wide, 2 GATE-COLLIDE,
and the 24 non-colliding ones traced back to their source declarations to prove
the second conjunct could not fire on any of them. Exactly those two moved.

---

## 8. Boundary

`vwide88.sh` (earl87's walker, unchanged in mechanism) walks a COPY of
`tools/probe` with **no path filter**, `.sv` and `.v`, at ANY depth, both
views, both frozen binaries, workdir-normalised dump byte-compare; the file
list is read on fd 3 with children `</dev/null`, `PROCESSED` is asserted and
every cell records its `rc`. **The four slang-fenced tests are never
dispatched** — the list is filtered by the names read out of `canaudit.sh` (the
only file here that may spell them) and 0 of 4026 files matched.

```
PROCESSED=4026 (== LISTED)  identical=7696  DIFFERING=6  no_output=350
rc: 0 -> 14746   3 -> 672   4 -> 658   139 -> 28
     the 28 rc=139 are 14 files x 2 sides and the A/B rc=139 sets are IDENTICAL
```

All 6 differing cells are 3 files × 2 views, and every one was re-measured
AGAINST GOLDEN (Surelog built on each file, official `uhdm-cmp` run, `sig88`
scored 3-way): **TO-GOLDEN 25, AWAY-GOLDEN 0, MOVED-WRONG 0, RIGHT→WRONG 0.**
See `BOUNDARY_WIDE.*` and `SCORE.bd_*.txt`.

---

## 9. Residues, ranked

`PREDICT_R0.txt` carries all of them with their evidence. R0 is the new
Earlgrey head: a FOLDED-PARAMETER constant inside an unpacked-dimension bound
that golden links to an `int_typespec` through a `ref_typespec` and we leave
bare (`flash_mp.sv:54 region_end`). Then: R1 the gen-scope home (do NOT widen
blind — the corpus's 5 gen-scope cells agree with golden today), R2 the `var`
keyword on a strict-net packed-array port, R3 the directionless typed ANSI
port, R4 the interface twin (earl77 R1), R5 the non-struct element under packed
dims (earl77 R2, 0 corpus cells), R6 earl77's undriven-struct R3 (the 4
OTHER-CONTAINER corpus cells), R7 the strict-net packed-array OUTPUT we make a
var.

---

## 10. Reproducing

```bash
g++ -O2 -std=c++17 sig88.cpp     -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o sig88        # and pareach88, pafld88
python3 gen88.py                                        # regenerates g1
SIG88=./sig88 PAREACH88=./pareach88 PRIS=<pristine> PATCHED=<patched> \
  bash arm88.sh g1_elemdims88.sv <outdir>
python3 score88.py <outdir>/g.sig <outdir>/oe.sig <outdir>/qe.sig
SIG88=./sig88     bash cen88.sh   <sweep-workdir> <prefix>   # corpus census
PAREACH88=./pareach88 bash reach88.sh <sweep-workdir> <prefix>
python3 cencount88.py <prefix>.golden <prefix>.ours <out.txt>
./pafld88 <db.uhdm> u_flash_mp region_cfgs_i                 # the head's fields
PATCHED_BIN=<q> PRISTINE_BIN=<p> PROBE_ROOT=<copy> bash vwide88.sh <list> <out>
```

`R10E88_OFF=1` disables the law at run time for the A/B gate.
