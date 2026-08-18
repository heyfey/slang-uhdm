# r10rgg9 — GRID.md: the golden measurements § srlgCondOpInstValueTernFold9 is built on

**MEASUREMENT-ONLY.** Every "GOLDEN" column below is REAL SURELOG
(`~/git-repos/Surelog/build/bin/surelog -parse dut.sv -mt 0 -mp 0`), read by
`gridscan9` on the resulting database. The official `uhdm-cmp` remains the sole
acceptance judge; nothing here is a judgement.

Reproduce:

```sh
python3 gen_grid9.py
g++ -O2 -std=c++17 gridscan9.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/r10rgg9_gridscan
GRIDSCAN=/tmp/r10rgg9_gridscan ./run_grid9.sh /tmp/g <base-bin> base <pat-bin> pat
python3 score9.py /tmp/g base pat | tail -1
```

**57 cells, 0 NODB, 0 NOSLANG.** `score9.py` over the whole grid, every site and
every view: **FIXED 41, OK 214, BROKEN 0, STILL 6.** `rcaudit9.sh` records the
exit code of both binaries on all 57 cells: **all 0, SEGFAULTS(rc=139)=0.**

**Golden-vs-golden calibration:** real Surelog re-run over all 57 cells into a
second output tree — **261 rows, 0 differing.**

---

## 1. THE ARM IS PICKED FROM THE ***INSTANCE***, AND THIS REFUTES A TRANSFER OF r10rgg8's CLAUSE 1

r10rgg8 measured that `evalFunc` reads the module **DEFINITION**'s parameter
values and that an instance override never reaches its reduction. **That does
not transfer to a ternary**, and the isolating cells say so in both directions:

| cell | declaration | instance | golden ELAB vpiRhs |
|---|---|---|---|
| `p_decl0` | `P = 0` | — | **FOLDS** `constant INT:0 sz64 ct7` LOC-LESS |
| `p_decl1` | `P = 1` | — | KEEPS (the taken arm is a non-constant concat) |
| `p_ov10` | `P = 1` | `.P(0)` | **FOLDS** — the DECLARATION would have kept it |
| `p_ov01` | `P = 0` | `.P(1)` | **KEEPS** — the DECLARATION would have folded it |
| `p_split` | `P = 0` | `.P(0)` and `.P(1)` | folds at `u_a`, keeps at `u_b` |
| `p_three` | `P = 1` | `.P(0)/.P(1)/.P(0)` | folds at `u_a` and `u_c` only |
| `c_deep` | `P = 0` | 2 mid instances | folds only under `.P(0)` |
| `c_headshape` | Rggen's own source | `.WRITABLE(0/1)` | folds only at `u_a` |

The mechanism, read out of Surelog: `UhdmWriter::writeCont_assign` passes
`netlist->getParent()` — the **ModuleInstance** — to `reduceExpr`, and
`CompileHelper::getValue` consults `instance->getValue(name)` **first**.
`evalFunc` looks parameters up in the `DesignComponent`; this reduce looks them
up in the instance. Same file, same arm, opposite answer.

**The DEF view never folds**: 14/14 DEF `CA` rows keep the operation, `p_decl0`
(whose declaration value is 0) included.

## 2. WHAT THE PREDICATE MAY BE

| cell | predicate | golden |
|---|---|---|
| `p_decl0` `p_ov10` `p_split` `p_three` | module `parameter bit` | FOLDS |
| `p_int` / `p_intwide` | `parameter int`, 0 / 7 | FOLDS / KEEPS (arm 1 non-const) |
| `p_localparam` | `localparam bit LP = P & 1'b1` | FOLDS at the `.P(0)` instance |
| `p_pkgparam` / `p_pkgimport` | `pk::PP` / imported | FOLDS |
| `p_enum` | an enum constant | FOLDS |
| `p_expr_eq` `p_expr_and` `p_expr_or` `p_expr_not` | `==`, `&&`, `||`, `!` | FOLD |
| `p_genvar` | a genvar (`gb[0]` vs `gb[1]`) | FOLDS at `gb[0]` only |
| `p_net` | a NET | **KEEPS** |

## 3. WHAT THE TAKEN ARM MAY BE — the value is `get_value()`'s int64

Golden always mints the SAME object: `constant`, `INT:<v>`, `vpiSize 64`,
`vpiConstType 7` (`vpiIntConst`), **NO LOCATION**.

| cell | taken arm | golden value |
|---|---|---|
| `a_u0` / `a_u1` / `a_true_u0` | `'0` / `'1` / `'0` | `INT:0` / `INT:1` / `INT:0` |
| `a_dec0` `a_dec42` `a_bothc0` `a_bothc1` `a_true_c` | `0` `42` `9` `7` `42` | the decimal |
| `a_hex` `a_bin` | `4'hF` `4'b1010` | `INT:15` `INT:10` |
| `a_neg` | `-1` | `INT:-1` — SIGNED, not `4294967295` |
| `a_wide` | `64'hDEAD_BEEF_CAFE_BABE` | `INT:-2401053089206453570` |
| `a_str` | `"ab"` | `INT:24930` |
| `a_param` / `a_localp` | a param / localparam | its value |
| `a_concat` `a_repl` | `{2'b10,2'b11}` `{4{1'b1}}` | `INT:11` `INT:15` |
| `a_nested` | `((P) ? 1 : 2)` | `INT:2` |
| `a_clog2` | `$clog2(9)` | `INT:4` |
| `a_untaken_call` | `'0`, the UNTAKEN arm a user call | `INT:0` |

`'1` proves the reducer never sees slang's PROPAGATED width: the UHDM operand is
the source object (`BIN:1`, `vpiSize -1`) and `get_value` reads ONE bit, so the
fold is `INT:1` and never the conditional type's all-ones.

**Two cells take the OTHER outcome of the same arm.** When `get_value` POISONS
on the reduced arm, `ExprEval` does `result = the_val` and writeCont installs
**THE ARM'S OWN CONSTANT OBJECT**:

| cell | taken arm | golden ELAB vpiRhs |
|---|---|---|
| `a_over64` | `72'h1_0000_0000_0000_0000` | `constant HEX sz 72 @8:36` (its own span) |
| `a_xz` | `4'bxx01` | `constant BIN:xx01 sz 4 @8:36` |

(`get_value` refuses `> 64` bits outright and parses an x/z bit under
`strict = true`.) Both are now modelled.

## 4. THE OPERAND GATE — an arm that is NOT taken can still kill the fold

`ExprEval::reduceExpr` walks EVERY operand before it looks at the opcode: a
`constant`, an `operation` / `func_call` / `sys_func_call` / `bit_select` /
`hier_path` / `var_select` / `enum_var` passes unchecked, a `ref_obj` passes only
if `getValue(name)` finds a value, and anything else sets `constantOperands =
false` and the whole operation is handed back unreduced.

| cell | source | golden |
|---|---|---|
| `l_vecbit` | `assign vec[0] = (P) ? sig : '0;`, `P = 0` | **KEEPS** |
| `l_plainnet1` | `assign o = (P) ? sig : '0;`, `P = 0` | **KEEPS** |
| `a_net` `a_true_net` | a bare net in the taken arm | KEEPS |
| `p_net` | a bare net as the predicate | KEEPS |
| `a_untaken_call` | a user CALL in the untaken arm | FOLDS |
| `a_param` `p_enum` | a PARAMETER / ENUM name (has a value) | FOLDS |

`l_vecbit` is the isolating cell: the predicate has a value and the taken arm
IS a constant, and golden still refuses — because the arm that is **not taken**
is a bare signal reference. Rggen's own lines 61-63 and 65
(`(backdoor_valid) ? read_mask[1] : read_mask[0]`,
`(active) ? register_if.valid : '0`) are the corpus instances of the same
refusal, and they are why the head's family is TWO objects and not 257.

§ elabCaTernaryNoFoldSigRefBranch22 (r10earl22) already carried the bare-signal
half of this rule for the plain-LHS path; this pass transcribes the whole loop.

## 5. THE LHS SHAPE DECIDES THE SIZE — `tps` null vs `tps` set

`writeCont_assign` runs `adjustSize(tps, ...)` on the reduced constant, and
`tps` comes from the LHS's typespec.

| cell | LHS | golden |
|---|---|---|
| `p_decl0` and most cells | `arr[0]`, bit_select of an UNPACKED array | `INT:0` **sz 64** LOC-LESS |
| `l_partsel` | `vec[3:0]` | `INT:0` sz 64 LOC-LESS |
| `l_concat` | `{a1, b1}` | `INT:0` sz 64 LOC-LESS |
| `l_iface` | `bif.d`, an interface member | `INT:0` sz 64 LOC-LESS |
| `l_plainnet` | a plain 8-bit net | `INT:0` **sz 8** LOC-LESS |
| `l_plainnet_i` | a plain 8-bit net, arm `42` | `INT:42` **sz 8** LOC-LESS |

A plain `ref_obj` LHS takes writeCont's EARLIER
`lhs->UhdmType() == uhdmref_obj` branch, where the constant IS adjusted to the
target width. **We already matched both plain-LHS cells on the base binary**
(§ elabCaTernaryFoldIntConst22), and this pass deliberately leaves that path
untouched — it claims only the `tps`-null shapes, which are exactly the shapes
whose ELAB cont_assign we were SHARING from the def view.

## 6. CONTEXT

| cell | context | golden | ours (patched) |
|---|---|---|---|
| `c_deep` | a module 2 levels down | FOLDS per instance | MATCH |
| `c_headshape` | Rggen's own source, verbatim | FOLDS at `.WRITABLE(0)` | MATCH |
| `c_proc` | `always_comb o = (P) ? ... ;` | **NEVER folds** | MATCH (both views) |
| `c_gen` | a cont-assign in a GENERATE block | FOLDS | **residue R2** |
| `p_genvar` | a cont-assign in a generate FOR | FOLDS at `gb[0]` | **residue R2** |
| `c_iface_body` | a cont-assign in an INTERFACE body | FOLDS | **residue R3** |
| `c_port` | a port high-conn `(.i((P)?...))` | folds to the ARM object | **residue R4** |
| `c_varinit` | a var-decl initializer | keeps the operation | **residue R5** |
| `c_paraminit` | `localparam int Z = (P)?3:4` | other laws own it | **residue R6** |

`c_proc` is the negative control that matters most: a PROCEDURAL assignment is
never seen by `writeCont_assign` at all, and golden keeps the operation in both
views — which we already did and still do.
