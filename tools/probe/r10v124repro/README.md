# r10v124 — ADVERSARIAL VERIFICATION of r10uvm124 § `selRecvStmtCallBareNames124`

**VERDICT: ACCEPT AS SHIPPED.** Every headline number reproduced bit-for-bit
from the verifier's own worktrees, own builds, own sweeps and own instruments.
The law was attacked over **twelve fresh arms / twenty-six arm-views** built
from receiver shapes, methods, homes, chains, collisions and multiplicities the
pass's own grids do not carry — **0 MOVED-WRONG**, and a multiset line audit
shows the patch **never removes a line golden holds** (BAD_REMOVED = 0 on every
arm-view and on every one of the seven corpus movers).

**MEASUREMENT ONLY.** Nothing here is an acceptance judge. The official
`uhdm-cmp` and `scripts/verify_golden.py` are the authorities. slang was NOT
patched; `results/*.csv` were READ ONLY; nothing promoted; **NO CORPUS ROW
CONVERTED**; `GOLDEN_DEFER` never set; the four slang-fenced tests never
dispatched and never spelled.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `5254f43` |
| worktrees | `/tmp/wt_v124` (patched), `/tmp/wt_v124pris` (pristine) — both fresh |
| binaries | pristine `65ae4ed26a877930f736e85ea10b5a82`, patched `f33032c3b6032765606711e5beae987e` (BOTH built here) |
| gates | `GATES.r10v124.txt` — all green |

## 1. The decode, re-read at the source (not carried forward)

* **The failing field.** `ref_obj::Compare`
  (`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:122`) runs
  `basetype_t::Compare`, then **`VpiName`**. The pristine head log
  (`head_pris_default_SeqDriver.v124.cmp`, 28 lines, one `^LHS:`) shows golden's
  `m_inst_override_queues` spanned 919:13-919:35 against our
  `m_inst_override_queues[obj]` spanned 919:13-919:40. Confirmed.
* **Surelog's rule.** `CompileHelper::compileTfCall`, user-call arm,
  `~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:4216-4241` — read in
  full. `name = fC->SymName(dollar_or_string)`; if the sibling is a
  `paConstant_bit_select`, `tfNameNode = fC->Sibling(Constant_bit_select)`
  **steps over the subscript**; `fcall->VpiName(SymName(tfNameNode))` and
  `prefix->VpiName(name)`, each spanned by `populateCoreMembers` of its own
  NAME NODE. The subscript is never read into either name. The write-up is
  verbatim correct.
* **The corpus site.** `uvm-1.2/src/base/uvm_factory.svh:919` is
  `m_inst_override_queues[obj].queue.push_back(m_wildcard_inst_overrides[i]);`
  — i.e. the DEEP shape (`A[i].B.method(...)`), which is why the call name
  `queue` was already right and only the prefix moved.

## 2. What the verifier attacked (`v124_*.sv`, 26 arm-views, DEF and ELAB)

Names inside every arm are deliberately unlike each other and unlike any
letter scheme, so an agreeing cell cannot be an artefact of the naming.

| arm | axis | result |
|---|---|---|
| `v124_1_shapes` | assoc string-key / assoc int-key / dynamic / queue `[0]` / queue `[$]` / fixed element / 2-D `[1][3]` / class-handle element / plain member / no-select control | def 7 / elab 7 TOGOLD |
| `v124_2_chain` | `this.`-prefixed, `super.`-prefixed, `a.b[x]`, `a[x].b.c[y]`, `a.b.c[y]` | def 3 / elab 3 TOGOLD + 2 MOVEDOTHER (R1) |
| `v124_3_homes` | in-body method, out-of-body function AND task, free package function AND task, module task, module `initial`, module `always`, an **interface task**, a **generate-scope block** | def 15 / elab 15 TOGOLD |
| `v124_4_lv` | the SAME select as an ordinary **rvalue** and **lvalue** in the SAME method as the statement call | def 4 / elab 4 TOGOLD; the rvalue/lvalue cells BYTE-IDENTICAL to pristine and to golden |
| `v124_5_import` | wildcard-import CLONES (uvm122's home-binding fence), export, ×3 module instances | def 5 / elab 4 TOGOLD |
| `v124_6_fence` | index that is a CALL, an OPERATION, a CONCATENATION, a plain id | def 4 / elab 4 TOGOLD |
| `v124_7_hier` | static property, `pkg::Class::prop[k]`, a STRUCT member `s.f[i]`, a virtual-interface member `dk.V[k]`, a gen-block-ARRAY element `Bay[0].C["h"]`, a module-hierarchy path `u_left.S["r"]` | def 3 / elab 2 TOGOLD, 2-3 MOVEDOTHER, **4 SAME_DIFF — the fence's blind spot, §4 R-V2** |
| `v124_8_exotic` | a CALL-RESULT receiver `draw().push_back(...)`, an array-slice receiver | **byte-identical** to pristine (refused) |
| `v124_9_partsel` | a ranged part-select receiver `Bits[3:5].reverse()` | **byte-identical** to pristine (refused); the legal cell beside it TOGOLD |
| `v124_10_meth` | `push_back` `push_front` `pop_back` `pop_front` `insert` `delete()` `delete(idx)` `delete(key)`, a user function, a user TASK — and `size`/`num`/`exists` in EXPRESSION position as controls | def 10 / elab 10 TOGOLD; every expression-position control SAME_AGREE |
| `v124_11_bind` | the renamed prefix now BINDS: package variable vs FORMAL of the same name, vs subroutine LOCAL of the same name, class property vs task formal | def 7 / elab 7 TOGOLD; every new binding byte-identical to golden **except** the one in §4 R-V1 |
| `v124_12_shadow` | class property colliding with a package variable, with a NO-SELECT control in the SAME method | 1 TOGOLD; the control convicts the binder as PRE-EXISTING (§4 R-V1) |

Totals: **118 TOGOLD, 0 MOVED-WRONG, 0 AWAY-FROM-GOLDEN**, 10 MOVEDOTHER (all
R1), 9 SAME_DIFF (refused shapes, unchanged). The implementer's own six arms,
re-scored with THIS verifier's extractor and scorer, reproduce their claim
exactly: **58 TOGOLD, 0 MOVED-WRONG, 6 MOVEDOTHER**, `g124_e_expr` SAME_AGREE=7
in both views. Golden-vs-golden calibration of the scorer: **0 DIFF / 0
ONESIDED over 45 views**.

## 3. The corpus, measured twice over

Independent a-priori prediction from PRISTINE dumps alone (`vpred.sh`,
`PREDICT.sl.r10v124.txt` / `PREDICT.u2r.r10v124.txt`): **7 candidate surelog
databases / 949 zero**, **0 / 1358** on uhdm2rtlil. `byteverify` then found
**exactly those 7** and **exactly 0** — nothing unpredicted.

`MOVERS.r10v124.txt`: order-blind (sorted, path- and id-normalised) whole-dump
diffs are 120 lines on SeqDriver/MiniAmiq and 60 on SimpleUVM/Scoreboard, and
**every moved line names `m_inst_override_queues` or
`m_inst_override_name_queues` — 0 lines outside the family** on all seven.
Scoreboard/default reads 152 ORDERED and 60 ORDER-BLIND: the 92-line
`vpiTaskFunc` COIN is fully separated from the law's 60. Census: **TOGOLD=5 on
each of the seven = 35 cells, 0 MOVED-WRONG, 0 AWAY**; multiset line audit
**BAD_REMOVED=0 AND BAD_ADDED=0** on all seven — the corpus movers are pure
renames onto lines golden already holds, and they gain **no** new bindings.

MiniAmiq's `get_cover_statistics_dpi(cover_info[index]` fossil (buvm23 residue
R-P) is predicted as a candidate and **refused** by the tree fence:
byte-identical after the law. R-Q is genuinely closed — golden strips
`q[0].delete()`'s subscript too, measured here on `v124_1`, `v124_10` and the
corpus.

## 4. RESIDUES THE VERIFIER FOUND (ranked; none is a regression)

**R-V1 — the renamed prefix BINDS, and the pre-existing late binder is
sometimes wrong.** In a class method whose class lives in a package that also
declares a variable of the SAME name, the new bare receiver name binds to the
PACKAGE variable where golden binds the CLASS PROPERTY:
`v124_12_shadow.sv:13` (`Vatt[kx].push_back(1201)` inside
`Tannery2::Currier2::plain`) — golden `array_var (Tannery2::Currier2::Vatt)`,
patched `array_var (Tannery2::Vatt)`, pristine **no `Actual_group` at all**.
Both ends are wrong, so this is MOVEDOTHER, not MOVED-WRONG. **The mis-binder
pre-dates this pass**: the CONTROL two lines below in the same method,
`Vatt.delete(kx)` with no select at all, shows the identical mis-bind already
in the PRISTINE binary. The law only routes one more reference into it.
**Corpus population ZERO** (the seven movers gain no bindings). Rank 1 because
it is the only way this pass can turn "no answer" into "a wrong answer".

**R-V2 — the tree fence refuses three whole receiver FAMILIES golden strips.**
`builtinRecvStepSelectors74` walks only `NamedValue` / `ElementSelect` /
`MemberAccess`, so where component 0 is anything else the written subscript
survives (`v124_7_hier`, all four SAME_DIFF cells, both views):
* a virtual/instantiated INTERFACE member — `dk.Vents[kx].push_back()`:
  golden `mfc Vents` + prefix `dk` + 1 argument, ours `mfc Vents[kx]`, 0 args;
* a GEN-BLOCK-ARRAY element — `Bay[0].Cans["h"].push_back()`: golden strips
  BOTH (`prefix Bay`, `mfc Cans`, 1 arg), ours strips neither;
* a MODULE-HIERARCHY path — `u_left.Slats["r"].push_back()`: same shape.
This is the largest remaining hole in the law and it is invisible to the
pass's own grids. Corpus population not measured here.

**R-V3 — R1 is broader than the pass's README states.** The
"second-component subscript is golden's ARGUMENT" gap is NOT confined to
class-handle chains: a plain STRUCT member reaches it too
(`v124_7_hier.sv:19-20`, `Casing.Panes[1]` / `Casing.Sash[kx]`). Names move
TOGOLD, the argument vector stays empty. Corpus population still ZERO.

**R-V4 — whitespace disables the law.** `stepIdxGroups14` requires the bracket
groups to TILE the step with nothing after the last `]`, so
`a[i] . b.push_back()` refuses the whole walk and keeps the written prefix.
Identical to pristine; a completeness gap, not a defect.

**R-V5 — a gen-scope queue declaration is an `array_net` here, an `array_var`
in golden** (`v124_3_homes` elab, `work@Yard.Loft.Ledge`). Pre-existing; the
law's new binding now points at it, which is why that arm-view is the only one
whose added-line multiset exceeds golden on a non-generic line.

**R-V6 — import-clone MULTIPLICITY.** In ELAB a wildcard-imported package's
cloned function body appears 12x here against golden's 11x
(`v124_5_import` elab, `Origin::Bench` at 17:5). Pre-existing and untouched.

## 5. R0, independently confirmed

The patched head (`head_pat_default_SeqDriver.v124.cmp`, 17 lines, one
`^LHS:`) is byte-identical to the pass's `head_pat_default_SeqDriver.cmp`.
The field decode is **right and re-derived**: `ref_obj` is a `simple_expr` is
an `expr`, and `expr::Compare` line 100
(`~/git-repos/UHDM/build/generated/src/expr.cpp:100`) is
`SafeCompare(lhs->Typespec(), rhs->Typespec(), context)` — the SINGULAR
overload, `RHS: <null>` — so the failing field is `ref_obj::Typespec`.
Both source ends check out in `uvm-1.2`: `uvm_printer.svh:808` cols 25-27 is
the ARGUMENT `id` of `return uvm_leaf_scope(id, scope_separator);`, and
`uvm_misc.svh:445` cols 33-39 is the `string` of the CALLEE's first formal
`full_name`. Golden types a call ARGUMENT from the CALLEE's FORMAL; we emit no
typespec. Typespec-linkage family, not naming.

## 6. Instruments

`v124cells.py` (independent census: every `method_func_call` DECLARATION site
with its prefix kind/name/span, its own name/span, and its argument
kinds/names/spans; key = call start | call name BASE | prefix start — all
three invariant under the law), `v124score.py` (multiset join, ONESIDED scored
never skipped), `vlines.py` (multiset LINE audit: BAD_REMOVED / BAD_ADDED
against golden's own multiset — the instrument that would convict a
regression the census key cannot see), `varms.sh` (fd-3 list, `</dev/null`
children, relative-path scratch, per-tool rc, PROCESSED asserted, both views),
`vpred.sh` (a-priori mover predictor over a sweep workdir). `bound124.sh` was
reused VERBATIM from the pass for the wide boundary.
