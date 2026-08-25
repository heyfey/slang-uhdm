# r10earl94 — § genCaCastOperandParentScopeBind94

**The cast operand is late-bound, and its pool is the gen scope's PARENT scope.**

BASE `e6156a8`, branch `auto5h`. The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge; every
instrument in this directory is MEASUREMENT ONLY.

---

## 1. The head this pass took

`Earlgrey_0_1` / **default**, 29 cmp lines, 1 head (`HEAD_BEFORE_Earlgrey_default.cmp`):

```
prim_lfsr.sv:315   assign next_lfsr_state = LfsrDw'(entropy_i) ^ ({LfsrDw{lfsr_q[0]}} & coeffs) ^ (lfsr_q >> 1);
the `entropy_i` at 315:38-315:47, parent operation 315:30-315:48 (vpiCastOp)
instances work@top_earlgrey.u_aes.aes_prng.aes_prng_lfsr and
          work@top_earlgrey.u_alert_handler.i_ping_timer.i_prim_lfsr

  golden  ref_obj entropy_i  Actual_group -> logic_net entropy_i 55:33-55:42
  ours    ref_obj entropy_i  Actual_group -> <null>
```

The cmp head prints `LHS: logic_net(entropy_i)` and `RHS: <null>` because
`BaseClass.h`'s SINGULAR `SafeCompare` with `rhs == nullptr` sets only
`m_failedLhs`, and sets it to the POINTEE — so the head NAMES THE NET AND HIDES
THE OWNER (RESUME §9). `r0ref94.cpp` is the generic locator that names the
owning `ref_obj`; `ln94.cpp` prints every object at one source line with the
fields the generated Compares read, and it is what separated the TWO copies of
the elaborated cont_assign that `Earlgrey_0_1`/testflags carries.

The decisive measurement is that the **same statement's other reads agree**:
`coeffs` (315:74) and `lfsr_q` (315:85) are `<null>` in golden AND in ours, the
LHS `next_lfsr_state` is bound in both, and only the operand of the SIZE CAST
differs. The defect is not "gen-scope refs do not bind"; it is one position.

## 2. The decoded model (Surelog)

`CompileExpression.cpp:2643`, the `paCast` / `paConstant_cast` arm, compiles the
cast's OPERAND with a **null `pexpr`**:

```cpp
operand = compileExpression(component, fC, Expression, compileDesign,
                            reduce, /*pexpr=*/nullptr, instance, muteErrors);
```

It is the one operand position in the compiler that does this; every other
operand is compiled against its own operation. The name arm
(`CompileExpression.cpp:2982-3001`) then reads that null:

```cpp
if (pexpr)         { if (var = bindVariable(component, pexpr, name)) ref->Actual_group(var);
                     else if (component) component->needLateBinding(ref); }
else if (instance) { … }
else if (component)  component->needLateBinding(ref);
```

so a BARE NAME under a cast never runs `bindVariable`'s parent walk — the same
"`pexpr` is null ⇒ late binding" mechanism `§ pkgSubRefBindsPkgVarOverFormal81`
decodes in `ExprEmit.cpp` — and lands in the late-binding pool instead.
`UhdmWriter::lateBinding` (`UhdmWriter.cpp:3294`) is then run ONCE PER WRITTEN
SCOPE (`UhdmWriter.cpp:1575 / 1623 / 2072 / 4785`, the last under
`if (mod && netlist)`) and resolves the name against THAT scope's `Nets()` /
`Array_nets()` / `Variables()` listing.

The scope a generate block's refs are written against is the one that OWNS the
block, so **the pool is exactly the gen scope's parent scope, one level and one
level only** — the enclosing module instance for a top-level gen scope, the
enclosing GEN SCOPE for a nested one. The DEF-view listing carries no netlist,
so `lateBinding` never runs there and every such ref stays null in the
definition — which is exactly what golden shows (`work@prim_lfsr`'s own listing
has `entropy_i` unbound, on both sides, before and after).

## 3. The law

`src/ModuleEmit.cpp`, inside `emitBlock`'s ELABORATED gen-scope `cont_assign`
loop, after the Rhs is emitted and after
`§ genCaOpDeepBindGenLocal20`'s walk: descend the emitted Rhs through
OPERATIONS only, and on the FIRST operand of a `vpiCastOp` that is a `ref_obj`
with a NULL `Actual_group`, bind the object `netMap` holds for the
**same-named Variable or Net whose parent scope is the gen scope's parent
scope** (skipping the `GenerateBlockArray` a gen-for body hangs under).

Two implementation traps, both MEASURED, both recorded in the law's comment:

* **Ports.** A module port is listed twice in the body — the `PortSymbol` from
  the header and the net it wraps — and the header one comes first. Scanning
  `members()` and stopping at the first name match left EVERY port operand
  unbound: `g6_depth94` / `g7_flat94` bound `m_var` and not `a_i`, and the
  Earlgrey head itself is a PORT. The pool is read out of `netMap` (the objects
  already emitted), which holds the INTERNAL net — which is what `lateBinding`
  searches.
* **Never `Scope::members()`.** Walking the parent scope's `members()` FORCES
  that scope's deferred member elaboration, and doing it here reordered
  `SeqDriver`'s dump in BOTH modes (an ORDER-ONLY move: sorted, path-normalised
  dumps byte-identical, 0 differing lines) — the AST-forcing Heisenbug RESUME §9
  records. The shipped law iterates `netMap` and compares `getParentScope()`,
  the same idiom the gen-scope CA LHS binder above it already uses.

## 4. The fences, each MEASURED on a purpose-built golden

`ARMS.r10earl94.txt` carries every cell. Seven arms, both views, one gen_scope
per row.

BOUND in golden (the law fires):

| arm | row | target |
|---|---|---|
| g3 `gen_if` / `gen_for` / `gen_case` / unnamed | `W'(a_i)`, `W'(m_var)`, `W'(m_wire)` | a PORT net, a module `logic` var, a module `wire` |
| g3 `gen_in`, g4 `gl3`, g5 `gf` | `W'(o_loc)`, `W'(v2)`, `W'(ov)` | the PARENT gen block's local |
| g4 `gsh` | `W'(sh_var)` | the MODULE-level `sh_var`, **not** the gen-local of the same name — the lookup is BY NAME in the parent scope |
| g4 `gfor` (3 iterations) | `W'(m_var)` ×3 | a gen-for body skips its `GenerateBlockArray` to reach the module |
| g5 `gx` | `W'(m_var)` under a SELECT LHS | golden's elaborated copies are VpiParent-less orphans; the LOOSE census family is what sees them |

NOT bound in golden (the law abstains):

* the gen scope's OWN local — g1 `g_loc`, g3 `g_loc`/`l_loc`/`k_loc`/`i_loc`,
  g4 `v3`/`w1`/`tv`, g5 `fv`/`yv`;
* a GRANDPARENT scope's name — g4 `gl3`'s `v1` and `m_var`, g3 `gen_in`'s
  `a_i`/`m_var`, g5 `gf`'s `m_var`: **one level only**;
* a genvar (g3 `gi`), an enum constant (g5 `E_B`), and a parameter/localparam
  (they fold to a constant before a ref exists: g1 `W'(W)`, g5 `W'(LQ)`/`W'(PW)`);
* an operand that is NOT a bare name — `W'(m_var[0])`, `W'(arr[0])`,
  `W'(a_i + m_var)` (g4 `gnb`): those operands are compiled against their OWN
  select/operation, `pexpr` is not null, and they never reach the pool;
* a PROCESS (g2 `n3` already agreed; g4 `gp2` does not — see R1);
* an INTERFACE gen scope (g5 `the_if`) already agrees on both sides.

Corpus witness for the abstentions: the 142 elaborated gen-scope cast operands
Earlgrey leaves null and golden leaves null too are `prim_fifo_sync`'s
`wptr_value`/`rptr_value` (declared INSIDE the same gen scope, :65/:66),
`tlul_socket_1n`'s genvar `i` (:128), and `tlul_adapter_host`'s `source_q`
(declared inside `g_multiple_reqs`, :55). Not one of them is a parent-scope name.

## 5. What moved

Prediction (blind — the census in `CENSUS.r10earl94.txt` reads PRISTINE
databases only and was scored before a line of the law was written):
**exactly two databases, `Earlgrey_0_1` default and testflags, four cells**
(`entropy_i` × two `prim_lfsr` instances × two modes); **uhdm2rtlil: zero**,
because it holds no null cast operand in an elaborated gen scope at all.

`byteverify SELFCHECK=1`, patched sweep vs this pass's OWN pristine sweep (all
binaries frozen `chmod 555` at immutable paths before any sweep; every
`cmds.txt` audited BY BINARY PATH — 0 of 1573 + 1462 name the main-tree binary):

```
uhdm2rtlil  MOVERS 0 / 1358      SELFCHECK 1357/1358 flagged
surelog     MOVERS 5 /  956      SELFCHECK  955/ 956 flagged
    ./default/Earlgrey_0_1     <- PREDICTED, the law
    ./testflags/Earlgrey_0_1   <- PREDICTED, the law
    ./default/SeqDriver        <- BUILD LAYOUT, see below
    ./testflags/SeqDriver      <- BUILD LAYOUT, see below
    ./default/Scoreboard       <- the documented COIN, see below
```

**SeqDriver, both modes: NOT the law.** A binary built from PRISTINE `e6156a8`
with ONE behaviour-free line added to `src/ModuleEmit.cpp` —
`__attribute__((used)) static char r10earl94_layout_pad[64];` — and NOTHING else
reproduces the PATCHED hashes EXACTLY, on the whole-corpus sweep:

```
layout control vs pristine (956 databases)   MOVERS 2 / 956
    ./default/SeqDriver    layoutctl d56dec429669   pristine 59faaf3106e0
    ./testflags/SeqDriver  layoutctl 48efd6ae07ab   pristine df3580c736e2
patched                    default   d56dec429669   testflags 48efd6ae07ab
```

and the order-blind attribution agrees: the sorted, path-normalised dumps are
byte-identical (0 differing lines), so the SET of dump lines never changed —
only its order. The layout control does NOT move Earlgrey (its Earlgrey hashes
equal the pristine ones), so the Earlgrey move is the law and nothing else.
Filed as R2. `byteverify` patched vs the LAYOUT CONTROL is the clean read:
**MOVERS 3 / 956 — Earlgrey ×2 (the law) and Scoreboard/default (the coin).**

**Scoreboard/default: the documented ~50/50 coin** (RESUME §9). The PRISTINE
binary alone, run six times on the same sources, produced BOTH hashes
(`9740ea5bb6b6` ×3, `5dcb6a96a2ab` ×3), and every order-blind pairing
(pristine/patched, pristine/layoutctl, layoutctl/patched) is 0 differing lines.

## 6. The census, re-scored over the same fixed universe

`ct94cen` enumerates four families in the fields the generated Compares
actually read (earl60's `attrv60.py` lesson — a span-carrying payload can hide
a kind flip, so the payload IS the compared fields):

* **RF** every `ref_obj` in a gen scope or in a cast, keyed
  `VIEW|GEN|CTX|DEPTH|INST|NAME|SPAN|PARENT-KIND|PARENT-SPAN`, payload the
  `Actual_group`'s kind and span;
* **RL** the same cell under a LOOSE key with no instance and no depth — the
  blind-spot-free family, because Surelog leaves an elaborated select-LHS gen
  cont_assign with a NULL `VpiParent` and the strict key cannot reach it;
* **SL** every OPERAND SLOT of every operation in a gen scope, payload the
  child's KIND plus its compared fields — this is the family that would see a
  ref↔constant flip;
* **GA** the GLOBAL tripwire over EVERY `ref_obj` in the database, so a binding
  appearing anywhere outside the law's population cannot hide below the filters.

`score94corpus.py` joins the two sides as a MULTISET (keys collide; a
last-writer dict drops rows). Whole universe, 956 surelog + 1358 uhdm2rtlil
databases, `nogolden=0`, every `ct94cen` rc=0 on both sides, **golden side
asserted byte-unchanged**:

```
surelog     BOTH-SAME 2 102 537 -> 2 102 551
            MOVED-WRONG   3 025 ->     3 013     <- the head, 12 cells
            GOLDEN-ONLY  22 819 ->    22 817
            OURS-ONLY   501 361 ->   501 359
uhdm2rtlil  every bucket of all four families UNCHANGED, and the two census
            files are BYTE-IDENTICAL before and after
```

`verd94corpus.py`, the CELL-level verdict (bucket counts can hide a swap):

**WRONG→RIGHT 12, RIGHT→WRONG 0, AWAY-GOLDEN 0, STILL-WRONG 0** on surelog;
**0 / 0 / 0 / 0** on uhdm2rtlil. Every one of the 12 changed rows is
`entropy_i` at `315:38-315:47` going from `-@-` to `logic_net@55:33-55:42`,
which is golden's payload, in the RF, RL and SL views of the two databases.

Arm-level, all seven arms × both views (`ARMS.r10earl94.txt`):
**WRONG→RIGHT 320, RIGHT→WRONG 0**, with no cell-count change anywhere. The
only "no-golden-key" rows are g2's nested cast `W'(W'(a_i))` — slang collapses
the inner cast out of the AST, so our operand hangs under the OUTER cast's span
where golden's hangs under the inner one (earl93 R2's shape) — and g5's
orphan-parented select-LHS copies; under the LOOSE key both land on exactly
golden's payload multiset.

## 7. Gates (all green)

```
build            pristine   377572c695d6878809390a6912be5481   (e6156a8)
                 patched    d56a5ef7bb590a992d4d5c34e8f6302c
                 layoutctl  5a69ef5f59afb965370ef00b96e08639   (e6156a8 + 64 B .bss, measurement only)
goldens          patched 23 PASS / 0 FAIL;  pristine 23/0;  SLANG_UHDM=/bin/false 0 PASS / 23 FAIL
u2r testflags    679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL   (default identical)
ct8rows          baseline vs patched, pristine vs patched, both corpora, both modes: PASS
                 (every row byte-identical in STATUS and DUMP; no row converted)
surelog          default 471 EQ / 10 NE;  testflags 466 EQ / 9 NE — histograms identical to pristine
canaries         ok=52 changed=0 (surelog), ok=8 changed=0 (u2r)
ctcan2           EXPECT_UNKNOWN=1 PASS, EXPECT_UNKNOWN=6 PASS
canaudit         PASS
protected DBs    InterfaceModPort / BlackParrotComplex / YosysOldOr SAME;
                 SVSwitch 4842211c4030;  YosysVerx 6ccda350c24a
heads            SeqDriver 62/62, SimpleUVM 62/62, Scoreboard 62/SKIP, MiniAmiq 62/62,
                 BuildUVMPkg 174/174, Rggen 0/SKIP — byte-identical before and after
                 Earlgrey_0_1 default   29 -> 46 cmp lines, 1 head   <- HEAD CLEARED, moved on
                 Earlgrey_0_1 testflags 50 -> 50 cmp lines, 1 head   <- unchanged
```

The `Earlgrey_0_1`/default head is CLEARED: it was the `entropy_i` null actual
and it is now the SAME `LfsrDw` fold the testflags mode already sat on
(`HEAD_AFTER_Earlgrey_default.cmp` / `HEAD_AFTER_Earlgrey_testflags.cmp`). The
two modes now share ONE head and ONE mechanism.

## 8. The wide boundary

`vwide94.sh`: every `.sv`/`.v` at ANY depth under a COPY of `tools/probe`, both
views, both frozen binaries, workdir-normalised dump byte-compare; the file
list on fd 3, children `</dev/null`, PROCESSED asserted, every rc recorded.

```
PROCESSED=4199 identical=8032 DIFFERING=14 no_output=352
rc histogram   rc=0 15390   rc=3 676   rc=4 702   rc=139 28
rc BY SIDE     0 A 7695 / 0 B 7695     3 A 338 / 3 B 338
               4 A 351 / 4 B 351     139 A 14 / 139 B 14      (symmetric)
```

**9 of the 14** are this pass's own arms — the law's intended movers and the
positive control that proves the gate can see. **2** are
`r10buvm22repro/g22.sv` (plain and elab): earl93's R5, the
build-layout-dependent associative-index range, re-proven here — the LAYOUT
CONTROL shifts the same constants by exactly 64 (its own `.bss` delta) while
the patch shifts them by 4096, and the line count is identical in all three
binaries. **3** are `r10earl57repro/v2_contexts57.sv` (plain) and
`v3_gengrid57.sv` (plain and elab), and they ARE this law: scored against
purpose-built Surelog goldens they are **WRONG→RIGHT 21 and 39, RIGHT→WRONG 0,
0 cell-count changes, 0 no-golden-key changes** — `v2_contexts57` reaches
MOVED-WRONG 0 / GOLDEN-ONLY 0 on the census families. The layout control does
not move either earl57 arm.

`BOUNDARY_WIDE.attribution.txt` carries the full table.

## 9. Reproducing

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib64:$HOME/.local/lib
g++ -O2 -std=c++17 -I ~/.local/include ct94cen.cpp -o /tmp/ct94cen \
    -L ~/.local/lib64 -luhdm -lcapnp -lkj
BIN=<binary> bash run94.sh g3_kind94.sv /tmp/out_g3        # one arm, both views
/tmp/ct94cen /tmp/out_g3/plain/g.uhdm > /tmp/g.cen
/tmp/ct94cen /tmp/out_g3/plain/o.uhdm > /tmp/o.cen
python3 score94.py /tmp/g.cen /tmp/o.cen                   # buckets
python3 verd94.py /tmp/g.cen /tmp/o.cen /tmp/q.cen         # cell verdict
CEN94=/tmp/ct94cen bash cen94.sh <sweep-workdir> /tmp/cen  # the corpus census
python3 score94corpus.py /tmp/cen.g /tmp/cen.o --cells /tmp/cen.cells
python3 verd94corpus.py  /tmp/cen.g /tmp/pris.o /tmp/patc.o
```

`ln94.cpp <db> <line> [inst]` and `r0ref94.cpp <db> <name>` are the two head
locators. The four slang-fenced tests are NEVER dispatched and no file here
spells them; `dirmap94.sh` lists their directories as opaque hashes only.
