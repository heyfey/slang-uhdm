# r10v143 — ADVERSARIAL VERIFICATION of r10uvm143 (§ `hpIdxClassBodyNeverLateBinds143`)

**VERDICT: ACCEPT.**  Every headline number in the implementer's report
reproduced **bit-for-bit** on my own worktrees, my own builds and my own
sweeps — including both binary md5s and the patch md5.  Thirteen fresh arms
(26 arm-views, DEF **and** ELAB) built to break the law found **AWAY-GOLDEN 0
and MOVED-WRONG 0**: no pristine-RIGHT → patched-WRONG cell on any legal SV I
could write.  Production is shipped **unchanged**.

**MEASUREMENT-ONLY.**  Nothing in this directory is an acceptance judge; the
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number.  **LHS IS ALWAYS GOLDEN.**  slang was NOT
patched, `results/*.csv` were READ ONLY, **no row was converted**,
`GOLDEN_DEFER` stayed unset, and the four slang-fenced tests were never
dispatched and are spelled nowhere here.

| | |
|---|---|
| base | `41e67d5`, fresh worktrees `/tmp/wt_v143` (patched) + `/tmp/wt_v143pris` (pristine) |
| pristine binary | md5 `312fbd2b8687e0886a0ec1152f503fd1` — **identical to the implementer's** |
| patched binary | md5 `532377c8fd0eb878c622bf805750554e` — **identical to the implementer's** |
| patch | `/tmp/r10uvm143.patch`, md5 `cd7a120dd8582993665086fd15167c55`; `git diff 41e67d5` regenerated from my own worktree is **md5-identical** |
| freezing | both binaries `chmod 555` at immutable paths **before** any sweep; `SLANG_UHDM` exported explicitly per binary; **every** `cmds.txt` audited by binary PATH (1458/1458 u2r and 1523/1523 surelog name my frozen binary; main-tree hits **0**) |

---

## 1. THE BREAK ATTEMPT — 13 arms, 26 views, AWAY-GOLDEN 0

`VARMS.v143.txt` has every scored table.  Every arm is built with Surelog in
BOTH views and with both frozen binaries, and scored by `vscore143.py` on top
of `vcen143.py`.

| arm | the face it breaks | DEF | ELAB |
|---|---|---|---|
| `v143_f_matrix.sv` | **the formal matrix**: defaulted formal FIRST / MIDDLE / LAST / all-three; default = `null` / literal / parameter / function call / concatenation / string; `input` / `output` / `inout` / `ref`; formal of class / enum / struct / string / queue / unpacked-array / dynamic-array type; task vs function; `static`; `virtual` + an override that repeats the default; a constructor `new` with two defaulted arguments; a body local, a class property and a literal; and the deep faces (operation operand, call argument, nested-select index, struct-member index, nested hier_path index) — all with out-of-body and free-package twins | TO-GOLDEN 28, AWAY 0 | TO-GOLDEN 28, AWAY 0 |
| `v143_g_homes.sv` | **the home axis**: free package task/function, out-of-body class task/function, in-body class task/function, a `pure virtual` prototype and the concrete child that implements it, a class NESTED in a class, a class in a MODULE (in-body **and** out-of-body), a class in a PROGRAM, a class in an INTERFACE, an interface task, a module task/function, a GENERATE-BLOCK task ×2 instances, a program task | TO-GOLDEN 7, AWAY 0 | TO-GOLDEN 7, AWAY 0 |
| `v143_h_idx.sv` | **33 index shapes** × in-body/out-of-body twins: literal, `parameter`, `localparam`, property, static property, `this.`, formal, body local, `+` and `(a+b)*2` operations, function call, method call, ternary, concatenation, cast, `$bits`, string literal, string formal, class-handle formal, `this` handle, enum literal, enum formal, struct member, nested select, nested select with an operation, `[7:0]` and `[f +: 4]` part selects, queue `$`, queue index, multi-dim `[f][g]`, a nested hier_path index `h.kid`, a class static `Hkey::s_key`, three uses of one formal, a mixed chain | TO-GOLDEN 16, AWAY 0 | TO-GOLDEN 14, AWAY 0 |
| `v143_i_special.sv` | `foreach` (twice), a `constraint`, a class PROPERTY INITIALISER, a `fork` block, a `while`+`begin` block local, a **DPI import** call as the index, `super.`, a class PARAMETER as the index, extern prototype carrying the default vs not, a `static` in-body method, 2 specializations | TO-GOLDEN 5, AWAY 0 | TO-GOLDEN 5, AWAY 0 |
| `v143_k_leak.sv` | **the flag-leak hunt**: a free subroutine declared AFTER a class, a module subroutine AFTER a class, a NESTED class BETWEEN two in-body methods of its outer class, a class between two module tasks, a generate block after a class | TO-GOLDEN 4, AWAY 0 | TO-GOLDEN 4, AWAY 0 |
| `v143_l_unit.sv` | the **$unit** home (free task, `$unit` class in-body and out-of-body) and the **instance-count axis**: the same module carrying an in-body class method instantiated 1, 2 and 3 deep (six instances) | TO-GOLDEN 2, AWAY 0 | TO-GOLDEN 2, AWAY 0 |
| `v143_m_recv.sv` | **the recursion branches** no other arm reaches: a METHOD CALL as the index (its RECEIVER is on the walk), a system call, `q.size()`, `vec.sum()`, a `var_select` multi-dim element, `+:` and `-:` part-select ranges, a concatenation of two refs, `h.mid() + vec[f]` | TO-GOLDEN 4, AWAY 0 | TO-GOLDEN 4, AWAY 0 |
| `v143_n_owner.sv` | **whose array is it**: the in-body method indexes an array owned by the PACKAGE, by a BASE CLASS, by a STATIC class property, by ANOTHER class's static, by the enclosing MODULE, `super.`, `this.`; three specializations of a parameterized class | TO-GOLDEN 7, AWAY 0 | TO-GOLDEN 7, AWAY 0 |
| `v143_j_refvar.sv` | the `ref_var` cell (`foreach (path.slices[j])`, the `LocalScopeHierPath` shape) | **byte-identical** | **byte-identical** |
| `v143_a_formals.sv`, `v143_a_formals_ch.sv` | the same formal matrix on a `return`-expression body and on struct- vs class-element tables | ALREADY-RIGHT 37 | ALREADY-RIGHT 34 |
| `v143_z_probe.sv` | **which body shape our emitter actually binds** (see §4) | TO-GOLDEN 3, AWAY 0 | TO-GOLDEN 3, AWAY 0 |

The implementer's own `g143_a_shapes.sv` and `g143_b_owners.sv` re-scored on my
census: **TO-GOLDEN 6 / AWAY 0** and **TO-GOLDEN 1 / AWAY 0**, matching their
tables.

## 2. THE INSTRUMENT THE PASS WAS MISSING — a DEPTH-AWARE census

The pass's `score143.py` keys a cell on a `ref_obj` whose **immediate** printed
parent is a `bit_select` under `vpiIndex`.  That key is **blind** to exactly the
cells the emitter's helper walks: an operand of an operation, an argument or
receiver of a call, and the index of a NESTED select all have a different
immediate parent.  So arm C's claim that "golden bares every in-body cell
*including operation operands, call arguments and nested-select indices*" was
not measured by the shipped scorer.

`vcen143.py` walks the WHOLE index subtree of every `hier_path` element and
records a DEPTH with each cell.  **Re-measured, the claim HOLDS**: every
deep cell in `v143_f_matrix` (`f28_op`, `f29_call`, `f30_nested`),
`v143_h_idx` (`h09 h10 h11 h13 h15 h24 h25 h26 h29`) and `v143_m_recv`
(`m07 m09 m10 m11 m12`) is bare in golden inside a class body, bound in golden
out of body, and moves TO-GOLDEN — at depth 1 **and** depth 2.

On the corpus the deeper census is also strictly stronger than the pass's:
SimpleUVM/default reads `AGREE 317 / OURS-OVERBOUND 1 / OURS-UNDERBOUND 0` →
`AGREE 318 / 0 / 0`, one-sided sets `ONLY-GOLDEN 193` / `ONLY-OURS 196`
**unchanged**, and the single overbound cell is
`uvm_pkg::uvm_objection::wait_for::obj` at `915:19`.  (`VCENSUS.v143.txt`.)

## 3. THE BRIEF'S FRAMING — refuted independently

My own `vpiIODecl` listing census on SimpleUVM/default, keyed on the OWNER
subroutine × the ordered tuple of `name:direction:default-value-presence`:
**2,026 subroutine rows on each side, 0 only-golden, 0 only-ours**, pristine
and patched alike.  `uvm_objection::wait_for` carries exactly
`[objt_event:-, obj:-]` on **both** sides — the head is not an `Io_decls`
size mismatch.  The head cell itself, read three ways:

```
golden      \_bit_select: (m_events[obj]) … |vpiIndex: \_ref_obj: (…::obj)      <- no vpiActual
pristine    …                                          |vpiActual: \_io_decl: (obj)
patched     …                                          <- no vpiActual, byte-for-byte golden's shape
```

## 4. WHAT THE PASS DOES NOT SAY, AND I MEASURED

`v143_z_probe.sv` — one in-body class method, eight body shapes, one array:

| body | pristine | golden |
|---|---|---|
| `if (tbl[k].tally == 0) …` (task **and** function) | **bound** | bare |
| handle-keyed `if (ridge[h].tally == 0) …` | **bound** | bare |
| `return tbl[k].tally;` | bare | bare |
| `t = tbl[k].tally;` (task and function) | bare | bare |
| `tbl[k].tally = 3;` (lvalue) | bare | bare |
| `$display(…, tbl[k].gauge)` (call argument) | bare | bare |

Our emitter binds a class-body path-element index only where the `hier_path` is
an OPERAND of an operation; the other five shapes were already golden-correct.
That is why a formal-face grid written with `return …` bodies scores
ALREADY-RIGHT everywhere (`v143_a_formals.sv`, 37 cells, zero movement) and is
**not** a test of the law.  Any future grid on this head must use the operand
shape.

## 5. EVERY GATE, RE-RUN ON MY OWN BUILDS

| gate | measured here |
|---|---|
| goldens | patched **23 PASS / 0 FAIL**, pristine 23/0, `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** |
| uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**, identical pristine and patched; `ct8rows` vs the committed `results/gate_uhdm2rtlil.csv` **PASS**, vs my own pristine tf **PASS**, vs my own pristine def **PASS** |
| surelog `--mode both`, 1,588 rows / 956 DBs | histogram byte-identical pristine vs patched (937 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM); `ct8rows` vs `results/golden_surelog.csv` **PASS** for BOTH binaries and pristine-vs-patched **PASS**; **no row converted**, `results/*.csv` untouched |
| byteverify `SELFCHECK=1` | surelog **MOVERS 9 / 956**, selfcheck 955/956; u2r **MOVERS 0 / 1358**, selfcheck 1357/1358 |
| the nine movers | `SimpleUVM`, `SeqDriver`, `MiniAmiq`, `BuildUVMPkg` × both modes + `Scoreboard`/default — exactly the predicted set; **all nine are `CMP_NOTEQUAL` rows, so no `CMP_EQUAL` row's bytes moved at all**; order-blind (sorted, id-stripped, path-normalised) whole-dump attribution is a **2-line delta** on every one, `\_io_decl: (obj)` and its `|vpiActual:` — Scoreboard/default included, so the coin did not flip |
| heads (`rowheads.sh`) | SimpleUVM def+tf and Scoreboard/def **29 → 62, head CLEARED** (pristine head `LHS:<null>` / `RHS: io_decl (obj)` on `uvm_objection::wait_for`; patched head = `parameter (UVM_STR_CRC_POLYNOMIAL)` under `design (work@top)`); SeqDriver 26, MiniAmiq 26, BuildUVMPkg 55, Earlgrey 110/142, Rggen 0 — **all nine other head logs byte-identical** |
| canaries | `ok=52 changed=0` surelog, `ok=8 changed=0` u2r; `ctcan2` **PASS/PASS**; `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| wide boundary | my own copy of the WHOLE probe tree, subdirectories included: **LISTED = PROCESSED = 4,122**, PRODUCED_DBS 3,976, **RC_DIFFS 0**, MOVED_ARMS 12 |

### The 12 boundary movers, each re-measured against golden

* **5 of mine** (`v143_f_matrix`, `v143_g_homes`, `v143_h_idx`, `v143_i_special`,
  `v143_z_probe`) and **3 of the pass's own** (`g143_a/b/c`) — the positive
  control: a boundary that reports zero over these cannot see.
* `r10svs4repro/g1_thisidx.sv` — **exactly 2 cells**, `pkt.data[k]`'s index at
  33:37 and 39:18; golden leaves both bare (`work@Grid::f::pkt.data[k]::k`, no
  `vpiActual`) — **TO-GOLDEN**.  ELAB cmp log byte-identical.
* `r10buvm7repro/v1_lvincdecshape.sv` — 1 cell TO-GOLDEN (`p7::holder7::f1::index`).
* `r10uvm79repro/c1_nestedidx.sv` — 1 cell TO-GOLDEN, at **depth 2** inside
  `arb_sequence_q[i].sequence_ptr`; § `hpMidSelIdxAtPath79`'s own head cell keeps
  its name, parent and span, only `vpiActual` moves.
* `r10buvm22repro/g22.sv` — **no cell of this law moved.**  Its only delta is
  three garbage numbers (`22498081/22498937 → 22502177/22503033`) in a
  `range` at 72:28 where golden emits `STRING:associative` and we emit an
  `operation` over a constant whose value is derived from a memory address.
  Pre-existing on both binaries, `uhdm-cmp` log **byte-identical in both views**,
  zero corpus reach.  It does mean the emitter reads a layout-dependent value
  there; recorded as R4 below.

## 6. FINDINGS THAT CORRECT THE PASS'S OWN RESIDUES

**F1 — R1 is INSTANCE-dependent, not view-dependent.**  The pass says a
program's path-element index is "bare in the definition view, bound under
`-elabuhdm`".  Measured on `v143_g_homes.sv`, where the program **is
instantiated** (`progG143v u_p();`), golden binds it in the **DEFINITION** view
too: `work@progG143v.gprg_tk.k` = `io_decl` in both views.  The pass's own
`g143_b_owners.sv` uses a **top-level, uninstantiated** program and golden
leaves it bare in the DEF view.  So the axis is `writeInstance` draining the
pool for an *instance*, not the view.  **A future fix for R1 keyed on the view
would regress the instantiated-program case** this arm measures.  (Our emitter
binds in both; the pass gates neither — correct, and its one `STILL-WRONG` cell
is honestly scored.)

**F2 — R2's population is a SHAPE gap, not a SLANG_REJECT accident.**  Every
`-elabuhdm` golden that elaborates a class emits a **second**, elaborated copy
of the class method whose path index **is** bound, beside the bare definition
copy — visible in *all* of my arms (`…::tbl[k].tally::k` = `io_decl` next to
`…::k` = bare).  We do not build those elaborated class copies at all, which is
why the pass has zero reach there.  The four named databases are simply the
only ones where it would collide with a database we emit, and I confirm all four
are non-comparable rows: `CoresSweRV` (SURELOG_FAIL / SLANG_REJECT),
`CoresSweRVMP` (SURELOG_FAIL / SLANG_REJECT), `Opentitan` (SLANG_REJECT ×2),
`IndexPartSelectBind` (SLANG_REJECT ×2).

**F3 — the `ref_var`/`ref_obj` guard is INERT, not load-bearing.**  The pass
says the guard is "the whole of `LocalScopeHierPath/testflags`… without it that
row would have regressed".  I built a third binary from the same patch with the
guard **removed** (`/tmp/wt_v143ng`, md5 `4e01e3d0b3c92dfb99f24792c7738a2b`,
never shipped) and re-ran that test's own source in both views: the databases
are **byte-identical** to the guarded patched binary, and a full
`--mode both` surelog sweep with the no-guard binary is byte-identical to the
patched sweep on every one of the 956 databases (§7).  The reason is visible in
the dump: in the **definition** view golden leaves `j` **bare** too — golden
binds it to a `ref_var` only in the *elaborated* copy, which we do not emit.
The guard costs nothing (patched `OURS-OVERBOUND` is 0 everywhere, so it
suppresses no to-golden move) and is a reasonable fence for the day we do emit
those copies — but the stated justification is not reproducible from the
databases, and the README should say "defensive" rather than "measured".

## 7. THE NO-GUARD CONTROL SWEEP

`SLANG_UHDM=/tmp/v143_bin/ng143.bin`, `--corpus surelog --mode both --jobs 2`,
own `--out`/`--workdir`, `cmds.txt` audited: **surelog --mode both with the NO-GUARD binary: ct8rows vs the PATCHED sweep PASS (every row byte-identical); byteverify SELFCHECK=1 MOVERS **0 / 956**, selfcheck 955/956; cmds.txt audit 1523/1523 name the no-guard binary, main-tree hits 0.  => the ref_var/ref_obj guard changes NOTHING on the whole surelog corpus, and nothing on the LocalScopeHierPath source in either view (databases byte-identical).**

## 8. RESIDUES I ADD

* **R4 — a layout-dependent constant in the associative-array range defect**
  (`r10buvm22repro/g22.sv`, 72:28).  Golden emits `STRING:associative`; we emit
  an `operation` whose constant is a memory-address-derived number that changes
  with the binary layout.  Pre-existing, corpus-unreachable, judge-invisible
  here — but it is the one place where a **null** production edit could still
  move bytes, so any future byte-mover attribution over the probe tree must
  expect it.
* **R5 — our class-body binding is NARROW** (§4): only the operation-operand
  context binds at all.  The other five body shapes are already golden-correct,
  so the law's *site* coverage is complete for what we build — but a future
  emitter change that starts binding `return`/lvalue/call-argument hier_paths
  would silently escape this gate unless the five call sites keep it.
* **R6 — one ELAB in-class cell is not gated.**  `v143_h_idx` ELAB carries a
  single `STILL-WRONG`: `pkH143v::Hin::h08::lv` at `35:43` keeps an `int_var`
  actual in **both** binaries where golden's definition copy is bare.  Same in
  pristine; not a regression, and it is a second-emission path in the
  elaborated view that `inBodyClassMethod88` does not cover.

## 9. FILES

| file | what it is |
|---|---|
| `vcen143.py` | DEPTH-AWARE cell census: every `ref_obj` anywhere under a `hier_path` element's index subtree, keyed (fullname, own loc, depth), never on a span; `V143KEY=tail` re-keys on the name tail for naming-residue families |
| `vscore143.py` | arm scorer over that census: TO-GOLDEN / ALREADY-RIGHT / **AWAY-GOLDEN** / **MOVED-WRONG** / STILL-WRONG / ONLY-GOLDEN / ONLY-OURS |
| `v143_*.sv` | the 12 arms of §1 |
| `VARMS.v143.txt` | every arm × view score, plus the four foreign boundary movers re-scored |
| `VCENSUS.v143.txt` | SimpleUVM/default deep census, pristine and patched |
| `VGATES.v143.txt` | the full gate battery as run here |
| `VBOUNDARY.v143.txt` | the 4,122-arm boundary result and the 12 movers |
