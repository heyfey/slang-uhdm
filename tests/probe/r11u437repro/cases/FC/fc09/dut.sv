// § foreachCgArrLoopVarRef437
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial begin foreach (cs[i]) cs[i] = new; foreach (cs[i]) cs[i].sample(); end
endmodule
