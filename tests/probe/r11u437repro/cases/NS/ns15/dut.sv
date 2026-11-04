// § foreachCgArrLoopVarRef437
module top(input clk, input [3:0] a);
covergroup cg @(posedge clk); coverpoint a; endgroup
cg cs[3];
initial foreach (cs[i]) cs[i] = new;
endmodule
