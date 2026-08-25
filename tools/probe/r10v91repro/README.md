# r10v91 — the ADVERSARIAL VERIFICATION of r10earl91

**VERDICT: ACCEPT AS SHIPPED.** Production unchanged; no verifier fix was
needed. `/tmp/r10earl91.verified.patch` = the implementer's patch plus this
directory.

**MEASUREMENT-ONLY directory.** The official
`~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge. BASE
`c887390`. `results/*.csv` was **READ ONLY** and is untouched — **NO ROW
CONVERTED**. slang was not patched. The four slang-fenced tests were never
dispatched and are not named in any artifact here.

---

## 1. What was reproduced, from the verifier's own worktrees

Two fresh worktrees at `c887390` (`/tmp/wt_v91` patched, `/tmp/wt_v91pris`
pristine), both configured and built by the verifier at `-j 2`, both frozen
`chmod 555` at immutable paths before any sweep, `SLANG_UHDM` exported
explicitly per binary, every `cmds.txt` audited file-by-file **by binary path**.

The pristine binary's md5 came out **`1fe90f78fd44f1a6c8774c47b717095c`** —
**the same md5 the implementer's README states**, so the two agents' builds of
`c887390` are bit-identical and every number below is comparable to theirs.

**Every headline number reproduced bit-for-bit:**

| claim | verifier's measurement |
|---|---|
| goldens 23/0, `/bin/false` 0/23 | 23/0 on BOTH binaries; 0/23 |
| u2r 679/50/2 both modes, 0 differing rows | identical histograms, ct8rows PASS ×4 |
| u2r 0 byte movers / 1358 | `MOVERS: 0 / 1358` |
| surelog 471+466 / 10+9, 0 differing rows over 1588 | 937 CMP_EQUAL / 19 CMP_NOTEQUAL, ct8rows PASS ×3 |
| surelog 2 byte movers / 956, `Earlgrey_0_1` both modes | the same two rows, and the same four 12-hex hashes `43a8d277a6fc` / `02496164d2f6` (pristine) and `b78f6e7ceabb` / `88e7443dcde5` (patched) |
| Earlgrey head 110 → 250 (default) and 142 → 278 (testflags), ONE head each | identical |
| every other named row's head log byte-identical | 10 / 10 logs `cmp` identical |
| `grep -c 56:24` = 24 before, 0 after | identical |
| `HEAD_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | all four **byte-identical** to the implementer's committed logs |
| canaries ok=52 / ok=8, ctcan2 ×2 PASS, canaudit 29/0/0 | identical |
| 5 protected DBs SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | identical |
| A/B gate: `R10E91_OFF=1` reproduces the pristine DB byte-for-byte | reproduced INDEPENDENTLY in the design's own directory, **both modes** |
| wide boundary 12 differing cells, rc histogram symmetric | reproduced (see §4) |

Full battery: `GATES.r10v91.txt`.

---

## 2. Breaking the law: seven adversarial arms

`ARMS.r10v91.txt` (scores) — built with Surelog (`-parse -nobuiltin -nocache
-d uhdm`) and with BOTH frozen binaries, censused with `ct91pat --inst`, scored
as MULTISETS three ways by `score3_91.py`; every child `</dev/null`, every rc
recorded; each arm additionally built in the `--elabuhdm` view.

| arm | what it attacks | KEYS | WRONG→RIGHT | **RIGHT→WRONG** | **AWAY** |
|---|---|---:|---:|---:|---:|
| `v1_ports91.sv` | **port `High_conn` patterns onto unpacked-array ports** (inline / typedef'd / 1-element / scalar-element / 2-D nested / array-of-packed-struct) + **net-decl-assign** patterns | 56 | 1 | **0** | **0** |
| `v2_targets91.sv` | **23 target declarations**: parameterised count, descending / ascending explicit range, typedef'd element, enum / packed-union / packed-struct / packed-array element, 2-D, parameterised width, signed, 1-bit, `int`, **typedef'd unpacked array**, an **unpacked SLICE** target, a 2-D **element** target, an interface member, 1 / 2 / 3 elements, operand wider and narrower than the element, a **replicated** pattern, a **default-keyed** pattern, a **conditional-op** RHS with two pattern arms | 106 | 16 | **0** | **0** |
| `v3_homes91.sv` | **homes × instances × hier_path faces**: nested packed-struct member, unpacked-array-of-struct element member, interface signal, interface struct member, the same path inside an operation / a concat / a cast; module, gen-for (3 instances), gen-if, a 3-deep chain, three `leaf3` specialisations | 190 | 64 | **0** | **0** |
| `v4_bind91.sv` | a **bind** instance, `always_comb`, `initial`, a var-decl initialiser, a **localparam** unpacked-array pattern, a **function-argument** pattern, a **cast to a typedef'd unpacked array**, an unsized-decimal operand 0, a sized-literal operand 0 | 32 | 2 | **0** | **0** |
| `v5_spell91.sv` | **exotic spellings**: an unpacked-struct member target, a **typedef of a typedef**, a **`parameter type` target**, a package typedef, an **output-port target** (inline and typedef'd), an unpacked array of an unpacked struct, a typedef'd element with a packed dim, replication, an operand 0 wider than a 4-bit element | 32 | 2 | **0** | **0** |
| `v6_faces91.sv` | **modport member** as operand 0, a modport struct member, a target reached **through a modport**, a cont_assign **inside an interface** (inline and typedef'd), a **package-parameter MEMBER** (`p6::PS.a`) as operand 0, a plain package parameter, a nested member in a 3-element pattern, a **wire (net) array** target, a 3-deep chain read, 3 instances at two widths | 60 | 9 | **0** | **0** |
| `v7_spell2.sv` | an inline dim over a **typedef'd unpacked-array element**, a **typedef chain**, a typedef'd scalar element, operand 0 that must **truncate** (20→12) and **extend** (12→20), a 1-bit target, a 32-bit `int` target, a **signed** target, a 2-level inline unpacked array | 28 | 6 | **0** | **0** |

**`RIGHT→WRONG` 0 and `AWAY-GOLDEN` 0 on all seven; 100 cells moved, every one
onto golden's payload.** Official `uhdm-cmp` on the five arms that build a
comparable database: cmp lines fall on every one (16278→16276, 24034→24000,
63044→62898, 10600→10598, 12018→12012), one head before and after.

### The fence that mattered most, measured seven independent ways

The predicate is the **spelling** — `expr.type->kind`, NOT the canonical kind —
so a typedef'd unpacked array must keep the stamp. Golden sizes operand 0 at
the element width, and the patch keeps it, for **every** alias spelling tested:

| spelling | golden | pristine | patched |
|---|---|---|---|
| `wa_t t14;` (`typedef logic [11:0] wa_t [2]`) | 12 | 12 | **12 KEPT** |
| `p5::wb_t b1;` (**typedef of a typedef**) | 12 | 12 | **12 KEPT** |
| `T c1;` with `parameter type T = p5::wa_t` | 12 | 12 | **12 KEPT** |
| `p5::pa_t d1;` (package-qualified) | 12 | 12 | **12 KEPT** |
| `output p5::wa_t po` (a **port** target) | 12 | 12 | **12 KEPT** |
| `p4::wa_t'('{…})` (a **cast** target) | 12 | 12 | **12 KEPT** |
| `p7::wb_t a2;` (chain, second file) | 12 | 12 | **12 KEPT** |

and it is withheld — matching golden's *no size* — on every inline spelling in
the same files.

### The two producers the law could have reached but does not

* **`High_conn` assignment patterns** (`ModuleEmit` sets `reemitting` around
  them). Measured on `v1_ports91`: the site withholds nothing there because we
  never stamped there — for all six port shapes, golden's ELAB copy carries a
  size (1 for the inline unpacked-array ports, 12 for the typedef'd one, 8 for
  the packed-struct one) and **both** binaries carry `SZ=0`. Pre-existing,
  unchanged, and ranked R6 below.
* **net-decl-assign with a nested pattern** (`ModuleEmit:20135`). Measured on
  `v1_ports91` lines 61–63: golden and both binaries agree at `SZ=0` before and
  after.

---

## 3. The Surelog decode, checked against the source

`CompileHelper::adjustOpSize` (`CompileHelper.cpp:4944-5035`) does write
`cop->VpiSize(ncsize)` unconditionally in the struct, logic and `else` branches
and **only** inside `if (const ref_typespec* ert = atps->Elem_typespec())` in
the `uhdmarray_typespec` branch — the implementer's citation is exact. Two
things the write-up leaves implicit and the verifier confirms:

* `adjustOpSize` chooses its branch on `rhs->Typespec()->Actual_typespec()`
  **falling back to** the target `tps`, not on the target alone. That is why the
  emitter-side predicate has to be the assignment target's *slang* type: the
  arms above show the two agree on every shape measured, including a cast and a
  `parameter type`.
* `expandPatternAssignment` recurses through `vpiConditionOp`
  (`CompileHelper.cpp:5070-5075`), so a `cond ? '{…} : '{…}` RHS gets the same
  treatment on both arms. `v2_targets91` `t23` measures it: golden leaves both
  arms' operand 0 bare, pristine sized both at 12, patched matches golden on
  both.

---

## 4. The wide boundary, run independently

`vbd91.sh`, three shards, disjoint stage dirs, list on **fd 3**, children
`</dev/null`, `PROCESSED` asserted, rc recorded per cell, **0 key collisions**
over the list.

```
LISTED = PROCESSED = 4104     (4099 committed probe sources + this dir's arms)
identical 7835   DIFFERING 23   no_output 350
rc histogram SYMMETRIC side for side:
   A rc=0 7523   A rc=139 14   A rc=3 336   A rc=4 335
   B rc=0 7523   B rc=139 14   B rc=3 336   B rc=4 335
```

23 = **12** (the implementer's set, reproduced exactly — `BOUNDARY_WIDE.v91.diff`)
+ **10** (this dir's own arms in both views, the positive control that the gate
can see a moved cell) + **1 the implementer's run did not report**.

### The 13th cell — convicted NOT this law, three ways

`plain r10vrgg3repro/xi_iface_param_type/dut.sv`, a single `|vpiSigned:1` line
on an interface-array instance's un-named `parameter` object.

1. `R10E91_CELLDBG=1` shows **0 cells reach the law's site** for that file, in
   both views.
2. It is a **coin, not code layout**: in isolation both binaries print 14
   occurrences, 12/12 runs each; under parallel load the count flips to 13 on
   **both** sides — 150 runs each at `-P 12` gave **pristine count13=1**,
   patched count13=0 (an earlier 24-run burst had caught the patched side).
3. It is invisible to the corpus judge; the whole-corpus byte gate finds 2
   movers and the A/B gate accounts for 100 % of both.

Contrast `r10buvm22repro/g22.sv`, which the implementer called layout and is:
`R10E91_OFF=1` still prints the **patched** hash `acdd87b39337` (identical to
law-ON) while pristine prints `88ff597a5ebf`; 0 cells reach the site; the whole
diff is a garbage `UINT` literal `22498969` vs `22498937` — a delta of 32, an
address artifact — and both sides exit `rc=4` with no comparable database. That
is r10earl84's R5, reproduced.

`r10earl61repro/v4_v61.sv` re-scored against a **fresh** Surelog golden:
`t61_t ua [1:0]; assign ua = '{'{…},'{…}}` is an inline unpacked array of packed
structs; the one moved cell goes `SZ=12 → SZ=0`, which is golden's;
`RIGHT→WRONG 0`, `AWAY 0`. Its residual difference is a pre-existing typespec
the operand carries and golden's does not.

Details: `COIN.xi_iface_param_type.txt`.

---

## 5. The census, re-derived on the two mover databases

Whole-database raw row diff of `ct91pat` output, pristine vs patched:

```
default    4 differing rows      testflags   8 differing rows
```

and **every one of them** is `hier_path … SZ=12 → SZ=0` at
`rv_timer.sv:56:22-56:47` or `SZ=8 → SZ=0` at `57:22-57:43`. `SZ=0` is golden's
value in every case. **Nothing else in either database moved.** The `ct91cen`
3-way score agrees: `WRONG→RIGHT 4`, `RIGHT→WRONG 0`, `AWAY 0`, `STILL-WRONG 0`
(the testflags copies are 3-vs-2 by count, a PRE-EXISTING elab-copy defect, and
all three carry golden's payload).

A post-patch scan of the same census by context shows how close the sizing
family now is to closed in `Earlgrey_0_1`:

| context | shared keys | OURS-SIZES-GOLDEN-DOESN'T | GOLDEN-SIZES-WE-DON'T |
|---|---:|---:|---:|
| `CTX=PORT` | 32 | 0 | 0 |
| `CTX=CONTASSIGN` (default) | 252 | **0** | **2** |
| `CTX=CONTASSIGN` (testflags) | 253 | **1** | **1** |
| `CTX=OTHER` | 111 | 0 | 0 |

Those three remaining cells are named in §6.

---

## 6. Ranked residues (verifier's own, measured)

* **R1 — the STRUCT-target operand size** (the implementer's R1, confirmed and
  localised). `rv_timer.sv:211:24-223:4`, `POP=75 NOPS=10 IDX=0
  PTS=struct_typespec`: golden gives operand 0 (`arb_valid`) `SZ=1`, ours `SZ=0`,
  13 copies. `adjustOpSize`'s `uhdmstruct_typespec` branch sizes per MEMBER.
* **R2 — the elaborated conditional-op fold (the implementer's R0, verified
  verbatim).** `hw/ip/aes/rtl/aes_key_expand.sv:109`,
  `assign spec_in_192 = AES192Enable ? key_i[5]^key_i[1]^key_i[0] : '0;` with
  `parameter bit AES192Enable = 1`. The patched head is LHS `operation
  109:39-109:69 vpiOpType:30` (the XOR), RHS `operation 109:24-109:74
  vpiOpType:32` (the whole ternary) — golden folds the elaborated
  `vpiConditionOp` to its selected arm and we keep it. ONE head in each mode;
  the two modes differ only in the parent (`operation` in default, `cont_assign`
  in testflags).
* **R3 — the unrolled-generate hier_path** (testflags only).
  `108:26-119:6`, `POP=75 NOPS=10 IDX=0`: golden holds
  `tl_h_i[0].a_valid` / `[1]` / `[2]` with `SZ=0` and an `array_typespec`;
  we hold 58 copies of `tl_h_i[i].a_valid` with `SZ=1` and no typespec — the
  genvar is not folded. This is the gen-scope hier_path cluster.
* **R4 — the folded all-ones concat operand.** `176:42-176:84`, `POP=33`
  (concat) `NOPS=4`: golden replaces 32 (default) / 64 (testflags) of the
  operands with one folded `32'b111…1` constant carrying an `int_typespec`; we
  keep the `MioPeriphHasSleepMode` ref_obj in all of them.
* **R5 — duplicate elaborated copies of one pattern.** Measured on
  `v3_homes91` / `v5_spell91` / the Earlgrey testflags census: golden holds one
  elaborated copy of a pattern where we hold two or three. Pre-existing;
  every one of our copies now carries golden's payload.
* **R6 — `High_conn` pattern operand 0 is never sized by us.** Measured on
  `v1_ports91`: golden's ELAB copy sizes operand 0 (1 / 12 / 8 for the six port
  shapes) and both binaries leave it bare. **No `Earlgrey_0_1` witness** (the
  `CTX=PORT` scan above is 0/0), so this is arm-only for now — a candidate once
  a corpus row exercises it.
* **R7 — the `vpiSigned` coin on an interface-array `parameter type` object.**
  `COIN.xi_iface_param_type.txt`; ~1/150 on **either** binary under load.
  Pre-existing, unreachable by this law, but it makes any wide boundary that
  includes `r10vrgg3repro/xi_iface_param_type/dut.sv` intermittently report one
  extra cell — worth knowing before a future pass reads it as a regression.

---

## 7. Files

| | |
|---|---|
| `v1…v7*.sv` | the seven adversarial arms |
| `varm.sh` | the arm runner (Surelog golden + both frozen binaries + both views, rc recorded, children `</dev/null`) |
| `vbd91.sh` | the verifier's own wide boundary (fd 3, PROCESSED asserted) |
| `ct91pat.cpp` / `ct91cen.cpp` / `score3_91.py` | the censuses and the 3-way multiset scorer (copied from the pass, unmodified) |
| `ARMS.r10v91.txt` | every arm's full score |
| `GATES.r10v91.txt` | the full gate battery, ten sections |
| `BOUNDARY_WIDE.v91.{diff,tally}` | the boundary result |
| `COIN.xi_iface_param_type.txt` | the 13th-cell conviction |
| `HEAD_v91_{BEFORE,AFTER}_Earlgrey_{default,testflags}.cmp` | the verifier's own head logs (byte-identical to the pass's) |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` `byteverify.sh` `rowheads.sh` | the gate scripts as run here |
