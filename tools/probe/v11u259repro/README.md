# v11u259: adversarial verification of r11u259 (pass 259, the module/type ground)

Base 73c55030 (pass 257). Implementer's patch /tmp/r11u259.patch applied clean on a fresh worktree. Verdict: **the
patch stands as delivered; no production fix.** No fresh case, control, probe case or corpus row moved away from
golden on legal SV. The only additions are this directory and the regenerated `tests/LAWS.md`.

## Builds

| binary | md5 | note |
|---|---|---|
| pristine | 8e370bc04400b7a764570b16132e2edd | equal to the main tree's build/slang-uhdm |
| law | ec23b976885a6c2ae45e4188c8c45cd8 | equal to the implementer's |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 | the same in both worktrees and the main tree |

Both binaries report slang 12.0.0+545f88b2e. They were frozen read-only under scratch before any measurement.
Binary-path audit, over fence-filtered cmds.txt path lists: 3265 of 3315 per sweep name that sweep's own binary,
and 0 name the other. The remaining 50 rows never dispatch slang.

## Targeted rows (reproduced)

| row-mode | pristine sweep | law sweep | first record under the law |
|---|---|---|---|
| MiniAmiq default | `STRICT_NOTEQUAL,differ:fullname(5)` | `MiniAmiq,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | #121302 |
| MiniAmiq testflags | `differ:fullname(5)` | `MiniAmiq,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | #121302 |
| SeqDriver default | `differ:fullname(5)` | `SeqDriver,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | #121260 |
| SeqDriver testflags | `differ:fullname(5)` | `SeqDriver,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` | **#121272** |

The implementer's report gives #121260 for SeqDriver in both modes. The testflags record is #121272; it is the
same face (evidence/rowheads.txt).

The new head is golden `struct_typespec uvm_pkg::uvm_reg_map_addr_range` at uvm_reg_model.svh 408:9-412:4, where
ours has `unsupported_typespec range` at uvm_reg_map.svh 825:50-55. That is the struct-index foreach in a copy, at
StmtEmit § cloneLoopVarHomeObject183. It is sister ground (residue 1).

No corpus row converts. The cleared heads, as reproduced from the pristine sweep:

- MiniAmiq #95125: golden `work@svaunit_vpi_interface.uvm_pkg::uvm_hdl_path_slice.path`, ours
  `uvm_pkg::uvm_pkg::uvm_hdl_path_slice::path`.
- SeqDriver #95083: golden `work@top_tb.uvm_pkg::uvm_hdl_path_slice.path`, ours the same package name.
- The `uvm_reg_addr_t` alias name: MiniAmiq #116544 and SeqDriver #116502.

**Each law alone, on the corpus movers** (harness runs, evidence/switches_corpus.txt):

| configuration | MiniAmiq d/t | SeqDriver d/t | bytes |
|---|---|---|---|
| `R11U259_OFF` | fullname(5) | fullname(5) | pristine's on all four |
| `R11U259_IMPLISTMEMB_OFF` | fullname(4) | fullname(4) | |
| `R11U259_LVHOMETS_OFF` | name(2) | name(2) | |

So the member law clears the five #95xxx records and the loop-variable law clears #116544 / #116502. Both are
needed for type(1).

## The laws checked

- **§ cloneMemberImporterListing259** (UhdmExporter, the member-path loop of § cloneAggMemberOwn241's drain;
  `R11U259_IMPLISTMEMB_OFF`).
- **§ cloneLoopVarHomeDeclTs259** (TypeEmit importCloneBareTdAlias16's listener plus the apply step at the head of
  UhdmExporter finish241; `R11U259_LVHOMETS_OFF`).
- **§ tpRebindIdOrder259** (UhdmExporter rebindTypeParamElem107; `R11U259_TP107ORDER_OFF`).
- `R11U259_OFF` drops all three.

Code read: the member law fires only when all of these hold:

- the member's struct or union is not owned by a subroutine;
- the root variable is not owned by the copy;
- the copy's parent is a package;
- exactly one same-named, same-kind typedef in that package's listing has exactly one member of that name.

The loop-variable law reads the home declaration's ref at the end of the export and binds it only when every home
view binds the same object. The order law sorts by UhdmId only when its switch is on; otherwise it keeps the map
order.

## Gates (reproduced bit for bit)

Pristine sweep, from the pristine worktree:

- probe: `EQUAL=3557 STRICT_NOTEQUAL=530`.
- surelog and uhdm2rtlil: the baseline, with `regressions=0 conversions=0 changes=0` in all three stages.

Law sweep, from the law worktree (evidence/gates.txt):

1. **probe**: `EQUAL=3558 STRICT_NOTEQUAL=529`, `regressions=0 conversions=1 changes=5` (evidence/probe_csv_diff.txt):
   - CONVERSION `r10uvm180repro/g180_a_kinds,EQUAL,,equal` (was `differ:fullname(1)`).
   - g207_e_head fullname(32) -> (16).
   - g207_h_foreign (41) -> (32).
   - v208_f_io name(7) -> (3).
   - v181_h_nofe fullname(2) -> depth(1).
   - g207_c_share fullname(16) -> (32). Checked: the first record #152 is unchanged. Pristine's walk diverged
     (objects 1165 vs 1198; type, name, line and col fields differing). The law's walk has equal object counts,
     and every differing record is an identity-derived raw full name (`fields: fullname=32`). The record away
     census reads dist 40 -> 0, lost 0.
2. **surelog**: `regressions=0 conversions=0 changes=4`, exactly the four rows above. Every other row is identical,
   apart from the LowMem SURELOG_FAIL detail text, which embeds the workdir. **uhdm2rtlil**:
   `regressions=0 conversions=0 changes=0`, 1606 of 1606; the csv diff is empty.
3. **downstream**: `EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 (of 871)`, with a verdict diff of 0 rows against
   results/downstream_uhdm2rtlil.csv. No row was targeted.
4. **uhdm-cmp**: rc 0 with 0 lines on all four corpus movers.
5. **byteverify** (fence-filtered hard-link mirrors of both sweeps, same-length names; evidence/byteverify_corpus.txt):
   - 2560 databases, 8 fenced paths skipped, PATH_SETS_IDENTICAL.
   - MOVERS 4 / 2560: MiniAmiq d/t and SeqDriver d/t.
   - SELFCHECK flags 2559 of 2560.
   - Earlgrey_0_1 has the same hashes on both binaries (42cbd61b21c6 / 569e14fc50ea).
6. **Probe byte movers**: the pristine probe stage was rerun from the law worktree, so both runs embed one source
   path. Exactly 6 of 4087 move: the six content-law predictions, which also serve as the positive control. The
   four § tpRebindIdOrder259 firings move no byte.
7. **Canaries**:
   - surelog: ok=50 changed=2 (the targeted SeqDriver d/t rows).
   - uhdm2rtlil: ok=16 changed=0.
   - ctcan2 surelog (EXPECT_UNKNOWN=1): ok=58 changed=0, PASS.
   - ctcan2 uhdm2rtlil (EXPECT_UNKNOWN=6): ok=2 changed=0, PASS.
8. **Law index**: the implementer's patch alone reads `law index current` on a fresh 73c55030. With this
   directory added, `tests/LAWS.md` is regenerated in this delivery. The law sweep's `rc=1` came only from the
   index going stale while these cases were uncommitted. Every stage reads regressions=0.

## Prediction (frozen before the law sweep)

drivers/tracecensus.sh ran the law binary under `R11U259_TRACE` over the probe cases and both corpora in both
modes. Its filter was built from `$FENCED`, and its output was frozen before the law sweep started
(evidence/predict_frozen.txt). It names 14 databases, identical line for line to the implementer's frozen
prediction:

- the 4 corpus row-modes;
- the 6 probe content-law firings;
- 4 probe § tpRebindIdOrder259 firings, predicted not to move.

Every byte mover, corpus and probe, is named there. Nothing unpredicted moved.

## Away censuses

- **Corpus, chain-keyed** (drivers/awaychain.py with strictcmp_x):
  - MiniAmiq d/t: away=0, toward=636.
  - SeqDriver d/t: away=0, toward=425.
- **Corpus, flat**: 14 and 3 records lost (away.py: 15 and 3). Every one is in the `uvm_reg_addr_t` bit_typespec
  subtree whose object identity moved: `uvm_pkg::uvm_reg_addr_t` at uvm_reg_model.svh 73:10-31, its range and its
  constants (evidence/away_corpus.txt). This matches the implementer's account.
- **Probe movers** (evidence/probe_movers.txt):
  - g180_a_kinds, g207_c_share, g207_e_head, g207_h_foreign and v181_h_nofe: 0 lost.
  - v181 dist 7 -> 12. Its walk diverges at #596 on both binaries, and the 6 surplus records are the importer
    listing's `onager` member subtree, now reached through the reference golden also uses.
  - v208_f_io lost=2 by multiset. Positionally, the law's 3 differing records (#738, #1011, #1294) are
    byte-identical to 3 of pristine's 7, so no record left golden. The multiset loss is order-blind reassignment.

## Byte controls

The implementer's 19 dirs, rerun (evidence/controls_summary.txt), cover 2304 case-views:

- 12 moving, 3 entering STRICT_EQUAL (r11u241 CF/e04, CF/e07, r11u252 decode/M/m01), 0 leaving.
- No exit-code changes and no uhdm-cmp line-count changes.
- Away census: 0 lost on every mover.

Widened by 10 dirs: v11u251, v11u249, v11u247, v11u245, v11u243, v11u241, r11u239, v11u239, r11u237 and v11u237.
These add 1288 case-views (evidence/controls_wide_summary.txt):

- 8 moving, all v11u241 AG: g02, g05, g09, g13 in both views.
- 2 entering STRICT_EQUAL (g05, g09), 0 leaving.
- No exit-code or uhdm-cmp line-count changes.
- Away census: 0 lost on all 8 (evidence/away_controls.txt).

The implementer's grid, rerun: 54 case-views × 6 configurations, 324 lines, every one `rc=0`. Its gridsum is
identical to the implementer's evidence/gridsum.txt line for line: 38 moving, 8 entering, `R11U259_OFF` pristine on
54 of 54 (evidence/gridsum_r11u259_rerun.txt).

## Attack grid: 35 fresh cases, both views, 6 configurations

That is 420 lines, every one `rc=0` (evidence/grid.txt, gridsum.txt):

- 70 case-views: 52 moving, 8 entering STRICT_EQUAL, **0 leaving**.
- No uhdm-cmp line count changes.
- `R11U259_OFF` gives pristine bytes on 70 of 70.
- Each mover is moved by exactly one switch, its own law's: VM by IMPLISTMEMB, VL by LVHOMETS.

Away census over all 52 movers (evidence/away_grid.txt):

- 0 lost on 46.
- The other 6 are stage-1 dump-line multisets: vl01 and vl09 in both views (lost=2), and vl12 in both views
  (lost=1).
  - vl01 and vl09 are tail print positions. With the law, the declaration copy is visited earlier, so its full
    text prints earlier.
  - In vl12, golden's `p::f::i` binds `bit_typespec addr_t 4:41`, exactly the law's binding. The lost 3:11 line is
    an order-blind reassignment.

Downstream on all 35 cases, on both binaries: the same verdict on every case. 34 are IDENTICAL and vm01 is
EQUIVALENT on both (evidence/downstream_cases.txt).

### VM: § cloneMemberImporterListing259

| case | shape | pristine -> law |
|---|---|---|
| vm01_pkgvar_root | root a package variable | stage 1 both, no fire |
| vm02_local_shadow_td | the importer declares its own `slice_t` | d fullname -> STRICT_EQUAL; el name #52 same |
| vm03_export_chain | p -> q -> r export chain | stage 1 both, moves, away 0 |
| vm04_nested_anon | nested anonymous struct, plus an unrelated anonymous struct var in the importer | stage 1 both, one firing (the named `inner` member), dump identical, away 0 |
| vm05_nested_named | nested named struct | d #125 -> #135 fullname, away 0 |
| vm06_explicit_item | explicit `import p::slice_t; import p::f;` | no fire (stage 1 / el name both) |
| vm07_two_importer_pkgs_iface | q, q2 and a module | d -> STRICT_EQUAL |
| vm08_packed_synth | packed struct, a module calling f | d -> STRICT_EQUAL; downstream IDENTICAL on both |
| vm09_member_in_foreach_body | for body and if condition | d -> STRICT_EQUAL |
| vm10_task_lhs_iface_prog | task writing members, program last importer | stage 1 both, away 0 |
| vm11_module_imports_importer | a module imports q only | d -> STRICT_EQUAL |
| vm12_two_pkgs_only | q and q2, no other importer | d #74 -> #158 fullname (the m02 face), away 0 |
| vm13_td_from_third_pkg | typedef from r that p imports | no fire (abstains) |
| vm14_array_elem_member | `arr[1].path` | no fire |
| vm15_packed_union | packed union, a module last importer | stage 1 both, away 0 |
| vm16_two_members_two_types | two struct typedefs read in one function | d -> STRICT_EQUAL |
| vm17_crlf | m01 shape with CRLF line ends | d -> STRICT_EQUAL |
| vm18_macro_body | member read inside a macro body | d -> STRICT_EQUAL |

In every VM elaborated view the first record is unchanged (the implementer's residue 3).

### VL: § cloneLoopVarHomeDeclTs259

| case | shape | pristine -> law |
|---|---|---|
| vl01_two_dim | `foreach (addr[i, j])` over `addr_t addr[][]` | stage 1 both, dist 38 -> 25 |
| vl02_assoc_td_index | `addr_t m[addr_t]` | line #91 -> #152, dist 5 -> 1 |
| vl03_assoc_int_elem_td_index | `int m[addr_t]` | STRICT_EQUAL both, no move |
| vl04_qualified_formal | `ref p::addr_t addr[]` | stage 1 both, dist unchanged, away 0 |
| vl05_td_from_other_pkg | typedef from a third package | line #89 -> #155 |
| vl06_local_shadows_formal_name | formal plus a nested-block local of another typedef | line #129 -> #285 |
| vl07_two_foreach_same_var | two foreach loops over the same formal | line #96 -> #180 |
| vl08_class_method_inline | in-body class method, class-property array | STRICT_EQUAL both, no move |
| vl09_vector_td_queue_task | `logic [7:0]` typedef queue in a task | stage 1 both, dist 33 -> 21 |
| vl10_fixed_local_synth | fixed local array, a module calling f | stage 1 both, no move; downstream IDENTICAL |
| vl11_block_local_shadows_formal | a nested-block local of the same typedef shadowing the formal of the same name | STRICT_EQUAL both, no move |
| vl12_local_and_formal_same_td | function-level local plus formal | stage 1, golden's `p::f::i` binding reached |
| vl13_two_classes_same_method | two classes, same out-of-body method name | line #113 -> #232, dist 10 -> 2 |
| vl14_formal_in_macro | whole function inside a macro body | line #82 -> #141 |
| vl15_included_header | function in a header the package includes | file #83 -> #142 |
| vl16_crlf | l01 with CRLF line ends | line #82 -> #141 |
| vl17_two_files | two files, an importer with its own formal at the same position | stage 1 both, no fire |

## Determinism (evidence/determinism.txt)

- **Corpus rows**: three concurrent harness draws per row-mode of the law binary on Earlgrey_0_1 and the five UVM
  rows give one hash each. Scoreboard testflags has no database, as at the base. Nine more concurrent draws on
  MiniAmiq and SeqDriver in both modes give one hash each, 12 of 12 per row-mode. These hashes equal the law
  sweep's.
- **Cases**: ten concurrent draws per view of the law binary give one hash on every case listed:
  - the four § tpRebindIdOrder259 probe cases;
  - r11u259 T t01, t02, M/m08 and L/l07;
  - VM vm07 and VL vl07.

## Residues, ranked

1. **MiniAmiq / SeqDriver #121302 / #121260 / #121272**, the struct-index foreach loop variable in a copy. Sister
   ground: StmtEmit § cloneLoopVarHomeObject183.
2. **Package-only importers** (r11u259 M/m02, VM vm12): the copy's second struct copy shares the home members.
   § cloneAggLocalOwnCopy241 skips a copy bound to the home listing object.
3. **The elaborated view of every member case**: the shared-member `name` record at the head. Wrong on pristine
   too.
4. **The home body's own foreach variable**: it binds the listing copy where golden binds the declaration's copy
   (r11u259 L l01, l03 to l05).
5. **Abstentions with stage 1 on both binaries**: the explicit import (vm06), a typedef from a third package
   (vm13), an array-element member (vm14) and a package-variable root (vm01).
   - vm01 is stage 1 on both binaries. Probe v181_h_nofe shows golden re-binding a package-variable root to the
     importer listing, which the law already does there.
6. **Determinism by construction**: `drainClassNestedTdGroups54`'s `grp54` still mints in key-pointer order. It
   was left unchanged and no draw has shown it.
7. **The brief's items (2) to (5) and (7)**: not attempted by the implementer. Item (6) is moot: HierPathTypespec
   d/t and InterfArrayBind d/t read `CMP_EQUAL ... equal` at the base.

Sister-ground faces, unchanged by this pass (the predictor names none of them, and byteverify moves none):

- BuildUVMPkg #194627: ExprEmit § shellCallKeepsItsSyntax167.
- Earlgrey #154375 / #165002: ExprEmit § selFold9.
- Earlgrey #136315 / #137760: ExprEmit § sysFuncArgFold.
- Rggen #27671: ExprEmit § selChainElemShapeIsSyntactic147.
- BlackBePipeInt #331795: ParamEmit, the import-copy Rhs.

## Process

**The verifier's slips:**

1. While retargeting the copied case.sh, a line-number `sed` ran after a header line had been inserted, so it
   overwrote the `GW=$S/g` line instead of the `rel=` line. The first pristine run of the fresh cases then had an
   empty golden root. Every `mkdir` and redirect into `/` failed, and neither Surelog nor slang-uhdm ran. No file
   was written: `/` and the case dirs were checked, and the main tree's porcelain is clean. The line was restored
   and the run repeated.
2. The first binary-path audit ran `grep -l` over every cmds.txt of both sweeps before filtering the path list by
   `$FENCED`. It read the harness command records of the fenced rows, never a source or a database, and printed
   only counts. It was redone with the path list filtered first; those are the numbers above.

The fence held otherwise:

- Nothing fenced was dispatched outside the gate sweeps. The firing census ran with the `$FENCED` filter.
- Every other corpus scan (bvmirror, the probe mover cmp, rowhead, awaycorp) filtered its path list first.
- No process was listed or signalled.

## Files

- `cases/VM` (18, § cloneMemberImporterListing259) and `cases/VL` (17, § cloneLoopVarHomeDeclTs259). Every case's
  first line names its law.
- `drivers/`: r11u259's drivers, retargeted to this directory.
- `evidence/`: grid, gridsum, away (grid, controls, corpus), controls summaries, byteverify, frozen prediction,
  probe movers, row heads, determinism, per-switch corpus runs, gates, csv diffs and downstream cases.
