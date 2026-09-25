# r11u163 — the expression/parameter ground of the strict axis: ten laws on parameter typespec copies, 18 row-modes converted

Base `202fb296` (branch matrix-1.87). Ground: `src/ParamEmit.cpp`, `src/ExprEmit.cpp`, `src/EmitHelpers.h`
(`src/StmtEmit.cpp` untouched). No edit to `TypeEmit.cpp`, `ModuleEmit.cpp`, `UhdmExporter.cpp`, `TaskFuncEmit.cpp`,
`uhdm_main.cpp` or `include/`. The faces whose fix sits there stop at the decode (section "Sister-ground faces").
Net binding is not touched. The laws of passes 140/145/147/154/158, r11u151, r11u157 and the
r11u141/149/153/154v/158v/159/162 refinements are not edited: every law here is a new site or a new branch under
its own switch. Worktree `/tmp/wt_r11u163`, system-deps config, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base; byte-identical to the main tree's `build/slang-uhdm`) | `2ba43a59d99989d17d1e556880efa269` |
| law (this patch; `law12` in the scratch naming) | `75d81015e32bf4686f665c16b31eaa84` |
| `build/uhdm-strictcmp` (= the main tree's) | `5d4617d0458f34aa79e0b91009d5d1fc` |
| `strictcmp_raw` (drivers/mkstrictraw.sh: the same comparison, the raw full name printed next to the canonical one; measurement only) | `933595297e21c137fec1857344a3fa8c` |
| pristine built with `-g1` (gdb pins only; a `git archive` of the base) | not a gate binary |

Every binary was frozen (`chmod 555` copies under `/tmp/r11u163_bin`) before it was measured. The pristine sweep
(`/tmp/r11u163_swP`) and the law sweep (`/tmp/r11u163_swL`) have workdir names of the same length. In the law sweep all
3273 corpus `cmds.txt` slang lines name the law copy; in the pristine sweep all 3273 name the pristine copy. The
pristine sweep reads `regressions=0 conversions=0 changes=0` in all three stages against the committed baselines,
its `probe.csv` is byte-identical to `results/golden_probe.csv`, and its downstream stage reads 803 IDENTICAL / 66
SLANG_REJECT / 2 EQUIVALENT (evidence/sweep_pristine_vs_baselines.txt). Its only red is `law index STALE` (the
worktree's abbreviated hashes); the regenerated tests/LAWS.md in this patch clears it.

**The fence.** No binary, gdb run, script or reader touched a slang-fenced test's source or database outside the
gate sweeps. The firing census (drivers/census.sh) refuses to run without `$FENCED` and dispatches the corpora with
`--filter '^(?!(<the four>)$)'` ("fenced mentions: 0" on every run). The row readers drivers/rowrec.sh, allrec.sh,
moverdiff.sh and predict.py refuse to run without `$FENCED` and refuse or skip a fenced name. The scratch copies of
corpus sources used to decode (StructUnsizedVal, LargeValue2Struct, ParamNoImport, ParamTypespec2, FuncIoTypespec,
the uhdm2rtlil tests type_param_override_elem_sel, param_array_wildcard, gen_scope_numports,
struct_param_pattern_packing, iface_zero_width_field, and a reduced openmsp430 shape) are none of the fenced four. A
grep of this directory for the four names reads 0.

## Result

| axis | base (committed = pristine sweep) | law | delta |
|---|---|---|---|
| surelog strict-equal (CMP_EQUAL of 954 judge-equal row-modes) | 855 | **865** | +10 |
| uhdm2rtlil strict-equal (of 1606) | 1508 | **1516** | +8 |
| probe EQUAL (of 4087) | 2529 | **2580** | +51 |
| judge-equal scoreboards (uhdm-cmp) | 480/3 + 474/3, 803/1/67 both modes | same | every row keeps its uhdm-cmp status |
| downstream (871 rows) | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT | same | the law sweep's downstream.csv is byte-identical to the pristine sweep's (0 of 871 rows differ) |

**CONVERSIONS (STRICT_NOTEQUAL -> CMP_EQUAL; results/ untouched, the landing re-baselines them).** The fresh csv rows
of the law sweep (evidence/sweep_law_vs_baselines.txt):

    surelog:
      FuncIoTypespec,default,CMP_EQUAL,,,equal                      § fnParamRangeNetNoFile163            (was differ:file(9))
      FuncIoTypespec,testflags,CMP_EQUAL,,,equal                    (same)
      LargeValue2Struct,default,CMP_EQUAL,,,equal                   § elabAggFoldYCopyDefNamed163         (was differ:fullname(4))
      LargeValue2Struct,testflags,CMP_EQUAL,,,equal                 (same)
      ParamNoImport,default,CMP_EQUAL,,,equal                       § ovPkgPatOpInstanceCopy163           (was differ:fullname(2))
      ParamNoImport,testflags,CMP_EQUAL,,,equal                     (same)
      ParamTypespec2,default,CMP_EQUAL,,,equal                      § pkgPatListingCopyWhenShared163 + § importPatOpCloneParamNamed163 (was differ:fullname(3))
      ParamTypespec2,testflags,CMP_EQUAL,,,equal                    (same)
      StructUnsizedVal,default,CMP_EQUAL,,,equal                    § elabAggFoldYCopyDefNamed163         (was differ:fullname(2))
      StructUnsizedVal,testflags,CMP_EQUAL,,,equal                  (same)
    uhdm2rtlil:
      gen_scope_numports,default,CMP_EQUAL,,,equal                  § elabTpDefaultDefNamed163            (was differ:fullname(4))
      gen_scope_numports,testflags,CMP_EQUAL,,,equal                (same)
      param_array_wildcard,default,CMP_EQUAL,,,equal                § elabOvArrFoldSharesDefParamTs163    (was differ:fullname(1))
      param_array_wildcard,testflags,CMP_EQUAL,,,equal              (same)
      struct_param_pattern_packing,default,CMP_EQUAL,,,equal        § paramOpCloneRelocatedSpan163        (was differ:line(1))
      struct_param_pattern_packing,testflags,CMP_EQUAL,,,equal      (same)
      type_param_override_elem_sel,default,CMP_EQUAL,,,equal        § elabTpNamedElemDimDefNamed163       (was differ:fullname(1))
      type_param_override_elem_sel,testflags,CMP_EQUAL,,,equal      (same)
    downstream (fresh rows of the law sweep, IDENTICAL as before):
      gen_scope_numports,IDENTICAL,NO_GATES,NO_GATES,0,0,,
      param_array_wildcard,IDENTICAL,OK,OK,19,19,,
      struct_param_pattern_packing,IDENTICAL,OK,OK,51,51,,
      type_param_override_elem_sel,IDENTICAL,OK,OK,3,3,,

**Probe: 51 cases go `STRICT_NOTEQUAL -> EQUAL`, 32 change, 0 regress** (evidence/sweep_changes_by_law.txt names the
laws that fired on each). The conversions: § elabTpNamedElemDimDefNamed163 33, the two type-parameter laws jointly
11, § elabTpDefaultDefNamed163 alone 1, § elabAggFoldYCopyDefNamed163 5 (the r11u108 pk `k10h`, `k10i`, `k23*`
cases), § elabOvArrFoldSharesDefParamTs163 1 (`r10earl102repro/g4_neg102`). The 32 changes:
* 15 § elabAggFoldYCopyDefNamed163 (r11u108 pk `k10*`, r11u111 f2 `b03`, `b06`, `b07`, `b13`, `b14`, v11u111
  `x22`): `differ:fullname(6) -> differ:name(2)`, the six fullname records leave and two name records that were
  already there become the first field;
* 10 § aggParamFoldQualSpanByView163 (r11u108 pk `k10e`, `k11`, r11u111 f2 `b04`, `b05`, `b08`, `b10`, `b11`,
  `b12`, `b17`, v11u111 `x26`): `differ:endcol(3) -> differ:name(2)`, the qualified fold's span records leave;
* 2 § importPatOpCloneParamNamed163 (`r11u114repro/grid/f1/a28` fullname(4) -> type(1), `v11u114repro/grid/set1/g25`
  fullname(3) -> type(1)): the fullname records leave and a walk divergence already there becomes first;
* 5 type-parameter count decreases or first-field moves later (`r11u20repro/t6`, `r11u110repro/grid/e1/e25_ovr_same_ctl`,
  `e45_pkg_enum_ovr`, `v11u110repro/brk/v3/a36_escaped_inst_name`, `v11u93b107repro/brk/r05_rt_ovr_samename`).

Every probe mover was attributed record by record against its golden (drivers/pdiff.sh,
evidence/probe_movers_records.txt): **0 records enter on all 99 movers**; 83 lose records, 16 are record-neutral.

## Targeted rows (brief items), before -> after

| row | before | after | law / what is left |
|---|---|---|---|
| (1)/(4) R-SP StructUnsizedVal d/t (N0005) | fullname(2) | **CMP_EQUAL** | § elabAggFoldYCopyDefNamed163 |
| (1)/(4) R-SP LargeValue2Struct d/t (N0005) | fullname(4) | **CMP_EQUAL** | § elabAggFoldYCopyDefNamed163 |
| (1) R-SP struct_param_pattern_packing d/t (N0043) | line(1) | **CMP_EQUAL** | § paramOpCloneRelocatedSpan163 |
| (1) ParamNoImport d/t (N0003) | fullname(2) | **CMP_EQUAL** | § ovPkgPatOpInstanceCopy163 |
| (1) N1132 iface_zero_width_field d/t | fullname(4) | fullname(4) | residue 3: the elaborated package listing's flattened copy of an UNPACKED struct pattern is named by the reading module (`work@top.p::bus_t.CTL`) |
| (1) N0472 param_array_wildcard d/t | fullname(1) | **CMP_EQUAL** | § elabOvArrFoldSharesDefParamTs163 (the distinguisher: the elaborated Rhs is the definition's typespec, as every other elaborated Rhs; not a naming rule) |
| (1) N0472 type_param_override_elem_sel d/t | fullname(1) | **CMP_EQUAL** | § elabTpNamedElemDimDefNamed163 (the distinguisher: a TYPE parameter's written default in force, section "Laws") |
| (1) N0472's sibling gen_scope_numports d/t | fullname(4) | **CMP_EQUAL** | § elabTpDefaultDefNamed163 |
| (1) FuncIoTypespec d/t (N0016) | file(9) | **CMP_EQUAL** | § fnParamRangeNetNoFile163 (the def-vs-elab grid: the net is minted once, in the definition, and every elaborated function shares it; grid fn) |
| (4) ParamTypespec2 d/t | fullname(3) | **CMP_EQUAL** | § pkgPatListingCopyWhenShared163 + § importPatOpCloneParamNamed163 |
| (1) LocalScopeHierPath t | fullname(1) | fullname(1) | residue 1: under `--elabuhdm` golden's foreach index `j` has no stored full name (UHDM's ElaboratorListener computes `...::path.slices[j].spath::j`); ours keeps a stored one |
| (1) R2/R3/R6/R8/R9 (UVM rows, line(94..187)) | — | unchanged | not reachable as row conversions; not worked (residue 8) |
| (1) gl/l4, ev/e16, hl/h3 | — | unchanged | not worked (residue 8) |
| (4) N0129 YosysOldOpen t | fullname(4) | fullname(4) | sister S1 (ModuleEmit `substNdaParamRefs`), decoded below |
| (4) N1115 PackedArrayHighConn d/t | fullname(6) | fullname(6) | sister S5 |
| (4) N0427 InterfArrayBind d | fullname(3) | fullname(3) | not reached (the elaborated default view, pass 154 residue 1a) |
| (4)/(5) HierPathTypespec t (N1174) | fullname(1) | fullname(1) | sister S4: the member actual is reached through the array typedef's element; golden's element is a copy of `a` parented under `b` (`pkg::pkg::b::pkg::a::x`), ours the typedef `a` itself |
| (4) N0822 HighLow, N0739 ComplexParamOverload, MacroArgMismatch | — | unchanged | ModuleEmit / the location model (report only, as briefed) |
| (4) N1063 / N1064 / N0357 / N0063 (pass 154) | CMP_EQUAL | CMP_EQUAL | confirmed (bytes of every CMP_EQUAL row are covered by the byte verifier; no CMP_EQUAL row moved) |
| (2) ComplexHierPath d/t | col(7) | col(7) | the def-view generate path (TypeEmit emitSyntaxExpr, r11u157's R1), sister |
| (3) GenIfIfaceParamStructField d/t | col(2) | col(2) | sister S3: the definition-view generate-if cont_assign's hier_path (TypeEmit emitSyntaxExpr) |

## Laws (each under its own switch; `R11U163_OFF=1` drops all of them; `R11U163_TRACE=1` prints one stderr line per firing)

Sites are named by function and § token (`grep -n '§ <law>' src`). The switch table is the r11u163 block at the end of
src/EmitHelpers.h. Every law was decoded on purpose-built goldens of the pinned Surelog (the grids below), with the
pristine and law databases compared by `uhdm-strictcmp` and by `strictcmp_raw`, whose raw full names show the
object identity the canonical comparison excuses.

### § elabAggFoldYCopyDefNamed163 (`R11U163_AGGFOLDYNAME_OFF`; ParamEmit.cpp emitParameters, the Y-clone branch of § pkgRefFoldClonesMultiDimOnly140)
An elaborated struct/union parameter whose default is an UNQUALIFIED read of a package parameter (`s_t P = X` after a
wildcard import) clones Y's folded constant and Y's typespec (pass 140's law). Golden names that typespec copy
through the parameter's DEFINITION: StructUnsizedVal `Init = InitDefault` has member references
`work@dut.pkg::init_t.key` and `work@dut.pkg::init_t.key.key`, LargeValue2Struct `work@top.pack::scrmbl_key_init_t.key`.
Ours used the package's own names (`pkg::init_t.key`), which the strict comparator's copy canonicalisation cannot
excuse because no golden copy carries them there. Only the name moves: the copy keeps Y's shape and package stamps.
Two alternatives were measured and refuted: binding the definition parameter's own typespec object (law2) and the
elaborated parameter's own clone (law3) both turn LargeValue2Struct NOT_EQUAL at stage 1 (`sp/s02`: the member
typespec's `vpiInstance` and name differ, `sram_key_t` against `pack::sram_key_t`). A qualified `pkg::X` read keeps
the package names (it is not the Y-clone branch's struct case; `sp/s03`, `sp/s10`). Cases: `sp/s01` (StructUnsizedVal),
`sp/s02` (LargeValue2Struct), `sp/s04` (two instances). Stage-1 residues on both binaries: `sp/s05` (a pattern-valued
Y), `sp/s06` (union), `sp/s07`, `sp/s08`, `sp/s09` (the parameter read by a continuous assignment or in an interface).

### § aggParamFoldQualSpanByView163 (`R11U163_AGGQUALSPAN_OFF`; ExprEmit.cpp emitExpr, the aggregate package-parameter fold beside § aggParamFoldUnqualWholeSpan158; EmitHelpers.h paramRhsView163)
The fold of a QUALIFIED aggregate package-parameter read in a parameter default (`P = pkg::X`) is located by view. The
ELABORATED listing spans the whole written reference when the fold is a constant: golden `pkg::XLONGNAME` 8:37-51,
`pkg ::  XLONGNAME` 8:37-54 (ours the package name + 2, 8:37-42). The DEFINITION listing spans the qualifier through
its `::` token as written (`pkg ::` 8:37-43; the name + 2 read 8:37-42). A pattern or cast fold keeps the qualifier
in the elaborated listing too (probe `r11v55repro/grid/vv1c_cast` and `r11u1repro/grid2`, which the first cut, law6,
moved away from golden: `7:64-67` against `7:64-74`; the law was narrowed to constant folds, law7 onward). Only the
emitParameters Rhs branch sets the view (paramRhsView163: 1 definition, 2 elaborated). Cases: `sp/s03`, `sp/s10`,
`sp/s11`.

### § elabOvArrFoldSharesDefParamTs163 (`R11U163_OVARRDEFTS_OFF`; ParamEmit.cpp emitParameters, the overridden unpacked vector-array fold)
The elaborated Rhs of an overridden unpacked vector-array parameter (`.DAM({{17'bx, ...}, ...})`, folded to one BIN
constant) refers to the DEFINITION parameter's `array_typespec`, as every other elaborated Rhs does (the
shareDefParamTs note in patchParamTypespecs; bound in drainShareDefParamTs). Golden param_array_wildcard names the
bound inside it `work@decoder.DAM.IFN`; ours bound this instance's clone (`work@param_array_wildcard.u.DAM.IFN`).
This is N0472's second face: no naming distinguisher exists because the object is the definition's. Cases:
`oa/o01` (param_array_wildcard), `oa/o04` (in a generate loop). Controls: `oa/o03` (literal bounds, equal on both).
Stage-1 residue on both binaries: `oa/o02` (two instances, different widths).

### § ovPkgPatOpInstanceCopy163 (`R11U163_OVPATCOPY_OFF`; ParamEmit.cpp emitParameters, the untyped formal overridden by a package pattern parameter; helper copyPatOp163)
An untyped instance parameter overridden with a package struct-pattern parameter (`#(.PWR_AST_RSP(pkg::PWR_AST_RSP_DEFAULT))`)
takes a COPY of the package's pattern operation, parented at the instance's param_assign, whose typespec reference is
named by the instance (golden ParamNoImport `ref_typespec (work@dut.t)`). Ours shared the package's operation: the
instance's reference read `pkg`, and the package listing's own operation, being shared into a module listing, was
kept out of § pkgPatReadTsNoParent131 (golden's is unnamed). A constant operand is copied (golden's copy owns its
operands: with a second instance the walk lists them again, `pi/p03`, which read `STRICT_NOTEQUAL count` with a
shared operand list, law5); any other operand is shared. Cases: `pi/p01` (ParamNoImport), `pi/p03` (two instances),
`pi/p04` (nested), `pi/p06` (read by a continuous assignment). Stage-1 residues on both binaries (same uhdm-cmp head):
`pi/p02` (unqualified override through an import), `pi/p05` (a positional pattern).

### § pkgPatListingCopyWhenShared163 (`R11U163_PATLISTCOPY_OFF`; ParamEmit.cpp drainShareDefParamTs, the § pkgPatReadTsNoParent131 package loop)
A package pattern parameter's operation that ALSO stands in a module listing (our substitution of `pkg::P` in a
high-conn replication shares the package's object) is no longer left alone by § pkgPatReadTsNoParent131: the PACKAGE
listing takes a copy with the unnamed, unparented reference (copyPatOp163), and the use keeps the original. Golden
ParamTypespec2 `.a({3{prim_esc_pkg::ESC_TX_DEFAULT}})`: the package listing's operation has an unnamed ref_typespec,
ours `prim_esc_pkg`. Cases: `pi/p07` (ParamTypespec2, with § importPatOpCloneParamNamed163), `hc/g01`. Controls:
`hc/g03` (a continuous assignment; the law does not fire). Residues: `hc/g02` (a direct `.a(pkg::D)` connection: the
operation's location, not this law; unchanged), `hc/g04` (stage 1 on both), `pi/p08` (iface_zero_width_field,
residue 3).

### § importPatOpCloneParamNamed163 (`R11U163_IMPOPNAME_OFF`; ParamEmit.cpp mintParamOpClones and patchParamTypespecs' opClone branch)
The struct copy an elaborated IMPORT copy's pattern operation carries (`import prim_esc_pkg::*`, `ESC_TX_DEFAULT =
'{...}` materialized in nmi_gen) is named through the PARAMETER: golden
`work@top.u_nmi_gen.ESC_TX_DEFAULT.prim_esc_pkg::esc_tx_t.esc_p`, ours dropped the parameter
(`work@top.u_nmi_gen.prim_esc_pkg::...`), the module-scoped name a module's OWN pattern parameter keeps (r11u131 grid
pat t12/t13; `ic/i03` is equal on both). An import copy is a package-scoped symbol in the module/interface queue.
Cases: `ic/i01`, `ic/i02` (interface body import), `pi/p07`. Residue: `ic/i04` (two records leave; a walk
divergence already there stays).

### § paramOpCloneRelocatedSpan163 (`R11U163_OPCLONERELOC_OFF`; ParamEmit.cpp opCloneRelocSpan163, called from mintParamOpClones and patchParamTypespecs' opClone branch)
The struct copy an elaborated parameter's pattern operation carries is located where the package's shared typedef
object was last re-located. A package struct typedef named as a package subroutine argument's type has its shared
typespec moved to that argument's type reference (Surelog's last-writer stamp, the relocation block at the end of
ParamEmit emitPackage); Surelog's elaboration clones that object. Golden struct_param_pattern_packing `parameter
p::cfg_t CFG = p::LIT` with `function automatic logic in_region(cfg_t C, ...)` in `p` puts the operation's `p::cfg_t` at
21:38-43 (the formal's `cfg_t`), ours at the typedef 8:11-11:4. Cases: `rl/q01`. Controls: `rl/q02` (no subroutine),
`rl/q04` (a return type does not relocate). Residue: `rl/q03` (the same relocated span on the DEFINITION listing's
parameter copies of an unqualified import: residue 4).

### § elabTpNamedElemDimDefNamed163 (`R11U163_TPDIMDEF_OFF`; ParamEmit.cpp emitParameters, the § typeParamNamedElemPackedDim31 elaborated wrapper)
The references in the written dimension of an elaborated type parameter's named-element wrapper (`localparam type
rt_t = id_t [DEPTH-1:0]`, the default in force) are named through the DEFINITION, as the definition listing names
them: golden type_param_override_elem_sel reads `work@child.rt_t.DEPTH` under instance `u`'s variable `rt_i`, ours
`work@dut.u.rt_t.DEPTH`. Surelog elaborates the definition's own typespec (the `compileParameterDeclaration` object)
and re-resolves only the element. Cases: `nd/n01` (type_param_override_elem_sel), `nd/n04` (one overridden and one
default instance), `nd/n05` (the bound parameter overridden), `nd/n06` (in a generate loop).

### § elabTpDefaultDefNamed163 (`R11U163_TPDEFNAME_OFF`; ParamEmit.cpp emitParameters, the elaborated type parameter's `makeTypespec(tps)` branch)
The same naming for the elaborated type of a type parameter whose DECLARATION DEFAULT is in force (the instance does
not override it): golden gen_scope_numports `parameter type data_t = logic [DataWidth-1:0]` reads
`work@tc_sram_wrapper.data_t.DataWidth` under every elaborated `i_tc_sram_wrapper`, ours the instance path. Cases:
`nd/n03` (gen_scope_numports), `nd/n08`. Control: `nd/n07` (one default and one overridden instance: equal on both).
Stage-1 residue on both: `nd/n09` (an anonymous struct default).

### § fnParamRangeNetNoFile163 (`R11U163_FNPNETFILE_OFF`; ExprEmit.cpp fnLocalParamRangeActual)
The implicit wire minted for a subroutine-local parameter read in a subroutine variable's range (UhdmWriter
lateBinding's lookup-miss branch) takes § implicitNetMintNoFile131's rule: the four span fields and no file on a
DEFINITION's wire. Golden FuncIoTypespec `reg [len-1:0] result` in `function fshl_u_1` (`parameter len = ...` local to
the function): `logic_net (work@shift.len) 28:11-28:14` with no file, ours `dut.sv`. The brief's def-vs-elab
question: the net is minted ONCE, in the definition module, and every elaborated function that reads it shares it
(gdb: one `MakeLogic_net` from fnLocalParamRangeActual, called from TaskFuncEmit under the definition's
emitModuleDef), so ParamEmit's end-of-export pass clears the one object and leaves any elaborated module's net alone
as before. Cases: `fn/f01` (FuncIoTypespec), `fn/f03` (two instances), `fn/f04` (`localparam`), `fn/f05` (an io_decl
range). Stage-1 residue on both: `fn/f02` (a task).

## Census (the predictions) and the movers

The census (drivers/census.sh + tracewrap.sh) ran on the law binary BEFORE the law sweep, through the harness, with
the fence filter. It predicts **347 names**: 27 surelog row-modes, 56 uhdm2rtlil row-modes and 264 probe cases, each
listed with the laws that fired on it (evidence/predicted_movers.tsv; drivers/predict.py). Every law's every branch
traces (§ aggParamFoldQualSpanByView163's definition branch traces only when its span differs from the old one; the
two type-parameter laws trace only when their object is built).

Byte verifier (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, law `/tmp/r11u163_swL` against pristine
`/tmp/r11u163_swP`, names of the same length):

| stage | paths | selfcheck | movers | predicted | unpredicted |
|---|---|---|---|---|---|
| surelog | 960 identical sets | 959/960 | 31 | 25 | **6: MiniAmiq, SeqDriver, SimpleUVM d/t** — the UINT/vpiDecompile order coin |
| uhdm2rtlil | 1608 identical sets | 1607/1608 | 40 | 40 | 0 |
| probe (every database compared) | 4087 | — | 99 | 99 | 0 |

The six unpredicted movers are the known coin: the path-normalised uhdm-dump diff is 4 lines, one constant's
`vpiDecompile` and `UINT` (MiniAmiq default: 693 in the law sweep, 1488 in the pristine sweep, and 1254, 641, 806 in
three census runs of law binaries whose code does not reach it), order-blind count 4 on all six.

Every corpus mover was attributed record by record (drivers/moverdiff.sh, evidence/corpus_movers_records.txt): **0
records enter on all 71 movers**. The 18 conversions lose their records (the laws quoted beside them above). The
other 53 are record-neutral:
* the six coin rows (MiniAmiq, SeqDriver, SimpleUVM d/t);
* § importPatOpCloneParamNamed163 on rows whose strict walk already diverges before the renamed copies
  (BlackBePipeInt d/t, Earlgrey_0_1 d/t, ibex_branch_predict, ibex_compressed_decoder, ibex_decoder, ibex_icache,
  ibex_multdiv_fast, ibex_multdiv_slow, ibex_pmp, ibex_tracer, ibex_wb_stage d/t: each keeps its strict verdict) and on
  CMP_EQUAL rows where the renamed copy is one the comparator's copy canonicalisation already paired (GenScopeHierPath,
  IndexedSelectHex, MultiConcatValueSize, ParamElabMulti, ParamNoSubst, PAssignType, BitSelectOfParameterPassedTo-
  SubmoduleInGenFor and its OfSubmodule twin, ff_dead_both_branches, ff_dead_guarded_reset, ibex_alu,
  struct_param_repl_count; each stays CMP_EQUAL);
* § elabTpDefaultDefNamed163 on param_name_collision_typeparam (stays CMP_EQUAL).
No CHANGE in either corpus, and every downstream verdict is byte-for-byte the pristine sweep's.

## Gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `2ba43a59…` = main tree; law `75d81015…` |
| (2) tests/sweep.sh --corpus probe | regressions=0, conversions=51, changes=32; EQUAL 2580 STRICT_NOTEQUAL 1507, every case judge-equal |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 10 + 8; changes 0 + 0 |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66; not identical and not excused=0; downstream.csv byte-identical to the pristine sweep's; the four targeted uhdm2rtlil rows read IDENTICAL (quoted above) |
| (5) uhdm-cmp on touched rows | every mover keeps its judge-equal status (0 regressions in all three stages); every grid case keeps its uhdm-cmp verdict, and the stage-1 cases keep their head (evidence/grid_pristine_vs_law.txt) |
| (6) byteverify | 31 + 40 corpus movers and 99 probe movers, all attributed; all but the six coin rows predicted by name (18 predicted corpus row-modes did not move) |
| canaries | r11u107repro/canaries.sh: surelog ok=50 changed=2 (FuncIoTypespec d/t, the conversion), uhdm2rtlil ok=16 changed=0 (pristine: 52/0 and 16/0); ctcan2.sh EXPECT_UNKNOWN=1 surelog ok=58 changed=0 PASS, EXPECT_UNKNOWN=6 uhdm2rtlil ok=2 changed=0 PASS |
| cases | 48 cases (evidence/grid_pristine_vs_law.txt): 27 go to STRICT_EQUAL, 6 are equal on both (controls), 15 stay (residues named above; 11 of them stage 1 on both binaries), and no case loses judge-equality |
| switches | each switch alone returns its own cases to the pristine verdict (evidence/switches.txt) |
| `R11U163_OFF=1` | 223 of 223 cases (these 48, the 74 r11u158 and the 101 r11v158 cases) byte-identical to pristine (evidence/offbytes.txt) |

## Sister-ground faces (decoded; the fix sits in a file this pass does not own)

S1 — YosysOldOpen t (N0129) `fullname(4)`: `wire reg_sel = per_en & (per_addr[13:DEC_WD-1] == BASE_ADDR[14:DEC_WD]);`
in an elaborated instance. The part-select bound constant substituted for `DEC_WD` carries a ref_typespec named
`work@openMSP430.clock_module_0` in golden and `...clock_module_0.BASE_ADDR` in ours. The select's base is a
PARAMETER here: the net base `per_addr` two operands earlier is named through the select in both. Reproduced by a
seven-line module (both `-elabuhdm` and not). Site: ModuleEmit.cpp `substNdaParamRefs`, the
`rt->VpiFullName(!selFull.empty() && !paAnchor ? selFull : ...)` line (gdb pin: `MakeRef_typespec` <-
ModuleEmit.cpp:33270 <- 33149/33162 on the base).

S2 — StructArrayNet d/t `fullname(2)`: `mod m(.struct_i(struct_array[sel]))`. The high conn's bit-select index `sel`
is `work@dut.m.sel` in golden in both listings; ours `work@dut.m.struct_i.sel` (definition) and `work@dut.sel`
(elaborated). The prefix is ModuleEmit's port high-conn emission (`hcPrefix`).

S3 — GenIfIfaceParamStructField d/t `col(2)`: the definition-view generate-if cont_assign `assign sub.rsp_sel =
sub.sel` (hier_path elements' spans and names), TypeEmit.cpp emitSyntaxExpr (r11u157's R1).

S4 — HierPathTypespec t (N1174) `fullname(1)`: `c[1].x` with `typedef a[5:0] b`: golden binds `x` to the member of a
copy of `a` parented under `b` (`pkg::pkg::b::pkg::a::x`); ours to `a`'s own member. The array typedef's element
copy is TypeEmit's.

S5 — PackedArrayHighConn d/t (N1115) `fullname(6)`: the enum typedef's base ref_typespec in the module's import copies
named `work@prim_pad_wrapper...` in golden, `work@dut...` in ours (TypeEmit/ModuleEmit), and a high conn's
bit_select full name (ModuleEmit port emission).

S6 — UnsizedParam d `fullname(2)` (249 against 244 objects): `assign a = int'(Y)` onto an implicit net in
`u_sub_default`: golden's elaborated cont_assign is the instance's own (`work@top.u_sub_default.a`), ours shares the
definition's (`work@submodule.a`). ModuleEmit emitContAssigns' implicit-net-LHS sharing block.

S7 — YosysBigSimEllip d `type(1)`: `assign C[195:194] = 0;` in `func3` deep in the hierarchy; ours lists eight fewer
objects and the walk meets our Rhs constant where golden has the Lhs part_select (a cont_assign missing or
reordered in ModuleEmit's elaborated listing). Not decoded further.

## Decoded, not landed (ranked residues on this ground)

1. LocalScopeHierPath t `fullname(1)`: under `--elabuhdm` golden's foreach index `j` inside `path.slices[j].spath`
   has an empty stored full name, which UHDM computes from the parent chain
   (`pack::uvm_mem_mam::check_reg::path.slices[j].spath::j`); ours stores `...::check_reg::j`. The default mode is
   equal. The rule (which of our stored names golden leaves empty after its ElaboratorListener clone) is not
   decoded: `clone_tree.cpp` `hier_path::DeepClone` re-binds but never writes a full name.
2. iface_zero_width_field d/t `fullname(4)` (N1132): the elaborated package listing's operation of an UNPACKED struct
   pattern parameter (`B = '{CTL:0, DAT:8, STS:0}`, read as `B.CTL` inside the package's own typedefs) has an
   unnamed reference in golden (ours `p`) and a struct copy named by the reading MODULE (`work@top.p::bus_t.CTL`,
   ours `p::B.p::bus_t.CTL`). The flattening Surelog's getValue runs happens in the reading module's context.
   § pkgPatReadTsNoParent131 excludes unpacked structs on purpose; widening it needs that naming decoded (`pi/p08`).
3. The relocated span on the DEFINITION listing's parameter copies (`rl/q03`: `import p::*; parameter cfg_t CFG =
   LIT` with a relocating subroutine: golden locates the import copy's and the module parameter's struct at the
   formal, 8:32-37; ours at the typedef). § paramOpCloneRelocatedSpan163 covers the elaborated operation copy only.
4. `hc/g02`: a package pattern parameter connected directly (`.a(pk::D)`) locates the high conn operation at the
   package declaration (4:21-40) in golden, at the reference (7:36-41) in ours.
5. Stage-1 shapes the grids found on both binaries: `sp/s05` (pattern-valued Y), `sp/s06` (union), `sp/s07`-`s09`
   (a struct parameter read by a continuous assignment / in an interface), `pi/p02`, `pi/p05`, `oa/o02`, `nd/n09`,
   `fn/f02`, `hc/g04`.
6. r11u157's R2/R3 and R6/R8/R9 remainders, gl/l4, ev/e16, hl/h3 (pass 158's residues 1, 5, 7, 8, 10): not worked in
   this pass; none of them converts a row by itself (the UVM rows are line(94..187) with other heads).

## Cases (first line of every case names its law; pristine / law verdicts in evidence/grid_pristine_vs_law.txt)

| grid | cases | law | pristine -> law |
|---|---|---|---|
| sp | s01 s02 s04 | § elabAggFoldYCopyDefNamed163 | fullname -> STRICT_EQUAL |
| sp | s05 s06 s07 s08 s09 | § elabAggFoldYCopyDefNamed163 (stage-1 residues) | NOT_EQUAL -> NOT_EQUAL |
| sp | s03 s10 s11 | § aggParamFoldQualSpanByView163 | endcol -> STRICT_EQUAL |
| oa | o01 o04 | § elabOvArrFoldSharesDefParamTs163 | fullname -> STRICT_EQUAL |
| oa | o03 | § elabOvArrFoldSharesDefParamTs163 (control) | equal -> equal |
| oa | o02 | § elabOvArrFoldSharesDefParamTs163 (stage-1 residue) | NOT_EQUAL -> NOT_EQUAL |
| pi | p01 p03 p04 p06 | § ovPkgPatOpInstanceCopy163 | fullname -> STRICT_EQUAL |
| pi | p02 p05 | § ovPkgPatOpInstanceCopy163 (stage-1 residues, same head) | NOT_EQUAL -> NOT_EQUAL |
| pi | p07 | § pkgPatListingCopyWhenShared163 (+ § importPatOpCloneParamNamed163) | fullname -> STRICT_EQUAL |
| pi | p08 | § pkgPatListingCopyWhenShared163 (residue 2) | fullname -> fullname |
| hc | g01 | § pkgPatListingCopyWhenShared163 | fullname -> STRICT_EQUAL |
| hc | g03 | § pkgPatListingCopyWhenShared163 (control) | equal -> equal |
| hc | g02 g04 | § pkgPatListingCopyWhenShared163 (residue 4, stage 1) | unchanged |
| ic | i01 i02 | § importPatOpCloneParamNamed163 | fullname -> STRICT_EQUAL |
| ic | i03 | § importPatOpCloneParamNamed163 (control) | equal -> equal |
| ic | i04 | § importPatOpCloneParamNamed163 (2 records leave, walk divergence stays) | fullname -> type |
| rl | q01 | § paramOpCloneRelocatedSpan163 | line -> STRICT_EQUAL |
| rl | q02 q04 | § paramOpCloneRelocatedSpan163 (controls) | equal -> equal |
| rl | q03 | § paramOpCloneRelocatedSpan163 (residue 3) | line -> line (one record leaves) |
| nd | n01 n04 n05 n06 | § elabTpNamedElemDimDefNamed163 | fullname -> STRICT_EQUAL |
| nd | n03 n08 | § elabTpDefaultDefNamed163 | fullname -> STRICT_EQUAL |
| nd | n07 | § elabTpDefaultDefNamed163 (control) | equal -> equal |
| nd | n09 | § elabTpDefaultDefNamed163 (stage-1 residue) | NOT_EQUAL -> NOT_EQUAL |
| fn | f01 f03 f04 f05 | § fnParamRangeNetNoFile163 | file -> STRICT_EQUAL |
| fn | f02 | § fnParamRangeNetNoFile163 (stage-1 residue) | NOT_EQUAL -> NOT_EQUAL |

## Ops notes (disclosed)

* Twelve law binaries were built in turn (law1 the first cut of the span and array laws, law2/law3 the two refuted
  bindings of the Y copy, law4 the naming law, law5/law6 the instance copy, law7 + the type-parameter law and the
  narrowed span law, law8 + the default-type law, law9 + the relocated span, law10 + the import-copy naming, law11 +
  the package-listing copy, law12 + the function-local net). Censuses ran on law8, law11 and law12 (the prediction);
  the gate sweep ran on law12 only. Every census reads regressions=0 against the baselines.
* The -g1 pristine (`/tmp/r11u163_gsrc`, a `git archive` of the base) served gdb pins only: the Y-clone branch
  (emitParameters < emitInstance), the overridden-array fold, the named-element wrapper and its `MakeRef_obj` mints,
  the function-local net mint, and the S1 site.
* No process I did not start was touched.

## Files

* drivers/grid.sh (one case: golden + ours + uhdm-cmp + uhdm-strictcmp), gridall.sh, switches.sh, offbytes.sh.
* drivers/census.sh + tracewrap.sh (the firing census, fence-filtered), predict.py (the predicted mover set).
* drivers/rowrec.sh, allrec.sh, moverdiff.sh (fence-guarded row readers), pdiff.sh (probe case record diff),
  mkstrictraw.sh (the raw-name comparator variant).
* evidence/: the files named above.
