# r11u157 — the hier_path element family, decoded at Surelog's two writers (measurement only)

Base 4e20e0d5. Analyst pass: the law is delivered as [law.patch](law.patch) (a diff of `src/ExprEmit.cpp` only,
applies clean on a fresh 4e20e0d5, `git apply --check` measured) for the expression-ground pair (pair A) to land.
Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is changed by this pass's deliverable.
`tools/uhdm-strictcmp` is unchanged (no defect found; no canonicalisation patch was supplied with the brief).

Binaries (frozen, chmod 555): pristine `slang-uhdm` md5 0b3b2d0a323c (byte-identical to the main tree's),
law binary md5 2993cfd94d61 (4e20e0d5 + law.patch), `uhdm-strictcmp` md5 5d4617d0458f (the committed tool).

## 1. Verdict

The family is ONE decode: Surelog builds a plain dotted path (`a.b.c`) in exactly two functions, and the
**grammar position** of the path — not whether it is an lvalue — picks the function. Our exporter keyed the same
choice on `inLhs` (plus a packed-struct parameter flag), which is right at the top of an assignment and wrong
inside a select index, a part-select bound, a size-cast width, a parameter value, an assignment pattern, a call
argument and the true branch of a constant `?:`. Two further writers (the `this.` handle and the `foreach` array
variable) and two naming details (the `$root` branch, the `with`-receiver loop) complete the family.

Measured on the full gate sweep with the law binary (tests/sweep.sh, all four stages, `--jobs 3`):

| stage | regressions | conversions | changes (detail only) |
|---|---|---|---|
| probe (4087) | 0 | 9 (EQUAL 2445 -> 2454) | 23 |
| surelog both modes | 0 | 1 (`LocalScopeHierPath` default) | 11 |
| uhdm2rtlil both modes | 0 | 6 (`expr_width_cast`, `mem_ff_partial_rsp`, `portsel_struct_param`, both modes) | 4 |
| downstream (871) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT — unchanged | | |

The sweep's exit status is 1 only because `scripts/law_index.py --check` reads the working tree's `src/`, which
carries the new `§` names; the pristine control sweep (run while the scratch law sat in `src/`) printed the same
`law index STALE` line. Every comparison stage read `regressions=0`. A landing regenerates `tests/LAWS.md`.

The targeted clusters (seventh map, `tools/probe/r11u156map`), pristine sweep -> law sweep, measured with the
map's own keying (`drivers/analyze.py` + `drivers/common.py rekey`, [evidence/family_counts.txt](evidence/family_counts.txt)):

| cluster | key | row-modes | objects | probe cases (of 69) |
|---|---|---|---|---|
| N0001 | span ref_obj col+endcol under hier_path | 48 -> 26 | 7226 -> 2535 | 39 -> 14 |
| N0007 | fullname ref_obj golden-empty under hier_path | 32 -> 24 | 5571 -> 483 | 28 -> 11 |
| N0018 | fullname ref_obj ours-empty under hier_path | 25 -> 11 | 1568 -> 46 | 18 -> 2 |
| N0071 | span hier_path endcol under operation | 13 -> 11 | 2401 -> 292 | 16 -> 8 |
| N0097 | span hier_path endcol under assignment | 11 -> 11 | 1384 -> 85 | 17 -> 14 |
| N0098 | file ref_obj ours-empty under hier_path | 11 -> 7 | 4974 -> 42 | 13 -> 1 |
| N0099 | span ref_obj ours-zero under hier_path | 11 -> 0 | 4932 -> 0 | 12 -> 0 |
| N0101 | file ref_obj golden-empty under hier_path | 11 -> 0 | 1465 -> 0 | 7 -> 0 |
| N0102 | span ref_obj golden-zero under hier_path | 11 -> 0 | 1465 -> 0 | 7 -> 0 |

The pristine numbers equal the map's (`cluster_index_p147.csv` objects 7226/5571/1568, probe 39/28/18/...).
No uhdm2rtlil row among them moved away from downstream IDENTICAL (the downstream stage is unchanged row for row).
The family cannot be matched by copying objects golden holds once: no law adds or removes an object; every law
changes a span, a stored full name or a location's presence on an object both databases already hold.

## 2. The decode (questions 1 and 2)

### 2.1 The instrument

`drivers/slpin.sh` runs the PINNED Surelog (`/home/heyfey/git-repos/Surelog/build/bin/surelog`, v1.87 0445655e,
check_probe's arguments) under gdb with two Python scripts:
* `drivers/slmint.py` — a breakpoint on `UHDM::Serializer::Make<T>` for ref_obj / hier_path / bit_select / ...,
  a `FinishBreakpoint` reading the new object's `UhdmId` at `object+24` (RTTI vptr, `serializer_`, `clientData_`,
  `uhdmId_`; UHDM c7562484 `templates/BaseClass.h`) and the caller chain (function names; the binary has symbols,
  no DWARF);
* `drivers/slfull.py` — a breakpoint on every `ref_obj::VpiFullName(std::string_view)` SETTER with the object id,
  the string and the caller.
`drivers/objtab.cpp` then lists every hier_path of the database written under gdb with its elements (UhdmId,
type, name, full name as `vpi_get_str(vpiFullName)` returns it — empty when it equals the name — and span), and the
two traces are joined by id. `drivers/ourpin.sh` + `drivers/ourmint.py` do the same on our `-g1` build
(file:line of the minting frame). `drivers/hpsig.py` reduces each path to a signature
`<base anchor>:<element name kinds>:<element spans>:<element types>` (N = the base carries the NEXT element's span,
O = its own; o = the full name reads empty (stored own name), c = a full name) and joins golden and ours by
(line, col, path name).

### 2.2 What Surelog does (third_party/Surelog/src/DesignCompile/CompileExpression.cpp, v1.87)

**SEL — `CompileHelper::compileSelectExpression`, the hierarchical branch (:1373-1550).** Reached for a
`ps_or_hierarchical_identifier constant_select` (SV3_1aParser.g4 `net_lvalue` :3703, `variable_lvalue` :3709,
`constant_primary` :3565). The base `r1` stores `VpiFullName(name)` and is populated from `Bit_select`, the NEXT
component's node (`fC->populateCoreMembers(Bit_select, Bit_select, r1)`); a bare field (`slStringConst`, :1432)
stores its own name and its own span; a `Ps_or_hierarchical_identifier` / `Select` component (the implicit-handle
lvalue, :1385-1403) stores neither a span nor a name.

**CFC — `CompileHelper::compileComplexFuncCall` (:5478-5731).** Reached for every `expression` primary
(`complex_func_call`, :3598). Every non-leaf component stores its own name (`ref->VpiFullName(tmpName)`, :5533) and
is populated from its own node. The leaf's full name is NEVER set during compilation: the gdb setter trace shows
its only setter call coming from `Serializer::Save` — `BaseClass::VpiFullName()` (UHDM `scripts/classes.py` :73)
computes `ComputeFullName()` (UHDM `templates/BaseClass.cpp` :100, the parent chain with the hier_path's own name
skipped) and caches it at save. So golden's rvalue leaf is "the parent chain at save", which our exporter models
with `joinRef(prefix, name)`.

**Which one, by position (the grammar):**

| position | production | writer | measured |
|---|---|---|---|
| cont/proc assignment target, op-assign target, inc/dec operand | `net_lvalue` / `variable_lvalue` | SEL | g1 c01 c05, c26 |
| parameter value (bare, operand of a constant operator) | `constant_param_expression` -> `constant_primary` | SEL | c10 c11, p07 |
| range / dimension bound | `constant_range` | SEL | c09, p07 r1 |
| part-select bound | `part_select_range: constant_range` (:3553) | SEL | c16, p05, p08, p09 |
| indexed part-select WIDTH / BASE | `indexed_range: expression +: constant_expression` (:3563) | SEL / CFC | p04 |
| size-cast width | `casting_type` (:857) | SEL | expr_width_cast |
| constant `?:` condition, false branch / TRUE branch | `constant_expression ? expression : constant_expression` (:3316) | SEL / CFC | c12 |
| select INDEX (also inside an lvalue) | `bit_select: [expression]` (:3657) | CFC | c07 c08, mem_ff_partial_rsp |
| net_lvalue index (cont-assign target) | `constant_bit_select` | SEL | p03 |
| assignment-pattern member value (also in a parameter) | `assignment_pattern: expression` | CFC | c13, r11u109 f1 grid |
| subroutine argument (also in a parameter, `$clog2`) | `list_of_arguments` | CFC | p02, r11u20 t5 |
| every other expression (RHS, condition, concat, cast operand, named port) | `expression` | CFC | c02 c06 c17 c19-c25 |

Two positions the table does not cover, both decoded with the same instrument:
* a parameter value SUBSTITUTED at a use site keeps the route of the place it was WRITTEN (ClogParam:
  `$clog2(Depth)` in an instance whose `Depth` is `Info.x` keeps the SEL form of `localparam NumScrmblBlocks = Info.x`);
* an ORDERED port connection is re-compiled by `NetlistElaboration::high_conn_` through compileSelectExpression
  (gdb: `compileSelectExpression < compileExpression < high_conn_ < elaborate_`): SEL for an input-port actual
  (c18 `s.a`, OneNetModPort `conntb.drive`, r11v1 vA `u.mp`), CFC for an output one (`conntb.observe`); a NAMED
  connection goes through `compileHighConn` -> compileComplexFuncCall (c17). Not written (section 4, R5).

**`this.` (`compileComplexFuncCall`'s `paImplicit_class_handle` branch, :5209-5217, into compileSelectExpression).**
Three forms (grid g4, g2): RVALUE — the hier_path spans the whole path, `this` anchors at the member token, the
member keeps its own token and its own name (the bare-field branch); LVALUE (assignment / op-assign target, prefix
`++/--`) — the hier_path spans `this`, `this` anchors at the first member token, every member is loc-less with a
computed name (the `Ps_or_hierarchical_identifier` branch); POSTFIX `++/--` — the lvalue members, the hier_path over
the whole path.

**`foreach (a.b[j])` — `CompileHelper::compileVariable` (CompileType.cpp :288-306).** A hier_path with no name and
no location, full name the dotted text; the base at its own token; every later component loc-less; no full name
stored on any element (computed at save).

**`$root.` — compileComplexFuncCall's `paDollar_root_keyword` branch (:5088-5134).** `$root` populated from the next
name node, every element stores its own name (grid r11u82 v3_rootpath).

**The `with`-receiver (`x.y.find_index() with (...)`)** is compileComplexFuncCall's loop: only the LAST receiver
element (the trailing `paSelect` branch) is left unnamed and scoped at save; every earlier one stores its bare
name (r10uvm175 g175_a, r10v175 v175_deep).

**Elaboration.** `hier_path::DeepClone` / `ref_obj::DeepClone` (UHDM `templates/clone_tree.cpp` :895, :100)
copy `*this` — the elaborated view carries the compiled element's stored name and span unchanged (golden
ComplexHierPath: id 121/122/123 `DeepClone < writeCont_assign < writeElabGenScope`, no setter call).

## 3. The grid (question 3)

Cases (all new, `cases/`), goldens from the pinned Surelog with check_probe's arguments, cached by case text
(`drivers/g1.sh`, `GC=` dir):
* `g1/` 26 module contexts x shapes (struct var member `s.a`, struct param member `Cfg.W`, interface-port member
  `sub.adr`/`sub.OFF`, def and elab views);
* `g2/` 15 class contexts (`this.x`, `o.m`, method receivers, `foreach`, `new[]`, randomize);
* `g3/` 13 more positions (instance overrides, `$clog2`/call args in parameters, net-lvalue constant index,
  indexed part-select base/width, nested index/part-select, parameter concat/cast, 3-level unpacked struct
  parameter, interface parameter in ranges, procedural part-select bounds, gen-block plain/indexed/procedural
  targets);
* `g4/` 3 `this.` forms (rvalue positions, lvalue positions incl. op-assign and pre/post inc/dec, mixed).
Plus, read in place (not copied into the deliverable): the 69 probe cases the three clusters carry
(`tests/probe/...`), 15 corpus sources of the target rows, 9 risk controls, 5 port-connection cases.

Per case the evidence holds the golden decode (`golden_decode.txt`: every element with its minting function and
every full-name setter), and the signatures before/after (`hpsig_pristine.txt`, `hpsig_law.txt`,
`verdicts.txt`): [evidence/grids](evidence/grids).

Grid outcome with the law binary (hpsig DIFF paths, pristine -> law): g1 19 -> 7 (left: the def-view TypeEmit
paths of c03 and c14, the ordered port c18 (2), the part-select hier_path NAME `sub.adr[ + 3:]` of c16 (2)); g2
7 -> 2 (k09 `new[bytes.size + 1]`, R8; k15 `this.randomize()`, an object golden does not mint); g3 14 -> 7 (the
def-view gen targets of q01, the missing def-view objects of q02 and q01 line 12, the p06 cast duplicate object); g4 15 -> 2
(`super.bx`, an object we do not mint); the 69 family probe cases 113 -> 47.

## 4. The laws (question 4), all in `src/ExprEmit.cpp`

Every law reads its own switch AND the axis switch of the half it changes; `R11U157_OFF=1` restores pristine
bytes (measured: 0 of 150 grid databases differ from the pristine binary's). Axes: `R11U157_SPAN_OFF` (an anchor
or a span), `R11U157_NAME_OFF` (a stored full name), `R11U157_FILE_OFF` (an element gains or loses its location —
`setLoc` writes VpiFile with the span, so the file rule is the location-presence rule). Per-switch effect:
[evidence/switches.txt](evidence/switches.txt). `R11U157_TRACE=1` prints one stderr line per route decision.

| law | switch | rule | sites |
|---|---|---|---|
| § hpSelRoute157 | R11U157_ROUTE_OFF (SPAN: base anchor, NAME: leaf) | walk the UHDM parent chain at emission: pattern / tagged_pattern / `?:` true branch (`ternTrueArmOps31`) / select index (not a cont-assign target, not a hier_path component) / indexed-part-select base / call argument -> CFC; part_select / range / indexed-part-select width / param_assign / typespec / size-cast width (`inCastSize` under the cast op) -> SEL; else keep the legacy flags. A path whose nearest located non-expression ancestor (ports and instances excepted) does not contain it is a substituted value: keep | buildDottedHierPath, the member-access branch, the interface/hierarchical branch |
| § thisPathFormByPosition157 | R11U157_THIS_OFF (SPAN, NAME, FILE) | the three `this.` forms of 2.2 (rvalue for a single-member path; lvalue for an assignment target and a prefix inc/dec; postfix) and the inc/dec operand of `emitThisPathSelectErased` (`this.aa[s]++`) | member-access branch, emitThisPathSelectErased |
| § foreachArrPathVarForm157 | R11U157_FOREACH_OFF (FILE, NAME) | a member path whose parent is a `foreach_stmt`: no hier_path location, members loc-less, every element scoped | member-access branch |
| § rootPathOwnNames157 | R11U157_ROOT_OFF (SPAN, NAME) | a `$root.` path: SEL anchor and names in every position | buildDottedHierPath |
| § genTgtLhsLeafOwnName157 | R11U157_GENTGT_OFF (SPAN, NAME) | the "module cont-assign LHS into a gen scope" override (raw leaf name, base-only hier_path span) is kept for an INDEXED base only (hierdefparam `bar[0].a`, grid q02); a plain gen-block target (`B.x`, `G.H.y`) is an ordinary net_lvalue | interface/hierarchical branch |
| § withRecvOnlyLastScoped157 | R11U157_WITHRECV_OFF (NAME) | in the `with`-clause receiver only the last element is scoped | method-call receiver builder |

## 5. Measurements (question 4, the gates)

1. Build: pristine md5 0b3b2d0a323c == main tree; law md5 2993cfd94d61; strictcmp 5d4617d0458f.
2. Probe: `regressions=0`, 9 conversions, 23 detail changes, EQUAL 2445 -> 2454, STRICT_NOTEQUAL 1642 -> 1633.
   Conversions: r10uvm84repro/{ast84, g84_a2_parens, g84_e1_positions, v84x2_incdec},
   r10uvm85repro/{g85_a1_builtin, g85_a7_pos, v85x1_kinds}, r10v125repro/v2_faces, r10vbuvm29repro/gv29_a_shapes.
3. Corpora: `regressions=0` both. Conversions (fresh csv rows, [evidence/law_surelog.csv](evidence/law_surelog.csv),
   [evidence/law_uhdm2rtlil.csv](evidence/law_uhdm2rtlil.csv)):
   `LocalScopeHierPath,default,CMP_EQUAL,,,equal`;
   `expr_width_cast,default|testflags,CMP_EQUAL,,,equal`; `mem_ff_partial_rsp,default|testflags,CMP_EQUAL,,,equal`;
   `portsel_struct_param,default|testflags,CMP_EQUAL,,,equal`. The brief's "conversions=0 changes=0" is the
   verifier's criterion for a pass that ships no law; this pass reports its conversions LOUDLY and edits no
   baseline. Detail changes: [evidence/sweep_law_changes.txt](evidence/sweep_law_changes.txt) (every one a
   smaller or equal count on a family row: ComplexHierPath col 10/8 -> 7, InterfaceModPort endcol 17 -> 15,
   SVSwitch endcol 27 -> 12, StructParam* fullname 15 -> 11, iface_* fullname 13 -> 5, ...).
4. Downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, "not identical and not excused=0" —
   identical to the pristine control. Every uhdm2rtlil row of the family (expr_width_cast, iface_scalar_localparam,
   iface_struct_field_partsel, mem_ff_partial_rsp, mem_read_reg, portsel_struct_param, OutputSizeWith...,
   mriscv_bind_sva, ibex_wb_stage) reads IDENTICAL before and after.
5. uhdm-cmp on every mover row: 37 rows, 0 output lines ([evidence/byteverify_P0_vs_law.txt](evidence/byteverify_P0_vs_law.txt)).
6. byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, workdirs /tmp/r11u157_swLC vs /tmp/r11u157_swP0,
   same length): path sets identical (960 + 1608), selfcheck 959/960 and 1607/1608 flagged, MOVERS 25/960 surelog +
   12/1608 uhdm2rtlil; probe databases 34/4087 moved. PREDICTED BY NAME from the pristine databases first:
   `drivers/predict157.cpp` + `drivers/predict_all.py` (fail-closed fence: the four fenced names are read from
   RESUME.md, their rows skipped unread) list 67 corpus rows and 121 probe cases; every mover is among them
   (37/37, 34/34; [evidence/predicted_movers_from_pristine.tsv](evidence/predicted_movers_from_pristine.tsv)).
   Honest note: the predictor's first cut had no size-cast-width branch and missed `expr_width_cast` (2 rows); the branch
   was added (mirroring the law) and the whole prediction re-run from the pristine databases before this count.
   The UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg) are predicted law movers (this/route/
   foreach candidates) and measured as such (SimpleUVM default facets 36627 -> 33327, the family keys collapsing),
   not the UINT/vpiDecompile coin. No fenced row moved.
7. Canaries ([evidence/canaries.txt](evidence/canaries.txt)): u2r ok=16 changed=0; surelog ok=48 changed=4 — the
   4 are InterfaceModPort and SVSwitch both modes, family rows moving toward golden (predicted); ctcan2 PASS
   (EXPECT_UNKNOWN=1 surelog: ok=58 changed=0; EXPECT_UNKNOWN=6 u2r: ok=2 changed=0).
8. Controls kept: the 9 corpus rows the predictor flags that are strict-equal at baseline (ClogParam,
   ClogOfParamOfInstanceInitializedByStructMember, FuncAlias, GenStructAccess, HierPathInterfBlock,
   InterfaceFuncCall, OneThis, func_local_decl_init, gen_struct_access) are byte-identical under the law
   (evidence/grids/rk). Earlier pass laws: every probe case stays EQUAL (0 probe regressions), including the
   r11u118/r11u119 grids.

Ops notes: an intermediate binary (no substitution guard) regressed ClogParam and ClogOf... (the `$clog2(Depth)`
substitution); the guard was added and re-measured. An ordered-port-connection route was tried and reverted: the
leaf name is rewritten afterwards by ModuleEmit (pair B) and the golden rule depends on port direction (R5).

## 6. What is left and why (ranked by objects)

| # | residue | where | size after the law | why not here |
|---|---|---|---|---|
| R1 | def-view generate-scope path: cont-assign LHS inside a gen-if/gen-for block, gen-for bound, gen-if condition — golden SEL, ours CFC form | TypeEmit.cpp `emitSyntaxExpr` (hier_path mint ~:18795, elements ~:19202-19220, called from ModuleEmit.cpp:47784 / :48840) — PAIR B | Rggen 2156+276 objects, Earlgrey_0_1 ~50, ComplexHierPath 6, GenForStructParamBound 4, GenIfIfaceParamStructField 2, probe ps23/tj/v6_ndecl78/w1_memlhs/p13 | the same route rule applies there verbatim (SEL for the assignment target and every constant position of the def-view statement); it is pair B's file |
| R2 | a MIXED path (a component select) in an rvalue: golden anchors the base at the next component (`seed_map.count[type_id]`, `qc.queue[index].used`) | emitMixedHierPath (ExprEmit) and the recv builder | UVM rows ~20-36 objects each | not routed; the element spans around a select need the select branch of compileSelectExpression decoded element by element |
| R3 | the index of a hier_path COMPONENT (`predict_info.addr[rw.addr]`, `iarr[h.idx[i]].f`): trailing bracket = `bit_select [expression]` (CFC), bracket before a dot = `constant_expression` (SEL) | hpRoute157 keeps them | UVM N0018 4-8 per row, probe c2_idxkind, a4_ctx | the position (last component or not) is not visible from the parent chain at emission |
| R4 | a substituted parameter value in a typespec range (`logic [NumScrmblBlocks-1:0]`, Info.x from `localparam NumScrmblBlocks = Info.x`): golden SEL | guard abstains | OutputSizeWith... 3 per mode | the route must come from the WRITTEN position (a parameter value -> SEL); needs the syntax of the parameter declaration at the use site |
| R5 | ordered port connection (SEL for an input actual, CFC for an output one) and the bind named connection's element names (mriscv_bind_sva N0007 20 per mode) | ModuleEmit.cpp emitInstance (the leaf re-scope at ~:17588) — PAIR B | OneNetModPort, mriscv_bind_sva, probe r11v1 vA, r11u1 grid2 | pair B's file; direction-dependent |
| R6 | method-call hier_path spans (N0071/N0097): golden populates the path from the whole `complex_func_call` node (call parens, arguments, `with` clause): `recv_b.randomize()` 11:12-30 vs ours -28, `iq.sum()  with ( item )` one column short, `bc.gn(t.gt())` whole | the method-call builder (~ExprEmit :29400) and memberRandomizeWith119 | UVM 13-43 per row, SimpleConstraint, ArrayMethodIterator, probe g119_b/g151/v116/v119 | a separate writer (the path span, not an element) |
| R7 | macro-expanded paths: element spans in the macro BODY's coordinates in golden (`this.len` in `uvm_report_error`, CovMacro `$root.top` in `$coverage_control`) | setLoc macro mapping | SimpleUVM +40 objects moved from ours-zero to a macro-coordinate span; CovMacro 22 | the macro location law, not the element rule |
| R8 | `new[x.size + 4]`: golden's leaf name is computed from a parent-less operation (reads its own name) | — | SVSwitch 2, probe s4_context/a1_newlhs | golden's broken parent chain; modelling it means modelling the missing parent |
| R9 | `this.h.v` RVALUE (multi-member) and `super.x` | — | g4 | neither side mints a hier_path for `this.h.v`; `super.bx` is an object we do not mint |

## 7. Files

* [law.patch](law.patch) — `git diff 4e20e0d5 -- src` (src/ExprEmit.cpp only).
* `cases/g1..g4/*/dut.sv` — the grid.
* `drivers/` — `g1.sh` (one case: golden + ours + uhdm-cmp + strict dumps), `grid.sh` (a grid, asserts
  PROCESSED == LISTED), `slpin.sh` + `slmint.py` + `slfull.py` (Surelog decode under gdb), `ourpin.sh` +
  `ourmint.py` (our mint sites under gdb), `objtab.cpp`, `hpsig.py`, `gfaces.py`, `diffpins.sh`, `tjobs.py`
  (the family's row/case job list from the seventh map, fail-closed fence), `predict157.cpp` + `predict_all.py`
  (the mover predictor), `redact.py`, and the map's `analyze.py` / `common.py` / `run1.sh` / `jobs.py` /
  `probejobs.py` / `strictcmp_x.cpp` / `cc.sh` / `objrank.cpp` (copied from tools/probe/r11u156map/drivers).
  The C++ tools build like `cc.sh` (the uhdm_strictcmp flags); the drivers expect them in /tmp/r11u157_bin.
* `evidence/` — family_counts.txt, probe_family_counts.txt, byteverify_P0_vs_law.txt, probe_db_movers.txt,
  predicted_movers_from_pristine.tsv, canaries.txt, switches.txt, sweep_P0.log / sweep_LC.log (summaries),
  sweep_law_changes.txt, law_{surelog,uhdm2rtlil,probe}.csv (fenced names redacted), grids/.
