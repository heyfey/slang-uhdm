# r10rgg8 — GRID.md: the golden measurements § srlgUnvaluedActualLitRetFold8 is built on

**MEASUREMENT-ONLY.** Every "GOLDEN" column below is REAL SURELOG
(`~/git-repos/Surelog/build/bin/surelog -parse dut.sv -mt 0 -mp 0`), read by
`gridscan` on the resulting database. The official `uhdm-cmp` remains the sole
acceptance judge; nothing here is a judgement.

Reproduce:

```sh
python3 gen_grid.py
GRIDSCAN=/tmp/r10rgg8_gridscan ./run_grid.sh /tmp/g <base-bin> base <pat-bin> pat
python3 score.py /tmp/g base pat | tail -1
```

129 cells. `score.py` over the whole grid, every site and every view:
**FIXED 69, OK 754, BROKEN 0, STILL 43.**

---

## 1. THE ARM IS PICKED FROM THE DECLARATION, NOT THE INSTANCE

| cell | declaration | instance | golden arm | golden ELAB cont_assign RHS |
|---|---|---|---|---|
| `f_pd0` | `PD = 0` | — | else | `constant BIN:1 sz1 @12:14` |
| `f_pd1` | `PD = 1` | — | if (reads the actual) | `func_call` KEPT |
| `f_override1` | `PD = 0` | `.PD(1)` | **else** | `constant BIN:1 sz1 @12:14` |
| `f_override0` | `PD = 1` | `.PD(0)` | **if** | `func_call` KEPT |
| `f_split` | `PD = 0` | `.PD(0)` and `.PD(1)` | else at BOTH | `constant BIN:1` at BOTH |
| `a_inst2` / `a_inst3` | `PD = 0` | 2 / 3 instances | else | the constant at EVERY instance |

`f_override0` is the cell that makes this necessary: reading the INSTANCE value
there folds a cont_assign golden leaves alone. The mechanism is Surelog's:
`UhdmWriter::writeCont_assign` passes the module DEFINITION (`DesignComponent*
mod`) as the value scope to `reduceExpr`, so `ExprEval::evalFunc` executes the
body against the DEFINITION's own parameter values.

**The DEF view NEVER folds** — `work@m`'s own cont_assign keeps the `func_call`
in all 129 cells, on golden and on both binaries.

## 2. THE ACTUAL'S SHAPE DECIDES WHETHER THE REDUCTION IS ATTEMPTED AT ALL

`evalFunc` reduces every actual before executing the body, and a reduction that
poisons `invalidValue` discards the whole result even when the executed path
never reads the formal.

| actual | cell | golden |
|---|---|---|
| plain name (net / port / var) | `a_lit1`, `c_net_actual` | FOLDS |
| constant | `c_allconst_actual` | FOLDS |
| concat / operation / CONST select | `c_select_actual` | FOLDS |
| nested user call | `h_callarg` | FOLDS |
| iface-port member, port has a **MODPORT** | `h_modport`, `h_mp_noports`, `h_full` | FOLDS |
| iface-port member, PLAIN interface port | `c_hierpath_actual`, `h_intlhs`, `h_ifparam` | **KEEPS** |
| struct member of a port | `h_struct` | **KEEPS** |
| submodule net (`u_s.q`) | `h_submod` | **KEEPS** |
| select with a NON-CONSTANT index | `h_arr` | **KEEPS** |

`h_intlhs` and `h_mp_noports` are the isolating pair: identical source except
`bus_t bus_if` vs `bus_t.slave bus_if`, and they split. It is the MODPORT, not
the interface, and not the LHS shape (`h_modport` drives a port, `h_full` and
`h_mp_noports` drive an internal `logic`, all three fold).

Rggen's `pre_decode(bus_if.address)` is the modport row: `rggen_bus_if.slave`.

## 3. THE BODY

Folds (the location column is the folded constant's own line:col):

| cell | body | golden |
|---|---|---|
| `a_lit1` `a_lit0` | `else return '1;` / `'0` | `BIN:1`/`BIN:0` sz1 @ the literal |
| `a_vecret` `a_intret` `a_signedret` `a_bitret` | same, return type `logic[7:0]`/`int`/`logic signed[7:0]`/`bit` | `BIN` of **the RETURN TYPE's** width @ the literal |
| `b_if_arm_lit` | `PD = 1`, the IF arm returns the literal | folds from the **if** arm |
| `b_multiret` | two returns | the FIRST |
| `b_nested_call` | `else return g();` | `g`'s literal, @ **g's** line |
| `b_twoargs_mixed` | one const actual, one not | FOLDS |
| `b_static_fn` | `function static` | FOLDS |
| `e_pkgfunc` / `e_pkgfunc_import` | package function, qualified / imported | FOLDS @ the package literal |
| `b_arg_used_untaken_only` | `t = address;` BEFORE the if | FOLDS — an unvalued assignment poisons only when READ |
| `b_loop_ret` `b_loop_noret` `b_case_param` `b_fname_assign` `b_localdecl` | loop / case / `f = ...` / local var | FOLD (locations in the table) |

Refuses:

| cell | why | golden |
|---|---|---|
| `b_taken_reads`, `b_else_reads`, `f_pd1`, `f_override0` | the EXECUTED path reads the unvalued actual | KEEPS |
| `b_noelse` | no return on the executed path | KEEPS |
| `b_recursion` | recursive | KEEPS |
| `b_localparam` | the body declares a `localparam` | KEEPS |
| `b_sideeffect` | writes a module signal | KEEPS |
| `b_read_modsig` | returns a module net | KEEPS |
| `b_read_param` | returns `P[0]`, a select of a parameter | KEEPS |
| `b_clog2_of_arg` | `$clog2(<unvalued>)` consumes the value | KEEPS |
| `a_sized`, and see § 4 | returns a **HEX-based** literal | KEEPS |

## 4. THE LITERAL GRID — 16 literal forms × 4 return types, 64 cells

The ONLY forms golden refuses are the **HEX-based** ones, and they refuse in all
four return types: `8'h2a`, `4'h5`, `32'hdead`. `'1 '0 0 1 3 42 1'b1 8'd42
8'b101010 8'sd3 1'd0 2'b11` all fold. `-1` folds too, but to a LOC-LESS constant
(it is a unary operation, not a literal) and is out of this law's claim.

`'1` / `'0` come out as the RETURN TYPE's width in binary form
(`logic` → `BIN:1` sz1 dec `1`; `logic[7:0]` → `BIN:11111111` sz8;
`int` → 32 ones), NEVER as slang's `size -1, decompile '1` — hence the rewrite
at the cont-assign RHS site. The eight `L_u1_*` / `L_u0_*` cells all assign to
the SAME 32-bit net, so the width is provably the return type's, not the
target's.

## 5. THE FOUR CELLS THAT ARE NOT MEASURABLE ON THIS SIDE

`b_outformal` (a function with an `output` formal called from a cont-assign) and
`e_classmethod` (a class method called from a cont-assign) are rejected by
**slang itself**, on the base binary and the patched one alike — a pre-existing
slang/Surelog divergence, symmetric, counted by `run_grid.sh` as NOSLANG, and
outside this pass.
