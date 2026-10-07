# v11u277 — adversarial verification of r11u277 (the constructor return class_var span and the strength-redeclared port net's typespec)

Base 59b55191 (pass 275). Verdict: **VERIFIED, no production fix.** Both laws of r11u277 (src/R277.h) hold on every
gate, on the implementer's grid, on 19 fresh case dirs, and on widened byte controls. No case-view, probe case, corpus
row-mode or downstream row moves away from golden.

## Binaries
Both binaries were built in fresh worktrees at 59b55191 with the system-deps config at -j 2, then frozen before any
measurement:
- pristine: md5 057775d8242c95d17077864f2fae643b, equal to the brief's pin;
- law: the implementer's patch applied clean, md5 2b1fe82b03179fa43b0caf4ea0ae677b, equal to the implementer's.

Binary audit: 3273 of 3323 `cmds.txt` in each sweep name that sweep's own frozen binary, 0 name another binary, and
the other 50 have no slang line.

## Targeted rows, reproduced
At the base, `uhdm-strictcmp --max 3` on MiniAmiq in both modes reads two records:
- `#241741 col`: svaunit_immediate_assertion_details.svh 43, golden 23-29, ours 30-34;
- `#243118 col`: svaunit_immediate_assertion_info.svh 37, golden 23-29, ours 30-34.

| row-mode | pristine sweep | law sweep |
|---|---|---|
| MiniAmiq default | `MiniAmiq,default,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)` | **`MiniAmiq,default,CMP_EQUAL,,,equal`** |
| MiniAmiq testflags | `MiniAmiq,testflags,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)` | **`MiniAmiq,testflags,CMP_EQUAL,,,equal`** |

On the law binary, uhdm-strictcmp reads STRICT_EQUAL 435559 objects in both modes, and uhdm-cmp prints 0 lines.
No record is left on MiniAmiq.

## Gate sweeps (tests/sweep.sh --jobs 3; `evidence/pristine_sweep.txt`, `evidence/law_sweep.txt`)
Every number in the implementer's report reproduces bit for bit.

- **Pristine:**
  - probe 3721 + 366;
  - surelog default 477 + 3, testflags 471 + 3;
  - uhdm2rtlil 803/1/67 in both modes;
  - downstream 803 / 66 / 2 / 0;
  - regressions=0 everywhere.
- **Law, probe:** 3728 EQUAL + 359 STRICT_NOTEQUAL, regressions=0, conversions=7, changes=0.
  - r10v223repro/arms/v16_oobctor col(5) -> EQUAL;
  - r11u90repro/grid/u12_strnonansi line(4) -> EQUAL;
  - r11u93repro/grid n1_strnonansi, n2_strrevorder, n7_strnonansi_in, n10_strnonansi_gen line(4) -> EQUAL;
  - r11u93repro/grid/n8_strtwoports line(8) -> EQUAL.
- **Law, surelog:** default 478 + 2, testflags 472 + 2. regressions=0, conversions=2 (MiniAmiq d/t), changes=0.
- **Law, uhdm2rtlil:** 803/1/67, regressions=0, conversions=0, changes=0, csv row-identical to pristine's.
- **Law, downstream:** 803 / 66 / 2 / 0. The csv is byte-identical to the pristine sweep's.

Row-by-row csv diff, law against pristine:
- surelog: only the two MiniAmiq rows, plus the two LowMem testflags rows, which differ only by the workdir path in
  their detail text;
- probe: only the seven conversions.

Every sweep, pristine included, exits 1 on the law-index check alone. At the base itself tests/LAWS.md is already
stale against scripts/law_index.py. The implementer's regenerated tests/LAWS.md reads current once this
directory is set aside.

## Movers (`evidence/byteverify.txt`, `evidence/probe_movers.txt`, `evidence/predict_rerun.txt`)
- The firing census (the implementer's tracecensus.sh, fence-filtered, rerun on the frozen law binary) is identical
  line for line to the implementer's frozen `predict.txt`: 9 databases.
- byteverify (SELFCHECK=1) ran on fence-filtered hard-link mirrors (8 fenced paths skipped by name) with same-length
  names. Movers:
  - surelog 2 of 952: MiniAmiq default and testflags, the positive control;
  - uhdm2rtlil 0 of 1608;
  - downstream 0 of 805.
- Probe: 7 of 4087 databases move, exactly the predicted seven.
  - The pristine probe stage was rerun from the law worktree, because probe databases embed the source path. The
    first compare across the two worktrees flagged every database.
  - That rerun's csv is identical to the pristine sweep's.

## Away census
- MiniAmiq d/t: order-blind distance 61 -> 59 with lost=0, and chain-keyed away=0, toward=2, in both modes.
- The fresh movers: chain-keyed away=0 on all 36 (`evidence/away_fresh.txt`).
- One fresh mover's dump census reads lost=1: VS/vs10_trireg_signed_el, a `    |vpiParent:` line. This is a print
  artefact:
  - the law's dump equals golden's except golden's weaklyReferenced cont_assign block;
  - pristine lacks that block as well;
  - pristine matched the count only through an extra non-golden typespec range line.

## Canaries and determinism
- canaries.sh: surelog ok=52, uhdm2rtlil ok=16, changed=0.
- ctcan2.sh: surelog with EXPECT_UNKNOWN=1 and uhdm2rtlil with EXPECT_UNKNOWN=6, both PASS.
- Three concurrent draws of the law binary (`evidence/det.txt`) on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen:
  - every one of the 12 row-modes that has a database reads one hash in 3 of 3;
  - each hash equals the law sweep's.

## The implementer's grid and controls, reproduced
- **Grid** (`evidence/grid_impl_rerun.txt`, `evidence/gridsum_impl_rerun.txt`): 21 dirs, 42 case-views, every line
  with rc=.
  - OFF equals P on 42 of 42.
  - 38 move: 32 enter STRICT_EQUAL and 0 leave.
  - Attribution: CTORRETSPAN 26, STRPORTTS 12.
  - uhdm-cmp line counts change on 2 case-views (s05_signed 102 -> 0); rc changes on 0.
- **Downstream:** 20 IDENTICAL and s04 SURELOG_FAIL, the same on both binaries.
- **Controls** (`evidence/ctlsum_impl_rerun.txt`): the same 15 repro dirs, 1302 case-views.
  - 12 movers, all entering STRICT_EQUAL: r11u270repro C/c01_input_kw, and tools/probe/r11u92repro/grid n1, n2,
    n7, n8 and n10, each in both views.
  - 0 leave; rc and uhdm-cmp line count change on 0.

## Widened controls (`evidence/ctlsum_wide.txt`)
- Scope: r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, r11u125, r11u130, r11u171, r11v105, r11v130 and
  r11u85 repro dirs, 938 dirs, 1876 case-views.
- r11v105, r11v130 and r11u85 were chosen because they hold strength-declared nets. r11u171 holds split ports.
- Result: 0 movers, 0 rc changes, 0 uhdm-cmp changes.
- r11v105repro/grid/v09_A_nested_program_in_sub exits 139 in both views on BOTH binaries (pre-existing).

## Attack: 19 fresh case dirs in both views (`cases/VC`, `cases/VS`; `evidence/grid_fresh.txt`, 190 lines, every line with rc=)
Each case dir was run on P, L, OFF and each switch off.

Overall:
- OFF equals P on 38 of 38 case-views.
- 36 move: 26 enter STRICT_EQUAL and **0 leave**.
- Each mover returns to P under exactly one switch: CTORRETSPAN 16, STRPORTTS 20.
- rc changes on 0. uhdm-cmp line counts change on 6 case-views, all stage 1 -> 0 (vs01, vs03 and vs10 in both views).
- Chain-keyed away=0 on all 36.
- Downstream (`evidence/downstream_fresh.txt`): every dir has the same verdict on both binaries. 18 are IDENTICAL;
  vs05 is EQUIVALENT on both, pre-existing.

§ ctorRetVarSiblingSpan277. Every class_var record now equals golden's (checked on the dump's class_var lines where
stage 1 hides the records):

| case | shapes | P -> L |
|---|---|---|
| VC/vc01_types | `int unsigned`, `logic signed [3:0]`, `integer`, `pc#(byte)`, `pc #(.T(shortint))`, `string s[]`, `string s[$]`, `ref string`, `output base b` | col -> STRICT_EQUAL |
| VC/vc02_attrs | two attributes, an attribute with a value, attribute + implicit dims, attribute + direction + dims, attribute + bare name | col -> STRICT_EQUAL |
| VC/vc03_nostmt | `new()` and `new` with statements, a `super.new()` body | unchanged (equal on both: the law does not reach an empty formal list) |
| VC/vc04_virt | `input virtual ifc`, a struct typedef, an enum with default, `p::st_t`, `bit [1:0][2:0]` | line -> line; class_var records cleared, 0 away |
| VC/vc05_twohdr | a header included in two packages, a function-like macro formal | col -> STRICT_EQUAL |
| VC/vc06_modoob | a module class with a value parameter, out-of-body constructor, two specializations | stage 1 both; class_var 7:40-41 -> golden 7:26-39 |
| VC/vc07_crlf | CRLF, a multi-line formal, an attribute with implicit dims | line -> STRICT_EQUAL |
| VC/vc08_macro_types | `` input `T ``, `` input `VEC(4) ``, `` `IN `VEC(2) ``, `q::qc::qt`, `q::qc` with default | stage 1 both; all five class_var spans golden's |
| VC/vc09_oob_mismatch | prototype and body spelled differently (direction on one side only, a default on the prototype) | stage 1 both; all three spans golden's (the body's spelling wins, as in golden) |

§ strPortNetTsFromPortDecl277:

| case | shapes | P -> L |
|---|---|---|
| VS/vs01_scalarport_vecnet | `output o;` with `wire (strong1, weak0) [3:0] o` | stage 1 -> STRICT_EQUAL (golden keeps the port's scalar type) |
| VS/vs02_param_two_inst | `[W-1:0]` with two instances W=4 and W=8 | line -> STRICT_EQUAL |
| VS/vs03_nettypes | tri, wor signed, wire supply0/pull1 | stage 1 -> STRICT_EQUAL |
| VS/vs04_multi_decl | two nets in one strength declaration, plus a plain re-declaration | line -> STRICT_EQUAL |
| VS/vs05_portexpr | `.p(o)` port expression next to a plain port | stage 1 both; 4 chain records toward, 0 away |
| VS/vs06_bind_gen | the strength module bound and instantiated in a for-generate | line -> STRICT_EQUAL |
| VS/vs07_dims_order | the net declared before the port, ascending [0:3] | line -> STRICT_EQUAL |
| VS/vs08_inout | an inout port | line -> STRICT_EQUAL |
| VS/vs09_delay | strength plus `#2` and `#(1, 2)` delays | line -> STRICT_EQUAL |
| VS/vs10_trireg_signed | trireg charge strength (small, large), `output signed s` with a signed strength net | stage 1 -> STRICT_EQUAL |

No break was found, so no refinement was written.

## Residues (all wrong on pristine too; none introduced by the laws)
1. A package-qualified formal type's typespec is located at the package declaration. Golden locates it at the use:
   VC/vc04_virt `input p::st_t s` (golden 19:24-31, ours 4:11-43). This is the same face as the implementer's
   C/c03_kinds `input q::t x`.
2. `input virtual ifc vif`: golden's interface_typespec spans `virtual ifc` (7:24-35), ours only `ifc` (7:32-35).
   Seen in VC/vc04_virt; the typespec writer is on this ground.
3. A class-scoped typedef used as a formal type, `input q::qc::qt t`: an unsupported_typespec at uhdm-cmp stage 1
   (VC/vc08_macro_types).
4. A prototype's default-argument constant: VC/vc09_oob_mismatch o3, stage 1.
5. A port-expression module's definition-view net listing: VS/vs05_portexpr, stage 1, downstream EQUIVALENT on both.
6. r11v105repro/grid/v09_A_nested_program_in_sub exits 139 on both binaries.
7. The implementer's own residues still stand:
   - the q2::row_t alias-chain extra level (about 17 probe cases);
   - struct-member typespec full names through import chains (14 or more);
   - class_typespec end columns (9);
   - the interface home of the strength re-declaration (n3_strnonansi_if);
   - Surelog's own `var` and `input signed a` formal faces (C/c09, c10);
   - the brief's items (3) to (7), attempted by neither agent.

## Process notes
- **First grid launch, a broken driver:** while adapting case.sh, a line edit replaced its `GW=$S/g` line. The first
  grid launch on the fresh cases therefore aimed every output at `/<case>`. Every mkdir and redirect there failed with
  permission denied, and nothing was created: `/` holds no such entry, and the main tree and both worktrees are
  unchanged. The driver was repaired and every grid was rerun from scratch.
- **Two stray temp files:** one comparison wrote two temporary files, `/tmp/a` and `/tmp/b`, outside the pass-prefixed
  scratch, and deleted them in the same command. If files of those names existed before, they were overwritten.
- **The fence:**
  - Every corpus database read went through fence-filtered mirrors: byteverify, and the away census on MiniAmiq only.
  - The firing census ran with the $FENCED filter.
  - No fenced source or database was opened, and nothing fenced was dispatched outside the gate sweeps.
  - The cmds.txt binary audit grepped every row's cmds.txt for the binary path, the fenced rows' included. Those are
    command lines, not sources or databases.
- No process was signalled.
- Every tool call through a variable was guarded by `[ -x ]`.
