# r10v179 — ADVERSARIAL VERIFICATION OF r10uvm179 (§ `recvCallArgRefVarLocalNeverBinds179`) — **VERDICT: ACCEPT, no fix needed**

**MEASUREMENT ONLY.**  Nothing here is an acceptance judge.  The official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`, md5 `2ad8015175758e918de1789b86ef1ea5`)
and `scripts/verify_golden.py` are the authorities for every number.
**LHS is ALWAYS golden; RHS is ALWAYS ours.**  slang was NOT patched;
`results/*.csv` were READ ONLY; no row was converted; `GOLDEN_DEFER` stayed
unset; the four slang-fenced tests were never dispatched and are not spelled in
any file of this directory.

| | |
|---|---|
| BASE | `cf42ecc3` |
| worktrees | fresh `cf42ecc3` for the pristine build, a second fresh `cf42ecc3` with `/tmp/r10uvm179.patch` applied |
| pristine binary | md5 `3eb10767c383f6ca2086f359842a4e98` — **the implementer's number, reproduced bit for bit** |
| patched binary | md5 `9af644fd7023a6661a2976fbd0c0033a` — **reproduced bit for bit** from the patch on a fresh `cf42ecc3` |
| both frozen | `chmod 555` copies at immutable paths before any sweep; **0 of 3146 surelog + 2924 uhdm2rtlil `cmds.txt` name the main-tree binary** |

## 1. HEADLINE NUMBERS, ALL REPRODUCED

| claim | verifier's own measurement |
|---|---|
| goldens 23/0 pristine, 23/0 patched, 0/23 with `/bin/false` | **reproduced** |
| u2r testflags and default `679 / 50 / 2` | **reproduced**, both binaries, both modes |
| u2r `ct8rows` PASS vs `results/gate_uhdm2rtlil.csv` and vs own pristine | **PASS**, testflags and default |
| surelog `--mode both`, 0 differing rows over 1588 vs `results/golden_surelog.csv` AND vs own pristine | **PASS**, status AND dump column; **no row converted** |
| status histograms identical in every bucket, `SLANG_REJECT 567` | **reproduced** — no hidden rc=139 |
| byte movers 9/956 surelog, 0/1358 u2r | **reproduced** (`byteverify.sh SELFCHECK=1`; `PATH_SETS_IDENTICAL`) |
| the 9 movers were PREDICTED BY NAME | the predicted list in `PREDICT.r10uvm179.txt` is **exactly** the measured set |
| each mover is FOUR order-blind dump lines: two removed `vpiActual` edges | **reproduced for all nine**, `uvm_sequencer::item_done::t` and `uvm_sequencer_param_base::send_request::param_t`; Scoreboard/default's order-blind diff is those four lines and nothing else, so **the coin did not flip** |
| heads: SimpleUVM ×2 `29 → 664681`, every other row unchanged | **reproduced** (SeqDriver 33/33, Scoreboard/default 95, MiniAmiq 33/33, BuildUVMPkg 52/52, Earlgrey 31/48, Rggen 0); ONE head per row |
| the committed head logs `head_pris_SimpleUVM.{default,testflags}.cmp` and `head_pat_SimpleUVM.default.cmp` | **byte-identical** to this verifier's own cmp logs |
| canaries `ok=52 changed=0` / `ok=8 changed=0`, `ctcan2` PASS ×2, `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` | **reproduced** |
| protected databases byte-identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | **reproduced** |
| WIDE boundary `PROCESSED=4909 MOVED=30 ASYMMETRIC_OUTPUT=0` | **reproduced as `LISTED=4913 PROCESSED=4913 MOVED=38 ASYMMETRIC_OUTPUT=0 PROCESSED-ASSERT-OK`** — 4913 = 4909 + this verifier's own four arms, 38 = 30 + those arms' eight views.  The 30 split exactly as claimed: 8 `g179_*`, 22 belonging to r10buvm5 / r10uvm107 / r10v107 |
| the eleven moved non-own arm files, cmp DEF pristine → patched | **every number reproduced** (29→0, 29→0, 29→3542, 29→3170, 29→449, 29→510, 29→29, 29→1038, 29→2118, 29→33, 29→33) |
| `a1_refvarbind` and `v107_b12` go CMP_EQUAL | **reproduced** (rc=0, 0 cmp lines, both views) |
| the three MOVED-WRONG arm cells | **reproduced**, cell for cell, with an INDEPENDENT scorer |

**No arm-view anywhere went from CMP_EQUAL to CMP_NOTEQUAL.**

## 2. THE INDEPENDENT INSTRUMENT

`vscore179.py` is deliberately NOT the pass's `ct179cen`: it reads `uhdm-dump`
TEXT, keys every reference on `(kind, base name, span, listing home + enclosing
subroutine)` and joins the three sides as MULTISETS, so a reference listed twice
(the class-body copy and the def-package copy, or an import clone) is counted
twice and cannot be silently folded.  Every score below is that instrument's,
over databases this verifier built.

## 3. THE ONE-LINE REFUTATION OF r10uvm177's R0, MADE CHEAPLY

SimpleUVM/default, occurrences of the `ref_var` DECLARATION object
`uvm_pkg::uvm_sequencer_param_base::send_request::param_t` in the whole dump:

```
golden   8        pristine  9        PATCHED  8
```

The ninth occurrence in the pristine dump is the printed `vpiActual` TARGET of
the `ref_obj` at 297:26, not a ninth listed `Variables` entry.  Removing that
one edge lands on golden's count exactly; deleting a `Variables` entry — which
is what r10uvm177's own R0 directed — would have taken it to **7**.
r10v177's correction stands, from a second direction.

## 4. THE ADVERSARIAL ARMS (this directory's `v179_*.sv`, ONE fresh Surelog golden each, DEF and ELAB)

Written from scratch, with names, orders and numbers unlike the pass's own arms.

### `v179_a_recv.sv` — RECEIVER SHAPES  (DEF **MOVED 3 / TOGOLD 3 / AWAY 0 / MW 0**, ELAB the same)

| cell | receiver | golden | pristine | patched |
|---|---|---|---|---|
| `z01` | one class PROPERTY | BARE | BOUND `ref_var` | **BARE** |
| `z02` | a body-LOCAL handle | BARE | BOUND `ref_var` | **BARE** |
| `z14` | the face inside a **TASK** body | BARE | BOUND `ref_var` | **BARE** |
| `z03` | an `a.b` CHAIN | BARE | BOUND | BOUND — residue R2 |
| `z04` | `bank[2]` INDEXED | BARE | BOUND | BOUND — residue R2 |
| `z05` | `assoc["k"]` ASSOCIATIVE-indexed | BARE | BOUND | BOUND — **R2, a shape the pass did not measure; same verdict** |
| `z06` | `deck[0]` QUEUE-indexed | BARE | BOUND | BOUND — **R2, likewise new** |
| `z07` `z08` | `this.p.` / no receiver | agreed | agreed | unmoved |
| `z09` `z10` | **a bare `virtual interface` at depth 0 — r10uvm176's face** | agreed | agreed | **UNMOVED** |
| `z11` `z12` `z13` `z15` | the STATEMENT twins, and a TASK-kind callee | BOUND | BOUND | BOUND |

### `v179_b_arg.sv` — ARGUMENT KINDS x DEPTHS x THE TWO-DEPTH PAIR  (DEF MOVED 8 / TOGOLD 6 / AWAY 0 / **MW 2**)

Every moved cell is TOGOLD; the two MOVED-WRONG cells are the pass's own
residue R4 reproduced independently and in **both** of its spellings:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `y00` | the face at depth 0 | BARE | BOUND `ref_var` | **BARE** |
| `y01` `y03` | depth 1 / depth **3** | BARE | BARE | BARE |
| `y_pair` | **the SAME call at depth 0 and depth 2 in ONE subroutine on ONE local** | d0 BARE, d2 BARE | d0 BOUND, d2 BARE | **d0 BARE, d2 BARE** — both cells land on golden |
| `y_two` | TWO `ref_var` arguments in one call | BARE ×2 | BOUND ×2 | **BARE ×2** |
| `y_nested_free` | `rk.look(loose_pass(loc))` — a receiver-LESS call nested inside the face | BARE | BOUND | **BARE** |
| `y_blocklocal` | declared IN the block that raised the depth | BARE | BOUND | **BARE** |
| `y_formal` | a FORMAL | `io_decl` | `io_decl` | unmoved |
| `y_prop` | a class PROPERTY | BARE | BARE | unmoved |
| `y_pkgvar` | **a PACKAGE VARIABLE** | `int_var` | `int_var` | **unmoved** |
| `y_pkgparm` | **a PACKAGE PARAMETER** | `constant` | `constant` | **unmoved** |
| `y_lit` | a LITERAL | agreed | agreed | unmoved |
| `y_shadow_v` | a local whose NAME is a **package VARIABLE** | BOUND `int_var` | BOUND `ref_var` | BARE — **MW** |
| `y_shadow_p` | a local whose NAME is a **package PARAMETER** | BOUND `constant` | BOUND `ref_var` | BARE — **MW** |

The two MW cells are **wrong before and wrong after**: golden binds the
PACKAGE object (`lateBinding`'s last-writer walk), pristine bound the LOCAL's
`ref_var`, patched binds nothing.  Neither binary is right, so nothing that was
right was lost, and the corpus holds no cell of the shape (the nine byte movers
are the two `try_put`/`try_get` cells and nothing else).

### `v179_c_home.sv` — HOMES  (DEF **MOVED 2 / TOGOLD 2 / AWAY 0 / MW 0**, ELAB the same)

Out-of-body FUNCTION and out-of-body TASK of a package class move to golden.
**Unmoved, both binaries:** the in-body method (§ 52 owns it), a `$unit`
class's out-of-body method (residue R3), an INTERFACE's own function, a
PROGRAM's own function, **the MODULE FUNCTION and the MODULE PROCESS controls**,
and the package free bodies below.

### `v179_e_freefn.sv` — THE UNTESTED HALF OF `pkgDefViewBody9`, AND WHY IT IS UNREACHABLE

`pkgDefViewBody9` is true for a package FREE function/task in the def pass, not
only for the out-of-body class-method clones, so the predicate's guard is wider
than the law's measured population.  This verifier tried to reach it and could
not: a package free body's local is emitted as a resolved object in every legal
spelling tried — a forward-declared class handle, a `virtual interface` handle,
and a **parameterized-class specialization** `Box #(WID)` all come out
`class_var` on BOTH sides (arm E scores **0 disagreeing keys**, DEF and ELAB),
and the "typedef declared later" spelling is not legal SV (slang and Surelog
both reject use-before-declaration in a package).  The `ref_var` shape the
predicate keys on needs a **class TYPE PARAMETER**, which exists only in a class
body.  So the free-function branch is unreachable by construction rather than
unmeasured — recorded as residue **R6**, a documentation gap, not a defect.

### `v179_d_fifo.sv` — THE CORPUS SHAPE, 1 / 2 / 3 INSTANCES  (DEF and ELAB **TOGOLD 3 / AWAY 0 / MW 0**)

A queue-backed `try_put` / `try_get` / `try_peek` triple in an out-of-body
method of a package class, imported by three modules holding one, two and three
instances.  **After the patch the arm's reference face disagrees with golden in
ZERO keys, in both views.**  The order-blind pristine-vs-patched dump diff is
**six lines: three removed `|vpiActual:` and their three targets** — nothing
created, nothing reshaped, which is the DIRECTION=SUPPRESS claim measured
rather than asserted.  The class-body listing keeps § 107's minted
`logic_net` on both binaries and in golden.

### `v179_f_nomod.sv` — THE FACE WITH NO IMPORTING MODULE

A package with no module anywhere and a second package importing it.  DEF:
golden BOUND ×2 (the class-body listing and the import clone), pristine ×3,
patched ×2 — **golden's multiset exactly**, patched-vs-golden disagreement 0.
ELAB: Surelog cannot elaborate a design with no top and writes a PRE-ELAB
database (`rc=4`); the official judge reports **EQUAL for both binaries**, so
the view carries no verdict and its scorer row is a listing-multiplicity
artifact, recorded and discarded.

## 5. THE READING OF THE PATCH ITSELF

The change is `window = false` under `recvUserMethodArgDepth107 > 0 &&
pkgDefViewBody9`, inside `refVarLocalNoBind5` (`src/ExprEmit.cpp:690`).  Read
against its two neighbours it is far narrower than it looks:

* gate (1) of the predicate already requires the emitted DECLARATION to be a
  `ref_var`, which is exactly the candidate every arm of Surelog's
  `UhdmWriter::lateBinding` skips (`if (decl->UhdmType() == uhdmref_var)
  continue;`, ~40 sites), and the fall-through mint at
  `UhdmWriter.cpp:3982-4004` is guarded on `module_inst || interface_inst ||
  program`.  A PACKAGE scope therefore binds nothing — the decode is correct as
  written.
* the counter is raised at ONE site (`src/ExprEmit.cpp:21513`) under
  `!callStmtCtx0 && recv0.kind == NamedValue`, i.e. expression position with a
  one-name receiver — never in statement position, never for the interface/vif
  arm (which uses `RecvCallArgIf52`), never for built-ins.
* `oobRefVarLocalHoistNet107` already returns `!bind5 || recvUserMethodArgDepth107 > 0`,
  so wherever `hoistHomePkg117()` is non-null the reference was pooled and
  net-bound BEFORE the patch too.  The delta is therefore confined to
  `hoistHomePkg117() == nullptr && pkgDefViewBody9 && recvUserMethodArgDepth107 > 0`,
  and `pkgFreeSubHomePkg117` is only set under `pkgTopEmit` while
  `pkgDefViewBody9` needs `cloneMode || !pkgTopEmit` — the two are disjoint.

**That is also the proof that the `pkgDefViewBody9` conjunct is INERT**, and it
is a stronger proof than the implementer's byte-identical home-blind build:
dropping the conjunct would open the class-body listing, where § 107's own
disjunct forces `bind5 = false` regardless.  The implementer reports the
conjunct as inert and is right.  **One documentation defect follows** (§7 R-D1).

## 6. RANKED RESIDUES (this verifier's ranking)

1. **R4 / R0b — the shadowed name.**  Reproduced in BOTH spellings
   (`y_shadow_v` a package VARIABLE, `y_shadow_p` a package PARAMETER); golden
   binds the package object through `lateBinding`'s last-writer walk, neither
   binary does.  Wrong before, wrong after; **zero corpus cells**; now visible.
   The implementer's R0b names it and hands it on — correct.
2. **R2 — deep / indexed receivers.**  Widened here from the pass's two
   spellings to four: `a.b` chain, constant index, ASSOCIATIVE index, QUEUE
   index.  All four are golden-BARE in the package listing and bound by both
   binaries.  Zero corpus cells.  Widening the counter widens § 107's net
   pooling with it, so it is correctly deferred.
3. **R1 — a BUILT-IN method in the same window** (`amap.exists(v)`); reached
   through a different emitter arm.  Unchanged by this pass.
4. **R3 — a `$unit` class's out-of-body method.**  Unchanged.
5. **R6 (new) — `pkgDefViewBody9`'s free-function branch is unreachable.**  The
   guard admits a body no legal spelling can put a `ref_var` local into (arm E).
   Harmless; worth a line in the law so a later reader does not go looking for
   the cells.

## 7. DEFECTS FOUND (documentation only; none blocks the landing)

* **R-D1 — an internal contradiction in the pass's own write-up.**
  `include/UhdmExporter.h` says the conjunct "is what makes the ELAB arm
  reproduce golden's `{BARE, BOUND=ref_var}` multiset exactly, and what leaves
  MiniAmiq's `svaunit_pkg` import clones untouched", while §4 of the README (and
  this verifier's reading of `oobRefVarLocalHoistNet107`) shows it is INERT on
  every measurable cell and that the ELAB copy and the import clones never call
  the predicate at all.  Both statements are in the same patch.  The README's
  §4 is the correct one; the header sentence overstates.  Cosmetic — the code is
  right either way.
* **R-D2 — `pkgDefViewBody9`'s free-function branch** (residue R6 above) is
  described as "the listing golden leaves bare" without noting that half of the
  bodies it admits cannot carry the object the predicate keys on.

## 8. FILES

| file | role |
|---|---|
| `v179_a_recv.sv` | receiver shapes incl. the vif must-stay and two receiver spellings the pass did not measure |
| `v179_b_arg.sv` | argument kinds, depths 0-3, the two-depth pair in one subroutine, both shadowed-name spellings |
| `v179_c_home.sv` | homes: in-body / oob function / oob task / `$unit` / interface / program / **module function and module process controls** |
| `v179_d_fifo.sv` | the corpus `try_put`/`try_get` shape with 1, 2 and 3 instances |
| `v179_e_freefn.sv` | the package-free-body branch of `pkgDefViewBody9` — the unreachability control |
| `v179_f_nomod.sv` | the face with NO importing module, plus an import clone |
| `vgrid179.sh` | the verifier's arm driver — Surelog golden + both FROZEN binaries, both views, every rc recorded, `uhdm-dump` on all six databases, the official judge on each arm-view |
| `vscore179.py` | the verifier's own multiset scorer over `uhdm-dump` text (TOGOLD / AWAY / MOVED-WRONG) |
| `VERIFIED.r10v179.txt` | the gate transcript |
