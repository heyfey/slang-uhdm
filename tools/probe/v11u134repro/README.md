# v11u134 — adversarial verification of r11u134

The verifier pass for r11u134 (the module/type ground on the strict axis, second round). Base `c9e2923c` (branch
matrix-1.87). **Verdict: ACCEPT.** The implementer's patch is right. Every headline number reproduces bit for bit.
82 fresh cases, 35 moved byte-control cases of passes 118-130 and the full censuses produce no case where pristine
was right and the patch is wrong. No fix was needed, so there is no `.verified.patch`: the deliverable is the
implementer's patch plus this directory.

Worktrees `/tmp/wt_v11u134` (patch applied, clean) and `/tmp/wt_v11u134pris` (pristine) were both built at `-j 2`
with the system-deps config. The binaries were frozen (`chmod 555`) under `/tmp/v11u134_bin/` before any
measurement.

| binary | md5 |
|---|---|
| pristine | `61cfb59f3cfa1865bccb360c76bf09dd` (the main tree's build of the base, as required) |
| law (r11u134) | `c4df1a46b2c140c818bc72b933fff741` (the implementer's law binary) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` (the worktrees' own build, the same as the main tree's) |

## 1. Headline numbers, reproduced

These are sweeps of my own (`tests/sweep.sh --jobs 3`, `SLANG_UHDM` and `STRICT_CMP` exported to the frozen copies):
pristine `/tmp/v11u134_wdP`, law `/tmp/v11u134_wdL`, downstream `/tmp/v11u134_dsL`, and a law sweep with
`R11U134_OFF=1` in `/tmp/v11u134_wdO`. The cmds.txt audit found 3273 of 3323 corpus runs naming the frozen binary in
each sweep; the other 50 never ran slang-uhdm, and no run names any other binary. The downstream slang lane was
audited by bytes: TypedefWithParameter, union_simple and net_types match the law binary's output and differ from the
pristine binary's.

| stage | pristine | law | compare vs baseline (law) |
|---|---|---|---|
| probe | EQUAL=2081 STRICT_NOTEQUAL=2006 | EQUAL=2102 STRICT_NOTEQUAL=1985 | regressions=0 conversions=21 changes=63 |
| surelog default | CMP_EQUAL=331 STRICT_NOTEQUAL=149 CMP_NOTEQUAL=3 | CMP_EQUAL=343 STRICT_NOTEQUAL=137 CMP_NOTEQUAL=3 | |
| surelog testflags | CMP_EQUAL=308 STRICT_NOTEQUAL=166 CMP_NOTEQUAL=3 | CMP_EQUAL=320 STRICT_NOTEQUAL=154 CMP_NOTEQUAL=3 | regressions=0 conversions=24 changes=22 |
| uhdm2rtlil (each mode) | CMP_EQUAL=635 STRICT_NOTEQUAL=168 CMP_NOTEQUAL=1 SLANG_REJECT=67 | CMP_EQUAL=652 STRICT_NOTEQUAL=151 CMP_NOTEQUAL=1 SLANG_REJECT=67 | regressions=0 conversions=34 changes=54 |
| downstream (law) | | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66 of 871, not excused=0 | verdict AND `differs` equal to results/downstream_uhdm2rtlil.csv on all 871 rows |

- Both sweeps exit 0, and `law_index.py --check` reads current.
- The judge-equal scoreboards stay: 480/3 + 474/3 surelog, 803/1/67 uhdm2rtlil.
- Row by row, no corpus row changes its uhdm-cmp status, no row leaves CMP_EQUAL/EQUAL, and every probe case stays
  judge-equal.
- The 58 corpus conversions (24 + 34) and the 21 probe conversions are exactly the implementer's list. The 17
  converted uhdm2rtlil tests read IDENTICAL downstream.
- The change split matches too: surelog has 12 rows with fewer objects on the same first field and 10 whose first
  field moved; uhdm2rtlil has 34 and 20.
- Canaries: `canaries.sh` law vs pristine gives surelog ok=46 changed=6 (Scr1SvTests line(244)->(228), Earlgrey_0_1
  line(5100)->(1038), BuildUVMPkg fullname(315)->line(284), both modes each) and uhdm2rtlil ok=16 changed=0.
  `EXPECT_UNKNOWN=1 ctcan2.sh` gives PASS ok=58, and `EXPECT_UNKNOWN=6 ctcan2.sh` gives PASS ok=2.

The fresh converted csv rows (law sweep) are all `<name>,<mode>,CMP_EQUAL,,,equal`:

- **surelog, both modes:** AssignmentPatternInAssignmentPattern, AssignRhsFlat, EarlgreyPackParam, HierPathStruct,
  LogicArrayParam, LogicTypedef, PartSelectNoParent, PatternOrder, RangeSelect, StructAccess, StructTypedef, WireType.
- **uhdm2rtlil, both modes:** EnumInPackage, indexed_partsel_array, IndexedPartSelectInFor,
  IndexedPartSelectOfArrayElement, latch_fifo_dynfield, latch_nested_ex_field, net_types, PartSelectInFor,
  struct_access, struct_pattern_named_default, svtypes_struct_simple, typedef_package, TypedefWithParameter,
  union_simple, unpacked_struct_2d, unpacked_struct_dyn_read, unpacked_struct_mixed.

The before values are in evidence/sweep_law.txt.

## 2. Nothing worse (strict axis)

- **Probe** (drivers/probe_fc.py, evidence/probe_fc.txt). uhdm-strictcmp re-ran on all 84 probe cases whose column
  changed, and the per-field tallies were compared pristine vs law. No field count grows, except
  r10buvm8repro/v5b8 (line/col/endline/endcol 8 -> 10). That case is an unmasking, confirmed. The pristine walk
  diverged at record #877 (the `kp5b::b_t` alias, a `type` face) before the last three `kp5b::e_t` enum listings. The
  law walk no longer diverges and reaches them. They carry the same pre-existing 6:3-6:43 vs golden 20:24-20:27 face
  as the first seven (the implementer's residue R4).
- **Corpora, changed columns** (drivers/corp_fc.py, evidence/corp_fc.txt). 134 row-modes changed (58 conversions +
  76 changes). No field count grows on any of them, and no walk that ran to the end now diverges.
- **Corpora, unchanged columns** (drivers/corp_fc2.py, evidence/corp_fc2.txt). These are byte movers whose column did
  not change, which a first-field census cannot see. 61 are strict-equal rows that moved bytes only, and 73 are
  STRICT_NOTEQUAL rows. No field count grows on any of them.

## 3. Byte movers and attribution

`byteverify.sh` law vs pristine (`SELFCHECK=1`, same-length workdirs) reads PATH_SETS_IDENTICAL on both corpora.
SELFCHECK flags 959/960 and 1607/1608. MOVERS: 104/960 + 164/1608 = 268.

- **The full `R11U134_OFF=1` sweep vs pristine** moves only the UVM order-coin family: surelog MiniAmiq ×2,
  SeqDriver ×2, SimpleUVM/testflags and Scoreboard/default, and 0/1608 on uhdm2rtlil (evidence/bvoff_*.txt).
- **Order-blind** (sorted, id-free dumps), law vs pristine reads exactly the 4-line UINT/vpiDecompile coin on
  MiniAmiq, SeqDriver and SimpleUVM/testflags, the same as OFF vs pristine, and 0 lines on Scoreboard and
  SimpleUVM/default.
- **So every one of the 268 movers is owned by the patch or by the coin.** Mine differ from the implementer's 266 by
  two coin rows (Scoreboard/default, MiniAmiq/testflags). The mover list excludes the slang-fenced test, which moves
  in both modes, as the implementer's does. That test was never dispatched on its own: it is attributed by the full
  OFF sweep.
- **Determinism.** My law sweep vs the implementer's law sweep (`/tmp/r11u134_wdL`, the same binary md5) moves 4/960
  (MiniAmiq, SeqDriver, both coin) and 0/1608.

**Per-switch attribution of the conversions** (evidence/attribution_conversions.txt). One switch off, default mode,
lists the rows that fall back:

| switch | rows that fall back |
|---|---|
| TDNETEND, TDARRSHARE | RangeSelect, latch_fifo_dynfield, unpacked_struct_{2d,dyn_read,mixed} |
| TDPARENT | AssignmentPatternInAssignmentPattern, HierPathStruct, latch_nested_ex_field, struct_pattern_named_default |
| CAUNPARENT | AssignRhsFlat, PartSelectNoParent, StructAccess, EnumInPackage, IndexedPartSelectInFor, PartSelectInFor, union_simple |
| ANONMEMBER | AssignRhsFlat, PatternOrder, StructTypedef, struct_access, svtypes_struct_simple, union_simple |
| ELABNETALIAS | LogicTypedef, WireType, net_types |
| TSREFCHAIN | EarlgreyPackParam, LogicArrayParam |
| SCOPEDPKGTD | typedef_package, TypedefWithParameter |
| PKGCLONEBOUND | TypedefWithParameter |
| MEMUNION, TSHPNAME | nothing (no corpus conversion) |

indexed_partsel_array and IndexedPartSelectOfArrayElement are converted REDUNDANTLY: either TDARRSHARE or CAUNPARENT
gives golden's name. They fall back only with both off, or with `R11U134_OFF`.

## 4. Byte controls of passes 118-130 (tools/probe grids not in tests/probe)

All 603 `dut.sv` under r11u130repro, r11v130repro, r11u125repro, r11v125repro, r11u120repro, r11v120repro,
r11u119repro, r11u118repro and r11v11u118repro ran through both binaries (drivers/bytes.sh, evidence/ctl_bytes.txt).
568 are byte-identical and 35 move.

The 35 movers were judged against fresh goldens (evidence/ctl_judge.txt):

- 23 turn strict-equal, and 2 were strict-equal and stay so.
- 10 judge-NE cells keep their uhdm-cmp head.
- 4 STRICT_NOTEQUAL cells:
  - c_import_structvar_pat, c06 and c07 have unchanged field counts.
  - r11u119repro b10_scoped_alias_concat goes from `endline` to `depth`. That is an unmasking. The law removes the
    unreferenced `pkg::u8_t` alias clone and moves the typedef's end to golden's 5:23 (the pristine walk diverged
    there). The walk now reaches a pre-existing face: the concatenation operand `i` lists a ref_typespec that
    golden's does not. The dump diff pristine vs law touches only the typedef end and the removed clone.

## 5. Breaking the laws: 82 fresh cases (grid/, every case names its law in its first line)

Each case was judged with Surelog `-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0` against `dut.sv --single-unit
--nobuiltin` (drivers/case.sh). It was scored by uhdm-cmp and uhdm-strictcmp with both binaries, then by
`R11U134_OFF=1` and each single switch (drivers/sw.sh), and by the downstream verdict with the law binary
(drivers/ds.sh). The faces tried:

- **Last writer:** three importers, including named import, header import, interface importers, a program, a class
  in the package, a package importing a package, an unused module, one module instantiated twice, a parameterized
  module, and `$unit` typedefs in two modules.
- **Unparenting:** port LHS, net declaration assignment, concatenation LHS, member LHS, element LHS, generate scope,
  interface, enum, union, typedef of typedef, package typedef assigned in one of two modules, parameterized per
  instance.
- **Anonymous members:** in a package, a union in a struct, a signed union, two declarators on one line spread over
  lines, three levels, an inline variable, an unpacked union, a port type, a parameter default.
- **Definition-net end write:** two modules in reverse name order, two nets in one module, 2-D, a parameter
  dimension, `[N-1:0]`, a union, an enum, a package typedef, a scoped name, a generate scope, an unpacked port
  control, and a typedef from an included file.
- **Elaborated net aliases:** `tri`, `wand`, a signed `reg` typedef, a parameterized typedef with two
  specializations, a net array, a net initializer.
- **Scoped package typedefs:** two declarators with initializers, a typedef over a typedef, ports, a child module,
  `bit`.
- **Range references:** hier_path bounds in a function return, an unpacked dimension, a sub-module parameter, an
  interface-port parameter, a package function's local range, a package parameter's typedef, a nested package struct.

| | cells | judge-equal | strict-equal pristine | strict-equal law | pristine equal, law not |
|---|---|---|---|---|---|
| all | 82 | 52 | 15 | 43 | **0** |

- **Judge-NE cells:** all 30 keep their uhdm-cmp head (evidence/ne_heads.txt). The line count is the same except
  ca17 (517 -> 513): the dump of the unparented `p::t` loses its `vpiParent` lines, and the head is the same
  object.
- **Judge-equal cells still STRICT_NOTEQUAL** (an03, bc05, hp03, hp06, pa11, rp02, rp05, td15, td16): no field
  grows, and each one's counts are equal or lower (drivers/fields.sh).
- **Switches:** `R11U134_OFF=1` gives pristine bytes on all 82 cells, and each moved cell is owned by the switches
  its law names (evidence/switches.txt).
- **Downstream:** 74 cells are IDENTICAL. 8 are EQUIVALENT with BOTH binaries (bc02, bc05, ca15, ca17, ca19, hp04,
  rp04, rp06): the law's RTLIL and netlist are byte-identical to the pristine binary's (bc05 checked file by file).
  So the difference predates the patch.

| case | law (first line) | pristine / law (uhdm-cmp lines, strict verdict), bytes | switches | downstream (law) |
|---|---|---|---|---|
| an01 | § anonMemberRefChainName134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 221] moved | off=pristine laws: TDPARENT ANONMEMBER | IDENTICAL |
| an02 | § anonMemberRefChainName134 | P[cmp=0 STRICT_NOTEQUAL file] L[cmp=0 STRICT_EQUAL 259] moved | off=pristine laws: ANONMEMBER MEMUNION | IDENTICAL |
| an03 | § anonMemberRefChainName134 | P[cmp=0 STRICT_NOTEQUAL endcol] L[cmp=0 STRICT_NOTEQUAL endcol] moved | off=pristine laws: ANONMEMBER | IDENTICAL |
| an04 | § memberAnonUnionAtKeyword134 | P[cmp=0 STRICT_NOTEQUAL file] L[cmp=0 STRICT_EQUAL 149] moved | off=pristine laws: CAUNPARENT ANONMEMBER MEMUNION | IDENTICAL |
| an05 | § memberAnonUnionAtKeyword134 | P[cmp=0 STRICT_NOTEQUAL file] L[cmp=0 STRICT_EQUAL 220] moved | off=pristine laws: CAUNPARENT ANONMEMBER MEMUNION | IDENTICAL |
| an06 | § anonMemberRefChainName134 | P[cmp=285 NOT_EQUAL stage1] L[cmp=285 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT ANONMEMBER | IDENTICAL |
| an07 | § anonMemberRefChainName134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 124] moved | off=pristine laws: ANONMEMBER | IDENTICAL |
| an08 | § memberAnonUnionAtKeyword134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 165] moved | off=pristine laws: ANONMEMBER | IDENTICAL |
| an09 | § anonMemberRefChainName134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 248] moved | off=pristine laws: CAUNPARENT ANONMEMBER | IDENTICAL |
| an10 | § anonMemberRefChainName134 | P[cmp=101 NOT_EQUAL stage1] L[cmp=101 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT ANONMEMBER | IDENTICAL |
| bc01 | § defNetScopedPkgVecTdShares134 | P[cmp=17 NOT_EQUAL stage1] L[cmp=17 NOT_EQUAL stage1] moved | off=pristine laws: SCOPEDPKGTD | IDENTICAL |
| bc02 | § defNetScopedPkgVecTdShares134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] moved | off=pristine laws: SCOPEDPKGTD | EQUIVALENT |
| bc03 | § pkgTdCloneBoundLoc134 | P[cmp=50 NOT_EQUAL stage1] L[cmp=50 NOT_EQUAL stage1] same | unmoved off=pristine | IDENTICAL |
| bc04 | § defNetScopedPkgVecTdShares134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 132] moved | off=pristine laws: SCOPEDPKGTD | IDENTICAL |
| bc05 | § defNetScopedPkgVecTdShares134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_NOTEQUAL fullname] moved | off=pristine laws: SCOPEDPKGTD | EQUIVALENT |
| bc06 | § defNetScopedPkgVecTdShares134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 161] moved | off=pristine laws: SCOPEDPKGTD | IDENTICAL |
| bc07 | § pkgTdCloneBoundLoc134 | P[cmp=0 STRICT_NOTEQUAL type] L[cmp=0 STRICT_EQUAL 103] moved | off=pristine laws: SCOPEDPKGTD PKGCLONEBOUND | IDENTICAL |
| ca01 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 194] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| ca02 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_EQUAL 135] L[cmp=0 STRICT_EQUAL 135] same | unmoved off=pristine | IDENTICAL |
| ca03 | § contAssignLhsTsUnparented134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] same | unmoved off=pristine | IDENTICAL |
| ca04 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_EQUAL 156] L[cmp=0 STRICT_EQUAL 156] same | unmoved off=pristine | IDENTICAL |
| ca05 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_EQUAL 160] L[cmp=0 STRICT_EQUAL 160] same | unmoved off=pristine | IDENTICAL |
| ca06 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 157] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| ca07 | § contAssignLhsTsUnparented134 | P[cmp=28 NOT_EQUAL stage1] L[cmp=28 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT | IDENTICAL |
| ca08 | § contAssignLhsTsUnparented134 | P[cmp=30 NOT_EQUAL stage1] L[cmp=30 NOT_EQUAL stage1] same | unmoved off=pristine | IDENTICAL |
| ca09 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 157] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| ca10 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 181] moved | off=pristine laws: CAUNPARENT ANONMEMBER | IDENTICAL |
| ca11 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 155] moved | off=pristine laws: TDPARENT | IDENTICAL |
| ca12 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 317] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| ca13 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_EQUAL 270] L[cmp=0 STRICT_EQUAL 270] same | unmoved off=pristine | IDENTICAL |
| ca14 | § contAssignLhsTsUnparented134 | P[cmp=38 NOT_EQUAL stage1] L[cmp=38 NOT_EQUAL stage1] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| ca15 | § contAssignLhsTsUnparented134 | P[cmp=17 NOT_EQUAL stage1] L[cmp=17 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT CAUNPARENT | EQUIVALENT |
| ca16 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_EQUAL 186] L[cmp=0 STRICT_EQUAL 186] same | unmoved off=pristine | IDENTICAL |
| ca17 | § contAssignLhsTsUnparented134 | P[cmp=517 NOT_EQUAL stage1] L[cmp=513 NOT_EQUAL stage1] moved | off=pristine laws: CAUNPARENT | EQUIVALENT |
| ca18 | § contAssignLhsTsUnparented134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 117] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| ca19 | § contAssignLhsTsUnparented134 | P[cmp=443 NOT_EQUAL stage1] L[cmp=443 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT | EQUIVALENT |
| hp01 | § tsHierPathElemNoName134 | P[cmp=64 NOT_EQUAL stage1] L[cmp=64 NOT_EQUAL stage1] moved | off=pristine laws: TSHPNAME | IDENTICAL |
| hp02 | § tsHierPathElemNoName134 | P[cmp=50 NOT_EQUAL stage1] L[cmp=50 NOT_EQUAL stage1] same | unmoved off=pristine | IDENTICAL |
| hp03 | § tsHierPathElemNoName134 | P[cmp=0 STRICT_NOTEQUAL col] L[cmp=0 STRICT_NOTEQUAL col] same | unmoved off=pristine | IDENTICAL |
| hp04 | § tsHierPathElemNoName134 | P[cmp=68 NOT_EQUAL stage1] L[cmp=68 NOT_EQUAL stage1] same | unmoved off=pristine | EQUIVALENT |
| hp05 | § tsHierPathElemNoName134 | P[cmp=50 NOT_EQUAL stage1] L[cmp=50 NOT_EQUAL stage1] same | unmoved off=pristine | IDENTICAL |
| hp06 | § tsHierPathElemNoName134 | P[cmp=0 STRICT_NOTEQUAL col] L[cmp=0 STRICT_NOTEQUAL col] same | unmoved off=pristine | IDENTICAL |
| nb01 | § elabNetTdCloneNoAlias134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] moved | off=pristine laws: ELABNETALIAS | IDENTICAL |
| nb02 | § elabNetTdCloneNoAlias134 | P[cmp=62 NOT_EQUAL stage1] L[cmp=62 NOT_EQUAL stage1] moved | off=pristine laws: ELABNETALIAS | IDENTICAL |
| nb03 | § elabNetTdCloneNoAlias134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] moved | off=pristine laws: ELABNETALIAS | IDENTICAL |
| nb04 | § elabNetTdCloneNoAlias134 | P[cmp=0 STRICT_NOTEQUAL type] L[cmp=0 STRICT_EQUAL 140] moved | off=pristine laws: ELABNETALIAS | IDENTICAL |
| nb05 | § elabNetTdCloneNoAlias134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] moved | off=pristine laws: ELABNETALIAS | IDENTICAL |
| pa01 | § typedefParentLastWriter134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 517] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa02 | § typedefParentLastWriter134 | P[cmp=101 NOT_EQUAL stage1] L[cmp=101 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT ANONMEMBER | IDENTICAL |
| pa03 | § typedefParentLastWriter134 | P[cmp=0 STRICT_EQUAL 276] L[cmp=0 STRICT_EQUAL 276] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa04 | § typedefParentLastWriter134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 198] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa05 | § typedefParentLastWriter134 | P[cmp=0 STRICT_EQUAL 256] L[cmp=0 STRICT_EQUAL 256] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa06 | § typedefParentLastWriter134 | P[cmp=0 STRICT_EQUAL 198] L[cmp=0 STRICT_EQUAL 198] same | unmoved off=pristine | IDENTICAL |
| pa07 | § typedefParentLastWriter134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 509] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa08 | § typedefParentLastWriter134 | P[cmp=264 NOT_EQUAL stage1] L[cmp=264 NOT_EQUAL stage1] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa09 | § typedefParentLastWriter134 | P[cmp=0 STRICT_EQUAL 161] L[cmp=0 STRICT_EQUAL 161] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa10 | § typedefParentLastWriter134 | P[cmp=0 STRICT_EQUAL 301] L[cmp=0 STRICT_EQUAL 301] same | unmoved off=pristine | IDENTICAL |
| pa11 | § typedefParentLastWriter134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_NOTEQUAL fullname] moved | off=pristine laws: TDPARENT | IDENTICAL |
| pa12 | § typedefParentLastWriter134 | P[cmp=0 STRICT_EQUAL 374] L[cmp=0 STRICT_EQUAL 374] moved | off=pristine laws: TDPARENT | IDENTICAL |
| rp01 | § pkgTsRefObjChainName134 | P[cmp=70 NOT_EQUAL stage1] L[cmp=70 NOT_EQUAL stage1] moved | off=pristine laws: TSREFCHAIN | IDENTICAL |
| rp02 | § pkgTsRefObjChainName134 | P[cmp=0 STRICT_NOTEQUAL depth] L[cmp=0 STRICT_NOTEQUAL depth] same | unmoved off=pristine | IDENTICAL |
| rp03 | § pkgTsRefObjChainName134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 211] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| rp04 | § pkgTsRefObjChainName134 | P[cmp=346 NOT_EQUAL stage1] L[cmp=346 NOT_EQUAL stage1] same | unmoved off=pristine | EQUIVALENT |
| rp05 | § pkgTsRefObjChainName134 | P[cmp=0 STRICT_NOTEQUAL depth] L[cmp=0 STRICT_NOTEQUAL depth] same | unmoved off=pristine | IDENTICAL |
| rp06 | § pkgTsRefObjChainName134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] moved | off=pristine laws: TSREFCHAIN | EQUIVALENT |
| rp07 | § pkgTsRefObjChainName134 | P[cmp=0 STRICT_EQUAL 187] L[cmp=0 STRICT_EQUAL 187] moved | off=pristine laws: CAUNPARENT | IDENTICAL |
| td01 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 198] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| td02 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_EQUAL 131] L[cmp=0 STRICT_EQUAL 131] moved | off=pristine laws: TDPARENT | IDENTICAL |
| td03 | § defNetTypedefEndWrite134 | P[cmp=36 NOT_EQUAL stage1] L[cmp=36 NOT_EQUAL stage1] moved | off=pristine laws: TDNETEND | IDENTICAL |
| td04 | § defNetTypedefEndWrite134 | P[cmp=639 NOT_EQUAL stage1] L[cmp=639 NOT_EQUAL stage1] moved | off=pristine laws: TDNETEND TDPARENT | IDENTICAL |
| td05 | § defNetTypedefArrayShares134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| td06 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_EQUAL 143] L[cmp=0 STRICT_EQUAL 143] same | unmoved off=pristine | IDENTICAL |
| td07 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL fullname] L[cmp=0 STRICT_EQUAL 289] moved | off=pristine laws: TDPARENT | IDENTICAL |
| td08 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 200] moved | off=pristine laws: TDNETEND TDARRSHARE CAUNPARENT | IDENTICAL |
| td09 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 175] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| td10 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_EQUAL 136] L[cmp=0 STRICT_EQUAL 136] same | unmoved off=pristine | IDENTICAL |
| td11 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 116] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| td12 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL endline] L[cmp=0 STRICT_EQUAL 159] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| td13 | § defNetTypedefEndWrite134 | P[cmp=52 NOT_EQUAL stage1] L[cmp=52 NOT_EQUAL stage1] moved | off=pristine laws: TDNETEND TDPARENT ANONMEMBER | IDENTICAL |
| td14 | § defNetTypedefArrayShares134 | P[cmp=58 NOT_EQUAL stage1] L[cmp=58 NOT_EQUAL stage1] same | unmoved off=pristine | IDENTICAL |
| td15 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL file] L[cmp=0 STRICT_NOTEQUAL file] moved | off=pristine laws: TDNETEND TDARRSHARE | IDENTICAL |
| td16 | § defNetTypedefEndWrite134 | P[cmp=0 STRICT_NOTEQUAL file] L[cmp=0 STRICT_NOTEQUAL file] moved | off=pristine laws: CAUNPARENT | IDENTICAL |

## 6. Residues found (ranked, none caused by the patch)

1. **Package-scoped name of a typedef over a typedef** (grid bc05: `p::byte_t v;` with `typedef nib_t [1:0]
   byte_t;`). The downstream verdict is EQUIVALENT with both binaries: the RTLIL `wiretype` attribute reads golden
   `\p::byte_t` against ours `\byte_t`. It is also strict `fullname`. § defNetScopedPkgVecTdShares134 excludes this
   shape on purpose (the `overAlias134` case, r11v111 y31_two_pkgs_rows), so the clone keeps the bare name. The next
   law should name that clone `p::byte_t`. Site: ModuleEmit.cpp materializeDefNetTs, next to
   § defNetScopedPkgVecTdShares134.
2. **Content from an included file carries golden's file `dut.sv`** (td15, td16: the typespec members of a typedef
   from an `include`d file). This is the include-line family of passes 125 and 130. The law cuts td15 from file(9) +
   endcol(3) to file(6) and clears td16's fullname(16). The rest is the include family's.
3. **Inline anonymous struct as a port type** (an03). Golden names the inner member refs `<in>in2.a`, and the port
   header span is pass 130's residue k07/c04. ANONMEMBER cuts fullname 5 -> 1.
4. **hier_path spans in ranges** (hp03, hp06: `col`) are the implementer's residue R6 (N0191).
5. **Package function local ranges** (rp02, rp05: a `depth` divergence at a folded bound constant). TSREFCHAIN does
   not fire there.
6. Judge-NE shapes met on the way, none moved by the patch:
   - `wire` of an unpacked array of a packed struct (td05);
   - a package typedef assigned with an initializer under `import` (ca19);
   - an assignment to a typedef-of-typedef variable (ca15);
   - a module-header import with an output of package struct type plus a variable initializer (ca17);
   - a program with an import (pa08);
   - `wand` nets (nb05);
   - a package parameter of a vector typedef (rp06).

The implementer's residues R1-R7 stand as reported: R1 in ParamEmit.cpp (the sister's ground), R2 gen-scope
reparenting, R3 N0045, R4 the enum relocation (v5b8 confirms it), R5 the elabuhdm clones, R6 N0191, R7 interface
definition nets.

## 7. Files

- `grid/<case>/dut.sv` — 82 cases (td15 and td16 carry an included file).
- `drivers/`:
  - case.sh: one case with both binaries.
  - fields.sh: per-field tallies.
  - sw.sh: the OFF and single-switch attribution.
  - ds.sh: the downstream verdict of one case.
  - bytes.sh: the byte-control mover scan.
  - probe_fc.py, corp_fc.py, corp_fc2.py: the census field checks.
- `evidence/`:
  - grid_scores.txt, switches.txt, ne_heads.txt;
  - downstream_fresh_law.txt, downstream_fresh_pris_nonident.txt;
  - sweep_pristine.txt, sweep_law.txt, downstream_law_summary.txt, downstream_law.csv;
  - probe_fc.txt, corp_fc.txt, corp_fc2.txt;
  - bv_*.txt (law vs pristine), bvoff_*.txt (OFF vs pristine), bvdet_*.txt (my law sweep vs the implementer's),
    movers.tsv, attribution_conversions.txt;
  - ctl_bytes.txt, ctl_judge.txt.
- The slang-fenced test's mover lines are left out of the evidence files. It moves in both modes, and the full OFF
  sweep gives it back.
