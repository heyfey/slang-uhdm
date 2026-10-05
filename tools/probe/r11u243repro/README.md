# r11u243 — module/type ground: the `this` wire, the imported-parameter copies, LAW S for `string`, the class property alias, the specialization param_assign file

Pass 243 (PAIR B refill after pass 241), base `f984159f`, worktree `/tmp/wt_r11u243`. Ground: `src/TypeEmit.cpp`,
`src/ModuleEmit.cpp`, `src/UhdmExporter.cpp`, `src/TaskFuncEmit.cpp`, `uhdm_main.cpp`. This pass touches
`src/TypeEmit.cpp`, `src/ModuleEmit.cpp`, `src/UhdmExporter.cpp` and adds `src/R243.h` (switches + `R11U243_TRACE`).

Seven laws, each behind its own switch; `R11U243_OFF` drops all of them (pristine bytes on 50 of 50 case-views and on
all 9 corpus movers, `evidence/off_corpus_movers.txt`). `R11U243_TRACE=<dir>` writes `<dir>/<pid>.243`: `OUT <-o path>`
then one `<law> <detail>` line per write (`thisNetSurelogAnchor243_abstain` / `_why` lines write nothing).

Binaries (`evidence/binaries.txt`): pristine `38df1270940e81dbce1addeef4d0e2ab` (byte-identical to the main tree's
build at the base), law `0fa327fd1592d945bab39b2926928080`; both link slang 12.0.0+545f88b2e; every cmds.txt of both
sweeps names its own frozen binary (`evidence/cmds_audit.txt`, 3265 + 3265 after the fence filter).

## Verdicts per targeted row (before -> after; no corpus row converts)

| row-mode | base | after | first record after |
|---|---|---|---|
| SimpleUVM d/t | `differ:file(2)` #75684 / #75696 | `differ:type(1)` #98800 / #98812 | #75684 (the `work@top.this` wire, golden uvm_object.svh 902:36-40 with no file, ours uvm_component.svh 1767:16-20 with the file) cleared by § thisNetSurelogAnchor243 + § thisNetNoFile243; #80745 (the class `work@env`'s copy of `uvm_pkg::UVM_RADIX = 'hf000000`: golden lists the copy's constant, ours shared the package's) cleared by § clsImpUnsizedBasedRhsCopy243 (+ § unitImpPaRhsOwnCopy243 for the design's own copies); the first record moves #75684 -> #98800. Next: the cast target of `uvm_severity'(severity)` in `uvm_pkg::m__uvm_report_dpi` (uvm_globals.svh 168:15): golden `enum_typespec uvm_pkg::uvm_severity`, ours `unsupported_typespec uvm_severity` — ExprEmit § dpiExportedPkgSubBareOwnTdUnsupported170 degrades it where SimpleUVM's golden resolves it, **ground A** (sister face 1) |
| BuildUVMPkg d/t | `differ:file(8)` #81827 | `differ:file(7)` #81827 | same first record (ground A, StmtEmit foreach `begin` with no location); one of the 8 differing objects cleared: a class property's LAW-S alias name (§ clsPropLawSAliasName243 is the only law firing on the row, 15 times) |
| Scoreboard d | `differ:fullname(3)` #81633 | `differ:fullname(2)` #81633 | same first record (ground A, ExprEmit hier_path naming); #84633 cleared: the `uvm_analysis_imp #(int, my_scoreboard)` specialization's `param_assign` for T, golden `110:31-110:32` with no file, ours with `uvm_analysis_port.svh` (§ clsPropSpecPaNoFile243) |
| MiniAmiq d/t | `differ:fullname(4)` #71388 | `differ:fullname(4)` #71388 | unchanged verdict and first record (ground A, StmtEmit); bytes moved toward golden only (away 0, toward 111 per mode) |
| SeqDriver d/t | `differ:fullname(4)` #71344 / #71356 | `differ:fullname(4)` #71344 / #71356 | unchanged verdict and first record (ground A); bytes moved toward golden (away 0, toward 58 per mode), among them SeqDriver's own `work@top_tb.this` wire (golden 902:36-40 no file at records #147919 / #348485 / #413604, pristine uvm_component.svh 1767:16-20, law equal) |

Fresh csv rows (law sweep, `evidence/sweep_L_surelog.csv`):

    SimpleUVM,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)
    SimpleUVM,testflags,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)
    BuildUVMPkg,default,STRICT_NOTEQUAL,differ:file(7),,differ:file(7)
    BuildUVMPkg,testflags,STRICT_NOTEQUAL,differ:file(7),,differ:file(7)
    Scoreboard,default,STRICT_NOTEQUAL,differ:fullname(2),,differ:fullname(2)
    MiniAmiq,default,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)        (testflags the same)
    SeqDriver,default,STRICT_NOTEQUAL,differ:fullname(4),,differ:fullname(4)       (testflags the same)

**SEVENTEEN PROBE CONVERSIONS** (STRICT_NOTEQUAL -> EQUAL, results/ untouched; `evidence/sweep_L_probe.csv`):
`r10uvm219repro/g219_a_order`, `g219_b_interleave`, `g219_c_thisfirst`, `g219_d_ownmulti` (file(3), § thisNetNoFile243);
`r10uvm23repro/t34g_t` (file(1), § clsPropSpecPaNoFile243); `r10uvm201repro/g201_f_kinds`, `r10v146repro/v05_second_pkg`,
`v11_unref`, `v15_twofile_a`, `r10v199repro/v199_d_ifprog`, `v199_f_multi`, `v199_g_uvmshape`, `r10v201repro/v201_c_localparam`,
`v201_h_ifprog`, `v201_j_nested` (fullname, § unitImpPaRhsOwnCopy243); `r10uvm207repro/g207_g_class`, `r10uvm61repro/v1_pkgparam`
(fullname, § clsPropLawSAliasName243). Five probe CHANGES, every one a shrink on the same field:
`r10uvm201repro/g201_a_forms` value(7) -> value(2), `g201_c_uvmshape` value(20) -> value(10), `g201_e_explicit` value(4) ->
value(2), `r10uvm210repro/g210_e_unitimp` value(6) -> value(2), `r10uvm67repro/c5_clone` value(3) -> value(2) (all
§ unitImpPaRhsOwnCopy243: the design copies' constants now listed).

## The laws

### § thisNetSurelogAnchor243 (`R11U243_THISANCHOR_OFF`; TypeEmit thisImplicitNetBoth38)
WHICH bare `this` the module's implicit `this` wire (§ thisImplicitNetBoth38) is located at. The old anchor was the
minimum of (VpiFile string, line, column): a total order, not Surelog's. Surelog mints the wire at the FIRST
unresolved `this` of the module's late-binding list (`UhdmWriter::lateBinding`); that list is the imported packages'
lists spliced in IMPORT order (`CompileHelper::importPackage`), a package's own list filled by `CompilePackage`'s
collect passes: functions and tasks in the flattened text order, constructors (`compileClassConstructorDeclaration`,
the OTHER pass) after all of them, the rule § hoistPoolSourceOrder240 reads for the property pool. LAW: the anchor is
the hit with the least (import rank of its home package in the module's listing, constructor body, include-expanded
position of the body's declaration, line, column). A package the module does not import itself is a file-scope
import and ranks first (decode `decode/th_unitimp`: golden puts the wire at the file-scope package's function, 16:20,
over the module import's; several file-scope packages tie and fall to the next keys). A hit whose routine has no
symbol abstains for the whole wire. The wire's place in the listing keeps the old anchor's key (§ hoistedThisRidesTheForwardedBlock219
is not re-derived). Cases TH t01 (a constructor first: golden 14:20, the first
function), t02 (constructors only: the first), t03 (two headers included against their names' order: golden zz.svh
6:18), t04 (a task first), t05 (two `this` in one body), t06 (a `this` in a macro body), t07 / t10 (the first IMPORTED
package wins, in t10 even with only a constructor), t08 (beside the module's own `$dumpvars` scope name), t09 (CRLF).

### § thisNetNoFile243 (`R11U243_THISNOFILE_OFF`; same site)
The wire is a late-binding mint like every other: `UhdmWriter::lateBinding` copies the four span fields of the
unresolved reference and never sets vpiFile (§ implicitNetMintNoFile131's rule). Golden writes no file on it in every
case. Cases TH (all ten), probe r10uvm219repro g219_a..d (the four conversions), SimpleUVM and SeqDriver.

### § clsImpUnsizedBasedRhsCopy243 (`R11U243_CLSIMPUNSIZED_OFF`; ModuleEmit importPaCopy82)
§ classImportParamOwnRefs183 copies the right-hand constant of a class's inherited import `param_assign` but refused an
unsized based literal (`'hf000000`), noting golden's copy as "the un-adjusted compile, not modelled". Decoded: golden's
copy carries exactly the package constant's fields (vpiSize -1, `HEX:f000000`, vpiConstType 5, the literal's span) and
a typespec reference named by the class with NO actual — what the package's own constant holds. Sharing listed it
once, under the package, so the class's param_assign listed no constant (SimpleUVM #80745: `constant` against
`parameter UVM_RADIX` at depth 6). LAW: the literal is copied like any other constant; on an UNTYPED parameter (the Lhs
has no typespec) its size is -1 and its reference has no actual, made even where the source constant has none (the
decode case `decode/ur_u04_modcls`: `'d3`); a TYPED parameter's literal keeps the adjusted 32 and the type (UR u02
`parameter int unsigned C = 'h7`). Cases UR u01 (the SimpleUVM shape, both views now STRICT_EQUAL), u02 (value kinds:
type(1) -> value(2), the next record is a module copy's folded value, below), u03 (a class in a package).

### § unitImpPaRhsOwnCopy243 (`R11U243_UNITIMPRHS_OFF`; UhdmExporter designImportPaCopy146)
The design's copies of a `$unit`-imported package's param_assigns (§ unitImportHoistsPkgParams146) shared the
package's right-hand constant. Surelog's `clone_tree` gives each its own constant, whose typespec reference has an
EMPTY full name (the design has no scope name; golden u01 `ref_typespec ""` under both design param_assigns, the
package's own reading `p`). Once the class copies stopped sharing the constant (above) the design's param_assign
listed none. LAW: a constant right-hand side is copied, its reference unnamed and bound to the source's actual; the
unsized-literal rule of the class branch applies. Cases UR u01, u02; probe r10v146 / r10v199 / r10v201 / g201 (eleven
conversions and five shrinks above); SimpleUVM and Scoreboard (45 copies per row-mode).

### § lawSStringTd243 (`R11U243_LAWSSTRING_OFF`; TypeEmit bareScalarTypedefVarTs / bareScalarTdCopyOfFresh16)
A package typedef of `string` is a LAW-S kind: golden writes a bare `string_typespec (str_t)` with a Typedef_alias
back at the listing object for a class property, a function formal, local and return in the home package, a module
variable and a module-function local, and an importing package's property and function, exactly the positions LAW S
measured for the integral kinds; ours bound the qualified listing object `p::str_t` (stage 1 at the base on every
case). Pass 240's sister face 4 / pass 238's residue (3)(b). Cases TS s01-s05 (s02-s05 STRICT_EQUAL in both views
under this law; s01 with § clsPropLawSAliasName243), LS l01. No corpus database fires it.

### § clsPropLawSAliasName243 (`R11U243_CLSPROPALIAS_OFF`; UhdmExporter exportDesign, after § lawSCopyHomeInstance36)
A CLASS PROPERTY's LAW-S copy is its own object, parented at the property, and its Typedef_alias reference is named by
the property: golden `p::b::m_al::str_t` / `p::b::m_i::i_t` (the property's full name, then the bare typedef name),
where the memoized copy LAW S shares with every other binder names it `str_t` / `i_t`. The strict comparator reads it
as content whenever golden names the copy one way only (the property is the only binder). Design-final, walking the
classes in listing order (design, packages, modules) so the minted objects are deterministic. Pre-existing for the
integral kinds (the decode `x3`: `typedef int i_t; class b; i_t m_i;` fullname(1) at the base). Cases TS s01, LS l01-l04
(l02 / l04 STRICT_EQUAL before and after: the copy shared with a function local is excused by the comparator, the
bytes move), probe g207_g_class / v1_pkgparam (conversions), BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard
(15 properties per row-mode).

### § clsPropSpecPaNoFile243 (`R11U243_PROPSPECPANOFILE_OFF`; UhdmExporter emitClassPropSpecParams163)
A class property's specialization listing (§ classPropSpecForeignPkgHome163) gives a data-type argument's
`param_assign` the formal's span by `pass->VpiLineNo(fparam->VpiLineNo())` (CompileType.cpp's
`compileDatastructureTypespec`), line and columns only, NO file: the rule § classSpecPaNoFile152 transcribes for the
typedef'd specialization. Scoreboard #84633 (`uvm_analysis_imp #(int, my_scoreboard) m_imp;`, golden 110:31-110:32,
no file). Cases CP c01 (another package's holder, two arguments), c02 (the Scoreboard shape in `$unit`), c03 (the
generic in an included header); probe r10uvm23repro/t34g_t (conversion).

## Measurements

* **Grid** (`evidence/grid.txt`, `evidence/gridsum.txt`; `drivers/grid.sh`): 25 cases in both views (50
  case-views) on 10 configurations (pristine, law, law + `R11U243_OFF`, law + each of the 7 switches): 500 lines,
  every line with its exit code, every exit code 0. `R11U243_OFF` == pristine on 50 of 50; 43 case-views enter
  STRICT_EQUAL, none leaves it or uhdm-cmp equality; the 7 that do not enter: UR u02 d/t (type(1) -> value(2), a
  module import copy's value, below), UR u03 `_el`, LS l02 and l04 d/t (STRICT_EQUAL on both binaries, bytes moved).
  Each switch reverts only its own cases: THISNOFILE 20, THISANCHOR 10 (t01, t03, t07, t09, t10), LAWSSTRING 12,
  CLSPROPALIAS 14, CLSIMPUNSIZED 6, PROPSPECPANOFILE 6, UNITIMPRHS 4 case-views.
* **Decode cases** (`decode/`, `evidence/decode_grid.txt`): 11 cases in both views on pristine and law (44 lines, the
  exit codes as pristine: 4 on the `tf_*` unsupported-property cases on both binaries, 0 elsewhere); every one stage
  1 on both binaries with the same uhdm-cmp line count.
* **Downstream on the cases** (`evidence/dscase_*.txt`, `drivers/dscase.py`): 25 of 25 IDENTICAL on both binaries;
  every law fires under the downstream flags (`evidence/dscase_law_firings.txt`: the positive control of the lane
  census).
* **Census and prediction, frozen before the law sweep** (`drivers/census.sh`, `drivers/dscensus.py`,
  `drivers/predict.py`, `evidence/predict.txt` md5 `cb505874eb3c192dd90542ecefc53a1f`): 40 predicted movers, 31 probe
  cases and 9 corpus row-modes, 0 downstream lanes (871 lanes run with the downstream flags, 0 fenced dispatched).
* **Gate sweeps** (`tests/sweep.sh --jobs 3`, workdirs `/tmp/r11u243_wP` and `/tmp/r11u243_wL`;
  `evidence/sweep_{P,L}_*`): pristine reproduces every baseline (probe 3481 + 606, surelog 469/11 + 465/9 with 0
  changes, uhdm2rtlil 803 + 0 per mode, downstream 803/66/2/0). Law: probe EQUAL 3498 + STRICT_NOTEQUAL 589,
  **regressions=0 conversions=17 changes=5**; surelog **regressions=0 conversions=0 changes=5** (the five rows above);
  uhdm2rtlil regressions=0 conversions=0 changes=0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0
  DIVERGENT, the verdict column equal to pristine's row for row. Both sweeps exit 1 only on the law-index staleness
  check (the new cases; `tests/LAWS.md` regenerated in the patch).
* **Byte movers** (`evidence/byteverify_law_vs_pristine.txt`, `tools/probe/r11v75repro/byteverify.sh` with
  SELFCHECK=1 on fence-filtered mirrors, `drivers/bvmirror.sh`): corpus 9 / 2560 (BuildUVMPkg, MiniAmiq, SeqDriver,
  SimpleUVM d/t, Scoreboard d; selfcheck 2559 / 2560), probe 31 / 4087 (`evidence/probe_movers.txt`), downstream
  slang lanes 0 / 805: **all 40 are the 40 predicted by name, none unpredicted**.
* **Away census** (`drivers/awayrows.py` with the variant comparator `drivers/strictcmp_x.cpp`, chain- and flat-keyed;
  `evidence/away_law_vs_pristine.txt`): 40 databases, away 0 on every one (chain and flat), toward 687 (SimpleUVM 79,
  Scoreboard 77, MiniAmiq 111, SeqDriver 58, BuildUVMPkg 15 per row-mode; probe 2-10 each; two probe databases move
  bytes with no record change: the alias copy's identity).
* **Canaries**: `canaries.sh` on the law surelog csv ok=47 changed=5 (exactly the five attributed changes; pristine
  ok=52 changed=0), on the uhdm2rtlil csv ok=16 changed=0; `ctcan2.sh` surelog ok=58 changed=0 (EXPECT_UNKNOWN=1 PASS),
  uhdm2rtlil ok=2 changed=0 (EXPECT_UNKNOWN=6 PASS).
* **Determinism** (`evidence/determinism_law.txt`, `drivers/det.sh`): three concurrent harness runs of the law binary
  on Earlgrey_0_1 and the five UVM rows, both modes: one hash per row-mode on all 11 runnable row-modes, each equal to
  the law sweep's (four draws).
* **uhdm-cmp**: every touched corpus row stays judge-equal (STRICT_NOTEQUAL), every touched probe case EQUAL or
  STRICT_NOTEQUAL; 0 cmp lines on all of them.

## Faces decoded and not written

1. **Item (1)(c), d01: a class property typed by a typedef'd unpacked array** (`decode/tf_f01..f04`, all exit 4 on
   both binaries): golden writes a SMALL `array_var` (name, full name, vpiAutomatic, vpiVisibility, a ref_typespec
   to a bare-named copy `array_typespec (f1_t)` carrying a Typedef_alias to the listing object; no vpiSize, no
   vpiArrayType, no vpiRandType, no range, no vpiReg) for a fixed (1-D and 2-D), queue and dynamic typedef alike
   (`tf_f02` records). Ours: the fixed kinds are `class property type: FixedSizeUnpackedArrayType` (UhdmExporter's
   class property switch, § fixedClassPropIsArrayVar6's gate clause (2) refuses a typedef name: its residue R1), the
   queue / dynamic kinds take the declarator shape (vpiSize 1, vpiArrayType, vpiReg). Not written because no case of
   the face is judge-equal on our ground alone: in a package the typedef LISTING is wrong first (face 2); in `$unit`
   (`tf_f03`) the `$unit` typedef writer notes `typedef target: FixedSizeUnpackedArrayType` / `QueueType`
   (UhdmExporter, the `$unit` typedef loop's catch-all) and writes no design typedef at all, golden lists
   `array_typespec (f1_t)` with a range `[0 : 4-1]` (the left constant unlocated, the right an operation) and an
   element ref named `f1_t`; a class-scope typedef (`tf_f04`) is stage 1 at the class. The three writers are one
   pass of work (the `$unit` listing, the property shape, then the package listing on the sister ground).
2. **Item (1)(d), d03: the package typedef writer** (`decode/tq_q01`, `tq_q02`): ParamEmit `emitPackage`'s typedef
   loop (the `ct.kind` chain: PackedArray, FixedSizeUnpackedArray, struct, enum, union, a topView-only
   FixedSizeUnpackedArray branch) has NO QueueType / DynamicArrayType branch, and the DEF listing omits even the fixed
   one: `package p; typedef int iq_t[$]; typedef int id_t[]; endpackage` lists nothing in either view where golden
   lists two `array_typespec` with the `$` / `unsized` marker range in both; with a module variable of each type the
   module binds `int_typespec` / `logic_typespec`. **Ground A** (ParamEmit), for the sister pass.
3. **SimpleUVM's new head #98800 / #98812**: `uvm_report(uvm_severity'(severity), ...)` in `uvm_pkg::m__uvm_report_dpi`
   (uvm_globals.svh 168:15): golden resolves the cast to the package's `enum_typespec uvm_pkg::uvm_severity` (located
   at the type's last writer, uvm_sequence_item.svh 352:37-49); ours writes `unsupported_typespec uvm_severity`
   through ExprEmit § dpiExportedPkgSubBareOwnTdUnsupported170 (`dpiOwnTdCast170`, the `export "DPI-C"` written above
   the definition). That law's head was MiniAmiq / BuildUVMPkg, where golden degrades; SimpleUVM's golden (uvm-1.2
   sources with `uvm_pkg.sv` including `uvm_globals.svh`) does not: the distinguisher between the two compilations
   is the sister ground's to decode (`dpiExportPkgHome170`). **Ground A.**
4. **UR u02's next record** (`parameter E = A + 1` imported by a module: golden `work@top.E` value `UINT:251658241`, ours
   no value) and the module import copies `decode/ur_u04_modcls`, `ur_u05_unitonly` (golden copies a module's import
   constant with a reference `work@top` bound to the int_typespec; ours writes none) and `ur_u06_twoclass` (a derived
   `$unit` class's copy): the module listing's and the derived class's import parameter copies (which writer, ModuleEmit or ParamEmit,
   is not decoded), stage 1 at the base, not attempted.
5. **File-scope imports and the `this` wire** (`decode/th_unitonly`): a `$unit` import with a `$unit`-scope class use
   is stage 1 at the base at the class's out-of-body method (golden lists `b::cb::f`'s body under the class; ours
   lists the hoisted object elsewhere), so the file-scope rank of § thisNetSurelogAnchor243 is measured on SimpleUVM
   and on golden's own record of `th_unitimp`, not on a judge-equal case.

## Residues, ranked

1. **Ground A heads of the targeted rows** (sister pass, call sites): SimpleUVM d/t #98800 / #98812 (face 3 above,
   ExprEmit § dpiExportedPkgSubBareOwnTdUnsupported170); BuildUVMPkg d/t #81827 (StmtEmit, the foreach body `begin`
   with no location); Scoreboard d #81633 (ExprEmit hier_path member naming `predict_info.addr[]::addr::addr`);
   MiniAmiq #71388 / SeqDriver #71344 / #71356 (StmtEmit, the nested-block fixed array `int q[5]` in a copy).
   BuildUVMPkg's later records seen in the walk (alignment after a divergence is not exact): #82349 / #139619
   hier_path element full names (ExprEmit), #91593 an int_typespec end column (9187:66-69 against ours -78), #129711
   an int_typespec line, #139713 a method_func_call span (ExprEmit), #153018 a folded constant against our operation
   (ParamEmit / ExprEmit); Scoreboard #130737 the same constant-against-operation fold.
2. Faces 1 and 2 above (typedef'd unpacked-array properties and the array typedef listings).
3. The wire's PLACE in the module's net vector still follows the old (file, line, column) key of
   § hoistedThisRidesTheForwardedBlock219; no case of the grid separates it from the new anchor's order.
4. Several file-scope imports tie at rank 0 in § thisNetSurelogAnchor243 (their relative order is not decoded).
5. The brief's items (2) (pass 241's residues), (3) (pass 239's), (4) (pass 237's), (5) beyond Scoreboard #84633 and
   BuildUVMPkg's alias record, and (6) (pass 231's and 228's): not attempted.

## Process

* Every helper reads `$FENCED` fail-closed from the FENCED= line of `tools/probe/r11u107repro/canaudit.sh`
  (`drivers/env.sh`); corpus censuses ran with the fence filter; byteverify ran on mirrors built from a path list
  filtered by `$FENCED`; the away census skips fenced rows unread.
* **One fence lapse, recorded**: the first binary-path audit of the two sweep workdirs ran `find ... -name cmds.txt |
  xargs grep` with no fence filter, so it read the harness command-line records (`cmds.txt`) of the fenced rows'
  sweep directories and printed only per-binary counts (3273 per sweep); no source, database or output of a fenced
  test was opened, no binary or script ran on one. The audit was re-run with the path list filtered first
  (`evidence/cmds_audit.txt`, 3265 per sweep).
* One `uhdm-dump` call early in the decode ran in a shell where `UHDM_DUMP` was unset (the variable was set in an
  earlier call); bash executed the golden database of `TQ/q01` as a script, printing syntax errors and writing no
  file (checked: no new file in that directory). Every later call went through a guarded `dump()` that checks
  `[ -x "$UHDM_DUMP" ]`.
* The predictor was written after the last law and frozen before the law sweep; the law binary was frozen before any
  measurement; both sweeps ran one at a time.
