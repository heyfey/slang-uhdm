# r11u198 — the expression/parameter ground: a generate-scope fold named by its owner where nothing re-parents it, a multi-index select actual stamped with its formal's typespec, one-hop folds in select indices named by the select, method-call operation arguments named through the path, lvalue-index call arguments compiled as reads, a cast right-hand side's operands named below the cast; ibex_pmp d/t and 37 probe cases converted

**Base.** `7eb6f4b5` (branch matrix-1.87, pass 195). Worktree `/tmp/wt_r11u198`, system-deps config, `-j 2`. Ground A
only: `src/ExprEmit.cpp` and `src/EmitHelpers.h` (the switch and trace helpers); no `StmtEmit.cpp` or `ParamEmit.cpp`
change was needed. Nothing under `results/`, `third_party/` or `tests/` (but the regenerated `tests/LAWS.md`) is edited.
The sister pass r11u196 (module/type ground, base `b8719ea9`) had not landed; none of its files is touched.

**The fence.** Every driver here that reads a corpus source or database takes the four names from the `FENCED=` line
of `tools/probe/r11u107repro/canaudit.sh` and refuses them fail-closed (`drivers/env.sh`; `rowhead.sh`, `obrow.sh`,
`det.sh`, `detob.sh`, `uvmdist.sh` refuse a fenced name; `census.sh` runs the corpora and the downstream lanes with a
`--filter` built from the fence; `bvmirror.sh` leaves the 8 fenced row-mode databases out of the byte comparison:
`fenced_skipped=8`). The gate sweeps dispatched every row, as the gate requires; their csv verdicts are the only
fenced facts cited (all unchanged). A grep of this directory for the four names reads 0.

## 0. Verdicts

| row / face | before (7eb6f4b5) | after | law |
|---|---|---|---|
| **ibex_pmp default** (uhdm2rtlil) | `STRICT_NOTEQUAL differ:type(1)` | **`CMP_EQUAL`** | § callArgVarSelStamp198 |
| **ibex_pmp testflags** (uhdm2rtlil) | `STRICT_NOTEQUAL differ:type(1)` | **`CMP_EQUAL`** | § callArgVarSelStamp198 |
| arb_idx_cast d/t (uhdm2rtlil) | `differ:endcol(17)` | `differ:endcol(3)` (the three records left are the sister's, section 8) | § genHopFoldSelName198 (12 records) + § genCaCastRhsRefUnnamed198 (2) |
| **37 probe cases** | `STRICT_NOTEQUAL` | **`EQUAL`** | section 5 |
| probe r10earl95repro/g5_hop95 | `differ:fullname(7)` | `differ:fullname(2)` | § genHopFoldSelName198 |
| probe r11u112repro/grid/f/g18_hop_lhs | `differ:fullname(5)` | `differ:fullname(1)` | § genHopFoldSelName198 |
| Earlgrey_0_1 d/t | `differ:fullname(82)` | cell unchanged; order-blind distance 12814 -> 8570 (d), 12306 -> 8316 (t) | § genHopFoldSelName198 (1995 records, r10earl66's R0 population), § ovrParamBoundOpSelName198 (31), § genCaCastRhsRefUnnamed198 (96, default only), § lvIdxCallArgIsRead198 (4) |
| MiniAmiq / SeqDriver / SimpleUVM / Scoreboard / BuildUVMPkg | cells unchanged | order-blind distance 15963 -> 15837, 12337 -> 12189, 4986 -> 4886, 3813 -> 3737, 2035 -> 1983 | § methodArgOpRefChainName198 (map N0175 / N0217 / N0220) |
| Rggen d | `differ:endcol(144)` | cell unchanged; order-blind 10771 -> 10659 | § ovrParamBoundOpSelName198 (56) |

The fresh rows (not written to `results/`):

    ibex_pmp,default,CMP_EQUAL,,,equal        (baseline STRICT_NOTEQUAL differ:type(1))
    ibex_pmp,testflags,CMP_EQUAL,,,equal      (baseline STRICT_NOTEQUAL differ:type(1))
    arb_idx_cast,default,STRICT_NOTEQUAL,differ:endcol(3),,differ:endcol(3)      (baseline differ:endcol(17))
    arb_idx_cast,testflags,STRICT_NOTEQUAL,differ:endcol(3),,differ:endcol(3)    (baseline differ:endcol(17))

and the 37 probe conversions (each `<case>,EQUAL,,equal` in the law sweep's `probe.csv`): r10earl105repro/h1_head105,
h2_child105; r10earl_repro/wf24; r10vearl118repro/v2_fenceface; r10vearl95repro/v95a_ctx; r11u112repro/grid/f/g11,
g12, g13, g14, g16, g17, g19, g20, g21; r11u113repro/grid/c/c19, c23, c24, c26, c28; r11u115repro/grid/r/f/p05, p12;
r11u115repro/grid/r/i/p01, p02, p03, p05, p12, p13; v11u112repro/grid/brk/f/g1h, g1j, g1m;
v11u113repro/grid/brk2/t12; v11u115repro/grid/f1/a01, a06, a09, a13, a18, a20 (the full list with the before cells
is [evidence/sweeps/compare_probe_law.txt](evidence/sweeps/compare_probe_law.txt)).

Totals of the law sweep against the committed baselines: **probe regressions=0 conversions=37 changes=2; surelog
regressions=0 conversions=0 changes=0; uhdm2rtlil regressions=0 conversions=2 changes=2; downstream 803 IDENTICAL / 66
SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, `downstream.csv` byte-identical to the pristine sweep's** (ibex_pmp and
arb_idx_cast stay IDENTICAL). 16 of 2560 corpus databases, 40 of 4087 probe databases and 2 of 805 downstream-lane
databases move, every one predicted by name by the frozen firing census (section 5).

## 1. Binaries (frozen `chmod 555` in `/tmp/r11u198_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `86812cac4e113f93d477723d6437b44c` | the worktree at `7eb6f4b5`: byte-identical to the main tree's `build/slang-uhdm` |
| **`law.bin`** (= `law15.bin`) | **`180bbe38c02c88d601e02c6671f01e7a`** | **THE DELIVERED SOURCES** (`/tmp/r11u198.patch` applied to a fresh `7eb6f4b5` rebuilds it, section 9) |
| `law1.bin` .. `law14.bin` | | development steps (law9 ran a first firing census, `/tmp/r11u198_cen9`; law13's probe run read the one break section 3.7 fixed) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

Sweeps (`tests/sweep.sh --jobs 3`, all four stages, `SLANG_UHDM` exported, same-length workdirs): `/tmp/r11u198_swP`
(pristine) and `/tmp/r11u198_swL` (law). `cmds.txt` audit: swP 3273 of 3273 `slang:` lines name
`/tmp/r11u198_bin/pris.bin`, swL 3273 of 3273 `/tmp/r11u198_bin/law.bin`. The pristine sweep reproduces the baselines
exactly: `probe.csv` byte-identical to `results/golden_probe.csv` (EQUAL 3306 / STRICT_NOTEQUAL 781), surelog and
uhdm2rtlil `regressions=0 conversions=0 changes=0` (480/3 + 474/3 judge-equal; 803/1/67 both modes), downstream 803 /
66 / 2 / 0. Both sweeps exit 1 for one reason only, `law index STALE: tests/LAWS.md`, which the main tree at
`7eb6f4b5` reads too (`python3 scripts/law_index.py --check`, rc 1, measured in the main tree); the patch carries the
regenerated file.

## 2. Switches (every law droppable alone; `R11U198_OFF` drops the whole pass)

| switch | law | file | grid |
|---|---|---|---|
| `R11U198_GSOWNER_OFF` | § genCaUnclonedFoldOwner198 | ExprEmit.cpp | cases/O (51) |
| `R11U198_VSARG_OFF` | § callArgVarSelStamp198 | ExprEmit.cpp | cases/V (31) |
| `R11U198_HOPSEL_OFF` | § genHopFoldSelName198 | ExprEmit.cpp | cases/N n01-n16 |
| `R11U198_OVRBOUND_OFF` | § ovrParamBoundOpSelName198 | ExprEmit.cpp | cases/N n17-n25 |
| `R11U198_MARGOP_OFF` | § methodArgOpRefChainName198 | ExprEmit.cpp (the design-final pass of § refFullNameThroughNamedExpr175) | cases/M (20) |
| `R11U198_LVCALLARG_OFF` | § lvIdxCallArgIsRead198 | ExprEmit.cpp (`emitExpr`'s entry guard beside § incDecSelCallArgRead194v) | cases/L (22) |
| `R11U198_CASTRHS_OFF` | § genCaCastRhsRefUnnamed198 | ExprEmit.cpp (`emitExpr`'s entry wrapper beside § idxCallPathAtDots191's) | cases/K (23) |

`R11U198_TRACE=<dir>` names every firing (one file per process, first line `OUT <-o path>`), the census's input.

**Switch checks** ([evidence/switchcheck.txt](evidence/switchcheck.txt), `drivers/switchcheck.sh`): each switch alone,
on every case of its grid where its law fires and no other law of the pass does, restores the pristine bytes, in both
forms: GSOWNER 25 + 26 (o41 fires both O and K: mixed), VSARG 22 + 20, HOPSEL 6 + 6, OVRBOUND 4 + 4, MARGOP 16 + 16,
LVCALLARG 18 + 18, CASTRHS 13 + 0 (the law is parse-form only). **`R11U198_OFF=1` writes the pristine bytes on all 170
grid cases in both forms** (`OFF=pristine` in every row of [evidence/grid.tsv](evidence/grid.tsv) and
[evidence/grid_elab.tsv](evidence/grid_elab.tsv)).

## 3. The laws

Every grid case is judged against a real pinned Surelog v1.87 golden in two forms: the probe form (`-parse -nobuiltin
-nocache -sv dut.sv` against `dut.sv --single-unit --nobuiltin`) and the `-elabuhdm` form (`ELAB=1`, `--elabuhdm` on
our side). Each case names its law on its first line.

### 3.1 § genCaUnclonedFoldOwner198 (`R11U198_GSOWNER_OFF`; refines § genForReplCountOwner192)

**Face** (pass 193's residue 2; the 14 probe cases of r11u115 / v11u115 it converts): a typed wildcard-imported package parameter
folded inside a generate scope's continuous assignment, `assign y[0] = {{W{1'b0}}, s};` in an if-generate: golden's
`ref_typespec` reads `work@top`, ours `work@top.g`; the same for a concatenation element `{s, W}`, a system-call
argument `q[fb] + $clog2(W)`, `$signed(W)`, `$countones(W)`, a case-generate.

**Decode.** CompileExpression.cpp's getValue substitutes the read by a clone of the owning instance's param_assign
Rhs, `result->VpiParent(param_ass)`, so the reader's chain name of its reference is the instance's. Two things
re-parent the clone: compileExpression's binary and ternary branches (`opL->VpiParent(operation)`,
`opR->VpiParent(operation)`) and its cast branch (`operand->VpiParent(operation)`) — the concatenation, replication,
unary (`paUnary_*`: `operands->push_back(operand)` with no re-parent) and system-call argument branches do not; and
UhdmWriter::writeCont_assign's `clone_tree` of the whole assignment when its Lhs is a ref_obj bindVariable finds and
its Rhs an operation (every object re-parented in the clone). Pass 192 measured only the whole-target if-generate
(its grid B b06 `y3`), which is the clone, and stated "an if / case generate scope keeps the scope name".

**Law.** In the elaborated top-level generate scope's continuous assignment (for, if, case), when the assignment is
not cloned (the target is a select, a member, a generate-local or implicit net that bindVariable does not find — the
committed model `caBoundLhsOpRhs17` — and the Rhs holds no unbased unsized literal, § psBoundPaOwnerName192's
re-clone), a stamped fold whose parent is a concatenation, a replication, a unary operator or a system call is named
by the owning instance (`ownerInstName192`). The for-generate replication count stays § genForReplCountOwner192's.

**Grid** cases/O (51 cases, both forms): converted o01 o02 o05 o06 o07 o08 o10 (depth 2, two instances) o13 o15 o20
o22 (depth 3) o23 o24 o27 (`int`) o28 (macro-born) o31 (else branch) o34 o38 o40 o41 o42 o43 o44 o48 o49 o50;
controls EQUAL on both binaries: o03 o04 o26 o33 o37 o39 (whole outside target: cloned), o14 o16 o35 o36 o45 o46
(binary / ternary / cast operand: re-parented), o17 (unbased unsized literal), o09 (nested generate: no fold), o21
(module scope), o29 (for-generate replication, pass 192's), o52 (a generate-local target with a module-body namesake)
and o53 (one with an ancestor-instance namesake): both cloned. Judge-unequal on both binaries, untouched: o11 o12
(a system call as the whole Rhs), o19 (a concatenation target), o32 (an untyped parameter), o47 (a nested system
call), o51 (a pattern). The `-elabuhdm` form reduces `-P`, `&P`, `!P` away whole on both sides (o42-o44 EQUAL at the
base there) and keeps `~P` with the owner-named clone (o15).

### 3.2 § callArgVarSelStamp198 (`R11U198_VSARG_OFF`; ibex_pmp d/t, map N0943)

**Face** (ibex_pmp's last record, `#13972 type`): `perm_check_wrapper(..., region_basic_perm_check[c][r])` in
`g_access_check[c].g_regions[r]`: golden's `var_select` actual carries a `ref_typespec` named after the select
(`work@ibex_pmp.g_access_check[0].g_regions[0].region_basic_perm_check`) bound to the formal's `logic` typespec
(ibex_pmp.sv 117:47-52); ours had none.

**Decode.** ExprEval::evalFunc binds every actual (`if (expr* exparg = reduceExpr(ioexp, ...))
exparg->Typespec(<formal typespec>)`); a multi-index select comes back unreduced like a part select and keeps the
stamp. Our argument stamp (`refArg`) listed ref_obj, bit_select, part_select and indexed_part_select only.

**Law.** A `var_select` actual takes the stamp like a bit select, named after the select (`argFull`), except where
golden leaves it bare: a call nested under an operation in the definition listing, in the `-elabuhdm` elaborated body
(its clone of the listing), and a select whose index list holds a range under an operation (`p[1][3:0]`).

**Grid** cases/V (31 cases, both forms): converted v01-v04 (v04 = the ibex_pmp shape) v05 v07 v11 v13 v15-v21 v25 v27
v28-v30 v32; controls v06 (a process: bare on both), v24 / v34 (a range index under an operation: bare), v26
(ternary). Left: v09 (a parameter-rooted select: golden stamps, `paramRootSel` excludes it), v22 (a bit_select under
an operation in the definition listing: the PRISTINE bit_select rule stamps it and golden does not; not this law's
object), v27's `-elabuhdm` form, v33 (a range index under an operation in a for-generate), v14 / v23 / v31
(judge-unequal on both).

### 3.3 § genHopFoldSelName198 (`R11U198_HOPSEL_OFF`; map N0443, arb_idx_cast's generate-scope records)

**Face** (map cluster N0443's probe cases: 13 convert, g5_hop95 and g18_hop_lhs narrow; arb_idx_cast `#322`...): a
localparam of the enclosing generate block read one hop down as a
bit-select index (`assign y[i] = a[L];` in `g[i].h`): golden's reference `work@top.g[0].h.a` (the select), ours
`work@top.g[0]` (the declaring scope).

**Law.** The one-hop fold of § genLpBitSelIdxOneHopFold67 (a bare bit-select index) and of
§ genLpIdxOpOperandFold112 (an operand of the index operation), and the same two positions of a `var_select`, carry a
reference named after the select; § genLpUseFoldParentScope47's select-BOUND positions keep the declaring scope (n04
n05 EQUAL on both binaries).

**Grid** cases/N n01-n16: converted n01 n02 n07 (inside a concatenation) n11 (if in if) n12 (`int`) n14 (a written
index); controls n04 n05 (bounds), n09 / n10 (distance 2 / 0: no fold), n16 (a module parameter in a top-level
generate block of the top instance). Judge-unequal on both: n03 n06 n08 n13 n15.

### 3.4 § ovrParamBoundOpSelName198 (`R11U198_OVRBOUND_OFF`; probe r10earl_repro/wf24, Rggen)

**Face** (wf24): an OVERRIDDEN port parameter read as an operand of a part-select bound operation in a child instance's
top-level generate block (`w[31:P+18]` in `u_c.g_r`): golden `work@wf24.u_c.g_r.w` (the select), ours
`work@wf24.u_c` (the `elabParamConst` copy's name drops two components of the prefix). The non-overridden parameter's
fold already names the select (n19).

**Law.** In that copy branch, a constant whose parent is an operation takes the select's name (`prefix`); a direct
bound keeps the instance's (n18's right bound).

**Grid** cases/N n17-n25: converted n17 n18 n21 (and n20 from 5 to 3 records); controls n19 n22 n23 n25. Left: n20's
direct indexed-part-select base in an if-generate (golden `work@top.u`, ours `work@top`) and n24's for-generate direct
bounds (golden the instance / the select, ours the generate scope): the fold branches of § genCaLoopSelIdxFold21, not
this copy.

### 3.5 § methodArgOpRefChainName198 (`R11U198_MARGOP_OFF`; map N0175 / N0217 / N0220, pass 195's R1)

**Face** (r11u191dec M/m01): `x = c.f(n, i + 1);` in a class method: golden names `i` `work@D::g::c.f::i`, ours the
scope's `work@D::g::i`; the direct argument `n` already reads the path name through § refFullNameThroughNamedExpr175.

**Decode.** Surelog stores no full name on these references; the reader's chain (UHDM BaseClass::ComputeFullName) runs
reference -> operation / system call (unnamed or skipped) -> method_func_call (skipped) -> hier_path.

**Law.** § refFullNameThroughNamedExpr175's design-final pass also takes a reference NESTED in such a call's argument
through operations and system calls, with that law's gates unchanged (inside a subroutine; ours must be the chain name
with ancestors dropped).

**Grid** cases/M (20 cases, both forms): converted m01 m03 (nested operations) m04 (unary) m05 (ternary) m06
(concatenation) m07 (a nested call: `work@D::g::c.f::c.f::i`) m10 (an array receiver) m12 (a system call inside the
operation) m14 (an interface function from a module function: `work@top.g.bus.f.i`) m15 (a package class) m17 m19 m20
m21; controls m08 (`this.`), m09 (`super.`), m11 (statement position). Left: m13 (a reference inside a path nested in
an operation argument, `s.substr(i, args[i].len() - 1)`), m02 / m16 (judge-unequal on both).

### 3.6 § lvIdxCallArgIsRead198 (`R11U198_LVCALLARG_OFF`; r11u194's N3)

**Face** (r11u194verify X/x05): `arr[fx(s.f[k])] <= 1'b1;` — the call argument inside the lvalue's index took the
lvalue shape (`s` 8:14-15, the member token); golden the read shape (`s` on its own token 8:12-13, a trailing select
at its index).

**Decode.** compileTfCallArguments (CompileHelper.cpp) compiles each argument afresh with compileExpression, outside
the Variable_lvalue branch; § incDecSelCallArgRead194v applied this to the inc/dec operand only.

**Law.** A call parent under a raised `inLhs` lowers it for the argument (an lvalue itself is never a call).

**Grid** cases/L (22 cases, both forms): converted l01 (nonblocking) l02 (blocking) l03 (compound) l04 (a nested
call) l05 (a system call) l06 (a plain select) l08 (an index operation) l11 (an indexed part-select base) l14 (a task)
l15 l16 (two calls) l19 (macros defined in ANOTHER root file, `args`) l20 (a macro from an `include`); l22 (a call
argument path two levels down, `t.f[fx(s.f[fx(s.f[k])])]`) goes from judge-unequal (NOT_EQUAL) to judge-equal with
N4's two names left; controls l09 (inc/dec, § incDecSelCallArgRead194v's), l18 (no call argument path), l23 (the same
call in an RVALUE index). Left: l12 (N4, section 7), l13 (section 8) and l21 (a streaming lvalue's call-argument
index: `depth(1)` on both binaries, a structural face of its own).

### 3.7 § genCaCastRhsRefUnnamed198 (`R11U198_CASTRHS_OFF`; map N0684, arb_idx_cast `#478` / `#548`)

**Face** (arb_idx_cast `assign index_nodes[Idx0] = idx_t'(sel);`, and 9 probe cases: r11u113 c19 c23 c24 c26 c28,
v11u113 t12, r10earl105 h1 h2, r10vearl118 v2_fenceface): golden's `ref_obj sel` reads no full name, ours
`work@dut.gen_levels[1].gen_level[0].gen_first_level.sel`.

**Decode.** writeCont_assign's `op->Typespec()` branch (the Rhs a cast, the Lhs not a found ref_obj) clones the
assignment and hands the clone the flattened operands WITHOUT re-parenting them
(`((operation*)rhs)->Operands(((operation*)tmp)->Operands())`), so the cast's operand subtree hangs off an operation
outside the tree: the reader's chain stops there. `ref_obj::GetVpiPropertyValue` returns no vpiFullName when the full
name equals the name, so `s` reads empty; a var_select's index reads `q.i`.

**Law.** Parse form only: in the elaborated generate-scope continuous assignment whose whole Rhs is an explicit cast
and whose target is not cloned by the ref_obj branch (`caBoundLhsOpRhs17` false), every reference / bit / part / var
select under the cast stores the chain name BELOW the cast (`chainNameBelow198`, ComputeFullName's skip rules). The
top cast's own typespec reference and a folded parameter constant (parented at its param_assign) keep their names.
Declined: a nested operation carrying a typespec reference (k19: golden's name is empty, which a stored name cannot
say) and any other object kind.

**The break the checks caught** (law13, probe `r11u74repro/grid/b3_rhskind` EQUAL -> `fullname(1)`, and grid O o52
under law13): a generate-local target whose NAME a module body declares (`r_cast` in `gb` and in the module) is found
by bindVariable and cloned; law13 read the ModuleEmit flags `genCaLhsSelect22 || genCaLhsGenLocal23` alone. Both
§ genCaUnclonedFoldOwner198 and this law now read the committed bind model `caBoundLhsOpRhs17` (ancestor-instance
namesakes included: probe r10earl98repro/g3_rhs98, which a law14 draft broke too); o52, o53, k22, k23 are the cells.

**Grid** cases/K (23 cases): converted k02 k04 k06 (a type parameter) k12 (if nested in for) k14 (generate-local) k15
(member) k16 (a concatenation with a var_select) k17 k20 (unary) k21 (part select); controls k01 k13 (module scope),
k03 k11 (a whole outside target), k07 (a cast nested in an operation), k22 k23 (namesakes), and every case's
`-elabuhdm` form (named on both sides). Left: k19 (declined), k10 (a typedef cast's `<in>t3` record), k05 k08 k09 k18
(judge-unequal on both).

## 4. The gates (`tests/sweep.sh --jobs 3`, all four stages, against the committed baselines at `7eb6f4b5`)

| gate | pristine `86812cac4e11` (`/tmp/r11u198_swP`) | law `180bbe38c02c` (`/tmp/r11u198_swL`) |
|---|---|---|
| (1) build | = the main tree's build (md5 above) | `7eb6f4b5` + this patch |
| (2) probe vs golden_probe.csv | EQUAL 3306 / STRICT_NOTEQUAL 781, `probe.csv` byte-identical to the baseline | EQUAL **3343** / 744: `regressions=0 conversions=37 changes=2` |
| (3) surelog vs golden_surelog.csv | `regressions=0 conversions=0 changes=0` (461+19 / 457+17) | `regressions=0 conversions=0 changes=0` |
| (3) uhdm2rtlil vs golden_uhdm2rtlil.csv | `regressions=0 conversions=0 changes=0` (793+10 both modes) | `regressions=0` **`conversions=2`** `changes=2`; 794+9 both modes |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | the same; `downstream.csv` byte-identical to the pristine sweep's; ibex_pmp and arb_idx_cast IDENTICAL |
| (5) uhdm-cmp | – | every mover keeps its judge status ([evidence/sweeps/movers_rows.txt](evidence/sweeps/movers_rows.txt): 16 corpus movers CMP_EQUAL / STRICT_NOTEQUAL, 40 probe movers EQUAL / STRICT_NOTEQUAL) |
| (6) byteverify (`SELFCHECK=1`, fence-free mirrors `fenced_skipped=8`) | | **16 / 2560 movers, every one predicted by name**; SELFCHECK 2559 / 2560 flagged ([evidence/sweeps/byteverify.txt](evidence/sweeps/byteverify.txt)) |
| probe / downstream-lane movers | | 40 / 4087 and 2 / 805, every one predicted |
| canaries | surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0 | surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS (ok=58) and `EXPECT_UNKNOWN=6` PASS (ok=2) |

## 5. The prediction and the attribution of every change

**The prediction** ([evidence/census/predicted_movers.txt](evidence/census/predicted_movers.txt), frozen `chmod 444`
before the law sweep): `drivers/census.sh` runs `law.bin` with `R11U198_TRACE` over every corpus row-mode but the
fenced four (the `--filter` built from the fence), every probe case and every downstream lane; `drivers/censum.py`
lists every database a law fired on: 21 corpus / downstream row-mode databases and 43 probe cases. The census's own
verdicts equal the law sweep's (probe 37 / 2, uhdm2rtlil 2 / 2, surelog 0, downstream csv byte-identical to the
pristine one).

| where | moved | predicted | predicted, not moved |
|---|---|---|---|
| corpus (2560 databases) | 16 | 18 | uhdm2rtlil mem2reg_test4 d/t: § lvIdxCallArgIsRead198 on `intermediate[depth2Index(1)]` — a constant argument, whose read and lvalue shapes coincide |
| probe (4087) | 40 | 43 | r11u46repro/grid2, v11u116repro/branches/g2_fcall, g2_sys: the same law on a parameter or constant argument |
| downstream lanes (805) | 2 (arb_idx_cast, ibex_pmp) | 3 | mem2reg_test4, as above |

Moved and not predicted: **0** in every population.

| row-mode / case | change | law, by the firing census and the per-law switch |
|---|---|---|
| ibex_pmp d/t | CONVERT | § callArgVarSelStamp198 (the only law firing: 8 records) |
| arb_idx_cast d/t | `endcol(17) -> endcol(3)` | § genHopFoldSelName198 (12 `ref_typespec` names, `#322`...) and § genCaCastRhsRefUnnamed198 (the two `ref_obj sel`, `#478` / `#548`); the three left are `#209`, `#360`, `#384` (section 8) |
| Earlgrey_0_1 d/t | bytes, cell unchanged (the walk diverges at its first records, 82 objects) | § genHopFoldSelName198 1995, § ovrParamBoundOpSelName198 31, § lvIdxCallArgIsRead198 4, § genCaCastRhsRefUnnamed198 96 (default only: the testflags command line has `-elabuhdm`); order-blind 12814 -> 8570 and 12306 -> 8316 ([evidence/orderblind_earlgrey.txt](evidence/orderblind_earlgrey.txt)) |
| Rggen d | bytes | § ovrParamBoundOpSelName198 56; order-blind 10771 -> 10659 |
| MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t, Scoreboard d, BuildUVMPkg d/t | bytes | § methodArgOpRefChainName198 (51, 50, 26, 26, 26 records); order-blind distances section 6 |
| 37 probe conversions | CONVERT | each by ONE law (the census file names the law per case): § genCaUnclonedFoldOwner198 14 (the r11u115 / v11u115 cases); § genHopFoldSelName198 13 (r11u112 g11-g14 g16 g17 g19-g21, v11u112 g1h g1j g1m, r10vearl95 v95a_ctx); § genCaCastRhsRefUnnamed198 9 (r11u113 c19 c23 c24 c26 c28, v11u113 t12, r10earl105 h1_head105 h2_child105, r10vearl118 v2_fenceface); § ovrParamBoundOpSelName198 1 (wf24) |
| probe g5_hop95 | `fullname(7) -> fullname(2)` | § genHopFoldSelName198 (5 records gone; the two left are child-instance hop names, R6) |
| probe g18_hop_lhs | `fullname(5) -> fullname(1)` | § genHopFoldSelName198 (4 gone; the one left is the definition listing's `ref_obj L`, R6) |
| probe r11u74repro/grid/b4_nonamesake | bytes, `type(1)` unchanged | § genCaCastRhsRefUnnamed198 on `q_cast` beyond the walk's divergence at `#418`; sorted-dump distance 247 -> 244 |

No count grows on a still-failing row.

## 6. Distances ([evidence/uvmdist.txt](evidence/uvmdist.txt) on the census, [evidence/uvmdist_lawsweep.txt](evidence/uvmdist_lawsweep.txt) on the law sweep: identical)

| row | pristine (swP) | law | delta |
|---|---|---|---|
| MiniAmiq d / t | 15963 | 15837 | −126 |
| SeqDriver d / t | 12337 | 12189 | −148 |
| SimpleUVM d / t | 4986 | 4886 | −100 |
| Scoreboard d | 3813 | 3737 | −76 |
| BuildUVMPkg d / t | 2035 | 1983 | −52 |
| ApbSlave d / t, SVSwitch d / t | 0, 102 | 0, 102 | 0 |
| Earlgrey_0_1 d / t | 12814 / 12306 | 8570 / 8316 | −4244 / −3990 |
| Rggen d | 10771 | 10659 | −112 |

The UVM pristine distances equal pass 195's after-values (its section 6), so the base is the one map 11 measured less
pass 195.

## 7. Ranked residues (this ground)

1. **R1 — N4, a call argument's index named through the OUTER lvalue path** (L/l12 `t.f[fx(s.f[k])] <= ...`: golden
   `work@top.t.f[].f.s.f[k].k`, ours `work@top.s.f[k].k`, § hpTrailSelIdxNamesByPath133's name): the reader's chain
   through the outer bit_select; a design-final chain pass like § refFullNameThroughNamedExpr175's would take it (the
   shape: a reference in a trailing select's index of a path that is a call argument inside an lvalue index).
2. **R2 — § methodArgOpRefChainName198's nested path** (M/m13, `s.substr(i, args[i].len() - 1)`: golden
   `work@D::g::s.substr::i`): the climb would have to pass the inner hier_path the index hangs off
   (§ hierPathSelIdxAtPath178); pass 195's R1 remainder.
3. **R3 — § genCaCastRhsRefUnnamed198's limits**: k19 (a nested cast's typespec reference reads NO name in golden:
   only an orphan parent can say it), k10 (the typedef cast's `<in>t3` record); a hier_path or a call inside the cast
   is declined.
4. **R4 — § ovrParamBoundOpSelName198's direct bounds**: n20 (an if-generate's direct indexed-part-select base, golden
   the instance, ours one component short), n24 (the for-generate child's direct bounds: golden the instance for a
   part select, the select for an ips base; ours the generate scope) — § genCaLoopSelIdxFold21's branches.
5. **R5 — § callArgVarSelStamp198's**: v09 (a parameter-rooted var_select is stamped in golden, `paramRootSel`
   excludes it), v22 (the PRISTINE bit_select rule stamps a call argument under an operation in the definition
   listing where golden is bare), v27 `-elabuhdm` (a unary over the call), v33.
6. **R6 — § genHopFoldSelName198's**: g18 (the definition listing's `ref_obj L` named through the Lhs select,
   `work@top.g.h.y.L`), g5_hop95 / v59v2_earl59 (child-instance hop names), the var_select index shapes n06 / n13
   (judge-unequal).
7. **R7 — pass 195's residues not reached**: UVM_MACRO_* reference names (ParamEmit `makeParamTs`), K/k12, `'{A:B.A}`,
   the ExprEval value faces (f1 c04 / c06, C/c03), T/t10, § funcCfgPatOpRefBare195's limits,
   § idxCallPathAtDots191's residues, the evaluator's e30 / e31 and G/g16 / g19.
8. **R8 — map 11's list not attempted**: struct_param_func_config's A half (N0045, N0675, N2412), cfg_func_width_loop,
   Scr1SvTests, Rggen N0145, BuildUVMPkg N0189, the UVM families N0097 / N0012 / N0034 / N0207 ..., BlackBePipeInt
   N0923, anon_struct_packed_dim N0820, FuncStructVal*, InterfArrayBind, a8_orphan, pass 184 / 187's carried faces.
9. **R9 — the 26 probe cases of map cluster N0739** (r11u108 pk/k10*, r11u111 f2/b*: `parameter s_t P = D; assign o =
   P;` with a struct-typed parameter): golden's ELABORATED `cont_assign` has NO Rhs at all (the walk reads `ref_obj o`
   where ours has `ref_obj P`). Observed, not decoded; the continuous-assignment emission is ModuleEmit's.
10. **R10 — § genCaUnclonedFoldOwner198 declines every whole outside-name target**; r11u199's
    § genForWholeLhsCallRootOwner199v (landed as `a015c911` while this pass ran) decodes that a whole-name assignment
    whose right-hand side ROOT is a system call is not cloned either, so a concatenation / system-call fold under such
    a root reads the owner too; not measured here (o12, the bare `$clog2(W)` root, is judge-unequal on both binaries).

## 8. Sister-ground faces met on the way (call sites; not edited here)

* **arb_idx_cast d/t `endcol(3)`** — the three records the row still needs, all TypeEmit: `#209` the elaborated
  `packed_array_var index_nodes`' folded range bound `2**NumLevels-2` spans golden's LEFT OPERAND `2**NumLevels`
  (15:10-15:22), ours its first token (15:10-15:11): TypeEmit `emitTypeParamArrayVar` (its `mkB`), pass 187's R3;
  `#360` / `#384` the type parameter `idx_t`'s default `logic_typespec` read by the elaborated variables, golden
  8:40-15:27, ours 8:40-8:60: TypeEmit `makeTypeParamDefaultTs` (map N0090's site, law typeParamDefaultBoundNoReduce20).
  With these the row converts (both modes).
* **L/l13** — the definition listing's generate-scope process `always @(posedge clk) arr[fx(s.f[k])] <= 1'b1;` spans
  the call `fx` at its name (8:31-33) where golden spans the call (8:31-41): the definition generate emission's
  expressions go through TypeEmit `emitSyntaxExpr`.
* **Earlgrey_0_1's next head** stays pass 195's `#90097` (its section 8, evidence/residue/Q there).

## 9. Files, and how to reproduce

- The patch `/tmp/r11u198.patch` = `git diff 7eb6f4b5` of `src/ExprEmit.cpp`, `src/EmitHelpers.h`, this directory
  and the regenerated `tests/LAWS.md`; it applies clean on a fresh `7eb6f4b5` and rebuilds `law.bin` byte for byte
  (measured: a fresh worktree `/tmp/wt_r11u198v` at `7eb6f4b5`, `git apply --check` clean, the build's md5
  `180bbe38c02c88d601e02c6671f01e7a`, `python3 scripts/law_index.py --check` current).
- **Integration note.** The main tree moved to `a015c911` (r11u199, the verification of passes 192 / 193) during this
  pass. On `a015c911` the patch's source and evidence hunks apply clean (`git apply --check --exclude=tests/LAWS.md`);
  `tests/LAWS.md` conflicts only because both regenerate it: re-run `python3 scripts/law_index.py` there. r11u199's
  ExprEmit change (§ genForWholeLhsCallRootOwner199v) sits in the for-generate replication and part-select bound branches
  this pass does not edit.
- `cases/<grid>/<case>/dut.sv` (170 cases; every case names its law in its first line): O, V, N, M, L, K. The drivers
  `mkgridO.py`, `mkgridV.py`, `mkgridN.py`, `mkgridM.py`, `mkgridL.py`, `mkgridK.py` write them; written by hand: N
  n18-n25, O o53, K k15 k22 k23, L l19 (`args` = `defs.sv dut.sv`) and l20 (`inc.svh`).
- `drivers/`: `env.sh` (pins, `$FENCED` fail-closed), `case.sh` (one case the way check_probe does; `ELAB=1` the
  `-elabuhdm` form; goldens cached per text md5 under `/tmp/r11u198_gold`), `judge.sh`, `grid.sh` (`OFFCHECK=1`:
  `R11U198_OFF=1` against pristine), `switchcheck.sh`, `foldnames.py` (the fold references' names side by side),
  `census.sh` + `censum.py` (the prediction), `bvmirror.sh`, `rowhead.sh`, `obrow.sh`, `obdist.sh`, `uvmdist.sh`,
  `det.sh` + `detob.sh` (the determinism control).
- `evidence/`: `grid.tsv`, `grid_elab.tsv`, `switchcheck.txt`, `census/predicted_movers.txt`, `sweeps/` (both sweep
  logs, the compare outputs, byteverify, the movers' fresh rows, the probe mover list), `uvmdist*.txt`,
  `orderblind_earlgrey.txt`, `determinism.txt`.

**The determinism control** ([evidence/determinism.txt](evidence/determinism.txt), `drivers/det.sh law.bin`: three
concurrent harness runs of `law.bin` over Earlgrey_0_1 and the five UVM rows, both modes): Earlgrey_0_1 one hash per
mode across the three runs, equal to the law sweep's (`899a9b821e15`, `8ad9eae9d68f`); the UVM rows draw the known
coin — the sorted uhdm-dumps of the three runs differ by 0 (order only: BuildUVMPkg, Scoreboard) or 4 lines (the
UINT / vpiDecompile coin: MiniAmiq, SeqDriver, SimpleUVM); SimpleUVM testflags one hash.

Reproduce: build `7eb6f4b5` and `7eb6f4b5` + the patch (system-deps config, `-j 2`), freeze them as
`/tmp/r11u198_bin/{pris,law}.bin`, `bash drivers/grid.sh` (`OFFCHECK=1`, and `ELAB=1`), `bash drivers/switchcheck.sh`,
`SLANG_UHDM=<law> bash drivers/census.sh <wd> <trace dir> <prefix>`, then `tests/sweep.sh --jobs 3 --workdir <wd>`
once per binary.

## 10. The grid (170 cases; parse form 93 converted, 0 regressed, 1 NOT_EQUAL case turned judge-equal (L l22); `-elabuhdm` form 72 converted, 0 regressed, the same l22; 170 of 170 pristine with the pass switched off in both forms)

| case | pristine (parse) | law (parse) | pristine (-elabuhdm) | law (-elabuhdm) |
|---|---|---|---|---|
| K/k01_module | EQUAL | EQUAL | EQUAL | EQUAL |
| K/k02_for_sel | STRICT_NOTEQUAL:fullname(2) | EQUAL | EQUAL | EQUAL |
| K/k03_for1_whole | EQUAL | EQUAL | EQUAL | EQUAL |
| K/k04_if_sel | STRICT_NOTEQUAL:fullname(1) | EQUAL | EQUAL | EQUAL |
| K/k05_for_castop | NOT_EQUAL | NOT_EQUAL | EQUAL | EQUAL |
| K/k06_for_tparam | STRICT_NOTEQUAL:fullname(2) | EQUAL | EQUAL | EQUAL |
| K/k07_for_nested | EQUAL | EQUAL | EQUAL | EQUAL |
| K/k08_for_signed | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| K/k09_for_proc | NOT_EQUAL | NOT_EQUAL | EQUAL | EQUAL |
| K/k10_for_typedef | STRICT_NOTEQUAL:fullname(4) | STRICT_NOTEQUAL:fullname(2) | STRICT_NOTEQUAL:fullname(2) | STRICT_NOTEQUAL:fullname(2) |
| K/k11_if_whole | EQUAL | EQUAL | EQUAL | EQUAL |
| K/k12_for_ifnested_tparam | STRICT_NOTEQUAL:fullname(2) | EQUAL | EQUAL | EQUAL |
| K/k13_module_sel | EQUAL | EQUAL | EQUAL | EQUAL |
| K/k14_for_genlocal | STRICT_NOTEQUAL:fullname(2) | EQUAL | EQUAL | EQUAL |
| K/k15_if_member | STRICT_NOTEQUAL:fullname(1) | EQUAL | EQUAL | EQUAL |
| K/k16_for_concat | STRICT_NOTEQUAL:fullname(8) | EQUAL | EQUAL | EQUAL |
| K/k17_for_bitsel | STRICT_NOTEQUAL:fullname(4) | EQUAL | EQUAL | EQUAL |
| K/k18_for_tern | NOT_EQUAL | NOT_EQUAL | EQUAL | EQUAL |
| K/k19_for_castcast | STRICT_NOTEQUAL:fullname(4) | STRICT_NOTEQUAL:fullname(4) | EQUAL | EQUAL |
| K/k20_for_unary | STRICT_NOTEQUAL:fullname(4) | EQUAL | EQUAL | EQUAL |
| K/k21_for_psel | STRICT_NOTEQUAL:fullname(6) | EQUAL | EQUAL | EQUAL |
| K/k22_for_genlocal_namesake | EQUAL | EQUAL | EQUAL | EQUAL |
| K/k23_ancestor_namesake | EQUAL | EQUAL | EQUAL | EQUAL |
| L/l01_nb_member | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l02_blk_member | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l03_compound | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l04_nestedcall | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l05_syscall | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l06_plainsel | STRICT_NOTEQUAL:col(2) | EQUAL | STRICT_NOTEQUAL:col(2) | EQUAL |
| L/l08_idxop | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l09_incdec_ctl | EQUAL | EQUAL | EQUAL | EQUAL |
| L/l11_ipsbase | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l12_memberlhs | STRICT_NOTEQUAL:col(6) | STRICT_NOTEQUAL:fullname(2) | STRICT_NOTEQUAL:col(6) | STRICT_NOTEQUAL:fullname(2) |
| L/l13_genscope | STRICT_NOTEQUAL:endcol(6) | STRICT_NOTEQUAL:endcol(2) | STRICT_NOTEQUAL:endcol(6) | STRICT_NOTEQUAL:endcol(2) |
| L/l14_task | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l15_callop_arg | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l16_two_args | STRICT_NOTEQUAL:col(8) | EQUAL | STRICT_NOTEQUAL:col(8) | EQUAL |
| L/l18_callidx_nocallarg | EQUAL | EQUAL | EQUAL | EQUAL |
| L/l19_macro_other_root | STRICT_NOTEQUAL:col(8) | EQUAL | STRICT_NOTEQUAL:col(8) | EQUAL |
| L/l20_macro_include | STRICT_NOTEQUAL:col(4) | EQUAL | STRICT_NOTEQUAL:col(4) | EQUAL |
| L/l21_stream_lvalue | STRICT_NOTEQUAL:depth(1) | STRICT_NOTEQUAL:depth(1) | STRICT_NOTEQUAL:depth(1) | STRICT_NOTEQUAL:depth(1) |
| L/l22_two_level | NOT_EQUAL | STRICT_NOTEQUAL:fullname(2) | NOT_EQUAL | STRICT_NOTEQUAL:fullname(2) |
| L/l23_rvalue_idx_ctl | EQUAL | EQUAL | EQUAL | EQUAL |
| M/m01_cls_binop | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m02_mod_binop | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| M/m03_cls_nestedop | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m04_cls_unary | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m05_cls_ternary | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| M/m06_cls_concat | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| M/m07_cls_nestedcall | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m08_cls_this | EQUAL | EQUAL | EQUAL | EQUAL |
| M/m09_cls_super | EQUAL | EQUAL | EQUAL | EQUAL |
| M/m10_cls_arrrecv | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(3) | STRICT_NOTEQUAL:fullname(2) |
| M/m11_cls_stmt | EQUAL | EQUAL | EQUAL | EQUAL |
| M/m12_cls_sysinop | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m13_cls_builtin_nested | STRICT_NOTEQUAL:fullname(1) | STRICT_NOTEQUAL:fullname(1) | STRICT_NOTEQUAL:fullname(1) | STRICT_NOTEQUAL:fullname(1) |
| M/m14_iface | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| M/m15_pkg | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m16_mod_nestedop | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| M/m17_cls_cmp | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m19_cls_inif | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| M/m20_cls_localop | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| M/m21_cls_propop | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| N/n01_bitidx_bare | STRICT_NOTEQUAL:fullname(4) | EQUAL | STRICT_NOTEQUAL:fullname(4) | EQUAL |
| N/n02_bitidx_op | STRICT_NOTEQUAL:fullname(4) | EQUAL | EQUAL | EQUAL |
| N/n03_psel_bound | NOT_EQUAL | NOT_EQUAL | EQUAL | EQUAL |
| N/n04_ips_base | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n05_ips_width | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n06_varsel_idx | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| N/n07_bitidx_incat | STRICT_NOTEQUAL:fullname(4) | EQUAL | STRICT_NOTEQUAL:fullname(4) | EQUAL |
| N/n08_proc | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| N/n09_dist2_ctl | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n10_dist0_ctl | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n11_ifif_bare | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| N/n12_int_bitidx | STRICT_NOTEQUAL:fullname(4) | EQUAL | STRICT_NOTEQUAL:fullname(4) | EQUAL |
| N/n13_varsel_op | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| N/n14_lhs_idx | STRICT_NOTEQUAL:fullname(4) | EQUAL | STRICT_NOTEQUAL:fullname(4) | EQUAL |
| N/n15_psel_bound_op | NOT_EQUAL | NOT_EQUAL | EQUAL | EQUAL |
| N/n16_modparam_topgen | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n17_child_modparam | STRICT_NOTEQUAL:fullname(1) | EQUAL | EQUAL | EQUAL |
| N/n18_child_direct_bound | STRICT_NOTEQUAL:fullname(1) | EQUAL | EQUAL | EQUAL |
| N/n19_child_opbound_noov | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n20_child_ips | STRICT_NOTEQUAL:fullname(5) | STRICT_NOTEQUAL:fullname(3) | STRICT_NOTEQUAL:fullname(3) | STRICT_NOTEQUAL:fullname(3) |
| N/n21_child_opbound_rhsop | STRICT_NOTEQUAL:fullname(1) | EQUAL | EQUAL | EQUAL |
| N/n22_child_bitidx_op | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n23_child_nested_bounds | EQUAL | EQUAL | EQUAL | EQUAL |
| N/n24_child_for_bounds | STRICT_NOTEQUAL:fullname(2) | STRICT_NOTEQUAL:fullname(2) | STRICT_NOTEQUAL:fullname(2) | STRICT_NOTEQUAL:fullname(2) |
| N/n25_child_modscope_bounds | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o01_for_sel_catelem | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o02_if_sel_sysarg | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o03_if_whole_catelem | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o04_for1_whole_sysarg | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o05_for_genlocal_catelem | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o06_if_implicit_catelem | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o07_if_member_catelem | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o08_case_sel_repl | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o09_nested_sel_catelem | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o10_depth2_twoinst | STRICT_NOTEQUAL:fullname(4) | EQUAL | STRICT_NOTEQUAL:fullname(4) | EQUAL |
| O/o11_if_sel_sysdirect | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| O/o12_if_whole_sysdirect | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| O/o13_for_sel_catinplus | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o14_for_sel_plusincat | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o15_for_sel_unaryincat | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o16_for_sel_castincat | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o17_for_sel_uu | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o18_if_whole_cast | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o19_if_lhsconcat | NOT_EQUAL | NOT_EQUAL | STRICT_NOTEQUAL:col(2) | STRICT_NOTEQUAL:col(2) |
| O/o20_for_sel_sysincat | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o21_module_sel_catelem | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o22_depth3 | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o23_for_sel_ternarm_sys | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o24_for_sel_signedincat | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o26_for1_whole_repl | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o27_if_sel_int | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o28_for_sel_macro | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o29_for_sel_replbits | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o31_else_sel_catelem | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o32_if_sel_untyped | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| O/o33_if_whole_sysarg | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o34_for_sel_countones | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o35_if_sel_ternarm | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o36_if_sel_shift | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o37_if_whole_ternsys | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o38_for_genlocal_sysarg | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o39_if_whole_replonly | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o40_if_sel_catcat | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o41_for_sel_castwhole | STRICT_NOTEQUAL:fullname(4) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o42_for_sel_negincat | STRICT_NOTEQUAL:fullname(2) | EQUAL | EQUAL | EQUAL |
| O/o43_for_sel_redincat | STRICT_NOTEQUAL:fullname(2) | EQUAL | EQUAL | EQUAL |
| O/o44_if_sel_notincat | STRICT_NOTEQUAL:fullname(1) | EQUAL | EQUAL | EQUAL |
| O/o45_for_sel_eqincat | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o46_for_sel_ternconds | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o47_for_sel_sysnested | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| O/o48_for_sel_concatrepl2 | STRICT_NOTEQUAL:fullname(2) | EQUAL | STRICT_NOTEQUAL:fullname(2) | EQUAL |
| O/o49_case_sel_sysarg | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o50_if_genlocal_ternsys | STRICT_NOTEQUAL:fullname(1) | EQUAL | STRICT_NOTEQUAL:fullname(1) | EQUAL |
| O/o51_for_sel_patwhole | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| O/o52_for_genlocal_namesake | EQUAL | EQUAL | EQUAL | EQUAL |
| O/o53_ancestor_namesake | EQUAL | EQUAL | EQUAL | EQUAL |
| V/v01_mod_unpacked2d | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v02_mod_packed2d | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v03_genfor_genvar | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v04_gen2_ibex | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v05_mod_inop | STRICT_NOTEQUAL:type(1) | EQUAL | EQUAL | EQUAL |
| V/v06_proc | EQUAL | EQUAL | EQUAL | EQUAL |
| V/v07_nested | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v09_param_root | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) | NOT_EQUAL | NOT_EQUAL |
| V/v11_second_arg | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v13_nda | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v14_portconn | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| V/v15_pkgfunc | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v16_depth2 | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v17_genif | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v18_genfor_whole | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v19_mod_var3 | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v20_genfor_sel | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v21_gen2_localarr | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v22_mod_inop_bitsel | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) |
| V/v23_mod_inop_ref | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| V/v24_mod_inop_psel | EQUAL | EQUAL | EQUAL | EQUAL |
| V/v25_genfor_inop | STRICT_NOTEQUAL:type(1) | EQUAL | EQUAL | EQUAL |
| V/v26_mod_tern | EQUAL | EQUAL | EQUAL | EQUAL |
| V/v27_mod_notop | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) |
| V/v28_mod_psel_whole | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v29_mod_varidx | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v30_genfor_exprIdx | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v31_mod_ips_whole | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL | NOT_EQUAL |
| V/v32_mod_ipsarg | STRICT_NOTEQUAL:type(1) | EQUAL | STRICT_NOTEQUAL:type(1) | EQUAL |
| V/v33_genfor_inop_psel | STRICT_NOTEQUAL:type(1) | STRICT_NOTEQUAL:type(1) | EQUAL | EQUAL |
| V/v34_mod_inop_ips | EQUAL | EQUAL | EQUAL | EQUAL |
