// § foreachCgArrLoopVarRef437
program prg (input clk, input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial foreach (cs[i]) cs[i] = new;
endprogram
