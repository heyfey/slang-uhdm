# r11u174 — the expression/parameter ground of the strict axis: r11u172's cast-listing law landed, a module-side struct parameter's leftover named through its own struct copy, the elaborated whole-reference span of an assembled default, the elaborated fold of a struct-member operation unlocated; 4 row-modes and 28 probe cases converted

Base `31739f79` (branch matrix-1.87, pass 169). Ground: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp`, `include/`, `results/`, `tests/` (except the regenerated `tests/LAWS.md`) or `third_party/`. Net
binding is not touched. Every law of passes 140-169 and every earlier refinement is left as landed; the laws here are
new sites under their own switches. Worktree `/tmp/wt_r11u174`, system-deps config, `-j 2`. The sister ground's
r11u172 half (`law_typeemit.patch`: the FILE, VALUE and SPAN laws) had not landed on the main tree at the start or at
the gate sweep (main tree HEAD `31739f79`, then `50a01bc3`, a tools-only commit), so the DEPTH law is measured alone.

| binary | md5 |
|---|---|
| pristine (worktree build of the base, byte-identical to the main tree's `build/slang-uhdm`) | `5f356bace7feda3ba46382e2b63ac365` |
| law (this patch; `law9` in the scratch naming) | `7e22bcccbe35b22fc6f331bf433fb032` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u174_bin`) before it was measured. The pristine sweep
(`/tmp/r11u174_swP`) and the law sweep (`/tmp/r11u174_swL`) have workdir names of the same length; in each, all 3273
`cmds.txt` slang lines (surelog + uhdm2rtlil) name the frozen binary of that sweep. The pristine sweep reads
`regressions=0 conversions=0 changes=0` in all three stages, probe `EQUAL=2755 STRICT_NOTEQUAL=1332`, downstream 803
IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT (evidence/sweep_pristine_summary.txt). Its only red, and the law sweep's,
is `law index STALE` (the worktree's hashes); the regenerated tests/LAWS.md in this patch clears it.

**The fence.** No binary, gdb run or script touched a slang-fenced test's source or database outside the gate
sweeps. drivers/env.sh reads the four names from RESUME.md; nothing in this directory spells them. The census
(drivers/census.sh) refuses to run without `$FENCED` and dispatches the corpora with a whole-name exclusion filter
("fenced mentions: 0"); the row readers (drivers/rowrec.sh, rowtoward.sh), the case drivers (offbytes.sh,
switches.sh) and predict.py refuse a fenced name; the byte verifier ran on hard-link mirrors that leave the 8 fenced
row-mode databases out (drivers/bvmirror.sh, `mirrored=2560 fenced_skipped=8`), and the downstream database
comparison skipped fenced names. No gdb run in this pass.

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 889 | 889 | 0 (2 changes, counts down) |
| uhdm2rtlil strict-equal (of 1606) | 1554 | **1558** | +4 |
| probe EQUAL (of 4087) | 2755 | **2783** | +28 |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | the law sweep's downstream.csv is byte-identical to the pristine sweep's |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched).** The fresh rows of the law sweep
(`/tmp/r11u174_swL/uhdm2rtlil.csv`):

    struct_param_field_shift,default,CMP_EQUAL,,,equal            was differ:fullname(5)  § elabParamLeftoverRefUnnamed174 + § asmRefQualWholeSpanElab174
    struct_param_field_shift,testflags,CMP_EQUAL,,,equal          was differ:fullname(5)  (same)
    param_nested_struct_field_width,default,CMP_EQUAL,,,equal     was differ:fullname(6)  the same two + § elabStructMemberOpFoldUnlocated174
    param_nested_struct_field_width,testflags,CMP_EQUAL,,,equal   was differ:fullname(6)  (same)

Their fresh downstream rows (IDENTICAL as at the base): `struct_param_field_shift,IDENTICAL,OK,OK,1,1,,`
`param_nested_struct_field_width,IDENTICAL,OK,OK,70,70,,`.

**CHANGES (corpus: 14 row-modes, every one attributed record by record, evidence/corpus_movers_toward.txt and the
single-switch reruns in evidence/corpus_movers_switches.txt):**

| row-mode | before -> after | law (the switch that alone restores pristine bytes, or all that act) | strict records (multiset vs golden): away, missing |
|---|---|---|---|
| surelog FuncStructValSimple d | file(42) -> file(40) | § elabParamLeftoverRefUnnamed174 (`LEFTREF:acts=pris`) | away 47 -> 45, missing 47 -> 45 |
| surelog FuncStructValSimple t | file(62) -> file(60) | the same | away 69 -> 67, missing 69 -> 67 |
| uhdm2rtlil rp32_r5p_alu d/t | file(46) -> file(170) | § pkgFnCastTopListing172 (`DEPTH:acts=pris`) | away 288 -> 171, missing 210 -> 171, records 60999 -> 60921 = golden's |
| uhdm2rtlil rp32_r5p_bru d/t | file(46) -> file(153) | the same | away 270 -> 153, missing 192 -> 153, records = golden's |
| uhdm2rtlil rp32_r5p_mdu d/t | file(46) -> file(153) | the same | away 270 -> 153, missing 192 -> 153, records = golden's |
| uhdm2rtlil rp32_r5p_wbu d/t | file(46) -> file(169) | the same | away 287 -> 170, missing 209 -> 170, records = golden's |
| uhdm2rtlil jeras_union d/t | fullname(54) -> fullname(121) | the same | away 154 -> 106, missing 118 -> 106, records 19948 -> 19912 = golden's |
| uhdm2rtlil struct_param_func_config d/t | fullname(14) -> line(8) | § elabParamLeftoverRefUnnamed174 + § asmRefQualWholeSpanElab174 | away 37 -> 10, missing 175 -> 148 |

**The grown counts are the walk going further (caution c).** Pristine's rp32 and jeras_union walks DIVERGED at the
N0025 face (`fields: ... objects_differing=46 (walk diverged)`), so the strict count stopped there:

    rp32_r5p_alu default, pristine: #1157 file ... #15883 value (45 records), then the divergence
      #15963 type   A: 10 constant  riscv_isa_i_pkg.sv 144 27 144 29  31 64 INT:31 7
                    B: 10 operation riscv_isa_i_pkg.sv 144 27 144 31
    law: the same 45 first records (#1157 file: struct_typespec riscv_isa_pkg::isa_t riscv_isa_i_pkg.sv (A) /
      riscv_isa_pkg.sv (B) 417:34-417:39), #15963 gone (the record now reads INT:31 in both), then
      #16005 value  A: UINT:05  B: UINT:5  (riscv_isa_i_pkg.sv 119:34-36)
      #16781 file   struct_typespec riscv_isa_pkg::isa_t  A riscv_isa_i_pkg.sv / B riscv_isa_pkg.sv
      ... to the end of the walk: 60921 records on both sides, no divergence

Every record after #15963 is one of r11u172's FILE (N0140/N0143/N0149) or VALUE (N0092) faces, the TypeEmit laws of
the sister ground (§ tdMoveCarriesFile172, § boundLitWrittenDigits172 in r11u172rp/law_typeemit.patch); r11u172
measured the rp32 rows CMP_EQUAL with all four laws. No record enters that the pristine walk had passed.

**Probe: 28 cases go `STRICT_NOTEQUAL -> EQUAL`, 23 change (every one a smaller count on the same field), 0 regress**
(evidence/sweep_law_summary.txt). Every probe byte mover (59) judged against its golden with both binaries
(evidence/probe_movers_attributed.tsv): uhdm-cmp text unchanged on all 59; strict records move only toward golden
(no record enters that golden lacks); the laws that fired on each are listed there from the census:
* conversions (28): § elabParamLeftoverRefUnnamed174 with § asmRefQualWholeSpanElab174 (r11u11 a5 a8, r11u13 b6,
  r11u14 c5, r11u18 b4, r11u20 b1 b3 b4 b6 t5, r11u21 t1, r11u28 a9 a12, r11u82 s1 s2 v2, r11v21 v1, r11v75
  xl_impclimb, r11vu13 v4 v9), § asmRefQualWholeSpanElab174 alone (the `endcol(1|2)` cases: r11u18 t5, r11u21 t6 t7,
  r11u24 n2, r11u26 m16, r11u28 a8, r11v11u9 g3 g13), § elabStructMemberOpFoldUnlocated174 with the other two
  (r11u21 t1);
* changes (23): r11u21 t9, r11u24 n1 n3 n12, r11u26 m6 m8 m9 m12 m13 m15, r11u28 a4 a5 a6 a7 a16, r11u82 v3,
  r11v26 v2 v9 v12 v13 v15 v16 v18 — one to five records leave, none enters;
* DEPTH movers with no verdict change (identity moves the canonicalising comparator does not see, as r11u172
  measured): r10buvm8 v4order8 vfwdts8 vxpkg8, r10v180 v180_a_share v180_e_ret v180_i_inst; r10uvm123
  g123_c_otherpkg loses 3 away records (`type(…)` unchanged: its first face is earlier);
* r11v21 v15: bytes move, one record leaves, its verdict text is unchanged.

## Targeted rows (brief items), before -> after

| item | row | before | after | what |
|---|---|---|---|---|
| (1) | rp32_r5p_{alu,bru,mdu,wbu} d/t | file(46) | file(170/153/153/169) | § pkgFnCastTopListing172 landed; the N0025/N0033 divergence is gone and the walk completes; the rows now wait only for the sister's FILE + VALUE laws (above) |
| (1) | jeras_union d/t | fullname(54) | fullname(121) | the same law; the walk completes (records = golden's) |
| (2) R1 | struct_param_field_shift d/t | fullname(5) | **CMP_EQUAL** | § elabParamLeftoverRefUnnamed174 + § asmRefQualWholeSpanElab174 |
| (2) R1 | param_nested_struct_field_width d/t | fullname(6) | **CMP_EQUAL** | the same + § elabStructMemberOpFoldUnlocated174 (its third face: `NOUT = CFG.u.dataWidth / CFG.u.sidWidth` INT:10, golden unlocated) |
| (2) R1 | struct_param_func_config d/t | fullname(14) | line(8) | the R1 face gone; the head is now the sister's typedef relocation (below, S1) |
| (2) R1 | FuncStructValSimple d/t | file(42)/file(62) | file(40)/file(60) | two records leave; the head is the package-listing leftover face (residue 2) |
| (2) R1 | FuncStructVal d/t | endcol(95)/endcol(177) | unchanged | 40 away records leave per mode (578 -> 538, 1008 -> 968); its walk diverges earlier |
| (2) | pass 169's ml grid | col/fullname/endcol | 11 of 17 STRICT_EQUAL | the six stage-1 cases keep their uhdm-cmp text (evidence/control_movers_judged.txt) |
| (2) | § aggParamFoldUnqualWholeSpan158 | — | left as landed | r11u170 measured it content-neutral (dump-identical) behind § aggParamFoldQualSpanByView163; retiring it is a byte-only change on four databases with no strict or judge effect, so it buys nothing on this axis and would add a byte mover to every later gate; kept |

## Laws (each under its own switch; `R11U174_OFF=1` drops all of them, r11u172's law included; `R11U174_TRACE=1` prints one stderr line per branch)

Sites are named by function and § token (`grep -n '§ <law>' src`). The switch table is the r11u174 block at the end
of src/EmitHelpers.h.

### § pkgFnCastTopListing172 (`R11U172_DEPTH_OFF`, also `R11U172_OFF` and `R11U174_OFF`; ExprEmit.cpp emitExpr, the named-typedef cast branch)
r11u172's law_exprEmit.patch, landed unchanged except the gate (it also reads `R11U174_OFF`) and three trace lines
(`DEPTH172 top`, `DEPTH172 top logic alias`, `DEPTH172 alias written`). The decode is r11u172's
(tools/probe/r11u172rp/README.md section 2, DEPTH): FunctorCompilePackage compiles every package twice, so a cast
written in a subroutine of the typedef's own package reaches, in the elaborated package, that view's folded listing.
The patch applied on 31739f79 with a 185-line offset (passes 168 and 169 moved ExprEmit). Its grid
(tools/probe/r11u172rp/cases/D) reproduces r11u172's reading: d01 d03 d05 d08 d10 go STRICT_EQUAL, d02 is an
identity move, d09 stays stage 1 with the same uhdm-cmp text, d04 d06 d07 are byte-identical.

### § elabParamLeftoverRefUnnamed174 (`R11U174_LEFTREF_OFF`; ParamEmit.cpp stampEvalFuncLeftovers — helpers leftRefFix174 / leftRefWalk174 / leftRefRepointPa174, run after the S2 clone walk for the elaborated listing and after the definition-listing re-point for the import copies; two keep-rules at the module-held assemble branch and the asmRefPa branch)
The leftover a whole-formal read leaves on a function-built struct parameter (`c.A = x`: the caller's actual with
the formal's typespec, § memLeftFormalReadTs18, and the parameter-actual copy of § memLeftFormalArgLoc169) stores the
package name on its `ref_typespec` in golden's package listings and in the definition module listing that resolves
the package's struct (`p`); every MODULE-SIDE parameter that holds its own struct copy carries a copy of that leftover
whose reference stores no name, so it computes through the copy's member (`<in>p::cfg_t.A`). Measured module-side
holders: the elaborated module parameter, per instance (lr/l02, as/a08), inside a generate scope (lr/l10), overridden
by a package parameter (lr/l06) or by the parent's parameter (lr/l18), a body localparam (lr/l07), a macro-born
default (lr/l08), and the import copy a wildcard-importing module materializes, in BOTH module listings (lr/l05,
as/a07; golden struct_param_func_config `work@child.C`). A module-held stamp's minted constant is parented at its call
in ours (its computed name empty): golden's definition listing agrees, its elaborated copy computes
`<in>p::cfg_t.A` (ml/m02), so a leftover whose parent is not a struct member is cloned too. The law gives such a
parameter its own struct copy (members copied as § evalFuncBodyRhsStampClone167 copies them; a struct already
parented at the parameter is that law's copy and is edited in place), clones each such leftover constant at its
member with the reference unnamed, and re-points the parameter's param_assign constant at the copy. Two exceptions,
each measured: the MODULE-held assembled constant (§ modStructFuncAssembleBin) keeps the stamped struct (ml/m02: its
leftover computes an empty name), and a SIBLING read (`C2 = Cfg`, the immediate referent not a package parameter,
recorded at the § asmEncFollowsRef R1 site) keeps it too (as/a02, as/a05: those leftovers store `p`). Traces
`LEFTREF copy|inplace`, `LEFTREF minted|other[ reparent]`, `LEFTREF param_assign`, `LEFTREF modasm keeps stamped`,
`LEFTREF asmref sibling keeps stamped`. Only a constant with a typespec is cloned; the copy allocates a struct, its
members and one constant plus one reference per leftover, never a partial tree (no failure path after allocation).

### § asmRefQualWholeSpanElab174 (`R11U174_ASMSPAN_OFF`; ParamEmit.cpp stampEvalFuncLeftovers, the § asmEncFollowsRef R1 branch; the range is recorded at its emitParameters site)
The assembled constant a module parameter reads whole out of a function-built parameter (`parameter cfg_t Cfg =
p::D`) is located, in the ELABORATED module listing, at the whole written reference (golden struct_param_field_shift
`cfg_pkg::DefaultCfg` 24:36-55, param_nested_struct_field_width `pk::CFG` 35:37-44), while the definition listing
keeps the qualifier (24:36-45). It is the view split § aggParamFoldQualSpanByView163 writes for a constant fold, which
this drain-minted constant never reached (its emitted fold is the unfolded call, so the qualifier span stood).
Measured: `p :: D` (as/a01), `(p::D)` (as/a03: the whole written initializer range, parentheses included), a
reference broken over two lines (as/a04), a sibling read (as/a02, as/a05), a
macro-born reference, plain (lr/l08) and through a macro argument (as/a06), a header import with a qualified read
(as/a07), an override (as/a08). Traces `ASMSPAN whole` / `ASMSPAN same`.

### § elabStructMemberOpFoldUnlocated174 (`R11U174_MOPUNLOC_OFF`; ParamEmit.cpp emitParameters, the per-parameter tail before the modDefImportShape dispatch)
Surelog cannot reduce `Cfg.A / Cfg.B` while it compiles the module when `Cfg` is built by a constant function (the
member values exist only once the struct parameter is elaborated), so the elaborated listing's value is the constant
UHDM's ExprEval mints at elaboration, which carries no location (golden param_nested_struct_field_width `NOUT =
CFG.u.dataWidth / CFG.u.sidWidth`: INT:10, file empty, 0:0-0:0). Measured: `/`, `+`, `*`, unary `-`, a nested
operation, the member on either side, a cast operand (`int'(Cfg.A) / 2`, `8'(Cfg.A / 2)`), a body localparam, per
instance, a whole-struct localparam read in between (ub/u23), and a parameter folded from an operation that reads
such a parameter (ub/u16 `Y = X + 1`). Located in golden, and left alone: a compile-time reducible operation (ub/u05
`P / 2`), a system call over a member (ub/u07 `$clog2(Cfg.A)`, ub/u17 `$clog2(Cfg.A) + 1`), a PATTERN-built struct
(ub/u21 — the break the first cut made, fixed before the census: the chain of whole parameter reads must end in a
user function call), an instance override actual (ub/u13, another emitter). An override, a conditional, a select or a
non-parameter base abstains (`MOPUNLOC abstain`).

## Census (the predictions) and the movers

The census (drivers/census.sh + tracewrap.sh) ran on the law binary BEFORE the law sweep, through the harness, with
the fence filter. Every branch of every law traces. evidence/census_all_firings.tsv lists every firing (101 row-modes
and cases), evidence/predicted_movers.tsv the byte-changing branches (every firing but `ASMSPAN same`, `MOPUNLOC
abstain`, `DEPTH172 top logic alias`): **82 names: 4 surelog row-modes, 16 uhdm2rtlil row-modes, 62 probe cases.**

Byte verifier (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law mirror against pristine mirror,
evidence/byteverify.txt):

| stage | paths | selfcheck | movers | predicted | unpredicted |
|---|---|---|---|---|---|
| surelog | 952 identical sets (fenced left out) | 951/952 | 10 | 4 (FuncStructVal d/t, FuncStructValSimple d/t) | **6: MiniAmiq d/t, SeqDriver d/t, SimpleUVM d** (the 4-line UINT/vpiDecompile coin: ordered = order-blind = 4 dump lines each) **and Scoreboard d** (the svunit list-order coin: 118 ordered lines, 0 order-blind): evidence/uvm_coin_orderblind.txt; no law fired on them |
| uhdm2rtlil | 1608 identical sets | 1607/1608 | 16 | 16 | 0 |
| probe (every database compared) | 4087 | — | 59 | 59 | 0 (3 predicted cases did not move: r10uvm180 g180_a_kinds, r10v123 v123_m2_plain_min, v123_m4_plain_novar — `DEPTH172 top` fired on a listing whose elaborated and definition objects coincide; the prediction is a superset) |
| downstream databases | 805 (fenced left out) | — | 8 | the 8 u2r movers' tests | 0; their `_nohier.il`, `.il` and `_synth.v` are byte-identical to pristine's (evidence/downstream.txt) |

uhdm-cmp reads 0 lines on all 26 corpus movers (evidence/uhdmcmp_movers.txt).

## Gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `5f356bac…` = main tree; law `7e22bccc…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=28, changes=23; EQUAL 2783 STRICT_NOTEQUAL 1304, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 0 + 4; changes 2 + 12 (all attributed above) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; not identical and not excused=0; downstream.csv byte-identical to the pristine sweep's; every touched row IDENTICAL: `struct_param_field_shift,IDENTICAL,OK,OK,1,1,,` `param_nested_struct_field_width,IDENTICAL,OK,OK,70,70,,` `struct_param_func_config,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `rp32_r5p_alu,IDENTICAL,OK,OK,1332,1332,,` `rp32_r5p_bru,IDENTICAL,OK,OK,174,174,,` `rp32_r5p_mdu,IDENTICAL,NO_GATES,NO_GATES,0,0,,` `rp32_r5p_wbu,IDENTICAL,OK,OK,320,320,,` `jeras_union,IDENTICAL,NO_GATES,NO_GATES,0,0,,` |
| (5) uhdm-cmp on touched rows | 0 lines on all 26 corpus movers; every grid case and every probe mover keeps its uhdm-cmp text (ids stripped) |
| (6) byteverify | 10 + 16 corpus movers and 59 probe movers, all attributed; all but the six coin rows predicted by name |
| canaries | r11u107repro/canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2.sh EXPECT_UNKNOWN=1 surelog ok=58 changed=0 PASS, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2 changed=0 PASS (evidence/canaries.txt) |
| grid | 48 cases (evidence/grid_pristine_vs_law.tsv): 30 go to STRICT_EQUAL, 2 equal on both (controls ub/u05 u21), 3 stay STRICT_NOTEQUAL with records leaving (lr/l15 away 10 -> 1, ub/u12 65 -> 60, ub/u14 13 -> 4: other faces), 13 are stage 1 on both with the same uhdm-cmp text |
| switches | evidence/switches.txt (48 + 17 + 10 cases) and evidence/corpus_movers_switches.txt (20 corpus row-modes): each switch acts only where its law fires; `R11U174_OFF=1` restores pristine bytes on every one; where one law alone acts the switch alone restores pristine (the D grid and rp32/jeras_union by `R11U172_DEPTH_OFF`, FuncStructVal/FuncStructValSimple by `R11U174_LEFTREF_OFF`, lr/l05 l06 ml/m02 by LEFTREF, ml/m15 m16 m18 lr/l14 by ASMSPAN, ub/u15 by MOPUNLOC) |
| `R11U174_OFF=1` | 2115 cases of passes 118-173 (tools/probe/r11u118repro … r11u173verify, r11u172rp) byte-identical to pristine: SAME 2099, NODB 16 (no database from either binary) (evidence/offbytes_controls.txt) |
| byte controls | the law binary with every law on moves 48 of those 2115 cases, all in the grids this pass works: r11u169 ml (17), r11v169 ml (24), r11u172 D (7); each judged with both binaries (evidence/control_movers_judged.txt): uhdm-cmp text unchanged on all 48, 18 go STRICT_EQUAL (ml m01 m02 m04-m07 m09 m10 m13 m15, mb01 mb02 mc06, D d01 d03 d05 d08 d10), d02 stays STRICT_EQUAL (identity move), the rest keep their verdict (mb10 mb12 m12 with records leaving, 26 stage 1 with the same uhdm-cmp text); the pass 118/119/120/124/131/154/158/160/163/167 grids are byte-identical |

## Sister-ground faces (decoded; the fix sits in a file this pass does not own)

* S1 — struct_param_func_config d/t `line(8)`: the import copy `work@child.U`'s struct `p::ucfg_t` is located at the
  `build` formal's type token in golden (`dut.sv 32:40-46`, `function automatic cfg_t build(input ucfg_t u)`), ours
  at the typedef (16:11-20:4): the typedef last-writer relocation (CompileHelper::compileTfPortList runs
  populateCoreMembers on the typedef object, r11u172 section 2 FILE), § tfArgTypedefLastWriter146 in UhdmExporter.cpp
  which declines struct formals of a function whose result feeds a module import copy; the definition and elaborated
  import copies carry it (#739, #820, #838). Ground B.
* S2 — rp32_r5p_* and jeras_union: after this pass their only faces are § tdMoveCarriesFile172 (FILE) and
  § boundLitWrittenDigits172 (VALUE) of r11u172rp/law_typeemit.patch (TypeEmit.cpp; ground B), plus jeras_union's
  60 range constants without a file and the union's file (r11u172 R5).
* S3 — iface_zero_width_field d/t `fullname(4)`: the package `B` pattern's `ref_typespec` (unpacked struct) is
  unnamed in golden's package listing (#105, `package p < param_assign < operation`); § pkgPatReadTsNoParent131
  excludes unpacked structs on purpose (its pass-131 decode found `B` keeping its parent). The read here is a
  package typedef's range bound `[B.CTL-1:0]`; the exclusion needs a regrid (ParamEmit drainShareDefParamTs, this
  ground), not worked.

## Decoded, not landed (ranked residues on this ground)

1. **FuncStructValSimple d/t `file(40)`**: the package-listing leftovers of `build_config_func` members:
   `INT:2` located at the call (ours `dut.sv 67:46-68:35`, golden unlocated) and a whole-formal read leftover whose
   reference stores `cva6_config_pkg` in golden where ours stores none (#129: the formal's own package name, the
   function sits in another package): § memLeftSliceUnlocated169's drain and § memLeftFormalReadTs18's `tsPrefix`
   when the subroutine's package differs from the formal type's.
2. **FuncStructVal d/t `endcol(95)`**: pass 169's residue 3 (the pattern caller's member read placed at a read site
   of the parameter), unchanged.
3. **r11u172's R2 (UVM `uvm_reg_addr_t`, the DEPTH rule reaching class scope)**: `DEPTH172` does not fire on any UVM
   row (the census reads no firing), so class-member casts still reach the definition listing; ungridded.
4. **ub/u12**: a module-held call default (`Cfg = p::mk(64, 5)`) next to a package call: golden locates the leftover
   at the module's own call (18:45-47), ours at the package's (15:27-29) — the stamp shares the first minted
   leftover across two calls with equal arguments.
5. **lr/l15**: a package localparam reading another package's function-built parameter (`q::QD = p::D`) — golden
   keeps a `ref_obj q::p::D` in the package listing where ours folds (stage-2 divergence at #105), another emitter.
6. The pass-169 carried items not worked here: gc/c04 and gc/a07, the empty-name references under `==?`, `&&`,
   `{P + 1}` and an inside left operand, the ml/m12 macro-born actual, LocalScopeHierPath t (S1 of r11u169), the
   defaulted formal and the actual's own size (stage 1 on r11v169 ml mb03 mb06 mb13 and on lr/l03 l04 l09 here),
   StructParamPatternInitCast / ParamNoImport's flattened pattern, InterfArrayBind d, const_cast_signext, N0012,
   N0536, the ibex_alu enum default span, YosysRiscv's column, CovMacro's `$root.top` names, ibex_pmp's typespecs
   (TypeEmit) and dv_fcov spans, the UVM method-call span under a macro formal, PackedArrayHighConn's enum base names,
   the package-localparam override location, r11u173's range-query and `s[i+1].f[0]` items, pass 154's macro lvalue
   paths, sc/c10, vA's column.

## Cases (first line of every case names its law; pristine / law verdicts in evidence/grid_pristine_vs_law.tsv)

| grid | cases | law | pristine -> law |
|---|---|---|---|
| lr | l01 l02 l05 l06 l07 l08 l10 l18 | § elabParamLeftoverRefUnnamed174 (with § asmRefQualWholeSpanElab174 where the default is a package read) | fullname -> STRICT_EQUAL |
| lr | l15 | § elabParamLeftoverRefUnnamed174 (residue 5) | fullname -> fullname (records leave) |
| lr | l03 l04 l09 l11 l12 l14 l16 l17 | § elabParamLeftoverRefUnnamed174 (stage 1 on both, same uhdm-cmp text: the actual's size, a func_call argument, an interface, a generate localparam) | NOT_EQUAL -> NOT_EQUAL |
| as | a01 a02 a03 a04 a05 a06 a07 a08 | § asmRefQualWholeSpanElab174 (with § elabParamLeftoverRefUnnamed174) | fullname -> STRICT_EQUAL |
| ub | u01 u02 u04 u08 u10 u11 u16 u18 u20 u22 u23 | § elabStructMemberOpFoldUnlocated174 (with the other two) | fullname -> STRICT_EQUAL |
| ub | u07 u13 u17 | § elabStructMemberOpFoldUnlocated174 (controls: a system call, an override actual; the other laws convert them) | fullname -> STRICT_EQUAL, MOPUNLOC silent or abstaining |
| ub | u05 u21 | § elabStructMemberOpFoldUnlocated174 (controls: `P / 2`, a pattern-built struct) | equal -> equal, bytes unchanged |
| ub | u12 u14 | § elabStructMemberOpFoldUnlocated174 (other faces: residue 4, a generate-scope ref_obj span) | unchanged verdict, records leave |
| ub | u03 u06 u09 u15 u19 | § elabStructMemberOpFoldUnlocated174 (stage 1 on both, same uhdm-cmp text) | NOT_EQUAL -> NOT_EQUAL |

## Ops notes (disclosed)

* Nine law binaries were built in turn (`law172` = the landed patch alone; law1 the leftover copy on named
  references and the span; law2 the member-less parent; law3 the module-held keep; law4-law5 the definition-listing
  import copies, moved after the definition re-point; law6-law7 the sibling keep, decided on the immediate referent;
  law8-law9 the member-operation fold, restricted to function-built structs after ub/u21 read a break on law8). The
  census and the gate sweep ran on law9 only.
* The law sweep and the pristine sweep ran one at a time; no other downstream sweep ran concurrently.
* No process I did not start was touched; the sister's and r11u175's worktrees were not read or written.
* The main tree gained `50a01bc3` (tools only) after the base; tests/LAWS.md in this patch is regenerated at
  31739f79 and needs a regeneration if that commit changed it.

## Files

* drivers/env.sh (the environment, `$FENCED` read from RESUME.md), sweep.sh (a gate sweep), grid.sh (one case:
  golden + ours + uhdm-cmp + uhdm-strictcmp), census.sh + tracewrap.sh (the firing census, fence-filtered),
  predict.py (the predicted movers), offbytes.sh (a binary + environment against pristine bytes over case trees),
  switches.sh (the switch matrix), rowrec.sh, rowtoward.sh + toward.py (strict-record multisets of a row or case:
  away/missing against golden), recanc.py / anc.py (parent chains of differing records), bvmirror.sh (fence-clean
  byteverify mirrors).
* cases/lr (17: l01-l12, l14-l18), cases/as (8), cases/ub (23): 48 cases, each `dut.sv` with its law in its first line.
* evidence/: the files named above.
