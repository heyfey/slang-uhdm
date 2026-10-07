# r11u281 — module/type ground: the probe residue by writer (type-parameter array rebinding, interface type parameters)

Base aa8941fd (pass 279). Five laws in UhdmExporter behind `src/R281.h`: each law reads its own `R11U281_<LAW>_OFF`
switch, `R11U281_OFF` drops all five and gives pristine's bytes on 78 of 78 grid case-views, `R11U281_TRACE=<dir>`
logs every firing (and the interface share law's stand-asides). No corpus row moves a byte; **TWELVE PROBE
CONVERSIONS** and two probe changes, both toward golden.

| target | before (base) | after (law) |
|---|---|---|
| pass 275's definition-view type-parameter array shapes and the same-type override (probe, 7 cases) | STRICT_NOTEQUAL `line`/`type` | **7 EQUAL** (r05 is left: residue 3) |
| interface type parameters (probe, 5 cases) | STRICT_NOTEQUAL `fullname(2)` | **5 EQUAL** |
| r11u107repro/grid/t13_iface_tp_struct, r11u18repro/t4 | `fullname(13)`, `line(6)` | `fullname(11)`, `line(2)` (changes toward golden) |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged; 0 byte movers in all three corpora |

## The laws

1. **§ defNetTpPatNestedSig281** (UhdmExporter, inside § defNetTpDimLastInstPat275; switch `R11U281_TPPATNEST_OFF`).
   `localparam type rt_t = id_t [3:0]` is compiled again for every instance, and a definition net declared with it
   reads the LAST instance's array (pass 275). Pass 275 found the instance's array only when the instance signal's own
   typespec was that array with the same span. Two shapes missed it: an unpacked dimension on the net (`rt_t x [2];`:
   our instance signal is an array_var whose element variable (vpiReg) holds the array) and an extra dimension written
   on the net (`rt_t [1:0] x;`, `(* keep *) rt_t [1:0] x, y;`: the definition net's array runs to the declarator,
   1:68-2:13 where the instance's own reads 1:68-1:78). With the law, the instance's array is read through the
   array_var's element variable (or an array_typespec's element) and matched by its START (file, line, column), which
   is the declaration it was compiled from. The copy keeps the definition net's end. Golden i09: definition net x has
   element `logic [1:0]` at the override 8:17-8:28, where ours had the default `logic` 1:38-1:43.
2. **§ tpRebindSpanDiffers281** (UhdmExporter rebindTypeParamElem107, § tpElemRebindDefView107's mint test; switch
   `R11U281_TPREBINDSPAN_OFF`). elabTypeParameter_'s tail rebuilds the definition type parameter's array for every
   instance that does not override the array parameter itself. Its element is bindTypespec's clone of the instance's
   binding, located where that binding is written. § tpElemRebindDefView107 minted only when the binding reads
   different to uhdm-cmp, so an override spelling the default's own type was skipped: `.id_t(logic)` over `= logic`
   (e25, golden element 13:17-13:22, ours 2:27-2:32), and `bit [1:0]` then `logic [1:0]` over `= logic [1:0]` (a11,
   where the last instance's 12:17-12:28 wins). With the law, a binding at another location is rebound too. Two
   conditions apply. First, the binding must come from a NAMED override of the element on the instance or an
   ancestor: an ordered override fills no getTypeParams(), so golden keeps the default (TR/r07, which an early draft
   moved away). Second, the override must not be a `type(expr)` reference that Surelog cannot bind (TR/r13, control
   v11u110repro k01, where golden lists no instance object). The binding must also sit inside an instantiation on
   the chain.
3. **§ tpElabPortRebindSpanDiffers281** (UhdmExporter rebindElabPortTypeParam110, the port twin; switch
   `R11U281_TPPORTSPAN_OFF`). The elaborated port typed `rt_t` reads the array rebuilt for its instance. Its element
   is the instance's binding at the override, even when the binding reads equal to the default (golden e25
   `work@dut.u` port `rt_i`: 13:17-13:22). The same guards as law 2 apply (in the chain, no type reference).
4. **§ ifaceInstTypeParamSharesDef281** (UhdmExporter shareInstTypeParams120, the interface twin of
   § instTypeParamSharesDef120; switch `R11U281_IFTPSHARE_OFF`). writeElabParameters runs for interface instances
   too. An interface instance whose instantiation does not override a type parameter BY NAME lists the definition's
   own type_parameter object, located, with its struct members read through the definition's chain. Golden
   t03_iface_tp, t6, g9, v7 and x10 have `work@ifc.T`, where ours listed an unlocated per-instance copy
   `work@dut.u.T`. The walk now reaches interface instances under modules, generate scopes and interfaces. The law
   stands aside for a named-element packed-array default (rebuilt per instance, § 107 models modules only: TN/n13 and
   TR/r12 moved away under a draft) and for an enum default.
5. **§ ifaceTpUseBindsDefDefault281** (UhdmExporter, run after § tpUseBindsDefDefault160; switch
   `R11U281_IFTPUSE_OFF`). This is the interface twin of § tpUseBindsDefDefault160. A signal `T d;` in an interface
   instance that does not override T by name binds the definition's default object, because compileTypespec falls
   back to the definition's parameter list (golden TI/i02 `work@dut.u.d`: `logic [3:0]` 2:36-2:47). Ours wrote a fresh
   typespec at the declaration's type token, 3:3-3:4, a bare `logic` with NO RANGE: a 1-bit signal that the judge
   never read and the downstream plugin did (DIVERGENT downstream on i02, i04 to i07, i09 and i11; IDENTICAL with the
   law). A rebind requires that the same-named definition signal binds a type parameter's default (or a copy of it at
   the same span), that the instance's typespec is its own, and that the default is not an enum or a named-element
   array.

Every new case names its law on its first line (`// § <law>`).

## Characterization (the base probe residue by first record)

`uhdm-strictcmp --max 100000` ran on all 290 STRICT_NOTEQUAL probe cases at the base, from the pristine sweep, with
goldens from the case driver (`drivers/case.sh`). `evidence/base_heads.tsv` lists, for each case, the head field, the
ancestor chain, the A/B records and the raw full name. The heads by parent > kind:

- 19 `fullname constant>ref_typespec`, 7 `operation>ref_typespec`, 4 `bit_select>operation` and the ref_obj/var_select
  full names: the folded-constant typespec references and expression names (ExprEmit / ParamEmit, the sister's).
- 18 `fullname typespec_member>ref_typespec`, which split into four faces:
  - Importing-chain struct member names in class import copies (golden `q6::p6::t6::a6`, ours `p6::t6::a6`):
    r10sd10repro g6 and v2, r10sd6repro v3, r10uvm198 g198_a_homes, r10uvm202 g202_a_kinds, and in the bit-typespec
    variant r10uvm207 g207_c, e and h. This is ModuleEmit classInheritsContainerImports23 /
    § typedefParentLastWriter134, not attempted (residue 1).
  - The anonymous type-parameter struct parented at its last value-parameter user (golden `work@dut.I.x`, ours `x`):
    r11u47repro g10, g2, r11v47repro v12, v28. Decoded: Surelog's compileParameterDeclaration runs
    `ts->VpiParent(param)` (CompileHelper.cpp) for the value parameter `localparam it_t I`. Ours already models the
    packed-struct shape in **ParamEmit § tpAnonStructLastParamUser167** (a fresh grid on the base reads packed
    structs equal). The open shapes are an unpacked `struct {`, a union with a parameter width, a `b_t = a_t` chain,
    and the function-formal relocation in v28. **That is the sister's file: stopped at the decode** (sister faces).
  - Interface type parameters (t13 and the probe conversions above): this pass.
  - k14_unpacked, n11 and v15 (parameter structs), and v2_kindns: not attempted.
- 16 `line ref_typespec>logic_typespec`: the type-parameter array element (7, this pass), § typeParamChainBorrow45's
  chain copy (r11u45 g9, g10, g13, r11v45 v2, v6, v7: ParamEmit, the sister's), and the vec-dims override names
  y61, y62, y64, y65, y68, y69 and q04, where golden binds `pk::w_t` (the listing object, dims dropped) and ours binds
  a copy named `w_t`. Positional overrides (y64, y65) keep the DEFAULT in golden. Not attempted (residue 2).
- 6 `endcol ref_typespec>class_typespec`: class_typespec spans on a local or a property (`regb #(ub, "ub") lv1`,
  `static box_j #(8) s_j` spanning the name only in golden), a scoped return `fp1::LL`, and dynamic arrays of
  classes in interfaces. The span rules live in TypeEmit's listingSite196 / § classPkgGenericSpecListing53 reshape.
  Not attempted (residue 4).
- 9 `file ref_typespec>logic_typespec`/`int_typespec`: the elaborated param_assign cast constant's typespec left
  unlocated, and the `q2::row_t` parameter typespecs (a27, x38, b07). ParamEmit, the sister's (5 + 3).

## Grid (tools/probe/r11u281repro/cases, 39 case dirs, both views)

`drivers/grid.sh` runs each case in both views on pristine (P), law (L), law + `R11U281_OFF` (OFF) and the law with
each switch off. Every line carries the exit code (`evidence/grid.txt`; `drivers/gridsum281.py` writes
`evidence/grid_summary.txt`).

**78 case-views. OFF == P on 78 of 78. 64 moving, 56 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes. Three
uhdm-cmp line-count changes, all smaller: TI/i07_genblk_el goes 83 -> 0 lines (stage 1 -> STRICT_EQUAL), and
TI/i08_iface_in_iface goes 1502 -> 1480 and 1222 -> 1200, still stage 1.** By attribution, 32 movers return to
pristine under exactly one switch (TPPATNEST 24, IFTPSHARE 4, TPREBINDSPAN 2, TPPORTSPAN 2). The other 32 need a
pair (`evidence/grid_pairs.txt`): TPREBINDSPAN + TPPORTSPAN 14 (the definition parameter and the instance's port are
the same producer), and IFTPSHARE + IFTPUSE 18. Away census (`drivers/away.py` order-blind, `drivers/awaychain.py`
chain-keyed; `evidence/grid_away.txt`): lost=0 on all 64, chain away=0 on 62. The two away are TI/i10_enum_tp in
both views, stage 1 on both binaries: our definition writes the enum type parameter's default as a
`logic_typespec`, the real face, and IFTPSHARE + IFTPUSE spread it (residue 5).

- **TN — § defNetTpPatNestedSig281**: n01_unpacked_net, n02_unpacked_bit_elem, n03_extra_packed,
  n04_two_inst_unpacked, n06_unpacked_2d, n07_genblk_inst, n08_param_depth, n10_macro_decl, n11_crlf_extra_packed,
  n12_two_decl_extra and n14_hdr_two_files (a header included from another file) enter STRICT_EQUAL in both views.
  n09_var_kw_unpacked moves toward golden (no longer diverging, fullname(4) remains: the `var` struct parent face).
  n05_default_inst_ctl stays equal on both. n13_interface_ctl is stage 1 on both, unmoved.
- **TR — § tpRebindSpanDiffers281 / § tpElabPortRebindSpanDiffers281**: r01_same_type_override, r02_bit_then_logic,
  r03_same_override_body_net, r04_override_then_default, r05_default_then_override, r08_macro_override, r09_genblk,
  r10_nested_parent_override and r11_signed_same enter STRICT_EQUAL in both views. r07_ordered_same_ctl is a control,
  unmoved. r06_typedef_override, r12_interface_port and r13_type_ref_ctl are stage 1 on both, unmoved.
- **TI — § ifaceInstTypeParamSharesDef281 / § ifaceTpUseBindsDefDefault281**: i01_local_tp_struct, i02_port_tp_logic,
  i04_ordered_override, i05_two_inst, i06_nested_in_module, i07_genblk (its elaborated view moves from stage 1),
  i11_inst_array and i12_struct_unused enter STRICT_EQUAL in both views. i03_named_override_ctl, i08_iface_in_iface,
  i09_modport_port and i10_enum_tp are stage 1 on both (i08 and i10 move, see above).

Downstream on every case dir with both binaries (`drivers/dscases.py`, `evidence/downstream_cases_{P,L}.txt`): 24
IDENTICAL on both, **10 DIVERGENT -> IDENTICAL** (n03, n11, n12, i02, i04, i05, i06, i07, i09, i11), 3 EQUIVALENT
and 2 DIVERGENT the same on both, none leaving IDENTICAL.

## Byte controls (`drivers/controls.sh`, `evidence/controls.txt`, `evidence/controls_summary.txt`)

1128 earlier repro dirs give 2256 case-views: r11u107, r11u108, v11u108, r11u110, v11u110, r11u111, v11u111, r11u112,
r11u113, v11u113, v11u93b107, r11u120, r11v120, r11u160, r11u271, v11u271, r11u273, v11u273, r11u275, v11u275,
r11u279, v11u279, r11u47, r11v47, r11u18, r11u20, r11u53 and r11v53. Each path list was fence-filtered before any
file was opened. **22 moving, 1 entering STRICT_EQUAL (v11u275repro/cases/VN/vn11_param_depth_two_inst, default
view), 0 leaving, 0 exit-code or uhdm-cmp line-count changes.** The away census (`evidence/controls_away.txt`) reads
chain away=0 on all 22, and lost=0 on 18. The 4 others are r11u273repro TP/t11_iface and v11u273repro VT/vt07_iface_tp
in both views (order-blind lost 2, chain toward 2): the same face as t13, below. f5a24_wdims_override moves its first
field from line(2) to fullname(1) (dump distance 4 -> 2, toward), and vn11's elaborated view from line(3) to
depth(1) (distance 8 -> 5, toward).

## Gates (worktree at aa8941fd + this patch)

Pristine `/tmp/r11u281_bin/pristine` has md5 11a220f100aa6c0856c4f6cc80047c0d, the same as the main tree's build.
Law md5 is f3468624ca02fe42d6908210227fa7e3. Both link slang 12.0.0+545f88b2e.

Both sweeps ran `tests/sweep.sh --jobs 3` with `SLANG_UHDM` exported, workdirs `/tmp/r11u281_P` and `/tmp/r11u281_L`
(equal length). Each exited 1 on the law-index check alone, because the committed index is stale at the base. This
patch carries the regenerated `tests/LAWS.md`, and `scripts/law_index.py --check` reads current.

- **probe**: pristine EQUAL 3797 + STRICT_NOTEQUAL 290, regressions=0. Law **EQUAL 3809 + STRICT_NOTEQUAL 278,
  regressions=0 conversions=12 changes=2**:
  - law 1: r11u110repro/grid/f2/i09_unpacked_child_ovr `line(2)`, r11u110repro/grid/f2/i11_attr_wdims_child
    `line(2)`, v11u110repro/brk/v1/c08_unpacked_2state_elem_ovr `type(1)`, v11u110repro/brk/v1/d01_attr_two_decl
    `line(2)` and v11u110repro/brk/v1/d02_attr_two_attrs `line(2)`, all -> EQUAL.
  - laws 2 + 3: r11u110repro/grid/e1/e25_ovr_same_ctl `line(4)` and v11u110repro/brk/v1/a11_bit_vs_logic
    `line(20)`, -> EQUAL.
  - laws 4 + 5: r11u20repro/t6, r11u47repro/arms/g9, r11v47repro/arms/v7, r11v53repro/grid/x10_iface_import_shadow
    and v11u113repro/grid/f2/t03_iface_tp, all `fullname(2)` -> EQUAL.
  - changes (law 4), both toward golden:
    - r11u107repro/grid/t13_iface_tp_struct `fullname(13) -> fullname(11)`. The first record #6 stays a struct
      member ref full name: golden has `a` (the struct unparented by `assign u.d = i`), and ours now has
      `work@ifc.T.a` where it had `a` on the copy. Dump distance is 10 -> 11, order-blind lost 2, chain-keyed away 0
      and toward 2.
    - r11u18repro/t4 `line(6) -> line(2)`. The instance var `a` typed `IT = int` remains: its definition net lists no
      typespec, so law 5 cannot see the default.
  - Also moving: r11u45repro/g13, whose detail is unchanged at `line(2)`, dump distance 3 -> 1.
- **surelog**: default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2 on both binaries. regressions=0
  conversions=0 changes=0. Every UVM row, Earlgrey_0_1 d/t, Rggen d and BlackBePipeInt d/t stay CMP_EQUAL.
- **uhdm2rtlil**: 803 CMP_EQUAL / 1 CMP_NOTEQUAL / 67 SLANG_REJECT in both modes on both binaries, regressions=0.
- **downstream**: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT. The law csv is byte-identical to
  the pristine csv and equal (sorted) to `results/downstream_uhdm2rtlil.csv`.
- **byteverify** (`tools/probe/r11v75repro/byteverify.sh`, SELFCHECK=1, run on fence-filtered hard-link mirrors from
  `drivers/bvmirror.sh` with the 8 fenced row-mode databases left out; `evidence/byteverify_corpus.txt`): **surelog
  MOVERS 0 / 952** (SELFCHECK 951 / 952), **uhdm2rtlil 0 / 1608** (1607 / 1608), **downstream 0 / 805** (804 / 805).
  Probe: **15 / 4087** databases move (`evidence/byteverify_probe.txt`).
- **firing census** (`drivers/tracecensus.sh`): the law binary ran under `R11U281_TRACE` over the probe cases and
  both corpora in both modes with the fence filter, and the result was frozen as `evidence/predict.txt` BEFORE the
  law sweep. It has 15 lines, all probe. Corpus predictions are 0, and the corpora read 0 movers. **The 15 probe
  movers match the prediction exactly.** Positive control: the census sees every probe firing, and the TI grid's
  trace shows IFTPUSE and IFTPSHARE lines.
- **away census** on the 15 probe movers (`evidence/probe_movers_away.txt`): chain-keyed away 0 on all 15, lost 0 on
  14. t13 reads lost 2, as described above.
- **canaries**: surelog ok=52 changed=0 and uhdm2rtlil ok=16 changed=0. `ctcan2.sh` passes with EXPECT_UNKNOWN=1
  (surelog) and EXPECT_UNKNOWN=6 (uhdm2rtlil) (`evidence/gates.txt`).
- **binary-path audit** (the cmds.txt path list was fence-filtered first): 3265 of 3315 name each sweep's own binary,
  the other 50 carry no slang line, and none names another binary.
- **determinism** (`drivers/det.sh`, `evidence/determinism.txt`): three concurrent draws of the law binary on
  Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes. Every one of the 12
  row-modes that writes a database reads one hash, equal to both sweeps' hashes (Scoreboard and Rggen testflags
  write none).

## Residues (ranked; all wrong on pristine too)

1. The 278 probe cases still open. On this ground:
   - **The importing-chain struct member names** in class import copies (8 cases: r10sd10repro g6 and v2,
     r10sd6repro v3, r10uvm198 g198_a_homes, r10uvm202 g202_a_kinds, r10uvm207 g207_c, e and h). Golden's copy of a
     package struct in a class reads `q6::p6::t6::a6` through the importing package (ModuleEmit
     classInheritsContainerImports23 with § typedefParentLastWriter134's last-writer parent). Not attempted.
   - **The vec-dims type-parameter override names** (v11u111repro/brk/f6 y61, y62, y64, y65, y68, y69,
     v11u93b107repro q04). With `.T(pk::w_t [1:0])`, golden types the elaborated signal with the package listing
     object `pk::w_t` itself, dropping the dims, where ours binds a copy named `w_t`. A positional `#(pk::w_t)` keeps
     the DEFAULT in golden (y64, y65). The writer of our copy was not located.
   - **class_typespec spans** (6 cases: r10sd1repro b27_inline_method_foreign, r10v119repro v119_j, r10uvm56repro
     v3_hierpath, r10v150repro v150_f1, r10uvm221repro a4_corpus, r10uvm225repro a6_headerforms).
   - k14_unpacked, r11u24repro n11, r11v21repro v15 and r11v74repro v2_kindns (struct member full names). Not
     attempted.
2. **The interface struct type parameter unparented by an assignment through the interface** (t13_iface_tp_struct,
   r11u273repro TP/t11_iface, v11u273repro VT/vt07_iface_tp). In golden, `assign u.d = i` writes the cont_assign
   that unparents the shared struct (§ contAssignLhsTsUnparented134's reset through a hier_path left side), so its
   members read bare `a`. Law 4 now lists the definition's object (parented at T, `work@ifc.T.a`) where pristine
   listed a copy that happened to read `a`. Order-blind lost 2, chain-keyed toward 2, objects differing 13 -> 11.
   The fix is § typeParamStructLastNetParent273's hier_path left side for interfaces.
3. v11u93b107repro/brk/r05_rt_ovr_samename: an instance overriding `rt_t` itself whose port golden types with the
   definition's current array (another instance's binding). Not modelled.
4. r11u18repro/t4: an interface signal whose definition net lists no typespec (law 5 cannot read the default).
5. TI/i10_enum_tp, TR/r06_typedef_override, r12_interface_port, r13_type_ref_ctl, TN/n13_interface_ctl,
   TI/i03, i08 and i09 are stage 1 on both binaries. Our definition writes an enum type-parameter default as a
   `logic_typespec` (i10: the share law spreads it, chain away 12 on that stage-1 case). Interface `localparam type
   rt_t = id_t [3:0]` arrays are not rebuilt per instance (§ tpElemRebindDefView107 is module-only).
6. Pass 279's and the brief's items (2) to (7) beyond the above were not attempted.

## Sister-ground faces (reported, not written)

- **ParamEmit § tpAnonStructLastParamUser167**: the anonymous type-parameter struct parented at its last
  value-parameter user. The open shapes are an unpacked `struct {` (r11u47repro g10), a union with a parameter width
  (g2), a `type b_t = a_t` chain (r11v47repro v12), and the function-formal relocation (v28: golden locates the
  struct at the second formal's `it_t` token). Golden `work@dut.I.x`, ours `x`. A fresh grid on the base (unit
  cases, removed) read the packed top-level shapes equal and those four open.
- ParamEmit § typeParamChainBorrow45 (r11u45 g9, g10, g13, r11v45 v2, v6, v7) and the elaborated cast constant's
  unlocated typespec (r10earl_repro ss, tl, ud, ue, r11u108repro f4 c12_const_fold). The 19 folded-constant
  `ref_typespec` full names and the expression-name heads (ExprEmit).

## Process notes

- Binaries were frozen under `/tmp/r11u281_bin` (`chmod 555`) before every measurement. The law binary was
  re-frozen after each refinement, and every gate (grid, census, sweep, byteverify, determinism, controls, away
  census) was rerun on the final binary f3468624. The first census, on a superseded binary, was stopped by its own
  task id. Pristine was never rebuilt after its freeze.
- Refinements made before delivery, each found by a grid or a control:
  - the ordered-override guard (TR/r07 moved away);
  - the packed-array and enum stand-asides of laws 4 and 5 (TN/n13, TR/r12 and TI/i10 away);
  - the type-reference and in-chain guards of laws 2 and 3 (control v11u110repro k01 chain away 4).
- Every corpus or probe path list was fence-filtered before any file was opened. Every tool call through a variable
  was guarded with `[ -x ]`. No process was signalled besides this pass's own census task. Nothing was written
  outside the worktree and `/tmp/r11u281_*`.
- The drivers are copied from tools/probe/r11u279repro/drivers (`gridsum281.py` and the switch lists renamed).
