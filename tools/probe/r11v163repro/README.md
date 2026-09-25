# r11v163 — adversarial verification of r11u163 (the expression/parameter ground: ten laws on parameter typespec copies)

Verdict: **ACCEPT-WITH-REFINEMENT.** Every headline number of r11u163 reproduces bit-for-bit. No break was found:
no probe case, corpus row-mode or downstream row moves away from golden on any of the 86 fresh cases of this
verification, the 48 cases of the implementer, the 4087 probe cases, the 3273 corpus databases or the 871 downstream rows.
One law, § ovPkgPatOpInstanceCopy163, also fires on a MODULE-LOCAL pattern parameter (outside its decoded scope). There
it replaces a missing-object walk (`count`/`depth`) with a copy at the wrong location (`line`). That is closer to golden,
but still not equal. A refinement behind its own switch, § ovPatOpCopyAtLocalRef163v (`R11V163_OVLOCALREF_OFF`),
locates that copy at the reading reference, as golden does. It converts the 8 cases that show this face and moves no
probe case and no corpus database (census zero with a positive control; the gate sweep of the verified binary is
byte-identical to the law sweep outside the UVM order coin). The verified patch is /tmp/r11u163.verified.patch.

Base `202fb296`. Worktrees: `/tmp/wt_v11u163pris` (pristine), `/tmp/wt_v11u163` (law, then verified), and
`/tmp/wt_v11u163c` (the composition: this patch applied on pass 160's landing `d48f8f8a8`). System-deps configuration, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base) | `2ba43a59d99989d17d1e556880efa269` (= the brief's) |
| law (r11u163.patch) | `75d81015e32bf4686f665c16b31eaa84` (= the implementer's `law12`) |
| verified (r11u163.patch + § ovPatOpCopyAtLocalRef163v) | `3f4b7ccaec29f36101ee7f76beace5ef` |
| composed (pass 160 `d48f8f8a8` + r11u163.patch) | `7b26a573283f506972253a8532c688ff` |
| `build/uhdm-strictcmp` (identical in all worktrees) | `5d4617d0458f34aa79e0b91009d5d1fc` |

All binaries were frozen (`chmod 555` copies under `/tmp/v11u163_bin`) before they were measured. Every sweep's
`cmds.txt` names its own frozen copy: pristine 3273/3273, law 3273/3273, verified 3273/3273. The census names the trace
wrapper in 3265/3265 (the fenced row-modes are excluded by `--filter`). The sweep workdirs `/tmp/v11u163_sw{P,L,V,C}`
have names of the same length.

**The fence.** No binary, script or reader touched a slang-fenced test outside the gate sweeps. Every driver here reads
`$FENCED` from the environment and refuses to run without it; the census dispatches the corpora with
`--filter '^(?!(<the four>)$)'`. A grep of this directory for the four names reads 0.

## 1. Reproduction (the implementer's numbers, bit for bit)

| stage | pristine sweep vs committed baselines | law sweep vs committed baselines |
|---|---|---|
| probe | EQUAL 2529 / STRICT_NOTEQUAL 1558; regressions=0 conversions=0 changes=0; probe.csv byte-identical to the base's results/golden_probe.csv | EQUAL **2580** / 1507; regressions=0 conversions=**51** changes=**32**; probe.csv byte-identical to the implementer's |
| surelog | CMP_EQUAL 429 + 426 (855); 0/0/0 | CMP_EQUAL 434 + 431 (**865**); regressions=0 conversions=**10** changes=0 |
| uhdm2rtlil | CMP_EQUAL 754 + 754 (1508); 0/0/0 | CMP_EQUAL 758 + 758 (**1516**); regressions=0 conversions=**8** changes=0 |
| downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT; csv byte-identical to results/downstream_uhdm2rtlil.csv | the same; downstream.csv byte-identical to the pristine sweep's |

The corpus csvs equal the implementer's except the LowMem SURELOG_FAIL detail text, which contains the workdir path.
The strict column (name, mode, status, strict) differs between the pristine and law sweeps on exactly the 18 converted
row-modes. The conversions in the fresh csvs (`<row>,<mode>,CMP_EQUAL,,,equal`, both modes): FuncIoTypespec,
LargeValue2Struct, ParamNoImport, ParamTypespec2, StructUnsizedVal (surelog); gen_scope_numports, param_array_wildcard,
struct_param_pattern_packing, type_param_override_elem_sel (uhdm2rtlil). Their downstream rows:

    gen_scope_numports,IDENTICAL,NO_GATES,NO_GATES,0,0,,
    param_array_wildcard,IDENTICAL,OK,OK,19,19,,
    struct_param_pattern_packing,IDENTICAL,OK,OK,51,51,,
    type_param_override_elem_sel,IDENTICAL,OK,OK,3,3,,

**Byte movers, law against pristine** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1: 959/960 and 1607/1608
flagged; evidence/byteverify_*_law.txt):
* surelog: 29 movers, the implementer's 25 predicted row-modes plus 4 of the UVM order coin: MiniAmiq d, SeqDriver
  d/t, SimpleUVM d. The order-blind path-normalised uhdm-dump diff is 4 lines on each of the four.
* uhdm2rtlil: 40 movers, all predicted.
* probe: with the raw walk (`uhdm-strictcmp --no-canon` of the law database against the pristine one, because a probe
  database embeds its worktree path), 98 cases move, all predicted (evidence/probe_movers_law.txt). The implementer's
  99th mover (`r10earl_repro/vf`, IMPOPNAME) differs in bytes, but its dump and raw walk are identical.
* canaries (tools/probe/r11u107repro): surelog ok=50 changed=2 (FuncIoTypespec d/t, the conversion), uhdm2rtlil ok=16
  changed=0; ctcan2 EXPECT_UNKNOWN=1 and =6 PASS.

The implementer's 48 grid cases reproduce their verdicts exactly (evidence/grid_impl_reproduced.txt). pi/p05 is
stage 1 on both binaries; its uhdm-cmp output changes from 17 to 11 lines, but the head is the same
(`LHS: <null>` against our operation's ref_typespec; the printed RHS object is now the law's unnamed copy).

## 2. Breaking the laws: 86 fresh cases, three judges

Each law got fresh instances on legal SV. Every case names its law on its first line. Each case was judged on the
pristine, law and verified binaries by uhdm-cmp against the v1.87 pin and by uhdm-strictcmp record by record
(drivers/grid3.sh, drivers/recdiff.py, full `--max 100000` walks). The downstream verdict came from ds.one on the
downstream flags (drivers/ds.py, pristine and law, then pristine and verified on the refinement cases). The whole table
is in evidence/grid_all.txt.

| grid | law | cases | pristine -> verified |
|---|---|---|---|
| qs | § aggParamFoldQualSpanByView163 | a01-a17: macro reference, a localparam, an interface, a second instance with the same override, a union, a cast value, `'0`, a chained package value, `$unit::`, a generate-block localparam, a concatenation value, a decimal value, an import copy of a package that reads another package, a parameter read by the next parameter | 6 endcol -> EQUAL (a03 a04 a06 a08 a11 a15), 1 equal both (a09), 10 stage 1 on both |
| sy | § elabAggFoldYCopyDefNamed163 | b01-b10: two definitions reading the same Y, explicit import, union, a nested hierarchy, an interface, an overridden second instance, a nested struct, a `$unit` import, a body localparam, instances in a generate loop | 5 fullname -> EQUAL (b03 b04 b06 b09 b10), b08 fullname both (the `$unit`-import shape), 4 stage 1 on both |
| po | § ovPkgPatOpInstanceCopy163 | c01-c07, c09-c11: two consumers of one package parameter, generate loop, a pattern with a parameter operand, `'{default:...}`, a positional override, a positional pattern, an interface, a typed formal, a part-select read | 5 fullname -> EQUAL, c11 fullname -> type (two records leave, the walk divergence at #166 was already there), c10 line both (a typed formal: the law does not fire), 4 stage 1 on both |
| po + lr | § ovPatOpCopyAtLocalRef163v (the refinement) | c08 c12 c13 c14, r01-r08: a module localparam, a header parameter, two instances, a package-typed localparam, a macro reference, a generate-block localparam, an interface, a positional override, an imported package parameter, a multi-line actual, a pass-through header parameter, a positional pattern | 8 `count`/`depth` -> **EQUAL** (the law alone reads `line` on all eight); r01 (macro) count -> line; r02 r05 r07 stage 1 on both |
| pl | § pkgPatListingCopyWhenShared163 | d01-d03: a concatenation of two reads, two replicating instances, two package parameters | d03 fullname -> EQUAL; d02 fullname -> depth (5 fullname records leave, the depth divergence at #337 was already there); d01 stage 1 on both |
| ip | § importPatOpCloneParamNamed163 | e01-e04: explicit import, a package importing a package, two instances, a `$unit` import | e01 e03 fullname -> EQUAL; e02 e04 fullname on both, the same records |
| rc | § paramOpCloneRelocatedSpan163 | f01-f07: two subroutines (last writer), a task argument, a subroutine in another package, an overridden second instance, an unqualified import, a union, a return type plus an argument | f02 f07 line -> EQUAL; f05 line both (2 records leave); f03 fullname both; f01 f04 stage 1 on both; f06 SLANG_FAIL on both (the union's initializer is rejected by slang) |
| tp | § elabTpDefaultDefNamed163 + § elabTpNamedElemDimDefNamed163 | g01-g11: two dimensions, a package-parameter bound, an interface, a pass-through, a localparam wrapper with a default and an overridden instance, a parameter-typed wrapper, a generate loop, a type parameter defaulting to another type parameter, `signed [2*W-1:W]`, `bit [W:1]` with an overridden sibling | g05 g06 fullname -> EQUAL; 6 equal on both (bytes move inside the canonicalised typespec copies); g02 g03 g08 unchanged records |
| oa | § elabOvArrFoldSharesDefParamTs163 | h01-h06: a nested instance, two instances with different widths, fixed dimensions, a parameterised element width, C-style `[N]`, an interface | h01 h05 fullname -> EQUAL; 4 stage 1 on both |
| fp | § fnParamRangeNetNoFile163 | i01-i06: a package function, an interface function, two ranged locals, a function in the top module, a parameterised module with two instances, a generate-block function | i03 i04 i05 file -> EQUAL; 3 stage 1 on both (bytes unchanged) |

Totals over the 86 fresh cases (pristine -> verified): **35 -> STRICT_EQUAL** (27 by the implementer's laws, 8 by the
refinement), 7 equal on both, 12 STRICT_NOTEQUAL on both, 31 stage 1 on both (same uhdm-cmp head; po/c06 changes
its line count in the way pi/p05 does), and 1 SLANG_FAIL on both.

The record-level judge found no record entering on any of the 85 cases with a database, except lr/r01. There the law
lists the 17 objects golden has and pristine lacked, and one of them sits at the declaration, where golden locates it
at the macro use (7:13-14). Every other changed case only loses records (evidence/records_pris_vs_verified.txt). By the
path-normalised uhdm-dump distance to golden, 54 cases get closer, 31 stay the same and **0 get worse**
(evidence/dumpdiff_pris_vs_verified.txt). Downstream, 0 of the 86 fresh cases worsens. fp/i03 goes EQUIVALENT ->
IDENTICAL, and every other verdict is unchanged (evidence/downstream_cases.txt).

**Droppability.** Each law was run alone, with its own switch off (drivers/switch1.sh, evidence/switch_single.txt):
* On every case where one law fires, turning that law's switch off gives pristine bytes (`:P`).
* Where two laws fire, the other law's bytes remain (`:L`).
* R11U163_OVPATCOPY_OFF gives bytes that are neither pristine nor law (`:X`), because § pkgPatListingCopyWhenShared163
  then fires on the package listing's operation, which is now shared. The verdict is pristine's on every such case
  (pi/p01, po/c01: fullname).
* With `R11U163_OFF=1`, 219 of 220 databases (the 134 grid cases, the 98 walk movers and `vf`, deduplicated) are
  byte-identical to pristine. The 220th is rc/f06, which has no database on either binary (evidence/off_bytes.txt).

## 3. The refinement: § ovPatOpCopyAtLocalRef163v (`R11V163_OVLOCALREF_OFF`; ParamEmit.cpp emitParameters, inside the § ovPkgPatOpInstanceCopy163 branch)

When the parameter substituted into an untyped formal's override is NOT a package member, golden locates the
instance's copy of the pattern operation at the READING reference, file included. That covers a module's own
localparam or header parameter (`test #(.P(L))`). It is § elabPatOperandRefSpan140's rule. Golden po/c08 puts it at
`L` 6:13-14; the law puts it at the declaration 5:22-42. An unqualified, non-macro reference only: a macro use (lr/r01)
is the location model's (golden 7:13-14 = the macro start plus the expansion's length) and stays as the law leaves it.
Cases: po/c08, po/c12, po/c13 (two instances), po/c14, lr/r03 (interface), lr/r04 (positional), lr/r06 (multi-line
actual), lr/r08 (positional pattern), all `count`/`depth` -> STRICT_EQUAL. The controls lr/r01 (macro) and lr/r05
(imported package parameter) do not fire, and neither do any of the implementer's 48 cases. lr/r07 (a pass-through
header parameter) fires and stays stage 1 with the same head. The downstream verdict of all 14 refinement-touched
cases is the pristine one: 11 IDENTICAL and 3 EQUIVALENT, none worse. A byte comparison against the law binary moves
exactly the 9 cases where the refinement fires.

**Census before the gate sweep** (drivers/census.sh + drivers/tracewrap.sh, fence-filtered): 0 firings over the
4087 probe cases and the 3265 corpus runs. A positive control (lr/r03 through the same wrapper) logs one firing. So the
predicted movers are none. The gate sweep of the verified binary confirms it:
* probe.csv, surelog.csv and uhdm2rtlil.csv are identical to the law sweep's (path-normalised);
* downstream.csv is byte-identical to the pristine sweep's;
* byteverify against the law sweep: uhdm2rtlil 0 movers; surelog 6, all UVM order-coin rows (MiniAmiq d, Scoreboard d,
  SeqDriver d/t, SimpleUVM d/t; order-blind dump diff 4 lines each, 0 on Scoreboard d, the svunit list-order coin).

## 4. Gates of the verified binary (all mandatory, from /tmp/wt_v11u163 with SLANG_UHDM exported)

| gate | result |
|---|---|
| (1) build | pristine `2ba43a59…`, verified `3f4b7cca…` |
| (2) probe | regressions=0 conversions=51 changes=32 (EQUAL 2580, STRICT_NOTEQUAL 1507; every case judge-equal) |
| (3) surelog / uhdm2rtlil | regressions=0; conversions 10 / 8; changes 0 / 0 |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66, not identical and not excused=0; byte-identical to pristine; the four targeted rows IDENTICAL (quoted above) |
| (5) uhdm-cmp on touched rows | every mover keeps its judge-equal status; all stage-1 grid cases keep their head |
| (6) byteverify vs pristine | surelog 30 movers (25 predicted + 5 coin), uhdm2rtlil 40 (all predicted); probe 98 walk movers (all predicted) |
| canaries | surelog ok=50 changed=2 (the conversion), uhdm2rtlil ok=16 changed=0; ctcan2 PASS both |
| sweep rc | 1 on the pre-regeneration run, from `law index STALE` alone (the new § token); `scripts/law_index.py --check` reads current after regeneration |

## 5. Composition with pass 160 (landed on the main tree during this verification as `d48f8f8a8`)

r11u163.patch applies on `d48f8f8a8`, with tests/LAWS.md regenerated and the three source files clean. The composed
binary's sweep against pass 160's committed baselines reads:
* probe: regressions=0, conversions=50, changes=32 (EQUAL 2597);
* surelog: regressions=0, conversions=10;
* uhdm2rtlil: regressions=0, conversions=6.

The difference: pass 160 already converted gen_scope_numports and one probe case. **§ elabTpDefaultDefNamed163 and
pass 160's § tpUseBindsDefDefault160 (`R11U160_TPUSEDEF_OFF`) are verdict-redundant on the composed binary.** On nd/n03
and nd/n08, either switch alone keeps STRICT_EQUAL, and only both off returns `fullname`. Over the tp/nd cases and the
TPDEFNAME probe movers, TPDEFNAME still moves bytes on 12 cases but no verdict (inside canonicalised typespec copies).
The integrator may keep both laws; they agree wherever both fire.

## 6. Residues on this ground (ranked; none is a break)

1. The macro-use location of the pattern copy (lr/r01): golden's location is the macro start plus the expansion's
   length. This belongs to r11u166's location model.
2. The implementer's residues stand as measured: LocalScopeHierPath t (the foreach index's stored full name under
   `--elabuhdm`), iface_zero_width_field d/t, rl/q03 (the relocated span on the definition listing's copies), hc/g02
   (a direct `.a(pk::D)` connection).
3. New STRICT_NOTEQUAL shapes found here, unchanged by the patch:
   * sy/b08 and ip/e04: a `$unit`-level `import pkg::*` with the Y read or the pattern parameter. The package-typedef
     member references are named by the compilation unit's copy.
   * ip/e02: a package importing a package; 9 member references.
   * rc/f03: the relocating subroutine in another package.
   * tp/g02: a package-parameter bound in a type-parameter default. The reference is named `t_t` where golden leaves it
     empty.
   * tp/g08: a type parameter defaulting to another type parameter.
   * po/c10: a typed struct formal overridden by a package pattern. The law does not fire; the location is off by the
     same face as the refinement.
4. Stage-1 shapes (both binaries, same head): qs/a01 (a pattern-valued Y read qualified), qs/a02 (a conditional),
   qs/a05 (an interface), qs/a07 and qs/a10 (a continuous-assignment reader), qs/a12 (`$unit::`), qs/a13 (a generate
   localparam), qs/a14 (a concatenation value), qs/a16, qs/a17, sy/b01 (two definitions, one Y), sy/b02, sy/b05,
   sy/b07, po/c03 (a parameter operand), po/c04 (`default:`), po/c06 (a positional pattern), po/c09, pl/d01, rc/f01,
   rc/f04, oa/h02, oa/h03, oa/h04, oa/h06, fp/i01, fp/i02, fp/i06, lr/r02, lr/r05, lr/r07.

## Cases (the law each exercises; verdicts in evidence/grid_all.txt)

* qs/a01-a17 — § aggParamFoldQualSpanByView163
* sy/b01-b10 — § elabAggFoldYCopyDefNamed163
* po/c01-c07, po/c09-c11 — § ovPkgPatOpInstanceCopy163
* po/c08, po/c12-c14, lr/r01-r08 — § ovPatOpCopyAtLocalRef163v
* pl/d01-d03 — § pkgPatListingCopyWhenShared163
* ip/e01-e04 — § importPatOpCloneParamNamed163
* rc/f01-f07 — § paramOpCloneRelocatedSpan163
* tp/g01-g04, g07-g11 — § elabTpDefaultDefNamed163; tp/g05-g06 — § elabTpNamedElemDimDefNamed163
* oa/h01-h06 — § elabOvArrFoldSharesDefParamTs163
* fp/i01-i06 — § fnParamRangeNetNoFile163

## Files

* drivers/grid.sh (golden + pristine + law, uhdm-cmp + uhdm-strictcmp), grid3.sh (adds the verified binary),
  recdiff.py (the entering/leaving records), dumpd.sh (the dump distance), ds.py (the downstream verdict of a case),
  off.sh (`R11U163_OFF` bytes), switch1.sh (each switch alone), census.sh + tracewrap.sh (the refinement's census),
  sweep.sh (the gate sweeps). They read the scratch paths `/tmp/v11u163_*` and `$FENCED`.
* evidence/: the files named above.
