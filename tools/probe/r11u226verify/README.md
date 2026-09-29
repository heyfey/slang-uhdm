# r11u226: second adversarial verification of passes 219, 220 and 223

Base `4a620bd0` (branch matrix-1.87): pass 219 and v11u219 landed at `896ec643` (module/type ground), pass 220 and
v11u220 at `551c9751` (expression/parameter ground), pass 223 and v11u223 at `75a564b0` (module/type ground), and
map 14 (`tools/probe/r11u222map`, measurement only) at `4a620bd0`. **Pass 224 (r11u224, expression/parameter
ground) landed at `ac0dda58` while this pass ran (06:10, after every measurement here had started); this pass kept
its base.** Pass 224 does not touch the address-order loop (its commit names MiniAmiq d/t's storage-order coin as
still moving), and it closes several of pass 220's residues re-measured in section 9 at `4a620bd0`. fix.patch
applies to `ac0dda58` with `git apply -3` with one conflict, the `#include` line in ExprEmit.cpp (keep both
`R224.h` and `R226.h`); every other hunk applies. r11u225's worktrees were not touched; the main tree's
uncommitted `src/ModuleEmit.cpp`, `src/TypeEmit.cpp` and `tests/LAWS.md` changes seen at 06:29 are not this pass's
(it never wrote to the main tree).

This pass measures only. No file under `src/`, `scripts/`, `tests/`, `results/` or `third_party/` is edited by this
directory. The two refinements it proves are in [fix.patch](fix.patch) (a diff against `4a620bd0`, not applied),
each behind its own switch, `R11V226_OFF` dropping both, in a new header `src/R226.h`. No canonicalisation patch of
`tools/uhdm-strictcmp` was handed to this pass and none was written: no comparator defect was proven. A probe case
is called a case. The four slang-fenced tests are never named here.

## 0. Verdict

* **One break, in a refinement of pass 223** (section 4.1). § tfArgScalarTdExportFirst223 keeps the typedef's
  declaration object on the formals of every subroutine whose `export "DPI-C"` precedes its definition. Golden keeps
  it only when the typedef is declared in the subroutine's own package (pass 223's f21, this pass's F/f14). When the
  typedef reaches the subroutine through an import (a `$unit` or module-level import into a module, or another
  package's typedef imported into the subroutine's package), golden writes the per-formal copy at the formal's
  type token, as for any other subroutine. Fresh cases F/f13 and F/f15 are STRICT_EQUAL in both views with
  `R11U223_SCALARTDEXP_OFF` and STRICT_NOTEQUAL `line` (2 records, the formal's typespec at the typedef's declaration
  `3:11-3:14` where golden writes `8:19-8:25`) with the refinement on. F/f11, f16 and f17 (stage 1 at the base on
  other faces) move the same field away. The refinement is **§ tfArgScalarTdExportOwnTd226v**
  (`R11V226_EXPOWNTD_OFF`): the export-first decline applies only when the formal's typedef is declared in the
  subroutine's own scope. F/f13 and f15 go STRICT_EQUAL in both views; f11, f16 and f17 move only toward golden;
  pass 223's f21 and f24, v11u223's a14 and this pass's f04 and f14 keep their bytes.
* **The MiniAmiq storage-order coin is cured** (section 7). On the base binary MiniAmiq drew **three** database
  hashes in 24 concurrent draws (default and testflags), all with one uhdm-dump. The writer is the address-order
  walk map 14 pinned, `refFullNameThroughNamedExpr175` (ExprEmit, called from ParamEmit drainPaNameCopySrc38), which
  registers fresh full-name strings while iterating `Serializer::AllObjects()` (a map keyed by object address).
  **§ fullNameDrainIdOrder226v** (`R11V226_IDORDER_OFF`) visits the objects in UhdmId order: **one hash in 24 of 24
  draws**, the uhdm-dump identical to the base's on every UVM row, and the coin returns with its switch set.
* **No break in the other laws of the three landings.** 104 fresh cases in both views (208 case-views) were judged
  three ways: uhdm-cmp, uhdm-strictcmp record by record, and the downstream verdict.
  * From all three landings off to on: **57 case-views enter STRICT_EQUAL, 0 leave, 0 go from judge-equal to stage
    1, 0 crash** (4 case-views crash, rc 139, with the landings off: the elaborated `$size` shapes pass 223 fixed).
  * Every law scored against its own switch reads TOWARD, BYTES-ONLY, UNFIRED or a stage-1 distance, except the
    break above and three dump-level readings examined object by object (section 4.2): v11u219's
    § sizeReachFollowsWalker219v (it keeps the call where the unrefined law wrote a WRONG value; golden's value is
    the generic handler's), § enumPkgWriterImportsType219 (a `vpiParent` neither comparator reads, on stage-1 shapes
    only) and § enumTdLastWriter214 on a three-level nested `$unit` class (raw names of the per-class identity
    family, excused by the comparator; its judge-equal two-level twins move only toward).
  * Downstream on the fresh cases: **6 DIVERGENT -> IDENTICAL, 0 leaving IDENTICAL**, every other verdict and
    netlist the same or closer.
* **Composition** (section 5): every conversion each landing claimed is its own at HEAD (pass 219: the ten probe
  cases; pass 220: anon_struct_packed_dim d/t and eleven probe cases; pass 223: four probe cases, t48c JOINT with
  pass 220 as claimed); CANCEL is **0 at status level and 0 at byte level over 7452 databases**; each landing's
  byte movers at HEAD equal its own frozen prediction; the cross-ground pairs compose in the same direction as each
  law alone.
* **The changes** (section 6): every surelog and probe CHANGE of the three integration sweeps is a strict subset
  of its base's records or an unmasking past the base walk's divergence; the one record the index-free check calls
  NEW (r10v112repro/g19_builtin) is the same object whose raw full name the law fixed, its pre-existing file and
  span difference now the first field.
* **v11u220's three checks, done here** (section 8): the three-run determinism with and without pass 220's laws
  (no new coin), the UVM order-blind distance (**MiniAmiq 6266 -> 2786, SeqDriver 4969 -> 2493, BuildUVMPkg 673
  -> 648, SimpleUVM 1903 -> 1894, Scoreboard 1393 -> 1386, reproduced exactly** at the `57ce3ae8` switch state),
  and the corpus-wide reversed positive control (**forward 0 away / 7730 toward, reversed 7730 away**).
* **Fence and process** (section 10): every driver of the six directories reads the fence itself or through a
  fenced caller, every env.sh fails closed, no file names a fenced test; four case drivers run `$UHDM_CMP` /
  `$STRICT_CMP` / `$SURELOG` with no executable guard of their own (listed); pass 223's prediction has an md5 but
  no time stamp file.

**The fix's gates** (section 2): probe, surelog and uhdm2rtlil **0 / 0 / 0**, downstream **803 / 66 / 2 / 0**, every
csv equal to the base's; byte movers 9 corpus + 3 probe + 0 lanes, all inside the frozen prediction and all with a
uhdm-dump identical to the base's (the id-order refinement's symbol-table order); `R11V226_OFF` gives the base's
bytes on 6646 of 6647 databases, the other the Scoreboard svunit coin (92 dump lines unsorted, 0 sorted); the patch
rebuilt on a fresh `4a620bd0` worktree gives `fix.bin`'s md5 `bd7f6f685b39`.

## 1. Binaries and states

| binary | md5 | what |
|---|---|---|
| `law.bin` | `abaa83b8a0194539219d406e055c8b51` | `/tmp/wt_r11u226` at `4a620bd0`, system-deps config, `-j 2`: the main tree's `build/slang-uhdm` |
| `fix.bin` | `bd7f6f685b39a13ad554c5d4fa9c6317` | `4a620bd0` + [fix.patch](fix.patch) (md5 `77054081`), `/tmp/wt_r11u226fix`, `-j 2` |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | the worktree's build, equal to the main tree's |
| `strictcmp_x` | `5bbd7f8373a051201b6367d6f0d615a7` | map 13's raw-name variant (tools/probe/r11u211map/drivers/cc.sh), the md5 the earlier passes cite |

All frozen `chmod 555` in `/tmp/r11u226_bin` before any measurement. Every state below is `law.bin` under switches
(read from the sources at `4a620bd0`, [drivers/laws.py](drivers/laws.py)):

| state | switches | the laws it drops |
|---|---|---|
| L (HEAD) | none | - |
| 219 off | `R11U219_OFF` | r11u214's eight laws (`r11u214Law` reads `R11U214_OFF` or `R11U219_OFF`), pass 219's laws (`r11u219Law`), v11u219's § sizeReachFollowsWalker219v (`r11v219Law` reads `R11V219_OFF` or `R11U219_OFF`). The landing switches `R11U219_LANDING202/212/216_OFF` are not read by it |
| 220 off | `R11U220_OFF` | pass 220's nine laws (`r11u220On`) AND r11u218's four (`r11u218On` reads `R11U218_OFF` or `R11U220_OFF`); `R11U218_OFF` alone drops only r11u218's four; `R11U220_LANDING205A_OFF` is not read by it |
| 223 off | `R11U223_OFF` | pass 223's five laws (`r11u223Law`) and v11u223's two refinements (`r11v223Law` reads `R11V223_OFF` or `R11U223_OFF`) |
| A (all off) | the three | = `162790c3` (probe 3422 + 665, the r11u221 integration's numbers) |
| 896ec643 | `R11U220_OFF R11U223_OFF` | probe 3432 + 655, surelog Earlgrey `endcol(39)`, UVM `file(7|56|32)`, BuildUVMPkg `line(31)`: the pass-219 integration's rows |
| 57ce3ae8 (UVM rows only) | the three + `R11V221_OFF` | MiniAmiq/SeqDriver `endline(59)`, SimpleUVM `fullname(185)`; + pass 220 = `fullname(183)`: pass 220's own base and law rows |

Gate sweeps (`tests/sweep.sh --jobs 3`, 15-character workdirs, every `slang:` line of all 3273 corpus `cmds.txt`
naming `law.bin` or `fix.bin` as the sweep's own, [evidence/compose/cmds_binary_audit.txt](evidence/compose/cmds_binary_audit.txt)):
L `/tmp/r11u226_wL`, A `/tmp/r11u226_wA`, 219 off `/tmp/r11u226_w9`, 220 off `/tmp/r11u226_w0`, 223 off
`/tmp/r11u226_w3`, 896ec643 `/tmp/r11u226_w8` (probe and both corpora), 57ce3ae8 `/tmp/r11u226_wW` / `_wV`
(the five UVM rows), fix `/tmp/r11u226_wF`, fix under `R11V226_OFF` `/tmp/r11u226_wO` (probe and both corpora).

**L reproduces the integration of pass 223**: probe, surelog, uhdm2rtlil and downstream csvs equal
`/tmp/intr11u223`'s row for row (status and strict columns), and 2558 of 2560 non-fenced corpus databases are
byte-identical; the two others are the known coins (MiniAmiq default, Scoreboard default, section 7).

## 2. The gates of the base and of the fix

| gate | L (law.bin) | fix.bin |
|---|---|---|
| probe vs golden_probe.csv | 3448 + 639, **0 / 0 / 0** | 3448 + 639, **0 / 0 / 0** |
| surelog vs golden_surelog.csv | **0 / 0 / 0** | **0 / 0 / 0** |
| uhdm2rtlil vs golden_uhdm2rtlil.csv | **0 / 0 / 0** | **0 / 0 / 0** |
| downstream | **803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT**, EXIT=0 | **803 / 66 / 2 / 0**; the four csvs equal L's row for row (status and strict) |

* **The fix's movers, predicted before its sweep.** The firing census (drivers/census.sh with `R11V226_TRACE`, every
  non-fenced corpus row-mode through a `--filter` built from `$FENCED`, every probe case) reduced by
  drivers/predict.py: 28 possible movers ([evidence/census/prediction_fix.txt](evidence/census/prediction_fix.txt), md5
  `eede7036`, frozen 06:13:14 with `fix.bin`'s md5 in the stamp, the sweep started after it), every one by
  § fullNameDrainIdOrder226v (a database where the drain sets two or more names; only there can the registered
  strings' order differ) and **none by § tfArgScalarTdExportOwnTd226v**. The sweep's movers against L:
  **byteverify 9 / 2560** (`PATH_SETS_IDENTICAL`, SELFCHECK 2559 / 2560 on hard-link mirrors without the 8 fenced
  row-mode databases, r11u223repro's bvmirror.sh; [evidence/fix/byteverify_fix_vs_law.txt](evidence/fix/byteverify_fix_vs_law.txt)):
  BuildUVMPkg d/t, MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d; **probe 3 / 4087** (r10buvm13repro/v3_clone13,
  r10uvm17repro/t29_t, r10v179repro/v179_f_nomod); **downstream lanes 0 / 805**. All 12 are in the prediction (the
  other 16 predicted kept their bytes: the id order equalled the address order there, SVSwitch d/t among them), and
  **all 12 read a uhdm-dump identical to L's** (unsorted).
* **uhdm-cmp**: every moved row-mode is STRICT_NOTEQUAL (judge-equal) on both binaries with the same strict cell.
* **Canaries**: tools/probe/r11u107repro/canaries.sh surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 (against the
  committed baselines and against L); `EXPECT_UNKNOWN=1 ctcan2.sh` surelog PASS, `EXPECT_UNKNOWN=6 ctcan2.sh`
  uhdm2rtlil PASS.
* **The switch**: the fix under `R11V226_OFF=1` (`/tmp/r11u226_wO`, [evidence/fix/sweep_wO_R11V226_OFF.log](evidence/fix/sweep_wO_R11V226_OFF.log))
  reads 0 / 0 / 0 in the three stages and writes L's bytes on 6646 of 6647 probe and non-fenced corpus databases,
  the other Scoreboard default (the svunit coin: 92 uhdm-dump lines unsorted, 0 sorted).
* **Rebuild**: fix.patch applied to a fresh `4a620bd0` worktree (`/tmp/wt_r11u226rb`, `-j 2`) builds md5
  `bd7f6f685b39a13ad554c5d4fa9c6317` = `fix.bin`.
* Every sweep's EXIT is 0 except the fix's (EXIT=1: the law-index staleness notice alone, this directory's cases
  naming laws in an untracked directory; every compare stage reads 0 regressions) and the switch-state sweeps (their
  regressions are the landings' own conversions, by construction).

## 3. The fresh cases (cases/, 104 cases, 208 case-views)

Every case names its laws on its first line. Goldens are the pinned Surelog's with the probe arguments (both views:
the parse view and `-elabuhdm` / `--elabuhdm`), built into `/tmp/r11u226_g`. [drivers/grid.py](drivers/grid.py)
(r11u221's, with the three landings' switch map) runs, per case-view, the law binary with no switch, with each named
law's switches (a law with several switches also each alone), with each landing's switch, with every pair of named
laws for the X cases, all three landings off (A) and A + `R11V221_OFF` (WIDE), and scores each state against ON by
strict records (TOWARD: records lost, none new; AWAY: a new record on an aligned walk; UNMASK; BYTES-ONLY) or, when
either side is stage 1, by the order-blind uhdm-dump distance to golden with the weaklyReferenced tail cut (the tail
is unreachable to the judge; the first scoring counted it and was re-scored, section 11).

| family | cases | shapes (none in the six earlier grids) |
|---|---|---|
| W (§ enumTdLastWriter214 and its two refinements) | w01 program class; w02 `$unit` class nested three levels; w03 two files, the second CRLF; w04 packages importing a value, the type by name and wildcard; w04b by name vs wildcard; w05 program, interface and module against name order; w06 explicit `$unit` import of the TYPE; w07 alias of an alias; w08 module class named after the `$unit` class; w09 nested one level; w10 outer and nested both listing; w11, w12 the ALIAS imported by name | every writer kind, name orders, nesting, two files, CRLF |
| C (§ classTdAliasLastWriter214, § classScopeTdPkgListingParent214, § cloneAliasFormalOwnChain214) | c01 interface and module; c02 nested in a `$unit` class; c03 two files; c04 two class-scope specializations read from two packages; c05 out-of-body alias-of-alias formal | |
| Q (§ modStructMemberQualSpan214) | q01 interface and generate typedefs; q02 sum of qualified names, `$clog2(cfg::D)`, a qualified-both range; q03 CRLF with tabs, product, spaced; q04 function-local struct, port type | |
| U (§ unitImportCopyOwnTsRef214, § unitImportCopyValueFollowsPkg214) | u01 enum-typed, byte, untyped, `int unsigned`; u02 two `$unit` imports, cross-package; u03 two files | |
| V (§ importVarElemOwnName214) | v01 associative of a struct by string and a fixed int array into a `$unit` class; v02 dynamic array and queue into a nested class; v03 2-D enum array and class-keyed associative into two packages | |
| S (§ ndaSizeFoldReach219, § sizeReachFollowsWalker219v, § ndaAdjSizeFoldSized223, § unsizedInnerSizeDeclines223) | s01 3-D unpacked, d = 1..4; s02 3-D packed; s03 int elements d = 1..3; s04 packed and unpacked struct elements; s05 typedef'd unpacked element and typedef'd packed; s06 parameter, localparam, parameter-sized; s07 enum elements d = 1..3; s08 wire and tri arrays; s09 bit and byte; s10 class handles and strings; s11 localparam and genvar `d`; s12 wand, uwire, signed 3-bit, `$size + 1`; s13 leading associative; s14 leading dynamic and queue | every element kind, every d, every unsized position |
| D (§ unsizedInnerSizeDeclines223, § sizeDeclineTsInvalid223v, § ndaAdjSizeFoldSized223) | d01 dynamic/queue inner in a continuous assign and a generate net; d02 fixed-dynamic-fixed and fixed-queue d = 1 with fixed-assoc-fixed; d03 tri, wor and a struct-typed net; d04 1-bit, `[0:9]`, 40-bit signed, an interface net; d05 fixed-assoc-fixed and fixed-assoc(string) | |
| B (§ fixedOuterAssocInnerReg223) | b01 interface, generate and module scopes keyed by byte, string, int; b02 byte, bit vector, longint, packed struct, enum elements and a fixed dimension after the associative; b03 class property, function local, queue after the associative | |
| P (§ ppIdentEndInRebuiltText219, § ppDotNameAfterArgToken219) | p01 a pasted method name through three levels; p02 a three-line actual with a comment through two; p03 stringified formal beside the call; p04 the macros from a header included by the second root file; p05 names with digits, a two-call line; p06 an array element actual; p07 CRLF and tabs; p08 one level, the actual on the next line | 1, 2 and 3 levels, multi-line, stringified, pasted, another root file |
| E (pass 220's laws and r11u218's) | e01 module parameter sum/shift/product/unary of qualified names; e02 interface parameter concatenation and conditional; e03 lvalue index path part select in a generate and `[6:4]`; e04 two-level member path lvalue index; e05 indexed part select, reference base and parameter width, in a function and `-:`; e06 in a class method; e07 e08 e23 clone returns (struct, enum, vector, queue typedef, static; two packages and `$unit`); e09 var_select three selects deep with cast and genvar indices in a two-level generate; e10 parameter and call indices; e11 `-:` and `+:` with reference and operation bases; e12 static class function and nested class method in a package; e13 backtick-space, escaped quotes beside backslashes, backtick before `\n`; e14 parameter, `$sformatf` argument, concatenation; e15 conditional operand and whole right side; e16 class property and static property; e17 module variable, localparam and function local initializers; e18 task argument, concatenation, `$display` argument; e19 `new[h(g(n), n)]`, `new[$size(q)]`, `new[arr[i][j]]`, `new[this.g(n)]`; e20 `new[dsc.len[k]]`, queue bit select, a call on a bit select; e21 clone indices, two packages; e22 nested select, cast and lvalue indices in a task | |
| F (§ tfArgScalarTdWriter223 and § tfArgScalarTdExportFirst223) | f01 int, integer, byte, shortint, longint, bit, logic, reg; f02 unsigned, signed packed, packed 2-D; f03 interface task, module function, module class, interface class; f04 DPI import, export after, task export before (package); f05 real, shortreal, string, chandle, struct, time (controls); f06 unpacked typedef (control); f07 CRLF, tabs, defaults, output/ref; f08 extern out-of-body in `$unit` and module classes; f09 virtual override in an importing package, static, constructor; f10 two packages one name; f11 module export with a C name before, task after; f12 unpacked dimension on the formal; f13-f17 the export-first distinguisher (section 4.1) | |
| X (the cross-ground pairs) | x01 formals and return scalar typedefs, in-body, importing package; x02 one module with a walker-resolved, a walker-declined and a fixed-assoc `$size`; x03 one package in a struct bound and a parameter initializer; x04 a continued literal passed with a method call through two macros; x05 an out-of-body clone reading a var_select part select and an indexed part select; x06 an out-of-body method whose formals and return are scalar typedefs, cloned by two packages | |

### 3.1 Per law (all 208 case-views, [evidence/grid/lawtable.md](evidence/grid/lawtable.md), drivers/lawtable.py)

| law or state | case-views | UNFIRED | TOWARD | BYTES-ONLY | UNMASK | AWAY | MIXED | STAGE1-CLOSER | STAGE1-SAME | STAGE1-AWAY | DB-PRESENCE-DIFFERS | NODB | enter STRICT_EQUAL | leave STRICT_EQUAL |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| classScopeTdPkgListingParent214 | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| classTdAliasLastWriter214 | 6 | 0 | 0 | 4 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| cloneAliasFormalOwnChain214 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| cloneHpIdxNamesByChain220 | 6 | 0 | 2 | 0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 0 |
| cloneIdxOwnCopyOnly220 | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| enumClsWriterUnitScopeOnly219 | 8 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| enumPkgWriterImportsType219 | 8 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 6 | 0 | 0 | 0 | 0 |
| enumTdLastWriter214 | 26 | 8 | 5 | 3 | 0 | 0 | 0 | 2 | 7 | 1 | 0 | 0 | 0 | 0 |
| enumTdLastWriter214:R11U214_ENUMALIASGRP_OFF | 26 | 20 | 0 | 0 | 0 | 0 | 0 | 0 | 6 | 0 | 0 | 0 | 0 | 0 |
| enumTdLastWriter214:R11U214_ENUMALIASNAME_OFF | 26 | 26 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| enumTdLastWriter214:R11U214_ENUMCLSW_OFF | 26 | 14 | 5 | 3 | 0 | 0 | 0 | 2 | 1 | 1 | 0 | 0 | 0 | 0 |
| enumTdLastWriter214:R11U214_ENUMPKGW_OFF | 26 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | 0 | 0 |
| enumTdLastWriter214:R11U214_SEQARBNAME_OFF | 26 | 8 | 5 | 3 | 0 | 0 | 0 | 2 | 7 | 1 | 0 | 0 | 0 | 0 |
| fixedOuterAssocInnerReg223 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 8 | 0 | 0 | 0 | 0 | 0 | 0 |
| hpTrailIpsNamesByPath218 | 6 | 2 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 4 | 0 |
| hpVarSelColumnJoin220 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 |
| hpVarSelIpsDirectRefSkipsSelect220 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 |
| hpVarSelRangeIdxNamesByPath220 | 10 | 2 | 4 | 0 | 0 | 0 | 0 | 2 | 2 | 0 | 0 | 0 | 4 | 0 |
| importCloneSharesHomeReturn218 | 10 | 6 | 2 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 2 | 0 |
| importVarElemOwnName214 | 6 | 0 | 4 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 2 | 0 |
| lvIdxPathRangeTailIsRead218 | 4 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 4 | 0 |
| modStructMemberQualSpan214 | 10 | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 4 | 0 | 0 | 0 | 6 | 0 |
| ndaAdjSizeFoldSized223 | 14 | 8 | 0 | 0 | 0 | 0 | 0 | 6 | 0 | 0 | 0 | 0 | 2 | 0 |
| ndaSizeFoldReach219 | 30 | 6 | 0 | 5 | 0 | 0 | 0 | 12 | 7 | 0 | 0 | 0 | 3 | 0 |
| ndaSizeFoldReach219:R11U219_SIZE2D_OFF | 30 | 14 | 0 | 4 | 0 | 0 | 0 | 8 | 4 | 0 | 0 | 0 | 3 | 0 |
| ndaSizeFoldReach219:R11U219_SIZEDIM_OFF | 30 | 6 | 0 | 5 | 0 | 0 | 0 | 12 | 7 | 0 | 0 | 0 | 3 | 0 |
| newArrayBitSelIdxStripped220 | 4 | 2 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| newArrayCallArgStripped220 | 4 | 0 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| pkgQualOperandSpanInParam218 | 6 | 0 | 4 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 4 | 0 |
| ppDotNameAfterArgToken219 | 18 | 6 | 12 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 12 | 0 |
| ppIdentEndInRebuiltText219 | 16 | 6 | 10 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 10 | 0 |
| sizeReachFollowsWalker219v | 26 | 18 | 0 | 0 | 0 | 0 | 0 | 4 | 0 | 4 | 0 | 0 | 2 | 0 |
| strLitContLineSpan220 | 10 | 2 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 4 | 0 |
| strLitShiftNeedsBacktick220 | 4 | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 |
| tfArgScalarTdExportFirst223 | 14 | 0 | 0 | 0 | 0 | 4 | 0 | 0 | 4 | 6 | 0 | 0 | 0 | 4 (F/f13_exp_first_mod_plain F/f13_exp_first_mod_plain_el F/f15_exp_first_mod_localtd F/f15_exp_first_mod_localtd_el) |
| tfArgScalarTdWriter223 | 38 | 8 | 10 | 0 | 0 | 0 | 0 | 20 | 0 | 0 | 0 | 0 | 10 | 0 |
| unitImportCopyOwnTsRef214 | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 0 |
| unitImportCopyValueFollowsPkg214 | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 0 |
| unsizedInnerSizeDeclines223 | 6 | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ALLOFF | 204 | 37 | 62 | 8 | 0 | 0 | 0 | 79 | 15 | 1 | 2 | 0 | 57 | 0 |
| LANDING219 | 106 | 22 | 27 | 12 | 0 | 0 | 0 | 25 | 19 | 1 | 0 | 0 | 23 | 0 |
| LANDING220 | 56 | 10 | 31 | 1 | 0 | 0 | 0 | 11 | 3 | 0 | 0 | 0 | 24 | 0 |
| LANDING223 | 62 | 16 | 10 | 0 | 0 | 0 | 0 | 34 | 0 | 0 | 2 | 0 | 12 | 0 |
| PAIR:cloneHpIdxNamesByChain220+hpTrailIpsNamesByPath218 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:cloneHpIdxNamesByChain220+hpVarSelRangeIdxNamesByPath220 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:hpVarSelRangeIdxNamesByPath220+hpTrailIpsNamesByPath218 | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:modStructMemberQualSpan214+pkgQualOperandSpanInParam218 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:ndaSizeFoldReach219+ndaAdjSizeFoldSized223 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:ndaSizeFoldReach219+sizeReachFollowsWalker219v | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| PAIR:ppDotNameAfterArgToken219+ppIdentEndInRebuiltText219 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:sizeReachFollowsWalker219v+ndaAdjSizeFoldSized223 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 |
| PAIR:strLitContLineSpan220+ppDotNameAfterArgToken219 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:strLitContLineSpan220+ppIdentEndInRebuiltText219 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| PAIR:tfArgScalarTdWriter223+importCloneSharesHomeReturn218 | 4 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| WIDE | 204 | 37 | 62 | 8 | 0 | 0 | 0 | 79 | 15 | 1 | 2 | 0 | 57 | 0 |

Reading the table:

* **enter / leave STRICT_EQUAL** count the case-views where switching the law off loses / gains STRICT_EQUAL.
  Nothing leaves but F/f13 and f15 under § tfArgScalarTdExportFirst223 (section 4.1).
* **ALLOFF**: 57 case-views enter STRICT_EQUAL, 0 leave; the one STAGE1-AWAY is W/w02_el (section 4.2); the two
  DB-PRESENCE rows are D/d05_el and X/x02_el, where the landings off crash (rc 139) and the law writes a database.
* **ON state**: 71 STRICT_EQUAL, 26 STRICT_NOTEQUAL, 107 stage 1 (pre-existing faces: program listings, typedef
  listings imported by name, class-in-second-file listings, the `[N]` bound of unsized-inner arrays, ...), 4
  SURELOG_FAIL (D/d01, d02: Surelog aborts on a dynamic or queue inner dimension); every rc 0 but B/b03 (rc 4, an
  unsupported construct, the database written, on every state).
* **The laws the grid did not fire** (UNFIRED on every case-view they name): classScopeTdPkgListingParent214 (c04:
  its two specializations are stage 1 at the base on another face), unsizedInnerSizeDeclines223 on d01/d02 parse
  views (it runs in the elaborated view only).

### 3.2 Downstream on the fresh cases ([evidence/downstream/fresh_law.txt](evidence/downstream/fresh_law.txt), [fresh_alloff.txt](evidence/downstream/fresh_alloff.txt), drivers/dscases.py: the gate's own `one()`, a fresh golden cache)

| verdict, all landings off -> law | cases |
|---|---|
| IDENTICAL -> IDENTICAL (netlist byte-identical in both states) | 80 |
| **DIVERGENT -> IDENTICAL** | **6**: S/s01, s04, s05, s06, s10, s12 (the `$size` reach) |
| DIVERGENT -> DIVERGENT, the slang netlist closer to golden's (`_nohier.il` diff lines law / off) | 5: D/d05 13/14, S/s03 4/16, S/s07 4/12, S/s09 4/16, X/x02 8/12 (the parse view keeps the call where golden writes ExprEval's generic-handler value, section 9) |
| DIVERGENT, EQUIVALENT, STATUS_DIFF with the same netlist | D/d04, S/s11 DIVERGENT; B/b01, E/e17, W/w07 EQUIVALENT; B/b02, D/d03 STATUS_DIFF |
| SURELOG_FAIL | D/d01, d02 |
| leaving IDENTICAL | **0** |

## 4. The break, and three dump-level readings

### 4.1 The break: § tfArgScalarTdExportFirst223 declines where golden writes the token copy (refined by § tfArgScalarTdExportOwnTd226v, `R11V226_EXPOWNTD_OFF`)

Golden, the formal typespecs of the exported subroutine ([evidence/grid/F_f13_exp_first_mod_plain.txt](evidence/grid/F_f13_exp_first_mod_plain.txt) and siblings):

| case | scope of the subroutine / of the typedef | export | golden formal typespec | law (refinement on) | refinement off |
|---|---|---|---|---|---|
| pass 223 F/f21, this F/f14 | package p / p's own | before, plain and with a C name | `p::FILE_T` 3:11-3:14 (the declaration object) | = golden (name face pre-existing) | token copy (away) |
| F/f13 | module / `$unit` import | before | `FILE_T` **8:19-8:25** (the token) | 3:11-3:14 | = golden: **STRICT_EQUAL** both views |
| F/f15 | module / module-level `import p::*` | before | 8:19-8:25 | 3:11-3:14 | = golden: **STRICT_EQUAL** both views |
| F/f11 | module / `$unit` import | before, C name | 9:19-9:25, 9:29-9:32 | 3:11, 4:11 | = golden (stage 1 on another face) |
| F/f16 | package q / p's typedef imported | before | 8:19-8:25 | 3:11 | = golden (stage 1 on another face) |
| F/f17 | module / `$unit` import | task before | 8:11-8:14 | 3:11 | = golden (stage 1 on another face) |
| F/f04, v11u223 A/a14 | package p / p's own | task before | `p::FILE_T` 3:11 | = golden | - |

So the decline is right only when the formal's typedef is declared in the subroutine's own scope. Pass 223's grid
and v11u223's grid tested only package-local typedefs (f21, a14). **§ tfArgScalarTdExportOwnTd226v**
(TaskFuncEmit, next to § tfArgScalarTdExportFirst223): the export-first decline applies only when the formal's
declared type is a `TypeAliasType` whose parent scope is the subroutine's parent scope; otherwise the formal is
recorded as for any subroutine (traced `tfArgScalarTdExportOwnTd226v <sub> <formal>` under `R11V226_TRACE`).
`R11V226_EXPOWNTD_OFF`, `R11V226_OFF` or `R11U223_OFF` give the law's bytes.

Measured ([evidence/fix_byte_reach.tsv](evidence/fix_byte_reach.tsv), drivers/lawfix.sh: law, fix, and fix under
`R11V226_OFF`, both views, every case directory of r11u219repro, v11u219repro, r11u220repro, v11u220repro,
r11u223repro, v11u223repro and this directory, 542 directories, 1084 case-views):

* **10 case-views move, all by this refinement's firings**: F/f11, f13, f15, f16, f17 in both views. f13 and f15
  go STRICT_NOTEQUAL `line` -> **STRICT_EQUAL** (both views); f11, f16, f17 stay stage 1 on their other faces with
  the order-blind dump distance to golden falling (f11 23 -> 19 / 36 -> 28, f16 40 -> 36 / 56 -> 48, f17 21 -> 19 /
  34 -> 30), every changed line a formal typespec moving to golden's token span.
* **1074 case-views keep the law's bytes** (pass 223's f21, f24, v11u223's a14, this pass's f04, f14 included);
  **`R11V226_OFF` gives the law's bytes on all 1084**; rc 0 on every case-view but the ten rc-4 ones (unsupported
  constructs, database written, the same on both binaries).
* The fix's census over every non-fenced corpus row-mode and every probe case finds **no firing** of this
  refinement (no corpus design exports a subroutine before its definition with an imported typedef formal).

### 4.2 Three dump-level readings, not breaks

* **§ sizeReachFollowsWalker219v (S/s03, s07, s09, X/x02, parse view; STAGE1-AWAY against its own switch).** Per
  net ([evidence/size/sizevals.txt](evidence/size/sizevals.txt), drivers/sizevals.py): where the refinement keeps the
  call, the unrefined law wrote a value golden does not hold (`$size(ia, 3)` of `int ia [3][5]`: golden `UINT:160`,
  unrefined 32; `$size(ea, 3)` of an enum `logic [4:0]` array: golden 15, unrefined 5; `$size(by, 3)` of
  `byte by [3][2]`: golden 16, unrefined 8; `$size(ea, 3)` in x02: golden 9, unrefined 3; `$size(ma)` of
  `int ma [4][int]`: golden 32, unrefined 4). Wrong to less wrong: the call is what the base wrote, and the dump
  metric counted the call's subtree. Every value the refined law writes equals golden's (s03 w0-w2, s07 w1-w2, s09
  w0-w2, s05 w0-w4, s12 w0-w2).
* **§ enumPkgWriterImportsType219 (W/w04, w04b, w11; stage 1 at the base on every state).** When a package imports
  the ALIAS by name (`import p::VAL_T;`) and another package imports the home package by wildcard, the refinement
  declines the base enum's writer; the only change against its own switch is one `vpiParent` of the base enum in
  the wildcard importer's listing: golden `aq`, the refinement none, the unrefined law `aq`. No record either
  comparator reads moves (the child references' stored names are the same), the shapes are stage 1 on a
  pre-existing face (the alias typedef listing of the by-name importer), and nothing is synthesized from them.
  Reported as a residue of the refinement (section 9), not a three-axis break.
* **§ enumTdLastWriter214 on W/w02 elaborated (a `$unit` class nested three levels).** Golden gives the enum
  alias one object per nested listing class (raw full names `work@outer_c::mid_c::inner_c::p::ALIAS_T` twice,
  `work@outer_c::mid_c::p::ALIAS_T`, `work@outer_c::p::ALIAS_T`); pristine held three of the four names, the law
  holds the one object named after the outer class at every position. This is the per-class identity family the
  comparator excuses by design (golden gives the object more than one name, ours is one of them; r11u219 README
  section 2.3), and the case is stage 1 at the base on another face (golden's listing of the third-level class).
  On the judge-equal two-level twins W/w09 and w10 the law moves only toward golden, canonical (7, 46, 34 records)
  and raw (strictcmp_x on w10 elaborated: 0 new, 34 gone).

## 5. Composition

### 5.1 Status level ([evidence/compose/compose_status.txt](evidence/compose/compose_status.txt), drivers/compose.py over L, A and the three single-off sweeps)

| stage | conversions A -> L | owner |
|---|---|---|
| probe | 26 | **OWN219 10** (g1_assoc_class_elem_import, g1_assoc_index_import, g2_dynarray_elem_import, g3_dynarray_class_elem_import, v1_fixedarray_elem_import, v3_elem_class_of_importing, v8_unpacked_sel, a8_single, v116_u, v133_f_macro), **OWN220 11** (r10earl_repro/i, g111_a, g127_c_import, a11_nested, v111_b1, v111_b2, v111_b7, v147_i, gv184_h_retpin, v194_e_explclone, h03_gen), **OWN223 4** (g125_b_shapes, g125_d_homes, t47a, t47b), **JOINT220+223 1** (t48c) |
| surelog | 0 | - |
| uhdm2rtlil | 2 | **OWN220**: anon_struct_packed_dim d/t |

Every claimed conversion is its landing's own. t48c: 223 alone (220 off) reads `fullname(3)` (pass 220's family),
220 alone (223 off) reads the base's `line(8)`, both convert it: each law removes its own records, same direction.
**CANCEL (a row the same in L and A but different with one landing off): 0 in all three stages.** The surelog
CHANGE rows are JOINT as expected (Earlgrey 219+220, the UVM rows 219+223 or all three, BuildUVMPkg OWN220).

### 5.2 Byte level ([evidence/compose/compose_bytes.txt](evidence/compose/compose_bytes.txt), drivers/bytecancel.py)

7452 databases (4087 probe, 2560 non-fenced corpus, 805 downstream lanes): SAME 7311, OWN219 86, OWN220 28, OWN223
13, JOINT 14 (Earlgrey d/t 219+220; t47a/b 219+223; t48c and the UVM rows three-way), **CANCEL 0**. Downstream lanes
moved: OWN219 6 (PackageCast, TypedefAliasInPackage, TypedefEnum, VarPassedTo2Submodules, ibex_branch_predict,
ibex_decoder), OWN220 1 (anon_struct_packed_dim), each lane's `.il`, `_nohier.il` and `_synth.v` byte-identical
between A and L, every verdict IDENTICAL.

### 5.3 Each landing's movers against its frozen prediction ([evidence/compose/movers_vs_frozen_predictions.txt](evidence/compose/movers_vs_frozen_predictions.txt), drivers/predcheck.py)

| landing | prediction (md5) | movers at HEAD (L vs its single-off) | unpredicted | predicted, not moved |
|---|---|---|---|---|
| 219 | r11u219repro evidence/census/prediction.txt (`3651a45b`, 96) | 94 | 0 | 2: r10uvm202repro/g202_e_head, r10v202repro/v202_6_twotd (pass 215 already writes those bytes: they converted with pass 215, r11u219 section 4.1 "the pass's own 22 less the 12 pass 215 had converted") |
| 220 | r11u220repro predict_final.txt (`3da1adc3`, 40) | 39 corpus + probe, + the downstream lane | 0 | 0 |
| 223 | r11u223repro prediction_frozen.txt (`49ac9f3d`, 25) | 25 | 0 | 0 |

### 5.4 The cross-ground pairs (X/, every pair switched off, both views)

| pair | case | result |
|---|---|---|
| § tfArgScalarTdWriter223 + § importCloneSharesHomeReturn218 | X/x06 (out-of-body, two cloning packages) | **STRICT_EQUAL in both views only with both**; each law alone TOWARD (18 and 3 records), the pair off TOWARD: same direction |
| same pair, in-body | X/x01 | STRICT_EQUAL both views; the clone law does not fire in-body |
| § ndaSizeFoldReach219 + § sizeReachFollowsWalker219v + § ndaAdjSizeFoldSized223 on one module | X/x02 | elaborated view: the three nets' constants equal golden's value, size and (no) location on the law (`UINT:5` size 4, `UINT:9` size 4, `UINT:32` size 6); v219 off writes 3 and 4 (wrong), 223's adjuster off leaves size 64 at the call span, 219 off leaves the adjuster to fold all three to golden's, 223 off entirely crashes (rc 139). Parse view: w1 folded to golden's, w2 and w3 kept as the call (golden folds them: residue) |
| § modStructMemberQualSpan214 + § pkgQualOperandSpanInParam218 | X/x03 | STRICT_EQUAL both views; each alone TOWARD |
| § strLitContLineSpan220 + the two pp laws | X/x04 | STRICT_EQUAL both views; laws UNFIRED/TOWARD |
| § cloneHpIdxNamesByChain220 + § hpVarSelRangeIdxNamesByPath220 + § hpTrailIpsNamesByPath218 | X/x05 | stage 1 at the base (clone listing); every law and pair STAGE1-CLOSER |
| § enumTdLastWriter214 + pass 215's § pkgTdAliasLastWriter215 | - | pass 224 is measuring it and has not landed; not duplicated here |

## 6. The CHANGES: strict improvements or unmaskings ([evidence/unmask/](evidence/unmask/), drivers/unmask2.py)

Each landing's before and after, as switch states at HEAD: 219 = A -> 896ec643; 220 = 896ec643 -> 223 off; 223 =
223 off -> L. Every row whose strict verdict differs is re-read record by record (golden against each database):

| landing | surelog | probe | uhdm2rtlil |
|---|---|---|---|
| 219 | Earlgrey d/t `endcol(45)` -> `endcol(39)` SUBSET (6 records gone, same first record); MiniAmiq, SeqDriver d/t `endline(59)` -> `file(7)` SUBSET (52 gone); SimpleUVM d/t `fullname(185)` -> `file(56)`, Scoreboard d `fullname(137)` -> `file(32)` UNMASK (1 new record, past the base walk's divergence, 130 / 106 gone) | 44 rows: CONVERSION 10, SUBSET 20, UNMASK 13, NEW 1 (g19_builtin, below) | none |
| 220 | BuildUVMPkg d/t `line(31)` -> `line(19)` SUBSET (same first record); Earlgrey d/t `endcol(39)` -> `fullname(19)` SUBSET (20 gone); SimpleUVM d/t `file(56)` -> `file(54)`, Scoreboard d `file(32)` -> `file(30)` SUBSET (same first record) | 22 rows: CONVERSION 11, SUBSET 8, UNMASK 3 (g193_c_argface and g207_e_head growing with the **same first record**, the base walk diverging at 2781 / 397 and the law's aligned; v111_b6) | anon_struct_packed_dim d/t CONVERSION |
| 223 | MiniAmiq, SeqDriver d/t `file(7)` -> `line(2)` SUBSET; SimpleUVM d/t `file(54)` -> `file(40)`, Scoreboard d `file(30)` -> `file(16)` SUBSET | 6 rows: CONVERSION 5 (t48c here), SUBSET 1 (t48a `line(10)` -> `name(2)`) | none |

**g19_builtin (r10v112repro, landing 219, "NEW" 2):** records #4 and #23, the same `type_parameter Q` objects:
before, the first differing field was the raw full name (`p19use::Aa19::p19use::t19::Q`, golden
`p19use::p19use::t19::Q`) with the pre-existing file and span difference behind it; after, the name is golden's and
the file is the first field. #5 and #24 (its `ref_typespec`s) are gone. A strict improvement; the index-free
multiset only sees the changed first-field label.

## 7. Determinism and the MiniAmiq coin ([evidence/det/draws.txt](evidence/det/draws.txt), drivers/det.sh: three concurrent harness runs per row-mode with the L sweep's command lines)

| row-mode | law.bin | law.bin + `R11U220_OFF` | fix.bin | fix.bin + `R11V226_IDORDER_OFF` |
|---|---|---|---|---|
| Earlgrey_0_1 d / t | 1 hash each (= sweep) | 1 each (`6a8fcde9f0f9` / `dc6bc45475ff`, pass 219's hashes) | 1 each, = law | - |
| MiniAmiq d | **3 hashes in 12 draws** (`accabd75`, `1d91262b`, `c65b7c37`) | 2 in 3 | **1 in 12** (`2f2ed6b2`) | 2 in 3 (`accabd75`, `c65b7c37`: the law's) |
| MiniAmiq t | **2 hashes in 12** (`c65b7c37`, `1d91262b`) | 1 in 3 | **1 in 12** (`2f2ed6b2`) | 1 in 3 (`accabd75`) |
| SeqDriver, SimpleUVM, BuildUVMPkg d/t | 1 hash each | 1 each | 1 each | - |
| Scoreboard d | 1 in 3 (≠ the sweep's) | 3 in 3 | 2 in 3 | - |

* Every variant of a row reads one uhdm-dump (unsorted): MiniAmiq's three law variants, the fix's, the 220-off
  pair; Scoreboard's variants differ unsorted and agree sorted on every binary (the svunit listing-order coin,
  pre-existing, not this drain).
* **Pass 220's laws add no coin** (v11u220's missing check): the with/without columns show the same coins (MiniAmiq,
  Scoreboard) and one hash everywhere else.
* **§ fullNameDrainIdOrder226v** (ExprEmit `refFullNameThroughNamedExpr175`, `R11V226_IDORDER_OFF`): the drain's four
  `AllObjects()` loops iterate one vector of the objects sorted by UhdmId. The names it sets are computed by
  `chainFullName175` from the chain's VpiName / VpiDefName only, never from a full name the drain sets, so the order
  changes which string is registered first and nothing else. The fix's uhdm-dump equals the law's on MiniAmiq d,
  SeqDriver d/t, SimpleUVM d/t, BuildUVMPkg d and Scoreboard d (0 lines unsorted); its bytes differ from the law's
  in the symbol table's order only. Pass 224's patch (`/tmp/r11u224.patch`, read only) adds two drains beside this
  call and does not touch the loop; the two compose textually.

## 8. v11u220's three checks

1. **Determinism with and without pass 220's laws**: section 7.
2. **UVM order-blind distance** (tools/probe/r11u220repro/drivers/uvmdist.sh; [evidence/uvm/](evidence/uvm/)): at the
   `57ce3ae8` switch state (the three landings and r11u221's refinements off, the five UVM rows) against the same +
   pass 220: **MiniAmiq 6266 -> 2786 (total 14256 -> 8615), SeqDriver 4969 -> 2493 (10724 -> 7091), SimpleUVM 1903
   -> 1894, Scoreboard 1393 -> 1386, BuildUVMPkg 673 -> 648: the implementer's numbers exactly**. At HEAD (220 off
   -> L): MiniAmiq 5238 -> 1774, SeqDriver 3779 -> 1319, SimpleUVM 934 -> 925, Scoreboard 601 -> 594, BuildUVMPkg
   267 -> 242 (the 220-off values are pass 223's claimed post-law distances).
3. **The corpus-wide reversed positive control** (tools/probe/r11u220repro/drivers/awayrows.py, strictcmp_x raw
   names, chain-keyed and flat, [evidence/away/](evidence/away/)): 220 off -> L over the 39 moving databases:
   **away 0, toward 7730**; reversed (L as the off side): **away 7730, toward 0**. The flat column reads 662 away
   (MiniAmiq d/t 170 each, SeqDriver d/t 159 each, g208_e_head 4; 598 at pass 220's base: 16 more per UVM row-mode
   with pass 223's copies); with `R11U218_CLONERET_OFF` on MiniAmiq and SeqDriver both modes the flat away reads **0**
   (908 and 603 toward): all of it is § importCloneSharesHomeReturn218's unreferenced return-variable subtrees, as
   pass 220 attributed.

## 9. Residues, re-measured at the base ([evidence/residues/](evidence/residues/))

| pass | residue (its README's rank) | at `4a620bd0` |
|---|---|---|
| 219 | 1 `typedef int UVM_FILE` heading the UVM rows | **closed** by pass 223 (the heads are now `UVM_SEQ_ARB_TYPE` / `this_type`) |
| 219 | 2 Earlgrey's `dm::` qualifier span (ground A) | **closed** by pass 220 (§ pkgQualOperandSpanInParam218; Earlgrey's first record is now `fullname(19)`) |
| 219 | 3 the enum writer's identity family | stands (excused by the comparator; W/w02 above) |
| v11u219 | 2 the generic-handler `$size` values | **stands in the parse view** (S/s03 w3 160, s07 w3 15, s09 w3 16, x02 w2 9 / w3 32, d03, d04, d05: golden folds, ours keeps the call; downstream DIVERGENT on those nets); the elaborated view writes golden's since pass 223 |
| v11u219 | 3 the elaborated `$size` crash | **closed** by pass 223 (d01, d02, d05, x02 elaborated: rc 139 with the landings off, rc 0 and the call kept on the law) |
| 220 | 1 the sister-ground halves | stand: InterfArrayBind d `fullname(1)`, OutputSize...StructMember d/t `line(8)`, cfg_func_width_loop d/t `line(3)`, struct_param_func_config d/t `fullname(5)` |
| 220 | 2 the backtick-blank shift | stands (SL s30, s35 `endcol`, both views) |
| 220 | 3 a continued literal in a class property or variable initializer | stands (SL s48, s50 `endline`; this pass's E/e16, e17 the same face) |
| v11u220 | 1 backtick-tab | stands (T/t12 `endcol`) |
| v11u220 | 2 conditional ending at a continued literal | stands (K/k04 `endline`; this pass's E/e15) |
| v11u220 | 3 continued literal from a macro | stands (K/k09 `endcol`) |
| 223 | 1 `UVM_SEQ_ARB_TYPE` | stands: MiniAmiq/SeqDriver d/t `line(2)`, first record #24915 1381:51 vs golden 332:40 (decode case E_externalias/e04 stage 1) |
| 223 | 2 `this_type` | stands: SimpleUVM d/t `file(40)` #26887, Scoreboard d `file(16)`, BuildUVMPkg d/t `line(19)` #26855 (T_oobthistype/t01 stage 1) |
| 223 | 3 package-qualified scalar formals | stands (F/f13 `line`, both views) |

Pass 224 (landed at `ac0dda58` after these measurements) reports T/t12, T/t14, SL s30-s32 s35 s36 s38 s39, K/k04,
s48, s50, C/c23, G/g07 and NW/w17 EQUAL in both views: of the rows above, pass 220's residues 2 and 3 and v11u220's
1 and 2 are closed there (not re-measured here; this pass kept its base).

New residues this pass found:

1. **Non-integral scalar typedef formals** (F/f05): golden also gives `real`, `shortreal`, `string`, `chandle` and
   `time` typedef formals their own copy at the formal's token (golden `real_typespec t_real` 10:21-10:27); the law
   admits int, integer, byte, shortint, longint, bit and logic only. Stage 1 at the base, law-invariant.
2. **§ enumPkgWriterImportsType219's by-name alias** (W/w04, w04b, w11): an import of the ALIAS by name counts as
   "listing without importing" for the BASE enum, which then keeps no parent where golden parents it at the
   wildcard importer (section 4.2). Dump-level only.
3. **Nested `$unit` class listings three levels deep** (W/w02): golden lists the third-level class in the
   elaborated view where ours has none (stage 1), and gives each nested listing its own alias name.
4. **`$size` with a genvar dimension argument** (S/s11): downstream DIVERGENT on both binaries, stage 1 in both views.

## 10. Fence and process

### 10.1 This pass

* Every driver here sources [drivers/env.sh](drivers/env.sh), which reads the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh (fail closed on anything but four) and **refuses to run unless `SURELOG`,
  `UHDM_CMP`, `UHDM_DUMP` and `STRICT_CMP` are executable files**; case.sh repeats that check and refuses a fenced
  path; compose.py, bytecancel.py, predcheck.py, unmask2.py, fenceaudit.py skip fenced corpus paths unread by word
  boundary; det.sh runs a fixed row list checked against the fence. The gate sweeps dispatched every row as the
  gate mandates; only their csv verdicts and non-fenced databases were read. A grep of this directory for the four
  names, as words and as substrings, reads 0.
* No binary, gdb or script ran on a fenced test's sources or databases outside the gate sweeps. No gdb at all.
* Builds `-j 2`, the fix's rebuild check `-j 2` with memory checked first (a reversed census held 5 GB for a while;
  the rebuild waited). Binaries frozen before measurement; no source edited while its build ran. No stash;
  `GOLDEN_DEFER` unset; nothing under `results/`, `tests/` or `third_party/` written. Scratch `/tmp/r11u226_*`,
  worktrees `/tmp/wt_r11u226`, `/tmp/wt_r11u226fix`, `/tmp/wt_r11u226rb`. Every process stopped was this pass's
  own (none was).
* The fix's prediction was frozen before its gate sweep ([evidence/census/prediction_fix.txt](evidence/census/prediction_fix.txt),
  md5 `eede7036`, stamp with the binary's md5 and the time, [prediction_fix.stamp](evidence/census/prediction_fix.stamp)).

### 10.2 The six directories ([fenceaudit.txt](evidence/fence/fenceaudit.txt) static, [fencecheck.txt](evidence/fence/fencecheck.txt) runtime, [casefirst.txt](evidence/fence/casefirst.txt))

* **env.sh, runtime**: all six read 4 names from the checkout (rc 0) and refuse a scratch copy beside a two-name
  canaudit.sh (rc 1, 2 names). r11u220repro's and v11u220repro's abort the shell (`${SURELOG:?}`) when the tools are
  unset: fail closed; with the tools set they read 4 names and refuse the two-name copy likewise.
* **The fence per driver** (static): every driver that touches corpus sources or databases reads the fence itself
  or sources its env.sh; the ones without their own check (r11u219repro away2.py, recctx.py, unmask.py, dsfaces.sh,
  grid.sh; v11u219repro sizevals.py, dsfaces.sh, grid.sh; r11u220repro caseaway.py, dumpaway.py, gridaway.sh,
  pairs.sh, reach205.sh, switches.sh; v11u220repro vaway.py, vaway1.py, vgrid.sh; r11u223repro away2.py, grid.sh,
  switches.sh; v11u223repro caseaway.py, grid.sh, switches.sh, symlist.sh) read case workdirs or database triples a
  fenced caller hands in, or run the directory's own cases through its fenced case.sh. **No file of the six names a
  fenced test** (word and substring).
* **Predictions**: pass 219 `prediction.txt` md5 `3651a45b` as claimed, stamp `prediction_frozen_at.txt` 22:02:27
  before the law sweep's 22:02:38 (the md5 is in the README, not the stamp); v11u219 `118c883e` as claimed, stamp
  23:45:58 before 23:46:09; pass 220 `3da1adc3` as claimed, stamp with the md5 and law.bin's md5, 00:56:19 before
  00:56:29; v11u220 `c11a57e9`, stamp 02:06:32 with the md5 and law.bin; pass 223 `49ac9f3d` as claimed, **but no
  stamp file** (the freeze before the sweep is asserted in its README only); v11u223 `375725b8`, its
  `prediction_frozen.md5` holds the md5 and "as frozen, before the law sweep" without a time.
* **Packaged cases**: r11u219repro 35, v11u219repro 52, r11u223repro 41, v11u223repro 53, v11u220repro 109 cases,
  every one naming a law on its first line; r11u220repro 150 cases, 114 naming a law and 36 marked
  `r11u220 decode` (SL s30-s39, IA, NW w02-w07 and w17, TN: the controls and residues its README says carry no law).
  Every named law exists in the sources (three of pass 223's in `uhdm_main.cpp`, outside `src/`).
* **Tool-variable guards** (the mechanism that twice executed a `.uhdm` as a script): the drivers that run a tool
  through a variable as a shell command word **with no executable check of their own**:

  | driver | runs | safe only if |
  |---|---|---|
  | r11u219repro/drivers/case.sh | `$SURELOG`, `$UHDM_CMP $g $o`, `$STRICT_CMP` | the caller exported FENCED and S after sourcing env.sh (it does not source env.sh itself) |
  | r11u220repro/drivers/case.sh | the same | the same (its env.sh aborts on unset tools) |
  | v11u220repro/drivers/vcase.sh | the same | the same |
  | r11u223repro/drivers/case.sh | the same | it sources env.sh only when FENCED is unset: a caller with FENCED exported and UHDM_CMP unset executes the golden database |

  v11u219repro/drivers/case.sh sources its env.sh unconditionally (literal tool paths) and v11u223repro's env.sh
  tests `-x` on three tools (not STRICT_CMP, which every env.sh defaults to `$B/uhdm-strictcmp`, a path, never
  empty). The Python drivers pass a tool as argv[0] (an unset variable raises; no database is executed).
* **Hard-coded scratch** (what each needs to re-run): r11u219repro `B=/tmp/r11u219_bin` (pristine, law_r6,
  uhdm-strictcmp; overridable), `/tmp/r11u219_awaycache`, uvmdist.sh `/tmp/r11u219_bin/uhdm-strictcmp`,
  `/tmp/r11u219_s`; v11u219repro `/tmp/v11u219_bin`, `/tmp/v11u219_g`, `/tmp/v11u219_awaycache`,
  `/tmp/v11u219_sizevals.rec`, lawfix `/tmp/v11u219_lf.*`; r11u220repro and v11u220repro none (B and S from the
  caller, both required); r11u223repro `/tmp/r11u223_bin` (overridable), `/tmp/r11u223_s`, `/tmp/r11u223_awaycache`;
  v11u223repro `/tmp/v11u223_bin`, `/tmp/v11u223_s`, det.py `/tmp/v11u223_det`, `/tmp/v11u223_wP` (a sweep). Every
  frozen binary directory they name was on disk when this pass ran except where they were pruned at landing; each
  directory re-runs given its pristine and law binaries in `$B`.

## 11. Process notes

* The first scoring of the grid counted the weaklyReferenced tail in the order-blind distance and flagged F/f04
  (§ tfArgScalarTdWriter223) STAGE1-AWAY: the 16 "new" lines were the minted copies listed in the tail, while the
  reachable dump moved toward golden (8:34-8:40). grid.py now cuts the tail (RESCORE=1 re-scored the saved outputs);
  every figure here is the re-scored one.
* Seven cases were edited after a first triage run, before their grid: B/b03 (`fl.num()` on a fixed-then-associative
  array, which slang rejects), D/d02 (`$size(m, 2)` of a dynamic dimension, which slang rejects), P/p06
  (`(h).get_name()`, which Surelog rejects), S/s13 (`$size` of a string-keyed array, which slang rejects), and W/w02,
  w03, w05 (a class-typed member, a method and a program variable removed to leave fewer pre-existing stage-1 faces).
  The golden cache keys on the case's file hashes, so each golden was rebuilt.

## 12. Files

* **fix.patch**: src/R226.h, src/TaskFuncEmit.cpp (§ tfArgScalarTdExportOwnTd226v), src/ExprEmit.cpp
  (§ fullNameDrainIdOrder226v). Not applied.
* **cases/**: B 3, C 5, D 5, E 23, F 17, P 8, Q 4, S 14, U 3, V 3, W 13, X 6 (104). Two-file cases carry an `args`
  file; P/p04 an included header.
* **drivers/**: env.sh (pins, fence, tool guards), case.sh, grid.py and laws.py (r11u221's grid with this pass's
  switch map; RESCORE), gridall.sh, quick.sh, lawtable.py, sizevals.py, dscases.py, sweep.sh, compose.py,
  bytecancel.py, predcheck.py, unmask2.py, det.sh, census.sh, predict.py, lawfix.sh, fenceaudit.py (with the
  tool-guard and scratch columns), fencecheck.sh, casefirst.py.
* **evidence/**: grid/ (per case-view results, state lines, law table), downstream/, compose/ (status, bytes,
  prediction checks, sweep logs, binary audit), unmask/, uvm/, away/, det/, size/, residues/, fence/, census/, fix/,
  fix_byte_reach.tsv.
