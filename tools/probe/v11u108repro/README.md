# v11u108 — adversarial verification of r11u108 (face 5 type-parameter var kind, face 2 package-typedef member binding)

Base `c4adbb58`. The implementer's patch reproduces bit for bit. The law binary md5 matches
(`81f13e49`). The six rows' cmp counts and heads match. The u2r conversion
(`type_param_packed_dim`, both modes) matches, as do the 6/1608 u2r byte movers and the
38-arm wide boundary. With `R11U108_OFF=1` the output is byte-identical to pristine on 239 arms.

The break grid found three wrong cells where pristine was right. All three are on legal SV,
and all three are fixed here in `src/TypeEmit.cpp`.

## Defects in r11u108, fixed here

| arm (brk/) | golden | pristine | r11u108 | fix |
|---|---|---|---|---|
| f5/b02_attr `(* keep *) rt_t x;` | packed_array_var **with** vpiAttribute | logic_var with the attribute | packed_array_var, attribute **dropped** (41/1) | attach `findAttrs(sym)` to a body (`DataDeclaration`) var: 0/0 |
| f5/b30_attr_two (two attributes) | the same | the same | the same (53/1) | 0/0 |
| f5/b23_port_default `input rt_t a = '0` | packed_array_var with vpiExpr | logic_var with the vpiExpr | vpiExpr **dropped** (19/1) | refused, back to pristine (92/1, kind head) |
| f5/b24_output_init `output rt_t o = 8'h5a` | the same | the same | the same (19/1) | refused (92/1) |
| f2/c25_import_member (`import p1::*;` in q2, member `row_t [0:1] U`) | **unnamed** member-span logic_typespec, elem → `p1::row_t` | unnamed, elem → `row_t` | binds the shared `p1::row_t` (binding AWAY) | law gated off, back to pristine |
| f2/c28_named_import (`import p1::row_t;`) | the same | the same | the same | back to pristine |

* **Attributes.** Surelog `makeVar_` attaches `sig->attributes()` to every variable it makes
  ([ElaborationStep.cpp:2403](../../../../Surelog/src/DesignCompile/ElaborationStep.cpp#L2403)).
  The dimensionless factory returns before the caller's attribute code runs.
  A port's attributes do not ride on the packed_array_var (golden b26), so the fix is gated to
  a `DataDeclaration` parent.
* **Port default.** The r11u108 refusal read the internal symbol's initializer. A port's
  default lives on the PortSymbol and on the declarator, so it slipped through. The fix
  refuses on the declarator's initializer, the same terms as f5a18.
* **Import.** A typedef of a named type that is declared in the struct's own package, or
  reached through a scoped name (`p1::row_t`, brk c10), binds the shared `pkg::T` object in
  golden. The same typedef reached through an import keeps the member-span wrapper. So the
  law now fires only for the struct's own package or a `ScopedName` member type.

Switches: `V11U108_FIX5_OFF=1` drops the first two fixes, `V11U108_FIX2_OFF=1` drops the
third, and `V11U108_FIX_OFF=1` drops all three. With all three off, the output is
byte-identical to r11u108 on all 239 arms. The r11u108 switches still work the same way
(`evidence/SWITCH.txt`).

## Measured

* Six rows (`evidence/HEADS.txt`): base 148/138/17/60/60/108. After the fixes (fix2) they read
  148/**17**/17/**47**/**0**/108, the same as r11u108.
  * `type_param_packed_dim` CONVERTS in both modes. The committed rows are
    `type_param_packed_dim,default,CMP_NOTEQUAL,decompile:,,` and
    `type_param_packed_dim,testflags,CMP_NOTEQUAL,decompile:,,`. The sweep reads CMP_EQUAL.
  * Next heads: stamped_gen_param is the element ref `(q2::q2::row_t)` inside `q2::row_t`,
    RHS null. type_param_override_elem_sel is the override `logic [1:0]` (32:17), RHS null.
* Break grid (`evidence/BRK.txt`, `CELLS.txt`): 54 arms, goldens calibrated golden-vs-golden to 0.
  * Face 5: every kind cell is TO-GOLDEN. The next heads that appear (b15, b29, r06) are the
    override-element family (R1), which pristine's own ladder already lists behind its first
    rung.
  * Face 2: every binding cell is TO-GOLDEN, apart from the two import cells fixed here.
* The whole-dump distance on face-2 arms goes UP by about 20-45 lines even though the binding
  is right. The pristine member-span copy carried a range and elem subtree that matched lines
  of golden's elem subtree by coincidence. Our `pkg::T` listing object has no elem and no
  range (R0, fenced), so those lines are gone. The judge and the name-keyed cells both read
  toward golden.
* Gates (`evidence/GATES.txt`): all green on fix2.
  * The corpora do not move from fix2 to r11u108: u2r 0/1608. On Surelog, the only movers are
    the UVM nondeterminism class.
  * Boundary (`evidence/BOUNDARY.txt`): r11u108 to fix2 moves only the 3 layout-tail arms,
    and `layoutproof154.sh` reports OK.

## Residues (ranked)
* **R0** (fenced): stamped_gen_param 17/1. The DEF-listing `pkg::T` object for a typedef of a
  named type has no elem and no range. It is built from ParamEmit's package listing.
* **R1**: the override element of a packed-array type-parameter typespec. This is the head on
  type_param_override_elem_sel 47/1, on brk b15/b29, and on v11u93b107 r06, where the count
  rises 17→92 because the typespec is now bound and its element is the default.
* **R2**: an initialised or port-default type-parameter packed-array declaration stays
  logic_var (f5a18, b23, b24). Golden carries vpiExpr on a packed_array_var, and the
  initializer is emitted by the fenced caller.
* **R3**: face-2 gaps where golden also binds the shared object: a multi-dim member
  (`row_t [1:0][0:1]`, c13) and a union member (c14). Face-5 gaps: interface body var (b03) and non-ANSI port (b05).
  The written-dims cell with an attribute (b25) lacks vpiAttribute in both pristine and
  r11u108.
* Faces 1, 3 and 4 are fenced, as r11u108 states. who108 on the const_cast_signext golden
  places the missing alias copy on the module function's cast operation (golden id 38),
  which is ExprEmit's ground, and on the drained return var, which is ModuleEmit's ground.

## Tools
`gridv108.sh` runs the arm driver (MODE=tf|def, records rc and grc). `rowcmp108.sh` runs the
row cmp, `swcheck2v108.sh` checks the switch identities, `varfields108.py` lists each var's
direct fields, and `bndv108.sh` runs the boundary. The cell scorers are r11u108's
`cell108.py`/`cellm108.py` with `cen108`/`cenm108`.
