# r11u266: pass 266, the expression/parameter ground (the probe residue, classified by writer; two laws in ParamEmit and ExprEmit)

Base `91223a6f` (pass 264). Production files: src/ParamEmit.cpp, src/ExprEmit.cpp and the new src/R266.h. Binaries:
pristine `73e79e8b` (byte-identical to the main tree's build), law `0d9da879`, both frozen before any measurement.
Two laws, each behind its own switch; `R11U266_OFF` drops both and gives pristine's bytes on every case-view
(152 of 152). `R11U266_TRACE=<dir>` writes one file per process (`<pid>.266`, first line `OUT <-o path>`) with
every firing and every abstention (`<law> abstain ...`).

## Verdict per targeted row

No corpus record is left on this ground at the base (the brief's item (1)), so no corpus row was targeted and
**no corpus row moves**: surelog 945 CMP_EQUAL + 9 STRICT_NOTEQUAL (default 476 + 4, testflags 469 + 5),
uhdm2rtlil 1606 + 0, downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, all as the base.
The work is the probe residue.

**PROBE: 18 CONVERSIONS (STRICT_NOTEQUAL -> EQUAL), 3 CHANGES toward golden, 0 regressions**, probe 3577 + 510 ->
**3595 EQUAL + 492 STRICT_NOTEQUAL**. The fresh rows of the law sweep (evidence/fresh_rows.txt):

| case | before | after (fresh csv row) | law |
|---|---|---|---|
| r11u108repro/grid/pk/k01_param_v | differ:name(2) | `r11u108repro/grid/pk/k01_param_v,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u108repro/grid/pk/k02_param_vn | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u108repro/grid/pk/k21_param_vn_nofunc | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u108repro/grid/pk/k22_param_v_literal | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u111repro/grid/f1/a06_q_signed | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u111repro/grid/f1/a12_q_multidim | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u111repro/grid/f1/a14_q_two_inst | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u111repro/grid/f1/a15_q_genblk | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u111repro/grid/f1/a17_q_and_import | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| r11u111repro/grid/f1/a19_q_ascending_sym | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| v11u111repro/brk/f1/x04_twodim | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| v11u111repro/brk/f1/x05_passthru | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| v11u111repro/brk/f1/y11_reg_typedef | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| v11u111repro/brk/f1/z11_three_inst_gen | differ:name(2) | `...,EQUAL,,equal` | § pkgTdParamValListingTs266 |
| v11u116repro/arms/f1_shex_body | differ:file(7) | `...,EQUAL,,equal` | § sgnLitElabFreshIntTs266 |
| v11u116repro/arms/f1_shex_hdr | differ:file(7) | `...,EQUAL,,equal` | § sgnLitElabFreshIntTs266 |
| v11u116repro/arms/f1_shex_lp | differ:file(7) | `...,EQUAL,,equal` | § sgnLitElabFreshIntTs266 |
| r10v80repro/v4_shape80 | differ:file(1) | `r10v80repro/v4_shape80,EQUAL,,equal` | § sgnLitElabFreshIntTs266 |

The three CHANGES, all § pkgTdParamValListingTs266, all toward golden with the same first field:
r11u108repro/grid/pk/k05_param_a, r11u111repro/grid/f1/a27_q_row_named_dims and
v11u111repro/brk/f3/x38_param_in_module_typed read `differ:file(12) -> differ:file(4)`. The 4 left are golden's
unlocated copy of a package ARRAY typedef (`typedef v_t [1:0] a_t`) on the same constant, a different face.

## 1. The probe residue at the base, classified by writer (evidence/residue_buckets.txt, residue_heads.txt, residue_chains.txt)

drivers/classify.py ran `uhdm-strictcmp --max 3` with record dumps on each of the 510 STRICT_NOTEQUAL probe
databases of the pristine sweep against check_probe's cached golden. drivers/chains.py rebuilt each first
record's ancestor chain from golden's record dump and keyed it as field | object | parent | grandparent | top
scope. 190 keys. The ground column is map 15's writer pin (tools/probe/r11u230map/probe_fail_list.csv,
measured at 97343175): 271 cases A, 239 B. The pin is old and names the first writer on the CALL CHAIN, so the
decode below re-assigns a bucket when the field's fix sits in another file.

The buckets of 9 or more cases:

| cases | key | example | writer and ground (decoded here) |
|---|---|---|---|
| 25 | name, ref_obj under an elaborated cont_assign | r11u108repro/grid/pk/k10_member_v_pkgparam | golden's elaborated `assign o = P` (P a struct-typed parameter, o a declared net) has NO Rhs of its own: its Rhs IS the elaborated param_assign's constant, shared and re-parented to the cont_assign (Surelog UhdmWriter::writeCont_assign: `reduceExpr`, `adjustSize` returning the same object for a non-UINT constant, `res->VpiParent(assign)`, `assign->Rhs(res)`); ours writes a fresh ref_obj P. **Ground B**: ModuleEmit emitContAssigns, where § implNetBareParamElab160 already does exactly this for an IMPLICIT left-hand net only. Map 15 pins it A because the ref_obj is minted by ExprEmit emitExpr, but the choice of object is emitContAssigns'. |
| 22 | type, ref_obj under an elaborated cont_assign | r10rgg8repro/cells/L_1b1_bt | the same writer: golden's elaborated Rhs is an EXISTING object (the evaluated function's return constant `1'b1` at its own span; the pattern member's constant for `IMPL.a`, r11u114 f1/a25), listed once; ours mints a copy. Ground B, ModuleEmit emitContAssigns. |
| 21 | fullname, ref_typespec under an operation under a typespec_member | r11u24repro/n12 | a struct typespec member's ref_typespec full name inside a parameter's struct copy (`<in>pk::c_t.u` against `pk`). Ground B, TypeEmit buildStructTs. |
| 20 + 10 | fullname, ref_typespec under a typespec_member | r11u107repro/grid/a08_anon_member | anonymous nested struct members named bare (`a`) where golden names through the typedef (`t_t.m.a`). Ground B, TypeEmit buildStructTs. |
| 16 | depth, class_typespec under a type_parameter | r10uvm112repro/a10_sameargs | class specialization type-parameter binding. Ground B, UhdmExporter emitClassTdSpecParams1 (the same family as MiniAmiq / SeqDriver #136655). |
| 15 | line, logic_typespec under a packed_array_typespec | r11u108repro/grid/f5/f5a05_override | a type parameter's default (`id_t [D-1:0]`) keeps the default's span where golden spans the override. Ground B, TypeEmit makeTypeParamDefaultTs. |
| **14** | **name, logic_typespec of an elaborated param_assign constant** | r11u108repro/grid/pk/k01_param_v | **this ground, ParamEmit: § pkgTdParamValListingTs266, all 14 converted** |
| 13 | fullname, ref_typespec of a constant under an operation | r10earl31repro/v5_hier | mixed: hier_path part-select folds, interface-array ranges (r10rgg4 a1/b1/c1, ModuleEmit), function return folds (r10uvm99). Not one law. |
| 13 | type, ref_obj under a generate-scope cont_assign | r11u23repro/grid/b17_genlocal_rhs_constcall | the generate-scope twin of the 22 above. Ground B, ModuleEmit. |
| 11 + 4 | type, bit_select under an elaborated cont_assign | r11u116repro/grid/f1/gl_o_ms | the same shared-Rhs face on a select read. Ground B, ModuleEmit. |
| 10 | name, logic_typespec under a logic_typespec in a package | r10uvm36repro/t48a | an importer copy's function argument typedef named `home48::w48_t` where golden names it bare. Ground B, the importer-copy drain (UhdmExporter / TaskFuncEmit). |
| 9 | fullname, ref_typespec under a packed_array_typespec | r11u107repro/grid/t05_tp_struct_dim | type-parameter struct dimensions. Ground B, TypeEmit. |

The smaller ground-A buckets: 8 macro-paste end columns on package string parameters (r10v104repro, the
`` `" `` stringification with token pastes, ExprEmit / ParamEmit), 6 + 5 + 5 constant typespec file / line faces
(of which § sgnLitElabFreshIntTs266 takes 4: the three f1_shex branches and v4_shape80; a2_earl52 is the signed
TERNARY `C ? 1'sb0 : 1'sb1`, residue R3; the r10earl_repro ss / tl / ud / ue are a ranged bound folded from a
qualified package parameter), 4 elaborated-param_assign operation lines (r11u69 g9_child / w5_ovr / v4_nestinst,
r10vearl108 m_gen108), 4 value faces of 64-bit casts (r11u109 f1 c04 / c06 / p06 / p07), 4 indexed-part-select
constant references (r10earl47). Every other key holds 3 cases or fewer.

## 2. The laws

### § pkgTdParamValListingTs266 (`R11U266_PKGTDLISTTS_OFF`; ParamEmit, the elaborated parameter emission)

**Statement.** The elaborated param_assign's Rhs constant of a parameter declared `pkg::T`, where T is a package
4-state vector typedef (the shape pass 111's `qualPkgVecTd111` reads), binds the PACKAGE'S LISTING OBJECT `pkg::T`
itself (the top-level `logic_typespec (pkg::T)` with its range, no Typedef_alias). Pristine bound the definition's
bare clone (`logic_typespec (T)` with an alias to the listing object, parented at the definition parameter) on
the shared-default branch, and a fresh `int_typespec` on the module-local-parameter-initializer branch (cases/A a02,
a14). The law applies on those two branches only: the read folds before them (a read parameter's loc-less bare
typespec, cases/A a12) keep pristine's answer.

**Decode.** Pass 111's note at § pkgTdQualParamCopiesListing111 (src/EmitHelpers.h): Surelog binds the value of
such a parameter to the last typespec its package registered under the name, which is the listing object unless
a package subroutine taking a `T` argument is evaluated with the parameter. The grid pinned the exception: a call
`q::inv(M)` that the elaborator evaluates (cases/A a07, a29 named) leaves the formal's bare clone, pristine's
answer. A subroutine with a `T` formal that is NOT called with the parameter does not (a08: not called; a09:
called with another argument; a36: pure virtual and extern prototypes). The distinguisher holds for overridden,
positional, expression, package-parameter, symbol and process-read overrides (a01 to a06), for defaults that
are unread or passed down (a10, a11, a13, a15), for the module-local initializer (a14), in for-generate and
if-generate instances one and two levels down (a16, a17), on signed and two-dimensional typedefs (a21, a22),
in every constant slot (part-select bounds a25, an indexed-part-select width and a replication count a26, a
dimension bound a27, another parameter's default a28) and through a macro-written type (a31).

**Abstentions** (each traced): the parameter passed alone as an argument of any call in its definition (a
syntax scan of the definition for an ordered or named argument whose only token is the parameter's name:
`nameIsDirectCallArg266`), an interface home (`ifaceHome111`), no listing object or one that is not a
logic_typespec. The 2-state (`bit`, a23), chain (a24) and bare-imported (a19) typedefs are refused by
`qualPkgVecTd111` itself.

### § sgnLitElabFreshIntTs266 (`R11U266_SGNLITTS_OFF`; ParamEmit at the parameter value, ExprEmit at two read sites)

**Statement.** A module parameter written with the signed `int` keyword (`int`, `int signed`) whose initializer
is a SIGNED SIZED literal in base `h`, `d` or `o` (`12'shFFF`, `8'sh7F`, `12'sd5`, `32'sh8000_0000`) keeps its
value and decompile, but its elaborated param_assign Rhs constant binds a FRESH signed `int_typespec` with NO
location, the same answer the signed-binary branches of pristine already give (the law adds the parameter to
`signedBinFoldParams`). The copies of that constant at two generate-scope read sites carry the same unlocated
typespec: § loopCaParamReadKeepsLiteral116's continuous-assignment clone in a loop-generate body, and
§ genProcParamFold's `paSrc9` copy in a generate process.

**Decode.** Surelog CompileExpression.cpp, the based-literal branch: `if (isSigned) { int_typespec *tps =
s.MakeInt_typespec(); tps->VpiSigned(true); ... c->Typespec(rt); }`. A signed based literal is compiled with its
own unlocated signed int typespec; for an `int` target the elaborator keeps it, and the generate-scope
substitution clones that constant (CompileExpression.cpp's `clone_tree(param_ass->Rhs())`).

**Fences** (grid cases/S): only `int` / `int signed` (the `int unsigned` s12, byte s13, shortint s14, longint s15,
integer s16 and vector s18 targets are uhdm-cmp stage 1 on both binaries; the untyped s17 is strict-equal on
pristine and stays so); only a module or interface home (a package parameter keeps its located typespec: s31,
and v11u116 arms/k3_child, which a draft without this fence moved away from golden); no `x`/`z` digit (s35).
The unary `-12'sd1` (s09) and the signed binary (s10) are pristine's already; the signed ternary (s38) is R3.

## 3. Grid (cases/A, cases/S; drivers/grid.sh; evidence/grid.txt, gridsum.txt, away_cases.txt, downstream_cases.txt)

76 case dirs (A 37, S 39) in both views (default and `--elabuhdm`): 152 case-views on five configurations
(pristine, law, law + `R11U266_OFF`, law with each switch off), 760 lines, **every line rc 0**.

| | A | S | total |
|---|---|---|---|
| case-views | 74 | 78 | 152 |
| moving | 52 | 50 | 102 |
| entering STRICT_EQUAL | 46 | 34 | 80 |
| leaving STRICT_EQUAL | 0 | 0 | 0 |

- `R11U266_OFF` gives pristine's bytes on 152 of 152.
- Every mover is moved by exactly one switch (PKGTDLISTTS 52, SGNLITTS 50).
- No uhdm-cmp line count and no exit code changes on any case-view.
- The movers that do not end strict-equal: A a32 / a33 / a34 and S s22 / s26 / s33 / s34 / s36 / s37_el are
  uhdm-cmp stage 1 on both binaries; S s04 (octal) and s37 keep an older face (residues R4, R5).
- **Away census** (drivers/awayall.sh): 100 of 102 movers lose 0 golden records. The two others are A
  a34_implicit_net (both views, stage 1 on both binaries, dump census): dist 34 -> 1 and 39 -> 8, "lost" 1 and 3
  dump lines, `|vpiParent:`, `|vpiActual:` structure lines of the definition's bare clone, which the law no longer
  references and so no longer prints; golden prints lines of the same text elsewhere at that indent. No field of
  any object moves away.
- **Downstream on the 76 case dirs** (drivers/dscases.py): the same verdict on both binaries, 69 IDENTICAL, 6
  EQUIVALENT, 1 DIVERGENT (a30 `$countones(M)`, DIVERGENT on pristine too).

## 4. Byte controls (drivers/controls.sh; evidence/controls_dirs.txt, controls.txt, controls_sum.txt, away_controls.txt)

45 earlier repro dirs: r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131, the
r / v pairs of 244 through 267, and the dirs of the shapes these laws touch: r / v 108, 110, 111 and 116.
6602 case-views in both views, every path list filtered by `$FENCED` before any file was opened.

- **28 move, 10 enter STRICT_EQUAL, none leave; no exit code and no uhdm-cmp line count changes.**
- Entering: r11u111 grid/f1 a01_q_lit_ovr and a02_q_sym_ovr, r11u131 ovr/o03_typedef and o10_pkg2d_qual (law A),
  v11u264 VR/vr17_src_signed_sized (law B), each in both views.
- Toward without entering: r11u111 f3 k05_param_a and t08_param_only (dist 6 -> 4); stage 1 on both binaries:
  r11u111 f3/s00_stamped_corpus, v11u111 f1 x09 / x11 / x13 / y14, f3 z32, v11u264 VR/vr01 (dump census,
  distance falling on every one).
- Away census: 0 lost records on every record-comparable mover. The dump census reads "lost" lines on v11u111
  x09 (6) and z32 (7), the `|vpiInstance:` / package / alias lines of the bare clone the law stops printing
  (distance 63 -> 5 and 23 -> 15), the same artefact as a34.
- The rc 139 lines of the control set are the known `--elabuhdm` crashes (r11u254 F/f04, v11u254 vf02 / vf04),
  identical on both binaries.

## 5. Gates (evidence/sweep_pristine.log, sweep_law.log, rowdiff.txt)

Both sweeps are tests/sweep.sh `--jobs 3`, workdirs /tmp/r11u266_swP and /tmp/r11u266_swL (equal length).

| stage | pristine | law |
|---|---|---|
| probe | 3577 + 510, regressions=0 conversions=0 changes=0 | **3595 + 492, regressions=0, conversions=18, changes=3** |
| surelog | default 476 + 4, testflags 469 + 5; regressions=0 | the same; regressions=0 conversions=0 changes=0 |
| uhdm2rtlil | 1606 + 0; regressions=0 | the same; regressions=0 conversions=0 changes=0 |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, verdict diff 0 |

Both sweeps exit 1 on the law-index staleness check alone: the committed tests/LAWS.md is stale at the base (the
pristine sweep printed `law index STALE` before any edit), and the regenerated index is part of this patch.
Row by row, law against pristine: surelog differs only in LowMemLib / LowMemPkg testflags detail text (the
workdir path, environment); uhdm2rtlil 0 rows; downstream 0 rows; probe the 21 rows above. No strict column
worsens anywhere.

**byteverify** (`SELFCHECK=1`, run on hard-link mirrors filtered by `$FENCED`, drivers/bvmirror.sh; 8 fenced
row-mode databases left out and never opened):

| corpus | movers | names | SELFCHECK |
|---|---|---|---|
| surelog | 0 of 952 | | 951 of 952 |
| uhdm2rtlil | 2 of 1608 | stamped_gen_param d/t | 1607 of 1608 |
| downstream | 1 of 805 | stamped_gen_param (IDENTICAL on both) | 804 of 805 |
| probe (a byte compare) | 21 of 4087 | the 18 conversions and 3 changes | |

SELFCHECK compares every file with ONE fixed file, so it flags N-1: the fixed file is identical to itself. That
is a self-check artifact, not a missed mover (the 2559-of-2560 shape pass 201 named).

**The firing census** (drivers/tracecensus.sh, frozen law binary, before the law sweep; evidence/census_predict.txt)
predicted, by name: the 21 probe movers (exactly the byte movers), uhdm2rtlil stamped_gen_param d/t and the
downstream stamped_gen_param (law A, 2 firings each), and abstentions on cfg_func_width_loop (u2r d/t and
downstream) and probe k17 / k20 (the call-argument abstention: `p::cnt(M)`), which moved no byte. Every byte
mover was predicted, and nothing predicted failed to move.

**stamped_gen_param** is the known CMP_NOTEQUAL row (the proven Surelog-defect row the user kept). Its
uhdm-cmp line count stays 64 in both modes on both binaries; its dump away census (evidence/away_corpus.txt)
reads dist 148 -> 144, lost 0, gained 2 in both modes; the downstream verdict stays IDENTICAL.

**Other checks:**
- uhdm-cmp reads 0 lines on every probe case that moved (all judge-equal on both binaries).
- **Canaries** (tools/probe/r11u107repro/canaries.sh): surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0.
- **ctcan2**: surelog PASS (`EXPECT_UNKNOWN=1`), uhdm2rtlil PASS (`EXPECT_UNKNOWN=6`).
- **Binary-path audit** (evidence/binaudit.txt): 3265 of the 3315 fence-filtered cmds.txt name
  `/tmp/r11u266_bin/law`; the other 50 carry no slang line; none names another binary.
- **Determinism** (drivers/det.sh; evidence/determinism.txt): three concurrent draws per row-mode of Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen with the law binary: one hash per row-mode
  (3 of 3 each), every one equal to the law sweep's (Scoreboard and Rggen testflags write no database).

## 6. Sister-ground faces (decoded, nothing written there)

- **The shared elaborated cont_assign Rhs** (60 + probe cases: the 25, 22, 13, 11 and 4 buckets of section 1).
  Surelog UhdmWriter::writeCont_assign: when `reduceExpr` returns a constant and `adjustSize` returns the same
  object (it clones only a vpiUIntConst under `uniquify`), the elaborated cont_assign's Rhs IS that object
  (the parameter's elaborated param_assign constant, the evaluated function's return constant, the pattern
  member's constant), re-parented at the assign and listed once. ModuleEmit emitContAssigns writes it, and
  § implNetBareParamElab160 already models it for an implicit left-hand net; the declared-net, struct-parameter,
  function-fold and generate-scope shapes are the extension. Example cases k10_member_v_pkgparam,
  L_1b1_bt, r11u114 f1/a25, b17_genlocal_rhs_constcall.
- **Struct typespec member reference full names** (21 + 20 + 10 + 9): TypeEmit buildStructTs.
- **Type-parameter faces** (16 + 15): UhdmExporter emitClassTdSpecParams1 (class specialization binding, the
  MiniAmiq / SeqDriver #136655 / #136613 / #136625 family) and TypeEmit makeTypeParamDefaultTs (default spans).
- **Importer-copy argument typedef names** (10, r10uvm36 t48a): the importer-copy drain.
- The items the brief lists for ground B stand as reported by pass 264: Earlgrey testflags #580520 to #594077
  and #604991, the package listing order, typedefParentModel134's unparenting of the cast copy, the select-Lhs
  replication fold (r11u267 R/r11 to r14), the pendingParamCloneTs drain (r11u264 P/p09), interface-array port
  views (r10rgg3 f1), vf01.

## 7. Residues on this ground, ranked

1. **R1, the rest of the 14-case family's neighbours.** A package ARRAY typedef `pkg::a_t` (k05_param_a,
   a27_q_row_named_dims, x38_param_in_module_typed, now file(4)): golden writes an unlocated copy of the
   array typedef on the constant; `qualPkgVecTd111` refuses the shape. The interface home (a18, stage 1 on both).
   A call taking the parameter inside a function body that is never called (a35, a37 through a class method):
   the abstention is a whole-definition syntax scan, so these keep pristine's (wrong) answer.
2. **R2, § sgnLitElabFreshIntTs266's other targets.** byte / shortint / longint / integer / `int unsigned` /
   vector targets of a signed literal are uhdm-cmp stage 1 on both binaries (cases/S s12 to s16, s18): the value
   encoding differs before the typespec does.
3. **R3, the signed ternary** `localparam int T = C ? 1'sb0 : 1'sb1` (r10earl52repro/a2_earl52, cases/S s38):
   golden's fresh unlocated int typespec follows the taken branch's literal; the law reads only a bare literal.
4. **R4, the octal elaborated cont_assign fold** (cases/S s04): Surelog folds an octal read into a fresh UINT at the
   parameter's span whose int typespec is unlocated; that constant is minted in ModuleEmit emitContAssigns.
5. **R5, s37**: a function returning the parameter, folded at the call (pristine's #54 head, now the first record).
6. The 8 macro-paste end-column cases (r10v104repro), the r10earl_repro qualified-bound faces, r11u69's
   elaborated-param_assign operation lines and r11u109's 64-bit cast values (section 1), not attempted.
7. The brief's items (2) to (7) (passes 264, 262, 260, 258 to 238 residues, the decode's BuildUVMPkg clusters,
   the carried items) were not attempted in this pass.

## 8. Process

- **Drafts.** Six draft binaries were measured on cases and on the probe stage only, before the law binary
  was frozen. Draft 1 gated law A on an override; the non-overridden cases (a10, a11, a13, x05_passthru's
  `m2`) showed golden binds the listing object there too, so the law moved to the two branches. Draft 4's read-site
  branch used the shared `signedBinFoldParams` set and fired on a package `byte` parameter, moving probe
  v11u116 arms/k3_child EQUAL -> STRICT_NOTEQUAL; the law got its own set (`sgnLit266`) and the `int`-keyword and
  module-home fences before the freeze. Every number above is the frozen law binary's.
- **The fence.** Every driver reads `$FENCED` from tools/probe/r11u107repro/canaudit.sh fail-closed; the
  census, the probe classification and the byteverify mirrors filter by word boundary before opening any file;
  the corpus byteverify ran on fence-filtered mirrors (952 surelog databases, not 960). No fenced test was
  dispatched, read or decoded outside the gate sweeps.
- **My slips.** (a) A variant loop ran `sed -n 1,3p $f` with an empty `$f` after a case slang rejected (rc 3), so
  sed waited on stdin; I stopped that sed (my own pid, its command line checked) and then the loop by its own
  task id, and rewrote the helper to read nothing from stdin. (b) One waiter used `pgrep -f` with a pattern
  that matched its own shell, the trap §9 warns about; I stopped it by its own task id after the grid had
  finished. (c) A second helper first took a relative case path after changing directory, so the case did not
  resolve, and its trailing `head` on an empty path waited on stdin; it was stopped by its own task id, and it
  wrote nothing outside my scratch. No other process was
  signalled.
- **src edits during the pristine sweep.** The pristine sweep ran the frozen binary /tmp/r11u266_bin/pristine;
  the worktree's src was edited while it ran, which only the law-index check reads.
- **The law index.** tests/LAWS.md was regenerated last (`python3 scripts/law_index.py`).

## Drivers

drivers/ (copied from r11u264repro; the pass-specific names changed):
- env.sh, case.sh, grid.sh, gridsum.py: the case grid.
- classify.py, chains.py: the probe residue classification (section 1).
- controls.sh, ctlsum.py: the byte controls.
- tracecensus.sh: the firing census (probe, both corpora, downstream; abstentions listed apart).
- bvmirror.sh: the fence-filtered byteverify mirror.
- awayall.sh, away.py, awaydump.py, awaycorp.sh, awaychain.py, awayrows.py, cc_x.sh, strictcmp_x.cpp: the away
  censuses.
- rowhead.sh, det.sh, dscases.py: a row's strict records, the determinism draws, downstream on cases.
