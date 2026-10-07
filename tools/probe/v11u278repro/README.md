# v11u278 — adversarial verification of r11u278 (pass 278, the expression/parameter ground)

Verifier of pass 278 (pair A), base b7d287dcf. **Verdict: ACCEPT WITH ONE FIX.** Every headline number of the
implementer reproduces bit for bit. Fresh cases found one break of § ifaceElabTypeParamIsDefObj278 on legal SV
(strict records moving AWAY from golden where pristine had them, chain-keyed away 4 to 8 on 8 case-views, stage 1
on both binaries so no gate saw it). The fix is one refinement behind its own switch,
**§ ifaceTpOvrTpRefAbstain278v** (`src/ParamEmit.cpp`, `R11V278_OVRTPREF_OFF`; `R11V278_OFF` drops it and gives the
law's bytes, `R11U278_OFF` still gives pristine's). On every gate database the fix binary is byte-identical to the
law binary, as predicted by the frozen firing census (0 of 2560 corpus, 0 of 4087 probe, 0 of 805 downstream).

Binaries (built here with the system-deps cmake config, `-j 2`, frozen `chmod 555` before any measurement):

| binary | md5 | note |
|---|---|---|
| pristine | 11861a824c30d2f1e1ea7745b57c9363 | equal to the main tree's `build/slang-uhdm` |
| law (r11u278 patch) | 91d3c653a338aa724023a2c9ae8f0abd | equal to the implementer's `law.bin` |
| fix (this delivery) | 8cf3443a0b860bf06ddcecff157d7d94 | law + § ifaceTpOvrTpRefAbstain278v |

## Reproduction of the implementer's numbers

- **Probe** (law sweep): EQUAL 3814 + STRICT_NOTEQUAL 273, regressions 0, the same **eleven conversions** and four
  changes by name (r10earl29repro a1_hp2 / a2_hp1 / b2_kinds; r10v201repro/v201_k_neg; r11u45repro/g9;
  r11v45repro/v2; r11u20repro/t6; r11u47repro/arms/g9; r11v47repro/arms/v7; r11v53repro/grid/x10_iface_import_shadow;
  v11u113repro/grid/f2/t03_iface_tp; changes r10uvm92repro/v92_b2_varsel fullname(21) -> col(2),
  r11u107repro/grid/t13_iface_tp_struct fullname(13) -> (11), r11u18repro/t4 line(6) -> line(2),
  r11v47repro/arms/v12 fullname(4) -> fullname(21)). Pristine sweep: 3803 + 284, 0 changes.
- **Surelog** 478 + 2 / 472 + 2, **uhdm2rtlil** 803/1/67 both modes, regressions, conversions and changes 0 on
  every binary; the surelog csv differs from pristine's only in the LowMemLib / LowMemPkg detail text (the workdir
  path); the uhdm2rtlil csv byte-identical to pristine's.
- **Downstream** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT on pristine, law and fix, every csv
  byte-identical to `results/downstream_uhdm2rtlil.csv`.
- **Byteverify** (fence-filtered mirrors, drivers/bvmirror.sh; evidence/byteverify_*.txt): law vs pristine 0 of 2560
  corpus databases, 16 of 4087 probe databases (exactly the 16 lines of the census, r11u45repro/g13 the sixteenth,
  its verdict unchanged), 0 of 805 downstream databases. The probe comparison uses a pristine probe stage rerun from
  the law worktree (`/tmp/v11u278_swQ`): probe databases embed the case path, so a pristine run from the pristine
  worktree differs on every database. **SELFCHECK reads 2559 of 2560**: the negative control compares every patched
  file against ONE fixed pristine file, and the one path that IS that file's own counterpart is byte-identical to
  it, so na - 1 flagged is the expected reading of a working comparator, not a mover.
- **Firing census** (drivers/tracecensus.sh, the harness filter built from `$FENCED`, run with the FIX binary
  before its sweep; evidence/predict.txt, md5 in predict.md5): 16 lines, all probe, identical line for line to the
  implementer's; no `IFACETP abstain ovr-tp-ref` line anywhere, so the fix was predicted to move nothing against the
  law on the gate. A positive control of the trace: the fix on cases/VI/vi14 writes `IFACETP abstain ovr-tp-ref U`.
- **Grid** (the implementer's 99 dirs, 198 case-views, 1386 lines, rerun here with drivers/grid.sh): identical in
  every verdict, rc and cmp field; 156 moving, 116 entering STRICT_EQUAL, 0 leaving, R11U278_OFF = pristine on 198 of
  198, attribution TRAILVARSEL 50, PKGQUALRHS 46, BODYCHAIN 26, IFACETP 32, T/t09 needing two switches. (Database
  md5s differ from the implementer's file because the case paths differ.) The fix gives the law's bytes on all 198.
- **Away census** on the law's 16 probe movers (awaychain.py, chain-keyed): away 0 on every one, toward 2 to 48
  (evidence/away_probe_law.txt).
- **Downstream on the implementer's 99 dirs**: T/t12 and T/t17 STATUS_DIFF -> IDENTICAL, every other verdict
  unchanged (85 IDENTICAL, 11 EQUIVALENT, 1 DIVERGENT, 2 STATUS_DIFF on the fix binary).
- Canaries (fix sweep): surelog ok=52, uhdm2rtlil ok=16, both ctcan2 checks PASS. Binary-path audit over the
  fence-filtered cmds.txt list: 3265 of 3315 name each sweep's own frozen binary on all three sweeps, 0 name another
  slang-uhdm binary, the other 50 run no slang-uhdm (48 with no slang line, CoresSweRV and CoresSweRVMP whose only
  "slang" is the repository path in a Surelog command). Determinism: three concurrent draws of the fix binary on
  Earlgrey_0_1, the five UVM rows and Rggen read one hash per row-mode, equal to all three sweeps (and to the
  implementer's hashes); Scoreboard and Rggen testflags have no database in any run.
- Every sweep exited 1 on the law-index check alone: the base's `tests/LAWS.md` is already stale at b7d287dc
  (`law_index.py --check` fails in a clean worktree of the base); the delivery regenerates it.

## The break: § ifaceElabTypeParamIsDefObj278 shares a default whose element golden re-binds

The law lists an elaborated interface instance's not-overridden type parameter as the definition's own
`type_parameter` and records the definition's default typespec in `typeParamElabTs`. Where that default is a
COMPOSITE type naming another type parameter that THIS instance overrides, golden keeps the definition's name and
span but its typespec's element reference is bound to the elaborating instance's override:

    interface ifc #(parameter type T = logic [1:0], parameter type U = T [1:0]) (); ... endinterface
    module top; ifc #(.T(logic [3:0])) u(); endmodule                        // cases/VI/vi14

    golden  type_parameter U  work@ifc.U 2:64  -> packed_array 2:68 -> ref T -> logic_typespec 7:12 (the override)
    law     type_parameter U  work@ifc.U 2:64  -> packed_array 2:68 -> ref T -> logic_typespec 2:36 (the default)
    pristine type_parameter U work@top.u.U (unlocated) -> ...      -> ref T -> logic_typespec 7:12

Chain-keyed away census of the law against pristine: vi14 away 4, vi19 (`V = U` through the composite U) away 8,
vi20 (`U = struct packed { T a; logic b; }`) away 6, vi24 (T overridden by a typedef) away 4, both views each, 0 away
anywhere else among the law's 112 grid movers (evidence/away_grid_law.txt). All eight case-views are stage 1 on both
binaries (uhdm-cmp line counts unchanged), which is why no gate row saw it. Golden's behaviour is a Surelog
re-binding of the shared default's inner reference per instance with the LAST elaborated instance winning: with two
instances, the first overriding T and the second not (cases/VI/vi25), golden's both instances read the default T
and the law happens to be STRICT_EQUAL. A bare chained default `U = T` (vi02) and a default naming a VALUE parameter
(`T = logic [W-1:0]` with W overridden, vi01, vi03, vi05, vi08, vi10, vi12) keep the definition's object in golden:
the law is right there.

## The fix: § ifaceTpOvrTpRefAbstain278v (`src/ParamEmit.cpp`, inside the law's `ifaceDefTp278`) — `R11V278_OVRTPREF_OFF`

The law abstains (trace `IFACETP abstain ovr-tp-ref <name>`) when the type parameter's default, after following bare
chains through type parameters this instance does not override (`V = U`), is a composite type syntax that directly
names (an `IdentifierName`, or slang's `IdentifierSelectName` for `T [1:0]`) a type parameter of the same body that
this instance overrides. A bare default naming an overridden parameter (`U = T`, vi02) and a composite naming only
not-overridden parameters (`V = U [1:0]` with `U = T`, vi26) keep the law. `src/R278.h` gains `r11v278On`
(`R11V278_OFF` drops the verifier's refinement; `R11U278_OFF` still drops everything).

## Fresh cases (cases/VI, VK, VS, VT: 66 dirs, 132 case-views, 1320 grid lines with exit codes)

Each dir's first line names its law. drivers/vgrid.sh runs every case-view on pristine, the law, the fix, the fix +
R11V278_OFF, the fix + R11U278_OFF, the fix + R11V278_OVRTPREF_OFF and the fix + each law switch
(evidence/grid.txt, grid_summary.txt):

- **pristine -> law**: 112 moving, 30 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 9 uhdm-cmp line changes
  all shrinking; **8 case-views AWAY** (vi14, vi19, vi20, vi24, both views).
- **pristine -> fix**: 100 moving, 28 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, the same 9 shrinking
  uhdm-cmp changes (vi01, vi03, vi08, vi10, vi12 e 33 -> 32; vi05 e 219 -> 77; vi18 e 123 -> 51; vi11 d/e
  1226 -> 1204, 1394 -> 1372); **away 0 on all 100** (evidence/away_grid_fix.txt). Each mover returns to pristine
  under exactly one law switch: IFACETP 40, TRAILVARSEL 24, PKGQUALRHS 20, BODYCHAIN 16. Fix + R11V278_OFF = law
  on 132 of 132; fix + R11U278_OFF = pristine on 132 of 132.
- **law -> fix**: 14 case-views move (vi14, vi19, vi20, vi22, vi23, vi24, vi25, both views), each back to the law
  under R11V278_OVRTPREF_OFF and to pristine's bytes exactly: the four away cases restored; vi22 (a POSITIONAL type
  override `ifc #(logic [3:0])`, which Surelog ignores, listing u's T as the definition's default object), vi23 (a
  body `localparam type U = T [1:0]`) and vi25 (two instances, golden's last-writer coincidence) give back the law's
  toward-only gains (7, 2 and 5 records; vi25 leaves STRICT_EQUAL against the LAW, never against pristine).
- Families (pristine -> fix): VI 52 case-views, 40 moving, 2 entering (vi21: `U = T [1:0]` not overridden); VK 30,
  20, 0 (every VK case stage 1 on both binaries, the law's typespec link moving toward golden); VS 30, 24, 20 (a
  var_select nested in a var_select's index vs01, a for-generate genvar index vs02/vs03, a struct array element vs07,
  an always_ff left and right side vs06, two instances vs10, an unpacked dimension vs11, a for-loop variable vs12, a
  var_select inside a bit-select index vs13, inside a call argument vs14 and inside a concatenation vs15 all moving
  to STRICT_EQUAL); VT 20, 16, 6 (a header type parameter named by a body chain vt01, a two-declarator chain vt08,
  an unpacked array of the chain vt09 to STRICT_EQUAL; a chain in a module instantiated with two widths vt04 and an
  enum chain vt06 moving with their downstream verdicts improving).
- **Downstream** (drivers/dscases.py, the HEAD harness's `one()`): on all 67 dirs (with r11u53repro w4) the fix's
  verdict equals the law's, and equals pristine's except VT/vt04 EQUIVALENT -> IDENTICAL and VT/vt06 STATUS_DIFF ->
  EQUIVALENT (46 IDENTICAL, 7 EQUIVALENT, 14 DIVERGENT on the fix, every DIVERGENT already so on pristine: the
  interface-instance lane); the slang lane's RTLIL and netlists byte-identical between law and fix (285 files).

## Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first; evidence/controls*.txt)

28 repro dirs, 1620 case dirs, 3240 case-views, pristine against the FIX (the controls file labels it `fix`): 160
moving, 116 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, 4 uhdm-cmp changes (the implementer's I/i08 e,
I/i11 e, I/i15 d/e, all toward). The movers are the implementer's 156 grid case-views (fix = law on 198 of 198),
r11u120repro/grid/gT/t08_body_localparam_type d/e (BODYCHAIN, away 0, toward 7 and 6, as the implementer measured)
and, beyond the implementer's set, **r11u53repro/grid/w4_bits_iface d/e** (an interface with two not-overridden type
parameters; IFACETP; stage 1 on all binaries; away 0, toward 6 and 12; downstream unchanged). Fourteen case dirs
read rc=3 NODB or rc=- NOGOLDEN identically on both binaries (pre-existing).

## Residues (ranked; all wrong on pristine too)

1. The overridden-reference composite default (vi14, vi19, vi20, vi23, vi24): golden's name and span with the
   rebound element would need the instance's own copy named `work@<ifc>.U` at the declaration with the element
   re-bound to the LAST elaborated instance's T (vi25); not attempted, the fix keeps pristine's bytes there.
2. The positional type override (vi22): Surelog drops it and lists the definition's T; slang honours it. A copy of
   a Surelog defect; not attempted.
3. The implementer's ranked residues stand unchanged (generate-scope fold names a3_earl47 / vo / v08_comb /
   v7_repl105, g1k_hop_userfn, the select-naming leftovers, the K/k15 / k27 continuous-assignment copy, the
   body-chain t03 / t05 / t06 shapes) and the brief's items (2) to (7) beyond them.
4. VK: every fresh package-qualified shape (sized, signed, 40-bit, chained, interface, generate, localparam
   chains) is stage 1 on both binaries, the first difference elsewhere; the law's link moves toward golden on all.

## Sister-ground faces (reported, not written)

The implementer's list stands (ModuleEmit `pvFold115` § pvRecvShadow115 for the received localparam typespec;
UhdmExporter § caProgramNamesakeKeyAtEntry105 / ModuleEmit § caProgTaskFuncInstIsElab95 for a program
instantiated twice; TypeEmit / ModuleEmit consumers of `typeParamElabTs` for variables typed by chained or interface
type parameters, where golden's `u.v` typed U binds the definition's default typespec even under an override
(vi02); ModuleEmit `emitContAssigns` for K/k15, k27).

## Process

Worktrees /tmp/wt_v11u278 (law + fix) and /tmp/wt_v11u278pris, scratch /tmp/v11u278_*. The pristine binary was
frozen before any source edit; the fix was edited only after the law binary was frozen, rebuilt three times
(fix1 matched only `IdentifierName` and missed `T [1:0]`; fix2 did not follow `V = U`; fix3 is the delivery) and
frozen before the census and the fix sweep. Every corpus path list was filtered by `$FENCED` before any file was
opened (bvmirror.sh, byteverify, the cmds.txt audit, controls.sh); the census ran with the harness filter built from
`$FENCED`; no fenced source, database or cmds.txt was read outside the gate sweeps. No process of another agent was
listed or signalled. Every tool variable was checked with `[ -x ]`; every `rm` of a variable path is `${VAR:?}`
guarded (drivers/bvmirror.sh, det.sh, tracecensus.sh now are). The main tree was not written. Drivers copied from
r11u278repro / r11u272repro carry a provenance line; new: drivers/runset.sh, vgrid.sh, vgridsum.py, dscases.py.
