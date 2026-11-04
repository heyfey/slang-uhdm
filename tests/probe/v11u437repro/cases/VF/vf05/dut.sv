// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg(int w); coverpoint a; endgroup
cg cs[2];
initial foreach (cs[k]) cs[k] = new(k);
endmodule
