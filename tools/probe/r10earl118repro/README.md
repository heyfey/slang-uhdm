# r10earl118 — § `genCaCastRhsOwnLocalLhsNoBind118` — **A GENERATE-SCOPE CONTINUOUS ASSIGN WHOSE Rhs IS A CAST LEAVES ITS OWN-SCOPE GENERATE-LOCAL TARGET REFERENCE UNBOUND, BECAUSE THE ONLY THING THAT RE-BINDS A TARGET AFTER `writeCont_assign`'s CLONE IS `bindVariable`, AND `bindVariable` CANNOT SEE INSIDE A `gen_scope`** — the Earlgrey_0_1 **default** head and all 128 cells behind it CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**, **nothing was promoted** and **NO CORPUS ROW
CONVERTED** (in either direction — `Earlgrey_0_1 / testflags` and
`BuildUVMPkg / both` are quoted below still `CMP_EQUAL`).  `GOLDEN_DEFER`
stayed unset.  The four slang-fenced tests were never dispatched and are named
only inside `canaudit.sh`'s own `FENCED=` list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.
(One name collision to keep straight: this pass's subject is an ASSIGNMENT's
left-hand side, `cont_assign::Lhs`.  Where that is meant it is spelled
`cont_assign::Lhs` or "the target".)

| | |
|---|---|
| BASE | `c3e022a3` |
| pristine binary | md5 `4a42bc7a0018bc97d6d57ceebe1a0a9d`, built from this pass's OWN worktree at a clean `c3e022a3` and frozen `chmod 555` before any sweep — **byte-identical to the main tree's own `build/slang-uhdm`** |
| patched binary (SHIPPED) | md5 `726b1d9e36054ae5bd68799d77c6c43b`, frozen `chmod 555`.  **REPRODUCED**: `/tmp/r10earl118.patch` applied to a FRESH `c3e022a3` worktree and rebuilt there gives the SAME md5 — the patch IS the artifact every number below was measured on |
| a THIRD binary, BUILT AND CONVICTED | md5 `1afae577863016698b0e548df314cbba` — the NO-FENCE cut, the `bindVariable` namesake walk removed: **AWAY-GOLDEN 1** on arm `a3_fence118` row `f1`, one pristine-right → cut-wrong cell on legal SV (§3, `NOFENCE.r10earl118.txt`) |
| production surface | `src/ModuleEmit.cpp` ONLY — one new bool beside the two flags that already sit there, read in the two places the pointer is written.  No new function, no new member, no header change |
| probe surface | `tools/probe/r10earl118repro/` only |
| the head | **Earlgrey_0_1/default, 31 cmp lines, ONE head → 56 cmp lines, ONE head, and the head OBJECT IS GONE.**  Before: `LHS: <null>` against our `logic_var (work@top_earlgrey.u_pinmux.gen_mio_periph_in[0].data_mux)` at `pinmux.sv:157:39` — r10earl107's R0, open since pass 104.  After: a DIFFERENT object at `padctrl.sv:39:24`, golden a folded `constant` (`vpiDecompile:63`, `UINT:63`, `vpiSize:8`) against our unfolded cast `operation` (`vpiOpType:67`).  Counts are DEPTH, not distance (RESUME.md §7) |
| Earlgrey_0_1/testflags | **0 cmp lines, 0 heads, `CMP_EQUAL` — before AND after.**  Its database's md5 moves; its uhdm-dump does NOT (§5) |
| goldens | 23 PASS / 0 FAIL on the patched binary (and on the pristine); `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL (the negative control) |
| arm grid | 3 arms × 2 VIEWS × golden + both binaries, 86 scored cells: **TO-GOLDEN 11, AWAY-GOLDEN 0, MOVED-WRONG 0, SAME_AGREE 74, STILL-WRONG 1** (that one is R1, a different leg).  Every ELABORATED-view cell of all three arms is `SAME_AGREE` — the law touches the non-elaborated view only, and it does so without a mode flag (§4) |
| corpus census | 5295 databases read across both corpora × both modes, golden halves of the two sweeps asserted IDENTICAL (surelog 101307 keys / 462550 cells; uhdm2rtlil 3636 / 11360): surelog **FX TO-GOLDEN 4 keys / 128 cells, AWAY-GOLDEN 0, MOVED-WRONG 0, NOGOLD_MOVED 0**; uhdm2rtlil **not one cell of either family moved**.  Movers PREDICTED BY NAME from the pristine databases first (`PREDICT_sl.txt`) |
| corpus rows | **0 differing rows of 1588** on the surelog corpus and **0 of 1358 + 1358** on uhdm2rtlil, in status AND dump column, against the committed baselines, against the `c3e022a3` controls, and pristine-vs-patched.  Status histograms IDENTICAL.  **NO ROW CONVERTED IN EITHER DIRECTION** |
| byte movers | surelog **3 / 956**, all three attributed: `default/Earlgrey_0_1` = the law's 128 cells and nothing else; `testflags/Earlgrey_0_1` = arena order only, its normalised uhdm-dump differs by ZERO content lines; `default/Scoreboard` = the documented COIN, order-blind diff ZERO content lines.  uhdm2rtlil **0 / 1358** |

---

## 1. THE JUDGE, DECODED FIRST — `own118`, the owner finder for a NULL head

RESUME.md §9's head-decode discipline: read `BaseClass.h`'s SafeCompare
overloads and the owning kind's GENERATED `Compare` order BEFORE naming a
field.  For a null head the two overloads say **different** things, and which
one fired is itself the evidence:

```
SINGULAR  SafeCompare(lhs, rhs, ctx)                       (BaseClass.h:187-199)
    lhs == nullptr && rhs != nullptr  ->  m_failedRhs = THE VALUE,     -1
VECTOR    SafeCompare(lhs_obj, lhs_vec, rhs_obj, rhs_vec, ctx)  (BaseClass.h:202-238)
    lhs_vec == nullptr && rhs_vec non-empty -> m_failedRhs = THE CONTAINER, -1
```

`own118.cpp` runs the OFFICIAL `design::Compare` (the same call `uhdm-cmp`
makes), prints the head, then READS — never guesses — the owner chain, BOTH
sides' full `scope`/`gen_scope` listing in the generated `Compare` order, each
container's own `SafeCompare` result with a FRESH `CompareContext`, the failing
container's elements one by one, and finally a WHOLE-DATABASE name search over
`Serializer::AllObjects` on both sides.  Full output in
`OWNER_BEFORE.r10earl118.txt`, measured on THIS pass's own pristine build:

```
== design::Compare -> -1
   HEAD LHS(golden) = <null>
   HEAD RHS(ours)   = logic_var id:499221  157:39-157:47   name='data_mux'
        full   : work@top_earlgrey.u_pinmux.gen_mio_periph_in[0].data_mux
   ONE SIDE NULL.  The printed RHS is a logic_var, NOT a container, so the
   failing field is a SINGULAR relation whose value is this object.
   -- OWNER CHAIN (ours) --
     gen_scope  @156:45-163:6
       gen_scope_array 'gen_mio_periph_in[0]'
         module_inst 'u_pinmux' dn='work@pinmux'
           module_inst 'work@top_earlgrey'
   == OWNER SCOPE fullname: 'work@top_earlgrey.u_pinmux.gen_mio_periph_in[0]'
      golden holds that scope: YES
   -- CONTAINER BISECTION (generated scope::Compare order, fresh context each) --
      scope::Variables           L=1    R=1    -> 0
      scope::Parameters          L=1    R=1    -> 0
      gen_scope::Cont_assigns    L=2    R=2    -> -1   <== FAILS
   -- CONT_ASSIGN DESCENT (fresh context each) --
     [0] pinmux.sv 160:12-160:63  ->  -1
         GOLDEN Lhs: ref_obj 'data_mux'  actual=<null>
         OURS   Lhs: ref_obj 'data_mux'  actual=logic_var
         GOLDEN Rhs: operation optype=67 ts=ref_typespec->integer_typespec
         OURS   Rhs: operation optype=67 ts=ref_typespec->integer_typespec
     [1] pinmux.sv 162:12-162:67  ->  0
```

**Five facts the judge hands over, and the FIRST one overturns the framing the
brief carried in.**

1. **Golden's default database DOES hold the `logic_var`.**  `scope::Variables`
   is `L=1 R=1` and compares **0**; the whole-DB name search finds **64
   `logic_var` under `gen_scope` on each side**.  The head is NOT "we emit a
   variable golden does not".  What golden does not emit is the POINTER TO it.
2. **The failing field is `ref_obj::Actual_group`**, reached as
   `gen_scope::Cont_assigns[0] -> cont_assign::Lhs -> ref_obj::Compare`.
   `ref_obj::Compare` (`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:150`)
   reads `Actual_group` through the SINGULAR `SafeCompare`, and golden's is
   `<null>` while ours is the `logic_var`.  `−1` is that overload's own return.
3. **Both sides' Rhs is the SAME cast** — `operation` `optype=67`
   (`vpiCastOp`), same span, same typespec edge.  The divergence is one
   pointer, on the target, in a cont_assign the two producers otherwise agree
   about.
4. **The sibling cont_assign at `:162` compares 0** — its target is a
   `bit_select`, and `bit_select` is a `ref_obj` subclass whose `Actual_group`
   is `<null>` on BOTH sides.  So the law cannot be about selects.
5. **The name search's asymmetry is arena tail, not model.**  Golden holds 264
   objects named `data_mux` and we hold 200; the 64-object gap is entirely
   `ref_obj under cont_assign` (golden 130, ours 66) — Surelog's per-instance
   `clone_tree` copies, unreachable to the judge (RESUME.md §9's
   weaklyReferenced rule).  `cen118` therefore walks `AllModules` /
   `AllInterfaces` / `TopModules` recursively and NOT `AllObjects`.

### the source

```systemverilog
pinmux.sv 156:  for (genvar k = 0; k < NMioPeriphIn; k++) begin : gen_mio_periph_in
pinmux.sv 157:    logic [2**$clog2(NMioPads+2)-1:0] data_mux;      <- BOTH sides emit this
pinmux.sv 160:    assign data_mux = $bits(data_mux)'({mio_in_i, 1'b1, 1'b0});   <- THE HEAD
pinmux.sv 162:    assign mio_to_periph_o[k] = data_mux[reg2hw.periph_insel[k].q];
pinmux.sv 163:  end
pinmux.sv 169:  for (genvar k = 0; k < NMioPads; k++) begin : gen_mio_out
pinmux.sv 170:    logic sleep_en;
pinmux.sv 171:    logic [2**$clog2(NMioPeriphOut+3)-1:0] data_mux, oe_mux, sleep_mux;
pinmux.sv 174:    assign data_mux  = $bits(data_mux)'({periph_to_mio_i, ...});   <- and here
pinmux.sv 175:    assign oe_mux    = $bits(oe_mux)'({...});                      <- and here
pinmux.sv 176:    assign sleep_mux = $bits(sleep_mux)'({...});                   <- and here
pinmux.sv 179:    assign sleep_en  = sleep_mux[...] & sleep_en_q;   <- golden BINDS this one
pinmux.sv 228:    assign pin_value = (...) ? ... : ...;            <- and this one
```

Four keys, 32 unrollings each, **128 cells** — and two gen-locals in the SAME
generate blocks that golden BINDS.  It is one law, not one cell, and the
counter-examples were on the table before a line was written.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

**There is exactly ONE place in Surelog that binds a continuous assign's target
reference**, and it is inside the writer:

`UhdmWriter::writeCont_assign`, `~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:2121-2172`

```cpp
if (lhs->UhdmType() == uhdmref_obj) {                       // 2121  (a) not a select
  UHDM::any* var = m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
  if (var) {                                                // 2124  (b) FOUND by name
    if (rhs->UhdmType() == uhdmoperation) {                 // 2125  (c) operation Rhs
      if (cloned == false) { ... assign = UHDM::clone_tree(assign, &elaboratorContext); ... }
      ref_obj* ref = (ref_obj*)lhs;
      ref->Actual_group(var);                               // 2165  THE ONLY BINDER
      cloned = true;
```

and `CompileHelper::bindVariable`, `src/DesignCompile/CompileStmt.cpp:3089-3151`,
is the walk r10earl113 already decoded:

```cpp
switch (scope->UhdmType()) {
  case uhdmfunction:    ... case uhdmtask: ... case uhdmbegin: ...
  case uhdmmodule_inst: { for (auto var : *mod->Variables()) ...
                          for (auto var : *mod->Nets())      ... break; }
  default: break;                       // <-- uhdmgen_scope FALLS HERE
}
return bindVariable(component, scope->VpiParent(), name, compileDesign);
```

**It knows `function`, `task`, `begin` and `module_inst` and nothing else.**  A
`gen_scope` falls to the default and recurses to its parent, so a name declared
INSIDE a generate block is never found, `var` comes back null, and line 2165
never runs for it.

**And a CAST is the one operation kind that takes a clone branch of its own.**
Three lines further down, in the `tps == nullptr` arm (which is where a
generate-local target lands, since `tps` is filled from `var`'s typespec and
`var` is null):

```cpp
} else if (rhs->UhdmType() == uhdmoperation) {              // 2218
  operation* op = (operation*)rhs;
  if (const ref_typespec* ro1 = op->Typespec()) {           // 2220  A CAST CARRIES ONE
    if (const typespec* tps = ro1->Actual_typespec()) {
      expr* tmp = eval.flattenPatternAssignments(s, tps, (expr*)rhs);
      if (tmp->UhdmType() == uhdmoperation) {
        if (cloned == false) {
          assign = (cont_assign*)UHDM::clone_tree(assign, &elaboratorContext);  // 2229
```

An `^`, an `&`, a `?:`, a concatenation carries no `Typespec` of its own; a
`'`-cast does, and that is what selects the branch.  Two more clone sites
follow for a Rhs `reduceExpr` folds to a constant (`:2264`) and for a Rhs
holding an unsized constant (`:2287`), and NONE of the three re-binds — line
2165 is the only writer of that pointer and it is gated on a `var` a
generate-local target can never produce.

**What that predicts, and what was MEASURED (§4):** an own-scope generate-local
target keeps its binding under any ordinary operation Rhs and loses it under a
cast; a MODULE-BODY target keeps it even under a cast, because `bindVariable`
finds it and 2165 runs; and a generate-local target whose NAME ALSO exists in
an enclosing module body keeps it too — bound to the NAMESAKE — which is the
fence in §3.

**THE MODE HALF, and why the law needs no mode flag.**  `-elabuhdm` runs UHDM's
own elaboration afterwards, and `ref_obj::DeepCopy`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:108`) fills an empty
`Actual_group` from `m_elaborator.bindAny(VpiName())`.  So golden's
ELABORATED database has every one of these bound again.  Ours does too:
`uhdm_main.cpp` runs the same `ElaboratorContext ... listenDesigns` under
`--elabuhdm`, and the arm grid measures it — golden, pristine and patched are
`logic_var` on every elaborated cell of all three arms (§4).  **Suppressing at
emission time is therefore correct in BOTH modes without a flag**, and the
`Earlgrey_0_1/testflags` row that carries `-elabuhdm` stays `CMP_EQUAL`.

**REFUTED, and recorded as refuted.**  The first model was "the clone loses the
binding".  It is wrong: `ref_obj::DeepClone` does `*clone = *this` and then
only fills an EMPTY `Actual_group`, so the pointer survives a clone — and arm
`a2_bind118` row `s3` (an Rhs of two sized constants, which takes the `:2264`
constant clone) comes back BOUND in golden.  The cast branch is the
distinguisher; the clone alone is not.  Likewise "the RHS mentions the target
through `$bits(self)`" is refuted by rows `r3`, `r6`, `r11` and `s12` — casts
with no self-reference at all, every one unbound.

---

## 3. THE FENCE, AND THE CUT THAT WAS BUILT AND CONVICTED

The gate is **OWN-SCOPE ONLY**, exactly like its sibling
§ `genCaConstRhsLhsNoBind25`, and it is lifted by `bindVariable`'s own namesake
walk.  Two independent reasons, both measured:

* **An ANCESTOR generate scope's local keeps its binding through a cast.**  Arm
  `a2_bind118` row `s6`: `logic [7:0] s6;` declared in `ga`, assigned
  `$bits(s6)'({...})` from inside `ga.anc` — golden BINDS.  That is the half
  `bindGenLocal9`'s `allowAnc9` exists for, and the flag must not reach it.
* **A NAMESAKE in the module body keeps it too** — bound to the namesake,
  because `bindVariable` FINDS that name at the `module_inst` and line 2165
  runs.  Arm `a3_fence118` row `f1`: `logic [7:0] mod_ns;` declared BOTH in the
  module body and generate-locally, `assign mod_ns = $bits(mod_ns)'({...})`.

The second is not a hypothetical.  **A THIRD BINARY WAS BUILT** with the
namesake walk removed (md5 `1afae577863016698b0e548df314cbba`) and scored on
the same arm against the same golden (`NOFENCE.r10earl118.txt`):

```
VIEW   ARM           KEY                                                  GOLDEN     PRISTINE   CUT        VERDICT
plain  a3_fence118   work@a3_fence118|gen_scope|g1|ref_obj|mod_ns|38:...  logic_var  logic_var  <null>     AWAY-GOLDEN
-- ARM TALLY --   AWAY-GOLDEN 1   SAME_AGREE 20   TO-GOLDEN 3
```

The SHIPPED binary scores that same cell `SAME_AGREE`, with `AWAY-GOLDEN 0`.
One pristine-right → cut-wrong cell on legal SystemVerilog is what the fence
costs to remove, and it is why the walk is transcribed rather than
approximated: it climbs PAST an `InstanceBody` through `parentInstance`, so an
ancestor INSTANCE's namesake lifts the suppress too.

> **VERIFIER AMENDMENT (r10earl118 adversarial verifier, ACCEPT WITH FIX).**
> This section's claim that the walk "skips generate scopes exactly as
> `bindVariable` skips them" is **REFUTED BY GOLDEN**.  A namesake in an
> ENCLOSING GENERATE scope keeps the binding too: on arm `v4_ancname`
> (`tools/probe/r10vearl118repro/`) golden BINDS `a_var` (one gen level up),
> `e_late` (ancestor declared textually later), `f_deep` (two gen levels up)
> and `b_net` (the ancestor namesake is a NET), while `d_sib` (a SIBLING
> generate block's namesake) and `a_free` (no namesake) stay UNBOUND.  Against
> the binary this README ships, those four rows scored **AWAY-GOLDEN 3 /
> MOVED-WRONG 1** — pristine-right → patched-wrong on legal SystemVerilog.
> The mechanism is `ref_obj::DeepCopy`'s `bindAny(VpiName())`
> (`UHDM/build/generated/src/ref_obj.cpp:104-110`) on the clone leg, whose name
> walk sees every ENCLOSING scope but not the assigning scope's own local —
> `bindVariable`'s :2165 arm is only one of the two ways a target keeps an
> actual.  The verified patch widens the walk to skip only the assigning scope
> itself; the corpus databases are UNCHANGED by that widening (0 byte movers of
> 956 surelog and 1358 u2r against this README's binary), the Earlgrey/default
> head still clears, and `Earlgrey_0_1/testflags` stays `CMP_EQUAL`.  The NO-
> FENCE cut re-measured on the verifier's arms scores **AWAY-GOLDEN 7 /
> MOVED-WRONG 3**.  See `tools/probe/r10vearl118repro/README.md`.

---

## 4. THE GRID — 3 ARMS × 2 VIEWS, GOLDEN + BOTH BINARIES, EVERY CELL SCORED

`grid118.sh` runs each arm through `surelog -parse` / `surelog -parse
-elabuhdm` and through both frozen binaries with and without `--elabuhdm`,
censuses all six databases with `cen118` and scores every key three ways.  Every
rc is recorded; a database that fails to appear is `NODB`, never agreement.
Full output in `GRID.r10earl118.txt`, rc in `GRID_rc.r10earl118.txt`
(14 × rc 0, 4 × rc 4 = warnings only, no signals).

**The GOLDEN rule, read straight off the arms** (own-scope generate-local
target, whole-name `ref_obj`, non-elaborated view):

| row | the assignment | golden |
|---|---|---|
| `a1 r1` | `assign r1 = din[0] & c;` — scalar target, operation Rhs | **BOUND** |
| `a1 r2` | `assign r2 = din ^ 8'h0f;` — vector target, operation Rhs | **BOUND** |
| `a1 r3` | `assign r3 = 8'({din[3:0], 4'b0});` — CAST, constant width | **`<null>`** |
| `a1 r4` | `assign r4 = $bits(r4)'({...});` — CAST, self-referencing width | **`<null>`** |
| `a1 r5` | `assign r5 = $bits(r5)'(c);` — CAST, SCALAR target | **`<null>`** |
| `a1 r6` | `assign r6 = $bits(r2)'({...});` — CAST, no self-reference | **`<null>`** |
| `a1 r7` | `assign r7 = din;` — whole-ref Rhs, not an operation | **BOUND** |
| `a1 r8` | `assign r8 = 8'hA5;` — bare literal | **`<null>`** (r10earl22/25, already ours) |
| `a1 r11` | `assign r11 = $bits(mod_vec)'({...});` — CAST of a module var | **`<null>`** |
| `a1 r12` | `assign r12 = din ^ 8'h07;` — operation Rhs | **BOUND** |
| `a1 shadow` | module-body NAMESAKE, operation Rhs | **BOUND** |
| `a1 mod_vec/mod_bit` | MODULE-BODY target, operation Rhs | **BOUND** |
| `a2 s1` | `assign s1 = din ^ '1;` — UNSIZED constant in an operation | **`<null>`** ← R1, a different leg |
| `a2 s3` | `assign s3 = 8'h0f ^ 8'h01;` — folds to a constant | **BOUND** |
| `a2 s4` | `assign s4 = {din[3:0], 4'b0};` — concatenation | **BOUND** |
| `a2 s5` | `assign s5 = c ? din : 8'h00;` — ternary | **BOUND** |
| `a2 s6` | ANCESTOR gen scope's local, CAST Rhs | **BOUND** ← the fence |
| `a2 s8` | own-scope local at generate DEPTH 2, CAST Rhs | **`<null>`** |
| `a2 s10/s11` | generate-local NET target, cast and non-cast | **`<null>`** both (pre-existing, ours agrees) |
| `a2 s12` | `assign s12 = byte8_t'({...});` — TYPE-named cast | **`<null>`** |
| `a2 s13` | `assign s13 = 8'(signed'(din));` — nested cast | **`<null>`** |
| `a2 mod_cast` | MODULE-BODY target, CAST Rhs | **BOUND** ← 2165 runs |
| `a3 f1` | module-body NAMESAKE, CAST Rhs | **BOUND** ← the fence |
| `a3 f2` | MODULE-BODY target assigned from a gen scope, CAST Rhs | **BOUND** |
| `a3 f3/f4/f5` | bit-select / part-select / array-element target, CAST Rhs | never a plain `ref_obj`; unchanged |
| `a3 f7` | own-scope local in a NAMED IF-generate, CAST Rhs | **`<null>`** |
| `a3 f8` | own-scope ENUM local, CAST Rhs | **`<null>`** |
| `a3 f9/f10` | an INTERFACE generate scope, cast and non-cast | **`<null>`** / **BOUND** |

So: **the CAST is the discriminator.**  Target width, target kind (`logic_var`
or `enum_var`), generate depth, generate-block flavour (loop / named if),
module or interface home, and whether the cast mentions the target at all are
NONE of them discriminators — every one of those was varied and golden did not
move.

**THE SCORE, patched vs pristine vs golden, both views:**

```
-- ARM TALLY --        TO-GOLDEN 11    AWAY-GOLDEN 0    MOVED-WRONG 0
                       SAME_AGREE 74   STILL-WRONG 1   (= a2 s1, R1)
```

The 11 TO-GOLDEN keys are `a1 r3 r4 r5 r6 r11`, `a2 s12 s13 s8`, `a3 f7 f8`,
`a3_ifc f9`.  **Every cell of the ELABORATED column of all three arms is
`SAME_AGREE`** — 0 keys of the elaborated view appear in the non-agreeing list
at all, which is §2's mode half measured rather than argued.

---

## 5. THE CORPUS — CENSUS, PREDICTION, AND THE THREE BYTE MOVERS

**PREDICTED BY NAME FIRST.**  `cen118` emits an `RCELL` diagnostic carrying the
Rhs shape and the target's declaration home read off the DATABASE, so the set of
rows the law can possibly touch is computable from the PRISTINE sweep alone.
`predict118.py` on the pristine surelog census (`PREDICT_sl.txt`):

```
PREDICT-MOVE default   Earlgrey_0_1   128 cells
PREDICT-MOVE testflags Earlgrey_0_1   128 cells
  rows=2  cells=256
PREDICT-GOLD default   Earlgrey_0_1   {'<null>': 128}
PREDICT-GOLD testflags Earlgrey_0_1   {'logic_var': 128}   <== GOLDEN BINDS SOME: would be AWAY
```

and on uhdm2rtlil: `rows=0 cells=0`.  The predictor's warning on the testflags
row is the honest statement of the risk — if `--elabuhdm` had NOT restored the
binding on our side, those 128 cells would have gone AWAY and the row would have
converted in reverse.  The census below is what retires it: the testflags row
shows **no FX movement at all**.

**THE CENSUS.**  `censweep118.sh` runs `cen118` over a whole `verify_golden.py`
workdir, golden path read from each test's OWN `cmds.txt`, every rc recorded.
5295 databases read (surelog 1523 golden + 956 ours; uhdm2rtlil 1458 + 1358),
`CENRC 0` on every one.  `score118.py` joins them as a MULTISET on
`(mode, test, key)` and asserts the two sweeps' golden halves identical FIRST.

```
surelog     CALIBRATION: golden halves IDENTICAL (101307 keys, 462550 cells)
            FX TO-GOLDEN     4 keys      128 cells
            FX AWAY-GOLDEN   0           MOVED-WRONG 0     NOGOLD_MOVED 0
            FX SAME_AGREE  662 keys    11550 cells
            FX STILL-WRONG 2561 keys   44343 cells
            REST  AWAY-GOLDEN 0   MOVED-WRONG 0   NOGOLD_MOVED 0
uhdm2rtlil  CALIBRATION: golden halves IDENTICAL (3636 keys, 11360 cells)
            NOT ONE CELL of either family moved (DETAIL_TOTAL 0)
```

The four TO-GOLDEN keys are named in `CENSUS_sl.txt`, each 32 cells:
`work@pinmux|gen_scope|g1|ref_obj|data_mux|160:12-160:20`,
`…|data_mux|174:12-174:20`, `…|oe_mux|175:12-175:18`,
`…|sleep_mux|176:12-176:21`, golden `<null>` / pristine `logic_var` / patched
`<null>`.  **One mover row, `default / Earlgrey_0_1`.**

**THE BYTE MOVERS, all three attributed** (`byteverify.sh SELFCHECK=1`; surelog
3 / 956, uhdm2rtlil 0 / 1358; SELFCHECK flags 955/956 and 1357/1358, so the
comparator can see):

| database | order-blind whole-dump attribution |
|---|---|
| `default/Earlgrey_0_1` | **exactly the law**: 128 removed `\|vpiActual:` lines and the 128 `logic_var` lines under them — 32 × `gen_mio_periph_in[N].data_mux`, 32 × `gen_mio_out[N].data_mux`, 32 × `…oe_mux`, 32 × `…sleep_mux` — and NOTHING else.  Sectioned: 256 lines in ELAB section 10, 0 in DEF, 0 in the weaklyReferenced tail (`ATTRIB_Earlgrey_default.diff`) |
| `testflags/Earlgrey_0_1` | **0 content lines.**  Raw diff 4 lines, order-blind diff 4 lines, and all four are the dump's own header path (`pris_sl` vs `pat_sl`).  The md5 moves because the suppressed-then-re-elaborated binding shifts arena ids; the model does not move at all (`ATTRIB_Earlgrey_testflags.diff`) |
| `default/Scoreboard` | **the documented COIN.**  Raw diff 85 lines, ORDER-BLIND diff 4 — again only the header path.  RESUME.md §9's `svunit_pkg` ordering flip, not this law (`ATTRIB_Scoreboard_coin.diff`) |

---

## 6. THE GATES — ALL GREEN, AND NO ROW CONVERTED

* build both, `-j 2`, md5 separately: pristine `4a42bc7a0018bc97d6d57ceebe1a0a9d`
  (byte-identical to the main tree's `build/slang-uhdm` at `c3e022a3`), patched
  `726b1d9e36054ae5bd68799d77c6c43b`, both frozen `chmod 555` BEFORE any sweep.
* goldens **23 PASS / 0 FAIL** on the patched binary and on the pristine, with
  `SLANG_UHDM` exported explicitly to EACH; `SLANG_UHDM=/bin/false` →
  **0 PASS / 23 FAIL**.
* every `cmds.txt` audited BY BINARY PATH: 1523 surelog + 1458 uhdm2rtlil name
  the frozen pristine binary on the pristine side and the frozen patched binary
  on the patched side; **0 name the main-tree binary** anywhere.
* `ct8rows.sh` (status AND dump column), **PASS on every one**:
  uhdm2rtlil testflags and default vs the committed baselines, vs the
  `c3e022a3` controls, and pristine vs patched; surelog vs
  `results/golden_surelog.csv`, vs `/tmp/ctl_sl_c3e022a3.csv`, and pristine vs
  patched.  **0 differing rows over 1588 surelog and over 1358 + 1358
  uhdm2rtlil.**
* status histograms IDENTICAL between the two binaries
  (`CMP_EQUAL 940`, `CMP_NOTEQUAL 16`, `SLANG_REJECT 567`, `SURELOG_FAIL 48`,
  `DEFERRED 10`, `NO_DATABASE 3`, `NO_UHDM 1`, `TIMEOUT 1`, `UNTRANSLATABLE 2`)
  — so no segfault hid inside a `SLANG_REJECT`.
* **THE ROWS THAT MUST STAY, quoted verbatim from the PATCHED sweep:**
  ```
  BuildUVMPkg,default,CMP_EQUAL,,,differ
  BuildUVMPkg,testflags,CMP_EQUAL,,,differ
  Earlgrey_0_1,default,CMP_NOTEQUAL,decompile:,,
  Earlgrey_0_1,testflags,CMP_EQUAL,,,
  ```
  identical to the pristine sweep's four lines.  **No conversion in either
  direction**; `results/*.csv` were not edited.
* `byteverify.sh SELFCHECK=1`: surelog MOVERS 3 / 956 (all named and attributed
  in §5), uhdm2rtlil MOVERS 0 / 1358.
* `rowheads.sh` on the seven named rows, both binaries: every cmp log
  BYTE-IDENTICAL except `Earlgrey_0_1.default.cmp` — `SeqDriver` 29/1 both
  modes, `SimpleUVM` 664681/1 both modes, `Scoreboard/default` 95/1,
  `MiniAmiq` 29/1 both modes, `BuildUVMPkg` 0/0 both modes, `Rggen/default`
  0/0, `Earlgrey_0_1/testflags` 0/0.  (`Scoreboard/testflags` and
  `Rggen/testflags` are the expected `SKIP-NOFILE`.)
* canaries: `ok=52 changed=0 absent=0` on surelog, `ok=8 changed=0 absent=0` on
  uhdm2rtlil; `ctcan2.sh` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` →
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* protected databases by name, patched vs pristine md5: `InterfaceModPort`,
  `BlackParrotComplex`, `YosysOldOr` byte-identical in both modes; `SVSwitch`
  pinned at `4842211c4030`; `YosysVerx` pinned at `6ccda350c24a`.

---

## 7. THE WIDE BOUNDARY — EARLIER PASSES' ARMS

`widerun118.sh` stages a COPY of the whole `tools/probe` tree, lists every
`.sv`/`.v` at ANY depth, FILTERS the four slang-fenced names out of the list
BEFORE a single child runs (the fence list is read out of `canaudit.sh`'s own
`FENCED=` line so it cannot drift from the audit), and compares
workdir-normalised uhdm-dumps from both frozen binaries in BOTH views, with
`PROCESSED == LISTED` asserted and rc recorded per side.

```
LISTED=5183   FENCED_REMOVED=0   (of 5183 found)
PROCESSED=5183 identical=9951 DIFFERING=21 no_output=394      PROCESSED==LISTED (5183)
rc by side   A/0 9579  A/139 16  A/3 378  A/4 393
             B/0 9579  B/139 16  B/3 378  B/4 393        <-- IDENTICAL per side
```

The rc histograms are identical side for side, so the patch introduces no
rejection and no signal; the 16 `rc=139` cells are R2's pre-existing
`--elabuhdm` segfault and they crash BOTH binaries.

**21 differing file/views of 9951 comparable, and every one is SECTIONED at
the `weaklyReferenced` marker** (`BOUNDARY_SECTIONED.txt`):

* **the 6 ELABORATED-view differences have `reachable=0`** — every differing
  line is in the weaklyReferenced TAIL, which is unreachable to the judge
  (RESUME.md §9).  That is the same finding as the `testflags/Earlgrey_0_1`
  byte mover in §5, and it is why the elaborated model does not move.
* **the 15 PLAIN-view differences have `tail=0` and, in EVERY one of them,
  every reachable differing line is a removed `|vpiActual:` and the actual
  object under it** — `logic_var`, and on two arms `enum_var`, `bit_var`,
  `struct_var`.  Nothing else changed in any file, at any depth.

Twelve of those fifteen are EARLIER PASSES' arms, so they were re-scored
against GOLDEN with the same grid (`BOUNDARY_ARMS.txt`, 90 rc-0 databases):

```
-- ARM TALLY --   TO-GOLDEN 34   AWAY-GOLDEN 0   MOVED-WRONG 0
                  SAME_AGREE 343  STILL-WRONG 1  (= a2_bind118 s1, R1)
```

Every earlier-pass arm the boundary flagged moves **TOWARD** golden:
`g5_gscope104` (2 keys), `g1_enc105` (6), `g2_pos105` (2), `g5_int105` (1),
`h1_head105` (2), `h2_child105` (2), `g1_home106` (1), `g3_home97` (1),
`pf19` (2), `v123_f_multi` (1, a `bit_var` target), `va7_mix106` (2),
`v3_lhs113` (1, a `struct_var` target) — golden `<null>`, pristine bound,
patched `<null>` in every one.  r10earl105's `h1_head105` / `h2_child105` are
the Earlgrey head's own minimal reproduction, written three passes before this
law existed, and they were wrong on the pristine binary all along.

---

## 8. RESIDUES

* **R0 — THE NEXT HEAD, named and measured.**  `Earlgrey_0_1/default`, now 56
  cmp lines / 1 head, at `padctrl.sv:39:24` inside
  `work@top_earlgrey.u_padctrl.gen_generic`: golden SUBSTITUTES a folded
  `constant` (`vpiDecompile:63`, `UINT:63`, `vpiSize:8`, `vpiConstType:9`)
  where we keep the unfolded cast `operation` (`vpiOpType:67`, its one operand
  the `6'h3F` constant, its typespec `int_typespec (AttrDw)`).  That is the
  `reduceExpr`-folds-the-Rhs-to-a-constant leg of the very same
  `writeCont_assign` (UhdmWriter.cpp:2255-2278, `adjustSize` against the
  target's typespec) — r10earl106's § `genCaCastFoldAdjustSize106` in the
  **NON-elaborated** view, where that pass's consumer half only runs under
  `--elabuhdm`.  `HEAD_AFTER_Earlgrey_default.cmp` holds it.
* **R1 — THE UNSIZED-CONSTANT LEG, measured and NOT taken.**  Arm `a2_bind118`
  row `s1`, `assign s1 = din ^ '1;`: golden leaves the own-scope generate-local
  target UNBOUND there too, and we still bind it — the one `STILL-WRONG` cell
  of §4.  It is `writeCont_assign`'s THIRD clone site
  (UhdmWriter.cpp:2280-2290, `DetectUnsizedConstant` over the whole Rhs), a
  different predicate from a cast, and it has NO corpus population in either
  corpus (the census's FX family shows zero such cells outside the arm).  A law
  of its own, with its own grid, or it is a widening on no evidence.
* **R2 — AN UNMASKED PRE-EXISTING SEGFAULT.**  A generate-scope PROCESS whose
  statement casts `$bits(<its own target>)` crashes BOTH binaries under
  `--elabuhdm` (rc 139) and neither without it.  Measured at `c3e022a3` on the
  pristine binary, so it is not this pass's; the reproduction is
  `a4_procsegv118.sv.txt`, deliberately not named `.sv` so it does not arm a
  landmine in every future pass's wide boundary.  It is why arm `a3_fence118`
  carries no process row.
* **R3 — THE `bit_select` TARGET IS STILL BOTH-NULL AND STILL UNEXPLAINED.**
  Every `bit_select`/`part_select`/`var_select` target in the corpus census is
  `<null>` on BOTH sides in the non-elaborated view (surelog FX: 112 + 4 + 10
  keys) — we agree with golden there by a different mechanism
  (`bindGenLocal9` only fires on a whole `ref_obj`).  Under `-elabuhdm` golden
  binds them and so do we.  Nothing to fix, but the agreement is not the same
  agreement, and a future widening must re-check it.
* **R4 — the 2561 FX `STILL-WRONG` keys of the surelog census** are not this
  family: they are dominated by `hier_path` targets (`Root_value`) and by
  `logic_net` vs `logic_var` actual-kind differences, both of which the judge
  reaches only after fields earlier passes still own.  They are named here so
  the number is not mistaken for this law's residue.
* **R5 — r10earl110–117's arms and fences are untouched**, re-scored by the wide
  boundary over every committed arm and by the corpus census's REST family
  (AWAY-GOLDEN 0, MOVED-WRONG 0, NOGOLD_MOVED 0 on both corpora).

---

## 9. FILES

| file | what it is |
|---|---|
| `own118.cpp` | THE JUDGE, decoded: the null-head owner finder — SafeCompare overload identification, both sides' scope listing, per-container `SafeCompare` with a fresh context, the failing container's element-by-element descent, and the whole-DB name search |
| `OWNER_BEFORE.r10earl118.txt` | its full output on the pristine build |
| `cen118.cpp` | the census: every `cont_assign` target reference and its `Actual_group`, keyed on home/scope-kind/gen-depth/target-kind/name/span, DEF/ELAB out of the key, walking the instance trees and NOT the arena tail.  Emits `CELL` (scored), `VIEWCELL` and `RCELL` (diagnostic Rhs-shape / declaration-home columns) |
| `censweep118.sh` | runs it over a whole `verify_golden.py` workdir, golden path from each test's OWN `cmds.txt`, every rc logged |
| `score118.py` | the three-way multiset join; asserts the two sweeps' golden halves identical FIRST; TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG / STILL-WRONG / NOGOLD, movers as ROWS |
| `predict118.py` | the mover set predicted BY NAME from the PRISTINE census alone, with golden's payload on the same cells beside it |
| `grid118.sh` | the arm grid: every arm × both views × golden + both binaries, censused and scored, every rc recorded |
| `a1_bind118.sv` | the twelve Rhs shapes and target kinds on an own-scope generate-local target |
| `a2_bind118.sv` | the clone LEGS (cast / unsized constant / constant fold) and the SCOPE cut (ancestor, module body, net, depth 2) |
| `a3_fence118.sv` | THE FENCE: the module-body namesake, the module-body target, select targets, a named if-generate, an enum target, an INTERFACE generate scope |
| `a4_procsegv118.sv.txt` | R2's reproduction, deliberately not a `.sv` |
| `GRID.r10earl118.txt` / `GRID_rc.r10earl118.txt` | the scored grid and its rc histogram |
| `NOFENCE.r10earl118.txt` | the THIRD binary's conviction: AWAY-GOLDEN 1 on `a3_fence118` row `f1` |
| `CENSUS_sl.txt` / `CENSUS_u2r.txt` | the corpus three-way scores, calibration line first |
| `PREDICT_sl.txt` / `PREDICT_u2r.txt` | the predictions, made from the pristine databases |
| `attrib118.sh` | the sectioned, path-normalised, ORDER-BLIND whole-dump mover attribution |
| `ATTRIB_Earlgrey_default.diff` / `ATTRIB_Earlgrey_testflags.diff` / `ATTRIB_Scoreboard_coin.diff` | the three byte movers, attributed |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the head logs, both binaries |
| `GATES.r10earl118.txt` | every gate's own output, transcribed |
| `BOUNDARY_WIDE.*` | the wide boundary: tally / listed+FENCED / diff list / rc histogram / rc by side / signals |
| `BOUNDARY_SECTIONED.txt` | each of the 21 differing file/views split at the `weaklyReferenced` marker — reachable lines vs tail lines, with the changed line shapes |
| `BOUNDARY_ARMS.txt` | the 15 differing files, including 12 EARLIER PASSES' arms, re-scored against GOLDEN on both binaries |
| `wide118.sh` `widerun118.sh` | the wide-boundary driver and runner |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the gate scripts this pass RAN, carried so the audit passes here |
