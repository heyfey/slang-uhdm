# r10v190 — ADVERSARIAL VERIFICATION of r10uvm190 (§ `enumBaseTdCloneDanglingRange190`)

**VERDICT: ACCEPT.** Every headline number reproduces bit-for-bit from freshly
built binaries. No face this verification tried turns a pristine-right cell into
a patched-wrong one: **AWAY-GOLDEN 0** in every census, arm, boundary mover and
corpus row measured. The implementer's patch needs no change; this directory
adds evidence only (no production surface).

Everything here is MEASUREMENT ONLY. The official `uhdm-cmp` and
`scripts/verify_golden.py` are the judges. LHS is ALWAYS golden.

## 1. What was rebuilt and re-measured (nothing carried forward)

Two fresh worktrees at the base commit, two binaries built `-j 2`, both frozen
(`chmod 555`) before any sweep, `SLANG_UHDM` exported explicitly per binary, and
**every `cmds.txt` audited by binary PATH**: 1573 + 1573 surelog and 1462 + 1462
uhdm2rtlil command files name only this verification's two frozen binaries, and
the main-tree binary appears in none.

| gate | result |
|---|---|
| goldens, patched / pristine | 23 PASS 0 FAIL each |
| negative control `SLANG_UHDM=/bin/false` | 23 FAIL |
| uhdm2rtlil, both modes, both binaries | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL |
| `ct8rows` u2r testflags + default (committed gate, and own pristine) | PASS |
| surelog corpus, 1588 rows, both binaries | identical histograms; `ct8rows` PASS vs the committed baseline AND vs own pristine — **0 differing rows, NO ROW CONVERTED**, `results/*.csv` untouched |
| byte movers, uhdm2rtlil | **0 / 1358** |
| byte movers, surelog | **3 / 956** (attributed below) |
| canaries | ok=52 changed=0 and ok=8 changed=0; `ctcan2` PASS twice |
| `canaudit.sh canaries.sh ctcan2.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected databases | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| determinism | the patched binary produced a byte-identical UVM database on 3 consecutive runs; two arms identical on 2 runs each |

Patch hygiene: 34 files, +4091/−2, `git apply -3` clean on a fresh base tree,
0 conflict markers; production surface is `src/TypeEmit.cpp` ALONE; no
`results/*.csv` hunk; no `rm -rf`; no driver hard-codes another pass's paths
(`CEN=${CEN:-…}` is the only default); all four slang-fenced names appear in no
file but `canaudit.sh`.

## 2. The head, re-measured

`rowheads.sh` over both binaries' own sweeps:

| row | pristine | patched |
|---|---|---|
| BuildUVMPkg default / testflags | 33 lines, 1 head | **300 lines, 1 head** |
| SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, Earlgrey_0_1, Rggen (10 cells) | 62 / 664681 / 95 / 62 / 31 / 37 / 0 | **identical** |

The two BuildUVMPkg cmp logs are byte-identical across modes. The new head is
the pass's R0 verbatim: LHS `function: (uvm_pkg::uvm_root::get), id:60621`
parented on `package uvm_pkg` with `vpiName:uvm_root::get`, versus RHS
`function: id:94911` parented on `class_defn: (uvm_pkg::uvm_root)` with
`vpiName:get`.

**The brief's framing is refuted, independently.** Golden's own dump carries the
`param_assign` at `uvm_pkg.sv:7856` complete with its `vpiRhs` constant, twice —
once per package listing. And the head that CLEARED was cleared by a patch that
touches nothing but a cloned `ref_obj`'s `Actual_group`: a `param_assign` Rhs
head could not have moved. The owner attribution (`ref_obj::Actual_group`, not
`param_assign::Rhs`) is therefore confirmed by construction, not only by the
implementer's masking run.

## 3. The census the implementer's payload could not see

`ct190cen`'s `boundDesc` prints, per bound node, a constant's
decompile/size/value/const-type, a ref's name and BOUND/BARE, and an
operation's op-type/decompile/size/operands. The generated `Compare` bodies read
MORE than that:

* `expr::Compare` → `Typespec()`, a `ref_typespec` whose own Compare reads
  `VpiName`, `VpiDefName`, `Actual_typespec`;
* `simple_expr::Compare` → `VpiUses()` (a vector `ref_obj` inherits — `constant`
  and `operation` derive from `expr` directly and have none);
* `ref_obj::Compare` → `VpiDefName`, `VpiGeneric`, `VpiStructMember`;
* `operation::Compare` → `VpiReordered`, `VpiFlattened`, `VpiOpStrong`,
  `Attributes`.

`cloneRangeExpr190` copies `VpiFullName` (which NO Compare reads) but not the
ref_typespec's `VpiName`/`VpiDefName`, and copies no `VpiUses` — so a census
blind to those fields cannot convict the copier. `ctv190cen.cpp` here prints
every one of them, in three sections: `TDCE` (enum-base typespecs), `TDCX`
(every typespec carrying a `Typedef_alias`) and `RNGA` (EVERY ranged typespec in
the database, clone or not, so an over-wide law shows outside the clones).

Scored on the head's own design, BuildUVMPkg golden vs pristine vs patched:

| section | pristine matching golden | patched | TO-GOLDEN | AWAY | WRONG-KEPT |
|---|---|---|---|---|---|
| TDCE (13 cells) | 11 | **13** | 2 | **0** | 0 |
| TDCX (410 ours vs 1069 golden) | 393 | 394 | 1 | **0** | 15 |
| RNGA (667 ours vs 1301 golden) | 644 | 645 | 1 | **0** | 21 |

and the moved cell, field for field:

```
golden    x28  L=op(t=11,ro=0,fl=0,st=0,dec=-,sz=0,attr=0,TS=NONE,
               [ref(n=UVM_FIELD_FLAG_RESERVED_BITS,dn=-,gen=0,sm=0,BARE,TS=NONE,u=0)|const(1)])
pristine  x27  … BARE …        + x2 … BOUND:constant …
patched   x29  … BARE …        (no BOUND row left)
```

Every compare-visible field on the re-minted nodes equals golden's. The two
uncopied fields are LATENT, not live: across all arms and both corpora every
range-bound `ref_typespec` is either absent (`TS=NONE`) or unnamed, and
`VpiUses` is 0 on all 655 measured nodes — our emitter originates `VpiUses`
nowhere (its only two mentions in `src/` copy it in other clone helpers).

## 4. Faces this verification broke the law against

Five arms, each with ONE REAL Surelog golden per view (`vgrid.sh`, every rc
recorded, both binaries named in every `cmds.txt`), scored by `vscore.py` on all
three sections:

| arm | faces | TO-GOLDEN | **AWAY** |
|---|---|---|---|
| `arms/v190_1_elabovr.sv` | module parameter read by an enum-base typedef, instantiated default / value-override / expression-override / a second override; package parameter for contrast; DEF and ELAB | 1 | **0** |
| `arms/v190_2_scopes.sv` | interface, program, generate-block, parameterized class, nested class, alias chain, module `localparam` (final vs override-able), an unconsumed parameter | 0 (gate never fires) | **0** |
| `arms/v190_3_shapes.sv` | one typedef feeding 1, 2 and 3 enums; `$clog2` and `$bits` bounds the gate must refuse; two-reference bound; zero-width bound; signed base; base with no range | 9 | **0** |
| `arms/v190_4_positions.sv` | the same ranged typedef at EVERY other clone position — function formal, return, body local, unpacked-array element, struct member, port, cast, plain variable — plus a twin typedef no enum ever takes | 1 (only the enum-base cell) | **0** |
| `arms/a_pkg.sv` + `arms/b_use.sv` | cross-FILE parameter, both file orders, `--single-unit` and multi-unit, `$unit`-scope typedef, one base feeding two enums | 6 (correct order) | **0** |

Findings worth recording:

1. **Golden DOES bind an enum-base clone's range reference — in the ELABORATED
   view.** Arms 1-4 carry 3, 7, 9 and 1 golden `TDCE` rows with a live
   `vpiActual`, every one of them `elab`. The pass's law text ("the clone's
   reference dangles for ever") is exact for the DEF view only. The patched
   binary agrees with golden in BOTH views: in `elab` the re-minted subtree is
   re-bound downstream (arm 1's elab dump gains a subtree that carries
   `|vpiActual: \_parameter: (pv1_190::PKW)` — the same object golden binds), so
   the elab payload is unchanged and still matches. The DEF view is where the
   cell moves. In the DEF view golden is BARE in every arm measured, including
   cross-file and `--single-unit`.
2. **The write is not over-wide.** Arm 4 moves the enum-base cell and nothing
   else: the formal, return, body-local, array-element, struct-member, port and
   cast positions of the very same typedef are byte-stable, and the `RNGA`
   section — every ranged typespec in the database — reports the same one moved
   key.
3. **The gate abstains where it must.** `$clog2` and `$bits` bounds never appear
   among the moved keys; the copy is made only for a vector that both holds a
   bound reference and contains none but reproducible nodes.
4. Arm 1's DEF cmp count rises 33 → 58 and arm 3's 33 → 50. This is the head
   OBJECT changing, not a regression: the cmp line count is the head object's
   decompile size. Arm 1's new head is a golden `operation` at `21:16` whose
   cell is BYTE-IDENTICAL in the pristine and patched databases (the census row
   and the sorted whole-dump diff both say so), i.e. a pre-existing difference
   the cleared head had been masking.

## 5. Movers, predicted before they were read

`predict.sh` derives the mover set from the PRISTINE databases alone — a design
must move iff some enum BASE typespec carries a `Typedef_alias` and its range
vector is one the gate accepts. Over all 956 pristine surelog databases it names
exactly:

```
PREDICT-MOVER default/BuildUVMPkg-…/slang.uhdm   cells=2
PREDICT-MOVER testflags/BuildUVMPkg-…/slang.uhdm cells=2
```

and over all 1358 uhdm2rtlil databases, nothing. Observed: byte movers
`0 / 1358` and `3 / 956` — the two predicted, plus `Scoreboard/default`, proven
a COIN by an order-blind attribution (sorted, path-normalised whole-dump diff:
**0 lines**). BuildUVMPkg's own sorted diff is **REMOVED 0 / ADDED 58** =
exactly 2 × {range, operation, `ref_obj` carrying NO `vpiActual`, 2 constants}.

## 6. The boundary, re-run

`bound190.sh` over a copy of the whole probe tree, both binaries, both views:
**LISTED=5100 PROCESSED=5100 PRODUCED_DBS=4936 MOVED_ARMS=13 RC_DIFFS=0.**

* **4** are this pass's own arms — the positive control that proves the gate sees.
* **6** are earlier passes' arms, all TO-GOLDEN, AWAY 0, totalling **19**
  TO-GOLDEN cells: `r10uvm114repro/g114_e_enumbase.sv` (4),
  `g114_f_twopkg.sv` (1, and its DEF view converts **33 cmp lines → 0, rc 255 →
  0: CMP-EQUAL**), `g114_h_ops.sv` (11), `r10uvm188repro/grid188/g188_a_shapes.sv`
  (1), `r10uvm188repro/probe0.sv` (1), `r10vbuvm28repro/gv28_c_edges.sv` (1).
* **3** are r10uvm188's recorded `.bss` static-address false mover, confirmed by
  dumping them: the ONLY changed lines are `UINT:22621945 → UINT:22626041`
  (exactly +4096) and their decompiles, with cmp verdicts and TDCE populations
  unchanged — `r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
  `r10uvm185repro/grid185/g185_e_kinds.sv` (cmp 92/92 both views).

Must-stay floor, scored listed/moved in both columns: uvm187 **6/0** (the
deferral arms stay), uvm170 5/0, earl111 6/0, uvm82 7/0, uvm91 5/0, buvm3 4/0,
buvm15 9/0, sd8 37/0, sd12 108/0; uvm185 5/1 (the `.bss` address), uvm188 4/2
(the render arms re-run: both TO-GOLDEN 1 / AWAY 0).

## 7. The implementer's own grids, re-run with the implementer's instrument

`grid190.sh` + `score190.py` over `probe0.sv` and the three `g190_*` arms, TDCE:
matching golden **59 → 75**, **TO-GOLDEN 16, AWAY-GOLDEN 0,
CHANGED-STILL-WRONG 0** — the reported figure, cell for cell (2+8+1+5).

## 8. Ranked residues found by this verification

1. **R-v1 — the copier drops two compared fields.** `cloneRangeExpr190` copies a
   `ref_typespec`'s `VpiFullName` (read by no Compare) but not its `VpiName` or
   `VpiDefName`, and copies no `VpiUses` for a `ref_obj`. Latent today
   (`TS=NONE`/unnamed and `u=0` everywhere measured) — but a future law that
   makes our range bounds carry a named typespec ref would silently lose it.
   Cheap to close: copy both names and the uses vector.
2. **R-v2 — the landed sibling § `pkgTdCloneRefNoBind18` re-mints ranges with a
   thinner copier** (`TypeEmit.cpp` ~7885-7945): `ranges18` builds each `range`
   without `VpiSize`, which `range::Compare` DOES read, and `cloneB18` copies
   neither `VpiDecompile`/`VpiSize`/`Typespec` on the ref and operation nor the
   constants. The 190 copier is strictly more faithful. The two want unifying
   once the corpus converges (per the standing "no premature extraction" rule).
3. **R-v3 — the enum-base clone still SHARES the typespec's own
   `Left_expr`/`Right_expr`**, which `bit_typespec::Compare` reads, so the same
   dangling-reference law would apply there the moment Surelog populates them.
4. **R-v4 — the ELAB agreement rests on a downstream rebind**, not on the copy
   itself: the re-minted `ref_obj` is left bare and something later binds it.
   Correct in every arm and both corpora here, but it is a coupling the pass's
   law text does not state.
5. The pass's own R1 (clone multiplicity: golden 32 folded + 28 symbolic vs our
   30 + 29 at `uvm_field_flag_t`), R2 (bare-parameter fold width 32 vs 64 —
   visible as arm A's `t_bare` cell), R4 (the dump-synthesised doubled
   `vpiFullName` `uvm_pkg::uvm_pkg::uvm_field_flag_t::…` on the new refs, dump
   only) and R5 (the `.bss` address) all reproduce as written.

## 9. Reproducing

```bash
VCEN=/tmp/r10v190_cen bash buildv190.sh
VCEN=/tmp/r10v190_cen/ctv190cen bash vgrid.sh arms/v190_1_elabovr.sv <pristine> <patched> <workdir>
python3 vscore.py <workdir>/g.cen <workdir>/a.cen <workdir>/b.cen TDCE
bash predict.sh <a pristine sweep workdir>      # names the movers before reading them
```
