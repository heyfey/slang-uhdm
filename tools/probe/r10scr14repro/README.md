# r10scr14 purpose-built goldens

Build one with
`~/git-repos/Surelog/build/bin/surelog -parse -mt 0 -mp 0 <files>` (NO
`-nobuiltin`) and read it with `tools/probe/r10scr14a.cpp` (param_assign tree
census, operation TYPESPEC included) or `tools/probe/r10scr14b.cpp` (whole-db
constant / ref_obj leaf census — the right microscope for a "folded or not"
question).

| file | law |
|---|---|
| `t5.sv` | § elabOvRefCopiesParam — the crossed matrix that decides the override copy's SIZE: source constant 64-bit (`localparam A64 = 1024*1024`) vs 32-bit (`localparam int A32`), against a formal whose default is a plain LITERAL (`P = 8`), an OPERATION (`P = 4 * 2`), or `int`. Only the OPERATION formal keeps the SOURCE width — Surelog derives no typespec from it, so `adjustSize` has nothing to re-render at. Scr1SvTests `i_memory_tb .SIZE(SCR1_MEM_SIZE)` is the `sub_op` row |
| `t6.sv` | § genProcParamFold — one module parameter in six positions of ONE gen-scope process. Bare Rhs, binary operand and indexed-part-select bound fold; a TF-CALL ARGUMENT does not, in any of its three spellings (`fn(W)`, `fn(W / 8)`, `tk(W)`). Scr1SvTests `scr1_memory_tb_axi:229 mem_read(..., W_DATA/8)` inside the `rw_if` loop |
