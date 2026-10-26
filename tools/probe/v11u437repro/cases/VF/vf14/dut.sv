// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial foreach (cs[i]) if (cs[i] == null) cs[i] = new;
endmodule
