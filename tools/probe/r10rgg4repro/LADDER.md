# r10rgg4 — the ladder, base vs patch, and the NEW HEAD

`tools/probe/r10ladder1repro/ctladder` is MEASUREMENT-ONLY; `uhdm-cmp` remains
the sole judge. Both ladders were taken on the SAME pinned pair of databases the
gates used (`/tmp/r10rgg4_slw_{base,pat}/default/Rggen-50ccbd70/slang.uhdm`
against the cached golden `6fc99d8f4119ff55b3e1/golden.uhdm`).

```
              RUNGS  STOP      MAXVIS
base           63    FIXPOINT  94488/252296
patch          61    FIXPOINT  94487/252296
```

## FAMILY CENSUS — identical row for row except ONE

| count base | count patch | FAM |
|---|---|---|
| 24 | 24 | `hier_path\|VpiName\|TEXT:register_if[#].value[#+:#]\|...` |
| 11 | 11 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#*j+k` |
|  6 |  6 | `constant\|VpiDecompile\|TEXT:#\|-#` |
|  3 |  3 | `<null>\|<lhs-null>\|EXTRA-OURS` |
|  2 |  2 | `operation\|VpiType\|KIND:operation>constant` |
|  2 |  2 | `constant\|VpiType\|KIND:constant>operation` |
|  2 |  2 | `constant\|VpiType\|KIND:constant>func_call` |
| **2** | **0** | **`constant\|VpiSize\|INT:G>O`  <- § sizeDimOvrChain4** |
|  2 |  2 | `constant\|VpiDecompile\|TEXT:#\|#+i` |
|  2 |  2 | `constant\|VpiDecompile\|TEXT:#\|#+#*i+#` |
|  2 |  2 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX(+i)` |
|  1 |  1 | `logic_typespec\|VpiType\|KIND:logic_typespec>bit_typespec` |
|  1 |  1 | `constant\|VpiDecompile\|TEXT:#'hab\|#` |
|  1 |  1 | `constant\|VpiDecompile\|O-EXTRA-SUFFIX(+#*i+#*j+k)` |
|  1 |  1 | `constant\|VpiDecompile\|O-EXTRA-PREFIX(-)` |
|  1 |  1 | `constant\|VpiDecompile\|DIGITS-ONLY` |

The whole 2-rung delta is the family this pass names, and no other family moved
by a single rung. That is the ladder-level attribution of the two byte movers.

## THE NEW HEAD — R0 for the next pass

`rowheads.sh` (official `uhdm-cmp`, Rggen default): **50 cmp lines / 1 head ->
64 cmp lines / 1 head.**

```
rggen_or_reducer.sv
  62   localparam bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);
  64   localparam int               NEXT_N      = get_next_n(SUB_N_LIST);
  66   logic [NEXT_N-1:0][WIDTH-1:0] next_data;

head object: constant @ 64:58-64:68  (the `SUB_N_LIST` ACTUAL ARGUMENT)
  < func_call(get_next_n) @ 66:10-66:16
  < operation @ 66:10-66:18  < range @ 66:9-66:21
  < logic_typespec @ 66:3-66:32 < logic_var(next_data) @ 66:33-66:42
  < module_inst(u_reducer) < gen_scope

field: vpiDecompile / BIN  (vpiSize:400 = 25 x 16, agreed; vpiConstType 3, agreed)
LHS(golden): ...0000000000000100                       (the value 4)
RHS(ours)  : ...0011000000000000001000000000000001000... (a 16-bit-field list)
```

Read: elaborating the range of `logic [NEXT_N-1:0][WIDTH-1:0] next_data`
re-folds `NEXT_N` by INLINING the constant call `get_next_n(SUB_N_LIST)`, and the
two sides disagree on the 400-bit `SUB_N_LIST` argument constant that the inlined
call receives — golden hands it `4`, we hand it the packed list our own
`get_sub_n_list(N)` fold produced. This is the ladder's rung-8 family
(`constant|VpiDecompile|TEXT:#|...`, 11+6 rungs), i.e. the SECOND of the three
families rgg3's fixpoint left on the map, and it is now the head.
