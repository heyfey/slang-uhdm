# r10v178 — the ADVERSARIAL VERIFIER of r10uvm178 (§ `pkgCloneParamRefStaysBare178`)

**VERDICT: ACCEPT.**  The production surface of `/tmp/r10uvm178.patch` is
shipped UNCHANGED; this directory adds only arms and transcripts.

**MEASUREMENT-ONLY.**  The official `uhdm-cmp` and `scripts/verify_golden.py`
are the only judges.  slang was NOT patched, `results/*.csv` were READ ONLY,
nothing was promoted, NO CORPUS ROW WAS CONVERTED, `GOLDEN_DEFER` stayed unset,
and the four slang-fenced tests were never dispatched (their names appear only
inside `canaudit.sh`'s own fence list, which lives in the implementer's dir).

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

---

## 1. What was reproduced bit-for-bit

Both binaries were rebuilt by the verifier from fresh `4b2b5d06` worktrees:
pristine md5 `252ab5fad779054d39ef74d7dde18edc`, patched md5
`1fc0285162673a878ae95a50430f4126` — **both equal to the implementer's**.  The
verifier's own pristine surelog sweep reproduces `results/golden_surelog.csv`
row for row (`ct8rows` PASS over 1588 rows).  Every headline number in the
implementer's report reproduced: the four heads 33 → 142 / 116 with the head
OBJECT changed, PREF `TOGOLD 144 / AWAY 0 / MOVED-WRONG 0` over the nine UVM
row-modes, REF `TOGOLD 18 / AWAY 0` on SeqDriver/default, the four predicted
movers with 72 all-removal order-blind dump lines each, and every gate green.
`GATES.r10v178.txt` is the full battery.

Two numbers came out different and both are explained, neither is a defect:

* **byteverify reported 5 movers, not 4.**  The fifth is `Scoreboard/default`,
  whose order-blind whole-dump diff is **0 lines** — the documented ~50/50 coin
  (RESUME.md §9), landing the other way in this run.  The four real movers are
  exactly the predicted ones.
* **MOVED-WRONG is 6, not 0**, on a reference position the implementer's arms
  do not walk.  See §3; all six are judge-invisible and none is a regression.

## 2. The break attempt — eight arms, sixteen arm-views

`vgrid178.sh` builds a fresh Surelog golden and BOTH binaries' databases in the
DEF and ELAB views for each arm, records every rc, and echoes every command
with its binary path into `cmds.txt`.  `GRID.r10v178.txt` is the scored join
(the implementer's `score178.py`, multiset, DEF/ELAB kept in separate tags and
the within-database LISTING kept in the key — never merged).

| arm | the face it attacks | result |
|---|---|---|
| `v178_a_kinds.sv` | **parameter KIND**: untyped / typed / **localparam** / **string** / an OPERATION-Rhs chain / a CONCATENATION Rhs, each read from one clone | 12 TOGOLD, **0 AWAY, 0 MOVED-WRONG, 0 STILL-WRONG** — the arm's whole PREF family becomes golden's |
| `v178_b_subkind.sv` | **subroutine KIND**: free function / free **TASK** / out-of-body method / **static** out-of-body method / out-of-body **task** / a default-argument read / an IN-BODY method | 10 TOGOLD, 0 AWAY, 0 MOVED-WRONG |
| `v178_c_pos.sv` | **19 reference POSITIONS** the implementer's arm B does not walk: if- and while-condition, case selector, case ITEM, ternary condition and arm, array index, concatenation operand, for-bound, local-variable initialiser, user-call arg, `$`-call arg, four return shapes, plain assignment, the same parameter TWICE in one body, two parameters in one body | 24 TOGOLD, 0 AWAY, **6 MOVED-WRONG** (§3) |
| `v178_d_multi.sv` | **multiple homes / multiple clones**: one importer wildcard-importing THREE homes, a second importing one, and an **EXPLICIT** single-item importer | 16 TOGOLD, 0 AWAY, 0 MOVED-WRONG; the head moved from home 1 to home 3 (§4) |
| `v178_e_depth.sv` | **control depth 0…3** plus the DIRECT vs NESTED return separation | 12 TOGOLD, 0 AWAY, 0 MOVED-WRONG |
| `v178_f_shadow.sv` | **name shadowing** (the importer AND a third package declare the same parameter name), block kinds (named begin, foreach, repeat, do-while, nested named blocks, fork/join_none) and **aggregate parameters** (unpacked array, packed struct) | 14 TOGOLD, 0 AWAY, 0 MOVED-WRONG; the importer's OWN same-named parameter stays BOUND |
| `v178_g_diamond.sv` | **transitive and DIAMOND clones** (a leaf importing two importers of one home), the same home cloned into two importers, and an out-of-body method reading a **THIRD** package's parameter | 20 TOGOLD, 0 AWAY, 0 MOVED-WRONG |
| `g169_b_forms.sv`, `v169_g_control.sv` | § 169's own committed arms, re-measured against a fresh golden because the wide boundary moves them | 18 TOGOLD, 0 AWAY, 0 MOVED-WRONG |

**Across all sixteen arm-views: `AWAY = 0`.**  Not one cell that agreed with
golden before disagrees after.  The corpus census (nine UVM row-modes) and the
956-database byte sweep say the same thing.

`vbound178.sh` is the wide boundary, `bound178.sh` with per-arm scratch removal
so a 4904-source run cannot fill the VHDX:
`LISTED=4904 FENCED_SKIPPED=0 PROCESSED=4904 MOVED=11 ASYMMETRIC=0`, and the 11
are 4 implementer arms + 5 verifier arms + § 169's two.  **uvm176's, uvm171's,
uvm165's and uvm173's committed arms are byte-identical between the two
binaries**, so uvm173's R4 twice-listed relabelling cannot have regressed; the
four moving UVM databases confirm it independently — their whole-dump
order-blind diff is 36 `vpiActual:` edges and their 36 targets and nothing
else, so no `func_call` listing moved.

## 3. The measured correction — MOVED-WRONG is 6, not 0

`v178_c_pos.sv` walks nineteen reference positions.  Golden's rule for a
wildcard-import clone turns out to be sharper than the implementer's gate
states it:

> **in a clone listing golden keeps a BARE `ref_obj` everywhere EXCEPT under a
> `return`, where the whole return expression is folded and there is no
> reference at all.**

`R2.return-window.r10v178.txt` is the per-listing copy map that shows it:
golden's `Sigma_imp_V` clone holds exactly eleven references — `p_asgn`,
`p_caseitem`, `p_casesel`, `p_cond`, `p_forbound`, `p_index@33:25`, `p_twice`
(twice), `p_twoparams`, `p_varinit`, `p_while` — **all BARE, and the patched
binary matches all eleven**.  Every position under a `return` is absent from
golden's clone.

The implementer's term 3 approximates "under a return" as *`pkgRetTopExpr8` and
the parent is an `operation` or a `sys_func_call`*.  Three positions escape
that test — a user-call argument (`return p_callee(PV)`), a user-call argument
inside a return operation (`return p_callee(PV) + a`), and a bit-select index
(`return arr[PV]`) — so those three cells go from a BOUND `ref_obj` to a BARE
one in both listings: **6 cells**.  Golden holds a `constant` at all three, so
the cell was wrong before and is wrong after; `ref_obj` vs `constant` fails on
`VpiType` either way and the arm's official cmp log is **byte-identical**
between the two binaries.  They belong to the FOLD family the implementer's R1
already books (§ 169 / § 30 / § 32), and they are judge-invisible — but the
report's "MOVED-WRONG 0" should read "0 on every cell golden holds a reference
for; 6 shape changes inside the fold family's residue".

Making term 3 simply `pkgRetTopExpr8` (anywhere inside a clone's return
expression) would take those six back to zero and move nothing else; it is not
required for correctness and was not applied, because the production surface is
accepted as shipped and the change has no judge-visible effect.

## 4. Ranked residues the verification found

* **R1 — the EXPLICIT-IMPORT clone is the same defect and is left un-cleared.**
  `R1.explicit-import.r10v178.txt` is the copy map from `v178_d_multi.sv`.
  `Exp_V` writes `import C3_V::c3_rd; import C3_V::c3_k;` — a single-item
  import, not a wildcard — and golden still carries a **clone** of `c3_rd`
  whose `c3_k` reference is **BARE in both of `Exp_V`'s listings**, exactly as
  in the wildcard case.  We bind it, before and after.  It is why that arm's
  head merely moved from `Ha_V` to `C3_V` instead of clearing.  The listing
  test the law uses (`pkgImportCloneEmit`) names only the two WILDCARD
  emission sites; the explicit-import clone runs under `importCloneEmit`.
  § 169 refused its own explicit-import arm because taking it there converted a
  wrong KIND into a wrong SIZE — that objection does not apply to a SUPPRESS,
  which has no size to get wrong.  Ranked first: it is the same law, one
  predicate wider, with golden read on both listings.
* **R2 — the return window (§3 above).**  Golden's clone has no reference of
  any kind under a `return`; our clone keeps five bound and four bare ones
  there.  Whoever takes the FOLD family next should read
  `R2.return-window.r10v178.txt` first: it is the complete position-by-position
  golden map for one clone.
* **R3 — golden's own asymmetries in the neighbouring cells**, recorded so the
  next pass does not mistake them for this law: a package's OWN function
  reading its OWN parameter is a folded `constant` in golden's `AllPackages`
  listing for a clone CARRIER (`Beta_imp_F::g_own`, `Exp_V::exp_rd`) but a
  BOUND `ref_obj` for a package that carries no clone (`Gamma_far_F::h_far`,
  `Alpha_home_F`'s own functions).  We bind all of them.

## 5. Ops observations (no action required)

* The implementer's `bound178.sh` defaults `BWD` to `/tmp/r10uvm178_bound` and
  `rm -rf`s it; it is overridable and pass-prefixed, so it is not a shared
  path, but a 4899-source run leaves the whole tree on disk.  `vbound178.sh`
  removes each arm's scratch as soon as it is judged (17 MB peak instead of
  tens of GB) and is otherwise the same contract.
* The implementer's note that the `4b2b5d06` control set rotated away mid-pass
  is independently covered here: the verifier's comparisons are against the
  COMMITTED baselines and against its OWN pristine sweep, both re-run after the
  rotation, and both PASS.
* `cen178.sh` reports `missing=617` on a full surelog workdir — those are the
  row directories with no golden cache hit or no `slang.uhdm` (SLANG_REJECT /
  SURELOG_FAIL).  Byte coverage is unaffected: `byteverify` sees all 956
  databases that exist and `PATH_SETS_IDENTICAL` holds.

## 6. What is in this directory

| file | what it is |
|---|---|
| `v178_{a_kinds,b_subkind,c_pos,d_multi,e_depth,f_shadow,g_diamond}.sv` | the seven break-attempt arms |
| `vgrid178.sh` | the arm driver (fresh Surelog golden + both binaries, DEF and ELAB, every rc recorded, every command echoed with its binary path) |
| `vbound178.sh` | the wide boundary gate with per-arm scratch removal |
| `GRID.r10v178.txt` | the scored join of all sixteen arm-views, every moved cell printed |
| `BOUNDARY.r10v178.txt` | the 4904-source boundary transcript |
| `GATES.r10v178.txt` | the verifier's own full gate battery |
| `R1.explicit-import.r10v178.txt` | golden's per-listing copy map for the explicit-import clone |
| `R2.return-window.r10v178.txt` | golden's per-listing copy map for nineteen reference positions in one clone |
