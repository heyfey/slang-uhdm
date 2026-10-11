# v11u286 — adversarial verification of r11u286

Base 0d2443e1 (pass 284 on top of pass 287).  The implementer's patch (/tmp/r11u286.patch: five laws in ExprEmit and
StmtEmit behind src/R286.h) was rebuilt, every headline number reproduced bit for bit, and 183 fresh case dirs (366
case-views) were written against it.  **No break on legal SystemVerilog was found: no case-view, probe case, corpus
row or downstream row moves away from golden under the law.**  One refinement was added: it converts six more
shapes inside the abstention of § genProcLvIdxCallSpan286, and it moves no gate database.  The refinement is
§ genLvTrailSelCallWhole286v, switch `R11V286_TRAILSEL_OFF`, in ExprEmit's `rootSelLvPath286`.

The delivered patch, applied with `git apply` on a fresh 0d2443e1 worktree (/tmp/wt_v11u286chk, removed) and built there
from scratch, gives the fix md5 c3c4c1c8... again; `law_index.py --check` reads current there.

Binaries (worktrees /tmp/wt_v11u286pris and /tmp/wt_v11u286, system-deps config, -j 2, frozen `chmod 555` in
/tmp/v11u286_bin before any measurement; evidence/binaries.txt):

| binary | md5 |
|---|---|
| pristine | `7a24e7c63d75dcabb2cf607f9f7e443c` (equal to the main tree's build/slang-uhdm) |
| law | `9bac5d074ea2624a0a6f99c03e95cb99` (equal to the implementer's law binary) |
| fix | `c3c4c1c895216230032959561cfa3b91` (law + § genLvTrailSelCallWhole286v) |

All three report slang 12.0.0+545f88b2e.  The strict comparator is the base's build/uhdm-strictcmp
(fa6e4f42…, equal to the main tree's build).

## Reproduction of the implementer's numbers

Sweeps: `tests/sweep.sh --jobs 3`, all run from /tmp/wt_v11u286 so the probe databases share one path prefix.
Workdirs: /tmp/v11u286_wP (pristine), /tmp/v11u286_wL (law) and /tmp/v11u286_wF (fix).  Each of the three exited 1
on the law-index check alone; tests/LAWS.md is stale at the base too.

- **Probe:** pristine EQUAL 3898 + STRICT_NOTEQUAL 189.  Law and fix both read 3905 + 182 with regressions 0,
  conversions 7 and changes 0.  The seven conversions match the implementer's report by name and first field:

  | case | before | after |
  |---|---|---|
  | r10earl31repro/e4_ctrl | endcol(2) | EQUAL |
  | r10uvm151repro/g151_e_ctx | endcol(2) | EQUAL |
  | r10v151repro/v151_5_ctx | endcol(1) | EQUAL |
  | r11v70repro/v11 | fullname(2) | EQUAL |
  | r11v70repro/v5 | fullname(3) | EQUAL |
  | v11u116repro/arms/f1t_intsig | endcol(4) | EQUAL |
  | v11u116repro/arms/g2_fcall | endcol(4) | EQUAL |

  Each fresh row reads `<case>,EQUAL,,equal`.  The law and fix probe csvs are identical.
- **Surelog corpus:** default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2.  Regressions, conversions and
  changes are 0 on all three binaries.  The csvs are identical row for row except the LowMemLib and LowMemPkg
  testflags SURELOG_FAIL detail text, which embeds the workdir path.
- **uhdm2rtlil corpus:** 803/1/67 in both modes, 0/0/0; the csvs are identical.
- **Downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on all three binaries; the csvs are
  identical.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh on hard-link mirrors made by drivers/mirror.sh; the path list
  is filtered by $FENCED first, so 8 fenced paths are skipped):
  - pristine -> law: PATH_SETS_IDENTICAL 2560, MOVERS 0 / 2560.
  - law -> fix: MOVERS 0 / 2560.
  - SELFCHECK reads 2559 / 2560 both times.  This is pass 201's self-check artefact, not a mover: the negative control
    compares every file against one fixed file (the first path's pristine database), and that path's own pair is
    byte-equal, so the control flags every path but that one.
  - Probe databases: pristine -> law moves 7 of 4087, exactly the seven conversions; law -> fix moves 0.
  - Downstream-lane slang databases: 0 of 805 move, pristine -> law and law -> fix
    (evidence/byteverify_*.txt).
- **Firing census** (drivers/tracecensus.sh under R11U286_TRACE; the harness filter is built from $FENCED):
  - The law's census reads 7 lines, identical to the implementer's frozen predict.txt: the seven probe databases
    and no corpus database (evidence/census.txt).  It ran after my law sweep; the implementer's file was frozen
    before theirs.
  - The fix binary's census was frozen before the fix sweep (evidence/census_fix.txt, md5 in census_fix.md5).  It
    reads the same 7 lines and no TRAILSEL line, predicting 0 law -> fix movers.  0 moved.
- **Canaries:** surelog ok=52 and uhdm2rtlil ok=16, both with changed=0; ctcan2 PASS with EXPECT_UNKNOWN=1 and 6,
  on both the law and fix csvs.
- **Binary audit** (drivers/audit.sh): 3265 of 3315 cmds.txt name each sweep's own binary in all three sweeps.  The
  other 50 run no slang, and 8 fenced paths are skipped by the list filter.
- **Determinism** (drivers/det.sh, three concurrent draws): one hash per row-mode on Earlgrey_0_1, MiniAmiq,
  SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen, for both the law and fix binaries.  Each hash equals the
  same row-mode's database in the binary's own sweep (evidence/determinism*.txt).  Scoreboard testflags and Rggen
  testflags write no database in any run.
- **uhdm-cmp:** 0 lines on all seven conversions (all EQUAL).

## The attack: 183 fresh case dirs, both views (366 case-views, every line with its exit code)

Each dut.sv names its law on its first line.  Goldens come from the pinned Surelog with check_probe's arguments,
cached by content under /tmp/v11u286_gold (drivers/case.sh).  Grid driver: drivers/grid.sh.  Labels: pristine, law,
fix, fix+R11U286_OFF, fix+R11V286_TRAILSEL_OFF and fix with each law's switch (evidence/gridall_*.txt).
Attribution: drivers/attrib.py (evidence/attrib_law.txt, attrib_fix.txt).

| group | law | cases |
|---|---|---|
| VW, VX | § withCallParenSyntax286 | double parentheses, iterator argument as the left operand, call argument, ternary branches, class method, if condition, struct items, `find`, nested with-calls, a macro body, package function, randomize-with (control), `this.` path, fixed array, for condition, multi-line, unparenthesized (control), index, concatenation, inside, assoc array, cast, unary, comparison of two, `item.index`, `min`, function return, always_comb, two on one line |
| VG, VY | § genProcLvIdxCallSpan286 | for/if/case/two-level generate, always_ff, part-select bounds and indexed part-select base (constant slots), plain-root member path, nested and zero-argument calls, `++`/`+=`, concatenation lvalue, child instance at depth 2, package function, `$clog2` (control), gen-local function, named argument, module-body process (control), nonblocking with delay, read-path index (§ 181v), interface body, parenthesized call, operation index, two calls, DPI import, root-selected struct array, task body, case and if statements, call argument with a parameter, unpacked member root, initial nonblocking, loop variable argument, assoc and queue lvalues, interface port path, hierarchical path, genvar root index, root-selected path with a trailing call |
| VQ | § genProcLvIdxCallSpan286 and § genLvTrailSelCallWhole286v | the decode of where the call sits in a member path: plain root with a middle call, middle and trailing calls, root-selected root call, a call at both ends, module-body controls for both, for-generate, three levels, middle call with a constant trailing select, always_ff, trailing operation index |
| VI, VJ | § foldIntTsSignedKwTrim286 | `integer`/`shortint`/`byte`/`longint signed`, `logic`/`bit signed [..]` (not trimmed), negative value, localparam, package parameter, parameter list, comment between the keywords, override, nested for, macro type, interface, `int unsigned` and `int` (controls), part-select bounds, indexed part-select width, replication count, if-generate, case-generate in for, process, extra spaces between the keywords |
| VK, VL | § elabCastKeyBindsDefNet286 | two overrides, instance array, single child, two definitions with the same key, two parameters, instance in if- and for-generate, key named like a port, a net or a parameter, two parents, three levels with two paths, definition after top, header parameter, override by a cast, interleaved definitions, interface, nested struct, module-local and package typedefs |
| VE, VZ | § escBlockNameSpanTrailSpace286 | end label, escaped simple identifier, function, nested, two spaces, generate-block process, task, class method, no space before the name, fork (control), for-generate always_ff, two escaped names on one line, CRLF line ends, plain name (control), escaped generate-block name (ModuleEmit, control), sequential blocks, escaped keyword, long name, macro-written (control), escaped block in an included file, disable, fork's inner begin, final, program, interface |

### Pristine -> law (evidence/attrib_law.txt)

- 232 of 366 case-views move and 160 enter STRICT_EQUAL.
- 0 leave STRICT_EQUAL and 0 exit codes change.  The uhdm-cmp line counts that change all shrink: VW vw02, vw16, vx10,
  vx13 and vx14 go from 45-91 lines to 17, and vw11 goes from 59/63 lines to 0.
- law+R11U286_OFF gives pristine's bytes on 366 of 366 case-views.
- Every mover goes back to pristine under exactly one switch: GENLVCALL 80, INTSIGNTRIM 54, ESCBLKNAME 44,
  CASTKEYDEF 40, WITHPAREN 14.

### Pristine -> fix (evidence/attrib_fix.txt)

- 246 case-views move, 172 enter STRICT_EQUAL and 0 leave.
- fix+R11U286_OFF gives pristine's bytes on 366 of 366.
- fix+R11V286_TRAILSEL_OFF gives the law's bytes on 366 of 366.

### Away-moved census

Chain-keyed: drivers/awaychain.py with strictcmp_x, copied from r11u286repro.

- pristine -> fix: chain away 0 on all 246 movers, 517 records toward golden (evidence/away_pristine_fix.txt).
- law -> fix: chain away 0 on all 14 movers, 1 to 3 records toward each (evidence/away_law_fix.txt).
- The per-batch law censuses read the same (evidence/away_grid*.txt).
- Positive control, with the binaries swapped: chain away 1 to 4 on 21 of 26 sampled movers.  The five zeros are
  records that match golden on neither binary (evidence/away_poscontrol.txt).

### Downstream (drivers/dscases.py; default view)

- Pristine and law on the 170 dirs written before VQ: 157 IDENTICAL on the law binary and 13 EQUIVALENT.
- Two dirs move toward golden: VG/vg14_initial_for and VY/vy13_loop_var_arg go from EQUIVALENT (nohier differs) to
  IDENTICAL.
- No dir moves the other way (evidence/ds_cases_P.txt, ds_cases_L.txt).
- Pristine, law and fix on the 15 refinement dirs (VQ, vg17, vy19): IDENTICAL on all three binaries
  (evidence/ds_cases_trailsel.txt).

### Byte controls (drivers/bytectl.sh)

The controls cover every earlier repro case dir under tools/probe: 451 repro dirs, 23110 case dirs and 46220
case-views.  The path list is built first and filtered by $FENCED before any file is opened.  The implementer's
27-dir control set is a subset.

**Pristine -> law** (evidence/bytectl_pristine_law_summary.txt):

- 16 case-views move and 0 exit codes differ (rc 0 on 45468, 3 on 460, 4 on 278, 139 on 14, identical on both
  binaries).
- 12 of the 16 enter STRICT_EQUAL, 0 leave, chain away 0 on all 16 (evidence/controls_movers.txt).

| case dir (d/e) | before | after | switch |
|---|---|---|---|
| r11u146repro/grid/ck/c2_sub | fullname | STRICT_EQUAL | CASTKEYDEF |
| v11u146repro/cases/ck/k1_twoinst | fullname | STRICT_EQUAL | CASTKEYDEF |
| r11u194verify/cases/G/g02_genvar_call_index | endcol | STRICT_EQUAL | GENLVCALL |
| r11u198repro/cases/L/l13_genscope | endcol | STRICT_EQUAL | GENLVCALL |
| r11u201repro/cases/N/n07 | endcol | STRICT_EQUAL | GENLVCALL |
| v11u187repro/cases/T/t26 | endcol | STRICT_EQUAL | GENLVCALL |
| r11v181repro/cases/lc/c01 | endcol | endcol | GENLVCALL (toward 3) |
| v11u201repro/cases/N/n07_gen_depth | fullname | fullname | GENLVCALL (toward 3) |

**Law -> fix** (evidence/bytectl_law_fix_summary.txt): 0 of 46220 case-views move.

The implementer's own 46 grid dirs (92 case-views) also read 0 law -> fix movers.

## § genLvTrailSelCallWhole286v — `R11V286_TRAILSEL_OFF` (ExprEmit, inside § genProcLvIdxCallSpan286's abstention)

**The abstention was too wide.**  § genProcLvIdxCallSpan286 abstains on every call inside a member-path lvalue whose
root is selected, so golden's name span is kept for `m[fn(1)].v`.  The same abstention also covered a call in the
path's TRAILING element, where golden spans the whole call exactly as on a plain root:

| statement in a generate-scope process | golden | law |
|---|---|---|
| `m[1].v[fn(2)] = ...` (VG/vg17) | 7:24-29 | 7:24-26 |
| `sa[1].f[fn(0)] = ...` (VY/vy19) | whole call | name |
| `m[fn(1)].b[fn(0)] = ...` (VQ/vq04) | second call whole | second call name |

On these shapes the law kept pristine's name span, which was wrong on pristine too.

**The decode, from the VQ cases in a generate scope:**

| shape | golden span |
|---|---|
| `s.arr[fn(1)].b` (plain root, middle call) | whole call |
| `m[fn(1)].b` (selected root, call in the root) | name |
| `ts[1].arr[fn(3)].v` (selected root, middle call; the implementer's GL/g13) | name |
| `m[1].b[fn(0)]` and `ts[1].arr[2].b[fn(0)]` (selected root, call in the trailing element) | whole call |

**The rule:** in a root-selected path, only a call outside the lvalue's trailing element (the right side of its
outermost ScopedName, or the select of an outermost ElementSelectExpression) keeps the name span.

**Results:**

- vg17, vy19, vq04, vq10, vq12 and vq13 enter STRICT_EQUAL in both views.
- vq09 (for-generate) moves endcol -> fullname: the call is now right, and the walk reaches the pre-existing
  `m[i].b` select full-name face.
- Trace tag: `TRAILSEL` (or `TRAILSEL_OFF`).  `R11U286_OFF` and `R11V286_OFF` also drop it.
- No probe or corpus database reaches the path: the law's census lists no `GENLVCALL_ABSTAIN` anywhere.

## Residues (ranked; all wrong on pristine too)

1. **The fold's int_typespec kind for the other integer atoms** (VI/VJ vj01 to vj04, vi01 to vi04).  For
   `integer`, `shortint`, `byte` and `longint signed`, golden's fold typespec is a byte_typespec, shortint_typespec
   and so on, at the trimmed span (vj03: golden `byte_typespec 2:24-28`).  Ours is an int_typespec, now at the same
   trimmed span: the law moved the span toward golden, and the kind keeps the walk at stage 1 on both binaries.
   The writer is ExprEmit `itsL9`, beside § foldIntTsSignedKwTrim286.  This is this ground's next law: it would
   mint the atom's own typespec kind.
2. **A module-body call in the root's select** of a member-path lvalue: `m[fn(1)].b = ...` in a module-level
   always_comb (VQ/vq06).  Golden spans the name, while § procLvIdxCallWholeSpan181 spans the whole call.  The VQ
   decode gives the rule (name span outside the trailing element of a root-selected path), but it is not written
   here because it refines a landed pass-181 law.  No probe case carries it.
3. **A module-level with-iterator name**: `(q.sum(x) with (x + 1))` in a module (vw02, vw16, vx10, vx13, vx14).
   Golden mints an implicit `logic_net work@top.x` for the iterator, leaving 17 uhdm-cmp lines on both binaries
   (the law cleared the other 54-74).  This is a Surelog late-binding mint and is not copied.
4. **A with-iterator `item` full name** (vx01: `a[(q.sum() with (item)) % 4]` names `item` work@top.a.item where
   golden has work@top.item; vx06: inside a cast, golden has no full name).  Both read fullname on both binaries
   and the law does not move them.
5. **The cast-key shapes at stage 1 on both binaries**: module-local typedefs (VK family) and keys named like a port
   or net, or a key value reading a parameter (vl01, vl07, vl12, vl14).  On these, golden types the cast operation
   with a ref_typespec that we leave null; § castNamedPatternConcat70 does not admit them.  Also at stage 1: an
   interface (vl19), a nested struct pattern (vl20) and an override written as a cast (vl17).  vl20 moves 2
   records toward golden.
6. **Generate-scope `bit_select` names in a member path** (vg05, vq02 and vq07: `s.arr[1].b[fn(2)]`, golden
   `work@top.gi.s.arr[1].b[].b`, ours `s.arr[1].b[]`) and the for-generate `m[i].b` select (vq09).  These are
   fullname faces that the calls' spans no longer hide.
7. **The fold typespec reference name inside nested and case generates** (vj13, vj22: golden
   `work@top.a[1].b[1]` / `work@top.g[1].cd`, ours `work@top`).  Strict stage 2, the walk diverging at that record.
8. **Pre-existing stage-1 shapes, untouched**: interface ports and hierarchical lvalues in generate processes (vy16,
   vy17), a gen-local function (vg15), program blocks (vz09), randomize/ternary/nested/`this.` with-calls (vw04,
   vw09, vw12, vw13, vx08), and `P + i` in a for-generate cont_assign, where golden folds the operation (vi01 and
   others; ModuleEmit's fold, the sister's ground).
9. **Two cases not run**: `(q.find with (...)).size()` has no golden (Surelog fails to parse it; dropped), and
   VK vk10 (packed union pattern) and vk12 exited 3 on slang (illegal; dropped).

The implementer's residues stand as reported: t9/n1, m4/m7/a2, WP/w06 (macro), v4_ops, g1/g13 and r11u109.  So do
their sister-ground faces: r11v66 a3_inst66 (ModuleEmit emitCaStructParamSubst55, § caStructParamPatternSubst55),
r11u113 c09/c11 (ModuleEmit emitGenScopes) and r11v46 grid7.

## Process

- **Fence.** Every corpus reader (mirror.sh, audit.sh, bytectl.sh, the probe and downstream byte comparisons,
  tracecensus.sh, det.sh) reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line.  Each
  one builds its path list first and filters it by word boundary before opening any file.  No fenced source,
  database or cmds.txt was read, run or decoded.
- **Guards and processes.** Every tool variable was checked with `[ -x ]` before use.  No other agent's process was
  listed or signalled.  The main tree was not written.
- **Slips.** The first away-census run failed before reading anything because `S` (the record cache) was unset;
  it was rerun with the cache under /tmp/v11u286_s.
- **Census order.** The law census ran after the law sweep (above).  The fix census was frozen before the fix
  sweep.

## Files

- **README.md**
- **cases/**: VW, VX, VG, VY, VQ, VI, VJ, VK, VL, VE, VZ.
- **drivers/**
  - New: grid.sh, awaygrid.sh, attrib.py, bytectl.sh.
  - Copied from r11u286repro: env.sh (VB -> /tmp/v11u286_bin), case.sh (cache /tmp/v11u286_gold), dump.sh,
    strictcmp_x.cpp, cc_x.sh, awaychain.py, awayrows.py, dscases.py, mirror.sh, audit.sh, det.sh, tracecensus.sh.
- **evidence/**
