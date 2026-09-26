# r11v178 — adversarial verification of r11u178: every headline number reproduced bit for bit; two index-parent breaks of § hierPathSelIdxAtPath178 (the inc/dec operand and the elaborated cont-assign clone, pristine-right on the parent) refined as § hierPathSelIdxCloneKeepsElem178v, the do-while end refined to the condition's end (§ doWhileEndsAtCondEnd178v); gates unchanged from the implementer's patch, 5 more case-modes converted

Verifier pass of `r11u178` (pair A, expression/parameter ground). Base `5e8d08d9` (branch matrix-1.87). Worktrees
`/tmp/wt_v11u178` (patched) and `/tmp/wt_v11u178pris` (pristine), system-deps config, `-j 2`. Deliverable
`/tmp/r11u178.verified.patch` = the implementer's patch + the two refinements below + this directory + the regenerated
`tests/LAWS.md`. Surface: `src/ExprEmit.cpp`, `src/StmtEmit.cpp` (the refinements), `src/ParamEmit.cpp` (the
implementer's, unchanged). No sister-ground file, nothing under `results/` or `third_party/`.

## Binaries (frozen `chmod 555` in `/tmp/v11u178_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `9958104447d83791aab5afe31f796885` | worktree build of `5e8d08d9` = the main tree's `build/slang-uhdm` |
| `law.bin` | `73acc5ae02789950d3019c7cb4c4c2a6` | `5e8d08d9` + `/tmp/r11u178.patch` (md5 `09d9ce30…`): = the implementer's `law178.bin` |
| `fix1.bin` | `caa19dc5f82db3fd469522eb7bd4d8d1` | `law.bin` + § hierPathSelIdxCloneKeepsElem178v + § doWhileEndsAtCondEnd178v (= the build of the verified patch's final source) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

Sweeps (`drivers/sweep.sh` = `tests/sweep.sh --jobs 3` from the patched worktree, `STRICT_CMP` pinned, `GOLDEN_DEFER`
unset): `/tmp/v11u178_swP` (pris.bin), `/tmp/v11u178_swM` (law.bin), `/tmp/v11u178_swF` (fix1.bin), same-length
names. `cmds.txt` audit: 3273/3273 `slang:` lines name the sweep's own binary in each of the three.

**The fence.** `drivers/env.sh` reads the four names from `tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and
every driver refuses without four (and refuses a fenced path); byte-verification ran on fence-free hard-link mirrors
(`drivers/bvmirror.sh`: 2560 mirrored, 8 fenced skipped); the predictor lists 6647 databases with 8 fenced excluded;
`drivers/rowsoff.sh` refuses a regex matching a fenced name. No file here names a fenced test (word-boundary scan: 0).
No gdb. Only the gate sweeps dispatched fenced rows.

## 1. The implementer's headline numbers, reproduced

| axis | claim | measured (`evidence/sweep_sw*.log`) |
|---|---|---|
| pristine gate | 0/0/0 everywhere, probe 2796/1291, downstream 803/66/2/0 | same; `swP/probe.csv` byte-identical to `results/golden_probe.csv`, `swP/downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv` |
| probe (law) | reg 0 / conv 18 / changes 64, EQUAL 2814 | **0 / 18 / 64, EQUAL 2814 STRICT_NOTEQUAL 1273** |
| surelog (law) | 0 / 1 / 11 | **0 / 1 / 11**; `LocalScopeHierPath,testflags,CMP_EQUAL,,,equal` |
| uhdm2rtlil (law) | 0 / 0 / 2 | **0 / 0 / 2**; `iface_zero_width_field,{default,testflags},STRICT_NOTEQUAL,differ:fullname(3)` |
| downstream (law) | csv byte-identical to pristine | **byte-identical**; `ExpressionInIndex,IDENTICAL,OK,OK,64,64,,`, `iface_zero_width_field,IDENTICAL,NO_GATES,NO_GATES,0,0,,`, `packed_struct_array_shift,IDENTICAL,OK,OK,54,54,,` |
| the 11 surelog changes | BuildUVMPkg d/t line(94)->(69); MiniAmiq, SeqDriver d/t file(29)->(26); SimpleUVM d/t, Scoreboard d fullname(45)->(42); SVSwitch d/t fullname(11)->file(9) | identical lines |
| corpus byte movers | 25/2560, all predicted | **25/2560** (SELFCHECK 2559/2560, path sets identical), every one in the implementer's `predict_pristine_hits.txt` |
| probe byte movers | 92, all predicted | **92**, all predicted; order-blind: CONVERSION TOWARD 18, CHANGE TOWARD 63, CHANGE SAME 1 (`r11u60repro/g7`) |
| downstream slang lane | 3 database movers | **3** of 805 compared (ExpressionInIndex, iface_zero_width_field, packed_struct_array_shift); 0 RTLIL/netlist files moved |
| canaries | surelog ok=43 changed=9; u2r ok=16; ctcan2 PASS x2 | same (`evidence/canaries.txt`) |
| UVM first records | unchanged; MiniAmiq objects 413982 -> 428712 of 435559 | same (`#573 enum_typespec uvm_pkg::uvm_check_e` file; fullname 5 -> 2) |
| r11u175 grid | f5 e01/e02/e03/e05 and f7 d1-d5 convert, f2 controls stay | same, in BOTH modes (the implementer ran default only) |
| r11u178 grid | h01e h04e h05e m02e m03 m03e m06e convert; h08 fullname -> endcol | same |

## 2. Breaking the laws: 57 fresh cases x both modes (`cases/`, `drivers/grid.sh`, `evidence/grid_final.txt`)

Each case judged by uhdm-cmp against the v1.87 pin, by uhdm-strictcmp, by the order-blind record distance to golden
(`drivers/ob.py`), by the index parents (`../r11u178repro/drivers/idxpar.cpp`), and the synthesizable ones by the
downstream verdict (`drivers/ds.sh`). Groups (law named in every case's first line):

| group | law | case-modes | law.bin vs pristine |
|---|---|---|---|
| `hx` (17 cases) | § hierPathSelIdxAtPath178 | 34 | 12 conversions, 19 toward, 1 same, 14 stage 1 both; parents: two breaks (below) |
| `hd` (3) | § hierPathSelIdxAtPath178 (packed, downstream) | 6 | 3 conversions; downstream IDENTICAL on every one, both binaries |
| `fn` (10) | § refFullNameThroughNamedExpr175 | 20 | 5 conversions (call arguments, select indices in module/class/interface subroutines), 7 toward, none away |
| `pu` (12) | § pkgPatUnqualReadTsNoParent178 | 24 | 5 toward, 8 same (order-blind artifacts of one fixed record, as the implementer's g7), none away |
| `ic` (5) | § importCloneBodyLocalCopies175 | 10 | toward on i01 (486 -> 98 records) and i02 (33 -> 3); the controls (explicit import, class method import) unchanged |
| `dw` (4) | § doWhileSpansToCloseParen175 / § doWhileEndsAtCondEnd178v | 8 | 4 conversions (include file, always_comb) |
| `hk` (6) | § hierPathSelIdxCloneKeepsElem178v | 12 | the breaks |

Notable non-breaks: `pu/u01_formal_shadow` (a function formal named like the parameter, `return B.D`): the law fires on
the formal's read and golden AGREES (Surelog's component branch reduces `B.D` by name and mints the unparented reference);
`pu/u03` (a class property shadowing) does not fire (ours' listing stays tagged). § refFullNameThroughNamedExpr175 and
§ importCloneBodyLocalCopies175 moved nothing away on any fresh shape.

### Break 1 — the inc/dec operand (pristine right on the parent)

`m.w[k+1].v++;`, `--m.w[k*2].v;`, `x = m.w[k].v++;` in a module initial, always_comb, a for step, a module and a
package function and a class method (`hk/k01`, `hk/k02`, `hk/k06`): golden keeps the index at the MEMBER BIT_SELECT
(an inc/dec operand is compiled as an lvalue), pristine had it there, § hierPathSelIdxAtPath178 hung it on the path
(the operand reaches the member-select site with `inLhs` false). 12 index parents moved away from golden on `k02`
alone. Strict-invisible in count on `k01` default (the name moved from `work@top.k` to `work@top.m.w[k + 1].v.k`,
golden `work@top.m.w[k + 1].v.w.k`: 36 = 36 records order-blind).

### Break 2 — the elaborated cont-assign clone (pristine right on the parent)

`assign y = c ? m.w[i-1].v : m.w[i].u;`, `~m.w[i^1].v`, `{m.w[i+2].v, ...}`, `um.w[k].v + um.w[k+1].v`
(`hk/k03`, `hk/k04`, `hk/k05`): Surelog re-writes an operation right-hand side for the elaborated module as a
`clone_tree` copy (UhdmWriter::writeCont_assign's operation branch, § caLhsDefNetUnlessOpRhs139's decode), and the clone
parents every index at the clone's bit_select; the definition view, a generate scope (`hx/x08`) and a net declaration
assignment (`k04` line 14) compile fresh and keep the path; a plain-path or call right-hand side is shared with the
definition (no elaborated copy on either side). The law hung the elaborated index on the path too. Measured: `k04`
default golden 5 elaborated indices at the bit_select, law 0, pristine 5.

### The refinement — § hierPathSelIdxCloneKeepsElem178v (ExprEmit.cpp, `emitMixedHierPath`'s two law sites)

In an inc/dec operand (`incDecOperand124() == &expr`) and in the elaborated cont-assign right-hand side
(`contAssignView == 2`), the index STAYS at its bit_select and the references in it (the index itself, or the
operands of an operation / call index) take UHDM's chain name through the bit_select, set design-final by the existing
`drainHierPathSelIdx178` (golden `work@top.m.w[k + 1].v.w.k`, `work@top.m.w[i].u.i`, `work@top.um.w[k].v.k`).
Switches `R11V178_INCDEC_OFF`, `R11V178_ELABCA_OFF` (each restores the implementer's law there), `R11V178_OFF` (both
and the next refinement); it also obeys `R11U178_MIDIDX_OFF`, `R11U178_MIDIDXNAME_OFF` (the name half) and
`R11U178_OFF`. Result: every index parent equal to golden's on `hk/k01`-`k05` both modes (law: 2, 12, 2, 5, 2 objects off), `k06`
2 -> 1 (the streaming lvalue, residue V1); `k03`, `k04`, `k05` default CONVERT (law fullname(2), (5), (2)); `k01` 36 -> 28 records (law 36) default,
32 -> 28 elab; the elab modes of `k03`-`k05` stay converted.

### Refinement — § doWhileEndsAtCondEnd178v (StmtEmit.cpp, at § doWhileSpansToCloseParen175)

Golden's do_while ends at the CONDITION's end, which is the `)` only when nothing stands between them (`dw/w04`,
`dw/w01`): `while ( i < 3 );` 5:5-5:26 (the `)` is col 27), `while (j < 3 /* c */);` ends after the `3`, a condition
on its own line `while (\n j > 0\n );` ends 12:12 (the `)` sits on line 13), `while ((k < 3));` after the inner `)`.
The end is the condition syntax's end when it lies in the statement's buffer, else the closing parenthesis as landed.
Switch `R11V178_DWCOND_OFF`. `w04` both modes CONVERT (law endcol(4)); `w01` 8 -> 4 records. Residue: a macro
condition `while `C;` (golden 8:25, the macro model's column: ours stops at the keyword).

## 3. Gates with the refinements (fix1.bin, `/tmp/v11u178_swF`)

- probe: regressions=0 conversions=18 changes=64, EQUAL 2814 / STRICT_NOTEQUAL 1273; `probe.csv` byte-identical to
  the law sweep's; 0 probe databases moved against the law sweep.
- surelog: regressions=0 conversions=1 changes=11; uhdm2rtlil: 0 / 0 / 2 — every csv row identical to the law sweep's
  (the LowMem detail-text draw aside).
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0; `downstream.csv`
  byte-identical to the pristine sweep's.
- The sweep exits 1 only on `law index STALE` (the new § tokens before `tests/LAWS.md` was regenerated); the patch
  carries the regenerated file (`law_index.py --check` reads current on a fresh `5e8d08d9` + the patch).
- uhdm-cmp 0 lines on every touched corpus row and probe case (their statuses stay judge-equal); canaries as in §1.

**Movers fix1 vs law, predicted first** (`drivers/predictv178.cpp` over the LAW sweep's databases, before the fix1
sweep: 11 of 6647 named, `evidence/predict_refinements_hits.txt`): corpus **7 / 2560 movers, all 7 predicted**
(MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d: INCDEC, uvm_factory's `...[index]...++` paths); 4
predicted did not move (Scr1SvTests d/t and GenScopeHierPath3 t: elaborated cont assigns whose index the law never
reparented; `r10v158repro/v158_d`: a do-while the § doWhileSpansToCloseParen175 site never reaches). Order-blind,
fix1 vs law against golden: MiniAmiq d 36039 -> 36021, SimpleUVM d 17242 -> 17226, SeqDriver t 29597 -> 29573,
Scoreboard d 15474 -> 15462, all TOWARD (the `index` references of `find_override_by_name` / `_by_type` now named as
golden; the remaining UINT lines are the known UVM order coin).

**Switches** (`evidence/probe_switch_alone.txt`, `evidence/corpus_switch_off.txt`): the probe gate with each switch
alone (`R11U175_MULT_OFF`, `R11U175_FULLNAME_OFF`, `R11U175_ESPAN_OFF`, `R11U178_MIDIDX_OFF`,
`R11U178_MIDIDXNAME_OFF`, `R11U178_PATUNQUAL_OFF`, `R11V178_INCDEC_OFF`, `R11V178_ELABCA_OFF`, `R11V178_DWCOND_OFF`)
reads regressions=0 every time; `R11U178_OFF` reads 0/0/0 (the baseline). On the 242 case-modes (this directory, the
implementer's `cases/`, r11u175's f2/f5/f7): `R11U178_OFF` = pristine bytes 242/242; `R11V178_OFF` = law bytes
242/242; the four implementer-law switches plus `R11U175_OFF` together = pristine 242/242; each `R11V178_*_OFF`
alone restores the law bytes on exactly its own cases. Probe: fix1 with `R11U178_OFF` = pristine on the 92 movers,
with `R11V178_OFF` = law on the 92. Corpus mover rows re-run (`drivers/rowsoff.sh`: 23 surelog databases, Scoreboard testflags being
SLANG_REJECT, + 6 uhdm2rtlil): `R11U178_OFF` = pristine on 18 + 6, `R11V178_OFF` = law on 17 + 6; every other one
(5 and 6 UVM databases) differs only in the UVM order coin (4 UINT/decompile lines + header, or Scoreboard's list-order flip: order-blind 2 header lines).

## 4. Residues, ranked (the implementer's R1-R7 stand; added here)

V1. The streaming lvalue `{>>{m.w[k+2].v}} = x` (`hk/k06` line 11): golden hangs the index on the path (compiled as an
rvalue), ours keeps the bit_select through `inLhs` (pre-existing, both binaries).
V2. The inc/dec path's own records (`hk/k01`): golden's `m` reference spans from the member, the bit_select is named
`work@top.m.w[k + 1].v.w` spanning to the `]`, the leaf `v` unnamed; ours differs on all three (pre-existing
§ incDecMemberPathIsLvalue124 territory), and the compound-assignment lvalue `m.w[k+1].v += 2` names its index
`...v.k` where golden has `...v.w.k`.
V3. Multi-dimensional member selects `m.w2[k][j+1].v` (`hx/x05`) and genvar-folded generate-scope paths (`hx/x08`: 5
records, law-only-partial): index parents still off golden in some elements (pre-existing, stage 1 on x05).
V4. The do-while condition written through a macro (`dw/w01` line 8) and a do-while in a class task with a declared
local (`r10v158repro/v158_d`, golden 88:7-92:24): § doWhileSpansToCloseParen175 does not reach them.
V5. `pu/u07` (packed struct pattern) `#207`: the module import listing's reference golden names `work@top`, ours
unnamed on every binary (the implementer's R5 twin).

## 5. Files

- `cases/hk/*` (§ hierPathSelIdxCloneKeepsElem178v), `cases/dw/w01,w04` (§ doWhileEndsAtCondEnd178v),
  `cases/dw/w02,w03` (§ doWhileSpansToCloseParen175), `cases/hx/*`, `cases/hd/*` (§ hierPathSelIdxAtPath178),
  `cases/fn/*` (§ refFullNameThroughNamedExpr175), `cases/pu/*` (§ pkgPatUnqualReadTsNoParent178), `cases/ic/*`
  (§ importCloneBodyLocalCopies175).
- `drivers/`: `env.sh`, `grid.sh`, `ds.sh`, `sweep.sh`, `matrix.py`, `ob.py`, `obrow.py`, `obprobe.py`, `coin.sh`,
  `offcases.sh`, `offbytes.sh`, `rowsoff.sh`, `probeswitch.sh`, `bvmirror.sh`, `predictv178.cpp` / `.sh` (build with
  `../r11u175uvm/drivers/cc175.sh`).
- `evidence/`: the three sweep logs, the downstream csv identities (`downstream_identity.txt`), byte-verify outputs, predictions, probe movers and their
  directions, the case grid and its matrix, canaries, switch results.
