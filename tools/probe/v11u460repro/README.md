# v11u460 — adversarial verification of r11u460 (pass 460, module/type ground)

Base 8acef805 (pass 458). The implementer's patch /tmp/r11u460.patch applies clean on a fresh
8acef805. The rebuilt law binary is byte-identical to the implementer's law12 (md5
53869f80635c0d3470cf7ac0da0b1dbc, slang 12.0.0+545f88b2e). Pristine is the base build, md5
2bc868e0bde5fcc16f311b8b0d5cd30c, equal to the main tree's base build. The verified binary (md5
6a6f84b3d0affcc29ed4e2cb5267a847) adds two refinements, both in src/UhdmExporter.cpp with a
declaration in src/TypeEmit.cpp. No src/R*.h, no getenv, no header change.

**VERDICT: CONFIRMED WITH TWO BREAKS FIXED.** The conversion stands:
`generated/uvm-examples/uvm_id_register.sv,STRICT_NOTEQUAL,differ:name(5),differ:name(5)`
(DIFFERENT -> STRICT_NOTEQUAL, uhdm-cmp equal). It reads the same on the law and on the verified
binary.

## The two breaks (pristine right, law wrong, on legal SV upstream slang accepts)

1. **§ elemBitsByExprEvalSize460v** (R11V460_ELEMBITS_OFF; cases VZ/vz15 to vz20). This refines
   § clsArrPatBasedLitElemW460 and § modArrPatBasedLitElemW460.
   - The law sized a based literal at slang's element bit width. Surelog's adjustSize uses
     Bits(element typespec), which is UHDM's ExprEval::size:
     - real and shortreal give 32;
     - time and realtime are a time_typespec. ExprEval::size has no branch for it, so the size is
       invalid and the literal keeps its own -1.
   - THE BREAK: `time tf[2] = '{'h1, 'h2}`, `time td[] = ...`, `realtime t[] = ...` and the class
     twins (module and class, fixed, dynamic and queue). Golden -1 equals pristine; the law wrote
     64.
     - vz15 line 5 and vz17 lines 4 and 6: pristine right, law wrong.
     - vz19: strict distance 6 -> 14 on the law, 2 on the verified binary.
     - vz18: lines 4 and 5.
   - Also fixed:
     - real gets 32 where the law wrote 64: golden 32, pristine -1; vz16 becomes STRICT_EQUAL.
     - A packed array of more than one dimension now abstains. `logic [1:0][3:0]` has golden 4,
       the law wrote 8 and pristine -1; vz20 is back to pristine's -1 at the same distance.
   - The fix computes the width once per operand through basedLitElemFire460 (UhdmExporter) at all
     five sites, and logs lawTrace(460, "elemBitsByExprEvalSize460v", ...) whenever it changes the
     width.
2. **§ oobScopedCallKeepsHome460v** (R11V460_OOBSCOPED_OFF; cases VO/vo11, vo17, vo01). This
   refines § oobCopyCallBindsBodyHomeClone460.
   - Take a PACKAGE-SCOPED call `p::t(v)` or `p::f(v)` in the out-of-body method. In both q's
     definition and s's copies, golden binds p TOP (call-link census, drivers/linkcensus.sh).
   - The law re-pointed s's two copies to q TOP. That is pristine right and law wrong on a link
     neither judge reads:
     - vo11 (task shape) and vo17 (class-extends shape): pristine 1+1 golden-only/ours-only links,
       law 3+3, verified 1+1.
     - Both cases are STRICT_EQUAL on all three binaries.
   - The fix makes the law abstain on a call whose name is scoped, so § 446's target stands.
   - Bytes on vo01, vo11 and vo17 equal pristine again.

Switches:
- `R11V460_OFF=1` on the verified binary gives the law's bytes on 95 of 95 case dirs (70 here and
  the implementer's 25).
- `R11U460_OFF=1` gives pristine's bytes on 95 of 95.
- Each refinement's own switch alone gives the law's bytes on its own movers
  (evidence/switchcheck_refinements.txt).
- The verified binary differs from the law binary on exactly the 10 dirs named above.

## The implementer's numbers reproduced

- **Grid:** 25 of 25 case dirs reproduced on rc, uhdm-cmp count and strict verdict
  (evidence/implementer_grid_reproduced.txt). Its switch evidence also stands: on 25 of 25,
  R11U460_OFF equals pristine.
- **Law sweep:** one full five-stage sweep on law12 (/tmp/v11u460_swp). The probe, surelog,
  uhdm2rtlil and downstream csvs are byte-identical to the master's control /tmp/intr11u458
  (the workdir names have the same length).
  - probe: 4023 + 64, 0/0/0.
  - surelog: 480 / 474, 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes, 0/0/0.
  - downstream: 803/66/2/0.
  - sv-tests, against the base golden: regressions 0, conversions 1, changes 0. EQUAL 1928,
    STRICT_NOTEQUAL 1, DIFFERENT 11, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19,
    SURELOG_CRASH 8, TIMEOUT 1. The csv is byte-identical to the implementer's.
  - The corpus command exited 1 on the stale law index alone.
- **Byteverify** (law against the control): 35 movers of 3408, the implementer's exact set. The
  MiniAmiq default and testflags hash is 6f8fb21fe3f4 on both runs (deterministic). SELFCHECK
  reads 3406 of 3408: the known duplicate pair.
- **Trace** (evidence/trace_law_sweep.txt):
  - MiniAmiq default and testflags: the two interface laws.
  - The 8 uvm-examples rows named by the implementer.
  - Nothing in probe, uhdm2rtlil or downstream.
- **id_register**, strict against the cached golden: name(5), the five
  `uvm_pkg::uvm_reg_addr_t` vs `uvm_reg_addr_t` bit_typespec records.
- **Canaries:** ok=52 and ok=16; both ctcan2 checks pass, on both sweeps.
- **Binary audit:** surelog 1531 of 1581 records name the binary under test, and the other 50
  hold only a Surelog line; uhdm2rtlil 1742 of 1742; sv-tests 2346 of 2346. This holds on both
  sweeps.

## The verified sweep (one, on the verified binary, /tmp/v11u460_swv)

- **Prediction**, written before the sweep (evidence/prediction.txt): neither refinement fires
  anywhere and every csv equals the law sweep's. **It held:**
  - The probe, surelog, uhdm2rtlil, downstream AND svtests csvs are byte-identical to the law
    sweep's.
  - The trace equals the law sweep's, with no 460v firing.
  - Byteverify against the control gives the same 35 movers.
  - Byteverify against the law sweep gives 0 corpus movers. Its 33 sv-tests raw-byte movers are
    all STRICT_EQUAL under uhdm-strictcmp --no-canon (evidence/ver_vs_law_svtests_strict.txt):
    the serialization variance pass 457 recorded.
- **Log slip:** the launcher appended the corpus exit line ("corpus rc=1", the stale law index)
  to the law sweep's log instead of its own. sweep_law_corpus.log therefore ends with two
  `corpus rc=1` lines. No measurement is affected.

## Attack grid (70 fresh case dirs, every one accepted by upstream slang, every exit code 0 except VZ/vz05)

- VZ/vz05 exits 4 on all three binaries. The cause is a class `real r[]` property ('class array
  property element'), a goal-1 face on this ground (residue).
- Readings are uhdm-cmp lines, the strict verdict and a strict-record multiset distance to
  golden. The distance uses drivers/sdist.sh with a stage-2-forced build of uhdm-strictcmp
  (drivers/tools/sc2_force_stage2.diff).
- Call links come from drivers/linkcensus.sh, built from drivers/tools/links.cpp, the v11u455
  tool.
- Full table: evidence/grid_attack_table.txt (pristine | law | verified).

**VZ (20 cases: the based-literal laws).**
- To STRICT_EQUAL: vz01, vz02, vz07, vz09, vz10 and vz13 (int, byte, shortint overflow, int
  unsigned, queues, a module concatenation, a program, one-bit and 128-bit elements); vz16 on the
  verified binary only.
- Closer: vz03 (interface and generate carriers; function local unchanged), vz04 (signed
  literals), vz08, vz11 ('b110), vz15, vz17, vz18, vz19 and vz05.
- Unchanged: vz06 (a module packed-struct element, golden 4: the law does not fire), vz12, vz14
  and vz20.
- No case is away from golden on the verified binary.

**VO (19 cases: the out-of-body copy call law).**
- vo12 (explicit import p::t): 756 -> STRICT_NOTEQUAL type.
- vo16 (two tasks and a function in one body): 1400 -> STRICT_EQUAL.
- vo18 and vo19: links toward golden.
- vo11 and vo17: the break, fixed.
- The 78-line cases are copies golden does not write (as OB/ob02): unjudgeable, and the same
  distance on all binaries.
- vo05 and vo15 (the class home declares its own callee) and vo13 and vo14 are controls,
  byte-identical.

**VS (16 cases: the specialization laws).**
- To STRICT_EQUAL: vs10 (explicit import u::S), vs13 (two packages specializing a class with
  this_type, which pins § clsNestedSpecCloneHomeInst460's instance at a's package as golden does)
  and vs15.
- vs15 is the ONLY case where § specGroupAliasFlatRoot460 fires. On the implementer's grid it
  fired nowhere. With R11U460_SPECALIASROOT_OFF alone vs15 reads STRICT_NOTEQUAL depth.
- Closer by strict distance: vs04 (export route; uhdm-cmp 104 -> 168 with the same head), vs07,
  vs08 (180 -> 244, same head), vs11, vs12, vs14 and vs16.
  - vs04 and vs08 grow in uhdm-cmp lines only because the newly listed REQ prints under the same
    paired head object.
- Byte-identical controls: vs01 (value parameter), vs02, vs03 (u::S without import), vs05 (bare
  S), vs06 (class-scope typedef) and vs09 (module typedef).
- The this_type vpiInstance, read from the dumps: golden a, pristine the importer, the law a, on
  vs11, vs13, SQ/sq05 and sq06.

**VI (6 cases: the interface laws).**
- vi03 and vi04 go to STRICT_EQUAL; vi01, vi02 and vi05 are closer.
- vi06 is the control: the interface also imports the transitive package directly. It is
  byte-identical.

**VN (9 cases: the implicit-net order).**
- vn01, vn02, vn03, vn05, vn06 and vn09 go 32 -> STRICT_EQUAL (order only).
- vn08 (implicit net named like a forwarded member) goes 32 -> STRICT_NOTEQUAL line.
- vn04 (generate block) and vn07 (interface) are unchanged.

**Downstream sample** (evidence/downstream_sample.txt):
- No case leaves IDENTICAL.
- VN/vn09 goes EQUIVALENT -> IDENTICAL.
- vz15 is DIVERGENT and vz18 STATUS_DIFF on all three binaries.

**Earlier grids** (r11u450 to r11u458 and v11u450 to v11u458, 793 case dirs, pristine against
verified; evidence/earlier_grids_bytecheck.txt):
- 789 are byte-identical and every exit code is equal.
- 4 move, all toward golden:
  - r11u450 IT/it02: 336 -> STRICT_EQUAL.
  - v11u456 VR/vr10: 230 -> STRICT_EQUAL. That is pass 456's residue, the importing package with
    its own enum.
  - r11u455 OC/oc07 and v11u455 VG/vg04: STRICT_EQUAL on both, links 3+3 -> 1+1.

## Corrections to the implementer's tree (no production effect)

- SQ/sq01 to sq04 named a law that does not exist, `§ specArgParamsOnShared460`.
- UZ/uz01 to uz05 likewise named `§ clsDynPatUnsizedBasedElemW460`.
- tests/LAWS.md therefore attributed no case to § pkgTdForeignSpecParams460, and none to
  § clsArrPatBasedLitElemW460 except uz06's twin.
- Both first lines are rewritten to the landed names. The goldens are unaffected: the first line
  is a comment either way.
- tests/LAWS.md is regenerated.

## Residues (all wrong on pristine too)

1. **uvm_id_register differ:name(5):** the get_base_addr return bit_typespec alias naming (the
   implementer's residue 1, not decoded).
2. **Element widths the laws do not model:**
   - module packed-struct elements, golden 4 (vz06);
   - multi-dimension packed elements, golden 4 (vz20; now abstains);
   - 'b01 re-encoded by adjustSize as UINT:4294967295 at 32 (vz11);
   - associative and keyed patterns (vz14);
   - the package variable `int pa[2]` (vz08);
   - function-local arrays (vz03);
   - module time arrays listed by golden as array_net with a cont_assign (vz18).
3. **Goal 1 on this ground:** a class `real r[]` property exits 4 ('class array property
   element'; vz05 on all binaries).
4. The interface law's next faces: the generate-block instance (vi05) and the implicit net of an
   interface (VN/vn07).
5. vn08's line field on an implicit net named like a forwarded class member.
6. The implementer's residues 2 to 6 stand: many_to_one's group base naming on ParamEmit,
   IF/if03's full name, IC/ic03, param_vif_config_db and UZ/uz03.

## Files

- cases/VZ (20), VO (19), VS (16), VI (6), VN (9). Every first line names its law.
- drivers/:
  - env.sh, runcase.sh, sdist.sh (strict-record distance), linkcensus.sh, ds.sh (downstream),
    earlier.sh;
  - tools/links.cpp and tools/sc2_force_stage2.diff. Build them in /tmp/v11u460_tools: links with
    g++ -std=c++17 -I$HOME/.local/include links.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
    -lpthread; sc2 is uhdm-strictcmp with the diff applied.
- evidence/: grid_runs.txt, grid_attack_table.txt, strict_distance.txt, link_census_VO.txt,
  switchcheck.txt, switchcheck_refinements.txt, implementer_grid_reproduced.txt,
  earlier_grids_bytecheck.txt, downstream_sample.txt, prediction.txt, sweep_{law,ver}_{corpus,svtests}.log,
  byteverify_{law_vs_control,ver_vs_control,ver_vs_law}.txt, ver_vs_law_svtests_strict.txt,
  trace_{law,ver}_sweep.txt.
- Process: neither sweep overlapped the sister's runner (three quiet readings before the first;
  the second launched after a quiet check). The attack grid and the earlier-grid check ran beside
  my own sweeps only. The fence list was never read: no tree-wide reader touched a corpus tree,
  and every reader walked only tools/probe repro dirs. No other agent's process was touched.
