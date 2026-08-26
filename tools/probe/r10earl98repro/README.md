# r10earl98 — § `genCaAncestorNetShadowUnbinds98`

**BASE `3b588b6`, branch `auto5h`.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; everything
in this directory is **measurement only**. **LHS is always golden (Surelog);
RHS is always ours.**

---

## 1. The head, and what the judge actually printed

`Earlgrey_0_1/default` at `3b588b6`, re-measured on this pass's own pristine
build (`rowheads.sh`): **31 cmp lines, 1 head** (testflags: 36 lines, 1 head —
a different object, the queued `tagged_pattern` one, untouched here).

```
LHS: <null>
RHS: logic_var (work@top_earlgrey.u_hmac.u_msg_fifo.gen_normal_fifo.fifo_wptr)
     line:58:27, endln:58:36   vpiParent: gen_scope (…gen_normal_fifo)
```

**HEAD DECODE — the first framing was WRONG and the measurement says so.**
The carried-forward reading (earl96/earl97 R0-default) called this "a SURPLUS
elaborated gen-scope variable". It is not:

* golden lists **14** `logic_var`s in that `gen_scope`'s `Variables()`, we list
  the **same 14**, same names, same order, same spans (`ct98own --scope`);
* comparing the two `fifo_wptr` objects directly with the OFFICIAL
  `logic_var::Compare` in a fresh `CompareContext` returns **0** — they are
  equal field for field (`ct98own --var`, `LOCAL-VAR-COMPARE r=0`).

The `<null>` is a **BINDING**, not a listing. `ref_obj::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp`) ends with

```
if ((r = SafeCompare(lhs->Actual_group(), rhs->Actual_group(), context)) != 0) return r;
```

and the SINGULAR `SafeCompare` (`BaseClass.h:187`) with `lhs == nullptr` sets
**only** `m_failedRhs`, to the VALUE — hence `LHS: <null>` and our `logic_var`
as RHS. The owner is therefore a `ref_obj`, not the `gen_scope`, and
`ct98own --refs` names it exactly:

| | golden | ours |
|---|---|---|
| `ref_obj(fifo_wptr)` `prim_fifo_sync.sv:111:27` | `Actual_group` **&lt;null&gt;** | → `logic_var fifo_wptr` |
| `ref_obj(fifo_rptr)` `prim_fifo_sync.sv:111:41` | `Actual_group` **&lt;null&gt;** | → `logic_var fifo_rptr` |
| `ref_obj(fifo_wptr)` `prim_fifo_sync.sv:110:27` | → `logic_var fifo_wptr` | → same |

Line 110 is `assign full = (fifo_wptr == (fifo_rptr ^ …));`, line 111 is
`assign fifo_empty = (fifo_wptr == fifo_rptr);` — two adjacent assignments in
the same gen scope reading the same two variables, and golden binds one pair
and not the other.

Design-wide (`ct98own --scan=prim_fifo_sync.sv`, 128 elaborated
`gen_normal_fifo` scopes + the DEF listing): every ref position reads
`127 bound + 1 unbound (DEF)` — **except** `111:27` and `111:41`, which read
**123 bound + 5 unbound**. The four elaborated exceptions are
`u_hmac.u_msg_fifo`, `u_hmac.u_tlul_adapter.{u_reqfifo,u_maskfifo,u_rspfifo}`
— *every* `prim_fifo_sync` under `u_hmac` and no other in the design.

---

## 2. The decoded law (Surelog's own code, cited)

`UhdmWriter::writeCont_assign` (`UhdmWriter.cpp:2120`):

```cpp
if (lhs->UhdmType() == uhdmref_obj) {
  UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {
    if (rhs->UhdmType() == uhdmoperation) {
      if (cloned == false) {
        ElaboratorContext elaboratorContext(&s, false, true);
        assign = (cont_assign*)UHDM::clone_tree(assign, &elaboratorContext);  // A CLONE
        ...
      }
      ref_obj* ref = (ref_obj*)lhs;
      ref->Actual_group(var);        // the Lhs — and ONLY the Lhs — is re-bound
      cloned = true;
```

and `CompileHelper::bindVariable(component, const UHDM::any* scope, name, …)`
(`CompileStmt.cpp:3089`) switches on **`uhdmfunction` / `uhdmtask` /
`uhdmbegin` / `uhdmmodule_inst` and nothing else**; every other scope kind
falls to `default:` and the function **recurses on `scope->VpiParent()`**. The
`module_inst` case searches `Variables()` then `Nets()`.

So, starting from the `gen_scope` being written, the walk

* **skips** the `gen_scope` / `gen_scope_array` levels (no case for them),
* **searches** the enclosing `module_inst`'s Variables then Nets,
* **keeps going up the elaborated hierarchy**, module instance after module
  instance, to the design,
* is **recursed past** at an `interface_inst` / `program` level (no case).

`clone_tree` carries no `Actual_group`, so **in the clone every ref except the
re-bound Lhs comes out UNBOUND.**

**§ `genCaAncestorNetShadowUnbinds98`** — *In an elaborated gen scope, a
continuous assignment whose Lhs is a bare gen-local ref and whose Rhs is an
`operation` loses every gen-local binding in its Rhs when the Lhs's NAME is
also a **net or variable of an enclosing MODULE instance** at any depth.*

The head falls straight out: `hmac.sv:51` declares `logic fifo_empty;`, and
`prim_fifo_sync`'s `gen_normal_fifo` declares one too. Under `u_hmac` the walk
finds hmac's, Surelog clones, and `fifo_wptr` / `fifo_rptr` lose their
`vpiActual`. Golden's Lhs at `111:13` proves it: it points at
`work@top_earlgrey.u_hmac.fifo_empty` (`hmac.sv:51:16`), **not** at the gen
scope's own. In the other 124 instances no ancestor declares `fifo_empty`, so
no clone, so the bindings survive. The same walk explains the three other
late-cloned assignments in that scope — `depth` (`:72`), `wready` (`:79`),
`rvalid` (`:80`) are the *instance's own ports*, found at depth 0.

**NOT CLAIMED, AND MEASURED UNREACHABLE — the clone's Lhs re-bind.** Every
generated `Compare` reaches an ancestor `module_inst`'s `Variables()` /
`Nets()` (via `scope::Compare` / `instance::Compare`, both in the basetype
chain) *before* its `Gen_scope_arrays()`, so the golden ancestor object is
already in `m_visited` and `logic_var::Compare` returns 0 on its first line.
The head itself is the proof: it is the **Rhs** ref, and the differently-bound
Lhs pair one field earlier had already passed.

---

## 3. The grid (arms `g0`–`g6`, Surelog golden + both frozen binaries, both views)

Read from the **plain** column, one axis per arm (`arm98.sh`, `ct98cen`,
`score98.py`; golden-vs-golden CALIB reads 0 on every arm and both views).

| arm | axis | golden UNBINDS the Rhs | golden KEEPS the bindings |
|---|---|---|---|
| `g1_depth98` | ancestor DEPTH | d0 (shipped), **d1, d2, d3** | ancestor **gen block**; nowhere |
| `g2_kind98` | ancestor DECL KIND | ancestor `wire`, `logic` var, module **PORT**, unpacked-array var | `localparam`, `function`, child **instance** name |
| `g3_rhs98` | Rhs SHAPE | operation, ternary, concat, unary, replication, size cast | **bare ref**, constant, part select, `$signed()` call |
| `g4_lhs98` | Lhs SHAPE + HOME | bare-ref Lhs in a gen-if, a gen-for body, a nested gen block, and in each of three instances of one definition | **element-select** and **range-select** Lhs (not a `uhdmref_obj` — § `genCaSelLhsDeepBindGenLocal23` untouched) |
| `g6_ifc98` | INTERFACE fence | a MODULE-level name two scopes above the interface | a name declared only in the **enclosing interface** (its wire / localparam / typedef) |
| `g5_neg98` | the REFUTED framing | — | declaration-form × use grid: **MOVED-WRONG 0 before and after** |

`g5_neg98` is the negative control for the framing this pass overturned: a gen
scope holding `logic`, `logic [3:0]`, `logic` with an initializer, `var logic`,
`wire`, `reg [3:0]`, `bit`, `int`, an unpacked array, and cont-assign-only /
`always_ff`-only / `always_comb`-only / read-only / unused signals. Kind and
listing **already agree** with golden, in both views, on both binaries.

**THE Rhs GATE WAS MEASURED AS AN AWAY-GOLDEN FIRST.** The first cut omitted
Surelog's `rhs->UhdmType() == uhdmoperation` test; arm `g3` row `s_fc`
(`assign s_fc = $signed(v1);`, Lhs shadowed one module up, Rhs a
`sys_func_call`) is BOUND in golden and the ungated build UNBOUND it — 1 cell
pristine-right → patched-wrong. With the gate that arm reads MOVED-WRONG 0.

### arm scoreboard (`score98.py`, MOVED-WRONG, pristine → patched)

| arm | plain | elab | uhdm-cmp heads plain | elab |
|---|---|---|---|---|
| `g0_head98` | 2 → **0** | 2 → **0** | 1 → **0** | 0 → 0 |
| `g1_depth98` | 6 → **0** | 56 → 50 † | 1 → **0** | 1 → **0** |
| `g2_kind98` | 13 → **3** ‡ | 13 → **3** ‡ | 1 → **0** | 0 → 0 |
| `g3_rhs98` | 10 → **0** | 10 → **0** | 1 → **0** | 0 → 0 |
| `g4_lhs98` | 18 → **2** § | 16 → **0** | 1 → 1 § | 0 → 0 |
| `g5_neg98` | 0 → 0 | 0 → 0 | 1 → 1 (unrelated) | 1 → 1 |
| `g6_ifc98` | 10 → 10 (R1/fence) | 5 → 5 | 1 → 1 | 1 → 1 |

† `g1`'s elab column carries a pre-existing whole-listing duplication of that
arm's gen scope (ours 4 copies, golden 2) that is identical on both binaries;
the six cells this law owns are the 56 → 50 delta.
‡ the three survivors are the **unclaimed Lhs re-bind** (golden's Lhs points at
the ancestor's `logic_net` / `array_var`, ours at the gen-local of the same
name) — invisible to the judge, see §2.
§ `g4`'s two survivors are an INTERFACE-owned gen scope: interfaces do not
reach this emitter at all (R2).

**No arm, no view, no row moves AWAY from golden.**

---

## 4. Files

| file | what it is |
|---|---|
| `ct98own.cpp` | the OWNER-FINDER: head + parent chains, a scope's whole listing on both sides, a variable's fields on both sides, a LOCAL `Compare` of any pair, a per-file ref BINDING scan, and the per-`cont_assign` ref dump that named this law |
| `ct98cen.cpp` | the CENSUS: every `ref_obj`-derived node inside a gen-scope `cont_assign`, keyed by identity (scope fullname, ca span, kind, name, ref span, slot, depth — **no file, no id**), payload = the COMPARE-VISIBLE `Actual_group` |
| `score98.py` | multiset join golden vs a candidate: BOTH-SAME / MOVED-WRONG / GOLDEN-ONLY / OURS-ONLY |
| `ct98pop.cpp` | the POPULATION counter over a database PAIR (`SHAPE` / `SHAPEREF` / `FIX` / `AWAY`) |
| `pop98.sh` | runs `ct98pop` over a whole verify_golden workdir, golden read from each test's own `cmds.txt` |
| `arm98.sh` | per-arm driver: Surelog golden + both frozen binaries, both views, official `uhdm-cmp` per side, census scored against the SAME golden, every child `</dev/null` with its rc printed |
| `g0…g6_*.sv` | the arms above |
| `vwide98.sh` | the WIDE boundary over every `.sv`/`.v` under a copy of `tools/probe` |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` | the shared gates, copied verbatim |

---

## 5. Corpus population, measured from PRISTINE databases only (`pop98.sh`)

The law's shape counted on the **golden** side of every comparable pair, before
any patched sweep existed:

| corpus | pairs | golden clone-shape `cont_assign`s | refs in them | databases with a cell we get WRONG | databases at risk of AWAY |
|---|---|---|---|---|---|
| `uhdm2rtlil` | 1356 (+2 FENCED) | **566** in 18 tests | 4268 | **0** | **0** |
| `surelog` | 948 (+8 FENCED) | **7081** in 17 tests | 18556 | **2** | **0** |

`pop98.sh` takes the fenced-name alternation in `FENCE_RE` and never spells it:
the four SLANG-FENCED tests (and any test whose directory name merely CONTAINS
one of those spellings) are skipped and reported only as `FENCED=<n>`, so no
artifact in this directory carries the spelling. Only `canaudit.sh` names them,
by design.

The two are `default/Earlgrey_0_1` and `testflags/Earlgrey_0_1`.

**PREDICTION, made before the patched sweep: EXACTLY TWO DATABASES MOVE —
`Earlgrey_0_1` default and testflags; `uhdm2rtlil` zero.** (The per-test `FIX`
column is an UPPER BOUND in the testflags view, where the census key collides
across the DEF and ELAB listings — Surelog gives a gen scope the same
`vpiFullName` in both. The per-key intersection in §6 is the arbiter, and it
reads 8.)

## 6. What actually moved

`byteverify.sh SELFCHECK=1`, patched sweep vs this pass's OWN pristine sweep,
both binaries frozen `chmod 555` at immutable paths of the SAME LENGTH
(`/tmp/…_pris.bin`, `/tmp/…_lawA.bin`); every `cmds.txt` audited BY BINARY
PATH — **0 of 1462 + 1573 name the main-tree binary**:

```
uhdm2rtlil  MOVERS 0 / 1358      <- as predicted   (SELFCHECK 1357/1358 flagged)
surelog     MOVERS 3 /  956                        (SELFCHECK  955/956  flagged)
   ./default/Earlgrey_0_1      <- predicted
   ./testflags/Earlgrey_0_1    <- predicted
   ./default/Scoreboard        <- THE COIN, not this law
```

`Scoreboard/default` is the documented ~50/50 `svunit_pkg` `vpiTaskFunc`
ORDER coin: the path-normalised whole-dump diff is **92 lines raw and 0 lines
ORDER-BLIND** (both dumps sorted) — the law contributes nothing to it.

Each Earlgrey mover's path-normalised whole-dump diff is **16 lines, all of
them REMOVED `|vpiActual:` + its `logic_var` line, and nothing else**
(`MOVER_Earlgrey_*.diff`): eight bindings dropped, in the four predicted gen
scopes, naming exactly `fifo_wptr` and `fifo_rptr` at `58:27` / `58:38`. In the
default dump they sit at ~2.13 M, between `|uhdmtopModules:` (1.20 M) and
`\_weaklyReferenced:` (3.82 M) — inside the **ELAB block the judge reads**, not
the unreachable tail.

**THE CENSUS re-scored over the SAME fixed universe** (`reg98.py`, golden side
asserted byte-unchanged by md5; CALIB golden-vs-golden-vs-golden reads
`BOTH-RIGHT 42073`, everything else 0):

```
Earlgrey default    TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-WRONG 0  ADDED 0  REMOVED 0
                    BOTH-RIGHT 41353   STILL-WRONG 1246
Earlgrey testflags  TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-WRONG 0  ADDED 0  REMOVED 0
                    BOTH-RIGHT 16506   STILL-WRONG 27786 †
```

† the testflags view's `STILL-WRONG` column is a key-collision artifact of the
same DEF/ELAB fullname clash; only the delta columns are meaningful there, and
they read 8 / 0 / 0 / 0 / 0.

All eight cells are the same key shape:
`…gen_normal_fifo | 111:13-111:51 | ref_obj | fifo_{w,r}ptr | 111:{27,41} | deep`,
golden `bound=0`, pristine `bound=1:logic_var:fifo_{w,r}ptr`, patched `bound=0`.

## 7. The head

`rowheads.sh` on the seven named rows, this pass's own pristine sweep → patched
sweep (SKIP-NOFILE on `Scoreboard/testflags` and `Rggen/testflags` is expected;
counts are DEPTH, not distance):

| row | pristine | patched |
|---|---|---|
| **Earlgrey_0_1 default** | **31 lines, 1 head** | **36 lines, 1 head — a NEW OBJECT** |
| Earlgrey_0_1 testflags | 36, 1 | 36, 1 (unchanged) |
| SeqDriver d/tf | 22, 1 / 22, 1 | identical |
| SimpleUVM d/tf | 36, 1 / 36, 1 | identical |
| Scoreboard default | 163, 1 | identical |
| MiniAmiq d/tf | 106, 1 / 106, 1 | identical |
| BuildUVMPkg d/tf | 56, 1 / 56, 1 | identical |
| Rggen default | 0, 0 (EQUAL) | identical |

The head **CLEARED**: the line count rises because the head OBJECT changed
(`HEAD_AFTER_Earlgrey_default.cmp`). Earlgrey/default now stands on
`hmac_core.sv:116:83` — golden `vpiDecompile:15 vpiSize:4 UINT:15
vpiConstType:9`, ours `'1 / -1 / BIN:1 / 3` — **the very same object
Earlgrey/testflags already stood on**. The two modes now share ONE head.

## 8. Gates (all green)

1. build both binaries, md5s recorded, frozen `chmod 555`, same length;
2. `check_goldens` **23 PASS / 0 FAIL** on both binaries; negative control
   `SLANG_UHDM=/bin/false` → **23 FAIL**;
3. `uhdm2rtlil` both modes: status histogram unchanged
   (testflags 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL);
   `ct8rows` = **0 differing rows** against the committed baseline
   `results/gate_uhdm2rtlil.csv` AND against this pass's own pristine sweep,
   in BOTH modes, status AND dump column;
4. `surelog --mode both`: status histograms unchanged;
   `ct8rows` = **0 differing rows over 1588**, against the committed baseline
   `results/golden_surelog.csv` and against the pass's own pristine sweep.
   **NO ROW IS CONVERTED** by this pass — `Earlgrey_0_1` stays `CMP_NOTEQUAL`
   in both modes (its default head moved to the testflags head's object);
   `results/*.csv` untouched;
5. `byteverify SELFCHECK=1`: every mover named and attributed (§6);
6. canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r);
   `ctcan2` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` →
   `audited=29 UNCOVERED=0 FENCE-BREACH=0`, and each of the four SLANG-FENCED
   names is confirmed **not dispatched by any driver here**;
   protected DBs by name — `InterfaceModPort` / `BlackParrotComplex` /
   `YosysOldOr` byte-identical to pristine, `SVSwitch` `4842211c4030`,
   `YosysVerx` `6ccda350c24a`;
7. boundaries — see §9.

## 9. Boundaries

`BOUNDARY_OWN.*` — the POSITIVE CONTROL that the gate can see a moved cell:
**LISTED=7 == PROCESSED=7**, 14 cells, **DIFFERING 10** (`g0`–`g4`, both
views) and exactly **4 identical** — `g5_neg98` and `g6_ifc98` in both views,
the two arms the law is not allowed to touch. rc histogram `rc=0 28`.

`BOUNDARY_WIDE.*` — every `.sv`/`.v` under a COPY of `tools/probe` at ANY
depth (subdirectory arms included), both views, both binaries,
workdir-normalised `uhdm-dump` byte-compare, list on fd 3, children
`</dev/null`, PROCESSED asserted:

```
LISTED=4395 == PROCESSED=4395   identical 8424   DIFFERING 10   no_output 356
rc by side:  0_A 8067 / 0_B 8067   139_A 14 / 139_B 14
             3_A  342 /  3_B  342     4_A 367 /   4_B 367     <- SYMMETRIC
```

**All ten differing cells are this pass's OWN arms** — `g0`–`g4`, both views.
**No earlier-pass arm moves by a single byte**, and the rc histogram is
symmetric side for side (the 14 `rc=139` per side are the pre-existing probe
segfaults, R5).

Named boundaries this pass had to clear, and what it did to them:

* **§ `genCaNestedModuleLhsOpRhsBinds59` (the binder mirror)** — the same
  `bindVariable` decode, the LHS half. Untouched: this pass writes nothing in
  `opRhsModuleLhs59` / `lhsSuppress`, and `g4`'s select-Lhs rows and `g6`'s
  interface rows (earl59's own fence) are byte-identical on both binaries.
* **§ `genCaSelLhsDeepBindGenLocal23`** — a select Lhs is not a
  `uhdmref_obj`, so it never enters the clone; `g4`'s `t_esel` / `t_rsel` rows
  BIND in golden and on both binaries.
* **§ `genCaOpDeepBindGenLocal20`'s d0 shadow clause** — kept **verbatim**
  (its witness is u2r `genvar_loop_decl_3`, which stays byte-identical).
* the port `high_conn` laws, the assignment-pattern / `tagged_pattern` laws and
  the net-vs-variable laws (the § 75 hoist net, the net-decl-assign gate, the
  array-of-struct net law) own the *kind and listing* of a declaration. This
  law changes **no object's kind, no listing, and mints and removes nothing** —
  `ADDED 0 / REMOVED 0` in both modes, and `g5_neg98`, the declaration-form ×
  use grid, is byte-identical on both binaries in both views.

## 10. Residues, and R0

**R0 — Earlgrey_0_1, BOTH MODES, ONE OBJECT: the unbased `'1` pattern member
that golden re-types and we do not.** `hmac_core.sv:116` (and `:117`, the same
shape):

```
assign sha_rdata = … (sel_rdata == SelIPad) ? '{data: i_pad[…-:32], mask: '1} : …
```

The constant at `116:83-116:85`, inside the `tagged_pattern` whose
`vpiTypespec` is the `string_typespec` `mask`: golden
`vpiDecompile:15 vpiSize:4 UINT:15 vpiConstType:9`, ours
`'1 / -1 / BIN:1 / 3`. `constant::Compare` reads VpiSize / VpiConstType /
VpiDecompile / value, so all four report. Golden RE-TYPES the unbased literal
against the STRUCT MEMBER's width (`mask` is 4 bits in `sha_fifo_t`). This
lands in the assignment-pattern / `tagged_pattern` family the standing boundary
already fences — decode WHICH of those laws owns a NAMED member before writing
a new one. **Both modes now stand on it, so one fix clears two heads.**

Ranked residues this pass MEASURED and deliberately did not take:

* **R1 — THE d0 SHADOW CLAUSE IS WIDER THAN THE DECODE.** The shipped clause
  tests EVERY member kind of the enclosing body and has no Rhs gate;
  `bindVariable` reads only `Variables()` and `Nets()`. Arm `g6` rows `w_param`
  (a d0 `localparam`) and `w_func` (a d0 `function`) are BOUND in golden and
  UNBOUND on both binaries — **4 cells, pristine-wrong and still wrong**.
  MEASURED DENOMINATOR: **0 corpus cells** (`AWAY=0` and no `FIX` row outside
  Earlgrey over 956 + 1358 pairs), which is why narrowing a gate-verified law
  with `genvar_loop_decl_3` behind it was not worth the risk. Its own pass.
* **R2 — AN INTERFACE-OWNED GEN SCOPE DOES NOT REACH THIS EMITTER.** Arm `g4`
  row `t_ifgen` (a gen scope inside an interface whose Lhs name is a module
  signal two scopes up): golden UNBINDS, we still bind, both binaries — 2
  cells, unchanged. The interface path emits its gen-scope `cont_assign`s
  elsewhere; finding and sharing that site is its own pass.
* **R3 — THE UNCLAIMED Lhs RE-BIND.** Arm `g2` rows `k_wire` / `k_port` /
  `k_arr`: golden's cloned Lhs points at the ANCESTOR's `logic_net` /
  `array_var`, ours at the gen-local of the same name. **Provably invisible to
  the judge** (§2), 3 arm cells, 0 corpus cells (the Earlgrey Lhs pair has the
  same kind and name on both sides and scores BOTH-SAME).
* **R4 — the 128 pinmux `Lhs` cells** (`pinmux.sv:174/175/176` and `:160`,
  `assign data_mux = $bits(data_mux)'({…})` in `gen_mio_out[k]` /
  `gen_mio_periph_in[k]`): golden leaves the gen-local Lhs UNBOUND, we bind it.
  A DIFFERENT clone trigger — `writeCont_assign`'s trailing
  `DetectUnsizedConstant` clone (`UhdmWriter.cpp:2270`), which clones and binds
  **nothing**, Lhs included. Present identically before and after.
* **R5 — the pre-existing probe/boundary segfaults.** The wide boundary's rc
  histogram is SYMMETRIC side for side; recorded by earl82 R6 / earl83 R6 /
  earl84 R6 / earl85 R5 / earl89 R6 / earl90 R8 / earl91 R5 / earl93 R7 /
  earl94 R6 / earl95 R4 / earl96 R5 / earl97 R5; `byteverify` proves none of
  them is a mover.
