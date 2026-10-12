# r11u291 — module/type ground: type-parameter uses, anonymous member names, class specialization spans

Base 309b62bc (pass 289). Three laws in TypeEmit and UhdmExporter behind `src/R291.h`. Each law reads its own
`R11U291_<LAW>_OFF` switch. `R11U291_OFF` drops all three and gives pristine's bytes on 216 of 216 grid case-views.
`R11U291_TRACE=<dir>` logs every firing and abstention (one file per process, `OUT <-o path>` first).

**NINETEEN PROBE CONVERSIONS**, no probe change, no regression. No corpus row changes status or strict column. Two
corpus databases move in bytes, TypeParam default and testflags (predicted by name, identity only: their record walks
are identical on both binaries).

| target (probe, default view = the gate) | before (base) | after (law) | law |
|---|---|---|---|
| v11u111repro/brk/f6/y61_vec_dims_extra_port_dims | `name(1)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| v11u111repro/brk/f6/y68_bit_td_dims | `name(1)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| v11u111repro/brk/f6/y69_vec_dims_two_inst_same | `name(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11u108repro/grid/f5/f5a20_ovr_pkgarr | `name(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| v11u108repro/brk/f5/b13_pkg_arr | `name(1)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11u18repro/t4 | `line(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11u45repro/g10 | `line(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11u45repro/g12 | `line(1)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11u45repro/g13 | `line(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11v45repro/v6 | `line(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11v45repro/v7 | `line(4)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11v45repro/v9 | `type(1)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11v32repro/w1_regression_witness | `line(2)` | **EQUAL** | § tpUseSigBindsTpObj291 |
| r11u107repro/grid/a08_anon_member | `fullname(8)` | **EQUAL** | § anonAggMemberChainName291 |
| r11u107repro/grid/a18_anon_typedef | `fullname(8)` | **EQUAL** | § anonAggMemberChainName291 |
| r11u113repro/grid/e/e05_nested | `fullname(5)` | **EQUAL** | § anonAggMemberChainName291 |
| v11u93b107repro/brk/p02_nested_member_dim | `fullname(6)` | **EQUAL** | § anonAggMemberChainName291 |
| r10v119repro/v119_j | `endcol(1)` | **EQUAL** | § clsSpecDeclNameSpan291 |
| r10sd1repro/b27_inline_method_foreign | `endcol(1)` | **EQUAL** | § clsSpecDeclNameSpan291 |
| probe | EQUAL 3903 + STRICT_NOTEQUAL 184 | **EQUAL 3922 + STRICT_NOTEQUAL 165** | regressions 0, changes 0 |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged | |

All nineteen conversions are STRICT_EQUAL in the elaborated view too. The r11u45 / r11v45 cases were listed as the
sister's § typeParamChainBorrow45 face; their first record was the signal's binding, written on this ground.

## Law 1 — § tpUseSigBindsTpObj291 (switch `R11U291_TPUSEOBJ_OFF`)

**The face.** A signal declared with a type parameter's name (`input T a`, `T v;`, `input b_t i` with `b_t = a_t`).

- With `T = pk::w_t` (a named override `.T(pk::w_t)` or `.T(pk::w_t [1:0])`, a default `parameter type T =
  pk::w_t`, a body `localparam type T = pk::w_t`), golden types the elaborated variable with the package listing
  object `logic_typespec pk::w_t` itself. Ours bound LAW S's bare copy `w_t` (TypeEmit `bareScalarTypedefVarTs`: an
  instance-scope variable of a ranged package scalar typedef takes the bare unaliased copy).
- In an interface (`IT a;` with `parameter type IT = int`) golden binds the parameter's object, located at the
  default or the override. Ours minted a fresh typespec at the use's `IT` token (`int_typespec` 3:3-3:5 where golden
  reads 2:37-2:40). For `.IT(logic [4:0])` the fresh object had no range at all: uhdm-cmp stage 1 and downstream
  EQUIVALENT (grid TB/b35).
- For a chain `b_t = a_t` golden binds `b_t`'s object as elaboration leaves it, which is the definition's default
  object listed under the instance (r11u45 g10: `logic` 4:26-4:31 though `a_t` is overridden). Ours bound the
  override.

**The decode.** Surelog's `CompileHelper::compileTypespec` resolves a NamedType that names one of the component's
type parameters in its `component->getParameters()` branch (CompileType.cpp): `result = tparam->Typespec()->
Actual_typespec()`. No per-declaration copy is made, unlike a written `pk::w_t v;`, which goes through
`compileDatastructureTypespec` and gets LAW S's per-use copy.

**The law.**

- Collection (TypeEmit `collectTpUse291`, at the start of LAW S): every variable or net member of an instantiated
  instance body, and of its generate blocks, whose declared type syntax is a NamedType (an IdentifierName or an
  IdentifierSelectName, so `T [1:0] a` too) naming a TypeParameter of the body. It is keyed on the signal's
  hierarchical path (`work@` + slang's path, equal to the variable's stored full name).
- LAW S makes no copy for a recorded signal whose instance lists that type_parameter.
- Binding (`bindTpUseVars291`, design-final in UhdmExporter after every type-parameter rebind, in UhdmId order):
  the variable's ref_typespec binds the Actual of the type_parameter of that name listed by its instance (or by the
  instance enclosing its generate scope).
- Abstains (pristine's binding kept), each found by a draft on legal SystemVerilog:
  - a `var`-keyword body declaration (`var T v;`): golden binds the DEFINITION's default (grid TB/b22, b31);
  - an ORDERED override (`child #(pk::w_t) u`), which Surelog ignores: golden keeps the default (probe f6 y64, y65);
  - a target reached through an unqualified name that is not a type parameter of the same body: an imported
    `.T(w_t)` (golden gives T itself a bare copy `w_t` that ours does not mint; TB/b08 went stage 1 under a draft),
    and `.T(T)` passing another instance's parameter (TB/b24);
  - a chain through a parameter that adds packed dimensions (`T2 = rt_t`, `rt_t = id_t [3:0]`): probe
    r11u108repro f5a12_chain left EQUAL under a draft;
  - a target written as an anonymous struct, union or enum, directly or through a chain: that object is
    § tpAnonStructLastParamUser167's, § typeParamStructLastNetParent273's and § tpPackedArrCaUnparent275's. The
    byte controls caught a draft there: tools/probe r11u107repro t07_tp_enum chain away 16, v11u273repro
    VT/vt06_enum_member chain away 9, r11u275repro PA/pa06_init_decl chain away 1, and PA/pa03, VP/vp05, vp06,
    vp12 order-blind lost 2 to 4;
  - an unpacked dimension on the declarator (`T v [2]`, TB/b21);
  - a signal whose instance lists no type_parameter of that name (a program, TB/b15).

## Law 2 — § anonAggMemberChainName291 (switch `R11U291_ANONMEMBNAME_OFF`)

**The face.** The member references of an anonymous struct, union or enum nested in another type:

- `struct packed { logic a; } [1:0] m` as a member of `t_t`: golden `t_t.m.a`, ours `a`;
- `typedef struct packed {...} [1:0] t_t`: golden `t_t.a`, ours `a`;
- the base reference of an anonymous enum member `e` in a nested anonymous struct `in`: golden `s_t.in.e`, ours `e`;
- an anonymous struct inside a packed array member of an anonymous signal struct: golden `m.a`.

**The decode.** CompileType.cpp's struct/union branch makes each member's `ref_typespec` with
`tsRef->VpiParent(m)` and no full name, and parents `member_ts` at the member. `BaseClass::ComputeFullName`
synthesises the name from the final parent chain when the database is read. buildStructTs names an anonymous
aggregate's member references bare, and § anonMemberRefChainName134 prefixes only an anonymous type that is a
member's type directly (not one reached through a packed dimension, not an enum's base reference).

**The law.** A design-final drain in UhdmExporter, after § defGenSelRefChainName287:

- It renames a member reference, and an anonymous enum member's base reference, whose STORED full name is still the
  member's bare name.
- The new name is the one `chainFullName287` (the ComputeFullName transcription) gives over the final chain.
- It reads the stored name through a member-pointer accessor, never the getter, which would compute and store one.
  A first draft that called the getter moved eight probe databases' bytes (symbol order only).
- It applies only to an aggregate nested in another type. The walk up from the member must reach a typespec_member
  or a named typespec before anything else. A type_parameter stops it.
  - A top-level anonymous signal struct keeps the bare names, as golden reads them: the assignment that writes the
    signal unparents its struct (§ contAssignLhsTsUnparented134). Under a draft, probe r11u109repro
    k12_int_member_nodim and r11u113repro e06_anon_var left EQUAL.
  - A type parameter's anonymous default keeps them too (probe v11u93b107repro q04_pkg_member moved name ->
    fullname under a draft).

## Law 3 — § clsSpecDeclNameSpan291 (switch `R11U291_CLSSPECDECL_OFF`)

**The face.** A class property or a subroutine / block local written as an unscoped specialization `C #(...)` of a
class not listed at the site (a $unit generic, a foreign package's generic). Golden locates its class_typespec at
the class NAME:

- `static box_j #(8) s_j` 20:10-20:15 where ours read to 20:20;
- `regb #(ub, "ub") lv1` 6:7-6:11 where ours read to 6:23.

The same holds for a $unit class property, a property with an initializer, two declarators, `box #()`, a named
argument, a module task or function local, a block local, a module class's property of a $unit generic, a foreign
package's function local and class method local (grid CS).

**The decode.** `CompileHelper::compileDatastructureTypespec`, the ClassDefinition branch, makes the class_typespec
with `fC->populateCoreMembers(type, type, ref)`, where `type` is the class name node. The same branch locates the
ordered arguments: an identifier argument's actual sits at the whole `#(...)`, the transcription
§ classSpecExprArgUnlocated202 carries as `respanSpecArgs202`.

**The law.** In TypeEmit's class-handle branch of `makeTypespec`, after the existing span rules. The conditions:

- not a listing site;
- a named class_typespec;
- the declaration is a ClassProperty, or a Variable nested in a subroutine or statement block;
- the type is written `C #(...)`.

Then the class_typespec is located at the class name token and its arguments are respanned by `respanSpecArgs202`.
These keep their own rules:

- the same-package local, Surelog's `compileVariable` fallback: unnamed and whole, § localClassTsUnnamed15;
- module-scope variables (§ modSpecValueArgSpanAtName202);
- formals (§ tfArgClassSpecNameSpan231);
- pure-virtual returns (§ pureVirtRetSpecWholeSpan234).

## Gates (law binary c3b84092d573fedf1aac730cdd76a1d6; pristine f285f238dbd51f0029dc79812e56e69d = the main tree's)

The pristine build in this worktree is byte-identical to the main tree's `build/slang-uhdm` at the base. Both
binaries were frozen read-only before any measurement. The delivered patch, applied to a fresh worktree at
309b62bc and rebuilt, gives the law binary bit for bit (c3b84092). On the new HEAD 0d207175 (pass 286) the patch's
source files are untouched by that landing; only tests/LAWS.md needs regenerating.

- **tests/sweep.sh --jobs 3**, all four stages (evidence/sweep_L.log):
  - probe: regressions=0, conversions=19, changes=0 (EQUAL 3922 + STRICT_NOTEQUAL 165).
  - surelog: 0 / 0 / 0 (default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2). Every row-mode stays
    CMP_EQUAL except the known failures LogicTypespec d/t and Scr1SvTests d/t.
  - uhdm2rtlil: 0 / 0 / 0 (803/1/67 both modes).
  - downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0. The csv is byte-identical to
    pristine's and to results/downstream_uhdm2rtlil.csv.
  - The surelog csv equals pristine's except the workdir path in the LowMemLib / LowMemPkg testflags detail. The
    uhdm2rtlil csvs are identical.
  - The sweep exited 1 on the law-index check alone; this patch regenerates tests/LAWS.md.
- **Pristine sweep** (evidence/sweep_P.log): probe 3903 + 184, surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67,
  downstream 803/66/2/0, each 0 / 0 / 0.
- **Predictor** (drivers/tracecensus.sh): R11U291_TRACE ran over the probe cases and both corpora in both modes,
  fence filtered, on the final binary. It was frozen before the law sweep (evidence/predict.txt, 24 lines). It
  counts the firing tags only (TPUSEOBJ, TPUSEOBJ_LAWS where LAW S would have copied, ANONMEMBNAME, CLSSPECDECL).
  - 22 probe databases: the 19 conversions plus r11u18repro t1 and t9 and r11u20repro t8, which are EQUAL on both
    binaries (the binding moves to the parameter's own object, identity only).
  - 2 corpus row-modes: surelog TypeParam default and testflags.
- **Byteverify** (tools/probe/r11v75repro/byteverify.sh on fence-filtered hard-link mirrors from
  drivers/bvmirror.sh; 8 fenced row-mode databases left out; evidence/byteverify_corpus.txt):
  - **2 of 3365 corpus databases move**: TypeParam d/t, exactly the predicted ones.
  - Both stay CMP_EQUAL and STRICT_EQUAL. Their record walks are identical: away.py lost 0, awaychain.py chain
    away 0 and toward 0 (evidence/away_corpus.txt). The uhdm-dump difference is the weakly-referenced tail no longer
    listing the per-use `int_typespec` copies of `DATA2`.
  - SELFCHECK reads 3363 of 3365, the known twin of downstream/1DUnpackedArray.
- **Probe byte compare** (evidence/byteverify_probe.txt, the same 4087 paths on both sweeps): **22 of 4087 move**,
  exactly the predicted 22.
- **uhdm-cmp**: 0 lines on every converted case and on every corpus row (the only corpus movers are CMP_EQUAL).
- **Canaries** (evidence/canaries.txt): surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both
  csvs (EXPECT_UNKNOWN=1 and 6).
- **Binary-path audit** (fence-filtered; evidence/binary_audit.txt): on each sweep, 3265 of 3315 cmds.txt name that
  sweep's own frozen binary, and the other 50 carry no slang line.
- **Determinism** (drivers/det.sh, three concurrent draws per row-mode with the law binary on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen; evidence/determinism.txt): one hash per
  row-mode, each equal to the law sweep's. Scoreboard and Rggen testflags write no database, as at the base.
  - The binding half walks in UhdmId order.
  - The anonymous-member drain only renames, so its order cannot move bytes.

## Grid (cases/; evidence/grid.txt, grid_summary.txt, grid_away.txt)

There are 89 case dirs (TB 45, AN 17, CS 27; each `dut.sv` names its law in its first line) and the 19 probe
targets. Each is run in both views, 216 case-views, every line with its exit code. Each case-view runs on pristine,
the law, the law with R11U291_OFF, and the law with each switch off.

- **168 moving, 144 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.** R11U291_OFF gives pristine's bytes on
  216 of 216.
- Every mover is restored by exactly one switch: TPUSEOBJ 84, ANONMEMBNAME 42, CLSSPECDECL 42.

| group | case-views | moving | entering STRICT_EQUAL | STRICT_EQUAL on the law |
|---|---|---|---|---|
| TB (law 1) | 90 | 62 | 50 | 62 |
| AN (law 2) | 34 | 30 | 26 | 28 |
| CS (law 3) | 54 | 38 | 30 | 44 |
| probe targets | 38 | 38 | 38 | 38 |

- Stage 1 -> STRICT_EQUAL: TB/b35_iface_ovr_kw (the interface variable had no range).
- The TB conversions, in both views:
  - b01 (named override), b02 (override with dims), b03 and b04 (package default, port and body variable), b05, b06
    (bit), b09 (body localparam type), b12, b14 (input and output), b17 (two instances, two typedefs);
  - b18 (a direct `pk::w_t d` beside `T`, which keeps LAW S's copy), b19 (chain `U = T`), b16 (generate block),
    b26, b27 (header with CRLF), b28 (two packages), b30 (declaration inside a macro), b32 (two declarators), b33
    (`input var T`);
  - the interface cases: b07, b34 (keyword default), b35, b36 (two instances), b41 (localparam type), b45 (package
    enum).
- The AN conversions: n03 (union), n04 (package enum), n05 (two dims), n06 (three levels), n07, n08, n09 (class
  typedef), n11 (function local), n12 (parameter), n13 (port), n14 (header with CRLF), n15 (unpacked outer), n17.
- The CS conversions: c01, c02 (static), c03, c08, c09, c10, c11, c14, c18, c20, c21, c22, c23, c26, c27 (macro).
- **Away census** (drivers/awaycv.sh: order-blind away.py and chain-keyed awaychain.py): **chain away 0 on all 168
  movers**, 894 records toward golden. Order-blind lost 0 on 166.
  - TB/b24_nested (both views) reads order-blind lost 1 with chain away 0 and toward 4. Pristine's mid-level `a`
    bound the bare copy `w_t`, which golden lists for the leaf's T (a coincidence of the multiset). The law binds
    the mid-level `a` to golden's `pk::w_t`, and the leaf's T is wrong on both binaries (residue).
  - The positive control (binaries swapped, evidence/away_poscontrol.txt) reads chain away 1 to 10 on 8 of 8.
- **uhdm-cmp line counts**: unchanged on every stage-1 grid case-view except:
  - b35 (51 -> 0, converted);
  - TB/b37_iface_modport_port (51 -> 101, both views). Its head moved from the type parameter's typespec to the
    modport port view's variable, which now reaches the same object earlier in the walk. Chain away is 0 and toward
    4, and downstream it goes STATUS_DIFF -> IDENTICAL.
- **Downstream** (drivers/dscases.py, both binaries, 108 dirs; evidence/downstream_cases.txt): **10 cases improve and
  none gets worse.**
  - DIVERGENT -> IDENTICAL: TB/b07 and b36.
  - STATUS_DIFF -> IDENTICAL: TB/b16 and b37.
  - EQUIVALENT -> IDENTICAL: TB/b09, b35 and b45, probe r11u45 g13, r11v45 v9 and v11u108 b13_pkg_arr.
  - 92 stay IDENTICAL. 4 keep their verdict: AN/n02 DIVERGENT; TB/b11, b38 and b42 EQUIVALENT. TB/b25 and
    CS/c19 exit 3 on every binary.

## Byte controls (evidence/controls.txt, controls_summary.txt, controls_away.txt)

The controls cover 30 earlier repro dirs of this ground: r11u18, r11u47, r11v47, r11u107, r11u108, v11u108, r11u110,
v11u110, r11u111, v11u111, v11u93b107, r11u120, r11v120, r11u160, r11u273, v11u273, r11u275, v11u275, r11u281,
v11u281, r11u134, r11u113, r11u109, r11u202, v11u202, r11u231, r11u196, r11u183dec, r11u234dec and r11u93. That is
1550 case dirs and 3100 case-views on pristine and the final law, every line with its exit code, paths filtered by
$FENCED before any case was opened.

- **68 moving, 14 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes, lost 0 and chain away 0 on all 68**, 210
  records toward golden.
- Entering STRICT_EQUAL:
  - from stage 1: r11u281repro TI/i03_named_override_ctl, v11u281repro VI/vi17_named_and_default_inst and
    vi42_iface_two_typeparams (pass 281's interface residues, uhdm-cmp 51 lines -> 0);
  - from strict-only: r11u120repro gD/d05_bit_vec (col) and gT/t08_body_localparam_type (line), r11u160repro
    TV/v08 (line), v11u281repro VI/vi21_iface_genblk_sig (line).
- The other movers move inside stage 1 with the same uhdm-cmp line count, or stay where they were (r11u275 TV/tv07,
  v11u281 VI/vi30), lost 0 and chain away 0.
- A draft of law 1 without the anonymous-aggregate abstention was convicted here (see law 1). The final binary moves
  none of those cases.

## Residues (ranked; all wrong on pristine too)

1. **Law 1's open shapes** (grid TB):
   - The imported unqualified override `.T(w_t)` (b08): golden's type parameter takes a bare copy `w_t` (no alias)
     and the signal shares it. Ours lists `pk::w_t` for T. A law minting that copy for T (LAW S's unaliased copy,
     parented at T) is the fix.
   - The `var`-keyword body declaration (b22, b31): golden binds the definition's default `logic`.
   - `.T(T)` through another instance (b24): golden's leaf T is a bare copy.
   - Ordered overrides (y64, y65, Surelog ignoring them): golden keeps the default where ours binds the override.
   - A program (b15): our program instance lists no type_parameter; golden binds `pk::w_t`.
   - Unpacked dimensions (b21).
   - Stage 1 on both binaries, another face: the function local b11, the typedef of T b20, `wire T w` b23, the
     interface modport port view's T typespec instance b37, the interface dims b38, the struct overrides b42 / b44.
   - The anonymous-aggregate targets abstained (the pass 167 / 273 / 275 family).
2. **Law 2's open shapes** (grid AN): the package typedef cases n01 and n02 (stage 1 on both binaries, n02 DIVERGENT
   downstream) and the interface case n10. Each moves toward golden only.
3. **Law 3's open shapes** (grid CS): a TYPE argument (c07, c17). The class_typespec now matches golden, but the
   specialization's type_parameter keeps the stored name `reg_c.T` that emitClassTsParams writes, where golden
   reads the chain `work@hold::r::reg_c::T` (strict `fullname(2)`, moved from `endcol`, toward 3 and away 0). The
   string and bit-vector arguments c24 and the program task local c25 are stage 1 on both binaries.
4. **Located on this ground, not written:**
   - The modport port view of a net-declaration-assignment wire (r11u90repro vx8_strifport, r11v88repro
     v14_ndamodport, `fullname(2)`). Golden's io_decl expression is an unparented net named `w_plain`. Ours is
     parented at the io_decl (`work@dut.u_s.p.mp.w_plain.w_plain`).
   - A struct member written `pk::w_t` inside a type-parameter default struct (v11u93b107 q04): golden binds the
     listing.
   - A member typed T in a module-local typedef (v11u111 y62): golden binds the definition's default.
   - The `q2::row_t` typedef-of-typedef with dims on a module or interface signal (v11u111 y31, x36).
   - Dynamic arrays of classes in interfaces spanning to the declarator's end (r10uvm221 a4_corpus, r10uvm225
     a6_headerforms).
   - An escaped instance name's ref_module end column (v11u110 a36).
5. **The rest of the probe residue**: 165 first records classified on the law sweep
   (evidence/residue_first_records_law.tsv; the base's 184 in residue_first_records_base.tsv). By first field:
   fullname 56, endcol 22, line 19, depth 15, type 14, file 11, col 8, name 7, endline 6, value 4, count 2,
   decompile 1.
6. Items (2) to (7) of the brief beyond the above were not attempted.

Sister-ground faces (ExprEmit / ParamEmit / StmtEmit; reported, not written):

- The type-parameter anonymous struct parenting (r11u47 g2, g10, g12, r11v47 v12, k14_unpacked, t13; ParamEmit
  § tpAnonStructLastParamUser167).
- The struct-fold member names (r11u26 m4, m7, r11u28 a2).
- The package struct typedef stretch (r11u13 b3, r11u24 n4; ParamEmit).
- The folded constants' spans in an elaborated parameter (r11v66 a3_inst66 `endcol`; ParamEmit).
- The package variable typespec end beside an escaped identifier (r10v223 v5_escaped; ParamEmit).
- The generate if-fold reference names (r11u113 c09, c11; ExprEmit).
- The package function call folds (`depth`: r10buvm13 v3_clone13, r10buvm8 v9fold8, r10uvm52 a1).
- The 64-bit cast range constants (r11u109 c04, c06, p06, p07; a Surelog defect, not copied).

## Process

- **Fence.** $FENCED was read fail-closed from tools/probe/r11u107repro/canaudit.sh's FENCED= line through
  drivers/env.sh and never spelled.
  - The gate sweeps dispatched every row themselves.
  - The census ran through the harness filter built from $FENCED.
  - The byteverify mirrors, the binary audit, the draft-sweep byte comparisons and the control path lists were
    filtered by word boundary before any file was opened.
  - gdb ran only on probe and fresh cases copied to scratch. The decode helpers that open databases check $FENCED
    fail-closed.
  - No process of another agent was listed or signalled. Only this pass's own grid, controls and sweep processes
    were stopped, each matched by its exact command line. The main tree was not written. The evidence files were
    checked to hold no fenced name.
- **Drafts superseded** (every reported number is from the final binary):
  - law 1's first cut (a LAW-S-only skip) broke TB/b08 to stage 1, then took `var` declarations and ordered
    overrides;
  - its rebinding moved from LAW S to design-final after r11u45 g10 showed a later rebind;
  - f5a12_chain and the byte controls' anonymous-aggregate cases added their abstentions;
  - law 2's first cut took top-level members (k12, e06) and type-parameter defaults (q04) and called the full-name
    getter.
- Two draft corpus sweeps (on intermediate binaries) read 0 regressions and are not reported as gates.
- tools/probe/r11u291repro: README, 89 case dirs in TB, AN and CS (each first line names its law), drivers (copied
  from r11u289repro with gridsum291.py and ctlsum291.py new), and evidence.
