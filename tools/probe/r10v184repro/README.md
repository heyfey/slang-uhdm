# r10v184 — ADVERSARIAL VERIFICATION of r10uvm184 (§ `cloneBuiltinMethodArgBindsReceiver184`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduces bit-for-bit on independently built binaries. One face the pass never
tested is a **pristine-RIGHT → patched-WRONG** cell on legal SystemVerilog; it
is fixed here as § `retNameArgKeepsReturnVar184v`, the full battery is re-run on
the fixed binary, and the fix is **corpus-invisible** (the four moved databases
are byte-identical to the un-fixed patch's).

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` and `scripts/verify_golden.py` are the authorities. slang was **NOT**
patched; `results/*.csv` were **READ ONLY**; **no corpus row converted**;
`GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never dispatched
and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `b71d5feb` |
| pristine binary | md5 `bc09e77cf8fd251285c06f6f0b54a5bc` — **the implementer's own pristine md5, reproduced from an independent worktree** |
| patched binary (implementer's patch, unmodified) | md5 `554e02b892d0377e734bc253c20181d6` — **the implementer's own patched md5, reproduced** |
| fixed binary (this verification's deliverable) | md5 `b960b23e0207385ad7807aa83d9007a9` |
| verifier surface | `src/ExprEmit.cpp` (the one recording site, one added skip) + `tools/probe/r10v184repro/` |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Built both binaries from scratch in fresh `b71d5feb` worktrees, froze them
`chmod 555`, exported `SLANG_UHDM` explicitly per binary and audited every
`cmds.txt` by binary PATH.

| claim | reproduced |
|---|---|
| pristine / patched binary md5 | **identical to the report's two md5s** |
| goldens | 23/0 on both binaries; `/bin/false` 0/23 |
| u2r, both modes, both binaries | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** |
| surelog histogram, both binaries | **937 / 567 / 48 / 19 / 10 / 3 / 2 / 1 / 1** — identical |
| `ct8rows` | PASS vs the committed `results/golden_surelog.csv`, vs the committed `results/gate_uhdm2rtlil.csv`, and vs this verification's OWN pristine sweep, status AND dump column, both corpora, both modes |
| `cmds.txt` audit | surelog **1523 / 1573** and u2r **1458 / 1462** name the frozen binary; **zero** name the main-tree or any worktree build |
| byteverify | surelog **MOVERS 4 / 956** (SELFCHECK 955/956); u2r **0 / 1358** |
| a-priori prediction (`predict184.sh` on this verification's own pristine sweep) | `LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4`, cells=12 each — **the mover set equals the predicted set** |
| the head | SeqDriver ×2 / MiniAmiq ×2 **29 → 31, one head**; the head OBJECT changes from `string_var (uvm_pkg::uvm_table_printer::emit::dash) @1040:17` to `int_var (uvm_pkg::uvm_packer::get_bytes::sz) @485:7` — the head CLEARED, R0 confirmed |
| mover attribution, order-blind | 46/46 plain and sorted, **44 content lines** each: 20 `<`, 24 `>` (two of them the head's new `|vpiActual:` markers); every line a `vpiActual` target |
| Scoreboard/default | **not a mover on this run** (the coin sat out here too) |
| arm A | **TOWARD 12 / AWAY 0 / MOVED-WRONG 0**, both views |
| arm B | **TOWARD 1 / AWAY 0 / MOVED-WRONG 0**, both views |
| `r10uvm171repro/g171_a_pos.sv` | rebuilt against its own real Surelog golden: **TOWARD 2 / AWAY 0 / MOVED-WRONG 0**, `uhdm-cmp` rc=0 on BOTH binaries |
| wide boundary (a copy of the whole `tools/probe` tree) | `LISTED=5022 FENCED_SKIPPED=0 PROCESSED=5022 MOVED=6 PROCESSED-ASSERT-OK` — exactly this pass's two arms (4) plus `g171_a_pos.sv` (2); every § 139 / uvm180-183 / uvm89 / buvm3-15 / sd8-12 arm byte-identical |
| canaries / ctcan2 / canaudit | ok=52 changed=0, ok=8 changed=0, PASS ×2, `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |

The corpus census was re-scored at a **finer granularity than the pass used**
(see §4): on the real SeqDriver/default and MiniAmiq/testflags rows,
**TOWARD 11 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**, calibrated
golden-vs-golden-vs-golden at every column 0 first.

---

## 2. BREAKING THE LAW — the faces the pass never tested

Five new arms, each one real Surelog golden, both views, scored on object
IDENTITY. `gv184_e` is byte-identical between binaries; the rest are named
below.

### Arm C (`gv184_c_argdecl.sv`) — the ARGUMENT-DECLARATION axis. TOWARD 21 / AWAY 0 / MOVED-WRONG 0, both views.

Golden binds the receiver, and the patch matches, for **every** one of: a STATIC
function-level local (initialized AND bare), an AUTOMATIC local, a package
PARAMETER, a package LOCALPARAM, a package VARIABLE, a NAMED-begin local, a
NAMED-begin STATIC, a NESTED bare-begin local, a for-header ITERATOR, a foreach
INDEX, a FORMAL, a class PROPERTY, two names in one call — inside a FUNCTION, a
TASK and an out-of-body CLASS METHOD alike. The whole-dump order-blind diff of
the arm changes only `vpiActual` targets; not one listing line moves.

The single STILL-WRONG is R3 (the class listing's class-property argument),
identical in both binaries.

### Arm D (`gv184_d_recvmeth.sv`) — the RECEIVER-KIND and METHOD-KIND axes. TOWARD 4 / AWAY 0 / MOVED-WRONG 0, both views.

Two findings worth carrying forward:

* **The string-type gate alone is NOT what fences the array family — the
  recorder's RECEIVER-KIND filter is, and it is undocumented as a fence.**
  `skein[0].substr(1,gauge)` over `string skein[3]` has a receiver whose slang
  type IS a string, so `stripImplicitConv(*recv).type->isString()` is TRUE and
  the site's own gate passes. Golden's answer there is the R2 shape — a
  `string_var` NAMED AFTER THE ARGUMENT spanned at the ARRAY's declaration
  (`string_var(gauge)@35:19`), not the receiver. What actually stops the wrong
  bind is `noteCloneMfcArgRecv184`'s `recvRef->UhdmType()` test: the receiver
  element is a `bit_select`, not a `ref_obj`/`ref_var`, so nothing is recorded.
  Measured identically for a string QUEUE element (`hank[0]`). Correct as
  shipped; the law's write-up should name this filter as a fence.
* A string CLASS-PROPERTY receiver reached through a handle
  (`frame.m_twine.substr(1,gauge)`) leaves the receiver BARE on both sides, and
  the drain's `if (!act) continue;` is what makes golden and ours agree.

`compare(other)` (the argument is itself a string) and `getc` at arg0 both take
the receiver in golden and in ours. A USER-DEFINED method call
(`frame.gird305(gauge)`) already read SAME-AS-RECEIVER on the pristine binary
and is untouched.

### Arm E (`gv184_e_listing.sv`) — § 139's LISTING faces. BYTE-IDENTICAL, both views.

The brief's original framing was a LISTING miss, so this arm holds every listing
face it names — STATIC vs AUTOMATIC, INITIALIZED vs BARE statics, int / string /
class HANDLE / UNPACKED ARRAY / packed STRUCT, FUNCTION-level vs NAMED-begin vs
NESTED-begin, a static in a TASK vs a FUNCTION vs an out-of-body class method vs
an in-body one, multiple statics in one begin in declaration ORDER, and the HOME
listing vs a WILDCARD clone vs an EXPLICIT-import clone. The pristine and
patched databases are **byte-identical in both views**: the LISTING law does not
move underneath the BINDING law.

### Arm F (`gv184_f_stmtpos.sv`) — STATEMENT vs EXPRESSION position. TOWARD 5 / AWAY 0 / MOVED-WRONG 0, and golden and ours agree on all twelve cells.

**The shipped law statement is broader than golden's truth; the CODE is right.**
Golden binds the argument to its OWN declaration, not the receiver, for every
built-in string method call in STATEMENT position — `putc`, `itoa`, `bintoa`,
`hextoa`, `octtoa`, `realtoa`, and also `void'(batten.getc(dowel))`, which is a
NON-void method in a cast at statement level. It binds the RECEIVER in every
value-consuming EXPRESSION position: a plain assignment, an `if` CONDITION, a
`case` SELECTOR and an actual of `$sformatf`. The patch fires in exactly the
second set, because its only site is `emitExpr`'s hier_path arm — so the
implementation coincides with golden on an axis the README does not mention.
A future pass that extends this law to the statement arm on the strength of the
README's wording would regress seven arm cells.

### Arms G / H / I (`gv184_g_retname.sv`, `gv184_h_retpin.sv`, `gv184_i_minimal.sv`) — THE REGRESSION.

`gv184_i_minimal.sv` is the minimal reproducer: one free package function, one
wildcard importer, one call.

```systemverilog
function automatic int ogee705(input int fml_o);
  string bead;  bead = "beadmould";  ogee705 = 2;
  ogee705 = bead.getc(ogee705);      // the return name as the ARGUMENT
  return ogee705 + fml_o;
endfunction
```

| | the clone's binding for `ogee705` as arg0 |
|---|---|
| GOLDEN | `int_var()@6:22` — § 171's RETURN VARIABLE |
| PRISTINE | `int_var()@6:22` — **right** |
| PATCHED | `string_var(bead)@7:12` — the receiver, **wrong** |

`gv184_h_retpin.sv` pins the discriminator on one golden, one row per face:

| face, in the wildcard clone | golden's answer for the RETURN-NAME argument |
|---|---|
| free function, `automatic` | the RETURN VARIABLE |
| free function, static | the RETURN VARIABLE |
| free function, return name never assigned | the RETURN VARIABLE |
| class method, OUT OF BODY | **the RECEIVER** |
| class method, IN BODY | **the RECEIVER** |
| any other argument (control) | the RECEIVER |

The cause is the drain's own design: it runs **dead last**, after § 171's, so
for a free subroutine it overwrites the very binding § 171 just made and golden
wants. In a class method's clone the same spelling is BARE on the pristine
binary — nothing claimed it — which is why keeping those cells in the pool earns
arm G's and arm H's TOWARDs.

---

## 3. THE FIX — § `retNameArgKeepsReturnVar184v`

One site, in the same `src/ExprEmit.cpp` block the pass already touches: the
built-in method arm's argument loop remembers the objects emitted for an
argument that is the enclosing subroutine's own return name **in a non-class
subroutine** (`funcRetSym && !curSubClassScope9` over the argument's own
`NamedValueExpression`), and the recorder skips exactly those. Nothing else
changes; the pool, the drain, the string gate and the clone gate are the
implementer's, untouched.

| | before the fix | after |
|---|---|---|
| arm I (minimal) | AWAY 1, both views | **AWAY 0; the arm is byte-identical to pristine** |
| arm G | AWAY 1, TOWARD 4 | **AWAY 0, TOWARD 4** |
| arm H | 3 AWAY faces per clone copy | **TOWARD 3 / AWAY 0**, and the arm goes `uhdm-cmp` rc=255 → **rc=0** in both views |
| arms A / B / C / D / E / F, the 171 arm | 12 / 1 / 21 / 4 / identical / 5 / 2 | **unchanged, every one** |

### The full battery on the fixed binary (md5 `b960b23e0207385ad7807aa83d9007a9`)

* goldens **23 / 0**; `/bin/false` **0 / 23**.
* u2r both modes **679 / 50 / 2**; `ct8rows` PASS vs the committed baseline and
  vs own pristine; byteverify **0 / 1358**.
* surelog **937/567/48/19/10/3/2/1/1**, identical to pristine; `ct8rows`
  **0 differing rows over 1588** against the committed `results/golden_surelog.csv`,
  against own pristine AND against the un-fixed patched sweep, status AND dump
  column. **NO ROW CONVERTED.**
* byteverify surelog **MOVERS 4 / 956** — the same four, the same md5s — and
  **MOVERS 0 / 956 against the UN-FIXED patched sweep**: the fix is
  corpus-invisible.
* heads: SeqDriver ×2 / MiniAmiq ×2 **31, one head**, R0 unchanged; every other
  named row unchanged.
* attribution: 46/46 plain and order-blind, **44 content lines** per mover,
  every one a `vpiActual` target.
* corpus census, identity granularity: **TOWARD 11 / AWAY 0 / MOVED-WRONG 0 /
  ONLY-OURS-MOVED 0** on SeqDriver/default and MiniAmiq/testflags.
* wide boundary over a copy of the whole `tools/probe` tree:
  `LISTED=5026 FENCED_SKIPPED=0 PROCESSED=5026 MOVED=16 PROCESSED-ASSERT-OK`,
  no `ASYMMETRIC_OUTPUT`. The sixteen are the pass's two arms (4), the 171 arm
  (2), and this verification's five moving arms (10: C, D, F, G, H). `gv184_e`
  and `gv184_i` do NOT move. Every § 139 / uvm180-183 / uvm89 / buvm3-15 /
  sd8-12 arm is byte-identical.
* canaries ok=52/8 changed=0; ctcan2 PASS ×2; canaudit
  `audited=29 UNCOVERED=0 FENCE-BREACH=0`; all protected databases SAME,
  SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`.

---

## 4. A MEASUREMENT NOTE ON `score184.py`

The pass's own scorer takes the value of a key to be a THREE-VALUED verdict
(`BARE` / `OTHER` / `SAME-AS-RECEIVER`), so two DIFFERENT non-receiver bindings
both read `OTHER` and a move between two wrong objects is invisible to it — arm
B's array cells and arm D's `skein[0]` cells are exactly that shape. It happens
not to matter for this law, whose every move is TO the receiver and therefore
always changes the verdict; but the blind spot is real. `scorev184id.py` here is
the same join keyed on the ACTUAL's own face (`kind(name)@line:col`), and every
census and grid above was scored with it as well as with the pass's scorer.

---

## 5. RESIDUES (ranked)

1. **R2 widens.** The array-receiver family the pass fences out is not
   `int`-only: a STRING array or queue element receiver takes the same shape
   (`string_var` named after the ARGUMENT at the ARRAY's declaration span, arm
   D cells D3/D4). Four corpus cells (`visited.exists(succ)`) plus two arm-B and
   two arm-D cells; verified byte-identical pristine vs patched vs fixed.
2. **The statement-position family.** Golden's answer for a built-in string
   method call in statement position is the argument's own declaration; the law
   as WRITTEN claims the receiver there. Seven arm-F cells; corpus incidence not
   surveyed. Record the boundary before anyone extends the law.
3. **The receiver-kind filter is a fence, not a formality.** The write-up should
   say so: without `recvRef->UhdmType() ∈ {ref_obj, ref_var}` the string gate
   alone would move arm D's D3/D4 cells the wrong way.
4. **`iterArg9` is a latent coupling.** It is pushed into `margs` before the
   recorder loop, so it is inside the law's reach; only the string gate keeps it
   out (a `with` clause cannot appear on a string method). Anyone loosening the
   string gate must re-fence it.
5. **R0 stands**: `int_var (uvm_pkg::uvm_packer::get_bytes::sz) @485:7`,
   SeqDriver ×2 and MiniAmiq ×2, 31 lines, one head — a `new` method call's
   argument in the clone listing, the same family one method on.
6. **R1 / R3 / R4 stand** as the pass states them: the explicit-import copy
   (arm A's six `Fillet184` cells, corpus incidence zero), the class listing's
   class-property argument (arm A, arm C's C21 home cell, arm G's `m_rise`), and
   the `arg-1` receiver-prefix family.
7. **Arm G's elab head.** With and without the fix the arm's elab cmp goes 29 →
   2670 lines because the head object changes from a `RHS: <null>` singular on
   `string_var(arch)` to a both-sides `module_inst work@top505` compare — a new
   head, not a bigger one. The arm's own census reads TOWARD 4 / AWAY 0 /
   MOVED-WRONG 0 and arm H, which holds the same faces, goes rc=255 → rc=0. No
   corpus row holds arm G's shape. Worth a ladder reading if the family is
   pursued.

---

## 6. REPRODUCING

```sh
g++ -O2 -std=c++17 ../r10uvm184repro/ct184mfc.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184mfc

# one arm, one real Surelog golden, both views, both binaries
CT184MFC=./ct184mfc ./gridv184.sh gv184_c_argdecl.sv <pris.bin> <fix.bin> <workdir>
python3 scorev184id.py <wd>/mfc.g.<view>.txt <wd>/mfc.a.<view>.txt <wd>/mfc.b.<view>.txt

# the regression, minimal
CT184MFC=./ct184mfc ./gridv184.sh gv184_i_minimal.sv <pris.bin> <patched.bin> <wd>   # AWAY 1
CT184MFC=./ct184mfc ./gridv184.sh gv184_i_minimal.sv <pris.bin> <fixed.bin>   <wd>   # AWAY 0, byte-identical

# the same gates the pass runs, against the FIXED binary
PRI=<pris.bin> PAT=<fix.bin> ROOT=<copy of tools/probe> BWD=<bwd> ../r10uvm184repro/bound184.sh
SELFCHECK=1 ../r10oth4repro/byteverify.sh <fixed wd> <pristine wd>
../r10oth8repro/ct8rows.sh <baseline.csv> <fresh.csv>
```

Arm E and arm I must read BYTE-IDENTICAL between the pristine and the fixed
binary in both views; arms A, B, C, D, F, G, H must read AWAY 0 and
MOVED-WRONG 0 in both views at identity granularity.
