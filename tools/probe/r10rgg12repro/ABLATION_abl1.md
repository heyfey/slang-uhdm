# r10rgg12 — ABLATION on GOLDEN: which const-function body keeps a range bound symbolic

Source: cells/abl1/top.sv (module `red`, N=4 and N=6, one localparam per shape,
one `logic [P-1:0]` declaration per localparam).  GOLDEN ONLY: slang REJECTS this
cell (`64'h600060003ffff is out of allowed range` for the two packed-2D bounds), so
the arm is a measurement of Surelog's evaluator, not a comparison.

`rcensus12` on the golden database, ELAB, instance work@top.u_a, Left bound:

```
ELAB|RANGE|work@top.u_a|logic_var:va|TS|0|L
    ==> op11[fcall:a_formal_tern(const(BIN:00000000..[68]..00000100,sz=64,ct=3,dec=000000000000..[64]..00000100)),const(UINT:1,sz=64,ct=9,dec=1)]
ELAB|RANGE|work@top.u_a|logic_var:vb|TS|0|L
    ==> op11[fcall:b_local_tern(const(UINT:4,sz=64,ct=9,dec=4)),const(UINT:1,sz=64,ct=9,dec=1)]
ELAB|RANGE|work@top.u_a|logic_var:vc|TS|0|L
    ==> op11[fcall:c_formal_cmp(const(BIN:00000000..[68]..00000100,sz=64,ct=3,dec=000000000000..[64]..00000100)),const(UINT:1,sz=64,ct=9,dec=1)]
ELAB|RANGE|work@top.u_a|logic_var:vd|TS|0|L
    ==> op11[fcall:d_formal_add(const(BIN:00000000..[68]..00000100,sz=64,ct=3,dec=000000000000..[64]..00000100)),const(UINT:1,sz=64,ct=9,dec=1)]
ELAB|RANGE|work@top.u_a|logic_var:ve|TS|0|L
    ==> op11[fcall:e_formal_tern_p2d(ref(SUBL)),const(UINT:1,sz=64,ct=9,dec=1)]
ELAB|RANGE|work@top.u_a|logic_var:vf|TS|0|L
    ==> const(INT:2,sz=64,ct=7,dec=2)
ELAB|RANGE|work@top.u_a|logic_var:vg|TS|0|L
    ==> const(INT:1125917086973951,sz=64,ct=7,dec=1125917086973951)
ELAB|RANGE|work@top.u_a|logic_var:vs|TS|0|L
    ==> const(INT:3,sz=64,ct=7,dec=3)
```

Reading (the localparam each row belongs to, and its function body):

| row | body | golden |
|---|---|---|
| `va` | `acc += ((a[i] != 0) ? 1 : 0)`, select of the FORMAL under a ternary — rggen's own `get_next_n` | **KEEPS the call** (argument folded to a BIN constant) |
| `vb` | the same shape but the select is of a function LOCAL | **KEEPS** |
| `vc` | the same + 0 | **KEEPS** |
| `vd` | `acc += 32'(a[i])` — select of the formal in a PLAIN add | **KEEPS** |
| `ve` | ternary select, PACKED-2D return | **KEEPS**, and the argument is NOT folded (`ref(SUBL)`) |
| `vf` | `acc += ((i != 0) ? 1 : 0)` — no select at all | **FOLDS** (`INT:2`) |
| `vg` | `o[i] = a[i-1] + o[i-1]` — rggen's `get_offset_list` | **FOLDS** |
| `vs` | `current_n -= list[idx]` in a while loop — rggen's `get_sub_n_list` | **FOLDS** (`INT:3`) |

The line this pass draws — a select of a function-scope value reached through a
COMPARISON / LOGICAL / BITWISE operator or a TERNARY CONDITION — separates
7 of the 8 correctly.  `vd` is the miss and is deliberately left on the FOLD
side: that is the side the arm already took before this pass, so it cannot
regress a row.
