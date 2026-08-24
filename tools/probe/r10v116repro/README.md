# r10v116 — ADVERSARIAL VERIFICATION of r10uvm116 (§ scopeRandomizeIsBareCall116)

**VERDICT: ACCEPT AS SHIPPED.**  Every headline number reproduced bit-for-bit
from a fresh 09dec24 worktree; no pristine-right → patched-wrong cell was found
on any legal-SV surface, so no verifier fix was needed.

## 0. Reproduction

| | |
|---|---|
| patch | `/tmp/r10uvm116.patch`, md5 `827b7402090f12104d985d213ed24a55`, 3819 lines |
| apply | `git apply --check` CLEAN on a FRESH 09dec24 worktree (39 files, +3554) |
| surface | `include/UhdmExporter.h`, `src/ExprEmit.cpp`, `tools/probe/r10uvm116repro/` — nothing else; `results/*.csv` untouched; fence scan 0/0/0/0 |
| patched binary | rebuilt here (`-j 2`) → md5 **`ba96b7757310bfe3577e6e0512cd9617`** — IDENTICAL to the implementer's claim |
| pristine binary | 09dec24 rebuilt here → md5 `b4900a013105152c57a347bda1e33990` |

Both binaries frozen `chmod 555` at `/tmp/v116_bin/{pat,pris}.bin` before any
sweep; `SLANG_UHDM` exported explicitly per binary; every `cmds.txt` audited by
binary PATH.

## 1. Gates — all reproduced

* goldens **23 PASS / 0 FAIL** on BOTH binaries; `SLANG_UHDM=/bin/false` → 23 FAIL.
* uhdm2rtlil testflags **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**.
  `ct8rows` vs the committed `results/gate_uhdm2rtlil.csv` **PASS**; vs my own
  pristine sweep, both modes, **PASS** (status AND dump column).
* surelog `--mode both`: status histograms **byte-identical** pristine vs
  patched (471/466 CMP_EQUAL, 10/9 CMP_NOTEQUAL, 1588 rows).  `ct8rows` vs
  `results/golden_surelog.csv` **PASS** and vs my pristine **PASS** —
  **0 differing rows over 1588. NO row converted.**
* `cmds.txt` audit: u2r 1462 cells, 1458 name the frozen patched binary, 4 name
  none (the 2 SURELOG_FAIL tests × 2 modes), **0 name any foreign binary**;
  surelog 1573 cells, 1523 name the frozen patched binary, **0 foreign**.
* byteverify SELFCHECK=1: u2r **MOVERS 0 / 1358**; surelog **MOVERS 9 / 956**,
  exactly the nine named in `PREDICTION.txt`.  SELFCHECK flagged 1357/1358 and
  955/956, so the gate can see.
* The prediction method re-run from MY pristine databases: **11 of 956** surelog
  DBs contain the symbol `randomize`, **0 of 1358** u2r DBs.  SimpleConstraint
  (default + testflags) holds the symbol, was predicted NOT to move, and did not.
* protected DBs: InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**;
  SVSwitch **4842211c4030**; YosysVerx **6ccda350c24a**.
* canaries `ok=52 changed=0` / `ok=8 changed=0`; ctcan2 both PASS;
  canaudit **audited=29 UNCOVERED=0 FENCE-BREACH=0**.

## 2. Heads — reproduced exactly

| row | pristine | patched |
|---|---|---|
| Scoreboard/default | 60 (1 head) | **46** (1 head) |
| MiniAmiq/default | 60 | **46** |
| MiniAmiq/testflags | 60 | **46** |
| SeqDriver ×2, BuildUVMPkg ×2 | 46 | 46 (head file BYTE-IDENTICAL) |
| SimpleUVM ×2 | 17 | 17 (BYTE-IDENTICAL) |
| Earlgrey_0_1 ×2 | 90 | 90 (BYTE-IDENTICAL) |
| Rggen/default | 0 | 0 |

Pristine head object on the three movers: `method_func_call (randomize)`
@196:10–197:27 with `vpiArgument ref_obj (l_kind)`.  Patched head object:
`ref_obj (uvm_pkg::uvm_sequence_library::m_add_typewide_sequence::this_type::add_typewide_sequence)`
@413:3.

**CORRECTION to the implementer's report.**  It claims "five big UVM rows now
share one head".  Measured: **four** do (SeqDriver, Scoreboard, MiniAmiq,
BuildUVMPkg).  SimpleUVM's head is a different object —
`logic_net: (work@top.p)` @263:3 — and always was.

## 3. Movers scored against golden, field-by-field

For all NINE mover databases I dumped golden, pristine and patched, stripped
`id:`, and compared.  The A-vs-B diff touches **only** the five scope-form
source sites (`uvm_sequence_builtin.svh` 87 / 97 / 196,
`uvm_sequence_library.svh` 673 / 691) — plus, on Scoreboard/default alone, the
documented `svunit_pkg` `vpiTaskFunc` ORDER COIN (sequential 210 vs order-blind
118: the 92-line coin RESUME §9 names).

At **every one of those sites, in every one of the nine databases, the patched
subtree is byte-identical to GOLDEN's** (md5 of the 8–12-line window):

```
BuildUVMPkg  56818 MATCH   56841 MATCH
Scoreboard     673 MATCH     691 MATCH     87/97/196 MATCH
SeqDriver       87 MATCH      97 MATCH   196 MATCH   673 MATCH   691 MATCH
SimpleUVM       87 MATCH      97 MATCH   196 MATCH   673 MATCH   691 MATCH
MiniAmiq ×2     87 MATCH      97 MATCH   196 MATCH   673 MATCH   691 MATCH
```

Whole-dump ORDER-BLIND distance to golden FELL on every mover and rose on none
(e.g. MiniAmiq 493035 → 492913, SeqDriver 478835 → 478697, BuildUVMPkg 70004 →
69972).  **TO-GOLDEN on every real target, AWAY-GOLDEN 0, STILL-WRONG 0.**

## 4. The implementer's own GRID reproduced cell-for-cell

Running the committed `grid116.sh` with my binaries returns the committed table
EXACTLY: `a 56→4 / 183→83`, `b 70→4 / 213→4`, `c 131→131 / 245→245`,
`d 66→21 / 171→81`, `e 4→4 / 46→46`, `f 142→26 / 245→83`, `g 106→4 / 156→53`,
`h 314→4 / 712→163`, `i 64→14 / 161→21`.

**CORRECTION.**  The README says "`g116_b` and `g116_h` were SLANG_REJECT on the
pristine binary".  Measured: `g116_b` yes (pristine exits non-zero with
`unsupported constructs encountered: system method call: randomize`); `g116_h`
**no** — the pristine binary exits 0 and writes a database.

## 5. NINE NEW VERIFIER ARMS — breaking the law

`vgrid116.sh <arm> <pris> <pat> <wd>` builds golden + both binaries in BOTH
views with rc per command; `VGRID.txt` holds the distances.

| arm | what it attacks | def PRIS→PAT | verdict |
|---|---|---|---|
| `v116_p` | `this.randomize()` / `this.randomize(x)` / `this.randomize(x) with{}` / `super.randomize()` / bare `randomize()` in a derived class / scope form in a base | 114 → **93** | the four `this.`/`super.` cells are BYTE-UNCHANGED; only the two scope forms moved, both to golden byte-for-byte |
| `v116_q` | the **EMPTY** `with { }` (with and without an argument), scope `randomize(null)`, member `obj.randomize(null)`, `rand_mode(0)` and `constraint_mode(0)` beside them | 72 → **8** | empty-`with` and `randomize(null)` reach GOLDEN exactly; rand_mode/constraint_mode untouched; the 8 residual lines are the member-form end span (R3) |
| `v116_r` | `$display(randomize(x))`, two randomize calls in one assignment, inside a `for`, inside `fork…join_none`, with-block naming a **package parameter** | 102 → **0** | **BYTE-IDENTICAL TO GOLDEN** |
| `v116_s` | negative control: package function `randomize(a,b)` called scoped AND imported, a module task `randomize_task`, a variable `randomize_var`, hierarchical call | 16 → **16** | **UNCHANGED** — the fence never touches a user `randomize` |
| `v116_t` | `std::randomize(a)`, `std::randomize(a,b)`, `std::randomize(b) with{}` in the SAME method as two scope-form calls | 85 → **51** | all 51 residual lines are the `std::` sites (R1), UNCHANGED; both scope calls reach golden |
| `v116_u` | scope randomize and member randomize both reached through **MACROS**, plus a scope randomize inside `function new()` | 42 → **8** | the macro-expanded with-form reaches GOLDEN including the span through the block's `}`; the macro member form is untouched |
| `v116_v` | parenthesised receivers `(h).randomize()`, `((h)).randomize(x)`, `h_arr[0].randomize()` — the attack on the fence's POSITIONAL receiver test | 1025 → **1025** | Surelog rejects `(h).randomize()` as a syntax error (not legal SV), and the fence does not fire anyway: AB = 0 |
| `v116_w` | `return randomize(x) with{}`, duplicate identifier list `randomize(a,a) with{}`, three names without `with`, `#5`-prefixed and `@(posedge…)`-prefixed calls, `inside` in the block | 152 → **0** | **BYTE-IDENTICAL TO GOLDEN** |
| `v116_x` | parens-LESS `randomize` reached through a macro (`` `define BARE randomize ``), a macro with a trailing block comment, and `` `BARE() `` — the attack on `methodParensWritten77`'s conservative default, which is PARENS-FUL and therefore *fires* §116 | 34 → **34** | **UNCHANGED**: the probe reads the macro DEFINITION site, finds a real non-`(` token, and answers PARENS-LESS |

Elab distance fell on every arm that moved and was unchanged on every control.

## 6. Boundary gate — run independently, three ways

A COPY of the whole probe tree (`/tmp/v116_bnd/probe`, no path filter, `.sv` and
`.v`, list on fd 3, children `</dev/null`, PROCESSED asserted, rc per cell):

```
MODE=file VIEW=def    PROCESSED=3591 LISTED=3591 DIFFER=10  PRIS_REJECT=138 PATCHED_REJECT=138
MODE=file VIEW=elab   PROCESSED=3591 LISTED=3591 DIFFER=10  PRIS_REJECT=152 PATCHED_REJECT=152
MODE=dir  VIEW=def    PROCESSED=1523 LISTED=1523 DIFFER=6   PRIS_REJECT=121 PATCHED_REJECT=121
```

No `asym.txt` in any of the three runs — **no asymmetric reject**.

* **7** of the 10 are this pass's own arms (a, b, d, f, g, h, i).
* **2** are `w4_classbuiltin.sv` carried twice (`r10svs2repro`, `r10uvm77repro`).
  Re-measured against golden: the arm moves at exactly ONE object, line 16's
  `func_call: (randomize) @16:14-16:25` with `vpiParent` → the `operation`, and
  that object is **byte-identical to golden's**; whole-dump distance 45 → 40.
  The parens-less line 15 stays unemitted (R6), i.e. pristine behaviour.
* **1** is `r10buvm22repro/g22.sv` — **R5, and it is PRE-EXISTING**.  Verified
  three ways: (a) golden emits no such value at all; (b) whole-dump distance to
  golden is **3057 on BOTH binaries** — the patch does not move it toward or
  away from golden; (c) the value is an ADDRESS that is deterministic per
  binary and identical between my 09dec24 pristine and the MAIN-TREE binary at
  HEAD `0f3eb2b3` (`UINT:22408601` in three repeat runs each), while the
  patched image gives `22412697`.  It reaches no corpus database.
* The **3 extra dir-mode directories** (`r10uvm75repro`, `r10uvm76repro`,
  `r10v109repro`) are the per-run ORDER COIN, proven: their ORDER-BLIND diff is
  **0 lines each**, and the PRISTINE binary alone produced three different
  dumps in four runs of `r10v109repro` (20 / 20 / 26 line deltas).  The
  implementer saw 4 such directories; the count is a coin, not a measurement.

## 7. Code review of the fence

`scopeRandomizeCall116` reads five disjuncts; every early return is the
pristine path, so the firing set only ever shrinks.  Checked against slang:
`CallExpression::createSystemCall` (`CallExpression.cpp:491`) does push the
receiver into `buffer` ahead of the written arguments and always builds with
`thisClass = nullptr`; `ClassRandomizeFunction::checkArguments`
(`MiscSystemFuncs.cpp:117`) forces every non-receiver argument to be a
`NamedValue` naming a property of that class, or the single `null`;
`ScopeRandomizeFunction::bindArgument` (`:191`) binds through
`Expression::bindLValue`, so `std::randomize`'s arguments really are
`AssignmentExpression`s.  `rawText` is bounds-checked and returns `""` off the
end of a buffer.

**One asymmetry worth recording (no defect demonstrated).**
`methodParensWritten77`'s fail-safe answer is `true` = PARENS-FUL.  For its
original caller that is conservative; for `scopeRandomizeCall116` `true` means
FIRE.  The two paths that can reach it are an unreadable trivia window and a
comment running past 4096 characters.  Arm `v116_x` probes the macro form of
exactly that surface and the probe answers correctly there, and no
corpus/boundary cell reaches it — but a future caller should not assume the
probe's default is conservative in its own direction.

## 8. Residues, re-ranked by what a next pass would gain

1. **R0 (unchanged, correctly named)** — the MEMBER form carrying a constraint
   block, `seq_or_item.randomize() with {…}`.  hier_path `VpiName` IS read by
   Compare, so this is a real judge-visible divergence, present in every UVM
   row and reproduced on arms C and P.
2. **R3** — the member form's hier_path END span (golden runs through the
   written `()`, ours stops at the `(`).  Judge-invisible, but it is what keeps
   arms C/P/Q/U off zero and it will mask nothing else once R0 lands.
3. **R2** — the parented + scoped with-form regime (direct if-condition, or a
   non-leading operand).  Zero corpus population today.
4. **R5** — the pre-existing associative-array range address leak
   (`vpiDecompile` / `UINT`).  `vpiDecompile` IS read by Compare, so this is a
   live hazard the moment an associative-array typedef reaches a corpus test.
5. **R1** (`std::randomize`), **R4** (`void'(randomize(x) with{})`, which
   Surelog itself errors on with `[ERR:CP0332]`), **R6** (parens-less
   receiver-less `randomize`) — all zero comparable corpus population.
6. **New, minor** — § randWithArgNameIsBare116 writes the bare name into
   `VpiFullName` in BOTH views, while golden's ELAB view keeps the scoped name
   (measured on arms A and W).  `VpiFullName` is dump-only and no generated
   `Compare` reads it, so it is invisible to the judge; recorded so a later
   elab-view pass does not read it as evidence.

## 9. Files

| file | what |
|---|---|
| `v116_p..x.sv` | the nine verifier arms |
| `vgrid116.sh` | golden + both binaries, both views, rc per command, path-normalised dumps |
| `VGRID.txt` | the nine arms' distances |
| `movdist.sh` | whole-dump distance to golden for all nine mover databases |
| `score.py`, `score2.py` | the multiset TO-GOLDEN / AWAY line scorer and its per-line explainer |
