// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[1:0];
initial foreach (cs[i]) cs[i] = new;
endmodule
