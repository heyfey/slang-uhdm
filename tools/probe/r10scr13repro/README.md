# r10scr13 purpose-built goldens

Build one with
`~/git-repos/Surelog/build/bin/surelog -parse -mt 0 -mp 0 <files>` (NO
`-nobuiltin`) and read it with `tools/probe/r10scr13a.cpp`, the PORT
`High_conn` census (module_inst / interface_inst for the ELAB view, ref_module
rows prefixed `REFMOD` for the DEF view).

| file | law |
|---|---|
| `t1.sv` | § connExprBindsNet — first sighting: concat/unary operands bind the NET, the ternary's CONDITION binds the VAR, a bare ref binds the VAR |
| `t2.sv` | § connExprBindsNet — the discriminator, every name used exactly once: the operand at the expression's OWN start column (the leading identifier) binds the VAR, all others bind the NET; the DEF-view `ref_module` binds the net in every position |
| `t3.sv` | § connActualParamFold — one file, four parameter homes ($unit localparam sized-hex / $unit `int` localparam / $unit parameter / module localparam) all fold to a copy of the parameter's own constant at the use site; module and $unit ENUM members already folded. Port `g` (`UP + UI`) is the un-implemented whole-expression fold |
| `t4a.sv` + `t4b.sv` | the CROSS-ROOT-FILE half: a $unit ENUM member declared in another root file keeps its ref_obj bound to the implicit wire (implemented), and so does a $unit PARAMETER (measured, NOT implemented) |
