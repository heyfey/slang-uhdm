# v11u297 — adversarial verification of r11u297 (the data-declaration initializer laws and the nested-definition port phase)

Base f85b3457 (pass 295). Implementer's patch: three laws in ModuleEmit behind `src/R297.h`
(§ varDeclInitMovesSharedTsEnd297 `R11U297_VARINITTSEND_OFF`, § varDeclInitElabSpan297 `R11U297_VARINITSPAN_OFF`,
§ nestedDefPortsNeedShell297 `R11U297_NESTNOSHELL_OFF`; `R11U297_OFF` drops all three).

**VERDICT: VERIFIED, NO PRODUCTION FIX.** Every headline number of the implementer reproduces bit for bit, and
61 fresh case dirs (122 case-views) found no case where pristine was right and the law is wrong. No refinement was
written, so `R11V297_*` stays empty and the verified patch is the implementer's production code unchanged, plus this
directory and the regenerated tests/LAWS.md.

## Reproduction (both binaries built here, frozen read-only at /tmp/v11u297_bin before any measurement)

- pristine `d3fc0099b42d8c498d08d3f19970782f`, the main tree's build and the implementer's; law
  `5169a64e5a38e8dabd7f40d233dc589d`, the implementer's; both link slang 12.0.0+545f88b2e. The patch applies clean on
  a fresh f85b3457 (whitespace warnings only, the CRLF case r11u297repro VI/v37_crlf).
- probe (evidence/sweeps.txt): pristine EQUAL 3952 + 135, regressions 0. Law **EQUAL 3954 + 133, regressions=0
  conversions=2 changes=1**:
  - `r11u32repro/k9b,EQUAL,,equal` (was differ:endline(4))
  - `v11u110repro/brk/v1/b06_const_init,EQUAL,,equal` (was differ:endline(4))
  - `r11u110repro/grid/f2/i16_var_kw_init,STRICT_NOTEQUAL,differ:fullname(5),differ:fullname(5)` (was endline(9)).
  The three are EQUAL / STRICT_EQUAL in both views at uhdm-cmp 0 lines except i16 (fullname in both views).
  The away census (drivers/awaycv.sh) reads lost 0 and chain away 0 on all six case-views, toward 7 / 5 (k9b),
  4 / 3 (b06), 4 / 3 (i16). The positive control (binaries swapped) reads away 7, 4, 4 (evidence/probe_targets.txt).
- probe bytes: exactly 3 of 4087 databases move, the three above (evidence/probe_movers.txt). Both probe sweeps were
  run from the same worktree because the databases carry the source path. The positive control is the pristine sweep
  run from the other worktree, where 4087 of 4087 differ.
- surelog 480 + 0 / 474 + 0 and uhdm2rtlil 803/1/67 in both modes, regressions 0, conversions 0 and changes 0 on both
  binaries. The pristine and law csvs differ only in the LowMemLib / LowMemPkg testflags detail text, which carries the
  workdir name.
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on both binaries. The two csvs are
  byte-identical to each other and to results/downstream_uhdm2rtlil.csv.
- byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) on fence-filtered mirrors (drivers/bvmirror.sh)
  of the surelog, uhdm2rtlil and downstream lanes: **MOVERS 0 / 3365**, identical path sets, SELFCHECK 3363 of 3365
  (the known twin).
- canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both (EXPECT_UNKNOWN=1: ok=58;
  EXPECT_UNKNOWN=6: ok=2).
- binary audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary. The other 50 run no slang: 48
  carry no slang line, and the 2 CoresSweRV rows match "slang" only in a path.
- determinism: three concurrent draws of the law binary (drivers/det.sh) give one hash per row-mode on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen. Each hash equals the law sweep's
  database. Scoreboard and Rggen testflags write none.
- every sweep exited 1 on the law-index check alone, the pristine sweep at the base included.

## Byte controls (drivers/controls.sh, both views, pristine vs law; evidence/controls*.txt)

31 repro dirs: the implementer's 15, widened by r11u118, r11v11u118, r11u120, r11v120, r11u124, r11v124,
r11u131, r11v131, r11u293, v11u293, r11u291, v11u291, r11u130, r11u125, v11u275 and r11u297 itself. That is 2362 case
dirs and 4724 case-views, every line with its exit code.

- **106 moving, 58 entering STRICT_EQUAL, 0 leaving.**
- 26 exit-code changes, all 139 -> 0: r11u297repro NM m01 to m10, r11u295repro NA/n02 and n07, and v11u295repro
  VN/vn02, each in both views.
- On the 80 movers that did not crash before, the away census reads lost 0 and chain away 0, with 389 records toward
  golden. Their uhdm-cmp line counts are unchanged.
- The implementer's own 63-dir grid reproduces: 82 movers in r11u297repro, as reported.
- Beyond the implementer's controls, v11u275repro VV/vv03_var_by_macro and vv04_var_comment_semi go endline ->
  STRICT_EQUAL in both views. These are pass 275's var-detection controls, and the move is toward golden.

## Attack grid (cases/, 61 dirs, 122 case-views; drivers/grid.sh on P, L, OFF and each switch; evidence/grid*.txt)

Each case names its law in its own first line.

- **96 moving, 47 entering STRICT_EQUAL, 0 leaving.** 22 exit codes go 139 -> 0, and OFF equals P in bytes and exit
  code on 122 of 122.
- Restored by one switch alone: VARINITTSEND 22, VARINITSPAN 4, NESTNOSHELL 22. The other 48 are restored only by
  `R11U297_OFF`, because both var laws write on them.
- Away census on the 74 non-crash movers: lost 0 and chain away 0, with 429 records toward golden. The positive
  control (binaries swapped) reads away 4 to 13 on 8 of 8.
- No mover changes its uhdm-cmp line count.
- Downstream: 14 dirs go EQUIVALENT -> IDENTICAL and 10 go SLANG_REJECT -> IDENTICAL. VN/vn09 goes SLANG_REJECT ->
  STATUS_DIFF, and none gets worse; the vn09 cause is below.

### § varDeclInitMovesSharedTsEnd297 cases

| case | pristine (default) | law (both views) |
|---|---|---|
| VA/va01_packed_dim_var (`var t_t [1:0] x = '0`) | stage 1 | unmoved (residue 3) |
| VA/va02_two_init_one_stmt, va03_init_then_noinit_one_stmt, va04_noinit_then_init_one_stmt | endline | STRICT_EQUAL |
| VA/va05_union_var | endline | STRICT_EQUAL |
| VA/va06_alias_td_var, va07_cast_init_enum, va08_func_init | stage 1 | stage 1, toward 1 to 7 |
| VA/va09_two_mods_var_bare, va10_two_mods_bare_var | endline | STRICT_EQUAL |
| VA/va11_two_mods_var_var (multi-line const) | stage 1 | stage 1, toward 9 / 5 |
| VA/va12_tp_override_twice | stage 1 | stage 1, toward 5 / 4 (VARINITTSEND alone) |
| VA/va13_struct_port_and_var | endline | STRICT_EQUAL |
| VA/va14_localparam_shared, va15_iface_modport, va18_pkg_level_var | stage 1 | stage 1, toward 5 to 13 |
| VA/va16_comment_after_init, va17_const_var_both | endline | STRICT_EQUAL |
| VA/va28_two_mods_var_var_order, va29_two_mods_var_var_revinst (writer order) | endline | STRICT_EQUAL |
| VA/va30_pkg_td_var_two_mods | endcol | STRICT_EQUAL |
| VA/va31_scoped_nokw_struct_two (`p::t_t x = ...` with no keyword) | stage 1 / endline | stage 1 toward 9 / STRICT_EQUAL |
| VM/vm01_macro_multiline_init | stage 1 | stage 1, toward 3 / 2 |
| VM/vm02_macro_arg_init | endline | STRICT_EQUAL |
| VM/vm03_hdr_in_two_mods (header included in two modules) | file | STRICT_EQUAL |
| VW/vw09_var_enum_in_iface_twice | endline | STRICT_EQUAL |
| VW/vw10_var_td_packed_signed | stage 1 | stage 1, toward 3 / 2 |

### § varDeclInitElabSpan297 cases

| case | pristine (default) | law (both views) |
|---|---|---|
| VA/va19_static_enum, va23_var_in_nested, va24_nonansi_out_var, va25_var_enum_twice_inst | endline | STRICT_EQUAL |
| VA/va20_multiline_concat, va21_param_dep_init_twice, va22_var_unpacked_struct, va26_var_struct_member_read, va27_var_signed_int_td | stage 1 | stage 1, toward 2 to 6 |
| VW/vw01 (`var [3:0]`), vw02 (`var x`), vw03 (`var bit`), vw04 (`const logic`), vw05 (`output var t_t o = ...`), vw07 (byte, shortint) | stage 1 or STRICT_EQUAL | unmoved |
| VW/vw06_nonansi_port_then_var | stage 1 | stage 1, toward 1 (VARINITSPAN alone) |
| VW/vw08_var_struct_always | endline | STRICT_EQUAL |

### § nestedDefPortsNeedShell297 cases

| case | pristine | law default / elaborated |
|---|---|---|
| VN/vn01_outer_twice_inner_ports | exit 139 | stage 1 / STRICT_EQUAL |
| VN/vn02_outer_twice_param | exit 139 | stage 1 / STRICT_EQUAL |
| VN/vn03_outer_array | exit 139 | depth / depth |
| VN/vn04_outer_genif_twice | exit 139 | stage 1 / stage 1 |
| VN/vn05_inner_uses_iface_port, vn08_two_parents | exit 139 | count / count |
| VN/vn06_inner_internal_var, vn09_inner_positional | exit 139 | stage 1 / stage 1 |
| VN/vn07_inner_inst_filescope, vn11_outer_genfor_ports_wide | exit 139 | STRICT_EQUAL / STRICT_EQUAL |
| VN/vn10_inner_twice_in_outer_twice | exit 139 | depth / depth |
| VN/vn13_inner_positional_once_ctl (control: outer once) | stage 1, STATUS_DIFF downstream | unmoved |
| VS/vs01 to vs05 (interface shapes: top with ports, array in generate, in a generate twice, nested interface instance, parameterized twice) | various | unmoved in bytes |

The VS cases control the early return, which skips the `currentScope = &body` assignment the old path made on a null
shell. All VS cases and the 13 probe cases plus MiniAmiq d/t, where the implementer's census showed the trace
firing on bytes the base already writes, are byte-identical on both binaries.

## Residues, ranked (all wrong on pristine too)

1. The nested-module shapes the crash fix opens:
   - an outer reached a second time elaborates against its second body's definition (r11u297repro NM/m01, m04 and
     n07 at `type`; VN/vn03, vn10 and m05 default at `depth`; vn05 and vn08 at `count`);
   - depth-2 nesting (m02, m03, m08, m09, n02) and the default view of vn01, vn02, vn04 and vn06 are at stage 1.
   The fix is to read the representative body's DefInfo in ModuleEmit emitInstance (implementer's residue 1).
2. A positional connection to a nested module (VN/vn09; the control vn13 with the outer instantiated once reads the
   same on pristine). The slang lane's RTLIL fails in the plugin with ``Module `\inner' referenced in module `\outer'
   in cell `\u_in' is not part of the design``: the ref_module of a positionally connected nested instance carries
   the bare name. Downstream STATUS_DIFF on both binaries wherever pristine writes a database. ModuleEmit, not
   decoded.
3. Data-declaration shapes the laws do not reach:
   - a packed dimension on the declarator (`var t_t [1:0] x = '0`, VA/va01). Surelog's slot still holds the
     initializer while ours writes the packed dimension's end first.
   - the implementer's residues 2 and 3: i16 / v15 fullname, and the stage-1 vector, `var logic`, package-qualified,
     interface struct, type-parameter struct or enum, multi-line, generate, unpacked and class shapes. VA/va06 to
     va08, va11, va14, va15, va18, va20 to va22, va26, va27, VM/vm01 and VW/vw10 sit at stage 1 on both binaries,
     each moved toward golden.
4. The remaining 133-case probe residue, unchanged from the base.

## Process

- Fence: read fail-closed through drivers/env.sh (the FENCED= line of tools/probe/r11u107repro/canaudit.sh) and
  never spelled. Every corpus path list (cmds.txt, mirrors, probe databases) was filtered before any file was opened.
  No fenced source or database was read.
- No other agent's process was listed or signalled. The main tree was not written. Binaries came from
  /tmp/v11u297_bin; scratch was under /tmp/v11u297_*.
- One case written for the grid, VN/vn12_nested_iface_inst (an interface declared inside a module), has no golden:
  Surelog fails on it. It was dropped from the grid and the counts.
- The two pristine probe runs exist because the first pristine sweep ran from the pristine worktree, so its source
  paths differ in length from the law worktree's. The byte comparison uses the rerun from the law worktree.
