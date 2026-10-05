# v11u240 — adversarial verification of r11u240

Base `63725718` (matrix-1.87). Subject: the r11u240 patch (`src/ParamEmit.cpp`, `src/R240.h`; two laws,
§ hoistPoolSourceOrder240 behind `R11U240_POOLORDER_OFF` and § pkgImpPackedArrElemCopy240 behind
`R11U240_IMPARRELEM_OFF`, `R11U240_OFF` drops both). The four slang-fenced tests are never named here; every driver
reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`, fail-closed.

**Verdict: VERIFIED, no fix.** Every headline number of the implementer reproduces with binaries built here. 24 fresh
cases in both views find no break: no case-view leaves STRICT_EQUAL or uhdm-cmp equality, no downstream verdict
moves, and the chain-keyed away census is 0 on every fresh mover except one stage-1 case (A/a08), where the 2
records are a multiset coincidence, not a positional loss (see below). The source files are unchanged from the
implementer's; the verified patch adds this directory and the regenerated `tests/LAWS.md`.

## Binaries (frozen at `/tmp/v11u240_bin` before any measurement)

| binary | md5 |
|---|---|
| pristine (built at `63725718`, system-deps config, `-j 2`) | `67b53b6b11f95808c8b8f655858c6f3f` (the brief's value) |
| law (the r11u240 patch applied to a fresh `63725718` worktree, built there) | `ba6ec6f9038fb19f697aec5366fbd14f` (the implementer's value) |
| uhdm-strictcmp | `fa6e4f42f252ae0ab69d9845003e71c5` |
| strictcmp_x (`drivers/strictcmp_x.cpp`, `drivers/cc_x.sh`) | `886f030233ecdbcce7d0e29ac0c4df2c` |

Both report slang 12.0.0+545f88b2e. The cmds.txt audit ([evidence/audit_movers.txt](evidence/audit_movers.txt)) uses
a path list that was filtered by `$FENCED` before any file was read. It finds 3265 slang lines per sweep, each naming
only that sweep's binary. The implementer's 3273 include the 8 fenced row-modes.

## Gates reproduced ([evidence/sweep_pristine.txt](evidence/sweep_pristine.txt), [evidence/sweep_law.txt](evidence/sweep_law.txt))

| stage | pristine `/tmp/v11u240_wP` | law `/tmp/v11u240_wL` |
|---|---|---|
| probe | 3476 + 611, 0/0/0 | 3476 + 611, **0/0/0** |
| surelog | 469 + 11 / 465 + 9, 0/0/0 | same counts, **0 regressions, 0 conversions, 4 changes** |
| uhdm2rtlil | 803 + 0 per mode, 0/0/0 | **0/0/0** |
| downstream | 803 / 66 / 2 / 0 | **803 / 66 / 2 / 0**, verdict diff 0 (the sorted csvs are identical) |

The 4 changes, from the law sweep's csv:

```
BlackBePipeInt,default,STRICT_NOTEQUAL,differ:depth(1),,differ:depth(1)
BlackBePipeInt,testflags,STRICT_NOTEQUAL,differ:fullname(3),,differ:fullname(3)
SimpleUVM,default,STRICT_NOTEQUAL,differ:file(6),,differ:file(6)
SimpleUVM,testflags,STRICT_NOTEQUAL,differ:file(6),,differ:file(6)
```

The law sweep's surelog and probe csvs are identical to the implementer's once the workdir paths are stripped.
Pristine against law, the surelog csv differs in these four rows only; the other two lines that differ are the two
LowMem detail texts, which carry the workdir path. Both sweeps print `law index STALE` (the base's committed
`tests/LAWS.md`).

First records after the laws (`uhdm-strictcmp --max 2`): BlackBePipeInt d #38807 (golden `parameter
dev_addr_width_gp bp_common_pkg::dev_addr_width_gp` at depth 6, ours `dev_id_width_gp` at depth 2: the walk
diverged), t #38803 (golden `work@bp_be_pipe_int.dev_addr_width_gp`, ours `bp_common_pkg::dev_addr_width_gp`),
SimpleUVM d #75684 (`work@top.this`, golden 902:36-40 with no file, ours uvm_component.svh 1767:16-20), then #80104
(the `uvm_driver` class_typespec location, ground B). These are the implementer's records.

- **Movers.** byteverify `SELFCHECK=1` on the fence-filtered hard-link mirrors (`drivers/bvmirror.sh`; 2560
  mirrored, 8 fenced skipped) reads `PATH_SETS_IDENTICAL`, **MOVERS 6 / 2560** (BlackBePipeInt, SeqDriver and
  SimpleUVM in both modes; the hashes equal the implementer's). The `SELFCHECK ... 2559 / 2560 flagged` line is the
  self-check's own artifact: one side is replaced by one fixed file, and that file compared with itself is the one
  path the check cannot flag.
- **Probe.** The pristine probe sweep was rerun from the law worktree (`/tmp/v11u240_wQ`), because a probe database
  embeds its source path and the first pristine sweep ran from another worktree. 1 of 4087 databases moves,
  `r10uvm81repro/c5_bindpos81`, which is EQUAL in both sweeps.
- **Downstream lanes.** 0 of 805 lane databases differ (positive control: two different lanes read as differing).
- **uhdm-cmp.** Every corpus mover reads rc 0 with 0 lines.
- **Canaries.** On the surelog csv, `canaries.sh` reads ok=50 with 2 changed (SimpleUVM d/t). `EXPECT_UNKNOWN=1
  ctcan2.sh` reads FAIL on the law csv with ok=56 and 2 changed (BlackBePipeInt d/t, the targeted changes), and PASS
  with ok=58 on the pristine csv. On uhdm2rtlil, `EXPECT_UNKNOWN=6 ctcan2.sh` reads PASS.
- **Away census over the sweeps** ([evidence/away_sweeps.txt](evidence/away_sweeps.txt), map 13's `awayrows.py`
  with strictcmp_x, chain key):
  - 7 databases differ, and **away is 0 on every one**.
  - Toward: BlackBePipeInt 288 per mode, SeqDriver and SimpleUVM 57 per mode, c5_bindpos81 0.
  - BlackBePipeInt reads flat_away 288. The implementer's explanation holds: chain away 0 means none of those flat
    records sat where golden has them.
- **Switches on the corpus movers and ApbSlave** ([evidence/switches_corpus.txt](evidence/switches_corpus.txt)):
  - `R11U240_OFF` gives pristine's hash on all 8 row-modes.
  - `R11U240_POOLORDER_OFF` reverts SimpleUVM and SeqDriver only. BlackBePipeInt keeps the law's hash.
  - `R11U240_IMPARRELEM_OFF` reverts BlackBePipeInt only.
  - ApbSlave keeps pristine's hash under every configuration.
- **Determinism** ([evidence/det_law.txt](evidence/det_law.txt), `drivers/det.sh`): three concurrent harness runs of
  the law binary on Earlgrey_0_1 and the five UVM rows in both modes give one hash per row-mode on 11 of 11 (Scoreboard
  testflags writes no database). Each hash equals the law sweep's database.

## The implementer's grid, rerun ([evidence/implementer_grid_rerun.txt](evidence/implementer_grid_rerun.txt))

The implementer's 19 cases were rerun with these binaries: 190 runs, every exit code 0. All 190 lines match the
implementer's in verdict, uhdm-cmp rc, line count and exit code. The md5 column differs only because the source path
differs. `R11U240_OFF` writes pristine's bytes on 38 of 38 case-views. Each switch reverts only its own law: POOLORDER
16 case-views, IMPARRELEM 8.

## Fresh cases (cases/, 24 cases, both views; [evidence/grid.txt](evidence/grid.txt))

`drivers/grid.sh` ran each case on pristine, law, law with `R11U240_OFF`, and law with each switch: 240 runs (15 P
cases and 9 A cases, 48 case-views), every exit code 0:

- `R11U240_OFF` gives pristine's bytes on every one.
- 34 move bytes. **10 enter STRICT_EQUAL** (p05 d/t, p08 d/t, p11 d/t, p14 d/t, p15 d/t; p05's `-elabuhdm` view
  enters from stage 1, uhdm-cmp 32 lines -> 0), and **none leaves**.
- No uhdm-cmp line count rises on any case-view.

Downstream verdicts ([evidence/downstream_cases.txt](evidence/downstream_cases.txt), `drivers/dscase.py`) cover these
24 cases and the implementer's 19, on both binaries. Every verdict is the same on pristine and law. On the five
DIVERGENT cases (a01, a04, a08, a09, n05: faces outside this pass) and the EQUIVALENT p09, the slang lane's
`_nohier.il` is byte-identical between pristine and law.

Away census per case-view ([evidence/away_cases.txt](evidence/away_cases.txt), `drivers/caseaway.py`, chain key):

- Over 34 movers, toward is 157.
- Away is 0 everywhere except A/a08 d/t, at 2 each.
- **A/a08** is stage 1 at the base. It declares `parameter ps_t [1:0] mine = allc;` in the importing package. Golden
  writes the member references of the re-listed `allc`'s param_assign right-hand constant as `bp::cp::ps_t::xd`.
  Ours shares one packed-array object between that constant and the parameter. So pristine wrote
  `work@top.cp::ps_t.xd` there, and the law writes `bp::allc::cp::ps_t::xd`: both are wrong at that position.
- Pristine's string matched, by multiset, golden's record under the param_assign of `mine`. Ours has a `ref_obj`
  there instead of golden's constant, which is the stage-1 face.
- A position-aligned walk over the aligned prefix reads **0 lost, 8 gained**. The 2 are a coincidence of the chain
  multiset, not a lost golden record. The shared object is pre-existing typespec identity (ParamEmit `makeParamTs`),
  the residue named below.

### § hoistPoolSourceOrder240 (P/)

| case | shape | pristine -> law |
|---|---|---|
| P/p01 | one macro expansion defines two out-of-body bodies whose class names sort against source order | STRICT_NOTEQUAL line, unchanged bytes (residue 1) |
| P/p02 | a derived class in a second package reads an inherited property beside its own; out-of-body constructor and task | stage 1 (620 lines, a pre-existing face), bytes move toward (+0/+1) |
| P/p03 | nested macros and a macro argument carrying the reference, constructor first in the text | STRICT_EQUAL kept, bytes unchanged |
| P/p04 | references in a fork, a nested begin, a local initializer and a for-loop bound | STRICT_EQUAL kept, bytes unchanged |
| P/p05 | the module declares one of the names; an interface also imports | d STRICT_NOTEQUAL -> STRICT_EQUAL; t stage 1 -> STRICT_EQUAL |
| P/p06 | a parameterized class's out-of-body method, a static method, a specialization in a dimension bound | stage 1 (a pre-existing face), toward 3/1 |
| P/p07 | a class-scope enum constant and a `with` iterator, a task calling a function, extern above and below | stage 1, toward 3/3 |
| P/p08 | the constant slots: indexed part-select base and width, a replication, an index | STRICT_NOTEQUAL line -> STRICT_EQUAL |
| P/p09 | header import and body import, the hoisting module at depth 2 | stage 1, bytes unchanged |
| P/p10 | an implicit net and an outside net beside the hoist, a generate block, a call as an index | stage 1, bytes unchanged |
| P/p11 | the constructor of the alphabetically first class written first; the later class's method and task read the same names (exercises the constructor-last rule) | STRICT_NOTEQUAL line -> STRICT_EQUAL |
| P/p12 | a `with` iterator and an enum constant in a constructor written before a method that reads them | stage 1, toward 9/5 |
| P/p13 | named-argument calls (linked and unlinked), `super.` and `this.` paths, a class-scoped static call | stage 1 on a pre-existing `super.g` hier_path face, bytes unchanged |
| P/p14 | an include inside the package between the classes, the include holding a constructor and a task | STRICT_NOTEQUAL line -> STRICT_EQUAL |
| P/p15 | a virtual base with a pure virtual prototype, an override's extern prototype below its caller, a typedef'd specialization | STRICT_NOTEQUAL line -> STRICT_EQUAL |

### § pkgImpPackedArrElemCopy240 (A/)

Every A case except a07 is stage 1 at the base, on faces outside the law. uhdm-cmp line counts are unchanged on every
one.

| case | shape | law effect (chain away / toward per view) |
|---|---|---|
| A/a01 | a two-level packed array of the struct; the member read as a localparam width in the importing package | 0 / 8 |
| A/a02 | the element is an alias typedef of the struct, imported by name (`import cp::allc;`) | 0 / 0: bytes move from `work@top.cp::alias_t.xd` to `bp::allc::cp::alias_t::xd`, while golden writes `bp::allc::alias_t::xd` (residue 3) |
| A/a03 | a three-package chain: the struct in one package, the parameter in a second, re-listed by a third that exports | 0 / 8 |
| A/a04 | an array typedef of the struct, a packed union of the struct, a parameter used as a replication count | 0 / 8 |
| A/a05 | two importing packages of one parameter, and a module two levels down reading it | 0 / 8 |
| A/a06 | a struct holding an enum and a packed-array member; the parameter in an indexed part-select base and a generate condition | 0 / 8 |
| A/a07 | controls: a struct parameter, an unpacked array of the struct, a typedef local to the importing package | bytes unchanged |
| A/a08 | the importing package declares parameters built from the imported array (`pick = allc[1]`, `mine = allc`) | 2 / 8, the multiset coincidence above |
| A/a09 | a class and a function in the importing package read the parameter | 0 / 4 and 0 / 7 |

## Residues (ranked)

1. **Ties inside one macro expansion (P/p01, § hoistPoolSourceOrder240).** When one macro expansion defines several
   out-of-body bodies, the bodies share the expansion-site key and keep emission order, which is alphabetical by
   class. Surelog follows the macro body's text order: golden mints `cnt` at line 3, ours at line 4. Pristine writes
   the same bytes, so this is not a break. A tie-break on the fully original location inside one expansion would
   transcribe it. No corpus row is known to hold this shape.
2. **The param_assign right-hand constant of a re-listed packed array (A/a08, every re-listing).** Golden gives that
   constant its own packed-array copy, with the elem ref named `<importing pkg>` and members
   `<pkg>::<home pkg>::<typedef>::<member>`. Ours shares the parameter's object, so the members read through
   `<pkg>::<param>`. The site is ParamEmit `makeParamTs` (typespec identity, ground A). BlackBePipeInt carries this
   at `bp_be_pkg`'s re-listing of `all_cfgs_gp`.
3. **An alias element (A/a02).** Golden names the members through the alias without the home package
   (`bp::allc::alias_t::xd`); the law writes `bp::allc::cp::alias_t::xd`. Both pristine and the law miss golden here.
4. **`super.<prop>` in an out-of-body method (P/p13).** uhdm-cmp reads a stage-1 hier_path face that is identical on
   both binaries (ExprEmit, ground A, not attempted).
5. The implementer's residues stand as written in `tools/probe/r11u240repro/README.md`: BlackBePipeInt #38807 /
   #38803 (§ parenCastWidthRefPkgBare207); h14's two formal-name wires; the brief's items not attempted; and the
   sister-ground faces (TypeEmit `thisImplicitNetBoth38` for SimpleUVM's new head, the class property writer, d01 and
   d03).

## Drivers (`drivers/`; every one reads `$FENCED` fail-closed)

- Copied from r11u240repro: `env.sh`, `case.sh`, `grid.sh`, `gridsum.py`, `bvmirror.sh`, `det.sh`, `awayrows.py`,
  `strictcmp_x.cpp` and `cc_x.sh`.
- New: `caseaway.py` (the chain-keyed and flat away census of one case-view, from case.sh's store) and `dscase.py`
  (the downstream verdict of a case through `scripts/downstream_uhdm2rtlil.py`'s `one()`).

## Process

- Worktrees: `/tmp/wt_v11u240` (the law; this directory) and `/tmp/wt_v11u240pris`. Scratch is under `/tmp/v11u240_*`.
  The main checkout was not written, and no submodule was initialised.
- Fence: every corpus path list (cmds.txt audit, byteverify mirrors, downstream lane list) was filtered by `$FENCED`
  before any file was opened. The away census skips fenced rows unread. No fenced source or database was read,
  dispatched or decoded outside the gate sweeps, and no fenced name was printed.
- No process was listed or signalled other than this session's own background jobs.
- Every tool reached through a variable was checked executable first.
- No law, refinement or source edit was made, so the verified patch's `src/` is byte-identical to the implementer's.
