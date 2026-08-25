# r10v133 — adversarial verification of r10uvm133 (§ `bitsCallArgNeverFolds133`)

**VERDICT: ACCEPT AS SHIPPED.** Every headline number reproduced bit for bit
from a rebuild; no pristine-right → patched-wrong cell was found on any legal
SystemVerilog this verifier could write; nothing was fixed, so there is no
`.verified.patch` — the deliverable is `/tmp/r10uvm133.patch` unchanged.

MEASUREMENT ONLY in this directory. golden (Surelog) is ALWAYS LHS; the
official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the only judge.

## 1. What was reproduced, and how independently

Both binaries were rebuilt from source at BASE `f08eee0` in the verifier's own
worktrees and came out **byte-identical to the implementer's**: pristine
`583b10a735e405dcfaeb2f49695d6632` (which is also the main tree's own
`build/slang-uhdm` at `f08eee0`), patched `7f81e89326a6057b6aa31d34a5efcb38`.
Four sweeps were then run from scratch — surelog `--mode both` and uhdm2rtlil
in both modes, for BOTH binaries — with `SLANG_UHDM` exported explicitly per
binary and every one of the 6070 `cmds.txt` files audited by binary PATH.
`VERIFY.r10v133.txt` carries all five gates as run.

The head claim reproduces exactly: `rowheads.sh` over the verifier's own
sweeps gives BuildUVMPkg **60 → 64** in both modes and leaves the other ten
measured row-modes' cmp logs **byte-identical**.

The mover claim reproduces exactly, and was checked one level deeper than the
pass checked it: the three changed subtrees at `82730:10`, `82735:61`,
`82742:61` are **identical to GOLDEN's own**, ids and indentation normalised,
where pristine's were not.

## 2. The decode, re-read from Surelog rather than accepted

`CompileHelper::compileBits` (`CompileExpression.cpp:4663`) folds only through
a TYPESPEC: the `bits == 0` block asks `getTypespec`, and the `Reduce::Yes`
promotion under it needs that typespec non-null and `isFullySpecified`. The
`paComplex_func_call` arm hands `getTypespec` a `hier_path` whose
`hierarchicalSelector` walks members and select suffixes only (a trailing
`method_func_call` is unselectable) or a `basename` that is the SUBROUTINE's
name. Both roads return null for a call.

The pass's claim that the SECOND road cannot rescue it was checked against
UHDM rather than taken on trust: `ExprEval::size` (`templates/ExprEval.cpp:1270`)
has cases for 33 object kinds and **not one of them is `uhdmfunc_call`,
`uhdmmethod_func_call` or `uhdmsys_func_call`** — they all reach
`default: invalidValue = true`, and `invalidValue` vetoes both constant arms at
`:4755`/`:4763`. The decode holds.

**Blast radius of the one added line.** `bitsKeep` is written at seven places
and READ at exactly four, every one of them under `name == "$bits"` — verified
by reading all eleven occurrences in `ExprEmit.cpp`. No sibling query function
can see the new condition, which arm C measures directly. The two later gates
that could switch it back off cannot fire on a call:
`bitsOwnClassPropFold61` needs `selChainRoot95` to reach a `ClassProperty`
(null for a `CallExpression`), and `bitsSelectThenMember95` needs a member
access. `binOpLeftmostSelect27` substitutes only a select-bearing leftmost
operand, so `$bits(f() + 1)` still reaches the pre-existing BinaryOp rule.

## 3. Breaking the law: 8 new arms, 16 views, 30 views scored in total

`v133_a_ctx` param_assign / localparam Rhs, packed and unpacked RANGE BOUNDS,
net-decl-assign, cont-assign, High_conn override, case item, for-loop bound,
replication count, generate-for, task body, scoped package call, nested call,
associative `.size()`/`.num()`, dynamic `.size()`, string `.len()`.
`v133_b_faces` 33 faces in one class: type keyword, typedef, struct typedef,
enum typedef, literal, package parameter, class localparam, plain property,
bit-select, part-select, member access, array element, enum variable, string
variable, CLASS HANDLE, whole queue / assoc / dynamic array, member through a
handle — beside the call faces (struct-returning call, string-returning call,
`e1.name()`, `e1.num()`, `ih.gi133b()`, `ih.iq.size()`, `qa.sum()`).
`v133_c_sibs` the eight sibling query functions over a call IN A MODULE, plus
`$clog2($bits(f()))`, `$bits($clog2(f()))`, `$bits($size(a))`,
`$bits($signed(v))`, `$bits($unsigned(v))`.
`v133_d_iface` interfaces, two parameterisations, THREE instances, calls
through an interface port.
`v133_e_const` constant functions in genuinely constant contexts: localparam,
overridable parameter, packed and unpacked range bounds, a typedef range bound,
replication count, select index, indexed part-select, cast operand, CAST SIZE.
`v133_f_macro` the field-automation macro shape of the corpus head over four
container faces, expanded twice, reached through two class instances.
`v133_g_pkg` the package definition listing vs the top copy, and an
OUT-OF-BLOCK method body.
`v133_h_more` constraint block, covergroup bin, `super.`-qualified call,
virtual method, static method, class-scoped static call, call ARGUMENT,
inside-set element, immediate assertion, case EXPRESSION, loop condition,
return expression, delay control, stream operand.

**Result over all 30 arm-views** (16 verifier + 10 the pass's own + 6 foreign):
`TOGOLD=184  MOVED-WRONG=0  AWAY=0`. Golden coverage rises in every single
view; whole-dump distance to golden falls in every single view; three arm-views
that were CMP_NOTEQUAL become **CMP_EQUAL under the official judge**
(`v133_c_sibs` both views, `v133_f_macro` both views, `v133_h_more` elab).

## 4. The one finding worth naming: the pass's scorer over-reports

`qjoin133.py` scores a site BOTHKEEP as soon as either side has one kept call.
Golden emits a param_assign TWICE — the `uhdmallModules` copy keeps the
`sys_func_call`, the `uhdmtopModules` copy folds it — so a site where we match
only one of the two copies reads as TOGOLD. `v133cen.py` scores the exact pair
(kept, folded) and reports 22 such sites as MOVED-OTHER instead.

**They are wrong-to-wrong, not regressions**, and this was settled by looking at
the objects rather than at the counts: in the top copy golden's folded constant
carries `vpiSize:32` and a `vpiTypespec` → `ref_typespec` → `int_typespec`,
while pristine's carried `vpiSize:64` and no typespec at all. `constant::Compare`
reads both fields, so pristine's top copy was already unequal to golden's. No
copy of any of these cells was ever right, and none became wrong. Corpus
population of the shape is ZERO. It is recorded below as R1.

## 5. What the arms unmasked (pre-existing, now reachable)

`v133_a_ctx`'s head after the patch is golden's `func_call: (mfa133)` against
our `ref_obj: (mfa133())` — a `$bits` argument inside a PACKED RANGE BOUND
emitted as a ref_obj whose NAME is the raw call text. Both dumps carry the
identical `ref_obj` line at `31:16`, pristine and patched alike, so this is a
pre-existing bug the cleared head merely exposes. Recorded as R2.

## 6. Ranked residues (verifier's own ranking)

* **R1 — `$bits(<call>)` in a param_assign Rhs.** Golden KEEPS in the
  `uhdmallModules` copy and FOLDS in the `uhdmtopModules` copy; we now keep
  both (before: folded both). Wrong-to-wrong, 17 cells across the arms, corpus
  population 0. The fold value is the `int` return width with `vpiSize:32` and
  an `int_typespec` ref — which our folded constant never carried either, so
  the fix is TWO facts, not one. `emitParameters(..., bool topView, ...)`
  already has the view flag; no member exposes it to `emitExpr`, which is why
  this is a separate pass and not a widening of this one.
* **R2 — a `$bits` argument in a packed RANGE BOUND emits as a `ref_obj` whose
  name is the raw source text** (`mfa133()`), where golden emits the real
  `func_call` with its `vpiFunction` link. PRE-EXISTING (byte-identical in
  pristine), corpus population 0, and now the visible head of that arm.
* **R3 — `$bits(<literal> | <cast> | <concat>)`**: golden keeps, we fold. The
  pass names this too; the arms confirm the population is 0 in both corpora.
* **R4 — `$bits(<own struct property>.<member>)`**: golden folds, we keep. The
  ONLY AWAY direction anywhere, and PRE-EXISTING (pristine keeps it too).
* **R5 — instrument.** `bound133.sh` diffs dumps it never re-reads for
  byte-stability and so can manufacture a phantom MOVED under load (it did:
  `vg19g.sv/elab`, 2678 lines, over two byte-identical databases). Compare the
  `.uhdm` md5s first.

## 7. R0 — the next head, independently confirmed

`head_pat_default_BuildUVMPkg.cmp` re-measured from the verifier's own patched
sweep: golden `struct_var (uvm_pkg::uvm_reg_map_info::mem_range)` @74749:27-36
against our `bit_var`, with **the same `ref_typespec` whose `vpiActual` is the
same `struct_typespec (uvm_reg_map_addr_range)` on both sides** — so the
typespec binding is already golden's and only the VARIABLE'S CLASS is wrong.
Source: `uvm_reg_map_addr_range mem_range;`, a class property whose written
data type is a struct TYPEDEF NAME. It reproduces outside the corpus in this
pass's own `g133_a_kinds.sv` (`st133_t s_mem;`) in both views. The lead the
implementer names — `compileVariable`'s named-typedef arm against our
declarator-variable class choice — is the right place to start.

## 8. Files here

`v133_[a-h]_*.sv` the eight verifier arms; `v133cen.py` the exact-multiset
census/join; `v133reg.py` the order-blind, cell-free regression detector;
`ARMS.r10v133.txt` every run line and every scored cell; `VERIFY.r10v133.txt`
the five gates as run; `PREDICT.r10v133.txt` the independent a-priori mover
prediction; `BOUNDARY.r10v133.txt` the verifier's own wide boundary and the
attribution of all 31 moved views. The arm runner is the pass's own
`tools/probe/r10uvm133repro/arm133.sh`, used unmodified.
