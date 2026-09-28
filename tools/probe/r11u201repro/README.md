# r11u201 — the expression/parameter ground: the r11u200 decode's ground-A laws landed (§ newArrayArgPathElemsStripped200, § unitBoundFoldAtLeftOperand200, § genBlockBitsKeepsSelect200) with one refinement (§ newArrayPathStripTrailOnly201v), the evaluator's argument stamp modelled for system-call and operator contexts (§ sysCtxRefArgBare201, § opCtxRefArgBare201, § nonReduceOpArgBare201), method-call and select-index call arguments named by the reader's chain (§ methodArgNestedRefChain201, § callArgInSelIdxChainName201), a class-scoped part-select bound spanning the whole name (§ clsScopedBoundWholeSpan201); 4 probe cases converted, 13 corpus row-modes closer, 0 regressions

**Base.** `ddc67d87` (branch matrix-1.87: pass 198, pass 196 and the r11u200 decode landed). Worktree `/tmp/wt_r11u201`,
system-deps config. Ground A only: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`, `src/EmitHelpers.h` (the switch and trace
helpers). No `StmtEmit.cpp` change was needed. No file of the sister's ground (TypeEmit, ModuleEmit, UhdmExporter,
TaskFuncEmit, uhdm_main) is touched; nothing under `results/`, `tests/` (but the regenerated `tests/LAWS.md`) or
`third_party/` is edited.

**The fence.** `drivers/env.sh` reads the four names from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` in the main repository (resolved through git's common dir, never from a
worktree) and every driver here fails closed on it: `case.sh`, `judge.sh`, `grid.sh`, `rowhead.sh`, `obrow.sh`,
`det.sh`, `detob.sh`, `uvmdist.sh` refuse a fenced name; `census.sh` runs the corpora and the downstream lanes with a
`--filter` built from the fence; `bvmirror.sh` leaves the 8 fenced row-mode databases out of every byte comparison
(`fenced_skipped=8`); the byte-control list was checked against the fence (0 hits). No fenced row is
`STRICT_NOTEQUAL` at the base (checked by count, without printing a name). The gate sweeps dispatched every row; their
csv verdicts are the only fenced facts cited (all unchanged). A grep of this directory for the four names reads 0.

## 0. Verdicts

No corpus row-mode converts: map 11 found that no remaining row ends on ground A alone, and every row this pass
moves still needs ground B (section 7). Every targeted row-mode moves toward golden and none worsens:

| row-mode | base (`ddc67d87`) | after | laws |
|---|---|---|---|
| MiniAmiq d / t | `differ:file(17)` | `differ:file(4)` | § methodArgNestedRefChain201, § sysCtxRefArgBare201, § newArrayArgPathElemsStripped200 |
| SeqDriver d / t | `differ:fullname(16)` | `differ:endcol(3)` | § methodArgNestedRefChain201, § sysCtxRefArgBare201 |
| SimpleUVM d / t | `differ:fullname(44)` | `differ:fullname(31)` | the same two |
| Scoreboard d | `differ:fullname(44)` | `differ:fullname(31)` | the same two |
| BuildUVMPkg d / t | `differ:line(11)` | `differ:line(5)` | the same two |
| SVSwitch d / t | `differ:fullname(13)` | `differ:endline(11)` | § newArrayArgPathElemsStripped200 (the A half; the row converts with r11u200's B half: section 7) |
| Scr1SvTests d / t | `differ:endcol(29)` | `differ:endcol(19)` | § unitBoundFoldAtLeftOperand200 (A half; B half: section 7) |
| **probe r10svs2repro/s4_context** | `differ:fullname(1)` | **`EQUAL`** | § newArrayArgPathElemsStripped200 |
| **probe r10svs3repro/a1_newlhs** | `differ:fullname(2)` | **`EQUAL`** | § newArrayArgPathElemsStripped200 |
| **probe r10uvm60repro/v2_class** | `differ:fullname(2)` | **`EQUAL`** | § methodArgNestedRefChain201 |
| **probe v11u112repro/grid/brk/t/b2c_iface_fn** | `differ:fullname(2)` | **`EQUAL`** | § methodArgNestedRefChain201 |
| probe r10uvm193repro/g193_c_argface | `differ:fullname(102)` | `differ:fullname(94)` | § methodArgNestedRefChain201 (8 records) |

The fresh rows of the law sweep (`/tmp/r11u201_sw7`, NOT written to `results/`):

    MiniAmiq,default,STRICT_NOTEQUAL,differ:file(4),,differ:file(4)
    SeqDriver,default,STRICT_NOTEQUAL,differ:endcol(3),,differ:endcol(3)
    SimpleUVM,default,STRICT_NOTEQUAL,differ:fullname(31),,differ:fullname(31)
    Scoreboard,default,STRICT_NOTEQUAL,differ:fullname(31),,differ:fullname(31)
    BuildUVMPkg,default,STRICT_NOTEQUAL,differ:line(5),,differ:line(5)
    SVSwitch,default,STRICT_NOTEQUAL,differ:endline(11),,differ:endline(11)
    Scr1SvTests,default,STRICT_NOTEQUAL,differ:endcol(19),,differ:endcol(19)
    r10svs2repro/s4_context,EQUAL,,equal          (probe.csv; likewise a1_newlhs, v2_class, b2c_iface_fn)

(testflags rows read the same cells.) The order-blind distance to golden falls on every UVM row (section 6).

Totals of the law sweep against the committed baselines: **probe `regressions=0 conversions=4 changes=1`; surelog
`regressions=0 conversions=0 changes=13`; uhdm2rtlil `regressions=0 conversions=0 changes=0`; downstream 803
IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, `downstream.csv` byte-identical to the pristine sweep's.**
13 of 2560 corpus databases, 5 of 4087 probe databases and 0 of 805 downstream-lane databases move, every one
predicted by name by the frozen firing census (section 5).

The pass's own grids and the earlier passes' evidence grids (the byte controls, section 4): 48 law cases here (+ 6 decode-only shapes), parse form
**33 converted to EQUAL, 0 worse**, `-elabuhdm` form 26 converted, 0 worse; `R11U201_OFF=1 R11U200_OFF=1` writes the
pristine bytes on all of them in both forms; of 1370 earlier-pass cases 18 move, 15 convert to EQUAL, 3 stay
judge-unequal but closer, **0 worse**.

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u201_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `18183f058868a85659208c85a099980e` | the worktree at `ddc67d87`: byte-identical to the main tree's `build/slang-uhdm` |
| `law200.bin` | `ce1ab244baa42558bd167edc1fc22b24` | `ddc67d87` + `tools/probe/r11u200dec/law_exprstmt.patch` alone (question 0) |
| `law.bin` (= `law6.bin`) | `2ff0e73d1fbc5e8facf196bab8f5be47` | all laws; ran the firing census, the first law sweep `/tmp/r11u201_swL` and the grids |
| **`law7.bin`** | **`a86ce8281a1d3fdd65a6a7fc0e2589bb`** | **THE DELIVERED SOURCES**: `law6` with the three argument-stamp laws' contexts made disjoint so each switch alone restores its own context (identical behaviour with no switch set: section 4); ran the final law sweep `/tmp/r11u201_sw7`, the byte controls, the switch checks and the determinism runs |
| `law1` .. `law5` | | development steps (law2/law3 read the Q/q03 and Z -elabuhdm breaks fixed in section 3) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, `SLANG_UHDM` exported, same-length workdirs): `/tmp/r11u201_swP`
(pristine), `/tmp/r11u201_swL` (law6), `/tmp/r11u201_sw7` (law7). `cmds.txt` audit: swP 3273 of 3273 `slang:` lines
name `/tmp/r11u201_bin/pris.bin`, sw7 3273 of 3273 `/tmp/r11u201_bin/law7.bin`. The pristine sweep reproduces the
baselines exactly: `probe.csv` byte-identical to `results/golden_probe.csv` (EQUAL 3345 / STRICT_NOTEQUAL 742),
surelog and uhdm2rtlil `regressions=0 conversions=0 changes=0`, downstream 803 / 66 / 2 / 0. Every sweep exits 1 for
one reason only, `law index STALE: tests/LAWS.md` (the worktree's sources and READMEs were edited); the patch carries
the regenerated file.

## 2. Switches (every law droppable alone; `R11U201_OFF` drops this pass's laws, `R11U200_OFF` the r11u200 ones)

| switch | law | file | grid |
|---|---|---|---|
| `R11U200_NEWARRHP_OFF` | § newArrayArgPathElemsStripped200 (r11u200, landed here) | ExprEmit.cpp | cases/Z z01 z02 |
| `R11U201_NEWARRLAST_OFF` | § newArrayPathStripTrailOnly201v (refines the law above) | ExprEmit.cpp | cases/Z z01 z02 `-elabuhdm` |
| `R11U200_UNITFOLD_OFF` | § unitBoundFoldAtLeftOperand200, the `$unit` bound (r11u200) | ParamEmit.cpp | cases/Z z03 |
| `R11U200_FOLDDEPTH_OFF` | § unitBoundFoldAtLeftOperand200, one level in a package bound (r11u200) | ParamEmit.cpp | cases/Z z04 |
| `R11U200_GENBITS_OFF` | § genBlockBitsKeepsSelect200, the elaborated half (r11u200) | ExprEmit.cpp | cases/Z z05-z08 |
| `R11U201_CLSBOUND_OFF` | § clsScopedBoundWholeSpan201 | ExprEmit.cpp (§ staticScopedRef12's branch) | cases/C |
| `R11U201_SYSARG_OFF` | § sysCtxRefArgBare201 | ExprEmit.cpp (the call-argument stamp, `refArg`) | cases/S |
| `R11U201_OPARG_OFF` | § opCtxRefArgBare201 | ExprEmit.cpp (the same site; `caClonedOpRoot201`) | cases/Q |
| `R11U201_NONRED_OFF` | § nonReduceOpArgBare201 | ExprEmit.cpp (the same site) | cases/Q q01 q09 q10 |
| `R11U201_MARGNEST_OFF` | § methodArgNestedRefChain201 | ExprEmit.cpp (the design-final pass `refFullNameThroughNamedExpr175`) | cases/M |
| `R11U201_SELIDXCALL_OFF` | § callArgInSelIdxChainName201 | ExprEmit.cpp (the same pass) | cases/N |

`R11U201_TRACE=<dir>` (one file per process, `<pid>.T201`) and `R11U200_TRACE=<dir>` (`<pid>.200E`, `<pid>.200P`)
name every firing, first line `OUT <-o path>`: the census's input. The two chain-naming laws run inside
`refFullNameThroughNamedExpr175`, so `R11U175_FULLNAME_OFF` drops them too; § sysCtxRefArgBare201 reads
§ vsStampReducedCtxOnly198v's walk, so `R11V198_VSSYS_OFF` drops it too.

**Switch checks** ([evidence/switchcheck.txt](evidence/switchcheck.txt), `drivers/switchcheck.sh` on `law7.bin`):
each switch alone, on every case of its grid where its law fires and no other law of either pass does, restores the
pristine bytes, in both forms: CLSBOUND 5 of 5, SYSARG 3 of 3 (4 mixed), OPARG 3 of 3 (2 mixed), NONRED 1 of 1 (2
mixed), MARGNEST 8 of 8, SELIDXCALL 5 of 5, NEWARRHP 2 of 2, FOLDDEPTH 1 of 1, UNITFOLD 1 of 1, GENBITS 4 of 4;
NOT_RESTORED none. `R11U201_NEWARRLAST_OFF` is a refinement switch: with it set the r11u200 law's own `-elabuhdm`
break returns (z01 z02 `STRICT_NOTEQUAL fullname`). **`R11U201_OFF=1 R11U200_OFF=1` writes the pristine bytes on all
54 grid cases (the 48 law cases and the 6 decode-only shapes) in both forms** (`OFF=pristine` in every row of [evidence/grid/grid_parse.tsv](evidence/grid/grid_parse.tsv)
and [grid_elab.tsv](evidence/grid/grid_elab.tsv)).

## 3. The laws

Every grid case is judged against a real pinned Surelog v1.87 golden in two forms: the probe form (`-parse -nobuiltin
-nocache -sv dut.sv` against `dut.sv --single-unit --nobuiltin`) and the `-elabuhdm` form (`ELAB=1`, `--elabuhdm` on
our side). Each case names its law on its first line. Verdict columns below: pristine -> law.

### 3.0 The r11u200 decode's ground-A laws (question 0)

`tools/probe/r11u200dec/law_exprstmt.patch` applies clean on `ddc67d87` (passes 196 and 198 landed after it was
drafted) and was landed unchanged, then refined once (3.0.1). Measured alone (`law200.bin`) on the r11u200 A grids
(B, N, U) and with pass 198's laws switched off (`R11U198_OFF=1`): identical verdicts, N n01 n02 and U u01 u05
converted, B needs the B half ([evidence/grid/r11u200_grid_A_with198.tsv](evidence/grid/r11u200_grid_A_with198.tsv),
[r11u200_grid_A_198off.tsv](evidence/grid/r11u200_grid_A_198off.tsv)): **the composition with pass 198 is neutral**.
Re-verified on 8 fresh cases of this pass (cases/Z, parse form):

| case | shape | law | parse | `-elabuhdm` |
|---|---|---|---|---|
| z01 | `new[h.q.size * 2]`, `new[this.data.size - 1](bytes)` in a class task | NEWARRHP | `fullname(1)` -> EQUAL | EQUAL -> EQUAL (law200 alone: EQUAL -> `fullname(2)`, fixed by 3.0.1) |
| z02 | `new[c ? b.size : 2]`, `new[(b.size + a.size)]` in a package function | NEWARRHP | `fullname(6)` -> EQUAL | EQUAL -> EQUAL (law200 alone: `fullname(6)`, fixed) |
| z03 | `$unit` bounds `[4*8-1:0]`, `[16/2-1:0]`, `[(3+5)-1:0]` | UNITFOLD | `endcol(9)` -> EQUAL | `endcol(9)` -> EQUAL |
| z04 | package bounds `[W*2-1:0]`, `[2*4*2-1:0]`, `[8-1-1:0]` | FOLDDEPTH | `endcol(6)` -> EQUAL | the same |
| z05 | `$bits(x[7:0])` in a case-generate item, `$bits(x[3])` in a gen-if else | GENBITS | NOT_EQUAL both (the definition listing's half is ground B) | the same |
| z06 | `$bits(x[5:0]) + 1` two generate levels down | GENBITS | NOT_EQUAL -> EQUAL | the same |
| z07 | `$bits(x[i+2:0])` in a for-generate `always_comb` | GENBITS | NOT_EQUAL -> EQUAL | the same |
| z08 | `$bits(x[1])` of a packed array in an if-generate | GENBITS | NOT_EQUAL both (definition-listing half, ground B) | the same |

Downstream (the gate's own `one()`, [evidence/downstream/](evidence/downstream/)): **z05 z06 z07 z08 DIVERGENT ->
IDENTICAL** (the elaborated `$bits` kept as a call: Surelog lane `connect \z 8`, ours had folded the root width);
z03 z04 IDENTICAL on both binaries.

#### 3.0.1 § newArrayPathStripTrailOnly201v (`R11U201_NEWARRLAST_OFF`; refines § newArrayArgPathElemsStripped200)

**Break found by the fresh cases.** The r11u200 law tested each path element with `VpiFullName().empty()`; ref_obj's
getter COMPUTES and STORES the chain name on an element that had none (UHDM `ref_obj::VpiFullName() const` freezes
`ComputeFullName()`), so the leading elements `h`, `q` of `new[h.q.size * 2]` got a stored name, and in the
`-elabuhdm` form the elaborator's clone carries it: golden `ref_obj h` unnamed, ours `work@C::t::h` (z01, z02: EQUAL
on the pristine binary, `fullname` on `law200.bin`). The refinement strips only the TRAILING element (the only one
ever minted with a stored name there), without reading it. All r11u200 N-grid and corpus conversions keep.

### 3.1 § clsScopedBoundWholeSpan201 (`R11U201_CLSBOUND_OFF`; r11u199's N2)

**Face.** `x[K::V:p::S]` with `K` a class: golden `ref_obj K::V` 13:17-13:21 (the whole name), ours 13:17-13:20 (the
qualifier, § staticScopedRef12's span).

**Decode.** CompileExpression.cpp `compilePartSelectRange` compiles both bounds with `Reduce::No`; outside a bound the
class-scope branch (`paClass_scope`: `populateCoreMembers(child, child, ref)`) populates the reference from the
class_scope node (`K::`), which is what a plain read, a bit-select index and an indexed part select's base show
(measured: c02's `x[K::V]`, c03's `x[K::V +: 2]` and `y2 = K::V` agree with the qualifier span). Inside a part-select
range the whole name node is populated — the mirror of § pkgQualBoundSpanQualifier192 for a package, which spans the
qualifier only in a bound.

**Law.** A two-segment class-scoped reference whose parent, through operations other than a conditional, is a
part_select spans the ScopedName's whole range (parentheses excluded). A three-segment `p::C::W` keeps the qualifier
in a bound too (golden 12:17-12:23, c05) and is declined; a conditional in the bound is not measured (declined).

**Grid** cases/C (both forms): c01 (left and right bounds) c02 (an operand `K::V-1`) c04 (procedural, an lvalue part
select) c05 (a member select `s.f[K::V:0]`, `(K::V)`) converted; c03 (`x[K::V]`, `x[K::V +: 2]`, `y2 = K::V`) keeps
its own `type(1)` face (golden keeps the rvalue `K::V` a ref_obj, ours folds: a fold face, unchanged); c06's function
body converts, its for-generate definition listing reads `fullname(1)` (the definition generate listing is TypeEmit
`emitSyntaxExpr`, ground B: section 7). Also converted: r11u199verify Q/q02_class_scoped.

### 3.2 The evaluator's argument stamp: § sysCtxRefArgBare201, § opCtxRefArgBare201, § nonReduceOpArgBare201

**Face** (v11u198's residue 3, r11u198's R5 v22): the pristine rule stamps the formal's typespec on every ref_obj /
bit_select / part_select / indexed_part_select actual of a user function call in a continuous assignment. Golden
stamps only where UHDM's evaluator reaches the call (ExprEval::evalFunc binds `exparg->Typespec(<formal>)`), and
`uhdm-cmp` reads an expression's Typespec, so most of these faces are judge-visible: `assign y = f(a) + 4'd1;` reads
`NOT_EQUAL` on the pristine binary (cases/Q q01).

**Decode.**
1. **§ sysCtxRefArgBare201** — ExprEval's `sys_func_call` branch reduces the arguments of `$signed`, `$unsigned`,
   `$clog2` only (the decode of § vsStampReducedCtxOnly198v clause 1, which that law applied to `var_select` actuals
   only): below any other system call (`$countones`, `$onehot`, `$isunknown`, `$bits`) the call is never evaluated,
   in every view. Grid S: s01 (`$countones(f(p1[2]))`, `$countones(f(a))`, `$countones(f(w[3:0]))`), s02
   (`$onehot`, `$isunknown`), s06 (a child module), s07 (`always_comb`, nesting) converted in the parse form; also
   v11u198's t18 and t35 (closer: 55 -> 41 order-blind lines; its own `$countones` sys-call typespec face stays).
2. **§ opCtxRefArgBare201** — UhdmWriter::writeCont_assign CLONES the continuous assignment (and reduces the clone)
   when its target is a whole name `bindVariable` finds and its right side is an OPERATION; the stamps land on the
   clone and the definition listing's own objects stay bare. A call that is a conditional's operand keeps the stamp in
   the listing (q03 `c ? f(a) : 4'd0`, q08 `(c ? f(a) : 4'd0) + 4'd1`), and so do a select target (`y4[3:0] = f(a) +
   4'd1`), a call root (`g(f(a) + 4'd1)`) and a system-call root (`$signed(f(a) + 4'd1)`): EQUAL on the pristine
   binary and on the law binary (q03 q08 are the controls that broke the first law binaries, law2/law3, whose rule
   was "any operation above"). The law: in the DEFINITION listing (`contAssignView == 1`), the call's NEAREST
   operation above it (through calls) is not a conditional, the target is a plain identifier and the root is an
   operation. The `-elabuhdm` form is left as it was (its q01 / q09 / q10 faces are not decoded).
3. **§ nonReduceOpArgBare201** — reduceExpr's operation switch has no branch for `^`, `~^`, `===`, `!==`, `==?`,
   `!=?` (the operator list § evalFuncOpReduceGate195 decoded): a call below such an operator (through reducing
   operators and calls; a conditional abstains) is never evaluated, in the definition listing and the elaborated
   parse-form body alike, whatever the root (q01 `f(w[3:0]) ^ 4'd2`, q10 `g(f(a) ^ 4'd1)`, `f(a) ~^ g(a)`).

The three contexts are disjoint (law7): a non-reducing system call above is 1's, a non-reducing operator 3's, the rest
2's, so each switch alone restores its own context's pristine bytes.

**Grid** cases/Q (10) and S (7), both forms:

| case | pristine | law (parse) | law (`-elabuhdm`) |
|---|---|---|---|
| Q q01 q02 q05 q07 q09 q10 | NOT_EQUAL | **EQUAL** | q02 q05 q07 EQUAL; q01 `type(1)`; q09 q10 NOT_EQUAL (the form this pass leaves alone) |
| Q q03 q04 q06 q08 (controls: conditional, net declaration, generate scopes, call root, whole-call rhs, select target) | EQUAL | EQUAL | EQUAL |
| S s01 s02 s06 s07 | NOT_EQUAL | **EQUAL** | s01 s02 s07 EQUAL, s06 NOT_EQUAL (pristine's) |
| S s03 s04 s05 | NOT_EQUAL | NOT_EQUAL (the next faces: a cast operation's typespec, a variable initializer's cast, the generate-scope definition listing) | the same |

Also converted: r11u198's V/v22 (`opCtxRefArgBare201`), v11u198's V/t08 t16 t17 (`opCtxRefArgBare201`) and t18
(`sysCtxRefArgBare201`); r11u198's V/v23 moves closer (16 -> 9). Downstream: every Q and S case keeps its verdict
(IDENTICAL, EQUIVALENT s03, DIVERGENT s04 on both binaries).

### 3.3 § methodArgNestedRefChain201 (`R11U201_MARGNEST_OFF`; the residues of § methodArgOpRefChainName198)

**Face.** Objects inside a method call's argument whose call is a hier_path's last element: `x = c.f(a[i] + 1, n)`:
golden bit_select `work@D::g::c.f::a` and its index `work@D::g::c.f::i`; `c.f(g2(i) + 1)`: `...::c.f::i`;
`s.substr(i, args[i].len() - 1)`: `...::s.substr::i`; `c.f(b[i][j] + 1)`: var_select `c.f::b`, indices
`c.f::b::i`; ours the scope's `work@D::g::a`.

**Decode.** compileTfCallArguments compiles the actuals under the call and stores no full name, so the reader's chain
(UHDM ComputeFullName, `chainFullName175`) names every object in an argument, whatever lies between it and the call:
selects, user calls, nested paths, operations. § refFullNameThroughNamedExpr175 took a reference directly under the
call, § methodArgOpRefChainName198 one under operations and system calls only, both inside a subroutine; golden
reads the same chain in a module `initial` / `always` block and a generate scope's `initial` (m07, m09: `work@top.c.f.a`,
`work@top.g.c.f.u`).

**Law.** Design-final, beside the two laws above: a ref_obj / bit_select / var_select / part_select /
indexed_part_select whose ancestors, through operations, system calls, user calls, selects and paths, reach a
method_func_call that is its hier_path's last element takes the chain name, only where ours is that name with
ancestors dropped (same root, same leaf); a reference those laws own (under operations only, inside a subroutine) is
left to them.

**Grid** cases/M (10), both forms: m01 m02 m03 m04 m05 m07 m09 m10 converted (m03 in the parse form; its
`-elabuhdm` form keeps `fullname(2)`: golden's elaborated chain runs through the inner path `args[i].len`, ours does
not); m06 (a method TASK call statement) control EQUAL; m08 (`c.h(i).f(...)`) NOT_EQUAL on both. Also converted:
r11u198's M/m13, v11u198's M/v01 v08 v13, r11u192's Q/q05_qual_class, and the probe cases r10uvm60repro/v2_class,
v11u112repro/.../b2c_iface_fn (g193_c_argface 102 -> 94 records).

### 3.4 § callArgInSelIdxChainName201 (`R11U201_SELIDXCALL_OFF`; r11u194's N4, r11u198's R1)

**Face.** `t.f[fx(s.f[k])] <= 0`: the index `k` of the argument path's trailing select, golden
`work@top.t.f[].f.s.f[k].k` (rvalue `work@top.t.f.f.s.f[k].k`, a class method index `kk.a[kk.idx(s.f[k])]`:
`work@top.kk.a[].a.kk.idx.s.f[k].k`), ours `work@top.s.f[k].k` (§ hpTrailSelIdxNamesByPath133's name).

**Decode and law.** The same storage rule as 3.3 with the call INSIDE another path's select index: a reference that
indexes a path's trailing select, when that path is (through operations and calls) an argument of a call whose parent
is a bit_select / var_select of another hier_path (a method call's own path stepped over), takes the chain name,
same root and leaf only.

**Grid** cases/N, both forms: n01 n02 n04 n05 n08 (two levels) converted; n06 (inside a function: already equal)
control; n07 (a generate-scope process) `fullname(8)` -> `endcol(3)`: the three records left are the call's span in
the generate listing (TypeEmit, r11u198's L/l13 face). Also converted: r11u198's L/l12, l22, v11u198's L/u08, u10.

## 4. The gates (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `ddc67d87`)

| gate | pristine (`/tmp/r11u201_swP`) | law7 (`/tmp/r11u201_sw7`) |
|---|---|---|
| (1) build | = the main tree's build (md5 above) | `ddc67d87` + this patch; the src patch applied to a fresh `ddc67d87` worktree rebuilds it (section 9) |
| (2) probe vs golden_probe.csv | EQUAL 3345 / 742, `probe.csv` byte-identical to the baseline | EQUAL **3349** / 738: `regressions=0 conversions=4 changes=1` |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (461+19 / 457+17) | `regressions=0 conversions=0` **`changes=13`** (section 0); judge-equal 480 / 474 and CMP_NOTEQUAL 3 / 3 unchanged |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (796+7 both modes) | the same |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; `downstream.csv` byte-identical to the pristine sweep's |
| (5) uhdm-cmp | – | every mover keeps its judge status (the histograms above; every probe mover stays uhdm-cmp equal) |
| (6) byteverify (`SELFCHECK=1`, fence-free mirrors `fenced_skipped=8`) | | **13 / 2560 movers, every one predicted by name** ([evidence/sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)); SELFCHECK 2559 / 2560 flagged |
| probe / downstream-lane movers | | 5 / 4087 and 0 / 805, every one predicted |
| canaries ([evidence/canaries.txt](evidence/canaries.txt)) | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0 | surelog ok=41 changed=11 (exactly the 11 canary rows among the 13 changes); uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS (ok=58), `EXPECT_UNKNOWN=6` PASS (ok=2) |

**law6 and law7.** The first law sweep `/tmp/r11u201_swL` (law6) reads the same verdicts: `probe.csv`,
`uhdm2rtlil.csv` and `downstream.csv` byte-identical to law7's, `surelog.csv` different only in the LowMem detail
text (the workdir path); the byte comparison of the two sweeps reads 1 / 2560 movers, SeqDriver/default, whose two
databases' uhdm-dumps are identical ordered and order-blind (storage order only;
[evidence/sweeps/byteverify_law6_law7.txt](evidence/sweeps/byteverify_law6_law7.txt)); the 54 grid cases are
byte-identical under both.

**Byte controls** ([evidence/byte_controls.txt](evidence/byte_controls.txt), `drivers/ctlbytes.sh` + `ctlsum.py`): every
case of the evidence grids of passes 118 (r11u118repro, r11v11u118repro), 119, 120 (r11u120repro, r11v120repro), 124
(r11u124repro, r11v124repro), 131 (r11u131repro, r11v131repro), 175 (r11u175uvm), 192, 195 (r11u195repro,
v11u195repro), 198 (r11u198repro, v11u198repro) and r11u199verify — **1370 cases**, judged with `pris.bin` and
`law7.bin`: **18 databases move; 15 convert to EQUAL, 3 stay judge-unequal and closer (r11u198's V/v23 16 -> 9,
r11u199's W/w8 79 -> 36, v11u198's V/t35 55 -> 41 order-blind dump lines), 0 worse**. Every mover is attributed by
trace (section 3).

## 5. The prediction and the attribution of every change

**The prediction** ([evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt), frozen `chmod 444`
before the law sweeps, [frozen_at.txt](evidence/census/frozen_at.txt)): `drivers/census.sh` runs `law.bin` with
`R11U201_TRACE` and `R11U200_TRACE` over every corpus row-mode but the fenced four (the `--filter` built from the
fence), every probe case and every downstream lane; `drivers/censum.py` lists every database a law fired on: 20
corpus row-modes, 1 downstream lane and 6 probe cases.

| where | moved | predicted | predicted, not moved |
|---|---|---|---|
| corpus (2560 databases) | 13 | 20 | Earlgrey_0_1 d/t (§ nonReduceOpArgBare201 ×6), SimpleConstraint d/t and ibex_tracer d/t (§ sysCtxRefArgBare201 ×1 / ×6): the trace fires where the law's context holds, before the stamp rule's other conditions (process and task contexts, parameter actuals) decide; those actuals were bare on the pristine binary too |
| probe (4087) | 5 | 6 | r10uvm57repro/v1_prodcell (§ sysCtxRefArgBare201 ×1, the same) |
| downstream lanes (805) | 0 | 1 | ibex_tracer (as above) |

Moved and not predicted: **0** in every population. The trace fires where a law's context holds, a superset of the
moves.

| row-mode / case | change | law, by the firing census |
|---|---|---|
| MiniAmiq d/t | `file(17) -> file(4)` | § methodArgNestedRefChain201 154, § sysCtxRefArgBare201 41, § newArrayArgPathElemsStripped200 1 |
| SeqDriver d/t | `fullname(16) -> endcol(3)` | § methodArgNestedRefChain201 146, § sysCtxRefArgBare201 41 |
| SimpleUVM d/t, Scoreboard d | `fullname(44) -> fullname(31)` | § methodArgNestedRefChain201 92, § sysCtxRefArgBare201 27 |
| BuildUVMPkg d/t | `line(11) -> line(5)` | § methodArgNestedRefChain201 71, § sysCtxRefArgBare201 27 |
| SVSwitch d/t | `fullname(13) -> endline(11)` | § newArrayArgPathElemsStripped200 2 (r11u200's lawA prediction exactly) |
| Scr1SvTests d/t | `endcol(29) -> endcol(19)` | § unitBoundFoldAtLeftOperand200 4, § sysCtxRefArgBare201 2 (r11u200's lawA prediction exactly) |
| 4 probe conversions, g193_c_argface | section 0 | per the census file |

No count grows on a still-failing row; the new first records are quoted in section 7.

## 6. Distances and determinism

**Order-blind distance to golden** (`drivers/uvmdist.sh`, `obrow.sh`: uhdm-strictcmp's records as multisets, depth
dropped, ours-not-in-golden + golden-not-in-ours; [evidence/sweeps/uvmdist_pristine_law.txt](evidence/sweeps/uvmdist_pristine_law.txt)):

| row-mode | pristine | law | |
|---|---|---|---|
| MiniAmiq d / t | 15559 | 15265 | −294 |
| SeqDriver d / t | 11805 | 11449 | −356 |
| SimpleUVM d / t | 4538 | 4246 | −292 |
| Scoreboard d | 3451 | 3213 | −238 |
| BuildUVMPkg d / t | 1907 | 1765 | −142 |
| SVSwitch d / t | 102 | 98 | −4 |
| Scr1SvTests d / t | 251 | 231 | −20 |
| Earlgrey_0_1, Rggen | unchanged (not movers) | | |

**Determinism** (`drivers/det.sh`: each binary three times CONCURRENTLY per row-mode, the reference command line;
`drivers/detob.sh`: sorted-dump diffs between the draws; [evidence/determinism/](evidence/determinism/)): **Earlgrey_0_1
default and testflags one hash per mode in both binaries**; the UVM rows (MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
BuildUVMPkg) draw two or three hashes in both binaries, every pair 0 sorted-dump lines apart (storage order only).
No law adds a coin.

## 7. Ranked residues and the sister-ground faces (call sites; not edited here)

1. **The joint rows' B halves this pass's laws wait for** (r11u200's law_typeemit.patch, which the sister r11u202 is
   landing): SVSwitch d/t now reads `endline(11)`, the implicit-type end across a line break (#1951 `rtl.sv
   2:6-1:479`, TypeEmit, law implicitTsEndCrossesLineBreak200) then the interface-array names (#3380, ModuleEmit,
   law ifaceArrPortElemViewNamedByArray200); with both the row converts (r11u200's measurement). Scr1SvTests d/t
   `endcol(19)`: the multi-dimensional port spans (#31055 `29:12-29:39` vs ours `29:28`, ModuleEmit
   `materializeDefNetTs`, law defPortPackedTsKeepsWholeSpan200), then the `$unit` initializer location
   (UhdmExporter, the R11U200_UNITINIT half). The definition-listing half of the generate `$bits` law (z05, z08:
   TypeEmit `emitSyntaxExpr`).
2. **The UVM rows' first records are ground B now** except two: MiniAmiq `#899` enum_typespec file (N0144), `#8753`
   the signing span (law tfSigningSpanFollowsCompilePath200), `#10106` the class typedef return (law
   classTdRetSharesTypedefTs200) — all in r11u200's B patch; SeqDriver `#8736` / `#10089` the same two. Ground A:
   **SimpleUVM / Scoreboard `#458` the `UVM_MACRO_*` parameter's ref_typespec full name** (golden
   `UVM_MACRO_NUMFLAGS`, ours `uvm_pkg::UVM_MACRO_NUMFLAGS`, 29 records: an untyped package parameter reached through
   a reference inside the package; ParamEmit `makeParamTs`, pass 195's R2). Small probe shapes of it (an untyped
   package parameter read by another) read NOT_EQUAL on both binaries on a judge-visible neighbour (the int_typespec's
   `vpiSigned` of the folded read), so it was not gridded to a law here. BuildUVMPkg `#5639` (N0189, a constant
   argument of `m_matches_type_override` located at another call, ExprEmit near § namedTfArgsFormalSlots4) is next.
3. **Earlgrey_0_1's head** is `#90097` (map 11's N0941 is already cleared at the base): a generate-scope port
   connection's trailing select `reg2hw_wrap.class_en[k]` — golden stores no full name (chain
   `work@alert_handler.gen_classes.i_accu.class_en_i.reg2hw_wrap.class_en[k].class_en`) and spans the INDEX (148:44-45),
   ours `reg2hw_wrap.class_en[k]` at the member (148:35-43). Reproduced in [evidence/decode/G_g01.sv.txt](evidence/decode/G_g01.sv.txt) (decode only; judged `fullname(12)` on both binaries): the definition
   listing's connection is emitted by TypeEmit `emitSyntaxExpr`, the elaborated one by ModuleEmit (ours names it
   `work@top.i_accu.en_i...` without the generate scope, golden `work@top.gen_classes[0].i_accu.en_i.reg2hw_wrap.class_en[0].class_en`):
   both ground B.
4. **Rggen's N0145** (`indexed_part_select read_data` in `bit_field_if.read_data[0+:4]` of a nested-generate
   continuous assignment: golden DefName `read_data` and no stored full name, ours DefName empty and full name
   `bit_field_if.read_data[0+:4]`): reproduced in [evidence/decode/](evidence/decode/) R_r01-R_r03 (decode only, `defname(1)`-`defname(2)` on both binaries); the minting site
   is TypeEmit `emitSyntaxExpr`'s path branches (the `ip8` / `ip9` indexed part selects, `dottedSoFar` / `dottedDisp`),
   the definition generate listing — ground B, not ExprEmit as map 11 placed it.
5. **arb_idx_cast d/t** reads `endline(2)` at the base: both records are the type parameter default's
   `logic_typespec` (golden 8:40-15:27, ours 8:40-8:60; TypeEmit `makeTypeParamDefaultTs`) — ground B only now (the
   `#322` generate-scope face is gone).
6. **cfg_func_width_loop d/t** `line(3)`: golden's elaborated `M` value constant `3'b101` points at maxw's FORMAL
   typespec (`q::maxw::cfg`'s `logic_typespec mask_t` 27:40, the object the io_decl's typedef reference names), ours a
   copy at the typedef (16:11); the stamp happens where the port range `[q::maxw(M)-1:0]` is evaluated with the
   instance's shared param_assign. A ParamEmit stamp (which parameter actuals the evaluator reaches from a port or net
   range) plus the kept `q::maxw(M)` call (ModuleEmit emitContAssigns). Decoded, not written: the row converts only
   with both.
7. **struct_param_func_config d/t** `fullname(5)`: the evaluator's struct copy named through the instance where the
   override chain was evaluated (`work@struct_param_func_config.p::cfg_t.u` where ours has `...u_c.Cfg.p::cfg_t.u`),
   then `#1364` a golden-only constant copy (N0045). ParamEmit `makeParamTs` `memberScope`; r11u200 found five
   differently named copies in golden (last writer wins); not written.
8. **The value encoding of folded calls** (r11u196's DF/d01, TB/t05): golden `f(1, 3)` -> `UINT:4`, `g(4'h1)` ->
   `UINT:2`, `g(4'd1)` -> `INT:2` with `int` returns: ExprEval types the result from the body's final operation's
   operands (any `INT` operand -> INT), ours from the return type (EmitHelpers.h `srlgRedIntSyn`). Not written.
9. **This pass's own limits**: the `-elabuhdm` form of the operator-context stamp (Q q01 `type(1)`, q09 q10 NOT_EQUAL:
   golden stamps some calls under a unary operator there and not under a binary one); m03's `-elabuhdm` chain through
   the inner path; c03's class-scoped rvalue kept as a ref_obj (a fold face); s03 / s04 (a cast operation's typespec,
   a variable initializer's cast; s04 is DIVERGENT downstream on both binaries); the generate-listing spans (c06,
   n07) of item 1's ground.
10. **Not reached** (carried): pass 198's R3 (the cast law's k19 / k10 / x17), R4 (n20, n24), R6 (g18, g5_hop95),
    the `-elabuhdm` call under a concatenation (t12, t20), R9 (N0739, ModuleEmit), R10 (whole-name targets whose root
    is a system call: every shape with a folded package parameter under it is judge-unequal at the base on faces of
    its own — the all-constant `$unsigned({1'b0, W})` folds whole in golden — so no law could be gridded); pass 195's
    K/k12, `'{A:B.A}`, T/t10, e30 / e31; pass 184 / 187's carried faces; InterfArrayBind, FuncStructVal*, a8_orphan,
    anon_struct_packed_dim N0820, BlackBePipeInt N0923, ibex_tracer, UnitElabBlock.

## 8. Files, and how to reproduce

* `drivers/`: `env.sh` (pins + fence), `case.sh` (judge one case, both forms with `ELAB=1`), `judge.sh`, `grid.sh`
  (`OFFCHECK=1`: `R11U201_OFF=1 R11U200_OFF=1` byte check), `switchcheck.sh`, `census.sh` + `censum.py` (the firing
  census), `bvmirror.sh`, `ctlbytes.sh` + `ctlsum.py` (the byte controls), `rowhead.sh`, `obrow.sh`, `obdist.sh`,
  `uvmdist.sh`, `det.sh` + `detob.sh`, `dscase.py` (the downstream gate's `one()` on a case).
* `cases/`: C (class-scoped bounds, § clsScopedBoundWholeSpan201), M (§ methodArgNestedRefChain201), N
  (§ callArgInSelIdxChainName201), Q (§ opCtxRefArgBare201, § nonReduceOpArgBare201), S (§ sysCtxRefArgBare201), Z
  (the r11u200 laws: z01 z02 § newArrayArgPathElemsStripped200 and § newArrayPathStripTrailOnly201v, z03 z04
  § unitBoundFoldAtLeftOperand200, z05-z08 § genBlockBitsKeepsSelect200); G and R are decode-only (ground B faces,
  section 7 items 3 and 4).
* `evidence/`: `grid/` (both forms, the r11u200 A grid with and without pass 198), `census/` (the frozen prediction),
  `sweeps/` (the three sweep summaries, byteverify, UVM distances), `canaries.txt`, `switchcheck.txt`,
  `byte_controls.txt` (+ the judge tsv), `downstream/` (the cases' downstream verdicts), `determinism/`.

Reproduce: build `ddc67d87` + the patch (`cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON
-DCMAKE_PREFIX_PATH=$HOME/.local && cmake --build build -j 2`), freeze it with the pristine build in `/tmp/r11u201_bin`,
then `bash drivers/grid.sh` (and `ELAB=1`), `bash drivers/switchcheck.sh law.bin`, `bash drivers/census.sh <wd> <tr>
<prefix>`, `tests/sweep.sh --jobs 3 --workdir <wd>` with `SLANG_UHDM` exported.

## 9. The patch

`/tmp/r11u201.patch` = `git diff ddc67d87` of this worktree: `src/ExprEmit.cpp`, `src/ParamEmit.cpp`,
`src/EmitHelpers.h`, `tools/probe/r11u201repro/`, `tests/LAWS.md` (regenerated by `python3 scripts/law_index.py`).
It applies clean on a fresh `ddc67d87` (`git apply --check`); the src part applied to a fresh worktree of `ddc67d87`
(`/tmp/wt_r11u201v`, system-deps config) rebuilds `law7.bin`'s md5 (section 1).
