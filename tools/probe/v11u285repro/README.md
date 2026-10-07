# v11u285 — adversarial verification of r11u285

Verdict: **VERIFIED, no production fix.** Every gate number in tools/probe/r11u285repro/README.md is reproduced bit for
bit on binaries this pass built itself. No fresh case built on legal SV moves a probe case, corpus row or downstream
row away from golden. The four laws stay as delivered: § clsImpCopyTdBindsContainerListing285
(R11U285_CLSIMPTDSHARE_OFF), § impCopyInitHierPathMemberName285 (R11U285_IMPHPNAME_OFF),
§ cloneOwnAggMemberChainName285 (R11U285_CLONEMEMBNAME_OFF) and § cloneMembTdOwnCopy285 (R11U285_CLONEMEMBTYPE_OFF),
with R11U285_OFF dropping all four. The one finding is a census reading on two elaborated-view fresh cases. It is
decoded below as a typespec-identity effect that the patch exposes, not a record the law writes wrong. The other two
changes in this delivery are a fence check added to r11u285repro/drivers/awaydump.py and the regenerated
tests/LAWS.md.

Base 7d3a945f (pass 283). Worktrees /tmp/wt_v11u285 (the implementer's /tmp/r11u285.patch, applied clean) and
/tmp/wt_v11u285pris. Frozen binaries (read-only copies, every measurement below ran on them):

| binary | md5 |
|---|---|
| pristine (7d3a945f) | c4f0de1e125459aeca302e7c20760c55, equal to the brief's pristine |
| law (r11u285) | 5b6de75145584562bbf6a9286aa343c4, equal to the implementer's |

Both binaries report slang 12.0.0+545f88b2e and UHDM 1.87.

## Gates reproduced (evidence/sweep_P.txt, sweep_L.txt)

- tests/sweep.sh --jobs 3, all four stages, run from each worktree with SLANG_UHDM exported:
  - **Probe:** pristine EQUAL 3842 + STRICT_NOTEQUAL 245. Law EQUAL 3849 + STRICT_NOTEQUAL 238, with regressions 0,
    conversions 7 and changes 1, matching the implementer by name:
    - Conversions: r10sd10repro g6_typedef_elem_import and v2_dynarray_struct_typedef, r10sd6repro v3_hier_path, all
      `fullname(2)`; r10uvm198repro g198_a_homes and r10uvm202repro g202_a_kinds, `fullname(4)`; r10uvm207repro
      g207_c_share `fullname(32)` and g207_e_head `fullname(16)`. All now EQUAL.
    - Change: r10uvm207repro g207_h_foreign `fullname(32) -> fullname(16)`.
  - **Surelog:** 478 + 2 / 472 + 2 on both binaries, regressions, conversions and changes all 0. The csvs differ only
    in the LowMemLib and LowMemPkg testflags detail text, which names the workdir.
  - **uhdm2rtlil:** 803/1/67 in both modes on both binaries, 0 / 0 / 0, with byte-identical csvs.
  - **Downstream:** IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0. The law csv is byte-identical to the
    pristine csv and to results/downstream_uhdm2rtlil.csv.
  - The pristine sweep exited 1 on the law-index check alone. The law sweep exited 0, because the patch carries the
    regenerated index.
- **Firing census** (r11u285repro/drivers/tracecensus.sh on the law binary, corpora filtered by $FENCED;
  evidence/predict.txt): 13 lines, byte-identical to the implementer's predict.txt. Slip: this pass ran the census
  after its own gate sweeps. The prediction comes from the trace, not from the sweep, and it matches the frozen file
  of the implementer, who ran it before the law sweep.
- **Byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1; evidence/byteverify_corpus.txt):
  - Corpus, on hard-link mirrors filtered by $FENCED (r11u285repro/drivers/bvmirror.sh, 8 fenced row-mode databases
    left out): 4 of 3365 move, exactly MiniAmiq d/t and SeqDriver d/t with the implementer's hashes.
  - SELFCHECK reads 3363 of 3365. The reference file downstream/1DUnpackedArray/slang.uhdm has a byte-identical
    twin, uhdm2rtlil/testflags/1DUnpackedArray-3af704bd/slang.uhdm (md5 349c99c5 on both), so 3363 is the expected
    count.
  - Probe (evidence/byteverify_probe.txt): 9 of 4087 move, exactly the predicted 9 — the eight targets and
    r10uvm180repro g180_a_kinds, which reads EQUAL on both binaries.
    - The pristine probe stage was rerun from the law worktree, because a database records its source path. A
      comparison across the two worktrees moves every case.
    - That rerun's csv is identical to the pristine sweep's.
- **Away census on the corpus movers** (evidence/corpus_away.txt):
  - MiniAmiq d/t: order-blind lost 0, chain-keyed away 0, toward 363.
  - SeqDriver d/t: order-blind lost 0, chain-keyed away 0, toward 242.
  - Positive control, with the binaries swapped on MiniAmiq default: away 363.
- **Canaries:**
  - canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0.
  - ctcan2: surelog ok=58 with unknown 1, PASS; uhdm2rtlil ok=2 with unknown 6, PASS.
- **Binary-path audit** (cmds.txt lists filtered by $FENCED): 3315 per sweep. 3265 name the sweep's own frozen
  binary, and the other 50 carry no slang line (two of them are CoresSweRV runs whose Surelog line names the repo
  path).
- **Determinism** (r11u285repro/drivers/det.sh, three concurrent draws per row-mode with the law binary;
  evidence/determinism.txt): one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
  BuildUVMPkg and Rggen, each equal to the law sweep's database. Scoreboard and Rggen testflags write no database,
  as at the base.
- **The implementer's grid** (32 case dirs, 64 case-views, rerun with this pass's binaries): identical to
  r11u285repro/evidence/grid.txt in every field but md5, which carries the worktree path.
  - R11U285_OFF gives pristine's bytes on 64 of 64.
  - 50 moving, 24 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 2 uhdm-cmp line-count changes (M/m06 both
    views).
- **Downstream on the implementer's 32 case dirs:** 31 IDENTICAL and 1 EQUIVALENT (C/c10_mod_cls) on both
  binaries.
- **The implementer's byte controls** (the same 23 repro dirs; evidence/controls_reproduced_summary.txt):
  - 2832 case-views: 140 moving, 4 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 0 uhdm-cmp line-count
    changes.
  - The 4 entering: r11u259repro M/m02_pkg_only, r11u265repro B/b01_vd01 in both views, v11u259repro
    VM/vm12_two_pkgs_only.
  - Away census on all 140 movers: order-blind lost 0 and chain-keyed away 0 (evidence/controls_reproduced_away.txt).
  - Exit codes are the same on both binaries: 0 on 2818 case-views, 3 on 8, 4 on 4, 139 on 2 (v11u283repro VB/vb06).

## Widened byte controls (evidence/controls_widened_summary.txt)

The widened set is 1823 case dirs from 29 repro dirs the implementer did not use: r11u243 / v11u243, r11u247 /
v11u247, r11u251 / v11u251, r11u255 / v11u255, r11u257 / v11u257, r11u263 / v11u263, r11u267 / v11u267, r11u269 /
v11u269, r11u271 / v11u271, r11u273 / v11u273, r11u275 / v11u275, r11u277 / v11u277, r11u279 / v11u279, r11u281 /
v11u281 and r11u221verify.

Result: **3646 case-views, 0 moving.** Exit codes are the same on both binaries: 0 on 3614, 4 on 20, 3 on 12.

## Fresh attack (cases/, 55 case dirs, 110 case-views; evidence/grid.txt, grid_summary.txt, grid_away.txt, grid_pairs.txt)

Each case's first line names the law it attacks. drivers/grid.sh runs every case-view on pristine, on the law, on
the law with R11U285_OFF and on the law with each switch off, and every line carries its exit code. The goldens come
from the v1.87 pin.

- **VC (21 cases, § clsImpCopyTdBindsContainerListing285):**
  - vc01_hdr_both: one typedef header included into both the source and the container package.
  - vc02_shadow_same_name: the container declares its own struct of the same name.
  - vc03_alias: a typedef alias.
  - vc04_two_containers: two importing packages.
  - vc05_multidim: a 2-D unpacked array.
  - vc06_nested_struct: a nested struct member.
  - vc07_class_extends: a derived class.
  - vc08_two_vars_types: a packed struct and a queue beside an unpacked struct.
  - vc09_macro_td: a macro-written typedef.
  - vc10_q_uses_t: the container's own variable of the type.
  - vc11_reexport: export p::*.
  - vc12_three_pkgs: three packages.
  - vc13_param_class: a parameterized class.
  - vc14_struct_member_td_elem: an associative index typedef.
  - vc15_union_tagged_ctl: an unpacked union beside a struct.
  - vc16_program_cls: a class in a program; the container is not a package.
  - vc17_const_init: a const pattern initializer.
  - vc18_local_alias: typedef p::t t in the container.
  - vc19_packed_union: a packed union.
  - vc20_iface_cls: a class in an interface.
  - vc21_crlf_dyn: CRLF line endings, with a dynamic array and a queue.
- **VH (13 cases, § impCopyInitHierPathMemberName285):**
  - vh01_bitsel_last: the path ends in a bit select.
  - vh02_partsel_last: the path ends in a part select.
  - vh03_in_call: the path inside $bits / $countones.
  - vh04_concat: a concatenation and a ternary.
  - vh05_qual_root: a package-qualified root.
  - vh06_three_level: a three-level path.
  - vh07_packed_member: a packed root.
  - vh08_two_classes: two classes.
  - vh09_module_import: a module importing the package beside the class copy.
  - vh10_param_root, vh11_op_only, vh12_param_only, vh13_plain_after_param: struct-parameter roots and operations.
- **VM (21 cases, § cloneOwnAggMemberChainName285 and § cloneMembTdOwnCopy285; importer copies of an extern method):**
  - vm01_td_of_td: a typedef of a typedef.
  - vm02_packed2d: a packed 2-D typedef.
  - vm03_third_pkg_td: a third package's typedef.
  - vm04_param_width: a parameter-sized typedef.
  - vm05_str_real_int: string, real and integer typedefs.
  - vm06_unpacked_td: an unpacked-array typedef.
  - vm07_two_locals: two locals.
  - vm08_local_td: a method-local struct typedef.
  - vm09_cls_td: a class-scoped vector typedef.
  - vm10_task_block: an extern task with a block local.
  - vm11_signed_enum: a signed typedef beside an enum member.
  - vm12_union_td: a union.
  - vm13_nested_td: a nested struct.
  - vm14_packed_member: a packed struct member.
  - vm15_two_importers: two importers.
  - vm16_macro_td: a macro typedef.
  - vm17_crlf: CRLF line endings.
  - vm18_hdr_td: an included header.
  - vm19_loop_block: a for-loop block local.
  - vm20_two_structs: two structs sharing one member typedef.
  - vm21_macro_member: a member declared through a macro argument.

Results:

- R11U285_OFF gives pristine's bytes on **110 of 110**.
- **96 moving, 28 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 0 uhdm-cmp line-count changes.** Exit
  code 0 on every line.
- Attribution:
  - Single switches: VC movers to CLSIMPTDSHARE; vh03 / vh04 / vh06 / vh07 to IMPHPNAME; vm01 and vm13 to
    CLONEMEMBNAME; vm10 and vm19 to CLONEMEMBTYPE.
  - Pairs (drivers/pairs.sh): vh08, vh09, vh10 and vh13 need CLSIMPTDSHARE + IMPHPNAME; every other VM mover needs
    CLONEMEMBNAME + CLONEMEMBTYPE.
  - vh01 and vh05 return to pristine under CLSIMPTDSHARE alone.
- Away census (r11u285repro/drivers/awaycv.sh): order-blind lost 0 and chain-keyed away 0 on **94 of 96**. The two
  exceptions are explained in the next section. Positive control, with the binaries swapped: VC/vc02 away 1,
  VM/vm07 away 24.
- Downstream (drivers/ds.py, the HEAD harness's one(); evidence/downstream_cases.txt): 51 IDENTICAL and 4 EQUIVALENT
  on both binaries, with no verdict moving. The 4 EQUIVALENT are vh09_module_import, vm10_task_block,
  vm19_loop_block and vc20_iface_cls. The 174 RTLIL and netlist files of the first 44 dirs are byte-identical
  between the binaries.
- The first draft of vm10 called a task from a function. That is illegal SV, and every binary exited 3 on it. The
  case was rewritten so the importer calls the task from a task; only the rewritten version is gridded.

## The finding: the elaborated view with a struct parameter in the source package (VH/vh10_el, vh13_el)

- **The readings.** vh13_plain_after_param_el reads order-blind lost 3 and chain-keyed away 2. vh10_param_root_el
  reads chain-keyed away 4 with flat away 0. Both cases are `package p; typedef struct {int f;} s_t; parameter s_t
  P = ...; s_t st; int e = st.f;` imported by a package holding a class. Both stay STRICT_NOTEQUAL:
  - vh13 moves from `fullname` at record #138 (5 objects differing) to `depth` at #161 (1 object differing).
  - vh10 stays at stage 1.
  - The default views read away 0.
  - The censuses return to 0 with R11U285_CLSIMPTDSHARE_OFF.
- **Decode** (drivers/objinfo2.cpp prints what each reference binds; evidence/vh13_identity_decode.txt):
  - Golden: the class copy `st` binds the container's listing struct (#4). Its initializer's `ref_obj f` binds that
    listing's member (#6). The class's parameter copy `P` binds a private struct copy (#122), parented at its
    param_assign.
  - Pristine: `st` binds a private clone (#116) and `f` that clone's member (#117), while `P` binds the listing
    (#40).
  - Law: `st` -> #40 and `f` -> #41, golden's identity. `P` still binds the listing #40.
- **Why the records go missing.** `ref_obj f` now reaches the listing's member outside any typespec subtree. The
  comparator's canonical walk re-expands a typespec at every reference, but it leaves visited an object first met
  outside such a subtree. So when the walk reaches `P`'s struct, it lists the struct without member `f`. Golden
  lists that member because its `P` struct is a separate object.
- **Assessment.** No record the law writes differs from golden. The records the census counts as lost exist in the
  law's database and are hidden by visit order.
- **The fix belongs to another face, not to this patch.** ModuleEmit importParamCopy82 (§ classImportParamStamped82
  with § classImportParamOwnRefs183) keeps the class's parameter copy pointing at the shared listing ("the typespec
  itself stays shared"), where golden clones it. A refinement that made law 1 abstain would restore the three hidden
  records. It would also give up the class copy's golden identity and the toward records in both views, so none was
  made. It is listed first among the residues.

## Residues (ranked; all wrong on pristine too)

1. The class import parameter copy's private struct (decoded above). Golden gives `P` in the class its own clone
   of the struct, shared between the class's parameter and its param_assign Lhs; ours shares the container listing.
   - Site: ModuleEmit importParamCopy82 / importPaCopy82.
   - Cases: VH/vh10_param_root and vh13_plain_after_param in the elaborated view, and the implementer's H/h05_el,
     whose chain away 1 has the same visit-order cause.
2. Law 1's open shapes, at stage 1 on both binaries though moved toward golden:
   - vc03_alias: a typedef alias.
   - vc04_two_containers: two containers.
   - vc05_multidim: a 2-D array, no byte move.
   - vc08_two_vars_types: a packed struct beside a queue.
   - vc11_reexport: export.
   - vc12_three_pkgs: three packages.
   - vc13_param_class: a parameterized class.
   - vc14_struct_member_td_elem: an associative index typedef.
   - vc15_union_tagged_ctl: an unpacked union.
   - vc17_const_init: a const pattern initializer.
   - vc01_hdr_both: reads `file` on both binaries.
   - Not reached by law 1: vc16_program_cls, vc19_packed_union and vc20_iface_cls, at stage 1 on both binaries
     with no byte move.
3. Law 2's open shapes:
   - vh01_bitsel_last: the last path element is a bit select, which law 2 does not rename. It moves toward golden
     under law 1 and stays at `fullname`.
   - vh02_partsel_last: unmoved, at stage 1.
   - vh03, vh04, vh05, vh06, vh07, vh09, vh10, vh11 and vh12: stage 1 on both binaries.
4. Laws 3 and 4's open shapes:
   - Every package-function importer copy reads stage 1 on both binaries (vm01 to vm06, vm10, vm11, vm12, vm19),
     although each moves 4 to 28 records toward golden.
   - vm13_nested_td: a member of a nested struct stays at `fullname`.
   - vm14_packed_member: a packed struct member stays at `fullname`.
   - vm18_hdr_td: an included header reads `file`.
   - Not reached by laws 3 and 4: vm08_local_td (a method-local struct typedef) and vm09_cls_td (a class-scoped
     vector typedef as the member type), at stage 1 on both binaries with no byte move.
5. The implementer's residues stand as written in tools/probe/r11u285repro/README.md:
   - g207_h_foreign, the third-package struct;
   - C/c10, c12, c16, c05, c06 and c14;
   - M/m10;
   - the base classification of the remaining 238 probe cases, and items (2) to (7) of the brief.

## Process

- **Fence.** Every corpus path list (the mirrors, the cmds.txt audit, the census filter) was filtered by $FENCED,
  read fail-closed from tools/probe/r11u107repro/canaudit.sh, before any file was opened. No fenced source or
  database was read or dispatched outside the gate sweeps.
- **Fence checks in helpers.** Every helper added here reads $FENCED fail-closed (grid.sh and pairs.sh through
  r11u285repro's env.sh and case.sh, plus ds.py, keys.py and objinfo2.cpp). The implementer's
  r11u285repro/drivers/awaydump.py opened databases with no fence check; this delivery adds one (it refuses with
  $FENCED unset and refuses a fenced path).
- **This pass's slip.** A background waiter for the fresh grid used `pgrep -f` with a pattern contained in its own
  command line, so it could never exit. It was stopped by its own task id, nothing was signalled, and grid
  completion was read from the line count instead.
- No process of another agent was listed or signalled. Every tool variable was checked with `[ -x ]` before use.
  Nothing was written to the main tree.
- **Integration note.** The main tree has moved to 8b0e9bffd (pass 280). The src hunks apply there; tests/LAWS.md
  must be regenerated with scripts/law_index.py at integration.
