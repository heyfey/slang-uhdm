# r11u178 — the expression/parameter ground: r11u175's three ground-A laws landed (importer-clone body locals copied per listing, reference full names through a named expression, do-while spanning to its closing parenthesis), a non-trailing select index hung off its hier_path, a package pattern parameter read by member inside its own package listed with an unparented reference; 1 row-mode and 18 probe cases converted

Implementer pass (pair A, refill after pass 174 and r11u177). Base `5e8d08d9` (branch matrix-1.87). Ground:
`src/ExprEmit.cpp`, `src/StmtEmit.cpp`, `src/ParamEmit.cpp` (`src/EmitHelpers.h` untouched). No edit to
`TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`, `uhdm_main.cpp`, `include/`, `results/`,
`tests/` (except the regenerated `tests/LAWS.md`) or `third_party/`. r11u175's `law_typeemit.patch` (TaskFuncEmit,
§ externProtoFormalsFromPrototype175) is the sister ground's and is NOT applied; the main tree had not landed it at
the start or at the gate sweep (main tree `5e8d08d9`, then `7fadac8a`, a tools-only map commit that also touches
`tests/LAWS.md`: the landing regenerates it). Net binding is not touched. Every law of passes 140-177 and every
refinement is left as landed; the new laws are new sites under their own switches. Worktree `/tmp/wt_r11u178`,
system-deps config, `-j 2`.

## Binaries (frozen `chmod 555` in `/tmp/r11u178_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `9958104447d83791aab5afe31f796885` | the worktree build of `5e8d08d9`, byte-identical to the main tree's `build/slang-uhdm` |
| `law175.bin` | `0d035c45f09bb824e2ba3745fc8afc29` | `5e8d08d9` + r11u175's `law_exprstmt.patch` ALONE (+ `R11U178_OFF` read by its two switch helpers) |
| `law178.bin` | `73acc5ae02789950d3019c7cb4c4c2a6` | the final patch (`/tmp/r11u178.patch`): the r11u175 laws + the two r11u178 laws |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `predict178`, `idxpar`, `strictcmp_raw` | built by `../r11u175uvm/drivers/cc175.sh` | `drivers/predict178.cpp` (mover predictor), `drivers/idxpar.cpp` (index parents), `drivers/strictcmp_raw.cpp` (the comparator printing raw full names; measurement only) |

Every sweep's `cmds.txt` names its own binary on all 3273 `slang:` lines: `/tmp/r11u178_swP` pris.bin 3273/3273,
`/tmp/r11u178_swL` law175.bin 3273/3273, `/tmp/r11u178_swM` law178.bin 3273/3273 (same-length workdir names).

**The fence.** No fenced test is named in this directory (0 files match the four names by word boundary). The
gate sweeps dispatched every row as the gate mandates; nothing else touched a fenced source or database:
`drivers/env.sh` reads the four names from `tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and refuses to run
without four; `drivers/predict178.sh` lists 6647 databases with the 8 fenced row-mode databases excluded by word
boundary (`fenced_excluded 8`); `drivers/bvmirror.sh` hard-links 2560 corpus databases leaving the 8 fenced ones out
(`fenced_skipped=8`); `drivers/rowrec.sh` refuses a fenced name; the filtered corpus runs (`verify_golden.py
--filter`) named only non-fenced tests (checked against `$FENCED` before dispatch); the downstream database
comparison skipped fenced names. No gdb run.

## Result

| axis | base (committed = pristine sweep) | law (law178.bin) | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL, default + testflags) | 450 + 446 | 450 + **447** | **+1** (LocalScopeHierPath testflags) |
| uhdm2rtlil strict-equal (of 1606) | 783 + 783 | 783 + 783 | 0 (iface_zero_width_field d/t: fullname(4) -> fullname(3)) |
| probe EQUAL (of 4087) | 2796 | **2814** | **+18** |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | `downstream.csv` byte-identical to the pristine sweep's |

Gate verdicts of `tests/sweep.sh --jobs 3` against the committed baselines (`evidence/sweep_*.log`):

| sweep | probe (reg / conv / changes) | surelog | uhdm2rtlil | downstream |
|---|---|---|---|---|
| swP pristine | 0 / 0 / 0, EQUAL 2796 / STRICT_NOTEQUAL 1291 | 0 / 0 / 0 | 0 / 0 / 0 | 803 / 66 / 2 / 0, not excused 0 |
| swL law175 (r11u175 alone) | 0 / **17** / 58, EQUAL 2813 | 0 / 0 / **11** | 0 / 0 / 0 | csv byte-identical to swP's |
| swM law178 (this patch) | 0 / **18** / 64, EQUAL 2814 | 0 / **1** / **11** | 0 / 0 / **2** | csv byte-identical to swP's |

Every sweep also prints `law index STALE` (a clean `5e8d08d9` checkout reads STALE too: `python3
scripts/law_index.py --check`, measured in the worktree before any edit); the regenerated `tests/LAWS.md` in this
patch clears it.

**CONVERSION (corpus; results/ untouched).** The fresh row of the law sweep (`/tmp/r11u178_swM/surelog.csv`):

    LocalScopeHierPath,testflags,CMP_EQUAL,,,equal          was differ:fullname(1)   § hierPathSelIdxAtPath178

The head it clears (pristine, `--elabuhdm`): `#101 ref_obj j` golden
`pack::uvm_mem_mam::check_reg::path.slices[j].spath::j`, ours `pack::uvm_mem_mam::check_reg::j`. Not a downstream
row.

**CHANGES (corpus: 13 row-modes, all attributed by the two sweeps: swL holds the r11u175 laws alone).**

| row-mode | before -> after | law |
|---|---|---|
| BuildUVMPkg d/t | line(94) -> line(69) | r11u175 (ESPAN + FULLNAME; identical in swL) |
| MiniAmiq d/t | file(29) -> file(26) | r11u175 (MULT + FULLNAME + ESPAN; identical in swL) |
| SeqDriver d/t | file(29) -> file(26) | r11u175 (the same) |
| SimpleUVM d/t | fullname(45) -> fullname(42) | r11u175 (FULLNAME + ESPAN) |
| Scoreboard d | fullname(45) -> fullname(42) | r11u175 (the same; testflags SLANG_REJECT unchanged) |
| SVSwitch d/t | fullname(11) -> file(9) | § refFullNameThroughNamedExpr175 (the `pkt.byte_pack::bytes` call argument, #101) |
| iface_zero_width_field d/t (uhdm2rtlil) | fullname(4) -> fullname(3) | § pkgPatUnqualReadTsNoParent178 (swL reads fullname(4)) |

The UVM rows' first records (`evidence/law175/uvm_first_records.txt`): the first two records are unchanged on every
row (MiniAmiq/SeqDriver `#573`/`#556 enum_typespec uvm_pkg::uvm_check_e` file, the F3 relocation; SimpleUVM/Scoreboard
`#458`/`#466 ref_typespec UVM_MACRO_NUMFLAGS`; BuildUVMPkg `#873 struct_typespec m_uvm_factory_type_pair_t` line);
the walk-diverged totals shrink (MiniAmiq objects 413982 -> 428712 of golden's 435559, SeqDriver 462179 -> 471999
of 475526; the fullname field count 5 -> 2 on both; BuildUVMPkg objects_differing 94 -> 69; SimpleUVM and
Scoreboard 45 -> 42); SVSwitch's first record `#101 ref_obj bytes` (golden
`work@Driver::start::pkt.byte_pack::bytes`) is gone, its head is now `#184 class_typespec Receiver` file (TypeEmit's).

**Probe: 18 conversions, 64 changes, 0 regressions.** Every one of the 82 lines moves TOWARD golden order-blind
except one SAME (`evidence/probe_movers_orderblind.tsv`: CONVERSION TOWARD 18, CHANGE TOWARD 63, CHANGE SAME 1). The
SAME one is `r11u60repro/g7` fullname(2) -> fullname(1): the record `#158 ref_typespec` (golden unnamed, ours `p7`)
is fixed by § pkgPatUnqualReadTsNoParent178 and the multiset distance stays 2 because the other differing record
(`#465`, golden `work@g7top.u_q`, ours unnamed) holds the same two values. r11u175's laws alone (swL) own 17
conversions and 58 changes (all TOWARD, `evidence/law175/probe_movers_orderblind_law175.tsv`); the r11u178 laws add
one conversion and six changes, each attributed by switch (`evidence/probe_law178_attribution.txt`):

| case | pristine = law175 | law178 | the switch that alone restores it |
|---|---|---|---|
| r11u49repro/a7 | fullname(1) | **EQUAL** | `R11U178_PATUNQUAL_OFF` |
| r11u26repro/m12 | fullname(6) | line(5) | `R11U178_PATUNQUAL_OFF` |
| r11u60repro/g4 | fullname(3) | fullname(2) | `R11U178_PATUNQUAL_OFF` |
| r11u60repro/g7 | fullname(2) | fullname(1) | `R11U178_PATUNQUAL_OFF` |
| r11u61repro/h1 | fullname(4) | fullname(3) | `R11U178_PATUNQUAL_OFF` |
| r10uvm143repro/g143_c_index | endcol(23) | endcol(20) | `R11U178_MIDIDX_OFF` or `R11U178_MIDIDXNAME_OFF` (the name half) |
| r10uvm79repro/c2_idxkind | file(10) | file(9) | `R11U178_MIDIDX_OFF` or `R11U178_MIDIDXNAME_OFF` |

## 1. r11u175's law_exprstmt.patch, landed (measured alone first)

The patch (`tools/probe/r11u175uvm/law_exprstmt.patch`, written against `e3f14d0a`) applied clean on `5e8d08d9`
(one hunk offset by 707 lines in ParamEmit.cpp: passes 174 and 177 grew the file, no conflict). The only edit made
on top: each of its two switch helpers (`r11u175LawA` in StmtEmit.cpp, `r11u175LawE` in ExprEmit.cpp) also reads
`R11U178_OFF`, so the pass switch restores pristine bytes. The laws keep their own switches:

- **§ importCloneBodyLocalCopies175** (`R11U175_MULT_OFF`; StmtEmit.cpp + the design-final hook
  `drainImportCloneLocalCopies175` at the head of `drainPaNameCopySrc38` in ParamEmit.cpp). A wildcard importer's
  listing is Surelog's `clone_tree` of the home function, which copies each LIST separately: the wrapper begin's
  Variables and each declaration assignment's Lhs take their own copies (an array's element variable first), made
  with UHDM's `clone_tree` design-final. Cases (the evidence of r11u175): `tools/probe/r11u175uvm/cases/f2/*`
  (§ importCloneBodyLocalCopies175).
- **§ refFullNameThroughNamedExpr175** (`R11U175_FULLNAME_OFF`; ExprEmit.cpp + the same hook). Inside a
  subroutine, a formal's default reference (read through its io_decl), a call argument when the call is its
  hier_path's last element, and a select index when the select is the last element take UHDM's chain name. Cases:
  `tools/probe/r11u175uvm/cases/f5/*` (§ refFullNameThroughNamedExpr175).
- **§ doWhileSpansToCloseParen175** (`R11U175_ESPAN_OFF`; StmtEmit.cpp). do_while spans from `do` to the
  condition's closing parenthesis (same buffer only). Cases: `tools/probe/r11u175uvm/cases/f7/*`
  (§ doWhileSpansToCloseParen175).

Its grid re-run under law178 (`evidence/law175/grid175_under_law178.txt`, default mode, goldens rebuilt):
f5 e01/e02/e03/e05 and f7 d1-d5 convert; f2 g06 moves type(1) -> line(1) (it converts only with the sister's F4 law,
as r11u175 measured); every f2 control (c01, g01, g04, g07, h01-h05) stays STRICT_EQUAL; nothing regresses.

Measured alone (swL): probe +17 conversions, 58 changes; surelog 11 changes (above); uhdm2rtlil 0; downstream csv
identical. Byte movers of swL: corpus 11 / 2560 (`evidence/byteverify_corpus_law175.txt`: BuildUVMPkg, MiniAmiq,
SeqDriver, SimpleUVM, SVSwitch both modes, Scoreboard default), exactly the 11 predicted for these three laws;
probe 81 movers, all predicted (86 predicted; the 5 extra are the predictor's over-approximation).

## 2. § hierPathSelIdxAtPath178 (ExprEmit.cpp) — a non-trailing select's index hangs off the hier_path

**Head (LocalScopeHierPath testflags).** `path.slices[j].spath` read inside a class method (`-elabuhdm`):

    #101 fullname  A: ref_obj j  pack::uvm_mem_mam::check_reg::path.slices[j].spath::j   dut.sv 19:31-19:32
                   B: ref_obj j  pack::uvm_mem_mam::check_reg::j

**Decode.** In the definition view golden parents the index `j` of the MIDDLE select at the hier_path, not at
its bit_select (`drivers/idxpar.cpp` on golden: `par=hier_path`; ours `par=bit_select`). The name ours stores
(`...::check_reg::j`) equals what UHDM's `ComputeFullName` gives through that parent (a reference directly under a
hier_path skips the path), so the definition view reads the same either way; the difference surfaces under
`-elabuhdm`: the ElaboratorListener clones the definition's processes, `hier_path::DeepClone` gives the clone its own
bit_select, and a clone whose full name was never stored recomputes it through its new parent chain (through the
path: `...::path.slices[j].spath::j`). § elabCloneFullNameUnstored137 (uhdm_main.cpp, the sister ground, unchanged)
already unstores a name equal to its own chain before the listener runs; with the index parented at the path, ours's
stored name IS its chain, so it is unstored and the clone reads golden's name.

**Grid** (`cases/hp`, 22 cases x both modes, goldens from the pinned Surelog with and without `-elabuhdm`; every
index parent compared with `drivers/idxpar.cpp`): golden hangs the index of EVERY non-trailing select at the path,
whatever its kind (`ref_obj`, `operation` `m.w[k + 1].v`, `func_call` `m.w[f(k)].v`, `hier_path` `m.w[s.k].v`,
`sys_func_call` `m.w[$clog2(k)].v`, `part_select`), in every context (module initial m01, continuous assignment m02,
generate scope m03, package function m04, class method m05/h01/h06/h08, module task m06, module function h04, a
path inside a plain select's index `arr[m.w[k].v]` h10); a base select's non-reference index too, lvalue or not
(m11 `a[k + 1].v`, `a[f(k)].v`; m12 the same as lvalues). The TRAILING select keeps its bit_select (h02, m01
`m.w[k].x[j]`'s `j`), a constant index stays unparented (m01 `m.w[2].v`), and an LVALUE member select keeps its
bit_select with the path name (m06 line 9, m08 `m.w[k].v = 2`: ours already right). One exception measured: a path
NESTED in another path's select index (`m.w[n.w[k].v + 1].v`, h09; h10 line 15) keeps the inner index at its
bit_select, named through both paths (golden `work@top.m.w[ + 1].v.n.w[k].v.k`).

**Law.** SITE 2 (the member select, next to § hpMidSelIdxAtPath79's post-pass): a non-trailing rvalue member
select's index of any kind but a constant is reparented at the path; SITE 1 (the base select): a non-trailing base
select's non-reference, non-constant index likewise (the reference case is already there). A path nested in
another path's index is left alone (its reference index is only named, below). Switch `R11U178_MIDIDX_OFF`.
**The name half** (`R11U178_MIDIDXNAME_OFF`, design-final in `drainHierPathSelIdx178`, called from
`drainPaNameCopySrc38`): a reference inside a reparented operation or call index takes the chain name (golden
`work@top.m.w[k + 1].v.k`, `work@top.a[].v.k`, ours `work@top.k`), and a nested path's reference index takes its
chain name through both paths; only where ours's stored name is the chain name with ancestors dropped (same root,
same leaf).

**Grid result** (`evidence/grid_switch_matrix.txt`): converts h01.elab, h04.elab, h05.elab, m02.elab, m03 (default:
the generate-scope index ours named through the path because its name was unstored), m03.elab, m06.elab (7
case-modes, each restored by `R11U178_MIDIDX_OFF`); h08 (default and elab) fullname -> endcol (the name half: an
operation index's reference; `R11U178_MIDIDXNAME_OFF` restores fullname); index parents equal golden's on every
case but m10 (an interface-port path ours emits differently, stage 1 before and after) and the nested-path element
faces of h09 (residue R1). Controls unchanged: h02, h03, c03, m07's other faces, every stage-1 case.

**Corpus:** LocalScopeHierPath testflags converts; byte movers without a verdict change (strict-equal before and
after, or the verdict unchanged): BitSelectExpr d/t, Earlgrey_0_1 d/t, LocalScopeHierPath d, the UVM rows (MiniAmiq,
SeqDriver, SimpleUVM both modes, Scoreboard d, BuildUVMPkg both modes), and in uhdm2rtlil ExpressionInIndex d/t,
packed_struct_array_shift d/t; their downstream rows (ExpressionInIndex, packed_struct_array_shift) stay IDENTICAL
(fresh rows `ExpressionInIndex,IDENTICAL,OK,OK,64,64,,` and `packed_struct_array_shift,IDENTICAL,OK,OK,54,54,,`).

## 3. § pkgPatUnqualReadTsNoParent178 (ParamEmit.cpp) — a member read inside the package unparents the listing's reference

**Head (iface_zero_width_field d/t, fullname(4)).** `localparam bus_t B = '{CTL:0, DAT:8, STS:0}` and, in the same
package, `logic [B.CTL-1:0] ctl`:

    #105 fullname  A: 4 ref_typespec (unnamed)   B: 4 ref_typespec p       (the elaborated package listing's pattern)

**Decode.** § pkgPatReadTsNoParent131's producer road (CompileHelper::getValue writes the expanded pattern back to
the package param_assign; ExprEval::flattenPatternAssignments mints its reference with no parent) is reached through
the COMPONENT branch of getValue too (CompileExpression.cpp, the `component->getParam_assigns()` loop after the
qualified-name branch): an UNQUALIFIED member read reduced inside the package. Grid `cases/pz` (12 cases): a typedef
range (z01 unpacked, z02 packed), a localparam value (z04 `W = B.D`), a typedef width (z07), a function body (z09
`return B.D`) all give golden's flattened elaborated listing an unnamed reference; ours already flattened each of
them but kept the parent. Bounds: no read (z03) keeps both listings tagged; a whole-value read (`C = B`, z08) and
`$bits(B)` (z10) keep the tagged listing in golden (ours too); a POSITIONAL pattern `'{2, 8}` (z12) keeps the parent
(flattened, nothing to mint); a read through an import from ANOTHER package (z11) leaves golden's home listing
tagged while ours flattens it (residue R4, stage 1 before and after).

**Law.** The 131 law's read set also holds a parameter that its own package reads by member without a qualifier
(`B.x` spelled as a dot ScopedName inside the PackageDeclaration), when the written pattern names its members
(StructuredAssignmentPattern) and ours's elaborated listing is flattened (no tagged_pattern operand): the listing's
operation takes a fresh, unparented reference exactly as 131 does. Switch `R11U178_PATUNQUAL_OFF`.

**Grid result** (`evidence/grid_pz_counts.txt`): one object fewer on every firing case (z01 fullname 3 -> 2, z02
2 -> 1, z04 4 -> 3, z07 3 -> 2, both modes; z09 elab 5 -> 4), each restored by `R11U178_PATUNQUAL_OFF`; the
remaining records are the members of the struct under that reference (residue R3). Corpus: iface_zero_width_field
d/t fullname(4) -> fullname(3) (its downstream row stays `iface_zero_width_field,IDENTICAL,NO_GATES,NO_GATES,0,0,,`);
BlackBePipeInt d/t move bytes with their verdicts unchanged. Probe: r11u49repro/a7 converts, four changes (table
above).

## 4. Switches

| switch | law |
|---|---|
| `R11U175_MULT_OFF` | § importCloneBodyLocalCopies175 |
| `R11U175_FULLNAME_OFF` | § refFullNameThroughNamedExpr175 |
| `R11U175_ESPAN_OFF` | § doWhileSpansToCloseParen175 |
| `R11U175_OFF` | the three r11u175 laws |
| `R11U178_MIDIDX_OFF` | § hierPathSelIdxAtPath178 (the reparent; the name half has nothing to name without it) |
| `R11U178_MIDIDXNAME_OFF` | § hierPathSelIdxAtPath178's name half |
| `R11U178_PATUNQUAL_OFF` | § pkgPatUnqualReadTsNoParent178 |
| `R11U178_OFF` | everything this patch adds (the r11u175 laws included) |

`R11U178_OFF=1` on law178.bin writes the pristine bytes: 74 of 74 case-modes of `cases/` (`drivers/caseoff.sh`), 120
of 120 predicted probe databases (`drivers/offbytes.sh`), and on the 25 corpus byte movers 19 identical plus the six
UVM databases (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d, Scoreboard d) that differ from the pristine SWEEP's copy in
the known order coin (see section 5). `R11U175_OFF=1 R11U178_MIDIDX_OFF=1 R11U178_MIDIDXNAME_OFF=1
R11U178_PATUNQUAL_OFF=1` gives the same 120 of 120.

## 5. Byte movers, predicted by name first

`drivers/predict178.cpp` (r11u175's predictor minus its TaskFuncEmit law, MULT widened to every declaration inside
a clone body, plus MIDIDX and PATUNQUAL, each over-approximating) read every PRISTINE database of swP (6647 listed,
8 fenced excluded) before the law178 sweep ran and named 149 databases (`evidence/predict_pristine_hits.txt`).
MIDIDX: a hier_path whose non-trailing bit_select holds a non-constant index parented at that bit_select (a base
select's reference excluded); PATUNQUAL: a package param_assign whose pattern operation is flattened and whose
reference is parented.

- **Corpus** (`byteverify.sh`, SELFCHECK=1 2559 / 2560 flagged, path sets identical, on fence-free mirrors):
  **25 / 2560 movers, all 25 predicted** (`evidence/byteverify_corpus_law178.txt`); 4 predicted did not move
  (CarryAdd t and GenScopeHierPath3 t: the listener's own clones already at their bit_select; StructOfArrayOfStructs
  d/t). No verdict moves on BitSelectExpr, Earlgrey_0_1, BlackBePipeInt, LocalScopeHierPath d, ExpressionInIndex,
  packed_struct_array_shift. The six UVM databases re-exported under `R11U178_OFF` differ from the pristine sweep's
  copies in the documented UVM order coin (MiniAmiq/SeqDriver/SimpleUVM/Scoreboard, a 0-or-4-line
  UINT/vpiDecompile order flip; `evidence/uvm_offswitch_coin.txt` gives the dump and order-blind line counts).
- **Probe:** 92 movers, **all predicted** (120 predicted; 28 over-approximated: PATUNQUAL 20, MULT 4, MIDIDX 3,
  ESPAN 1); `evidence/probe_movers_law178.txt`.
- **Downstream slang lane:** 805 databases compared, 3 movers (ExpressionInIndex, iface_zero_width_field,
  packed_struct_array_shift), each predicted in its uhdm2rtlil row; every downstream verdict unchanged.

Canaries (`evidence/canaries.txt`): `canaries.sh` surelog ok=43 changed=9 (exactly the nine claimed canary rows:
SVSwitch d/t, SimpleUVM d/t, SeqDriver d/t, BuildUVMPkg d/t, Scoreboard d; pristine ok=52 changed=0), uhdm2rtlil
ok=16 changed=0; `ctcan2.sh` surelog PASS (EXPECT_UNKNOWN=1), uhdm2rtlil PASS (EXPECT_UNKNOWN=6), on both sweeps.

## 6. Residues, ranked

R1. **A path nested in another path's select index** (h09 `m.w[n.w[k].v + 1].v`): golden compiles the inner path
through another branch: its bit_select is named through the outer path (`work@top.m.w[ + 1].v.n.w[k].v.w`, ours
`n.w[k]`) and spans to its index, its base reference starts at the member (col 21, ours 19), the trailing member
reference is unnamed. ExprEmit.cpp, the hier_path builder (the index emission of § hpMidSelIdxAtPath79's sites).

R2. **A call as a select index spans its name** inside a hier_path (`m.w[f(k)].v`, `path.slices[g(j)].spath`:
golden 11:14-15, ours the whole call 11:14-18; `cases/cs` c01 c02, `hp/m07`, `hp/h08`), while an LVALUE plain
bit_select index spans the whole call (`arr[f(k)] = 1`: golden 17:9-13, ours the name) and a class method's
`arr[g(k)]` bit_select ends at its `]` (golden 9:14-23, ours 9:14-20). ExprEmit.cpp (call spans), not decoded.

R3. **The struct members under the unparented reference** (iface_zero_width_field fullname(3), `pz` z01/z02/z04/z07):
`drivers/strictcmp_raw.cpp` shows ours's reference reaches the struct copy listed under the parameter (raw
`p::B.p::cfg_t.A`) where golden's reaches the one whose members read `work@top.p::cfg_t.A`, so the comparator's
use-site test does not excuse them: the typespec identity face. Site: ParamEmit.cpp § pkgPatReadTsNoParent131's
fresh reference (`nrt->Actual_typespec(rt->Actual_typespec())`), shared by 131 and this law.

R4. **A package pattern parameter read by member from ANOTHER package through an import** (z11): golden leaves the
home listing tagged; ours flattens it (stage 1 before and after).

R5. **The module-side import copy of a flattened package pattern** (r11u60repro/g7 `#465`): golden names its
reference `work@g7top.u_q`, ours leaves it unnamed.

R6. Scr1SvTests d/t `type(1)` at `#16033`: golden hangs a `ref_typespec` (the called function's formal typespec,
`logic [1:0]` at 90:13-26) on the call argument `din[(i+1)*2-1-:2]` (an indexed_part_select), ours none. Surelog's
`CompileHelper::compileTfCallArguments` does not set it; the producer site was not found this pass (not decoded).

R7. The brief's other ground-A residues were not worked this pass; their cells at NEWHEAD (the pristine sweep):
FuncStructValSimple d/t file(40)/file(60); FuncStructVal endcol(95)/(177); StructParamPatternInitCast d/t fullname(3)
(its `#414 ref_typespec` golden unnamed, ours `work@StructParamPatternInitCast`: the module-listing twin of R3/R5);
InterfArrayBind d fullname(3) (`io_gen[0].peripheral_io_bus[io_idx].write_en.io_idx`: a FIRST-element index in an
elaborated generate scope read through the path, ModuleEmit's elaborated-view flag); UnsizedParam d fullname(2);
YosysRiscv d/t col(40); CovMacro d/t fullname(8); ibex_pmp d/t file(15); ibex_multdiv_fast d/t file(11);
jeras_union d/t fullname(75); const_cast_signext d/t line(5); PreprocTest d/t endcol(2); MiniAmiq/SeqDriver file(26)
and SimpleUVM/Scoreboard fullname(42) and BuildUVMPkg line(69) after the r11u175 laws (their heads are the F3
relocation and the UVM macro reference names, the sister ground's per r11u175).

**Sister-ground faces.** None of this patch's laws needs a TypeEmit/ModuleEmit/UhdmExporter/TaskFuncEmit/uhdm_main
edit. The LocalScopeHierPath conversion relies on § elabCloneFullNameUnstored137 (uhdm_main.cpp, the r11u137 law,
unchanged): a refinement that stops it unstoring a reference equal to its own chain would undo it. The F4 law
(§ externProtoFormalsFromPrototype175, r11u175's `law_typeemit.patch`, TaskFuncEmit.cpp) remains the sister's to land;
r11u175's f2 g06 and the ApbSlave movement wait for it.

## 7. Files

- `cases/hp/*/dut.sv` (§ hierPathSelIdxAtPath178; h01-h10, m01-m12), `cases/cs/*/dut.sv` (§ hierPathSelIdxAtPath178's
  call-index span residue R2: c01-c03), `cases/pz/*/dut.sv` (§ pkgPatUnqualReadTsNoParent178: z01-z12). Every case
  names its law in its first line.
- `drivers/`: `env.sh` (pins, `$FENCED` from canaudit.sh), `grid.sh` (golden + ours + uhdm-cmp + strictcmp per case;
  `ELAB=1` for `-elabuhdm` / `--elabuhdm`), `gridmatrix.sh` (the switch matrix), `caseoff.sh` and `offbytes.sh`
  (switch-off byte checks), `predict178.cpp` / `predict178.sh` (mover predictor), `idxpar.cpp` (index parents),
  `strictcmp_raw.cpp` (raw full names in records), `rowrec.sh` (a row-mode's strict records, fence-refusing),
  `bvmirror.sh` (fence-free byte-verify mirrors), `obprobe.py` / `obrows.sh` (order-blind direction; copies of
  r11u175's).
- `evidence/`: the three sweep logs, the byte-verify outputs, predictions, probe movers and their directions, the
  switch matrix and the pattern counts, the canaries, the r11u175 grid and UVM first records under `law175/`.
