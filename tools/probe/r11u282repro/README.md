# r11u282 — pass 282, the expression/parameter ground (ExprEmit, ParamEmit)

Implementer of pass 282 (pair A, refill after pass 280), base 8b0e9bffd. Sixteen laws in `src/ExprEmit.cpp`
behind `src/R282.h`: ten laws and six refinements, each read through `r11u282On("R11U282_<LAW>_OFF")`.
`R11U282_OFF` drops all sixteen and gives pristine's bytes on 1354 of 1354 grid case-views. `R11U282_TRACE=<dir>` logs
every firing and abstention, one file per process, first line `OUT <-o path>`. The design-final drain
`foldTsNameFinalDrain282` is called at the end of ParamEmit's `drainShareDefParamTs`, after pass 280's drain. That
call is the only ParamEmit change.

This pass was resumed. The first implementer was stopped by the account limit after it wrote the ten laws, the
grids C, D, F, G, H, I and L, and a law sweep. Every number below comes from the resumed runs on the final binary
(law4). The draft numbers on disk were all rerun. The draft binary (law2, md5 57aa95ca, which is the ten laws
alone) failed the byte controls this pass added: three control cases left STRICT_EQUAL, and fourteen stage-1
control case-views moved records away. Six refinements fix those breaks (section "The refinements" below).

**Verdict.** No corpus row converts or moves. Byteverify reads 0 of 2560 corpus databases and 0 of 805 downstream
databases moving. **TEN PROBE CONVERSIONS**, no probe change, no regression. The firing census was frozen before
the law sweep. Its writer tags name exactly the ten byte movers, and it names no corpus database. The Surelog corpus
stays at zero open rows: every row-mode is CMP_EQUAL except the known failures LogicTypespec d/t and Scr1SvTests
d/t. uhdm2rtlil stays at 1606 + 0. Downstream reads 803 / 66 / 2 / 0, and its csv is byte-identical to pristine's
and to results/downstream_uhdm2rtlil.csv.

All ten conversions are generate-scope **fold reference names**. Each is the `vpiFullName` of the `ref_typespec`
under a parameter that was folded into a constant. Item (1)'s "other branches" bucket names these cases. The fresh
csv rows below come from the law sweep's `probe.csv`; `results/` is untouched.

    r10earl47repro/a3_earl47,EQUAL,,equal            (was differ:fullname(4))   § genCaLhsIpsBoundInPlace282
    r10earl76repro/g2_orig76,EQUAL,,equal            (was differ:fullname(13))  § genProcOpFoldInPlace282
    r10earl95repro/g5_hop95,EQUAL,,equal             (was differ:fullname(2))   § genCaReplCountInst282
    r10earl_repro/pu20,EQUAL,,equal                  (was differ:fullname(1))   § genProcFoldTsInstFromSelect282
    r10earl_repro/vo,EQUAL,,equal                    (was differ:fullname(1))   § caHierSelBoundName282
    r10uvm99repro/g99_a7_shapes,EQUAL,,equal         (was differ:fullname(4))   § tfFoldCaseInsideBoundModule282
    r10v64repro/v7_inst64,EQUAL,,equal               (was differ:fullname(16))  § genCaSelBoundNestedOwner282 + § genCaCastFoldOrphanName282
    r11u112repro/grid/v/v08_comb,EQUAL,,equal        (was differ:fullname(4))   § genProcFoldTsInstFromSelect282
    r11u113repro/grid/v/v07_genfor_comb_ctl,EQUAL,,equal (was differ:fullname(2)) § genProcOpFoldInPlace282
    r11u114repro/grid/f2/b07,EQUAL,,equal            (was differ:fullname(2))   § tfFoldCaseInsideBoundModule282

The first differing record of each case at the base. A is golden and B is pristine. Every record is a
`ref_typespec`. Source: evidence/residue_first_records_base.txt.

| case | golden | pristine |
|---|---|---|
| a3_earl47 | `work@a3_earl47.gen_x[0].gen_y[0].p_lhs` | `work@a3_earl47.gen_x[0]` |
| g2_orig76 | `work@g76origtop.u_o.gen_o` | `work@g76origtop.u_o` |
| g5_hop95 | `work@toph95.u8` | `work@toph95.u8.c_in` |
| pu20 | `work@pu20` | `work@pu20.gi` |
| vo | `work@votop.u.st.addr[16+:1].addr` | `work@votop.u` |
| g99_a7_shapes | `work@iota99` | `work@iota99.h1` |
| v7_inst64 | `` (empty) / `work@topV7.k1` | `work@topV7.k1.g_if` / `work@topV7.k1.g_if.n` |
| v08_comb | `work@top` | `work@top.g[0]` |
| v07_genfor_comb_ctl | `work@top.g[0].a` | `work@top` |
| b07 | `work@top` | `work@top.dec` |

## The decode: where golden's reference name comes from

Surelog folds a parameter read in an elaborated instance through `getValue` in
`third_party/Surelog/src/DesignCompile/CompileExpression.cpp`. On the netlist path it clones the instance's
`param_assign` Rhs (`clone_tree`) and sets **`result->VpiParent(param_ass)`**. The new constant's `ref_typespec`
is then named by UHDM's ComputeFullName over its parent chain, so where that clone ends up decides the name:

1. **The clone stays at the param_assign.** The reference reads the instance (`work@top`). This happens when the
   expression that holds the clone does not re-parent its operands. CompileExpression's concatenation and
   replication branch and its unary-operator branch (`paUnary_Minus`, `paUnary_Tilda`, `paUnary_Not`,
   `paUnary_BitwOr`, ...) push the operand without calling `VpiParent`. A case item and an inside-range bound behave
   the same way.
2. **The clone is re-parented by the holder.** The reference reads the holder's chain: the select's full name, or
   the generate scope a statement sits in. Binary operators re-parent their operands, for example
   `opL->VpiParent(operation)`.
3. **The whole assignment is re-cloned.** `UhdmWriter::writeCont_assign` (UhdmWriter.cpp) re-clones a cont_assign
   in several cases: when its left side is a ref_obj that `bindVariable` finds and its right side is an operation;
   when its right side reduces to a constant; when its right side holds a constant of `vpiSize -1`
   (`DetectUnsizedConstant`); and on the typed-operation (cast) path. The clone re-parents every constant in the
   tree, so references read the chain inside the clone. Without such a re-clone, the getValue constants keep the
   param_assign as their parent, and their references read the instance.

Our emitter wrote these names in three places: the generate-scope branches of `emitExpr`, `genLpUseFoldBound47`, and
the module-body generate-scope copy. Each place chose the instance, the generate block or the select by emission
site, and disagreed with the others by depth. The laws below set the name golden's chain gives. They work at
emission where the holder is known there, and design-final over every cont_assign where the left side and the
whole right side are needed. No law changes an object, a parent, a binding or any judge-read field. Only
`vpiFullName` of a `ref_typespec` changes. The one exception is § genCaCastFoldOrphanName282, which also detaches
the reference's `vpiParent`; no comparator field and no uhdm2rtlil reader looks at that.

## The laws

### § genCaLhsIpsBoundInPlace282 (ExprEmit `lhsIpsBoundInPlace282`, design-final) — `R11U282_LHSIPSINPLACE_OFF`

A parameter folded as the base or width of an indexed part select on the **left side** of a generate scope's
continuous assignment (`assign p_lhs[LPX +: 4] = 4'hA;`). Golden's reference reads the select's chain
(`work@a3_earl47.gen_x[0].gen_y[0].p_lhs`). Our three writers disagreed by generate depth. The law sets the name
on every generate-scope cont_assign whose left side is an indexed part select. Interfaces abstain, because golden
names the instance there. The law is narrowed by § genCaLhsIpsBoundCloneOnly282. Trace `LHSIPSINPLACE <old> ->
<new>`, `LHSIPSINPLACE_ABSTAIN interface`. Grid: L, D (`*_lhsips`).

### § genCaLhsIpsBoundCloneOnly282 (inside the law above) — `R11U282_LHSIPSCLONE_OFF`

The select's chain is golden's name **only when writeCont_assign re-clones the assignment**: the right side
reduces to a constant (`= 4'hA`, `= 2'b10`) or holds an unsized constant (`= '1`). With any other right side
(`= a[1:0]`, `= a[1:0] | 2'd0`) no re-clone is made, so golden reads the instance (`work@top`). This holds in a
for-generate and in an if-generate. The law moved the for-generate cases away from pristine, which already wrote
the instance there. On the if-generate cases, the refinement writes the instance where pristine wrote the generate
block. The L grid used `'1` on every right side, which is why the draft passed it. Trace `LHSIPSCLONE noclone
<name>`. Grid: N (`ips_*`).

### § genCaSelBoundNestedOwner282 (ExprEmit `genCaSelBoundNestedOwner282`, design-final) — `R11U282_CASELBOUND_OFF`

A parameter folded as a part select's bound, or as an indexed part select's base or width, where the select is
**nested under an operation** (`b[P +: 2] | 8'd0`) on the right side of a generate scope's continuous assignment.
Golden reads the select's own full name (`work@wrap.u.g[0].b`) when the left side is a plain name bound to a
signal declared **outside** the generate scope; writeCont_assign's `bindVariable` leg re-clones such an assignment.
For any other left side (a select, a member path, a generate-local signal) golden reads the owning instance
(`work@wrap.u`), as in r10v64repro/v7_inst64 `assign q2 = n[P +: 1] | 4'd0` with `q2` declared in `g_if`. Pass
256's § genIpsBoundOwner256 keyed the same choice on for- versus if-generate, which its grid had confounded with
the left side. A generate-local parameter's fold (genLpUseFoldBound47) keeps its declaring scope. A select that is
the whole right side is left alone. Interfaces abstain. Trace `CASELBOUND <old> -> <new>` and
`CASELBOUND_ABSTAIN interface|lhs <kind>|genlocal`. Grid: I, D.

### § genCaSelBoundImplicitLhs282 (inside the law above) — `R11U282_CAIMPLICIT_OFF`

A left-side name that is declared nowhere (not in the enclosing generate scopes and not among the instance's nets,
variables, array nets or ports) is an **implicit net**. `bindVariable` does not find it, so writeCont_assign makes
no re-clone and golden reads the instance (`assign imp = ^a[W:0]`, v11u262repro VL/vl13 and vl41: `work@top.u`).
The draft classed it as an outer name and moved these two control cases (four case-views) away from STRICT_EQUAL.
Trace `CAIMPLICIT <name>`. Grid: M (`imp_*`, `z_z2`, `z_z13`).

### § genCaSelBoundUnsizedClone282 (inside the law above) — `R11U282_CAUNSIZED_OFF`

A right side that holds an **unsized constant** anywhere (`'0`, `'1`) is re-cloned by writeCont_assign's
`DetectUnsizedConstant` leg, whatever the left side is. The select bound's reference then reads the select's name,
as for an outer plain left side (`assign y6[g] = c[g] ? '0 : x[S:0]`, r11u192repro/cases/B/b11_genfor_unsized:
golden `work@top.gb[0].x`). The draft wrote the instance there and moved that control case (both views) away from
STRICT_EQUAL. The decode came from grid M `tn_*`: the ternary was not the distinguisher. `c[0] ? '0 : x[S:0]` reads
the select, and `c[0] ? 8'd0 : x[S:0]` reads the instance. The same rule converts the module-parameter shapes that
pristine also had wrong (`b_mp_*`, `tn_*`, `z_z4` `x[S:0] | '1`, `z_z11` a member path). The test is a recursive
search of the right side, including indices, ranges, path elements and call arguments, for a constant with
`vpiSize == -1`, as DetectUnsizedConstant does. Trace `CAUNSIZED <instance>`. This tag is a classification, not a
write. Grid: M.

### § caHierSelBoundName282 (in the same drain) — `R11U282_CAHIERBOUND_OFF`

The same choice for a part select or an indexed part select that is the **last element of a member path**
(`|st.addr[BW +: 1]`, r10earl_repro/vo). When the select is nested under an operation, a plain outer left side (or
an unsized re-clone) reads the chain through the path (`work@votop.u.st.addr[16+:1].addr`, ComputeFullName over
the select, the path's text name and the scope). Any other left side reads the instance. This holds in a module
body as in a generate scope; definition listings are excluded. A path that is the whole right side of a generate
scope's assignment reads the instance. Trace `CAHIERBOUND <old> -> <new>`. Grid: H.

### § genCaCastFoldOrphanName282 (in the same drain) — `R11U282_CASTORPHAN_OFF`

A parameter folded as the operand of a **cast that is the whole right side** (`assign q1 = W'(P)`,
r10v64repro/v7_inst64) when the left side is a select or a generate-local signal. Golden reaches this assignment
through writeCont_assign's typed-operation clone, which has no parent, so the reference's ComputeFullName reads
empty. Ours named the scope. The reference's stored name is cleared and it is detached from its constant, while the
constant keeps it as its `Typespec`, so its chain reads empty too. Trace `CASTORPHAN <old>`. Grid: I (`*_cast_*`).

### § genCaReplCountInst282 (ExprEmit, the copy and mint branches of the generate cont_assign fold) — `R11U282_CAREPLINST_OFF`

A module parameter (header or body localparam) folded as the **count of a replication** in a generate scope's
continuous assignment whose left side is not a plain name (`assign q[3] = {W{e_i[0]}}`,
r10earl95repro/g5_hop95). The count is the concatenation branch's unparented getValue clone at the instance's
param_assign, so golden reads `work@toph95.u8` where ours wrote the if-generate scope. A whole left side
(`assign b1 = {W{e_i[0]}}`) keeps the scope; a draft without that gate moved r10earl95repro/g2_depth95 and
r10v94repro/v4_ctx94 away. Trace `CAREPLINST <instance>`. Grid: C, D (`*_repl`).

### § genCaReplCountUnsizedClone282 (ExprEmit `genCaReplCountUnsizedClone282`, design-final) — `R11U282_REPLCLONE_OFF`

The same count in an assignment whose right side holds an **unsized constant** (`assign z[7:0] = {P{b[0]}} | '0`).
The unsized re-clone re-parents the count at the replication, so golden reads the generate scope's chain
(`work@wrap.u.g[0]` in a for-generate, `work@wrap.u.g` in an if-generate). § genCaReplCountInst282 had written the
instance there, which broke the if-generate shape (pristine was right). Pristine wrote the instance in the
for-generate and the whole-left-side shapes; this law converts those. Interfaces abstain. Trace `REPLCLONE <old> ->
<new>`. Grid: N (`rep_*`).

### § genProcOpFoldInPlace282 (ExprEmit, the § genScopeProcOpFoldTs75 branch) — `R11U282_PROCOPINPLACE_OFF`

Pass 75 wrote the owning instance for every fold of a wildcard-imported package parameter under an operation in a
generate-scope process. Its witness was `{N{x}}`. That is golden's name only when the operation directly holding
the fold leaves the clone at the param_assign. Any other operation chain re-parents the clone, so the reference
reads ComputeFullName in place. Under a select (`a[w][P-1]`, `b[P-1:0]`) that is the select's name
(`work@top.g[0].a`, r11u113 v07_genfor_comb_ctl). Under the statement (`r[1] = NB + ND`, r10earl76 g2_orig76) it is
the generate block's (`work@g76origtop.u_o.gen_o`). Trace `PROCOPINPLACE select|stmt <param>` and
`PROCOPINPLACE_ABSTAIN concat|<holder kind>`. Grid: G.

### § genProcOpFoldUnaryKeepsInst282 (inside the law above) — `R11U282_PROCOPUNARY_OFF`

A **unary operator** directly holding the fold (`~P`, `-P`, `+P`, `!P`, `|P`, `a & ~M`) also leaves the clone at
the param_assign, because CompileExpression's `paUnary_*` branch does not re-parent its operand. Golden reads the
instance (r11u116repro/grid/f1 `pk_*_ac` `(a[c] & ~M) == 32'd0`: `work@dut`). The draft wrote the statement's
scope there. That moved fourteen stage-1 control case-views 2 records away, and the fresh grid U `pk_*` cases away
from STRICT_EQUAL. A cast holder keeps the law (`32'(P)`, U `pk_c1` and `pk_c2`). Trace `PROCOPUNARY <param>`.
Grid: U.

### § genProcCatFoldInst282 (ExprEmit, the § genProcFoldTsKeepsScope154 branch) — `R11U282_PROCCATINST_OFF`

For a module parameter folded in a generate-scope process, a fold that is directly an operand of a
**concatenation or a replication** (`{P, 1'b0}`, `{P{1'b1}}`) keeps golden's clone at the param_assign. The
reference reads the instance (`work@top`), not the generate block that the operation rule keeps. Trace
`PROCCATINST <old> -> <new>`. Grid: G (`*_cat_*`, `*_repl_*`).

### § genProcUnaryFoldInst282 (inside the law above) — `R11U282_PROCCATUNARY_OFF`

The same rule for a fold directly under a **unary operator** (`~P`, `a & ~P`, `-P + a`, `32'(|P)`), for module
parameters and module localparams in for- and if-generate processes. Pristine wrote the generate block (`work@top.g[0]`)
where golden reads `work@top`. Trace `PROCCATUNARY <instance>`. Grid: U (`mp_*`, `lp_*`).

### § genProcFoldTsInstFromSelect282 (ExprEmit, the § genProcFoldDeclTsScopeNamed167 neighbourhood) — `R11U282_PROCSELINST_OFF`

The generate-level drop in that branch counts levels from the generate block's path. Inside a nested select (the
width of an indexed part select that is a var_select's element, `cl_rdata[i][{off_i, 3'b0} +: FW]`), the prefix
is the select's path, one level longer, so the drop left the generate block (`work@top.g[0]`). Golden's clone sits
at the instance's param_assign and reads the instance (`work@top`, r11u112 v08_comb and r10earl_repro/pu20).
Trace `PROCSELINST <old> -> <new>`. Grid: G (`*_vs*`).

### § genProcIpsBoundInst282 (ExprEmit, the § genForReplCountOwner192 site) — `R11U282_PROCIPSINST_OFF`

The getValue clone of a wildcard-imported package parameter written directly as an indexed part select's bound
inside a generate-scope **process** (`z[w] = b[w +: P]`) stays at the param_assign. The reference reads the
instance, where ours wrote the generate block. Trace `PROCIPSINST <old> -> <new>`. Grid: G (`*_ipsw_*`, `*_ipsd*`).

### § tfFoldCaseInsideBoundModule282 (ExprEmit, the same site) — `R11U282_TFCASEINS_OFF`

In a module function or task, a wildcard-imported package parameter written directly as a **case item**
(`case (x) P_LIT:`, r11u114 b07) or as an **inside-range bound** (`x inside {[PA:PB]}`, r10uvm99 g99_a7_shapes) is
golden's getValue clone at the module's param_assign. The reference reads the module (`work@top`), not the
subroutine (`work@top.f`). An operand under further arithmetic (`[P-1:P+1]`) and a plain inside member (`{P, 1}`)
keep the subroutine. Trace `TFCASEINS <old> -> <new>` and `TFCASEINS_ABSTAIN <old>`. Grid: F, D (`*_fn_task`).

## The grid (cases/, both views, every line with its exit code)

drivers/gridall.sh runs every case dir in the default view (`d`) and the elaborated view (`e`, `--elabuhdm` against
Surelog `-elabuhdm`). It runs each on pristine, on the law, and on the law with `R11U282_OFF`. drivers/attrib.sh
then reruns every mover with each of the sixteen switches off alone. The output is evidence/gridall.txt,
gridsum.txt, attrib.txt and attrib_sum.txt, with family.txt summarising them.

Totals: **677 case dirs, 1354 case-views, 458 moving, 391 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes,
0 uhdm-cmp line-count changes.** `R11U282_OFF` gives pristine's bytes on **1354 of 1354** case-views.

| family | dirs | views | moving | entering | mv EQ both | mv still differ | mv stage1 both | = EQ | = stage1 | = differ | rc!=0 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C | 78 | 156 | 14 | 10 | 0 | 2 | 2 | 138 | 4 | 0 | 0 |
| D | 26 | 52 | 16 | 8 | 0 | 2 | 6 | 26 | 8 | 2 | 0 |
| F | 24 | 48 | 4 | 4 | 0 | 0 | 0 | 44 | 0 | 0 | 0 |
| G | 114 | 228 | 84 | 74 | 10 | 0 | 0 | 120 | 24 | 0 | 0 |
| H | 82 | 164 | 68 | 54 | 0 | 10 | 4 | 94 | 0 | 2 | 0 |
| I | 192 | 384 | 136 | 122 | 12 | 0 | 2 | 236 | 6 | 6 | 0 |
| L | 35 | 70 | 20 | 20 | 0 | 0 | 0 | 43 | 7 | 0 | 0 |
| M | 38 | 76 | 30 | 28 | 0 | 2 | 0 | 42 | 2 | 2 | 0 |
| N | 42 | 84 | 38 | 34 | 0 | 0 | 4 | 38 | 8 | 0 | 0 |
| U | 46 | 92 | 48 | 37 | 11 | 0 | 0 | 40 | 4 | 0 | 0 |
| all | 677 | 1354 | 458 | 391 | 33 | 16 | 18 | 821 | 63 | 12 | 0 |

"mv EQ both" means STRICT_EQUAL on both binaries with different bytes. These are elaborated-view or
definition-listing names that the strict walk does not reach as a first difference. The away census reads 0 on each.

Coverage, by family and the law each case names in its first line:
- **C** (§ genCaReplCountInst282): a replication count in for- and if-generate continuous assignments. It covers
  header parameters (`mp`), body localparams (`lp`) and imported package parameters (`pk`). The holders are a
  direct bit select, a bit-select index, a concatenation, a concatenation under an operation, indexed part-select
  base and width, an operand, a part-select bound, a ternary and its condition. The `rl_*` left sides are a bit
  select, a concatenation, a concatenation of selects, a member path, a part select and a whole name. The `rp_*`
  instance depths and overrides are a top, a child, two children, an override and 8-bit widths.
- **D** (mixed): instance depths 2 and 3 for four of the laws; an interface body (the drain laws abstain); a
  class method `case` (stage 1 on both binaries); a function and task; macro-born text.
- **F** (§ tfFoldCaseInsideBoundModule282): case items (`case`, `casez`), inside ranges, a plain inside member, an
  operand, a bit select and a ternary in a module function, for `mp`, `lp` and `pk`.
- **G** (process laws): always_comb in for- and if-generates. The fold is a direct bit select, a bit-select index,
  a concatenation, a concatenation under an operation, indexed part-select base and width (direct and nested), an
  operand, a part-select bound, a replication, a ternary, var_select bounds, widths, indices and part selects, and
  generate-local parameters (`gl_*`).
- **H** (§ caHierSelBoundName282): member paths ending in a part select or an indexed part select. They appear
  under a unary or binary operation or as the whole right side, with plain, select and generate-local left sides,
  in a top module, a child and a generate scope.
- **I** (§ genCaSelBoundNestedOwner282, § genCaCastFoldOrphanName282): nested and direct selects, concatenations,
  ternaries and casts. Each has a whole (`_w`), select (`_s`) and generate-local (`_l`) left side, in for- and
  if-generates, at one to three generate levels (`g0`, `g1`), with an implicit-variable and module-variable left
  side (`*_iv`, `*_mv`, `*_mvar`).
- **L** (§ genCaLhsIpsBoundInPlace282): left-side indexed part-select base and width, part-select bounds and an
  operation bound, at one and two for-generate levels, in an if-generate, and with a generate-local parameter.
- **M** (§ genCaSelBoundImplicitLhs282, § genCaSelBoundUnsizedClone282): implicit nets in for- and if-generates
  and at module level. The unsized and sized pairs (`'0` / `8'd0` / `0`, `'1`) appear in ternary branches and
  conditions, with constant and genvar indices, part and indexed part selects, member paths, a body assignment, a
  delay and a generate-local parameter. Package parameters are written as a literal and as `$clog2`, in a top
  module and a child.
- **N** (§ genCaLhsIpsBoundCloneOnly282, § genCaReplCountUnsizedClone282): left-side indexed part selects whose
  right side is a signal, an operation, a literal, an unsized constant or a parameter select. Replication counts
  appear under unsized and sized right sides and under whole and select left sides, for the eight fold sites
  `q1` to `q8`.
- **U** (§ genProcOpFoldUnaryKeepsInst282, § genProcUnaryFoldInst282): every unary operator over package, header
  and localparam parameters in for- and if-generate processes; casts and conditional holders as controls;
  continuous-assignment controls (`ca_*`).

Attribution (evidence/attrib_sum.txt). Each mover is listed with the switches whose single-off run changes the
law's bytes: CASELBOUND 118, CAHIERBOUND 68, PROCOPINPLACE 36, LHSIPSINPLACE 36, PROCCATINST + PROCCATUNARY 36,
CASELBOUND + CASTORPHAN 24, PROCSELINST 24, CASELBOUND + CAUNSIZED 22, PROCIPSINST 20, CAREPLINST 18,
PROCCATINST 18, LHSIPSCLONE + LHSIPSINPLACE 16, REPLCLONE 8, TFCASEINS 6, CAHIERBOUND + CAUNSIZED 4,
CAIMPLICIT + CASELBOUND 2, PROCIPSINST + PROCOPINPLACE 2 (D/pk_iface_proc). A pair means each of the two switches
alone moves the bytes. This is a refinement and its law, or two laws on one assignment.

**Refinement switch controls** (drivers/refsw.sh, evidence/refsw.txt). Every case-view of families G, I, L, M, N
and U runs with each refinement switch off alone. 154 case-views move: CAUNSIZED 36, PROCCATUNARY 36,
PROCOPUNARY 34, LHSIPSCLONE 24, REPLCLONE 14, CAIMPLICIT 10. The law reads STRICT_EQUAL on 144 of them, and with
the switch off 129 of those 144 leave STRICT_EQUAL. Every refinement therefore restores its break, or its
conversion, when switched off.

## The away-moved census (chain-keyed; tools/probe/r11u272repro/drivers/awaychain.py with strictcmp_x)

- Grid: **chain away 0 on all 458 movers**, 562 records toward golden in total (evidence/away_grid.txt).
- Positive control: 23 sampled movers (every twentieth) with the binaries swapped. 21 read away 1 or 2. The other
  two (D/pk_d2_lhsips d, N/ips_lp_if_par d) are stage-1 movers whose moved records agree with golden on neither
  binary (toward 0). See evidence/away_poscontrol.txt.
- Controls: **chain away 0 on all 148 control movers** (evidence/away_controls.txt). Toward is 0 on 22 of them,
  all stage 1 on both binaries.

## Gates (law binary law4 md5 0b81965c32da819f870f80f4b3447689; pristine d072965260dff2559869f224ede4b3f1 = the main tree's build at the base)

Both binaries were frozen under /tmp/r11u282_bin before any measurement. The pristine sweep is
/tmp/r11u282_wP2 and the law sweep is /tmp/r11u282_wL4; the two workdir names have the same length.

- **Probe** (tests/sweep.sh, the probe stage): **regressions=0 conversions=10 changes=0**. EQUAL 3856 +
  STRICT_NOTEQUAL 231, against the base's 3846 + 241, which the pristine sweep reproduced with 0 / 0 / 0. Every
  case is uhdm-cmp-equal. The strict tally moves from `differ:fullname=98` to `88` and every other field is
  unchanged.
- **Surelog**: regressions=0 conversions=0 changes=0 (default 478 + 2, testflags 472 + 2). The law csv differs
  from pristine's only in the LowMemLib and LowMemPkg testflags detail text (the workdir path).
- **uhdm2rtlil**: regressions=0 conversions=0 changes=0 (803 / 1 / 67 in both modes). The csv is byte-identical
  to pristine's.
- **Downstream**: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT. The csv is byte-identical to
  pristine's and to results/downstream_uhdm2rtlil.csv. **0 of 805 slang-lane databases move.**
- No corpus row is touched, so the uhdm-cmp-at-0-lines gate holds on the corpora with nothing to quote.
- Both sweeps' exit codes come from the law-index check alone. The law sweep exits 1 because tests/LAWS.md was
  regenerated after the sweep, and the regenerated file is in the patch. The pristine sweep read the law index as
  current.
- **Firing census** (drivers/tracecensus.sh with `R11U282_TRACE`). It covers the probe cases and both corpora in
  both modes, with the fenced tests excluded by the harness filter built from `$FENCED`. It was frozen before the
  law sweep (evidence/predict.txt, md5 in predict.md5): 290 lines, 225 probe, 19 surelog, 46 uhdm2rtlil. Only
  the writer tags change bytes: CASELBOUND, CAHIERBOUND, LHSIPSINPLACE, CASTORPHAN, CAREPLINST, REPLCLONE,
  PROCOPINPLACE, PROCSELINST, PROCCATINST, PROCIPSINST, TFCASEINS. The `_ABSTAIN` tags and the classification tags
  CAUNSIZED, CAIMPLICIT, LHSIPSCLONE, PROCCATUNARY and PROCOPUNARY move nothing alone. **The writer tags fire on
  exactly 10 probe databases and on no corpus database** (evidence/predict_writers.txt). The corpus lines carry
  only abstentions and classification tags. Examples: Rggen default CAUNSIZED:640 on cont_assigns whose fold names
  already equal golden's; uhdm2rtlil multiplier LHSIPSCLONE:3 where the bounds are not folded constants.
- **byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1). It ran on fence-filtered hard-link mirrors
  (drivers/mirror.sh, 2560 databases mirrored per sweep, 8 fenced paths skipped): PATH_SETS_IDENTICAL 2560,
  **MOVERS 0 / 2560**. SELFCHECK reads 2559 of 2560. The self-check compares every file against one fixed file,
  and that file cannot be flagged against itself, so this is pass 201's self-check artefact and not a mover.
  Probe: **10 of 4087 databases move, exactly the 10 predicted** (the 10 conversions). Downstream: 0 of 805
  (evidence/byteverify_corpus.txt, byteverify_probe_downstream.txt).
- **Canaries**: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0. ctcan2 PASS on both (EXPECT_UNKNOWN=1 and
  6; evidence/canaries.txt).
- **Binary-path audit** (drivers/audit.sh). The cmds.txt path list is filtered by `$FENCED` before any file is
  opened. 3265 of 3315 name the sweep's own frozen binary on every `slang:` line, 0 name another binary, the other
  50 carry no `slang:` line, and 8 fenced paths are skipped. This holds for both sweeps (evidence/binary_audit.txt).
- **Determinism** (drivers/det.sh: three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver,
  SimpleUVM, Scoreboard, BuildUVMPkg and Rggen). Every row-mode with a database reads one hash in 3 of 3. That is
  12 row-modes; Scoreboard and Rggen testflags write no database on any binary. Each hash equals the law sweep's
  and the pristine sweep's (evidence/determinism.txt).
- **Byte controls** (drivers/controls.sh; the path lists are filtered by `$FENCED` first). 28 earlier repro dirs
  in both views: r11u112, r11u113, r11u114, r11u115, r11u116, r11u118, r11u119, r11u120, r11u154, r11u167,
  r11u192, r11u198, r11u256, r11u262, r11u280, r11v11u118, r11v120, v11u262, v11u280, r11u124, r11v124, r11u131,
  r11v131, r11u278, v11u278, r11u75, r11u145, r11u187. Result: **4218 case-views, 148 moving, 31 entering
  STRICT_EQUAL, 0 leaving, 0 exit-code or uhdm-cmp line changes** (evidence/controls.txt,
  controls_summary.txt). The 31 entering are r11u198 N/n24_child_for_bounds d/e, r11u256 B/b07_member_path d/e
  and G/g19_for_always d/e, r11u262 B/b39 e, v11u262 VB/vb10 d/e, and v11u262 VL vl24, vl28 to vl33 and vl36 to
  vl39 d/e (the for-generate loop-bound shapes). The other 117 movers are stage 1 on both binaries: r11u116
  grid f1, f2 and f3 (102), v11u262 VL (12), VH (2) and r11u262 B (1). They have away 0 and toward up to 16.
- **Downstream on the fresh cases** (drivers/dscases.py with both binaries). It covers the 229 case dirs whose
  default-view database moves; every other dir's default-view bytes are identical, so its downstream result is
  identical too. Result: **229 IDENTICAL on both binaries**: 177 NO_GATES on both lanes, 47 OK, 5 READ_FAIL on
  both lanes. The slang lane's 675 `.il`, `_nohier.il` and `_synth.v` files are byte-identical between the
  binaries (evidence/downstream_cases_*.txt). Full names of `ref_typespec`s do not reach RTLIL.

## History of this pass (the resume)

The first implementer's binary law2 held the ten laws alone. Its sweep, grid (1102 case-views, 0 leaving) and
census read clean. The byte controls this pass ran on law2 found breaks on legal SV where pristine was right
(evidence/law2_draft_control_breaks.txt):

- r11u192repro/cases/B/b11_genfor_unsized d/e: STRICT_EQUAL -> fullname. Fixed by the unsized re-clone,
  § genCaSelBoundUnsizedClone282.
- v11u262repro VL/vl13 and vl41 d/e: STRICT_EQUAL -> fullname. Fixed by the implicit net,
  § genCaSelBoundImplicitLhs282.
- r11u116repro/grid/f1 `pk_*_ac` (14 case-views, stage 1): chain away 2. Fixed by the unary holder,
  § genProcOpFoldUnaryKeepsInst282.

Fresh cases written to decode these breaks found three more shapes the draft broke:

- the left-side indexed part select with a non-constant right side (N `ips_*_for_sig` and `_op`), fixed by
  § genCaLhsIpsBoundCloneOnly282;
- the replication count under an unsized re-clone in an if-generate (N `rep_r_if_unsz`, `rep_q2_if`,
  `rep_q6_if`), fixed by § genCaReplCountUnsizedClone282;
- the unary holders in grid U.

The two extensions, § genProcUnaryFoldInst282 and the instance write of § genCaLhsIpsBoundCloneOnly282, came from
the same decode. Binaries: law2 57aa95ca (the draft; a comment fix rebuilt it byte-identically), law3 def80962 (+
CAIMPLICIT, CAUNSIZED, PROCOPUNARY, PROCCATUNARY; its byte controls read 0 leaving and away 0), law4 0b81965c (+
LHSIPSCLONE, REPLCLONE; the final binary). Every gate, grid, control, census, away, determinism and downstream
number above was measured on law4.

## The probe residue (evidence/residue_first_records_*.txt, residue_chains_*.tsv)

The probe has 231 STRICT_NOTEQUAL cases under the law. drivers/classify.py and chains.py give the first differing
record and its object chain. First fields: fullname 88, type 30, line 29, endcol 24, depth 15, file 15, name 9,
col 8, endline 6, value 4, count 2, decompile 1. The fold reference names on this ground that still stand:

1. **The if-generate continuous assignment, concatenation member under a ternary** (r11v23repro adv
   x09_concat_64bit_param_small and v11_concat_64bit_param: `lv = 1'b1 ? {P64, 1'b0} : 64'd0` with a
   generate-local left side). Golden reads `work@dut`, ours `work@dut.g`. This is the c7 copy branch next to
   § unaryOperandParamOwnerName145, and it was not attempted.
2. **The interface bodies** (D/mp_iface, pk_iface: a nested select bound and an indexed part-select left side in
   an interface generate block). Golden reads the interface instance for a plain left side too, so the drain laws
   abstain in interfaces. The interface leg of writeCont_assign was not decoded.
3. **A member path's index reference in the definition view** (H `*_psun_gen`, `*_pswhole_gen`, M/z_z7,
   M/z_z8). The `ref_obj BW` inside `st.addr[BW:1]` reads `work@top.g.st.addr[BW:1].addr.BW` in golden and
   `...addr[BW:1].BW` in ours. The path element's name is missing from the chain, in the same family as
   § hpMemVarSelIdxNamesByChain280. These cases move toward golden under § caHierSelBoundName282, and this record
   is left.
4. **The module-parameter unary operand in a generate-scope continuous assignment** (U/ca_mp_neg, ca_pk_neg:
   `assign z[w] = ~P`). Stage 1 on both binaries on an unrelated listing.
5. The C family's `rl_cat` and `rl_catsel` elaborated views (a concatenation left side, `col` on both binaries),
   and the D class-method case (stage 1).
6. The delay leg of writeCont_assign (`assign #D ...` with a parameter delay, M/z_z3) reads stage 1 on both
   binaries, so the leg was not transcribed.
7. The decode files evidence/decode/K_sources.txt and X_sources.txt are the first implementer's decode shapes. K
   holds casts of a bit localparam: `byte'(L)` reads stage 1 on both binaries, and `int'(L)` in a condition reads
   `file`. X holds the generate-scope concatenation and operand shapes that located the PROCCAT rule. Neither has
   a law.
8. Items (2) to (7) of the brief beyond the above were not attempted.

The rest of the fullname bucket belongs to other writers. The struct-member full names in class and importer copies
(r10sd10 g6 and v2, r10sd6 v3) were landed by the sister's pass 285 after this base. The rest are the doubled
for-generate part-select base (v11u112 b4b, b4d, b4h, v11u115 v06; TypeEmit, the sister's), the interface-array
port range fold (r10rgg4 three cases, r10vrgg4 one; ModuleEmit fillSizeDimRange), the package struct-member
parameter copies (r11u26 m4, m7, r11u28 a2), and the interface parameter operations (r11v4 v5, v6).

## Decodes stopping at the sister's ground (reported, not written)

- The doubled for-generate part-select base name (`rd[i+1][o -: 4]`, v11u112repro b4b, b4d, b4h and v11u115repro
  v06): TypeEmit emitSyntaxExpr called from ModuleEmit emitDefGenStmts, unchanged since pass 280's report.
- The interface-array port range fold (r10rgg4repro a1_noovr, b1_int_noovr, c1_p_noovr, r10vrgg4repro
  v5k_noovr_int_signed): ModuleEmit fillSizeDimRange.
- The elaborated cont_assign call fold (r10rgg6repro cells `*_ca`, type(1)): ModuleEmit emitContAssigns.
- The faces passes 276, 278 and 280 reported stand as they reported them.

## Process

**Fence.** Every corpus path list was filtered by `$FENCED` (word boundary) before any file was opened. This
covers controls.sh, mirror.sh, audit.sh and the probe and downstream byte comparisons (the path list is built, then
filtered, then compared). The census ran with the harness filter built from `$FENCED`. No fenced source, database
or cmds.txt was read or dispatched outside the gate sweeps. Every driver reads `$FENCED` fail-closed from
tools/probe/r11u107repro/canaudit.sh. Every tool variable is checked with `[ -x ]`.

**Processes.** No other agent's process was listed or signalled. The implementer stopped two of its own processes:
its first away-census script and an awaygrid run. The awaygrid driver needed an edit before the control movers
could resolve their paths. Each pid was checked by an exact match of its own `/proc/<pid>/cmdline`, never by
`pgrep -f`.

**Slips** (none touched the fence).
- One waiter loop polled a log that a script without the execute bit never wrote. The script was rerun with
  chmod. No measurement came from that window.
- The first away rerun ran without `S` exported, so awaygrid refused and wrote nothing. It was rerun.
- A `rm -f $X/*.uhdm` was refused by the harness's safety check and rewritten with a literal path.

**Main tree.** Not written.

**Files.**
- drivers/case.sh, grid.sh, gridall.sh, gridsum.py, attrib.sh, attrib.py, controls.sh, awaygrid.sh (now with
  `CB=` for control paths), tracecensus.sh, det.sh, mirror.sh and env.sh are the first implementer's.
- ctlsum.py, dscases.py, classify.py and chains.py are copied from r11u280repro.
- audit.sh and refsw.sh are new.
- The away census uses awaychain.py with strictcmp_x in place from tools/probe/r11u272repro/drivers.
