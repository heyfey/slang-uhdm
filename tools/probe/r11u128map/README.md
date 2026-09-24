# r11u128map — the strict ground map, second edition (measurement only)

Base `3051c07d` (branch matrix-1.87). No edit to `src/`, `scripts/`, `results/`, `tests/` or `third_party/`.
Worktree `/tmp/wt_r11u128`, system-deps config, `-j 2`. Frozen binaries (`chmod 555`, before any measurement):

| binary | md5 | what |
|---|---|---|
| `slang-uhdm` | `cb7b39bd1fa880fa84d54d11d9ff8ce2` | byte-identical to the main tree's `build/slang-uhdm` |
| `uhdm-strictcmp` | `88bf7040c706f80686ea981e6a8650c8` | byte-identical to the main tree's (identity canonicalisation, full names compared everywhere) |
| `slang-uhdm.g1` | `1c27f08f08d0…` | the same source with `-g1` line tables, used ONLY to pin minting sites under gdb; its database is byte-identical to the release binary's on the pinned case |

Inputs. The record dumps were taken from the 3051c07d strict sweep `/tmp/intr11u121` (read-only; every
`cmds.txt` names the main-tree `build/slang-uhdm` and a golden-cache `golden.uhdm`). A fresh pristine sweep with
the frozen binary (`/tmp/r11u128_sweep`) re-derived everything the map rests on (evidence/sweep_gates.txt):
strict cells identical to the committed `results/golden_*.csv` column 6 on 1596 + 1742 rows; every database
byte-identical to the dump input except the UVM order coin (MiniAmiq both modes, Scoreboard/default,
SimpleUVM/testflags); probe 4087/4087 strict-equal to the dump input.

Law names are written `law <name>` (never with the section sign): scripts/law_index.py reads every pass README
and would otherwise attribute the unnumbered laws named here to this map. Adding this directory still adds one
row (`| r11u128map |  |  | 0 | 0 |`) to the passes table of tests/LAWS.md: the landing must run
`python3 scripts/law_index.py` and commit tests/LAWS.md with it (this pass may not edit tests/).

## 0. Where we stand (3051c07d)

| corpus | judge-equal row-modes | strict-equal | strict NOT equal | tests judge-equal | tests NE in some mode |
|---|---|---|---|---|---|
| surelog | 954 (480 + 474) | 521 (267 + 254) | 433 (213 + 220) | 480 | 233 |
| uhdm2rtlil | 1606 (803 + 803) | 1072 | 534 (267 + 267) | 803 | 267 |
| probe cases | 4087 | 1712 | 2375 | — | — |

First fields over both corpora: file 345, fullname 309, endcol 71, line 52, value 46, depth 37, col 37,
endline 31, type 20, count 9, name 8, decompile 2 (all 967 row-modes reproduced by the tool: first field and
`objects_differing` equal the csv cell on 967/967). Downstream (the consumer): 803 IDENTICAL / 66 SLANG_REJECT /
2 EQUIVALENT / 0 DIVERGENT of 871 (fresh sweep = baseline).

## 1. Method (what changed since r11u122map)

1. `drivers/jobs.py` + `drivers/run1.sh`: `uhdm-strictcmp --max 50 --dump-a --dump-b golden.uhdm slang.uhdm` on
   all 967 strict-NE corpus row-modes (both modes: 30 surelog tests differ by mode, law8) and on all 4087 probe
   cases (`drivers/probejobs.py`; goldens = the check_probe cache entries; 1712 rc 0, 2375 rc 2).
2. `drivers/analyze.py` (r11u122's aligner, unchanged in its alignment) records EVERY differing object:
   facet (name / fullname / file / span / value / struct / depth / order), object type, name, the walk-parent
   chain, golden vs ours. 1,274,664 corpus facets, 32,247 probe facets. The records now come from the
   CANONICAL walk (typespec subtrees and enum constants re-expanded at every reference), so the old
   typespec-copy clusters (C0002/4/5/6/8/10/11) are gone as identity; what remains under a typespec is content.
   New: an anchored identity key per record (located: type name defname file span decompile value;
   unlocated, e.g. every ref_typespec: the nearest located ancestor's key) gives, per full-name object, how many
   distinct full names each side gives the same source object (law6).
3. Cluster key = `facet|type|shape|under:<walk parent type>` (r11u122's, so every cluster carries its old id in
   `cluster_index.csv` column `r11u122_id`), split twice (`drivers/common.py`): a file facet naming builtin.sv
   (`@builtin`), and a full-name facet on a non-ref_typespec object inside a typespec subtree (`@in-typespec`,
   the F02 ground). 2617 clusters (2099 with corpus rows), 314 families. Ids `K####` ranked by corpus row-modes,
   then probe cases.
4. Coverage (`final.py:coverage`): COVERED r11u124 = r11u122 C0003 C0012 C0007 C0009 C0013 C0037 C0015 C0028
   C0019 C0020 C0034 C0044 C0014 + family FULLNAME-IN-TYPESPEC-SUBTREE (F02 parent policy); COVERED r11u125 =
   C0001 C0582 C0104 + FILE-OTHER-BUFFER (F10) + STRUCT-TSCOPY|ours (F04) + FILE-BUILTIN + the FILE-EMPTY census
   sites a pin landed on (evidence/coverage_overrides.json: K0023, K0066, K0071; K0037 is C0019's span twin,
   the same 346 objects). Everything else is OPEN.
5. Sites: `drivers/objrank.cpp` lists every object of our database with its creation rank per type (the
   Serializer's `UhdmId` order); `drivers/pinsite.sh` stops the `-g1` exporter at that rank's
   `Serializer::Make<Type>` and prints the backtrace; `drivers/pinall.py` names the nearest `law law` above each
   frame. PINNED = the minting frame read on one example of the cluster (evidence/pins.txt); a mint site is where
   the object is born — the differing field may be written elsewhere, which the site column says when it is.
6. Yield (`final.py`): a row-mode clears only when EVERY object of it falls in fixed clusters; a test clears
   when every NE mode clears. OPTIMISTIC = a covered cluster is fixed whole. REALISTIC = the identity residue
   (law6, law7) is split out as unfixable without a copy per use.

## 2. Positive controls (evidence/controls/)

| control | result |
|---|---|
| surelog/default/1364_2005 | `STRICT_EQUAL 159 objects`, record dumps byte-identical (159) |
| surelog/default/HierPathInterfBlock | `STRICT_EQUAL 226 objects`, dumps identical (226) |
| uhdm2rtlil/default/1DUnpackedArray | `STRICT_EQUAL 194 objects`, dumps identical (194) |
| uhdm2rtlil/{default,testflags}/stamped_gen_param | rc 1 `NOT_EQUAL stage1`, `lhsPath: design(work@stamped_gen_param) > module_inst(work@stamped_gen_param) > gen_scope_array(gen_grps[0]) > gen_scope > param_assign > constant` (no record dumps: stage 2 not reached) |
| tool vs committed cells | 967/967 |
| probe gate | EQUAL=4087 of 4087, strict equal=1712 (the check_probe histogram equals the per-case tool runs) |

## 3. Coverage by the live pairs

| | clusters | row-modes touched | alone yield (optimistic) | alone yield (realistic) |
|---|---|---|---|---|
| r11u124 (pair A) | 482 | 554 | 223 rows / 112 tests | 146 rows / 72 tests |
| r11u125 (pair B) | 221 | 323 | 136 rows / 69 tests | 136 rows / 69 tests |
| both landed | 703 | — | **388 rows / 196 tests** | **297 rows / 149 tests** |

The gap for pair A is the identity residue inside F02: of F02's 488,335 full-name objects, 201,061 are
USE-SITE (golden gives the object more names than ours has objects; 248 row-modes carry one), 10,782 are
STABLE (145 row-modes) and 276,492 are USE-SITE-BOTH (169). A parent-policy law reaches STABLE and
USE-SITE-BOTH; it cannot reach USE-SITE without a copy per use (law6). Pair A's non-F02 full-name clusters
(C0009, C0013, C0037) are 6,454 STABLE / 157 USE-SITE objects: a naming law is enough there
(C0009 = K0016: 6,100 objects, all STABLE).

## 4. Ranked OPEN clusters with emitter sites

Rows = corpus row-modes (surelog/u2r); alone = rows cleared by this cluster alone; +pairs = rows cleared when
this cluster lands on top of both pairs (base 388; the gain in parentheses). Twins (the same objects on another
field, or the two sides of one walk-order move) are merged into one line. Site = PINNED mint (function, file, nearest law law) unless
marked DECODED (read from records/source) or OWNER (candidate). Full list: cluster_index.csv; one evidence file
per cluster in evidence/clusters/ (top 80 overall, top 80 OPEN, the structural ones).

| # | cluster (r11u122) | rows sl/u2r | tests | probe | alone | +pairs | key | example (golden vs ours) | site / decode |
|---|---|---|---|---|---|---|---|---|---|
| 1 | K0017 (C0024) | 39 15/24 | 22 | 29 | 15 | 406 (+18) | `struct\|golden-only:fewer-copies\|logic_net\|under:ref_obj` | ParameterColonReference: golden's elab cont_assign LHS `ref_obj a` → a net re-listed with no typespec; ours → the elab net | NET-BINDING (law5 class A). ref_obj minted in emitExpr, ExprEmit.cpp (law staticScopedLvalueBad48 block) from emitContAssigns / emitInstance high-conn, ModuleEmit.cpp; the Actual choice is the defect |
| 2 | K0024 (C0059) | 32 14/18 | 16 | 22 | 0 | 390 (+2) | `span\|struct_typespec\|endline+endcol\|under:ref_typespec` | RangeSelect `tl_h2d_t`: golden 2:12-6:17 (typedef start to the `a[4]` declarator end), ours 2:12-4:5 | USE-SITE span (law7): golden's per-declaration copy ends at the declarator. buildStructTs, TypeEmit.cpp (law typeParamAnonAggMemberNoReduce35) — our one shared object; needs a per-declaration copy |
| 3 | K0025 (C0039) | 32 12/20 | 16 | 5 | 2 | 392 (+4) | `span\|constant\|col+endcol\|under:param_assign` | BlackParrotSkipParam `($clog2(max_val_p+1))`: golden 4:31-52 (with the parens), ours 4:32-51 | PINNED emitParameters, ParamEmit.cpp (law patOpMemberAsmSplit28 block): the folded RHS constant takes the inner span; the paren rule of law pkgQualPsParenSpan118v, generalised to folded param_assign RHS |
| 4 | K0027 (C0042) | 29 21/8 | 18 | 26 | 7 | 397 (+9) | `file\|logic_net\|golden-empty\|under:ref_obj` | CheckerInst `req`: golden no file, ours dut.sv | VERIFIED: Surelog's late-binding implicit net (UhdmWriter.cpp, the lookup-miss mint copying the ref's four span fields and no file) = law implicitNetNoFile119's producer; its "NOT noted" roads: emitPropFormalRef and emitExpr's implicitNetMap mints, ExprEmit.cpp (PINNED: law oobCtorLocalsRideTheImport203 block) |
| 5 | K0028 + K0058 (C0216/C0219) | 29 13/16 | 15 | 5 | 4 | 396 (+8) | `file\|enum_typespec\|ours-empty\|under:ref_typespec` | TypeParameterAsPortTypeWithEnumOfParametrizedWidth `state_e`: golden dut.sv 12:3-14:13, ours no file, 0:0:0:0 | PINNED buildEnumTs, TypeEmit.cpp (law pkgTdCloneRefNoBind18 block) via makeTypespec: an enum typespec minted with no location at all (K0058 = its span twin: 19 of the 29 row-modes, the same records) |
| 6 | K0034 (C0057) | 26 24/2 | 13 | 16 | 8 | 396 (+8) | `file\|logic_net\|golden-empty\|under:module_inst` | Disable `loop` (the `disable loop` target): golden no file | as #4; PINNED emitModuleDef, ModuleEmit.cpp (the law implicitNetNoFile119 definition-net loop) + the disable-target implicitNetMap mint in emitStmt, StmtEmit.cpp |
| 7 | K0035 (C0049) | 26 6/20 | 13 | 5 | 0 | 388 (+0) | `span\|constant\|endline+endcol\|under:sys_func_call` | CovMacro: golden 12:31-12:32, ours 12:31-0:0 | macro-argument spans. PINNED emitExpr constant, ExprEmit.cpp (law srlgTimeLitVal block); probe law macroQuoteContLeak11. Rides with r11u125's F10 macro decode but is a span, not a file |
| 8 | K0036 (C0054) | 25 21/4 | 13 | 18 | 0 | 390 (+2) | `fullname\|ref_obj\|ours-empty\|under:hier_path` | LocalScopeHierPath `path`: golden `pack::uvm_mem_mam::check_reg::path`, ours bare | PINNED emitExpr, ExprEmit.cpp (law vifClockingPathComponent5 block) from the inc/dec operand (law incDecStmtOperandBinds21). Class mix: 774 STABLE / 792 USE-SITE objects |
| 9 | K0043 (C0051) | 21 17/4 | 11 | 16 | 0 | 388 (+0) | `fullname\|ref_obj\|tok:id.id.->\|under:operation` | dff_different_styles: golden `work@dffsr2.uut.preset.preset`, ours `work@dffsr2.preset` | port high-conn operand ref_obj: PINNED emitExpr (law staticScopedLvalueBad48 block) from emitInstance (law elabPortConnUnitEnumNet caller), ModuleEmit.cpp. Golden parents it under the port (the same ref_objs as class A) |
| 10 | K0044 + K0045 (C0065/C0066) | 21 9/12 | 12 | 3 | 6 | 394 (+6) | `struct\|golden-only/ours-only:elsewhere\|logic_net` | sva_value_change_changed `clk`: golden first reaches the net from the clocking-block event, ours from the always | NET-BINDING (class A): PINNED emitEventExpr, StmtEmit.cpp (law evCtrlOperandBinds108) from emitScopeClocking, ModuleEmit.cpp (law clockingSkewDelayControl) |
| 11 | K0047 (C0004) + K0099 | 20 12/8 | 10 | 37 | 0 | 388 (+0) | `struct\|golden-only:fewer-copies\|struct_typespec\|under:ref_typespec` | cva6_struct_param_field: the tagged-pattern key operation's typespec is golden struct `cfg_pkg::cfg_t`, ours integer_typespec | CONTENT (the cast target): PINNED emitExpr, ExprEmit.cpp (law castTgtDefaultIsLiteral) |
| 12 | K0048 (C0067) | 20 16/4 | 11 | 37 | 2 | 392 (+4) | `span\|logic_typespec\|endcol\|under:ref_typespec` | SignedWire: golden 2:1-12, ours 2:1-19 | PINNED makeTypespec, TypeEmit.cpp (via emitPackageVar / emitImportedPkgVarNets): the net-type keyword span (`wire` vs `wire signed`) |
| 13 | K0049 + K0057 (C0613/C0764) | 20 6/14 | 11 | 12 | 0 | 388 (+0) | `depth\|constant\|range->operation` | TypedefWithParameter: golden's elab typedef range bound is a folded constant, ours an operation `X-1` | CONTENT (fold): PINNED emitSyntaxExpr, TypeEmit.cpp (law hpSymbolicSelect) via makeTypespec (law typedPkgBoundElabSize113 caller) |
| 14 | K0050/51/54/55 (C0069-C0072) | 20 0/20 each | 10 | 1-10 | 0 | 388 (+0) | `span\|constant/sys_func_call\|line…\|under:sys_func_call/begin` | ibex_csr `$error`/`$time` in the prim_assert macros: golden 29:10-51, ours 32:10-51 | MACRO-SPAN: PINNED emitExpr sys_func_call, ExprEmit.cpp (law enumNoBaseTypespecZeroBits28 block) and the constant case (law srlgTimeLitVal); same rows as F10 (r11u125) — hand the span half to the F10 brief |
| 15 | K0052 (C0098) | 20 14/6 | 11 | 6 | 0 | 388 (+0) | `span\|struct_typespec\|line+col+endline+endcol\|under:ref_typespec` | const_cast_signext `op_t`: golden 19:42-46 (the reference), ours 15:11-61 (the declaration) | USE-SITE span (law7): buildStructTs via makeTypespec from emitParameters (law typeParamChainBorrow45 caller) |
| 16 | K0053 (C0073) | 20 8/12 | 10 | 3 | 2 | 392 (+4) | `file\|packed_array_typespec\|ours-empty\|under:ref_typespec` | EnumArray: golden dut.sv 0:0:8:46, ours no file | PINNED makeTypespec, TypeEmit.cpp (law classPkgGenericSpecListing53 block) via sharedTypespec / materializeDefNetTs — not a census line |
| 17 | K0056 (C0046) | 19 11/8 | 11 | 58 | 0 | 393 (+5) | `fullname\|ref_obj\|tok:id.->\|under:operation` | EmptyAssign: golden `work@top.dut.b`, ours `work@dut.b` | elab-process ref_obj named by the definition: PINNED emitSyntaxExpr (law modStructMemberPkgFold) and emitExpr (law genLpUseFoldParentScope47 caller); probe law nestedGenProcLhsKeepsRef116 (43 cases) |
| 18 | K0060 (C0085) | 18 10/8 | 9 | 34 | 2 | 394 (+6) | `span\|func_call\|endcol\|under:param_assign` | struct_param_func_arg `p::build`: golden 16:39-42, ours 16:39-40 | PINNED emitExpr, ExprEmit.cpp (law defGenQualPkgCallBinds18): the package-qualified call span (r11u118's pkgQual span family) |
| 19 | K0062 + K0064 + K0076 (C0080/C0083/C0094) | 18+18+16 | 9 | 16 | 0 | 388 (+0) | `value\|parameter\|value:UINT/INT->empty` | IntegerConcat `InfoPageW`: golden UINT:2, ours none | PINNED ParamEmit.cpp emitParameters: K0062/K0064 on the upLhs9 import-Lhs clone (law elabReExportPaLhsShare) = **C0003's object** (r11u124): add the value stamp as a rider of that pass; K0076 at law unsizedBasedParamRhsSize106 |
| 20 | K0067 (C0079) | 18 8/10 | 9 | 1 | 4 | 395 (+7) | `span\|ref_obj\|endcol\|under:port` | WildConn `a`: golden 14:5-6, ours 14:5-7 | PINNED emitExpr from emitInstance (law elabPortConnUnitEnumNet caller), ModuleEmit.cpp: the `.*`/implicit connection ref span |
| 21 | K0070 (C0112) | 17 17/0 | 10 | **224** | 0 | 388 (+0) | `span\|int_typespec\|line+col+endline+endcol\|under:ref_typespec` | TypeParam DATA2: golden 17:85-88 (the type_parameter's typespec), ours 20:5-8 | DECL vs USE: golden binds the type parameter's own typespec object; PINNED makeTypespec, TypeEmit.cpp (law shadowedImportBoundFold block); probe laws badConcatOperandsFromSyntax160 (57), law nestedParamActualTs6 (22) |
| 22 | K0074 (C0100) | 16 6/10 | 8 | 73 | 2 | 396 (+8) | `span\|struct_typespec\|endcol\|under:ref_typespec` | gen_scope_typaram `pair_t`: golden 17:13-60, ours 17:13-26 | USE-SITE-like (the declarator end): buildStructTs via sharedTypespec / emitTopPorts (law defNetTsScope caller) |
| 23 | K0075 (C0358) | 16 8/8 | 8 | 12 | 0 | 388 (+0) | `struct\|golden-only:fewer-copies\|constant\|under:typespec_member` | StructParamPatternInitCast: golden member default constant listed inside the struct | IDENTITY (r11u123: a constant first visited outside any typespec is not re-expanded; walk completeness, not content) |
| 24 | K0085 (C0109) | 15 7/8 | 8 | 55 | 0 | 396 (+8) | `fullname\|parameter\|tok:id->id.id.id\|under:param_assign` | InterfType: golden `work@tnoc_types.PACKET_CONFIG`, ours `work@dut.tnoc.types.PACKET_CONFIG` | nested interface-instance parameter named by its DEFINITION in golden; PINNED emitParameters (law unsizedBasedParamRhsSize106 block) from emitInterfaceInstance (law ifaceIfaceTypedPort); all 18 objects USE-SITE-BOTH (a naming law on our objects) |
| 25 | K0087 + K0088 (C0106/C0125) | 15+15 sl | 8 | 28/20 | 0 | 388 (+0) | `span\|class_typespec\|…\|under:ref_typespec` | ArrayMethodIterator `uvm_callback`: golden 10:50-62 (the reference), ours 14:3-5 | USE-SITE span on class_typespec (law7): buildClassTypedefTs, UhdmExporter.cpp (law classTpTdGroupNonClsRootShared91) and makeTypespec, TypeEmit.cpp (law arrayElemTdClone42) |

Greedy by marginal yield on top of both pairs (clusters): K0017 406, K0027 415, K0034 428, K0080 437,
K0074 445, K0085 453, K0067 460, K0060 466, K0120 472, K0200 478, K0587 484, K0056 489, K0024 493, K0349 499,
K0025 503, K0043 507, K0048 511, K0053 515, K0098 519, K0103 523 (rows; evidence/final_all.txt has the tests).
Single clusters clear little: a row carries 1–50 clusters. The brief-sized unit is the family (law5).

## 5. OPEN families (brief-sized) and the structural rows

**OPEN families, greedy on top of both pairs** (the open part of each family; cumulative row-modes / tests;
evidence/final_all.txt):

OPTIMISTIC (a covered cluster is fixed whole; base 388 / 196): 1 FULLNAME|ref_obj|tok (G04, 137 rows touched,
311 open clusters) 420 / 218 · 2 FILE-EXTRA|logic_net (G17) 443 / 229 · 3 SPAN|struct_typespec (G09) 465 / 240 ·
4 STRUCT-SHARE|golden|logic_net (G12) 487 / 252 · 5 STRUCT-SHARE|ours|logic_net (G20) 510 / 264 ·
6 SPAN|operation (G13) 528 / 273 · 7 FULLNAME|parameter|tok (G38) 542 / 280 · 8 SPAN|func_call (G27) 555 / 286 ·
9 SPAN|ref_obj (G03, open part) 566 / 291 · 10 SPAN|constant (G05, open part) 574 / 295 · … 25 steps 679 / 347;
every cluster 967 / 500.

REALISTIC (the law6/law7 identity residue split out; base 297 / 149): 1 FILE-EXTRA|logic_net 317 / 158 ·
2 SPAN|struct_typespec 335 / 167 · 3 STRUCT-SHARE|golden|logic_net 352 / 176 · 4 STRUCT-SHARE|ours|logic_net
371 / 186 · 5 FULLNAME|ref_obj|tok 390 / 196 · 6 FULLNAME|parameter|tok 401 / 201 · 7 SPAN|ref_obj 411 / 206 ·
8 SPAN|operation 421 / 211 · 9 FULLNAME|bit_select|tok 429 / 215 · 10 VALUE|parameter|empty->UINT 437 / 219 ·
… 20 steps 491 / 245; every cluster fixed, residue kept: **684 / 338**.

**The 66 STRUCTURAL row-modes (first field depth 37 / count 9 / type 20)** — every one decoded:

| class | row-modes (tests) | clusters | what differs | Surelog's writer | our site | fixable without copying typespecs? |
|---|---|---|---|---|---|---|
| A. NET-BINDING | 32 (17: surelog Moves/default, PackageParamConst/default; u2r Clog2OfSumWithParameterIn2InstancesOfSubmodule ParameterColonReference StructLocalParam StructParameter array_assign cdc_static_basic param_type_logic_width partsel_simple sva_range sva_throughout sva_value_change_changed sva_value_change_changed_wide sva_value_change_rose vector_index wandwor, both modes) | K0017 K0080 K0044 K0045 | which net object `ref_obj.Actual` names: golden's elaborated cont_assign LHS / port high-conn operand / clocking event binds the DEFINITION's net (re-listed after the listener's epoch clear, with the definition's children — no typespec where the definition net has none), ours the elaborated net; K0080 is the mirror (net_decl_assign RHS: golden elab, ours def) | 280 of 281 extra nets are a re-listing of an identical earlier record (evidence/netchk.txt). Candidate mechanism: `ElaboratorListener::bindNet` resolves a PORT name through the port's low_conn `ref_obj->Actual_group()`, which keeps the definition net | the Actual chosen in emitContAssigns / emitInstance high-conn / emitEventExpr (law4 #1, #9, #10) | **YES**: a binding law (point Actual at the definition net in the named shapes), no new object. All 15 u2r tests are downstream IDENTICAL |
| B. TYPEDEF-ALIAS on the net typespec | 6 (WireType, LogicTypedef, net_types; both modes) | K0133 | ours' net typespec carries `Typedef_alias` (ref_typespec > the typedef's typespec), golden's copy has none | relation ABSENT in golden: content (r11u123) | candidates PINNED: emitModuleDef (law ifaceDefNetTypespecIsTheModuleRule224), emitPorts (law tpDimVecPortTsIsDefault120), emitInstance (law pkgScopedPaStructStrictNetVar88), ModuleEmit.cpp | YES (drop the alias on the net's typespec in these shapes). Family F04 → COVERED r11u125, but it is content, not a copy |
| C. CONSTANT / PARAMETER IDENTITY | 10 (DefaultPatternInt, DefaultPatternModule, ParamArrayUnsizedPattern, ParamFromPackage, ParameterFromPkgOnParameterPortList) | K0005 (C0012, r11u124) K0590 K0131 | golden's imported param_assign Lhs is a module-scoped clone (C0012); golden's array_expr lists ONE constant twice where ours has two (K0590) | CompileHelper importPackage clone (C0012); shared default constant | K0590 PINNED emitParameters, ParamEmit.cpp (law patOpMemberAsmSplit28, law foldSigned9) | YES for K0590 (share the constant); C0012 is r11u124's |
| D. MEMBER DEFAULT + CAST TARGET | 8 (StructParamFuncBodyFieldCompare, def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot) | K0075 K0047 K0099 K0936 K0938 | a member default constant visited first outside the typespec (identity, walk completeness); the tagged-pattern key's cast typespec (content: golden struct, ours integer) | the constant: identity; the cast: content | K0047/K0099: emitExpr, ExprEmit.cpp (law castTgtDefaultIsLiteral) | the constant needs nothing (walk); the cast: YES |
| E. FOLD CONTENT | 6 (FunctionParam, SelectGivenBySelectOnParameterInFunction, func_local_array) | K0197 K0374 K1308 K0339 | golden keeps the elaborated cont_assign's `func_call`, ours folds it to a constant (type first field); golden's constant actual argument carries the formal's typespec (K0339, **113 probe cases**) | Surelog does not evaluate a function call on the elaborated cont_assign RHS; it stamps the formal's typespec on a constant argument | emitContAssigns elaborated RHS, ModuleEmit.cpp (law liveCallEntryIsContAssignRhs, law caAsmMemberSliceFold) | YES (no fold in this shape; add the typespec) |
| F. TYPE-PARAMETER DEF NET | 2 (TypeParam) | K0950 K0979 | the definition net typed by a type parameter: golden logic_typespec (the parameter's default), ours int_typespec | content | emitClassParameters / makeTypespec (PINNED on a probe case) | YES |
| G. EXTRA FOLDED CONSTANT | 2 (BlackParrotComplex) | K0904 | ours lists a folded param_assign constant (size 50) with an unlocated logic typespec golden lacks | content | PINNED tryFoldConst, ExprEmit.cpp (law srlgSizeCastUbShiftMask93) from emitParameters (law castElabFoldTargetKinds) | YES |

## 6. The FULLNAME family: declaration-stable vs use-site-dependent

For each full-name-differing object, the anchored identity key groups every listing of the same source
object (a golden copy per use, or our re-expanded share). **STABLE**: golden gives it one name at every use →
a parent-link / naming law can match it. **USE-SITE**: golden gives more distinct names than ours has
(its per-use copies are named from their use sites; ours holds one object) → matching needs a copy per use:
the IDENTITY RESIDUE. **USE-SITE-BOTH**: golden names per use and ours already has at least as many names →
a per-use parenting law on our existing objects can match.

| population | STABLE | USE-SITE (residue) | USE-SITE-BOTH |
|---|---|---|---|
| corpus row-modes with a full-name facet (510; worst class per row) | 138 | **271 (156 tests; surelog 129, u2r 142)** | 101 |
| rows whose FIRST field is fullname (309) | 70 | 176 | 63 |
| rows whose every facet is a full name | 34 | 68 | 31 |
| probe cases with a full-name facet (1319) | 416 | 428 | 475 |
| objects in F02 (r11u124's parent policy) | 10,782 | 201,061 | 276,492 |
| objects in OPEN full-name clusters | 17,518 | 57,718 | 54,401 |

Top shapes (evidence/fnclass.txt): K0004 `id.->` under typespec_member 90 / 6453 / 1137 (49 rows carry
USE-SITE: GenForIfaceLocalparamNestedGen golden names `p::bus_t.DAT` four ways, ours two); K0007 `->id.`
0 / 24442 / 126; K0016 (C0009) 6100 / 0 / 0 (all stable: a naming law); K0030 `pkg::A::N` vs `pkg::A.N`
102 / 0 / 0; K0085 0 / 0 / 18. **The explicit residue the flip must carry: 271 row-modes (156 tests)**, of
which 68 row-modes have nothing else wrong. With the 28 row-modes of the span residue (law7) the residue
touches 283 row-modes (162 tests); fixing every other cluster clears 684 of 967 row-modes (338 of 500 tests).

## 7. Spans on typespec copies: the residue in span form

The same test on span/file facets of NAMED typespecs (golden distinct (file, span) per (type, name) vs ours;
`drivers/tsspan.py`, evidence/tsspan.txt): 28,994 USE-SITE objects, 26,220 USE-SITE-BOTH, 2,613 STABLE, 18,084
unnamed (not classified). Golden's per-use copies carry the REFERENCE's span (class_typespec `uvm_callback`
10:50-62 at the use; struct `op_t` 19:42-46 at the parameter's type; an unpacked-array element struct ending at
its declarator, RangeSelect 6:17). Only 28 row-modes carry a USE-SITE typespec span (the objects concentrate in
the UVM rows), but they need a copy per use like law6.

## 8. Flip preview (evidence/flip_preview.txt has every name)

If the gate flipped to strict today:

| corpus | mode | judge-equal | strict-equal | would leave CMP_EQUAL | of those downstream IDENTICAL |
|---|---|---|---|---|---|
| surelog | default | 480 | 267 | **213** | n/a (no downstream lane) |
| surelog | testflags | 474 | 254 | **220** | n/a |
| uhdm2rtlil | default | 803 | 536 | **267** | **266** (func_upto EQUIVALENT) |
| uhdm2rtlil | testflags | 803 | 536 | **267** | **266** |

233 surelog tests leave in some mode. NE in default only: BiasValue BlackBoxInst BlackBoxInstTop BlackBoxMod
BlackBoxSubMod DecValue Moves PackFunc PackageParamConst PortInitVal. NE in testflags only: AllPackageSignal
ArrayExprFuncArg ArrayVarName ClogParam DollarBits EmptyAssign FileList ForeachFunction FuncParam FuncRetArray
FuncStruct ImplicitPackedStructNet InterfInst InterfaceUnpackedStructArrayDim JKFlipflop NoParamSubs
OneNetInterf PortByName TypespecExpr UnsizedFunc. Judged in one mode only: Rggen Scoreboard YosysBigSimEllip.
The u2r modes are identical (267 = 267, same names). **266 of the 267 u2r tests the flip would fail are
downstream IDENTICAL**: the consumer is satisfied. func_upto (the one EQUIVALENT) is wholly K0001 (C0001,
2477 objects) + K0610 (C0582, 333): both r11u125. matching_end_labels (the other EQUIVALENT) is strict-equal.
Predicted after both pairs land: 297–388 of 967 row-modes clear (realistic–optimistic); per mode realistic:
surelog 67 + 58, u2r 86 + 86.

## 9. Probe cases by law

2375 NE cases in 1076 clusters (probe_clusters.csv: case, law, first field, cluster, objects; law from
scripts/law_index.py). 625 NE cases fall wholly in COVERED clusters. Laws with the most NE cases:
loopCaParamReadKeepsLiteral116 96/123, nestedGenProcLhsKeepsRef116 74/74, badConcatOperandsFromSyntax160
71/71, genCaOpFoldElabTs115 68/68, tpPackedArrayTsVar108 58/73, tpElemRebindElabPort110 57/61,
pvExprDefaultFold115 48/50, portViewRangeRecvParams 46/55, typedPkgBoundElabSize113 42/46,
srlgCondOpInstValueTernFold9 37/140. Probe-heavy OPEN clusters the corpus barely shows:
K0070 (int_typespec decl-vs-use span, 224 cases), K2107 (`fullname|logic_net` nested-module def
`work@sub.work@sub::innermod.i` vs `work@sub::innermod.i`, 119 cases, 0 corpus rows; laws
caNestedModPortedDefShell101, caTopNamesakeKeyAtEntry105), K0339 (constant argument's formal typespec, 113),
K0218 (golden ref_typespec under parameter, 85), K0189/K0191/K0856 (array_typespec / range spans of port views,
law portViewRangeRecvParams, 69–79), K0219/K0220 (function begin unlocated, law badConcatOperandsFromSyntax160, 71),
K0917 (parameter `[n]` fullname of interface-array views, 68).

## 10. Residues, ranked (what the next briefs should take — OPEN only)

1. **NET-BINDING (K0017 K0080 K0044 K0045 + K0043's names)** — 32 structural row-modes, the largest single
   yield (alone 32; on top of both pairs 388 → 423, +35 row-modes / +19 tests); a binding law, no copies. All u2r rows downstream IDENTICAL.
2. **FILE-EXTRA|logic_net (K0027 K0034)** — extend law implicitNetNoFile119 to the implicitNetMap mints
   (emitPropFormalRef, emitExpr, the disable target); VERIFIED producer. Alone 20; on top of both pairs +22 row-modes (410 / 206 tests).
3. **FULLNAME|ref_obj (G04, 137 rows)** — elab-process and high-conn ref_obj names (K0056, K0043, K0036,
   K0120, K0200); mostly STABLE / USE-SITE-BOTH, so a naming law reaches them.
4. **Unlocated typespecs (K0028/K0058 enum, K0053 packed_array)** — buildEnumTs / makeTypespec mint with no
   location (not census lines: r11u125's census does not reach them).
5. **Paren and macro spans (K0025, K0035, K0050-K0055, K0065, K0072, K0077)** — the r11u118 paren rule on folded
   RHS constants; macro-argument spans alongside r11u125's F10.
6. **Fold content (class E + K0049/K0057 + K0339)** — elab cont_assign function calls, typedef range folds,
   the formal typespec on constant arguments (113 probe cases).
7. **Parameter values on the import-Lhs clone (K0062 K0064)** — the C0003 object: a rider for r11u124.
8. **The identity residue** — 271 (full name) + 28 (typespec span) row-modes that need a copy per use; the
   flip carries them explicitly or the comparator scopes them.

## Files

* `clusters.csv` — every (row-mode, cluster) with its object count (test,mode,corpus,first_field,cluster_id,objects; 9951 rows).
* `probe_clusters.csv` — every (probe case, cluster) (case,law,first_field,cluster_id,objects; 8571 rows).
* `cluster_index.csv` / `family_index.csv` — ranked, with rows per corpus, probe cases, alone yield, coverage, the r11u122 id, the top probe laws, an example.
* `evidence/objects.csv` — one example object per (corpus row-mode, cluster): type, name, walk-parent chain, golden vs ours.
* `evidence/clusters/K####_*.txt` — golden and our records around the object, the holder on the other side, every facet of that row.
* `evidence/pins.txt` + `pinprep.tsv` — the gdb backtraces of the minting frames with the nearest law law.
* `evidence/fnclass.txt`, `tsspan.txt`, `netchk.txt`, `final_all.txt`, `flip_preview.txt`, `census.txt` (the FILE-EMPTY census rerun: 33 sites), `sweep_gates.txt`, `controls/`, `coverage_overrides.json`.
* `drivers/` — `run.sh` (the pipeline), `jobs.py`, `run1.sh`, `probejobs.py`, `probelaw.py`, `analyze.py`, `common.py`, `final.py`, `fullname_classes.py`, `tsspan.py`, `netchk.py`, `evid.py`, `objrank.cpp`, `pinprep.py`, `pinsite.sh`, `pinall.py`.
