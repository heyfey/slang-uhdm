# r10vearl98 — ADVERSARIAL VERIFICATION of § `genCaAncestorNetShadowUnbinds98`

**VERDICT: ACCEPT `r10earl98` as shipped.** No production change was needed;
no `.verified.patch` exists. This directory is the verifier's own evidence:
nine independent arms that attack the law from angles the pass's own `g0`–`g6`
did not cover, plus the wide-boundary tally measured on the verifier's own
binaries.

**BASE `3b588b6`.** LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge;
everything here is measurement only.

---

## 1. Reproduced bit-for-bit

Both binaries rebuilt from scratch in the verifier's own worktrees and frozen
`chmod 555` at immutable paths, same length 22342256:

| | md5 |
|---|---|
| pristine `3b588b6` | `afff6da0b582557192810f2e28c8be3f` |
| patched | `027499accb40ad7c87d62d844c12b33b` |

— identical to the implementer's. Every headline number reproduced: goldens
23/0 on both binaries and 23 FAIL under `/bin/false`; `ct8rows` 0 differing
rows on `uhdm2rtlil` (both modes, committed baseline and own pristine) and 0
over 1588 on the Surelog suite; `byteverify SELFCHECK=1` MOVERS **0/1358**
(u2r) and **3/956** (Surelog) — `default/Earlgrey_0_1`,
`testflags/Earlgrey_0_1` and `default/Scoreboard`, whose path-normalised dump
diff is 92 lines raw and **0 order-blind** (the documented `svunit_pkg` coin).
Each Earlgrey mover's whole-dump diff is exactly **16 lines**: eight removed
`|vpiActual:` + `logic_var` pairs on `fifo_wptr` / `fifo_rptr` in the four
`prim_fifo_sync` gen scopes under `u_hmac`. `reg98.py` over the fixed key
universe: **TO-GOLDEN 8 / AWAY-GOLDEN 0 / CHANGED-WRONG 0 / ADDED 0 /
REMOVED 0** in both modes (`BOTH-RIGHT 41353` default, `16506` testflags).
`pop98.sh` on the u2r pristine workdir: `PAIRS=1356 FENCED=2`,
`SHAPE=566 SHAPEREF=4268 FIX=0 AWAY=0` — the implementer's table exactly.
Head: `Earlgrey_0_1/default` 31,1 → 36,1 **on a new object**, the
`hmac_core.sv:116:83` unbased `'1`, byte-identical to the testflags head.

## 2. The nine adversarial arms (`VARMS.reg98.txt`)

Every arm: Surelog golden + both frozen binaries, **plain and `-elabuhdm`**,
scored by per-key multiset intersection (`reg98.py`), never a dump diff.

| arm | what it attacks | plain | elab |
|---|---|---|---|
| `v1_decl98` | the DECLARATION-FACE grid *with* a d1 shadow — `logic`, vector, initialised, `var logic`, `wire`, `reg`, `bit`, `int`, a typedef'd logic, a struct-typed var, an unpacked-array element select (earl98's own `g5` is the same grid with NO shadow, so nothing there could move) | 16 → 0 AWAY | 16 → 0 AWAY |
| `v2_mixinst98` | **THE BODY-SHARING TRAP** — three instances of one definition, only the middle one with a shadowing ancestor | 2 → 0 AWAY | 2 → 0 AWAY |
| `v3b_shapes98` | generate-for with 1 and 3 iterations, a nested generate, two SIBLING gen scopes declaring the same name, a local driven continuously and read procedurally | 18 → 0 AWAY | 10 → 0 AWAY |
| `v4b_bind98` | a **`bind` instance** whose target's net is the shadow | 2 → 0 AWAY | 2 → 0 AWAY |
| `v4c_ifc98` | an interface in the design: a name living ONLY in the interface must stay bound, a module name above it must unbind | 2 → 0 AWAY | 2 → 0 AWAY |
| `v5_deep98` | a d4 net, and at d1 a `localparam` / `typedef` / `genvar` / INSTANCE NAME of the same spelling — `bindVariable` reads only `Variables()` and `Nets()`, so all four must be IGNORED | 2 → 0 AWAY | 2 → 0 AWAY |
| `v6_notmine98` | names `Scope::find` could hand back that Surelog never lists: an ancestor's always-block local, a task local, an implicit net, a wildcard-IMPORTED package variable | 4 → 0 AWAY | 4 → 0 AWAY |
| `v7_rhs98` | the Rhs gate's far edges — a USER func_call, a streaming concat, `inside`, `$bits()`, a hierarchical read, a conditional inside a concat | 7 → 0 AWAY | 7 → 0 AWAY |
| `v8_edges98` | an ANONYMOUS gen block, an ancestor reached through a MODULE ARRAY, an ancestor module living inside a GENERATE block, and an INTERFACE-owned gen scope | 14 → 0 AWAY | 12 → 0 AWAY |

**AWAY-GOLDEN 0, ADDED 0, REMOVED 0 in all 18 arm × view cells**; 126 cells
move TO golden. Every patched-wrong set is a STRICT SUBSET of the
pristine-wrong set. The two `CHANGED-WRONG` cells (`v8` elab) move toward
golden and are the pre-existing gen-scope listing duplication (ours 4 copies,
golden 2), not a new error.

**`v2_mixinst98` is the sharpest result.** slang deduplicates
`InstanceBodySymbol`s, so a walk that read a SHARED body's `parentInstance`
would have to answer the same for all three instances. Golden unbinds only
under `u_b`, and the patched census is byte-identical to golden: `u_a` and
`u_c` keep both bindings, `u_b` keeps the DEF listing's binding and drops the
ELAB listing's. The Earlgrey head (4 of 128 `prim_fifo_sync`) is this shape.

## 3. What the verifier measured that the pass did not

* **An ancestor's WILDCARD-IMPORTED package variable counts for Surelog's
  walk.** `v6` row `p_imp`: `import v6pkg98::*` at d1 and `logic p_imp;` in the
  package — golden UNBINDS the Rhs, both binaries still bind it. slang's
  `Scope::find` documents "Don't return imported symbols", so the walk cannot
  see it. 2 cells per view, pristine-wrong and still wrong — a RESIDUE, not a
  regression. Same-arm controls prove the boundary is real: an ancestor's
  named-block local (`p_blk`) and an ancestor task's local (`p_task`) are BOUND
  in golden and bound by us, and an ancestor's IMPLICIT net (`p_impl`) unbinds
  correctly under the patch.
* **A user `func_call` Rhs is a pre-existing UNDER-bind.** `v7` row `r_func`
  (`assign r_func = f98(u1);`): golden BINDS `u1`, both binaries leave it
  unbound — `deep20` descends operations and `sys_func_call`s only. 1 cell,
  unchanged by this pass.
* **`Scope::find` calls `ensureElaborated()`**, so the new walk forces
  elaboration of ancestor scopes during emission. Three independent runs of the
  patched binary over `Earlgrey_0_1/default` produce md5
  `2106673fce6bcdc79cd3c1f1976efb5d`, identical to the sweep's — no Heisenbug,
  no nondeterminism on the largest design in the corpus.
* **The `lv98 < 64` ancestor cap** has no counterpart in `bindVariable`, which
  recurses unbounded. Unreachable in either corpus; recorded, not taken.

## 4. Wide boundary, on the verifier's own binaries

`VBOUNDARY_WIDE.*` — every `.sv`/`.v` under a copy of `tools/probe` at any
depth (subdirectory arms included) PLUS the nine arms above, both views, both
frozen binaries, workdir-normalised `uhdm-dump` byte-compare, list on fd 3,
children `</dev/null`, PROCESSED asserted:

```
PROCESSED=4405 == LISTED=4405   identical 8426   DIFFERING 26   no_output 358
rc by side:  0_A 8085 / 0_B 8085   139_A 14 / 139_B 14
             3_A  344 /  3_B  344     4_A 367 /   4_B 367     <- SYMMETRIC
```

**All 26 differing cells are arms of this pass or of this verification** —
earl98's `g0`–`g4` (10) and `v1`,`v2`,`v3b`,`v4b`,`v4c`,`v5`,`v6`,`v7` (16).
**No earlier pass's arm moves a single byte**, `§ genCaNestedModuleLhsOpRhsBinds59`'s
binder-mirror arms and `§ genCaSelLhsDeepBindGenLocal23`'s select arms
included. The 14 `rc=139` per side are the pre-existing probe segfaults, the
same 14 files on both sides, elab view only. `genvar_loop_decl_3` — the
witness behind the shipped d0 clause — is byte-identical.

## 5. Running an arm

```bash
export PRISTINE_BIN=... PATCHED_BIN=... \
       CEN98=<ct98cen> SC98=tools/probe/r10earl98repro/score98.py
bash tools/probe/r10earl98repro/arm98.sh tools/probe/r10vearl98repro/v2_mixinst98.sv <outdir>
python3 tools/probe/r10earl98repro/reg98.py <outdir>/plain/{g,pris,patc}.cen
```
