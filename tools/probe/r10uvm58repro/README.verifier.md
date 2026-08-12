# r10uvm58 — ADVERSARIAL VERIFIER: **VERDICT PASS**

**FIRST LINE:** every gate number, every head number, every mover number and
every target per-shape count in the implementer's report **REPRODUCED EXACTLY
on binaries I built myself**, including the two build md5s. **0 OVER-FIRES**
survive my own per-shape attribution, and the r10svs3 `function`-span boundary
was **not crossed**. Six findings follow, all residue-level or
documentation-level; **none blocks the landing**.

I independently rebuilt the control (`663899bcad3b7696f1d3f9fa972ec085`) and the
patched binary (`62bac79f9274890d566178600ddbf3b9`) from a **fresh** 266d3a6
worktree and got the implementer's md5s **bit for bit**, which is the strongest
form of the base-commit check this campaign has: two independently configured
trees at the same revision produce the same two binaries.

```
git -C .claude/worktrees/r10uvm58v      rev-parse HEAD -> 266d3a6649663dc151188b0623e88d9336b7c745
git -C .claude/worktrees/r10uvm58vpris  rev-parse HEAD -> 266d3a6649663dc151188b0623e88d9336b7c745
CONTROL (pristine 266d3a6) md5 663899bcad3b7696f1d3f9fa972ec085   <- theirs, to the digit
PATCHED (266d3a6 + patch)  md5 62bac79f9274890d566178600ddbf3b9   <- theirs, to the digit
patch /tmp/r10uvm58.patch  md5 3ba6cf5dadf0116f9c603451a4330e24  (84618 bytes)
```

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours. Every `uhdm-cmp` below ran
as `uhdm-cmp <golden.uhdm> <ours.uhdm>`.

---

## 1. PATCH HYGIENE — no `results/`, no harness, no slang header

`git apply --stat /tmp/r10uvm58.patch` (full output, 23 files):

```
 include/UhdmExporter.h  | 76 ++  src/EmitHelpers.h | 36 ++  src/StmtEmit.cpp | 6
 src/TaskFuncEmit.cpp    | 16 +   src/UhdmExporter.cpp | 14 +
 tools/probe/r10uvm58repro/{README.md, a1_witness.sv, a2_pureconc.sv,
   a3_nonvirt.sv, a4_types.sv, a5_spec.sv, a6_extern.sv, a7_formal.sv,
   a8_locals.sv, arm58.sh, kindcen58.py, mv58.sh, refvar58.py, v1_bound.sv,
   v2_elabmod.sv, v3_specelab.sv, v4_contprop.sv, vcells.py}
 23 files changed, 1451 insertions(+), 5 deletions(-)
```

| check | command | result |
|---|---|---|
| no `results/`, `scripts/`, `tests/` path in the diff | `grep -cE '^(\+\+\+\|---) (a\|b)/(results\|scripts\|tests)/' /tmp/r10uvm58.patch` | **0** |
| the four `results/` mentions are README prose, not file changes | `grep -n 'results/' /tmp/r10uvm58.patch` | all four are `+` lines **inside** `tools/probe/r10uvm58repro/README.md` |
| harness/baselines untouched BEFORE apply | `git status --short results/ scripts/ tests/` | empty |
| harness/baselines untouched AFTER apply **and after all five gates ran** | same command | **empty** |
| clean apply to a pristine 266d3a6 | `git apply --check /tmp/r10uvm58.patch` | rc=0 |
| the delivered patch == the diff I gated | `git diff -- include/ src/ \| md5sum` vs `git diff 266d3a6 -- include/ src/ \| md5sum` | both `e0450790d047fccfa59387d8e3d60dd0` |
| no slang header, no `scripts/verify_golden.py`, no `tests/check_goldens.sh` | the file list above | confirmed |

Final `git status --short` in my worktree: the five production files modified,
`tools/probe/r10uvm58repro/` untracked. Nothing else. `git stash` never used.

## 2. THE r10svs3 BOUNDARY — NOT CROSSED

```
git diff -- src/ include/ | grep -nE '^[+-].*setLoc'          -> NOTHING
git diff -- src/ include/ | grep -cE 'MakeFunction|VpiEndLineNo|VpiEndColumnNo|VpiLineNo|VpiColumnNo'  -> 0
```

And measured, per shape, indentation stripped, on my own SimpleUVM dumps
(`grep -Fxc`) — **identical before and after**, so the concurrent pass's subject
is untouched and its law is confirmed:

| shape | golden | before | after |
|---|---|---|---|
| `function: (…uvm_set_get_dap_base::get), line:71:4, endln:71:16` | **2** | 0 | **0** |
| `function: (…uvm_set_get_dap_base::get), line:71:4, endln:71:34` | 0 | 2 | **2** |
| `function: (…uvm_set_get_dap_base::set), line:55:4, endln:55:16` | **2** | 0 | **0** |
| `function: (…uvm_set_get_dap_base::set), line:55:4, endln:55:44` | 0 | 2 | **2** |
| `function: (…uvm_set_before_get_dap::get), line:113:4, endln:113:11` | **3** | 0 | **0** |
| `function: (…uvm_set_before_get_dap::get), line:113:4, endln:120:21` | 0 | 3 | **3** |

## 3. THE FIVE GATES, mine beside theirs

| gate | theirs | **mine** | verdict |
|---|---|---|---|
| **1** BUILD, absolute path, link line counted | `Linking CXX executable slang-uhdm` = 1, `error:` = 0, md5 CHANGED asserted separately with a 32-hex baseline validation | **1 / 0 / `MD5 CHANGED: PASS`** (baseline `663899bc…`, new `62bac79f…`) | **MATCH** |
| **2** GOLDENS | 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL | **rc=0, 23 PASS / 0 FAIL**; `/bin/false` → **rc=1, 0 PASS / 23 FAIL** | **MATCH** |
| **3** u2r testflags j2 | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL; dump 496/183/52; ct8rows 0 rows | **679 / 50 / 2; dump 496 match / 183 differ / 52 blank; ct8rows `0 differing ROWS (0 diff row-sides)`** — and my **pristine** sweep is also 0 differing rows | **MATCH** |
| **4** surelog both j2 | default 467/13, testflags 463/10, DEFERRED 5 both; dump 225 & 165; ct8rows 0 rows | **default 467 CMP_EQUAL / 13 CMP_NOTEQUAL / 5 DEFERRED; testflags 463 / 10 / 5; dump default 225 match, testflags 165 match; ct8rows `0 differing ROWS`** — pristine also 0 | **MATCH** |
| **5** BYTE VERIFIER both corpora | u2r 0/679 (SELFCHECK 678/679, SELFCHECK1=1); surelog 7/953 (SELFCHECK 952/953, SELFCHECK1=8) | **u2r `PATH_SETS_IDENTICAL (679)` MOVERS 0/679, SELFCHECK 678/679, SELFCHECK1 = 1; surelog `PATH_SETS_IDENTICAL (953)` MOVERS 7/953, SELFCHECK 952/953, SELFCHECK1 = 8** | **MATCH** |

The 7 surelog movers are the same 7 rows they name:
`default/{BuildUVMPkg,Scoreboard,SeqDriver,SimpleUVM}` +
`testflags/{BuildUVMPkg,SeqDriver,SimpleUVM}`.

GOLDEN_DEFER left at default (5 DEFERRED both modes). `UnsignedParam`,
`HierPathEval`, `FileLocalParam`, `TopParam` never dispatched — audited below.

### CANARIES

| check | mine |
|---|---|
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=6` on u2r | `ok=1 changed=0 absent=0 unknown-patterns=6` → **PASS** |
| `r10oth7repro/ctcan2.sh` `EXPECT_UNKNOWN=1` on surelog | `ok=58 changed=0 absent=0 unknown-patterns=1` → **PASS** |
| **`tools/probe/r10uvm52repro/canaries.sh`** on u2r | `ok=8 changed=0 absent=0` unknown-names=25 |
| **`tools/probe/r10uvm52repro/canaries.sh`** on surelog | `ok=52 changed=0 absent=0` unknown-names=7 |
| `r10uvm55repro/canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` → **PASS** |
| BY NAME | `InterfaceModPort` default+testflags **IDENTICAL** (`CMP_EQUAL,,,differ`); `BlackParrotComplex` default+testflags **IDENTICAL**; both also identical on u2r |

## 4. THE HEADS — reproduced, including the 266d3a6 head verbatim

The 266d3a6 head on SimpleUVM/default, printed off **my** control binary, is the
brief's head down to the object ids:

```
LHS: ref_var: (uvm_pkg::uvm_set_get_dap_base::get), id:173208, line:71:26, endln:71:27
     |vpiParent: \_function: (…::get), id:173207, line:71:4, endln:71:16
     |vpiTypespec: \_ref_typespec: id:173209 -> |vpiActual: \_int_typespec: id:173185, line:80:45, endln:80:46
```

| test | mode | cmp lines / heads BEFORE | AFTER | new head (mine) |
|---|---|---|---|---|
| SimpleUVM | default | **54 / 1** | **50 / 1** | `constant: , id:132599, line:150:156, endln:150:157` |
| SimpleUVM | testflags | **54 / 1** | **50 / 1** | same constant (`id:132611`) |
| Scoreboard | default | **54 / 1** | **50 / 1** | same constant (`id:132869`) |
| Scoreboard | testflags | — | — | SKIP-NOFILE (`SLANG_REJECT`, no database) |
| SeqDriver | default | **85 / 1** | **85 / 1** | `class_typespec: (adpcm_pkg::type_id), line:440:12, endln:440:31` — **UNCHANGED** |
| SeqDriver | testflags | **85 / 1** | **85 / 1** | same, UNCHANGED |
| BuildUVMPkg | default | **58 / 1** | **15 / 1** | `ref_obj: (uvm_pkg::uvm_registry_common::__deferred_init::Tregistry::get), id:161192, line:14104:24, endln:14104:35` |
| BuildUVMPkg | testflags | **58 / 1** | **15 / 1** | same |

**All three refutations CONFIRMED, one by reading the source they cite:**

1. **SeqDriver never carried this head** — its head is the `class_typespec`
   above, 85 → 85. Worth pinning: SeqDriver **is** a byte mover (2 of the 7), so
   the law fires inside it; it just never fired at its head. The report says
   this correctly.
2. **Only the object CLASS is a compared field.** Read, not taken on trust:
   `~/git-repos/UHDM/scripts/classes.py:473` `vpi_blacklist` contains
   `vpiColumnNo vpiEndColumnNo vpiEndLineNo vpiFile vpiFullName vpiLineNo` (+
   the `vpiRef*` and `vpiDef*` family), and
   `UHDM/build/generated/src/variables.cpp:251` **does** compare `VpiSigned`.
   So typespec *identity* that differs only in location cannot move a head, and
   `vpiSigned` can.
3. **80:45 is the `try_get` formal, not the `type T=int` default.** Read off
   `uvm-1.2/src/dap/uvm_set_get_dap_base.svh` with `awk 'NR==80{print substr($0,40,12)}'`
   → `tput T value`, so 1-based col 45 is the `T` of `output T value` in
   `pure virtual function bit try_get(output T value);`. Line 32
   (`virtual class uvm_set_get_dap_base#(type T=int)`) puts `T` at col 42 and
   `int` at col 44 — which is where we mint ours. **The brief's guess was wrong
   and the implementer's reading is right.**

## 5. THE GATE IS THE GATE — verified in the code, and in slang's header

`typeParamVarIsRefVar58` (`src/EmitHelpers.h`) is
`kind == TypeAlias && getSyntax()->kind == TypeAssignment && getCanonicalType().kind != ClassType`,
and the gate at the top of `makeReturnVar` calls exactly that predicate before
any arm keys on the canonical type. The claim "`TypeAssignment` is the only
syntax kind that spells a type-parameter assignment and never a typedef" is
**true in slang's own header**: `grep -n TypeAssignment
~/.local/include/slang/syntax/AllSyntax.h` shows `TypeAssignmentSyntax` occurring
only as `SeparatedSyntaxList<TypeAssignmentSyntax> declarators` inside
`TypeParameterDeclarationSyntax`. So the stated gate == the semantic gate.

**The ONE EXCLUSION is safe by construction, checked by reading every arm.**
`src/UhdmExporter.cpp:1474` now passes the canonical type `ec` instead of
`elemType`. The only two arms of `makeReturnVar` that read the **declared**
type are (a) the `ct.kind == ClassType` arm — unreachable here, the branch is
guarded by `ec.kind == PredefinedIntegerType` — and (b) the
`signedImplicitRet && PackedArrayType` arm, whose flag defaults to false at this
call site. So the substitution changes **only** whether the gate fires, and
nothing else.

## 6. THE EMPTY PRODUCT CELLS — I BUILT THE FOUR ARMS THEY SKIPPED

Enumerating the axes (pure/non-pure × virtual/non × type-param/concrete return ×
default/explicit specialization × in-body/out-of-body × parameterized/plain
class) against their 12 arms leaves these products **unbuilt**, and three of
them sit on live entries into the gated factory
(`ModuleEmit.cpp:6258 → emitDynArrayVar → makeReturnVar` is module-scope;
`StmtEmit.cpp:2157` is the loop variable; `classElemVar` is reached only from
`classAssocElemVar`, so every *other* property path is ungated by construction).
New arms, all committed here, judged with `w58check.py` (which reuses
`vcells.py`'s own-child-depth parse and reports **two** criteria — FULL and
var-CLASS-only — precisely because the last verifier under-counted a finding by
judging on one target kind):

| arm | product cells it adds | golden | before → after | verdict |
|---|---|---|---|---|
| **w1_modscope** | module-scope `T v / T a[3] / T q[$] / T d[] / T as[string]`, **interface-scope** `T ivar / T iq[$]`, **`T` PORTS**, **`T` struct member**, module-scope `function T mf()` | see below | cells 37/48 → **34/48** | **no over-fire**; 1 sideways (F3) |
| **w2_locals** | **STATIC-lifetime local**, **TASK local**, **the LOOP VARIABLE of type `T`**, **local through a typedef alias to `T`**, `string`-bound foreach local | ref_var for all | cells 26/42 → **18/42** | **no over-fire**; 2 under-fire families (F1, F2) |
| **w3_props** | **STATIC / RAND / DYNAMIC-array / typedef-alias class PROPERTIES** (v4 has only `[$] [3] [string]`) | **int_var for every one** | cells 19/31 → **14/30** | **no over-fire — every property stayed concrete on both sides** |
| **w4_aliasret** | **RETURN through a typedef alias to `T`**, **interface-scope method returning `T`**, class nested in a generic | ref_var | cells 26 lines/1 head, unchanged | **no over-fire**; F1 again, in its return flavour |

**RESHAPE holds on every new arm** (object totals, `grep -c '\_<kind>:'`):

```
w1: array_var 13->13   int_var 36->23   ref_var 0->13   (lines 858->856 = the vpiSigned drops)
w2: array_var  0-> 0   int_var 17-> 8   ref_var 5->17   string_var 6->3
w3: array_var 10->10   int_var 22->17   ref_var 0-> 5
```

and at corpus scale, on SimpleUVM/default, **total variable objects 51850
before and 51850 after** — not one object added or deleted.

The three cells `w58check.py` labels `OVER-FIRE` in w1
(`u_m.{mq,mdyn,mas} vpiParent g=ABSENT b=ABSENT a=array_var`) are an
**instrument artifact of the cell key, and I proved it**: the key carries the
PARENT KIND, so when an element reg turns from `int_var` into `ref_var` the
`array_var`'s own `vpiParent` cell is re-keyed from `(…,vpiParent,int_var)` to
`(…,vpiParent,ref_var)` — the paired `FIX g=ABSENT b=array_var a=ABSENT` row is
the same object leaving the old key. The object census above shows
`array_var 13 → 13`: **no object was created.** Recorded here as a named caveat
of `vcells.py`/`w58check.py`: **a parent-kind-keyed cell table re-keys, it does
not duplicate — read the object census before calling a re-key an over-fire.**

## 7. MOVER ATTRIBUTION — my own run, per shape, ADDED and REMOVED separately

`mv58.sh` uses `grep -Fxc` (whole line, indentation stripped) against **golden**,
which is stronger than the brief's `grep -Fc`. My run:

```
---- movers=7  ADDED instances=426  REMOVED instances=584
---- OVER-FIRE shapes=0  UNDER-FIRE shapes=2
```

* **ADDED: 165 shape rows / 45 distinct shape texts, ALL `\_ref_var:`,
  every one `covered`. 0 OVER-FIRE.** (25 distinct shapes × 5 SimpleUVM-family
  rows + 20 × 2 BuildUVMPkg rows.)
* **REMOVED: 172 shape rows — 158 `\_int_var:`, 7 `\_enum_var:`, 7 bare
  `|vpiSigned:1`.** 170 `correct`, 2 `UNDER-FIRE`, both the bare
  `|vpiSigned:1` aggregate.
* `SELFCHECK=1` (fabricated shape injected per mover) → OVER-FIRE on all 7: the
  attributor can see a bad line.

**The 2 UNDER-FIRE flags are an instrument artifact, and I re-proved it
independently rather than accepting the report's proof.** At OWN CHILD DEPTH on
SimpleUVM/default:

```
GOLDEN       ref_var WITH vpiSigned=0   ref_var WITHOUT=3327   total var objs=52463
OURS-BEFORE  ref_var WITH vpiSigned=0   ref_var WITHOUT=3208   total var objs=51850
OURS-AFTER   ref_var WITH vpiSigned=0   ref_var WITHOUT=3272   total var objs=51850
```

No `ref_var` in golden carries `vpiSigned` at all, and none of ours does after
the patch, so dropping 24 per row is exact. **A bare field line has no owner
once indentation is stripped: never attribute one.**

### The target measures, mine

| shape (`grep -Fxc`, indentation stripped) | golden | before | after |
|---|---|---|---|
| `\_ref_var: (uvm_pkg::uvm_set_get_dap_base::get), line:71:26, endln:71:27` | **2** | 0 | **2** |
| `\_int_var: (…uvm_set_get_dap_base::get), line:71:26, endln:71:27` | **0** | 2 | **0** |
| `\_ref_var: (…uvm_set_before_get_dap::get), line:113:22, endln:113:23` | **2** | 0 | **2** |
| `\_int_var: (…uvm_set_before_get_dap::get), line:113:22, endln:113:23` | **0** | 2 | **0** |
| `\_int_var: (uvm_pkg::uvm_queue::queue), line:43:15, endln:43:20` — **the over-fire they caught and fixed** | **3** | 3 | **3** |
| `\_ref_var: (uvm_pkg::uvm_queue::queue), line:43:15, endln:43:20` | **0** | 0 | **0** |

Reach, mine: `refvar58.py` **73 → 50** keys involving a `ref_var` on either
side; `msdist.sh` (the FIXED, indentation-keeping one) **146203 → 146063**; dump
lines **1100465 → 1100441** against golden's **1140700**. All three exact.

### Their 12 arms, re-run on my binaries

11 of 12 reproduce exactly (`a1` 54/1→0/0 cells 7/21→5/21; **`a2` 0/0→0/0 cells
0/12→0/12 and the arm database BYTE-IDENTICAL across the patch — pure virtual is
NOT the discriminator**; `a3` 58→165; `a4` 2206→2200; `a5` 54→0; `a6` 58→24 cells
12/16→10/16; `a7` 54→0; `a8` 58→0; `v2` 169→165; `v3` 58→0). Two before-column
figures drift — see F4.

**a6, the negative control, is byte-identical where it must be:**
`int_var: (p58a6::c_negctl::get), line:20:29, endln:20:32` golden **2** /
pristine **2** / final **2**, the same for `ok`, and the `c_negctl` dump region
has the same md5 (`6bd27828d36c1b21db2e86d854a2868d`) before and after.

---

## 8. FINDINGS, most severe first

### F1 — MEDIUM (unranked residue). A typedef alias to a TYPE PARAMETER is golden `ref_var` too, and the landed gate cannot see it.
The gate keys on syntax kind `TypeAssignment`, so `typedef T my_t;` (kind
`TypedefDeclaration`) is invisible to it — but golden treats an alias-to-`T`
**exactly like `T`**. Three of my arms agree, 13 under-fire cells:

* `w2` `f_alias::av` (local, `typedef T alias_w2_t`): golden `ref_var` /
  ours `int_var,S` **before and after** — 3 cells.
* `w3` `m::aloc`: golden `ref_var` / ours `int_var,S` unchanged — 3 cells.
* `w4` `function alias_w4_t aget()`: golden `ref_var`, **ours emits no return
  variable at all** (`b=ABSENT a=ABSENT`) — 2 cells — plus its local `r`,
  3 cells.

The report's R8 covers "typedef alias to a **class or struct**"; the
type-parameter flavour is a different shape and is unranked. This is an
UNDER-fire, so it costs nothing that landed. Command:
`python3 tools/probe/r10uvm58repro/w58check.py /tmp/v58arm/w4.final/g.dump /tmp/v58arm/w4.pris/o.dump /tmp/v58arm/w4.final/o.dump`

### F2 — MEDIUM (unranked residue). A `for` LOOP VARIABLE of type `T` keeps `int_var`.
`for (T i = 0; i < 2; i++)` in `class c #(type T=int)`: golden `ref_var`, ours
`int_var,S` **before and after**. `StmtEmit.cpp:2157` only enters
`makeReturnVar` when the loop variable is neither integral nor logic, so an
`int`-bound type parameter never reaches the gate — while the loop-**body**
local right beside it (a8's cell) does. 2 cells, `w2_locals.sv:20`. The law's
own SITE list in `include/UhdmExporter.h` names "non-integral for-loop
variables", so the code and the law agree; it is the *coverage* that is partial.
Command: as F1 on `/tmp/v58arm/w2_locals.*`.

### F3 — LOW (sideways byte move, zero corpus reach). At MODULE scope, an associative array of `T` moves its element reg from `int_var` to `ref_var` while golden has `logic_var`.
`work@w1_top58.u_m.mas vpiReg`: golden `logic_var`, before `int_var`, after
`ref_var`. Golden disagrees with **both**, so no head can move either way; and
the module-scope shape occurs nowhere in the corpus (u2r byte movers 0/679, and
all 7 surelog movers attribute per-shape with 0 over-fire). Reported because the
module-scope entry into the gated factory
(`ModuleEmit.cpp:6258 → emitDynArrayVar → makeReturnVar`) was **never priced by
the implementer's grid**, and priced here **empirically from the mover list
first**: it costs 0 movers. Command:
`python3 tools/probe/r10uvm58repro/w58check.py /tmp/v58arm/w1_modscope.final/g.dump /tmp/v58arm/w1_modscope.pris/o.dump /tmp/v58arm/w1_modscope.final/o.dump`

### F4 — LOW (documentation). Three secondary "reach" statistics do not reproduce; every gate and head number does.
* "cells whose **var class** differs: **172 → 114**". I measure, with
  `vcells.py`'s own keying on SimpleUVM/default: **7410 → 7361** (whole DB),
  **3780 → 3731** (both sides present), **117 → 68** (both present and
  `ref_var`-involving), **1819 → 1796** (`kindcen58.py`). None is 172/114; the
  delta is the same order (−49 vs −58) so the direction is right and the
  criterion is unstated.
* "**3971** of SimpleUVM's **8497** differing variable cells are ts-location
  only" — my run has 27119 keys and 7410 differing, and the FULL and CLASS
  criteria give the **same** 7410, so neither denominator is reconstructible.
* Two arm BEFORE columns: `v1_bound` is reported `10/15` and measures **12/15**
  — **deterministically**, 3 consecutive pristine runs, identical `ours.uhdm`
  md5 `d111225c1d37` each time; `v4_contprop`'s denominator is reported `31` and
  measures **36**. Both arms' AFTER columns (7/15 and 13/35) are exact.

None of these figures gates anything. Command:
`python3 tools/probe/r10uvm58repro/refvar58.py /tmp/v58mv/._default_SimpleUVM-1dc93a62.gold /tmp/v58mv/._default_SimpleUVM-1dc93a62.{old,new}`

### F5 — INFO, and it is a MEASUREMENT LAW worth keeping. The aggregate `int_var` count moved AWAY from golden while every per-shape delta was correct.
SimpleUVM/default `\_int_var:` occurrences: **golden 5679, before 5679, after
5619.** Before the patch our total was *exactly* golden's — pure coincidence:
the 60 we removed sit at spans golden has none of, and golden's 60 sit at spans
we lack (all 158 removed `int_var` shapes came back `golden=0 … correct`). **An
aggregate-count guard would have read this correct landing as a 60-object
regression.** Fresh evidence for the standing "per-shape or nothing, at own
child depth" law. Command:
`for k in int_var ref_var enum_var; do grep -c "^\\\\_$k:" /tmp/v58mv/._default_SimpleUVM-1dc93a62.{gold,old,new}; done`

### F6 — INFO (cosmetic). The report's §1.4 gives the non-pure sibling's span without a count; the count is golden **3** / ours **3** (not 2) at `113:4-113:11` / `113:4-120:21`. See the table in §2 above.

---

## 9. RANKED RESIDUE (mine — theirs, re-ranked, with my two new entries folded in)

| # | residue | measured reach | note |
|---|---|---|---|
| **R1** | **`SimpleUVM`/`Scoreboard`'s NEW head**: a macro-continuation `constant` in `uvm_report_error` — golden `@150:156 vpiSize:64 vpiConstType:9`, ours `@149:331 vpiSize:1`, no `vpiConstType` | the head on 3 of 7 UVM row-modes | **both fields ARE compared** → highest-value next target. (Their R11; promoted, because it is now a live head.) |
| **R2** | **`BuildUVMPkg`'s NEW head**: golden `ref_obj (…uvm_registry_common::__deferred_init::Tregistry::get) @14104:24`, `RHS: <null>` | the head on 2 of 7 row-modes, at cmp depth **15** (was 58) | their R12 |
| **R3** | enum-/struct-bound type parameter: our typespec is a `bit_typespec` where golden shares the typedef's `enum_typespec`/`struct_typespec` | a4 `d_enum`, `d_struct` | **IS compared** (typespec `VpiType`) → head-making. Their R3 |
| **R4** | array-/queue-/assoc-/vif-bound type parameter: wrong typespec KIND (`int_typespec`/`logic_typespec` vs golden's `array_typespec`/`interface_typespec`) | v1: 5 of 6 cells | compared; their R4 |
| **R5** | **NEW (F1)** typedef alias to a TYPE PARAMETER: golden `ref_var` for locals AND returns; we keep the concrete var, and for an alias RETURN we emit **no return variable at all** | 13 cells across w2/w3/w4; a superset of their R8's shape | the natural extension of the law that just landed — same predicate, one more syntax kind |
| **R6** | `type T` with **NO default**: golden emits a `ref_var` with no typespec; we emit **no return variable** | a4 `d_nodef::get` | their R2; a missing-object law |
| **R7** | `extern`/out-of-body method with a type-parameter return: golden emits **TWO** return vars; we emit one | a6, cmp 58 → 24; new head is golden's `unsupported_typespec (T)` | their R5 |
| **R8** | module-/interface-scope type parameter: golden's return typespec is an `unsupported_typespec`, ours a resolved `int_typespec` | a3, v2, and **w1/w4's interface cells** | their R6, now also confirmed at interface scope |
| **R9** | **NEW (F2)** a `for` loop VARIABLE of type `T` bound to an integral type never reaches the gate | 2 cells (w2) | one-line reach, cheap |
| **R10** | statement-scope typedef-alias-to-class/struct → golden `ref_var` (§ aliasClassRefVar10 not extended) | 14 keys on SimpleUVM | their R8 |
| **R11** | the **per-type-parameter SHARED TYPESPEC** — golden mints ONE per class type parameter, re-stamped to the last `T` formal | `int_typespec@80:45` golden 6 / ours 2 in the dap class alone | **DELIBERATELY not done, and I agree**: location fields are blacklisted from `Compare`, so it cannot move a head. Their R1, demoted on that evidence. Fully decoded in their §2 — implementable without re-measuring |
| **R12** | the reverse over-fire of § aliasClassRefVar10 on `uvm_resource_pool::lookup_*` | 6 keys | pre-existing; their R9 |
| **R13** | `TYPE[$]` typedef local: golden ONE `ref_var`, ours `array_var` + element | `uvm_utils::find::types` golden 4 / ours 3 | their R10 |
| **R14** | **NEW (F3)** module-scope assoc-array-of-`T` element: golden `logic_var`, ours now `ref_var` | 0 corpus movers | cosmetic until a corpus test grows the shape |
| **R15** | r10svs3's `function` object span (qualifier-prefix end) | golden 2/3 vs ours 0 at three spans (§2) | **theirs**; not a compared field |

---

## 10. DISK

**I deleted every sweep workdir and every scratch tree I created** — the four
sweep workdirs (`/tmp/v58wd_{u2r,sl}_{patched,pris}`, 790 MB), the mover
attribution tree (`/tmp/v58mv`, 1.1 GB), the arm trees (`/tmp/v58arm`), the
dump tree (`/tmp/v58dm`, 156 MB) and my logs/CSVs — **≈2.1 GB**, leaving
`/tmp/r10uvm58.patch` in place. **`/tmp/claude-1000` was never touched.** My two
worktrees (`.claude/worktrees/r10uvm58v`, `…/r10uvm58vpris`) are left in place
because they hold this record and the two gated binaries.
